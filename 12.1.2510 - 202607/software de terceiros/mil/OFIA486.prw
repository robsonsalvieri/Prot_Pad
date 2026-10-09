#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE 'FWEditPanel.CH'
#INCLUDE 'VEIFUNC.CH'
#INCLUDE 'OFIA486.CH'

Static cCpoCabVSJ := "VSJ_NUMOSV"
Static cCpoAux    := "VSJ_SEQINC/VSJ_GRUINC/VSJ_CODINC/VSJ_DESINC/"
Static cCpoGrdVSJ := "VSJ_GRUITE/VSJ_CODITE/VSJ_RESPEC/VSJ_DEPGAR/VSJ_DEPINT/VSJ_TIPTEM/VSJ_ORIDAD/VSJ_CODTES/VSJ_FATPAR/VSJ_LOJA/VSJ_NOMCLI/VSJ_DESITE/VSJ_NNRCOD/VSJ_QTDEST/VSJ_OPER/VSJ_CODSIT/VSJ_QTDINI/VSJ_MOTPED/VSJ_QTDAGU"

Static lAltInconv := findFunction("OX001066K_AlteraDescricaoInconveniente")

Function OFIA486()

	Local oBrowse

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('VSJ')
	oBrowse:SetDescription(STR0001) //"Peças em espera para aplicação"
	oBrowse:Activate()

Return

Static Function MenuDef()

	Local aRotina := {}

	aRotina := FWMVCMenu('OFIA486')

Return aRotina

Static Function ModelDef()
	Local oModel
	Local oStruVSJCab := FWFormStruct( 1, 'VSJ', { |cCampo| ALLTRIM(cCampo) $ cCpoCabVSJ } )
	Local oStrVSJ := FWFormStruct(1, "VSJ")
	Local aAux
	Local oRpm := OFJDRpmConfig():New()
	Local lMostraEstoque := oRpm:MostraEstoqueAoDigitar()
	Local lHasInconv     := GetNewPar( "MV_INCORC" ,"N") == "S"
	
	If lHasInconv
		cCpoGrdVSJ := cCpoAux + cCpoGrdVSJ
	EndIf

	oModel := MPFormModel():New('OFIA486',;
	/*Pré-Validacao*/,;
	/*Pós-Validacao*/,;
	/*Confirmacao da Gravação*/,;
	/*Cancelamento da Operação*/)

	oStrVSJ:SetProperty( 'VSJ_NUMORC', MODEL_FIELD_OBRIGAT, .f.)
	oStrVSJ:SetProperty( 'VSJ_QTDITE', MODEL_FIELD_OBRIGAT, .f.)

	oStrVSJ:SetProperty( 'VSJ_ORIDAD',MODEL_FIELD_WHEN, { || .F. })
	oStrVSJ:SetProperty( 'VSJ_ORIDAD',MODEL_FIELD_INIT,FWBuildFeature( STRUCT_FEATURE_INIPAD, X3Combo("VSJ_ORIDAD", VSJ->VSJ_ORIDAD) ) )
	oStrVSJ:SetProperty( 'VSJ_DESITE',MODEL_FIELD_INIT,FWBuildFeature( STRUCT_FEATURE_INIPAD, "Posicione('SB1',7,xFilial('SB1')+VSJ->VSJ_GRUITE+VSJ->VSJ_CODITE,'B1_DESC')" ) )
	oStrVSJ:SetProperty( 'VSJ_NOMCLI',MODEL_FIELD_INIT,FWBuildFeature( STRUCT_FEATURE_INIPAD, "Posicione('SA1',1,xFilial('SA1')+VSJ->VSJ_FATPAR+VSJ->VSJ_LOJA,'A1_NOME')" ) )

	If lHasInconv
		oStrVSJ:SetProperty( 'VSJ_DESINC',MODEL_FIELD_INIT,FWBuildFeature( STRUCT_FEATURE_INIPAD, "Posicione('VST',1, VST->(VST_FILIAL+VST_TIPO+VST_CODIGO+VST_SEQINC),'VST_DESINC')" ) )
	EndIf

	oStrVSJ:SetProperty( 'VSJ_RESPEC',MODEL_FIELD_INIT,FWBuildFeature( STRUCT_FEATURE_INIPAD, "'0'"))
	oStrVSJ:SetProperty( 'VSJ_QTDEST',MODEL_FIELD_INIT,FWBuildFeature( STRUCT_FEATURE_INIPAD, iif(lMostraEstoque, "OA4860025_QuantidadeEstoque()", "0")))
	oStrVSJ:SetProperty( 'VSJ_GRUITE', MODEL_FIELD_VALID, FWBuildFeature( STRUCT_FEATURE_VALID , "(OFIA486_FG_POSSB1().And.FG_GRUTEM(FwFldGet('VSJ_TIPTEM'),FwFldGet('VSJ_GRUITE')) )") )
	oStrVSJ:SetProperty( 'VSJ_CODITE', MODEL_FIELD_VALID, FWBuildFeature( STRUCT_FEATURE_VALID , "FS_VERBLQ3() .and. OFIA486_FG_POSSB1()" ) )
	oStrVSJ:SetProperty( 'VSJ_TIPTEM', MODEL_FIELD_VALID, FWBuildFeature( STRUCT_FEATURE_VALID , FM_VLDUSR("FG_TIPTPFAT(,'VSJ_FATPAR','VSJ_LOJA','VSJ_NOMCLI',Posicione('VV1',1,xFilial('VV1')+VO1->VO1_CHAINT,'VV1_CODMAR'),,,,,,,.t.,'VSJDETAIL')", "VSJ_TIPTEM")))
	oStrVSJ:SetProperty( 'VSJ_FATPAR', MODEL_FIELD_VALID, FWBuildFeature( STRUCT_FEATURE_VALID , "OA4860015_FATSP(FwFldGet('VSJ_NUMOSV'),FwFldGet('VSJ_TIPTEM'),FwFldGet('VSJ_FATPAR'))" ) )
	oStrVSJ:SetProperty( 'VSJ_LOJA'  , MODEL_FIELD_VALID, FWBuildFeature( STRUCT_FEATURE_VALID , "OA4860015_FATSP(FwFldGet('VSJ_NUMOSV'),FwFldGet('VSJ_TIPTEM'),FwFldGet('VSJ_FATPAR'),FwFldGet('VSJ_LOJA'))" ) )
	oStrVSJ:SetProperty( 'VSJ_CODTES', MODEL_FIELD_VALID, FWBuildFeature( STRUCT_FEATURE_VALID , "ExistCPO('SF4',FwFldGet('VSJ_CODTES')) .and. MaAvalTes('S',FwFldGet('VSJ_CODTES'))" ) )
	oStrVSJ:SetProperty( 'VSJ_DEPGAR', MODEL_FIELD_VALID, FWBuildFeature( STRUCT_FEATURE_VALID , "Vazio() .or. FG_Seek('SX5',"+'"'+"'VF'+FwFldGet('VSJ_DEPGAR')"+'"'+",1,.f.)" ) )
	oStrVSJ:SetProperty( 'VSJ_DEPINT', MODEL_FIELD_VALID, FWBuildFeature( STRUCT_FEATURE_VALID , "Vazio() .or. FG_Seek('SX5',"+'"'+"'VD'+FwFldGet('VSJ_DEPINT')"+'"'+",1,.f.)" ) )
	oStrVSJ:SetProperty( 'VSJ_OPER'  , MODEL_FIELD_VALID, FWBuildFeature( STRUCT_FEATURE_VALID , "Vazio() .or. Existcpo('SX5','DJ'+FwFldGet('VSJ_OPER'))" ) )
	oStrVSJ:SetProperty( 'VSJ_CODSIT', MODEL_FIELD_VALID, FWBuildFeature( STRUCT_FEATURE_VALID , "Vazio() .or. Existcpo('V09',FwFldGet('VSJ_CODSIT'))" ) )
	
	If lHasInconv
		oStrVSJ:SetProperty( 'VSJ_SEQINC', MODEL_FIELD_VALID, {|| OA4860106_AtualizaDados( FwFldGet('VSJ_NUMOSV') ) } )
	EndIf

	If IsInCallStack("OM020029G_Demanda_Retroativa")
		//Campos da Grid
		oStrVSJ:SetProperty( 'VSJ_TIPTEM', MODEL_FIELD_OBRIGAT, .f.)
		oStrVSJ:SetProperty( 'VSJ_FATPAR', MODEL_FIELD_OBRIGAT, .f.)
		oStrVSJ:SetProperty( 'VSJ_LOJA'  , MODEL_FIELD_OBRIGAT, .f.)
		oStrVSJ:SetProperty( 'VSJ_CODTES', MODEL_FIELD_OBRIGAT, .f.)
		oStrVSJ:SetProperty( 'VSJ_QTDINI', MODEL_FIELD_OBRIGAT, .f.)
		oStrVSJ:SetProperty( 'VSJ_QTDDIG', MODEL_FIELD_OBRIGAT, .f.)
		oStrVSJ:SetProperty( 'VSJ_MOTPED', MODEL_FIELD_VALID, FWBuildFeature( STRUCT_FEATURE_VALID , "OA486006G_ValidaMotivo()" ) )
	EndIf

	oStrVSJ:SetProperty('VSJ_NUMOSV', MODEL_FIELD_INIT,FWBuildFeature( STRUCT_FEATURE_INIPAD, VO1->VO1_NUMOSV ) )
	If FWIsInCallStack("OFIOM020") .or. FWIsInCallStack("OFIXA120")
		oStrVSJ:SetProperty( 'VSJ_ORIDAD', MODEL_FIELD_INIT,FWBuildFeature( STRUCT_FEATURE_INIPAD, "4" ) )
	EndIf

	If GetRPORelease() < "12.1.2510"
		oStrVSJ:SetProperty( 'VSJ_QESTNA', MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD, cValToChar(-1) ) )
	Endif

	oModel:AddFields( 'VSJMASTER', /*cOwner*/, oStruVSJCab, /* <bPre> */ , /* <bPost> */ , /* <bLoad> */{ |oFieldModel, lCopy| loadCab(oFieldModel, lCopy) } )
	oModel:AddGrid(   'VSJDETAIL','VSJMASTER', oStrVSJ    , /* <bLinePre > */ , /* <bLinePost > */ , /* <bPre > */ , /* <bLinePos > */ , /**/)

	oModel:SetRelation('VSJDETAIL', { { 'VSJ_FILIAL' , 'xFilial("VSJ")' } , { 'VSJ_NUMOSV' , 'VSJ_NUMOSV' } } , 'VSJ_FILIAL+VSJ_NUMOSV' )

	oModel:SetPrimaryKey( { "VSJ_FILIAL", "VSJ_CODIGO" } )

	oModel:SetDescription(STR0001)
	oModel:GetModel('VSJMASTER'):SetDescription(STR0002) //"Dados de peças em espera para aplicação"

	oModel:GetModel('VSJDETAIL'):SetOptional(.t.)

	oModel:InstallEvent("OFIA486EVDEF", /*cOwner*/, OFIA486EVDEF():New())

	aAux := fwStruTrigger( 'VSJ_CODITE', 'VSJ_CODTES', 'OA486005C_TriggerVSJ()', .F., "", 0, "", nil, "01" )
	oStrVSJ:addTrigger( aAux[1], aAux[2], aAux[3], aAux[4] )
Return oModel

Static Function ViewDef()

	Local oView
	Local oModel := ModelDef()

	Local oStruVSJCab := FWFormStruct( 2, 'VSJ' , { |cCampo| ALLTRIM(cCampo) $ cCpoCabVSJ } )
	Local oStruVSJ

	Local oRpm 		  := OFJDRpmConfig():New()
	Local lHasInconv  := GetNewPar( "MV_INCORC" ,"N") == "S"

	Local lSolicit := GetNewPar("MV_SUGCOS","N") == "S" .or. GetNewPar("MV_MIL0209",.f.)
	Local lProcSol := GetNewPar("MV_MIL0220",.f.)

	If VSJ->(FieldPos("VSJ_QTDTRA")) > 0
		cCpoGrdVSJ += "/VSJ_QTDTRA"
	EndIf

	oStruVSJ := FWFormStruct( 2, 'VSJ' , { |cCampo| ALLTRIM(cCampo) $ cCpoGrdVSJ } )

	oStruVSJ:SetProperty('VSJ_RESPEC', MVC_VIEW_CANCHANGE , .F.)
	
	If lHasInconv
		oStruVSJ:SetProperty('VSJ_SEQINC', MVC_VIEW_CANCHANGE , .T.)
	EndIf

	If IsInCallStack("OM020029G_Demanda_Retroativa") //Essa rotina é chamada em atividades diferentes na OFIOM020, por isso, essa verificação primeiro
		oStruVSJ:SetProperty('VSJ_MOTPED',MVC_VIEW_CANCHANGE, .T. )
		
		oModel:GetModel("VSJDETAIL"):SetLoadFilter( , "VSJ_ORIDAD IN ('2','4')" )

	ElseIf IsInCallStack("OFIOM020") .or. IsInCallStack("OFIXA120")
		oModel:GetModel("VSJDETAIL"):SetLoadFilter( , "VSJ_ORIDAD IN ('2','4') AND VSJ_QTDITE > 0" )
	EndIf

	If !oRpm:lNovaConfiguracao
		oStruVSJ:RemoveField('VSJ_NNRCOD')
	Endif

	oView := FWFormView():New()

	oView:SetModel(oModel)

	oView:AddField( 'VIEW_VSJCAB', oStruVSJCab, 'VSJMASTER' )
	oView:AddGrid(  'VIEW_VSJ'   , oStruVSJ   , 'VSJDETAIL' )

	oView:CreateHorizontalBox( 'VSJCAB', 100,,.t.) // tamanho em pixel
	oView:CreateHorizontalBox( 'VSJDET', 100) // tamanho em %

	oView:SetOwnerView('VIEW_VSJCAB','VSJCAB')
	oView:EnableTitleView('VIEW_VSJCAB', STR0003 ) //"Ordem de Serviço"

	oView:SetOwnerView('VIEW_VSJ','VSJDET')
	oView:EnableTitleView('VIEW_VSJ', STR0004) //"Peças em espera para aplicação"

	If IsInCallStack("OM020029G_Demanda_Retroativa") //Não poderá inserir linhas quando chamado dessa rotina.
		oView:SetNoInsertLine('VIEW_VSJ')
		oView:SetNoDeleteLine('VIEW_VSJ')
		oView:AddUserButton(STR0023,'CLIPS',{ |oView| OA486007G_DemandaRetroativa() , oView:Refresh()}) //"Preencher para Todos"
	Else
		If !lProcSol
			oView:AddUserButton(STR0005,'CLIPS',{ |oView| OA4860045_GeraSugestaoCompra() , oView:Refresh()}) //"Requisição de Compra"
		Else
			If lSolicit
				oView:AddUserButton(STR0037,'CLIPS',{ |oView| OA4860115_Solicitacoes() , oView:Refresh()}) //"Pendências de Estoque"
			EndIf
		EndIf
		VAI->(Dbsetorder(4))
		VAI->(DbSeek(xFilial("VAI")+__cUserID))
		If VAI->VAI_ACEDET <> "0"
			oView:AddUserButton(STR0029,'CLIPS',{ |oView| OA4860091_ChamaAnaliseItem() , oView:Refresh()}) //Analise do Item
		EndIf
	EndIf

	If lHasInconv
		oStruVSJ:SetProperty( "VSJ_GRUINC" ,MVC_VIEW_CANCHANGE, .F. )
		oStruVSJ:SetProperty( "VSJ_CODINC" ,MVC_VIEW_CANCHANGE, .F. )
		oStruVSJ:SetProperty( "VSJ_SEQINC" ,MVC_VIEW_CANCHANGE, .T. )
		oStruVSJ:SetProperty('VSJ_SEQINC', MVC_VIEW_TITULO, iif( lAltInconv, OX001066K_AlteraDescricaoInconveniente('VSJ_SEQINC'), retTitle('VSJ_SEQINC') ) )
		oStruVSJ:SetProperty('VSJ_GRUINC', MVC_VIEW_TITULO, iif( lAltInconv, OX001066K_AlteraDescricaoInconveniente('VSJ_GRUINC'), retTitle('VSJ_GRUINC') ) )
		oStruVSJ:SetProperty('VSJ_CODINC', MVC_VIEW_TITULO, iif( lAltInconv, OX001066K_AlteraDescricaoInconveniente('VSJ_CODINC'), retTitle('VSJ_CODINC') ) )
		oStruVSJ:SetProperty('VSJ_DESINC', MVC_VIEW_TITULO, iif( lAltInconv, OX001066K_AlteraDescricaoInconveniente('VSJ_DESINC'), retTitle('VSJ_DESINC') ) )
		oStruVSJ:SetProperty("VSJ_ORIDAD", MVC_VIEW_ORDEM, "01")
		oStruVSJ:SetProperty("VSJ_SEQINC", MVC_VIEW_ORDEM, "02")
    EndIf

Return oView

Static Function loadCab(oFieldModel, lCopy)
	Local aLoad := {}
	Local aAuxFields := oFieldModel:GetStruct():GetFields()
	Local nPosField

	RegToMemory("VSJ",INCLUI)

	If Empty(VO1->VO1_NUMOSV)
		M->VSJ_NUMOSV := VSJ->VSJ_NUMOSV
	Else
		M->VSJ_NUMOSV := VO1->VO1_NUMOSV
	EndIf

	For nPosField := 1 to Len(aAuxFields)
		AADD( aLoad, &("M->" + aAuxFields[nPosField, 3] ) )
	Next nPosField

Return aLoad


Function OA4860015_FATSP(cNumOsv,cTipTem,cFatPar,cLojFat)

Local nRecFAT := 0
Local cSQL    := ""

Local oModel	:= FWModelActive()
Local oModVSJDet:= oModel:GetModel("VSJDETAIL")
Local cChvPsq   := ""
Local nBkpLn    := 0
Local lProblema := .f.

Default cNumOsv := VO1->VO1_NUMOSV
Default cFatPar := Space(GetSX3Cache("VSJ_FATPAR","X3_TAMANHO"))
Default cLojFat := Space(GetSX3Cache("VSJ_LOJA","X3_TAMANHO"))

If Empty(cLojFat)
	cChvPsq := cFatPar
Else
	cChvPsq := cFatPar + cLojFat
EndIf

DbSelectArea("SA1")
DbSetOrder(1)
If !DbSeek( xFilial("SA1") + cChvPsq )
	Help("  ",1,"REGNOIS",,(STR0324),5,1)
	Return .f.
EndIf

cSQL := "SELECT VO3.R_E_C_N_O_"
cSQL += " FROM " + RetSQLName("VO3") + " VO3 "
cSQL += " WHERE VO3.VO3_FILIAL = '" + xFilial("VO3") + "'"
cSQL +=   " AND VO3.VO3_NUMOSV = '" + cNumOsv + "'"
cSQL +=   " AND VO3.VO3_TIPTEM = '" + cTipTem + "'"

If !Empty(cFatPar)
	If Empty(cLojFat)
		cSQL +=   " AND VO3.VO3_FATPAR <> '" + cFatPar + "' "
	Else
		cSQL +=   " AND VO3.VO3_FATPAR = '" + cFatPar + "' "
		cSQL +=   " AND VO3.VO3_LOJA <> '" + cLojFat + "' "
	EndIF
EndIf

cSQL +=   " AND VO3.D_E_L_E_T_ = ' '"

cSQL += " UNION "

cSQL += "SELECT VO4.R_E_C_N_O_"
cSQL += " FROM " + RetSQLName("VO4") + " VO4 "
cSQL += " WHERE VO4.VO4_FILIAL = '" + xFilial("VO4") + "'"
cSQL +=   " AND VO4.VO4_NUMOSV = '" + cNumOsv + "'"
cSQL +=   " AND VO4.VO4_TIPTEM = '" + cTipTem + "'"

If !Empty(cFatPar)
	If Empty(cLojFat)
		cSQL +=   " AND VO4.VO4_FATPAR <> '" + cFatPar + "' "
	Else
		cSQL +=   " AND VO4.VO4_FATPAR = '" + cFatPar + "' "
		cSQL +=   " AND VO4.VO4_LOJA <> '" + cLojFat + "' "
	EndIf
EndIf

cSQL +=   " AND VO4.D_E_L_E_T_ = ' '"

nRecFAT := FM_SQL(cSQL)

If nRecFAT > 0
	Help(" ",1,"FATPARSP")
	Return .f.
EndIf

nBkpLn := oModVSJDet:nLine

oModVSJDet:GoLine()

lSeek := oModVSJDet:SeekLine({;
									{ "VSJ_TIPTEM" , cTipTem };
		})

If lSeek .and. nBkpLn <> oModVSJDet:nLine

	If !Empty(cLojFat) .and. (oModVSJDet:GetValue("VSJ_FATPAR") <> cFatPar .or. oModVSJDet:GetValue("VSJ_LOJA") <> cLojFat)


		lProblema := .t.

	Endif

	dbSelectArea("SA1")
	SA1->(DbSetOrder(1))
	If !SA1->(DbSeek(xFilial("SA1") + oModVSJDet:GetValue("VSJ_FATPAR") + oModVSJDet:GetValue("VSJ_LOJA")))

		lProblema := .t.

	EndIf

	If lProblema

		Help(" ",1,"FATPARSP")

		oModVSJDet:GoLine(nBkpLn)
		Return .f.

	EndIf
	
ElseIf lSeek .and. nBkpLn == 1 .and. oModVSJDet:Length(.T.) > 1 //Se eu possuir mais de 1 linha ativa no grid, não posso alterar o VSJ_FATPAR e o VSJ_LOJA na primeira linha.
	
	Help(" ",1,"FATPARSP")

	oModVSJDet:GoLine(nBkpLn)
	Return .f.
EndIf

oModVSJDet:GoLine(nBkpLn)
oModVSJDet:LoadValue("VSJ_NOMCLI", Left(Alltrim(SA1->A1_NOME), GetSX3Cache("VSJ_NOMCLI","X3_TAMANHO")))

Return .t.


Function OA4860025_QuantidadeEstoque()

	Local nRetorno  := 0
	Local oModel	:= FWModelActive()
	Local oMdVSJDet := oModel:GetModel("VSJDETAIL")
	Local oRpm := OFJDRpmConfig():New()

	If oMdVSJDet:GetLine() == 0
		if ! empty(VSJ->VSJ_GRUITE) .and. ! empty(VSJ->VSJ_CODITE)

			SB1->(DbSetOrder(7))
			SB1->(DbSeek(xFilial("SB1")+VSJ->VSJ_GRUITE+VSJ->VSJ_CODITE))

			if oRpm:lNovaConfiguracao
				if ! oRpm:MostraEstoqueAoDigitar() .or. empty(VSJ->VSJ_NNRCOD)
					return 0
				endif

				if oRpm:MostraEstoqueAoDigitar() .and. ! empty(VSJ->VSJ_NNRCOD)
					nQtd := oRpm:SaldoTotalDaPeca(SB1->B1_COD, cFilAnt, VSJ->VSJ_NNRCOD)
					return nQtd
				endif
			endif

			if ! oRpm:lNovaConfiguracao
				if oRpm:MostraEstoqueAoDigitar() .or. VSJ->VSJ_QESTNA >= 0
					nRetorno := FS_SALDOESTQ( SB1->B1_COD , OM0200065_ArmazemOrigem( VSJ->VSJ_TIPTEM ) )
				endif
			endif
		endif
	EndIf

Return nRetorno

/*/{Protheus.doc} OA4860035_LevantaInfoItensSugestao

	@type function
	@author Renato Vinicius
	@since 30/03/2023
/*/

Function OA4860035_LevantaInfoItensSugestao(cNumOsv, lValidaSaldo)

	Local aRetSug := {}
	Local nQntEstq := 0
	Local nQtdSug  := 0
	Local lVSJQTDTRA := VSJ->(FieldPos("VSJ_QTDTRA")) > 0
	Local cLocalArm := ''
	Default lValidaSaldo := .F.

	cQuery := "SELECT VSJ.VSJ_QTDITE, VSJ_GRUITE, VSJ_CODITE, VSJ_QTDRES, VSJ_CODIGO, VSJ_TIPTEM, VSJ_LOCAL, VSJ.R_E_C_N_O_ AS VSJRECNO "
	cQuery += " FROM " + RetSqlName("VSJ") + " VSJ "
	cQuery += " WHERE VSJ.VSJ_FILIAL = '" + xFilial("VSJ") + "' "
	cQuery += 	" AND VSJ.VSJ_NUMOSV = '" + cNumOsv + "' "
	cQuery += 	" AND VSJ.VSJ_QTDAGU = 0 "
	If lVSJQTDTRA
		cQuery += 	" AND VSJ.VSJ_QTDTRA = 0 "
	EndIf
	cQuery += 	" AND VSJ.VSJ_QTDITE - VSJ.VSJ_QTDRES > 0 "
	cQuery += 	" AND VSJ.D_E_L_E_T_ = ' '"

	TcQuery cQuery New Alias "TMPVSJ"

	While !TMPVSJ->(Eof())

		SB1->( DbSetOrder(7) )
		SB1->( DbSeek( xFilial("SB1") + TMPVSJ->VSJ_GRUITE + TMPVSJ->VSJ_CODITE ) )

        nQtdSug := TMPVSJ->VSJ_QTDITE - TMPVSJ->VSJ_QTDRES

		// lValidaSaldo Se habilitado: valida se há saldo suficiente no estoque para a quantidade sugerida
		// Caso o saldo seja suficiente, ignora o item (não adiciona à sugestão de compras)
        If lValidaSaldo

			cLocalArm := OM0200065_ArmazemOrigem(TMPVSJ->VSJ_TIPTEM)
            If !empty(TMPVSJ->VSJ_LOCAL)
				cLocalArm := TMPVSJ->VSJ_LOCAL
			Endif
			nQntEstq := FS_SALDOESTQ(SB1->B1_COD, cLocalArm)

			nQtdSug := nQtdSug - nQntEstq

            If nQtdSug <= 0
                TMPVSJ->(DbSkip())
                Loop
            EndIf

        EndIf

		aAdd(aRetSug, { , ;
						TMPVSJ->VSJ_GRUITE ,;
						TMPVSJ->VSJ_CODITE ,;
						,;
						nQtdSug,;
						,;
						,;
						,;
						,;
						,;
						,;
						SB1->B1_COD,;
						"",;
						TMPVSJ->VSJ_QTDITE,;
						TMPVSJ->VSJ_QTDRES,;
						TMPVSJ->VSJ_LOCAL,;
						,;
						,;
						,;
						,;
						,;
						,;
						,;
						,;
						,;
						"VSJ",;
						TMPVSJ->VSJRECNO,;
						TMPVSJ->VSJ_CODIGO,;
					} )
		TMPVSJ->(DbSkip())
	EndDo

	TMPVSJ->(DbCloseArea())

Return aRetSug

/*/{Protheus.doc} OA4860045_GeraSugestaoCompra

	@type function
	@author Renato Vinicius
	@since 30/03/2023
/*/

Function OA4860045_GeraSugestaoCompra()

	Local oModelAct	:= FWModelActive()
	Local oViewAct 	:= FWViewActive()
	Local aArea     := GetArea()

	Local oGerSug := OFIA486EVDEF():New()
	Local lGerSug := .f.

	Local aIteSug := {}

	If oModelAct:VldData()

		If oModelAct:lModify
			ForceToHideMessage(oViewAct)
			oViewAct:ButtonOkAction(.F.)
		Endif

		aIteSug := oGerSug:GetItensSugestao(.T.)
		If Len(aIteSug) > 0
			lGerSug := oGerSug:GetGeraSugestao()
			If lGerSug
				If !OFIA485( aIteSug )
					Return .f.
				EndIf
			EndIf
		Else
			FMX_HELP("VLDOFIA486001", STR0006, "")// "Não há itens que necessite a geração de sugestão de compra." // "Atenção"
		EndIf
		fRefresh(oModelAct,oViewAct)
	Else
		FMX_HELP("VLDOFIA486002", oModelAct:GetErrorMessage()[6], "")
	EndIf

	RestArea( aArea )

Return

/*/{Protheus.doc} fRefresh

	@type function
	@author Renato Vinicius
	@since 30/03/2023
/*/

Static Function fRefresh(oModelAct,oViewAct)

	Local aArea         := GetArea()

	FWModelActive(oModelAct, .T.)
	oModelAct:Deactivate()
	oModelAct:Activate()

	If ValType(oViewAct) != "U"
		oViewAct:Refresh()
	Endif

	RestArea(aArea)

Return


/*/{Protheus.doc} OA486005C_TriggerVSJ
Gatilho campo VSJ_CODITE, busca TES/TES Inteligente e retorna p/ campo VSJ_CODTES
@type function
@version 1.0
@author cristiamRossi
@since 6/13/2024
@return character, Código TES
/*/
function OA486005C_TriggerVSJ()
local cAuxTES   := ""
local cTESIntel := ""
local oModel    := fwModelActive()
local oSubModel := oModel:GetModel( "VSJDETAIL" )
local lVOITESPEC:= VOI->(FieldPos("VOI_TESPEC")) > 0 // Argentina/México - Tem TES default para PEÇAS no Cadastro do Tipo de Tempo

	VOI->( DbSetOrder(1) )
	VOI->( DbSeek( xFilial("VOI") + FwFldGet("VSJ_TIPTEM") ) )

	cTESIntel := VOI->VOI_CODOPE

	if ! empty( cTESIntel )
		if empty( FwFldGet("VSJ_OPER") )
			oSubModel:loadValue("VSJ_OPER", cTESIntel )
		endif
		cAuxTES := MaTesInt( 2, cTESIntel, FwFldGet("VSJ_FATPAR"), FwFldGet("VSJ_LOJA"), "C", FwFldGet("VSJ_CODITE"))
	endif

	If cPaisLoc $ "ARG/MEX" .and. lVOITESPEC // Argentina/México - Tem TES default para PEÇAS no Cadastro do Tipo de Tempo
		If !Empty(VOI->VOI_TESPEC) // Argentina/México - Tem TES default para PEÇAS no Cadastro do Tipo de Tempo
			cAuxTES := VOI->VOI_TESPEC
		EndIf
	EndIf

return iif( ! empty( cAuxTES ), cAuxTES, SB1->B1_TS )

/*/{Protheus.doc} ForceToHideMessage()
	(long_description)
	@type  Static Function
	@author Lucas Oliveira
	@since 01/03/2025
	@version version
	@param param, param_type, param_descr
	@return return, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Static Function ForceToHideMessage(oViewAct)

	Local aArea := GetArea()

	If ValType(oViewAct) == "O"
		oViewAct:lUpdateMsg := .F. // Força para não apresentar a mensagem Registro alterado com sucesso.
		oViewAct:lInsertMsg := .F. // Força para não apresentar a mensagem Registro inserido com sucesso.
	Endif

	RestArea(aArea)

Return Nil

/*/{Protheus.doc} OFIA486_FG_POSSB1
	Função para abrir a tela após digitar parte do código e autopreencher o grupo, código e descrição no model
	@type  Static Function
	@author Lucas Oliveira
	@since 14/03/2025
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Function OFIA486_FG_POSSB1()

	Local oModel := FWModelActive()
	Local oModelVSJDet := oModel:GetModel('VSJDETAIL')
	Local lRet	:= .F.
	Private cGruIte := FwFldGet("VSJ_GRUITE") // Utilizado no FG_POSSB1
	Private cCodIte := FwFldGet("VSJ_CODITE") // Utilizado no FG_POSSB1

	Do Case
		Case ReadVar() == "M->VSJ_GRUITE"
			If !Empty(cGruIte)
				SBM->(DBSetOrder(1))
				lRet := SBM->(DBSeek(xFilial("SBM") + cGruIte ))
				If !Empty(cCodIte)
					SB1->(DBSetOrder(7))
					If SB1->(DBSeek(xFilial("SB1") + cGruIte + cCodIte ))
						oModelVSJDet:LoadValue("VSJ_DESITE", SB1->B1_DESC)
					Else
						oModelVSJDet:SetValue("VSJ_CODITE", Space(GetSX3Cache("B1_CODITE","X3_TAMANHO")) )
					Endif
				EndIf
			Else
				lRet := .T.
				oModelVSJDet:SetValue("VSJ_CODITE", Space(GetSX3Cache("B1_CODITE","X3_TAMANHO")) )
			EndIf
			If lRet
				M->VO3_GRUITE := cGruIte // variavel utilizada na Consulta Padrão 'B01'
			EndIf
		Case ReadVar() == "M->VSJ_CODITE"
			If !Empty(cCodIte)
				If FG_POSSB1('cCodIte','SB1->B1_CODITE','cGruIte')
					lRet := .T.
					oModelVSJDet:LoadValue("VSJ_CODITE", SB1->B1_CODITE) // Necessário carregar para validar o grupo e código antes do SetValue
					oModelVSJDet:SetValue("VSJ_GRUITE", SB1->B1_GRUPO)
					oModelVSJDet:SetValue("VSJ_CODITE", SB1->B1_CODITE)
					oModelVSJDet:LoadValue("VSJ_DESITE", SB1->B1_DESC)
					M->VO3_GRUITE := SB1->B1_GRUPO // variavel utilizada na Consulta Padrão 'B01'
				EndIf
			Else
				lRet := .T.
				oModelVSJDet:LoadValue("VSJ_DESITE", Space(GetSX3Cache("B1_DESC","X3_TAMANHO")) )
			Endif
	EndCase

Return lRet

/*/{Protheus.doc} OA486006G_ValidaMotivo
	Validação do campo Motivo de Cancelamento, para o caso de usar a rotina "Demanda Retroativa"
	@type   Function
	@author Luiz Pereira
	@since 24/03/2025
/*/
Function OA486006G_ValidaMotivo()

	Local lRet := .T.
	Local oModel    := FWModelActive()
	Local oModelDet := oModel:GetModel('VSJDETAIL')
		
	DbSelectArea("VSJ")
	DbSetOrder(1) //VSJ_FILIAL+VSJ_NUMOSV+VSJ_GRUITE+VSJ_CODITE
	If DbSeek(xFilial("VSJ") + oModelDet:GetValue("VSJ_NUMOSV") + oModelDet:GetValue("VSJ_GRUITE") + oModelDet:GetValue("VSJ_CODITE"))
		If Empty(VSJ->VSJ_MOTPED)
			FMX_HELP("OA486006001", STR0020, STR0026) //"Não é possível atualizar o motivo de cancelamento para um item não cancelado."###"Para cancelar um item, utilize a opção Peças da OS, ou deixe este campo sem preenchimento para não informar um código de cancelamento."
			lRet := .F.
		ElseIf Empty(FwFldGet("VSJ_MOTPED")) //Campo na tela ficou vazio
			FMX_HELP("OA486006002", STR0021, STR0027) //"Não é possível remover o motivo de cancelamento de um item cancelado." ### "O campo não poderá ficar sem preenchimento, informe um código de cancelamento existente."
			lRet := .F.
		EndIf
	EndIf

	If lRet
		DbSelectArea("VS0") //Motivo de Cancelamento
		DbSetOrder(1) //VS0_FILIAL+VS0_TIPASS+VS0_CODMOT
		If !DbSeek(xFilial("VS0") + cMotivo + FwFldGet("VSJ_MOTPED"))
			FMX_HELP("OA486006003", STR0022, STR0028) //"Código de cancelamento inexistente." ### "Informe um código existente."
			lRet := .F.
		EndIf
	EndIf

Return(lRet)

/*/{Protheus.doc} OA486006G_CabDemandaRetroativa
	Validações do cabeçalho, quando for demanda retroativa
	@type   Function
	@author Luiz Pereira
	@since 24/03/2025
/*/
Function OA486007G_DemandaRetroativa()

	Local aRet      := {}
	Local aParamBox := {}
	Local oModel    := FWModelActive()
	Local oModelDet := oModel:GetModel('VSJDETAIL')
	Local oView		:= FWViewActive()
	Local nI        := 0
	Local cCodSit   := ""
	Local cMotPed   := ""
	Local aArea     := GetArea()
	Local aAreaVSJ  := VSJ->(GetArea())
	
	aAdd(aParamBox, { 1, RetTitle("VSJ_CODSIT"), Space(TamSX3("VSJ_CODSIT")[1]),"@!","OA486008G_ValidaDemandaRetroativa('MV_PAR01')","V09","",0,.F.})
	aAdd(aParamBox, { 1, RetTitle("VSJ_MOTPED"), Space(TamSX3("VSJ_MOTPED")[1]),"@!","OA486008G_ValidaDemandaRetroativa('MV_PAR02')","SA2","",0,.F.})
	
	If ! ParamBox(aParamBox, STR0023, @aRet,,,,,,,, .F., .F.) //"Preencher para Todos"
		Return .F.
	EndIf

	cCodSit   := aRet[1]
	cMotPed   := aRet[2]

	For nI := 1 to oModelDet:Length()
		oModelDet:goLine(nI)
		If !Empty(cCodSit)
			oModelDet:LoadValue("VSJ_CODSIT", cCodSit)
		EndIf

		If !Empty(cMotPed)
			DbSelectArea("VSJ")
			DbSetOrder(1) //VSJ_FILIAL+VSJ_NUMOSV+VSJ_GRUITE+VSJ_CODITE
			If DbSeek(xFilial("VSJ") + oModelDet:GetValue("VSJ_NUMOSV") + oModelDet:GetValue("VSJ_GRUITE") + oModelDet:GetValue("VSJ_CODITE"))
				If !Empty(VSJ->VSJ_MOTPED) //item cancelado e preencheu o código do motivo
					oModelDet:LoadValue("VSJ_MOTPED", cMotPed)
				EndIf
			EndIf
		EndIf
	Next

	oModelDet:goLine(1)
	oView:Refresh()

	RestArea(aAreaVSJ)
	RestArea(aArea)

Return()

/*/{Protheus.doc} OA486006G_CabDemandaRetroativa
	Responsável por validar os campos do Parambox da opção "Informar para Todos"
	@type   Function
	@author Luiz Pereira
	@since 29/03/2025
/*/

Function OA486008G_ValidaDemandaRetroativa(cPar)

	Local lRet := .T.

	If Empty(&cPar)
		Return(lRet)
	ElseIf cPar == "MV_PAR01" // Código da Situação

		DbSelectArea("V09")
		DbSetOrder(1) // V09_FILIAL+V09_CODSIT
		If !DbSeek(xFilial("V09") + MV_PAR01)
			FMX_HELP("OA486007001", STR0024, STR0028) //"Código de situação de demanda inexistente."
			lRet := .F.
		EndIf

	ElseIf cPar == "MV_PAR02" //Motivo de Cancelamento

		DbSelectArea("VS0")
		DbSetOrder(1) //VS0_FILIAL+VS0_TIPASS+VS0_CODMOT
		If !DbSeek(xFilial("VS0") + cMotivo + MV_PAR02)
			FMX_HELP("OA486007002", STR0025, STR0028) //"Código de cancelamento inexistente."
			lRet := .F.
		EndIf

	EndIf

Return(lRet)

/*/{Protheus.doc} OA4860091_ChamaAnaliseItem
	Chamada da Analise de Itens

	@author Andre Luis Almeida
	@since 29/05/2025
/*/
Static Function OA4860091_ChamaAnaliseItem()
Local oModel := FWModelActive()
Local oModelVSJDet := oModel:GetModel('VSJDETAIL')
OC001CONANA( oModelVSJDet:GetValue("VSJ_GRUITE") , oModelVSJDet:GetValue("VSJ_CODITE") )
Return()

/*/{Protheus.doc} OA4860106_AtualizaDados
Carrega dados do inconveniente selecionado
@type function
@version  
@author Jessé Augusto
@since 31/12/2026
@param cNumOS, character, param_description
@return variant, return_description
/*/
Static Function OA4860106_AtualizaDados( cNumOS )
	
	Local oModel 	   := FWModelActive()
	Local oViewAct 	   := FWViewActive()
	Local oModelVSJDet := oModel:GetModel("VSJDETAIL")

	Local aAux         := {}

	If ReadVar() == "M->VSJ_SEQINC"

		aAux := OM420SELINCON({},{},,'2', cNumOS ,)
		
		oModelVSJDet:LoadValue('VSJ_GRUINC', aAux[1] )
		oModelVSJDet:LoadValue('VSJ_CODINC', aAux[2] )
		oModelVSJDet:LoadValue('VSJ_DESINC', aAux[3] )
		oModelVSJDet:LoadValue('VSJ_SEQINC', aAux[4] )
		
		oViewAct:Refresh()
	EndIf

Return .T.

/*/{Protheus.doc} OA4860115_Solicitacoes

	@type function
	@author Renato Vinicius
	@since 30/03/2023
/*/

Function OA4860115_Solicitacoes()

	Local oModelAct	:= FWModelActive()
	Local oViewAct 	:= FWViewActive()
	Local aArea     := GetArea()

	Local aIteSug := {}

	If oModelAct:VldData()

		If oModelAct:lModify 
			ForceToHideMessage(oViewAct)
			oViewAct:ButtonOkAction(.F.)
		Endif

		If FindFunction("OFIA611")
			OFIA611( "3", VO1->VO1_FILIAL , VO1->VO1_NUMOSV )
		EndIf

		fRefresh(oModelAct,oViewAct)

	Else

		FMX_HELP("VLDOFIA486002", oModelAct:GetErrorMessage()[6], "")

	EndIf

Return
