#!/bin/bash -x

#set -euo pipefail

ssh_agent=$(ps -aux | grep "ssh-agent \-D" | wc -l)
if [[ $ssh_agent -gt 0 ]]; then 
	PDD=$(ps -aux | grep $USER.*ssh-agent | cut -c 11-17) 
	echo "extra agents: $PDD, need to remove."
	if [[ -n $pr ]]; then
		for pr in $PDD; do
			echo "Killing $PDD"
			kill -15 $pr
		done
	fi
	# No need for purge
fi

if [ -z "${SSH_AUTH_SOCK:-}" ]; then
	echo "[ssh] Starting new ssh-agent..."
	eval $(ssh-agent -s)
	# Trap ensures agent is killed when script exits
	trap "ssh-agent -k" EXIT
else
	echo "[ssh] Reusing existing ssh-agent (PID ${SSH_AGENT_PID:-unknown})"
fi


if [[ $ssh_agent -lt 1 ]]; then
	eval `ssh-agent -s`
else
	echo "ssh agent is already active."
	echo "Stopping."
	exit 1
fi

KEY1="$HOME/.ssh/ed_lustre"
KEY2="$HOME/.ssh/gh_tf"

if ! ssh-add -l | grep -q "$(ssh-keygen -lf "$KEY1" | awk '{print $2}')"; then
  echo "[ssh] Adding key: $KEY1"
  ssh-add "$KEY1"
else
  echo "[ssh] Key already loaded, skipping ssh-add"
fi

if ! ssh-add -l | grep -q "$(ssh-keygen -lf "$KEY2" | awk '{print $2}')"; then
  echo "[ssh] Adding key: $KEY2"
  ssh-add "$KEY2"
else
  echo "[ssh] Key already loaded, skipping ssh-add"
fi

echo "[ssh] Loaded keys:"
#ssh-add ../.ssh/ed_lustre
#ssh-add ../.ssh/gh_tf
