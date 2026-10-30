#INCLUDE "TOTVS.ch"
#INCLUDE "RPTDEF.CH"
#INCLUDE "GTPR710.CH"
#INCLUDE "FWPrintSetup.ch"


Static lRetOR    	    := .F.	//PARAMETRO PARA PASSAR APENAS UMA VEZ NO DBSETORDER
/*/{Protheus.doc} GTPR710
	Relatorio de Regras Produto x Tipo de Bilhete
	@type function
	@author  GTP | pedro.saboia
	@since 31/03/2026
	@obs pergunte GTPR710

	MV_PAR01    --> GIC_DTVEND  --> Data de  :
	MV_PAR02    --> GIC_DTVEND  --> Data ate :
	MV_PAR03    --> GIC_AGENCI  --> Agencia de :
	MV_PAR04    --> GIC_AGENCI  --> Agencia ate :
	MV_PAR05    --> GIC_BILHET  --> Bilhete de :
	MV_PAR06    --> GIC_BILHET  --> Bilhete Ate :
	MV_PAR07    --> ??????????  --> Esta configurado ? : | A=Ambos | C=Configurado | N=Nao Configurado |
/*/
Function GTPR710()

	Local oReport := Nil
	Local cPerg   := 'GTPR710'

	If ( !FindFunction("GTPHASACCESS") .Or.;
			( FindFunction("GTPHASACCESS") .And. GTPHasAccess() ) )

		If Pergunte(cPerg, .T.)
			lRetOR := .T.
			oReport := ReportDef(cPerg)
			oReport:PrintDialog()
		EndIf

	EndIf
	lRetOR := .F.
Return()

/*/{Protheus.doc} ReportDef
Lista os bilhetes cadastrados de acordo com os parâmetros selecionados
@type function
@author GTP | pedro.saboia
@since 31/03/2026

/*/
Static Function ReportDef(cPerg)
	Local oReport    := Nil
	Local oSection1  := Nil

	Local cAliasQry  := GetNextAlias()  // alias para query de bilhetes (oSection2)
	Local cTitle     := "Produto x Tipo de Bilhete" //'Produto x Tipo de Bilhete'
	Local cHelp      := "Produto x Tipo de Bilhete" //'Produto x Tipo de Bilhete'

	oReport := TReport():New('GTPR710', cTitle, cPerg, {|oReport|ReportPrint(oReport,cAliasQry)}, cHelp, .T.,, .F.,, .F., .F.,)


	oSection1 := TRSection():New(oReport, "Bilhete", {"GIC", "GI1", "GI2", "G9O", "H60", "H87", "GI6"})
	oSection1:SetNoFilter("GIC")
	oSection1:SetNoFilter("GI1")
	oSection1:SetNoFilter("GI2")
	oSection1:SetNoFilter("G9O")
	oSection1:SetNoFilter("H60")
	oSection1:SetNoFilter("H87")
	oSection1:SetNoFilter("GI6")
	oSection1:SetTotalInLine(.F.)
	TRCell():New(oSection1, "GIC_CODIGO", cAliasQry, "Codigo"  ,/*Picture*/,    TamSX3("GIC_CODIGO")[1],.F./*lPixel*/, /*bBlock*/ , "RIGHT"/*cAlign*/ , .F./*lLineBreak*/ , "RIGHT"/*cHeaderAlign*/ , /*lCellBreak*/ , /*nColSpace*/ , .T./*lAutoSize*/ , /*nClrBack*/ , /*nClrFore*/ , /*lBold*/ )  //'Codigo'//'Codigo'
	TRCell():New(oSection1, "GIC_NUMBPE", cAliasQry, "Num. BPE",/*Picture*/,    TamSX3("GIC_NUMBPE")[1],.F./*lPixel*/, /*bBlock*/ , "RIGHT"/*cAlign*/ , .F./*lLineBreak*/ , "RIGHT"/*cHeaderAlign*/ , /*lCellBreak*/ , /*nColSpace*/ , .T./*lAutoSize*/ , /*nClrBack*/ , /*nClrFore*/ , /*lBold*/ )  //'Codigo'//'Num. BPE'
	TRCell():New(oSection1, "GIC_CHVBPE", cAliasQry, "Chave BPE",/*Picture*/,  TamSX3("GIC_CHVBPE")[1],.F./*lPixel*/, /*bBlock*/ , "RIGHT"/*cAlign*/ , .F./*lLineBreak*/ , "RIGHT"/*cHeaderAlign*/ , /*lCellBreak*/ , /*nColSpace*/ , .T./*lAutoSize*/ , /*nClrBack*/ , /*nClrFore*/ , /*lBold*/ )  //'Codigo'//'Chave BPE'
	TRCell():New(oSection1, "GIC_BILHET", cAliasQry, "Bilhete",/*Picture*/,     TamSX3("GIC_BILHET")[1],.F./*lPixel*/, /*bBlock*/ , "RIGHT"/*cAlign*/ , .F./*lLineBreak*/ , "RIGHT"/*cHeaderAlign*/ , /*lCellBreak*/ , /*nColSpace*/ , .T./*lAutoSize*/ , /*nClrBack*/ , /*nClrFore*/ , /*lBold*/ )  //'Codigo'//'Bilhete'
	TRCell():New(oSection1, "GIC_DTVEND", cAliasQry, "Data Venda",/*Picture*/,  TamSX3("GIC_DTVEND")[1],.F./*lPixel*/, /*bBlock*/ , "RIGHT"/*cAlign*/ , .F./*lLineBreak*/ , "RIGHT"/*cHeaderAlign*/ , /*lCellBreak*/ , /*nColSpace*/ , .T./*lAutoSize*/ , /*nClrBack*/ , /*nClrFore*/ , /*lBold*/ )  //'Codigo'//'Data Venda'
	TRCell():New(oSection1, "GIC_AGENCI", cAliasQry, "Agencia",/*Picture*/,     TamSX3("GIC_AGENCI")[1],.F./*lPixel*/, /*bBlock*/ , "RIGHT"/*cAlign*/ , .F./*lLineBreak*/ , "RIGHT"/*cHeaderAlign*/ , /*lCellBreak*/ , /*nColSpace */ , .T./*lAutoSize*/ , /*nClrBack */ , /*nClrFore */ , /*lBold */ )  //'Codigo'//'Agência'
	TRCell():New(oSection1, "GIC_LINHA" , cAliasQry, "Num. Linha",/*Picture*/,  TamSX3("GIC_LINHA")[1],.F./*lPixel*/, /*bBlock*/ , "RIGHT"/*cAlign*/ , .F./*lLineBreak*/ , "RIGHT"/*cHeaderAlign*/ , /*lCellBreak*/ , /*nColSpace*/ , .T./*lAutoSize*/ , /*nClrBack*/ , /*nClrFore*/ , /*lBold*/ )  //'Codigo'//'Num. Linha'
	TRCell():New(oSection1, "GIC_LOCORI", cAliasQry, "Cod. Origem",/*Picture*/, TamSX3("GIC_LOCORI")[1],.F./*lPixel*/, /*bBlock*/ , "RIGHT"/*cAlign*/ , .F./*lLineBreak*/ , "RIGHT"/*cHeaderAlign*/ , /*lCellBreak*/ , /*nColSpace*/ , .T./*lAutoSize*/ , /*nClrBack*/ , /*nClrFore*/ , /*lBold*/ )  //'Codigo'//'Cod. Origem'
	TRCell():New(oSection1, "GIC_LOCDES", cAliasQry, "Cod. Destino",/*Picture*/,TamSX3("GIC_LOCDES")[1],.F./*lPixel*/, /*bBlock*/ , "RIGHT"/*cAlign*/ , .F./*lLineBreak*/ , "RIGHT"/*cHeaderAlign*/ , /*lCellBreak*/ , /*nColSpace*/ , .T./*lAutoSize*/ , /*nClrBack*/ , /*nClrFore*/ , /*lBold*/ )  //'Codigo'//'Cod. Destino'


	TRCell():New(oSection1, "G9O_CODIGO",   cAliasQry, "Cod. Prod.",/*Picture*/,    TamSX3("G9O_CODIGO")[1],.F./*lPixel*/, /*bBlock*/ , "RIGHT"/*cAlign*/ , .F./*lLineBreak*/ , "RIGHT"/*cHeaderAlign*/ , /*lCellBreak*/ , /*nColSpace*/ , .T./*lAutoSize*/ , /*nClrBack */ , /*nClrFore */ , /*lBold */ )  //'Codigo' //'Cod. Prod. '
    TRCell():New(oSection1, "H60_PRDTAR",   cAliasQry, "Prod.Tarifa",/*Picture*/,   TamSX3("H60_PRDTAR")[1],.F./*lPixel*/, /*bBlock*/ , "RIGHT"/*cAlign*/ , .F./*lLineBreak*/ , "RIGHT"/*cHeaderAlign*/ , /*lCellBreak*/ , /*nColSpace*/ , .T./*lAutoSize*/ , /*nClrBack*/ , /*nClrFore*/ , /*lBold*/ )  //'Codigo' //'Prod.Tarifa '
	TRCell():New(oSection1, "H60_PRDTAX",   cAliasQry, "Prod.Taxa",/*Picture*/,     TamSX3("H60_PRDTAX")[1],.F./*lPixel*/, /*bBlock*/ , "RIGHT"/*cAlign*/ , .F./*lLineBreak*/ , "RIGHT"/*cHeaderAlign*/ , /*lCellBreak*/ , /*nColSpace*/ , .T./*lAutoSize*/ , /*nClrBack*/ , /*nClrFore*/ , /*lBold*/ )  //'Codigo' //'Prod.Taxa'
	TRCell():New(oSection1, "H60_PRDPED",   cAliasQry, "Prod.Pedágio",/*Picture*/,  TamSX3("H60_PRDPED")[1],.F./*lPixel*/, /*bBlock*/ , "RIGHT"/*cAlign*/ , .F./*lLineBreak*/ , "RIGHT"/*cHeaderAlign*/ , /*lCellBreak*/ , /*nColSpace*/ , .T./*lAutoSize*/ , /*nClrBack*/ , /*nClrFore*/ , /*lBold*/ )  //'Codigo' //'Prod.Pedágio'
    TRCell():New(oSection1, "H60_PRDGRT",   cAliasQry, "Prod. Gratui.",/*Picture*/, TamSX3("H60_PRDGRT")[1],.F./*lPixel*/, /*bBlock*/ , "RIGHT"/*cAlign*/ , .F./*lLineBreak*/ , "RIGHT"/*cHeaderAlign*/ , /*lCellBreak*/ , /*nColSpace*/ , .T./*lAutoSize*/ , /*nClrBack*/ , /*nClrFore*/ , /*lBold*/ )  //'Codigo' //'Prod.Pedágio'
    TRCell():New(oSection1, "H60_PRDSEG",   cAliasQry, "Prod. Seguro",/*Picture*/,  TamSX3("H60_PRDSEG")[1],.F./*lPixel*/, /*bBlock*/ , "RIGHT"/*cAlign*/ , .F./*lLineBreak*/ , "RIGHT"/*cHeaderAlign*/ , /*lCellBreak*/ , /*nColSpace*/ , .T./*lAutoSize*/ , /*nClrBack*/ , /*nClrFore*/ , /*lBold*/ )  //'Codigo'
    TRCell():New(oSection1, "H60_PRDOUT",   cAliasQry, "Prod. Outros",/*Picture*/,  TamSX3("H60_PRDOUT")[1],.F./*lPixel*/, /*bBlock*/ , "RIGHT"/*cAlign*/ , .F./*lLineBreak*/ , "RIGHT"/*cHeaderAlign*/ , /*lCellBreak*/ , /*nColSpace*/ , .T./*lAutoSize*/ , /*nClrBack*/ , /*nClrFore*/ , /*lBold*/ )  //'Codigo'
	TRCell():New(oSection1, "GIC_CODG9B",   cAliasQry, "Categ. Bil.",/*Picture*/,   TamSX3("GIC_CODG9B")[1],.F./*lPixel*/, /*bBlock*/ , "RIGHT"/*cAlign*/ , .F./*lLineBreak*/ , "RIGHT"/*cHeaderAlign*/ , /*lCellBreak*/ , /*nColSpace*/ , .T./*lAutoSize*/ , /*nClrBack*/ , /*nClrFore*/ , /*lBold*/ )  //'Codigo' //'Categ. Bil.'
	TRCell():New(oSection1, "GIC_STATUS",   cAliasQry, "Status Bil.",/*Picture*/,   TamSX3("GIC_STATUS")[1],.F./*lPixel*/, /*bBlock*/ , "RIGHT"/*cAlign*/ , .F./*lLineBreak*/ , "RIGHT"/*cHeaderAlign*/ , /*lCellBreak*/ , /*nColSpace*/ , .T./*lAutoSize*/ , /*nClrBack*/ , /*nClrFore*/ , /*lBold */ )  //'Codigo' //'Status Bil.'
	
	TRCell():New(oSection1, "G9O_PRDTARN",   cAliasQry, "Regra do Bilhete",/*Picture*/, 100,.F./*lPixel*/,{||RegRel(oSection1,cAliasQry)} , "RIGHT"/*cAlign*/ , .F./*lLineBreak*/ , "RIGHT"/*cHeaderAlign*/ , /*lCellBreak*/ , /*nColSpace*/ , .T./*lAutoSize*/ , /*nClrBack*/ , /*nClrFore*/ , /*lBold */ .T.)
	//TRCell():New(oSection1 ,"G9O_PRDTARN"  ,cAliasQry ,"Regra do Bilhete",/*Picture*/,100,/*lPixel*/,{||RegRel(oSection1,cAliasQry)},,,,,,,,,.T.) //"Reg. Prod x Bilhete"

	

Return oReport



/*/{Protheus.doc} ReportPrint
Realiza a Impressão do Relatório 
@type function
@author pedro.saboia
@since 01/04/2026
/*/
Static Function ReportPrint(oReport, cAliasQry)
	Local oSection1 := oReport:Section("Bilhete")



	SetQrySection(oReport, cAliasQry)
	oSection1:Print()

Return

/*/{Protheus.doc} ReportPrint
Monta query
@type function
@author  GTP | pedro.saboia
@since 31/03/2026
/*/
Static Function SetQrySection(oReport, cAliasQry)

	Local oSection1   :=  oReport:Section("Bilhete")

	Local cQryG90      := ""   as character
	Local cQryCond     := ""   as character
	Local cDtDe     := DTOS(MV_PAR01)
	Local cDtAte    := DTOS(MV_PAR02)
	Local nConfigurado := MV_PAR07   // 1=AMBOS 2=CONFIGURADO 3=NAO CONFIGURADO

	// Filtro CONFIGURADO/NAO CONFIGURADO aplicado em AdvPL apos a query
	If nConfigurado == 2
		cQryCond := "% AND ISNULL(G9O.G9O_CODIGO,'') > '' %"
	ElseIf nConfigurado == 3
		cQryCond := "% AND ISNULL(G9O.G9O_CODIGO,'') = '' %"
	Else
		cQryCond := "% %"
	EndIf

	cQryG90 := "% AND ( "
	cQryG90 += " G.G9O_GQCCOD = GI2.GI2_TIPLIN "
	cQryG90 += " OR LTRIM(RTRIM(ISNULL(G.G9O_GQCCOD,''))) = '' "
	cQryG90 += " ) %"

	oSection1:BeginQuery()
	BeginSql Alias cAliasQry


        SELECT 
            Distinct(GIC.GIC_CODIGO),
			GIC.GIC_NUMBPE,
			GIC.GIC_CHVBPE,
			GIC.GIC_CHVSUB,
			GIC.GIC_BILHET,
			GIC.GIC_DTVEND,
			GIC.GIC_AGENCI,
			GIC.GIC_STATUS,
			GIC.GIC_TIPO,
			GIC.GIC_LINHA,
            GIC.GIC_ORIGEM,
			GIC.GIC_LOCORI,
			GIC.GIC_LOCDES,
			GIC.GIC_CODG9B,
			GIC.GIC_TIPCAN,

			GI6.GI6_FILRES,
			GI6.GI6_CLIENT,
			GI6.GI6_FORNEC,
			GI6.GI6_CLIBIL,

            G9O.G9O_PRDTAR, 
            G9O.G9O_PRDTAX,
            G9O.G9O_PRDPED,
			G9O.G9O_PRDSEG,
			G9O.G9O_PRDOUT,
            G9O.G9O_CODIGO,

            H60.H60_PRDTAR,
            H60.H60_PRDTAX,
            H60.H60_PRDPED,
            H60.H60_PRDGRT,
			H60.H60_GERFIS,

            H87.H87_CODG9O,
			H87.H87_GERFIS,
            H87.H87_LOCORI,
            H87.H87_LOCDES,

			GI2.GI2_TIPLIN,
            GI1ORI.GI1_UF AS UFORI,
            GI1ORI.GI1_DESCRI AS DSMUNIORI,
            GI1DES.GI1_UF AS UFDES, 
            GI1DES.GI1_DESCRI AS DSMUNIDES
        FROM %Table:GIC% GIC

			INNER JOIN %Table:GI1% GI1ORI
				ON  GI1ORI.GI1_FILIAL = %xFilial:GI1%
				AND GI1ORI.GI1_COD    = GIC.GIC_LOCORI
				AND GI1ORI.%NotDel%
			INNER JOIN %Table:GI1% GI1DES
				ON  GI1DES.GI1_FILIAL = %xFilial:GI1%
				AND GI1DES.GI1_COD    = GIC.GIC_LOCDES
				AND GI1DES.%NotDel%
			LEFT JOIN %Table:GI2% GI2
				ON  GI2.GI2_FILIAL = GIC.GIC_FILIAL
				AND GI2.GI2_COD    = GIC.GIC_LINHA
				AND GI2.%NotDel%
				OUTER APPLY (
					SELECT TOP 1
						G.G9O_FILIAL,
						G.G9O_CODIGO,
						G.G9O_PRDTAR,
						G.G9O_PRDTAX,
						G.G9O_PRDPED,
						G.G9O_PRDSEG,
						G.G9O_PRDOUT,
						G.G9O_GQCCOD
					FROM %Table:G9O% G
					WHERE G.G9O_FILIAL  = GIC.GIC_FILIAL
					AND G.G9O_ORIGEM = GIC.GIC_ORIGEM
					AND G.G9O_TIPO   = GIC.GIC_TIPO
					AND G.G9O_STATUS = GIC.GIC_STATUS
					%Exp:cQryG90%
					AND G.%NotDel%
					ORDER BY
					CASE
						WHEN G.G9O_GQCCOD = GI2.GI2_TIPLIN THEN 0
						ELSE 1
					END
				) G9O
			LEFT JOIN %Table:H60% H60
				ON  H60.H60_FILIAL  = G9O.G9O_FILIAL
				AND H60.H60_CODG9O  = G9O.G9O_CODIGO
				AND H60.H60_UF      = GI1ORI.GI1_UF
				AND H60.%NotDel%
			LEFT JOIN %Table:H87% H87
				ON  H87.H87_FILIAL  = G9O.G9O_FILIAL
				AND H87.H87_CODG9O  = G9O.G9O_CODIGO
				AND H87.H87_LOCORI  = GIC.GIC_LOCORI
				AND H87.H87_LOCDES  = GIC.GIC_LOCDES
				AND H87.%NotDel%
			INNER JOIN %Table:GI6% GI6
				ON  GI6.GI6_FILIAL  = %xFilial:GI6%
				AND GI6.GI6_CODIGO  = GIC.GIC_AGENCI
				AND GI6.%NotDel%
        WHERE GIC.%notDel%
         AND GIC.GIC_FILIAL = %xFilial:GIC%
         AND GIC.GIC_BILHET BETWEEN  %Exp:mv_par05%  AND %Exp:mv_par06%
		 AND GIC.GIC_DTVEND  BETWEEN  %Exp:cDtDe%     AND  %Exp:cDtAte%
		 AND GIC.GIC_AGENCI  BETWEEN  %Exp:mv_par03%  AND %Exp:mv_par04%
		 AND GIC_STAPRO IN ('0','2')
         AND GIC.GIC_CHVBPE <> ' '
         AND (GIC_STATUS IN ('V','D','T','C') OR GIC_STATUS = 'E' AND GIC_VENDRJ = 'IVP')
		 AND GIC.GIC_NUMPRO <> '000000000000000'
		 %Exp:cQryCond%
        ORDER BY GIC.GIC_CODIGO


	EndSql


	oSection1:EndQuery()

	
Return 



/*/{Protheus.doc} RegRel
Regra Relatorio 
@type function
@version  
@author pedro.saboia
@since 02/04/2026
@param cAlias, character, param_description
@param cReg, character, param_description
@return variant, return_description
/*/
Static Function RegRel(oSection1,cAliasQry)

    Local cResult := ""


    Local cCodCateg 	:= ALLTRIM((cAliasQry)->(GIC_CODG9B))
    Local cCodG9O       := ALLTRIM((cAliasQry)->(G9O_CODIGO))
    Local cEstOri       := ALLTRIM((cAliasQry)->(UFORI))
    Local cTpBil  	    := ALLTRIM((cAliasQry)->(GIC_TIPO))
    Local cEstCal 	    := ALLTRIM((cAliasQry)->(UFDES))
    Local lfound        := .F.
    Local lG9B_GRATUI   := .T.
	Local cTpLinha 		:= ""
	Local cCodG9B  		:= ""
	Local cResuAg 		:= ""
	local cResCan       := ""
	Local cOrigem	    := ""
	



    DEFAULT cReg := ''

	If lRetOR

    	GIC->(DbSetOrder(1)) //GIC_FILIAL+GIC_CODIGO
    	GI2->(DbSetOrder(1)) //GI2_FILIAL+GI2_COD+GI2_VIA
    	GQC->(DbSetOrder(1)) //GQC_FILIAL+GQC_CODIGO
    	GZW->(DbSetOrder(1)) //GZW_FILIAL+GZW_CODGQC+GZW_EST
    	G9O->(DbSetOrder(2)) //GG9O_FILIAL+G9O_ORIGEM+G9O_TIPO+G9O_STATUS+G9O_GQCCOD+G9O_CODIGO 
    	H87->(DbSetOrder(1)) //H87_FILIAL+H87_CODG9O+H87_LOCORI+H87_LOCDES
    	H60->(DbSetOrder(1)) //H60_FILIAL+H60_CODG9O+H60_UF
		GI6->(DbSetOrder(1)) //GI6_FILIAL+GI6_CODIGO

	EndIf

	cTpLinha := Posicione('GI2',4,xFilial('GI2')+(cAliasQry)->(GIC_LINHA)+'2','GI2_TIPLIN')
	cCodG9B  := Posicione('G9B',1,xFilial('G9B')+(cAliasQry)->(GIC_CODG9B),'G9B_CODIGO')

	If (cAliasQry)->(GIC_STATUS) == 'C'

	 	If Empty((cAliasQry)->(GIC_TIPCAN))
			cResCan := "Tipo de cancelamento não informado"
		Elseif !Empty((cAliasQry)->(GIC_CHVSUB))
			cOrigem := Posicione('GIC',12,xFilial('GIC')+(cAliasQry)->(GIC_CHVSUB)+'V','GIC_NOTA')
			If Empty(cOrigem)
				cResCan := "Bilhete de Origem não faturado"
			EndIf
				
		Elseif Empty((cAliasQry)->(GIC_CHVSUB))
			cResCan := "Chave de Origem não informada"
		EndIf
	EndIf


	If (cAliasQry)->(GIC_STATUS) == 'T'

	 	If !Empty((cAliasQry)->(GIC_CHVSUB))
			cOrigem := Posicione('GIC',12,xFilial('GIC')+(cAliasQry)->(GIC_CHVSUB)+'V','GIC_NOTA')
			If Empty(cOrigem)
				cResCan := "Bilhete de Origem não faturado"
			EndIf
				
		Elseif Empty((cAliasQry)->(GIC_CHVSUB))
			cResCan := "Chave de Origem não informada"
		EndIf
	EndIf


	If Empty((cAliasQry)->(GI6_FILRES))
		cResuAg := "Agência não possui filial cadastrada"
	ElseIf Empty((cAliasQry)->(GI6_CLIENT))
		cResuAg := "Agência não possui cliente cadastrado"
	ElseIf Empty((cAliasQry)->(GI6_FORNEC))
		cResuAg := "Agência não possui fornecedor cadastrado"
	ElseIf Empty((cAliasQry)->(GI6_CLIBIL))
		cResuAg := "Agência não possui cliente cadastrado"
	EndIf


	If Empty(cResCan)
		IF Empty(cResuAg)
			If !Empty(cTpLinha)
				if !Empty(cCodG9B)
					If 	G9O->(DbSeek(xFilial("G9O") + (cAliasQry)->(GIC_ORIGEM) + cTpBil + (cAliasQry)->(GIC_STATUS) + cTpLinha)) .Or. G9O->(DbSeek(xFilial("G9O") + (cAliasQry)->(GIC_ORIGEM) + cTpBil + (cAliasQry)->(GIC_STATUS) + Space(TamSx3('G9O_GQCCOD')[1]) ))//Caso não encontrar, procura a chave sem o tipo de linha	

						If  GetGratuidade(lG9B_GRATUI,cEstOri,cCodCateg,cEstCal,@lfound,cAliasQry)
							If lFound
								If  (cAliasQry)->(H60_GERFIS) == '1'
									cResult  := "Regra de produto x tipo bilhete para gratuidade."
								Else
									cResult :=  'UF de origem do BP-e possui regra para não gerar o documento fiscal para o tipo e status deste BP-e' 
									lSkip := .T.
								Endif
							Else 									
								cResult := "Não localizado regra produto x tipo bilhete para gratuidade.' 
								lSkip := .T.
							EndIf 
						Else 
							If !Empty((cAliasQry)->(H87_CODG9O)) .And. H87->(DbSeek(xFilial('H87')+cCodG9O+(cAliasQry)->(GIC_LOCORI)+(cAliasQry)->(GIC_LOCDES)))	
								If (cAliasQry)->(H87_GERFIS)  == '1'
									cResult:="Regra Produto x Trechos Linha "
								Else 											 
									cResult := 'UF de origem do BP-e possui regra para não gerar o documento fiscal para o tipo e status deste BP-e' 
									lSkip := .T.
								EndIf 
							Else 
								If cEstOri == 'EX' .OR. cEstCal == 'EX'
									cResult:="Intinerario nacional em Linha internacional"
									
								ElseIf H60->(dbSeek(xFilial("H60")+cCodG9O+cEstOri))
									If  (cAliasQry)->(H60_GERFIS) == '1'
										cResult:="Regra Produto x Estados"
									Else 											 
										cResult := 'UF de origem do BP-e possui regra para não gerar o documento fiscal para o tipo e status deste BP-e' 
										lSkip := .T.
									EndIf 							
								Else
		    		                cResult:="Regra Produto x Tipo Bilhete"
								EndIf 
							EndIf 
						EndIf 
					Else
						cResult := "Não existe regra de produto x tipo bilhete cadastrada"
						lSkip := .T.
					Endif
				Else
					cResult := "Categoria de bilhete não cadastrada para a categoria do BP-e"
				Endif
			Else
				cResult := "Tipo de linha não cadastrado para a linha do BP-e"
			Endif
		Else
			cResult := cResuAg
		Endif
	Else
		cResult := cResCan
	EndIf

Return cResult

/*/{Protheus.doc} GetGratuidade()
Localiza Regra de bilhete gratuito
@type function
@author José Carlos
@since 20/02/2026
@version 1.0
/*/
Static Function GetGratuidade(lG9B_GRATUI,cEstOri,cCodCateg,cEstCal,lfound,cAliasQry)

	Local lRetorno := .F.
	Local lGratuito:= Iif(lG9B_GRATUI,GetAdvFval("G9B","G9B_GRATUI",xFilial("G9B")+cCodCateg,1),'') == '2'


	If lGratuito
		lRetorno := .T.
		lfound := (H60->(dbSeek(xFilial("H60")+(cAliasQry)->(G9O_CODIGO)+cEstOri+cCodCateg)) .Or. ;
						H60->(dbSeek(xFilial("H60")+(cAliasQry)->(G9O_CODIGO)+Space(TamSx3("H60_UF")[1])+cCodCateg)) .Or.;
						H60->(dbSeek(xFilial("H60")+(cAliasQry)->(G9O_CODIGO)+cEstOri)) .OR. ;
						H60->(dbSeek(xFilial("H60")+(cAliasQry)->(G9O_CODIGO)+cEstCal+cCodCateg)) ) 
	Else
			lRetorno := .F.
			lfound   := .F.
	EndIf						


Return lRetorno 
