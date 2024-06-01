#!/bin/bash
red=`tput setaf 1`
green=`tput setaf 2`
reset=`tput sgr0`
exec_timestamp=$(TZ=America/Detroit date +'%x %X %Z')

# 🚇 Creating the SSH Tunnel to the old Server for DB connection
# ⏬ Export the DB Remotely Down to the Local Server
# 📖 Replace the Collation/CHARSET to match the DB version (Maria) , otherwise it does not import correctly
# ⛔ Deleting all tables from the Import Database in preparation for a fresh DB Import
# ⏬ Perform the Import to the Local Server’s DB.

# ------------------------------------------------------------------------------------------------
while true; do
    read -p "Do you want to ${green}start${reset} the ${red}Remote${reset} DB migration? (y/n)" yn
    case $yn in
        [Yy]* )
                # Initialize the --ignore-table options string
                IGNORE_TABLES_STRING=""

                # Read the exclude tables file and construct the --ignore-table options
                while IFS= read -r TABLE
                do
                    echo "  - 🙈 Ignoring Table: ${TABLE}"
                    IGNORE_TABLES_STRING+=" --ignore-table=${DB_NAME}.${TABLE}"
                done < ${export_external_exlude_tables_file}

                # Setting up SSH Tunnel for DB Connection using SSH Key on port 3337
                if [ -z $remote_ssh_key ]; then
                    echo "🚇 SSH Tunnel to DB: 📝 Using Password"
                    printf "\n [$(TZ=America/Detroit date +'%x %X %Z')] >>>> 🚇 Creating SSH Tunnel for DB Connection... \n\n" && ssh -4 -f -N -p ${remote_ssh_port} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -L 3337:${export_external_db_host}:${export_external_db_port} ${remote_ssh_user}@${remote_ssh_host} &
                else
                    echo "🚇 SSH Tunnel to DB: 🔑 Using SSH Key"
                    printf "\n [$(TZ=America/Detroit date +'%x %X %Z')] >>>> 🚇 Creating SSH Tunnel for DB Connection... \n\n" && ssh -4 -f -N -i${remote_ssh_key} -p ${remote_ssh_port} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -L 3337:${export_external_db_host}:${export_external_db_port} ${remote_ssh_user}@${remote_ssh_host} &
                fi

                # Capture the SSH Tunnel PID
                SSH_PID=$!
                wait $PID
                echo "🚇 SSH Tunnel PID: ${SSH_PID}";

                # Dump the database structure without data
                printf "\n [$(TZ=America/Detroit date +'%x %X %Z')] >>>> ⏬ Remote DB Structure Export Started... \n\n" && mysqldump -u ${export_db_user} -p${export_db_pass} -P3337 -h 127.0.0.1 --no-data ${export_db_name} > db_structure.sql

                # Dump the data excluding specified tables
                printf "\n [$(TZ=America/Detroit date +'%x %X %Z')] >>>> ⏬ Remote DB Data Export Started... \n\n";
                eval mysqldump --no-tablespaces -u ${export_db_user} -p${export_db_pass} -P3337 -h 127.0.0.1 ${export_db_name} $IGNORE_TABLES_STRING --no-create-info -v > db_data.sql

                # Combine the structure and data dumps
                cat db_structure.sql db_data.sql > ${export_db_filename}

                # Clean up intermediate files
                rm db_structure.sql db_data.sql

                echo "Database dump completed and saved to ${export_db_filename}. 🚇 Closing SSH Tunnel..."
                # Kill the SSH process
                kill $SSH_PID

                printf "\n [$(TZ=America/Detroit date +'%x %X %Z')] >>>> ⛔ Deleting all tables from the Database ${red}${import_db_name}${reset} in preparation for a fresh DB Import ... \n\n" && echo "SET FOREIGN_KEY_CHECKS = 0;" $(mysqldump --add-drop-table --no-tablespaces --no-data -h${import_db_host} -u ${import_db_user} -p${import_db_pass} ${import_db_name} | grep 'DROP TABLE') "SET FOREIGN_KEY_CHECKS = 1;" | mysql -h${import_db_host} -u ${import_db_user} -p${import_db_pass} ${import_db_name} &&  \
                printf "\n [$(TZ=America/Detroit date +'%x %X %Z')] >>>> ⏫ Importing Database ... \n\n" && mysql -h${import_db_host} -u ${import_db_user} -p${import_db_pass} ${import_db_name} < ${export_db_filename} &&  \
                printf "\n [$(TZ=America/Detroit date +'%x %X %Z')] >>>> 🥳 Database Migration Complete! \n\n"; break;

            break;;
        [Nn]* )
            break;;
        * ) echo "Please answer yes or no.";;
    esac
done
