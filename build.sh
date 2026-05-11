#!/bin/bash

# Install Flutter
echo "Downloading Flutter..."
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:`pwd`/flutter/bin"

# Disable telemetry to prevent interactive prompts from hanging the CI
echo "Disabling telemetry..."
flutter --disable-telemetry
flutter config --no-analytics

# Enable web support
echo "Enabling Flutter Web..."
flutter config --enable-web

# Get dependencies
echo "Getting dependencies..."
flutter pub get

# Build the project for the web
echo "Building Flutter Web app..."
flutter build web --release
