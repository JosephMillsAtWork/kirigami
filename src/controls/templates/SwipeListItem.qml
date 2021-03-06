/*
 *   Copyright 2010 Marco Martin <notmart@gmail.com>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU Library General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  2.010-1301, USA.
 */

import QtQuick 2.5
import QtQuick.Layouts 1.2
import QtQuick.Controls 1.0 as Controls
import QtQuick.Controls.Private 1.0
import org.kde.kirigami 1.0
import "../private"

/**
 * An item delegate Intended to support extra actions obtainable
 * by uncovering them by dragging away the item with the handle
 * This acts as a container for normal list items.
 * Any subclass of AbstractListItem can be assigned as the contentItem property.
 * @code
 * ListView {
 *     model: myModel
 *     delegate: SwipeListItem {
 *         Label {
 *             text: model.text
 *         }
 *         actions: [
 *              Action {
 *                  iconName: "document-decrypt"
 *                  onTriggered: print("Action 1 clicked")
 *              },
 *              Action {
 *                  iconName: model.action2Icon
 *                  onTriggered: //do something
 *              }
 *         ]
 *     }
 * 
 * }
 * @endcode
 *
 * @inherit QtQuick.Item
 */
Item {
    id: listItem

//BEGIN properties
    /**
     * contentItem: Item
     * This property holds the visual content item.
     *
     * Note: The content item is automatically resized inside the
     * padding of the control.
     */
     default property Item contentItem

    /**
     * supportsMouseEvents: bool
     * Holds if the item emits signals related to mouse interaction.
     *TODO: remove
     * The default value is false.
     */
    property alias supportsMouseEvents: itemMouse.enabled

    /**
     * clicked: signal
     * This signal is emitted when there is a click.
     *
     * This is disabled by default, set enabled to true to use it.
     * @see enabled
     */
    signal clicked


    /**
     * pressAndHold: signal
     * The user pressed the item with the mouse and didn't release it for a
     * certain amount of time.
     *
     * This is disabled by default, set enabled to true to use it.
     * @see enabled
     */
    signal pressAndHold

    /**
     * checked: bool
     * If true makes the list item look as checked or pressed. It has to be set
     * from the code, it won't change by itself.
     */
    property bool checked: false

    /**
     * pressed: bool
     * True when the user is pressing the mouse over the list item and
     * supportsMouseEvents is set to true
     */
    property alias pressed: itemMouse.pressed

    /**
     * containsMouse: bool
     * True when the user hover the mouse over the list item
     * NOTE: on mobile touch devices this will be true only when pressed is also true
     */
    property alias containsMouse: itemMouse.containsMouse

    /**
     * sectionDelegate: bool
     * If true the item will be a delegate for a section, so will look like a
     * "title" for the items under it.
     */
    property bool sectionDelegate: false

    /**
     * separatorVisible: bool
     * True if the separator between items is visible
     * default: true
     */
    property bool separatorVisible: true

    /**
     * actions: list<Action>
     * Defines the actions for the list item: at most 4 buttons will
     * contain the actions for the item, that can be revealed by
     * sliding away the list item.
     */
    property list<Action> actions


    /**
     * position: real
     * This property holds the position of the dragged list item relative to its
     * final destination (just like the Drawer). That is, the position
     * will be 0 when the list item is fully closed, and 1 when fully open.
     */
    property real position: 0

    /**
     * background: Item
     * This property holds the background item.
     *
     * Note: If the background item has no explicit size specified,
     * it automatically follows the control's size.
     * In most cases, there is no need to specify width or
     * height for a background item.
     */
    property Item background

    /**
     * textColor: color
     * Color for the text in the item
     *
     * Note: if custom text elements are inserted in an AbstractListItem,
     * their color proprty will ahve to be manually binded with this property
     */
    property color textColor: Theme.viewTextColor

    /**
     * backgroundColor: color
     * Color for the background of the item
     */
    property color backgroundColor: Theme.viewBackgroundColor

    /**
     * activeTextColor: color
     * Color for the text in the item when pressed or selected
     * It is advised to leave the default value (Theme.highlightedTextColor)
     *
     * Note: if custom text elements are inserted in an AbstractListItem,
     * their color proprty will ahve to be manually binded with this property
     */
    property color activeTextColor: Theme.highlightedTextColor

    /**
     * activeBackgroundColor: color
     * Color for the background of the item when pressed or selected
     * It is advised to leave the default value (Theme.highlightColor)
     */
    property color activeBackgroundColor: Theme.highlightColor

    Item {
        id: behindItem
        parent: listItem
        anchors {
            fill: parent
            leftMargin: height
        }
        Rectangle {
            id: shadowHolder
            color: Theme.backgroundColor
            anchors.fill: parent
        }
        EdgeShadow {
            edge: Qt.TopEdge
            anchors {
                right: parent.right
                left: parent.left
                top: parent.top
            }
        }
        EdgeShadow {
            edge: Qt.LeftEdge
            x: behindItem.width - (behindItem.width * listItem.position)
            anchors {
                top: parent.top
                bottom: parent.bottom
            }
        }
    }

    implicitWidth: parent ? parent.width : contentItem.width + paddingItem.anchors.margins * 2
    implicitHeight: contentItem.height + Units.smallSpacing * 5
//END properties

//BEGIN signal handlers
    onBackgroundChanged: {
        background.parent = itemMouse;
        background.anchors.fill = itemMouse;
        background.z = 0;
    }

    onContentItemChanged: {
        contentItem.parent = paddingItem
        contentItem.z = 0;
    }

    Component.onCompleted: {

        if (background) {
            background.parent = itemMouse;
            background.z = 0;
        }

        contentItem.parent = itemMouse
        contentItem.z = 1;
    }

    onPositionChanged: {
        if (!mainFlickable.loopCheck && !handleMouse.pressed && !mainFlickable.flicking &&
            !mainFlickable.dragging && !positionAnimation.running) {
            mainFlickable.contentX = (listItem.width-listItem.height) * mainFlickable.internalPosition;
        }
    }
//END signal handlers

//BEGIN UI implementation
    Row {
        id: actionsLayout
        z: 1
        anchors {
            right: parent.right
            verticalCenter: parent.verticalCenter
            rightMargin: y
        }
        height: Math.min( parent.height / 1.5, Units.iconSizes.medium)
        width: childrenRect.width
        property bool exclusive: false
        property Item checkedButton
        spacing: Units.largeSpacing
        Repeater {
            model: {
                if (listItem.actions.length == 0) {
                    return null;
                } else {
                    return listItem.actions[0].text !== undefined &&
                        listItem.actions[0].trigger !== undefined ?
                            listItem.actions :
                            listItem.actions[0];
                }
            }
            delegate: Icon {
                height: actionsLayout.height
                width: height
                source: modelData.iconName
                enabled: (modelData && modelData.enabled !== undefined) ? modelData.enabled : true;
                visible: (modelData && modelData.visible !== undefined) ? modelData.visible : true;
                MouseArea {
                    anchors {
                        fill: parent;
                        margins: -Units.smallSpacing;
                    }
                    enabled: (modelData && modelData.enabled !== undefined) ? modelData.enabled : true;
                    onClicked: {
                        if (modelData && modelData.trigger !== undefined) {
                            modelData.trigger();
                        // assume the model is a list of QAction or Action
                        } else if (toolbar.model.length > index) {
                            toolbar.model[index].trigger();
                        } else {
                            console.log("Don't know how to trigger the action")
                        }
                        positionAnimation.to = 0;
                        positionAnimation.running = true;
                    }
                }
            }
        }
    }

    PropertyAnimation {
        id: positionAnimation
        target: mainFlickable
        properties: "contentX"
        duration: Units.longDuration
        easing.type: Easing.InOutQuad
    }

    Flickable {
        id: mainFlickable
        z: 2
        interactive: false
        boundsBehavior: Flickable.StopAtBounds
        anchors.fill: parent
        contentWidth: mainItem.width
        contentHeight: height
        onFlickEnded: {
            if (contentX > width / 2) {
                positionAnimation.to = width - height;
            } else {
                positionAnimation.to = 0;
            }
            positionAnimation.running = true;
        }
        readonly property real internalPosition:  (mainFlickable.contentX/(listItem.width-listItem.height));
        property bool loopCheck: false
        onInternalPositionChanged: {
            if (!loopCheck) {
                loopCheck = true;
                listItem.position = internalPosition;
                loopCheck = false;
            }
        }

        Item {
            id: mainItem
            width: (mainFlickable.width * 2) - height 
            height: mainFlickable.height
            MouseArea {
                id: itemMouse
                anchors {
                    left: parent.left
                    top: parent.top
                    bottom: parent.bottom
                }
                hoverEnabled: !Settings.isMobile
                width: mainFlickable.width
                onClicked: listItem.clicked()
                onPressAndHold: listItem.pressAndHold()

                Item {
                    id: paddingItem
                    anchors {
                        fill: parent
                        margins: Units.smallSpacing
                    }
                }
            }

            MouseArea {
                id: handleMouse
                anchors {
                    left: itemMouse.right
                    top: parent.top
                    bottom: parent.bottom
                    leftMargin:  -height
                }
                preventStealing: true
                width: mainFlickable.width - actionsLayout.width - actionsLayout.anchors.rightMargin
                property var downTimestamp;
                property int startX
                property int startMouseX

                onClicked: {
                    if (Math.abs(startX - mainFlickable.contentX) > Units.gridUnit ||
                        Math.abs(startMouseX - mouse.x) > Units.gridUnit) {
                        return;
                    }
                    if (mainFlickable.contentX > mainFlickable.width / 2) {
                        positionAnimation.to = 0;
                    } else {
                        positionAnimation.to = mainFlickable.width - mainFlickable.height;
                    }
                    positionAnimation.running = true;
                }
                onPressed: {
                    downTimestamp = (new Date()).getTime();
                    startX = mainFlickable.contentX;
                    startMouseX = mouse.x;
                }
                onPositionChanged: {
                    mainFlickable.contentX = Math.max(0, Math.min(mainFlickable.width - height, mainFlickable.contentX + (startMouseX - mouse.x)))
                }
                onReleased: {
                    var speed = ((startX - mainFlickable.contentX) / ((new Date()).getTime() - downTimestamp) * 1000);
                    mainFlickable.flick(speed, 0);
                }
                Icon {
                    id: handleIcon
                    anchors.verticalCenter: parent.verticalCenter
                    selected: listItem.checked || (listItem.pressed && !listItem.checked && !listItem.sectionDelegate)
                    width: Units.iconSizes.smallMedium
                    height: width
                    x: y
                    source: (mainFlickable.contentX > mainFlickable.width / 2) ? "handle-right" : "handle-left"
                }
            }
        }
    }
//END UI implementation

    Accessible.role: Accessible.ListItem
}
