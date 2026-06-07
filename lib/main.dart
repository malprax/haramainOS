import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:haramain_os/bindings/initial_binding.dart';
import 'package:haramain_os/routes/app_pages.dart';
import 'package:haramain_os/routes/app_routes.dart';

void main() {
  runApp(const HaramainOSApp());
}

class HaramainOSApp extends StatelessWidget {
  const HaramainOSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'HaramainOS',
      debugShowCheckedModeBanner: false,
      initialBinding: InitialBinding(),
      initialRoute: AppRoutes.group,
      getPages: AppPages.routes,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.green),
    );
  }
}
