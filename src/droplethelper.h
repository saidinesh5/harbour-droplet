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

#ifndef DROPLETHELPER_H
#define DROPLETHELPER_H

#include <QObject>

class DropletHelper : public QObject
{
    Q_OBJECT

    Q_PROPERTY(bool isDefaultBrowser READ isDefaultBrowser WRITE setIsDefaultBrowser NOTIFY isDefaultBrowserChanged)

public:
    explicit DropletHelper(QObject *parent = 0);

    bool isDefaultBrowser();

    Q_INVOKABLE void openInDroplet(QString url);
    Q_INVOKABLE void openInExternal(QString url);

signals:
    void isDefaultBrowserChanged(bool value);

public slots:
    void setIsDefaultBrowser(bool value);

private:
    void setMime(const QString &mimeType, const QString &desktopFile);
    QString commandOutput(QString command);
};

#endif // DROPLETHELPER_H
