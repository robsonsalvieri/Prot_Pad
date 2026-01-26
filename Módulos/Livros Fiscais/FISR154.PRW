#Include "Protheus.ch"
#INCLUDE "REPORT.CH"
#Include "FISR154.ch"
//-------------------------------------------------------------------
/*/ {Protheus.doc} FISR154
Relatorio Lancamentos fiscais

@author Rafael.Soliveira
@since 04/08/2018
@version 12.17
/*/
//-------------------------------------------------------------------
Function FISR154()
Local oReport
Local lProcessa := .T.
Local lVerpesssen := Iif(FindFunction("Verpesssen"),Verpesssen(),.T.)


If lVerpesssen
	If !TRepInUse()
		Alert(STR0003) //"A impressão em TREPORT deverá estar habilitada. Favor verificar o parâmetro MV_TREPORT."
		lProcessa := .F.
	EndIf

	If lProcessa
		oReport:= ReportDef()
		oReport:PrintDialog()
	EndIf
EndIf

Return

//-------------------------------------------------------------------
/*/ {Protheus.doc} ReportDef
Interface de impressao

@author Rafael.Soliveira
@since 04/08/2018
@version 12.17
/*/
//-------------------------------------------------------------------
Static Function ReportDef()

Local oReport
Local oEmpr
Local oBreak
Local oSection1
Local cAlias := GetNextAlias()
Local lSF2frt	:= SF2->(FieldPos("F2_FRTCFOP")) > 0

oReport:= TReport():New("FISR154",STR0001,"FISR154",{|oReport| ReportPrint(oReport,cAlias,lSF2frt)},STR0002,.T.)
oReport:lHeaderVisible := .T.
oReport:HideParamPage()
oReport:lDisableOrientation := .T.
oReport:SetLandscape()

//Carrega SX1
Pergunte(oReport:uParam,.F.)

oEmpr:= TRSection():New(oReport,"Filiais",{},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/,,,,.T.)
oEmpr:SetReadOnly()
oEmpr:SetNoFilter("SM0")

oSection1:= TRSection():New(oEmpr,"Notas Fiscais",{cAlias,"SA1","SA4","SF3","SF2"},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/)
oSection1:SetAutoSize(.T.)
oSection1:SetCellBorder(1,1,,.T.)   //cabecalho superior
oSection1:SetCellBorder(4,1,,.T.)	//cabecalho Direita

TRCell():New(oSection1,"F3_FILIAL"	,"SF3","Filial",/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"F3_EMISSAO"	,"SF3",/*Title*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"F3_NFISCAL"	,"SF3","NF Fiscal"/*Title*/,/*Picture*/,TAMSX3("F3_NFISCAL")[1]/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"F3_SERIE"	,"SF3",/*Title*/,/*Picture*/,3/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"A1_CGC"  	,"SA1","CNPJ/CPF Cliente"/*Title*/,''/*Picture*/,20/*Tamanho*/,/*lPixel*/,{|| Iif(Len(AllTrim((cAlias)->A1_CGC)) > 11,Transform((cAlias)->A1_CGC,"@R! NN.NNN.NNN/NNNN-99"),Transform((cAlias)->A1_CGC,"@R 999.999.999-99")) })
TRCell():New(oSection1,"A1_NREDUZ"  ,"SA1","Nome Cliente"/*Title*/,/*Picture*/,TAMSX3("A1_NREDUZ")[1]/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"F2_TPFRETE"	,"SF2","Tp. Frete",/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| TPFRETE((cAlias)->F2_TPFRETE) })
TRCell():New(oSection1,"TIPCGC"		,"SA4",'CGC Transp'/*Title*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,{||  Iif(Len(AllTrim((cAlias)->A4_CGC)) > 11,"CNPJ","CPF") })
TRCell():New(oSection1,"A4_CGC"  	,"SA4","CNPJ/CPF Transp"/*Title*/,''/*Picture*/,20/*Tamanho*/,/*lPixel*/,{|| Iif(Len(AllTrim((cAlias)->A4_CGC)) > 11,Transform((cAlias)->A4_CGC,"@R! NN.NNN.NNN/NNNN-99"),Transform((cAlias)->A4_CGC,"@R 999.999.999-99"))})
TRCell():New(oSection1,"A4_NREDUZ"  ,"SA4","Nome Transp"/*Title*/,/*Picture*/,TAMSX3("A4_NREDUZ")[1]/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"F2_FRETE" 	,"SF2",/*Title*/,/*Picture*/,TAMSX3("F2_FRETE")[1]/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"F3_ICMAUTO" ,"SF3",'A'/*Title*/,/*Picture*/,TAMSX3("F3_ICMAUTO")[1]/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"F3_VALTST" 	,"SF3",'B'/*Title*/,/*Picture*/,TAMSX3("F3_VALTST")[1]/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"F2_FRETAUT" ,"SF2",'Base de Cálculo'/*Title*/,/*Picture*/,TAMSX3("F2_FRETAUT")[1]/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)

If lSF2frt
	TRCell():New(oSection1,"F2_FRTCFOP" ,"SF2",'CFOP Frete'/*Title*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
Endif

//Alinhamento Celulas
oSection1:Cell("F3_FILIAL"):nAlign := 2
oSection1:Cell("F3_EMISSAO"):nAlign := 2
oSection1:Cell("F3_NFISCAL"):nAlign := 2
oSection1:Cell("F3_SERIE"):nAlign := 2
oSection1:Cell("TIPCGC"):nAlign := 2
oSection1:Cell("F2_TPFRETE"):nAlign := 2

If lSF2frt
	oSection1:Cell("F2_FRTCFOP"):nAlign := 2
Endif

//Alinhamento Cabecalho
oSection1:Cell("F3_FILIAL"):nHeaderAlign := 2
oSection1:Cell("F3_EMISSAO"):nHeaderAlign := 2
oSection1:Cell("F3_NFISCAL"):nHeaderAlign := 2
oSection1:Cell("F3_SERIE"):nHeaderAlign := 2
oSection1:Cell("TIPCGC"):nHeaderAlign := 2
oSection1:Cell("A1_CGC"):nHeaderAlign := 2
oSection1:Cell("A1_NREDUZ"):nHeaderAlign := 2
oSection1:Cell("F2_TPFRETE"):nHeaderAlign := 2
oSection1:Cell("A4_CGC"):nHeaderAlign := 2
oSection1:Cell("A4_NREDUZ"):nHeaderAlign := 2
oSection1:Cell("F3_ICMAUTO"):nHeaderAlign := 2
oSection1:Cell("F3_VALTST"):nHeaderAlign := 2
If lSF2frt
	oSection1:Cell("F2_FRTCFOP"):nHeaderAlign := 2
Endif


oBreak := TRBreak():New(oSection1,'',STR0004,.F.,STR0004,.T.) //"Totalizadores do Relatório
TRFunction():New(oSection1:Cell("F2_FRETE"),NIL,"SUM",oBreak,  'Valor do Frete:            ',"999,999,999.99",,.F.,.F.,.F.)
TRFunction():New(oSection1:Cell("F2_FRETAUT"),NIL,"SUM",oBreak,'Credito ICMS:              ',"999,999,999.99",,.F.,.F.,.F.)
TRFunction():New(oSection1:Cell("F3_ICMAUTO"),NIL,"SUM",oBreak,'ICMS sobre frete autonomo: ',"999,999,999.99",,.F.,.F.,.F.)
TRFunction():New(oSection1:Cell("F3_VALTST"),NIL,"SUM",oBreak, 'Valor ICMS ST transporte:  ',"999,999,999.99",,.F.,.F.,.F.)
//TRFunction():New(oSection1:Cell("F3_BASETST"),NIL,"SUM",oBreak,'Base ICMS ST transporte:   ',"999,999,999.99",,.F.,.F.,.F.)

Return(oReport)

//-------------------------------------------------------------------
/*/ {Protheus.doc} ReportPrint
Impressao do relatorio

@author Rafael.Soliveira
@since 04/08/2018
@version 12.17
/*/
//-------------------------------------------------------------------
Static Function ReportPrint(oReport,cAlias,lSF2frt)
Local oEmpr     := oReport:Section(1)
Local oCodL     := oEmpr:Section(1)
Local oTFont    := TFont():New('Arial',,11,,.T.)
Local cFilBak   := cFilAnt
Local aFilsCalc := {}
Local nForFilial:= 0
Local cWhere	:= ""
Local cSelect	:= ""
Local aAreaSM0  := SM0->(GetArea())

cSelect := "SF3.F3_FILIAL,SF3.F3_EMISSAO,SF3.F3_NFISCAL,SF3.F3_SERIE,SF3.F3_CLIEFOR,SF3.F3_LOJA, SF3.F3_BASETST,SF3.F3_VALTST,SF3.F3_ICMAUTO,"
cSelect += "SF2.F2_FRTCFOP, SF2.F2_TRANSP,SF2.F2_FRETAUT,SF2.F2_ICMAUTO,SF2.F2_VALTST,SF2.F2_TPFRETE,SF2.F2_BASETST,SF2.F2_FRETE,"
If lSF2frt
	cSelect += "F2_FRTCFOP,"
Endif
cSelect +="SA1.A1_COD, SA1.A1_NOME, SA1.A1_CGC,SA1.A1_NREDUZ,"
cSelect +="SA4.A4_COD, SA4.A4_NOME, SA4.A4_CGC,SA4.A4_CGC TIPCGC ,SA4.A4_TPTRANS, SA4.A4_NREDUZ"

	//-- Seleciona Filiais
	If MV_PAR07==1
		aFilsCalc := MatFilCalc(.T.)
	Else
		aFilsCalc := {{.T.,cFilAnt}}
	EndIf
	
	//-- Documento de/ate
	If !Empty(MV_PAR01+MV_PAR02)
		cWhere += "F3_NFISCAL >= '"+MV_PAR01+"' AND F3_NFISCAL <= '"+MV_PAR02+"' AND "
	EndIf

	//-- Serie de/ate
	If !Empty(MV_PAR03+MV_PAR04)
		cWhere += "F3_SERIE >= '"+MV_PAR03+"' AND F3_SERIE <= '"+MV_PAR04+"' AND "
	EndIf

	//-- Seleciona Livro
	If MV_PAR08 <> "*"
		cWhere += "F3_NRLIVRO = '" +MV_PAR08+"' AND "
	EndIf	
	
	cSelect := '%'+cSelect+'%'
	cWhere := '%'+cWhere+'%'	

	For nForFilial := 1 To Len(aFilsCalc)

		If aFilsCalc[ nForFilial, 1 ]
			cFilAnt := aFilsCalc[ nForFilial, 2 ]
            SM0->( DbSetOrder(1) )
			SM0->( DbSeek( cEmpAnt + cFilAnt ) )
			
			MakeSqlExpr(oReport:uParam)
			
			oCodL:BeginQuery()

			BeginSql Alias cAlias
				COLUMN F3_EMISSAO AS DATE
				
				SELECT
				%Exp:cSelect%
							/*SELECT SF3.F3_FILIAL,SF3.F3_EMISSAO,SF3.F3_NFISCAL,SF3.F3_SERIE,SF3.F3_CLIEFOR,SF3.F3_LOJA, SF3.F3_BASETST,SF3.F3_VALTST,SF3.F3_ICMAUTO,;
							SF2.F2_FRTCFOP, SF2.F2_TRANSP,SF2.F2_FRETAUT,SF2.F2_ICMAUTO,SF2.F2_VALTST,SF2.F2_TPFRETE,SF2.F2_BASETST,;
							SA1.A1_COD, SA1.A1_NOME, SA1.A1_CGC,SA1.A1_NREDUZ,;
							SA4.A4_COD, SA4.A4_NOME, SA4.A4_CGC,SA4.A4_CGC TIPCGC ,SA4.A4_TPTRANS, SA4.A4_NREDUZ*/
				FROM %table:SF3% SF3
				INNER JOIN %table:SF2% SF2
				ON    F2_FILIAL			= %xFilial:SF2% AND
					  SF2.F2_DOC		= SF3.F3_NFISCAL	AND
					  SF2.F2_SERIE		= SF3.F3_SERIE  	AND
					  SF2.F2_CLIENTE 	= SF3.F3_CLIEFOR 	AND
					  SF2.F2_LOJA		= SF3.F3_LOJA   	AND					  
					  SF2.%NotDel%
					  
				INNER JOIN %table:SA4% SA4
				ON    SA4.A4_FILIAL = %xFilial:SA4% AND
					  SA4.A4_COD    = SF2.F2_TRANSP AND					  
					  SA4.%NotDel%

				INNER JOIN %table:SA1% SA1
				ON    SA1.A1_FILIAL = %xFilial:SA1% AND
					  SA1.A1_COD     = SF3.F3_CLIEFOR AND
					  SA1.A1_LOJA    = SF3.F3_LOJA	  AND
					  SA1.%NotDel%

				WHERE SF3.F3_FILIAL = %xFilial:SF3%
					  AND SF3.F3_ENTRADA >= %Exp:mv_par05%
					  AND SF3.F3_ENTRADA <= %Exp:mv_par06%
					  AND %Exp:cWhere%
					  SF3.F3_CFO >= '5'
					  AND SF3.F3_TIPO NOT IN ('D','B')
					  AND (SF3.F3_ICMAUTO > 0 Or SF3.F3_VALTST > 0)
					  AND SF3.F3_DTCANC = ''
					  AND SF3.%NotDel%
			EndSql			

			oCodL:EndQuery()

			oEmpr:Init()
			oReport:EndPage() //Reinicia Paginas
			oReport:Say(300,20,"Razão Social: "+SM0->M0_NOMECOM,oTFont)
			oReport:Say(350,20,"Endereco: "+AllTrim(SM0->M0_ENDENT)+" Cidade: "+AllTrim(SM0->M0_CIDENT)+" - UF: "+SM0->M0_ESTENT,oTFont)
			oReport:Say(400,20,"CNPJ: "+Transform(SM0->M0_CGC,"@R! NN.NNN.NNN/NNNN-99"),oTFont)
			oReport:Say(450,20,"Inscr. Estadual: "+SM0->M0_INSC,oTFont)

			oReport:SkipLine(10)
			oReport:FatLine()
			oReport:SkipLine(01)
			oReport:Say(600,20,"Métodos de cálculo de ICMS sobre frete:")
			oReport:Say(650,20,"A = Calculado ICMS sobre frete em que alíquota utilizada será a mesma do cálculo do ICMS na operação. Fret.Aut (F4_FRETAUT) = 1")
			oReport:Say(700,20,"B = Calculado ICMS sobre frete em que alíquota do cálculo será definida a partir do parâmetro MV_ALIQFRE. Fret.Aut (F4_FRETAUT) = 3")
			
			oEmpr:Finish()
			oReport:SkipLine(7)
			oCodL:Print()
		EndIf
	Next nForFilial

cFilAnt := cFilBak
RestArea(aAreaSM0)
Return


//-------------------------------------------------------------------
/*/ {Protheus.doc} TPFRETE
Retorna tipo de  Frete

@author Rafael.Soliveira
@since 04/08/2018
@version 12.17
/*/
//-------------------------------------------------------------------
Static Function TPFRETE(cFrete)
Local aCombo := {}
Local nPos :=  0

aCombo := RetSX3Box(GetSX3Cache("C5_TPFRETE","X3_CBOX"),,,1)
/*Ele retorna um array multidimensional onde cada elemento tem 3 posições, sendo :

[1] Opção completa (ex. F=Fisica)
[2] Código da opção (ex. F)
[3] Descrição da opção (ex. Fisica)
*/

If (nPos := AScan(aCombo,{|aX| aX[2]==cFrete},/*nStart*/,/*nCount*/)) > 0
	cFrete := aCombo[nPos,3]
EndIf

Return Alltrim(cFrete)
