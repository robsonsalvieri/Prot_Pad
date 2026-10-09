#INCLUDE "TOTVS.CH"
#INCLUDE "QIEA183.CH"

/*/{Protheus.doc} QIEA183
Importacao/Reimportacao das Entradas.
@author Paulo Emidio de Barros
@since 29/05/2001
/*/

Static Function MenuDef(cAlias)

	Local aRotina := {}

	If cAlias == "TMP"
		Aadd(aRotina,{OemToAnsi(STR0005), "Q183MkAllI()", 0, 5})//"Seleciona"
		Aadd(aRotina,{OemToAnsi(STR0008), "Q183GrvImp()", 0, 5})//"Importacao"
	Else
		Aadd(aRotina,{OemToAnsi(STR0007), "Q183MkAllQ()", 0, 5})//"Seleciona"
		Aadd(aRotina,{OemToAnsi(STR0008), "Q183GrvImp()", 0, 5})//"Importacao"
		Aadd(aRotina,{OemToAnsi(STR0009), "Q183ExcImp()", 0, 5})//"Exclusao"
	EndIf
	Aadd(aRotina,{OemToAnsi(STR0010), "Q183Ocor()" , 0, 3}) //"Ocorrencias"
	Aadd(aRotina,{OemToAnsi(STR0067), "Q183Ficha()", 0, 3}) //Ficha Produto
	Aadd(aRotina,{OemToAnsi(STR0011), "Q183Legend" , 0, 5,,.F.}) //"Legenda"

Return aRotina


Function Qiea183()

	Local aArea            := GetArea()
	Local aStru            := NIL
	Local aTam             := NIL
	Local bProcessa        :={|oSelf| Q183GeraTmp("TMP",cFileTmp,aStruTXT,oSelf)}
	Local cAliasQry        := ""
	Local cDescricao       := ""
	Local cFuncao          := "QIEA183"
	Local cPergunte        := "QEA183"
	Local cTitulo          := OemToAnsi( STR0002 ) //"Realizando carga no Arquivo Temporario"
	Local lContinua        := NIL
	Local oQLTQueryManager := QLTQueryManager():New()
	Local oTempTable       := NIL

	Private aCpoUsu  := {}
	Private aStruTxt := {}
	Private cFileTmp := NIL

	// mv_par01 = Realiza Importacao 1) Normal 2)TXT
	// mv_par02 = Caminho do Arquivo TXT
	// mv_par03 = Arquivo TXT a ser Importado
	// mv_par04 = Exibe Log de Importacao
	// mv_par05 = Imprime Ocorrencias

	lContinua := Pergunte("QEA183",.T.)
	cFileTmp  := (AllTrim(mv_par02)+AllTrim(mv_par03))

	If mv_par01 == 2
		If File(cFileTmp) == .F.
			lContinua := .F.
		EndIf
	EndIf

	If lContinua
		MsgRun(STR0064,STR0065,{||Q183DelFic()})
	Else
		Return(NIL)
	EndIf

	If (!oQLTQueryManager:validaTamanhoCamposChaveNF("QEK", "QEL", "QEL_NISERI", "QEK") .OR.;
   		!oQLTQueryManager:validaTamanhoCamposChaveNF("QEK", "QER", "QER_NISERI", "QEK") .OR.;
   		!oQLTQueryManager:validaTamanhoCamposChaveNF("D1" , "QER", "QER_NISERI", "D1" ) .OR.;
   		!oQLTQueryManager:validaTamanhoCamposChaveNF("D1" , "QEL", "QEL_NISERI", "D1" )) 
		Return Nil
	EndIf

    // Realiza a Importacao do arquivo TXT
	If mv_par01 == 2

		// Retorna a Estrutura do layout para a Importacao TXT
		aStruTXT := Q183OpenTxt()

		// Se Q183OpenTxt retornou NIL, o IMPORT.IMP esta com tamanhos de campo inconsistentes com a SX3 (QEP_TAMLOT, QEP_TAMAMO ou QEP_PRECO).
		If ValType(aStruTXT) == "U" .Or. Len(aStruTXT) == 0
			RestArea(aArea)
			Return Nil
		EndIf

		// Define a estrutura do arquivo temporario
		aStru := {}
		Aeval(aStruTXT,{|x|aTam := TamSX3(x[3]),Aadd(aStru,{x[3],"C",aTam[1],aTam[2]})})

		//Adiciona os demais campos na estrutura
		aTam := TamSX3("QEP_TES")   ; Aadd(aStru,{"QEP_TES"   ,"C",aTam[1],aTam[2]})
		aTam := TamSX3("QEP_CODTAB"); Aadd(aStru,{"QEP_CODTAB","C",aTam[1],aTam[2]})
		aTam := TamSX3("QEP_LOTORI"); Aadd(aStru,{"QEP_LOTORI","C",aTam[1],aTam[2]})
		aTam := TamSX3("QEP_OK")    ; Aadd(aStru,{"QEP_OK"    ,"C",aTam[1],aTam[2]})

		// Abre o arquivo Temporario
		
		oTempTable := FWTemporaryTable():New( "TMP" )
		oTempTable:SetFields( aStru )
		oTempTable:AddIndex("indice1", {"QEP_FORNEC","QEP_LOJFOR","QEP_PRODUT","QEP_DTENTR","QEP_LOTE"} )
		oTempTable:Create()

		dbSelectArea("TMP")

		// Executa a gravacao do Arquivo Temporario
		Processa({||Q183GeraTmp("TMP",cFileTmp,aStruTXT)},STR0002,; //"Realizando carga no Arquivo Temporario"
		OemToAnsi(STR0003),.F.)//"Gravando Registro..."

		// Verifica se o Arquivo esta vazio
		dbSelectArea("TMP")
		TMP->(dbGoTop())
		If Eof()
			Help("  ",1,"QNAOEXITXT")
		Else
			// Exibe o Browse com os dados a serem importados
			If mv_par04 == 1
				Q183BrwOcor("TMP")
			Else
				// Realiza a Importacao dos dados sem exibicao do Log
				Q183GrvImp(.F.)

				// Realiza a Impressao do Relatorio de Ocorrencias
				If mv_par05 == 1
					Q183Ocor()
				EndIf
			EndIf
		EndIf

		// Exclui o arquivo Temporario
		TMP->(DBCloseArea())
		oTempTable:Delete()

	Else
		// Realiza a Importacao do arquivo Normal (a partir do QEP)
		
		cAliasQry := QIE183MQ() // Monta queries da QEP
				
		If (cAliasQry)->(Eof())
			Help("  ",1,"QNAOEXIINC")
		Else
			If mv_par04 == 1
				Q183BrwOcor("QEP")
			Else
				// Realiza a Importacao dos dados sem exibicao do Log
				Q183GrvImp(.F.)
			EndIf
		EndIf
		(cAliasQry)->(DBCloseArea())
	EndIf

	RestArea(aArea)
Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Q183GeraTmp³ Autor ³Paulo Emidio de Barros³ Data ³29/05/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Realiza a gravacao das Entradas a serem importadas no TMP  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q183GeraTmp(EXPC1,EXPC2,EXPN1,EXPA1)						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPC1 = Alias do Arquivo Temporario						  ³±±
±±³          ³ EXPC2 = Nome do Arquivo Temporario						  ³±±
±±³          ³ EXPA1 = Estrutura do arquivo temporario					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIEA183													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Q183GeraTmp(cAlias,cFileTmp,aStruTXT,oSelf)
	Local nHandle
	Local xBuffer := ""
	Local cCampo
	Local nQtdRec := 1
	Local bRegua

	dbSelectArea(cAlias)

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Grava os dados no arquivo temporario a partir do TXT		 ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	bRegua := {||nHandle := fOpen(cFileTmp,2+64),nQtdRec := fSeek(nHandle,0,2),;
		fReadLn(nHandle,@xBuffer,1000),nQtdRec := (nQtdRec/Len(xBuffer)),fClose(nHandle)}
	Eval(bRegua)

	xBuffer := " "
	nHandle := fOpen(cFileTmp,2+64)

	ProcRegua(nQtdRec)

	While fReadLn(nHandle,@xBuffer,1000)

		If !SeekQEP183(QEP->QEP_CODTAB, QEP->QEP_FORNEC, QEP->QEP_LOJFOR, QEP->QEP_PRODUT, QEP->QEP_NTFISC,;
					 QEP->QEP_SERINF, QEP->QEP_ITEMNF, QEP->QEP_TIPONF, QEP->QEP_DTENTR, QEP->QEP_LOTE  , QEP->QEP_NUMSEQ)

			RecLock(cAlias,.T.)
			Aeval(aStruTXT,{|x|cCampo:=SubStr(xBuffer,x[1],(x[2]-x[1])+1),;
				FieldPut(FieldPos(AllTrim(x[3])),cCampo)})
			(cAlias)->(MsUnLock())
			IncProc()

		Endif

	EndDo

    //Fecha o arquivo 
	fClose(nHandle)

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Q183BrwOcor³ Autor ³Paulo Emidio de Barros³ Data ³30/05/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Exibicao do browse com os dados a serem importados		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q183BrwOcor(EXPC1)										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do Arquivo Temporario						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIEA183													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Q183BrwOcor(cAlias)
	Local aCor      := {}
	Local aCpoBrw   := {}
	Local cCampo    := ""
	Local cFilInc   := ''
	Local cMarcaAll := ""
	Local nY        := 0
	Local oBrw      := Nil

   // Define as variaveis utilizadas no MarkBrowse
	Private cCadastro := OemToAnsi(STR0004) // Log de Importacao/Reimportacao 
	Private cMarca    := GetMark()
	Private lInverte

	// Monta o aRotina conforme a origem da Importacao
	Private aRotina   := MenuDef(cAlias)

	If mv_par01 == 1
		aAdd(aCor,{"QEP->QEP_CODTAB <> '2' ", 'BR_AMARELO' })  // Pendente para Importacao Normal ou TXT
		aAdd(aCor,{"QEP->QEP_CODTAB == '2' ", 'BR_VERMELHO' }) //Importacao realizada com Inconsistencia
	else
		aAdd(aCor,{"QEP->QEP_CODTAB <> '2'", 'BR_AMARELO'})    // Pendente para Importacao TXT
		aAdd(aCor,{"QEP->QEP_CODTAB == '2'", 'BR_VERMELHO'})   // Importacao realizada com Inconsistencia
	Endif

	// Define colunas com os campos a serem utilizados na MarkBrowse
	Aadd(aCpoBrw,{"QEP_OK"    ,," "})
	Aadd(aCpoBrw,{"QEP_FORNEC",,STR0012}) //"Forn/Cliente"
	Aadd(aCpoBrw,{"QEP_LOJFOR",,STR0013}) //"Loja"
	Aadd(aCpoBrw,{"QEP_PRODUT",,STR0014}) //"Produto"
	Aadd(aCpoBrw,{"QEP_DTENTR",,STR0015}) //"Entrada"
	Aadd(aCpoBrw,{"QEP_HRENTR",,STR0016}) //"Hora"
	Aadd(aCpoBrw,{"QEP_LOTE"  ,,STR0017}) //"Lote"
	Aadd(aCpoBrw,{"QEP_DOCENT",,STR0018}) //"Documento"
	Aadd(aCpoBrw,{"QEP_TAMLOT",,STR0019}) //"Tamanho"
	Aadd(aCpoBrw,{"QEP_TAMAMO",,STR0020}) //"Amostra"
	Aadd(aCpoBrw,{"QEP_PEDIDO",,STR0021}) //"Pedido"
	Aadd(aCpoBrw,{"QEP_NTFISC",,STR0022}) //"Nota Fiscal"
	Aadd(aCpoBrw,{"QEP_SERINF",,STR0023}) //"Serie NF"
	Aadd(aCpoBrw,{"QEP_DTNFIS",,STR0024}) //"Data NF"
	Aadd(aCpoBrw,{"QEP_TES"   ,,STR0056}) //TES
	Aadd(aCpoBrw,{"QEP_TIPDOC",,STR0025}) //"Tipo DOC"
	Aadd(aCpoBrw,{"QEP_CERFOR",,STR0026}) //"Certificado"
	Aadd(aCpoBrw,{"QEP_DIASAT",,STR0027}) //"Dias atraso"
	Aadd(aCpoBrw,{"QEP_SOLIC" ,,STR0028}) //"Solicitante"
	Aadd(aCpoBrw,{"QEP_PRECO" ,,STR0029}) //"Preco"
	Aadd(aCpoBrw,{"QEP_EXCLUI",,STR0030}) //"Exclusao"
	Aadd(aCpoBrw,{"QEP_CODTAB",,STR0066}) //"Status da Importacao"
	Aadd(aCpoBrw,{"QEP_LOTORI",,STR0057}) //"Tam Lote original"
    
	// Adiciona no Browse campos de usuarios.
	If Len(aCpoUsu) > 0
		For nY:=1 to Len(aCpoUsu)
			cCampo := GetSx3Cache("QEP_"+aCpoUsu[nY],"X3_CAMPO")
			If !Empty(cCampo)
				Aadd(aCpoBrw,{Alltrim(cCampo),,AllTrim(QAGetX3Tit("QEP_"+aCpoUsu[nY]))})
			EndIf
		Next nY
	EndIF

	// Endereca a funcao
	dbSelectArea(cAlias)
	
	cMarcaAll := If(cAlias == "TMP", "Q183MkAllI()", "Q183MkAllQ()")
	cFilInc := 'QEP_CODTAB <> "1"'
	
	// STR0084 - "Selecionando as Entradas..."
	// STR0085 - "Aguarde..."
	MsgRun(STR0084,STR0085,{||dbSetFilter({||&cFilInc},cFilInc)})
	dbGoTop()
	MarkBrow(cAlias,"QEP_OK",,aCpoBrw,@lInverte,@cMarca,cMarcaAll,,,,"Q183MarkAny()",,,,aCor)

	dbSelectArea(cAlias) // Desliga o Filtro Ativo
	Set Filter to
	oBrw    := GetObjBrow()
	freeObj(oBrw)

Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Q183MkAllI ³ Autor ³Paulo Emidio de Barros³ Data ³30/05/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Marca todos os registros provenientes da Importacao TXT	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q183MkAllI()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIEA183													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q183MkAllI()
	Local aAreaAnt := GetArea()

	dbSelectArea("TMP")
	dbGoTop()
	dbEval({||Q183MarkAny("TMP")})

	RestArea(aAreaAnt)

Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Q183MkAllQ ³ Autor ³Paulo Emidio de Barros³ Data ³30/05/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Marca todos os registros provenientes da ReImportacao no QEP³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q183MkAllQ()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIEA183													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q183MkAllQ()
	Local aAreaAnt := GetArea()

	dbSelectArea("QEP")
	dbGoTop()
	While !Eof()
		Q183MarkAny("QEP")
		dbSkip()
	Enddo

	RestArea(aAreaAnt)
Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Q183MarkAny³ Autor ³Paulo Emidio de Barros³ Data ³30/05/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ realiza a marca do registro corrente na MarkBrowse		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q183MarkAny(expc1,expl1)									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPC1 = Alias corrente na MarkBrowse						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIEA183													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q183MarkAny(cAlias)
	Default cAlias := Alias()

	RecLock(cAlias,.F.)
	If IsMark("QEP_OK",ThisMark(),ThisInv())
		Replace QEP_OK With " "
	Else
		Replace QEP_OK With cMarca
	EndIf
	MsUnLock()

Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Q183GrvImp ³ Autor ³Paulo Emidio de Barros³ Data ³30/05/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Realiza a gravacao das Entradas provenientes do QEP (Entra-³±±
±±³			 ³ das Inconsistentes), atraves da chamada da Q183GravaTmp()  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q183GrvImp()											 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ NENHUM													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIEA183													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q183GrvImp(lDispLog)
	Default lDispLog := .T.

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Realiza a gravacao da Entrada								 ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Processa({||Q183GravaTmp(If(mv_par01==1,"QEP","TMP"),lDispLog)},OemToAnsi(STR0050),;//"Gravando os dados referente a Entrada"
	OemToAnsi(STR0051),.F.) //"Gravando Registro..."

Return(.T.)

/* {Protheus.doc} Q183GravaTmp
Realiza a gravacao das Entradas e Inconsistencias.
@author Paulo Emidio de Barros
@since 29/05/2001
@param01 cAlias, Caracter, Alias do Arquivo Temporario
@param02 lLog  , Logical , Exibe o Log de Importacao
*/
Static Function Q183GravaTmp(cAlias,lDispLog)

	Local aDadosImp   := Nil
	Local aRetQie     := Nil
	Local aStruQEP    := QEP->(dbStruct())
	Local cIndexQEP   := ''
	Local cSvFilAnt   := cFilAnt
	Local lExcluirTXT := .F.
	Local lQE183GRV   := ExistBlock("QE183GRV")
	Local lQuery      := .F.
	Local nCpoUsu     := 0
	Local nPosCpo     := 0
	Local nTmLote     := TamSX3("D1_LOTECTL")[1]
	Local nTmSubLote  := TamSX3("D1_NUMLOTE")[1]

	dbSelectArea(cAlias)

	// Filtras as Inconsistencias, quando for Importacao Normal sem a exibicao do LOG de Registros.
	Pergunte("QEA183",.F.)
	If mv_par01 == 1 .And. mv_par04 == 2
		lQuery := .T.
		//Filtra as Entradas no Periodo

		cAlias := QIE183MQ() // Monta queries da QEP

		For nPosCpo := 1 To Len(aStruQEP)
			If aStruQEP[nPosCpo,2]<>"C"
				TcSetField(cAlias,aStruQEP[nPosCpo,1],aStruQEP[nPosCpo,2],aStruQEP[nPosCpo,3],aStruQEP[nPosCpo,4])
			EndIf
		Next nPosCpo
	EndIf

	QEP->(dbGoTop())
	ProcRegua(LastRec())
	While !QEP->(Eof())

		IncProc()

		// Importa somente os Itens selecionados na MarKBrowse
		If lDispLog
			If !IsMark("QEP_OK",cMarca);
					.Or. (cAlias)->QEP_CODTAB == "1";
					.Or. ((cAlias)->QEP_CODTAB == "2" .And. cAlias == "TMP")
				QEP->(dbSkip())
				Loop
			EndIf
		EndIf

		// Grava os dados referentes ao Inspecao de Entradas (SIGAQIE)
		aDadosImp := { ;
			QEP_NTFISC,;                               			            //01-Numero da Nota Fiscal
			QEP_SERINF,;                                           			//02-Serie da Nota Fiscal
			If(cAlias == "TMP","N",QEP_TIPONF),;                            //03-Tipo da Nota Fiscal
			If(cAlias == "TMP",StoD(QEP_DTNFIS),QEP_DTNFIS),;               //04-Data de Emissao da Nota Fiscal
			If(cAlias == "TMP",StoD(QEP_DTENTR),QEP_DTENTR),;               //05-Data de Entrada da Nota Fiscal
			QEP_TIPDOC,; 								                    //06-Tipo de Documento
			If(cAlias == "TMP",IIF(Ascan(aStruTXT,{|x|x[3]=="QEP_ITEMNF"})>0,QEP_ITEMNF,Space(TamSx3("D1_ITEM")[1])),QEP_ITEMNF),;  //07-Item da Nota Fiscal
			Space(TamSx3("D1_REMITO")[1]),;                                 //08-Numero do Remito (Localizacoes)
			QEP_PEDIDO,;                                                    //09-Numero do Pedido de Compra
			If(cAlias == "TMP",IIF(Ascan(aStruTXT,{|x|x[3]=="QEP_ITEMPC"})>0,QEP_ITEMPC,Space(TamSx3("D1_ITEMPC")[1])),QEP_ITEMPC),; //10-Item do Pedido de Compra
			QEP_FORNEC,;                                                    //11-Codigo Fornecedor/Cliente
			QEP_LOJFOR,;                                                    //12-Loja Fornecedor/Cliente
			QEP_DOCENT,;                                           			//13-Numero do Lote do Fornecedor (Doc de Entrada)
			QEP_SOLIC,;                                                     //14-Codigo do Solicitante
			QEP_PRODUT,;                                                    //15-Codigo do Produto
			If(cAlias == "TMP",IIF(Ascan(aStruTXT,{|x|x[3]=="QEP_LOCORI"})>0,QEP_LOCORI,Space(TamSx3("D1_LOCAL")[1])),QEP_LOCORI),;  //16-Local Origem
			SubStr(QEP_LOTE,1,nTmLote),;                                    //17-Numero do Lote
			SubStr(QEP_LOTE,nTmLote+1,nTmSubLote),;                         //18-Sequencia do Sub-Lote
			If(cAlias == "TMP",IIF(Ascan(aStruTXT,{|x|x[3]=="QEP_NUMSEQ"})>0,QEP_NUMSEQ,Space(TamSx3("D1_NUMSEQ")[1])),QEP_NUMSEQ),; //19-Numero Sequencial
			QEP_CERFOR,;                                                    //20-Numero do CQ
			Val(QEP_TAMLOT),;                                               //21-Quantidade
			If(cAlias == "TMP",Val(QEP_PRECO),QEP_PRECO),;                  //22-Preco
			If(cAlias == "TMP",Val(QEP_DIASAT),QEP_DIASAT),;                //23-Dias de atraso
			QEP_TES,;                                                       //24-TES
			If(cAlias == "TMP",AllTrim(FunName()),QEP_ORIGEM),;             //25-Origem
			If(cAlias == "TMP",mv_par03,QEP_IMPORT),;                       //26-Origem da Importacao TXT
			QEP_LOTORI,;                                                    //27-Tamanho do lote original
			QEP_HRENTR;                                                     //28-Hora da Entrada
		}

		//Conforme DMANQUALI-10900, execução multi-filial só funcionará se tabela QEP for exclusiva
		If FWModeAccess("QEP") != "C" //Proteção para manter filial logada quando QEP for compartilhada
			cFilAnt := QEP->QEP_FILIAL // Modifica a Filial do registro
		EndIf
		
		// Realiza a integracao Materiais x Inspecao de Entradas
		aRetQie     := qAtuMatQie(aDadosImp,If(QEP->QEP_EXCLUI=="S",2,1),If(cAlias=="TMP",.T.,.F.))
		lExcluirTXT := .T.

		// Realiza gravacao dos campos incluidos pelo usuario no Import.imp
		If Len(aCpoUsu) > 0

			If aRetQie[1] == "C" .Or. aRetQie[1] == " " //Entrada Certificada e/ou a Inspecionar
				For nCpoUsu := 1 to Len(aCpoUsu)
					SX3->(dbSetOrder(2))
					If SX3->(dbSeek("QEK_"+aCpoUsu[nCpoUsu]))
						If SX3->(dbSeek("QEP_"+aCpoUsu[nCpoUsu]))
							RecLock("QEK",.F.)
							QEK->(&("QEK_"+aCpoUsu[nCpoUsu])) := TMP->(&("QEP_"+aCpoUsu[nCpoUsu]))
							MsUnlock()
						EndIf
					EndIf
				Next nCpoUsu

			ElseIf aRetQie[1] == "E" //Ocorrencia de Erro
				For nCpoUsu := 1 to Len(aCpoUsu)
					SX3->(dbSetOrder(2))
					If SX3->(dbSeek("QEP_"+aCpoUsu[nCpoUsu]))
						RecLock("QEP",.F.)
						QEP->(&("QEP_"+aCpoUsu[nCpoUsu])) := TMP->(&("QEP_"+aCpoUsu[nCpoUsu]))
						MsUnlock()
					EndIf
				Next

			EndIf
		EndIf

		dbSelectArea(cAlias)
		If cAlias == 'TMP'
			If SeekQEP183(If(aRetQie[3],'1','2'), QEP->QEP_FORNEC, QEP->QEP_LOJFOR, QEP->QEP_PRODUT, QEP->QEP_NTFISC,;
						QEP->QEP_SERINF, QEP->QEP_ITEMNF, QEP->QEP_TIPONF, QEP->QEP_DTENTR, QEP->QEP_LOTE  , QEP->QEP_NUMSEQ)
				RecLock('QEP',.F.)
				QEP->(DBDelete())
				MsUnLock()
			
			Else
				RecLock('TMP',.F.)
				TMP->QEP_CODTAB := If(aRetQie[3],'1','2')
				MsUnLock()
			EndIf
		EndIf

		//³Ponto de Entrada apos gravação das tabelas QEP e QEK.
		If lQE183GRV
			ExecBlock("QE183GRV",.F.,.F.)
		EndIf

		cFilAnt := cSvFilAnt // Restaura a Filial

		QEP->(dbSkip())

	EndDo

	// Restaura a area original das Inconsistencias  
	If mv_par01 == 1 .And. mv_par04 == 2 //Importacao Normal, Sem LOG
		dbSelectArea(cAlias)
		If lQuery
			dbCloseArea()
		Else
			RetIndex("QEP")
			Set Filter To
			fErase(cIndexQEP+OrdBagExt())
		EndIf
		dbSelectArea("QEP")
	EndIf

	//Exclui o arquivo TXT, que foi importado
	If mv_par01 == 2 .And. lExcluirTXT
		fErase(cFileTMP)
	EndIf

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Q183ExcImp ³ Autor ³Paulo Emidio de Barros³ Data ³04/06/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Realiza a exclusao das Entradas inconsistentes			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q183ExcImp()											 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIEA183													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q183ExcImp()
	Local lRet := .T.

	// Realiza a gravacao da Entrada
	If !MsgNoYes (STR0088) //Deseja excluir esta entrada?
		lRet :=.F.
	Endif

	If lRet
		Processa({||Q183DelInc("QEP")},OemToAnsi(STR0054),; //"Excluindo Entradas Inconsistentes"
		OemToAnsi(STR0055),.F.) //"Excluindo Registro..."
	EndIf

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Q183DelInc ³ Autor ³Paulo Emidio de Barros³ Data ³04/06/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Realiza a exclusao das Entradas inconsistentes no QEP	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q183DelInc()											 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIEA183													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function q183DelInc(cAlias)
	dbSelectArea(cAlias)
	dbGoTop()
	ProcRegua(LastRec())
	While !Eof()
		IncProc()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Exclue somente os registros marcados						 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !IsMark("QEP_OK",cMarca)
			dbSkip()
			Loop
		EndIf

		RecLock(cAlias,.F.)
		dbDelete()
		MsUnLock()
		dbSkip()
	EndDo

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QIEA180    ³ Autor ³Paulo Emidio de Barros³ Data ³01/08/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Compatibiliza a chamada nas versoes anteriores			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QIEA180() 												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIEA183													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QIEA180()
	QIEA183()
Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QIEA190    ³ Autor ³Paulo Emidio de Barros³ Data ³01/08/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Compatibiliza a chamada nas versoes anteriores			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QIEA190() 												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIEA183													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QIEA190()
	QIEA183()
Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QIEM060    ³ Autor ³Paulo Emidio de Barros³ Data ³01/08/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Compatibiliza a chamada nas versoes anteriores			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QIEM060() 												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIEA183													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QIEM060()
	QIEA183()
Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Q183Ocor   ³ Autor ³Paulo Emidio de Barros³ Data ³04/06/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Realiza a chamada do Relatorio de ocorrencias			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q183Ocor()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ NENHUM													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIEA183													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q183Ocor()
	Local wnrel    := "QIEA183"
	Local cString  := "QEK"
	Local aAreaAnt := GetArea()
	Local cDesc1   := OemToAnsi(STR0068) //"Neste relat¢rio ser„o relacionadas as entradas"
	Local cDesc2   := OemToAnsi(STR0069) //"dos Produtos/Fornecedores."
	Local cDesc3   := ""
	Local aSX1

	aSX1 := QA_SaveSX1() //Salva as perguntas

	Private cTitulo   := OemToAnsi(STR0070) //"Relatorio de Ocorrencias da Importacao"
	Private cTamanho  := "M"
	Private cPerg     := "Q183OC"
	Private aReturn   := {STR0071, 1,STR0072, 1, 2, 1, "",1 } //"Zebrado" ### "Administracao"
	Private cNomeProg := "QIEA183"
	Private nLastKey  := 0

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Verifica as perguntas selecionadas                           ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	pergunte("Q183OC",.F.)

	wnrel := SetPrint(cString,wnrel,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,.F.,"",.T.,cTamanho,,,,,.F.)

	If nLastKey == 27
		Set Filter To
		Return
	Endif

	SetDefault(aReturn,cString)

	RptStatus({|lEnd| Q183Imp(@lEnd,wnrel,cString)},cTitulo)

	RestArea(aAreaAnt)

	QA_RestSX1(aSX1) //Recupera as Perguntas

Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Q183Imp    ³ Autor ³Paulo Emidio de Barros³ Data ³04/06/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Realiza a Impressao do Relatorio de Ocorrencias			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q183Imp()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Q183Imp(lEnd,wnrel,cString)								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIEA183													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q183Imp(lEnd,wnrel,cString)
	Local cbTxt   := Space(10)
	Local cbCont  := 0
	Local nTipo   := If(aReturn[4]==1,15,18)
	Local cAprv	  := "A"+Space(TamSX3("QEP_ERRO")[1]-1)
	Local cCabec1 := " "
	Local cCabec2 := " "


	If mv_par01 == 1 .or. mv_par01 == 2

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Imprime as entradas inconsistentes 							 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		//01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
		//          1         2         3         4         5         6         7         8         9        10
		//Fornecedor       Loja Produto         Data Entrada Lote              Inconsistencia
		cCabec1 := STR0073 //"Fornecedor       Loja Produto         Data Entrada Lote              Inconsistencia"
		cCabec2 := " "
		Li      := 80
		m_Pag   := 01

		dbSelectArea("QEP")
		dbSetOrder(1)
		MsSeek(xFilial("QEP")+"2")
		SetRegua(RecCount())
		While !Eof() .And. QEP_FILIAL == xFilial("QEP") .And. QEP_CODTAB == "2"
			If lEnd
				@PROW()+1,001 PSAY STR0074 //"CANCELADO PELO OPERADOR"
				Exit
			Endif

			If QEP->QEP_IMPFIC == "S" .or. QEP->QEP_FORNEC < mv_par02 .or. QEP->QEP_FORNEC > mv_par03 .or. QEP->QEP_PRODUT < mv_par04 .or. ;
					QEP->QEP_PRODUT > mv_par05 .or. dtos(QEP->QEP_DTENTR) < dtos(mv_par06) .or. dtos(QEP->QEP_DTENTR) > dtos(mv_par07)
				dbSkip()
				Loop
			EndIf
			IncRegua()

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Impressao do Cabecalho										 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Li > 58
				Cabec(STR0075,cCabec1,cCabec2,cNomeProg,cTamanho,nTipo,,.F.) //"Entradas Inconsistentes"
				Li++
			Endif

			@ Li,000 PSAY QEP_FORNEC
			@ Li,017 PSAY QEP_LOJFOR
			@ Li,022 PSAY QEP_PRODUT
			@ Li,053 PSAY QEP_DTENTR
			@ Li,066 PSAY QEP_LOTE
			@ Li,084 PSAY QEP_ERRO
			Li++
			dbSkip()

		EndDo
	Endif
	if mv_par01 == 1 .or. mv_par01 == 3
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Imprime as entradas em Skip-Lote 							 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		//01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
		//          1         2         3         4         5         6         7         8         9        10
		//Fornecedor          Loja  Produto          Data Entrada  Lote
		cCabec1 := STR0076 //"Fornecedor          Loja  Produto          Data Entrada  Lote"
		cCabec2 := " "
		Li      := 80
		m_Pag   := 01

		dbSelectArea("QEP")
		dbSetOrder(1)
		MsSeek(xFilial("QEP")+"1")
		While !Eof() .And. QEP_FILIAL == xFilial("QEP") .And. QEP_CODTAB == "1"
			If lEnd
				@PROW()+1,001 PSAY STR0077 //"CANCELADO PELO OPERADOR"
				Exit
			Endif

			If QEP->QEP_ERRO # cAprv .Or. QEP->QEP_EXCLUI == "S" .Or. QEP->QEP_IMPFIC == "S" .or. ;
					QEP->QEP_FORNEC < mv_par02 .or. QEP->QEP_FORNEC > mv_par03 .or. QEP->QEP_PRODUT < mv_par04 .or. ;
					QEP->QEP_PRODUT > mv_par05 .or. dtos(QEP->QEP_DTENTR) < dtos(mv_par06) .or. dtos(QEP->QEP_DTENTR) > dtos(mv_par07)
				dbSkip()
				Loop
			EndIf

			IncRegua()

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Impressao do Cabecalho										 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Li > 58
				Cabec(STR0078,cCabec1,cCabec2,cNomeProg,cTamanho,nTipo,,.F.) //"Entradas em Skip-Lote"
				Li++
			Endif

			@ Li,000 PSAY QEP_FORNEC
			@ Li,020 PSAY QEP_LOJFOR
			@ Li,026 PSAY QEP_PRODUT
			@ Li,043 PSAY QEP_DTENTR
			@ Li,057 PSAY QEP_LOTE
			Li++

			dbSkip()

		EndDo
	Endif
	If mv_par01 == 1 .or. mv_par01 == 4
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Imprime as entradas a Inspecionar 							 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		//01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
		//          1         2         3         4         5         6         7         8         9        10
		//Fornecedor          Loja  Produto          Data Entrada  Lote
		cCabec1 := STR0079 //"Fornecedor          Loja  Produto          Data Entrada  Lote"
		cCabec2 := " "
		Li      := 80
		m_Pag   := 01

		dbSelectArea("QEP")
		dbSetOrder(1)
		MsSeek(xFilial("QEP")+"1")

		While !Eof() .And. QEP_FILIAL == xFilial("QEP") .And. QEP_CODTAB == "1"
			If lEnd
				@PROW()+1,001 PSAY STR0016	//"CANCELADO PELO OPERADOR"
				Exit
			Endif

			If QEP->QEP_ERRO == cAprv .Or. QEP->QEP_EXCLUI == "S" .Or. QEP->QEP_IMPFIC == "S" .or. ;
					QEP->QEP_FORNEC < mv_par02 .or. QEP->QEP_FORNEC > mv_par03 .or. QEP->QEP_PRODUT < mv_par04 .or. ;
					QEP->QEP_PRODUT > mv_par05 .or. dtos(QEP->QEP_DTENTR) < dtos(mv_par06) .or. dtos(QEP->QEP_DTENTR) > dtos(mv_par07)
				dbSkip()
				Loop
			EndIf

			IncRegua()

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Impressao do Cabecalho										 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Li > 58
				Cabec(STR0080,cCabec1,cCabec2,cNomeProg,cTamanho,nTipo,,.F.) //"Entradas a Inspecionar"
				Li++
			Endif

			@ Li,000 PSAY QEP_FORNEC
			@ Li,020 PSAY QEP_LOJFOR
			@ Li,026 PSAY QEP_PRODUT
			@ Li,043 PSAY QEP_DTENTR
			@ Li,057 PSAY QEP_LOTE
			Li++

			dbSkip()

		EndDo
	Endif
	If mv_par01 == 1 .or. mv_par01 == 5

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Imprime as entradas excluidas pela importacao ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		//01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
		//          1         2         3         4         5         6         7         8         9        10
		//Fornecedor          Loja  Produto          Data Entrada  Lote
		cCabec1 := STR0081 //"Fornecedor          Loja  Produto          Data Entrada  Lote"
		cCabec2 := " "
		Li      := 80
		m_Pag   := 01

		dbSelectArea("QEP")
		dbSetOrder(1)
		MsSeek(xFilial("QEP")+"1")
		While !Eof() .And. QEP_FILIAL == xFilial("QEP") .And. QEP_CODTAB == "1"
			If lEnd
				@PROW()+1,001 PSAY STR0082 //"CANCELADO PELO OPERADOR"
				Exit
			Endif

			If QEP->QEP_EXCLUI # "S"  .Or. QEP->QEP_IMPFIC == "S" .or. ;
					QEP->QEP_FORNEC < mv_par02 .or. QEP->QEP_FORNEC > mv_par03 .or. QEP->QEP_PRODUT < mv_par04 .or. ;
					QEP->QEP_PRODUT > mv_par05 .or. dtos(QEP->QEP_DTENTR) < dtos(mv_par06) .or. dtos(QEP->QEP_DTENTR) > dtos(mv_par07)
				dbSkip()
				Loop
			EndIf

			IncRegua()

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Impressao do Cabecalho										 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Li > 58
				Cabec(STR0083,cCabec1,cCabec2,cNomeProg,cTamanho,nTipo,,.F.) //"Entradas excluidas"
				Li++
			Endif

			@ Li,000 PSAY QEP_FORNEC
			@ Li,020 PSAY QEP_LOJFOR
			@ Li,026 PSAY QEP_PRODUT
			@ Li,043 PSAY QEP_DTENTR
			@ Li,057 PSAY QEP_LOTE
			Li++

			dbSkip()

		EndDo
	Endif
	If Li != 80
		Roda(CbCont,cbtxt)
	EndIf

	Set device to Screen
	If aReturn[5] == 1
		Set Printer To
		dbCommitAll()
		OurSpool(wnrel)
	Endif

	MS_FLUSH()

Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Q183Ficha  ³ Autor ³Paulo Emidio de Barros³ Data ³04/06/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Realiza a chamada para Impressao das Fichas de Produtos Ins³±±
±±³ 		 ³ pecionados.												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q183Ficha()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIEA183													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q183Ficha()
	Local aAreaAnt := GetArea()
	Local aSX1

	aSX1 := QA_SaveSX1() //Salva as perguntas

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Ponto de entrada para personalizar a rotina de impressao da ficha³
    //³ de produto.                                                      ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock("QIE183EN")
		ExecBlock("QIE183EN",.F.,.F.,{"QIEA200"})
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Funcao que imprime as fichas dos produtos para todas as entradas ³
		//³ marcadas para inspecao.                                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		QIER220("QIEA200")
	EndIf

	RestArea(aAreaAnt)

	QA_RestSX1(aSX1)

Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Q183DelFic ³ Autor ³Paulo Emidio de Barros³ Data ³13/08/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Exclui as Entradas com Ficha Produto impressa, ou Certifi- ³±±
±±³ 		 ³ cadas.													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q183DelFic()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIEA183													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q183DelFic()
	Local aTam       := TamSX3("QEP_ERRO")
	Local cCertifica := "A"+Space(aTam[1]-1)

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Exclui a Entradas referentes a importacao anterior, se a Ficha do³
    //³ produto foi impressa, ou se a Entrada foi certificada.			 ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("QEP")
	dbSetOrder(1)
	If dbSeek(xFilial("QEP")+"1")
		While !Eof() .And. (QEP_FILIAL+QEP_CODTAB) == (xFilial("QEP")+"1")
			If (QEP->QEP_IMPFIC == "S") .Or. (QEP->QEP_ERRO == cCertifica) .Or.;
					(QEP->QEP_EXCLUI == "S")
				RecLock("QEP",.F.)
				dbDelete()
				MsUnLock()
			EndIf
			dbSkip()
		EndDo
	Endif

Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³Q183Legend³ Autor ³Paulo Emidio de Barros ³ Data ³20/08/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Define as Legendas utilizadas nas Entradas				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Q183Legend()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ NENHUM													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ NIL														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIEA183													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q183Legend()
	Local aLegenda := {}

	If mv_par01 == 1
		Aadd(aLegenda,{"BR_AMARELO", OemToAnsi(STR0058)}) //"Pendente para Importacao Normal"
		Aadd(aLegenda,{"BR_VERMELHO",OemToAnsi(STR0061)}) //"Importacao realizada com Inconsistencia"
	Else
		Aadd(aLegenda,{"BR_AMARELO", OemToAnsi(STR0060)}) //"Pendente para Importacao TXT"
		Aadd(aLegenda,{"BR_VERMELHO",OemToAnsi(STR0061)}) //"Importacao realizada com Inconsistencia"
	EndIf

	BrwLegenda(cCadastro,STR0062,aLegenda) //"Importacao das Entradas"
Return(NIL)

/* {Protheus.doc} Q183OpenTx
Retorna a Estrutura do layout de Importacao TXT.
@author Paulo Emidio de Barros
@since 23/04/2003
@return aEstrutura, Array, Estrutura do Layout de Importacao TXT
*/
Function Q183OpenTxt()

	Local aCampos  := {"QEP_NTFISC", "QEP_TAMLOT", "QEP_PRECO", "QEP_TAMAMO", "QEP_LOTORI"}
	Local aCpoErro := {}
	Local aCpoTxt  := {}
	Local aStruTxt := {}
	Local cCampos  := ""
	Local cCpoOri  := ""
	Local cCpoPad  := ""
	Local lLayout  := .F. // Sinaliza inconsistencia de tamanho de campo no IMPORT.IMP vs SX3
	Local nBytes   := 0
	Local nCampo   := 0
	Local nHandle  := 0
	Local nP001    := 0
	Local nP002    := 0
	Local nP003    := 0
	Local nP004    := 0
	Local nP005    := 0
	Local nP006    := 0
	Local nP007    := 0
	Local nP008    := 0
	Local nP009    := 0
	Local nP010    := 0
	Local nP011    := 0
	Local nP012    := 0
	Local nP013    := 0
	Local nP014    := 0
	Local nP015    := 0
	Local nP016    := 0
	Local nP017    := 0
	Local nP018    := 0
	Local nP019    := 0
	Local nP020    := 0
	Local nPosFin  := 0
	Local nPosIni  := 0
	Local nTamArq  := 0
	Local nTamCpo  := 0
	Local nTamLin  := 0
	Local xBuffer  := NIL

	cCpoPad  := "QEP_FORNEC,QEP_LOJFOR,QEP_PRODUT,QEP_DTENTR,QEP_HRENTR,QEP_LOTE,QEP_DOCENT,QEP_TAMLOT,QEP_TAMAMO"
	cCpoPad  += ",QEP_PEDIDO,QEP_NTFISC,QEP_SERINF,QEP_DTNFIS,QEP_TIPDOC,QEP_CERFOR,QEP_DIASAT,QEP_SOLIC,QEP_PRECO,QEP_EXCLUI"

    //Verifica o caminho para gravacao do layout padrao,caso o mesmo nao exista
	If !File("IMPORT.IMP")

		//Atribindo valores para as posição a serem utilizadas na montagem do layout.
		nP001:= GetSx3Cache("QEP_FORNEC","X3_TAMANHO")
		nP002:= nP001+GetSx3Cache("QEP_LOJFOR","X3_TAMANHO")
		nP003:= nP002+GetSx3Cache("QEP_PRODUT","X3_TAMANHO")
		nP004:= nP003+GetSx3Cache("QEP_DTENTR","X3_TAMANHO")
		nP005:= nP004+GetSx3Cache("QEP_HRENTR","X3_TAMANHO")
		nP006:= nP005+GetSx3Cache("QEP_LOTE  ","X3_TAMANHO")
		nP007:= nP006+GetSx3Cache("QEP_DOCENT","X3_TAMANHO")
		nP008:= nP007+GetSx3Cache("QEP_TAMLOT","X3_TAMANHO")
		nP009:= nP008+GetSx3Cache("QEP_TAMAMO","X3_TAMANHO")
		nP010:= nP009+GetSx3Cache("QEP_PEDIDO","X3_TAMANHO")
		nP011:= nP010+GetSx3Cache("QEP_NTFISC","X3_TAMANHO")
		nP012:= nP011+GetSx3Cache("QEP_SERINF","X3_TAMANHO")
		nP013:= nP012+GetSx3Cache("QEP_ITEMNF","X3_TAMANHO")
		nP014:= nP013+GetSx3Cache("QEP_DTNFIS","X3_TAMANHO")
		nP015:= nP014+GetSx3Cache("QEP_TIPDOC","X3_TAMANHO")
		nP016:= nP015+GetSx3Cache("QEP_CERFOR","X3_TAMANHO")
		nP017:= nP016+GetSx3Cache("QEP_DIASAT","X3_TAMANHO")
		nP018:= nP017+GetSx3Cache("QEP_SOLIC ","X3_TAMANHO")
		nP019:= nP018+GetSx3Cache("QEP_PRECO ","X3_TAMANHO")
		nP020:= nP019+GetSx3Cache("QEP_EXCLUI","X3_TAMANHO")

		//Montagem das posições para a geração do layout padrao do arquivo de Importacao com base no tamanho dos campos na SX3
		Aadd(aCpoTxt,"0001"+STRZERO((nP001),4)+"QEP_FORNEC")
		Aadd(aCpoTxt,STRZERO(nP001+1,4)+STRZERO(nP002,4)+"QEP_LOJFOR")
		Aadd(aCpoTxt,STRZERO(nP002+1,4)+STRZERO(nP003,4)+"QEP_PRODUT")
		Aadd(aCpoTxt,STRZERO(nP003+1,4)+STRZERO(nP004,4)+"QEP_DTENTR")
		Aadd(aCpoTxt,STRZERO(nP004+1,4)+STRZERO(nP005,4)+"QEP_HRENTR")
		Aadd(aCpoTxt,STRZERO(nP005+1,4)+STRZERO(nP006,4)+"QEP_LOTE  ")
		Aadd(aCpoTxt,STRZERO(nP006+1,4)+STRZERO(nP007,4)+"QEP_DOCENT")
		Aadd(aCpoTxt,STRZERO(nP007+1,4)+STRZERO(nP008,4)+"QEP_TAMLOT")
		Aadd(aCpoTxt,STRZERO(nP008+1,4)+STRZERO(nP009,4)+"QEP_TAMAMO")
		Aadd(aCpoTxt,STRZERO(nP009+1,4)+STRZERO(nP010,4)+"QEP_PEDIDO")
		Aadd(aCpoTxt,STRZERO(nP010+1,4)+STRZERO(nP011,4)+"QEP_NTFISC")
		Aadd(aCpoTxt,STRZERO(nP011+1,4)+STRZERO(nP012,4)+"QEP_SERINF")
		Aadd(aCpoTxt,STRZERO(nP012+1,4)+STRZERO(nP013,4)+"QEP_ITEMNF")
		Aadd(aCpoTxt,STRZERO(nP013+1,4)+STRZERO(nP014,4)+"QEP_DTNFIS")
		Aadd(aCpoTxt,STRZERO(nP014+1,4)+STRZERO(nP015,4)+"QEP_TIPDOC")
		Aadd(aCpoTxt,STRZERO(nP015+1,4)+STRZERO(nP016,4)+"QEP_CERFOR")
		Aadd(aCpoTxt,STRZERO(nP016+1,4)+STRZERO(nP017,4)+"QEP_DIASAT")
		Aadd(aCpoTxt,STRZERO(nP017+1,4)+STRZERO(nP018,4)+"QEP_SOLIC ")
		Aadd(aCpoTxt,STRZERO(nP018+1,4)+STRZERO(nP019,4)+"QEP_PRECO ")
		Aadd(aCpoTxt,STRZERO(nP019+1,4)+STRZERO(nP020,4)+"QEP_EXCLUI")

		nHandle := fCreate("IMPORT.IMP")
		Aeval(aCpoTxt,{|x|cString:=x+Chr(13)+Chr(10),fWrite(nHandle,cString)})
	Else
		nHandle := fOpen("IMPORT.IMP",2+64)
	EndIf

    //Posiciona no arquivo
	nTamArq := fSeek(nHandle,0,2)
	nTamLin := 20
	fSeek(nHandle,0,0)

	While nBytes < nTamArq
		xBuffer := Space(nTamLin)
		fRead(nHandle,@xBuffer,nTamLin)

		cCpoOri := AllTrim(SubStr(xBuffer,9,10)) //Campo a receber o Valor
		nPosFin := Val(SubStr(xBuffer,5,4)) //Posicao Final
		nPosIni := Val(SubStr(xBuffer,1,4)) //Posicao Inicial
		nTamCpo := nPosFin - nPosIni + 1

		// Valida tamanho dos campos do IMPORT.IMP vs SX3.
		// Caso inconsistente: alerta o usuario e barra a importacao.
		For nCampo := 1 To Len(aCampos)
			If cCpoOri $ aCampos[nCampo] .AND. nTamCpo <> GetSx3Cache(aCampos[nCampo], "X3_TAMANHO")
				Aadd(aCpoErro, cCpoOri)
				lLayout := .T.
				Exit
			EndIf
		Next 

		Aadd(aStruTxt,{nPosIni,nPosFin,cCpoOri})
		//Verifica campos incluidos pelo usuario.
		If !(Alltrim(cCpoOri)$cCpoPad)
			Aadd(aCpoUsu,Substr(Alltrim(cCpoOri),5,10))
		EndIf
		nBytes+=nTamLin
	EndDo

    //Fecha o arquivo de configuracao
	fClose(nHandle)

	// Se algum campo (QEP_NTFISC, QEP_TAMLOT ou QEP_PRECO) estava com
	// tamanho inconsistente no IMPORT.IMP, retorna NIL para não gerar o arquivo
	If lLayout
		AEVAL(aCpoErro, {|x| cCampos += x + CHR(13)+CHR(10)})
		// STR0089 - A configuração da estrutura do arquivo de importação está inconsistente. Verifique 'Início', 'Fim' e o tamanho dos campos: 
		// STR0090 - Regenere o arquivo IMPORT.IMP através da rotina Miscelânea->Administração de Texto (QIEM100).
		Help("",1,"QIEA183TamSX3",,STR0089 + cCampos ,1,0,,,,,,{STR0090})
		Return NIL
	EndIf

Return(aStruTxt)

/*/{Protheus.doc} QIE183MQ
Função genérica para retornar o alias com os registros da tabela QEP que estão inconsistentes

@type  Function
@author thiago.rover
@since 05/08/2025
@return cAlias, caracter, retorna o alias da área de consulta
/*/
Function QIE183MQ()

	Local aBindParam   := {}
	Local cQuery       := ""
	Local lChangeQuery := .F.

	cQuery := " SELECT * "
	cQuery += " FROM "+RetSqlName("QEP")+" QEP "

	aAdd(aBindParam, {'2', "S"})
	aAdd(aBindParam, {' ', "S"})
	cQuery += " WHERE QEP.QEP_CODTAB = ? "
	cQuery +=   " AND QEP.D_E_L_E_T_ = ?"
	cQuery += " ORDER BY "+SqlOrder(QEP->(IndexKey()))
	cQuery := ChangeQuery(cQuery)
	
Return QLTQueryManager():executeQueryWithBind(cQuery, aBindParam, lChangeQuery)

/*/{Protheus.doc} SeekQEP183
Realiza busca otimizada na QEP usando a chave do indice 2 via QLTQueryManager():dbSeek().
@type  Function
@author willian.ramalho
@since 16/06/2026
@param 01 cCodTab, caracter, Codigo da tabela 	  - (QEP_CODTAB)
@param 02 cFornec, caracter, Fornecedor 	  	  - (QEP_FORNEC)
@param 03 cLojFor, caracter, Loja do fornecedor   - (QEP_LOJFOR)
@param 04 cProdut, caracter, Produto 			  - (QEP_PRODUT)
@param 05 cNtFisc, caracter, Nota fiscal 		  - (QEP_NTFISC)
@param 06 cSerInf, caracter, Serie da nota fiscal - (QEP_SERINF)
@param 07 cItemNF, caracter, Item da NF 		  - (QEP_ITEMNF) - opcional
@param 08 cTipoNF, caracter, Tipo da NF 		  - (QEP_TIPONF) - opcional
@param 09 dDtEntr, data    , Data de entrada      - (QEP_DTENTR) em data AdvPL ou AAAAMMDD - opcional
@param 10 cLote  , caracter, Lote 			      - (QEP_LOTE) - opcional
@param 11 cNumSeq, caracter, Numero sequencial    - (QEP_NUMSEQ) - opcional
@return lFound, logico, .T. se localizar registro conforme filtros; .F. caso contrario
/*/
Function SeekQEP183 (cCodTab, cFornec, cLojFor, cProdut, cNtFisc, cSerInf, cItemNF, cTipoNF, dDtEntr, cLote, cNumSeq)

	Local aWhereExtra := {}
	Local lFound      := .F.
	Local oQLtQuery:= QLTQueryManager():New()

	// Ordem da chave do indice 2 (apos filial, que ja e tratada no dbSeek):
	// QEP_CODTAB + QEP_FORNEC + QEP_LOJFOR + QEP_PRODUT + QEP_NTFISC + QEP_SERINF + QEP_ITEMNF + QEP_TIPONF + DTOS(QEP_DTENTR) + QEP_LOTE + QEP_NUMSEQ

	aAdd(aWhereExtra, {" QEP_CODTAB = ? ", {{cCodTab, "S"}}})
	aAdd(aWhereExtra, {" QEP_FORNEC = ? ", {{cFornec, "S"}}})
	aAdd(aWhereExtra, {" QEP_LOJFOR = ? ", {{cLojFor, "S"}}})
	aAdd(aWhereExtra, {" QEP_PRODUT = ? ", {{cProdut, "S"}}})
	aAdd(aWhereExtra, {" QEP_DTENTR = ? ", {{DtoS(dDtEntr), "S"}}})
	aAdd(aWhereExtra, {" QEP_NTFISC = ? ", {{cNtFisc, "S"}}})
	aAdd(aWhereExtra, {" QEP_SERINF = ? ", {{cSerInf, "S"}}})
	aAdd(aWhereExtra, {" QEP_ITEMNF = ? ", {{cItemNF, "S"}}})
	aAdd(aWhereExtra, {" QEP_NUMSEQ = ? ", {{cNumSeq, "S"}}})
	aAdd(aWhereExtra, {" QEP_TIPONF = ? ", {{cTipoNF, "S"}}})
	aAdd(aWhereExtra, {" QEP_LOTE   = ? ", {{cLote  , "S"}}})

	// O dbSeek interno ja aplica QEP_FILIAL (xFilial) e D_E_L_E_T_ = ' '.
	lFound := oQLtQuery:dbSeek("QEP", "", aWhereExtra)

Return lFound

