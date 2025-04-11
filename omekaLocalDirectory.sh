#!/bin/bash
set -e

TEMP_DIR="/tmp/omeka-install"
MOUNTED_DIR="/var/www/html"

# On install omeka si le répertoire est vide
if [ "$(find "$MOUNTED_DIR" -mindepth 1 | wc -l)" -eq 0 ]; then

  mkdir -p "$TEMP_DIR"

  ##########
  # Installation OMEKA
  ##########

  # Télécharge le fichier ZIP dans le répertoire temporaire
  curl -J -L -s -k \
      'https://github.com/omeka/omeka-s/releases/download/v4.1.1/omeka-s-4.1.1.zip' \
      -o "$TEMP_DIR/omeka.zip"

  # Décompresse le fichier ZIP dans le répertoire temporaire
  unzip -q "$TEMP_DIR/omeka.zip" -d "$TEMP_DIR"

  # Copie les fichiers dans /var/www/html (volume monté)
  cp -r "$TEMP_DIR/omeka-s/." /var/www/html/

  ##########
  # Installation du module Common
  ##########

  curl -J -L -s -k \
      'https://gitlab.com/Daniel-KM/Omeka-S-module-Common/-/archive/3.4.54/Omeka-S-module-Common-3.4.54.zip' \
      -o "$TEMP_DIR/common.zip"

  unzip -q "$TEMP_DIR/common.zip" -d "$TEMP_DIR"

  # Copie les fichiers dans /var/www/html (volume monté)
  cp -r "$TEMP_DIR/Omeka-S-module-Common-3.4.54/." /var/www/html/modules/Common


  ##########
  # Installation du module EasyAdmin
  ##########

  curl -J -L -s -k \
      'https://github.com/Daniel-KM/Omeka-S-module-EasyAdmin/releases/download/3.4.16/EasyAdmin-3.4.16.zip' \
      -o "$TEMP_DIR/easyadmin.zip"

  unzip -q "$TEMP_DIR/easyadmin.zip" -d "$TEMP_DIR"

  # Copie les fichiers dans /var/www/html (volume monté)
  cp -r "$TEMP_DIR/EasyAdmin/." /var/www/html/modules/EasyAdmin

  # Droits
  chown -R www-data:www-data /var/www/html/modules

  ##########
  # Copie des fichiers de paramétrages
  ##########

  rm /var/www/html/config/database.ini
  cp "$TEMP_DIR/database.ini" /var/www/html/config/

  rm /var/www/html/.htaccess
  cp "$TEMP_DIR/.htaccess" /var/www/html/


  ##########
  # Droits
  ##########

  chown -R www-data:www-data /var/www/html
  chown -R www-data:www-data /var/www/html/
  chown -R www-data:www-data /var/www/html/modules
  chmod 600 /var/www/html/config/database.ini
  chmod 600 /var/www/html/.htaccess


  ##########
  # Suppression du répertoire d'installation
  ##########

  # Nettoie le répertoire temporaire
  rm -rf "$TEMP_DIR"

fi

##########
# Lancement d'Apache
##########
exec apache2-foreground