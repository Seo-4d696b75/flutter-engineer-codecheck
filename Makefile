setup:
	fvm flutter pub get
	fvm flutter pub run build_runner build
	fvm flutter gen-l10n