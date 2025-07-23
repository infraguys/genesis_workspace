generate:
	flutter pub run build_runner build --delete-conflicting-outputs

watch:
	flutter pub run build_runner watch

slang:
	dart run slang

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
