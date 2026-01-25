#Include 'TOTVS.ch'
#INCLUDE "STPOS.CH"
#INCLUDE "POSCSS.CH"
#INCLUDE "STIConsentTerm.CH"

/*/
{Protheus.doc} STIConsentTerm

Função responsavem por criar o texto que será exibido no termo de consentimento

@type function
@author Lucas Novais (lnovais)
@since 20/09/2019
@version P12.1.25
@return Nil, Nulo

/*/

Function STIConsentTerm()

Local lLjTermCo 	:= ExistBlock("LjTermCo")   // Indica se ponto de entrada LjTermCo esta compilado no RPO
Local cTextHtml     := ""                       // Texto contendo informações presentes no Termo.

/* Template Padrão do termo de consentimento */
cTextHtml += '<br>'
cTextHtml += '<font size="10" color="black" >' + STR0001 + '</font><br/>' //"Termo de consentimento"
cTextHtml += '<br>'
cTextHtml += '<br>'
cTextHtml += '<font size="5" color="#424242">' + STR0002 + '</font><br/>'//"Informar ao cliente que os dados pessoais cadastrados serão utilizados com as finalidades de sua identificação na realização de: "
cTextHtml += '<br>'
cTextHtml += '<font size="5" color="#424242">' + STR0003 + '</font><br/>'//" - Vendas"
cTextHtml += '<br>'
cTextHtml += '<font size="5" color="#424242">' + STR0004 + '</font><br/>'//" - Devoluções"
cTextHtml += '<br>'
cTextHtml += '<font size="5" color="#424242">' + STR0005 + '</font><br/>'//" - Entrega a domicílio"
cTextHtml += '<br>'
cTextHtml += '<font size="5" color="#424242">' + STR0006 + '</font><br/>'//" - Análise de crédito"
cTextHtml += '<br>'
cTextHtml += '<font size="5" color="#424242">' + STR0007 + '</font><br/>'//" - Títulos financeiro"
cTextHtml += '<br>'
cTextHtml += '<font size="5" color="#424242">' + STR0008 + '</font><br/>'//" - Campanhas de propaganda"

If lLjTermCo
    cTextHtml := ExecBlock("LjTermCo",.F.,.F.,{cTextHtml})
EndIf 

If Empty(cTextHtml)
    STIIncCustomer()
    LjGrvLog("STIConsentTerm","Ponto de entrada LjTermCo Compilado")
    LjGrvLog("STIConsentTerm","A Tela com Termo de consentimento não será exibida pois o retorno do ponto de entrada LjTermCo esta vazio.")
Else
    LjGrvLog("STIConsentTerm","Mensagem que será exibida para o termo de consentimento: ",cTextHtml)
    STFCleanInterfaceMessage()
    STIExchangePanel({|| STITerm(cTextHtml) })
Endif 

return

/*/
{Protheus.doc} STITerm

Função resposavel por Printar o parametro cTextHtml contendo as informações do termo de consentimento 

@type function
@author Lucas Novais (lnovais)
@since 20/09/2019
@version P12.1.25
@param cTextHtml, caracter, Texto que será exibido como termo de consentimento
@return oMainPanel, Objeto com infomações da Painel que será aberto.

/*/

Static Function STITerm(cTextHtml)

Local oPanelMVC		:= STIGetDlg()		                                                                //Painel principal do dialog
Local oMainPanel 	:= TPanel():New(00,00,"",oPanelMVC,,,,,,oPanelMVC:nWidth/2,(oPanelMVC:nHeight)/2)   //Painel do Termo de consentimento
Local lHtml         := .T.                                                                              //Indica que o Say sera em HTML
Local oFont         := TFont():New('Courier new',,-18,.T.)                                              //Fonte padrão do Say
Local oTexto                                                                                            //Objeto TSAY
Local oBtnAceito                                                                                        //Botão Aceito
Local oBtnDeclino                                                                                       //Botão Declino
Local lStiMataObj   := Iif(ExistFunc("StiMataObj"),.T.,.F.)                                             //Verifica se a função StiMataObj() existe                                     

oMainPanel:SetCSS(POSCSS(GetClassName(oMainPanel),CSS_PANEL_CONTEXT))

oTexto := TSay():New(020,008, {||cTextHtml},oMainPanel,,oFont,,,,.T.,,,oMainPanel:nWidth/2.10,oPanelMVC:nHeight/2,,,,,,lHtml)
oTexto:SetCSS( POSCSS(GetClassName(oTexto),CSS_LABEL_FOCAL))

oBtnAceito:= TButton():New(POSVERT_BTNFOCAL,POSHOR_BTNFOCAL,STR0009,oMainPanel,{ || Iif(lStiMataObj,StiMataObj(oMainPanel),Nil), STIIncCustomer()},LARGBTN,ALTURABTN,,,,.T.)//"Aceitar"
oBtnAceito:SetCSS(POSCSS(GetClassName(oBtnAceito),CSS_BTN_FOCAL))	

oBtnDeclino:= TButton():New(POSVERT_BTNFOCAL,POSHOR_1,STR0010,oMainPanel,{ || Iif(lStiMataObj,StiMataObj(oMainPanel),Nil), STIRegItemInterface() },LARGBTN,ALTURABTN,,,,.T.)//"Declinar"				
oBtnDeclino:SetCSS(POSCSS(GetClassName(oBtnDeclino),CSS_BTN_NORMAL))

Return oMainPanel
