import QtQuick 2.8
import QtQuick.Window 2.2
import QtQuick.Controls 2.0
import "methods.js" as Utils
import Cellulo 1.0
import QMLCache 1.0

Window
{
    width: login.state == "loggedIn" ? app.width : login.width
    height: login.state == "loggedIn" ? app.height : login.height
    title: qsTr("HapticCellulo")
    visible: true
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
