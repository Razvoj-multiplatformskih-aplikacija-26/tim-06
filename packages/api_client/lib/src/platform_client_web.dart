import 'package:http/browser_client.dart';
import 'package:http/http.dart' as http;

/// U pregledacu token ne sme da stoji na mestu do kojeg JavaScript moze da dodje,
/// pa prijavu drzi kolacic koji postavlja server. `withCredentials` je ono sto
/// pregledacu kaze da taj kolacic posalje i kada server stoji na drugoj adresi.
const platformKeepsSessionInCookie = true;

http.Client platformHttpClient() => BrowserClient()..withCredentials = true;
