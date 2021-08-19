import QtQuick 2.8
import QtQuick.Window 2.2
import QtQuick.Controls 2.0
import QtQuick.Controls.Styles 1.2


Button
{
  text: "SuccessButton"
  property string buttonColor: "#16c780"
  font.pixelSize: 12
  font.weight: Font.Light
  background: Rectangle {
      color: buttonColor
      radius: 5
      width: parent.width
  }
  anchors.horizontalCenter: parent.horizontalCenter
}
