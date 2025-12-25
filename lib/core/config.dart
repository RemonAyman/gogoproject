// App-local API config for demo server

// --- STEP 1: CONFIGURE YOUR ENVIRONMENT ---

// Set this to `true` if you are running the app on a PHYSICAL Android device.
// Set this to `false` if you are using the Android EMULATOR.
const bool _usingPhysicalDevice = false;

// --- STEP 2: SET YOUR COMPUTER'S IP ADDRESS (if using a physical device) ---

// If `_usingPhysicalDevice` is true, you MUST replace this with your computer's local IP address.
// To find your IP on Windows: open Command Prompt and type `ipconfig`. Look for 'IPv4 Address'.
// To find your IP on macOS/Linux: open Terminal and type `ifconfig` or `ip a`.
const String _computerIpAddress = '192.168.1.5'; // <-- IMPORTANT: REPLACE THIS IF NEEDED

// --- Do not edit below this line ---

const String _emulatorIp = '10.0.2.2';
const String _port = '3000';

const String kApiBaseUrl = String.fromEnvironment('API_BASE_URL',
    defaultValue: _usingPhysicalDevice ? 'http://$_computerIpAddress:$_port' : 'http://$_emulatorIp:$_port');

const String kApiKey = String.fromEnvironment('API_KEY', defaultValue: 'dev-api-key');
