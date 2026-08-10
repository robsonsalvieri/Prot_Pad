#INCLUDE "TOTVS.CH"
#INCLUDE "PCPA200REC.CH"
#INCLUDE "FWMVCDEF.CH"

Static _aFiliais := {}

// Estáticas para exibição do resultado da verificação de recursividade.
Static _aLinhas  := {}
Static _aRastro  := {}
Static _cMsgMemo := ""
Static _oBrowse  := Nil
Static _oMsgMemo := Nil
Static slPCPREVATU := FindFunction('PCPREVATU') .AND. SuperGetMv("MV_REVFIL",.F.,.F.)

/*/{Protheus.doc} PCPA200Rec
Função para realização de validações de recursividade (loop) nas estruturas (PCPA200)

@author brunno.costa
@since 26/05/2020
@version P12

@param 01 - cCodPesq    , caracter, código do item para pesquisa
@param 02 - cCodValid   , caracter, código do componente a ser comparado
@param 03 - cMsgEstr    , caracter, (RETORNO POR REFERENCIA) caminho da estrutura que ficará inconsistente
@param 04 - oDadosCommit, objeto  , Json com os dados para commit
@param 05 - cFilSG1		, caracter, filial utilizada no seek da tabela SG1.
@param 06 - lPai        , lógico  , identifica se a validação é para o produto pai. Nesse caso, faz a busca no sentido PAI->COMPON
                                    verificando se o G1_COMP é igual ao cCodValid.
                                    Se não for o produto pai, faz a busca no sentido COMPON->PAI, verificando se o G1_COD é igual ao cCodValid.
@return lExiste		- Indica se o iem é usado na estrutura
/*/

Function PCPA200Rec(cCodPesq, cCodValid, cMsgEstr, oDadosCommit, cFilSG1, lPai)

	Local cAliasTop    := GetNextAlias()
	Local cBanco       := TCGetDB()
	Local cQuery       := ""
	Local cQryUniAll   := ""
	Local cRevCod      := CriaVar('B1_REVATU')
	Local lExiste      := .F.
	Local lProcTemp    := .F.
	Local lQueryOk     := .F.
	Local lRevAut      := SuperGetMv("MV_REVAUT",.F.,.F.)
	Local oTempTable   := criaTmpTRB()
	Local oTempG1      
	Local cDirecao     := " > "
	Local cCplWhere    := ""
	Local cCplOnJoin   := ""
	Local cCpoCompar   := ""
	Local oOldError

	If lRevAut
		dbSelectArea("SB1")
		SB1->(dbSetOrder(1))
		If SB1->(dbSeek(xFilial("SB1")+cCodPesq))
			cRevCod := IIF(slPCPREVATU , PCPREVATU(SB1->B1_COD), SB1->B1_REVATU)
		EndIf

		lProcTemp := .F.
		If cRevCod > '050'
			lProcTemp := .T.
			oTempG1 := criaTmpG1()
		EndIf
	EndIf	

	//Proteção contra SQL Injection
	cCodValid  := StrTran(cCodValid,  "'", "")

	If lPai
		cCplWhere    := " (SG1_Base.G1_COD  = '" + cCodPesq + "')"
		cCplOnJoin   := " ON Qry_Recurs.G1_COMP = SG1_Rec.G1_COD  "
		cCpoCompar   := "G1_COMP"
	Else
		cCplWhere    := " (SG1_Base.G1_COMP = '" + cCodPesq + "')"
		cCplOnJoin   := " ON Qry_Recurs.G1_COD  = SG1_Rec.G1_COMP "
		cCpoCompar   := "G1_COD"
	EndIf

	cQuery := " WITH EstruturaRecursiva(G1_COD, G1_COMP, PathCod)"
	cQuery += " AS ("
	cQuery +=      " SELECT SG1_Base.G1_COD,"
	cQuery +=             " SG1_Base.G1_COMP,"
	cQuery +=             " Cast( Trim(SG1_Base.G1_COD) || '" + cDirecao + "' || Trim(SG1_Base.G1_COMP) AS VarChar(8000) ) AS PathCod"
	cQuery +=      " FROM ( cQryMemFro ) SG1_Base"
	cQuery +=      " WHERE "
	cQuery += cCplWhere

	cQryUniAll +=       " UNION ALL"
	cQryUniAll +=       " SELECT SG1_Rec.G1_COD,"
	cQryUniAll +=              " SG1_Rec.G1_COMP,"
	cQryUniAll +=             " Cast( (Qry_Recurs.PathCod || '" + cDirecao + "' || Trim(SG1_Rec.G1_COMP) ) AS VarChar(8000) ) PathCod"
	
	If lProcTemp
		cQryUniAll +=        " FROM "  +oTempG1:GetRealName()+ " SG1_Rec "
	Else
		cQryUniAll +=        " FROM " + RetSqlName( "SG1" ) + " SG1_Rec "
	EndIf 

	cQryUniAll +=             " INNER JOIN EstruturaRecursiva Qry_Recurs"
	cQryUniAll += cCplOnJoin
	cQryUniAll +=       " WHERE SG1_Rec.D_E_L_E_T_ = ' '"
	cQryUniAll +=         " AND SG1_Rec.G1_FILIAL  = '" + cFilSG1 + "' "

	//Tratamento dados em memoria
	PesMemoria(@cQryUniAll, @cQuery, oTempTable, oDadosCommit, cFilSG1)

	cQuery +=   " )"
	cQuery += " SELECT DISTINCT Resultado.PathCod "
	cQuery +=   " FROM EstruturaRecursiva Resultado"
	cQuery +=  " WHERE Resultado." + cCpoCompar + " = '" + cCodValid + "'"

	//Realiza ajustes da Query para cada banco
	If "POSTGRES" $ cBanco

		//Altera sintaxe da clausula WITH
		cQuery := StrTran(cQuery, 'WITH ', 'WITH recursive ')

		//Corrige Falhas internas de Binário - POSTGRES
		cQuery := StrTran(cQuery, CHR(13), " ")
		cQuery := StrTran(cQuery, CHR(10), " ")
		cQuery := StrTran(cQuery, CHR(09), " ")

	ElseIf "MSSQL" $ cBanco
		//Substitui a função Trim
		cQuery := StrTran(cQuery, "Trim(", "RTrim(")
		//Substitui concatenação || por +
		cQuery := StrTran(cQuery, '||', '+')

	ElseIf ! "ORACLE" $ cBanco
		//Substitui concatenação || por +
		cQuery := StrTran(cQuery, '||', '+')

	EndIf

	If "ORACLE" $ cBanco
		cQuery := StrTran(cQuery,"VarChar(8000)","VarChar(4000)")
	EndIf

	oOldError    := ErrorBlock( {|| .T. } )

	BEGIN SEQUENCE
		dbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAliasTop, .T., .T.)
		lQueryOk := .T.
		If Select(cAliasTop) == 0
			lQueryOk := .F.
		ElseIf !(cAliasTop)->(Eof())
			lExiste  := .T.
			cMsgEstr := AllTrim((cAliasTop)->PathCod)
		EndIf
		(cAliasTop)->(dbCloseArea())

	RECOVER
		lQueryOk := .F.

	END SEQUENCE

	ErrorBlock( oOldError )

	If !lQueryOk
		lExiste  := .T.
		If lPai
			cMsgEstr := AllTrim(cCodPesq)  + cDirecao + "..." + cDirecao + AllTrim(cCodPesq)
		Else
			cMsgEstr := AllTrim(cCodValid) + cDirecao + "..." + cDirecao + AllTrim(cCodValid)
		EndIf
	EndIf

	oTempTable:Delete()
	oTempTable := Nil

	If lProcTemp
		oTempG1:Delete()
		oTempG1:= Nil
	EndIf

Return lExiste

/*/{Protheus.doc} PesMemoria
Realiza ajustes na query de pesquisa para considerar os dados em memoria

@author brunno.costa
@since 26/05/2020
@version P12.1.30

@param 01 - cQryUniAll  , caracter, trecho da query UNION ALL utilizada para copia em MSSQL
@param 02 - cQuery      , caracter, query recursiva de pesquisa original - retornada por referencia
@param 03 - oTempTable  , objeto  , objeto com a tabela temporaria
@param 04 - oDadosCommit, objeto  , Json com os dados para commit
@param 05 - cFilSG1		, caracter, filial utilizada no seek da tabela SG1.
@return oTempTable	- Objeto da tabela temporária.
/*/
Static Function PesMemoria(cQryUniAll, cQuery, oTempTable, oDadosCommit, cFilSG1)

	Local cBanco       := TCGetDB()
	Local nIndAux      := 0
	Local cQryMemFro   := ""
	Local cQryMemCpl   := ""
	Local cRecnos      := ""
	Local oModel       := FWModelActive()
	Local oModelGrAt   := oModel:GetModel("SG1_DETAIL")
	Local cAliasTRB    := oTempTable:GetAlias()
	Local oLines       := oDadosCommit["oLines"]
	Local oFields      := oDadosCommit["oFields"]
	Local oLinDel      := oDadosCommit["oLinDel"]
	Local aLinhasMem   := oLines:GetNames()

	cQryMemFro := " SELECT G1_FILIAL, "
	cQryMemFro +=        " G1_COD, "
	cQryMemFro +=        " G1_REVINI, "
	cQryMemFro +=        " G1_REVFIM, "
	cQryMemFro +=        " G1_COMP, "
	cQryMemFro +=        " G1_TRT, "
	cQryMemFro +=        " G1_INI, "
	cQryMemFro +=        " G1_FIM "
	cQryMemFro +=   " FROM " + RetSqlName("SG1") + " "
	cQryMemFro +=  " WHERE D_E_L_E_T_ = ' ' "
	cQryMemFro +=    " AND G1_FILIAL  = '" + cFilSG1 + "' "
	cQryMemFro += " X_UpdRecnos_X "
	cQryMemFro += " UNION ALL "
	cQryMemFro += " SELECT G1_FILIAL, "
	cQryMemFro +=        " G1_COD, "
	cQryMemFro +=        " '   ' G1_REVINI, "
	cQryMemFro +=        " 'ZZZ' G1_REVFIM, "
	cQryMemFro +=        " G1_COMP, "
	cQryMemFro +=        " G1_TRT, "
	cQryMemFro +=        " G1_INI, "
	cQryMemFro +=        " G1_FIM "
	cQryMemFro +=   " FROM " + oTempTable:GetRealName()

	//Analise dos dados no JSON com os dados para commit - Dados alterados ainda nao gravados no banco
	For nIndAux := 1 to Len(aLinhasMem)
		If oLines[aLinhasMem[nIndAux]] != Nil
			//Tratamento de exclusoes
			If oLinDel[aLinhasMem[nIndAux]]
				If Empty(cRecnos)
					cRecnos := cValToChar(oLines[aLinhasMem[nIndAux]][oFields["NREG"]])
				Else
					cRecnos += ", " + cValToChar(oLines[aLinhasMem[nIndAux]][oFields["NREG"]])
				EndIf
			Else
				//Tratamento de inclusoes
				RecLock(cAliasTRB, .T.)
				(cAliasTRB)->G1_FILIAL := cFilSG1
				(cAliasTRB)->G1_COD    := oLines[aLinhasMem[nIndAux]][oFields["G1_COD"]]
				(cAliasTRB)->G1_REVINI := oLines[aLinhasMem[nIndAux]][oFields["G1_REVINI"]]
				(cAliasTRB)->G1_REVFIM := oLines[aLinhasMem[nIndAux]][oFields["G1_REVFIM"]]
				(cAliasTRB)->G1_INI    := oLines[aLinhasMem[nIndAux]][oFields["G1_INI"]]
				(cAliasTRB)->G1_FIM    := oLines[aLinhasMem[nIndAux]][oFields["G1_FIM"]]
				(cAliasTRB)->G1_COMP   := oLines[aLinhasMem[nIndAux]][oFields["G1_COMP"]]
				(cAliasTRB)->G1_TRT    := oLines[aLinhasMem[nIndAux]][oFields["G1_TRT"]]
				(cAliasTRB)->(MsUnLock())
			EndIf
		EndIf
	Next

	//Analise dos dados na SG1_DETAIL - Dados alterados(ou nao) exibidos na tela
	For nIndAux := 1 to oModelGrAt:Length(.F.)
		If !Empty(oModelGrAt:GetValue("G1_COD", nIndAux)) .AND. (oModelGrAt:IsUpdated(nIndAux) .OR. oModelGrAt:IsDeleted(nIndAux))
			//Tratamento de exclusoes
			If oModelGrAt:IsDeleted(nIndAux)
				If Empty(cRecnos)
					cRecnos := cValToChar(oModelGrAt:GetValue("NREG", nIndAux))
				Else
					cRecnos += ", " + cValToChar(oModelGrAt:GetValue("NREG", nIndAux))
				EndIf
			Else
				//Tratamento de inclusoes
				RecLock(cAliasTRB, .T.)
				(cAliasTRB)->G1_FILIAL := cFilSG1
				(cAliasTRB)->G1_COD    := oModelGrAt:GetValue("G1_COD"   , nIndAux)
				(cAliasTRB)->G1_REVINI := oModelGrAt:GetValue("G1_REVINI", nIndAux)
				(cAliasTRB)->G1_REVFIM := oModelGrAt:GetValue("G1_REVFIM", nIndAux)
				(cAliasTRB)->G1_INI    := oModelGrAt:GetValue("G1_INI"   , nIndAux)
				(cAliasTRB)->G1_FIM    := oModelGrAt:GetValue("G1_FIM"   , nIndAux)
				(cAliasTRB)->G1_COMP   := oModelGrAt:GetValue("G1_COMP"  , nIndAux)
				(cAliasTRB)->G1_TRT    := oModelGrAt:GetValue("G1_TRT"   , nIndAux)
				(cAliasTRB)->(MsUnLock())
			EndIf
		EndIf
	Next

	//SQL SERVER
	If "MSSQL" $ cBanco
		cQryMemCpl := StrTran(cQryUniAll, "FROM " + RetSqlName( "SG1" ) + " SG1_Rec",;
																			"FROM (SELECT G1_FILIAL, G1_COD, '   ' G1_REVINI, 'ZZZ' G1_REVFIM, G1_COMP, G1_TRT, G1_INI, G1_FIM " +;
																			      "FROM " + oTempTable:GetRealName() + ") SG1_Rec")

		cQryMemCpl := StrTran(cQryMemCpl, "WHERE SG1_Rec.D_E_L_E_T_ = ' '", "")
		cQryUniAll +=         " SG1_Rec.X_UpdRecnos_X "
		cQryUniAll +=         " AND SG1_Rec.D_E_L_E_T_ = ' ' "

	//ORACLE, POSTGRES
	Else
		cQryUniAll := StrTran(cQryUniAll, "SG1_Rec.D_E_L_E_T_ = ' '", "1=1")
		cQryUniAll := StrTran(cQryUniAll, "FROM " + RetSqlName( "SG1" ) + " SG1_Rec",;
																			"FROM (SELECT G1_FILIAL, G1_COD, G1_REVINI, G1_REVFIM, G1_COMP, G1_TRT, G1_INI, G1_FIM "+;
																			      " FROM " + RetSqlName( "SG1" ) +;
																						" WHERE D_E_L_E_T_ = ' ' " +;
																						" AND G1_FILIAL = '" + cFilSG1 + "' " +;
																						" X_UpdRecnos_X " +;
																						" UNION " +;
																						" SELECT G1_FILIAL, G1_COD, '   ' G1_REVINI, 'ZZZ' G1_REVFIM, G1_COMP, G1_TRT, G1_INI, G1_FIM " +;
																			      " FROM " + oTempTable:GetRealName() + ") SG1_Rec")
	EndIf

	cQuery     += cQryUniAll + cQryMemCpl
	cQuery     := StrTran(cQuery, "cQryMemFro", cQryMemFro)

	If !Empty(cRecnos)
		cQuery := StrTran(cQuery, "SG1_Rec.X_UpdRecnos_X", " AND SG1_Rec.R_E_C_N_O_ NOT IN (" + cRecnos + ") ")
		cQuery := StrTran(cQuery, "X_UpdRecnos_X", " AND R_E_C_N_O_ NOT IN (" + cRecnos + ") ")
	Else
		cQuery := StrTran(cQuery, "SG1_Rec.X_UpdRecnos_X", "")
		cQuery := StrTran(cQuery, "X_UpdRecnos_X", "")
	EndIf
Return

/*/{Protheus.doc} criaTmpTRB
Cria a tabela temporária conforme a estrutura da tabela SG1

@author brunno.costa
@since 26/05/2020
@version P12.1.30

@return oTempTable	- Objeto da tabela temporária.
/*/
Static Function criaTmpTRB()
	Local oTempTable := FwTemporaryTable():New()

	oTempTable:SetFields(SG1->(dbStruct()))
	oTempTable:AddIndex("01",{"G1_FILIAL","G1_COD","G1_COMP","G1_TRT", "G1_REVINI", "G1_REVFIM"})
	oTempTable:Create()

Return oTempTable

/*/{Protheus.doc} criaTmpG1
Cria a tabela temporária conforme a estrutura da tabela SG1

@author michele.girardi
@since 16/12/2024
@version P12.1.24

@return oTempTable	- Objeto da tabela temporária.
/*/
Static Function criaTmpG1()
	Local aStrut     := {}
	Local cQuery     := ""
	Local oTempTable := FwTemporaryTable():New()

	AADD(aStrut,{"G1_FILIAL" ,GetSX3Cache("G1_FILIAL", "X3_TIPO"),GetSX3Cache("G1_FILIAL","X3_TAMANHO"),0})//Codigo da Filial
	AADD(aStrut,{"G1_COD"    ,GetSX3Cache("G1_COD", "X3_TIPO")   ,GetSX3Cache("G1_COD","X3_TAMANHO"),0})//Codigo do Pai
	AADD(aStrut,{"G1_COMP"   ,GetSX3Cache("G1_COMP", "X3_TIPO")  ,GetSX3Cache("G1_COMP","X3_TAMANHO"),0})//Codigo do Componente

	oTempTable:SetFields(aStrut)
	oTempTable:AddIndex("01",{"G1_COD","G1_COMP"})
	oTempTable:Create()

	cQuery := " INSERT INTO " +oTempTable:GetRealName()+ " (G1_FILIAL, G1_COD, G1_COMP)"
	cQuery += " SELECT DISTINCT  SG1.G1_FILIAL, SG1.G1_COD, SG1.G1_COMP "
	cQuery += "   FROM " + RetSqlName("SG1") + " SG1 "
	cQuery += "  WHERE SG1.G1_FILIAL  = '"+xFilial("SG1")+"' "
	cQuery += "    AND SG1.D_E_L_E_T_ = ' ' "

	MATExecQry(cQuery)

Return oTempTable

/*/{Protheus.doc} modelDef
Função para definir o modelo de dados usado pelo MVC.
@type  Static Function
@author Lucas Fagundes
@since 28/11/2022
@version P12
@return oModel, Object, Modelo de dados definido.
/*/
Static Function modelDef()
	Local oModel    := MPFormModel()      :New('PCPA200Rec' )
	Local oStruCab  := FWFormModelStruct():New()
	Local oStruGrid := montaStru(.T.)

	//Cria campo para o modelo invisível
	oStruCab:AddField("", "", "ARQ", "C", 1, 0, , , {}, .T., , .F., .F., .F., , )

	//MDL_INVI - Modelo "invisível"
	oModel:addFields('MDL_INVI', /*cOwner*/, oStruCab, , , {|| LoadMdlFld()})
	oModel:GetModel("MDL_INVI"):SetDescription(STR0001) // "Verificar Recursividade"
	oModel:GetModel("MDL_INVI"):SetOnlyQuery(.T.)
	
	oModel:addGrid("GRID", "MDL_INVI",oStruGrid, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bLinePost*/, {|| loadFils()})
	oModel:GetModel("GRID"):SetDescription(STR0002) // "Filiais"
	oModel:GetModel("GRID"):SetOptional(.T.)
	oModel:GetModel("GRID"):SetOnlyQuery(.T.)
	oModel:GetModel("GRID"):SetNoInsertLine(.T.)
	oModel:GetModel("GRID"):SetNoDeleteLine(.T.)

	oModel:SetDescription(STR0001) // "Verificar Recursividade"
	oModel:SetPrimaryKey({})

Return oModel

/*/{Protheus.doc} viewDef
Função para definir a view usada pelo MVC.
@type  Static Function
@author Lucas Fagundes
@since 28/11/2022
@version P12
@return oView, Object, View definida.
/*/
Static Function viewDef()
	Local oModel    := FwLoadModel("PCPA200Rec")
	Local oStruGrid := montaStru(.F.)
	Local oView     := FWFormView():New()

	oView:setModel(oModel)
	
	oView:AddOtherObject("VIEW_TXT", {|oPanel| montaTxt(oPanel) })

	oView:addGrid("VIEW_GRID", oStruGrid, "GRID")

	oView:createHorizontalBox("BOX_TXT", 75, , .T.)
	oView:createHorizontalBox("BOX_GRID", 100)

	oView:setOwnerView("VIEW_TXT", "BOX_TXT")
	oView:setOwnerView("VIEW_GRID", "BOX_GRID")

	oView:setAfterViewActivate({|oView| afterView(oView) })
	oView:setFieldAction("CHECK", {|oView| setModify(oView, .F.) })

	oView:addUserButton(STR0003, "", {|oView| marcaTodos(oView)}, /*cToolTip*/, /*nShortCut*/, /*aOptions*/, .T.) // "Marcar/Desmarcar Todos"
	oView:showUpdateMsg(.F.)

Return oView

/*/{Protheus.doc} montaStru
Monta estrutura da grid para o modelo e a view.
@type  Static Function
@author Lucas Fagundes
@since 28/11/2022
@version P12
@param lModel, Logico, Indica que está montando estrutura para o model.
@return oStruct, Object, Objeto com a estrutura da grid para ser usado na view e no model.
/*/
Static Function montaStru(lModel)
	Local oStruct := Nil
	
	If lModel
		oStruct := FWFormModelStruct():New()
		
		oStruct:AddField(""            ,; // [01]  C  Titulo do campo
						""             ,; // [02]  C  ToolTip do campo
						"CHECK"        ,; // [03]  C  Id do Field
						"L"            ,; // [04]  C  Tipo do campo
						6              ,; // [05]  N  Tamanho do campo
						0              ,; // [06]  N  Decimal do campo
						NIL            ,; // [07]  B  Code-block de validação do campo
						NIL            ,; // [08]  B  Code-block de validação When do campo
						{}             ,; // [09]  A  Lista de valores permitido do campo
						.F.            ,; // [10]  L  Indica se o campo tem preenchimento obrigatório
						Nil            ,; // [11]  B  Code-block de inicializacao do campo
						NIL            ,; // [12]  L  Indica se trata-se de um campo chave
						NIL            ,; // [13]  L  Indica se o campo pode receber valor em uma operação de update.
						.T.)              // [14]  L  Indica se o campo é virtual

		oStruct:AddField(STR0004       ,; // [01]  C  Titulo do campo // "Cod. Filial"
						STR0005        ,; // [02]  C  ToolTip do campo // "Código da Filial"
						"FILIAL"       ,; // [03]  C  Id do Field
						"C"            ,; // [04]  C  Tipo do campo
						FwSizeFilial() ,; // [05]  N  Tamanho do campo
						0              ,; // [06]  N  Decimal do campo
						NIL            ,; // [07]  B  Code-block de validação do campo
						NIL            ,; // [08]  B  Code-block de validação When do campo
						{}             ,; // [09]  A  Lista de valores permitido do campo
						.F.            ,; // [10]  L  Indica se o campo tem preenchimento obrigatório
						Nil            ,; // [11]  B  Code-block de inicializacao do campo
						NIL            ,; // [12]  L  Indica se trata-se de um campo chave
						NIL            ,; // [13]  L  Indica se o campo pode receber valor em uma operação de update.
						.T.)              // [14]  L  Indica se o campo é virtual

		oStruct:AddField(STR0006       ,; // [01]  C  Titulo do campo // "Desc. Filial"
						STR0007        ,; // [02]  C  ToolTip do campo // "Descrição da Filial"
						"DESCFIL"      ,; // [03]  C  Id do Field
						"C"            ,; // [04]  C  Tipo do campo
						100            ,; // [05]  N  Tamanho do campo
						0              ,; // [06]  N  Decimal do campo
						NIL            ,; // [07]  B  Code-block de validação do campo
						NIL            ,; // [08]  B  Code-block de validação When do campo
						{}             ,; // [09]  A  Lista de valores permitido do campo
						.F.            ,; // [10]  L  Indica se o campo tem preenchimento obrigatório
						Nil            ,; // [11]  B  Code-block de inicializacao do campo
						NIL            ,; // [12]  L  Indica se trata-se de um campo chave
						NIL            ,; // [13]  L  Indica se o campo pode receber valor em uma operação de update.
						.T.)              // [14]  L  Indica se o campo é virtual
	Else
		oStruct := FWFormViewStruct():New()

		// Estrutura do grid para a view
        oStruct:AddField("CHECK"       ,; // [01]  C   Nome do Campo
						   "00"        ,; // [02]  C   Ordem
                           ""          ,; // [03]  C   Titulo do campo
                           ""          ,; // [04]  C   Descricao do campo
                           NIL         ,; // [05]  A   Array com Help
                           "L"         ,; // [06]  C   Tipo do campo
                           Nil         ,; // [07]  C   Picture
                           NIL         ,; // [08]  B   Bloco de PictTre Var
                           NIL         ,; // [09]  C   Consulta F3
                           .T.         ,; // [10]  L   Indica se o campo é alteravel
                           NIL         ,; // [11]  C   Pasta do campo
                           NIL         ,; // [12]  C   Agrupamento do campo
                           NIL         ,; // [13]  A   Lista de valores permitido do campo (Combo)
                           NIL         ,; // [14]  N   Tamanho maximo da maior opção do combo
                           NIL         ,; // [15]  C   Inicializador de Browse
                           .T.         ,; // [16]  L   Indica se o campo é virtual
                           NIL         ,; // [17]  C   Picture Variavel
                           NIL)           // [18]  L   Indica pulo de linha após o campo

		oStruct:AddField("FILIAL"      ,; // [01]  C   Nome do Campo
						   "01"        ,; // [02]  C   Ordem
                           STR0004     ,; // [03]  C   Titulo do campo // "Cod. Filial"
                           STR0005     ,; // [04]  C   Descricao do campo // "Código da Filial"
                           NIL         ,; // [05]  A   Array com Help
                           "C"         ,; // [06]  C   Tipo do campo
                           Nil         ,; // [07]  C   Picture
                           NIL         ,; // [08]  B   Bloco de PictTre Var
                           NIL         ,; // [09]  C   Consulta F3
                           .F.         ,; // [10]  L   Indica se o campo é alteravel
                           NIL         ,; // [11]  C   Pasta do campo
                           NIL         ,; // [12]  C   Agrupamento do campo
                           NIL         ,; // [13]  A   Lista de valores permitido do campo (Combo)
                           NIL         ,; // [14]  N   Tamanho maximo da maior opção do combo
                           NIL         ,; // [15]  C   Inicializador de Browse
                           .T.         ,; // [16]  L   Indica se o campo é virtual
                           NIL         ,; // [17]  C   Picture Variavel
                           NIL)           // [18]  L   Indica pulo de linha após o campo

		oStruct:AddField("DESCFIL"     ,; // [01]  C   Nome do Campo
						   "02"        ,; // [02]  C   Ordem
                           STR0006     ,; // [03]  C   Titulo do campo // "Desc. Filial"
                           STR0007     ,; // [04]  C   Descricao do campo // "Descrição da Filial"
                           NIL         ,; // [05]  A   Array com Help
                           "C"         ,; // [06]  C   Tipo do campo
                           Nil         ,; // [07]  C   Picture
                           NIL         ,; // [08]  B   Bloco de PictTre Var
                           NIL         ,; // [09]  C   Consulta F3
                           .F.         ,; // [10]  L   Indica se o campo é alteravel
                           NIL         ,; // [11]  C   Pasta do campo
                           NIL         ,; // [12]  C   Agrupamento do campo
                           NIL         ,; // [13]  A   Lista de valores permitido do campo (Combo)
                           NIL         ,; // [14]  N   Tamanho maximo da maior opção do combo
                           NIL         ,; // [15]  C   Inicializador de Browse
                           .T.         ,; // [16]  L   Indica se o campo é virtual
                           NIL         ,; // [17]  C   Picture Variavel
                           NIL)           // [18]  L   Indica pulo de linha após o campo

	EndIf

Return oStruct

/*/{Protheus.doc} LoadMdlFld
Carrega o modelo invisivel.
@type  Static Function
@author Lucas Fagundes
@since 28/11/2022
@version P12
@return aLoad, Array, Array com os dados para o modelo.
/*/
Static Function LoadMdlFld()
	Local aLoad := {}
	
	aAdd(aLoad, {"A"}) //Dados
	aAdd(aLoad, 1    ) //Recno

Return aLoad

/*/{Protheus.doc} loadFils
Carrega o modelo da grid com as filiais.
@type  Static Function
@author Lucas Fagundes
@since 28/11/2022
@version P12
@return _aFiliais, Array, Array com as filiais que serão inseridas na grid.
/*/
Static Function loadFils()
	Local cAlias   := GetNextAlias()

	If Empty(_aFiliais)
		BeginSql alias cAlias
			SELECT DISTINCT G1_FILIAL
			FROM %table:SG1% SG1
			WHERE SG1.%notDel%
			ORDER BY SG1.G1_FILIAL
		EndSql
		
		While (cAlias)->(!Eof())
			aAdd(_aFiliais, {0, {.F., (cAlias)->(G1_FILIAL), FWFilialName(cEmpAnt, (cAlias)->(G1_FILIAL), 1)}})
			(cAlias)->(dbSkip())
		End
		(cAlias)->(dbCloseArea())
	EndIf

Return _aFiliais

/*/{Protheus.doc} marcaTodos
Seta como verdadeiro ou falso o campo CHECK em todas as linhas da grid.
@type  Static Function
@author Lucas Fagundes
@since 01/12/2022
@version P12
@param oView, Object, Objeto view do MVC.
@return Nil
/*/
Static Function marcaTodos(oView)
	Local oModel     := oView:GetModel("GRID")
	Local lCheck     := oModel:GetValue("CHECK", 1)
	Local nLinha     := 0
	Local nLinhaAtu  := oModel:GetLine()
	Local nTotLinhas := oModel:Length()
	Local oViewGrid  := oView:GetSubView("GRID")

	For nLinha := 1 To nTotLinhas
		oModel:GoLine(nLinha)
		oModel:SetValue("CHECK", !lCheck)
	Next

	oModel:GoLine(nLinhaAtu)
	oViewGrid:Refresh()

	setModify(oView, .F.)
Return Nil


/*/{Protheus.doc} montaTxt
Adiciona o texto no painel da view.
@type  Static Function
@author Lucas Fagundes
@since 28/11/2022
@version P12
@param oPanel, Object, Objeto TPanel que será adicionado os textos.
@return Nil
/*/
Static Function montaTxt(oPanel)
	Local cTxt  := ""
	Local oFont := Nil
	Local oSay  := Nil

	oFont := TFont():New('Arial', /*uPar2*/, 18, /*uPar4*/, .F., /*uPar6*/, /*uPar7*/, /*uPar8*/, /*uPar9*/, .F., .F.)

	cTxt := STR0008 // "Bem-vindo à função de verificação de recursividade nas estruturas."
	cTxt += Chr(13)+Chr(10)+Chr(13)+Chr(10)
	cTxt += STR0009 // "Para iniciar, selecione as filiais que terão as estruturas verificadas."


	oSay := TSay():New(5, 5, {|| cTxt}, oPanel, /*cPicture*/, oFont, , , , .T., /*nClrText*/, /*nClrBack*/,;
	                   oPanel:nClientWidth/2, oPanel:nClientHeight/2)

	oSay:lWordWrap = .T.

Return Nil

/*/{Protheus.doc} validaRec
Valida se há recursividade nas filiais selecionadas na tela.
@type  Static Function
@author Lucas Fagundes
@since 29/11/2022
@version P12
@param oModel, Object, Objeto model do MVC.
@return Nil
/*/
Static Function validaRec(oModel)
	Local aEstsRec   := {}
	Local aFilsRec   := {}
	Local cFilAux    := ""
	Local nIndex     := 0
	Local nIndexFil  := 0
	Local nTotal     := 0
	Local nTotFilRec := 0
	Local oJson      := JsonObject():New()
	
	oJson["items"              ] := JsonObject():New()
	oJson["produtosRecursivos" ] := JsonObject():New()

	incProc(STR0034) // "Buscando Filiais com Recursividade"
	
	nTotal := oModel:length()
	For nIndex := 1 To nTotal
		
		If !oModel:GetValue("CHECK", nIndex)
			Loop
		EndIf

		cFilAux := oModel:GetValue("FILIAL", nIndex)
		If existeRec(cFilAux, "")
			aAdd(aFilsRec, cFilAux)
		EndIf
	Next

	nTotFilRec := Len(aFilsRec)
	If nTotFilRec > 0
		setTotal(aFilsRec)

		For nIndexFil := 1 To nTotFilRec
			cFilAux := aFilsRec[nIndexFil]
			aEstsRec := buscaEsts(cFilAux)

			nTotal := Len(aEstsRec)
			If nTotal > 0
				oJson["produtosRecursivos"][cFilAux] := JsonObject():New()

				incProc(STR0010 + cFilAux + STR0035) // "Verificando filial " " - Verificando Recursividade."
				
				For nIndex := 1 To nTotal
					buscaRecur(aEstsRec[nIndex], Nil, Nil, cFilAux, @oJson, .F.)
				Next
			EndIf
		Next

		incProc(STR0011) // "Montando resultados..."
		montaResul(oJson)
		
		exibeResul()
	Else
		MsgInfo(STR0022) // "Não existe estrutura recursiva na filial selecionada."
	EndIf

	FwFreeObj(oJson)
	aSize(aEstsRec, 0)
Return Nil

/*/{Protheus.doc} montaProc
Monta a tela com a barra de processamento.
@type  Static Function
@author Lucas Fagundes
@since 29/11/2022
@version P12
@param oModel, Object, Objeto model do MVC.
@return lRet, Logico, Retorna se iniciou ou não o processamento.
/*/
Static Function procRec(oModel)
	Local lRet := .F.

	If MsgYesNo(STR0031 + Chr(13)+Chr(10)+Chr(13)+Chr(10) + STR0036, STR0030) // "Deseja iniciar a verificação agora?" "Este processo pode demorar." "Verificação de Recursividade"
		lRet := .T.

		processa({|| validaRec(oModel)}, STR0012, STR0014, .F.) // "Verificando recursividades" "Por favor, aguarde!"
	EndIf

Return lRet

/*/{Protheus.doc} existeRec
Verifica se há recursividade na filial recebida.
@type  Static Function
@author Lucas Fagundes
@since 29/11/2022
@version P12
@param 01 cCodFil , Caracter, Código da filial que irá verificar se há recursividade.
@param 02 cProduto, Caracter, Código do produto para verificar estrutura especifica.
@return lExiste, Logico, Retorna se há ou não recursividade.
/*/
Static Function existeRec(cCodFil, cProduto)
	Local bErrBlock := ErrorBlock( {|oErro| P200ErrRec(oErro) } )
	Local cAlias    := GetNextAlias()
	Local cBanco    := TCGetDB()
	Local lExiste   := .F.
	Local oTempG1 
	
	Private lError  := .F.

	If "POSTGRES" $ cBanco
		cQuery := "WITH recursive RastroRecursivo(G1_COD, G1_COMP)"
		cQuery +=  " AS ("
		cQuery +=       " SELECT SG1_Base.G1_COD,"
		cQuery +=              " SG1_Base.G1_COMP,"
		cQuery +=         " CONCAT(CONCAT(';', CAST(SG1_BASE.R_E_C_N_O_ AS VARCHAR(11))), ' ; ') AS RECS, "
		cQuery +=         " FALSE recursivo "
		cQuery +=         " FROM " + RetSqlName("SG1") + " SG1_Base"
		cQuery +=        " WHERE SG1_Base.D_E_L_E_T_ = ' '"
		cQuery +=          " AND SG1_Base.G1_FILIAL  = '" + xFilial("SG1", cCodFil) + "'"
	
		If !Empty(cProduto)
			cQuery +=      " AND SG1_Base.G1_COD  = '" + cProduto + "'"
		EndIf

		cQuery +=        " UNION ALL"
		cQuery +=       " SELECT SG1_Rec.G1_COD,"
		cQuery +=              " SG1_Rec.G1_COMP,"
		cQuery +=              " CONCAT(CONCAT(QRY_RECURS.RECS, CAST(SG1_REC.R_E_C_N_O_ AS VARCHAR(11))), ';') AS RECS, "
        cQuery +=              " CASE "
		cQuery +=              "    WHEN POSITION(CONCAT(CONCAT(';', CAST(SG1_REC.R_E_C_N_O_ AS VARCHAR(11))), ';') IN QRY_RECURS.RECS) > 0 THEN TRUE "
		cQuery +=              "    ELSE FALSE "
		cQuery +=              " END recursivo "
		cQuery +=         " FROM " + RetSqlName("SG1") + " SG1_Rec"
		cQuery +=        " INNER JOIN RastroRecursivo Qry_Recurs"
		cQuery +=           " ON Qry_Recurs.G1_COMP = SG1_Rec.G1_COD"
		cQuery +=          " AND Qry_Recurs.recursivo = FALSE "
		cQuery +=        " WHERE SG1_Rec.D_E_L_E_T_ = ' '"
		cQuery +=          " AND SG1_Rec.G1_FILIAL  = '" + xFilial("SG1", cCodFil) + "')"
		cQuery +=  " SELECT COUNT(*) TOTAL "
		cQuery +=    " FROM RastroRecursivo Resultad "
		cQuery +=   " WHERE recursivo = TRUE "

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T., .T.)

		If !(cAlias)->(Eof())
			If (cAlias)->TOTAL > 0
				lExiste  := .T.
			Else
				lExiste  := .F.
			EndIf
		EndIf

		(cAlias)->(dbCloseArea())
	Else
		oTempG1 := criaTmpG1()

		cQuery := "WITH RastroRecursivo(G1_COD, G1_COMP)"
		cQuery +=  " AS ("
		cQuery +=       " SELECT SG1_Base.G1_COD,"
		cQuery +=              " SG1_Base.G1_COMP"
		//cQuery +=         " FROM " + RetSqlName("SG1") + " SG1_Base"
		cQuery +=        " FROM "  +oTempG1:GetRealName()+ " SG1_Base "
		cQuery +=        " WHERE SG1_Base.D_E_L_E_T_ = ' '"
		cQuery +=          " AND SG1_Base.G1_FILIAL  = '" + xFilial("SG1", cCodFil) + "'"
	
		If !Empty(cProduto)
			cQuery +=      " AND SG1_Base.G1_COD  = '" + cProduto + "'"
		EndIf

		cQuery +=        " UNION ALL"
		cQuery +=       " SELECT SG1_Rec.G1_COD,"
		cQuery +=              " SG1_Rec.G1_COMP"
		//cQuery +=         " FROM " + RetSqlName("SG1") + " SG1_Rec"
		cQuery +=        " FROM "  +oTempG1:GetRealName()+ " SG1_Rec "
		cQuery +=        " INNER JOIN RastroRecursivo Qry_Recurs"
		cQuery +=           " ON Qry_Recurs.G1_COMP = SG1_Rec.G1_COD"
		cQuery +=        " WHERE SG1_Rec.D_E_L_E_T_ = ' '"
		cQuery +=          " AND SG1_Rec.G1_FILIAL  = '" + xFilial("SG1", cCodFil) + "')"
		cQuery +=  " SELECT COUNT(*) TOTAL "
		cQuery +=    " FROM RastroRecursivo Resultad"

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.F.,.F.)

		ErrorBlock(bErrBlock)

		If lError
			lExiste := .T.
		Else
			lExiste := .F.
			(cAlias)->(dbCloseArea())
		EndIf

		oTempG1:Delete()
		oTempG1:= Nil
	EndIf	

Return lExiste

/*/{Protheus.doc} P200ErrRec
Função executada pelo ErrorBlock para setar a variavel com erro.
@type  Function
@author Lucas Fagundes
@since 29/11/2022
@version P12
@param oErro, Object, Objeto de erro
@return .T.
/*/
Function P200ErrRec(oErro)
	lError := .T.
Return .T.

/*/{Protheus.doc} buscaRecur
Percorre a tabela SG1 em busca das estruturas que estão com recursividade.
@type  Static Function
@author Lucas Fagundes
@since 29/11/2022
@version P12
@param 01 cProduto  , Caracter, Produto pai da estrutura.
@param 02 oJsEst    , Object  , Objeto json com os níveis anteriores da estrutura.
@param 03 oJsEstErro, Object  , Objeto json com os produtos que tem recursividade.
@param 04 cCodFil   , Caracter, Código da filial que irá buscar as estruturas recursivas.
@param 05 oJsRet    , Object  , Objeto json que retorna por referencia as estruturas com recursividade.
@param 06 lRecursiva, Logico  , Indica se é uma chamada recursiva.
@return lEncontrou, Logico, Retorna se encontrou recursividade ou não.
/*/
Static Function buscaRecur(cProduto, oJsEst, oJsEstErro, cCodFil, oJsRet, lRecursiva)
	Local aAreaSG1   := {}
	Local aEstrErro  := {}
	Local cChave     := ""
	Local cCodComp   := ""
	Local cCodPai    := ""
	Local lEncontrou := .F.

	Default oJsEst     := JsonObject():New()
	Default oJsEstErro := JsonObject():New()

	SG1->(dbSetOrder(1))
	SG1->(dbSeek(xFilial("SG1", cCodFil) + cProduto))

	While SG1->(!Eof()) .And. SG1->G1_FILIAL == xFilial("SG1", cCodFil)
		cCodPai  := SG1->G1_COD
		cCodComp := SG1->G1_COMP

		If cCodPai <> cProduto
			Exit
		EndIf

		oJsEst[cCodPai] := .T.

		If oJsEst:HasProperty(cCodComp) .Or. oJsRet["produtosRecursivos"][cCodFil]:HasProperty(cCodComp) .Or. cCodPai == cCodComp 
			oJsEstErro[cCodComp] := .T.
			lEncontrou := .T.

			If !oJsRet["produtosRecursivos"][cCodFil]:HasProperty(cCodComp)
				oJsRet["produtosRecursivos"][cCodFil][cCodComp] := .T.
			EndIf

			If lRecursiva
				Exit
			EndIf
		EndIf

		aAreaSG1 := SG1->(GetArea())
		lEncontrou := BuscaRecur(cCodComp, @oJsEst, @oJsEstErro, cCodFil, @oJsRet, .T.)
		RestArea(aAreaSG1)

		If lEncontrou
			If !lRecursiva
				aEstrErro := oJsEstErro:GetNames()

				If oJsRet["produtosRecursivos"][cCodFil][aEstrErro[Len(aEstrErro)]]
					cChave := xFilial("SG1", cCodFil)+cCodPai
					oJsRet["items"][cChave] := JsonObject():New()
					
					oJsRet["items"][cChave]["filial" ] := xFilial("SG1", cCodFil)
					oJsRet["items"][cChave]["produto"] := cCodPai
					oJsRet["items"][cChave]["rastro" ] := oJsEst:GetNames()

					aAdd(oJsRet["items"][cChave]["rastro"], aEstrErro[Len(aEstrErro)])

					oJsRet["produtosRecursivos"][cCodFil][aEstrErro[Len(aEstrErro)]] := .F.

					FwFreeObj(oJsEst)
					oJsEst := JsonObject():New()
				EndIf
				
				aSize(aEstrErro, 0)
			Else
				Exit
			EndIf
		Else
			oJsEst:DelName(cCodPai)
		EndIf

		SG1->(dbSkip())
	End

	If !lRecursiva
		FwFreeObj(oJsEst)
		FwFreeObj(oJsEstErro)
	EndIf

Return lEncontrou

/*/{Protheus.doc} exibeResul
Monta tela de resultado com as estruturas recursivas.
@type  Static Function
@author Lucas Fagundes
@since 29/11/2022
@version P12
@return Nil
/*/
Static Function exibeResul()
	Local nTamB1Cod  := GetSx3Cache("B1_COD", "X3_TAMANHO")
	Local nTamB1Desc := GetSx3Cache("B1_DESC", "X3_TAMANHO")
	Local nTamFil    := FwSizeFilial()
	Local oPanelInf  := Nil
	Local oPanelSup  := Nil

	DEFINE DIALOG oDlgResult TITLE STR0015 FROM 0,0 TO 520,480 PIXEL // "Resultado"

	oPanelSup := TPanel():New(0, 0, /*cText*/, oDlgResult, /*oFont*/, /*lCentered*/, /*uParam7*/, /*nClrText*/, /*nClrBack*/, 100, 230, .F., .T.)
	oPanelSup:Align := CONTROL_ALIGN_TOP

	_oBrowse := TWBrowse():New(01, 01, 240, 140, /*bLine*/, {STR0016, STR0017, STR0018}, {nTamFil, nTamB1Cod, nTamB1Desc},; // "Filial" "Produto" "Descrição"
	oPanelSup, /*cField*/, /*uValue1*/, /*uValue2*/, /*bChange*/,{||}, /*bRClick*/, /*oFont*/, /*oCursor*/, /*nClrFore*/,;
	 /*nClrBack*/, /*cMsg*/, .F., /*cAlias*/, .T., /*bWhen*/, .F., /*bValid*/, .T., .T.)

	_oBrowse:SetArray(_aLinhas)
	_oBrowse:bLine := {|| { _aLinhas[_oBrowse:nAt,1], _aLinhas[_oBrowse:nAt,2], _aLinhas[_oBrowse:nAt,3]}}
	_oBrowse:bChange := { || alteraRastro(_oBrowse:nAt) }

	oPanelInf := TPanel():New(130, 0, /*cText*/, oDlgResult, /*oFont*/, /*lCentered*/, /*uParam7*/, /*nClrText*/, /*nClrBack*/, 400, 110, .F., .F.)

	TSay():New(05, 05, {|| STR0019 }, oPanelInf, , , , , , .T., , , 100, 20) // "Caminho Estrutura:"

	_oMsgMemo := TSimpleEditor():New( 15, 05, oPanelInf, 230, 95, "", .T., {|u| If(PCount()==0, _cMsgMemo, _cMsgMemo:=u)}, /*oFont*/, .T., /*bWhen*/, /*bValid*/, /*cLabelText*/, /*nLabelPos*/, /*oLabelFont*/, /*nLabelColor*/, /*bChanged*/)

	TButton():New( 245, 150, STR0020, oDlgResult, {|| exportaRec() }, 40, 10, /*uParam8*/, /*oFont*/, /*uParam10*/, .T., /*uParam12*/, /*uParam13*/, /*uParam14*/, /*bWhen*/, /*uParam16*/, /*uParam17*/) // "Exportar"
	TButton():New( 245, 195, STR0021, oDlgResult, {|| oDlgResult:End() }, 40, 10, /*uParam8*/, /*oFont*/, /*uParam10*/, .T., /*uParam12*/, /*uParam13*/, /*uParam14*/, /*bWhen*/, /*uParam16*/, /*uParam17*/) // "Fechar"

	ACTIVATE MSDIALOG oDlgResult CENTERED

	FwFreeArray(_aLinhas)
	aSize(_aRastro, 0)

Return Nil

/*/{Protheus.doc} montaResul
Preenche o array a _aLinhas com as linha que serão exibidas na tela de resultado.
@type  Static Function
@author Lucas Fagundes
@since 30/11/2022
@version P12
@param oDados, Object, Objeto json com os dados para montagem dos resultado.
@return Nil
/*/
Static Function montaResul(oDados)
	Local aChaves  := {}
	Local cDescAux := ""
	Local cFilAux  := ""
	Local cProdAux := ""
	Local nIndChv  := 0
	Local nTotal   := 0

	_aLinhas := {}
	_aRastro := {}

	aChaves := oDados["items"]:getNames()
	nTotal := Len(aChaves)

	SB1->(DbSetOrder(1))
	For nIndChv := 1 To nTotal
		cFilAux  := oDados["items"][aChaves[nIndChv]]["filial"]
		cProdAux := oDados["items"][aChaves[nIndChv]]["produto"]
		cDescAux := ""

		If SB1->(DbSeek(xFilial("SB1", cFilAux)+cProdAux))
			cDescAux := SB1->B1_DESC
		EndIf

		aAdd(_aLinhas, {cFilAux, cProdAux, cDescAux})
		montaRastro(oDados["items"][aChaves[nIndChv]]["rastro"])
	Next

	aSize(aChaves, 0)
Return Nil

/*/{Protheus.doc} montaRastro
Preenche o array _aRastro com os caminhos das estruturas que estão com recursividade.
@type  Static Function
@author Lucas Fagundes
@since 30/11/2022
@version P12
@param aRastro, Array, Array com os produtos que compoem a estrutura com recursividade.
@return Nil
/*/
Static Function montaRastro(aRastro)
	Local cProdAux := ""
	Local cProdRec := ""
	Local cRastro  := ""
	Local nIndex   := 0
	Local nTotal   := Len(aRastro)

	cProdRec := Trim(aRastro[nTotal])
	For nIndex := 1 To nTotal	
		cProdAux := Trim(aRastro[nIndex])

		If cProdAux == cProdRec
			cProdAux := "<b><font color=red>" + cProdAux + "</font></b>"
		EndIf

		cRastro += cProdAux

		If nIndex <> nTotal
			cRastro += " > "
		EndIf
	Next

	aAdd(_aRastro, cRastro)

Return Nil

/*/{Protheus.doc} alteraRastro
Altera o campo com o caminho da estrutura de acordo com o registro posicionado na tela de resultados.
@type  Static Function
@author Lucas Fagundes
@since 30/11/2022
@version P12
@param nPos, Numerico, Posição do registro posicionado na grid de resultados.
@return Nil
/*/
Static Function alteraRastro(nPos)
	
	_cMsgMemo := _aRastro[nPos]

	SetFocus(_oMsgMemo:HWND)
	SetFocus(_oBrowse:HWND)

Return Nil

/*/{Protheus.doc} exportaRec
Exporta os resultados em formato TXT.
@type  Static Function
@author Lucas Fagundes
@since 30/11/2022
@version P12
@return Nil
/*/
Static Function exportaRec()
	Local cDir    := ""
	Local cLinha  := ""
	Local nHandle := -1
	Local nIndex  := 0
	Local nTotal  := Len(_aLinhas)

	cDir := cGetFile("", STR0023, /*nMascpadrao*/, /*cDirinicial*/, .F.,; // "Exportar Recursividades"
	 nOr(GETF_RETDIRECTORY,  GETF_LOCALHARD), /*lArvore*/, /*lKeepCase*/)

	If !Empty(cDir)
		cDir += "estRec.txt"

		nHandle := FCreate(cDir, Nil, Nil, .F.)

		If nHandle == -1		
			Help(' ', 1,"FError" + CValToChar(FError()),,;
			STR0024 + cValtoChar(FError()), 1, 1, , , , , , {STR0025}) // "Erro na exportação das recursividades. FError: " "Consulte o suporte para mais informações."
		Else
			For nIndex := 1 To nTotal
				cLinha := STR0027 + Trim(_aLinhas[nIndex][1]) + " " + STR0026 + Trim(_aLinhas[nIndex][2]) +; // "Filial: " "Produto: " 
				 CHR(10) + STR0028 + _aRastro[nIndex] + CHR(10) + CHR(10) // "Caminho na Estrutura: "

				cLinha := StrTran(cLinha, "<b>"             , "")
				cLinha := StrTran(cLinha, "</b>"            , "")
				cLinha := StrTran(cLinha, "<font color=red>", "")
				cLinha := StrTran(cLinha, "</font>"         , "")
				
				FWrite(nHandle, cLinha)
			Next
			FClose(nHandle)

			MsgInfo(STR0029) // "Exportado com sucesso!"
		EndIf
	EndIf

Return Nil

/*/{Protheus.doc} P200Recur
Função responsavel pela abertura da tela de recursividade.
@type  Function
@author Lucas Fagundes
@since 14/12/2022
@version P12
@return Nil
/*/
Function P200Recur()
	Local aButtons   := {}
	Local oModel     := Nil
	Local oModelGrid := Nil

	loadFils()

	If Len(_aFiliais) > 1
		aButtons := {{.F., Nil}, {.F., Nil}, {.F., Nil}, {.F., Nil}, {.F., Nil}, {.F., Nil}, {.T., Nil},;
		             {.T., Nil}, {.F., Nil}, {.F., Nil}, {.F., Nil}, {.F., Nil}, {.F., Nil}, {.F., Nil}}

		FWExecView(STR0030, "PCPA200Rec", MODEL_OPERATION_UPDATE, /*oDlg*/, {|| .T. }, {|oModel| buttonOk(oModel)},; // "Verificação de Recursividade"
			65, aButtons, {|oView| setModify(oView, .F.)} , /*cOperatId*/, /*cToolBar*/, /*oModel*/)
		
		FwFreeArray(aButtons)
	Else
		oModel     := FwLoadModel("PCPA200Rec")
		oModelGrid := oModel:GetModel("GRID")

		oModel:SetOperation(MODEL_OPERATION_UPDATE)
		oModel:Activate()

		oModelGrid:SetValue("CHECK"  , .T.)

		procRec(oModelGrid)

		oModel:Destroy()
	EndIf

Return Nil

/*/{Protheus.doc} setModify
Atualiza o atributo lModify do model e da view.
@type  Static Function
@author Lucas Fagundes
@since 15/12/2022
@version P12
@param 01 oView, Object, Objeto da View;
@param 02 lMod , Logico, Valor que será setada no atributo.
@return .T.
/*/
Static Function setModify(oView, lMod)
	Local oModel := oView:GetModel()

	oModel:lModify := lMod
	oView:lModify  := lMod

Return .T.

/*/{Protheus.doc} afterView
Função executada após ativar a view.
@type  Static Function
@author Lucas Fagundes
@since 15/12/2022
@version P12
@param oView, Object, Objeto da View.
@return Nil
/*/
Static Function afterView(oView)

	//Seta funcionalidade de marcar/desmarcar todos clicando no cabeçalho
	oView:GetSubView("GRID"):oBrowse:aColumns[1]:bHeaderClick := {|| marcaTodos(oView) }

	//Seta o modelo como não alterado
	SetModify(oView, .F.)

Return Nil

/*/{Protheus.doc} buttonOK
Valida se houve alterações no modelo e inicia a verificação de recursividades.
@type  Static Function
@author Lucas Fagundes
@since 15/12/2022
@version P12
@param oModel, Object, Modelo com os dados da view.
@return lFecha, Logico, Indica se fecha ou não a tela.
/*/
Static Function buttonOK(oModel)
	Local lFecha  := .F.
	Local oView      := FwViewActive()
	Local oModelGrid := oModel:GetModel("GRID")

	lFecha := oModelGrid:seekLine({{"CHECK", .T.}}, .F., .F.)

	If lFecha
		setModify(oView, .T.)
		lFecha := procRec(oModelGrid)

		If !lFecha
			setModify(oView, .F.)
		EndIf
	Else
		Help(' ', 1, "P200NOFIL",, STR0032,; // "Nenhuma filial foi selecionada."
		 1, 1, , , , , , {STR0033}) // "Para continuar selecione uma filial."
	EndIf

Return lFecha

/*/{Protheus.doc} buscaEsts
Percorre as estruturas de uma filial e retorna as que contém recursividade.
@type  Static Function
@author Lucas Fagundes
@since 16/12/2022
@version P12
@param cCodFil, Caracater, Código da filial que irá buscar as estruturas.
@return aEstsRecur, Array, Array com os produtos com estrutura recursiva.
/*/
Static Function buscaEsts(cCodFil)
	Local aEstsRecur := {}
	Local cAlias     := GetNextAlias()
	Local cProduto   := ""
	Local cQuery     := ""
	Local nCount     := 0
	Local nTotal     := 0

	cQuery := queryRegs(cCodFil, .T.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.F.,.F.)

	If (cAlias)->(!Eof())
		nTotal := (cAlias)->TOTAL
	EndIf
	(cAlias)->(dbCloseArea())

	If nTotal > 0
		cQuery := queryRegs(cCodFil, .F.)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.F.,.F.)

		While (cAlias)->(!Eof())
			nCount++
			incProc(STR0010 + cCodFil + STR0037 + cValToChar(Round((nCount / nTotal) * 100, 2)) + "% ") // "Verificando filial " " - Buscando Estruturas "
			
			cProduto := (cAlias)->G1_COD
			If existeRec(cCodFil, cProduto)
				aAdd(aEstsRecur, cProduto)
			EndIf

			(cAlias)->(dbSkip())
		End
		(cAlias)->(dbCloseArea())

	EndIf

Return aEstsRecur

/*/{Protheus.doc} queryRegs
Retorna a query para buscar os registros.
@type  Static Function
@author Lucas Fagundes
@since 19/12/2022
@version P12
@param xCodFil, Array/Caracter, Código da filial para o filtro;
@param lCount , Logico        , Indica que deve retornar a query com count.
@return Nil
/*/
Static Function queryRegs(xCodFil, lCount)
	Local cCondFil := ""
	Local cQuery   := ""
	Local nIndex   := 0
	Local nTotal   := 0

	If valType(xCodFil) == "A"
		nTotal   := Len(xCodFil)
		cCondFil := " IN ( "
		
		For nIndex := 1 To nTotal
			cCondFil += " '" + xFilial("SG1", xCodFil[nIndex]) + "'"

			If nIndex < nTotal
				cCondFil += ", "
			EndIf
		Next

		cCondFil += " ) "
	Else
		cCondFil := " = '" + xFilial("SG1", xCodFil) + "' "
	EndIf

	cQuery := " SELECT DISTINCT SG1a.G1_FILIAL, SG1a.G1_COD "
	cQuery +=   " FROM " + RetSqlName("SG1") + " SG1a "
	cQuery +=  " WHERE SG1a.G1_FILIAL " + cCondFil
	cQuery +=    " AND SG1a.D_E_L_E_T_ = ' ' "
	cQuery +=    " AND EXISTS (SELECT 1 "
	cQuery +=                  " FROM " + RetSqlName("SG1") + " SG1b "
	cQuery +=                 " WHERE SG1b.G1_FILIAL " + cCondFil
	cQuery +=                   " AND SG1b.D_E_L_E_T_ = ' ' "
	cQuery +=                   " AND SG1b.G1_COMP = SG1a.G1_COD) "
	cQuery +=    " AND EXISTS (SELECT 1 "
	cQuery +=                  " FROM " + RetSqlName("SG1") + " SG1c "
	cQuery +=                 " WHERE SG1c.G1_FILIAL " + cCondFil
	cQuery +=                   " AND SG1c.D_E_L_E_T_ = ' ' "
	cQuery +=                   " AND SG1c.G1_COD = SG1a.G1_COMP) "
	cQuery +=    " AND EXISTS (SELECT 1 "
	cQuery +=                  " FROM " + RetSqlName("SG1") + " SG1d "
	cQuery +=                 " WHERE SG1d.G1_FILIAL " + cCondFil
	cQuery +=                   " AND SG1d.D_E_L_E_T_ = ' ' "
	cQuery +=                   " AND SG1d.G1_COD = SG1a.G1_COD) "

	If lCount
		cQuery := " SELECT COUNT(CONT.G1_COD) TOTAL FROM (" + cQuery + ") CONT "
	EndIf

Return cQuery

/*/{Protheus.doc} setTotal
Seta o total da barra de progresso com a quantidade de registros que serão verificados.
@type  Static Function
@author Lucas Fagundes
@since 19/12/2022
@version P12
@param aFiliais, Array, Array com as filiais que possuem estruturas com recursividade.
@return Nil
/*/
Static Function setTotal(aFiliais)
	Local cAlias  := getNextAlias()
	Local cQuery  := ""
	Local nTamFil := Len(aFiliais)
	Local nTotal  := 0
	
	cQuery := queryRegs(aFiliais, .T.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.F.,.F.)

	If (cAlias)->(!Eof())
		nTotal := (cAlias)->TOTAL
	EndIf
	(cAlias)->(dbCloseArea())

	nTotal += (nTamFil * 2) + 1

	procRegua(nTotal)
Return Nil
