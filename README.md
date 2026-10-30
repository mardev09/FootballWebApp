# FootballApp

Aplicación web en **DataFlex** sobre **MariaDB** para consultar ligas, equipos, entrenadores,
jugadores y posiciones. Dashboard con tarjetas, y por cada entidad un listado (Select) y una
ficha de detalle (Zoom).

## Base de datos

`football`, con seis tablas: `liga`, `equipo`, `entrenador`, `jugador`, `posicion` y la tabla
puente `jugadorposicion`. Datos de partida: 2 ligas, 6 equipos, 7 entrenadores y 60 jugadores.

## Puesta en marcha

1. Ejecutar `football_mariadb.sql` contra MariaDB.
2. Crear el usuario de la aplicación:

   ```sql
   CREATE USER 'dataflex'@'localhost' IDENTIFIED BY 'Flex2026';
   CREATE USER 'dataflex'@'127.0.0.1' IDENTIFIED BY 'Flex2026';
   GRANT ALL PRIVILEGES ON `football`.* TO 'dataflex'@'localhost';
   GRANT ALL PRIVILEGES ON `football`.* TO 'dataflex'@'127.0.0.1';
   ```

3. Crear un DSN de sistema llamado `footballDB` apuntando a `football`. Hay que crearlo en
   los **dos** administradores ODBC, el de 64 y el de 32 bits, con el mismo nombre.
4. Abrir `FootballApp.sws` con el Studio **como administrador**, compilar y ejecutar.

Usuario de la aplicación: `admin` / `admin`.

## Git

Flujo **gitflow**: `main` estable y etiquetada, `develop` de integración y una rama
`feature/*` por funcionalidad. Las fusiones se hacen con `--no-ff` para conservar la traza
de cada rama en el historial.

## Autor

Práctica académica — Sprint 1.