CREATE VIEW v_parties AS
	SELECT * FROM parties
;

CREATE VIEW v_roles AS
	SELECT * FROM roles
;

CREATE VIEW v_players AS
	SELECT * FROM players
;

CREATE VIEW v_players_in_parties AS
	SELECT * FROM players_in_parties
;

CREATE VIEW v_turns AS
	SELECT * FROM turns
;

CREATE VIEW v_players_play AS
	SELECT * FROM players_play
;

-- actually allows to do all these on the table by through the view ??
-- whith syntax :
-- INSERT INTO v_parties (title_party) VALUES ('Nouvelle partie');
-- INSERT INTO v_parties SET title_party = 'Ancienne partie' WHERE title_party = 'Nouvelle partie';
-- DELETE FROM v_parties WHERE title_party = 'Ancienne partie';

GRANT SELECT, INSERT, UPDATE, DELETE ON v_parties TO PUBLIC;
GRANT SELECT, INSERT, UPDATE, DELETE ON v_roles TO PUBLIC;
GRANT SELECT, INSERT, UPDATE, DELETE ON v_players TO PUBLIC;
GRANT SELECT, INSERT, UPDATE, DELETE ON v_players_in_parties TO PUBLIC;
GRANT SELECT, INSERT, UPDATE, DELETE ON v_turns TO PUBLIC;
GRANT SELECT, INSERT, UPDATE, DELETE ON v_players_play TO PUBLIC;

