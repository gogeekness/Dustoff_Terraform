#!/bin/bash

### A script to add ssh-keys for github ssh access
### It checks for previous agents and removes them
### Adds the ssh-keys at the end
### run a source 'source ssh-activate.sh'

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

ssh-add ~/.ssh/ed_lustre
ssh-add ~/.ssh/gh_tf
