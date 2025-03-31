CREATE PROCEDURE SEED_DATA(NB_PLAYERS INT, PARTY_ID INT)
LANGUAGE plpgsql AS $$
DECLARE
    turn_count INT;
    max_turns INT := (select max_turns from parties where id_party = PARTY_ID);
    player_counter INT := 1;
    player_id INT;
    turn_id INT;
	turn_max_time INTERVAL := (select max_decision_time from parties where id_party = PARTY_ID);
BEGIN
    FOR turn_count IN 1..max_turns LOOP
        INSERT INTO turns (id_party, start_time, end_time) VALUES (PARTY_ID, NOW(), NOW()+turn_max_time) RETURNING id_turn INTO turn_id;
    END LOOP;
END $$;

-- note : if this looks terrible, it’s because it is. It could probably be optimised to be 10 times faster at least, but i’m just trying to not have a syntax error, and maybe have it work if possible
CREATE PROCEDURE COMPLETE_TOUR(TOUR_ID INT, PARTY_ID INT)
LANGUAGE plpgsql AS $$
DECLARE
    id_wolf_role INT := (SELECT id_role FROM roles WHERE description_role = 'loup');
    id_villager_role INT := (SELECT id_role FROM roles WHERE description_role = 'villageois');
	record RECORD;
BEGIN
    FOR record IN (SELECT * FROM players_play WHERE id_turn = TOUR_ID) LOOP -- start by sanitising
		-- ensure they start where they ended last turn

		-- ensure they only try to move 1 tile
	
	END LOOP;

    FOR record IN (SELECT * FROM players_play WHERE id_turn = TOUR_ID) LOOP -- then prevent collisions against same teams and moving on rocks
		conflict := (exists (select 1 from players_play pp
				join turns t on pp.id_turn = t.id_turn
				join players_in_parties pip on pp.id_player = pip.id_player
				where id_role = record.id_role
				and target_position_col = record.target_position_col
				and target_position_row = record.target_position_row
		));
		UPDATE players_play
		SET target_position_col = CASE
			WHEN conflict = TRUE THEN target_position_col
			ELSE origin_position_col
		END
		SET target_position_row = CASE
			WHEN conflict = TRUE THEN target_position_row
			ELSE origin_position_row
		END
        WHERE id_player = record.id_player AND id_party = PARTY_ID;
		
		-- todo : support rocks

	END LOOP;

    FOR record IN (SELECT * FROM players_play WHERE id_turn = TOUR_ID) LOOP	-- kill
		UPDATE players_in_parties
		SET is_alive = CASE
			WHEN (exists (select 1 from players_play pp
				join turns t on pp.id_turn = t.id_turn
				join players_in_parties pip on pp.id_player = pip.id_player
				where id_role = record.id_role
				and target_position_col = record.target_position_col
				and target_position_row = record.target_position_row
			)) THEN FALSE
			ELSE TRUE
        WHERE id_player = record.id_player AND id_party = PARTY_ID;
    END LOOP;
END $$;

CREATE PROCEDURE USERNAME_TO_LOWER()
LANGUAGE plpgsql AS $$
BEGIN
    UPDATE players SET pseudo = LOWER(pseudo);
END $$;

