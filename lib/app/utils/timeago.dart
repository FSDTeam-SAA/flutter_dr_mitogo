import 'package:intl/intl.dart';

String timeAgo(DateTime? date) {
  if (date == null) return "";
  final now = DateTime.now();
  final diff = now.difference(date);

  if (diff.inDays >= 1) {
    return Intl.plural(
      diff.inDays,
      one: '1 day ago',
      other: '${diff.inDays} days ago',
    );
  } else if (diff.inHours >= 1) {
    return Intl.plural(
      diff.inHours,
      one: '1 hour ago',
      other: '${diff.inHours} hours ago',
    );
  } else if (diff.inMinutes >= 1) {
    return Intl.plural(
      diff.inMinutes,
      one: '1 minute ago',
      other: '${diff.inMinutes} mins ago',
    );
  } else {
    return 'just now';
  }
}

String commentTimeAgo(DateTime? date) {
  if (date == null) return "";
  final now = DateTime.now();
  final diff = now.difference(date);

  if (diff.inDays >= 1) {
    return Intl.plural(
      diff.inDays,
      one: '1 day ago',
      other: '${diff.inDays}d',
    );
  } else if (diff.inHours >= 1) {
    return Intl.plural(
      diff.inHours,
      one: '1 hour ago',
      other: '${diff.inHours}h',
    );
  } else if (diff.inMinutes >= 1) {
    return Intl.plural(
      diff.inMinutes,
      one: '1 minute ago',
      other: '${diff.inMinutes}m',
    );
  } else {
    return 'now';
  }
}
