#Include "PROTHEUS.CH"

//--------------------------------------------------------------
/*/{Protheus.doc} GFEX101
Simulação basica de Calculo de frete
                                                                
@return xRet Return Description
@author  -                                               
@since 22/02/2012                                                   
/*/
//--------------------------------------------------------------

Main Function GFEX011()
	Local oGet1,oGet2,oGet3,oGet4,oGet5,oGet6,oGet7,oGet8,oGet9,oGet10,oGet11,oGet12,oGet13,oGet14,oGet15,oGet16,oGet17,oGet18,oGet19,oGet20
	Local oCombo
	Local oGroup1,oGroup2
	Local oSay1,oSay2,oSay3,oSay4,oSay5,oSay6,oSay7,oSay8,oSay9,oSay10,oSay11,oSay12,oSay13
	Local cDesTpOp
	Local cDesClFr
	Local cDesRem
	Local cDesTpVc
	Local cDsDest
	Local aCampos
	Local lClearEnv := .F.
	Local oSize
	Local aPosEnch
	Local aCombo := {"1=Sim","2=Não"}
	Local cDsCidOri
	Local cDsCidDest
	Local cDsTrp
	Private cTpOp 
	Private nVlFrt
	Private cCdClFr 
	Private nPsReal
	Private nVolume 
	Private cCodRem
	Private cCodDes
	Private cCdTpVc
	Private oDlg,oListbox,cAlias
	Private oMsgBar   
	Private cSitTab
	
	Static cCidOri
	Static cCidDest
	Static cCdTrp 
	
	// Abertura de ambiente só pode ser executada se o programa não for acessado pelo GFE/Protheus
	If Select("SM0") <= 0 
	    OpenSM0()

		dbSelectArea( "SM0" )
		dbGoTop()
		
		RpcSetType( 3 )
		RpcSetEnv( SM0->M0_CODIGO, SM0->M0_CODFIL )
		lClearEnv := .T.	
	EndIf
	
	// Habilita a skin padrão dos componentes visuais
	SetSkinDefault()
	
	aCampos := {{"CDTRP"  ,"C",14,0},;
				{"DSTRP"  ,"C",50,0},;
				{"VLCALC" ,"N",15,2},;
				{"DTPRE"  ,"D",8,0}}     
 
	cAlias := GFECriaTab({aCampos,{"CDTRP"}})  
	
	dbSelectArea(cAlias)
	ZAP
	
    cTpOp 	 := PADR(AllTrim(GetMv("MV_TPOPEMB")), TamSX3("GWN_CDTPOP")[1]) 
	cCdClFr  := PADR(AllTrim(GetMv("MV_CDCLFR")), TamSX3("GWN_CDCLFR")[1])
	cCdTpVc  := SPACE(TamSX3("GWU_CDTPVC")[1]) 
	nVlFrt   := 0
	nPsReal  := 0
	nVolume  := 0
	nDistan  := 0
	cCodRem  := SPACE(TamSX3("GU3_CDEMIT")[1]) 
	cCodDes  := SPACE(TamSX3("GW1_CDDEST")[1])
	cDesClFr := AllTrim(POSICIONE("GUB",1,xFilial("GUB")+cCdClFr,"GUB_DSCLFR"))
	cDesTpOp := AllTrim(POSICIONE("GV4",1,xFilial("GV4")+cTpOp  ,"GV4_DSTPOP"))
	cCidOri  := SPACE(TamSX3("GU7_NRCID")[1])
	cCidDest := SPACE(TamSX3("GU7_NRCID")[1])
	cCdTrp   := SPACE(TamSX3("GU3_CDEMIT")[1])
	
	oSize := FWDefSize():New(.T.)
	oSize:AddObject( "ENCHOICE", 100, 60, .T., .T. ) // Adiciona enchoice
	oSize:SetWindowSize({000, 000, 750, 1000})
	oSize:lLateral := .F.  // Calculo vertical	
	oSize:Process() //executa os calculos
	
	aPosEnch := {oSize:GetDimension("ENCHOICE","LININI"),;
                 oSize:GetDimension("ENCHOICE","COLINI"),;
                 oSize:GetDimension("ENCHOICE","LINEND"),;
                 oSize:GetDimension("ENCHOICE","COLEND")}
	
	DEFINE MSDIALOG oDlg TITLE "Simulação de Fretes Simplificada" ;
							FROM oSize:aWindSize[1],oSize:aWindSize[2] ;
							TO oSize:aWindSize[3],oSize:aWindSize[4] ; 
							OF oMainWnd PIXEL
							
   	@ aPosEnch[1]+002, aPosEnch[2]+020 SAY oSay1  PROMPT "Tipo Operação" 		  	SIZE 050, 010 OF oDlg PIXEL
   	@ aPosEnch[1]+002, aPosEnch[2]+240 SAY oSay2  PROMPT "Classificação Frete" 		SIZE 050, 010 OF oDlg PIXEL
   	@ aPosEnch[1]+027, aPosEnch[2]+020 SAY oSay8  PROMPT "Tipo de Veículo"        	SIZE 050, 010 OF oDlg PIXEL 
   	@ aPosEnch[1]+053, aPosEnch[2]+020 SAY oSay3  PROMPT "Valor Total Carga" 	 	SIZE 057, 010 OF oDlg PIXEL
   	@ aPosEnch[1]+053, aPosEnch[2]+087 SAY oSay4  PROMPT "Peso Total Carga (Kg)"   	SIZE 078, 010 OF oDlg PIXEL
   	@ aPosEnch[1]+053, aPosEnch[2]+145 SAY oSay7  PROMPT "Volume Total Carga (m³)"	SIZE 078, 010 OF oDlg PIXEL
   	@ aPosEnch[1]+053, aPosEnch[2]+220 SAY oSay10 PROMPT "Percurso (Km)" 		  	SIZE 078, 010 OF oDlg PIXEL
    @ aPosEnch[1]+077, aPosEnch[2]+020 SAY oSay6  PROMPT "Cod. Remetente" 		  	SIZE 057, 010 OF oDlg PIXEL 
   	@ aPosEnch[1]+077, aPosEnch[2]+257 SAY oSay5  PROMPT "Cod. Destinatário"       	SIZE 057, 010 OF oDlg PIXEL
   	@ aPosEnch[1]+102, aPosEnch[2]+020 SAY oSay9  PROMPT "Considera Negociação?"    SIZE 065, 010 OF oDlg PIXEL
   	@ aPosEnch[1]+127, aPosEnch[2]+020 SAY oSay11 PROMPT "Cidade Origem"       		SIZE 057, 010 OF oDlg PIXEL
   	@ aPosEnch[1]+127, aPosEnch[2]+257 SAY oSay12 PROMPT "Cidade Destino"       	SIZE 057, 010 OF oDlg PIXEL
   	@ aPosEnch[1]+152, aPosEnch[2]+020 SAY oSay13 PROMPT "Transportador"       		SIZE 057, 010 OF oDlg PIXEL
  
  
   	@ aPosEnch[1]+012, aPosEnch[2]+020 MSGET oGet1     VAR cTpOp 	  SIZE 045, 010 OF oDlg PICTURE "@!" F3 "GV4" Valid GFEX011Desc(1,cTpOp,@cDesTpOp) PIXEL hasbutton
   	@ aPosEnch[1]+012, aPosEnch[2]+070 MSGET oGet2     VAR cDesTpOp   SIZE 156, 010 OF oDlg PICTURE "@!" READONLY PIXEL
   	@ aPosEnch[1]+012, aPosEnch[2]+240 MSGET oGet3     VAR cCdClFr 	  SIZE 045, 010 OF oDlg PICTURE "@!" F3 "GUB" Valid GFEX011Desc(2,cCdClFr,@cDesClFr) PIXEL hasbutton
	@ aPosEnch[1]+012, aPosEnch[2]+290 MSGET oGet4     VAR cDesClFr   SIZE 156, 010 OF oDlg PICTURE "@!" READONLY PIXEL 
	@ aPosEnch[1]+037, aPosEnch[2]+020 MSGET oGet12    VAR cCdTpVc 	  SIZE 045, 010 OF oDlg PICTURE "@!" F3 "GV3" Valid GFEX011Desc(4,cCdTpVc,@cDesTpVc) PIXEL hasbutton
	@ aPosEnch[1]+037, aPosEnch[2]+070 MSGET oGet13    VAR cDesTpVc   SIZE 156, 010 OF oDlg PICTURE "@!" READONLY PIXEL     
   	@ aPosEnch[1]+063, aPosEnch[2]+020 MSGET oGet5     VAR nVlFrt  	  SIZE 055, 010 OF oDlg PICTURE PESQPICT("GW8", "GW8_VALOR")  PIXEL hasbutton
   	@ aPosEnch[1]+063, aPosEnch[2]+087 MSGET oGet6     VAR nPsReal 	  SIZE 055, 010 OF oDlg PICTURE PESQPICT("GW8", "GW8_PESOR")  PIXEL hasbutton
   	@ aPosEnch[1]+063, aPosEnch[2]+145 MSGET oGet11    VAR nVolume 	  SIZE 055, 010 OF oDlg PICTURE PESQPICT("GW8", "GW8_VOLUME") PIXEL hasbutton
   	@ aPosEnch[1]+063, aPosEnch[2]+220 MSGET oGet14    VAR nDistan 	  SIZE 055, 010 OF oDlg PICTURE PESQPICT("GWN", "GWN_DISTAN") PIXEL hasbutton
    @ aPosEnch[1]+087, aPosEnch[2]+020 MSGET oGet7     VAR cCodRem 	  SIZE 060, 010 OF oDlg PICTURE "@!" F3 "GU3" Valid GFEX011Desc(3,cCodRem,@cDesRem) PIXEL hasbutton
   	@ aPosEnch[1]+087, aPosEnch[2]+087 MSGET oGet8     VAR cDesRem 	  SIZE 155, 010 OF oDlg PICTURE "@!" READONLY PIXEL
   	@ aPosEnch[1]+087, aPosEnch[2]+257 MSGET oGet9     VAR cCodDes 	  SIZE 060, 010 OF oDlg PICTURE "@!" F3 "GU3" Valid GFEX011Desc(3,cCodDes,@cDsDest)PIXEL hasbutton
   	@ aPosEnch[1]+087, aPosEnch[2]+317 MSGET oGet10    VAR cDsDest 	  SIZE 155, 010 OF oDlg PICTURE "@!" READONLY PIXEL
    @ aPosEnch[1]+112, aPosEnch[2]+020 COMBOBOX oCombo VAR cSitTab    ITEMS aCombo	SIZE 080, 010 OF oDlg PIXEL 
    @ aPosEnch[1]+137, aPosEnch[2]+020 MSGET oGet15    VAR cCidOri 	  SIZE 060, 010 OF oDlg PICTURE "@!" F3 "GU7GUA" Valid GFEX011Desc(5,cCidOri,@cDsCidOri) PIXEL hasbutton
   	@ aPosEnch[1]+137, aPosEnch[2]+087 MSGET oGet16    VAR cDsCidOri  SIZE 155, 010 OF oDlg PICTURE "@!" READONLY PIXEL
   	@ aPosEnch[1]+137, aPosEnch[2]+257 MSGET oGet17    VAR cCidDest   SIZE 060, 010 OF oDlg PICTURE "@!" F3 "GU7GUA" Valid GFEX011Desc(5,cCidDest,@cDsCidDest) PIXEL hasbutton
   	@ aPosEnch[1]+137, aPosEnch[2]+317 MSGET oGet18    VAR cDsCidDest SIZE 155, 010 OF oDlg PICTURE "@!" READONLY PIXEL
   	@ aPosEnch[1]+162, aPosEnch[2]+020 MSGET oGet19    VAR cCdTrp 	  SIZE 060, 010 OF oDlg PICTURE "@!" F3 "GU3TRP" Valid GFEX011Desc(3,cCdTrp,@cDsTrp) PIXEL hasbutton
    @ aPosEnch[1]+162, aPosEnch[2]+087 MSGET oGet20    VAR cDsTrp 	  SIZE 155, 010 OF oDlg PICTURE "@!" READONLY PIXEL
   	    
	oMsgBar := TMsgBar():New(oDlg, "",.F.,.F.,.F.,.F., RGB(116,116,116),,,.F.)
    
	dbSelectArea(cAlias)
    
    @ aPosEnch[1]+187, aPosEnch[2]+020 LISTBOX oListbox FIELDS (cAlias)->CDTRP,(cAlias)->DSTRP,Transform((cAlias)->VLCALC,"@E 999,999,999.99"),(cAlias)->DTPRE ;
    			HEADER "Cod. Transp","Nome Transp","Frete Previsto","Prev Entrega" SIZE 450, 100 OF oDlg PIXEL ColSizes 75,225,75,75
	 
   	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(ODlg,{||RptStatus( {|| GFEX011SIM()}, "Aguarde...","Executando Simulação de Frete.", .T. )},{||ODlg:End()},,) CENTERED  
	
	GFEDelTab(cAlias)
	
	If lClearEnv
		RpcClearEnv()
	EndIf
Return

/*Valida e aplica o gatilho da descrição*/
Static Function GFEX011Desc(nOp,cCod,cDesc)
	Local lRet := .T.

	If nOp == 1 //Tipo de Operação 
		If !Empty(cCod)
			If GFEExistC("GV4",,cCod,"GV4->GV4_SIT=='1'")               
		   		cDesc := POSICIONE("GV4",1,xFilial("GV4")+cCod,"GV4_DSTPOP") 
	   		Else
		   		lRet := .F.
		   	EndIf  
	   	Else
	   		cDesc := ''
	   	EndIf  
	ElseIf nOp == 2 // Classificação de Frete      
		If !Empty(cCod)
			If GFEExistC("GUB",,cCod,"GUB->GUB_SIT=='1'")
		   		cDesc := POSICIONE("GUB",1,xFilial("GUB")+cCod,"GUB_DSCLFR") 
	   		Else
	    		lRet := .F.
	   		EndIf 
	   	Else
	   		cDesc := ''
	   	EndIf  
	ElseIf nOp == 3  // Destinatario e remetente
		If !Empty(cCod)
			If GFEExistC("GU3",,cCod,"GU3->GU3_SIT=='1'")
		   		cDesc := POSICIONE("GU3",1,xFilial("GU3")+cCod,"GU3_NMEMIT")    
		 	Else
		   		lRet := .F.
		 	EndIf
		 Else
		 	cDesc := ""
		 EndIf
    ElseIf nOp == 4  // Tipo de Veículo
    	If !Empty(cCod)
    		If GFEExistC("GV3",,cCod,"GV3->GV3_SIT=='1'")
		   		cDesc := POSICIONE("GV3",1,xFilial("GV3")+cCod,"GV3_DSTPVC")
		   	Else
		   		lRet := .F.
		 	EndIf
		Else
			cDesc := ""
    	EndIf
    ElseIf nOp == 5  // Cidade
    	If !Empty(cCod)
    		If GFEExistC("GU7",,cCod,"GU7->GU7_SIT=='1'")
		   		cDesc := POSICIONE("GU7",1,xFilial("GU7")+cCod,"GU7_NMCID")
		   	Else
		   		lRet := .F.
		 	EndIf
		Else
			cDesc := ""
    	EndIf
	EndIf
	
	If !lRet 
		oMsgBar:SetMsg("Não existe registro relacionado a este codigo. Informe um código que exista no cadastro.")
	Else
		oMsgBar:SetMsg("")
	EndIf
Return lRet  

/*Simula*/

Static Function GFEX011SIM()
	Local oModelSim 		:= FWLoadModel("GFEX010")
	Local oModelNeg  		:= oModelSim:GetModel("GFEX010_01")
	Local oModelAgr  		:= oModelSim:GetModel("DETAIL_01")  // oModel do grid "Agrupadores"
	Local oModelDC   		:= oModelSim:GetModel("DETAIL_02")  // oModel do grid "Doc Carga"
	Local oModelIt   		:= oModelSim:GetModel("DETAIL_03")  // oModel do grid "Item Carga"
	Local oModelTr   		:= oModelSim:GetModel("DETAIL_04")  // oModel do grid "Trechos"
	Local oModelInt  		:= oModelSim:GetModel("SIMULA")
	Local oModelCal1 		:= oModelSim:GetModel("DETAIL_05")
	Local oModelCal2 		:= oModelSim:GetModel("DETAIL_06")
	Local nCont, nRegua 	:= 0
	
	oModelSim:SetOperation(3)
	oModelSim:Activate() 
	
	SetRegua(nRegua)   
	
	dbSelectArea("GV5")
	dbSetOrder(3)
	dbSeek(xFilial("GV5")+"1")   
	
	oModelNeg:LoadValue('CONSNEG', cSitTab )
	IncRegua()
	//Agrupadores
		oModelAgr:LoadValue('GWN_NRROM' , "01" )
		oModelAgr:LoadValue('GWN_CDCLFR', cCdClFr)                                   
		oModelAgr:LoadValue('GWN_CDTPOP', cTpOp)
		oModelAgr:LoadValue('GWN_DOC'   , "ROMANEIO")  
		oModelAgr:LoadValue('GWN_DISTAN', nDistan)             
	//Documento de Carga
		oModelDC:LoadValue('GW1_EMISDC', cCodRem)
		oModelDC:LoadValue('GW1_NRDC'  , "00001")
		oModelDC:LoadValue('GW1_CDTPDC', GV5->GV5_CDTPDC)
		oModelDC:LoadValue('GW1_CDREM' , cCodRem)
		oModelDC:LoadValue('GW1_CDDEST', cCodDes)
		oModelDC:LoadValue('GW1_TPFRET', "1")
		oModelDC:LoadValue('GW1_ICMSDC', "2")
		oModelDC:LoadValue('GW1_USO'   , "1")
		oModelDC:LoadValue('GW1_NRROM' , "01")
		oModelDC:LoadValue('GW1_QTUNI' , 1)   
	//Trechos
		oModelTr:LoadValue('GWU_EMISDC', cCodRem)
		oModelTr:LoadValue('GWU_NRDC'  , "00001")
		oModelTr:LoadValue('GWU_CDTPDC', GV5->GV5_CDTPDC)
		oModelTr:LoadValue('GWU_SEQ'   , "01")
		If !Empty(cCidOri)
			oModelTr:LoadValue('GWU_NRCIDO', cCidOri)
		Else
			oModelTr:LoadValue('GWU_NRCIDO', POSICIONE("GU3",1,xFilial("GU3")+cCodRem,"GU3_NRCID"))
		EndIf

		oModelTr:LoadValue('GWU_CEPO', POSICIONE("GU3",1,xFilial("GU3")+cCodRem,"GU3_CEP"))

		If !Empty(cCidDest)
			oModelTr:LoadValue('GWU_NRCIDD', cCidDest)
		Else
			oModelTr:LoadValue('GWU_NRCIDD', POSICIONE("GU3",1,xFilial("GU3")+cCodDes,"GU3_NRCID"))
		EndIf

		oModelTr:LoadValue('GWU_CEPD', POSICIONE("GU3",1,xFilial("GU3")+cCodDes,"GU3_CEP"))

		If !Empty(cCdTrp)
			oModelTr:LoadValue('GWU_CDTRP', cCdTrp)
		EndIf
		
		oModelTr:LoadValue('GWU_CDTPVC', cCdTpVc)
	//Itens								
		oModelIt:LoadValue('GW8_EMISDC', cCodRem)
		oModelIt:LoadValue('GW8_NRDC'  , "00001")
		oModelIt:LoadValue('GW8_CDTPDC', GV5->GV5_CDTPDC)
		oModelIt:LoadValue('GW8_ITEM'  , "ItemA"  )
		oModelIt:LoadValue('GW8_DSITEM', "Item Generico")
		oModelIt:LoadValue('GW8_CDCLFR', cCdClFr)
		oModelIt:LoadValue('GW8_PESOR' , nPsReal)
		oModelIt:LoadValue('GW8_VALOR' , nVlFrt)
		oModelIt:LoadValue('GW8_VOLUME', nVolume)	
		oModelIt:LoadValue('GW8_TRIBP' , "1")
   	// Dispara a simulação
		oModelInt:SetValue("INTEGRA", "A")
	IncRegua()
	dbSelectArea(cAlias)
	ZAP
	
	If oModelCal1:GetQtdLine() > 1 .Or. !Empty( oModelCal1:GetValue('C1_NRCALC'  ,1) )
		For nCont := 1 to oModelCal1:GetQtdLine()
			oModelCal1:GoLine( nCont )   
			
			RecLock(cAlias,.T.)
				(cAlias)->CDTRP  := oModelCal2:GetValue('C2_CDEMIT'  ,1)  
				(cAlias)->DSTRP  := POSICIONE("GU3",1,xFilial("GU3")+oModelCal2:GetValue('C2_CDEMIT'  ,1 ),"GU3_NMEMIT")
				(cAlias)->VLCALC := oModelCal1:GetValue('C1_VALFRT'  ,nCont)
				(cAlias)->DTPRE  := oModelCal1:GetValue('C1_DTPREN'  ,nCont)
			MsUnlock(cAlias) 			
		Next nCont 
		dbSelectArea(cAlias)
		dbGoTop()        
		oListbox:Refresh()
	EndIf		
Return .T.

/**********************************/
 