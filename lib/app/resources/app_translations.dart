import 'package:get/get.dart';

import 'languages/ar.dart';
import 'languages/en.dart';
import 'languages/es.dart';
import 'languages/fr.dart';
import 'languages/pt.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'en': enUS,
    'es': esES,
    'fr': frFR,
    'ar': arAR,
    'pt': ptBR,
  };
}
