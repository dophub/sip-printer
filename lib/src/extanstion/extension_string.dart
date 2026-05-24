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
      // Türkçe
      'ğ': 'g', 'Ğ': 'G',
      'ş': 's', 'Ş': 'S',
      'ı': 'i', 'İ': 'I',

      // Diakritikli harfler → ASCII tabanı
      'À': 'A', 'Á': 'A', 'Â': 'A', 'Ã': 'A',
      'à': 'a', 'á': 'a', 'â': 'a', 'ã': 'a',
      // Not: Ä, Å, ä, å CP437'de mevcut — dönüştürmüyoruz

      'È': 'E', 'Ê': 'E', // É CP437'de mevcut
      'è': 'e', 'ê': 'e', 'ð': 'd', // é, ë CP437'de mevcut

      'Ð': 'D',

      'Ì': 'I', 'Í': 'I', 'Î': 'I', 'Ï': 'I',
      'ì': 'i', 'í': 'i', 'î': 'i', 'ï': 'i',
      // Not: î, ï, ì, í CP437'de mevcut — yine de ASCII'ye çekiyoruz (güvenli taraf)

      'Ò': 'O', 'Ó': 'O', 'Ô': 'O', 'Õ': 'O',
      'ò': 'o', 'ó': 'o', 'ô': 'o', 'õ': 'o',
      // Not: Ö, Ø, ö, ø CP437'de mevcut

      'Ù': 'U', 'Ú': 'U', 'Û': 'U',
      'ù': 'u', 'ú': 'u', 'û': 'u',
      // Not: Ü, ü CP437'de mevcut

      'Ñ': 'N', 'ñ': 'n',
      'Š': 'S', 'š': 's',
      'Ÿ': 'Y', 'ÿ': 'y',
      'ý': 'y',
      'Ž': 'Z', 'ž': 'z',

      // Yaygın Unicode noktalama → ASCII
      '\u2018': "'", '\u2019': "'", // ' '
      '\u201C': '"', '\u201D': '"', // " "
      '\u2013': '-', '\u2014': '-', // – —
      '\u2026': '...', // …
      '\u00B7': '.', // ·
      '\u2022': '-', // •
      '\u00A0': ' ', // Non-breaking space
      '\u2116': 'No', // №
      '\u00D7': 'x', // ×
      '\u00BC': '1/4', // ¼
      '\u00BD': '1/2', // ½
      '\u00BE': '3/4', // ¾
    };

    final buffer = StringBuffer();
    for (final char in split('')) {
      buffer.write(replacements[char] ?? char);
    }
    return buffer.toString();
  }

  static const Set<String> _cp437Printable = {
    ' ', '!', '"', '#', r'$', '%', '&', "'", '(', ')', '*', '+', ',', '-', '.', '/',
    '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', ':', ';', '<', '=', '>', '?',
    '@', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O',
    'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', '[', r'\', ']', '^', '_',
    '`', 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o',
    'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z', '{', '|', '}', '~',
    // ---------
    'Ç', 'ü', 'é', 'â', 'ä', 'à', 'å', 'ç', 'ê', 'ë', 'è', 'ï', 'î', 'ì', 'Ä', 'Å',
    'É', 'æ', 'Æ', 'ô', 'ö', 'ò', 'û', 'ù', 'ÿ', 'Ö', 'Ü', '¢', '£', '¥', '₧', 'ƒ',
    'á', 'í', 'ó', 'ú', 'ñ', 'Ñ', 'ª', 'º', '¿', '⌐', '¬', '½', '¼', '¡', '«', '»',
    'α', 'ß', 'Γ', 'π', 'Σ', 'σ', 'µ', 'τ', 'Φ', 'Θ', 'Ω', 'δ', '∞', 'φ', 'ε', '∩',
    '≡', '±', '≥', '≤', '⌠', '⌡', '÷', '≈', '°', '∙', '·', '√', 'ⁿ', '²',
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
