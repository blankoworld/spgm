#!/bin/bash -
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
VERSION=0.1

# desactive le mode verbeux
verbeux=0
# desactive le mode de suppression
suppression=0
# liste de fichiers à supprimer
# index.dat provient de phpwebgallery
liste_suppr="index.dat votreFichierIndesirable yourUnwantedFile"

# repertoire source
REP_SOURCE=

IDX_EXT=".txt" # index extension
GAL_FILE="gal-desc" # nom du fichier de description de la galerie
PIC_FILE="pic-desc" # idem pour l'ensemble des images
GAL_IDX="${GAL_FILE}${IDX_EXT}" # index de la galerie
PIC_IDX="${PIC_FILE}${IDX_EXT}" # index des images d'un dossier

IMG_EXT="*.jpg|*.jpeg|*.bmp|*.png|*.gif" # extensions prises en compte

## Fonctions basiques

erreur()
{
  echo "$@" 1>&2
  utilisation_puis_sortie 1
}

utilisation()
{
  echo "Utilisation: $PROGRAMME [OPTIONS] [DOSSIER_CIBLE]"
  echo -e "Permet de générer dans le répertoire tout les fichiers nécessaires\n\
 pour l'utilisation de SPGM (Simple Picture Gallery Manager)."
  echo -e "Ceci comprend les fichiers gal-desc.txt, les fichiers pic-desc.txt\n\
 ainsi que toutes les miniatures des images."
  echo -e "$PROGRAMME permet aussi de supprimer si besoin les lignes inutiles\n\
 du fichier pic-desc.txt."
  echo ""
  echo "Options possibles :"
  echo -e "  -h, --h, -help, --help, -?, --?  Afficher l'aide mémoire"
  echo -e "  --version                        Afficher le nom et la \n\
 version du logiciel"
  echo -e "  -v                               Mode verbeux actif"
  echo -e "  -s                               Mode suppression de fichiers \n\
 indésirables actif. La liste se trouve dans la variable 'liste_suppr' du \n\
 script $PROGRAMME."
}

utilisation_puis_sortie()
{
  utilisation
  exit $1
}

version()
{
  echo "$PROGRAMME version $VERSION"
}

affichage_mode_verbeux()
{
  if test $verbeux -ne 0
  then
    echo -e "$1"
  fi
}

## Fonctions utiles

suppression_fichiers_indesirables()
{
  # Suppression des fichiers selon une liste definie
  if test $suppression -ne 0
  then
    affichage_mode_verbeux "\tSuppression des fichiers indésirables"
    for mot in $liste_suppr
    do
      # si le fichier existe
      if test -f $1/$mot
      then # alors on le supprime
        rm -f $1/$mot
      fi
    done
  fi
}

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
  affichage_mode_verbeux "\tConversion des images"
  # On se concentre sur les fichiers images dont les formats sont listes 
  #+ ci-dessous mais PAS les miniatures
  for img in `ls $1 | grep -Ei "$IMG_EXT" | grep -v _thb_`
  do
    # Si l'element est un fichier (et qu'il existe) ET que son miniature 
    #+ n'existe pas
    if test -f $1/$img && ! test -a $1/_thb_$img
    then # alors conversion
      convert -resize 120 $1/$img $1/_thb_$img
    fi
  done
}

creation_desc_gal()
{
  affichage_mode_verbeux "\tCreation descriptif galerie"
  # Si gal-desc.txt n'existe pas
  if ! test -a $1/${GAL_IDX}
  then # alors creation du fichier gal-desc.txt
    touch $1/${GAL_IDX}
    echo "Aucune description" > $1/${GAL_IDX}
  fi
}

creation_pic_gal()
{
  affichage_mode_verbeux "\tCreation descriptif images"
  # Si pic-desc.txt n'existe pas
  if ! test -a $1/${PIC_IDX}
  then # alors creation et completement du fichier pic-desc.txt
    affichage_mode_verbeux "\t\tCreation du fichier de description"
    touch $1/${PIC_IDX}
    affichage_mode_verbeux "\t\tAjout de commentaires placebo"
    echo -e "; Do not remove this comment (used for UTF-8 compliance)\n" > $1/${PIC_IDX}
    # Parcours des fichiers images selon les formats listes ci-dessous mais 
    #+ SEULEMENT les miniatures cette fois-ci
    for img in `ls $1 | grep -Ei "$IMG_EXT" | grep "_thb_"`
    do
      echo "$img | Aucun commentaire" >> $1/${PIC_IDX}
    done
  else # s'il existe
    affichage_mode_verbeux "\t\tVerification du fichier de description"
    # Comme avant : parcours des miniatures du dossier
    for img in `ls $1 | grep -Ei "$IMG_EXT" | grep "_thb_"`
    do
      # Si la valeur resultante de la recherche sur le fichier image est nulle
      if  [ -z "$(grep $img $1/pic-desc.txt)" ]
      then # alors ajout dans l'index pic-desc.txt
        echo "$img | Aucun commentaire" >> $1/${PIC_IDX}
      fi
    done
  fi
}

suppression_desc_gal()
{
  if test -f $1/${GAL_IDX}
  then
    affichage_mode_verbeux "\t\tSuppression de la description inutile de la galerie"
    rm -f $1/${GAL_IDX}
    return 2
  fi

  return 1
}

suppression_pic_gal()
{
  if test -f $1/${PIC_IDX}
  then
    affichage_mode_verbeux "\t\tSuppression de l'index inutile des images de la galerie"
    rm -f $1/${PIC_IDX}
    return 2
  fi

  return 1
}

suppression_index()
{
  affichage_mode_verbeux "\tSuppression des index inutiles"
  suppression_desc_gal "$1"
  suppression_pic_gal "$1"
}

optimisation_index()
{
  affichage_mode_verbeux "\tOptimisation de l'index"
  # Si pic-desc.txt existe
  if test -f $1/${PIC_IDX}
  then
    # Parcours du fichier index (pic-desc.txt)
    cat $1/${PIC_IDX} | while read ligne ; do
      # On extrait le nom de l'image des lignes donnees par pic-desc.txt
      miniature=`echo $ligne | grep -Ei "${IMG_EXT}" | cut -d "|" -f 1`
      case $miniature in
      "")
        affichage_mode_verbeux "\t\tLigne vide: aucune modification"
      ;;
      *)
      # Si le fichier miniature n'existe pas (ceci implique donc que la 
      #+ generation precedente n'a soi pas fonctionne soit que le fichier 
      #+ n'existe effectivement pas et a ete supprime entre temps
      if ! test -f $1/$miniature
      then # alors on supprime la ligne dans le fichier d'index des images
        # nom reel du fichier
        fichier=`echo $miniature|cut -d "_" -f 3`
        affichage_mode_verbeux "\t\tSuppression de la ligne pour le fichier: $fichier"
        # suppression de la ligne contenant le nom de fichier et enregistrement
        sed -i "'/$fichier/d'" $1/${PIC_IDX}
      fi
      ;;
      esac
    done
  fi
## Fonctions utiles
  # retourne le nom du fichier sans _thb_
  #        nom_fichier=`echo $miniature|cut -d "_" -f 3`

  # retourne le numéro de ligne pour le mot recherché
  #        num_ligne=`grep -r -n "$nom_fichier" $1/${PIC_IDX} | cut -d ":" -f 1`
}

## DEBUT / BEGIN

# Verification des parametres donnes
while test $# -gt 0
do
  case $1 in
    -v )
    verbeux=1
    ;;
    -s )
    suppression=1
    ;;
    -sv | -vs )
    verbeux=1
    suppression=1
    ;;
    --help | --h | '--?' | -help | -h | '-?' )
    utilisation_puis_sortie 0
    ;;
    --version)
    version
    exit 0
    ;;
    -*)
    erreur "Option non reconnue : $1"
    ;;
    *)
    break
    ;;
  esac
  shift
done

# Enregistrement de la variable pour le dossier source
REP_SOURCE=$1

# Tests avant de continuer
if test -z "$REP_SOURCE"
then
  erreur Vous devez indiquer une valeur pour le repertoire a parcourir
elif ! test -d "$REP_SOURCE"
then
  erreur Le parametre indique n\'est pas un dossier
elif ! [[ $(ls $1 | grep -Ei "$IMG_EXT"|wc -l) -gt 0 ]]
then
  erreur Aucun fichier image pris en charge par $PROGRAMME ne se trouve dans \
  votre dossier
fi

## Parcours recursifs dans chacun des dossiers
find ${REP_SOURCE} -type d | while read A ; do

  # Affichage dossier dans lequel nous nous trouvons
  echo $A

  suppression_fichiers_indesirables "${A}"

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

    ## Optimisation du fichier pic-desc.txt
    optimisation_index "${A}"
    ;;
  "42")
    echo -e "\tLe dossier ne contient aucune image prise en charge"
    suppression_index "${A}"
    ;;
  esac

  ## FIN / END
done

# Limite le code de retour aux valeurs classiques d'Unix (vu dans Script Shell 
#+ chez O'Reilly)
test $CODEEXIT -gt 125 && CODEEXIT=125

exit $CODEEXIT

