import QtQuick 2.8
import QtQuick.Window 2.2
import QtQuick.Controls 2.0
import "methods.js" as Utils
import Cellulo 1.0
import QMLCache 1.0

Window {
  visible: true
  width: 640
  height: 480
  title: qsTr("Hello World")

  property string name: "player3"
  property double poseX: 12
  property double poseY: 13
  property double poseTheta: 5

  CelluloRobot {
      id: robotComm
      property string robotName: "robot1"
      Component.onCompleted: {}
      onZoneValueChanged: {}
      onPoseChanged: {
          console.log(x);
          console.log(y);
          console.log(theta);
          // update internal state representation
          poseX = x;
          poseY = y;
          poseTheta = theta;
      }
  }


  Timer {
      id: timer
      interval: 200;
      running: true;
      repeat: true
      // update server with robot's pose every 200ms
      onTriggered: {
          poseX += 1;
          poseY += 1;
          poseTheta -= 0.3;
          let message = {
            type : "sendPose",
            contents : {
              name : name,
              pose : { x: poseX, y: poseY, theta: poseTheta}
            }
          };
          Utils.makeRequest(message);
      }
  }

  // Robot connection items
  GroupBox {
      id: addressBox

      Column{
          spacing: 5
          Row {
            Label {
                text: "Current location: (x=" + Math.round(poseX) + ", y=" + Math.round(poseY) + ", theta=" + Math.round(poseTheta) + ")"
                font.pixelSize: 22
                font.italic: true
            }
          }
          Row {
            Button {
              onClicked: {
                let fakePose = { x: poseX, y: poseY, theta: poseTheta};
                let message = {
                  type : "sendPose",
                  contents : {
                    name : name,
                    pose : fakePose
                  }
                };
                Utils.makeRequest(message);
              }
              text: "Make request"
            }
          }
          CelluloBluetoothScanner {
              id: scanner
              onRobotDiscovered: {
                  var newAddresses = macAddrSelector.addresses;
                  if (newAddresses.indexOf(macAddr) < 0){
                      console.log(macAddr + " discovered.");
                      newAddresses.push(macAddr);
                      newAddresses.sort();
                  }
                  macAddrSelector.addresses = newAddresses;
                  QMLCache.write("addresses", macAddrSelector.addresses.join(','));
              }
          }
          Row {
              spacing: 5
              MacAddrSelector {
                  id: macAddrSelector
                  addresses: QMLCache.read("addresses").split(",")
                  onConnectRequested: {
                      robotComm.localAdapterMacAddr = selectedLocalAdapterAddress;
                      robotComm.macAddr = selectedAddress;
                  }
                  onDisconnectRequested: robotComm.disconnectFromServer()
                  connectionStatus: robotComm.connectionStatus
              }
              Button {
                  text: "Reset"
                  onClicked: robotComm.reset()
              }
          }
          Row {
              spacing: 5
              BusyIndicator {
                  running: scanner.scanning
                  height: scanButton.height
              }
              Button {
                  id: scanButton
                  text: "Scan"
                  onClicked: scanner.start()
              }
              Button {
                  text: "Clear List"
                  onClicked: {
                      macAddrSelector.addresses = [];
                      QMLCache.write("addresses","");
                  }
              }
          }


      }
  }


}
