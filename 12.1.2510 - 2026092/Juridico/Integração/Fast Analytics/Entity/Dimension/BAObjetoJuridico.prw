#INCLUDE "BADEFINITION.CH"

NEW ENTITY OBJJURIDICO

//-------------------------------------------------------------------
/*/{Protheus.doc} BAProcesso
Visualiza as informacoes dos Processos da area Juridica.

@author  Marcia Junko
@since   26/09/2018
/*/
//-------------------------------------------------------------------
Class BAObjetoJuridico from BAEntity
	Method Setup( ) CONSTRUCTOR
	Method BuildQuery( )
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} Setup
Construtor padrao.

@author  Marcia Junko
@since   26/09/2018
/*/
//-------------------------------------------------------------------
Method Setup( ) Class BAObjetoJuridico
	_Super:Setup("ObjetoJuridico", DIMENSION, "NQ4")
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constroi a query da entidade.

@return aQuery, array, Retorna as consultas da entidade por empresa.

@author  Marcia Junko
@since   26/09/2018
/*/
//-------------------------------------------------------------------
Method BuildQuery( ) Class BAObjetoJuridico
	Local cQuery := ""
	
	cQuery := " SELECT <<KEY_COMPANY>> AS BK_EMPRESA, " + ;
	       		  "<<KEY_FILIAL_NQ4_FILIAL>> AS BK_FILIAL, " + ;
	              "<<KEY_NQ4_NQ4_FILIAL+NQ4_COD>> AS BK_OBJETO_JURIDICO, " + ;          
				  "NQ4_COD AS COD_OBJETO, " + ;
				  "NQ4_DESC AS DESC_OBJETO, " + ;
				  "<<CODE_INSTANCE>> AS INSTANCIA " +;
              "FROM <<NQ4_COMPANY>> NQ4 " + ; 
              "WHERE NQ4.D_E_L_E_T_ = ' ' " + ;
              	"<<AND_XFILIAL_NQ4_FILIAL>>"              	
 Return cQuery