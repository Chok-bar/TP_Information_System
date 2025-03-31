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
    max_wolves INT := (SELECT max_wolves FROM parties WHERE id_party = party_id);
    max_villagers INT := (SELECT max_villagers FROM parties WHERE id_party = party_id);
    current_wolves INT;
    current_villagers INT;
    new_role INT;
    id_wolf_role INT := (SELECT id_role FROM roles WHERE description_role = 'loup');
    id_villager_role INT := (SELECT id_role FROM roles WHERE description_role = 'villageois');
BEGIN
    SELECT COUNT(1) INTO current_wolves
    FROM players_in_parties
    WHERE id_party = party_id AND id_role = id_wolf_role;

    SELECT COUNT(1) INTO current_villagers
    FROM players_in_parties
    WHERE id_party = party_id AND id_role = id_villager_role;

    IF (current_wolves + current_villagers) = (SELECT max_players FROM parties WHERE id_party = party_id) THEN
        new_role := 0;
    ELSIF (current_wolves::FLOAT / max_wolves) > (current_villagers::FLOAT / max_villagers) THEN
        new_role := id_villager_role;
    ELSE
        new_role := id_wolf_role;
    END IF;

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
    id_wolf_role INT := (SELECT id_role FROM roles WHERE description_role = 'loup');
    id_villager_role INT := (SELECT id_role FROM roles WHERE description_role = 'villageois');
    winning_team INT;
BEGIN
    -- Get total number of turns
    total_turns := (SELECT COUNT(*) FROM turns WHERE id_party = party_id);

    -- Determine winning team
    winning_team := CASE
        WHEN NOT EXISTS (
            SELECT 1 FROM players_in_parties WHERE id_party = party_id AND is_alive = TRUE AND id_role = id_villager_role
        )
        THEN id_wolf_role
        ELSE id_villager_role
    END;

    -- Fetch all winners and return them
    RETURN QUERY 
    SELECT 
        p.pseudo AS player_name, 
        CASE WHEN pip.id_role = id_wolf_role THEN 'loup' ELSE 'villageois' END AS role_name, 
        pt.title_party AS party_name, 
        COUNT(t.id_turn) AS player_turns, 
        total_turns, 
        AVG(pp.start_time - pp.end_time) AS avg_decision_time
    FROM players p
    JOIN players_in_parties pip ON p.id_player = pip.id_player
    JOIN players_play pp ON p.id_player = pp.id_player
    JOIN turns t ON t.id_turn = pp.id_turn
    JOIN parties pt ON t.id_party = pt.id_party
    WHERE pip.id_role = winning_team 
      AND pip.is_alive = TRUE 
      AND pip.id_party = party_id
    GROUP BY p.pseudo, pip.id_role, pt.title_party;

END;
$$ LANGUAGE plpgsql;


