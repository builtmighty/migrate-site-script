#!/bin/sh
wp --path=${local_web_root} rewrite flush --url-%;
wp --path=${local_web_root} cache flush --url-%;
wp --path=${local_web_root} kinsta cache purge --url-%;
