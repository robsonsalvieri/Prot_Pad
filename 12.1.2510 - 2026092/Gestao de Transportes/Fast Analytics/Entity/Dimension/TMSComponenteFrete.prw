#INCLUDE "BADEFINITION.CH"

NEW ENTITY 43CMPFR

//----------------------------------------------------------------------------------
/*{Protheus.doc } BAComponenteFrete
Dimensão que demonstra as negociações cadastradas no SIGATMS.
@author Leandro Paulino
@since  23/11/2018     
/*/
//----------------------------------------------------------------------------------

Class TMSComponenteFrete from BAEntity
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
Method Setup() Class TMSComponenteFrete

    _Super:Setup("TMS Componente Frete", DIMENSION, "DT3")
    
Return

//----------------------------------------------------------------------------------
/*{Protheus.doc} BuildQuery
Contrói a query da entidade.

@return aQuery, array, Retorna as consultas da entidade por empresa

@author Leandro Paulino
@since  23/11/2018
/*/
//----------------------------------------------------------------------------------
Method BuildQuery() Class TMSComponenteFrete
	
    Local cQuery := ""

	cQuery += " SELECT "
	cQuery += "      	<<KEY_DT3_DT3_FILIAL+DT3_CODPAS>>   	AS BK_COMPONENTE ,"
	cQuery += " 	    DT3.DT3_CODPAS                          AS COD_COMPONENTE,"
	cQuery += " 	    DT3.DT3_DESCRI                          AS DES_COMPONENTE, "
	cQuery += " 	    <<CODE_INSTANCE>>						AS INSTANCIA"
	cQuery += "     FROM <<DT3_COMPANY>> DT3                                      "
	cQuery += "     WHERE                                                         "
    cQuery += "     DT3.D_E_L_E_T_ = ' '       									  "
	cQuery += "     <<AND_XFILIAL_DT3_FILIAL>>"                                   

Return cQuery
