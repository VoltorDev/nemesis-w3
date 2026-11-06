// Némesis — Fase 0: prueba de persistencia. Mod TEMPORAL, solo para una partida desechable.
//
// Tras cargar una partida, cuando lleva 3 s jugando con Geralt (sin escena, diálogo ni combate):
//   sin datos -> crea un conjunto fijo de datos y un PNJ persistente; escribe NEM|CREADO.
//   con datos -> los compara con los valores esperados; escribe NEM|PASA / NEM|FALLA por
//                comprobación y NEM|RESUMEN al final (tras esperar hasta 20 s al PNJ).
// Salida: LogChannel('NEM', ...) en Documentos\The Witcher 3\scriptslog.txt; exige -debugscripts.
// Formato de línea: "NEM|tipo|texto". Lo lee herramientas\fase0.py.

@addField(CR4Player)
saved var nemesisPrueba : CNemesisPrueba;

// Estado de esta carga, sin guardar: el jugador es un objeto nuevo en cada carga.
// nemesisFase: 0 esperando, 1 esperando al PNJ persistente, 2 terminado.
@addField(CR4Player)
var nemesisEspera : float;

@addField(CR4Player)
var nemesisFase : int;

@addField(CR4Player)
var nemesisEsperaEntidad : float;

@wrapMethod(CR4ScriptedHud)
function OnTick( timeDelta : float )
{
	if ( thePlayer )
	{
		thePlayer.NemesisPruebaTick( timeDelta );
	}
	wrappedMethod( timeDelta );
}

@addMethod(CR4Player)
function NemesisPruebaTick( timeDelta : float )
{
	var geralt : W3PlayerWitcher;

	// Solo con Geralt: en los tramos de Ciri thePlayer es otro jugador y no lleva estos datos.
	geralt = (W3PlayerWitcher)this;
	if ( !geralt )
	{
		return;
	}

	if ( nemesisFase == 2 )
	{
		// Refresca cada 2 s la foto de Geralt que viaja en la partida, para que al guardar
		// coincida con su estado y la siguiente carga pueda detectar si se corrompió.
		nemesisEspera += timeDelta;
		if ( nemesisEspera > 2.0 && nemesisPrueba )
		{
			nemesisEspera = 0;
			nemesisPrueba.TomarReferencia();
		}
		return;
	}

	if ( nemesisFase == 1 )
	{
		nemesisEsperaEntidad += timeDelta;
		nemesisEspera += timeDelta;
		if ( nemesisEspera < 1.0 )
		{
			return;
		}
		nemesisEspera = 0;
		if ( nemesisPrueba.ComprobarEntidad( this, nemesisEsperaEntidad >= 20.0 ) )
		{
			nemesisPrueba.Cerrar();
			nemesisFase = 2;
		}
		return;
	}

	// Fase 0: esperar a que se esté jugando de verdad.
	if ( theGame.IsDialogOrCutscenePlaying() || IsInNonGameplayCutscene() || IsInCombat() )
	{
		nemesisEspera = 0;
		return;
	}
	nemesisEspera += timeDelta;
	if ( nemesisEspera < 3.0 )
	{
		return;
	}
	nemesisEspera = 0;

	if ( !nemesisPrueba )
	{
		nemesisPrueba = new CNemesisPrueba in this;
		nemesisPrueba.Crear( this );
		nemesisFase = 2;
	}
	else
	{
		nemesisPrueba.Verificar( this );
		nemesisFase = 1;
	}
}

class CNemesisRecuerdo
{
	saved var tipo : name;
	saved var intensidad : int;
	saved var dia : int;
}

class CNemesisPNJ
{
	saved var id : int;
	saved var nombre : string;
	saved var temperamento : name;
	saved var nivel : int;
	saved var rencor : float;
	saved var vivo : bool;
	saved var relaciones : array< int >;
	saved var recuerdos : array< CNemesisRecuerdo >;
}

class CNemesisPrueba
{
	saved var version : int;
	saved var sesiones : int;
	saved var diaCreacion : int;
	saved var pnjs : array< CNemesisPNJ >;
	saved var notoriedad : map< name, int >;
	saved var pnjReal : EntityHandle;
	saved var posReal : Vector;
	saved var plantillaReal : string;

	// Foto de Geralt al guardar. Otro mod de Némesis avisó de partidas que perdían nivel,
	// experiencia y ranuras de equipo con muchos datos de mods guardados en el jugador.
	saved var refNivel : int;
	saved var refExp : float;
	saved var refEquipo : array< name >;

	private var pasa : int;
	private var falla : int;

	// ---- Valores esperados (fijos: la verificación los recalcula) ----

	function NombreEsperado( i : int ) : string
	{
		if ( i == 0 ) { return "Prueba Uno"; }
		if ( i == 1 ) { return "Ñoño Ávila de Cintra"; }
		return "Prueba|Tres~con^separadores";
	}

	function TemperamentoEsperado( i : int ) : name
	{
		if ( i == 0 ) { return 'Hothead'; }
		if ( i == 1 ) { return 'Coward'; }
		return 'Proud';
	}

	function RencorEsperado( i : int ) : float
	{
		return 12.5 * ( i + 1 ) + 0.25;
	}

	// ---- Creación ----

	function Crear( p : CR4Player )
	{
		var i, k : int;
		var pnj : CNemesisPNJ;
		var rec : CNemesisRecuerdo;

		version = 1;
		sesiones = 0;
		diaCreacion = GameTimeDays( theGame.GetGameTime() );

		for ( i = 0; i < 3; i += 1 )
		{
			pnj = new CNemesisPNJ in this;
			pnj.id = 100 + i;
			pnj.nombre = NombreEsperado( i );
			pnj.temperamento = TemperamentoEsperado( i );
			pnj.nivel = 5 * ( i + 1 );
			pnj.rencor = RencorEsperado( i );
			pnj.vivo = ( i != 2 );
			pnj.relaciones.PushBack( i * 10 + 1 );
			pnj.relaciones.PushBack( i * 10 + 2 );
			for ( k = 0; k <= i; k += 1 )
			{
				rec = new CNemesisRecuerdo in pnj;
				rec.tipo = 'Ira';
				rec.intensidad = 60 + i * 5 + k;
				rec.dia = k + 1;
				pnj.recuerdos.PushBack( rec );
			}
			pnjs.PushBack( pnj );
		}

		notoriedad[ 'Bandidos' ] = 35;
		notoriedad[ 'Nilfgaard' ] = 70;

		CrearPNJReal( p );
		TomarReferencia();

		Log( "CREADO", "datos v" + version + ", " + pnjs.Size() + " PNJ, dia " + diaCreacion
			+ ", entidad " + plantillaReal + ". Ahora GUARDA en una ranura nueva y cierra el juego." );
		Volcar();
	}

	// La plantilla con la que empezará la Fase 1 (docs\LORE-Y-ENEMIGOS.md): cabecilla de bandidos
	// genérico, comprobado en REDkit r4data\living_world\enemy_templates. Se le pone actitud
	// amistosa para que no haya combate y se pueda guardar; tras cargar se mira si la conserva.
	function CrearPNJReal( p : CR4Player )
	{
		var ruta : string;
		var plantilla : CEntityTemplate;
		var ent : CEntity;
		var actor : CActor;

		ruta = "living_world\enemy_templates\novigrad_bandit_leader_swordshield.w2ent";
		plantilla = (CEntityTemplate)LoadResource( ruta, true );
		if ( !plantilla )
		{
			plantillaReal = "";
			Log( "AVISO", "no se pudo cargar " + ruta + "; se prueba solo la parte de datos" );
			return;
		}

		posReal = p.GetWorldPosition();
		posReal.X += 4.0;
		ent = theGame.CreateEntity( plantilla, posReal, p.GetWorldRotation(), true, false, false, PM_Persist );
		if ( !ent )
		{
			plantillaReal = "";
			Log( "AVISO", "CreateEntity devolvio vacio con " + ruta );
			return;
		}
		actor = (CActor)ent;
		if ( actor )
		{
			actor.SetBaseAttitudeGroup( 'friendly_to_player' );
		}
		EntityHandleSet( pnjReal, ent );
		plantillaReal = ruta;
		posReal = ent.GetWorldPosition();
	}

	// ---- Foto de Geralt ----

	function EquipoActual() : array< name >
	{
		var inv : CInventoryComponent;
		var ranuras : array< EEquipmentSlots >;
		var res : array< name >;
		var id : SItemUniqueId;
		var i : int;

		ranuras.PushBack( EES_SteelSword );
		ranuras.PushBack( EES_SilverSword );
		ranuras.PushBack( EES_Armor );
		ranuras.PushBack( EES_Boots );
		ranuras.PushBack( EES_Pants );
		ranuras.PushBack( EES_Gloves );
		inv = thePlayer.GetInventory();
		for ( i = 0; i < ranuras.Size(); i += 1 )
		{
			if ( inv && inv.GetItemEquippedOnSlot( ranuras[ i ], id ) )
			{
				res.PushBack( inv.GetItemName( id ) );
			}
			else
			{
				res.PushBack( 'ninguno' );
			}
		}
		return res;
	}

	function TomarReferencia()
	{
		var wp : W3PlayerWitcher;

		wp = GetWitcherPlayer();
		if ( !wp || !wp.levelManager )
		{
			return;
		}
		refNivel = wp.levelManager.GetLevel();
		refExp = wp.levelManager.GetPointsTotal( EExperiencePoint );
		refEquipo = EquipoActual();
	}

	function VerificarGeralt()
	{
		var wp : W3PlayerWitcher;
		var ahora : array< name >;
		var i : int;
		var exp : float;

		wp = GetWitcherPlayer();
		if ( !wp || !wp.levelManager )
		{
			Log( "AVISO", "no se juega con Geralt; no se comprueba nivel ni equipo" );
			return;
		}
		Comprobar( "Geralt nivel", wp.levelManager.GetLevel() == refNivel,
			"guardado " + refNivel + ", leido " + wp.levelManager.GetLevel() );
		exp = wp.levelManager.GetPointsTotal( EExperiencePoint );
		Comprobar( "Geralt experiencia", AbsF( exp - refExp ) < 1.0,
			"guardada " + FloatToStringPrec( refExp, 0 ) + ", leida " + FloatToStringPrec( exp, 0 ) );
		ahora = EquipoActual();
		for ( i = 0; i < refEquipo.Size() && i < ahora.Size(); i += 1 )
		{
			Comprobar( "Geralt ranura " + i, ahora[ i ] == refEquipo[ i ],
				"guardado " + NameToString( refEquipo[ i ] ) + ", leido " + NameToString( ahora[ i ] ) );
		}
		Comprobar( "Geralt numero de ranuras", refEquipo.Size() == ahora.Size(), "guardadas " + refEquipo.Size() );
	}

	// ---- Verificación tras cargar ----

	function Comprobar( que : string, ok : bool, detalle : string )
	{
		if ( ok )
		{
			pasa += 1;
			Log( "PASA", que + " (" + detalle + ")" );
		}
		else
		{
			falla += 1;
			Log( "FALLA", que + " (" + detalle + ")" );
		}
	}

	function Verificar( p : CR4Player )
	{
		var i, k : int;
		var pnj : CNemesisPNJ;
		var esperado : int;

		pasa = 0;
		falla = 0;
		Log( "CARGADO", "sesiones leidas de la partida: " + sesiones );

		VerificarGeralt();
		Comprobar( "version", version == 1, "leido " + version );
		Comprobar( "numero de PNJ", pnjs.Size() == 3, "leido " + pnjs.Size() );

		for ( i = 0; i < pnjs.Size() && i < 3; i += 1 )
		{
			pnj = pnjs[ i ];
			if ( !pnj )
			{
				Comprobar( "pnj " + i + " existe", false, "objeto vacio" );
				continue;
			}
			Comprobar( "pnj " + i + " id", pnj.id == 100 + i, "leido " + pnj.id );
			Comprobar( "pnj " + i + " nombre", pnj.nombre == NombreEsperado( i ), "leido '" + pnj.nombre + "'" );
			Comprobar( "pnj " + i + " temperamento", pnj.temperamento == TemperamentoEsperado( i ), "leido " + NameToString( pnj.temperamento ) );
			Comprobar( "pnj " + i + " nivel", pnj.nivel == 5 * ( i + 1 ), "leido " + pnj.nivel );
			Comprobar( "pnj " + i + " rencor", AbsF( pnj.rencor - RencorEsperado( i ) ) < 0.001, "leido " + FloatToStringPrec( pnj.rencor, 3 ) );
			Comprobar( "pnj " + i + " vivo", pnj.vivo == ( i != 2 ), "leido " + pnj.vivo );
			Comprobar( "pnj " + i + " relaciones", pnj.relaciones.Size() == 2
				&& pnj.relaciones[ 0 ] == i * 10 + 1 && pnj.relaciones[ 1 ] == i * 10 + 2, "tamano " + pnj.relaciones.Size() );
			Comprobar( "pnj " + i + " recuerdos", pnj.recuerdos.Size() == i + 1, "tamano " + pnj.recuerdos.Size() );
			for ( k = 0; k < pnj.recuerdos.Size() && k <= i; k += 1 )
			{
				esperado = 60 + i * 5 + k;
				Comprobar( "pnj " + i + " recuerdo " + k, pnj.recuerdos[ k ]
					&& pnj.recuerdos[ k ].tipo == 'Ira'
					&& pnj.recuerdos[ k ].intensidad == esperado
					&& pnj.recuerdos[ k ].dia == k + 1, "esperado intensidad " + esperado );
			}
		}

		Comprobar( "map Bandidos", notoriedad.Contains( 'Bandidos' ) && notoriedad[ 'Bandidos' ] == 35, "tamano " + notoriedad.Size() );
		Comprobar( "map Nilfgaard", notoriedad.Contains( 'Nilfgaard' ) && notoriedad[ 'Nilfgaard' ] == 70, "tamano " + notoriedad.Size() );
	}

	// El PNJ persistente puede tardar en cargarse después de la partida: se reintenta desde el
	// tick hasta que aparece o hasta el último intento, y solo entonces cuenta como fallo.
	function ComprobarEntidad( p : CR4Player, ultimo : bool ) : bool
	{
		var ent : CEntity;
		var actor : CActor;

		if ( plantillaReal == "" )
		{
			Log( "AVISO", "no se creo entidad al principio; no se comprueba el EntityHandle" );
			return true;
		}
		ent = EntityHandleGet( pnjReal );
		if ( !ent )
		{
			if ( ultimo )
			{
				Comprobar( "entidad persistente", false, "EntityHandleGet vacio tras 20 s; " + plantillaReal
					+ ", Geralt a " + FloatToStringPrec( VecDistance( p.GetWorldPosition(), posReal ), 0 ) + " m del sitio" );
			}
			return ultimo;
		}
		Comprobar( "entidad persistente", true, plantillaReal + ", a "
			+ FloatToStringPrec( VecDistance( ent.GetWorldPosition(), posReal ), 1 ) + " m de donde se creo" );
		actor = (CActor)ent;
		if ( actor )
		{
			// Informativo, no cuenta: decide si la actitud de un némesis hay que reaplicarla al cargar.
			Log( "INFO", "actitud base tras cargar: " + NameToString( actor.GetBaseAttitudeGroup() )
				+ " (se puso friendly_to_player); vivo " + actor.IsAlive() );
		}
		return true;
	}

	function Cerrar()
	{
		Log( "RESUMEN", "pasa=" + pasa + " falla=" + falla );
		Volcar();

		// Cambio sin guardar: sirve para el paso opcional de morir y recargar.
		sesiones += 1;
	}

	// ---- Volcado legible ----

	function Volcar()
	{
		var i : int;
		var pnj : CNemesisPNJ;

		for ( i = 0; i < pnjs.Size(); i += 1 )
		{
			pnj = pnjs[ i ];
			if ( pnj )
			{
				Log( "VOLCADO", "pnj " + pnj.id + " '" + pnj.nombre + "' " + NameToString( pnj.temperamento )
					+ " nivel " + pnj.nivel + " rencor " + FloatToStringPrec( pnj.rencor, 2 )
					+ " vivo " + pnj.vivo + " relaciones " + pnj.relaciones.Size() + " recuerdos " + pnj.recuerdos.Size() );
			}
		}
	}

	function Log( tipo : string, texto : string )
	{
		LogChannel( 'NEM', "NEM|" + tipo + "|" + texto );
	}
}
