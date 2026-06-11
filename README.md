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

-- WARNING: This schema is for context only and is not meant to be run.
-- Table order and constraints may not be valid for execution.

CREATE TABLE public.ParserEntity (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  name character varying DEFAULT ''::character varying UNIQUE,
  basisUrl character varying,
  searchUrl character varying,
  searchHref character varying,
  searchTitle character varying,
  chapterRoad character varying,
  chapterList character varying,
  selectorIframe character varying,
  selectorVideo character varying,
  referer character varying,
  CONSTRAINT ParserEntity_pkey PRIMARY KEY (id)
);