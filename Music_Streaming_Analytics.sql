CREATE DATABASE music_streaming;
USE music_streaming;

/*CREATE TABLES*/
CREATE TABLE Users (
    user_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(120) UNIQUE NOT NULL,
    age INT CHECK (age >= 0),
    country VARCHAR(60) DEFAULT 'Unknown'
);

CREATE TABLE Artists (
    artist_id INT PRIMARY KEY,
    artist_name VARCHAR(120) NOT NULL,
    genre VARCHAR(60),
    country VARCHAR(60)
);

CREATE TABLE Albums (
    album_id INT PRIMARY KEY,
    album_title VARCHAR(150) NOT NULL,
    artist_id INT NOT NULL,
    release_year INT,
    FOREIGN KEY (artist_id) REFERENCES Artists(artist_id)
);

CREATE TABLE Songs (
    song_id INT PRIMARY KEY,
    title VARCHAR(150) NOT NULL,
    duration_sec INT CHECK (duration_sec > 0),
    release_year INT,
    artist_id INT NOT NULL,
    album_id INT,
    FOREIGN KEY (artist_id) REFERENCES Artists(artist_id),
    FOREIGN KEY (album_id) REFERENCES Albums(album_id)
);

CREATE TABLE Playlists (
    playlist_id INT PRIMARY KEY,
    playlist_name VARCHAR(120) NOT NULL,
    user_id INT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

CREATE TABLE PlaylistSongs (
    playlist_id INT,
    song_id INT,
    PRIMARY KEY (playlist_id, song_id),
    FOREIGN KEY (playlist_id) REFERENCES Playlists(playlist_id),
    FOREIGN KEY (song_id) REFERENCES Songs(song_id)
);

CREATE TABLE ListeningHistory (
    history_id INT PRIMARY KEY,
    user_id INT NOT NULL,
    song_id INT NOT NULL,
    played_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    device VARCHAR(40) DEFAULT 'mobile',
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    FOREIGN KEY (song_id) REFERENCES Songs(song_id)
);

CREATE TABLE Subscriptions (
    subscription_id INT PRIMARY KEY,
    user_id INT NOT NULL,
    plan_type ENUM('Free','Premium','Family') NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE,
    price DECIMAL(10,2) DEFAULT 0.00,
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

/* ALTER ADD COLUMN */

ALTER TABLE Users ADD gender ENUM('Male','Female','Other') NULL;
ALTER TABLE Songs ADD play_count INT NOT NULL DEFAULT 0;

INSERT INTO Users (user_id, name, email, age, country, gender) VALUES
(1,'Aarav','aarav@example.com',21,'India','Male'),
(2,'Maya','maya@example.com',24,'USA','Female'),
(3,'Liam','liam@example.com',19,'UK','Male'),
(4,'Isha','isha@example.com',27,'India','Female');

INSERT INTO Artists (artist_id, artist_name, genre, country) VALUES
(1,'Echo Waves','Pop','USA'),
(2,'Raga Roots','Classical','India'),
(3,'Neon Drift','EDM','Germany');

INSERT INTO Albums (album_id, album_title, artist_id, release_year) VALUES
(1,'Blue Horizon',1,2022),
(2,'Morning Ragas',2,2021);

INSERT INTO Songs (song_id, title, duration_sec, release_year, artist_id, album_id) VALUES
(1,'Skyline',210,2022,1,1),
(2,'Night Drive',180,2022,1,1),
(3,'Bhimpalasi',420,2021,2,2),
(4,'Trance Gate',230,2023,3,NULL);

INSERT INTO Playlists (playlist_id, playlist_name, user_id) VALUES
(1,'Chill Mix',1),
(2,'Focus',2);

INSERT INTO PlaylistSongs (playlist_id, song_id) VALUES
(1,1),(1,3),(2,2),(2,4);

INSERT INTO ListeningHistory (history_id, user_id, song_id, played_at, device) VALUES
(1,1,1,'2025-08-01 10:00:00','mobile'),
(2,1,3,'2025-08-01 21:15:00','desktop'),
(3,2,2,'2025-08-02 09:30:00','mobile'),
(4,2,4,'2025-08-02 23:55:00','tablet'),
(5,3,1,'2025-08-03 19:20:00','mobile'),
(6,4,3,'2025-08-04 06:45:00','smart_speaker');

INSERT INTO Subscriptions (subscription_id, user_id, plan_type, start_date, end_date, price) VALUES
(1,1,'Premium','2025-07-01','2025-08-01',199.00),
(2,2,'Free','2025-07-10',NULL,0.00),
(3,3,'Family','2025-06-15','2025-07-15',299.00);

/* UPDATE */
UPDATE Users SET country = 'Canada' WHERE email = 'liam@example.com';

/* DELETE */
DELETE FROM PlaylistSongs WHERE playlist_id = 2 AND song_id = 4;

/* WHERE + LIKE */
/* Find all EDM songs with title like '%Drive%' */
SELECT song_id, title FROM Songs s JOIN Artists a ON s.artist_id = a.artist_id WHERE a.genre = 'EDM' AND s.title LIKE '%Drive%';

/* Total plays per song */
SELECT s.title, COUNT(*) AS play_count FROM ListeningHistory lh JOIN Songs s ON lh.song_id = s.song_id GROUP BY s.title 
HAVING COUNT(*) >= 1 ORDER BY play_count DESC;

/* Average song duration per artist */
SELECT a.artist_name, AVG(s.duration_sec) AS avg_duration_sec FROM Songs s JOIN Artists a ON s.artist_id = a.artist_id 
GROUP BY a.artist_name;

/* Users who listened more than the overall average number of plays */
SELECT u.user_id, u.name, play_ct FROM ( SELECT user_id, COUNT(*) AS play_ct FROM ListeningHistory GROUP BY user_id) t
JOIN Users u ON u.user_id = t.user_id WHERE t.play_ct > (SELECT AVG(cnt) FROM (SELECT COUNT(*) AS cnt FROM ListeningHistory
 GROUP BY user_id)x);

/* STORED PROCEDURE */ 
DELIMITER //
CREATE PROCEDURE GetTopSongsByMonth(IN y INT, IN m INT, IN topN INT)
BEGIN
    SELECT s.title, COUNT(*) AS plays
    FROM ListeningHistory lh
    JOIN Songs s ON lh.song_id = s.song_id
    WHERE YEAR(lh.played_at) = y AND MONTH(lh.played_at) = m
    GROUP BY s.title
    ORDER BY plays DESC
    LIMIT topN;
END //
DELIMITER ;


CALL GetTopSongsByMonth(2025, 8, 3);


 /* TRIGGER */
DELIMITER //
CREATE TRIGGER trg_increment_playcount
AFTER INSERT ON ListeningHistory
FOR EACH ROW
BEGIN
    UPDATE Songs SET play_count = play_count + 1
    WHERE song_id = NEW.song_id;
END //
DELIMITER ;


INSERT INTO ListeningHistory (history_id, user_id, song_id) VALUES (7,1,1);
SELECT song_id, title, play_count FROM Songs WHERE song_id = 1;
