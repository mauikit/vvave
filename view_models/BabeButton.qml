import QtQuick 2.9
import QtQuick.Controls 2.2
import "../utils"
import org.kde.kirigami 2.2 as Kirigami

ToolButton
{
    id: babeButton

    property string iconName
    property int iconSize : toolBarIconSize
    property color iconColor: foregroundColor
    readonly property string defaultColor :  foregroundColor

//        icon.name: isMobile ? "" : babeButton.iconName
//        icon.width: isMobile ? 0 : babeButton.iconSize
//    //    icon.height: isMobile ? 0 : babeButton.iconSize
//        icon.color: isMobile  ?  "transparent" : (iconColor || defaultColor)

    Kirigami.Icon
    {
        id: kirigamIcon
        anchors.centerIn: parent
        width: iconSize
        height: iconSize
        visible: !isMobile
        source: isMobile  ? "" : iconName
        color: iconColor || defaultColor

    }

    BabeIcon
    {
        id: babeIcon
        visible: isMobile
        icon: babeButton.iconName
        iconColor: babeButton.iconColor || babeButton.defaultColor
        iconSize: babeButton.iconSize
    }

}

