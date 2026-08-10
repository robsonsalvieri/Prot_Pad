#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "PFSNPSAPP.CH"
 
#DEFINE SW_SHOW	5	 // Mostra na posição mais recente da janela

//-------------------------------------------------------------------
/*/{Protheus.doc} PFSNPSAPP
App de NPS com Dialog

@author Willian Yoshiaki Kazahaya
@since 22/12/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Function PFSNPSAPP(lMsgValid)
Local oDlg := Nil
Local oNPS := GsNps():New()

Default lMsgValid := .F.

	oNps:setProductName("PreFatJuridico") // Chave Agrupadora do Produto

	If (oNps:canSendAnswer())
		// 1º Param: Nome da Aplicação
		// 2º Param: Dialog. Caso vazio, pega a janela inteira
		// 6º Param: Nome do fonte caso seja diferente do App
		DEFINE MSDIALOG oDlg FROM 0,0 TO 33, 120 TITLE "NPS" Style 128

		ACTIVATE MSDIALOG oDlg CENTERED ON INIT ( PfsNps( oDlg ) )
	EndIf
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} PfsNps( oDlg )
Chamada do APP dentro da Dialog

@param oDlg - Dialog de destino para App abrir

@author Willian Yoshiaki Kazahaya
@since 22/12/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function PfsNps( oDlg )
	FWCallApp( "tecnps", oDlg, , , , "PFSNPSAPP")
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} JsToAdvpl(oWebChannel, cType, cContent)
Chamada do APP dentro da Dialog

@param oWebChannel - WebChannel para enviar informação para o App
@param cType - "Tipo" da chamada na chamada Via App
@param cContent - Conteudo adicional recebido do App

@author Willian Yoshiaki Kazahaya
@since 22/12/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JsToAdvpl(oWebChannel, cType, cContent)
	Do Case
		Case cType == "preLoad"
			appPreLoad(oWebChannel)
	EndCase
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} appPreLoad(oWebChannel)
Passa os parâmetros de PreLoad para o App

@param oWebChannel - WebChannel para enviar informação para o App

@author Willian Yoshiaki Kazahaya
@since 22/12/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function appPreLoad(oWebChannel)
	// Para desenvolvimento trocar para PreFatDev
	// Para produção trocar para PreFatJuridico
	oWebChannel:AdvPLToJS( "setProdutoNPS", "PreFatJuridico") 
	oWebChannel:AdvPLToJS( "setURLEndpoint", "WSPfsMet/nps" )
	oWebChannel:AdvPLToJS( "setProductLabel", STR0003 ) //"TOTVS Pré Faturamento de Serviços"
Return Nil
