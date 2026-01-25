#Include "WMSR459.ch"
#Include "Protheus.ch"

//-----------------------------------------------------------
/*/{Protheus.doc} WMSR459
Relação de Movimentos por Remito de Transferência Mercado internacional
@author  Roselaine Adriano
@version	P12
@since   09/10/2022
/*/
//-----------------------------------------------------------
Function WMSR459()
Local oReport
	If !SuperGetMV("MV_WMSNEW", .F., .F.)
		Return ( Nil )
	EndIf

	If cPaisLoc == 'BRA'
    	Return ( Nil )
	EndIf 

	// Interface de Impressão
	oReport:= ReportDef()
	oReport:PrintDialog()
Return( Nil )
//-----------------------------------------------------------
// Definições do relatório
//-----------------------------------------------------------
Static Function ReportDef()
Local oReport, oSection1, oSection2, oSection3
Local cPictQtd   := PesqPict("D12","D12_QTDMOV")
Local cAliasRel  := GetNextAlias()

	// Criacao do componente de impressao
	oReport := TReport():New("WMSR459",STR0001,"WMSR459",{|oReport| ReportPrint(oReport,cAliasRel)},".") // "Relatório Separação Remito Transferência"
	oReport:SetColSpace(2)
	oReport:lParamPage := .F.
	
	//quando executado através do Mata462TN os perguntes já virão preenchidos com o documento 
	If !FWIsIncallStack('MATA462TN')
		Pergunte(oReport:uParam,.T.)
	EndIf 
	
	// Seção 1 - Movimentos por Remito de Transferência
	oSection1:= TRSection():New(oReport,STR0002,{"D12"},,,,,,,,,,,.T.,3) // "Remito de Transferência."
	TRCell():New(oSection1,"D12_DOC","D12") 
	TRCell():New(oSection1,"D12_SERIE","D12")
	
	// Seção 2 - Movimentos por endereco - Endereco
	oSection2:= TRSection():New(oSection1,STR0003,{"D12","SB1"},,,,,,,,,,,.F.,0) // Movimentos por Documento
	TRCell():New(oSection2,"D12_LOCORI","D12")
	TRCell():New(oSection2,"D12_ENDORI","D12")
    TRCell():New(oSection2,"D12_LOCDES","D12")
    TRCell():New(oSection2,"D12_ENDDES","D12")
	TRCell():New(oSection2,"D12_PRODUT","D12")
	TRCell():New(oSection2,"B1_DESC"   ,"SB1")
	TRCell():New(oSection2,"D12_LOTECT","D12")
	TRCell():New(oSection2,"D12_NUMLOT","D12")
	TRCell():New(oSection2,"NCAIXAFC"  ,/*Alias*/, STR0004  ,"@E 999,999,999",/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,"RIGHT",,"RIGHT")  // Segunda UM
	TRCell():New(oSection2,"B1_SEGUM"  ,"SB1"    ,/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,,,,,/*nColSpace*/ 1)
	TRCell():New(oSection2,"NUNIDADE"  ,/*Alias*/, STR0005  , cPictQtd  ,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,"RIGHT",,"RIGHT")  // Unidades
	TRCell():New(oSection2,"B1_UM"     ,"SB1"    ,/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,,,,,/*nColSpace*/ 1)
	
	// Seção 3 - Movimentos por endereco - Recurso Humano
	oSection3:= TRSection():New(oSection1,STR0006,{"D12"},{'1'}) // "Movimentos por Remito de Transferência - Recurso Humano "
	TRCell():New(oSection3,"SEPARADOR", "",STR0007,,55,,{||" _______________________   ___:___   ___:___"}) // Separador :
	TRCell():New(oSection3,"CONFERENTE","",STR0008,,55,,{||" _______________________   ___:___   ___:___"}) // Conferente :
	oSection3:SetLineStyle(.F.)
	oSection3:SetCharSeparator("")

	// Esconde o título da 1a e 2a UM
	oSection2:Cell('B1_UM'   ):HideHeader()
	oSection2:Cell('B1_SEGUM'):HideHeader()

	// Posicionamento das tabelas secundárias na impressão do relatório
	TRPosition():New(oSection1,"D12",1,{|| xFilial("D12")+(cAliasRel)->D12_DOC  })

Return( oReport )
//-----------------------------------------------------------
// Impressão do relatório
//-----------------------------------------------------------
Static Function ReportPrint(oReport,cAliasRel)
Local oSection1 := oReport:Section(1)
Local oSection2 := oSection1:Section(1)
Local oSection3 := oSection1:Section(2)
Local cSeekQry  := ""
Local bSeekQry  := {||.T.}
Local nCaixaFc  := 0
Local nUnidade  := 0
   
	oSection1:BeginQuery()
	BeginSql Alias cAliasRel
	  SELECT 	D12.D12_SERIE,
	  			D12.D12_LOCORI,
				D12.D12_ENDORI,
				D12.D12_LOCDES,
				D12.D12_ENDDES,
				D12.D12_DOC,
				D12.D12_QTDMOV,
				D12.D12_PRODUT,
				D12.D12_LOTECT,
				D12.D12_NUMLOT,
				D12.D12_ATUEST,
				D12.R_E_C_N_O_ RECNOD12,
				SB1.B1_DESC, 
				SB1.B1_UM, 
				SB1.B1_SEGUM, 
				SB1.B1_CONV, 
				SB5.B5_UMIND 
		FROM %table:SD2% SD2
		INNER JOIN %Table:D12% D12
		ON D12.D12_FILIAL =  %xFilial:D12%
		AND D12.D12_ORIGEM = 'SD2'
		AND D12.D12_DOC = SD2.D2_DOC
		AND D12.D12_SERIE = SD2.D2_SERIE
		AND D12.D12_SERVIC = SD2.D2_SERVIC
		AND D12.D12_LOCORI  = SD2.D2_LOCAL
		AND D12.D12_ATUEST = '1'
		AND D12.D12_STATUS = '1'
		AND D12.%NotDel%
		INNER JOIN %Table:DCF% DCF
		ON DCF.DCF_FILIAL = %xFilial:DCF%
		AND DCF.DCF_ID = D12.D12_IDDCF
		AND DCF.DCF_STSERV = '3'
		AND DCF.DCF_NUMSEQ = D12.D12_NUMSEQ
		AND DCF.%NotDel%
		INNER JOIN %table:SB1% SB1
			 ON SB1.B1_FILIAL = %xFilial:SB1%
			AND SB1.B1_COD = D12.D12_PRODUT
			AND SB1.%NotDel%
		INNER JOIN %table:SB5% SB5
			 ON SB5.B5_FILIAL = %xFilial:SB5%
			AND SB5.B5_COD = D12.D12_PRODUT
			AND SB5.%NotDel%
		INNER JOIN %table:SBE% SBE
			ON SBE.BE_FILIAL  = %xFilial:SBE%
		  AND SBE.BE_LOCAL   = D12.D12_LOCORI
		  AND SBE.BE_LOCALIZ = D12.D12_ENDORI
		  AND SBE.%NotDel%
		 WHERE SD2.D2_FILIAL = %xFilial:SD2%
			AND SD2.D2_DOC BETWEEN %Exp:mv_par01% AND %Exp:mv_par02%
			AND SD2.D2_SERIE BETWEEN %Exp:mv_par03% AND %Exp:mv_par04%
 			AND SD2.%NotDel%
	EndSql

	// EndQuery (Classe TRSection) - Prepara o relatório para executar o Embedded SQL
	oSection1:EndQuery(/*Array com os parametros do tipo Range*/)

	// Define que a seção filha utiliza a query da seção pai na impressão da seção
	oSection2:SetParentQuery()

	// Fluxo de impressão do relatório
	oReport:SetMeter((cAliasRel)->(LastRec()))

	While !oReport:Cancel() .And. !(cAliasRel)->(Eof())

		oSection1:Init()

		// Início da impressão das informações do mapa de separação e documento
		oSection1:Cell('D12_DOC'):SetValue((cAliasRel)->D12_DOC)
        oSection1:Cell('D12_SERIE'):SetValue((cAliasRel)->D12_SERIE)

		// DEverá agrupar pelo numero do documento 
		cSeekQry := (cAliasRel)->D12_DOC+(cAliasRel)->D12_SERIE
		bSeekQry := &("{|| cSeekQry == (cAliasRel)->D12_DOC+"+"(cAliasRel)->D12_SERIE}")
		
		oSection1:PrintLine()
		
		oSection2:Init()
		While !oReport:Cancel() .And. (cAliasRel)->(!Eof()) .And. Eval(bSeekQry)
			If (cAliasRel)->B5_UMIND == "1"
				nCaixaFc := 0
				nUnidade := (cAliasRel)->D12_QTDMOV
			Else
				If !Empty((cAliasRel)->B1_CONV)
					nCaixaFc := Int(ConvUM((cAliasRel)->D12_PRODUT,(cAliasRel)->D12_QTDMOV,0,2))
					nUnidade := (cAliasRel)->D12_QTDMOV - ConvUM((cAliasRel)->D12_PRODUT,0,nCaixaFc,1)
				Else
					nCaixaFc := (cAliasRel)->D12_QTDMOV
					nUnidade := 0
				EndIf
			EndIf
			oSection2:Cell("NCAIXAFC"):SetValue(nCaixaFc)
			oSection2:Cell("NUNIDADE"):SetValue(nUnidade)

			// Somente imprime a atividade que movimenta estoque
			oSection2:PrintLine()
			
			oReport:IncMeter()
			(cAliasRel)->(DbSkip())
		EndDo
		oSection2:Finish()
		oSection3:Init()
		oSection3:PrintLine()
		oSection3:Finish()
		oSection1:Finish()
		oReport:EndPage()
	EndDo
Return( Nil )
