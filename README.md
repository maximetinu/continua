# continua

> You hit your usage limit. Try again at 15:45.

`continua` types `continue` + Enter into one specific [Ghostty](https://ghostty.org) tab at the time you choose. Start it, pick the tab where Codex (or Claude Code, or any terminal agent) stopped, type the time, and walk away. When the time comes, it brings that tab to the front and sends the message.

It does not detect anything and it does not run in the background. It does one thing while it is open. Close it and the plan is cancelled.

```
continua  · q or Ctrl+C quits and cancels

  Tab:   w1 tab 3  codex      ~/git/myproject  myproject · fix the flaky test
  Text:  'continue' + Enter   mode paste, Enter after 400 ms

  Fires at: 15:45:00   in 1h 12m 08s

  [t] test now  [5] test in 5 s  [0] test in 10 s  [f] focus only  [c] change time  [q] quit
```

## Install

```sh
curl -fsSL https://raw.githubusercontent.com/maximetinu/continua/main/install.sh | sh
```

This puts a single Python file in `~/.local/bin/continua` (set `CONTINUA_BIN_DIR` to change it). There are no dependencies beyond `python3` (3.8+), which macOS gives you with the Command Line Tools.

To uninstall: `rm ~/.local/bin/continua`.

**Requirements:** macOS and a Ghostty build with AppleScript support. Tested on macOS 26 with Ghostty 1.4.0. Linux is not supported (yet).

## Usage

```sh
continua                              # wizard: pick a tab, enter a time, wait
continua -t codex --at 15:45          # no wizard: match a tab by process, folder or title
continua -t codex --in 2h13m
continua -t codex --at 3:45pm --text "go on"
continua --list                       # list Ghostty terminals and their ids
continua -t <id> --test               # send now and exit
```

Time formats: `15:45`, `15:45:30`, `3:45pm`, `+2h13m`, `2h 13m`, `in 2 hours 13 minutes`, `45m`, `90s`, `45` (minutes). A clock time that already passed today means tomorrow.

While it waits:

| Key | Action |
| --- | --- |
| `t` | Test now: focus the tab and send the text |
| `5` / `0` | Test in 5 / 10 seconds, so you can switch to another app and check that focus comes back |
| `f` | Focus only, without typing |
| `c` | Change the time |
| `q`, `Esc`, `Ctrl+C` | Quit and cancel |

Note: a test sends the real text. If the agent is idle, it will start working. Use `f` to test focus only.

### Options

| Option | Default | Meaning |
| --- | --- | --- |
| `--text` | `continue` | Text to type. You can also set `CONTINUA_TEXT` in your shell profile. |
| `--mode` | `paste` | `paste` or `keystroke` (see below). |
| `--enter-ms` | `400` | Pause between the text and Enter. |
| `--margin` | `0` | Extra seconds after the given time. |
| `--exit-after` | off | Exit after it fires. |

## How it works

Ghostty has an AppleScript dictionary. `continua` uses it to:

1. List every terminal with its stable id, tab, working directory, title and foreground process.
2. At the set time, focus that terminal (`activate` + `focus`) and check that Ghostty is frontmost with that terminal focused. It retries up to 3 times.
3. Send the text straight to that terminal surface (`input text`), wait `--enter-ms`, then `send key "enter"`.

Because step 3 targets the terminal by id, the text lands in the right tab even if focus fails or the screen is locked. Nothing goes to whatever window happens to be in front.

`--mode keystroke` replaces step 3 with real key events from System Events. It types only after step 2 confirms focus. This mode needs Accessibility permission for your terminal (System Settings → Privacy & Security → Accessibility).

The pause before Enter matters: some TUIs treat text followed at once by Enter as a paste, and insert a newline instead of submitting.

While it waits, `caffeinate -is` keeps the Mac awake, and it stops when `continua` exits. A closed lid on battery still sleeps.

The first time, macOS can ask you to let your terminal control Ghostty (Automation permission). Allow it.

## License

[WTFPL](LICENSE). Do what you want.
