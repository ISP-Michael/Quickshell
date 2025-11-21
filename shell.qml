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
  implicitWidth: 30
  // exclusiveZone: 0
  visible: true
  
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

  MouseArea {
    anchors {
      top: parent.top
      right: parent.right
      bottom: parent.bottom
    }
    width: 1
    hoverEnabled: true
    onEntered: panel.visible = true
  }

  // MouseArea {
  //   anchors.fill: parent
  //   hoverEnabled: true
  //   onExited: panel.visible = false
  // }
}
