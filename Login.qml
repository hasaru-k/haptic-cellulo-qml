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
    id: login
    state: "enteringId"
    visible: idInput.state != "loggedIn"
    states:
    [
        State
        {
            name: "enteringId"
            PropertyChanges { target: idInputColumn; visible: true }
            PropertyChanges { target: partnerIdInputColumn; visible: false }
        },
        State
        {
            name: "requestInFlight"
            PropertyChanges { target: idInputColumn; visible: false }
            PropertyChanges { target: partnerIdInputColumn; visible: false }
        },
        State
        {
            name: "requestError"
            PropertyChanges { target: idInputColumn; visible: false }
        },
        State
        {
            name: "enteringPartnerId"
            PropertyChanges { target: idInputColumn; visible: false }
            PropertyChanges { target: usernameRequestStatus; visible: false }
            PropertyChanges { target: partnerIdInputColumn; visible: true }
        },
        State
        {
            name: "loggedIn"
        }
    ]
    Column
    {
        id: container
        // layout attributes
        leftPadding: 10
        bottomPadding: 10
        rightPadding: 10
        topPadding: 10
        spacing: 10
        Column
        {
            spacing: 10
            Column
            {
                id: idInputColumn
                spacing: 10
                Row
                {
                    TextField
                    {
                        id: idInput
                        font.pixelSize: 15
                        placeholderText: "Create an id here."
                    }
                }
                Row
                {
                    Button
                    {
                        text: "Continue"
                        onClicked:
                        {
                            let message = {
                              type : "sendPose",
                              contents : {
                                name : idInput.text,
                                pose : { x: 0, y: 0, theta: 0}
                              }
                            };
                            Utils.makeRequest(message, usernameRequestStatus);
                        }
                    }
                }
            }
            Column
            {
                Label
                {
                    id: usernameRequestStatus
                    text: ""
                    font.pixelSize: 15
                    visible: text != ""
                    onTextChanged:
                    {
                        if (text === "") {
                            login.state = "enteringId";
                        } else if (text === "loading") {
                            login.state = "requestInFlight";
                        } else if (text === "loaded") {
                            login.state = "enteringPartnerId";
                        } else {
                            login.state = "requestError";
                        }
                    }
                }
            }
            Column
            {
                id: partnerIdInputColumn
                spacing: 10
                Row
                {
                    TextField
                    {
                        id: partnerIdInput
                        font.pixelSize: 15
                        placeholderText: "Enter your partner's id here."
                    }
                }
                Row
                {
                    Button
                    {
                        id: connectButton
                        property variant robots: []
                        text: "Connect to partner"
                        onClicked:
                        {
                            Utils.getRobots(partnerIdRequestStatus, connectButton);
                        }
                    }
                }
                Row
                {
                    Label
                    {
                        id: verifier
                        text: ""
                    }
                }
            }
            Column
            {
                Label
                {
                    id: partnerIdRequestStatus
                    text: ""
                    font.pixelSize: 15
                    visible: text != ""
                    onTextChanged:
                    {
                        if (text === "") {
                            login.state = "partnerIdRequestStatus";
                        } else if (text === "loading") {
                            login.state = "requestInFlight";
                        } else if (text === "loaded") {
                            if (connectButton.robots.indexOf(partnerIdInput.text) < 0) {
                                verifier.text = "Hmm, that id doesn't seem to exist. Try again!";
                                login.state = "partnerIdRequestStatus";
                            } else {
                              login.state = "loggedIn";
                            }
                        } else {
                            login.state = "requestError";
                        }
                    }
                }
            }
        }

    }
}
