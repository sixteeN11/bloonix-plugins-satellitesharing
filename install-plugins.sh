#!/bin/bash
#
# Install the plugins

set -e
set -x

mkdir -p /usr/lib/bloonix/etc/plugins/import/satellitesharing
cd checks

# Iterate over all contained plugins
for plugin in asn varnish4 php-fpm aws-instance docker du saltmaster-minions shorewall uwsgi ssllabs; do

    # Install server components for the plugin
    chmod 755 "check-${plugin}"
    bloonix-create-plugin "../plugins/plugin-${plugin}" > "/usr/lib/bloonix/etc/plugins/import/satellitesharing/plugin-${plugin}"
    bloonix-load-plugins -c /etc/bloonix/server/main.conf -p "/usr/lib/bloonix/etc/plugins/import/satellitesharing/plugin-${plugin}"

    # Install client components for the plugin
    cp "check-${plugin}" /usr/lib/bloonix/plugins/
    chmod 755 "/usr/lib/bloonix/plugins/check-${plugin}"

    # Fix permisions
    chown -R root:root /usr/lib/bloonix/

done

cd ..

service bloonix-server restart; service bloonix-webgui restart

