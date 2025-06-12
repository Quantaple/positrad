import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
// Source: https://github.com/mastercomdev/QtToastify
// Edited because I think it was coded for Qt5???
Item {
    id: root
    anchors.fill: parent
    parent: Overlay.overlay

    //Top-Left
    ColumnLayout{
        id: topLeftColumn
        x: 12
        y: 0
        width: 300
        spacing: 0
    }

    // Causes errors because we don't know what toprow is
    //Top-Center
    ColumnLayout{
        id: topCenterColumn
        x: width / 2
        y: root.y //y: toprow.y + toprow.height + 1
        width: root.width / 2
        spacing: 0
    }

    //Top-Right
    ColumnLayout{
        id: topRightColumn
        x: root.width-width-12
        y: 0
        width: 300
        spacing: 0
    }

    //Bottom-Left
    ColumnLayout{
        id: bottomLeftColumn
        x: 12
        y: root.height-height-12
        width: 300
        spacing: 0
    }

    //Bottom-Center
    ColumnLayout{
        id: bottomCenterColumn
        x: width / 2
        y: root.height-height-12
        width: root.width / 2
        spacing: 0
    }

    //Bottom-Right
    ColumnLayout{
        id: bottomRightColumn
        x: root.width-width-12
        y: root.height-height-12
        width: 300
        spacing: 0
    }

    function createMessage( message, options = {} ){
        try{
            if(!message){
                throw new Error("Invalid message")
            }

            const { type, position, theme, closeOnClick, autoClose, hideProgressBar, clickAction } = options;
            var component = Qt.createComponent("ToastifyDelegate.qml") //("qrc:/qml/Toastify/ToastifyDelegate.qml")
            if (component.status == Component.Ready) {
                var messageContainer = component.createObject(determinePosition(position), {
                                                                message,
                                                                type,
                                                                position,
                                                                theme,
                                                                closeOnClick,
                                                                autoClose,
                                                                hideProgressBar,
                                                                clickAction
                                                            });
                return messageContainer;
            } else {
                component.statusChanged.connect(() => {
                    if (component.status == Component.Ready) {
                        var messageContainer = component.createObject(determinePosition(position), {
                                                                        message,
                                                                        type,
                                                                        position,
                                                                        theme,
                                                                        closeOnClick,
                                                                        autoClose,
                                                                        hideProgressBar,
                                                                        clickAction
                                                                    });
                        return messageContainer;
                    } else if (component.status == Component.Error) {
                        console.log("Error loading component:", component.errorString())
                    }
                })
            }
        }
        catch(err){
            console.error(err || "Failed to create toast")
        }
    }

    function determinePosition(position){
        switch(position){
        case Qt.TopLeftCorner:
            return topLeftColumn;
        case Qt.TopEdge:
            return topCenterColumn;
        case Qt.TopRightCorner:
            return topRightColumn;
        case Qt.BottomLeftCorner:
            return bottomLeftColumn;
        case Qt.BottomEdge:
            return bottomCenterColumn;
        case Qt.BottomRightCorner:
            return bottomRightColumn;
        case undefined:
            return topLeftColumn;
        default:
            console.log("Invalid position")
        }
    }
}
