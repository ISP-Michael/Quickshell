import Quickshell
import Quickshell.Io
import QtQuick


PanelWindow {
  anchors {
    top: true
    right: true
    bottom: true
  }

  id: panel
  implicitWidth: 1
  exclusiveZone: 0
  color: "transparent"
  
  Rectangle {
    id: content
    implicitWidth: 30
    color: "white"
    opacity: 0

    anchors {
      top: parent.top
      bottom: parent.bottom
      right: parent.right
    }

    Behavior on opacity {
      NumberAnimation {
        duration: 300;
        easing.type: Easing.OutCubic
      }
    }

    Text {
      id: clock

      anchors {
        top: parent.top
        horizontalCenter: parent.horizontalCenter
        topMargin: 5
      }

      Process {
        id: dateProc
        command: ['date', '+%H\n%M\n%S']
        running: true
        stdout: StdioCollector {
          onStreamFinished: clock.text = this.text
        }
      }

      Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: dateProc.running = true
      }
    }

    Text {
      id: battery

      anchors {
        bottom: parent.bottom
        horizontalCenter: parent.horizontalCenter
        bottomMargin: 5
      }

      Process {
        id: batteryProc
        command: ['bat', '/sys/class/power_supply/BAT1/capacity']
        running: true
        stdout: StdioCollector {
          onStreamFinished: battery.text = this.text
        }
      }

      Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: batteryProc.running = true
      }
    }
  }

  MouseArea {
    anchors.fill: parent
    hoverEnabled: true
    onEntered: {
      panel.implicitWidth = 31
      content.opacity = 1
    }
    onExited: {
      panel.implicitWidth = 1
      content.opacity = 0
    }
  }
}
