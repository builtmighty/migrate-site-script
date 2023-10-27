#!/bin/sh
rsync_log_filename=rsync-$(date +"%Y-%m-%d").log && echo "${rsync_log_filename}"
echo "🧛 Gathering file count to transfer"
num_files=$(rsync -avn --ignore-existing --exclude '*.sql' -e "ssh -i${remote_ssh_key} -p${remote_ssh_port}" ${remote_ssh_user}@${remote_ssh_host}:${remote_ssh_web_root} ${local_web_root} | wc -l)
echo "Total Files to Transfer: ${num_files}"

if [ -z $remote_ssh_key ]; then
    echo "SSH: 📝 Using Password"
    mkdir -p -v ./logs/rsync && rsync -trhv --stats --ignore-existing --exclude '*.sql' -e "ssh -p${remote_ssh_port}" ${remote_ssh_user}@${remote_ssh_host}:${remote_ssh_web_root} ${local_web_root} --log-file=./logs/rsync/${rsync_log_filename} | pv -lpes $num_files > /dev/null

else
    echo "SSH: 🔑 Using SSH Key"
    mkdir -p -v ./logs/rsync && rsync -trhv --stats --ignore-existing --exclude '*.sql' -e "ssh -i${remote_ssh_key} -p${remote_ssh_port}" ${remote_ssh_user}@${remote_ssh_host}:${remote_ssh_web_root} ${local_web_root} --log-file=./logs/rsync/${rsync_log_filename} | pv -lpes $num_files > /dev/null
fi
echo "File Sync Finished 🏁!"
tail -15 ./logs/rsync/${rsync_log_filename}

# Old rsync Method (without progressbar):
# mkdir -p -v ./logs/rsync && rsync -trh --stats --info=progress2 --ignore-existing --exclude '*.sql' -e "ssh -p${remote_ssh_port}" ${remote_ssh_user}@${remote_ssh_host}:${remote_ssh_web_root} ${local_web_root} --log-file=./logs/rsync/rsync-$(date +"%Y-%m-%d").log
