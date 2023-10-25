#!/usr/bin/env bash
# Purpose: Cleans up WPEngine variables, constants and mu-plugins
# Author: Mike from WP Bullet
# defines the path to wp-config.php
WPCONFIGPATH=${local_web_root}wp-config.php

# back up the wp-config.php just in case
cp ${WPCONFIGPATH} ${WPCONFIGPATH}.wpengine
# replace 127.0.0.1 to avoid ERROR 1130 (HY000): Host '127.0.0.1' is not allowed to connect to this MariaDB server
# sed -i "s#127.0.0.1#localhost#g" ${WPCONFIGPATH}

# remove the DB_HOST_SLAVE entry
sed -i "/define( 'DB_HOST_SLAVE'/d" ${WPCONFIGPATH}

# remove any hardcoded WP_SITEURL and WP_HOME
sed -i '/WP_SITEURL/d' ${WPCONFIGPATH}
sed -i '/WP_HOME/d' ${WPCONFIGPATH}

# clean up WPE variables from wp-config.php
sed -i '/WP_SITEURL/d' ${WPCONFIGPATH}
sed -i '/WP_HOME/d' ${WPCONFIGPATH}
sed -i '/wpe/d' ${WPCONFIGPATH}
sed -i '/WPE/d' ${WPCONFIGPATH}
sed -i '/PWP/d' ${WPCONFIGPATH}
sed -i '/memcached_servers/d' ${WPCONFIGPATH}
sed -i '/WP Engine/d' ${WPCONFIGPATH}
sed -i "/define( 'WP_CACHE'/d" ${WPCONFIGPATH}
sed -i "/define( 'DISABLE_WP_CRON'/d" ${WPCONFIGPATH}
sed -i "/define( 'FORCE_SSL_LOGIN'/d" ${WPCONFIGPATH}
sed -i "/define( 'WP_TURN_OFF_ADMIN_BAR'/d" ${WPCONFIGPATH}
sed -i "/define( 'WP_AUTO_UPDATE_CORE'/d" ${WPCONFIGPATH}
sed -i "/define( 'DISALLOW_FILE_MODS'/d" ${WPCONFIGPATH}
sed -i "/define( 'DISALLOW_FILE_EDIT'/d" ${WPCONFIGPATH}
sed -i "/define( 'WP_POST_REVISIONS'/d" ${WPCONFIGPATH}
sed -i "/umask(0002)/d" ${WPCONFIGPATH}

# remove the empty blank lines https://stackoverflow.com/questions/4521162/can-i-use-the-sed-command-to-replace-multiple-empty-line-with-one-empty-line
sed -i '/^$/N;/^\n$/D' ${WPCONFIGPATH}

# remove the mu-plugins
chmod -R 777 ${local_web_root}wp-content/mu-plugins/force-strong-passwords
chmod -R 777 ${local_web_root}wp-content/mu-plugins/slt-force-strong-passwords.php
chmod -R 777 ${local_web_root}wp-content/mu-plugins/stop-long-comments.php
chmod -R 777 ${local_web_root}wp-content/mu-plugins/mu-plugin.php
chmod -R 777 ${local_web_root}wp-content/mu-plugins/wpengine-common
chmod -R 777 ${local_web_root}wp-content/object-cache.php

rm -rf ${local_web_root}wp-content/mu-plugins/force-strong-passwords
rm -rf ${local_web_root}wp-content/mu-plugins/slt-force-strong-passwords.php
rm -rf ${local_web_root}wp-content/mu-plugins/stop-long-comments.php
rm -rf ${local_web_root}wp-content/mu-plugins/mu-plugin.php
rm -rf ${local_web_root}wp-content/mu-plugins/wpengine-common
rm -rf ${local_web_root}wp-content/object-cache.php

chmod -R 777 ${local_web_root}wp-content/mu-plugins/wpe-cache-plugin
chmod -R 777 ${local_web_root}wp-content/mu-plugins/wpe-cache-plugin.php
chmod -R 777 ${local_web_root}wp-content/mu-plugins/wpe-elasticpress-autosuggest-logger
chmod -R 777 ${local_web_root}wp-content/mu-plugins/wpe-elasticpress-autosuggest-logger.php
chmod -R 777 ${local_web_root}wp-content/mu-plugins/wpe-wp-sign-on-plugin
chmod -R 777 ${local_web_root}wp-content/mu-plugins/wpe-wp-sign-on-plugin.php
chmod -R 777 ${local_web_root}wp-content/mu-plugins/wpengine-security-auditor.php

rm -rf ${local_web_root}wp-content/mu-plugins/wpe-cache-plugin
rm -rf ${local_web_root}wp-content/mu-plugins/wpe-cache-plugin.php
rm -rf ${local_web_root}wp-content/mu-plugins/wpe-elasticpress-autosuggest-logger
rm -rf ${local_web_root}wp-content/mu-plugins/wpe-elasticpress-autosuggest-logger.php
rm -rf ${local_web_root}wp-content/mu-plugins/wpe-wp-sign-on-plugin
rm -rf ${local_web_root}wp-content/mu-plugins/wpe-wp-sign-on-plugin.php
rm -rf ${local_web_root}wp-content/mu-plugins/wpengine-security-auditor.php
