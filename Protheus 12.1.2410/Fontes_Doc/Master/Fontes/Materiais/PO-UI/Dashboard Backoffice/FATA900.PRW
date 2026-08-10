#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "FATA900.CH"

Static  oFontTit    
Static  oFont2      
Static  oFont2N     

Static cMultiProt   
Static cAppEnv      

//-------------------------------------------------------------------
/*/{Protheus.doc} FATA900
Dashboard

@author CRM/Faturamento
@since 27/03/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------

Function FATA900()

If !ChkConfigs()
  IIf(oFontTit   == Nil, oFontTit := TFont():New(,,-25,.T.,.T.,,,,,), .F.)
  IIf(oFont2     == Nil, oFont2   := TFont():New(,,-14,.T.,,,,,,)   , .F.)
  IIf(oFont2N    == Nil, oFont2N  := TFont():New(,,-14,.T.,.T.,,,,,), .F.) 
  FATA900WZD()
  Return .F.
EndIf

If FindFunction("FATA901")
  /*
  AVISO IMPORTANTE:
    A linha comentada abaixo, deverá ser ativada
    quando a versão do DASH que esta em avaliação
    pela BRANCH DEVELOP se tornar oficial.
    A linha validará se o ambiente está com o novo
    campo (A1O_FIJSON) criado no dicionario e dados.
    //If !( TableIndic("A1N") .and. TableIndic("A1O") .and. TableIndic("A1P") .and. TableIndic("A1Q") .and. TableIndic("A1R") ) .Or. A1O->(ColumnPos("A1O_FIJSON")) == 0
  */

  //If !( TableIndic("A1N") .and. TableIndic("A1O") .and. TableIndic("A1P") .and. TableIndic("A1Q") .and. TableIndic("A1R") ) .Or. A1O->(ColumnPos("A1O_FIJSON")) == 0
  If !( TableIndic("A1N") .and. TableIndic("A1O") .and. TableIndic("A1P") .and. TableIndic("A1Q") .and. TableIndic("A1R") )
    HELP(" ",1, STR0001 ,, STR0002 ,2,0,,,,,,{ STR0003 }) // "DASHBOARD - Ambiente para acesso" # "Dicionário de Dados Desatualizado" # "Favor procurar o Administrador do Sistema."
    Return .F.
  Else
    FATA901() // Função dará carga de dados nas tabelas do Dash em base de dados
    FWCallApp( "FATA900" )
  Endif
EndIf

Return

//------------------------------------------------------------------
/*/{Protheus.doc} JsToAdvpl

Bloco de codigo que recebera as chamadas JavaScript
Não retirar! Chamada pela função FWCallApp

@author  Squad CRM/Faturamento
@since   27/01/2021
@version 12.1.27
/*/
//-------------------------------------------------------------------
Static Function JsToAdvpl(oWebChannel,cType,cContent)

Local cUserAdm  := ""
Local lUserAdm  := FwIsAdmin()

If lUserAdm
  cUserAdm := "true"
Else
  cUserAdm := "false"
Endif

Do Case
  Case cType == "preLoad"
    cJsonCompany  := '{"Code":"'+cEmpAnt+'","InternalId":"'+cEmpAnt+'","CorporateName":"'+FWGrpName(cEmpAnt)+'","AccessAdm":"'+cUserAdm+'"}'
    cJsonBranch   := '{"CompanyCode":"'+cEmpAnt+'","EnterpriseGroup":"'+cEmpAnt+'","ParentCode":"'+cFilAnt+'","Code":"'+cFilAnt+'","Description":"'+FWFilialName()+'"}'
    oWebChannel:AdvPLToJS('setCompany', cJsonCompany)
    oWebChannel:AdvPLToJS('setBranch', cJsonBranch)
    oWebChannel:AdvPLToJS('proPaisLoc', cPaisLoc)
EndCase

Return
//------------------------------------------------------------------
/*/{Protheus.doc} ChkConfigs

Funcao que verifica se as chaves app_environment e multiprotocolport
estao ativadas

@author  Squad CRM/Faturamento
@since   29/08/2022
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function ChkConfigs()
  Local lMultiProc := ""
  Local lAppEnv    := ""
  Local lConfigure := ""

  IIf(cMultiProt == Nil, cMultiProt := GetPvProfString("DRIVERS", "MULTIPROTOCOLPORT", "", GetSrvIniName()), .F.)
  IIf(cAppEnv    == Nil, cAppEnv    := GetPvProfString("GENERAL", "APP_ENVIRONMENT"  , "", GetSrvIniName()), .F.)

  lMultiProc := cMultiProt == "1"
  lAppEnv    := cAppEnv    <> ""
  lConfigure := lMultiProc .And. lAppEnv
Return lConfigure

//-------------------------------------------------------------------
/*/{Protheus.doc} FATA900WZD
Wizard para auxiliar na configuração do Dashboard Backoffice

@author Squad CRM/Faturamento
@since 29/08/2022
/*/
//-------------------------------------------------------------------
Function FATA900WZD()

  Local oStepWiz 
	Local o1stPage 
	Local o2stPage 
	Local o3stPage 
	Local oDlg     
  Local lIsAdmin 

  FWLsPutAsyncInfo("LS006", RetCodUsr(), '05', "FATA900WZD")

  lIsAdmin := FWIsAdmin( __cUserID )

  DEFINE DIALOG oDlg TITLE ' ' PIXEL STYLE nOR( WS_VISIBLE, WS_POPUP )

    oDlg:nWidth  := 750
    oDlg:nHeight := 550

    oStepWiz := FWWizardControl():New(oDlg)
    oStepWiz:ActiveUISteps()

    //----------------------
    // Pagina 1 - Início
    //----------------------
    o1stPage := oStepWiz:AddStep("1STSTEP",{|Panel| cria_pn1(Panel, lIsAdmin)})
    o1stPage:SetStepDescription(OemToAnsi(STR0004))     // "Início"
    If lIsAdmin
      o1stPage:SetNextTitle(OemToAnsi(STR0005))         // "Avançar"
      o1stPage:SetNextAction({||.T.})                 
    Else
      o1stPage:SetNextTitle(OemToAnsi(STR0006))         // "Terminar"
      o1stPage:SetNextAction({||oDlg:End()})          
    EndIf
    o1stPage:SetCancelAction({|| .T.})                

    If lIsAdmin
      //----------------------
      // Pagina 2 - Recomendações Adm
      //----------------------
      o2stPage := oStepWiz:AddStep("2STSTEP",{|Panel| cria_pn2(Panel)})
      o2stPage:SetStepDescription(OemToAnsi(STR0008))   // "Avisos"
      o2stPage:SetNextTitle(OemToAnsi(STR0005))         // "Avançar"
      o2stPage:SetNextAction({||.T.})                   
      o2stPage:SetCancelAction({|| .T.})                

      //----------------------
      // Pagina 3 - Porta Multiprotocolo
      //----------------------
      o3stPage := oStepWiz:AddStep("3STSTEP",{|Panel| cria_pn3(Panel)})
      o3stPage:SetStepDescription(OemToAnsi(STR0009))   // "Configurações"
      o3stPage:SetNextTitle(OemToAnsi(STR0010))         // "Finalizar"
      o3stPage:SetCancelAction({|| .T.})                
    EndIf

    oStepWiz:activate()

  ACTIVATE DIALOG oDlg CENTER
  oStepWiz:Destroy()
  oStepWiz := Nil
  
Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} cria_pn1
Função para construção página do wizard
step 1 informações gerais do Dashboard Backoffice
@param oPanel

@author Squad CRM/Faturamento
@since 29/08/2022
/*/
//-------------------------------------------------------------------
Static Function cria_pn1(oPanel, lIsAdmin)

	Local cLinkTdn 
	Local cMsg001  
	Local oSay1    

	cLinkTdn := 'https://tdn.totvs.com/pages/releaseview.action?pageId=567767216'

	cMsg001 := "<b><a target='_blank' href='"+cLinkTDN+"'> "
	cMsg001 += STR0011  // "Saiba mais"
	cMsg001 += " </a></b>"
	cMsg001 += "<span color: #565759;'>" + "</span>"

	TSay():New(10,15,{|| STR0012 },oPanel,,oFontTit,,,,.T.,CLR_BLUE,)   // "Boas-vindas ao Dashboard Backoffice"
	TSay():New(35,15,{|| STR0013 },oPanel,,oFont2  ,,,,.T.,CLR_BLUE,)   // "O Dashboard Backoffice fornece um conjunto de funcionalidades para permitir adotar uma estratégia "
	TSay():New(45,15,{|| STR0014 },oPanel,,oFont2  ,,,,.T.,CLR_BLUE,)   // "que visa consolidar os principais indicadores da corporação em uma interface moderna."

  TSay():New(65,15,{|| STR0007 },oPanel,,oFont2  ,,,,.T.,CLR_BLUE,)   // "Consulte todas as informações sobre o Dashboard Backoffice no link abaixo:"
	oSay1 := TSay():New(75,15,{||cMsg001},oPanel,,oFont2,,,,.T.,,,220,20,,,,,,.T.)

	if !(lIsAdmin)
		TSay():New(95,15,{|| STR0015 },oPanel,,oFont2  ,,,,.T.,CLR_BLUE,) // "Algumas configurações são necessárias para acessar essa rotina."
		TSay():New(115,15,{|| STR0016 },oPanel,,oFont2N,,,,.T.,CLR_RED,)  // "Por favor, solicite ao administrador do sistema que acesse essa mesma rotina para realizar"
		TSay():New(125,15,{|| STR0017 },oPanel,,oFont2N,,,,.T.,CLR_RED,)  // "as configurações necessárias."
	else
		TSay():New(95,15,{|| STR0015 + " " + STR0018 },oPanel,,oFont2,,,,.T.,CLR_BLUE,) // "Algumas configurações são necessárias para acessar essa rotina." "Você será guiado nos próximos passos."
	endIf

	oSay1:bLClicked := {|| MsgRun( STR0019, "URL",{|| ShellExecute("open",cLinkTDN,"","",1) } ) } // "Abrindo o link... Aguarde..."

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} cria_pn2
Função para construção página do wizard
step 2 informações gerais do wizard
@param oPanel

@author Squad CRM/Faturamento
@since 02/03/2021
/*/
//-------------------------------------------------------------------
Static Function cria_pn2(oPanel As Object)

	Local cLinkTdn
	Local cMsg001 
	Local oSay1   

	cLinkTdn := 'https://tdn.totvs.com/pages/releaseview.action?pageId=707366113'

	TSay():New(10,15,{|| STR0008}, oPanel,,oFontTit,,,,.T.,CLR_BLUE,)   // "Avisos"
	TSay():New(35,15,{|| STR0020}, oPanel,,oFont2  ,,,,.T.,CLR_BLUE,)   // "Nos próximos passos, vamos apresentar todas as configurações necessárias para a execução do DashBoard."

  TSay():New(55,15,{|| STR0030}, oPanel,,oFont2  ,,,,.T.,CLR_BLUE,)   // "Consulte a abaixo documentação completa referente a este Wizard:"
	cMsg001 := "<b><a target='_blank' href='"+cLinkTDN+"'> "
	cMsg001 += STR0011  // "Saiba mais"
	cMsg001 += " </a></b>"
	cMsg001 += "<span color: #565759;'>" + "</span>"
	oSay1 := TSay():New(65,15,{||cMsg001},oPanel,,oFont2,,,,.T.,,,220,20,,,,,,.T.)
	oSay1:bLClicked := {|| MsgRun( STR0019 , "URL",{|| ShellExecute("open",cLinkTDN,"","",1) } ) }  // "Abrindo o link... Aguarde..."

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} cria_pn3
Função para construção página do wizard
step 3 porta multiprotocolo e app environment
@param oPanel

@author Squad CRM/Faturamento
@since 29/08/2022
/*/
//-------------------------------------------------------------------
Static Function cria_pn3(oPanel As Object)

	Local cMsg001 
	Local oSay1   

	TSay():New(10,15,{|| STR0022 },oPanel,,oFontTit,,,,.T.,CLR_BLUE,)   // "Porta Multiprotocolo e App Environment"

	TSay():New(35,15,{|| STR0023 },oPanel,,oFont2  ,,,,.T.,CLR_BLUE,)   // "Para acessar essa rotina precisa realizar as configurações da porta multiprocolo e a chave App Environment."

  cMsg001 := "<b> <a target='_blank' href='https://tdn.totvs.com/pages/releaseview.action?pageId=707366113'>"
  cMsg001 += STR0021  // "Clique aqui e consulte as configurações atuais e como elas devem ser definidas."
  cMsg001 += " </a></b>"
  cMsg001 += "<span color: #565759;'>" + "</span>"
  oSay1 := TSay():New(55,15,{||cMsg001},oPanel,,oFont2,,,,.T.,,,320,20,,,,,,.T.)
  oSay1:bLClicked := {|| logCfgDash() } 

  TSay():New(75,15,{|| STR0024 },oPanel,,oFont2N,,,,.T.,CLR_RED,)     // "Após definir as configurações no appserver.ini reinicie o serviço."

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} logCfgDash
Função para apresentar o log com as configuracoes atuais do appserver
e as que devem ser ajustadas.

@author Squad CRM/Faturamento
@since 30/08/2022
/*/
//-------------------------------------------------------------------
Static Function logCfgDash()

  AutoGRLog("====================================")
  AutoGRLog("Dashboard Backoffice                ")
  AutoGRLog("                                    ")
  AutoGRLog(STR0025                               )   // "A seguir são apresentadas as chaves "
  AutoGRLog(STR0026                               )   // "e suas respectivas seções conforme  "
  AutoGRLog(STR0027                               )   // "estão configuradas atualmente:      "
  AutoGRLog("====================================")
  AutoGRLog("                                    ")

  If Empty(cAppEnv)
    AutoGRLog("[GENERAL]                           ")
    AutoGRLog(";" + STR0028                         ) // "A chave abaixo N Ã O   E X I S T E "
    AutoGRLog(";APP_ENVIRONMENT=" + GetEnvServer()  )
    AutoGRLog("                                    ")
  Else
    AutoGRLog("[GENERAL]                           ")
    AutoGRLog("APP_ENVIRONMENT=" + cAppEnv          )
    AutoGRLog("                                    ")
  EndIf

  If Empty(cMultiProt)
    AutoGRLog("[DRIVERS]                           ")
    AutoGRLog(";" + STR0028                         ) // "A chave abaixo N Ã O   E X I S T E "
    AutoGRLog(";MULTIPROTOCOLPORT=1                ")
    AutoGRLog("                                    ")
  ElseIf cMultiProt <> "1"
    AutoGRLog("[DRIVERS]                           ")
    AutoGRLog("MULTIPROTOCOLPORT=" + cMultiProt     )
    AutoGRLog("                                    ")
  EndIf

  AutoGRLog("====================================")
  AutoGRLog(STR0025                               )   // "A seguir são apresentadas as chaves "
  AutoGRLog(STR0026                               )   // "e suas respectivas seções conforme  "
  AutoGRLog(STR0029                               )   // "devem ser ajustadas para uso do     "
  AutoGRLog("Dashboard Backoffice:               ")
  AutoGRLog("====================================")
  AutoGRLog("                                    ")

  If Empty(cAppEnv)
    AutoGRLog("[GENERAL]                           ")
    AutoGRLog("APP_ENVIRONMENT=" + GetEnvServer()   )
    AutoGRLog("                                    ")
  EndIf

  If Empty(cMultiProt) .Or. cMultiProt <> "1"
    AutoGRLog("[DRIVERS]                           ")
    AutoGRLog("MULTIPROTOCOLPORT=1                 ")
  EndIf

  MostraErro()
Return


