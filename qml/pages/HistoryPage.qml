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
    id: historyPage

    allowedOrientations: Orientation.Portrait

    SilicaFlickable {
        anchors.fill: parent

        PullDownMenu {
            MenuItem {
                text: qsTr("Clear History")
                onClicked: historyModel.wipe()
            }
        }

        contentWidth: column.width
        contentHeight: column.height

        HistoryModel { id: historyModel }

        Column {
            id: column

            width: historyPage.width

            PageHeader {
                id: pageHeader
                title: qsTr("History")
            }

            SilicaListView {
                id: listView
                model: historyModel.dataModel()
                height: historyPage.height - pageHeader.height
                width: parent.width
                clip: true

                section.property: "timestamp"
                section.criteria: ViewSection.FullString
                section.delegate: SectionHeader{ text: section }

                delegate: BackgroundItem {
                    id: delegate

                    Label {
                        x: Theme.horizontalPageMargin
                        text: title && title !== ""? title : url
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
