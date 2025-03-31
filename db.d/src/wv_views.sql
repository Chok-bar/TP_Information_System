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

-- extra views :
CREATE VIEW ALL_PLAYERS AS
	SELECT 
	    p.pseudo,
	    COUNT(DISTINCT pip.id_party) as nb_parties,
	    COUNT(DISTINCT pp.id_turn)as nb_turns,
	    MIN(tp.start_time) as first_action,
	    MAX(pp.end_time) as last_action
	FROM players p
	JOIN players_in_parties pip ON pip.id_player = p.id_player
	JOIN parties pr ON pr.id_party = pip.id_party
	JOIN players_play pp ON pp.id_player = p.id_player
	JOIN turns tp ON tp.id_turn = pp.id_turn
	GROUP BY p.pseudo
ORDER BY nb_parties DESC, first_action, last_action, p.pseudo;

CREATE VIEW ALL_PLAYERS_ELAPSED_GAME AS
	SELECT 
	    p.pseudo,
	    pr.title_party,
	    COUNT(DISTINCT pip.id_player),
	    MIN(pp.end_time),
	    MAX(pp.end_time),
	    EXTRACT(EPOCH FROM (MAX(pp.end_time) - MIN(pp.start_time))) AS time_in_game
	FROM players p
	JOIN players_in_parties pip ON pip.id_player = p.id_player
	JOIN parties pr ON pr.id_party = pip.id_party
	JOIN players_play pp ON pp.id_player = p.id_player
	JOIN turns tp ON tp.id_turn = pp.id_turn
GROUP BY p.id_player, pr.id_party;

CREATE VIEW ALL_PLAYERS_ELAPSED_TOUR AS
	SELECT 
	    p.pseudo,
	    pr.title_party,
	    tp.id_turn,
	    tp.start_time,
	    pp.end_time,
	    EXTRACT(EPOCH FROM (pp.end_time - tp.start_time)) AS decision_time
	FROM players p
	JOIN players_in_parties pip ON pip.id_player = p.id_player
	JOIN parties pr ON pr.id_party = pip.id_party
	JOIN players_play pp ON pp.id_player = p.id_player
	JOIN turns tp ON tp.id_turn = pp.id_turn
ORDER BY p.pseudo, pr.title_party, tp.id_turn;


