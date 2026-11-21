import 'package:http/http.dart' as http;

/// Telefon i desktop nose token u zaglavlju i sami ga cuvaju.
const platformKeepsSessionInCookie = false;

http.Client platformHttpClient() => http.Client();
