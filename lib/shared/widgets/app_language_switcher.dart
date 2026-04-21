import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:prog_set_touch/core/localization/app_locale.dart';
import 'package:prog_set_touch/features/settings/presentation/bloc/settings_bloc.dart';

class AppLanguageSwitcher extends StatelessWidget {
  const AppLanguageSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final selectedLocale =
        context.select((SettingsBloc bloc) => bloc.state.locale);

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _LanguageButton(
          label: l10n.settingsLanguageRussian,
          isSelected: selectedLocale == AppLocale.ru,
          onPressed: () {
            context.read<SettingsBloc>().add(
                  const SettingsLocaleChanged(AppLocale.ru),
                );
          },
        ),
        _LanguageButton(
          label: l10n.settingsLanguageEnglish,
          isSelected: selectedLocale == AppLocale.en,
          onPressed: () {
            context.read<SettingsBloc>().add(
                  const SettingsLocaleChanged(AppLocale.en),
                );
          },
        ),
      ],
    );
  }
}

class _LanguageButton extends StatelessWidget {
  const _LanguageButton({
    required this.label,
    required this.isSelected,
    required this.onPressed,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonal(
      style: FilledButton.styleFrom(
        backgroundColor:
            isSelected ? const Color(0xFF0E7490) : const Color(0xFFE8F1F8),
        foregroundColor: isSelected ? Colors.white : const Color(0xFF16324F),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      ),
      onPressed: isSelected ? null : onPressed,
      child: Text(label),
    );
  }
}
