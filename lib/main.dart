import 'package:flutter/material.dart';

import 'app.dart';
import 'core/network/dio_client.dart';
import 'core/storage/preference_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final preferenceService = await PreferenceService.init();
  final dioClient = DioClient(preferenceService: preferenceService);

  runApp(
    BazaarApp(dioClient: dioClient, preferenceService: preferenceService),
  );
}
