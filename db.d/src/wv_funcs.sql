CREATE OR REPLACE FUNCTION random_position(party_id INT) 
RETURNS TABLE (random_col INT, random_row INT) AS $$
DECLARE
    max_col INT := (select grid_x from parties where party_id = party_id);
    max_row INT := (select grid_x from parties where party_id = party_id);
BEGIN
    LOOP
        random_col := floor(random() * max_col) + 1;
        random_row := floor(random() * max_row) + 1;

        IF NOT EXISTS (
            SELECT 1
            FROM players_in_parties
            WHERE id_party = party_id
            AND origin_position_col = random_col
            AND origin_position_row = random_row
        ) THEN
            RETURN NEXT;
            EXIT;
        END IF;
    END LOOP;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION random_role(party_id INT) 
RETURNS INT AS $$
DECLARE
    max_wolves INT := (select max_wolves from parties where id_party = party_id);
    max_villagers INT := (select max_villagers from parties where id_party = party_id);
    current_wolves INT;
    current_villagers INT;
    new_role INT;
	id_wolf_role INT := (select id_role from roles where description_role == 'loup');
	id_villager_role INT := (select id_role from roles where description_role == 'villageois');
BEGIN
    SELECT COUNT(1) INTO current_wolves
    FROM players_in_parties
    WHERE id_party = party_id AND id_role = id_wolf_role;

    SELECT COUNT(1) INTO current_villagers
    FROM players_in_parties
    WHERE id_party = party_id AND id_role = id_villager_role;

	CASE
		WHEN current_wolves + current_villagers = (select max_players from parties where id_party = party_id)
		THEN new_role := 0
		WHEN current_wolves / max_wolves > current_villagers / max_villagers
		THEN new_role := id_villager_role
		ELSE new_role := id_wolf_role		
    END

    RETURN new_role;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_the_winner(party_id INT) 
RETURNS TABLE (
    player_name TEXT, 
    role_name TEXT, 
    party_name TEXT, 
    player_turns INT, 
    total_turns INT, 
    avg_decision_time INTERVAL
) AS $$
DECLARE
	id_wolf_role INT := (select id_role from roles where description_role == 'loup');
	id_villager_role INT := (select id_role from roles where description_role == 'villageois');
BEGIN
	
	DECLARE total_turns INT;
    SELECT COUNT(*) INTO total_turns
    FROM turns
    WHERE id_party = party_id;

	DECLARE winning_team INT;
	CASE
		WHEN (NOT EXISTS (
			select (1) from players_in_parties where id_party = party_id and is_alive = TRUE and id_role = id_villager_role
		)
		THEN winning_team := id_wolf_role;
		ELSE winning_team := id_villager_role;
	END

	DECLARE names_and_times TABLE;
	names_and_times := (select p.pseudo, avg(pp.start_time - pp.end_time) from players p
		join players_in_parties pip on p.id_player = pip.id_player
		join players_play pp on p.id_player = pp.id_player
		join turns t on t.id_turn = pp.id_turn
		join parties pt on t.id_party = pt.id_party
		where id_role = winning_team and is_alive = TRUE and id_party = party_id
		group by p.id_player
	);

	DECLARE party_name text := (select title_party from parties where id_party = party_id);

    RETURN QUERY 
    SELECT (select 1 from names_and_times), winning_team, party_name, total_turns total_turns, (select 2 from names_and_times);
	-- total turns is always equal to an individual’s turns played
END;
$$ LANGUAGE plpgsql;

