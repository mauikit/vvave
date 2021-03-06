import QtQuick.Controls 2.14
import QtQuick 2.14
import QtQuick.Layouts 1.3

import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.2 as Maui

import org.maui.vvave 1.0

import ".."

Maui.AltBrowser
{
    id: control
    property int albumCoverSize: 130
    property int albumCoverRadius :  Maui.Style.radiusV

    property alias list: _albumsList
    property alias listModel: _albumsModel

    readonly property string prefix : list.query === Albums.ALBUMS ? "album" : "artist"

    readonly property int count: currentView.count

    signal albumCoverClicked(string album, string artist)

    Kirigami.Theme.colorSet: Kirigami.Theme.View
    Kirigami.Theme.inherit: false

    headBar.visible: true
    headerBackground.color: "transparent"

    headBar.middleContent: Maui.TextField
    {
        Layout.fillWidth: true
        placeholderText: i18n("Filter")
        onAccepted: _albumsModel.filter = text
        onCleared: _albumsModel.filter = ""
    }

    viewType: control.width > Kirigami.Units.gridUnit * 25 ? Maui.AltBrowser.ViewType.Grid : Maui.AltBrowser.ViewType.List

    gridView.itemSize: albumCoverSize
    holder.visible: count === 0

    model: Maui.BaseModel
    {
        id: _albumsModel
        recursiveFilteringEnabled: true
        sortCaseSensitivity: Qt.CaseInsensitive
        filterCaseSensitivity: Qt.CaseInsensitive
        list: Albums
        {
            id: _albumsList
        }
    }

    listDelegate: Maui.ItemDelegate
    {
        isCurrentItem: ListView.isCurrentItem
        width: ListView.view.width
        height: Maui.Style.rowHeight * 1.8


        Maui.ListItemTemplate
        {
            anchors.fill: parent
            spacing: Maui.Style.space.medium
            label1.text: model.album ? model.album : model.artist
            label2.text: model.artist && model.album ? model.artist : ""
            imageSource: "image://artwork/%1:".arg(control.prefix)+( control.prefix === "album" ? model.artist+":"+model.album : model.artist)
            iconSizeHint: height * 0.9
            leftMargin: 0
        }

        onClicked:
        {
            control.currentIndex = index
            if(Maui.Handy.singleClick)
            {
                albumCoverClicked(model.album, model.artist)
            }
        }

        onDoubleClicked:
        {
            control.currentIndex = index
            if(!Maui.Handy.singleClick)
            {
                albumCoverClicked(model.album, model.artist)
            }
        }
    }

    gridDelegate: Item
    {
        id: _albumDelegate
        height: control.gridView.cellHeight
        width: control.gridView.cellWidth

        property bool isCurrentItem: GridView.isCurrentItem

        BabeAlbum
        {
            id: albumDelegate
            anchors.centerIn: parent
            albumRadius: albumCoverRadius
            height: control.gridView.itemSize - Maui.Style.space.small
            width: height
            isCurrentItem: parent.isCurrentItem

            label1.text: model.album ? model.album : model.artist
            label2.text: model.artist && model.album ? model.artist : ""
            image.source: "image://artwork/%1:".arg(control.prefix)+( control.prefix === "album" ? model.artist+":"+model.album : model.artist)

            onClicked:
            {
                control.currentIndex = index
                if(Maui.Handy.singleClick)
                {
                    albumCoverClicked(model.album, model.artist)
                }
            }

            onDoubleClicked:
            {
                control.currentIndex = index
                if(!Maui.Handy.singleClick)
                {
                    albumCoverClicked(model.album, model.artist)
                }
            }
        }
    }
}

