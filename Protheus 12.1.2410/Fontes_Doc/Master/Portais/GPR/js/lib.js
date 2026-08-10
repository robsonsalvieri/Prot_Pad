/*
****************************************************************************
* Programa   * fLimCampo  * Autor * Luiz Felipe Couto    * Data * 23/02/05 *
****************************************************************************
* Desc.      * Esta funcao limita o tamanho do campo oCampo e altera o     *
*            * valor do campo contador oCampoCont (caso possua)            *
****************************************************************************
* Parametros * ExpO1 : campo limitado                                      *
*            * ExpO2 : campo contador                                      *
*            * ExpN3 : limite maximo do campo Exp01                        *
****************************************************************************
* Uso        * SIGAGPR                                                     *
****************************************************************************
* Analista   * Data/BOPS//Ver * Manutencao Efetuada                        *
****************************************************************************
*            *                *                                            *
****************************************************************************
*/
function fLimCampo( oCampo, oCampoCont, nLimMax )
{
	if ( oCampo.value.length > nLimMax )
	{
		oCampo.value = oCampo.value.substring( 0, nLimMax );

		if ( ( event.keyCode != 37 ) && ( event.keyCode != 38 ) && ( event.keyCode != 39 ) && ( event.keyCode != 40 ) && 
			( event.keyCode != 8 ) && ( event.keyCode != 46 ) && ( event.keyCode != 35 ) && ( event.keyCode != 34 ) && 
			( event.keyCode != 33 ) && ( event.keyCode != 36 ) && ( event.keyCode != 45 ) )
			{
				event.returnValue = false;
			}
	}
	else
	{
		oCampoCont.value = nLimMax - oCampo.value.length;
	}
}

/*
****************************************************************************
* Programa   * fHabCampo  * Autor * Luiz Felipe Couto    * Data * 23/02/05 *
****************************************************************************
* Desc.      * Esta funcao habilita ou desabilita o campo oCampo           *
****************************************************************************
* Parametros * ExpO1 : campo                                               *
*            * ExpO2 : true - habilita                                     *
*            *         false - desabilita                                  *
****************************************************************************
* Uso        * SIGAGPR                                                     *
****************************************************************************
* Analista   * Data/BOPS//Ver * Manutencao Efetuada                        *
****************************************************************************
*            *                *                                            *
****************************************************************************
*/
function fHabCampo( nTipo, oCampoChecked, oCampo, lHabilita )
{
	if( nTipo == 1 )
		if( lHabilita == true )
		{
			oCampo.disabled = false;
		}
		else
		{
			oCampo.disabled = true;
		}
	else
	{
		if( oCampoChecked.checked )
		{
			oCampo.disabled = false;
		}
		else
		{
			oCampo.disabled = true;
		}
	}
}