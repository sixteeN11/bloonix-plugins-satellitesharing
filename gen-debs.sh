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
    cd $START_DIR

    check="./checks/check-$arg";
    plugin="./plugins/plugin-$arg";

    if [[ -f "$check" && -f "$plugin" ]]
    then

        version=$(grep -i version $check | perl -pe 'if (/((?:\d+\.?)+)/) { $v=$1; s/.*/$v/}')
        description=$(grep -i description $plugin | head -1 | sed -e 's/^ *description *//')
        package="bloonix-plugins-satellitesharing-$arg";
        stage="/tmp/$package/$package-$version";

        rm -fr "$stage";
        mkdir -p "$stage";

        cp "$check" "$stage/";
        cp "$plugin" "$stage/";

        # echo -e and use \t for tab
        cat >"$stage/Makefile" <<EOF
IMPORT_DIR=/usr/lib/bloonix/etc/plugins/import/satsharing
PLUGIN_DIR=/usr/lib/bloonix/etc/plugins
CHECK_DIR=/usr/lib/bloonix/plugins
install:
	install -d \$(DESTDIR)\$(IMPORT_DIR) \$(DESTDIR)\$(CHECK_DIR) \$(DESTDIR)\$(PLUGIN_DIR)
	bloonix-create-plugin plugin-$arg > \$(DESTDIR)\$(IMPORT_DIR)/plugin-$arg
	install ./plugin-$arg \$(DESTDIR)\$(PLUGIN_DIR)
	install ./check-$arg \$(DESTDIR)\$(CHECK_DIR)
	chmod 755 \$(DESTDIR)\$(CHECK_DIR)/check-$arg
EOF

        cd "/tmp/$package"
        tar czf "$package-$version.tar.gz" "$package-$version"
        cd -

        BUILD_DIR=./build
        mkdir -p $BUILD_DIR

        DEB_DIR=./debs
        mkdir -p $DEB_DIR

        rm -f "$BUILD_DIR/$package-$version.tar.gz"
        rm -f "$BUILD_DIR/${package}_$version.orig.tar.gz"
        rm -fr "$BUILD_DIR/$package-$version"

        cp "/tmp/$package/$package-$version.tar.gz" $BUILD_DIR

        cd "$BUILD_DIR"
        tar xzf "$package-$version.tar.gz"
        cd "$package-$version"
        dh_make --single --yes --copyright Apache -f "../$package-$version.tar.gz"

        # Update debian/control
        sed -i -e 's/^Architecture: .*/Architecture: all/' ./debian/control
        sed -i -e 's/^Build-Depends: /Build-Depends: bloonix-plugin-config, /' ./debian/control
        sed -i -e 's|^Homepage: .*|Homepage: https://satellitesharing.org|' ./debian/control
        sed -i -e 's|^#Vcs-Git: .*|Vcs-Git: git://git@github.com:satellitesharing/bloonix-plugins-satellitesharing.git|' ./debian/control 
        sed -i -e 's|^#Vcs-Browser: .*|Vcs-Browser: https://github.com/satellitesharing/bloonix-plugins-satellitesharing|' ./debian/control
        sed -i -e "s|^Description: .*|Description: $description|" ./debian/control

        # Update the webgui database with the plugin's details on installation
        # when installed on a webgui system.
        sed -i -e "s|\sconfigure)| configure)\n\tif [[ -f /usr/bin/bloonix-load-plugins ]]; then bloonix-load-plugins --plugin /usr/lib/bloonix/etc/plugins/import/satsharing/plugin-$arg; fi|" ./debian/postinst.ex
        mv ./debian/postinst.ex ./debian/postinst

        # - Update the debian/copyright.
        # - Create the cron file if the plugin has a cron job.

        # - Create the deb.
        DESTDIR=$PWD dpkg-buildpackage
        cp "../${package}_$version-1_all.deb" ../../$DEB_DIR/
        cp "../${package}_$version-1.dsc" ../../$DEB_DIR/
    else
        echo "  Ignoring: $arg";
    fi
done
