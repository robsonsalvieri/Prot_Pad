#Include "FISA240C.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FISA240C
  
Rotina de Visualização da ADRC-ST - ARQUIVO DIGITAL DA RECUPERAÇÃO, DO RESSARCIMENTO E DA COMPLEMENTAÇÃO
DO ICMS ST, do Estado do Paraná.
O método de apuração é determinado pelo Decreto nº 3.886 de 21/01/2020 e pela Norma de Procedimento 
Fiscal nº 003/2020, publicado em 28/01/2020.

@author Ulisses P. Oliveira
@since 31/03/2020
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Function FISA240C()
    Local oBrowse

    If AliasIndic("F1I") .And. AliasIndic("F1L") .And. AliasIndic("F1M") .And. AliasIndic("F2W") .And. AliasIndic("F3M") .And. AliasIndic("F1Z")
		DbSelectArea ("F1I")
		DbSelectArea ("F1L")
		DbSelectArea ("F1M")
		DbSelectArea ("F2W")
		DbSelectArea ("F3M")
		DbSelectArea ("F1Z")

        oBrowse := FWMBrowse():New()
        oBrowse:SetAlias("F1I")
        oBrowse:SetDescription(STR0001) //---Apuração do Recuperação, Ressarcimento e Complementação do ICMS ST---//
        oBrowse:SetOnlyFields({'F1I_FILIAL','F1I_ANOMES','F1I_VLACRE','F1I_VLACOM','F1I_FECRES','F1I_FECCMP'})
        oBrowse:Activate()
    Else
        MsgStop(STR0002) //---Dicionário de dados desatualizado. Favor aplicar as atualizações necessárias.---//
    EndIf

Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Função para criação de menu [MVC].

@author Ulisses P. Oliveira
@since 31/03/2020
@version 1.0

/*/
//--------------------------------------------------------------------------------------------------
Static Function MenuDef()
    Local aRotina := {}

    ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.FISA240C' OPERATION 2 ACCESS 0 //---Visualizar---//
    ADD OPTION aRotina TITLE STR0004 ACTION 'FISA240EXC'       OPERATION 5 ACCESS 0 //---Excluir---//

Return ( aRotina )


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Função para criação do modelo [MVC].

@author Ulisses P. Oliveira
@since 31/03/2020
@version 1.0

/*/
//--------------------------------------------------------------------------------------------------
Static Function ModelDef()
    Local oModel
    Local oStructF1I := FWFormStruct(1,"F1I")

    oModel := MPFormModel():New("FISA240C",,)
    oModel:AddFields("F1IMASTER",,oStructF1I)
    oModel:GetModel("F1IMASTER"):SetOnlyView ( .T. )
    oModel:SetDescription(STR0001)                       //---Apuração do Recuperação, Ressarcimento e Complementação do ICMS ST---//
    oModel:GetModel("F1IMASTER"):SetDescription(STR0005) //---Ress.ICMSST-Apuração---//
Return oModel


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Função para criação da view [MVC].

@author Ulisses P. Oliveira
@since 31/03/2020
@version 1.0

/*/
//--------------------------------------------------------------------------------------------------
Static Function ViewDef()
Local oModel     := FWLoadModel("FISA240C")
Local oStructF1I := FWFormStruct(2,"F1I")
Local oView
Local lCpos      := F1I->(fieldPOs("F1I_REVOP4")) > 0 .and. F1I->(fieldPOs("F1I_REVOP1")) > 0  .and. F1I->(fieldPOs("F1I_REVOP3")) > 0 

oStructF1I:RemoveField("F1I_IDAPUR")
oStructF1I:RemoveField("F1I_VLREST")
oStructF1I:RemoveField("F1I_VLCOMP")
oStructF1I:RemoveField("F1I_SDRESS")
oStructF1I:RemoveField("F1I_SDRES2")
oStructF1I:RemoveField("F1I_SDICOP")
oStructF1I:RemoveField("F1I_ORIGEM")
oStructF1I:RemoveField("F1I_REVOP2")
oStructF1I:AddGroup('GRUPO00','','',2) 
oStructF1I:AddGroup('GRUPO01','Saldos a Ressarcir e a Complementar','',2) 
oStructF1I:AddGroup('GRUPO02','Valores Apurados de Ressarcimento e Complemento de Imposto','',2) 
oStructF1I:AddGroup('GRUPO03','Valores Apurados de Ressarcimento e Complemento de FECOP','',2) 
oStructF1I:SetProperty('*'         ,MVC_VIEW_GROUP_NUMBER,'GRUPO00')
oStructF1I:SetProperty('F1I_ANOMES',MVC_VIEW_GROUP_NUMBER,'GRUPO00') 
oStructF1I:SetProperty('F1I_SDREST',MVC_VIEW_GROUP_NUMBER,'GRUPO01') 
oStructF1I:SetProperty('F1I_SDRES1',MVC_VIEW_GROUP_NUMBER,'GRUPO01')
oStructF1I:SetProperty('F1I_SDRES3',MVC_VIEW_GROUP_NUMBER,'GRUPO01')
oStructF1I:SetProperty('F1I_SDCOMP',MVC_VIEW_GROUP_NUMBER,'GRUPO01')
oStructF1I:SetProperty('F1I_VLACRE',MVC_VIEW_GROUP_NUMBER,'GRUPO02')
oStructF1I:SetProperty('F1I_VLACOM',MVC_VIEW_GROUP_NUMBER,'GRUPO02')
oStructF1I:SetProperty('F1I_FECRES',MVC_VIEW_GROUP_NUMBER,'GRUPO03')
oStructF1I:SetProperty('F1I_FECCMP',MVC_VIEW_GROUP_NUMBER,'GRUPO03')
oStructF1I:SetProperty("F1I_SDREST", MVC_VIEW_TITULO, STR0007) 
oStructF1I:SetProperty("F1I_SDRES1", MVC_VIEW_TITULO, STR0008) 
oStructF1I:SetProperty("F1I_SDRES3", MVC_VIEW_TITULO, STR0010) 
oStructF1I:SetProperty("F1I_SDCOMP", MVC_VIEW_TITULO, STR0011) 
oStructF1I:SetProperty("F1I_VLACRE", MVC_VIEW_TITULO, STR0012) 
oStructF1I:SetProperty("F1I_VLACOM", MVC_VIEW_TITULO, STR0013) 
oStructF1I:SetProperty("F1I_FECRES", MVC_VIEW_TITULO, STR0014) 
oStructF1I:SetProperty("F1I_FECCMP", MVC_VIEW_TITULO, STR0015) 
If lCpos
    oStructF1I:SetProperty("F1I_REVOP4", MVC_VIEW_TITULO, STR0018) 
    oStructF1I:SetProperty("F1I_REVOP1", MVC_VIEW_TITULO, STR0016) 
    oStructF1I:SetProperty("F1I_REVOP3", MVC_VIEW_TITULO, STR0017) 
EndIf
oView := FWFormView():New()
oView:SetModel(oModel)
oView:AddField("VIEW_F1I",oStructF1I,"F1IMASTER")
oView:CreateHorizontalBox("TELA",100)
oView:SetOwnerView("VIEW_F1I","TELA")

Return oView
