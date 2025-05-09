#!/bin/sh
rsync_log_filename=rsync-$(date +"%Y-%m-%d").log && echo "${rsync_log_filename}"
echo "🧛 Gathering file count to transfer"

if [ -z $remote_ssh_key ]; then
    echo "SSH: 📝 Using Password"
    num_files=$(rsync -avn --ignore-existing --exclude-from=${rsync_exclude_file_path} --exclude '*.sql' --exclude='.git/' -e "sshpass -p ${remote_ssh_pass} ssh -p${remote_ssh_port} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null" ${remote_ssh_user}@${remote_ssh_host}:${remote_ssh_web_root} ${local_web_root} | wc -l)
    echo "Total Files to Transfer: ${num_files}"
    mkdir -p -v ./logs/rsync && rsync -trhv --stats --ignore-existing --exclude-from=${rsync_exclude_file_path} --exclude '*.sql' --exclude='.git/' -e "sshpass -p ${remote_ssh_pass} ssh -p${remote_ssh_port} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null" ${remote_ssh_user}@${remote_ssh_host}:${remote_ssh_web_root} ${local_web_root} --log-file=./logs/rsync/${rsync_log_filename} | pv -lpes $num_files > /dev/null

else
    echo "SSH: 🔑 Using SSH Key"
    num_files=$(rsync -avn --ignore-existing --exclude-from=${rsync_exclude_file_path} --exclude '*.sql' --exclude='.git/' -e "ssh -i${remote_ssh_key} -p${remote_ssh_port} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null" ${remote_ssh_user}@${remote_ssh_host}:${remote_ssh_web_root} ${local_web_root} | wc -l)
    echo "Total Files to Transfer: ${num_files}"
    mkdir -p -v ./logs/rsync && rsync -trhv --stats --ignore-existing --exclude-from=${rsync_exclude_file_path} --exclude '*.sql' --exclude='.git/' -e "ssh -i${remote_ssh_key} -p${remote_ssh_port} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null" ${remote_ssh_user}@${remote_ssh_host}:${remote_ssh_web_root} ${local_web_root} --log-file=./logs/rsync/${rsync_log_filename} | pv -lpes $num_files > /dev/null
fi
echo "File Sync Finished 🏁!"
tail -15 ./logs/rsync/${rsync_log_filename}

# Old rsync Method (without progressbar):
# mkdir -p -v ./logs/rsync && rsync -trh --stats --info=progress2 --ignore-existing --exclude-from=${rsync_exclude_file_path} --exclude '*.sql' --exclude='.git/' -e "ssh -p${remote_ssh_port}" ${remote_ssh_user}@${remote_ssh_host}:${remote_ssh_web_root} ${local_web_root} --log-file=./logs/rsync/rsync-$(date +"%Y-%m-%d").log


echo ${rsync_exclude_file_path}
