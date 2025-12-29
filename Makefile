NAME := $(shell grep '^name:' pubspec.yaml | awk '{print $$2}')
VERSION := $(shell grep '^version:' pubspec.yaml | awk -F "+" '{print $$1}' | awk '{print $$2}')
BUILD_NUMBER := $(shell grep '^version:' pubspec.yaml | awk -F "+" '{print $$2}' | xargs)
APK_PROD_PATH := build/app/outputs/flutter-apk/app-prod-release.apk
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

build_stage_web:
	flutter build web --release -t lib/stage.dart --dart-define-from-file=env.json

build_prod_web:
	flutter build web --release -t lib/prod.dart --dart-define-from-file=env.json

build_stage_apk:
	flutter build apk --flavor stage -t lib/stage.dart --dart-define-from-file=env.json

build_prod_apk:
	flutter build apk --flavor prod -t lib/prod.dart --dart-define-from-file=env.json

build_prod_macos:
	flutter build macos --flavor prod -t lib/prod.dart --dart-define-from-file=env.json

build_stage_linux:
	flutter build linux --release -t lib/stage.dart --dart-define-from-file=env.json

build_prod_linux:
	flutter build linux --release -t lib/prod.dart --dart-define-from-file=env.json

build_prod_windows:
	flutter build windows --release -t lib/prod.dart --dart-define-from-file=env.json

ci_stage_web:
	make clean
	make generate
	make slang
	make build_stage_web

ci_prod_web:
	make clean
	make generate
	make slang
	make build_prod_web

ci_prod_apk:
	make clean
	make generate
	make slang
	make build_prod_apk

ci_stage_apk:
	make clean
	make generate
	make slang
	make build_stage_apk

ci_stage_linux:
	make clean
	make generate
	make slang
	make build_stage_linux

ci_prod_linux:
	make clean
	make generate
	make slang
	make build_prod_linux

ci_prod_windows:
	make clean
	make generate
	make slang
	make build_prod_windows

rename_prod_apk:
	@if [ -f $(APK_PROD_PATH) ]; then \
		mv $(APK_PROD_PATH) $(APK_DIR)$(NAME)_$(VERSION)b$(BUILD_NUMBER)_prod.apk; \
		echo "APK файл переименован в $(NAME)_$(VERSION)b$(BUILD_NUMBER)_prod.apk"; \
	else \
		echo "APK файл не найден."; \
	fi

open_directories:
	open $(APK_DIR)

.PHONY: generate watch slang clean build_stage_web build_prod_web build_stage_apk build_prod_apk build_prod_macos build_stage_linux build_prod_linux build_prod_windows ci_stage_web ci_prod_web ci_prod_apk ci_stage_apk ci_stage_linux ci_prod_linux ci_prod_windows rename_prod_apk open_directories
