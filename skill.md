---
name: onboarding-pm
description: >-
  Acompaña a un PM de Nexu, paso a paso y verificando cada paso, hasta dejar
  Cursor conectado al repo prestemos_backend: revisa accesos de GitHub, crea
  la llave SSH, clona el repo en solo lectura, lo abre como workspace, lo deja
  actualizándose solo una vez al día, conecta el MCP de Linear y le muestra la
  diferencia entre Ask y Agent. Usar cuando
  alguien arranca su onboarding en el repo, no puede clonarlo, o pregunta qué
  necesita para conectar Cursor.
disable-model-invocation: true
---

# Onboarding de PM: conectar Cursor a `prestemos_backend`

Quien corre esta skill **no es desarrollador**. No sabe qué es una llave SSH ni
por qué `git clone` falla. Tu trabajo es llevarlo de "tengo Cursor abierto" a
"tengo el repo abierto y funcionando", ejecutando tú los comandos y traduciendo
los errores.

**Termina cuando** el repo está clonado, en solo lectura, abierto como
workspace, actualizándose solo, con el MCP de Linear conectado, y el PM entendió
la diferencia entre Ask y Agent. Conectar el MCP de Postgres es otra skill: no lo intentes aquí.

## Distribución (para quien comparte esta skill)

El PM todavía no tiene el repo, así que no puede leer esta skill desde el repo.
Este archivo es la fuente de verdad y está publicado en
https://slnexu.github.io/onboarding-cursor-nexu/skill.md para que el PM lo
instale como skill personal en un solo paso:

1. Abre Cursor en cualquier carpeta, en modo **Agent**, y le pide que descargue
   ese archivo y lo guarde en `~/.cursor/skills/onboarding-pm/SKILL.md`.
2. Recarga la ventana (**Cmd + Shift + P** → *Reload Window*) para que Cursor
   lea la skill nueva.
3. Escribe `/onboarding-pm`.

Si cambias este archivo, vuelve a publicarlo: el repo que sirve la página es
`SLnexu/onboarding-cursor-nexu` y ahí vive como `skill.md`.

Lo que el PM debía preparar **antes** de la sesión (cuentas, accesos, descargas)
está en [mensaje-equipo.md](mensaje-equipo.md), junto con los mensajes para
pedirle los accesos a los admins. Esa misma guía está publicada como página en
https://slnexu.github.io/onboarding-cursor-nexu/, que es el enlace que se le
comparte al PM por Slack.

## Prerrequisitos (verifícalos antes de arrancar)

Sin estos cuatro, la sesión se atora esperando a alguien más. Si falta alguno,
**dilo de entrada y detén el flujo**: es más barato reagendar que dejarlo a
medias.

| Prerrequisito | Por qué bloquea |
|---|---|
| **Invitación al repo ya aceptada** (no solo pedida) | Sin acceso no hay clon, y la invitación la aprueba otra persona |
| **Mac** | Esta skill asume macOS (`pbcopy`, `xcode-select`). En Windows los comandos no aplican |
| **Permiso de administrador en la computadora** | Instalar Cursor y las Command Line Tools lo requiere; en laptop corporativa bloqueada, no hay vuelta |
| **Cursor instalado y con sesión iniciada** en la cuenta de Nexu | Es donde ocurre la conversación |

Y uno más que no detiene la sesión pero sí un paso: sin **acceso al workspace de
Linear**, el Paso 8 no se puede completar. Sigue con lo demás y déjalo anotado.

Lo demás lo puedes resolver en la sesión, pero conviene tenerlo listo porque
son descargas lentas: git instalado (`xcode-select --install`, ~10 min),
alrededor de **500 MB libres** y una red estable para el clon.

## Cómo conversar

Esto importa tanto como los comandos:

- **Un paso a la vez.** Nunca listes todos los pasos ni pegues un bloque de
  comandos. Un paso, su resultado, confirmación, siguiente.
- **Ejecuta tú.** Corre los comandos con la terminal y explica el resultado en
  lenguaje llano. Solo le pides que haga algo cuando de verdad requiere sus
  manos (abrir una página de GitHub, pegar una llave, dar un permiso).
- **Una frase de para qué** antes de cada paso. "Voy a revisar si tu
  computadora ya se puede identificar ante GitHub" — no "voy a correr
  `ssh -T`".
- **Nunca** le pidas contraseñas, tokens ni el contenido de un `.env*` en el
  chat.
- **No repitas un comando que ya falló** sin cambiar algo. Lee el error real y
  diagnostica.
- **Si el bloqueo es de permisos, no lo rodees.** Redacta el mensaje para
  pedirlo (Paso 1) y detén el flujo ahí.

## Paso 0 — Diagnóstico (antes de preguntar nada)

Corre esto primero y sáltate los pasos que ya estén resueltos. No le preguntes
al PM lo que puedes averiguar solo. Si `uname` no devuelve `Darwin`, para aquí:
esta skill es para Mac.

```bash
uname -s
git --version 2>&1 | head -1
ls ~/.ssh/*.pub 2>/dev/null
ssh -T git@github.com 2>&1 | head -1
ls -d ~/prestemos_backend ~/dev/prestemos_backend 2>/dev/null
```

| Lo que ves | Qué significa | A dónde vas |
|---|---|---|
| `git: command not found` | Falta git | Paso 3, nota de Xcode |
| Sin `.pub` | No hay llave SSH | Paso 3 |
| `Hi <usuario>! You've successfully authenticated` | La llave ya está en GitHub | Paso 1 |
| `Permission denied (publickey)` | Hay llave o no, pero GitHub no lo reconoce | Paso 3 |
| Ya existe una carpeta del repo | Puede estar clonado a medias | Verifica con `git -C <ruta> rev-parse --show-toplevel` antes de re-clonar |

Resume en dos líneas lo que encontraste y qué falta. Ese resumen es lo primero
que el PM lee.

## Paso 1 — Acceso al repo en GitHub

El repo es privado: `git@github.com:prestemos/prestemos_backend.git`, en la
organización `prestemos`. Sin acceso, ningún otro paso sirve.

```bash
git ls-remote git@github.com:prestemos/prestemos_backend.git HEAD
```

- **Devuelve un hash** → tiene acceso. Sigue al Paso 4.
- **`Repository not found`** → es problema de **permisos**, no de llave. La
  llave funciona pero la cuenta no está invitada al repo.
- **`Permission denied (publickey)`** → todavía no hay identidad; primero el
  Paso 3 y vuelve aquí.

Si falta el acceso, dale este mensaje **listo para copiar** y detente hasta que
lo confirmen. Pídele antes su usuario de GitHub (sale del `Hi <usuario>!`, o
en `https://github.com/settings/profile`):

```text
Hola Remigio, estoy arrancando en Cursor con el repo del backend.
¿Me puedes dar acceso de lectura?

- Repo: prestemos/prestemos_backend
- Mi usuario de GitHub: <usuario>
- Correo de la cuenta: <correo>
- Acceso: solo lectura (Read), no voy a hacer push

Gracias!
```

## Paso 2 — Cursor

Si te está hablando, Cursor ya está instalado y con sesión iniciada. No hay
nada que verificar; dilo en una línea y sigue.

## Paso 3 — Llave SSH

Es la credencial que identifica su computadora ante GitHub. Explícalo así, no
como criptografía.

Si falta git en macOS, primero:

```bash
xcode-select --install
```

Crear la llave (sin passphrase para no complicar el flujo diario):

```bash
ssh-keygen -t ed25519 -C "<correo>" -f ~/.ssh/id_ed25519 -N ""
```

Copiar la llave **pública** al portapapeles:

```bash
pbcopy < ~/.ssh/id_ed25519.pub
```

Ahora sí necesitas sus manos: que abra `https://github.com/settings/keys`,
**New SSH key**, título con el nombre de su compu, pegue y guarde. La pública
se comparte sin riesgo; la privada (`id_ed25519`, sin `.pub`) nunca sale de su
computadora — dilo explícitamente.

Verifica:

```bash
ssh -T git@github.com 2>&1 | head -1
```

Debe responder `Hi <usuario>!`. Con eso, vuelve al Paso 1.

## Paso 4 — Clonar el repo

Pregúntale dónde quiere la carpeta; si no tiene opinión, usa
`~/dev/prestemos_backend`. Avísale que tarda un par de minutos.

```bash
mkdir -p ~/dev && git clone git@github.com:prestemos/prestemos_backend.git ~/dev/prestemos_backend
```

Verifica que quedó completo:

```bash
git -C ~/dev/prestemos_backend rev-parse --abbrev-ref HEAD
```

## Paso 5 — Dejarlo en solo lectura

Un PM lee y analiza; no publica código. Bloquear el push evita un accidente sin
quitarle nada de lo que sí va a usar:

```bash
git -C ~/dev/prestemos_backend remote set-url --push origin DISABLED_NO_PUSH_CONSUMER_ONLY
git -C ~/dev/prestemos_backend remote -v
```

El `fetch` sigue apuntando a GitHub (puede actualizar) y el `push` queda
deshabilitado. Confírmalo mostrando la salida.

## Paso 6 — Abrir el repo como workspace

Mueve el agente a la carpeta clonada con `move_agent_to_root` y la ruta
absoluta. No le pidas que lo abra a mano ni que reinicie Cursor.

Ya adentro, verifica y muéstrale el resultado:

```bash
git rev-parse --show-toplevel
ls .cursor/rules
```

Las reglas de `.cursor/rules/` se cargan solas: son las que hacen que el agente
guarde reportes en `reportes/`, arme fichas para DEV y consulte la base con
cuidado. Menciónalo en una línea, sin explicarlas.

## Paso 7 — Dejar el repo actualizándose solo

El repo cambia todos los días. Si nadie lo actualiza, en dos semanas el PM va a
estar analizando código que ya no existe, sin enterarse. No va a correr
`git pull` por su cuenta, así que se lo dejas automático.

Es un hook de Cursor: cada vez que abre una sesión revisa si ya pasaron 24 horas
desde la última actualización y, si sí, actualiza el repo en segundo plano. No
retrasa el arranque y no pisa nada: usa `--ff-only`, así que ante cualquier
divergencia se detiene y lo anota en su bitácora. Vive en la carpeta personal de
Cursor, no en el repo, y en cualquier otra carpeta no hace nada porque primero
valida que el `origin` sea `prestemos_backend`.

Descarga el script y hazlo ejecutable:

```bash
mkdir -p ~/.cursor/hooks
curl -fsSL https://slnexu.github.io/onboarding-cursor-nexu/actualizar-repo.sh \
  -o ~/.cursor/hooks/actualizar-repo-prestemos.sh
chmod +x ~/.cursor/hooks/actualizar-repo-prestemos.sh
```

Si `~/.cursor/hooks.json` no existe, créalo con esto. Si ya existe, **agrega la
entrada** a `sessionStart` en vez de sobrescribir el archivo:

```json
{
  "version": 1,
  "hooks": {
    "sessionStart": [
      { "command": "./hooks/actualizar-repo-prestemos.sh", "timeout": 15 }
    ]
  }
}
```

Pruébalo ahí mismo, sin esperar a mañana:

```bash
echo '{"workspace_roots":["'"$HOME"'/dev/prestemos_backend"]}' | ~/.cursor/hooks/actualizar-repo-prestemos.sh
sleep 5 && cat ~/.cursor/hooks/actualizar-repo-prestemos.log
```

La bitácora debe decir `actualizado`. Si dice `fallo al actualizar`, el motivo
real está en las líneas de arriba: casi siempre es que no había red, o que el
repo quedó con commits locales y ya no puede avanzar derecho.

Dilo en una línea: de aquí en adelante, cada día que abra Cursor el repo se pone
al día solo. Y dile dónde está la bitácora, por si algún día quiere confirmarlo.

## Paso 8 — Conectar el MCP de Linear

Esto es lo que le deja consultar y crear tickets desde el chat. Es de un clic:
**no lo mandes a editar un `mcp.json`**.

Requiere que ya tenga acceso al workspace de Linear de Nexu, porque va a pedir
login. Si no lo tiene, sáltate el paso y anótalo como pendiente.

Guíalo por la UI, un paso a la vez:

1. En la barra lateral, **Customize**.
2. **MCPs**.
3. Buscar **Linear**.
4. **Add to Cursor**.
5. Seguir los pasos de autenticación: se abre el navegador para autorizar con su
   cuenta de Linear.

Verifica que quedó pidiéndole que abra un chat nuevo y vea la lista de
herramientas arriba del panel: deben aparecer las de Linear. Si no conecta, el
error real está en **Cmd + Shift + U** → **MCP Logs**; y la forma documentada de
"reiniciarlo" es quitarlo desde **Customize → MCPs** y volverlo a agregar.

Avísale que la primera vez que el agente use una herramienta de Linear le va a
pedir aprobación, para que el popup no lo asuste.

## Paso 9 — Mostrarle las dos formas de usarlo

No expliques los cuatro modos. Solo estos dos, y con un ejemplo real corrido en
vivo — que lo vea funcionando pesa más que la explicación.

| Modo | Qué hace | Para qué |
|---|---|---|
| **Ask** | Solo lee y responde; **no modifica nada** | Entender cómo funciona algo |
| **Agent** | Lee, escribe archivos, corre comandos y usa Linear | Sacar un reporte, crear un ticket |

Se cambia con **Shift + Tab**, o con **Cmd + .** para abrir el menú de modos.

Haz la demo así:

1. En **Ask**, pregúntale algo real del repo. Una pregunta que funciona bien:
   *"¿cómo se valida el comprobante de domicilio?"*. Deja que él escriba la
   pregunta, no tú.
2. Cámbiate a **Agent** y pídele algo que produzca un archivo, para que vea la
   diferencia.

Cierra la demo con las dos redes de seguridad, que es lo que le quita el miedo:
el botón **Stop** interrumpe al agente a media tarea, y **Restore Checkpoint**
(pasando el cursor sobre un mensaje anterior) revierte todo lo que hizo después
de ese punto.

Menciona también que **Ask no cambia nada por diseño**: es el modo para
explorar sin riesgo, y es donde debería empezar.

## Paso 10 — Cierre

Repite el checklist con lo que quedó verificado:

```
- [ ] Acceso al repo en GitHub
- [ ] Llave SSH funcionando
- [ ] Repo clonado en <ruta>
- [ ] Push deshabilitado
- [ ] Repo abierto en Cursor
- [ ] Actualización diaria activada
- [ ] MCP de Linear conectado
- [ ] Vio Ask y Agent funcionando
```

Y cierra con esta advertencia, tal cual, para que no crea que ya puede consultar
datos:

> Con esto puedes leer el repo, trabajar con el agente y usar Linear desde el
> chat. Todavía **no** tienes conectada la base de datos: eso es un paso aparte.

## Errores comunes

| Error | Causa real | Qué hacer |
|---|---|---|
| `Permission denied (publickey)` | La llave no está registrada en GitHub | Paso 3 |
| `Repository not found` | Falta la invitación al repo | Paso 1, pedir acceso |
| `git: command not found` | Faltan las Command Line Tools | `xcode-select --install` |
| `Host key verification failed` | Primera conexión a GitHub | Responder `yes` al fingerprint |
| El clon se corta a medias | Red | Borrar la carpeta y volver a clonar, no reintentar encima |

## Fuera de alcance

No lo hagas aquí, aunque lo pidan; dilo y ofrece agendarlo aparte:

- Conectar el MCP de Postgres a la réplica. Necesita credenciales que se piden
  por separado y no viven en el repo.
- Instalar Ruby, `bundle install` o correr la aplicación. Un PM **no** necesita
  levantar el backend para analizar.
