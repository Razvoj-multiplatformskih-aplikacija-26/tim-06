#!/usr/bin/env bash
# Dva planinara potvrdjuju istu stazu u istom trenutku.
#
# Pravilo kaze da staza prelazi u "potvrdjena" tek posle dve potvrde razlicitih
# planinara i da isti planinar ne moze da potvrdi dvaput. Ovaj skript salje
# zahteve paralelno i ispisuje sta se na kraju upisalo.
#
# Pokretanje: bash apps/server/tool/race.sh [id-staze]
set -euo pipefail

SERVER=${SERVER:-http://localhost:8080}
PASSWORD=${DEMO_PASSWORD:-staze-demo}
ASCENT=${1:-a-4}   # a-4 je u stanju "ceka potvrde", bez ijedne potvrde

token() {
  curl -s -X POST "$SERVER/api/v1/sessions" \
    -H 'Content-Type: application/json' \
    -d "{\"username\":\"$1\",\"password\":\"$PASSWORD\"}" \
  | python3 -c 'import sys,json; print(json.load(sys.stdin)["token"])'
}

confirm() {
  curl -s -o "$2" -w '%{http_code}' -X POST \
    "$SERVER/api/v1/ascents/$ASCENT/confirmation" -H "Authorization: Bearer $1"
}

ANA=$(token ana)
PETAR=$(token petar)
MARKO=$(token marko)

echo "== dve potvrde razlicitih planinara, istovremeno =="
confirm "$ANA"   /tmp/staze-ana.json   > /tmp/staze-ana.code &
confirm "$PETAR" /tmp/staze-petar.json > /tmp/staze-petar.code &
wait
echo "ana:   $(cat /tmp/staze-ana.code)"
echo "petar: $(cat /tmp/staze-petar.code)"

echo
echo "== stanje posle toga =="
curl -s "$SERVER/api/v1/ascents/$ASCENT" -H "Authorization: Bearer $ANA" \
  | python3 -m json.tool | grep -A6 '"status"'

echo
echo "== ista osoba potvrdjuje dvaput, istovremeno =="
confirm "$MARKO" /tmp/staze-m1.json > /tmp/staze-m1.code &
confirm "$MARKO" /tmp/staze-m2.json > /tmp/staze-m2.code &
wait
echo "marko 1: $(cat /tmp/staze-m1.code)  $(cat /tmp/staze-m1.json)"
echo "marko 2: $(cat /tmp/staze-m2.code)  $(cat /tmp/staze-m2.json)"
echo
echo "Ocekivano: jedna potvrda prolazi, druga dobija 409 already-confirmed ili"
echo "409 invalid-transition. Broj potvrda u bazi nikada ne poraste za dva."
