import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import qs.Commons
import qs.Ui
import "WorkspacesModel.js" as Model

BarWidget {
  id: root
  moduleName: "crmne.global-workspaces"

  readonly property var monitor: {
    var window = root.QsWindow.window
    var screen = window ? window.screen : null
    return screen ? Hyprland.monitorFor(screen) : Hyprland.focusedMonitor
  }
  readonly property int activeId: root.monitor && root.monitor.activeWorkspace ? root.monitor.activeWorkspace.id : -1
  property var rules: []
  property bool rulesPending: false
  property real wheelAccumulator: 0
  readonly property var ids: Model.workspaceIds(Hyprland.workspaces.values, root.rules)

  function workspaceById(id) {
    var values = Hyprland.workspaces.values
    for (var i = 0; i < values.length; i++) if (values[i].id === id) return values[i]
    return null
  }

  function focus(id) {
    var expression = Model.focusExpression(id)
    if (root.bar && expression) root.bar.run("hyprctl dispatch " + Util.shellQuote(expression))
  }

  function readRules() {
    if (rulesProcess.running) root.rulesPending = true
    else rulesProcess.running = true
  }

  function refresh() {
    Hyprland.refreshMonitors()
    Hyprland.refreshWorkspaces()
    root.readRules()
  }

  function scroll(delta) {
    var wheel = Util.wheelSteps(root.wheelAccumulator, delta)
    root.wheelAccumulator = wheel.remainder
    if (wheel.steps === 0) return
    var index = root.ids.indexOf(root.activeId)
    if (index < 0) return
    var next = root.ids[Util.clamp(index - wheel.steps, 0, root.ids.length - 1)]
    if (next !== root.activeId) root.focus(next)
  }

  Component.onCompleted: root.refresh()

  Connections {
    target: Hyprland
    function onRawEvent(event) {
      var name = event ? String(event.name) : ""
      if (name === "configreloaded") root.readRules()
      if (["workspacev2", "focusedmon", "focusedmonv2", "moveworkspacev2", "changeworkspaceid", "configreloaded"].indexOf(name) >= 0) {
        Hyprland.refreshMonitors()
        Hyprland.refreshWorkspaces()
      }
    }
  }

  Process {
    id: rulesProcess
    command: ["hyprctl", "-j", "workspacerules"]
    stdout: StdioCollector {
      onStreamFinished: {
        try {
          var parsed = JSON.parse(text)
          if (Array.isArray(parsed)) root.rules = parsed.filter(function(rule) { return rule && typeof rule === "object" })
        } catch (_) { /* Keep the previous plan during a transient compositor failure. */ }
      }
    }
    onExited: {
      if (root.rulesPending) {
        root.rulesPending = false
        Qt.callLater(root.readRules)
      }
    }
  }

  // Omarchy routes refresh calls for the replaced stock widget here too.
  ShellIpc {
    target: "crmne.global-workspaces"
    function refresh(): void { root.broadcast("refresh") }
  }

  readonly property real trailingGap: root.vertical ? 0 : Style.spaceReal(1.5)
  implicitWidth: grid.implicitWidth + trailingGap
  implicitHeight: grid.implicitHeight

  GridLayout {
    id: grid
    anchors.fill: parent
    anchors.rightMargin: root.trailingGap
    columns: root.vertical ? 1 : root.ids.length
    columnSpacing: root.vertical ? 0 : Style.space(1)
    rowSpacing: root.vertical ? Style.space(2) : 0

    Repeater {
      model: root.ids
      WidgetButton {
        required property int modelData
        readonly property var workspace: root.workspaceById(modelData)
        readonly property bool occupied: workspace !== null && workspace.toplevels.values.length > 0
        readonly property bool shown: root.activeId === modelData
        bar: root.bar
        text: shown ? "󱓻" : Model.label(modelData)
        opacity: occupied || shown ? 1 : 0.5
        horizontalMargin: 6
        verticalPadding: 6
        fixedWidth: root.vertical ? Math.max(root.barSize, Style.space(String(modelData).length * 8 + 8)) : Style.space(Math.max(20, String(modelData).length * 8 + 8))
        fixedHeight: root.barSize
        onPressed: if (!shown) root.focus(modelData)
        onWheelMoved: function(delta) { root.scroll(delta) }
      }
    }
  }
}
