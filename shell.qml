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
  exclusiveZone: 0
  color: 'transparent'

  Rectangle {
    id: trigger
    implicitWidth: 1
    color: 'transparent'

    anchors {
      top: parent.top
      bottom: parent.bottom
      right: parent.right
    }

    MouseArea {
      anchors.fill: parent
      hoverEnabled: true
      onEntered: {
        content.x = panel.width - content.width
        trigger.width = 30
      }
      onExited: {
        content.x = panel.width
        trigger.width = 1
      }
    }
  }

  Rectangle {
    id: content
    implicitWidth: 30
    color: '#ffffff'
    width: 30
    height: parent.height
    x: panel.width

    Behavior on x {
      NumberAnimation {
        duration: 500;
        easing.type: Easing.OutCubic
      }
    }

    Text {
      id: clock
      font {
        weight: 900
      }

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
      font {
        weight: 900
      }

      anchors {
        bottom: parent.bottom
        horizontalCenter: parent.horizontalCenter
        bottomMargin: 5
      }

      Process {
        id: batteryProc
        command: ['cat', '/sys/class/power_supply/BAT1/capacity']
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

    Text {
      id: bright
      font {
        weight: 900
      }

      anchors {
        bottom: parent.bottom
        horizontalCenter: parent.horizontalCenter
        bottomMargin: 20
      }

      Process {
        id: brightProc
        command: ['sh', '-c', './scripts/bright.sh > ./tmp/bright.txt && cat ./tmp/bright.txt']
        running: true
        stdout: StdioCollector {
          onStreamFinished: bright.text = this.text
        }
      }

      Timer {
        interval: 100
        running: true
        repeat: true
        onTriggered: brightProc.running = true
      }
    }
    
    Text {
      id: volume
      font {
        weight: 900
      }

      anchors {
        bottom: parent.bottom
        horizontalCenter: parent.horizontalCenter
        bottomMargin: 35
      }

      Process {
        id: volumeProc
        command: ['sh', '-c', './scripts/pa.sh > ./tmp/pa.txt && cat ./tmp/pa.txt']
        running: true
        stdout: StdioCollector {
          onStreamFinished: volume.text = this.text
        }
      }

      Timer {
        interval: 100
        running: true
        repeat: true
        onTriggered: volumeProc.running = true
      }
    }
  }
}

