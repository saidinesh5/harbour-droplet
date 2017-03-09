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

Item {
    id: bubbleStack

    clip: true

    //TODO: Save me and restore me on App exit
    property int snapX: width - bubbleWidth
    property int snapY: height/4
    property int maxExpandableBubbles: 5
    property bool expandFromLeft: snapX === 0

    property Item interactionTarget
    property bool interactionActive: interactionTarget != null
    property Item dragTarget
    property bool dragActive: dragTarget != null

    property bool expanded
    property alias model: bubbles.model
    property alias count: bubbles.count
    onCountChanged: bubbleStack.expanded = false

    property int currentIndex
    Binding {
        when: !expanded
        target: bubbleStack
        property: 'currentIndex'
        value: bubbleStack.count - 1
    }
    property Item currentItem: currentIndex >= 0 && currentIndex < count? bubbles.itemAt(currentIndex).item : null
    property int bubbleWidth: currentItem != null? currentItem.width : 1

    property Component delegate

    signal closeRequested(int index)

    function isExpandable(index) {
        return bubbleStack.count - index - 1 < maxExpandableBubbles
    }

    function _overlaps(bubble1, bubble2) {
        //Checks if the circle containing bubble1 overlaps with that of bubble2
        var center1 = Qt.vector2d(bubble1.x + bubble1.width/2, bubble1.y + bubble1.height/2)
        var center2 = Qt.vector2d(bubble2.x + bubble2.width/2, bubble2.y + bubble2.height/2)
        var radius1 = bubble1.width/2
        var radius2 = bubble2.width/2
        var distance = center1.minus(center2).length()
        return distance < radius1 + radius2
    }

    TrashCan {
        id: trashCan

        enabled: dragActive
        activated: dragTarget != null && _overlaps(this, dragTarget)

        anchors.horizontalCenter: parent.horizontalCenter
        y: enabled? parent.height - 2*height : parent.height

        Behavior on y {
            enabled: dragActive
            NumberAnimation{ easing.period: 0.75; duration: 500; easing.type: Easing.OutElastic }
        }
    }

    Repeater {
        id: bubbles

        Item {
            id: bubble

            property int bubbleIndex: index
            property alias item: delegateLoader.item

            width: item.width
            height: item.height

            Loader {
                id: delegateLoader

                property int index: bubble.bubbleIndex
                property bool pressed: mouseArea.pressed

                sourceComponent: bubbleStack.delegate
            }

            MouseArea {
                id: mouseArea
                anchors.fill: parent

                property bool dragActive: drag.active

                drag.target: bubble
                drag.minimumX: 0
                drag.minimumY: 0
                drag.maximumX: bubbleStack.width
                drag.maximumY: bubbleStack.height

                onClicked: {
                    if(bubbleStack.expanded){
                        if(bubbleStack.currentIndex === index) bubbleStack.expanded = false
                        else bubbleStack.currentIndex = index
                    }
                    else bubbleStack.expanded = true
                }

                onDoubleClicked: bubbleStack.expanded = !bubbleStack.expanded
                onPressed: bubbleStack.interactionTarget = item
                onReleased: {
                    if(bubbleStack._overlaps(bubble, trashCan))
                    {
                        bubbleStack.interactionTarget = null
                        if(bubbleStack.expanded) bubbleStack.closeRequested(index)
                        else bubbleStack.closeRequested(-1)
                        return
                    }

                    bubbleStack.interactionTarget = null
                }

                onDragActiveChanged: {
                    if(!dragActive)
                    {
                        if(!bubbleStack.expanded)
                        {
                            snapX = bubble.x + bubble.width/2 > bubbleStack.width/2? bubbleStack.width - bubble.width : 0
                            snapY = bubble.y
                        }
                    }

                    bubbleStack.dragTarget = dragActive? bubble : null
                }
            }


            Binding {
                target: bubble
                when: !bubbleStack.dragActive
                property: 'x'
                value: {
                    if(bubbleStack.expanded) {
                        //bubbleWidth*(index - Math.max(bubbleStack.count - maxExpandableBubbles, 0))
                        if(bubbleStack.expandFromLeft) bubbleWidth*(Math.min(bubbleStack.count - index - 1, maxExpandableBubbles - 1))
                        else bubbleStack.width - bubbleWidth*(Math.min(bubbleStack.count - index, maxExpandableBubbles))
                    }
                    else snapX
                }
            }

            Binding {
                target: bubble
                when: !bubbleStack.dragActive
                property: 'y'
                value: bubbleStack.expanded ? 0 : snapY
            }

            Behavior on x { enabled: !bubbleStack.interactionActive; NumberAnimation { easing.period: 0.75; duration: 500; easing.type: Easing.OutElastic } }
            Behavior on y { enabled: !bubbleStack.interactionActive; NumberAnimation { easing.period: 0.75; duration: 500; easing.type: Easing.OutElastic } }
        }
    }
}
