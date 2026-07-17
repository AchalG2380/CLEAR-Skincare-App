import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends GetxController {
  // Defaults to dark since that's the app's original, primary design
  var isDarkMode = true.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSavedPreference();
  }

  Future<void> _loadSavedPreference() async {
    final prefs = await SharedPreferences.getInstance();
    // Only override the default if the user has explicitly chosen before
    if (prefs.containsKey('isDarkMode')) {
      isDarkMode.value = prefs.getBool('isDarkMode') ?? true;
    }
  }

  Future<void> toggleTheme() async {
    isDarkMode.value = !isDarkMode.value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDarkMode.value);
  }
}
