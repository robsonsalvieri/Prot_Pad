#include 'protheus.ch'
#include 'parmtype.ch'
#include 'gtpr421d.ch'


//-------------------------------------------------------------------
/*/{Protheus.doc} GTPR421D
Posição de conta corrente da Ficha de Remessa.

@author SIGAGTP | João Pires
@since 28/07/2025
@version 1.0

@type function
/*/
//-------------------------------------------------------------------

Function GTPR421D()

	Local oReport
	Local cPerg   := "GTPR421D"

	Pergunte( cPerg, .T. )
	
	oReport := ReportDef( cPerg )
	oReport:PrintDialog()
	
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportDef
Posição de conta corrente da Ficha de Remessa.

@author SIGAGTP | João Pires
@since 20/07/2025
@version 1.0

@type function
/*/
//-------------------------------------------------------------------

Static Function ReportDef(cPerg)
	Local oReport     := Nil
	Local oSection1   := Nil
	
	oReport := TReport():New("GTPR421D",STR0001,cPerg,{|oReport| ReportPrint(oReport)},STR0001) //"Posição de conta corrente da Ficha de Remessa"
	oReport:SetPortrait()   		
	
	oSection1:= TRSection():New(oReport,STR0003, {"G6X"}, , .F., .T.) //"Ficha de remessa"
	oSection1:SetAutoSize(.F.)
	
	TRCell():New(oSection1,"G6X_NUMFCH"  ,"G6X",STR0011	 ,X3Picture("G6X_NUMFCH")	  ,TamSX3("G6X_NUMFCH")[1]+1 ) //"Num. Ficha"	
	TRCell():New(oSection1,"GI6_IDAGEN"  ,"GI6",STR0002	 ,X3Picture("GI6_IDAGEN")	  ,TamSX3("GI6_IDAGEN")[1]+1 ) //"Ag. Totalbus"
    TRCell():New(oSection1,"GI6_CODIGO"  ,"GI6",STR0004	 ,X3Picture("GI6_CODIGO")	  ,TamSX3("GI6_CODIGO")[1]+1 ) //"Ag. Protheus"
    TRCell():New(oSection1,"SALTOANT"    ,"G6X",STR0005	 ,X3Picture("G6X_VLDIFE")	  ,TamSX3("G6X_VLDIFE")[1]+1 ) //"Saldo Ant."
    TRCell():New(oSection1,"G59_RECBIL"  ,"G59",STR0006	 ,X3Picture("G59_RECBIL")	  ,TamSX3("G59_RECBIL")[1]+1 ) //"Rec. Bilhete"
    TRCell():New(oSection1,"G59_VLRREC"  ,"G59",STR0007	 ,X3Picture("G59_VLRREC")	  ,TamSX3("G59_VLRREC")[1]+1 ) //"Receita" 
    TRCell():New(oSection1,"G6X_VLTOES"  ,"G6X",STR0008	 ,X3Picture("G6X_VLTOES")	  ,TamSX3("G6X_VLTOES")[1]+1 ) //"Estorno Dep." 
    TRCell():New(oSection1,"G6X_VLTODE"  ,"G6X",STR0009	 ,X3Picture("G6X_VLTODE")	  ,TamSX3("G6X_VLTODE")[1]+1 ) //"Deposito" 
    TRCell():New(oSection1,"G6X_VLRDES"  ,"G6X",STR0010	 ,X3Picture("G6X_VLRDES")	  ,TamSX3("G6X_VLRDES")[1]+1 ) //"Despesa" 
    TRCell():New(oSection1,"G6X_VLDIFE"  ,"G6X",STR0012	 ,X3Picture("G6X_VLDIFE")	  ,TamSX3("G6X_VLDIFE")[1]+1 ) //"Saldo Atu." 
			
	oSection1:SetLeftMargin(5)	
	oSection1:SetTotalInLine(.F.)
	//TRFunction():New(oSection1:Cell("G6X_VLDIFE") ,,"SUM",,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.T./*lEndReport*/,.F./*lEndPage*/)
			
Return(oReport)

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportPrint
Posição de conta corrente da Ficha de Remessa.

@author SIGAGTP | João Pires
@since 28/07/2025
@version 1.0

@type function
/*/
//-------------------------------------------------------------------

Static Function ReportPrint(oReport)
	Local oSection1	 := oReport:Section(1)
	Local cAliasG6X  := GetNextAlias()
	Local cAliasTmp  := GetNextAlias()
	Local cDtini     := DTOS(MV_PAR03)
	Local cDtFim     := DTOS(MV_PAR04)
	Local nSaldoAnt  := 0
	Local cAgencia	 := ""


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Query com os resultados a serem exibidos³
	//³na Secao                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	BeginSql Alias cAliasG6X

        SELECT 
			G6X.G6X_NUMFCH,
			G6X.G6X_DTINI,			
			GI6.GI6_IDAGEN,
            GI6.GI6_CODIGO,
            G59.G59_RECBIL,
            G59.G59_VLRREC,
            G6X.G6X_VLTOES,
            G6X.G6X_VLTODE,
            G6X.G6X_VLRDES,
            G6X.G6X_VLDIFE
        FROM  %Table:G6X% G6X
            INNER JOIN %Table:GI6% GI6
                    ON GI6.GI6_FILIAL = G6X.G6X_FILIAL
                        AND GI6.GI6_CODIGO = G6X.G6X_AGENCI
                        AND GI6.%NotDel%	
            INNER JOIN %Table:G59% G59
                    ON G59.G59_FILIAL = G6X.G6X_FILIAL
                        AND G59.G59_AGENCI = G6X.G6X_AGENCI
                        AND G59.G59_NUMFCH = G6X.G6X_NUMFCH
                        AND G59.%NotDel%	
        WHERE  G6X.%NotDel%	
            AND G6X.G6X_FILIAL = %xFilial:G6X%
            AND G6X.G6X_DTINI BETWEEN %Exp:cDtini% AND %Exp:cDtFim%
            AND G6X.G6X_AGENCI BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
        ORDER  BY G6X_AGENCI,
                G6X_DTINI 
		
	EndSql
	
	oReport:SetMeter((cAliasG6X)->(RecCount()))
	
	oReport:StartPage()	
	oReport:SkipLine()
	
	oSection1:Init()
	
	
	While (cAliasG6X)->(!Eof())	

		nSaldoAnt := 0

		If !Empty(cAgencia) .AND. cAgencia <> (cAliasG6X)->GI6_CODIGO
			oSection1:Finish()
			oReport:ThinLine()
			oSection1:Init(.F.)
		Endif

		cAgencia  := (cAliasG6X)->GI6_CODIGO

        BeginSql Alias cAliasTmp

           SELECT G6X.G6X_VLDIFE
			FROM %Table:G6X% G6X
			WHERE  G6X.G6X_FILIAL =  %xFilial:G6X%
				AND G6X.G6X_AGENCI = %Exp:(cAliasG6X)->GI6_CODIGO%
				AND G6X.G6X_DTFIN < %Exp:(cAliasG6X)->G6X_DTINI%
				AND G6X.%NotDel%
			ORDER  BY G6X.G6X_DTFIN DESC 
            
        EndSql
		
		If (cAliasTmp)->(!Eof())
			nSaldoAnt := (cAliasTmp)->G6X_VLDIFE
		Endif

		(cAliasTmp)->(DBCloseArea())

		oSection1:Cell("G6X_NUMFCH"):SetValue( (cAliasG6X)->G6X_NUMFCH )		
		oSection1:Cell("GI6_IDAGEN"):SetValue( (cAliasG6X)->GI6_IDAGEN )
		oSection1:Cell("GI6_CODIGO"):SetValue( (cAliasG6X)->GI6_CODIGO )
		oSection1:Cell( "SALTOANT" ):SetValue( nSaldoAnt )
		oSection1:Cell("G59_RECBIL"):SetValue( (cAliasG6X)->G59_RECBIL )
		oSection1:Cell("G59_VLRREC"):SetValue( (cAliasG6X)->G59_VLRREC )
		oSection1:Cell("G6X_VLTOES"):SetValue( (cAliasG6X)->G6X_VLTOES )
		oSection1:Cell("G6X_VLTODE"):SetValue( (cAliasG6X)->G6X_VLTODE )
		oSection1:Cell("G6X_VLRDES"):SetValue( (cAliasG6X)->G6X_VLRDES )
		oSection1:Cell("G6X_VLDIFE"):SetValue( (cAliasG6X)->G6X_VLDIFE )
		oSection1:Printline()
				
		(cAliasG6X)->(DbSkip())			
	EndDo

	(cAliasG6X)->(DBCloseArea())
	
	oSection1:Finish()
	
	oReport:ThinLine()
	oReport:EndPage()
	
Return
