import 'package:flutter/foundation.dart';

// App-local API config for clinic system

// --- STEP 1: CONFIGURE FOR PHYSICAL PHONE TESTING ---

// Set this to `true` if you are running the app on a PHYSICAL mobile phone.
// Set this to `false` if you are using an EMULATOR / WEB / DESKTOP.
const bool _usingPhysicalDevice = false;

// If `_usingPhysicalDevice` is true, replace this with your computer's local IP address
// (Find it on Windows by running `ipconfig` in CMD, look for IPv4 Address)
const String _computerIpAddress = '192.168.1.5'; 

// --- Do not edit below this line ---

const String _port = '3000';

String get kApiBaseUrl {
  if (kIsWeb) {
    // Web browser runs on the same machine, so localhost works perfectly
    return 'http://localhost:$_port';
  }
  
  if (_usingPhysicalDevice) {
    return 'http://$_computerIpAddress:$_port';
  } else {
    // Android Emulator uses 10.0.2.2 to access the computer's localhost.
    // iOS Simulator, Windows desktop, and macOS desktop use localhost.
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:$_port';
    }
    return 'http://localhost:$_port';
  }
}

const String kApiKey = 'dev-api-key';
