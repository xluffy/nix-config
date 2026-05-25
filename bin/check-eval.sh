#!/usr/bin/env bash

set -euo pipefail

# 1. Discover all defined homeConfigurations
echo "🔍 Discovering defined homeConfigurations..."
configs=$(nix eval --json .#homeConfigurations --apply 'builtins.attrNames')

echo "📦 Found configurations: ${configs}"

# 2. Iterate and evaluate each configuration's activation package
for config in $(echo "${configs}" | jq -r '.[]'); do
  echo "⏳ Evaluating configuration: ${config}..."
  nix eval --json ".#homeConfigurations.\"${config}\".activationPackage.outPath" >/dev/null
  echo "✅ ${config} evaluated successfully!"
done

echo "🎉 All homeConfigurations evaluated successfully!"
