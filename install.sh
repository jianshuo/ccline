#!/usr/bin/env bash
#
# Install ccline. Works two ways:
#   • from a local clone:   ./install.sh
#   • remotely:             curl -fsSL <raw-url>/install.sh | bash
#
# Idempotent — safe to re-run.

set -euo pipefail

# Pinned to a release tag so the install command is stable across future
# changes. Override with CCLINE_REF=main (or another tag) to install elsewhere.
REPO="jianshuo/ccline"
REF="${CCLINE_REF:-v0.2.2}"
RAW="https://raw.githubusercontent.com/${REPO}/${REF}"

BIN_DIR="${HOME}/.local/bin"
CFG_DIR="${HOME}/.config/ccline"
ZSHRC="${HOME}/.zshrc"
SOURCE_LINE="source ${CFG_DIR}/ccline.zsh"

# Find source files: prefer a local clone; otherwise download from GitHub.
SRC_DIR=""
if [ -n "${BASH_SOURCE:-}" ] && [ -f "${BASH_SOURCE[0]}" ]; then
  maybe="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  if [ -f "${maybe}/ccline" ] && [ -f "${maybe}/ccline.zsh" ]; then
    SRC_DIR="$maybe"
  fi
fi

cleanup=""
if [ -z "$SRC_DIR" ]; then
  echo "Downloading ccline from ${REPO}…"
  SRC_DIR="$(mktemp -d)"
  cleanup="$SRC_DIR"
  for f in ccline ccline.zsh; do
    if ! curl -fsSL "${RAW}/${f}" -o "${SRC_DIR}/${f}"; then
      echo "ccline: failed to download ${f} from ${RAW}/${f}" >&2
      rm -rf "$cleanup"
      exit 1
    fi
  done
fi

mkdir -p "$BIN_DIR" "$CFG_DIR"
install -m 0755 "${SRC_DIR}/ccline" "${BIN_DIR}/ccline"
install -m 0644 "${SRC_DIR}/ccline.zsh" "${CFG_DIR}/ccline.zsh"
[ -n "$cleanup" ] && rm -rf "$cleanup"

echo "Installed:"
echo "  ${BIN_DIR}/ccline"
echo "  ${CFG_DIR}/ccline.zsh"

if [ -f "$ZSHRC" ] && grep -qF "$SOURCE_LINE" "$ZSHRC"; then
  echo "~/.zshrc already sources ccline — nothing to add."
else
  {
    echo ""
    echo "# ccline — type a thought at your shell, get an answer"
    echo "$SOURCE_LINE"
  } >> "$ZSHRC"
  echo "Added ccline source line to ${ZSHRC}."
fi

case ":${PATH}:" in
  *":${BIN_DIR}:"*) ;;
  *) echo "NOTE: ${BIN_DIR} is not on your PATH. Add it in ~/.zshrc." ;;
esac

if ! command -v claude >/dev/null 2>&1 \
  && ! command -v codex >/dev/null 2>&1 \
  && ! command -v pi >/dev/null 2>&1; then
  echo "NOTE: no supported LLM CLI was found. ccline needs one:"
  echo "      Claude Code: https://claude.com/claude-code"
  echo "      Codex:       https://github.com/openai/codex"
  echo "      Pi:          https://github.com/earendil-works/pi"
fi

echo
echo "Done. Open a new terminal (or run: source ~/.zshrc) and just type a thought:"
echo "    how do I find files bigger than 100MB here"
