# imgix_core_dart

Imgix package for Dart. Imgix is a CDN service with support for realtime image processing and optimization.

See also
- https://docs.imgix.com
- https://github.com/imgix/imgix-blueprint

## Install

```pubspec.yaml
dependencies:
     imgix_core_dart: 1.0.0
```
## Usage

```dart
import 'package:imgix_core_dart/imgix_core_dart.dart';

void main() {
  final client = URLBuilder(
    domain: 'testing.imgix.net',
    shouldUseHttpsByDefault: true,
    defaultSignKey: '<SECURE TOKEN>',
  );

  final url = client.createURLString(
    '/path/to/image.png',
    params: {'w': '400', 'h': '300'},
  );
  print(url); // => https://testing.imgix.net/path/to/image.png?w=400&h=300&s=11c92d85ea7e2d7ddfb98e5aac179964
}
```

## signed urls
To produce a signed URL, you must enable secure URLs on your source and then provide your signature key to the URL builder.

```dart
final urlBuilder =  new URLBuilder('demos.imgix.net',signKey: '***********');

// or
final urlBuilder = new URLBuilder('demos.imgix.net')
    ..setDefaultSignKey('**********');
```

## Srcset Generation

```dart
final urlBuilder =  new URLBuilder('demos.imgix.net');
final srcsetString = urlBuilder.createSrcsetString('example.png');
final srcset = urlBuilder.createSrcset('example.png');
```

## Running Tests

```shell script
pub run test
```
