CREATE PROCEDURE SEED_DATA(NB_PLAYERS INT, PARTY_ID INT)
LANGUAGE plpgsql AS $$
DECLARE
    turn_count INT;
    max_turns INT := (select max_turns from parties where id_party = PARTY_ID);
	turn_max_time INTERVAL := (select max_decision_time from parties where id_party = PARTY_ID);
BEGIN
    FOR turn_count IN 1..max_turns LOOP
        INSERT INTO turns (id_party) VALUES (PARTY_ID);
    END LOOP;
END $$;

-- note : if this looks terrible, it’s because it is. It could probably be optimised to be 10 times faster at least, but i’m just trying to not have a syntax error, and maybe have it work if i’m feeling spicy
CREATE PROCEDURE COMPLETE_TOUR(TOUR_ID INT, PARTY_ID INT)
LANGUAGE plpgsql AS $$
DECLARE
    id_wolf_role INT := (SELECT id_role FROM roles WHERE description_role = 'loup');
    id_villager_role INT := (SELECT id_role FROM roles WHERE description_role = 'villageois');
    conflict BOOLEAN;
	record RECORD;
BEGIN
	-- start by sanitising
    FOR record IN (SELECT * FROM players_play WHERE id_turn = TOUR_ID) LOOP
		-- ensure they start where they ended last turn

 		-- ensure they only try to move 1 tile
   END LOOP;

	-- then check for conflicts
    FOR record IN (SELECT * FROM players_play WHERE id_turn = TOUR_ID) LOOP
        SELECT EXISTS ( -- members of the same team attempted to move to the same tile
            SELECT 1
            FROM players_play pp
            JOIN turns t ON pp.id_turn = t.id_turn
            JOIN players_in_parties pip ON pp.id_player = pip.id_player
            WHERE pp.id_role = record.id_role
            AND pp.target_position_col = record.target_position_col
            AND pp.target_position_row = record.target_position_row
        ) INTO conflict;
        
        UPDATE players_play
        SET 
            target_position_col = CASE
                WHEN conflict THEN origin_position_col -- cancel movement request in case of conflict
                ELSE target_position_col
            END,
            target_position_row = CASE
                WHEN conflict THEN origin_position_row
                ELSE target_position_row
            END
        WHERE id_player = record.id_player AND id_party = PARTY_ID;

		-- todo : support rocks        

    END LOOP;

    FOR record IN (SELECT * FROM players_play WHERE id_turn = TOUR_ID) LOOP -- kill. my favourite !
        UPDATE players_in_parties
        SET is_alive = CASE
            WHEN EXISTS (
                SELECT 1
                FROM players_play pp
                JOIN turns t ON pp.id_turn = t.id_turn
                JOIN players_in_parties pip ON pp.id_player = pip.id_player
                WHERE pp.id_role = record.id_role
                AND pp.target_position_col = record.target_position_col
                AND pp.target_position_row = record.target_position_row
            ) THEN FALSE
            ELSE TRUE
        END
        WHERE id_player = record.id_player AND id_party = PARTY_ID;
    END LOOP;

	UPDATE turns SET end_time = NOW() WHERE id_turn = TOUR_ID; -- end
	UPDATE turns SET start_time = NOW() -- set new turn starting point
	WHERE id_turn = (SELECT MIN(id_turn) FROM turns WHERE id_turn > TOUR_ID);
	-- this works because we know for sure every turn’s id is greater than the last

END $$;

CREATE PROCEDURE USERNAME_TO_LOWER()
LANGUAGE plpgsql AS $$
BEGIN
    UPDATE players SET pseudo = LOWER(pseudo);
END $$;

