# Calculadoira
# Copyright (C) 2011 Christophe Delord
# http://www.cdsoft.fr/calculadoira
#
# This file is part of Calculadoira.
#
# Calculadoira is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published
# by the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Calculadoira is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Calculadoira.  If not, see <http://www.gnu.org/licenses/>.

AHK_URL = http://www.autohotkey.com/download/AutoHotkey.zip
BL_URL  = http://www.cdsoft.fr/bl/bonaluna-0.6.0.tgz
BL      = bl.exe
RESHACK = http://delphi.icm.edu.pl/ftp/tools/ResHack.zip

all: calculadoira.exe

clean:
	rm -rf calculadoira.exe
	rm -rf tmp

ahk:
	wget -c $(AHK_URL)
	mkdir $@
	cd $@ && unzip ../$(notdir $(AHK_URL))

reshack:
	wget -c $(RESHACK)
	mkdir $@
	cd $@ && unzip ../$(notdir $(RESHACK))

$(BL): reshack calculadoira.ico
	wget -c $(BL_URL)
	tar xzf $(notdir $(BL_URL))
	mv bonaluna-*/$@ $@
	rm -rf bonaluna-*
	wine reshack/ResHacker.exe -addoverwrite $(BL), $(BL), calculadoira.ico, ICONGROUP,APPICON,0

calculadoira.exe: calculadoira.ahk calculadoira.ico calculadoira.lua calculadoira.ini $(BL) ahk
	 wine ahk/Compiler/Ahk2Exe.exe /in calculadoira.ahk /icon calculadoira.ico

