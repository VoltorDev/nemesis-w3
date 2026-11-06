// Némesis — Fase 0, SOLO para la prueba automática (requiere también la variante Derrota).
// Al terminar la verificación tras cargar, vuelve hostil al cabecilla de prueba y deja a Geralt
// con un 5 % de vida, para que la derrota sin recarga se pruebe sin intervención.

@wrapMethod(CNemesisPrueba)
function Cerrar()
{
	var ent : CEntity;
	var actor : CActor;

	wrappedMethod();
	ent = EntityHandleGet( pnjReal );
	actor = (CActor)ent;
	if ( actor )
	{
		actor.SetBaseAttitudeGroup( 'hostile_to_player' );
		actor.SetTemporaryAttitudeGroup( 'hostile_to_player', AGP_Default );
		Log( "AUTODERROTA", "cabecilla hostil" );
	}
	else
	{
		Log( "AUTODERROTA", "no hay cabecilla; hace falta otro enemigo para probar la derrota" );
	}
	thePlayer.ForceSetStat( BCS_Vitality, thePlayer.GetStatMax( BCS_Vitality ) * 0.05 );
	Log( "AUTODERROTA", "Geralt al 5 % de vida" );
}
