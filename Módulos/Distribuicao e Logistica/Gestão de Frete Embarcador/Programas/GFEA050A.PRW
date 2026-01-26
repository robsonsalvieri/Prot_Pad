#INCLUDE "GFEA050A.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "DBINFO.CH"

#DEFINE CRLF CHR(13)+CHR(10) // FINAL DE LINHA

// SONARQUBE - CA1003: Uso não permitido de chamada de API em LOOP
Static lPE503		:= ExistBlock("GFEA0503")
Static lPE505		:= ExistBlock("GFEA05A5")
Static lPE506		:= ExistBlock("GFEA05A6")
Static lPE507		:= ExistBlock("GFEA05A7")
Static lPE508       := ExistBlock("GFEA05A8")
Static lPE509       := ExistBlock("GFEA05A9")
Static s_INTFRE		:= SuperGetMV('MV_INTFRE',.F.,'1')
Static s_GFETRP		:= SuperGetMv("MV_GFETRP",.F.,"1")
Static lExiSITFRE	:= GFXCP12117("GW1_SITFRE")
Static s_MULFIL		:= SuperGetMV("MV_MULFIL",.F.,"2")

//-------------------------------------------------------------------  
/*/{Protheus.doc} GFEA050A

Cria o vinculo entre o Documento de Carga e um Romaneio, permite ao 
usuário selecionar os documentos de carga que vão fazer parte do romaneio.

@author Luiz Fernando Soares	
@since 17/11/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFEA050A(cParamF12)
	Local oDlg
	Local cDSTRAN
	Local aPos
	Local aRotAdic := {}
	Local oSize
	Local oOK := LoadBitmap( GetResources(), "LBOK" )
	Local oNO := LoadBitmap( GetResources(), "LBNO" )

	aNewButton := {}

	Private cCadastro := STR0001 //"Documentos de Carga"
	Private cMarca    := GetMark()
	//Arrays para os rodapés - [1]->Nr Docs,[2]->Peso,[3]->Peso Cub,[4]->Volume,[5]->Valor Merc,[6]->Nr Volumes,[7]->Peso Liq
	Private aRdpDC    := {0,0,0,0,0,0,0}
	Private aRdpSel   := {0,0,0,0,0,0,0}
	Private _lFiltro  := .F.
	Private _lChgDocs := .F.	// Indica se houve alteração nos documentos de carga do romaneio
	Private oPanelB
	Private aDocFil := {} // Documentos de carga Filtrados
	Private aDocSel := {} // Documentos de Carga Selecionados
	Private nLinSel := 0
	Private oBrFil
	Private oBrSel
	Default cParamF12 := 2 // 1 - Sim 2 - Não

	//----------------------------------------------
	// Criacao da tabela temporaria p/ Markbrowse  
	//---------------------------------------------- 
	aMKB := {{"OK"    , "",                   02},;
			 {"FILIAL", "Filial",		     04},;
			 {"SERIE" , STR0002,              05},;
			 {"NRDC"  , STR0003,              16},;
			 {"TPDC"  , STR0004,              05},;
			 {"TPFRET", "Tipo de Frete",      25},;
			 {"CDEMIS", STR0005,              TamSx3("GU3_CDEMIT")[1]},;
			 {"NMEMIS", STR0006,              30},;
			 {"CDREM" , STR0007,              TamSx3("GU3_CDEMIT")[1]},;
			 {"NMREM" , "Nome do Remetente",  30},;
			 {"CDDEST", STR0008,              TamSx3("GU3_CDEMIT")[1]},;
			 {"NMDEST", "Nome do Destino",    30},;
			 {"NRREG" , "Região",             06},;
			 {"NRCID" , "Cidade",             TamSx3("GU3_NRCID")[1]},;
			 {"DTEMIS", "Emissão",            30},;
			 {"DTSAI" , "Data Saida",         30},;
			 {"CIDDES", "Cidade Destino",     TamSx3("GU7_NMCID")[1]},;
			 {"UFDEST", "UF Destino",         08}}

	If s_MULFIL == "1"
		SetMVValue("GFEA050FIL", "MV_PAR01", '')       				// Filial de ?              
		SetMVValue("GFEA050FIL", "MV_PAR02", 'ZZZZZZZZ')    		// Filial até ?             
		SetMVValue("GFEA050FIL", "MV_PAR03", '')       				// Serie de ?               
		SetMVValue("GFEA050FIL", "MV_PAR04", 'ZZZZZ')       		// Serie até ?              
		SetMVValue("GFEA050FIL", "MV_PAR05", '')       				// Numero Docto de ?        
		SetMVValue("GFEA050FIL", "MV_PAR06", 'ZZZZZZZZZZZZZZZZ')    // Numero Docto até ?       
		SetMVValue("GFEA050FIL", "MV_PAR07", '')       				// Cidade Destino de ?      
		SetMVValue("GFEA050FIL", "MV_PAR08", 'ZZZZZZZ')       		// Cidade Destino até ?     
		SetMVValue("GFEA050FIL", "MV_PAR09", '')       				// UF de ?                  
		SetMVValue("GFEA050FIL", "MV_PAR10", 'ZZ')       			// UF até ?                 
		SetMVValue("GFEA050FIL", "MV_PAR11", '')       				// Destinatário de ?        
		SetMVValue("GFEA050FIL", "MV_PAR12", 'ZZZZZZZZZZZZZZ')      // Destinatário até ?       
		SetMVValue("GFEA050FIL", "MV_PAR13", GWN->GWN_CDTRP)       	// Transportador de ?       
		SetMVValue("GFEA050FIL", "MV_PAR14", GWN->GWN_CDTRP)       	// Transportador até ?      
		SetMVValue("GFEA050FIL", "MV_PAR15", '')       				// Tipo Docto de ?          
		SetMVValue("GFEA050FIL", "MV_PAR16", 'ZZZZZ')       		// Tipo Docto até ?         
		SetMVValue("GFEA050FIL", "MV_PAR17", 1)       				// Tipo Frete ?             
		SetMVValue("GFEA050FIL", "MV_PAR18", STOD("20000101"))      // Data Prev. Saída de ?    
		SetMVValue("GFEA050FIL", "MV_PAR19", Date())      			// Data Prev. Saída até ?   
		SetMVValue("GFEA050FIL", "MV_PAR20", STOD("20000101"))      // Data Emissao de ?        
		SetMVValue("GFEA050FIL", "MV_PAR21", Date())      			// Data Emissao até ?       
		SetMVValue("GFEA050FIL", "MV_PAR22", '')      				// Reg. Comercial de ?      
		SetMVValue("GFEA050FIL", "MV_PAR23", 'ZZZZZZZZZZZZ')       	// Reg. Comercial até ? 

		Pergunte("GFEA050FIL", .F.)
	Else
		SetMVValue("GFEA050","MV_PAR01", '')
		SetMVValue("GFEA050","MV_PAR02", 'zzzzz')
		SetMVValue("GFEA050","MV_PAR03", '')
		SetMVValue("GFEA050","MV_PAR04", 'zzzzzzzzzzzzzzzz')
		SetMVValue("GFEA050","MV_PAR05", '')
		SetMVValue("GFEA050","MV_PAR06", '9999999')
		SetMVValue("GFEA050","MV_PAR07", '')
		SetMVValue("GFEA050","MV_PAR08", 'zz')
		SetMVValue("GFEA050","MV_PAR09", '')
		SetMVValue("GFEA050","MV_PAR10", 'zzzzzzzzzzzzzz')
		SetMVValue("GFEA050","MV_PAR11", GWN->GWN_CDTRP)
		SetMVValue("GFEA050","MV_PAR12", GWN->GWN_CDTRP)
		SetMVValue("GFEA050","MV_PAR13", '')
		SetMVValue("GFEA050","MV_PAR14", 'zzzzz')
		SetMVValue("GFEA050","MV_PAR15", 1)
		SetMVValue("GFEA050","MV_PAR16", STOD(""))
		SetMVValue("GFEA050","MV_PAR17", STOD('20491231'))
		SetMVValue("GFEA050","MV_PAR18", STOD('20000101'))
		SetMVValue("GFEA050","MV_PAR19", Date())
		SetMVValue("GFEA050","MV_PAR20", '')
		SetMVValue("GFEA050","MV_PAR21", 'zzzzzzzzzzzz')

		Pergunte("GFEA050", .F.)
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

	//----- Processa os registros e carrega os browses -----//
	If cParamF12 == 1 //Exibe tela de filtro antes da abertura do programa
		GFE050AFIL(.F.)
	EndIf
	Processa({|lEnd| GFE050AMB()},STR0027,STR0028) //"Processando informações"###"Aguarde"
	CursorArrow()

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
	oBtnAdd  := TBtnBmp():NewBar("PMSSETADOWN","PMSSETADOWN",,,,{||GFEA50AOK()},,oPnlBtn1,,,"",,,,,"")
	oBtnAdd:cToolTip := STR0010 //"Adicionar"
	oBtnAdd:Align    := CONTROL_ALIGN_TOP

	//------ Botao para Filtro do Documento de carga com o romaneio -----//			
	oBtnFiltro			:= TBtnBmp():NewBar("brw_filtro","brw_filtro",,,,{|| GFE050AFIL(.T.,oBrFil)},,oPnlBtn1,,,"",,,,,"")
	oBtnFiltro:cToolTip := STR0011 //"Filtrar"
	oBtnFiltro:Align    := CONTROL_ALIGN_TOP

	//Botão para selecionar todos os documentos de carga
	oBtnChk := TBtnBmp():NewBar("CHECKED","CHECKED",,,,{||GFEA50ACHK(1, @aDocFil)},,oPnlBtn1,,,"",,,,,"")
	oBtnChk:cToolTip := STR0045 //"Marca todos os documentos de carga em tela"
	oBtnChk:Align    := CONTROL_ALIGN_TOP

	//Botão para desselecionar todos os documentos de carga
	oBtnDChk := TBtnBmp():NewBar("UNCHECKED","UNCHECKED",,,,{||GFEA50ACHK(2, @aDocFil)},,oPnlBtn1,,,"",,,,,"")
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

	SetKey(VK_F9,{||GFEA050ADC()})
	//Adiciona documento de carga
	oBtnAddDC		  := TBtnBmp():NewBar("BMPINCLUIR","BMPINCLUIR",,,,{||GFEA050ADC()},,oPnlBtn2,,,"",,,,,"")
	oBtnAddDC:cToolTip := "Localiza e adiciona documentos de carga.(Abrir - F9|Adicionar - F10)"
	oBtnAddDC:Align    := CONTROL_ALIGN_TOP

	//------ Botao para visualizar Documento de carga  -----// 
	oBtnVis  := TBtnBmp():NewBar("bmpvisual","bmpvisual",,,,{||GFE050AVIS()},,oPnlBtn2,,,"",,,,,"")
	oBtnVis:cToolTip := STR0014 //"Visualzar"
	oBtnVis:Align    := CONTROL_ALIGN_TOP

	//------ Botao para simular Trechos  -----// 
	oBtnCalc		  := TBtnBmp():NewBar("SIMULACAO","SIMULACAO",,,,{||GFEA50ACL()},,oPnlBtn2,,,"",,,,,"")
	oBtnCalc:cToolTip := STR0015 //"Simular Calculo"
	oBtnCalc:Align    := CONTROL_ALIGN_TOP

	If lPE508
		ExecBlock("GFEA05A8",.f.,.f.,{oPnlBtn2, oBtnCalc})
	Endif

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
	oBrFil := TWBrowse():New( 01 , 01, 260,184,,;
	{aMKB[01,02], aMKB[02,02], aMKB[03,02], aMKB[04,02], aMKB[05,02], aMKB[06,02], aMKB[07,02], aMKB[08,02], aMKB[09,02],;
	 aMKB[10,02], aMKB[11,02], aMKB[12,02], aMKB[13,02], aMKB[14,02], aMKB[15,02], aMKB[16,02], aMKB[17,02], aMKB[18,02]},;  //Descrição das colunas
	{aMKB[01,03], aMKB[02,03], aMKB[03,03], aMKB[04,03], aMKB[05,03], aMKB[06,03], aMKB[07,03], aMKB[08,03], aMKB[09,03],;
	 aMKB[10,03], aMKB[11,03], aMKB[12,03], aMKB[13,03], aMKB[14,03], aMKB[15,03], aMKB[16,03], aMKB[17,03], aMKB[18,03]},;  //Colunas da tabela
	oPanelB,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )    
	oBrFil:Align := CONTROL_ALIGN_ALLCLIENT 
	oBrFil:SetArray(aDocFil)
	oBrFil:bLine := {||{	IIF(len(aDocFil)>0,IIF(aDocFil[oBrFil:nAt,01],oOK,oNO),), ;
	IIF(len(aDocFil)>0,aDocFil[oBrFil:nAt,02],''), IIF(len(aDocFil)>0,aDocFil[oBrFil:nAt,03],''), ;
	IIF(len(aDocFil)>0,aDocFil[oBrFil:nAt,04],''), IIF(len(aDocFil)>0,aDocFil[oBrFil:nAt,05],''), ;
	IIF(len(aDocFil)>0,aDocFil[oBrFil:nAt,06],''), IIF(len(aDocFil)>0,aDocFil[oBrFil:nAt,07],''), ;
	IIF(len(aDocFil)>0,aDocFil[oBrFil:nAt,08],''), IIF(len(aDocFil)>0,aDocFil[oBrFil:nAt,09],''), ;
	IIF(len(aDocFil)>0,aDocFil[oBrFil:nAt,10],''), IIF(len(aDocFil)>0,aDocFil[oBrFil:nAt,11],''), ;
	IIF(len(aDocFil)>0,aDocFil[oBrFil:nAt,12],''), IIF(len(aDocFil)>0,aDocFil[oBrFil:nAt,13],''), ;    
	IIF(len(aDocFil)>0,aDocFil[oBrFil:nAt,14],''), IIF(len(aDocFil)>0,aDocFil[oBrFil:nAt,15],''), ;
	IIF(len(aDocFil)>0,aDocFil[oBrFil:nAt,16],''), IIF(len(aDocFil)>0,aDocFil[oBrFil:nAt,17],''),;
	IIF(len(aDocFil)>0,aDocFil[oBrFil:nAt,18],'')}}      
	// Troca a imagem no duplo click do mouse 
	oBrFil:bLDblClick := {|| ArmazPos1 := oBrFil:nAt, GFEA50AD(ArmazPos1), oBrFil:Refresh()}
	oBrFil:bChange := {|| oBrFil:Refresh()}
	oBrFil:bHeaderClick :=  {|| GFEA50ACHK(3, @aDocFil), oBrFil:Refresh()}
	//--------------Fim 1 -- criado o browse---------------//

	//--2----- Seleciona a temp-table de Documentos de cargas que ja foram relacionados ao romaneio e cria o browse -----// 
	oBrSel := TWBrowse():New( 01 , 01, 260,184,,;
	{aMKB[01,02], aMKB[02,02], aMKB[03,02], aMKB[04,02], aMKB[05,02], aMKB[06,02], aMKB[07,02], aMKB[08,02], aMKB[09,02],;
	 aMKB[10,02], aMKB[11,02], aMKB[12,02], aMKB[13,02], aMKB[14,02], aMKB[15,02], aMKB[16,02], aMKB[17,02], aMKB[18,02]},;  //Descrição das colunas
	{aMKB[01,03], aMKB[02,03], aMKB[03,03], aMKB[04,03], aMKB[05,03], aMKB[06,03], aMKB[07,03], aMKB[08,03], aMKB[09,03],;
	 aMKB[10,03], aMKB[11,03], aMKB[12,03], aMKB[13,03], aMKB[14,03], aMKB[15,03], aMKB[16,03], aMKB[17,03], aMKB[18,03]},;  //Colunas da tabela
	oPanelC,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )    
	oBrSel:Align := CONTROL_ALIGN_ALLCLIENT 
	oBrSel:SetArray(aDocSel)
	oBrSel:bLine := {||{	IIF(len(aDocSel)>0,IIF(aDocSel[oBrSel:nAt,01],oOK,oNO),), ;
	IIF(len(aDocSel)>0,aDocSel[oBrSel:nAt,02],''), IIF(len(aDocSel)>0,aDocSel[oBrSel:nAt,03],''), ;
	IIF(len(aDocSel)>0,aDocSel[oBrSel:nAt,04],''), IIF(len(aDocSel)>0,aDocSel[oBrSel:nAt,05],''), ;
	IIF(len(aDocSel)>0,aDocSel[oBrSel:nAt,06],''), IIF(len(aDocSel)>0,aDocSel[oBrSel:nAt,07],''), ;
	IIF(len(aDocSel)>0,aDocSel[oBrSel:nAt,08],''), IIF(len(aDocSel)>0,aDocSel[oBrSel:nAt,09],''), ;
	IIF(len(aDocSel)>0,aDocSel[oBrSel:nAt,10],''), IIF(len(aDocSel)>0,aDocSel[oBrSel:nAt,11],''), ;
	IIF(len(aDocSel)>0,aDocSel[oBrSel:nAt,12],''), IIF(len(aDocSel)>0,aDocSel[oBrSel:nAt,13],''), ;    
	IIF(len(aDocSel)>0,aDocSel[oBrSel:nAt,14],''), IIF(len(aDocSel)>0,aDocSel[oBrSel:nAt,15],''), ;
	IIF(len(aDocSel)>0,aDocSel[oBrSel:nAt,16],''), IIF(len(aDocSel)>0,aDocSel[oBrSel:nAt,17],''),;
	IIF(len(aDocSel)>0,aDocSel[oBrSel:nAt,18],'')}}  
	// Troca a imagem no duplo click do mouse 
	oBrSel:bLDblClick := {|| ArmazPos2 := oBrSel:nAt, GFEA50AE(ArmazPos2), oBrSel:Refresh()}
	oBrSel:bChange := {|| nLinSel := oBrSel:nAt}
	oBrSel:bHeaderClick :=  {|| GFEA50ACHK(4, @aDocSel), oBrSel:Refresh()}

	//--------------Fim 2--------------------//
	// Ponto de entrada que permite incluir opções adicionais
	// no menu padrão da rotina de vinculo de Doc Carga x Romaneio

	If ExistBlock("GFEA05A3")
		aRotAdic := ExecBlock("GFEA05A3",.f.,.f.)
		If ValType(aRotAdic) == "A"
			AEval(aRotAdic, {|x| AAdd(aNewButton ,x)})
		EndIf
	EndIf 

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(ODlg,{||If(GFEA50AOK(.T.),ODlg:End(),NIL)},;
	{||ODlg:End()},,aNewButton,/*nRecno*/,/*cAlias*/,/*lMashups*/,/*lImpCad*/, /*lPadrao*/, .F. /*lHasOK*/) CENTERED

	//------ Limpa as tabelas temporarias -----//
	IIF(aDocFil==NIL,,aSize(aDocFil,0))
	aDocFil := Nil
	IIF(aDocSel==NIL,,aSize(aDocSel,0))
	aDocSel := Nil
	IIF(aRdpSel==NIL,,aSize(aRdpSel,0))
	aRdpSel := Nil
	IIF(oBrFil==NIL,,aSize(oBrFil,0))
	oBrFil := Nil
	IIF(oBrSel==NIL,,aSize(oBrSel,0))
	oBrSel := Nil
	//-----------------------------------------//

	SetKey(VK_F9,{||})
	SetKey(VK_F8,{||})

Return _lChgDocs

//-------------------------------------------------------------------
/*/{Protheus.doc} GFE050AMB
Acrescenta os registros na tabela temporaria para que eles sejam exibidos na tela


@author Luiz Fernando Soares
@since 20/11/09
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function GFE050AMB()
	Local cTrpIni := ""
	Local cTrpFim := ""

	cQuery := "SELECT GW1.GW1_FILIAL FILIAL, GW1.GW1_SERDC SERIE, GW1.GW1_NRDC NRDC, GW1.GW1_CDTPDC TPDC, "
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
	cQuery += " 		END) UFDEST, "	
	cQuery += " 		GW1.GW1_QTVOL "	
	cQuery += "FROM " + RetSQLName("GW1") + " GW1 "
	cQuery += "INNER JOIN " + RetSQLName("GU3") + " GU3EMI ON GU3EMI.GU3_FILIAL = '" + xFilial("GU3") + "' AND GU3EMI.GU3_CDEMIT = GW1.GW1_EMISDC AND GU3EMI.D_E_L_E_T_ = ' ' "
	cQuery += "INNER JOIN " + RetSQLName("GU3") + " GU3REM ON GU3REM.GU3_FILIAL = '" + xFilial("GU3") + "' AND GU3REM.GU3_CDEMIT = GW1.GW1_CDREM  AND GU3REM.D_E_L_E_T_ = ' ' "
	cQuery += "INNER JOIN " + RetSQLName("GU3") + " GU3DES ON GU3DES.GU3_FILIAL = '" + xFilial("GU3") + "' AND GU3DES.GU3_CDEMIT = GW1.GW1_CDDEST AND GU3DES.D_E_L_E_T_ = ' ' "
	If _lFiltro
		cQuery += "INNER JOIN " + RetSQLName("GU7") + " GU7 ON GU7.GU7_FILIAL = '" + xFilial("GU7") + "' AND GU7.GU7_NRCID = GU3DES.GU3_NRCID AND GU7.D_E_L_E_T_ = ' ' "
	EndIf
	cQuery += "INNER JOIN " + RetSQLName("GV5") + " GV5 ON GV5.GV5_FILIAL = '" + xFilial("GV5") + "' AND GV5.GV5_CDTPDC = GW1.GW1_CDTPDC AND GV5.D_E_L_E_T_ = ' ' "
	cQuery += "INNER JOIN " + RetSQLName("GWU") + " GWU ON GWU.GWU_FILIAL = GW1.GW1_FILIAL AND GWU.GWU_CDTPDC = GW1.GW1_CDTPDC AND "
	cQuery += "		GWU.GWU_EMISDC = GW1.GW1_EMISDC AND GWU.GWU_SERDC = GW1.GW1_SERDC AND GWU.GWU_NRDC = GW1.GW1_NRDC AND GWU.GWU_SEQ = '01' "
	cQuery += "INNER JOIN " + RetSQLName("GV4") + " GV4 ON GV4.GV4_FILIAL = '" + xFilial("GV4") + "' AND GV4.GV4_CDTPOP = '" + GWN->GWN_CDTPOP + "'"
	cQuery += "LEFT JOIN " + RetSQLName("GU7") + " GU7DEST ON GU7DEST.GU7_FILIAL = '" + xFilial("GU7") + "' AND GU7DEST.GU7_NRCID = GU3DES.GU3_NRCID AND GU7DEST.D_E_L_E_T_ = ' ' "
	cQuery += "LEFT JOIN " + RetSQLName("GU7") + " GU7DOC ON GU7DOC.GU7_FILIAL = '" + xFilial("GU7") + "' AND GU7DOC.GU7_NRCID = GW1.GW1_ENTNRC AND GU7DOC.D_E_L_E_T_ = ' ' "
	cQuery += "WHERE GW1.D_E_L_E_T_ = ' ' "
	cQuery += "  AND GW1.GW1_SIT = '3'  "
	cQuery += "  AND (GW1.GW1_NRROM = '' OR GW1.GW1_NRROM = '0') " 
	cQuery += "  AND (GV5.GV5_SENTID = GV4.GV4_SENTID OR GV4.GV4_SENTID = '0') "
	cQuery += "  AND GV4.D_E_L_E_T_ = ' ' "
	cQuery += "  AND GWU.D_E_L_E_T_ = ' ' "
	
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
			cQuery += "AND GW1.GW1_DTPSAI >= '" + DToS(MV_PAR16) + "' AND GW1.GW1_DTPSAI <= '" + DToS(MV_PAR17) + "' " //Data de Saída
			cQuery += "AND GW1.GW1_DTEMIS >= '" + DToS(MV_PAR18) + "' AND GW1.GW1_DTEMIS <= '" + DToS(MV_PAR19) + "' " //Data de Emissão
			cQuery += "AND GW1.GW1_REGCOM >= '" + MV_PAR20 + "' AND GW1.GW1_REGCOM <= '" + MV_PAR21 + "' " //Região comercial
		EndIf
	EndIf

	//Ponto de entrada Pirelli
	If ExistBlock("GFEA05A1")
		cQuery += ExecBlock("GFEA05A1",.f.,.f.)
	EndIf
	//Fim ponto de entrada Pirelli 

	cQuery += " ORDER BY GW1.GW1_FILIAL, GW1.GW1_CDTPDC, GW1.GW1_EMISDC, GW1.GW1_SERDC, GW1.GW1_NRDC "
	
	cQuery := ChangeQuery(cQuery)
	cGW1 := GetNextAlias()
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cGW1, .F., .T.)

	ASize(aDocFil,0)

	(cGW1)->( dbGoTop() )
	while !(cGW1)->(Eof())
		AaDD(aDocFil,{.F.   ,;
			(cGW1)->FILIAL  ,; 
			(cGW1)->SERIE   ,;
			(cGW1)->NRDC    ,;
			(cGW1)->TPDC    ,;
			(cGW1)->TPFRET  ,;
			(cGW1)->CDEMIS  ,;
			(cGW1)->NMEMIS  ,;
			(cGW1)->CDREM   ,;
			(cGW1)->NMREM   ,;
			(cGW1)->CDDEST  ,; 
			(cGW1)->NMDEST  ,;
			(cGW1)->NRREG  ,;
			(cGW1)->NRCID  ,;
			StoD((cGW1)->DTEMIS)  ,;
			StoD((cGW1)->DTSAI)  ,;
			(cGW1)->CIDDES  ,;
			(cGW1)->UFDEST  ,;
			(cGW1)->GW1_QTVOL })
			(cGW1)->(dbSkip())
	EndDo

	If Len(aDocFil) = 0
		AaDD(aDocFil,{.F.,; 
					  '' ,;
				      '' ,;
					  '' ,;
					  '' ,;
					  '' ,;
					  '' ,;
					  '' ,;
					  '' ,;
					  '' ,;
					  '' ,; 
					  '' ,;
					  '' ,;
					  '' ,;
					  '' ,;
					  '' ,;
					  '' ,;
					  '' ,;
					  0 })
	EndIf

	(cGW1)->( dbCloseArea() )

	cQuery := "SELECT GW1.GW1_FILIAL FILIAL, GW1.GW1_SERDC SERIE, GW1.GW1_NRDC NRDC, GW1.GW1_CDTPDC TPDC, "
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
	cQuery += " 		END) UFDEST, "	
	cQuery += " 		GW1.GW1_QTVOL "	
	cQuery += "FROM " + RetSQLName("GW1") + " GW1 "
	cQuery += "INNER JOIN " + RetSQLName("GU3") + " GU3EMI ON GU3EMI.GU3_FILIAL = '" + xFilial("GU3") + "' AND GU3EMI.GU3_CDEMIT = GW1.GW1_EMISDC AND GU3EMI.D_E_L_E_T_ = ' ' "
	cQuery += "INNER JOIN " + RetSQLName("GU3") + " GU3REM ON GU3REM.GU3_FILIAL = '" + xFilial("GU3") + "' AND GU3REM.GU3_CDEMIT = GW1.GW1_CDREM  AND GU3REM.D_E_L_E_T_ = ' ' "
	cQuery += "INNER JOIN " + RetSQLName("GU3") + " GU3DES ON GU3DES.GU3_FILIAL = '" + xFilial("GU3") + "' AND GU3DES.GU3_CDEMIT = GW1.GW1_CDDEST AND GU3DES.D_E_L_E_T_ = ' ' "
	cQuery += "LEFT JOIN " + RetSQLName("GU7") + " GU7DEST ON GU7DEST.GU7_FILIAL = '" + xFilial("GU7") + "' AND GU7DEST.GU7_NRCID = GU3DES.GU3_NRCID AND GU7DEST.D_E_L_E_T_ = ' ' "
	cQuery += "LEFT JOIN " + RetSQLName("GU7") + " GU7DOC ON GU7DOC.GU7_FILIAL = '" + xFilial("GU7") + "' AND GU7DOC.GU7_NRCID = GW1.GW1_ENTNRC AND GU7DOC.D_E_L_E_T_ = ' ' "
	If s_MULFIL == "1" .And. GFXCP1212210('GW1_FILROM')
		cQuery += "WHERE GW1.GW1_NRROM = '" + GWN->GWN_NRROM + "' AND GW1.GW1_FILROM = '" + GWN->GWN_FILIAL + "' AND GW1.D_E_L_E_T_ = ' ' "
		cQuery += " ORDER BY GW1.GW1_FILROM, GW1.GW1_CDTPDC, GW1.GW1_EMISDC, GW1.GW1_SERDC, GW1.GW1_NRDC "
	Else 
		cQuery += "WHERE GW1.GW1_NRROM = '" + GWN->GWN_NRROM + "' AND GW1.GW1_FILIAL = '" + GWN->GWN_FILIAL + "' AND GW1.D_E_L_E_T_ = ' ' "
		cQuery += " ORDER BY GW1.GW1_FILIAL, GW1.GW1_CDTPDC, GW1.GW1_EMISDC, GW1.GW1_SERDC, GW1.GW1_NRDC "
	EndIf

	cQuery := ChangeQuery(cQuery)
	cGW1 := GetNextAlias()
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cGW1, .F., .T.)

	ASize(aDocSel,0)

	(cGW1)->( dbGoTop() )
	While !(cGW1)->(Eof())
		AaDD(aDocSel,{.F.,; 
					  (cGW1)->FILIAL,;
					  (cGW1)->SERIE,;
					  (cGW1)->NRDC,;
					  (cGW1)->TPDC,;
					  (cGW1)->TPFRET,;
					  (cGW1)->CDEMIS,;
					  (cGW1)->NMEMIS,;
					  (cGW1)->CDREM,;
					  (cGW1)->NMREM,;
					  (cGW1)->CDDEST,; 
					  (cGW1)->NMDEST,;
					  (cGW1)->NRREG,;
					  (cGW1)->NRCID,;
					  StoD((cGW1)->DTEMIS),;
					  StoD((cGW1)->DTSAI),;
					  (cGW1)->CIDDES,;
					  (cGW1)->UFDEST,;
					  (cGW1)->GW1_QTVOL })
			(cGW1)->(dbSkip())
	EndDo

	if Len(aDocSel) = 0
		AaDD(aDocSel,{.F.,; 
					  '' ,;
					  '' ,;
					  '' ,;
					  '' ,;
					  '' ,;
					  '' ,;
					  '' ,;
					  '' ,;
					  '' ,;
					  '' ,; 
					  '' ,;
					  '' ,;
					  '' ,;
					  '' ,;
					  '' ,;
					  '' ,;
					  '' ,;
					  0 })
	EndIf

	(cGW1)->( dbCloseArea() )

	aRdpDC:={0,0,0,0,0,0,0}
	GFEA50TSEL()
	GFE50ASORT(.T.,.T.)
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA50AOK
Salva o número do Romaneio no Documento de Carga escolhido

@author Luiz Fernando Soares
@since 20/11/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFEA50AOK(lConfirma) 

	Local lVincRoman := .F.
	Local nI         := 0
	Local nCont      := 0
	Local lRetPE     := .T.

	Default lConfirma := .F.

	If !GFE50ALINV(aDocFil)
		Return .T.
	EndIf

	For nI:= Len(aDocFil) to 1 Step -1 
		If aDocFil[nI,1] == .T.

			GW1->( dbSetOrder(1) )
			If GW1->( dbSeek(aDocFil[nI,02] + aDocFil[nI,05] + aDocFil[nI,07] + aDocFil[nI,03] + aDocFil[nI,04]) )
				If GWN->GWN_BLOQPF == "2"
					GV5->(dbSetOrder(1))
					GV5->(dbSeek(xFilial("GV5") + GW1->GW1_CDTPDC))
					If((GV5->GV5_EMITPF == "2" .Or. Empty(GV5->GV5_EMITPF)))
						If !IsBlind()
							MsgInfo("Você está vinculando um Documento de Carga cujo seu tipo bloqueia a emissão de pré-fatura a um Romaneio que não bloqueia a emissão de pré-fatura. Desta forma, o Romaneio será bloqueado para emissão de pré-fatura.")
						EndIf
						RecLock("GWN",.F.)
						GWN->GWN_BLOQPF := "1"
						GWN->(MsUnlock())	
					EndIf
				EndIf

				GW4->( dbSetOrder(02) )
				If GW4->( dbSeek(GW1->GW1_FILIAL+GW1->GW1_EMISDC+GW1->GW1_SERDC+GW1->GW1_NRDC+GW1->GW1_CDTPDC) )
					If !IsBlind()
						MsgInfo("O Documento de Carga " + Alltrim(GW1->GW1_NRDC) + " já está vinculado a um Documento de Frete.")
					EndIf
					Return .F.
				EndIf

				If !Empty(GWN->GWN_VIAGEM)
					If !GFEA058RVG(GW1->(RecNo()))
						If !IsBlind()
							MsgInfo("Não é possível vincular o documento " + Alltrim(GW1->GW1_NRDC) + " que possui frete combinado/simulação com origem erp em romaneio com viagem")
						EndIf
						Return .F.
					EndIf
				EndIf

				// Ponto de entrada que permite realizar consistência adicional
				// na seleção dos documentos de carga que pertencerão ao romaneio
				If lPE503
					lRetPE := ExecBlock("GFEA0503",.F.,.F.,{GWN->GWN_NRROM,GW1->GW1_CDTPDC,GW1->GW1_EMISDC,GW1->GW1_SERDC,GW1->GW1_NRDC})
					If ValType(lRetPE) == "L" .And. !lRetPE
						Return .F.
					EndIf
				EndIf

				// Atualiza o documento de carga com o numero do romaneio
				RecLock("GW1", .F.)
					GW1->GW1_NRROM := GWN->GWN_NRROM
					If GFXCP1212210('GW1_FILROM')
						GW1->GW1_FILROM := GWN->GWN_FILIAL
					EndIf
					If GW1->GW1_SIT != "2"
						GW1->GW1_SIT   := "4" // Embarcado
					EndIf
					lVincRoman := .T.
				GW1->(MsUnLock())

				If lExiSITFRE .And. s_INTFRE == '2'
					If GW1->GW1_ORIGEM == "2" .And. GW1->GW1_SITFRE != '6'
						RecLock("GW1", .F.)
						GW1->GW1_SITFRE := "2"
						GW1->GW1_MOTFRE := "GFEA050 - Vinculo do Documento de Carga no Romaneio"
						GW1->GW1_DTFRE  := Date()
						GW1->( MsUnLock() )
					EndIf
				EndIf

				GV4->( dbSetOrder(1) )
				If GV4->( dbSeek(xFilial("GV4") + GWN->GWN_CDTPOP) )

					GWU->( dbSetOrder(1) )
					If GWU->( dbSeek(xFilial("GWU") + aDocFil[nI,05] + aDocFil[nI,07] + aDocFil[nI,03] + aDocFil[nI,04]) )
						RecLock('GWU', .F. )
							GWU->GWU_CDTRP  := GWN->GWN_CDTRP
							GWU->GWU_CDTPVC := GWN->GWN_CDTPVC
						GWU->( MsUnLock() )
					EndIf
				EndIf   

				_lChgDocs := .T. // Romaneio teve alteração nos seus documentos de carga

			EndIf

			If nCont == 0
				GFE50ADELARRAY(aDocSel)
			EndIf

			AaDD(aDocSel,{.F.,aDocFil[nI,02],aDocFil[nI,03],aDocFil[nI,04],aDocFil[nI,05],aDocFil[nI,06],;
						  aDocFil[nI,07],aDocFil[nI,08],aDocFil[nI,09],aDocFil[nI,10],aDocFil[nI,11],aDocFil[nI,12],;
						  aDocFil[nI,13],aDocFil[nI,14],aDocFil[nI,15],aDocFil[nI,16],aDocFil[nI,17],aDocFil[nI,18],aDocFil[nI,19]})
			aDel(aDocFil,nI)
			nCont++
		EndIf
	Next

	If lVincRoman
		// Houve vinculo de romaneio com documento
		// Verifica se o cálculo do documento pode ser liberado, se possuir cálculo simulado
		aAreaGW1:= GW1->(GetArea())
		GFEA050ALI(GWN->GWN_FILIAL + GWN->GWN_NRROM)
		RestArea(aAreaGW1)

		If lConfirma
			//verifica se deve liberá-lo e libera-os
			GFE50LbRom()
		EndIf
	ElseIf lConfirma
		//verifica se deve liberá-lo e libera-os
		GFE50LbRom()
	EndIf

	ASize(aDocFil,Len(aDocFil)-nCont)

	GFE50ASORT(.T.,.T.)

	aRdpDC:={0,0,0,0,0,0,0}

	If !IsBlind()
		GFEA50RD()
		GFEA50TSEL()
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
	Local nI         := 0
	Local nCont      := 0
	Local cTxtDoc	 := ''
	Local cOriCalc   := ""
	Local cMV_CALRET := SuperGetMv("MV_CALRET",.F.,"2")

	If !GFE50ALINV(aDocSel)
		Return .T.
	EndIf
	
	If cMV_CALRET == "1"
		cOriCalc := "1"
	EndIf

	For nI:= Len(aDocSel) To 1 Step -1 
		If aDocSel[nI,1] == .T.
			dbSelectArea("GW1")
			dbSetOrder(1)
			If dbSeek(aDocSel[nI,02] + aDocSel[nI,05] + aDocSel[nI,07] + aDocSel[nI,03] + aDocSel[nI,04])
				aCalcs := {}	
				//Verifica se o Documento de carga está entregue, em caso positivo não será possível desvinculá-lo
				If GW1->GW1_SIT == "5"
					Help( ,,'HELP',,"Documento de Carga já foi entregue. Retirada não permitida.", 1, 0,) 
					lRetiraDoc := .F.	
				EndIf

				// Verificar se o documento de carga está relacionado a cálculo de frete
				dbSelectArea("GWH")
				dbSetOrder(02)
				dbSeek(GW1->GW1_FILIAL+GW1->GW1_CDTPDC+GW1->GW1_EMISDC+GW1->GW1_SERDC+GW1->GW1_NRDC)
				While !GWH->(Eof()) .AND. GWH->GWH_FILIAL == GW1->GW1_FILIAL;
								    .AND. GWH->GWH_EMISDC == GW1->GW1_EMISDC;
									.AND. GWH->GWH_SERDC  == GW1->GW1_SERDC;
									.AND. GWH->GWH_NRDC   == GW1->GW1_NRDC
					dbSelectArea("GWF")
					dbSetOrder(01)
					If dbSeek(GWH->GWH_FILIAL + GWH->GWH_NRCALC)
						// Revisar quando a rotina estiver apta para gerar outros tipos de calculo (reentrega, devolucao)
						If aScan(aCalcs,{|x| x[1] == GWH->GWH_FILIAL .And. x[2] == GWH->GWH_NRCALC}) == 0 .AND. (GWF->GWF_TPCALC $ "168" .Or. GWF->GWF_TPCALC == "5" .And. cOriCalc == "1") // 1-Normal, 5-Devolução, 6-Redespacho, 8-Provisao
							aAdd(aCalcs, {GWH->GWH_FILIAL, GWH->GWH_NRCALC})
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

						If !GFEVldLotProvisao(aCalcs[nX][2], aCalcs[nX][1])
							cTxtDoc += ' (Lotes de Provisão) '
							lApagaCalc := .F.
						EndIf

						// Valida o cálculo de frete existente em relacao aos documentos de frete
						If !GFEVldDocFrete(aCalcs[nX][2], ,aCalcs[nX][1])
							cTxtDoc += ' (Documento de Frete) '
							lApagaCalc := .F.
						EndIf

						// Valida o cálculo de frete existente em relacao a pre-fatura
						If !GFEVldPreFat(aCalcs[nX][2], aCalcs[nX][1])
							cTxtDoc += ' (Pré-Fatura) '
							lApagaCalc := .F.
						EndIf

						// Valida o cálculo de frete em relacao a contrato com terceiros
						If !GFEVldContr(aCalcs[nX][2], aCalcs[nX][1])
							cTxtDoc += ' (Contrato com Autônomo) '
							lApagaCalc := .F.
						EndIf

						// Se não for possível eliminar o cálculo, não permitir a retirada do mesmo
						If !lApagaCalc
							Help( ,,'HELP',,"Cálculo do documento de carga possui vínculo com:" + cTxtDoc + "." + CRLF + CRLF + STR0031, 1, 0,) //"Retirada não permitida."
							lRetiraDoc := .F.
							Exit
						Else
							If !GFEVldMovCtb(aCalcs[nX][2], aCalcs[nX][1]) // Cálculo possui movimentos contábeis atualizados no ERP
								cTpCalc := Posicione("GWF",1,xFilial("GWF")+aCalcs[nX],"GWF_TPCALC")
								dbSelectArea("GWF")
								dbSetOrder(01)
								If dbSeek(xFilial("GWF")+aCalcs[nX])
									RecLock("GWF",.F.)
									If cTpCalc $ "16"	// 1-Normal, 6-Redespacho
										GWF->GWF_TPCALC := "8"	// Transforma o cálculo em Provisão              
									EndIf
									GWF->GWF_NRROM := ""   // Desvincula o cálculo do romaneio
									GWF->(MsUnLock())
								EndIf	
							Else
								// Reativa as provisões relacionadas aos documentos de carga do cálculo corrente
								GFEDelEstorno(aCalcs[nX][1], aCalcs[nX][2])
								// Apaga o calculo de frete e seus relacionamentos, incluindo movimentos contábeis
								GFEDelCalc(aCalcs[nX][2], aCalcs[nX][1],,,cOriCalc)
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
					GW1->(MsUnLock())

					If lExiSITFRE .And. s_INTFRE == '2'
						If GW1->GW1_ORIGEM == "2" .And. GW1->GW1_SITFRE != '6'
							RecLock("GW1", .F.)
							GW1->GW1_SITFRE := "2"
							GW1->GW1_MOTFRE := "GFEA050 - Remoção do Documento de Carga do Romaneio"
							GW1->GW1_DTFRE  := Date()
							GW1->( MsUnLock() )
						EndIf
					EndIf

					If lPE509
						ExecBlock("GFEA05A9",.f.,.f.)
					EndIf

					If nCont == 0
						GFE50ADELARRAY(aDocFil)
					EndIf
					AaDD(aDocFil,{.F.,aDocSel[nI,02],aDocSel[nI,03],aDocSel[nI,04],aDocSel[nI,05],aDocSel[nI,06],;
								  aDocSel[nI,07],aDocSel[nI,08],aDocSel[nI,09],aDocSel[nI,10],aDocSel[nI,11],aDocSel[nI,12],;
							      aDocSel[nI,13],aDocSel[nI,14],aDocSel[nI,15],aDocSel[nI,16],aDocSel[nI,17],aDocSel[nI,18],aDocSel[nI,19]})
					aDel(aDocSel,nI)
					nCont++

					_lChgDocs := .T. // Romaneio teve alteração em seus documentos de carga

				EndIf
			EndIf
		EndIf
	next

	if nCont > 0
		ASize(aDocSel,Len(aDocSel)-nCont)

		GFE50ASORT(.T.,.T.)
		GFEA50RD()
		GFEA50TSEL()

		If oBrSel:nAt > Len(aDocSel) .And. Len(aDocSel) > 0
			oBrSel:nAt := Len(aDocSel)
		EndIf
	EndIf

Return

/*-------------------------------------------------------------------
Elimina o estorno dos cálculos de provisão dos documentos de carga
relacionados ao calculo normal recebido
-------------------------------------------------------------------*/
Static Function GFEDelEstorno(cCodFilial, cNrCalcNormal)
	Local aAreaGWF := GWF->(getArea())
	Local aAreaGWH := GWH->(getArea())
	Local aAreaGW1 := GW1->(getArea())    

	ChkFile("GWH",,"GWHBF")	// Cria um "buffer" da tabela GWH, evitando desposicionamento do registro na área original

	dbSelectArea("GWH")
	dbSetOrder(1)
	If dbSeek(cCodFilial + cNrCalcNormal)

		// Para cada documento de carga do calculo de frete normal (ou redespacho)...
		While !GWH->(Eof()) .AND. GWH->GWH_FILIAL == cCodFilial .AND. GWH->GWH_NRCALC == cNrCalcNormal
			dbSelectArea("GW1")
			dbSetOrder(1)
			If dbSeek(GWH->GWH_FILIAL+GWH->GWH_CDTPDC+GWH->GWH_EMISDC+GWH->GWH_SERDC+GWH->GWH_NRDC)
				dbSelectArea("GWHBF")
				dbSetOrder(2)
				If dbSeek(GW1->GW1_FILIAL+GW1->GW1_CDTPDC+GW1->GW1_EMISDC+GW1->GW1_SERDC+GW1->GW1_NRDC)			
					// Localiza os demais cálculos, diferentes do cálculo normal
					While !GWHBF->(Eof()) .AND. GWHBF->GWH_FILIAL == GW1->GW1_FILIAL;
										  .AND. GWHBF->GWH_EMISDC == GW1->GW1_EMISDC;
										  .AND. GWHBF->GWH_SERDC  == GW1->GW1_SERDC;
										  .AND. GWHBF->GWH_NRDC   == GW1->GW1_NRDC;
										  .AND. GWHBF->GWH_NRCALC != cNrCalcNormal				             
						dbSelectArea("GWF")
						dbSetOrder(1)
						// Se o cálculo de frete for do tipo provisão
						If dbSeek(GWHBF->GWH_FILIAL+GWHBF->GWH_NRCALC) .AND. GWF->GWF_TPCALC == "8"	// Provisao					
							// Eliminar os movimentos contábeis de estorno, se possível, fazendo a provisão voltar à ativa
							GWA->(dbSetOrder(1))
							If GWA->(dbSeek(GWF->GWF_FILIAL+"1"+PadR("",5)+PadR("",TamSx3("GWA_CDEMIT")[1])+PadR("",5)+GWF->GWF_NRCALC))
								While !GWA->(Eof()) .AND. GWA->GWA_FILIAL == GWF->GWF_FILIAL;
													.AND. GWA->GWA_TPDOC  == "1";
													.AND. GWA->GWA_CDESP  == PadR("",5);
													.AND. GWA->GWA_CDEMIT == PadR("", TamSx3("GWA_CDEMIT")[1]);
													.AND. GWA->GWA_SERIE  == PadR("",5);
													.AND. AllTrim(GWA->GWA_NRDOC) == AllTrim(GWF->GWF_NRCALC)     										 
									If AllTrim(GWA->GWA_CDTRAN) >= "305" .AND. AllTrim(GWA->GWA_CDTRAN) <= "309"; // Estornos de provisao
																		 .AND. GWA->GWA_SITCTB $ "13"	// Movimento contábil não atualizado no ERP
										RecLock("GWA",.F.)
										dbDelete()
										GWA->(MsUnLock())									
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
/*/{Protheus.doc} GFE050AVIS
Permite a visualização do registro do browse

@author Luiz Fernando Soares
@since 30/11/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFE050AVIS()
	if !GFE50ALINV(aDocSel)
		Return .T.
	EndIf
	if Len(aDocSel) > 0 .AND. nLinSel > 0 .AND. (nLinSel <= Len(aDocSel)) 
		dbSelectArea("GW1")
		dbSetOrder(1)
		if dbSeek(aDocSel[nLinSel,2] + aDocSel[nLinSel,5] + aDocSel[nLinSel,7] + aDocSel[nLinSel,3] + aDocSel[nLinSel,4])
			FWExecView("",'GFEA044',1,,{||.T.})
		endif
	EndIf
Return(.T.)

//-------------------------------------------------------------------
/*/{Protheus.doc} GFE050AFIL
Permite o filtro do browse superior

@author Luiz Fernando Soares
@since 30/11/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFE050AFIL(lFiltrar, oBrwse)

	If s_MULFIL == "1"
		If Pergunte("GFEA050FIL", .T.)
			_lFiltro := .T.
			If lFiltrar
				GFE050AMB()
			EndIf
		Else
			_lFiltro := .F.
		EndIf
	Else
		If Pergunte("GFEA050", .T.)
			_lFiltro := .T.
			If lFiltrar
				GFE050AMB()
			EndIf
		Else
			_lFiltro := .F.
		EndIf
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA50ACL
Rotina para realizar a simulacao do calculo de frete do romaneio

@author Felipe N. Welter
@since 08/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFEA50ACL(lReal) 
	Local nQtdeIt := 0, nVlDC := 0, nVol := 0, nPeso := 0, nVlFrete := 0, nPercDC := 0
	Local aAgrFrt := {}
	Local aDocCarg := {}
	Local aTrchDoc := {}
	Local aItDoc := {}
	Local nI := 0
	Local nX
	Local aTrechos
	Local lGW8VALLIQ := GFXCP12118("GW8_VALLIQ")
	Local lXFBGWUDC := FindFunction("XFBGWUDC")
	Local aRetGXT

	Private cTRBCCF, cTRBITE, cTRBTRE, cTRBTCF, cTRBUNC, cTRBDOC, cTRBAGRU, cTRBSIM, cTRBENT    //variaveis utilizadas na rotina de calculo de frete
	Private aTRBCCF3 := {} // Indice 3
	Private lTabTemp := .F.

	Private idpCCF := 1 // posição do array cTRBCCF
	Private idxCCF := 1 // Indice  da array cTRBCCF
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

	if !GFE50ALINV(aDocSel)
		Return .T.
	EndIf

	if Len(aDocSel) > 0
		//ARRAY de Agrupadores de Frete (Romaneio)
		aAdd(aAgrFrt,{GWN->GWN_NRROM,; //Numero do Agrupador
		GWN->GWN_CDTRP,;  //Transportador
		GWN->GWN_CDTPVC,; //Tipo de Veiculo
		GWN->GWN_CDCLFR,; //Classificacao de Frete
		GWN->GWN_CDTPOP,; //Tipo de Operacao
		GWN->GWN_DISTAN,; //Distancia Percorrida
		GWN->GWN_NRCIDD,; //Cidade Destino
		GWN->GWN_CEPD,;   //CEP Destino
		"0"})   			//ERRO

		for nI:= 1 to Len(aDocSel)
			GW1->(dbSetOrder(01))
			If GW1->(!dbSeek(aDocSel[nI,2] + aDocSel[nI,5] + aDocSel[nI,7] + aDocSel[nI,3] + aDocSel[nI,4]))
				Loop
			EndIf

			//Totaliza unitizadores do documento selecionado
			nQtde := 0
			GWB->(dbSetOrder(02))
			GWB->(dbSeek(xFilial("GWB")+GW1->GW1_CDTPDC+GW1->GW1_EMISDC+GW1->GW1_SERDC+GW1->GW1_NRDC,.T.))
			While GWB->(!Eof()) .And. GWB->GWB_FILIAL == xFilial("GWB") .And. GWB->GWB_CDTPDC == GW1->GW1_CDTPDC .And.;
			GWB->GWB_EMISDC == GW1->GW1_EMISDC .And. GW1->GW1_SERDC == GW1->GW1_SERDC .And. GWB->GWB_NRDC == GW1->GW1_NRDC
				nQtde += GWB->GWB_QTDE
				GWB->(dbSkip())
			EndDo

			//ARRAY de Documentos de Carga
			aAdd(aDocCarg,{	GW1->GW1_EMISDC,; //Emitente do Documento
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
			If lXFBGWUDC			
				aTrechos := XFBGWUDC(,GW1->GW1_FILIAL,GW1->GW1_CDTPDC,GW1->GW1_EMISDC,GW1->GW1_SERDC,GW1->GW1_NRDC)
				For nX := 1 To Len(aTrechos)
					aAdd(aTrchDoc,aClone(aTrechos[nX]))
				Next nX
			Else
				GWU->(dbSetOrder(01))
				GWU->(dbSeek(xFilial("GWU")+GW1->GW1_CDTPDC+GW1->GW1_EMISDC+GW1->GW1_SERDC+GW1->GW1_NRDC,.T.))
				While GWU->(!Eof()) .And. GWU->GWU_FILIAL == xFilial("GWU") .And. GWU->GWU_CDTPDC == GW1->GW1_CDTPDC .And.;
				GWU->GWU_EMISDC == GW1->GW1_EMISDC .And. GWU->GWU_SERDC == GW1->GW1_SERDC .And. GWU->GWU_NRDC == GW1->GW1_NRDC

					//ARRAY de Trechos do Documento
					aAdd(aTrchDoc,{	GWU->GWU_EMISDC,; //Emitente do Documento
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
			While GW8->(!Eof()) .And. GW1->GW1_FILIAL == xFilial("GW8") .And. GW8->GW8_EMISDC == GW1->GW1_EMISDC .And.;
			GW8->GW8_CDTPDC == GW1->GW1_CDTPDC .And. GW8->GW8_SERDC == GW1->GW1_SERDC .And. GW8->GW8_NRDC == GW1->GW1_NRDC

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
		next

		aRetGXT := GFEA50GXT()

		aRet := GFECLCFRT(aAgrFrt,aDocCarg,aTrchDoc,aItDoc,IIF(aRetGXT[1]== .T.,aRetGXT[2],Nil),.F.,2,.F.,.F.,1)    

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
				If Len(aRet) >= 12
					cTRBCCF := aRet[12]
				EndIf

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
			if lTabTemp
				GFEDelTab(cTRBCCF)
				GFEDelTab(cTRBITE) 
				GFEDelTab(cTRBTRE) 
				GFEDelTab(cTRBTCF) 
				GFEDelTab(cTRBUNC) 
				GFEDelTab(cTRBDOC) 
				GFEDelTab(cTRBAGRU)
				GFEDelTab(cTRBENT) 
			Else
				IIF(aTRBCCF3==NIL,,aSize(aTRBCCF3,0))
				aTRBCCF3:= Nil
			EndIf 
			If !Empty(cTRBSIM) 
				GFEDelTab(cTRBSIM) 
			EndIf  
		EndIf
	EndIf
Return

/*
{Protheus.doc} GFEA50TSEL
Função para preencher os totais nos campos do rodapé.

@sample
GFEA50TSEL()

@author Octávio Augusto Felippe de Macedo
@since 31/03/2011
@version 1.0
*/     

Static Function GFEA50TSEL()
	Local nI := 0

	aRdpSel := {0,0,0,0,0,0,0}

	For nI:= 1 To Len(aDocSel)
		aRdpSel[1]++
		aRdpSel[6] += aDocSel[nI,19]
		
		GW8->( dbSetOrder(1) )
		GW8->( dbSeek(aDocSel[nI,02] + aDocSel[nI,05] + aDocSel[nI,07] + aDocSel[nI,03] + aDocSel[nI,04]) )
		While !GW8->( Eof() ) .And. ;
		GW8->GW8_CDTPDC == aDocSel[nI,05] .And. ;
		GW8->GW8_EMISDC == aDocSel[nI,07] .And. ;
		GW8->GW8_SERDC == aDocSel[nI,03]   .And. ;
		GW8->GW8_NRDC == aDocSel[nI,04]

			aRdpSel[2] += GW8->GW8_PESOR
			aRdpSel[3] += GW8->GW8_PESOC
			aRdpSel[4] += GW8->GW8_VOLUME
			aRdpSel[5] += GW8->GW8_VALOR
			aRdpSel[7] += GW8->GW8_QTDALT

			GW8->( dbSkip() )
		EndDo
	Next
Return

/*
{Protheus.doc} GFEA50ACHK
Função para marcar/desmarcar todos os documentos de carga

@sample
GFEA50ACHK(nOp)

@author Octávio Augusto Felippe de Macedo
@since 01/04/2011
@version 1.0
*/ 

Static Function GFEA50ACHK(nOp, aDoc)
	Local nI := 0

	if !GFE50ALINV(aDoc)
		Return .T.
	EndIf

	for nI:= 1 to Len(aDoc)
		if nOp==1 .AND. aDoc[nI,01] == .F.
			aDoc[nI,01] := IIF(nOp==1, .T., .F.)
			GFEA50ARDP(nI)
		ElseIf nOp==2 .AND. aDoc[nI,01] == .T.
			aDoc[nI,01] := IIF(nOp==1, .T., .F.)
			GFEA50ARDP(nI)
		ElseIf nOp==3
			aDoc[nI,01] := !aDoc[nI,01]
			GFEA50ARDP(nI)
		ElseIf nOp==4
			aDoc[nI,01] := !aDoc[nI,01]
		EndIf
	next
	GFEA50RD()
Return

Static Function GFEA50RD()
	Local nCont := 1
	While nCont <= 7
		&("oGetRdp"+AllTrim(Str(nCont))+":Refresh()")
		nCont++
	EndDo
Return

/*
{Protheus.doc} GFEA50ARDP
Função que atualiza o valor do rodapé

@sample
GFEA50ARDP()

@author Octávio Augusto Felippe de Macedo
@since 01/04/2011
@version 1.0
*/

Static Function GFEA50ARDP(nPosicao)

	If aDocFil[nPosicao,01] == .T.

		aRdpDC[1]++

		aRdpDC[6] += aDocFil[nPosicao,19]

		GW8->( dbSetOrder(1) )
		GW8->( dbSeek(aDocFil[nPosicao,02] + aDocFil[nPosicao,05] + aDocFil[nPosicao,07] + aDocFil[nPosicao,03] + aDocFil[nPosicao,04]) )
		While !GW8->( Eof() ) .And. ;
		GW8->GW8_CDTPDC == aDocFil[nPosicao,05] .And. ;
		GW8->GW8_EMISDC == aDocFil[nPosicao,07] .And. ;
		GW8->GW8_SERDC  == aDocFil[nPosicao,03]  .And. ;
		GW8->GW8_NRDC   == aDocFil[nPosicao,04]

			aRdpDC[2] += GW8->GW8_PESOR
			aRdpDC[3] += GW8->GW8_PESOC
			aRdpDC[4] += GW8->GW8_VOLUME
			aRdpDC[5] += GW8->GW8_VALOR
			aRdpDC[7] += GW8->GW8_QTDALT

			GW8->( dbSkip() )
		EndDo
	Else

		aRdpDC[1]--

		aRdpDC[6] -= aDocFil[nPosicao,19]

		GW8->( dbSetOrder(1) )
		GW8->( dbSeek(aDocFil[nPosicao,02] + aDocFil[nPosicao,05] + aDocFil[nPosicao,07] + aDocFil[nPosicao,03] + aDocFil[nPosicao,04]) )
		While !GW8->( Eof() ) .And. GW8->GW8_CDTPDC == aDocFil[nPosicao,05] .And. GW8->GW8_EMISDC == aDocFil[nPosicao,07] .And. GW8->GW8_SERDC == aDocFil[nPosicao,03] ;
		.And. GW8->GW8_NRDC == aDocFil[nPosicao,04]

			aRdpDC[2] -= GW8->GW8_PESOR
			aRdpDC[3] -= GW8->GW8_PESOC
			aRdpDC[4] -= GW8->GW8_VOLUME
			aRdpDC[5] -= GW8->GW8_VALOR
			aRdpDC[7] -= GW8->GW8_QTDALT

			GW8->( dbSkip() )
		EndDo
	EndIf
Return

//Atualiza a situação do cálculo/romaneio para um cálculo ORIGEM 4
Function GFEA050ALI(cNrRoman)
	Local lDCBloq	:= .F.
	Local lCalcSimu	:= .F.
	Local lDifSimu	:= .F.
	Local aAreaGWN	:= GWN->(GetArea())
	Local aAreaGWH	:= GWH->(GetArea())
	Local aAreaGW1	:= GW1->(GetArea())
	Local aRet		:= {.T., ""}
	Local aRetPE 	:= {}
	Local cNumBloq	:= ""
	Local cNumSimu	:= ""

	Default cNrRoman	:= ""

	// Setando a opção de busca para as tabelas que serão utilizadas
	GWF->(dbSetOrder(1))
	GWH->(dbSetOrder(2))
	GWN->(dbSetOrder(1))

	// Caso o parâmetro seja recebido em branco, é utilizada as informações da GW1 que está posicionada
	If Empty(cNrRoman) .And. !Empty(GW1->GW1_NRROM)
		cNrRoman := GW1->GW1_FILIAL + GW1->GW1_NRROM
	EndIf

	If !Empty(cNrRoman)
		// Realiza a busca de todas as GW1 vincualdas ao romaneio
		GW1->(dbSetOrder(9))
		GW1->(dbSeek(cNrRoman))

		While !GW1->(Eof()) .And. cNrRoman == GW1->GW1_FILIAL + GW1->GW1_NRROM
			// Verifica se algum dos documentos de carga está como bloqueado
			If GW1->GW1_SIT == '2'
				lDCBloq := .T.
				cNumBloq += cValToChar(AllTrim(GW1->GW1_NRDC)) + ";"
			EndIf
			// Verificar se existe cálculo vincualado ao documento de carga
			If GWH->(dbSeek(GW1->GW1_FILIAL + GW1->GW1_CDTPDC + GW1->GW1_EMISDC + GW1->GW1_SERDC + GW1->GW1_NRDC))
				// Caso exista cálculo é verificado se é de simulação, se for lCalcSimu igual a .T., senão lDifSimu igual a .T.
				If GWF->(dbSeek(GWH->GWH_FILIAL + GWH->GWH_NRCALC)) .And. GWF->GWF_ORIGEM = '4'
					lCalcSimu 	:= .T.
					cNumSimu   += cValToChar(AllTrim(GW1->GW1_NRDC)) + ";"
				Else
					lDifSimu 	:= .T.
				EndIf
				If lPE505
					aRetPE := ExecBlock("GFEA05A5",.f.,.f.,{GWH->GWH_FILIAL, GWH->GWH_NRCALC, lCalcSimu, lDifSimu})

					If ValType(aRetPE) == "A" .And. !Empty(aRetPE)
						lCalcSimu 	:= aRetPE[1]
						lDifSimu 	:= aRetPE[2]
					EndIf
				EndIf
			Else
				// Senão existe cálculo para o documento de carga, lDifSimu fica igual a .T.
				lDifSimu 	:= .T.
			EndIf

			GW1->(dbSkip())
		EndDo

		// Verificação das variáveis de controle para efetuar o retorno com o erro ou a alteração do romaneio para calculado com sucesso
		If lDCBloq
			// Existe documento de carga bloqueado, é retornado o erro e modificado a situação do romaneio para necessita recálculo
			aRet := {.F., "Não foi possível alterar a situação do cálculo para 'Calculado com sucesso'. Verifique se existem documentos de carga com a situação 'bloqueado'. Documentos Bloqueados: " + cNumBloq}

			GWN->(dbSeek(cNrRoman)) 
			RecLock('GWN', .F. )
			GWN->GWN_CALC   := "4"
			GWN->GWN_MTCALC := ""
			GWN->GWN_DTCALC := DATE()
			GWN->GWN_HRCALC := TIME()
			GWN->(MsUnlock())

			If !Empty(GWN->GWN_VIAGEM) 
				GFE58ATVG(GWN->GWN_VIAGEM,GWN->GWN_CALC,GWN->GWN_MTCALC,GWN->GWN_DTCALC,GWN->GWN_HRCALC,GWN->GWN_FILIAL,GWN->GWN_NRROM)
			EndIf
		Else
			// Verifica se existe documentos de carga com simulação junto aos sem cálculo, caso exista retorna erro e o romaneio fica 
			// como necessita recálculo
			If lCalcSimu .And. lDifSimu
				aRet := {.F., "Não foi possível alterar a situação do cálculo para 'Calculado com sucesso'. Existem documentos de carga vinculados a uma simulação e outros que não possuem cálculo. Para esta situação devem ser criados dois romaneios ou deletado o cálculo de simulação através da rotina do cálculo combinado. Documentos com simulação: " + cNumSimu }

				GWN->(dbSeek(cNrRoman))
				RecLock('GWN', .F. )
				GWN->GWN_CALC   := "4"
				GWN->GWN_MTCALC := ""
				GWN->GWN_DTCALC := DATE()
				GWN->GWN_HRCALC := TIME()
				GWN->(msUnlock())

				If !Empty(GWN->GWN_VIAGEM) 
					GFE58ATVG(GWN->GWN_VIAGEM,GWN->GWN_CALC,GWN->GWN_MTCALC,GWN->GWN_DTCALC,GWN->GWN_HRCALC,GWN->GWN_FILIAL,GWN->GWN_NRROM)
				EndIf				
			Else
				// Se não ocorrer nenhum erro e existir cálculo de simulação, o romaneio passa a calculado com sucesso
				If lCalcSimu
					GWN->(dbSeek(cNrRoman)) 

					RecLock('GWN', .F. )
					GWN->GWN_CALC   := "1"
					GWN->GWN_MTCALC := ""
					GWN->GWN_DTCALC := DDATABASE
					GWN->GWN_HRCALC := SubStr(TIME(), 1, 5)
					GWN->(MsUnlock())

					GW1->(dbSetOrder(9))
					GW1->(dbSeek(cNrRoman))

					While !GW1->(Eof()) .And. cNrRoman == GW1->GW1_FILIAL + GW1->GW1_NRROM

						GWH->(dbSeek(GW1->GW1_FILIAL + GW1->GW1_CDTPDC + GW1->GW1_EMISDC + GW1->GW1_SERDC + GW1->GW1_NRDC))
						// busca pelos cálculos do documento
						While !GWH->(Eof()) .And. GW1->GW1_FILIAL == GWH->GWH_FILIAL;
						.And. GW1->GW1_CDTPDC == GWH->GWH_CDTPDC;
						.And. GW1->GW1_EMISDC == GWH->GWH_EMISDC;
						.And. GW1->GW1_SERDC  == GWH->GWH_SERDC; 
						.And. GW1->GW1_NRDC   == GWH->GWH_NRDC 

							If GWF->(dbSeek(GWH->GWH_FILIAL + GWH->GWH_NRCALC))	.And. GWF->GWF_ORIGEM == '4'
								If Empty(GWF->GWF_NRROM) .And. !Empty(cNrRoman)
									Reclock("GWF",.F.)
									GWF->GWF_NRROM := SubStr(cNrRoman,FWSizeFilial()+1)
									msUnlock("GWF")
								EndIf
							EndIf

							If lPE506
								aRet := ExecBlock("GFEA05A6",.f.,.f.,{GWH->GWH_FILIAL, GWH->GWH_NRCALC, cNrRoman})
							EndIf

							GWH->(dbSkip())
						EndDo
						GW1->(dbSkip())
					EndDo
				EndIf
			EndIf
		EndIf
	EndIf

	RestArea(aAreaGWN)
	RestArea(aAreaGWH)
	RestArea(aAreaGW1)
Return aRet

//Uso do Pergunte GFEA050
Function GFE50VLDP(cTrp)
	Local lRet	:=	.T.

	If cTrp <> GWN->GWN_CDTRP .And. SuperGetMv("MV_GFETRP",.F.,"1") == "2"
		Help(,,'HELP',,'Conforme definido pelos Parâmetros do Módulo, não é permitido redefinir o Transportador das Cargas pelo Romaneio. O Transportador do Romaneio deve ser o mesmo Transportador do primeiro trecho dos Documentos de Carga',1,0)
		lRet := .F.
	EndIf
Return lRet

//Abre uma tela de pesquisa que permite a marcação de documentos de carga na lista superior
Function GFEA050ADC()
	Local aAreaGW1 := GW1->( GetArea() )
	Local aPosEnch := {}
	Local cFilBkp  := cFilAnt
	
	Private cGW1NRDC   := Space(TamSX3("GW1_NRDC"  )[1])
	Private cGW1CDTPDC := Space(TamSX3("GW1_CDTPDC")[1])
	Private cGW1SERDC  := Space(TamSX3("GW1_SERDC" )[1])
	Private cGW1EMISDC := Space(TamSX3("GW1_EMISDC")[1])
	Private oGetNrDc   := Nil
	Private lReload    := .F.
	Private oWind      := Nil
	Private cGW1FIL    := GWN->GWN_FILIAL
	Private oGetFil    := Nil

	SetKey(VK_F10,{||GFEA050ADD()})

	GW1->(dbSetOrder(8))

	oSize := FWDefSize():New(.T.)
	oSize:AddObject( "ENCHOICE", 200, 110, .T., .T. ) // Adiciona enchoice
	oSize:SetWindowSize({000, 000, 150, 600})
	oSize:lLateral     := .F.  // Calculo vertical	
	oSize:Process() //executa os calculos

	aPosEnch := {oSize:GetDimension("ENCHOICE","LININI"),;
	oSize:GetDimension("ENCHOICE","COLINI"),;
	oSize:GetDimension("ENCHOICE","LINEND"),;
	oSize:GetDimension("ENCHOICE","COLEND")}

	DEFINE MSDIALOG oWind TITLE "Busca de documento de carga" ;
	FROM oSize:aWindSize[1],oSize:aWindSize[2] ;
	TO oSize:aWindSize[3],oSize:aWindSize[4] ; 
	PIXEL	

	TSay():New(aPosEnch[1]+010,aPosEnch[2]+0014,{|| "Filial"},oWind,,,,,,.T.,,,50,10,)
	oGetFil := TGet():New(aPosEnch[1]+017,aPosEnch[2]+0014,bSETGET(cGW1FIL),oWind,50,10,"@!",/*bValid*/,,,,,,.T.,,,{||s_MULFIL == "1"}/*bWhen*/,,,{|x| GFEA050FVL(cGW1FIL)}/*bChange*/,.F.,.F.,,"cGW1FIL",,,,.T.)
	oGetFil:cF3 := "SM0"
	
	TSay():New(aPosEnch[1]+010,aPosEnch[2]+065,{|| "Nr Documento"},oWind,,,,,,.T.,,,60,10,)
	oGetNrDc := TGet():New(aPosEnch[1]+017,aPosEnch[2]+065,bSETGET(cGW1NRDC),oWind,60,10,"@!",/*bValid*/,,,,,,.T.,,,/*bWhen*/,,,{|x|GFEA050ASQ()},.F.,.F.,,"cGW1NRDC",,,,.T.)
	oGetNrDc:cF3 := "GFEGW4"

	TSay():New(aPosEnch[1]+010,aPosEnch[2]+125,{|| "Tipo"},oWind,,,,,,.T.,,,50,10,)
	oGet := TGet():New(aPosEnch[1]+017,aPosEnch[2]+125,bSETGET(cGW1CDTPDC),oWind,50,10,"@!",/*bValid*/,,,,,,.T.,,,/*bWhen*/,,,/*bChange*/,.F.,.F.,,"cGW1CDTPDC")

	TSay():New(aPosEnch[1]+010,aPosEnch[2]+180,{|| "Série"},oWind,,,,,,.T.,,,50,10,)
	oGet := TGet():New(aPosEnch[1]+017,aPosEnch[2]+180,bSETGET(cGW1SERDC),oWind,50,10,"@!",/*bValid*/,,,,,,.T.,,,/*bWhen*/,,,/*bChange*/,.F.,.F.,,"cGW1SERDC")

	TSay():New(aPosEnch[1]+010,aPosEnch[2]+235,{|| "Emissor"},oWind,,,,,,.T.,,,50,10,)
	oGet := TGet():New(aPosEnch[1]+017,aPosEnch[2]+235,bSETGET(cGW1EMISDC),oWind,50,10,"@!",/*bValid*/,,,,,,.T.,,,/*bWhen*/,,,/*bChange*/,.F.,.F.,,"cGW1EMISDC")
	oGetNrDc:SetFocus()
	oGetFil:SetFocus()
	oWind:Activate(,,,.T.,,,{|| EnchoiceBar(oWind, {|| GFEA050ADD() }, {|| lReload := .F., oWind:End() },,)})
	SetKey(VK_F10,{||})
	RestArea(aAreaGW1)
	If lReload
		lReload := .F.
		oPanelB:Refresh()
		GFEA050ADC()
	EndIf
	cFilAnt := cFilBkp
Return

//Busca e marca um documento na lista acima. se não achar, pergunta se o usuário deseja adicionar mesmo assim.
Function GFEA050ADD()
	Local nPos := 0
	Local cQuery 
	Local cGW1 
	local lRetPE := .F.

	if aScan(aDocSel,{|x| 	x[05] == cGW1CDTPDC .AND. ;
	x[07] == cGW1EMISDC .AND. ;
	x[03] == cGW1SERDC  .AND. ;
	x[04] == cGW1NRDC},1,1) > 0
		Help(,,'HELP',,'Documento de carga já está relacionado ao Romaneio.',1,0)
		Return
	EndIf

	nPos := aScan(aDocFil,{|x| 	x[05] == cGW1CDTPDC .AND. ;
	x[07] == cGW1EMISDC .AND. ;
	x[03] == cGW1SERDC  .AND. ;
	x[04] == cGW1NRDC})

	If nPos > 0
		aDocFil[nPos,01] := .T.
		GFEA50AOK()
	Else
		GWU->(dbSetOrder(1))
		If GWU->(dbSeek(cGW1FIL+cGW1CDTPDC+cGW1EMISDC+cGW1SERDC+cGW1NRDC+'01'))
			If GWN->GWN_CDTRP <> GWU->GWU_CDTRP
				If SuperGetMv("MV_GFETRP",.F.,"1") == "2"
					Help(,,'HELP',,'Conforme definido pelo Parâmetro do Módulo, não é permitido redefinir o Transportador da Carga pelo Romaneio. O Transportador do Romaneio deve ser o mesmo Transportador do primeiro trecho do Documento de Carga',1,0)
					Return
				Else
					If lPE507
						lRetPE := ExecBlock("GFEA05A7",.F.,.F.)
					Endif
					If !lRetPE
						If !MsgYesNo("O Transportador do Romaneio difere do primeiro trecho do Documento de Carga. Confirma redefinição do transportador do primeiro trecho?")
							Return
						EndIf
					Endif
				EndIf
			EndIf

			cQuery := "SELECT GW1.GW1_FILIAL FILIAL, GW1.GW1_SERDC SERIE, GW1.GW1_NRDC NRDC, GW1.GW1_CDTPDC TPDC, "
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
			cQuery += " 		END) UFDEST, "	
			cQuery += " 		GW1.GW1_QTVOL, GW1.GW1_NRROM, GW1.GW1_SIT, GV5DOC.GV5_SENTID, GV4DOC.GV4_SENTID "	
			cQuery += "FROM " + RetSQLName("GW1") + " GW1 "
			cQuery += "INNER JOIN " + RetSQLName("GU3") + " GU3EMI  ON GU3EMI.GU3_FILIAL  = '" + xFilial("GU3") + "' AND GU3EMI.GU3_CDEMIT = GW1.GW1_EMISDC   AND GU3EMI.D_E_L_E_T_ = ' ' "
			cQuery += "INNER JOIN " + RetSQLName("GU3") + " GU3REM  ON GU3REM.GU3_FILIAL  = '" + xFilial("GU3") + "' AND GU3REM.GU3_CDEMIT = GW1.GW1_CDREM    AND GU3REM.D_E_L_E_T_ = ' ' "
			cQuery += "INNER JOIN " + RetSQLName("GU3") + " GU3DES  ON GU3DES.GU3_FILIAL  = '" + xFilial("GU3") + "' AND GU3DES.GU3_CDEMIT = GW1.GW1_CDDEST   AND GU3DES.D_E_L_E_T_ = ' ' "
			cQuery += "LEFT  JOIN " + RetSQLName("GU7") + " GU7DEST ON GU7DEST.GU7_FILIAL = '" + xFilial("GU7") + "' AND GU7DEST.GU7_NRCID = GU3DES.GU3_NRCID AND GU7DEST.D_E_L_E_T_ = ' ' "
			cQuery += "LEFT  JOIN " + RetSQLName("GU7") + " GU7DOC  ON GU7DOC.GU7_FILIAL  = '" + xFilial("GU7") + "' AND GU7DOC.GU7_NRCID  = GW1.GW1_ENTNRC   AND GU7DOC.D_E_L_E_T_ = ' ' "
			cQuery += "LEFT  JOIN " + RetSQLName("GV5") + " GV5DOC  ON GV5DOC.GV5_FILIAL  = '" + xFilial("GV5") + "' AND GV5DOC.GV5_CDTPDC = GW1.GW1_CDTPDC   AND GV5DOC.D_E_L_E_T_ = ' ' "
			cQuery += "LEFT  JOIN " + RetSQLName("GV4") + " GV4DOC  ON GV4DOC.GV4_FILIAL  = '" + xFilial("GV4") + "' AND GV4DOC.GV4_CDTPOP = '" +GWN->GWN_CDTPOP+ "' AND GV4DOC.D_E_L_E_T_ = ' ' " 
			
			cQuery += " WHERE GW1.GW1_FILIAL = '" + cGW1FIL + "'"
			cQuery += " AND GW1.GW1_CDTPDC = '" + cGW1CDTPDC + "'"
			cQuery += " AND GW1.GW1_EMISDC = '" + cGW1EMISDC + "'"
			cQuery += " AND GW1.GW1_SERDC = '" + cGW1SERDC + "'"
			cQuery += " AND GW1.GW1_NRDC = '" + cGW1NRDC + "'"
			cQuery += " AND GW1.D_E_L_E_T_ = ' '"

			cQuery := ChangeQuery(cQuery)
			cGW1 := GetNextAlias()

			dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cGW1, .F., .T.)
			dbSelectArea(cGW1)

			If !Empty((cGW1)->GW1_NRROM) .And. (cGW1)->GW1_NRROM != GWN->GWN_NRROM
				Help(,,'HELP',,'Documento de carga já está relacionado a outro Romaneio.',1,0)
				(cGW1)->( dbCloseArea() )
				Return
			EndIf
			If (cGW1)->GW1_SIT != "3"
				Help(,,'HELP',,'Documento de carga deve estar liberado.',1,0)
				(cGW1)->( dbCloseArea() )
				Return
			EndIf
			If !((cGW1)->GV5_SENTID == (cGW1)->GV4_SENTID .Or. (cGW1)->GV4_SENTID == '0')
				Help(,,'HELP',,'Sentido da carga deve ser o mesmo do documento de carga.',1,0)
				(cGW1)->( dbCloseArea() )
				Return
			EndIf

			AaDD(aDocFil,{.T.,;
						  (cGW1)->FILIAL  ,; 
						  (cGW1)->SERIE   ,;
						  (cGW1)->NRDC    ,;
						  (cGW1)->TPDC    ,;
						  (cGW1)->TPFRET  ,;
						  (cGW1)->CDEMIS  ,;
						  (cGW1)->NMEMIS  ,;
						  (cGW1)->CDREM   ,;
						  (cGW1)->NMREM   ,;
						  (cGW1)->CDDEST  ,; 
						  (cGW1)->NMDEST  ,;
						  (cGW1)->NRREG   ,;
						  (cGW1)->NRCID   ,;
						  (cGW1)->DTEMIS  ,;
						  (cGW1)->DTSAI   ,;
						  (cGW1)->CIDDES  ,;
						  (cGW1)->UFDEST  ,;
						  (cGW1)->GW1_QTVOL })
			(cGW1)->( dbCloseArea() )
			GFEA50AOK()
		Else
			Help(,,'HELP',,'Documento de carga não localizado',1,0)
			Return
		EndIf
	EndIf

	cGW1NRDC   := Space(TamSX3("GW1_NRDC"  )[1])
	cGW1CDTPDC := Space(TamSX3("GW1_CDTPDC")[1])
	cGW1SERDC  := Space(TamSX3("GW1_SERDC" )[1])
	cGW1EMISDC := Space(TamSX3("GW1_EMISDC")[1])

	oGetNrDc:SetFocus()
	oGetFil:SetFocus()
	lReload := .T.
	oWind:End()
Return

//Pesquisa e preenche os outros campos se achar um documento de carga válido pelo número
Function GFEA050ASQ()
	Local cAliasQ
	Local cQuery 	:= ""
	Local aDCMark 	:= {}
	Local nI 		:= 0
	
	For nI:= 1 To Len(aDocSel)
		aAdd(aDCMark,aDocSel[nI,5] + aDocSel[nI,7] + aDocSel[nI,3] + aDocSel[nI,4])
	Next

	cQuery := "SELECT GW1.GW1_FILIAL, GW1.GW1_SERDC SERIE, GW1.GW1_NRDC NRDC, GW1.GW1_CDTPDC TPDC, GW1.GW1_EMISDC CDEMIS"
	cQuery += "  FROM " + RetSQLName("GW1") + " GW1 "
	cQuery += " INNER JOIN " + RetSQLName("GV5") + " GV5 ON GV5.GV5_FILIAL = '" + xFilial("GV5") + "' AND GV5.GV5_CDTPDC = GW1.GW1_CDTPDC AND GV5.D_E_L_E_T_ = ' '"
	cQuery += " INNER JOIN " + RetSQLName("GWU") + " GWU ON GWU.GWU_FILIAL = '" + xFilial("GWU") + "' AND GWU.GWU_CDTPDC = GW1.GW1_CDTPDC AND GWU.GWU_EMISDC = GW1.GW1_EMISDC AND GWU.GWU_SERDC = GW1.GW1_SERDC AND GWU.GWU_NRDC = GW1.GW1_NRDC AND GWU.GWU_SEQ = '01' AND GWU.D_E_L_E_T_ = ' '"
	cQuery += " INNER JOIN " + RetSQLName("GV4") + " GV4 ON GV4.GV4_FILIAL = '" + xFilial("GV4") + "' AND GV4.GV4_CDTPOP = '" + GWN->GWN_CDTPOP + "' AND GV4.D_E_L_E_T_ = ' ' "
	cQuery += "  LEFT JOIN " + RetSQLName("GW4") + " GW4 ON GW4.GW4_FILIAL = '" + xFilial("GW4") + "' AND GW4.GW4_TPDC = GW1.GW1_CDTPDC AND GW4.GW4_EMISDC = GW1.GW1_EMISDC AND GW4.GW4_SERDC = GW1.GW1_SERDC AND GW4.GW4_NRDC = GW1.GW1_NRDC  AND GW4.D_E_L_E_T_ = ' '"
	cQuery += " WHERE GW1.GW1_SIT = '3'" 
	cQuery += "   AND GW1.GW1_NRDC = '" + cGW1NRDC + "'"
	cQuery += "	  AND (GW1.GW1_NRROM = '' OR GW1.GW1_NRROM = '0') AND (GV5.GV5_SENTID = GV4.GV4_SENTID OR GV4.GV4_SENTID = '0')"
	cQuery += "	  AND (GV5.GV5_SENTID = GV4.GV4_SENTID OR GV4.GV4_SENTID = '0')"
	cQuery += "	AND GW1.GW1_FILIAL = '" +cGW1FIL+ "'"
	cQuery += "	AND GW4.GW4_NRDF IS NULL AND GW1.D_E_L_E_T_ = ' ' "
	cQuery += "	ORDER BY GW1.GW1_NRDC"
	cAliasQ := GetNextAlias()
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQ, .F., .T.)
	While !(cAliasQ)->(Eof())
		If aScan(aDCMark,{|x| x == (cAliasQ)->(TPDC+CDEMIS+SERIE+NRDC)}) == 0
			cGW1NRDC	:= (cAliasQ)->NRDC
			cGW1CDTPDC	:= (cAliasQ)->TPDC
			cGW1SERDC	:= (cAliasQ)->SERIE
			cGW1EMISDC	:= (cAliasQ)->CDEMIS
			(cAliasQ)->(dbCloseArea())
			Return
		EndIf
		(cAliasQ)->(dbSkip())
	EndDo
	(cAliasQ)->(dbCloseArea())
Return

Static Function GFEA50AD(nAt)
	If !GFE50ALINV(aDocFil)
		Return .T.
	EndIf

	If Len(aDocFil) > 0
		aDocFil[nAt,1] := !aDocFil[nAt,1]
		GFEA50ARDP(nAt)
		GFEA50RD()
	EndIf
Return

Static Function GFEA50AE(nAt)
	If !GFE50ALINV(aDocSel)
		Return .T.
	EndIf
	
	If Len(aDocSel) > 0
		aDocSel[nAt,1] := !aDocSel[nAt,1]
	EndIf
Return

Static function GFE50ASORT(lDocFil,lDocSel)
	Local cOrdemPE1 := ""
	Local cOrdemPE2 := ""

	If ExistBlock("GFEA05A2")
		cOrdemPE1 := ExecBlock("GFEA05A2",.f.,.f., {"1"}) 
	EndIf

	If ExistBlock("GFEA05A2")
		cOrdemPE2 := ExecBlock("GFEA05A2",.f.,.f., {"2"}) 
	EndIf

	cOrdDocCa := GFEArrOrd(cOrdemPE1)
	cOrdDocC2 := GFEArrOrd(cOrdemPE2)

	If lDocFil
		If Len(aDocFil) > 0
			aSort(aDocFil,,,{|x,y| &(cOrdDocCa)})
		EndIf
	EndIf
	If lDocSel
		If Len(aDocSel) > 0
			aSort(aDocSel,,,{|x,y| &(cOrdDocC2)})
		EndIf
	EndIf
Return .T.

Static Function GFEArrOrd(cOrdemPE)

	Local aOrdemPE := {}
	Local cOrdDocx := ""
	Local cOrdDocy := ""
	Local cOrdDC := ""
	Local nI

	If !Empty(cOrdemPE)
		aOrdemPE := StrToKArr(cOrdemPE, ';')

		cOrdDocx := "x[" + aOrdemPE[1] + "]" 
		cOrdDocy := "y[" + aOrdemPE[1] + "]"

		For nI:= 2 to Len(aOrdemPE)
			cOrdDocx += "+x[" + aOrdemPE[nI] + "]" 
			cOrdDocy += "+y[" + aOrdemPE[nI] + "]" 
		Next

		cOrdDC := cOrdDocx + " < " + cOrdDocy
	Else
		cOrdDC := "x[4]+x[6]+x[2]+x[3] < y[4]+y[6]+y[2]+y[3]"
	EndIf
Return cOrdDC

Static Function GFE50ADELARRAY(aDoc)
	if !GFE50ALINV(aDoc)
		aDel(aDoc,1)
		ASize(aDoc,0)
	EndIf
Return .T.

Static Function GFE50ALINV(aDoc)
	If Len(aDoc) = 1
		chkSerieEmpty(@aDoc)	// Adiciona caracter na serie
		If Empty(aDoc[1,3])
			Return .F.
		EndIf
		chkSerieEmpty(@aDoc)	// remove caracter na serie
	EndIf
Return .T.

Function GFEA050FVL(cGW1FIL)
	IF cGW1FIL == cFilAnt
		Return .F.
	Else 
		cFilAnt := cGW1FIL
	EndIf
Return .T.

Static Function chkSerieEmpty(aDoc)
	Local nI        := 0
	Local cTamSerie := Space(TamSx3("GW1_SERDC")[1])

	For nI := 1 To Len(aDoc)
		If Empty(aDoc[nI][3]) .And. (!Empty(aDoc[nI][2]) .And. !Empty(aDoc[nI][5]) .And. !Empty(aDoc[nI][7]) .And. !Empty(aDoc[nI][4]))
			aDoc[nI][3] := "-"
		ElseIf Alltrim(aDoc[nI][3]) = "-" .And. (!Empty(aDoc[nI][2]) .And. !Empty(aDoc[nI][5]) .And. !Empty(aDoc[nI][7]) .And. !Empty(aDoc[nI][4]))
			aDoc[nI][3] := cTamSerie
		EndIf
	Next
Return
