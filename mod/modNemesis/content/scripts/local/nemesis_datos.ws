// Némesis para The Witcher 3 — datos guardados en la partida y tablas fijas.
// Todo cuelga de un único registro en el jugador (CNemesisMundo): otro mod de némesis vio partidas
// estropeadas al guardar muchos valores sueltos en Geralt.

class CNemesisRegistro
{
	saved var id : int;
	saved var nombre : string;
	saved var apodo : string;              // clave del apodo (texto en nemesis_textos.ws); en la 0.1/0.2, el texto en español
	saved var temperamento : name;        // Hothead, Proud, Cold, Coward, Greedy, Loyal, Drifter
	saved var plantilla : string;          // ruta del depot de su cuerpo
	saved var familia : name;              // bandido, desertor, nilfgaardiano, pirata, skellige
	saved var nivelBase : int;
	saved var rango : int;                 // 1-5
	saved var odio : int;                  // 0-100
	saved var victorias : int;             // veces que ha vencido a Geralt
	saved var derrotas : int;              // veces que Geralt lo ha tumbado y ha sobrevivido
	saved var cicatrices : array< name >;  // Espada, Igni, Aard, Axii, Yrden, Bomba, Virote
	saved var inmunidades : array< name >; // Burning, Knockdown, Confusion, Slowdown, Stagger
	saved var vivo : bool;
	saved var area : name;
	saved var horaUltimo : int;            // hora de juego del último encuentro
	saved var origen : name;               // Sobrevivio, TeVencio
	saved var botin : int;                 // coronas robadas a Geralt que lleva encima

	// En el idioma del juego (ver nemesis_textos.ws).
	function NombreCompleto() : string
	{
		return nombre + " " + NemesisApodoTexto( apodo );
	}

	function Resumen() : string
	{
		return id + "~" + NombreCompleto() + "~" + NemesisTemperamentoTexto( temperamento ) + "~rango " + rango
			+ "~odio " + odio + "~victorias " + victorias + "~derrotas " + derrotas
			+ "~cicatrices " + cicatrices.Size() + "~botin " + botin + "~vivo " + vivo + "~" + NameToString( area );
	}

	function AnadirCicatriz( causa : name )
	{
		var inmunidad : name;

		cicatrices.PushBack( causa );
		apodo = NemesisApodoPorCicatriz( causa, apodo );
		inmunidad = NemesisInmunidadPorCausa( causa );
		if ( IsNameValid( inmunidad ) && !inmunidades.Contains( inmunidad ) )
		{
			inmunidades.PushBack( inmunidad );
		}
	}
}

class CNemesisMundo
{
	saved var version : int;
	saved var siguienteId : int;
	saved var registros : array< CNemesisRegistro >;
	saved var horaUltimoNacimiento : int;
	saved var cronica : array< string >;
	saved var horaUltimaEmboscada : int;   // pausa global entre emboscadas de distintos némesis

	function NombreLibre( nombreCompleto : string ) : bool
	{
		var i : int;
		for ( i = 0; i < registros.Size(); i += 1 )
		{
			if ( registros[ i ] && registros[ i ].vivo && registros[ i ].NombreCompleto() == nombreCompleto ) { return false; }
		}
		return true;
	}

	function Iniciar()
	{
		version = 1;
		siguienteId = 1;
		horaUltimoNacimiento = -1000;
	}

	function Vivos() : int
	{
		var i, n : int;
		for ( i = 0; i < registros.Size(); i += 1 )
		{
			if ( registros[ i ] && registros[ i ].vivo ) { n += 1; }
		}
		return n;
	}

	function Buscar( id : int ) : CNemesisRegistro
	{
		var i : int;
		for ( i = 0; i < registros.Size(); i += 1 )
		{
			if ( registros[ i ] && registros[ i ].id == id ) { return registros[ i ]; }
		}
		return NULL;
	}

	function Anotar( texto : string )
	{
		cronica.PushBack( texto );
		if ( cronica.Size() > 30 ) { cronica.Erase( 0 ); }
		LogChannel( 'NEM', "NEM|CRONICA|" + texto );
	}
}

// ---- Tablas ----

function NemesisHoraJuego() : int
{
	var t : GameTime;
	t = theGame.GetGameTime();
	return GameTimeDays( t ) * 24 + GameTimeHours( t );
}

function NemesisRuta( nombre : string ) : string
{
	var base : string;
	// Una «\» justo antes de la comilla la escaparía: se recorta la última letra de esta base.
	base = "living_world\enemy_templates\x";
	return StrLeft( base, StrLen( base ) - 1 ) + nombre + ".w2ent";
}

// Solo para los registros NEM| y la crónica (no lo ve el jugador): por eso no está traducido.
function NemesisTemperamentoTexto( t : name ) : string
{
	switch ( t )
	{
		case 'Hothead': return "Sanguíneo";
		case 'Proud':   return "Orgulloso";
		case 'Cold':    return "Frío";
		case 'Coward':  return "Cobarde";
		case 'Greedy':  return "Codicioso";
		case 'Loyal':   return "Leal";
		default:        return "Vagabundo";
	}
}

function NemesisTemperamentoAzar() : name
{
	var r : int;
	r = RandRange( 100 );
	if ( r < 18 ) { return 'Hothead'; }
	if ( r < 34 ) { return 'Proud'; }
	if ( r < 48 ) { return 'Cold'; }
	if ( r < 60 ) { return 'Coward'; }
	if ( r < 76 ) { return 'Greedy'; }
	if ( r < 88 ) { return 'Loyal'; }
	return 'Drifter';
}

// Horas de juego mínimas entre un encuentro y el siguiente.
function NemesisEsperaHoras( t : name ) : int
{
	switch ( t )
	{
		case 'Hothead': return 4;
		case 'Proud':   return 8;
		case 'Cold':    return 12;
		case 'Coward':  return 20;
		case 'Greedy':  return 8;
		case 'Loyal':   return 10;
		default:        return 16;
	}
}

// Parte del dinero que se lleva al vencer, sobre la regla vanilla del guardia.
function NemesisFactorRobo( t : name ) : float
{
	switch ( t )
	{
		case 'Greedy': return 1.5;
		case 'Proud':  return 0.5;
		case 'Coward': return 0.8;
		default:       return 1.0;
	}
}

function NemesisFraseEmboscada( r : CNemesisRegistro ) : string
{
	if ( r.victorias > 0 ) { return NemesisTexto( 'FraseRevancha' ); }
	if ( r.cicatrices.Size() > 1 ) { return NemesisTexto( 'FraseCicatrices' ); }
	switch ( r.temperamento )
	{
		case 'Hothead': return NemesisTexto( 'FraseHothead' );
		case 'Proud':   return NemesisTexto( 'FraseProud' );
		case 'Cold':    return NemesisTexto( 'FraseCold' );
		case 'Coward':  return NemesisTexto( 'FraseCoward' );
		case 'Greedy':  return NemesisTexto( 'FraseGreedy' );
		case 'Loyal':   return NemesisTexto( 'FraseLoyal' );
		default:        return NemesisTexto( 'FraseDrifter' );
	}
}

function NemesisNombreAzar( familia : name ) : string
{
	var n : array< string >;
	if ( familia == 'skellige' )
	{
		n.PushBack( "Hjort" ); n.PushBack( "Gunnar" ); n.PushBack( "Ulfgar" ); n.PushBack( "Brand" );
		n.PushBack( "Torvald" ); n.PushBack( "Eyvind" ); n.PushBack( "Skarde" ); n.PushBack( "Ketil" );
	}
	else if ( familia == 'hansa' )
	{
		n.PushBack( "Gaspard" ); n.PushBack( "Renaud" ); n.PushBack( "Bertrand" ); n.PushBack( "Lucien" );
		n.PushBack( "Armand" ); n.PushBack( "Thibault" ); n.PushBack( "Fabrice" ); n.PushBack( "Odilon" );
	}
	else if ( familia == 'nilfgaardiano' )
	{
		n.PushBack( "Aelred" ); n.PushBack( "Dorian" ); n.PushBack( "Fergus" ); n.PushBack( "Lavrence" );
		n.PushBack( "Mattheus" ); n.PushBack( "Riordain" ); n.PushBack( "Tibor" ); n.PushBack( "Vreemde" );
	}
	else
	{
		n.PushBack( "Jurek" ); n.PushBack( "Bram" ); n.PushBack( "Hensel" ); n.PushBack( "Olek" );
		n.PushBack( "Radek" ); n.PushBack( "Gerd" ); n.PushBack( "Kuno" ); n.PushBack( "Lubo" );
		n.PushBack( "Marek" ); n.PushBack( "Ostap" ); n.PushBack( "Stasko" ); n.PushBack( "Zbylut" );
		n.PushBack( "Wit" ); n.PushBack( "Bodek" ); n.PushBack( "Iwo" ); n.PushBack( "Tomko" );
	}
	return n[ RandRange( n.Size() ) ];
}

// Devuelve la CLAVE del apodo; el texto en cada idioma está en NemesisApodoTexto (nemesis_textos.ws).
function NemesisApodoAzar() : string
{
	var a : array< string >;
	a.PushBack( "Tuerto" ); a.PushBack( "Mediaoreja" ); a.PushBack( "Sabueso" ); a.PushBack( "Diente" );
	a.PushBack( "Cuervo" ); a.PushBack( "Barbaroja" ); a.PushBack( "Manco" ); a.PushBack( "Matalobos" );
	a.PushBack( "Ahorcado" ); a.PushBack( "Sietevidas" ); a.PushBack( "Zorro" ); a.PushBack( "Cuchillo" );
	a.PushBack( "Callado" ); a.PushBack( "MalaHierba" ); a.PushBack( "Rata" ); a.PushBack( "Piedra" );
	return a[ RandRange( a.Size() ) ];
}

// La cicatriz de una Señal, una bomba o un virote le cambia el apodo (clave, como arriba); la de
// espada lo deja como estaba.
function NemesisApodoPorCicatriz( causa : name, actual : string ) : string
{
	switch ( causa )
	{
		case 'Igni':   return "Chamuscado";
		case 'Aard':   return "Quebrado";
		case 'Axii':   return "Embrujado";
		case 'Yrden':  return "Atado";
		case 'Bomba':  return "Tiznado";
		case 'Virote': return "Virote";
		default:       return actual;
	}
}

// Aprende de cómo lo tumbaste.
function NemesisInmunidadPorCausa( causa : name ) : name
{
	switch ( causa )
	{
		case 'Igni':  return 'Burning';
		case 'Aard':  return 'Knockdown';
		case 'Axii':  return 'Confusion';
		case 'Yrden': return 'Slowdown';
		case 'Bomba': return 'Stagger';
		default:      return '';
	}
}

// Cada inmunidad aprendida cubre todos los efectos de esa Señal o ese golpe.
function NemesisEfectos( inmunidad : name ) : array< EEffectType >
{
	var e : array< EEffectType >;
	switch ( inmunidad )
	{
		case 'Burning':   e.PushBack( EET_Burning ); break;
		case 'Knockdown': e.PushBack( EET_Knockdown ); e.PushBack( EET_HeavyKnockdown ); break;
		case 'Confusion': e.PushBack( EET_Confusion ); e.PushBack( EET_AxiiGuardMe ); break;
		case 'Slowdown':  e.PushBack( EET_Slowdown ); break;
		default:          e.PushBack( EET_Stagger ); e.PushBack( EET_LongStagger ); break;
	}
	return e;
}

// Plantillas de historia o de misión: nunca pueden ser némesis.
function NemesisPlantillaDeMision( ruta : string ) : bool
{
	var r : string;
	r = StrLower( ruta );
	if ( StrFindFirst( r, "quest" ) >= 0 || StrFindFirst( r, "main_npc" ) >= 0 || StrFindFirst( r, "secondary_npc" ) >= 0 ) { return true; }
	// Los tres jefes de hansa de Toussaint tienen plantilla propia: son personajes, no genéricos.
	return StrFindFirst( r, "antoine_straggen" ) >= 0 || StrFindFirst( r, "cystus" ) >= 0 || StrFindFirst( r, "raider_half_elf" ) >= 0;
}

function NemesisVersion() : string
{
	return "0.3";
}

// Plantillas de las expansiones (comprobadas en REDkit r4data\dlc\…\living_world\enemy_templates).
// Sin la expansión instalada no cargan y el motor cae a la familia bandido.
function NemesisBarra() : string
{
	var b : string;
	// Una «\» justo antes de la comilla la escaparía; se toma la primera letra de esta cadena.
	b = "\x";
	return StrLeft( b, 1 );
}

function NemesisRutaDlc( dlc : string, nombre : string ) : string
{
	return "dlc" + NemesisBarra() + dlc + NemesisBarra() + "data" + NemesisBarra() + NemesisRuta( nombre );
}

function NemesisFamiliaDeRuta( ruta : string, area : name ) : name
{
	var r : string;
	r = StrLower( ruta );
	if ( StrFindFirst( r, "flaming_rose" ) >= 0 ) { return 'rosa'; }
	if ( StrFindFirst( r, "raider" ) >= 0 || StrFindFirst( r, "thug" ) >= 0 ) { return 'hansa'; }
	if ( area == 'AN_Bob' || area == 'AN_Dlc_Bob' ) { return 'hansa'; }
	if ( StrFindFirst( r, "nilfgaard" ) >= 0 ) { return 'nilfgaardiano'; }
	if ( StrFindFirst( r, "skellige" ) >= 0 ) { return 'skellige'; }
	if ( StrFindFirst( r, "pirate" ) >= 0 ) { return 'pirata'; }
	if ( StrFindFirst( r, "deserter" ) >= 0 ) { return 'desertor'; }
	if ( StrFindFirst( r, "bandit" ) >= 0 ) { return 'bandido'; }
	if ( area == 'AN_Skellige_ArdSkellig' ) { return 'skellige'; }
	return 'bandido';
}

// Plantillas comprobadas en REDkit r4data\living_world\enemy_templates.
function NemesisPlantillaLider( familia : name ) : string
{
	switch ( familia )
	{
		case 'hansa':         return NemesisRutaDlc( "bob", "raider_leader" );
		case 'rosa':          return NemesisRutaDlc( "ep1", "flaming_rose_guard_sword" );
		case 'desertor':      return NemesisRuta( "nml_deserters_axe_normal" );
		case 'nilfgaardiano': return NemesisRuta( "nilfgaardian_deserter_sword_hard" );
		case 'pirata':        return NemesisRuta( "nml_pirates_boss" );
		case 'skellige':      return NemesisRuta( "skellige_pirate_leader_swordshield" );
		default:              return NemesisRuta( "novigrad_bandit_leader_swordshield" );
	}
}

function NemesisPlantillaSequito( familia : name ) : string
{
	var p : array< string >;
	switch ( familia )
	{
		case 'hansa':
			p.PushBack( "raider_lvl1_sword_mid" ); p.PushBack( "raider_lvl1_axe_mid" ); p.PushBack( "raider_lvl2_shield_mid" ); p.PushBack( "raider_ranged_mid" );
			return NemesisRutaDlc( "bob", p[ RandRange( p.Size() ) ] );
		case 'rosa':
			p.PushBack( "flaming_rose_guard_halberd" ); p.PushBack( "flaming_rose_guard_mace" ); p.PushBack( "flaming_rose_guard_xbow" ); p.PushBack( "flaming_rose_guard_shield" );
			return NemesisRutaDlc( "ep1", p[ RandRange( p.Size() ) ] );
		case 'desertor':
			p.PushBack( "nml_deserters_sword_easy" ); p.PushBack( "nml_deserters_bow" ); p.PushBack( "nml_deserters_axe_normal" );
			break;
		case 'nilfgaardiano':
			p.PushBack( "nilfgaardian_deserter_shield" ); p.PushBack( "nilfgaardian_deserter_bow" ); p.PushBack( "nilfgaardian_deserter_sword_hard" );
			break;
		case 'pirata':
			p.PushBack( "nml_pirates_sword_normal" ); p.PushBack( "nml_pirates_axe_normal" ); p.PushBack( "nml_pirates_crossbow" );
			break;
		case 'skellige':
			p.PushBack( "skellige_bandit_sword_normal" ); p.PushBack( "skellige_bandit_axe1h_normal" ); p.PushBack( "skellige_bandit_bow" );
			break;
		default:
			p.PushBack( "novigrad_bandit_sword" ); p.PushBack( "novigrad_bandit_1haxe" ); p.PushBack( "novigrad_bandit_ranged" );
			p.PushBack( "novigrad_bandit_spear" ); p.PushBack( "novigrad_bandit_shield_1hclub" );
			break;
	}
	return NemesisRuta( p[ RandRange( p.Size() ) ] );
}

// Zonas donde el sistema no actúa: mundos de misión y el prólogo.
function NemesisAreaPermitida( area : name ) : bool
{
	switch ( area )
	{
		case 'AN_Island_of_Myst':
		case 'AN_Spiral':
		case 'AN_Wyzima':
		case 'AN_Kaer_Morhen':
		case 'AN_Prologue_Village':
		case 'AN_Prologue_Village_Winter':
			return false;
		default:
			return true;
	}
}
