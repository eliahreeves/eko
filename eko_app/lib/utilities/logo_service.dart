import 'package:eko_app/utilities/supabase_ref.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'dart:async';

class LogoService {
  static String? _logo;

  static Future<void> init() async {
    try {
      _logo = await supabase
          .rpc('get_logo_of_the_day')
          .timeout(const Duration(seconds: 2));
    } on TimeoutException catch (e) {
      debugPrint('[LOGO SERVICE] timeout: $e');
      _logo = null;
    } catch (e) {
      debugPrint('[LOGO SERVICE] error: $e');
      _logo = null;
    }
  }

  static String? get instance {
    return _logo;
  }
}
