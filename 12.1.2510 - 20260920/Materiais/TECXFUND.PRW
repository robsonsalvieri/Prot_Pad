#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TECXFUND.CH"

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TecF3Posto
Executa a F3 de Posto de Trabalho, montando dinamicamente colunas, filtros e query SQL
de acordo com o tipo informado, considerando regras de contrato, filial, produto,
local de atendimento, múltiplas filiais e campos adicionais configuráveis.

@param  cTipo       Tipo de chamada da F3 (POSTO, POSTO_TFL, POSTO_LCA, POSTO_LGY, POSTO_CFG)
@param  lAutomato   Indica se a execução ocorre em modo automático (IsBlind)
@param  oModel      Modelo FW ativo utilizado para obtenção dos dados (FwModelActive)
@param  cRetorno    Variável de retorno com o código selecionado na F3
@return logical     .T. se executado corretamente
@author Breno Gomes
@since  11/02/2026
/*/
//--------------------------------------------------------------------------------------------------------------------
Function TecF3Posto(cTipo, lAutomato, oModel, cRetorno)
	Local aCampos    := {}
	Local aColumns   := {}
	Local aCpoAdd    := {}
	Local aIndex     := {}
	Local aRetExec   := {}
	Local aSeek      := {}
	Local cCampoCod  := ""
	Local cCliente   := ""
	Local cCodTFL    := ""
	Local cContrat   := ""
	Local cFilTFJ    := ""
	Local cLocAt     := ""
	Local cLoja      := ""
	Local cNao       := STR0003 //"Não"
	Local cOrcam     := ""
	Local cProd      := ""
	Local cQuery     := ""
	Local cRevis     := ""
	Local cSim       := STR0002 //"Sim" 
	Local cSpcContra := Space(TamSx3("CN9_NUMERO")[1])
	Local cTitle     := STR0001 //"Posto de Trabalho"
	Local lEnceDT    := TecEncDtFt()
	Local lExibCamp  := ExistBlock("TecF3190")
	Local lMultFil   := TecMultFil() //Indica se considera multiplas filiais
	Local lRet       := .T.
	Local nOrdem     := 1
	Local nX         := 0
	Local nY         := 0
	Local oQuery     := Nil

	Default cTipo     := ""
	Default lAutomato := IsBlind()
	Default oModel    := FwModelActive()

	If cTipo == "POSTO"
		cContrat := oModel:GetValue("TGYMASTER","TGY_CONTRT")
		cRevis   := oModel:GetValue("TGYMASTER","TGY_CONREV")
		If lMultFil
			cFilTFJ  := oModel:GetValue("TGYMASTER","TGY_FILIAL")
		EndIf
		cCodTFL  := oModel:GetValue("TGYMASTER","TGY_CODTFL")
	ElseIf cTipo == "POSTO_LCA"
		cContrat := oModel:GetValue("LCAMASTER","LCA_CONTRT")
		cRevis   := oModel:GetValue("LCAMASTER","LCA_CONREV")
		If lMultFil
			cFilTFJ  := oModel:GetValue("LCAMASTER","LCA_FILIAL")
		EndIf
		cCodTFL  := oModel:GetValue("LCAMASTER","LCA_CODTFL")
	ElseIf cTipo == "POSTO_LGY"
		cContrat := oModel:GetValue("LGYDETAIL","LGY_CONTRT")
		cRevis   := oModel:GetValue("LGYDETAIL","LGY_CONREV")
		If lMultFil
			cFilTFJ  := oModel:GetValue("LGYDETAIL","LGY_FILIAL")
		EndIf
		cCodTFL  := oModel:GetValue("LGYDETAIL","LGY_CODTFL")
	ElseIf cTipo $ "POSTO_TFL"
		cContrat := oModel:GetValue("TFLMASTER","TFL_CONTRT")
		cRevis   := oModel:GetValue("TFLMASTER","TFL_CONREV")
		If lMultFil
			cFilTFJ  := oModel:GetValue("TFLMASTER","TFL_FILIAL")
		EndIf
		cCliente := oModel:GetValue("TFLMASTER","TFL_CODENT")
		cLoja    := oModel:GetValue("TFLMASTER","TFL_LOJA")
		cOrcam   := oModel:GetValue("TFLMASTER","TFL_CODPAI")
		cLocAt   := oModel:GetValue("TFLMASTER","TFL_LOCAL")
		cProd    := oModel:GetValue("TFLMASTER","TFL_PROD")
	ElseIf cTipo == "POSTO_CFG" .And. lMultFil
		cFilTFJ  := oModel:GetValue("TFFMASTER","TFF_FILIAL")
	EndIf

	If lExibCamp
		aRetExec :=	ExecBlock("TecF3190",.F.,.F.)
	EndIf
	
	If !Empty(aRetExec)
        For nX := 1 To LEN(aRetExec)
            If aRetExec[nX][1] == cTipo
                Aadd(aCpoAdd, aRetExec[nX][2])
            Endif
        Next nX
    EndIf

	//Define campos das colunas
	//Aadd(aCampos, {/*Campo*/ ,/*Descr*/, /* [1]Tamanho, [2]decimal e [3]tipo*/ , /*Seek?*/})//"Filial do Posto"
	Aadd(aCampos, {"TFF_FILIAL", STR0004, TamSX3("TFF_FILIAL"), .F. })//"Filial do Posto"
	Aadd(aCampos, {"TFF_COD"   , STR0005, TamSX3("TFF_COD")   , .T. })//"Código do Posto"
	Aadd(aCampos, {"B1_COD"    , STR0006, TamSX3("B1_COD")    , .T. })//"Código do Produto"
	Aadd(aCampos, {"B1_DESC"   , STR0007, TamSX3("B1_DESC")   , .T. })//"Descrição"
	Aadd(aCampos, {"TFF_COBCTR", STR0008, TamSX3("TFF_COBCTR"), .T. })//"Cobra em Contr."
	Aadd(aCampos, {"TFF_CONTRT", STR0009, TamSX3("TFF_CONTRT"), .T. })//"Contrato"
	Aadd(aCampos, {"ABS_DESCRI", STR0010, TamSX3("ABS_DESCRI"), .T. })//"Descrição do Posto"
	Aadd(aCampos, {"TFF_PERINI", STR0011, TamSX3("TFF_PERINI"), .F. })//"Período Inicial"
	Aadd(aCampos, {"TFF_PERFIM", STR0012, TamSX3("TFF_PERFIM"), .F. })//"Período Final"
	Aadd(aCampos, {"TFF_QTDVEN", TecTituDes( "TFF_QTDVEN", .F. ), TamSX3("TFF_QTDVEN"), .F. })
	Aadd(aCampos, {"TFF_FUNCAO", STR0013, TamSX3("TFF_FUNCAO"), .T. })//"Codigo da Função"
	Aadd(aCampos, {"RJ_DESC"   , STR0014, TamSX3("RJ_DESC")   , .T. })//"Descrição da Função"
	Aadd(aCampos, {"TFF_TURNO ", STR0015, TamSX3("TFF_TURNO") , .T. })//"Código do Turno"
	Aadd(aCampos, {"R6_DESC"   , STR0016, TamSX3("R6_DESC")   , .T. })//"Descrição do Turno"
	Aadd(aCampos, {"TFF_ESCALA", STR0017, TamSX3("TFF_ESCALA"), .T. })//"Código da Escala"
	Aadd(aCampos, {"TDW_DESC"  , STR0018, TamSX3("TDW_DESC")  , .T. })//"Descrição da Escala"
	If lEnceDT
		Aadd(aCampos, {"TFF_DTENCE", STR0019, TamSX3("TFF_DTENCE"), .T. })// "Data de encerramento"
	EndIf

	For nX := 1  To LEN(aCpoAdd)//Campos adicionais	
		Aadd(aCampos, {aCpoAdd[nX], TecTituDes(aCpoAdd[nX], .T. ) , TamSX3(aCpoAdd[nX]), .T. })
	Next nX

	//Define campos de busca
	For nY := 1 To Len(aCampos)
		If aCampos[nY][4]
			Aadd( aSeek, { aCampos[nY][2] /*Titulo*/, {{""/*lookup*/,aCampos[nY][3][3]/*Tipo*/,aCampos[nY][3][1]/*Tamanho*/,aCampos[nY][3][2]/*Decimal*/,aCampos[nY][2]/*Título do campo*/,/*Máscara*/,aCampos[nY][1]/*Campo*/}} } )//"Código do Posto" # "Código do Posto"
			Aadd( aIndex, aCampos[nY][1] )
		EndIf
	Next nY

	Aadd( aIndex, "TFF_FILIAL")  // adicionado para não ter problema de não encontrar o último índice, em caso de adicionar mais deixe a filial por último

	cQuery := " SELECT TFF.TFF_FILIAL,"
	cQuery +=        " TFF.TFF_COD,"
	cQuery +=        " SB1.B1_COD,"
	cQuery +=        " SB1.B1_DESC,"
	cQuery +=        " TFF.TFF_CONTRT,"
	cQuery +=        " ABS.ABS_DESCRI,"
	cQuery +=        " TFF.TFF_PERINI,"
	cQuery +=        " TFF.TFF_PERFIM,"
	cQuery +=        " TFF.TFF_QTDVEN, "
	cQuery +=        " TFF.TFF_FUNCAO, TFF.TFF_TURNO, TFF.TFF_ESCALA,"
	cQuery +=        " CASE WHEN TFF_COBCTR = '1' THEN ? ELSE ? END TFF_COBCTR,"
	cQuery +=        " CASE WHEN RJ_DESC IS NOT NULL THEN RJ_DESC ELSE ' ' END RJ_DESC,"
	cQuery +=        " CASE WHEN R6_DESC IS NOT NULL THEN R6_DESC ELSE ' ' END R6_DESC,"
	cQuery +=        " CASE WHEN TDW_DESC IS NOT NULL THEN TDW_DESC ELSE ' ' END TDW_DESC,"
	
	If lEnceDT
		cQuery +=    " TFF.TFF_DTENCE"
	EndIf	

	For nX := 1 To Len(aCpoAdd)//Campos adicionais
		If nX == 1
			cQuery += ", "
		Endif
		cQuery += aCpoAdd[nX] 
		If nX != LEN(aCpoAdd)
			cQuery += ", "
		Endif
	Next nX
	cQuery += " FROM ? TFF "
	cQuery +=      " INNER JOIN ? SB1"//Produto
	If lMultFil
		cQuery +=          " ON ?"
	Else
		cQuery +=          " ON SB1.B1_FILIAL = ?"
	EndIf
	cQuery +=                 " AND SB1.B1_COD = TFF.TFF_PRODUT"
	cQuery +=                 " AND SB1.D_E_L_E_T_ = ' ' "
	
	cQuery +=      " LEFT JOIN ? SRJ"//Função
	If lMultFil
		cQuery +=         " ON ?"
	Else
		cQuery +=         " ON SRJ.RJ_FILIAL = ?"
	EndIf
	cQuery +=                " AND SRJ.RJ_FUNCAO = TFF.TFF_FUNCAO "
	cQuery +=                " AND SRJ.D_E_L_E_T_ = ' ' "

	cQuery +=      " LEFT JOIN ? SR6 "//Turno
	If lMultFil
		cQuery +=         " ON ?"
	Else
		cQuery +=         " ON SR6.R6_FILIAL = ?"
	EndIf
	cQuery +=                " AND SR6.R6_TURNO = TFF.TFF_TURNO"  
	cQuery +=                " AND SR6.D_E_L_E_T_ = ' '"

	cQuery +=      " LEFT JOIN ? TDW "//Escala
	If lMultFil
		cQuery +=         " ON ?"
	Else
		cQuery +=         " ON TDW.TDW_FILIAL = ?"
	EndIf
	cQuery +=                " AND TDW.TDW_COD = TFF.TFF_ESCALA"  
	cQuery +=                " AND TDW.D_E_L_E_T_ = ' '"

	cQuery +=      " INNER JOIN ? TFL"//Posto de Trabalho
	If lMultFil
		cQuery +=          " ON ?"
	Else
		cQuery +=          " ON TFL.TFL_FILIAL = ?"
	EndIf
	cQuery +=                 " AND TFL.TFL_CODIGO = TFF.TFF_CODPAI"
	cQuery +=                 " AND TFL.D_E_L_E_T_ = ' '"

	cQuery +=      " INNER JOIN ? TFJ"//Orçamento de Serviços
	If lMultFil
		cQuery +=          " ON TFJ.TFJ_FILIAL = ?"
		cQuery +=             " AND ?"
	Else
		cQuery +=          " ON TFJ.TFJ_FILIAL = ?"
	EndIf
	cQuery +=                 " AND TFJ.TFJ_CODIGO = TFL.TFL_CODPAI"
	cQuery +=                 " AND ( TFJ.TFJ_STATUS = '1' OR TFJ.TFJ_STATUS = '5' )"
	cQuery +=                 " AND ( TFJ.TFJ_CONTRT <> ? OR TFJ.TFJ_RESTEC = '1' )"
	If !Empty(cContrat)
		cQuery +=             " AND TFJ.TFJ_CONTRT = ?"
		cQuery +=             " AND TFJ.TFJ_CONREV = ?"
	EndIf
	cQuery +=                 " AND TFJ.D_E_L_E_T_ = ' '"

	cQuery +=      " INNER JOIN ? ABS"//Local de atendimento

	If lMultFil
		cQuery +=          " ON ?"
	Else
		cQuery +=          " ON ABS.ABS_FILIAL = ?"
	EndIf
	cQuery +=                 " AND TFL.TFL_LOCAL = ABS.ABS_LOCAL"
	cQuery +=                 " AND ABS.D_E_L_E_T_ = ' '"

	cQuery += " WHERE TFF.TFF_GERVAG != '2'"
	If !lMultFil
		cQuery +=   " AND TFF.TFF_FILIAL = ?"
	EndIf

	cQuery +=       " AND ( TFF.TFF_ENCE <> '1'"
	cQuery +=             " OR ( TFF.TFF_ENCE = '1'"
	cQuery +=                  " AND TFF.TFF_DTENCE >= ? ) )"
	
	If cTipo == "POSTO_TFL"
		If !Empty(cCliente)
			cQuery += " AND TFJ.TFJ_CODENT = ?"
			If !Empty(cLoja)
				cQuery += " AND TFJ.TFJ_LOJA = ?"
			EndIf
		EndIf

		If !Empty(cOrcam)
			cQuery += " AND TFJ_CODIGO = ?"
		EndIf

		If !Empty(cLocAt)
			cQuery += " AND TFL.TFL_LOCAL = ?"
		EndIf

		If !Empty(cProd)
			cQuery += " AND TFF.TFF_PRODUT = ?"
		EndIf
	ElseIf cTipo == "POSTO"
		cQuery +=     " AND TFL.TFL_CODIGO = ?"
	ElseIf cTipo == "POSTO_LCA"
		cQuery +=     " AND TFJ.TFJ_RESTEC <> '1'"
		If !Empty(cCodTFL)
			cQuery += " AND TFL.TFL_CODIGO = ?"
		EndIf
	ElseIf cTipo == "POSTO_LGY" .AND. !Empty(cCodTFL)
		cQuery +=     " AND TFL.TFL_CODIGO = ?"
	EndIf

	If TFF->(FieldPos('TFF_MSBLQL')) > 0
		cQuery += " AND TFF.TFF_MSBLQL <> '1'"
	EndIf

	cQuery +=   " AND TFF.D_E_L_E_T_ = ' '"
	
	oQuery := FwExecStatement():New(cQuery)

	oQuery:SetString( nOrdem++, cSim )
	oQuery:SetString( nOrdem++, cNao )

	oQuery:SetUnsafe( nOrdem++, RetSqlName("TFF") )
	
	oQuery:SetUnsafe( nOrdem++, RetSqlName("SB1") )
	If lMultFil
		oQuery:SetUnsafe( nOrdem++, FWJoinFilial("TFF" , "SB1" , "TFF", "SB1", .T.))
	Else
		oQuery:SetString( nOrdem++, xFilial("SB1") )
	EndIf
	
	oQuery:SetUnsafe( nOrdem++, RetSqlName("SRJ") )
	If lMultFil
		oQuery:SetUnsafe( nOrdem++, FWJoinFilial("TFF" , "SRJ" , "TFF", "SRJ", .T.))
	Else
		oQuery:SetString( nOrdem++, xFilial("SRJ") )
	EndIf

	oQuery:SetUnsafe( nOrdem++, RetSqlName("SR6") )
	If lMultFil
		oQuery:SetUnsafe( nOrdem++, FWJoinFilial("TFF" , "SR6" , "TFF", "SR6", .T.))
	Else
		oQuery:SetString( nOrdem++, xFilial("SR6") )
	EndIf

	oQuery:SetUnsafe( nOrdem++, RetSqlName("TDW") )
	If lMultFil
		oQuery:SetUnsafe( nOrdem++, FWJoinFilial("TFF" , "TDW" , "TFF", "TDW", .T.))
	Else
		oQuery:SetString( nOrdem++, xFilial("TDW") )
	EndIf

	oQuery:SetUnsafe( nOrdem++, RetSqlName("TFL") )
	If lMultFil
		oQuery:SetUnsafe( nOrdem++, FWJoinFilial("TFF" , "TFL" , "TFF", "TFL", .T.))
	Else
		oQuery:SetString( nOrdem++, xFilial("TFL") )
	EndIf

	oQuery:SetUnsafe( nOrdem++, RetSqlName("TFJ") )

	If lMultFil
		oQuery:SetString( nOrdem++, cFilTFJ )
		oQuery:SetUnsafe( nOrdem++, FWJoinFilial("TFF" , "TFJ" , "TFF", "TFJ", .T.))
	Else
		oQuery:SetString( nOrdem++, xFilial("TFJ") )
	EndIf
	
	oQuery:SetString( nOrdem++, cSpcContra )

	If !Empty(cContrat)
		oQuery:SetString( nOrdem++, cContrat )
		oQuery:SetString( nOrdem++, cRevis )
	EndIf

	oQuery:SetUnsafe( nOrdem++, RetSqlName("ABS") )
	If lMultFil
		oQuery:SetUnsafe( nOrdem++, FWJoinFilial("ABS" , "TFL" , "ABS", "TFL", .T.))
	Else
		oQuery:SetString( nOrdem++, xFilial("ABS") )
	EndIf

	If !lMultFil
		oQuery:SetString( nOrdem++, xFilial("TFF") )
	EndIf

	oQuery:SetDate( nOrdem++, dDataBase )
	If cTipo == "POSTO_TFL"
		If !Empty(cCliente)
			oQuery:SetString( nOrdem++, cCliente )
			If !Empty(cLoja)
				oQuery:SetString( nOrdem++, cLoja )
			EndIf
		EndIf
		If !Empty(cOrcam)
			oQuery:SetString( nOrdem++, cOrcam )
		EndIf
		If !Empty(cLocAt)
			oQuery:SetString( nOrdem++, cLocAt )
		EndIf
		If !Empty(cProd)
			oQuery:SetString( nOrdem++, cProd )
		EndIf
	ElseIf cTipo == "POSTO"
		oQuery:SetString( nOrdem++, cCodTFL )
	ElseIf cTipo == "POSTO_LCA"
		If !Empty(cCodTFL)
			oQuery:SetString( nOrdem++, cCodTFL )
		EndIf
	ElseIf cTipo == "POSTO_LGY" .AND. !Empty(cCodTFL)
		oQuery:SetString( nOrdem++, cCodTFL )
	EndIf
	
	cQuery := oQuery:GetFixQuery()
	cQuery := ChangeQuery( cQuery )

	oQuery:Destroy()
	FwFreeObj(oQuery)

	If !lAutomato
		cCampoCod := "TFF_COD"

		aColumns := TecDefColuna(aCampos)

    	TecFrmBrw(cTipo/*cAlias*/, aColumns, cTitle, cTitle, cQuery, aSeek, /*cCampoDest*/ , cCampoCod, /*cCodPro*/, @cRetorno, aIndex)

		cRetF3 := cRetorno
	EndIf

Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TecDefColuna
Define e retorna as colunas do browse FW a partir da estrutura de campos informada,
configurando título, tamanho e tratamento de dados conforme o tipo do campo.

@param  aCampos     Array com definição dos campos, títulos, tamanhos e tipos
@return array       Array de objetos FWBrwColumn configurados
@author Breno Gomes
@since  11/02/2026
/*/
//--------------------------------------------------------------------------------------------------------------------
Function TecDefColuna(aCampos)
	Local aColumns := {}
	Local nX       := 0

	For nX := 1 To Len(aCampos)
		AAdd(aColumns,FWBrwColumn():New())
		If aCampos[nX][3][3] == "D"
			aColumns[nX]:SetData( &("{|| STOD(" + aCampos[nX][1] + ")}") )
		Else
			aColumns[nX]:SetData( &("{||" + aCampos[nX][1] + "}") )
		EndIf
		aColumns[nX]:SetTitle(aCampos[nX][2])
		aColumns[nX]:SetSize(aCampos[nX][3][1])
	Next nX

Return aColumns
