// Némesis para The Witcher 3 — todos los textos que ve el jugador, en español y en inglés.
// Español si el idioma de TEXTO del juego es español (de España «ES» o de Latinoamérica «ESMX»);
// inglés con cualquier otro idioma. El idioma se consulta en cada aviso, así que cambiarlo en el
// menú se nota en el siguiente sin recargar.
//
// Los registros (NEM|…) y la crónica guardada siguen en español: son para depurar, no para el jugador.

function NemesisIdiomaEspanol() : bool
{
	var audio, texto : string;

	// Misma llamada que usan los menús vanilla (chosenLanguageCondition.ws): el segundo valor es el
	// idioma de texto y subtítulos, con códigos como "EN", "ES", "ESMX", "PL"…
	theGame.GetGameLanguageName( audio, texto );
	texto = StrUpper( texto );
	return texto == "ES" || texto == "ESMX";
}

function NemesisEsEn( es : string, en : string ) : string
{
	if ( NemesisIdiomaEspanol() ) { return es; }
	return en;
}

// Sustituye {1} y {2} en el texto de la clave.
function NemesisTextoCon( clave : name, optional a : string, optional b : string ) : string
{
	var t : string;
	t = NemesisTexto( clave );
	t = StrReplaceAll( t, "{1}", a );
	t = StrReplaceAll( t, "{2}", b );
	return t;
}

// ---- Avisos y nombre flotante ----

function NemesisTexto( clave : name ) : string
{
	switch ( clave )
	{
		case 'Nace':
			return NemesisEsEn( "Entre los caídos, uno aún respira. Te ha visto la cara y no lo olvidará: {1}.",
				"Among the fallen, one is still breathing. He has seen your face and he won't forget it: {1}." );
		case 'Emboscada':
			return "{1}: {2}";
		case 'Huida':
			return NemesisEsEn( "{1} te pierde la pista. Por ahora.",
				"{1} has lost your trail. For now." );
		case 'DespiertaPoste':
			return NemesisEsEn( "Despiertas magullado junto a un poste del camino.",
				"You come to, battered, beside a roadside signpost." );
		case 'DespiertaSitio':
			return NemesisEsEn( "Despiertas magullado donde caíste.",
				"You come to, battered, where you fell." );
		case 'Robo':
			return NemesisEsEn( "{1} se ha llevado {2} coronas de tu bolsa.",
				"{1} made off with {2} crowns from your purse." );
		case 'SinRobo':
			return NemesisEsEn( "{1} no encontró nada que robarte, pero su fama crece.",
				"{1} found nothing worth taking, but his name is spreading." );
		case 'Sobrevive':
			return NemesisEsEn( "{1} cae… y cuando vuelves a mirar, su cuerpo ya no está. Volverá.",
				"{1} falls… but when you look again, his body is gone. He'll be back." );
		case 'MuereBotin':
			return NemesisEsEn( "{1} ha muerto. Lleva encima las {2} coronas que te robó.",
				"{1} is dead. He's carrying the {2} crowns he stole from you." );
		case 'Muere':
			return NemesisEsEn( "{1} ha muerto. Su banda se dispersa.",
				"{1} is dead. His gang scatters." );
		case 'MuereOtros':
			return NemesisEsEn( "{1} ha muerto, pero no por tu mano.",
				"{1} is dead, but not by your hand." );
		case 'NombreFlotante':
			return NemesisEsEn( "{1} · rango {2}", "{1} · rank {2}" );

		// Frase con la que se presenta en la emboscada.
		case 'FraseRevancha':
			return NemesisEsEn( "«¿Otra vez tú, brujo? La última vez te dejé durmiendo en el barro.»",
				"“You again, witcher? Last time I left you sleeping in the mud.”" );
		case 'FraseCicatrices':
			return NemesisEsEn( "«Cada cicatriz lleva tu nombre, mutante. Hoy te las cobro todas.»",
				"“Every scar has your name on it, mutant. Today I collect on all of them.”" );
		case 'FraseHothead':
			return NemesisEsEn( "«¡Brujo! ¡Te he buscado por todo el maldito camino!»",
				"“Witcher! I've hunted you up and down this cursed road!”" );
		case 'FraseProud':
			return NemesisEsEn( "«Me dejaste vivo. Ese fue tu error, brujo.»",
				"“You left me alive. That was your mistake, witcher.”" );
		case 'FraseCold':
			return NemesisEsEn( "«Sabía que pasarías por aquí. Siempre pasáis.»",
				"“Knew you'd come this way. Your kind always does.”" );
		case 'FraseCoward':
			return NemesisEsEn( "«Ahora somos más… ¡a por él, rápido!»",
				"“There's more of us now… Get him, quick!”" );
		case 'FraseGreedy':
			return NemesisEsEn( "«Por tu cabeza pagan bien. Por tu bolsa, aún mejor.»",
				"“Your head's worth good coin. Your purse, even more.”" );
		case 'FraseLoyal':
			return NemesisEsEn( "«Esto es por los muchachos que dejaste en la cuneta.»",
				"“This is for the lads you left in the ditch.”" );
		default:   // 'FraseDrifter' y cualquier otra
			return NemesisEsEn( "«Mira a quién me trae el camino…»",
				"“Well, well. Look who the road brought me…”" );
	}
}

// ---- Apodos ----
// En la partida se guarda la CLAVE del apodo (p. ej. "Tuerto") y el texto se elige al mostrarlo.
// Las partidas de la 0.1 y la 0.2 guardaron el apodo ya escrito en español («el Tuerto»): también
// se reconoce, así que esos némesis cambian de idioma igual que los nuevos.

function NemesisApodoSi( apodo : string, clave : string, es : string, en : string, out texto : string ) : bool
{
	if ( apodo != clave && apodo != es ) { return false; }
	texto = NemesisEsEn( es, en );
	return true;
}

function NemesisApodoTexto( apodo : string ) : string
{
	var t : string;

	// Al azar al nacer (lista de claves en NemesisApodoAzar).
	if ( NemesisApodoSi( apodo, "Tuerto",     "el Tuerto",        "the One-Eyed",    t ) ) { return t; }
	if ( NemesisApodoSi( apodo, "Mediaoreja", "Mediaoreja",       "Half-Ear",        t ) ) { return t; }
	if ( NemesisApodoSi( apodo, "Sabueso",    "el Sabueso",       "the Hound",       t ) ) { return t; }
	if ( NemesisApodoSi( apodo, "Diente",     "Diente de Hierro", "Irontooth",       t ) ) { return t; }
	if ( NemesisApodoSi( apodo, "Cuervo",     "el Cuervo",        "the Crow",        t ) ) { return t; }
	if ( NemesisApodoSi( apodo, "Barbaroja",  "Barbaroja",        "Redbeard",        t ) ) { return t; }
	if ( NemesisApodoSi( apodo, "Manco",      "el Manco",         "One-Hand",        t ) ) { return t; }
	if ( NemesisApodoSi( apodo, "Matalobos",  "Matalobos",        "Wolfslayer",      t ) ) { return t; }
	if ( NemesisApodoSi( apodo, "Ahorcado",   "el Ahorcado",      "the Hanged Man",  t ) ) { return t; }
	if ( NemesisApodoSi( apodo, "Sietevidas", "Sietevidas",       "Ninelives",       t ) ) { return t; }
	if ( NemesisApodoSi( apodo, "Zorro",      "el Zorro",         "the Fox",         t ) ) { return t; }
	if ( NemesisApodoSi( apodo, "Cuchillo",   "Cuchillo Largo",   "Longknife",       t ) ) { return t; }
	if ( NemesisApodoSi( apodo, "Callado",    "el Callado",       "the Silent",      t ) ) { return t; }
	if ( NemesisApodoSi( apodo, "MalaHierba", "Mala Hierba",      "Bad Seed",        t ) ) { return t; }
	if ( NemesisApodoSi( apodo, "Rata",       "el Rata",          "the Rat",         t ) ) { return t; }
	if ( NemesisApodoSi( apodo, "Piedra",     "Piedra",           "Stone",           t ) ) { return t; }
	// Según lo que lo tumbó (NemesisApodoPorCicatriz).
	if ( NemesisApodoSi( apodo, "Chamuscado", "el Chamuscado",    "the Scorched",    t ) ) { return t; }
	if ( NemesisApodoSi( apodo, "Quebrado",   "el Quebrado",      "the Broken",      t ) ) { return t; }
	if ( NemesisApodoSi( apodo, "Embrujado",  "el Embrujado",     "the Hexed",       t ) ) { return t; }
	if ( NemesisApodoSi( apodo, "Atado",      "el Atado",         "the Bound",       t ) ) { return t; }
	if ( NemesisApodoSi( apodo, "Tiznado",    "el Tiznado",       "Sootface",        t ) ) { return t; }
	if ( NemesisApodoSi( apodo, "Virote",     "Virote",           "Bolt",            t ) ) { return t; }
	return apodo;
}
