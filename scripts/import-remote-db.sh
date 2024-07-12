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
                # Install netcat if not already installed
                # apt install -y netcat;

                # Initialize the --ignore-table options string
                IGNORE_TABLES_STRING=""

                # Read the exclude tables file and construct the --ignore-table options
                while IFS= read -r TABLE
                do
                    echo "  - 🙈 Ignoring Table: ${TABLE}"
                    IGNORE_TABLES_STRING+=" --ignore-table=${DB_NAME}.${TABLE}"
                done < ${db_exclude_tables_file_path}

                # Setting up SSH Tunnel for DB Connection using SSH Key on port 3337
                if [ -z $remote_ssh_key ]; then
                    echo "🚇 SSH Tunnel to DB: 📝 Using Password"
                    printf "\n [$(TZ=America/Detroit date +'%x %X %Z')] >>>> 🚇 Creating SSH Tunnel with Password for DB Connection... \n\n" && sshpass -p ${remote_ssh_pass} ssh -4 -f -N -p ${remote_ssh_port} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -L 3337:${export_db_host}:${export_db_port} ${remote_ssh_user}@${remote_ssh_host} &
                else
                    echo "🚇 SSH Tunnel to DB: 🔑 Using SSH Key"
                    printf "\n [$(TZ=America/Detroit date +'%x %X %Z')] >>>> 🚇 Creating SSH Tunnel with Key for DB Connection... \n\n" && ssh -4 -f -N -i${remote_ssh_key} -p ${remote_ssh_port} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -L 3337:${export_db_host}:${export_db_port} ${remote_ssh_user}@${remote_ssh_host} &
                fi

                # Wait for SSH tunnel to connect
                # while ! nc -z localhost 3337; do sleep 1; done
                while ! (echo > /dev/tcp/localhost/3337) >/dev/null 2>&1; do sleep 1; done

                # Capture the SSH Tunnel PID
                SSH_TUNNEL_PID=$(lsof -t -i:3337);
                echo "🚇 SSH Tunnel PID: ${SSH_TUNNEL_PID}";

                # Read the contents of the file into a variable
                file_contents=$(cat db-tables-exclude.txt)

                # Check if the contents match "no_tables_ignored"
                if [ "$file_contents" == "no_tables_ignored" ]; then
                    # Dump the whole database
                    printf "\n [$(TZ=America/Detroit date +'%x %X %Z')] >>>> ⏬ Remote DB Export Started... \n\n" && \
                    mysqldump --quick --single-transaction --compress --no-tablespaces -v -u ${export_db_user} -p${export_db_pass} -P3337 -h 127.0.0.1 ${export_db_name} | sed 's/DEFINER=[^*]*\*/\*/g' | sed 's/SQL SECURITY DEFINER//g' > ${export_db_filename}
                else
                    # Dump the database structure without data
                    printf "\n [$(TZ=America/Detroit date +'%x %X %Z')] >>>> ⏬ Remote DB Structure Export Started... \n\n" && \
                    mysqldump -v -u ${export_db_user} -p${export_db_pass} -P3337 -h 127.0.0.1 --no-data ${export_db_name} > db_structure.sql

                    # Dump the data excluding specified tables
                    printf "\n [$(TZ=America/Detroit date +'%x %X %Z')] >>>> ⏬ Remote DB Data Export Started... \n\n";
                    eval mysqldump --quick --single-transaction --compress --no-tablespaces -u ${export_db_user} -p${export_db_pass} -P3337 -h 127.0.0.1 ${export_db_name} $IGNORE_TABLES_STRING --no-create-info -v | sed 's/DEFINER=[^*]*\*/\*/g' | sed 's/SQL SECURITY DEFINER//g' > db_data.sql

                    # Combine the structure and data dumps
                    cat db_structure.sql db_data.sql > ${export_db_filename}

                    # Clean up intermediate files
                    rm db_structure.sql db_data.sql
                fi

                # Kill the SSH Tunnel Process
                printf "\n Database dump completed and saved to ${export_db_filename}. \n🚇 Closing SSH Tunnel...\n\n"
                kill -9 $SSH_TUNNEL_PID

                # Improve the Import Process by adding the following to the SQL file:
                echo "Optimizing the SQL file for Quicker Import...
                - autocommit=0;
                - unique_checks=0;
                - foreign_key_checks=0;"
                sed -i '1i\
                SET GLOBAL net_buffer_length = 1000000;\
                SET GLOBAL max_allowed_packet = 1000000000;\
                SET autocommit=0;\
                SET unique_checks=0;\
                SET foreign_key_checks=0;\
                START TRANSACTION;' ${export_db_filename};
                echo -e "SET unique_checks=1;\nSET foreign_key_checks=1;\nCOMMIT;" >> ${export_db_filename};

                printf "\n [$(TZ=America/Detroit date +'%x %X %Z')] >>>> ⛔ Deleting all tables from the Database ${red}${import_db_name}${reset} in preparation for a fresh DB Import ... \n\n" && echo "SET FOREIGN_KEY_CHECKS = 0;" $(mysqldump --add-drop-table --no-tablespaces --no-data -h${import_db_host} -u ${import_db_user} -p${import_db_pass} ${import_db_name} | grep 'DROP TABLE') "SET FOREIGN_KEY_CHECKS = 1;" | mysql -h${import_db_host} -u ${import_db_user} -p${import_db_pass} ${import_db_name} &&  \
                printf "\n [$(TZ=America/Detroit date +'%x %X %Z')] >>>> ⏫ Importing Database ... \n\n" && mysql -h${import_db_host} -u ${import_db_user} -p${import_db_pass} ${import_db_name} < ${export_db_filename} &&  \
                printf "\n [$(TZ=America/Detroit date +'%x %X %Z')] >>>> 🥳 Database Migration Complete! \n\n"; break;

            break;;
        [Nn]* )
            break;;
        * ) echo "Please answer yes or no.";;
    esac
done
