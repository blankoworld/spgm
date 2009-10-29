#!/bin/bash

# Initialisation des variables
CODEEXIT=0
PROGRAMME=`basename $0`
VERSION=0.0

REP_SOURCE=$1 # repertoire a parcourir

# nom du fichier contenant le nombre de photos de la galerie
calculPhotos="nbrePhotos.txt"

# Debut
find ${REP_SOURCE} -type d | while read A ; do
  # Affichage du repertoire courant
  echo ${A}

  # suppression des fichiers _thb_
  echo -e "\tSuppression des fichiers miniatures"
  for i in `ls ${A} | grep -Ei "*.jpg|*.jpeg|*.bmp|*.png|*.gif" | grep "_thb_"`
  do
    # si l'elemet est un fichier
    if test -f ${A}/$i
    then # alors suppression
      echo -e "\t\tSuppression de $i"
      rm -f ${A}/${i}
    fi
  done

  # suppression des fichiers gal-desc.txt et pic-desc.txt
  echo -e "\tSuppression des fichiers index"
  for i in `ls ${A} | grep -E "gal-desc.txt|pic-desc.txt"`
  do
    # si l'element est un fichier
    if test -f ${A}/$i
    then # alors suppression
      echo -e "\t\tSuppression de $i"
      rm -f ${A}/$i
    fi
  done

  # suppression de potentiels fichiers nbrePhotos.txt
  echo -e "\tSuppression du fichier $calculPhotos si existant"
  # si l'element est un fichier
  if test -f ${A}/$calculPhotos
  then
    echo -e "\t\tLe fichier existe, suppression..."
    rm -f ${A}/$calculPhotos
  fi

done

# Limite le code de retour aux valeurs classiques d'Unix (vu dans Script Shell \
#+ chez O'Reilly)
test $CODEEXIT -gt 125 && CODEEXIT=125

exit $CODEEXIT
# Fin
