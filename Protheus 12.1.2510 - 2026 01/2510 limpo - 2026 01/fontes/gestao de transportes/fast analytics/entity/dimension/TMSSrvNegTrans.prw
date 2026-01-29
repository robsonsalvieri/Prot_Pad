#INCLUDE "BADEFINITION.CH"

NEW ENTITY 43SRVNE

//----------------------------------------------------------------------------------
/*{Protheus.doc } BASRVNEGTRANS
Dimensão que demonstra os Serviços de Negociação de Transporte
@author Leandro Paulino
@since  23/11/2018     
/*/
//----------------------------------------------------------------------------------

Class TMSSrvNegTrans  from BAEntity
    Method Setup() CONSTRUCTOR  
    Method BuildQuery() 
EndClass


//----------------------------------------------------------------------------------
/*{Protheus.doc } Setup
Construtor Padrão

@author Leandro Paulino
@since  23/11/2018
/*/
//----------------------------------------------------------------------------------
Method Setup() Class TMSSrvNegTrans

    _Super:Setup("TMS Servico Negociacao Transp.", DIMENSION, "SX5")
    
Return

//----------------------------------------------------------------------------------
/*{Protheus.doc} BuildQuery
Contrói a query da entidade.

@return cQuery, string, query a ser processada.

@author Leandro Paulino
@since  23/11/2018
/*/
//----------------------------------------------------------------------------------
Method BuildQuery( ) Class TMSSrvNegTrans
    Local cQuery := ""

	cQuery += " SELECT "	
	cQuery += "      	<<KEY_SX5_X5_FILIAL+X5_CHAVE>>  AS BK_SERVICO,  "
	cQuery += " 	    SX5.X5_CHAVE                    AS COD_SERVICO, " 
	cQuery += " 	    SX5.X5_DESCRI                   AS DES_SERVICO, "
	cQuery += " 	    <<CODE_INSTANCE>>				AS INSTANCIA"
	cQuery += "     FROM <<SX5_COMPANY>> SX5                            "
	cQuery += "     WHERE                                               "
    cQuery += "     SX5.X5_TABELA = 'L4'                                "
    cQuery += "     AND SX5.D_E_L_E_T_ = ' '                            "
    cQuery += "     <<AND_XFILIAL_X5_FILIAL>>                           " 	

Return cQuery