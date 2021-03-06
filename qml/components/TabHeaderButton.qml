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

MouseArea {
    id: button

    width: 2*icon.width
    height: 2*icon.height

    property alias iconText: icon.text

    Rectangle {
        anchors.fill: parent
        color: button.pressed? Qt.rgba(0,0,0, 0.5) : Qt.rgba(0,0,0,0)

        Label {
            id: icon
            color: button.enabled? 'black' : 'grey'
            anchors.centerIn: parent
            font.family: FontAwesome.fontName
        }
    }
}
