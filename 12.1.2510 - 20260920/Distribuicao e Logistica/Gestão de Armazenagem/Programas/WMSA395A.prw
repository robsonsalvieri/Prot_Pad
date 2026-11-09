#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWEDITPANEL.CH"
#INCLUDE "WMSA395A.CH"

/*
+---------+--------------------------------------------------------------------+
|Função   | WMSA395A - Regras de Montagem de Volumes Cross-Docking Monitor     |
+---------+--------------------------------------------------------------------+
|Objetivo | Permite efetuar a montagem de volumes em endereços cross-docking   |
|         | de forma manual através do monitor de volumes cross-docking.       |
+---------+--------------------------------------------------------------------+
*/

#DEFINE WMSA395A01 "WMSA395A01"
#DEFINE WMSA395A02 "WMSA395A02"
#DEFINE WMSA395A03 "WMSA395A03"
#DEFINE WMSA395A04 "WMSA395A04"
#DEFINE WMSA395A05 "WMSA395A05"
#DEFINE WMSA395A06 "WMSA395A06"
#DEFINE WMSA395A07 "WMSA395A07"

Static __lHasLot   := SuperGetMV("MV_WMSLOTE",.F.,.T.)
Static oMntVolItem := WMSDTCVolumeCrossDockingItens():New()

//------------------------------------------------------------------------------
// Função para aparecer no inspetor de objetos
//------------------------------------------------------------------------------
Function WMSA395A()
Return Nil

//-------------------------------------------------------------------//
//---------------------------ModelDef--------------------------------//
//-------------------------------------------------------------------//
Static Function ModelDef()
Local oModel    := Nil
Local oStrD0N   := FWFormStruct(1,"D0N")
Local oStrD0OFld:= FWFormStruct(1,"D0O")
Local oStrD0OGrd:= FWFormStruct(1,"D0O")
Local aColsSX3  := {}

	oStrD0N:SetProperty("*",MODEL_FIELD_OBRIGAT,.F.)
	oStrD0OFld:SetProperty("*",MODEL_FIELD_OBRIGAT,.F.)
	oStrD0OGrd:SetProperty("*",MODEL_FIELD_OBRIGAT,.F.)

	oStrD0N:SetProperty("D0N_LOCAL",MODEL_FIELD_INIT,FwBuildFeature(STRUCT_FEATURE_INIPAD,"SBE->BE_LOCAL"))
	oStrD0N:SetProperty("D0N_ENDER",MODEL_FIELD_INIT,FwBuildFeature(STRUCT_FEATURE_INIPAD,"SBE->BE_LOCALIZ"))
	oStrD0N:SetProperty("D0N_CODVOL",MODEL_FIELD_INIT,FwBuildFeature(STRUCT_FEATURE_INIPAD,"PadL(CBProxCod('MV_WMSNVOL'),TamSX3('D0N_CODVOL')[1],'0')"))
	oStrD0N:SetProperty("D0N_DATINI",MODEL_FIELD_INIT,FwBuildFeature(STRUCT_FEATURE_INIPAD,"dDataBase"))
	oStrD0N:SetProperty("D0N_HORINI",MODEL_FIELD_INIT,FwBuildFeature(STRUCT_FEATURE_INIPAD,"Time()"))
	oStrD0OFld:SetProperty("D0O_QUANT",MODEL_FIELD_INIT,FwBuildFeature(STRUCT_FEATURE_INIPAD,"1"))

	oStrD0OFld:SetProperty("D0O_CODPRO",MODEL_FIELD_VALID,FWBuildFeature(STRUCT_FEATURE_VALID,"WMS395VFld(A,B,C)"))
	oStrD0OFld:SetProperty("D0O_LOTECT",MODEL_FIELD_VALID,FWBuildFeature(STRUCT_FEATURE_VALID,"WMS395VFld(A,B,C)"))
	oStrD0OFld:SetProperty("D0O_NUMLOT",MODEL_FIELD_VALID,FWBuildFeature(STRUCT_FEATURE_VALID,"WMS395VFld(A,B,C)"))

	oStrD0OFld:SetProperty("D0O_LOTECT",MODEL_FIELD_WHEN,FwBuildFeature(STRUCT_FEATURE_WHEN,"WMS395WFld(A,B)"))
	oStrD0OFld:SetProperty("D0O_NUMLOT",MODEL_FIELD_WHEN,FwBuildFeature(STRUCT_FEATURE_WHEN,"WMS395WFld(A,B)"))

	oModel := MPFormModel():New("WMSA395A",/*bPre*/,{|oModel| ValidMdl(oModel)},{|oModel| CommitMdl(oModel)},/*bCancel*/)

	oModel:AddFields("WMSA395AD0N",Nil,oStrD0N,/*bPre*/,/*bPost*/,/*bLoad*/)
	oModel:AddFields("WMSA395AD0OF","WMSA395AD0N",oStrD0OFld,/*bPre*/,/*bPost*/,/*bLoad*/)
	oModel:AddGrid("WMSA395AD0OG","WMSA395AD0OF",oStrD0OGrd,/*bPre*/,/*bPost*/,/*bLoad*/)

	oModel:SetRelation("WMSA395AD0OF",{{"D0O_FILIAL","'"+xFilial("D0O")+"'"},{"D0O_CODVOL","D0N_CODVOL"}},D0O->(IndexKey(1)))
	oModel:SetRelation("WMSA395AD0OG",{{"D0O_FILIAL","'"+xFilial("D0O")+"'"},{"D0O_CODVOL","D0O_CODVOL"}},D0O->(IndexKey(1)))

	oModel:AddRules("WMSA395AD0OF","D0O_LOTECT","WMSA395AD0OF","D0O_CODPRO",3)
	oModel:AddRules("WMSA395AD0OF","D0O_NUMLOT","WMSA395AD0OF","D0O_LOTECT",3)

	oModel:GetModel("WMSA395AD0OF"):SetOnlyQuery(.T.)
	oModel:GetModel("WMSA395AD0OG"):SetOptional(.T.)
	oModel:GetModel("WMSA395AD0OG"):SetNoInsertLine(.T.)

	oModel:SetActivate({|oModel| ActivMdl(oModel)})
Return oModel

//-------------------------------------------------------------------//
//-----------------------------ViewDef-------------------------------//
//-------------------------------------------------------------------//
Static Function ViewDef()
Local oModel    := ModelDef()
Local oView     := FWFormView():New()
Local oStrD0OF  := FWFormStruct(2,"D0O")
Local oStrD0OG  := FWFormStruct(2,"D0O")
Local aColsSX3  := {}

	oStrD0OF:RemoveField("D0O_CODVOL")
	oStrD0OF:RemoveField("D0O_PRDORI")
	oStrD0OF:RemoveField("D0O_CODOPE")
	oStrD0OF:RemoveField("D0O_NOMOPE")

	oStrD0OF:SetProperty("D0O_QUANT" ,MVC_VIEW_ORDEM,"00")
	oStrD0OF:SetProperty("D0O_CODPRO",MVC_VIEW_ORDEM,"01")

	oStrD0OF:SetProperty("D0O_QUANT" ,MVC_VIEW_CANCHANGE,.T.)
	oStrD0OF:SetProperty("D0O_CODPRO",MVC_VIEW_CANCHANGE,.T.)

	oStrD0OG:RemoveField("D0O_CODVOL")
	oStrD0OG:RemoveField("D0O_CODOPE")
	oStrD0OG:RemoveField("D0O_NOMOPE")

	// Objeto do model a se associar a view.
	oView:SetModel(oModel)

	oView:CreateHorizontalBox("MASTER",35,/*cIDOwner*/,/*lFixPixel*/,/*cIDFolder*/,/*cIDSheet*/)
	oView:AddField("WMSA395AD0OF",oStrD0OF)
	oView:SetViewProperty("WMSA395AD0OF","SETLAYOUT",{FF_LAYOUT_VERT_DESCR_TOP,5})
	oView:CreateHorizontalBox("DETAIL",65,/*cIDOwner*/,/*lFixPixel*/,/*cIDFolder*/,/*cIDSheet*/ )
	oView:AddGrid("WMSA395AD0OG",oStrD0OG,,,{ || RegItnVol(oModel,oView)} )
	oView:SetOnlyView("WMSA395AD0OG")

	oView:EnableTitleView("WMSA395AD0OF", STR0001) // Produto
	oView:EnableTitleView("WMSA395AD0OG", STR0002) // Itens Volume

	// Associa um View a um box
	oView:SetOwnerView("WMSA395AD0OF", "MASTER")
	oView:SetOwnerView("WMSA395AD0OG", "DETAIL")
Return oView

//------------------------------------------------------------------------------
// Ao ativar o model, inicializa o objeto com os valores do model
//------------------------------------------------------------------------------
Static Function ActivMdl(oModel)
Local oModelD0N := oModel:GetModel("WMSA395AD0N")
Local oView     := FWViewActive()

	oMntVolItem:oVolume:SetArmazem(oModelD0N:GetValue("D0N_LOCAL"))
	oMntVolItem:oVolume:SetEnder(oModelD0N:GetValue("D0N_ENDER"))
	oMntVolItem:oVolume:SetCodVol(oModelD0N:GetValue("D0N_CODVOL"))
	oMntVolItem:oVolume:SetDtIni(oModelD0N:GetValue("D0N_DATINI"))
	oMntVolItem:oVolume:SetHrIni(oModelD0N:GetValue("D0N_HORINI"))
	oView:EnableTitleView("WMSA395AD0OF", STR0003+oModelD0N:GetValue("D0N_CODVOL")) // "Produto - Volume: "
Return .T.

//-----------------------------------------------------------------//
//--------Função responsável por validar a edição do campo---------//
//-----------------------------------------------------------------//
Function WMS395WFld(oModel,cField)
Local lRet    := .T.
	If cField == "D0O_LOTECT"
		lRet :=  __lHasLot .And. Rastro(oModel:GetValue("D0O_CODPRO"))
	ElseIf cField == "D0O_NUMLOT"
		lRet := __lHasLot .And. Rastro(oModel:GetValue("D0O_CODPRO"),"S")
	EndIf
Return lRet

//-----------------------------------------------------------------//
// Função de validação dos campos
//-----------------------------------------------------------------//
Function WMS395VFld(oModel,cField,xValue)
Local lRet := .T.
Local cCodBar  := ""
Local cProduto := ""
Local cLoteCtl := ""
Local cSubLote := ""
Local nQtde    := 0

	If cField == "D0O_CODPRO"
		cCodBar := xValue
		lRet := VldPrdLot(oModel,@cProduto,@cLoteCtl,@cSubLote,@nQtde,@cCodBar)
	ElseIf cField == "D0O_LOTECT"
		lRet := VldLoteCtl(oModel,xValue)
	ElseIf cField == "D0O_NUMLOT"
		lRet := VldSubLote(oModel,xValue)
	EndIf
Return lRet

//----------------------------------------------------------------------------------
// Valida o produto informado, verificando se é um código de barras ou etiqueta CB0
//----------------------------------------------------------------------------------
Static Function VldPrdLot(oModel,cProduto,cLoteCtl,cSubLote,nQtde,cCodBar)
Local lRet      := .T.
Local aProduto  := {}
Local lAchou    := .F.

	If Empty(cCodBar)
		Return .F.
	EndIf
	// Deve zerar estas informações, pois pode haver informação de outra etiqueta
	cProduto := Space(TamSx3("D0O_CODPRO")[1])
	cLoteCtl := Space(TamSx3("D0O_LOTECT")[1])
	cSubLote := Space(TamSx3("D0O_NUMLOT")[1])
	nQtde    := 0
	aProduto := CBRetEtiEAN(cCodBar)
	If Len(aProduto) > 0
		cProduto := aProduto[1]
		If ValType(aProduto[2]) == 'N'
			nQtde := Iif(aProduto[2] == 0,1,aProduto[2]) * oModel:GetValue("D0O_QUANT")
		EndIf
		cLoteCtl := Padr(aProduto[3],TamSx3("D0O_LOTECT")[1])
	Else
		aProduto := CBRetEti(cProduto, '01')
		If Len(aProduto) > 0
			cProduto := aProduto[1]
			nQtde    := Iif(aProduto[2] == 0,1,aProduto[2]) * oModel:GetValue("D0O_QUANT")
			cLoteCtl := Padr(aProduto[16],TamSx3("D0O_LOTECT")[1])
			cSubLote := Padr(aProduto[17],TamSx3("D0O_NUMLOT")[1])
		EndIf
		If Empty(aProduto)
			oModel:GetModel():SetErrorMessage(oModel:GetId(),"D0O_CODPRO",,,WMSA395A01,STR0004,STR0005) // "Código do produto é invalido!","Informe o código do produto ou o código de barras do produto desejado."
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
			oModel:GetModel():SetErrorMessage(oModel:GetId(),"D0O_CODPRO",,,WMSA395A02,STR0006,STR0007) // "Produto não possui saldo disponível no endereço para montagem de volumes.","Verifique o saldo por endereço do produto."
			lRet := .F.
		Else
			lRet := oModel:LoadValue("D0O_PRDORI",oMntVolItem:GetPrdOri())
		EndIf
	EndIf

	If lRet .And. !Empty(cLoteCtl)
		lRet := oModel:SetValue("D0O_LOTECT",cLoteCtl)
	EndIf
	If lRet .And. !Empty(cSubLote)
		lRet := oModel:SetValue("D0O_NUMLOT",cSubLote)
	EndIf
	If lRet .And. !Empty(nQtde)
		lRet := oModel:LoadValue("D0O_QUANT",nQtde)
	EndIf

	If !lRet
		cCodBar := Space(128)
		oModel:ClearField("D0O_CODPRO")
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
	//Deve validar se o produto/lote possui quantidade em estoque no endereço
	If QtdComp(oMntVolItem:GetQuant()) == 0
		oModel:GetModel():SetErrorMessage(oModel:GetId(),"D0O_LOTECT",,,WMSA395A03,STR0008,STR0007) // "Produto/Lote não possui saldo disponível no endereço para montagem de volumes.","Verifique o saldo por endereço do produto."
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
	//Deve validar se o produto/lote possui quantidade em estoque no endereço
	If QtdComp(oMntVolItem:GetQuant()) == 0
		oModel:GetModel():SetErrorMessage(oModel:GetId(),"D0O_NUMLOT",,,WMSA395A04,STR0009,STR0007) //"Produto/Rastro não possui saldo disponível no endereço para montagem de volumes.","Verifique o saldo por endereço do produto."
		Return .F.
	EndIf
Return .T.

//------------------------------------------------------------------------------
// Valida se a quantidade informada não ultrapassa o saldo no endereço
//-----------------------------------------------------------------------------
Static Function VldQtdSld(oModel,nQtde)
Local lRet := .T.
// Qtde. de tolerancia p/calculos com a 1UM. Usado qdo o fator de conv gera um dizima periodica
Local nToler1UM := SuperGetMV("MV_NTOL1UM",.F.,0)
	If Empty(nQtde)
		Return .F.
	EndIf

	If QtdComp(nQtde) > QtdComp(oMntVolItem:GetQuant()) .And.;
		QtdComp(Abs(oMntVolItem:GetQuant()-nQtde)) > QtdComp(nToler1UM)
		// O Help do formulário não era exibido neste momento, força exibição
		WmsMessage(WmsFmtMsg(STR0010,{{"[VAR01]",AllTrim(Str(oMntVolItem:GetQuant()))}}),WMSA395A05,5,.T.,,STR0011) // "Quantidade de saldo disponível ([VAR01]) menor que a quantidade solicitada.","Informe uma quantidade menor de acordo com o saldo disponível."
		lRet := .F.
	EndIf
Return lRet

//------------------------------------------------------------------------------
// Valida a transferência dos dados digitados pelo usuário no formulário para
// o grid sumarizando as quantidades quando necessário.
//------------------------------------------------------------------------------
Static Function RegItnVol(oModel,oView)
Local oModelD0N  := oModel:GetModel("WMSA395AD0N")
Local oModelD0OF := oModel:GetModel("WMSA395AD0OF")
Local oModelD0OG := oModel:GetModel("WMSA395AD0OG")
Local cPrdOri    := oModelD0OF:GetValue("D0O_PRDORI")
Local cProduto   := oModelD0OF:GetValue("D0O_CODPRO")
Local cLoteCtl   := oModelD0OF:GetValue("D0O_LOTECT")
Local cNumLote   := oModelD0OF:GetValue("D0O_NUMLOT")
Local nQuant     := 0
Local lConfirma  := .T.

	// Verifica produto
	If Empty(cProduto)
		lConfirma := .F.
	EndIf

	If lConfirma
		If __lHasLot .And. Rastro(cProduto)
			If Empty(cLoteCtl) // Verifica lote
				lConfirma := .F.
			EndIf
			If lConfirma .And. Rastro(cProduto,"S") .And. Empty(cNumLote) // Verifica sub-lote
				lConfirma := .F.
			EndIf
		Else
			oMntVolItem:QtdPrdVol() // Deve carregar as quantidades neste ponto
		EndIf
	EndIf

	// Verifica quantidade
	If lConfirma .And. oModelD0OF:GetValue("D0O_QUANT") <= 0
		lConfirma := .F.
	EndIf

	If lConfirma
		// Deve validar contra a quantidade que já está tela inclusive
		If oModelD0OG:SeekLine({{"D0O_PRDORI", cPrdOri},{"D0O_CODPRO", cProduto},{"D0O_LOTECT", cLoteCtl},{"D0O_NUMLOT", cNumLote}})
			nQuant := oModelD0OG:GetValue("D0O_QUANT") + oModelD0OF:GetValue("D0O_QUANT")
		Else
			nQuant := oModelD0OF:GetValue("D0O_QUANT")
		EndIf
		If !VldQtdSld(oModelD0OF,nQuant)
			lConfirma := .F.
		EndIf
	EndIf

	// Preenche modelo de dados
	If lConfirma
		oModelD0OG:SetNoInsertLine(.F.)
		// Cria itens na DCY
		If oModelD0OG:SeekLine({{"D0O_PRDORI", cPrdOri},{"D0O_CODPRO", cProduto},{"D0O_LOTECT", cLoteCtl},{"D0O_NUMLOT", cNumLote}})
			oModelD0OG:SetValue("D0O_QUANT", nQuant)
		Else
			oModelD0OG:GoLine(oModelD0OG:Length())
			If !oModelD0OG:IsEmpty()
				oModelD0OG:AddLine()
			EndIf

			oModelD0OG:SetValue("D0O_PRDORI", cPrdOri)
			oModelD0OG:SetValue("D0O_CODPRO", cProduto)
			oModelD0OG:SetValue("D0O_DESCR",  Posicione("SB1",1,xFilial("SB1")+cProduto,"B1_DESC"))
			oModelD0OG:SetValue("D0O_LOTECT", cLoteCtl)
			oModelD0OG:SetValue("D0O_NUMLOT", cNumLote)
			oModelD0OG:SetValue("D0O_QUANT" , nQuant)
		EndIf
		oModelD0OG:SetNoInsertLine(.T.)

		oModelD0OF:LoadValue("D0O_QUANT",1)
		oModelD0OF:ClearField("D0O_CODPRO")
		oModelD0OF:ClearField("D0O_DESCR")
		oModelD0OF:ClearField("D0O_LOTECT")
		oModelD0OF:ClearField("D0O_NUMLOT")
		oModelD0OG:GoLine(1)
		oView:Refresh()
	EndIf

	oView:GetViewObj("WMSA395AD0OF")[3]:getFWEditCtrl("D0O_CODPRO"):oCtrl:SetFocus()
Return lConfirma

//------------------------------------------------------------------------------
// Efetua as validações do módel antes da inclusão, reavaliando o saldo e não
// deixa incluir um volume sem ter itens informados.
//------------------------------------------------------------------------------
Static Function ValidMdl(oModel)
Local oModelD0N  := oModel:GetModel("WMSA395AD0N")
Local oModelD0OG := oModel:GetModel("WMSA395AD0OG")
Local nI         := 0
Local lRet       := .T.
Local lAchou     := .F.
Local nQtde      := 0
Local nToler1UM  := SuperGetMV("MV_NTOL1UM",.F.,0)

	If oModel:GetOperation() == MODEL_OPERATION_INSERT
		For nI := 1 To oModelD0OG:Length()
			oModelD0OG:GoLine(nI)
			If !Empty(oModelD0OG:GetValue("D0O_CODPRO"))
				lAchou := .T.
				oMntVolItem:SetProduto(oModelD0OG:GetValue("D0O_CODPRO"))
				oMntVolItem:SetLoteCtl(oModelD0OG:GetValue("D0O_LOTECT"))
				oMntVolItem:SetNumLote(oModelD0OG:GetValue("D0O_NUMLOT"))
				oMntVolItem:SetPrdOri(oModelD0OG:GetValue("D0O_PRDORI"))
				oMntVolItem:QtdPrdVol() // Valida novamente a quantidade em estoque
				nQtde := oModelD0OG:GetValue("D0O_QUANT")
				If QtdComp(nQtde) > QtdComp(oMntVolItem:GetQuant()) .And.;
					QtdComp(Abs(oMntVolItem:GetQuant()-nQtde)) > QtdComp(nToler1UM)
					oModel:SetErrorMessage(oModelD0OG:GetId(),"D0O_QUANT",,,WMSA395A06,WmsFmtMsg(STR0012,{{"[VAR01]",oModelD0OG:GetValue("D0O_CODPRO")},{"[VAR02]",AllTrim(Str(oMntVolItem:GetQuant()))},{"[VAR03]",AllTrim(Str(nQtde))}}),STR0011) // "Para o produto [VAR01] a quantidade de saldo disponível ([VAR02]) é menor que a quantidade solicitada [VAR03].", "Informe uma quantidade menor de acordo com o saldo disponível."
					lRet := .F.
					Exit
				EndIf
			EndIf
		Next nI

		If !lAchou
			oModel:SetErrorMessage(oModelD0OG:GetId(),"D0O_CODPRO",,,WMSA395A07,STR0013,STR0014) // "Não é possível inserir volumes sem itens.","Informe pelo menos um item para montagem de volumes."
			lRet := .F.
		EndIf

		If lRet
			oModelD0N:SetValue("D0N_FILIAL",xFilial("D0N"))
			oModelD0N:SetValue("D0N_DATFIM",dDataBase)
			oModelD0N:SetValue("D0N_HORFIM",Time())
		EndIf

	EndIf
Return lRet

//------------------------------------------------------------------------------
// Efetua a gravação dos dados do modelo nas tabelas oficiais
//------------------------------------------------------------------------------
Static Function CommitMdl(oModel)
Local lRet       := .T.
Local oModelD0OG := oModel:GetModel("WMSA395AD0OG")
Local aProdutos  := {}
Local nI         := 0
Local oView      := FWViewActive()

	For nI := 1 To oModelD0OG:Length()
		oModelD0OG:GoLine(nI)
		oMntVolItem:SetProduto(oModelD0OG:GetValue("D0O_CODPRO"))
		oMntVolItem:SetLoteCtl(oModelD0OG:GetValue("D0O_LOTECT"))
		oMntVolItem:SetNumLote(oModelD0OG:GetValue("D0O_NUMLOT"))
		oMntVolItem:SetPrdOri(oModelD0OG:GetValue("D0O_PRDORI"))
		If !oMntVolItem:LoadPrdVol(aProdutos,oModelD0OG:GetValue("D0O_QUANT"))
			lRet := .F.
			Exit
		EndIf
	Next nI

	If lRet
		lRet := oMntVolItem:MntPrdVol(aProdutos)
	EndIf
	If lRet .And. oView != Nil
		oView:setInsertMessage("SIGAWMS",WmsFmtMsg(STR0015,{{"[VAR01]",oMntVolItem:oVolume:GetCodVol()}})) // "Volume [VAR01] inserido com sucesso."
	EndIf
Return lRet
