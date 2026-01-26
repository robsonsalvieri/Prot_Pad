#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "AJSXRSP.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±                 
±±ºPrograma    ³AjSXRSP    ºAutor    ³Inovação - RH       º Data ³  29/06/2015 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.       ³ Fonte responsávels pelos ajustas na versão p12.               º±±
±±º            ³                                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAnalista    ³ DATA      ³ Ticket/Issue³  MOTIVO DA ALTERACAO                ³±±
±±º            ³           ³             ³                                     ³±±
±±ºMarcelo F   ³20/01/2017 ³ #375145     ³Ajuste na função RSPLoad para inclus.³±±
±±º            ³           ³ MRH-5681    ³do campo responsável no perg. RSR004 ³±±
±±³            ³           ³             ³                                     ³±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍ±±ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/ 

Main function RSPLoad()
Local lRet := .T.

//Verifica uso do Modulo
If !RspUsaModulo()
	Final()
EndIf

lRet := fChkConv12()
If !lRet
	Return
Endif

Return (.T.)

/*/{Protheus.doc} RspUsaModulo()
	(long_description)
	@type  Function
	@author Emerson Grassi Rocha
	@since 24/04/2025
	@version version
	/*/
Function RspUsaModulo()

Local lRet 	:= .T.
Local nSQG	:= 0
Local nSQD	:= 0
Local nSQS	:= 0
Local cUrl 	:= "https://produtos.totvs.com/ficha-tecnica/tudo-sobre-o-totvs-rh-atracao-de-talentos/"

dbSelectArea("SQG") //Curriculo
nSQG := SQG->(RecCount())

dbSelectArea("SQD") //Agenda
nSQD := SQD->(RecCount())

If nSQG <= 12 .And. nSQD <= 12
			
	nOp := Aviso( 	STR0001, STR0002 + chr(13) + chr(13) +; 	//"Atenção"###"Prezado usuário, não foi possivel abrir o módulo SIGARSP. Entre em contato com o seu Executivo de conta."
					STR0003 + chr(13) + chr(13) + cUrl,; 			//"A Solução TOTVS Atração de Talentos (ATS) simplifica o processo de Recrutamento e Seleção, promovendo a diversidade e acessibilidade tanto para empresas quanto para as pessoas candidatas."
					{OemToAnsi(STR0004), OemToAnsi(STR0005)}) 	//"Link documentação"###"Fechar"

	If nOp == 1
		shellExecute("Open",cUrl, "", "", 1)
	EndIf
	
	lRet := .F.
EndIf

Return lRet
