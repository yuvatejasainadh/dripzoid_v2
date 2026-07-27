class AppInitializer {
  AppInitializer._();

  static Future<void> initialize() async {
    // Startup tasks will go here.

    await Future.wait([
      Future.delayed(const Duration(milliseconds: 1200)),
    ]);
  }
}