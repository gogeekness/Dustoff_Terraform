#!/bin/bash -x

ssh_agent=$(ps -aux | grep "ssh-agent \-D" | wc -l)
echo $ssh_agent

PDD=$(ps -aux | grep $USER.*ssh-agent | cut -c 11-17) 
echo "extra agents: $PDD, need to remove."
if [[ -n $pr ]]; then
	for pr in $PDD; do
		echo "Killing $PDD"
		kill -15 $pr
	done
fi

if [[ $ssh_agent -lt 1 ]]; then
	eval `ssh-agent -s`
else
	echo "ssh agent is already active."
	echo "Stopping."
	exit 1
fi
ssh-add ../.ssh/ed_lustre
ssh-add ../.ssh/gh_tf
