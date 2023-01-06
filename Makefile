# This file is part of Calculadoira.
#
# Calculadoira is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Calculadoira is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Calculadoira.  If not, see <https://www.gnu.org/licenses/>.
#
# For further information about Calculadoira you can visit
# http://cdelord.fr/calculadoira

INSTALL_PATH = $(HOME)/.local/bin
BUILD = .build

CALCULADOIRA = $(BUILD)/calculadoira
CALCULADOIRA_INI = ~/.config/calculadoira.ini

# avoid being polluted by user definitions
export LUA_PATH := ./?.lua

## Compile, test and generate the documentation
all: compile
all: test
all: doc

clean:
	rm -rf $(BUILD)

include makex.mk

####################################################################
# Compilation
####################################################################

## Compile calculadoira
compile: $(CALCULADOIRA)

$(CALCULADOIRA): calculadoira.lua bn.lua | $(LUAX)
	@mkdir -p $(dir $@)
	$(LUAX) -o $@ $^

####################################################################
# Installation
####################################################################

.PHONY: install

## Install calculadoira
install: $(INSTALL_PATH)/$(notdir $(CALCULADOIRA)) $(CALCULADOIRA_INI)

$(INSTALL_PATH)/$(notdir $(CALCULADOIRA)): $(CALCULADOIRA)
	@mkdir -p $(dir $@)
	install $^ $@

$(CALCULADOIRA_INI): calculadoira.ini
	@mkdir -p $(dir $@)
	test -f $(CALCULADOIRA_INI) || install $< $(CALCULADOIRA_INI)

####################################################################
# Tests
####################################################################

.PHONY: test

## Run calculadoira tests
test: $(BUILD)/tests.txt

$(BUILD)/tests.txt: $(CALCULADOIRA) tests.py
	@mkdir -p $(dir $@)
	python3 tests.py $(CALCULADOIRA) > $@.tmp
	mv $@.tmp $@

####################################################################
# Documentation
####################################################################

## Generate documentation (README.md)
doc: README.md

README.md: calculadoira.md $(CALCULADOIRA) | $(PANDA)
	PATH=$(dir $(CALCULADOIRA)):$$PATH LANG=en $(PANDA_GFM) $< -o $@
