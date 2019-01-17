#!/bin/bash

die () {
	echo "ERROR: $*"
	exit 1
}

if [ ! -d /foswiki_persist/foswiki ]; then
	echo "Initializing /foswiki_persist/foswiki"
	cp -R /foswiki_init/foswiki /foswiki_persist || die "initialization copy failed"
fi

cd /var/www/foswiki/bin

./foswiki.fcgi -l 127.0.0.1:9000 -n 5 -d

nginx -g "daemon off;"
