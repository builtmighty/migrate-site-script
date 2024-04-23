#!/bin/sh
wp --path=${local_web_root} rewrite flush --allow-root --url=%;
wp --path=${local_web_root} cache flush --allow-root --url=%;
wp --path=${local_web_root} kinsta cache purge --allow-root --url=%;
