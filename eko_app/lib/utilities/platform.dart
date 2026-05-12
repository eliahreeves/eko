import 'dart:io';

import 'package:flutter/foundation.dart';

final bool isWeb = kIsWeb;
final bool isLinux = (!kIsWeb && Platform.isLinux);
final bool isIOS = (!kIsWeb && Platform.isIOS);
final bool isAndroid = (!kIsWeb && Platform.isAndroid);
final bool isWindows = (!kIsWeb && Platform.isWindows);
final bool isMacOS = (!kIsWeb && Platform.isMacOS);
final bool isMobile = isAndroid || isIOS;
final bool isDesktop = isWindows || isLinux || isMacOS;
