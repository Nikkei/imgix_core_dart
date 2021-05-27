# imgix_core_dart

Imgix package for Dart. Imgix is a CDN service with support for realtime image processing and optimization.

See also https://docs.imgix.com

## Install

```pubspec.yaml
dependencies:
     imgix_core_dart: 1.0.0-nullsafety.0
```
## Usage

```dart
import 'package:imgix_core_dart/imgix_core_dart.dart';

void main() {
  final client = ImgixClient(
    domain: 'testing.imgix.net',
    useHTTPS: true,
    secureURLToken: '<SECURE TOKEN>',
  );

  final url = client.buildURL(
    '/path/to/image.png',
    <String, dynamic>{'w': 400, 'h': 300},
  );
  print(url);
  // -> http://testing.imgix.net/path/to/image.png?ixlib=dart-1.0.0&s=d989ab7de53535886b09183a43f801aa
}
```