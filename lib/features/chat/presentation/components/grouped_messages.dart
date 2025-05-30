/*import 'package:Cinemate/features/chat/domain/entities/message_entity.dart';

Map<String, List<MessageEntity>> groupMessagesByDate(List<MessageEntity> messages) {
  final Map<String, List<MessageEntity>> grouped = {};

  for (var msg in messages) {
    final now = DateTime.now();
    final date = msg.timestamp;

    String label;

    final difference = now.difference(date).inDays;

    if (difference == 0) {
      label = 'Bugün';
    } else if (difference == 1) {
      label = 'Dün';
    } else if (difference < 7) {
      label = _weekdayName(date.weekday);
    } else {
      label = '${date.day}.${date.month}.${date.year}';
    }

    grouped.putIfAbsent(label, () => []).add(msg);
  }

  return grouped;
}

String _weekdayName(int weekday) {
  const names = [
    'Pazartesi',
    'Salı',
    'Çarşamba',
    'Perşembe',
    'Cuma',
    'Cumartesi',
    'Pazar'
  ];
  return names[weekday - 1];
}
*/