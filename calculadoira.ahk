; Calculadoira
; Copyright (C) 2011 Christophe Delord
; http://www.cdsoft.fr/calculadoira
;
; This file is part of Calculadoira.
;
; Calculadoira is free software: you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published
; by the Free Software Foundation, either version 3 of the License, or
; (at your option) any later version.
;
; Calculadoira is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
;
; You should have received a copy of the GNU General Public License
; along with Calculadoira.  If not, see <http://www.gnu.org/licenses/>.

#SingleInstance force

calculadoira=%A_AppData%\calculadoira
FileCreateDir, %calculadoira%
FileInstall, bl.exe, %calculadoira%\bl.exe, 0
FileInstall, calculadoira.lua, %calculadoira%\calculadoira.lua, 1
FileInstall, calculadoira.ini, %calculadoira%\calculadoira.ini, 0

Menu, Tray, NoStandard
Menu, Tray, Add, Calculadoira (Win+c), calculadoira
Menu, Tray, Add, Configuration (Win+Alt+c), conformatge
Menu, Tray, Add, Exit, kill

Return

calculadoira:
    Run %calculadoira%\bl calculadoira.lua calculadoira.ini, %calculadoira%
    Return

conformatge:
    Run %calculadoira%\calculadoira.ini
    Return

kill:
    ExitApp

#c:: Gosub calculadoira
#!c:: Gosub conformatge
