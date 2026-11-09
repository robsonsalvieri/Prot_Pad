#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "DBINFO.CH"
#INCLUDE "FWEDITPANEL.CH"
#INCLUDE "WMSA391A.CH"

#DEFINE WMSA391A01 "WMSA391A01"
#DEFINE WMSA391A02 "WMSA391A02"
#DEFINE WMSA391A03 "WMSA391A03"
#DEFINE WMSA391A04 "WMSA391A04"
#DEFINE WMSA391A05 "WMSA391A05"
#DEFINE WMSA391A06 "WMSA391A06"
#DEFINE WMSA391A07 "WMSA391A07"
#DEFINE WMSA391A08 "WMSA391A08"
#DEFINE WMSA391A09 "WMSA391A09"
#DEFINE WMSA391A10 "WMSA391A10"
#DEFINE WMSA391A11 "WMSA391A11"
#DEFINE WMSA391A12 "WMSA391A12"
#DEFINE WMSA391A13 "WMSA391A13"
#DEFINE WMSA391A14 "WMSA391A14"
#DEFINE WMSA391A15 "WMSA391A15"
#DEFINE WMSA391A16 "WMSA391A16"
#DEFINE WMSA391A17 "WMSA391A17"
#DEFINE WMSA391A18 "WMSA391A18"
#DEFINE WMSA391A19 "WMSA391A19"
#DEFINE WMSA391A20 "WMSA391A20"
#DEFINE WMSA391A21 "WMSA391A21"

Static __lHasLot   := SuperGetMV("MV_WMSLOTE",.F.,.T.)
Static oMntVolItem := WMSDTCMontagemVolumeItens():New()

//-------------------------------------------------------
/*/{Protheus.doc} WMSA391A
Programa que contém as regras de montagem de volume pelo monitor
@author felipe.m
@since 07/05/2015
@version 1.0
/*/
//-------------------------------------------------------
Function WMSA391A()
Return Nil

//-------------------------------------------------------------------//
//---------------------------ModelDef--------------------------------//
//-------------------------------------------------------------------//
Static Function ModelDef()
Local oModel    := Nil
Local oStrDCU   := FWFormStruct(1,"DCU")
Local oStrDCVFld:= FWFormStruct(1,"DCV")
Local oStrDCVGrd:= FWFormStruct(1,"DCV")
Local aColsSX3  := {}

	oStrDCU:SetProperty("*",MODEL_FIELD_OBRIGAT,.F.)
	oStrDCVFld:SetProperty("*",MODEL_FIELD_OBRIGAT,.F.)
	oStrDCVGrd:SetProperty("*",MODEL_FIELD_OBRIGAT,.F.)

	oStrDCU:SetProperty("DCU_FILIAL",MODEL_FIELD_INIT,FwBuildFeature(STRUCT_FEATURE_INIPAD,"xFilial('DCU')"))
	oStrDCU:SetProperty("DCU_CODMNT",MODEL_FIELD_INIT,FwBuildFeature(STRUCT_FEATURE_INIPAD,"DCS->DCS_CODMNT"))
	oStrDCU:SetProperty("DCU_CARGA" ,MODEL_FIELD_INIT,FwBuildFeature(STRUCT_FEATURE_INIPAD,"DCS->DCS_CARGA"))
	oStrDCU:SetProperty("DCU_PEDIDO",MODEL_FIELD_INIT,FwBuildFeature(STRUCT_FEATURE_INIPAD,"DCS->DCS_PEDIDO"))
	oStrDCU:SetProperty("DCU_CODVOL",MODEL_FIELD_INIT,FwBuildFeature(STRUCT_FEATURE_INIPAD,"Padl(CBProxCod('MV_WMSNVOL'),TamSX3('DCU_CODVOL')[1],'0')"))
	oStrDCU:SetProperty("DCU_DATINI",MODEL_FIELD_INIT,FwBuildFeature(STRUCT_FEATURE_INIPAD,"dDataBase"))
	oStrDCU:SetProperty("DCU_HORINI",MODEL_FIELD_INIT,FwBuildFeature(STRUCT_FEATURE_INIPAD,"Time()"))
	
	oStrDCVFld:SetProperty("DCV_CODPRO",MODEL_FIELD_VALID,FWBuildFeature(STRUCT_FEATURE_VALID,"WMS391VFld(A,B,C)"))
	oStrDCVFld:SetProperty("DCV_QUANT",MODEL_FIELD_INIT,FwBuildFeature(STRUCT_FEATURE_INIPAD,"1"))
	oStrDCVFld:SetProperty("DCV_LOTE",MODEL_FIELD_VALID,FWBuildFeature(STRUCT_FEATURE_VALID,"WMS391VFld(A,B,C)"))
	oStrDCVFld:SetProperty("DCV_SUBLOT",MODEL_FIELD_VALID,FWBuildFeature(STRUCT_FEATURE_VALID,"WMS391VFld(A,B,C)"))

	oStrDCVFld:SetProperty("DCV_LOTE",MODEL_FIELD_WHEN,FwBuildFeature(STRUCT_FEATURE_WHEN,"WMS391WFld(A,B)"))
	oStrDCVFld:SetProperty("DCV_SUBLOT",MODEL_FIELD_WHEN,FwBuildFeature(STRUCT_FEATURE_WHEN,"WMS391WFld(A,B)"))

	oModel := MPFormModel():New("WMSA391A",/*bPre*/,{|| ValidMdl(oModel)},{|oModel| CommitMdl(oModel)},/*bCancel*/)

	oModel:AddFields("WMSA391ADCU",Nil,oStrDCU,/*bPre*/,/*bPost*/,/*bLoad*/)
	oModel:AddFields("WMSA391ADCVF","WMSA391ADCU",oStrDCVFld,/*bPre*/,/*bPost*/,/*bLoad*/)
	oModel:AddGrid("WMSA391ADCVG","WMSA391ADCVF",oStrDCVGrd,/*bPre*/,/*bPost*/,/*bLoad*/)

	oModel:SetRelation("WMSA391ADCVF",{{"DCV_FILIAL","'"+xFilial("DCV")+"'"},{"DCV_CODMNT","DCU_CODMNT"},{"DCV_CARGA","DCU_CARGA"},{"DCV_PEDIDO","DCU_PEDIDO"},{"DCV_CODVOL","DCU_CODVOL"}},DCV->(IndexKey(3)))
	oModel:SetRelation("WMSA391ADCVG",{{"DCV_FILIAL","'"+xFilial("DCV")+"'"},{"DCV_CODMNT","DCV_CODMNT"},{"DCV_CARGA","DCV_CARGA"},{"DCV_PEDIDO","DCV_PEDIDO"},{"DCV_CODVOL","DCV_CODVOL"}},DCV->(IndexKey(3)))

	oModel:AddRules("WMSA391ADCVF","DCV_LOTE","WMSA391ADCVF","DCV_CODPRO",3)
	oModel:AddRules("WMSA391ADCVF","DCV_SUBLOT","WMSA391ADCVF","DCV_LOTE",3)

	oModel:GetModel("WMSA391ADCVF"):SetOnlyQuery(.T.)
	oModel:GetModel("WMSA391ADCVG"):SetOptional(.T.)
	oModel:GetModel("WMSA391ADCVG"):SetNoInsertLine(.T.)

	oModel:SetActivate({|oModel| ActivMdl(oModel)})
Return oModel

//-------------------------------------------------------------------//
//-----------------------------ViewDef-------------------------------//
//-------------------------------------------------------------------//
Static Function ViewDef()
Local oModel := ModelDef()
Local oView := FWFormView():New()
Local oStrDCVF := FWFormStruct(2,"DCV")
Local oStrDCVG := FWFormStruct(2,"DCV")
Local aColsSX3 := {}

	oStrDCVF:RemoveField("DCV_CODVOL")
	oStrDCVF:RemoveField("DCV_QTORIG")
	oStrDCVF:RemoveField("DCV_CARGA")
	oStrDCVF:RemoveField("DCV_PEDIDO")
	oStrDCVF:RemoveField("DCV_SEQUEN")
	oStrDCVF:RemoveField("DCV_DATINI")
	oStrDCVF:RemoveField("DCV_HORINI")
	oStrDCVF:RemoveField("DCV_DATFIM")
	oStrDCVF:RemoveField("DCV_HORFIM")
	oStrDCVF:RemoveField("DCV_TMPMNT")
	oStrDCVF:RemoveField("DCV_DATA")
	oStrDCVF:RemoveField("DCV_HORA")
	oStrDCVF:RemoveField("DCV_CODMNT")
	oStrDCVF:RemoveField("DCV_ITEM")
	oStrDCVF:RemoveField("DCV_STATUS")
	oStrDCVF:RemoveField("DCV_PRDORI")
	oStrDCVF:RemoveField("DCV_CODOPE")
	oStrDCVF:RemoveField("DCV_NOMOPE")

    oStrDCVF:SetProperty("DCV_CODPRO",MVC_VIEW_ORDEM,"00")
	oStrDCVF:SetProperty("DCV_QUANT",MVC_VIEW_ORDEM,"01")
	

	oStrDCVF:SetProperty("DCV_QUANT",MVC_VIEW_CANCHANGE,.T.)
	oStrDCVF:SetProperty("DCV_CODPRO",MVC_VIEW_CANCHANGE,.T.)

	oStrDCVG:RemoveField("DCV_CODVOL")
	oStrDCVG:RemoveField("DCV_QTORIG")
	oStrDCVG:RemoveField("DCV_CARGA")
	oStrDCVG:RemoveField("DCV_PEDIDO")
	oStrDCVG:RemoveField("DCV_SEQUEN")
	oStrDCVG:RemoveField("DCV_DATINI")
	oStrDCVG:RemoveField("DCV_HORINI")
	oStrDCVG:RemoveField("DCV_DATFIM")
	oStrDCVG:RemoveField("DCV_HORFIM")
	oStrDCVG:RemoveField("DCV_TMPMNT")
	oStrDCVG:RemoveField("DCV_DATA")
	oStrDCVG:RemoveField("DCV_HORA")
	oStrDCVG:RemoveField("DCV_CODMNT")
	oStrDCVG:RemoveField("DCV_ITEM")
	oStrDCVG:RemoveField("DCV_STATUS")
	oStrDCVG:RemoveField("DCV_PRDORI")
	oStrDCVG:RemoveField("DCV_CODOPE")
	oStrDCVG:RemoveField("DCV_NOMOPE")

	// Objeto do model a se associar a view.
	oView:SetModel(oModel)

	oView:CreateHorizontalBox("MASTER",35,/*cIDOwner*/,/*lFixPixel*/,/*cIDFolder*/,/*cIDSheet*/)
	oView:AddField("WMSA391ADCVF",oStrDCVF)
	oView:SetViewProperty("WMSA391ADCVF","SETLAYOUT",{FF_LAYOUT_VERT_DESCR_TOP,5})
	oView:CreateHorizontalBox("DETAIL",65,/*cIDOwner*/,/*lFixPixel*/,/*cIDFolder*/,/*cIDSheet*/ )
	oView:AddGrid("WMSA391ADCVG",oStrDCVG,,,{ || RegItnVol(oModel,oView)} )
	oView:SetOnlyView("WMSA391ADCVG")

	oView:EnableTitleView("WMSA391ADCVF", STR0003) // Produto
	oView:EnableTitleView("WMSA391ADCVG", STR0002) // Itens Volume

	// Associa um View a um box
	oView:SetOwnerView("WMSA391ADCVF", "MASTER")
	oView:SetOwnerView("WMSA391ADCVG", "DETAIL")
Return oView

//------------------------------------------------------------------------------
// Ao ativar o model, inicializa o objeto com os valores do model
//------------------------------------------------------------------------------
Static Function ActivMdl(oModel)
Local oModelDCU := oModel:GetModel("WMSA391ADCU")
Local oModelDCV := oModel:GetModel("WMSA391ADCVF")
Local oView     := FWViewActive()

	oMntVolItem:oMntVol:SetCodMnt(oModelDCU:GetValue("DCU_CODMNT"))
	oMntVolItem:oMntVol:SetCarga(oModelDCU:GetValue("DCU_CARGA"))
	oMntVolItem:oMntVol:SetPedido(oModelDCU:GetValue("DCU_PEDIDO"))
	oMntVolItem:oVolume:SetCodVol(oModelDCU:GetValue("DCU_CODVOL"))
	oMntVolItem:oVolume:SetDtIni(oModelDCU:GetValue("DCU_DATINI"))
	oMntVolItem:oVolume:SetHrIni(oModelDCU:GetValue("DCU_HORINI"))
	oModelDCV:LoadValue("DCV_CODVOL",oModelDCU:GetValue("DCU_CODVOL"))
	oView:EnableTitleView("WMSA391ADCVF", STR0006+oModelDCU:GetValue("DCU_CODVOL")) // "Produto - Volume: "
Return .T.

//-----------------------------------------------------------------//
//--------Função responsável por validar a edição do campo---------//
//-----------------------------------------------------------------//
Function WMS391WFld(oModel,cField)
Local lRet    := .T.
	If cField == "DCV_LOTE"
		lRet :=  __lHasLot .And. Rastro(oModel:GetValue("DCV_CODPRO"))
	ElseIf cField == "DCV_SUBLOT"
		lRet := __lHasLot .And. Rastro(oModel:GetValue("DCV_CODPRO"),"S")
	EndIf
Return lRet

//-----------------------------------------------------------------//
// Função de validação dos campos
//-----------------------------------------------------------------//
Function WMS391VFld(oModel,cField,xValue)
Local oView    := FwViewActive()
Local lRet := .T.
Local cCodBar  := ""
Local cProduto := ""
Local cLoteCtl := ""
Local cSubLote := ""
Local nQtde    := 0

	If cField == "DCV_CODPRO"
		cCodBar := xValue
		lRet := VldPrdLot(oModel,oView,@cProduto,@cLoteCtl,@cSubLote,@nQtde,@cCodBar)
	ElseIf cField == "DCV_LOTE"
		lRet := VldLoteCtl(oModel,xValue)
	ElseIf cField == "DCV_SUBLOT"
		lRet := VldSubLote(oModel,xValue)
	EndIf
Return lRet

//----------------------------------------------------------------------------------
// Valida o produto informado, verificando se é um código de barras ou etiqueta CB0
//----------------------------------------------------------------------------------
Static Function VldPrdLot(oModel,oView,cProduto,cLoteCtl,cSubLote,nQtde,cCodBar)
Local lRet      := .T.
Local aProduto  := {}
Local lAchou    := .F.

	If Empty(cCodBar)
		Return .F.
	EndIf
	// Deve zerar estas informações, pois pode haver informação de outra etiqueta
	cProduto := Space(TamSx3("DCV_CODPRO")[1])
	cLoteCtl := Space(TamSx3("DCV_LOTE")[1])
	cSubLote := Space(TamSx3("DCV_SUBLOT")[1])
	nQtde    := 0
	aProduto := CBRetEtiEAN(cCodBar)
	If Len(aProduto) > 0
		cProduto := aProduto[1]
		If ValType(aProduto[2]) == 'N' 
			nQtde := Iif(aProduto[2] == 0,1,aProduto[2])
		EndIf
		cLoteCtl := Padr(aProduto[3],TamSx3("DCV_LOTE")[1])
	Else
		aProduto := CBRetEti(cProduto, '01')
		If Len(aProduto) > 0
			cProduto := aProduto[1]
			nQtde    := Iif(aProduto[2] == 0,1,aProduto[2])
			cLoteCtl := Padr(aProduto[16],TamSx3("DCV_LOTE")[1])
			cSubLote := Padr(aProduto[17],TamSx3("DCV_SUBLOT")[1])
		EndIf
		If Empty(aProduto)
			oModel:GetModel():SetErrorMessage(oModel:GetId(),"DCV_CODPRO",,,WMSA391A01,STR0005,STR0004) //"Código do produto é invalido!","Informe o código do produto ou o código de barras do produto desejado."
			lRet := .F.
		EndIf
	EndIf
	// Deve validar se o produto informado é um produto partes ou componente
	If lRet
		oMntVolItem:SetProduto(cProduto)
		oMntVolItem:SetLoteCtl(cLoteCtl)
		oMntVolItem:SetNumLote(cSubLote)
		lAchou := oMntVolItem:VldPrdCmp()

		If !lAchou
			oModel:GetModel():SetErrorMessage(oModel:GetId(),"DCV_CODPRO",,,WMSA391A02,STR0010,STR0016) //"Produto não pertence a montagem de volumes do documento.","Verifique os dados informados."
			lRet := .F.
		Else
			lRet := oModel:LoadValue("DCV_PRDORI",oMntVolItem:GetPrdOri())
		EndIf
	EndIf

	If lRet
		// Carregar as quantidades para o produto
		oMntVolItem:QtdPrdVol()
		//Deve validar se o produto possui quantidade para separada para ser embalada
		If QtdComp(oMntVolItem:GetQtdSep()) == 0
			oModel:GetModel():SetErrorMessage(oModel:GetId(),"DCV_CODPRO",,,WMSA391A18,STR0007,STR0019) // "Produto não possui quantidade separada para montagem de volumes.","Aguarde a finalização do processo de separação."
			lRet := .F.
		EndIf
		//Deve validar se o produto possui quantidade para separada pendente para ser embalada
		If lRet .And. QtdComp(oMntVolItem:GetQtdOri()-oMntVolItem:GetQtdEmb()) == 0
			oModel:GetModel():SetErrorMessage(oModel:GetId(),"DCV_CODPRO",,,WMSA391A19,STR0008,STR0016) // "Montagem de volumes do produto finalizada.","Verifique os dados informados."
			lRet := .F.
		EndIf
		//Deve validar se o produto possui quantidade para separada pendente para ser embalada
		If lRet .And. QtdComp(oMntVolItem:GetQtdSep()-oMntVolItem:GetQtdEmb()) == 0
			oModel:GetModel():SetErrorMessage(oModel:GetId(),"DCV_CODPRO",,,WMSA391A20,STR0009,STR0019) // "Produto não possui quantidade separada pendente para montagem de volumes.","Aguarde a finalização do processo de separação."
			lRet := .F.
		EndIf
	EndIf

	If lRet .And. !Empty(cProduto)
		lRet := oModel:LoadValue("DCV_CODPRO",cProduto)
	EndIf
	If lRet .And. !Empty(cLoteCtl)
		lRet := oModel:SetValue("DCV_LOTE",cLoteCtl)
	EndIf
	If lRet .And. !Empty(cSubLote)
		lRet := oModel:SetValue("DCV_SUBLOT",cSubLote)
	EndIf
	If lRet .And. !Empty(nQtde)
		lRet := oModel:LoadValue("DCV_QUANT",nQtde)
	EndIf

	If !lRet
		cCodBar := Space(128)
		oModel:ClearField("DCV_CODPRO")
		oView:Refresh()
		oView:GetViewObj("WMSA391ADCVF")[3]:getFWEditCtrl("DCV_CODPRO"):oCtrl:SetFocus()
	EndIf
Return lRet

//-----------------------------------------------------------------------------
// Valida o produto/lote informado, verificando se o mesmo possui saldo no endereço
//-----------------------------------------------------------------------------
Static Function VldLoteCtl(oModel,cLoteCtl)

	If Empty(cLoteCtl)
		Return .F.
	EndIf
	oMntVolItem:SetLoteCtl(cLoteCtl)
	// Carregar as quantidades para o produto
	oMntVolItem:QtdPrdVol()
	//Deve validar se o produto/lote possui quantidade para separada para ser embalada
	If QtdComp(oMntVolItem:GetQtdOri()) == 0
		oModel:GetModel():SetErrorMessage(oModel:GetId(),"DCV_LOTE",,,WMSA391A03,STR0015,STR0016) //"Produto/Lote não pertence a montagem de volumes do documento."##"Verifique os dados informados."
		Return .F.
	EndIf
	//Deve validar se o produto/lote possui quantidade para separada para ser embalada
	If QtdComp(oMntVolItem:GetQtdSep()) == 0
		oModel:GetModel():SetErrorMessage(oModel:GetId(),"DCV_LOTE",,,WMSA391A04,STR0018,STR0019) // "Produto/Lote não possui quantidade separada para montagem de volumes."##"Aguarde a finalização do processo de separação."
		Return .F.
	EndIf
	//Deve validar se o produto/lote já foi todo montado volume
	If QtdComp(oMntVolItem:GetQtdOri()-oMntVolItem:GetQtdEmb()) == 0
		oModel:GetModel():SetErrorMessage(oModel:GetId(),"DCV_LOTE",,,WMSA391A05,STR0020,STR0016) // "Montagem de volumes do Produto/Lote finalizada."##"Verifique os dados informados."
		Return .F.
	EndIf
	//Deve validar se o produto/lote possui quantidade pendente para ser separada
	If QtdComp(oMntVolItem:GetQtdSep()-oMntVolItem:GetQtdEmb()) == 0
		oModel:GetModel():SetErrorMessage(oModel:GetId(),"DCV_LOTE",,,WMSA391A06,STR0021,STR0019) // "Montagem de volumes do Produto/Lote da quantidade separada finalizada."##"Aguarde a finalização do processo de separação."
		Return .F.
	EndIf
Return .T.

//-----------------------------------------------------------------------------
// Valida o produto/rastro informado, verificando se o mesmo possui saldo no endereço
//-----------------------------------------------------------------------------
Static Function VldSubLote(oModel,cSubLote)

	If Empty(cSubLote)
		Return .F.
	EndIf
	oMntVolItem:SetNumLote(cSubLote)
	// Carregar as quantidades para o produto
	oMntVolItem:QtdPrdVol()
	//Deve validar se o produto/lote possui quantidade para separada para ser embalada
	If QtdComp(oMntVolItem:GetQtdOri()) == 0
		oModel:GetModel():SetErrorMessage(oModel:GetId(),"DCV_SUBLOT",,,WMSA391A07,STR0022,STR0016) //"Produto/Rastro não pertence a montagem de volumes do documento."##"Verifique os dados informados."
		Return .F.
	EndIf
	//Deve validar se o produto/lote possui quantidade para separada para ser embalada
	If QtdComp(oMntVolItem:GetQtdSep()) == 0
		oModel:GetModel():SetErrorMessage(oModel:GetId(),"DCV_SUBLOT",,,WMSA391A08,STR0023,STR0019) // "Produto/Rastro não possui quantidade separada para montagem de volumes."##"Aguarde a finalização do processo de separação."
		Return .F.
	EndIf
	//Deve validar se o produto/lote já foi todo montado volume
	If QtdComp(oMntVolItem:GetQtdOri()-oMntVolItem:GetQtdEmb()) == 0
		oModel:GetModel():SetErrorMessage(oModel:GetId(),"DCV_SUBLOT",,,WMSA391A09,STR0024,STR0016) // "Montagem de volumes do Produto/Rastro finalizada."##"Verifique os dados informados."
		Return .F.
	EndIf
	//Deve validar se o produto/lote possui quantidade pendente para ser separada
	If QtdComp(oMntVolItem:GetQtdSep()-oMntVolItem:GetQtdEmb()) == 0
		oModel:GetModel():SetErrorMessage(oModel:GetId(),"DCV_SUBLOT",,,WMSA391A10,STR0025,STR0019) // "Montagem de volumes do Produto/Rastro da quantidade separada finalizada."##"Aguarde a finalização do processo de separação."
		Return .F.
	EndIf
Return .T.

//------------------------------------------------------------------------------
// Valida se a quantidade informada não ultrapassa o saldo no endereço
//-----------------------------------------------------------------------------
Static Function VldQtdSld(oModel,nQtde)
Local lRet       := .T.
Local nQtdResVol := 0
Local lWmsNew    := SuperGetMV("MV_WMSNEW",.F.,.F.)
// Qtde. de tolerancia p/calculos com a 1UM. Usado qdo o fator de conv gera um dizima periodica
Local nToler1UM := QtdComp(SuperGetMV("MV_NTOL1UM",.F.,0))
Local lValDisSep := .T.
	If Empty(nQtde)
		Return .F.
	EndIf
	If lRet
		nQtdResVol := oMntVolItem:GetQtdSep() - oMntVolItem:GetQtdEmb()
		If QtdComp(nQtde) > QtdComp(nQtdResVol) .And.;
			QtdComp(Abs(nQtdResVol-nQtde)) > QtdComp(nToler1UM)
			WmsMessage(WmsFmtMsg(STR0026,{{"[VAR01]",oMntVolItem:GetProduto()},{"[VAR02]",AllTrim(Str(nQtdResVol))}}),WMSA391A11,5,.T.,,STR0027) // "Quantidade em volumes mais informada ultrapassa a quantidade separada do produto [VAR01]. Saldo disponível: [VAR02].","Informe uma quantidade menor para incluir no volume."
			oModel:ClearField("DCV_CODPRO")
			oModel:ClearField("DCV_DESCR")
			oModel:ClearField("DCV_LOTE")
			oModel:ClearField("DCV_SUBLOT")
			lRet := .F.
		EndIf
	EndIf
	If lWmsNew
		// Verifica se produto controla lote e não obriga a informação no processo WMS
		// Caso não obrigue não irá realizar as validações referente a quantidade distribuida de separação se houver
		If lRet .And. Rastro(oMntVolItem:GetProduto()) .And. !__lHasLot
			lValDisSep := .F.
		EndIf
		If lRet .And. lValDisSep .And. !WMA391AQTD(oMntVolItem:GetCarga(),oMntVolItem:GetPedido(),oMntVolItem:GetPrdOri(),oMntVolItem:GetProduto(),oMntVolItem:GetLoteCtl(),oMntVolItem:GetNumLote(),nQtde)
			lRet := .F.
		EndIf
	EndIf
Return lRet

//------------------------------------------------------------------------------
// Valida a transferência dos dados digitados pelo usuário no formulário para
// o grid sumarizando as quantidades quando necessário.
//------------------------------------------------------------------------------
Static Function RegItnVol(oModel,oView)
Local oModelDCU  := oModel:GetModel("WMSA391ADCU")
Local oModelDCVF := oModel:GetModel("WMSA391ADCVF")
Local oModelDCVG := oModel:GetModel("WMSA391ADCVG")
Local cPrdOri    := oModelDCVF:GetValue("DCV_PRDORI")
Local cProduto   := oModelDCVF:GetValue("DCV_CODPRO")
Local cLoteCtl   := oModelDCVF:GetValue("DCV_LOTE")
Local cNumLote   := oModelDCVF:GetValue("DCV_SUBLOT")
Local nQuant     := 0
Local lConfirma  := .T.

	// Verifica produto
	If Empty(cProduto)
		lConfirma := .F.
	EndIf

	If lConfirma
		If __lHasLot
			// Verifica lote
			If Rastro(cProduto) .And. Empty(cLoteCtl)
				oView:Refresh()
				oView:GetViewObj("WMSA391ADCVF")[3]:getFWEditCtrl("DCV_LOTE"):oCtrl:SetFocus()
				lConfirma := .F.
			EndIf
			// Verifica sub-lote
			If lConfirma .And. Rastro(cProduto,"S") .And. Empty(cNumLote)
				oView:Refresh()
				oView:GetViewObj("WMSA391ADCVF")[3]:getFWEditCtrl("DCV_SUBLOT"):oCtrl:SetFocus()
				lConfirma := .F.
			EndIf
		Else
			oMntVolItem:QtdPrdVol() // Deve carregar as quantidades neste ponto
		EndIf
	EndIf

	// Verifica quantidade
	If lConfirma .And. oModelDCVF:GetValue("DCV_QUANT") <= 0
		oView:Refresh()
		oView:GetViewObj("WMSA391ADCVF")[3]:getFWEditCtrl("DCV_QUANT"):oCtrl:SetFocus()
		lConfirma := .F.
	EndIf

	If lConfirma
		// Deve validar contra a quantidade que já está tela inclusive
		If oModelDCVG:SeekLine({{"DCV_PRDORI", cPrdOri},{"DCV_CODPRO", cProduto},{"DCV_LOTE", cLoteCtl},{"DCV_SUBLOT", cNumLote}})
			nQuant := oModelDCVG:GetValue("DCV_QUANT") + oModelDCVF:GetValue("DCV_QUANT")
		Else
			nQuant := oModelDCVF:GetValue("DCV_QUANT")
		EndIf
		If !VldQtdSld(oModelDCVF,nQuant)
			oView:Refresh()
			oView:GetViewObj("WMSA391ADCVF")[3]:getFWEditCtrl("DCV_CODPRO"):oCtrl:SetFocus()
			lConfirma := .F.
		EndIf
	EndIf

	// Preenche modelo de dados
	If lConfirma
		oModelDCVG:SetNoInsertLine(.F.)
		// Cria itens na DCY
		If oModelDCVG:SeekLine({{"DCV_PRDORI", cPrdOri},{"DCV_CODPRO", cProduto},{"DCV_LOTE", cLoteCtl},{"DCV_SUBLOT", cNumLote}})
			oModelDCVG:SetValue("DCV_QUANT", nQuant)
		Else
			oModelDCVG:GoLine(oModelDCVG:Length())
			If !oModelDCVG:IsEmpty()
				oModelDCVG:AddLine()
			EndIf

			oModelDCVG:SetValue("DCV_PRDORI", cPrdOri)
			oModelDCVG:SetValue("DCV_CODPRO", cProduto)
			oModelDCVG:SetValue("DCV_DESCR",  Posicione("SB1",1,xFilial("SB1")+cProduto,"B1_DESC"))
			oModelDCVG:SetValue("DCV_LOTE", cLoteCtl)
			oModelDCVG:SetValue("DCV_SUBLOT", cNumLote)
			oModelDCVG:SetValue("DCV_QUANT" , nQuant)
		EndIf
		oModelDCVG:SetNoInsertLine(.T.)
		oModelDCVG:GoLine(1)
		// Inicializa valores
		oModelDCVF:LoadValue("DCV_QUANT",1)
		oModelDCVF:ClearField("DCV_CODPRO")
		oModelDCVF:ClearField("DCV_DESCR")
		oModelDCVF:ClearField("DCV_LOTE")
		oModelDCVF:ClearField("DCV_SUBLOT")
		oView:Refresh()
		oView:GetViewObj("WMSA391ADCVF")[3]:getFWEditCtrl("DCV_CODPRO"):oCtrl:SetFocus()
	EndIf
Return lConfirma

//------------------------------------------------------------------------------
// Efetua as validações do módel antes da inclusão, reavaliando o saldo e não
// deixa incluir um volume sem ter itens informados.
//------------------------------------------------------------------------------
Static Function ValidMdl(oModel)
Local oModelDCU  := oModel:GetModel("WMSA391ADCU")
Local oModelDCVG := oModel:GetModel("WMSA391ADCVG")
Local nI         := 0
Local lRet       := .T.
Local lAchou     := .F.
Local nQtde      := 0
Local nQtdResVol := 0
// Qtde. de tolerancia p/calculos com a 1UM. Usado qdo o fator de conv gera um dizima periodica
Local nToler1UM := QtdComp(SuperGetMV("MV_NTOL1UM",.F.,0))

	If oModel:GetOperation() == MODEL_OPERATION_INSERT
		For nI := 1 To oModelDCVG:Length()
			oModelDCVG:GoLine(nI)
			If !Empty(oModelDCVG:GetValue("DCV_CODPRO"))
				lAchou := .T.
				oMntVolItem:SetProduto(oModelDCVG:GetValue("DCV_CODPRO"))
				oMntVolItem:SetLoteCtl(oModelDCVG:GetValue("DCV_LOTE"))
				oMntVolItem:SetNumLote(oModelDCVG:GetValue("DCV_SUBLOT"))
				oMntVolItem:SetPrdOri(oModelDCVG:GetValue("DCV_PRDORI"))
				oMntVolItem:QtdPrdVol() // Valida novamente a quantidade em estoque
				nQtde := oModelDCVG:GetValue("DCV_QUANT")
				nQtdResVol := oMntVolItem:GetQtdSep() - oMntVolItem:GetQtdEmb()
				If QtdComp(nQtde) > QtdComp(nQtdResVol) .And.;
					QtdComp(Abs(nQtdResVol-nQtde)) > QtdComp(nToler1UM)
					oModel:SetErrorMessage(oModelDCVG:GetId(),"DCV_CODPRO",,,WMSA391A12,WmsFmtMsg(STR0026,{{"[VAR01]",oMntVolItem:GetProduto()},{"[VAR02]",AllTrim(Str(nQtdResVol))}}),STR0027) // // "Quantidade em volumes mais informada ultrapassa a quantidade separada do produto [VAR01]. Saldo disponível: [VAR02].","Informe uma quantidade menor para incluir no volume."
					lRet := .F.
					Exit
				EndIf
			EndIf
		Next nI

		If !lAchou
			oModel:SetErrorMessage(oModelDCVG:GetId(),"DCV_CODPRO",,,WMSA391A14,STR0028,STR0029) // "Não é possível inserir volumes sem itens.","Informe pelo menos um item para montagem de volumes."
			lRet := .F.
		EndIf

		If lRet
			oModelDCU:SetValue("DCU_DATFIM",dDataBase)
			oModelDCU:SetValue("DCU_HORFIM",Time())
		EndIf
	EndIf
Return lRet

//------------------------------------------------------------------------------
// Efetua a gravação dos dados do modelo nas tabelas oficiais
//------------------------------------------------------------------------------
Static Function CommitMdl(oModel)
Local lRet       := .T.
Local oModelDCVG := oModel:GetModel("WMSA391ADCVG")
Local aProdutos  := {}
Local nI         := 0
Local oView      := FWViewActive()
Local lExistBloc := ExistBlock("WMS391CM")

	For nI := 1 To oModelDCVG:Length()
		oModelDCVG:GoLine(nI)
		oMntVolItem:SetProduto(oModelDCVG:GetValue("DCV_CODPRO"))
		oMntVolItem:SetLoteCtl(oModelDCVG:GetValue("DCV_LOTE"))
		oMntVolItem:SetNumLote(oModelDCVG:GetValue("DCV_SUBLOT"))
		oMntVolItem:SetPrdOri(oModelDCVG:GetValue("DCV_PRDORI"))
		If !oMntVolItem:LoadPrdVol(aProdutos,oModelDCVG:GetValue("DCV_QUANT"))
			oModel:SetErrorMessage(oModelDCVG:GetId(),"DCV_CODPRO",,,WMSA391A15,oMntVolItem:GetErro(),STR0016) // Verifique os dados informados
			lRet := .F.
			Exit
		EndIf
	Next nI

	If lRet
		If !oMntVolItem:MntPrdVol(aProdutos)
			oModel:SetErrorMessage(oModelDCVG:GetId(),"DCV_CODPRO",,,WMSA391A21,oMntVolItem:GetErro(),STR0016) // Verifique os dados informados
			lRet := .F.
		EndIf
	EndIf
	If lRet .And. oMntVolItem:oMntVol:GetStatus() == "3"
		GerEtqVol() // Se não gerar as etiquetas, não impede a gravação
	EndIf
	If lRet .And. oView != Nil
		oView:setInsertMessage("SIGAWMS",WmsFmtMsg(STR0030,{{"[VAR01]",oMntVolItem:oVolume:GetCodVol()}})) // "Volume [VAR01] inserido com sucesso."
	EndIf

	If lRet .AND. lExistBloc
		ExecBlock("WMS391CM",.F.,.F.,{oMntVolItem:oVolume:GetCodVol(), oMntVolItem:GetPedido()})
	Endif

Return lRet

//-------------------------------------------------------------------//
//------------Função de geração de etiquetas dos volumes-------------//
//-------------------------------------------------------------------//
Static Function GerEtqVol()
Local aAreaAnt  := GetArea()
Local lRet      := .T.
Local cLocImp   := SuperGetMV('MV_WMSLOCI',.F.,'')
Local lLocImp   := .T.
Local cQuery    := ""
Local cAliasDCU := ""
Local lExecBlc  := !SuperGetMV("MV_WMSNEW",.F.,.F.) .And. ExistBlock("WMSR410A")

	// Pergunta se será feita a impressão da Etiqueta
	If WmsQuestion(STR0011,"SIGAWMS") // Deseja imprimir as etiquetas de Volume?
		If Empty(cLocImp)
			cLocImp := Space(TamSX3("CB5_CODIGO")[1])
			DEFINE MSDIALOG oDlgLI TITLE STR0012 From 50,50 to 120,280 PIXEL // Informe local da impressão

				@ 06,05 SAY STR0013 SIZE 50,8 OF oDlgLI PIXEL // Local de Impressão:"
				@ 05,60 MSGET oGetLI VAR cLocImp F3 'CB5' SIZE 50,06 WHEN .T. PICTURE '@!' OF oDlgLI PIXEL
				DEFINE SBUTTON FROM 21,083 TYPE 1 ACTION (nOpcLI := 1,oDlgLI:End()) ENABLE Of oDlgLI

			ACTIVATE DIALOG oDlgLI CENTERED

			If !CB5SetImp(cLocImp,IsTelNet())
				WmsMessage(STR0014,WMSA391A16,1) // Local de impressão inválido!
				lLocImp := .F.
			EndIf

		ElseIf !CB5SetImp(CBRLocImp('MV_WMSLOCI'),IsTelNet())
			WmsMessage(STR0014,WMSA391A17) // Local de impressão inválido!
			lLocImp := .F.
		EndIf
		If lLocImp
			cQuery := "SELECT DCU_CODVOL"
			cQuery +=  " FROM "+RetSqlName('DCU')+" DCU"
			cQuery += " WHERE DCU_FILIAL = '"+xFilial('DCU')+"'"
			cQuery +=   " AND DCU_CARGA = '"+oMntVolItem:GetCarga()+"'"
			cQuery +=   " AND DCU_PEDIDO = '"+oMntVolItem:GetPedido()+"'"
			cQuery +=   " AND DCU_CODMNT = '"+oMntVolItem:GetCodMnt()+"'"
			cQuery +=   " AND DCU.D_E_L_E_T_ = ' '"
			cAliasDCU := GetNextAlias()
			DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasDCU,.F.,.T.)
			Do While (cAliasDCU)->(!Eof())
				If lExecBlc
					ExecBlock("WMSR410A",.F.,.F.,{(cAliasDCU)->DCU_CODVOL,.T.})
				Else
					WMSR410A((cAliasDCU)->DCU_CODVOL,.T.)
				Endif
				(cAliasDCU)->(DbSkip())
			EndDo

			(cAliasDCU)->(DbCloseArea())
			MSCBCLOSEPRINTER()
		EndIf
	EndIf

	RestArea(aAreaAnt)
Return lRet
//------------------------------------------------------------------
// Verifica se o produto distribuição realizada
//------------------------------------------------------------------
Function WMA391AQTD(cCarga,cPedido,cPrdori,cProduto,cLoteCtl,cNumLote,nQtdMnt)
Local lRet        := .T.
Local oMntVolItem := Nil
Local oDisSepItem := Nil
Local oProdComp   := Nil
Local aDisSep     := {}
Local nQtdOriMnt  := 0
Local nQtdEmbal   := 0
Local nQtdDis     := 0
Local nQtdOri     := 0
Local nQtdSDi     := 0
Local nQtdMult    := 0
Local nQtdMntAux  := 0
Local nI          := 0
Local cProdutAux  := ""
Local cPrdOriAux  := ""

Default cCarga   := Space(TamSX3("DCT_CARGA")[1])
Default cPedido  := Space(TamSX3("DCT_PEDIDO")[1])
Default cPrdOri  := Space(TamSX3("DCT_PRDORI")[1])
Default cProduto := Space(TamSX3("DCT_CODPRO")[1])
Default cLoteCtl := Space(TamSX3("DCT_LOTE")[1])
Default cNumLote := Space(TamSX3("DCT_SUBLOT")[1])
Default nQtdMnt  := 0

	oProdComp := WMSDTCProdutoComponente():New()
	oProdComp:SetPrdOri(cPrdOri)
	oProdComp:SetProduto(cProduto)
	oProdComp:EstProduto()
	aProduto := oProdComp:GetArrProd()

	For nI := 1 To Len(aProduto)
		cProdutAux := aProduto[nI][1]
		cPrdOriAux := aProduto[nI][3]
		nQtdMult   := aProduto[nI][2]
		nQtdMntAux := nQtdMnt * nQtdMult

		//Valida se possui distribuição de separação, apenas se já não foi validado o volume
		If QtdComp(nQtdMnt) > QtdComp(0)
			oMntVolItem := WMSDTCMontagemVolumeItens():New()
			oMntVolItem:SetCarga(cCarga)
			oMntVolItem:SetPedido(cPedido)
			oMntVolItem:SetPrdOri(cPrdOriAux)
			oMntVolItem:SetProduto(cProdutAux)
			oMntVolItem:SetLoteCtl(cLoteCtl)
			oMntVolItem:SetNumLote(cNumLote)
			// Atribui o codigo da montagem do modelo de dados
			oMntVolItem:SetCodMnt(oMntVolItem:oMntVol:FindCodMnt())
			// Busca a quantidade origem
			aMntVol := oMntVolItem:CalcQtdMnt()
			nQtdOriMnt := aMntVol[1] // Quantidade total origem
			nQtdEmbal  := aMntVol[2] // Quantidade total montada
			If QtdComp(nQtdOriMnt) > QtdComp(0)
				oDisSepItem := WMSDTCDistribuicaoSeparacaoItens():New()
				//Valida se possui distribuição de separação, apenas se já não foi validado o volume
				oDisSepItem:SetCarga(cCarga)
				oDisSepItem:SetPedido(cPedido)
				oDisSepItem:SetPrdOri(cPrdOriAux)
				oDisSepItem:SetProduto(cProdutAux)
				oDisSepItem:SetLoteCtl(cLoteCtl)
				oDisSepItem:SetNumLote(cNumLote)
				// Busca quantidade sumarizada da distribuição de separação
				aDisSep := oDisSepItem:ChkQtdDis(oMntVolItem:GerAIdDCF())
				nQtdOri := aDisSep[1] // Quantidade original de montagens de volume com distribuição de separação
				nQtdDis := aDisSep[2] - nQtdEmbal // Quantidade distribuida
				nQtdSDi := nQtdOriMnt - nQtdOri // Calcula a diferença entre a quantidade a montar e a distribuir.
				If QtdComp(nQtdOri) > QtdComp(0) .And. QtdComp(nQtdMntAux) > QtdComp(nQtdDis + nQtdSDi)
					WmsMessage(WmsFmtMsg(STR0017,{{"[VAR01]",cProdutAux}}),WMSA391A13)  //Quantidade do produto [VAR01] da montagem não possui distribuição de separação, primeiro realize a distribuição!
					lRet := .F.
				EndIf
			EndIf
		EndIf
		If !lRet
			Exit
		EndIf
	Next nI
Return lRet
