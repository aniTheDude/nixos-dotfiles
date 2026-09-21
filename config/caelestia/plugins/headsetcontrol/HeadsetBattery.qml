import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Caelestia.Config
import qs.components
import qs.components.controls
import qs.services
import qs.utils

StyledRect {
    id: root

    property var screenState: null
    property bool hasDevice: false
    property string deviceName: "Headset"
    property int batteryLevel: -1
    property string batteryStatus: "BATTERY_UNAVAILABLE"
    readonly property bool isCharging: batteryStatus === "BATTERY_CHARGING"
    property int timeToEmpty: -1
    property int timeToFull: -1
    property int chatmix: -1
    property bool isRefreshing: false
    readonly property bool shouldShow: true

    function formatTime(min) {
        if (!min || min <= 0)
            return "";
        const h = Math.floor(min / 60);
        const m = min % 60;
        return h > 0 ? `${h}h ${m}m` : `${m}m`;
    }

    function refresh() {
        if (!proc.running) {
            root.isRefreshing = true;
            proc.running = true;
        }
    }

    onScreenStateChanged: {
        if (screenState && screenState.sidebar) {
            refresh();
        }
    }

    Connections {
        target: root.screenState

        function onSidebarChanged() {
            if (root.screenState && root.screenState.sidebar) {
                root.refresh();
            }
        }
    }

    Timer {
        id: pollTimer

        interval: 30000
        repeat: true
        running: true
        onTriggered: root.refresh()
    }

    Process {
        id: proc

        command: ["headsetcontrol", "-o", "json"]

        stdout: StdioCollector {
            onStreamFinished: {
                root.isRefreshing = false;
                try {
                    const data = JSON.parse(text);
                    if (data && data.devices && data.devices.length > 0) {
                        const dev = data.devices[0];
                        root.hasDevice = true;
                        root.deviceName = dev.product || dev.device || "Headset";

                        if (dev.battery) {
                            root.batteryLevel = typeof dev.battery.level === "number" ? dev.battery.level : -1;
                            root.batteryStatus = dev.battery.status || "BATTERY_AVAILABLE";
                            root.timeToEmpty = typeof dev.battery.time_to_empty_min === "number" ? dev.battery.time_to_empty_min : -1;
                            root.timeToFull = typeof dev.battery.time_to_full_min === "number" ? dev.battery.time_to_full_min : -1;
                        } else {
                            root.batteryLevel = -1;
                            root.batteryStatus = "BATTERY_UNAVAILABLE";
                        }

                        if (typeof dev.chatmix === "number") {
                            root.chatmix = dev.chatmix;
                        } else {
                            root.chatmix = -1;
                        }
                    } else {
                        root.hasDevice = false;
                        root.batteryLevel = -1;
                        root.batteryStatus = "BATTERY_UNAVAILABLE";
                    }
                } catch (e) {
                    root.hasDevice = false;
                    root.isRefreshing = false;
                }
            }
        }

        onRunningChanged: {
            if (!running)
                root.isRefreshing = false;
        }
    }

    Component.onCompleted: refresh()

    radius: Tokens.rounding.large
    color: Colours.tPalette.m3surfaceContainer
    clip: true

    implicitWidth: layout.implicitWidth + Tokens.padding.large * 2
    implicitHeight: layout.implicitHeight + Tokens.padding.large * 2

    ColumnLayout {
        id: layout

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: Tokens.padding.large
        spacing: Tokens.spacing.small

        RowLayout {
            Layout.fillWidth: true
            spacing: Tokens.spacing.medium

            // Circular badge with headphones icon
            StyledRect {
                implicitWidth: implicitHeight
                implicitHeight: icon.implicitHeight + Tokens.padding.large
                radius: Tokens.rounding.full

                color: {
                    if (!root.hasDevice)
                        return Colours.palette.m3surfaceContainerHigh;
                    if (root.isCharging)
                        return Colours.palette.m3primary;
                    if (root.batteryLevel >= 0 && root.batteryLevel < 20)
                        return Colours.palette.m3error;
                    return Colours.palette.m3secondaryContainer;
                }

                MaterialIcon {
                    id: icon
                    anchors.centerIn: parent
                    text: root.hasDevice ? "headphones" : "headset_off"
                    fontStyle: Tokens.font.icon.large
                    color: {
                        if (!root.hasDevice)
                            return Colours.palette.m3onSurfaceVariant;
                        if (root.isCharging)
                            return Colours.palette.m3onPrimary;
                        if (root.batteryLevel >= 0 && root.batteryLevel < 20)
                            return Colours.palette.m3onError;
                        return Colours.palette.m3onSecondaryContainer;
                    }
                }

                Behavior on color {
                    CAnim {}
                }
            }

            // Text info
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0

                StyledText {
                    Layout.fillWidth: true
                    text: root.hasDevice ? root.deviceName : qsTr("Headset Offline")
                    font: Tokens.font.body.medium
                    elide: Text.ElideRight
                }

                StyledText {
                    Layout.fillWidth: true
                    font: Tokens.font.body.small
                    color: Colours.palette.m3onSurfaceVariant
                    elide: Text.ElideRight
                    text: {
                        if (!root.hasDevice)
                            return qsTr("No supported device detected");
                        if (root.isCharging) {
                            if (root.batteryLevel >= 0)
                                return qsTr("Charging • %1%").arg(root.batteryLevel);
                            return qsTr("Charging");
                        }
                        if (root.batteryLevel >= 0) {
                            const timeStr = root.formatTime(root.timeToEmpty);
                            if (timeStr.length > 0)
                                return qsTr("%1% • ~%2 remaining").arg(root.batteryLevel).arg(timeStr);
                            return qsTr("%1% remaining").arg(root.batteryLevel);
                        }
                        return qsTr("Battery level unknown");
                    }
                }
            }

            // Battery percentage badge or icon
            RowLayout {
                spacing: Tokens.spacing.extraSmall
                visible: root.hasDevice && root.batteryLevel >= 0

                MaterialIcon {
                    text: Icons.getBatteryIcon(root.batteryLevel / 100, root.isCharging)
                    fontStyle: Tokens.font.icon.medium
                    color: {
                        if (root.isCharging)
                            return Colours.palette.m3primary;
                        if (root.batteryLevel < 20)
                            return Colours.palette.m3error;
                        return Colours.palette.m3onSurface;
                    }
                }

                StyledText {
                    text: `${root.batteryLevel}%`
                    font: Tokens.font.body.medium
                }
            }

            // Refresh button
            IconButton {
                icon: "refresh"
                type: IconButton.Text
                onClicked: root.refresh()

                RotationAnimation on rotation {
                    running: root.isRefreshing
                    from: 0
                    to: 360
                    duration: 1000
                    loops: Animation.Infinite
                }
            }
        }

        // Progress bar for battery level
        StyledRect {
            Layout.fillWidth: true
            Layout.topMargin: Tokens.spacing.extraSmall
            implicitHeight: 4
            radius: Tokens.rounding.full
            color: Colours.palette.m3surfaceContainerHighest
            visible: root.hasDevice && root.batteryLevel >= 0

            StyledRect {
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                implicitWidth: parent.width * Math.max(0, Math.min(1, root.batteryLevel / 100))
                radius: Tokens.rounding.full

                color: {
                    if (root.isCharging)
                        return Colours.palette.m3primary;
                    if (root.batteryLevel < 20)
                        return Colours.palette.m3error;
                    return Colours.palette.m3primary;
                }

                Behavior on implicitWidth {
                    Anim {}
                }

                Behavior on color {
                    CAnim {}
                }
            }
        }

        // Chatmix balance indicator (SteelSeries Arctis support)
        RowLayout {
            Layout.fillWidth: true
            Layout.topMargin: Tokens.spacing.extraSmall / 2
            visible: root.hasDevice && root.chatmix >= 0

            MaterialIcon {
                text: "sports_esports"
                fontStyle: Tokens.font.icon.small
                color: Colours.palette.m3onSurfaceVariant
            }

            StyledText {
                text: {
                    if (root.chatmix === 64)
                        return qsTr("ChatMix: Balanced (Game 50% / Chat 50%)");
                    const gamePercent = Math.round(((128 - root.chatmix) / 128) * 100);
                    const chatPercent = 100 - gamePercent;
                    return qsTr("ChatMix: Game %1% / Chat %2%").arg(gamePercent).arg(chatPercent);
                }
                font: Tokens.font.label.small
                color: Colours.palette.m3onSurfaceVariant
            }
        }
    }

    Behavior on implicitHeight {
        Anim {}
    }
}
