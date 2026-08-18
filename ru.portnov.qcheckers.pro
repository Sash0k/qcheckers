TARGET = ru.portnov.qcheckers
DEFINES += AURORA_OS_VERSION=5

CONFIG += \
    auroraapp

PKGCONFIG += \

HEADERS	= src/pdn.h \
	    src/checkers.h src/echeckers.h src/rcheckers.h \
	    src/capture.h \
	    src/common.h \
	    src/backend.h \
	    src/player.h src/humanplayer.h src/computerplayer.h \
	    src/settings.h

SOURCES	= src/pdn.cc \
	    src/checkers.cc src/echeckers.cc src/rcheckers.cc \
	    src/capture.cc \
	    src/main.cc \
	    src/backend.cc \
	    src/humanplayer.cc src/computerplayer.cc \
	    src/settings.cpp

RESOURCES = qcheckers.qrc icons.qrc themes.qrc

DISTFILES += \
    rpm/ru.portnov.qcheckers.spec \

AURORAAPP_ICONS = 86x86 108x108 128x128 172x172

CONFIG += \
    auroraapp_i18n_idbased \
    auroraapp_i18n \

TRANSLATIONS += \
    translations/ru.portnov.qcheckers.ts \
    translations/ru.portnov.qcheckers-ru.ts \
