import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

class LogoService {
  static String? _logo;

  static Future<void> init() async {
    try {
      final logosRef = FirebaseStorage.instance.ref().child('eko_logos');
      final logos = await logosRef.listAll();
      final int numLogos = logos.items.length;

      if (numLogos == 0) {
        _logo = null;
        return;
      }

      int date = DateTime.now().toUtc().millisecondsSinceEpoch ~/
          Duration.millisecondsPerDay;
      int logoIndex = date % numLogos;
      final storageRef = logos.items[logoIndex];

      final url = await storageRef.getDownloadURL().timeout(
            const Duration(seconds: 1),
          );

      final response =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 1));

      if (response.statusCode == 200) {
        _logo = response.body;
      } else {
        _logo = null;
      }
    } on TimeoutException catch (_) {
      _logo = null;
    } on FirebaseException catch (_) {
      _logo = null;
    } catch (e) {
      _logo = null;
    }
  }

  static String? get instance {
    return _logo;
  }
}
