TARGET = ru.portnov.qcheckers

CONFIG += \
    auroraapp

PKGCONFIG += \

HEADERS	= src/pdn.h \
	    src/checkers.h src/echeckers.h src/rcheckers.h \
	    src/capture.h \
	    src/common.h \
	    src/backend.h \
	    src/player.h src/humanplayer.h src/computerplayer.h

SOURCES	= src/pdn.cc \
	    src/checkers.cc src/echeckers.cc src/rcheckers.cc \
	    src/capture.cc \
	    src/main.cc \
	    src/backend.cc \
	    src/humanplayer.cc src/computerplayer.cc

RESOURCES = qcheckers.qrc icons.qrc qml/qml.qrc

DISTFILES += \
    rpm/ru.portnov.qcheckers.spec \

AURORAAPP_ICONS = 86x86 108x108 128x128 172x172
