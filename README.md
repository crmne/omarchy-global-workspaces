# Global Workspaces for Omarchy

Keep one set of workspace numbers across your monitors. Workspace 2 means workspace 2 wherever you click it.

This restores Omarchy's workspace widget from immediately before per-monitor numbering. Every bar shows the same global numbers and highlights the currently focused workspace. Clicking another number focuses that workspace, including on another monitor. Clicking the focused workspace cycles its layout: a square for tiling, a circle for scrolling, and a triangle for floating. Scroll to move through the displayed destinations.

The bar shows the first five workspaces, every numbered workspace in your configured rules, and any other numbered workspace that exists. Workspace 10 uses the keyboard label `0`; higher numbers keep their full IDs.

## Workspace ownership

This widget changes the bar only. Use it with global workspace shortcuts and assignments, such as hyprmoncfg's global workspace plans. It does not disable Omarchy's per-monitor workspace manager, change your monitor layout, move windows, or rewrite your keyboard shortcuts.

Omarchy 4.5 RC2 introduces per-monitor numbering and has no supported global-mode toggle. A compatible hyprmoncfg build writes the workspace handoff in its existing generated Lua configuration when workspace planning is enabled. Older hyprmoncfg releases need that handoff separately. The proposed [Omarchy workspace toggle](https://github.com/omacom/omarchy/pull/16213) is another path once available.

## Install

```sh
omarchy plugin install https://github.com/crmne/omarchy-global-workspaces
```

Omarchy recognises this as a replacement for its workspace widget and preserves its position in the bar. The stock widget remains installed. Re-enable `omarchy.workspaces` to return to it, alongside restoring Omarchy's per-monitor workspace behaviour.

The plugin needs Omarchy's Quickshell bar, Hyprland, `hyprctl`, and Omarchy's workspace layout commands. It reads workspace rules at startup and config reload, and refreshes workspace state on compositor events. Like the original widget, clicking the focused layout icon runs Omarchy's layout toggle, which saves that workspace's layout. It does not poll, contact a network service, or rewrite workspace assignments or shortcuts.

To remove it:

```sh
omarchy plugin remove crmne.global-workspaces
```

Re-enable the stock `omarchy.workspaces` widget in the bar settings if returning to Omarchy's per-monitor workspace manager.

## Development

```sh
node --test tests/*.test.js
ruby tests/widget.rb
```

The widget test needs an Omarchy session and Quickshell. It loads the actual QML and Omarchy UI components, then exercises button presses and scrolling with commands captured instead of executed. It never injects keyboard or mouse input. Check the running widget on multiple monitors too: both bars should highlight the globally focused workspace, including after a cross-monitor focus change.

MIT licensed. The widget is based on [Omarchy's original global workspace component](https://github.com/omacom/omarchy/blob/dd07b6269f0dd2a059b8ed5b4124f5adde74d389/shell/plugins/bar/widgets/Workspaces.qml). The additions keep configured empty workspaces and IDs above ten visible, and refresh state after cross-monitor changes. Omarchy's copyright notice is retained in `LICENSE`.
