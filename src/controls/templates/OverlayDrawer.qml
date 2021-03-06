/*
 *   Copyright 2012 Marco Martin <mart@kde.org>
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
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import QtQuick 2.1
import org.kde.kirigami 1.0
import "private"

/**
 * Overlay Drawers are used to expose additional UI elements needed for
 * small secondary tasks for which the main UI elements are not needed.
 * For example in Okular Active, an Overlay Drawer is used to display
 * thumbnails of all pages within a document along with a search field.
 * This is used for the distinct task of navigating to another page.
 *
 */
AbstractDrawer {
    id: root

    z: modal ? (opened ? 100 : 99 ): 98

//BEGIN Properties
    /**
     * page: Item
     * It's the default property. it's the main content of the drawer page,
     * the part that is always shown
     */
    default property alias page: mainPage.data

    /**
     * contentItem: Item
     * It's the part that can be pulled in and out, will act as a sidebar.
     */
    property Item contentItem

    /**
     * background: Item
     * This property holds the background item.
     * Note: the background will be automatically sized as the whole control
     */
    property Item background

    /**
     * opened: bool
     * If true the drawer is open showing the contents of the "drawer"
     * component.
     */
    property alias opened: mainFlickable.open

    /**
     * edge: enumeration
     * This property holds the edge of the content item at which the drawer
     * will open from.
     * The acceptable values are:
     * Qt.TopEdge: The top edge of the content item.
     * Qt.LeftEdge: The left edge of the content item (default).
     * Qt.RightEdge: The right edge of the content item.
     * Qt.BottomEdge: The bottom edge of the content item.
     */
    property int edge: Qt.LeftEdge

    /**
     * position: real
     * This property holds the position of the drawer relative to its
     * final destination. That is, the position will be 0 when the
     * drawer is fully closed, and 1 when fully open.
     */
    property real position: 0

    /**
     * handleVisible: bool
     * If true, a little handle will be visible to make opening the drawer easier
     * Currently supported only on left and right drawers
     */
    property bool handleVisible: typeof(applicationWindow)===typeof(Function) && applicationWindow() ? applicationWindow().controlsVisible : true

    /**
     * leftPadding: int
     * default contents padding at left
     */
    property int leftPadding: Units.smallSpacing

    /**
     * topPadding: int
     * default contents padding at top
     */
    property int topPadding: Units.smallSpacing

    /**
     * rightPadding: int
     * default contents padding at right
     */
    property int rightPadding: Units.smallSpacing

    /**
     * bottomPadding: int
     * default contents padding at bottom
     */
    property int bottomPadding: Units.smallSpacing

    /**
     * modal: bool
     * If true the drawer will be an overlay of the main content,
     * obscuring it and blocking input.
     * If false, the drawer will look like a sidebar, with the main content
     * application still usable.
     * It is recomended to use modal on mobile devices and not modal on desktop
     * devices.
     * Default is true
     */
    //property bool modal: true
//END Properties


//BEGIN Methods
    /**
     * open: function
     * This method opens the drawer, animating the movement if a
     * valid animation has been set.
     */
    function open () {
        mainAnim.to = 0;
        switch (root.edge) {
        case Qt.RightEdge:
            mainAnim.to = drawerPage.width;
            break;
        case Qt.BottomEdge:
            mainAnim.to = drawerPage.height;
            break;
        case Qt.LeftEdge:
        case Qt.TopEdge:
        default:
            mainAnim.to = 0;
            break;
        }
        mainAnim.running = true;
        mainFlickable.open = true;
    }

    /**
     * close: function
     * This method closes the drawer, animating the movement if a
     * valid animation has been set.
     */
    function close () {
        switch (root.edge) {
        case Qt.RightEdge:
        case Qt.BottomEdge:
            mainAnim.to = 0;
            break;
        case Qt.LeftEdge:
            mainAnim.to = drawerPage.width;
            break;
        case Qt.TopEdge:
            mainAnim.to = drawerPage.height;
            break;
        }
        mainAnim.running = true;
        mainFlickable.open = false;
    }

    /**
     * clicked: signal
     * This signal is emitted when the drawer is clicked.
     */
//END Methods

//BEGIN Signal handlers
    onBackgroundChanged: {
        background.z = 1;
        background.parent = mainItem;
        background.anchors.fill = drawerPage;
    }

    onPositionChanged: {
        if (!mainFlickable.loopCheck) {
            mainFlickable.loopCheck = true;
            if (!mainFlickable.flicking && !mainFlickable.dragging && !mainAnim.running) {
                switch (root.edge) {
                case Qt.RightEdge:
                    mainFlickable.contentX = drawerPage.width * position;
                    break;
                case Qt.LeftEdge:
                    mainFlickable.contentX = drawerPage.width * (1-position);
                    break;
                case Qt.BottomEdge:
                    mainFlickable.contentY = drawerPage.height * position;
                    break;
                }
            }
            mainFlickable.loopCheck = false;
        }
    }
    onContentItemChanged: {
        contentItem.parent = drawerPage
        contentItem.anchors.fill = drawerPage
        if (contentItem.flickableItem !== undefined) {
            contentItem.anchors.topMargin = 0;
            contentItem.anchors.leftMargin = 0;
            contentItem.anchors.bottomMargin = 0;
            contentItem.anchors.rightMargin = 0;
        } else {
            contentItem.anchors.topMargin = root.topPadding;
            contentItem.anchors.leftMargin = root.leftPadding;
            contentItem.anchors.bottomMargin = root.bottomPadding;
            contentItem.anchors.rightMargin = root.rightPadding;
        }
    }
//END Signal handlers

    Item {
        id: mainPage
        anchors.fill: parent
        onChildrenChanged: mainPage.children[0].anchors.fill = mainPage
    }

    Rectangle {
        anchors.fill: parent
        color: "black"
        opacity: 0.6 * mainFlickable.internalPosition
        visible: root.modal
    }


    //NOTE: it's a PropertyAnimation instead of a NumberAnimation because
    //NumberAnimation doesn't have NOTIFY signal on to property
    PropertyAnimation {
        id: mainAnim
        target: mainFlickable
        properties: (root.edge == Qt.RightEdge || root.edge == Qt.LeftEdge) ? "contentX" : "contentY"
        duration: Units.longDuration
        easing.type: mainAnim.to > 0 ? Easing.InQuad : Easing.OutQuad
    }

    MouseArea {
        id: edgeMouse
        anchors {
            right: root.edge == Qt.LeftEdge ? undefined : parent.right
            left: root.edge == Qt.RightEdge ? undefined : parent.left
            top: root.edge == Qt.BottomEdge ? undefined : parent.top
            bottom: root.edge == Qt.TopEdge ? undefined : parent.bottom
        }
        z: 99
        width: Units.smallSpacing * 3
        height: Units.smallSpacing * 3
        property int startMouseX
        property real oldMouseX
        property int startMouseY
        property real oldMouseY
        property bool startDragging: false

        function managePress(mouse) {
            if (drawerPage.children.length == 0) {
                mouse.accepted = false;
                return;
            }

            speedSampler.restart();
            mouse.accepted = true;
            oldMouseX = startMouseX = mouse.x;
            oldMouseY = startMouseY = mouse.y;
            startDragging = false;
        }
        onPressed: {
            managePress(mouse)
        }

        onPositionChanged: {
            if (!root.contentItem) {
                mouse.accepted = false;
                return;
            }

            if (Math.abs(mouse.x - startMouseX) > root.width / 5 ||
                Math.abs(mouse.y - startMouseY) > root.height / 5) {
                startDragging = true;
            }
            if (startDragging) {
                switch (root.edge) {
                case Qt.RightEdge:
                    mainFlickable.contentX = Math.min(mainItem.width - root.width, mainFlickable.contentX + oldMouseX - mouse.x);
                    break;
                case Qt.LeftEdge:
                    mainFlickable.contentX = Math.max(0, mainFlickable.contentX + oldMouseX - mouse.x);
                    break;
                case Qt.BottomEdge:
                    mainFlickable.contentY = Math.min(mainItem.height - root.height, mainFlickable.contentY + oldMouseY - mouse.y);
                    break;
                case Qt.TopEdge:
                    mainFlickable.contentY = Math.max(0, mainFlickable.contentY + oldMouseY - mouse.y);
                    break;
                }
            }
            oldMouseX = mouse.x;
            oldMouseY = mouse.y;
        }
        onReleased: {
            if (!startDragging) {
                return;
            }
            speedSampler.running = false;
            if (speedSampler.speed != 0) {
                if (root.edge == Qt.RightEdge || root.edge == Qt.LeftEdge) {
                    mainFlickable.flick(speedSampler.speed, 0);
                } else {
                    mainFlickable.flick(0, speedSampler.speed);
                }
            } else {
                if (mainFlickable.internalPosition > 0.5) {
                    root.open();
                } else {
                    root.close();
                }
            }
        }
    }

    MouseArea {
        id: handleMouseArea
        z:999
        anchors {
            right: root.edge == Qt.LeftEdge ? undefined : parent.right
            left: root.edge == Qt.RightEdge ? undefined : parent.left
            bottom: parent.bottom
            leftMargin: root.opened ? drawerPage.width : 0
            rightMargin: root.opened ? drawerPage.width : 0
        }
        visible: root.handleVisible && (root.edge == Qt.LeftEdge || root.edge == Qt.RightEdge)
        width: Units.iconSizes.medium
        height: width
        onPressed: edgeMouse.managePress(mouse);
        onPositionChanged: edgeMouse.positionChanged(mouse);
        onReleased: edgeMouse.released(mouse);
        onClicked: root.opened ? root.close() : root.open();
    }

    Timer {
        id: speedSampler
        interval: 100
        repeat: true
        property real speed
        property real oldContentX
        property real oldContentY
        onTriggered: {
            if (root.edge == Qt.RightEdge || root.edge == Qt.LeftEdge) {
                speed = (mainFlickable.contentX - oldContentX) * 10;
                oldContentX = mainFlickable.contentX;
            } else {
                speed = (mainFlickable.contentY - oldContentY) * 10;
                oldContentY = mainFlickable.contentY;
            }
        }
        onRunningChanged: {
            if (running) {
                speed = 0;
                oldContentX = mainFlickable.contentX;
                oldContentY = mainFlickable.contentY;
            } else {
                if (root.edge == Qt.RightEdge || root.edge == Qt.LeftEdge) {
                    speed = (oldContentX - mainFlickable.contentX) * 10;
                } else {
                    speed = (oldContentY - mainFlickable.contentY) * 10;
                }
            }
        }
    }

    MouseArea {
        id: mainMouseArea
        anchors.fill: parent
        drag.filterChildren: true
        onClicked: {
            if ((root.edge == Qt.LeftEdge && mouse.x < drawerPage.width) ||
                (root.edge == Qt.RightEdge && mouse.x > drawerPage.x - mainFlickable.contentX) ||
                (root.edge == Qt.TopEdge && mouse.y < drawerPage.height) ||
                (root.edge == Qt.BottomEdge && mouse.y > drawerPage.y - mainFlickable.contentY)) {
                return;
            }
            root.clicked();
            root.close();
        }
        enabled: (root.edge == Qt.LeftEdge && !mainFlickable.atXEnd) ||
                 (root.edge == Qt.RightEdge && !mainFlickable.atXBeginning) ||
                 (root.edge == Qt.TopEdge && !mainFlickable.atYEnd) ||
                 (root.edge == Qt.BottomEdge && !mainFlickable.atYBeginning) ||
                 mainFlickable.moving

        Flickable {
            id: mainFlickable
            property bool open
            anchors.fill: parent
            interactive: root.modal
            onOpenChanged: {
                if (open) {
                    root.open();
                    Qt.inputMethod.hide();
                } else {
                    root.close();
                }
            }
            enabled: parent.enabled
            flickableDirection: root.edge == Qt.LeftEdge || root.edge == Qt.RightEdge ? Flickable.HorizontalFlick : Flickable.VerticalFlick
            contentWidth: mainItem.width
            contentHeight: mainItem.height
            boundsBehavior: Flickable.StopAtBounds
            readonly property real internalPosition: {
                switch (root.edge) {
                case Qt.RightEdge:
                    return mainFlickable.contentX/drawerPage.width;
                case Qt.LeftEdge:
                    return 1 - (mainFlickable.contentX/drawerPage.width);
                case Qt.BottomEdge:
                    return mainFlickable.contentY/drawerPage.height;
                case Qt.TopEdge:
                    return 1 - (mainFlickable.contentY/drawerPage.height);
                }
            }
            property bool loopCheck: false
            onInternalPositionChanged: {
                if (!loopCheck) {
                    loopCheck = true;
                    root.position = internalPosition;
                    loopCheck = false;
                }
            }

            onFlickingChanged: {
                if (!flicking) {
                    if (internalPosition > 0.5) {
                        root.open();
                    } else {
                        root.close();
                    }
                }
            }
            onMovingChanged: {
                if (!moving) {
                    flickingChanged();
                }
            }

            Item {
                id: mainItem
                width: root.width + ((root.edge == Qt.RightEdge || root.edge == Qt.LeftEdge) ? drawerPage.width : 0)
                height: root.height + ((root.edge == Qt.TopEdge || root.edge == Qt.BottomEdge) ? drawerPage.height : 0)
                onWidthChanged: {
                    if (root.edge == Qt.LeftEdge) {
                        if (root.opened) {
                            mainFlickable.contentX = 0;
                        } else {
                            mainFlickable.contentX = drawerPage.width;
                        }
                    }
                }
                onHeightChanged: {
                    if (root.edge == Qt.TopEdge) {
                        mainFlickable.contentY = drawerPage.Height;
                    }
                }


                Item {
                    id: drawerPage
                    z: 3
                    anchors {
                        left: root.edge != Qt.RightEdge ? parent.left : undefined
                        right: root.edge != Qt.LeftEdge ? parent.right : undefined
                        top: root.edge != Qt.BottomEdge ? parent.top : undefined
                        bottom: root.edge != Qt.TopEdge ? parent.bottom : undefined
                    }

                    clip: true
                    width: root.contentItem ? Math.min(root.contentItem.implicitWidth, root.width * 0.7) : 0
                    height: root.contentItem ? Math.min(root.contentItem.implicitHeight, root.height * 0.7) : 0
                }
            }
        }
    }
}
