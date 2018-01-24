import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2
import "../../utils"

ItemDelegate
{
    id: delegateRoot

    width: parent.width
    height: sameAlbum ? 48 : 64
    clip: true
    signal play()
    signal rightClicked()
    signal leftClicked()

    signal artworkCoverClicked()
    signal artworkCoverDoubleClicked()

    readonly property bool sameAlbum :
    {
        if(coverArt)
        {
            if(listModel.get(index-1))
            {
                if(listModel.get(index-1).album === album) true
                else false
            }else false
        }else false
    }

    property string textColor: ListView.isCurrentItem ? bae.hightlightTextColor() : bae.foregroundColor()
    property bool number : false
    property bool quickPlay : true
    property bool coverArt : false

    property bool trackDurationVisible : false
    property bool trackRatingVisible: false
    //    property bool playingIndicator: false
    property string trackMood : art
    property alias trackRating : trackRating

//    NumberAnimation on x
//    {
//        running: ListView.isCurrentItem
//        from: 0; to: 100
//    }

    Rectangle
    {
        anchors.fill: parent
        color:
        {
            if(trackMood.length>0)
                Qt.lighter(trackMood)
            else
                index % 2 === 0 ? bae.midColor() : "transparent"
        }
        opacity: 0.3
    }

    MouseArea
    {
        anchors.fill: parent
        acceptedButtons:  Qt.RightButton
        onClicked:
        {
            if(!root.isMobile && mouse.button === Qt.RightButton)
                rightClicked()
        }
    }

    RowLayout
    {
        id: gridLayout
        anchors.fill: parent
        spacing: 20

        Item
        {
            visible: coverArt

            Layout.fillHeight: true
            width: sameAlbum ? 64 : parent.height

            ToolButton
            {
                visible: !sameAlbum
                height: parent.height
                width: parent.height
                anchors.verticalCenter: parent.verticalCenter

                Image
                {
                    id: artworkCover
                    anchors.fill: parent
                    source:
                    {
                        if(artwork)
                            (artwork.length > 0 && artwork !== "NONE")? "file://"+encodeURIComponent(artwork) : "qrc:/assets/cover.png"
                        else "qrc:/assets/cover.png"
                    }
                    fillMode:  Image.PreserveAspectFit
                    cache: false
                    antialiasing: true
                }

                onDoubleClicked: artworkCoverDoubleClicked()
                onClicked: artworkCoverClicked()
                onPressAndHold: if(root.isMobile) artworkCoverDoubleClicked()

            }
        }

        Item
        {
            visible: quickPlay
            Layout.fillHeight: true
            width: sameAlbum ? 64 : parent.height

            ToolButton
            {
                id: playBtn
                anchors.centerIn: parent

                BabeIcon { icon: "playCircle"; color: textColor }
                onClicked: play()
            }
        }


        Item
        {

            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            Layout.margins: 15
            anchors.verticalCenter: parent.verticalCenter


            GridLayout
            {
                anchors.fill: parent
                rows:2
                columns:3
                //                rowSpacing: 0
                //                columnSpacing: 20

                Label
                {
                    id: trackNumber
                    visible: number
                    width: 16
                    Layout.fillHeight: true
                    Layout.row: 1
                    Layout.column: 1

                    Layout.alignment: Qt.AlignCenter
                    verticalAlignment:  Qt.AlignVCenter

                    text: track
                    font.bold: true
                    elide: Text.ElideRight

                    font.pointSize: 10
                    color: textColor
                }


                Label
                {
                    id: trackTitle

                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.row: 1
                    Layout.column: 2
                    verticalAlignment:  Qt.AlignVCenter
                    text: title
                    font.bold: true
                    elide: Text.ElideRight

                    font.pointSize: 10
                    color: textColor

                }

                Label
                {
                    id: trackInfo
                    visible: coverArt ? !sameAlbum : true
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.row: 2
                    Layout.column: 2
                    Layout.rowSpan: sameAlbum && coverArt ? 2 : 1
                    verticalAlignment:  Qt.AlignVCenter
                    text: artist + " | " + album
                    font.bold: false
                    elide: Text.ElideRight
                    font.pointSize: 9
                    color: textColor

                }


                //        Item
                //        {
                //            Layout.row: 1
                //            Layout.rowSpan: 2
                //            Layout.column: 4
                //            height: 48
                //            width: height
                //            Layout.fillWidth: true
                //            Layout.fillHeight: true
                //            Layout.alignment: Qt.AlignCenter

                //            AnimatedImage
                //            {
                //                id: animation
                //                cache: true
                //                visible: playingIndicator
                //                height: 22
                //                width: 22
                //                horizontalAlignment: Qt.AlignLeft
                //                verticalAlignment:  Qt.AlignVCenter
                //                source: "qrc:/assets/bars.gif"
                //            }
                //        }

                Label
                {
                    id: trackDuration
                    visible: trackDurationVisible
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.row: 1
                    Layout.column: 3
                    horizontalAlignment: Qt.AlignRight
                    verticalAlignment:  Qt.AlignVCenter
                    text: player.transformTime(duration)
                    font.bold: false
                    elide: Text.ElideRight
                    font.pointSize: 8
                    color: textColor
                }

                Label
                {
                    id: trackRating
                    visible: trackRatingVisible
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.row: 2
                    Layout.column: 3
                    horizontalAlignment: Qt.AlignRight
                    verticalAlignment:  Qt.AlignVCenter
                    text: stars
                    font.bold: false
                    elide: Text.ElideRight
                    font.pointSize: 8
                    color: textColor
                }
            }
        }
    }

    function setStars(stars)
    {

        switch (parseInt(stars))
        {
        case 0:
            return  " ";

        case 1:
            return  "\xe2\x98\x86 ";

        case 2:
            return "\xe2\x98\x86 \xe2\x98\x86 ";

        case 3:
            return  "\xe2\x98\x86 \xe2\x98\x86 \xe2\x98\x86 ";

        case 4:
            return  "\xe2\x98\x86 \xe2\x98\x86 \xe2\x98\x86 \xe2\x98\x86 ";

        case 5:
            return "\xe2\x98\x86 \xe2\x98\x86 \xe2\x98\x86 \xe2\x98\x86 \xe2\x98\x86 ";

        default: return "error";
        }
    }
}