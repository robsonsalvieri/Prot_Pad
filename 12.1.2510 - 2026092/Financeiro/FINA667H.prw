#Include 'Protheus.ch'
#Include 'FINA667H.CH'
#Include 'FWEDITPANEL.CH'
#INCLUDE 'FWMVCDEF.CH'

/*/{Protheus.doc} ViewDef
Definição do interface
@author William Matos Gundim Junior
@since 01/11/2013
@version 1.0
/*/
Static Function ViewDef()
Local oModel   := FWLoadModel('FINA667H')
Local oStruFLD := FWFormStruct(2,'FLD')
Local oStruFLM := FWFormStruct(2,'FLM')

F667FixNm(FLD->FLD_VIAGEM, FLD->FLD_PARTIC)

oView := FWFormView():New()
oView:SetModel(oModel)

oView:AddField('VIEW_FLD',oStruFLD,'FLDMASTER')
oStruFLM:RemoveField('FLM_STATUS')
oStruFLM:AddField("Status", "01",'','',/*aHelp*/,"BT",/*cPicture*/,/*PictVar*/,/*cLookUp*/,/*lCanChange*/,/*cFolder*/,/*cGroup*/,/*aComboValues*/,/*nMaxLenCombo*/,/*cIniBrow*/,/*lVirtual*/,/*cPictVar*/,/*lInsertLine*/ )
oView:AddGrid('VIEW_FLM',oStruFLM,'FLMDETAIL')
oView:SetViewProperty("VIEW_FLD","SETLAYOUT",{FF_LAYOUT_VERT_DESCR_TOP ,-1})

oView:CreateHorizontalBox( 'SUP_FLD', 50)
oView:CreateHorizontalBox( 'INF_FLM', 50)

oView:SetOwnerView('VIEW_FLD','SUP_FLD')
oView:SetOwnerView('VIEW_FLM','INF_FLM')

oView:EnableTitleView('VIEW_FLD')
oView:EnableTitleView('VIEW_FLM')

oView:AddUserButton('Legenda','',{|oView|LMLegenda()})

Return oView

/*/{Protheus.doc} ModelDef
Definição do modelo de Dados
@author William Matos Gundim Junior.
@since 01/11/2013
@version 1.0
/*/
Static Function ModelDef()
Local aRelacao := {}
Local oStruFLD := FWFormStruct(1,'FLD')
Local oStruFLM := FWFormStruct(1,'FLM')
Local oModel   := MPFormModel():New('FINA667H')
oModel:SetDescription(STR0001)

oModel:AddFields('FLDMASTER',/*cOwner(Pai)*/,oStruFLD)
oStruFLM:AddField("Status","","Status","BT",1,0,/*bValid*/, /*bWhen*/, , .F.,{||F667HLeg()}/*bInit*/, /*lKey*/, /*lNoUpd*/, .T./*lVirtual*/,/*cValid*/)
oModel:AddGrid('FLMDETAIL','FLDMASTER',oStruFLM)

aAdd(aRelacao,{'FLM_FILIAL','xFilial("FLM")'})
aAdd(aRelacao,{'FLM_VIAGEM','FLD_VIAGEM'})
aAdd(aRelacao,{'FLM_PARTIC','FLD_PARTIC'})

oModel:SetRelation('FLMDETAIL',aRelacao,FLM->(IndexKey(1)))

oModel:GetModel('FLDMASTER'):SetDescription(STR0001)
oModel:GetModel('FLMDETAIL'):SetDescription(STR0002)

Return oModel

/*/{Protheus.doc} F667FixNm
	Corrige o nome do aprovador (FLM_NOMEAP) dos registros de historico de
	aprovacao ao abrir a consulta.

	@author vinicius.prado
	@since 04/09/2026
	@version 1.0
	@param cViagem, caractere, codigo da viagem
	@param cPartic, caractere, codigo do participante
/*/
Function F667FixNm(cViagem as Character, cPartic as Character)
	Local aArea    	as Array
	Local aAreaFLM  as Array
	Local cFilFLM   as Character
	Local cChave    as Character
	Local cNomeAtu  as Character

	Default cViagem := ""
	Default cPartic := ""

	aArea    := GetArea()
	aAreaFLM := FLM->(GetArea())
	cFilFLM  := xFilial("FLM")
	cChave   := cFilFLM + cViagem + cPartic
	cNomeAtu := ""

	If !Empty(cViagem) .And. !Empty(cPartic)
		FLM->(DbSetOrder(1)) //FLM_FILIAL+FLM_VIAGEM+FLM_PARTIC+FLM_ADIANT+FLM_SEQ

		If FLM->(DbSeek(cChave))
			While FLM->(!Eof()) .And. FLM->(FLM_FILIAL+FLM_VIAGEM+FLM_PARTIC) == cChave
				If !Empty(FLM->FLM_APROV)
					cNomeAtu := Posicione("RD0", 1, xFilial("RD0") + FLM->FLM_APROV, "RD0_NOME")

					If !Empty(cNomeAtu) .And. AllTrim(cNomeAtu) != AllTrim(FLM->FLM_NOMEAP)
						RecLock("FLM", .F.)
						FLM->FLM_NOMEAP := cNomeAtu
						FLM->(MsUnLock())
					EndIf
				EndIf

				FLM->(DbSkip())
			EndDo
		EndIf
	EndIf

	RestArea(aAreaFLM)
	RestArea(aArea)
Return

/*/{Protheus.doc} F667HLeg
Monta a legenda dos registros apresentados no Grid.
@author William Matos Gundim Junior.
@since 05/11/2013
@version 11.9
/*/
Function F667HLeg()

Local cRet:=''
Local cValue := FLM->FLM_STATUS

If cValue == "0"			//Liberação Indisponivel
	cRet:='br_branco'
ElseIf cValue == "1"		//Aguardando liberação	
	cRet:='br_amarelo'
ElseIf cValue == "2"		//Liberação Aprovada
    cRet:='br_verde'
Elseif cValue == "3"		//Cancelada
    cRet:='br_vermelho'
Elseif cValue == "4"		//Reprovada
    cRet:='br_preto'
Endif

Return cRet

/*/{Protheus.doc} LMLegenda
Monta a legenda dos registros apresentados no Grid.
@author William Matos Gundim Junior.
@since 05/11/2013
@version 11.9
/*/
Function LMLegenda()
Local oLegenda:=FwLegend():New()
oLegenda:add('FLM->FLM_STATUS==0','WHITE' ,STR0005)		//"Indisponível"
oLegenda:add('FLM->FLM_STATUS==1','YELLOW',STR0006)		//"Aguardando Liberação"
oLegenda:add('FLM->FLM_STATUS==2','GREEN' ,STR0003)		//"Aprovada"
oLegenda:add('FLM->FLM_STATUS==3','RED'   ,STR0004)		//"Reprovada"
oLegenda:add('FLM->FLM_STATUS==4','BLACK' ,STR0007)		//"Cancelada"
oLegenda:View()
oLegenda:=nil
        
Return .T.
