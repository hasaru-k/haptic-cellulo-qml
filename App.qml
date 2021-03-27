import QtQuick 2.8
import QtQuick.Window 2.2
import QtQuick.Controls 2.0
import "methods.js" as Utils
import Cellulo 1.0
import QMLCache 1.0
import QtWebView 1.1

Item
{
    id: app
    property string userId: ""
    property string partnerId: ""
    property double poseX: -1
    property double poseY: -1
    property double poseTheta: -1
    property var partnerPose: {"x": -1, "y": -1, "theta": -1}
    property bool loggedIn: false
    width: container.width
    height: container.height
    visible: loggedIn
    // robot comm
    CelluloRobot
    {
        id: robotComm
        Component.onCompleted: {}
        onZoneValueChanged: {}
        onPoseChanged:
        {
            // update internal state representation
            poseX = x;
            poseY = y;
            poseTheta = theta;
            poseUpdateAnimation.start();
        }
    }
    // Sends pose updates to the remote server every 200ms.
    // Activated iff. the robot is connected.
    Timer
    {
        id: poseUpdateTimer
        interval: 200;
        running: true;
        repeat: true
        onTriggered: {
            if (!loggedIn) {
              return;
            }
            return;
            console.log(userId);
            console.log(partnerId);
            let requestStatus = { text: "" };
            let content =
            {
              name : userId,
              pose : { x: poseX, y: poseY, theta: poseTheta}
            }
            Utils.sendPose(content, requestStatus);
        }
    }
    // Sends pose updates to the remote server every 200ms.
    // Activated iff. the robot is connected.
    Timer
    {
        id: partnerPoseUpdateTimer
        interval: 200;
        running: true;
        repeat: true
        onTriggered: {
            if (!loggedIn) {
              return;
            }
            console.log(partnerId);
            let requestStatus = { text: "" };
            let data = { requestStatus: requestStatus, app: app, partnerAnimation: partnerAnimation };
            Utils.getPose(partnerId, data);
        }
    }

    // Visual components follow

    Column
    {
        id: container
        // layout attributes
        leftPadding: 10
        bottomPadding: 10
        rightPadding: 10
        topPadding: 10
        spacing: 10
        Label
        {
            text: "1. Connect your robot to the application below."
            font.pixelSize: 15
        }
        // Robot connection items
        Row
        {
            GroupBox
            {
                id: addressBox
                Column{
                    spacing: 5
                    CelluloBluetoothScanner
                    {
                        id: scanner
                        onRobotDiscovered:
                        {
                            var newAddresses = macAddrSelector.addresses;
                            if (newAddresses.indexOf(macAddr) < 0)
                            {
                                console.log(macAddr + " discovered.");
                                newAddresses.push(macAddr);
                                newAddresses.sort();
                            }
                            macAddrSelector.addresses = newAddresses;
                            QMLCache.write("addresses", macAddrSelector.addresses.join(','));
                        }
                    }
                    Row
                    {
                        spacing: 5
                        MacAddrSelector
                        {
                            id: macAddrSelector
                            addresses: QMLCache.read("addresses").split(",")
                            onConnectRequested:
                            {
                                robotComm.localAdapterMacAddr = selectedLocalAdapterAddress;
                                robotComm.macAddr = selectedAddress;
                            }
                            onDisconnectRequested: robotComm.disconnectFromServer()
                            connectionStatus: robotComm.connectionStatus
                        }
                    }
                    Row
                    {
                        spacing: 5
                        BusyIndicator
                        {
                            running: scanner.scanning
                            height: scanButton.height
                        }
                        Button
                        {
                            id: scanButton
                            text: "Scan"
                            onClicked: scanner.start()
                        }
                        Button
                        {
                            text: "Clear List"
                            onClicked: {
                                macAddrSelector.addresses = [];
                                QMLCache.write("addresses","");
                            }
                        }
                        Button
                        {
                            text: "Reset connection"
                            onClicked: robotComm.reset()
                        }
                    }
                }
            }
        }
        Label
        {
            text: "Me: (x=" + Math.round(poseX) + ", y=" + Math.round(poseY) + ", theta=" + Math.round(poseTheta) + ")"
            font.pixelSize: 10
            font.letterSpacing: 1.2
            SequentialAnimation on color
            {
                id: poseUpdateAnimation
                ColorAnimation { from: "black"; to: "#3333ff"; duration: 250 }
                ColorAnimation { from: "#3333ff"; to: "black"; duration: 250 }
            }
            padding: 5
            background: Rectangle
            {
                color: "#e6e6ff"
            }
        }
        Label
        {
            text: "Partner: (x=" + Math.round(partnerPose.x) + ", y=" + Math.round(partnerPose.y) + ", theta=" + Math.round(partnerPose.theta) + ")"
            font.pixelSize: 10
            font.letterSpacing: 1.2
            SequentialAnimation on color
            {
                id: partnerAnimation
                ColorAnimation { from: "black"; to: "#3333ff"; duration: 250 }
                ColorAnimation { from: "#3333ff"; to: "black"; duration: 250 }
            }
            padding: 5
            background: Rectangle
            {
                color: "#e6e6ff"
            }
        }
        Label
        {
            text: "2. Launch the activity in browser."
            font.pixelSize: 15
        }
        Button
        {
            text: "Go!"
            onClicked: Qt.openUrlExternally("https://hasaru-k.github.io/haptic-cellulo?left=" + userId + "&right=" + partnerId);
            font.pixelSize: 15
        }
    }
}
