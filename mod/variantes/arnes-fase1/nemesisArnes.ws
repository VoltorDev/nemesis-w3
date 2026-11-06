// Némesis — arnés de prueba automática de la Fase 1. SOLO para el PC de desarrollo; lo instala y
// lo retira herramientas\autoprueba-fase1.ps1. Carga la última partida desde el menú principal y,
// según haya o no némesis guardados, ejecuta la sesión A o la B:
//  A (sin némesis): nace uno al «matar» Geralt a un bandido generado; emboscada forzada; Geralt al
//    3 % de vida para que lo venzan; tras despertar, guarda en una ranura manual nueva.
//  B (con némesis): comprueba lo guardado; emboscada y muerte con supervivencia forzada; otra
//    emboscada y muerte definitiva.

@addField(CR4Game)
var nemesisArnesCargado : bool;

@addMethod(CR4Game)
function NemesisArnesPrimeraCarga() : bool
{
	if ( nemesisArnesCargado ) { return false; }
	nemesisArnesCargado = true;
	return true;
}

// Con el juego en primer plano aparece «Pulsa cualquier tecla»: el arnés la pasa solo.
@wrapMethod(CR4StartScreenMenuBase)
function OnConfigUI()
{
	var res : bool;
	res = wrappedMethod();
	LogChannel( 'NEM', "NEM|ARNES|pantalla de inicio: la paso" );
	startFade();
	return res;
}

// La partida se elige por nombre, no «la última»: en pruebas reapareció una partida ya apartada.
// Modo A: la partida manual original de Nico. Modo B: la más reciente (la que acaba de guardar A).
// El modo lo fija nemesisArnesModo.ws, que el script de prueba instala distinto en cada sesión.
@wrapMethod(CR4IngameMenu)
function OnConfigUI()
{
	var saves : array< SSavegameInfo >;
	var i, elegida : int;
	var res : bool;

	res = wrappedMethod();
	if ( !isMainMenu || !theGame.NemesisArnesPrimeraCarga() ) { return res; }
	theGame.GetRecentListSG( saves );
	elegida = -1;
	for ( i = 0; i < saves.Size(); i += 1 )
	{
		LogChannel( 'NEM', "NEM|ARNES|partida " + i + ": " + saves[ i ].filename );
		if ( elegida < 0 )
		{
			if ( NemesisArnesModo() == 'B' ) { elegida = i; }
			else if ( StrFindFirst( saves[ i ].filename, "ManualSave_53db8_7ea4b800" ) >= 0 ) { elegida = i; }
		}
	}
	if ( elegida < 0 ) { LogChannel( 'NEM', "NEM|ARNES|FALLO: no encuentro la partida del modo " + NameToString( NemesisArnesModo() ) ); return res; }
	LogChannel( 'NEM', "NEM|ARNES|modo " + NameToString( NemesisArnesModo() ) + ", cargando " + saves[ elegida ].filename );
	theGame.LoadGameInit( saves[ elegida ], false );
	return res;
}

@addField(CR4Player)
var nemesisArnesT : float;

@addField(CR4Player)
var nemesisArnesPaso : int;

@addField(CR4Player)
var nemesisArnesSesion : int;

@addField(CR4Player)
var nemesisArnesId : int;

@wrapMethod(CR4ScriptedHud)
function OnTick( timeDelta : float )
{
	wrappedMethod( timeDelta );
	if ( thePlayer && thePlayer.nemesisMotor ) { thePlayer.NemesisArnesTick( timeDelta ); }
}

@addMethod(CR4Player)
function NemesisArnesLog( texto : string )
{
	LogChannel( 'NEM', "NEM|ARNES|" + texto );
}

@addMethod(CR4Player)
function NemesisArnesKill( npc : CNewNPC )
{
	if ( npc && npc.IsAlive() ) { npc.Kill( 'NemesisArnes', true, this ); }
}

@addMethod(CR4Player)
function NemesisArnesTick( dt : float )
{
	var m : CNemesisMotor;
	var plantilla : CEntityTemplate;
	var victima : CNewNPC;
	var pos : Vector;
	var i : int;
	var r : CNemesisRegistro;

	m = nemesisMotor;
	if ( theGame.IsDialogOrCutscenePlaying() ) { return; }
	nemesisArnesT += dt;

	if ( nemesisArnesPaso == 0 && nemesisArnesT > 5.0 )
	{
		NemesisArnesLog( "paso 0: inicio" );
		m.ignorarFiltros = true;
		ForceSetStat( BCS_Vitality, GetStatMax( BCS_Vitality ) );
		// Sin AddMoney: en el sueño-tutorial de Kaer Morhen el juego se cerraba justo aquí (dos de dos).
		// El botín se prueba en la sesión B dándoselo directamente al némesis.
		nemesisArnesSesion = 1;
		if ( NemesisArnesModo() == 'B' ) { nemesisArnesSesion = 2; }
		NemesisArnesLog( "sesion " + nemesisArnesSesion + " en " + NameToString( theGame.GetCommonMapManager().GetCurrentArea() )
			+ ", nivel " + GetWitcherPlayer().levelManager.GetLevel() + ", dinero " + GetMoney() );
		nemesisArnesPaso = 1;
		nemesisArnesT = 0;
		return;
	}

	// ---- Sesión A ----
	if ( nemesisArnesSesion == 1 )
	{
		if ( nemesisArnesPaso == 1 && nemesisArnesT > 1.0 )
		{
			plantilla = (CEntityTemplate)LoadResource( NemesisRuta( "novigrad_bandit_sword" ), true );
			pos = GetWorldPosition();
			pos.X += 5.0;
			victima = (CNewNPC)theGame.CreateEntity( plantilla, pos, GetWorldRotation(), true, false, false, PM_DontPersist );
			NemesisArnesLog( "bandido de prueba generado: " + ( (bool)victima ) );
			m.forzarNacimiento = true;
			NemesisArnesKill( victima );
			nemesisArnesPaso = 2;
			nemesisArnesT = 0;
		}
		else if ( nemesisArnesPaso == 2 && nemesisArnesT > 3.0 )
		{
			if ( m.mundo.registros.Size() == 0 ) { NemesisArnesLog( "FALLO: no nacio ningun nemesis" ); nemesisArnesPaso = 99; return; }
			nemesisArnesId = m.mundo.registros[ 0 ].id;
			m.forzarEmboscadaId = nemesisArnesId;
			nemesisArnesPaso = 3;
			nemesisArnesT = 0;
		}
		else if ( nemesisArnesPaso == 3 && nemesisArnesT > 4.0 && m.encuentroId == 0 )
		{
			NemesisArnesLog( "emboscada sin generar; reintento" );
			m.forzarEmboscadaId = nemesisArnesId;
			nemesisArnesT = 0;
		}
		else if ( nemesisArnesPaso == 3 && nemesisArnesT > 4.0 )
		{
			// Caso límite: guardar EN MITAD del encuentro, con Geralt inmortal. La sesión B carga
			// esta partida y comprueba que la inmortalidad no viaja en ella.
			if ( theGame.AreSavesLocked() )
			{
				if ( nemesisArnesT > 24.0 ) { NemesisArnesLog( "guardado bloqueado durante el encuentro; sigo sin guardar a mitad" ); nemesisArnesPaso = 31; nemesisArnesT = 0; }
				return;
			}
			NemesisArnesLog( "guardando a mitad del encuentro; inmortal ahora: " + IsImmortal() );
			theGame.SaveGame( SGT_Manual, -1 );
			LogChannel( 'NEM', "NEM|GUARDADO|sesion A, a mitad del encuentro" );
			nemesisArnesPaso = 31;
			nemesisArnesT = 0;
		}
		else if ( nemesisArnesPaso == 31 && nemesisArnesT > 8.0 )
		{
			// Simula la paliza: Geralt al 1 % durante el encuentro, sin depender de la IA ni de la zona.
			NemesisArnesLog( "encuentro activo: " + m.encuentroId + "; Geralt al 1 %" );
			ForceSetStat( BCS_Vitality, GetStatMax( BCS_Vitality ) * 0.01 );
			nemesisArnesPaso = 4;
			nemesisArnesT = 0;
		}
		else if ( nemesisArnesPaso == 4 )
		{
			// Esperar a que lo venzan y despierte (el motor cierra el encuentro al levantarse).
			if ( m.encuentroId == 0 && nemesisArnesT > 3.0 )
			{
				nemesisArnesPaso = 5;
				nemesisArnesT = 0;
			}
			else if ( nemesisArnesT > 25.0 && m.encuentroId > 0 && !m.geraltDerrotado )
			{
				NemesisArnesLog( "FALLO: la derrota no se disparo; reintento" );
				ForceSetStat( BCS_Vitality, GetStatMax( BCS_Vitality ) * 0.01 );
				nemesisArnesT = 0;
			}
		}
		else if ( nemesisArnesPaso == 5 && nemesisArnesT > 3.0 )
		{
			NemesisArnesLog( "tras despertar: inmortal " + IsImmortal() + ", vida " + FloatToStringPrec( GetStat( BCS_Vitality ), 0 ) + " de " + FloatToStringPrec( GetStatMax( BCS_Vitality ), 0 ) );
			NemesisArnesLog( "FIN sesion A" );
			nemesisArnesPaso = 6;
		}
		return;
	}

	// ---- Sesión B ----
	if ( nemesisArnesSesion == 2 )
	{
		if ( nemesisArnesPaso == 1 )
		{
			NemesisArnesLog( "al cargar la partida guardada a mitad del encuentro: inmortal " + IsImmortal() + ", encuentro " + m.encuentroId );
			for ( i = 0; i < m.mundo.registros.Size(); i += 1 )
			{
				if ( m.mundo.registros[ i ].vivo ) { nemesisArnesId = m.mundo.registros[ i ].id; }
			}
			// Botín de prueba: lo que «robó» en una derrota anterior.
			r = m.mundo.Buscar( nemesisArnesId );
			if ( r ) { r.botin = 500; }
			m.forzarEmboscadaId = nemesisArnesId;
			nemesisArnesPaso = 2;
			nemesisArnesT = 0;
		}
		else if ( ( nemesisArnesPaso == 2 || nemesisArnesPaso == 4 ) && nemesisArnesT > 4.0 && m.encuentroId == 0 )
		{
			NemesisArnesLog( "emboscada sin generar; reintento" );
			m.forzarEmboscadaId = nemesisArnesId;
			nemesisArnesT = 0;
		}
		else if ( nemesisArnesPaso == 2 && nemesisArnesT > 4.0 )
		{
			NemesisArnesLog( "botin en el inventario del lider: " + m.lider.GetInventory().GetMoney() + " coronas" );
			// Caso límite: cae el líder pero su séquito sigue vivo; el encuentro debe continuar.
			NemesisArnesLog( "matando SOLO al lider, con supervivencia forzada" );
			m.forzarSupervivencia = 1;
			NemesisArnesKill( m.lider );
			nemesisArnesPaso = 21;
			nemesisArnesT = 0;
		}
		else if ( nemesisArnesPaso == 21 && nemesisArnesT > 3.0 )
		{
			NemesisArnesLog( "tras caer el lider: encuentro " + m.encuentroId + ", sequito vivo " + ( (bool)m.MiembroVivo() ) + ", inmortal " + IsImmortal() );
			for ( i = 0; i < m.sequito.Size(); i += 1 ) { NemesisArnesKill( m.sequito[ i ] ); }
			nemesisArnesPaso = 3;
			nemesisArnesT = 0;
		}
		else if ( nemesisArnesPaso == 3 && nemesisArnesT > 4.0 )
		{
			NemesisArnesLog( "tras matar al sequito: encuentro " + m.encuentroId + " (debe ser 0), inmortal " + IsImmortal() );
			if ( m.encuentroId > 0 ) { m.TerminarEncuentro( true ); }
			m.forzarEmboscadaId = nemesisArnesId;
			nemesisArnesPaso = 4;
			nemesisArnesT = 0;
		}
		else if ( nemesisArnesPaso == 4 && nemesisArnesT > 4.0 )
		{
			NemesisArnesLog( "matando al lider con muerte forzada" );
			m.forzarSupervivencia = 2;
			NemesisArnesKill( m.lider );
			for ( i = 0; i < m.sequito.Size(); i += 1 ) { NemesisArnesKill( m.sequito[ i ] ); }
			nemesisArnesPaso = 5;
			nemesisArnesT = 0;
		}
		else if ( nemesisArnesPaso == 5 && nemesisArnesT > 4.0 )
		{
			m.Volcar();
			// Familia de expansión: se revive al némesis como forajido de Toussaint (solo prueba).
			r = m.mundo.Buscar( nemesisArnesId );
			r.vivo = true;
			r.familia = 'hansa';
			r.plantilla = NemesisPlantillaLider( 'hansa' );
			NemesisArnesLog( "probando familia hansa con " + r.plantilla );
			m.forzarEmboscadaId = nemesisArnesId;
			nemesisArnesPaso = 6;
			nemesisArnesT = 0;
		}
		else if ( nemesisArnesPaso == 6 && nemesisArnesT > 5.0 )
		{
			NemesisArnesLog( "hansa: encuentro " + m.encuentroId + ", lider " + ( (bool)m.lider ) + ", sequito " + m.sequito.Size()
				+ ( m.lider ? ", plantilla del lider " + m.lider.GetReadableName() : "" ) );
			if ( m.encuentroId > 0 ) { m.TerminarEncuentro( true ); }
			NemesisArnesLog( "FIN sesion B" );
			nemesisArnesPaso = 7;
		}
	}
}
