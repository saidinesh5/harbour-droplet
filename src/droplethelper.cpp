/**
* Project: Droplet Browser
* Copyright 2017, Dinesh Manajipet <saidinesh5@gmail.com>
*
* This program is free software; you can redistribute it and/or modify
* it under the terms of the GNU Lesser General Public License as published by
* the Free Software Foundation; either version 2 of the License, or
* (at your option) any later version.
*
* This program is distributed in the hope that it will be useful, but
* WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
* or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License
* for more details.
*
* You should have received a copy of the GNU Lesser General Public License along
* with this program; if not, write to the Free Software Foundation, Inc.,
* 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
*/

#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QProcess>
#include <QStandardPaths>

#include <QtDBus/QtDBus>

#include "droplethelper.h"

//Shamelessly got most of the code in here from https://github.com/llelectronics/droplet/blob/master/src/myclass.cpp

DropletHelper::DropletHelper(QObject *parent) : QObject(parent)
{

}

bool DropletHelper::isDefaultBrowser()
{
    return commandOutput("xdg-mime query default text/html") == "open-url-droplet.desktop" &&
            commandOutput("xdg-mime query default x-maemo-urischeme/http") == "open-url-droplet.desktop" &&
            commandOutput("xdg-mime query default x-maemo-urischeme/https") == "open-url-droplet.desktop";
}

void DropletHelper::openInDroplet(QString url)
{
    QDBusConnection bus = QDBusConnection::sessionBus();
    QDBusInterface dbus_iface("net.garageresearch.droplet", "/browser",
                              "net.garageresearch.droplet", bus);
    dbus_iface.call("openUrl", url);
}

void DropletHelper::openInExternal(QString url)
{
    QDBusConnection bus = QDBusConnection::sessionBus();
    QDBusInterface dbus_iface("org.sailfishos.browser.ui", "/ui",
                              "org.sailfishos.browser.ui", bus);
    dbus_iface.asyncCall("openUrl", QStringList(url));
}

void DropletHelper::setIsDefaultBrowser(bool value)
{
    QString home = QStandardPaths::standardLocations(QStandardPaths::HomeLocation).first();

    if(value){
        QFile cpFile;
        if (!QFileInfo(home + "/.local/share/applications/open-url-droplet.desktop").isFile()) {
            cpFile.copy("/usr/share/harbour-droplet/open-url-droplet.desktop", home + "/.local/share/applications/open-url-droplet.desktop");
        }
//Installing the service file to /usr/share/dbus..
//        if (!QDir(home + "/.local/share/dbus-1/services").exists()) {
//            QDir makePath;
//            makePath.mkpath(home + "/.local/share/dbus-1/services");
//        }
//        cpFile.copy("/usr/share/harbour-droplet/net.garageresearch.droplet.service", home+ "/.local/share/dbus-1/services/net.garageresearch.droplet.service");
        setMime("text/html", "open-url-droplet.desktop");
        setMime("x-maemo-urischeme/http", "open-url-droplet.desktop");
        setMime("x-maemo-urischeme/https", "open-url-droplet.desktop");
    }
    else
    {
        setMime("text/html", "open-url.desktop");
        setMime("x-maemo-urischeme/http", "open-url.desktop");
        setMime("x-maemo-urischeme/https", "open-url.desktop");
    }

    emit isDefaultBrowserChanged(value);
}

void DropletHelper::setMime(const QString &mimeType, const QString &desktopFile)
{
    QString home = QStandardPaths::standardLocations(QStandardPaths::HomeLocation).first();

    // Workaround for SailfishOS which only works if defaults.list is available. Xdg-mime only produces mimeapps.list however
    if (!QFileInfo(home + "/.local/share/applications/defaults.list").isFile())  {
        QProcess linking;
        linking.start("ln -sf " + home + "/.local/share/applications/mimeapps.list " + home + "/.local/share/applications/defaults.list");
        linking.waitForFinished();
    }

    QProcess mimeProc;
    mimeProc.start("xdg-mime default " + desktopFile + " " + mimeType);
    mimeProc.waitForFinished();
}

QString DropletHelper::commandOutput(QString command)
{
    QProcess p;
    p.start(command);
    p.waitForFinished(3000);
    return p.readAllStandardOutput().trimmed();
}
