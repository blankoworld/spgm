#! /bin/sh
#
# calculPhotos.sh
#
# FRANCAIS
#
# Calcule le nombre de fichiers images miniatures _thb_ et donne le résultat 
#   dans un fichier .txt
#
# ENGLISH
#
# Give the total count of all pictures thumbnails in a text file
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

ls -R | grep -Ei "*.jpg|*.jpeg|*.bmp|*.gif|*.png" | grep -v "_thb_" | wc -l > nbrePhotos.txt
