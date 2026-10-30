#include "rwmake.ch"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "protheus.ch"
#INCLUDE "TOTVS.ch"
#Include "GTPR121.ch"

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPR121
Relatório de Receitas por Agência/Empresa
@sample		GTPR121
@return		lRet, Lógico, .T. ou .F.
@author		Mick William da Silva
@since		29/04/2024
@version	P12
/*/
//------------------------------------------------------------------------------------------
Function GTPR121()
	
	Local cPerg 	 := "GTPR121"
	
	Private nAuxCol	 := 25
	Private nTotGeral:= 0

    If Pergunte( cPerg, .T. )
        oReport := ReportDef( cPerg )
        oReport:PrintDialog()
    Endif

Return .T.

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ReportDef
Função para montar o relatório
@sample		ReportDef
@author		Mick William da Silva
@since		29/04/2024
@version	P12
@return		oReport , Objeto	, Retorna o objeto do relatório
@param 		cPerg	, character	, Pergunte do relatório
/*/
//------------------------------------------------------------------------------------------
Static Function ReportDef(cPerg)
    
    Local oReport
	Local oSecReceit		:= Nil
	Local oSecBilhet		:= Nil
	Local oSecTotal			:= Nil
	Local cTitulo 			:= '[GTPR121] - '+ STR0001 //"Receitas por Agência / Empresa"
	Local cAlsGZT			:= QryGZT()
	Local cAlsGIC			:= QryGIC()
	Local nTipo				:= IIF(!EMPTY(MV_PAR05),MV_PAR05,1)


	oReport := TReport():New('GTPR121', cTitulo,cPerg, {|oReport| PrintReport(oReport,cAlsGZT,cAlsGIC)}, STR0002 ,,,.T.  )  //'Este relatório ira imprimir os totais de Receitas e Despesas Adicionais'
	oReport:SetLandsCape(.T.)
    
    oSecReceit := TRSection():New( oReport, STR0003 ,{cAlsGZT} ) //"Receitas"
	IF nTipo == 1
		TRCell():New(oSecReceit , "GZT_CODGZC"	, cAlsGZT , RetTitle("GZT_CODGZC")	, PesqPict("GZT","GZT_CODGZC") 	, TamSX3("GZT_CODGZC")[1]   ,,,"LEFT",,,,,,,,) 
		TRCell():New(oSecReceit , "GZC_DESCRI"  , cAlsGZT , RetTitle("GZC_DESCRI")	, PesqPict("GZC","GZC_DESCRI") 	, TamSX3("GZC_DESCRI")[1]+11   )
		TRCell():New(oSecReceit , "TOTAL "		, cAlsGZT , STR0009					, PesqPict("GZT","GZT_VALOR") 	, TamSX3("GZT_VALOR")[1]	,,,"RIGHT",,"RIGHT",,,,,,) //"Total"
	ELSE

		TRCell():New(oSecReceit , "GZT_DTVEND"	, cAlsGZT , STR0011					, PesqPict("GZT","GZT_DTVEND") 	,,,,"LEFT",.F.,,,,.T.,,,) //"Data"
		TRCell():New(oSecReceit , "GI6_CODIGO"  , cAlsGZT , STR0012					, PesqPict("GI6","GI6_CODIGO") 	,,,,"LEFT",.F.,,,,.T.,,,) //"Agencia"
		TRCell():New(oSecReceit , "GI6_DESCRI"  , cAlsGZT , STR0013					, PesqPict("GI6","GI6_DESCRI") 	,,,,"LEFT",.F.,,,,.T.,,,) //"Nome Agencia"
		TRCell():New(oSecReceit , "GZT_CODGZC"	, cAlsGZT , RetTitle("GZT_CODGZC")	, PesqPict("GZT","GZT_CODGZC") 	,,,,"LEFT" ,.F.,,,,.T.,,,) 
		TRCell():New(oSecReceit , "GZC_DESCRI"  , cAlsGZT , RetTitle("GZC_DESCRI")	, PesqPict("GZC","GZC_DESCRI") 	,,,,"LEFT",.F.,,,,.T.,,,) 
		TRCell():New(oSecReceit , "TOTAL "		, cAlsGZT , STR0009					, PesqPict("GZT","GZT_VALOR") 	,,,,"RIGHT",.F.,"RIGHT",,,.T.,,,) //"Total"
	ENDIF

	oSecBilhet := TRSection():New( oReport, STR0004 ,{cAlsGIC} ) //"Bilhetes"
	IF nTipo == 1
		TRCell():New(oSecBilhet , "GIC_STATUS"	, cAlsGIC , STR0005	, PesqPict("GIC","GIC_STATUS") 	, 15   							,,,"LEFT",,,,,,,, ) //"Status"
		TRCell():New(oSecBilhet , "TARIFA"	    , cAlsGIC , STR0006	, PesqPict("GIC","GIC_TAR") 	, TamSX3("GIC_TAR")[1]+5      	,,,,,"RIGHT",,,,,,)	//"Tarifa"
		TRCell():New(oSecBilhet , "TAXA"	    , cAlsGIC , STR0007	, PesqPict("GIC","GIC_TAR") 	, TamSX3("GIC_TAR")[1]+5     	,,,,,"RIGHT",,,,,,)	//"Taxa"
		TRCell():New(oSecBilhet , "PEDAGIO"	    , cAlsGIC , STR0008	, PesqPict("GIC","GIC_TAR") 	, TamSX3("GIC_TAR")[1]+5    	,,,,,"RIGHT",,,,,,)	//"Pedágio"
		TRCell():New(oSecBilhet , "TOTAL"	    , cAlsGIC , STR0009	, PesqPict("GIC","GIC_TAR") 	, TamSX3("GIC_TAR")[1]+5		,,,,,"RIGHT",,,,,,)	//"Total"
	ELSE
		
		TRCell():New(oSecBilhet , "GIC_STATUS"	, cAlsGIC , STR0005	, PesqPict("GIC","GIC_STATUS") 	,,,,"LEFT",.F.,,,,.T.,,, ) //"Status"
		TRCell():New(oSecBilhet , "GIC_DTVEND"	, cAlsGIC , STR0011	, PesqPict("GIC","GIC_DTVEND") 	,,,,"LEFT",.F.,,,,.T.,,, ) //"Data"
		TRCell():New(oSecBilhet , "GI6_CODIGO"	, cAlsGIC , STR0012	, PesqPict("GI6","GI6_CODIGO") 	,,,,"LEFT",.F.,,,,.T.,,, ) //"Agencia"
		TRCell():New(oSecBilhet , "GI6_DESCRI"	, cAlsGIC , STR0013	, PesqPict("GI6","GI6_DESCRI") 	,,,,"LEFT",.F.,,,,.T.,,, ) //"Nome Agencia"
		TRCell():New(oSecBilhet , "TARIFA"	    , cAlsGIC , STR0006	, PesqPict("GIC","GIC_TAR") 	,,,,,.F.,"RIGHT",,,.T.,,,)	//"Tarifa"
		TRCell():New(oSecBilhet , "TAXA"	    , cAlsGIC , STR0007	, PesqPict("GIC","GIC_TAR") 	,,,,,.F.,"RIGHT",,,.T.,,,)	//"Taxa"
		TRCell():New(oSecBilhet , "PEDAGIO"	    , cAlsGIC , STR0008	, PesqPict("GIC","GIC_TAR") 	,,,,,.F.,"RIGHT",,,.T.,,,)	//"Pedágio"
		TRCell():New(oSecBilhet , "TOTAL"	    , cAlsGIC , STR0009	, PesqPict("GIC","GIC_TAR") 	,,,,,.F.,"RIGHT",,,.T.,,,)	//"Total"
	ENDIF

	oSecTotal := TRSection():New( oReport, STR0010 ,"") //"Total Geral"
	TRCell():New(oSecTotal,"TOTGERAL","",STR0010,,TamSX3("GZT_CODGZC")[1]+TamSX3("GZC_DESCRI")[1]+TamSX3("GZT_VALOR")[1]+nAuxCol,,/*{||(nTotGeral)}*/,"RIGHT",,"LEFT",,,,,,.T.) 

Return oReport

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} QryGZT
Função para montar a query da seção "Receitas"
@sample		QryGZT
@author		Mick William da Silva
@since		29/04/2024
@version	P12
@return		cTmpGZT , caracter	, Alias da query gerada
/*/
//------------------------------------------------------------------------------------------
Static Function QryGZT()

    Local cTmpGZT   := GetNextAlias()
    Local cFiltro   := ""
    Local cDataDe	:= DTOS(MV_PAR01)
    Local cDataAte	:= DTOS(MV_PAR02)
    Local cAgeDe	:= Alltrim(MV_PAR03)
    Local cAgeAte	:= Alltrim(MV_PAR04)
	Local cCampos	:= ""


    If !Empty(MV_PAR01) .OR. !Empty(MV_PAR02)
        cFiltro += " AND GZT_DTVEND BETWEEN '"+cDataDe+"' AND '" + cDataAte + "' "
    EndIf

    If !Empty(MV_PAR03) .OR. !Empty(MV_PAR04)
        cFiltro += " AND GZT_AGENCI BETWEEN '"+cAgeDe+"' AND '" + cAgeAte + "' "
    EndIf
    
    cFiltro:="%"+cFiltro+"%"

	If !Empty(MV_PAR05) .AND. MV_PAR05 == 2
        cCampos += " ,GZT_DTVEND, GI6_CODIGO, GI6_DESCRI "
    EndIf

    cCampos:="%"+cCampos+"%"

    BeginSql Alias cTmpGZT
        SELECT  GZT_CODGZC, GZC_DESCRI, 
			    CASE 
					WHEN GZT.GZT_VALOR >= 0 
						THEN '1'
                    	ELSE '2'
                END AS TPVALOR,
				SUM(GZT_VALOR) TOTAL 
				%exp:cCampos% 
				FROM %Table:GZT% GZT
        INNER JOIN %Table:GZC% GZC ON GZC.GZC_FILIAL = GZT.GZT_FILIAL AND GZC.GZC_CODIGO = GZT_CODGZC AND GZC.%NotDel%
		INNER JOIN %Table:GI6% GI6 ON GZT.GZT_FILIAL = GI6.GI6_FILIAL AND GZT.GZT_AGENCI = GI6.GI6_CODIGO AND GI6.%NotDel%
        WHERE
        GZT_FILIAL =  %xFilial:GZT%
		AND GZT.%NotDel%
        %exp:cFiltro%
        GROUP BY GZT_CODGZC, GZC_DESCRI,
        		CASE 
        			WHEN GZT.GZT_VALOR >= 0 
						THEN '1'
						ELSE '2'
				END
				%exp:cCampos% 
		ORDER BY GZT_CODGZC
    EndSql

Return(cTmpGZT)

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} QryGIC
Função para montar a query da seção "Bilhetes"
@sample		QryGIC
@author		Mick William da Silva
@since		29/04/2024
@version	P12
@return		cTmpGZT , caracter	, Alias da query gerada
/*/
//------------------------------------------------------------------------------------------
Static Function QryGIC()

    Local cTmpGIC   := GetNextAlias()
    Local cFiltro   := ""
    Local cDataDe	:= DTOS(MV_PAR01)
    Local cDataAte	:= DTOS(MV_PAR02)
    Local cAgeDe	:= Alltrim(MV_PAR03)
    Local cAgeAte	:= Alltrim(MV_PAR04)
	Local cCampos	:= ""
	Local cGrupo    := ""
    
    If !Empty(MV_PAR01) .OR. !Empty(MV_PAR02)
        cFiltro += " AND GIC_DTVEND BETWEEN '"+cDataDe+"' AND '" + cDataAte + "' "
    EndIf

    If !Empty(MV_PAR03) .OR. !Empty(MV_PAR04)
        cFiltro += " AND GIC_AGENCI BETWEEN '"+cAgeDe+"' AND '" + cAgeAte + "' "
    EndIf
    
    cFiltro:="%"+cFiltro+"%"

	If !Empty(MV_PAR05) .AND. MV_PAR05 == 2
        cCampos += " ,GIC_DTVEND, GI6_CODIGO, GI6_DESCRI "
        cGrupo := " GROUP BY GIC_DTVEND, GI6_CODIGO, GI6_DESCRI "
    EndIf

    cCampos:="%"+cCampos+"%"
	cGrupo:= "%"+cGrupo+"%"

    BeginSql Alias cTmpGIC
        SELECT 	
			CASE
				WHEN GIC_STATUS = 'C' THEN 'Cancelado'
				WHEN GIC_STATUS = 'E' THEN 'Entregue'
				WHEN GIC_STATUS = 'D' THEN 'Devolvido'
				WHEN GIC_STATUS = 'I' THEN 'Inutilizado'
			END AS GIC_STATUS
			,SUM(GIC_TAR) TARIFA, SUM(GIC_TAX) TAXA, SUM(GIC_PED) PEDAGIO , SUM(GIC_VALTOT) TOTAL
			%exp:cCampos% 
		FROM %Table:GIC% GIC 
		INNER JOIN %Table:GI6% GI6 ON GIC.GIC_FILIAL = GI6.GI6_FILIAL AND GIC.GIC_AGENCI = GI6.GI6_CODIGO AND GI6.%notdel%
        WHERE
			GIC_FILIAL =  %xFilial:GIC%
	       	%exp:cFiltro%
			AND GIC_STATUS <> 'V' AND GIC_STATUS<>'T'
        	AND GIC.%NotDel%			
        GROUP BY GIC_STATUS %exp:cCampos%
		
		UNION ALL
		
		SELECT 	
			'Vendido' AS GIC_STATUS ,SUM(GIC_TAR) TARIFA, SUM(GIC_TAX) TAXA, SUM(GIC_PED) PEDAGIO , SUM(GIC_VALTOT) TOTAL
			%exp:cCampos% 
		FROM %Table:GIC% GIC
		INNER JOIN %Table:GI6% GI6 ON GIC.GIC_FILIAL = GI6.GI6_FILIAL AND GIC.GIC_AGENCI = GI6.GI6_CODIGO AND GI6.%NotDel%
        WHERE
			GIC_FILIAL =  %xFilial:GIC%
        	%exp:cFiltro%
			AND ( GIC_STATUS = 'V' OR GIC_STATUS='T' )
        	AND GIC.%NotDel%
        %exp:cGrupo%
		ORDER BY GIC_STATUS
    EndSql

Return(cTmpGIC)

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PrintReport
Função preencher as seções de Receitas e Bilhetes
@sample		PrintReport
@author		Mick William da Silva
@since		29/04/2024
@version	P12
@param 		oReport		, Objeto		, Objeto com os dados do relatório
@param 		cAliasTmp	, character		, Alias da tabela para Receita
@param 		cTmpGIC		, character		, Alias da tabela para Bilhete
/*/
//------------------------------------------------------------------------------------------
Static Function PrintReport( oReport, cAliasTmp, cTmpGIC )
 
	Local oSecReceit 	:=	oReport:Section(1)
	Local oSecBilhet	:=	oReport:Section(2)
	Local oSecTotal		:=	oReport:Section(3)
	Local oCouNew09		:= TFont():New("Courier New",08,08,,.T.,,,,.T.,.F.)
	Local oCouNew09N	:= TFont():New("Courier New",08,08,,.T.,,,,.T.,.T.)
	Local nCanTar		:= 0
	Local nVenTar		:= 0
	Local nCanTaxa		:= 0
	Local nVenTaxa		:= 0
	Local nCanPeda		:= 0
	Local nVenPeda		:= 0
	Local nCanTotal		:= 0
	Local nVenTotal		:= 0
	Local nBilTot		:= 0
	Local nTipo			:= IIF(!EMPTY(MV_PAR05),MV_PAR05,1)

	DbSelectArea(cAliasTmp)
	(cAliasTmp)->(dbGoTop())
	oSecReceit:Init()
	oReport:Say(306, 325, "")
	oSecReceit:Say(oReport:Row()+1, 350, OemToAnsi(STR0003),oCouNew09N )
	oReport:SkipLine(2)
	While (cAliasTmp)->(!Eof())
		
		
		oSecReceit:Cell("GZT_CODGZC"	):SetValue((cAliasTmp)->GZT_CODGZC	)
		oSecReceit:Cell("GZC_DESCRI"	):SetValue((cAliasTmp)->GZC_DESCRI	)	
		oSecReceit:Cell("TOTAL"	):SetValue((cAliasTmp)->TOTAL	)
		nBilTot += (cAliasTmp)->TOTAL

		IF nTipo == 2
			nAuxCol	:= IIF(oReport:nDevice == 6, 0 , -90 )
			oSecReceit:Cell("GZT_DTVEND"	):SetValue(DTOC(STOD((cAliasTmp)->GZT_DTVEND)))
			oSecReceit:Cell("GI6_CODIGO"	):SetValue((cAliasTmp)->GI6_CODIGO	)	
			oSecReceit:Cell("GI6_DESCRI"	):SetValue((cAliasTmp)->GI6_DESCRI	)
		ENDIF

		oSecReceit:PrintLine()

	 (cAliasTmp)->(dbSkip())
	EndDo

	oReport:SkipLine(1)
	oSecReceit:Say(oReport:Row() , oSecReceit:aCell[1]:ncol					, OemToAnsi(STR0009)	, oCouNew09 )
	oSecReceit:Say(oReport:Row() , oSecBilhet:Cell("TOTAL"):Col()+nAuxCol	, Transform(nBilTot		,PesqPict("GIC","GIC_TAR")	))	
	oReport:ThinLine()

	oSecReceit:Finish()	

	oReport:SkipLine(3)
	oReport:FatLine()
	oReport:SkipLine(2)

	DbSelectArea(cTmpGIC)
	(cTmpGIC)->(dbGoTop())
	oSecBilhet:Init()
	oSecBilhet:Say(oReport:Row()+1, 350, OemToAnsi(STR0004),oCouNew09N )
	oReport:SkipLine(1)

	While (cTmpGIC)->(!Eof())
		oSecBilhet:Cell("GIC_STATUS"):SetValue((cTmpGIC)->GIC_STATUS)
		oSecBilhet:Cell("TARIFA"	):SetValue((cTmpGIC)->TARIFA	)	
		oSecBilhet:Cell("TAXA"	 	):SetValue((cTmpGIC)->TAXA		)	
		oSecBilhet:Cell("PEDAGIO"	):SetValue((cTmpGIC)->PEDAGIO	)	
		oSecBilhet:Cell("TOTAL"	 	):SetValue((cTmpGIC)->TOTAL		)

		If (cTmpGIC)->GIC_STATUS = 'V' .Or. (cTmpGIC)->GIC_STATUS = 'T'
			nVenTar  += (cTmpGIC)->TARIFA
			nVenTaxa += (cTmpGIC)->TAXA
			nVenPeda += (cTmpGIC)->PEDAGIO
			nVenTotal+= (cTmpGIC)->TOTAL
		ElseIf (cTmpGIC)->GIC_STATUS = 'C' .Or. (cTmpGIC)->GIC_STATUS = 'D'
			nCanTar	 += (cTmpGIC)->TARIFA
			nCanTaxa += (cTmpGIC)->TAXA
			nCanPeda += (cTmpGIC)->PEDAGIO
			nCanTotal+= (cTmpGIC)->TOTAL
		EndIf

		IF nTipo == 2
			oSecBilhet:Cell("GIC_DTVEND"):SetValue(DTOC(STOD((cTmpGIC)->GIC_DTVEND)))
			oSecBilhet:Cell("GI6_CODIGO"):SetValue((cTmpGIC)->GI6_CODIGO)	
			oSecBilhet:Cell("GI6_DESCRI"):SetValue((cTmpGIC)->GI6_DESCRI)				
			nAuxCol	:= IIF(oReport:nDevice == 6, 0 , -120 )
		ENDIF
		
		oSecBilhet:PrintLine()
	 (cTmpGIC)->(dbSkip())
	EndDo

	oReport:SkipLine(1)
	oSecBilhet:Say(oReport:Row() , oSecBilhet:Cell("GIC_STATUS"):Col()		, OemToAnsi(STR0009)	, oCouNew09 )
	oSecBilhet:Say(oReport:Row() , oSecBilhet:Cell("TARIFA"):Col()+nAuxCol	, Transform(nVenTar - nCanTar		,PesqPict("GIC","GIC_TAR")	))	
	oSecBilhet:Say(oReport:Row() , oSecBilhet:Cell("TAXA"):Col()+nAuxCol	, Transform(nVenTaxa - nCanTaxa		,PesqPict("GIC","GIC_TAR")	))	
	oSecBilhet:Say(oReport:Row() , oSecBilhet:Cell("PEDAGIO"):Col()+nAuxCol	, Transform(nVenPeda - nCanPeda		,PesqPict("GIC","GIC_TAR")	))	
	oSecBilhet:Say(oReport:Row() , oSecBilhet:Cell("TOTAL"):Col()+nAuxCol	, Transform(nVenTotal - nCanTotal	,PesqPict("GIC","GIC_TAR")	))
	oReport:ThinLine()

	oSecBilhet:Finish()	
	
	oReport:SkipLine(3)
	oReport:FatLine()
	oReport:SkipLine(1)

	nTotGeral:= Transform(	(nVenTotal - nCanTotal) + nBilTot	,PesqPict("GIC","GIC_TAR")	)
	oSecTotal:Init()
	oSecTotal:Say(oReport:Row()	, oSecReceit:aCell[1]:ncol					, OemToAnsi(STR0010)	, oCouNew09 )
	oSecTotal:Say(oReport:Row() , oSecBilhet:Cell("TOTAL"):Col()+nAuxCol	, nTotGeral)		
	oSecTotal:Finish()
	
	oReport:EndPage()	

Return
