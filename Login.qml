import QtQuick 2.8
import QtQuick.Window 2.2
import QtQuick.Controls 2.0
import "methods.js" as Utils
import Cellulo 1.0
import QMLCache 1.0
import QtQuick.Controls.Styles 1.2


Item {
    // the Login item has an obligation to fill in and validate the userId and partnerId fields
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
            width: 160
            FlowLabel
            {
                width: parent.width
                text: "HapticCellulo"
                font.pixelSize: 20
                bottomPadding: 70
                font.family: "Roboto"
                horizontalAlignment: Text.AlignHCenter
                color: "#1f1f1f"
            }
            InputForm
            {
                id: idInput
                focus: true
                width: parent.width
                placeholderText: "Create an id here."
                validator: RegExpValidator { regExp: /[0-9A-xa-x]+/ }
                Keys.onEnterPressed: continueButton.activate();
                Keys.onReturnPressed: continueButton.activate();
            }
            SuccessButton
            {
                id: continueButton
                text: "Continue"
                font.pixelSize: 12
                width: parent.width
                function activate()
                {
                  if (idInput.text === "") {
                      requestStatus.text = "Hmm, the id can't be empty.";
                      return;
                  }
                  Utils.uploadUserId(requestStatus, idInput.text);
                  idInput.focus = false;
                  partnerIdInput.focus = true;
                }
                onClicked: continueButton.activate()
            }
        }
        Column
        {
            id: partnerIdInputColumn
            spacing: 10
            width: 180
            visible: false
            FlowLabel
            {
                text: "Hi, " + userId + "!"
                width: parent.width
            }
            InputForm
            {
                id: partnerIdInput
                width: parent.width
                placeholderText: "Enter your partner's id here."
                Keys.onEnterPressed: connectButton.activate();
                Keys.onReturnPressed: connectButton.activate();
            }
            SuccessButton
            {
                id: connectButton
                font.pixelSize: 9
                width: parent.width
                text: "Connect to partner"
                function activate()
                {
                  if (partnerIdInput.text === "")
                  {
                      requestStatus.text = "Hmm, the id can't be empty.";
                      return;
                  }
                  Utils.validatePartnerId(requestStatus, partnerIdInput.text);

                }
                onClicked: connectButton.activate()
            }
        }
        Column
        {
            width: 160
            FlowLabel
            {
                id: requestStatus
                text: ""
                font.pixelSize: 9
                width: parent.width
                wrapMode: Label.WordWrap
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
