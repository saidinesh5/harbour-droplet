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

    //TODO: refactor this component to be not dependent on Bubble
    //TODO: Save me and restore me on App exit
    property int snapX: width - bubbleWidth
    property int snapY: height/4
    property int maxExpandableBubbles: 5
    property bool expandFromLeft: snapX === 0

    property Bubble interactionTarget
    property bool interactionActive: interactionTarget != null

    property bool expanded
    property alias model: bubbles.model
    property alias count: bubbles.count
    onCountChanged: bubbleStack.expanded = false

    property int currentIndex
    property Bubble currentItem: currentIndex >= 0 && currentIndex < bubbles.count? bubbles.itemAt(currentIndex) : null
    property int bubbleWidth: currentItem != null? currentItem.width : 1
    property Item tabLoader

    signal closeRequested(int index)

    Binding {
        when: !expanded
        target: bubbleStack
        property: 'currentIndex'
        value: bubbleStack.count - 1
    }

    function isExpandable(index) {
        return bubbleStack.count - index - 1 < maxExpandableBubbles
    }

    function _overlaps(bubble1, bubble2) {
        //Checks if the circle containing bubble1 overlaps with that of bubble2
        var center1 = Qt.vector2d(bubble1.x + bubble1.width/2, bubble1.y + bubble1.height/2)
        var center2 = Qt.vector2d(bubble2.x + bubble2.width/2, bubble2.y + bubble2.height/2)
        var distance = center1.minus(center2).length()
        return distance < bubble1.radius + bubble2.radius
    }

    TrashCan {
        id: trashCan

        enabled: interactionActive
        activated: interactionTarget != null && _overlaps(this, interactionTarget)

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: height
    }

    Repeater {
        id: bubbles
        Bubble {
            id: bubble

            property bool isTop: index === bubbleStack.count - 1
            property bool isCurrent: index === bubbleStack.currentIndex || (isTop && !bubbleStack.expanded)
            property Tab tab: tabLoader.itemAt(index)
            property int bubbleIndex: index

            iconSource: tab !== null ? tab.icon : ''
            progress: tab !== null? tab.loadProgress : 0
            showProgress: tab !== null && tab.loading

            Connections {
                target: tabLoader
                onItemAdded: if(index === bubbleIndex) tab = item
                onItemRemoved: if(index === bubbleIndex) tab = null
            }

            minX: 0
            minY: 0
            maxX: bubbleStack.width
            maxY: bubbleStack.height

            number: bubbleStack.expanded? count - maxExpandableBubbles : count
            showNumber: expanded? (index === bubbleStack.count - maxExpandableBubbles && bubbleStack.count - maxExpandableBubbles > 0 && !held):
                                  count > 1
            numberAlignmentToRight: tab && bubbleStack && tab.x + tab.width/2 > bubbleStack.width/2

            visible: isTop || bubbleStack.expanded && isExpandable(index + 1)
            highlighted: isCurrent || held

            onClicked: {
                if(bubbleStack.expanded){
                    if(bubbleStack.currentIndex === index) bubbleStack.expanded = false
                    else bubbleStack.currentIndex = index
                }
                else bubbleStack.expanded = true
            }
            onDoubleClicked: bubbleStack.expanded = !bubbleStack.expanded
            onDragActiveChanged: {
                if(dragActive)
                {
                    bubbleStack.interactionTarget = this
                }
                else
                {
                    //See if this bubble needs to be deleted
                    if(bubbleStack._overlaps(bubble, trashCan))
                    {
                        bubbleStack.interactionTarget = null
                        if(bubbleStack.expanded) bubbleStack.closeRequested(index)
                        else bubbleStack.closeRequested(-1)
                        return
                    }

                    //See if the user just wants to move the tabStack around
                    if(!bubbleStack.expanded)
                    {
                        snapX = x + width/2 > bubbleStack.width/2? bubbleStack.width - width : 0
                        snapY = y
                    }

                    bubbleStack.interactionTarget = null
                }
            }

            Binding {
                target: bubble
                when: !bubbleStack.interactionActive
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
                when: !bubbleStack.interactionActive
                property: 'y'
                value: bubbleStack.expanded ? 0 : snapY
            }

            Behavior on x { enabled: !held; NumberAnimation { duration: 200; easing.type: Easing.InOutQuad } }
            Behavior on y { enabled: !held; NumberAnimation { duration: 200; easing.type: Easing.InOutQuad } }
        }
    }
}
