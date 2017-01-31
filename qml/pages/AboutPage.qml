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

import "../components"
import "../models"
import "../vendor/FontAwesome"

Page {
    id: page

    allowedOrientations: Orientation.Portrait

    SilicaFlickable {
        id: flickable
        anchors.fill: page
        contentHeight: column.height
        contentWidth: column.width

        Column {
            id: column
            width: page.width
            spacing: Theme.paddingLarge
            anchors.margins: Theme.paddingMedium

            PageHeader {
                title: qsTr("About")
            }

            Image {
                id: logo
                anchors.horizontalCenter: parent.horizontalCenter
                fillMode: Image.PreserveAspectFit
                width: page.width/2
                height: width
                source: Qt.resolvedUrl("../images/harbour-droplet.svg")

                MouseArea {
                    anchors.fill: parent
                    onPressAndHold: pageStack.push(Qt.resolvedUrl("FirstRunPage.qml"))
                }
            }

            Label {
                id: label
                font.pixelSize: Theme.fontSizeLarge
                font.bold: true
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                text: qsTr("Droplet Browser v") + SettingsModel.applicationVersion
            }

            Label {
                id: author
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                text: qsTr("by :Dinesh")
            }

            SilicaFlickable {
                id: license
                clip: true
                anchors.horizontalCenter: parent.horizontalCenter
                height: parent.height*0.3
                width: parent.width*0.8
                contentWidth: width
                contentHeight: licenseText.height
                Label {
                    id: licenseText
                    font.pixelSize: Theme.fontSizeTiny
                    width: license.width
                    wrapMode: Text.WordWrap
                    text: "Copyright 2017 Dinesh Manajipet.
This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>."
                }

                ScrollDecorator{ flickable: license }
            }

            Row {
                id: links
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: Theme.paddingLarge

                BackgroundItem {
                    id: sourceWebsite
                    width: Theme.iconSizeMedium
                    height: width
                    Label {
                        anchors.centerIn: parent
                        font.family: FontAwesome.fontName
                        font.pixelSize: Theme.fontSizeLarge
                        text: FontAwesome.icon.github
                    }

                    onClicked: Qt.openUrlExternally("https://github.com/saidinesh5/harbour-droplet")
                }

                BackgroundItem {
                    id: googleplus
                    width: Theme.iconSizeMedium
                    height: width
                    Label {
                        anchors.centerIn: parent
                        font.pixelSize: Theme.fontSizeLarge
                        font.family: FontAwesome.fontName
                        text: FontAwesome.icon.google_plus_square
                    }
                    onClicked: Qt.openUrlExternally("https://plus.google.com/u/0/105526388669909711493")
                }

                BackgroundItem {
                    id: paypal
                    width: Theme.iconSizeMedium
                    height: width
                    Label {
                        anchors.centerIn: parent
                        font.pixelSize: Theme.fontSizeLarge
                        font.family: FontAwesome.fontName
                        text: FontAwesome.icon.paypal
                    }
                    onClicked: Qt.openUrlExternally("https://paypal.me/saidinesh5")
                }
            }
        }
    }
}
