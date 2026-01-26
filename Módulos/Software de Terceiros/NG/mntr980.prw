#Include "MNTR980.ch"
#Include "Protheus.ch"

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTR980
Relatorio de Documentos Pagos no Período
@author Rafael Diogo Richter
@since 22/03/2007
@version undefined
@type function
@obs uso SigaMNT
/*/
//---------------------------------------------------------------------
Function MNTR980()

	Local WNREL       := "MNTR980"
	Local cDESC1      :=	STR0001+; //"O relatório permitirá filtrar por documento, filial, período e UF. Totalizará os valores "
							STR0002   //"Pagos"
	Local cDESC2      := ""
	Local cDESC3      := ""
	Local cSTRING     := "TS2"

	Private cCadastro := OemtoAnsi(STR0003) //"Relatório de Documentos Pagos no Período"
	Private cPerg     := "MNR980"
	Private aPerg     := {}
	Private NOMEPROG  := "MNTR980"
	Private TAMANHO   := "G"
	Private aRETURN   := {STR0004,1,STR0005,1,2,1,"",1} //"Zebrado"###"Administracao"
	Private TITULO    := STR0003 //"Relatório de Documentos Pagos no Período"
	Private nTIPO     := 0
	Private nLASTKEY  := 0
	Private CABEC1
	Private CABEC2
	Private aVETINR   := {}
	Private lFilial
	Private lGera     := .T.
	Private cTRB	:= GetNextAlias()

	SetKey( VK_F9, { | | NGVersao( "MNTR980" , 2 ) } )

	//+----------------------------------------------------------------------+
	//| Tabelas   | TS0 - Documentos                                         |
	//|           | TS1 - Doctos Obrigatorios por Veiculo                    |
	//|           | TS2 - Documentos a Pagar                                 |
	//|           | TS8 - Honorarios de Despachante                          |
	//|           | SA2 - Fornecedores                                       |
	//|           | TS4 - Servicos Despachantes                              |
	//|           | ST9 - Bens												 |
	//+----------------------------------------------------------------------+

	Pergunte(cPERG,.F.)

	//+--------------------------------------------------------------+
	//| Envia controle para a funcao SETPRINT                        |
	//+---------------------------------------------------------------+
	WNREL:=SetPrint(cSTRING,WNREL,cPERG,TITULO,cDESC1,cDESC2,cDESC3,.F.,"")
	If nLASTKEY = 27
		Set Filter To
		DbSelectArea("TS2")
		Return
	EndIf
	SetDefault(aReturn,cSTRING)
	Processa({|lEND| MNTR980IMP(@lEND,WNREL,TITULO,TAMANHO)},STR0014) //"Processando Registros..."
	Dbselectarea("TS2")

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTR980Imp
Chamada do Relatório
@author Rafael Diogo Richter
@since 22/03/2007
@version undefined
@param lEND, logical, descricao
@param WNREL, , descricao
@param TITULO, , descricao
@param TAMANHO, , descricao
@type function
@obs uso MNTR980
/*/
//---------------------------------------------------------------------
Function MNTR980Imp(lEND,WNREL,TITULO,TAMANHO)

	Local nAcu := 0
	Local oTempTable 	//Tabela Temporaria
	Local nSizeFil := IIf(FindFunction("FWSizeFilial"), FwSizeFilial(), Len(TS2->TS2_FILIAL))

	Private cFil     := ""
	Private cFornec  := ""
	Private cServic  := ""
	Private lFirst   := .T.
	Private li       := 80
	Private m_pag    := 1
	Private cRODATXT := ""
	Private nCNTIMPR := 0
	Private nQtd := 0

	aDBF :=	{{"FILIAL"	, "C", nSizeFil,0},;
			 {"DOCTO"	, "C", 06,0},;
			 {"DTEMIS"	, "D", 08,0},;
			 {"PLACA"	, "C", 08,0},;
			 {"CODBEM"	, "C", 16,0},;
			 {"NOMBEM"	, "C", 30,0},;
			 {"UF"		, "C", 02,0},;
			 {"PARCEL"	, "C", 01,0},;
			 {"DTPGTO"	, "D", 08,0},;
			 {"DTVENC"	, "D", 08,0},;
			 {"NOTFIS"	, "C", 06,0},;
			 {"VALDOC"	, "N", 09,2},;
			 {"DTPGFO"	, "D", 08,0},;
			 {"DTEMFO"	, "D", 08,0},;
			 {"FORNEC"	, "C", TAMSX3("A2_COD")[1],0},;
			 {"NOMFOR"	, "C", 30,0},;
			 {"LOJA"	, "C", TAMSX3("A2_LOJA")[1],0},;
			 {"CODSER"	, "C", 06,0},;
			 {"NOMSER"	, "C", 30,0},;
			 {"VALFOR"	, "N", 09,2}}

	//Intancia classe FWTemporaryTable
	oTempTable  := FWTemporaryTable():New( cTRB, aDBF )
	//Cria indices
	oTempTable:AddIndex( "Ind01" , {"FILIAL","FORNEC","CODSER","CODBEM","DOCTO","DTVENC"} )
	//Cria a tabela temporaria
	oTempTable:Create()

	MsgRun(OemToAnsi(STR0016),OemToAnsi(STR0017),{|| MNTR980TMP()}) //"Processando Arquivo..."###"Aguarde"

	If !lGera
		oTempTable:Delete()//Deleta Tabela Temporaria
		Return .F.
	Endif
	/*
	0         1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6         7
	012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
	***************************************************************************************************************************************************************************
	Docto.  Dt.Emissão  Placa     Bem               Nome                            UF  Parc.  Dt.Pgto.    Dt.Venc.    NF           Valor
	***************************************************************************************************************************************************************************
	Filial: XX - XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

	Fornecedor: XXXXXXXX - XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  Loja: XX    Dt.Pgto: 99/99/9999

	Servico: XXXXXX - XXXXXXXXXXXXXXXXXXXXXXXXX

	XXXXXX  99/99/9999  XXXXXXXX  XXXXXXXXXXXXXXXX  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  XX      9  99/99/9999  99/99/9999  XXXXXX  999.999,99
	XXXXXX  99/99/9999  XXXXXXXX  XXXXXXXXXXXXXXXX  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  XX      9  99/99/9999  99/99/9999  XXXXXX  999.999,99
	XXXXXX  99/99/9999  XXXXXXXX  XXXXXXXXXXXXXXXX  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  XX      9  99/99/9999  99/99/9999  XXXXXX  999.999,99
	XXXXXX  99/99/9999  XXXXXXXX  XXXXXXXXXXXXXXXX  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  XX      9  99/99/9999  99/99/9999  XXXXXX  999.999,99
	XXXXXX  99/99/9999  XXXXXXXX  XXXXXXXXXXXXXXXX  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  XX      9  99/99/9999  99/99/9999  XXXXXX  999.999,99

	Total Geral:    9.999.999,99
	/*/

	Cabec1 := STR0018 //"    Docto.  Dt.Emissão  Placa     Bem               Nome                            UF  Parc.  Dt.Pgto.    Dt.Venc.    NF           Valor"
	Cabec2 := ""

	cFil := " "
	cFornec := " "
	cServic := " "
	lFirst := .T.
	dbSelectArea(cTRB)
	dbSetOrder(1)
	dbGoTop()
	ProcRegua(Reccount())
	While !Eof()
		IncProc()

		Somalinha()

		@ Li,004		Psay (cTRB)->DOCTO
		@ Li,012		Psay (cTRB)->DTEMIS
		@ Li,024		Psay (cTRB)->PLACA
		@ Li,034		Psay (cTRB)->CODBEM
		@ Li,052		Psay (cTRB)->NOMBEM
		@ Li,084		Psay (cTRB)->UF
		@ Li,092		Psay (cTRB)->PARCEL
		@ Li,095		Psay (cTRB)->DTPGFO
		@ Li,107		Psay (cTRB)->DTVENC
		@ Li,119		Psay (cTRB)->NOTFIS
		@ Li,127		Psay (cTRB)->VALDOC Picture "@E 999,999.99"

		nAcu += (cTRB)->VALDOC

		DbSelectArea(cTRB)
		DbSkip()
	End

	NgSomaLi(58)
	NgSomaLi(58)
	@ Li,109		Psay STR0019 //"Total Geral"
	@ Li,125		Psay nAcu Picture "@E 9,999,999.99"

	oTempTable:Delete()

	RODA(nCNTIMPR,cRODATXT,TAMANHO)

	// Devolve a condicao original do arquivo principal
	RetIndex("TS2")
	Set Filter To
	Set Device To Screen
	If aReturn[5] == 1
		Set Printer To
		dbCommitAll()
		OurSpool(WNREL)
	EndIf
	MS_FLUSH()

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTR980TMP
Geracao do arquivo temporario
@author Rafael Diogo Richter
@since 22/03/2007
@version undefined
@type function
@obs MNTA980
/*/
//---------------------------------------------------------------------
Function MNTR980TMP()

	Local cAlsTS2 := GetNextAlias()
	Local cJoin   := '% ' + NGMODCOMP( 'ST9', 'TS2' ) + ' AND %'

	BeginSQL Alias cAlsTS2

		COLUMN TS2_DTPGTO AS DATE
		COLUMN TS2_DTVENC AS DATE
		COLUMN TS2_DTEMIS AS DATE

		SELECT DISTINCT
			TS2.TS2_FILIAL,
			TS2.TS2_DOCTO ,
			TS2.TS2_PLACA ,
			TS2.TS2_CODBEM,
			ST9.T9_NOME   , 
			TS2.TS2_PARCEL, 
			TS2.TS2_DTPGTO, 
			TS2.TS2_DTVENC, 
			TS2.TS2_NOTFIS, 
			TS2.TS2_VALOR ,
			TS2.TS2_UFEMIS,
			TS2.TS2_DTEMIS,
			ISNULL( TS8.TS8_FORNEC, '' ) AS TS8_FORNEC,
			ISNULL( TS8.TS8_LOJA  , '' ) AS TS8_LOJA  ,
			ISNULL( TS8.TS8_SERVIC, '' ) AS TS8_SERVIC,
			ISNULL( TS4.TS4_DESCRI, '' ) AS TS8_DESCRI,
			ISNULL( TS1.TS1_FORNEC, '' ) AS TS1_FORNEC,
			ISNULL( TS1.TS1_LOJA  , '' ) AS TS1_LOJA  
		FROM
			%table:TS2% TS2
		INNER JOIN
			%table:ST9% ST9 ON
				%exp:cJoin%
				ST9.T9_CODBEM = TS2.TS2_CODBEM AND
				ST9.%NotDel%
		INNER JOIN
			%table:TS1% TS1 ON
				TS1.TS1_FILIAL = TS2.TS2_FILIAL AND
				TS1.TS1_CODBEM = TS2.TS2_CODBEM AND
				TS1.TS1_DOCTO  = TS2.TS2_DOCTO  AND
				TS1.%NotDel%
		LEFT JOIN
			%table:TS8% TS8 ON
				TS8.TS8_FILIAL = TS2.TS2_FILIAL AND
				TS8.TS8_CODBEM = TS2.TS2_CODBEM AND
				TS8.TS8_DOCTO  = TS2.TS2_DOCTO  AND
				TS8.%NotDel%
		LEFT JOIN
			%table:TS4% TS4 ON
				TS4.TS4_FILIAL = TS2.TS2_FILIAL AND
				TS4.TS4_CODSDP = TS8.TS8_SERVIC AND
				TS4.%NotDel%
		WHERE
			TS2.TS2_FILIAL BETWEEN %exp:MV_PAR03% AND %exp:MV_PAR04% AND
			TS2.TS2_DOCTO  BETWEEN %exp:MV_PAR06% AND %exp:MV_PAR07% AND
			TS2.TS2_DTPGTO BETWEEN %exp:MV_PAR01% AND %exp:MV_PAR02% AND
			TS2.TS2_DTPGTO <> ' '                                    AND
			TS2.%NotDel%

	EndSQL

	While (cAlsTS2)->( !Eof() )

		If !( !Empty( MV_PAR05 ) .And. MV_PAR05 != (cAlsTS2)->TS2_UFEMIS )

			RecLock( cTRB, .T. )

				(cTRB)->FILIAL := (cAlsTS2)->TS2_FILIAL
				(cTRB)->DOCTO  := (cAlsTS2)->TS2_DOCTO
				(cTRB)->DTEMIS := (cAlsTS2)->TS2_DTEMIS
				(cTRB)->PLACA  := (cAlsTS2)->TS2_PLACA
				(cTRB)->CODBEM := (cAlsTS2)->TS2_CODBEM
				(cTRB)->NOMBEM := SubStr( (cAlsTS2)->T9_NOME, 1, 30 )
				(cTRB)->UF	   := (cAlsTS2)->TS2_UFEMIS
				(cTRB)->PARCEL := (cAlsTS2)->TS2_PARCEL
				(cTRB)->DTPGFO := (cAlsTS2)->TS2_DTPGTO
				(cTRB)->DTVENC := (cAlsTS2)->TS2_DTVENC
				(cTRB)->NOTFIS := (cAlsTS2)->TS2_NOTFIS
				(cTRB)->VALDOC := (cAlsTS2)->TS2_VALOR
				
				If !Empty( (cAlsTS2)->TS8_FORNEC )

					(cTRB)->FORNEC := (cAlsTS2)->TS8_FORNEC
					(cTRB)->NOMFOR := SubStr( Posicione( 'SA2', 1, FWxFilial( 'SA2' ) + (cAlsTS2)->TS8_FORNEC, 'A2_NOME' ), 1, 30 )
					(cTRB)->LOJA   := (cAlsTS2)->TS8_LOJA
					(cTRB)->CODSER := (cAlsTS2)->TS8_SERVIC
					(cTRB)->NOMSER := SubStr( (cAlsTS2)->TS8_DESCRI, 1, 30 )
				
				Else

					(cTRB)->FORNEC := (cAlsTS2)->TS1_FORNEC
					(cTRB)->NOMFOR := SubStr( Posicione( 'SA2', 1, FWxFilial( 'SA2' ) + (cAlsTS2)->TS1_FORNEC, 'A2_NOME' ), 1, 30 )
					(cTRB)->LOJA   := (cAlsTS2)->TS1_LOJA

				EndIf

			MsUnLock()

		EndIf

		(cAlsTS2)->( dbSkip() )

	End

	(cAlsTS2)->( dbCloseArea() )

	dbSelectArea(cTRB)
	dbGoTop()
	If Eof()
		MsgInfo(STR0020,STR0021) //"Não existem dados para montar o Relatório!"###"Atenção!"
		(cTRB)->(dbGoTop())
		lGera := .F.
		Return .F.
	Endif

	(cTRB)->(dbGoTop())

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT980FL
Valida o parametro filial
@author Rafael Diogo Richter
@since 22/03/2007
@version undefined
@param nOpc, numeric, descricao
@type function
@obs uso MNTR980
/*/
//---------------------------------------------------------------------
Function MNT980FL(nOpc)

	If Empty(mv_par03) .And. mv_par04 = 'ZZ'
		Return .t.
	Else
		If nOpc == 1
			lRet := IIf(Empty(Mv_Par03),.t.,ExistCpo('SM0',SM0->M0_CODIGO+Mv_par03))
			If !lRet
				Return .f.
			EndIf
		EndIf

		If nOpc == 2
			lRet := IIF(ATECODIGO('SM0',SM0->M0_CODIGO+Mv_par03,SM0->M0_CODIGO+Mv_Par04,02),.T.,.F.)
			If !lRet
				Return .f.
			EndIf
		EndIf
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} SomaLinha
Controle de quebra de linha
@author Rafael Diogo Richter
@since 23/03/2007
@version undefined
@type function
@obs uso SomaLinha
/*/
//---------------------------------------------------------------------
Static function SomaLinha()

	If Li > 58
		Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
	EndIf

	If cFil != (cTRB)->FILIAL

		If lFirst
			Li++
			lFirst := .F.
		Else
			Li++
			Li++
		EndIf

		cFil := (cTRB)->FILIAL

		@ Li,000 Psay STR0022 // Filial:
		@ Li,008 Psay AllTrim( (cTRB)->FILIAL )

		dbSelectArea( 'SM0' )
		dbSetOrder( 1 )
		If msSeek( SM0->M0_CODIGO + (cTRB)->FILIAL )

			@ Li,017 Psay ' - ' + SM0->M0_FILIAL

		EndIf

	EndIf

	If cFornec != (cTRB)->FORNEC

		Li++
		Li++

		cFornec := (cTRB)->FORNEC
		cServic := ' '

		@ Li,002 Psay STR0023 // Fornecedor:
		@ Li,014 Psay AllTrim( (cTRB)->FORNEC )
		@ Li,023 Psay ' - ' + (cTRB)->NOMFOR
		@ Li,057 Psay STR0024 // Loja:
		@ Li,063 Psay (cTRB)->LOJA

	EndIf

	If cServic != (cTRB)->CODSER
		
		Li++
		Li++

		cServic := (cTRB)->CODSER

		@ Li,004 Psay STR0025 // Serviço:
		@ Li,013 Psay AllTrim( (cTRB)->CODSER )
		@ Li,020 Psay ' - ' + (cTRB)->NOMSER

		Li++

	EndIf

	Li++

Return .T.
