#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "WMSA510.CH"
#INCLUDE "FWEDITPANEL.CH"

#DEFINE WMSA51001 "WMSA51001"
#DEFINE WMSA51002 "WMSA51002"
#DEFINE WMSA51003 "WMSA51003"
#DEFINE WMSA51004 "WMSA51004"
#DEFINE WMSA51005 "WMSA51005"
#DEFINE WMSA51006 "WMSA51006"
#DEFINE WMSA51007 "WMSA51007"
#DEFINE WMSA51008 "WMSA51008"
#DEFINE WMSA51009 "WMSA51009"
#DEFINE WMSA51010 "WMSA51010"
#DEFINE WMSA51011 "WMSA51011"
#DEFINE WMSA51012 "WMSA51012"
#DEFINE WMSA51013 "WMSA51013"
#DEFINE WMSA51014 "WMSA51014"
#DEFINE WMSA51015 "WMSA51015"
#DEFINE WMSA51016 "WMSA51016"


Static lOperInsert := .F.
Static lOperView   := .F.
Static lOperDelete := .F.


//---------------------------------------------------------------
/*/{Protheus.doc} WMSA510
Rotina de Montagem/Desmontagem de produtos com estrutura
@author felipe.m
@since 25/02/2015
@version 1.0
/*/
//---------------------------------------------------------------
Function WMSA510()
Local oBrw := Nil


	// Permite efetuar validações, apresentar mensagem e abortar o programa quando desejado
	If !WMSChkPrg(FunName(),"1")
		Return Nil
	EndIf

	oBrw := FWMBrowse():New()
	oBrw:SetAlias("D0A")
	oBrw:SetMenuDef("WMSA510")
	oBrw:AddLegend("D0A_OPERAC == '1'",'BLUE', STR0001) // Montagem
	oBrw:AddLegend("D0A_OPERAC == '2'",'RED',  STR0002) // Desmontagem
	oBrw:SetFilterDefault("@ D0A_PROCES = '1'")
	oBrw:SetDescription(STR0003) // Montagem/Desmontagem Estrutura WMS
	oBrw:Activate()
Return
//---------------------------------------------------------------
/*/{Protheus.doc} MenuDef
MenuDef
@author felipe.m
@since 25/02/2015
@version 1.0
/*/
//---------------------------------------------------------------
Static Function MenuDef()
Private aRotina := {}
	ADD OPTION aRotina TITLE STR0004 ACTION 'PesqBrw'       OPERATION MODEL_OPERATION_VIEW   ACCESS 0 // Pesquisar
	ADD OPTION aRotina TITLE STR0005 ACTION 'WMSA510MEN(2)' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 // Visualizar
	ADD OPTION aRotina TITLE STR0006 ACTION 'WMSA510MEN(3)' OPERATION MODEL_OPERATION_INSERT ACCESS 0 // Incluir
	ADD OPTION aRotina TITLE STR0008 ACTION 'WMSA510MEN(4)' OPERATION MODEL_OPERATION_DELETE ACCESS 0 // Excluir
Return aRotina
//---------------------------------------------------------------
Function WMSA510MEN(nPos)
Local lRet       := .T.
Local aRotina    := MenuDef()
Local nOperation := 0

	nOperation  := aRotina[nPos][4]
	lOperInsert := .F.
	lOperView   := .F.
	lOperDelete := .F.

	Do Case
		Case nOperation == MODEL_OPERATION_INSERT
			lRet := Pergunte("WMSA510",.T.)
			lOperInsert := .T.
			If lRet
				lRet := A510VldPrd(.T.) .And. A510VldArm()
			EndIf

		Case nOperation == MODEL_OPERATION_VIEW
			lOperView := .T.

		Case nOperation == MODEL_OPERATION_DELETE
			lRet := A510VldOS()
			lOperDelete := .T.
	EndCase
	
	If lRet .And. SegunNivel()
		WmsMessage(STR0033,WMSA51008) //Não é possível realizar montagem/desmontagem do segundo nível de um produto componente.
		lRet := .F.
	EndIf
Return Iif(lRet,FWExecView(aRotina[nPos][1],"WMSA510",nOperation,,{ || .T. },{ || .T. },0,,{ || .T. },,, ),.F.)
//---------------------------------------------------------------
/*/{Protheus.doc} ModelDef
ModeDef
@author felipe.m
@since 25/02/2015
@version 1.0
/*/
//---------------------------------------------------------------
Static Function ModelDef()
Local oModel   := Nil
Local oStrD0A  := FWFormStruct(1,'D0A')
Local oStrD0B  := FWFormStruct(1,'D0B')
Local oStrD0C  := FWFormStruct(1,'D0C')
Local oStrSld  := FWFormModelStruct():New()
Local aColsSx3 := {}
Local bLoadD0C := Iif(!lOperInsert,{|| LoadGrdD0C(oModel) },Nil)
Local bLoadSld := Iif(!lOperInsert,{|| LoadGrdSld(oModel) },Nil)
Local bValid   := { |oModel,cField| ValidField(oModel,cField) }
Local cDocto := ""

	oModel := MPFormModel():New('WMSA510',,{|oModel| ValidModel(oModel) },{|oModel|CommitMdl(oModel)})

	// cTitulo,cTooltip,cIdField,cTipo,nTamanho,nDecimal,bValid,bWhen,aValues,lObrigat,bInit,lKey,lNoUpd,lVirtual,cValid
	oStrD0A:AddField(buscarSX3("D0A_QTDMOV",,aColsSX3) ,aColsSX3[1],'D0A_QTDSLD','N',aColsSX3[3],aColsSX3[4],Nil,{||.F.}/*bWhen*/,Nil,.F.,,.F.,.T./*lNoUpd*/,.F.)
	oStrD0A:SetProperty('D0A_DOC'   ,MODEL_FIELD_INIT ,{|| cDocto := GetSX8Num('DCF','DCF_DOCTO'),IIf(__lSX8,ConfirmSX8(),),cDocto })
	oStrD0A:SetProperty('D0A_DTMOV' ,MODEL_FIELD_INIT ,{|| dDataBase })
	oStrD0A:SetProperty('D0A_QTDMOV',MODEL_FIELD_VALID,{|| SetQtdMult() })
	oStrD0A:SetProperty('D0A_ENDER',MODEL_FIELD_OBRIGAT,.F.)
	oStrD0A:SetProperty('D0A_QTDMOV',MODEL_FIELD_OBRIGAT,.T.)
	oStrD0A:SetProperty('D0A_MOVAUT',MODEL_FIELD_INIT ,FWBuildFeature(STRUCT_FEATURE_INIPAD, "'1'"))

	oModel:AddFields('A510D0A',,oStrD0A)
	oModel:SetDescription(STR0003) // Montagem/Desmontagem Estrutura WMS
	oModel:GetModel('A510D0A'):SetDescription(STR0003) // Montagem/Desmontagem Estrutura WMS
	// Monta Componentes
	// cTitulo,cTooltip,cIdField,cTipo,nTamanho,nDecimal,bValid,bWhen,aValues,lObrigat,bInit,lKey,lNoUpd,lVirtual,cValid
	oStrD0C:AddField(buscarSX3("DCF_QUANT",,aColsSX3),aColsSX3[1],'QTDCNJ','N',aColsSX3[3],aColsSX3[4],Nil,{||.F.}/*bWhen*/,Nil,.F.,,.F.,.F./*lNoUpd*/,.F.)
	oStrD0C:AddField(buscarSX3("DCF_QUANT",,aColsSX3),aColsSX3[1],'QTDPRE','N',aColsSX3[3],aColsSX3[4],Nil,{||.F.}/*bWhen*/,Nil,.F.,,.F.,.F./*lNoUpd*/,.F.)
	oStrD0C:SetProperty('D0C_PRODUT',MODEL_FIELD_WHEN,.F.)
	oStrD0C:SetProperty('D0C_LOTECT',MODEL_FIELD_WHEN,.F.)
	oStrD0C:SetProperty('D0C_NUMLOT',MODEL_FIELD_WHEN,.F.)
	oStrD0C:SetProperty('D0C_PRODUT',MODEL_FIELD_VALID,bValid)

	oModel:AddGrid('A510D0C','A510D0A',oStrD0C,/*bLinePre*/,/*bLinePost*/,/*bPre*/,/*bLinePost*/,bLoadD0C)
	oModel:SetRelation("A510D0C", {{"D0C_FILIAL","xFilial('D0C')"},{"D0C_DOC","D0A_DOC"}} )
	oModel:GetModel('A510D0C'):SetDescription(STR0011) // Componentes
	oModel:GetModel('A510D0C'):SetOptional(.T.)
	oModel:GetMOdel('A510D0C'):SetOnlyQuery(.T.)

	// Monta Saldos por Endereço
	oStrSld:AddTable('D14',{'LOCAL','PRODUT','LOTECT','NUMLOT','ENDORI'},'')
	oStrSld:AddIndex(1,"01","LOCAL+PRODUT+LOTECT+NUMLOT+ENDORI","Armazém+Produto+Lote+Sub-Lote+End. Origem","","",.T.)

	// cTitulo,cTooltip,cIdField,cTipo,nTamanho,nDecimal,bValid,bWhen,aValues,lObrigat,bInit,lKey,lNoUpd,lVirtual,cValid
	oStrSld:AddField(buscarSX3("DCF_LOCAL",,aColsSX3) ,aColsSX3[1],'LOCAL' ,'C',aColsSX3[3],aColsSX3[4],Nil,{||.F.}/*bWhen*/,Nil,.F.,,.F.,.F./*lNoUpd*/,.F.)
	oStrSld:AddField(buscarSX3("DCF_CODPRO",,aColsSX3),aColsSX3[1],'PRODUT','C',aColsSX3[3],aColsSX3[4],Nil,{||.F.}/*bWhen*/,Nil,.F.,,.F.,.F./*lNoUpd*/,.F.)
	oStrSld:AddField(buscarSX3("B1_DESC",,aColsSX3)   ,aColsSX3[1],'DESC'  ,'C',aColsSX3[3],aColsSX3[4],Nil,{||.F.}/*bWhen*/,Nil,.F.,,.F.,.F./*lNoUpd*/,.F.)
	oStrSld:AddField(buscarSX3("DCF_LOTECT",,aColsSX3),aColsSX3[1],'LOTECT','C',aColsSX3[3],aColsSX3[4],Nil,{||.F.}/*bWhen*/,Nil,.F.,,.F.,.F./*lNoUpd*/,.F.)
	oStrSld:AddField(buscarSX3("DCF_NUMLOT",,aColsSX3),aColsSX3[1],'NUMLOT','C',aColsSx3[3],aColsSX3[4],Nil,{||.F.}/*bWhen*/,Nil,.F.,,.F.,.F./*lNoUpd*/,.F.)
	oStrSld:AddField(buscarSX3("DCF_ENDER",,aColsSX3) ,aColsSX3[1],'ENDORI','C',aColsSx3[3],aColsSX3[4],Nil,{||.F.}/*bWhen*/,Nil,.F.,,.F.,.F./*lNoUpd*/,.F.)
	oStrSld:AddField(buscarSX3("DCF_QUANT",,aColsSX3) ,aColsSX3[1],'QTDSLD','N',aColsSx3[3],aColsSX3[4],Nil,{||.F.}/*bWhen*/,Nil,.F.,,.F.,.F./*lNoUpd*/,.F.)
	If WmsX312118('D0R','D0R_IDUNIT')
		oStrSld:AddField(buscarSX3("D0R_IDUNIT",,aColsSX3),aColsSX3[1],'IDUNIT','C',aColsSx3[3],aColsSX3[4],Nil,{||.F.}/*bWhen*/,Nil,.F.,,.F.,.F./*lNoUpd*/,.F.)
	EndIf
	oStrSld:AddField(buscarSX3("DCF_QUANT",,aColsSX3) ,aColsSX3[1],'QUANT' ,'N',aColsSx3[3],aColsSX3[4],{ |A,B,C,D,nValAnt| SetQtdDig(nValAnt,oModel) },{||.T.}/*bWhen*/,Nil,.F.,,.F.,.F./*lNoUpd*/,.F.)

	oModel:AddGrid('A510SLD','A510D0C',oStrSld,/*bLinePre*/,/*bLinePost*/,/*bPre*/,/*bLinePost*/,bLoadSld)
	oModel:GetModel('A510SLD'):SetDescription(STR0012) // Saldo por Endereço
	oModel:SetRelation("A510SLD", {{"PRODUT","D0C_PRODUT"}} )
	oModel:GetModel('A510SLD'):SetOptional(.T.)
	oModel:GetMOdel('A510SLD'):SetOnlyQuery(.T.)

	oModel:AddGrid('A510D0B','A510D0A',oStrD0B)
	oModel:GetModel('A510D0B'):SetDescription(STR0012) // Saldo por Endereço
	oModel:SetRelation("A510D0B", {{"D0B_FILIAL","xFilial('D0B')"},{"D0B_DOC","D0A_DOC"}} )
	oModel:GetModel('A510D0B'):SetOptional(.T.)

	oModel:GetModel("A510SLD"):SetNoInsertLine(.T.)
	oModel:GetModel("A510SLD"):SetNoDeleteLine(.T.)
	oModel:GetModel("A510D0C"):SetNoInsertLine(.T.)
	oModel:GetModel("A510D0C"):SetNoDeleteLine(.T.)

	oModel:SetActivate({|oModel| Iif(!lOperDelete .And. !lOperView, Active(oModel), .T.) })
Return oModel
//---------------------------------------------------------------
/*/{Protheus.doc} ViewDef
ViewDef
@author felipe.m
@since 25/02/2015
@version 1.0
/*/
//---------------------------------------------------------------
Static Function ViewDef()
Local oModel   := ModelDef()
Local oStrD0A  := FWFormStruct(2,'D0A')
Local oStrD0C  := FWFormStruct(2,'D0C')
Local oStrSld  := FWFormViewStruct():New()
Local oView    := Nil
Local aColsSX3 := {}

	oView := FWFormView():New()
	oView:SetModel(oModel)

	If !lOperDelete .And.  !lOperView
		// cIdField,cOrdem,cTitulo,cDescric,aHelp,cType,cPicture,bPictVar,cLookUp,lCanChange,cFolder,cGroup,aComboValues,nMaxLenCombo,cIniBrow,lVirtual,cPictVar,lInsertLine,nWidth,lIsDeleted
		oStrD0A:AddField('D0A_QTDSLD','08',buscarSX3("D0A_QTDMOV",STR0013,aColsSX3)  ,aColsSX3[1],Nil,'GET',aColsSX3[2],Nil,Nil/*cLookUp*/,.F./*lCanChange*/,Nil,Nil,Nil,Nil,Nil,.F.) // Qtd. Multipla
	EndIf
	oStrD0A:RemoveField('D0A_PROCES')
	oStrD0A:RemoveField('D0A_ENDER')
	oStrD0A:RemoveField('D0A_MOVAUT')
	oStrD0A:SetProperty('D0A_DOC'   ,MVC_VIEW_ORDEM,'01')
	oStrD0A:SetProperty('D0A_LOCAL' ,MVC_VIEW_ORDEM,'02')
	oStrD0A:SetProperty('D0A_PRODUT',MVC_VIEW_ORDEM,'03')
	oStrD0A:SetProperty('D0A_DESC'  ,MVC_VIEW_ORDEM,'04')
	oStrD0A:SetProperty('D0A_LOTECT',MVC_VIEW_ORDEM,'05')
	oStrD0A:SetProperty('D0A_NUMLOT',MVC_VIEW_ORDEM,'06')
	oStrD0A:SetProperty('D0A_DTMOV' ,MVC_VIEW_ORDEM,'07')
	oStrD0A:SetProperty('D0A_QTDMOV',MVC_VIEW_ORDEM,'09')
	oStrD0A:SetProperty('D0A_OPERAC',MVC_VIEW_ORDEM,'10')
	oStrD0A:SetProperty('D0A_PRODUT',MVC_VIEW_CANCHANGE,.F.)
	oStrD0A:SetProperty("D0A_DTMOV" ,MVC_VIEW_CANCHANGE,.F.)
	If !lOperInsert
		oStrD0A:SetProperty('D0A_QTDMOV',MVC_VIEW_CANCHANGE,.F.)
	EndIf

	oView:AddField('VA510D0A',oStrD0A,'A510D0A')
	oView:SetViewProperty('VA510D0A','SETLAYOUT',{FF_LAYOUT_VERT_DESCR_TOP,5})
	oView:SetDescription(STR0003) // Montagem/Desmontagem Estrutura WMS

	// cIdField,cOrdem,cTitulo,cDescric,aHelp,cType,cPicture,bPictVar,cLookUp,lCanChange,cFolder,cGroup,aComboValues,nMaxLenCombo,cIniBrow,lVirtual,cPictVar,lInsertLine,nWidth,lIsDeleted
	If !lOperDelete
		oStrD0C:AddField('QTDCNJ','03',buscarSX3("DCF_QUANT",STR0013,aColsSX3),aColsSX3[1],Nil,'GET',aColsSX3[2],Nil,Nil/*cLookUp*/,.F./*lCanChange*/,Nil,Nil,Nil,Nil,Nil,.F.) // Qtd. Multipla"
	EndIf
	If !lOperDelete .And. !lOperView
		oStrD0C:AddField('QTDPRE','04',buscarSX3("DCF_QUANT",STR0016,aColsSX3),aColsSX3[1],Nil,'GET',aColsSX3[2],Nil,Nil/*cLookUp*/,.F./*lCanChange*/,Nil,Nil,Nil,Nil,Nil,.F.) // Qtd. Preenchida"
	EndIf
	oStrD0C:RemoveField('D0C_DOC')
	oStrD0C:RemoveField('D0C_LOTECT')
	oStrD0C:RemoveField('D0C_NUMLOT')
	oStrD0C:SetProperty('D0C_PRODUT',MVC_VIEW_ORDEM,'01')
	oStrD0C:SetProperty('D0C_DESC'  ,MVC_VIEW_ORDEM,'02')
	If (!lOperInsert .And. D0A->D0A_OPERAC == "1") .Or. (lOperInsert .And. MV_PAR05 == 1)
		oStrD0C:RemoveField('D0C_RATEIO')
	Else
		oStrD0C:SetProperty('D0C_RATEIO',MVC_VIEW_ORDEM,'05')
	EndIf
	oStrD0C:SetProperty('D0C_PRODUT',MVC_VIEW_CANCHANGE,.F.)

	oView:AddGrid('VA510D0C',oStrD0C,'A510D0C')
	oView:EnableTitleView('VA510D0C', STR0011) // Componentes

	// cIdField,cOrdem,cTitulo,cDescric,aHelp,cType,cPicture,bPictVar,cLookUp,lCanChange,cFolder,cGroup,aComboValues,nMaxLenCombo,cIniBrow,lVirtual,cPictVar,lInsertLine,nWidth,lIsDeleted
	oStrSld:AddField('PRODUT','01',buscarSX3("DCF_CODPRO",,aColsSX3),aColsSX3[1],Nil,'GET',aColsSX3[2],Nil,Nil/*cLookUp*/,.F./*lCanChange*/,Nil,Nil,Nil,Nil,Nil,.F.)
	oStrSld:AddField('DESC'  ,'02',buscarSX3("B1_DESC",,aColsSX3)   ,aColsSX3[1],Nil,'GET',aColsSX3[2],Nil,Nil/*cLookUp*/,.F./*lCanChange*/,Nil,Nil,Nil,Nil,Nil,.F.)
	oStrSld:AddField('LOTECT','03',buscarSX3("DCF_LOTECT",,aColsSX3),aColsSX3[1],Nil,'GET',aColsSX3[2],Nil,Nil/*cLookUp*/,.F./*lCanChange*/,Nil,Nil,Nil,Nil,Nil,.F.)
	oStrSld:AddField('NUMLOT','04',buscarSX3("DCF_NUMLOT",,aColsSX3),aColsSX3[1],Nil,'GET',aColsSX3[2],Nil,Nil/*cLookUp*/,.F./*lCanChange*/,Nil,Nil,Nil,Nil,Nil,.F.)
	oStrSld:AddField('ENDORI','05',buscarSX3("DCF_ENDER",,aColsSX3) ,aColsSX3[1],Nil,'GET',aColsSX3[2],Nil,Nil/*cLookUp*/,.F./*lCanChange*/,Nil,Nil,Nil,Nil,Nil,.F.)
	If WmsX312118('D0R','D0R_IDUNIT')
		oStrSld:AddField('IDUNIT','06',buscarSX3("D0R_IDUNIT",,aColsSX3),aColsSX3[1],Nil,'GET',aColsSX3[2],Nil,Nil/*cLookUp*/,.F./*lCanChange*/,Nil,Nil,Nil,Nil,Nil,.F.)
	EndIf
	If !lOperDelete .And. !lOperView
		oStrSld:AddField('QTDSLD','07',buscarSX3("DCF_QUANT",STR0017,aColsSX3),aColsSX3[1],Nil,'GET',aColsSX3[2],Nil,Nil/*cLookUp*/,.F./*lCanChange*/,Nil,Nil,Nil,Nil,Nil,.F.) // Qtd. Saldo"
	EndIf
	oStrSld:AddField('QUANT' ,'08',buscarSX3("DCF_QUANT",STR0018,aColsSX3),aColsSX3[1],Nil,'GET',aColsSX3[2],Nil,Nil/*cLookUp*/,.T./*lCanChange*/,Nil,Nil,Nil,Nil,Nil,.F.) // Qtd. Movimento"

	oView:AddGrid('VA510SLD',oStrSld,'A510SLD')
	oView:EnableTitleView('VA510SLD', STR0012) // Saldo por Endereço

	oView:CreateHorizontalBox('HORIZONTAL_UP',30)
	oView:CreateHorizontalBox('HORIZONTAL_MID',25)
	oView:CreateHorizontalBox('HORIZONTAL_DOWN',45)

	oView:SetOwnerView('VA510D0A','HORIZONTAL_UP')
	oView:SetOwnerView('VA510D0C','HORIZONTAL_MID')
	oView:SetOwnerView('VA510SLD','HORIZONTAL_DOWN')
Return oView
//---------------------------------------------------------------
/*/{Protheus.doc} ValidModel
Validação dos dados
@author felipe.m
@since 25/02/2015
@version 1.0
/*/
//---------------------------------------------------------------
Static Function ValidModel(oModel)
Local lRet      := .T.
Local nI        := 0
Local nJ        := 0
Local nPos      := 0
Local nQuant    := 0
Local nQtdDisp  := 0
Local aLotesPrd := {}
Local aLotes    := {}
Local aArrProd  := {}
Local oProdComp := Nil
Local oView     := Nil
Local oEndereco := WMSDTCEndereco():New() 
Local oSeqAbast := WMSDTCSequenciaAbastecimento():New()
Local oModelD0A := oModel:GetModel("A510D0A")

	If !lOperView .And. !lOperDelete
		//Verifica quantidade disponível novamente
		nQtdDisp := WMSA510SLD(oModelD0A:GetValue("D0A_LOCAL"),oModelD0A:GetValue("D0A_PRODUT"),oModelD0A:GetValue("D0A_LOTECT"),oModelD0A:GetValue("D0A_NUMLOT"),/*dDtValid*/,oModelD0A:GetValue("D0A_OPERAC") == "2",.T.)
		If QtdComp(nQtdDisp) < QtdComp(oModelD0A:GetValue("D0A_QTDMOV"))
			//Recarrega saldo dos componentes
			LoadSldPrd()
			oModel:GetModel():SetErrorMessage( , , oModel:GetId() , '',WMSA51013,STR0041,WmsFmtMsg(STR0042,{{"[VAR01]",Str(nQtdDisp)}}), '', '') //Quantidade informada indisponível. //Informe uma quantidade compatível com a disponível ([VAR01]).
			oModelD0A:LoadValue("D0A_QTDSLD",nQtdDisp)
			oView := FWViewActive()
			oView:Refresh()
			Return .F.
		EndIf
		If lRet
			For nI := 1 To oModel:GetModel("A510D0C"):Length()
				oModel:GetModel("A510D0C"):GoLine(nI)

				// A quantidade mulipla dos componentes deve ser igual a quantidade preenchida para cada produto
				If oModel:GetModel("A510D0C"):GetValue("QTDCNJ",nI) != oModel:GetModel("A510D0C"):GetValue("QTDPRE",nI)
					lRet := .F.
					oModel:GetModel():SetErrorMessage( , , oModel:GetId() , '',WMSA51001,WmsFmtMsg(STR0019,{{"[VAR01]",oModel:GetModel("A510D0C"):GetValue("D0C_PRODUT",nI)}}), "", '', '') //// Rever quantidades preenchidas para o produto [VAR01]!
					Exit
				EndIf

				For nJ := 1 To oModel:GetModel("A510SLD"):Length()
					oModel:GetModel("A510SLD"):GoLine(nJ)

					If lRet .And. !Empty(oModel:GetModel("A510SLD"):GetValue("LOTECT"))
						nPos := aScan(aLotesPrd,{ |x| x[1]+x[2]+x[3] == oModel:GetModel("A510SLD"):GetValue("LOTECT") + oModel:GetModel("A510SLD"):GetValue("NUMLOT") + oModel:GetModel("A510SLD"):GetValue("PRODUT") })

						If nPos == 0
							aAdd(aLotesPrd,{ oModel:GetModel("A510SLD"):GetValue("LOTECT"),oModel:GetModel("A510SLD"):GetValue("NUMLOT"),oModel:GetModel("A510SLD"):GetValue("PRODUT"),oModel:GetModel("A510SLD"):GetValue("QUANT") })
						Else
							aLotesPrd[nPos][4] += oModel:GetModel("A510SLD"):GetValue("QUANT")
						EndIf
					EndIf
				Next nJ
			Next nI
		EndIf
		If lRet .And. Len(aLotesPrd) > 0
			For nJ := 1 To Len(aLotesPrd)
				If (aScan(aLotes,{ |x| x[1]+x[2] == aLotesPrd[nJ][1] + aLotesPrd[nJ][2]}) == 0) .And. QtdComp(aLotesPrd[nJ][4]) > 0
					 aAdd(aLotes,{aLotesPrd[nJ][1], aLotesPrd[nJ][2]})
				EndIf
			Next nJ
			oProdComp := WMSDTCProdutoComponente():New()
			oProdComp:SetPrdOri(oModelD0A:GetValue("D0A_PRODUT"))
			oProdComp:LoadData(3)
			If oProdComp:EstProduto()
				aArrProd := oProdComp:GetArrProd()
			EndIf

			For nJ := 1 To Len(aLotes)
				For nI := 1 To Len(aArrProd)
					If (nPos := aScan(aLotesPrd,{|x| AllTrim(x[1]+x[2]+x[3]) == AllTrim(aLotes[nJ][1]+aLotes[nJ][2]+ aArrProd[nI][1])})) > 0
						If nI == 1
							nQuant := aLotesPrd[nPos][4] / aArrProd[nI][2]
						Else
							If nQuant != (aLotesPrd[nPos][4] / aArrProd[nI][2])
								lRet := .F.
								oModel:GetModel():SetErrorMessage( , , oModel:GetId() , '', WMSA51002,STR0020, WmsFmtMsg(STR0021,{{"[VAR01]",aLotes[nJ + (nI - 1)][1]}}), '', '') // Quantidade multipla dos componentes em lotes inválida! // Rever quantidades dos produtos do Lote [VAR01].
								Exit
							EndIf
						EndIf
					Else
						lRet := .F.
						oModel:GetModel():SetErrorMessage( , , oModel:GetId() , '', WMSA51009,STR0020, WmsFmtMsg(STR0021,{{"[VAR01]",aLotes[nJ + (nI - 1)][1]}}), '', '') // Quantidade multipla dos componentes em lotes inválida! // Rever quantidades dos produtos do Lote [VAR01].
						Exit
					EndIf
				Next nI

				If !lRet
					Exit
				EndIf
			Next nJ
		EndIf
		If lRet .And. oModelD0A:GetValue("D0A_OPERAC") == "2"
			nQuant := 0

			For nI := 1 To oModel:GetModel("A510D0C"):Length()
				oModel:GetModel("A510D0C"):GoLine(nI)

				nQuant += oModel:GetModel("A510D0C"):GetValue("D0C_RATEIO")
			Next nI

			If nQuant != 100
				oModel:GetModel():SetErrorMessage( , , oModel:GetId() , '',WMSA51006,STR0029,STR0030, '', '') // Rateio inválido. // Quantidade informada para o rateio deve somar 100%.
				lRet := .F.
			EndIf
		EndIf
	EndIf
	oEndereco:Destroy()
	oSeqAbast:Destroy()
Return lRet
//---------------------------------------------------------------
/*/{Protheus.doc} ValidOS
Valida se a ordem de serviço relacionada está executada
@author felipe.m
@since 06/03/2015
@version 1.0
/*/
//---------------------------------------------------------------
Function A510VldOS()
Local lRet      := .T.
Local aAreaAnt  := GetArea()
Local cAliasDCF := GetNextAlias()
	BeginSql Alias cAliasDCF
		SELECT DCF.DCF_ID
		FROM %Table:DCF% DCF
		WHERE DCF.DCF_FILIAL = %xFilial:DCF%
		AND DCF.DCF_ORIGEM = 'D0A'
		AND DCF.DCF_DOCTO  = %Exp:D0A->D0A_DOC%
		AND DCF.DCF_STSERV IN ('2','3')
		AND DCF.%NotDel%
	EndSql
	If (cAliasDCF)->(!Eof())
		WmsMessage(STR0022,WMSA51003,,,,STR0023) // Documento não pode ser alterado/excluído, pois existe serviço executado! // Estorne primeiramente estes serviços!
		lRet := .F.
	EndIf
	(cAliasDCF)->(dbCloseArea())
	RestArea(aAreaAnt)
Return lRet
//---------------------------------------------------------------
/*/{Protheus.doc} A510VldPrd
Validação do produto informado no pergunte
@author felipe.m
@since 06/03/2015
@version 1.0
@param lInvRet, Lógico, (Inverte pesquisa)
/*/
//---------------------------------------------------------------
Function A510VldPrd(lInvRet,lDesmPrd)
Local lRet      := .T.
Local lLote     := .F.
Local lSLote    := .F.
Local aAreaAnt  := GetArea()
Local cErro     := ""
Local cSolucao  := ""
Local cAliasD11 := Nil
Default lDesmPrd:= .F.
	If !IntWMS(MV_PAR02)
		cErro := STR0028 // Produto não controla WMS.
		lRet := .F.
	Else
		If lDesmPrd
			lLote  := Rastro(MV_PAR02)
			lSLote := Rastro(MV_PAR02,'S')
			If lLote .And. Empty(MV_PAR03)
				cErro    := STR0044 // Produto Informado possui controle de rastro.
				cSolucao := STR0045 // Informe o lote.
				lRet     := .F.
			ElseIf lSLote .And. (Empty(MV_PAR03) .Or. Empty(MV_PAR04))
				cErro    := STR0044 // Produto Informado possui controle de rastro.
				cSolucao := STR0046 // Informe o lote e sub-lote.
				lRet     := .F.
			EndIf
		EndIf
		If lRet
			cAliasD11 := GetNextAlias()
			BeginSql Alias cAliasD11
				SELECT 1
				FROM %Table:D11% D11
				WHERE D11.D11_FILIAL = %xFilial:D11%
				AND D11.D11_PRDORI = %Exp:MV_PAR02%
				AND D11.%NotDel%
			EndSql
			If (cAliasD11)->(!Eof())
				lRet := .F.
			EndIf
			(cAliasD11)->(dbCloseArea())
			If lInvRet
				lRet := !lRet
			EndIf
			If !lRet
				If !lInvRet
					cErro    := STR0024 // Produto informado possui estrutura.
					cSolucao := STR0025 // Utilize a rotina Montagem/Desmontagem Estrutura WMS (WMSA510).
					lRet     := .F.
				Else
					cErro    := STR0026 // Produto informado não possui estrutura.
					cSolucao := STR0027 // Utilize a rotina Montagem/Desmontagem Produtos WMS (WMSA520).
					lRet     := .F.
				EndIf
			EndIf
		EndIf
	EndIf
	If !lRet
		WmsMessage(cErro,WMSA51004,,,,cSolucao)
	EndIf
	RestArea(aAreaAnt)
Return lRet

Static Function SegunNivel()
Local oProdComp := WMSDTCProdutoComponente():New()
	oProdComp:SetPrdOri( PadR(Iif(lOperInsert,MV_PAR02,D0A->D0A_PRODUT),TamSx3("D0A_PRODUT")[1]) )
	oProdComp:LoadData(3)
Return oProdComp:GetNivel() > 1
//---------------------------------------------------------------
/*/{Protheus.doc} CommitMdl
Criação dos serviços
@author felipe.m
@since 25/02/2015
@version 1.0
/*/
//---------------------------------------------------------------
Static Function CommitMdl(oModel)
Local lRet       := .T.
Local oModelD0A  := oModel:GetModel("A510D0A")
Local oModelD0C  := oModel:GetModel("A510D0C")
Local oModelSld  := oModel:GetModel("A510SLD")
Local oModelD0B  := oModel:GetModel("A510D0B")
Local cAliasQry  := Nil
Local cCtrl      := "01"
Local nJ         := 0
Local nI         := 0
Local nQtdDisp   := 0
Local nRecSB2    := 0
	If oModel:GetOperation() == MODEL_OPERATION_INSERT
		cAliasQry := GetNextAlias()
		BeginSql Alias cAliasQry
			SELECT SB2.R_E_C_N_O_ RECNOSB2
			FROM %Table:SB2% SB2
			WHERE SB2.B2_FILIAL = %xFilial:SB2% 
			AND SB2.B2_COD = %Exp:oModelD0A:GetValue("D0A_PRODUT")%
			AND SB2.B2_LOCAL = %Exp:oModelD0A:GetValue("D0A_LOCAL")%
			AND SB2.%NotDel%
		EndSql
		If (cAliasQry)->(!Eof())
			SB2->(dbGoTo((cAliasQry)->RECNOSB2))
			If SB2->(SimpleLock())
				nRecSB2 := SB2->(Recno())
				//Verifica quantidade disponível novamente
				nQtdDisp := WMSA510SLD(oModelD0A:GetValue("D0A_LOCAL"),oModelD0A:GetValue("D0A_PRODUT"),oModelD0A:GetValue("D0A_LOTECT"),oModelD0A:GetValue("D0A_NUMLOT"),/*dDtValid*/,oModelD0A:GetValue("D0A_OPERAC") == "2",.T.)
				If QtdComp(nQtdDisp) < QtdComp(oModelD0A:GetValue("D0A_QTDMOV"))
					oModel:GetModel():SetErrorMessage( , , oModel:GetId() , '',WMSA51011,STR0041,WmsFmtMsg(STR0042,{{"[VAR01]",Str(nQtdDisp)}}), '', '') //Quantidade informada indisponível. //Informe uma quantidade compatível com a disponível ([VAR01]).
					lRet := .F.
				EndIf
			Else
				oModel:GetModel():SetErrorMessage( , , oModel:GetId() , '',WMSA51012,STR0043,, '', '') //"Produto comprometido em outro processo de Montagem/Desmontagem."
				lRet :=  .F.
			EndIf
		EndIf
		(cAliasQry)->(dbCloseArea())
	EndIf
	If lRet
		Begin Transaction
			If oModel:GetOperation() != MODEL_OPERATION_INSERT
				//Estorna movimentações automáticas de estoque.
				lRet := WMSA510EST(oModel,oModelD0A:GetValue('D0A_DOC'))
			EndIf
			If lRet
				If oModel:GetOperation() != MODEL_OPERATION_DELETE
					// Limpa a grid de Saldos, para considerar os endereços com quantidade preenchida maior que 0 (zero).
					oModelSld:SetNoDeleteLine(.F.)
					For nI := 1 To oModelD0C:Length()
						oModelD0C:GoLine(nI)
						For nJ := 1 To oModelSld:Length()
							oModelSld:GoLine(nJ)
							If oModelSld:GetValue("QUANT") == 0
								oModelSld:DeleteLine()
								Loop
							EndIf
							// Construção da tabela D0B (Transferência)
							If !Empty(oModel:GetModel("A510D0B"):GetValue("D0B_DOC", oModel:GetModel("A510D0B"):Length()) )
								oModel:GetModel("A510D0B"):AddLine()
								oModel:GetModel("A510D0B"):GoLine(oModel:GetModel("A510D0B"):Length())
							EndIf
							oModelD0B:SetValue("D0B_TIPMOV", "1") // Movimento saída (transferência)
							If oModelD0A:GetValue('D0A_OPERAC') == "2" // Desmontagem
								oModelD0B:SetValue("D0B_PRDORI", oModelD0A:GetValue("D0A_PRODUT") )
							Else // Montagem
								oModelD0B:SetValue("D0B_PRDORI", oModelSld:GetValue("PRODUT") )
							EndIf
							oModelD0B:SetValue("D0B_DOC",    oModelD0A:GetValue("D0A_DOC") )
							oModelD0B:SetValue("D0B_LOCAL",  oModelSld:GetValue("LOCAL") )
							oModelD0B:SetValue("D0B_PRODUT", oModelSld:GetValue("PRODUT") )
							oModelD0B:SetValue("D0B_LOTECT", oModelSld:GetValue("LOTECT") )
							oModelD0B:SetValue("D0B_NUMLOT", oModelSld:GetValue("NUMLOT") )
							oModelD0B:SetValue("D0B_QUANT",  oModelSld:GetValue("QUANT") )
							oModelD0B:SetValue("D0B_ENDORI", oModelSld:GetValue("ENDORI") )
							If WmsX312118('D0R','D0R_IDUNIT')
								oModelD0B:SetValue("D0B_IDUNIT", oModelSld:GetValue("IDUNIT") )
							EndIf
							oModelD0B:SetValue("D0B_ENDDES", oModelSld:GetValue("ENDORI"))
							oModelD0B:SetValue("D0B_CTRL"  , cCtrl)
		
							// Construção da tabela D0B (Endereçamento)
							oModel:GetModel("A510D0B"):AddLine()
							oModel:GetModel("A510D0B"):GoLine(oModel:GetModel("A510D0B"):Length())
		
							oModelD0B:SetValue("D0B_TIPMOV", "2") // Movimento saída (transferência)
							If oModelD0A:GetValue('D0A_OPERAC') == "2" // Desmontagem
								oModelD0B:SetValue("D0B_PRDORI", oModelSld:GetValue("PRODUT") )
							Else // Montagem
								oModelD0B:SetValue("D0B_PRDORI", oModelD0A:GetValue("D0A_PRODUT") )
							EndIf
							oModelD0B:SetValue("D0B_DOC",    oModelD0A:GetValue("D0A_DOC") )
							oModelD0B:SetValue("D0B_LOCAL",  oModelSld:GetValue("LOCAL") )
							oModelD0B:SetValue("D0B_PRODUT", oModelSld:GetValue("PRODUT") )
							oModelD0B:SetValue("D0B_LOTECT", oModelSld:GetValue("LOTECT") )
							oModelD0B:SetValue("D0B_NUMLOT", oModelSld:GetValue("NUMLOT") )
							oModelD0B:SetValue("D0B_ENDORI", oModelSld:GetValue("ENDORI") )
							oModelD0B:SetValue("D0B_ENDDES", oModelSld:GetValue("ENDORI") )
							If WmsX312118('D0R','D0R_IDUNIT')
								oModelD0B:SetValue("D0B_IDUNIT", oModelSld:GetValue("IDUNIT") )
							EndIf
							oModelD0B:SetValue("D0B_QUANT",  oModelSld:GetValue("QUANT") )
							oModelD0B:SetValue("D0B_CTRL"  , cCtrl)
							cCtrl := Soma1(cCtrl)
						Next nJ
					Next nI
					oModelSld:SetNoDeleteLine(.T.)
				EndIf
				// Realiza o Commit dos dados D0A e D0B para serem utilizadas em metodos posteriores.
				FwFormCommit(oModel)
				If oModel:GetOperation() == MODEL_OPERATION_INSERT
					lRet := WMSA510AUTO(oModel,oModelD0A:GetValue('D0A_DOC'))
				EndIf
			EndIf
			If !lRet
				Disarmtransaction()
			EndIf
		End Transaction
		// Atualiza tabela de estoque do produto
		If (nRecSB2 > 0)
			If SB2->(Recno()) != nRecSB2
				SB2->(dbGoTo(nRecSB2))
			EndIf
			SB2->(MsUnlock())
		EndIf
	EndIf
Return lRet
//---------------------------------------------------------------
/*/{Protheus.doc} Active
Preenchimento dos modelos
@author felipe.m
@since 25/02/2015
@version 1.0
@param oModel, objeto, (Modelo de dados)
/*/
//---------------------------------------------------------------
Static Function Active(oModel)
Local cLocal    := PadR(MV_PAR01,TamSx3("D0A_LOCAL")[1])
Local cProdut   := PadR(MV_PAR02,TamSx3("D0A_PRODUT")[1])
Local cLoteCt   := PadR(MV_PAR03,TamSx3("D0A_LOTECT")[1])
Local cNumLot   := PadR(MV_PAR04,TamSx3("D0A_NUMLOT")[1])

	If lOperInsert
		oModel:GetModel("A510D0A"):SetValue("D0A_LOCAL" ,cLocal)
		oModel:GetModel("A510D0A"):SetValue("D0A_PRODUT",cProdut)
		oModel:GetModel("A510D0A"):SetValue("D0A_LOTECT",cLoteCt)
		oModel:GetModel("A510D0A"):SetValue("D0A_NUMLOT",cNumLot)
		oModel:GetModel("A510D0A"):SetValue("D0A_OPERAC",Iif(MV_PAR05 == 1,"1","2"))
		oModel:GetModel("A510D0A"):SetValue("D0A_PROCES","1")
	EndIf
	//Carrega grid de saldo dos componentes
	LoadSldPrd()
Return .T.
//---------------------------------------------------------------
/*/{Protheus.doc} LoadSldPrd
Carrega os dados da grid Saldo por endereço quando operação for inclusão
@author Squad WMS
@since 11/09/17
@version 1.0
/*/
//---------------------------------------------------------------
Static Function LoadSldPrd()
Local lRet      := .T.
Local aProds    := {}
Local aArrPrd   := {}
Local aSeek     := {}
Local oModel    := FWModelActive()
Local oProdComp := WMSDTCProdutoComponente():New()
Local cLocal    := PadR(MV_PAR01,TamSx3("D0A_LOCAL")[1])
Local cQuery    := ""
Local cAliasD14 := Nil
Local nI        := 1
Local nJ        := 0
Local nPos      := 0
Local nLinConj  := 0
Local nSaldo    := 0
	oModel:GetModel("A510SLD"):SetNoInsertLine(.F.)
	oModel:GetModel("A510SLD"):SetNoDeleteLine(.F.)
	oModel:GetModel("A510D0C"):SetNoInsertLine(.F.)
	oModel:GetModel("A510D0C"):SetNoDeleteLine(.F.)

	If lOperInsert
		oModel:GetModel("A510SLD"):ClearData()
		oModel:GetModel("A510SLD"):InitLine()
		oModel:GetModel("A510SLD"):GoLine(1)
		
		oModel:GetModel("A510D0C"):ClearData()
		oModel:GetModel("A510D0C"):InitLine()
		oModel:GetModel("A510D0C"):GoLine(1)
	EndIf

	oProdComp:SetPrdOri(oModel:GetModel("A510D0A"):GetValue("D0A_PRODUT"))
	oProdComp:LoadData(3)
	If oProdComp:EstProduto()
		aArrPrd := oProdComp:GetArrProd()
	EndIf
	// Inicialização do array de produtos
	For nJ := 1 To Len(aArrPrd)
		aAdd(aProds, {"",0})
	Next nJ
	// Realisa a busca dos endereços dos componentes do produto pai informado.
	cQuery := " SELECT D14.D14_LOCAL,"
	cQuery +=        " D14.D14_PRODUT,"
	cQuery +=        " D14.D14_LOTECT,"
	cQuery +=        " D14.D14_NUMLOT,"
	cQuery +=        " D14.D14_ENDER,"
	cQuery +=        " D14.D14_IDUNIT,"
	cQuery +=        " (D14.D14_QTDEST - (D14.D14_QTDSPR + D14.D14_QTDEMP + D14.D14_QTDBLQ)) D14_SLD"
	cQuery +=   " FROM "+RetSqlName("D14")+" D14"
	cQuery +=  " WHERE D14.D14_FILIAL = '"+xFilial("D14")+"'"
	cQuery +=    " AND D14.D_E_L_E_T_ = ' '"
	cQuery +=    " AND D14.D14_PRODUT IN ("
	For nJ := 1 To Len(aArrPrd)
		cQuery += "'"+aArrPrd[nJ][1]+"'"
		If nJ != Len(aArrPrd)
			cQuery += ","
		Else
			cQuery += ")"
		EndIf
	Next nJ
	If Iif(lOperInsert,MV_PAR05 == 1,oModel:GetModel("A510D0A"):GetValue("D0A_OPERAC") == '1') // Montagem (pesquisa endereços que o produto origem é o próprio componente).
		cQuery +=" AND D14.D14_PRODUT = D14.D14_PRDORI"
	ElseIf Iif(lOperInsert,MV_PAR05 == 2,oModel:GetModel("A510D0A"):GetValue("D0A_OPERAC") == '2') // Desmontagem (pesquisa endereços dos componentes do produto pai).
		cQuery +=" AND D14.D14_PRODUT <> D14.D14_PRDORI"
	EndIf
	If !Empty(oModel:GetModel("A510D0A"):GetValue("D0A_LOTECT"))
		cQuery +=" AND D14.D14_LOTECT = '"+oModel:GetModel("A510D0A"):GetValue("D0A_LOTECT")+"'"
		cQuery +=" AND D14.D14_NUMLOT = '"+oModel:GetModel("A510D0A"):GetValue("D0A_NUMLOT")+"'"
	EndIf
	cQuery +=    " AND D14.D14_LOCAL = '"+cLocal+"'"
	cQuery +=    " AND (D14.D14_QTDEST - (D14.D14_QTDSPR + D14.D14_QTDEMP + D14.D14_QTDBLQ)) > 0 "
	cQuery +=  " ORDER BY D14.D14_PRODUT, D14.D14_LOTECT, D14.D14_NUMLOT, D14.D14_IDUNIT, D14.D14_ENDER "
	cQuery := ChangeQuery(cQuery)
	cAliasD14 := GetNextAlias()
	DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasD14,.F.,.T.)
	While (cAliasD14)->(!Eof())
		// Montagem da grid de componentes
		If aScan(aProds,{ |x| AllTrim(x[1]) == AllTrim((cAliasD14)->D14_PRODUT) } ) <= 0

			If lOperInsert // Não é necessário carregar o modelo quando operação de upadate/view
				If nI != 1
					oModel:GetModel("A510D0C"):AddLine()
					oModel:GetModel("A510D0C"):GoLine(nI)
				EndIf
			EndIf

			aProds[nI][1] := (cAliasD14)->D14_PRODUT

			If lOperInsert // Não é necessário carregar o modelo quando operação de upadate/view
				oModel:GetModel("A510D0C"):LoadValue("D0C_DOC"   , oModel:GetModel("A510D0A"):GetValue("D0A_DOC") )
				oModel:GetModel("A510D0C"):LoadValue("D0C_DESC"  , Posicione("SB1",1,xFilial("SB1")+aProds[nI][1],"B1_DESC") )
				oModel:GetModel("A510D0C"):LoadValue("D0C_PRODUT", aProds[nI][1] )
				If oModel:GetModel("A510D0A"):GetValue("D0A_OPERAC") == "2"
					oModel:GetModel("A510D0C"):LoadValue("D0C_RATEIO", Posicione("D11",2,xFilial("D11")+aProds[nI][1],"D11_RATEIO") )
				Else
					oModel:GetModel("A510D0C"):LoadValue("D0C_RATEIO", 100 ) // Atribui 100% para os filhos quando operação igual a montagem
				EndIf
			EndIf

			nI++
		EndIf

		oModel:GetModel("A510D0C"):SeekLine({{"D0C_PRODUT",(cAliasD14)->D14_PRODUT}})
		nLinConj := oModel:GetModel("A510D0C"):GetLine()

		nSaldo := (cAliasD14)->D14_SLD
		If WmsX312118('D0R','D0R_IDUNIT')
			aSeek := {{"LOCAL",(cAliasD14)->D14_LOCAL},{"PRODUT",(cAliasD14)->D14_PRODUT},{"LOTECT",(cAliasD14)->D14_LOTECT},{"NUMLOT",(cAliasD14)->D14_NUMLOT},{"ENDORI",(cAliasD14)->D14_ENDER},{"IDUNIT",(cAliasD14)->D14_IDUNIT}}
		Else
			aSeek := {{"LOCAL",(cAliasD14)->D14_LOCAL},{"PRODUT",(cAliasD14)->D14_PRODUT},{"LOTECT",(cAliasD14)->D14_LOTECT},{"NUMLOT",(cAliasD14)->D14_NUMLOT},{"ENDORI",(cAliasD14)->D14_ENDER}}
		EndIf
		If oModel:GetModel("A510SLD"):SeekLine(aSeek)
			// Caso o produto já se encontra no modelo de dados (quando a operação for alteração ou view), preenche o campo virtual D0B_QTDSLD com o devido saldo do endereço;
			// saldo preenchido na inclusão da Montagem/Desmontagem + o restante que há no endereço. Apenas para visualização
			nSaldo += oModel:GetModel("A510SLD"):GetValue("QUANT")
			oModel:GetModel("A510SLD"):LoadValue("QTDSLD", nSaldo )
		ElseIf !lOperView
			If !Empty(oModel:GetModel("A510SLD"):GetValue("LOCAL", oModel:GetModel("A510SLD"):Length()) )
				oModel:GetModel("A510SLD"):AddLine()
				oModel:GetModel("A510SLD"):GoLine(oModel:GetModel("A510SLD"):Length())
			EndIf

			oModel:GetModel("A510SLD"):LoadValue("LOCAL", (cAliasD14)->D14_LOCAL )
			oModel:GetModel("A510SLD"):LoadValue("PRODUT",(cAliasD14)->D14_PRODUT )
			oModel:GetModel("A510SLD"):LoadValue("DESC",  Posicione("SB1",1,xFilial("SB1")+(cAliasD14)->D14_PRODUT,"B1_DESC") )
			oModel:GetModel("A510SLD"):LoadValue("LOTECT",(cAliasD14)->D14_LOTECT )
			oModel:GetModel("A510SLD"):LoadValue("NUMLOT",(cAliasD14)->D14_NUMLOT )
			oModel:GetModel("A510SLD"):LoadValue("QTDSLD",(cAliasD14)->D14_SLD )
			oModel:GetModel("A510SLD"):LoadValue("ENDORI",(cAliasD14)->D14_ENDER )
			If WmsX312118('D0R','D0R_IDUNIT')
				oModel:GetModel("A510SLD"):LoadValue("IDUNIT",(cAliasD14)->D14_IDUNIT )
			EndIf
		EndIf
		// Soma os saldos dos componentes para calcular o saldo do produto pai.
		aProds[nLinConj][2] += nSaldo

		(cAliasD14)->(dbSkip())
	EndDo
	(cAliasD14)->(DbCloseArea())

	If !lOperInsert
		// Caso a operação seja update ou view, preenche o campo virtual D0B_QTDSLD com o devido saldo do endereço,
		// pois nos casos em que este campo está zerado ele ja foi selecionado na inclusão da Montagem/Desmontagem.
		// Apenas para visualização.
		For nI := 1 To oModel:GetModel("A510D0C"):Length()
			oModel:GetModel("A510D0C"):GoLine(nI)

			For nJ := 1 To oModel:GetModel("A510SLD"):Length()
				oModel:GetModel("A510SLD"):GoLine(nJ)
				If oModel:GetModel("A510SLD"):GetValue("QTDSLD") == 0
					oModel:GetModel("A510SLD"):LoadValue("QTDSLD", oModel:GetModel("A510SLD"):GetValue("QUANT") )
					aProds[nI][2] += oModel:GetModel("A510SLD"):GetValue("QUANT")
				Else
					Loop
				EndIf
			Next nJ
			oModel:GetModel("A510SLD"):GoLine(1)
		Next nI
	EndIf

	//Carrega quantidade disponível para a montagem ou desmontagem
	oModel:GetModel("A510D0A"):LoadValue("D0A_QTDSLD", WMSA510SLD(oModel:GetModel("A510D0A"):GetValue("D0A_LOCAL"),oModel:GetModel("A510D0A"):GetValue("D0A_PRODUT"),oModel:GetModel("A510D0A"):GetValue("D0A_LOTECT"),oModel:GetModel("A510D0A"):GetValue("D0A_NUMLOT"),/*dDtValid*/,oModel:GetModel("A510D0A"):GetValue("D0A_OPERAC") == "2",.T.))

	oModel:GetModel("A510SLD"):SetNoInsertLine(.T.)
	oModel:GetModel("A510SLD"):SetNoDeleteLine(.T.)

	oModel:GetModel("A510D0C"):SetNoInsertLine(.T.)
	oModel:GetModel("A510D0C"):SetNoDeleteLine(.T.)

	oModel:GetModel("A510D0C"):GoLine(1)
	If lOperView
		oModel:LMODIFY := .F.
		oModel:LVALID := .T.
	EndIf
Return lRet
//---------------------------------------------------------------
/*/{Protheus.doc} SetQtdMult
Preenchimento automático das quantidades multiplas de cada
componente na grid de saldos por endereços do primeiro endereço
encontrado.
@author felipe.m
@since 25/02/2015
@version 1.0
/*/
//---------------------------------------------------------------
Static Function SetQtdMult()
Local oModel    := FWModelActive()
Local oView     := FWViewActive()
Local oModelD0A := oModel:GetModel("A510D0A")
Local oModelD0C := oModel:GetModel("A510D0C")
Local oModelSLD := oModel:GetModel("A510SLD")
Local cPrdOri   := oModelD0A:GetValue("D0A_PRODUT")
Local nQtdSld   := oModelD0A:GetValue("D0A_QTDSLD")
Local nQtdMov   := oModelD0A:GetValue("D0A_QTDMOV")
Local cPrdCmp   := ""
Local nI        := 0
Local nX        := 0
Local nAuxQtd   := 0
Local nQtdUtilz := 0
	If QtdComp(nQtdMov) <= QtdComp(0) .Or. QtdComp(nQtdSld) < QtdComp(nQtdMov)
		Return .F.
	EndIf
	For nI := 1 To oModelD0C:Length()
		oModelD0C:GoLine(nI)
		cPrdCmp := oModelD0C:GetValue("D0C_PRODUT",nI)
		oModelD0C:LoadValue("QTDCNJ", ( nQtdMov * Posicione("D11",2,xFilial("D11")+cPrdCmp+cPrdOri,"D11_QTMULT") ))
		nAuxQtd := 0
		nQtdUtilz := 0
		For nX := 1 To oModelSLD:Length()
			oModelSLD:GoLine(nX)
			oModelSLD:SetValue("QUANT", 0 )
		Next nX
		For nX := 1 To oModelSLD:Length()
			oModelSLD:GoLine(nX)
			nAuxQtd := oModelD0C:GetValue("QTDCNJ",nI) - nQtdUtilz
			If nAuxQtd == 0
				Exit
			EndIf
			If oModelSLD:GetValue("QTDSLD",nX) <= nAuxQtd
				oModelSLD:SetValue("QUANT", oModelSLD:GetValue("QTDSLD",nX) )
				nQtdUtilz += oModelSLD:GetValue("QTDSLD",nX)
			Else
				oModelSLD:SetValue("QUANT", nAuxQtd )
				nQtdUtilz += nAuxQtd
			EndIf
		Next nX
		oModelSLD:GoLine(1)
	Next nI
	oModelD0C:GoLine(1)
	oView:Refresh()
Return .T.
//---------------------------------------------------------------
/*/{Protheus.doc} SetQtdDig
Recalcula as quantidades quando alterado o valor do saldo na
grid de saldos por endereços dos componentes.
@author felipe.m
@since 25/02/2015
@version 1.0
@param nValAnt, numérico, (Valor anterior)
@param oModel, objeto, (Modelo de dados)
/*/
//---------------------------------------------------------------
Static Function SetQtdDig(nValAnt,oModel)
	// Não deixa informar uma quantidade maior que o saldo.
	If oModel:GetModel("A510SLD"):GetValue("QTDSLD") < oModel:GetModel("A510SLD"):GetValue('QUANT')
		Return .F.
	Endif
	oModel:GetModel("A510D0C"):SeekLine( { {"D0C_PRODUT",oModel:GetModel("A510SLD"):GetValue('PRODUT')} } )
	If nValAnt < oModel:GetModel("A510SLD"):GetValue('QUANT')
		oModel:GetModel("A510D0C"):LoadValue( 'QTDPRE', oModel:GetModel("A510D0C"):GetValue('QTDPRE') + (oModel:GetModel("A510SLD"):GetValue('QUANT') - nValAnt) )
	ElseIf nValAnt > oModel:GetModel("A510SLD"):GetValue('QUANT')
		oModel:GetModel("A510D0C"):LoadValue( 'QTDPRE', oModel:GetModel("A510D0C"):GetValue('QTDPRE') - (nValAnt - oModel:GetModel("A510SLD"):GetValue('QUANT')) )
	EndIf
Return .T.
//---------------------------------------------------------------
/*/{Protheus.doc} ValidEnder
Validação dos campos.
@author felipe.m
@since 25/02/2015
@version 1.0
@param oModel, objeto, (Modelo de dados)
@param cField, character, (Campo posicionado)
/*/
//---------------------------------------------------------------
Static Function ValidField(oModel,cField)
Local lRet := .T.
	If  cField == "QUANT"
		lRet := oModel:GetModel("A510SLD"):GetValue("QTDSLD") >= oModel:GetModel("A510SLD"):GetValue("QUANT")
	EndIf
Return lRet
//---------------------------------------------------------------
/*/{Protheus.doc} LoadGrdComp
Carrega a grid temporária dos componentes quando a operação não
é inclusão.
@author felipe.m
@since 25/02/2015
@version 1.0
@param oModel, objeto, (Modelo de dados)
/*/
//---------------------------------------------------------------
Static Function LoadGrdD0C(oModel)
Local aLoad     := {}
Local oModelD0A := oModel:GetModel("A510D0A")
Local cAliasD11 := GetNextAlias()
	
	BeginSql Alias cAliasD11
		SELECT D11.D11_PRDCMP,
				D11.D11_QTMULT,
				D11.D11_RATEIO
		FROM %Table:D11% D11
		WHERE D11.D11_FILIAL = %xFilial:D11%
		AND D11.D11_PRODUT = %Exp:oModelD0A:GetValue("D0A_PRODUT")%
		AND D11.D11_PRDORI = %Exp:oModelD0A:GetValue("D0A_PRODUT")%
		AND D11.%NotDel%
	EndSql
	Do While (cAliasD11)->(!Eof())
		aAdd(aLoad,{0, {xFilial("D0C"),;
						oModelD0A:GetValue("D0A_DOC"),;
						(cAliasD11)->D11_PRDCMP,;
						Posicione("SB1",1,xFilial("SB1")+(cAliasD11)->D11_PRDCMP,"B1_DESC"),;
						"",;
						"",;
						(cAliasD11)->D11_RATEIO,;
						(cAliasD11)->D11_QTMULT,;
						0}})
		(cAliasD11)->(dbSkip())
	EndDo
	(cAliasD11)->(dbCloseArea())
Return aLoad
//---------------------------------------------------------------
/*/{Protheus.doc} LoadGrdSld
Carrega a grid temporária de saldos quando a operação não é
inclusão.
@author felipe.m
@since 06/03/2015
@version 1.0
@param oModel, objeto, (Modelo de dados)
/*/
//---------------------------------------------------------------
Static Function LoadGrdSld(oModel)
Local aLoad     := {}
Local aAreaAnt  := GetArea()
Local cQuery    := ""
Local cAliasSld := ""

	cQuery := " SELECT D0B.D0B_LOCAL,"
	cQuery +=        " D0B.D0B_PRODUT,"
	cQuery +=        " D0B.D0B_LOTECT,"
	cQuery +=        " D0B.D0B_NUMLOT,"
	cQuery +=        " D0B.D0B_ENDORI,"
	If WmsX312118('D0R','D0R_IDUNIT')
		cQuery +=        " D0B.D0B_IDUNIT,"
	EndIf
	cQuery +=        " D0B.D0B_QUANT"
	cQuery +=   " FROM "+RetSqlName("D0B")+" D0B "
	cQuery +=  " INNER JOIN (SELECT D0B_CTRL "
	cQuery +=                " FROM "+RetSqlName("D0B")+" D0B "
	cQuery +=               " WHERE D0B.D0B_FILIAL = '"+xFilial("D0B")+"' "
	cQuery +=                 " AND D0B.D_E_L_E_T_ = ' ' "
	cQuery +=                 " AND D0B.D0B_TIPMOV = '2' "
	cQuery +=                 " AND D0B.D0B_PRODUT = '"+oModel:GetModel("A510D0C"):GetValue("D0C_PRODUT")+"' "
	cQuery +=                 " AND D0B.D0B_DOC    = '"+oModel:GetModel("A510D0A"):GetValue("D0A_DOC")+"' ) D0B2 "
	cQuery +=     " ON D0B2.D0B_CTRL  = D0B.D0B_CTRL "
	cQuery +=  " WHERE D0B.D0B_FILIAL = '"+xFilial("D0B")+"' "
	cQuery +=    " AND D0B.D0B_TIPMOV = '1' "
	cQuery +=    " AND D0B.D0B_PRODUT = '"+oModel:GetModel("A510D0C"):GetValue("D0C_PRODUT")+"' "
	cQuery +=    " AND D0B.D0B_DOC    = '"+oModel:GetModel("A510D0A"):GetValue("D0A_DOC")+"' "
	cQuery +=    " AND D0B.D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery(cQuery)
	cAliasSld := GetNextAlias()
	DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasSld,.F.,.T.)
	Do While (cAliasSld)->(!Eof())
		If WmsX312118('D0R','D0R_IDUNIT')
			aAdd(aLoad,{0, {(cAliasSld)->D0B_LOCAL,;
							(cAliasSld)->D0B_PRODUT,;
							Posicione("SB1",1,xFilial("SB1")+(cAliasSld)->D0B_PRODUT,"B1_DESC"),;
							(cAliasSld)->D0B_LOTECT,;
							(cAliasSld)->D0B_NUMLOT,;
							(cAliasSld)->D0B_ENDORI,;
							0,;
							(cAliasSld)->D0B_IDUNIT,;
							(cAliasSld)->D0B_QUANT}})
		Else
			aAdd(aLoad,{0, {(cAliasSld)->D0B_LOCAL,;
							(cAliasSld)->D0B_PRODUT,;
							Posicione("SB1",1,xFilial("SB1")+(cAliasSld)->D0B_PRODUT,"B1_DESC"),;
							(cAliasSld)->D0B_LOTECT,;
							(cAliasSld)->D0B_NUMLOT,;
							(cAliasSld)->D0B_ENDORI,;
							0,;
							(cAliasSld)->D0B_QUANT}})
		EndIf
		(cAliasSld)->(dbSkip())
	EndDo
	(cAliasSld)->(dbCloseArea())
	RestArea(aAreaAnt)
Return aLoad
//--------------------------------------
/*/{Protheus.doc} WMSA510AUTO
Realiza movimentações automáticas de estoque.
@author Amanda Rosa Vieira
@since 07/06/2017
@version 1.0
/*/
//--------------------------------------
Function WMSA510AUTO(oModel,cDocumento)
Local lRet      := .T.
Local cAliasD0B := Nil
Local oMntItem  := WMSDTCMontagemDesmontagemItens():New()
Local oEstEnder := WMSDTCEstoqueEndereco():New()
Local oMovEstEnd:= WMSDTCMovimentosEstoqueEndereco():New()
Local oOrdServ  := WMSDTCOrdemServico():New()
	//Faz movimentações SD3  para as montagens/desmontagens
	cAliasD0B := GetNextAlias()
	BeginSql Alias cAliasD0B
		SELECT D0B.D0B_PRODUT,
				D0B.D0B_DOC
		FROM %Table:D0B% D0B
		WHERE D0B.D0B_FILIAL = %xFilial:D0B%
		AND D0B.D0B_DOC = %Exp:cDocumento%
		AND D0B.D0B_TIPMOV = %Exp:Iif(D0A->D0A_OPERAC == "1","2","1")%
		AND D0B.%NotDel%
	EndSql
	If (cAliasD0B)->(!Eof())
		oOrdServ:SetDocto((cAliasD0B)->D0B_DOC)
		oOrdServ:oProdLote:SetProduto((cAliasD0B)->D0B_PRODUT)
		If !(lRet := oOrdServ:AtuMovSD3(.T.))
			oModel:GetModel():SetErrorMessage( , , oModel:GetId() , '', WMSA51010,STR0036,,'','')// Não foi possível realizar as movimentações de estoque.
		EndIf
	EndIf
	(cAliasD0B)->(DbCloseArea())
	If lRet
		//Realiza saídas dos endereços origem
		cAliasD0B := GetNextAlias()
		BeginSql Alias cAliasD0B
			SELECT D0B.R_E_C_N_O_ RESNOD0B
			FROM %Table:D0B% D0B
			WHERE D0B.D0B_FILIAL = %xFilial:D0B%
			AND D0B.D0B_DOC = %Exp:cDocumento%
			AND D0B.D0B_TIPMOV = '1'
			AND D0B.%NotDel%
		EndSql
		Do While (cAliasD0B)->(!Eof())
			If oMntItem:GoToD0B((cAliasD0B)->RESNOD0B)
				oEstEnder:oEndereco:SetArmazem(oMntItem:oMntEndOri:GetArmazem())
				oEstEnder:oEndereco:SetEnder(oMntItem:oMntEndOri:GetEnder())
				oEstEnder:oProdLote:SetArmazem(oMntItem:oProdLote:GetArmazem()) // Armazem
				oEstEnder:oProdLote:SetPrdOri(oMntItem:oProdLote:GetPrdOri())   // Produto Origem
				oEstEnder:oProdLote:SetProduto(oMntItem:oProdLote:GetProduto()) // Componente
				oEstEnder:oProdLote:SetLoteCtl(oMntItem:oProdLote:GetLoteCtl()) // Lote do produto principal que deverá ser o mesmo no componentes
				oEstEnder:oProdLote:SetNumLote(oMntItem:oProdLote:GetNumlote()) // Sub-Lote do produto principal que deverá ser o mesmo no componentes
				oEstEnder:oProdLote:SetNumSer(oMntItem:oProdLote:GetNumSer())   // Numero de serie
				oEstEnder:SetIdUnit(oMntItem:GetIdUnit())
				oEstEnder:LoadData()
				oEstEnder:SetQuant(oMntItem:GetQuant())
				// Seta o bloco de código para informações do documento para o Kardex
				oEstEnder:SetBlkDoc({|oMovEstEnd|oMovEstEnd:SetDocto(cDocumento),oMovEstEnd:SetOrigem("D0A")})
				// Seta o bloco de código para informações do movimento para o Kardex
				oEstEnder:SetBlkMov({|oMovEstEnd|oMovEstEnd:SetIdUnit(oMntItem:GetIdUnit())})
				// Realiza Entrada Armazem Estoque por Endereço
				oEstEnder:UpdSaldo('999',.T. /*lEstoque*/,.F. /*lEntPrev*/,.F. /*lSaiPrev*/,.F. /*lEmpenho*/,.F. /*lBloqueio*/,.F./*lEmpPrev*/,.T./*lMovEstEnd*/)
			EndIf		
			(cAliasD0B)->(DbSkip())
		EndDo
		(cAliasD0B)->(DbCloseArea())
	
		//Realiza entradas dos endereços destino
		cAliasD0B := GetNextAlias()
		BeginSql Alias cAliasD0B
			SELECT D0B.R_E_C_N_O_ RESNOD0B
			FROM %Table:D0B% D0B
			WHERE D0B.D0B_FILIAL = %xFilial:D0B%
			AND D0B.D0B_DOC = %Exp:cDocumento%
			AND D0B.D0B_TIPMOV = '2'
			AND D0B.%NotDel%
		EndSql
		Do While (cAliasD0B)->(!Eof())
			If oMntItem:GoToD0B((cAliasD0B)->RESNOD0B)
				oEstEnder:oEndereco:SetArmazem(oMntItem:oMntEndDes:GetArmazem())
				oEstEnder:oEndereco:SetEnder(oMntItem:oMntEndDes:GetEnder())
				oEstEnder:oProdLote:SetArmazem(oMntItem:oProdLote:GetArmazem()) // Armazem
				oEstEnder:oProdLote:SetPrdOri(oMntItem:oProdLote:GetPrdOri())   // Produto Origem
				oEstEnder:oProdLote:SetProduto(oMntItem:oProdLote:GetProduto()) // Componente
				oEstEnder:oProdLote:SetLoteCtl(oMntItem:oProdLote:GetLoteCtl()) // Lote do produto principal que deverá ser o mesmo no componentes
				oEstEnder:oProdLote:SetNumLote(oMntItem:oProdLote:GetNumlote()) // Sub-Lote do produto principal que deverá ser o mesmo no componentes
				oEstEnder:oProdLote:SetNumSer(oMntItem:oProdLote:GetNumSer())   // Numero de serie
				oEstEnder:SetIdUnit(oMntItem:GetIdUnit())
				oEstEnder:LoadData()
				oEstEnder:SetQuant(oMntItem:GetQuant())
				// Seta o bloco de código para informações do documento para o Kardex
				oEstEnder:SetBlkDoc({|oMovEstEnd|oMovEstEnd:SetDocto(cDocumento),oMovEstEnd:SetOrigem("D0A")})
				// Seta o bloco de código para informações do movimento para o Kardex
				oEstEnder:SetBlkMov({|oMovEstEnd|oMovEstEnd:SetIdUnit(oMntItem:GetIdUnit())})
				// Realiza Entrada Armazem Estoque por Endereço
				oEstEnder:UpdSaldo('499',.T. /*lEstoque*/,.F. /*lEntPrev*/,.F. /*lSaiPrev*/,.F. /*lEmpenho*/,.F. /*lBloqueio*/,.F./*lEmpPrev*/,.T./*lMovEstEnd*/)
			EndIf		
			(cAliasD0B)->(DbSkip())
		EndDo
		(cAliasD0B)->(DbCloseArea())
	EndIf
	FreeObj(oMntItem)
	oMovEstEnd:Destroy()
Return lRet
//--------------------------------------
/*/{Protheus.doc} WMSA510EST
Estorna movimentações automáticas de estoque.
@author Amanda Rosa Vieira
@since 07/06/2017
@version 1.0
/*/
//--------------------------------------
Function WMSA510EST(oModel,cDocumento)
Local lRet      := .T.
Local cAliasD0B := Nil
Local cAliasD13 := Nil
Local oMntItem  := WMSDTCMontagemDesmontagemItens():New()
Local oEstEnder := WMSDTCEstoqueEndereco():New()
Local oMovEstEnd:= WMSDTCMovimentosEstoqueEndereco():New()
Local oOrdServ  := WMSDTCOrdemServico():New()

	//Estorna movimentações SD3
	oOrdServ:SetDocto(cDocumento)
	If !(lRet := oOrdServ:UndoMovSD3())
		oModel:GetModel():SetErrorMessage( , , oModel:GetId() , '', WMSA51012,STR0038,,'','')//Não foi possível estornar as movimentações de estoque.
	EndIf
	//Realiza saídas dos endereços origem
	If lRet
		cAliasD0B := GetNextAlias()
		BeginSql Alias cAliasD0B
			SELECT D0B.R_E_C_N_O_ RESNOD0B
			FROM %Table:D0B% D0B
			WHERE D0B.D0B_FILIAL = %xFilial:D0B%
			AND D0B.D0B_DOC = %Exp:cDocumento%
			AND D0B.D0B_TIPMOV = '2'
			AND D0B.%NotDel%
		EndSql
		Do While (cAliasD0B)->(!Eof()) .And. lRet
			If oMntItem:GoToD0B((cAliasD0B)->RESNOD0B)
				oEstEnder:oEndereco:SetArmazem(oMntItem:oMntEndDes:GetArmazem())
				oEstEnder:oEndereco:SetEnder(oMntItem:oMntEndDes:GetEnder())
				oEstEnder:oProdLote:SetArmazem(oMntItem:oProdLote:GetArmazem()) // Armazem
				oEstEnder:oProdLote:SetPrdOri(oMntItem:oProdLote:GetPrdOri())   // Produto Origem
				oEstEnder:oProdLote:SetProduto(oMntItem:oProdLote:GetProduto()) // Componente
				oEstEnder:oProdLote:SetLoteCtl(oMntItem:oProdLote:GetLoteCtl()) // Lote do produto principal que deverá ser o mesmo no componentes
				oEstEnder:oProdLote:SetNumLote(oMntItem:oProdLote:GetNumlote()) // Sub-Lote do produto principal que deverá ser o mesmo no componentes
				oEstEnder:oProdLote:SetNumSer(oMntItem:oProdLote:GetNumSer())   // Numero de serie
				oEstEnder:SetIdUnit(oMntItem:GetIdUnit())
				oEstEnder:LoadData()
				If oEstEnder:ConsultSld(.F./*lEntPrevista*/,.T./*lSaiPrevista*/,.T./*lEmpenho*/,/*lBloqueado*/) < oMntItem:GetQuant()
					oModel:GetModel():SetErrorMessage( , , oModel:GetId() , '', WMSA51015, WmsFmtMsg(STR0037,{{"[VAR01]",oMntItem:oProdLote:GetProduto()},{"[VAR02]",oMntItem:oProdLote:GetLoteCtl()}}),,'','')//Saldo do produto/lote [VAR01]/[VAR02] indisponível para o estorno.
					lRet := .F.
				Else
					oEstEnder:SetQuant(oMntItem:GetQuant())
					// Seta o bloco de código para informações do documento para o Kardex
					oEstEnder:SetBlkDoc({|oMovEstEnd|oMovEstEnd:SetDocto(cDocumento),oMovEstEnd:SetOrigem("D0A")})
					// Seta o bloco de código para informações do movimento para o Kardex
					oEstEnder:SetBlkMov({|oMovEstEnd|oMovEstEnd:SetIdUnit(oMntItem:GetIdUnit()),oMovEstEnd:SetlUsaCal(.F.)})
					// Realiza Entrada Armazem Estoque por Endereço
					oEstEnder:UpdSaldo('999',.T. /*lEstoque*/,.F. /*lEntPrev*/,.F. /*lSaiPrev*/,.F. /*lEmpenho*/,.F. /*lBloqueio*/,.F./*lEmpPrev*/,.T./*lMovEstEnd*/)
				EndIf
			EndIf
			(cAliasD0B)->(DbSkip())
		EndDo
		(cAliasD0B)->(DbCloseArea())
		If lRet
			//Realiza entradas dos endereços destino
			cAliasD0B := GetNextAlias()
			BeginSql Alias cAliasD0B
				SELECT D0B.R_E_C_N_O_ RESNOD0B
				FROM %Table:D0B% D0B
				WHERE D0B.D0B_FILIAL = %xFilial:D0B%
				AND D0B.D0B_DOC = %Exp:cDocumento%
				AND D0B.D0B_TIPMOV = '1'
				AND D0B.%NotDel%
			EndSql
			Do While (cAliasD0B)->(!Eof())
				If oMntItem:GoToD0B((cAliasD0B)->RESNOD0B)
					oEstEnder:oEndereco:SetArmazem(oMntItem:oMntEndOri:GetArmazem())
					oEstEnder:oEndereco:SetEnder(oMntItem:oMntEndOri:GetEnder())
					oEstEnder:oProdLote:SetArmazem(oMntItem:oProdLote:GetArmazem()) // Armazem
					oEstEnder:oProdLote:SetPrdOri(oMntItem:oProdLote:GetPrdOri())   // Produto Origem
					oEstEnder:oProdLote:SetProduto(oMntItem:oProdLote:GetProduto()) // Componente
					oEstEnder:oProdLote:SetLoteCtl(oMntItem:oProdLote:GetLoteCtl()) // Lote do produto principal que deverá ser o mesmo no componentes
					oEstEnder:oProdLote:SetNumLote(oMntItem:oProdLote:GetNumlote()) // Sub-Lote do produto principal que deverá ser o mesmo no componentes
					oEstEnder:oProdLote:SetNumSer(oMntItem:oProdLote:GetNumSer())   // Numero de serie
					oEstEnder:SetIdUnit(oMntItem:GetIdUnit())
					oEstEnder:LoadData()
					oEstEnder:SetQuant(oMntItem:GetQuant())
					// Seta o bloco de código para informações do documento para o Kardex
					oEstEnder:SetBlkDoc({|oMovEstEnd|oMovEstEnd:SetDocto(cDocumento),oMovEstEnd:SetOrigem("D0A")})
					// Seta o bloco de código para informações do movimento para o Kardex
					oEstEnder:SetBlkMov({|oMovEstEnd|oMovEstEnd:SetIdUnit(oMntItem:GetIdUnit()),oMovEstEnd:SetlUsaCal(.F.)})
					// Realiza Entrada Armazem Estoque por Endereço
					oEstEnder:UpdSaldo('499',.T. /*lEstoque*/,.F. /*lEntPrev*/,.F. /*lSaiPrev*/,.F. /*lEmpenho*/,.F. /*lBloqueio*/,.F./*lEmpPrev*/,.T./*lMovEstEnd*/)
				EndIf		
				(cAliasD0B)->(DbSkip())
			EndDo
			(cAliasD0B)->(DbCloseArea())
		EndIf
		If lRet
			// Verifica os movimentos da ordem de serviço origem para desconsiderar
			// no cálculo de estoque 
			If lRet .And. WmsX312118("D13","D13_USACAL")
				cAliasD13 := GetNextAlias()
				BeginSql Alias cAliasD13
					SELECT D13.R_E_C_N_O_ RECNOD13
					FROM %Table:D13% D13
					WHERE D13.D13_FILIAL = %xFilial:D13%
					AND D13.D13_DOC = %Exp:cDocumento%
					AND D13.D13_ORIGEM = 'D0A'
					AND D13.D13_USACAL <> '2'
					AND D13.%NotDel%
				EndSql
				Do While (cAliasD13)->(!Eof())
					D13->(dbGoTo((cAliasD13)->RECNOD13))
					RecLock("D13",.F.)
					D13->D13_USACAL = '2'
					D13->(MsUnLock())
					(cAliasD13)->(dbSkip())
				EndDo
				(cAliasD13)->(dbCloseArea())
			EndIf
		EndIf
	EndIf
	FreeObj(oMntItem)
	oMovEstEnd:Destroy()
Return lRet
//-----------------------------------------------------------------------------------------------
// Utilizado para carregar a quantidade disponível para a montagem ou desmontagem da estrutura //
//-----------------------------------------------------------------------------------------------
Function WMSA510SLD(cArmazem,cPrdOri,cLoteCtl,cNumLote,dDtValid,lDesmont,lEstrutura)
Local nQtdDisp   := 0
Local oEstEnder  := WMSDTCEstoqueEndereco():New()
Local lD14SemSB8 := .T.
Default lEstrutura := .F.
Default cLoteCtl   := ""
Default cNumLote   := ""
Default dDtValid   := StoD("")

	
	//Para Novo WMS
	//Verifica se o produto controla rastro e possui SB8. Usado para ler o saldo da D14 caso não tenha SB8
	//Essa regra existe para o caso em que o produto não controlava rastro e foi alterado para controlar.
	lD14SemSB8 := WmsD14SSB8(cArmazem, cPrdOri)   
	
	oEstEnder:oProdLote:SetPrdOri(cPrdOri)
	oEstEnder:oProdLote:SetArmazem(cArmazem)
	If !Empty(cLoteCtl)
		oEstEnder:oProdLote:SetLotectl(cLoteCtl)
	EndIf
	If !Empty(cNumLote)
		oEstEnder:oProdLote:SetNumLote(cNumLote)
	EndIf
	If !Empty(dDtValid)
		oEstEnder:oProdLote:SetDtValid(dDtValid)
	EndIf
	nQtdDisp := Iif(lEstrutura,Int(oEstEnder:GetSldOrig(lDesmont,.T.,,lD14SemSB8)),oEstEnder:GetSldOrig(lDesmont,.T.,,lD14SemSB8))

Return nQtdDisp
/*/{Protheus.doc} A510VldArm
Verifica se o armazém informado é o armazém de qualidade e impede a operação.
@author amanda.vieira
@since 14/04/2020
@version 1.0
/*/
Static Function A510VldArm()
Local lRet := .T.
Local cLocalCQ := SuperGetMV("MV_CQ",.F.,"")
	If !Empty(cLocalCQ) .And. AllTrim(cLocalCQ) == AllTrim(MV_PAR01)
		WmsMessage(STR0047,WMSA51016,5/*MSG_HELP*/) //Não permitida a montagem ou desmontagem de estruturas no armazém de qualidade.
		lRet := .F.
	EndIf
Return lRet
