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
- **DB IMPORT/EXPORT:** The script uses `mysqldump` to export the database from the remote server and `mysql` to import the database to the local server.
  - If the env var `export_external_db_host` is NOT set the script will create a SSH Tunnel to the remote server for Export.
  - If `export_external_db_host` is SET we directly connect to the external DB server from our own server. This is useful if you have a DB server that is not on the same server as your web server.

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
- `export_external_db_host`: (Optional) If the DB is External from the Remote Server. Enter the host of the database to be exported. If not leave this blank
- `remote_domain`: Enter the domain of the remote server

### Local Server Credentials:
- `import_db_name`: Enter the name of the database to import the Remote DB into
- `import_db_user`: Enter the username of the database to import the Remote DB into
- `import_db_host`: Enter the host of the database to import the Remote DB into
- `import_db_pass`: Enter the password of the database to import the Remote DB into
- `local_web_root`: Enter the path to the web root of the local server
- `local_db_backup_filename`: Enter the filename of the database backup to be created
- `local_domain`: Enter the domain of the local server
