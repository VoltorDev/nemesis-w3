// Némesis para The Witcher 3 — lógica de juego. Solo vive mientras dura la carga (no se guarda):
// lo que importa conservar está en CNemesisMundo.
//
// Ciclo:
//  1. Nacimiento: Geralt mata a un humano hostil genérico; con cierta probabilidad «sobrevive»
//     con una cicatriz y se convierte en némesis.
//  2. Emboscada: pasadas unas horas de juego (según temperamento), vuelve con su banda en la
//     misma región, con su nombre sobre la cabeza e inmune a lo que lo tumbó.
//  3. Derrota de Geralt: no muere; fundido a negro, el némesis le roba parte del dinero, sube de
//     rango y Geralt despierta junto al poste de viaje rápido descubierto más cercano.
//  4. Muerte del némesis: puede volver a engañar a la muerte (35 % + 5 % por rango, máx. 60 %).

// Canal propio de la inmortalidad de Geralt durante un encuentro. La inmortalidad se GUARDA en la
// partida (actor.ws, saved var immortalityFlags) y AIC_Combat lo pisan las animaciones
// sincronizadas vanilla; el de la pelea a puñetazos no coincide nunca con una emboscada.
function NemesisCanal() : EActorImmortalityChannel
{
	return AIC_Fistfight;
}

class CNemesisMotor
{
	var mundo : CNemesisMundo;

	// Encuentro en curso.
	var encuentroId : int;
	var lider : CNewNPC;
	var liderCaido : bool;
	var sequito : array< CNewNPC >;
	var posEncuentro : Vector;
	var segundosLejos : float;
	var segundosNombre : float;
	var segundosEncuentro : float;
	var geraltDerrotado : bool;
	var segundosDerrota : float;     // >0: fundido a negro en curso antes de llevarlo al poste

	var acumulado : float;
	var acumuladoEmboscada : float;

	// Para pruebas: fuerzan el siguiente nacimiento o una emboscada inmediata.
	var forzarNacimiento : bool;
	var forzarEmboscadaId : int;
	var forzarSupervivencia : int;   // 0 al azar, 1 sobrevive, 2 muere
	var ignorarFiltros : bool;       // solo pruebas: actúa en cualquier zona

	var segundosDesdeCarga : float;
	var limpiado : bool;

	function Iniciar( m : CNemesisMundo )
	{
		mundo = m;
		LogChannel( 'NEM', "NEM|CARGA|v" + NemesisVersion() + "|" + mundo.registros.Size() + " registros, " + mundo.Vivos() + " vivos" );
		Volcar();
	}

	// Si se guardó en mitad de un encuentro o de la derrota, la partida trae a Geralt inmortal o
	// bloqueado. Se limpia a los 3 s de juego y solo si lleva nuestra marca: hacerlo en el primer
	// fotograma tras cargar cerraba el juego (0xc0000005, tres de tres en el tutorial de Kaer Morhen).
	function LimpiarRestosDeCarga()
	{
		var canales : array< EActorImmortalityChannel >;

		limpiado = true;
		canales = thePlayer.GetImmortalityModeChannels( AIM_Immortal );
		if ( canales.Contains( NemesisCanal() ) )
		{
			thePlayer.SetImmortalityMode( AIM_None, NemesisCanal() );
			LogChannel( 'NEM', "NEM|LIMPIEZA|inmortalidad de un encuentro guardado, retirada" );
		}
		if ( thePlayer.IsActionBlockedBy( EIAB_Movement, 'NemesisDerrota' ) )
		{
			thePlayer.BlockAllActions( 'NemesisDerrota', false );
			LogChannel( 'NEM', "NEM|LIMPIEZA|bloqueo de una derrota guardada, retirado" );
		}
	}

	function Volcar()
	{
		var i : int;
		for ( i = 0; i < mundo.registros.Size(); i += 1 )
		{
			if ( mundo.registros[ i ] )
			{
				LogChannel( 'NEM', "NEM|ESTADO|" + mundo.registros[ i ].Resumen() );
			}
		}
	}

	// Los textos salen de nemesis_textos.ws, ya en el idioma del juego.
	function Avisar( texto : string )
	{
		theGame.GetGuiManager().ShowNotification( texto, 6.0, true );
	}

	// ---- Condiciones ----

	function EnEscena() : bool
	{
		return theGame.IsDialogOrCutscenePlaying() || thePlayer.IsInNonGameplayCutscene();
	}

	// Para que aparezca una emboscada: campo abierto, sin misión en curso que bloquee el guardado.
	// Mismas condiciones de aborto que Random Encounters Reworked, más su turno compartido.
	function PuedeEmboscar() : bool
	{
		var p : CR4Player;
		p = thePlayer;
		if ( !p || EnEscena() ) { return false; }
		if ( theGame.IsFading() || theGame.IsBlackscreen() ) { return false; }
		if ( ignorarFiltros ) { return true; }
		if ( theGame.AreSavesLocked() ) { return false; }
		if ( p.IsInInterior() || p.IsInSettlement() ) { return false; }
		if ( p.IsSwimming() || p.IsUsingVehicle() || p.IsFistFightMinigameEnabled() ) { return false; }
		if ( HayEncuentroDeRER() ) { return false; }
		return NemesisAreaPermitida( theGame.GetCommonMapManager().GetCurrentArea() );
	}

	// Turno compartido con Random Encounters Reworked: si tiene criaturas a menos de 150 m, se
	// aplaza la emboscada. Se usa su etiqueta (no su código), así compila con o sin RER instalado.
	function HayEncuentroDeRER() : bool
	{
		var ents : array< CEntity >;
		var i : int;
		var aqui : Vector;

		theGame.GetEntitiesByTag( 'RandomEncountersReworked_Entity', ents );
		aqui = thePlayer.GetWorldPosition();
		for ( i = 0; i < ents.Size(); i += 1 )
		{
			if ( ents[ i ] && VecDistance( aqui, ents[ i ].GetWorldPosition() ) < 150.0 ) { return true; }
		}
		return false;
	}

	// Criaturas de contratos y recompensas de RER: tienen su propia historia, no pueden ser némesis.
	function EsDeContratoRER( npc : CNewNPC ) : bool
	{
		return npc.HasTag( 'RandomEncountersReworked_ContractCreature' ) || npc.HasTag( 'RandomEncountersReworked_BountyCreature' )
			|| npc.HasTag( 'RER_BountyEntity' );
	}

	// Para que nazca: basta con estar en una zona permitida y fuera de escenas; la pelea puede ser
	// en un pueblo (la emboscada ya será fuera).
	function PuedeNacer() : bool
	{
		if ( EnEscena() ) { return false; }
		if ( ignorarFiltros ) { return true; }
		return NemesisAreaPermitida( theGame.GetCommonMapManager().GetCurrentArea() );
	}

	// ---- Tick ----

	function Tick( dt : float )
	{
		// La derrota se vigila en cada frame: Geralt es inmortal durante el encuentro y no debe
		// quedarse a 1 punto de vida más de lo necesario.
		if ( encuentroId > 0 )
		{
			VigilarDerrota( dt );
		}
		acumulado += dt;
		if ( acumulado < 1.0 ) { return; }
		dt = acumulado;
		acumulado = 0;

		if ( !limpiado )
		{
			segundosDesdeCarga += dt;
			if ( segundosDesdeCarga >= 3.0 && !EnEscena() ) { LimpiarRestosDeCarga(); }
			return;
		}

		if ( encuentroId > 0 )
		{
			ActualizarEncuentro( dt );
			return;
		}
		acumuladoEmboscada += dt;
		if ( forzarEmboscadaId > 0 || acumuladoEmboscada >= 10.0 )
		{
			acumuladoEmboscada = 0;
			IntentarEmboscada();
		}
	}

	// ---- 1. Nacimiento ----

	function CausaDe( action : W3DamageAction ) : name
	{
		if ( !action ) { return 'Espada'; }
		if ( action.IsActionWitcherSign() )
		{
			switch ( action.GetSignType() )
			{
				case ST_Igni:  return 'Igni';
				case ST_Aard:  return 'Aard';
				case ST_Axii:  return 'Axii';
				case ST_Yrden: return 'Yrden';
				default:       return 'Espada';
			}
		}
		if ( (W3Petard)action.causer ) { return 'Bomba'; }
		if ( action.IsActionRanged() ) { return 'Virote'; }
		return 'Espada';
	}

	function RutaPlantillaDe( npc : CNewNPC ) : string
	{
		var r : string;
		var i : int;
		// El nombre legible del motor trae la ruta de la plantilla (comprobado en el juego).
		r = npc.GetReadableName();
		i = StrFindFirst( StrLower( r ), ".w2ent" );
		if ( i < 0 ) { return ""; }
		r = StrLeft( r, i + 6 );
		i = StrFindLast( r, " " );
		if ( i >= 0 ) { r = StrRight( r, StrLen( r ) - i - 1 ); }
		i = StrFindLast( r, ":" );
		if ( i >= 0 ) { r = StrRight( r, StrLen( r ) - i - 1 ); }
		return r;
	}

	// Solo comprobaciones baratas y seguras: el juego también «mata» PNJ de escena al cargar, y
	// leer el nombre interno de uno de ellos en ese momento se asoció a cierres del juego. El
	// nombre (ruta de la plantilla) se lee después, solo si esto pasa.
	function EsCandidato( npc : CNewNPC, action : W3DamageAction ) : bool
	{
		var cat : EMonsterCategory;
		var sonido : CName;
		var tele, apuntable, punos : bool;

		if ( !npc || !action || action.attacker != thePlayer ) { return false; }
		// Civiles, guardias y PNJ de misión: el juego ya los trata aparte (npc.ws:443-466).
		if ( npc.GetNPCType() != ENGT_Enemy ) { return false; }
		if ( npc.HasTag( 'NemesisSequito' ) || npc.HasTag( 'NemesisLider' ) || EsDeContratoRER( npc ) ) { return false; }
		theGame.GetMonsterParamsForActor( npc, cat, sonido, tele, apuntable, punos );
		return cat == MC_Human;
	}

	function MuerteNPC( npc : CNewNPC, action : W3DamageAction )
	{
		var r : CNemesisRegistro;
		var ruta : string;
		var intento : int;

		if ( encuentroId > 0 && npc == lider && !liderCaido )
		{
			MuerteLider( action );
			return;
		}
		if ( !limpiado ) { return; }   // nada de nacimientos en los primeros segundos tras cargar
		if ( !EsCandidato( npc, action ) ) { return; }
		if ( !PuedeNacer() || mundo.Vivos() >= 5 ) { return; }
		ruta = RutaPlantillaDe( npc );
		if ( NemesisPlantillaDeMision( ruta ) ) { return; }
		if ( !forzarNacimiento )
		{
			if ( NemesisHoraJuego() - mundo.horaUltimoNacimiento < 12 ) { return; }
			if ( RandRange( 100 ) >= ProbNacimiento( ruta ) ) { return; }
		}
		forzarNacimiento = false;

		r = new CNemesisRegistro in mundo;
		r.id = mundo.siguienteId;
		mundo.siguienteId += 1;
		r.area = theGame.GetCommonMapManager().GetCurrentArea();
		r.plantilla = ruta;
		r.familia = NemesisFamiliaDeRuta( r.plantilla, r.area );
		if ( r.plantilla == "" ) { r.plantilla = NemesisPlantillaLider( r.familia ); }
		r.temperamento = NemesisTemperamentoAzar();
		// Sin dos némesis vivos con el mismo nombre completo.
		for ( intento = 0; intento < 10; intento += 1 )
		{
			r.nombre = NemesisNombreAzar( r.familia );
			r.apodo = NemesisApodoAzar();
			if ( mundo.NombreLibre( r.NombreCompleto() ) ) { break; }
		}
		r.nivelBase = Max( npc.GetLevel(), 1 );
		r.rango = 1;
		if ( StrFindFirst( StrLower( r.plantilla ), "leader" ) >= 0 || StrFindFirst( StrLower( r.plantilla ), "boss" ) >= 0 ) { r.rango = 2; }
		r.odio = 50;
		r.vivo = true;
		r.origen = 'Sobrevivio';
		r.horaUltimo = NemesisHoraJuego();
		r.AnadirCicatriz( CausaDe( action ) );
		mundo.registros.PushBack( r );
		mundo.horaUltimoNacimiento = r.horaUltimo;

		mundo.Anotar( r.NombreCompleto() + " sobrevivió a Geralt (" + NemesisTemperamentoTexto( r.temperamento ) + ", " + NameToString( r.familia ) + ")" );
		LogChannel( 'NEM', "NEM|NACE|" + r.Resumen() + "|plantilla " + r.plantilla );
		Avisar( NemesisTextoCon( 'Nace', r.NombreCompleto() ) );
	}

	function ProbNacimiento( ruta : string ) : int
	{
		ruta = StrLower( ruta );
		if ( StrFindFirst( ruta, "leader" ) >= 0 || StrFindFirst( ruta, "boss" ) >= 0 ) { return 30; }
		return 10;
	}

	// ---- 2. Emboscada ----

	function IntentarEmboscada()
	{
		var i : int;
		var r : CNemesisRegistro;
		var area : name;
		var hora : int;
		var candidatos : array< CNemesisRegistro >;

		if ( forzarEmboscadaId > 0 ) { LogChannel( 'NEM', "NEM|TRAZA|emboscada pedida" ); }
		if ( !PuedeEmboscar() || thePlayer.IsInCombat() ) { return; }
		// Nadie viene a por un Geralt ya malherido: la derrota sería inmediata.
		if ( thePlayer.GetStat( BCS_Vitality ) < thePlayer.GetStatMax( BCS_Vitality ) * 0.3 ) { return; }
		hora = NemesisHoraJuego();
		// Pausa global: dos emboscadas seguidas de némesis distintos serían una encerrona.
		if ( forzarEmboscadaId <= 0 && hora - mundo.horaUltimaEmboscada < 2 ) { return; }
		area = theGame.GetCommonMapManager().GetCurrentArea();
		for ( i = 0; i < mundo.registros.Size(); i += 1 )
		{
			r = mundo.registros[ i ];
			if ( !r || !r.vivo ) { continue; }
			if ( forzarEmboscadaId > 0 )
			{
				if ( r.id == forzarEmboscadaId ) { candidatos.PushBack( r ); }
				continue;
			}
			if ( r.area != area ) { continue; }
			if ( hora - r.horaUltimo < NemesisEsperaHoras( r.temperamento ) ) { continue; }
			candidatos.PushBack( r );
		}
		if ( candidatos.Size() == 0 ) { return; }
		// Sin forzar: un 4 % cada 10 s cuando hay alguien esperando (unos 4 min de media).
		if ( forzarEmboscadaId <= 0 && RandRange( 100 ) >= 4 ) { return; }
		forzarEmboscadaId = 0;
		Emboscar( candidatos[ RandRange( candidatos.Size() ) ] );
	}

	// Busca suelo navegable alrededor de Geralt: primero detrás, luego a los lados y delante, y cada
	// vez más cerca. En sitios cerrados una sola dirección fallaba dos de cada tres veces.
	function PuntoOculto( distancia : float, out punto : Vector ) : bool
	{
		var base, dir, lado, aqui : Vector;
		var dirs : array< Vector >;
		var z, d : float;
		var i, k : int;

		aqui = thePlayer.GetWorldPosition();
		dir = thePlayer.GetHeadingVector();
		lado = Vector( dir.Y, -dir.X, 0 );
		dirs.PushBack( -dir );
		dirs.PushBack( lado );
		dirs.PushBack( -lado );
		dirs.PushBack( -dir + lado );
		dirs.PushBack( -dir - lado );
		dirs.PushBack( dir );
		for ( k = 0; k < 3; k += 1 )
		{
			d = distancia * ( 1.0 - 0.3 * k );
			for ( i = 0; i < dirs.Size(); i += 1 )
			{
				base = aqui + VecNormalize( dirs[ i ] ) * d;
				base.X += RandRangeF( 3.0, -3.0 );
				base.Y += RandRangeF( 3.0, -3.0 );
				if ( theGame.GetWorld().NavigationFindSafeSpot( base, 0.6, 10.0, punto ) )
				{
					if ( theGame.GetWorld().NavigationComputeZ( punto, punto.Z - 5.0, punto.Z + 5.0, z ) ) { punto.Z = z; }
					return true;
				}
			}
		}
		LogChannel( 'NEM', "NEM|AVISO|sin suelo navegable alrededor de Geralt" );
		return false;
	}

	function Generar( ruta : string, etiqueta : name, nivel : int ) : CNewNPC
	{
		var plantilla : CEntityTemplate;
		var punto : Vector;
		var tags : array< name >;
		var npc : CNewNPC;

		plantilla = (CEntityTemplate)LoadResource( ruta, true );
		if ( !plantilla ) { LogChannel( 'NEM', "NEM|AVISO|no carga la plantilla " + ruta ); return NULL; }
		if ( !PuntoOculto( 24.0, punto ) ) { return NULL; }
		tags.PushBack( etiqueta );
		npc = (CNewNPC)theGame.CreateEntity( plantilla, punto, thePlayer.GetWorldRotation(), true, false, false, PM_DontPersist, tags );
		if ( !npc ) { return NULL; }
		npc.SetLevel( nivel );
		npc.SetTemporaryAttitudeGroup( 'hostile_to_player', AGP_Default );
		return npc;
	}

	function Emboscar( r : CNemesisRegistro )
	{
		var i, j, n, nivel : int;
		var s : CNewNPC;
		var efectos : array< EEffectType >;
		var familia : name;

		nivel = Max( r.nivelBase, GetWitcherPlayer().levelManager.GetLevel() ) + r.rango - 1;
		familia = r.familia;
		lider = Generar( r.plantilla, 'NemesisLider', nivel );
		if ( !lider )
		{
			lider = Generar( NemesisPlantillaLider( familia ), 'NemesisLider', nivel );
		}
		if ( !lider && familia != 'bandido' )
		{
			// Partida sin la expansión de su familia: viene como bandido, con séquito de bandidos.
			familia = 'bandido';
			lider = Generar( NemesisPlantillaLider( familia ), 'NemesisLider', nivel );
		}
		if ( !lider ) { LogChannel( 'NEM', "NEM|AVISO|no se pudo generar a " + r.NombreCompleto() ); return; }

		// Lleva encima lo que te robó: si lo matas del todo, está en su cadáver.
		if ( r.botin > 0 && lider.GetInventory() ) { lider.GetInventory().AddMoney( r.botin ); }
		// Con los sentidos de brujo se le ve en rojo, como una pista.
		lider.SetFocusModeVisibility( FMV_Clue );
		for ( i = 0; i < r.inmunidades.Size(); i += 1 )
		{
			efectos = NemesisEfectos( r.inmunidades[ i ] );
			for ( j = 0; j < efectos.Size(); j += 1 )
			{
				lider.AddBuffImmunity( efectos[ j ], 'Nemesis', true );
			}
		}
		n = Min( 1 + r.rango, 4 );
		sequito.Clear();
		for ( i = 0; i < n; i += 1 )
		{
			s = Generar( NemesisPlantillaSequito( familia ), 'NemesisSequito', Max( nivel - 2, 1 ) );
			if ( s ) { sequito.PushBack( s ); }
		}

		encuentroId = r.id;
		liderCaido = false;
		posEncuentro = lider.GetWorldPosition();
		segundosEncuentro = 0;
		segundosLejos = 0;
		segundosNombre = 0;
		geraltDerrotado = false;
		segundosDerrota = 0;
		r.horaUltimo = NemesisHoraJuego();
		mundo.horaUltimaEmboscada = r.horaUltimo;
		// Mientras dure, Geralt no muere (derrota sin recarga). No se usa el estado vanilla
		// «inconsciente»: en pruebas se quedaba atascado fuera de los casos del guardia y el ascensor.
		thePlayer.SetImmortalityMode( AIM_Immortal, NemesisCanal() );
		MostrarNombre();

		mundo.Anotar( r.NombreCompleto() + " embosca a Geralt con " + sequito.Size() + " hombres" );
		LogChannel( 'NEM', "NEM|EMBOSCADA|" + r.Resumen() + "|sequito " + sequito.Size() + "|nivel " + nivel + "|inmunidades " + r.inmunidades.Size() );
		Avisar( NemesisTextoCon( 'Emboscada', r.NombreCompleto(), NemesisFraseEmboscada( r ) ) );
	}

	function MostrarNombre()
	{
		var hud : CR4ScriptedHud;
		var r : CNemesisRegistro;

		r = mundo.Buscar( encuentroId );
		hud = (CR4ScriptedHud)theGame.GetHud();
		if ( hud && lider && r && !liderCaido && lider.IsAlive() )
		{
			hud.ShowOneliner( NemesisTextoCon( 'NombreFlotante', r.NombreCompleto(), IntToString( r.rango ) ), lider );
		}
	}

	function OcultarNombre()
	{
		var hud : CR4ScriptedHud;
		hud = (CR4ScriptedHud)theGame.GetHud();
		if ( hud && lider ) { hud.HideOneliner( lider ); }
	}

	// Algún miembro vivo de la banda; sirve para medir si Geralt se ha alejado.
	function MiembroVivo() : CNewNPC
	{
		var i : int;
		if ( lider && !liderCaido && lider.IsAlive() ) { return lider; }
		for ( i = 0; i < sequito.Size(); i += 1 )
		{
			if ( sequito[ i ] && sequito[ i ].IsAlive() ) { return sequito[ i ]; }
		}
		return NULL;
	}

	function ActualizarEncuentro( dt : float )
	{
		var r : CNemesisRegistro;
		var vivo : CNewNPC;

		if ( geraltDerrotado ) { return; }
		r = mundo.Buscar( encuentroId );
		if ( !r )
		{
			TerminarEncuentro( true );
			return;
		}
		// Una escena o un diálogo de misión que empieza en mitad del encuentro manda: la banda se
		// retira para no estropearlo.
		if ( EnEscena() && !ignorarFiltros )
		{
			LogChannel( 'NEM', "NEM|AVISO|escena durante el encuentro; la banda se retira" );
			TerminarEncuentro( true );
			return;
		}
		vivo = MiembroVivo();
		if ( !vivo )
		{
			TerminarEncuentro( false );
			return;
		}
		segundosNombre += dt;
		if ( segundosNombre >= 5.0 )
		{
			segundosNombre = 0;
			MostrarNombre();
		}
		if ( VecDistance( thePlayer.GetWorldPosition(), vivo.GetWorldPosition() ) > 90.0 )
		{
			segundosLejos += dt;
			if ( segundosLejos >= 25.0 )
			{
				if ( !liderCaido )
				{
					mundo.Anotar( "Geralt dejó atrás a " + r.NombreCompleto() );
					LogChannel( 'NEM', "NEM|HUIDA|" + r.Resumen() );
					Avisar( NemesisTextoCon( 'Huida', r.NombreCompleto() ) );
				}
				TerminarEncuentro( true );
			}
		}
		else
		{
			segundosLejos = 0;
		}
	}

	function TerminarEncuentro( retirarCuerpos : bool )
	{
		var i : int;

		OcultarNombre();
		if ( retirarCuerpos )
		{
			if ( lider && !liderCaido ) { lider.Destroy(); }
			for ( i = 0; i < sequito.Size(); i += 1 )
			{
				if ( sequito[ i ] ) { sequito[ i ].Destroy(); }
			}
		}
		lider = NULL;
		liderCaido = false;
		sequito.Clear();
		encuentroId = 0;
		thePlayer.SetImmortalityMode( AIM_None, NemesisCanal() );
	}

	// ---- 3. Derrota de Geralt ----

	function VigilarDerrota( dt : float )
	{
		var vida, maxima : float;

		if ( segundosDerrota > 0 )
		{
			segundosDerrota -= dt;
			if ( segundosDerrota <= 0 ) { GeraltSeLevanta(); }
			return;
		}
		if ( geraltDerrotado ) { return; }
		segundosEncuentro += dt;
		if ( segundosEncuentro < 3.0 ) { return; }
		vida = thePlayer.GetStat( BCS_Vitality );
		maxima = thePlayer.GetStatMax( BCS_Vitality );
		if ( maxima > 0 && vida <= maxima * 0.03 )
		{
			GeraltCae();
			if ( geraltDerrotado )
			{
				thePlayer.BlockAllActions( 'NemesisDerrota', true );
				theGame.FadeOutAsync( 0.8 );
				segundosDerrota = 2.0;
			}
		}
	}

	var ultimoRobo : int;

	function GeraltCae()
	{
		var r : CNemesisRegistro;
		var dinero : int;
		var pct, tope : float;

		if ( encuentroId <= 0 || geraltDerrotado ) { return; }
		r = mundo.Buscar( encuentroId );
		if ( !r ) { return; }
		geraltDerrotado = true;

		// Solo dinero: espadas, equipo puesto y objetos de misión quedan fuera por construcción.
		switch ( theGame.GetDifficultyLevel() )
		{
			case EDM_Easy:     pct = 0.25; tope = 750;  break;
			case EDM_Medium:   pct = 0.40; tope = 1250; break;
			case EDM_Hard:     pct = 0.65; tope = 1750; break;
			case EDM_Hardcore: pct = 0.85; tope = 2250; break;
			default:           pct = 0.40; tope = 1250; break;
		}
		dinero = thePlayer.GetMoney();
		ultimoRobo = Clamp( (int)MinF( dinero * pct * NemesisFactorRobo( r.temperamento ), tope ), 0, dinero );
		if ( ultimoRobo > 0 ) { thePlayer.RemoveMoney( ultimoRobo ); }
		r.botin += ultimoRobo;

		r.victorias += 1;
		r.rango = Min( r.rango + 1, 5 );
		r.odio = Max( r.odio - 10, 20 );
		r.horaUltimo = NemesisHoraJuego();
		if ( r.victorias == 1 ) { r.origen = 'TeVencio'; }

		mundo.Anotar( r.NombreCompleto() + " venció a Geralt y se llevó " + ultimoRobo + " coronas (rango " + r.rango + ")" );
		LogChannel( 'NEM', "NEM|DERROTA|Geralt vencido por " + r.NombreCompleto() + "|robado " + ultimoRobo + " de " + dinero + "|" + r.Resumen() );
	}

	function GeraltSeLevanta()
	{
		var r : CNemesisRegistro;
		var antes : Vector;
		var poste : name;
		var texto : string;

		if ( !geraltDerrotado ) { return; }
		r = mundo.Buscar( encuentroId );
		antes = thePlayer.GetWorldPosition();
		TerminarEncuentro( true );
		poste = LlevarAlPoste();
		thePlayer.ForceSetStat( BCS_Vitality, thePlayer.GetStatMax( BCS_Vitality ) * 0.4 );
		thePlayer.BlockAllActions( 'NemesisDerrota', false );
		theGame.FadeInAsync( 1.5 );
		geraltDerrotado = false;
		LogChannel( 'NEM', "NEM|DESPIERTA|poste " + NameToString( poste ) + "|movido "
			+ FloatToStringPrec( VecDistance( antes, thePlayer.GetWorldPosition() ), 0 ) + " m" );
		if ( !r ) { return; }
		if ( IsNameValid( poste ) ) { texto = NemesisTexto( 'DespiertaPoste' ); }
		else { texto = NemesisTexto( 'DespiertaSitio' ); }
		if ( ultimoRobo > 0 ) { texto += " " + NemesisTextoCon( 'Robo', r.NombreCompleto(), IntToString( ultimoRobo ) ); }
		else { texto += " " + NemesisTextoCon( 'SinRobo', r.NombreCompleto() ); }
		Avisar( texto );
	}

	function LlevarAlPoste() : name
	{
		var mm : CCommonMapManager;
		var pines : array< SAvailableFastTravelMapPin >;
		var i : int;
		var pos, mejor, aqui : Vector;
		var rot, mejorRot : EulerAngles;
		var d, minD : float;
		var tag : name;

		mm = theGame.GetCommonMapManager();
		pines = mm.GetFastTravelPoints( true, true, false, true );
		aqui = thePlayer.GetWorldPosition();
		minD = -1;
		for ( i = 0; i < pines.Size(); i += 1 )
		{
			if ( !mm.GetLocalFastTravelPointPosition( pines[ i ].tag, true, pos, rot ) ) { continue; }
			d = VecDistanceSquared( aqui, pos );
			if ( minD < 0 || d < minD )
			{
				minD = d;
				mejor = pos;
				mejorRot = rot;
				tag = pines[ i ].tag;
			}
		}
		if ( minD < 0 ) { return ''; }
		thePlayer.TeleportWithRotation( mejor, mejorRot );
		return tag;
	}

	// ---- 4. Muerte del némesis ----

	function MuerteLider( action : W3DamageAction )
	{
		var r : CNemesisRegistro;
		var prob : int;
		var sobrevive, porGeralt : bool;
		var causa, quien : string;

		r = mundo.Buscar( encuentroId );
		if ( !r ) { return; }
		liderCaido = true;
		OcultarNombre();
		porGeralt = action && action.attacker == thePlayer;
		if ( porGeralt ) { quien = "Geralt"; } else { quien = "otros"; }
		prob = Min( 35 + 5 * r.rango, 60 );
		if ( forzarSupervivencia == 1 ) { sobrevive = true; }
		else if ( forzarSupervivencia == 2 ) { sobrevive = false; }
		else { sobrevive = RandRange( 100 ) < prob; }
		forzarSupervivencia = 0;

		causa = NameToString( CausaDe( action ) );
		if ( sobrevive )
		{
			r.derrotas += 1;
			r.odio = Min( r.odio + 25, 100 );
			if ( porGeralt ) { r.AnadirCicatriz( CausaDe( action ) ); }
			r.horaUltimo = NemesisHoraJuego();
			// Su cuerpo desaparece de verdad: si se quedara en el suelo, el aviso mentiría.
			lider.DestroyAfter( 6.0 );
			mundo.Anotar( r.NombreCompleto() + " cayó ante " + quien + " (" + causa + ") pero sigue vivo" );
			LogChannel( 'NEM', "NEM|SOBREVIVE|prob " + prob + "|causa " + causa + "|por " + quien + "|" + r.Resumen() );
			Avisar( NemesisTextoCon( 'Sobrevive', r.NombreCompleto() ) );
		}
		else
		{
			r.vivo = false;
			mundo.Anotar( r.NombreCompleto() + " murió a manos de " + quien + " (" + causa + ")" );
			LogChannel( 'NEM', "NEM|MUERE|prob " + prob + "|causa " + causa + "|por " + quien + "|" + r.Resumen() );
			if ( porGeralt && r.botin > 0 ) { Avisar( NemesisTextoCon( 'MuereBotin', r.NombreCompleto(), IntToString( r.botin ) ) ); }
			else if ( porGeralt ) { Avisar( NemesisTextoCon( 'Muere', r.NombreCompleto() ) ); }
			else { Avisar( NemesisTextoCon( 'MuereOtros', r.NombreCompleto() ) ); }
			// Las coronas ya están en su cadáver (se le dieron al aparecer).
			r.botin = 0;
		}
	}
}
