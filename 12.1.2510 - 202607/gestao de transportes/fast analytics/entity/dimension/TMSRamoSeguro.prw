#INCLUDE "BADEFINITION.CH"

NEW ENTITY 43RmSeg

//-------------------------------------------------------------------
/*/{Protheus.doc} TMSRAMOSEGURO
Visualiza as informacoes por Tabela de Ocorrencia

@author  Leandro Paulino
@since   07/12/2018
/*/
//----------------------------------------------------s---------------
Class TMSRamoSeguro from BAEntity
	Method Setup( ) CONSTRUCTOR
	Method BuildQuery( )
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New
Construtor padrão.

@author  Leandro Paulino
@since   07/12/2018
/*/
//-------------------------------------------------------------------
Method Setup( ) Class TMSRamoSeguro
	_Super:Setup("TMS Ramo Seguro", DIMENSION, "DU3")
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constrói a query da entidade.
@return cQuery, string, query a ser processada.

@author  Leandro Paulino
@since   07/12/2018
/*/
//-------------------------------------------------------------------
Method BuildQuery( ) Class TMSRamoSeguro
	Local cQuery    := ""

	cQuery += " SELECT "
	cQuery += " 		<<KEY_DU3_DU3_FILIAL+DU3_COMSEG>>   AS BK_RAMO_SEGURO    ,"
	cQuery += " 		DU3.DU3_COMSEG                      AS COD_RAMO_SEGURO   ,"
	cQuery += " 		DU3.DU3_DESCRI                      AS DESC_OCORRENCIA, "
	cQuery += " 	    <<CODE_INSTANCE>>						AS INSTANCIA"
	cQuery += " 	FROM <<DU3_COMPANY>> DU3                                     " 
	cQuery += " 	WHERE                                                        "
	cQuery += "	   	DU3.D_E_L_E_T_ = ' '                                         "
	cQuery += "     <<AND_XFILIAL_DU3_FILIAL>>                                   "

	
Return cQuery