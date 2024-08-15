import 'package:collection/collection.dart';

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
