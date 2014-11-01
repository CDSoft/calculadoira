# Calculadoira
# Copyright (C) 2011 - 2014 Christophe Delord
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

BL_VERSION = 3.0.3-beta
BL_URL     = http://www.cdsoft.fr/bl/bonaluna-$(BL_VERSION).tgz
BL_TGZ     = bonaluna-$(BL_VERSION).tgz
BL_SRC     = bonaluna-$(BL_VERSION)
BL         = bl.exe

all: calculadoira-demo.exe calculadoira.exe

UNAME = $(shell uname)
ifneq "$(findstring Linux,$(UNAME))" ""
WINE = wine
else
WINE =
endif

clean:
	rm -rf calculadoira*.exe $(BL_SRC)
	rm -rf tmp

$(BL_TGZ):
	wget -c $(BL_URL)

$(BL_SRC)/Makefile: $(BL_TGZ)
	tar xzf $(BL_TGZ)
	touch $@
	
$(BL_SRC)/$(BL): calculadoira.ico $(BL_SRC)/Makefile
	echo 'export LIBRARIES="QLZ BN"'            >  $(BL_SRC)/setup
	echo 'export ICON="../../calculadoira.ico"' >> $(BL_SRC)/setup
	echo 'export COMPRESS="upx --brute"'        >> $(BL_SRC)/setup
	#sed -i '/# Documentation and tests/,$$d' $(BL_SRC)/src/build.sh
	cd $(BL_SRC)/ && make $(notdir $@)

calculadoira-demo.exe: calculadoira.lua calculadoira.ini $(BL_SRC)/$(BL) trial.lua Makefile
	$(WINE) $(BL_SRC)/$(BL) $(BL_SRC)/tools/pegar.lua \
        lua:trial.lua \
        file::/calculadoira.ini=calculadoira.ini \
        lua:calculadoira.lua \
        write:$@

calculadoira.exe: calculadoira.lua calculadoira.ini $(BL_SRC)/$(BL) Makefile
	$(WINE) $(BL_SRC)/$(BL) $(BL_SRC)/tools/pegar.lua \
        lua:pro.lua \
        file::/calculadoira.ini=calculadoira.ini \
        lua:calculadoira.lua \
        write:$@

calculadoira.png: Makefile
	convert -size 64x64 xc:white \
		-fill black -stroke black -strokewidth 0 \
		-draw "rectangle 28,8 35,55" \
		-draw "rectangle 8,28 55,35" \
		$@

calculadoira.ico: calculadoira.png
	convert $< \
		-bordercolor white -border 0 \
		\( -clone 0 -resize 32x32 \) \
		-delete 0 -alpha off -colors 2 \
		$@
