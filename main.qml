import QtQuick 2.8
import QtQuick.Window 2.2
import QtQuick.Controls 2.0
import "methods.js" as Utils
import Cellulo 1.0
import QMLCache 1.0

Window
{
    minimumWidth: login.state == "loggedIn" ? app.width : 300
    minimumHeight: login.state == "loggedIn" ? app.height : 400
    maximumWidth: login.state == "loggedIn" ? app.width : 300
    maximumHeight: login.state == "loggedIn" ? app.height : 400
    title: qsTr("HapticCellulo")
    visible: true
    Image
    {
        source: "cellulo.png"
        fillMode: Image.PreserveAspectCrop
        anchors.centerIn: parent
        visible: login.state != "loggedIn"
    }
    App
    {
        id: app
        loggedIn: false
        visible: login.state == "loggedIn"
        OpacityAnimator on opacity
        {
            from: 0;
            to: 1;
            duration: 500
        }
    }
    Login
    {
        id: login
        OpacityAnimator on opacity
        {
            from: 0;
            to: 1;
            duration: 500
        }
    }
}
