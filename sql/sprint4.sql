-- Sprint 4: tablas de validacion (nacionalidades).
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
