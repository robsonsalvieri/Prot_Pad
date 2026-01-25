#INCLUDE "TOTVS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "RHLIBAPI.CH"
#Include "TBICONN.CH"
#Include "FWAdapterEAI.ch"
#include 'parmtype.ch'

#DEFINE TAB CHR ( 13 ) + CHR ( 10 )

/*
{Protheus.doc} fSetInforRJP(nOperacao,)
Biblioteca de funcoes para tratamento de envio de dados de API                    
@author  Wesley Alves Pereira
@since   23/03/2020
@version 12.1.27
*/

Function fSetInforRJP(cTmpFil, cTmpMat, cProces, cChaves, cOperac,  dDtBase, cHoraAt,cUserId)
//cTmpFil - Filial da Entidade
//cTmpMat - Matricula do Funcionario
//cProces - Tabela da Entidade
//cChaves - Chave da Entidade
//cOperac - Tipo da operacao
//dDtBase - Data da operacao
//cHoraAt - Hora da operacao
//cUserId - Usuario da operacao

Local lReto := .F.
Local lAltReg := .F.
Local TamFil := TamSX3( 'RJP_FIL' )[1] - Len(cTmpFil)
Local TamMat := TamSX3( 'RJP_MAT' )[1] - Len(cTmpMat)
Local CIncSemInteg := "I"

cTmpFil := cTmpFil + Space(TamFil)
cTmpMat := cTmpMat + Space(TamMat)  

If ! TcCanOpen(RetSqlName("RJP"))
	Help( " ", 1, OemToAnsi(STR0001),, OemToAnsi(STR0002), 1, 0 )
	Return (lReto)
EndIf

If (cOperac == 'E')
	DBSelectArea("RJP")
	DBSetOrder(1)
	If DBSeek(xFilial("RJP")+cTmpFil+cTmpMat)
		While ! EOF() .AND. RJP->RJP_FILIAL == xFilial("RJP") .AND. RJP->RJP_FIL == cTmpFil .AND. RJP->RJP_MAT == cTmpMat 
			If  ( ( Alltrim(RJP->RJP_TAB) == Alltrim(cProces)) .AND. ( Alltrim(RJP->RJP_KEY) == Alltrim(cChaves) ) .AND. ( RJP->RJP_OPER == 'I') .AND. Empty(RJP->RJP_DTIN))
				If RecLock("RJP",.F.)
					RJP->(DbDelete())

					lReto := .T. 
				
					Return (lReto)

				EndIf
			EndIf
			
			DBSelectArea("RJP")
			DBSkip()
		
		EndDo	
	EndIf	
EndIf

DBSelectArea("RJP")
DBSetOrder(7)
If (RJP->(DBSeek(xFilial("RJP")+cProces+cChaves)))
	While RJP->RJP_FILIAL== xFilial("RJP") .AND. RJP->RJP_TAB == cProces .AND. RJP->RJP_FIL == cTmpFil ;
	.AND. ( RJP->RJP_OPER == cOperac .OR. RJP->RJP_OPER == CIncSemInteg ) .AND. AllTrim(RJP->RJP_KEY) == AllTrim(cChaves)

		If Empty(RJP->RJP_DTIN)	
			If RecLock("RJP",.F.)

				RJP->RJP_DATA   := dDtBase
				RJP->RJP_HORA   := cHoraAt
				RJP->RJP_USER   := cUserId
					
				RJP->(MsUnlock())

				lReto 	:= .T.
				lAltReg	:= .T.
			EndIf
		EndIf
		DBSkip()		
	EndDo
Endif

If !lAltReg .And. RecLock("RJP",.T.)

		RJP->RJP_FILIAL := xFilial("RJP")
		RJP->RJP_FIL    := cTmpFil
		RJP->RJP_MAT    := cTmpMat
		RJP->RJP_TAB    := cProces
		RJP->RJP_KEY    := cChaves
		RJP->RJP_DATA   := dDtBase
		RJP->RJP_HORA   := cHoraAt
		RJP->RJP_OPER   := cOperac
		RJP->RJP_USER   := cUserId
	
		RJP->(MsUnlock())

		lReto := .T.
EndIf

Return (lReto)

/*
{Protheus.doc} fSetDeptoRJP(nOperacao,)
Biblioteca de funcoes para tratamento de envio de dados de API                    
@author  brdwc0032
@since   23/03/2020
@version 12.1.27
*/

Function fSetDeptoRJP(cTmpFil, cProces, cChaves, cOperac,  dDtBase, cHoraAt, cUserId, lCompTab)
	//cTmpFil - Filial da Entidade
	//cProces - Tabela da Entidade
	//cChaves - Chave da Entidade
	//cOperac - Tipo da operacao
	//dDtBase - Data da operacao
	//cHoraAt - Hora da operacao
	//cUserId - Usuario da operacao
	//lCompTab - Tabela SQB/SQ3 totalmente Compartilhada
	Local lReto := .F.
	Local lAltReg := .F.
	Local TamFil := TamSX3( 'RJP_FIL' )[1] - Len(cTmpFil)
	Local CIncSemInteg := "I"
	Local cFilRJP	:= ""

	Default lCompTab	:= .F.

	// Verifica Compartilhamento Tabelas SQB/SQ3
	// Quando SQB/SQ3 for totalmente Compartilhada o campo RJP_FILIAL deverá pertencer 
	// a mesma Filial do campo RJP_FIL para viabilização do Schedule
	cTmpFil := cTmpFil + Space(TamFil) 
	cFilRJP	:= If(lCompTab,xFilial("RJP",cTmpFil),xFilial("RJP"))

	If ! TcCanOpen(RetSqlName("RJP"))
		Help( " ", 1, OemToAnsi(STR0001),, OemToAnsi(STR0002), 1, 0 )
		Return (lReto)
	EndIf

	If (cOperac == 'E')
		DBSelectArea("RJP")
		DBSetOrder(7)
		If DBSeek(cFilRJP+cProces+cChaves)
			While ! EOF() .AND. RJP->RJP_FILIAL == xFilial("RJP") .AND. RJP->RJP_FIL == cTmpFil .AND. RJP->RJP_TAB == cProces .AND. Alltrim(RJP->RJP_KEY) == Alltrim(cChaves) 
				If  ( ( Alltrim(RJP->RJP_TAB) == Alltrim(cProces)) .AND. ( Alltrim(RJP->RJP_KEY) == Alltrim(cChaves) ) .AND. ( RJP->RJP_OPER == 'I') .AND. Empty(RJP->RJP_DTIN))
					If RecLock("RJP",.F.)
						RJP->(DbDelete())

						lReto := .T. 
					
						Return (lReto)

					EndIf
				EndIf
				
				DBSelectArea("RJP")
				DBSkip()
			
			EndDo	
		EndIf	
	EndIf

	DBSelectArea("RJP")
	DBSetOrder(7)
	If (RJP->(DBSeek(cFilRJP+cProces+cChaves)))
		While RJP->RJP_FILIAL== cFilRJP .AND. RJP->RJP_TAB == cProces .AND. RJP->RJP_FIL == cTmpFil ;
		.AND. ( RJP->RJP_OPER == cOperac .OR. RJP->RJP_OPER == CIncSemInteg ) .AND. AllTrim(RJP->RJP_KEY) == AllTrim(cChaves)

			If Empty(RJP->RJP_DTIN)	
				If RecLock("RJP",.F.)

					RJP->RJP_DATA   := dDtBase
					RJP->RJP_HORA   := cHoraAt
					RJP->RJP_USER   := cUserId
						
					RJP->(MsUnlock())

					lReto := .T.
					lAltReg	:= .T.
				EndIf
			EndIf
			DBSkip()		
		EndDo
	Endif

	If !lAltReg .And. RecLock("RJP",.T.)			
				
			RJP->RJP_FILIAL := cFilRJP
			RJP->RJP_FIL    := cTmpFil
			RJP->RJP_MAT    := Space(TamSX3("RJP_MAT")[1])
			RJP->RJP_TAB    := cProces
			RJP->RJP_KEY    := cChaves
			RJP->RJP_DATA   := dDtBase
			RJP->RJP_HORA   := cHoraAt
			RJP->RJP_OPER   := cOperac
			RJP->RJP_USER   := cUserId
			If Funname() == "GPEM925"
				RJP->RJP_CGINIC := '1'
				If cProces == "SQ3" .And. Type("aLogSq3") == "A"
					Aadd(aLogSq3,{ cChaves, dDtBase, cHoraAt, cUserId })
				ElseIf cProces == "SQB" .And. Type("aLogSqb") == "A"
					Aadd(aLogSqb,{ cChaves, dDtBase, cHoraAt, cUserId })
				EndIf
			EndIf	
			RJP->(MsUnlock())

			lReto := .T.
	EndIf

Return (lReto)

//-------------------------------------------------------------------
/*/{Protheus.doc} function fFormTel
Recebe o DDD e Telefone e retorna formatado para envio na API
@author  Hugo de Oliveira
@since   18/05/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Function fFormTel(cDDD, cTelefone)
    
    DEFAULT cDDD := ""
    DEFAULT cTelefone := ""

    If Len(cTelefone) > 7 .AND. !Empty(cTelefone) // Tamanho Mínimo: 8
        If !Empty(cDDD)
            cTelefone := cDDD + " " + cTelefone
        EndIf

        If Len(cTelefone) == 9 // "975434543" - Sem DDD(Obrigatório)
            cTelefone := "XX " + cTelefone

        ElseIf Len(cTelefone) == 8 // "75434543" - Sem 9 Dígito(Não Obrigatório) e sem DDD(Obrigatório)
            cTelefone := "XX " + cTelefone
        EndIf
    Else
        cTelefone := ""
    EndIf
Return cTelefone

//-------------------------------------------------------------------
/*/{Protheus.doc} function prepIntQrn
Funcão responsável integrar com as APIs do Quirons
@author  Marcio Felipe Martins
@since   01/11/2023
@version 1.0
/*/
//-------------------------------------------------------------------
Function prepIntQrn(nRecno, cResource, cBody, cOperac, cCodSucss, lAborta)

	Local oNG
	Local oRet
	Local lRet	 	:= .F.
	Local cRet		:= ""
	Local cRetCode	:= ""
	Local lHeader   := .T.
	
	//Tratamento de erro
	Local cError   := ""
	Local bError   := ErrorBlock({ |oError| cError := oError:Description })

	DEFAULT nRecno		:= 0
	DEFAULT cResource	:= ""
	DEFAULT cBody		:= ""
	DEFAULT cOperac		:= ""
	DEFAULT cCodSucss	:= "200|201|202|203|204"
	DEFAULT lAborta		:= .F.

	oNG := FwRest():New(cURI)
	oNG:setPath(cResource)	
	oNG:SetChkStatus(.F.) //Assume a responsabilidade de avaliar o HTTP Code retornado pela requisição

	//Remove acentos e caracteres especiais do json que sera enviado ao Quirons
	cBody := FSubstJson(cBody)

	Begin Sequence
		Do Case
			Case cOperac == "I"
				oNG:SetPostParams(cBody)
				lHeader := oNG:Post(aHeadReq)
			Case cOperac $ "A|D"
				oNG:SetPostParams(cBody)
				lHeader := oNG:Put(aHeadReq,cBody)
			Case cOperac == "E"
				lHeader := oNG:Delete(aHeadReq)
		EndCase

		oRet := JsonObject():new()
		lRet := FWJsonDeserialize(oNG:GetResult(), @oRet)

		If oNG:GetResult() <> Nil 
			cRet	 := IIf(DecodeUtf8(oNG:GetResult()) <> Nil, DecodeUtf8(oNG:GetResult()), oNG:GetResult())
		ElseIf !lRet .And. oNG:GetLastError() <> Nil
			cRet	 := DecodeUtf8(oNG:GetLastError())
		EndIf

		cRetCode := oNG:GetHTTPCode()
	End Sequence

	//Se acontecer algum erro crítico, captura a mensagem de erro
	ErrorBlock(bError)        
	cRet += IIf(!Empty(cError), OemToAnsi(STR0004) + cError, "")

	IIf(cOperac == "E" .AND. !lRet .And. cRetCode $ cCodSucss .AND. Empty(cRet), lRet := .T., Nil)

	//Atualiza Retorno na RJP e Histórico(RU7)
	fAtuRJPRet(nRecno, cRetCode, cRet, cCodSucss, cBody)

	//A depender do erro não faz sentido continuar enviando outros registros, o processo deve ser abortado
	If !Empty(cError) .Or. cRetCode $ "401"
		lAborta := .T.
		cRet := cRetCode + " - " + FSubst(cRet)
		FWLogMsg("FATAL", , "GPEM923", , , , cRet, , , )
	EndIf
	
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} function fAtuRJPRet
Atualiza retorno da API na RJP
@author  Marcio Felipe Martins
@since   18/05/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Function fAtuRJPRet(nRecno, cRetCode, cRet, cCodSucss, cBody)

	Local lOk		:= .F.
	Local lTudoOk	:= .T.
	Local dDtIn		:= DATE()
	Local cHoraIn	:= TIME()

	DEFAULT nRecno		:= 0
	DEFAULT cRetCode	:= ""
	DEFAULT cRet		:= ""
	DEFAULT cCodSucss	:= "200|201|202|203|204"
	DEFAULT cBody		:= ""

	DbSelectArea("RJP")
	RJP->( DbGoTop() )
	DbGoTo(nRecno)
	If !Eof()
		lTudoOk := cRetCode $ cCodSucss
		If Reclock("RJP", .F.)
			RJP->RJP_DTIN	:= dDtIn
			RJP->RJP_HORAIN	:= cHoraIn
			RJP->RJP_RTN := IIf(lTudoOk, STR0003, cRetCode + " - " + cRet)// "Registro integrado com sucesso!"

			If ISINCALLSTACK("prepIntQrn") .And. (cGrvHist == "2" .Or. (!lTudoOk .And. cGrvHist == "1"))
				fGrvRU7(dDtIn, cHoraIn, cBody, lTudoOk, cRetCode)
			EndIf
			RJP->(MsUnlock())

			lOk := .T.
		EndIf
	EndIf

Return lOk

//-------------------------------------------------------------------
/*/{Protheus.doc} function fGrvRU7
Funcão responsável por gravar o histórico na tabela RU7
@author  Marcio Felipe Martins
@since   01/11/2023
@version 1.0
/*/
//-------------------------------------------------------------------
Function fGrvRU7(dDtIn, cHoraIn, cBody, lTudoOk, cRetCode)
	Local lRet		:= .T.
	Local aArea		:= GetArea()
	Local cIdRU7	:= ""
	Local cSeqRU7	:= ""
	Local lRU7Atual	:= RU7->(ColumnPos("RU7_CODRET")) > 0

	DEFAULT dDtIn	:= STOD("")
	DEFAULT cHoraIn	:= ""
	DEFAULT	cBody	:= ""
	DEFAULT lTudoOk := .F.
	DEFAULT cRetCode := ""
	
	cIdRU7 := RJP->RJP_FIL + RJP->RJP_MAT + RJP->RJP_TAB + RJP->RJP_OPER
	DbSelectArea("RU7")
	RU7->(DbSetOrder(1))	
	If RU7->(DbSeek(xFilial("RU7",RJP->RJP_FILIAL) + cIdRU7))		
		While !RU7->(EOF()) .And. AllTrim(RU7->RU7_FILIAL +RU7->RU7_ID) == xFilial("RU7",RJP->RJP_FILIAL) + cIdRU7
			cSeqRU7 := RU7->RU7_SEQ
			RU7->(DbSkip())
		EndDo
	EndIf

	cSeqRU7 := IIf( Empty(cSeqRU7), Strzero(1, GetSx3Cache("RU7_SEQ", "X3_TAMANHO")), SOMA1(cSeqRU7))

	If Reclock("RU7", .T.)
		RU7->RU7_FILIAL	:= RJP->RJP_FILIAL
		RU7->RU7_ID		:= cIdRU7    
		RU7->RU7_DTIN	:= dDtIn  
		RU7->RU7_HORAIN	:= cHoraIn
		RU7->RU7_SEQ	:= cSeqRU7
		RU7->RU7_MENS	:= cBody
		RU7->RU7_RTN	:= RJP->RJP_RTN
		If lRU7Atual
			RU7->RU7_CODRET := cRetCode
			RU7->RU7_SUCESS := IIf(lTudoOk, "S", "N")
		EndIf
		RU7->(MsUnlock())
	EndIf

	RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} function fComprJSn
Compacta os dados do retorno solicitado
@author  Marcio Felipe Martins
@since   22/04/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Function fComprJSn(oObj)
	Local cJson    := ""
	Local cComp    := ""
	Local lCompact := .F.
	
	// Set gzip format to Json Object
	cJson := FWJsonSerialize(oObj,.T.,.T.)

	If Type("::GetHeader('Accept-Encoding')") != "U"  .and. 'GZIP' $ Upper(::GetHeader('Accept-Encoding') )
		lCompact := .T.
	EndIf
	
	If(lCompact)
		::SetHeader('Content-Encoding','gzip')
		GzStrComp(cJson, @cComp, @nLenComp )
	Else
		cComp := cJson
	Endif

Return cComp

//-------------------------------------------------------------------
/*/{Protheus.doc} function FSubstJson
Substitui acentuação e caracteres especiais por caracteres aceitos
@author  Marcio Felipe Martins
@since   23/02/2024
@version 1.0
/*/
//-------------------------------------------------------------------
Function FSubstJson(cTexto)

	Local aAcentos	:= {}
	Local aAcSubst	:= {}
	Local nX		:= 0

	Default cTexto := ""

	If !Empty(cTexto)
		// Para alteracao/inclusao de caracteres, utilizar a fonte TERMINAL no IDE com o tamanho
		// maximo possivel para visualizacao dos mesmos.
		// Utilizar como referencia a tabela ASCII anexa a evidencia de teste (FNC 807/2009).
		aAcentos :=	{;
					Chr(199), Chr(231), Chr(196), Chr(197), Chr(224), Chr(229), Chr(225), Chr(228), Chr(170), Chr(201),; 
					Chr(234), Chr(233), Chr(237), Chr(244), Chr(246), Chr(242), Chr(243), Chr(186), Chr(250), Chr(097),; 
					Chr(098), Chr(099), Chr(100), Chr(101), Chr(102), Chr(103), Chr(104), Chr(105), Chr(106), Chr(107),;
					Chr(108), Chr(109), Chr(110), Chr(111), Chr(112), Chr(113), Chr(114), Chr(115), Chr(116), Chr(117),;
					Chr(118), Chr(120), Chr(122), Chr(119), Chr(121), Chr(065), Chr(066), Chr(067), Chr(068), Chr(069),;
					Chr(070), Chr(071), Chr(072), Chr(073), Chr(074), Chr(075), Chr(076), Chr(077), Chr(078), Chr(079),;
					Chr(080), Chr(081), Chr(082), Chr(083), Chr(084), Chr(085), Chr(086), Chr(088), Chr(090), Chr(087),;
					Chr(089), Chr(048),	Chr(049), Chr(050), Chr(051), Chr(052), Chr(053), Chr(054), Chr(055), Chr(056),;
					Chr(057), Chr(038), Chr(195), Chr(212), Chr(211), Chr(205), Chr(193), Chr(192), Chr(218), Chr(220),;
					Chr(213), Chr(245), Chr(227), Chr(252);
					}

		aAcSubst :=	{;
					"C", "c", "A", "A", "a", "a", "a", "a", "a",;
					"E", "e", "e", "i", "o", "o", "o", "o", "o",;
					"u", "a", "b", "c", "d", "e", "f", "g", "h",;
					"i", "j", "k", "l", "m", "n", "o", "p", "q",;
					"r", "s", "t", "u", "v", "x", "z", "w", "y",;
					"A", "B", "C", "D", "E", "F", "G", "H", "I",;
					"J", "K", "L", "M", "N", "O", "P", "Q", "R",;
					"S", "T", "U", "V", "X", "Z", "W", "Y", "0",;
					"1", "2", "3", "4", "5", "6", "7", "8", "9",;
					"E", "A", "O", "O", "I", "A", "A", "U", "U",;
					"O", "o", "a", "u";
					}

		For nX := 1 To Len(aAcSubst)
			cTexto := strTran(cTexto, aAcentos[nX], aAcSubst[nX])
		Next nX
	EndIf

Return cTexto

//-------------------------------------------------------------------
/*/{Protheus.doc} function fDtHrToJsn
Return JSON Date Format
@author  martins.marcio
@since   11/03/2024
@version 1.0
/*/
//-------------------------------------------------------------------
Function fDtHrToJsn(cDateX, cHoraX)
	Local cNewDate := ""

	DEFAULT cDateX := "20991231"
    DEFAULT cHoraX := "00:00:00"

	cNewDate := FwTimeStamp( 6, Stod(cDateX), cHoraX)

Return cNewDate
