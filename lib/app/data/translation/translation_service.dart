import 'package:get/get.dart';

class TranslationService extends Translations {
  static TranslationService? _instance;

  static TranslationService get instance {
    _instance ??= TranslationService._init();
    return _instance!;
  }

  TranslationService._init();

  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': {},
        'es_ES': {},
      };
}
