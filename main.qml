import QtCore
import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts

Window {
    id: window
    visible: true
    title: qsTr("POSiTrad")
    visibility: Window.Windowed

    minimumWidth: 800
    minimumHeight: 600

    Material.accent: Material.Blue
    Material.primary: Material.Green
    Material.theme: darkMode? Material.Dark : Material.Light

    property bool darkMode: true

    Settings {
        property alias darkMode: window.darkMode
        property alias width: window.width
        property alias height: window.height
    }

    TabBar {
        id: navBar
        anchors.left: parent.left
        anchors.right: parent.right

        TabButton {
            text: qsTr("Items")
            icon.source: "assets/fast_food.svg"
        }

        TabButton {
            text: qsTr("Écrans")
            icon.source: "assets/gridview.svg"
        }

        TabButton {
            text: qsTr("Menus")
            icon.source: "assets/menu_book.svg"
        }

        TabButton {
            text: qsTr("Autres")
            icon.source: "assets/other_admission.svg"
        }

        TabButton {
            text: qsTr("Quitter")
            icon.source: "assets/close.svg"
        }

        TabButton {
            text: qsTr("Paramètres")
            icon.source: "assets/settings.svg"
        }
    }

    StackLayout {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.top: navBar.bottom

        currentIndex: navBar.currentIndex

        Pane { // Items pane
            Row {
                id: itemsToolbar

                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top

                spacing: 10

                Switch {
                    id: showTranslatedSwitch
                    text: qsTr("Afficher items déjà traduits")

                    checked: true
                    onClicked: itemModel.setFilters(showArchivedSwitch.checked, checked)
                }

                Switch {
                    id: showArchivedSwitch
                    text: qsTr("Afficher items archivés")

                    checked: true
                    onClicked: itemModel.setFilters(checked, showTranslatedSwitch.checked)
                }
            }
            ListView {

                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: itemsToolbar.bottom
                anchors.bottom: parent.bottom

                anchors.topMargin: 88

                spacing: 10

                model: itemModel

                delegate: Rectangle {
                    //width: parent.width
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 80
                    radius: 20
                    color: Material.primary
                    //color: Material.background

                    // TODO Should not hide while we're still focused on translationTextField
                    //visible: (showTranslatedSwitch.checked || translationTextField.text.length == 0) && (!model.Archived || showArchivedSwitch.checked)
                    Row {
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8
                        anchors.topMargin: 8
                        anchors.bottomMargin: 8
                        spacing: 10
                        Text {
                            width: parent.width/3 - 16
                            anchors.top: translationTextField.top
                            anchors.bottom: translationTextField.bottom
                            verticalAlignment: Text.AlignVCenter
                            color: Material.foreground
                            text: model.Title
                            font.bold: true
                        }
                        TextField {
                            width: parent.width/3 - 16
                            id: translationTextField
                            placeholderText: qsTr("Traduction")
                            text: model.Translation
                            maximumLength: 22
                        }
                        Switch {
                            text: qsTr("Archiver")
                            anchors.top: translationTextField.top
                            anchors.bottom: translationTextField.bottom

                            checked: model.Archived
                            focusPolicy: Qt.NoFocus

                            //onClicked: model.Archived = checked
                        }
                    }
                }
            }

        } // End Items pane
        Pane { // Screens pane

        } // End screens pane
        Pane { // Menus pane

        } // End Menus pane
        Pane { // Others pane

        } // End Others pane
        Pane { // Quit pane

        } // End Quit pane
        Pane { // Settings pane
            Column {
                anchors.fill: parent
                spacing: 10

                Switch {
                    text: qsTr("Mode sombre")
                    checked: window.darkMode

                    onClicked: window.darkMode = checked
                }
            }
        } //// End Settings pane
    }
}