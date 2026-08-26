import 'package:uuid/uuid.dart';

/// Single source of id generation so no feature reaches for `uuid` directly.
class IdGenerator {
  static const _uuid = Uuid();

  static String generate() => _uuid.v4();
}
