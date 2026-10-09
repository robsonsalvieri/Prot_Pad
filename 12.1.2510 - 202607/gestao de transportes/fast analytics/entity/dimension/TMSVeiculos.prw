#INCLUDE "BADEFINITION.CH"

NEW ENTITY 43Veicu

//----------------------------------------------------------------------------------
/*{Protheus.doc } TMSVeiculos
Apresenta os veículos cadastrados na Tabela DA3
@author Leandro Paulino
@since  23/11/2018     
/*/
//----------------------------------------------------------------------------------

Class TMSVeiculos from BAEntity
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
Method Setup() Class TMSVeiculos
    
    _Super:Setup("TMS Veiculos", DIMENSION, "DA3")
    
Return

//----------------------------------------------------------------------------------
/*{Protheus.doc} BuildQuery
Contrói a query da entidade.

@return aQuery, array, Retorna as consultas da entidade por empresa

@author Leandro Paulino
@since  23/11/2018
/*/
//----------------------------------------------------------------------------------
Method BuildQuery() Class TMSVeiculos

    Local cQuery := ""

    //Regiões de Transporte

	cQuery += " SELECT "
	cQuery += " 		<<KEY_DA3_DA3_FILIAL+DA3_COD>> AS BK_VEICULO,   "
	cQuery += " 		DA3.DA3_COD     AS COD_VEICULO, 	            "
    cQuery += " 		DA3.DA3_DESC    AS DES_VEICULO,             	"
	cQuery += " 		DA3.DA3_PLACA   AS PLACA, "
	cQuery += "			<<CODE_INSTANCE>>	AS INSTANCIA "
	cQuery += " 	FROM <<DA3_COMPANY>> DA3                            " 
	cQuery += " 	WHERE                                               "
	cQuery += "	   	DA3.D_E_L_E_T_ = ' '                                "
	cQuery += " 	<<AND_XFILIAL_DA3_FILIAL>>                          "
    
Return cQuery
