# Migrate Website
> Bash Script for Migrating a Website's Codebase and Database from a Remote Server to a Local Server

## Usage:

1. Clone this repository to your local server.
2. Fill out the `.env` file with the appropriate values.
3. Run `bash migrate.sh` from the root of the repository.

## Optional Steps:
> Each Step in the Script will ask you if you want to run it, you can skip any of the following steps if needed

* Clear WEB ROOT of all Files/Directories (Optional)
* Activate Maintenance Mode
* Sync Files from Remote Server
* Migrate Database from Remote Server
* Update Site URL
* Clear out WP Engine Specific Configurations in wp-config.php (Only for migrating FROM WP Engine)
* Install Kinsta Plugins (Only use if migrating TO Kinsta)
* Refresh Permalinks & Clear All Caches
* Deactivate Maintenance Mode
