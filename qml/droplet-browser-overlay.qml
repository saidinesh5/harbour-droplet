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
import org.nemomobile.dbus 2.0
import net.garageresearch.droplet 0.1

import "components"
import "models"

Item {
    id: root
    width: thisWindow.width
    height: thisWindow.height

    property int connectedClients: 0

    Timer {
        //3 seconds of no tabs / connected clients means the browser exits
        id: exitTimer
        running: tabModel.count === 0 && connectedClients === 0
        interval: SettingsModel.overlayTimeout
        onTriggered: {
            console.log("There are no active droplets or connected clients. Bye Bye")
            thisWindow.quit()
        }
    }

    ListModel {
        id: tabModel
        //ListElement { source: 'http://www.google.com' }
        onCountChanged: g_dbusService.emitSignal("dropletCountChanged", count)

        function push(url) {
            tabModel.append({ source: url })
        }
    }

    Item {
        id: tabContainer
        width: root.width
        height: root.height - tabStack.bubbleWidth

        visible: true

        Repeater {
            id: tabLoader
            width: tabContainer.width
            height: tabContainer.height
            model: tabModel

            delegate: Tab {
                clip: true
                width: tabContainer.width
                height: tabContainer.height
                url: source
                visible: tabStack.currentIndex === index && tabStack.expanded
                active: tabStack.isExpandable(index)

                onCollapseRequested: tabStack.expanded = false
                onCloseRequested: tabModel.remove(index)
                onBookmarkedChanged: g_dbusService.emitSignal("bookmarksUpdated", [])
            }
        }

        y: tabStack.expanded? tabStack.bubbleWidth : root.height
        Behavior on y { NumberAnimation { duration: 200 } }
    }

    BubbleStack {
        id: tabStack

        anchors.fill: parent

        property rect contentArea: expanded || interactionActive? Qt.rect(0, 0, width, height):
                                                                  Qt.rect(snapX,snapY, bubbleWidth, bubbleWidth)
        onContentAreaChanged: thisWindow.activeArea = contentArea

        model: tabModel
        tabLoader: tabLoader

        maxExpandableBubbles: SettingsModel.preloadCount
        onExpandedChanged: {
            //thisWindow.activeAreaShape = (expanded)? AppletView.Rectangle : AppletView.Ellipse
            if(expanded) thisWindow.raise()
            else thisWindow.lower()
        }

        onCloseRequested: {
            if(index >= 0) tabModel.remove(index)
            else tabModel.clear()
        }
    }

    //Main DBus Service offering the interface to this overlay
    DBusAdaptor {
        id: g_dbusService
        service: SettingsModel.dbusServiceName
        path: SettingsModel.dbusPathName
        iface: SettingsModel.dbusInterfaceName
        xml: '<interface name="net.garageresearch.droplet">
                  <method name="openUrl"> <arg type="s" name="url" direction="in"/> </method>
                  <method name="dropletCount"> <arg type="i" name="url" direction="out"/> </method>
                  <method name="quit"/>
                  <method name="attachClient"/>
                  <method name="detachClient"/>
                  <signal name="dropletCountChanged"><arg type="i" name="count" direction="out"/></signal>
                  <signal name="bookmarksUpdated"/>
              </interface>'

        function openUrl(url){
            tabModel.push(url.toString())
        }

        function quit(){
            tabModel.clear()
        }

        function dropletCount()
        {
            return tabModel.count
        }

        function attachClient()
        {
            console.log("Client attached")
            root.connectedClients++;
        }

        function detachClient()
        {
            console.log("Client detached")
            if(root.connectedClients > 0)
                root.connectedClients--;
        }
    }

    Connections {
        target: SettingsModel
        onIsDefaultBrowserChanged: {
            g_dropletHelper.setIsDefaultBrowser(SettingsModel.isDefaultBrowser)
        }
    }

    DropletHelper {
        id: g_dropletHelper
        onIsDefaultBrowserChanged: SettingsModel.isDefaultBrowser = isDefaultBrowser
    }

    //TODO show a warning when running in fallbackmode

    Component.onCompleted: {
        SettingsModel.isDefaultBrowser = g_dropletHelper.isDefaultBrowser
        g_dbusService.emitSignal("dropletCountChanged", tabModel.count)
    }
}

