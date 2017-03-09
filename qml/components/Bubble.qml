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

import "../vendor/FontAwesome"

Item {
    id: bubble

    property int number
    property bool showNumber
    property bool showNumberToRight

    property alias iconText: iconLabel.text
    property alias iconSource: icon.source

    property alias progress: progressCircle.progressValue
    property alias showProgress: progressCircle.visible

    property bool highlighted

    property int diameter: Math.max(iconLabel.width, iconLabel.height)*3
    property alias radius: bubbleBg.radius
    property alias backgroundColor: bubbleBg.color

    width: diameter
    height: diameter

    Rectangle {
        id: bubbleBg

        anchors.centerIn: parent
        width: highlighted? diameter : diameter*0.8
        height: width
        radius: width*0.5
        border.color: 'darkgrey'

        Behavior on width { NumberAnimation{ duration: 200 } }
    }

    Label {
        id: iconLabel
        anchors.centerIn: parent
        font.family: FontAwesome.fontName
        text: FontAwesome.icon.globe
        visible: icon.source == ''
        color: 'black'
    }

    Image {
        id: icon
        width: parent.width/3
        height: width
        anchors.centerIn: parent
    }

    ProgressCircle {
        id: progressCircle
        width: highlighted? diameter : diameter*0.8
        height: width
        progressValue: 0.55
        visible: progressValue !== -1 && progressValue !== 1.0
    }

    Rectangle {
        id: bubbleCount
        x: showNumberToRight? bubbleBg.width - width : 0
        y: bubbleBg.height - height
        visible: showNumber
        width: numberLabel.width + Theme.paddingMedium
        height: numberLabel.height*1.1
        radius: width/4
        color: 'lightblue'

        Label {
            id: numberLabel
            anchors.centerIn: parent
            fontSizeMode: Text.Fit
            font.bold: true
            text: number
            color: 'white'
        }
    }
}
