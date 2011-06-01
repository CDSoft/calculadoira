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

BL_URL  = http://www.cdsoft.fr/bl/bonaluna-1.1.3.tgz
BL      = bl.exe
PEGAR   = pegar.lua
RESHACK = http://delphi.icm.edu.pl/ftp/tools/ResHack.zip

all: calculadoira.exe

clean:
	rm -rf calculadoira.exe bl.exe
	rm -rf tmp

reshack:
	wget -c $(RESHACK)
	mkdir $@
	cd $@ && unzip ../$(notdir $(RESHACK))
	chmod +x reshack/ResHacker.exe

$(notdir $(BL_URL)):
	wget -c $(BL_URL)
	
$(BL): reshack calculadoira.ico $(notdir $(BL_URL))
	tar xzf $(notdir $(BL_URL))
	mv bonaluna-*/$@ $@
	rm -rf bonaluna-*/
	reshack/ResHacker.exe -addoverwrite $(BL), $(BL), calculadoira.ico, ICONGROUP,APPICON,0
	upx --best $@
	touch $@

$(PEGAR): $(notdir $(BL_URL))
	tar xzf $(notdir $(BL_URL))
	mv bonaluna-*/tools/$@ $@
	rm -rf bonaluna-*/
	touch $@

calculadoira.exe: calculadoira.lua calculadoira.ini $(BL) $(PEGAR) license.lua
	$(BL) $(PEGAR) read:$(BL) \
        compile:min compress:min \
        lua:license.lua \
        file::/calculadoira.ini=calculadoira.ini \
        lua:calculadoira.lua \
        write:$@
