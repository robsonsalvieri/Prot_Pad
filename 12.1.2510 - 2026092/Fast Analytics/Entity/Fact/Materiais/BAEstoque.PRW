#INCLUDE "BADEFINITION.CH"

NEW ENTITY ESTOQUE

//-------------------------------------------------------------------
/*/{Protheus.doc} BAEstoque
Visualiza as informacoes do Estoque da area de Materiais.

@author  Helio Leal
@since   06/11/2017
/*/
//-------------------------------------------------------------------
Class BAEstoque from BAEntity
	Method Setup( ) CONSTRUCTOR
	Method BuildQuery( )
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} Setup
Construtor padrao.

@author  Helio Leal
@since   06/11/2017
/*/
//-------------------------------------------------------------------
Method Setup( ) Class BAEstoque
	_Super:Setup("Estoque", FACT, "SD1")
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constrói a query da entidade.

@return aQuery, array, Retorna as consultas da entidade por empresa.

@author Helio Leal
@since   06/11/2017
/*/
//-------------------------------------------------------------------
Method BuildQuery( ) Class BAEstoque
	Local cQuery := ""
	
	// SALDO DOC ENTRADAS
	cQuery := " SELECT <<KEY_COMPANY>> AS BK_EMPRESA, " + ;
	"<<KEY_FILIAL_D1_FILIAL>> AS BK_FILIAL, " + ;
	"<<KEY_SB1_B1_FILIAL+D1_COD>> AS BK_ITEM, " + ;
	"<<KEY_SB2_B2_FILIAL+D1_LOCAL>> AS BK_DEPOSITO, " + ; 
	"<<KEY_SAH_AH_FILIAL+D1_UM>> AS BK_UNIDADE_DE_MEDIDA, " + ;
	"'Saldo Entradas' AS TIPO_DE_SALDO, " + ;
	"<<EXTRACTION_DATE>> AS DATA_DE_EXTRACAO, " + ; 
	"SUM(D1_QUANT) AS SALDO_ENT, " + ;
	"0 AS SALDO_SAI, " + ;
	"0 AS SALDO_MOV_ENT, " + ;
	"0 AS SALDO_MOV_SAI, " + ;
	"<<CODE_INSTANCE>> AS INSTANCIA " +;
	"FROM <<SD1_COMPANY>> SD1 " + ;
	"INNER JOIN <<SF4_COMPANY>> SF4 " + ;
	"ON F4_FILIAL = <<SUBSTR_SF4_D1_FILIAL>> " + ;
		"AND F4_CODIGO = D1_TES " + ;
		"AND F4_ESTOQUE = 'S' " + ;
		"AND SF4.D_E_L_E_T_ = ' ' " + ;
	"LEFT JOIN <<SB1_COMPANY>> SB1 " + ;
	"ON B1_FILIAL = <<SUBSTR_SB1_D1_FILIAL>> " + ; // Produto
		"AND B1_COD = D1_COD " + ;
		"AND SB1.D_E_L_E_T_ = ' ' " + ;
	"LEFT JOIN <<SB2_COMPANY>> SB2 " + ;
	"ON B2_FILIAL = <<SUBSTR_SB2_D1_FILIAL>> " + ; //Deposito 
		"AND B2_COD = D1_COD " + ;
		"AND B2_LOCAL = D1_LOCAL " + ;
		"AND SB2.D_E_L_E_T_ = ' ' " + ;
	"LEFT JOIN <<SAH_COMPANY>> SAH " + ;
	"ON AH_FILIAL = <<SUBSTR_SAH_D1_FILIAL>> " + ; // Unidade de medida
		"AND AH_UNIMED = D1_UM " + ;
		"AND SAH.D_E_L_E_T_ = ' ' " + ;
	"WHERE D1_DTDIGIT <= <<EXTRACTION_DATE>> " + ;
		"AND D1_ORIGLAN <> 'LF' " + ;
		"AND D1_QUANT > 0 " + ;
		"AND SD1.D_E_L_E_T_ = ' ' " + ;
		"<<AND_XFILIAL_D1_FILIAL>> " + ;
	"GROUP BY D1_FILIAL, B1_FILIAL, B2_FILIAL, AH_FILIAL, D1_COD, D1_LOCAL, D1_UM "

cQuery += "UNION ALL "
		
// SALDO DOC SAIDAS
cQuery += "SELECT <<KEY_COMPANY>> AS BK_EMPRESA, " + ;
	"<<KEY_FILIAL_D2_FILIAL>> AS BK_FILIAL, " + ;
	"<<KEY_SB1_B1_FILIAL+D2_COD>> AS BK_ITEM, " + ;
	"<<KEY_SB2_B2_FILIAL+D2_LOCAL>> AS BK_DEPOSITO, " + ; 
	"<<KEY_SAH_AH_FILIAL+D2_UM>> AS BK_UNIDADE_DE_MEDIDA, " + ;
	"'Saldo Saídas' AS TIPO_DE_SALDO, " + ;
	"<<EXTRACTION_DATE>> AS DATA_DE_EXTRACAO, " + ; 
	"0 AS SALDO_ENT, " + ;
	"SUM(D2_QUANT) AS SALDO_SAI, " + ;
	"0 AS SALDO_MOV_ENT, " + ;
	"0 AS SALDO_MOV_SAI, " + ;
	"<<CODE_INSTANCE>> AS INSTANCIA " +;
	"FROM <<SD2_COMPANY>> SD2 " + ;
	"INNER JOIN <<SF4_COMPANY>> SF4 " + ;
	"ON F4_FILIAL = <<SUBSTR_SF4_D2_FILIAL>> " + ;
		"AND F4_CODIGO = D2_TES " + ;
		"AND F4_ESTOQUE = 'S' " + ;
		"AND SF4.D_E_L_E_T_ = ' ' " + ;
	"LEFT JOIN <<SB1_COMPANY>> SB1 " + ;
	"ON B1_FILIAL = <<SUBSTR_SB1_D2_FILIAL>> " + ; // Produto
		"AND B1_COD = D2_COD " + ;
		"AND SB1.D_E_L_E_T_ = ' ' " + ;
	"LEFT JOIN <<SB2_COMPANY>> SB2 " + ;
	"ON B2_FILIAL = <<SUBSTR_SB2_D2_FILIAL>> " + ; //Deposito 
		"AND B2_COD = D2_COD " + ;
		"AND B2_LOCAL = D2_LOCAL " + ;
		"AND SB2.D_E_L_E_T_ = ' ' " + ;
	"LEFT JOIN <<SAH_COMPANY>> SAH " + ;
	"ON AH_FILIAL = <<SUBSTR_SAH_D2_FILIAL>> " + ; // Unidade de medida
		"AND AH_UNIMED = D2_UM " + ;
		"AND SAH.D_E_L_E_T_ = ' ' " + ;
	"WHERE D2_DTDIGIT <= <<EXTRACTION_DATE>> " + ;
		"AND D2_ORIGLAN <> 'LF' " + ;
		"AND D2_QUANT > 0 " + ;
		"AND SD2.D_E_L_E_T_ = ' ' " + ;
		"<<AND_XFILIAL_D2_FILIAL>> " + ;
	"GROUP BY D2_FILIAL, B1_FILIAL, B2_FILIAL, AH_FILIAL, D2_COD, D2_LOCAL, D2_UM "

cQuery += "UNION ALL "
		
// SALDO MOV ENTRADAS
cQuery += "SELECT <<KEY_COMPANY>> AS BK_EMPRESA, " + ;
	"<<KEY_FILIAL_D3_FILIAL>> AS BK_FILIAL, " + ;
	"<<KEY_SB1_B1_FILIAL+D3_COD>> AS BK_ITEM, " + ;
	"<<KEY_SB2_B2_FILIAL+D3_LOCAL>> AS BK_DEPOSITO, " + ; 
	"<<KEY_SAH_AH_FILIAL+D3_UM>> AS BK_UNIDADE_DE_MEDIDA, " + ;
	"'Saldo Movimento Entradas' AS TIPO_DE_SALDO, " + ;
	"<<EXTRACTION_DATE>> AS DATA_DE_EXTRACAO, " + ; 
	"0 AS SALDO_ENT, " + ;
	"0 AS SALDO_SAI, " + ;
	"SUM(D3_QUANT) AS SALDO_MOV_ENT, " + ;
	"0 AS SALDO_MOV_SAI, " + ;
	"<<CODE_INSTANCE>> AS INSTANCIA " +;
	"FROM <<SD3_COMPANY>> SD3 " + ;
	"LEFT JOIN <<SB1_COMPANY>> SB1 " + ;
	"ON B1_FILIAL = <<SUBSTR_SB1_D3_FILIAL>> " + ; // Produto
		"AND B1_COD = D3_COD " + ;
		"AND SB1.D_E_L_E_T_ = ' ' " + ;
	"LEFT JOIN <<SB2_COMPANY>> SB2 " + ;
	"ON B2_FILIAL = <<SUBSTR_SB2_D3_FILIAL>> " + ; //Deposito 
		"AND B2_COD = D3_COD " + ;
		"AND B2_LOCAL = D3_LOCAL " + ;
		"AND SB2.D_E_L_E_T_ = ' ' " + ;
	"LEFT JOIN <<SAH_COMPANY>> SAH " + ;
	"ON AH_FILIAL = <<SUBSTR_SAH_D3_FILIAL>> " + ; // Unidade de medida
		"AND AH_UNIMED = D3_UM " + ;
		"AND SAH.D_E_L_E_T_ = ' ' " + ;
	"WHERE D3_EMISSAO <= <<EXTRACTION_DATE>> " + ;
		"AND D3_ESTORNO = ' ' " + ;
		"AND D3_TM <= '500' " + ;
		"AND (D3_TM = '499' OR 0 < (SELECT COUNT(*) FROM <<SF5_COMPANY>> SF5 WHERE F5_FILIAL = <<SUBSTR_SF5_D3_FILIAL>> AND F5_CODIGO = D3_TM AND SF5.D_E_L_E_T_ = ' ' )) " + ;
		"AND SD3.D_E_L_E_T_ = ' ' " + ;
		"<<AND_XFILIAL_D3_FILIAL>> " + ;
	"GROUP BY D3_FILIAL, B1_FILIAL, B2_FILIAL, AH_FILIAL, D3_COD, D3_LOCAL, D3_UM "

cQuery += "UNION ALL "
		
// SALDO MOV SAIDAS
cQuery += "SELECT <<KEY_COMPANY>> AS BK_EMPRESA, " + ;
	"<<KEY_FILIAL_D3_FILIAL>> AS BK_FILIAL, " + ;
	"<<KEY_SB1_B1_FILIAL+D3_COD>> AS BK_ITEM, " + ;
	"<<KEY_SB2_B2_FILIAL+D3_LOCAL>> AS BK_DEPOSITO, " + ; 
	"<<KEY_SAH_AH_FILIAL+D3_UM>> AS BK_UNIDADE_DE_MEDIDA, " + ;
	"'Saldo Movimento Entradas' AS TIPO_DE_SALDO, " + ;
	"<<EXTRACTION_DATE>> AS DATA_DE_EXTRACAO, " + ; 
	"0 AS SALDO_ENT, " + ;
	"0 AS SALDO_SAI, " + ;
	"0 AS SALDO_MOV_ENT, " + ;
	"SUM(D3_QUANT) AS SALDO_MOV_SAI, " + ;
	"<<CODE_INSTANCE>> AS INSTANCIA " +;
	"FROM <<SD3_COMPANY>> SD3 " + ;
	"LEFT JOIN <<SB1_COMPANY>> SB1 " + ;
	"ON B1_FILIAL = <<SUBSTR_SB1_D3_FILIAL>> " + ; // Produto
		"AND B1_COD = D3_COD " + ;
		"AND SB1.D_E_L_E_T_ = ' ' " + ;
	"LEFT JOIN <<SB2_COMPANY>> SB2 " + ;
	"ON B2_FILIAL = <<SUBSTR_SB2_D3_FILIAL>> " + ; //Deposito 
		"AND B2_COD = D3_COD " + ;
		"AND B2_LOCAL = D3_LOCAL " + ;
		"AND SB2.D_E_L_E_T_ = ' ' " + ;
	"LEFT JOIN <<SAH_COMPANY>> SAH " + ;
	"ON AH_FILIAL = <<SUBSTR_SAH_D3_FILIAL>> " + ; // Unidade de medida
		"AND AH_UNIMED = D3_UM " + ;
		"AND SAH.D_E_L_E_T_ = ' ' " + ;
	"WHERE D3_EMISSAO <= <<EXTRACTION_DATE>> " + ;
		"AND D3_ESTORNO = ' ' " + ;
		"AND D3_TM > '500' " + ;
		"AND SD3.D_E_L_E_T_ = ' ' " + ;
		"<<AND_XFILIAL_D3_FILIAL>> " + ;
	"GROUP BY D3_FILIAL, B1_FILIAL, B2_FILIAL, AH_FILIAL, D3_COD, D3_LOCAL, D3_UM "

Return cQuery