import 'dart:io';

void main() {
  const sourcePngPath =
      'assets/icons/AppAssets_2026-06-15/Android/play_store_512.png';
  const pngPath = 'assets/icons/app_icon.png';
  const svgPath = 'assets/icons/app_icon.svg';

  final sourceBytes = File(sourcePngPath).readAsBytesSync();
  File(pngPath).writeAsBytesSync(sourceBytes);

  final svg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512" width="512" height="512">
  <image width="512" height="512" href="app_icon.png" />
</svg>
''';
  File(svgPath).writeAsStringSync(svg);

  stdout.writeln('Synced app icon assets from $sourcePngPath');
}
