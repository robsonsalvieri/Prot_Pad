#Include "loca229f.ch"
#INCLUDE "TOTVS.CH"

#INCLUDE "FWEditPanel.CH "

/*/{Protheus.doc} LOCA259F
Implementa o estorno da separação no romaneio
@type function
@version 24.10
@author Alexandre Circenis
@since 2/27/2025
/*/
/*/{Protheus.doc} ModelDef
Definição do Model do LOCA259C
@type function
@version 25.10
@author Alexandre Circenis
@since 6/10/2025
@return variant, Model definido
/*/
Static Function ModelDef()
local oModel    := FWLoadModel("LOCA259C")

oModel := Loca259HMD(oModel)
oModel:GetModel("GRID"):bLoad :=   {|oGrid| Loca229FLG(oGrid)}
//Adicionando descrição ao modelo
oModel:SetDescription( "A.S. Separadas") //"A.S. DIPONIVEL"
// Adiciona a descricao do Componente do Modelo de Dados
//  oModel:GetModel( 'CABEC' ):SetDescription( 'MODEL FAKE' )
oModel:GetModel( 'GRID' ):SetDescription( "A.S. Separadas" ) //"A.S. Disponiveis"
//  oModel:SetPrimaryKey( { 'X_ZMVC' } )
   
Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Função estática do ViewDef
@type function
@version 24.10 
@author Alexandre Circenis
@since 2/12/2025
@return variant, retorna o objeto view
/*///-------------------------------------------------------------------/*/
Static Function ViewDef()
	local oView    := FwLoadView("LOCA259C")
	local oModel   := FWLoadModel( 'LOCA229F' )

oView := LOCA259HVI(oView, oModel)
oView:SetViewAction("BUTTONOK", { |oView| Loca259HOk()})

Return oView

/*/{Protheus.doc} Loca229FLG
Função para gerar a carga do model conforme os parametros de entrada na rotina
@type function
@version 24.10
@author Alexandre Circenis
@since 2/27/2025
@param oMdl, object, model a ser preenchido
@return variant, array com os dados no formato do model
/*/
Static Function Loca229FLG( oMdl)

	Local aArea      := GetArea()
	Local cAliasT    := GetNextAlias()
	Local aDados     := {}
	Local aStruQry   := {}
	Local nLinha     := 0
	Local cQuery 	:= ''
	Local cTmp		:= ''
	Local aParam    := {}

	cTmp := GetNextAlias()
	
	cQuery += "SELECT FQ5.*,FPA.FPA_LOCAL, FPA.FPA_DESGRU, SB1.B1_DESC, 'F' MARK
	
	cQuery += " FROM " + RetSqlName("FQ5") + " FQ5 "  					//-- Cadastro de Viagem

	cQuery += " INNER JOIN  " +	RetSqlName("FPA") + " FPA "  					//-- AgendametosS Itens
	cQuery += " ON  FPA.FPA_FILIAL  =  '" + xFilial("FPA") + "' "
	cQuery += " AND	FPA.FPA_AS = FQ5.FQ5_AS"
	cQuery += " AND	FPA.FPA_TIPOSE = 'L'"
	cQuery += " AND	FPA.FPA_NFREM = ''"

	cQuery += " AND	FPA.D_E_L_E_T_  =  ' ' "

	cQuery += " INNER JOIN  " +	RetSqlName("SB1") + " SB1 "  					//-- AgendametosS Itens
	cQuery += " ON  SB1.B1_FILIAL  =  '" + xFilial("SB1") + "' "
	cQuery += " AND	SB1.B1_COD = FQ5_XPROD"
	cQuery += " AND	SB1.D_E_L_E_T_  =  ' ' "

	cQuery += " LEFT JOIN  " +	RetSqlName("ST9") + " ST9 "  					//-- Solicitantes
	cQuery += " ON  ST9.T9_FILIAL  =  '" + xFilial("ST9") + "' "
	cQuery += " AND ST9.T9_CODBEM  =  FQ5.FQ5_GUINDA "
	cQuery += " AND ST9.D_E_L_E_T_  =  ' ' "

	cQuery += " WHERE FQ5.FQ5_FILIAL = '" + xFilial("FQ5") + "' "

	cQuery += " AND  FQ5_XROMAN = ?" // AS não ligada a demanda
    aadd( aParam, FQU->FQU_NUM)
	cQuery += " AND  FQ5_TPAS = 'L'" // AS do tipo Locação
	cQuery += " AND  FQ5_STATUS = '6'" // AS Separada

	cQuery += " AND NOT EXISTS ( " // AS Está num Romaneio
	cQuery += " SELECT  FQ3_AS "
	cQuery += " FROM " + RetSqlName("FQ3") +" FQ3 "
	cQuery += " WHERE FQ3_FILIAL = '"+xFilial("FQ3")+"'"
	cQuery += " AND FQ3_AS = FQ5.FQ5_AS "
	cQuery += " AND FQ3.D_E_L_E_T_ = ' ')"

	cQuery += " AND NOT EXISTS ( " // AS Está num Pedido
	cQuery += " SELECT  FPZ_AS "
	cQuery += " FROM " + RetSqlName("FPZ") +" FPZ "
	cquery += " INNER JOIN " + RetSqlName("FPY") +" FPY "
	cQuery += "   ON FPY_FILIAL = FPZ_FILIAL "
	cQuery += "   AND FPY_PEDVEN = FPZ_PEDVEN "
	cQuery += "   AND FPY_TIPFAT = 'R' "
	cQuery += "   AND FPY_STATUS <> '2'"
	cQuery += "   AND FPY.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE FPZ_FILIAL = '"+xFilial("FPZ") +"'"
	cQuery += " AND FPZ_AS = FQ5.FQ5_AS "
	cQuery += " AND FPZ.D_E_L_E_T_ = ' ')"
	cQuery += " ORDER BY FQ5_SOT, FQ5_OBRA, FQ5_AS"

	cQuery := ChangeQuery(cQuery)

//-- Executa QUERY
	MPSysOpenQuery(cQuery,cAliasT,,,aParam)

//-- Formata Campos Da Query
	aStruQry := (cAliasT)->(DbStruct())

	For nLinha := 1 To Len(aStruQry)
		If GetSX3Cache(aStruQry[nLinha][1],"X3_TIPO") == "D" .Or. GetSX3Cache(aStruQry[nLinha][1],"X3_TIPO") == "N"
			TCSetField( cAliasT , aStruQry[nLinha][1], GetSX3Cache(aStruQry[nLinha][1],"X3_TIPO"), GetSX3Cache(aStruQry[nLinha][1],"X3_TAMANHO") , GetSX3Cache(aStruQry[nLinha][1],"X3_DECIMAL"))
		Endif
	Next nLinha
	TCSetField( cAliasT , "MARK", "L")
/*
FWLoadByAlias
Função que realiza a carga de um submodelo baseado em um alias existente

@param oObj, object,     		Objeto do submodelo (FWFormFieldsModel ou FWFormGridModel)
@param cAlias, character,       Alias para carga .
@param cAliasReal, character,   Alias Real. Utilizado para carga de campos MEMO reais na tabela, se houver e para uso real de inicializadores padrao, 
	                            se nao for informado usa a tabela definida na estrutura do objeto.
@param cFieldRecno, character,  Nome do campo que contem o numero do recno. Quando a tabela foi criada a partir de uma query
	                            deve ter uma coluna contendo o recno() real do registro. Se o nome desta coluna for R_E_C_N_O_ ou 
	                            RECNO ou Alias+RECNO, nao é preciso informar o nome da coluna neste parametro, caso contrario deve-se informar.
@param lCopy, logical,      	Apenas para compatibilidade, Nao usar
@param lQuery, logical,       	Indica que o alias foi criado a partir de uma query.
*/

// Como tem o campo R_E_C_N_O_, nao é preciso informar qual o campo contem o Recno() real
	aDados := FWLoadByAlias( oMdl , cAliasT , 'FQ5' , Nil , Nil , nil )

//-- Fecha Arquivo Temporário
	If Select(cAliasT) > 0
		(cAliasT)->(DbCloseArea())
	EndIf

	RestArea(aArea)

Return( aDados )
