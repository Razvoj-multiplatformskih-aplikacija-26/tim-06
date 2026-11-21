# tim-06
# Staze

Aplikacija u kojoj planinari prave i predlažu nove planinarske staze, čak i u planini bez signala, drugi planinari ih potvrđuju i ocenjuju, a moderator ih objavljuje u javni katalog.

## Tim

| Ime i prezime | Broj indeksa | GitHub nalog |
| --- | --- | --- |
| Luka Ljubičić | SI 98/2024 | [@nalog](https://github.com/lljubicic9824si) |
| Anđela Stanišić | SI 77/2025 | [@nalog](https://github.com/astanisic7725si)|

## Zahtevi za temu

1. **Uloge.** Sistem koriste planinari i moderator, sa različitim ovlašćenjima: planinar predlaže stazu, potvrđuje tuđe staze i ocenjuje objavljene, a moderator pregleda sve predloge, objavljuje ili odbija stazu i arhivira je.
2. **Stanja.** Staza prolazi kroz više stanja: priprema, predložena, potvrđena, objavljena i arhivirana, a može biti i odbijena.
3. **Pravila.** Staza se potvrđuje tek kad je potvrde dva druga planinara, autor ne može da potvrdi svoju stazu, a svako potvrđuje samo jednom. Objavljena staza se više ne menja, osim opisa, a ocenu daje samo onaj ko je stazu prešao. Potvrde dolaze od drugih korisnika, pa o prelasku u stanje potvrđena konačno odlučuje server.
4. **Rad bez mreže.** Planinar u planini pravi pripremu staze, beleži da je prešao stazu i povlači svoj predlog i bez signala; izmene se šalju kada se veza vrati.
5. **Posao za osoblje.** Moderator radi sa tabelom svih staza i potvrda, filtrira po stanju i težini i rešava predloge koji čekaju odluku, što je posao za veći ekran.
6. **Javni sadržaj.** Katalog objavljenih staza, sa nazivom, planinom, težinom, dužinom i ocenom, zanima i one koji nemaju nalog, pa ima smisla da ga pronađu pretraživači.

## Delovi sistema

| Deo | Korisnici | Tehnologija | Platforme |
| --- | --- | --- | --- |
| Mobilna aplikacija | planinari | Flutter | Android |
| Backoffice | moderator | Flutter | Windows, veb |
| Javni veb | svi posetioci | Jaspr | pregledač |
| Server | ostali delovi sistema | Relic, PostgreSQL | Linux |
| Domenski paket | svi delovi sistema | Dart | sve |

## Pokretanje iz cistog klona

```bash
git clone <adresa-repozitorijuma> staze
cd staze
cp .env.example .env          # bez ijedne izmene
docker compose up --build     # baza, migracije i server
```

Server je na `http://localhost:8080`, provera: `curl http://localhost:8080/health`.

Pregled baze u pregledacu, kada zatreba: `docker compose --profile tools up adminer`
pa `http://localhost:8082` (sistem PostgreSQL, server `db`, korisnik i lozinka iz `.env`).

Klijenti:

```bash
flutter run -d emulator-5554 --target apps/mobile/lib/main.dart
flutter run -d windows        --target apps/backoffice/lib/main.dart
flutter run -d chrome --web-port 8081 --target apps/backoffice/lib/main.dart
```

Adresa servera se ne upisuje u kod. Android emulator sam zove `10.0.2.2`, desktop i
veb `localhost`. Za pravi telefon ili drugi racunar:
`--dart-define=SERVER_URL=http://192.168.0.10:8080`, a ta adresa se doda u
`CORS_ORIGINS` u `.env` ako se koristi veb.

## Demo nalozi

Lozinka je za sve naloge ista i stoji u `.env` kao `DEMO_PASSWORD` (`staze-demo`).
U bazi postoji samo Argon2id hes; otvorena lozinka se nigde ne cuva.

| Uloga | Korisnicko ime | Gde se prijavljuje |
| --- | --- | --- |
| moderator | `moderator` | backoffice |
| planinar | `ana` | mobilna aplikacija |
| planinar | `petar` | mobilna aplikacija |
| planinar | `jovana`, `marko`, `dunja`, `vuk`, `milica`, `nikola`, `stefan` | mobilna aplikacija |

Prijava u pogresnu aplikaciju prolazi na serveru, ali je aplikacija odbija i kaze
zasto: backoffice sa „Backoffice je za moderatore", mobilna sa „Ova aplikacija je
za planinare".

## Pocetni podaci

Pri prvom podizanju baze upisuje se 8 planina, 11 vrhova, 10 naloga i 13 staza,
od kojih bar jedna u svakom od sest stanja: priprema, ceka potvrde, potvrdjena,
objavljena, odbijena, arhivirana. Isti spisak koriste i klijenti kada rade bez
servera, jer stoji na jednom mestu (`packages/fake_data`).

## Sta se gde nalazi

```
packages/domain         model, stanja i pravila; cist Dart, bez Fluttera
packages/use_cases      akcije nad stazom i portovi (repozitorijum, prijava, vreme)
packages/blocs          blokovi koje dele obe aplikacije
packages/api_contract   adrese, kodovi gresaka i oblik JSON-a; bez domena i bez dart:io
packages/api_mapping    prevod domen <-> ugovor, u oba smera
packages/api_client     repozitorijumi preko HTTP-a, isti za VM i za pregledac
packages/ui             prijava i stanja ekrana, zajednicki za obe aplikacije
packages/ui_text        recenice za korisnika, na jednom mestu
packages/fake_data      podaci i repozitorijum u memoriji
apps/server             Relic i PostgreSQL
apps/mobile             Flutter, Android
apps/backoffice         Flutter, Windows i veb
```

## Adrese

| Metod | Adresa | Prijava |
| --- | --- | --- |
| GET | `/health` | ne |
| GET | `/api/v1/catalog` | ne |
| GET | `/api/v1/ascents` | nije uslov; bez nje se vide samo objavljene |
| GET | `/api/v1/ascents/{id}` | nije uslov |
| POST | `/api/v1/ascents` | planinar |
| POST | `/api/v1/ascents/{id}/submission` | autor staze |
| POST | `/api/v1/ascents/{id}/confirmation` | planinar koji nije autor |
| POST | `/api/v1/ascents/{id}/publication` | moderator |
| POST | `/api/v1/ascents/{id}/rejection` | moderator |
| POST | `/api/v1/ascents/{id}/archival` | autor ili moderator, zavisno od stanja |
| GET | `/api/v1/peaks/{id}/weather` | ne |
| POST | `/api/v1/sessions` | — |
| GET, DELETE | `/api/v1/sessions/current` | da |

## Poziv mimo aplikacije

```bash
# prijava
TOKEN=$(curl -s -X POST http://localhost:8080/api/v1/sessions \
  -H 'Content-Type: application/json' \
  -d '{"username":"ana","password":"staze-demo"}' | python3 -c 'import sys,json;print(json.load(sys.stdin)["token"])')

# planinar pokusava da objavi stazu, sto sme samo moderator
curl -i -X POST http://localhost:8080/api/v1/ascents/a-1/publication -H "Authorization: Bearer $TOKEN"
# -> 403 application/problem+json, "code": "not-allowed"
```

Isto pravilo, isti kod greske i ista poruka koju bi korisnik video da je dugme
uopste bilo prikazano u aplikaciji.