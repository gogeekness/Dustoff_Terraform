#!/bin/bash
agent_ok() { ssh-add -l > /dev/null 2>&1 || [ $? -eq 1 ]; }
if ! agent_ok; then
    if [ -e ~/.ssh/agent.info ]; then
       eval $(< ~/.ssh/agent.info)
    fi
fi
if ! agent_ok; then
    eval $(ssh-agent | tee ~/.ssh/agent.info)
fi
cat ~/.ssh/agent.info

ssh-add ../.ssh/ed_lustre
ssh-add ../.ssh/gh_tf
