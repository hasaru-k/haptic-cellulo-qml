import QtQuick 2.8
import QtQuick.Window 2.2
import QtQuick.Controls 2.0
import "methods.js" as Utils
import Cellulo 1.0
import QMLCache 1.0
import Logger 1.0
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
    Component.onCompleted:
    {
      zoneLogger.log([poseZone]);
      poseLogger.log([poseX, poseY, poseTheta]);
      let connectionStatus = CelluloBluetoothEnums.ConnectionStatusDisconnected;
      connectionStatusLogger.log([CelluloBluetoothEnums.ConnectionStatusString(connectionStatus)]);
    }
    /*
     * LOGGERS
     */
    CSVLogger
    {
        id: zoneLogger
        filename: Utils.createFileName(["zoneChanged", Utils.getDate()]);
        header: ["zoneValue"]
    }
    CSVLogger
    {
        id: poseLogger
        filename: Utils.createFileName(["poseChanged", Utils.getDate()]);
        header: ["x","y","theta"]
    }
    CSVLogger
    {
        id: connectionStatusLogger
        filename: Utils.createFileName(["connectionStatus", Utils.getDate()]);
        header: ["connectionStatusString"]
    }
    /*
     * ROBOT API
     */
    CelluloRobot
    {
        id: robotComm
        Component.onCompleted:
        {
            zoneEngine.addNewClient(robotComm);
        }
        onZoneValueChanged: {
            console.log(zone);
            // not in a zone
            if (value == 0) {
              poseZone = "cytosol";
              robotComm.setVisualEffect(0, "#ffffff", 100);
            } else {
              poseZone = zone.name;
              robotComm.setVisualEffect(0, "#ff005d", 100);
            }
            zoneLogger.log([poseZone]);
        }
        onPoseChanged:
        {
            // update internal state representation
            poseX = x;
            poseY = y;
            poseTheta = theta;
            poseUpdateAnimation.start();
            poseLogger.log([poseX, poseY, poseTheta]);
        }
        onConnectionStatusChanged:
        {
            robotComm.setVisualEffect(0, "#ffffff", 100);
            console.log(x);
            console.log(y);
            console.log(theta);
            connectionStatusLogger.log([CelluloBluetoothEnums.ConnectionStatusString(connectionStatus)]);
        }
    }
    /*
     * ZONE DEFINITIONS
     */
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
    /*
     * TIMER DEFINITIONS
     *
     * Sends pose updates to the remote server every 200ms.
     * Activated after logging in.
     */
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
    /*
     * Fetches pose updates for the partner from remote server every 200ms.
     * Activated after logging in.
     */
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
    /*
     * UI COMPONENTS
     */
    Column
    {
        id: container
        // layout attributes
        leftPadding: 15
        bottomPadding: 15
        rightPadding: 15
        topPadding: 15
        spacing: 15
        width: 500
        anchors.centerIn: parent
        FlowLabel
        {
            text: "1. Connect your robot to the application below."
        }
        // Robot connection items
        GroupBox
        {
            id: addressBox
            anchors.horizontalCenter: parent.horizontalCenter
            Column {
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
        InfoLabel
        {
            text: "My location: " + poseZone
            SequentialAnimation on color
            {
                id: poseUpdateAnimation
                ColorAnimation { from: "black"; to: "#3333ff"; duration: 250 }
                ColorAnimation { from: "#3333ff"; to: "black"; duration: 250 }
            }
        }
        InfoLabel
        {
            text: "Partner location: " + partnerPose.zone
            SequentialAnimation on color
            {
                id: partnerAnimation
                ColorAnimation { from: "black"; to: "#3333ff"; duration: 250 }
                ColorAnimation { from: "#3333ff"; to: "black"; duration: 250 }
            }
        }
        FlowLabel
        {
            text: "2. Launch the activity in browser."
        }
        SuccessButton
        {
            text: "Launch!"
            onClicked: Qt.openUrlExternally("https://hasaru-k.github.io/haptic-cellulo?player=" + userId + "&partner=" + partnerId);
        }
        FlowLabel
        {
            text: "Mode: " + Utils.getMode()
            font.pixelSize: 8
            topPadding: 20
            id: modeDisplay
            width: parent.width
        }
        SuccessButton
        {
            text: "Toggle mode"
            onClicked: {
              Utils.switchMode();
              modeDisplay.text = "Mode: " + Utils.getMode();
            }
            font.pixelSize: 7
            buttonColor: "#ff96ad"
        }
    }
}
