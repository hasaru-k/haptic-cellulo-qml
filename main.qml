import QtQuick 2.8
import QtQuick.Window 2.2
import QtQuick.Controls 2.0
import "methods.js" as Utils
import Cellulo 1.0
import QMLCache 1.0

Window
{
    property int loginScreenWidth: 210
    property int loginScreenHeight: 280
    title: qsTr("HapticCellulo")
    visible: true
    minimumWidth: login.state === "loggedIn" ? app.width : loginScreenWidth
    minimumHeight: login.state === "loggedIn" ? app.height : loginScreenHeight
    maximumWidth: login.state === "loggedIn" ? app.width : loginScreenWidth
    maximumHeight: login.state === "loggedIn" ? app.height : loginScreenHeight
    Image
    {
        source: "cellulo.png"
        fillMode: Image.PreserveAspectCrop
        anchors.centerIn: parent
        visible: !(login.state === "loggedIn")
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
        onStateChanged: {
          console.log(login.userId);
          console.log(login.partnerId);
        }
    }
    App
    {
        userId: login.userId
        partnerId: login.partnerId
        id: app
        loggedIn: login.state === "loggedIn"
        OpacityAnimator on opacity
        {
            from: 0;
            to: 1;
            duration: 500
        }
    }
}
