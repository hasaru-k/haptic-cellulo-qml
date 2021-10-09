import QtQuick 2.8
import QtQuick.Window 2.2
import QtQuick.Controls 2.0
import QtQuick.Controls.Styles 1.2


TextField
{
    font.pixelSize: 10
    color: "#1f1f1f"
    font.weight: Font.Light
    validator: RegExpValidator { regExp: /[0-9A-za-z]+/ }
}
