#INCLUDE "PROTHEUS.CH"

/*
{Protheus.doc} GFEUFIX
Programa para mostrar os programas de acerto em um grid dinamicamente

@sample
GFEUFIX()

@author Octávio Augusto Felippe de Macedo
@since 11/11/2011
@version 1.0
*/

Function GFEUFIX()
	Local cDe  := "01"
	Local cAte := Space(2)
	
	Private lButOk := .F.
	Private oFootAtu, oFootDes
	Private oDlgFix		
	cMarca := GetMark()
	                                   
	aMKB := {{"GFEOK"  , "C", 2 , 0}, ;
			 {"GFEFUN" , "C", 8 , 0}, ;
			 {"GFEEXEC", "D", 8 , 0}, ;
			 {"GFEMEMO", "C", 5 , 0}, ;
			 {"GFEUSU" , "C", 63, 0}, ;
			 {"GFECLR" , "C", 1 , 0}}
	                       
	aCpMKB := {{"GFEOK"  , NIL, ""          , ""  }, ;
			   {"GFEFUN" , NIL, "Função"    , "@!"}, ;
			   {"GFEEXEC", NIL, "Executada?", "@" }, ;
			   {"GFEMEMO", NIL, "Descrição" , ""  }, ;
			   {"GFEUSU" , NIL, "Usuário "  , "@" }}
	
	cAli := GFECriaTab({aMKB,{"GFEFUN"}})
	
	(cAli)->( dbGoTop() )
	
	Define MSDialog oDlgFix Title "Funções de Manutenção" From 0, 0 To 270, 450 Pixel
		
		oPanel1 := tPanel():New(0,0,,oDlgFix,,,,,,31,15,.F.,.F.)
		oPanel1:Align := CONTROL_ALIGN_TOP
	    
	    TSay():New(4, 65,{||"Atualização da Empresa : " + SM0->M0_CODIGO},oPanel1,,TFont():New('Arial',,-12,,.T.),,,,.T.,CLR_BLACK,CLR_WHITE,200,20)
		
		oPanel2 := tPanel():New(0,0,,oDlgFix,,,,,,31,15,.F.,.F.)
		oPanel2:Align := CONTROL_ALIGN_ALLCLIENT
		
		oPanel3 := tPanel():New(0,0,,oPanel2,,,,,,31,15,.F.,.F.)
		oPanel3:Align := CONTROL_ALIGN_TOP
		
		TSay():New(4, 2,{||"De GFEFIX"},oPanel3,,TFont():New('Arial',,-12,,.T.),,,,.T.,CLR_BLACK,CLR_WHITE,50,20)
		TGet():New(3, 31,{|u| If(PCount()>0,cDe:=u,cDe)},oPanel3,10,8,"@! 99",,,,,,,.T.,,,{|| .T.},,,,,,,"cDe")
		
		TSay():New(4, 56,{||"Até GFEFIX"},oPanel3,,TFont():New('Arial',,-12,,.T.),,,,.T.,CLR_BLACK,CLR_WHITE,50,20)
		TGet():New(3, 87,{|u| If(PCount()>0,cAte:=u,cAte)},oPanel3,10,8,"@! 99",,,,,,,.T.,,,{|| .T.},,,,,,,"cAte")						
		
	    TBtnBmp2():New(6, 228, 20, 20, "CHECKED"  , "CHECKED"  ,,,{|| TABLESEL(cDe,cAte, 1)}, oPanel3, "Selecionar"   ,, .T.)
	    TBtnBmp2():New(6, 253, 20, 20, "UNCHECKED", "UNCHECKED",,,{|| TABLESEL(cDe,cAte, 2)}, oPanel3, "Desselecionar",, .T.)
	    TBtnBmp2():New(4, 420, 25, 25, "SDUERASE" , "SDUERASE" ,,,{|| TABLEDEL(@cAte)      }, oPanel3, "Limpar"       ,, .T.)
	    
	 	TSay():New(4, 162, {|| "Limpar histórico"}, oPanel3,, TFont():New('Arial',,-12,,.T.),,,, .T., CLR_BLACK, CLR_WHITE, 50, 100)
	 	
		oMark := MsSelect():New(cAli,"GFEOK",,aCpMKB,,@cMarca,{0,0,0,0},,,oPanel2)
		oMark:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
		oMark:oBrowse:bLDblClick := {|x,nCol| IIf(nCol == 4, TABLEMEMO(), TABLECHK())}
		; 
		oMark:oBrowse:SetBlkBackColor({|| GFEUFIXCLR()})
		
		oMark:oBrowse:lHScroll := .F.
		oMark:oBrowse:Refresh()
		
		oPanel2 := tPanel():New(0,0,,oDlgFix,,,,,,31,15,.F.,.F.)
		oPanel2:Align := CONTROL_ALIGN_BOTTOM
		
		oFootAtu := TSay():New(4, 5,{|| "Todos os programas de acerto foram aplicados." },oPanel2,,TFont():New('Arial',,-10,,.F.),,,,.T.,CLR_BLUE,CLR_WHITE,140,20)
		oFootDes := TSay():New(4, 5,{|| "Há programas de acerto não executados!" },oPanel2,,TFont():New('Arial',,-10,,.T.),,,,.T.,CLR_RED,CLR_WHITE,140,20)
		oBtn  := tButton():New(3,185,"Fechar"  ,oPanel2,{|| oDlgFix:End()},30,10,,,,.T.)
	   	oBtn  := tButton():New(3,145,"Executar",oPanel2,{|| IIf(GFEMANOK(), oDlgFix:End(), Nil)},30,10,,,,.T.) 
	   	
		Processa({|| TABLEFILL(@cAte)},"Carregando tabelas")
		
	Activate MSDialog  oDlgFix Center			
	
	If lButOk				
		MsgInfo("Atualização realizada com sucesso!", "Aviso")
	EndIf

Return

//-------------------------------

Static Function GFEUFIXCLR()
	
	Local nColor := RGB(183, 216, 255)
	
	If !Empty((cAli)->GFEEXEC)
		
		nColor := RGB(166, 239, 141)
		
	ElseIf (cAli)->GFECLR == "1"
	
		nColor := RGB(254, 254, 254)
	
	EndIf
	
Return nColor

//-------------------------------

Static Function TABLEMEMO()

	Local cTexto
	Local oDlg2
	
	cTexto := GFE115DS(SubStr((cAli)->GFEFUN,7))
	
	DEFINE MSDIALOG oDlg2 TITLE (cAli)->GFEFUN From 0,0 To 18,70 OF oMainWnd
		@ 4, 006 SAY "Correções do Programa de Acerto: " SIZE 130,7 PIXEL OF oDlg2
		
	    oTMultiget1 := TMultiget():New(13,06,{|u|If(Pcount()>0,cTexto:=u,cTexto)},;
	                           oDlg2,265,105,,,,,,.T.,,,,,,.T.)
	
		oButtonOK   := tButton():New(125,5,'GFEOK',oDlg2,{|| oDlg2:End()},25,10,,,,.T.)
		
	ACTIVATE MSDIALOG oDlg2 CENTER

Return

//-------------------------------

Static Function GFEMANOK()
	
	Local aFunc := {}
	Local nI
	Local cMsg  := ""
	
	dbSelectArea(cAli)
	(cAli)->( dbGoTop() )
	While !(cAli)->( Eof() )
		
		AAdd(aFunc, {(cAli)->GFEFUN, IsMark("GFEOK",cMarca), (cAli)->GFEEXEC})
		
		dbSelectArea(cAli)
		(cAli)->( dbSkip() )	
	EndDo
	
	(cAli)->( dbGoTop() )
	
	If AScan(aFunc, {|x| x[2]}) == 0
		Tone()
		MsgInfo("Não foram selecionadas funções para executar!")
		Return .F.
	EndIf
	
	If MsgYesNo("Deseja executar os programas de acerto selecionados?", "Aviso")
		
		GFEDelTab(cAli)
		
		lButOk := .T.
		
		For nI := 1 To Len(aFunc)
			
			If aFunc[nI][2] .And. Empty(aFunc[nI][3])
				If !&(aFunc[nI][1] + "()")
					lButOk := .F.
				EndIf
			EndIf
			
		Next nI
	Else
		Return .F.
	EndIf
	
Return .T.

//-------------------------------

Static Function TABLESEL(cDe, cAte, cOp)
	
	If !Empty(cDe)
		cDe := StrZero(Val(cDe), 2)
	EndIf
	
	If !Empty(cAte)
		cAte := StrZero(Val(cAte), 2)
	EndIf
	
	dbSelectArea(cAli)
	(cAli)->( dbGoTop() )
	While !(cAli)->( Eof() )
	
		If IIf(Empty(cDe), .T., SubStr((cAli)->GFEFUN, 7) >= cDe) .And. IIf(Empty(cAte), .T., SubStr((cAli)->GFEFUN, 7) <= cAte) .And. Empty((cAli)->GFEEXEC)
			
			RecLock(cAli,.F.)
				(cAli)->GFEOK := IIf(cOp==1, cMarca, " ")
			MsUnlock(cAli)
		
		EndIf
		
		dbSelectArea(cAli)
		(cAli)->( dbSkip() )	
	EndDo
	
	(cAli)->( dbGoTop() )

Return

//------------------------------------------

Static Function TABLEDEL(cAte)
	
	Local aAreaGW0 := GW0->( GetArea() )
	Local cTabela  := PadR("GFEUFIX", TamSX3("GW0_TABELA")[1])
	Local cFilGW0  := Space(Len(xFilial("GW0")))
	
	If MsgYesNo("Deseja eliminar TODOS os registros de execução (datas de execução/histórico) dos programas de acerto para poder reprocessá-los? " + ;
				"Este processo não desfaz as alterações realizadas pelo programa de acerto.", "Aviso")
	
		dbSelectArea("GW0")
		GW0->( dbSetOrder(1) )
		GW0->( dbSeek(cFilGW0 + cTabela + (cAli)->GFEFUN) )
		While !GW0->( Eof() ) .And. GW0->GW0_FILIAL == cFilGW0 .And. GW0->GW0_TABELA == cTabela
			
			RecLock("GW0")
				dbDelete()
			GW0->( MSUnlock() )
			
			GW0->( dbSkip() )
		EndDo
	
		RestArea(aAreaGW0)
		
		TABLEFILL(@cAte)
		
		oMark:oBrowse:Refresh()
		
	EndIf

Return Nil

//-------------------------------

Static Function TABLECHK()
      
	If !Empty((cAli)->GFEEXEC)
		MsgInfo("Esse programa de acerto já foi executado, não poderá ser selecionado!")
		Return .F.
 	EndIf
 	
	RecLock(cAli,.F.)
		(cAli)->GFEOK := If(IsMark("GFEOK",cMarca), " ", cMarca)
	MsUnlock(cAli)
	
Return

//-------------------------------
      
Static Function TABLEFILL(cAte)
	
	Local nIni   := 1
	Local cFun
	Local dExec
	Local cUsu
	Local lAtual := .T. 
	
	dbSelectArea(cAli)
	ZAP
	
	While FindFunction( (cFun := "GFEFIX" + StrZero(nIni, 2)) )
		
		dbSelectArea("GW0")
		GW0->( dbSetOrder(1) )
		If GW0->( dbSeek(Space(Len(xFilial("GW0"))) + PadR("GFEUFIX", TamSX3("GW0_TABELA")[1]) + PadR(cFun, TamSX3("GW0_CHAVE")[1])) )
			dExec := GW0->GW0_DATA01
			cUsu  := GW0->GW0_CHAR01
		Else
			dExec  := CToD("  /  /    ")
			cUsu   := "---"
			lAtual := .F.
		EndIf
		
		RecLock(cAli, .T.)
			(cAli)->GFEFUN  := cFun
			(cAli)->GFEEXEC := dExec
			(cAli)->GFEUSU  := cUsu
			(cAli)->GFEMEMO := "Memo"
			(cAli)->GFECLR  := IIf((nIni % 2) == 0, "1", "2")
		MsUnlock(cAli)
		
		nIni++
		
	EndDo
	
	oMark:oBrowse:GoTop()
	
	If lAtual
		oFootAtu:Show()
		oFootDes:Hide()
	Else
		oFootAtu:Hide()
		oFootDes:Show()
	EndIf
	
	cAte := StrZero(nIni-1,2)

Return

//---------------------------------------

Static Function GFE115DS(cFun)
	
	Local cDesc := "Não há descrição para esta função!"
	
	If cFun == "01"
		
		cDesc := 'Programa de acerto para informar a Ocorrência que gerou o Cálculo, informando o campo GWF_NROCO.' + CRLF + CRLF + ;
				 'Updates necessários: ' + CRLF + ;
				 '-U_GFE11507'
		
	ElseIf cFun == "02"
		
		cDesc := 'Programa de acerto para informar o campo de Transportador da Ocorrência conforme os Documentos de Carga vinculados, ' +;
				 'e informar os campos Ação DC e Ação DF da Ocorrência conforme o seu Tipo.' + CRLF + CRLF + ;
				 'Updates necessários: ' + CRLF + ;
				 '-U_GFE11532'
		
	ElseIf cFun == "03"
		
		cDesc := 'Colocar ":" na hora de liberação dos Romaneios que foram salvos apenas com os números.'
		
	ElseIf cFun == "04"
		
		cDesc := 'Preenchimento dos campos GU3_CATTRP e GU3_MODAL conforme a parametrização dos campos GU3_EMFIL e GU3_AUTON.' + CRLF + CRLF + ;
				 'Updates necessários: ' + CRLF + ;
				 '-U_GFE11540'
		
	ElseIf cFun == "05"
		
		cDesc := 'Refaz os rateios contábeis(GWM) com a nova estrutura de unidade de negócio.'
		
	ElseIf cFun == "08"
		
		cDesc := "Acertar a base do GFE alterando os Códigos dos Emitentes por uma numeração sequencial para cada Emitente." + CRLF + CRLF +;
					"Pré-requisitos:" + CRLF +;
					"-> Antes de executar o GFEFIX08 o parâmetro MV_EMITMP (Numeração Própria) deve estar igual a '1=Numeração Própria'!" + CRLF +;
					"-> Caso a tabeça GU3 seja Exclusiva, o programa de acerto GFEFIX08 deve ser executado para cada Filial." + CRLF + CRLF +;
					"-> É de EXTREMA IMPORTÂNCIA que seja feito um Backup (Cópia) da Base antes de executar o programa de acerto GFEFIX08!"
	ElseIf cFun == "11"
		
		cDesc := "Acerta a base do GFE eliminando os Emitentes integrados pela numeração própria que estejam duplicados." + CRLF + CRLF +;
					"Pré-requisitos:" + CRLF +;
					"-> Antes de executar o GFEFIX11 o parâmetro MV_EMITMP (Numeração Própria) deve estar igual a '1=Numeração Própria'!" + CRLF +;
					"-> É de EXTREMA IMPORTÂNCIA que seja feito um Backup (Cópia) da Base antes de executar o programa de acerto GFEFIX11!"
					
	ElseIf cFun == "13"
		
		cDesc := "Acerta a base do Protheus preenchendo a data de entrega dos documentos de saída integrados ao GFE cujos documentos estejam com a situação Entregue." + CRLF + CRLF +;
					"Pré-requisitos:" + CRLF +;
					"-> Antes de executar o GFEFIX13:" + CRLF +; 
					"->o parâmetro MV_INTGFE (Integração GFE Ativo) deve estar ativo!"+ CRLF +;
					"->o parâmetro MV_ERPGFE (Erp Integrado) deve ser Protheus !"+ CRLF +; 
					"->o parâmetro MV_INTGFE2 (Modo Integração) deve ser Direto!"+ CRLF +; 
					"->o parâmetro MV_GFEIDTE (Registrar Integra) deve estar ativo!"+ CRLF +;  
					"-> É de EXTREMA IMPORTÂNCIA que seja feito um Backup (Cópia) da Base antes de executar o programa de acerto GFEFIX13!"

	ElseIf cFun == "19"
		
		cDesc := 'Programa de acerto para corrigir a base e o valor de PIS/COFINS '
		
			
	EndIf

Return cDesc

//-------------------------------------------

Function GFEUFIXATU(cFun)
	
	dbSelectArea("GW0")
	GW0->( dbSetOrder(1) )
	If !GW0->( dbSeek(Space(Len(xFilial("GW0"))) + PadR("GFEUFIX", TamSX3("GW0_TABELA")[1]) + PadR(cFun, TamSX3("GW0_CHAVE")[1])) )
		
		RecLock("GW0", .T.)
			GW0->GW0_TABELA := "GFEUFIX"
			GW0->GW0_CHAVE  := cFun
			GW0->GW0_CHAR01 := GetComputerName()
			GW0->GW0_DATA01 := Date()
		GW0->( MSUnlock() )
		
	EndIf
	
Return Nil

//-------------------------------------------

Function GFEUFIXCAD(cFunc, aUpd, cMsg)
	
	Local cFilGW0
	Local cTabela
	Local cFun
	Local nI
	
	Default aUpd := {}
	
	If Empty(Select("GW0"))
		dbSelectArea("GW0")
	EndIf
	
	cFilGW0 := Space(Len(xFilial("GW0")))	
	cTabela := PadR("GFEUFIX", TamSX3("GW0_TABELA")[1])
	cTabUpd := PadR("GFEUMAN", TamSX3("GW0_TABELA")[1])
	cFun    := PadR(cFunc, TamSX3("GW0_CHAVE")[1])
	
	dbSelectArea("GW0")
	GW0->( dbSetOrder(1) )
	If GW0->( dbSeek(cFilGW0 + cTabela + cFun) )
	
		cMsg := "O programa de acerto já foi executado."
		Return .F.
		
	EndIf
	
	For nI := 1 To Len(aUpd)
		
		dbSelectArea("GW0")
		GW0->( dbSetOrder(1) )
		If !GW0->( dbSeek(cFilGW0 + cTabUpd + aUpd[nI]) )
		
			cMsg := "O compatibilizador " + aUpd[nI] + " precisa estar executado!"
			Return .F.
			
		EndIf
		
	Next
	
Return .T.
