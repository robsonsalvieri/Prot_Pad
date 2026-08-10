#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PARMTYPE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA314()
Controle de Fila para envio de comunicação do LegalData

@author Willian Kazahaya
@since 31/10/2023
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA314()
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J314ProcMdl(oModel)
Controle de Fila para envio de comunicação do LegalData

@param oModel - Modelo alterado

@author Willian Kazahaya
@since 31/10/2023
@version 1.0
/*/
//-------------------------------------------------------------------
Function J314ProcMdl(oModel)
Local cFilNSZ   := xFilial("NSZ")
Local cCajuri   := oModel:GetValue("NSZMASTER", "NSZ_COD")
Local oMdlInsta := oModel:GetModel("NUQDETAIL")
Local cTpOper   := ""
Local lRet      := .F.
Local nI        := 0
Local cTipoRec  := JGetParTpa(oModel:GetValue("NSZMASTER", "NSZ_TIPOAS"), "MV_JTPANAU", "1") // Tipo de recebimento de andamento automático (1=Por processo, 2=Por instância)

	For nI := 1 To oMdlInsta:Length()
		oMdlInsta:GoLine(nI)
		cTpOper := ""

		// Se for inclusão de processo
		If oModel:GetOperation() == MODEL_OPERATION_INSERT .And. cTipoRec == "1"
			cTpOper := "1"

		// Se a AndAut foi alterada 
		ElseIf (oMdlInsta:IsFieldUpdated("NUQ_ANDAUT") .And. oMdlInsta:GetValue("NUQ_ANDAUT") != "3" .And.  oModel:GetValue("NSZMASTER", "NSZ_SITUAC") == "1")
			cTpOper := oMdlInsta:GetValue("NUQ_ANDAUT")

		// Se a Instância foi excluida
		ElseIf (oMdlInsta:IsDeleted() .OR. oModel:GetOperation() == MODEL_OPERATION_DELETE)
			cTpOper := "2"

		// Se o processo foi encerrado
		ElseIf (oModel:IsFieldUpdated("NSZMASTER", "NSZ_SITUAC") .And. oModel:GetValue("NSZMASTER", "NSZ_SITUAC") == "2")
			If JGetParTpa(oModel:GetValue("NSZMASTER", "NSZ_TIPOAS"), "MV_JANDEXC", "1") == "1"
				cTpOper := "2"
			Else
				// Atualiza quando foi alterado manualmente para o Andamento Automatico
				If oMdlInsta:IsFieldUpdated("NUQ_ANDAUT") .And. oMdlInsta:GetValue("NUQ_ANDAUT") == "1"
					cTpOper := "1"
				EndIf
			EndIf
		EndIf

		If (!Empty(cTpOper))
			J314IncFlLD(cFilNSZ, cCajuri, oMdlInsta:GetValue("NUQ_COD"), cTpOper)
		EndIf
	Next nI
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J314FilaLD()
Inclui o registro na Fila do LegalData

@author Willian Kazahaya
@since 31/10/2023
@version 1.0
/*/
//-------------------------------------------------------------------
Function J314IncFlLD(cFilNSZ, cCajuri, cCodInsta, cTpOper)
Local cArea := GetArea()
Local lRet := .T.

	DbSelectArea("O1H")
	RecLock("O1H", .T.) // .F. Alterar .T. Cadastrar

	O1H->O1H_FILIAL = cFilNSZ
	O1H->O1H_COD    = GetSxeNum("O1H","O1H_COD")
	O1H->O1H_CAJURI = cCajuri
	O1H->O1H_CINSTA = cCodInsta
	O1H->O1H_STATUS = '1'
	O1H->O1H_OPERAC = cTpOper
	O1H->O1H_DTINCL = Date()
	O1H->O1H_HRINCL = Time()
	O1H->( MsUnLock() )

	If __lSX8
		ConFirmSX8()
		lOk := .T.
	EndIf

	RestArea(cArea)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J314FilaLD()
Executa a fila de itens do LegalData

@author Willian Kazahaya
@since 31/10/2023
@version 1.0
/*/
//-------------------------------------------------------------------
Function J314ExFlLD()
Local cQry        := JQryFilaLD()
Local cAlsO1H     := ""
Local cComarca    := ""
Local cTribunal   := ""
Local cRetService := ""
Local cStsAndAut  := "1"
Local lVldCNJ     := .F.
Local lRet        := .F.

	cAlsO1H := GetNextAlias()
	DbUseArea( .T., "TOPCONN", TCGenQry2(,,cQry, {}), cAlsO1H, .F., .F. )
	
	While ( (cAlsO1H)->(!Eof()) )
		cStsAndAut := "1"

		// Valida CNJ
		lVldCNJ :=  J183VldCnj((cAlsO1H)->NSZ_TIPOAS, (cAlsO1H)->NUQ_CNATUR)
		If (lVldCNJ)
			cComarca  := (cAlsO1H)->NUQ_CCOMAR
			cTribunal := (cAlsO1H)->NUQ_CLOC2N
		Else 
			cComarca  := ""
			cTribunal := ""
		EndIf

		// Se a operação for inclusão
		If ((cAlsO1H)->O1H_OPERAC == "1")
			If !J223CadPro((cAlsO1H)->NUQ_NUMPRO, ;
						   (cAlsO1H)->NUQ_ESTADO, ;
						   cComarca, ;
						   , ;
						   cTribunal, ;
						   lVldCNJ, ;
						   @cRetService)
				cStsAndAut := "3"
			EndIf
		Else
			// Se a operação for exclusão
			If J223ExcPro((cAlsO1H)->NUQ_NUMPRO, lVldCNJ)
				cStsAndAut := "2"
			EndIf
		EndIf

		// Realizando a atualização irá atualizar a instância e a fila
		If (!Empty(cStsAndAut))
			JUpdInsta((cAlsO1H)->O1H_FILIAL, (cAlsO1H)->O1H_CAJURI, (cAlsO1H)->O1H_CINSTA, cStsAndAut)
			JUpdFilaLD((cAlsO1H)->O1H_FILIAL, (cAlsO1H)->O1H_COD, cRetService)
		EndIf

		(cAlsO1H)->(DbSkip())
	EndDo
	(cAlsO1H)->(dbCloseArea())
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JUpdInsta(cFilNsz, cCajuri, cCodInsta, cAndAutSts)
Atualiza a Instância com o Status do Andamento Automatico

@param cFilNsz    - Filial da NSZ
@param cCajuri    - Código do Assunto Jurídico
@param cCodInsta  - Código da Instância
@param cAndAutSts - Status do Andamento Automatico

@author Willian Kazahaya
@since 06/11/2023
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JUpdInsta(cFilNsz, cCajuri, cCodInsta, cAndAutSts)
Local cArea := GetArea()
Local lRet  := .T.

	DbSelectarea("NUQ")
	NUQ->( DbSetOrder(5) ) // NUQ_FILIAL+NUQ_CAJURI+NUQ_COD 
	lRet := NUQ->( DbSeek( cFilNsz + cCajuri + cCodInsta ) )

	If (lRet)
		RecLock("NUQ", .F.)
		NUQ->NUQ_ANDAUT = cAndAutSts
		NUQ->( MsUnLock() )
	EndIf
	RestArea( cArea )
Return lRet 

//-------------------------------------------------------------------
/*/{Protheus.doc} JUpdFilaLD(cFilFila, cCodFila, cRetWS)
Atualiza a fila

@param cFilFila   - Filial da Fila
@param cCodFila   - Código da Fila
@param cRetWS     - Retorno do Webservice

@author Willian Kazahaya
@since 06/11/2023
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JUpdFilaLD(cFilFila, cCodFila, cRetWS)
Local cArea := GetArea()
Local lRet  := .T.

	DbSelectArea("O1H")
	O1H->( DbSetOrder(1) )
	lRet := O1H->( DbSeek( cFilFila + cCodFila) )

	If (lRet)
		RecLock("O1H", .F.)
		O1H->O1H_STATUS := "2"
		O1H->O1H_DTPROC := Date()
		O1H->O1H_HRPROC := Time()
		O1H->O1H_RETORN := AllTrim(cRetWS)
		O1H->( MsUnLock() )
	EndIf

	RestArea( cArea )
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JQryFilaLD()
Query de Busca dos itens da Fila do LD

@author Willian Kazahaya
@since 06/11/2023
@version 1.0'
/*/
//-------------------------------------------------------------------
Static Function JQryFilaLD()
Local cQuery := ""
	// 
	cQuery := " SELECT O1H.O1H_FILIAL,"
	cQuery +=        " O1H.O1H_COD,"
	cQuery +=        " O1H.O1H_CAJURI,"
	cQuery +=        " O1H.O1H_OPERAC,"
	cQuery +=        " O1H.O1H_CINSTA,"
	cQuery +=        " NSZ.NSZ_TIPOAS,"
	cQuery +=        " NUQ.NUQ_CNATUR,"
	cQuery +=        " NUQ.NUQ_NUMPRO,"
	cQuery +=        " NUQ.NUQ_ESTADO,"
	cQuery +=        " NUQ.NUQ_CCOMAR,"
	cQuery +=        " NUQ.NUQ_CLOC2N,"
	cQuery +=        " NUQ.NUQ_ANDAUT"
	cQuery +=   " FROM " + RetSqlName("O1H") + " O1H"
	cQuery +=  " INNER JOIN " + RetSqlName("NSZ") + " NSZ"
	cQuery +=     " ON (NSZ.NSZ_FILIAL = O1H.O1H_FILIAL" 
	cQuery +=    " AND NSZ.NSZ_COD = O1H.O1H_CAJURI"
	cQuery +=    " AND NSZ.D_E_L_E_T_ = ' ')"
	cQuery +=  " INNER JOIN " + RetSqlName("NUQ") + " NUQ"
	cQuery +=     " ON (NUQ.NUQ_FILIAL = NSZ.NSZ_FILIAL"
	cQuery +=    " AND NUQ.NUQ_CAJURI = NSZ.NSZ_COD"
	cQuery +=    " AND NUQ.NUQ_COD = O1H.O1H_CINSTA)"
	cQuery +=  " WHERE O1H.O1H_STATUS = '1'"
	cQuery +=  " ORDER BY O1H.O1H_FILIAL,"
	cQuery +=           " O1H.O1H_CAJURI,"
	cQuery +=           " O1H.O1H_DTINCL,"
	cQuery +=           " O1H.O1H_HRINCL"
Return cQuery
