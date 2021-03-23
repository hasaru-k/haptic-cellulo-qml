import QtQuick 2.8
import QtQuick.Window 2.2
import QtQuick.Controls 2.0
import "methods.js" as Utils
import Cellulo 1.0
import QMLCache 1.0
import QtQuick.Controls.Styles 1.2

Item {
    property string apiId: idInput.text
    width: container.width
    height: container.height
    anchors.centerIn: parent
    id: login
    state: "enteringId"
    states:
    [
        State
        {
            name: "enteringId"
            PropertyChanges { target: idInputColumn; visible: true }
        },
        State
        {
            name: "enteringPartnerId"
            PropertyChanges { target: partnerIdInputColumn; visible: true }
        },
        State
        {
            name: "loggedIn"
            PropertyChanges { target: idInput; visible: false }
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
            }
            Button
            {
                text: "Continue"
                font.pixelSize: 14
                width: parent.width
                onClicked:
                {
                    let message = {
                      type : "sendPose",
                      contents : {
                        name : idInput.text,
                        pose : { x: 0, y: 0, theta: 0}
                      }
                    };
                    Utils.makeRequest(message, requestInfo);
                    apiId = idInput.text;
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
                text: "Hi, " + apiId
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
                    Utils.getRobots(requestInfo, partnerIdInput.text);
                }
            }
        }
        Column
        {
            Label
            {
                id: requestInfo
                text: ""
                font.pixelSize: 10
                visible: text != "" && text != "loaded"
                onTextChanged:
                {
                    if (text === "loaded")
                    {
                        let currState = login.state;
                        login.state = (currState === "enteringId") ?
                              "enteringPartnerId" : "loggedIn";
                        console.log(login.state);
                    }
                }
            }
        }
    }
}
