#INCLUDE 'MATR280.CH'
#INCLUDE "PROTHEUS.CH"

//-------------------------------------
/*/{Protheus.doc} WMSR460
Listagem do pré-inventario WMS NOVO   
@author Fagner Barreto
@since 215/04/2024
@version 1.0
/*/
//-------------------------------------
Function WMSR460()
	Local oReport

	oReport := ReportDef()
	oReport:PrintDialog()

Return

Static Function ReportDef()

	Local aOrdem	:= {}
	Local cPerg		:= "MTR280"
	Local oReport
	Local oCell
	Local oSection

	aOrdem := {STR0005,STR0006,STR0007,STR0008,STR0017}   //' Por Codigo         '###' Por Tipo           '###' Por Descricao    '###' Por Grupo        '###' Por Endereco     '
					
	oReport := TReport():New("MATR280",STR0001,cPerg, {|oReport| ReportPrint(oReport)},STR0002+" "+STR0003+" "+STR0004) // 'Listagem para Inventario'##'Este programa emite um relatorio que facilita a digitacao'##'das quantidades inventariadas.'##"Ele e' emitido de acordo com os parametros informados."
	oReport:SetLandScape()

	Pergunte(cPerg,.F.)

	oSection := TRSection():New(oReport,STR0024,{"SB1","SB2","NNR"},aOrdem) //"Produtos"

	TRCell():New(oSection,"B1_COD","SB1")
	TRCell():New(oSection,"B1_TIPO","SB1")
	TRCell():New(oSection,"B1_GRUPO","SB1")
	TRCell():New(oSection,"B1_DESC","SB1",,,,,,,,,,,.T./*lAutoSize*/)
	TRCell():New(oSection,"B1_UM","SB1")
	TRCell():New(oSection,"B2_LOCAL","SB2")
	TRCell():New(oSection,"NNR_DESCRI","NNR")

	oCell := TRCell():New(oSection,"LOCALIZ","")
	oCell:GetFieldInfo("D14_ENDER")

	oCell := TRCell():New(oSection,"LOTECTL","")
	oCell:GetFieldInfo("D14_LOTECT")

	oCell := TRCell():New(oSection,"NUMLOTE","")
	oCell:GetFieldInfo("D14_NUMLOT")
           
	oCell := TRCell():New(oSection,"NUMSERI","")
	oCell:GetFieldInfo("D14_NUMSER")
	oCell:SetSize(14)

	TRCell():New(oSection,"QTD1","",STR0018+CRLF+STR0019,,11,,{|| "[         ]" }) //" _______1a."###"Quantidade"
	TRCell():New(oSection,"ETQ1","",STR0020+CRLF+STR0021,, 8,,{|| "[      ]" }) //"Contagem"###"Etiqueta"
	TRCell():New(oSection,"QTD2","",STR0022+CRLF+STR0019,,11,,{|| "[         ]" }) //" _______2a."###"Quantidade"
	TRCell():New(oSection,"ETQ2","",STR0020+CRLF+STR0021,, 8,,{|| "[      ]" }) //"Contagem"###"Etiqueta"
	TRCell():New(oSection,"QTD3","",STR0023+CRLF+STR0019,,11,,{|| "[         ]" }) //" _______3a."###"Quantidade"
	TRCell():New(oSection,"ETQ3","",STR0020+CRLF+STR0021,, 8,,{|| "[      ]" }) //"Contagem"###"Etiqueta"

Return(oReport)

Static Function ReportPrint(oReport)

	Local cAliasQRY := ""
	Local cLoteAnt	:= ""
	Local cCondicao1:= "" 
	Local cOrdem    := ""
	Local lImpLote	:= If(mv_par13==1,.T.,.F.)
	Local nOrdem    := oReport:Section(1):GetOrder()
	Local lFirst	:= .T.
	Local lRastro	:= .F.
	Local lRastroS	:= .F.
	Local lCLocal	:= .F.
	Local oSection	:= oReport:Section(1)
	Local dDataInv	:= ""
	Local cWhere    := ""
	Local cChave	:= ""
	Local cOrder	:= ""

	If nOrdem == 1
		cOrdem := STR0005
	ElseIf nOrdem == 2
		cOrdem := STR0006
	ElseIf nOrdem == 3
		cOrdem := STR0007
	ElseIf nOrdem == 4
		cOrdem := STR0008
	ElseIf nOrdem == 5
		cOrdem := STR0017
	EndIf

	//-- Inicializa os Arquivos e Ordens a serem utilizados
	oSection:SetHeaderPage()
	oReport:SetTitle(oReport:Title()+" ("+AllTrim(cOrdem)+")" )

	dbSelectArea('SB8')
	dbSetOrder(3)

	//--Transforma parametros Range em expressao SQL
	MakeSqlExpr(oReport:uParam)

	cAliasQRY := GetNextAlias()

	cWhere := "%"
	If mv_par14 == 2
		cWhere += " AND B2_QATU <> 0 "
	EndIf
	cWhere += "%"

	cOrder := "%"
	If nOrdem == 5
		cOrder += " ORDER BY BE_FILIAL, BE_LOCAL, BE_LOCALIZ, BE_ESTFIS "
	Else
		cOrder += " ORDER BY B1_FILIAL, B1_COD "
	EndIf
	cOrder += "%"

	oSection:BeginQuery()

	BeginSql Alias cAliasQRY
		SELECT	BE_FILIAL 	AS FILIAL,
				BE_LOCAL 	AS ARMAZEM,
				BE_LOCALIZ 	AS ENDER,
				BE_ESTFIS	AS ESTFIS,
				D14_PRODUT	AS PRODUTO,
				D14_LOTECT	AS LOTECT,
				D14_NUMLOT	AS NUMLOT,
				D14_NUMSER	AS NUMSER,
				B1_FILIAL,
				B1_COD,
				B1_TIPO,
				B1_GRUPO,
				B1_DESC,
				B1_UM,
				B1_PERINV,
				B2_FILIAL,
				B2_COD,
				B2_LOCAL,
				NNR_DESCRI,
				B2_DINVENT,
				B2_DINVFIM,
				B2_DTINV
		FROM %table:SB1% SB1
		JOIN %table:SB2% SB2
			ON SB2.B2_FILIAL = %xFilial:SB2% 
			AND SB2.B2_COD = SB1.B1_COD
			AND SB2.B2_LOCAL BETWEEN %Exp:mv_par01% AND %Exp:mv_par02%
			AND SB2.%NotDel%
			%Exp:cWhere% 	
		JOIN %table:NNR% NNR
			ON NNR.NNR_FILIAL = %xFilial:NNR% 
			AND NNR.NNR_CODIGO = SB2.B2_LOCAL 
			AND NNR.%NotDel%
		LEFT JOIN %table:D14% D14
			ON	D14.D14_FILIAL = %xFilial:D14%
			AND D14.D14_LOCAL = SB2.B2_LOCAL
			AND D14.D14_PRODUT = SB2.B2_COD
			AND D14.%NotDel%
		LEFT JOIN %table:SBE% SBE 
			ON SBE.BE_FILIAL = %xFilial:SBE%
			AND SBE.BE_LOCAL = D14.D14_LOCAL
			AND SBE.BE_LOCALIZ = D14.D14_ENDER
			AND SBE.BE_ESTFIS = D14.D14_ESTFIS
			AND SBE.%NotDel%	
		WHERE SB1.B1_FILIAL = %xFilial:SB1% 
			AND SB1.B1_COD BETWEEN %Exp:mv_par03% AND %Exp:mv_par04%
			AND SB1.B1_TIPO BETWEEN %Exp:mv_par05% AND %Exp:mv_par06%
			AND SB1.B1_GRUPO BETWEEN %Exp:mv_par07% AND %Exp:mv_par08%
			AND SB1.B1_DESC BETWEEN %Exp:mv_par09% AND %Exp:mv_par10% 
			AND SB1.%NotDel%
		UNION
		SELECT	BE_FILIAL 	AS FILIAL,
				BE_LOCAL 	AS ARMAZEM,
				BE_LOCALIZ 	AS ENDER,
				BE_ESTFIS	AS ESTFIS,
				BF_PRODUTO	AS PRODUTO,
				BF_LOTECTL	AS LOTECT,
				BF_NUMLOTE	AS NUMLOT,
				BF_NUMSERI	AS NUMSER,
				B1_FILIAL,
				B1_COD,
				B1_TIPO,
				B1_GRUPO,
				B1_DESC,
				B1_UM,
				B1_PERINV,
				B2_FILIAL,
				B2_COD,
				B2_LOCAL,
				NNR_DESCRI,
				B2_DINVENT,
				B2_DINVFIM,
				B2_DTINV
		FROM %table:SB1% SB1
		JOIN %table:SB2% SB2
			ON SB2.B2_FILIAL = %xFilial:SB2% 
			AND SB2.B2_COD = SB1.B1_COD
			AND SB2.B2_LOCAL BETWEEN %Exp:mv_par01% AND %Exp:mv_par02%
			AND SB2.%NotDel%
			%Exp:cWhere% 	
		JOIN %table:NNR% NNR
			ON NNR.NNR_FILIAL = %xFilial:NNR% 
			AND NNR.NNR_CODIGO = SB2.B2_LOCAL 
			AND NNR.%NotDel%
		LEFT JOIN %table:SBF% SBF 
			ON SBF.BF_FILIAL = %xFilial:SBF% 
			AND SBF.BF_LOCAL = SB2.B2_LOCAL
			AND SBF.BF_PRODUTO = SB2.B2_COD
			AND SBF.%NotDel%
		LEFT JOIN %table:SBE% SBE 
			ON SBE.BE_FILIAL = %xFilial:SBE%
			AND SBE.BE_LOCAL = SBF.BF_LOCAL
			AND SBE.BE_LOCALIZ = SBF.BF_LOCALIZ
			AND SBE.BE_ESTFIS = SBF.BF_ESTFIS
			AND SBE.%NotDel%	
		WHERE SB1.B1_FILIAL = %xFilial:SB1% 
			AND SB1.B1_COD BETWEEN %Exp:mv_par03% AND %Exp:mv_par04%
			AND SB1.B1_TIPO BETWEEN %Exp:mv_par05% AND %Exp:mv_par06%
			AND SB1.B1_GRUPO BETWEEN %Exp:mv_par07% AND %Exp:mv_par08%
			AND SB1.B1_DESC BETWEEN %Exp:mv_par09% AND %Exp:mv_par10% 
			AND SB1.%NotDel%
			%Exp:cOrder%		
	EndSql
	
	oSection:EndQuery(/*Array com os parametros do tipo Range*/)

	If !lImpLote
		oSection:Cell("LOCALIZ"):Disable()
		oSection:Cell("LOTECTL"):Disable()
		oSection:Cell("NUMLOTE"):Disable()
		oSection:Cell("NUMSERI"):Disable()
	Else
		oSection:Cell("LOCALIZ"):Enable()
		oSection:Cell("LOTECTL"):Enable()
		oSection:Cell("NUMLOTE"):Enable()
		oSection:Cell("NUMSERI"):Enable()
	EndIf

	oReport:SetMeter(Contar( cAliasQRY, "!Eof()" ))
	oSection:Init()

	(cAliasQRY)->( DbGoTop() )
	Do While (cAliasQRY)->( !Eof() )
		oReport:IncMeter()
	
		ProcessMessages() //--Força o refresh do Smart Client em casos de congelamento
		If oReport:Cancel()
			Exit
		EndIf

		lCLocal	  := Localiza((cAliasQRY)->B1_COD, .T.)

		If mv_par15 == 2
			dDataInv := (cAliasQRY)->B2_DTINV
			
			If Empty((cAliasQRY)->B2_DINVFIM) .Or. (cAliasQRY)->B2_DINVFIM < mv_par11 .Or. dDataInv > mv_par12
				(cAliasQRY)->(dbSkip())
				Loop
			EndIf			    
		Else
			dDataInv := (cAliasQRY)->B2_DTINV
			
			If (!Empty(dDataInv) .And. ;
				(((dDataInv + (cAliasQRY)->B1_PERINV) < mv_par11) .Or. ;
				((dDataInv + (cAliasQRY)->B1_PERINV) > mv_par12)))
				(cAliasQRY)->(dbSkip())
				Loop
			EndIf
		EndIf

		lRastro	  := Rastro((cAliasQRY)->B1_COD)
		lRastroS  := Rastro((cAliasQRY)->B1_COD, 'S')
		lFirst := .T.

		If lCLocal .And. lImpLote
			//--Pula registro inconsistente, que possue controle de localização mas o endereço não foi encontrado, seja D14 ou SBF
			If Empty( (cAliasQRY)->( FILIAL+ARMAZEM+ESTFIS+ENDER ) )
				(cAliasQRY)->(dbSkip())
				Loop
			EndIf
			If cChave != (cAliasQRY)->( FILIAL+ARMAZEM+ESTFIS+ENDER )
				oSection:Cell("B1_COD"):Show()
				oSection:Cell("B1_TIPO"):Show()
				oSection:Cell("B1_GRUPO"):Show()
				oSection:Cell("B1_DESC"):Show()
				oSection:Cell("B1_UM"):Show()
				oSection:Cell("B2_LOCAL"):Show()
				oSection:Cell("NNR_DESCRI"):Show()

				cChave := (cAliasQRY)->( FILIAL+ARMAZEM+ESTFIS+ENDER )
			Else
				oSection:Cell("B1_COD"):Hide()
				oSection:Cell("B1_TIPO"):Hide()
				oSection:Cell("B1_GRUPO"):Hide()
				oSection:Cell("B1_DESC"):Hide()
				oSection:Cell("B1_UM"):Hide()
				oSection:Cell("B2_LOCAL"):Hide()
				oSection:Cell("NNR_DESCRI"):Hide()
			EndIf   
			oSection:Cell("LOCALIZ"):SetValue( AllTrim( (cAliasQRY)->ENDER ) )
			oSection:Cell("LOTECTL"):SetValue( AllTrim( (cAliasQRY)->LOTECT ) )
			oSection:Cell("NUMLOTE"):SetValue( AllTrim( (cAliasQRY)->NUMLOT ) )
			oSection:Cell("NUMSERI"):SetValue( AllTrim( (cAliasQRY)->NUMSER ) )
			oSection:PrintLine()	
		ElseIf lRastro .And. lImpLote .And.;
			SB8->(dbSeek(xFilial('SB8') + (cAliasQRY)->B1_COD + (cAliasQRY)->B2_LOCAL, .F.))
			cLoteAnt   := ""
			cCondicao1 := 'SB8->B8_FILIAL + SB8->B8_PRODUTO + SB8->B8_LOCAL + SB8->B8_LOTECTL ' + If(lRastroS,'+ SB8->B8_NUMLOTE','')
			Do While !oReport:Cancel() .And. !SB8->(Eof()) .And. ;
				xFilial('SB8') + (cAliasQRY)->B1_COD + (cAliasQRY)->B2_LOCAL + SB8->B8_LOTECTL + If(lRastroS,SB8->B8_NUMLOTE,'') == &(cCondicao1)
				
				//-- Verifica se o saldo esta' zerado (mv_par14 == 2 (Nao))
				If mv_par14 == 2 .And. SB8->B8_SALDO == 0
					SB8->(dbSkip())
					Loop
				EndIf
				If !(cLoteAnt==SB8->B8_LOTECTL) .Or. lRastroS									    
					If lFirst
						oSection:Cell("B1_COD"):Show()
						oSection:Cell("B1_TIPO"):Show()
						oSection:Cell("B1_GRUPO"):Show()
						oSection:Cell("B1_DESC"):Show()
						oSection:Cell("B1_UM"):Show()
						oSection:Cell("B2_LOCAL"):Show()
						oSection:Cell("NNR_DESCRI"):Show()

						lFirst := .F.
					Else
						oSection:Cell("B1_COD"):Hide()
						oSection:Cell("B1_TIPO"):Hide()
						oSection:Cell("B1_GRUPO"):Hide()
						oSection:Cell("B1_DESC"):Hide()
						oSection:Cell("B1_UM"):Hide()
						oSection:Cell("B2_LOCAL"):Hide()
						oSection:Cell("NNR_DESCRI"):Hide()
					EndIf   
					oSection:Cell("LOCALIZ"):SetValue("")  
					oSection:Cell("LOTECTL"):SetValue(SB8->B8_LOTECTL)
					oSection:Cell("NUMLOTE"):SetValue(If(lRastroS,SB8->B8_NUMLOTE,""))
					oSection:Cell("NUMSERI"):SetValue("")

					cLoteAnt := SB8->B8_LOTECTL

					oSection:PrintLine()
				Endif
				SB8->(dbSkip())
			EndDo
		Else
			oSection:Cell("B1_COD"):Show()
			oSection:Cell("B1_TIPO"):Show()
			oSection:Cell("B1_GRUPO"):Show()
			oSection:Cell("B1_DESC"):Show()
			oSection:Cell("B1_UM"):Show()
			oSection:Cell("B2_LOCAL"):Show()
			oSection:Cell("NNR_DESCRI"):Show()
			oSection:Cell("LOCALIZ"):SetValue("")
			oSection:Cell("LOTECTL"):SetValue("")
			oSection:Cell("NUMLOTE"):SetValue("")
			oSection:Cell("NUMSERI"):SetValue("")
			oSection:PrintLine()	
		EndIf
		(cAliasQRY)->(dbSkip())		
	EndDo
	oSection:Finish()

Return NIL
