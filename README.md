# FootballApp

Aplicación web en **DataFlex** sobre **MariaDB** para consultar ligas, equipos, entrenadores,
jugadores y posiciones. Dashboard con tarjetas, y por cada entidad un listado (Select) y una
ficha de detalle (Zoom), con navegación drilldown entre ellas.

## Base de datos

`football`, con seis tablas: `liga`, `equipo`, `entrenador`, `jugador`, `posicion` y la tabla
puente `jugadorposicion`. Datos de partida: 2 ligas, 6 equipos, 7 entrenadores y 60 jugadores.

Relaciones: `equipo.LigaID -> liga.ID`, `jugador.EquipoID -> equipo.ID`,
`entrenador.EquipoID -> equipo.ID`, `jugadorposicion.JugadorID -> jugador.ID` y
`jugadorposicion.PosicionID -> posicion.ID`.

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
   Las versiones de las dependencias (Web UI y tema Material) quedan fijadas en
   `FootballApp.sws.lock`.

Usuario de la aplicación: `admin` / `admin`.

## Navegación (Sprint 2)

El framework decide el tipo de navegación comparando la tabla principal del objeto que navega
con la de la vista destino. La aplicación muestra los cuatro tipos:

| Tipo | Cómo se llega | Resultado |
|---|---|---|
| `nfFromMain` | Listado de jugadores → clic en una fila | Se abre la ficha del jugador (misma tabla principal) |
| `nfFromChild` | Ficha de jugador, entrenador o equipo → prompt del campo padre (Equipo / Liga) | El listado actúa como búsqueda: al elegir una fila vuelve con el padre seleccionado |
| `nfFromParent` | Ficha de liga → botón **Ver equipos** | Listado de equipos filtrado solo a esa liga |
| `nfUndefined` | Ficha de jugador → botón **Ver posiciones**, o el Dashboard | Listado de posiciones completo, sin filtrar (jugador y posición solo se relacionan N:M) |

Además, la ficha de liga incluye una lista de solo lectura con sus equipos, resuelta dentro de
la propia vista con un DDO hijo de `equipo`.

Para comprobarlo, la ficha de jugador y los listados de equipos y posiciones tienen al pie una
etiqueta de diagnóstico con el tipo de navegación, la vista invocadora y el objeto invocador
(clase `cNavigateInfoLabel`, en `AppSrc/cNavigateInfoLabel.pkg`).

El prompt de Liga de la ficha de equipo se oculta cuando se llega desde *Liga → Ver equipos*,
porque el listado de ligas ya está en la pila de navegación y la liga viene fijada.

## Reglas de datos

Un jugador y un entrenador deben tener equipo, y un equipo debe tener liga. Si se guarda sin
elegirlo, la aplicación muestra un aviso en lugar del error de clave foránea de MariaDB
(validación en `Validate_Save` de los Data Dictionaries).

## Git

Flujo **gitflow**: `main` estable y etiquetada, `develop` de integración y una rama
`feature/*` por funcionalidad (`fix/*` para correcciones y `chore/*` para mantenimiento).
Las fusiones se hacen con `--no-ff` para conservar la traza de cada rama en el historial.

Cada sprint se etiqueta en `main`: `v1.0` (Sprint 1) y `v2.0` (Sprint 2: navegación).

La salida del compilador (`*.exe`, `*.dbg`, `*.prn`, `*.dep`), las cachés, los ficheros
locales del Studio y los logs no se versionan (ver `.gitignore`).

## Autor

Práctica académica — Sprint 2 - Omar A..
