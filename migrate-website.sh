#!/bin/sh


red=`tput setaf 1`
green=`tput setaf 2`
yellow=`tput setaf 3`
blue=`tput setaf 4`
magenta=`tput setaf 5`
cyan=`tput setaf 6`
reset=`tput sgr0`

# Import .env.
export $(grep -v '^#' .env | xargs);

# ==============================================================================
# Migrate Site from Remote Server to Local Server

# ----------------------
# Optional Steps:
# ----------------------
# Clear WEB ROOT of all Files/Directories (Optional)
# Sync Files from Remote Server
# Clear out WP Engine Specific Configurations and update wp-config with Kinsta DB Credentials
# Install Kinsta Plugins
# Migrate Database from Remote Server
# Update Site URL
# Activate Maintenance Mode
# Deactivate Maintenance Mode
# Refresh Permalinks & Clear All Caches
# ==============================================================================
while true; do
    read -p "
##################################################################
${red}🧨 !WARNING! 🧨 ${reset} - ${yellow}Backup your site before running${reset} -
##################################################################

You will be asked before each item below is executed:

${cyan}
* Clear WEB ROOT of all Files/Directories (Optional)
* Sync Files from Remote Server
* Migrate Database from Remote Server
** WP: Update WP Config and Site URL
** WP: Clear out WP Engine Specific Configurations and update wp-config with DB Credentials
** WP: Install Kinsta Plugins
** WP: Activate Maintenance Mode
** WP: Deactivate Maintenance Mode
** WP: Refresh Permalinks & Clear All Caches
${reset}
------------------------------------------------------------------

🧯 ARE YOU SURE YOU WANT TO ${yellow}PROCEED${reset} WITH ${red}THE SITE MIGRATION ${reset} 🧯  (y/n)" yn
    case $yn in
        [Yy]* )
            break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done


# Clear WEB ROOT of all Files/Directories?
while true; do
    read -p "${red}🚧 Clear WEB ROOT of all Files/Directories in preparation for a full SYNC? (Skip Step if you ONLY want new Files to Sync) 🚧${reset}? (y/n)" yn
    case $yn in
        [Yy]* )
            printf "\n [$(TZ=America/Detroit date +'%x %X %Z')] >>>> ❌ Clearing WEB ROOT of all Files/Directories ... \n\n" && chmod -R 777 ${local_web_root} && rm -rf ${local_web_root}* && rm -rf ${local_web_root}.* ;
            break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no.";;
    esac
done


# Sync Files from Remote Server?
while true; do
    read -p "${red}🚧 Sync Files from Remote Server? 🚧${reset}? (y/n)" yn
    case $yn in
        [Yy]* )
            printf "\n [$(TZ=America/Detroit date +'%x %X %Z')] >>>> ⏬ Syncing Files from Remote Server ... \n\n" && source sync-remote-files.sh ;
            break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no.";;
    esac
done


# Migrate Database from Remote Server ?
while true; do
    read -p "${red}🚧 Migrate Database from Remote Server? 🚧${reset}? (y/n)" yn
    case $yn in
        [Yy]* )
            printf "\n [$(TZ=America/Detroit date +'%x %X %Z')] >>>> 💾 Migrating Database from Remote Server ... \n\n" && source import-remote-db.sh;
            break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no.";;
    esac
done

# Update WP Config and Site URL?
while true; do
    read -p "${red}🚧 Update WP Config and Site URL? 🚧${reset}? (y/n)" yn
    case $yn in
        [Yy]* )
            printf "\n [$(TZ=America/Detroit date +'%x %X %Z')] >>>> 📍 Updating Remote Site URL to Local URL... \n\n" && source wp-update-url.sh;
            break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no.";;
    esac
done

# Clear out WP Engine Specific Configurations?
while true; do
    read -p "${red}🚧 Clear WP Engine Specific Configurations? 🚧${reset}? (y/n)" yn
    case $yn in
        [Yy]* )
            printf "\n [$(TZ=America/Detroit date +'%x %X %Z')] >>>> 📂 Clearing out WP Engine Specific Configurations ... \n\n" source sh clean-wpe-dependant-configs.sh;
            break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no.";;
    esac
done

# Install Kinsta Plugins ?
while true; do
    read -p "${red}🚧 Install Kinsta Plugins? 🚧${reset}? (y/n)" yn
    case $yn in
        [Yy]* )
            printf "\n [$(TZ=America/Detroit date +'%x %X %Z')] >>>> 🔌 Install Kinsta Plugins ... \n\n" && source install-kinsta-plugins.sh ;
            break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no.";;
    esac
done

# Activate Maintenance Mode?
while true; do
    read -p "${red}🚧 Activate Maintenance Mode? 🚧${reset}? (y/n)" yn
    case $yn in
        [Yy]* )
            printf "\n [$(TZ=America/Detroit date +'%x %X %Z')] >>>>  🚧 Activating Maintenance Mode... \n\n" && wp --path=${local_web_root} maintenance-mode activate && wp --path=${local_web_root} cache flush && wp --path=${local_web_root} kinsta cache purge;
            break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no.";;
    esac
done


# Dectivate Maintenance Mode?
while true; do
    read -p "${red}🚧 Dectivate Maintenance Mode? 🚧${reset}? (y/n)" yn
    case $yn in
        [Yy]* )
            printf "\n [$(TZ=America/Detroit date +'%x %X %Z')] >>>>  🚧 Dectivating Maintenance Mode... \n\n" && wp --path=${local_web_root} maintenance-mode deactivate && wp --path=${local_web_root} cache flush && wp --path=${local_web_root} kinsta cache purge;
            break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no.";;
    esac
done

# Refresh Permalinks & Clear All Caches
while true; do
    read -p "${red}🚧 Refresh Permalinks & Clear All Caches? 🚧${reset}? (y/n)" yn
    case $yn in
        [Yy]* )
            printf "\n [$(TZ=America/Detroit date +'%x %X %Z')] >>>>  🧼 Refreshing Permalinks and 🧹 Clearing WP/Kinsta Caches... \n\n" && source clear-local-cache-refresh-permalinks.sh;
            break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no.";;
    esac
done
