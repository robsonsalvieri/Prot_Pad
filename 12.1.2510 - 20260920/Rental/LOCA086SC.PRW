#INCLUDE "PROTHEUS.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPRINTSETUP.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "LOCA086SC.CH"

/*/{Protheus.doc} LOCA086SC
Processamento em schedule do reajuste de contratos
@type function
@version v1 
@author Frank Zwarg Fuga
@since 07/01/2026
/*/
Function LOCA086SC
Local aExecAuto := {}
Local aFil1 := {}
Local aAreaFP0
Local aAreaFPA  // Salva posicao do FPA antes de chamar LOCA086
Local cProjeto  := "" // Guarda codigo do projeto para evitar leitura de FP0 apos reposicionamento

Private LMSERROAUTO := .T.
        
    // SX1 correspondente para o schedule - LOCP078
    If MV_PAR01 == 1 // reajuste - atualização

        FP0->(dbSetOrder(1))
        FP0->(dbSeek(xFilial("FP0")))
        While !FP0->(Eof()) .and. FP0->FP0_FILIAL == xFilial("FP0")

            If FP0->FP0_PROJET >= MV_PAR02 .and. FP0->FP0_PROJET <= MV_PAR03
                
                aAreaFP0 := FP0->(GetArea())
                // Guarda o codigo do projeto ANTES de qualquer reposicionamento interno
                cProjeto := FP0->FP0_PROJET

                FPA->(dbSetOrder(1))
                FPA->(dbSeek(xFilial("FPA")+cProjeto))

                // Usa cProjeto (variavel local) pois FP0 pode ser reposicionado dentro de LOCA086
                While !FPA->(Eof()) .and. FPA->FPA_FILIAL == xFilial("FPA") .and. FPA->FPA_PROJET == cProjeto

                    If FPA->FPA_OBRA >= MV_PAR15 .and. FPA->FPA_OBRA <= MV_PAR16

                        aExecAuto := {}
                        aFil1 := {}

                        aadd(aExecAuto,1) // Atualizacao
                        aadd(aExecAuto,cProjeto) // Projeto de
                        aadd(aExecAuto,cProjeto) // Projeto at
                        aadd(aExecAuto,MV_PAR04) // Data de
                        aadd(aExecAuto,MV_PAR05) // Data até
                        aadd(aExecAuto,MV_PAR06) // Bem de
                        aadd(aExecAuto,MV_PAR07) // Bem até
                        aadd(aExecAuto,MV_PAR08) // Indice de reajuste
                        aadd(aExecAuto,MV_PAR09) // Cliente de
                        aadd(aExecAuto,MV_PAR10) // Loja de
                        aadd(aExecAuto,MV_PAR11) // Cliente até
                        aadd(aExecAuto,MV_PAR12) // Loja até
                        aadd(aExecAuto,MV_PAR13) // Produto de
                        aadd(aExecAuto,MV_PAR14) // Produto até
                        aadd(aExecAuto,FPA->FPA_OBRA) // Localidade de
                        aadd(aExecAuto,FPA->FPA_OBRA) // Localidade até
                        aadd(aExecAuto,MV_PAR17) // aniversario de
                        aadd(aExecAuto,MV_PAR18) // aniversario até
                        aadd(aExecAuto,MV_PAR19) // atualiza aniversario
                        aadd(aExecAuto,MV_PAR20) // fator de reajuste
                        aadd(aExecAuto,MV_PAR21) // calcular automatico
                        aadd(aExecAuto,2) // reajusta medição

                        aadd(aFil1,FPA->FPA_SEQGRU) // identificacao da sequencia
                        aadd(aFil1,.F.)   // atualiza os titulos provisorios, não se esquecer do parametro "MV_LOCX278"
                        aadd(aFil1,"") // observacao
                        aadd(aFil1,FPA->FPA_DTENRE) // Dt.Fim.Locação
                        aadd(aFil1,FPA->FPA_NIVER) // Dt.Aniversario reajuste

                        // Salva e restaura posicao do FPA pois LOCA086 reposiciona o cursor internamente
                        aAreaFPA := FPA->(GetArea())
                        LOCA086(aExecAuto, aFil1)
                        FPA->(RestArea(aAreaFPA))

                    EndIf

                    FPA->(dbSkip())
                
                EndDo

            EndIf

            //FP0->(RestArea(aAreaFP0))
            FP0->(dbSkip())
        EndDo
    
    Endif

Return

/*/{Protheus.doc} SchedDef
Execucao da rotina via Schedule
@type function
@version v1
@author Frank Zwarg Fuga
@since 07/01/2026
@return variant, return_description
/*/
Static Function SchedDef()
Local aParam := {}

	aParam := 	{"P"	,;	//Tipo R para relatorio P para processo
				"LOCP078",;	//Nome do grupo de perguntas (SX1)
				Nil		,;	//cAlias (para Relatorio)
				Nil		,;	//aArray (para Relatorio)
				Nil		,;	//Titulo (para Relatorio)
				Nil		,;  //Nome   (para Relatorio)
				.F.     ,;  //indica se permite que o agendamento possa ser cadastrado como sempre ativo
				.T.}        //indica que o agendamento pode ser realizado por filiais
Return aParam

/*/{Protheus.doc} LOCA086P
Impressão do reajuste
@type function
@version v1 
@author Frank Zwarg Fuga
@since 11/08/2026
/*/
Function LOCA086P(lAuto, cNome, cDir, cCorpo, aItens)
Local cHora
Local oFont1
Local oFont2
Local oFont3
Local oFont4
Local oFont5
Local cGrpCompany := AllTrim(FWGrpCompany())
Local cCodEmpGrp := AllTrim(FWCodEmp())
Local cUnitGrp := AllTrim(FWUnitBusiness())
Local cFilGrp := AllTrim(FWFilial())
Local cDocumento := ""
Local aLinhas 
Local nX
Local cComple := ""

Private lAdJustToLegacy := .F.
Private lDisableSetup   := .T.
Private cLogo			:= ""
Private cDescLogo		:= ""
Private oReport
Private oBrush      	:= TBRUSH():NEW("",CLR_HGRAY)
Private nLin        	:= 10
Private nMinLeft    	:= 10
Private nMaxWidth 	    := 584
Private nMaxHeight   	:= 2900
Private nMeio		    := ((NMAXWIDTH+NMINLEFT)/2)
Private cArquivo

Default lAuto := .F.
Default cNome := ""
Default cDir := "\RELATO\"
Default aItens := {}
Default cCorpo := ""
                  
    cHora := time()
    cHora := strtran(cHora,":","")

    cArquivo := STR0001 + "-" + DTOS(DATE()) + cHora  + ".PDF" //"REAJUSTE"
    
	If !empty(cNome)
		cArquivo := cNome
	EndIf

	c_local := cDir
	
	If !lAuto
		oReport := FWMSPrinter():New(cArquivo, IMP_PDF, .F., c_local, .T.)
        oReport:cPathPDF := c_local
        oReport:lServer  := .T.      
        oReport:lViewPDF := .T.
        oReport:nDevice  := 6
	Else
		oReport := FWMSPrinter():New(cArquivo, IMP_PDF, .F., c_local, .T.)
		oReport:cPathPDF := c_local
		oReport:lServer  := .T.      
		oReport:lViewPDF := .F.
		oReport:nDevice  := 6
	EndIf

	oReport:SETPORTRAIT()
	oReport:SETPAPERSIZE(9)

	If !lauto
		oReport:SETVIEWPDF( .T. )
	Else
		oReport:SETVIEWPDF( .F. )
	EndIF

	oFont1 := TFONTEX():NEW(oReport,"COURIER",10,10,.T.,.T.,.F.)
	oFont2 := TFONTEX():NEW(oReport,"COURIER",22,22,.F.,.F.,.F.)
	oFont3 := TFONTEX():NEW(oReport,"COURIER",12,12,.T.,.T.,.F.)
	oFont4 := TFONTEX():NEW(oReport,"COURIER",12,12,.F.,.F.,.F.)
	oFont5 := TFONTEX():NEW(oReport,"COURIER",8,8,.F.,.F.,.F.)
    
	If !Empty(cUnitGrp) .and. !file("\SYSTEM\LOCA86SCER.TXT")
		cDescLogo := cGrpCompany + cCodEmpGrp + cUnitGrp + cFilGrp
	Else
		cDescLogo := cEmpAnt + cFilAnt
	EndIf
	cLogo := GETSRVPROFSTRING("STARTPATH","") + "LOGO" + cDescLogo + ".jpg"

    oReport:STARTPAGE()

    oReport:SAY( nLin+28, nMinLeft+20, STR0002, OFONT2:OFONT )

	oReport:SAY( nLin+55, nMinLeft+20, STR0041+FP0->FP0_PROJET, OFONT2:OFONT ) //"Projeto: "

    oReport:SAYBITMAP(nLin, nMaxWidth-100, cLogo, 0098, 0040)

    nLin += 68
    
    oReport:SAY( nLin, nMaxWidth-100, dtoc(dDataBase), OFONT3:OFONT ) 

    nLin += 20

    oReport:BOX( NLIN, NMINLEFT, NLIN+40, nMaxWidth )

    nLin += 10

    oReport:SAY( nLin, NMINLEFT+5, STR0003 +alltrim(SA1->A1_NOME), OFONT1:OFONT ) //"Cliente: "
    oReport:SAY( nLin, nMaxWidth-65, STR0004 +alltrim(SA1->A1_EST), OFONT1:OFONT ) //"Estado: "

    nLin += 12

    oReport:SAY( nLin, NMINLEFT+5, STR0005 +alltrim(SA1->A1_END)+" - "+alltrim(SA1->A1_MUN), OFONT1:OFONT ) //"Endereço: "

    If SA1->A1_PESSOA == "J"
		cDocumento := STR0006+alltrim(SA1->A1_CGC) //"CNPJ: "
	Else
		If !empty(SA1->A1_CGC)
			cDocumento := STR0007+alltrim(SA1->A1_CGC) //"Documento: "
		EndIf
	EndIf
    nLin += 12

    oReport:SAY( nLin, NMINLEFT+5, cDocumento, OFONT1:OFONT ) 

    nLin += 20

    oReport:SAY( nLin, NMINLEFT+5, STR0008, OFONT1:OFONT ) //"Prezado Cliente"

    nLin += 24

    cCorpo := StrTran(cCorpo, Chr(13) + Chr(10), " ")
	cCorpo := StrTran(cCorpo, Chr(10), " ")
	cCorpo := StrTran(cCorpo, Chr(13), " ")    
       
    aLinhas := Quebra(cCorpo, 118)

    For nX := 1 to len(aLinhas)
        oReport:SAY( nLin, NMINLEFT+5, aLinhas[nX], OFONT1:OFONT ) 
        nLin += 12
    Next

	nLin += 12

	oReport:SAY( nLin, NMINLEFT+5,   STR0009, OFONT1:OFONT ) //"Obra-Item"
	oReport:SAY( nLin, NMINLEFT+51,  STR0010, OFONT1:OFONT ) //"Série"
	oReport:SAY( nLin, NMINLEFT+119, STR0011, OFONT1:OFONT ) //"Produto-Bem"
	oReport:SAY( nLin, NMINLEFT+319, STR0012, OFONT1:OFONT ) //"Aniversário"
	oReport:SAY( nLin, NMINLEFT+380, STR0013, OFONT1:OFONT ) //"Indice"
	oReport:SAY( nLin, NMINLEFT+422, STR0014, OFONT1:OFONT ) //"Valor atual"
	oReport:SAY( nLin, NMINLEFT+483, STR0015, OFONT1:OFONT ) //"Valor reajustado"

	nLin += 12

	For nX := 1 to len(aItens)

		If nLin > 800
			OREPORT:ENDPAGE()
			OREPORT:STARTPAGE()
			NLIN := 24
			oReport:SAY( nLin, NMINLEFT+5,   STR0009, OFONT1:OFONT ) //"Obra-Item"
			oReport:SAY( nLin, NMINLEFT+51,  STR0010, OFONT1:OFONT ) //"Série"
			oReport:SAY( nLin, NMINLEFT+119, STR0011, OFONT1:OFONT ) //"Produto-Bem"
			oReport:SAY( nLin, NMINLEFT+319, STR0012, OFONT1:OFONT ) //"Aniversário"
			oReport:SAY( nLin, NMINLEFT+380, STR0013, OFONT1:OFONT ) //"Indice"
			oReport:SAY( nLin, NMINLEFT+422, STR0014, OFONT1:OFONT ) //"Valor atual"
			oReport:SAY( nLin, NMINLEFT+483, STR0015, OFONT1:OFONT ) //"Valor reajustado"
			nLin += 12
		EndIf


		oReport:SAY( nLin, NMINLEFT+5,   aItens[nX,8]+"-"+aItens[nX,1], OFONT5:OFONT ) 
		oReport:SAY( nLin, NMINLEFT+51,  aItens[nX,2], OFONT5:OFONT ) 
		oReport:SAY( nLin, NMINLEFT+119, aItens[nX,3], OFONT5:OFONT ) 
		oReport:SAY( nLin, NMINLEFT+319, aItens[nX,4], OFONT5:OFONT ) 
		oReport:SAY( nLin, NMINLEFT+380, aItens[nX,5], OFONT5:OFONT ) 
		oReport:SAY( nLin, NMINLEFT+412, aItens[nX,6], OFONT5:OFONT ) 
		oReport:SAY( nLin, NMINLEFT+495, aItens[nX,7], OFONT5:OFONT ) 
		nLin += 12

	Next

	nLin += 24

	oReport:SAY( nLin, NMINLEFT+5, STR0016, OFONT1:OFONT ) //"Quaisquer dúvidas, por favor, entrar em contato."

	nLin += 24
	
	oReport:SAY( nLin, NMINLEFT+5, STR0017, OFONT1:OFONT ) //"Atenciosamente,"

	nLin += 12
	
	oReport:SAY( nLin, NMINLEFT+5, STR0018, OFONT1:OFONT ) //"Departamento de locação"

	nLin += 12

	oReport:SAY( nLin, NMINLEFT+5, alltrim(SM0->M0_NOME)+" - "+alltrim(SM0->M0_NOMECOM), OFONT1:OFONT ) 

	nLin += 12

	cComple := STR0019 //"CNPJ "
	cComple =+ alltrim(SM0->M0_CGC)
	cComple += STR0020+alltrim(SM0->M0_ENDENT) //" - Endereço: "

	oReport:SAY( nLin, NMINLEFT+5, cComple, OFONT1:OFONT ) 

	nLin += 12

	cComple := alltrim(SM0->M0_CIDENT)
	cComple += " - "+alltrim(SM0->M0_ESTENT)
	cComple += STR0021+alltrim(SM0->M0_CEPENT) //" - CEP: "

	oReport:SAY( nLin, NMINLEFT+5, cComple, OFONT1:OFONT ) 

    
    oReport:ENDPAGE()

   	If !lAuto
		oReport:SETVIEWPDF( .T. )
		If MVPAR22 <> 1 // só apresenta o relatório na tela, se não for simulação
			oReport:PREVIEW()
		else
			oReport:PRINT()
		EndIf
	Else
        oReport:PRINT()
	EndIF
	
	
	FREEOBJ(oReport)
	oReport := NIL

Return cDir+cArquivo


/*/{Protheus.doc} Quebra
Quebra das linhas do corpo do relatório
@type function
@version v1 
@author Frank Zwarg Fuga
@since 13/08/2026
/*/
Static Function Quebra(cTexto, nTam)
Local aRet      := {}
Local aPalavras := {}
Local cPalavra  := ""
Local cLinhaAtu := ""
Local nI        := 0
Local nPos      := 0

Default nTam := 118

    cTexto := alltrim(cTexto)

	// Remove espacos duplicados para nao gerar tokens vazios na quebra
	While At("  ", cTexto) > 0
		cTexto := StrTran(cTexto, "  ", " ")
	EndDo

	cTexto := AllTrim(cTexto)

	// Separa o texto em palavras (tokens), usando o espaco em branco
	// como delimitador
	While Len(cTexto) > 0

		nPos := At(" ", cTexto)

		If nPos == 0
			cPalavra := cTexto
			cTexto   := ""
		Else
			cPalavra := Left(cTexto, nPos - 1)
			cTexto   := SubStr(cTexto, nPos + 1)
		EndIf

		aAdd(aPalavras, cPalavra)

	EndDo

	// Monta as linhas respeitando o tamanho maximo, sem quebrar palavras
	For nI := 1 To Len(aPalavras)

		cPalavra := aPalavras[nI]

		If Empty(cLinhaAtu)

			// Trata o caso raro de uma palavra sozinha ser maior que o limite
			If Len(cPalavra) > nTam
				aAdd(aRet, cPalavra)
				cLinhaAtu := ""
			Else
				cLinhaAtu := cPalavra
			EndIf

		ElseIf Len(cLinhaAtu) + 1 + Len(cPalavra) <= nTam

			// Cabe na linha atual (+1 referente ao espaco separador)
			cLinhaAtu += " " + cPalavra

		Else

			// Nao cabe: fecha a linha atual e inicia uma nova
			aAdd(aRet, cLinhaAtu)

			If Len(cPalavra) > nTam
				aAdd(aRet, cPalavra)
				cLinhaAtu := ""
			Else
				cLinhaAtu := cPalavra
			EndIf

		EndIf

	Next nI

	// Adiciona a ultima linha pendente, se houver
	If !Empty(cLinhaAtu)
		aAdd(aRet, cLinhaAtu)
	EndIf

Return aRet


/*/{Protheus.doc} LOCA086E1
Registro do log dos e-mails
@type function
@version v1  
@author Frank Zwarg Fuga
@since 14/08/2026
/*/
Function LOCA086E1(aLog, lMens, lGera, cValida, cEmail, cAssunto, cCorpo, aAnexos)
Local lRet := .T.
Local cErro := ""
Local lValCli := .T.
Local lValLoj := .T.
Local lValPro := .T.
Local lValObr := .T.
Local cId
Local dDtenv := dDataBase
Local cHenv := time()
Local cStatus := "1"
Local lForca := .F.
Local lMVLOCX316 := SuperGetMv("MV_LOCX316",,.F.)
Local nX

Default lMens := .T.
Default lGera := .F.
Default cValida := ""
Default aAnexos := {}

	/* cValida (0,1) 0 não valida, 1 valida
	Exemplo: "0010" não valida cliente, loja, valida projeto e não valida obra.
	1 = Código do cliente
	2 = Loja do cliente
	3 = Projeto
	4 = Obra
	*/
	If !empty(cValida)
		If substr(cValida,1,1) == "0" // não deve validar o preenchimento do cliente
			lValCli := .F.
		Endif
		If substr(cValida,2,1) == "0" // não deve validar o preenchimento da loja do cliente
			lValLoj := .F.
		Endif
		If substr(cValida,3,1) == "0" // não deve validar o preenchimento do projeto
			lValPro := .F.
		Endif
		If substr(cValida,4,1) == "0" // não deve validar o preenchimento da obra
			lValObr := .F.
		Endif
		If substr(cValida,1,1) == "1" // não deve validar o preenchimento do cliente
			lValCli := .T.
		Endif
		If substr(cValida,2,1) == "1" // não deve validar o preenchimento da loja do cliente
			lValLoj := .T.
		Endif
		If substr(cValida,3,1) == "1" // não deve validar o preenchimento do projeto
			lValPro := .T.
		Endif
		If substr(cValida,4,1) == "1" // não deve validar o preenchimento da obra
			lValObr := .T.
		Endif
	EndIF


	/* aLog
	1 - Reservado
	2 - Código do cliente
	3 - Loja do cliente
	4 - Projeto
	5 - Obra
	6 - Data da geração
	7 - Hora da geração
	8 - Código do usuário
	9 - e-Mail
	10 - Origem
	11 - Doc
	12 - Descrição
	13 - Rastreio
	*/

	IF FH8->(FIELDPOS("FH8_ID")) == 0
		lRet := .F.
		cErro := STR0036 //"Não foi localizada a tabela do log dos e-mails."
	EndIf

	If lRet
		If len(aLog) > 0
			If lGera .and. (empty(cAssunto) .or. empty(cCorpo))
				lRet := .F.
				cErro := STR0037 //"Faltou informar o assunto e o corpo do e-mail"
			EndIf
			If lValCli
				If empty(aLog[2]) // Código do cliente
					cErro := STR0024 //"Faltou informar o código do cliente."
					lRet := .F.
				EndIf
			EndIf
			If lValLoj
				If empty(aLog[3]) // Loja do cliente
					cErro := STR0025 //"Faltou informar a loja do cliente."
					lRet := .F.
				EndIf
			EndIf
			If lValPro
				If empty(aLog[4]) // Projeto
					cErro := STR0026 //"Faltou informar o código do projeto."
					lRet := .F.
				EndIf
			EndIf
			If lValObr
				If empty(aLog[5]) // Obra
					cErro := STR0027 //"Faltou informar o código da obra."
					lRet := .F.
				EndIf
			Endif
			If empty(aLog[6]) // Data da geração
				cErro := STR0028 //"Faltou informar a data da geração."
				lRet := .F.
			EndIf
			If empty(aLog[7]) // Hora da geração
				cErro := STR0029 //"Faltou informar a hora da geração."
				lRet := .F.
			EndIf
			If empty(aLog[8]) // Usuário
				cErro := STR0030 //"Faltou informar o código do usuário."
				lRet := .F.
			EndIf
			If empty(aLog[9]) // E-mail
				cErro := STR0031 //"Faltou informar os e-mails."
				lRet := .F.
			EndIf
			If empty(aLog[10]) // Origem
				cErro := STR0032 //"Faltou informar a origem da informação."
				lRet := .F.
			EndIf
			If empty(aLog[12]) // Dados da descrição do e-mail
				cErro := STR0033 //"Faltou informar os dados da descrição do e-mail."
				lRet := .F.
			EndIf
			If empty(aLog[13]) // Rastreio
				cErro := STR0034 //"Faltou informar o rastreio do registro"
				lRet := .F.
			EndIf
		Else
			cErro := STR0035 //"Faltou informar os dados para o registro do e-Mail."
			lRet := .F.
		EndIF
	EndIf

	If lGera .and. lRet

		If empty(cEmail) .or. empty(cAssunto) .or. empty(cCorpo)
			lRet := .F.
			cErro := STR0039 //"O e-mail destinatário, assunto e corpo são obrigatórios."
		Else
			// Enviar o e-mail
			If !LOCA0735(cEmail, cAssunto, cCorpo, aAnexos)
				lRet := .F.
				cErro := STR0038 //"Falha no envio do e-mail"
				lForca := .T.
				cStatus := "2"
				dDtenv := ctod("")
				cHenv := ""
			EndIf
		EndIF
	EndIf

	If !lRet
		Help(Nil,	Nil,STR0022+alltrim(upper(Procname())),; //"RENTAL: "
			Nil,STR0023,1,0,Nil,Nil,Nil,Nil,Nil,; //"Inconsistência nos dados."
			{cErro})  
	EndIf

	If lRet .or. lForca
		FH8->(RecLock("FH8",.T.))
		cID := GETSX8NUM("FH8","FH8_ID")
		ConfirmSx8()
		FH8->FH8_FILIAL	:= xFilial("FH8")
		FH8->FH8_ID		:= cId
		FH8->FH8_CODCLI := aLog[2]
		FH8->FH8_LOJA	:= aLog[3]
		FH8->FH8_PROJET	:= aLog[4]
		FH8->FH8_OBRA	:= aLog[5]
		FH8->FH8_DTGERA	:= aLog[6]
		FH8->FH8_HGERA	:= aLog[7]
		FH8->FH8_DTENV	:= dDtenv
		FH8->FH8_HENV	:= cHenv
		FH8->FH8_STATUS	:= cStatus
		FH8->FH8_USUARI	:= aLog[8]
		FH8->FH8_EMAIL	:= aLog[9]
		FH8->FH8_ORIGEM	:= aLog[10]
		FH8->FH8_DOC	:= aLog[11]
		FH8->FH8_DESC	:= aLog[12]
		FH8->FH8_RASTRO	:= aLog[13]
		FH8->(MsUnlock())

		// Gravação do banco de conhecimento
		If lMVLOCX316
			For nX := 1 to len(aAnexos)
				GERDOC(aAnexos[nX])
			Next
		EndIf


	EndIf

Return lRet

/*/{Protheus.doc} LOCA086VE
Visualização dos e-mails
@type function
@version v1 
@author Frank Zwarg Fuga
@since 17/08/2026
/*/
Function LOCA086VE
Private aRotina := {}
Private cTitulo := STR0042 //"Registro do envio de e-mails"
Private cCadastro := STR0042 //"Registro do envio de e-mails"

	dbSelectArea("FH8")
	dbSetOrder(1)

    aRotina := MenuDef()
	MBROWSE(6,1,22,75,"FH8")
    

Return Nil

/*/{Protheus.doc} MenuDef
Menu de opcoes
@author Frank Zwarg Fuga
@since 17/08/2026
@version 1.0
/*/

Static Function MenuDef()
Local aRotina := {}

    AADD(AROTINA,{STR0040,"AXVISUAL",0,2}) //"Visualizar"
	AADD(AROTINA,{STR0043,"LOCA086DC",0,2}) //"Banco de Conhecimento"

Return aRotina    


/*/{Protheus.doc} Docs
Apresenta o banco de conhecimento
@type function
@version v1 
@author Frank Zwarg Fuga
@since 18/08/2026
/*/
Function LOCA086DC
Local lMVLOCX316 := SuperGetMv("MV_LOCX316",,.F.)

	If lMVLOCX316
		MsDocument("FH8", FH8->(Recno()), 1)
	Else
		Help(Nil,	Nil,STR0022+alltrim(upper(Procname())),; //"RENTAL: "
			Nil,STR0023,1,0,Nil,Nil,Nil,Nil,Nil,; //"Inconsistência nos dados."
			{STR0044}) //"O parâmetro MV_LOCX316 está desativado."
	EndIf

Return



/*/{Protheus.doc} GERDOC
Criação do banco de conhecimento
@type function
@author Frank Z Fuga
@since 18/08/2026
/*/
Static Function GERDOC(cAnexo)
Local nCont 
Local cArquivo := ""
Local cExtensao
Local cCodObj
Local cDirDoc := Alltrim(GetMv("MV_DIRDOC"))
Local cComando

	cAnexo := alltrim(cAnexo)
	nCont := len(cAnexo)
	While nCont > 0
		If Substr(cAnexo,nCont,1) == "." 
			Exit
		EndIf
		nCont --
	EndDo
	cExtensao := alltrim(substr(cAnexo,nCont,len(cAnexo)))
	cArquivo := "rental-lc86"+alltrim(FH8->FH8_ID)+cExtensao

	If SubStr(cDirDoc, Len(cDirDoc), 1) != '\'
		cDirDoc := cDirDoc + "\"
	EndIf
	cPathBco := cDirDoc + "co" + cEmpAnt + "\shared\"

	cComando := '__CopyFile(cAnexo, cPathBco + cArquivo)'
	&(cComando)

	If file(cPathBco + cArquivo)
		ACB->(DbSetOrder(2))
		If Reclock("ACB", .T.)
			cCodObj := GetSxeNum("ACB","ACB_CODOBJ")
			ConfirmSx8()
			ACB->ACB_FILIAL := FWxFilial('ACB')
			ACB->ACB_CODOBJ := cCodObj
			ACB->ACB_OBJETO := cArquivo
			ACB->ACB_DESCRI := cAnexo
			ACB->(MsUnlock())

			AC9->(DbSetOrder(1))
			If Reclock("AC9", .T.)
				AC9->AC9_FILIAL := FWxFilial('AC9')
				AC9->AC9_FILENT	:= FWxFilial("FH8")
				AC9->AC9_ENTIDA := "FH8"
				AC9->AC9_CODENT := xFilial("FH8")+FH8->FH8_ID
				AC9->AC9_CODOBJ := cCodObj
				AC9->(MsUnlock())
			EndIF
		EndIf
	EndIf
Return
