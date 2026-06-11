# ccline

[![GitHub stars](https://img.shields.io/github/stars/jianshuo/ccline?style=flat-square)](https://github.com/jianshuo/ccline/stargazers)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue?style=flat-square)](LICENSE)

Type a thought directly at your shell prompt — no command, no prefix — and get
an answer. If the answer contains shell commands, confirm once and run them.

![ccline demo](docs/demo.gif)

```
$ how do I find files bigger than 100MB here

    find . -maxdepth 1 -type f -size +100M       (rendered, colorized)

This lists files in the current directory only.

Commands found — ↑/↓ to choose, Enter to run, q to cancel:
 ❯ find . -maxdepth 1 -type f -size +100M
   find . -type f -size +100M
   ➤ Run all of them
   ✗ Cancel
$ find . -maxdepth 1 -type f -size +100M
./big.iso
```

The answer is rendered as Markdown (headings, bold, inline code, bullets, and
colorized code blocks) when printed to a terminal.

## Why ccline?

You're in the terminal and need to remember a command. Your options:
- Leave the terminal to Google it, copy, paste back
- Open a new Claude window, ask, copy, paste back
- Open a new terminal tab, run `claude -p "..."`, copy

With ccline: just type the question where you already are. The answer appears
inline, and if there's a runnable command, one keypress executes it in your live
shell — `cd`, `export`, history and all.

## How it works

It hijacks zsh's `command_not_found_handler`. When you type something that
isn't a real command, zsh hands the whole line to ccline:

- **One word** (`gti`) → treated as a normal typo: `zsh: command not found: gti`.
- **Two or more words** → treated as a thought, sent to your LLM CLI. The answer
  is rendered as Markdown. Any runnable commands are shown in an arrow-key menu —
  **↑/↓** to move, **Enter** to run the highlighted command (or "Run all of
  them"), **q** to cancel. When stdout isn't a terminal (piped/redirected), it
  falls back to a typed prompt (`1-N`, `a`=all, Enter=none).

It uses the [`claude`](https://claude.com/claude-code) CLI if installed
(preferred), otherwise the [`codex`](https://github.com/openai/codex) CLI, then
Pi's [`pi`](https://github.com/earendil-works/pi) CLI. Force one with
`CCLINE_BACKEND=claude`, `CCLINE_BACKEND=codex`, or `CCLINE_BACKEND=pi`.

Markdown rendering uses [`glow`](https://github.com/charmbracelet/glow) if it's
installed; otherwise a built-in `perl` renderer (no extra dependency).

## Requirements

- zsh (the macOS default shell)
- One of these on your `PATH`, authenticated:
  - [`claude`](https://claude.com/claude-code) (preferred), or
  - [`codex`](https://github.com/openai/codex) (fallback), or
  - [`pi`](https://github.com/earendil-works/pi) (fallback)

## Install

**Homebrew** (recommended for macOS):

```sh
brew install jianshuo/tap/ccline
```

Then add to `~/.zshrc`:

```sh
source $(brew --prefix)/share/ccline/ccline.zsh
```

**One-line install script**:

```sh
curl -fsSL https://raw.githubusercontent.com/jianshuo/ccline/v0.2.2/install.sh | bash
```

**From a clone**:

```sh
git clone https://github.com/jianshuo/ccline.git
cd ccline && ./install.sh
```

The install script puts `ccline` in `~/.local/bin`, `ccline.zsh` in `~/.config/ccline/`,
and adds one `source` line to your `~/.zshrc`. Re-running it is safe. Then open a
new terminal (or `source ~/.zshrc`).

## Configuration

- `CCLINE_BACKEND` — force the LLM CLI: `claude`, `codex`, or `pi`. Default is
  auto-detect (`claude`, then `codex`, then `pi`).
- `CCLINE_MODEL` — override the model. The claude backend defaults to
  `claude-sonnet-4-6` (fastest end-to-end for these short prompts); set this to
  use another, e.g. `export CCLINE_MODEL=claude-opus-4-8`. Passed as `--model`
  to whichever backend is used.

## Running commands

When you trigger ccline by typing at the prompt (the normal path), the chosen
command runs in **your live shell** — so `cd`, `export`, aliases, functions, and
history all work and persist, exactly as if you'd typed it. (ccline writes the
selection to a temp file and the zsh handler `eval`s it.)

Running `ccline …` directly as a command instead runs the selection in a
subprocess, so shell-state changes like `cd` won't persist there.

## Limitations (v1)

- A bare `*` in a thought can glob-expand against the current directory. (A
  trailing `?` is handled — the integration sets `no_nomatch`.)
- Single-word thoughts won't reach Claude — by design, so typos stay fast.

## Uninstall

```sh
rm -f ~/.local/bin/ccline
rm -rf ~/.config/ccline
```
Then remove the `# ccline` block from `~/.zshrc`.

## Tests

```sh
bash tests/test_ccline.sh
```

## Fish support

Fish support is available through a separate installer:

```sh
./install-fish.sh
```

Or remotely:

```sh
curl -fsSL https://raw.githubusercontent.com/jianshuo/ccline/v0.2.2/install-fish.sh | bash
```

This installs `ccline` to `~/.local/bin` and the fish integration to
`~/.config/fish/conf.d/ccline.fish`.

To uninstall the fish integration:

```sh
rm -f ~/.local/bin/ccline
rm -f ~/.config/fish/conf.d/ccline.fish
```
