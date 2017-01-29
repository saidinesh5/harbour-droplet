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


pragma Singleton
import QtQuick 2.0

Item {
    property alias count: tabModel.count
    property string enqueuedUrl: ''

    function push(url) {
        if(url !== '') tabModel.append({ source: url })
    }

    function delayedPush(url) {
        if(enqueuedUrl !== url)
            push(enqueuedUrl)

        enqueuedUrl = url
        timer.restart()
    }

    function remove(index) {
        tabModel.remove(index)
    }

    function clear(index) {
        tabModel.clear()
    }

    function dataModel() {
        return tabModel
    }

    Timer {
        id: timer

        interval: 200
        repeat: false
        running: enqueuedUrl !== ''
        onTriggered: {
            push(enqueuedUrl)
            enqueuedUrl = ''
        }
    }


    ListModel {
        id: tabModel
        //ListElement{ source: 'http://google.com' }
    }
}
