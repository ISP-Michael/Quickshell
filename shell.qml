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
    width: 30
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
  }

  MouseArea {
    anchors.fill: parent
    hoverEnabled: true
    onEntered: {
      panel.width = 31
      content.opacity = 1
    }
    onExited: {
      panel.width = 1
      content.opacity = 0
    }
  }
}
