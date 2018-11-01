//
// This file is part of Sugar Light, a theme for the Simple Display Desktop Manager.
//
// Copyright 2018 Marian Arlt
//
// Sugar Light is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// Sugar Light is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with Sugar Light. If not, see <https://www.gnu.org/licenses/>.
//

import QtQuick 2.11
import QtQuick.Layouts 1.11
import QtQuick.Controls 2.4

Column {
    id: inputContainer
    Layout.fillWidth: true

    property Control exposeLogin: loginButton

    Item {
        id: usernameField
        height: root.font.pointSize * 3.25
        width: parent.width / 2
        anchors.horizontalCenter: parent.horizontalCenter

        TextField {
            id: username
            text: config.ForceLastUser == "true" ? userModel.lastUser : ""
            anchors.centerIn: parent
            height: root.font.pointSize * 3
            width: parent.width
            placeholderText: config.TranslateUsernamePlaceholder || textConstants.userName
            selectByMouse: true
            horizontalAlignment: TextInput.AlignHCenter
            renderType: Text.QtRendering
            background: Rectangle {
                color: "transparent"
                border.color: root.palette.text
                border.width: parent.activeFocus ? 2 : 1
                radius: config.RoundCorners || undefined
            }
            Keys.onReturnPressed: loginButton.clicked()
            KeyNavigation.down: password
        }

        Button {
            id: usernameIcon
            anchors.horizontalCenter: parent.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenterOffset: username.height * 0.6
            icon.height: username.height * 0.4
            icon.width: username.height * 0.4
            enabled: false
            icon.color: root.palette.text
            icon.source: Qt.resolvedUrl("../Assets/User.svgz")
        }
    }

    Item {
        id: passwordField
        height: root.font.pointSize * 4.5
        width: parent.width / 2
        anchors.horizontalCenter: parent.horizontalCenter

        TextField {
            id: password
            anchors.centerIn: parent
            height: root.font.pointSize * 3
            width: parent.width
            focus: config.ForcePasswordFocus == "true" ? true : false
            selectByMouse: true
            echoMode: revealSecret.checked ? TextInput.Normal : TextInput.Password
            placeholderText: config.TranslatePasswordPlaceholder || textConstants.password
            horizontalAlignment: TextInput.AlignHCenter
            passwordCharacter: "•"
            passwordMaskDelay: config.ForceHideCompletePassword == "true" ? undefined : 1000
            renderType: Text.QtRendering
            background: Rectangle {
                color: "transparent"
                border.color: root.palette.text
                border.width: parent.activeFocus ? 2 : 1
                radius: config.RoundCorners || undefined
            }
            Keys.onReturnPressed: loginButton.clicked()
            KeyNavigation.down: revealSecret
        }
    }

    Item {
        id: secretCheckBox
        height: root.font.pointSize * 7
        width: parent.width / 2
        anchors.horizontalCenter: parent.horizontalCenter

        CheckBox {
            id: revealSecret
            width: parent.width
            hoverEnabled: true

            indicator: Rectangle {
                id: indicator
                anchors.left: parent.left
                implicitHeight: root.font.pointSize
                implicitWidth: root.font.pointSize
                color: "transparent"
                border.color: root.palette.text
                border.width: parent.visualFocus ? 2 : 1
                Rectangle {
                    anchors.centerIn: parent
                    implicitHeight: parent.width - 6
                    implicitWidth: parent.width - 6
                    color: root.palette.text
                    visible: revealSecret.checked
                }
            }

            contentItem: Text {
                text: config.TranslateShowPassword || "Show Password"
                anchors.verticalCenter: indicator.verticalCenter
                horizontalAlignment: Text.AlignLeft
                anchors.left: indicator.right
                anchors.leftMargin: indicator.width / 2
                font.pointSize: root.font.pointSize * 0.75
                color: parent.down ? root.palette.text : parent.visualFocus | parent.hovered ? Qt.lighter(root.palette.text, 1.5) : root.palette.text
            }

            Keys.onReturnPressed: toggle()
            KeyNavigation.down: loginButton
        }
    }

    Item {
        height: root.font.pointSize * 2.3
        width: parent.width / 2
        anchors.horizontalCenter: parent.horizontalCenter
        Label {
            id: errorMessage
            width: parent.width
            text: config.TranslateLoginFailed || textConstants.loginFailed + "!"
            horizontalAlignment: Text.AlignHCenter
            font.pointSize: root.font.pointSize * 0.8
            font.italic: true
            color: root.palette.text
            opacity: 0
            OpacityAnimator on opacity {
                id: fadeIn
                from: 0;
                to: 1;
                duration: 200
                running: false
            }
            OpacityAnimator on opacity {
                id: fadeOut
                from: 1;
                to: 0;
                duration: 400
                running: false
            }
        }
    }

    Item {
        id: login
        height: root.font.pointSize * 3
        width: parent.width / 2
        anchors.horizontalCenter: parent.horizontalCenter

        Button {
            id: loginButton
            anchors.horizontalCenter: parent.horizontalCenter
            text: config.TranslateLogin || textConstants.login
            height: root.font.pointSize * 3
            implicitWidth: parent.width
            enabled: username.text !== "" && password.text !== "" ? true : false
            hoverEnabled: true

            contentItem: Text {
                text: parent.text
                color: "white"
                font.pointSize: root.font.pointSize
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            background: Rectangle {
                id: buttonBackground
                opacity: enabled ? 1 : 0.2
                color: !enabled ? "#999999" : parent.down ? "#222222" : parent.visualFocus | parent.hovered ? config.LoginHoverColor : root.palette.text
                border.color: !enabled ? "#999999" : parent.down ? "#222222" : parent.visualFocus | parent.hovered ? config.LoginHoverColor : root.palette.text
                border.width: 1
                radius: config.RoundCorners || undefined
            }

            Keys.onReturnPressed: clicked()
            onClicked: username.text !== "" && password.text !== "" ? sddm.login(username.text, password.text, sessionSelector.selectedSession) : sddm.loginFailed()
        }
    }

    SessionButton {
        id: sessionSelector
        textConstantSession: textConstants.session
    }

    Connections {
        target: sddm
        onLoginSucceeded: {}
        onLoginFailed: { 
            fadeIn.start()
            resetError.running ? resetError.stop() & resetError.start() : resetError.start()
        }
    }

    Timer {
        id: resetError
        interval: 2000
        onTriggered: fadeOut.start()
        running: false
    }

}