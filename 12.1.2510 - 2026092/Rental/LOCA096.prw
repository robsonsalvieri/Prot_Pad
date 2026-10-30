#INCLUDE "PROTHEUS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "LOCA096.CH"

/*/{PROTHEUS.DOC} LOCA00185
ITUP BUSINESS - TOTVS RENTAL - Integração entre TAE e SIGALOC - CONSUMO DA CLASSE DE INTEGRAÇÃO
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 03/12/2024
/*/
Function LOCA096(cProjeto, cObra, cSeqDoc, cCodigo, cDoc, aDados, nPonteiro, cNomeFile, cUsuario, cSenha, nOpcao, cDescricao, cDir)
Local oTAE      := conTAE(cUsuario, cSenha)
Local oFile     := Nil
Local cFile     := ""
Local lUpload   := .F.
local oRequest  := Nil
Local cMsgErr   := ""
Local aDest     := {}
Local nIdEnv    := Nil // Id do envelope
Local cAssunto  := STR0001 //"Assinatura digital do documento "
Local cMsgTAE   := STR0002 //"Documentos do SIGALOC "
Local aObserv   := {}
Local cResponse := '' // retorno da chamada de uploadFile
Local lRet      := .T.
Local nX
Local cEmail
Local lArmazena := SuperGetMV("MV_MULTDIR",,.F.)

Private cPapel  := ""

	// Valida se o pacote foi baixado do TAE
	If !LOCA096V("FPB_IDTAE", "FPB")
		Return .F.
	EndIF

	If !oTae:AUTHSUCC
		MsgAlert(STR0017,STR0004) //"Erro na autenticação do usuário"###"Atenção!"
		Return .F.
	EndIf
    
    // aqui colocar se houver observador
	For nX:=1 to len(aDados)
		If aDados[nX,1]
			if aDados[nX,12] == "1"
				cEmail := ALLTRIM(aDados[nX,9])
				AADD(aObserv,ALLTRIM(cEmail))
			EndIf
		EndIF
	Next
	
    // Obter documento que será assinado
    If !oTAE:hasError()

        // email, nome, cpf, papel
		cPapel := "" // variavel private será populada no assinantes()
        aDest := assinantes(aDados, nOpcao)

        If Len(aDest) > 0
            cAssunto += cDescricao //cNomeFile
            cMsgTAE += alltrim(cProjeto)
            cFile := cNomeFile
            If !Empty(cFile) .AND. VALTYPE(cFile) == 'C'
                
                If !lArmazena
					cDir := alltrim(SuperGetMv("MV_LOCX313",,"/dirdoc/cot1/shared/"))
				Else
					cDir := alltrim(cdir)+"\"
				EndIF
				
				oFile := tecFOPEN(cDir+cFile)
                
                // Fazer upload do documento, usando o objeto TAE
                lUpload := oTAE:uploadFile(oFile, cNomeFile, cNomeFile, @oRequest, @cMsgErr)

                If lUpload
                    nIdEnv := oRequest:data
                    cDtExp := substr(dtos(dDataBase + 180),1,4)+"-"+substr(dtos(dDataBase + 180),5,2)+"-"+substr(dtos(dDataBase + 180),7,2)

					oTAE:publicar(nIdEnv,aDest,aObserv,cPapel,cDtExp,cAssunto,cMsgTAE,@cResponse)

                    If !oTae:hasError
						For nX := 1 to len(aDados)
							if aDados[nX,1]
								FPB->(dbGoto(aDados[nX,13]))
								FPB->(RecLock("FPB",.F.))
								FPB->FPB_DOC := cDoc
								FPB->FPB_DESDOC := cDescricao
								FPB->FPB_IDTAE := CVALTOCHAR(nIdEnv)
								FPB->FPB_DATAE := dDataBase
								FPB->FPB_HORAE := Time()
								FPB->FPB_STATUS := "2"
								FPB->(MsUnlock())
							EndIf
						Next
						lRet := .T. 
					EndIF
				Else
					lRet := .F.
                EndIf
            EndIf
        EndIf
    EndIf

return lRet

/*/{PROTHEUS.DOC} conTAE
ITUP BUSINESS - TOTVS RENTAL - Identificação do acesso usuário e senha
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 03/12/2024
/*/
Static Function conTAE(cUsuario, cSenha)
Local cUser     := SUPERGETMV('MV_USRTAE',,'') 
Local cPsWrd    := SUPERGETMV('MV_PWTAE',,'')
Local cBaseUrl  := SUPERGETMV('MV_TAEBASE',,"https://totvssign.staging.totvs.app")
Local oTAE      := TecTAE():New(cBaseUrl) 
    
	If !empty(cUsuario)
		cUSer := cUsuario
		cPsWrd := cSenha
	EndIf

    oTAE:defUser(cUser)
    oTAE:defPw(cPsWrd)
    oTAE:auth() 

Return oTAE

/*/{PROTHEUS.DOC} assinantes
ITUP BUSINESS - TOTVS RENTAL - Identificação dos assinantes
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 03/12/2024
aDados[nPonteiro,9], aDados[nPonteiro,8], aDados[nPonteiro,10], aDados[nPonteiro,11], aDados[nPonteiro,12], nOpcao
cEmail, cNome, cCpf, cPapel, cAprov
/*/
Static Function assinantes(aDados, nOpcao)
Local aDest := {}
Local cTipo := alltrim(str(nOpcao))
Local nX
Local cCpf

	For nX := 1 to len(aDados)
		If aDados[nX,1] .and. aDados[nX,12] $ "0" //23" // 0=Assinante, 2=Validador e 3=Testemunha
			If cTipo <> "3"
				cCpf := ALLTRIM(aDados[nX,10]) // cpf tem que ser válido
			Else
				cCpf := ""
			EndIF
			
			// cPapel foi criado como private
			If empty(cPapel)
				cPapel := alltrim(aDados[nX,11]) // Papel padrão para assinatura
			EndIF
			
			// e-mail, Nome, cpf
			AADD(aDest, { ALLTRIM(aDados[nX,9]), ALLTRIM(aDados[nX,8]), cCpf })
		EndIf
	Next

Return aDest

/*/{PROTHEUS.DOC} tecFOPEN
ITUP BUSINESS - TOTVS RENTAL - Transforma o arquivo no formato valido para a integracao
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 03/12/2024
/*/
Static Function tecFOPEN(cPath)
Local cBuffer := ""
Local cResult := ""
Local nHandle := 0
Local nBytes  := 0
Local cComando := "FOPEN(cPath)"

	nHandle := &(cComando)
	If nHandle > -1
		While (nBytes := FREAD(nHandle, @cBuffer, 524288)) > 0 
			cResult += cBuffer
		EndDo

		FCLOSE(nHandle)
	EndIf

Return cResult


/*/{PROTHEUS.DOC} LOCA00184
ITUP BUSINESS - TOTVS RENTAL - Valida se pode alterar a linha dos documentos
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 03/12/2024
/*/

Function LOCA00184(lDel)
Local lRet := .T.
Default lDel := .F.

	// Valida se o pacote foi baixado do TAE
	If !LOCA096V("FPB_IDTAE", "FPB")
		Return .T.
	EndIF

	If !lDel
		If !empty(ODLGDOC:ACOLS[ODLGDOC:NAT][ASCAN(ODLGDOC:AHEADER,{|X|ALLTRIM(X[2])=="FPB_DOC"})])
			lRet := .F.
		EndIf
	Else
		If empty(ODLGDOC:ACOLS[ODLGDOC:NAT][ASCAN(ODLGDOC:AHEADER,{|X|ALLTRIM(X[2])=="FPB_DOC"})])
			If ODLGDOC:ACOLS[ODLGDOC:NAT][len(ODLGDOC:AHEADER)+1]
				ODLGDOC:ACOLS[ODLGDOC:NAT][len(ODLGDOC:AHEADER)+1] := .F.
			Else
				ODLGDOC:ACOLS[ODLGDOC:NAT][len(ODLGDOC:AHEADER)+1] := .T.
			EndIf
		EndIf
		ODLGDOC:refresh()
	EndIf

Return lRet

/*/{PROTHEUS.DOC} LOCA00185
ITUP BUSINESS - TOTVS RENTAL - Assinatura digital
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 03/12/2024
/*/

Function LOCA00185()
Local lProc := .F.
Local aSize := MSADVSIZE()
Local oTela
Local cTitulo := STR0006 // "Ass.Digital"
Local cProjet := FP0->FP0_PROJET
Local cDoc := space(10)
Local oProjet
Local oDoc
Local oList
Local aDados := {}
Local oOk := LOADBITMAP( GETRESOURCES(), "LBOK")
Local oNo := LOADBITMAP( GETRESOURCES(), "LBNO")
Local lOk := .F.
Local oUsuario
Local cUsuario := space(60)
Local oSenha
Local cSenha := space(50)
Local nOpcao := 1
Local aOpcao := {}
Local oRadio
Local lRet := .T.

	// Valida se o pacote foi baixado do TAE
	If !LOCA096V("FPB_IDTAE", "FPB")
		Return .F.
	EndIF

	aadd( aOpcao, STR0033 ) //"Brasil" 
	aadd( aOpcao, STR0034 ) //"Exterior"
	aadd( aOpcao, STR0035 ) //"Não solicitar"

	FPB->(dbSetOrder(1))
	FPB->(dbSeek(xFilial("FPB")+FP0->FP0_PROJET))
	While !FPB->(Eof())
		If empty(FPB->FPB_DOC)
			lProc := .T.
			Exit
		EndIF
		FPB->(dbSkip())
	EndDo
	
	If lProc

		DEFINE MSDIALOG OTELA FROM 0, 0 TO ASIZE[6],ASIZE[5] TITLE CTITULO OF GETWNDDEFAULT() PIXEL
		
		@ 35,005 SAY OEMTOANSI(SUPERGETMV("MV_LOCX248",.F.,STR0005)+":") SIZE 050,8 OF OTELA PIXEL //"PROJETO"
		@ 33,030 MSGET OPROJET VAR CPROJET WHEN .F. SIZE 50,8 OF OTELA PIXEL 
		@ 35,100 SAY OEMTOANSI(STR0007) SIZE 080,8 OF OTELA PIXEL //"Documento:"
		@ 33,135 MSGET oDoc VAR cDoc F3 "LOCAC9" SIZE 60,8 OF OTELA PIXEL 
		@ 35,215 SAY OEMTOANSI(STR0030) SIZE 080,8 OF OTELA PIXEL //"Login:"
		@ 33,235 MSGET oUsuario VAR cUsuario SIZE 120,8 OF OTELA PIXEL 
		@ 35,374 SAY OEMTOANSI(STR0031) SIZE 080,8 OF OTELA PIXEL //"Senha:"
		@ 33,397 MSGET oSenha VAR cSenha PASSWORD SIZE 60,8 OF OTELA PIXEL 
		@ 35,470 SAY OEMTOANSI(STR0032) SIZE 080,8 OF OTELA PIXEL //"Idendificação:"

		oRadio:= tRadMenu():New(35,510,aOpcao,{|u| iif(PCount()==0, nOpcao, nOpcao:=u)},oTela,,,,,,,,60,15,,,,.T.)
		
		@ 70,005 LISTBOX OLIST FIELDS HEADER "",;
		FWX3Titulo("FPB_OBRA"),;
		FWX3Titulo("FPB_SEQDOC"),;
		FWX3Titulo("FPB_CODIGO"),;
		FWX3Titulo("FPB_DESCR"),;
		FWX3Titulo("FPB_TPDOC"),;
		FWX3Titulo("FPB_DESCRI"),;
		FWX3Titulo("FPB_NOME"),;
		FWX3Titulo("FPB_EMAIL"),;
		FWX3Titulo("FPB_CPF"),;
		FWX3Titulo("FPB_DFUNCA"),;
		FWX3Titulo("FPB_APROV"),;
		"Controle","Tipo" PIXEL SIZE ASIZE[3]-5, ASIZE[4]-90 ON DBLCLICK ( FSELECIONA(aDados, oList:nAt) ) OF oTela

		Processa({|| aDados := LOCA00190()},STR0008) //"Aguarde... Montando o ambiente."

		If len(aDados) == 0
			MsgAlert(STR0039,STR0004) //"Não existem documentos para o envio."###"Atenção!"
			Return .F.
		EndIf

		oList:SETARRAY( aDados )
		oList:BLINE := {|| { IF( aDados[oList:nAt,01],OOK,ONO),;
							 aDados[oList:nAt,02],;
							 aDados[oList:nAt,03],;
							 aDados[oList:nAt,04],;
							 aDados[oList:nAt,05],;
							 aDados[oList:nAt,06],;
							 aDados[oList:nAt,07],;
							 aDados[oList:nAt,08],;
							 aDados[oList:nAt,09],;
							 aDados[oList:nAt,10],;
							 aDados[oList:nAt,11],;
							 aDados[oList:nAt,12],;
							 aDados[oList:nAt,13],;
							 aDados[oList:nAt,14]}}

		ACTIVATE MSDIALOG OTELA CENTERED ON INIT ENCHOICEBAR(OTELA ,{|| IF(VALDOCX(aDados, cDoc),(LOK:=.T., OTELA:END()),.F.) } , {|| OTELA:END()} , , )
	Else
		MsgAlert(STR0009,STR0004) //"Não foram localizados documentos para o envio."###"Atenção!"
	EndIF

	If lOk
		Processa({|| lRet := LOCA001D2(aDados, cDoc, cUsuario, cSenha, nOpcao  )},STR0010) //"Enviando os documentos ao TAE."
		If lRet 
			MsgAlert(STR0018,STR0004) //"Registros processados com sucesso."###"Atenção!"
		Else
			MsgAlert(STR0019,STR0004) //"Houve uma falha na integração com o TAE."###"Atenção!"
		EndIF
	EndIf

Return 


/*/{PROTHEUS.DOC} LOCA001D2
ITUP BUSINESS - TOTVS RENTAL - Assinatura digital - envio dos documentos ao TAE
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 03/12/2024
/*/

Function LOCA001D2(aDados, cDoc, cUsuario, cSenha, nOpcao)
Local nX
Local lRetorno := .T.

	// Valida se o pacote foi baixado do TAE
	If !LOCA096V("FPB_IDTAE", "FPB")
		Return .F.
	EndIF
	
	ProcRegua(0)
	For nX := 1 to len(aDados)
		IncProc()
		SysRefresh()
		If aDados[nX,1]
			ACB->(dbSetOrder(1))
			ACB->(dbSeek(xFilial("ACB")+cDoc))
			// Projeto, Obra, SeqDoc, Código, Documento
			lRet := LOCA096(FP0->FP0_PROJET, aDados[nX,2], aDados[nX,3], aDados[nX,4], cDoc, aDados, nX, alltrim(ACB->ACB_OBJETO), cUsuario, cSenha, nOpcao, alltrim(ACB->ACB_DESCRI), ACB->ACB_PATH )
			If !lRet
				lRetorno := .F.
			EndIF
			Exit
		EndIF
	Next

Return lRetorno

/*/{PROTHEUS.DOC} VALDOCX
ITUP BUSINESS - TOTVS RENTAL - Assinatura digital - Valida e gera a integracao com o TAE
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 03/12/2024
/*/

Static Function VALDOCX(aDados, cDoc)
Local nX
Local lMarca := .F.
Local lRet := .T.
Local lNome := .T.
Local lPdf := .F.
Local lAssina := .F.
Local lConflito := .F.
Local aEmail := {}
Local cEmail := ""
Local nY
Local lExist

	If !MsgYesNo(STR0011,STR0004) //"Confirma o envio para o TAE?"###"Atenção!"
		Return .F.
	EndIf

	If empty(cDoc)
		MsgAlert(STR0012,STR0004) //"Nenhum documento foi selecionado."###"Atenção!"
		lRet := .F.
	EndIF

	ACB->(dbSetOrder(1))
	ACB->(dbSeek(xFilial("ACB")+cDoc))
	If ACB->(!eof())
		If upper(substr(ACB->ACB_OBJETO,AT(".",ACB->ACB_OBJETO)+1,3)) == "PDF" .or. upper(substr(ACB->ACB_OBJETO,AT(".",ACB->ACB_OBJETO)+1,3)) == "DOC"
			lPdf := .T.
		EndIF
	EndIF

	If !lPdf
		lRet := .F.
		MsgAlert(STR0013, STR0004) // "O documento precisa estar no formato PDF, DOC, ou DOCX"###"Atenção!"
	EndIF

	If lRet
		For nX := 1 to len(aDados)
			If aDados[nX,1]
				lMarca := .T.
				If aDados[nX,12] $ "0" //23" //0=assinante, 2=validador e 3=testemunha
					lAssina := .T.
				EndIF
			EndIF
		Next
		For nX := 1 to len(aDados)
			If aDados[nX,1]
				lMarca := .T.
				If empty(aDados[nX,12])
					lAssina := .F.
				EndIF
			EndIF
		Next

		If !lAssina
			MsgAlert(STR0020,STR0004) //"Não foi indicado nenhum assinante para a aprovação."###"Atenção!"
			Return .F.
		EndIF
	EndIF

	aEmail := {}
	cEmail := ""
	For nX:= 1 to len(aDados)
		If aDados[nX,1]
			cEmail := aDados[nX,9]		
			lExist := .F.
			For nY := 1 to len(aEmail)
				If aEmail[nY] == cEmail
					lConflito := .T.
					lExist := .T.
				EndIf
			Next
			If !lExist
				aadd(aEmail,cEmail)
			EndIF
		EndIf
	Next
	If lConflito
		MsgAlert(STR0021,STR0004) //"No mesmo pacote de aprovação não pode haver e-mails duplicados."###"Atenção!"
		Return .F.
	EndIF

	If lRet
		For nX := 1 to len(aDados)
			If aDados[nX,1]
				lMarca := .T.
				If empty(aDados[nX,8]) .or. empty(aDados[nX,9]) .or. empty(aDados[nX,10])
					lRet := .F.
					lNome := .F.
				EndIF
			EndIF
		Next
		If !lMarca
			//MsgAlert(STR0014,STR0004) //"Nenhum documento foi selecionado."###"Atenção!"
			//lRet := .F.
		Else
			If !lNome
				MsgAlert(STR0015,STR0004) //"O nome, e-mail e CPF são obrigatórios."###"Atenção!"
			EndIF
		EndIF
	EndIF

Return lRet



/*/{PROTHEUS.DOC} FSELECIONA
ITUP BUSINESS - TOTVS RENTAL - Assinatura digital - montando o ambiente
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 03/12/2024
/*/

Static Function FSELECIONA(aDados, nAt)
Local nX
Local cCodigo := ""
//Local cEmail := ""
//Local lErroEmail := .F.
//Local nY

	If aDados[nAt,01]
		aDados[nAt,01] := .F.
	Else
		For nX:=1 to len(aDados)
			If aDados[nX,01]
				cCodigo := aDados[nX,04]
			EndIf
		Next
		If (empty(cCodigo) .or. aDados[nAt,04] == cCodigo) 
			aDados[nAt,01] := .T.
		Else
			aDados[nAt,01] := .F.
			MsgAlert(STR0016,STR0004) //"Não pode ser selecionado documentos com códigos."###"Atenção!"
		EndIF
	
	EndIF

Return 


/*/{PROTHEUS.DOC} LOCA00190
ITUP BUSINESS - TOTVS RENTAL - Assinatura digital - montando o ambiente
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 03/12/2024
/*/

Function LOCA00190()
Local aTemp := {}
Local cTipo
	
	ProcRegua(0)
	FPB->(dbSetOrder(1))
	FPB->(dbSeek(xFilial("FPB")+FP0->FP0_PROJET))
	While !FPB->(Eof()) .and. FPB->FPB_FILIAL == xFilial("FPB") .and. FPB->FPB_PROJET == FP0->FP0_PROJET
		If empty(FPB->FPB_DOC)
			cTipo := ""
			If FPB->FPB_APROV=="0"
				cTipo := STR0037 // Assinante
			ElseIf FPB->FPB_APROV=="1"
				cTipo := STR0038 // Observador
			//ElseIf FPB->FPB_APROV=="2"
			//	cTipo := "Validador"
			//ElseIf FPB->FPB_APROV=="3"
			//	cTipo := "Testemunha"
			EndIf

			aadd(aTemp,{ .F.,;
			FPB->FPB_OBRA,;
			FPB->FPB_SEQDOC,;
			FPB->FPB_CODIGO,;
			FPB->FPB_DESCR,;
			FPB->FPB_TPDOC,;
			FPB->FPB_DESCRI,;
			FPB->FPB_NOME,;
			FPB->FPB_EMAIL,;
			FPB->FPB_CPF,;
			FPB->FPB_DFUNCA,; 
			FPB->FPB_APROV,;
			FPB->(Recno()),;
			cTipo}) 
		EndIf
		FPB->(dbSkip())
		IncProc()
	EndDo

Return aTemp

/*/{PROTHEUS.DOC} LOCA001D1
ITUP BUSINESS - TOTVS RENTAL - Assinatura digital - filtro da consulta padrão LOCAAC9
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 03/12/2024
/*/

Function LOCA001D1()
Local lRet := .T.

	If AC9->AC9_FILIAL <> xFilial("AC9")
		lRet := .F.
	EndIf
	If AC9->AC9_CODENT <> xFilial("FP0")+FP0->FP0_PROJET
		lRet := .F.
	EndIf
	FPB->(dbSetOrder(2))
	If FPB->(dbSeek(xFilial("FPB")+AC9->AC9_CODOBJ))
		lRet := .F.
	EndIF
	FPB->(dbSetOrder(1))
	
Return lRet

/*/{PROTHEUS.DOC} LOCA001D4
ITUP BUSINESS - TOTVS RENTAL - Assinatura digital - cancelamento da publicacao
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 03/12/2024
/*/

Function LOCA001D4()
//Local oTAE := conTAE()
Local lRet := .F.
Local cTitulo := STR0036 //"Cancelamento de documentos no TAE"
Local lOk := .F.
Local oUsuario
Local cUsuario := space(60)
Local oSenha
Local cSenha := space(50)

	// Valida se o pacote foi baixado do TAE
	If !LOCA096V("FPB_IDTAE", "FPB")
		Return .F.
	EndIF
    
	If empty(ODLGDOC:ACOLS[ODLGDOC:NAT][ASCAN(ODLGDOC:AHEADER,{|X|ALLTRIM(X[2])=="FPB_IDTAE"})])
		MsgAlert(STR0022,STR0004) //"O documento ainda não foi enviado ao TAE"###"Atenção!"
		Return .F.
	EndIf

	If ODLGDOC:ACOLS[ODLGDOC:NAT][ASCAN(ODLGDOC:AHEADER,{|X|ALLTRIM(X[2])=="FPB_STATUS"})] <> "2"
		MsgAlert(STR0023,STR0004) //"O status do documento não permite o cancelamento no TAE"###"Atenção!"
		Return .F.
	EndIF

	DEFINE MSDIALOG oTela FROM 0, 0 TO 300,700 TITLE cTitulo OF GETWNDDEFAULT() PIXEL
		
		@ 35,005 SAY OEMTOANSI(STR0030) SIZE 080,8 OF OTELA PIXEL //"Login:"
		@ 33,025 MSGET oUsuario VAR cUsuario SIZE 120,8 OF OTELA PIXEL 
		@ 35,155 SAY OEMTOANSI(STR0031) SIZE 080,8 OF OTELA PIXEL //"Senha:"
		@ 33,180 MSGET oSenha VAR cSenha PASSWORD SIZE 60,8 OF OTELA PIXEL 

	ACTIVATE MSDIALOG OTELA CENTERED ON INIT ENCHOICEBAR(OTELA ,{|| IF(MsgYesNo(STR0027,STR0004),(LOK:=.T., OTELA:END()),.F.) } , {|| OTELA:END()} , , ) //"Confirma o cancelamento?"###"Atenção!"

	If lOk
		Processa({|| lRet := LOCA001D5(cUsuario,cSenha)},STR0028) //"Aguarde... Cancelando o documento no TAE"
	EndIF

Return lRet

/*/{PROTHEUS.DOC} LOCA001D5
ITUP BUSINESS - TOTVS RENTAL - Assinatura digital - cancelamento da publicacao
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 03/12/2024
/*/

Function LOCA001D5(cUsuario, cSenha)
Local lRet := .F.
Local oTae
Local cIdDoc := ODLGDOC:ACOLS[ODLGDOC:NAT][ASCAN(ODLGDOC:AHEADER,{|X|ALLTRIM(X[2])=="FPB_IDTAE"})]
Local cProjeto
Local nX

	ProcRegua(0)
	IncProc()
	oTAE := conTAE(cUsuario, cSenha)

	If !oTae:AUTHSUCC
		MsgAlert(STR0024,STR0004) //"Erro na autenticação do usuário"###"Atenção!"
		Return .F.
	EndIf
    
    lRet := oTAE:pubCancel(val(cidDoc))

	If lRet

		IncProc()
		SysRefresh()
		
		For nX := 1 to len(ODLGDOC:ACOLS)
			If ODLGDOC:ACOLS[nX][ASCAN(ODLGDOC:AHEADER,{|X|ALLTRIM(X[2])=="FPB_IDTAE"})] == cIdDoc
				ODLGDOC:ACOLS[nX][ASCAN(ODLGDOC:AHEADER,{|X|ALLTRIM(X[2])=="FPB_STATUS"})] := "5"
			EndIf
		Next

		cProjeto := FP0->FP0_PROJET
		
		FPB->(dbSetOrder(1))
		FPB->(dbSeek(xFilial("FPB")+cProjeto))
		While !FPB->(Eof()) .and. FPB->(FPB_FILIAL+FPB_PROJET) == xFilial("FPB")+cProjeto
			If FPB->FPB_IDTAE == cIdDoc
				FPB->(RecLock("FPB",.F.))
				FPB->FPB_STATUS := "5"
				FPB->(MsUnlock())
			EndIF
			FPB->(dbSkip())
		EndDo
		MsgAlert(STR0025,STR0004) //"Documento cancelado com sucesso no TAE"###"Atenção!"
	Else
		MsgAlert(STR0026,STR0004) //"Não foi possível cancelar o documento no TAE"###"Atenção!"
	EndIF

Return lRet


/*/{PROTHEUS.DOC} LOCA001D6
ITUP BUSINESS - TOTVS RENTAL - Assinatura digital - verifica o status no TAE
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 03/12/2024
/*/

Function LOCA001D6(cProjeto)
Local lRet := .T.
Local lLoga := .F.

	If !LOCA096V("FPB_IDTAE", "FPB")
		Return .F.
	EndIF

	FPB->(dbSetOrder(1))
	FPB->(dbSeek(xFilial("FPB")+cProjeto))
	While !FPB->(Eof()) .and. FPB->(FPB_FILIAL+FPB_PROJET) == xFilial("FPB")+cProjeto
		If !empty(FPB->FPB_IDTAE)
			lLoga := .T.
			Exit
		EndIF
		FPB->(dbSkip())
	EndDo

	If lLoga

		Processa({|| lRet := LOCA001D7(cProjeto)},STR0029) //"Validando o status dos documentos no TAE."

	EndIF
    
Return lRet


/*/{PROTHEUS.DOC} LOCA001D7
ITUP BUSINESS - TOTVS RENTAL - Assinatura digital - verifica o status no TAE
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 03/12/2024

1 = pendente
2 = finalizado
5 = cancelado

/*/

Function LOCA001D7(cProjeto,lJob)
Local oTAE
Local lRet := .T.
Local cStatus := ""
Local aAreaFPB := FPB->(GetArea())

Default lJob := .F.

	If !lJob
		ProcRegua(0)
	EndIf
	
	oTAE := conTAE()
	If !lJob
		IncProc()
		SysRefresh()
	EndIf
	If oTae:AUTHSUCC
		FPB->(dbSeek(xFilial("FPB")+cProjeto))
		While !FPB->(Eof()) .and. FPB->(FPB_FILIAL+FPB_PROJET) == xFilial("FPB")+cProjeto
			If !lJob
				IncProc()
				SysRefresh()
			EndIf
			If !empty(FPB->FPB_IDTAE)	
				cStatus := oTAE:detailPub(val(FPB->FPB_IDTAE))
				cStatus := alltrim(str(cStatus))
				FPB->(Reclock("FPB"),.F.)
				If cStatus == "1"
					FPB->FPB_STATUS := "2" // Pendente
				ElseIf cStatus == "2"
					FPB->FPB_STATUS := "6" // Finalizado
				ElseIf cStatus == "7" .or. cStatus == "5"
					FPB->FPB_STATUS := "5" // Cancelado
				ElseIf cStatus == "4" // Recusado
					FPB->FPB_STATUS := "4"
				EndIF
				FPB->(MsUnlock())
			EndIF
			FPB->(dbSkip())
		EndDo
	EndIF
	FPB->(RestArea(aAreaFPB))

Return lRet


/*/{PROTHEUS.DOC} LOCA001D8
ITUP BUSINESS - TOTVS RENTAL - Assinatura digital - verifica o status no TAE - Job
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 03/12/2024
/*/

Function LOCA001D8()
Local cProjeto
Local aProc := {}
Local nX
Local lProc

	// Valida se o pacote foi baixado do TAE
	If !LOCA096V("FPB_IDTAE", "FPB")
		Return .F.
	EndIF

	FPB->(dbSeek(xFilial("FPB")))
	While !FPB->(Eof()) .and. FPB->FPB_FILIAL == xFilial("FPB")
		If !empty(FPB->FPB_IDTAE)
			cProjeto := FPB->FPB_PROJET
			lProc := .T.
			For nX := 1 to len(aProc)
				If aProc[nX,1] == cProjeto
					lProc := .F.
					Exit
				EndIf
			Next
			If lProc 
				aadd(aProc,{cProjeto})
				LOCA001D7(cProjeto,.T.)
			EndIf
		EndIf		
		FPB->(dbSkip())
	EndDo
Return
 

/*/{PROTHEUS.DOC} LOCA224B1
ITUP BUSINESS - TOTVS RENTAL
VALIDA SE UM CAMPO EXISTE NO SX3
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 15/05/2024
/*/

Static Function LOCA096V(cCampo, cAlias)
Local a1Struct 
Local nP
Local lRet := .F.
    If !empty(cCampo) .and. !empty(cAlias)
        a1Struct := FWSX3Util():GetListFieldsStruct( cAlias, .F.)
        For nP := 1 to len(a1Struct)
            If upper(alltrim(a1Struct[nP][01])) == upper(alltrim(cCampo))
                lRet := .T.
                exit
            EndIf
        Next
    EndIF
Return lRet 



