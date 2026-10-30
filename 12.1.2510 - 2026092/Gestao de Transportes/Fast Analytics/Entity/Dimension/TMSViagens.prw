#INCLUDE "BADEFINITION.CH"

NEW ENTITY 43Viage	

//----------------------------------------------------------------------------------
/*{Protheus.doc } TMSViagens
Apresenta as viagens que foram incluídas do TMS.
@author Leandro Paulino
@since  01/04/2019
/*/
//----------------------------------------------------------------------------------

Class TMSViagens from BAEntity
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
Method Setup() Class TMSViagens
    
    _Super:Setup("TMS Viagens", DIMENSION, "DTQ")
    
Return

//----------------------------------------------------------------------------------
/*{Protheus.doc} BuildQuery
Contrói a query da entidade.

@return aQuery, array, Retorna as consultas da entidade por empresa

@author Leandro Paulino
@since  23/11/2018
/*/
//----------------------------------------------------------------------------------
Method BuildQuery() Class TMSViagens

    Local cQuery := ""

    //Regiões de Transporte

	cQuery += " SELECT "
	cQuery += " 		<<KEY_DTQ_DTQ_FILIAL+DTQ_VIAGEM>> AS BK_VIAGEM,  "
	cQuery += " 		DTQ.DTQ_FILORI   AS FILIAL_VIAGEM,          	            "
    cQuery += " 		DTQ.DTQ_VIAGEM   AS NUMERO_VIAGEM, "
	cQuery += "			<<CODE_INSTANCE>>	AS INSTANCIA "
    cQuery += " 	FROM <<DTQ_COMPANY>> DTQ                                        " 
	cQuery += " 	WHERE                                                           "
	cQuery += "	   	DTQ.D_E_L_E_T_ = ' '                                            "
	cQuery += " 	<<AND_XFILIAL_DTQ_FILIAL>>                                      "
    
Return cQuery
