FROM alpine:3.7

ENV PERL_MM_USE_DEFAULT 1

ENV FOSWIKI_LATEST_URL https://github.com/foswiki/distro/releases/download/FoswikiRelease02x01x06/Foswiki-2.1.6.zip

ENV FOSWIKI_LATEST Foswiki-2.1.6

RUN apk add --update && \
    apk add nginx wget unzip make zip perl perl-cgi perl-fcgi perl-cgi-session perl-error perl-json perl-file-copy-recursive ca-certificates && \
    apk add perl-uri perl-digest-perl-md5 perl-lwp-protocol-https perl-html-tree perl-email-mime perl-algorithm-diff && \
    apk add perl-cache-cache  perl-file-which perl-module-pluggable perl-moo perl-json perl-dbi perl-dbd-sqlite && \
    apk add perl-archive-zip perl-time-modules mailcap imagemagick6 perl-authen-sasl perl-db_file perl-net-ldap && \
    apk add perl-io-socket-inet6 && \
    apk add perl-json-xs --update-cache --repository http://dl-3.alpinelinux.org/alpine/edge/testing/ --allow-untrusted && \
    apk add gcc perl-dev musl-dev db-dev imagemagick6-dev krb5-dev && \
    perl -MCPAN -e 'install Crypt::PasswdMD5, BerkeleyDB, Spreadsheet::XLSX ,XML::Easy, Time::ParseDate, Types::Standard, Algorithm::Diff::XS, GSSAPI, AuthCAS' && \
    perl -MCPAN -e "CPAN::Shell->notest('install', 'DB_File::Lock')" && \
    wget http://www.imagemagick.org/download/perl/PerlMagick-6.89.tar.gz && \
    tar xvfz PerlMagick-6.89.tar.gz && \
    cd PerlMagick-6.89 && \
    perl Makefile.PL && \
    make install && \
    cd / && \
    rm -f PerlMagick-6.89.tar.gz && \
    rm -fr PerlMagick-6.89 && \
    apk del gcc perl-dev musl-dev db-dev imagemagick6-dev krb5-dev && \
    cd ~/ && \
    rm -fr .cpan

RUN wget ${FOSWIKI_LATEST_URL}

RUN mkdir -p /var/www && \
    mv ${FOSWIKI_LATEST}.zip /var/www && \
    cd /var/www && \
    unzip ${FOSWIKI_LATEST}.zip -d /var/www/ && \
    rm -rf ${FOSWIKI_LATEST}.zip && \
    mv ${FOSWIKI_LATEST} foswiki && \
    cd foswiki && \
    sh tools/fix_file_permissions.sh && \
    mkdir -p /run/nginx && \
    mkdir -p /etc/nginx/conf.d

COPY nginx.default.conf /etc/nginx/conf.d/default.conf
COPY docker-entrypoint.sh docker-entrypoint.sh

RUN mkdir /foswiki_init /foswiki_persist && \
    for d in pub data templates; do mv /var/www/foswiki/$d /foswiki_init; ln -s /foswiki_persist/$d /var/www/foswiki/$d; done

EXPOSE 80

CMD ["sh", "docker-entrypoint.sh"]
