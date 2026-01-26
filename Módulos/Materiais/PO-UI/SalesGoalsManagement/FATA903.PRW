#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} FATA903
Metas de Vendas Gerenciais

@author CRM/Faturamento
@since 08/07/2024
@version 12.1.2410
/*/
//-------------------------------------------------------------------

Function FATA903()
  IIf(!Empty(GetApoRes("FATA903.APP")), FWCallApp("FATA903"), .T.)
Return

//------------------------------------------------------------------
/*/{Protheus.doc} JsToAdvpl

Bloco de codigo que recebera as chamadas JavaScript
Não retirar! Chamada pela função FWCallApp

@author  Squad CRM/Faturamento
@since   08/07/2024
@version 12.1.2410
/*/
//-------------------------------------------------------------------
Static Function JsToAdvpl(oWebChannel,cType,cContent)
  Local cUserAdm  := ""
  Local lUserAdm  := FwIsAdmin()

  cUserAdm := IIf(lUserAdm, "true", "false")
    
  Do Case
    Case cType == "preLoad"
      cJsonCompany  := '{"Code":"'+cEmpAnt+'","InternalId":"'+cEmpAnt+'","CorporateName":"'+FWGrpName(cEmpAnt)+'","AccessAdm":"'+cUserAdm+'"}'
      cJsonBranch   := '{"CompanyCode":"'+cEmpAnt+'","EnterpriseGroup":"'+cEmpAnt+'","ParentCode":"'+cFilAnt+'","Code":"'+cFilAnt+'","Description":"'+FWFilialName()+'"}'
      oWebChannel:AdvPLToJS('setCompany', cJsonCompany)
      oWebChannel:AdvPLToJS('setBranch', cJsonBranch)
  EndCase
Return

//------------------------------------------------------------------
/*/{Protheus.doc} FT903JTAdv

Função criada para permitir a execucao da automacao de testes AdvPR
da função JsToAdvpl

@author  Squad CRM/Faturamento
@since   12/07/2024
@version 12.1.2410
/*/
//-------------------------------------------------------------------
Function FT903JTAdv(oWebChannel, cType, cContent)
  JsToAdvpl(oWebChannel,cType,cContent)
Return




