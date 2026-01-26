#include "TECA871.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"

//Status do orçamento de serviços 
#DEFINE DEF_TFJ_ATIVO     "1"			//TFJ_STATUS Ativo
#DEFINE DEF_TFJ_EMREVISAO "2"			//TFJ_STATUS Em Revisão
#DEFINE DEF_TFJ_REVISADO  "3"			//TFJ_STATUS Revisado
#DEFINE DEF_TFJ_AGDAPROVA "4"			//TFJ_STATUS Aguardando Aprovação
#DEFINE DEF_TFJ_ENCERRADO "5"			//TFJ_STATUS Encerrado
#DEFINE DEF_TFJ_CANCELADO "6"			//TFJ_STATUS Cancelado

//----------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Model - Efetivar encerramento do posto 

@Return 	model
@author 	Serviços
@since 		25/08/2015
/*/
//----------------------------------------------------------
Static Function ModelDef()
Local oModel	:= Nil
Local oStrCab	:= FWFormStruct(1,"TFJ")
Local oStrTFL 	:= FWFormStruct(1,"TFL")
Local oStrTFF 	:= FWFormStruct(1,"TFF")
Local oStrTFI 	:= FWFormStruct(1,"TFI")
Local xAux    	:= Nil

oModel := MPFormModel():New("TECA871", /*bPreValidacao*/, {|oMdl| At871RecPen(oMdl)}, {|oMdl| At871Commit(oMdl)}, /*bCancel*/ )

//Criando master falso para a alimentação dos details.
oModel:AddFields("TFJMASTER",/*cOwner*/,oStrCab, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

//locais do contrato
oModel:AddGrid( "TFLDETAIL", "TFJMASTER", oStrTFL, {|oMdlTFL, nLine, cAction, cField, xValue, xOldValue| At871PVTFL(oMdlTFL, cAction, nLine, cField, xValue, xOldValue)}, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*bLoad*/ )
oModel:SetRelation( "TFLDETAIL", { { "TFL_FILIAL", "xFilial('TFL')" }, { "TFL_CONTRT", "TFJ_CONTRT" } , { "TFL_CONREV", "TFJ_CONREV" } }, TFL->(IndexKey(1)) )
oModel:SetDescription(STR0001) //"Locais do contrato"

//Itens do RH
oModel:AddGrid( "TFFDETAIL", "TFLDETAIL", oStrTFF, {|oMdlTFF, nLine, cAction, cField, xValue| At871PVTFF(oMdlTFF, cAction, nLine, cField, xValue)}, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*bLoad*/ )
oModel:SetRelation( "TFFDETAIL", { { "TFF_FILIAL", "xFilial('TFF')" }, { "TFF_CONTRT", "TFL_CONTRT" } , { "TFF_CONREV", "TFL_CONREV" } , { "TFF_CODPAI", "TFL_CODIGO" } }, TFF->(IndexKey(1)) )
oModel:SetDescription(STR0002) //"Itens do RH"

//Itens de locação
oModel:AddGrid( "TFIDETAIL", "TFLDETAIL", oStrTFI, {|oMdlTFI, nLine, cAction, cField, xValue| At871PVTFI(oMdlTFI, cAction, nLine, cField, xValue)}, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*bLoad*/ )
oModel:SetRelation( "TFIDETAIL", { { "TFI_FILIAL", "xFilial('TFI')" }, { "TFI_CONTRT", "TFL_CONTRT" } , { "TFI_CONREV", "TFL_CONREV" } , { "TFI_CODPAI", "TFL_CODIGO" } }, TFI->(IndexKey(1)) )
oModel:SetDescription(STR0003) //"Itens de locação" 

//Adicional campo OK para controle da operação
oStrTFL:AddField("", "", "OK", "L", 1, 0, /*bValid */, , {}	, .F., , .F., .F., .F., , )//''#//'Seleção'
oStrTFF:AddField("", "", "OK", "L", 1, 0, /*bValid */, , {}	, .F., , .F., .F., .F., , )//''#//'Seleção'
oStrTFI:AddField("", "", "OK", "L", 1, 0, /*bValid */, , {}	, .F., , .F., .F., .F., , )//''#//'Seleção'

oModel:getModel("TFFDETAIL"):SetOptional(.T.)
oModel:getModel("TFIDETAIL"):SetOptional(.T.)

oModel:GetModel("TFLDETAIL"):SetNoDeleteLine()
oModel:GetModel("TFFDETAIL"):SetNoDeleteLine()
oModel:GetModel("TFIDETAIL"):SetNoDeleteLine()

oModel:GetModel("TFLDETAIL"):SetNoInsertLine()
oModel:GetModel("TFFDETAIL"):SetNoInsertLine()
oModel:GetModel("TFIDETAIL"):SetNoInsertLine()

If TFL->( ColumnPos('TFL_DTENCE') ) > 0 .AND. TFF->( ColumnPos('TFF_DTENCE') ) > 0
	xAux := FwStrutrigger( 'OK', 'OK', 'At871DtEnc("TFL", .T.)',.F.)
		oStrTFL:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

	xAux := FwStrutrigger( 'TFL_DTENCE', 'TFL_DTENCE', 'At871DtGat("TFL")',.F.)
		oStrTFL:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

	xAux := FwStrutrigger( 'OK', 'OK', 'At871DtEnc("TFF")',.F.)
		oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

	xAux := FwStrutrigger( 'TFF_DTENCE', 'TFF_DTENCE', 'At871DtGat("TFF")',.F.)
		oStrTFF:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

EndIf

oStrTFL:SetProperty("TFL_DESLOC", MODEL_FIELD_INIT, {|| Posicione("ABS",1,xFilial("ABS")+TFL->TFL_LOCAL,"ABS_DESCRI")})
oStrTFL:SetProperty("TFL_MUNIC",  MODEL_FIELD_INIT, {|| Posicione("ABS",1,xFilial("ABS")+TFL->TFL_LOCAL,"ABS_MUNIC")})
oStrTFL:SetProperty("TFL_ESTADO", MODEL_FIELD_INIT, {|| Posicione("ABS",1,xFilial("ABS")+TFL->TFL_LOCAL,"ABS_ESTADO")})

oStrTFI:SetProperty("TFI_DESCRI", MODEL_FIELD_INIT, {|| Posicione("SB1",1,xFilial("SB1")+TFI->TFI_PRODUT,"B1_DESC")}) 
oStrTFI:SetProperty("TFI_UM",     MODEL_FIELD_INIT, {|| Posicione("SB1",1,xFilial("SB1")+TFI->TFI_PRODUT,"B1_UM")})
oStrTFI:SetProperty("TFI_ENCE",   MODEL_FIELD_WHEN, {|| !(Empty(FwFldGet("TFI_PRODUT")))})
oStrTFI:SetProperty("OK",         MODEL_FIELD_WHEN, {|| !(Empty(FwFldGet("TFI_PRODUT")))})

oStrTFF:SetProperty("OK",         MODEL_FIELD_WHEN, {|| !(Empty(FwFldGet("TFF_PRODUT")))})
oStrTFF:SetProperty("TFF_ENCE",   MODEL_FIELD_WHEN, {|| !(Empty(FwFldGet("TFF_PRODUT")))})

If TFL->( ColumnPos('TFL_DTENCE') ) > 0
	oStrTFL:SetProperty("TFL_DTENCE",   MODEL_FIELD_WHEN, {|| .T.})
EndIf

If TFF->( ColumnPos('TFF_DTENCE') ) > 0
	oStrTFF:SetProperty("TFF_DTENCE",   MODEL_FIELD_WHEN, {|| !(Empty(FwFldGet("TFF_PRODUT")))})
EndIf

oStrTFF:SetProperty("TFF_DESCRI", MODEL_FIELD_INIT, {|| Posicione("SB1",1,xFilial("SB1")+TFF->TFF_PRODUT,"B1_DESC")})

If (TFF->(ColumnPos('TFF_GERVAG')) > 0)
	oStrTFF:SetProperty('TFF_FUNCAO',MODEL_FIELD_OBRIGAT,.F.)
EndIf
oStrTFF:SetProperty('TFF_PRCVEN',MODEL_FIELD_OBRIGAT,.F.)
oStrCab:SetProperty('*',MODEL_FIELD_OBRIGAT,.F.)

oModel:SetPrimarykey({})
oModel:SetActivate( {|oModel| InitDados( oModel ) } )

At740AddLeg(.T.,{oStrTFL},{oStrTFF},{oStrTFI})

Return(oModel)


//----------------------------------------------------------
/*/{Protheus.doc} ViewDef()
View - Relacionamentos - Gestão de Escalas 

@Return 	view
@author 	Serviços
@since 		17/08/2015
/*/
//----------------------------------------------------------
Static Function ViewDef()

Local oView
Local oModel  := FWLoadModel("TECA871")
Local oStrCab := FWFormStruct(2,"TFJ")  
Local oStrTFL := FWFormStruct(2,"TFL",{|cCpo| !(Alltrim(cCpo)$"TFL_ENCE")})
Local oStrTFF := FWFormStruct(2,"TFF",{|cCpo| !(Alltrim(cCpo)$"TFF_ENCE")})
Local oStrTFI := FWFormStruct(2,"TFI",{|cCpo| !(Alltrim(cCpo)$"TFI_ENCE")})
Local lGSLE	  := GSGetIns('LE') 
Local lGSRH   := GSGetIns('RH') 

oView := FWFormView():New()
oView:SetModel(oModel)

oView:AddField("FORM_FAKE",oStrCab, "TFJMASTER") //Cabeçalho falso
oView:AddGrid("VIEW_TFL",  oStrTFL, "TFLDETAIL") //Locais do contrato
oView:AddGrid("VIEW_TFF",  oStrTFF, "TFFDETAIL") //Itens do RH
oView:AddGrid("VIEW_TFI",  oStrTFI, "TFIDETAIL") //Itens de locação

//campo adicional OK
oStrTFL:AddField( "OK", "01", "", "", , "Check" ,,,,,,,,,,,, ) //''#//''
oStrTFF:AddField( "OK", "01", "", "", , "Check" ,,,,,,,,,,,, ) //''#//''
oStrTFI:AddField( "OK", "01", "", "", , "Check" ,,,,,,,,,,,, ) //''#//''

oView:CreateHorizontalBox("BOXCABEC", 0)	//Cabeçalho
oView:CreateHorizontalBox("SUPERIOR", 30)	//locais do contrato
oView:CreateHorizontalBox("INFERIOR", 70)	//locais do contrato

// Criação da pasta para conter as abas da parte inferior
oView:CreateFolder( "ABAS", "INFERIOR" )

// Criação das Abas
oView:AddSheet( "ABAS", "ABA01", STR0002 )	// "Itens RH"
oView:AddSheet( "ABAS", "ABA02", STR0003 )	// "Itens de locação"

// Criação das áreas de exibição dos dados nas abas
oView:CreateHorizontalBox( "ID_ABA01", 100,,, "ABAS", "ABA01" )
oView:CreateHorizontalBox( "ID_ABA02", 100,,, "ABAS", "ABA02" )

If TFL->( ColumnPos('TFL_DTENCE') ) > 0
	oStrTFL:SetProperty("TFL_DTENCE",   MVC_VIEW_ORDEM, "02")
EndIf

If TFF->( ColumnPos('TFF_DTENCE') ) > 0
	oStrTFF:SetProperty("TFF_DTENCE",   MVC_VIEW_ORDEM, "02")
EndIf

oStrCab:SetProperty("*",        MVC_VIEW_CANCHANGE, .F.)
oStrTFL:SetProperty("*",        MVC_VIEW_CANCHANGE, .F.)
oStrTFF:SetProperty("*",        MVC_VIEW_CANCHANGE, .F.)
oStrTFI:SetProperty("*",        MVC_VIEW_CANCHANGE, .F.)
oStrTFF:SetProperty("OK",       MVC_VIEW_CANCHANGE, .T.)
oStrTFI:SetProperty("OK",       MVC_VIEW_CANCHANGE, .T.)
oStrTFL:SetProperty("OK",       MVC_VIEW_CANCHANGE, .T.)

If TFL->( ColumnPos('TFL_DTENCE') ) > 0
	oStrTFL:SetProperty("TFL_DTENCE", MVC_VIEW_CANCHANGE, .T.)
EndIf

If TFF->( ColumnPos('TFF_DTENCE') ) > 0
	oStrTFF:SetProperty("TFF_DTENCE", MVC_VIEW_CANCHANGE, .T.)
EndIf

oView:SetOwnerView("FORM_FAKE", "BOXCABEC")	// Cabeçalho
oView:SetOwnerView("VIEW_TFL",  "SUPERIOR") 
oView:SetOwnerView("VIEW_TFF",  "ID_ABA01")	// Grid Itens do RH
oView:SetOwnerView("VIEW_TFI",  "ID_ABA02")	// Grid Itens de locação
 
At740AddLeg(.F.,{oStrTFL,"VIEW_TFL"},{oStrTFF,"VIEW_TFF"},{oStrTFI,"VIEW_TFI"},oView) 

If !lGSRH
	oView:HideFolder( "ABAS",  STR0002, 2 )	// "Itens RH"
EndIf

If !lGSLE
	oView:HideFolder( "ABAS", STR0003, 2 )	// "Itens de locação"
EndIf
 
Return oView


//----------------------------------------------------------
/*/{Protheus.doc} At871RecPen()
	Validar recursos dos postos a serem encerrados 

@Return 	ExpL: .T. = Registros avaliados com sucesso; .F. = Há inconsistências nos registros que impedem a sua gravação
@author 	Serviços
@since 		26/08/2015
/*/
//----------------------------------------------------------
Static Function At871RecPen(oMdl)

Local cOldAlias		:= Alias()
Local aOldAlias		:= (cOldAlias)->(GetArea()) 
Local oMdlTFL		:= oMdl:GetModel("TFLDETAIL")
Local oMdlTFF		:= oMdl:GetModel("TFFDETAIL")
Local oMdlTFI		:= oMdl:GetModel("TFIDETAIL")
Local oMdlTFJ		:= oMdl:GetModel("TFJMASTER")
Local aCmpTFS       := {}
Local aCmpTXQ       := {}
Local aLogMail      := {}
Local aRetMail      := {}
Local aSaveLines    := FWSaveRows()
Local cAssunto      := ""
Local cCliente      := ""
Local cCod          := ""
Local cCodTFF       := ""
Local cContrt       := ""
Local cDesc         := ""
Local cDescri       := ""
Local cFile			:= ""
Local cLocal        := ""
Local cGrpCom		:= ""
Local cMailArma     := ""
Local cMailMI       := ""
Local cMailPosto    := ""
Local cMsg			:= ""
Local cMens         := ""
Local cMens02       := ""
Local cMens03       := ""
Local cPicTFSQtde   := ""
Local cProduto      := ""
Local cTitABBCod    := ""
Local cTitTFFFunc   := ""
Local cTitTFSPrd    := "" 
Local cTitTFSQtde   := "" 
Local cTmpTEW       := ""
Local cTmpTFF       := ""
Local cTmpTFS       := ""
Local cTmpTXQ       := ""
Local cTpMov        := ""
Local cAdmissa      := ""
Local cQuery        := ""
Local cDrive        := ""
Local cDir          := ""
Local cNome         := ""
Local cExt          := ""
Local dDtEnce       := dDataBase
Local lAllMrk       := .T.
Local lDtEnce       := FindFunction("TecEncDtFt") .AND. TecEncDtFt()
Local lGSLE         := GSGetIns("LE")
Local lGsOrcArma 	:= FindFunction("TecGsArma") .And. TecGsArma()
Local lMsgLocal     := .F.
Local lOkTEW        := .T.
Local lOkTFF        := .T.
Local lOkTFS        := .T.
Local lOkTXQ        := .T.
Local lOrcPrc       := SuperGetMV("MV_ORCPRC",,.F.)
Local lRet          := .T.
Local nInd          := 0
Local nLinTFF       := 0
Local nLinTFI       := 0
Local nLinTFL       := 0
Local nQuant        := 0
Local nSld          := 0
Local nX            := 0
Local nY            := 0
Local oQuery        := Nil

cTitABBCod  := AllTrim(FWX3Titulo("ABB_CODTEC"))+":"
cTitTFFFunc := AllTrim(FWX3Titulo("TFF_FUNCAO"))+":"
cTitTFSPrd  := AllTrim(FWX3Titulo("TFS_PRODUT"))+":"
cTitTFSQtde := AllTrim(FWX3Titulo("TFS_QUANT"))+":"
cPicTFSQtde := AllTrim(X3Picture("TFS_QUANT"))

cGrpCom := oMdlTFJ:GetValue("TFJ_GRPCOM")
cContrt := oMdlTFJ:GetValue("TFJ_CONTRT")
cCliente := Posicione("SA1",1,xFilial("SA1")+oMdlTFJ:GetValue("TFJ_CODENT")+oMdlTFJ:GetValue("TFJ_LOJA"),"A1_NOME") //A1_FILIAL+A1_COD+A1_LOJA

//verificar se a linha selecionada esta para ser encerrado o posto esta marcado o OK
cMens	   := ""
cMailArma  := at871AddMsg("<br>", "", "CONTRATO", cContrt, cCliente)
cMailMI    := at871AddMsg("<br>", "", "CONTRATO", cContrt, cCliente)
cMailPosto := at871AddMsg("<br>", "", "CONTRATO", cContrt, cCliente)

For nLinTFL := 1 To oMdlTFL:Length() //Percorrerá todo grid
	oMdlTFL:GoLine(nLinTFL)
	If oMdlTFL:GetValue("OK") .And. oMdlTFL:GetValue("TFL_ENCE") != "1"  // Verifica se o local de atendimento está marcado
		
		cCod  	:= AllTrim(oMdlTFL:GetValue("TFL_CODIGO"))
		cLocal	:= AllTrim(oMdlTFL:GetValue("TFL_LOCAL"))
		cDescri	:= Posicione("ABS",1,xFilial("ABS")+cLocal,"ABS_DESCRI") //ABS_FILIAL+ABS_LOCAL

		cMens		:= at871AddMsg(CRLF, cMens, "LOCAL", cLocal, cDescri)
		cMailArma	:= at871AddMsg("<br>", cMailArma, "LOCAL", cLocal, cDescri)
		cMailMI		:= at871AddMsg("<br>", cMailMI, "LOCAL", cLocal, cDescri)
		cMailPosto	:= at871AddMsg("<br>", cMailPosto, "LOCAL", cLocal, cDescri)
		
		lMsgLocal := .T.
		If lOrcPrc
			//Verificar os materiais de implantação não retornados MV_ORCPRC .T.(Materiais filhos do Local de atendimento)
			cQuery := "SELECT TFL.TFL_CODIGO, TFS.TFS_PRODUT, SB1.B1_DESC, SUM(TFS.TFS_QUANT) AS QtTotal, TFS.TFS_MOV, TFG.TFG_ITEM, TFG.TFG_RESRET "
			cQuery += " FROM ? TFS "
			cQuery += " INNER JOIN ? TFG ON TFG.TFG_FILIAL = ? "
			cQuery +=		" AND TFG.TFG_COD = TFS.TFS_CODTFG "
			cQuery +=		" AND TFG.D_E_L_E_T_ = ' ' "
			cQuery += " INNER JOIN ? TFL ON TFL.TFL_FILIAL = ? "
			cQuery +=		" AND TFL.TFL_CODIGO = TFG.TFG_CODPAI "
			cQuery +=		" AND TFL.TFL_CONTRT = ? "
			cQuery +=		" AND TFL.TFL_CODIGO = ? "
			cQuery +=		" AND TFL.D_E_L_E_T_ = ' ' "
			cQuery += " INNER JOIN ? SB1 on SB1.B1_FILIAL = ? "
			cQuery +=		" AND SB1.B1_COD = TFS.TFS_PRODUT "
			cQuery +=		" AND SB1.D_E_L_E_T_ = ' ' "
			cQuery += " WHERE TFS.TFS_FILIAL = ? "
			cQuery +=		" AND TFS.D_E_L_E_T_ = ' ' "
			cQuery += " GROUP BY TFL.TFL_CODIGO, TFG.TFG_ITEM, TFS.TFS_PRODUT, SB1.B1_DESC, TFS.TFS_QUANT, TFS.TFS_MOV, TFG.TFG_RESRET "
			cQuery += " ORDER BY TFL.TFL_CODIGO, TFG.TFG_ITEM, TFS.TFS_PRODUT, TFS.TFS_MOV "

			cQuery := ChangeQuery(cQuery)
			oQuery := FwExecStatement():New(cQuery)

			oQuery:SetUnsafe( 1, RetSqlName("TFS") )
			oQuery:SetUnsafe( 2, RetSqlName("TFG") )
			oQuery:SetString( 3, xFilial("TFG") )
			oQuery:SetUnsafe( 4, RetSqlName("TFL") )
			oQuery:SetString( 5, xFilial("TFL") )
			oQuery:SetString( 6, oMdlTFL:GetValue("TFL_CONTRT") )
			oQuery:SetString( 7, oMdlTFL:GetValue("TFL_CODIGO") )
			oQuery:SetUnsafe( 8, RetSqlName("SB1") )
			oQuery:SetString( 9, xFilial("SB1") )
			oQuery:SetString(10, xFilial("TFS") )

			cTmpTFS := oQuery:OpenAlias()

			aCmpTFS	:=	{}
			cMens02	:= ""
			nSld := 0
			DbSelectArea(cTmpTFS)
			(cTmpTFS)->(DbGoTop())
			While (cTmpTFS)->( ! Eof() )
				aAdd(aCmpTFS,{(cTmpTFS)->TFS_PRODUT,;
								(cTmpTFS)->QtTotal,;
								(cTmpTFS)->TFS_MOV,;
								(cTmpTFS)->TFG_RESRET,;
								(cTmpTFS)->TFG_ITEM,;
								(cTmpTFS)->B1_DESC})
				(cTmpTFS)->(dBSkip())
			Enddo
			(cTmpTFS)->(DbCloseArea())
			oQuery:Destroy()
			FwFreeObj(oQuery)

			//Verificar se existe quantidade (saldo) a retornar
			For nInd := 1 to len(aCmpTFS)
				nRes	:= aCmpTFS[nInd][4]
				nQuant	:= aCmpTFS[nInd][2]
				cTpMov	:= aCmpTFS[nInd][3]

				If cProduto == aCmpTFS[nInd][1] .OR. nInd == 1
					If cTpMov == "1"
						nSld	+= nQuant
					Elseif cTpMov == "2"
						nSld	-= nQuant
					Endif
				Elseif cProduto <> aCmpTFS[nInd][1] .AND. nInd <> 1
					If nSld - nRes > 0
						cMens02	+= If( !Empty(cMens02), CRLF, "" )
						//se existir saldo a retornar, avisar o usuário...
						cMens02	+=	STR0024 + " [" + AllTrim(aCmpTFS[nInd][5]) + "] " +;	//"MI-Item:"
									cTitTFSPrd + " [" + AllTrim(cProduto) + "-" + AllTrim(cDesc) + "] " +;
									cTitTFSQtde + " [" + AllTrim(Transform(nSld,cPicTFSQtde)) + "]"
						lOkTFS	:= .F.
						//zera as quantidades
						nSld	:= 0
						nRes	:= 0
					EndIf
					If cTpMov == "1"
						nSld	+= nQuant
					Elseif cTpMov == "2"
						nSld	-= nQuant
					Endif
				Endif

				If nInd == Len(aCmpTFS)
					If nSld - nRes > 0
						cMens02	+= If( !Empty(cMens02), CRLF, "" )
						//se existir saldo a retornar, avisar o usuário...
						cMens02	+=	STR0024 + " [" + AllTrim(aCmpTFS[nInd][5]) + "] " +;	//"MI-Item:"
									cTitTFSPrd + " [" + AllTrim(aCmpTFS[nInd][1]) + "-" + AllTrim(aCmpTFS[nInd][6]) + "] " +;
									cTitTFSQtde + " [" + AllTrim(Transform(nSld,cPicTFSQtde)) + "]"
						lOkTFS	:= .F.
					EndIf
				EndIf 
		
				cProduto	:= aCmpTFS[nInd][1]
				cDesc		:= aCmpTFS[nInd][6]							
			Next nInd
				
			If	!Empty(cMens02)
				cMens	+= If( !Empty(cMens), CRLF, "" )
				cMens	+= STR0022 + CRLF + CRLF	//"Os materiais de implantação abaixo estão pendentes de retorno:"
				cMens	+= cMens02 + CRLF
			EndIf
		EndIf
	EndIf	
	
	If	!( oMdlTFF:IsEmpty() )
		//verificar os itens do RH
		For nLinTFF := 1 to oMdlTFF:Length()
			oMdlTFF:GoLine(nLinTFF)
			If oMdlTFF:GetValue("OK")
				If lDtEnce
					dDtEnce := oMdlTFF:GetValue("TFF_DTENCE")
				EndIf

				If oMdlTFF:GetValue("TFF_ENCE") != "1"
					
					If !lMsgLocal
						cCod 	:= AllTrim(oMdlTFL:GetValue("TFL_CODIGO"))
						cLocal 	:= AllTrim(oMdlTFL:GetValue("TFL_LOCAL"))
						cDesc 	:= AllTrim(oMdlTFL:GetValue("TFL_DESLOC"))
						cDescri	:= Posicione("ABS",1,xFilial("ABS")+cLocal,"ABS_DESCRI") //ABS_FILIAL+ABS_LOCAL

						cMens		:= at871AddMsg(CRLF, cMens, "LOCAL", cLocal, cDescri)
						cMailArma	:= at871AddMsg("<br>", cMailArma, "LOCAL", cLocal, cDescri)
						cMailMI		:= at871AddMsg("<br>", cMailMI, "LOCAL", cCod, cDescri)
						cMailPosto	:= at871AddMsg("<br>", cMailPosto, "LOCAL", cCod, cDescri)

						lMsgLocal := .T.
					EndIf

					cContrt 		:= oMdlTFF:GetValue("TFF_CONTRT")
					cCodTFF 		:= oMdlTFF:GetValue("TFF_COD")

					//Verificar se existe agenda futura
					cQuery := " SELECT DISTINCT TFF.TFF_CONTRT, ABQ.ABQ_ITEM, TFF.TFF_COD, TFF.TFF_ITEM, TFF.TFF_PRODUT, "
					cQuery +=				  " ABB.ABB_CODTEC, AA1.AA1_NOMTEC, AA1.AA1_FUNFIL, AA1.AA1_CDFUNC, SRJ.RJ_DESC "
					cQuery += " FROM ? TFF "
					cQuery += " INNER JOIN ? ABQ ON ABQ.ABQ_FILIAL = ? "
					cQuery +=				  " AND ABQ.ABQ_FILTFF = TFF.TFF_FILIAL "
					cQuery +=				  " AND ABQ.ABQ_CODTFF = TFF.TFF_COD "
					cQuery +=				  " AND ABQ.ABQ_CONTRT = TFF.TFF_CONTRT "
					cQuery +=				  " AND ABQ.ABQ_ORIGEM = 'CN9' "
					cQuery +=				  " AND ABQ.D_E_L_E_T_ = ' ' "
					cQuery += " INNER JOIN ? ABB ON ABB.ABB_FILIAL = ? "
					cQuery +=				  " AND ABB.D_E_L_E_T_ = ' ' "
					cQuery +=				  " AND ABB.ABB_IDCFAL = ABQ.ABQ_CONTRT || ABQ.ABQ_ITEM || ABQ.ABQ_ORIGEM "
					cQuery +=				  " AND ABB.ABB_ATIVO = '1' "
					cQuery += " INNER JOIN ? TDV ON ABB.ABB_CODIGO = TDV.TDV_CODABB "
					cQuery +=				  " AND TDV.TDV_FILIAL = ABB.ABB_FILIAL "
					cQuery +=				  " AND TDV.D_E_L_E_T_ = ' ' "
					cQuery +=				  " AND TDV.TDV_DTREF > ? "
					cQuery += " INNER JOIN ? AA1 ON AA1.AA1_FILIAL = ? "
					cQuery +=				  " AND AA1.D_E_L_E_T_ = ' ' "
					cQuery +=				  " AND AA1.AA1_CODTEC = ABB.ABB_CODTEC
					cQuery += " INNER JOIN ? SRJ ON SRJ.RJ_FILIAL = ? "
					cQuery +=				  " AND SRJ.D_E_L_E_T_ = ' ' "
					cQuery +=				  " AND SRJ.RJ_FUNCAO = TFF.TFF_FUNCAO "
					cQuery += " WHERE TFF.TFF_FILIAL = ? "
					cQuery +=	" AND TFF.D_E_L_E_T_ = ' ' "
					cQuery +=	" AND TFF.TFF_CONTRT = ? "
					cQuery +=	" AND TFF.TFF_COD = ? "
					cQuery += " ORDER BY TFF.TFF_CONTRT, ABQ.ABQ_ITEM, TFF.TFF_COD, TFF.TFF_ITEM, TFF.TFF_PRODUT"

					cQuery := ChangeQuery(cQuery)
					oQuery := FwExecStatement():New(cQuery)

					oQuery:SetUnsafe(  1, RetSqlName("TFF") )
					oQuery:SetUnsafe(  2, RetSqlName("ABQ") )
					oQuery:SetString(  3, xFilial("ABQ") )
					oQuery:SetUnsafe(  4, RetSqlName("ABB") )
					oQuery:SetString(  5, xFilial("ABB") )
					oQuery:SetUnsafe(  6, RetSqlName("TDV") )
					oQuery:SetDate( 7, dDtEnce )
					oQuery:SetUnsafe(  8, RetSqlName("AA1") )
					oQuery:SetString(  9, xFilial("AA1") )
					oQuery:SetUnsafe( 10, RetSqlName("SRJ") )
					oQuery:SetString( 11, xFilial("SRJ") )
					oQuery:SetString( 12, xFilial("TFF") )
					oQuery:SetString( 13, cContrt )
					oQuery:SetString( 14, cCodTFF )

					cTmpTFF := oQuery:OpenAlias()

					DbSelectArea(cTmpTFF)
					(cTmpTFF)->(DbGoTop())
					If	(cTmpTFF)->( ! Eof() )
						lOkTFF	:= .F.
						cMens		:= at871AddMsg(CRLF, cMens, "TITULO_POSTO", AllTrim((cTmpTFF)->TFF_COD), DTOC(dDtEnce))
						cMailPosto	:= at871AddMsg("<br>", cMailPosto, "TITULO_POSTO", AllTrim((cTmpTFF)->TFF_COD), DTOC(dDtEnce))
					EndIf
					While (cTmpTFF)->( ! EOF() )
						cAdmissa := ""
						If !Empty((cTmpTFF)->AA1_CDFUNC)
							cAdmissa := Dtoc(Posicione("SRA",1,(cTmpTFF)->AA1_FUNFIL+(cTmpTFF)->AA1_CDFUNC,"RA_ADMISSA"))
						EndIf
						cMens		:= at871AddMsg(CRLF, cMens, "POSTO",;
													AllTrim(Posicione("SB5",1,xFilial("SB5")+AllTrim((cTmpTFF)->TFF_PRODUT),"B5_CEME")),;
													AllTrim((cTmpTFF)->ABB_CODTEC),;
													AllTrim((cTmpTFF)->AA1_NOMTEC),;
													cAdmissa)
						cMailPosto	:= at871AddMsg("<br>", cMailPosto, "POSTO",;
													AllTrim(Posicione("SB5",1,xFilial("SB5")+AllTrim((cTmpTFF)->TFF_PRODUT),"B5_CEME")),;
													AllTrim((cTmpTFF)->ABB_CODTEC),;
													AllTrim((cTmpTFF)->AA1_NOMTEC),;
													cAdmissa)
						(cTmpTFF)->(dBSkip())
					Enddo
					(cTmpTFF)->(DbCloseArea())
					oQuery:Destroy()
					FwFreeObj(oQuery)

					cCodTFF := ""
					cContrt := "" 

					If !( oMdlTFF:IsEmpty() ) .AND. !lOrcPrc
						//Verificar os materiais de implantação não retornados MV_ORCPRC .F.(Materiais filhos do Posto (RH))
						cQuery := "SELECT TFF.TFF_ITEM, TFF.TFF_COD, TFS.TFS_PRODUT, SB1.B1_DESC, SUM(TFS.TFS_QUANT) AS QtTotal, TFS.TFS_MOV, TFG.TFG_RESRET "
						cQuery += " FROM ? TFS "
						cQuery += " INNER JOIN ? TFG ON TFG.TFG_FILIAL = ? "
						cQuery +=				  " AND TFG.D_E_L_E_T_ = ' ' "
						cQuery +=				  " AND TFG.TFG_COD = TFS.TFS_CODTFG "
						cQuery += " INNER JOIN ? TFF ON TFF.TFF_FILIAL = ? "
						cQuery +=				  " AND TFF.D_E_L_E_T_ = ' ' "
						cQuery +=				  " AND TFF.TFF_COD = TFG.TFG_CODPAI "
						cQuery +=				  " AND TFF.TFF_CONTRT = ? "
						cQuery +=				  " AND TFF.TFF_COD = ? "
						cQuery += " INNER JOIN ? SB1 ON SB1.B1_FILIAL = ? "
						cQuery +=				  " AND SB1.D_E_L_E_T_ = ' ' "
						cQuery +=				  " AND SB1.B1_COD = TFS.TFS_PRODUT "
						cQuery += " WHERE TFS.TFS_FILIAL = ? "
						cQuery +=	" AND TFS.D_E_L_E_T_ = ' ' "
						cQuery += " GROUP BY TFF.TFF_COD, TFF.TFF_ITEM, TFS.TFS_PRODUT, SB1.B1_DESC, TFS.TFS_QUANT, TFS.TFS_MOV, TFG.TFG_RESRET "
						cQuery += " ORDER BY TFF.TFF_COD, TFF.TFF_ITEM, TFS.TFS_PRODUT, TFS.TFS_MOV "

						cQuery := ChangeQuery(cQuery)
						oQuery := FwExecStatement():New(cQuery)

						oQuery:SetUnsafe( 1, RetSqlName("TFS") )
						oQuery:SetUnsafe( 2, RetSqlName("TFG") )
						oQuery:SetString( 3, xFilial("TFG") )
						oQuery:SetUnsafe( 4, RetSqlName("TFF") )
						oQuery:SetString( 5, xFilial("TFF") )
						oQuery:SetString( 6, oMdlTFF:GetValue("TFF_CONTRT") )
						oQuery:SetString( 7, oMdlTFF:GetValue("TFF_COD") )
						oQuery:SetUnsafe( 8, RetSqlName("SB1") )
						oQuery:SetString( 9, xFilial("SB1") )
						oQuery:SetString(10, xFilial("TFS") )

						cTmpTFS := oQuery:OpenAlias()

						aCmpTFS	:=	{}
						cMens02	:= ""
						nSld		:= 0
						DbSelectArea(cTmpTFS)
						(cTmpTFS)->(DbGoTop())
						While (cTmpTFS)->( ! Eof() )
							aAdd(aCmpTFS,{(cTmpTFS)->TFS_PRODUT,;
											(cTmpTFS)->QtTotal,;
											(cTmpTFS)->TFS_MOV,;
											(cTmpTFS)->TFG_RESRET,;
											(cTmpTFS)->TFF_ITEM,;
											(cTmpTFS)->B1_DESC,;
											(cTmpTFS)->TFF_COD})
							(cTmpTFS)->(dBSkip())
						Enddo
						(cTmpTFS)->(DbCloseArea())
						oQuery:Destroy()
						FwFreeObj(oQuery)

						//Verificar se existe quantidade (saldo) a retornar
						For nInd := 1 to len(aCmpTFS)
							nRes	:= aCmpTFS[nInd][4]
							nQuant	:= aCmpTFS[nInd][2]
							cTpMov	:= aCmpTFS[nInd][3]

							If cProduto == aCmpTFS[nInd][1] .OR. nInd == 1
								If cTpMov == "1"
									nSld	+= nQuant
								Elseif cTpMov == "2"
									nSld	-= nQuant
								Endif
							Elseif cProduto <> aCmpTFS[nInd][1] .AND. nInd <> 1
								If nSld - nRes > 0
									cMens02	+= If( !Empty(cMens02), CRLF, "" )
									//se existir saldo a retornar, avisar o usuário...
									cMens02	+=	STR0024 + " [" + AllTrim(aCmpTFS[nInd][5]) + "] " +;	//"MI-Item:"
												cTitTFSPrd + " [" + AllTrim(cProduto) + "-" + AllTrim(cDesc) + "] " +;
												cTitTFSQtde + " [" + AllTrim(Transform(nSld,cPicTFSQtde)) + "]"
									lOkTFS	:= .F.
									//zera as quantidades
									nSld	:= 0
									nRes	:= 0
								EndIf
								If cTpMov == "1"
									nSld	+= nQuant
								Elseif cTpMov == "2"
									nSld	-= nQuant
								Endif
							Endif

							If nInd == Len(aCmpTFS)
								If nSld - nRes > 0
									cMens02	+= If( !Empty(cMens02), CRLF, "" )
									//se existir saldo a retornar, avisar o usuário...
									cMens02	+=	STR0024 + " [" + AllTrim(aCmpTFS[nInd][5]) + "] " +;	//"MI-Item:"
												cTitTFSPrd + " [" + AllTrim(aCmpTFS[nInd][1]) + "-" + AllTrim(aCmpTFS[nInd][6]) + "] " +;
												cTitTFSQtde + " [" + AllTrim(Transform(nSld,cPicTFSQtde)) + "]"
									lOkTFS	:= .F.
								EndIf
							EndIf 
					
							cProduto	:= aCmpTFS[nInd][1]
							cDesc		:= aCmpTFS[nInd][6]	
							cPosto		:= AllTrim(aCmpTFS[nInd][7])						
						Next nInd
							
						If	!Empty(cMens02)
							cMens   := at871AddMsg(CRLF, cMens, "TITULO_MI", cPosto, DtoC(dDtence))
							cMailMI := at871AddMsg("<br>", cMailMI, "TITULO_MI", cPosto, DtoC(dDtence))
							cMens   := at871AddMsg(CRLF, cMens, "MI", cMens02)
							cMailMI := at871AddMsg("<br>", cMailMI, "MI", cMens02)
						EndIf

						//Verificar armamentos não retornados - MV_ORCPRC .F.(Materiais filhos do Posto (RH))
						If lGsOrcArma
							cQuery := " SELECT TXQ.TXQ_CODIGO, TXQ.TXQ_CODPRD, TXQ.TXQ_QTDAPO "
							cQuery += " FROM ? TXQ "
							cQuery += " WHERE TXQ.TXQ_FILIAL = ? "
							cQuery += " AND TXQ.D_E_L_E_T_ = ' ' "
							cQuery += " AND TXQ.TXQ_CONTRT = ? "
							cQuery += " AND TXQ.TXQ_CODTFF = ? "
							cQuery += " AND TXQ.TXQ_QTDAPO > 0 "
							cQuery += " AND TXQ.TXQ_ITEARM <> '3' "

							cQuery := ChangeQuery(cQuery)
							oQuery := FwExecStatement():New(cQuery)

							oQuery:SetUnsafe( 1, RetSqlName("TXQ") )
							oQuery:SetString( 2, xFilial("TXQ") )
							oQuery:SetString( 3, oMdlTFF:GetValue("TFF_CONTRT") )
							oQuery:SetString( 4, oMdlTFF:GetValue("TFF_COD") )

							cTmpTXQ := oQuery:OpenAlias()

							DbSelectArea(cTmpTXQ)
							(cTmpTXQ)->(DbGoTop())
				
							While (cTmpTXQ)->(!EOF())
								aAdd(aCmpTXQ,{(cTmpTXQ)->TXQ_CODIGO,;
												(cTmpTXQ)->TXQ_CODPRD,;
												(cTmpTXQ)->TXQ_QTDAPO})
								(cTmpTXQ)->(dBSkip())
							Enddo
				
							(cTmpTXQ)->(DbCloseArea())
							oQuery:Destroy()
							FwFreeObj(oQuery)

							If Len(aCmpTXQ) > 0
								cMens03 := ""
								For nInd := 1 To Len(aCmpTXQ)
									If !Empty(cMens03)
										cMens03 += CRLF
									EndIf
									//Se existir saldo a retornar, avisar o usuário...
									cMens03	+=	STR0049	+ " [" + AllTrim(aCmpTXQ[nInd][2]) + "] " +;		//"Armamento"
												STR0050	+ " [" + AllTrim(aCmpTXQ[nInd][1]) + "] "  +;		//"Cod. Prod:"	
												STR0051 + " [" + AllTrim(cValToChar(aCmpTXQ[nInd][3])) + "]"//"Quantidade:" 
									lOkTXQ	:= .F.
								Next nInd
							EndIf
							If !Empty(cMens03)
								cMens  := at871AddMsg(CRLF, cMens, "TITULO_ARMA", oMdlTFF:GetValue("TFF_COD"), DtoC(dDtence))
								cMailArma := at871AddMsg("<br>", cMailArma, "TITULO_ARMA", oMdlTFF:GetValue("TFF_COD"), DtoC(dDtence))
								cMens    := at871AddMsg(CRLF, cMens, "ARMA", cMens03)
								cMailArma := at871AddMsg("<br>", cMailArma, "ARMA", cMens03)
							EndIf
						EndIf
					EndIf
				Endif
			EndIf	
		Next nLinTFF
	EndIf

	If	lGSLE .And. !( oMdlTFI:IsEmpty() )
		//verificar os itens de locação
		For nLinTFI := 1 to oMdlTFI:Length()
			oMdlTFI:GoLine(nLinTFI)
			If oMdlTFI:GetValue("OK")
				If !lMsgLocal
					cMens	+= If( !Empty(cMens), CRLF + CRLF + CRLF, "" )
					cMens	+=	STR0004 + AllTrim(oMdlTFL:GetValue("TFL_CODIGO")) + " "+;
								STR0005 + AllTrim(oMdlTFL:GetValue("TFL_LOCAL")) + "-"+;
								AllTrim(oMdlTFL:GetValue("TFL_DESLOC")) + CRLF // Código: " "- Posto: "
					lMsgLocal := .T.
				EndIf
				//verificar equipamentos não retornados
				cQuery := "SELECT TEW.TEW_CODEQU, TEW.TEW_PRODUT, TEW.TEW_BAATD, SB1.B1_DESC, TEW.TEW_DTRFIM, TFI.TFI_COD, TFI.TFI_ITEM "
				cQuery += " FROM ? TEW "
				cQuery += " INNER JOIN ? TFI ON TFI.TFI_FILIAL = ? "
				cQuery +=				  " AND TFI.D_E_L_E_T_ = ' ' "
				cQuery +=				  " AND TFI.TFI_COD = TEW.TEW_CODEQU
				cQuery += " INNER JOIN ? SB1 on SB1.B1_FILIAL = ? "
				cQuery +=				  " AND SB1.D_E_L_E_T_ = ' ' "
				cQuery +=				  " AND SB1.B1_COD = TEW.TEW_PRODUT
				cQuery += " WHERE TEW.TEW_FILIAL = ? "
				cQuery +=	" AND TEW.D_E_L_E_T_ = ' ' "
				cQuery +=	" AND TEW.TEW_CODEQU = ? "
				cQuery +=	" AND TEW.TEW_DTSEPA <> ' ' "
				cQuery +=	" AND TEW.TEW_DTRFIM = ' ' "

				cQuery := ChangeQuery(cQuery)
				oQuery := FwExecStatement():New(cQuery)

				oQuery:SetUnsafe( 1, RetSqlName("TEW") )
				oQuery:SetUnsafe( 2, RetSqlName("TFI") )
				oQuery:SetString( 3, xFilial("TFI") )
				oQuery:SetUnsafe( 4, RetSqlName("SB1") )
				oQuery:SetString( 5, xFilial("SB1") )
				oQuery:SetString( 6, xFilial("TEW") )
				oQuery:SetString( 7, oMdlTFI:GetValue("TFI_COD") )

				cTmpTEW := oQuery:OpenAlias()

				DbSelectArea(cTmpTEW)
				(cTmpTEW)->( DbGoTop() )
				If	(cTmpTEW)->( ! Eof() )
					lOkTEW	:= .F.
					cMens	+= If( !Empty(cMens), CRLF, "" )
					cMens	+= STR0023 + CRLF	//"Os equipamentos abaixo estão pendentes de retorno ou encontram-se separados:"
				EndIf
				While (cTmpTEW)->( ! EOF() )
					cMens	+= If( !Empty(cMens), CRLF, "" )
					cMens	+=	STR0014 + " [" + AllTrim((cTmpTEW)->TFI_ITEM) + "] " +;												//"LE - Item: "
								STR0015 + " [" + AllTrim((cTmpTEW)->TFI_COD) + "] " +;												//" - Cód.Locação: "
								STR0016 + " [" + AllTrim((cTmpTEW)->TEW_PRODUT) + "-" + AllTrim((cTmpTEW)->B1_DESC) + "] "	+;	//" prod "
								STR0025 + " [" + AllTrim((cTmpTEW)->TEW_BAATD) + "] "												//"Núm.Série:"
					(cTmpTEW)->(dBSkip())
				Enddo
				(cTmpTEW)->(DbCloseArea())
				oQuery:Destroy()
				FwFreeObj(oQuery)
			Endif
		Next nLinTFI
	EndIf
	lMsgLocal := .F.
Next nLinTFL

cMailPosto := at871AddMsg("<br>", cMailPosto, "FIMPOSTO", DTOC(dDtEnce))
cMailMI := at871AddMsg("<br>", cMailMI, "FIMMI", DTOC(dDtEnce))
cMailArma := at871AddMsg("<br>", cMailArma, "FIMARMA", DTOC(dDtEnce))

If !( lOkTFF .And. lOkTFS .And. lOkTEW .And. lOkTXQ )

	lRet := MsgYesNo( STR0065 +CRLF+CRLF+ STR0066 +CRLF+CRLF+ STR0067, STR0068 ) //"Existem pendencias para o encerramento do Posto ou Local." ## "Não - CANCELA o encerramento do posto e mostra Log." ## "Sim - CONTINUA o encerramento. - As pendências serão enviadas por e-mail de acordo com a configuração do Grupo de Comunicação."

	If !Empty(cGrpCom) .And. lRet
		If !lOkTFF //Envio de Email Efetivos "EE"
			FwMsgRun(Nil,{|| aRetMail := At774Mail("TFJ",cGrpCom,"EE",cMailPosto)}, Nil, STR0069)
			Aadd(aLogMail, aRetMail)
		EndIf
		If !lOkTFS //Envio de Email Materiais "EM"
			FwMsgRun(Nil,{|| aRetMail := At774Mail("TFJ",cGrpCom,"EM",cMailMI)}, Nil, STR0069)
			Aadd(aLogMail, aRetMail)
		EndIf
		If !lOkTXQ //Envio de Email Armamentos "EA"
			FwMsgRun(Nil,{|| aRetMail := At774Mail("TFJ",cGrpCom,"EA",cMailArma)}, Nil, STR0069)
			Aadd(aLogMail, aRetMail)
		EndIf

		For nX := 1 To Len(aLogMail)
			For nY := 1 To Len(aLogMail[nX])
				cMail := aLogMail[nX,nY,1]
				cSend := IIF(aLogMail[nX,nY,2], STR0071, STR0072) //"Sucesso", "Falha"
				cLog := aLogMail[nX,nY,3]
				cAssunto := aLogMail[nX,nY,4]
				cMsg += STR0073 + cMail + CRLF //"Destinatário: "
				cMsg += STR0074 + cAssunto + CRLF //"Assunto: "
				cMsg += STR0075 + cSend + CRLF //"Retorno do envio: "
				cMsg += STR0076 + cLog + CRLF + CRLF +CRLF //"Log: "
			Next nY
		Next nX

		AtShowLog(cMsg, STR0077, .T., .T., .F.) //"Envio de Email"
	EndIf

	If lRet
		If MsgYesNo(STR0070, STR0068) //"Deseja salvar o log de pendencias?" ## "Pendencias"
			cFile := tFileDialog("Arquivos Texto (*.TXT) |*.txt|",,,,.T.)
			If !Empty(cFile)
				SplitPath(cFile, @cDrive, @cDir, @cNome, @cExt)
				TxLogFile(cNome, cMens, .F., .F., .F., cDrive+cDir, cExt)
			EndIf
		EndIf
	EndIf

EndIf

If lRet
	For nLinTFL := 1 to oMdlTFL:Length() //encerrar os locais
		oMdlTFL:GoLine(nLinTFL)

		// Prepara o encerramento dos itens de RH do local
		If	!( oMdlTFF:IsEmpty() )
			For nLinTFF := 1 to oMdlTFF:Length()
				oMdlTFF:GoLine(nLinTFF)
				oMdlTFF:SetValue("TFF_ENCE",If(oMdlTFF:GetValue("OK"),"1","2"))
			Next nLinTFF
		EndIf

		// Prepara o encerramento dos itens de locação do local
		If	lGSLE .And. !( oMdlTFI:IsEmpty() )
			For nLinTFI := 1 to oMdlTFI:Length()
				oMdlTFI:GoLine(nLinTFI)
				oMdlTFI:SetValue("TFI_ENCE",If(oMdlTFI:GetValue("OK"),"1","2"))
			Next nLinTFI
		EndIf

		// Prepara o encerramento do local
		oMdlTFL:SetValue("TFL_ENCE",If(oMdlTFL:GetValue("OK"),"1","2"))
		If	lAllMrk
			lAllMrk := oMdlTFL:GetValue("OK")
		EndIf
	Next nLinTFL

	//verificar se pode encerrar o contrato caso todos os postos estejam encerrados
	If	lAllMrk
		// Atualiza o status do Orçamento de Serviços como ENCERRADO
		oMdlTFJ:SetValue("TFJ_STATUS",DEF_TFJ_ENCERRADO)
	EndIf
Else
	AtShowLog(cMens, STR0017, .T., .T., .F.)  // "Inconsistências"
	Help( , , "At871RecPen", , STR0078, 1, 0)	//"Encerramento de Posto cancelado pelo usuário."
Endif

FWRestRows( aSaveLines )
(cOldAlias)->(RestArea(aOldAlias))
dBSelectArea(cOldAlias)
Return lRet


//------------------------------------------------------------------------------
/*/{Protheus.doc} InitDados
Inicializa as informações 
@sample 	InitDados()
@param  	oModel, Objeto, objeto geral do model que será alterado
@return	Nil 
@author 	Serviços
@since		19/06/2015
@version	P12
/*/
//------------------------------------------------------------------------------
Static Function InitDados(oModel)

Local oMdlTFL 		:= oModel:GetModel("TFLDETAIL") 
Local oMdlTFF 		:= oModel:GetModel("TFFDETAIL")
Local oMdlTFI 		:= oModel:GetModel("TFIDETAIL")
Local aSaveLines	:= FWSaveRows()
Local dDtEnceTFL 	:= SToD("")
Local dDtEnceTFF	:= SToD("")
Local lDtEnce		:= FindFunction("TecEncDtFt") .AND. TecEncDtFt()
Local lEnceTFL		:= .F.
Local nI			:= 0
Local nZ			:= 0

If IsBlind()
	//inicia TFL
	For nI := 1 to oMdlTFL:Length()
		oMdlTFL:GoLine(nI)
		oMdlTFL:SetValue("OK",.T.)
		
            
		//inicia a TFF
		If	!( oMdlTFF:IsEmpty() )
			For nZ := 1 to oMdlTFF:Length()
				oMdlTFF:GoLine(nZ)
				oMdlTFF:SetValue("OK",.T.)	
           
			Next nZ
		EndIf
	
		//inicia a TFI
		If	!( oMdlTFI:IsEmpty() )
			For nZ := 1 to oMdlTFI:Length()
				oMdlTFI:GoLine(nZ)
				oMdlTFI:SetValue("OK",.T.)	
		
			Next nZ
		EndIf
		
	Next nI
Else
	//inicia TFL
	For nI := 1 to oMdlTFL:Length()
		oMdlTFL:GoLine(nI)
		lEnceTFL := .F.
		If oMdlTFL:GetValue("TFL_ENCE") == "1"
			If lDtEnce
				dDtEnceTFL := oMdlTFL:GetValue("TFL_DTENCE")
				If Empty(dDtEnceTFL)
					lEnceTFL := .T.
				EndIf
			EndIf
			oMdlTFL:LoadValue("OK",.T.)
			At740SetLeg('TFL',oMdlTFL)
		Endif
		//inicia a TFF
		If	!( oMdlTFF:IsEmpty() )
			For nZ := 1 to oMdlTFF:Length()
				oMdlTFF:GoLine(nZ)
				If oMdlTFF:GetValue("TFF_ENCE") == "1"
					oMdlTFF:LoadValue("OK",.T.)
				 	At740SetLeg('TFF',oMdlTFF)

					If lDtEnce 
						dDtEnceTFF := oMdlTFF:GetValue("TFF_DTENCE")
						If Empty(dDtEnceTFF)
							dDtEnceTFF := A871DtEncF( oMdlTFF )
							If dDtEnceTFF > dDtEnceTFL
								dDtEnceTFL := dDtEnceTFF
							EndIf
							If Empty(dDtEnceTFF)
								oMdlTFF:SetValue("TFF_DTENCE", oMdlTFF:GetValue("TFF_PERFIM"))
							Else
								oMdlTFF:SetValue("TFF_DTENCE", dDtEnceTFF)
							EndIf
						EndIf
					EndIf
				Endif	
			Next nZ
		EndIf
		//inicia a TFI
		If	!( oMdlTFI:IsEmpty() )
			For nZ := 1 to oMdlTFI:Length()
				oMdlTFI:GoLine(nZ)
				If oMdlTFI:GetValue("TFI_ENCE") == "1"
					oMdlTFI:LoadValue("OK",.T.)
					At740SetLeg('TFI',oMdlTFI)
				Endif	
			Next nZ
		EndIf
		If lDtEnce .AND. lEnceTFL
			oMdlTFL:SetValue("TFL_DTENCE", dDtEnceTFL)
		EndIf
	Next nI
EndIf

FWRestRows( aSaveLines )
Return


//------------------------------------------------------------------------------
/*/{Protheus.doc} At871Commit
Atualiza as informações na base de dados 
@sample 	At871Commit(oMdl)
@param  	oMdl, Objeto, objeto geral do model que será alterado
@return	Nil 
@author 	Alexandre da Costa
@since		30/03/2016
@version	P12
/*/
//------------------------------------------------------------------------------
Static Function At871Commit(oMdl)
Local	lRet		:=	.T.
Local	cContrato	:=	oMdl:GetModel("TFJMASTER"):GetValue("TFJ_CONTRT")
Local	cRevisao	:=	oMdl:GetModel("TFJMASTER"):GetValue("TFJ_CONREV")
If	oMdl:GetModel("TFJMASTER"):GetValue("TFJ_STATUS") == DEF_TFJ_ENCERRADO
	lRet := At870NwSit(cContrato, cRevisao, DEF_TFJ_ENCERRADO, .F.)
EndIf
lRet	:=	( lRet .And. FwFormCommit(oMdl) )
Return	lRet


//------------------------------------------------------------------------------
/*/{Protheus.doc} At871PVTFL
Pré-validação do grid dos locais de atendimento 
@sample 	At871PVTFL(oModelGrid,cAction, nLine, cField, xValue)
@param  	oMdlTFL, Objeto, objeto geral do model que será alterado
@param  	cAction, Caracter, ação que está sendo executada 
@param  	nLine, Numérido, número da linha ativa do modelo do grid
@param  	cField, Caracter, nome do campo que está em edição
@param  	xValue, conterá o conteúdo que foi informado no campo no momento da execução desta função
@return	Nil
@author 	Alexandre da Costa
@since		13/05/2016
@version	P12
/*/
//------------------------------------------------------------------------------
Static Function At871PVTFL(oMdlTFL, cAction, nLine, cField, xValue, xOldValue)
Local oModel		:= FwModelActive()
Local oView			:= FwViewActive()
Local oMdlTFF		:= oModel:GetModel("TFFDETAIL")
Local oMdlTFI		:= oModel:GetModel("TFIDETAIL")
Local aSaveLines	:= FWSaveRows()
Local aArea			:= {}
Local aDtBck		:= {}
Local nI			:= 0
Local lRet			:= .T.
Local lDtBck		:= .F.
Local lFirst		:= .T.
Local lAplica		:= .F.
Local lFirstHelp	:= .T.	

If cAction == "SETVALUE"

	If	cField == "OK"
		// Se o usuário marcou ou desmarcou o  LOCAL DE ATENDIMENTO, então todos os seus itens de RH e
		// LOCAÇÃO serão marcados ou desmarcados da mesma maneira.   A validação final que será a res- 
		// ponsável por indicar se tal encerramento do posto desse local de atendimento será efetivado  
		// ou não, ocorrerá na validação final do modelo, antes do COMMIT.
		//
		// Marca ou desmarca todos os itens de RH
		If	!( oMdlTFF:IsEmpty() )
			nLine := oMdlTFF:GetLine()
			For nI := 1 to oMdlTFF:Length()
				oMdlTFF:GoLine(nI)
				oMdlTFF:LoadValue("OK", xValue)
			Next nI
			oMdlTFF:GoLine( nLine )
		EndIf
		//Marca ou desmarca todos os itens de locação
		If	!( oMdlTFI:IsEmpty() )
			For nI := 1 to oMdlTFI:Length()
				oMdlTFI:GoLine(nI)
				oMdlTFI:LoadValue("OK", xValue)
			Next nI
		EndIf
	ElseIf cField == "TFL_DTENCE"
		If !Empty(xValue)
			aArea := GetArea()
			DbSelectArea("TFL")
			TFL->(dBSetOrder(1)) //TFL_FILIAL+TFL_CODIGO                                                                                                                                           
			If TFL->(dBSeek(xFilial("TFL")+oMdlTFL:GetValue("TFL_CODIGO")))
				If TFL->TFL_DTINI > xValue
					Help(,,"At871PVTFL",, STR0034+ DToC(xValue) + STR0039 + DToC(TFL->TFL_DTINI) + ").", 1, 0) //"Não é possivel selecionar uma data(" ## ") menor que a data de inicio do Local de Atendimento("
					lRet := .F.
				ElseIf TFL->TFL_DTFIM < xValue
					Help(,,"At871PVTFL",, STR0034+ DToC(xValue) + STR0040 + DToC(TFL->TFL_DTFIM) + ").", 1, 0) //"Não é possivel selecionar uma data(" ## ") maior que a data fim do Local de Atendimento("
					lRet := .F.
				EndIf
				If lRet .AND. !( oMdlTFF:IsEmpty() )
					For nI := 1 to oMdlTFF:Length()
						oMdlTFF:GoLine(nI)
						If oMdlTFF:GetValue("TFF_DTENCE") > xValue
							If lFirst
								lFirst := .F.
								If !IsBlind()
									If IsInCallStack("InitDados")
										lAplica := .T.
									Else
										lAplica := MsgYesNo(STR0042 + DToC(oMdlTFF:GetValue("TFF_DTENCE")) + STR0043 + DToC(xValue) + STR0044, STR0045) // "Este local de atendimento possui items de RH com data de encerramento(" ## ") superior a data nova selecionada no Local de Atendimento(" ##"). Deseja replicar a nova data para esses itens?", "Inconssistencias de Datas"
									EndIf
								EndIf
							EndIf
							If lAplica
								oMdlTFF:LoadValue("TFF_DTENCE", xValue)
							Else
								Help(,,"At871PVTFL",, STR0046, 1, 0) //"Não é possivel selecionar essa data pois esse local de atendimento possui item de RH com data de encerramento superior."
								lRet := .F.
								lDtBck := .T.
								Exit
							EndIf
						Else
							If Empty(oMdlTFF:GetValue("TFF_DTENCE")) .OR. oMdlTFF:GetValue("TFF_DTENCE") == oMdlTFL:GetValue("TFL_DTENCE")
								If lFirstHelp .AND. !IsInCallStack("InitDados")
									lFirstHelp := .F.
									MsgInfo(STR0047+ DToC(xValue) + STR0048 + DToC(oMdlTFF:GetValue("TFF_DTENCE")) + ").") //"A data selecionada(" ## ") sera replicada apenas para postos que não possuem nenhuma data ou que seja igual a data atual do Local de Atendimento("
								EndIf
								AADD( aDtBck, {oMdlTFF:GetValue("TFF_DTENCE"), nI})
								oMdlTFF:LoadValue("TFF_DTENCE", xValue)
							EndIf
						EndIf
					Next nI
					If lDtBck
						For nI := 1 to Len(aDtBck)
							oMdlTFF:GoLine(aDtBck[nI][2])
							oMdlTFF:LoadValue("TFF_DTENCE", aDtBck[nI][1])
						Next nI
					EndIf
				EndIf
			EndIf
			RestArea(aArea)
		EndIf
	EndIf
EndIf

FWRestRows( aSaveLines )
If !IsBlind() .And. oView:IsActive()
	oView:Refresh()
EndIf
Return lRet


//------------------------------------------------------------------------------
/*/{Protheus.doc} At871PVTFF
Pré-validação do grid dos itens de RH dos locais de atendimento 
@sample 	At871PVTFF(oModelGrid,cAction, nLine, cField, xValue)
@param  	oMdlTFF, Objeto, objeto geral do model que será alterado
@param  	cAction, Caracter, ação que está sendo executada 
@param  	nLine, Numérido, número da linha ativa do modelo do grid
@param  	cField, Caracter, nome do campo que está em edição
@param  	xValue, conterá o conteúdo que foi informado no campo no momento da execução desta função
@return	Nil
@author 	Alexandre da Costa
@since		13/05/2016
@version	P12
/*/
//------------------------------------------------------------------------------
Static Function At871PVTFF(oMdlTFF, cAction, nLine, cField, xValue)
Local oModel		:= FwModelActive()
Local oView			:= FwViewActive()
Local oMdlTFL		:= oModel:GetModel("TFLDETAIL")
Local oMdlTFI		:= oModel:GetModel("TFIDETAIL")
Local aSaveLines	:= FWSaveRows()
Local aArea			:= {}
Local dDtEnce		:= CTod("")		
Local nAtLineTFF	:= oMdlTFF:GetLine()
Local nI			:= 0
Local lEnceDT		:= FindFunction("TecEncDtFt") .AND. TecEncDtFt()
Local lAllMrk		:= .T.
Local lRet			:= .T.

If cAction == "SETVALUE" 

	If	cField == "OK"

		// Verifica se todos os itens de RH e de locação de equipamentos estão marcados ou se o registro que está sendo processado nesse
		// momento é o último que está sendo selecionado (marcado) pelo usuário. Caso afirmativo, então o registro-pai (da tabela TFL)
		// será automaticamente marcado. Caso contrário, o registro-pai será desmarcado.
		lAllMrk	:= xValue
		If	lAllMrk
			If	!( oMdlTFF:IsEmpty() )
				For nI := 1 to oMdlTFF:Length()
					oMdlTFF:GoLine(nI)
					If	nI <> nAtLineTFF .AND. !( lAllMrk := oMdlTFF:GetValue("OK") )
						EXIT
					EndIf
				Next nI
			EndIf
			If	lAllMrk .AND. !( oMdlTFI:IsEmpty() )
				For nI := 1 to oMdlTFI:Length()
					oMdlTFI:GoLine(nI)
					If	!( lAllMrk := oMdlTFI:GetValue("OK") )
						EXIT
					EndIf
				Next nI
			EndIf
		EndIf
		oMdlTFL:LoadValue("OK", lAllMrk)
		If (lEnceDT .AND. !GSGetIns("LE"))
			If lAllMrk
				For nI := 1 to oMdlTFF:Length()
					oMdlTFF:GoLine(nI)
					If Empty(oMdlTFF:GetValue("TFF_DTENCE"))
						dDtEnce := dDataBase
					Else
						If oMdlTFF:GetValue("TFF_DTENCE") > dDtEnce
							dDtEnce := oMdlTFF:GetValue("TFF_DTENCE")
						EndIf
					EndIf
				Next nI
				If Empty(dDtEnce)
					dDtEnce := dDataBase
				EndIf
				At871DtEnc("TFL", , dDtEnce)
			Else
				At871DtEnc("TFL")
			Endif
		EndIf
	ElseIf cField == "TFF_DTENCE"
		If !Empty(xValue)
			aArea := GetArea()
			oMdlTFF:GoLine(nAtLineTFF)
			DbSelectArea("TFF")
			TFF->(dBSetOrder(1)) // TFF_FILIAL+TFF_COD                                                                                                                                              
			If TFF->(dBSeek(xFilial("TFF")+oMdlTFF:GetValue("TFF_COD")))
				If !Empty(oMdlTFL:GetValue("TFL_DTENCE")) .AND. oMdlTFL:GetValue("TFL_DTENCE") < xValue
					Help(,,"At871PVTFF",, STR0034+ DToC(xValue) +STR0035 + DToC(oMdlTFL:GetValue("TFL_DTENCE")) + ").", 1, 0) //"Não é possivel selecionar uma data(" ## ") maior que a data de encerramento do Local de Atendimento("
					lRet := .F.
				ElseIf TFF->TFF_PERINI > xValue
					Help(,,"At871PVTFF",, STR0034+ DToC(xValue) +STR0036 + DToC(TFF->TFF_PERINI) + ").", 1, 0) //"Não é possivel selecionar uma data(" ## ") menor que a data de inicio do item de RH("
					lRet := .F.
				ElseIf TFF->TFF_PERFIM < xValue
					Help(,,"At871PVTFF",, STR0034+ DToC(xValue) +STR0037 + DToC(TFF->TFF_PERFIM) + ").", 1, 0) //"Não é possivel selecionar uma data(" ## ") maior que a data fim do item de RH("
					lRet := .F.
				EndIf
			EndIf
			RestArea(aArea)
		EndIf
	EndIf

EndIf

FWRestRows( aSaveLines )
If !IsBlind() .And. oView:IsActive()
	oView:Refresh()
EndIf
Return	lRet


//------------------------------------------------------------------------------
/*/{Protheus.doc} At871PVTFI
Pré-validação do grid dos itens de locação dos locais de atendimento 
@sample 	At871PVTFI(oModelGrid,cAction, nLine, cField, xValue)
@param  	oMdlTFI, Objeto, objeto geral do model que será alterado
@param  	cAction, Caracter, ação que está sendo executada 
@param  	nLine, Numérido, número da linha ativa do modelo do grid
@param  	cField, Caracter, nome do campo que está em edição
@param  	xValue, conterá o conteúdo que foi informado no campo no momento da execução desta função
@return	Nil
@author 	Alexandre da Costa
@since		13/05/2016
@version	P12
/*/
//------------------------------------------------------------------------------
Static Function At871PVTFI(oMdlTFI, cAction, nLine, cField, xValue)
Local oModel		:= FwModelActive()
Local oView		:= FwViewActive()
Local oMdlTFL		:= oModel:GetModel("TFLDETAIL")
Local oMdlTFF		:= oModel:GetModel("TFFDETAIL")
Local aSaveLines	:= FWSaveRows()
Local nAtLineTFI	:= oMdlTFI:GetLine()
Local nI			:= 0
Local lAllMrk		:= .T.
Local lRet			:= .T.

If cAction == "SETVALUE" 

	If	cField == "OK"

		// Verifica se todos os itens de RH e de locação de equipamentos estão marcados ou se o registro que está sendo processado nesse
		// momento é o último que está sendo selecionado (marcado) pelo usuário. Caso afirmativo, então o registro-pai (da tabela TFL)
		// será automaticamente marcado. Caso contrário, o registro-pai será desmarcado.
		lAllMrk	:= xValue
		If	lAllMrk
			If	!( oMdlTFI:IsEmpty() )
				For nI := 1 to oMdlTFI:Length()
					oMdlTFI:GoLine(nI)
					If	nI <> nAtLineTFI .AND. !( lAllMrk := oMdlTFI:GetValue("OK") )
						EXIT
					EndIf
				Next nI
			EndIf
			If	lAllMrk .AND. !( oMdlTFF:IsEmpty() )
				For nI := 1 to oMdlTFF:Length()
					oMdlTFF:GoLine(nI)
					If	!( lAllMrk := oMdlTFF:GetValue("OK") )
						EXIT
					EndIf
				Next nI
			EndIf
		EndIf
		oMdlTFL:LoadValue("OK", lAllMrk)

	EndIf

EndIf

FWRestRows( aSaveLines )
If !IsBlind() .And. oView:IsActive()
	oView:Refresh()
EndIf

Return	lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At871TotVl
Utilizando o RECNO, busca o total orçado de uma TFI, TFF ou TFL
@sample 	At871TotVl(cTable, nRECNO)

@param  	cTable, string, Nome da tabela que desejas consultar (TFF, TFI ou TFL)
@param  	nRECNO, int, Nº do RECNO buscado 

@return	nRet, int, total orçado
@author 	Mateus Boiani
@since		05/07/2018
@version	P12
/*/
//------------------------------------------------------------------------------
Function At871TotVl(cTable, nRECNO)
Local nRet := 0
Local aArea := GetArea()
Local nDescon := 0
Local nTxLucr := 0
Local nTxAdm := 0

Default nRECNO := 0

If !(EMPTY(nRECNO))
	DbSelectArea(cTable)
	DbGoTo(nRECNO)
	If cTable == "TFI"
		nRet := TFI->TFI_TOTAL
	ElseIf cTable == "TFF"
		nRet := (TFF->TFF_QTDVEN * TFF->TFF_PRCVEN)
		nDescon := nRet * (TFF->TFF_DESCON / 100)
		nTxLucr := nRet * (TFF->TFF_LUCRO / 100)
		nTxAdm := nRet * (TFF->TFF_ADM / 100)
		nRet := (nRet - nDescon + nTxLucr + nTxAdm)
	ElseIf cTable == "TFL"
		nRet := TFL->TFL_TOTRH + TFL->TFL_TOTMI + TFL->TFL_TOTMC + TFL->TFL_TOTLE
	EndIf
EndIf

RestArea(aArea)

Return nRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At871TotVl
Utilizando o RECNO, busca o total apurado de uma TFI, TFF ou TFL
@sample 	At871TotMd(cTable, nRECNO)

@param  	cTable, string, Nome da tabela que desejas consultar (TFF, TFI ou TFL)
@param  	nRECNO, int, Nº do RECNO buscado 

@return	nRet, int, total apurado
@author 	Mateus Boiani
@since		05/07/2018
@version	P12
/*/
//------------------------------------------------------------------------------
Function At871TotMd(cTable, nRECNO)
Local nRet := 0
Local cContrato := ""
Local cRevContr := ""
Local cLocal := ""
Local aArea := GetArea()
Local aAreaCNA := CNA->(GetArea())
Local cAliasAux := GetNextAlias()
Local cAcrescimos := '1'
Local cDecrescimos := '2'

If !(EMPTY(nRECNO))
	DbSelectArea(cTable)
	DbGoTo(nRECNO)
	
	If cTable == "TFL"
	
		cLocal := TFL->TFL_PLAN
		cContrato := TFL->TFL_CONTRT
		cRevContr := TFL->TFL_CONREV
		
		BeginSql Alias cAliasAux
			SELECT CNA.CNA_VLTOT - CNA.CNA_SALDO AS VALOR
			FROM %table:CNA% CNA
			WHERE CNA.CNA_FILIAL = %xFilial:CNA%
				AND CNA.CNA_CONTRA = %Exp:cContrato%
				AND CNA.CNA_REVISA = %Exp:cRevContr%
				AND CNA.CNA_NUMERO = %Exp:cLocal%
				AND CNA.%NotDel%
		EndSql
		
	ElseIf cTable == "TFF"
		cLocal := TFF->TFF_COD
		
		BeginSql Alias cAliasAux
			SELECT SUM(TFW.TFW_VLRMED) + SUM(TFW.TFW_TOTMUL) - SUM(TFW.TFW_TOTBON) - SUM(TFW.TFW_TOTDES)  AS VALOR
			FROM %table:TFW% TFW
			WHERE TFW.TFW_FILIAL = %xFilial:TFW%
				AND TFW.TFW_CODTFF = %Exp:cLocal%
				AND TFW.%NotDel%
		EndSql
		
	ElseIf cTable == "TFI"
		cLocal := TFI->TFI_COD
		
		BeginSql Alias cAliasAux
			SELECT SUM(TFZ.TFZ_TOTAL) 
			 AS VALOR
			FROM %table:TFZ% TFZ
			WHERE TFZ.TFZ_FILIAL = %xFilial:TFZ%
				AND TFZ.TFZ_CODTFI = %Exp:cLocal%
				AND TFZ.%NotDel%
		EndSql
		
		nRet += IIF(VALTYPE((cAliasAux)->(VALOR)) == 'N', (cAliasAux)->(VALOR), 0)
		(cAliasAux)->(DbCloseArea())
		
		cAliasAux := GetNextAlias()
		
		BeginSql Alias cAliasAux
			SELECT SUM(TW6.TW6_VALOR) AS VALOR
			FROM %table:TW6% TW6
			WHERE TW6.TW6_CODPAI = %Exp:cLocal%
			AND TW6.%NotDel%
		EndSql
		
		nRet -= IIF(VALTYPE((cAliasAux)->(VALOR)) == 'N', (cAliasAux)->(VALOR), 0)
		(cAliasAux)->(DbCloseArea())
		
		cAliasAux := GetNextAlias()
		
		BeginSql Alias cAliasAux
			SELECT SUM(TW7_VALOR) AS VALOR
			FROM %table:TW7% TW7 
			WHERE TW7.TW7_CODPAI = %Exp:cLocal%
			AND TW7.%NotDel%
			AND TW7.TW7_TPMOV = %Exp:cAcrescimos%
		EndSql
		
		nRet += IIF(VALTYPE((cAliasAux)->(VALOR)) == 'N', (cAliasAux)->(VALOR), 0)
		(cAliasAux)->(DbCloseArea())
		
		cAliasAux := GetNextAlias()
		
		BeginSql Alias cAliasAux
			SELECT SUM(TW7_VALOR) AS VALOR
			FROM %table:TW7% TW7 
			WHERE TW7.TW7_CODPAI = %Exp:cLocal%
			AND TW7.%NotDel%
			AND TW7.TW7_TPMOV = %Exp:cDecrescimos%
		EndSql
		
		nRet -= IIF(VALTYPE((cAliasAux)->(VALOR)) == 'N', (cAliasAux)->(VALOR), 0)
		(cAliasAux)->(DbCloseArea())
		
	EndIf
	
	If !EMPTY(cLocal) .AND. cTable != "TFI"
		If (cAliasAux)->(!EOF())
			nRet := (cAliasAux)->(VALOR)
		EndIf
		(cAliasAux)->(DbCloseArea())
	EndIf
EndIf

RestArea(aAreaCNA)
RestArea(aArea)

Return nRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At871ChkAr
Verifica se, em uma TFL reativada, algum dos seus itens filhos continuam como encerrados.
Se sim, retorna .F.

@sample 	At871ChkAr(aArrPre, aArrPos, nRECTFL)

@param  	aArrPre, array, Array de itens encerrados antes do TECA871 (verificar At870gEnce() no TECA870)
@param  	aArrPos, array, Array de itens encerrados após o TECA871 (verificar At870gEnce() no TECA870)
@param  	nRECTFL, int, Nº do RECNO da TFL verificada 

@return	lRet, bool, .F. se um dos filhos da TFL estiver encerrado, .T. se todos os filhos estiverem ativos
@author 	Mateus Boiani
@since		05/07/2018
@version	P12
/*/
//------------------------------------------------------------------------------
Function At871ChkAr(aArrPre, aArrPos, nRECTFL)
Local lRet := .T.
Local nX
/*
	array itens encerrados:
		[1] R_E_C_N_O_ da TFL
		[2] TFL_ENCE (1 = Sim , Else = Não )
		[3] R_E_C_N_O_ da TFF
		[4] TFF_ENCE (1 = Sim , Else = Não )
		[5] R_E_C_N_O_ da TFI
		[6] TFI_ENCE (1 = Sim , Else = Não )
		[7] Bool que indica se a TFL já foi processada (.T. = Sim ; .F. = Não)
*/
For nX := 1 To LEN(aArrPos)
	If aArrPos[nX][1] == nRECTFL
		If aArrPos[nX][4] == "1" .OR. aArrPos[nX][6] == "1"
			lRet := .F.
			Exit
		EndIf
	EndIf
Next


Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At871DtEnc

@description Executa a logica de travar o campo caso o check box esteja desabilitado
@author	Augusto Albuquerque
@since	19/10/2021
/*/
//------------------------------------------------------------------------------
Function At871DtEnc(cIdTabela, lGeral, dDtEnce)
Local oModel	:= FwModelActive()
Local oView 	:= FwViewActive()
Local oMdlAux	:= oModel:GetModel(cIdTabela+"DETAIL")
Local oStrTFF	:= Nil
Local oMdlTFF	:= Nil
Local lEnce		:= oMdlAux:GetValue("OK")
Local nX		:= 0
Local nLine		:= 0
Local lContCtt	:= SuperGetMv("MV_GSDTENC",,.F.)

Default dDtEnce := dDataBase

If lEnce
	If cIdTabela == 'TFL'
		oMdlTFF := oModel:GetModel("TFFDETAIL")
		nLine := oMdlTFF:GetLine()
		For nX := 1 To oMdlTFF:Length()
			oMdlTFF:GoLine(nX)
			If oMdlTFF:GetValue("TFF_DTENCE") > dDtEnce
				dDtEnce := oMdlTFF:GetValue("TFF_DTENCE")
			EndIf
		Next nX
		oMdlTFF:GoLine( nLine )
	EndIf
	If Empty(oMdlAux:GetValue(cIdTabela+"_DTENCE"))
		If lContCtt .And. cIdTabela == 'TFF'
			dDtEnce := oMdlAux:GetValue("TFF_PERFIM")
		Else 
			dDtEnce := dDataBase
		EndIf 
		oMdlAux:LoadValue(cIdTabela+"_DTENCE", dDtEnce) 
		dDtEnce := dDataBase
	EndIf
Else
	oMdlAux:LoadValue(cIdTabela+"_DTENCE", CToD("")) 
EndIf

If cIdTabela == 'TFL' .AND. lGeral
	oMdlTFF := oModel:GetModel("TFFDETAIL")
	oStrTFF := oMdlTFF:GetStruct()
	nLine := oMdlTFF:GetLine()
	For nX := 1 To oMdlTFF:Length()
		oMdlTFF:GoLine(nX)
		If !(Empty(oMdlTFF:GetValue("TFF_PRODUT")))
			If lEnce
				If Empty(oMdlTFF:GetValue("TFF_DTENCE"))
					oMdlTFF:LoadValue("TFF_DTENCE", dDtEnce)
				EndIf
			Else
				oMdlTFF:LoadValue("TFF_DTENCE", CToD("")) 
			EndIf
		EndIf
	Next nX
	oMdlTFF:GoLine( nLine )
EndIf

If !isBlind()
	oView:Refresh()
EndIf

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} At871DtGat

@description Executa o gatilho para preencher o campo de OK
@author	Augusto Albuquerque
@since	19/10/2021
/*/
//------------------------------------------------------------------------------
Function At871DtGat( cIdTabela )
Local oModel	:= FwModelActive()
Local oMdlAux	:= oModel:GetModel(cIdTabela+"DETAIL")

If !IsInCallStack("InitDados")
	If Empty(oMdlAux:GetValue(cIdTabela+"_DTENCE"))
		oMdlAux:SetValue("OK", .F.)
	Else
		oMdlAux:SetValue("OK", .T.)
	EndIf
EndIf

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} A871DtEncF

@description Retorna a data da ultima agenda ativa para encerrar o posto
@author	Augusto Albuquerque
@since	17/01/2022
/*/
//------------------------------------------------------------------------------
Function A871DtEncF( oMdlTFF )
Local aArea			:= GetArea()
Local cAliasTDV 	:= GetNextAlias()
Local cWhereABB		:= "%%"
Local cWhereABQ		:= "%%"
Local cComAA1 		:= FwModeAccess("AA1",1) +  FwModeAccess("AA1",2) + FwModeAccess("AA1",3)
Local cComSRA 		:= FwModeAccess("SRA",1) +  FwModeAccess("SRA",2) + FwModeAccess("SRA",3)
Local dRet			:= SToD("")
Local lMV_MultFil 	:= SuperGetMV("MV_GSMSFIL",,.F.) .AND. (LEN(STRTRAN( cComAA1  , "E" )) > LEN(STRTRAN(  cComSRA  , "E" )))

If !lMV_MultFil
	cWhereABB := "% AND ABB.ABB_FILIAL = '" + xFilial("ABB") + "' %"
Else
	cWhereABB := "% AND " + FWJoinFilial("ABB" , "TDV" , "ABB", "TDV", .T.) + " %"
EndIf

If !lMV_MultFil
	cWhereABQ := "% AND ABQ.ABQ_FILIAL = '" + xFilial("ABQ") + "' %"
Else
	cWhereABQ := "% AND " + FWJoinFilial("ABQ" , "ABB" , "ABQ", "ABB", .T.) + " %"
Endif

BeginSql Alias cAliasTDV

	Select MAX(TDV.TDV_DTREF) TDV_DTREF
		From %table:TDV% TDV
			Inner join %table:ABB% ABB ON ABB.ABB_CODIGO = TDV.TDV_CODABB
									%Exp:cWhereABB%
									AND ABB.ABB_ATIVO = '1'
									AND ABB.%NotDel%
			Inner join %table:ABQ% ABQ ON ABQ.ABQ_CONTRT || ABQ.ABQ_ITEM || ABQ.ABQ_ORIGEM = ABB.ABB_IDCFAL
									AND ABQ.%NotDel%
									%Exp:cWhereABQ%
									AND ABQ.ABQ_FILTFF = %exp:oMdlTFF:GetValue("TFF_FILIAL")%
									AND ABQ.ABQ_CODTFF = %exp:oMdlTFF:GetValue("TFF_COD")%
	Where TDV.TDV_FILIAL = %xFilial:TDV%
		AND TDV.%NotDel%
EndSql

If (cAliasTDV)->( ! Eof() )
	dRet := SToD((cAliasTDV)->TDV_DTREF)
EndIf

(cAliasTDV)->(DbCloseArea())

RestArea(aArea)

Return dRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} at871AddMsg

@description Retorna a mensagem para preenchimento da mensagem de Log e Email
@Param xBreak -> CRLF (advpl) ou <br> (html) -- quebra de linha
		cMsg -> mensagem
		cTipo -> Tipo que define a composição e quantidade de espaços
		cValue1-cValue3 -> valores a se colocar na mensagem
@Ret cMsg -> Mensagem

@author	Jack Junior
@since	18/08/2023
/*/
//------------------------------------------------------------------------------

Static Function at871AddMsg(xBreak, cMsg, cTipo, cValue1, cValue2, cValue3, cValue4)

Default cValue1 := ""
Default cValue2 := ""
Default cValue3 := ""
Default cValue4 := ""

If cTipo == "LOCAL" .And. !Empty(cMsg)
	cMsg += xBreak + xBreak
	cMsg += Replicate( "-", 50 )
	cMsg += xBreak + xBreak
ElseIf !Empty(cMsg)
	cMsg += xBreak + xBreak
EndIf

If cTipo == "CONTRATO" //Mensagem do número de Contrato:
	cMsg +=	STR0053 + cValue1 + xBreak //"Número do Contrato: "
	cMsg +=	STR0058 + cValue2 //"Cliente: "

ElseIf cTipo == "LOCAL" //Mensagem de Local de Atendimento:
	cMsg +=	STR0054 + cValue1 + xBreak //"Código do Local de Atendimento: "
	cMsg +=	STR0055 + cValue2 //"Descrição do Local de Atendimento: "

ElseIf cTipo == "TITULO_MI" //Mensagem Titulo de Material de Implantação:
	If xBreak == CRLF
		cMsg += Space(4) + STR0022 + xBreak + xBreak //"Os materiais de implantação abaixo estão pendentes de retorno:"
		cMsg += Space(8) + STR0056  + " [" + cValue1 + "] "//"Posto"
		cMsg += STR0057 + " [" + cValue2 + "]" //Dt. Encerramento:
	Else
		cMsg += "&emsp;" + STR0022 + xBreak + xBreak //"Os materiais de implantação abaixo estão pendentes de retorno:"
		cMsg += "&emsp;" + "&emsp;" + "&bull;" + STR0056  + " [" + cValue1 + "] "//"Posto"
		cMsg += "<strong>"+ STR0057 + " [" + cValue2 + "] </strong>" //Dt. Encerramento:
	EndIf

ElseIf cTipo == "MI" //Mensagem de Material de Implantação:
	If xBreak == CRLF
		cMsg += Space(12) + cValue1 //Posto:
	Else
		cMsg += "&emsp;" + "&emsp;"  + "&emsp;" + cValue1
	EndIf

ElseIf cTipo == "FIMMI"
	cMsg += xBreak + xBreak + "<strong>"+ STR0059 +"</strong>" //"Por gentileza faça o retorno dos materiais de implantação acima até no máximo "

ElseIf cTipo == "TITULO_POSTO" //Mensagem de Titulo do Posto:
	If xBreak == CRLF
		cMsg += Space(4) + STR0060 + xBreak + xBreak //"Efetivos Alocados:"
		cMsg += Space(8) + STR0056 + " [" + cValue1 + "] " //Posto: 
		cMsg += STR0057 + " [" + cValue2 + "]" //Dt. Encerramento:
	Else
		cMsg += "&emsp;" + STR0060 + xBreak + xBreak //"Efetivos Alocados:"
		cMsg += "&emsp;" + "&emsp;" + "&bull;" + STR0056 + " [" + cValue1 + "] " //Posto: 
		cMsg += "<strong>"+ STR0057 + " [" + cValue2 + "] </strong>" //Dt. Encerramento:
	EndIf

ElseIf cTipo == "POSTO" //Mensagem do Posto:
	If xBreak == CRLF
		cMsg +=	Space(12) + STR0063 + " [" + cValue1 + "] " + STR0064 + " [" + cValue2 + "-" + cValue3 + "]" //"Serviço: []" # "Atendente:[-]"
	Else
		cMsg +=	"&emsp;" + "&emsp;" + "&emsp;" + STR0063 + " [" + cValue1 + "] " + STR0064 + " [" + cValue2 + "-" + cValue3 + "]" //"Serviço: []" # "Atendente:[-]"
	EndIf
	If !Empty(cValue4)
		cMsg +=	" " + STR0079 + " [" + cValue4 + "]" //"Admissão:"
	EndIf

ElseIf cTipo == "FIMPOSTO"
	cMsg += xBreak + xBreak + "<strong>"+STR0061+"</strong>" //"Por gentileza exclua as agendas dos atendentes a partir da data de encerramento dos respectivos postos até no máximo "

ElseIf cTipo == "TITULO_ARMA" //Mensagem de Titulo de armamento:
	If xBreak == CRLF
		cMsg += Space(4) + STR0052 + xBreak + xBreak //"Os Armamentos abaixo estão pendentes de retorno:"
		cMsg += Space(8) + STR0056  + " [" + cValue1 + "] "//"Posto"
		cMsg += STR0057 + " [" + cValue2 + "]" //Dt. Encerramento:
	Else
		cMsg += "&emsp;" + STR0052 + xBreak + xBreak //"Os Armamentos abaixo estão pendentes de retorno:"
		cMsg += "&emsp;" + "&emsp;" + "&bull;" + STR0056  + " [" + cValue1 + "] "//"Posto"
		cMsg += "<strong>"+ STR0057 + " [" + cValue2 + "] </strong>" //Dt. Encerramento:
	EndIf

ElseIf cTipo == "ARMA" //Mensagem do Armamento:
	If xBreak == CRLF
		cMsg += Space(12) + cValue1
	Else
		cMsg += "&emsp;" + "&emsp;"  + "&emsp;" + cValue1
	EndIf

ElseIf cTipo == "FIMARMA"
	cMsg += xBreak + xBreak + "<strong>"+STR0062+"</strong>" //"Por gentileza faça o retorno dos Armamentos acima até no máximo "

EndIf

Return cMsg
