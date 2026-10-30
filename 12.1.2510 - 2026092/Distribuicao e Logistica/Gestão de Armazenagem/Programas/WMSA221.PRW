#INCLUDE 'FWMVCDEF.CH' 
#INCLUDE "PROTHEUS.CH"
#INCLUDE 'WMSA221.CH'
//-------------------------------------
/*/{Protheus.doc} WMSA221
Programa de criação de ordem de serviço manual
@author felipe.m
@since 11/12/2014
@version 1.0
/*/
//-------------------------------------
Function WMSA221()
Private oBrowse, oDlg
	
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('DCF')
	oBrowse:SetOwner(oDlg)
	oBrowse:SetDescription(STR0001) // Ordens de Serviço
	oBrowse:SetMenuDef("WMSA221")
	oBrowse:AddLegend('!Empty(DCF_SERVIC).And.DCF_STSERV=="0"','WHITE', STR0018)                        // O.S. Cancelada
	oBrowse:AddLegend('!Empty(DCF_SERVIC).And.(Empty(DCF_STSERV).Or.DCF_STSERV=="1")','GREEN', STR0009) // O.S. Não Executada
	oBrowse:AddLegend('!Empty(DCF_SERVIC).And.DCF_STSERV=="2"','YELLOW', STR0010)                       // O.S. Interrompida
	oBrowse:AddLegend('!Empty(DCF_SERVIC).And.DCF_STSERV=="3"','RED', STR0011)                          // O.S. Executada
	oBrowse:AddLegend('!Empty(DCF_SERVIC).And.DCF_STSERV=="4"','BLACK', STR0027)                        // O.S. Bloqueada
	oBrowse:AddLegend('Empty(DCF_SERVIC)','BROWN', STR0013)                                             // O.S. Sem Serviço
	oBrowse:Activate()
Return Nil
//-------------------------------------
/*/{Protheus.doc} MenuDef
(long_description)
@author felipe.m
@since 11/12/2014
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
//-------------------------------------
Static Function MenuDef()
Private aRotina := {}
	ADD OPTION aRotina TITLE STR0002 ACTION 'PesqBrw'         OPERATION 1 ACCESS 0 // Pesquisar
	ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.WMSA221' OPERATION 2 ACCESS 0 // Visualizar
	ADD OPTION aRotina TITLE STR0007 ACTION 'VIEWDEF.WMSA221' OPERATION 8 ACCESS 0 // Imprimir
	If ExistBlock("DLG220MNU")
		ExecBlock("DLG220MNU",.F.,.F.)
	EndIf
Return aRotina
//-------------------------------------
/*/{Protheus.doc} ModelDef
(long_description)
@author felipe.m
@since 11/12/2014
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
//-------------------------------------
Static Function ModelDef()
Local oModel  := MPFormModel():New('WMSA221',,,)
Local oStrDCF := FWFormStruct(1,'DCF')

	oModel:AddFields('DCFMASTER',,oStrDCF)
	oModel:SetDescription(STR0001) // Ordens de Serviço
	oModel:GetModel('DCFMASTER'):SetDescription(STR0001) // Ordem de Serviço
	
Return oModel
//-------------------------------------
/*/{Protheus.doc} ViewDef
(long_description)
@author felipe.m
@since 11/12/2014
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
//-------------------------------------
Static Function ViewDef()
Local lWmsNew := SuperGetMv("MV_WMSNEW",.F.,.F.)
Local oModel  :=  ModelDef()
Local oView   := FWFormView():New()
Local oStrDCF := FWFormStruct(2, 'DCF',{ |cCampo| IIf(lWmsNew,.T.,!(AllTrim( cCampo ) $ "DCF_PRDORI")) })

	oView:SetModel(oModel)
	
	oStrDCF:RemoveField('DCF_ESTFIS')
	oStrDCF:SetProperty('*' ,MVC_VIEW_ORDEM,'99')
	oStrDCF:SetProperty('DCF_SERVIC',MVC_VIEW_ORDEM,'01')
	oStrDCF:SetProperty('DCF_DESSER',MVC_VIEW_ORDEM,'02')
	oStrDCF:SetProperty('DCF_STSERV',MVC_VIEW_ORDEM,'03')
	oStrDCF:SetProperty('DCF_DOCTO' ,MVC_VIEW_ORDEM,'04')
	oStrDCF:SetProperty('DCF_CODPRO',MVC_VIEW_ORDEM,'05')
	oStrDCF:SetProperty('DCF_LOTECT',MVC_VIEW_ORDEM,'06')
	oStrDCF:SetProperty('DCF_NUMLOT',MVC_VIEW_ORDEM,'07')
	oStrDCF:SetProperty('DCF_CARGA' ,MVC_VIEW_ORDEM,'08')
	oStrDCF:SetProperty('DCF_QUANT' ,MVC_VIEW_ORDEM,'09')
	oStrDCF:SetProperty('DCF_QTSEUM',MVC_VIEW_ORDEM,'10')
	oStrDCF:SetProperty('DCF_ORIGEM',MVC_VIEW_ORDEM,'11')
	oStrDCF:SetProperty('DCF_LOCAL' ,MVC_VIEW_ORDEM,'12')
	oStrDCF:SetProperty('DCF_ENDER' ,MVC_VIEW_ORDEM,'13')
	oStrDCF:SetProperty('DCF_LOCDES',MVC_VIEW_ORDEM,'14')
	oStrDCF:SetProperty('DCF_ENDDES',MVC_VIEW_ORDEM,'15')
	oStrDCF:SetProperty('DCF_REGRA' ,MVC_VIEW_ORDEM,'16')
	
	oView:AddField('FORMDCF',oStrDCF,'DCFMASTER') 
	
	oView:CreateHorizontalBox('DCFFIELDS',100)
	oView:SetOwnerView('FORMDCF','DCFFIELDS')
Return oView
