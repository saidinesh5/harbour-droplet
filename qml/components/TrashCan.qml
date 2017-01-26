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

Rectangle {
    id: trashCan

    property bool activated

    property int diameter:  Math.max(icon.width, icon.height)*3.2

    color: activated? 'white' : Qt.rgba(0,0,0,0.8)
    border.color: activated? 'black' : 'white'

    width: diameter
    height: diameter
    radius: diameter/2


    Label {
        id: icon
        anchors.centerIn: parent
        font.family: FontAwesome.fontName
        font.pointSize: 24
        color: activated? 'black' : 'white'
        text: activated? FontAwesome.icon.trash_o : FontAwesome.icon.trash
    }

    opacity: enabled? 1.0 : 0.0
    Behavior on opacity { NumberAnimation { duration: 200 } }
    Behavior on color { ColorAnimation { duration: 200 } }
}
