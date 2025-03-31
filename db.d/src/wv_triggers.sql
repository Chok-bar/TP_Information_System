-- triggers need functions, not procedures, so gotta wrap it up like a christmas present on… christmas day. Cmon, i can’t always be funny, it’s hard
CREATE FUNCTION username_to_lower_function()
RETURNS TRIGGER 
LANGUAGE plpgsql AS $$
BEGIN
    CALL username_to_lower();
    RETURN NEW;
END;
$$;

CREATE TRIGGER enforce_username_to_lower
AFTER INSERT ON players
FOR EACH ROW
EXECUTE FUNCTION username_to_lower_function();

CREATE FUNCTION complete_turn_function()
RETURNS TRIGGER
LANGUAGE plpgsql AS $$
BEGIN
	IF NOT EXISTS (SELECT id_player FROM players_in_parties WHERE id_party = NEW.id_PARTY AND is_alive = TRUE) EXCEPT (SELECT id_player FROM players_play WHERE id_turn = NEW.id_turn)
	THEN CALL COMPLETE_TOUR(NEW.id_turn, NEW.id_party);
	RETURN NEW;
END;

CREATE TRIGGER enforce_complete_tour
AFTER INSERT ON players_play
FOR EACH ROW
EXECUTE FUNCTION complete_tour_function();
