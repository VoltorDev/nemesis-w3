// Némesis — arnés de prueba automática de la Fase 0. SOLO para el PC de desarrollo.
// Lo instala herramientas\autoprueba-fase0.ps1 y lo retira al terminar.
// 1. En el menú principal carga la última partida (una vez por arranque del juego).
// 2. Tras crear los datos de prueba, espera 8 s jugando y guarda en una ranura manual NUEVA.

@addField(CR4Game)
var nemesisAutocargado : bool;

// theGame es constante desde fuera: el campo se cambia desde un método del propio CR4Game.
@addMethod(CR4Game)
function NemesisPrimeraAutocarga() : bool
{
	if ( nemesisAutocargado )
	{
		return false;
	}
	nemesisAutocargado = true;
	return true;
}

// En 5.0 el menú principal es el mismo CR4IngameMenu que el de pausa; isMainMenu los distingue.
@wrapMethod(CR4IngameMenu)
function OnConfigUI()
{
	wrappedMethod();
	if ( isMainMenu && theGame.NemesisPrimeraAutocarga() )
	{
		LogChannel( 'NEM', "NEM|AUTO|cargando la ultima partida desde el menu principal" );
		theGame.LoadLastGameInit();
	}
}

@addField(CR4Player)
var nemesisGuardarEn : float;

@wrapMethod(CNemesisPrueba)
function Crear( p : CR4Player )
{
	wrappedMethod( p );
	p.nemesisGuardarEn = 8.0;
}

@wrapMethod(CR4ScriptedHud)
function OnTick( timeDelta : float )
{
	var p : CR4Player;

	wrappedMethod( timeDelta );
	p = thePlayer;
	if ( p && p.nemesisGuardarEn > 0 )
	{
		p.nemesisGuardarEn -= timeDelta;
		if ( p.nemesisGuardarEn <= 0 )
		{
			if ( theGame.AreSavesLocked() )
			{
				p.nemesisGuardarEn = 2.0;
				LogChannel( 'NEM', "NEM|AUTO|guardado bloqueado por el juego; reintento en 2 s" );
			}
			else
			{
				theGame.SaveGame( SGT_Manual, -1 );
				LogChannel( 'NEM', "NEM|GUARDADO|partida manual nueva pedida al juego" );
			}
		}
	}
}
