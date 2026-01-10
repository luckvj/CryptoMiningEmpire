/// Web interop for removing HTML loading screen
// ignore: avoid_web_libraries_in_flutter
import 'dart:js' as js;

/// Remove the HTML loading screen (web only)
void removeHtmlLoadingScreen() {
  try {
    js.context.callMethod('removeLoadingScreen');
  } catch (e) {
    // Ignore errors
  }
}
