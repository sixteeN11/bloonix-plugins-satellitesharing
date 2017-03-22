# Satellitesharing's bloonix-plugins

Additional plugins for the Bloonix monitoring system


## Plugin ID Range

Note that we are claiming the plugin ID range 3.000.000 to 3.010.000

## Generating bloonix plugin debian packages

Bloonix plugins are made up of two files, a `plugin-<name>` and a
`check-<name>` file. These files are located in the plugins and checks 
directories of this repository. To generate the debian package for a 
plugin named `<name>` (ie `plugins/plugin-<name>` and `checks/check-<name>` 
files exist in this repo) you would run:

The following environment variables must be specified before running
gen-debs.sh

DEB_SIGN_KEYID  This is the GPG key id to be used to sign the packages
DEBFULLNAME     This is the maintainer's full name
DEBEMAIL        This is the maintainer's email address

#### Generate deb for a single package named asn.

`DEB_SIGN_KEYID=8530BEEF DEBFULLNAME="Ebow Halm" DEBEMAIL=ejh@cpan.org ./gen-debs.sh asn`

#### Generate debs for a list of packages.

`DEB_SIGN_KEYID=8530BEEF DEBFULLNAME="Ebow Halm" DEBEMAIL=ejh@cpan.org ./gen-debs.sh asn docker du`

#### Generate debs for all packages in this repository.

Passing no arguments let's it search for all plugins in the repository
and generate a debian package for each.

`DEB_SIGN_KEYID=8530BEEF DEBFULLNAME="Ebow Halm" DEBEMAIL=ejh@cpan.org ./gen-debs.sh`
