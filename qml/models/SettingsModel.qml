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
import org.nemomobile.configuration 1.0
import QtQuick.LocalStorage 2.0 as LS

Item {
    id: settings

    function getStorageDatabase(){
        return LS.LocalStorage.openDatabaseSync("dropletbrowser", "0.1", "StorageDatabase", 100000);
    }

    readonly property string applicationVersion: "0.2"

    readonly property string dbusServiceName: "net.garageresearch.droplet"
    readonly property string dbusPathName: "/browser"
    readonly property string dbusInterfaceName: "net.garageresearch.droplet"


    //General Settings
    property alias isFirstRun: firstRunItem.value
    property alias isDefaultBrowser: defaultBrowserItem.value
    property alias doubleTapToOpenExternally: doubleTapToOpenExternallyItem.value
    readonly property int overlayTimeout: 3000

    //Browser Settings
    property alias isDefaultDeviceMobile: defaultDeviceMoileItem.value
    property alias preloadCount: preloadCountItem.value

    property string defaultUserAgentMobile: "Mozilla/5.0 (Linux; Android 4.4; Nexus 4 Build/KRT16H) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/30.0.0.0 Mobile Safari/537.36"
    property string defaultUserAgentDesktop: "Mozilla/5.0 (X11; Linux) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/27.0.1453 Safari/537.36"

    ConfigurationValue {
      id: firstRunItem
      key: "/apps/garageresearch/droplet/is_first_run"
      defaultValue: true
    }

    ConfigurationValue {
      id: defaultBrowserItem
      key: "/apps/garageresearch/droplet/is_default_browser"
      defaultValue: false
    }

    ConfigurationValue {
      id: doubleTapToOpenExternallyItem
      key: "/apps/garageresearch/droplet/doubletap_to_open_externally"
      defaultValue: true
    }

    ConfigurationValue {
      id: defaultDeviceMoileItem
      key: "/apps/garageresearch/droplet/browser/is_default_device_mobile"
      defaultValue: true
    }

    ConfigurationValue {
      id: preloadCountItem
      key: "/apps/garageresearch/droplet/browser/preload_count"
      defaultValue: 5
    }

    //Maybe one to vibrate the device when a new link is added
}
