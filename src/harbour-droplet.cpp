/*
  Copyright (C) 2017 Dinesh Manajipet <saidinesh5@gmail.com>
  Copyright (C) 2013 Jolla Ltd.
  Contact: Thomas Perl <thomas.perl@jollamobile.com>
  All rights reserved.

  You may use this file under the terms of BSD license as follows:

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the Jolla Ltd nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR
  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#ifdef QT_QML_DEBUG
#include <QtQuick>
#endif

#include <QGuiApplication>
#include <QScopedPointer>
#include <QtQml>
#include <QCommandLineParser>
#include <QCommandLineOption>

#include <sailfishapp.h>
#include "appletview.h"
#include "droplethelper.h"

int main(int argc, char *argv[])
{
    //Some more speed & memory improvements
    setenv("QT_NO_FAST_MOVE", "0", 0);
    setenv("QT_NO_FT_CACHE","0",0);
    setenv("QT_NO_FAST_SCROLL","0",0);
    setenv("QT_NO_ANTIALIASING","1",1);
    setenv("QT_NO_FREE","1",1);

    // Taken from sailfish-browser
    setenv("USE_ASYNC", "1", 1);

    QScopedPointer<QGuiApplication> app(SailfishApp::application(argc, argv));
    QCommandLineParser parser;
    parser.setApplicationDescription(QCoreApplication::translate("main", "A lightweight web browser for Sailfish OS"));
    parser.addHelpOption();
    parser.addPositionalArgument("url", QCoreApplication::translate("main", "Url to open"));
    parser.process(*app.data());

    const QStringList args = parser.positionalArguments();

    if(args.length() > 0){
        const QString url = args.at(0);
        DropletHelper helper;
        qDebug() << args;
        helper.openInDroplet(url);
        if(app->hasPendingEvents())
            app->processEvents();
        return 0;
    }
    else {
        //Code for command line arguments come here
        qmlRegisterType<AppletView>("net.garageresearch.droplet", 0, 1, "AppletView");
        qmlRegisterType<DropletHelper>("net.garageresearch.droplet", 0, 1, "DropletHelper");

        QScopedPointer<AppletView> view(new AppletView());
        view->setSource(SailfishApp::pathTo("qml/droplet-browser-overlay.qml"));
        view->showFullscreen();

        return app->exec();
    }
}
