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

import "."

ListModel {
    id: historyModel

    property var db: SettingsModel.getStorageDatabase();
    property int maxCount: 100

    function prettyDate(time) {
        var date = new Date(time),
            diff = (((new Date()).getTime() - date.getTime()) / 1000)

        return diff < 60? qsTr("Just now") :
               diff < 3600? qsTr("Past hour"):
               diff < 86400? qsTr("Earlier today"):
               diff < 604800? qsTr("Earlier this week"):
                              qsTr("Long long ago..")
    }


    function initialize(){
        db.transaction(function(tx){
            tx.executeSql('CREATE TABLE IF NOT EXISTS history(timestamp INTEGER UNIQUE, url TEXT, title TEXT)');
        })
    }

    function add(url, title){
        var result = false
        var date = new Date()

        db.transaction(function(tx){
            var rs = tx.executeSql('INSERT OR REPLACE INTO history VALUES (?,?,?);', [date.getTime(),url, title]);
            if(rs.rowsAffected > 0)
                result = true
        })

        return result
    }

    function dataModel(startPoint){
        historyModel.clear()
        db.readTransaction(function(tx){
            var rs = tx.executeSql('SELECT * FROM history ORDER BY timestamp DESC limit (?)', [maxCount])
            for(var i = 0; i < rs.rows.length; i++)
            {
                var row = rs.rows.item(i)
                historyModel.append({ timestamp: prettyDate(row.timestamp), url: row.url, title: row.title })
            }
            //ListElement { timestamp: 'yesterday', url: 'https://duckduckgo.com', title: 'Duck duck go' }
        })

        return historyModel
    }

    function remove(uid){
        db.transaction(function(tx){
            var rs = tx.executeSql('DELETE FROM history WHERE uid=(?);', [uid])
        })
    }

    function wipe(){
        historyModel.clear()
        db.transaction(function(tx){
            var rs = tx.executeSql('DROP TABLE IF EXISTS history')
        })
        initialize()

    }

    Component.onCompleted: initialize()
}
