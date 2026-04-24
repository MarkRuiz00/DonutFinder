# DonutFinder — Meteor Client Addon

Addon de [Meteor Client](https://meteorclient.com/) (Fabric) con utilidades para encontrar bases en Donut SMP.

## Módulos

### Detección directa (necesita que el bloque sea visible al cliente)

| Módulo | Descripción |
|---|---|
| **NewChunks** | Detecta chunks nuevos vs. viejos. Un chunk "viejo" lejos del spawn = alguien lo cargó antes = posible base. |
| **StashFinder** | Cuenta contenedores por chunk y guarda posibles stashes en `meteor-client/donutfinder/stashes.json`. |
| **BaseESP** | ESP de obsidiana, beacons, ancient debris, shulkers, ender chests, spawners… |
| **SpawnerESP** | Spawners a través de paredes + tracer al más cercano. |
| **PortalFinder** | Portales nether/end en rango. |
| **EntityRadar** | Item frames, minecarts con chest/hopper, item drops. |

### "Bypass" pasivo del anti-xray de DonutSMP

> DonutSMP oculta el contenido de chunks bajo Y=-1 para impedir x-ray. No se puede revelar el bloque desde el cliente (literalmente no llega la información). Estos módulos usan packets que el servidor **sí envía**: sonidos, partículas y entidades, con coordenadas exactas del emisor, aunque el chunk esté vacío para tu cliente.

| Módulo | Qué hace |
|---|---|
| **SoundLeaks** | Escucha `PlaySoundS2CPacket`: chests abriéndose, furnaces, pistones, puertas, xp pickups… y los pinta como cubos con TTL para ver el "mapa de calor" de actividad. |
| **ParticleLeaks** | Intercepta `ParticleS2CPacket`: portales enterrados (PORTAL), chimeneas (SMOKE), redstone activa (DUST), villagers (HAPPY_VILLAGER), enchantment tables… |
| **EntityLeaks** | Agrupa spawns de entidades bajo un Y configurable: xp orbs, villagers, iron golems, mobs hostiles → farms/trading halls/spawners enterrados. |
| **SurfaceAnalyzer** | Inferencia pura: detecta huecos 1x1 profundos, arena suspendida, bloques colocados, antorchas en superficie, etc. No hace magia, solo mira lo visible. |

### Reducción de huella

| Módulo | Qué hace |
|---|---|
| **StealthMode** | **No es un bypass mágico — no existe.** Lo que hace: (1) auto-desactiva módulos ESP/radar cuando detecta staff en tablist por prefijos ("Admin", "Mod", "Staff"…), (2) desactiva todo al recibir mensajes típicos de report ("has been reported", "freeze", "watching you"), (3) clampa cambios bruscos de rotación (yaw/pitch) en packets C→S para evitar snap-aim heurísticos. |
| **AutoLogger** | Desconecta automáticamente ante jugadores en rango o cuando tu vida baja del umbral. Whitelist de amigos. |

## Sobre el anti-xray y los anticheats

### Por qué no se puede "ver" bajo Y=-1 directamente

El anti-xray de DonutSMP es (casi seguro) **server-side**: el servidor filtra los bloques antes de enviarte el packet `ChunkDataS2CPacket` o los reemplaza con bedrock/stone falso. Tu cliente **nunca recibe** la información de esos bloques. Ningún mod del mundo puede reconstruir datos que no llegaron. Cualquier "x-ray" que te prometa ver bajo Y=-1 en Donut es mentira, impossible by design.

### Lo único real son los **leaks** laterales

El servidor, aunque oculta los bloques, necesita enviar:

- **Sonidos** con coordenadas del emisor (chest.open, piston.extend…).
- **Partículas** emitidas por furnaces, redstone, portales, enchantment tables…
- **Spawns y movimiento de entidades** (mobs, xp orbs, villagers, items).
- **Light updates** si el servidor no parchea también la luz.
- **Block updates** puntuales cuando un jugador rompe/coloca un bloque cerca de ti.

Los módulos `SoundLeaks`, `ParticleLeaks` y `EntityLeaks` explotan exactamente eso y son 100% pasivos — no envías nada al servidor, solo lees lo que ya te llega.

### Sobre "pasar desapercibido"

Los anticheats modernos combinan:

1. **Checks server-side de física** (speed, NoFall, fly, reach, blink). Aquí ningún cliente "pasa desapercibido": o tu packet es válido físicamente o no lo es.
2. **Heurísticas estadísticas** de rotación, timing y patrones. Aquí sí hay margen (StealthMode clampa rotaciones).
3. **Staff en vanish + reports**. Aquí hay mucho margen: StealthMode detecta staff en tablist y triggers de chat para apagar módulos antes de ser reportado.
4. **Machine learning de comportamiento** (servidores grandes). Contra esto poco se puede.

**No uses movimiento (fly/speed/step) ni auto-aim en Donut**. Los ESP y radars pasivos son "safe" contra anticheat automático, pero un staff te puede reportar por conducta anómala si te ven caminando al chest exacto sin haberlo visto antes. StealthMode mitiga eso.

## Comandos

- `.donut stashes` — lista stashes detectados.
- `.donut clear` — limpia la lista.
- `.donut help`.

## Cómo compilar

Requiere JDK 21.

```bash
gradlew.bat build          # Windows
./gradlew build            # Linux/macOS
```

`.jar` final en `build/libs/donutfinder-1.0.0.jar`.

## Instalación

1. Fabric Loader para Minecraft 1.21.x.
2. En `mods/`:
   - `fabric-api`.
   - `meteor-client.jar`.
   - `donutfinder-1.0.0.jar`.
3. Abre Meteor (`Right Shift` por defecto) → categoría **Donut**.

## Configuración recomendada para Donut SMP

1. **Activa siempre primero**: `StealthMode` con tus nombres de staff reales, y `AutoLogger` con whitelist de amigos.
2. **Exploración de highways**: `NewChunks` + `ParticleLeaks` + `SoundLeaks`.
3. **Búsqueda de bases confirmadas**: `StashFinder` + `BaseESP` + `SpawnerESP` + `EntityLeaks`.
4. **Ajusta** `max-y` de `EntityLeaks` a 30 o menos si Donut SMP oculta bajo Y=-1 para centrarte solo en anomalías profundas.

## Aviso legal

Usar este tipo de addons viola las reglas de la mayoría de servidores SMP, incluido Donut SMP (reglas de client-side modifications). Puedes perder tu cuenta, rank pagado o ambos. Úsalo bajo tu responsabilidad; el autor no se hace responsable de bans. Se entrega con fines educativos.

## Licencia

MIT.
