#cloud-config

# ─── Users ───────────────────────────────────────────────────────────────────
users:
  - name: reseke
    gecos: "Richard Eseke"
    groups: [sudo, adm, systemd-journal]
    shell: /bin/bash
    sudo: ALL=(ALL) NOPASSWD:ALL
    lock_passwd: true                  # password login disabled; SSH key only
    ssh_authorized_keys:
      - ${ssh_public_key}

# Disable root SSH login entirely
disable_root: false 

# ─── System packages ─────────────────────────────────────────────────────────
package_update: true
package_upgrade: true
packages:
  - curl
  - wget
  - git
  - vim
  - htop
  - jq
  - unattended-upgrades
  - fail2ban
  - chrony                            # NTP sync

# ─── Files written to disk ───────────────────────────────────────────────────
write_files:

  # Cron: daily system update + autoremove (runs as root via /etc/cron.d)
  - path: /etc/cron.d/auto-update
    owner: root:root
    permissions: '0644'
    content: |
      SHELL=/bin/bash
      PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
      # Daily at 03:15 — update + autoremove, log to /var/log/auto-update.log
      15 3 * * * root apt-get update -qq && apt-get -y -qq upgrade && apt-get -y -qq autoremove >> /var/log/auto-update.log 2>&1

  # Cron: hourly disk usage check — warns if any filesystem > 80%
  - path: /usr/local/bin/disk-check.sh
    owner: root:root
    permissions: '0755'
    content: |
      #!/bin/bash
      THRESHOLD=80
      LOGFILE=/var/log/disk-check.log
      TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

      df -h --output=pcent,target | tail -n +2 | while read -r line; do
        PCT=$(echo "$line" | awk '{print $1}' | tr -d '%')
        MNT=$(echo "$line" | awk '{print $2}')
        if [ "$PCT" -ge "$THRESHOLD" ]; then
          echo "[$TIMESTAMP] WARNING: $MNT is at $${PCT}% capacity" >> "$LOGFILE"
        fi
      done

  - path: /etc/cron.d/disk-check
    owner: root:root
    permissions: '0644'
    content: |
      SHELL=/bin/bash
      PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
      # Hourly disk usage check
      0 * * * * root /usr/local/bin/disk-check.sh

  # Cron: weekly log rotation flush (supplements logrotate)
  - path: /etc/cron.d/log-flush
    owner: root:root
    permissions: '0644'
    content: |
      SHELL=/bin/bash
      PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
      # Sunday 02:00 — force logrotate run
      0 2 * * 0 root /usr/sbin/logrotate --force /etc/logrotate.conf >> /var/log/logrotate-manual.log 2>&1

  # SSH hardening — applied before sshd restarts
  - path: /etc/ssh/sshd_config.d/99-hardening.conf
    owner: root:root
    permissions: '0600'
    content: |
      PermitRootLogin no
      PasswordAuthentication no
      PubkeyAuthentication yes
      X11Forwarding no
      MaxAuthTries 3
      LoginGraceTime 30
      AllowUsers reseke

  # fail2ban — protect SSH
  - path: /etc/fail2ban/jail.d/sshd.local
    owner: root:root
    permissions: '0644'
    content: |
      [sshd]
      enabled  = true
      port     = ssh
      maxretry = 5
      bantime  = 1h
      findtime = 10m

# ─── Run commands (in order) ─────────────────────────────────────────────────
runcmd:
  # Reload SSH with hardening config
  - systemctl restart ssh

  # Enable and start fail2ban
  - systemctl enable fail2ban
  - systemctl start fail2ban

  # Enable unattended-upgrades (security patches only, auto)
  - dpkg-reconfigure -f noninteractive unattended-upgrades

  # Ensure reseke's home and .ssh exist with correct permissions
  - mkdir -p /home/reseke/.ssh
  - chown -R reseke:reseke /home/reseke/.ssh
  - chmod 700 /home/reseke/.ssh

  # Sync clock immediately
  - chronyc makestep

  # Signal that cloud-init finished cleanly
  - echo "cloud-init complete $(date)" >> /var/log/cloud-init-done.log

# ─── Final message in cloud-init log ─────────────────────────────────────────
final_message: |
  Cloud-init finished after $UPTIME seconds.
  User reseke is ready. SSH key auth only.