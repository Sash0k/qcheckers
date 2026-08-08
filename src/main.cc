/***************************************************************************
 *   Copyright (C) 2002-2003 Andi Peredri                                  *
 *   andi@ukr.net                                                          *
 *   Copyright (C) 2004-2007 Artur Wiebe                                   *
 *   wibix@gmx.de                                                          *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.             *
 ***************************************************************************/
#include <auroraapp.h>
#include <QtQuick>

#include "backend.h"
#include "common.h"

int main(int argc, char *argv[])
{
    QScopedPointer<QGuiApplication> application(Aurora::Application::application(argc, argv));
    application->setOrganizationName(QStringLiteral("ru.portnov"));
    application->setApplicationName(QStringLiteral("qcheckers"));

	QQmlApplicationEngine engine;
	GameController* controller = new GameController(&engine);

    QScopedPointer<QQuickView> view(Aurora::Application::createView());
    view->rootContext()->setContextProperty("game", controller);
    view->rootContext()->setContextProperty("AURORA_OS_VERSION", AURORA_OS_VERSION);
    view->setSource(Aurora::Application::pathTo(QStringLiteral("qml/qcheckers.qml")));
    view->show();

    return application->exec();
}
