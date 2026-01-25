#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "WMSA100.CH"
Static lMarkAll := .T. //Indicador de marca/desmarca todos
Static nContTMP := 0   //Contador de Registros Marcados (ProcRegua)
Static lWMSAutoma := IsBlind() //--Inicializa variavel de automação de testes
Static cAliasBrw  := GetNextAlias()
Static cMarca     := "X"

//----------------------------------------------------------------------------------------------------------------------//
//-------------------------Rotina que efetua o reabastecimento nos enderecos de picking fixo----------------------------//
//-------------------------------e/ou enderecos de picking parcialmente preenchidos-------------------------------------//
//----------------------------------------------------------------------------------------------------------------------//
Function WmsA100()
Local aColsBrw   := {}
Local aColsSX3   := {}
Local aSeeks     := {}
Local aRegra     := StrTokArr(Posicione('SX3',2,'DCF_REGRA','X3CBox()'),';')
Local nPos       := 0
Local bRegra     := Nil

Private oBrowse    := Nil

	If SuperGetMv("MV_WMSNEW",.F.,.F.)
		Return WMSA101()
	EndIf

	If !Pergunte("WMSA100",.T.)
		Return
	EndIf

	For nPos := 1 To Len(aRegra)
		aRegra[nPos] := StrTokArr(aRegra[nPos],'=')
	Next
	bRegra := {|| nPos := AScan(aRegra,{|x| x[1] == (cAliasBrw)->TP_REGRA}), Iif(nPos > 0, aRegra[nPos,2], '')}

	If !BrwQuery()
		Return
	EndIf
	AAdd(aColsBrw,{buscarSX3('BE_LOCAL'  ,,aColsSX3), "TP_LOCAL"  ,'C',aColsSX3[3],aColsSX3[4],aColsSX3[2],1,,.F.,,,,,,,,1})   // Armazem
	AAdd(aColsBrw,{buscarSX3('BE_LOCALIZ',,aColsSX3), "TP_LOCALIZ",'C',aColsSX3[3],aColsSX3[4],aColsSX3[2],1,,.F.,,,,,,,,1})   // Endereço
	AAdd(aColsBrw,{buscarSX3('BE_ESTFIS' ,,aColsSX3), "TP_ESTFIS" ,'C',aColsSX3[3],aColsSX3[4],aColsSX3[2],1,,.F.,,,,,,,,1})   // Prod./Fixo/Endereço
	AAdd(aColsBrw,{buscarSX3('BE_CODZON' ,,aColsSX3), "TP_CODZON" ,'C',aColsSX3[3],aColsSX3[4],aColsSX3[2],1,,.F.,,,,,,,,1})   // Zona Armaz.
	AAdd(aColsBrw,{buscarSX3('BF_PRODUTO',,aColsSX3), "TP_PRODUTO",'C',aColsSX3[3],aColsSX3[4],aColsSX3[2],1,,.T.,,,,,,,,1})   // Produto
	buscarSX3('BF_QUANT',,aColsSX3)
	AAdd(aColsBrw,{/*Mesmo BF_QUANT*/        STR0007, "TP_NORMA"  ,'N',aColsSX3[3],aColsSX3[4],aColsSX3[2],1,,.F.,,,,,,,,1})   // Norma
	AAdd(aColsBrw,{/*Mesmo BF_QUANT*/        STR0008, "TP_QTDSALD",'N',aColsSX3[3],aColsSX3[4],aColsSX3[2],1,,.F.,,,,,,,,1})   // Qtd Saldo
	AAdd(aColsBrw,{/*Mesmo BF_QUANT*/        STR0009, "TP_QTDPREV",'N',aColsSX3[3],aColsSX3[4],aColsSX3[2],1,,.F.,,,,,,,,1})   // Qtd Prevista
	AAdd(aColsBrw,{/*Mesmo BF_QUANT*/        STR0010, "TP_QTDREAB",'N',aColsSX3[3],aColsSX3[4],aColsSX3[2],1,,.F.,,,,,,,,1})   // Qtd Reabastecer
	AAdd(aColsBrw,{buscarSX3('DCF_REGRA' ,,aColsSX3), /*"TP_REGRA"*/bRegra  ,'C',aColsSX3[3],aColsSX3[4],Nil,1,,.T.,,,,,,,,1}) // Regra WMS
	AAdd(aSeeks, {; // Armazém + Endereço + Produto
		AllTrim(aColsBrw[1][1])+' + '+AllTrim(aColsBrw[2][1])+' + '+AllTrim(aColsBrw[5][1]),;
		{;
			{'NNR',aColsBrw[1][3],aColsBrw[1][4],aColsBrw[1][5],aColsBrw[1][1],Nil},;
			{'SBE',aColsBrw[2][3],aColsBrw[2][4],aColsBrw[2][5],aColsBrw[2][1],Nil},;
			{'SB1',aColsBrw[5][3],aColsBrw[5][4],aColsBrw[5][5],aColsBrw[5][1],Nil} ;
		}})

	AAdd(aSeeks, {; // Produto
		AllTrim(aColsBrw[5][1]),;
		{;
			{'SB1',aColsBrw[5][3],aColsBrw[5][4],aColsBrw[5][5],aColsBrw[5][1],Nil} ;
		}})
	oBrowse:= FWMarkBrowse():New()
	oBrowse:SetDescription(STR0001)
	oBrowse:SetAlias(cAliasBrw)
	oBrowse:SetTemporary(.T.)
	oBrowse:SetFields(aColsBrw)
	oBrowse:SetSeek(,aSeeks)
	oBrowse:SetFieldMark("TP_MARK")
	oBrowse:SetMark(cMarca,cAliasBrw,"TP_MARK")
	oBrowse:SetValid({||!Empty((cAliasBrw)->TP_PRODUTO)})
	oBrowse:SetAllMark({||BrwAllMark()})
	oBrowse:SetAfterMark({||Iif(oBrowse:IsMark(),nContTMP++,nContTMP--)})
	oBrowse:oBrowse:SetMenuDef("WMSA100")
	oBrowse:SetWalkThru(.F.)
	oBrowse:SetAmbiente(.F.)
	oBrowse:SetUseFilter(.T.)
	oBrowse:SetParam({|| WMS100Sel()})
	oBrowse:Activate()

	delTabTmp(cAliasBrw)
Return

//-------------------------------------------------------------------//
//-------------------------Função MenuDef----------------------------//
//-------------------------------------------------------------------//
Static Function MenuDef()
Local aRotina := {}
	ADD OPTION aRotina TITLE STR0002 ACTION 'WMS100PReb()' 		OPERATION 4 ACCESS 0 // Processar
	ADD OPTION aRotina TITLE STR0003 ACTION 'WMS100Sel()' 		OPERATION 3 ACCESS 0 // Selecionar
	ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.WMSA100'   OPERATION 2 ACCESS 0 // Visualizar
	ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.WMSA100'   OPERATION 4 ACCESS 0 // Alterar
Return aRotina

//--------------------------------------------------------------------//
//-------------------------Função ModelDef----------------------------//
//--------------------------------------------------------------------//
Static Function ModelDef()
Local aColsSX3 := {}
Local oStruct  := FWFormModelStruct():New()
Local oModel   := MPFormModel():New('WMSA100',,{|oModel| ValidModel(oModel)},{|| GravaTemp(,,,,FwFldGet("TP_PRODUTO"),FwFldGet("TP_QTDSALD"),FwFldGet("TP_NORMA"),FwFldGet("TP_QTDPREV"),FwFldGet("TP_QTDREAB"),2)})
Local aRegra   := StrTokArr(Posicione('SX3',2,'DCF_REGRA','X3CBox()'),';')

	If lWMSAutoma 
		Pergunte("WMSA100",.F.)
		BrwQuery()
	EndIf
	
	AAdd(aRegra," ")
	// Monta Struct da TEMP
	oStruct:AddTable(cAliasBrw, {'TP_LOCAL','TP_LOCALIZ','TP_PRODUTO'},STR0006)
	oStruct:AddIndex(1,'1','TP_LOCAL+TP_LOCALIZ+TP_PRODUTO',buscarSX3('BE_LOCAL',,aColsSX3) + '|' + buscarSX3('BE_LOCALIZ',,aColsSX3),'','',.T.)
	oStruct:AddIndex(2,'2','TP_PRODUTO'                    ,buscarSX3('BF_PRODUTO'                                        ,,aColsSX3),'','',.T.)

	oStruct:AddField(buscarSX3('BE_LOCAL'  ,,aColsSX3),aColsSX3[1],'TP_LOCAL'  ,'C',aColsSX3[3],aColsSX3[4],Nil,{||.T.},Nil,.F.,,.T.,.F.,.T.)
	oStruct:AddField(buscarSX3('BE_LOCALIZ',,aColsSX3),aColsSX3[1],'TP_LOCALIZ','C',aColsSX3[3],aColsSX3[4],Nil,{||.T.},Nil,.F.,,.T.,.F.,.T.)
	oStruct:AddField(buscarSX3('BE_ESTFIS' ,,aColsSX3),aColsSX3[1],'TP_ESTFIS' ,'C',aColsSX3[3],aColsSX3[4],Nil,{||.T.},Nil,.F.,,.F.,.F.,.T.)
	oStruct:AddField(buscarSX3('BE_CODZON' ,,aColsSX3),aColsSX3[1],'TP_CODZON' ,'C',aColsSX3[3],aColsSX3[4],Nil,{||.T.},Nil,.F.,,.F.,.F.,.T.)
	oStruct:AddField(buscarSX3('BF_PRODUTO',,aColsSX3),aColsSX3[1],'TP_PRODUTO','C',aColsSX3[3],aColsSX3[4],FwBuildFeature(STRUCT_FEATURE_VALID,"StaticCall(WMSA100,ValidField)"),FwBuildFeature(STRUCT_FEATURE_WHEN,"StaticCall(WMSA100,WhenField,A,B)"),Nil,.F.,,.F.,.F.,.T.)
	buscarSX3('BF_QUANT',,aColsSX3)
	oStruct:AddField(/*Mesmo BF_QUANT*/        STR0007,STR0007    ,'TP_NORMA'  ,'N',aColsSX3[3],aColsSX3[4],Nil,{||.T.},Nil,.F.,,.F.,.F.,.T.) // Norma
	oStruct:AddField(/*Mesmo BF_QUANT*/        STR0008,STR0008    ,'TP_QTDSALD','N',aColsSX3[3],aColsSX3[4],Nil,{||.T.},Nil,.F.,,.F.,.F.,.T.) // Qtd Saldo
	oStruct:AddField(/*Mesmo BF_QUANT*/        STR0009,STR0009    ,'TP_QTDPREV','N',aColsSX3[3],aColsSX3[4],Nil,{||.T.},Nil,.F.,,.F.,.F.,.T.) //Qtd Prev
	oStruct:AddField(/*Mesmo BF_QUANT*/        STR0010,STR0010    ,'TP_QTDREAB','N',aColsSX3[3],aColsSX3[4],FwBuildFeature(STRUCT_FEATURE_VALID,"StaticCall(WMSA100,ValidField)"),{||.T.},Nil,.F.,,.F.,.F.,.T.) //Qtd Reab
	oStruct:AddField(buscarSX3('DCF_REGRA' ,,aColsSX3),aColsSX3[1],'TP_REGRA'  ,'C',aColsSX3[3],aColsSX3[4],Nil,{||.T.},aRegra,.F.,,.F.,.F.,.T.)

	oModel:AddFields('PKGMASTER', /*cOwner*/, oStruct)
	oModel:SetPrimaryKey({'TP_LOCAL','TP_LOCALIZ','TP_PRODUTO'})
	oModel:SetDescription(STR0001)
Return oModel

//-------------------------------------------------------------------//
//-------------------------Função ViewDef----------------------------//
//-------------------------------------------------------------------//
Static Function ViewDef()
Local aColsSX3 := {}
Local oModel   := FWLoadModel('WMSA100')
Local oView    := FWFormView():New()
Local oStruct  := FWFormViewStruct():New()
Local aRegra   := StrTokArr(Posicione('SX3',2,'DCF_REGRA','X3CBox()'),';')

	AAdd(aRegra," ")
	//Monta Struct da TEMP
	oStruct:AddField('TP_LOCAL'  ,'01',buscarSX3('BE_LOCAL'  ,,aColsSX3),aColsSX3[1],Nil,'GET',aColsSX3[2],Nil,'NNR',.F.,Nil,Nil,Nil,Nil,Nil,.T.)
	oStruct:AddField('TP_LOCALIZ','02',buscarSX3('BE_LOCALIZ',,aColsSX3),aColsSX3[1],Nil,'GET',aColsSX3[2],Nil,'SBE',.F.,Nil,Nil,Nil,Nil,Nil,.T.)
	oStruct:AddField('TP_ESTFIS' ,'03',buscarSX3('BE_ESTFIS' ,,aColsSX3),aColsSX3[1],Nil,'GET',aColsSX3[2],Nil,Nil  ,.F.,Nil,Nil,Nil,Nil,Nil,.T.)
	oStruct:AddField('TP_CODZON' ,'04',buscarSX3('BE_CODZON' ,,aColsSX3),aColsSX3[1],Nil,'GET',aColsSX3[2],Nil,Nil  ,.F.,Nil,Nil,Nil,Nil,Nil,.T.)
	oStruct:AddField('TP_PRODUTO','05',buscarSX3('BF_PRODUTO',,aColsSX3),aColsSX3[1],Nil,'GET',aColsSX3[2],Nil,'SB5',.T.,Nil,Nil,Nil,Nil,Nil,.T.)
	buscarSX3('BF_QUANT',,aColsSX3)
	oStruct:AddField('TP_NORMA'  ,'06',/*Mesmo BF_QUANT*/        STR0007,STR0007    ,Nil,'GET',aColsSX3[2],Nil,Nil  ,.F.,Nil,Nil,Nil,Nil,Nil,.T.) // Norma
	oStruct:AddField('TP_QTDSALD','07',/*Mesmo BF_QUANT*/        STR0008,STR0008    ,Nil,'GET',aColsSX3[2],Nil,Nil  ,.F.,Nil,Nil,Nil,Nil,Nil,.T.) // Qtd Saldo
	oStruct:AddField('TP_QTDPREV','08',/*Mesmo BF_QUANT*/        STR0009,STR0009    ,Nil,'GET',aColsSX3[2],Nil,Nil  ,.F.,Nil,Nil,Nil,Nil,Nil,.T.) // Qtd Prev
	oStruct:AddField('TP_QTDREAB','09',/*Mesmo BF_QUANT*/        STR0010,STR0010    ,Nil,'GET',aColsSX3[2],Nil,Nil  ,.T.,Nil,Nil,Nil,Nil,Nil,.T.) //Qtd Reab
	oStruct:AddField('TP_REGRA'  ,'10',buscarSX3('DCF_REGRA' ,,aColsSX3),aColsSX3[1],Nil,'GET',aColsSX3[2],Nil,Nil  ,.T.,Nil,Nil,aRegra,10,Nil,.T.)

	oView:SetModel(oModel)
	oView:AddField("VIEW_PKG",oStruct,"PKGMASTER")
	oView:CreateHorizontalBox("TELA",100)
	oView:SetOwnerView("VIEW_PKG","TELA")
	oView:SetDescription(STR0001)
	oView:SetAfterOkButton({|oModel| AfterOKView(oModel)})
	oView:SetCloseOnOk({||.T.})
Return oView

//-------------------------------------------------------------------------------//
//-------------------------Realiza validação do Model----------------------------//
//-------------------------------------------------------------------------------//
Static Function ValidModel(oModel)
Return .T.

//-------------------------------------------------------------------------------------------------------------//
//-------------------------Desmarca os registros onde não se tem informação de produto-------------------------//
//------------------------------e marca os registros onde essa informação existe-------------------------------//
//-------------------------------------------------------------------------------------------------------------//
Static Function AfterOKView(oModel)
Local cProduto := oModel:GetValue('PKGMASTER','TP_PRODUTO')
	If Empty(cProduto)
		If oBrowse:IsMark()
			oBrowse:SetValid({||.T.}) // Retira o evento de validação
			oBrowse:MarkRec() // Desmarca o registro
			oBrowse:SetValid({||!Empty((cAliasBrw)->TP_PRODUTO)}) // Recoloca o evento de validação
		EndIf
	Else
		If !oBrowse:IsMark()
			oBrowse:MarkRec() // Marca o registro
		EndIf
	EndIf
Return .T.

//---------------------------------------------------------------------------------------------------------//
//-------------------------Realiza busca dos dados que serão exibidos no Browse----------------------------//
//---------------------------------------------------------------------------------------------------------//
Static Function BrwAllMark()
Local aAreaAnt  := GetArea()
	lMarkAll := !lMarkAll
	nContTMP := 0
	(cAliasBrw)->(DbGoTop())
	While (cAliasBrw)->(!Eof())
		If !Empty((cAliasBrw)->TP_PRODUTO)
			RecLock(cAliasBrw,.F.)
			(cAliasBrw)->TP_MARK := Iif(lMarkAll,cMarca," ")
			MsUnlock()
			If !Empty((cAliasBrw)->TP_MARK)
				nContTMP++
			EndIf
		EndIf
		(cAliasBrw)->(DbSkip())
	EndDo
	(cAliasBrw)->(DbGoTop())
RestArea(aAreaAnt)
oBrowse:Refresh()
Return Nil
//---------------------------------------------------------------------------------------------------------//
//-------------------------Realiza busca dos dados que serão exibidos no Browse----------------------------//
//---------------------------------------------------------------------------------------------------------//
Static Function BrwQuery(lCriaTemp)
Local cQuery    := ""
Local cAliasQry := ""
Local cAliasSDB := ""
Local cProduto  := ""
Local nQtdSaldo := 0
Local nQtdPrev  := 0
Local nQtdNorma := 0
Local nQtdReab  := 0
Local lGeraReab := .T.
Local lRadioF   := (SuperGetMV('MV_RADIOF')=="S")
Local cLocAnt   := ""
Local cEndAnt   := ""

Default lCriaTemp := .T.
	If lCriaTemp
		If !CriaTemp()
			Return .F.
		EndIf
	EndIf
	nContTMP = 0

	cQuery := "SELECT SBE.BE_LOCAL, SBE.BE_LOCALIZ, SBE.BE_ESTFIS, SBE.BE_CODZON, SBE.BE_CODPRO, SBF.BF_PRODUTO, SBF.BF_QUANT"
	cQuery +=  " FROM "+RetSqlName("DC8")+" DC8, "+RetSqlName("SBE")+" SBE"
	cQuery +=  " LEFT JOIN (SELECT BF_LOCAL, BF_LOCALIZ, BF_PRODUTO, SUM(BF_QUANT) BF_QUANT"
	cQuery +=               " FROM "+RetSqlName("SBF")+" SBF"
	cQuery +=              " WHERE SBF.BF_FILIAL = '"+xFilial("SBF")+"'"
	cQuery +=                " AND SBF.BF_QUANT > 0"
	cQuery +=                " AND SBF.D_E_L_E_T_ = ' '"
	cQuery +=              " GROUP BY BF_LOCAL, BF_LOCALIZ, BF_PRODUTO) SBF"
	cQuery +=    " ON SBF.BF_LOCAL = SBE.BE_LOCAL"
	cQuery +=   " AND SBF.BF_LOCALIZ = SBE.BE_LOCALIZ "
	cQuery += " WHERE SBE.BE_FILIAL = '"+xFilial("SBE")+"'"
	cQuery +=   " AND DC8.DC8_FILIAL = '"+xFilial("DC8")+ "'"
	cQuery +=   " AND DC8.D_E_L_E_T_ = ' '"
	cQuery +=   " AND SBE.D_E_L_E_T_ = ' '"
	cQuery +=   " AND SBE.BE_ESTFIS = DC8.DC8_CODEST"
	cQuery +=   " AND DC8.DC8_TPESTR = '2'"
	cQuery +=   " AND SBE.BE_LOCAL   BETWEEN '"+ mv_par01 +"' AND '"+ mv_par02 +"'" // Filtro de Armazem de/até
	cQuery +=   " AND SBE.BE_CODZON  BETWEEN '"+ mv_par03 +"' AND '"+ mv_par04 +"'" // Filtro de Zona de/até
	cQuery +=   " AND SBE.BE_LOCALIZ BETWEEN '"+ mv_par05 +"' AND '"+ mv_par06 +"'" // Filtro de Endereço de/até
	cQuery +=   " AND SBE.BE_CODPRO  BETWEEN '"+ mv_par07 +"' AND '"+ mv_par08 +"'" // Filtro de Produto de/até
	If mv_par09 == 1 // Somente picking fixo
		cQuery += " AND SBE.BE_CODPRO <> ' '"
	EndIf
	cQuery += " ORDER BY SBE.BE_LOCAL, SBE.BE_LOCALIZ, SBE.BE_CODPRO, SBF.BF_PRODUTO"
	cQuery := ChangeQuery(cQuery)
	cAliasQry := GetNextAlias()
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
	(cAliasQry)->(DbGoTop())
	While !(cAliasQry)->(Eof())
		lGeraReab := .T.
		cProduto := Iif(Empty((cAliasQry)->BF_PRODUTO),(cAliasQry)->BE_CODPRO,(cAliasQry)->BF_PRODUTO)
		//Se o endereço possui saldo ou é especifico de um determinado produto
		If !Empty(cProduto)
			nQtdSaldo := Iif(Empty((cAliasQry)->BF_QUANT),0,(cAliasQry)->BF_QUANT)
			nQtdNorma := DLQtdNorma(cProduto, (cAliasQry)->BE_LOCAL, (cAliasQry)->BE_ESTFIS, /*cDesUni*/, /*lNUnit*/, (cAliasQry)->BE_LOCALIZ)
			//Deve verificar se o endereço já possui previsão de reabastecimento
			If lRadioF
				nQtdPrev := ConSldRF((cAliasQry)->BE_LOCAL,(cAliasQry)->BE_LOCALIZ,cProduto,Nil,Nil,0,.T.,'1',.F.,.T.,.T.,.F.)
			Else
				nQtdPrev := 0
			EndIf
			nQtdReab  := nQtdNorma - (nQtdSaldo + nQtdPrev)
			GravaTemp((cAliasQry)->BE_LOCAL,(cAliasQry)->BE_LOCALIZ,(cAliasQry)->BE_ESTFIS,(cAliasQry)->BE_CODZON,cProduto,nQtdSaldo,nQtdNorma,nQtdPrev,nQtdReab)
		Else
			nQtdSaldo := 0
			If lRadioF
				// Verifica se já existe previsão de reabastecimento para algum produto
				cQuery  = "SELECT DB_PRODUTO FROM "+RetSqlName("SDB")
				cQuery += " WHERE DB_FILIAL = '"+xFilial("SDB")+"'"
				cQuery +=   " AND DB_ATUEST = 'N'"
				cQuery +=   " AND DB_STATUS IN ('4','3','2','-')"
				cQuery +=   " AND DB_ESTORNO = ' '"
				cQuery +=   " AND DB_LOCAL = '"+(cAliasQry)->BE_LOCAL+"'"
				cQuery +=   " AND DB_ENDDES = '"+(cAliasQry)->BE_LOCALIZ+"'"
				cQuery +=   " AND D_E_L_E_T_ = ' '"
				cQuery += " GROUP BY DB_PRODUTO"
				cAliasSDB := GetNextAlias()
				DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasSDB,.F.,.T.)
				While !(cAliasSDB)->(Eof())
					cProduto  := (cAliasSDB)->DB_PRODUTO
					nQtdNorma := DLQtdNorma(cProduto, (cAliasQry)->BE_LOCAL, (cAliasQry)->BE_ESTFIS, /*cDesUni*/, /*lNUnit*/, (cAliasQry)->BE_LOCALIZ)
					nQtdPrev  := ConSldRF((cAliasQry)->BE_LOCAL,(cAliasQry)->BE_LOCALIZ,cProduto,Nil,Nil,0,.T.,'1',.F.,.T.,.T.,.F.)
					nQtdReab  := nQtdNorma - nQtdPrev
					// Somente grava se sobrou saldo a reabastecer e se existe alguma previsão para o produto
					GravaTemp((cAliasQry)->BE_LOCAL,(cAliasQry)->BE_LOCALIZ,(cAliasQry)->BE_ESTFIS,(cAliasQry)->BE_CODZON,cProduto,nQtdSaldo,nQtdNorma,nQtdPrev,nQtdReab)
					lGeraReab := .F. //Já gerou para um produto, não deve gerar em branco
					(cAliasSDB)->(DbSkip())
				EndDo
				(cAliasSDB)->(DbCloseArea())
			EndIf
			// Grava apenas o endereço em branco para geração de reabastecimento
			If lGeraReab
				GravaTemp((cAliasQry)->BE_LOCAL,(cAliasQry)->BE_LOCALIZ,(cAliasQry)->BE_ESTFIS,(cAliasQry)->BE_CODZON,Nil,0,0,0,0)
			EndIf
		EndIf
		// Se o endereço não é especifico para um produto, deve verificar se o mesmo é compartilhado
		If Empty((cAliasQry)->BE_CODPRO) .And. !Empty(cLocAnt+cEndAnt) .And.;
			(cLocAnt+cEndAnt) != ((cAliasQry)->BE_LOCAL+(cAliasQry)->BE_LOCALIZ)
			ChkEndDCP(cLocAnt,cEndAnt,lRadioF)
		EndIf
		cLocAnt := (cAliasQry)->BE_LOCAL
		cEndAnt := (cAliasQry)->BE_LOCALIZ
		(cAliasQry)->(DbSkip())
	EndDo
	(cAliasQry)->(DbCloseArea())
	(cAliasBrw)->(DbGoTop())
	// Verifica se o ultimo endereço é compartilhado
	If !Empty(cLocAnt+cEndAnt)
		ChkEndDCP(cLocAnt,cEndAnt,lRadioF)
	EndIf
	// Exclui os endereços que não precisam ser reabastecidos
	(cAliasBrw)->(DbGoTop())
	While !(cAliasBrw)->(Eof())
		If !Empty((cAliasBrw)->TP_PRODUTO)
			// Se não deve reabastecer nada para o endereço dele o mesmo
			If (QtdComp((cAliasBrw)->TP_QTDREAB) <= QtdComp(0)) .Or.;
				(QtdComp((cAliasBrw)->TP_QTDREAB) < QtdComp((cAliasBrw)->TP_NORMA * (mv_par10/100)))
				RecLock(cAliasBrw,.F.)
				(cAliasBrw)->(DbDelete())
				MsUnlock(cAliasBrw)
			EndIf
		EndIf
		(cAliasBrw)->(DbSkip())
	EndDo
	(cAliasBrw)->(__DBPack())
Return .T.

//--------------------------------------------------------------------------------//
//-------Verifica se o endereço é compartilhado via percentual de ocupação--------//
//--------------------------------------------------------------------------------//
Static Function ChkEndDCP(cLocal,cEndereco,lRadioF)
Local nQtdNorma := 0
Local nQtdPrev  := 0
Local nQtdReab  := 0
	DCP->(DbSetOrder(1))
	If DCP->(DbSeek(cSeekDCP := xFilial('DCP')+cLocal+cEndereco,.F.))
		While DCP->(!Eof() .And. cSeekDCP==(xFilial('DCP')+DCP_LOCAL+DCP_ENDERE))
			// Se não foi informado o produto, não considera
			If Empty(DCP->DCP_CODPRO)
				DCP->(DbSkip())
				Loop
			EndIf
			// Se ainda não existir na TEMP
			If (cAliasBrw)->(!MsSeek(DCP->(DCP_LOCAL+DCP_ENDERE+DCP_CODPRO),.F.))
				nQtdNorma := DLQtdNorma(DCP->DCP_CODPRO,DCP->DCP_LOCAL,DCP->DCP_ESTFIS, /*cDesUni*/, /*lNUnit*/,DCP->DCP_ENDERE)
				If lRadioF
					nQtdPrev := ConSldRF(DCP->DCP_LOCAL,DCP->DCP_ENDERE,DCP->DCP_CODPRO,Nil,Nil,0,.T.,'1',.F.,.T.,.T.,.F.)
				Else
					nQtdPrev := 0
				EndIf
				nQtdReab := nQtdNorma - nQtdPrev
				GravaTemp(DCP->DCP_LOCAL,DCP->DCP_ENDERE,DCP->DCP_ESTFIS,Posicione('SBE',1,xFilial('SBE')+DCP->DCP_LOCAL+DCP->DCP_ENDERE,'BE_CODZON'),DCP->DCP_CODPRO,0,nQtdNorma,nQtdPrev,nQtdReab)
			EndIf
			DCP->(DbSkip())
		EndDo
	EndIf
Return

//----------------------------------------------------------------------------------------//
//-------------------------Grava os dados na tabela temporária----------------------------//
//----------------------------------------------------------------------------------------//
Static Function GravaTemp(cLocal,cEndereco,cEstFis,cCodZona,cProduto,nQtdSaldo,nQtdNorma,nQtdPrev,nQtdReab,nAcao)
Default nAcao = 1

	If nAcao == 1
		RecLock(cAliasBrw,.T.)
		(cAliasBrw)->TP_MARK    := Iif(!Empty(cProduto),cMarca," ")
		(cAliasBrw)->TP_LOCAL   := cLocal
		(cAliasBrw)->TP_LOCALIZ := cEndereco
		(cAliasBrw)->TP_ESTFIS  := cEstFis
		(cAliasBrw)->TP_CODZON  := cCodZona
		(cAliasBrw)->TP_PRODUTO := cProduto
		(cAliasBrw)->TP_NORMA   := nQtdNorma
		(cAliasBrw)->TP_QTDSALD := nQtdSaldo
		(cAliasBrw)->TP_QTDPREV := nQtdPrev
		(cAliasBrw)->TP_QTDREAB := nQtdReab
		(cAliasBrw)->TP_REGRA   := ''
		(cAliasBrw)->TP_ALTPRD  := Iif(!Empty(cProduto),"N","S")
		MsUnlock(cAliasBrw)
		If !Empty((cAliasBrw)->TP_MARK)
			nContTMP++
		EndIf
	ElseIf nAcao == 2
		RecLock(cAliasBrw,.F.)
		(cAliasBrw)->TP_PRODUTO := cProduto
		(cAliasBrw)->TP_NORMA   := nQtdNorma
		(cAliasBrw)->TP_QTDSALD := nQtdSaldo
		(cAliasBrw)->TP_QTDPREV := nQtdPrev
		(cAliasBrw)->TP_QTDREAB := nQtdReab
		(cAliasBrw)->TP_REGRA   := FwFldGet("TP_REGRA")
		(cAliasBrw)->(MsUnlock())
	EndIf
Return .T.

//-----------------------------------------------------------------------------//
//-------------------------Cria a tabela temporária----------------------------//
//-----------------------------------------------------------------------------//
Static Function CriaTemp()
Local aColsSX3 := {}
Local aColsBrw  := {}

	/*Coluna de marcação*/             AAdd(aColsBrw,{"TP_MARK"   ,"C",          1,          0})
	buscarSX3("BE_LOCAL"  ,,aColsSX3); AAdd(aColsBrw,{"TP_LOCAL"  ,"C",aColsSX3[3],aColsSX3[4]})
	buscarSX3("BE_LOCALIZ",,aColsSX3); AAdd(aColsBrw,{"TP_LOCALIZ","C",aColsSX3[3],aColsSX3[4]})
	buscarSX3("BE_ESTFIS" ,,aColsSX3); AAdd(aColsBrw,{"TP_ESTFIS" ,"C",aColsSX3[3],aColsSX3[4]})
	buscarSX3("BE_CODZON" ,,aColsSX3); AAdd(aColsBrw,{"TP_CODZON" ,"C",aColsSX3[3],aColsSX3[4]})
	buscarSX3("BF_PRODUTO",,aColsSX3); AAdd(aColsBrw,{"TP_PRODUTO","C",aColsSX3[3],aColsSX3[4]})
	buscarSX3("BF_QUANT"  ,,aColsSX3); AAdd(aColsBrw,{"TP_NORMA"  ,"N",aColsSX3[3],aColsSX3[4]})
  /*As mesmas informações do saldo*/  AAdd(aColsBrw,{"TP_QTDSALD","N",aColsSX3[3],aColsSX3[4]})
  /*As mesmas informações do saldo*/  AAdd(aColsBrw,{"TP_QTDPREV","N",aColsSX3[3],aColsSX3[4]})
  /*As mesmas informações do saldo*/  AAdd(aColsBrw,{"TP_QTDREAB","N",aColsSX3[3],aColsSX3[4]})
	buscarSX3("DCF_REGRA" ,,aColsSX3); AAdd(aColsBrw,{"TP_REGRA"  ,"C",aColsSX3[3],aColsSX3[4]})
	/*Coluna oculta auxiliar*/         AAdd(aColsBrw,{"TP_ALTPRD" ,"C",          1,          0})

	// Cria tabelas temporárias
	criaTabTmp(aColsBrw,{'TP_LOCAL+TP_LOCALIZ+TP_PRODUTO','TP_PRODUTO'},cAliasBrw)
Return .T.

//-----------------------------------------------------------------------------------------------------------//
//-------------------------Validação que seta se é possível alteração do registro----------------------------//
//-----------------------------------------------------------------------------------------------------------//
Static Function WhenField(oModel,cField)
	Do Case
	Case cField == "TP_PRODUTO"
		Return Iif((cAliasBrw)->TP_ALTPRD=="N",.F.,.T.)
	EndCase
Return .T.

//---------------------------------------------------------------------------------//
//-------------------------Realiza validação do Produto----------------------------//
//---------------------------------------------------------------------------------//
Static Function ValidField()
Local lRet      := .T.
Local cField    := SubStr(ReadVar(),4)
Local cProduto  := ""
Local cCodZona  := ""
Local nQtdNorma := 0
Local nQtdReab  := 0
Local nQtdMax   := 0

	Do Case
		Case cField == "TP_PRODUTO"
			cProduto := FwFldGet("TP_PRODUTO")
			If Empty(cProduto)
				FWFldPut('TP_NORMA',0)
				FWFldPut('TP_QTDREAB',0)
				Return .T.
			EndIf
			// Valida se o produto existe
			If !ExistCpo('SB1',cProduto)
				Return .F.
			EndIf
			// Valida se o complemento do produto existe
			DbSelectArea('SB5')
			SB5->(DbSetOrder(1))
			If (SB5->(!MsSeek(xFilial('SB5')+cProduto,.F.)))
				Help(,,,,STR0011+' '+AllTrim(cProduto)+' '+STR0012,1,0) // Produto '#####' não cadastrado nos Dados Adicionais do Produto (SB5).
				lRet := .F.
			Else
				cCodZona := SB5->B5_CODZON
			EndIf
			SB5->(DbCloseArea())
			If lRet .And. Empty(cCodZona)
				Help(,,,,STR0011+' '+AllTrim(cProduto)+' '+STR0013,1,0) // Produto '#####' não possui Zona de Armazenagem informada (SB5).
				lRet := .F.
			EndIf
			If lRet .And. cCodZona != M->TP_CODZON
				// Deve validar se existe uma zona alternativa
				DbSelectArea('DCH')
				DCH->(DbSetOrder(1)) // DCH_FILIAL+DCH_CODPRO+DCH_CODZON
				If DCH->(!MsSeek(xFilial('DCH')+cProduto+M->TP_CODZON,.F.))
					Help(,,,,STR0011+' '+AllTrim(cProduto)+' '+STR0014+' '+AllTrim(M->TP_CODZON)+'.',1,0) // Produto '#####' não pode ser armazenado na Zona de Armazenagem '#####'.
					lRet := .F.
				EndIf
				DCH->(DbCloseArea())
			EndIf
			// Se o produto foi validado deve buscar as informações do mesmo
			If lRet
				nQtdNorma := DLQtdNorma(cProduto, M->TP_LOCAL, M->TP_ESTFIS, /*cDesUni*/, /*lNUnit*/, M->TP_LOCALIZ)
				FWFldPut('TP_NORMA',nQtdNorma)
				FWFldPut('TP_QTDREAB',nQtdNorma)
			EndIf
		Case cField == "TP_QTDREAB"
			nQtdReab := FwFldGet("TP_QTDREAB")
			// Na inclusão de um produto em um endereço vazio, deve validar a quantidade informada contra a norma
			If (cAliasBrw)->TP_ALTPRD == 'S'
				nQtdNorma := DLQtdNorma(M->TP_PRODUTO, M->TP_LOCAL, M->TP_ESTFIS, /*cDesUni*/, /*lNUnit*/, M->TP_LOCALIZ)
				If nQtdNorma < nQtdReab
					Help(,,,,STR0018 + AllTrim(Str(nQtdNorma)) + '.',1,0) // Valor inválido! A quantidade para reabastecimento deste endereço não pode ser superior a
					lRet := .F.
				EndIf
			// Senão, deve validar a quantidade informada contra o que foi calculado automaticamente pelo sistema
			Else
				nQtdMax := (cAliasBrw)->TP_NORMA - (cAliasBrw)->TP_QTDSALD - (cAliasBrw)->TP_QTDPREV
				If QtdComp(nQtdMax) < QtdComp(nQtdReab)
					Help(,,,,STR0018 + AllTrim(Str(nQtdMax)) + '.',1,0) // Valor inválido! A quantidade para reabastecimento deste endereço não pode ser superior a
					lRet := .F.
				EndIf
			EndIf
	EndCase
Return lRet

//--------------------------------------------------------------------------------------------------//
//-------------------------Chama a função que processa o reabastecimento----------------------------//
//--------------------------------------------------------------------------------------------------//
Function WMS100PReb()
	If nContTMP <= 0
		WmsMessage(STR0017,,1) // Selecione ao menos um item para processar o reabastecimento.
	Else
		// Chamada da função é feita desta forma para que apareça na tela a régua de progressão
		Processa({|| ProcReab01()},STR0001,OemToAnsi(STR0015),.T.) // Reabastecimento // Processando Reabastecimento...
	EndIf
Return

//-------------------------------------------------------------------------------//
//-------------------------Processa o Reabastecimento----------------------------//
//-------------------------------------------------------------------------------//
Static Function ProcReab01()
Local aAreaAnt   := GetArea()
Local lRet       := .T.
Local lRadioF    := (SuperGetMV('MV_RADIOF')=="S")
Local nQtdReab   := 0
Local cDocto     := ""
Local cSerie     := Space(TamSX3("DCF_SERIE")[1])
Local aMsgLog    := {}
Local nCntMsg    := 0
Local cMensagem  := ""
Local lDocSx8    := .F.

  // Carrega o serviço padrão de reabastecimento
	DbSelectArea('DC5')
	DC5->(DbSetOrder(3)) // DC5_FILIAL+DC5_FUNEXE
	If DC5->(!MsSeek(xFilial('DC5')+'000003'))
		WmsMessage(STR0016,,2)// Não existe um serviço de reabastecimento cadastrado.
		RestArea(aAreaAnt)
		Return .F.
	EndIf

	Private aParam150 := Array(34)
	cDocto := GetSX8Num('DCF', 'DCF_DOCTO')

	// Valor máximo que terá a régua de progressão
	ProcRegua(nContTMP)

	(cAliasBrw)->(DbGoTop())
	While (cAliasBrw)->(!Eof())
		If !Empty((cAliasBrw)->TP_MARK)
			// Incremento da régua de progressão
			IncProc((cAliasBrw)->(TP_LOCAL+"/"+AllTrim(TP_LOCALIZ)+"/"+TP_PRODUTO))

			aParam150[01] := (cAliasBrw)->TP_PRODUTO // Produto
			aParam150[02] := (cAliasBrw)->TP_LOCAL   // Armazem Origem
			aParam150[03] := cDocto // Documento
			aParam150[04] := cSerie // Serie
			aParam150[06] := (cAliasBrw)->TP_QTDREAB
			aParam150[25] := (cAliasBrw)->TP_LOCAL   // Armazem Destino
			aParam150[27] := (cAliasBrw)->TP_ESTFIS  // Estrutura Destino
			aParam150[26] := (cAliasBrw)->TP_LOCALIZ // Endereco Destino
			aParam150[22] := Val((cAliasBrw)->TP_REGRA) // Regra para o Apanhe - 1=Lote/2=Numero de Serie/3=Data
			aParam150[09] := "" // Limpa o serviço, força busca
			aParam150[10] := "" // Limpa a tarefa, força busca
			aParam150[28] := "" // Limpa a ordem da tarefa, força busca
			nQtdReab := 0

			Begin Transaction
				If (lRet := WmsAbastece(lRadioF,"1","M",@nQtdReab))
					If QtdComp(nQtdReab) >= QtdComp((cAliasBrw)->TP_QTDREAB)
						cMensagem := STR0021  // Reabastecimento gerado com sucesso.
						lDocSx8 := .T.
					Else
						If QtdComp(nQtdReab) > 0
							cMensagem := WmsFmtMsg(STR0019,{{"[VAR01]",(cAliasBrw)->TP_LOCALIZ},{"[VAR02]",(cAliasBrw)->TP_PRODUTO}}) // Não foi possível reabastecer toda a quantidade para o endereço [VAR01] para o produto [VAR02].
							lDocSx8 := .T.
						Else
							cMensagem := WmsFmtMsg(STR0020,{{"[VAR01]",(cAliasBrw)->TP_LOCALIZ},{"[VAR02]",(cAliasBrw)->TP_PRODUTO}}) // Não foi possível reabastecer nenhuma quantidade para o endereço [VAR01] para o produto [VAR02].
						EndIf
					EndIf
				Else
					cMensagem := WmsLastMsg()
				EndIf
			End Transaction

			SB1->(DbSetOrder(1))
			SB1->(DbSeek(xFilial('SB1')+(cAliasBrw)->TP_PRODUTO))

			AAdd(aMsgLog,Array(09))
			nCntMsg := Len(aMsgLog)
			aMsgLog[nCntMsg][01] := (cAliasBrw)->TP_LOCAL   // Armazém Destino
			aMsgLog[nCntMsg][02] := (cAliasBrw)->TP_ESTFIS  // Estutura Destino
			aMsgLog[nCntMsg][03] := (cAliasBrw)->TP_LOCALIZ // Endereço Destino
			aMsgLog[nCntMsg][04] := (cAliasBrw)->TP_PRODUTO // Produto Reabastecimento
			aMsgLog[nCntMsg][05] := SB1->B1_DESC            // Descrição do Produto Reabastecimento
			aMsgLog[nCntMsg][06] := (cAliasBrw)->TP_LOCAL   // Armazém Origem Reabastecimento
			aMsgLog[nCntMsg][07] := (cAliasBrw)->TP_QTDREAB // Quantidade solicitada reabastecer
			aMsgLog[nCntMsg][08] := nQtdReab                // Quantidade reabastecida
			aMsgLog[nCntMsg][09] := cMensagem               // Mensagem
		EndIf
		(cAliasBrw)->(DbSkip())
	EndDo
	If lDocSx8 .And. ( __lSX8 )
		ConfirmSX8()
	Else
		RollBackSX8()
	EndIf
	(cAliasBrw)->(DbGoTop())
	RestArea(aAreaAnt)
	WMSR100(aMsgLog)
	If !lWmsAutoma
		WMS100Sel(.F.)
	ENDiF
Return lRet

//----------------------------------------------------------------------------------------------------//
//------------------------------Permite selecionar novamente o intervalo------------------------------//
//----------------------------------e recarregar os dados no Browse-----------------------------------//
//----------------------------------------------------------------------------------------------------//
Function WMS100Sel(lPergunte)
Default lPergunte := .T. // Variável = .F. para quando se usa a função apenas para recarregar os dados
	If lPergunte
		If !Pergunte("WMSA100",.T.)
			Return
		EndIf
	EndIf
	DbSelectArea(cAliasBrw)
	ZAP // Apaga os dados da tabela temporária cAliasBrw
	BrwQuery(.F.)
	oBrowse:Refresh()
	 	
Return
