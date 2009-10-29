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

# variables texte : 
txt_fr_gal_desc="Aucune description"
txt_fr_pic_desc="Aucun commentaire"
txt_fr_suppr_indesirables="Suppression des fichiers indésirables"
txt_fr_converion="Conversion des images"
txt_fr_creation_gal_idx="Création descriptif galerie"
txt_fr_creation_pic_idx="Création descriptif images"
txt_fr_creation_desc_file="Création du fichier de description"
txt_fr_ajout_com="Ajout de commentaires placebo"
txt_fr_verif_desc="Vérification du fichier de description"
txt_fr_suppr_desc="Suppression de la description inutile de la galerie"
txt_fr_suppr_idx="Suppression de l'index inutile des images de la galerie"
txt_fr_suppr_idx_tous="Suppression des index inutiles"
txt_fr_optim_idx="Optimisation de l'index"
txt_fr_optim_ligne_vide="Ligne vide: aucune modification"
txt_fr_suppr_ligne="Suppression de la ligne pour le fichier: "
txt_fr_test_rep_echoue="Le test sur le contenu du dossier a echoué ou n'a pas \
été lancé."
txt_fr_test_rep_vide="Le dossier est vide."
txt_fr_test_rep_images="Le dossier contient des images prises en charge."
txt_fr_test_rep_autre="Le dossier ne contient AUCUNE image prise en charge."

txt_fr_formats_traites="Le script $PROGRAMME prend en charge les formats suivants : "

## Fonctions basiques

erreur()
{
  echo "$@" 1>&2
  utilisation_puis_sortie 1
}

formats_traites()
{
  # Affichage des formats pris en compte dans les traitements
  echo -e "$txt_fr_formats_traites"
  # redefinition du caractere de separation
  IFS="|"
  # pour chaque format de la liste
  for i in `echo "${IMG_EXT}"`
  do
    # affichage du format
    echo "  $i"
  done
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
  echo ""
  formats_traites
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
    affichage_mode_verbeux "\t$txt_fr_suppr_indesirables"
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
  affichage_mode_verbeux "\t$txt_fr_converion"
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
  affichage_mode_verbeux "\t$txt_fr_creation_gal_idx"
  # Si gal-desc.txt n'existe pas
  if ! test -a $1/${GAL_IDX}
  then # alors creation du fichier gal-desc.txt
    affichage_mode_verbeux "\t\t$txt_fr_creation_desc_file"
    touch $1/${GAL_IDX}
    echo "$txt_fr_gal_desc" > $1/${GAL_IDX}
  fi
}

creation_pic_gal()
{
  affichage_mode_verbeux "\t$txt_fr_creation_pic_idx"
  # Si pic-desc.txt n'existe pas
  if ! test -a $1/${PIC_IDX}
  then # alors creation et completement du fichier pic-desc.txt
    affichage_mode_verbeux "\t\t$txt_fr_creation_desc_file"
    touch $1/${PIC_IDX}
    affichage_mode_verbeux "\t\t$txt_fr_ajout_com"
    echo -e "; Do not remove this comment (used for UTF-8 compliance)\n" > $1/${PIC_IDX}
    # Parcours des fichiers images selon les formats listes ci-dessous mais 
    #+ SEULEMENT les miniatures cette fois-ci
    for img in `ls $1 | grep -Ei "$IMG_EXT" | grep "_thb_"`
    do
      echo "$img | $txt_fr_pic_desc" >> $1/${PIC_IDX}
    done
  else # s'il existe
    affichage_mode_verbeux "\t\t$txt_fr_verif_desc"
    # Comme avant : parcours des miniatures du dossier
    for img in `ls $1 | grep -Ei "$IMG_EXT" | grep "_thb_"`
    do
      # Si la valeur resultante de la recherche sur le fichier image est nulle
      if  [ -z "$(grep $img $1/pic-desc.txt)" ]
      then # alors ajout dans l'index pic-desc.txt
        echo "$img | $txt_fr_pic_desc" >> $1/${PIC_IDX}
      fi
    done
  fi
}

suppression_desc_gal()
{
  if test -f $1/${GAL_IDX}
  then
    affichage_mode_verbeux "\t\t$txt_fr_suppr_desc"
    rm -f $1/${GAL_IDX}
    return 2
  fi

  return 1
}

suppression_pic_gal()
{
  if test -f $1/${PIC_IDX}
  then
    affichage_mode_verbeux "\t\t$txt_fr_suppr_idx"
    rm -f $1/${PIC_IDX}
    return 2
  fi

  return 1
}

suppression_index()
{
  affichage_mode_verbeux "\t$txt_fr_suppr_idx_tous"
  suppression_desc_gal "$1"
  suppression_pic_gal "$1"
}

optimisation_index()
{
  affichage_mode_verbeux "\t$txt_fr_optim_idx"
  # Si pic-desc.txt existe
  if test -f $1/${PIC_IDX}
  then
    # Parcours du fichier index (pic-desc.txt)
    cat $1/${PIC_IDX} | while read ligne ; do
      # On extrait le nom de l'image des lignes donnees par pic-desc.txt
      miniature=`echo $ligne | grep -Ei "${IMG_EXT}" | cut -d "|" -f 1`
      case $miniature in
      "")
        affichage_mode_verbeux "\t\t$txt_fr_optim_ligne_vide"
      ;;
      *)
      # Si le fichier miniature n'existe pas (ceci implique donc que la 
      #+ generation precedente n'a soi pas fonctionne soit que le fichier 
      #+ n'existe effectivement pas et a ete supprime entre temps
      if ! test -f $1/$miniature
      then # alors on supprime la ligne dans le fichier d'index des images
        # nom reel du fichier
        fichier=`echo $miniature|cut -d "_" -f 3`
        affichage_mode_verbeux "\t\t$txt_fr_suppr_ligne $fichier"
        # suppression de la ligne contenant le nom de fichier et enregistrement
        sed -i "/$fichier/d" $1/${PIC_IDX}
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
  erreur Vous devez indiquer une valeur pour le répertoire à parcourir
elif ! test -d "$REP_SOURCE"
then
  erreur Le parametre indique n\'est pas un dossier
elif ! [[ $(ls -R $1 | grep -Ei "$IMG_EXT"|wc -l) -gt 0 ]]
then
  erreur Aucun fichier image pris en charge par $PROGRAMME ne se trouve dans \
  votre dossier et ses sous-répertoires
fi

## Parcours recursifs dans chacun des dossiers
find ${REP_SOURCE} -type d | while read dossier ; do

  # Affichage dossier dans lequel nous nous trouvons
  echo $dossier

  suppression_fichiers_indesirables "${dossier}"

  ## Verification contenu
  CONTENU="-" # controle
  contient_fichiers_images "${dossier}"
  case $CONTENU in
  "-")
    echo -e "\t$txt_fr_test_rep_echoue"
    ;;
  "2")
    echo -e "\t$txt_fr_test_rep_vide"
    ;;
  "1")
    echo -e "\t$txt_fr_test_rep_images"
    ## Conversion des images en miniatures
    conversion_images "${dossier}"

    ## Creation d'un descriptif de la galerie
    creation_desc_gal "${dossier}"

    ## Creation d'un descriptif des images
    creation_pic_gal "${dossier}"

    ## Optimisation du fichier pic-desc.txt
    optimisation_index "${dossier}"
    ;;
  "42")
    echo -e "\t$txt_fr_test_rep_autre"
    suppression_index "${dossier}"
    ;;
  esac

  ## FIN / END
done

# Limite le code de retour aux valeurs classiques d'Unix (vu dans Script Shell 
#+ chez O'Reilly)
test $CODEEXIT -gt 125 && CODEEXIT=125

exit $CODEEXIT

