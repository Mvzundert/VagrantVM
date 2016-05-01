#!/usr/bin/env bash

# Install drush from the latest head
composer global require drush/drush:dev-master

# Rename to `drush` instead of `php drush.phar`. Destination can be anywhere on $PATH.
chmod +x drush.phar
sudo mv drush.phar /usr/local/bin/drush

# Optional. Enrich the bash startup file with completion and aliases.
drush init