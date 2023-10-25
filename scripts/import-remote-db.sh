#!/bin/bash
red=`tput setaf 1`
green=`tput setaf 2`
reset=`tput sgr0`
exec_timestamp=$(TZ=America/Detroit date +'%x %X %Z')

# 🚇 Creating the SSH Tunnel to the old Server for DB connection
# ⏬ Export the DB Remotely Down to Kinsta
# 📖 Replace the Collation/CHARSET to match the DB version (Maria) , otherwise it does not import correctly
# ⛔ Deleting all tables from the Import Database in preparation for a fresh DB Import
# ⏬ Perform the Import to Kinsta’s DB.

# ------------------------------------------------------------------------------------------------
# ## Full Command:
# printf "\n >>>> 🚇 Creating SSH Tunnel for DB Connection... \n\n" && ssh -f -L 3336:127.0.0.1:3306 root@167.99.105.42 sleep 20 && printf "\n >>>> ⏬ Remote DB Export Started... \n\n" && mysqldump --no-tablespaces -u ${export_db_user} -p${export_db_pass} -P3336 -h 127.0.0.1 ${export_db_name} > ${export_db_filename} && printf "\n >>>> 📖 Updating DB Export's Collation/CHARSET to match the DB version ... \n\n" && sed -i 's/utf8mb4_0900_ai_ci/utf8_general_ci/g' ${export_db_filename} && sed -i 's/CHARSET=utf8mb4/CHARSET=utf8/g' ${export_db_filename} && sed -i 's/utf8mb4/utf8/g' ${export_db_filename} && printf "\n >>>> ❌ Deleting all tables from the Database ${red}${import_db_name}${reset} in preparation for a fresh DB Import ... \n\n" && echo "SET FOREIGN_KEY_CHECKS = 0;" $(mysqldump --add-drop-table --no-data -u ${import_db_user} -p${import_db_pass} ${import_db_name} | grep 'DROP TABLE') "SET FOREIGN_KEY_CHECKS = 1;" | mysql -u ${import_db_user} -p${import_db_pass} ${import_db_name} && printf "\n >>>> ⏫ Importing Database ... \n\n" && mysql -u ${import_db_user} -p${import_db_pass} ${import_db_name} < ${export_db_filename} && printf "\n >>>> 🥳 Migration Complete! \n\n";

# Output:
# printf "\n [${exec_timestamp}] >>>> 🚇 Creating SSH Tunnel for DB Connection... \n\n" && printf "\n [${exec_timestamp}] >>>> ⏬ Remote DB Export Started... \n\n" && printf "\n [${exec_timestamp}] >>>> 📖 Updating DB Export's Collation/CHARSET to match the DB version ... \n\n" && printf "\n [${exec_timestamp}] >>>> ❌ Deleting all tables from the Database ${red}${import_db_name}${reset} in preparation for a fresh DB Import ... \n\n" && printf "\n [${exec_timestamp}] >>>> ⏫ Importing Database ... \n\n" && printf "\n [${exec_timestamp}] >>>> 🥳 Migration Complete! \n\n";

while true; do
    read -p "Do you want to ${green}start${reset} the ${red}Remote${reset} DB migration? (y/n)" yn
    case $yn in
        [Yy]* )

                if [ -z $export_external_db_host ]; then
                    echo "🏰 DB is on the same server as the web root... Create a SSH Tunnel into the server to export the DB"
                    if [ -z $remote_ssh_key ]; then
                        echo "SSH Tunnel: 📝 Using Password"
                        printf "\n [$(TZ=America/Detroit date +'%x %X %Z')] >>>> 🚇 Creating SSH Tunnel for DB Connection... \n\n" && ssh -f -p ${remote_ssh_port} -L 3336:127.0.0.1:3306 ${remote_ssh_user}@${remote_ssh_host} sleep 20
                    else
                        echo "SSH Tunnel: 🔑 Using SSH Key"
                        printf "\n [$(TZ=America/Detroit date +'%x %X %Z')] >>>> 🚇 Creating SSH Tunnel for DB Connection... \n\n" && ssh -f -i${remote_ssh_key} -p ${remote_ssh_port} -L 3336:127.0.0.1:3306 ${remote_ssh_user}@${remote_ssh_host} sleep 20
                    fi
                    printf "\n [$(TZ=America/Detroit date +'%x %X %Z')] >>>> ⏬ Remote DB Export Started... \n\n" && mysqldump --no-tablespaces -u ${export_db_user} -p${export_db_pass} -P3336 -h 127.0.0.1 ${export_db_name} > ${export_db_filename}
                else
                    echo "👩‍🚀 The DB is on a different server than the web root... Export the DB directly from the remote server"
                    printf "\n [$(TZ=America/Detroit date +'%x %X %Z')] >>>> ⏬ Remote DB Export Started... \n\n" && mysqldump -v --no-tablespaces -u ${export_db_user} -p${export_db_pass} -P3306 -h ${export_external_db_host} ${export_db_name} > ${export_db_filename}
                fi
                printf "\n [$(TZ=America/Detroit date +'%x %X %Z')] >>>> ⛔ Deleting all tables from the Database ${red}${import_db_name}${reset} in preparation for a fresh DB Import ... \n\n" && echo "SET FOREIGN_KEY_CHECKS = 0;" $(mysqldump --add-drop-table --no-tablespaces --no-data -h${import_db_host} -u ${import_db_user} -p${import_db_pass} ${import_db_name} | grep 'DROP TABLE') "SET FOREIGN_KEY_CHECKS = 1;" | mysql -h${import_db_host} -u ${import_db_user} -p${import_db_pass} ${import_db_name} &&  \
                printf "\n [$(TZ=America/Detroit date +'%x %X %Z')] >>>> ⏫ Importing Database ... \n\n" && mysql -h${import_db_host} -u ${import_db_user} -p${import_db_pass} ${import_db_name} < ${export_db_filename} &&  \
                printf "\n [$(TZ=America/Detroit date +'%x %X %Z')] >>>> 🥳 Database Migration Complete! \n\n"; break;

                break;;

        [Nn]* ) break;;
        * ) echo "Please answer yes or no.";;
    esac
done
