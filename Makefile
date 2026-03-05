NAME := $(shell grep '^name:' pubspec.yaml | awk '{print $$2}')
VERSION := $(shell grep '^version:' pubspec.yaml | awk -F "+" '{print $$1}' | awk '{print $$2}')
BUILD_NUMBER := $(shell grep '^version:' pubspec.yaml | awk -F "+" '{print $$2}' | xargs)
APK_RELEASE_PATH := build/app/outputs/flutter-apk/app-release.apk
APK_DIR := build/app/outputs/flutter-apk/

generate:
	flutter pub run build_runner build --delete-conflicting-outputs

watch:
	flutter pub run build_runner watch

slang:
	flutter pub run slang

clean:
	flutter clean
	yes | flutter pub cache clean
	flutter pub get

format:
	dart format --output=write lib test

format_check:
	dart format --output=none --set-exit-if-changed lib test

build_web:
	flutter build web --release -t lib/main.dart --dart-define-from-file=env.json

build_apk:
	flutter build apk --release -t lib/main.dart --dart-define-from-file=env.json

build_app_bundle:
	flutter build appbundle --release -t lib/main.dart --dart-define-from-file=env.json

build_macos:
	flutter build macos --release -t lib/main.dart --dart-define-from-file=env.json

build_linux:
	flutter build linux --release -t lib/main.dart --dart-define-from-file=env.json

build_windows:
	flutter build windows --release -t lib/main.dart --dart-define-from-file=env.json

ci_web:
	make clean
	make generate
	make slang
	make build_web

ci_apk:
	make clean
	make generate
	make slang
	make build_apk

ci_linux:
	make clean
	make generate
	make slang
	make build_linux

ci_windows:
	make clean
	make generate
	make slang
	make build_windows

rename_apk:
	@if [ -f $(APK_RELEASE_PATH) ]; then \
		mv $(APK_RELEASE_PATH) $(APK_DIR)$(NAME)_$(VERSION)b$(BUILD_NUMBER).apk; \
		echo "APK файл переименован в $(NAME)_$(VERSION)b$(BUILD_NUMBER).apk"; \
	else \
		echo "APK файл не найден."; \
	fi

open_directories:
	open $(APK_DIR)

generate_app_icons:
	flutter pub run flutter_launcher_icons

.PHONY: generate watch slang clean format format_check build_web build_apk build_app_bundle build_macos build_linux build_windows ci_web ci_apk ci_linux ci_windows rename_apk open_directories generate_app_icons
