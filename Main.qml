import QtQuick 2.0
import Ubuntu.Components 1.1
import QtQuick.XmlListModel 2.0
import Ubuntu.Components.ListItems 0.1
import Ubuntu.Components.Popups 0.1
import "xmlparser.js" as API

/*!
    \brief MainView with a Label and Button elements.
*/

MainView {
    id: root
    // objectName for functional testing purposes (autopilot-qt5)
    objectName: "mainView"

    // Note! applicationName needs to match the "name" field of the click manifest
    applicationName: "currencyconverterxml.liu-xiao-guo"

    /*
     This property enables the application to change orientation
     when the device is rotated. The default is false.
    */
    //automaticOrientation: true

    // Removes the old toolbar and enables new features of the new header.
    useDeprecatedToolbar: false

    property real margins: units.gu(2)
    property real buttonWidth: units.gu(9)

    width: units.gu(50)
    height: units.gu(75)

    function convert(from, fromRateIndex, toRateIndex) {
        var fromRate = currencies.getRate(fromRateIndex);
        if (from.length <= 0 || fromRate <= 0.0)
            return "";
        return currencies.getRate(toRateIndex) * (parseFloat(from) / fromRate);
    }

    function update() {
        indicator.running = false;
    }

    Page {
        title: i18n.tr("Currency Converter")

        ListModel {
            id: currencies
            ListElement {
                currency: "EUR"
                rate: 1.0
            }

            function getCurrency(idx) {
                return (idx >= 0 && idx < count) ? get(idx).currency: ""
            }

            function getRate(idx) {
                return (idx >= 0 && idx < count) ? get(idx).rate: 0.0
            }
        }

        ActivityIndicator {
            id: indicator
            objectName: "activityIndicator"
            anchors.right: parent.right
            running: true
        }

        Component {
            id: currencySelector
            Popover {
                Column {
                    anchors {
                        top: parent.top
                        left: parent.left
                        right: parent.right
                    }
                    height: pageLayout.height
                    Header {
                        id: header
                        text: i18n.tr("Select currency")
                    }
                    ListView {
                        clip: true
                        width: parent.width
                        height: parent.height - header.height
                        model: currencies
                        delegate: Standard {
                            objectName: "popoverCurrencySelector"
                            text: model.currency
                            onClicked: {
                                caller.currencyIndex = index
                                caller.input.update()
                                hide()
                            }
                        }
                    }
                }
            }
        }

        Column {
            id: pageLayout

            anchors {
                fill: parent
                margins: root.margins
            }

            spacing: units.gu(1)

            Row {
                spacing: units.gu(1)

                Button {
                    id: selectorFrom
                    objectName: "selectorFrom"
                    property int currencyIndex: 0
                    property TextField input: inputFrom
                    text: currencies.getCurrency(currencyIndex)
                    onClicked: PopupUtils.open(currencySelector, selectorFrom)
                }

                TextField {
                    id: inputFrom
                    objectName: "inputFrom"
                    errorHighlight: false
                    validator: DoubleValidator {notation: DoubleValidator.StandardNotation}
                    width: pageLayout.width - 2 * root.margins - root.buttonWidth
                    height: units.gu(5)
                    font.pixelSize: FontUtils.sizeToPixels("medium")
                    text: '0.0'
                    onTextChanged: {
                        if (activeFocus) {
                            inputTo.text = convert(inputFrom.text, selectorFrom.currencyIndex, selectorTo.currencyIndex)
                        }
                    }

                    // This is more like a callback function
                    function update() {
                        text = convert(inputTo.text, selectorTo.currencyIndex, selectorFrom.currencyIndex)
                    }
                }
            }

            Row {
                spacing: units.gu(1)
                Button {
                    id: selectorTo
                    objectName: "selectorTo"
                    property int currencyIndex: 1
                    property TextField input: inputTo
                    text: currencies.getCurrency(currencyIndex)
                    onClicked: PopupUtils.open(currencySelector, selectorTo)
                }

                TextField {
                    id: inputTo
                    objectName: "inputTo"
                    errorHighlight: false
                    validator: DoubleValidator {notation: DoubleValidator.StandardNotation}
                    width: pageLayout.width - 2 * root.margins - root.buttonWidth
                    height: units.gu(5)
                    font.pixelSize: FontUtils.sizeToPixels("medium")
                    text: '0.0'
                    onTextChanged: {
                        if (activeFocus) {
                            inputFrom.text = convert(inputTo.text, selectorTo.currencyIndex, selectorFrom.currencyIndex)
                        }
                    }

                    function update() {
                        text = convert(inputFrom.text, selectorFrom.currencyIndex, selectorTo.currencyIndex)
                    }
                }
            }

            Button {
                id: clearBtn
                objectName: "clearBtn"
                text: i18n.tr("Clear")
                width: units.gu(12)
                onClicked: {
                    inputTo.text = '0.0';
                    inputFrom.text = '0.0';
                }
            }
        }

        Component.onCompleted: {
            API.startParse(root);
        }
    }
}

