#!/bin/sh

echo "ssh -p${remote_ssh_port}"

if [ -z $remote_ssh_key ]; then
    echo "SSH: 📝 Using Password"
    mkdir -p -v ./rsync/ && rsync -trvh --progress --ignore-existing -e "ssh -p${remote_ssh_port}" ${remote_ssh_user}@${remote_ssh_host}:${remote_ssh_web_root} ${local_web_root} --log-file=./rsync/rsync-$(date +"%Y-%m-%d").log
else
    echo "SSH: 🔑 Using SSH Key"
    mkdir -p -v ./rsync/ && rsync -trvh --progress --ignore-existing -e "ssh -i${remote_ssh_key} -p${remote_ssh_port}" ${remote_ssh_user}@${remote_ssh_host}:${remote_ssh_web_root} ${local_web_root} --log-file=./rsync/rsync-$(date +"%Y-%m-%d").log
fi
