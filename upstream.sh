#!/bin/bash

#------------------------------------------------------------------------------
#
# Plugin names cannot have spaces in them so no need to handle arguments that
# are strings with spaces.
#
#------------------------------------------------------------------------------

START_DIR=$(pwd)
for arg in "$@"
do
    echo $START_DIR
    cd $START_DIR

    check="./checks/check-$arg";
    plugin="./plugins/plugin-$arg";

    if [[ -f "$check" && -f "$plugin" ]]
    then
        echo "Processing: $arg";

        version=$(grep -i version $check | perl -pe 'if (/((?:\d+\.?)+)/) { $v=$1; s/.*/$v/}')
        description=$(grep -i description $plugin | head -1 | sed -e 's/^ *description *//')

        echo "   Version: $version";
        package="bloonix-plugin-$arg";

        stage="/tmp/$package/$package-$version";
        rm -fr "$stage";
        mkdir -p "$stage";

        cp "$check" "$stage/";
        cp "$plugin" "$stage/";

        # echo -e and use \t for tab
        cat >"$stage/Makefile" <<EOF
IMPORT_DIR=/usr/lib/bloonix/etc/plugins/import
PLUGIN_DIR=/usr/lib/bloonix/plugins
install:
	install -d \$(DESTDIR)\$(IMPORT_DIR) \$(DESTDIR)\$(PLUGIN_DIR)
	bloonix-create-plugin plugin-$arg > \$(DESTDIR)\$(IMPORT_DIR)/plugin-$arg
	install ./check-$arg \$(DESTDIR)\$(PLUGIN_DIR)
	chmod 755 \$(DESTDIR)\$(PLUGIN_DIR)/check-$arg
EOF

        cd "/tmp/$package"
        tar czf "$package-$version.tar.gz" "$package-$version"
        cd -

        DEBDIR=./debs
        mkdir -p $DEBDIR
        rm -f "$DEBDIR/$package-$version.tar.gz"
        rm -f "$DEBDIR/${package}_$version.orig.tar.gz"
        rm -fr "$DEBDIR/$package-$version"

        cp "/tmp/$package/$package-$version.tar.gz" $DEBDIR

        cd "$DEBDIR"
        tar xzf "$package-$version.tar.gz"
        cd "$package-$version"
        dh_make --single --yes --copyright Apache -f "../$package-$version.tar.gz"

        # Update debian/control
        sed -i -e 's/^Architecture: .*/Architecture: all/' ./debian/control
        sed -i -e 's/^Build-Depends: /Build-Depends: bloonix-plugin-config, /' ./debian/control
        sed -i -e 's|^Homepage: .*|Homepage: https://satellitesharing.org|' ./debian/control
        sed -i -e 's|^#Vcs-Git: .*|Vcs-Git: git://git@github.com:satellitesharing/bloonix-plugins-satellitesharing.git|' ./debian/control 
        sed -i -e 's|^#Vcs-Browser: .*|Vcs-Browser: https://github.com/satellitesharing/bloonix-plugins-satellitesharing|' ./debian/control
        sed -i -e 's|^Depends: |Depends: bloonix-plugin-config, perl, |' ./debian/control
        sed -i -e "s|^Description: .*|Description: $description|" ./debian/control

        # Update the webgui database with the plugin's details on installation.
        sed -i -e "s|\sconfigure)| configure)\n\tbloonix-load-plugins --plugin /usr/lib/bloonix/etc/plugins/import/plugin-$arg|" ./debian/postinst.ex
        mv ./debian/postinst.ex ./debian/postinst

        # - Update the debian/copyright.
        # - Create the cron file if the plugin has a cron job.

        # - Create the deb.
        dpkg-buildpackage

    else
        echo "  Ignoring: $arg";
    fi
done
