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
    property string poseZone: "cytosol"
    property var partnerPose: {"x": -1, "y": -1, "theta": -1, "zone": "cytosol"}
    property bool loggedIn: false
    width: container.width
    height: container.height
    visible: loggedIn


    //TODO: look into CSV logger
    // - allows you to create logger objects
    // - logs the position at all time of a robot
    // - whenever the robot enters and exits a zone
    // - useful for computing metrics
    // ex. leader-follower pattern: look at zone sequence,
    // position of the robot, change in direction of the robot
    // https://github.com/chili-epfl/qml-logger/

    // Next week:
    // - haptic feedback
    //     - haptic connection

    // Flesh out understanding of the following things:
    // - haptic understanding communication
    // - haptic understanding the problem/situation
    // https://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.257.7356&rep=rep1&type=pdf

    // robot comm
    CelluloRobot
    {
        id: robotComm
        Component.onCompleted: {
          zoneEngine.addNewClient(robotComm);
        }
        onZoneValueChanged: {
          console.log(zone);
          if (value == 0) {
            poseZone = "cytosol";
            robotComm.setVisualEffect(0, "#ffffff", 100);
          } else {
            poseZone = zone.name;
            robotComm.setVisualEffect(0, "#ff005d", 100);
          }
        }
        onPoseChanged:
        {
            // update internal state representation
            poseX = x;
            poseY = y;
            poseTheta = theta;
            poseUpdateAnimation.start();
        }
        onConnectionStatusChanged:
        {
          robotComm.setVisualEffect(0, "#ffffff", 100);
          console.log(x);
          console.log(y);
          console.log(theta);
        }
    }
    CelluloZoneEngine
    {
        id: zoneEngine
        CelluloZoneCircleInner
        {
            id: nucleusZone
            x: 124
            y: 130
            r: 15
            name: "nucleus"
        }
        CelluloZoneCircleInner
        {
            id: mitochondrionZone1
            x: 67
            y: 204
            r: 15
            name: "mitochondrion"
        }
        CelluloZoneCircleInner
        {
            id: mitochondrionZone2
            x: 165
            y: 97
            r: 10
            name: "mitochondrion"
        }
        CelluloZoneCircleInner
        {
            id: lysosomeZone
            x: 51
            y: 105
            r: 15
            name: "lysosome"
        }
        CelluloZoneCircleInner
        {
            id: golgiBodyZone
            x: 124
            y: 214
            r: 15
            name: "golgiBody"
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
            let requestStatus = { text: "" };
            let content =
            {
              name : userId,
              pose : { x: poseX, y: poseY, theta: poseTheta, zone: poseZone }
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
            // console.log(partnerId);
            let requestStatus = { text: "" };
            let data = { requestStatus: requestStatus, app: app, partnerAnimation: partnerAnimation, robotComm: robotComm };
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
            text: "Me: (x=" + Math.round(poseX) + ", y=" + Math.round(poseY) + ", theta=" + Math.round(poseTheta) + ", zone=" + poseZone + ")"
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
            text: "Partner: (x=" + Math.round(partnerPose.x) + ", y=" + Math.round(partnerPose.y) + ", theta=" + Math.round(partnerPose.theta) + ", zone=" + partnerPose.zone + ")"
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
            onClicked: Qt.openUrlExternally("https://hasaru-k.github.io/haptic-cellulo?player=" + userId + "&partner=" + partnerId);
            font.pixelSize: 15
        }
        Label
        {
            id: modeDisplay
            text: "Haptic mode: " + Utils.getMode();
            font.pixelSize: 15
        }
        Button
        {
            text: "Switch haptic mode"
            onClicked: {
              Utils.switchMode();
              modeDisplay.text = "Haptic mode: " + Utils.getMode();
            }
            font.pixelSize: 15
        }
    }
}
