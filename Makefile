generate:
	fvm flutter pub run build_runner build --delete-conflicting-outputs

watch:
	fvm flutter pub run build_runner watch

slang:
	fvm dart run slang

clean:
	fvm flutter clean
	fvm flutter pub get

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
