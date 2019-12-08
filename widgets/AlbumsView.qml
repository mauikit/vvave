import QtQuick 2.10
import QtQuick.Controls 2.10
import QtQuick.Layouts 1.3

import "../view_models/BabeGrid"
import "../view_models/BabeTable"

import "../db/Queries.js" as Q
import "../utils/Help.js" as H
import org.kde.kirigami 2.6 as Kirigami
import org.kde.mauikit 1.0 as Maui
import TracksList 1.0
import AlbumsList 1.0

BabeGrid
{
    id: albumsViewGrid

    property string currentAlbum: ""
    property string currentArtist: ""

    property var tracks: []

    property alias table : albumsViewTable
    property alias listModel : albumsViewTable.listModel
    //    property alias tagBar : tagBar

    signal rowClicked(var track)
    signal playTrack(var track)
    signal queueTrack(var track)
    signal appendTrack(var track)

    signal appendAll(string album, string artist)
    signal playAll(string album, string artist)
    //    signal albumCoverClicked(string album, string artist)
    signal albumCoverPressedAndHold(string album, string artist)

    visible: true
    //        topPadding: Maui.Style.space.large
    onAlbumCoverPressed: albumCoverPressedAndHold(album, artist)
    headBar.visible: false
    //    headBar.rightContent: Kirigami.ActionToolBar
    //    {
    //        Layout.fillWidth: true
    //        actions:   [
    //            Kirigami.Action
    //        {
    //            id: sortBtn
    //            icon.name: "view-sort"
    //                text: qsTr("Sort")


    //                    Kirigami.Action
    //                {
    //                    text: qsTr("Artist")
    //                    checkable: true
    //                    checked: list.sortBy === Albums.ARTIST
    //                    onTriggered: list.sortBy = Albums.ARTIST
    //                }

    //                Kirigami.Action
    //                {
    //                    text: qsTr("Album")
    //                    checkable: true
    //                    checked: list.sortBy === Albums.ALBUM
    //                    onTriggered: list.sortBy = Albums.ALBUM
    //                }

    //                Kirigami.Action
    //                {
    //                    text: qsTr("Release date")
    //                    checkable: true
    //                    checked: list.sortBy === Albums.RELEASEDATE
    //                    onTriggered: list.sortBy = Albums.RELEASEDATE
    //                }

    //                Kirigami.Action
    //                {
    //                    text: qsTr("Add date")
    //                    checkable: true
    //                    checked: list.sortBy === Albums.ADDDATE
    //                    onTriggered: list.sortBy = Albums.ADDDATE
    //                }
    //            }
    //    ]
    //    }

    //    headBar.rightContent: [

    //        ToolButton
    //        {
    //            id: appendBtn
    //            visible: headBar.visible && albumsViewGrid.count > 0
    //            anim : true
    //            icon.name : "media-playlist-append"//"media-repeat-track-amarok"
    //            onClicked: appendAll()
    //        }
    //    ]

    Maui.Dialog
    {
        id: albumDialog
        parent: parent
        maxWidth: Maui.Style.unit * 600
        maxHeight: Math.min(Maui.Style.unit * 600, albumsViewTable.listView.contentHeight + albumsViewTable.headBar.height + (Maui.Style.space.huge*2))
        widthHint: 0.9
        heightHint: 0.9
        defaultButtons: false
        page.padding: 0

        ColumnLayout
        {
            id: albumFilter
            anchors.fill: parent
            spacing: 0

            BabeTable
            {
                id: albumsViewTable
                Layout.fillHeight: true
                Layout.fillWidth: true
                trackNumberVisible: true
                headBar.visible: true
                coverArtVisible: true
                focus: true
                list.sortBy: Tracks.TRACK
                holder.emoji: "qrc:/assets/dialog-information.svg"
                holder.isMask: false
                holder.title : "Oops!"
                holder.body: "This list is empty"
                holder.emojiSize: Maui.Style.iconSizes.huge

                onRowClicked:
                {
                    albumsViewGrid.rowClicked(listModel.get(index))
                }

                onQuickPlayTrack:
                {
                    albumsViewGrid.playTrack(listModel.get(index))
                }

                onQueueTrack:
                {
                    albumsViewGrid.queueTrack(listModel.get(index))
                }

                onAppendTrack:
                {
                    albumsViewGrid.appendTrack(listModel.get(index))
                }

                onPlayAll:
                {
                    albumDialog.close()
                    albumsViewGrid.playAll(currentAlbum, currentArtist)
                }

                onAppendAll:
                {
                    albumDialog.close()
                    albumsViewGrid.appendAll(currentAlbum, currentArtist)
                }
            }

            //            Maui.TagsBar
            //            {
            //                id: tagBar
            //                visible:false
            //                Layout.fillWidth: true
            //                allowEditMode: false
            //                onTagClicked: H.searchFor("tag:"+tag)
            //            }
        }
    }

    function populateTable(album, artist)
    {
        console.log("PAPULATE ALBUMS VIEW")
        albumDialog.open()

        var query = ""
        var tagq = ""

        currentAlbum = album === undefined ? "" : album
        currentArtist= artist

        if(album && artist)
        {
            query = Q.GET.albumTracks_.arg(album)
            query = query.arg(artist)
            albumsViewTable.title = album
            tagq = Q.GET.albumTags_.arg(album)

        }else if(artist && album === undefined)
        {
            query = Q.GET.artistTracks_.arg(artist)
            albumsViewTable.title = artist
            tagq = Q.GET.artistTags_.arg(artist)
        }

        albumsViewTable.list.query = query

        /*dunoooo*/
        //        if(tracks.length > 0)
        //        {
        //            tagq = tagq.arg(artist)
        //            var tags = bae.get(tagq)
        //            console.log(tagq, "TAGS", tags)
        //            tagBar.populate(tags)
        //        }
    }

    function filter(tracks)
    {
        var matches = []

        for(var i = 0; i<tracks.length; i++)
            matches.push(find(tracks[i].album))

        for(var j = 0 ; j < albumsViewGrid.gridModel.count; j++)
            albumsViewGrid.gridModel.remove(j,1)


        //        for(var match in matches)
        //        {
        //            albumsViewGrid.gridModel.get(match).hide = true
        //            console.log(match)
        //        }
    }

    function find(query)
    {
        var indexes = []
        for(var i = 0 ; i < albumsViewGrid.gridModel.count; i++)
            if(albumsViewGrid.gridModel.get(i).album.includes(query))
                indexes.push(i)

    }
}

