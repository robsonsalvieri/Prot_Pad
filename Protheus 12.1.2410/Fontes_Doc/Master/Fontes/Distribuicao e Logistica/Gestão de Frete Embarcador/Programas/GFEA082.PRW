#INCLUDE "GFEA082.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

/*/--------------------------------------------------------------------------------------------------
{Protheus.doc} GFEA082
Agrupamento dos Calculos dos Romaneios.
Generico.
                                                           
@sample
GFEA082()

@author Luiz Fernando Soares
@since 18/03/2010
@version 1.0
--------------------------------------------------------------------------------------------------/*/
Function GFEA082()

Local oDlg
Local nAlt := (GetScreenRes()[2]-10)
Local nLrg := (GetScreenRes()[1]-10)
Private	cCdTran,cClaFre,cTpOper,cTpDocC,dDtCrIn,dDtCrFi,cTpImp
Private cCadastro := "Agrupamento de Cálculos de Frete" //"Romaneios"
Private cMarca := GetMark()

If Pergunte("GFEA082",.T.)
	cCdTran	:= MV_PAR01
	cClaFre	:= MV_PAR02
	cTpOper	:= MV_PAR03
	cTpDocC	:= MV_PAR04
	dDtCrIn	:= MV_PAR05
	dDtCrFi	:= MV_PAR06
	cTpImp 	:= MV_PAR07

	
	aNewButton := {}		
		
	//----------------------------------------------
	// Criacao da tabela temporaria p/ Markbrowse  
	//----------------------------------------------	

	aCpMKB  := {	{"OK"        ,NIL ,""      ,""                           },;
					{"ROMANEIO"  ,NIL ,STR0002 ,"@!"                         },; //"Romaneio"
					{"VLFRETE"   ,NIL ,STR0003 ,"@E 999,999,999.99"          },; //"Valor do Frete"
					{"QTCALC"    ,NIL ,STR0025 ,"@E 999,999,999"             },; // "Qt.Calc"
					{"DTCRIACAO" ,NIL ,STR0006 ,"@D"                           },; //"Data de Criação"
					{"HRCRIACAO" ,NIL ,STR0007 ,"@R"                         },; //"Hora"
					{"DTSAIDA"   ,NIL ,STR0008 ,"@D"                           },; //"Data de Saída"
					{"HRSAIDA"   ,NIL ,STR0009 ,"@R"                         },; //"Hora Saída"
					{"PLACADIAN" ,NIL ,STR0010 ,PesqPict("GWN","GWN_PLACAD") },; //"Placa Dianteira"
					{"PLACAMEIO" ,NIL ,STR0011 ,PesqPict("GWN","GWN_PLACAM") },; //"Placa Meio"
					{"PLACATRAS" ,NIL ,STR0012 ,PesqPict("GWN","GWN_PLACAT") },; //"Placa Traseira"
					{"MOTORISTA" ,NIL ,STR0013 ,""                           } } //"Motorista"

	cAliMKB  := GFECriaTab(GetMKBStr())
	cAliMKB2 := GFECriaTab(GetMKB2Str())

	//----------------------------------------------------------------
	//Tabela temporaria para os documentos de carga do calculo de frete 
	//----------------------------------------------------------------
	cTabDC := GFECriaTab(GetTabDCStr())
	
	//----------------------------------------------------------------
	//Tabela temporaria para as Tabelas do calculo de frete 
	//----------------------------------------------------------------
	cTabFrete := GFECriaTab(GetTabFreStr())
	

	//--------------------------
	// Montagem da tela        
	//--------------------------
	CursorWait()
	
	Define MsDialog oDlg Title cCadastro From 500,120 To nAlt,nLrg Of oMainWnd Color CLR_BLACK,RGB(225,225,225) Pixel
	oDlg:lEscClose := .F.
	//----- Painel superior da tela principal, com as informacoes do romaneio -----//
	oPnlB := tPanel():New(00,00,,oDlg,,,,,,30,40,.F.,.F.)
	oPnlB:Align := CONTROL_ALIGN_ALLCLIENT  
	//----- Painel lateral do browse de documentos relacionados, para adicionar botoes -----//
	oPnlBtn1:=TPanel():New(00,00,,oPnlB,,,,,RGB(67,70,87),15,15,.F.,.F.)
	oPnlBtn1:Align := CONTROL_ALIGN_LEFT	

	//------Botão para selecionar Todos os componentes visiveis no Grid----------//
	oBtnChk := TBtnBmp():NewBar("CHECKED","CHECKED",,,,{||GFEA82CLK(1)},,oPnlBtn1,,,"",,,,,"")
	oBtnChk:cToolTip := "Marca todos os cálculos em tela"
	oBtnChk:Align    := CONTROL_ALIGN_TOP
	
	//------Botão para selecionar Todos os componentes visiveis no Grid----------//
	oBtnChk := TBtnBmp():NewBar("UNCHECKED","UNCHECKED",,,,{||GFEA82CLK(2)},,oPnlBtn1,,,"",,,,,"")
	oBtnChk:cToolTip := "Desmarca todos os cálculos em tela"
	oBtnChk:Align    := CONTROL_ALIGN_TOP
								
	dbSelectArea(cAliMKB)
	dbSetOrder(01)
	dbGoTop()
	oMark := MsSelect():New(cAliMKB,STR0015,,aCpMKB,,@cMarca,{0,0,0,0},,,oPnlB) //"OK"
	oMark:oBrowse:bLDblClick := { || GFEA82CHK() }
	oMark:oBrowse:cToolTip := STR0016 //"Visualização"
	oMark:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	
	Processa({|lEnd| GFEA82CRG()},STR0017,STR0018) //"Carregando informações"###"Aguarde"
	
	CursorArrow()

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(ODlg,{||If(GFEA82POK(),ODlg:End(),NIL)},;
		{||ODlg:End()},,aNewButton) CENTERED 

	// Elimina as tabelas temporárias				
	GFEDelTab(cAliMKB)
	GFEDelTab(cAliMKB2)
	GFEDelTab(cTabDC)
	GFEDelTab(cTabFrete)

EndIf

Return(Nil) 


Static Function GetMKBStr()  
				
Local aMKB :=  {{"OK"       ,"C",02,0},;
				{"ROMANEIO" ,"C",10,0},;
				{"VLFRETE"  ,"N",12,2},;
				{"QTCALC"   ,"N",09,0},;
				{"DTCRIACAO","D",08,0},;
				{"HRCRIACAO","C",05,0},;
				{"DTSAIDA"  ,"D",08,0},;
				{"HRSAIDA"  ,"C",05,0},;
				{"PLACADIAN","C",08,0},;
				{"PLACAMEIO","C",08,0},;
				{"PLACATRAS","C",08,0},;
				{"MOTORISTA","C",50,0}}
	
Local aIndex := {"ROMANEIO", "OK"}

Return {aMKB,aIndex}


Static Function GetMKB2Str()

Local aMKB2 := {{"CDCOMP" ,"C", TamSX3("GWI_CDCOMP")[1],0},;
				{"TRANSP" ,"C", TamSX3("GWF_TRANSP")[1],0},; 
				{"EMIREM" ,"C", TamSX3("GWF_EMIREM")[1],0},;
				{"EMIDES" ,"C", TamSX3("GWF_EMIDES")[1],0},;
				{"CDCLFR" ,"C", TamSX3("GWI_CDCLFR")[1],0},;
				{"CDTPOP" ,"C", TamSX3("GWI_CDTPOP")[1],0},;	
				{"BASICM" ,"N", 12,2},;
				{"BAPICO" ,"N", 12,2},;
				{"VLICMS" ,"N", 12,2},;
				{"VLISS"  ,"N", 12,2},;
				{"VLPIS"  ,"N", 12,2},;
				{"VLCOFI" ,"N", 12,2},;				
				{"VLFRETE","N", 12,2},;
				{"QTCALC" ,"N", 15,5}}
					
Local aIndex := {"TRANSP+CDCLFR+CDTPOP+CDCOMP"}

Return {aMKB2,aIndex}

//---------------------------------------------------------------------
Static Function GetTabDCStr()

Local aTabDC := {{"NRCALC" ,"C", 8,0},;
				 {"CDTPDC" ,"C", 5,0},; 
				 {"EMISDC" ,"C", TamSX3("GWH_EMISDC")[1],0},;
			 	 {"SERDC",	"C", TamSX3("GWH_SERDC")[1],0},;
				 {"NRDC"   ,"C",16,0}}
					
Local aIndex := {"NRDC+SERDC+EMISDC+CDTPDC"}

Return {aTabDC,aIndex}

//---------------------------------------------------------------------
Static Function GetTabFreStr()

Local aTabFrete := {{"NRCALC" ,"C",8, 0},;
				    {"CDTPOP" ,"C",10,0},; 
	                {"CDCLFR" ,"C",4, 0},;
				    {"CDEMIT" ,"C",TamSX3("GWG_CDEMIT")[1], 0},;  
				    {"NRTAB"  ,"C",6, 0},;
				    {"NRNEG"  ,"C",6, 0},;
	                {"QTM3"   ,"N",12,5},; 
				    {"QTPESO" ,"N",15,5},;
				    {"PESCUB" ,"N",15,5},;
				    {"QTITEM" ,"N",15,5},;
				    {"VLMERC" ,"N",12,2}}
	
Local aIndex := {"CDEMIT+CDCLFR+CDTPOP","NRCALC+CDTPOP+CDCLFR"}

Return {aTabFrete,aIndex}


//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA44CRG
                 
Acrescenta os registros na tabela temporaria para que eles sejam
exibidos na tela do romaneio

@author Luiz Fernando Soares
@since 10/11/09
@version 1.0
/*/
//-------------------------------------------------------------------            		                        

Function GFEA82CRG()

	Local lTemDocFrete := .F.
	Local lTemPreFat   := .F.
	Local lTemCalcDif  := .F.
	Local cSentido     := ""
	Local nVlFreteRom  := 0
	Local nQtdeCalc    := 0
	Local nCountRom    := 0
	Local cAliasGW1    := Nil
	Local cAliasGWF    := Nil
	Local cWhere       := Nil

	DbSelectArea(cAliMKB)
	DbSetOrder(1)
	DbGotop()
	nCountRom := (cAliMKB)->(RecCount())

	procRegua(nCountRom)

	dbSelectArea(cAliMKB)
	ZAP	

	cAliasGWN := GetNextAlias()
	cQuery := " SELECT GWN.*"
	cQuery += " FROM " + RetSQLName("GWN") + " GWN"
	cQuery += " WHERE GWN.GWN_FILIAL = '" + xFilial("GWN")  + "'"
	cQuery += " AND GWN.GWN_CDTRP = '" + cCdTran + "' AND "
	If !Empty(cClaFre)
		cQuery += " GWN.GWN_CDCLFR = '" + cClaFre +  "'AND " 
	EndIf
	cQuery += " GWN.GWN_SIT = '" + '3' + "' AND "
	If !Empty(cTpOper)
		cQuery += " GWN.GWN_CDTPOP = '" + cTpOper + "'AND " 
	EndIf
	cQuery += " GWN.GWN_CALC = '" + '1' + "' AND "					
	cQuery += " GWN.GWN_DTIMPL >= '" + DTOS(dDtCrIn) + "' AND GWN.GWN_DTIMPL <= '" + DTOS(dDtCrFi) + "'AND " 
	cQuery += " GWN.D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasGWN, .F., .T.)

	dbSelectArea((cAliasGWN))
	(cAliasGWN)->( dbGoTop() )

	While !(cAliasGWN)->( Eof() )
		incProc("Carregando Romaneios")
	             
		If GFXCP1212210('GW1_FILROM')
			cWhere := "GW1.GW1_FILROM = '" + (cAliasGWN)->GWN_FILIAL + "'"
		Else
			cWhere := "GW1.GW1_FILIAL = '" + (cAliasGWN)->GWN_FILIAL + "'"
		EndIf
		cWhere := "%" + cWhere + "%"

		cAliasGW1 := GetNextAlias()
		BeginSql Alias cAliasGW1
			SELECT GW1_FILIAL, GW1_CDTPDC, GW1_EMISDC, GW1_SERDC, GW1_NRDC, GW1.R_E_C_N_O_ AS GW1RECNO
			FROM %table:GW1% GW1
			WHERE %Exp:cWhere%
			AND GW1.GW1_NRROM = %Exp:(cAliasGWN)->GWN_NRROM%
			AND GW1.%NotDel%
			ORDER BY GW1.GW1_FILIAL,GW1.GW1_NRDC
		EndSql
		If !(cAliasGW1)->(Eof()) .And. (Empty(cTpDocC) .OR. (cAliasGW1)->GW1_CDTPDC == cTpDocC)	// Tipo do 1o documento de carga deve ser igual ao parâmetro, se informado
				
			lTemDocFrete := .F.		
			While !(cAliasGW1)->(Eof())
				// Verifica se algum documento de carga do romaneio está vinculado à documento de frete
				dbSelectArea("GW4")
				dbSetOrder(2)
				If dbSeek(xFilial("GW4") + (cAliasGW1)->GW1_EMISDC + (cAliasGW1)->GW1_SERDC + (cAliasGW1)->GW1_NRDC + (cAliasGW1)->GW1_CDTPDC)
					lTemDocFrete := .T.
					Exit
				EndIf

				(cAliasGW1)->(dbSkip())
			EndDo

			If lTemDocFrete
				(cAliasGWN)->( dbSkip() )	
				Loop
			EndIf
		Else
			(cAliasGWN)->( dbSkip() )	
			Loop
		EndIf
		(cAliasGW1)->(dbCloseArea())
            
		lTemPreFat  := .F.
		lTemCalcDif := .F.
		nVlFreteRom := 0
		nQtdeCalc   := 0
			
			
		If GFXCP1212210('GWF_FILROM')
			cWhere := "GWF.GWF_FILROM = '" + (cAliasGWN)->GWN_FILIAL + "'"
		Else
			cWhere := "GWF.GWF_FILIAL = '" + (cAliasGWN)->GWN_FILIAL + "'"
		EndIf
		cWhere := "%" + cWhere + "%"

		cAliasGWF := GetNextAlias()
		BeginSql Alias cAliasGWF
			SELECT GWF.R_E_C_N_O_ AS GWFRECNO
			FROM %table:GWF% GWF
			WHERE %Exp:cWhere%
			AND GWF.GWF_NRROM  = %Exp:(cAliasGWN)->GWN_NRROM%
			AND GWF.%NotDel%
			ORDER BY GWF.GWF_FILIAL,GWF.GWF_NRCALC
		EndSql
		While !(cAliasGWF)->(Eof())
			GWF->(dbGoto( (cAliasGWF)->GWFRECNO ))

			// Verifica se algum cálculo do romaneio está vinculado à pré-fatura
			If !Empty(GWF->GWF_NRPREF)
				lTemPreFat := .T.
				Exit
			EndIf
			If CVALTOCHAR(cTpImp) <> GWF->GWF_IMPOST
				(cAliasGWF)->(dbSkip())
				Loop
			EndIf
			// Verifica se o tipo do calculo é normal
			If Empty(cTpDocC) .AND. GWF->GWF_TPCALC != "1"
				(cAliasGWF)->(dbSkip())
				Loop
			Else
				cSentido := Posicione("GV5",1,xFilial("GV5")+cTpDocC,"GV5_SENTID")
				If !GWF->GWF_TPCALC $ "15" /* Normal ou Devolução */ .OR. (cSentido == "2" /*Saida*/   .AND. GWF->GWF_TPCALC != "1" /*Normal*/)
					(cAliasGWF)->(dbSkip())
					Loop
				EndIf
			EndIf

			// Verifica se os demais cálculos do romaneio são do mesmo tipo do cálculo atual
			If verCalcDif((cAliasGWN)->GWN_FILIAL,(cAliasGWN)->GWN_NRROM,GWF->GWF_TPCALC)
				(cAliasGWF)->(dbSkip())
				Loop
			EndIf

			nVlFreteRom += VlTotFret(GWF->GWF_NRCALC)
			nQtdeCalc++

			(cAliasGWF)->(dbSkip())
		EndDo
		(cAliasGWF)->(dbCloseArea())

		If lTemPreFat .OR. (nVlFreteRom == 0)
			(cAliasGWN)->( dbSkip() )	
			Loop
		EndIf

		dbSelectArea(cAliMKB)
		RecLock((cAliMKB),.T.)
		(cAliMKB)->ROMANEIO  := (cAliasGWN)->GWN_NRROM
		(cAliMKB)->DTCRIACAO := STOD((cAliasGWN)->GWN_DTIMPL)
		(cAliMKB)->HRCRIACAO := (cAliasGWN)->GWN_HRIMPL
		(cAliMKB)->DTSAIDA   := STOD((cAliasGWN)->GWN_DTSAI)
		(cAliMKB)->HRSAIDA   := (cAliasGWN)->GWN_HRSAI
		(cAliMKB)->PLACADIAN := (cAliasGWN)->GWN_PLACAD
		(cAliMKB)->PLACAMEIO := (cAliasGWN)->GWN_PLACAM
		(cAliMKB)->PLACATRAS := (cAliasGWN)->GWN_PLACAT
		(cAliMKB)->MOTORISTA := POSICIONE("GUU",1,XFILIAL("GUU")+(cAliasGWN)->GWN_CDMTR,"GUU_NMMTR")
		(cAliMKB)->VLFRETE   := nVlFreteRom            
		(cAliMKB)->QTCALC    := nQtdeCalc
		(cAliMKB)->OK        := ""
		MsUnLock(cAliMKB)

		dbSelectArea((cAliasGWN))
		(cAliasGWN)->( dbSkip() )	
	EndDo	                                                             		
	
	dbSelectArea(cAliMKB)
	dbGoTOp()		
	oMark:oBrowse:Refresh()

Return .T.
    
//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA44CHK

Verifica se já existe um registro marcado

@author Luiz Fernando Soares
@since 10/03/2010
@version 1.0
/*/
//------------------------------------------------------------------- 

Static Function GFEA82CHK()

Local lMArk := .T.
Local nREc  := (cAliMKB)->(RecNo())

	dbSelectArea(cAliMKB)
	dbSetOrder(01)   

	dbGoTo(nRec)      
	If lMArk 
		RecLock(cAliMKB,.F.) 
		(cAliMKB)->OK := If(IsMark('OK',cMarca),"  ",cMarca)
		MsUnLock(cAliMKB)
				
	EndIf 
	
	oMark:oBrowse:Refresh()
Return	

Function GFEA82POK()

	Local lRet

	Processa({|| If (GFEA82OK(),lRet := .T., lRet := .F.)},,)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA82OK

Salva o numero do romaneio selecionado no documento de carga corente

@author Luiz Fernando Soares
@since 10/11/09
@version 1.0
/*/
//------------------------------------------------------------------- 

Function GFEA82OK()
	Local nNovoNrCalc := 0
	Local lRet := .T.
	Local lExistGWA := .F.
	Local nPIS, nICMS, nCOFINS, nBapico, nBaseIcms, nISS, cCodTransp, nPCICMS, nNumEmbMark, cRecnoGWA
	Local nPcISS := 0, nBaseISS := 0
	Local cTpFrete := "", cTpCalc := "", cTpTrib := "", cTpImposto := "" 
	Local cFinalidade := ""
	Local cRomaneio  := ""
	Local cCalculo   := ""
	Local cEmiPag    := ""
	Local aAreaGWA
	Local cChaveGWA
	Local nVlMov:= 0
	Local lAcumula := .F.
	Local aCalc := {}
	Local nPos
	//Contadores.
	Local nCountMKB := 0
	Local nCountMKB2 := 0
	Local nCountDC := 0
	Local nCountTbF := 0
	Local aMovAt := {}
	Local nI := 0
	Local cAliasGWF := Nil
	Local cWhere    := Nil
	Local nSeq      := Nil
	//Conta os registros das tabelas temporárias.
	DbSelectArea(cAliMKB)
	DbSetOrder(1)
	DbGotop()
	nCountMKB := (cAliMKB)->(RecCount())

	DbSelectArea(cAliMKB2)
	DbSetOrder(1)
	DbGotop()
	nCountMKB2 := (cAliMKB2)->(RecCount())

	DbSelectArea(cTabDC)
	DbSetOrder(1)
	DbGotop()
	nCountDC := (cTabDC)->(RecCount())

	DbSelectArea(cTabFrete)
	DbSetOrder(1)
	DbGotop()
	nCountTbF := (cTabFrete)->(RecCount())

	nPIS		:= 0
	nICMS		:= 0
	nCOFINS		:= 0
	nBapico		:= 0
	nBaseIcms	:= 0 
	nISS		:= 0
	nPCICMS		:= 0
	nNumEmbMark	:= 0
	cCodTransp	:= " "

	ProcRegua(nCountMKB)

   	dbSelectArea(cAliMKB)
	(cAliMKB)->( dbSetOrder(2) )
	If(cAliMKB)->( dbSeek(cMarca) ) 
		nNovoNrCalc := GETSXENUM("GWF","GWF_NRCALC")
		While !(cAliMKB)->(Eof()) .and. (cAliMKB)->OK == cMarca

			IncProc("Lendo romaneio: " + (cAliMKB)->ROMANEIO )

			dbSelectArea("GWN")
			dbSetOrder(1)
			If dbseek(xFilial("GWN")+(cAliMKB)->ROMANEIO)

				If GFXCP1212210('GWF_FILROM')
					cWhere := "GWF.GWF_FILROM = '" + GWN->GWN_FILIAL + "'"
				Else
					cWhere := "GWF.GWF_FILIAL = '" + GWN->GWN_FILIAL + "'"
				EndIf
				cWhere := "%" + cWhere + "%"

				cAliasGWF := GetNextAlias()
				BeginSql Alias cAliasGWF
					SELECT GWF.R_E_C_N_O_ AS GWFRECNO
					FROM %table:GWF% GWF
					WHERE %Exp:cWhere%
					AND GWF.GWF_NRROM  = %Exp:GWN->GWN_NRROM%
					AND GWF.%NotDel%
					ORDER BY GWF.GWF_FILIAL,GWF.GWF_NRCALC
				EndSql
				While !(cAliasGWF)->(Eof())
					GWF->(dbGoto( (cAliasGWF)->GWFRECNO) )

					If CVALTOCHAR(cTpImp) <> GWF->GWF_IMPOST
						(cAliasGWF)->(dbSkip())
						Loop
					EndIf

					dbSelectArea("GWA")
		         	dbSetOrder(3)
				  	If dbSeek(xFilial("GWA")+"1"+GWF->GWF_NRCALC)
				    	cRecnoGWA := GWA->(Recno())
		            	If GWA->GWA_SITCTB == "4" // Atualizado ERP
		            		lExistGWA := .T.
		            		RecLock(("GWF"),.F.)
								GWF->GWF_TPCALC := "8"	// 8-Provisao
							MsUnLock("GWF")
						Else
							lExistGWA := .F.
		            	EndIf
		     		Else
						lExistGWA := .F.
		          	EndIf

					If Empty(cCodTransp)
						cCodTransp  := GWF->GWF_TRANSP
						cEmiRem     := GWF->GWF_EMIREM
						cEmiDes     := GWF->GWF_EMIDES
						cFinalidade := GWF->GWF_FINCAL
						cTpImposto  := GWF->GWF_IMPOST
						cTpFrete    := GWF->GWF_TPFRET
						cTpTrib     := GWF->GWF_TPTRIB
						cTpCalc     := GWF->GWF_TPCALC
						nPCICMS     := GWF->GWF_PCICMS
						nPcISS      := GWF->GWF_PCISS
					EndIf

					dbSelectArea("GWH")
					dbSetOrder(1)
					dbSeek(xFilial("GWH")+GWF->GWF_NRCALC)
					While !GWH->( Eof() ) .and. GWH->GWH_NRCALC == GWF->GWF_NRCALC
						dbSelectArea(cTabDC)
						dbSetOrder(01)
						If !dbSeek(GWH->GWH_NRDC+GWH->GWH_SERDC+GWH->GWH_EMISDC+GWH->GWH_CDTPDC)
							dbSelectArea(cTabDC)
							dbSetOrder(01)
							RecLock(cTabDC,.T.)
								(cTabDC)->NRDC    := GWH->GWH_NRDC
								(cTabDC)->SERDC   := GWH->GWH_SERDC
								(cTabDC)->EMISDC  := GWH->GWH_EMISDC
								(cTabDC)->CDTPDC  := GWH->GWH_CDTPDC
							MsUnLock(cTabDC)
						EndIf

						//Rateio Contábeis do Documento de Frete
		  				dbSelectArea("GWM")
		    			dbSetOrder(2)
		    			If dbSeek(GWH->GWH_FILIAL+GWH->GWH_CDTPDC+GWH->GWH_EMISDC+GWH->GWH_SERDC+GWH->GWH_NRDC)
			    			While !GWM->(Eof()) .And. GWH->GWH_FILIAL+GWH->GWH_CDTPDC+GWH->GWH_EMISDC+GWH->GWH_SERDC+GWH->GWH_NRDC == GWM->(GWM_FILIAL+GWM_CDTPDC+GWM_EMISDC+GWM_SERDC+GWM_NRDC)
			    			 	If GWM->GWM_TPDOC == "1" .And. AllTrim(GWM->GWM_NRDOC) == AllTrim(GWH->GWH_NRCALC)
				    				//GWM - RATEIO CONTABIL DE FRETE
				    				cTpDocMo	:= GWM->GWM_TPDOC
									RecLock("GWM",.F.)
										GWM->GWM_NRDOC := nNovoNrCalc
									MsUnlock("GWM")
								EndIf
								GWM->(dbSkip())
							EndDo
						Endif

						If !lExistGWA
							RecLock(("GWH"),.F.)
							dbDelete()
							MsUnLock("GWH")
						EndIf

						GWH->( dbSkip() )
					EndDo

					nPIS		+= GWF->GWF_VLPIS
					nCOFINS		+= GWF->GWF_VLCOFI
					nBapico		+= GWF->GWF_BAPICO
					nICMS		+= GWF->GWF_VLICMS
					nISS 		+= GWF->GWF_VLISS
					nBaseIcms	+= GWF->GWF_BASICM
					nBaseISS	+= GWF->GWF_BASISS

					//Adiciona os numeros dos cálculos que serão agrupados no array para
					//utilizar no momento em que os movimentos contábeis serão agrupados.
					Aadd(aCalc, GWF->GWF_NRCALC)

					dbSelectArea("GWG")
					dbSetOrder(1)
					dbSeek(xFilial("GWG")+GWF->GWF_NRCALC)
					While !GWG->(Eof()) .and. GWG->GWG_NRCALC == GWF->GWF_NRCALC
						dbSelectArea(cTabFrete)
						dbSetOrder(01) //NRCALC+CDTPOP+CDCLFR
						If dbSeek(GWG->GWG_CDEMIT + GWG->GWG_CDCLFR + GWG->GWG_CDTPOP)
							RecLock(cTabFrete,.F.)
								(cTabFrete)->QTPESO  += GWG->GWG_QTPESO
								(cTabFrete)->QTITEM  += GWG->GWG_QTITEM
								(cTabFrete)->VLMERC  += GWG->GWG_VLMERC
								(cTabFrete)->PESCUB  += GWG->GWG_PESCUB
								(cTabFrete)->QTM3    += GWG->GWG_QTM3
							MsUnLock(cTabFrete)
						Else
							dbSelectArea(cTabFrete)
							dbSetOrder(01)
							RecLock(cTabFrete,.T.)
								(cTabFrete)->CDEMIT  := GWG->GWG_CDEMIT
								(cTabFrete)->NRTAB   := ""
								(cTabFrete)->NRNEG   := ""
								(cTabFrete)->CDTPOP  := GWG->GWG_CDTPOP
								(cTabFrete)->CDCLFR  := GWG->GWG_CDCLFR
								(cTabFrete)->QTPESO  := GWG->GWG_QTPESO
								(cTabFrete)->QTITEM  := GWG->GWG_QTITEM
								(cTabFrete)->VLMERC  := GWG->GWG_VLMERC
								(cTabFrete)->PESCUB  := GWG->GWG_PESCUB
								(cTabFrete)->QTM3    := GWG->GWG_QTM3
							MsUnLock(cTabFrete)
						EndIf
						If !lExistGWA
							//GWG - Tabela de Cálculo de Frete
							RecLock(("GWG"),.F.)
								dbDelete()
							MsUnLock("GWG")
						EndIf

						GWG->( dbSkip() )
					EndDo

					dbSelectArea("GWI")
					dbSetOrder(1)
					dbSeek(xFilial("GWI")+GWF->GWF_NRCALC)
					While !GWI->(Eof()) .and. GWI->GWI_FILIAL == xFilial("GWI") .And. GWI->GWI_NRCALC == GWF->GWF_NRCALC
						If GWI->GWI_TOTFRE == "1"
							dbSelectArea(cAliMKB2)
							dbSetOrder(01)//TRANSP+CDCLFR+CDTPOP+CDCOMP
							If dbSeek(GWF->GWF_TRANSP + GWI->GWI_CDCLFR + GWI->GWI_CDTPOP + GWI->GWI_CDCOMP)
								RecLock(cAliMKB2,.F.)
									(cAliMKB2)->VLFRETE += GWI->GWI_VLFRETE
									(cAliMKB2)->QTCALC  += GWI->GWI_QTCALC
								MsUnLock(cAliMKB2)
							Else
								dbSelectArea(cAliMKB2)
								dbSetOrder(01)
								RecLock(cAliMKB2,.T.)
									(cAliMKB2)->TRANSP  := cCodTransp
									(cAliMKB2)->EMIREM  := cEmiRem
									(cAliMKB2)->EMIDES  := cEmiDes
									(cAliMKB2)->CDCOMP  := GWI->GWI_CDCOMP
									(cAliMKB2)->CDCLFR  := GWI->GWI_CDCLFR
									(cAliMKB2)->CDTPOP  := GWI->GWI_CDTPOP
									(cAliMKB2)->VLFRETE := GWI->GWI_VLFRETE
									(cAliMKB2)->QTCALC  := GWI->GWI_QTCALC
								MsUnLock(cAliMKB2)
							EndIf
						EndIf
						If !lExistGWA
							//GWI - COMPONENTE DO CALCULO DE FRETE
							RecLock("GWI",.F.)
					  			dbDelete()
							MsUnLock("GWI")
						EndIf
						GWI->( dbSkip() )
					EndDo

					IIf(Empty(cCalculo), cCalculo += Alltrim(GWF->GWF_NRCALC) , cCalculo += ", " + Alltrim(GWF->GWF_NRCALC))

					If Empty(cEmiPag)
						cEmiPag := GWF->GWF_EMIPAG
					Endif

					(cAliasGWF)->(dbSkip())
				EndDo
				(cAliasGWF)->(dbCloseArea())

			EndIf
				   
			dbSelectArea("GWN")
			dbSetOrder(1)
			If dbseek(xFilial("GWN")+(cAliMKB)->ROMANEIO)
				RecLock(("GWN"),.F.)
					GWN->GWN_AGRUP := "1"
					GWN->GWN_DTCALC := DDATABASE
					GWN->GWN_HRCALC := SubStr(TIME(), 1, 5)
				MsUnLock("GWN")
			EndIf
			
			If Empty(cRomaneio)
				cRomaneio += Alltrim((cAliMKB)->ROMANEIO) 
			Else 
				cRomaneio += + ", " + Alltrim((cAliMKB)->ROMANEIO) 
			EndIf							
			dbSelectArea(cAliMKB)
			dbSkip()					
		EndDo
		
		ProcRegua(nCountMKB2+1)
		IncProc("Gravando novo cálculo...")
		dbSelectArea("GWF")
		dbSetOrder(1)
		If !dbSeek(xFilial("GWF")+nNovoNrCalc) //olhar			
	    	RecLock("GWF",.T.)								
				GWF->GWF_FILIAL  	:= xFilial("GWF")
				GWF->GWF_NRCALC  	:= nNovoNrCalc
				GWF->GWF_DTCRIA  	:= DDATABASE           
				GWF->GWF_HRCRIA  	:= TIME()
				GWF->GWF_USUCRI  	:= cUserName     			
				GWF->GWF_TRANSP  	:= (cAliMKB2)->TRANSP  
				GWF->GWF_EMIREM  	:= (cAliMKB2)->EMIREM
				GWF->GWF_EMIDES  	:= (cAliMKB2)->EMIDES	
				GWF->GWF_EMIPAG  	:= cEmiPag
				GWF->GWF_BAPICO  	:= nBapico
			   	GWF->GWF_VLPIS		:= nPIS
				GWF->GWF_VLCOFI  	:= nCOFINS
				GWF->GWF_IMPOST  	:= cTpImposto
				GWF->GWF_BASICM  	:= nBaseIcms
				GWF->GWF_PCICMS  	:= nPCICMS
				GWF->GWF_VLICMS  	:= nICMS
				GWF->GWF_BASISS  	:= nBaseISS
				GWF->GWF_PCISS   	:= nPcIss
				GWF->GWF_VLISS   	:= nISS
				GWF->GWF_FINCAL  	:= cFinalidade
				GWF->GWF_AGRUP   	:= "1" // 1-Sim
				GWF->GWF_ORIGEM  	:= "2" // 2-Informado
				GWF->GWF_TPFRET  	:= cTpFrete
				GWF->GWF_TPCALC  	:= cTpCalc
				GWF->GWF_TPTRIB  	:= cTpTrib
				GWF->GWF_IDFRVI  	:= "2" // 2-Não     
				GWF->GWF_OBS     	:= STR0023 + cCalculo + STR0024 + cRomaneio //"Este cálculo é proveniente da junção dos cálculos: " ### ", dos romaneios: "
			MsUnLock("GWF")
		EndIf	

		dbSelectArea(cAliMKB2)
		dbSetOrder(01) 
		dbGoTop()
		While !(cAliMKB2)->( Eof() )
		
			IncProc("Gravando componentes...")
			
			dbSelectArea("GWI")
			dbSetOrder(1)
			If !dbSeek(xFilial("GWI")+nNovoNrCalc+(cAliMKB2)->CDCLFR+(cAliMKB2)->CDTPOP+(cAliMKB2)->CDCOMP)
				RecLock("GWI",.T.)
					GWI->GWI_FILIAL   := xFilial("GWI")  
					GWI->GWI_NRCALC   := nNovoNrCalc
					GWI->GWI_CDCOMP   := (cAliMKB2)->CDCOMP   
					GWI->GWI_CDCLFR   := (cAliMKB2)->CDCLFR
					GWI->GWI_CDTPOP   := (cAliMKB2)->CDTPOP 
					GWI->GWI_VLFRETE  := (cAliMKB2)->VLFRETE
					GWI->GWI_TOTFRE   := "1"
					GWI->GWI_QTCALC   := (cAliMKB2)->QTCALC 
				MsUnLock("GWI")
		    Else
		    	RecLock("GWI",.F.)
			    	GWI->GWI_VLFRETE += (cAliMKB2)->VLFRETE
					GWI->GWI_QTCALC  += (cAliMKB2)->QTCALC  
		    	MsUnLock("GWI")
			EndIf
			
			(cAliMKB2)->( dbSkip() )	
					                
	    EndDo
	    
	   	ProcRegua(nCountDC)
	    
	    dbSelectArea(cTabDC)
	    dbSetOrder(01) 
	    dbGoTop()
		While !(cTabDC)->( Eof() )		
		
			IncProc("Atualizando Documentos de Carga...")
			
			dbSelectArea("GWH")
			dbSetOrder(1)
			If !dbSeek(xFilial("GWH")+nNovoNrCalc+(cTabDC)->CDTPDC+(cTabDC)->EMISDC+(cTabDC)->SERDC+(cTabDC)->NRDC)
		    	RecLock("GWH",.T.)								
					GWH->GWH_FILIAL  := xFilial("GWH")
					GWH->GWH_NRCALC  := nNovoNrCalc
					GWH->GWH_NRDC    := (cTabDC)->NRDC           
					GWH->GWH_EMISDC  := (cTabDC)->EMISDC
					GWH->GWH_SERDC   := (cTabDC)->SERDC   			
					GWH->GWH_CDTPDC  := (cTabDC)->CDTPDC				
				MsUnLock("GWH")		
			EndIf
	
			(cTabDC)->( dbSkip() )
		EndDo
		
		ProcRegua(nCountTbF)
	
		dbSelectArea(cTabFrete)
		dbSetOrder(01) 
		dbGoTop()
		While !(cTabFrete)->(Eof())	
		
			IncProc("Atualizando tabela de frete do cálculo...")
		
			dbSelectArea("GWG")
			dbSetOrder(1)
			If !dbSeek(xFilial("GWG")+nNovoNrCalc + (cTabFrete)->CDCLFR + (cTabFrete)->CDTPOP)
		    	RecLock("GWG",.T.)
			    	GWG->GWG_FILIAL := xFilial("GWG")
					GWG->GWG_NRCALC := nNovoNrCalc								
					GWG->GWG_CDEMIT := (cTabFrete)->CDEMIT  
					GWG->GWG_NRTAB  := (cTabFrete)->NRTAB   
					GWG->GWG_NRNEG  := (cTabFrete)->NRNEG   
					GWG->GWG_CDTPOP := (cTabFrete)->CDTPOP  
					GWG->GWG_CDCLFR := (cTabFrete)->CDCLFR  							
					GWG->GWG_QTPESO := (cTabFrete)->QTPESO  
					GWG->GWG_QTITEM := (cTabFrete)->QTITEM
					GWG->GWG_VLMERC := (cTabFrete)->VLMERC
					GWG->GWG_PESCUB := (cTabFrete)->PESCUB
					GWG->GWG_QTM3   := (cTabFrete)->QTM3			
				MsUnLock("GWG")		
			EndIf
			
			ConfirmSX8()
			dbSelectArea(cTabFrete)
			dbSkip()
		Enddo	
			
		// ======================================================================= //
		// ======================= Chamado TQRFC2 ================================ //
		// ==== Realiza a soma dos movimentos contábeis dos antigos cálculos ===== //
		// ======== e agrupa em apenas um movimento para o novo cálculo ========== //
		// ======================================================================= //
		
		ProcRegua(nCountMKB)
		
		dbSelectArea(cAliMKB)
		(cAliMKB)->( dbSetOrder(2) )
		(cAliMKB)->( dbSeek(cMarca) )  
		//Tabela temporária dos Romaneios que podem ser agrupados, os que serão estão marcados.           
		While !(cAliMKB)->(Eof()) .and. (cAliMKB)->OK == cMarca
		
			IncProc("Agrupando movimentos contábeis...")
		
			dbSelectArea("GWF")
			GWF->( dbSetOrder(4) )
			If GWF->( dbSeek(xFilial("GWF")+(cAliMKB)->ROMANEIO ) )
				While !GWF->( Eof() ) .And. GWF->GWF_NRROM == Alltrim((cAliMKB)->ROMANEIO)
					dbSelectArea("GWA")
					GWA->( dbSetOrder(3) )
					If GWA->( dbSeek(GWF->GWF_FILIAL+"1"+GWF->GWF_NRCALC) )
						While !GWA->( Eof() ) .And. GWA->GWA_FILIAL == GWF->GWF_FILIAL;
						.And. GWA->GWA_TPDOC == "1";
						.And. Alltrim(GWA->GWA_NRDOC) == GWF->GWF_NRCALC
						
							//Guarda a chave do registro posicionado para posterior comparação.
							cChaveGWA := GWA->GWA_TPDOC+GWA->GWA_CDTRAN+GWA->GWA_TPMOV+GWA->GWA_CTACRE+;
							GWA->GWA_CCCRE+GWA->GWA_CTADEB+GWA->GWA_CCDEB
							
							//Apaga o cálculo que está sendo utilizado como base para o movimento para
							//não somá-lo novamente.
							nPos := aScan(aCalc, {|x| x == Alltrim(GWA->GWA_NRDOC) })
							If nPos != 0
								aDel(aCalc, nPos)
							EndIf
							
							//Guarda o posicionamento da GWA
							aAreaGWA := GWA->( GetArea() )
							
							GWA->( dbSkip() )
							
							//Zera os valores do movimento e a variável lógica de gravação.
							nVlMov := 0
							lAcumula := .F.
							
							While !GWA->( Eof() ) .And. GWA->GWA_FILIAL == GWF->GWF_FILIAL;
							.And. GWA->GWA_TPDOC == "1"
							
								//verifica se o NRDOC corresponde a um movimento de um cálculo que está sendo agrupado.
								If (aScan(aCalc, {|x| x == Alltrim(GWA->GWA_NRDOC) }) != 0)
								
									//Verifica se os movimentos correspondem as mesmas contas e tipo de movimento
									//para realizar a soma dos valores.
									If cChaveGWA == GWA->GWA_TPDOC+GWA->GWA_CDTRAN+GWA->GWA_TPMOV+GWA->GWA_CTACRE+;
										GWA->GWA_CCCRE+GWA->GWA_CTADEB+GWA->GWA_CCDEB
		
										//guarda o valor do movimento posicionado.
										nVlMov += GWA->GWA_VLMOV
										//apaga registro da GWA.
										RecLock("GWA", .F.)
											GWA->( dbDelete() )	
										MsUnlock("GWA")
										lAcumula := .T.	
									EndIf
	
								EndIf
								
								GWA->( dbSkip() )
							EndDo
							
							RestArea(aAreaGWA)
							
							//Realiza a atualização do valor do Movimento
							If lAcumula
								RecLock("GWA", .F.)
									GWA->GWA_VLMOV += nVlMov
								MsUnlock("GWA")
								Aadd(aMovAt, GWA->( Recno() ))
							EndIf 
							   
							GWA->( dbSkip() )
							
						EndDo
					EndIf
				
					GWF->( dbSkip() )
				EndDo
			EndIf	

			(cAliMKB)->( dbSkip() )				
		EndDo
		
		//Realiza a atualização do número do cálculo nos movimentos devidos.
		For nI := 1 To len(aMovAt) 
			nSeq := nI
			dbSelectArea("GWA")
			GWA->( dbGoTo(aMovAt[nI]) )
			RecLock("GWA", .F.)
				If nI > 1
					GWA->GWA_SEQ   := StrZero(nSeq,(TAMSX3("GWA_SEQ")[1]))
				EndIf
				GWA->GWA_NRDOC := nNovoNrCalc
			MsUnlock("GWA")
		Next nI

		ProcRegua(nCountMKB)
		
		(cAliMKB)->( dbSeek(cMarca) )             
		While !(cAliMKB)->(Eof()) .and. (cAliMKB)->OK == cMarca
		
			IncProc("Apagando cálculos...")
		
			dbSelectArea("GWF")
			GWF->( dbSetOrder(4) )
			If GWF->( dbSeek(xFilial("GWF")+(cAliMKB)->ROMANEIO ) )
				While !GWF->( Eof() ) .And. GWF->GWF_NRROM == Alltrim((cAliMKB)->ROMANEIO)
					If GWF->GWF_NRCALC != nNovoNrCalc
						RecLock("GWF", .F.)
							GWF->( dbDelete() )
						MsUnlock("GWF")
					EndIf
				GWF->( dbSkip() )
				EndDo
			EndIf
			(cAliMKB)->( dbSkip() )
		EndDo
			
		If lRet
			msginfo(STR0021 + nNovoNrCalc) //" Novo cálculo gerado: "		
		EndIf
	Else
		GFEA82CRG()
		msginfo("É necessário selecionar romaneios para realizar o agrupamento.")
		lRet := .F.
	EndIf
Return (lRet)
//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GFEA82CLK
Função para marcar/desmarcar todos os cálculos
Generico

@sample
GFEA82CLK(nOp)

@author Ana Claudia da Silva
@since 25/08/2014
@version 1.0
/*///------------------------------------------------------------------------------------------------

Static Function GFEA82CLK(nOp)

dbSelectArea(cAliMKB)
(cAliMKB)->( dbGoTop() )
While !(cAliMKB)->( Eof() )

    If If(nOp==1,!IsMark("OK",cMarca),IsMark("OK",cMarca))
    	RecLock(cAliMKB,.F.)
			(cAliMKB)->OK := If(nOp==1, cMarca, " ")
		MsUnlock(cAliMKB)
	EndIf

	dbSelectArea(cAliMKB)
	(cAliMKB)->( dbSkip() )
EndDo

DbSelectArea(cAliMKB)
(cAliMKB)->( DbGoTop() )

oMark:oBrowse:Refresh()

Return

/*-------------------------------------------------------------------
Verifica se os demais cálculos do romaneio tem tipo diferente do informado
-------------------------------------------------------------------*/
Static Function verCalcDif(cFilRom, cNrRom, cTpCalcInf)

	Local cAliasGW1 := Nil
	Local cWhere    := Nil
	Local aAreaGW1  := GW1->(getArea())
	Local aAreaGWH  := GWH->(getArea())
	Local aAreaGWF  := GWF->(getArea())

	// Documentos de carga
	If GFXCP1212210('GW1_FILROM')
		cWhere := "GW1.GW1_FILROM = '" + cFilRom + "'"
	Else
		cWhere := "GW1.GW1_FILIAL = '" + cFilRom + "'"
	EndIf
	cWhere := "%" + cWhere + "%"

	cAliasGW1 := GetNextAlias()
	BeginSql Alias cAliasGW1
		SELECT GW1_FILIAL, GW1_CDTPDC, GW1_EMISDC, GW1_SERDC, GW1_NRDC, GW1.R_E_C_N_O_ AS GW1RECNO
		FROM %table:GW1% GW1
		WHERE %Exp:cWhere%
		AND GW1.GW1_NRROM  = %Exp:cNrRom%
		AND GW1.%NotDel%
		ORDER BY GW1.GW1_FILIAL,GW1.GW1_NRDC
	EndSql
	While !(cAliasGW1)->(Eof())

		// Documentos de carga x calculos de frete             
		dbSelectArea("GWH")
		dbSetOrder(2)
		dbSeek(xFilial("GWH")+(cAliasGW1)->GW1_CDTPDC+(cAliasGW1)->GW1_EMISDC+(cAliasGW1)->GW1_SERDC+(cAliasGW1)->GW1_NRDC)
		While !GWH->(Eof()) .And.;
			  GWH->GWH_FILIAL+GWH->GWH_CDTPDC+GWH->GWH_EMISDC+GWH->GWH_SERDC+GWH->GWH_NRDC = (cAliasGW1)->GW1_FILIAL+(cAliasGW1)->GW1_CDTPDC+(cAliasGW1)->GW1_EMISDC+(cAliasGW1)->GW1_SERDC+(cAliasGW1)->GW1_NRDC

			if Posicione("GWF",1,xFilial("GWF")+GWH->GWH_NRCALC,"GWF_TPCALC") != cTpCalcInf
				RestArea(aAreaGW1)
				RestArea(aAreaGWH)
				RestArea(aAreaGWF)
				Return .T.
			EndIf

			dbSelectArea("GWH")
			dbSkip()
		EndDo

		(cAliasGW1)->(dbSkip())
	EndDo	
	(cAliasGW1)->(dbCloseArea())

	RestArea(aAreaGW1)
	RestArea(aAreaGWH)
	RestArea(aAreaGWF)
Return .F.
