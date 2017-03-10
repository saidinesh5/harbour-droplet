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
import org.nemomobile.notifications 1.0
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
        running: g_tabModel.count === 0 && connectedClients === 0
        interval: SettingsModel.overlayTimeout
        onTriggered: {
            console.log("There are no active droplets or connected clients. Bye Bye")
            thisWindow.quit()
        }
    }

    BookmarksModel { id: g_bookmarksModel }
    HistoryModel { id: g_historyModel }
    TabModel {
        id: g_tabModel
        onCountChanged: g_dbusService.emitSignal("dropletCountChanged", g_tabModel.count)
    }

    Item {
        id: tabContainer
        width: root.width
        height: root.height - bubbleStack.bubbleWidth

        visible: true

        Repeater {
            id: tabLoader
            width: tabContainer.width
            height: tabContainer.height
            model: g_tabModel.dataModel()

            delegate: Tab {
                clip: true
                anchors.fill: parent
                url: source
                visible: bubbleStack.currentIndex === index && bubbleStack.expanded
                active: bubbleStack.isExpandable(index)

                onCollapseRequested: bubbleStack.expanded = false
                onCloseRequested: g_tabModel.remove(index)
                onBookmarkedChanged: g_dbusService.emitSignal("bookmarksUpdated", [])
            }
        }

        y: bubbleStack.expanded? bubbleStack.bubbleWidth : root.height

        Behavior on y { NumberAnimation { duration: 200 } }
    }

    BubbleStack {
        id: bubbleStack

        anchors.fill: parent

        property rect contentArea: expanded? Qt.rect(0, 0, width, height):
                                             Qt.rect(snapX,snapY, bubbleWidth, bubbleWidth)
        onContentAreaChanged: thisWindow.activeArea = contentArea

        model: tabLoader.count

        maxExpandableBubbles: SettingsModel.preloadCount
        onExpandedChanged: {
            //thisWindow.activeAreaShape = (expanded)? AppletView.Rectangle : AppletView.Ellipse
            if(expanded) {
                thisWindow.flags |= (Qt.WindowOverridesSystemGestures)
                thisWindow.raise()
            }
            else {
                thisWindow.flags &= ~(Qt.WindowOverridesSystemGestures)
                thisWindow.lower()
            }
        }

        delegate: Bubble {
            property Tab tab: tabLoader.itemAt(index)
            property bool isTop: index === bubbleStack.count - 1
            property bool isCurrent: index === bubbleStack.currentIndex || (isTop && !bubbleStack.expanded)

            iconSource: tab !== null ? tab.icon : ''
            progress: tab !== null? tab.loadProgress : 0
            showProgress: tab !== null && tab.loading

            number: bubbleStack.expanded? bubbleStack.count - bubbleStack.maxExpandableBubbles : bubbleStack.count
            showNumber: bubbleStack.expanded? (index === bubbleStack.count - bubbleStack.maxExpandableBubbles && bubbleStack.count - bubbleStack.maxExpandableBubbles > 0 && !pressed):
                                  bubbleStack.count > 1
            showNumberToRight: bubbleStack.snapX === 0
            visible: isTop || bubbleStack.expanded && bubbleStack.isExpandable(index + 1)

            highlighted: isCurrent || pressed
            backgroundColor: pressed? Qt.rgba(0.7,0.7,0.7, 1) : Qt.rgba(1, 1, 1, 1)
        }

        onCloseRequested: {
            if(index >= 0) g_tabModel.remove(index)
            else g_tabModel.clear()
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
                  <method name="openUrlExternally"> <arg type="s" name="url" direction="in"/> </method>
                  <method name="dropletCount"> <arg type="i" name="url" direction="out"/> </method>
                  <method name="quit"/>
                  <method name="attachClient"/>
                  <method name="detachClient"/>
                  <signal name="dropletCountChanged"><arg type="i" name="count" direction="out"/></signal>
                  <signal name="bookmarksUpdated"/>
              </interface>'

        function openUrl(url){
            var urlString = url.toString()
            if(SettingsModel.doubleTapToOpenExternally) {
                if(g_tabModel.enqueuedUrl === urlString)
                {
                    g_tabModel.enqueuedUrl = ''
                    g_dropletHelper.openInExternal(urlString)
                }
                else g_tabModel.delayedPush(urlString)
            }
            else g_tabModel.push(urlString)
        }

        function openUrlExternally(url){
            g_dropletHelper.openInExternal(url.toString())
        }

        function quit(){
            g_tabModel.clear()
        }

        function dropletCount()
        {
            return g_tabModel.count
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

    Notification {
        id: fallbackModeNotification
        urgency: Notification.Low
        category: 'x-nemo.software-update.conf'
        appName: qsTr("Droplet Browser")
        previewSummary: qsTr("Applets not supported!")
        previewBody: qsTr("Droplet browser needs support for applets")
        summary: qsTr("Applets not supported!")
        body: qsTr("Kindly enable support for Applets for optimum experience.")

        remoteActions: [ {
                "name": "default",
                "displayName": qsTr("Enable support for applets"),
                "icon": "icon-lock-social",
                "service": SettingsModel.dbusServiceName,
                "path": SettingsModel.dbusPathName,
                "iface": SettingsModel.dbusInterfaceName,
                "method": "openUrlExternally",
                "arguments": ["https://github.com/saidinesh5/sailfishos-lipstick-enable-applets"]
            }]
    }

    Component.onCompleted: {
        SettingsModel.isDefaultBrowser = g_dropletHelper.isDefaultBrowser
        g_dbusService.emitSignal("dropletCountChanged", g_tabModel.count)

        if(thisWindow.fallbackMode){
            fallbackModeNotification.publish()
        }
    }
}

