import QtQuick 2.0
import QtQuick.Controls 2.10
import org.kde.kirigami 2.2 as Kirigami
import org.kde.mauikit 1.0 as Maui
import QtQuick.Layouts 1.3

import "../../view_models"
import "../../utils/Player.js" as Player
import "../../db/Queries.js" as Q

Maui.Dialog
{
    title: "Add "+ tracks.length +" tracks to..."

    property var tracks : []
    maxHeight: 400 * Maui.Style.unit
    page.padding: Maui.Style.space.medium

    ColumnLayout
    {
        anchors.fill: parent

        BabeList
        {
            id: dialogList

            Layout.fillHeight: true
            Layout.fillWidth: true

            headBar.visible: false
            holder.title: qsTr("There's not playlists")
            holder.body: qsTr("Create a new one and start adding tracks to it")

            model: Maui.BaseModel
            {
                list: playlistsList
            }

            delegate: Maui.ListDelegate
            {
                id: delegate
                label: model.playlist

                Connections
                {
                    target: delegate
                    onClicked: dialogList.currentIndex = index
                    onPressAndHold:
                    {
                        dialogList.currentIndex = index
                        insert()
                    }
                }
            }
        }


        Maui.TextField
        {
            Layout.fillWidth: true
            id: newPlaylistField
            color: Kirigami.Theme.textColor
            placeholderText: qsTr("New playlist")
            onAccepted:
            {
                addPlaylist()
                playlistsList.addTrack(dialogList.listView.currentIndex, tracks)
                clear()
            }

            actions.data: ToolButton
            {
                icon.name: "checkbox"
                icon.color: Kirigami.Theme.textColor
                onClicked: addPlaylist()
            }
        }
    }

    onAccepted:
    {
        if(newPlaylistField.text.length)
            addPlaylist()

        insert()
    }

    function insert()
    {
        playlistsList.addTrack(dialogList.listView.currentIndex, tracks)
        close()
    }

    function addPlaylist()
    {
        if (newPlaylistField.text)
        {
            var title = newPlaylistField.text.trim()
            if(playlistsList.insertAt(title, 0))
            {
                dialogList.listView.currentIndex = 0
                dialogList.listView.positionViewAtBeginning()
            }

            newPlaylistField.clear()
        }
    }

}
