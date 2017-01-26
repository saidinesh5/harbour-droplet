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
import "../vendor/FontAwesome"

Page {
    id: page

    allowedOrientations: Orientation.Portrait

    PageHeader{ id: header; title: qsTr("Welcome") }

    ListView {
        id: slideshow

        clip: true

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: header.bottom
        anchors.bottom: button.top
        anchors.margins: Theme.paddingLarge

        boundsBehavior: Flickable.StopAtBounds
        snapMode: ListView.SnapOneItem
        highlightRangeMode: ListView.StrictlyEnforceRange
        maximumFlickVelocity: 0

        orientation: ListView.Horizontal

        currentIndex: 0

        spacing: Theme.paddingLarge

        model: ListModel{
            ListElement { imageSource: "../images/slide1.svg"; title: "Tap a link to open a new droplet" }
            ListElement { imageSource: "../images/slide2.svg"; title: "Tap the droplet to expand its content" }
            ListElement { imageSource: "../images/slide3.svg"; title: "Drag the droplet to the trashcan below to close it" }
        }

        delegate: Item {
            clip: true
            width: slideshow.width
            height: slideshow.height

            Image {
                id: image
                width: Math.min(parent.width, parent.height)
                height: width
                source: imageSource
            }

            Label {
                anchors.top:  image.bottom
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: 4*Theme.paddingLarge
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.Wrap
                text: qsTr(title)

                opacity: index !== slideshow.currentIndex || slideshow.dragging? 0.2 : 1.0

                Behavior on opacity { NumberAnimation { duration: 200 } }
            }
        }
    }

    ListView {
        id: scrollDecorator
        model: slideshow.count
        interactive: false
        width: Theme.fontSizeMedium*count
        height: Theme.fontSizeMedium
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: header.bottom
        anchors.topMargin: Math.min(parent.width, parent.height) + Theme.paddingLarge

        orientation: ListView.Horizontal

        delegate: Item {
            property int expanded: index === slideshow.currentIndex
            width: Theme.fontSizeMedium
            height: width
            Rectangle {
                width: expanded? parent.width : parent.width*0.5
                height: width
                radius: width/2
                x: expanded? 0 : 0.25*parent.width
                y: x

                Behavior on x { NumberAnimation{ duration: 100 } }
                Behavior on width { NumberAnimation{ duration: 100 } }
            }
        }
    }

    Button {
        id: button
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: Theme.paddingLarge
        text: qsTr("Make Droplet your default Browser")
        onClicked: {
            SettingsModel.isDefaultBrowser = true
            pageStack.replaceAbove(null, "MainPage.qml")
        }
    }
}
