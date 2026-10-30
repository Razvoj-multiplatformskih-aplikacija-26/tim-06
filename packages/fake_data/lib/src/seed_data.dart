import 'package:domain/domain.dart';

const moderator = User(UserId('u-mod'), 'moderator', Role.moderator);
const ana = User(UserId('u-ana'), 'Ana V.', Role.hiker);
const petar = User(UserId('u-petar'), 'Petar K.', Role.hiker);
const jovana = User(UserId('u-jovana'), 'Jovana M.', Role.hiker);
const marko = User(UserId('u-marko'), 'Marko T.', Role.hiker);
const dunja = User(UserId('u-dunja'), 'Dunja S.', Role.hiker);
const vuk = User(UserId('u-vuk'), 'Vuk R.', Role.hiker);
const milica = User(UserId('u-milica'), 'Milica J.', Role.hiker);
const nikola = User(UserId('u-nikola'), 'Nikola P.', Role.hiker);
const stefan = User(UserId('u-stefan'), 'Stefan R.', Role.hiker);

/// Korisnik koji je prijavljen u mobilnoj aplikaciji.
const currentUser = ana;

const seedUsers = <User>[
  moderator,
  ana,
  petar,
  jovana,
  marko,
  dunja,
  vuk,
  milica,
  nikola,
  stefan,
];

/// Ime autora za prikaz. U KT2 dolazi iz tabele korisnika.
String authorName(UserId id) {
  for (final user in seedUsers) {
    if (user.id == id) return user.username;
  }
  return id.value;
}

const _stara = MountainId('m-stara');
const _kopaonik = MountainId('m-kopaonik');
const _suva = MountainId('m-suva');
const _tara = MountainId('m-tara');
const _zlatibor = MountainId('m-zlatibor');
const _rudnik = MountainId('m-rudnik');
const _maljen = MountainId('m-maljen');
const _avalaId = MountainId('m-avala');

const seedMountains = <Mountain>[
  Mountain(_stara, 'Stara planina', 'RS', GeoPoint(43.38, 22.60)),
  Mountain(_kopaonik, 'Kopaonik', 'RS', GeoPoint(43.28, 20.80)),
  Mountain(_suva, 'Suva planina', 'RS', GeoPoint(43.17, 22.17)),
  Mountain(_tara, 'Tara', 'RS', GeoPoint(43.90, 19.40)),
  Mountain(_zlatibor, 'Zlatibor', 'RS', GeoPoint(43.73, 19.70)),
  Mountain(_rudnik, 'Rudnik', 'RS', GeoPoint(44.13, 20.52)),
  Mountain(_maljen, 'Maljen', 'RS', GeoPoint(44.10, 20.02)),
  Mountain(_avalaId, 'Avala', 'RS', GeoPoint(44.69, 20.51)),
];

const seedPeaks = <Peak>[
  Peak(PeakId('p-midzor'), 'Midžor', _stara, 2169, GeoPoint(43.40, 22.67)),
  Peak(PeakId('p-babin'), 'Babin zub', _stara, 1758, GeoPoint(43.38, 22.57)),
  Peak(PeakId('p-pancic'), 'Pančićev vrh', _kopaonik, 2017, GeoPoint(43.27, 20.81)),
  Peak(PeakId('p-gobelja'), 'Gobelja', _kopaonik, 1934, GeoPoint(43.32, 20.75)),
  Peak(PeakId('p-trem'), 'Trem', _suva, 1810, GeoPoint(43.18, 22.13)),
  Peak(PeakId('p-kozji'), 'Kozji rid', _tara, 1591, GeoPoint(43.88, 19.36)),
  Peak(PeakId('p-banjska'), 'Banjska stena', _tara, 1065, GeoPoint(43.96, 19.37)),
  Peak(PeakId('p-tornik'), 'Tornik', _zlatibor, 1496, GeoPoint(43.68, 19.55)),
  Peak(PeakId('p-sturac'), 'Veliki Šturac', _rudnik, 1132, GeoPoint(44.13, 20.50)),
  Peak(PeakId('p-kraljev'), 'Kraljev sto', _maljen, 1103, GeoPoint(44.10, 20.03)),
  Peak(PeakId('p-avala'), 'Avala', _avalaId, 511, GeoPoint(44.69, 20.51)),
];

DateTime _daysAgo(int days) => DateTime.now().toUtc().subtract(Duration(days: days));

AscentTitle _title(String text) => AscentTitle.parse(text).valueOrNull!;

AscentDescription? _description(String? text) =>
    text == null ? null : AscentDescription.parse(text).valueOrNull;

/// Staze se prave funkcijom, a ne konstantom, jer datumi zavise od trenutka pokretanja.
List<Ascent> seedAscents() => [
  // čeka odluku moderatora
  Ascent(
    const AscentId('a-1'),
    const PeakId('p-trem'),
    ana.id,
    _title('Trem iz Rakoša'),
    _description('Izlaz na greben posle sat vremena, dalje nema vode.'),
    Difficulty.moderate,
    14.5,
    const [
      Waypoint(0, 430, 'Rakoš', 'kraj sela', null),
      Waypoint(4, 780, 'Greben', 'izlaz iz šume', null),
      Waypoint(9.2, 1320, 'Sedlo', 'vetrovito', null),
      Waypoint(14.5, 1810, 'Trem', 'vrh', null),
    ],
    const [],
    Confirmed({UserId('u-marko'), UserId('u-jovana')}, _daysAgo(2)),
    _daysAgo(4),
  ),
  Ascent(
    const AscentId('a-2'),
    const PeakId('p-gobelja'),
    petar.id,
    _title('Gobelja, stari rudarski put'),
    _description('Markacija postoji, ali je izbledela na poslednjoj trećini.'),
    Difficulty.moderate,
    11,
    const [
      Waypoint(0, 980, 'Brzeće', 'centar sela', null),
      Waypoint(4.5, 1300, 'Rudnik', 'ostaci kolica', null),
      Waypoint(11, 1934, 'Gobelja', 'vrh', null),
    ],
    const [],
    Confirmed({UserId('u-ana'), UserId('u-stefan')}, _daysAgo(1)),
    _daysAgo(2),
  ),
  // skuplja potvrde
  Ascent(
    const AscentId('a-3'),
    const PeakId('p-banjska'),
    dunja.id,
    _title('Banjska stena, kratka'),
    _description('Najlepše je pred zalazak sunca.'),
    Difficulty.easy,
    5.2,
    const [
      Waypoint(0, 1080, 'Mitrovac', 'parking', null),
      Waypoint(2.4, 1140, 'Raskrsnica', 'levo za vidikovac', null),
      Waypoint(5.2, 1065, 'Banjska stena', 'vidikovac nad Drinom', null),
    ],
    const [],
    const Proposed({UserId('u-milica')}),
    _daysAgo(6),
  ),
  Ascent(
    const AscentId('a-4'),
    const PeakId('p-kraljev'),
    vuk.id,
    _title('Prečica do skloništa'),
    null,
    Difficulty.hard,
    9.7,
    const [
      Waypoint(0, 900, 'Divčibare', 'parking', null),
      Waypoint(4, 1010, 'Sklonište', 'drvena koliba', null),
      Waypoint(9.7, 1103, 'Kraljev sto', 'vrh', null),
    ],
    const [],
    const Proposed({}),
    _daysAgo(1),
  ),
  // objavljene
  Ascent(
    const AscentId('a-5'),
    const PeakId('p-midzor'),
    jovana.id,
    _title('Midžor iz Topli Dola'),
    _description('Dugačak uspon preko Tri čuke. Voda samo na izvoru posle kolibe.'),
    Difficulty.hard,
    17.4,
    const [
      Waypoint(0, 780, 'Topli Do', 'parking kod česme', null),
      Waypoint(3.6, 1120, 'Koliba', 'poslednja kuća', null),
      Waypoint(7.2, 1480, 'Izvor', 'poslednja voda', null),
      Waypoint(11, 1830, 'Tri čuke', 'izlaz na greben', null),
      Waypoint(17.4, 2169, 'Midžor', 'granični kamen', null),
    ],
    const [],
    Published(const UserId('u-mod'), _daysAgo(13)),
    _daysAgo(15),
  ),
  Ascent(
    const AscentId('a-6'),
    const PeakId('p-pancic'),
    marko.id,
    _title('Pančićev vrh od Suvog Rudišta'),
    _description('Širok put, prohodan i zimi. Poslednji deo iznad šume.'),
    Difficulty.easy,
    4.6,
    const [
      Waypoint(0, 1700, 'Suvo Rudište', 'parking i info tabla', null),
      Waypoint(1.8, 1830, 'Raskrsnica', 'levo prema mauzoleju', null),
      Waypoint(3.4, 1940, 'Iznad šume', 'vidi se vrh', null),
      Waypoint(4.6, 2017, 'Pančićev vrh', 'mauzolej i toranj', null),
    ],
    const [],
    Published(const UserId('u-mod'), _daysAgo(11)),
    _daysAgo(12),
  ),
  Ascent(
    const AscentId('a-7'),
    const PeakId('p-avala'),
    milica.id,
    _title('Avala sa Zuca'),
    _description('Kružna staza kroz bukovu šumu, pogodna i za početnike.'),
    Difficulty.easy,
    6.4,
    const [
      Waypoint(0, 220, 'Zuce', 'autobuska stanica', null),
      Waypoint(2.3, 330, 'Šumski put', 'skretanje desno', null),
      Waypoint(4.6, 430, 'Spomenik', 'stepenice', null),
      Waypoint(6.4, 511, 'Avala', 'toranj', null),
    ],
    const [],
    Published(const UserId('u-mod'), _daysAgo(39)),
    _daysAgo(40),
  ),
  Ascent(
    const AscentId('a-8'),
    const PeakId('p-sturac'),
    nikola.id,
    _title('Veliki Šturac iz Majdana'),
    _description('Uspon preko livada, poslednji deo je kamenit. Voda na pola puta.'),
    Difficulty.moderate,
    12.8,
    const [
      Waypoint(0, 540, 'Majdan', 'parking kod škole', null),
      Waypoint(4.4, 760, 'Livade', 'nema hlada', null),
      Waypoint(8, 930, 'Izvor', 'poslednja voda', null),
      Waypoint(12.8, 1132, 'Veliki Šturac', 'predajnik', null),
    ],
    const [],
    Published(const UserId('u-mod'), _daysAgo(27)),
    _daysAgo(28),
  ),
  Ascent(
    const AscentId('a-9'),
    const PeakId('p-babin'),
    jovana.id,
    _title('Babin zub sa Konjarnika'),
    _description('Kratko i strmo na kraju, stene na vrhu traže pažnju.'),
    Difficulty.moderate,
    5.2,
    const [
      Waypoint(0, 1320, 'Konjarnik', 'parking ispod hotela', null),
      Waypoint(2.1, 1520, 'Sedlo', 'skretanje za stene', null),
      Waypoint(5.2, 1758, 'Babin zub', 'vrh', null),
    ],
    const [],
    Published(const UserId('u-mod'), _daysAgo(20)),
    _daysAgo(22),
  ),
  Ascent(
    const AscentId('a-10'),
    const PeakId('p-tornik'),
    dunja.id,
    _title('Tornik sa Ribnice'),
    _description('Deo staze ide pod žičarom, lako se prati.'),
    Difficulty.moderate,
    7.1,
    const [
      Waypoint(0, 1100, 'Ribnica', 'donja stanica žičare', null),
      Waypoint(2.6, 1260, 'Livade', 'prelaz preko staze', null),
      Waypoint(5, 1390, 'Gornja stanica', 'česma', null),
      Waypoint(7.1, 1496, 'Tornik', 'vrh Zlatibora', null),
    ],
    const [],
    Published(const UserId('u-mod'), _daysAgo(8)),
    _daysAgo(9),
  ),
  // odbijena
  Ascent(
    const AscentId('a-11'),
    const PeakId('p-kozji'),
    stefan.id,
    _title('Kozji rid preko Mitrovca'),
    _description('Šumska staza, blagi uspon, na kraju proplanak sa pogledom.'),
    Difficulty.moderate,
    9.8,
    const [
      Waypoint(0, 1080, 'Mitrovac', 'početak markacije', null),
      Waypoint(3.2, 1230, 'Crveni potok', 'drveni most', null),
      Waypoint(9.8, 1591, 'Kozji rid', 'najviši vrh Tare', null),
    ],
    const [],
    Rejected('Staza prelazi privatni posed bez dozvole vlasnika.', const UserId('u-mod'), _daysAgo(32)),
    _daysAgo(34),
  ),
  // arhivirana
  Ascent(
    const AscentId('a-12'),
    const PeakId('p-gobelja'),
    milica.id,
    _title('Gobelja, zimska varijanta'),
    _description('Predlog je povukao autor.'),
    Difficulty.hard,
    13.2,
    const [
      Waypoint(0, 980, 'Brzeće', 'parking', null),
      Waypoint(6, 1500, 'Sedlo', 'vetrovito', null),
      Waypoint(13.2, 1934, 'Gobelja', 'vrh', null),
    ],
    const [],
    Archived(const UserId('u-milica'), _daysAgo(49)),
    _daysAgo(50),
  ),
  // priprema prijavljenog korisnika, vidi je samo on
  Ascent(
    const AscentId('a-13'),
    const PeakId('p-kraljev'),
    currentUser.id,
    _title('Maljen preko Divčibara'),
    null,
    Difficulty.easy,
    6.2,
    const [
      Waypoint(0, 980, 'Divčibare', 'centar', null),
      Waypoint(6.2, 1103, 'Kraljev sto', 'vrh', null),
    ],
    const [],
    const Draft(),
    _daysAgo(0),
  ),
];