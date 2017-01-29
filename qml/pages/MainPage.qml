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

import QtQuick 2.0
import Sailfish.Silica 1.0

import "../models"

Page {
    id: mainPage

    allowedOrientations: Orientation.Portrait

    SilicaFlickable {
        anchors.fill: parent

        PullDownMenu {
            MenuItem {
                text: qsTr("About")
                onClicked: pageStack.push(Qt.resolvedUrl("AboutPage.qml"))
            }
            MenuItem {
                text: qsTr("Settings")
                onClicked: pageStack.push(Qt.resolvedUrl("SettingsPage.qml"))
            }
            MenuItem {
                text: qsTr("History")
                onClicked: pageStack.push(Qt.resolvedUrl("HistoryPage.qml"))
            }
            MenuItem {
                visible: root.dropletCount > 0
                text: qsTr("Close all droplets")
                onClicked: g_dbusInterface.call("quit")
            }
        }

        contentWidth: column.width
        contentHeight: column.height

        BookmarksModel {
            id: bookmarksModel
        }

        Connections {
            target: root
            onBookmarksUpdated: bookmarksModel.reload()
        }

        Column {
            id: column

            width: mainPage.width

            PageHeader {
                id: pageHeader
                title: qsTr("Bookmarks")
            }

            SilicaListView {
                id: listView
                model: bookmarksModel.dataModel()
                height: mainPage.height - pageHeader.height
                width: parent.width
                clip: true

                delegate: BackgroundItem {
                    id: delegate

                    Label {
                        x: Theme.horizontalPageMargin
                        text: title
                        anchors.verticalCenter: parent.verticalCenter
                        color: delegate.highlighted ? Theme.highlightColor : Theme.primaryColor
                    }
                    onClicked: g_dbusInterface.call("openUrl", [url])
                }

                VerticalScrollDecorator {}
            }
        }

    }
}
