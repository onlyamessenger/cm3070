#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
FUNCTIONS_DIR="$PROJECT_ROOT/apis/functions"

FUNCTION_ID="${1:-}"
if [ -z "$FUNCTION_ID" ]; then
  echo "Usage: ./scripts/deploy_function.sh <function-id>"
  exit 1
fi

FUNC_DIR="$FUNCTIONS_DIR/$FUNCTION_ID"
if [ ! -f "$FUNC_DIR/pubspec.yaml" ]; then
  echo "Error: Function '$FUNCTION_ID' not found at $FUNC_DIR"
  exit 1
fi

echo "Copying packages into $FUNCTION_ID..."
rm -rf "$FUNC_DIR/packages"
mkdir -p "$FUNC_DIR/packages"

cp -r "$PROJECT_ROOT/packages/core" "$FUNC_DIR/packages/core"
cp -r "$PROJECT_ROOT/packages/infrastructure" "$FUNC_DIR/packages/infrastructure"

# Remove files not needed for deployment
for pkg in core infrastructure; do
  rm -rf "$FUNC_DIR/packages/$pkg/test"
  rm -rf "$FUNC_DIR/packages/$pkg/.dart_tool"
  rm -f "$FUNC_DIR/packages/$pkg/pubspec_overrides.yaml"
done

# Remove melos override
rm -f "$FUNC_DIR/pubspec_overrides.yaml"

echo "Deploying function: $FUNCTION_ID"
cd "$PROJECT_ROOT"
appwrite push function -f "$FUNCTION_ID"

echo "Cleaning up..."
rm -rf "$FUNC_DIR/packages"

# Restore melos overrides
cd "$PROJECT_ROOT"
dart run melos bootstrap 2>/dev/null

echo "Done."
