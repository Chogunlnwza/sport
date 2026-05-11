#!/bin/bash

# Install Flutter
echo "Downloading Flutter..."
git clone https://github.com/flutter/flutter.git -b stable --depth 1
export PATH="$PATH:`pwd`/flutter/bin"

# Disable telemetry
echo "Disabling telemetry..."
flutter config --no-analytics

# Enable web support
echo "Enabling Flutter Web..."
flutter config --enable-web

# Precache Web SDK to prevent hanging during build
echo "Precaching Web SDK..."
flutter precache --web

# Get dependencies
echo "Getting dependencies..."
flutter pub get

# Build the project for the web
echo "Building Flutter Web app..."
flutter build web --web-renderer html --release
