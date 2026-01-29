#INCLUDE "BADEFINITION.CH"

NEW ENTITY 43NEGTR

//----------------------------------------------------------------------------------
/*{Protheus.doc } TMSNegociacaoTransporte
Dimensão que demonstra as negociações cadastradas no SIGATMS.
@author Leandro Paulino
@since  23/11/2018     
/*/
//----------------------------------------------------------------------------------

Class TMSNegociacaoTransporte from BAEntity
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
Method Setup() Class TMSNegociacaoTransporte

    _Super:Setup("TMS Negociacao Transporte", DIMENSION, "DDB")
    
Return

//----------------------------------------------------------------------------------
/*{Protheus.doc} BuildQuery
Contrói a query da entidade.

@return aQuery, array, Retorna as consultas da entidade por empresa

@author Leandro Paulino
@since  23/11/2018
/*/
//----------------------------------------------------------------------------------
Method BuildQuery() Class TMSNegociacaoTransporte
	
    Local cQuery := ""

	cQuery += " SELECT "
	cQuery += "      	<<KEY_DDB_DDB_FILIAL+DDB_CODNEG>>   	AS BK_NEGOCIACAO,"
	cQuery += " 	    DDB.DDB_CODNEG                          AS CODNEG,      "
	cQuery += " 	    DDB.DDB_DESCRI                          AS DES_NEGOCI, "
	cQuery += " 	    <<CODE_INSTANCE>>						AS INSTANCIA"
	cQuery += "     FROM <<DDB_COMPANY>> DDB                                    "
	cQuery += "     WHERE                                                       "
    cQuery += "     DDB.D_E_L_E_T_ = ' '                                        "
	cQuery += "     <<AND_XFILIAL_DDB_FILIAL>>"

Return cQuery
