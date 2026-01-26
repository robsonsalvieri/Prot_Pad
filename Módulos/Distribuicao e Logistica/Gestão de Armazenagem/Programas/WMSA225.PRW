#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "WMSA225.CH"

#DEFINE WMSA22501 "WMSA22501"
#DEFINE WMSA22502 "WMSA22502"
#DEFINE WMSA22503 "WMSA22503"
#DEFINE WMSA22504 "WMSA22504"
#DEFINE WMSA22505 "WMSA22505"
#DEFINE WMSA22506 "WMSA22506"
#DEFINE WMSA22507 "WMSA22507"
#DEFINE WMSA22508 "WMSA22508"
#DEFINE WMSA22509 "WMSA22509"
#DEFINE WMSA22510 "WMSA22510"
#DEFINE WMSA22511 "WMSA22511"
#DEFINE WMSA22512 "WMSA22512"
#DEFINE WMSA22513 "WMSA22513"
#DEFINE WMSA22514 "WMSA22514"
#DEFINE WMSA22515 "WMSA22515"
#DEFINE WMSA22516 "WMSA22516"
#DEFINE WMSA22517 "WMSA22517"
#DEFINE WMSA22518 "WMSA22518"
#DEFINE WMSA22519 "WMSA22519"
#DEFINE WMSA22520 "WMSA22520"
#DEFINE WMSA22521 "WMSA22521"
#DEFINE WMSA22522 "WMSA22522"
#DEFINE WMSA22523 "WMSA22523"
#DEFINE WMSA22524 "WMSA22524"
#DEFINE WMSA22525 "WMSA22525"

Static nOperation := 0
Static lPermTrfBlq := SuperGetMv("MV_WMSTRBL",.F.,.F.)
//-------------------------------------
/*/{Protheus.doc} WMSA225
Tranferencia entre endereços e entre armazéns
@author felipe.m
@since 11/12/2014
@version 1.0
/*/
//-------------------------------------
Function WMSA225()
Local oBrw

	// Permite efetuar validações, apresentar mensagem e abortar o programa quando desejado
	If !WMSChkPrg(FunName(),"1")
		Return Nil
	EndIf

	oBrw := FWMBrowse():New()
	oBrw:SetAlias("DCF")
	oBrw:SetDescription(STR0001) // Tranferência WMS
	oBrw:AddLegend("!Empty(DCF_SERVIC).And.DCF_STSERV=='1'","GREEN" ,STR0002) // O.S. Não Executada
	oBrw:AddLegend("!Empty(DCF_SERVIC).And.DCF_STSERV=='2'","YELLOW",STR0003) // O.S. Interrompida
	oBrw:AddLegend("!Empty(DCF_SERVIC).And.DCF_STSERV=='3'","RED"   ,STR0004) // O.S. Executada
	oBrw:AddLegend("Empty(DCF_SERVIC)"                     ,"BLACK" ,STR0005) // O.S. Sem Serviço
	oBrw:AddLegend("!Empty(DCF_SERVIC).And.DCF_STSERV=='0'","WHITE" ,STR0006) // O.S. Cancelada
	oBrw:SetFilterDeafult("@ DCF_ORIGEM = 'DCF' OR (DCF_ORIGEM = 'DH1' AND DCF_LOCAL <> DCF_LOCDES)")
	oBrw:Activate()
Return

//-------------------------------------
/*/{Protheus.doc} MenuDef
MenuDef
@author felipe.m
@since 11/12/2014
@version 1.0
/*/
//-------------------------------------
Static Function MenuDef()
Private aRotina := {}
	ADD OPTION aRotina TITLE STR0007 ACTION 'PesqBrw'       OPERATION 1 ACCESS 0 // Pesquisar
	ADD OPTION aRotina TITLE STR0008 ACTION 'WMSA225MEN(2)' OPERATION 1 ACCESS 0 // Visualizar
	ADD OPTION aRotina TITLE STR0009 ACTION 'WMSA225MEN(3)' OPERATION 3 ACCESS 0 // Incluir
	ADD OPTION aRotina TITLE STR0011 ACTION 'WMSA225MEN(4)' OPERATION 4 ACCESS 0 // Excluir
Return aRotina
//-------------------------------------
/*/{Protheus.doc} ModelDef
ModelDef
@author felipe.m
@since 11/12/2014
@version 1.0
/*/
//-------------------------------------
Static Function ModelDef()
Local oModel
Local oStrDCF    := FWFormStruct(1,'DCF')
Local oStructTab := FWFormModelStruct():New()
Local aColsSX3   := {}
Local cDocto := ""

	oModel := MPFormModel():New('WMSA225',,{|oModel| WMS225VMdl(oModel) },{|oModel| WMS225Cmmt(oModel) })
	oModel:AddFields('DCFMASTER',,oStrDCF)
	oModel:SetDescription(STR0001) // Tranferência WMS
	oModel:GetModel('DCFMASTER'):SetDescription(STR0001) // Tranferência WMS

	oStrDCF:SetProperty('*' ,MODEL_FIELD_OBRIGAT,.F.)
	If nOperation == MODEL_OPERATION_INSERT
		oStrDCF:SetProperty('DCF_DOCTO',MODEL_FIELD_INIT,{|| cDocto := GetSX8Num("DCF","DCF_DOCTO"),Iif(__lSX8,ConfirmSX8(),Nil),cDocto })

		// Monta Struct
		oStructTab:AddTable('SELECAO', {'CODPRO'},'Selecao')
		oStructTab:AddIndex(1,'1','CODPRO',STR0023,'','',.T.) // Produto

		buscarSX3("B1_COD",,aColsSX3);      oStructTab:AddField(aColsSX3[1],STR0012,'CODPRO' ,'C',aColsSX3[3],aColsSX3[4],Nil,{||.F.},Nil,.F.,,.F.,.F.,.F.) // cTitulo ,cTooltip,cIdField,cTipo,nTamanho,nDecimal,bValid,bWhen,aValues,lObrigat,bInit,lKey,lNoUpd,lVirtual,cValid // Código do Produto
		buscarSX3("DCF_QUANT",,aColsSX3);   oStructTab:AddField(aColsSX3[1],STR0013,'QUANT'  ,'N',aColsSX3[3],aColsSX3[4],Nil,{||.T.},Nil,.F.,,.F.,.T.,.F.) // Quantidade
		buscarSX3("B5_SERVINT",,aColsSX3);  oStructTab:AddField(aColsSX3[1],STR0014,'SERVIC' ,'C',aColsSX3[3],aColsSX3[4],Nil,{||.T.},Nil,.F.,,.F.,.T.,.F.) // Serviço de Transferência
		buscarSX3("DCF_LOCDES",,aColsSX3);  oStructTab:AddField(aColsSX3[1],STR0015,'LOCDES' ,'C',aColsSX3[3],aColsSX3[4],{|A,B,C,D,E| WMS225VFld(A,B,C,D,E,.F.) },{||.T.},Nil,.F.,,.F.,.T.,.F.) // Armazém Destino
		buscarSX3("DCF_ENDDES",,aColsSX3);  oStructTab:AddField(aColsSX3[1],STR0016,'ENDDES' ,'C',aColsSX3[3],aColsSX3[4],{|A,B,C,D,E| WMS225VFld(A,B,C,D,E,.F.) },{||.T.},Nil,.F.,,.F.,.T.,.F.) // Endereço Destino
		buscarSX3("D14_LOCAL",,aColsSX3);   oStructTab:AddField(aColsSX3[1],STR0017,'LOCAL'  ,'C',aColsSX3[3],aColsSX3[4],Nil,{||.F.},Nil,.F.,,.F.,.T.,.F.) // Armazém Origem
		buscarSX3("D14_ENDER",,aColsSX3);   oStructTab:AddField(aColsSX3[1],STR0016,'ENDER'  ,'C',aColsSX3[3],aColsSX3[4],Nil,{||.F.},Nil,.F.,,.F.,.T.,.F.) // Endereço Origem
		buscarSX3("D14_LOTECTL",,aColsSX3); oStructTab:AddField(aColsSX3[1],STR0019,'LOTECTL','C',aColsSX3[3],aColsSX3[4],Nil,{||.F.},Nil,.F.,,.F.,.T.,.F.) // Lote
		buscarSX3("D14_NUMLOTE",,aColsSX3); oStructTab:AddField(aColsSX3[1],STR0020,'NUMLOTE','C',aColsSX3[3],aColsSX3[4],Nil,{||.F.},Nil,.F.,,.F.,.T.,.F.) // Sub-Lote
		buscarSX3("D14_DTVALD",,aColsSX3);  oStructTab:AddField(aColsSX3[1],STR0052,'DTVALD' ,'D',aColsSX3[3],aColsSX3[4],Nil,{||.F.},Nil,.F.,,.F.,.T.,.F.) // Data Validade
		buscarSX3("D14_PRDORI",,aColsSX3);  oStructTab:AddField(aColsSX3[1],STR0021,'PRDORI' ,'C',aColsSX3[3],aColsSX3[4],Nil,{||.F.},Nil,.F.,,.F.,.T.,.F.) // Produto Origem
		buscarSX3("D14_NUMSER",,aColsSX3);  oStructTab:AddField(aColsSX3[1],STR0022,'NUMSER' ,'C',aColsSX3[3],aColsSX3[4],Nil,{||.F.},Nil,.F.,,.F.,.T.,.F.) // Número de Serie
		If WmsX212118("D0Y")
			buscarSX3("D14_IDUNIT",,aColsSX3);  oStructTab:AddField(aColsSX3[1],STR0039,"IDUNIT" ,"C",aColsSX3[3],aColsSX3[4],Nil,{||.F.},Nil,.F.,,.F.,.F.,.F.) // Unitizador
			buscarSX3("DCF_UNIDES",,aColsSX3);  oStructTab:AddField(aColsSX3[1],STR0040,"UNIDES" ,"C",aColsSX3[3],aColsSX3[4],Nil,{|A,B,C,D,E| WhenField(A,B,C,D,E) },Nil,.F.,,.F.,.F.,.F.) // Unitizador Destino
			buscarSX3("D14_CODUNI",,aColsSX3);  oStructTab:AddField(aColsSX3[1],STR0042,"CODUNI" ,"C",aColsSX3[3],aColsSX3[4],Nil,{|A,B,C,D,E| WhenField(A,B,C,D,E) },Nil,.F.,,.F.,.F.,.F.) // Tipo Unitizador
		EndIf

		oModel:AddGrid('SELECAO','DCFMASTER',oStructTab)
		oModel:GetModel('SELECAO'):SetOnlyQuery(.T.)
		oModel:GetModel('SELECAO'):SetOptional(.T.)
		oModel:GetModel('SELECAO'):SetNoInsertLine(.T.)
		oModel:GetModel('SELECAO'):SetNoDeleteLine(.T.)
	EndIf
	oModel:SetActivate({|oModel| ActiveModel(oModel) } )
Return oModel
//-------------------------------------
/*/{Protheus.doc} ViewDef
ViewDef
@author felipe.m
@since 11/12/2014
@version 1.0
/*/
//-------------------------------------
Static Function ViewDef()
Local nI         := 1
Local oModel     :=  ModelDef()
Local oStrDCF    := FWFormStruct(2,'DCF')
Local oStructTab := FWFormViewStruct():New()
Local oView
Local aColsSX3   := {}

	oView := FWFormView():New()
	oView:SetModel(oModel)

	If nOperation == MODEL_OPERATION_INSERT
		buscarSX3("B1_COD",,aColsSX3);      oStructTab:AddField('CODPRO' ,'01',aColsSX3[1],STR0012,Nil,'GET',aColsSX3[2],Nil,Nil  ,.F.,Nil,Nil,Nil,Nil,Nil,.F.) // cIdField,cOrdem,cTitulo,cDescric,aHelp,cType,cPicture,bPictVar,cLookUp,lCanChange,cFolder,cGroup,aComboValues,nMaxLenCombo,cIniBrow,lVirtual,cPictVar,lInsertLine,nWidth,lIsDeleted // Código do Produto
		buscarSX3("DCF_QUANT",,aColsSX3);   oStructTab:AddField('QUANT'  ,'02',aColsSX3[1],STR0013,Nil,'GET',aColsSX3[2],Nil,Nil  ,.T.,Nil,Nil,Nil,Nil,Nil,.F.) // Quantidade
		buscarSX3("B5_SERVINT",,aColsSX3);  oStructTab:AddField('SERVIC' ,'03',aColsSX3[1],STR0014,Nil,'GET',aColsSX3[2],Nil,"DC5",.T.,Nil,Nil,Nil,Nil,Nil,.F.) // Serviço de Transferência
		buscarSX3("D14_LOCAL",,aColsSX3);   oStructTab:AddField('LOCAL'  ,'04',aColsSX3[1],STR0017,Nil,'GET',aColsSX3[2],Nil,Nil  ,.F.,Nil,Nil,Nil,Nil,Nil,.F.) // Armazém Origem
		buscarSX3("D14_ENDER",,aColsSX3);   oStructTab:AddField('ENDER'  ,'05',aColsSX3[1],STR0018,Nil,'GET',aColsSX3[2],Nil,Nil  ,.F.,Nil,Nil,Nil,Nil,Nil,.F.) // Endereço Origem
		If WmsX212118("D0Y")
			buscarSX3("D14_IDUNIT",,aColsSX3);  oStructTab:AddField('IDUNIT' ,'06',aColsSX3[1],STR0039,Nil,"GET",aColsSX3[2],Nil,Nil  ,.F.,Nil,Nil,Nil,Nil,Nil,.F.) // Unitizador
		EndIf
		buscarSX3("DCF_LOCDES",,aColsSX3);  oStructTab:AddField('LOCDES' ,'07',aColsSX3[1],STR0015,Nil,'GET',aColsSX3[2],Nil,"NNR",.T.,Nil,Nil,Nil,Nil,Nil,.F.) // Armazém Destino
		buscarSX3("DCF_ENDDES",,aColsSX3);  oStructTab:AddField('ENDDES' ,'08',aColsSX3[1],STR0016,Nil,'GET',aColsSX3[2],Nil,"SBE",.T.,Nil,Nil,Nil,Nil,Nil,.F.) // Endereço Destino
		If WmsX212118("D0Y")
			buscarSX3("DCF_UNIDES",,aColsSX3);  oStructTab:AddField('UNIDES' ,'09',aColsSX3[1],STR0040,Nil,"GET",aColsSX3[2],Nil,Nil  ,.T.,Nil,Nil,Nil,Nil,Nil,.F.) // Unitizador Destino
			buscarSX3("D14_CODUNI",,aColsSX3);  oStructTab:AddField('CODUNI' ,'10',aColsSX3[1],STR0042,Nil,"GET",aColsSX3[2],Nil,"D0T",.T.,Nil,Nil,Nil,Nil,Nil,.F.) // Tipo Unitizador
		EndIf
		buscarSX3("D14_LOTECTL",,aColsSX3); oStructTab:AddField('LOTECTL','11',aColsSX3[1],STR0019,Nil,'GET',aColsSX3[2],Nil,Nil  ,.F.,Nil,Nil,Nil,Nil,Nil,.F.) // Lote
		buscarSX3("D14_NUMLOTE",,aColsSX3); oStructTab:AddField('NUMLOTE','12',aColsSX3[1],STR0020,Nil,'GET',aColsSX3[2],Nil,Nil  ,.F.,Nil,Nil,Nil,Nil,Nil,.F.) // Sub-Lote
		buscarSX3("D14_DTVALD",,aColsSX3);  oStructTab:AddField('DTVALD' ,'13',aColsSX3[1],STR0052,Nil,'GET',aColsSX3[2],Nil,Nil  ,.F.,Nil,Nil,Nil,Nil,Nil,.F.) // Data Validade
		buscarSX3("D14_PRDORI",,aColsSX3);  oStructTab:AddField('PRDORI' ,'14',aColsSX3[1],STR0021,Nil,'GET',aColsSX3[2],Nil,Nil  ,.F.,Nil,Nil,Nil,Nil,Nil,.F.) // Produto Origem
		buscarSX3("D14_NUMSER",,aColsSX3);  oStructTab:AddField('NUMSER' ,'15',aColsSX3[1],STR0022,Nil,'GET',aColsSX3[2],Nil,Nil  ,.F.,Nil,Nil,Nil,Nil,Nil,.F.) // Número de Serie

		For nI := 1 To Len(oStrDCF:aFields)
			If nI > Len(oStrDCF:aFields)
				Exit
			EndIf
			// Campos que podem aparecer em tela
			If oStrDCF:aFields[nI][1] $ "DCF_DOCTO/DCF_ORIGEM/DCF_DATA"
				Loop
			EndIf

			oStrDCF:RemoveField(oStrDCF:aFields[nI][1])
			nI--
		Next nI
	EndIf

	oStrDCF:SetProperty('*' ,MVC_VIEW_ORDEM,'99')
	oStrDCF:SetProperty('DCF_DOCTO' ,MVC_VIEW_ORDEM,'01')
	oStrDCF:SetProperty('DCF_ORIGEM',MVC_VIEW_ORDEM,'02')
	oStrDCF:SetProperty('DCF_DATA'  ,MVC_VIEW_ORDEM,'03')

	If nOperation == MODEL_OPERATION_INSERT
		oStrDCF:SetProperty('DCF_DOCTO' ,MVC_VIEW_CANCHANGE,.F.)
		oStrDCF:SetProperty('DCF_ORIGEM',MVC_VIEW_CANCHANGE,.F.)
		oStrDCF:SetProperty('DCF_DATA'  ,MVC_VIEW_CANCHANGE,.F.)
	ElseIf nOperation == MODEL_OPERATION_UPDATE
		oStrDCF:SetProperty('*' ,MVC_VIEW_CANCHANGE,.F.)
	EndIf

	oView:AddField('DCFFORM',oStrDCF,'DCFMASTER')

	If nOperation == MODEL_OPERATION_INSERT
		oView:AddOtherObject('DCFPRODS',{|oPainel| MarkProds(oPainel,oModel,oView) })
		oView:AddGrid('SELECAO',oStructTab,'SELECAO')
		oView:EnableTitleView('SELECAO', STR0024) // Produtos Selecionados

		oView:CreateHorizontalBox('DCF_DADOS',10)
		oView:CreateHorizontalBox('ITENS_DADOS',45)
		oView:CreateHorizontalBox('TRANSF_DADOS',45)

		oView:SetOwnerView('DCFFORM','DCF_DADOS')
		oView:SetOwnerView('DCFPRODS','ITENS_DADOS')
		oView:SetOwnerView('SELECAO','TRANSF_DADOS')
	Else
		oView:CreateHorizontalBox('DCFFIELDS',100)
		oView:SetOwnerView('DCFFORM','DCFFIELDS')
	EndIf
Return oView

Static lTransfPrd := .T.
//-------------------------------------------------------
Function WMSA225MEN(nPos)
//-------------------------------------------------------
Local lRet      := .T.
Local aRotina   := MenuDef()
Local cAliasDC5 := Nil
Local cModel    := "WMSA225"
Local cAliasDCF := Nil

	nOperation := aRotina[nPos][4]
	// Criação das tabelas temporárias para validação do unitizador
	WMSCTPENDU()

	If nOperation == MODEL_OPERATION_INSERT
		lRet := Pergunte("WMSA225",.T.)
		If WmsX212118("D0Y")
			If WmsX112118("WMSA225","09")
				If MV_PAR09 == 1 // Produto
					cModel := "WMSA225"
					lTransfPrd := .T.
				ElseIf MV_PAR09 == 2 // Unitizador
					cModel := "WMSA225A"
					lTransfPrd := .F.
				EndIf
			EndIf
		EndIf
	EndIf

	If lRet .And. (nOperation == MODEL_OPERATION_UPDATE )
		If DCF->DCF_STSERV != '1'
			//"O status atual (" ") da ordem de serviço de transferência não permite a exclusão. 
			//Somente é possível excluir transferências com status 1-" "Verificar possibilidade de desfazer a transferência via WMSA150."
			WmsMessage(STR0058 + DCF->DCF_STSERV+"-"+X3COMBO("DCF_STSERV",DCF->DCF_STSERV)+ STR0059 + X3COMBO("DCF_STSERV","1") + ". " + STR0060,WMSA22506)
			lRet := .F.
		ElseIf !Empty(DCF->DCF_IDORI)
			cAliasDC5 := GetNextAlias()
			BeginSql Alias cAliasDC5
				SELECT DC5.DC5_SERVIC
				FROM %Table:DC5% DC5
				WHERE DC5.DC5_FILIAL = %xFilial:DC5%
				AND DC5.DC5_SERVIC = %Exp:DCF->DCF_SERVIC%
				AND DC5.DC5_OPERAC <> '5'
				AND DC5.%NotDel%
			EndSql
			If (cAliasDC5)->(!Eof())
				cAliasDCF := GetNextAlias()
				cAliasDCF := WMSDcfOri(@cAliasDCF, DCF->DCF_IDORI) 
				//"Transferência originada a partir do estorno de uma ordem de serviço não pode ser excluída. 
				//Dados da ordem de serviço origem: Serviço " "Documento" "Serie" "Data" "Produto" "Cliente" " Loja "
				WmsMessage(STR0061 + (cAliasDCF)->DCF_SERVIC+", "+ STR0062 +AllTrim((cAliasDCF)->DCF_DOCTO)+", "+STR0022+AllTrim((cAliasDCF)->DCF_SERIE)+", "+;
					STR0063+cValToChar(STOD((cAliasDCF)->DCF_DATA))+", "+STR0023 + AllTrim((cAliasDCF)->DCF_CODPRO)+", "+STR0064+AllTrim((cAliasDCF)->DCF_CLIFOR)+", "+STR0065+AllTrim((cAliasDCF)->DCF_LOJA)+".",WMSA22515)
				lRet := .F.
				(cAliasDCF)->(dbCloseArea())
			EndIf
			(cAliasDC5)->(dbCloseArea())
		EndIf
	EndIf

	If lRet
		FWExecView(aRotina[nPos][1],cModel,aRotina[nPos][4],,{ || .T. },{ || .T. },0,,{ || .T. },,, )
	EndIf

	// Deleção das tabelas temporárias para validação do unitizador
	WMSDTPENDU()
Return Nil
//-------------------------------------------------------
Static Function RetFiltro()
//-------------------------------------------------------
Local cFiltro := ""
Local cArqProd := SuperGetMv('MV_ARQPROD',.F.,"SB1") 


	cFiltro := " D14_FILIAL  =  '" + xFilial("D14") + "' AND "
    cFiltro += "D14_LOCAL  >= '"+MV_PAR01+"' AND D14_LOCAL  <= '"+MV_PAR02+"' AND "
	cFiltro += "D14_PRODUT >= '"+MV_PAR03+"' AND D14_PRODUT <= '"+MV_PAR04+"' AND "
	cFiltro += "D14_ENDER  >= '"+MV_PAR05+"' AND D14_ENDER  <= '"+MV_PAR06+"' AND "
	If lPermTrfBlq
		cFiltro += "(D14_QTDEST - (D14_QTDSPR+D14_QTDEMP)) > 0"
	Else
		cFiltro += "(D14_QTDEST - (D14_QTDSPR+D14_QTDEMP+D14_QTDBLQ)) > 0"
	EndIf

	If cArqProd == 'SB1'
		cFiltro += " AND EXISTS (SELECT B1_COD FROM " + RetSqlName("SB1") + " SB1 "
		cFiltro += " INNER JOIN " + RetSqlName("SB5") + " SB5 " 
		cFiltro += " ON SB5.B5_FILIAL = '" + xFilial("SB5") + "'"
		cFiltro += " AND SB5.B5_COD = SB1.B1_COD"
		cFiltro += " AND SB5.B5_CTRWMS = '1'"
		cFiltro += " AND SB5.D_E_L_E_T_ = ' '"
		cFiltro += " WHERE SB1.B1_FILIAL = '" + xFilial("SB1") + "'"
		cFiltro += " AND SB1.B1_COD = D14_PRODUT"
		cFiltro += " AND SB1.B1_LOCALIZ = 'S'"
		cFiltro += " AND SB1.D_E_L_E_T_ = ' ')"
	Else
		cFiltro += " AND EXISTS (SELECT B1_COD FROM " + RetSqlName("SB1") + " SB1 "
		cFiltro += " INNER JOIN " + RetSqlName("SB5") + " SB5 " 
		cFiltro += " ON SB5.B5_FILIAL = '" + xFilial("SB5") + "'"
		cFiltro += " AND SB5.B5_COD = SB1.B1_COD"
		cFiltro += " AND SB5.D_E_L_E_T_ = ' '"
		cFiltro += " LEFT JOIN " + RetSqlName("SBZ") + " SBZ "
		cFiltro += " ON SBZ.BZ_FILIAL = '" + xFilial("SBZ") + "'"
		cFiltro += " AND SBZ.BZ_COD = SB1.B1_COD"
		cFiltro += " AND SBZ.D_E_L_E_T_ = ' '
		cFiltro += " WHERE SB1.B1_FILIAL = '" + xFilial("SB1") + "'"
		cFiltro += " AND SB1.B1_COD = D14_PRODUT"
		cFiltro += " AND SB1.D_E_L_E_T_ = ' '
		cFiltro += " AND CASE WHEN SBZ.BZ_CTRWMS IS NULL THEN SB5.B5_CTRWMS ELSE SBZ.BZ_CTRWMS END = '1'"
		cFiltro += " AND CASE WHEN SBZ.BZ_LOCALIZ IS NULL THEN SB1.B1_LOCALIZ ELSE SBZ.BZ_LOCALIZ END = 'S')"
	EndIf
	
Return cFiltro

Static oMntUniItem := Nil
Static oTipUnit    := Nil
Static oTransf     := Nil
//-------------------------------------------------------
Function WMS225VMdl(oModel)
//-------------------------------------------------------
Local aAreaAnt   := GetArea()
local lRet       := .T.
Local lRetPE     := .T.
Local aRetPE     := {}
Local nI         := 0
Local oModelDCF  := oModel:GetModel("DCFMASTER")
Local oModelSel  := oModel:GetModel("SELECAO")
Local aUniDes    := {}
Local cIdUnit    := ""
Local cEndDes    := ""
Local cCabAviso  := ""
Local cAliasQry  := Nil
Local nPos       := 0
Local nLinha     := 0
Local lUnitOri   := .F.
Local lUnitDes   := .F.
	WmsMsgExibe(.F.) // Exibe a mensagem do WmsMessage

	If	ExistBlock("WMS225VL")
		lRetPE := ExecBlock("WMS225VL",.F.,.F.,{oModel})
		lRet := If(ValType(lRetPE)=="L",lRetPE,.T.)
	EndIf

	If lRet .And. oModel:GetOperation() == MODEL_OPERATION_INSERT
		// Instancia os objetos para utilizá-los na validação
		oMntUniItem := WMSDTCMontagemUnitizadorItens():New()
		oTipUnit    := WMSDTCUnitizadorArmazenagem():New()
		oTransf     := WMSBCCTransferencia():New()
		// O modelo principal precisa sofrer alguma alteração.
		oModelDCF:LoadValue("DCF_SERVIC",oModelSel:GetValue("SERVIC",1))

		For nI := 1 To oModelSel:Length()
			oModelSel:GoLine(nI)
			If oModelSel:IsDeleted(nI)
				Loop
			EndIf

			lUnitOri  := WmsArmUnit(oModelSel:GetValue("LOCAL",nI))
			lUnitDes  := WmsArmUnit(oModelSel:GetValue("LOCDES",nI))
			cCabAviso := WmsFmtMsg(STR0048,{{"[VAR01]",oModelDCF:GetValue("DCF_DOCTO")},{"[VAR02]",Iif(lTransfPrd,STR0023,STR0039)},{"[VAR03]",oModelSel:GetValue(Iif(lTransfPrd,"CODPRO","IDUNIT"),nI)}}) // "SIGAWMS - OS [VAR01] - [VAR02]: [VAR03]"
			lRet      := .T.
			// Inicializa os objetos
			oTransf:oMovEndOri:ClearData()
			oTransf:oMovEndDes:ClearData()
			oTransf:oMovPrdLot:ClearData()

			// Seta o serviço
			oTransf:oMovServic:SetServico(oModelSel:GetValue("SERVIC",nI))
			// Informações do endereço origem
			oTransf:oMovEndOri:SetArmazem(oModelSel:GetValue("LOCAL",nI))
			oTransf:oMovEndOri:SetEnder(oModelSel:GetValue("ENDER",nI))
			oTransf:oMovEndOri:LoadData()
			// Informações do unitizador origem
			If lUnitOri
				oTransf:SetIdUnit(oModelSel:GetValue("IDUNIT",nI))
			Else
				oTransf:SetIdUnit("")
			EndIf

			// Informações do endereço destino
			oTransf:oMovEndDes:SetArmazem(oModelSel:GetValue("LOCDES",nI))
			oTransf:oMovEndDes:SetEnder(oModelSel:GetValue("ENDDES",nI))
			oTransf:oMovEndDes:LoadData()
			// Informações do unitizador destino
			If lUnitDes
				oTransf:SetUniDes(oModelSel:GetValue("UNIDES",nI))
				oTransf:SetTipUni(oModelSel:GetValue("CODUNI",nI))
			Else
				oTransf:SetUniDes("")
				oTransf:SetTipUni("")
			EndIf

			If !lTransfPrd .And. !(oTransf:oMovEndOri:GetArmazem() == oTransf:oMovEndDes:GetArmazem()) .And. lUnitOri .And. !lUnitDes
				// Busca todos os produtos do unitizador
				cAliasQry := GetNextAlias()
				BeginSql Alias cAliasQry
					SELECT D14.D14_LOCAL,
							D14.D14_PRODUT,
							D14.D14_PRDORI,
							D14.D14_LOTECT,
							D14.D14_NUMLOT,
							D14.D14_DTVALD,
							D14.D14_NUMSER,
							D14.D14_QTDEST,
							D14.D14_QTDES2
					FROM %Table:D14% D14
					WHERE D14.D14_FILIAL = %xFilial:D14%
					AND D14.D14_IDUNIT = %Exp:oTransf:GetIdUnit()%
					AND D14.%NotDel%
				EndSql
				Do While lRet .And. (cAliasQry)->(!Eof())
					// Seta a informação do produto do unitizador
					oTransf:oMovPrdLot:SetArmazem((cAliasQry)->D14_LOCAL)
					oTransf:oMovPrdLot:SetProduto((cAliasQry)->D14_PRODUT)
					oTransf:oMovPrdLot:SetPrdOri((cAliasQry)->D14_PRDORI)
					oTransf:oMovPrdLot:SetLoteCtl((cAliasQry)->D14_LOTECT)
					oTransf:oMovPrdLot:SetNumLote((cAliasQry)->D14_NUMLOT)
					oTransf:oMovPrdLot:SetDtValid((cAliasQry)->D14_DTVALD)
					oTransf:oMovPrdLot:SetNumSer((cAliasQry)->D14_NUMSER)
					oTransf:oMovPrdLot:LoadData()
					oTransf:SetQuant((cAliasQry)->D14_QTDEST)
					// Validação do produto
					lRet := VldMdlData(oModelSel,@aUniDes,nI,cCabAviso,lUnitOri,lUnitDes,.T./*lProduto*/)

					(cAliasQry)->(dbSkip())
				EndDo
				(cAliasQry)->(dbCloseArea())
			Else
				If lTransfPrd
					// Seta a informação do produto que está no modelo
					oTransf:oMovPrdLot:SetArmazem(oModelSel:GetValue("LOCAL"))
					oTransf:oMovPrdLot:SetProduto(oModelSel:GetValue("CODPRO"))
					oTransf:oMovPrdLot:SetPrdOri(oModelSel:GetValue("PRDORI"))
					oTransf:oMovPrdLot:SetLoteCtl(oModelSel:GetValue("LOTECTL"))
					oTransf:oMovPrdLot:SetNumLote(oModelSel:GetValue("NUMLOTE"))
					oTransf:oMovPrdLot:SetDtValid(oModelSel:GetValue("DTVALD"))
					oTransf:oMovPrdLot:LoadData()
				EndIf
				oTransf:SetQuant(oModelSel:GetValue('QUANT'))
				// Validação do produto
				lRet := VldMdlData(oModelSel,@aUniDes,nI,cCabAviso,lUnitOri,lUnitDes,lTransfPrd)
			EndIf
		Next nI

		// Array com os unitizadores destinos para validação da grid para não deixar informar
		// o mesmo unitizador em várias linhas com endereços diferentes ou em branco
		If Len(aUniDes) > 1
			lRet := .T.
			While lRet .And. Len(aUniDes) > 0
				For nI := 1 To Len(aUniDes)
					cIdUnit := aUniDes[nI][1]
					cEndDes := aUniDes[nI][2]
					nLinha  := aUniDes[nI][3]
					// Apaga o unitizador do array
					aDel(aUniDes,nI)
					aSize(aUniDes,Len(aUniDes)-1)

					If Len(aUniDes) == 0
						Exit
					EndIf
					// Analisa se existe o mesmo unitizador no array
					If (nPos := aScan(aUniDes,{|x| x[1] == cIdUnit})) > 0
						// Caso exista o mesmo unitizador em endereços diferentes ou com endereços em branco
						If !(cEndDes == aUniDes[nPos][2]) .Or. (Empty(cEndDes) .And. Empty(aUniDes[nPos][2]))
							aAdd(oTransf:oOrdServ:aWmsAviso, cCabAviso + CRLF + WMSA22519 + " - " + WmsFmtMsg(STR0044,{{"[VAR01]",oModelSel:GetValue("UNIDES",nLinha)},{"[VAR02]",oModelSel:GetValue("CODPRO",nLinha)}}) + " - " + STR0045) // "Unitizador [VAR01] em endereços diferentes informado para o produto [VAR02]."##"Informe outro unitizador ou transfira o unitizador completo."
							lRet := .F.
							Exit
						EndIf
					EndIf
					Exit
				Next nI
			EndDo
		EndIf
		// Mensagem de aviso dos erros do formulário
		WmsMsgExibe(.T.) // Exibe a mensagem do WmsMessage
		If Len(oTransf:oOrdServ:aWmsAviso) > 0
			oModel:SetErrorMessage(oModelSel:GetId(),oModelSel:GetId(),,,"SIGAWMS",STR0051,"") // "Existem informações inválidos no formulário!"
			lRet := .F.
		EndIf
		oTransf:oOrdServ:ShowWarnig()

		If lRet .And. ExistBlock("WMS225VA")
			aRetPE := ExecBlock("WMS225VA",.F.,.F.,{oModel})
			If ValType(aRetPE)=="A" .And. Len(aRetPE) >=1 .And. ValType(aRetPE[1])=='L'
				lRet := aRetPE[1]
			Else
				lRet := .T.
			EndIf
			If !lRet
				oModel:SetErrorMessage(oModelSel:GetId(),oModelSel:GetId(),,,"SIGAWMS",aRetPE[2],"") // "Existem informações inválidos no formulário!"
			EndIf
		EndIf

		// Destroy objetos
		oTransf:Destroy()
		FreeObj(oTipUnit)
		oMntUniItem:Destroy()
	EndIf
	RestArea(aAreaAnt)
Return lRet
//-------------------------------------------------------
Static Function VldMdlData(oModelSel,aUniDes,nLinha,cCabAviso,lUnitOri,lUnitDes,lProduto)
//-------------------------------------------------------
Local lRet := .T.
Local cArmaCq :=  SuperGetMV("MV_CQ",.F.,"98")

	If oTransf:GetIdUnit() == oTransf:GetUniDes()
		If oTransf:oMovEndOri:GetArmazem()+oTransf:oMovEndOri:GetEnder() == oTransf:oMovEndDes:GetArmazem()+oTransf:oMovEndDes:GetEnder()
			aAdd(oTransf:oOrdServ:aWmsAviso, cCabAviso + CRLF + WMSA22518 + " - " + WmsFmtMsg(STR0043,{{"[VAR01]",Iif(lProduto,Lower(STR0023),Lower(STR0039))},{"[VAR02]",Iif(lProduto,oTransf:oMovPrdLot:GetProduto(),oTransf:GetIdUnit())}})) // "Endereço origem igual ao destino para o [VAR01] [VAR02]."
			Return .F.
		EndIf
	EndIf

	If lProduto
		If QtdComp(oTransf:GetQuant()) <= 0
			aAdd(oTransf:oOrdServ:aWmsAviso, cCabAviso + CRLF + WMSA22501 + " - " + WmsFmtMsg(STR0026,{{"[VAR01]",oTransf:oMovPrdLot:GetProduto()}})) // Informe quantidade maior que zero para o produto [VAR01].
			Return .F.
		EndIf

		If !(oTransf:oMovPrdLot:GetProduto() == oTransf:oMovPrdLot:GetPrdOri())
			If !(oTransf:oMovEndOri:GetArmazem() == oTransf:oMovEndDes:GetArmazem())
				aAdd(oTransf:oOrdServ:aWmsAviso, cCabAviso + CRLF + WMSA22514 + " - " + WmsFmtMsg(STR0037,{{"[VAR01]",oTransf:oMovPrdLot:GetProduto()}}) + " - " + STR0038) // "Não é permitido tranferir o produto [VAR01] entre armazéns diferentes, pois possui estrutura."
				Return .F.
			EndIf
		EndIf

		If oTransf:oMovEndOri:GetArmazem() == cArmaCq
			If oTransf:oMovEndOri:GetArmazem() <> oTransf:oMovEndDes:GetArmazem()
				aAdd(oTransf:oOrdServ:aWmsAviso, cCabAviso + " - " + WmsFmtMsg(STR0071,{{"[VAR01]",oTransf:oMovEndDes:GetArmazem()}}) + " - " ) // "Local destino informado não possui controle de qualidade (CQ) ativo"
				Return .F.
			EndIf	
		EndIf

		If lUnitDes
			// Valida se deve ou não informar o unitizador destino
			If Empty(oTransf:oMovEndDes:GetEnder())
				If Empty(oTransf:GetUniDes())
					lRet := .F.
				EndIf
			Else
				If Empty(oTransf:GetUniDes()) .And. !( cValtoChar(oTransf:oMovEndDes:GetTipoEst()) $ "2|7|8" )
					lRet := .F.
				EndIf
			EndIf

			If !lRet
				aAdd(oTransf:oOrdServ:aWmsAviso, cCabAviso + CRLF + WMSA22504 + " - " + WmsFmtMsg(STR0041,{{"[VAR01]",oTransf:oMovPrdLot:GetProduto()}})) // "Unitizador destino não informado para o produto [VAR01]."
				Return .F.
			EndIf

			If !Empty(oTransf:GetUniDes())
				// Valida se o unitizador possui caractere especial
				If !WmsVlStr(oTransf:GetUniDes())
					aAdd(oTransf:oOrdServ:aWmsAviso, cCabAviso + CRLF + WMSA22520 + " - " + WmsFmtMsg(STR0049,{{"[VAR01]",Iif(lProduto,Lower(STR0023),Lower(STR0039))},{"[VAR02]",Iif(lProduto,oTransf:oMovPrdLot:GetProduto(),oTransf:GetIdUnit())}})) // "Unitizador destino contém caracteres inválidos para o [VAR01] [VAR02]"
					Return .F.
				EndIf

				// Valida se existe etiqueta do unitizador
				oMntUniItem:oUnitiz:SetIdUnit(oTransf:GetUniDes())
				If !oMntUniItem:VldIdUnit(4)
					// Valida a existencia do código do unitizador
					aAdd(oTransf:oOrdServ:aWmsAviso, cCabAviso + CRLF + WMSA22522 + " - " + oMntUniItem:GetErro())
					Return .F.
				EndIf
				// Validações apenas se o unitizador origem estiver preenchido
				If lUnitOri
					// Valida se está movimentando um unitizador parcial e deixando em outro endereço com o mesmo unitizador,
					// pois não é permitido o mesmo unitizador em dois endereços ou armazéns diferentes.
					If !VldEndUni()
						aAdd(oTransf:oOrdServ:aWmsAviso, cCabAviso + CRLF + WMSA22517 + " - " + WmsFmtMsg(STR0044,{{"[VAR01]",oTransf:GetUniDes()},{"[VAR02]",oTransf:oMovPrdLot:GetProduto()}}) + " - " + STR0045) // "Unitizador [VAR01] em endereços diferentes informado para o produto [VAR02]."##"Informe outro unitizador ou transfira o unitizador completo."
						Return .F.
					EndIf
				Else
					//Quando não tem unitizador de origem, deve ser validado se o unitizador destino está no local e endereço informados.
					If !WMS225VUNI(oTransf)
						Return .F.
					EndIf
				EndIf

				If lRet
					If Empty(oTransf:GetTipUni())
						aAdd(oTransf:oOrdServ:aWmsAviso, cCabAviso + CRLF + WMSA22512 + " - " + WmsFmtMsg(STR0046,{{"[VAR01]",oTransf:oMovPrdLot:GetProduto()}})) // "Não foi informado o tipo do unitizador para o produto [VAR01]."
						Return .F.
					Else
						oTipUnit:SetTipUni(oTransf:GetTipUni())
						If oTipUnit:LoadData() //Verifica unitizadores mistos
							If !oTipUnit:CanUniMis() .And. oMntUniItem:oUnitiz:IsMultPrd(oTransf:oMovPrdLot:GetProduto(),,.T.)
								aAdd(oTransf:oOrdServ:aWmsAviso, cCabAviso + CRLF + WMSA22523 + " - " + WmsFmtMsg(STR0053,{{"[VAR01]",oTipUnit:GetTipUni()}})) // "Tipo de unitizador [VAR01] não permite montagem de unitizador misto."
								Return .F.
							EndIf
						Else
							aAdd(oTransf:oOrdServ:aWmsAviso, cCabAviso + CRLF + WMSA22516 + " - " + WmsFmtMsg(STR0047,{{"[VAR01]",oTransf:oMovPrdLot:GetProduto()}})) // "Tipo do unitizador não cadastrado para o produto [VAR01]."
							Return .F.
						EndIf
					EndIf
				EndIf
				// Adiciona os endereços destinos informados para validar se foi informado endereços diferetes para o mesmo unitizador destino
				aAdd(aUniDes,{oTransf:GetUniDes(),oTransf:oMovEndDes:GetEnder(),nLinha})
			Else
				// Limpa o Tipo do Unitizador para não gravar indevidamente quando o campo unitizador destino estiver vazio
				oModelSel:LoadValue("CODUNI","",nLinha)
			EndIf
		EndIf
	EndIf

	If Empty(oTransf:oMovServic:GetServico())
		aAdd(oTransf:oOrdServ:aWmsAviso, cCabAviso + CRLF + WMSA22502 + " - " + WmsFmtMsg(STR0027,{{"[VAR01]",Iif(lProduto,Lower(STR0023),Lower(STR0039))},{"[VAR02]",Iif(lProduto,oTransf:oMovPrdLot:GetProduto(),oTransf:GetIdUnit())}})) // "É obrigatório informar um serviço de transferência para o [VAR01] [VAR02]."
		Return .F.
	EndIf

	If oTransf:oMovServic:LoadData()
		If !oTransf:oMovServic:ChkTransf()
			aAdd(oTransf:oOrdServ:aWmsAviso, cCabAviso + CRLF + WMSA22503 + " - " + WmsFmtMsg(STR0028,{{"[VAR01]",Iif(lProduto,Lower(STR0023),Lower(STR0039))},{"[VAR02]",Iif(lProduto,oTransf:oMovPrdLot:GetProduto(),oTransf:GetIdUnit())}})) // "Serviço informado deve ser de transferência para o [VAR01] [VAR02]."
			Return .F.
		EndIf
	Else
		aAdd(oTransf:oOrdServ:aWmsAviso, cCabAviso + CRLF + WMSA22505 + " - " + WmsFmtMsg(STR0029,{{"[VAR01]",Iif(lProduto,Lower(STR0023),Lower(STR0039))},{"[VAR02]",Iif(lProduto,oTransf:oMovPrdLot:GetProduto(),oTransf:GetIdUnit())}})) // "Serviço informado para o [VAR01] [VAR02] não existe no cadastro DC5 (Serviço x Tarefa)."
		Return .F.
	EndIf

	If Empty(oTransf:oMovEndDes:GetArmazem())
		aAdd(oTransf:oOrdServ:aWmsAviso, cCabAviso + CRLF + WMSA22507 + " - " + WmsFmtMsg(STR0030,{{"[VAR01]",Iif(lProduto,Lower(STR0023),Lower(STR0039))},{"[VAR02]",Iif(lProduto,oTransf:oMovPrdLot:GetProduto(),oTransf:GetIdUnit())}})) // "É obrigatório informar o armazém destino para o [VAR01] [VAR02]."
		Return .F.
	Else
		If Empty( Posicione("NNR",1,xFilial("NNR")+oTransf:oMovEndDes:GetArmazem(),"NNR_CODIGO") )
			aAdd(oTransf:oOrdServ:aWmsAviso, cCabAviso + CRLF + WMSA22508 + " - " + WmsFmtMsg(STR0031,{{"[VAR01]",Iif(lProduto,Lower(STR0023),Lower(STR0039))},{"[VAR02]",Iif(lProduto,oTransf:oMovPrdLot:GetProduto(),oTransf:GetIdUnit())}})) // "Armazém destino informado para o [VAR01] [VAR02] não existe no cadastro NNR (Locais de Estoque)."
			Return .F.
		EndIf
	EndIf

	If oTransf:oMovEndOri:GetArmazem() != oTransf:oMovEndDes:GetArmazem()
		If Empty(oTransf:oMovEndDes:GetEnder())
			aAdd(oTransf:oOrdServ:aWmsAviso, cCabAviso + CRLF + WMSA22509 + " - " + WmsFmtMsg(STR0032,{{"[VAR01]",Iif(lProduto,Lower(STR0023),Lower(STR0039))},{"[VAR02]",Iif(lProduto,oTransf:oMovPrdLot:GetProduto(),oTransf:GetIdUnit())}})) // "É obrigatório informar o endereço destino para o [VAR01] [VAR02]."
			Return .F.
		Else
			If Empty( Posicione("SBE",1,xFilial("SBE")+oTransf:oMovEndDes:GetArmazem()+oTransf:oMovEndDes:GetEnder(),"BE_LOCALIZ") )
				aAdd(oTransf:oOrdServ:aWmsAviso, cCabAviso + CRLF + WMSA22510 + " - " + WmsFmtMsg(STR0033,{{"[VAR01]",Iif(lProduto,Lower(STR0023),Lower(STR0039))},{"[VAR02]",Iif(lProduto,oTransf:oMovPrdLot:GetProduto(),oTransf:GetIdUnit())}})) // "Endereço destino informado para o [VAR01] [VAR02] não existe no cadastro SBE (Endereços)."
				Return .F.
			EndIf
		EndIf
	EndIf

	// Verificação do endereço origem
	If !oTransf:ChkEndOri(,,,lPermTrfBlq)
		aAdd(oTransf:oOrdServ:aWmsAviso, cCabAviso + CRLF + WMSA22511 + " - " + oTransf:GetErro()) // Erro ChkEndOri
		Return .F.
	EndIf

	// Verificação do endereço destino
	If !Empty(oTransf:oMovEndDes:GetEnder())
		If !oTransf:ChkEndDes()
			aAdd(oTransf:oOrdServ:aWmsAviso, cCabAviso + CRLF + WMSA22513 + " - " + oTransf:GetErro()) // Erro ChkEndDes
			Return .F.
		EndIf
	EndIf
	If !WMSDtVdDif(oTransf:oMovEndOri:GetArmazem(),oTransf:oMovEndDes:GetArmazem(),oTransf:oMovPrdLot:GetPrdOri(),oTransf:oMovPrdLot:GetLotectl(),oTransf:oMovPrdLot:GetNUmlote()) 
		aAdd(oTransf:oOrdServ:aWmsAviso, cCabAviso + CRLF + WMSA22524 + " - " + WmsFmtMsg(STR0055,{{"[VAR01]",oTransf:oMovPrdLot:GetProduto()},{"[VAR02]",oTransf:oMovPrdLot:GetLotectl()},{"[VAR03]",oTransf:oMovPrdLot:GetNUmlote()},{"[VAR04]",oTransf:oMovEndDes:GetArmazem()}}) + " - " + STR0056) //Produto [VAR01] com Lote/Sublote [VAR02]/[VAR03] possui data validade diferente no armazém destino [VAR04]. "Ajuste  a data antes de continuar a transferência"
		Return .F.
	EndIf 

	If !WMSDtFbDif(oTransf:oMovEndOri:GetArmazem(),oTransf:oMovEndDes:GetArmazem(),oTransf:oMovPrdLot:GetPrdOri(),oTransf:oMovPrdLot:GetLotectl(),oTransf:oMovPrdLot:GetNUmlote()) 
		aAdd(oTransf:oOrdServ:aWmsAviso, cCabAviso + CRLF + WMSA22525 + " - " + WmsFmtMsg(STR0057,{{"[VAR01]",oTransf:oMovPrdLot:GetProduto()},{"[VAR02]",oTransf:oMovPrdLot:GetLotectl()},{"[VAR03]",oTransf:oMovPrdLot:GetNUmlote()},{"[VAR04]",oTransf:oMovEndDes:GetArmazem()}}) + " - " + STR0056) //Produto [VAR01] com Lote/Sublote [VAR02]/[VAR03] possui data fabricação diferente no armazém destino [VAR04]. "Ajuste  a data antes de continuar a transferência"
		Return .F.
	EndIf 

	If !WMSDtFuro(@oTransf) 
		Return .F.
	EndIf 

Return lRet

Static oOrdServ   := Nil
Static oEtiqUnit  := Nil
Static oMovimento := Nil
Static oModelDCF  := Nil
Static oModelSel  := Nil

Function WMS225Cmmt(oModel)
Local lRet      := .T.
Local nI        := 0
Local cAliasQry := Nil

	If oModel:GetOperation() == MODEL_OPERATION_INSERT
		oMovimento := WMSBCCTransferencia():New()
		oOrdServ   := WMSDTCOrdemServicoCreate():New()
		oEtiqUnit  := WMSDTCEtiquetaUnitizador():New()
		oModelDCF  := oModel:GetModel("DCFMASTER")
		oModelSel  := oModel:GetModel("SELECAO")
		WmsOrdSer(oOrdServ)

		Begin Transaction
			For nI := 1 To oModelSel:Length()
				If oModelSel:IsDeleted(nI)
					Loop
				EndIf
				oModelSel:GoLine(nI)
				// Criação do serviço com origem DCF quando o armazém destino é o mesmo
				If lTransfPrd
					// Atribui produto/Lote/Sublote
					oOrdServ:oProdLote:SetArmazem(oModelSel:GetValue("LOCAL"))
					oOrdServ:oProdLote:SetProduto(oModelSel:GetValue("CODPRO"))
					oOrdServ:oProdLote:SetPrdOri(oModelSel:GetValue("PRDORI"))
					oOrdServ:oProdLote:SetLoteCtl(oModelSel:GetValue("LOTECTL"))
					oOrdServ:oProdLote:SetNumLote(oModelSel:GetValue("NUMLOTE"))
					oOrdServ:oProdLote:SetDtValid(oModelSel:GetValue("DTVALD"))
					oOrdServ:oProdLote:LoadData()
					oOrdServ:oProdLote:SetNumSer("")
				EndIf
				// Atribui endereco origem
				oOrdServ:oOrdEndOri:SetArmazem(oModelSel:GetValue("LOCAL"))
				oOrdServ:oOrdEndOri:SetEnder(oModelSel:GetValue("ENDER"))
				// Atribui endereco destino
				oOrdServ:oOrdEndDes:SetArmazem(oModelSel:GetValue("LOCDES"))
				oOrdServ:oOrdEndDes:SetEnder(oModelSel:GetValue("ENDDES"))
				// Atribui quantidade
				oOrdServ:SetQuant(oModelSel:GetValue("QUANT"))
				oOrdServ:SetOrigem(oModelDCF:GetValue("DCF_ORIGEM"))
				oOrdServ:SetDocto(oModelDCF:GetValue("DCF_DOCTO"))
				// Atribui servico
				oOrdServ:oServico:SetServico(oModelSel:GetValue("SERVIC"))
				oOrdServ:oServico:LoadData()
				//Informa que a classe não deve gerar um novo Id DCF
				oOrdServ:GeraNovoId(.F.)
				// Criação do serviço com origem DH1 quando o armazém é diferente
				If !(oModelSel:GetValue("LOCAL") == oModelSel:GetValue("LOCDES"))
					// Muda a origem do serviço para DH1
					oOrdServ:SetOrigem("DH1")  //Sempre que o armazém origem e destino for diferente a origem e DH1.
					If lTransfPrd
						// Atribui id dcf
						oOrdServ:SetIdDCF(WMSProxSeq('MV_DOCSEQ','DCF_ID'))
						// Gera a DH1 com base nas informações do objeto e incrementa B2_RESERVA
						lRet := WmsGeraDH1("WMSA225")
					Else
						// Criação do serviço com origem DH1 quando o armazém é diferente para cada produto do unitizador
						cAliasQry := GetNextAlias()
						BeginSql Alias cAliasQry
							SELECT D14.D14_LOCAL,
									D14.D14_PRODUT,
									D14.D14_PRDORI,
									D14.D14_LOTECT,
									D14.D14_NUMLOT,
									D14.D14_DTVALD,
									D14.D14_NUMSER,
									D14.D14_QTDEST,
									D14.D14_QTDES2
							FROM %Table:D14% D14
							WHERE D14.D14_FILIAL = %xFilial:D14%
							AND D14.D14_IDUNIT = %Exp:oModelSel:GetValue("IDUNIT")%
							AND D14.%NotDel%
							ORDER BY D14.D14_FILIAL, 
							D14.D14_LOCAL, 
							D14.D14_PRODUT
						EndSql
						Do While lRet .And. (cAliasQry)->(!Eof())
							// Atribui id dcf
							oOrdServ:SetIdDCF(WMSProxSeq('MV_DOCSEQ','DCF_ID'))
							// Seta as informações do produto do unitizador
							oOrdServ:oProdLote:SetArmazem((cAliasQry)->D14_LOCAL)
							oOrdServ:oProdLote:SetProduto((cAliasQry)->D14_PRODUT)
							oOrdServ:oProdLote:SetPrdOri((cAliasQry)->D14_PRDORI)
							oOrdServ:oProdLote:SetLoteCtl((cAliasQry)->D14_LOTECT)
							oOrdServ:oProdLote:SetNumLote((cAliasQry)->D14_NUMLOT)
							oOrdServ:oProdLote:SetDtValid((cAliasQry)->D14_DTVALD)
							oOrdServ:oProdLote:SetNumSer((cAliasQry)->D14_NUMSER)
							oOrdServ:oProdLote:LoadData()
							oOrdServ:SetQuant((cAliasQry)->D14_QTDEST)
							// Gera a DH1 com base nas informações do objeto e incrementa B2_RESERVA
							If (lRet := WmsGeraDH1("WMSA225"))
								WMSRemBloq((cAliasQry)->D14_PRDORI,;
											(cAliasQry)->D14_PRODUT,;
											(cAliasQry)->D14_LOTECT,;
											(cAliasQry)->D14_NUMLOT,;
											(cAliasQry)->D14_LOCAL,;
											oModelSel:GetValue("ENDER"),;
											oModelSel:GetValue("IDUNIT"),;
											(cAliasQry)->D14_QTDEST,;
											oOrdServ:GetIdDCF(),;
											oOrdServ:GetDocto(),;
											oModel)
								// Atribui os valores e cria a ordem de serviço por produto
								lRet := GeraOrdSer(oModel,.T./*lProduto*/)
							EndIf
							(cAliasQry)->(dbSkip())
						EndDo
						(cAliasQry)->(dbCloseArea())
					EndIf
				Else
					// Atribui id dcf
					oOrdServ:SetIdDCF(WMSProxSeq('MV_DOCSEQ','DCF_ID'))
				EndIf
				//Remove bloqueio de saldos
				If lRet .And. (oModelSel:GetValue("LOCAL") == oModelSel:GetValue("LOCDES") .Or. lTransfPrd) 
					If lTransfPrd
						lRet := WMSRemBloq(oModelSel:GetValue("PRDORI"),;
										oModelSel:GetValue("CODPRO"),;
										oModelSel:GetValue("LOTECTL"),;
										oModelSel:GetValue("NUMLOTE"),;
										oModelSel:GetValue("LOCAL"),;
										oModelSel:GetValue("ENDER"),;
										oModelSel:GetValue("IDUNIT"),;
										oModelSel:GetValue("QUANT"),;
										oOrdServ:GetIdDCF(),;
										oOrdServ:GetDocto(),;
										oModel)
					Else
						lRet := WMSRemBlUn(oModelSel:GetValue("IDUNIT"),oOrdServ:GetIdDCF(),oOrdServ:GetDocto(),oModelSel:GetValue("LOCAL"),oModel)
					EndIf
				EndIf
				If lRet .And. (oModelSel:GetValue("LOCAL") == oModelSel:GetValue("LOCDES") .Or. lTransfPrd) 
					// Atribui os valores e cria a ordem de serviço
					lRet := GeraOrdSer(oModel,lTransfPrd)
				EndIf		
				If !lRet
					Exit
				EndIf
			Next nI
			If !lRet
				Disarmtransaction()
			EndIf
		End Transaction

		If lRet
			WmsExeServ()
		EndIf
		// Destroy objetos
		oMovimento:Destroy()
		oOrdServ:Destroy()
		FreeObj(oEtiqUnit)

	ElseIf oModel:GetOperation() == MODEL_OPERATION_UPDATE
		Begin Transaction
			oOrdServ := WMSDTCOrdemServicoDelete():New()

			WmsDCFdDH1(DCF->DCF_ID)//Deleta DH1

			If oOrdServ:GoToDCF(DCF->(Recno()))
				If oOrdServ:CanDelete()
					oOrdServ:DeleteDCF()
				Else
					lRet := .F.
				EndIf
			Else
				lRet := .F.
			EndIf
			//Se foi transferida quantidade bloqueada, refaz o bloqueio
			If lRet
				lRet := RefBloq(DCF->DCF_ID,DCF->DCF_DOCTO,oModel)
			EndIf
			If !lRet
				oModel:GetModel():SetErrorMessage( , , oModel:GetId() , "", "", oOrdServ:GetErro(), "", "", "")
			EndIf
			FreeObj(oOrdServ)
			If !lRet
				Disarmtransaction()
			EndIf
		End Transaction
	EndIf
Return lRet
//-------------------------------------------------------
Static Function GeraOrdSer(oModel,lProduto)
//-------------------------------------------------------
Local lRet := .T.
	// Atribui informações do unitizador
	oOrdServ:SetIdUnit(oModelSel:GetValue("IDUNIT"))
	If WmsArmUnit(oOrdServ:oOrdEndDes:GetArmazem())
		oOrdServ:oOrdEndDes:LoadData()
		If !( cValtoChar(oOrdServ:oOrdEndDes:GetTipoEst()) $ "2|7|8" )
			oOrdServ:SetUniDes(oModelSel:GetValue("UNIDES"))
			oOrdServ:SetTipUni(oModelSel:GetValue("CODUNI"))
			
			// Atualiza dados da etiqueta do unitizador
			oEtiqUnit:SetIdUnit(oModelSel:GetValue("UNIDES"))
			If oEtiqUnit:LoadData()
				If !oEtiqUnit:GetIsUsed()
					oEtiqUnit:SetUsado("1")
					oEtiqUnit:SetTipUni(oModelSel:GetValue("CODUNI"))
					oEtiqUnit:UpdateD0Y()
				EndIf
			EndIf
		EndIf
	Else
		oOrdServ:SetUniDes("")
		oOrdServ:SetTipUni("")
	EndIf
	// Endereco Origem
	oMovimento:SetIdUnit(oOrdServ:GetIdUnit())
	oMovimento:oMovEndOri:SetArmazem(oOrdServ:oOrdEndOri:GetArmazem())
	oMovimento:oMovEndOri:SetEnder(oOrdServ:oOrdEndOri:GetEnder())
	// Endereco Destino
	oMovimento:SetUniDes(oOrdServ:GetUniDes())
	oMovimento:SetTipUni(oOrdServ:GetTipUni())
	oMovimento:oMovEndDes:SetArmazem(oOrdServ:oOrdEndDes:GetArmazem())
	oMovimento:oMovEndDes:SetEnder(oOrdServ:oOrdEndDes:GetEnder())
	If lProduto
		// Produto/Lote
		oMovimento:oMovPrdLot:SetArmazem(oOrdServ:oProdLote:GetArmazem())
		oMovimento:oMovPrdLot:SetPrdOri(oOrdServ:oProdLote:GetPrdOri())
		oMovimento:oMovPrdLot:SetProduto(oOrdServ:oProdLote:GetProduto())
		oMovimento:oMovPrdLot:SetLoteCtl(oOrdServ:oProdLote:GetLoteCtl())
		oMovimento:oMovPrdLot:SetNumLote(oOrdServ:oProdLote:GetNumLote())
		oMovimento:oMovPrdLot:SetNumSer(oOrdServ:oProdLote:GetNumSer())
		oMovimento:oMovPrdLot:LoadData()
	EndIf
	oMovimento:oMovServic:SetServico(oOrdServ:oServico:GetServico())
	oMovimento:oOrdServ:SetDocto(oOrdServ:GetDocto())
	oMovimento:SetQuant(oOrdServ:GetQuant())
	If !oMovimento:ChkEndOri()
		oModel:GetModel():SetErrorMessage( , , oModel:GetId() , "", "", oMovimento:GetErro(), "", "", "")
		lRet := .F.
	EndIf
	If lRet .And. !Empty(oOrdServ:oOrdEndDes:GetEnder())
		If !oMovimento:ChkEndDes()
			oModel:GetModel():SetErrorMessage( , , oModel:GetId() , "", "", oMovimento:GetErro(), "", "", "")
			lRet := .F.
		EndIf
	EndIf
	If lRet
		If !oOrdServ:CreateDCF()
			oModel:GetModel():SetErrorMessage( , , oModel:GetId() , "", "", oOrdServ:GetErro(), "", "", "")
			lRet := .F.
		EndIf
	EndIf
Return lRet
//-------------------------------------------------------
Static Function MarkProds(oPainel,oModel,oView)
//-------------------------------------------------------
Local aAreaAnt := GetArea()
Local oMarkBrw
Local lMarcar  := .F.

	oMarkBrw := FWMarkBrowse():New()
	oMarkBrw:SetDescription(STR0036) // Saldo por endereço WMS
	oMarkBrw:SetOwner(oPainel)
	oMarkBrw:SetAlias("D14")
	oMarkBrw:oBrowse:SetDBFFilter(.T.)
	oMarkBrw:oBrowse:SetUseFilter(.T.)
	oMarkBrw:oBrowse:SetFixedBrowse(.T.)
	oMarkBrw:oBrowse:SetFilterDefault("@ "+RetFiltro())
	oMarkBrw:SetFieldMark('D14_OK')
	oMarkBrw:bAllMark := { || SetMarkAll(oMarkBrw:Mark(),lMarcar := !lMarcar,oMarkBrw,oModel ), oMarkBrw:Refresh(.T.),oView:Refresh()  }
	oMarkBrw:SetAfterMark({|| SetAfter(oMarkBrw,oModel), oView:Refresh() })
	oMarkBrw:SetMenuDef('')
	oMarkBrw:Activate()

	RestArea(aAreaAnt)
Return
//-------------------------------------------------------
Static Function SetMarkAll(cMarca,lMarcar,oMarkBrw,oModel)
//-------------------------------------------------------
Local aAreaTable := D14->(GetArea())
	D14->(dbSetOrder(1))
	D14->(dbGoTop() )
	While !D14->(Eof())
		RecLock( "D14", .F. )
		D14->D14_OK := IIf( lMarcar, cMarca, '  ' )
		SetAfter(oMarkBrw,oModel)
		MsUnLock()
		D14->(dbSkip())
	EndDo
	RestArea( aAreaTable )
Return .T.
//-------------------------------------------------------
Static Function SetAfter(oMarkBrw,oModel)
//-------------------------------------------------------
Local aAreaAnt := GetArea()
Local nI := 0
Local aSelecao := {}

	oModel:GetModel('SELECAO'):SetNoInsertLine(.F.)
	oModel:GetModel('SELECAO'):SetNoDeleteLine(.F.)
	If oMarkBrw:IsMark()
		If !oModel:GetModel('SELECAO'):SeekLine( { {"LOCAL",D14->D14_LOCAL},{"ENDER",D14->D14_ENDER},{"PRDORI",D14->D14_PRDORI},{"CODPRO",D14->D14_PRODUT},{"LOTECTL",D14->D14_LOTECT},{"NUMLOTE",D14->D14_NUMLOT},{"NUMSER",D14->D14_NUMSER},{"IDUNIT",D14->D14_IDUNIT} } )
			If !Empty(oModel:GetModel('SELECAO'):GetValue('CODPRO'))
				oModel:GetModel('SELECAO'):AddLine()
			EndIf

			oModel:GetModel('SELECAO'):LoadValue('SERVIC' ,Posicione("SB5",1,xFilial("SB5")+D14->D14_PRODUT,"B5_SERVINT") )
			If lPermTrfBlq
				oModel:GetModel('SELECAO'):LoadValue('QUANT'  ,Iif(D14->D14_QTDEST > 0,D14->D14_QTDEST - ( D14->D14_QTDSPR + D14->D14_QTDEMP ),0) )
			Else
				oModel:GetModel('SELECAO'):LoadValue('QUANT'  ,Iif(D14->D14_QTDEST > 0,D14->D14_QTDEST - ( D14->D14_QTDSPR + D14->D14_QTDEMP + D14->D14_QTDBLQ),0) )
			EndIf
			oModel:GetModel('SELECAO'):LoadValue('LOCAL'  ,D14->D14_LOCAL)
			oModel:GetModel('SELECAO'):LoadValue('ENDER'  ,D14->D14_ENDER)
			oModel:GetModel('SELECAO'):LoadValue('PRDORI' ,D14->D14_PRDORI)
			oModel:GetModel('SELECAO'):LoadValue('CODPRO' ,D14->D14_PRODUT)
			oModel:GetModel('SELECAO'):LoadValue('LOTECTL',D14->D14_LOTECT)
			oModel:GetModel('SELECAO'):LoadValue('NUMLOTE',D14->D14_NUMLOT)
			oModel:GetModel('SELECAO'):LoadValue('DTVALD' ,D14->D14_DTVALD)
			oModel:GetModel('SELECAO'):LoadValue('NUMSER' ,D14->D14_NUMSER)
			If WmsX212118("D0Y")
				oModel:GetModel('SELECAO'):LoadValue('IDUNIT' ,D14->D14_IDUNIT)
				oModel:GetModel('SELECAO'):LoadValue('CODUNI' ,Iif(WmsArmUnit(D14->D14_LOCAL),LoadPadrao(),""))
			EndIf
			oModel:GetModel('SELECAO'):SetValue('LOCDES'  ,D14->D14_LOCAL)
		EndIf
	Else
		If oModel:GetModel('SELECAO'):SeekLine( { {"LOCAL",D14->D14_LOCAL},{"ENDER",D14->D14_ENDER},{"PRDORI",D14->D14_PRDORI},{"CODPRO",D14->D14_PRODUT},{"LOTECTL",D14->D14_LOTECT},{"NUMLOTE",D14->D14_NUMLOT},{"NUMSER",D14->D14_NUMSER} } )
			oModel:GetModel('SELECAO'):DeleteLine()
		EndIf

		For nI := 1 To oModel:GetModel("SELECAO"):Length()
			oModel:GetModel('SELECAO'):GoLine(nI)
			If !oModel:GetModel('SELECAO'):IsDeleted()
				If WmsX212118("D0Y")
					aAdd(aSelecao,{ oModel:GetModel("SELECAO"):GetValue("CODPRO",nI),;
									oModel:GetModel("SELECAO"):GetValue("QUANT"  ,nI),;
									oModel:GetModel("SELECAO"):GetValue("SERVIC" ,nI),;
									oModel:GetModel("SELECAO"):GetValue("LOCDES" ,nI),;
									oModel:GetModel("SELECAO"):GetValue("ENDDES" ,nI),;
									oModel:GetModel("SELECAO"):GetValue("LOCAL"  ,nI),;
									oModel:GetModel("SELECAO"):GetValue("ENDER"  ,nI),;
									oModel:GetModel("SELECAO"):GetValue("LOTECTL",nI),;
									oModel:GetModel("SELECAO"):GetValue("NUMLOTE",nI),;
									oModel:GetModel("SELECAO"):GetValue("DTVALD" ,nI),;
									oModel:GetModel("SELECAO"):GetValue("PRDORI" ,nI),;
									oModel:GetModel("SELECAO"):GetValue("NUMSER" ,nI),;
									oModel:GetModel("SELECAO"):GetValue("IDUNIT" ,nI),;
									oModel:GetModel("SELECAO"):GetValue("UNIDES" ,nI),;
									oModel:GetModel("SELECAO"):GetValue("CODUNI" ,nI)})
				Else
					aAdd(aSelecao,{ oModel:GetModel("SELECAO"):GetValue("CODPRO",nI),;
									oModel:GetModel("SELECAO"):GetValue("QUANT"  ,nI),;
									oModel:GetModel("SELECAO"):GetValue("SERVIC" ,nI),;
									oModel:GetModel("SELECAO"):GetValue("LOCDES" ,nI),;
									oModel:GetModel("SELECAO"):GetValue("ENDDES" ,nI),;
									oModel:GetModel("SELECAO"):GetValue("LOCAL"  ,nI),;
									oModel:GetModel("SELECAO"):GetValue("ENDER"  ,nI),;
									oModel:GetModel("SELECAO"):GetValue("LOTECTL",nI),;
									oModel:GetModel("SELECAO"):GetValue("NUMLOTE",nI),;
									oModel:GetModel("SELECAO"):GetValue("DTVALD" ,nI),;
									oModel:GetModel("SELECAO"):GetValue("PRDORI" ,nI),;
									oModel:GetModel("SELECAO"):GetValue("NUMSER" ,nI)})
				EndIf
			EndIf
		Next nI

		oModel:GetModel("SELECAO"):ClearData()
		oModel:GetModel("SELECAO"):InitLine()
		oModel:GetModel("SELECAO"):GoLine(1)

		For nI := 1 To Len(aSelecao)
			If !Empty(oModel:GetModel('SELECAO'):GetValue('CODPRO'))
				oModel:GetModel('SELECAO'):AddLine()
				oModel:GetModel('SELECAO'):GoLine(nI)
			EndIf

			oModel:GetModel("SELECAO"):LoadValue("CODPRO" ,aSelecao[nI][1])
			oModel:GetModel("SELECAO"):LoadValue("QUANT"  ,aSelecao[nI][2])
			oModel:GetModel("SELECAO"):LoadValue("SERVIC" ,aSelecao[nI][3])
			oModel:GetModel("SELECAO"):SetValue("LOCDES"  ,aSelecao[nI][4])
			oModel:GetModel("SELECAO"):LoadValue("ENDDES" ,aSelecao[nI][5])
			oModel:GetModel("SELECAO"):LoadValue("LOCAL"  ,aSelecao[nI][6])
			oModel:GetModel("SELECAO"):LoadValue("ENDER"  ,aSelecao[nI][7])
			oModel:GetModel("SELECAO"):LoadValue("LOTECTL",aSelecao[nI][8])
			oModel:GetModel("SELECAO"):LoadValue("NUMLOTE",aSelecao[nI][9])
			oModel:GetModel("SELECAO"):LoadValue("DTVALD" ,aSelecao[nI][10])
			oModel:GetModel("SELECAO"):LoadValue("PRDORI" ,aSelecao[nI][11])
			oModel:GetModel("SELECAO"):LoadValue("NUMSER" ,aSelecao[nI][12])
			If WmsX212118("D0Y")
				oModel:GetModel("SELECAO"):LoadValue("IDUNIT" ,aSelecao[nI][13])
				oModel:GetModel("SELECAO"):LoadValue("UNIDES" ,aSelecao[nI][14])
				oModel:GetModel("SELECAO"):LoadValue("CODUNI" ,aSelecao[nI][15])
			EndIf
		Next nI
	EndIf

	oModel:GetModel('SELECAO'):SetNoInsertLine(.T.)
	oModel:GetModel('SELECAO'):SetNoDeleteLine(.T.)
	oModel:GetModel('SELECAO'):GoLine(1)

	RestArea(aAreaAnt)
Return
//-------------------------------------------------------
Function WMS225VFld(oModel,cField,xValor,nLinha,xValorAnt,lLimpaUnit)
//-------------------------------------------------------
Local lRet      := .T.
Local oView     := Nil
Local oEndereco := Nil
Local lArmUnit  := .F.
Default lLimpaUnit := .T.
	Do Case
		Case cField == "LOCDES"
			oView := FWViewActive()
			If Empty(xValor)
				xValor := oModel:GetValue("LOCAL",nLinha)
				// Se o armazém destino foi limpado, atribui o mesmo que o origem
				oModel:LoadValue("LOCDES",xValor,nLinha)
			EndIf	
			
			NNR->(dbSetOrder(1))
			If !Empty(xValor) .And. !(xValor == xValorAnt)
				NNR->(dbSeek(xFilial("NNR")+xValor))
			Else
				NNR->(dbSeek(xFilial("NNR")+xValorAnt))
			EndIf
			
			If WmsX212118("D0Y")
				lArmUnit := WmsArmUnit(NNR->NNR_CODIGO)
	
				If lArmUnit .And. Empty(oModel:GetValue("CODUNI",nLinha))
					oModel:LoadValue("CODUNI",LoadPadrao(),nLinha)
				EndIf
	
				If lLimpaUnit //Tela no modo unitizador
					If lArmUnit
						If Empty(oModel:GetValue("UNIDES",nLinha))
							oModel:LoadValue("UNIDES", oModel:GetValue("IDUNIT",nLinha) ,nLinha)
						EndIf
					Else
						oModel:LoadValue("UNIDES"," ",nLinha)
					EndIf
				EndIf
			EndIf
			oView:Refresh()
		Case cField == "ENDDES"
			If WmsArmUnit(oModel:GetValue("LOCDES",nLinha))
				If !Empty(oModel:GetValue("ENDDES",nLinha))
					oEndereco := WMSDTCEndereco():New()
					oEndereco:SetArmazem(oModel:GetValue("LOCDES",nLinha))
					oEndereco:SetEnder(oModel:GetValue("ENDDES",nLinha))
					// Desabilita o campo unitizador destino se o endereço informado for um picking
					If oEndereco:LoadData()
						If !(oEndereco:GetTipoEst() == 2 .Or. oEndereco:GetTipoEst() == 7) .And. Empty(oModel:GetValue("CODUNI",nLinha))
							oModel:LoadValue("CODUNI",LoadPadrao(),nLinha)
						EndIf
					EndIf
					oEndereco:Destroy()
				Else
					If Empty(oModel:GetValue("CODUNI",nLinha))
						oModel:LoadValue("CODUNI",LoadPadrao(),nLinha)
					EndIf
				EndIf
			EndIf
	EndCase
Return lRet
//-------------------------------------------------------
Static Function WhenField(oModel,cField,xValor,nLinha,xValorAnt)
//-------------------------------------------------------
Local lRet := .T.
Local oView := Nil
Local oEndereco := Nil
	Do Case
		Case cField == "UNIDES" .Or. cField == "CODUNI"
			// Desabilita os campos quando o armazém informado não controla unitizador
			If (lRet := WmsArmUnit(oModel:GetValue("LOCDES",nLinha)))
				If !Empty(oModel:GetValue("ENDDES",nLinha))
					oEndereco := WMSDTCEndereco():New()
					oEndereco:SetArmazem(oModel:GetValue("LOCDES",nLinha))
					oEndereco:SetEnder(oModel:GetValue("ENDDES",nLinha))
					// Desabilita o campo unitizador destino se o endereço informado for um picking
					If oEndereco:LoadData() .And. (oEndereco:GetTipoEst() == 2 .Or. oEndereco:GetTipoEst() == 7)
						lRet := .F.
					EndIf
					oEndereco:Destroy()
				EndIf
			EndIf
			If !lRet
				oView := FWViewActive()
				oModel:LoadValue("UNIDES","",nLinha)
				oModel:LoadValue("CODUNI","",nLinha)
				oView:Refresh()
			EndIf
	EndCase
Return lRet
//-------------------------------------------------------
Static Function ActiveModel(oModel)
//-------------------------------------------------------
	If nOperation == 4
		// O modelo precisa sofrer alteração
		oModel:LoadValue('DCFMASTER','DCF_DOCTO',oModel:GetValue('DCFMASTER','DCF_DOCTO'))
	EndIf
Return .T.
//-------------------------------------------------------
// Retorna a opção selecionada no menu do WMSA225
Function WMSA225OPT()
//-------------------------------------------------------
Return nOperation
//-------------------------------------------------------
Static Function LoadPadrao()
//-------------------------------------------------------
Local oTipUni := WMSDTCUnitizadorArmazenagem():New()
	oTipUni:FindPadrao()
Return oTipUni:GetTipUni()
//-------------------------------------------------------
Static Function VldEndUni()
//-------------------------------------------------------
Local aAreaAnt := GetArea()
Local lRet      := .T.
Local cAliasQry := Nil
Local cSelect   := ""
Local nQtdPrd   := 0
Local nQtdUni   := 0
	cSelect := "%"
	If lPermTrfBlq
		cSelect += 	", ((D14.D14_QTDEST+D14.D14_QTDEPR) - (D14.D14_QTDSPR + D14.D14_QTDEMP)) D14_QTDEST"
	Else
		cSelect += ", ((D14.D14_QTDEST+D14.D14_QTDEPR) - (D14.D14_QTDSPR + D14.D14_QTDEMP + D14.D14_QTDBLQ)) D14_QTDEST"
	EndIf
	cSelect += "%"
	cAliasQry := GetNextAlias()
	BeginSql Alias cAliasQry
		SELECT D14.D14_LOCAL,
				D14.D14_ENDER,
				D14.D14_PRODUT,
				D14.D14_LOTECT,
				D14.D14_NUMLOT
				%Exp:cSelect%
		FROM %Table:D14% D14
		WHERE D14.D14_FILIAL = %xFilial:D14%
		AND D14.D14_IDUNIT = %Exp:oTransf:GetUniDes()%
		AND D14.%NotDel%
	EndSql
	// Caso tentativa de transferência do unitizador destino para um endereço diferente do que já está no estoque, invalida a operação
	If (cAliasQry)->(!Eof()) .And. !((cAliasQry)->(D14_LOCAL+D14_ENDER) == oTransf:oMovEndDes:GetArmazem()+oTransf:oMovEndDes:GetEnder())
		lRet := .F.
	EndIf
	// Quando é um endereço diferente, analisa se está querendo transferir toda a quantidade do unitizador
	If !lRet .And. oTransf:GetUniDes() == oTransf:GetIdUnit()
		(cAliasQry)->(dbEval({|| nQtdPrd++, nQtdUni := (cAliasQry)->D14_QTDEST }))

		lRet := .T.
		// Caso o unitizador seja misto, já não deixa transferir parcialemente, do contrário analisa a quantidade do movimento
		If nQtdPrd > 1 .Or. QtdComp(nQtdUni) > QtdComp(oTransf:GetQuant())
			lRet := .F.
		EndIf
	EndIf
	(cAliasQry)->(dbCloseArea())
	If lRet
		// Procura na DCF se existe alguma transferência pendente de execução
		// para o mesmo unitizador com outro endereço ou endereço em branco
		cAliasQry := GetNextAlias()
		BeginSql Alias cAliasQry
			SELECT DCF.DCF_LOCDES,
					DCF.DCF_ENDDES
			FROM %Table:DCF% DCF
			WHERE DCF.DCF_FILIAL = %xFilial:DCF%
			AND DCF.DCF_UNIDES = %Exp:oTransf:GetUniDes()%
			AND DCF.DCF_STSERV IN ('1','2','4')
			AND DCF.%NotDel%
			AND EXISTS (SELECT 1 
						FROM %Table:DC5% DC5
						WHERE DC5.DC5_FILIAL = %xFilial:DC5%
						AND DC5.DC5_SERVIC = DCF.DCF_SERVIC
						AND DC5.DC5_TIPO = '3'
						AND DC5.%NotDel% )
		EndSql
		Do While lRet .And. (cAliasQry)->(!Eof())
			If Empty((cAliasQry)->DCF_ENDDES) .Or. !((cAliasQry)->(DCF_LOCDES+DCF_ENDDES) == oTransf:oMovEndDes:GetArmazem()+oTransf:oMovEndDes:GetEnder())
				lRet := .F.
			EndIf
			(cAliasQry)->(dbSkip())
		EndDo
		(cAliasQry)->(dbCloseArea())
	EndIf
	RestArea(aAreaAnt)
Return lRet
//-------------------------------------
/*/{Protheus.doc} QtdDispEnd
Calcula quantidade disponível no endereço
@author amanda.vieira
@since 25/11/2019
@version 1.0
/*/
//-------------------------------------
Static Function QtdDispEnd(cPrdOri,cProduto,cLoteCtl,cNumLote,cLocal,cEnder,cIdUnit)
Local nSldEnd   := 0
Local oEstEnder := WMSDTCEstoqueEndereco():New()
	oEstEnder:oEndereco:SetArmazem(cLocal)
	oEstEnder:oEndereco:SetEnder(cEnder)
	oEstEnder:oProdLote:SetArmazem(cLocal)
	oEstEnder:oProdLote:SetPrdOri(cPrdOri)
	oEstEnder:oProdLote:SetProduto(cProduto)
	oEstEnder:oProdLote:SetLoteCtl(cLoteCtl)
	oEstEnder:oProdLote:SetNumLote(cNumLote)
	oEstEnder:SetIdUnit(cIdUnit)
	If oEstEnder:LoadData()
		nSldEnd := oEstEnder:ConsultSld(.F.,.T.,.T.,.T.)
	EndIf
	oEstEnder:Destroy()
Return nSldEnd
//-------------------------------------
/*/{Protheus.doc} WMSRemBloq
Remove quantidade bloqueada para permitir a transferência
@author amanda.vieira
@since 25/11/2019
@version 1.0
/*/
//-------------------------------------
Function WMSRemBloq(cPrdOri,cProduto,cLoteCtl,cNumLote,cLocal,cEnder,cIdUnit,nQtdTrsf,cIdDCF,cDocto,oModel)
Local lRet        := .T.
Local cAliasD0V   := GetNextAlias()
Local nQtdDisp    := QtdDispEnd(cPrdOri,cProduto,cLoteCtl,cNumLote,cLocal,cEnder,cIdUnit) //Quantidade disponível para a transferência
Local nQtdLiberar := nQtdTrsf - nQtdDisp //Quantidade que precisará ter quantidade liberada
Local nQtdBlq     := 0
Local aRetPE      := {}
Default oModel    := Nil

	If	ExistBlock("WMS225QL")
		aRetPE := ExecBlock("WMS225QL",.F.,.F.,{nQtdTrsf})
		If aRetPE[1]
			nQtdLiberar := aRetPE[2]
		EndIf
	EndIf

	If nQtdLiberar > 0
		BeginSql Alias cAliasD0V
			SELECT D0V.D0V_QTDBLQ,
				   D0V.D0V_IDBLOQ,
				   D0V.D0V_DTVALD
			  FROM %Table:D0V% D0V
			 WHERE D0V.D0V_FILIAL = %xFilial:D0V%
			   AND D0V.D0V_PRDORI = %Exp:cPrdOri%
			   AND D0V.D0V_PRODUT = %Exp:cProduto%
			   AND D0V.D0V_LOTECT = %Exp:cLoteCtl%
			   AND D0V.D0V_NUMLOT = %Exp:cNumLote%
			   AND D0V.D0V_LOCAL  = %Exp:cLocal%
			   AND D0V.D0V_ENDER  = %Exp:cEnder%
			   AND D0V.D0V_IDUNIT = %Exp:cIdUnit%
			   AND D0V.%NotDel%
		EndSql
		TcSetField(cAliasD0V,'D0V_DTVALD','D')
		While (cAliasD0V)->(!EoF()) .And. nQtdLiberar > 0
			If (cAliasD0V)->D0V_QTDBLQ > nQtdLiberar
				nQtdBlq := nQtdLiberar
			Else 
				nQtdBlq := (cAliasD0V)->D0V_QTDBLQ
			EndIf
			nQtdLiberar -= nQtdBlq
			//Remove Bloqueio do Produto
			lRet := RemBloqPrd((cAliasD0V)->D0V_IDBLOQ,cPrdOri,cProduto,cLoteCtl,cNumLote,cLocal,cEnder,cIdUnit,nQtdBlq,cIdDCF,cDocto,(cAliasD0V)->D0V_DTVALD,oModel)
			(cAliasD0V)->(dbSkip())
		EndDo
		(cAliasD0V)->(dbCloseArea())
	EndIf

	If nQtdLiberar > 0 .And. !Empty(oModel)
		oModel:GetModel():SetErrorMessage( , , oModel:GetId() , "", "", STR0054, "", "", "") //Não foi possível liberar toda a quantidade para a transferência.
		lRet := .F.
	EndIf
Return lRet
//-------------------------------------
/*/{Protheus.doc} RemBloqPrd
Remove bloqueio de estoque do produto
@author amanda.vieira
@since 25/11/2019
@version 1.0
/*/
//-------------------------------------
Static Function RemBloqPrd(cIdBlq,cPrdOri,cProduto,cLoteCtl,cNumLote,cLocal,cEnder,cIdUnit,nQtdLib,cIdDCF,cDocto,dDtValid,oModel)
Local lRet := .T.
Local oTransfBlqItens := Nil
	If TableInDic("D18", .F.)
		oTransfBlqItens := WMSDTCTransferenciaBloqueioSaldoItens():New()
		oTransfBlqItens:SetIdDCF(cIdDCF)
		oTransfBlqItens:SetDocto(cDocto)
		oTransfBlqItens:SetIdBlq(cIdBlq)
		oTransfBlqItens:SetPrdOri(cPrdOri)
		oTransfBlqItens:SetProduto(cProduto)
		oTransfBlqItens:SetLoteCtl(cLoteCtl)
		oTransfBlqItens:SetNumLote(cNumLote)
		oTransfBlqItens:SetLocal(cLocal)
		oTransfBlqItens:SetEnder(cEnder)
		oTransfBlqItens:SetIdUnit(cIdUnit)
		oTransfBlqItens:SetQtdLib(nQtdLib)
		oTransfBlqItens:SetDtValid(dDtValid)
		If !(lRet := oTransfBlqItens:RemoverBloqueioParaTransferir()) .And. !Empty(oModel)
			oModel:GetModel():SetErrorMessage( , , oModel:GetId() , "", "", oTransfBlqItens:GetErro(), "", "", "")
		EndIf
		FreeObj(oTransfBlqItens)
	EndIf
Return lRet
//-------------------------------------
/*/{Protheus.doc} WMSRemBlUn
Remove bloqueio do unitizador
@author amanda.vieira
@since 25/11/2019
@version 1.0
/*/
//-------------------------------------
Function WMSRemBlUn(cIdUnit,cIdDCF,cDocto,cArmazem,oModel)
Local lRet := .T.
Local cAliasD14 := "" 

	If TableInDic("D18", .F.)
		cAliasD14 := GetNextAlias()
		BeginSql Alias cAliasD14
			SELECT D14.D14_LOCAL,
					D14.D14_PRODUT,
					D14.D14_PRDORI,
					D14.D14_LOTECT,
					D14.D14_NUMLOT,
					D14.D14_QTDEST,
					D14.D14_ENDER,
					D14.D14_IDUNIT
			FROM %Table:D14% D14
			WHERE D14.D14_FILIAL = %xFilial:D14%
			AND D14.D14_IDUNIT = %Exp:cIdUnit%
			AND D14.D14_LOCAL = %Exp:cArmazem%
			AND D14.%NotDel%
		EndSql
		Do While lRet .And. (cAliasD14)->(!Eof())
			lRet := WMSRemBloq((cAliasD14)->D14_PRDORI,;
							(cAliasD14)->D14_PRODUT,;
							(cAliasD14)->D14_LOTECT,;
							(cAliasD14)->D14_NUMLOT,;
							(cAliasD14)->D14_LOCAL,;
							(cAliasD14)->D14_ENDER,;
							(cAliasD14)->D14_IDUNIT,;
							(cAliasD14)->D14_QTDEST,;
							cIdDCF,;
							cDocto,;
							oModel)
			(cAliasD14)->(dbSkip())
		EndDo
		(cAliasD14)->(dbCloseArea())
	EndIf
Return lRet

//-------------------------------------
/*/{Protheus.doc} RefBloq
Refaz bloqueio de estoque do produto
@author amanda.vieira
@since 25/11/2019
@version 1.0
/*/
//-------------------------------------
Static Function RefBloq(cIdDCF,cDocto,oModel)
Local lRet := .T.
Local oTransfBlqItens := Nil

	If TableInDic("D18", .F.)
		oTransfBlqItens := WMSDTCTransferenciaBloqueioSaldoItens():New()
		oTransfBlqItens:SetIdDCF(cIdDCF)
		oTransfBlqItens:SetDocto(cDocto)
		If !(lRet := oTransfBlqItens:RefazerBloqueio()) .And. !Empty(oModel)
			oModel:GetModel():SetErrorMessage( , , oModel:GetId() , "", "", oTransfBlqItens:GetErro(), "", "", "")
		EndIf
		FreeObj(oTransfBlqItens)
	EndIf
Return lRet
//-------------------------------------
/*/{Protheus.doc} WMSDtVdDif
Função para validar se existe no armzem destino mesmo lote/Subolote com data de validade diferente da origem.
@author roselaine.adriano
@since 05/05/2020
@version 1.0
/*/
//-------------------------------------
Function WMSDtVdDif(cArmOri,cArmDest, cProduto, cLotectl, cNumLote)
Local lRet := .T.
Local cAliasSB8 := ""
 
	cAliasSB8 := GetNextAlias()
	BeginSql Alias cAliasSB8
		SELECT DISTINCT 1
  		FROM %Table:SB8% SB8
 		WHERE SB8.B8_FILIAL = %xFilial:SB8%
  	 	AND SB8.B8_LOCAL =  %Exp:cArmOri%
   		AND SB8.B8_PRODUTO = %Exp:cProduto%
   		AND SB8.B8_LOTECTL = %Exp:cLotectl%
   		AND SB8.B8_NUMLOTE  = %Exp:cNumLote%
   		AND EXISTS (SELECT DISTINCT 1  
  					FROM %Table:SB8% SB82
 					WHERE Sb82.B8_FILIAL = %xFilial:SB8%
   					AND SB82.B8_LOCAL = %Exp:cArmDest%
   					AND SB82.B8_PRODUTO = %Exp:cProduto%
   					AND SB82.B8_LOTECTL = %Exp:cLotectl%
   					AND SB82.B8_NUMLOTE  = %Exp:cNumLote%
   					AND SB82.b8_dtvalid <> SB8.b8_dtvalid
					AND SB82.%NotDEl%)
		AND SB8.%NotDel%   
	ENDSQL
	If (cAliasSB8)->(!EoF())
		lRet := .F. 
	EndIf
	(cAliasSB8)->(dbCloseArea())
Return lRet 

//-------------------------------------
/*/{Protheus.doc} WMSDtVdDif
Função para validar se existe no armzem destino mesmo lote/Subolote com data de Fabricacao diferente da origem.
@author roselaine.adriano
@since 14/07/2020
@version 1.0
/*/
//-------------------------------------
Function WMSDtFbDif(cArmOri,cArmDest, cProduto, cLotectl, cNumLote)
Local lRet := .T.
Local cAliasSB8 := ""
 
	cAliasSB8 := GetNextAlias()
	BeginSql Alias cAliasSB8
		SELECT DISTINCT 1
  		FROM %Table:SB8% SB8
 		WHERE SB8.B8_FILIAL = %xFilial:SB8%
  	 	AND SB8.B8_LOCAL =  %Exp:cArmOri%
   		AND SB8.B8_PRODUTO = %Exp:cProduto%
   		AND SB8.B8_LOTECTL = %Exp:cLotectl%
   		AND SB8.B8_NUMLOTE  = %Exp:cNumLote%
   		AND EXISTS (SELECT DISTINCT 1  
  					FROM %Table:SB8% SB82
 					WHERE Sb82.B8_FILIAL = %xFilial:SB8%
   					AND SB82.B8_LOCAL = %Exp:cArmDest%
   					AND SB82.B8_PRODUTO = %Exp:cProduto%
   					AND SB82.B8_LOTECTL = %Exp:cLotectl%
   					AND SB82.B8_NUMLOTE  = %Exp:cNumLote%
   					AND SB82.b8_DFABRIC <> SB8.b8_DFABRIC
					AND SB82.%NotDEl%)
		AND SB8.%NotDel%   
	ENDSQL
	If (cAliasSB8)->(!EoF())
		lRet := .F. 
	EndIf
	(cAliasSB8)->(dbCloseArea())
Return lRet 

Static Function WMSDcfOri(cAliasDCF, cIdDef) 
Local aAreaAnt   := GetArea()

	BeginSql Alias cAliasDCF
		SELECT DCF_SERVIC,DCF_DOCTO,DCF_SERIE,DCF_DATA,DCF_CODPRO,DCF_CLIFOR,DCF_LOJA
		FROM %Table:DCF% DCF
		WHERE DCF.DCF_FILIAL = %xFilial:DCF%
		AND DCF.DCF_ID = %Exp:cIdDef%
		AND DCF.%NotDel%
	EndSql

	RestArea(aAreaAnt)
Return cAliasDCF

//-------------------------------------
/*/{Protheus.doc} WMSDtFuro
Funcao para validar diferencas de datas entre SB8 e D14
@author Equipe WMS
@since 20/07/2021
@version 1.0
/*/
//-------------------------------------
Static Function WMSDtFuro(oTransf)
	Local lRet := .T.
	Local cAliasSB8 := ""
	Local cArmOri	:= oTransf:oMovEndOri:GetArmazem()
	Local cProduto  := oTransf:oMovPrdLot:GetPrdOri()
	Local cLotectl  := oTransf:oMovPrdLot:GetLotectl()
	Local cNumLote  := oTransf:oMovPrdLot:GetNUmlote()
	Local cEndOri	:= oTransf:oMovEndOri:GetEnder()
	Local oModel    := FwModelActive()

	cAliasSB8 := GetNextAlias()
	BeginSql Alias cAliasSB8
		SELECT B8_DFABRIC,
			B8_DTVALID,
			D14_DTFABR,
			D14_DTVALD
		FROM %TABLE:SB8% SB8
		INNER JOIN %TABLE:D14% D14 ON (D14.D14_FILIAL = %xFilial:D14% 
									AND D14.D14_LOCAL = SB8.B8_LOCAL
									AND D14.D14_PRDORI = SB8.B8_PRODUTO
									AND D14.D14_LOTECT = SB8.B8_LOTECTL
									AND D14.D14_NUMLOT = SB8.B8_NUMLOTE)
		WHERE B8_FILIAL = %xFilial:SB8%
		AND B8_LOCAL = %Exp:cArmOri%
		AND B8_PRODUTO = %Exp:cProduto%
		AND B8_LOTECTL = %Exp:cLotectl%
		AND B8_NUMLOTE = %Exp:cNumLote%
		AND D14_ENDER  = %Exp:cEndOri%
		AND SB8.%NotDel%
		AND D14.%NotDel%
	ENDSQL
	If (cAliasSB8)->(!EoF())
		If (cAliasSB8)->B8_DFABRIC <> (cAliasSB8)->D14_DTFABR 
			lRet := .F. 
			oModel:GetModel():SetErrorMessage( , , oModel:GetId() , "", "", STR0066 + cValToChar(STOD((cAliasSB8)->B8_DFABRIC)) + STR0067 + cValToChar(STOD((cAliasSB8)->D14_DTFABR)) + STR0068 , "", "", "") //"A data de fabricação (" ") do lote na tabela SB8 está diferente da data de fabricação ("") do lote na tabela D14. Utilize o programa WMSA535 (Troca de Validade do Lote) para equalizar a divergência."
		ElseIf (cAliasSB8)->B8_DTVALID <> (cAliasSB8)->D14_DTVALD
			oModel:GetModel():SetErrorMessage( , , oModel:GetId() , "", "", STR0069 + cValToChar(STOD((cAliasSB8)->B8_DTVALID)) + STR0070 + cValToChar(STOD((cAliasSB8)->D14_DTVALD)) + STR0068, "", "", "")//"A data de validade ("") do lote na tabela SB8 está diferente da data de validade ("") do lote na tabela D14. Utilize o programa WMSA535 (Troca de Validade do Lote) para equalizar a divergência."
			lRet := .F. 
		EndIf
	EndIf
	(cAliasSB8)->(dbCloseArea())

Return lRet 

//-------------------------------------
/*/{Protheus.doc} WmsDCFdDH1
Deleta DH1 de acordo com o codigo IDDCF
@author Equipe WMS
@since 16/01/2023
@version 1.0
/*/
//-------------------------------------
Function WmsDCFdDH1(cIdDCF)
	Local cAliasDH1 := Nil
	Local aArea := GetArea()

	cAliasDH1 := GetNextAlias()
	BeginSql Alias cAliasDH1
		SELECT R_E_C_N_O_ RECNODH1
		FROM %Table:DH1% DH1
		WHERE DH1.DH1_FILIAL = %xFilial:DH1%
		AND DH1.DH1_IDDCF = %Exp:cIdDCF%
		AND DH1.%NotDel%
		ORDER BY DH1.R_E_C_N_O_
	EndSql
	Do While (cAliasDH1)->(!Eof())
		DH1->(dbGoTo((cAliasDH1)->RECNODH1))
		RecLock("DH1",.F.)
		DH1->(dbDelete())
		DH1->(MsUnlock())
		(cAliasDH1)->(dbSkip())
	EndDo
	(cAliasDH1)->(dbCloseArea())

	RestArea(aArea)

Return


//-------------------------------------
/*/{Protheus.doc} WMS225VUNI
Valida o unitizador preenchido
@author Equipe WMS
@since 11/01/2023
@version 1.0
/*/
//-------------------------------------
Static Function WMS225VUNI(oTransf)
	Local oModel 	:= FwModelActive()
	Local lRet      := .T.
	Local aArea     := GetArea()
	Local cAliasQry := GetNextAlias()
	
	BeginSql Alias cAliasQry
		SELECT D14_LOCAL, D14_ENDER
		FROM %Table:D14% D14
		WHERE D14.D14_FILIAL =  %xFilial:D14%
		AND D14.D14_IDUNIT = %Exp:oTransf:GetUniDes()%
		AND D14.%NotDel%
	EndSql
	If (cAliasQry)->(!Eof())
		If ((cAliasQry)->D14_ENDER != oTransf:oMovEndDes:GetEnder() .Or. (cAliasQry)->D14_LOCAL != oTransf:oMovEndDes:GetArmazem()) // .And.;
			oModel:GetModel():SetErrorMessage(,,oModel:GetId(),"","",STR0073 + (cAliasQry)->D14_LOCAL + STR0074 +RTRIM((cAliasQry)->D14_ENDER)+".", "", "", "") //"O unitizador informado está armazenado no local "" e endereço "
			lRet := .F.
		EndIf
	EndIf
	(cAliasQry)->(DbCloseArea())
	RestArea(aArea)
	
Return lRet
