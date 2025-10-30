import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Controls
import QtQuick.Window
import QtQuick.Layouts

Scope {
  id: root
  property bool hidden: true // Состояние скрытия бара
  property bool barHovered: false // Наведена ли мышка на бар
  property bool tooltipHovered: false // Наведена ли мышка на попап
  property bool showSeconds: false // Показывать ли секунды в часах
  property var activeTooltip: null // Активный попап для закрытия предыдущего

  // Функция проверки скрытия: если мышка не на баре и не на попапе, скрываем бар и попап
  function checkHide() {
    if (!barHovered && !tooltipHovered) {
      root.hidden = true
      if (activeTooltip) {
        activeTooltip.hide()
        activeTooltip = null
      }
    }
  }

  // Hotspot для триггера: тонкая прозрачная область на левом краю для показа бара при наведении
  Variants {
    model: Quickshell.screens

    PanelWindow {
      required property var modelData
      screen: modelData
      anchors { left: true; top: true; bottom: true }
      implicitWidth: 5
      color: "transparent"
      exclusiveZone: 0
      margins { left: 0; right: 0; top: 0; bottom: 0 }

      MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onContainsMouseChanged: if (containsMouse) root.hidden = false // Показываем бар при наведении
      }
    }
  }

  // Основной бар: вертикальный слева, скрыт за экраном, появляется с анимацией, как в caelestia (использует Behavior для анимации, PanelWindow для overlay)
  Variants {
    model: Quickshell.screens

    PanelWindow {
      id: barWindow
      required property var modelData
      screen: modelData
      anchors { left: true; top: true; bottom: true }
      implicitWidth: 50
      color: "transparent"
      exclusiveZone: 0 // Overlay, не двигает окна, как в caelestia (exclusiveZone: 0 для некоторых панелей)
      margins { left: root.hidden ? -implicitWidth : 0; top: 0; right: 0; bottom: 0 }

      Behavior on margins.left { PropertyAnimation { duration: 200; easing.type: Easing.InOutQuad } } // Анимация появления, как в caelestia (easing OutCubic, but adapted)

      // Фон: полупрозрачный, как frosted glass в caelestia (transparency base 0.85, layers 0.4)
      Rectangle {
        anchors.fill: parent
        color: "#cc1a1a1a"
        opacity: 0.8
      }

      MouseArea {
        id: barMouseArea
        anchors.fill: parent
        hoverEnabled: true
        onEntered: root.barHovered = true // Мышка на баре
        onExited: { root.barHovered = false; root.checkHide() } // Мышка ушла, проверяем скрытие
      }

      Window {
        id: tooltipWindow
        flags: Qt.ToolTip | Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint
        color: 'transparent'
        visible: false
        width: tooltipContent.width
        height: tooltipContent.height

        property bool showing: false

        opacity: 0
        Behavior on opacity {
          PropertyAnimation {
            duration: 250
            easing.type: Easing.InOutQuad // Плавное появление, как в caelestia anim durations
          }
        }

        Rectangle {
          id: tooltipContent
          width: tooltipText.contentWidth + 20
          height: tooltipText.height + 20
          color: '#e0e0e0'
          border.color: 'gray'
          radius: 5
          opacity: tooltipWindow.opacity

          Text {
            id: tooltipText
            anchors.centerIn: parent
            horizontalAlignment: Text.AlignLeft
            font.family: "monospace"
          }

          MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onEntered: root.tooltipHovered = true
            onExited: { root.tooltipHovered = false; root.checkHide(); tooltipWindow.hide() }
          }
        }

        function showAt(x, y, details, wrap = false) {
          if (root.activeTooltip && root.activeTooltip !== this) {
            root.activeTooltip.hide()
          }
          root.activeTooltip = this
          tooltipWindow.x = x
          tooltipWindow.y = y
          tooltipText.text = details
          tooltipText.wrapMode = wrap ? Text.Wrap : Text.NoWrap
          tooltipText.width = wrap ? 200 : tooltipText.contentWidth
          if (!showing) {
            showing = true
            visible = true
            opacity = 1
            root.tooltipHovered = true
          }
        }

        function hide() {
          showing = false
          opacity = 0
          root.tooltipHovered = false
          hideTimer.start()
        }
      }

      Timer {
        id: hideTimer
        interval: 250
        repeat: false
        onTriggered: { tooltipWindow.visible = false; root.checkHide(); root.activeTooltip = null }
      }

      ColumnLayout {
        anchors.fill: parent
        anchors.margins: 5 // Уменьшенные margins
        spacing: 5 // Ещё меньше расстояние

        Text {
          id: clock
          color: 'white'
          text: root.showSeconds ? Qt.formatTime(new Date(), 'hh\nmm\nss') : Qt.formatTime(new Date(), 'hh\nmm')
          Layout.alignment: Qt.AlignTop | Qt.AlignHCenter

          Timer {
            interval: 1000
            running: true
            repeat: true
            triggeredOnStart: true
            onTriggered: clock.text = root.showSeconds ? Qt.formatTime(new Date(), 'hh\nmm\nss') : Qt.formatTime(new Date(), 'hh\nmm')
          }

          MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onEntered: { root.showSeconds = true; root.barHovered = true } // Держим barHovered true
            onExited: { root.showSeconds = false; root.barHovered = false; root.checkHide() }
            onClicked: {
              let point = clock.mapToGlobal(0, 0)
              tooltipWindow.showAt(
                point.x + clock.width + 5,
                point.y - (tooltipWindow.height / 2),
                barWindow.calText,
                false
              )
            }
          }
        }

        Item {
          Layout.fillHeight: true
        }

        Text {
          id: btIcon
          color: 'white'
          text: ''
          Layout.alignment: Qt.AlignBottom | Qt.AlignHCenter
        }

        Text {
          id: wifiIcon
          color: 'white'
          Layout.alignment: Qt.AlignBottom | Qt.AlignHCenter

          property bool connected: false
          property string ssid: ""
          property int signal: 0
          property string rate: ""
          property string chan: ""
          property string security: ""

          Timer {
            interval: 30000
            running: true
            repeat: true
            triggeredOnStart: true
            onTriggered: wifiReader.running = true
          }

          Process {
            id: wifiReader
            command: ["nmcli", "-m", "tabular", "-f", "IN-USE,SSID,BARS,RATE,CHAN,SECURITY", "device", "wifi"]
            stdout: StdioCollector {
              onStreamFinished: barWindow.parseWifi(this.text)
            }
          }

          function updateIcon() {
            text = connected ? '󰖩' : '󰖪' // Ваша исходная иконка Wi-Fi, как в запросе
          }
        }

        MouseArea {
          anchors.fill: wifiIcon
          hoverEnabled: true
          onEntered: root.barHovered = true // Держим barHovered true
          onExited: { root.barHovered = false; root.checkHide() }
          onClicked: {
            let point = wifiIcon.mapToGlobal(0, 0)
            let details = wifiIcon.connected ?
              "SSID: " + wifiIcon.ssid + "\nRate: " + wifiIcon.rate + "\nSignal: " + wifiIcon.signal + "%\nChan: " + wifiIcon.chan + "\nSecurity: " + wifiIcon.security :
              "Не подключено"
            tooltipWindow.showAt(
              point.x + wifiIcon.width + 5,
              point.y - (tooltipWindow.height / 2),
              details,
              true
            )
          }
        }

        Text {
          id: batteryIcon
          color: 'white'
          Layout.alignment: Qt.AlignBottom | Qt.AlignHCenter

          property string rawOutput: ""

          function getBatteryIcon() {
            if (batteryLevel > 75) return "🔋████"
            if (batteryLevel > 50) return "🔋███ "
            if (batteryLevel > 25) return "🔋██  "
            return "🔋█   "
          }

          property int batteryLevel: 0
          property string batteryStatus: 'Unknown'

          Timer {
            interval: 1000
            running: true
            repeat: true
            triggeredOnStart: true
            onTriggered: batteryReader.running = true
          }

          Process {
            id: batteryReader
            command: ['acpi', '-b']
            stdout: StdioCollector {
              onStreamFinished: {
                if (!this.text) return
                batteryIcon.rawOutput = this.text
                let output = this.text
                if (output.includes('Discharging')) batteryIcon.batteryStatus = 'Discharging'
                else if (output.includes('Not charging')) batteryIcon.batteryStatus = 'Not charging'
                else if (output.includes('Charging')) batteryIcon.batteryStatus = 'Charging'
                else if (output.includes('Full')) batteryIcon.batteryStatus = 'Full'
                else batteryIcon.batteryStatus = 'Unknown'

                let percentageMatch = output.match(/(\d+)%/)
                if (percentageMatch) batteryIcon.batteryLevel = parseInt(percentageMatch[1])

                batteryIcon.text = batteryIcon.getBatteryIcon()
              }
            }
          }
        }

        MouseArea {
          anchors.fill: batteryIcon
          hoverEnabled: true
          onEntered: root.barHovered = true // Держим barHovered true
          onExited: { root.barHovered = false; root.checkHide() }
          onClicked: {
            let point = batteryIcon.mapToGlobal(0, 0)
            tooltipWindow.showAt(
              point.x + batteryIcon.width + 5,
              point.y - (tooltipWindow.height / 2),
              batteryIcon.rawOutput,
              true
            )
          }
        }
      }

      property string calText: ""

      Process {
        id: calProc
        command: ["cal"]
        stdout: StdioCollector {
          onStreamFinished: barWindow.processCal(this.text)
        }
        Component.onCompleted: running = true
      }

      Timer {
        interval: 86400000 // 24 часа
        running: true
        repeat: true
        onTriggered: calProc.running = true
      }

      property bool btConnected: false

      Timer {
        interval: 30000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: btReader.running = true
      }

      Process {
        id: btReader
        command: ["bluetoothctl", "devices", "Connected"]
        stdout: StdioCollector {
          onStreamFinished: barWindow.btConnected = (this.text.trim() !== "")
        }
      }

      function processCal(text) {
        let lines = text.split('\n')
        let dayStr = new Date().getDate().toString().padStart(2, ' ')
        let regex = new RegExp('(^|\\s)' + dayStr.replace(/ /g, '\\s?') + '(\\s|$)')
        for (let i = 0; i < lines.length; i++) {
          lines[i] = lines[i].replace(regex, function(match) { return match.replace(dayStr, '<font color="red">' + dayStr + '</font>') })
        }
        calText = lines.join('\n')
      }

      function parseWifi(text) {
        let lines = text.split('\n')
        wifiIcon.connected = false
        for (let line of lines) {
          if (line.startsWith('*')) {
            let fields = line.split('\t')
            wifiIcon.connected = true
            wifiIcon.ssid = fields[1] || ""
            wifiIcon.signal = fields[2] ? fields[2].length * 25 : 0
            wifiIcon.rate = fields[3] || ""
            wifiIcon.chan = fields[4] || ""
            wifiIcon.security = fields[5] || ""
            break
          }
        }
        wifiIcon.updateIcon()
      }
    }
  }
}
