#Include "loca104i.ch"
#INCLUDE 'TOTVS.CH'
#include 'FWMVCDEF.CH'
#INCLUDE 'FWEditPanel.CH '

/*/{Protheus.doc} MODELDEF
Definicão do modelo de 
@type function
@version 24.10 
@author Alexandre Circenis
@since 2/12/2025
@return variant, Modelo do romaneio
/*/
STATIC FUNCTION MODELDEF()
Local oModel   := MPFormModel():New( 'LOCA104I', /*bPreValidacao*/, /*bPosValidacao*/ , /*bCommit*/, /*bCancel*/ )
Local oStruFQW := FWFormStruct( 1, 'FQW', /*bAvalCampo*/,/*lViewUsado*/ )
Local oStruFQX := FWFormStruct( 1, 'FQX', /*bAvalCampo*/,/*lViewUsado*/ )
Local oStruFH2 := FWFormStruct( 1, 'FH2', /*bAvalCampo*/,/*lViewUsado*/ )


oStruFQX:SetProperty("FQX_QTD",MODEL_FIELD_VALID, FWBuildFeature(STRUCT_FEATURE_VALID,"LOCA104IVQ()" ))

oStruFH2:AddField("Item", ' ', 'ITEM', 'C', 3, 0, , , {}, .F.)

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'FQWMASTER', /*cOwner*/, oStruFQW, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por Grid
oModel:AddGrid( 'GRIDFQX', 'FQWMASTER', oStruFQX, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
oModel:AddGrid( 'GRIDFH2', 'GRIDFQX', oStruFH2, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

oModel:GetModel( 'GRIDFQX' ):SetDescription(STR0001)  //STR0001 //'Itens do Romaneio'
oModel:GetModel( 'GRIDFH2' ):SetDescription(STR0002)  //'Itens do Romaneio' //'ID dos Quantificaveis'
//Setando a chave primária da rotina
oModel:SetRelation( 'GRIDFQX', { { 'FQX_FILIAL', 'xFilial("FQX")' },{'FQX_NUM','FQW_NUM'}}, FQX->( IndexKey( 1 ) ) )
oModel:SetRelation( 'GRIDFH2', { { 'FH2_FILIAL', 'xFilial("FH2")' },{'FH2_ROMRET','FQW_NUM'},{'FH2_AS','FQX_AS'} }, FH2->( IndexKey( 1 ) ) )

oModel:GetModel( 'GRIDFQX'):SetLoadFilter( , " EXISTS ( SELECT B1_COD FROM "+ RetSqlName("SB1") + " SB1 INNER JOIN "+ RetSqlName("SBM") + " SBM ON BM_FILIAL = '"+xFilial("SBM")+"' and BM_GRUPO = B1_GRUPO and BM_XACESS = '3' and SBM.D_E_L_E_T_ = ' ' WHERE B1_FILIAL = '"+xFilial('SB1')+"' and B1_COD = FQX_PROD and SB1.D_E_L_E_T_ = ' ')" )   

oModel:GetModel( 'GRIDFQX' ):SetNoInserLine(.T.)
oModel:GetModel( 'GRIDFQX' ):SetNoDeleteLine(.T.)

oModel:GetModel('GRIDFQX'):SetOptional(.T.)
// Liga a validação da ativacao do Modelo de Dados
oModel:SetVldActive( { | oModel | LOCA104FAC( oModel ) })
oModel:GetModel("GRIDFH2"):SetLPre({|oGrid,nLinha,cAcao| Loca104LPV(oGrid,nLinha,cAcao)})

oModel:SetOnlyQuery('GRIDFQX', .T.)
oModel:SetOnlyQuery('GRIDFH2', .T.)
oModel:SetOnlyQuery('FQWMASTER', .T.)

Return oModel


/*/{Protheus.doc} ViewDef
Define a View da Demanda
@type function
@version 24.10 
@author Alexandre Circenis
@since 2/12/2025
@return variant, Retorna a view da demanda
/*///-------------------------------------------------------------------
Static Function ViewDef()
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   := FWLoadModel( 'LOCA104I' )
Local oStruFQW := FWFormStruct( 2, 'FQW', /*bAvalCampo*/,/*lViewUsado*/ )
Local oStruFQX := FWFormStruct( 2, 'FQX', {|cCampo| cCampo $ "FQX_ITEM   FQX_AS     FQX_PROD   FQX_DESPRO FQX_QTD    FQX_ARMZ01"},/*lViewUsado*/ )
Local oStruFH2 := FWFormStruct( 2, 'FH2', {|cCampo| cCampo $ "FH2_CODBEM FH2_NOMBEM "}/*bAvalCampo*/,/*lViewUsado*/ )
Local oView

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

oStruFH2:AddField("ITEM", '01 ', 'Item', 'Item', {}, "G", "@!" ,/*bPictVar*/,/*cLookUp*/, .F./*lCanChange*/,"1"/*cFolder*/)


oStruFQX:SetProperty("FQX_ITEM"   , MVC_VIEW_ORDEM, '001')
oStruFQX:SetProperty("FQX_PROD"   , MVC_VIEW_ORDEM, '002')
oStruFQX:SetProperty("FQX_DESPRO" , MVC_VIEW_ORDEM, '003')
oStruFQX:SetProperty("FQX_QTD"    , MVC_VIEW_ORDEM, '004')
oStruFQX:SetProperty("FQX_ARMZ01" , MVC_VIEW_ORDEM, '005')
oStruFQX:SetProperty("FQX_AS"     , MVC_VIEW_ORDEM, '006')

oStruFQX:SetProperty("FQX_ARMZ01" , MVC_VIEW_CANCHANGE, .F.)

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_FQW', oStruFQW, 'FQWMASTER' )
oView:AddGrid( 'VIEW_FQX', oStruFQX, 'GRIDFQX' )
oView:AddGrid( 'VIEW_FH2', oStruFH2, 'GRIDFH2' )

oView:addIncrementField("VIEW_FH2","ITEM")

oView:EnableTitleView('VIEW_FQX',  STR0003) //"A.S. Devolvidas"
oView:EnableTitleView('VIEW_FH2', STR0004) //"I.D. Retornados"

oView:AddOtherObject('LeituraCB', {|oPanel,oView| LOCA104ICB(oPanel, 'GRIDFQX', 'GRIDFH2')})

oView:SetViewProperty('GRIDFQX', 'GRIDSEEK'  , {.T.})
oView:SetViewProperty('GRIDFQX', 'GRIDFILTER', {.T.})
oView:SetViewProperty('GRIDFH2', 'GRIDSEEK'  , {.T.})
oView:SetViewProperty('GRIDFH2', 'GRIDFILTER', {.T.})
// Altura das Linhas
oView:SetViewProperty("*", "GRIDROWHEIGHT", {20})

// Criar um 'box' horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'CABEC' , 30 )
oView:CreateHorizontalBox( 'ITENS' , 70 )
oView:CreateVerticalBox('FQXIT',60,'ITENS')
oView:CreateVerticalBox('IDS',40,'ITENS')
oView:CreateHorizontalBox( 'FH2IT' , 90 , 'IDS')

oView:CreateHorizontalBox( 'CODBAR' , 10 , 'IDS')

// Relaciona o ID da View com o 'box' para exibicao
oView:SetOwnerView( 'VIEW_FQW', 'CABEC' )
oView:SetOwnerView( 'VIEW_FQX', "FQXIT" )
oView:SetOwnerView( 'VIEW_FH2', 'FH2IT' )
oView:SetOwnerView( 'LeituraCB', 'CODBAR' )

oView:SetViewAction("BUTTONOK", { |oView| Loca104IPR( oView ) } )
oView:SetCloseOnOk({|| .T. })

Return oView

/*/{Protheus.doc} LOCA104ICB
Botões de marcar e desmarcar todos
@type function
@version 25.10  
@author Alexandre Circenis
@since 4/1/2025
@param oPanel, object, Panel da Grid
@param cGrid, character, Nome da Grid que vai ser marcada/desmarcada
/*/
Function LOCA104ICB(oPanel, cGrid, cDest)
Local oModel as object
Local oView  as object
Local oSayCodBar		:= Nil													//objeto say codigo de barras
Local oGetCodBar		:= Nil													//objeto get codigo de barras
Local cGetCodBar		:= Space(TamSx3("T9_CODBEM")[1])
//Inicializa variáveis
oModel   	:= FWModelActive()
oView    	:= FwViewActive()	

//Say Codigo de Barras
oSayCodBar := tSay():New( 07, 5, {|| STR0006}, oPanel,/*pict*/,/*fonte*/,,,, .T., CLR_BLUE,, 50, 10)  //STR0006 //"Código de Barras:"
//Get Codigo de Barras
oGetCodBar := TGet():New( 05, 60, {|u| If(PCount() > 0, cGetCodBar := u, cGetCodBar)}, oPanel,;								
								80, 10, "@!", { || .T. } ,,,,,,.T.,,, {|| },,,, .F.,,,)				

//Perda de foco do campo Codigo de Barras
oGetCodBar:bLostFocus := {|| IIF(LOCA104IPC(@cGetCodBar, oGetCodBar, cGrid, cDest), .T.,.F.)}
	
Return()


/*/{Protheus.doc} LOCA104IPC
Busca o codigo informado no campo Codigo de Barra
Primeiro busca pelo codigo do Bem na grid
Se não encontrar busca pelo Codigo de Barra cadastrado no Campo B1_CODBAR 
@type function
@version 25.10
@author Alexandre Circenis
@since 13/11/2025
@param cCodSearch, character, Codigo Contido na campo Codigo de BArra
@param oGetCodBar, object, Objeto do Get do codigo de barra usado para retornar o foco e permitir informar novos codigo
@param cGrid, character, Nome do Grid base da busca
@param cDest, character, Nome do Grid de preenchimento
/*/
Function LOCA104IPC(cCodSearch, oGetCodBar, cGrid, cDest)
Local oModel := FWModelActive()
Local oGrid  := oModel:GetModel(cGrid)
Local oDest  := oModel:GetModel(cDest)
Local oView := FWViewActive() 
Local aSaveLines := FWSaveRows()

if Empty(cCodSearch)
	Return
endif

if !Loca104IVC(cCodSearch, cGrid, cDest)
	oGetCodBar:SetFocus()
	Return
endif

oDest:SetNoInsertLine(.F.)
if !Empty(oDest:GetValue("FH2_PROD",1))
	oDest:AddLine()
	oDest:GoLine(oDest:Length())
endif


oDest:LoadValue("FH2_FILIAL", xFilial("FH2"))
oDest:LoadValue("FH2_AS", FH2->FH2_AS)
oDest:LoadValue("FH2_PROD", FH2->FH2_PROD)
oDest:LoadValue("FH2_CODBEM",  FH2->FH2_CODBEM)
oDest:LoadValue("FH2_NOMBEM", Posicione("ST9",1,xFilial("ST9")+FH2->FH2_CODBEMh, "T9_NOME"))
oDest:LoadValue("FH2_CONTRA",  FH2->FH2_CONTRA)
oDest:LoadValue("FH2_OBRA", FH2->FH2_OBRA)
oDest:LoadValue("FH2_DESPRO", Posicione("SB1",1,xFilial("SB1")+ FH2->FH2_PROD,"B1_DESC"))
oDest:SetNoInsertLine(.T.)

oGrid:LoadValue("FQX_ARMZ01", oGrid:GetValue("FQX_ARMZ01")+1 )

FWRestRows( aSaveLines )
oView:Refresh()
//Atualiza objetos de tela
cCodSearch := Space(TamSx3("T9_CODBEM")[1])	
oGetCodBar:Refresh()
oGetCodBar:SetFocus()

Return

/*/{Protheus.doc} Loca104IVC
Valida o codigo do bem informado no campo de código de barras
Deve existir na ST9
Deve ser do mesmo produto do item quantificavel
O bem deve estar no status de nota emitida
Não pode estar na lista de bems já informados
Os bens separados não podem ultrapassar a quantidade do informado na FPA
@type function
@version 25.10
@author Alexandre Circenis
@since 12/12/2025
@param cBem, character, Código do bem 
@param cGrid, character, Nome do Grid pai 
@param cDest, character, Nome do Grid filho
/*/
Function Loca104IVC(cBem, cGrid, cDest)
Local oModel := FWModelActive()
Local oGrid  := oModel:GetModel(cGrid)
Local oDest  := oModel:GetModel(cDest)
//Local cBem := &(ReadVar())
Local lRet := .T.

ST9->(dbSetOrder(1))
if !ST9->(dbSeek(xFilial("ST9")+cBem)) // Bem 
	lRet := .F.
	Help(" ",1,"LOCA104I_01",, STR0007,1,0)   //"Código não encontrato na tabelas de Bens."
    
elseif ST9->T9_CODESTO <> oGrid:GetValue("FQX_PROD")  // O produto do bem não é igual ao da Grid
	lRet := .F.
	Help(" ",1,"LOCA104I_02",, STR0008,1,0)   //"O produto associado a bem informado não corresponde ao produto selecionado na grid superior."
elseif !ST9->T9_STATUS $ Loca104ISt("20") // O bem tem que estar ccom remessa gerada 
	lRet := .F.
	Help(" ",1,"LOCA104I_05",, STR0009,1,0)    //"O bem informado não está com o status de Nota de Remessa emitida."
elseif oDest:SeekLine({{"FH2_CODBEM",cBem}},,.F.)
	lRet := .F.
	Help(" ",1,"LOCA104I_03",, STR0010,1,0)  //"O bem já está incluido na lista de bens retornados."
elseif !(FH2->(dbSeek(xFilial("FH2")+oGrid:GetValue("FQX_AS")+cBem)))
//elseif oGrid:GetValue("FQ5_XQTD") = oGrid:GetValue("QTDNEW")
	lRet := .F.
	Help(" ",4,"LOCA104I_04",,STR0011,1,0)    //"O I.D. informado não está associado a A.S. retornada"
endif

Return lRet


/*/{Protheus.doc} LOCA104IST
Retorna o codigo de status da ST9 correspondente a um status usdao pelo Rental
00 - Disponival
10 - Contrato Gerado
20 - NF DE REMESSA GERADA
50 - Retorno de Locação
60 - Nota Fiscal de Retorno Gerada
70 - Manutenção
@type function
@version 25.10
@author Alexandre Circenis
@since 22/12/2025
@param cStRental, character, Codigo do status rental
@return variant, Codigo Status da ST9
/*/
FUNCTION LOCA104IST(cStRental)
Local cRet      := ""
Local aAreaXXX  := getarea()
Local lMvLocBac	:= SuperGetMv("MV_LOCBAC",.F.,.F.) //Integração com Módulo de Locações SIGALOC

	If !lMvLocBac
// Só para quem usa LOCBAC como .T.
	//	if  !empty(FWX3Titulo( "TQY_STTCTR" ))
	//		TQY->(dbSetOrder(1))
	//		TQY->(dbSeek(xFilial("TQY")))

	//		While !TQY->(Eof()) .and. TQY->TQY_FILIAL == xFilial("TQY")
	//			If TQY->TQY_STTCTR == cStRental
	//				cRet += TQY->TQY_STATUS + "*"
	//			EndIf
	//			TQY->(dbSkip())
	//		EndDo
	//	endif
	else
		if  !empty(FWX3Titulo( "FQD_STAREN" ))
			FQD->(dbSetOrder(1))
			FQD->(dbSeek(xFilial("FQD")))

			While !FQD->(Eof()) .and. FQD->FQD_FILIAL == xFilial("FQD")
				If FQD->FQD_STAREN == cStRental
					cRet += FQD->FQD_STATQY + "*"
				endif
				FQD->(dbSkip())
			EndDo
		endif
	EndIF

	RestArea(aAreaXXX)

	aSize(aAreaXXX,0)
	FwFreeArray(aAreaXXX)

RETURN cRet

/*/{Protheus.doc} Loca140IPR
Realiza o processamento do Model
@type function
@version 25.10 
@author Alexandre Circenis
@since 4/1/2025
@param oModel, object, Modelo dados processado
@return variant, Indica se a troca foi realizada com sucesso (.T.)
/*/
Function Loca104IPR(oModel, lRomaneio)
Local oGridFQX := oModel:GetModel("GRIDFQX")
Local oGridFH2 := oModel:GetModel("GRIDFH2")
Local aAlteradas := {}
Local aAlteraFH2 := {}
Local nX
Local aArea := GetArea()
Local nY
Local lOk := .T.
Local lNaoOk := .F.

PRIVATE nTpAce	:= 0
PRIVATE cServ   := 'L' // Private usada no aceite da A.S.
//PRIVATE NTOTMIN := 0						// PARA RETORNAR O NUMERO DE MINUTAS CRIADAS
private lImplemento := LOCA059B1("FQG_FILIAL", "FQG") .and. GETMV("MV_NG1LOC",,.F.)
Private cLocErro    := ""
Private lLocAuto    := .T.

DEFAULT lRomaneio := .F.

BEGIN TRANSACTION

// Trocar e/ou separar o Grid de Maquinas Patrimonial
aAlteradas := oGridFQX:GetLinesChanged(MODEL_GRID_LINECHANGED_ALL)

For nX := 1 to Len(aAlteradas)

	oGridFQX:Goline(aAlteradas[ nX])
	FQX->(dbGoto(oGridFQX:GetDataId()))
	RecLock("FQX", .F.)
	FQX->FQX_QTD    := oGridFQX:GetValue("FQX_QTD")
	FQX->FQX_ARMZ01 := oGridFQX:GetValue("FQX_ARMZ01")
	FQX->FQX_STATUS := If(oGridFQX:GetValue("FQX_QTD") <> oGridFQX:GetValue("FQX_ARMZ01") , '4', '3')
	FQX->(msUnLock())
	if !lNaoOk 
		lNaoOk := FQX->FQX_STATUS = '4'
	endif
	// Processar a Lista de I.D,. para devolução
	// Preparar a gravação de status do bem 
	aAlteraFH2 := oGridFH2:GetLinesChanged(MODEL_GRID_LINECHANGED_ALL)
	For nY := 1 to Len(aAlteraFH2)

		oGridFH2:Goline(aAlteraFH2[ nY])
		
		if FH2->(dbSeek(xFilial("FH2")+oGridFH2:GetValue("FH2_AS")+oGridFH2:GetValue("FH2_CODBEM")))
			RecLock("FH2", .F.)
			if oGridFH2:IsDeleted()
				FH2->FH2_ROMRET := ""
			else
				FH2->FH2_ROMRET := FQW->FQW_NUM
			endif
			FH2->(msUnLock())
		endif
	next nY
next

if lNaoOk
	RecLock("FQW" , .F.)
	FQW->FQW_STATUS := "4"
	MsUnlock()
endif

END TRANSACTION

RestArea(aArea)

//if !lOk
//	oModel:lUpdateMsg := .F. /// Se tiver erro não apresentar mensagem de sucesso 
//endif

RETURN lOk

/*/{Protheus.doc} Loca104LPV
Processa o Delete/Undelete de um item da lista dos bens alocados para um item quantificavel
@type function
@version 25.10
@author Alexandre Circenis
@since 12/12/2025
@param oFH2, object, Objeto tipo grid da Tabela FH2
@param nLinha, numeric, Numero da linha
@param cAcao, character, Ação sendo realizada
@return variant, Sucesso na realização da ação
/*/
Function Loca104LPV(oFH2,nLinha,cAcao)
Local oModel := FWModelActive()
Local oGrid  := oModel:GetModel("GRIDFQX")
Local lRet := .T.

if cACAO = "UNDELETE" // Se está desdeletando varificar se a quantiade separada já foi atingida
	oGrid:LoadValue("FQX_ARMZ01", oGrid:GetValue("FQX_ARMZ01") + 1)	
elseif cAcao = 'DELETE'
	oGrid:LoadValue("FQX_ARMZ01", oGrid:GetValue("FQX_ARMZ01") - 1)	
endif

Return lRet

/*/{Protheus.doc} LOCA104IVQ
Valida a quantidade informada para devolução
@type function
@version 25.10
@author Alexandre Circenis
@since 28/12/2025
@return variant, Retorna se a qunatidae informada é valida
/*/
Function LOCA104IVQ()
Local lRet := .T.
Local oModel := FWModelActive()


	if M->FQX_QTD <= 0
		oModel:SetErrorMessage("","","","","LOCA104I_01",STR0012,)  //"Quantidade Retornada deve ser Positiva e maior que zero!"
		lRet := .F.
	elseif  Int(M->FQX_QTD) <> M->FQX_QTD
		oModel:SetErrorMessage("","","","","LOCA104I_02",STR0013,)  //"Quantidade deve ser inteira!"
		lRet := .F.
	elseif M->FQX_QTD > Posicione("FPA",3, xFilial("FPA")+FwFldGet("FQX_AS"), "FPA_QUANT")
		oModel:SetErrorMessage("","","","","LOCA104I_03","Quantidade não pode ser maior que a Original do Contrato. Quantidade do contrato "+Alltrim(Str(Posicione("FPA",3, xFilial("FPA")+FwFldGet("FQX_AS"), "FPA_QUANT"))),)  
		lRet := .F.
	endif

Return lRet
