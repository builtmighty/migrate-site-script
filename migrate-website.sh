#!/bin/sh
red=`tput setaf 196`
green=`tput setaf 2`
yellow=`tput setaf 3`
blue=`tput setaf 12`
magenta=`tput setaf 207`
cyan=`tput setaf 51`
orange=`tput setaf 208`
purple=`tput setaf 99`
grey=`tput setaf 248`
reset=`tput sgr0`
SCRIPT_SUMMARY_REPORT="\n\n========================================================\n              📋 Script Summary Report 📋  \n--------------------------------------------------------\n";
full_script_start_time=$(date +%s);
export SCRIPT_SUMMARY_REPORT;
export red;
export green;
export yellow;
export blue;
export magenta;
export orange;
export purple;
export grey;
export cyan;
export reset;

# Import .env.
export $(grep -v '^#' .env | xargs);

echo "Port:"$export_external_db_port
echo "Host:"$export_external_db_host

# ==============================================================================
# Migrate Site from Remote Server to Local Server

# ----------------------
# Optional Steps:
# ----------------------
# * Clear WEB ROOT of all Files/Directories
# ** WP: Activate Maintenance Mode
# * Sync Files from Remote Server
# * Migrate Database from Remote Server
# ** WP: Update WP Config and Site URL
# ** WP: Clear out WP Engine Specific Configurations and update wp-config with DB Credentials
# ** WP: Install Kinsta Plugins (Only use if migrating TO Kinsta)
# ** WP: Refresh Permalinks & Clear All Caches
# ** WP: Deactivate Maintenance Mode
# ==============================================================================
while true; do
    read -p "
##################################################################
${red}🧨 !WARNING! 🧨 ${reset} - ${yellow}Backup your site before running${reset} -
##################################################################

You will be asked to confirm before each item below is ${orange}executed${reset}:

${grey}
* Clear WEB ROOT of all Files/Directories
** WP: Activate Maintenance Mode
* Sync Files from Remote Server
* Migrate Database from Remote Server
** WP: Update WP Config and Site URL
** WP: Clear out WP Engine Specific Configurations and update wp-config with DB Credentials
** WP: Install Kinsta Plugins
** WP: Refresh Permalinks & Clear All Caches
** WP: Deactivate Maintenance Mode
${reset}
------------------------------------------------------------------

🧯 ARE YOU SURE YOU WANT TO ${yellow}PROCEED${reset} WITH ${orange}THE SITE MIGRATION ${reset} 🧯(y/n)" yn
    case $yn in
        [Yy]* )
            break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done

printf "\n==================================================================\n\n"
# Clear WEB ROOT of all Files/Directories?
while true; do
    read -p "${red}🚧 Clear WEB ROOT (${reset}${green}${local_web_root}${reset}${red})${reset} of all Files/Directories in preparation for a full SYNC? 🚧
    ${grey}(Skip Step if you ONLY want new Files to Sync)${reset} (y/n)" yn
    case $yn in
        [Yy]* )
            script_start_time=$(date +%s);
            printf "\n [$(TZ=America/Detroit date +'%x %X %Z')] >>>> ❌ Clearing WEB ROOT of all Files/Directories ... \n\n" && chmod -R 777 ${local_web_root} && rm -rf ${local_web_root}* && rm -rf ${local_web_root}*.* ;
            script_end_time=$(date +%s);
            script_exec_time=$((script_end_time - script_start_time));
            SCRIPT_SUMMARY_REPORT+="\n - ✅ WEB ROOT (${local_web_root}) Directory Wiped - Execution Time: ${script_exec_time} seconds";
            break;;
        [Nn]* )
            SCRIPT_SUMMARY_REPORT+="\n - ❌ WP MEDIA File Sync from Remote Server Skipped ";
            break;;
        * ) echo "Please answer yes or no.";;
    esac
done

printf "\n"
# Activate Maintenance Mode?
while true; do
    read -p "🚧 Activate ${yellow}Maintenance Mode?${reset} (Skip step! if you cleared all files) 🚧? (y/n)" yn
    case $yn in
        [Yy]* )
            script_start_time=$(date +%s);
            printf "\n [$(TZ=America/Detroit date +'%x %X %Z')] >>>>  🚧 Activating Maintenance Mode... \n\n" && wp --path=${local_web_root} scripts/maintenance-mode activate && wp --path=${local_web_root} cache flush && wp --path=${local_web_root} kinsta cache purge;
            script_end_time=$(date +%s);
            script_exec_time=$((script_end_time - script_start_time));
            SCRIPT_SUMMARY_REPORT+="\n - ✅ Maintenance Mode was Activated - Execution Time: ${script_exec_time} seconds";
            break;;
        [Nn]* )
            SCRIPT_SUMMARY_REPORT+="\n - ❌ Maintenance Mode was Skipped";
            break;;
        * ) echo "Please answer yes or no.";;
    esac
done

printf "\n"
# Sync Files from Remote Server?
while true; do
    read -p "${green}🚧 Sync Files${reset} from Remote Server? 🚧? (y/n)" yn
    case $yn in
        [Yy]* )
            printf "\n [$(TZ=America/Detroit date +'%x %X %Z')] >>>> ⏬ Syncing Files from Remote Server ... \n\n" && source scripts/sync-remote-files.sh ;
            script_end_time=$(date +%s);
            script_exec_time=$((script_end_time - script_start_time));
            SCRIPT_SUMMARY_REPORT+="\n - ✅ Files Synced from Remote Server - Execution Time: ${script_exec_time} seconds";
            break;;
        [Nn]* )
            SCRIPT_SUMMARY_REPORT+="\n - ❌ File Sync from Remote Server Skipped ";
            break;;
        * ) echo "Please answer yes or no.";;
    esac
done


printf "\n"
# Migrate Database from Remote Server ?
while true; do
    read -p "🚧 ${magenta}Migrate Database${reset} from Remote Server? 🚧? (y/n)" yn
    case $yn in
        [Yy]* )
            script_start_time=$(date +%s);
            printf "\n [$(TZ=America/Detroit date +'%x %X %Z')] >>>> 💾 Migrating Database from Remote Server ... \n\n" && source scripts/import-remote-db.sh;
            script_end_time=$(date +%s);
            script_exec_time=$((script_end_time - script_start_time));
            SCRIPT_SUMMARY_REPORT+="\n - ✅ Migrated Database from Remote Server - Execution Time: ${script_exec_time} seconds";
            break;;
        [Nn]* )
            SCRIPT_SUMMARY_REPORT+="\n - ❌ Database Migration from Remote Server Skipped ";
            break;;
        * ) echo "Please answer yes or no.";;
    esac
done

printf "\n"
# Update WP Config and Site URL?
while true; do
    read -p "🚧 ${orange}Update WP Configs${reset} and Site URL? 🚧? (y/n)" yn
    case $yn in
        [Yy]* )
            script_start_time=$(date +%s);
            printf "\n [$(TZ=America/Detroit date +'%x %X %Z')] >>>> 📍 Updating Remote Site URL to Local URL... \n\n" && source scripts/wp-update-url.sh;
            script_end_time=$(date +%s);
            script_exec_time=$((script_end_time - script_start_time));
            SCRIPT_SUMMARY_REPORT+="\n - ✅ WP Config and Site URL updated - Execution Time: ${script_exec_time} seconds";
            break;;
        [Nn]* )
            SCRIPT_SUMMARY_REPORT+="\n - ❌  WP Config and Site URL updates were Skipped";
            break;;
        * ) echo "Please answer yes or no.";;
    esac
done

# Clear out WP Engine Specific Configurations?
while true; do
    read -p "${red}🚧 Clear WP Engine Specific Configurations? 🚧${reset}? (y/n)" yn
    case $yn in
        [Yy]* )
            script_start_time=$(date +%s);
            printf "\n [$(TZ=America/Detroit date +'%x %X %Z')] >>>> 📂 Clearing out WP Engine Specific Configurations ... \n\n" source sh scripts/clean-wpe-dependant-configs.sh;
            script_end_time=$(date +%s);
            script_exec_time=$((script_end_time - script_start_time));
            SCRIPT_SUMMARY_REPORT+="\n - ✅ WP Engine Specific Configurations Cleared! - Execution Time: ${script_exec_time} seconds";
            break;;
        [Nn]* )
            SCRIPT_SUMMARY_REPORT+="\n - ❌ Removing WP Engine Specific Configurations was Skipped";
            break;;
        * ) echo "Please answer yes or no.";;
    esac
done

printf "\n"
# Install Kinsta Plugins ?
while true; do
    read -p "🚧 Install Kinsta Plugins? 🚧? (y/n)" yn
    case $yn in
        [Yy]* )
            script_start_time=$(date +%s);
            printf "\n [$(TZ=America/Detroit date +'%x %X %Z')] >>>> 🔌 Install Kinsta Plugins ... \n\n" && source scripts/install-kinsta-plugins.sh ;
            script_end_time=$(date +%s);
            script_exec_time=$((script_end_time - script_start_time));
            SCRIPT_SUMMARY_REPORT+="\n - ✅ Installed Kinsta Plugins - Execution Time: ${script_exec_time} seconds";
            break;;
        [Nn]* )
            SCRIPT_SUMMARY_REPORT+="\n - ❌ Kinsta Plugins Installation was Skipped";
            break;;
        * ) echo "Please answer yes or no.";;
    esac
done

# Refresh Permalinks & Clear All Caches
while true; do
    read -p "🚧 Refresh Permalinks & Clear All Caches? 🚧? (y/n)" yn
    case $yn in
        [Yy]* )
            script_start_time=$(date +%s);
            printf "\n [$(TZ=America/Detroit date +'%x %X %Z')] >>>>  🧼 Refreshing Permalinks and 🧹 Clearing WP/Kinsta Caches... \n\n" && source scripts/clear-local-cache-refresh-permalinks.sh;
            script_end_time=$(date +%s);
            script_exec_time=$((script_end_time - script_start_time));
            SCRIPT_SUMMARY_REPORT+="\n - ✅ Refreshed Permalinks and Cleared WP/Kinsta Caches - Execution Time: ${script_exec_time} seconds";
            break;;
        [Nn]* )
            SCRIPT_SUMMARY_REPORT+="\n - ❌ Permalinks and Cache Clears were Skipped";
            break;;
        * ) echo "Please answer yes or no.";;
    esac
done

# Dectivate Maintenance Mode?
while true; do
    read -p "${red}🚧 Dectivate Maintenance Mode? 🚧${reset}? (y/n)" yn
    case $yn in
        [Yy]* )
            script_start_time=$(date +%s);
            printf "\n [$(TZ=America/Detroit date +'%x %X %Z')] >>>>  🚧 Dectivating Maintenance Mode... \n\n" && wp --path=${local_web_root} maintenance-mode deactivate && wp --path=${local_web_root} cache flush && wp --path=${local_web_root} kinsta cache purge;
            script_end_time=$(date +%s);
            script_exec_time=$((script_end_time - script_start_time));
            SCRIPT_SUMMARY_REPORT+="\n - ✅ Maintenance Mode Deactivated - Execution Time: ${script_exec_time} seconds";
            break;;
        [Nn]* )
            SCRIPT_SUMMARY_REPORT+="\n - ❌ Maintenance Mode Deactivation Skipped ";
            break;;
        * ) echo "Please answer yes or no.";;
    esac
done


# ===========================================================================
# 📋 Script Summary Report Output 📋
# ------------------------------------------------------------------

# Get Script Execution Time for Report
full_script_end_time=$(date +%s);
full_script_exec_time=$((full_script_end_time - full_script_start_time));
formatted_duration=$(printf "%d minutes, %d seconds\n" $(($full_script_exec_time/60)) $(($full_script_exec_time%60)))
# Add Script Execution Time to Report
SCRIPT_SUMMARY_REPORT+="\n\n--------------------------------------------------------\n"
SCRIPT_SUMMARY_REPORT+=" 🕰️  TOTAL Script Execution Time: ${formatted_duration}"
SCRIPT_SUMMARY_REPORT+="\n--------------------------------------------------------\n\n"

# Output Report
REPORT_DATE=$(TZ="America/New_York" date +"%Y-%m-%d_%I-%M%p");
printf "$SCRIPT_SUMMARY_REPORT";
printf "$SCRIPT_SUMMARY_REPORT" > ./logs/migrate_report--$REPORT_DATE.txt;
