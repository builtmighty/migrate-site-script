#!/bin/sh
wp --path=${local_web_root} rewrite flush;
wp --path=${local_web_root} cache flush;
wp --path=${local_web_root} kinsta cache purge;
