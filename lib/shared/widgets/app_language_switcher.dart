import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:prog_set_touch/core/localization/app_locale.dart';
import 'package:prog_set_touch/features/settings/presentation/bloc/settings_bloc.dart';

class AppLanguageMenuButton extends StatelessWidget {
  const AppLanguageMenuButton({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final selectedLocale =
        context.select((SettingsBloc bloc) => bloc.state.locale);

    return PopupMenuButton<AppLocale>(
      tooltip: l10n.languageSwitcherTooltip,
      icon: const Icon(Icons.language_outlined),
      initialValue: selectedLocale,
      onSelected: (locale) {
        if (locale == selectedLocale) {
          return;
        }
        context.read<SettingsBloc>().add(SettingsLocaleChanged(locale));
      },
      itemBuilder: (context) => [
        _buildMenuItem(
          context: context,
          value: AppLocale.ru,
          label: l10n.settingsLanguageRussian,
          isSelected: selectedLocale == AppLocale.ru,
        ),
        _buildMenuItem(
          context: context,
          value: AppLocale.en,
          label: l10n.settingsLanguageEnglish,
          isSelected: selectedLocale == AppLocale.en,
        ),
      ],
    );
  }

  PopupMenuItem<AppLocale> _buildMenuItem({
    required BuildContext context,
    required AppLocale value,
    required String label,
    required bool isSelected,
  }) {
    final theme = Theme.of(context);
    return PopupMenuItem<AppLocale>(
      value: value,
      child: Row(
        children: [
          Icon(
            isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
            size: 18,
            color: isSelected ? theme.colorScheme.primary : null,
          ),
          const SizedBox(width: 10),
          Text(label),
        ],
      ),
    );
  }
}
