# Global Workspaces for Omarchy

Keep one set of workspace numbers across your monitors. Workspace 2 means workspace 2 wherever you click it.

The bar shows the first five workspaces, every numbered workspace in your configured rules, and any other numbered workspace that exists. Each monitor highlights the workspace it is showing. Workspace 10 uses the keyboard label `0`; higher numbers keep their full IDs. Scroll to move through the displayed destinations.

## Workspace ownership

This widget changes the bar only. Use it with global workspace shortcuts and assignments, such as hyprmoncfg's global workspace plans. It does not disable Omarchy's per-monitor workspace manager, change your monitor layout, move windows, or rewrite your keyboard shortcuts.

Omarchy 4.5 RC2 introduces per-monitor numbering and has no supported global-mode toggle. A compatible hyprmoncfg build writes the workspace handoff in its existing generated Lua configuration when workspace planning is enabled. Older hyprmoncfg releases need that handoff separately. The proposed [Omarchy workspace toggle](https://github.com/omacom/omarchy/pull/16213) is another path once available.

## Install

```sh
omarchy plugin install https://github.com/crmne/omarchy-global-workspaces
```

Omarchy recognises this as a replacement for its workspace widget and preserves its position in the bar. The stock widget remains installed. Re-enable `omarchy.workspaces` to return to it, alongside restoring Omarchy's per-monitor workspace behaviour.

The plugin needs Omarchy's Quickshell bar, Hyprland, and `hyprctl`. It reads workspace rules at startup and config reload, and refreshes workspace state on compositor events. It does not poll, contact a network service, or write configuration.

## Development

```sh
node --test tests/*.test.js
```

Test the running widget on multiple monitors as well: the highlighted workspace must agree with `hyprctl -j monitors`, including after a cross-monitor focus change. Check horizontal and vertical bars and IDs above ten before publishing UI changes.

MIT licensed. The bar presentation is derived from Omarchy's workspace widget; its copyright notice is retained in `LICENSE`.
