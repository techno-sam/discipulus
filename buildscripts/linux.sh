#!/bin/bash

echo "Building Rust..."
cargo build --release
echo "Building Flutter..."
flutter build linux --release
echo "Done"