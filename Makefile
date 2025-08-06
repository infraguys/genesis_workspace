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

ci_prod:
	make clean
	make generate
	make slang
	flutter build web --release -t lib/prod.dart

ci_stage:
	make clean
	make generate
	make slang
	flutter build web --release -t lib/stage.dart

build-prod-apk:
	flutter build apk --flavor prod -t lib/prod.dart --dart-define-from-file=env.json

build-macos:
	flutter build macos --flavor prod -t lib/prod.dart --dart-define-from-file=env.json

rename_prod_apk:
	@if [ -f $(APK_PROD_PATH) ]; then \
		mv $(APK_PROD_PATH) $(APK_DIR)$(NAME)_$(VERSION)b$(BUILD_NUMBER)_prod.apk; \
		echo "APK файл переименован в $(NAME)_$(VERSION)b$(BUILD_NUMBER)_prod.apk"; \
	else \
		echo "APK файл не найден."; \
	fi

open_directories:
	open $(APK_DIR)

.PHONY: generate watch slang clean ci_prod ci_stage build-prod-apk rename_prod_apk open_directories
