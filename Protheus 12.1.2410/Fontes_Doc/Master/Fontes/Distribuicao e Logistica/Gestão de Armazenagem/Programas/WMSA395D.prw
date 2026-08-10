#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "WMSA395D.CH"

/*
+---------+--------------------------------------------------------------------+
|Função   | WMSA395D - Geração de Volume Automático Cross-Docking Monitor      |
+---------+--------------------------------------------------------------------+
|Objetivo | Permite efetuar a seleção de uma listagem de itens do saldo do     |
|         | endereço para efetuar a geração de volume cross docking automático |
|         | sem precisar informar produto e quantidade de forma manual um a um.|
+---------+--------------------------------------------------------------------+
*/

#DEFINE WMSA395D01 "WMSA395D01"
#DEFINE WMSA395D02 "WMSA395D02"

Static __lMarkAll := .T.
Static __nMarkRec := 0
Static oMntVolItem := WMSDTCVolumeCrossDockingItens():New()

//------------------------------------------------------------------------------
// Função para aparecer no inspetor de objetos
//------------------------------------------------------------------------------
Function WMSA395D()
Return Nil

//------------------------------------------------------------------------------
// ModelDef
//------------------------------------------------------------------------------
Static Function ModelDef()
Local aColsSX3 := {}
Local oModel   := Nil
Local oStrD0N  := FWFormStruct(1,"D0N")
Local oStrD0O  := FWFormStruct(1,"D0O")

	oStrD0N:SetProperty("*",MODEL_FIELD_OBRIGAT,.F.)
	oStrD0O:SetProperty("*",MODEL_FIELD_OBRIGAT,.F.)

	oStrD0N:SetProperty("D0N_LOCAL",MODEL_FIELD_INIT,FwBuildFeature(STRUCT_FEATURE_INIPAD,"SBE->BE_LOCAL"))
	oStrD0N:SetProperty("D0N_ENDER",MODEL_FIELD_INIT,FwBuildFeature(STRUCT_FEATURE_INIPAD,"SBE->BE_LOCALIZ"))
	oStrD0N:SetProperty("D0N_CODVOL",MODEL_FIELD_INIT,FwBuildFeature(STRUCT_FEATURE_INIPAD,"PadL(CBProxCod('MV_WMSNVOL'),TamSX3('D0N_CODVOL')[1],'0')"))
	oStrD0N:SetProperty("D0N_DATINI",MODEL_FIELD_INIT,FwBuildFeature(STRUCT_FEATURE_INIPAD,"dDataBase"))
	oStrD0N:SetProperty("D0N_HORINI",MODEL_FIELD_INIT,FwBuildFeature(STRUCT_FEATURE_INIPAD,"Time()"))
	
	oStrD0N:AddField(BuscarSX3('BE_DESCRIC',,aColsSX3),aColsSX3[1],'D0N_DESEND','C',aColsSX3[3],aColsSX3[4],Nil,{||.T.},Nil,.F.,,.T.,.F.,.T.)

	// cID     Identificador do modelo
	// bPre    Code-Block de pre-edição do formulário de edição. Indica se a edição esta liberada
	// bPost   Code-Block de validação do formulário de edição
	// bCommit Code-Block de persistência do formulário de edição
	// bCancel Code-Block de cancelamento do formulário de edição
	oModel := MPFormModel():New("WMSA395D", /*bPre*/, {|oModel| ValidMdl(oModel)},{|oModel| CommitMdl(oModel)}, /*bCancel*/)
	// cId          Identificador do modelo
	// cOwner       Identificador superior do modelo
	// oModelStruct Objeto com  a estrutura de dados
	// bPre         Code-Block de pré-edição do formulário de edição. Indica se a edição esta liberada
	// bPost        Code-Block de validação do formulário de edição
	// bLoad        Code-Block de carga dos dados do formulário de edição
	oModel:AddFields("WMSA395DD0N", Nil, oStrD0N,/*bPre*/,/*bPost*/,/*bLoad*/)
	oModel:AddGrid("WMSA395DD0O","WMSA395DD0N",oStrD0O,/*bPre*/,/*bPost*/,/*bLoad*/)
	oModel:SetRelation("WMSA395DD0O",{{"D0O_FILIAL","'"+xFilial("D0O")+"'"},{"D0O_CODVOL","D0N_CODVOL"}},D0O->(IndexKey(1)))
	oModel:GetModel("WMSA395DD0O"):SetOptional(.T.)
	
	oModel:SetDescription(STR0001) //"Montar Volume"
	oModel:SetActivate({|oModel| ActiveModel(oModel)})
Return oModel

//----------------------------------------------------------
// ViewDef
//----------------------------------------------------------
Static Function ViewDef()
Local aColsSX3 := {}
Local oModel   := FWLoadModel('WMSA395D')
Local oStrD0N  := FWFormStruct(2,"D0N")
Local oView    := FWFormView():New()
Local oBrowse  := Nil
Local nX       := 0
Local cOrd     := ""

	// Elimina os campos que não quer visualizar
	oStrD0N:RemoveField("D0N_DATFIM")
	oStrD0N:RemoveField("D0N_HORFIM")
	oStrD0N:RemoveField("D0N_TMPMNT")
	// Busca a posição do endereço para colocar a descrição depois
	nX := aScan(oStrD0N:aFields,{|x| x[1] == "D0N_ENDER"})
	cOrd := Soma1(oStrD0N:aFields[nX,2])
	oStrD0N:AddField('D0N_DESEND',cOrd,BuscarSX3('BE_DESCRIC',,aColsSX3),aColsSX3[1],Nil,'GET',aColsSX3[2],Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,.T.)
	// Reordena os outros campos
	For nX := (nX+1) To (Len(oStrD0N:aFields)-1)
		cOrd := Soma1(cOrd)
		oStrD0N:aFields[nX,2] := cOrd
	Next
	oStrD0N:SetProperty('*',MVC_VIEW_CANCHANGE,.F.)
	// Objeto do model a se associar a view.
	oView:SetModel(oModel)
	oView:CreateHorizontalBox( 'MASTER' , 25,/*cIDOwner*/,/*lFixPixel*/,/*cIDFolder*/,/*cIDSheet*/ )
	oView:AddField('WMSA395DD0N' , oStrD0N)
	oView:CreateHorizontalBox( 'DETAIL' , 75,/*cIDOwner*/,/*lFixPixel*/,/*cIDFolder*/,/*cIDSheet*/ )
	oView:AddOtherObject('WMSA395DD0O', {|oPanel| MontaBrw(oPanel,oView,oModel,@oBrowse)})
	// Associa um View a um box
	oView:SetOwnerView('WMSA395DD0N', 'MASTER')
	oView:SetOwnerView('WMSA395DD0O', 'DETAIL')
	oView:SetUseCursor(.F.)
Return oView

//------------------------------------------------------------------------------
// Ao ativar o model, inicializa o objeto com os valores do model
//------------------------------------------------------------------------------
Static Function ActiveModel(oModel)
Local oModelD0N := oModel:GetModel("WMSA395DD0N")
	oModelD0N:LoadValue('D0N_LOCAL', oModelD0N:GetValue('D0N_LOCAL')) // Para forçar a simulação de alteração
	oModelD0N:LoadValue('D0N_DESEND',Posicione("SBE",1,xFilial("SBE")+oModelD0N:GetValue('D0N_LOCAL')+oModelD0N:GetValue("D0N_ENDER"),"BE_DESCRIC"))
	oMntVolItem:oVolume:SetArmazem(oModelD0N:GetValue("D0N_LOCAL"))
	oMntVolItem:oVolume:SetEnder(oModelD0N:GetValue("D0N_ENDER"))
	oMntVolItem:oVolume:SetCodVol(oModelD0N:GetValue("D0N_CODVOL"))
	oMntVolItem:oVolume:SetDtIni(oModelD0N:GetValue("D0N_DATINI"))
	oMntVolItem:oVolume:SetHrIni(oModelD0N:GetValue("D0N_HORINI"))
Return .T.
//------------------------------------------------------------------------------
// Monta o browse para seleção dos volumes
//------------------------------------------------------------------------------
Static Function MontaBrw(oPanel,oView,oModel,oBrowse)
Local aColsSX3 := {}
Local aFldCols := {}
Local aBrwCols := {}
Local nX       := 0

	AAdd(aFldCols,{"D14_PRODUT",BuscarSX3("D14_PRODUT", ,aColsSX3),"C",aColsSX3[3],aColsSX3[4],aColsSX3[2],{||D14->D14_PRODUT}})
	AAdd(aFldCols,{"D14_DESPRD",BuscarSX3("B1_DESC"   , ,aColsSX3),"C",aColsSX3[3],aColsSX3[4],aColsSX3[2],{||Posicione("SB1",1,xFilial("SB1")+D14->D14_PRODUT,"B1_DESC")}})
	AAdd(aFldCols,{"D14_LOTECT",BuscarSX3("D14_LOTECT", ,aColsSX3),"C",aColsSX3[3],aColsSX3[4],aColsSX3[2],{||D14->D14_LOTECT}})
	AAdd(aFldCols,{"D14_NUMLOT",BuscarSX3("D14_NUMLOT", ,aColsSX3),"C",aColsSX3[3],aColsSX3[4],aColsSX3[2],{||D14->D14_NUMLOT}})
	AAdd(aFldCols,{"D14_SLDEST",BuscarSX3("D14_QTDEST", ,aColsSX3),"N",aColsSX3[3],aColsSX3[4],aColsSX3[2],{||D14->(D14_QTDEST-(D14_QTDSPR+D14_QTDEMP+D14_QTDBLQ))}})
	AAdd(aFldCols,{"D14_PRDORI",BuscarSX3("D14_PRDORI", ,aColsSX3),"C",aColsSX3[3],aColsSX3[4],aColsSX3[2],{||D14->D14_PRDORI}})

	__lMarkAll := .T.
	__nMarkRec := 0
	oBrowse := FWMarkBrowse():New() // FWMBrowse():New()
	oBrowse:SetMenuDef("") // Para não apresentar menu
	oBrowse:DisableDetails()
	oBrowse:SetOwner(oPanel)
	oBrowse:SetDescription(STR0002) //"Saldo Estoque Endereço"
	oBrowse:SetAlias("D14")
	oBrowse:SetFieldMark("D14_OK")
	oBrowse:SetAfterMark({||AfterMark(oBrowse,oView,oModel)})
	oBrowse:SetAllMark({||AllMark(oBrowse,oView,oModel)})
	oBrowse:SetFilterDefault("@D14_LOCAL = '"+SBE->BE_LOCAL+"' AND D14_ENDER = '"+SBE->BE_LOCALIZ+"' AND D14_QTDEST-(D14_QTDSPR+D14_QTDEMP+D14_QTDBLQ) > 0")
	oBrowse:SetOnlyFields({''}) // Para não carregar os campos da tabela inteira
	// Adicionando os campos ao browse
	For nX := 1 To Len(aFldCols)
		oColumn := FWBrwColumn():New()
		oColumn:SetID(aFldCols[nX,1])
		oColumn:SetTitle(aFldCols[nX,2])
		oColumn:SetType(aFldCols[nX,3])
		oColumn:SetSize(aFldCols[nX,4])
		oColumn:SetDecimal(aFldCols[nX,5])
		oColumn:SetPicture(aFldCols[nX,6])
		oColumn:SetData(aFldCols[nX,7])
		AAdd(aBrwCols,oColumn)
	Next
	oBrowse:SetColumns(aBrwCols)
	oBrowse:Activate()
Return Nil

//------------------------------------------------------------------------------
// Função para marcação dos registros
//------------------------------------------------------------------------------
Static Function AfterMark(oBrowse,oView,oModel)

	Iif(oBrowse:IsMark(),__nMarkRec--,__nMarkRec++)
	__lMarkAll := __nMarkRec > 0 // Para forçar se clicar no header marcar todos
	// Se marcado deve adicionar no model
	UpdMdlD0O(oModel,oBrowse:Alias(),oBrowse:IsMark())
	oView:SetModified(.T.)
Return .T.

//------------------------------------------------------------------------------
// Função para marcação de todos os registros
//------------------------------------------------------------------------------
Static Function AllMark(oBrowse,oView,oModel)
Local cAlias    := oBrowse:Alias()
Local oModelD0O := oModel:GetModel("WMSA395DD0O")
Local nI        := 0
	// Apaga todas as linhas do model
	For nI := oModelD0O:Length() To 1 Step -1
		oModelD0O:GoLine(nI)
		oModelD0O:DeleteLine(.T.,.T.)
	Next
	__nMarkRec := 0
	(cAlias)->(DbGoTop())
	While (cAlias)->(!Eof())
		RecLock(cAlias,.F.)
		(cAlias)->D14_OK := Iif(__lMarkAll,oBrowse:cMark,Space(Len(oBrowse:cMark)))
		(cAlias)->(MsUnlock())
		If __lMarkAll
			UpdMdlD0O(oModel,cAlias,.T.)
			__nMarkRec++
		EndIf
		(cAlias)->(DbSkip())
	EndDo
	__lMarkAll := !__lMarkAll
	oView:SetModified(.T.)
	oBrowse:Refresh (.T.)
Return .T.

//------------------------------------------------------------------------------
// Função para adicionar os itens marcados ao model D0O
//------------------------------------------------------------------------------
Static Function UpdMdlD0O(oModel,cAlias,lMarkRec)
Local oModelD0O := oModel:GetModel("WMSA395DD0O")

	If lMarkRec
		oModelD0O:GoLine(oModelD0O:Length())
		If !oModelD0O:IsEmpty()
			oModelD0O:AddLine()
		EndIf
		oModelD0O:SetValue("D0O_PRDORI", (cAlias)->D14_PRDORI)
		oModelD0O:SetValue("D0O_CODPRO", (cAlias)->D14_PRODUT)
		oModelD0O:SetValue("D0O_LOTECT", (cAlias)->D14_LOTECT)
		oModelD0O:SetValue("D0O_NUMLOT", (cAlias)->D14_NUMLOT)
		oModelD0O:SetValue("D0O_QUANT" , (cAlias)->(D14_QTDEST-(D14_QTDSPR+D14_QTDEMP+D14_QTDBLQ)))
	Else
		If oModelD0O:SeekLine({{"D0O_PRDORI", (cAlias)->D14_PRDORI},{"D0O_CODPRO", (cAlias)->D14_PRODUT},{"D0O_LOTECT", (cAlias)->D14_LOTECT},{"D0O_NUMLOT", (cAlias)->D14_NUMLOT}})
			oModelD0O:DeleteLine(.T.,.T.)
		EndIf
	EndIf
Return

//------------------------------------------------------------------------------
// Efetua as validações do model antes da inclusão, reavaliando os volumes
//------------------------------------------------------------------------------
Static Function ValidMdl(oModel)
Local oModelD0N := oModel:GetModel("WMSA395DD0N")
Local oModelD0O := oModel:GetModel("WMSA395DD0O")
Local lAchou    := .F.
Local lRet      := .T.
Local nI        := 0
Local nQtde     := 0
Local nToler1UM := SuperGetMV("MV_NTOL1UM",.F.,0)

	For nI := 1 To oModelD0O:Length()
		oModelD0O:GoLine(nI)
		If !Empty(oModelD0O:GetValue("D0O_CODPRO"))
			lAchou := .T.
			oMntVolItem:SetProduto(oModelD0O:GetValue("D0O_CODPRO"))
			oMntVolItem:SetLoteCtl(oModelD0O:GetValue("D0O_LOTECT"))
			oMntVolItem:SetNumLote(oModelD0O:GetValue("D0O_NUMLOT"))
			oMntVolItem:SetPrdOri(oModelD0O:GetValue("D0O_PRDORI"))
			oMntVolItem:QtdPrdVol() // Valida novamente a quantidade em estoque
			nQtde := oModelD0O:GetValue("D0O_QUANT")
			If QtdComp(nQtde) > QtdComp(oMntVolItem:GetQuant()) .And.;
				QtdComp(Abs(oMntVolItem:GetQuant()-nQtde)) > QtdComp(nToler1UM)
				oModel:SetErrorMessage(oModelD0O:GetId(),"D0O_QUANT",,,WMSA395D02,WmsFmtMsg(STR0005,{{"[VAR01]",oModelD0O:GetValue("D0O_CODPRO")},{"[VAR02]",AllTrim(Str(oMntVolItem:GetQuant()))},{"[VAR03]",AllTrim(Str(nQtde))}}),STR0006) // "Para o produto [VAR01] a quantidade de saldo disponível ([VAR02]) é menor que a quantidade solicitada [VAR03].", "Informe uma quantidade menor de acordo com o saldo disponível."
				lRet := .F.
				Exit
			EndIf
		EndIf
	Next nI
	
	If !lAchou
		oModel:SetErrorMessage(oModelD0N:GetId(),"D0N_ENDER",,,WMSA395D01,STR0003,STR0004) //"Não foi selecionado nenhum item do estoque para ser adicionado ao volume.","Selecione ao menos um item de estoque para geração do volume."
		lRet := .F.
	EndIf

Return lRet

//------------------------------------------------------------------------------
// Efetua a gravação dos dados do modelo nas tabelas oficiais gerando o pedido
//------------------------------------------------------------------------------
Static Function CommitMdl(oModel)
Local lRet      := .T.
Local oModelD0O := oModel:GetModel("WMSA395DD0O")
Local aProdutos := {}
Local nI        := 0
Local oView     := FWViewActive()

	For nI := 1 To oModelD0O:Length()
		oModelD0O:GoLine(nI)
		oMntVolItem:SetProduto(oModelD0O:GetValue("D0O_CODPRO"))
		oMntVolItem:SetLoteCtl(oModelD0O:GetValue("D0O_LOTECT"))
		oMntVolItem:SetNumLote(oModelD0O:GetValue("D0O_NUMLOT"))
		oMntVolItem:SetPrdOri(oModelD0O:GetValue("D0O_PRDORI"))
		If !oMntVolItem:LoadPrdVol(aProdutos,oModelD0O:GetValue("D0O_QUANT"))
			lRet := .F.
			Exit
		EndIf
	Next nI

	If lRet
		lRet := oMntVolItem:MntPrdVol(aProdutos)
	EndIf
	If lRet .And. oView != Nil
		oView:setInsertMessage("SIGAWMS",WmsFmtMsg(STR0007,{{"[VAR01]",oMntVolItem:oVolume:GetCodVol()}})) // "Volume [VAR01] inserido com sucesso."
	EndIf
Return lRet
