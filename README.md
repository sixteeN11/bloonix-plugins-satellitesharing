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

`./gen-debs.sh <name>`

### Example: generate .debs for all the packages in the repository.

`./gen-debs.sh  asn aws-instance docker du php-fpm saltmaster-minions shorewall ssllabs uwsgi varnish4`

