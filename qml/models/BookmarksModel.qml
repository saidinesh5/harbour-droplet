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
    id: bookmarksModel

    //ListElement{title: "Google"; url: "www.google.com"; icon: ""}
    property var db: SettingsModel.getStorageDatabase();

    function initialize(){
        db.transaction(function(tx){
            tx.executeSql('CREATE TABLE IF NOT EXISTS bookmarks(title TEXT, url TEXT)')
            var table = tx.executeSql("SELECT * FROM bookmarks")
            if(table.rows.length === 0)
            {
                console.log("Initializing Bookmarks Table with fresh data")
                tx.executeSql('INSERT INTO bookmarks VALUES (?,?);', ["Duck Duck Go", "https://duckduckgo.com/"])
                tx.executeSql('INSERT INTO bookmarks VALUES (?,?);', ["Jolla Together", "https://together.jolla.com/questions/"])
                tx.executeSql('INSERT INTO bookmarks VALUES (?,?);', ["Maemo forum", "https://talk.maemo.org/"])
            }
        })
    }

    function reload(){
        bookmarksModel.clear()
        db.readTransaction(function(tx){
            var rs = tx.executeSql('SELECT * FROM bookmarks ORDER BY bookmarks.title;');
            for(var i = 0; i < rs.rows.length; i++)
            {
                var item = rs.rows.item(i)
                bookmarksModel.append({ title: item.title, url: item.url })
            }
        })
    }

    function add(title, url){
        var result = false

        db.transaction(function(tx){
            //If already exists, remove - called at times for updating title etc..
            remove(url)
            var rs = tx.executeSql('INSERT OR REPLACE INTO bookmarks VALUES (?,?);', [title,url])
            result = rs.rowsAffected > 0
        })

        return result
    }

    function dataModel(){
        reload()
        return bookmarksModel
    }

    function contains(url){
        var result = false

        db.readTransaction(function(tx){
            var rs = tx.executeSql('SELECT * FROM bookmarks  WHERE url=(?);', [url])
            result = rs.rows.length > 0
        })

        return result
    }

    function remove(url){
        db.transaction(function(tx){
            var rs = tx.executeSql('DELETE FROM bookmarks WHERE url=(?);', [url])
        })
    }

    function wipe(){
        bookmarksModel.clear()
        db.transaction(function(tx){
            var rs = tx.executeSql('DROP TABLE IF EXISTS bookmarks;')
        })
        initialize()
    }

    Component.onCompleted: initialize()
}
