CREATE TYPE actions as ENUM (
	"up",
	"down",
	"left",
	"right"
);

alter table parties (
	PRIMARY KEY id_party
);

alter table roles (
	PRIMARY KEY id_role
);

alter table players (
	PRIMARY KEY id_player
);

alter table players_in_parties (
	ALTER COLUMN is_alive BOOL,
	FOREIGN KEY id_party REFERENCES parties(id_party),
	FOREIGN KEY id_player REFERENCES players(id_player),
	FOREIGN KEY id_role REFERENCES roles(id_role),
	PRIMARY KEY (id_party, id_player)
);

alter table turns (
	PRIMARY KEY id_turn,
	FOREIGN KEY id_party REFERENCES parties(id_party)
);

alter table players_play (
	ALTER COLUMN action actions,

	ALTER COLUMN origin_position_col int,
	ALTER COLUMN origin_position_row int,
	ALTER COLUMN target_position_col int,
	ALTER COLUMN target_position_row int,

	FOREIGN KEY id_player REFERENCES players(id_player),
	FOREIGN KEY id_turn REFERENCES turns(id_turn)
);

