#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "WMSA520.CH"
#INCLUDE "FWEDITPANEL.CH"

#DEFINE WMSA52001 "WMSA52001"
#DEFINE WMSA52002 "WMSA52002"
#DEFINE WMSA52003 "WMSA52003"
#DEFINE WMSA52004 "WMSA52004"
#DEFINE WMSA52005 "WMSA52005"
#DEFINE WMSA52006 "WMSA52006"
#DEFINE WMSA52007 "WMSA52007"
#DEFINE WMSA52008 "WMSA52008"
#DEFINE WMSA52009 "WMSA52009"
#DEFINE WMSA52010 "WMSA52010"
#DEFINE WMSA52011 "WMSA52011"
#DEFINE WMSA52012 "WMSA52012"
#DEFINE WMSA52013 "WMSA52013"
#DEFINE WMSA52014 "WMSA52014"
#DEFINE WMSA52015 "WMSA52015"
#DEFINE WMSA52016 "WMSA52016"
#DEFINE WMSA52017 "WMSA52017"
#DEFINE WMSA52018 "WMSA52018"
#DEFINE WMSA52019 "WMSA52019"
#DEFINE WMSA52020 "WMSA52020"
#DEFINE WMSA52021 "WMSA52021"
#DEFINE WMSA52022 "WMSA52022"
#DEFINE WMSA52023 "WMSA52023"
#DEFINE WMSA52024 "WMSA52024"
#DEFINE WMSA52025 "WMSA52025"
#DEFINE WMSA52026 "WMSA52026"
#DEFINE WMSA52027 "WMSA52027"
#DEFINE WMSA52028 "WMSA52028"

Static lOperInsert := .F.
Static lOperView   := .F.
Static lOperDelete := .F.

//--------------------------------------------------------------
/*/{Protheus.doc} WMSA520
Rotina de Troca de produtos
@author felipe.m
@since 25/02/2015
@version 1.0
/*/
//--------------------------------------------------------------
Function WMSA520()
	Local oBrwD0A := Nil
	Private oEstEnder := WMSDTCEstoqueEndereco():New()
	Private oSeqAbast := WMSDTCSequenciaAbastecimento():New()

	// Permite efetuar validações, apresentar mensagem e abortar o programa quando desejado
	If !WMSChkPrg(FunName(),"1")
		Return Nil
	EndIf

	oBrwD0A := FWMBrowse():New()
	oBrwD0A:SetAlias("D0A")
	oBrwD0A:SetMenuDef("WMSA520")
	oBrwD0A:SetFilterDefault("@ D0A_PROCES = '2'")
	oBrwD0A:SetDescription(STR0003) // Troca de produto WMS
	oBrwD0A:Activate()
	// Destroy objetos
	oEstEnder:Destroy()
	oSeqAbast:Destroy()
	
Return
//--------------------------------------------------------------
/*/{Protheus.doc} MenuDef
MenuDef
@author felipe.m
@since 25/02/2015
@version 1.0
/*/
//--------------------------------------------------------------
Static Function MenuDef()
Private aRotina := {}
	ADD OPTION aRotina TITLE STR0004 ACTION 'PesqBrw'       OPERATION MODEL_OPERATION_VIEW   ACCESS 0 // Pesquisar
	ADD OPTION aRotina TITLE STR0005 ACTION 'WMSA520MEN(2)' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 // Visualizar
	ADD OPTION aRotina TITLE STR0006 ACTION 'WMSA520MEN(3)' OPERATION MODEL_OPERATION_INSERT ACCESS 0 // Incluir
	ADD OPTION aRotina TITLE STR0008 ACTION 'WMSA520MEN(4)' OPERATION MODEL_OPERATION_DELETE ACCESS 0 // Excluir
Return aRotina
//--------------------------------------------------------------
/*/{Protheus.doc} WMSA520MEN
WMSA520MEN
@author felipe.m
@since 25/02/2015
@version 1.0
/*/
//--------------------------------------------------------------
Function WMSA520MEN(nPos)
Local lRet       := .T.
Local aRotina    := MenuDef()
Local cArmazem   := ""
Local cProduto   := ""
Local cLoteCtl   := ""
Local cNumLote   := ""
Local cEndereco  := ""
Local nOperation := 0
Local oFwSX1Util := FwSX1Util():New()
Local aPergunte	 := {}

Private nTpWMSA520	:= 1

	nOperation  := aRotina[nPos][4]
	lOperInsert := .F.
	lOperView   := .F.
	lOperDelete := .F.

	Do Case
		Case nOperation == MODEL_OPERATION_INSERT
	
			//Valida pergunta do WMSA520
			oFwSX1Util:AddGroup("WMSA520")
			oFwSX1Util:SearchGroup()
			aPergunte := oFwSX1Util:GetGroup("WMSA520")

			lRet := Pergunte("WMSA520",.T.)
			lOperInsert := .T.
			cArmazem  	:= MV_PAR01
			cProduto  	:= MV_PAR02
			cLoteCtl  	:= MV_PAR03
			cNumLote  	:= MV_PAR04
			cEndereco 	:= MV_PAR05
			If Len(aPergunte[2]) > 5 //--Suavização para casos em que o dicionario não contenha esta pergunta 
				nTpWMSA520	:= MV_PAR06
			EndIf
			If lRet
				lRet := A520VldPrd(cArmazem,cProduto,cLoteCtl,cNumLote,cEndereco) .And. A520VldArm()
			EndIf
		Case nOperation == MODEL_OPERATION_VIEW
			lOperView := .T.
		Case nOperation == MODEL_OPERATION_DELETE
			lOperDelete := .T.
			lRet := VldDel520()
	EndCase
Return Iif(lRet,FWExecView(aRotina[nPos][1],"WMSA520",nOperation,,{ || .T. },{ || .T. },0,,{ || .T. },,, ),.F.)
//--------------------------------------------------------------
/*/{Protheus.doc} ModelDef
ModelDef
@author felipe.m
@since 25/02/2015
@version 1.0
/*/
//--------------------------------------------------------------
Static Function ModelDef()
Local aColsSx3 := {}
Local oModel   := Nil
Local oStrD0A  := FWFormStruct(1,'D0A')
Local oStrD0B  := FWFormStruct(1,'D0B')
Local oStrD0C  := FWFormStruct(1,'D0C')
Local bValid   := { |oModel,cField| ValidField(cField) }
Local cDocto := ""

	oModel := MPFormModel():New('WMSA520',,{|oModel| ValidModel(oModel) },{|oModel| CommitMdl(oModel) })
	If !lOperDelete
		oStrD0A:AddField(buscarSX3("D0A_QTDMOV",,aColsSX3) ,aColsSX3[1],'D0A_QTDSLD','N',aColsSX3[3],aColsSX3[4],Nil,{||.F.}/*bWhen*/,Nil,.F.,,.F.,.T./*lNoUpd*/,.F.)
	EndIf
	oStrD0A:SetProperty('D0A_DOC'   ,MODEL_FIELD_INIT ,{|| cDocto := GetSX8Num('DCF','DCF_DOCTO'),IIf(__lSX8,ConfirmSX8(),),cDocto })
	oStrD0A:SetProperty('D0A_DTMOV' ,MODEL_FIELD_INIT ,{|| dDataBase })
	oStrD0A:SetProperty('D0A_QTDMOV',MODEL_FIELD_VALID,{|| SetQtd() })
	oStrD0A:SetProperty('D0A_ENDER',MODEL_FIELD_OBRIGAT,.F.)
	oStrD0A:SetProperty('D0A_QTDMOV',MODEL_FIELD_OBRIGAT,.T.)
	oStrD0A:SetProperty('D0A_MOVAUT',MODEL_FIELD_INIT ,FWBuildFeature(STRUCT_FEATURE_INIPAD, "'1'"))

	oModel:AddFields('A520D0A',,oStrD0A)
	oModel:SetDescription(STR0003) // Montagem/Desmontagem Produto WMS
	oModel:GetModel('A520D0A'):SetDescription(STR0003) // Montagem/Desmontagem Produto WMS

	oStrD0C:AddField(buscarSX3("DCF_QUANT",,aColsSX3) ,aColsSX3[1],'QUANT' ,'N',aColsSX3[3],aColsSX3[4],Nil,{||.T.}/*bWhen*/,Nil,.T.,,.F.,.F./*lNoUpd*/,.F.)
	oStrD0C:SetProperty('D0C_PRODUT',MODEL_FIELD_VALID,bValid)

	oStrD0C:SetProperty('D0C_LOTECT',MODEL_FIELD_WHEN,FwBuildFeature(STRUCT_FEATURE_WHEN,'WMS520WFld(A,B)'))
	oStrD0C:SetProperty('D0C_NUMLOT',MODEL_FIELD_WHEN,FwBuildFeature(STRUCT_FEATURE_WHEN,'WMS520WFld(A,B)'))

	oModel:AddGrid('A520D0C','A520D0A',oStrD0C,/*bLinePre*/,{|oModelD0C| PosValid(oModelD0C) },/*bPre*/,/*bLinePost*/,/*bLoad*/)
	oModel:SetRelation("A520D0C", {{"D0C_FILIAL","xFilial('D0C')"},{"D0C_DOC","D0A_DOC"}} )
	oModel:GetModel('A520D0C'):SetDescription(STR0010) // Produtos
	
	oModel:AddGrid('A520D0B','A520D0A',oStrD0B)
	oModel:GetModel('A520D0B'):SetDescription(STR0009) // Saldo por Endereço
	oModel:SetRelation("A520D0B", {{"D0B_FILIAL","xFilial('D0B')"},{"D0B_DOC","D0A_DOC"}} )
	oModel:GetModel('A520D0B'):SetOptional(.T.)

	oModel:SetActivate({|oModel| Iif(!lOperDelete .And. !lOperView, Active(oModel), .T.) })

	oModel:SetVldActivate({|oModel| WMS520Actv(oModel)})

Return oModel
//--------------------------------------------------------------
/*/{Protheus.doc} ViewDef
ViewDef
@author felipe.m
@since 25/02/2015
@version 1.0
/*/
//--------------------------------------------------------------
Static Function ViewDef()
Local aColsSX3 := {}
Local oModel   := ModelDef()
Local oStrD0A  := FWFormStruct(2,'D0A')
Local oStrD0C  := FWFormStruct(2,'D0C')
Local oView    := Nil

	oView := FWFormView():New()
	oView:SetModel(oModel)

	If !lOperDelete .And. !lOperView
		oStrD0A:AddField('D0A_QTDSLD','07',buscarSX3("D0A_QTDMOV",STR0011,aColsSX3)  ,aColsSX3[1],Nil,'GET',aColsSX3[2],Nil,Nil/*cLookUp*/,.F./*lCanChange*/,Nil,Nil,Nil,Nil,Nil,.F.) // Qtd. Saldo"
	EndIf
	oStrD0A:RemoveField('D0A_PROCES')
	oStrD0A:RemoveField('D0A_MOVAUT')
	oStrD0A:SetProperty('D0A_DOC'   ,MVC_VIEW_ORDEM,'01')
	oStrD0A:SetProperty('D0A_LOCAL' ,MVC_VIEW_ORDEM,'02')
	oStrD0A:SetProperty('D0A_PRODUT',MVC_VIEW_ORDEM,'03')
	oStrD0A:SetProperty('D0A_DESC'  ,MVC_VIEW_ORDEM,'04')
	oStrD0A:SetProperty('D0A_LOTECT',MVC_VIEW_ORDEM,'05')
	oStrD0A:SetProperty('D0A_NUMLOT',MVC_VIEW_ORDEM,'06')
	oStrD0A:SetProperty('D0A_QTDMOV',MVC_VIEW_ORDEM,'08')
	oStrD0A:SetProperty('D0A_OPERAC',MVC_VIEW_ORDEM,'09')
	oStrD0A:SetProperty('D0A_ENDER',MVC_VIEW_CANCHANGE,.F.)
	oStrD0A:SetProperty('D0A_PRODUT',MVC_VIEW_CANCHANGE,.F.)
	If !lOperInsert
		oStrD0A:SetProperty('D0A_QTDMOV',MVC_VIEW_CANCHANGE,.F.)
	EndIf

	oView:AddField('VA520D0A',oStrD0A,'A520D0A')
	oView:SetViewProperty('VA520D0A','SETLAYOUT',{FF_LAYOUT_VERT_DESCR_TOP,5})
	oView:SetDescription(STR0003) // Montagem/Desmontagem Produto WMS

	If !lOperDelete .And. !lOperView
		// cIdField,cOrdem,cTitulo,cDescric,aHelp,cType,cPicture,bPictVar,cLookUp,lCanChange,cFolder,cGroup,aComboValues,nMaxLenCombo,cIniBrow,lVirtual,cPictVar,lInsertLine,nWidth,lIsDeleted
		oStrD0C:AddField('QUANT' ,'06',buscarSX3("DCF_QUANT",STR0012,aColsSX3)    ,aColsSX3[1],Nil,'GET',aColsSX3[2],Nil,Nil  /*cLookUp*/,.T./*lCanChange*/,Nil,Nil,Nil,Nil,Nil,.F.) // Qtd. Movimento"
	EndIf
	oStrD0C:SetProperty('D0C_LOTECT',MVC_VIEW_ORDEM,'03')
	oStrD0C:SetProperty('D0C_NUMLOT',MVC_VIEW_ORDEM,'04')
	oStrD0C:RemoveField('D0C_DOC')
	oStrD0C:SetProperty('D0C_PRODUT',MVC_VIEW_ORDEM,'01')
	oStrD0C:SetProperty('D0C_DESC'  ,MVC_VIEW_ORDEM,'02')
	oStrD0C:SetProperty('D0C_RATEIO',MVC_VIEW_ORDEM,'07')
	oView:AddGrid('VA520D0C',oStrD0C,'A520D0C')
	oView:EnableTitleView('VA520D0C', STR0010) // Produtos

	oView:CreateHorizontalBox('HORIZONTAL_UP',40)
	oView:CreateHorizontalBox('HORIZONTAL_DOWN',60)

	oView:AddUserButton(STR0040,'',{|| WMS520Estr(oModel,oView) }) //"1o.Nivel"

	oView:SetOwnerView('VA520D0A' ,'HORIZONTAL_UP')
	oView:SetOwnerView('VA520D0C','HORIZONTAL_DOWN')
Return oView
//--------------------------------------------------------------
/*/{Protheus.doc} ValidModel
Validação dos dados
@author felipe.m
@since 25/02/2015
@version 1.0
@param oModel, objeto, (Modelo de dados)
/*/
//--------------------------------------------------------------
Static Function ValidModel(oModel)
Local lRet   	 := .T.
Local oModelD0A  := oModel:GetModel("A520D0A")
Local oModelD0C  := oModel:GetModel("A520D0C")
Local oView      := Nil
Local oMntItem   := WMSDTCMontagemDesmontagemItens():New()
Local nI     	 := 0
Local nTotal 	 := 0
Local nQtdDisp   := 0
Local cAliasSB8  := ""
Local cAliasSB2  := ""
Local cAliasD0B  := ""
Local lConsVenc  := lOperDelete //Quando e estorno nao valida lote vencido
			
	If !lOperDelete .And. !lOperView
		//Verifica quantidade disponível novamente
		oEstEnder:ClearData()
		oEstEnder:oProdLote:SetArmazem(oModelD0A:GetValue("D0A_LOCAL"))
		oEstEnder:oProdLote:SetPrdOri(oModelD0A:GetValue("D0A_PRODUT"))
		oEstEnder:oProdLote:SetProduto(oModelD0A:GetValue("D0A_PRODUT"))
		oEstEnder:oProdLote:SetLoteCtl(oModelD0A:GetValue("D0A_LOTECT"))
		oEstEnder:oProdLote:SetNumLote(oModelD0A:GetValue("D0A_NUMLOT"))
		oEstEnder:oProdLote:LoadData()
		
		oEstEnder:oEndereco:SetArmazem(oModelD0A:GetValue("D0A_LOCAL"))
		oEstEnder:oEndereco:SetEnder(oModelD0A:GetValue("D0A_ENDER"))
		oEstEnder:oEndereco:LoadData()
		
		nQtdDisp := oEstEnder:ConsultSld(,.T.,.T.,.T.)
		If QtdComp(nQtdDisp) < QtdComp(oModelD0A:GetValue("D0A_QTDMOV"))
			//Recarrega saldo do produto
			LoadSldPrd()
			oModel:GetModel():SetErrorMessage( , , oModel:GetId() , '',WMSA52009,STR0023,WmsFmtMsg(STR0024,{{"[VAR01]",Str(nQtdDisp)}}), '', '') //Quantidade informada indisponível. //Informe uma quantidade compatível com a disponível ([VAR01]).
			oModelD0A:LoadValue("D0A_QTDSLD",nQtdDisp)
			oView := FWViewActive()
			If !Empty(oView)
				oView:Refresh()
			EndIf	
			Return .F.
		EndIf
		oSeqAbast:SetArmazem(oModelD0A:GetValue('D0A_LOCAL'))
		oSeqAbast:SetProduto(oModelD0A:GetValue("D0A_PRODUT"))
		oSeqAbast:SetEstFis(oEstEnder:oEndereco:GetEstFis())
		If !oSeqAbast:LoadData(2)
			oModel:GetModel():SetErrorMessage( , , oModel:GetId() , '', WMSA52005, WmsFmtMsg(STR0019,{{"[VAR01]",oModelD0A:GetValue('D0A_PRODUT')}}), STR0020, '', '')  // O produto [VAR01] não possui a estrutura cadastrada do endereço destino informado. //Informe outro endereço ou cadastre a estrutura para o produto.
			lRet := .F.
		EndIf
		If lRet
			If !(oSeqAbast:GetTipoEnd() == '4')
				oModel:GetModel():SetErrorMessage( , , oModel:GetId() , '', WMSA52005, WmsFmtMsg(STR0026,{{"[VAR01]",AllTrim(oEstEnder:oEndereco:GetEstFis())}}), WmsFmtMsg(STR0027,{{"[VAR01]",AllTrim(oModelD0A:GetValue("D0A_PRODUT"))},{"[VAR02]",AllTrim(oEndereco:GetEstFis())}}), '', '')  // Estrutura física [VAR01] não permite misturar produtos. // Informe outro endereço ou configure no casdatro de sequencia de abastecimento do produto [VAR01] a estrutura fisica [VAR02] o tupo de endereçamento que permita misturar produtos.
				lRet := .F.
			EndIf
		EndIf
		
		nTotal := 0
		For nI := 1 To oModelD0C:Length()
			oModelD0C:GoLine(nI)
			If !oModelD0C:IsDeleted() .And. oModelD0C:GetValue('QUANT') < 0
				oModel:GetModel():SetErrorMessage( , , oModel:GetId() , '', WMSA52026, STR0041, STR0042, '', '') // "Quantidade inválida","Não é possível informar quantidade negativa."
				lRet := .F.
				Exit
			EndIf

			If IntWMS(oModelD0C:GetValue('D0C_PRODUT'))
				oSeqAbast:SetArmazem(oModelD0A:GetValue('D0A_LOCAL'))
				oSeqAbast:SetProduto(oModelD0C:GetValue('D0C_PRODUT'))
				oSeqAbast:SetEstFis(oEstEnder:oEndereco:GetEstFis())
				If !oSeqAbast:LoadData(2)
					oModel:GetModel():SetErrorMessage( , , oModel:GetId() , '', WMSA52012, WmsFmtMsg(STR0019,{{"[VAR01]",oModelD0C:GetValue('D0C_PRODUT')}}), STR0020, '', '') //O produto [VAR01] não possui a estrutura cadastrada do endereço destino informado. //Informe outro endereço ou cadastre a estrutura para o produto.
					lRet := .F.
					Exit
				EndIf
				If lRet
					If !(oSeqAbast:GetTipoEnd() == '4')
						oModel:GetModel():SetErrorMessage( , , oModel:GetId() , '', WMSA52013, WmsFmtMsg(STR0026,{{"[VAR01]",AllTrim(oEstEnder:oEndereco:GetEstFis())}}), WmsFmtMsg(STR0027,{{"[VAR01]",AllTrim(oModelD0C:GetValue('D0C_PRODUT'))},{"[VAR02]",AllTrim(oEndereco:GetEstFis())}}), '', '')  // Estrutura física [VAR01] não permite misturar produtos. // Informe outro endereço ou configure no casdatro de sequencia de abastecimento do produto [VAR01] a estrutura fisica [VAR02] o tupo de endereçamento que permita misturar produtos.
						lRet := .F.
					EndIf
				EndIf
			EndIf
			
			nTotal += oModelD0C:GetValue("D0C_RATEIO")
		Next nI

		If lRet .And. nTotal != 100
			oModel:GetModel():SetErrorMessage( , , oModel:GetId() , '', WMSA52002, STR0017, STR0018, '', '') // Rateio inválido. // Quantidade informada para o rateio deve somar 100%.
			lRet := .F.
		EndIf
	EndIf
	//Valida saldo para estorno
	If lOperDelete
		cAliasD0B := GetNextAlias()
		BeginSql Alias cAliasD0B
			SELECT D0B.R_E_C_N_O_ RESNOD0B
			  FROM %Table:D0B% D0B
			 WHERE D0B.D0B_FILIAL = %xFilial:D0B%
			   AND D0B.D0B_DOC = %Exp:oModelD0A:GetValue('D0A_DOC')%
			   AND D0B.D0B_TIPMOV = '2'
			   AND D0B.%NotDel%
		EndSql
		Do While (cAliasD0B)->(!Eof()) .And. lRet
			If oMntItem:GoToD0B((cAliasD0B)->RESNOD0B)
				If !Empty(oMntItem:oProdLote:GetLoteCtl()) .And. Rastro(oMntItem:oProdLote:GetPrdOri())
					cAliasSB8 := GetNextAlias()
					BeginSql Alias cAliasSB8
						SELECT B8_FILIAL,B8_PRODUTO,B8_LOCAL,B8_DTVALID,B8_LOTECTL,B8_NUMLOTE,B8_SALDO,B8_SALDO2,B8_DATA,B8_QACLASS,B8_QACLAS2,B8_EMPENHO,B8_EMPENH2,B8_QEMPPRE,B8_QEPRE2,SB8.R_E_C_N_O_ RECNOSB8
						  FROM %Table:SB8% SB8
						 WHERE SB8.B8_FILIAL = %xFilial:SB8%
						   AND SB8.B8_PRODUTO = %Exp:oMntItem:oProdLote:GetPrdOri()%
						   AND SB8.B8_LOCAL = %Exp:oMntItem:oMntEndDes:GetArmazem()%
						   AND SB8.B8_LOTECTL = %Exp:oMntItem:oProdLote:GetLoteCtl()%
						   AND SB8.B8_NUMLOTE = %Exp:oMntItem:oProdLote:GetNumlote()%
						   AND SB8.%NotDel%
					EndSql
					If (cAliasSB8)->(!EoF())
						TCSetField(cAliasSB8,"B8_DTVALID","D",8,0)
						TCSetField(cAliasSB8,"B8_DATA"   ,"D",8,0)

						SB8->(DbGoTo((cAliasSB8)->RECNOSB8))
						If SB8Saldo(/*lBaixaEmp*/,lConsVenc,.T./*lConsClas*/,/*lSegUM*/,cAliasSB8,/*lEmpPrevisto*/,/*lConsulta*/,dDataBase) < oMntItem:GetQuant()
							oModel:GetModel():SetErrorMessage( , , oModel:GetId() , '', WMSA52024, WmsFmtMsg(STR0038,{{"[VAR01]",oMntItem:oProdLote:GetProduto()},{"[VAR02]",oMntItem:oProdLote:GetLoteCtl()}}),,'','') // Saldo (SB8) do produto/lote [VAR01]/[VAR02] indisponível para o estorno.
							lRet := .F.
						EndIf
					EndIf
					(cAliasSB8)->(DbCloseArea())
				Else
					cAliasSB2 := GetNextAlias()
					BeginSql Alias cAliasSB2
						SELECT SB2.R_E_C_N_O_ RECNOSB2
						  FROM %Table:SB2% SB2
						 WHERE SB2.B2_FILIAL = %xFilial:SB2%
						   AND SB2.B2_COD = %Exp:oMntItem:oProdLote:GetPrdOri()%
						   AND SB2.B2_LOCAL = %Exp:oMntItem:oMntEndDes:GetArmazem()%
						   AND SB2.%NotDel%
					EndSql
					If (cAliasSB2)->(!EoF())
						SB2->(DbGoTo((cAliasSB2)->RECNOSB2))
						If SaldoSB2(,.F.,,.F.,,,,,.F.,,.F.) < oMntItem:GetQuant()
							oModel:GetModel():SetErrorMessage( , , oModel:GetId() , '', WMSA52025, WmsFmtMsg(STR0039,{{"[VAR01]",oMntItem:oProdLote:GetProduto()}}),,'','') // Saldo (SB2) do produto [VAR01] indisponível para o estorno.
							lRet := .F.
						EndIf
					EndIf
					(cAliasSB2)->(DbCloseArea())
				EndIf
			EndIf
			(cAliasD0B)->(DbSkip())
		EndDo
		(cAliasD0B)->(DbCloseArea())
	EndIf
Return lRet
//--------------------------------------------------------------
/*/{Protheus.doc} CommitMdl
Criação dos serviços
@author felipe.m
@since 25/02/2015
@version 1.0
@param oModel, objeto, (Modelo de dados)
/*/
//--------------------------------------------------------------
Static Function CommitMdl(oModel)
Local lRet       := .T.
Local oModelD0A  := oModel:GetModel("A520D0A")
Local oModelD0C  := oModel:GetModel("A520D0C")
Local oModelD0B  := oModel:GetModel("A520D0B")
Local oEstEnder  := WMSDTCEstoqueEndereco():New()
Local cCtrl      := "01"
Local cLote      := ""
Local cNumLote   := ""
Local cAliasQry  := Nil
Local nJ         := 0
Local nI         := 0
Local nRecSB2    := 0
Local nQtdDisp   := 0
Local cDocto	 := ""
Local bNewDoc	 := { || cDocto := GetSX8Num('DCF','DCF_DOCTO'),IIf(__lSX8,ConfirmSX8(),),cDocto }

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
				oEstEnder:ClearData()
				oEstEnder:oProdLote:SetArmazem(oModelD0A:GetValue("D0A_LOCAL"))
				oEstEnder:oProdLote:SetPrdOri(oModelD0A:GetValue("D0A_PRODUT"))
				oEstEnder:oProdLote:SetProduto(oModelD0A:GetValue("D0A_PRODUT"))
				oEstEnder:oProdLote:SetLoteCtl(oModelD0A:GetValue("D0A_LOTECT"))
				oEstEnder:oProdLote:SetNumLote(oModelD0A:GetValue("D0A_NUMLOT"))
				oEstEnder:oProdLote:LoadData()
				
				oEstEnder:oEndereco:SetArmazem(oModelD0A:GetValue("D0A_LOCAL"))
				oEstEnder:oEndereco:SetEnder(oModelD0A:GetValue("D0A_ENDER"))
				oEstEnder:oEndereco:LoadData()
				nQtdDisp := oEstEnder:ConsultSld(,.T.,.T.,.T.)
				If QtdComp(nQtdDisp) < QtdComp(oModelD0A:GetValue("D0A_QTDMOV"))
					oModel:GetModel():SetErrorMessage( , , oModel:GetId() , '',WMSA52010,STR0023,WmsFmtMsg(STR0024,{{"[VAR01]",Str(nQtdDisp)}}), '', '') //Quantidade informada indisponível. //Informe uma quantidade compatível com a disponível ([VAR01]).
					lRet := .F.
				EndIf
			Else
				oModel:GetModel():SetErrorMessage( , , oModel:GetId() , '',WMSA52011,STR0025,, '', '') //"Produto comprometido em outro processo de Montagem/Desmontagem."
				lRet := .F.
			EndIf
		EndIf
	EndIf
	If lRet
		Begin Transaction
			If oModel:GetOperation() != MODEL_OPERATION_INSERT
				//Estorna movimentações automáticas de estoque.
				lRet := WMSA520EST(oModel,oModelD0A:GetValue('D0A_DOC'))
			EndIf
			If lRet 
				If oModel:GetOperation() == MODEL_OPERATION_UPDATE
					For nI := 1 To oModelD0B:Length()
						oModelD0B:GoLine(nI)
						oModelD0B:DeleteLine()
					Next nI
					oModelD0B:InitLine()
					oModelD0B:GoLine(1)
				EndIf
			EndIf
			If lRet
				If oModel:GetOperation() != MODEL_OPERATION_DELETE
					// Limpa a grid de Saldos, para considerar os endereços com quantidade preenchida maior que 0 (zero).
					// Construção da tabela D0B (Transferência)
					If !Empty(oModelD0B:GetValue("D0B_DOC", oModelD0B:Length()) )
						oModelD0B:AddLine()
						oModelD0B:GoLine(oModelD0B:Length())
					EndIf
	
					oModelD0B:SetValue("D0B_TIPMOV", "1") // Movimento saída (transferência)
					oModelD0B:SetValue("D0B_PRDORI", oModelD0A:GetValue("D0A_PRODUT") )
					oModelD0B:SetValue("D0B_DOC",    oModelD0A:GetValue("D0A_DOC") )
					oModelD0B:SetValue("D0B_LOCAL",  oModelD0A:GetValue("D0A_LOCAL") )
					oModelD0B:SetValue("D0B_PRODUT", oModelD0A:GetValue("D0A_PRODUT") )
					oModelD0B:SetValue("D0B_LOTECT", oModelD0A:GetValue("D0A_LOTECT") )
					oModelD0B:SetValue("D0B_NUMLOT", oModelD0A:GetValue("D0A_NUMLOT") )
					oModelD0B:SetValue("D0B_QUANT",  oModelD0A:GetValue("D0A_QTDMOV") )
					oModelD0B:SetValue("D0B_ENDORI", oModelD0A:GetValue("D0A_ENDER") )
					oModelD0B:SetValue("D0B_ENDDES", oModelD0A:GetValue("D0A_ENDER") )
					oModelD0B:SetValue("D0B_CTRL"  , cCtrl)
	
					cCtrl := Soma1(cCtrl)
					cCtrl := '01'
					For nJ := 1 To oModelD0C:Length()
						oModelD0C:GoLine(nJ)
						If oModelD0C:IsDeleted()
							Loop
						EndIf
						oModelD0C:SetValue("D0C_DOC", oModelD0A:GetValue("D0A_DOC") )
						//Encontra próximo lote/sublote
						If Rastro(oModelD0C:GetValue("D0C_PRODUT"),"S") .And. (Empty(oModelD0C:GetValue("D0C_LOTECT")) .Or. Empty(oModelD0C:GetValue("D0C_NUMLOT")))
							cNumLote := NextLote(oModelD0A:GetValue("D0A_PRODUT"),"S")
							cLote    := "AUTO"+cNumLote
						ElseIf Rastro(oModelD0C:GetValue("D0C_PRODUT")) .And. Empty(oModelD0C:GetValue("D0C_LOTECT"))
							cLote := NextLote(oModelD0A:GetValue("D0A_PRODUT"),"L")
							cNumLote := ""
						Else 
							cLote    := oModelD0C:GetValue("D0C_LOTECT")
							cNumLote := oModelD0C:GetValue("D0C_NUMLOT")
						EndIf
						// Construção da tabela D0B (Endereçamento)
						oModelD0B:AddLine()
						oModelD0B:GoLine(oModelD0B:Length())
						oModelD0B:SetValue("D0B_TIPMOV", "2") // Movimento Entrada (endereçamento)
						oModelD0B:SetValue("D0B_PRDORI", oModelD0C:GetValue("D0C_PRODUT"))
						oModelD0B:SetValue("D0B_DOC",    oModelD0A:GetValue("D0A_DOC"))
						oModelD0B:SetValue("D0B_LOCAL",  oModelD0A:GetValue("D0A_LOCAL"))
						oModelD0B:SetValue("D0B_PRODUT", oModelD0C:GetValue("D0C_PRODUT"))
						oModelD0B:SetValue("D0B_LOTECT", cLote)
						oModelD0B:SetValue("D0B_NUMLOT", cNumLote)
						oModelD0B:SetValue("D0B_ENDORI", oModelD0A:GetValue("D0A_ENDER"))
						oModelD0B:SetValue("D0B_ENDDES", oModelD0A:GetValue("D0A_ENDER"))
						oModelD0B:SetValue("D0B_QUANT",  oModelD0C:GetValue("QUANT"))
						oModelD0B:SetValue("D0B_CTRL",   cCtrl)
						// Atualiza as informações do lote na D0C
						oModelD0C:LoadValue("D0C_LOTECT", cLote)
						oModelD0C:LoadValue("D0C_NUMLOT", cNumLote)
						cCtrl := Soma1(cCtrl)
					Next nJ
				EndIf
				// Realiza o Commit dos dados D0A e D0B para serem utilizadas em metodos posteriores.
				If oModel:GetOperation() == MODEL_OPERATION_DELETE .Or. oModel:VldData()

					//--Verifica se o numero do documento setado foi utilizado por outro processo, em caso positivo, redefine até encontrar um numero disponivel
					If oModel:GetOperation() != MODEL_OPERATION_DELETE
						D0A->( DbSetOrder(1) )
						Do While D0A->( DbSeek( xFilial("D0A") + oModelD0A:GetValue('D0A_DOC') ) )
							oModelD0A:SetValue( 'D0A_DOC', Eval( bNewDoc ) )						 
						EndDo

						If !Empty( cDocto )
							WmsMessage(WmsFmtMsg(STR0050,{{"[VAR01]",AllTrim(cDocto)}}),WMSA52028) //"O numero deste documento foi alterado para [VAR01] porque o numero anterior foi utilizado por outro processo!" 
						EndIf
					EndIf

					lRet := FwFormCommit(oModel)
				Else
					lRet := .F.
					oModel:GetModel():SetErrorMessage( , , oModel:GetId() , '', WMSA52027,cValToChar(oModel:GetErrorMessage()[4]) + ' - '+;
																						  cValToChar(oModel:GetErrorMessage()[5]) + ' - '+;
																						  cValToChar(oModel:GetErrorMessage()[6]),,'','') 
				EndIf
				If lRet .And. oModel:GetOperation() == MODEL_OPERATION_INSERT
					lRet := WMSA520AUT(oModel,oModelD0A:GetValue('D0A_DOC'))
				EndIf
			EndIf
			If !lRet
				Disarmtransaction()
			EndIf
		End Transaction
		If (nRecSB2 > 0)
			If SB2->(Recno()) != nRecSB2
				SB2->(dbGoTo(nRecSB2))
			EndIf
			SB2->(MsUnlock())
		EndIf
	EndIf
Return lRet
//--------------------------------------------------------------
/*/{Protheus.doc} Active
Preenchimento dos modelos
@author felipe.m
@since 25/02/2015
@version 1.0
@param oModel, objeto, (Modelo de dados)
/*/
//--------------------------------------------------------------
Static Function Active(oModel)
Local oModelD0A := oModel:GetModel("A520D0A")
Local cArmazem  := PadR(MV_PAR01,TamSx3("D0A_LOCAL")[1])
Local cProduto  := PadR(MV_PAR02,TamSx3("D0A_PRODUT")[1])
Local cLoteCtl  := PadR(MV_PAR03,TamSx3("D0A_LOTECT")[1])
Local cNumLote  := PadR(MV_PAR04,TamSx3("D0A_NUMLOT")[1])
Local cEndereco := PadR(MV_PAR05,TamSx3("D0A_ENDER")[1])

	If lOperInsert
		oModelD0A:SetValue("D0A_LOCAL" ,cArmazem)
		oModelD0A:SetValue("D0A_ENDER", cEndereco)
		oModelD0A:SetValue("D0A_PRODUT",cProduto)
		oModelD0A:SetValue("D0A_LOTECT",cLoteCtl)
		oModelD0A:SetValue("D0A_NUMLOT",cNumLote)
		oModelD0A:SetValue("D0A_OPERAC","2") // troca de produto (Desmontagem)
		oModelD0A:SetValue("D0A_PROCES","2") // Produto
	EndIf
	//Carrega grid de saldo do produto
	LoadSldPrd()
Return .T.

/*/{Protheus.doc} WMS520Actv
	(Não permite chamadas externas para alterar a troca de lotes)
	@type  Function
	@author Equipe WMS
	@since 27/03/2024
	@param oModel, objeto, modelo
	@return lRet, boolean, trava modelo
	@see (DLOGWMSMSP-16107)
	/*/
Function WMS520Actv(oModel)
	Local lRet := .T.
	If oModel:GetOperation() = MODEL_OPERATION_UPDATE
		lRet := .F.
		oModel:SetErrorMessage(oModel:GetID(),"",oModel:GetID(),"","SetVldActivate",STR0043) //"Não é permitida a alteração da troca de lotes."
		lRet := .F.
	EndIf
Return lRet

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
Local oModel    := FWModelActive()
Local oView     := FWViewActive()
Local oModelD0A := oModel:GetModel("A520D0A")
Local oModelD0C := oModel:GetModel("A520D0C")

	//Verifica quantidade disponível novamente
	oEstEnder:ClearData()
	oEstEnder:oProdLote:SetArmazem(oModelD0A:GetValue("D0A_LOCAL"))
	oEstEnder:oProdLote:SetPrdOri(oModelD0A:GetValue("D0A_PRODUT"))
	oEstEnder:oProdLote:SetProduto(oModelD0A:GetValue("D0A_PRODUT"))
	oEstEnder:oProdLote:SetLoteCtl(oModelD0A:GetValue("D0A_LOTECT"))
	oEstEnder:oProdLote:SetNumLote(oModelD0A:GetValue("D0A_NUMLOT"))
	oEstEnder:oProdLote:LoadData()
	
	oEstEnder:oEndereco:SetArmazem(oModelD0A:GetValue("D0A_LOCAL"))
	oEstEnder:oEndereco:SetEnder(oModelD0A:GetValue("D0A_ENDER"))
	oModelD0A:LoadValue("D0A_QTDSLD", oEstEnder:ConsultSld(,.T.,.T.,.T.))
	oModelD0C:GoLine(1)
	If lOperView .And. !Empty(oView)
		oView:Refresh()
	EndIf
	If lOperView
		oModel:LMODIFY := .F.
		oModel:LVALID := .T.
	EndIf
Return lRet
//--------------------------------------------------------------
/*/{Protheus.doc} SetQtd
Preenchimento automático das quantidades nos primeiros endereços
encontrados.
@author felipe.m
@since 25/02/2015
@version 1.0
/*/
//--------------------------------------------------------------
Static Function SetQtd()
Local oModel    := FWModelActive()
Local oView     := FWViewActive()
Local nQtdMov   := oModel:GetModel("A520D0A"):GetValue("D0A_QTDMOV")
	If nQtdMov <= 0 .Or. oModel:GetModel("A520D0A"):GetValue("D0A_QTDSLD") < nQtdMov
		Return .F.
	EndIf
	If !empty(oView)
		oView:Refresh()
		oModel:GetModel("A520D0C"):GoLine(1)
	EndIf
Return .T.
//--------------------------------------------------------------
/*/{Protheus.doc} ValidField
Validação dos campos.
@author felipe.m
@since 25/02/2015
@version 1.0
@param oModel, objeto, (Descrição do parâmetro)
@param cField, character, (Descrição do parâmetro)
/*/
//--------------------------------------------------------------
Static Function ValidField(cField)
Local lRet      := .T.
Local oModel    := FwModelActive()
Local oModelD0A := oModel:GetModel("A520D0A")
Local oModelD0C := oModel:GetModel("A520D0C")
Local lWmsDes   := SuperGetMV("MV_WMSDPES", .F.,.F.) // Permitir desmontagem de produtos com WMS para produtos sem controle WMS.

	If cField == "D0C_PRODUT"
		lRet := !Empty(oModelD0C:GetValue("D0C_PRODUT"))
		
		If lRet .And. (AllTrim(oModelD0C:GetValue("D0C_PRODUT")) == AllTrim(oModelD0A:GetValue("D0A_PRODUT")))
			oModel:GetModel():SetErrorMessage( , , oModel:GetId() , '',WMSA52018, STR0028,STR0029, '', '') // Produto igual ao selecionado para troca. // Informe um produto diferente do selecionado para troca
			lRet := .F.
		EndIf
		If IntWMS(oModelD0C:GetValue("D0C_PRODUT"))
			If lRet
				//Carrega informações
				oEstEnder:ClearData()
				oEstEnder:oProdLote:SetArmazem(oModelD0A:GetValue('D0A_LOCAL'))
				oEstEnder:oProdLote:SetPrdOri(oModelD0C:GetValue("D0C_PRODUT"))
				oEstEnder:oProdLote:SetProduto(oModelD0C:GetValue("D0C_PRODUT"))
				oEstEnder:oProdLote:SetLoteCtl(oModelD0C:GetValue("D0C_LOTECT"))
				oEstEnder:oProdLote:SetNumLote(oModelD0C:GetValue("D0C_NUMLOT"))
				If oEstEnder:oProdLote:oProduto:LoadData()
					If !oEstEnder:oProdLote:oProduto:IsCtrWms()
						oModel:GetModel():SetErrorMessage( , , oModel:GetId() , '',WMSA52017, STR0021, "", '', '') // Produto não controla WMS.
						lRet := .F.
					EndIf
					If lRet .And. oEstEnder:oProdLote:oProduto:oProdComp:IsDad()
						oModel:GetModel():SetErrorMessage( , , oModel:GetId() , '', WMSA52016,STR0030,"", '', '') // Produto informado possui estrutura de armazenamento. Operação não permitida!
						lRet := .F.
					EndIf
				Else
					oModel:GetModel():SetErrorMessage( , , oModel:GetId() , '',WMSA52019,STR0031, "", '', '') //Produto não cadatrado.
					lRet := .F.
				EndIf
			EndIf
			If lRet 
				oEstEnder:oEndereco:SetArmazem(oModelD0A:GetValue('D0A_LOCAL'))
				oEstEnder:oEndereco:SetEnder(oModelD0A:GetValue('D0A_ENDER'))
				oEstEnder:oEndereco:LoadData()
				
				oSeqAbast:SetArmazem(oModelD0A:GetValue('D0A_LOCAL'))
				oSeqAbast:SetProduto(oModelD0C:GetValue('D0C_PRODUT'))
				oSeqAbast:SetEstFis(oEstEnder:oEndereco:GetEstFis())
				If !oSeqAbast:LoadData(2)
					oModel:GetModel():SetErrorMessage( , , oModel:GetId() , '', WMSA52014, WmsFmtMsg(STR0048,{{"[VAR01]",oModelD0C:GetValue('D0C_PRODUT')},{"[VAR02]",oEstEnder:oEndereco:GetEstFis()}}), STR0049, '', '') //"O produto [VAR01] não possui a estrutura [VAR02] cadastrada na sequência de abastecimento."//"Realize o cadastro da estrutura para o produto."
					lRet := .F.
				EndIf
				If lRet
					If !(oSeqAbast:GetTipoEnd() == '4')
						oModel:GetModel():SetErrorMessage( , , oModel:GetId() , '', WMSA52015, WmsFmtMsg(STR0026,{{"[VAR01]",AllTrim(oEstEnder:oEndereco:GetEstFis())}}), WmsFmtMsg(STR0027,{{"[VAR01]",AllTrim(oModelD0C:GetValue("D0C_PRODUT"))},{"[VAR02]",AllTrim(oEstEnder:oEndereco:GetEstFis())}}), '', '')  // Estrutura física [VAR01] não permite misturar produtos. // Informe outro endereço ou configure no casdatro de sequencia de abastecimento do produto [VAR01] a estrutura fisica [VAR02] o tipo de endereçamento que permita misturar produtos.
						lRet := .F.
					EndIf
				EndIf
			EndIf
			If lRet
				If !oEstEnder:oProdLote:HasRastro()
					If !Empty(oModelD0C:GetValue("D0C_LOTECT")) .Or. !Empty(oModelD0C:GetValue("D0C_NUMLOT"))
						oModelD0C:LoadValue("D0C_LOTECT", "")
						oModelD0C:LoadValue("D0C_NUMLOT", "")
					EndIf
				EndIf
			EndIf
		Else
			If lRet .And. !lWmsDes
				If SB1->(DbSeek(xFilial("SB1")+oModelD0C:GetValue("D0C_PRODUT")))
					If RetFldProd(SB1->B1_COD,"B1_LOCALIZ") == "S"
						oModel:GetModel():SetErrorMessage( , , oModel:GetId() , '',WMSA52022,"Produtos com controle de localização e sem controle WMS não são permitidos para a troca.", "", '', '') //Produto não cadatrado.
						lRet := .F.
					EndIf
				Else
					oModel:GetModel():SetErrorMessage( , , oModel:GetId() , '',WMSA52023,STR0031, "", '', '') //Produto não cadatrado.
					lRet := .F.
				EndIf
				If lRet .And. !Rastro(oModelD0C:GetValue("D0C_PRODUT"))
					If !Empty(oModelD0C:GetValue("D0C_LOTECT")) .Or. !Empty(oModelD0C:GetValue("D0C_NUMLOT"))
						oModelD0C:LoadValue("D0C_LOTECT", "")
						oModelD0C:LoadValue("D0C_NUMLOT", "")
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
Return lRet
//--------------------------------------------------------------
/*/{Protheus.doc} WhenField
valida se habilita o campo
@author felipe.m
@since 06/03/2015
@version 1.0
@param oModel, objeto, (Modelo de dados)
@param cField, caracter, nome do campo
/*/
//--------------------------------------------------------------
Function WMS520WFld(oModel,cField)
Local lRet := .F.
	If cField == "D0C_LOTECT"
		lRet := Rastro(oModel:GetValue("D0C_PRODUT"))
	ElseIf cField == "D0C_NUMLOT"
		lRet := Rastro(oModel:GetValue("D0C_PRODUT"),"S")
	EndIf
Return lRet
//--------------------------------------------------------------
/*/{Protheus.doc} PosValid
Validação pós linha da grid Produtos
@author felipe.m
@since 06/03/2015
@version 1.0
@param oModelD0C, objeto, (Modelo de dados)
/*/
//--------------------------------------------------------------
Static Function PosValid(oModelD0C)
Local lRet     := .T.
Local cMsmProd := ""
Local nLine    := 0
Local nI       := 0

	nLine := oModelD0C:GetLine()
	cMsmProd := oModelD0C:GetValue("D0C_PRODUT")+oModelD0C:GetValue("D0C_LOTECT")+oModelD0C:GetValue("D0C_NUMLOT")
	If lRet
		For nI := 1 To oModelD0C:Length()
			oModelD0C:GoLine(nI)
			If oModelD0C:IsDeleted()
				Loop
			EndIf
			If nLine != nI .And. oModelD0C:GetValue("D0C_PRODUT")+oModelD0C:GetValue("D0C_LOTECT")+oModelD0C:GetValue("D0C_NUMLOT") == cMsmProd
				lRet := .F.
				Exit
			EndIf
		Next nI
	EndIf
	If !lRet
		WmsMessage(STR0016,WMSA52004,5/*MSG_HELP*/) // Produto/Lote/Sub-Lote já informado!
	EndIf
	oModelD0C:GoLine(nLine)
Return lRet
//--------------------------------------
/*/{Protheus.doc} WMSA520AUT
Realiza movimentações automáticas de estoque.
@author Squad WMS Protheus
@since 13/02/2018
@version 1.0
/*/
//--------------------------------------
Function WMSA520AUT(oModel,cDocumento)
Local lRet      := .T.
Local oMntItem  := WMSDTCMontagemDesmontagemItens():New()
Local oMovEstEnd:= WMSDTCMovimentosEstoqueEndereco():New()
Local oOrdServ  := WMSDTCOrdemServico():New()
Local cAliasD0A := Nil
Local cAliasD0B := Nil
Local cTipMov   := Nil
	//Faz movimentações SD3  para as montagens/desmontagens
	oOrdServ:SetDocto(cDocumento)
	cAliasD0A := GetNextAlias()
	BeginSql Alias cAliasD0A
		SELECT D0A.D0A_OPERAC
		FROM %Table:D0A% D0A
		WHERE D0A.D0A_FILIAL = %xFilial:D0A% 
		AND D0A.D0A_DOC = %Exp:cDocumento%
		AND D0A.%NotDel%
	EndSql
	If (cAliasD0A)->(!Eof())
		cTipMov := Iif((cAliasD0A)->D0A_OPERAC == "1","2","1")
		cAliasD0B := GetNextAlias()
		BeginSql Alias cAliasD0B
			SELECT D0B.D0B_PRODUT
			FROM %Table:D0B% D0B
			WHERE D0B.D0B_FILIAL = %xFilial:D0B%
			AND D0B.D0B_DOC = %Exp:cDocumento%
			AND D0B.D0B_TIPMOV = %Exp:cTipMov%
			AND D0B.%NotDel%
		EndSql
		If (cAliasD0B)->(!Eof()) .And. lRet
			oOrdServ:oProdLote:SetProduto((cAliasD0B)->D0B_PRODUT)
			If !(lRet := oOrdServ:AtuMovSD3())
				oModel:GetModel():SetErrorMessage( , , oModel:GetId() , '', WMSA51010,STR0032,,'','') // Não foi possível realizar as movimentações de estoque.
			EndIf
		EndIf
		(cAliasD0B)->(dbCloseArea())
	EndIf
	(cAliasD0A)->(dbCloseArea())
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
			If IntWMS(oMntItem:oProdLote:GetPrdOri())
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
		EndIf		
		(cAliasD0B)->(DbSkip())
	EndDo
	(cAliasD0B)->(DbCloseArea())
	FreeObj(oMntItem)
	oMovEstEnd:Destroy()
Return lRet
//--------------------------------------
/*/{Protheus.doc} WMSA520EST
Estorna movimentações automáticas de estoque.
@author Squad WMS Protheus
@since 13/02/2018
@version 1.0
/*/
//--------------------------------------
Function WMSA520EST(oModel,cDocumento)
Local lRet      := .T.
Local oMntItem  := WMSDTCMontagemDesmontagemItens():New()
Local oMovEstEnd:= WMSDTCMovimentosEstoqueEndereco():New()
Local oOrdServ  := WMSDTCOrdemServico():New()
Local cAliasD0B := ""
Local cAliasD13 := ""
	
	//Estorna movimentações SD3
	oOrdServ:SetDocto(cDocumento)
	If !(lRet := oOrdServ:UndoMovSD3())
		oModel:GetModel():SetErrorMessage( , , oModel:GetId() , '', WMSA51012,STR0022,,'','') // Não foi possível estornar as movimentações de estoque.
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
				If IntWMS(oMntItem:oProdLote:GetPrdOri())
					oEstEnder:ClearData()
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
						oModel:GetModel():SetErrorMessage( , , oModel:GetId() , '', WMSA52012, WmsFmtMsg(STR0033,{{"[VAR01]",oMntItem:oProdLote:GetProduto()},{"[VAR02]",oMntItem:oProdLote:GetLoteCtl()}}),,'','') // Saldo do produto/lote [VAR01]/[VAR02] indisponível para o estorno.
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
					oEstEnder:ClearData()
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
//---------------------------------------------------------------
/*/{Protheus.doc} A520VldPrd
Validação do produto informado no pergunte
@author felipe.m
@since 06/03/2015
@version 1.0
@param lInvRet, Lógico, (Inverte pesquisa)
/*/
//---------------------------------------------------------------
Function A520VldPrd(cArmazem, cProduto, cLoteCtl, cNumLote, cEndereco)
Local lRet      := .T.
Local aAreaAnt  := GetArea()
	//Verifica quantidade disponível novamente
	oEstEnder:ClearData()
	oEstEnder:oProdLote:SetArmazem(cArmazem)
	oEstEnder:oProdLote:SetPrdOri(cProduto)
	oEstEnder:oProdLote:SetProduto(cProduto)
	oEstEnder:oProdLote:SetLoteCtl(cLoteCtl)
	oEstEnder:oProdLote:SetNumLote(cNumLote)
	oEstEnder:oProdLote:LoadData()
	If oEstEnder:oProdLote:oProduto:LoadData()
		If !oEstEnder:oProdLote:oProduto:IsCtrWms()
			cErro    := STR0021 // Produto não controla WMS.
			cSolucao := ""
			lRet := .F.
		EndIf
		If lRet .And. oEstEnder:oProdLote:oProduto:oProdComp:IsDad()
			cErro    := STR0030 // Produto informado possui estrutura de armazenamento. Operação não permitida!
			cSolucao := ""
			lRet := .F.
		EndIf
		If lRet
			If oEstEnder:oProdLote:HasRastro() .And. Empty(cLoteCtl)
				cErro    := STR0015 // Produto Informado possui controle de rastro.
				cSolucao := STR0013 // Informe o lote.
				lRet := .F.
			EndIf
			If lRet .And. oEstEnder:oProdLote:HasRastSub() .And. Empty(cNumLote)
				cErro    := STR0015 // Produto Informado possui controle de rastro.
				cSolucao := STR0002 // Informe o sub-lote.
				lRet := .F.	
			EndIf
		EndIf
	Else
		cErro    := STR0031 //Produto não cadatrado.
		cSolucao := ""
		lRet := .F.
	EndIf	
	If lRet
		oEstEnder:oEndereco:SetArmazem(cArmazem)
		oEstEnder:oEndereco:SetEnder(cEndereco)
		oEstEnder:oEndereco:LoadData()
		nQtdDisp := oEstEnder:ConsultSld(,.T.,.T.,.T.)
		If QtdComp(nQtdDisp) <= 0
			cErro    := WmsFmtMsg(STR0001,{{"[VAR01]",AllTrim(cProduto)},{"[VAR02]",AllTrim(cArmazem)},{"[VAR03]",AllTrim(cEndereco)}}) //Produto [VAR01] não possui saldo disponível no armazém [VAR02] e endereço [VAR03] informado.
			cSolucao := STR0014 // Verifique se há movimentações pendentes, estorne-os caso queira realmente trocar o produto nesse endereço.
			lRet := .F.
		EndIf
		// Valida se é armazem unitizado e se estrutura física permite processo de troca de produtos WMS
		If lRet .And. WmsArmUnit(cArmazem)
			If !(oEstEnder:oEndereco:GetTipoEst() == 2 .Or. oEstEnder:oEndereco:GetTipoEst() == 5 .Or. oEstEnder:oEndereco:GetTipoEst() == 7 .Or. oEstEnder:oEndereco:GetTipoEst() == 8)
				cErro    := WmsFmtMsg(STR0035,{{"[VAR01]",AllTrim(cArmazem)},{"[VAR02]",AllTrim(cEndereco)}}) // Armazém [VAR01] e o tipo de estrutura do endereço [VAR02] controlam unitizadores! Operação não permitida.
				cSolucao := STR0036 // Transfira o unitizador para um endereço do tipo (1-Picking, 5-Doca, 7-Produção ou 8-Qualidade) para realizar a troca de produto WMS 
				lRet := .F.
			EndIf
		EndIf
	EndIf
	If lRet
		oSeqAbast:SetArmazem(cArmazem)
		oSeqAbast:SetProduto(cProduto)
		oSeqAbast:SetEstFis(oEstEnder:oEndereco:GetEstFis())
		If !oSeqAbast:LoadData(2)
			cErro    := WmsFmtMsg(STR0019,{{"[VAR01]",AllTrim(cProduto)}}) // O produto [VAR01] não possui a estrutura cadastrada do endereço destino informado.
			cSolucao := STR0020 // Informe outro endereço ou cadastre a estrutura para o produto.
			lRet := .F.
		EndIf
		If lRet
			If !(oSeqAbast:GetTipoEnd() == '4')
				cErro    :=  WmsFmtMsg(STR0026,{{"[VAR01]",AllTrim(oEstEnder:oEndereco:GetEstFis())}}) // Estrutura física [VAR01] não permite misturar produtos.
				cSolucao :=  WmsFmtMsg(STR0027,{{"[VAR01]",AllTrim(oEstEnder:oProdLote:GetProduto())},{"[VAR02]",AllTrim(oEstEnder:oEndereco:GetEstFis())}}) // Informe outro endereço ou configure no casdatro de sequencia de abastecimento do produto [VAR01] a estrutura fisica [VAR02] o tipo de endereçamento que permita misturar produtos.
				lRet := .F.
			EndIf
		EndIf
	EndIf
	If !lRet
		WmsMessage(cErro,WMSA52020,,,,cSolucao)
	EndIf
	RestArea(aAreaAnt)
Return lRet
/*/{Protheus.doc} A520VldArm
Verifica se o armazém informado é o armazém de qualidade e impede a operação.
@author amanda.vieira
@since 14/04/2020
@version 1.0
/*/
Static Function A520VldArm()
Local lRet := .T.
Local cLocalCQ := SuperGetMV("MV_CQ",.F.,"")
	If !Empty(cLocalCQ) .And. AllTrim(cLocalCQ) == AllTrim(MV_PAR01)
		WmsMessage(STR0037,WMSA52021,5/*MSG_HELP*/) //Não permitida a troca de produtos no armazém de qualidade.
		lRet := .F.
	EndIf
Return lRet


/*/{Protheus.doc} VldDel520
Valida se registro pode ser excluido
@author equipe WMS
@since 17/07/2023
@version 1.0
/*/
Static Function VldDel520()
	Local lRet := .T.
	Local dDataFec  := MVUlmes()

	If dDataFec >= D0A->D0A_DTMOV 
		Help ( " ", 1, "FECHTO" )
		lRet := .F.
	EndIf
Return lRet


/*/{Protheus.doc} WMS520Estr
Valida se registro pode ser excluido
@author equipe WMS
@since 02/04/2024
@version 1.0
/*/
Function WMS520Estr(oModel,oView)
	Local oModelD0C := oModel:GetModel("A520D0C")
	Local oModelD0A := oModel:GetModel("A520D0A")
	Local nX := 0
	Local lRet := .T.
	Local aEstrutura := {}

	For nX := 1 To oModelD0C:Length()
		oModelD0C:GoLine(nX)
		If !oModelD0C:IsDeleted() .AND. !Empty(oModelD0C:GetValue('D0C_PRODUT'))
			If !ApMsgYesNo(STR0044) //"Já existem informacões digitadas para a desmontagem. Deseja substituir?"
				lRet := .F.
				Exit
			Else
				oModelD0C:ClearData(.T.,.T.)
				oView:Refresh()
				Exit
			EndIf
		EndIf
	Next nX

	If lRet 
		If oModelD0A:GetValue('D0A_QTDMOV') > 0
			aCusbExpld(oModelD0A:GetValue('D0A_PRODUT'),oModelD0A:GetValue('D0A_QTDMOV'),@aEstrutura) 

			If Len(aEstrutura) > 0
				For nX := 1 to Len(aEstrutura)
					If nX > 1
						oModelD0C:AddLine()
					EndIf

					oModelD0C:GoLine(nX)
					SB1->(dbSetOrder(1))
					SB1->(MsSeek(xFilial("SB1")+aEstrutura[nX,3]))
					oModelD0C:SetValue('D0C_PRODUT',aEstrutura[nX,3])
					oModelD0C:SetValue('QUANT',aEstrutura[nX,4])

					/* Tratamento para marcar como deletados os itens com quantidade negativa na 
					estrutura, de acordo com o tipo de movimentacao RE/DE. */
					If QtdComp(aEstrutura[nX,4]) <= QtdComp(0)
						oModelD0C:DeleteLine()
					EndIf
				Next nX
				oModelD0C:GoLine(1)
			Else
				Help( , , STR0045, , STR0046 , 1, 0 )//"Atenção","Produto sem estrutura cadastrada."
				lRet := .F.
			EndIf
		Else
			Help( , , STR0045, ,STR0047 , 1, 0 )//"Atenção","Informe a quantidade de movimentação."
			lRet := .F.
		EndIf
	EndIf

Return lRet
