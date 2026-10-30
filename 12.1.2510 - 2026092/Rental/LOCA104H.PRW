#Include "loca104h.ch"
#INCLUDE "TOTVS.CH"
#include "FWMVCDEF.CH"
/*/{Protheus.doc} LOCA104H
Rotina para Estornar o documento de entrada referente ao romaneio posicionado
@type function
@version 25.10
@author Alexandre Circenis
@since 05/11/2025
@return variant, retorna o sucesso da operação
/*/
Function LOCA104H()
	Local aArea := GetArea()

	PRIVATE _LTUDOOK   := .F.
	PRIVATE cAviso     := ""
	PRIVATE cProjet    := FQU->FQU_PROJET
	PRIVATE _CFILAUX   // FRANK 07/10/2020 - FILIAL PARA GERACAO DA NOTA DE REMESSA SEM SER VIA ROMANEIO
	PRIVATE aFPYTransf := {} // Deve ser private e serão utilizadas no LOCM006
	PRIVATE aFPZTransf := {} // Deve ser private e serão utilizadas no LOCM006
	Private aBlqRemessa // Array com bloqueios de documento
	private _nzuc     := 0  // recno da zuc (conjunto transportador) usado no ponto de entrada mt103fim, gernfret e a103devol - frank 02/11/20

	// Validação pré geração de nota de retorno
	if !FQW->FQW_STATUS $'56'
		MsgAlert(STR0002, STR0001) //"Atenção" //"Romaneio não tem Documento de Retorno gerado. Não é possivel continuar!"
		RestArea(aArea)
		Return .T.
	endif

	if MsgYesNo(STR0005+FQW->FQW_NFRET+ STR0004+FQW->FQW_SERRET, STR0003) //"Exclusão de Documento de Retorno" //" serie " //"Confirme a exclusão do Documento "
		FWMsgRun(, {|oSay| LOCA104HEST(oSay) }, "", STR0006+FQW->FQW_NFRET+ STR0004+FQW->FQW_SERRET) //" serie " //"Processando a exclusão do Documento "
	endif

RETURN .T.

/*/{Protheus.doc} LOCA104HEST
Processo de estorno do Documento de Devolução
@type function
@version  25.10
@author Alexandre Circenis
@since 6/25/2025
@param oView, object, View de origem 
@return variant, Retorna .f. para fechar a janela
/*/
FUNCTION LOCA104HEST(oSay)
Local aArea		As Array	
Local aAreaSF1	As Array
Local cF1_DOC	As Character
Local cF1_SERIE	As Character
Local cF1_FORN	As Character
Local cF1_LOJA	As Character
Local cF1_TIPO	As Character
Local lRet		As Logical		
Local cChaveSF1	As Character
Local aCabNFE	As Array
Local aIteNFE	As Array
Local lPreNota	As Logical
Local aErro		As Array	
Local nX		As Numeric
Local cMsg		As Character
Local aAreaSN1 	As Array			

aArea				:= GetArea()
aAreaSF1			:= SF1->(GetArea())
cF1_DOC				:= FQW->FQW_NFRET
cF1_SERIE			:= FQW->FQW_SERRET
cF1_FORN			:= FQW->FQW_CLIDEV
cF1_LOJA			:= FQW->FQW_LOJDEV
cF1_TIPO			:= FQW->FQW_TIPONF
lRet				:= .T.
cChaveSF1			:= ""
aCabNFE				:= {}
aIteNFE				:= {}
lPreNota			:= .T.
aErro				:= {}
nX					:= 0
cMsg				:= ""
aAreaSN1    		:= SN1->(GetArea())

//Controle de rotina automatica
Private lMsErroAuto		:= .F. //Determina se houve algum tipo de erro durante a execucao do ExecAuto
Private lMsHelpAuto		:= .T. //Define se mostra ou não os erros na tela (T= Nao mostra; F=Mostra)
Private lAutoErrNoFile	:= .T. //Habilita a gravacao de erro da rotina automatica

cChaveSF1 := XFilial("SF1") + cF1_DOC + cF1_SERIE + cF1_FORN + cF1_LOJA + cF1_TIPO

DbSelectArea("SF1")
SF1->(DbSetOrder(1)) //F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO
If SF1->(DbSeek(cChaveSF1))

	//Cabeçalho do Documento de Entrada
	Aadd(aCabNFE, {"F1_DOC"		,SF1->F1_DOC		,Nil})
	Aadd(aCabNFE, {"F1_SERIE"	,SF1->F1_SERIE		,Nil})
	Aadd(aCabNFE, {"F1_FORNECE"	,SF1->F1_FORNECE	,Nil})
	Aadd(aCabNFE, {"F1_LOJA"	,SF1->F1_LOJA		,Nil})
	Aadd(aCabNFE, {"F1_TIPO"	,SF1->F1_TIPO		,Nil})

	//lPreNota := Empty(SF1->F1_STATUS) //Documento nao classificado, excluir pelo MATA140

Else
	lRet := .F.
	cMsg := STR0007 //"O documento de entrada não foi localizado para exclusão."
EndIf

If lRet

	//If lPreNota	// Pré Nota - Exclusão do Documento de Entrada no MATA140
	//	MSExecAuto( { |x,y,z| MATA140(x,y,z) }, aCabNFE,aIteNFE,5 )
	//Else // Documento Fiscal - Exclusão do Documento de Entrada no MATA103
		MSExecAuto( { |x,y,z| MATA103(x,y,z) }, aCabNFE,aIteNFE,5 )
	//EndIf

	oSay:SetText(STR0008+" . . .")  //"Executando o estorno do documento de retorno"
	
	If lMsErroAuto
		aErro := GetAutoGrLog()
		cMsg := ""

		For nX := 1 To Len(aErro)
			cMsg += aErro[nX] + CRLF
		Next nX

		lRet := .F.
	EndIf
EndIf

if !lRet
	MsgAlert(cMsg, STR0009) //"Erro no estorno da nota"
endif

RestArea(aAreaSN1)
RestArea(aAreaSF1)
RestArea(aArea)

Return lRet
