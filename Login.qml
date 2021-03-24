import QtQuick 2.8
import QtQuick.Window 2.2
import QtQuick.Controls 2.0
import "methods.js" as Utils
import Cellulo 1.0
import QMLCache 1.0
import QtQuick.Controls.Styles 1.2

Item {
    property string userId: ""
    property string partnerId: ""
    width: container.width
    height: container.height
    anchors.centerIn: parent
    id: login
    state: "enteringId"
    states:
    [
        // in enteringId, both userId and partnerId are undefined
        State
        {
            name: "enteringId"
            PropertyChanges { target: idInputColumn; visible: true }
        },
        // in enteringPartnerId, userId is defined while partnerId is undefined
        State
        {
            name: "enteringPartnerId"
            PropertyChanges { target: partnerIdInputColumn; visible: true }
        },
        // the loggedIn state guarantees that both userId and partnerId are valid
        State
        {
            name: "loggedIn"
        }
    ]
    Grid
    {
        id: container
        columns: 1
        // layout attributes
        leftPadding: 10
        bottomPadding: 10
        rightPadding: 10
        topPadding: 10
        spacing: 10
        Column
        {
            id: idInputColumn
            visible: false
            spacing: 10
            width: 200
            TextField
            {
                id: idInput
                font.pixelSize: 12
                width: parent.width
                placeholderText: "Create an id here."
                validator: RegExpValidator { regExp: /[0-9A-xa-x]+/ }
            }
            Button
            {
                text: "Continue"
                font.pixelSize: 14
                width: parent.width
                onClicked:
                {
                    if (idInput.text === "") {
                        requestStatus.text = "Hmm, the id can't be empty.";
                        return;
                    }
                    Utils.uploadUserId(requestStatus, idInput.text);
                }
            }
        }
        Column
        {
            id: partnerIdInputColumn
            spacing: 10
            width: 200
            visible: false
            Label
            {
                text: "Hi, " + userId
                font.pixelSize: 12
                width: parent.width
                anchors.horizontalCenter: parent
            }
            TextField
            {
                id: partnerIdInput
                font.pixelSize: 12
                width: parent.width
                placeholderText: "Enter your partner's id here."
            }
            Button
            {
                font.pixelSize: 16
                width: parent.width
                anchors.horizontalCenter: parent
                text: "Connect to partner"
                onClicked:
                {
                    if (partnerIdInput.text === "")
                    {
                        requestStatus.text = "Hmm, the id can't be empty.";
                        return;
                    }
                    if (partnerIdInput.text === userId) {
                        requestStatus.text = "Hmm, that's your id. You need your partner's.";
                        return;
                    }
                    Utils.validatePartnerId(requestStatus, partnerIdInput.text);
                }
            }
        }
        Column
        {
            width: 200
            Label
            {
                id: requestStatus
                text: ""
                width: parent.width
                wrapMode: Label.WordWrap
                font.pixelSize: 12
                visible: text != "" && text != "loaded"
                onTextChanged:
                {
                    // transition the state iff. the request was successful
                    if (text === "loaded")
                    {
                        let currState = login.state;
                        if (currState === "enteringId") {
                            login.userId = idInput.text;
                            login.state = "enteringPartnerId";
                        } else {
                            login.partnerId = partnerIdInput.text;
                            login.state = "loggedIn";
                        }
                    }
                }
            }
        }
    }
}
