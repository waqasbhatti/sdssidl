#  
#  Makefile for sdssidl ascii,binary reading and writing interfaces.
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

include ../make.conf

CC =	g++
LD =	g++

INCLUDE	= -I${IDL_DIR}/external/include
CCFLAGS = ${INCLUDE} ${OS_CFLAGS} -O -Wno-deprecated 
LDFLAGS = ${OS_LDFLAGS}
CP =	cp -f
RM =	rm -f


SOFILES =	testidlstruct.so
DLMS 	=	testidlstruct.dlm

#all: ${SOFILES}
#	${CP} ${SOFILES} ${DLMS} ../DLM
all: ${SOFILES}

testidlstruct.so: testidlstruct.o IDLStruct.o
	@ echo linking $@
	${LD} ${LDFLAGS} -o $@ testidlstruct.o IDLStruct.o

clean:
	- ${RM} *.o *.so
	- cd ../DLM; ${RM} ${SOFILES} ${DLMS}

.SUFFIXES:
.SUFFIXES: .o .cpp

.cpp.o:
	@ echo compiling $<
	${CC} -c ${CCFLAGS} $<


IDLStruct.o: IDLStruct.cpp IDLStruct.hpp
testidlstruct.o: testidlstruct.cpp IDLStruct.cpp IDLStruct.hpp
