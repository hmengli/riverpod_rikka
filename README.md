# rikka

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

* [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
* [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
* [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.



git update-index --assume-unchanged windows/flutter/generated_plugin_registrant.cc
git update-index --assume-unchanged windows/flutter/generated_plugin_registrant.h
git update-index --assume-unchanged windows/flutter/generated_plugins.cmake
git update-index --assume-unchanged linux/flutter/generated_plugin_registrant.cc
git update-index --assume-unchanged linux/flutter/generated_plugin_registrant.h
git update-index --assume-unchanged linux/flutter/generated_plugins.cmake
git update-index --assume-unchanged macos/Flutter/GeneratedPluginRegistrant.swift
git update-index --assume-unchanged pubspec.lock

$env:CXXFLAGS = "-D_SILENCE_EXPERIMENTAL_COROUTINE_DEPRECATION_WARNINGS"
flutter run -d windows
dart run build_runner build
dart run build_runner watch --delete-conflicting-outputs

