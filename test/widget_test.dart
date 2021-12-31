import 'package:test/test.dart';
import 'package:intl/intl.dart';

DateTime _parsePubDate(String pubDate) {
  var format = DateFormat("EEE, dd MMM yyyy HH:mm:ss Z");
  return format.parse(pubDate);
}

void main() {
  group('Testing App Provider', () {
    test('A new item should be added', () {
      // var date = _parsePubDate("Fri, 31 Dec 2021 10:50:42 +0000");
      // expect(date.month, 12);
      // expect(date.year, 2021);
      // expect(date.day, 31);

      var date2 = _parsePubDate("Fri, 31 Dec 2021 00:00:00 GMT");
      expect(date2.month, 12);
      expect(date2.year, 2021);
      expect(date2.day, 31);
    });
  });
}
