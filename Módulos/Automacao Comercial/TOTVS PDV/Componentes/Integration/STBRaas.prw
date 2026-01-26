#INCLUDE "TOTVS.CH"

Static oRAAS := Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} STBGetRaas()
Retorna objeto de RAAS Integration da variavel static

@type    function
@return  LjRAASIntegration, Objeto da variavel static
@author  Rafael Tenorio da Costa
@since   08/06/21
@version 12.1.33
/*/
//-------------------------------------------------------------------
Function STBGetRaas()
Return oRAAS

//-------------------------------------------------------------------
/*/{Protheus.doc} STBSetRaas()
Atualiza objeto de RAAS Integration da variavel static

@type    function
@return  LjRAASIntegration, Objeto da variavel static
@author  Rafael Tenorio da Costa
@since   08/06/21
@version 12.1.33
/*/
//-------------------------------------------------------------------
Function STBSetRaas(oRaasI)
    oRAAS := oRaasI
Return 