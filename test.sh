#!/bin/bash

#Initialisation des variables
CODEEXIT=0
PROGRAMME=`basename $0`
VERSION=0.0

REP_SOURCE=$1

# Debut
find ${REP_SOURCE} -type d | while read A ; do
  # Affichage du repertoire courant
  echo ${A}

  # Mettre ici tests divers sur le parcours des dossiers, par exemple :
  # Verification que le dossier est vide
#  if [[ -z "$(ls ${A})" ]]
#  then
#    echo -e "\tDossier vide"
#  fi
  # Nombre de fichier verifiant l'operance donnee
#  operandes="*.jpg|*.jpeg|*.bmp|*.png|*.gif"
#
#  a=`ls ${A} | grep -Ei "$operandes"|wc -l`
#  echo "Valeure : $a"
done

