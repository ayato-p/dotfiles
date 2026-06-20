#!/usr/bin/env bash
# KDE(KWin) のグローバルショートカットは fcitx5 より先にキーを掴むため、
# "Walk Through Windows of Current Application" が既定の Alt+` を奪うと
# fcitx5 のトグル(Alt+`)が効かなくなる。
# アクティブショートカットを Meta+` に固定して Alt+` を解放する。
set -euo pipefail

# KDE 環境以外（kwriteconfig6 が無い）では何もしない
command -v kwriteconfig6 >/dev/null 2>&1 || exit 0

key='Walk Through Windows of Current Application'
# 書式: アクティブ,デフォルト,表示名 （複数キーはタブ区切り）
value=$'Meta+`,Meta+`\tAlt+`,Walk Through Windows of Current Application'

# 既に希望値ならデーモン再起動を避けて終了（冪等）
if command -v kreadconfig6 >/dev/null 2>&1; then
  current=$(kreadconfig6 --file kglobalshortcutsrc --group kwin --key "$key" 2>/dev/null || true)
  [ "$current" = "$value" ] && exit 0
fi

kwriteconfig6 --file kglobalshortcutsrc --group kwin --key "$key" "$value"

# 反映: kglobalacceld を再起動（失敗しても無視。最悪 再ログインで反映される）
if command -v kquitapp6 >/dev/null 2>&1; then
  kquitapp6 kglobalacceld >/dev/null 2>&1 || true
  for d in \
    /usr/lib/x86_64-linux-gnu/libexec/kglobalacceld \
    /usr/libexec/kglobalacceld \
    "$(command -v kglobalacceld 2>/dev/null || true)"; do
    if [ -n "$d" ] && [ -x "$d" ]; then
      ( setsid "$d" >/dev/null 2>&1 & ) || true
      break
    fi
  done
fi

echo 'KDE: Alt+` を fcitx5 用に解放しました（Walk Through Windows of Current Application -> Meta+`）'
