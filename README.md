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
