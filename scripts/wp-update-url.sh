#!/bin/bash

wp --path=${local_web_root} config set DB_NAME ${import_db_name} --allow-root --url=%
wp --path=${local_web_root} config set DB_USER ${import_db_user}  --allow-root --url=%
wp --path=${local_web_root} config set DB_PASSWORD ${import_db_pass}  --allow-root --url=%
wp --path=${local_web_root} config set DB_HOST ${import_db_host} --allow-root --url=%
wp --path=${local_web_root} config set WP_HOME  https://${local_domain} --allow-root --url=%
wp --path=${local_web_root} config set WP_SITEURL  https://${local_domain} --allow-root --url=%

# Use the wp-search-replace-exclude.txt file to exclude certain tables from the search and replace
exclude_wp_tables=$(cat $wp_search_replace_exclude_file_path | tr '\n' ',' | sed 's/,$//')
echo "🙈 Excluding tables:"
cat $wp_search_replace_exclude_file_path;


# Check if the site is a Multi-site install or not, then run search and replace of the old domain to new
if $(wp --path=${local_web_root} --url=${remote_domain} core is-installed --network --allow-root); then
    echo "Multisite Install FOUND for ${remote_domain}, replacing site URL..";
    wp search-replace --path=${local_web_root} --url=${remote_domain} ${remote_domain} ${local_domain} --recurse-objects --network --skip-columns=guid --skip-tables="${exclude_wp_tables}" --all-tables --allow-root
    if [ $(wp --path=${local_web_root} config get 'DOMAIN_CURRENT_SITE' --allow-root) = ${remote_domain} ]
    then
        echo "DOMAIN_CURRENT_SITE matches set remote_domain to replace. Updating DOMAIN_CURRENT_SITE in wp-config.php ..";
        wp --path=${local_web_root} config set DOMAIN_CURRENT_SITE ${local_domain} --allow-root
    fi
else
    echo "Multisite Install NOT found for ${remote_domain}, replacing site URL for Single Site WP Install..";
    wp search-replace --path=${local_web_root} ${remote_domain} ${local_domain} --recurse-objects --skip-columns=guid --skip-tables="${exclude_wp_tables}" --all-tables --allow-root --url=%
fi

# wp --path=${local_web_root} search-replace ${remote_domain} ${local_domain} --skip-columns=guid --allow-root;
