// Némesis — Fase 0, paso 4: un campo nuevo en una clase que ya está en la partida.
// Lo copia herramientas\prueba-fase0.ps1 -Instalar -V2 junto al mod de prueba.
// Pasa si la partida guardada con la v1 carga, la verificación de la v1 sigue en PASA
// y aparece una línea NEM|V2 por PNJ con el valor que toma el campo nuevo.

@addField(CNemesisPNJ)
saved var campoNuevo : int;

@wrapMethod(CNemesisPrueba)
function Verificar( p : CR4Player )
{
	var i : int;

	wrappedMethod( p );
	for ( i = 0; i < pnjs.Size(); i += 1 )
	{
		if ( pnjs[ i ] )
		{
			Log( "V2", "pnj " + pnjs[ i ].id + " campoNuevo=" + pnjs[ i ].campoNuevo );
		}
	}
}
