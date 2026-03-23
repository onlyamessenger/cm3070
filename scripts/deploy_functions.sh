#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
FUNCTIONS_DIR="$PROJECT_ROOT/apis/functions"

copy_packages() {
  local func_dir="$1"
  rm -rf "$func_dir/packages"
  mkdir -p "$func_dir/packages"

  cp -r "$PROJECT_ROOT/packages/core" "$func_dir/packages/core"
  cp -r "$PROJECT_ROOT/packages/infrastructure" "$func_dir/packages/infrastructure"

  # Remove files not needed for deployment
  for pkg in core infrastructure; do
    rm -rf "$func_dir/packages/$pkg/test"
    rm -rf "$func_dir/packages/$pkg/.dart_tool"
    rm -f "$func_dir/packages/$pkg/pubspec_overrides.yaml"
  done

  # Fix infrastructure's core path to be relative within the deployed directory
  sed -i '' 's|path: ../core|path: ../core|' "$func_dir/packages/infrastructure/pubspec.yaml"

  # Remove melos override
  rm -f "$func_dir/pubspec_overrides.yaml"
}

cleanup_packages() {
  local func_dir="$1"
  rm -rf "$func_dir/packages"
}

echo "Preparing functions for deployment..."
for func_dir in "$FUNCTIONS_DIR"/*/; do
  [ -f "$func_dir/pubspec.yaml" ] || continue
  func_name=$(basename "$func_dir")
  echo "  Copying packages into $func_name..."
  copy_packages "$func_dir"
done

echo "Deploying all functions..."
cd "$PROJECT_ROOT"
appwrite push functions

echo "Cleaning up..."
for func_dir in "$FUNCTIONS_DIR"/*/; do
  [ -f "$func_dir/pubspec.yaml" ] || continue
  cleanup_packages "$func_dir"
done

# Restore melos overrides
cd "$PROJECT_ROOT"
dart run melos bootstrap 2>/dev/null

echo "Done."
