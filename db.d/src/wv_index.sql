DROP TABLE IF EXISTS parties;
DROP TABLE IF EXISTS roles;
DROP TABLE IF EXISTS players;
DROP TABLE IF EXISTS players_in_parties;
DROP TABLE IF EXISTS turns;
DROP TABLE IF EXISTS players_play;

CREATE TYPE actions AS ENUM (
	'up',
	'down',
	'left',
	'right'
);

create table parties (
    id_party SERIAL PRIMARY KEY,
    title_party text
	grid_x INT,
	grid_y INT,
	max_decision_time INT,
	max_turns INT,
	obstacles_count INT,
	max_players INT,
	max_wolves INT,
	max_villagers INT
);

create table roles (
    id_role SERIAL PRIMARY KEY,
    description_role text
);

create table players (
    id_player SERIAL PRIMARY KEY,
    pseudo text
);

create table players_in_parties (
    id_party int REFERENCES parties(id_party),
    id_player int REFERENCES players(id_player),
    id_role int REFERENCES roles(id_role),
    is_alive BOOLEAN,
	PRIMARY KEY (id_party, id_player)
);

create table turns (
    id_turn SERIAL PRIMARY KEY,
    id_party int REFERENCES parties(id_party),
    start_time timestamp,
    end_time timestamp
);

create table players_play (
    id_player int REFERENCES players(id_player),
    id_turn int REFERENCES turns(id_turn),
    start_time timestamp,
    end_time timestamp,
    action varchar(10),
    origin_position_col INT,
    origin_position_row INT,
    target_position_col INT,
    target_position_row INT,
	PRIMARY KEY (id_player, id_turn)
);
