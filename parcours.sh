#! /bin/bash -
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

## Initialisation des variables

CODEEXIT=0
PROGRAMME=`basename $0`
VERSION=0.0

REP_SOURCE=$1 # repertoire source

IDX_EXT=".txt" # index extension
GAL_FILE="gal-desc" # nom du fichier de description de la galerie
PIC_FILE="pic-desc" # idem pour l'ensemble des images
GAL_IDX="${GAL_FILE}${IDX_EXT}" # index de la galerie
PIC_IDX="${PIC_FILE}${IDX_EXT}" # index des images d'un dossier

IMG_EXT="*.jpg|*.jpeg|*.bmp|*.png|*.gif" # extensions prises en compte

## Fonctions utiles

contient_fichiers_images()
{
  nbre_image=`ls $1 | grep -Ei "$IMG_EXT"|wc -l`
  if [[ $nbre_image -gt 0 ]] #test -z "$(ls $1)" 
  then
    CONTENU=1 # contient des images
    return 1
  elif test -z "$(ls $1)" #! test -z $nbre_image
  then
    CONTENU=2 # ne contient rien
    return 2
  else
    CONTENU=42 # contient autre chose
    return 42
  fi
}

conversion_images()
{
  echo -e "\tConversion des images"
  # On se concentre sur les fichiers images dont les formats sont listes \
  # ci-dessous mais PAS les miniatures
  for img in `ls $1 | grep -Ei "$IMG_EXT" | grep -v _thb_`
  do
    # Si l'element est un fichier (et qu'il existe) ET que son miniature \
    # n'existe pas
    if test -f $1/$img && ! test -a $1/_thb_$img
    then # alors conversion
      convert -resize 120 $1/$img $1/_thb_$img
    fi
  done

  return 1
}

creation_desc_gal()
{
  echo -e "\tCreation descriptif galerie"
  # Si gal-desc.txt n'existe pas
  if ! test -a $1/${GAL_IDX}
  then # alors creation du fichier gal-desc.txt
    touch $1/${GAL_IDX}
    echo "Aucune description" > $1/${GAL_IDX}
  fi

  return 1
}

creation_pic_gal()
{
  echo -e "\tCreation descriptif images"
  # Si pic-desc.txt n'existe pas
  if ! test -a $1/${PIC_IDX}
  then # alors creation et completement du fichier pic-desc.txt
    echo -e "\t\tCreation du fichier de description"
    touch $1/${PIC_IDX}
    echo -e "\t\tAjout de commentaires placebo"
    echo -e "; Do not remove this comment (used for UTF-8 compliance)\n" > $1/${PIC_IDX}
    # Parcours des fichiers images selon les formats listes ci-dessous mais \
    # SEULEMENT les miniatures cette fois-ci
    for img in `ls $1 | grep -Ei "$IMG_EXT" | grep "_thb_"`
    do
      echo "$img | Aucun commentaire" >> $1/${PIC_IDX}
    done
  else # s'il existe
    echo -e "\t\tVerification du fichier de description"
    # Comme avant : parcours des miniatures du dossier
    for i in `ls $1 | grep -Ei "$IMG_EXT" | grep "_thb_"`
    do
      # Si la valeur resultante de la recherche sur le fichier image est nulle
      if  [ -z "$(grep $img $1/pic-desc.txt)" ]
      then # alors ajout dans l'index pic-desc.txt
        echo "$img | Aucun commentaire" >> $1/${PIC_IDX}
      fi
    done
  fi

  return 1
}

## DEBUT / BEGIN

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

  ## Verification contenu
  CONTENU="-" # controle
  contient_fichiers_images "${A}"
  case $CONTENU in
  "-")
    echo -e "\tLe test sur le contenu du dossier a echoue ou n'a pas ete \ 
lance"
    ;;
  "2")
    echo -e "\tLe dossier est vide"
    ;;
  "1")
    echo -e "\tLe dossier contient des images"
    ## Conversion des images en miniatures
    conversion_images "${A}"

    ## Creation d'un descriptif de la galerie
    creation_desc_gal "${A}"

    ## Creation d'un descriptif des images
    creation_pic_gal "${A}"
    ;;
  "42")
    echo -e "\tLe dossier ne contient aucune images prise en charge"
    ;;
  esac

  ## FIN / END
done

# Limite le code de retour aux valeurs classiques d'Unix (vu dans Script Shell \
# chez O'Reilly)
test $CODEEXIT -gt 125 && CODEEXIT=125

exit $CODEEXIT

