default: switch

alias b := bootstrap
alias s := switch
alias l := list
alias ls := list
alias f := fix
alias c := check

bootstrap:
  nix develop

# Set HM_FLAKE_ATTR to your flake output name (user@hostname). Use .envrc.local (gitignored) or shell rc so each machine can differ without editing this file.
switch:
  #!/usr/bin/env bash
  set -euo pipefail
  profile="$HOME/.local/state/nix/profiles/home-manager"
  old_gen=$(readlink -f "$profile" 2>/dev/null || true)
  home-manager switch --flake ".#${HM_FLAKE_ATTR}"
  new_gen=$(readlink -f "$profile")
  if [ -n "$old_gen" ] && [ "$old_gen" != "$new_gen" ]; then
    echo ""
    echo "📦 Package changes:"
    nvd diff "$old_gen" "$new_gen"
  fi

# Build and run the oh-my-token app from source. Uses the SwiftPM build cache,
# so a rebuild after a small change takes a few seconds instead of about 45s.
app-run:
  #!/usr/bin/env bash
  set -euo pipefail
  root="$(git rev-parse --show-toplevel)"
  dir="$root/apps/oh-my-token"
  nix develop "$root#swift" --command bash -c '
    set -euo pipefail
    cd "'"$dir"'"
    swift build -c debug --product oh-my-token --disable-sandbox --disable-automatic-resolution
  '
  bin="$dir/.build/$(uname -m)-apple-macosx/debug/oh-my-token"
  app="$dir/.build/oh-my-token.app"
  rm -rf "$app"
  mkdir -p "$app/Contents/MacOS" "$app/Contents/Resources"
  cp "$dir/Info.plist" "$app/Contents/Info.plist"
  cp "$dir/AppIcon.icns" "$app/Contents/Resources/AppIcon.icns"
  cp "$bin" "$app/Contents/MacOS/oh-my-token"
  pkill -f "oh-my-token.app/Contents/MacOS/oh-my-token" 2>/dev/null || true
  open "$app"

list:
  home-manager packages

gc-dry-run:
  nix-collect-garbage --delete-older-than 2d --dry-run

gc:
  nix-collect-garbage --delete-older-than 2d

check:
  just check-eval
  just test

check-eval:
  bash bin/check-eval.sh

test:
  bats tests/

fix:
  alejandra .
  deadnix --edit .
  statix fix .

update:
  nix flake update nixpkgs-unstable
  nix flake update nixpkgs
  nix flake update llm-agents
