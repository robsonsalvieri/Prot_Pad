#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

/*/ GFEC053
@author Alan Victor Lamb
@since 05/09/2013
@version 1.0		

@description
Monitor de carregamentos
/*/
Function GFEC053() 
	Local aCoors := FWGetDialogSize(oMainWnd)
	Private oFWLayer, oPanelUp, oPanelDown, oRelacGWN
	Private oBrowseGWN, oBrowseGW1, oRelation
	Private oDlg
	Private aFieldsGWN, aFieldsGW1, aFieldsUFS
	Private cAliasGWN, cAliasGW1, cAliasUFS
	Private s_MULFIL := SuperGetMV("MV_MULFIL",.F.,"2")
	Private aRotina  := MenuDef()
	
	Define MsDialog oDlg Title 'Monitor de Carregamentos' From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel
	
	oFWLayer := FWLayer():New()
	oFWLayer:Init(oDlg, .F., .T.)
	
	oFWLayer:AddLine('UP',60,.F.)
	oFWLayer:AddLine('DOWN',40,.F.)
	oFWLayer:AddCollumn('ALL',100,.T.,'UP')
	oFWLayer:AddCollumn('ALL',100,.T.,'DOWN')
	
	oPanelUp   := oFWLayer:GetColPanel('ALL','UP')
	oPanelDown := oFWLayer:GetColPanel('ALL','DOWN')
	
	oDlg:Activate(,,,.T.,,,{||RptStatus({||Iniciar()}, "Carregando", "Aguarde, carregando dados...")})
	
	GFEDelTab(cAliasUFS)
	GFEDelTab(cAliasGW1)
	GFEDelTab(cAliasGWN)
Return Nil

Static Function Iniciar()
	Local aIndGWN, aIndGW1, aIndUFS
	
	SetRegua(5)
	
	aFieldsUFS := { {"Filial"  ,"GWN_FILIAL","C",TamSX3("GWN_FILIAL")[1],0,,1,2,.F.},;
					{"Romaneio","GWN_NRROM" ,"C",TamSX3("GWN_NRROM")[1],0,,1,2,.T.},;
					{"UF" 	   ,"GU7_CDUF"  ,"C",2,0,,1,2,.T.}}
	
	aIndUFS := {"GWN_FILIAL+GWN_NRROM"}
	cAliasUFS := CriaTab(aFieldsUFS, aIndUFS)
	
	aFieldsGWN := { {"Filial"		   	,"GWN_FILIAL","C",TamSX3("GWN_FILIAL")[1],0,,1,2,.F.},;
					{"Romaneio"		    ,"GWN_NRROM" ,"C",TamSX3("GWN_NRROM")[1],0,,1,TamSX3("GWN_NRROM")[1],.T.},;
					{"Data"	 		    ,"GWN_DTIMPL","D",8,0,,1,8,.T.},;
					{"Prioridade"	 	,"GWN_PRIOR" ,"N",TamSX3("GWN_PRIOR")[1],0,,1,2,.T.},;
					{"Placa"	 		,"GWN_PLACA" ,"C",TamSX3("GWN_PLACAD")[1],0,PESQPICT("GWN","GWN_PLACAD"),1,TamSX3("GWN_PLACAD")[1],.T.},;
					{"Cod Tipo Veic"	,"GWN_CDTPVC","C",TamSX3("GWN_CDTPVC")[1],0,,1,2,.F.},;
					{"Tipo Veículo"	    ,"GV3_DSTPVC","C",TamSX3("GV3_DSTPVC")[1],0,,1,10,.T.},;
					{"Cod Motorista"	,"GWN_CDMTR" ,"C",TamSX3("GWN_CDMTR")[1],0,,1,2,.F.},;
					{"Motorista"	 	,"GUU_NMMTR" ,"C",TamSX3("GUU_NMMTR")[1],0,,1,10,.T.},;
					{"Transportador"	,"GWN_CDTRP" ,"C",TamSX3("GWN_CDTRP")[1],0,,1,6,.F.},;
					{"Nome Transp"	    ,"GU3_NMEMIT","C",TamSX3("GU3_NMEMIT")[1],0,,1,6,.T.},;
					{"Tipo operação"	,"GV4_DSTPOP","C",TamSX3("GV4_DSTPOP")[1],0,,1,6,.T.},;
					{"Carga Max"		,"CARGUT"	 ,"N",TamSX3("GU8_CARGUT")[1],TamSX3("GU8_CARGUT")[2],PESQPICT("GU8","GU8_CARGUT"),2,10,.T.},;
					{"% Lotação" 		,"PCT_CARGUT","N",10,2,"@E 9,999.99",2,8,.T.},;
					{"Volum Max" 		,"VOLUT"	 ,"N",TamSX3("GU8_VOLUT")[1],TamSX3("GU8_VOLUT")[2],PESQPICT("GU8","GU8_VOLUT"),2,5,.T.},;
					{"% Ocupação"		,"PCT_VOLUT" ,"N",10,2,"@E 9,999.99",2,8,.T.},;
					{"Impresso?"  		,"IMPRESSO"  ,"C",05,0,,1,5,.T.},;
					{"UF Entregas" 	    ,"GU7_CDUF"  ,"C",50,0,,1,6,.T.},;
					{"Qtd Entregas"	    ,"QTD_TRE"   ,"N",15,0,,2,10,.T.},;
					{"Qtd Doctos"	 	,"QTD_DOC"	 ,"N",15,0,,2,10,.T.},;
					{"Qtd Vols"	 	    ,"GW8_QTDE"  ,"N",TamSX3("GW8_QTDE")[1],0,,2,10,.T.},;
					{"Peso Carga"		,"GW8_PESOR" ,"N",15,5,PESQPICT("GW8","GW8_PESOR"),2,10,.T.},;
					{"Valor Carga" 	    ,"GW8_VALOR" ,"N",TamSX3("GW8_VALOR")[1],TamSX3("GW8_VALOR")[2],PESQPICT("GW8","GW8_VALOR"),2,10,.T.},;
					{"Volume Carga" 	,"GW8_VOLUME","N",TamSX3("GW8_VOLUME")[1],TamSX3("GW8_VOLUME")[2],PESQPICT("GW8","GW8_VOLUME"),2,10,.T.},;
					{"Situação Cálculo" ,"GWN_CALC"  ,"C",30,0,,1,10,.T.},;
					{"Valor Frete" 	    ,"VLFRET"	 ,"N",TamSX3("GWI_VLFRET")[1],TamSX3("GWI_VLFRET")[2],PESQPICT("GWI","GWI_VLFRET"),2,10,.T.},;
					{"$ Frete Ton" 	    ,"FRT_PESOR" ,"N",15,5,PESQPICT("GW8","GW8_PESOR"),2,10,.T.},;
					{"% Frete Valor" 	,"FRT_VALOR" ,"N",15,5,PESQPICT("GW8","GW8_VALOR"),2,10,.T.},;
					{"$ Frete m3" 		,"FRT_VOLUME","N",15,5,PESQPICT("GW8","GW8_VOLUME"),2,10,.T.};
					}
	
	aIndGWN := {"GWN_FILIAL+GWN_NRROM"}
	cAliasGWN := CriaTab(aFieldsGWN, aIndGWN)
	
	
	aFieldsGW1 := { {"Filial"		   	,"GW1_FILIAL","C",TamSX3("GWN_FILIAL")[1],0,,1,2,.T.},;
					{"Cd Emissor"  	    ,"GW1_EMISDC","C",TamSX3("GW1_EMISDC")[1],0,,1,10,.F.},;
					{"Destinatário"	    ,"GW1_NMEMIS","C",TamSX3("GU3_NMEMIT")[1],0,,1,10,.T.},;
					{"Tipo"	 		    ,"GW1_CDTPDC","C",TamSX3("GW1_CDTPDC")[1],0,,1,5,.T.},;
					{"Série"	 	   	,"GW1_SERDC" ,"C",TamSX3("GW1_SERDC")[1],0,"!!!",1,5,.T.},;
					{"Número"	 		,"GW1_NRDC"  ,"C",TamSX3("GW1_NRDC")[1],0,,1,6,.T.},;
					{"Nr Romaneio"	    ,"GW1_NRROM" ,"C",TamSX3("GW1_NRROM")[1],0,,1,6,.F.},;
					{"Emissão"			,"GW1_DTEMIS","D",8,0,,1,8,.T.},;
					{"Prev Saída"	  	,"GW1_DTPSAI","D",8,0,,1,8,.T.},;
					{"Prev Entrega"	    ,"GWU_DTPENT","D",8,0,,1,8,.T.},;
					{"Peso Bruto"	 	,"GW8_PESOR" ,"N",15,5,PESQPICT("GW8","GW8_PESOR"),2,10,.T.},;
					{"Volume"	   		,"GW8_VOLUME","N",TamSX3("GW8_VOLUME")[1],TamSX3("GW8_VOLUME")[2],PESQPICT("GW8","GW8_VOLUME"),2,10,.T.},;
					{"Qtd Vols"	   	    ,"GW8_QTDE"	 ,"N",TamSX3("GW8_QTDE")[1],TamSX3("GW8_QTDE")[2],PESQPICT("GW8","GW8_QTDE"),2,10,.T.},;
					{"Cod Destinatário" ,"GW1_CDDEST","C",TamSX3("GW1_CDDEST")[1],0,,1,10,.F.},;
					{"Cidade Dest"	    ,"GU7_NMCID" ,"C",TamSX3("GU7_NMCID")[1],0,,1,10,.T.},;
					{"UF Dest" 		    ,"GU7_CDUF"	 ,"C",TamSX3("GU7_CDUF")[1],2,,1,2,.T.},;
					{"Qtd Redsp" 		,"QTD_TRE"	 ,"N",02,0,,2,5,.T.},;
					{"Qtd Redsp CIF"	,"QTD_TRECIF","N",02,0,,2,5,.T.},;
					{"Local Redesp 1"	,"RE1_NMCID" ,"C",TamSX3("GU7_NMCID")[1],0,,1,10,.T.},;
					{"Local Redesp 2"   ,"RE2_NMCID" ,"C",TamSX3("GU7_NMCID")[1],0,,1,10,.T.};
				}

	If GFXCP1212210('GW1_FILROM') .And. s_MULFIL == "1"
		aadd(aFieldsGW1, {"Fil Romaneio", "GW1_FILROM","C",TamSX3("GWN_FILIAL")[1],0,,1,2,.F.})

		aIndGW1 := {"GW1_FILIAL+GW1_CDTPDC+GW1_EMISDC+GW1_SERDC+GW1_NRDC+GW1_FILROM", "GW1_FILROM+GW1_NRROM"}
	Else
		aIndGW1 := {"GW1_FILIAL+GW1_CDTPDC+GW1_EMISDC+GW1_SERDC+GW1_NRDC", "GW1_FILIAL+GW1_NRROM"}
	EndIf
	cAliasGW1 := CriaTab(aFieldsGW1, aIndGW1)
	
	IncRegua()
	
	CarregarDados()
	
	IncRegua()
	
	//
	// Romaneios
	//
	oBrowseGWN:= FWMBrowse():New()
	oBrowseGWN:SetOwner(oPanelUp)
	oBrowseGWN:SetDescription('Romaneios de Carga')
	oBrowseGWN:DisableDetails()
	oBrowseGWN:SetAlias(cAliasGWN)
	oBrowseGWN:SetMenuDef('GFEC053')
	oBrowseGWN:SetProfileID('1')
	oBrowseGWN:ForceQuitButton()
	oBrowseGWN:SetAmbiente(.F.)
	oBrowseGWN:SetWalkthru(.F.)
	oBrowseGWN:SetFields(GetFields(aFieldsGWN, "cAliasGWN"))
	oBrowseGWN:Activate()
	
	IncRegua()
	
	//
	// Documentos de carga
	//
	oBrowseGW1:= FWMBrowse():New()
	oBrowseGW1:SetOwner(oPanelDown)
	oBrowseGW1:SetDescription('Documentos de Carga')
	oBrowseGW1:DisableDetails()
	oBrowseGW1:SetAlias(cAliasGW1)
	oBrowseGW1:SetMenuDef('GFEC053A')
	oBrowseGW1:SetAmbiente(.F.)
	oBrowseGW1:SetWalkthru(.F.)
	oBrowseGW1:SetProfileID('2')
	oBrowseGW1:SetFields(GetFields(aFieldsGW1, "cAliasGW1"))
	oBrowseGW1:Activate()
	
	IncRegua()
	
	oRelation := FWBrwRelation():New()
	If GFXCP1212210('GW1_FILROM') .And. s_MULFIL == "1"
		oRelation:AddRelation(oBrowseGWN, oBrowseGW1, {{"GW1_FILROM", 'xFilial("GWN")'},{"GW1_NRROM",'GWN_NRROM'}})
	Else
		oRelation:AddRelation(oBrowseGWN, oBrowseGW1, {{"GW1_FILIAL", 'xFilial("GWN")'},{"GW1_NRROM",'GWN_NRROM'}})
	EndIf
	oRelation:Activate()

	oBrowseGWN:UpdateBrowse()

	IncRegua()
Return Nil

Static Function Atualizar()
	SetRegua(4)
		
	IncRegua()
	CarregarDados()
	IncRegua()
	oBrowseGWN:Refresh()
	IncRegua()
	oBrowseGW1:Refresh()
	IncRegua()
Return Nil

Static Function MenuDef()
	Local aRotina  := {}
	ADD OPTION aRotina TITLE "Emitir Romaneio" 			ACTION "GFEC053OPT(1)"	OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE "Liberar Romaneio" 		ACTION "GFEC053OPT(2)"	OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE "Alterar Prioridade" 		ACTION "GFEC053OPT(3)"	OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE "Consultar Romaneio" 		ACTION "GFEC053OPT(4)"	OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE "Consultar Veículo" 		ACTION "GFEC053OPT(5)"	OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE "Consultar Motorista" 		ACTION "GFEC053OPT(6)"	OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE "Consultar Transportador" 	ACTION "GFEC053OPT(7)"	OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE "Listar Destinos"	 		ACTION "GFEC053OPT(8)"	OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE "Visualizar Anexo"         ACTION "MsDocument('GWN',GWN->(RecNo()), 2)" OPERATION 2  ACCESS 0 
Return aRotina

Static Function SetSX1()
	
	SetMVValue("GFEA052","MV_PAR01",(cAliasGWN)->GWN_FILIAL)
	SetMVValue("GFEA052","MV_PAR02",(cAliasGWN)->GWN_NRROM)
	SetMVValue("GFEA052","MV_PAR03",(cAliasGWN)->GWN_NRROM)
	
Return

Function GFEC053OPT(nOption)

	Do Case
		Case nOption == 1 // Emitir Romaneio
			SetSX1()
			GFEA052()
			RptStatus({||Atualizar()}, "Carregando", "Aguarde, atualizando dados...")
			
		Case nOption == 2 // Liberar Romaneio
			PosGWN()
			If GFEA050LIB()
				RecLock(cAliasGWN,.F.)
				(cAliasGWN)->(dbDelete())
				MsUnlock()
				
				oBrowseGWN:Refresh()
			EndIf

		Case nOption == 3 // Alterar Prioridade
			PosGWN()
			xTmp := GFEC053PRI()
			If xTmp != -1
				RecLock(cAliasGWN,.F.)
				(cAliasGWN)->GWN_PRIOR := xTmp
				MsUnlock()	
				
				oBrowseGWN:Refresh()
			EndIf
			
		Case nOption == 4 // Consultar Romaneio
			PosGWN()
			FWExecView("Visualizar", "GFEC050", 1,, {||.T.})
			
		Case nOption == 5 // Consultar Veículo
			If !Empty((cAliasGWN)->GWN_PLACA)
				dbSelectArea("GU8")
				GU8->(dbSetOrder(2))
				If GU8->(dbSeek(xFilial("GU8")+(cAliasGWN)->GWN_PLACA))
					FWExecView("Visualizar", "GFEA012", 1,, {||.T.})
				Else
					MsgStop("Veículo não encontrado")
				EndIf 
			Else
				MsgStop("O Romaneio não possui veículo informado")
			EndIf
			
		Case nOption == 6 // Consultar Motorista
			If !Empty((cAliasGWN)->GWN_CDMTR)
				dbSelectArea("GUU")
				GUU->(dbSetOrder(1))
				GUU->(dbSeek(xFilial("GUU")+(cAliasGWN)->GWN_CDMTR))
				FWExecView("Visualizar", "GFEA012", 1,, {||.T.}) 
			Else
				MsgStop("O Romaneio não possui motorista informado")
			EndIf
			
		Case nOption == 7 // Consultar Transportador
			dbSelectArea("GU3")
			GU3->(dbSetOrder(1))
			GU3->(dbSeek(xFilial("GU3")+(cAliasGWN)->GWN_CDTRP))
			FWExecView("Visualizar", "GFEA015", 1,, {||.T.}) 
		
		Case nOption == 8 // Listar Destinos
			PosGWN()
			GFEC053A()
			Return
		
		Case nOption == 9
			dbSelectArea("GW1")
			GW1->(dbSetOrder(1))
			GW1->(dbSeek((cAliasGW1)->(GW1_FILIAL+GW1_CDTPDC+GW1_EMISDC+GW1_SERDC+GW1_NRDC)))
			FWExecView("Visualizar", "GFEC040", 1,,{||.T.})
			
		Case nOption == 10
			dbSelectArea("GU3")
			GU3->(dbSetOrder(1))
			GU3->(dbSeek(xFilial("GU3")+(cAliasGW1)->GW1_CDDEST))
			FWExecView("Visualizar", "GFEA015", 1,, {||.T.}) 
			
	EndCase
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEC053PRI
Rotina para alterar a prioridade do Romaneio

Uso Geral.

Retorno: -1 se falha, ou a nova prioridade informada.

@author Alan Victor Lamb
@since 16/07/13
@version 1.0
/*/
//-------------------------------------------------------------------*/
Function GFEC053PRI()
	Local nRet := -1
	Local oDlg
	Local cDSTRAN
	Local cCadastro := "Alterar Prioridade"
	Local oSize
	Local aPosEnch
	Private cPrioridade := GWN->GWN_PRIOR
	
	aNewButton := {}
	
	oSize := FWDefSize():New(.T.)
	oSize:AddObject( "ENCHOICE", 100, 60, .T., .T. ) // Adiciona enchoice
	oSize:SetWindowSize({000, 000,200,620})
	oSize:lLateral     := .F.  // Calculo vertical	
	oSize:Process() //executa os calculos
	
	
	aPosEnch := {oSize:GetDimension("ENCHOICE","LININI"),;
                 oSize:GetDimension("ENCHOICE","COLINI"),;
                 oSize:GetDimension("ENCHOICE","LINEND"),;
                 oSize:GetDimension("ENCHOICE","COLEND")}
                 
	DEFINE MSDIALOG oDlg TITLE cCadastro ;
							FROM oSize:aWindSize[1],oSize:aWindSize[2] ;
							TO oSize:aWindSize[3],oSize:aWindSize[4] ; 
							PIXEL
	oDlg:lEscClose := .F.
	
//	oPnlA := tPanel():New(00,00,,oDlg,,,,,,10,80,.F.,.F.)
//	oPnlA:Align := CONTROL_ALIGN_TOP
	
	cDSTRAN := Posicione("GU3",1,xFilial("GU3")+GWN->GWN_CDTRP,"GU3_NMEMIT")
	
	@ aPosEnch[1]+07,aPosEnch[2]+10 Say "Romaneio: " Of oDlg Pixel 
   	@ aPosEnch[1]+05,aPosEnch[2]+55 MSGET GWN->GWN_NRROM Picture "@!" Of oDlg Valid When .F.   Pixel

	@ aPosEnch[1]+22,aPosEnch[2]+10 Say "Transportadora: "  Of oDlg Pixel
	@ aPosEnch[1]+20,aPosEnch[2]+55 MSGET GWN->GWN_CDTRP Picture "@!" Of oDlg Valid When .F.   Pixel
	@ aPosEnch[1]+20,aPosEnch[2]+145 MSGET cDSTRAN Picture "@!" SIZE 160,10 Of oDlg Valid When .F.   Pixel
	
	@ aPosEnch[1]+37,aPosEnch[2]+10  Say "Prioridade: " Of oDlg Pixel
   	@ aPosEnch[1]+35,aPosEnch[2]+55  MSGET cPrioridade Picture "@E 99" Of oDlg Valid POSITIVO() When .T. Pixel
	
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(ODlg,{||If(GFEC053OK(cPrioridade),ODlg:End(),NIL)},{||ODlg:End()},,aNewButton) CENTERED
	
	nRet := cPrioridade
Return nRet

Function GFEC053OK(nPrioridade)
	RecLock("GWN",.F.)
	GWN->GWN_PRIOR := nPrioridade
	MsUnlock()
Return .T.

Static Function PosGWN()
	dbSelectArea("GWN")
	GWN->(dbSetOrder(1))
Return GWN->(dbSeek((cAliasGWN)->(GWN_FILIAL+GWN_NRROM)))

Static Function GetUFDest(cFil, cNrRom)
	Local cRet := ""
	
	(cAliasUFS)->(dbSetOrder(1))
	If (cAliasUFS)->(dbSeek(cFil+cNrRom))
		While (cAliasUFS)->(!Eof()) .AND.;
		       (cAliasUFS)->GWN_FILIAL == cFil .AND.;
		        (cAliasUFS)->GWN_NRROM == cNrRom
		    
		    If !Empty(cRet)
		    	cRet += ","	
		    EndIf
		    
		    cRet += (cAliasUFS)->GU7_CDUF 
			(cAliasUFS)->(dbSkip())
		EndDo
	EndIf
	
Return cRet

Static Function CarregarDados()
	Local cQuery   := ""
	Local aSitCalc := {"Calculado com Sucesso","Nao Calculado","Tentativa sem Sucesso","Necessita Recalculo"}
	
	dbSelectArea(cAliasGW1)
	ZAP
	dbSelectArea(cAliasGWN)
	ZAP
	dbSelectArea(cAliasUFS)
	ZAP
	
	//
	// UF's por romaneio
	//
	cQuery += "	SELECT DISTINCT GWN_FILIAL,GWN_NRROM,GU7_CDUF"
	cQuery += "     FROM " + RetSQLName("GWN") + " GWN "
	If GFXCP1212210('GW1_FILROM') .And. s_MULFIL == "1"
		cQuery += "    INNER JOIN " + RetSQLName("GW1") + " GW1 ON GW1_FILROM = GWN_FILIAL AND GW1_NRROM = GWN_NRROM AND GW1.D_E_L_E_T_ = ''"
	Else
		cQuery += "    INNER JOIN " + RetSQLName("GW1") + " GW1 ON GW1_FILIAL = GWN_FILIAL AND GW1_NRROM = GWN_NRROM AND GW1.D_E_L_E_T_ = ''"
	EndIf
	cQuery += "    INNER JOIN " + RetSQLName("GU3") + " GU3 ON GU3_CDEMIT = GW1_CDDEST AND GU3.D_E_L_E_T_ = ''"
	cQuery += "    INNER JOIN " + RetSQLName("GU7") + " GU7 ON GU7_NRCID = GU3_NRCID AND GU7.D_E_L_E_T_ = ''"
	cQuery += "    WHERE GWN.D_E_L_E_T_ = '' "
	cQuery += "      AND GWN.GWN_FILIAL = '" + FWCodFil() + "' "
	cQuery += "      AND GWN.GWN_SIT != '3' "
	cQuery += "      AND GWN.GWN_SIT != '4' "
	
	
	cTmp := GetNextAlias()
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cTmp,.F.,.T.)
	dbSelectArea(cTmp)
	(cTmp)->(dbGoTop())
	
	If (cTmp)->(Recno()) > 0
		While (cTmp)->(!Eof())
			RecLock(cAliasUFS,.T.)
			(cAliasUFS)->GWN_FILIAL := (cTmp)->GWN_FILIAL
			(cAliasUFS)->GWN_NRROM  := (cTmp)->GWN_NRROM
			(cAliasUFS)->GU7_CDUF   := (cTmp)->GU7_CDUF
			MsUnlock()
			
			(cTmp)->(dbSkip())
		EndDo
	EndIf
	(cTmp)->(dbCloseArea())
	
	//
	// Browse Romaneios
	//
	cQuery := "SELECT DISTINCT GWN_FILIAL,"
	cQuery += "       GWN_NRROM,"
	cQuery += "       GWN_DTIMPL,"
	cQuery += "       GWN_PRIOR,"
	cQuery += "       GWN_PLACAD,"
	cQuery += "       GWN_CDTPVC,"
	cQuery += "       GWN_CDMTR,"
	cQuery += "       GWN_CDTRP,"
	cQuery += "       GWN_NRCIDD,"
	cQuery += "       GWN_CDTPOP,"
	cQuery += "	   	  CASE "
	cQuery += "       	WHEN (GU81.GU8_VOLUT+GU82.GU8_VOLUT+GU83.GU8_VOLUT) IS NOT NULL  "
	cQuery += "       	 AND (GU81.GU8_VOLUT+GU82.GU8_VOLUT+GU83.GU8_VOLUT) > 0"
	cQuery += "       	THEN (GU81.GU8_VOLUT+GU82.GU8_VOLUT+GU83.GU8_VOLUT)"
	cQuery += "       	ELSE GV3_VOLUT"
	cQuery += "       END VOLUT,"
	cQuery += "       CASE"
	cQuery += "       	WHEN (GU81.GU8_CARGUT+GU82.GU8_CARGUT+GU83.GU8_CARGUT) IS NOT NULL "
	cQuery += "       	 AND (GU81.GU8_CARGUT+GU82.GU8_CARGUT+GU83.GU8_CARGUT) > 0"
	cQuery += "       	THEN (GU81.GU8_CARGUT+GU82.GU8_CARGUT+GU83.GU8_CARGUT)"
	cQuery += "       	ELSE GV3_CARGUT"
	cQuery += "       END CARGUT,"
	cQuery += "       QTD_DOC,"
	cQuery += "       QTD_TRE,"
	cQuery += "       GW8_PESOR,"
	cQuery += "       GW8_VOLUME,"
	cQuery += "       GW8_QTDE,"
	cQuery += "       GW8_VALOR,"
	cQuery += "       GWN_CALC,"
	cQuery += "       GWN_SIT,"
	cQuery += "       GWF.VLFRET,"
	cQuery += "       GV3.GV3_DSTPVC GWN_DSTPVC, "
	
	cQuery += "       (SELECT GUU_NMMTR FROM " + RetSqlName("GUU") + " GUU "  
	cQuery += "         WHERE GUU.GUU_FILIAL = '" + xFilial("GUU") + "' "
	cQuery += "           AND GUU.GUU_CDMTR = GWN.GWN_CDMTR"
	cQuery += "           AND GUU.D_E_L_E_T_ = '') GUU_NMMTR, "
		
	cQuery += "       (SELECT GU3_NMEMIT FROM " + RetSqlName("GU3") + " GU3TRP "  
	cQuery += "         WHERE GU3TRP.GU3_FILIAL = '" + xFilial("GU3") + "' "
	cQuery += "           AND GU3TRP.GU3_CDEMIT = GWN.GWN_CDTRP"
	cQuery += "           AND GU3TRP.D_E_L_E_T_ = '') GU3_NMTRP, "
	
	cQuery += "       (SELECT GV4_DSTPOP FROM " + RetSqlName("GV4") + " GV4 "  
	cQuery += "         WHERE GV4.GV4_FILIAL = '" + xFilial("GV4") + "' "
	cQuery += "           AND GV4.GV4_CDTPOP = GWN.GWN_CDTPOP"
	cQuery += "           AND GV4.D_E_L_E_T_ = '') GV4_DSTPOP "
	
	cQuery += "  FROM " + RetSQLName("GWN") + " GWN"
	cQuery += " INNER JOIN ("
	cQuery += " 	        SELECT GW1_FILIAL, GW1_FILROM, GW1_NRROM, COUNT(*) QTD_DOC, SUM(GW8_PESOR) GW8_PESOR, "
	cQuery += " 	               SUM(GW8_VOLUME) GW8_VOLUME, SUM(GW8_QTDE) GW8_QTDE, SUM(GW8_VALOR) GW8_VALOR,"
	cQuery += " 	               COUNT(DISTINCT GW1_CDDEST) QTD_TRE"
	cQuery += " 	          FROM " + RetSQLName("GW1") + " GW1"
	cQuery += " 	         INNER JOIN " + RetSQLName("GWN") + " GWN"
	If GFXCP1212210('GW1_FILROM') .And. s_MULFIL == "1"
		cQuery += "		        ON GWN.GWN_FILIAL = GW1.GW1_FILROM "
	Else
		cQuery += "	            ON GWN.GWN_FILIAL = GW1.GW1_FILIAL "
	EndIf
	cQuery += " 	           AND GWN.GWN_NRROM = GW1.GW1_NRROM "
	cQuery += " 	 		   AND GWN.GWN_SIT != '3' "
	cQuery += "   			   AND GWN.GWN_SIT != '4' "
	cQuery += "   			   AND GWN.GWN_FILIAL = '"+FWCodFil()+"' "
	cQuery += " 	         INNER JOIN ( "
	cQuery += " 	 	                  SELECT GW8_FILIAL, GW8_CDTPDC, GW8_EMISDC, GW8_SERDC, GW8_NRDC, SUM(GW8_PESOR) GW8_PESOR, SUM(GW8_VOLUME) GW8_VOLUME, SUM(GW8_QTDE) GW8_QTDE, SUM(GW8_VALOR) GW8_VALOR"
	cQuery += " 	 	                    FROM " + RetSQLName("GW8") + ""
	cQuery += " 	 	                   WHERE D_E_L_E_T_ = ''"
	cQuery += " 	 	                   GROUP BY GW8_FILIAL, GW8_CDTPDC, GW8_EMISDC, GW8_SERDC, GW8_NRDC"
	cQuery += " 	                    ) GW8"
	cQuery += " 	            ON GW8.GW8_FILIAL = GW1.GW1_FILIAL"
	cQuery += " 	 	       AND GW8.GW8_CDTPDC = GW1.GW1_CDTPDC"
	cQuery += " 	 	       AND GW8.GW8_EMISDC = GW1.GW1_EMISDC"
	cQuery += " 	 	       AND GW8.GW8_SERDC = GW1.GW1_SERDC"
	cQuery += " 	 	       AND GW8.GW8_NRDC = GW1.GW1_NRDC"
	cQuery += " 	         WHERE GW1.D_E_L_E_T_ = ''"
	cQuery += " 	         GROUP BY GW1_FILIAL, GW1_FILROM, GW1_NRROM"
	cQuery += "            ) GW1N"
	If GFXCP1212210('GW1_FILROM') .And. s_MULFIL == "1"
		cQuery += "     ON GW1N.GW1_FILROM = GWN.GWN_FILIAL"
	Else
		cQuery += "     ON GW1N.GW1_FILIAL = GWN.GWN_FILIAL"
	EndIf
	cQuery += "        AND GW1N.GW1_NRROM = GWN.GWN_NRROM"
	cQuery += "  LEFT JOIN " + RetSQLName("GU8") + " GU81 ON GU81.GU8_PLACA = GWN.GWN_PLACAD AND GU81.D_E_L_E_T_ = ''"
	cQuery += "  LEFT JOIN " + RetSQLName("GU8") + " GU82 ON GU82.GU8_PLACA = GWN.GWN_PLACAT AND GU82.D_E_L_E_T_ = ''"
	cQuery += "  LEFT JOIN " + RetSQLName("GU8") + " GU83 ON GU83.GU8_PLACA = GWN.GWN_PLACAM AND GU83.D_E_L_E_T_ = ''"
	cQuery += "  LEFT JOIN " + RetSQLName("GV3") + " GV3  ON GV3.GV3_FILIAL = '" + xFilial("GV3") + "' AND GV3.GV3_CDTPVC = GWN.GWN_CDTPVC AND GV3.D_E_L_E_T_ = ''"
	cQuery += "  LEFT JOIN ("
	cQuery += "  	        SELECT GWF_FILIAL, GWF_NRROM, SUM(GWI_VLFRET+GWF_VLAJUS) VLFRET "
	cQuery += "  	          FROM " + RetSQLName("GWF") + " GWF"
	cQuery += "	             INNER JOIN " + RetSQLName("GWN") + " GWN"
	cQuery += "	                ON GWN.GWN_FILIAL = GWF.GWF_FILIAL "
	cQuery += "	 			   AND GWN.GWN_NRROM = GWF.GWF_NRROM "
	cQuery += " 	 		   AND GWN.GWN_SIT != '3' "
	cQuery += "   			   AND GWN.GWN_SIT != '4' "
	cQuery += "   			   AND GWN.D_E_L_E_T_ = ''"
	cQuery += "   			   AND GWN.GWN_FILIAL = '"+FWCodFil()+"'"
	cQuery += " 	          LEFT JOIN ("
	cQuery += "	  						 SELECT GWI_FILIAL, GWI_NRCALC, SUM(GWI_VLFRET) GWI_VLFRET"
	cQuery += "	  	  					   FROM " + RetSQLName("GWI") + " "
	cQuery += "	  	 					  WHERE D_E_L_E_T_ = ''"
	cQuery += "	  	   					    AND GWI_TOTFRE = '1'"
	cQuery += "	  	 					  GROUP BY GWI_FILIAL, GWI_NRCALC"
	cQuery += "	                        ) GWI"
	cQuery += "	                ON GWI.GWI_FILIAL = GWF.GWF_FILIAL"
	cQuery += "	               AND GWI.GWI_NRCALC = GWF.GWF_NRCALC"
	cQuery += "	             WHERE GWF.D_E_L_E_T_ = ''"
	cQuery += "	               AND GWF_TPCALC != '8'"
	cQuery += "	             GROUP BY GWF_FILIAL, GWF_NRROM"
	cQuery += "	           ) GWF"
	cQuery += "	   ON GWF.GWF_FILIAL = GWN.GWN_FILIAL"
	cQuery += "	  AND GWF.GWF_NRROM = GWN.GWN_NRROM"
	cQuery += " WHERE GWN.D_E_L_E_T_ = ''"
	cQuery += "   AND GWN.GWN_FILIAL = '" + FWCodFil() + "' "
	cQuery += "   AND GWN.GWN_SIT != '3' "
	cQuery += "   AND GWN.GWN_SIT != '4'"
	
	cTmp := GetNextAlias()
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cTmp,.F.,.T.)
	dbSelectArea(cTmp)	
	(cTmp)->(dbGoTop())
	If (cTmp)->(Recno()) > 0
		While (cTmp)->(!Eof())
			RecLock(cAliasGWN,.T.)
			(cAliasGWN)->GWN_FILIAL := (cTmp)->GWN_FILIAL
			(cAliasGWN)->GWN_NRROM  := (cTmp)->GWN_NRROM
			(cAliasGWN)->GWN_DTIMPL := StoD((cTmp)->GWN_DTIMPL)
			(cAliasGWN)->GWN_PRIOR  := (cTmp)->GWN_PRIOR
			(cAliasGWN)->GWN_PLACA  := (cTmp)->GWN_PLACAD
			(cAliasGWN)->GWN_CDTPVC := (cTmp)->GWN_CDTPVC
			(cAliasGWN)->GV3_DSTPVC := (cTmp)->GWN_DSTPVC
			(cAliasGWN)->GWN_CDMTR  := (cTmp)->GWN_CDMTR
			(cAliasGWN)->GUU_NMMTR  := (cTmp)->GUU_NMMTR
			(cAliasGWN)->GWN_CDTRP  := (cTmp)->GWN_CDTRP
			(cAliasGWN)->GU3_NMEMIT := (cTmp)->GU3_NMTRP			
			(cAliasGWN)->GV4_DSTPOP := (cTmp)->GV4_DSTPOP
			(cAliasGWN)->CARGUT	    := (cTmp)->CARGUT
			(cAliasGWN)->PCT_CARGUT := If((cTmp)->CARGUT > 0,(cTmp)->GW8_PESOR / (cTmp)->CARGUT * 100,0)
			(cAliasGWN)->VOLUT	    := (cTmp)->VOLUT
			(cAliasGWN)->PCT_VOLUT  := If((cTmp)->VOLUT > 0,(cTmp)->GW8_VOLUME / (cTmp)->VOLUT * 100,0)
			(cAliasGWN)->IMPRESSO   := If((cTmp)->GWN_SIT == "2", "Sim", "Não")
			(cAliasGWN)->GU7_CDUF   := GetUFDest((cTmp)->GWN_FILIAL, (cTmp)->GWN_NRROM)
			(cAliasGWN)->QTD_TRE    := (cTmp)->QTD_TRE
			(cAliasGWN)->QTD_DOC    := (cTmp)->QTD_DOC
			(cAliasGWN)->GW8_QTDE   := (cTmp)->GW8_QTDE
			(cAliasGWN)->GW8_PESOR  := (cTmp)->GW8_PESOR
			(cAliasGWN)->GW8_VALOR  := (cTmp)->GW8_VALOR
			(cAliasGWN)->GW8_VOLUME := (cTmp)->GW8_VOLUME
			(cAliasGWN)->GWN_CALC   := aSitCalc[Val((cTmp)->GWN_CALC)]
			(cAliasGWN)->VLFRET	    := (cTmp)->VLFRET
			(cAliasGWN)->FRT_PESOR  := If((cTmp)->GW8_PESOR > 0, (cTmp)->VLFRET / (cTmp)->GW8_PESOR * 1000, 0)
			(cAliasGWN)->FRT_VALOR  := If((cTmp)->GW8_VALOR > 0, (cTmp)->VLFRET / (cTmp)->GW8_VALOR * 100, 0)
			(cAliasGWN)->FRT_VOLUME := If((cTmp)->GW8_VOLUME > 0, (cTmp)->VLFRET / (cTmp)->GW8_VOLUME, 0)
			MsUnlock()
			
			(cTmp)->(dbSkip())
		EndDo
	EndIf
	(cTmp)->(dbCloseArea())
	
	//
	// Browse Documentos de Carga
	//
	cQuery := " SELECT GW1_FILIAL, "
	cQuery += "		   GW1_CDTPDC, "
	cQuery += "		   GW1_EMISDC, "
	cQuery += "		   GW1_SERDC, "
	cQuery += "		   GW1_NRDC,"
	cQuery += "		   GW1_DTEMIS,"
	cQuery += "		   GW1_DTPSAI,"
	cQuery += "		   GWUFIN.GWU_DTPENT,"
	cQuery += "		   GW1_FILROM, "
	cQuery += "		   GW1_NRROM,"
	cQuery += "		   GW8_PESOR,"
	cQuery += "		   GW8_QTDE,"
	cQuery += "		   GW8_VOLUME,"
	cQuery += "		   GW1_CDDEST,"
	cQuery += "		   QTD_TRE,"
	cQuery += "		   QTD_TRECIF,"
	cQuery += "		   GU7.GU7_NMCID,"		   
	cQuery += "		   GU7.GU7_CDUF,"
	cQuery += "		   GU3.GU3_NMEMIT,"

	cQuery += "        (SELECT GU7_NMCID "
	cQuery += "           FROM " + RetSQLName("GWU") + " GWU2, " + RetSQLName("GU7") + " GU72 "
	cQuery += "          WHERE GWU2.GWU_NRDC = GW1.GW1_NRDC"
	cQuery += "	           AND GWU2.GWU_FILIAL = GW1.GW1_FILIAL"
	cQuery += "	           AND GWU2.GWU_EMISDC = GW1.GW1_EMISDC"
	cQuery += "	           AND GWU2.GWU_SERDC = GW1.GW1_SERDC"
	cQuery += "	           AND GWU2.GWU_CDTPDC = GW1.GW1_CDTPDC"
	cQuery += "	           AND GWU2.GWU_SEQ = '01'"
	cQuery += "	           AND GWU2.D_E_L_E_T_       = ''"
	cQuery += "	           AND GU72.GU7_FILIAL = '" + xFilial("GU7") + "' "
	cQuery += "	           AND GU72.GU7_NRCID = GWU2.GWU_NRCIDD"   
	cQuery += "	           AND GU72.D_E_L_E_T_ = '') RE1_NMCID,"  

	cQuery += "        (SELECT GU7_NMCID "
	cQuery += "           FROM " + RetSQLName("GWU") + " GWU3, " + RetSQLName("GU7") + " GU73 "
	cQuery += "          WHERE GWU3.GWU_NRDC    = GW1.GW1_NRDC"
	cQuery += "	           AND GWU3.GWU_FILIAL  = GW1.GW1_FILIAL"
	cQuery += "	           AND GWU3.GWU_EMISDC  = GW1.GW1_EMISDC"
	cQuery += "	           AND GWU3.GWU_SERDC   = GW1.GW1_SERDC"
	cQuery += "	           AND GWU3.GWU_CDTPDC  = GW1.GW1_CDTPDC"
	cQuery += "	           AND GWU3.GWU_SEQ = '02'"
	cQuery += "	           AND GWU3.D_E_L_E_T_ = ''"
	cQuery += "	           AND GU73.GU7_FILIAL = '" + xFilial("GU7") + "' "
	cQuery += "	           AND GU73.GU7_NRCID = GWU3.GWU_NRCIDD"   
	cQuery += "	           AND GU73.D_E_L_E_T_ = '') RE2_NMCID "

	cQuery += "	  FROM " + RetSQLName("GW1") + " GW1"
	cQuery += "	 INNER JOIN " + RetSQLName("GWN") + " GWN"
	If GFXCP1212210('GW1_FILROM') .And. s_MULFIL == "1"
		cQuery += "	ON GWN.GWN_FILIAL = GW1_FILROM"
	Else
		cQuery += "	ON GWN.GWN_FILIAL = GW1_FILIAL"
	EndIf
	cQuery += "	   AND GWN.GWN_NRROM = GW1_NRROM"
	cQuery += "	   AND GWN.GWN_SIT != '3'"
	cQuery += "	   AND GWN.GWN_SIT != '4'"
	cQuery += "	   AND GWN.D_E_L_E_T_ = ''"
	cQuery += "	   AND GWN.GWN_FILIAL = '" + FWCodFil() + "'"
	cQuery += "	 INNER JOIN " + RetSQLName("GU3") + " GU3 ON GU3.GU3_FILIAL = '" + xFilial("GU3") + "'  AND GU3.GU3_CDEMIT = GW1.GW1_CDDEST AND GU3.D_E_L_E_T_ = ''"
	cQuery += "  INNER JOIN " + RetSQLName("GU7") + " GU7 ON GU7.GU7_FILIAL = '" + xFilial("GU7") + "' AND GU7.GU7_NRCID  = GU3.GU3_NRCID  AND GU7.D_E_L_E_T_ = ''"
	cQuery += "	 INNER JOIN ( "
	cQuery += " 	 		  SELECT GW8_FILIAL, GW8_CDTPDC, GW8_EMISDC, GW8_SERDC, GW8_NRDC, SUM(GW8_PESOR) GW8_PESOR, SUM(GW8_VOLUME) GW8_VOLUME, SUM(GW8_QTDE) GW8_QTDE, SUM(GW8_VALOR) GW8_VALOR"
	cQuery += " 	 	        FROM " + RetSQLName("GW1") + " GW1"
	cQuery += " 	 	       INNER JOIN " + RetSQLName("GWN") + " GWN"
	If GFXCP1212210('GW1_FILROM') .And. s_MULFIL == "1"
		cQuery += "		          ON GWN.GWN_FILIAL = GW1_FILROM"
	Else
		cQuery += "		          ON GWN.GWN_FILIAL = GW1_FILIAL"
	EndIf
	cQuery += " 	 	         AND GWN.GWN_NRROM = GW1_NRROM"
	cQuery += "		             AND GWN.GWN_SIT != '3'"
	cQuery += "		             AND GWN.GWN_SIT != '4'"
	cQuery += "		             AND GWN.GWN_FILIAL = '"+FWCodFil()+"' "
	cQuery += "		             AND GWN.D_E_L_E_T_ = '' "
	cQuery += " 	 	       INNER JOIN " + RetSQLName("GW8") + " GW8"
	cQuery += " 	 	          ON GW8.GW8_FILIAL = GW1.GW1_FILIAL"
	cQuery += "				     AND GW8.GW8_CDTPDC = GW1.GW1_CDTPDC"
	cQuery += "				     AND GW8.GW8_EMISDC = GW1.GW1_EMISDC"
	cQuery += "				     AND GW8.GW8_SERDC  = GW1.GW1_SERDC"
	cQuery += "				     AND GW8.GW8_NRDC   = GW1.GW1_NRDC"
	cQuery += "				     AND GW8.D_E_L_E_T_ = ''"
	cQuery += " 	 	       WHERE GW1.D_E_L_E_T_ = ''"
	cQuery += " 	 	       GROUP BY GW8_FILIAL, GW8_CDTPDC, GW8_EMISDC, GW8_SERDC, GW8_NRDC"
	cQuery += " 	        ) GW8"
	cQuery += "     ON GW8.GW8_FILIAL = GW1.GW1_FILIAL"
	cQuery += "    AND GW8.GW8_CDTPDC = GW1.GW1_CDTPDC"
	cQuery += "    AND GW8.GW8_EMISDC = GW1.GW1_EMISDC"
	cQuery += "    AND GW8.GW8_SERDC  = GW1.GW1_SERDC"
	cQuery += "    AND GW8.GW8_NRDC   = GW1.GW1_NRDC"
	cQuery += "  INNER JOIN ("
	cQuery += " 	 		 SELECT GWU_FILIAL, GWU_CDTPDC, GWU_EMISDC, GWU_SERDC, GWU_NRDC, COUNT(*) QTD_TRE, COUNT(CASE WHEN GWU_PAGAR = '1' THEN 1 END) QTD_TRECIF"
	cQuery += " 	 	       FROM " + RetSQLName("GW1") + " GW1"
	cQuery += " 	 	      INNER JOIN " + RetSQLName("GWN") + " GWN"
	If GFXCP1212210('GW1_FILROM') .And. s_MULFIL == "1"
		cQuery += "		         ON GWN.GWN_FILIAL = GW1_FILROM"
	Else
		cQuery += "		         ON GWN.GWN_FILIAL = GW1_FILIAL"
	EndIf
	cQuery += " 	 	        AND GWN.GWN_NRROM = GW1_NRROM"
	cQuery += "		            AND GWN.GWN_SIT != '3'"
	cQuery += "		            AND GWN.GWN_SIT != '4'"
	cQuery += "		            AND GWN.GWN_FILIAL = '"+FWCodFil()+"'"
	cQuery += "		            AND GWN.D_E_L_E_T_ = ''"
	cQuery += "		          INNER JOIN " + RetSQLName("GWU") + " GWU"
	cQuery += "		             ON GWU.GWU_FILIAL = GW1.GW1_FILIAL"
	cQuery += "				    AND GWU.GWU_CDTPDC = GW1.GW1_CDTPDC"
	cQuery += "				    AND GWU.GWU_EMISDC = GW1.GW1_EMISDC"
	cQuery += "				    AND GWU.GWU_SERDC  = GW1.GW1_SERDC"
	cQuery += "					AND GWU.GWU_NRDC   = GW1.GW1_NRDC"
	cQuery += "					AND GWU.D_E_L_E_T_ = ''"
	cQuery += " 	 	      WHERE GW1.D_E_L_E_T_ = ''"
	cQuery += " 	 	      GROUP BY GWU_FILIAL, GWU_CDTPDC, GWU_EMISDC, GWU_SERDC, GWU_NRDC"
	cQuery += " 	        ) GWU"
	cQuery += " 	ON GWU.GWU_FILIAL = GW1.GW1_FILIAL"
	cQuery += "    AND GWU.GWU_CDTPDC = GW1.GW1_CDTPDC"
	cQuery += "    AND GWU.GWU_EMISDC = GW1.GW1_EMISDC"
	cQuery += "    AND GWU.GWU_SERDC  = GW1.GW1_SERDC"
	cQuery += "    AND GWU.GWU_NRDC   = GW1.GW1_NRDC"
	cQuery += "   LEFT JOIN ( "
	cQuery += "	   			 SELECT GWU1.GWU_FILIAL, GWU1.GWU_CDTPDC, GWU1.GWU_EMISDC, GWU1.GWU_SERDC, GWU1.GWU_NRDC, GWU1.GWU_DTENT, GWU1.GWU_DTPENT"
	cQuery += "		  		   FROM " + RetSQLName("GWU") + " GWU1"
	cQuery += "		 		  INNER JOIN ("
	cQuery += "		 					  SELECT GWU_FILIAL, GWU_CDTPDC, GWU_EMISDC, GWU_SERDC, GWU_NRDC, MAX(GWU_SEQ) GWU_SEQ"
	cQuery += "		 	  					FROM " + RetSQLName("GWU")
	cQuery += "		 	 				   WHERE D_E_L_E_T_ = '' "
	cQuery += "		 	   					 AND GWU_PAGAR = '1' "
	cQuery += "		     				   GROUP BY GWU_FILIAL, GWU_CDTPDC, GWU_EMISDC, GWU_SERDC, GWU_NRDC "
	cQuery += "		 					 ) GWU2"
	cQuery += "		 			 ON GWU1.GWU_FILIAL = GWU2.GWU_FILIAL "
	cQuery += "			        AND GWU1.GWU_CDTPDC = GWU2.GWU_CDTPDC "
	cQuery += "			        AND GWU1.GWU_EMISDC = GWU2.GWU_EMISDC "
	cQuery += "			        AND GWU1.GWU_SERDC  = GWU2.GWU_SERDC "
	cQuery += "			        AND GWU1.GWU_NRDC   = GWU2.GWU_NRDC "
	cQuery += "			        AND GWU1.GWU_SEQ    = GWU2.GWU_SEQ "
	cQuery += "		          WHERE GWU1.D_E_L_E_T_ = '' "
	cQuery += "		            AND GWU1.GWU_PAGAR = '1' "
	cQuery += "	          ) GWUFIN"
	cQuery += "	    ON GWUFIN.GWU_NRDC    = GW1.GW1_NRDC "
	cQuery += "	   AND GWUFIN.GWU_FILIAL  = GW1.GW1_FILIAL "
	cQuery += "	   AND GWUFIN.GWU_EMISDC  = GW1.GW1_EMISDC "
	cQuery += "	   AND GWUFIN.GWU_SERDC   = GW1.GW1_SERDC "
	cQuery += "	   AND GWUFIN.GWU_CDTPDC  = GW1.GW1_CDTPDC "
	cQuery += "	 WHERE GW1.D_E_L_E_T_ = '' "
	
	cTmp := GetNextAlias()
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cTmp,.F.,.T.)
	dbSelectArea(cTmp)
	(cTmp)->(dbGoTop())
	If (cTmp)->(Recno()) > 0
		While (cTmp)->(!Eof())
			RecLock(cAliasGW1,.T.)
			(cAliasGW1)->GW1_FILIAL := (cTmp)->GW1_FILIAL
			(cAliasGW1)->GW1_EMISDC := (cTmp)->GW1_EMISDC
			(cAliasGW1)->GW1_NMEMIS := (cTmp)->GU3_NMEMIT
			(cAliasGW1)->GW1_CDTPDC := (cTmp)->GW1_CDTPDC
			(cAliasGW1)->GW1_SERDC  := (cTmp)->GW1_SERDC
			(cAliasGW1)->GW1_NRDC   := (cTmp)->GW1_NRDC
			(cAliasGW1)->GW1_NRROM  := (cTmp)->GW1_NRROM
			(cAliasGW1)->GW1_DTEMIS := StoD((cTmp)->GW1_DTEMIS)
			(cAliasGW1)->GW1_DTPSAI := StoD((cTmp)->GW1_DTPSAI)
			(cAliasGW1)->GWU_DTPENT := StoD((cTmp)->GWU_DTPENT)
			(cAliasGW1)->GW8_PESOR  := (cTmp)->GW8_PESOR
			(cAliasGW1)->GW8_VOLUME := (cTmp)->GW8_VOLUME
			(cAliasGW1)->GW8_QTDE   := (cTmp)->GW8_QTDE
			(cAliasGW1)->GW1_CDDEST := (cTmp)->GW1_CDDEST
			(cAliasGW1)->GU7_NMCID  := (cTmp)->GU7_NMCID
			(cAliasGW1)->GU7_CDUF   := (cTmp)->GU7_CDUF
			(cAliasGW1)->QTD_TRE	:= (cTmp)->QTD_TRE
			(cAliasGW1)->QTD_TRECIF := (cTmp)->QTD_TRECIF
			(cAliasGW1)->RE1_NMCID  := (cTmp)->RE1_NMCID 
			(cAliasGW1)->RE2_NMCID  := (cTmp)->RE2_NMCID
			If GFXCP1212210('GW1_FILROM') .And. s_MULFIL == "1"
				(cAliasGW1)->GW1_FILROM := (cTmp)->GW1_FILROM
			EndIf
			MsUnlock()

			(cTmp)->(dbSkip())
		EndDo
	EndIf
	(cTmp)->(dbCloseArea())
	
Return Nil

//
// Retorna estrutura de campos/colunas para browse com tabela temporária
//
Static Function GetFields(aStruct, cAlias)
	Local aFields := {}
	Local nCount
	
	For nCount := 1 To Len(aStruct)
		If aStruct[nCount, 9]
			aAdd(aFields, {aStruct[nCount,1],;
						     &("{|| ("+cAlias+")->" + aStruct[nCount,2] + "}"),;
						     aStruct[nCount,3],;
						     aStruct[nCount,6],;
						     aStruct[nCount,7],;
						     aStruct[nCount,8],;
						     aStruct[nCount,5],;
						     .F.,{||.T.},.F.,{||.T.},NIL,{||.T.},.F.,.F.,{}})					     
		EndIf
	Next nCount 
Return aFields

// Cria tabela temporária
Static Function CriaTab(aFields, aIndices)
	Local cAlias
	Local nCont
	Local aStruct := {}
	               
	For nCont := 1 To Len(aFields)
		aADD(aStruct,{aFields[nCont][2],;  //Nome do campo
						aFields[nCont][3],;  //Tipo
						aFields[nCont][4],;  //Tamanho
						aFields[nCont][5]}) //Decimal
	Next nCont
	
	cAlias := GFECriaTab({aStruct,aIndices})
Return cAlias
