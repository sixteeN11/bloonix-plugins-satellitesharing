#!/bin/bash

#------------------------------------------------------------------------------
# 
# Author     : Ebow Halm <ejh@cpan.org>
# Created    : Feb 2017
# Description: Create debian packages of bloonix plugins in this repo.
# Usage      : ./gen-debs.sh <name> # Generate package for the <name> plugin.
#              ./gen-debs.sh # No arguments generates packages for all plugins
#              ./gen-debs.sh <name1> <name2> # Generate package for listed plugins
#
#------------------------------------------------------------------------------

# Require the maintainer name and email address to be specified via 
# environment variables, and also require the GPG key id to be specified.

: "${DEB_SIGN_KEYID:?Must set DEB_SIGN_KEYID, the GPG key id to sign packages with}"
: "${DEBFULLNAME:?Must set DEBFULLNAME, the maintainer's name}"
: "${DEBEMAIL:?Must set DEBEMAIL, the maintainer's email address}"

# First GPG key id
# DEB_SIGN_KEYID=$(gpg --list-keys | grep '^pub' | head -1 | awk  '{print $2}' | awk -F '/' '{print $2}')

# If no plugins specified, do for all plugins in repo.
if [ $# -eq 0 ]; then
    files=$(ls checks/check-*)
    for file in $files; do
        set -- "$@" ${file#checks/check-}
    done
fi

START_DIR=$PWD
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
IMPORT_DIR=/usr/lib/bloonix/etc/plugins/import/satellitesharing
PLUGIN_DIR=/usr/lib/bloonix/etc/plugins
CHECK_DIR=/usr/lib/bloonix/plugins
install:
	install -d \$(DESTDIR)\$(IMPORT_DIR) \$(DESTDIR)\$(CHECK_DIR) \$(DESTDIR)\$(PLUGIN_DIR)
	install ./plugin-$arg \$(DESTDIR)\$(PLUGIN_DIR)
	install ./check-$arg \$(DESTDIR)\$(PLUGIN_DIR)
	install ./check-$arg \$(DESTDIR)\$(CHECK_DIR)
	chmod 755 \$(DESTDIR)\$(CHECK_DIR)/check-$arg
	chmod 644 \$(DESTDIR)\$(PLUGIN_DIR)/plugin-$arg
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
        sed -i -e 's|^Homepage: .*|Homepage: https://satellitesharing.org|' ./debian/control
        sed -i -e 's|^#Vcs-Git: .*|Vcs-Git: git://git@github.com:satellitesharing/bloonix-plugins-satellitesharing.git|' ./debian/control 
        sed -i -e 's|^#Vcs-Browser: .*|Vcs-Browser: https://github.com/satellitesharing/bloonix-plugins-satellitesharing|' ./debian/control
        sed -i -e 's|^Depends: .*|Depends: bloonix-core|' ./debian/control
        sed -i -e "s|^Description: .*|Description: $description|" ./debian/control
        sed -i -e "s|^Section: .*|Section: net|" ./debian/control
        sed -i -e "s|^Priority: .*|Priority: extra|" ./debian/control

        # Update the webgui database with the plugin's details on installation
        # when installed on a webgui system.
        sed -i -e "s|\sconfigure)| configure)\n\tif test -f /usr/bin/bloonix-create-plugin; then bloonix-create-plugin /usr/lib/bloonix/etc/plugins/plugin-$arg > /usr/lib/bloonix/etc/plugins/import/satellitesharing/plugin-$arg; fi\n\tif test -f /usr/bin/bloonix-load-plugins; then bloonix-load-plugins --plugin /usr/lib/bloonix/etc/plugins/import/satellitesharing/plugin-$arg; fi\n\trm /usr/lib/bloonix/etc/plugins/check-$arg|" ./debian/postinst.ex
        mv ./debian/postinst.ex ./debian/postinst

        # Create the debian package.
        DESTDIR=$PWD dpkg-buildpackage

        # Sign the debian package.
        dpkg-sig --sign builder "../${package}_$version-1_all.deb"

        cp "../${package}_$version-1_all.deb" ../../$DEB_DIR/
        cp "../${package}_$version-1.dsc" ../../$DEB_DIR/
        cp "../${package}_$version-1.debian.tar.xz" ../../$DEB_DIR/
        cp "../${package}_$version.orig.tar.gz" ../../$DEB_DIR/
    else
        echo "  Ignoring: $arg";
    fi
done
