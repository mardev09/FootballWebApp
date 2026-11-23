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

1. Ejecutar `football_mariadb.sql` contra MariaDB y después
   [`sql/sprint4.sql`](sql/sprint4.sql) (nacionalidades en CodeType/CodeMast y número de
   equipos de la liga gestionado por la aplicación):

   ```
   mariadb --default-character-set=utf8mb4 -u dataflex -p football < sql/sprint4.sql
   ```

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

Las reglas viven en los Data Dictionaries (`DDSrc`) y están explicadas tabla por tabla, junto con
los cambios visuales, en [docs/DataDictionaries.md](docs/DataDictionaries.md). En resumen:

- Un equipo debe tener liga, y no se puede dar de alta ni mover a una liga llena
  (`Equipos >= EquiposMax`). El número de equipos de la liga se actualiza solo al dar de alta,
  cambiar de liga o borrar un equipo.
- Los PK no se pueden modificar, y los nombres y apellidos se escriben al dar de alta y quedan
  bloqueados una vez guardados.
- La nacionalidad de jugadores y entrenadores se elige de una lista (tabla de validación).
- Un entrenador se puede despedir desde su ficha: queda sin equipo.
- Jugador y entrenador pueden quedar sin equipo (padre opcional; `EquipoID` se guarda como `NULL`).
  Un equipo tiene como mucho un entrenador.
- No se puede borrar una liga con equipos, un equipo con jugadores o entrenador, ni una posición
  asignada a jugadores.
- Los nombres de posición no se repiten, y el máximo de equipos de una liga va de 2 a 40 (20 por
  defecto) y nunca es menor que los equipos inscritos.

En todos los casos la aplicación muestra un aviso en español en lugar del error de MariaDB.

## Sprint 3: Data Dictionaries y mejoras visuales

**Data Dictionaries** (`DDSrc`). Las reglas de datos de la sección anterior se implementan en los
DD siguiendo el curso *Getting to know the Data Dictionaries* y respetando la estructura del Data
Dictionary Modeler, para que los ficheros se sigan abriendo en él:

- Todas las columnas tienen etiqueta larga y corta y ayuda breve en español.
- `Nombre`, `Apellido` y `Pais` son requeridos (`DD_REQUIRED`).
- `liga.Equipos` es de solo lectura (`DD_DISPLAYONLY`), porque lo mantiene la BD.
- `liga.EquiposMax` vale 20 por defecto y tiene un rango de 2 a 40.
- El equipo es un padre opcional para jugador y entrenador (`ParentNullAllowed`); sin equipo,
  `EquipoID` se graba como `NULL`.
- Los borrados con hijos se impiden con `Cascade_Delete_State` a `False`, con mensajes claros en
  lugar del error estándar.
- Ningún ID usa el auto-incremento de DataFlex.

**Mejoras visuales**:

- Columnas y campos con rótulos en español, en lugar de rótulos técnicos como `posicion.Nombre`.
- Títulos de vista en plural en los listados y en singular en las fichas.
- Botones en español: Buscar, Nuevo, Guardar, Editar, Borrar y Descartar cambios.
- Menú sin la entrada duplicada "Liga".
- Pantalla de acceso en español.
- Dashboard:
  - "Panel de control" como título de la vista.
  - Tiles a todo el ancho, con icono del tema Material.
  - Colores coherentes: bienvenida en azul y entidades en blanco con acento azul.
  - El subtítulo "Futbolistas" sustituye al número fijo de jugadores.
- Los estilos están en `AppHtml/CssStyle/application.css`, con las clases y los colores del tema.
  El enlace en `Index.html` lleva versión (`?v=5`), y hay que subirla en cada cambio del CSS para
  que el navegador no use una copia en caché.

El detalle de cada regla y su motivo, tabla por tabla, está en
[docs/DataDictionaries.md](docs/DataDictionaries.md).

## Sprint 4: construcción de la clase y validación

**Construcción de la clase** (`DDSrc`):

- **PK protegidas**: el `ID` de las seis tablas tiene `Key_Field_State`. En un registro ya
  guardado el DD rechaza cualquier cambio del `ID`.
- **Nombres y apellidos no modificables**: se compararon las tres opciones del enunciado:

  | Opción | Qué hace | Problema |
  |---|---|---|
  | `DD_NOPUT` | Se puede escribir, pero el valor no pasa al buffer | El usuario cree que cambia el nombre y al guardar se pierde sin aviso |
  | `DD_NOENTER` | El campo sale deshabilitado | Si el valor llega por código, se graba |
  | `DD_DISPLAYONLY` | `NOENTER` + `NOPUT`: ni se escribe ni se graba | Ninguno, es la más segura |

  Las tres son fijas, así que también impiden escribir el nombre al **crear** un registro. Como
  además el nombre es requerido, el botón Nuevo dejaría de funcionar. Por eso se usa
  `DD_COMMIT`: con él el campo es editable en un alta y pasa a ser `DD_DISPLAYONLY` en cuanto el
  registro está guardado. Se aplica a `Nombre` en las cinco tablas que lo tienen y también a
  `Apellido` en jugador y entrenador. En los campos que forman parte de un índice, DataFlex solo
  aplica `NOPUT` por defecto; cada DD devuelve `True` en `Field_CommitNoEnterOnIndex` para que
  también ahí sea `DD_DISPLAYONLY`.
- **Requeridos**: las columnas de texto `NOT NULL` (`Nombre`, `Apellido`, `Pais`) ya eran
  `DD_REQUIRED`. Las numéricas `NOT NULL` se cubren de otra forma, porque en un número
  `DD_REQUIRED` solo comprueba que no sea 0:
  - los `ID` los asigna la BD;
  - `liga.Equipos` lo calcula la aplicación;
  - `liga.EquiposMax` tiene rango de 2 a 40;
  - las claves de padre obligatorio (`equipo.LigaID` y las de `jugadorposicion`) las exige el
    `Validate_Save` y la relación.
- **Número de equipos de la liga** (`liga.Equipos`): lo mantiene el DD de equipo con
  `Update` (+1 a la liga) y `Backout` (−1). Así se cubren el alta, el cambio de liga (−1 en la
  antigua, +1 en la nueva) y el borrado, dentro de la misma transacción que el equipo. Los
  triggers de MariaDB que hacían lo mismo se eliminan en `sql/sprint4.sql`, porque si no se
  contaría dos veces.
- **Botón Despedir** en la ficha del entrenador: solo aparece si el entrenador tiene equipo. Pide
  confirmación, deja el entrenador sin equipo (`EquipoID` a `NULL`) y vuelve al listado.

**Validación**:

- La nacionalidad de jugador y entrenador es un desplegable (`cWebCombo`) en lugar de un campo
  de texto.
- Las opciones salen de las tablas de validación de DataFlex: el tipo `NACIONAL` en `CodeType` y
  sus valores en `CodeMast`. Son las 20 nacionalidades que tienen hoy los jugadores y
  entrenadores, sin el valor de prueba "Test".
- En el DD, cada campo `Nacionalidad` tiene un `CodeValidationTable` (`Field_Value_Table`), y el
  combo se rellena solo a partir de él. El DD también rechaza un valor que no esté en la lista.

## Git

Flujo **gitflow**: `main` estable y etiquetada, `develop` de integración y una rama
`feature/*` por funcionalidad (`fix/*` para correcciones, `chore/*` para mantenimiento y
`docs/*` para documentación).
Las fusiones se hacen con `--no-ff` para conservar la traza de cada rama en el historial.

Cada sprint se etiqueta en `main`: `v1.0` (Sprint 1), `v2.0` (Sprint 2: navegación), `v3.0`
(Sprint 3: Data Dictionaries y mejoras visuales) y `v4.0` (Sprint 4: construcción de la clase y
validación).

La salida del compilador (`*.exe`, `*.dbg`, `*.prn`, `*.dep`), las cachés, los ficheros
locales del Studio y los logs no se versionan (ver `.gitignore`).

## Uso de inteligencia artificial

Durante el desarrollo se ha utilizado un asistente de inteligencia artificial para agilizar
tareas del proyecto: consultar la documentación de DataFlex, redactar parte del código de los
Data Dictionaries, las vistas y el CSS, y preparar la documentación. Todos los cambios se han
revisado y comprendido, igual que cada proceso del proyecto (reglas de negocio, navegación entre
vistas, flujo de trabajo con gitflow), y las decisiones finales son del autor.

## Autor

Práctica académica — Omar A.
