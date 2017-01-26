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

import QtQuick 2.0
import Sailfish.Silica 1.0
import org.nemomobile.dbus 2.0

import "pages"
import "models"

ApplicationWindow
{
    id: root

    property int dropletCount

    function closeAllDroplets()
    {
        g_dbusInterface.call("quit", [])
    }

    initialPage: {
        if(SettingsModel.isFirstRun)
        {
            SettingsModel.isFirstRun = false
            return Qt.createComponent("pages/FirstRunPage.qml")
        }

        return Qt.createComponent("pages/MainPage.qml")
    }

    DBusInterface {
        id: g_dbusInterface
        service: SettingsModel.dbusServiceName
        path: SettingsModel.dbusPathName
        iface: SettingsModel.dbusInterfaceName

        signalsEnabled: true

        function dropletCountChanged(count){
            root.dropletCount = count
        }
    }

    cover: Qt.resolvedUrl("cover/CoverPage.qml")
    allowedOrientations: defaultAllowedOrientations

    Component.onCompleted: {
        g_dbusInterface.call("attachClient")
        g_dbusInterface.typedCall("dropletCount", [] , function(count){ dropletCount = count})
    }

    Component.onDestruction: g_dbusInterface.call("detachClient")
}

