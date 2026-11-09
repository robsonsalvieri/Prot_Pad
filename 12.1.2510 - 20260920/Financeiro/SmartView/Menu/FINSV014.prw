#Include 'totvs.ch'
#include 'fwlibversion.ch'
#include 'FINSV014.ch'


/*/{Protheus.doc} FINSV014
    Chamada do Smart View no menu - Bank Statement - Extrato Bancário

    @author guilhermed.santos@totvs.com.br
    @since 21/09/2023
    @version 12.1.2310
*/

Function FINSV014()

    Local lSuccess          As Logical
    Local cError            As Character
	Local cMsg              As Character
    local jParams           As Json 
    local oSmartView        As object
    local lLibVersion       As Logical 
    local lExclusiveShare   As Logical 
    local oProfile          As object
    local lHasParams        As Logical 

    lLibVersion     := FwLibVersion() < "20240226"
    lExclusiveShare :=  FWModeAccess("SA6", 1) + FWModeAccess("SA6", 2) + FWModeAccess("SA6", 3) == "EEE"
    
    if !FWSX1Util():ExistPergunte("FINT038")
		FINSV014HLP()
        return
	endIf  

    If GetRpoRelease() > '12.1.2210' 
        If lLibVersion 
            lSuccess := totvs.framework.treports.callTReports("backoffice.sv.fin.bankstatement",,,,,.F.,,.T., @cError)
            
            If !lSuccess
            Conout(cError)
            EndIf
        Else              
            oSmartView := totvs.framework.smartview.callSmartView():new("backoffice.sv.fin.bankstatement")
            lHasParams := oSmartView:loadParamsProfile("totvs.protheus.backoffice.fin.smartview.integratedprovider.bankstatementsmartviewbusinessobject", @oProfile)

            If lHasParams
                FINSV014Pr(oProfile)
            EndIf

            if lExclusiveShare 
                jParams := JsonObject():new()
                jParams["parameters"] := Array(1)
                jParams["force"] := .T. //Indica se força o valor
                jParams["parameters"][1] := JsonObject():New()
                jParams["parameters"][1]["name"] := "SV_MULTBRANCH"
                jParams["parameters"][1]["value"] := FWxFilial("SA6")
                jParams["parameters"][1]["visibility"] := "Disabled"

                oSmartView:setParameters(jParams)
                oSmartView:setForceParams(.T.)
            EndIf

            lSuccess := oSmartView:executeSmartView()

            If !lSuccess
                cMsg := oSmartView:getError()
            EndIf 

            oSmartView:Destroy()
        EndIf
    Else
        Conout("rotina não disponivel")
    EndIf

Return

static function FINSV014HLP()
    Local cMsg 		     As character
	Local cTitulo 	     As character
	Local aBtLinks 	     As array
	Local cColorTitle    As character
	Local cColorSubTitle As character
	Local cColorText 	 As character

    cMsg 		        := "" 
	cTitulo 	        := "" 
	aBtLinks 	        := ARRAY(1,2) 
	cColorTitle         := "" 
	cColorSubTitle      := "" 
	cColorText 	        := "" 

	setHelpColors(@cColorTitle,@cColorSubTitle,@cColorText)

	cTitulo  := STR0001 + " - " + STR0002 //FINSV024 - Movimento Financeiro Diário

	cMsg := "<font size='5' color='"+ cColorTitle +"'><b>" + STR0003 + " - " + STR0001 + "</b></font><br/><br/>"//HELP - FINSV014

	cMsg += "<font size='3' color='"+ cColorSubTitle +"'><b>" + STR0004 + "</b></font><br/>" //Ocorrência
	cMsg += "<font size='3' color='"+ cColorText +"'>" + STR0005 + "</font><br/><br/>"//Grupo de perguntas FINT038 ausente.

	cMsg += "<font size='3' color='"+ cColorSubTitle +"'><b>" + STR0006 + "</b></font><br/>" //Solução
	cMsg += "<font size='3' color='"+ cColorText +"'>" + STR0007 + "</font><br/><br/>" //A partir da Expedição Contínua de setembro/2026, é necessário executar o UPDDISTR para criar o novo grupo de perguntas e garantir a execução correta do relatório.

	cMsg += "<font size='3' color='"+ cColorSubTitle +"'><b>" + STR0008 + "</b></font>" //Para maiores informações acesse:
	cMsg += "<br/><br/>"

	aBtLinks[1,1] :=  STR0009 + " - " + STR0001 //Documento de referência - FINSV014
	aBtLinks[1,2] := "https://tdn.totvs.com/pages/viewpage.action?pageId=759953066"

    FinHelp(cTitulo, cMsg, aBtLinks, 400, 600)
Return

/*/{Protheus.doc} FINSV014Pr
    Trata o profile de parametros salvo do usuario, comparando o tipo de cada
    parametro gravado no profile com o tipo definido no dicionario SX1 (grupo
    FINT038). Caso haja divergencia de tipo (estrutura do grupo de perguntas
    alterada), o profile e apagado para evitar erro na execucao do relatorio.

    @param oProfile - Objeto FWProfile carregado via loadParamsProfile

    @author matheus.epova@totvs.com.br
    @since 04/09/2026
    @version 12.1.2510
*/
Static Function FINSV014Pr(oProfile as object)
    Local oPergSx1 As object
    Local aSx1     As array
    Local aProfile As array
    Local lDelete  As logical
    Local nX       As numeric

    oPergSx1 := Nil
    aSx1     := {}
    aProfile := {}
    lDelete  := .F.
    nX       := 0

    oPergSx1 := FWSX1Util():New()
    oPergSx1:AddGroup("FINT038")
    oPergSx1:SearchGroup()
    aSx1     := oPergSx1:GetGroup("FINT038")
    aProfile := oProfile:Load()

    For nX := 1 To Len(aSx1[2])
        If ValType(aProfile[2][nX]) != (aSx1[2][nX]:CX1_TIPO)
            lDelete := .T.
            Exit
        EndIf
    Next nX

    If lDelete
        oProfile:Delete()
    EndIf

    FwFreeObj(oPergSx1)
    FwFreeArray(aSx1)
    FwFreeArray(aProfile)
Return
