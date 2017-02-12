#!/bin/bash
#
# Quick and dirty installer
# Will be replaced by proper .deb packaging

set -e

mkdir -vp /usr/lib/bloonix/etc/plugins/import/satellitesharing
cd plugins

# Iterate over all contained plugins
for plugin in asn varnish4 php-fpm aws-instance docker du saltmaster-minions shorewall uwsgi ssllabs; do

    echo "== Installing Plugin $plugin"
    # Install server components for the plugin
    chmod -v 755 "../checks/check-${plugin}"
    ln -vsf "../checks/check-${plugin}" .
    bloonix-create-plugin "plugin-${plugin}" > "/usr/lib/bloonix/etc/plugins/import/satellitesharing/plugin-${plugin}"
    rm -v "check-${plugin}"
    bloonix-load-plugins -c /etc/bloonix/server/main.conf -p "/usr/lib/bloonix/etc/plugins/import/satellitesharing/plugin-${plugin}"

    # Install client components for the plugin
    cp -v "../checks/check-${plugin}" /usr/lib/bloonix/plugins/
    chmod -v 755 "/usr/lib/bloonix/plugins/check-${plugin}"
    echo

done

echo "== Restarting bloonix server and webui"
cd ..
chown -R root:root /usr/lib/bloonix/
service bloonix-server restart; service bloonix-webgui restart

