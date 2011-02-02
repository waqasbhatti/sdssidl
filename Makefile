#  This file is part of the sdssidl IDL routines. 
#  Makefile for sdssidl
#
#  Copyright (C) 2005  Erin Sheldon, NYU.  erin dot sheldon at gmail dot com
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program; if not, write to the Free Software
#    Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA


#
# Build all routines
#

# by default we install to the esidl_dir, but := means we can set this
# on the command line
PREFIX := $(SDSSIDL_DIR)

SRC_DIR	= src

default : all

all clean linux irix osf:
	@cd ${SRC_DIR}; echo Making ${SRC_DIR}; ${MAKE} $@

copy :
	@echo "rsyncing to $(PREFIX)"
	@if [ ! -e $(PREFIX) ]; then \
		echo Creating directory $(PREFIX); \
		mkdir -p $(PREFIX); \
	fi
	rsync -av --exclude "*svn*" --exclude "*swp" ./ $(PREFIX)/


