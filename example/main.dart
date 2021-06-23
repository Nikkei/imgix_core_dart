import 'package:imgix_core_dart/url_builder.dart';

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
  print(url);
}
