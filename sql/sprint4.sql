-- Sprint 4: tablas de validacion y numero de equipos de la liga.
-- Se ejecuta una vez sobre la BD `football` (ya creada con football_mariadb.sql):
--   mariadb --default-character-set=utf8mb4 -u dataflex -p football < sql/sprint4.sql
-- Es repetible: se puede volver a ejecutar sin duplicar datos.

SET NAMES utf8mb4;

-- ---------------------------------------------------------------------------------------------
-- 1. Nacionalidades en las tablas de validacion de DataFlex (CodeType + CodeMast).
--    El codigo es el propio nombre de la nacionalidad, que es lo que ya guardan
--    jugador.Nacionalidad y entrenador.Nacionalidad, asi que los datos existentes no cambian.
--    CodeMast.Code es varchar(10) por defecto y "Mozambiqueño" tiene 12 letras: se amplia a 20.
-- ---------------------------------------------------------------------------------------------
ALTER TABLE `codemast` MODIFY `Code` varchar(20) NOT NULL DEFAULT '';

INSERT INTO `codetype` (`Type`, `Description`, `Comment`)
VALUES ('NACIONAL', 'Nacionalidades', 'Nacionalidades de jugadores y entrenadores')
ON DUPLICATE KEY UPDATE `Description` = VALUES(`Description`), `Comment` = VALUES(`Comment`);

-- Solo las nacionalidades que tienen hoy jugadores y entrenadores (sin el valor de prueba "Test").
INSERT INTO `codemast` (`Type`, `Code`, `Description`) VALUES
    ('NACIONAL', 'Alemán',       'Alemán'),
    ('NACIONAL', 'Argentino',    'Argentino'),
    ('NACIONAL', 'Belga',        'Belga'),
    ('NACIONAL', 'Brasileño',    'Brasileño'),
    ('NACIONAL', 'Colombiano',   'Colombiano'),
    ('NACIONAL', 'Egipcio',      'Egipcio'),
    ('NACIONAL', 'Escocés',      'Escocés'),
    ('NACIONAL', 'Esloveno',     'Esloveno'),
    ('NACIONAL', 'Español',      'Español'),
    ('NACIONAL', 'Francés',      'Francés'),
    ('NACIONAL', 'Húngaro',      'Húngaro'),
    ('NACIONAL', 'Inglés',       'Inglés'),
    ('NACIONAL', 'Italiano',     'Italiano'),
    ('NACIONAL', 'Mozambiqueño', 'Mozambiqueño'),
    ('NACIONAL', 'Neerlandés',   'Neerlandés'),
    ('NACIONAL', 'Noruego',      'Noruego'),
    ('NACIONAL', 'Peruano',      'Peruano'),
    ('NACIONAL', 'Polaco',       'Polaco'),
    ('NACIONAL', 'Portugués',    'Portugués'),
    ('NACIONAL', 'Uruguayo',     'Uruguayo')
ON DUPLICATE KEY UPDATE `Description` = VALUES(`Description`);

-- ---------------------------------------------------------------------------------------------
-- 2. liga.Equipos lo mantiene ahora el Data Dictionary de equipo (Update / Backout).
--    Los triggers que sumaban y restaban equipos se eliminan: si no, cada alta, cambio de liga o
--    borrado contaria dos veces.
-- ---------------------------------------------------------------------------------------------
DROP TRIGGER IF EXISTS `trg_equipo_after_insert`;
DROP TRIGGER IF EXISTS `trg_equipo_after_update`;
DROP TRIGGER IF EXISTS `trg_equipo_after_delete`;

-- El trigger de liga llena leia liga.Equipos. DataFlex graba la liga (con el +1) antes que el
-- equipo, asi que ese trigger rechazaria el ultimo hueco libre. Se sustituye por uno que cuenta
-- los equipos reales, y se anade el mismo control al cambiar un equipo de liga. Son la ultima
-- garantia de la BD; el aviso al usuario lo da el DD.
DROP TRIGGER IF EXISTS `trg_equipo_before_insert`;
DROP TRIGGER IF EXISTS `trg_equipo_before_update`;

DELIMITER //

CREATE TRIGGER `trg_equipo_before_insert` BEFORE INSERT ON `equipo`
FOR EACH ROW
BEGIN
    DECLARE vActuales INT;
    DECLARE vMaximo   INT;

    SELECT COUNT(*) INTO vActuales FROM `equipo` WHERE `LigaID` = NEW.`LigaID`;
    SELECT `EquiposMax` INTO vMaximo FROM `liga` WHERE `ID` = NEW.`LigaID`;

    IF vActuales >= vMaximo THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'La liga ya ha alcanzado su numero maximo de equipos';
    END IF;
END//

CREATE TRIGGER `trg_equipo_before_update` BEFORE UPDATE ON `equipo`
FOR EACH ROW
BEGIN
    DECLARE vActuales INT;
    DECLARE vMaximo   INT;

    IF OLD.`LigaID` <> NEW.`LigaID` THEN
        SELECT COUNT(*) INTO vActuales FROM `equipo` WHERE `LigaID` = NEW.`LigaID`;
        SELECT `EquiposMax` INTO vMaximo FROM `liga` WHERE `ID` = NEW.`LigaID`;

        IF vActuales >= vMaximo THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'La liga ya ha alcanzado su numero maximo de equipos';
        END IF;
    END IF;
END//

DELIMITER ;

-- Se recalcula el contador con los equipos reales (la liga de prueba "test" estaba descuadrada).
UPDATE `liga` l
   SET l.`Equipos` = (SELECT COUNT(*) FROM `equipo` e WHERE e.`LigaID` = l.`ID`);
