# Diseño del Némesis para The Witcher 3

21-10-2026. Reúne en un solo planteamiento, adaptado a Witcher 3:

- las reglas de enRAGE, del [informe](../../../../outputs/enrage-nemesis-witcher3-21-10-2026/INFORME.md);
- el lore, en [LORE-Y-ENEMIGOS.md](LORE-Y-ENEMIGOS.md);
- los mods de referencia y los efectos sobre el mundo, en [MODS-Y-MUNDO.md](MODS-Y-MUNDO.md).

Los datos llevan la cita en esos documentos. Aquí van las decisiones. Lo marcado **[decisión]** es criterio de diseño y se puede cambiar; lo que está por probar está marcado.

## 1. La idea en Witcher 3

En Velen, Novigrado, Skellige o Toussaint hay bandas con cabecillas, desertores, piratas, cazadores de brujas y caballeros caídos. Recuerdan lo que les hizo **el brujo**. Un bandido al que humillaste vuelve con su banda; el cabecilla al que dejaste vivo regresa con una cicatriz y defensas contra tu Igni. Si lo matas, su lugarteniente ocupa su sitio y quizá jure venganza. Y si un némesis te vence, Geralt despierta sin bolsa en el camino, no en una pantalla de carga.

Lo que aporta respecto a lo que ya existe:

- **Frente al mod «Nemesis - Enemy Grudge System» (Nexus 13930)**, que solo convierte en némesis a quien te vence: aquí el rencor nace de lo que tú haces, cada PNJ tiene temperamento y las facciones viven su propia vida, como en enRAGE.
- **Frente a enRAGE:** está pensado para un brujo y para el mundo de 1272.

## 2. Reglas de enRAGE adaptadas

| enRAGE | En Witcher 3 | Motivo |
|---|---|---|
| Sin ver tu cara no hay némesis (máscara) | **Desaparece.** Geralt no puede ocultarse: el pelo blanco y los ojos de gato le delatan. Cuenta todo agravio con testigo | Rasgo canónico del personaje. La regla de testigos se mantiene |
| Temperamentos Hothead, Proud, Cold, Coward, Greedy, Loyal, Drifter | Se conservan los siete con sus multiplicadores. Nombres: Sanguíneo, Orgulloso, Frío, Cobarde, Codicioso, Leal, Vagabundo. El fanatismo (Fuego Eterno) es devoción alta, no un octavo temperamento | Los números de enRAGE ya están estudiados; solo cambia la lectura |
| Agravios del Oeste (robar el caballo, maniatar, atracar) | **Agravios de brujo:** matar a sus compañeros, robarle el botín, humillarle delante de su banda, cobrar un contrato por su cabeza, usar Axii contra él, arrasar su campamento, perdonarle la vida (es humillación para el orgulloso) | [decisión]. Los pesos parten de la tabla de enRAGE (anexo A) y se ajustan jugando |
| Miedo al pistolero famoso | **Miedo al mutante:** el brujo es «el monstruo». Las Señales y la fama («el Carnicero de Blaviken», por verificar) suben el miedo de partida | Lore del brujo |
| Muerte del jugador: el némesis asciende | **Derrota sin recarga (decidido por Nico el 21-10-2026):** Geralt queda inconsciente y **despierta junto al poste de viaje rápido descubierto más cercano**. El némesis **se lleva parte del dinero**, pero **nunca espadas, equipo puesto ni objetos de misión**. El némesis asciende y apunta la victoria | Morir en W3 recarga la partida. El estado inconsciente del juego lo evita (por probar, Fase 0). Detalle técnico en §2.1 |
| Engañar a la muerte (35 % + 5 %/rango, máx. 60 %) | Se conserva para humanos. Con el arquetipo «espectro», un némesis humano que muere puede volver como **aparición** en el lugar donde cayó | Lore de las apariciones vengativas |
| Bandas del Oeste (O'Driscoll…) | **Facciones por región** (§4) | Lore de 1272 |
| Telegramas | **Cartas** que lleva un mensajero o encuentras en un cadáver, y **notas en los tablones** | No hay telégrafo |
| Periódico | **Rumores de taberna** (texto sobre los aldeanos), **carteles de «se busca»** en los tablones y la crónica completa en el panel de Segunda Pantalla | No hay prensa |
| Funerales | Según la cultura: **barco en llamas** en Skellige, entierro en el Continente | Lore |
| Reputación por pueblo | Se conserva, y parte de **desconfianza hacia el brujo**. Los no humanos son perseguidos en Novigrado | Lore |

### 2.1 Derrota: cómo se hace

Todas las API están leídas en los scripts vanilla instalados; nada se ha probado en partida.

1. **No morir.** Durante la pelea con un némesis, Geralt lleva inmortalidad de tipo inconsciente. Al caer entra en el estado `Unconscious` en vez de morir (`player.ws:1086-1099`; prueba `-Derrota` de la Fase 0).
2. **Robo de dinero.** Se toma como modelo la regla vanilla del guardia: un porcentaje según la dificultad, con tope (25 %, 40 %, 65 % u 85 %; máximo 750-2250) (`unconscious.ws:173-188`). Se ajusta con el temperamento del némesis: más el codicioso, menos el orgulloso, que busca humillar y no dinero [decisión]. Solo `RemoveMoney`: no se tocan objetos, así que espadas, equipo puesto y objetos de misión quedan a salvo por construcción.
3. **Despertar junto al poste.**
   - `GetCommonMapManager().GetFastTravelPoints(onlyDiscovered = true, onlyEnabled = true)` da los postes descubiertos (`commonMapManager.ws:908`).
   - `GetEntityMapPins(ruta del mundo)` da la posición exacta de llegada de cada poste (`fastTravelTeleportWayPointPosition`, `commonMapManager.ws:20-29,135`).
   - Se elige el más cercano, igual que hace el juego con el guardia y su punto de reaparición (`unconscious.ws:218-245`), y se teletransporta con fundido a negro mientras Geralt está inconsciente.
   - Si no hay ningún poste descubierto en ese mundo, despierta en el sitio, con el némesis ya ido [decisión].
4. **Después.** Se adelanta el reloj, como en la regla del guardia (`TimeFlow`). El némesis sube de rango y guarda la victoria. Mensaje en pantalla y línea en la crónica del panel.

Por probar en la Fase 1: que el teletransporte durante el estado inconsciente quede limpio, y cómo convive con Undying, la Mutación 11 o la armadura reforzada, que pueden salvar a Geralt antes.

## 3. Quién puede ser némesis

Detalle en [LORE-Y-ENEMIGOS.md §2](LORE-Y-ENEMIGOS.md).

| Clase | Quién | Qué tiene |
|---|---|---|
| **Completo** | Humanos genéricos hostiles: bandidos, desertores temerios y nilfgaardianos, piratas, renegados, esclavistas, matones de Novigrado, cazadores de brujas, caballeros renegados de la Rosa Llameante (HoS), hansas de Toussaint. Scoia'tael, pocos y con motivo | Memoria, rencor, cara a cara en texto, facción, rangos, interrogatorio |
| **Limitado** | Trol de piedra (texto), alghul y garkain (alfas), grifo viudo, leshen con su marcado, lobo alfa, oso, hombre lobo con la luna llena, bruja o alpa en Toussaint, aparición vengativa atada a un lugar | Recuerda y vuelve con cicatrices y defensas; sin facción ni diálogo, salvo el trol |
| **Nunca** | Gólems, elementales, insectoides, ghuls, ahogados, arpías, sirenas (pueden ser **séquito** de un limitado). Cacería Salvaje, vampiros superiores, Moiras, jefes de contrato, doppler, súcubo | Sin mente, únicos de la historia o pacíficos |

**Regla para no romper la historia** [decisión]:

- Solo son candidatos los PNJ que genera el sistema, o enemigos `ENGT_Enemy` que no vengan de plantillas de historia ni de misión.
- Nunca un PNJ `Quest`, `Guard` ni `Commoner`: el juego los deja inconscientes en vez de matarlos (`npc.ws:443-466`, comprobado).
- Nunca en mundos de misión (Isla de la Niebla, La Espiral, Vizima) ni en zonas sensibles: Percha del Cuervo, Cenagal del Jorobado, Montecalvo, centro de Novigrado, Kaer Trolde, Hindarsfjall, Beauclair.
- No hay una API de «zona de misión». Se combinan varias señales: escena, diálogo, interior, asentamiento, combate, guardado bloqueado, pines de misión cerca, jefes y monstruos de contrato. El filtro es imperfecto: riesgo medio.

## 4. Facciones por región

Detalle y plantillas en [LORE-Y-ENEMIGOS.md §3](LORE-Y-ENEMIGOS.md). Tienen voz los gritos de combate (voicesets) que traen las plantillas; no se doblan voces nuevas.

| Región | Facciones del sistema | Rivalidades para guerras (Fase 2) |
|---|---|---|
| Velen | Bandidos con cabecilla, desertores temerios y nilfgaardianos, renegados, esclavistas, piratas del Pontar, Risueños, Scoia'tael, caballeros renegados (HoS) | Bandidos y desertores; desertores temerios y nilfgaardianos; piratas y Risueños |
| Novigrado y Oxenfurt | Matones y bandas genéricas, cazadores de brujas, contrabandistas | Cazadores de brujas y Scoia'tael; bandas entre sí, sin tocar al Gran Cuatro |
| Skellige | Bandidos isleños, piratas de Skellige con capitán, berserkers | Piratas y bandidos, oportunistas |
| Toussaint | Hansas genéricas, matones de Beauclair, bruja o alpa (limitadas) | Hansas aliadas entre sí, contra los caballeros andantes |
| Huerto Blanco | Solo como origen de biografías | — |

## 5. Efectos que se notan en el mundo

APIs y riesgos en [MODS-Y-MUNDO.md §3](MODS-Y-MUNDO.md).

- **Nombre del némesis** en la placa del enemigo y en la barra de jefe, envolviendo los módulos del HUD.
- **Los aldeanos hablan de él:** texto sobre los PNJ cerca de su guarida; sus bandidos gritan su nombre.
- **Brillo rojo con los sentidos de brujo** en su rastro y en su guarida.
- **Pin de la guarida**, que también se emite al panel de Segunda Pantalla, porque ese mod oculta el minimapa.
- **Contrato de brujo en el tablón** sobre un némesis (pseudo-contrato: nota, fact, pin, barra de jefe y pago). Con 6 notas como mucho, compite con RER.
- **Cartas** suyas con texto generado. El juego ya genera texto por código para el Almanaque de Gwent.
- **Botín y trofeo** al matarlo.
- **Ciclo del mundo:** los monstruos limitados son más fuertes de noche o con luna llena; el hombre lobo solo aparece con luna llena.
- **No se puede meditar** cerca de su guarida.
- Más adelante: **precios** cerca de la amenaza y **gente añadida** en asentamientos (refugiados, guardias). Nunca se vacían aldeas vanilla.

## 6. Mejoras propias de Witcher 3

1. **Aprende cómo lo venciste:** detecta la Señal, el aceite, las bombas, la ballesta, las paradas y las esquivas, y gana una inmunidad o reduce ese daño. Es la idea más «de brujo». API verificada; coste moderado.
2. **Contrato de brujo** sobre tu némesis, con pago.
3. **Precio por tu cabeza:** cartel con tu nombre y cazarrecompensas que te buscan.
4. **Lleva lo que te quitó** al despertar tras una derrota.
5. **Usa bombas o pociones**, solo si la plantilla ya sabe lanzarlas (por verificar).

## 7. Convivencia con otros mods

- **RER:** compatible, no dependencia. No toca la muerte del jugador. Turno compartido: no lanzar emboscadas si hay criaturas de RER cerca, y usar otra nota del tablón. Nunca referenciarlo desde el mod principal.
- **Nemesis 13930:** jugarlo como referencia en una partida desechable, **nunca a la vez** que este, porque los dos interceptan la derrota de Geralt.
- **shared-utils (MIT):** sí a sus módulos de anotaciones (oneliners, mappins, noticeboards, dialogChoices, glossary, npcInteraction, damagemodifiers). No a los que sustituyen archivos vanilla (journalquest, custombossbar, customcooldowns, storage).
- **Evitar:** DLL nativas (TW3SE, AMF, W3MCL), overhauls y Deadly Guards, que edita justo la muerte del jugador.
- **Un solo registro guardado** en el jugador: con varios mods guardando muchos valores sueltos se han visto partidas que perdían nivel y equipo. La Fase 0 lo vigila.

## 8. Fases

1. **Fase 0, base técnica.** Persistencia y derrota sin recarga, con la prueba actual.
2. **Fase 1, un némesis.** Un cabecilla de bandidos en Velen (`novigrad_bandit_leader_swordshield`, séquito `novigrad_bandit_sword`/`_ranged`), lejos de Percha del Cuervo, del Cenagal y de Novigrado. Rencor por agravios con temperamento, derrota sin recarga, nombre en el HUD, gritos y texto sobre PNJ, brillo con los sentidos, botín, pin de la guarida, filtros de misión y turno con RER, y «aprende cómo lo venciste» en versión mínima.
3. **Fase 2, facciones.** Facciones de Velen con cabecilla y rangos, ascensos, economía y guerras fuera de cámara. Contrato en el tablón, cartas, ciclo del mundo y propagación de muertes.
4. **Fase 3, encuentros.** Tensión, emboscadas, cara a cara en texto con gritos, interrogatorio con miedo, súplica y huida, y cazarrecompensas. Primer némesis limitado: alghul o lobo alfa.
5. **Fase 4, sociedad.** Reputación por asentamiento, testigos, rumores, funerales por cultura y precios. Se amplía a Novigrado, Skellige y Toussaint.
6. **Fase 5, opcional.** Trofeos y objetos con XML propio, cicatrices visibles y entradas de diario con REDkit, gente añadida en asentamientos.

## 9. Decisiones de Nico

1. ~~Despertar tras la derrota~~: **decidido el 21-10-2026.** Poste de viaje rápido más cercano; se lleva parte del dinero, nunca espadas, equipo puesto ni objetos de misión (§2.1).
2. **Nemesis 13930:** si lo quieres jugar antes como referencia.
3. **Ámbito de la Fase 1:** solo Velen, como se propone, o también otra región.
