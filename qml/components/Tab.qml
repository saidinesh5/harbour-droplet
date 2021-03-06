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
import QtWebKit 3.0
import QtWebKit.experimental 1.0
import Sailfish.Silica 1.0
import Sailfish.Silica.private 1.0

import "."
import "../models"
import "../vendor/FontAwesome"

Rectangle {
    id: tab

    property url url
    property bool mobileMode: SettingsModel.isDefaultDeviceMobile
    property bool bookmarked: _bookmarked || g_bookmarksModel.contains(url)

    readonly property string title: _content !== null? _content.title : ''
    readonly property string icon: _content !== null? _content.icon : ''

    readonly property bool loading: _content !== null? _content.loading : false
    readonly property real loadProgress: _content !== null? _content.loadProgress : 0

    readonly property bool canGoBack: _content !== null? _content.canGoBack : false
    readonly property bool canGoForward: _content !== null? _content.canGoForward : false

    property alias active: contentLoader.active

    function goBack(){ _content.goBack() }
    function goForward(){ _content.goForward() }
    function stop(){ _content.stop() }
    function reload(){ _content.reload() }

    property Item _content: contentLoader.item
    property bool _bookmarked

    onUrlChanged: {
        //To make sure the binding gets reevaluated on local change
        _bookmarked = false
    }

    signal closeRequested()
    signal collapseRequested()

    onLoadingChanged: if(!loading) g_historyModel.add(url, title)
/*
    Component {
        id: contentComponent
        Rectangle {
            //id: dummycontent
            property url url: tab.url
            property url icon
            property string title: 'Demo Demo Demo Demo Demo Demo Demo'
            property bool loading: loadProgress <= 1
            property real loadProgress: Math.random()
            property bool canGoBack: true
            property bool canGoForward: false

            color: Qt.rgba(Math.random(), Math.random(), Math.random(), 1)

            function goBack(){ console.log("Going back") }
            function goForward(){ console.log("Going forward") }
            function stop(){ loadProgress = 1 }
            function reload(){ loadProgress = 0 }

            TextEdit {
                anchors.centerIn: parent
                text:  mobileMode? 'mobile :'+  url  : 'desktop :' + url
                focus: tab.visible
            }

            Timer {
                running: loading
                repeat: true
                interval: 100
                onTriggered: loadProgress += 0.01*Math.random()
            }

            Component.onCompleted: console.log("Loaded: ", url)
        }
    }
*/
    Component {
        id: contentComponent
        WebView {
            id: webView
            url: tab.url

            focus: tab.visible

            anchors.fill: parent
            anchors.bottomMargin: vkbObserver.opened? vkbObserver.panelSize : 0

            VirtualKeyboardObserver {
                id: vkbObserver
                active: webView.visible

                onOpenedChanged: {
                    if (opened) {
                        if (webView.focus && webView._allowFocusAnimation) {
                            experimental.animateInputFieldVisible()
                        }
                    }
                }
            }

            experimental.userAgent: mobileMode? SettingsModel.defaultUserAgentMobile :
                                                SettingsModel.defaultUserAgentDesktop
            experimental.useDefaultContentItemSize: false

            // Column handles height of web content and width read from web page
            // For still unknown reason pulley menu cannot be opened when contentHeight == height
            // Due to Bug #7857, cleanup + 1px when bug is fixed
            contentHeight: Math.floor(Math.max(webView.height + 1, webView.experimental.page.height))
            contentWidth: Math.floor(Math.max(tab.width, webView.experimental.page.width))

            experimental.deviceWidth: Screen.width
            experimental.deviceHeight: Screen.height
            experimental.preferences.cookiesEnabled: true
            experimental.enableInputFieldAnimation: false
            experimental.enableResizeContent: !vkbObserver.animating
            experimental.preferences.developerExtrasEnabled: true
            experimental.preferences.navigatorQtObjectEnabled: true

            //We are not interested in taking care of the downloads.
            //Let the default browser nicely download it to transfers
            experimental.onDownloadRequested: {
                Toast.post(qsTr("Starting download..."))
                g_dropletHelper.openInExternal(downloadItem.url.toString())
                tab.collapseRequested()
            }

            // Helps rendering websites that are only optimized for desktop
            experimental.preferredMinimumContentsWidth: 980

            experimental.userScripts: [
                Qt.resolvedUrl("../js/devicePixelRatioHack.js"),
                Qt.resolvedUrl("../js/userscript.js")
            ]

            experimental.onMessageReceived: {
                var data = null
                try {
                    data = JSON.parse(message.data)
                } catch (error) {
                    console.log('onMessageReceived: ' + message.data )
                    return
                }


                switch (data.type) {
                case 'link':
                    if(data.target === '_blank') g_tabModel.push(data.href)
                    else if(data.target && data.target !== '_parent') g_tabModel.push(data.href)
                    break
                }
            }

            Component.onCompleted: console.log("Loading: ", url)

            Connections {
                target: webView.experimental.page
                onWidthChanged: contentWidth = Math.floor(Math.max(webView.width, webView.experimental.page.width))
            }
        }
    }

    Loader {
        id: contentLoader
        sourceComponent: contentComponent

        width: tab.width
        anchors.top: header.bottom
        anchors.bottom: tab.bottom

        Connections {
            target: contentLoader.item
            ignoreUnknownSignals: true

            onUrlChanged: tab.url = _content.url
        }
    }

    Rectangle {
        id: subheader
        border.color: 'darkgrey'
        width: header.width
        height: header.height
        enabled: false
        visible: enabled
        y: enabled? header.height : 0

        Row {
            anchors.fill: parent

            //Back
            TabHeaderButton {
                width: parent.width/5
                height: parent.height
                enabled: canGoBack
                iconText: FontAwesome.icon.chevron_left
                onClicked: goBack()
            }

            //Forward
            TabHeaderButton {
                width: parent.width/5
                height: parent.height
                enabled: canGoForward
                iconText: FontAwesome.icon.chevron_right
                onClicked: goForward()
            }

            //Bookmark
            TabHeaderButton {
                width: parent.width/5
                height: parent.height
                iconText: tab.bookmarked? FontAwesome.icon.bookmark : FontAwesome.icon.bookmark_o
                onClicked: {
                    //Show toast
                    if(tab.bookmarked){
                        g_bookmarksModel.remove(url)
                        tab._bookmarked = false
                    }
                    else {
                        g_bookmarksModel.add(title, url)
                        tab._bookmarked = true
                        Toast.post(qsTr("Bookmarked"))
                    }
                }
            }

            //Copy link
            TabHeaderButton {
                width: parent.width/5
                height: parent.height
                iconText: FontAwesome.icon.link
                onClicked: {
                    Clipboard.text = tab.url
                    Toast.post(qsTr("Link copied"))
                }
            }

            //Launch in external
            TabHeaderButton {
                width: parent.width/5
                height: parent.height
                iconText: FontAwesome.icon.share_square_o
                onClicked: {
                    g_dropletHelper.openInExternal(url)
                    tab.closeRequested()
                    Toast.post(qsTr("Launching in Sailfish Browser..."))
                }
            }

        }

        Behavior on y { NumberAnimation { duration: 100 } }
    }

    Rectangle {
        id: header
        width: tab.width
        height: 1.25*Math.max(Theme.fontSizeMedium, Theme.iconSizeMedium)
        border.color: 'darkgrey'

        //Title
        Label {
            color: 'black'
            anchors.left: header.left
            anchors.leftMargin: Theme.paddingSmall
            anchors.verticalCenter: parent.verticalCenter
            text: {
                var allowedLength = Math.floor((tab.width/2)/Theme.paddingMedium)
                if(title.length >= allowedLength)
                    return title.substring(0, allowedLength - 4) + '...'
                return title
            }
        }

        //Navigation buttons
        Row {
            x: header.width/2
            anchors.verticalCenter: parent.verticalCenter
            width: header.width/2
            height: header.height
            layoutDirection: Qt.RightToLeft

            //Subheader Menu
            TabHeaderButton {
                width: parent.width/4
                height: parent.height
                iconText: FontAwesome.icon.chevron_down
                onClicked: subheader.enabled = !subheader.enabled
            }

            //Mobile Mode/Desktop Mode
            TabHeaderButton {
                width: parent.width/4
                height: parent.height
                iconText: mobileMode? FontAwesome.icon.desktop : FontAwesome.icon.mobile
                onClicked: {
                    //TODO: Fix the URL if the url changed too
                    mobileMode = !mobileMode
                    reload()
                }
            }

            //Stop/Refresh Button
            TabHeaderButton {
                width: parent.width/4
                height: parent.height
                iconText: tab.loading? FontAwesome.icon.stop : FontAwesome.icon.refresh
                onClicked: tab.loading? stop() : reload()
            }

        }
    }

    Rectangle {
        id: progressBar
        width: loadProgress*tab.width
        height: 1
        anchors.top: subheader.bottom
        anchors.topMargin: -height

        color: 'lightblue'
        visible: loading
    }

    onActiveChanged: subheader.enabled = false
    onVisibleChanged: subheader.enabled = false
}
