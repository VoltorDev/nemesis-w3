// Némesis para The Witcher 3 — enganches con el juego (anotaciones, sin reemplazar archivos vanilla).

@addField(CR4Player)
saved var nemesisMundo : CNemesisMundo;

@addField(CR4Player)
var nemesisMotor : CNemesisMotor;

@addMethod(CR4Player)
function NemesisMotorActivo() : CNemesisMotor
{
	var geralt : W3PlayerWitcher;

	// Solo con Geralt: en los tramos de Ciri thePlayer es otro jugador.
	geralt = (W3PlayerWitcher)this;
	if ( !geralt ) { return NULL; }
	if ( !nemesisMundo )
	{
		nemesisMundo = new CNemesisMundo in this;
		nemesisMundo.Iniciar();
	}
	if ( !nemesisMotor )
	{
		nemesisMotor = new CNemesisMotor in this;
		nemesisMotor.Iniciar( nemesisMundo );
	}
	return nemesisMotor;
}

@wrapMethod(CR4ScriptedHud)
function OnTick( timeDelta : float )
{
	var m : CNemesisMotor;

	wrappedMethod( timeDelta );
	if ( thePlayer )
	{
		m = thePlayer.NemesisMotorActivo();
		if ( m ) { m.Tick( timeDelta ); }
	}
}

@wrapMethod(CNewNPC)
function OnDeath( damageAction : W3DamageAction )
{
	var m : CNemesisMotor;

	wrappedMethod( damageAction );
	if ( thePlayer )
	{
		m = thePlayer.NemesisMotorActivo();
		if ( m ) { m.MuerteNPC( this, damageAction ); }
	}
}

// Para la consola del juego (si está activada).
exec function nemesis_estado()
{
	if ( thePlayer.NemesisMotorActivo() ) { thePlayer.nemesisMotor.Volcar(); }
}
