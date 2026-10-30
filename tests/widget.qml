import QtQuick
import Quickshell
import Quickshell.Hyprland
import "." as Plugin

ShellRoot {
  id: harness
  property var commands: []

  QtObject {
    id: host
    property bool vertical: false
    property int barSize: 26
    property string fontFamily: "sans-serif"
    property color barForeground: "white"
    property color urgent: "red"
    property bool foregroundAnimationEnabled: false
    function run(command) { harness.commands.push(command) }
    function hideTooltip(owner) {}
    function registerClickTarget(target) {}
    function unregisterClickTarget(target) {}
    function moduleWidgets(id) { return [widget] }
  }

  Plugin.Workspaces { id: widget; bar: host }

  function assert(value, message) {
    if (!value) throw new Error(message)
  }

  function buttonFor(item, id) {
    if (item.modelData === id && typeof item.triggerPress === "function") return item
    var children = item.children || []
    for (var i = 0; i < children.length; i++) {
      var button = buttonFor(children[i], id)
      if (button) return button
    }
    return null
  }

  function expectedFocus(id) {
    return "hyprctl dispatch 'hl.dsp.focus({ workspace = \"" + id + "\" })'"
  }

  function assertPress(id, expected) {
    var button = buttonFor(widget, id)
    assert(button !== null, "missing button " + id)
    harness.commands = []
    button.triggerPress(Qt.LeftButton)
    assert(harness.commands.length === 1, "button " + id + " did not issue exactly one command")
    assert(harness.commands[0] === expected, "unexpected command for " + id + ": " + harness.commands[0])
  }

  function checkInteractions() {
    try {
      var focused = Hyprland.focusedWorkspace.id
      // Exercise the reported cross-monitor button before any helper calls:
      // a handler named `focus` collides with QtQuick.Item.focus at runtime.
      var crossMonitorId = focused === 4 ? 1 : 4
      assertPress(crossMonitorId, expectedFocus(crossMonitorId))
      var ids = widget.workspaceIds()
      for (var i = 0; i < ids.length; i++) {
        var id = ids[i]
        assertPress(id, id === focused ? "omarchy-hyprland-workspace-layout-toggle" : expectedFocus(id))
      }

      var button = buttonFor(widget, focused)
      assert(button !== null, "focused workspace is missing")
      assert(button.text === widget.modeGlyph(widget.focusedMode), "focused workspace lost its layout icon")
      assert(widget.modeGlyph("dwindle") !== widget.modeGlyph("scrolling"), "layout glyphs must differ")
      assert(widget.modeGlyph("floating") !== widget.modeGlyph("scrolling"), "floating glyph must differ")

      var index = ids.indexOf(focused)
      var delta = index < ids.length - 1 ? -120 : 120
      var next = ids[index + (delta < 0 ? 1 : -1)]
      harness.commands = []
      button.wheelMoved(delta / 4)
      button.wheelMoved(delta / 4)
      button.wheelMoved(delta / 4)
      assert(harness.commands.length === 0, "partial scroll switched early")
      button.wheelMoved(delta / 4)
      assert(harness.commands.length === 1 && harness.commands[0] === expectedFocus(next), "scroll must follow global focus")

      // Empty high IDs and a vertical bar still use the same global click path.
      widget.rules = [{ workspaceString: "12" }, { workspaceString: "100" }]
      host.vertical = true
      Qt.callLater(function() {
        try {
          assertPress(12, focused === 12 ? "omarchy-hyprland-workspace-layout-toggle" : expectedFocus(12))
          assertPress(100, focused === 100 ? "omarchy-hyprland-workspace-layout-toggle" : expectedFocus(100))
          assert(widget.vertical, "vertical bar not applied")
          assert(buttonFor(widget, 12).text === (focused === 12 ? widget.modeGlyph(widget.focusedMode) : "12"), "high ID was renumbered")
          console.log("WIDGET_TEST_PASS")
        } catch (error) { console.error("WIDGET_TEST_FAIL: " + error) }
        Qt.quit()
      })
    } catch (error) {
      console.error("WIDGET_TEST_FAIL: " + error)
      Qt.quit()
    }
  }

  Timer {
    interval: 400
    repeat: true
    running: true
    onTriggered: {
      if (!Hyprland.focusedWorkspace || Hyprland.focusedWorkspace.id <= 0) return
      stop()
      harness.checkInteractions()
    }
  }
}
