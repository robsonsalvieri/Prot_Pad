#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
/*/{Protheus.doc} GFEA058A 
	Permite selecionar/criar uma viagem para um romaneio
@author siegklenes.beulke
@since 21/06/2016
@version 1.0
@param cNrRom, characters, numero do romaneio
@param cCdTrp, characters, transportador
@param cViagem, characters, viagem posicionada
@return cVigRet, characters, nova viagem(se for criada) 
@example
(examples)
@see (links_or_references)
/*/
Function GFEA058A(cNrRom,cCdTrp,cViagem)

	Local oDlg
	Local nAlt := (GetScreenRes()[2])
	Local nLrg := (GetScreenRes()[1]-100)
	Local aNewButton := {}
	Local aMKB
	Local aCpMKB
	
	Private cCadastro := "Viagem"
	Private cMarca := GetMark()
	Private cAliMKBA58
	Private oMark
	Private _cCdTrp := cCdTrp
	Private _cViagem := cViagem
	Private cVigRet := ""
	
	//Trata a altura da janela de acordo com a resolução
	If nAlt > 1000
		nAlt -= (nAlt - 900) * 80/100
	ElseIf nAlt < 900
		nAlt += (900 - nAlt) * 90/100
	EndIf
	
	Aadd(aNewButton,{"novacelula" ,{||Processa({|lEnd| GFE58BNVG()},"Processando informações","Aguarde")},"Nova viagem","Nova viagem"})
	
		//----------------------------------------------
	// Criacao da tabela temporaria p/ Markbrowse
	//----------------------------------------------

	aMKB :=    {{"OK"       ,"C",02,0},;
				{"VIAGEM"   ,"C",8 ,0}}

	aCpMKB  := {{"OK"        ,NIL,"",""},;
				{"VIAGEM"  ,NIL,"Viagem",""}} //"Tipo de Veículo"

	cAliMKBA58 := GFECriaTab({aMKB,{"VIAGEM"}})
	
	CursorWait()
	
	//--------------------------
	// Montagem da tela
	//--------------------------
	Define MsDialog oDlg Title cCadastro From 500,120 To nAlt,nLrg Of oMainWnd Color CLR_BLACK,RGB(225,225,225) Pixel
	oDlg:lEscClose := .F.

	oPnlA := tPanel():New(00,00,,oDlg,,,,,,30,35,.F.,.F.)
	oPnlA:Align := CONTROL_ALIGN_TOP

	oPnlB := tPanel():New(00,00,,oDlg,,,,,,30,40,.F.,.F.)
	oPnlB:Align := CONTROL_ALIGN_ALLCLIENT

	@ 07,10  Say "Romaneio" Of oPnlA COLOR CLR_BLACK Pixel
	@ 05,63  MSGET cNrRom   Picture "@!" Of oPnlA When .F. Pixel

	dbSelectArea(cAliMKBA58)
	dbSetOrder(01)
	dbGoTop()

	oMark := MsSelect():New(cAliMKBA58,"OK",,aCpMKB,,@cMarca,{0,0,0,0},,,oPnlB)
	oMark:oBrowse:bLDblClick := { || GFEA58CHK() }
	oMark:oBrowse:cToolTip := "Visualização"
	oMark:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

	Processa({|lEnd| GFEA58CRG()},"Processando informações","Aguarde") //###

	CursorArrow()

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(ODlg,{||If(GFEA58OK(),ODlg:End(),NIL)},;
		{||If(APMSGYESNO("Confirma o fechamento da tela?"),ODlg:End(),)},,aNewButton) CENTERED

	GFEDelTab(cAliMKBA58)

Return cVigRet

Static Function GFEA58OK()
	dbSelectArea(cAliMKBA58)
	dbSetOrder(01)
	dbGoTop()
	While !Eof()
		If IsMark('OK',cMarca)
			cVigRet := (cAliMKBA58)->VIAGEM
			Exit
		EndIf
	    dbSkip()
	EndDo
Return .T.

Static Function GFEA58CHK()

	Local lMArk := .T.
	Local nREc  := (cAliMKBA58)->(RecNo())
	
	If (cAliMKBA58)->(BOF()) .And. (cAliMKBA58)->(EOF())
		Return
	EndIf  

	dbSelectArea(cAliMKBA58)
	dbSetOrder(01)

	If !IsMark('OK',cMarca)
		dbGoTop()
		While !Eof()
			If IsMark('OK',cMarca)
				msgInfo("Já existe um registro selecionado","Aviso")
				lMark := .F.
				Exit
			EndIf
		    dbSkip()
		EndDo
	EndIf

	dbGoTo(nRec)
	If lMArk
		RecLock(cAliMKBA58,.F.)
		(cAliMKBA58)->OK := If(IsMark('OK',cMarca),"  ",cMarca)
		MsUnLock(cAliMKBA58)

	EndIf

	oMark:oBrowse:Refresh()

Return

Static Function GFEA58CRG()
	
	Local cQuery    := ''
	Local cAliasQry := GetNextAlias()
	Local nRecMkb := 0
	
	DbSelectArea(cAliMKBA58)
	ZAP
	
	cQuery := "SELECT GWP.GWP_VIAGEM"
	cQuery += " FROM "+RetSqlName('GWP')+" GWP"
	cQuery += " WHERE GWP.GWP_FILIAL = '"+xFilial('GWP')+"'"
	cQuery +=   " AND GWP.GWP_SIT    = '1'" //Situação Aberto
	cQuery +=   " AND GWP.GWP_CDTRP  = '" + _cCdTrp + "'"
	cQuery +=   " AND GWP.D_E_L_E_T_ = ' '"
	cQuery += " ORDER BY GWP.GWP_VIAGEM"
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
	
	While (cAliasQry)->(!Eof())
	
		RecLock((cAliMKBA58),.T.)
		(cAliMKBA58)->VIAGEM  := (cAliasQry)->GWP_VIAGEM
		If _cViagem == (cAliasQry)->GWP_VIAGEM
			(cAliMKBA58)->OK := cMarca
		EndIf
		
		(cAliMKBA58)->(MsUnlock())
		
		If _cViagem == (cAliasQry)->GWP_VIAGEM
			nRecMkb := (cAliMKBA58)->(RecNo())
		EndIf
		
		(cAliasQry)->(DbSkip())
	EndDo
	(cAliasQry)->(DbCloseArea())
	(cAliMKBA58)->(DbGoTop())
	
	If nRecMkb != 0
		(cAliMKBA58)->(dbGoTo(nRecMkb))
	EndIf
	oMark:oBrowse:Refresh()
   
   
   
Return .T.

Function GFE58ANVG(cTransp)
	Local oModel := FwLoadModel("GFEA058")
	Local oModelGWP
	Local aRet := {.T.,"",""}
	Local aErro
	Default cTransp := _cCdTrp

	oModel:SetOperation(MODEL_OPERATION_INSERT)

	If !oModel:Activate()
		aRet[1] := .F.
		aErro := oModel:GetErrorMessage()
		aRet[2] := AllToChar(aErro[6]) + CRLF +;
					 AllToChar(aErro[7]) + CRLF + CRLF +;
					 "Campo: " + AllToChar(aErro[2]) + CRLF +;
					 "Valor: " + AllToChar(aErro[9])
	Else
		FwModelActive(oModel)
		oModelGWP := oModel:GetModel("GFEA058_GWP")
		//Pode ser um array com loop, se precisar
		If !oModelGWP:SetValue("GWP_CDTRP",cTransp)
			aRet[1] := .F.
			aErro := oModel:GetErrorMessage()
			aRet[2] := AllToChar(aErro[6]) + CRLF +;
						 AllToChar(aErro[7]) + CRLF + CRLF +;
						 "Campo: " + AllToChar(aErro[2]) + CRLF +;
						 "Valor: " + AllToChar(aErro[9])
			
		EndIf
		
		If oModel:VldData()
			oModel:CommitData()
			aRet[3] := GWP->GWP_VIAGEM
			oModel:DeActivate()
			FreeObj(oModel)
		Else
			aRet[1] := .F.
			aErro := oModel:GetErrorMessage()
			aRet[2] := AllToChar(aErro[6]) + CRLF +;
						 AllToChar(aErro[7]) + CRLF + CRLF +;
						 "Campo: " + AllToChar(aErro[2]) + CRLF +;
						 "Valor: " + AllToChar(aErro[9])
		EndIf
	EndIf
	
Return aRet

Function GFE58BNVG(cTransp)
	Local aRet 
	Default cTransp := _cCdTrp
	aRet := GFE58ANVG(cTransp)
	If aRet[1] == .F.
		MsgStop(aRet[2],'Atenção')
	Else
		_cViagem := aRet[3]
		GFEA58CRG()
	EndIf
Return 
