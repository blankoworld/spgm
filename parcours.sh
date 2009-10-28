#! /bin/sh -
#
# parcours.sh
#
# FRANCAIS
# 
# Parcours du dossier donne en parametre afin de  :
# - Convertir les images en _thb_ (miniatures) (si elles n'existent pas)
# - Creer un fichier de description de la galerie (s'il n'existe pas)
# - Creer un fichier de description des images miniatures (si non existant)
# - Dans le cas contraire, verifie que les _thb_ soient presents 
#   dans le fichier
#
# ENGLISH
#
# Scan the directory, recursively, in order to :
# - Create pictures thumbnails (if they don't exist)
# - Create gallery description file (if don't exist)
# - Create a pictures thumbnails description file (if don't exist)
# - If this one exists, add missing thumbnails in
#

## LICENCE

# Copyright 2009 by Olivier DOSSMANN (alias Blankoworld)

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.If not, see <http://www.gnu.org/licenses/>.

## DEBUT / BEGIN

## Initialisation des variables
REP_SOURCE=$1

## Parcours recursifs dans chacun des dossiers
find ${REP_SOURCE} -type d | while read A ; do

  # Affichage dossier dans lequel nous nous trouvons
  echo $A

##########
# Mettre ici les tests et les suppressions des fichiers non - desires
# Ici ce sont des fichiers index.dat resultant de phpwebgallery

# Add here some test code, for an example to remove some unwanted files
# Here I remove index.dat files inherit from phpwebgallery

#  echo -e "\tSuppression des fichiers indesirables"
#  if test -f ${A}/index.dat
#  then
#    rm -f ${A}/index.dat
#  fi

##########

  ## Conversion des images en miniatures
  echo -e "\tConversion des images"
  # On se concentre sur les fichiers images dont les formats sont listes \
  # ci-dessous mais PAS les miniatures
  for i in `ls ${A} | grep -Ei "*.jpg|*.jpeg|*.bmp|*.png|*.gif" | grep -v _thb_`
  do
    # Si l'element est un fichier (et qu'il existe) ET que son miniature \
    # n'existe pas
    if test -f ${A}/$i && ! test -a ${A}/_thb_$i
    then # alors conversion
      convert -resize 120 ${A}/$i ${A}/_thb_$i
    fi
  done

  ## Creation d'un descriptif de la galerie
  echo -e "\tCreation descriptif galerie"
  # Si gal-desc.txt n'existe pas
  if ! test -a ${A}/gal-desc.txt
  then # alors creation du fichier gal-desc.txt
    touch ${A}/gal-desc.txt
    echo "Aucune description" > ${A}/gal-desc.txt
  fi

  ## Creation d'un descriptif des images
  echo -e "\tCreation descriptif images"
  # Si pic-desc.txt n'existe pas
  if ! test -a ${A}/pic-desc.txt
  then # alors creation et completement du fichier pic-desc.txt
    echo -e "\t\tCreation du fichier de description"
    touch ${A}/pic-desc.txt
    echo -e "\t\tAjout de commentaires placebo"
    echo -e "; Do not remove this comment (used for UTF-8 compliance)\n" > ${A}/pic-desc.txt
    # Parcours des fichiers images selon les formats listes ci-dessous mais \
    # SEULEMENT les miniatures cette fois-ci
    for i in `ls ${A} | grep -Ei "*.jpg|*.jpeg|*.bmp|*.png|*.gif" | grep "_thb_"`
    do
      echo "$i | Aucun commentaire" >> ${A}/pic-desc.txt
    done
  else # s'il existe
    echo -e "\t\tVerification du fichier de description"
    # Comme avant : parcours des miniatures du dossier
    for i in `ls ${A} | grep -Ei "*.jpg|*.jpeg|*.bmp|*.png|*.gif" | grep "_thb_"`
    do
      # Si la valeur resultante de la recherche sur le fichier image est nulle
      if  [ -z "$(grep $i ${A}/pic-desc.txt)" ]
      then # alors ajout dans l'index pic-desc.txt
        echo "$i | Aucun commentaire" >> ${A}/pic-desc.txt
      fi
    done
  fi

  ## FIN / END
done
