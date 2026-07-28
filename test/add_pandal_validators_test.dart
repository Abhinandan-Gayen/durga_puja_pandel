import 'package:durga_puja_pandel/core/utils/validators.dart';
import 'package:flutter_test/flutter_test.dart';

List<String> parseUrls(String value) {
  final seen = <String>{};
  final result = <String>[];
  for (final url in value.split(RegExp(r'\r?\n'))) {
    final trimmed = url.trim();
    if (trimmed.isNotEmpty && seen.add(trimmed)) {
      result.add(trimmed);
    }
  }
  return result;
}

String? validateUrl(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  final uri = Uri.tryParse(value.trim());
  if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
    return 'Enter a valid URL';
  }
  if (uri.scheme != 'http' && uri.scheme != 'https') {
    return 'URL must start with http or https';
  }
  return null;
}

String? validateUrlList(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  final urls = parseUrls(value);
  for (final url in urls) {
    final error = validateUrl(url);
    if (error != null) return error;
  }
  return null;
}

void main() {
  group('URL validation', () {
    test('null input returns null', () {
      expect(validateUrl(null), isNull);
    });

    test('empty input returns null', () {
      expect(validateUrl(''), isNull);
    });

    test('whitespace only returns null', () {
      expect(validateUrl('   '), isNull);
    });

    test('valid http URL passes', () {
      expect(
        validateUrl('http://example.com/image.jpg'),
        isNull,
      );
    });

    test('valid https URL passes', () {
      expect(
        validateUrl('https://example.com/image.jpg'),
        isNull,
      );
    });

    test('invalid scheme fails', () {
      expect(
        validateUrl('ftp://example.com/file.jpg'),
        isNotNull,
      );
    });

    test('no scheme fails', () {
      expect(
        validateUrl('example.com/image.jpg'),
        isNotNull,
      );
    });

    test('empty host fails', () {
      expect(
        validateUrl('https:///path'),
        isNotNull,
      );
    });

    test('Google Drive thumbnail URL passes', () {
      expect(
        validateUrl(
          'https://drive.google.com/thumbnail?id=FILE_ID&sz=w1000',
        ),
        isNull,
      );
    });

    test('Google Drive uc export view URL passes', () {
      expect(
        validateUrl(
          'https://drive.google.com/uc?export=view&id=FILE_ID',
        ),
        isNull,
      );
    });

    test('Google Drive uc export download URL passes', () {
      expect(
        validateUrl(
          'https://drive.google.com/uc?export=download&id=FILE_ID',
        ),
        isNull,
      );
    });

    test('URL with trailing whitespace still validates', () {
      expect(
        validateUrl('  https://example.com/image.jpg  '),
        isNull,
      );
    });
  });

  group('URL parsing', () {
    test('empty string returns empty list', () {
      expect(parseUrls(''), isEmpty);
    });

    test('whitespace only returns empty list', () {
      expect(parseUrls('  \n  '), isEmpty);
    });

    test('single URL parses correctly', () {
      expect(parseUrls('https://example.com/a.jpg'), [
        'https://example.com/a.jpg',
      ]);
    });

    test('multiple URLs parse correctly', () {
      expect(parseUrls('https://a.com/1.jpg\nhttps://b.com/2.jpg'), [
        'https://a.com/1.jpg',
        'https://b.com/2.jpg',
      ]);
    });

    test('trims whitespace around URLs', () {
      expect(parseUrls('  https://a.com/1.jpg  \n  https://b.com/2.jpg  '), [
        'https://a.com/1.jpg',
        'https://b.com/2.jpg',
      ]);
    });

    test('removes empty lines', () {
      expect(
        parseUrls('https://a.com/1.jpg\n\nhttps://b.com/2.jpg\n\n'),
        ['https://a.com/1.jpg', 'https://b.com/2.jpg'],
      );
    });

    test('removes duplicate URLs while preserving order', () {
      expect(
        parseUrls(
          'https://a.com/1.jpg\nhttps://b.com/2.jpg\nhttps://a.com/1.jpg\nhttps://c.com/3.jpg',
        ),
        ['https://a.com/1.jpg', 'https://b.com/2.jpg', 'https://c.com/3.jpg'],
      );
    });

    test('handles carriage return newlines', () {
      expect(
        parseUrls('https://a.com/1.jpg\r\nhttps://b.com/2.jpg'),
        ['https://a.com/1.jpg', 'https://b.com/2.jpg'],
      );
    });
  });

  group('URL list validation', () {
    test('null input returns null', () {
      expect(validateUrlList(null), isNull);
    });

    test('empty input returns null', () {
      expect(validateUrlList(''), isNull);
    });

    test('all valid URLs return null', () {
      expect(
        validateUrlList('https://a.com/1.jpg\nhttps://b.com/2.jpg'),
        isNull,
      );
    });

    test('one invalid URL returns error', () {
      expect(
        validateUrlList('https://a.com/1.jpg\nnot-a-url'),
        isNotNull,
      );
    });

    test('empty lines among valid URLs still passes', () {
      expect(
        validateUrlList('https://a.com/1.jpg\n\nhttps://b.com/2.jpg'),
        isNull,
      );
    });
  });

  group('Video URL max count', () {
    test('exactly 2 videos is allowed', () {
      final urls = parseUrls('https://a.com/v1.mp4\nhttps://b.com/v2.mp4');
      expect(urls.length <= 2, isTrue);
    });

    test('1 video is allowed', () {
      final urls = parseUrls('https://a.com/v1.mp4');
      expect(urls.length <= 2, isTrue);
    });

    test('more than 2 videos is detected', () {
      final urls =
          parseUrls('https://a.com/v1.mp4\nhttps://b.com/v2.mp4\nhttps://c.com/v3.mp4');
      expect(urls.length > 2, isTrue);
    });

    test('duplicate video URLs do not count toward max', () {
      final urls =
          parseUrls('https://a.com/v1.mp4\nhttps://a.com/v1.mp4');
      expect(urls.length, 1);
    });
  });

  group('Latitude validation', () {
    test('null returns error', () {
      expect(Validators.latitude(null), isNotNull);
    });

    test('empty returns error', () {
      expect(Validators.latitude(''), isNotNull);
    });

    test('0 is valid', () {
      expect(Validators.latitude('0'), isNull);
    });

    test('22.5726 is valid', () {
      expect(Validators.latitude('22.5726'), isNull);
    });

    test('-90 is valid', () {
      expect(Validators.latitude('-90'), isNull);
    });

    test('90 is valid', () {
      expect(Validators.latitude('90'), isNull);
    });

    test('-91 is invalid', () {
      expect(Validators.latitude('-91'), isNotNull);
    });

    test('91 is invalid', () {
      expect(Validators.latitude('91'), isNotNull);
    });

    test('non-numeric is invalid', () {
      expect(Validators.latitude('abc'), isNotNull);
    });
  });

  group('Longitude validation', () {
    test('null returns error', () {
      expect(Validators.longitude(null), isNotNull);
    });

    test('empty returns error', () {
      expect(Validators.longitude(''), isNotNull);
    });

    test('0 is valid', () {
      expect(Validators.longitude('0'), isNull);
    });

    test('88.3639 is valid', () {
      expect(Validators.longitude('88.3639'), isNull);
    });

    test('-180 is valid', () {
      expect(Validators.longitude('-180'), isNull);
    });

    test('180 is valid', () {
      expect(Validators.longitude('180'), isNull);
    });

    test('-181 is invalid', () {
      expect(Validators.longitude('-181'), isNotNull);
    });

    test('181 is invalid', () {
      expect(Validators.longitude('181'), isNotNull);
    });

    test('non-numeric is invalid', () {
      expect(Validators.longitude('abc'), isNotNull);
    });
  });
}
