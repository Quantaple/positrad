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
    property string sourceFile: "C:\\SC\\"
    property string odbcConnectionString: "DSN=qmdb"
    property string outputPath: "qm.mdb"
    property string preOutputScript: ""
    property string postOutputScript: ""
    property bool showArchived: true
    property bool showTranslated: true

    Settings {
        property alias darkMode: window.darkMode
        property alias sourceFile: window.sourceFile
        property alias odbcConnectionString: window.odbcConnectionString
        property alias width: window.width
        property alias height: window.height
        property alias outputPath: window.outputPath
        property alias preOutputScript: window.preOutputScript
        property alias postOutputScript: window.postOutputScript
        property alias showArchived: window.showArchived
        property alias showTranslated: window.showTranslated
    }

    Component.onCompleted: {
        itemModel.setFilters(window.showArchived, window.showTranslated);
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

                    checked: window.showTranslated
                    onClicked: {
                        window.showTranslated = checked
                        itemModel.setFilters(showArchivedSwitch.checked, checked)
                        }
                }

                Switch {
                    id: showArchivedSwitch
                    text: qsTr("Afficher items archivés")

                    checked: window.showArchived
                    onClicked: {
                        window.showArchived = checked
                        itemModel.setFilters(checked, showTranslatedSwitch.checked)
                        }
                }
            }
            ListView {

                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: itemsToolbar.bottom
                anchors.bottom: parent.bottom

                anchors.topMargin: 88

                spacing: 16

                model: itemModel

                ScrollBar.vertical: ScrollBar {
                    policy: ScrollBar.AlwaysOn
                    width: 16
                }

                delegate: Rectangle {
                    //width: parent.width
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 80
                    radius: 20
                    color: index%2 == 0? Material.primary : Material.color(Material.Green, Material.Shade800)
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

                            onEditingFinished: itemModel.setTranslation(index, text)
                        }
                        Switch {
                            text: qsTr("Archiver")
                            anchors.top: translationTextField.top
                            anchors.bottom: translationTextField.bottom

                            checked: model.Archived
                            focusPolicy: Qt.NoFocus

                            onClicked: itemModel.setArchived(index, checked)
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
            Column {
                //anchors.fill: parent
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                spacing: 32

                Button {
                    text: qsTr("Générer la traduction et quitter")
                    width: 384
                    height: 96
                    icon.source: "assets/publish.svg"
                    icon.color: Material.color(Material.Blue)
                    onClicked: Qt.quit()
                }

                Button {
                    text: qsTr("Quitter")
                    width: 384
                    height: 96
                    icon.source: "assets/close.svg"
                    icon.color: Material.color(Material.Red)
                    onClicked: Qt.quit()
                }
            }
        } // End Quit pane
        Pane { // Settings pane
            id: settingsPane
            ScrollView {
                anchors.fill: parent
                ScrollBar.vertical.policy: ScrollBar.AlwaysOn
                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                Column {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    spacing: 32

                    Switch {
                        text: qsTr("Mode sombre")
                        checked: window.darkMode

                        onClicked: window.darkMode = checked
                    }

                    GroupBox {
                        title: qsTr("Paramètres POSiTouch")

                        //anchors.left: parent.left
                        //anchors.right: parent.right

                        Column {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            spacing: 16

                            TextField {
                                width: 400
                                placeholderText: qsTr("Connexion à ODBC")
                                text: window.odbcConnectionString
                                onEditingFinished: window.odbcConnectionString = text
                            }

                            TextField {
                                width: 400
                                placeholderText: qsTr("Fichier source (ex: C:\\SC\\qm.mdb)")
                                text: window.sourceFile
                                onEditingFinished: window.sourceFile = text
                            }
                        }
                    }

                    GroupBox {
                        title: qsTr("Paramètres d'exportation")
                        anchors.left: parent.left
                        anchors.right: parent.right

                        Column {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            spacing: 16

                            TextField {
                                width: 400
                                placeholderText: qsTr("Exporter vers...")
                                text: window.outputPath
                                onEditingFinished: window.outputPath = text
                            }

                            TextField {
                                width: 400
                                placeholderText: qsTr("Script éxécuté avant l'exportation")
                                text: window.preOutputScript
                                onEditingFinished: window.preOutputScript = text
                            }

                            TextField {
                                width: 400
                                placeholderText: qsTr("Script après l'exportation")
                                text: window.postOutputScript
                                onEditingFinished: window.postOutputScript = text
                            }
                        }
                    }

                    GroupBox {
                        title: qsTr("À propos")
                        anchors.left: parent.left
                        anchors.right: parent.right
                        Column {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            spacing: 16


                            Text {
                                text: qsTr("POSiTrad")
                                color: Material.accent
                                font.pixelSize: 24
                                font.bold: true
                            }

                            Text {
                                text: qsTr("Outil pour simplifier le maintient de différentes versions d'un menu.")
                                wrapMode: Text.WordWrap
                                color: Material.foreground
                            }

                            Text {
                                text: qsTr("Auteur: Martin Lapierre Pitre (C) CLS Info 2025")
                                wrapMode: Text.WordWrap
                                color: Material.foreground
                            }
                        }
                    }
                }
            }

        } //// End Settings pane
    }
}