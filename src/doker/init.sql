-- 1. Crear extensión Citus para distribución
CREATE EXTENSION IF NOT EXISTS citus;

-- 2. Crear tablas sin constraints de FK inicialmente
CREATE TABLE users (
    user_id VARCHAR(50) PRIMARY KEY,
    display_name VARCHAR(100),
    email VARCHAR(255) UNIQUE,
    country VARCHAR(50),
    product_type VARCHAR(20),
    created_at TIMESTAMP DEFAULT NOW(),
    last_login TIMESTAMP
);

CREATE TABLE artists (
    artist_id VARCHAR(50) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    genres TEXT[],
    popularity INTEGER CHECK (popularity BETWEEN 0 AND 100),
    followers INTEGER DEFAULT 0,
    image_url VARCHAR(255)
);

CREATE TABLE albums (
    album_id VARCHAR(50) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    release_date DATE,
    total_tracks INTEGER,
    artist_id VARCHAR(50), -- FK se agregará después
    album_type VARCHAR(50),
    cover_image VARCHAR(255)
);

CREATE TABLE tracks (
    track_id VARCHAR(50) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    duration_ms INTEGER,
    explicit BOOLEAN DEFAULT false,
    popularity INTEGER CHECK (popularity BETWEEN 0 AND 100),
    album_id VARCHAR(50), -- FK se agregará después
    disc_number INTEGER,
    track_number INTEGER,
    preview_url VARCHAR(255),
    isrc_code VARCHAR(20)
);

CREATE TABLE artist_tracks (
    artist_id VARCHAR(50),
    track_id VARCHAR(50),
    PRIMARY KEY (artist_id, track_id)
);

CREATE TABLE playlists (
    playlist_id VARCHAR(50) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    owner_id VARCHAR(50), -- FK se agregará después
    public BOOLEAN DEFAULT false,
    collaborative BOOLEAN DEFAULT false,
    tracks_count INTEGER DEFAULT 0,
    version INTEGER DEFAULT 0,
    cover_image VARCHAR(255),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE playlist_tracks (
    playlist_id VARCHAR(50),
    track_id VARCHAR(50),
    added_at TIMESTAMP DEFAULT NOW(),
    added_by VARCHAR(50),
    position INTEGER,
    PRIMARY KEY (playlist_id, track_id, added_at)
);

CREATE TABLE play_events (
    event_id BIGSERIAL PRIMARY KEY,
    user_id VARCHAR(50), -- FK se agregará después
    track_id VARCHAR(50), -- FK se agregará después
    played_at TIMESTAMP DEFAULT NOW(),
    context_type VARCHAR(50),
    context_id VARCHAR(50),
    device_type VARCHAR(50),
    ip_address VARCHAR(50)
);

-- 3. Agregar constraints de foreign key después de crear todas las tablas
ALTER TABLE albums ADD CONSTRAINT fk_album_artist 
    FOREIGN KEY (artist_id) REFERENCES artists(artist_id) ON DELETE CASCADE;

ALTER TABLE tracks ADD CONSTRAINT fk_track_album 
    FOREIGN KEY (album_id) REFERENCES albums(album_id) ON DELETE SET NULL;

ALTER TABLE artist_tracks ADD CONSTRAINT fk_artist_track_artist
    FOREIGN KEY (artist_id) REFERENCES artists(artist_id) ON DELETE CASCADE;
ALTER TABLE artist_tracks ADD CONSTRAINT fk_artist_track_track
    FOREIGN KEY (track_id) REFERENCES tracks(track_id) ON DELETE CASCADE;

ALTER TABLE playlists ADD CONSTRAINT fk_playlist_owner
    FOREIGN KEY (owner_id) REFERENCES users(user_id) ON DELETE CASCADE;

ALTER TABLE playlist_tracks ADD CONSTRAINT fk_playlist_track_playlist
    FOREIGN KEY (playlist_id) REFERENCES playlists(playlist_id) ON DELETE CASCADE;
ALTER TABLE playlist_tracks ADD CONSTRAINT fk_playlist_track_track
    FOREIGN KEY (track_id) REFERENCES tracks(track_id) ON DELETE CASCADE;

ALTER TABLE play_events ADD CONSTRAINT fk_play_event_user
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE SET NULL;
ALTER TABLE play_events ADD CONSTRAINT fk_play_event_track
    FOREIGN KEY (track_id) REFERENCES tracks(track_id) ON DELETE SET NULL;

-- 4. Crear índices para mejorar el rendimiento
CREATE INDEX idx_tracks_album_id ON tracks(album_id);
CREATE INDEX idx_play_events_user_id ON play_events(user_id);
CREATE INDEX idx_play_events_track_id ON play_events(track_id);
CREATE INDEX idx_playlist_tracks_track_id ON playlist_tracks(track_id);
CREATE INDEX idx_playlists_owner_id ON playlists(owner_id);
CREATE INDEX idx_albums_artist_id ON albums(artist_id);

-- 5. Configuración de sharding con Citus
SELECT create_distributed_table('users', 'user_id');
SELECT create_distributed_table('playlists', 'owner_id', colocate_with => 'users');
SELECT create_distributed_table('play_events', 'user_id', colocate_with => 'users');
SELECT create_reference_table('artists');
SELECT create_reference_table('albums');
SELECT create_reference_table('tracks');

-- 6. Crear roles y permisos
CREATE ROLE spotifyapi WITH LOGIN PASSWORD 'api123password';
GRANT CONNECT ON DATABASE spotifydb TO spotifyapi;
GRANT USAGE ON SCHEMA public TO spotifyapi;
GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA public TO spotifyapi;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO spotifyapi;

-- 7. Funciones útiles
CREATE OR REPLACE FUNCTION update_playlist_version()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    NEW.version = NEW.version + 1;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_playlist_version
BEFORE UPDATE ON playlists
FOR EACH ROW EXECUTE FUNCTION update_playlist_version();

-- 8. Vistas para consultas comunes
CREATE VIEW popular_tracks AS
SELECT t.track_id, t.name, a.name as artist, COUNT(pe.event_id) as plays
FROM tracks t
JOIN artist_tracks at ON t.track_id = at.track_id
JOIN artists a ON at.artist_id = a.artist_id
LEFT JOIN play_events pe ON t.track_id = pe.track_id
GROUP BY t.track_id, t.name, a.name
ORDER BY plays DESC
LIMIT 100;