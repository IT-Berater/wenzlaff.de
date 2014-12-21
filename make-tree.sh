#!/bin/sh
#
# make-tree.sh
#
# Erstellt einen abhängigkeits Graphen.
#
# Thomas Wenzlaff 21.12.2014 Installationsanleitung unter http://www.wenzlaff.info
#
# (C) 2014 Thomas Wenzlaff http://www.wenzlaff.de
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see {http://www.gnu.org/licenses/}.
#
# Folgendes Programm muss installiert werden: sudo apt-get install debtree
# Siehe http://blog.wenzlaff.de/?p=3839
#
# Aufruf: ./make-tree Package


mkdir $1
cd $1
debtree $1 > $1.dot
dot -Tpng -o $1.png $1.dot
