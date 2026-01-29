#INCLUDE "Protheus.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "JURA317.CH"

PUBLISH MODEL REST NAME JURA317 SOURCE JURA317 RESOURCE OBJECT JurModRest 

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA317
Modelo de inclusão de subsídios

@since 03/01/2024
/*/
//-------------------------------------------------------------------
Function JURA317()
Local oBrowse := FWMBrowse():New()

	oBrowse:SetDescription(STR0001) // "Modelo de inclusão de subsídios"
	oBrowse:SetAlias( "O1I" )
	oBrowse:Activate()
	oBrowse:Destroy()

Return .T.
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Funcional

@return aRotina - Estrutura
		[n,1] Nome a aparecer no cabecalho
		[n,2] Nome da Rotina associada
		[n,3] Reservado
		[n,4] Tipo de Transação a ser efetuada:
				1 - Pesquisa e Posiciona em um Banco de Dados
				2 - Simplesmente Mostra os Campos
				3 - Inclui registros no Bancos de Dados
				4 - Altera o registro corrente
				5 - Remove o registro corrente do Banco de Dados
				6 - Alteração sem inclusão de registros
				7 - Cópia
				8 - Imprimir
		[n,5] Nivel de acesso
		[n,6] Habilita Menu Funcional

@since 03/01/2024
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

	aAdd( aRotina, { STR0003, "VIEWDEF.JURA317", 0, 2, 0, NIL } ) // "Visualizar"
	aAdd( aRotina, { STR0004, "VIEWDEF.JURA317", 0, 3, 0, NIL } ) // "Incluir"
	aAdd( aRotina, { STR0005, "VIEWDEF.JURA317", 0, 4, 0, NIL } ) // "Alterar"
	aAdd( aRotina, { STR0006, "VIEWDEF.JURA317", 0, 5, 0, NIL } ) // "Excluir"

Return aRotina

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Função responsavel pela definição do modelo

@since 03/01/2024
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()
Local oModel    := nil
Local oStrO1I   := FWFormStruct(1,'O1I')
Local oStrO1J   := FWFormStruct(1,'O1J')

	oModel := MPFormModel():New('JURA317', /*bPreValidacao*/, {|oModel| ModelPosValid(oModel)} /*bPosValid*/, /*bCommit*/, /*bCancel*/ )
	oModel:AddFields('O1IMASTER', /*cOwner*/, oStrO1I, /*bPre*/, /*bPos*/, /*bLoad*/)
	oModel:AddGrid( "O1JDETAIL", "O1IMASTER" /*cOwner*/, oStrO1J, /*bLinePre*/, /*bLinePost*/,/*bPre*/, /*bPost*/ )

	oModel:SetDescription(STR0001)  // "Modelo de inclusão de subsídios"
	oModel:SetDescription(STR0002)  // "Tipos de documentos"

	oModel:GetModel('O1IMASTER'):SetDescription(STR0001)  // "Modelo de inclusão de subsídios"
	oModel:GetModel('O1JDETAIL'):SetDescription(STR0002)  // "Tipos de documentos"

	oModel:SetRelation("O1JDETAIL", {{"O1J_FILIAL", "O1I_FILIAL" }, {"O1J_CODMOD", "O1I_CODIGO" }}, O1J->( IndexKey( 1 )))

Return oModel

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelPosValid
Função responsavel pela validação dos dados do modelo

@since 03/01/2024
/*/
//------------------------------------------------------------------------------
Static Function ModelPosValid(oModel)
Local lRet      := .T.
Local oMdlO1I   := Nil
Local cQuery    := ""
Local cTmpAlias := ""
Local aQryParam := {}

	If oModel:GetOperation() == MODEL_OPERATION_INSERT .OR. oModel:GetOperation() == MODEL_OPERATION_UPDATE
		aQryParam := {}
		oMdlO1I   := oModel:GetModel('O1IMASTER')
		cTmpAlias := GetNextAlias()

		aAdd(aQryParam,xFilial('O1I'))
		aAdd(aQryParam,oMdlO1I:GetValue("O1I_CTIPAS"))
		aAdd(aQryParam,oMdlO1I:GetValue("O1I_CAREAJ"))
		aAdd(aQryParam,oMdlO1I:GetValue("O1I_COBJET"))
		aAdd(aQryParam,oMdlO1I:GetValue("O1I_TPENVO"))
		aAdd(aQryParam,oMdlO1I:GetValue("O1I_CODIGO"))

		cQuery += " SELECT COUNT(O1I_CODIGO) as TOTAL"
		cQuery +=   " FROM " + RetSqlName('O1I')
		cQuery +=  " WHERE O1I_FILIAL = ?"
		cQuery +=    " AND O1I_CTIPAS = ?"
		cQuery +=    " AND O1I_CAREAJ = ?"
		cQuery +=    " AND O1I_COBJET = ?"
		cQuery +=    " AND O1I_TPENVO = ?"
		cQuery +=    " AND O1I_CODIGO <> ?"
		cQuery +=    " AND D_E_L_E_T_ = ' '"

		dbUseArea( .T., 'TOPCONN', TCGenQry2(NIL,NIL,cQuery,aQryParam), cTmpAlias, .T., .F. )

		If (cTmpAlias)->TOTAL > 0
			lRet := .F.
			JurMsgErro(STR0007) // "Já existem registros com as informações utilizadas. Verifique!"
		EndIf
	EndIf


Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Função responsavel pela definição da view

@since 03/01/2024
/*/
//------------------------------------------------------------------------------
Static Function ViewDef()
Local oView   := FWFormView():New()
Local oModel  := FwLoadModel('JURA317')
Local oStrO1I := FWFormStruct(2, 'O1I')
Local oStrO1J := FWFormStruct(2, 'O1J')

	oStrO1J:RemoveField('O1J_CODMOD')

	oView:SetModel(oModel)
	oView:AddField('VIEW_O1I' ,oStrO1I,'O1IMASTER')
	oView:SetDescription(STR0001)  // "Modelo de inclusão de subsídios"
	oView:AddGrid(  "VIEW_O1J" , oStrO1J, "O1JDETAIL" )

	oView:CreateHorizontalBox( "FORMMASTER" , 30 )
	oView:CreateHorizontalBox( "FORMDETAIL" , 70 )

	oView:SetOwnerView( "O1IMASTER" , "FORMMASTER" )
	oView:SetOwnerView( "O1JDETAIL" , "FORMDETAIL" )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} J317IncSub(cFilNsz, cCajuri, cTipoAsj, cAreaJur, cCObjAss)
Realiza a inclusão de subsídio 

@Param cFilNsz  - filial NSZ
@Param cCajuri  - cajuri do processo
@Param cTipoAsj - tipo de assunto jurídico
@Param cAreaJur - área jurídica
@Param cCObjAss - código do assunto

@author Willian Kazahaya
@since 24/01/2024
/*/
//-------------------------------------------------------------------
Function J317IncSub(cFilNsz, cCajuri, cTipoAsj, cAreaJur, cCObjAss)
Local lRet        := .T.
Local cAlsSub     := GetNextAlias()
Local cQrySel     := ""
Local cQryFrm     := ""
Local cQryWhr     := ""
Local cQuery      := ""
Local nI          := 0
Local oMdl254     := Nil
Local aEnvProc    := {}
Local aListDocs   := {}
Local aParams     := {}
Local cChave      := ""
Local nPrzSolic   := 0
Local cCodEnvolv  := ""
Local cObserv     := ""
Local oSaveModel  := Nil

	If (FwAliasInDic("O1I") .And. FwAliasInDic("O1J"))
		aEnvProc := JGetEnvol(cFilNsz, cCajuri)

		For nI := 1 to Len(aEnvProc)

			aAdd(aParams, aEnvProc[nI][2])
			aAdd(aParams, cTipoAsj)
			aAdd(aParams, cAreaJur)
			aAdd(aParams, cCObjAss)

			cQrySel := "SELECT O1I.O1I_FILIAL,"
			cQrySel +=       " O1I.O1I_CODIGO,"
			cQrySel +=       " O1I.O1I_PRAZO,"
			cQrySel +=       " O1I.O1I_OBSERV,"
			cQrySel +=       " O1J.O1J_CTPDOC,"
			cQrySel +=       " O1J.O1J_CRESP,"
			cQrySel +=       " O1J.O1J_PRAZO,"
			cQrySel +=       JQryMemo("O1I_OBSERV", Nil, Nil, 4000) + " O1I_OBSERV"
			cQryFrm :=  " FROM " + RetSqlName("O1I") + " O1I"
			cQryFrm += " INNER JOIN " + RetSqlName("O1J") + " O1J"
			cQryFrm +=    " ON (O1J.O1J_FILIAL = O1I.O1I_FILIAL"
			cQryFrm +=   " AND O1J.O1J_CODMOD = O1I.O1I_CODIGO"
			cQryFrm +=   " AND O1J.D_E_L_E_T_ = ' ')"
			cQryWhr := " WHERE O1I.O1I_TPENVO = ?"

			cQryWhr +=   " AND O1I.O1I_CTIPAS IN (' ', ? )"
			cQryWhr +=   " AND O1I.O1I_CAREAJ IN (' ', ? )"
			cQryWhr +=   " AND O1I.O1I_COBJET IN (' ', ? )"
			cQryWhr +=   " AND O1I.D_E_L_E_T_ = ' '"

			cQuery := cQrySel + cQryFrm + cQryWhr

			cQuery := ChangeQuery(cQuery)
			DbUseArea( .T., "TOPCONN", TcGenQry2(,,cQuery, aParams), cAlsSub, .F., .F. )

			If ((cAlsSub)->(!Eof()))
				cChave := (cAlsSub)->(O1I_FILIAL) + (cAlsSub)->(O1I_CODIGO)	
				oSaveModel := FWModelActive()	
				oMdl254 := FWLoadModel("JURA254")

				While((cAlsSub)->(!Eof()))
					If (cChave == (cAlsSub)->(O1I_FILIAL) + (cAlsSub)->(O1I_CODIGO))
						aAdd(aListDocs, {  (cAlsSub)->(O1J_CTPDOC), ;
						                   (cAlsSub)->(O1J_CRESP),  ;
						                   (cAlsSub)->(O1J_PRAZO)})

						cCodEnvolv := aEnvProc[nI][1]
						nPrzSolic  := (cAlsSub)->(O1I_PRAZO)
						cObserv    := (cAlsSub)->(O1I_OBSERV)
					Else
						If Len(aListDocs) > 0
							JCriaSolic(oMdl254, cFilNsz, cCajuri, nPrzSolic, cCodEnvolv, ;
									cObserv, aListDocs)
							aSize(aListDocs, 0)
							nPrzSolic   := 0
							cCodEnvolv  := ""
							cObserv     := ""
						EndIf

						cChave := (cAlsSub)->(O1I_FILIAL) + (cAlsSub)->(O1I_CODIGO)	
						aAdd(aListDocs, {  (cAlsSub)->(O1J_CTPDOC), ;
						                   (cAlsSub)->(O1J_CRESP),  ;
						                   (cAlsSub)->(O1J_PRAZO)})

						cCodEnvolv := aEnvProc[nI][1]
						nPrzSolic  := (cAlsSub)->(O1I_PRAZO)
						cObserv    := (cAlsSub)->(O1I_OBSERV)
					EndIf
					(cAlsSub)->( DbSkip() )
				EndDo

				If (Len(aListDocs) > 0)
					// Cadastra a ultima solicitação do Loop
					JCriaSolic(oMdl254, cFilNsz, cCajuri, nPrzSolic, cCodEnvolv, cObserv, ;
							aListDocs)
				EndIf
				aSize(aListDocs, 0)
			EndIf

			//Destroy model
			If oMdl254 <> Nil
				oMdl254:Destroy()
				FWModelActive(oSaveModel,.T.)
			EndIf
			
			(cAlsSub)->( dbcloseArea() )

			aSize(aParams, 0)

		Next nI
	EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JCriaSolic(oModel, cFilNSZ, cCajuri, nPrzSolic, cCodEnvolv, cObserv, aListDocs)
Cria a Solicitação de Documento

@param oModel    - Modelo da JURA254
@param cFilNSZ   - Filial NSZ
@param cCajuri   - Código do Assunto Jurídico
@param nPrzSolic - Prazo da Solicitação
@param cCodEnvol - Codigo do Envolvido
@param cObserv   - Observações
@param aListDocs - Lista de documentos a adicionar
					[1] - Tipo de Documento
					[2] - Responsável
					[3] - Dias do Prazo

@author Willian Kazahaya
@since 24/01/2024
/*/
//-------------------------------------------------------------------
Static Function JCriaSolic(oModel, cFilNSZ, cCajuri, nPrzSolic, cCodEnvolv, cObserv, aListDocs)
Local lRet        := .T.
Local nI          := 0
Local oModelO0M   := Nil
Local oModelO0N   := Nil
Local cTamO0NSeq  := FWTamSX3("O0N_SEQ")[1]

Default nPrzSolic := 0
Default cCodEnvol := ""
Default cObserv   := ""
Default aListDocs := {}

	oModel:SetOperation(MODEL_OPERATION_INSERT)
	oModel:Activate()

	oModelO0M := oModel:GetModel("O0MMASTER")
	oModelO0M:SetValue("O0M_FILIAL", cFilNSZ)
	oModelO0M:SetValue("O0M_CAJURI", cCajuri)
	oModelO0M:SetValue("O0M_PRZSOL", JUR106DTFU("3", Date(), nPrzSolic ) ) // "3" = dias úteis
	oModelO0M:SetValue("O0M_CENVOL", cCodEnvolv )
	oModelO0M:SetValue("O0M_OBS", cObserv )

	oModelO0N := oModel:GetModel("O0NDETAIL")

	For nI := 1 To Len(aListDocs)
		If nI > 1
			oModelO0N:AddLine() // Modelo inicializa com uma linha ativa (em braco)
		EndIf

		oModelO0N:SetValue("O0N_SEQ", StrZero(nI,cTamO0NSeq) )
		oModelO0N:SetValue("O0N_CTPDOC", aListDocs[nI][1] )
		oModelO0N:SetValue("O0N_CPART" , aListDocs[nI][2] )
		oModelO0N:SetValue("O0N_PRZENT", JUR106DTFU("3", Date(), aListDocs[nI][3]) )
		oModelO0N:SetValue("O0N_STATUS", "1" )
	Next nI

	lRet := oModel:VldData() .And. oModel:CommitData()
	oModel:DeActivate()
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JGetEnvol(cFilNsz, cCajuri)
Busca os envolvidos principais

@Param cFilNsz - Filial NSZ
@Param cCajuri - Cajuri do processo

@author Willian Kazahaya
@since 24/01/2024
/*/
//-------------------------------------------------------------------
Static Function JGetEnvol(cFilNsz, cCajuri)
Local aRet      := {}
Local aParams   := {}
Local cQuery    := ""
Local cAlsNT9   := ""
Local cPrincNT9 := "1" // Principal? -> "1" = Sim

	aAdd(aParams, cFilNsz)
	aAdd(aParams, cCajuri)
	aAdd(aParams, cPrincNT9)

	cQuery  := " SELECT NT9.NT9_COD,"
	cQuery  +=        " NT9.NT9_TIPOEN"
	cQuery  +=   " FROM " + RetSqlName("NT9") + " NT9"
	cQuery  +=  " WHERE NT9.NT9_FILIAL = ?"
	cQuery  +=    " AND NT9.NT9_CAJURI = ?"
	cQuery  +=    " AND NT9.NT9_PRINCI = ?"
	cQuery  +=    " AND NT9.D_E_L_E_T_ = ' '"
	cQuery  +=  " ORDER BY NT9.NT9_TIPOEN"

	cAlsNT9 := GetNextAlias()
	DbUseArea( .T., "TOPCONN", TcGenQry2(,,cQuery, aParams), cAlsNT9, .F., .F. )

	While((cAlsNT9)->(!Eof()))
		aAdd(aRet, { (cAlsNT9)->NT9_COD, ;
		             (cAlsNT9)->NT9_TIPOEN })

		(cAlsNT9)->( DbSkip() )
	EndDo

	(cAlsNT9)->(DbCloseArea())
Return aRet
