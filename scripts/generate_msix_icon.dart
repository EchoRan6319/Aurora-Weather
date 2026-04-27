import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  final svgPath = 'assets/icons/app_icon.svg';
  final pngPath = 'assets/icons/app_icon.png';

  // Try reading SVG first (may fail on CI without rendering libs)
  try {
    final svgBytes = File(svgPath).readAsBytesSync();
    final svgContent = String.fromCharCodes(svgBytes);

    // Extract dominant color from SVG (simple heuristic)
    int r = 100, g = 150, b = 255;
    final colorMatch = RegExp(r'fill="([^"]+)"').firstMatch(svgContent);
    if (colorMatch != null) {
      final fill = colorMatch.group(1)!;
      if (fill.startsWith('#')) {
        final hex = fill.substring(1);
        if (hex.length == 6) {
          r = int.parse(hex.substring(0, 2), radix: 16);
          g = int.parse(hex.substring(2, 4), radix: 16);
          b = int.parse(hex.substring(4, 6), radix: 16);
        }
      }
    }

    final image = img.Image(width: 256, height: 256);
    for (int y = 0; y < 256; y++) {
      for (int x = 0; x < 256; x++) {
        final rr = (r + (x * (255 - r) ~/ 256)).clamp(0, 255);
        final gg = (g + (y * (255 - g) ~/ 256)).clamp(0, 255);
        final bb = (b + ((x + y) * (255 - b) ~/ 512)).clamp(0, 255);
        image.setPixelRgba(x, y, rr, gg, bb, 255);
      }
    }
    File(pngPath).writeAsBytesSync(img.encodePng(image));
    print('PNG icon generated at $pngPath');
  } catch (e) {
    // Fallback: simple blue square
    final image = img.Image(width: 256, height: 256);
    for (int y = 0; y < 256; y++) {
      for (int x = 0; x < 256; x++) {
        image.setPixelRgba(x, y, 100, 150, 255, 255);
      }
    }
    File(pngPath).writeAsBytesSync(img.encodePng(image));
    print('Fallback PNG icon generated at $pngPath');
  }
}
