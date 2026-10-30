#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

Function GFEA053()
	Private dDataCalc
	Private oBrowse
	Private cAliMKB
	Private aCpMKB
	Private cMarca := GetMark()
	CursorWait()
	
	Processa({|lEnd| GFEA53CRG()},"Processando informações","Aguarde")

	oBrowse := FWMarkBrowse():New()
	oBrowse:SetTemporary(.T.)
	oBrowse:SetAlias(cAliMKB)			// Alias da tabela utilizada
	oBrowse:SetFields(aCpMKB)
	oBrowse:SetFieldMark("OK")
	oBrowse:SetMenuDef("GFEA053")	// Nome do fonte onde esta a função MenuDef
	oBrowse:SetDescription("Conciliação de Vale Pedágio")	// Descrição do browse //"Romaneios de Carga"
	oBrowse:SetCustomMarkRec({|| GFEA53CHK()})
	oBrowse:AddLegend("VP=='2'", "RED" , "Não Conferido") //"Digitado"
	oBrowse:AddLegend("VP=='3'", "GREEN", "Conferido") //"Emitido"

	oBrowse:Activate()
	CursorArrow()
Return

Static Function GFEA53CHK()
	Local lMark := !oBrowse:IsMark(oBrowse:Mark())

	dbSelectArea(cAliMKB)
	dbSetOrder(01)
	RecLock(cAliMKB,.F.)
	(cAliMKB)->OK := IIf(lMark, oBrowse:Mark(), "  ")
	MsUnLock(cAliMKB)
	
	If !GFE53VLDMK()[1]
		RecLock(cAliMKB,.F.)
		(cAliMKB)->OK := "  "
		MsUnLock(cAliMKB)
	EndIf
	
	oBrowse:Refresh()
Return .T.

Static Function GFEA53CRG()

	aMKB :=    {{"OK"         ,"C",02,0},;
				{"VP"          ,"C",01,0},;
				{"GWN_VPCDOP" ,"C",TamSX3("GWN_VPCDOP")[1],0},;
				{"GWN_VPNMOP" ,"C",TamSX3("GWN_VPNMOP")[1],0},;
				{"GWN_DTIMPL" ,"D",TamSX3("GWN_DTIMPL")[1],0},;
				{"GWN_DTSAI"  ,"D",TamSX3("GWN_DTSAI")[1],0},;
				{"GWN_NRROM"  ,"C",TamSX3("GWN_NRROM")[1],0},;
				{"GWN_PLACAD" ,"C",TamSX3("GWN_PLACAD")[1],0},;
				{"GWN_CDTRP"  ,"C",TamSX3("GWN_CDTRP")[1],0},;
				{"GWN_DSTRP"  ,"C",TamSX3("GWN_DSTRP")[1],0},;
				{"GWN_VPNUM"  ,"C",TamSX3("GWN_VPNUM")[1],0},;
				{"GWN_VPVAL"  ,"N",TamSX3("GWN_VPVAL")[1],2};
				}

	aCpMKB  := {;
				{"Código da Operadora","GWN_VPCDOP","C",TamSX3("GWN_VPCDOP")[1],0},; 
				{"Nome da Operadora" ,"GWN_VPNMOP","C",TamSX3("GWN_VPNMOP")[1],0},;
				{"Número do Comprovante"  ,"GWN_VPNUM","C",TamSX3("GWN_VPNUM")[1],0},;
				{"Valor do Pedágio"  ,"GWN_VPVAL","N",TamSX3("GWN_VPVAL")[1],TamSX3("GWN_VPVAL")[2],"@E 99,999.99"},; 
				{"Data de Criação do Romaneio" ,"GWN_DTIMPL","D",TamSX3("GWN_DTIMPL")[1],0},; 
				{"Data de Liberação do Romaneio"  ,"GWN_DTSAI","D",TamSX3("GWN_DTSAI")[1],0},;
				{"Número do Romaneio"  ,"GWN_NRROM","C",TamSX3("GWN_NRROM")[1],0},;
				{"Placa Dianteira" ,"GWN_PLACAD","C",TamSX3("GWN_PLACAD")[1],0},;
				{"Código do Transportador"  ,"GWN_CDTRP","C",TamSX3("GWN_CDTRP")[1],0},;
				{"Nome do Transportador"  ,"GWN_DSTRP","C",TamSX3("GWN_DSTRP")[1],0};		
				} 

	cAliMKB := GFECriaTab({aMKB,{"GWN_NRROM","OK+GWN_NRROM"}})

	dbSelectArea(cAliMKB)
	ZAP
		
	dbSelectArea("GWN")
	dbSetOrder(1)
	dbGoTop()
	ProcRegua( GWN->(RecCount()) )
	While !Eof()
		IncProc("Montando Lista de Conciliação")
		IF GWN->GWN_VALEP $ "23"
			RecLock((cAliMKB),.T.)
				(cAliMKB)->OK 			:= "  "
				(cAliMKB)->VP			:=	GWN->GWN_VALEP 
				(cAliMKB)->GWN_VPCDOP:=	GWN->GWN_VPCDOP
				(cAliMKB)->GWN_VPNMOP:=	Posicione("GU3",1,xFilial("GU3") + GWN->GWN_VPCDOP,"GU3_NMEMIT")
				(cAliMKB)->GWN_DTIMPL:=	GWN->GWN_DTIMPL
				(cAliMKB)->GWN_DTSAI	:=	GWN->GWN_DTSAI
				(cAliMKB)->GWN_NRROM	:=	GWN->GWN_NRROM
				(cAliMKB)->GWN_PLACAD:=	GWN->GWN_PLACAD
				(cAliMKB)->GWN_CDTRP	:=	GWN->GWN_CDTRP
				(cAliMKB)->GWN_DSTRP	:=	Posicione("GU3",1,xFilial("GU3") + GWN->GWN_CDTRP,"GU3_NMEMIT")
				(cAliMKB)->GWN_VPNUM	:=	GWN->GWN_VPNUM
				(cAliMKB)->GWN_VPVAL	:=	GWN->GWN_VPVAL
			
			msUnlock(cAliMKB)
		EndIf
		dbSelectArea("GWN")
		dbSkip()
	EndDo
	
	
	dbSelectArea(cAliMKB)
	dbGoTop()
Return .T.

Static Function MenuDef()
	Local aRotina := {}
		
	ADD OPTION aRotina TITLE 'Visualizar' ACTION 'GFE53VWROM()' 	OPERATION 2 ACCESS 0	
	ADD OPTION aRotina TITLE "Conferir" ACTION "GFE53CONF()" 	OPERATION 10 ACCESS 0 
	ADD OPTION aRotina TITLE "Alterar Pedágio" ACTION "GFE53ALTVP()" 	OPERATION 11 ACCESS 0  	
	ADD OPTION aRotina TITLE "Mostrar Total" ACTION "GFE53TOTAL()"      	OPERATION 12 ACCESS 0
	ADD OPTION aRotina TITLE "Desfazer Conferência" ACTION "GFE53DCONF()" OPERATION 10 ACCESS 0 
		
Return aRotina

Function GFE53CONF()

	If GFE53VLDMK(1)[1]
		dbSelectArea(cAliMKB)
		dbSetorder(2)
		dbGoTop()
		
		CursorWait()
		dbSeek(oBrowse:Mark())
		While !Eof()
			If oBrowse:IsMark(oBrowse:Mark())				
				RecLock(cAliMKB,.F.)
				(cAliMKB)->VP := "3"
				MsUnLock(cAliMKB)
				
				GWN->(dbSetOrder(1))
				If GWN->(dbSeek(xFilial("GWN") + (cAliMKB)->GWN_NRROM))
					RecLock("GWN",.F.)
					 GWN->GWN_VALEP := "3"
					MsUnLock("GWN")
				EndIf				
			EndIf
			dbSelectArea(cAliMKB)
			dbSkip()
		EndDo
		
		CursorArrow()
		
		dbSelectArea(cAliMKB)
		dbSetorder(1)
		dbGoTop()
	EndIf
	
Return

Function GFE53DCONF()

	If GFE53VLDMK(1)[1]
		dbSelectArea(cAliMKB)
		dbSetorder(2)
		dbGoTop()
		
		CursorWait()
		dbSeek(oBrowse:Mark())
		While !Eof()
			If oBrowse:IsMark(oBrowse:Mark())				
				RecLock(cAliMKB,.F.)
				(cAliMKB)->VP := "2"
				MsUnLock(cAliMKB)
				
				GWN->(dbSetOrder(1))
				If GWN->(dbSeek(xFilial("GWN") + (cAliMKB)->GWN_NRROM))
					RecLock("GWN",.F.)
					 GWN->GWN_VALEP := "2"
					MsUnLock("GWN")
				EndIf				
			EndIf
			dbSelectArea(cAliMKB)
			dbSkip()
		EndDo
		
		CursorArrow()
		
		dbSelectArea(cAliMKB)
		dbSetorder(1)
		dbGoTop()
	EndIf
	
Return

Function GFE53ALTVP()
	Local nValor
	Local lRet 
	Local aAreaMK := (cAliMKB)->(GetArea())
	If GFE53VLDMK(2)[1]
		dbSelectArea(cAliMKB)
		dbSetorder(2)
		
		dbSeek(oBrowse:Mark())
		nValor := (cAliMKB)->GWN_VPVAL 
		DEFINE MSDIALOG oDlg TITLE "Alterar Pedágio" From 4,0 To 100,250 OF oMainWnd PIXEL
		 
		//DEFINE MSDIALOG oObjetoDLG TITLE cTitulo FROM nLinIni,nColIni TO nLinFim,nColFim OF oObjetoRef UNIDADE
			@  4, 006  SAY "Valor Pedágio:" SIZE 60,7 PIXEL OF oDlg 
			@  3, 070  MSGET nValor When .T. PICTURE "@E 99,999.99" SIZE 49,7 PIXEL OF oDlg hasbutton

			oButtonOK   := tButton():New(35,66,'OK',oDlg,{||If(GFE53VP(nValor),oDlg:End(),lRet:=.F.)},25,10,,,,.T.)
			oButtonCanc := tButton():New(35,100,"Cancelar",oDlg,{||lRet:=.F.,oDlg:End()},25,10,,,,.T.)

		ACTIVATE MSDIALOG oDlg
	EndIf
	RestArea(aAreaMK)
Return

Function GFE53VP(nValor)
	Local lRet := .T.
	If nValor <= 0
		HELP(,,'HELP',,"O valor do pedágio deve ser maior que zero.",1,0)
		lRet := .F.
	EndIF
	
	If lRet
		RecLock(cAliMKB,.F.)
		(cAliMKB)->GWN_VPVAL:= nValor
		(cAliMKB)->VP := "3"
		MsUnLock(cAliMKB)
		
		GWN->(dbSetOrder(1))
		If GWN->(dbSeek(xFilial("GWN") + (cAliMKB)->GWN_NRROM))
			RecLock("GWN",.F.)
			 GWN->GWN_VPVAL := nValor
			 GWN->GWN_VALEP := "3"
			MsUnLock("GWN")
		EndIf
		
	EndIf
Return lRet 

Function GFE53TOTAL()
	Local aValor := GFE53VLDMK(3)
	Local nValor := 0
	Local lRet
	
	If aValor[1]
		nValor := aValor[2]
		DEFINE MSDIALOG oDlg TITLE "Total Selecionado" From 4,0 To 100,250 OF oMainWnd PIXEL
		 
		//DEFINE MSDIALOG oObjetoDLG TITLE cTitulo FROM nLinIni,nColIni TO nLinFim,nColFim OF oObjetoRef UNIDADE
			@  4, 006  SAY "Valor Pedágio:" SIZE 60,7 PIXEL OF oDlg 
			@  3, 070  MSGET nValor When .F. PICTURE "@E 9,999,999.99" SIZE 49,7 PIXEL OF oDlg hasbutton

			oButtonOk := tButton():New(35,100,'OK',oDlg,{||lRet:=.F.,oDlg:End()},25,10,,,,.T.)

		ACTIVATE MSDIALOG oDlg
	EndIf
Return

Function GFE53VLDMK(nTipoMark)
	Local cTipo := ""
	Local nMark := 0
	Local lRet := .T.
	Local aAreaMK := (cAliMKB)->(GetArea())
	Local nTotal := 0
	Default nTipoMark := 0
	
	dbSelectArea(cAliMKB)
	dbSetorder(2)

	dbSeek(oBrowse:Mark())
	
	While !Eof() .And. lRet
		If Empty(cTipo)
			cTipo:= (cAliMKB)->VP
		EndIf
		
		If cTipo != (cAliMKB)->VP .And. nTipoMark < 3
			HELP(,,'HELP',,"Os registros selecionados devem possuir a mesma Situação da Conferência",1,0)
			lRet := .F.
		EndIf
		
		nMark++
		nTotal+=(cAliMKB)->GWN_VPVAL
		
		dbSkip()
	EndDo
	
	dbSeek(oBrowse:Mark())
	If nTipoMark > 0 .And. nMark == 0
		HELP(,,'HELP',,"Ao menos um registro deve estar selecionado.",1,0)
		lRet := .F.
	ElseIf nTipoMark == 2 .And. nMark > 1
		HELP(,,'HELP',,"Somente um registro deve estar selecionado.",1,0)
		lRet := .F.
	ElseIf nTipoMark == 2 .And. nMark == 1 .And. (cAliMKB)->VP == "3"
		HELP(,,'HELP',,"Não é possivel alterar o Valor do Pedágio quando o mesmo está Conferido. Desfaça a conferência antes de alterar o valor.",1,0)
		lRet := .F.
	EndIf
	
	RestArea(aAreaMK)
	
Return {lRet,nTotal}

Function GFE53VWROM()
	dbSelectArea("GWN")
	GWN->(dbSetOrder(1))
	If GWN->(dbSeek(xFilial("GWN") + (cAliMKB)->GWN_NRROM))
		FWExecView("Visualizar","GFEC050",1,,{||.T.})
	EndIf
Return