#INCLUDE "GFEA050A.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "DBINFO.CH"

// SonarQube - CA1003: Uso não permitido de chamada de API em LOOP
Static lPEXGFEAMKB	:= ExistBlock("XGFEAMKB")
Static lPEXACPMKB	:= ExistBlock("XACPMKB")
Static lPEXAliMKB2	:= ExistBlock("XAliMKB2")
Static lPEXQRYMKB	:= ExistBlock("XQRYMKB")
Static lPEXGFERELD  := ExistBlock("XGFERELD")
Static s_GFETRP		:= SuperGetMv("MV_GFETRP",.F.,"1")
Static s_MULFIL		:= SuperGetMV("MV_MULFIL",.F.,"2")


//-------------------------------------------------------------------  
/*/{Protheus.doc} GFEA050B

Cria o vinculo entre o Documento de Carga e um Romaneio, permite ao 
usuário selecionar os documentos de carga que vão fazer parte do romaneio.

@author Luiz Fernando Soares	
@since 17/11/09
@version 1.0
/*/
//-------------------------------------------------------------------

Function GFEA050B(cParamF12)
	Local oDlg
	Local cDSTRAN
	Local cUserName
	Local oSize
	Local aPos
	Local lPEAMKB := ExistBlock("XGFEAMKB")

	aNewButton 	:= {}
	aButt 		:= {}

	Private cCadastro := STR0001 //"Documentos de Carga"
	Private cMarca    := GetMark()
	Private oLisDocC
	//Arrays para os rodapés - [1]->Nr Docs,[2]->Peso,[3]->Peso Cub,[4]->Volume,[5]->Valor Merc,[6]->Nr Volumes,[7]->Peso Liq
	Private aRdpDC    := {0,0,0,0,0,0,0}
	Private aRdpSel   := {0,0,0,0,0,0,0}
	Private _lFiltro  := .F.
	Private _lChgDocs := .F.	// Indica se houve alteração nos documentos de carga do romaneio
	Private oPanelB
	Default cParamF12 := 2 // 1 - Sim 2 - Não

	//----------------------------------------------
	// Criacao da tabela temporaria p/ Markbrowse  
	//---------------------------------------------- 

	aMKB := {{"OK"    ,"C", 02, 0},;
			{"FILIAL" ,"C", 08, 0},;
			{"SERIE"  ,"C", TamSx3("GW1_SERDC")[1], 0},;
			{"NRDC"   ,"C", 16, 0},;
			{"TPDC"   ,"C", 05, 0},;
			{"TPFRET" ,"C", 25, 0},;
			{"CDEMIS" ,"C", TamSx3("GU3_CDEMIT")[1], 0},;
			{"NMEMIS" ,"C", 30, 0},;
			{"CDREM"  ,"C", TamSx3("GU3_CDEMIT")[1], 0},;
			{"NMREM"  ,"C", 30, 0},;
			{"CDDEST" ,"C", TamSx3("GU3_CDEMIT")[1], 0},;
			{"NMDEST" ,"C", 30, 0},;
			{"NRREG"  ,"C", 06, 0},;
			{"NRCID"  ,"C", TamSx3("GU3_NRCID")[1], 0},;
			{"DTEMIS" ,"D", 08, 0},;
			{"DTSAI"  ,"D", 08, 0},;
			{"CIDDES" ,"C", TamSx3("GU7_NMCID")[1], 0},;// Cidade Destinatario
			{"UFDEST" ,"C", 08, 0}}

	
	//Ponto de entrada Harley Davidson
	If lPEAMKB
		aMKB := ExecBlock("XGFEAMKB",.f.,.f.,{aMKB , '3' })
	EndIf 	
	//Fim ponto de entrada Harley Davidson

	aCpMKB  := {{"OK"    , NIL, "", ""},;
				{"FILIAL", NIL, "Filial",""},;
				{"SERIE" , NIL, STR0002, "@R"},; //"Serie"
				{"NRDC"  , NIL, STR0003, "@!"},; //"Numero do Documento"
				{"TPDC"  , NIL, STR0004, "@!"},; //"Tipo Documento"
				{"TPFRET", NIL, "Tipo de Frete", ""},;
				{"CDEMIS", NIL, STR0005, "@!"},; //"Emissor do Documento"
				{"NMEMIS", NIL, STR0006, ""},; //"Nome do Emissor"
				{"CDREM" , NIL, STR0007, "@!"},; //"Remetente"
				{"NMREM" , NIL, "Nome do Remetente", ""},;
				{"CDDEST", NIL, STR0008, "@!"},; //"Destinatário"
				{"NMDEST", NIL, "Nome do Destino", ""},;
				{"CIDDES", NIL, "Cidade Destino", ""},;
				{"UFDEST", NIL, "UF Destino", "@!"}}

	//Ponto de entrada Harley Davidson
	If lPEXACPMKB
		aCpMKB := ExecBlock("XACPMKB",.f.,.f.,{aCpMKB, '3'})
	EndIf 	
	//Fim ponto de entrada Harley Davidson		


	cAliMKB := GFECriaTab({aMKB, {"NRDC", "OK","TPDC+CDEMIS+SERIE+NRDC"}})

	//----------------------------------------------
	// Criacao da tabela temporaria p/ Markbrowse  
	//----------------------------------------------

	aMKB2:=	{{"FILIAL" ,"C", TamSx3("GW1_FILIAL")[1], 0},;
			{"SERIE"   ,"C", TamSx3("GW1_SERDC")[1], 0},;
			{"NRDC"    ,"C", 16, 0},;
			{"TPDC"    ,"C", 05, 0},;
			{"TPFRET"  ,"C", 25, 0},;
			{"CDEMIS"  ,"C", TamSx3("GU3_CDEMIT")[1], 0},;
			{"NMEMIS"  ,"C", 30, 0},;
			{"CDREM"   ,"C", TamSx3("GU3_CDEMIT")[1], 0},;
			{"NMREM"   ,"C", 30, 0},;
			{"CDDEST"  ,"C", TamSx3("GU3_CDEMIT")[1], 0},;
			{"NMDEST"  ,"C", 30, 0},;
			{"NRREG"   ,"C", 06, 0},;
			{"NRCID"   ,"C", TamSx3("GU3_NRCID")[1], 0},;
			{"DTEMIS"  ,"C", 08, 0},;
			{"DTSAI"   ,"C", 08, 0},;
			{"CIDDES"  ,"C", TamSx3("GU7_NMCID")[1], 0},;
			{"UFDEST"  ,"C", 30, 0}}                                   
	
	//Ponto de entrada Harley Davidson
	If lPEXGFEAMKB
		aMKB2:= ExecBlock("XGFEAMKB",.f.,.f.,{aMKB2, '2'})
	EndIf 	
	//Fim ponto de entrada Harley Davidso                                

	aCpMKB2  := {{"FILIAL",NIL, "Filial", "@R"},;
				{"SERIE"  ,NIL, STR0002, "@R"},; //"Serie"
				{"NRDC"   ,NIL, STR0003, "@!"},; //"Numero do Documento"
				{"TPDC"   ,NIL, STR0004, "@!"},; //"Tipo Documento"
				{"TPFRET" ,NIL, "Tipo de Frete", ""},;
				{"CDEMIS" ,NIL, STR0005, "@!"},; //"Emissor do Documento"
				{"NMEMIS" ,NIL, STR0006, ""},; //"Nome do Emissor"
				{"CDREM"  ,NIL, STR0007, "@!"},; //"Remetente"
				{"NMREM"  ,NIL, "Nome do Remetente", ""},;
				{"CIDDES" ,NIL, "Cidade Destino", ""},;
				{"UFDEST" ,NIL, "UF Destino", "@!"}}

	//Ponto de entrada Harley Davidson
	If lPEXACPMKB
		aCpMKB2 := ExecBlock("XACPMKB",.f.,.f.,{aCpMKB2, '2'})
	EndIf 	
	//Fim ponto de entrada Harley Davidson		

	cAliMKB2 := GFECriaTab({aMKB2, {"NRDC","TPDC+CDEMIS+SERIE+NRDC"}})

	If s_MULFIL == "1"
		Pergunte("GFEA050FIL", .F.)
	Else
		Pergunte("GFEA050", .F.)
	EndIf
	
	If cParamF12 != 1 //Não exibe tela de filtro antes da abertura do programa
		PswOrder(1)
		If PswSeek(RetCodUsr())
			cUserName := cEmpAnt + PswRet(1)[1][2]
			If FindProfDef(cUserName, "GFEA050", "PERGUNTE", "MV_PAR")
				WriteProfDef(cUserName, "GFEA050", "PERGUNTE", "MV_PAR", ; // Chave antiga
				cUserName, "GFEA050", "PERGUNTE", "MV_PAR", ; // Chave nova
				"C#G#     "             + CRLF + ;
				"C#G#zzzzz"             + CRLF + ;
				"C#G#                "  + CRLF + ;
				"C#G#zzzzzzzzzzzzzzzz"  + CRLF + ;
				"C#G#       "           + CRLF + ;
				"C#G#9999999"           + CRLF + ;
				"C#G#  "                + CRLF + ;
				"C#G#zz"                + CRLF + ;
				"C#G#              "    + CRLF + ;
				"C#G#zzzzzzzzzzzzzz"    + CRLF + ;
				"C#G#" + GWN->GWN_CDTRP + CRLF + ;
				"C#G#" + GWN->GWN_CDTRP + CRLF + ;
				"C#G#     "             + CRLF + ;
				"C#G#zzzzz"             + CRLF + ;
				"C#G#1"	                + CRLF + ;
				"D#G#        "          + CRLF + ;
				"D#G#20491231"          + CRLF + ;
				"D#G#20000101"          + CRLF + ;
				"D#G#" + DToS(Date())   + CRLF + ;
				"C#G#            "      + CRLF + ;
				"C#G#zzzzzzzzzzzz")
			EndIf
		EndIf
	EndIf

	CursorWait()

	//Criação da tela

	oSize := FWDefSize():New(.T.)
	oSize:AddObject( "ENCHOICE", 100, 60, .T., .T. ) // Adiciona enchoice
	oSize:lLateral     := .F.  // Calculo vertical	
	oSize:Process() //executa os calculos

	aPos := {oSize:GetDimension("ENCHOICE","LININI"),; 
	oSize:GetDimension("ENCHOICE","COLINI"),;
	oSize:GetDimension("ENCHOICE","XSIZE"),;
	oSize:GetDimension("ENCHOICE","YSIZE")}

	DEFINE MSDIALOG oDlg TITLE cCadastro ;
	FROM oSize:aWindSize[1],oSize:aWindSize[2] ;
	TO oSize:aWindSize[3],oSize:aWindSize[4] ; 
	Of oMainWnd COLORS 0, 16777215 PIXEL	
	oDlg:lEscClose := .F.

	oPnlCnt := tPanel():New(aPos[1],aPos[2],,oDlg,,,,,,aPos[3],aPos[4],.F.,.F.)
	//----- Painel superior da tela principal, com as informacoes do romaneio -----//
	oPnlA := tPanel():New(00,00,,oPnlCnt,,,,,,10,20,.F.,.F.)
	oPnlA:Align := CONTROL_ALIGN_TOP

	//----- Splitter para permitir ao usuario movimentar os paineis dos browses -----//	
	oSplitter := tSplitter():New( 0,0,oPnlCnt,80,80,1 ) 
	oSplitter:Align := CONTROL_ALIGN_ALLCLIENT

	//----- Painel superior da tela, para o browse de documentos de cargas -----//
	oPanelB := TPanel():New(01,01,,oSplitter,,,,,,0,0,.F.,.T.)
	oPanelB:Align := CONTROL_ALIGN_TOP

	//----- Painel lateral do browse de documentos relacionados, para adicionar botoes -----//
	oPnlBtn1:=TPanel():New(00,00,,oPanelB,,,,,RGB(67,70,87),15,15,.F.,.F.)
	oPnlBtn1:Align := CONTROL_ALIGN_LEFT

	//------ Botao para adicionar relacionamento do Documento de carga com o romaneio -----//

	oBtnAdd  := TBtnBmp():NewBar("PMSSETADOWN","PMSSETADOWN",,,,{||GFEA50BOK()},,oPnlBtn1,,,"",,,,,"")
	oBtnAdd:cToolTip := STR0010 //"Adicionar"
	oBtnAdd:Align    := CONTROL_ALIGN_TOP

	//------ Botao para Filtro do Documento de carga com o romaneio -----//			
	oBtnFiltro			:= TBtnBmp():NewBar("brw_filtro","brw_filtro",,,,{|| GFE50BFIL()},,oPnlBtn1,,,"",,,,,"")
	oBtnFiltro:cToolTip := STR0011 //"Filtrar"
	oBtnFiltro:Align    := CONTROL_ALIGN_TOP

	//Botão para selecionar todos os documentos de carga
	oBtnChk := TBtnBmp():NewBar("CHECKED","CHECKED",,,,{||GFEA50BCHK(1)},,oPnlBtn1,,,"",,,,,"")
	oBtnChk:cToolTip := STR0045 //"Marca todos os documentos de carga em tela"
	oBtnChk:Align    := CONTROL_ALIGN_TOP

	//Botão para desselecionar todos os documentos de carga
	oBtnDChk := TBtnBmp():NewBar("UNCHECKED","UNCHECKED",,,,{||GFEA50BCHK(2)},,oPnlBtn1,,,"",,,,,"")
	oBtnDChk:cToolTip := STR0046 //"Desmarca todos os documentos de carga em tela"
	oBtnDChk:Align    := CONTROL_ALIGN_TOP

	//-----Painel inferior com o rodapé---//

	oPanelE := TPanel():New(00,00,,oPanelB,,,,,RGB(67,70,87),12,18,.F.,.F.)
	oPanelE:Align := CONTROL_ALIGN_BOTTOM 

	oSayRdp := tSay():New(05,18 ,{||STR0034},oPanelE,,TFont():New('Arial',,-12,,.T.),,,,.T.,CLR_WHITE,CLR_WHITE,100,20) //"Nr Docs:"
	oSayRdp := tSay():New(05,103,{||STR0035},oPanelE,,TFont():New('Arial',,-12,,.T.),,,,.T.,CLR_WHITE,CLR_WHITE,100,20) //"Peso:"
	oSayRdp := tSay():New(05,179,{||"Peso Liq:"},oPanelE,,TFont():New('Arial',,-12,,.T.),,,,.T.,CLR_WHITE,CLR_WHITE,100,20) //
	oSayRdp := tSay():New(05,263,{||STR0036},oPanelE,,TFont():New('Arial',,-12,,.T.),,,,.T.,CLR_WHITE,CLR_WHITE,100,20) //"Peso Cub:"
	oSayRdp := tSay():New(05,350,{||STR0037},oPanelE,,TFont():New('Arial',,-12,,.T.),,,,.T.,CLR_WHITE,CLR_WHITE,100,20) //"Volume:"
	oSayRdp := tSay():New(05,432,{||STR0038},oPanelE,,TFont():New('Arial',,-12,,.T.),,,,.T.,CLR_WHITE,CLR_WHITE,100,20) //"Valor Merc:"
	oSayRdp := tSay():New(05,524,{||STR0039},oPanelE,,TFont():New('Arial',,-12,,.T.),,,,.T.,CLR_WHITE,CLR_WHITE,100,20) //"Nr Volumes:"

	oGetRdp1 := TGet():New(04,46 ,{|u| If(PCount()>0,aRdpDC[1]:=u,aRdpDC[1])},oPanelE,50,8,'999999999'        ,,,,,,,.T.,,,{|| .F.},,,,,,,"aRdpDC[1]",,,,,.T.,.T.)
	oGetRdp2 := TGet():New(04,122,{|u| If(PCount()>0,aRdpDC[2]:=u,aRdpDC[2])},oPanelE,50,8,'999,999,999.99999',,,,,,,.T.,,,{|| .F.},,,,,,,"aRdpDC[2]",,,,,.T.,.T.)
	oGetRdp7 := TGet():New(04,208,{|u| If(PCount()>0,aRdpDC[7]:=u,aRdpDC[7])},oPanelE,50,8,'999,999,999.99999',,,,,,,.T.,,,{|| .F.},,,,,,,"aRdpDC[7]",,,,,.T.,.T.)
	oGetRdp3 := TGet():New(04,294,{|u| If(PCount()>0,aRdpDC[3]:=u,aRdpDC[3])},oPanelE,50,8,'999,999,999.99999',,,,,,,.T.,,,{|| .F.},,,,,,,"aRdpDC[3]",,,,,.T.,.T.)
	oGetRdp4 := TGet():New(04,375,{|u| If(PCount()>0,aRdpDC[4]:=u,aRdpDC[4])},oPanelE,50,8,'999,999,999.99999',,,,,,,.T.,,,{|| .F.},,,,,,,"aRdpDC[4]",,,,,.T.,.T.)
	oGetRdp5 := TGet():New(04,468,{|u| If(PCount()>0,aRdpDC[5]:=u,aRdpDC[5])},oPanelE,50,8,'999,999,999.99'   ,,,,,,,.T.,,,{|| .F.},,,,,,,"aRdpDC[5]",,,,,.T.,.T.)
	oGetRdp6 := TGet():New(04,561,{|u| If(PCount()>0,aRdpDC[6]:=u,aRdpDC[6])},oPanelE,50,8,'999999999'        ,,,,,,,.T.,,,{|| .F.},,,,,,,"aRdpDC[6]",,,,,.T.,.T.)

	//----- Painel superior do browse de documentos de carga, para colocar o titulo -----//
	oPnlBtn:=TPanel():New(00,00,,oPanelB,,,,,RGB(67,70,87),12,12,.F.,.F.)
	oPnlBtn:Align := CONTROL_ALIGN_TOP
	oFont12B := TFont():New('Arial',,-12,,.T.)
	@ 03,14  Say STR0012 Of oPnlBtn COLOR CLR_WHITE Pixel font oFont12B  //"Selecione Documentos de Carga " 

	//---------------- Fim do painel superior da tela ------------------//


	//----- Painel inferior da tela, para o browse de documentos relacionados -----//
	oPanelC := TPanel():New(01,01,,oSplitter,,,,,,0,0,.F.,.T.)
	oPanelC:Align := CONTROL_ALIGN_BOTTOM

	//----- Painel lateral do browse de documentos relacionados, para adicionar botoes -----//
	oPnlBtn2:=TPanel():New(00,00,,oPanelC,,,,,RGB(67,70,87),15,16,.F.,.F.)
	oPnlBtn2:Align := CONTROL_ALIGN_LEFT
	
	SetKey(VK_F8,{||GFE50DELDC()})
	//------ Botao para excluir relacionamento do Documento de carga com o romaneio -----//
	oBtnDel  := TBtnBmp():NewBar("PMSSETAUP","PMSSETAUP",,,,{||GFE50DELDC()},,oPnlBtn2,,,"",,,,,"")
	oBtnDel:cToolTip := STR0013 //"Excluir"
	oBtnDel:Align    := CONTROL_ALIGN_TOP


	SetKey(VK_F9,{||GFEA050BDC()})
	//Adiciona documento de carga
	oBtnAddDC		  := TBtnBmp():NewBar("BMPINCLUIR","BMPINCLUIR",,,,{||GFEA050BDC()},,oPnlBtn2,,,"",,,,,"")
	oBtnAddDC:cToolTip := "Localiza e adiciona documentos de carga.(Abrir - F9|Adicionar - F10)"
	oBtnAddDC:Align    := CONTROL_ALIGN_TOP

	//------ Botao para visualizar Documento de carga  -----// 
	oBtnVis  := TBtnBmp():NewBar("bmpvisual","bmpvisual",,,,{||GFE050VIS()},,oPnlBtn2,,,"",,,,,"")
	oBtnVis:cToolTip := STR0014 //"Visualzar"
	oBtnVis:Align    := CONTROL_ALIGN_TOP

	//------ Botao para visualizar Trechos  -----// 
	//	oBtnTre  := TBtnBmp():NewBar("produto","produto",,,,{||GFE050TRE()},,oPnlBtn2,,,"",,,,,"")
	//	oBtnTre:cToolTip := "Trechos"
	//	oBtnTre:Align    := CONTROL_ALIGN_TOP

	//------ Botao para simular Trechos  -----// 
	oBtnCalc		  := TBtnBmp():NewBar("SIMULACAO","SIMULACAO",,,,{||GFEA50BCL()},,oPnlBtn2,,,"",,,,,"")
	oBtnCalc:cToolTip := STR0015 //"Simular Calculo"
	oBtnCalc:Align    := CONTROL_ALIGN_TOP

	//----- Painel superior do browse de documentos relacionados, para colocar o titulo -----//	
	oPnlBtn3:=TPanel():New(00,00,,oPanelC,,,,,RGB(67,70,87),12,12,.F.,.F.)
	oPnlBtn3:Align := CONTROL_ALIGN_TOP
	oFont12B := TFont():New('Arial',,-12,,.T.)
	@ 03,14  Say STR0016 Of oPnlBtn3 COLOR CLR_WHITE Pixel font oFont12B 	 //"Documentos de Carga Relacionados "
	//--------------- Fim do painel inferior da tela principal-----------------------//

	//--------StatusBar onde serão apresentados os valores totais referente aos documentos de carga relacionados--------------------//

	oPanelD := TPanel():New(00,00,,oPanelC,,,,,RGB(67,70,87),12,18,.F.,.F.)
	oPanelD:Align := CONTROL_ALIGN_BOTTOM 

	oSayRdp := tSay():New(05,18 ,{||STR0034},oPanelD,,TFont():New('Arial',,-12,,.T.),,,,.T.,CLR_WHITE,CLR_WHITE,100,20) //"Nr Docs:"
	oSayRdp := tSay():New(05,103,{||STR0035},oPanelD,,TFont():New('Arial',,-12,,.T.),,,,.T.,CLR_WHITE,CLR_WHITE,100,20) //"Peso:"
	oSayRdp := tSay():New(05,179,{||"Peso Liq:"},oPanelD,,TFont():New('Arial',,-12,,.T.),,,,.T.,CLR_WHITE,CLR_WHITE,100,20) //
	oSayRdp := tSay():New(05,263,{||STR0036},oPanelD,,TFont():New('Arial',,-12,,.T.),,,,.T.,CLR_WHITE,CLR_WHITE,100,20) //"Peso Cub:"
	oSayRdp := tSay():New(05,350,{||STR0037},oPanelD,,TFont():New('Arial',,-12,,.T.),,,,.T.,CLR_WHITE,CLR_WHITE,100,20) //"Volume:"
	oSayRdp := tSay():New(05,432,{||STR0038},oPanelD,,TFont():New('Arial',,-12,,.T.),,,,.T.,CLR_WHITE,CLR_WHITE,100,20) //"Valor Merc:"
	oSayRdp := tSay():New(05,524,{||STR0039},oPanelD,,TFont():New('Arial',,-12,,.T.),,,,.T.,CLR_WHITE,CLR_WHITE,100,20) //"Nr Volumes:"

	oGetRdp := TGet():New(04,46 ,{|u| If(PCount()>0,aRdpSel[1]:=u,aRdpSel[1])},oPanelD,50,8,'999999999'           ,,,,,,,.T.,,,{|| .F.},,,,,,,"aRdpSel[1]",,,,,.T.,.T.)
	oGetRdp := TGet():New(04,122,{|u| If(PCount()>0,aRdpSel[2]:=u,aRdpSel[2])},oPanelD,50,8,'@E 999,999,999.99999',,,,,,,.T.,,,{|| .F.},,,,,,,"aRdpSel[2]",,,,,.T.,.T.)
	oGetRdp := TGet():New(04,208,{|u| If(PCount()>0,aRdpSel[7]:=u,aRdpSel[7])},oPanelD,50,8,'@E 999,999,999.99999',,,,,,,.T.,,,{|| .F.},,,,,,,"aRdpSel[7]",,,,,.T.,.T.)
	oGetRdp := TGet():New(04,294,{|u| If(PCount()>0,aRdpSel[3]:=u,aRdpSel[3])},oPanelD,50,8,'@E 999,999,999.99999',,,,,,,.T.,,,{|| .F.},,,,,,,"aRdpSel[3]",,,,,.T.,.T.)
	oGetRdp := TGet():New(04,375,{|u| If(PCount()>0,aRdpSel[4]:=u,aRdpSel[4])},oPanelD,50,8,'@E 999,999,999.99999',,,,,,,.T.,,,{|| .F.},,,,,,,"aRdpSel[4]",,,,,.T.,.T.)
	oGetRdp := TGet():New(04,468,{|u| If(PCount()>0,aRdpSel[5]:=u,aRdpSel[5])},oPanelD,50,8,'@E 999,999,999.99'   ,,,,,,,.T.,,,{|| .F.},,,,,,,"aRdpSel[4]",,,,,.T.,.T.)
	oGetRdp := TGet():New(04,561,{|u| If(PCount()>0,aRdpSel[6]:=u,aRdpSel[6])},oPanelD,50,8,'999999999'           ,,,,,,,.T.,,,{|| .F.},,,,,,,"aRdpSel[6]",,,,,.T.,.T.)	

	//--------Fim do Statusbar

	// ----- Criacao dos fields referente ao romaneio no painel superior da tela principal -----//
	cDSTRAN := posicione("GU3",1,xFilial("GU3")+GWN->GWN_CDTRP,"GU3_NMEMIT")	
	@ 07,10  Say STR0017 Of oPnlA COLOR CLR_BLACK Pixel //"Filial: "
	@ 05,25  MSGET GWN->GWN_FILIAL Picture "@!" Of oPnlA When .F. SIZE 40,10  Pixel

	@ 07,72  Say STR0018 Of oPnlA COLOR CLR_BLACK Pixel //"Romaneio: "
	@ 05,102  MSGET GWN->GWN_NRROM Picture "@!" Of oPnlA When .F. SIZE 55,10   Pixel  			

	@ 07,167 Say STR0019            Of oPnlA COLOR CLR_BLACK Pixel //"Transportadora: "
	@ 05,212 MSGET GWN->GWN_CDTRP  Picture "@!" Of oPnlA When .F.  SIZE 80,10  Pixel 			
	@ 05,300 MSGET cDSTRAN Picture "@!" Of oPnlA When .F. SIZE 180,10  Pixel 			                                                                                                                                                                      
	//---------Fim da criacao dos fields ----------//

	//--1----- Seleciona a temp-table de Documentos de cargas que nao foram relacionados ao romaneio e cria o browse -----// 	
	dbSelectArea(cAliMKB)
	dbSetOrder(01)
	dbGoTop()
	oMark := MsSelect():New(cAliMKB,"OK",,aCpMKB,,@cMarca,{0,0,0,0},,,oPanelB)
	oMark:oBrowse:cToolTip := STR0001 //"Documentos de Carga"
	oMark:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	oMark:oBrowse:bLDblClick := {|| GFEA50BCLK()}
	//--------------Fim 1 -- criado o browse---------------//
	//--2----- Seleciona a temp-table de Documentos de cargas que ja foram relacionados ao romaneio e cria o browse -----// 
	dbSelectArea(cAliMKB2)
	dbSetOrder(01)
	dbGoTop()
	//Ponto de entrada Harley Davidson
	If lPEXAliMKB2
		lPedHD := ExecBlock("XAliMKB2",.f.,.f.,nil)
	EndIf 	
	
	If lPedHD
		@ 0,0 Listbox oLisDocC Fields (cAliMKB2)->FILIAL  ,;
		(cAliMKB2)->SERIE   ,;
		(cAliMKB2)->NRPED   ,;
		(cAliMKB2)->TPPED   ,;
		(cAliMKB2)->NRDC    ,;
		(cAliMKB2)->TPDC    ,;
		(cAliMKB2)->TPFRET  ,;
		(cAliMKB2)->CDEMIS  ,;
		(cAliMKB2)->NMEMIS  ,;
		(cAliMKB2)->CDREM   ,;
		(cAliMKB2)->NMREM   ,;
		(cAliMKB2)->CDDEST  ,; 
		(cAliMKB2)->NMDEST  ,;
		(cAliMKB2)->CIDDES  ,;
		(cAliMKB2)->UFDEST   ;		
		FieldSizes 10,10,18,09,30,25,10,10,30,10,30,30;
		Size 140,290 Pixel Of oPanelC   ;
		HEADERS 	"Filial",;
		STR0002 	  	    ,; //"Serie"
		"Num Ped"           ,;
		"Tipo Ped"          ,;
		STR0020 		    ,; //"Numero"
		STR0021 		    ,; //"Tipo Doc."
		"Tipo Frete"        ,; //"Tipo Frete"
		STR0022             ,; //"Emissor"
		STR0023  	  	    ,; //"Nome Emissor"
		STR0007             ,; //"Remetente"
		STR0024             ,; //"Nome"
		STR0025             ,; //"Cod Dest"
		STR0026             ,; //"Destinatario"
		"Cidade Destino"    ,; //"Cidade Destinatario" 
		"UF Destino"         ; //"UF Destinatario"

		oLisDocC:Align := CONTROL_ALIGN_ALLCLIENT
	Else
		@ 0,0 Listbox oLisDocC Fields 	(cAliMKB2)->SERIE   ,;
		(cAliMKB2)->NRDC    ,;
		(cAliMKB2)->TPDC    ,;
		(cAliMKB2)->TPFRET  ,;
		(cAliMKB2)->CDEMIS  ,;
		(cAliMKB2)->NMEMIS  ,;
		(cAliMKB2)->CDREM   ,;
		(cAliMKB2)->NMREM   ,;
		(cAliMKB2)->CDDEST  ,; 
		(cAliMKB2)->NMDEST  ,;
		(cAliMKB2)->CIDDES  ,;
		(cAliMKB2)->UFDEST   ;		
		FieldSizes 10,09,30,25,10,10,30,10,30,30;
		Size 140,290 Pixel Of oPanelC   ;
		HEADERS 	STR0002 	  	    ,; //"Serie"
		STR0020 		    ,; //"Numero"
		STR0021 		    ,; //"Tipo Doc."
		"Tipo Frete"      ,; //"Tipo Frete"
		STR0022           ,; //"Emissor"
		STR0023  	  	    ,; //"Nome Emissor"
		STR0007           ,; //"Remetente"
		STR0024           ,; //"Nome"
		STR0025           ,; //"Cod Dest"
		STR0026           ,; //"Destinatario"
		"Cidade Destino",; //"Cidade Destinatario" 
		"UF Destino"  ;  //"UF Destinatario"



		oLisDocC:Align := CONTROL_ALIGN_ALLCLIENT
	EndIf

	//--------------Fim 2--------------------//
	If cParamF12 == 1 //Exibe tela de filtro antes da abertura do programa
		GFE50BFIL()
	EndIf
	//----- Processa os registros e carrega os browses -----//
	Processa({|lEnd| GFE50BMKB()},STR0027,STR0028) //"Processando informações"###"Aguarde"
	CursorArrow()

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(ODlg,{||If(GFEA50BOK(),ODlg:End(),NIL)},;
	{||ODlg:End()},,aNewButton,/*nRecno*/,/*cAlias*/,/*lMashups*/,/*lImpCad*/, /*lPadrao*/, .F. /*lHasOK*/) CENTERED

	//------ Limpa as tabelas temporarias -----//
	GFEDelTab(cAliMKB)
	GFEDelTab(cAliMKB2)
	//-----------------------------------------//

	//Depois de limpar as temp-table é necessário selecionar uma tabela, para que não ocorra erros//
	dbSelectArea("GWN")
	SetKey(VK_F9,{||})
	SetKey(VK_F8,{||})
	Return _lChgDocs


//-------------------------------------------------------------------
/*/{Protheus.doc} GFE50BMKB
Acrescenta os registros na tabela temporaria para que eles sejam exibidos na tela


@author Luiz Fernando Soares
@since 20/11/09
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function GFE50BMKB()

	dbSelectArea(cAliMKB)
	ZAP

	dbSelectArea(cAliMKB2)
	ZAP

	cQuery := "SELECT '  ' OK, GW1.GW1_FILIAL FILIAL, GW1.GW1_SERDC SERIE, GW1.GW1_NRDC NRDC, GW1.GW1_CDTPDC TPDC, "
	cQuery += GFEA66CASE("GW1", "GW1_TPFRET", "TPFRET", "''") + ", "
	cQuery += "      	GW1.GW1_EMISDC CDEMIS, GU3EMI.GU3_NMEMIT NMEMIS, GW1.GW1_CDREM CDREM, "
	cQuery += "		GU3REM.GU3_NMEMIT NMREM, GW1.GW1_CDDEST CDDEST, GU3DES.GU3_NMEMIT NMDEST, GW1.GW1_NRREG NRREG, "
	cQuery += "		GW1.GW1_DTEMIS DTEMIS, GW1.GW1_DTPSAI DTSAI, "
	cQuery += "		(CASE GW1.GW1_ENTNRC "
	cQuery += "			WHEN '' THEN GU3DES.GU3_NRCID"
	cQuery += "	   		ELSE GW1.GW1_ENTNRC "
	cQuery += " 		END) NRCID, "
	cQuery += "		(CASE GW1.GW1_ENTNRC "
	cQuery += "			WHEN '' THEN GU7DEST.GU7_NMCID"
	cQuery += "	   		ELSE GU7DOC.GU7_NMCID "
	cQuery += " 		END) CIDDES, "
	cQuery += "		(CASE GW1.GW1_ENTNRC "
	cQuery += "			WHEN '' THEN GU7DEST.GU7_CDUF"
	cQuery += "	   		ELSE GU7DOC.GU7_CDUF "
	cQuery += " 		END) UFDEST "	

	//Ponto de entrada Harley Davidson
	If lPEXQRYMKB
		cQuery += ExecBlock("XQRYMKB",.f.,.f.,nil)
	EndIf 	
	//Fim ponto de entrada Harley Davidson

	cQuery += "FROM " + RetSQLName("GW1") + " GW1 "
	cQuery += "INNER JOIN " + RetSQLName("GU3") + " GU3EMI ON GU3EMI.GU3_FILIAL = '" + xFilial("GU3") + "' AND GU3EMI.GU3_CDEMIT = GW1.GW1_EMISDC "
	cQuery += "INNER JOIN " + RetSQLName("GU3") + " GU3REM ON GU3REM.GU3_FILIAL = '" + xFilial("GU3") + "' AND GU3REM.GU3_CDEMIT = GW1.GW1_CDREM "
	cQuery += "INNER JOIN " + RetSQLName("GU3") + " GU3DES ON GU3DES.GU3_FILIAL = '" + xFilial("GU3") + "' AND GU3DES.GU3_CDEMIT = GW1.GW1_CDDEST "


	If _lFiltro
		cQuery += "INNER JOIN " + RetSQLName("GU7") + " GU7 ON GU7.GU7_FILIAL =  '" + xFilial("GU7") + "' AND GU7.GU7_NRCID = GU3DES.GU3_NRCID "
	EndIf

	cQuery += "INNER JOIN " + RetSQLName("GV5") + " GV5 ON GV5.GV5_FILIAL = '" + xFilial("GV5") + "' AND GV5.GV5_CDTPDC = GW1.GW1_CDTPDC "
	cQuery += "INNER JOIN " + RetSQLName("GWU") + " GWU ON GWU.GWU_FILIAL =  GW1.GW1_FILIAL AND GWU.GWU_CDTPDC = GW1.GW1_CDTPDC AND "
	cQuery += "		GWU.GWU_EMISDC = GW1.GW1_EMISDC AND GWU.GWU_SERDC = GW1.GW1_SERDC AND GWU.GWU_NRDC = GW1.GW1_NRDC AND GWU.GWU_SEQ = '01' "
	cQuery += "INNER JOIN " + RetSQLName("GV4") + " GV4 ON GV4.GV4_FILIAL = '" + xFilial("GV4") + "' AND GV4.GV4_CDTPOP = '" + GWN->GWN_CDTPOP + "'"

	cQuery += "LEFT JOIN " + RetSQLName("GU7") + " GU7DEST ON GU7DEST.GU7_FILIAL = '" + xFilial("GU7") + "' AND GU7DEST.GU7_NRCID = GU3DES.GU3_NRCID "
	cQuery += "LEFT JOIN " + RetSQLName("GU7") + " GU7DOC ON GU7DOC.GU7_FILIAL = '" + xFilial("GU7") + "' AND GU7DOC.GU7_NRCID = GW1.GW1_ENTNRC "

	cQuery += "WHERE GW1.GW1_SIT = '3' "
	cQuery += " AND (GW1.GW1_NRROM = '' OR GW1.GW1_NRROM = '0') "
	cQuery += " AND (GV5.GV5_SENTID = GV4.GV4_SENTID OR GV4.GV4_SENTID = '0') " 
	cQuery += " AND GW1.D_E_L_E_T_ = ' '" 
	cQuery += " AND GV4.D_E_L_E_T_ = ' ' "
	cQuery += " AND GU3EMI.D_E_L_E_T_ = ' ' " 
	cQuery += " AND GU3REM.D_E_L_E_T_ = ' ' "
	cQuery += " AND GV5.D_E_L_E_T_ = ' ' "
	cQuery += " AND GU3DES.D_E_L_E_T_ = ' ' "
	cQuery += " AND GWU.D_E_L_E_T_ = ' ' "
	cQuery += " AND GU7DEST.D_E_L_E_T_ = ' ' "
	
	If s_MULFIL == "2"
		cQuery += "AND GW1.GW1_FILIAL = '" + GWN->GWN_FILIAL + "' "
	EndIf

	If s_MULFIL == "1"
		If _lFiltro
			cQuery += "AND GW1.GW1_FILIAL >= '" + MV_PAR01 + "' AND GW1.GW1_FILIAL <= '" + MV_PAR02 + "' "
			cQuery += "AND GW1.GW1_SERDC >= '" + MV_PAR03 + "' AND GW1.GW1_SERDC <= '" + MV_PAR04 + "' " //Série
			cQuery += "AND GW1.GW1_NRDC >= '" + MV_PAR05 + "' AND GW1.GW1_NRDC <= '" + MV_PAR06 + "' " //Número
			If MV_PAR17 == 2
				cQuery += " AND (GW1.GW1_TPFRET = '1' OR GW1.GW1_TPFRET = '2') " //Doc. Carga CIF ou CIF Redesp.
			ElseIf MV_PAR17 == 3
				cQuery += " AND (GW1.GW1_TPFRET = '3' OR GW1.GW1_TPFRET = '4') " //Doc. Carga FOB ou FOB Redesp.
			EndIf
			cQuery += "AND ((GU3DES.GU3_NRCID >= '" + MV_PAR07 + "' AND GU3DES.GU3_NRCID <= '" + MV_PAR08 + "' AND GW1.GW1_ENTNRC = '') OR "
			cQuery += "(GW1.GW1_ENTNRC >= '" + MV_PAR07 + "' AND GW1.GW1_ENTNRC <= '" + MV_PAR08 + "' AND GW1.GW1_ENTNRC <> ''))" //Cidade

			cQuery += "AND GU7.GU7_CDUF >= '" + MV_PAR09 + "' AND GU7.GU7_CDUF <= '" + MV_PAR10 + "' " //UF
			cQuery += "AND GW1.GW1_CDDEST >= '" + MV_PAR11 + "' AND GW1.GW1_CDDEST <= '" + MV_PAR12 + "' " //Destinatário
		EndIf
		/*
		Verifica se o parâmetro MV_GFETRP -> Transportador de Início e fim = Ao Transportador do Romaneio
		Ou se o Filtro não está sendo aplicado. 
		*Se verdadeiro atribui o valor do transportador do romaneio para busca.
		*Se falso atribui o valor dos transportadores informados no pergunte.
		*/
		If s_GFETRP == "2" .OR. !_lFiltro
			cTrpIni := GWN->GWN_CDTRP
			cTrpFim := GWN->GWN_CDTRP
		Else
			cTrpIni := MV_PAR13
			cTrpFim := MV_PAR14
		EndIf

		cQuery += "AND GWU.GWU_CDTRP >= '" + cTrpIni + "' AND GWU.GWU_CDTRP <= '" + cTrpFim + "' " //Transportador do Trecho

		If _lFiltro
			cQuery += "AND GW1.GW1_CDTPDC >= '" + MV_PAR15 + "' AND GW1.GW1_CDTPDC <= '" + MV_PAR16 + "' " //Tipo de Documento de Carga
			cQuery += "AND GW1.GW1_DTPSAI >= '" + DToS(MV_PAR18) + "' AND GW1.GW1_DTPSAI <= '" + DToS(MV_PAR19) + "' " //Data de Saída
			cQuery += "AND GW1.GW1_DTEMIS >= '" + DToS(MV_PAR20) + "' AND GW1.GW1_DTEMIS <= '" + DToS(MV_PAR21) + "' " //Data de Emissão
			cQuery += "AND GW1.GW1_REGCOM >= '" + MV_PAR22 + "' AND GW1.GW1_REGCOM <= '" + MV_PAR23 + "' " //Região comercial
		EndIf
	Else
		If _lFiltro
			cQuery += "AND GW1.GW1_SERDC >= '" + MV_PAR01 + "' AND GW1.GW1_SERDC <= '" + MV_PAR02 + "' " //Série
			cQuery += "AND GW1.GW1_NRDC >= '" + MV_PAR03 + "' AND GW1.GW1_NRDC <= '" + MV_PAR04 + "' " //Número

			If MV_PAR15 == 2
				cQuery += " AND (GW1.GW1_TPFRET = '1' OR GW1.GW1_TPFRET = '2') " //Doc. Carga CIF ou CIF Redesp.
			ElseIf MV_PAR15 == 3
				cQuery += " AND (GW1.GW1_TPFRET = '3' OR GW1.GW1_TPFRET = '4') " //Doc. Carga FOB ou FOB Redesp.
			EndIf

			cQuery += "AND ((GU3DES.GU3_NRCID >= '" + MV_PAR05 + "' AND GU3DES.GU3_NRCID <= '" + MV_PAR06 + "' AND GW1.GW1_ENTNRC = '') OR "
			cQuery += "(GW1.GW1_ENTNRC >= '" + MV_PAR05 + "' AND GW1.GW1_ENTNRC <= '" + MV_PAR06 + "' AND GW1.GW1_ENTNRC <> ''))" //Cidade

			cQuery += "AND GU7.GU7_CDUF >= '" + MV_PAR07 + "' AND GU7.GU7_CDUF <= '" + MV_PAR08 + "' " //UF
			cQuery += "AND GW1.GW1_CDDEST >= '" + MV_PAR09 + "' AND GW1.GW1_CDDEST <= '" + MV_PAR10 + "' " //Destinatário
		EndIf
		/*
		Verifica se o parâmetro MV_GFETRP -> Transportador de Início e fim = Ao Transportador do Romaneio
		Ou se o Filtro não está sendo aplicado. 
		*Se verdadeiro atribui o valor do transportador do romaneio para busca.
		*Se falso atribui o valor dos transportadores informados no pergunte.
		*/
		If s_GFETRP == "2" .OR. !_lFiltro
			cTrpIni := GWN->GWN_CDTRP
			cTrpFim := GWN->GWN_CDTRP
		Else
			cTrpIni := MV_PAR11
			cTrpFim := MV_PAR12
		EndIf

		cQuery += "AND GWU.GWU_CDTRP >= '" + cTrpIni + "' AND GWU.GWU_CDTRP <= '" + cTrpFim + "' " //Transportador do Trecho

		If _lFiltro
			cQuery += "AND GW1.GW1_CDTPDC >= '" + MV_PAR13 + "' AND GW1.GW1_CDTPDC <= '" + MV_PAR14 + "' " //Tipo de Documento de Carga
			cQuery += "AND GW1.GW1_DTSAI >= '" + DToS(MV_PAR16) + "' AND GW1.GW1_DTSAI <= '" + DToS(MV_PAR17) + "' " //Data de Saída
			cQuery += "AND GW1.GW1_DTEMIS >= '" + DToS(MV_PAR18) + "' AND GW1.GW1_DTEMIS <= '" + DToS(MV_PAR19) + "' " //Data de Emissão
			cQuery += "AND GW1.GW1_REGCOM >= '" + MV_PAR20 + "' AND GW1.GW1_REGCOM <= '" + MV_PAR21 + "' " //Região comercial
		EndIf
	EndIf

	SqlToTrb(cQuery, aMKB, cAliMKB)

	cQuery := "SELECT '  ' OK, GW1.GW1_FILIAL FILIAL, GW1.GW1_SERDC SERIE, GW1.GW1_NRDC NRDC, GW1.GW1_CDTPDC TPDC , "
	cQuery += GFEA66CASE("GW1", "GW1_TPFRET", "TPFRET", "''") + ", "
	cQuery += "GW1.GW1_TPFRET TPFRET, GW1.GW1_EMISDC CDEMIS, GU3EMI.GU3_NMEMIT NMEMIS, "
	cQuery += "GW1.GW1_CDREM CDREM, GU3REM.GU3_NMEMIT NMREM, GW1.GW1_CDDEST CDDEST, GU3DES.GU3_NMEMIT NMDEST, GW1.GW1_NRREG NRREG, "
	cQuery += "		(CASE GW1.GW1_ENTNRC "
	cQuery += "			WHEN '' THEN GU3DES.GU3_NRCID"
	cQuery += "	   		ELSE GW1.GW1_ENTNRC "
	cQuery += " 		END) NRCID, "
	cQuery += "		(CASE GW1.GW1_ENTNRC "
	cQuery += "			WHEN '' THEN GU7DEST.GU7_NMCID"
	cQuery += "	   		ELSE GU7DOC.GU7_NMCID "
	cQuery += " 		END) CIDDES, "
	cQuery += "		(CASE GW1.GW1_ENTNRC "
	cQuery += "			WHEN '' THEN GU7DEST.GU7_CDUF"
	cQuery += "	   		ELSE GU7DOC.GU7_CDUF "
	cQuery += " 		END) UFDEST "	

	//Ponto de entrada Harley Davidson
	If lPEXQRYMKB
		cQuery += ExecBlock("XQRYMKB",.f.,.f.,nil)
	EndIf 	
	//Fim ponto de entrada Harley Davidson

	cQuery += "FROM " + RetSQLName("GW1") + " GW1 "
	cQuery += "INNER JOIN " + RetSQLName("GU3") + " GU3EMI ON GU3EMI.GU3_FILIAL = '" + xFilial("GU3") + "' AND GU3EMI.GU3_CDEMIT = GW1.GW1_EMISDC "
	cQuery += "INNER JOIN " + RetSQLName("GU3") + " GU3REM ON GU3REM.GU3_FILIAL = '" + xFilial("GU3") + "' AND GU3REM.GU3_CDEMIT = GW1.GW1_CDREM "
	cQuery += "INNER JOIN " + RetSQLName("GU3") + " GU3DES ON GU3DES.GU3_FILIAL = '" + xFilial("GU3") + "' AND GU3DES.GU3_CDEMIT = GW1.GW1_CDDEST "
	cQuery += "LEFT JOIN " + RetSQLName("GU7") + " GU7DEST ON GU7DEST.GU7_FILIAL = '" + xFilial("GU7") + "' AND GU7DEST.GU7_NRCID = GU3DES.GU3_NRCID "
	cQuery += "LEFT JOIN " + RetSQLName("GU7") + " GU7DOC ON GU7DOC.GU7_FILIAL = '" + xFilial("GU7") + "' AND GU7DOC.GU7_NRCID = GW1.GW1_ENTNRC "
	If s_MULFIL == "1" .And. GFXCP1212210('GW1_FILROM')
		cQuery += "WHERE GW1.GW1_NRROM = '" + GWN->GWN_NRROM + "' AND GW1.GW1_FILROM = '" + GWN->GWN_FILIAL + "' AND GW1.D_E_L_E_T_ = ' ' AND "
	Else
		cQuery += "WHERE GW1.GW1_NRROM = '" + GWN->GWN_NRROM + "' AND GW1.GW1_FILIAL = '" + GWN->GWN_FILIAL + "' AND GW1.D_E_L_E_T_ = ' ' AND "
	EndIf
	cQuery += "GU3EMI.D_E_L_E_T_ = ' ' AND GU3REM.D_E_L_E_T_ = ' ' AND GU3DES.D_E_L_E_T_ = ' ' AND GU7DEST.D_E_L_E_T_ = ' '"

	SqlToTrb(cQuery, aMKB2, cAliMKB2)   

	aRdpDC:={0,0,0,0,0,0,0}

	dbSelectArea(cAliMKB)
	dbGoTOp()
	oMark:oBrowse:Refresh()

	dbSelectArea(cAliMKB2)
	dbGoTOp()
	oLisDocC:Refresh()		

	GFEA50BFIL()

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA50BOK
Salva o número do Romaneio no Documento de Carga escolhido

@author Luiz Fernando Soares
@since 20/11/09
@version 1.0
/*/
//-------------------------------------------------------------------

Function GFEA50BOK() 

	Local aTmpArea := (cAliMKB)->( GetArea() )
	Local aAreaGW1
	Local lVincRoman := .F.
	
	dbSelectArea(cAliMKB)
	(cAliMKB)->( dbSetOrder(2) )
	(cAliMKB)->( dbSeek(cMarca) )
	While !(cAliMKB)->( Eof() ) .And. (cAliMKB)->OK == cMarca

		dbSelectArea("GW1")
		GW1->( dbSetOrder(1) )
		If GW1->( dbSeek((cAliMKB)->FILIAL + (cAliMKB)->TPDC + (cAliMKB)->CDEMIS + (cAliMKB)->SERIE + (cAliMKB)->NRDC) )

			If GWN->GWN_BLOQPF == "2"
				dbSelectArea("GV5")
				GV5->(dbSetOrder(1))
				GV5->(dbSeek(xFilial("GV5") + GW1->GW1_CDTPDC))
				If ( (GV5->GV5_EMITPF == "2" .Or. Empty(GV5->GV5_EMITPF)))
					MsgInfo("Você está vinculando um Documento de Carga cujo seu tipo bloqueia a emissão de pré-fatura a um Romaneio que não bloqueia a emissão de pré-fatura. Desta forma, o Romaneio será bloqueado para emissão de pré-fatura.")
					RecLock("GWN",.F.)
						GWN->GWN_BLOQPF := "1"
					MsUnlock("GWN")	
				EndIf
		
			Endif

			dbSelectArea("GW4")
			GW4->( dbSetOrder(02) )
			If GW4->( dbSeek(GW1->GW1_FILIAL+GW1->GW1_EMISDC+GW1->GW1_SERDC+GW1->GW1_NRDC+GW1->GW1_CDTPDC) )
				MsgInfo("O Documento de Carga " + Alltrim(GW1->GW1_NRDC) + " já está vinculado a um Documento de Frete.")
				Return .F.
			EndIf

			If !Empty(GWN->GWN_VIAGEM)
				If !GFEA058RVG(GW1->(RecNo()))
					MsgInfo("Não é possível vincular o documento " + Alltrim(GW1->GW1_NRDC) + " que possui frete combinado/simulação com origem erp em romaneio com viagem")
					Return .F.
				EndIf
			EndIf

			// Atualiza o documento de carga com o numero do romaneio
			RecLock("GW1", .F.)
			GW1->GW1_NRROM := GWN->GWN_NRROM
			If GFXCP1212210('GW1_FILROM')
				GW1->GW1_FILROM := GWN->GWN_FILIAL
			EndIf
			GW1->GW1_SIT   := "4" // Embarcado
			lVincRoman := .T.
			MsUnLock("GW1")

			dbSelectArea("GV4")
			GV4->( dbSetOrder(1) )
			If GV4->( dbSeek(xFilial("GV4") + GWN->GWN_CDTPOP) )
				dbSelectArea("GWU")
				GWU->( dbSetOrder(1) )
				If GWU->( dbSeek(xFilial("GWU") + (cAliMKB)->TPDC + (cAliMKB)->CDEMIS + (cAliMKB)->SERIE + (cAliMKB)->NRDC) )
					RecLock('GWU', .F. )
						GWU->GWU_CDTRP  := GWN->GWN_CDTRP
						GWU->GWU_CDTPVC := GWN->GWN_CDTPVC
					GWU->( MsUnLock() )
				EndIf
			EndIf   

			// Início Ponto de Entrada Britania
			If lPEXGFERELD  
				// Envia o romaneio e o documento de carga
				aRotAdic := ExecBlock("XGFERELD",.f.,.f.,{GWN->GWN_NRROM,(cAliMKB)->TPDC,(cAliMKB)->CDEMIS,(cAliMKB)->SERIE,(cAliMKB)->NRDC})
			EndIf
			// Fim Ponto de Entrada Britania		 	    				

			_lChgDocs := .T. // Romaneio teve alteração nos seus documentos de carga
		EndIf
		dbSelectArea(cAliMKB)
		(cAliMKB)->( dbSkip() )
	EndDo
	
	If lVincRoman
		// Houve vinculo de romaneio com documento
		// Verifica se o cálculo do documento pode ser liberado, se possuir cálculo simulado
		aAreaGW1:= GW1->(GetArea())
		GFEA050BLI(xFilial("GW1")+GWN->GWN_NRROM)
		RestArea(aAreaGW1)

		//verifica se deve liberá-lo e libera-os
		GFE50LbRom()
	EndIf
	RestArea(aTmpArea)

	GFE50BMKB()
	If AllTrim((cAliMKB)->( IndexKey() )) == "OK"
		(cAliMKB)->( dbSetOrder(1) )
	EndIf 

Return .T.  

//-------------------------------------------------------------------
/*/{Protheus.doc} GFE50DELDC
Elimina do Romaneio o Documento de Carga escolhido

@author Luiz Fernando Soares
@since 20/11/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GFE50DELDC()

	Local aCalcs     := {}	
	Local nX         := 0
	Local lRetiraDoc := .T. 
	Local lApagaCalc := .T.
	Local cTpCalc
	Local cTxtDoc	:= ''

	dbSelectArea("GW1")
	dbSetOrder(1)
	If dbSeek((cAliMKB2)->FILIAL + (cAliMKB2)->TPDC +(cAliMKB2)->CDEMIS +(cAliMKB2)->SERIE +(cAliMKB2)->NRDC)

		//Verifica se o Documento de carga está entregue, em caso positivo não será possível desvinculá-lo
		If GW1->GW1_SIT == "5"
			Help( ,,'HELP',,"Documento de Carga já foi entregue. Retirada não permitida.", 1, 0,) 
			lRetiraDoc := .F.	
		EndIf

		// Verificar se o documento de carga está relacionado a cálculo de frete
		dbSelectArea("GWH")
		dbSetOrder(02)
		dbSeek(xFilial("GWH")+GW1->GW1_CDTPDC+GW1->GW1_EMISDC+GW1->GW1_SERDC+GW1->GW1_NRDC)
		While !Eof() .AND. GWH->GWH_FILIAL == xFilial("GWH");
					 .AND. GWH->GWH_EMISDC == GW1->GW1_EMISDC;
					 .AND. GWH->GWH_SERDC  == GW1->GW1_SERDC;
					 .AND. GWH->GWH_NRDC   == GW1->GW1_NRDC
			
			dbSelectArea("GWF")
			dbSetOrder(01)
			If dbSeek(xFilial("GWF")+GWH->GWH_NRCALC)
				// Revisar quando a rotina estiver apta para gerar outros tipos de calculo (reentrega, devolucao)
				If aScan(aCalcs,{|cNrCalc| cNrCalc == GWH->GWH_NRCALC}) == 0 .AND. (GWF->GWF_TPCALC $ "168") // 1-Normal, 6-Redespacho, 8-Provisao
					aAdd(aCalcs,GWH->GWH_NRCALC)
				EndIf
			EndIf   
			dbSelectArea("GWH")
			dbSkip()
		EndDo	

		// Verifica se os cálculos encontrados podem ser eliminados
		cTxtDoc := ''
		If !Empty(aCalcs)
			For nX := 1 to len(aCalcs)
				lApagaCalc := .T.

				If !GFEVldLotProvisao(aCalcs[nX])
					cTxtDoc += ' (Lotes de Provisão) '
					lApagaCalc := .F.
				EndIf

				// Valida o cálculo de frete existente em relacao aos documentos de frete
				If !GFEVldDocFrete(aCalcs[nX])
					cTxtDoc += ' (Documento de Frete) '
					lApagaCalc := .F.
				EndIf

				// Valida o cálculo de frete existente em relacao a pre-fatura
				If !GFEVldPreFat(aCalcs[nX])
					cTxtDoc += ' (Pré-Fatura) '
					lApagaCalc := .F.
				EndIf

				// Valida o cálculo de frete em relacao a contrato com terceiros
				If !GFEVldContr(aCalcs[nX])
					cTxtDoc += ' (Contrato com Autônomo) '
					lApagaCalc := .F.
				EndIf

				// Se não for possível eliminar o cálculo, não permitir a retirada do mesmo
				If !lApagaCalc
					Help( ,,'HELP',,"Cálculo do documento de carga possui vínculo com:" + cTxtDoc + "." + CRLF + CRLF + STR0031, 1, 0,) //"Retirada não permitida."
					lRetiraDoc := .F.
					Exit
				Else
					If !GFEVldMovCtb(aCalcs[nX]) // Cálculo possui movimentos contábeis atualizados no ERP
						cTpCalc := Posicione("GWF",1,xFilial("GWF")+aCalcs[nX],"GWF_TPCALC")
						dbSelectArea("GWF")
						dbSetOrder(01)
						If dbSeek(xFilial("GWF")+aCalcs[nX])
							RecLock("GWF",.F.)
							If cTpCalc $ "16"	// 1-Normal, 6-Redespacho
								GWF->GWF_TPCALC := "8"	// Transforma o cálculo em Provisão              
							EndIf
							GWF->GWF_NRROM := ""   // Desvincula o cálculo do romaneio
							MsUnLock("GWF")
						EndIf	
					Else
						// Reativa as provisões relacionadas aos documentos de carga do cálculo corrente
						GFEDelEstorno(aCalcs[nX])
						// Apaga o calculo de frete e seus relacionamentos, incluindo movimentos contábeis
						GFEDelCalc(aCalcs[nX])
					EndIf
				EndIf
			Next nX
		EndIf

		If lRetiraDoc		
			// Desvincula o documento de carga do romaneio
			RecLock("GW1",.F.)
			GW1->GW1_NRROM := "" 
			
			If GFXCP1212210('GW1_FILROM')
				GW1->GW1_FILROM := ""
			EndIf
			
			If GW1->GW1_SIT == "4"
				GW1->GW1_SIT := "3" // Liberado
			EndIf
			
			MsUnLock("GW1")
			_lChgDocs := .T. // Romaneio teve alteração em seus documentos de carga
		EndIf
	EndIf
	GFE50BMKB()
Return

/*-------------------------------------------------------------------
Elimina o estorno dos cálculos de provisão dos documentos de carga
relacionados ao calculo normal recebido
-------------------------------------------------------------------*/
Static Function GFEDelEstorno(cNrCalcNormal)

	Local aAreaGWF := GWF->(getArea())
	Local aAreaGWH := GWH->(getArea())
	Local aAreaGW1 := GW1->(getArea())    

	ChkFile("GWH",,"GWHBF")	// Cria um "buffer" da tabela GWH, evitando desposicionamento do registro na área original

	dbSelectArea("GWH")
	dbSetOrder(1)
	If dbSeek(xFilial("GWH")+cNrCalcNormal)
		// Para cada documento de carga do calculo de frete normal (ou redespacho)...
		While !Eof() .AND. GWH->GWH_FILIAL == xFilial("GWH") .AND. GWH->GWH_NRCALC == cNrCalcNormal
			dbSelectArea("GW1")
			dbSetOrder(1)
			If dbSeek(xFilial("GW1")+GWH->GWH_CDTPDC+GWH->GWH_EMISDC+GWH->GWH_SERDC+GWH->GWH_NRDC)
				dbSelectArea("GWHBF")
				dbSetOrder(2)
				If dbSeek(xFilial("GWH")+GW1->GW1_CDTPDC+GW1->GW1_EMISDC+GW1->GW1_SERDC+GW1->GW1_NRDC)			
					// Localiza os demais cálculos, diferentes do cálculo normal
					While !Eof() .AND. GWHBF->GWH_FILIAL == xFilial("GWH");
								 .AND. GWHBF->GWH_EMISDC == GW1->GW1_EMISDC;
								 .AND. GWHBF->GWH_SERDC  == GW1->GW1_SERDC;
								 .AND. GWHBF->GWH_NRDC   == GW1->GW1_NRDC;
								 .AND. GWHBF->GWH_NRCALC != cNrCalcNormal				             
						dbSelectArea("GWF")
						dbSetOrder(1)
						// Se o cálculo de frete for do tipo provisão
						If dbSeek(xFilial("GWF")+GWHBF->GWH_NRCALC) .AND. GWF->GWF_TPCALC == "8"	// Provisao					
							// Eliminar os movimentos contábeis de estorno, se possível, fazendo a provisão voltar à ativa
							dbSelectArea("GWA")
							dbSetOrder(1)
							If dbSeek(xFilial("GWA")+"1"+PadR("",5)+PadR("",TamSx3("GWA_CDEMIT")[1])+PadR("",5)+GWF->GWF_NRCALC)
								While !Eof() .AND. GWA->GWA_FILIAL == xFilial("GWA");
											 .AND. GWA->GWA_TPDOC  == "1";
											 .AND. GWA->GWA_CDESP  == PadR("",5);
											 .AND. GWA->GWA_CDEMIT == PadR("", TamSx3("GWA_CDEMIT")[1]);
											 .AND. GWA->GWA_SERIE  == PadR("",5);
											 .AND. AllTrim(GWA->GWA_NRDOC) == AllTrim(GWF->GWF_NRCALC)     										 
									If AllTrim(GWA->GWA_CDTRAN) >= "305" .AND. AllTrim(GWA->GWA_CDTRAN) <= "309"; // Estornos de provisao
																		 .AND. GWA->GWA_SITCTB $ "13"	// Movimento contábil não atualizado no ERP
										RecLock("GWA",.F.)
										dbDelete()
										MsUnLock("GWA")									
									EndIf   								
									GWA->(dbSkip())
								EndDo
							EndIf
						EndIf
						GWHBF->(dbSkip())
					EndDo
				EndIF				
			EndIf		
			GWH->(dbSkip())
		EndDo
	EndIf		
	
	GWHBF->(dbCloseArea())
	RestArea(aAreaGWF)
	RestArea(aAreaGWH)
	RestArea(aAreaGW1)

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} GFE050VIS
Permite a visualização do registro do browse

@author Luiz Fernando Soares
@since 30/11/09
@version 1.0
/*/
//-------------------------------------------------------------------
	
Function GFE050VIS()
	Local lRet := .T.
	
	dbSelectArea("GW1")
	dbSetOrder(1)
	If dbSeek((cAliMKB2)->FILIAL + (cAliMKB2)->TPDC +(cAliMKB2)->CDEMIS +(cAliMKB2)->SERIE +(cAliMKB2)->NRDC)
		FWExecView("",'GFEA044',1,,{||.T.})
	EndIf

Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} GFE050TRE
Permite a visualização dos trechos dos documentos de carga

@author Luiz Fernando Soares
@since 30/11/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFE050TRE()
	Local lRet := .T.
	
	dbSelectArea("GW1")
	dbSetOrder(1)
	If dbSeek(xFilial("GW1") + (cAliMKB2)->TPDC +(cAliMKB2)->CDEMIS +(cAliMKB2)->SERIE +(cAliMKB2)->NRDC)
		FWExecView("",'GFEA044',4,,{||.T.})
	EndIf

Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} GFE50BFIL
Permite o filtro do browse superior

@author Luiz Fernando Soares
@since 30/11/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFE50BFIL()

	If s_MULFIL == "1"
		If Pergunte("GFEA050FIL", .T.)
			_lFiltro := .T.
			If _lFiltro
				GFE50BMKB() //GFE050AMB()
			EndIf
		Else
			_lFiltro := .F.
		EndIf
	Else
		If Pergunte("GFEA050", .T.)
			_lFiltro := .T.
			GFE50BMKB()
		Else
			_lFiltro := .F.
		EndIf
	EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA50BCL
Rotina para realizar a simulacao do calculo de frete do romaneio

@author Felipe N. Welter
@since 08/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFEA50BCL(lReal) 
	Local nQtdeIt    := 0, nVlDC := 0, nVol := 0, nPeso := 0, nVlFrete := 0, nPercDC := 0
	Local aAgrFrt    := {}
	Local aDocCarg   := {}
	Local aTrchDoc 	 := {}
	Local aItDoc     := {}
	Local lGW8VALLIQ := GFXCP12118("GW8_VALLIQ")
	Local lXFBGWUDC  := FindFunction("XFBGWUDC")
	Local aRetGXT

	Private cTRBCCF, cTRBITE, cTRBTRE, cTRBTCF, cTRBUNC, cTRBGRU, cTRBDOC, cTRBAGRU, cTRBSIM    //variaveis utilizadas na rotina de calculo de frete
	Private aTRBCCF3 := {} // Indice 3
	Private lTabTemp := .F.

	Private idpCCF   := 1 // posição do array cTRBCCF
	Private idxCCF   := 1 // Indice  da array cTRBCCF
	Private _aCmpCCF := {	"NRCALC",; // 1
	"CDCLFR",; // 2
	"CDTPOP",; // 3
	"SEQ"   ,; // 4
	"CDCOMP",; // 5
	"CATVAL",; // 6
	"QTDE"  ,; // 7
	"VALOR" ,; // 8
	"TOTFRE",; // 9
	"BASIMP",; // 10
	"BAPICO",; // 11
	"FREMIN",; // 12
	"IDMIN" ,; // 13
	"VLFRMI",; // 14
	"DELETE"}  // 15


	//ARRAY de Agrupadores de Frete (Romaneio)
	aAdd(aAgrFrt,{GWN->GWN_NRROM,; 	//Numero do Agrupador
	GWN->GWN_CDTRP ,;  				//Transportador
	GWN->GWN_CDTPVC,; 				//Tipo de Veiculo
	GWN->GWN_CDCLFR,; 				//Classificacao de Frete
	GWN->GWN_CDTPOP,; 				//Tipo de Operacao
	GWN->GWN_DISTAN,; 				//Distancia Percorrida
	GWN->GWN_NRCIDD,; 				//Cidade Destino
	GWN->GWN_CEPD  ,;   			//CEP Destino
	"0"})   		  				//ERRO

	dbSelectArea(cAliMKB2)
	dbGoTop()

	GW1->(dbSetOrder(09))
	GW1->(dbSeek(xFilial("GW1")+GWN->GWN_NRROM,.T.))
	If lXFBGWUDC			
		aTrchDoc := XFBGWUDC(GWN->GWN_NRROM)
	EndIf
	
	While (cAliMKB2)->(!Eof()) .And. GW1->GW1_NRROM == GWN->GWN_NRROM
		GW1->(dbSetOrder(01))
		If GW1->(!dbSeek((cAliMKB2)->FILIAL+(cAliMKB2)->TPDC+(cAliMKB2)->CDEMIS+(cAliMKB2)->SERIE+(cAliMKB2)->NRDC))
			Loop
		EndIf

		//Totaliza unitizadores do documento selecionado
		nQtde := 0
		GWB->(dbSetOrder(02))
		GWB->(dbSeek(xFilial("GWB")+GW1->GW1_CDTPDC+GW1->GW1_EMISDC+GW1->GW1_SERDC+GW1->GW1_NRDC,.T.))
		While GWB->(!Eof()) .And. GWB->GWB_FILIAL == xFilial("GWB"); 
							.And. GWB->GWB_CDTPDC == GW1->GW1_CDTPDC; 
							.And. GWB->GWB_EMISDC == GW1->GW1_EMISDC; 
							.And. GW1->GW1_SERDC  == GW1->GW1_SERDC; 
							.And. GWB->GWB_NRDC   == GW1->GW1_NRDC
			nQtde += GWB->GWB_QTDE
			GWB->(dbSkip())
		EndDo

		//ARRAY de Documentos de Carga
		aAdd(aDocCarg,{GW1->GW1_EMISDC,; //Emitente do Documento
		GW1->GW1_SERDC,;  //Serie do Documento
		GW1->GW1_NRDC,;   //Numero do Documento
		GW1->GW1_CDTPDC,; //Tipo do Documento
		GW1->GW1_CDREM,;  //Remetente do Documento
		GW1->GW1_CDDEST,; //Destinatario do Documento
		GW1->GW1_ENTEND,; //Endereco de Entrega
		GW1->GW1_ENTBAI,; //Bairro de entrega
		GW1->GW1_ENTNRC,; //Cidade de Entrega
		GW1->GW1_ENTCEP,; //CEP de Entrega
		GW1->GW1_NRREG,;  //Região de destino
		GW1->GW1_TPFRET,; //Tipo de Frete  
		GW1->GW1_ICMSDC,; //ICMS?
		GW1->GW1_USO,;    //Finalidade da mercadoria
		GW1->GW1_CARREG,; //Número do carregamento
		GW1->GW1_NRROM,;    //Numero do Agrupador
		nQtde}) //Quantidade de Unitizadores

		If !lXFBGWUDC			
			dbSelectArea("GWU")
			GWU->(dbSetOrder(01))
			GWU->(dbSeek(xFilial("GWU")+GW1->GW1_CDTPDC+GW1->GW1_EMISDC+GW1->GW1_SERDC+GW1->GW1_NRDC,.T.))
			While GWU->(!Eof()) .And. GWU->GWU_FILIAL == xFilial("GWU"); 
								.And. GWU->GWU_CDTPDC == GW1->GW1_CDTPDC; 
								.And. GWU->GWU_EMISDC == GW1->GW1_EMISDC;
								.And. GWU->GWU_SERDC  == GW1->GW1_SERDC; 
								.And. GWU->GWU_NRDC   == GW1->GW1_NRDC
					
					//ARRAY de Trechos do Documento
					aAdd(aTrchDoc,{GWU->GWU_EMISDC,; //Emitente do Documento
					GWU->GWU_SERDC,;  //Serie do Documento
					GWU->GWU_NRDC,;   //Numero do Documento
					GWU->GWU_CDTPDC,; //Tipo do Documento
					GWU->GWU_SEQ,;    //Sequencia do Trecho
					GWU->GWU_CDTRP,;  //Transportador do Trecho 
					GWU->GWU_NRCIDD,;  //Cidade Destino 
					GWU->GWU_CDTPVC,; //Tipo de Veiculo do Trecho
					GWU->GWU_PAGAR}) 
				GWU->(dbSkip())   				
			EndDo
		EndIf

		GW8->(dbSetOrder(01))
		GW8->(dbSeek(xFilial("GW8")+GW1->GW1_CDTPDC+GW1->GW1_EMISDC+GW1->GW1_SERDC+GW1->GW1_NRDC,.T.))
		While GW8->(!Eof()) .And. GW1->GW1_FILIAL == xFilial("GW8"); 
							.And. GW8->GW8_EMISDC == GW1->GW1_EMISDC; 
							.And. GW8->GW8_CDTPDC == GW1->GW1_CDTPDC; 
							.And. GW8->GW8_SERDC  == GW1->GW1_SERDC; 
							.And. GW8->GW8_NRDC   == GW1->GW1_NRDC

			//ARRAY de Itens do Documento
			aAdd(aItDoc,{GW8->GW8_EMISDC,; //Emitente do Documento
			GW8->GW8_SERDC,;  //Serie do Documento
			GW8->GW8_NRDC,;   //Numero do Documento
			GW8->GW8_CDTPDC,; //Tipo do Documento
			GW8->GW8_ITEM,;   //Item
			GW8->GW8_CDCLFR,; //Classificacao de Frete
			GW8->GW8_TPITEM,; //Tipo de Item
			GW8->GW8_QTDE,;   //Quantidade do Item
			GW8->GW8_PESOR,;  //Peso do Item
			GW8->GW8_PESOC,;  //Peso Cubado
			GW8->GW8_QTDALT,; //Quantidade/Peso Alternativo
			GW8->GW8_VALOR,;  //Valor do Item
			GW8->GW8_VOLUME,; //Volume ocupado (m3)
			GW8->GW8_TRIBP,;  // Frete tributado PIS
			IIF(lGW8VALLIQ,GW8->GW8_VALLIQ,0),;// Valor Liquido
			GW8->GW8_FILIAL}) // Filial

			nQtdeIt := GW8->GW8_QTDE + nQtdeIt
			nVlDC := GW8->GW8_VALOR + nVlDC   
			nVol  := GW8->GW8_VOLUME + nVol 
			nPeso := IF( GW8->GW8_PESOR > GW8->GW8_PESOC ,GW8->GW8_PESOR,GW8->GW8_PESOC) + nPeso 

			GW8->(dbSkip())    
		EndDo

		(cAliMKB2)->(dbSkip())
	EndDo

	aRetGXT := GFEA50GXT()
	aRet    := GFECLCFRT(aAgrFrt,aDocCarg,aTrchDoc,aItDoc,IIF(aRetGXT[1]== .T.,aRetGXT[2],Nil),.F.,1,.F.,.F.,1)    

	If !Empty(aRet)  
		If aRet[1]
			lTabTemp	:= aRet[07]
			aTRBCCF3	:= aRet[10]
			/*
			Quantidade: Soma da quantidade dos itens dos documentos de cargas; 
			Valor Doctos Carga: Soma dos valores das mercadorias dos itens dos documentos de cargas; 
			Volumes: Soma dos volumes dos itens dos documentos de cargas; 
			Peso: Soma dos pesos real/cubado dos itens dos documentos de cargas;
			Valor do Frete: Total do frete calculado, resultado da simulação do frete. 
			% Doctos Carga: Percentual do frete com relação ao valor total do documento de carga  (Valor do Frete/Valor Doctos Carga)
			*/

			//Calculando to total do frete simulado
			GFEXFB_BORDER(lTabTemp,cTRBCCF,01,9) //dbSetOrder(1)
			GFEXFB_2TOP(lTabTemp, cTRBCCF, @aTRBCCF3, 9) //dbGoTop()
			While !GFEXFB_3EOF(lTabTemp, cTRBCCF, @aTRBCCF3, 9) 
				nVlFrete := nVlFrete + GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF3, 9,"VALOR")
				GFEXFB_8SKIP(lTabTemp, cTRBCCF, 9) //dbSkip()
			EndDo	 
			nPercDC := (nVlFrete/nVlDC) * 100

			oSize := FWDefSize():New(.T.)
			oSize:AddObject( "ENCHOICE", 100, 60, .T., .T. ) // Adiciona enchoice
			oSize:SetWindowSize({80,50,320,500})
			oSize:lLateral     := .F.  // Calculo vertical	
			oSize:Process() //executa os calculos

			aPos := {oSize:GetDimension("ENCHOICE","LININI"),; 
			oSize:GetDimension("ENCHOICE","COLINI"),;
			oSize:GetDimension("ENCHOICE","XSIZE"),;
			oSize:GetDimension("ENCHOICE","YSIZE")}


			DEFINE MSDIALOG oDlg TITLE STR0040 ;
			FROM oSize:aWindSize[1],oSize:aWindSize[2] ;
			TO oSize:aWindSize[3],oSize:aWindSize[4] ;
			OF oMainWnd COLORS 0, 16777215 PIXEL	
			oDlg:lEscClose := .F.

			@ aPos[1]+27,aPos[2]+10  Say STR0041 Of oDlg COLOR CLR_BLACK Pixel //"Quantidade: "
			@ aPos[1]+25,aPos[2]+45  MSGET nQtdeIt Picture "@E 999,999,999.99" Of oDlg When .F. Pixel

			@ aPos[1]+47,aPos[2]+10  Say STR0037 Of oDlg COLOR CLR_BLACK Pixel //"Volume: "
			@ aPos[1]+45,aPos[2]+45  MSGET nVol Picture "@E 999,999,999.99" Of oDlg When .F. Pixel

			@ aPos[1]+67,aPos[2]+10  Say STR0035 Of oDlg COLOR CLR_BLACK Pixel //"Peso: "
			@ aPos[1]+65,aPos[2]+45  MSGET nPeso Picture "@E 999,999,999.99" Of oDlg When .F. Pixel

			@ aPos[1]+27,aPos[2]+120  Say STR0042 Of oDlg COLOR CLR_BLACK Pixel //"Valor DC: "
			@ aPos[1]+25,aPos[2]+155  MSGET nVlDC Picture "@E 999,999,999.99" Of oDlg When .F. Pixel

			@ aPos[1]+47,aPos[2]+120  Say STR0043 Of oDlg COLOR CLR_BLACK Pixel //"Valor Frete: "
			@ aPos[1]+45,aPos[2]+155  MSGET nVlFrete Picture "@E 999,999,999.99" Of oDlg When .F. Pixel

			@ aPos[1]+67,aPos[2]+120  Say STR0044 Of oDlg COLOR CLR_BLACK Pixel //"% Doc Carga: "
			@ aPos[1]+65,aPos[2]+155  MSGET nPercDC Picture "@E 999,999,999.99" Of oDlg When .F. Pixel

			ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(ODlg,{||ODlg:End()},{||ODlg:End()},,aNewButton) CENTERED 
		EndIf   

		//Deletar as tabelas usadas na rotina do calculo de frete
		If lTabTemp
			GFEDelTab(cTRBCCF)
			GFEDelTab(cTRBITE) 
			GFEDelTab(cTRBTRE) 
			GFEDelTab(cTRBTCF) 
			GFEDelTab(cTRBUNC) 
			GFEDelTab(cTRBGRU) 
			GFEDelTab(cTRBDOC) 
			GFEDelTab(cTRBAGRU) 
		Else
			IIF(aTRBCCF3==NIL,,aSize(aTRBCCF3,0))
			aTRBCCF3:= Nil
		EndIf 
		
		If !Empty(cTRBSIM) 
			GFEDelTab(cTRBSIM) 
		EndIf  

		dbSelectArea(cAliMKB2)
		(cAliMKB2)->( dbGoTop() )

	EndIf
Return
//-------------------------------------------------------------------
/*
{Protheus.doc} GFEA50BFIL
Função para preencher os totais nos campos do rodapé.

@sample
GFEA50BFIL()

@author Octávio Augusto Felippe de Macedo
@since 31/03/2011
@version 1.0
*/     
//-------------------------------------------------------------------
Static Function GFEA50BFIL()

	aRdpSel := {0,0,0,0,0,0,0}
	dbSelectArea(cAliMKB2)
	While !(cAliMKB2)->( Eof() )

		aRdpSel[1]++

		dbSelectArea("GW1")
		GW1->( dbSetOrder(1) )
		If GW1->( dbSeek((cAliMKB2)->FILIAL + (cAliMKB2)->TPDC + (cAliMKB2)->CDEMIS + (cAliMKB2)->SERIE + (cAliMKB2)->NRDC) )
			aRdpSel[6] += GW1_QTVOL

			dbSelectArea("GW8")
			GW8->( dbSetOrder(1) )
			GW8->( dbSeek(xFilial("GW8") + GW1->GW1_CDTPDC + GW1->GW1_EMISDC + GW1->GW1_SERDC + GW1->GW1_NRDC) )
			While !GW8->( Eof() ) .And. GW8->GW8_CDTPDC == GW1->GW1_CDTPDC; 
								  .And. GW8->GW8_EMISDC == GW1->GW1_EMISDC; 
								  .And. GW8->GW8_SERDC  == GW1->GW1_SERDC;
								  .And. GW8->GW8_NRDC   == GW1->GW1_NRDC

				aRdpSel[2] += GW8->GW8_PESOR
				aRdpSel[3] += GW8->GW8_PESOC
				aRdpSel[4] += GW8->GW8_VOLUME
				aRdpSel[5] += GW8->GW8_VALOR
				aRdpSel[7] += GW8->GW8_QTDALT

				dbSelectArea("GW8")
				GW8->( dbSkip() )
			EndDo
		EndIf
		dbSelectArea(cAliMKB2)
		(cAliMKB2)->( dbSkip() )
	EndDo

	dbSelectArea(cAliMKB2)
	(cAliMKB2)->( dbGoTop() )
Return

//-------------------------------------------------------------------
/*
{Protheus.doc} GFEA50BCHK
Função para marcar/desmarcar todos os documentos de carga

@sample
GFEA50BCHK(nOp)

@author Octávio Augusto Felippe de Macedo
@since 01/04/2011
@version 1.0
*/ 
//-------------------------------------------------------------------

Static Function GFEA50BCHK(nOp)

	dbSelectArea(cAliMKB)
	(cAliMKB)->( dbGoTop() )
	While !(cAliMKB)->( Eof() )

		If IIf(nOp==1,!IsMark("OK",cMarca),IsMark("OK",cMarca))
			RecLock(cAliMKB,.F.)
			(cAliMKB)->OK := IIf(nOp==1, cMarca, " ")
			MsUnlock(cAliMKB)
			GFEA50BRDP()
		EndIf

		dbSelectArea(cAliMKB)
		(cAliMKB)->( dbSkip() )
	EndDo

	DbSelectArea(cAliMKB)
	(cAliMKB)->( DbGoTop() )

	oMark:oBrowse:Refresh()
Return
//-------------------------------------------------------------------
/*
{Protheus.doc} GFEA50BCLK
Função chamada no evento de duplo click para marcar/desmarcar e atualizar o rodapé

@sample
GFEA50BCLK()

@author Octávio Augusto Felippe de Macedo
@since 01/04/2011
@version 1.0
*/
//-------------------------------------------------------------------
Static Function GFEA50BCLK()
	Local nCont := 1

	If !(cAliMKB)->( Eof() )

		RecLock(cAliMKB, .F.)
		(cAliMKB)->OK := If(IsMark("OK",cMarca), " ", cMarca)
		MsUnlock(cAliMKB)

		GFEA50BRDP()
		oMark:oBrowse:Refresh()

		While nCont <= 7
			&("oGetRdp"+AllTrim(Str(nCont))+":Refresh()")
			nCont++
		EndDo
	EndIf

Return

//-------------------------------------------------------------------
/*
{Protheus.doc} GFEA50BRDP
Função que atualiza o valor do rodapé

@sample
GFEA50BRDP()

@author Octávio Augusto Felippe de Macedo
@since 01/04/2011
@version 1.0
*/
//-------------------------------------------------------------------
Static Function GFEA50BRDP()

	If IsMark("OK",cMarca)

		aRdpDC[1]++

		dbSelectArea("GW1")
		GW1->( dbSetOrder(1) )
		If GW1->( dbSeek((cAliMKB)->FILIAL + (cAliMKB)->TPDC + (cAliMKB)->CDEMIS + (cAliMKB)->SERIE + (cAliMKB)->NRDC) )
			aRdpDC[6] += GW1_QTVOL

			dbSelectArea("GW8")
			GW8->( dbSetOrder(1) )
			GW8->( dbSeek(GW1->GW1_FILIAL + GW1->GW1_CDTPDC + GW1->GW1_EMISDC + GW1->GW1_SERDC + GW1->GW1_NRDC) )
			While !GW8->( Eof() ) .And. GW8->GW8_CDTPDC == GW1->GW1_CDTPDC; 
								  .And. GW8->GW8_EMISDC == GW1->GW1_EMISDC; 
								  .And. GW8->GW8_SERDC  == GW1->GW1_SERDC;
								  .And. GW8->GW8_NRDC   == GW1->GW1_NRDC

				aRdpDC[2] += GW8->GW8_PESOR
				aRdpDC[3] += GW8->GW8_PESOC
				aRdpDC[4] += GW8->GW8_VOLUME
				aRdpDC[5] += GW8->GW8_VALOR
				aRdpDC[7] += GW8->GW8_QTDALT

				dbSelectArea("GW8")
				GW8->( dbSkip() )
			EndDo
		EndIf
	Else
		aRdpDC[1]--
		dbSelectArea("GW1")
		GW1->( dbSetOrder(1) )
		If GW1->( dbSeek((cAliMKB)->FILIAL + (cAliMKB)->TPDC + (cAliMKB)->CDEMIS + (cAliMKB)->SERIE + (cAliMKB)->NRDC) )
			aRdpDC[6] -= GW1_QTVOL

			dbSelectArea("GW8")
			GW8->( dbSetOrder(1) )
			GW8->( dbSeek(GW1->GW1_FILIAL + GW1->GW1_CDTPDC + GW1->GW1_EMISDC + GW1->GW1_SERDC + GW1->GW1_NRDC) )
			While !GW8->( Eof() ) 	.And. GW8->GW8_CDTPDC == GW1->GW1_CDTPDC; 
									.And. GW8->GW8_EMISDC == GW1->GW1_EMISDC; 
									.And. GW8->GW8_SERDC  == GW1->GW1_SERDC;
									.And. GW8->GW8_NRDC   == GW1->GW1_NRDC

				aRdpDC[2] -= GW8->GW8_PESOR
				aRdpDC[3] -= GW8->GW8_PESOC
				aRdpDC[4] -= GW8->GW8_VOLUME
				aRdpDC[5] -= GW8->GW8_VALOR
				aRdpDC[7] -= GW8->GW8_QTDALT

				dbSelectArea("GW8")
				GW8->( dbSkip() )
			EndDo
		EndIf
	EndIf
Return
//-------------------------------------------------------------------

//Atualiza a situação do cálculo/romaneio para um cálculo ORIGEM 3
Function GFEA050BLI(cNrRoman)
	Local lLibCalc	:= .F.
	Local lTodosRoma:= .T.
	Local aAreaGWN	:= GWN->(GetArea())
	Local aAreaGWH
	Local aAreaGW1	:= GW1->(GetArea())
	Default cNrRoman:= ""

	dbSelectArea("GWH")
	GWH->(dbSetOrder(2))
	dbSelectArea("GWF")
	GWF->(dbSetOrder(1))
	dbSelectArea("GWN")
	GWN->(dbSetOrder(1))

	If !Empty(cNrRoman) 
		dbSelectArea("GW1")
		GW1->(dbSetOrder(9))
		GW1->(dbSeek(cNrRoman))
	EndIf

	If Empty(cNrRoman)
		GWH->(dbSeek(GW1->GW1_FILIAL + GW1->GW1_CDTPDC + GW1->GW1_EMISDC + GW1->GW1_SERDC + GW1->GW1_NRDC))
		// busca pelos cálculos do documento
		While !GWH->(Eof()) .And. GW1->GW1_FILIAL == GWH->GWH_FILIAL;
							.And. GW1->GW1_CDTPDC == GWH->GWH_CDTPDC;
							.And. GW1->GW1_EMISDC == GWH->GWH_EMISDC;
							.And. GW1->GW1_SERDC  == GWH->GWH_SERDC; 
							.And. GW1->GW1_NRDC   == GWH->GWH_NRDC; 
							.And. lTodosRoma
			
			aAreaGWH := GWH->(GetArea())
			If GWF->(dbSeek(GWH->GWH_FILIAL + GWH->GWH_NRCALC))	.And. GWF->GWF_ORIGEM == '4'
				lLibCalc := .T.
				If Empty(GWF->GWF_NRROM)
					dbSelectArea("GW1")
					GW1->(dbSetOrder(1))
					dbSelectArea("GWH")
					GWH->(dbSetOrder(1))
					GWH->(dbSeek(GWF->GWF_FILIAL + GWF->GWF_NRCALC))
					While !GWH->(Eof()) .And. GWH->GWH_FILIAL + GWH->GWH_NRCALC == GWF->GWF_FILIAL + GWF->GWF_NRCALC
							If GW1->(dbSeek(GWH->GWH_FILIAL+GWH->GWH_CDTPDC+GWH->GWH_EMISDC+GWH->GWH_SERDC+GWH->GWH_NRDC)) .And. GW1->GW1_SIT == '2'
								lTodosRoma := .F.
								Exit
							EndIf

							If Empty(GW1->GW1_NRROM) .Or. !GWN->(dbseek(GW1->GW1_FILIAL + GW1->GW1_NRROM))
								lTodosRoma := .F.
							Else
								cNrRoman := GW1->GW1_FILIAL + GW1->GW1_NRROM
							EndIf
						GWH->(dbSkip())
					EndDo
					RestArea(aAreaGWH)
					RestArea(aAreaGW1)
				EndIf
	
				If Empty(GWF->GWF_NRROM) .And. lTodosRoma .And. !Empty(cNrRoman)
					Reclock("GWF",.F.)
						GWF->GWF_NRROM := SubStr(cNrRoman,FWSizeFilial()+1)
					msUnlock("GWF")
				EndIf
			Else
				lLibCalc := .F.
				RestArea(aAreaGWH)
				RestArea(aAreaGW1)
				Exit
			EndIf
			GWH->(dbSkip())
		EndDo
		If lTodosRoma .And. lLibCalc .And. GWN->(dbSeek(GW1->GW1_FILIAL + GW1->GW1_NRROM))
			RecLock('GWN', .F. )
				GWN->GWN_CALC   := "1"
				GWN->GWN_MTCALC := ""
				GWN->GWN_DTCALC := DDATABASE
				GWN->GWN_HRCALC := SubStr(TIME(), 1, 5)
			MsUnlock("GWN")
		EndIf
	Else //Busca pelos cálculos dos documentos do romaneio
		While !GW1->(Eof()) .And. cNrRoman == GW1->GW1_FILIAL + GW1->GW1_NRROM

			If GW1->GW1_SIT == '2'
				lTodosRoma := .F.
				Exit
			EndIf

			GWH->(dbSeek(GW1->GW1_FILIAL + GW1->GW1_CDTPDC + GW1->GW1_EMISDC + GW1->GW1_SERDC + GW1->GW1_NRDC))
			While !GWH->(Eof()) .And. GW1->GW1_FILIAL == GWH->GWH_FILIAL;
								.And. GW1->GW1_CDTPDC == GWH->GWH_CDTPDC;
								.And. GW1->GW1_EMISDC == GWH->GWH_EMISDC;
								.And. GW1->GW1_SERDC  == GWH->GWH_SERDC; 
								.And. GW1->GW1_NRDC   == GWH->GWH_NRDC

				If GWF->(dbSeek(GWH->GWH_FILIAL + GWH->GWH_NRCALC));
						.And. GWF->GWF_ORIGEM == '4'
					//Romaneio do Cálculo não é o mesmo do romaneio/documento
					If !Empty(GWF->GWF_NRROM) .And. cNrRoman != GWF->GWF_FILIAL + GWF->GWF_NRROM
						lTodosRoma := .F.
						Exit
					Else // Ao menos um cálculo de origem 4 está relacionado ao romaneio corrente
						lLibCalc := .T.
						If Empty(GWF->GWF_NRROM) .And. lTodosRoma .And. !Empty(cNrRoman)
							Reclock("GWF",.F.)
								GWF->GWF_NRROM := SubStr(cNrRoman,FWSizeFilial()+1)
							MsUnlock("GWF")
						EndIf
					EndIf
				Else // Um dos documentos do romaneio não possui um cálculo origem 4
					lLibCalc := .F.
					Exit
				EndIf
				GWH->(dbSkip())
			EndDo
			If !lLibCalc .Or. !lTodosRoma
				Exit
			EndIf
			GW1->(dbSkip())
		EndDo

		If lTodosRoma .And. lLibCalc .And. GWN->(dbSeek(cNrRoman))
			RecLock('GWN', .F. )
				GWN->GWN_CALC   := "1"
				GWN->GWN_MTCALC := ""
				GWN->GWN_DTCALC := DDATABASE
				GWN->GWN_HRCALC := SubStr(TIME(), 1, 5)
			MsUnlock("GWN")
		EndIf
	EndIf
	RestArea(aAreaGWN)
Return lTodosRoma .And. lLibCalc

//-------------------------------------------------------------------
/*
//Uso do Pergunte GFEA050
Function GFE50VLDP(cTrp)
Local lRet	:=	.T.

If cTrp <> GWN->GWN_CDTRP .And. SuperGetMv("MV_GFETRP",.F.,"1") == "2"
Help(,,'HELP',,'Conforme definido pelos Parâmetros do Módulo, não é permitido redefinir o Transportador das Cargas pelo Romaneio. O Transportador do Romaneio deve ser o mesmo Transportador do primeiro trecho dos Documentos de Carga',1,0)
lRet := .F.
EndIf
Return lRet
*/
//-------------------------------------------------------------------
//Abre uma tela de pesquisa que permite a marcação de documentos de carga na lista superior
Function GFEA050BDC()
	Local aAreaGW1 := GW1->( GetArea() )
	Local aPosEnch := {}

	Private cGW1NRDC   := Space(TamSX3("GW1_NRDC"  )[1])
	Private cGW1CDTPDC := Space(TamSX3("GW1_CDTPDC")[1])
	Private cGW1SERDC  := Space(TamSX3("GW1_SERDC" )[1])
	Private cGW1EMISDC := Space(TamSX3("GW1_EMISDC")[1])
	Private oGetNrDc   := Nil
	Private lReload    := .F.
	Private oWind      := Nil

	SetKey(VK_F10,{||GFEA050BDD()})

	GW1->(dbSetOrder(8))

	oSize := FWDefSize():New(.T.)
	oSize:AddObject( "ENCHOICE", 100, 60, .T., .T. ) // Adiciona enchoice
	oSize:SetWindowSize({000, 000, 150, 465})
	oSize:lLateral     := .F.  // Calculo vertical	
	oSize:Process() //executa os calculos

	aPosEnch := {oSize:GetDimension("ENCHOICE","LININI"),;
	oSize:GetDimension("ENCHOICE","COLINI"),;
	oSize:GetDimension("ENCHOICE","LINEND"),;
	oSize:GetDimension("ENCHOICE","COLEND")}

	DEFINE MSDIALOG oWind TITLE "Busca de documento de carga" ;
	FROM oSize:aWindSize[1],oSize:aWindSize[2] ;
	TO oSize:aWindSize[3],oSize:aWindSize[4] ; 
	COLORS 0, 16777215 PIXEL	

	TSay():New(aPosEnch[1]+009,aPosEnch[2]+005,{|| "Nr Documento"},oWind,,,,,,.T.,,,60,10,)
	oGetNrDc := TGet():New(aPosEnch[1]+017,aPosEnch[2]+005,bSETGET(cGW1NRDC),oWind,60,10,"@!",/*bValid*/,,,,,,.T.,,,/*bWhen*/,,,{|x|GFEA050PSQ(x)},.F.,.F.,,"cGW1NRDC",,,,.T.)
	oGetNrDc:cF3 := "GFEGW4"

	TSay():New(aPosEnch[1]+009,aPosEnch[2]+070,{|| "Tipo"},oWind,,,,,,.T.,,,50,10,)
	oGet := TGet():New(aPosEnch[1]+017,aPosEnch[2]+070,bSETGET(cGW1CDTPDC),oWind,50,10,"@!",/*bValid*/,,,,,,.T.,,,/*bWhen*/,,,/*bChange*/,.F.,.F.,,"cGW1CDTPDC")

	TSay():New(aPosEnch[1]+009,aPosEnch[2]+125,{|| "Série"},oWind,,,,,,.T.,,,50,10,)
	oGet := TGet():New(aPosEnch[1]+017,aPosEnch[2]+125,bSETGET(cGW1SERDC),oWind,50,10,"@!",/*bValid*/,,,,,,.T.,,,/*bWhen*/,,,/*bChange*/,.F.,.F.,,"cGW1SERDC")

	TSay():New(aPosEnch[1]+009,aPosEnch[2]+180,{|| "Emissor"},oWind,,,,,,.T.,,,50,10,)
	oGet := TGet():New(aPosEnch[1]+017,aPosEnch[2]+180,bSETGET(cGW1EMISDC),oWind,50,10,"@!",/*bValid*/,,,,,,.T.,,,/*bWhen*/,,,/*bChange*/,.F.,.F.,,"cGW1EMISDC")
	oGetNrDc:SetFocus()
	oWind:Activate(,,,.T.,,,{|| EnchoiceBar(oWind, {|| GFEA050BDD() }, {|| lReload := .F., oWind:End() },,)})
	SetKey(VK_F10,{||})
	RestArea(aAreaGW1)
	
	If lReload
		lReload := .F.
		oPanelB:Refresh()
		GFEA050BDC()
	EndIf
	(cAliMKB)->(dbSetOrder(1))
	(cAliMKB)->(dbgotop())
Return

//-------------------------------------------------------------------
//Busca e marca um documento na lista acima. se não achar, pergunta se o usuário deseja adicionar mesmo assim.
Function GFEA050BDD()
	Local aAreaMKB := (cAliMKB)->(GetArea())
	Local aAraMKB2 := (cAliMKB2)->(GetArea())

	(cAliMKB2)->(dbSetOrder(2))
	If (cAliMKB2)->(dbSeek(cGW1CDTPDC+cGW1EMISDC+cGW1SERDC+cGW1NRDC))
		Help(,,'HELP',,'Documento de carga já está relacionado ao Romaneio.',1,0)
		RestArea(aAraMKB2)
		Return
	EndIf

	(cAliMKB)->(dbSetOrder(3))
	If (cAliMKB)->(dbSeek(cGW1CDTPDC+cGW1EMISDC+cGW1SERDC+cGW1NRDC))
		RecLock(cAliMKB,.F.)
			(cAliMKB)->OK := cMarca
		MsUnLock(cAliMKB)
		GFEA50BOK()
	Else
		dbSelectArea("GWU")
		GWU->(dbSetOrder(1))
		If GWU->(dbSeek(GWN->GWN_FILIAL+cGW1CDTPDC+cGW1EMISDC+cGW1SERDC+cGW1NRDC+'01'))
			If GWN->GWN_CDTRP <> GWU->GWU_CDTRP
				If SuperGetMv("MV_GFETRP",.F.,"1") == "2"
					Help(,,'HELP',,'Conforme definido pelo Parâmetro do Módulo, não é permitido redefinir o Transportador da Carga pelo Romaneio. O Transportador do Romaneio deve ser o mesmo Transportador do primeiro trecho do Documento de Carga',1,0)
					Return
				Else
					If !MsgYesNo("O Transportador do Romaneio difere do primeiro trecho do Documento de Carga.Confirma redefinição do transportador do primeiro trecho?")
						Return
					EndIf
				EndIf
			EndIf
		
			GW1->(dbSetOrder(1))
			GW1->(dbSeek(GWN->GWN_FILIAL+cGW1CDTPDC+cGW1EMISDC+cGW1SERDC+cGW1NRDC))
			If !Empty(GW1->GW1_NRROM) .And. GW1->GW1_NRROM != GWN->GWN_NRROM
				Help(,,'HELP',,'Documento de carga já está relacionado a outro Romaneio.',1,0)
				Return
			EndIf
		
			If GW1->GW1_SIT != "3"
				Help(,,'HELP',,'Documento de carga deve estar liberado.',1,0)
				Return
			EndIf
		
			dbSelectArea("GV5")
			GV5->(dbSetOrder(1))
			GV5->(dbSeek(xFilial("GV5")+ GW1->GW1_CDTPDC))
			dbSelectArea("GV4")
			GV4->(dbSetOrder(1))
			GV4->(dbSeek(xFilial("GV4")+ GWN->GWN_CDTPOP))
		
			If GV5->GV5_SENTID != GV4->GV4_SENTID .Or. GV4->GV4_SENTID != '0'
				Help(,,'HELP',,'Sentido da carga deve ser o mesmo do documento de carga.',1,0)
				Return
			EndIf

			RecLock(cAliMKB,.T.)
				(cAliMKB)->OK     := cMarca
				(cAliMKB)->TPDC   := cGW1CDTPDC
				(cAliMKB)->CDEMIS := cGW1EMISDC
				(cAliMKB)->SERIE  := cGW1SERDC
				(cAliMKB)->NRDC   := cGW1NRDC
			MsUnLock(cAliMKB)
			GFEA50BOK()
		Else
			Help(,,'HELP',,'Documento de carga não localizado',1,0)
			Return
		EndIf
	EndIf
	
	RestArea(aAreaMKB)
	cGW1NRDC   := Space(TamSX3("GW1_NRDC"  )[1])
	cGW1CDTPDC := Space(TamSX3("GW1_CDTPDC")[1])
	cGW1SERDC  := Space(TamSX3("GW1_SERDC" )[1])
	cGW1EMISDC := Space(TamSX3("GW1_EMISDC")[1])
	oGetNrDc:SetFocus()
	lReload := .T.
	oWind:End()
Return

//-------------------------------------------------------------------
//Pesquisa e preenche os outros campos se achar um documento de carga válido pelo número
Function GFEA050PSQ()
	Local cAliasQ
	Local cQuery := ""
	Local aAreaMKB := (cAliMKB2)->(GetArea())
	Local aDCMark := {}

	(cAliMKB2)->(dbSetOrder(2))
	(cAliMKB2)->(dbGoTop())
	While !(cAliMKB2)->(Eof())
		aAdd(aDCMark,(cAliMKB2)->(TPDC+CDEMIS+SERIE+NRDC))
		(cAliMKB2)->(dbSkip())
	EndDo

	cQuery := "SELECT GW1.GW1_FILIAL, GW1.GW1_SERDC SERIE, GW1.GW1_NRDC NRDC, GW1.GW1_CDTPDC TPDC, "
	cQuery += "      	GW1.GW1_EMISDC CDEMIS"
	cQuery += " FROM " + RetSQLName("GW1") + " GW1 "
	cQuery += " INNER JOIN " + RetSQLName("GV5") + " GV5 ON GV5.GV5_FILIAL = '" + xFilial("GV5") + "' AND GV5.GV5_CDTPDC = GW1.GW1_CDTPDC "
	cQuery += " INNER JOIN " + RetSQLName("GWU") + " GWU ON GWU.GWU_FILIAL = '" + xFilial("GWU") + "' AND GWU.GWU_CDTPDC = GW1.GW1_CDTPDC AND "
	cQuery += "		GWU.GWU_EMISDC = GW1.GW1_EMISDC AND GWU.GWU_SERDC = GW1.GW1_SERDC AND GWU.GWU_NRDC = GW1.GW1_NRDC AND GWU.GWU_SEQ = '01' "
	cQuery += " INNER JOIN " + RetSQLName("GV4") + " GV4 ON GV4.GV4_FILIAL = '" + xFilial("GV4") + "' AND GV4.GV4_CDTPOP = '" + GWN->GWN_CDTPOP + "'"
	cQuery += " LEFT JOIN " + RetSQLName("GW4") + " GW4 ON GW4.GW4_FILIAL = '" + xFilial("GW4") + "' AND GW4.GW4_TPDC = GW1.GW1_CDTPDC AND "
	cQuery += "		GW4.GW4_EMISDC = GW1.GW1_EMISDC AND GW4.GW4_SERDC = GW1.GW1_SERDC AND GW4.GW4_NRDC = GW1.GW1_NRDC  AND GW4.D_E_L_E_T_ = ' '"
	cQuery += " WHERE GW1.GW1_SIT = '3' AND GW1.GW1_NRDC = '" + cGW1NRDC + "'" 
	cQuery += "		AND (GW1.GW1_NRROM = '' OR GW1.GW1_NRROM = '0') AND (GV5.GV5_SENTID = GV4.GV4_SENTID OR GV4.GV4_SENTID = '0') AND "
	cQuery += "		GW1.GW1_FILIAL = '" + GWN->GWN_FILIAL + "' AND GW4.GW4_NRDF IS NULL AND GW1.D_E_L_E_T_ = ' ' AND "
	cQuery += "		GV4.D_E_L_E_T_ = ' ' AND GV5.D_E_L_E_T_ = ' '"
	cQuery += "		ORDER BY GW1.GW1_NRDC"
	cAliasQ := GetNextAlias()
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQ, .F., .T.)
	
	While !(cAliasQ)->(Eof())
		If aScan(aDCMark,{|x| x == (cAliasQ)->(TPDC+CDEMIS+SERIE+NRDC)}) == 0
			cGW1NRDC	:= (cAliasQ)->NRDC
			cGW1CDTPDC	:= (cAliasQ)->TPDC
			cGW1SERDC	:= (cAliasQ)->SERIE
			cGW1EMISDC	:= (cAliasQ)->CDEMIS
			(cAliasQ)->(dbCloseArea())
			RestArea(aAreaMKB)
			Return
		EndIf
		(cAliasQ)->(dbSkip())
	EndDo
	(cAliasQ)->(dbCloseArea())
	RestArea(aAreaMKB)
Return
