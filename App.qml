import QtQuick 2.8
import QtQuick.Window 2.2
import QtQuick.Controls 2.0
import "methods.js" as Utils
import Cellulo 1.0
import QMLCache 1.0

Item
{
    property string userId: ""
    property string partnerId: ""
    property double poseX: 12
    property double poseY: 13
    property double poseTheta: 5
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
        }
    }
    // Sends pose updates to the remote server every 200ms.
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
        Row
        {
            Label
            {
                text: "1. Connect your robot to the application below."
                font.pixelSize: 15
                font.italic: true
            }
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
                    Row {
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
        Row
        {
            Label
            {
                text: "Current location: (x=" + Math.round(poseX) + ", y=" + Math.round(poseY) + ", theta=" + Math.round(poseTheta) + ")"
                font.pixelSize: 15
                font.letterSpacing: 1.2
            }
        }
    }
}
