#INCLUDE "BADEFINITION.CH"

NEW ENTITY MOTIVENCERRAMENTO

//-------------------------------------------------------------------
/*/{Protheus.doc} BAMotivEncerramento
Visualiza as informacoes do Motivo de Encerramento.

@author  henrique.cesar
@since   21/02/2018
/*/
//-------------------------------------------------------------------
Class BAMotivEncerramento from BAEntity
	Method Setup( ) CONSTRUCTOR
	Method BuildQuery( )
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New
Construtor padrao.

@author  henrique.cesar
@since   21/02/2018
/*/
//-------------------------------------------------------------------
Method Setup( ) Class BAMotivEncerramento
	_Super:Setup("MotivEncerramento", DIMENSION, "NQI")
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constroi a query da entidade.
@return cQuery, string, query a ser processada.

@author  Helio Leal
@since   26/10/2017
/*/
//-------------------------------------------------------------------
Method BuildQuery( ) Class BAMotivEncerramento
	Local cQuery := ""

	cQuery += " SELECT"
	cQuery += " 		<<KEY_NQI_NQI_FILIAL+NQI_COD>> AS BK_MOTIVO_ENCERRAMENTO,"
	cQuery += " 		NQI.NQI_COD AS COD_DO_MOTIVO,"
	cQuery += " 		NQI.NQI_DESC AS DESC_DO_MOTIVO,"
	cQuery += " 		NQI.NQI_SUGEST AS CANCELAR_PROC,"
	cQuery += "         <<CODE_INSTANCE>> AS INSTANCIA"
	cQuery += " 	FROM <<NQI_COMPANY>> NQI" 
	cQuery += " 	WHERE "
	cQuery += "	   	NQI.D_E_L_E_T_ = ' '"
	cQuery += "     <<AND_XFILIAL_NQI_FILIAL>> "
Return cQuery
