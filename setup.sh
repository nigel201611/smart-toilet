#!/bin/sh
# Setup script for Smart Toilet Flutter App
# Run this script after cloning the repository to initialize git hooks.

echo "=== Smart Toilet Setup ==="

echo "1. Configuring git hooks..."
git config core.hooksPath git-hooks/
echo "   -> Git hooks activated (pre-commit & pre-push)"

echo ""
echo "2. Installing dependencies..."
flutter pub get

echo ""
echo "Setup complete!"
