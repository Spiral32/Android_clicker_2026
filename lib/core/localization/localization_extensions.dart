import 'package:flutter/widgets.dart';
import 'package:prog_set_touch/core/localization/app_localizations.dart';

extension LocalizationBuildContextX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}
