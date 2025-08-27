import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:totem_pro_admin/themes/ds_theme.dart';
import 'package:totem_pro_admin/themes/ds_theme_switcher.dart';

// Esta é a extensão que adiciona o novo "atalho" ao BuildContext
extension DsThemeExtension on BuildContext {

  /// Acessa o objeto DsTheme atual de forma reativa.
  ///
  /// Usar `context.dsTheme` em qualquer widget fará com que ele
  /// seja reconstruído automaticamente quando o tema mudar.
  DsTheme get dsTheme => watch<DsThemeSwitcher>().theme;

}