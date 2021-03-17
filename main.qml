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

  CelluloRobot{
      id: robotComm
      property string robotName: "robot1"
      Component.onCompleted: {}
      onZoneValueChanged: {}
      onPoseChanged: {}
  }


  //Visible items
  GroupBox {
      id: addressBox

      Column{

          spacing: 5

          Row {
            Button {
              onClicked: {
                let fakePose = { x: 80, y: 66, theta: 45};
                let macAddress = "00:1B:44:11:3A:B7";
                let message = {
                  type : "sendPose",
                  contents : {
                    macAddress : macAddress,
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

              Button{
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
