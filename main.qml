import QtCore
import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import QtQuick.Dialogs

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
    property bool allowGenerateAndQuit: true
    property string sourceFile: "C:\\SC\\"
    property string odbcConnectionString: "DSN=qmdb"
    property string outputPath: "qm.mdb"
    property string preOutputScript: ""
    property string postOutputScript: ""
    property int backupCount: 5
    property string backupPath: "backup\\"
    property bool showArchived: true
    property bool showTranslated: true

    function updateItemCountText() {
        var total = 0
        var displayed = 0
        var model = null
        if (navBar.currentIndex == 0) {
            model = itemModel
        } else if (navBar.currentIndex == 1) {
            model = screenModel
        } else if (navBar.currentIndex == 2) {
            model = menuModel
        } else if (navBar.currentIndex == 3) {
            model = miscModel
        }
        if (model === null) {
            itemCountText.text = qsTr("Aucun item à afficher")
        } else {
            itemCountText.text = qsTr("Items affichés: %0/%1").arg(model.countDisplayed()).arg(model.countAll())
        }
    }

    Settings {
        property alias darkMode: window.darkMode
        property alias allowGenerateAndQuit: window.allowGenerateAndQuit
        property alias sourceFile: window.sourceFile
        property alias odbcConnectionString: window.odbcConnectionString
        property alias width: window.width
        property alias height: window.height
        property alias outputPath: window.outputPath
        property alias preOutputScript: window.preOutputScript
        property alias postOutputScript: window.postOutputScript
        property alias backupCount: window.backupCount
        property alias backupPath: window.backupPath
        property alias showArchived: window.showArchived
        property alias showTranslated: window.showTranslated
    }

    Toastify {
        id: toastManager
    }

    Component.onCompleted: {
        itemModel.setFilters(window.showArchived, window.showTranslated);
        screenModel.setFilters(window.showArchived, window.showTranslated);
        menuModel.setFilters(window.showArchived, window.showTranslated);
        miscModel.setFilters(window.showArchived, window.showTranslated);
        updateItemCountText()
    }

    TabBar {
        id: navBar
        anchors.left: parent.left
        anchors.right: parent.right

        onCurrentIndexChanged: {
            var model = null
            if (currentIndex == 0) {
                model = itemModel
            } else if (currentIndex == 1) {
                model = screenModel
            } else if (currentIndex == 2) {
                model = menuModel
            } else if (currentIndex == 3) {
                model = miscModel
            }

            if (model !== null) {
                model.setFilters(showArchivedSwitch.checked, showTranslatedSwitch.checked)
                updateItemCountText()
            }
        }

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
            text: qsTr("Aide")
            icon.source: "assets/help.svg"
        }

        TabButton {
            text: qsTr("Quitter")
            icon.source: "assets/close.svg"
        }

        TabButton {
            //text: qsTr("Paramètres")
            icon.source: "assets/settings.svg"
        }
    }

    ToolBar {
        id: toolBar
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: navBar.bottom

        Material.background: darkMode? Material.background : '#FFFFFF' // TODO Fix binding loop

        //height: 88
        Row {
            anchors.fill: parent
            anchors.topMargin: 8
            anchors.bottomMargin: 8
            visible: paneStack.currentIndex < 4 // Hide toolbar when on Quit or Settings panes
            spacing: 8

            Switch {
                id: showTranslatedSwitch
                text: qsTr("Afficher items déjà traduits")

                checked: window.showTranslated
                onClicked: {
                    window.showTranslated = checked
                    if (paneStack.currentIndex == 0) {
                        itemModel.setFilters(showArchivedSwitch.checked, checked)
                    } else if (paneStack.currentIndex == 1) {
                        screenModel.setFilters(showArchivedSwitch.checked, checked)
                    } else if (paneStack.currentIndex == 2) {
                        menuModel.setFilters(showArchivedSwitch.checked, checked)
                    } else if (paneStack.currentIndex == 3) {
                        miscModel.setFilters(showArchivedSwitch.checked, checked)
                    }
                    updateItemCountText()
                }

                ToolTip.delay: 1000
                ToolTip.timeout: 5000
                ToolTip.text: qsTr("Déasactiver cette option permet de ne voir que les items qui n'ont pas encore été traduits.")
                ToolTip.visible: hovered
            }

            Switch {
                id: showArchivedSwitch
                text: qsTr("Afficher items archivés")

                checked: window.showArchived
                onClicked: {
                    window.showArchived = checked
                    itemModel.setFilters(checked, showTranslatedSwitch.checked)
                    updateItemCountText()
                }

                ToolTip.delay: 1000
                ToolTip.timeout: 5000
                ToolTip.text: qsTr("Désactiver cette option permet de ne pas voir les items archivés.")
                ToolTip.visible: hovered
            }

            Text {
                id: itemCountText
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: 16
                font.bold: true
                text: qsTr("Aucun item à afficher")
                color: Material.primary
                verticalAlignment: Text.AlignVCenter
            }
        }
    }

    StackLayout {
        id: paneStack
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.top: toolBar.bottom

        currentIndex: navBar.currentIndex

        Pane { // Items pane

            ListView {

                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom

                anchors.topMargin: 88

                spacing: 16

                model: itemModel

                ScrollBar.vertical: ScrollBar {
                    policy: ScrollBar.AlwaysOn
                    width: 16
                }

                delegate: Rectangle {
                    width: parent != null? parent.width - 18 : 0
                    height: 80
                    radius: 20
                    color: index%2 == 0? Material.primary : Material.color(Material.Green, Material.Shade800)

                    Row {
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8
                        anchors.topMargin: 8
                        anchors.bottomMargin: 8
                        spacing: 10
                        Text {
                            width: parent.width/4
                            anchors.top: translationTextField.top
                            anchors.bottom: translationTextField.bottom
                            verticalAlignment: Text.AlignVCenter
                            color: Material.foreground
                            text: model.Title
                            font.bold: true
                        }
                        TextField {
                            width: parent.width/4
                            id: translationTextField
                            placeholderText: qsTr("Traduction")
                            text: model.Translation
                            maximumLength: 22
                            validator: RegularExpressionValidator { regularExpression: /^[\x00-\x7F]*$/ } // Allow only ASCII
                            onEditingFinished: itemModel.setTranslation(index, text)
                        }
                        Switch {
                            text: qsTr("Archiver")
                            anchors.top: translationTextField.top
                            anchors.bottom: translationTextField.bottom

                            checked: model.Archived
                            focusPolicy: Qt.NoFocus

                            onClicked: {
                                itemModel.setArchived(index, checked)
                                if (checked) {
                                    itemModel.refreshList()
                                    updateItemCountText()
                                }
                            }

                            ToolTip.delay: 1000
                            ToolTip.timeout: 5000
                            ToolTip.text: qsTr("Archiver cet item permet de le cacher. Vous pouvez le retrouver en activant l'option 'Afficher items archivés'.")
                            ToolTip.visible: hovered
                        }
                    }
                }
            }

        } // End Items pane
        Pane { // Screens pane
            ListView {

                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom

                anchors.topMargin: 88

                spacing: 16

                model: screenModel

                ScrollBar.vertical: ScrollBar {
                    policy: ScrollBar.AlwaysOn
                    width: 16
                }

                delegate: Rectangle {
                    width: parent != null? parent.width - 18 : 0
                    height: 80
                    radius: 20
                    color: index%2 == 0? Material.color(Material.Purple) : Material.color(Material.Purple, Material.Shade800)

                    Row {
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8
                        anchors.topMargin: 8
                        anchors.bottomMargin: 8
                        spacing: 10
                        Text {
                            width: parent.width/4
                            anchors.top: translationTextField.top
                            anchors.bottom: translationTextField.bottom
                            verticalAlignment: Text.AlignVCenter
                            color: Material.foreground
                            text: model.Title
                            font.bold: true
                        }
                        TextField {
                            width: parent.width/4
                            id: translationTextField
                            placeholderText: qsTr("Traduction")
                            text: model.Translation
                            maximumLength: 22
                            validator: RegularExpressionValidator { regularExpression: /^[\x00-\x7F]*$/ } // Allow only ASCII

                            onEditingFinished: screenModel.setTranslation(index, text)
                        }
                        Switch {
                            text: qsTr("Archiver")
                            anchors.top: translationTextField.top
                            anchors.bottom: translationTextField.bottom

                            checked: model.Archived
                            focusPolicy: Qt.NoFocus

                            onClicked: {
                                screenModel.setArchived(index, checked)
                                if (checked) {
                                    screenModel.refreshList()
                                    updateItemCountText()
                                }
                            }

                            ToolTip.delay: 1000
                            ToolTip.timeout: 5000
                            ToolTip.text: qsTr("Archiver cet item permet de le cacher. Vous pouvez le retrouver en activant l'option 'Afficher items archivés'.")
                            ToolTip.visible: hovered
                        }
                    }
                }
            }
        } // End screens pane
        Pane { // Menus pane
            ListView {

                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom

                anchors.topMargin: 88

                spacing: 16

                model: menuModel

                ScrollBar.vertical: ScrollBar {
                    policy: ScrollBar.AlwaysOn
                    width: 16
                }

                delegate: Rectangle {
                    width: parent != null? parent.width - 18 : 0
                    height: 80
                    radius: 20
                    color: index%2 == 0? Material.color(Material.Pink) : Material.color(Material.Pink, Material.Shade800)

                    Row {
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8
                        anchors.topMargin: 8
                        anchors.bottomMargin: 8
                        spacing: 10
                        Text {
                            width: parent.width/4
                            anchors.top: translationTextField.top
                            anchors.bottom: translationTextField.bottom
                            verticalAlignment: Text.AlignVCenter
                            color: Material.foreground
                            text: model.Title
                            font.bold: true
                        }
                        TextField {
                            width: parent.width/4
                            id: translationTextField
                            placeholderText: qsTr("Traduction")
                            text: model.Translation
                            maximumLength: 22
                            validator: RegularExpressionValidator { regularExpression: /^[\x00-\x7F]*$/ } // Allow only ASCII

                            onEditingFinished: menuModel.setTranslation(index, text)
                        }
                        Switch {
                            text: qsTr("Archiver")
                            anchors.top: translationTextField.top
                            anchors.bottom: translationTextField.bottom

                            checked: model.Archived
                            focusPolicy: Qt.NoFocus

                            onClicked: {
                                menuModel.setArchived(index, checked)
                                if (checked) {
                                    menuModel.refreshList()
                                    updateItemCountText()
                                }
                            }

                            ToolTip.delay: 1000
                            ToolTip.timeout: 5000
                            ToolTip.text: qsTr("Archiver cet item permet de le cacher. Vous pouvez le retrouver en activant l'option 'Afficher items archivés'.")
                            ToolTip.visible: hovered
                        }
                    }
                }
            }
        } // End Menus pane
        Pane { // Misc pane
            ListView {

                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom

                anchors.topMargin: 88

                spacing: 16

                model: miscModel

                ScrollBar.vertical: ScrollBar {
                    policy: ScrollBar.AlwaysOn
                    width: 16
                }

                delegate: Rectangle {
                    width: parent != null? parent.width - 18 : 0
                    height: 80
                    radius: 20
                    color: index%2 == 0? Material.color(Material.Orange) : Material.color(Material.Orange, Material.Shade800)

                    Row {
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8
                        anchors.topMargin: 8
                        anchors.bottomMargin: 8
                        spacing: 10
                        Text {
                            width: parent.width/4
                            anchors.top: translationTextField.top
                            anchors.bottom: translationTextField.bottom
                            verticalAlignment: Text.AlignVCenter
                            color: Material.foreground
                            text: model.Title
                            font.bold: true
                        }
                        TextField {
                            width: parent.width/4
                            id: translationTextField
                            placeholderText: qsTr("Traduction")
                            text: model.Translation
                            maximumLength: 22
                            validator: RegularExpressionValidator { regularExpression: /^[\x00-\x7F]*$/ } // Allow only ASCII

                            onEditingFinished: miscModel.setTranslation(index, text)
                        }
                        Switch {
                            text: qsTr("Archiver")
                            anchors.top: translationTextField.top
                            anchors.bottom: translationTextField.bottom

                            checked: model.Archived
                            focusPolicy: Qt.NoFocus

                            onClicked: {
                                miscModel.setArchived(index, checked)
                                if (checked) {
                                    miscModel.refreshList()
                                    updateItemCountText()
                                }
                            }

                            ToolTip.delay: 1000
                            ToolTip.timeout: 5000
                            ToolTip.text: qsTr("Archiver cet item permet de le cacher. Vous pouvez le retrouver en activant l'option 'Afficher items archivés'.")
                            ToolTip.visible: hovered
                        }
                    }
                }
            }
        } // End Misc pane
        Pane { // Help pane
            ScrollView {
                anchors.fill: parent
                ScrollBar.vertical.policy: ScrollBar.AlwaysOn
                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

                Column {
                    anchors.fill: parent
                    //anchors.rightMargin: 18
                    spacing: 16

                    Repeater {
                        model: ListModel {
                            ListElement {
                                header: qsTr("Fonctionnement de POSiTrad")
                                help: qsTr("POSiTrad facilite la traduction de menus pour POSiTouch construits à partir de QuickMenu. Sous les onglets 'Items', 'Écrans', 'Menus' et 'Autres', vous trouverez des listes d'objets existants dans votre menu dont vous pouvez définir une traduction. En utilisant l'option 'Générer la traduction et quitter', POSiTrad va générer une copie de votre menu original, mais substituera les traductions que vous avez définies.\n\nNotez que POSiTrad n'est approprié que pour les cas où les menus sont rigourusement identiques entre les succursales, autre que la langue.")
                            }

                            ListElement {
                                header: qsTr("Comment sauvegarder mes changements?")
                                help: qsTr("Tout est sauvegardé automatiquement au fur et à mesure que vous faites des modifications.")
                            }

                            ListElement {
                                header: qsTr("Comment pousser mes changements dans une succursale?")
                                help: qsTr("Pour pousser les modifications dans une succursale, il sera nécessaire d'éxécuter un script d'exportation, que CLS Info aura configuré pour vous. Il sera également nécessaire d'effectuer un 'Immediate System Change' dans la succursale si on veut que les modifications soient appliquées immédiatement.\n\nSi vous avez omis de traduire un item, le texte original sera utilisé.")
                            }

                            ListElement {
                                header: qsTr("À quoi sert l'option 'Archiver' sur les items?")
                                help:qsTr("L'option 'Archiver' permet de cacher un item de la liste. Il sera toujours possible de le retrouver en activant l'option 'Afficher items archivés'. Ceci est utile pour cacher des items qui ne sont plus utilisés.\n\nNotez que cette fonction n'a aucun impact sur le menu lui-même, mais seulement sur la liste d'items affichée dans POSiTrad.")
                            }
                        }
                        delegate: Column {
                            spacing: 8
                            width: parent.width

                            Button {
                                id: header
                                text: model.header
                                icon.source: checked? "assets/keyboard_arrow_down.svg" : "assets/chevron_right.svg"
                                font.pixelSize: 24
                                font.bold: true
                                flat: true
                                checkable: true
                                checked: false
                            }

                            Text {

                                text: model.help
                                width: parent.width
                                wrapMode: Text.WordWrap
                                color: Material.foreground

                                // Adapted from https://forum.qt.io/topic/81646/expandible-collapsible-pane-with-smooth-animation-in-qml/5
                                // These lines below are responsible for the expand/collapse animation
                                visible: height > 0
                                height: header.checked? implicitHeight : 0
                                Behavior on height {
                                    NumberAnimation {
                                        easing.type: Easing.InOutQuad
                                    }
                                }
                                clip: true
                            }
                        }
                    }
                }
            }

        } // End Help pane
        Pane { // Quit pane
            Column {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                spacing: 32

                Button {
                    text: qsTr("Générer la traduction et quitter")
                    width: 384
                    height: 96
                    icon.source: "assets/publish.svg"
                    icon.color: Material.color(Material.Blue)
                    enabled: window.allowGenerateAndQuit
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

                        onClicked: {
                            window.darkMode = checked
                            toolBar.Material.background = darkMode ? Material.background : '#FFFFFF'
                        }
                    }

                    GroupBox {
                        title: qsTr("Paramètres POSiTouch")

                        width: window.width - 64

                        Column {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            spacing: 16

                            FileDialog {
                                id: sourceFileDialog
                                title: qsTr("Sélectionner le fichier source")
                                nameFilters: ["Access Database (*.mdb)", "All files (*)"]
                                onAccepted: {
                                    sourceFileTextField.text = fileUrl.toString()
                                    window.sourceFile = fileUrl.toString()
                                }
                            }

                            TextField {
                                width: 400
                                placeholderText: qsTr("Connexion à ODBC")
                                text: window.odbcConnectionString
                                onEditingFinished: window.odbcConnectionString = text
                            }

                            Row {
                                spacing: 8

                                TextField {
                                    id: sourceFileTextField
                                    width: 400
                                    placeholderText: qsTr("Fichier source (ex: C:\\SC\\qm.mdb)")
                                    text: window.sourceFile
                                    onEditingFinished: window.sourceFile = text
                                }
                                Button {
                                    icon.source: "assets/folder.svg"
                                    flat: true
                                    onClicked: {
                                        sourceFileDialog.open()
                                    }
                                }
                            }


                        }
                    }

                    GroupBox {
                        title: qsTr("Paramètres d'exportation")

                        width: window.width - 64

                        FileDialog {
                            id: preOutputScriptDialog
                            title: qsTr("Sélectionner le script à exécuter avant l'exportation")
                            nameFilters: ["Batch files (*.bat)", "All files (*)"]
                            onAccepted: {
                                preOutputScriptTextField.text = fileUrl.toString()
                                window.preOutputScript = fileUrl.toString()
                            }
                        }

                        FileDialog {
                            id: postOutputScriptDialog
                            title: qsTr("Sélectionner le script à exécuter après l'exportation")
                            nameFilters: ["Batch files (*.bat)", "All files (*)"]
                            onAccepted: {
                                postOutputScriptTextField.text = fileUrl.toString()
                                window.postOutputScript = fileUrl.toString()
                            }
                        }

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

                            Row {
                                spacing : 8
                                TextField {
                                    id: preOutputScriptTextField
                                    width: 400
                                    placeholderText: qsTr("Script éxécuté avant l'exportation")
                                    text: window.preOutputScript
                                    onEditingFinished: window.preOutputScript = text
                                }
                                Button {
                                    icon.source: "assets/folder.svg"
                                    flat: true
                                    onClicked: {
                                        preOutputScriptDialog.open()
                                    }
                                }
                            }

                            Row {
                                spacing: 8
                                TextField {
                                    width: 400
                                    placeholderText: qsTr("Script éxécuté après l'exportation")
                                    text: window.postOutputScript
                                    onEditingFinished: window.postOutputScript = text
                                }
                                Button {
                                    icon.source: "assets/folder.svg"
                                    flat: true
                                    onClicked: {
                                        postOutputScriptDialog.open()
                                    }
                                }
                            }

                            Switch {
                                text: qsTr("Activer l'option 'Générer la traduction et quitter'")
                                checked: window.allowGenerateAndQuit

                                onClicked: window.allowGenerateAndQuit = checked
                            }
                        }
                    }

                    GroupBox {
                        title: qsTr("Copies de sauvegarde")
                        width: window.width - 64

                        Popup {
                            id: backupRestorePopup
                            parent: Overlay.overlay
                            anchors.centerIn: parent
                            //width: window.width*0.8
                            //height: window.height*0.8

                            modal: true
                            focus: true
                            closePolicy: Popup.CloseOnEscape

                            contentItem: Column {
                                spacing: 16
                                Label {
                                    text: qsTr("Restaurer une copie de sauvegarde")
                                    font.pointSize: 16
                                    font.bold: true
                                    color: Material.primary
                                }
                                Label {
                                    text: qsTr("Voici une liste des copies de sauvegarde que vous pouvez remettre en place:")
                                }
                                ComboBox {
                                    id: backupRestoreComboBox
                                    width: parent.width
                                    model: backupManager
                                    textRole: "LastModified"
                                    valueRole: "Path"
                                }

                                Row {
                                    spacing: 32
                                    Button {
                                        icon.source: "assets/close.svg"
                                        icon.color: Material.color(Material.Red)
                                        flat: true
                                        width: 96
                                        height: 96

                                        onClicked: backupRestorePopup.close()
                                    }
                                    Button {
                                        text: qsTr("Restaurer")
                                        icon.source: "assets/check.svg"
                                        icon.color: Material.color(Material.Green)
                                        width: 192
                                        height: 96
                                        onClicked: {
                                            console.log(backupRestoreComboBox.currentValue)
                                            backupManager.restore(backupRestoreComboBox.currentValue)
                                        }
                                    }
                                }
                            }
                            

                        }

                        Column {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            spacing: 16

                            Row {
                                spacing: 16
                                SpinBox {
                                    id: backupCountSpinBox
                                    from: 1
                                    to: 99
                                    value: window.backupCount
                                    stepSize: 1
                                    width: 200

                                    enabled: backupPathTextField.text.length > 0
                                    
                                    onValueChanged: window.backupCount = value
                                }
                                Label {
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: qsTr("Nombre de copies de sauvegarde à conserver")
                                }
                            }

                            TextField {
                                id: backupPathTextField
                                width: 400
                                wrapMode: Text.WordWrap
                                color: Material.foreground
                                placeholderText: qsTr("Chemin vers les copies de sauvegarde (ex: backup\\)")
                                text: window.backupPath
                                onEditingFinished: {
                                    window.backupPath = text
                                    backupCountSpinBox.enabled = text.length > 0
                                    if (text.length == 0) {
                                        toastManager.createMessage(qsTr("Copies de sauvegarde désactivées. Cette configuration n'est pas recommandable."), {
                                        type: "warning",
                                        position: Qt.BottomEdge,
                                        theme: window.darkMode? "Dark" : "Light",
                                        closeOnClick: true,
                                        autoClose: 2000,
                                        hideProgressBar: true,
                                        clickAction: null
                                        })
                                    }
                                }
                            }

                            Button {
                                text: qsTr("Restaurer une copie de sauvegarde")
                                icon.source: "assets/settings_backup_restore.svg"

                                onClicked: backupRestorePopup.open()
                            }
                        }
                    }

                    GroupBox {
                        title: qsTr("À propos")
                        width: window.width - 64
                        Column {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            spacing: 16


                            Text {
                                text: Qt.application.displayName
                                color: Material.primary
                                font.pixelSize: 24
                                font.bold: true
                            }

                            Text {
                                text: qsTr("Version %0").arg(Qt.application.version)
                                color: Material.primary
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