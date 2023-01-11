#!/bin/bash

wp --path=${local_web_root} config set DB_NAME ${import_db_name} --allow-root
wp --path=${local_web_root} config set DB_USER ${import_db_user}  --allow-root
wp --path=${local_web_root} config set DB_PASSWORD ${import_db_pass}  --allow-root
wp --path=${local_web_root} config set DB_HOST ${import_db_host} --allow-root

wp --path=${local_web_root} search-replace ${remote_domain} ${local_domain} wp_options;
