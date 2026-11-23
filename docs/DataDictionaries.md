# Data Dictionaries

Reglas de negocio de los Data Dictionaries (`DDSrc/*.dd`) y cambios visuales de los Sprints 3 y 4.

Los DD siguen la estructura que genera el Data Dictionary Modeler: todo lo que el Modeler sabe
modelar (etiquetas, opciones de columna, rangos, mensajes de validación, padres opcionales,
borrado en cascada, tablas de validación) está dentro de `Construct_Object` y `Field_Defaults`, y
la lógica propia va en métodos aparte (`Validate_Save`, `Update`, `Backout`, `Save_Main_File`,
`Operation_Not_Allowed` y funciones de validación registradas con `Register_Function`). Así los
ficheros se siguen abriendo en el Modeler.

## Criterios comunes

- **PK protegidas** (Sprint 4): el `ID` de cada tabla tiene `Key_Field_State`. Con
  `Protect_Key_State` (activo por defecto) el DD rechaza el cambio del `ID` de un registro ya
  guardado (`DD_TEXT_NO_KEY_CHANGE_ALLOWED`).
- **Nombres no modificables** (Sprint 4): `Nombre` (y `Apellido` en jugador y entrenador) llevan
  `DD_COMMIT`. Se probaron las tres opciones del enunciado:
  - `DD_NOPUT`: el usuario puede escribir, pero el valor no pasa al buffer y el cambio se pierde
    sin aviso.
  - `DD_NOENTER`: el campo sale deshabilitado, pero un valor que llegue por código sí se graba.
  - `DD_DISPLAYONLY`: las dos a la vez; es la más completa.

  Las tres son fijas: bloquean también el alta, y con `DD_REQUIRED` no se podría crear ningún
  registro. `DD_COMMIT` aplica `DD_DISPLAYONLY` solo cuando el registro ya está guardado
  (`File_Field_Committed_Options`), y las vistas drilldown deshabilitan el campo en ese momento.
  Para los campos indexados DataFlex solo aplica `DD_NOPUT`; cada DD devuelve `True` en
  `Field_CommitNoEnterOnIndex` para que también sean `DD_DISPLAYONLY`.

- **Etiquetas**: todas las columnas tienen etiqueta larga (`Field_Label_Long`), corta
  (`Field_Label_Short`) y ayuda breve (`Status_Help`) en español. Los mensajes de error que
  nombran una columna usan la etiqueta larga.
- **Requeridos**: `Nombre`, `Apellido` y `Pais` son `NOT NULL` en MariaDB, así que llevan
  `DD_REQUIRED`. El usuario ve el aviso al salir del campo o al guardar, en lugar del error de la
  base de datos. `DD_REQUIRED` no se usa en columnas numéricas (la documentación lo desaconseja).
- **IDs**: ningún DD usa `Field_Auto_Increment`. Los IDs los asigna MariaDB (`AUTO_INCREMENT`);
  usar a la vez el contador de DataFlex duplicaría la numeración.
- **Comprobaciones de duplicados**: se hacen en una validación de columna (`Field_Validate_msg`) y
  no en `Validate_Save`, porque necesitan hacer un `Find` y `Validate_Save` se ejecuta con los
  buffers ya cargados y bloqueados: la documentación prohíbe buscar o limpiar buffers ahí. La
  validación de columna se ejecuta antes del bloqueo; al terminar la búsqueda se resincroniza el
  buffer global con `Refind_Records` (o se limpia si es un alta). Los índices únicos de MariaDB
  siguen siendo la última garantía.
- **Borrados**: las tablas padre usan `Cascade_Delete_State` a `False`. Con eso
  `Validate_Delete` comprueba los ficheros cliente (`Add_Client_File`) y rechaza el borrado si
  hay registros hijos, en lugar de borrarlos en cascada. El error estándar
  (`DFERR_NO_DELETE_RELATED_RECORDS_EXIST`) se sustituye por un mensaje claro aumentando
  `Operation_Not_Allowed`, que es el mecanismo documentado para cambiar ese mensaje. Además, la
  vista ya no necesita los DDO de los hijos para poder borrar, porque sin cascada solo se valida
  la estructura hacia arriba.

## liga (`cligaDataDictionary`)

| Columna | Etiqueta larga / corta | Reglas |
|---|---|---|
| `ID` | Código de liga / Código | La asigna la BD. `Key_Field_State`. |
| `Nombre` | Nombre de la liga / Liga | Requerido. `DD_COMMIT`. |
| `Pais` | País / País | Requerido. |
| `Equipos` | Nº de equipos / Equipos | `DD_DISPLAYONLY`. |
| `EquiposMax` | Máximo de equipos / Máx. equipos | Por defecto 20. Rango de 2 a 40. |

- **`Equipos` de solo lectura**: lo mantiene el DD de equipo (`Update` / `Backout`, ver más
  abajo) al dar de alta, mover o borrar equipos. Hasta el Sprint 3 lo llevaban triggers de
  MariaDB, que `sql/sprint4.sql` elimina. `DD_DISPLAYONLY` equivale a `DD_NOENTER` + `DD_NOPUT`:
  el campo se ve deshabilitado y el DD nunca escribe en el buffer el valor de la pantalla, así
  que al guardar una liga no se pisa el número de equipos.
- **`EquiposMax`**:
  - Valor por defecto 20 en `Field_Defaults` con `Field_Changed_Value`, para que una liga nueva
    nazca con un máximo razonable y ese valor se guarde.
  - `Field_Value_Range` de 2 a 40, con `Field_Error` en español ("El máximo de equipos debe
    estar entre 2 y 40"). Una liga necesita al menos dos equipos, y 40 es un margen amplio para
    cualquier liga real.
  - `Validate_Save` rechaza un máximo menor que el número de equipos ya inscritos. Se comprueba
    en `Validate_Save` porque compara dos columnas con el registro releído y bloqueado, justo antes
    de grabar. Solo se mira si el usuario ha cambiado `EquiposMax`: el DD de liga también recibe
    `Validate_Save` cuando participa como padre en la grabación de un equipo, y la liga llena ya la
    avisa el DD de equipo.
- **Borrado**: `Cascade_Delete_State` a `False`; una liga con equipos no se borra ("No se puede
  borrar la liga porque tiene equipos..."). Antes la cascada intentaba borrar equipos, jugadores y
  entrenadores, o fallaba con un error técnico de estructura de DDO.

## equipo (`cequipoDataDictionary`)

| Columna | Etiqueta larga / corta | Reglas |
|---|---|---|
| `ID` | Código de equipo / Código | La asigna la BD. `DD_AUTOFIND`. `Key_Field_State`. |
| `Nombre` | Nombre del equipo / Equipo | Requerido. `DD_COMMIT`. |
| `LigaID` | Liga / Liga | Padre `liga` obligatorio. |

- **Padre `liga` obligatorio**: `Validate_Save` exige liga (`liga.ID <> 0`) con el mensaje
  "Selecciona la liga del equipo antes de guardar." (regla del Sprint 2). La opción
  `DD_FINDREQ` solo valida los campos visitados, y sin liga MariaDB rechazaría la fila por la
  clave foránea (error 1452).
- **Número de equipos de la liga** (Sprint 4): el par estándar `Update` / `Backout` suma 1 a
  `liga.Equipos` en `Update` y resta 1 en `Backout`. DataFlex envía `Backout` con la liga
  antigua en el buffer y `Update` con la nueva:

  | Operación | Mensajes | Efecto |
  |---|---|---|
  | Alta | `Update` | +1 en la liga |
  | Cambio de liga | `Backout` + `Update` | −1 en la antigua, +1 en la nueva |
  | Edición sin cambiar de liga | `Backout` + `Update` | −1 +1 en la misma liga (sin cambio) |
  | Borrado | `Backout` | −1 en la liga |

  El DD graba las ligas modificadas en la misma transacción que el equipo; si algo falla, se
  deshace todo. También funciona cuando el equipo solo participa como padre, por ejemplo al
  cambiar un jugador de equipo: cada equipo recibe su `Backout` y su `Update` y el número no
  cambia. Los triggers `after insert/update/delete` de MariaDB se eliminan para no contar dos
  veces, y el de liga llena se reescribe para contar los equipos reales (era la última garantía
  de la BD y leía `liga.Equipos`, que DataFlex graba antes que el equipo).
- **Liga llena**: `Validate_Save` se ejecuta después de `Update`, así que cuando un equipo se da
  de alta o se mueve a una liga, `liga.Equipos` ya lo cuenta. Si supera `EquiposMax`, la liga
  estaba llena y se da el error "La liga X ya está completa (n de m equipos)...", que deshace la
  transacción (también el +1). Una edición sin cambio de liga deja el número igual y nunca se
  rechaza.
- **`DD_AUTOFIND` en `ID`**: es la opción que la documentación recomienda en las columnas clave.
  Hace falta para los padres opcionales de `jugador` y `entrenador`: en sus fichas, al vaciar el
  campo Equipo, el autofind deja el DDO de equipo sin registro y el equipo pasa a ser nulo.
- **Borrado**: `Cascade_Delete_State` a `False`; un equipo con jugadores o con entrenador no se
  borra ("No se puede borrar el equipo porque tiene jugadores o entrenador asignados. Quítales
  antes el equipo."). Al ser el equipo opcional en sus hijos, primero se les quita el equipo y
  después se borra.

## entrenador (`centrenadorDataDictionary`)

| Columna | Etiqueta larga / corta | Reglas |
|---|---|---|
| `ID` | Código de entrenador / Código | La asigna la BD. `Key_Field_State`. |
| `Nombre` | Nombre / Nombre | Requerido. `DD_COMMIT`. |
| `Apellido` | Apellido / Apellido | Requerido. `DD_COMMIT`. |
| `Nacionalidad` | Nacionalidad / Nacionalidad | Opcional. Tabla de validación `NACIONAL` (CodeMast). |
| `EquipoID` | Equipo / Equipo | Padre `equipo` opcional. Un entrenador por equipo. |

- **Padre `equipo` opcional**: `Set ParentNullAllowed equipo.File_Number to True` es el
  mecanismo de DataFlex para padres nulos (el Modeler lo muestra en la pestaña Structures). Con él,
  si no hay equipo, el `DD_FINDREQ` no da error y el DDO de equipo no participa en la grabación. Se
  quita la validación del Sprint 2 que obligaba a tener equipo.
- **NULL en MariaDB**: sin padre, DataFlex representa la relación nula como `EquipoID = 0`, que
  no es un equipo válido para la clave foránea. `Save_Main_File` detecta que el DDO de equipo no
  tiene registro y marca la columna con `DF_FIELD_IS_NULL`, así que se graba `NULL`.
- **Un entrenador por equipo**: la validación de columna `ValidarEquipoSinEntrenador` (sobre
  `EquipoID`) busca por el índice 3 (`EquipoID`, `ID`) otro entrenador con el equipo elegido. Si lo
  hay, avisa: "El equipo X ya tiene entrenador (Nombre Apellido). Quítale antes el equipo a ese
  entrenador o elige otro equipo." El equipo elegido se lee del DDO de equipo, porque `EquipoID`
  no recibe el nuevo valor hasta el `Attach` de la grabación. `EquipoID` no tiene control en la
  vista, así que el DD lo valida al guardar.
- **Nacionalidad con tabla de validación** (Sprint 4): ver la sección de jugador, es igual
  (objeto `entrenador_Nacionalidad_VT`).
- **Botón Despedir** (Sprint 4, `ZoomEntrenador.wo`): solo se ve si el entrenador tiene equipo,
  tanto al consultar como al editar. Pide confirmación (`ShowYesNo`). Si se acepta:
  1. `RefreshRecord` descarta los cambios sin guardar de la ficha, para grabar solo el despido.
  2. Se vacía el DDO de equipo, igual que cuando el usuario borra el campo Equipo.
  3. Se graba el entrenador. Por el padre opcional, `EquipoID` queda en `NULL`.
  4. Se informa al usuario y se vuelve al listado, como al guardar.

  No hace falta código nuevo en el DD: el despido usa las reglas que ya tenía (`ParentNullAllowed`
  y `Save_Main_File`).

## jugador (`cjugadorDataDictionary`)

| Columna | Etiqueta larga / corta | Reglas |
|---|---|---|
| `ID` | Código de jugador / Código | La asigna la BD. `Key_Field_State`. |
| `Nombre` | Nombre / Nombre | Requerido. `DD_COMMIT`. |
| `Apellido` | Apellido / Apellido | Requerido. `DD_COMMIT`. |
| `Nacionalidad` | Nacionalidad / Nacionalidad | Opcional. Tabla de validación `NACIONAL` (CodeMast). |
| `EquipoID` | Equipo / Equipo | Padre `equipo` opcional. |

- **Padre `equipo` opcional**: igual que en `entrenador`: `ParentNullAllowed` y `Save_Main_File`,
  que graba `NULL` en `EquipoID` cuando no hay equipo. Así un jugador puede quedar libre, sin
  equipo, y se puede borrar un equipo después de quitárselo a sus jugadores. Se quita la
  validación del Sprint 2 que obligaba a tener equipo.
- Sin cambios en el borrado del jugador: sigue con la cascada por defecto sobre
  `jugadorposicion`, porque esta tarea no la cambia.
- **Nacionalidad con tabla de validación** (Sprint 4):
  - Antes del `Class` se crea el objeto `jugador_Nacionalidad_VT`, un `CodeValidationTable` con
    `Type_Value` `NACIONAL` y `Allow_Blank_State` (la columna admite `NULL`). Se asigna a la
    columna con `Field_Value_Table`, y `Field_Class_Name` `Combo` indica al Studio el control que
    debe generar.
  - Los valores están en `CodeMast` (tipo `NACIONAL`, descrito en `CodeType`) y los carga
    `sql/sprint4.sql`. El código es el propio nombre ("Español", "Francés"...), que es lo que ya
    guardaba la columna, así que no hay que convertir datos. Para que quepa "Mozambiqueño", la
    columna `CodeMast.Code` pasa de 10 a 20 caracteres.
  - En la ficha, `cWebCombo` llena su lista a partir de la tabla de validación del DD, sin código
    en la vista, y el DD rechaza al guardar un valor que no esté en la lista.
  - Las tablas `CodeMast` y `CodeType` usan ahora la misma conexión que el resto
    (`DFCONNID=footballCon` en sus `.int`) en lugar de un DSN con el usuario `root`.
  - La tabla es estática: se carga una vez por proceso. Si se añade una nacionalidad a
    `CodeMast`, aparece al reiniciar la aplicación web.

## posicion (`cposicionDataDictionary`)

| Columna | Etiqueta larga / corta | Reglas |
|---|---|---|
| `ID` | Código de posición / Código | La asigna la BD. `Key_Field_State`. |
| `Nombre` | Nombre de la posición / Posición | Requerido y único. `DD_COMMIT`. |

- **Nombre único**: la validación de columna `ValidarNombreUnico` busca por el índice 2
  (`uqPosicionNombre`). Si el nombre ya existe en otra posición, avisa: "Ya existe una posición
  llamada X. Elige otro nombre." Así no aparece el error de clave duplicada de MariaDB. La
  comparación la hace la BD, con su intercalación.
- **Borrado**: `Cascade_Delete_State` a `False`; una posición asignada a jugadores (filas en
  `jugadorposicion`) no se borra ("No se puede borrar la posición porque está asignada a
  jugadores.").

## jugadorposicion (`cjugadorposicionDataDictionary`)

Tabla puente N:M entre jugador y posición. Solo se añaden etiquetas y ayudas (Código de
asignación, Jugador, Posición); sus reglas no cambian.
En el Sprint 4 su `ID` también lleva `Key_Field_State`.

## Cambios visuales

- **Rótulos**: se quitan los rótulos técnicos (`posicion.Nombre`, `liga.Pais`, `btn`...) de las
  columnas de los listados. Ahora usan las etiquetas cortas del DD (Liga, País, Equipo, Apellido,
  Nombre, Nacionalidad, Posición), y el botón de detalle se llama "Detalle". En la ficha de liga,
  los campos usan las etiquetas largas: País, Nº de equipos y Máximo de equipos. Los controles
  web no leen la etiqueta del DD en ejecución (el Studio la copia al generar la vista), por eso
  los rótulos se escriben en la vista con el mismo texto que el DD.
- **Títulos de vista** (`psCaption`, que se ve en la miga de pan): en plural en los listados
  (Ligas, Equipos, Entrenadores, Jugadores, Posiciones) y en singular en las fichas (Liga, Equipo,
  Entrenador, Jugador, Posición).
- **Dashboard**:
  - Cada tile lleva un icono de la fuente `material-icons` del tema (clase `Tile_Icon`): cuenta
    de usuario en la bienvenida, globo en Ligas, grupo en Equipos, carpeta de notas en
    Entrenadores, persona en Jugadores y marcador de posición en Posiciones.
  - Colores coherentes: la bienvenida usa `Tile Dark` (color principal del tema) y los cinco
    tiles de entidad usan `Tile Light` (fondo blanco, icono y borde superior en el color
    principal, resaltado al pasar el ratón). Antes cada tile tenía una variante distinta
    (`Light`, `LightAlternate`, `Dark`, `DarkAlternate`) que el tema Material pinta igual.
  - Tamaño: el grupo de tiles ocupa todo el ancho del panel (`piColumnSpan 0`; antes 8 de 24
    columnas, y cada tile quedaba en unos 110 px con scroll en los títulos largos). Cada tile mide
    156 px de alto, con 20 px de padding vertical y 16 px horizontal y 8 px de separación, y no
    muestra barras de scroll internas. Las palabras nunca se cortan: el título se ajusta al ancho
    del tile (container query, de 11 a 20 px) y el subtítulo puede ocupar dos líneas.
  - La navegación no cambia: mismos `WebRegisterPath` y `NavigatePath`.
- **CSS**: todo en `AppHtml/CssStyle/application.css` (ya enlazado en `Index.html` después del
  tema), sin estilos en línea. Solo ajusta clases del tema (`Tile`, `Light`, `Dark`,
  `Tile_Icon`, `Tile_Title`, `Tile_Subtitle`), acotadas a la vista `Dashboard`, y usa las
  variables de color del tema (`--df-MainRegular`, `--df-MainLight4`, `--df-Grayscale*`...).
  El enlace lleva versión (`application.css?v=5`), igual que `theme.css`: al cambiar el CSS hay
  que subir el número para que el navegador no siga usando la copia en caché.
- **Botones en español**: en los listados, Buscar y Nuevo; en las fichas, Guardar, Editar, Borrar
  y Descartar cambios.
- **Menú** (`WebApp.src`): se quita la entrada duplicada "Liga", que abría el mismo listado que
  "Ligas". El resto de entradas pasan a plural, como los títulos de los listados (Equipos,
  Entrenadores, Posiciones, Jugadores). Panel de control, Vista y Finalizar sesión ya salían en
  español porque usan las constantes de idioma (`C_$...`) de la instalación española de DataFlex.
- **Login** (`Login.wo`): Usuario, Contraseña, Entrar y el aviso de credenciales incorrectas, en
  español. `LoginDialog.wo` no se toca porque la aplicación no lo incluye.
- **Dashboard**: el título de la vista pasa de "Dashboard" a "Panel de control", como la
  entrada del menú. El subtítulo del tile Jugadores, "60 en plantilla", era un número fijo que
  deja de ser cierto al dar de alta o borrar jugadores (y ahora puede haber jugadores sin equipo).
  Pasa a ser "Futbolistas", en la línea de los otros subtítulos.
- No cambian la navegación del Sprint 2 ni los `OnRowClick`; solo se elimina la entrada de menú
  duplicada.
