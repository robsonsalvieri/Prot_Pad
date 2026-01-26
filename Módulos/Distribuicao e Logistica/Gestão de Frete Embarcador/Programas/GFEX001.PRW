#INCLUDE "PROTHEUS.CH"
#INCLUDE "GFEX001.CH"

/*
{Protheus.doc} GFEX001
Rotina para apresentação dos logs do cálculo de frete e dos rateios contábeis

@sample
GFEX001()

@author Octávio Augusto Felippe de Macedo
@since 04/02/2011
@version 1.0
*/

Function GFEX001()

	Local oDlg     //Janela principal
	Local nAlt := 1050 //Altura de acordo com a resolução
	Local nLrg := 1098 //Largura de acordo com a resolução
	Local aFolder  //aba de calculo de frete
	Local oFolder  //aba de rateio contábil
	Local oPanelA  //painel de calculo de frete
	Local oPanelB  //painel de rateio contábil
	Local oGrdCal  //Objeto de grid do calculo
	Local oGrdRat  //Objeto de grid do rateio contábil
	Local aTbl     //Armazena a estrutura das tabelas
	Local oBtn     //Armazena os objetos para o botão
	Local oSay     //Armazena os objetos de texto
	Local oGet     //Armazena os objetos de textbox
	Local oMGet    //Armazena o objeto de MemoBox
	Local cLog  := ""  //Armazena o Log
	Local lNull := .F. //Indica se não houve resultados encontrados
	Local cDsArq := "" //Armazena a descrição do log visualizado
	Local cTplog := "" //Armazena a descrição do tipo de log visualizado
	//----------Variáveis do pergunte para exibição
	Private cCalcFret 
	Private cAcao
	Private cAgrup
	Private cNrDC
	Private cCDtDe
	Private cCDtAte
	Private cRatCont
	Private cNrCalc
	Private cDocFret
	Private cRDtDe
	Private cRDtAte
	//---------Tabelas temporárias
	Private cAliCal 
	Private cAliRat
	
	If Empty(SuperGetMv("MV_DRTLOG",,""))
		If MsgYesNo(STR0001,STR0002) // "O parâmetro 'MV_DRTLOG', que informa o diretório de logs do sistema, não foi preenchido. Gostaria de assumir o diretório padrão do servidor como '\system'?" ### "Aviso"
			PutMv("MV_DRTLOG","\system\")
		Else
			Return Nil
		EndIf
	EndIf
	
	//Parâmetros             
	If GFEX1PAR(Nil) == "1"//se igual a "1" o pergunte foi cancelado.
		Return Nil
	EndIf
	
	//Monta array para estrutura da tabela temporária
	aTbl := {{"ARQUIVO"  ,"C",100,0},;
			{"TAMANHO"   ,"C",10,0},;
			{"PERIODO"   ,"D",08,0},;
			{"HORA"      ,"C",08,0}}
	   
	//Alias da tabela temporária de rateio
	cAliRat := GFECriaTab({aTbl,{"PERIODO"}})
	//Alias da tabela temporária de cálculo  
	aAdd(aTbl, {"ACAO", "C", 10, 0})
	cAliCal := GFECriaTab({aTbl,{"PERIODO"}})
	
	CursorWait()                 
	
	//----------------Montagem da tela
	
	Define MsDialog oDlg Title "Consulta de Memória de Cálculo de Frete" From 500,120 To nAlt,nLrg Of oMainWnd Color CLR_BLACK,RGB(225,225,225) Pixel // "Visualização de Log"
	oDlg:lEscClose := .F.
	
	//Painel onde estarão os painéis dos botões e dos gets dos perguntes
	oPanelA := tPanel():New(0,0,,oDlg,,,,,,31,100,.F.,.F.)
	oPanelA:Align := CONTROL_ALIGN_TOP
	
	//Painel dos botões
	oPanelB := tPanel():New(0,0,,oPanelA,,,,,,30,15,.F.,.F.)
	oPanelB:Align := CONTROL_ALIGN_TOP
	
	//Painel com os gets dos perguntes
	oPanelC := tPanel():New(0,0,,oPanelA,,,,,CLR_WHITE,30,70,.F.,.F.)
	oPanelC:Align := CONTROL_ALIGN_ALLCLIENT
	
	//Painel onde estarão as abas
	oPanelD := tPanel():New(0,0,,oDlg,,,,,CLR_WHITE,30,35,.F.,.F.)
	oPanelD:Align := CONTROL_ALIGN_ALLCLIENT
	
	//Montagem do esquema de abas
	aFolder := {STR0004,STR0005,STR0006} // "Log de Cálculo"### "Log de Rateio Contábil" ### "Visualização do Log"
	oFolder := TFolder():New( 0, 0, aFolder, aFolder, oPanelD,,,, .T., , 492, 222 )
	oFolder:aEnable(3,.F.)
	oFolder:bChange := {|| }
	oFolder:Align := CONTROL_ALIGN_ALLCLIENT
	
	//Painel do grid de logs do cálculo de frete
	oPanelE := tPanel():New(0,0,,oFolder:aDialogs[1],,,,,,30,35,.F.,.F.)
	oPanelE:Align := CONTROL_ALIGN_ALLCLIENT
	
	//Painel do grid de logs do rateio contábil
	oPanelF := tPanel():New(0,0,,oFolder:aDialogs[2],,,,,,30,40,.F.,.F.)
	oPanelF:Align := CONTROL_ALIGN_ALLCLIENT
	
	//Painel onde será exibido o log
	oPanelG := tPanel():New(0,0,,oFolder:aDialogs[3],,,,,,31,15,.F.,.F.)
	oPanelG:Align := CONTROL_ALIGN_BOTTOM
	
	//------------Campos para informar os valores dos campos do pergunte
	
	//---Grupo de Cálculo de Frete
	
	oGroupCal := tGroup():New(5,10,80,240,STR0007,oPanelC,,CLR_GRAY,.T.) // "Cálculo de Frete"
	
	oSay := tSay():New(20,13,{||STR0008},oGroupCal,,TFont():New(, 8, 12),,,,.T.,CLR_BLUE,CLR_WHITE,60,8) //"Log Cálculo: "
	
	oGet := TGet():New(18,70,{|u| If(PCount()>0,cCalcFret:=u,cCalcFret)}, oGroupCal, 40,5,'@',,,,,,,.T.,,,{|| .F.},,,,,,,'cCalcFret')   
	
	oSay := tSay():New(40,13,{||STR0009},oGroupCal,,TFont():New(, 8, 12),,,,.T.,CLR_BLUE,CLR_WHITE,60,8) // "Ação: "
	
	oGet := TGet():New(38,70,{|u| If(PCount()>0,cAcao:=u,cAcao)}, oGroupCal, 40,5,'@',,,,,,,.T.,,,{|| .F.},,,,,,,'cAcao')
	
	oSay := tSay():New(60,13,{||STR0010},oGroupCal,,TFont():New(, 8, 12),,,,.T.,CLR_BLUE,CLR_WHITE,80,8) //"Agrupador: "
	                             
	oGet := TGet():New(58,70,{|u| If(PCount()>0,cAgrup:=u,cAgrup)}, oGroupCal, 50,5,'@',,,,,,,.T.,,,{|| .F.},,,,,,,'cAgrup')  
	
	oSay := tSay():New(20,125,{||STR0011},oGroupCal,,TFont():New(, 8, 12),,,,.T.,CLR_BLUE,CLR_WHITE,80,8) //"Nr Docto Carga: "
	                             
	oGet := TGet():New(18,182,{|u| If(PCount()>0,cNrDC:=u,cNrDC)}, oGroupCal, 50,5,'@',,,,,,,.T.,,,{|| .F.},,,,,,,'cNrDC')
	
	oSay := tSay():New(40,125,{||STR0012},oGroupCal,,TFont():New(, 8, 12),,,,.T.,CLR_BLUE,CLR_WHITE,60,8) //"Data de: "
	
	oGet := TGet():New(38,182,{|u| If(PCount()>0,cCDtDe:=u,cCDtDe)}, oGroupCal, 50,5,'@',,,,,,,.T.,,,{|| .F.},,,,,,,'cCDtDe') 
	
	oSay := tSay():New(60,125,{||STR0013},oGroupCal,,TFont():New(, 8, 12),,,,.T.,CLR_BLUE,CLR_WHITE,60,8) // "Data Até: "
	
	oGet := TGet():New(58,182,{|u| If(PCount()>0,cCDtAte:=u,cCDtAte)}, oGroupCal, 50,5,'@',,,,,,,.T.,,,{|| .F.},,,,,,,'cCDtAte') 
	
	//---Grupo de Rateio contábil
	
	oGroupRat := tGroup():New(5,250,80,480,STR0014,oPanelC,,CLR_GRAY,.T.) //"Rateio Contábil"
	
	oSay := tSay():New(18,253,{||STR0015},oGroupCal,,TFont():New(, 8, 12),,,,.T.,CLR_BLUE,CLR_WHITE,55,12) // "Log Rateio Contábil: "
	
	oGet := TGet():New(18,310,{|u| If(PCount()>0,cRatCont:=u,cRatCont)}, oGroupCal, 40,5,'@',,,,,,,.T.,,,{|| .F.},,,,,,,'cRatCont')   
	
	oSay := tSay():New(40,253,{||STR0016},oGroupCal,,TFont():New(, 8, 12),,,,.T.,CLR_BLUE,CLR_WHITE,60,8) // "Nr Cálculo: "
	
	oGet := TGet():New(38,310,{|u| If(PCount()>0,cNrCalc:=u,cNrCalc)}, oGroupCal, 50,5,'@',,,,,,,.T.,,,{|| .F.},,,,,,,'cNrCalc') 
	
	oSay := tSay():New(60,253,{||STR0017},oGroupCal,,TFont():New(, 8, 12),,,,.T.,CLR_BLUE,CLR_WHITE,80,8) // "Nr Docto Frete: "
	                             
	oGet := TGet():New(58,310,{|u| If(PCount()>0,cDocFret:=u,cDocFret)}, oGroupCal, 50,5,'@',,,,,,,.T.,,,{|| .F.},,,,,,,'cDocFret') 
	
	oSay := tSay():New(20,375,{||STR0012},oGroupCal,,TFont():New(, 8, 12),,,,.T.,CLR_BLUE,CLR_WHITE,60,8) // "Data de: "
	
	oGet := TGet():New(18,422,{|u| If(PCount()>0,cRDtDe:=u,cRDtDe)}, oGroupCal, 50,5,'@',,,,,,,.T.,,,{|| .F.},,,,,,,'cRDtDe') 
	
	oSay := tSay():New(40,375,{||STR0013},oGroupCal,,TFont():New(, 8, 12),,,,.T.,CLR_BLUE,CLR_WHITE,60,8) // "Data Até: "
	
	oGet := TGet():New(38,422,{|u| If(PCount()>0,cRDtAte:=u,cRDtAte)}, oGroupCal, 50,5,'@',,,,,,,.T.,,,{|| .F.},,,,,,,'cRDtAte')
	
	//------------Campos para informar a qual arquivo pertence o log apresentado
	                                                                                                                                  
	oSay := tSay():New(4,8,{||STR0018+cTpLog},oPanelG,,TFont():New('Courier New', 8, 14),,,,.T.,CLR_BLACK,CLR_WHITE,150,20) // "Tipo de Log: "
	
	oSay := tSay():New(4,150,{||STR0019+cDsArq},oPanelG,,TFont():New('Courier New', 8, 14),,,,.T.,CLR_BLACK,CLR_WHITE,200,20) // "Arquivo: "
	
	//------------Botões
	
	oBtn := TButton():New( 3, 360, STR0020, oPanelB,{|| If(oFolder:aDialogs[1]:lVisible == .T., GFEX1CALC(oFolder, @cLog, @cDsArq, @cTpLog), GFEX1RATC(oFolder, @cLog, @cDsArq, @cTpLog))},;
	40, 10,,,.F.,.T.,.F.,,.F.,{|| !oFolder:aDialogs[3]:lVisible == .T.},,.F. ) // "Visualizar"
	
	oBtn := TButton():New( 3, 405, STR0021, oPanelB,{|| GFEX1WPAR(oFolder),oGrdCal:GoTop(),oGrdRat:GoTop()},;
	40, 10,,,.F.,.T.,.F.,,.F.,,,.F. ) // "Parâmetros"
	
	oBtn := TButton():New( 3, 450, STR0022, oPanelB,{||oDlg:End()},;
	40, 10,,,.F.,.T.,.F.,,.F.,,,.F. ) // "Fechar"
	
	//---------------------------Grid dos logs do cálculo
	
	oGrdCal := TCBrowse():New( 01 , 01, 300, 200,,;
	      {STR0023,STR0024,STR0025,STR0026,STR0027},{50,50,50,50,50},;
	      oPanelE,,,,,{||},,,,,,,.F.,cAliCal,.T.,,.F.,,, ) // "Arquivo" ### "Tamanho" ### "Data" ### "Hora" ### "Ação"
	oGrdCal:Align := CONTROL_ALIGN_ALLCLIENT
	oGrdCal:bLDblClick := {|| GFEX1CALC(oFolder, @cLog, @cDsArq, @cTpLog)}  
	
	If MV_PAR01 == 2 .Or. !GFEX1PROC()
		lNull := .T.
		oFolder:SetOption(2,.T.)
		oFolder:aEnable(1,.F.)
	EndIf
	
	oGrdCal:bLine := {||{ (cAliCal)->ARQUIVO, (cAliCal)->TAMANHO, (cAliCal)->PERIODO, (cAliCal)->HORA, (cAliCal)->ACAO } }         
	oGrdCal:GoTop()
	
	//---------------------------Grid dos logs do rateio contábil
	
	oGrdRat := TCBrowse():New( 01 , 01, 300, 200,,;
	      {STR0023,STR0024,STR0025,STR0026},{50,50,50,50},;
	      oPanelF,,,,,{||},,,,,,,.F.,cAliRat,.T.,,.F.,,, ) // "Arquivo" ### "Tamanho" ### "Data" ### "Hora"
	oGrdRat:Align := CONTROL_ALIGN_ALLCLIENT
	oGrdRat:bLDblClick := {|| GFEX1RATC(oFolder, @cLog, @cDsArq, @cTpLog)}
	
	If MV_PAR07 == 2 .Or. !GFEX1PROR()
		If lNull	
			MsgInfo(STR0028,STR0002) // "Não há registros para serem exibidos." ### "Aviso"
			GFEDelTab(cAliCal)
			GFEDelTab(cAliRat)
			Return Nil
		Else 
			oFolder:aEnable(2,.F.)
		EndIf
	EndIf
	
	oGrdRat:bLine := {||{ (cAliRat)->ARQUIVO, (cAliRat)->TAMANHO, (cAliRat)->PERIODO, (cAliRat)->HORA } }    
	oGrdRat:GoTop()
	
	CursorArrow()
	
	//--------------------------Objeto Memo para leitura do Txt
	
	oMGet:= tMultiget():New(0,0,{|u| if(Pcount()>0,cLog:=u,cLog)}, oFolder:aDialogs[3] ,300,204,,,,,,.T.,,,,,,.T.)
	oMGet:EnableVScroll(.T.)
	oMGet:EnableHScroll(.T.)
	oMGet:Align := CONTROL_ALIGN_ALLCLIENT
	oMGet:oFont := TFont():New( 'Courier New', 6, 16 )
	oMGet:lWordWrap := .F.
	
	//Ativa a janela
	ACTIVATE MSDIALOG oDlg CENTERED
	
	//deleta tabelas temporárias
	GFEDelTab(cAliCal)
	GFEDelTab(cAliRat)

Return Nil

/*------------------------------------------------------
Função para chamar a tela de parâmetros
------------------------------------------------------*/

Static Function GFEX1PAR(oFolder)
	Local lNull := .F.

	If !Pergunte("GFEX001")
		Return "1"
	EndIf
	
	//-------------Altera os valores na tela
	
	cCalcFret := If(MV_PAR01 == 1, STR0029, STR0030) // "Sim" ###"Não"
	cAcao     := If(MV_PAR02 == 1, STR0031, If(MV_PAR02 == 2, STR0032, STR0033)) // "Ambos" ### "Gravar" ###"Simular"
	cAgrup    := AllTrim(MV_PAR03)
	cNrDC     := AllTrim(MV_PAR04)
	cCDtDe    := MV_PAR05
	cCDtAte   := MV_PAR06
	cRatCont  := If(MV_PAR07 == 1, STR0029, STR0030) // "Sim" ### "Não"
	cNrCalc   := AllTrim(MV_PAR08)
	cDocFret  := AllTrim(MV_PAR09)
	cRDtDe    := MV_PAR10
	cRDtAte   := MV_PAR11
	
	//--------------------------------------
	
	If oFolder != Nil
		If MV_PAR01 == 2 .And. MV_PAR07 == 2
			Return "2"
		EndIf
		
		If MV_PAR01 == 2 .Or. !GFEX1PROC()
			lNull := .T.
			oFolder:aEnable(1,.F.)
			oFolder:SetOption(2)
		Else
			oFolder:aEnable(1,.T.)
		EndIf
		
		If MV_PAR07 == 2 .Or. !GFEX1PROR()
			If lNull
				oFolder:aEnable(3,.F.)
				oFolder:aEnable(2,.F.)
				Return "2"
			Else
				oFolder:SetOption(1)
				oFolder:aEnable(2,.F.)
			EndIf  
		Else
			oFolder:aEnable(2,.T.)
		EndIf   
		
		oFolder:aEnable(3,.F.)
	EndIf 
	
Return "3"         

/*--------------------------------------------------------------------
Função para quando chamar a tela de parâmetros pelo botão 'parâmetros'
--------------------------------------------------------------------*/

Static Function GFEX1WPAR(oFolder)

	While GFEX1PAR(oFolder) == "2" //Se igual a "2" os parâmetros selecionados não retornam registros
		MsgInfo(STR0034, STR0002) // "Não há registros para os filtros informados. Escolha outros ou clique em 'cancelar'." ### "Aviso"
	EndDo

Return

/*------------------------------------------------------
Função para processamento dos logs de Cálculo do Frete
------------------------------------------------------*/

Static Function GFEX1PROC()
	Local cDir  := SuperGetMv("MV_DRTLOG",,"")
	Local aArqs := Directory(cDir+"\"+STR0035+"*.log") // "calculofrete" <- deve ser exatamente igual ao ch do cálculo do frete (GFEXFUNB)
	Local nCont := 1
	Local cBuff
	Local aInfo := {}
	
	If len(aArqs) == 0
		Return .F.
	EndIf
	
	dbSelectArea(cAliCal)
	ZAP
	
	While nCont <= len(aArqs)
		
		FT_FUSE(cDir+"\"+aArqs[nCont][1])  
	    FT_FGOTOP()
		cBuff := FT_FREADLN()
	    
		If Empty(cBuff) .Or. FT_FEOF()
			nCont++
			Loop
		EndIf
		   
		aInfo := StrToKarr(cBuff,";")
		
		FT_FUSE()
		
		If If(!Empty(MV_PAR05), MV_PAR05 <= aArqs[nCont][3], .T.) .And. If(!Empty(MV_PAR06), aArqs[nCont][3] <= MV_PAR06, .T.) .And. ;
		   If(MV_PAR02==1, .T., If(MV_PAR02==2, "1" $ aInfo[1], "2" $ aInfo[1])) .And. If(!Empty(MV_PAR03),aScan(aInfo,{|cAgr| AllTrim(cAgr) == AllTrim("A"+MV_PAR03) }) != 0,.T.) .And. ;
		   If(!Empty(MV_PAR04),aScan(aInfo,{|cDc| AllTrim(cDc) == AllTrim("D"+MV_PAR04) }) != 0,.T.)
			RecLock((cAliCal),.T.)
				(cAliCal)->ARQUIVO := aArqs[nCont][1]
				(cAliCal)->TAMANHO := AllTrim(Str(Round(aArqs[nCont][2]/1024,2))+" KB")
				(cAliCal)->PERIODO := aArqs[nCont][3]
				(cAliCal)->HORA    := aArqs[nCont][4]
				(cAliCal)->ACAO    := If("1" $ aInfo[1], STR0032, STR0033) // "Gravar" ### "Simular"
			MsUnlock(cAliCal)
		EndIf	
		nCont++
	EndDo
	
	If (cAliCal)->( Eof() )
		Return .F.
	EndIf

Return .T.   

/*------------------------------------------------------
Função para processamento do logs de Rateio Contábil
------------------------------------------------------*/

Static Function GFEX1PROR()
	Local cDir  := SuperGetMv("MV_DRTLOG",,"")
	Local aArqs := Directory(cDir+"\"+STR0036+"*.log") //"rateiocontabil"
	Local nCont := 1
	Local cBuff
	Local cCod
	
	If len(aArqs) == 0
		Return .F.
	EndIf
	
	dbSelectArea(cAliRat)
	ZAP
	
	While nCont <= len(aArqs)
	
		FT_FUSE(cDir+"\"+aArqs[nCont][1])  
	    FT_FGOTOP()
		cBuff := FT_FREADLN()
	    
		If Empty(cBuff) .Or. FT_FEOF()
			nCont++
			Loop
		EndIf
		
		While !FT_FEOF()
			If STR0037 $ cBuff //"Contabilização por Documento de Frete"
				FT_FSKIP()
				cBuff := FT_FREADLN()
				cCod := SubStr(cBuff,At(STR0039, cBuff)+9) // "Número :"
				cCod := "F"+AllTrim(SubStr(cCod, 1, At(",", cCod)-1))
				Exit
			EndIf
			
			If STR0038 $ cBuff // "Contabilização por Cálculo de Frete"
				FT_FSKIP()
				cBuff := FT_FREADLN()
				cCod := "C"+AllTrim(SubStr(cBuff,9))
				Exit
			EndIf
			
			FT_FSKIP()
			cBuff := FT_FREADLN()
		EndDo
		
		FT_FUSE()
	
		If If(!Empty(MV_PAR10), MV_PAR10 <= aArqs[nCont][3], .T.) .And. If(!Empty(MV_PAR11), aArqs[nCont][3] <= MV_PAR11, .T.) .And. ;
		   ( If(Empty(MV_PAR08) .And. Empty(MV_PAR09), .T., If(!Empty(MV_PAR08), AllTrim("C"+MV_PAR08) == AllTrim(cCod), .F.) .Or. If(!Empty(MV_PAR09), AllTrim("F"+MV_PAR09) == AllTrim(cCod), .F.)) )
			RecLock((cAliRat),.T.)
				(cAliRat)->ARQUIVO := aArqs[nCont][1]
				(cAliRat)->TAMANHO := AllTrim(Str(Round(aArqs[nCont][2]/1024,2))+" KB")
				(cAliRat)->PERIODO := aArqs[nCont][3]
				(cAliRat)->HORA    := aArqs[nCont][4]
			MsUnlock(cAliRat)
		EndIf	
		nCont++
	EndDo
	
	If (cAliRat)->( Eof() )
		Return .F.
	EndIf

Return .T.     

/*------------------------------------------------------
Função visualização do log de Cálculo do Frete
------------------------------------------------------*/

Static Function GFEX1CALC(oFolder, cLog, cDsArq, cTpLog)
	Local cDir := SuperGetMv("MV_DRTLOG",,"")
	
	cLog := GFEX1MEMO(cDir + "\" + (cAliCal)->ARQUIVO) //MemoRead(cDir+"\"+(cAliCal)->ARQUIVO)
	cDsArq := (cAliCal)->ARQUIVO
	cTpLog := STR0007 //"Cálculo de Frete"
	
	oFolder:aEnable(3,.T.)
	oFolder:SetOption(3,.T.)

Return

/*------------------------------------------------------
Função visualização do log de Rateio Contábil
------------------------------------------------------*/

Static Function GFEX1RATC(oFolder, cLog, cDsArq, cTpLog)
	Local cDir := SuperGetMv("MV_DRTLOG",,"")
	
	cLog   := GFEX1MEMO(cDir + "\" + (cAliRat)->ARQUIVO) //MemoRead(cDir+"\"+(cAliRat)->ARQUIVO)
	cDsArq := (cAliRat)->ARQUIVO
	cTpLog := STR0014 //"Rateio Contábil"
	
	oFolder:aEnable(3,.T.)
	oFolder:SetOption(3,.T.)

Return

/*------------------------------------------------------
Traz o texto de um arquivo txt atráves do path
------------------------------------------------------*/

Function GFEX1MEMO(cPath)
	
	Local cTxt := ""
	
	If File(cPath)
	
		FT_FUSE(cPath)
		
		FT_FGOTOP()
		
		While !FT_FEOF()
			
			If Len(cTxt) + Len(FT_FREADLN() + CRLF) <= 1000000			
				cTxt += FT_FREADLN() + CRLF
			Else
				cTxt += CRLF + "     ***VERIFICAR O LOG COMPLETO NO DIRETÓRIO ONDE SÃO SALVOS." + CRLF
				Exit
			EndIf
			
			FT_FSKIP()
			
		EndDo
		
		FT_FUSE()
		
	EndIf
	
Return cTxt
