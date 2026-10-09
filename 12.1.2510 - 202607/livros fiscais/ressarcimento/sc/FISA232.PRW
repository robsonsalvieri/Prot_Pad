#Include "FISA232.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FISA232
  
Rotina de Visualização da DRCST - Demonstrativo para Apuração Mensal do Ressarcimento, 
da Restituição e da Complementação do ICMS Substituição Tributária, do Estado de Santa Catarina.
O método de apuração é determinado pelo Decreto Nº 1818 DE 28/11/2018 e pela Portaria SEF N° 378/2018.

@author Ulisses P. Oliveira
@since 09/04/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Function FISA232()
    Local oBrowse

    If AliasIndic("F1I") .And. AliasIndic("F1J") .And. AliasIndic("F1K") .And. AliasIndic("F1L") .And. AliasIndic("F1M") .And. AliasIndic("F2W") .And. AliasIndic("F3M")
		DbSelectArea ("F1I")
		DbSelectArea ("F1J")
		DbSelectArea ("F1K")
		DbSelectArea ("F1L")
		DbSelectArea ("F1M")
		DbSelectArea ("F2W")
		DbSelectArea ("F3M")

        oBrowse := FWMBrowse():New()
        oBrowse:SetAlias("F1I")
        oBrowse:SetDescription(STR0001) //---Apuração do Ressarcimento, Restituição e Complementação do ICMS ST---//
        oBrowse:SetOnlyFields({'F1I_FILIAL','F1I_ANOMES','F1I_SDREST','F1I_SDRESS','F1I_SDCOMP','F1I_SDICOP','F1I_VLACRE','F1I_VLACOM'})
        oBrowse:Activate()
    Else
        MsgStop(STR0002) //---Dicionário de dados desatualizado. Favor aplicar as atualizações necessárias.---//
    EndIf

Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Função para criação de menu [MVC].

@author Ulisses P. Oliveira
@since 09/04/2019
@version 1.0

/*/
//--------------------------------------------------------------------------------------------------
Static Function MenuDef()
    Local aRotina := {}

    ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.FISA232' OPERATION 2 ACCESS 0 //---Visualizar---//
    ADD OPTION aRotina TITLE STR0004 ACTION 'FISA231EXC'      OPERATION 5 ACCESS 0 //---Excluir---//

Return ( aRotina )


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Função para criação do modelo [MVC].

@author Ulisses P. Oliveira
@since 09/04/2019
@version 1.0

/*/
//--------------------------------------------------------------------------------------------------
Static Function ModelDef()
    Local oModel
    Local oStructF1I := FWFormStruct(1,"F1I")

    oModel := MPFormModel():New("FISA232",,)
    oModel:AddFields("F1IMASTER",,oStructF1I)
    oModel:GetModel("F1IMASTER"):SetOnlyView ( .T. )
    oModel:SetDescription(STR0001)                       //---Apuração do Ressarcimento, Restituição e Complementação do ICMS ST---//
    oModel:GetModel("F1IMASTER"):SetDescription(STR0005) //---Ress.ICMSST-Apuração---//
Return oModel


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Função para criação da view [MVC].

@author Ulisses P. Oliveira
@since 09/04/2019
@version 1.0

/*/
//--------------------------------------------------------------------------------------------------
Static Function ViewDef()
Local oModel     := FWLoadModel("FISA232")
Local oStructF1I := FWFormStruct(2,"F1I")
Local oView

oStructF1I:RemoveField("F1I_IDAPUR")
oStructF1I:RemoveField("F1I_VLREST")
oStructF1I:RemoveField("F1I_VLCOMP")
oStructF1I:RemoveField("F1I_SDRES1")
oStructF1I:RemoveField("F1I_SDRES2")
oStructF1I:RemoveField("F1I_SDRES3")
oStructF1I:RemoveField("F1I_FECRES")
oStructF1I:RemoveField("F1I_FECCMP")
oStructF1I:RemoveField("F1I_ORIGEM")
oStructF1I:RemoveField("F1I_REVOP1")
oStructF1I:RemoveField("F1I_REVOP2")
oStructF1I:RemoveField("F1I_REVOP3")
oStructF1I:RemoveField("F1I_REVOP4")
oStructF1I:AddGroup('GRUPO00','','',2) 
oStructF1I:AddGroup('GRUPO01','Saldos a Restituir, a Ressarcir e a Complementar','',2) 
oStructF1I:AddGroup('GRUPO02','Saldo de ICMS sobre Operações Próprias','',2) 
oStructF1I:AddGroup('GRUPO03','Valores Apurados de Crédito e Complemento de Imposto','',2) 
oStructF1I:SetProperty('*'         ,MVC_VIEW_GROUP_NUMBER,'GRUPO00') 
oStructF1I:SetProperty('F1I_SDREST',MVC_VIEW_GROUP_NUMBER,'GRUPO01') 
oStructF1I:SetProperty('F1I_SDRESS',MVC_VIEW_GROUP_NUMBER,'GRUPO01')
oStructF1I:SetProperty('F1I_SDCOMP',MVC_VIEW_GROUP_NUMBER,'GRUPO01')
oStructF1I:SetProperty('F1I_SDICOP',MVC_VIEW_GROUP_NUMBER,'GRUPO02')
oStructF1I:SetProperty('F1I_VLACRE',MVC_VIEW_GROUP_NUMBER,'GRUPO03')
oStructF1I:SetProperty('F1I_VLACOM',MVC_VIEW_GROUP_NUMBER,'GRUPO03')

oView := FWFormView():New()
oView:SetModel(oModel)
oView:AddField("VIEW_F1I",oStructF1I,"F1IMASTER")
oView:CreateHorizontalBox("TELA",100)
oView:SetOwnerView("VIEW_F1I","TELA")

Return oView