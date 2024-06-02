# Migrate Website from Remote Server to Local Server
> Bash Script for Migrating a Website's Codebase and Database from a Remote Server to a Local Server *(Skip WP steps if Laravel)*

## Usage:

1. Clone this repository to your local server.
2. Fill out the `.env` file with the appropriate server credentials.
3. Run `bash migrate.sh` from the root of the repository.

## Script Steps:
> Each Step in the Script will ask you if you want to run it, you can skip any of the following steps if needed

- Clear WEB ROOT of all Files/Directories
- WP: Activate Maintenance Mode
- Sync Files from Remote Server
- Migrate Database from Remote Server
- WP: Update WP Config and Site URL
- WP: Clear out WP Engine Specific Configurations and update wp-config with DB Credentials
- WP: Install Kinsta Plugins (Only use if migrating TO Kinsta)
- WP: Refresh Permalinks & Clear All Caches
- WP: Deactivate Maintenance Mode

---

# Features:

- **REPORTS:** Upon script completion, a report is "Results" report is generated. You can find this in the `/logs` directory named: `migrate_report--{date_here}.txt`
- **RSYNC:** The migrate script uses `rsync` to sync files from the remote server to the local server. We have included a progress bar feature for the file sync progress as well as a log of all the syned files within the `/logs` directory
- **DB IMPORT/EXPORT:** The script uses `mysqldump` to export the database from the remote server and `mysql` to import the database to the local server. The DB export process uses a SSH Tunnel to connect to the remote server and export the database. If the MySQL Database lives on the same server as the Web Server, you can set the `export_db_host` .env var to `127.0.0.1` and the script will export the database direclty from the Web Server. If the MySQL Database lives on a different server, you can set the `export_db_host` .env var to the IP of the External MySQL Server.
- **Exclude Files:** The script uses a `rsync-exclude.txt` file to exclude files and directories from the rsync process. This file is located in the root of the repository. You can add any files or directories you want to exclude from the rsync process to this file.
- **Exclude DB Tables:** The script uses a `db-tables-exclude.txt` file to exclude tables from the database export/import process. This file is located in the root of the repository. You can add any tables you want to exclude from the database export/import process to this file.




## ENV File Explained:

### Remote Server Crendetials:
- `remote_ssh_key`: The local path to the Private SSH Key for connecting to the remote server. Although this is optional, it is ***HIGHLY*** recommended to a SSH Key to connect. If not set you will be prompted for a password to connect to the remote server.
- `remote_ssh_host`: Enter the IP/FQDN of the remote server
- `remote_ssh_user`: Enter the username of the remote server
- `remote_ssh_port`: Enter the SSH port of the remote server
- `remote_ssh_web_root`: Enter the path to the web root of the remote server
- `export_db_name`: Enter the name of the database to be exported
- `export_db_user`: Enter the username of the database to be exported
- `export_db_pass`: Enter the password of the database to be exported
- `export_db_filename`: Enter the filename of the database to be exported
- `export_db_port`: Enter the port of the database to be exported
- `export_db_host`: Enter the host of the database to be exported ( IE: Local: *127.0.0.1* | External: *123.43.567.1*)
- `remote_domain`: Enter the domain of the remote server

### Local Server Credentials:
- `import_db_name`: Enter the name of the database to import the Remote DB into
- `import_db_user`: Enter the username of the database to import the Remote DB into
- `import_db_host`: Enter the host of the database to import the Remote DB into
- `import_db_pass`: Enter the password of the database to import the Remote DB into
- `local_web_root`: Enter the path to the web root of the local server
- `local_db_backup_filename`: Enter the filename of the database backup to be created
- `local_domain`: Enter the domain of the local server

### Exclusions:
- `rsync_exclude`: Enter the path to the file containing the list of files/directories to exclude from the rsync process
- `db_tables_exclude`: Enter the path to the file containing the list of tables to exclude from the database export/import process
