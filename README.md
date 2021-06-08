# imgix_core_dart

Imgix package for Dart. Imgix is a CDN service with support for realtime image processing and optimization.

See also
- https://docs.imgix.com
- https://github.com/imgix/imgix-blueprint

## Install

```pubspec.yaml
dependencies:
     imgix_core_dart: 1.0.0-nullsafety.0
```
## Usage

```dart
import 'package:imgix_core_dart/imgix_core_dart.dart';

void main() {
  final urlBuilder = ImgixURLBuilder(
    domain: 'testing.imgix.net',
    useHTTPS: true,
    secureURLToken: '<SECURE TOKEN>',
  );

  final url = urlBuilder.buildURL(
    '/path/to/image.png',
    <String, dynamic>{'w': 400, 'h': 300},
  );
  print(url);
  // -> http://testing.imgix.net/path/to/image.png?ixlib=dart-1.0.0&s=d989ab7de53535886b09183a43f801aa
}
```

## signed urls
To produce a signed URL, you must enable secure URLs on your source and then provide your signature key to the URL builder.

```dart
final urlBuilder =  new ImgixURLBuilder('demos.imgix.net',signKey: '***********');

// or
final urlBuilder = new ImgixUrlBuilder('demos.imgix.net')
    ..setDefaultSignKey('**********');
```

## Srcset Generation

```dart
final urlBuilder =  new ImgixURLBuilder('demos.imgix.net');
final srcsetString = urlBuilder.createSrcsetString('example.png');
final srcset = urlBuilder.createSrcset('example.png');
```

## Running Tests

```shell script
pub test
```