#!/bin/sh
# Update the Application General Settings in the .env file
sed -i "/APP_URL/c\APP_URL=https://${local_domain}" $DOCUMENT_ROOT/.env
sed -i "/APP_ENV/c\APP_ENV=development" $DOCUMENT_ROOT/.env
sed -i "/APP_DEBUG/c\APP_DEBUG=true" $DOCUMENT_ROOT/.env

# Update the Application Database Settings in the .env file
sed -i "/DB_HOST/c\DB_HOST=${import_db_host}" $DOCUMENT_ROOT/.env
sed -i "/DB_DATABASE/c\DB_DATABASE=${import_db_name}" $DOCUMENT_ROOT/.env
sed -i "/DB_USERNAME/c\DB_USERNAME=${import_db_user}" $DOCUMENT_ROOT/.env
sed -i "/DB_PASSWORD/c\DB_PASSWORD=${import_db_pass}" $DOCUMENT_ROOT/.env
sed -i "/DB_PORT/c\DB_PORT=3306" $DOCUMENT_ROOT/.env
