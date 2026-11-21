-- migrate:up

CREATE TABLE users (
  id text PRIMARY KEY,
  username text NOT NULL,
  role text NOT NULL CHECK (role IN ('hiker', 'moderator')),
  login text UNIQUE,
  password_hash text
);

CREATE TABLE mountains (
  id text PRIMARY KEY,
  name text NOT NULL,
  country text NOT NULL,
  lat double precision NOT NULL,
  lon double precision NOT NULL
);

CREATE TABLE peaks (
  id text PRIMARY KEY,
  name text NOT NULL,
  mountain_id text NOT NULL REFERENCES mountains (id),
  altitude_m int NOT NULL CHECK (altitude_m > 0),
  lat double precision NOT NULL,
  lon double precision NOT NULL
);

CREATE TABLE ascents (
  id text PRIMARY KEY,
  peak_id text NOT NULL REFERENCES peaks (id),
  author_id text NOT NULL REFERENCES users (id),
  title text NOT NULL,
  description text,
  difficulty text NOT NULL CHECK (difficulty IN ('easy', 'moderate', 'hard')),
  distance_km double precision NOT NULL CHECK (distance_km > 0),
  -- Tacke na putu i trag su lista koja se uvek cita cela, uz stazu, i nikada se
  -- ne pretrazuje po pojedinacnoj tacki. Zato stoje kao jsonb, a ne kao tabela:
  -- odbacena mogucnost je tabela waypoints, koja bi za svaki spisak staza trazila
  -- jos jedno spajanje bez ijednog upita koji bi od nje imao koristi.
  waypoints jsonb NOT NULL,
  track jsonb NOT NULL DEFAULT '[]'::jsonb,
  status text NOT NULL CHECK (status IN ('draft', 'proposed', 'confirmed', 'published', 'rejected', 'archived')),
  status_by text REFERENCES users (id),
  status_at timestamptz,
  reject_reason text,
  created_at timestamptz NOT NULL,
  CONSTRAINT ascents_decided_status_has_author CHECK (
    status IN ('draft', 'proposed') OR status_at IS NOT NULL
  ),
  CONSTRAINT ascents_rejection_has_reason CHECK (
    status <> 'rejected' OR reject_reason IS NOT NULL
  )
);

-- Prag glasova: koliko potvrda treba pise u domenu (requiredConfirmations), ali
-- ko je potvrdio cuva baza. Kljuc (ascent_id, user_id) je ono sto konacno
-- sprecava da isti planinar potvrdi dvaput, pa ni dva zahteva koja stignu u istom
-- trenutku ne mogu da se izbroje kao dve potvrde.
CREATE TABLE ascent_confirmations (
  ascent_id text NOT NULL REFERENCES ascents (id) ON DELETE CASCADE,
  user_id text NOT NULL REFERENCES users (id),
  confirmed_at timestamptz NOT NULL,
  PRIMARY KEY (ascent_id, user_id)
);

CREATE INDEX ascents_by_status ON ascents (status);
CREATE INDEX ascents_by_author ON ascents (author_id);
CREATE INDEX ascents_by_peak ON ascents (peak_id);

-- migrate:down
DROP TABLE ascent_confirmations;
DROP TABLE ascents;
DROP TABLE peaks;
DROP TABLE mountains;
DROP TABLE users;
