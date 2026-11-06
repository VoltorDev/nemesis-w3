// Némesis — Fase 0, prueba opcional de la derrota sin recarga, que es lo que necesita la Fase 1.
// Lo copia herramientas\prueba-fase0.ps1 -Instalar -Derrota junto al mod de prueba.
// Tras crear o verificar los datos, pone a Geralt en inmortalidad «inconsciente» en el canal de
// combate. Déjate vencer (lobos, el cabecilla…): en vez de morir y recargar, el juego debería
// tumbarlo, fundir a negro y levantarlo (game\player\states\unconscious.ws:79-129). Una vez por carga.

@wrapMethod(CNemesisPrueba)
function Crear( p : CR4Player )
{
	wrappedMethod( p );
	ArmarDerrota( p );
}

@wrapMethod(CNemesisPrueba)
function Verificar( p : CR4Player )
{
	wrappedMethod( p );
	ArmarDerrota( p );
}

@addMethod(CNemesisPrueba)
function ArmarDerrota( p : CR4Player )
{
	p.SetImmortalityMode( AIM_Unconscious, AIC_Combat );
	Log( "DERROTA", "armada; WillBeUnconscious=" + p.WillBeUnconscious() + ". Si Geralt cae, debe quedar inconsciente y levantarse sin recargar" );
}

@wrapMethod(CR4PlayerStateUnconscious)
function OnEnterState( prevStateName : name )
{
	wrappedMethod( prevStateName );
	// Solo una vez: se quita para que el paso de morir sin guardar siga siendo posible.
	parent.SetImmortalityMode( AIM_None, AIC_Combat );
	LogChannel( 'NEM', "NEM|DERROTA|Geralt inconsciente (venia de " + NameToString( prevStateName ) + "); inmortalidad retirada" );
}

@wrapMethod(CR4PlayerStateUnconscious)
function OnLeaveState( nextStateName : name )
{
	wrappedMethod( nextStateName );
	LogChannel( 'NEM', "NEM|DERROTA|Geralt se levanta sin recargar: vida " + FloatToStringPrec( parent.GetStat( BCS_Vitality ), 0 )
		+ " de " + FloatToStringPrec( parent.GetStatMax( BCS_Vitality ), 0 ) + ", en combate " + parent.IsInCombat() );
}
