#!/bin/bash

for i in /foswiki_init/*; do
	p=/foswiki_persist/$(basename $i)
	if [ ! -d "$p" ]; then
		echo "Initializing $p"
		cp -R $i /foswiki_persist
	fi
done

cd /var/www/foswiki/bin

./foswiki.fcgi -l 127.0.0.1:9000 -n 5 -d

nginx -g "daemon off;"
