import 'package:imgix_flutter/imgix_flutter.dart';

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
}
