
source ".env";

# Initialize the --ignore-table options string
IGNORE_TABLES_STRING=""

# Read the exclude tables file and construct the --ignore-table options
while IFS= read -r TABLE
do
    echo "  - 🙈 Ignoring Table: ${TABLE}"
    IGNORE_TABLES_STRING+=" --ignore-table=${DB_NAME}.${TABLE}"
done < ${export_external_exlude_tables_file}


echo "👨‍🚀 The DB is on a different server than the web root... Export the DB directly from the remote server \n\n"

# Setting up SSH Tunnel for DB Connection using SSH Key on port 3337
echo "Setting up SSH Tunnel: 🔑 Using SSH Key"
ssh -f -i${remote_ssh_key} -p ${remote_ssh_port} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -L 3337:${export_external_db_host}:${export_external_db_port} ${remote_ssh_user}@${remote_ssh_host} sleep 20 && \


# Dump the database structure without data
# printf "\n [$(TZ=America/Detroit date +'%x %X %Z')] >>>> ⏬ Remote DB Structure Export Started... \n\n" && mysqldump -u ${export_db_user} -p${export_db_pass} -P3337 -h 127.0.0.1 --no-data ${export_db_name} > db_structure.sql

# Dump the data excluding specified tables
printf "\n [$(TZ=America/Detroit date +'%x %X %Z')] >>>> ⏬ Remote DB Data Export Started... \n\n";
eval mysqldump --no-tablespaces -u ${export_db_user} -p${export_db_pass} -P3337 -h 127.0.0.1 ${export_db_name} $IGNORE_TABLES_STRING --no-create-info -v > db_data.sql

# Combine the structure and data dumps
cat db_structure.sql db_data.sql > database_full_backup.sql

# Clean up intermediate files
rm db_structure.sql db_data.sql

echo "Database dump completed and saved to $OUTPUT_FILE"
