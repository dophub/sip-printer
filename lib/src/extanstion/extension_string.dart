import 'package:collection/collection.dart';
/*

extension DiacriticsAwareString on String {
  String withoutDiacriticalMarks() {
    const diacritics = 'ÀÁÂÃÄÅàáâãäåÒÓÔÕÕÖØòóôõöøÈÉÊËèéêëðÇçÐÌÍÎÏİìíîïÙÚÛÜùúûüÑñŠšŸÿýŽžıŞşĞğ';
    const nonDiacritics = 'AAAAAAaaaaaaOOOOOOOooooooEEEEeeeeeCcDIIIIiiiiiUUUUuuuuNnSsYyyZziSsGg';

    return splitMapJoin(
      '',
      onNonMatch: (char) =>
          char.isNotEmpty && diacritics.contains(char) ? nonDiacritics[diacritics.indexOf(char)] : char,
    );
  }
}
*/

extension EscPosString on String {
  /// Tüm diakritik ve özel karakterleri ASCII/CP437 karşılığına dönüştürür,
  /// ardından CP437'de olmayan karakterleri siler.
  String withoutDiacriticalMarks() {
    return _replaceSpecialChars()._removeNonCp437();
  }

  String _replaceSpecialChars() {
    const Map<String, String> replacements = {
      // =====================
      // 🇹🇷 TÜRKÇE HARFLER
      // =====================
      'ğ': 'g', 'Ğ': 'G',
      'ş': 's', 'Ş': 'S',
      'ı': 'i', 'İ': 'I',
      'ç': 'c', 'Ç': 'C',
      'ö': 'o', 'Ö': 'O',
      'ü': 'u', 'Ü': 'U',

      // =====================
      // Latin diakritikler (seninki + genişletilmiş)
      // =====================
      'À': 'A', 'Á': 'A', 'Â': 'A', 'Ã': 'A', 'Ä': 'A', 'Å': 'A',
      'à': 'a', 'á': 'a', 'â': 'a', 'ã': 'a', 'ä': 'a', 'å': 'a',

      'È': 'E', 'É': 'E', 'Ê': 'E', 'Ë': 'E',
      'è': 'e', 'é': 'e', 'ê': 'e', 'ë': 'e',

      'Ì': 'I', 'Í': 'I', 'Î': 'I', 'Ï': 'I',
      'ì': 'i', 'í': 'i', 'î': 'i', 'ï': 'i',

      'Ò': 'O', 'Ó': 'O', 'Ô': 'O', 'Õ': 'O', 'Ø': 'O',
      'ò': 'o', 'ó': 'o', 'ô': 'o', 'õ': 'o', 'ø': 'o',

      'Ù': 'U', 'Ú': 'U', 'Û': 'U',
      'ù': 'u', 'ú': 'u', 'û': 'u',

      'Ñ': 'N', 'ñ': 'n',
      'Š': 'S', 'š': 's',
      'Ž': 'Z', 'ž': 'z',
      'Ÿ': 'Y', 'ÿ': 'y',

      // =====================
      // Diğer yaygın özel karakterler
      // =====================
      'Ð': 'D',
      'Þ': 'TH',
      'ß': 'ss',

      // =====================
      // Rusça harfleri
      "А": "A", "а": "a",
      "Б": "B", "б": "b",
      "В": "V", "в": "v",
      "Г": "G", "г": "g",
      "Д": "D", "д": "d",
      "Е": "E", "е": "e",
      "Ё": "Yo", "ё": "yo",
      "Ж": "Zh", "ж": "zh",
      "З": "Z", "з": "z",
      "И": "I", "и": "i",
      "Й": "Y", "й": "y",
      "К": "K", "к": "k",
      "Л": "L", "л": "l",
      "М": "M", "м": "m",
      "Н": "N", "н": "n",
      "О": "O", "о": "o",
      "П": "P", "п": "p",
      "Р": "R", "р": "r",
      "С": "S", "с": "s",
      "Т": "T", "т": "t",
      "У": "U", "у": "u",
      "Ф": "F", "ф": "f",
      "Х": "Kh", "х": "kh",
      "Ц": "Ts", "ц": "ts",
      "Ч": "Ch", "ч": "ch",
      "Ш": "Sh", "ш": "sh",
      "Щ": "Shch", "щ": "shch",
      "Ъ": "", "ъ": "",
      "Ы": "Y", "ы": "y",
      "Ь": "'", "ь": "'",
      "Э": "E", "э": "e",
      "Ю": "Yu", "ю": "yu",
      "Я": "Ya", "я": "ya"
    };

    final buffer = StringBuffer();
    for (final char in split('')) {
      buffer.write(replacements[char] ?? char);
    }
    return buffer.toString();
  }

  static const Set<String> _cp437Printable = {
    // =====================
    // Letters
    // =====================
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M',
    'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',

    'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm',
    'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z',

    // =====================
    // Numbers
    // =====================
    '0', '1', '2', '3', '4', '5', '6', '7', '8', '9',

    // =====================
    // Basic punctuation
    // =====================
    ' ', '!', '"', '#', r'$', '%', '&', "'", '(', ')',
    '*', '+', ',', '-', '.', '/',

    ':', ';', '<', '=', '>', '?', '@',

    '[', r'\', ']', '^', '_', '`',

    '{', '|', '}', '~',

    // =====================
    // Safe extended CP437 (çok kullanılan)
    // =====================
    'Ç', 'ç',
    'Ü', 'ü',
    'Ö', 'ö',
    'İ', 'ı', // yazıcıya göre değişir (CP437’de garanti değil ama sık görülür)

    '£', '¥', '¢', '§', '°', '±',
  };

  String _removeNonCp437() {
    final buffer = StringBuffer();
    for (final c in split('')) {
      if (_cp437Printable.contains(c)) {
        buffer.write(c);
      }
    }
    return buffer.toString();
  }
}

extension NullStringExtension on String? {
  String maskNullableSurname() {
    try {
      if (this == null || this!.trim().isEmpty) return "Müşteri";

      final text = this!.trim();
      List<String> nameParts = text.split(' ');

      // Get the first name and the first letter of the last name
      String firstName = nameParts.first;
      String lastNameInitial = nameParts.last[0];

      // Create the masked name with asterisks
      String maskedName = '$firstName $lastNameInitial${'*' * (nameParts.last.length - 1)}';

      return maskedName;
    } catch (e) {
      return "Müşteri";
    }
  }
}

extension GetXExtension2 on String {
  T? enumFromString<T>(Iterable<T> values) {
    return values.firstWhereOrNull((type) => type.toString().split(".").last == this);
  }
}
