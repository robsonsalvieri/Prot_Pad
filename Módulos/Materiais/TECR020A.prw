#INCLUDE "REPORT.CH"
#Include "Protheus.ch"
#Include "TOPCONN.ch"
#Include "TECR020A.ch"

Static cAutoPerg := "TECR020A"

//-------------------------------------------------------------------
/*/{Protheus.doc} TECR020A
Monta as definiçoes do relatorio de Atendentes sem Agenda.

@author fabiana.silva
@since 24/09/2019
@version P12.1.25
/*/
//-------------------------------------------------------------------
Function TECR020A()
Local oReport := Nil
Local cPerg	:= "TECR020A" 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ PARAMETROS                                                             ³
//³ MV_PAR01 : Data de ?                                                   ³
//³ MV_PAR02 : Data ate?                                                   ³
//³ MV_PAR03 : Atendente de ?                                              ³
//³ MV_PAR04 : Atendente ate ?                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 

//Exibe dialog de perguntes ao usuario
If Pergunte(cPerg,.T.)
	oReport := ReportDef(cPerg)
	oReport:PrintDialog()
EndIf

Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} reportDef
Monta as definiçoes do relatorio de Atendentes sem Agenda

@author fabiana.silva
@since 24/09/2019
@version P12.1.25
@param cPerg - Pergunte do relatório
@return  Nil
/*/
//-------------------------------------------------------------------------------------
Static Function ReportDef(cPerg)

Local cTitulo   := STR0001 //"Atendentes sem agenda"
Local cAliasAA1 := GetNextAlias()
Local oReport   := NIL
Local oSection0 := NIL
Local oBreak0   := NIL
Local nTam      := 0
Local nX        := 0

	For nX := 1 to 7
		nTam := Max(Len(TECCdow(Dow(sTod('20190511')+nX))), nTam)
	Next Nx

	oReport := TReport():New(cPerg, cTitulo, cPerg , {|oReport| PrintReport(oReport, cAliasAA1)}, STR0001) //"Atendentes sem agenda"

	oSection0 := TRSection():New(oReport, STR0001, {cAliasAA1, "AA1", "SRA"}, {"Atendente"}) //"Atendentes sem agenda"
 		DEFINE CELL NAME "AA1_CODTEC"	OF oSection0 ALIAS "AA1"
		DEFINE CELL NAME "AA1_NOMTEC"	OF oSection0 ALIAS "AA1"
		DEFINE CELL NAME "AA1_CDFUNC"	OF oSection0 ALIAS "AA1"
 		DEFINE CELL NAME "RA_ADMISSA"	OF oSection0 ALIAS "AA1"
 		DEFINE CELL NAME "RA_DEMISSA"	OF oSection0 ALIAS "AA1"

	oBreak0 = TRBreak():New(oSection0, {|| (cAliasAA1)->AA1_CODTEC }, "", .F.,, .T.)

	TRPosition():New(oSection0,"AA1", 1, {|| xFilial("AA1")+(cAliasAA1)->AA1_CODTEC})
	TRPosition():New(oSection0,"SRA", 1, {|| AA1->AA1_FUNFIL+AA1->AA1_CDFUNC})  

	oSection1 := TRSection():New(oSection0, STR0001 ,{cAliasAA1, "AA1","SRA"}) //"Atendentes sem agenda"
		DEFINE CELL NAME "DATA"		OF oSection1 ALIAS cAliasAA1 TITLE STR0002 SIZE 10   Block {|| Ctod("" )} //"Data Sem Agenda"
		DEFINE CELL NAME "DIASEM"	OF oSection1 ALIAS cAliasAA1 TITLE STR0003 SIZE nTam Block {|| "" } //"Dia da Semana"

Return (oReport) 

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} PrintReport
Gera o relatorio de Atendentes sem Agenda

@author fabiana.silva
@since 24/09/2019
@version P12.1.25
@param oReport - Objeto report
@param cAlias - Objeto Alias
@return  Nil

/*/
//-------------------------------------------------------------------------------------
Static Function PrintReport(oReport, cAliasAA1)
Local aDiaOc		:= {}
Local aPerAfast		:= {}
Local oSection0		:= oReport:Section(1)
Local oSection1		:= oSection0:Section(1)
Local cAliasABB		:= GetNextAlias()
Local cCodTec		:= ""
Local cCodFil		:= ""
Local cCodFun		:= ""
Local cWhrAA1Blq	:= ""
Local cWhrSRABlq	:= ""
Local cCol			:= ""
Local dDtIni		:= Ctod("")
Local dDtFim		:= Ctod("")
Local dDataUlt		:= Ctod("")
Local lFncAfasta	:= .F.
Local nC			:= 0
Local oQuery		:= Nil

If AA1->(ColumnPos('AA1_MSBLQL')) > 0
	cWhrAA1Blq := " AND AA1.AA1_MSBLQL <> '1'"
EndIf

If SRA->(ColumnPos('RA_MSBLQL')) > 0
	cWhrSRABlq := " AND (X.RA_MSBLQL IS NULL OR X.RA_MSBLQL <> '1') "
	cCol := ",SRA.RA_MSBLQL"
EndIf

cWhrAA1Blq := "%" +cWhrAA1Blq+"%"
cWhrSRABlq := "%"+cWhrSRABlq+"%"
cCol := "%"+cCol+"%"

BEGIN REPORT QUERY oSection0

	BeginSql alias cAliasAA1
		COLUMN RA_DEMISSA AS DATE
		COLUMN RA_ADMISSA AS DATE
		SELECT X.* FROM
		(
			SELECT
			AA1.AA1_CODTEC, AA1.AA1_CDFUNC, AA1.AA1_NOMTEC, AA1.AA1_FUNFIL,
			SRA.RA_ADMISSA, SRA.RA_DEMISSA, SRA.RA_TPCONTR
			%Exp:cCol%
			FROM
			%table:AA1% AA1
			LEFT JOIN %table:SRA% SRA ON SRA.RA_FILIAL = AA1.AA1_FUNFIL AND SRA.RA_MAT = AA1.AA1_CDFUNC  AND SRA.%notDel%
			WHERE
			AA1.AA1_FILIAL = %xfilial:AA1% AND
			AA1.AA1_CODTEC BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04% AND
			AA1.AA1_ALOCA <> '2' AND
			AA1.%notDel%
			%Exp:cWhrAA1Blq%
		) X
		WHERE
		 (X.RA_ADMISSA IS NULL OR X.RA_ADMISSA <= %Exp:MV_PAR02%) AND
		 (X.RA_DEMISSA IS NULL OR X.RA_DEMISSA  = %Exp:dDataUlt%  OR X.RA_DEMISSA >= %Exp:MV_PAR01%) AND
		 (X.RA_TPCONTR IS NULL OR X.RA_TPCONTR <> '3')
		 %Exp:cWhrSRABlq%
		ORDER BY X.AA1_CODTEC
	EndSql

END REPORT QUERY oSection0

oSection0:Init()
oSection1:Init()
While (cAliasAA1)->(!Eof())

	cCodTec := (cAliasAA1)->AA1_CODTEC
	cCodFil := (cAliasAA1)->AA1_FUNFIL
	cCodFun := (cAliasAA1)->AA1_CDFUNC
	aDiaOc  := {}

	// Data inicial posterior a admissao
	dDtIni := MV_PAR01
	If !Empty((cAliasAA1)->RA_ADMISSA)
		dDtIni := Max((cAliasAA1)->RA_ADMISSA, dDtIni)
	EndIf

	// Data final anterior a admissao
	dDtFim := MV_PAR02
	If !Empty((cAliasAA1)->RA_DEMISSA)
		dDtFim := Min((cAliasAA1)->RA_DEMISSA,dDtFim)
	EndIf

	// Retorna periodos de Afastamento e Ferias
	aPerAfast := GetPerAfast(cCodFil, cCodFun, dDtIni, dDtFim)

	// Agendas do Atendente
	cQuery := "SELECT DISTINCT ABB.ABB_DTINI, ABB.ABB_DTFIM "
	cQuery += "FROM " + RetSqlName( "ABB" ) + " ABB "
	cQuery += "WHERE "
	cQuery += "ABB.ABB_CODTEC = ? AND "
	cQuery += "ABB.ABB_FILIAL = ? AND "
	cQuery += "(ABB.ABB_DTINI BETWEEN ? AND ?  OR "
	cQuery += " ABB.ABB_DTFIM BETWEEN ? AND ?) AND "
	cQuery += "ABB.D_E_L_E_T_ = ' ' "
	cQuery += "ORDER BY ABB.ABB_DTINI, ABB.ABB_DTFIM"
	oQuery := FwPreparedStatement():New( cQuery )
	oQuery:SetString( 1, cCodTec )
	oQuery:SetString( 2, FwXFilial("ABB") )
	oQuery:SetString( 3, DToS(dDtIni) )
	oQuery:SetString( 4, DToS(dDtFim) )
	oQuery:SetString( 5, DToS(dDtIni) )
	oQuery:SetString( 6, DToS(dDtFim) )
	cQuery := oQuery:GetFixQuery()
	MPSysOpenQuery( cQuery, cAliasABB )

    dDataUlt := dDtIni
    If (cAliasABB)->(!Eof())
	    Do While (cAliasABB)->(!Eof())
	    	If SToD((cAliasABB)->ABB_DTINI) > dDataUlt
				Do While dDataUlt < SToD((cAliasABB)->ABB_DTINI)
					lFncAfasta := .F.
					For nC := 1 To Len(aPerAfast)
						If dDataUlt >= aPerAfast[nC, 1] .And. dDataUlt <= aPerAfast[nC, 2]
							lFncAfasta := .T.
							Exit
						EndIf
					Next nC
					If !lFncAfasta
						aAdd( aDiaOc, {dDataUlt, TECCdow(Dow(dDataUlt))} )
					EndIf
					dDataUlt++
				EndDo
	    	EndIf
		    If (cAliasABB)->ABB_DTINI < (cAliasABB)->ABB_DTFIM
		    	dDataUlt := SToD((cAliasABB)->ABB_DTFIM	)
		    EndIf
		    dDataUlt++
	    	(cAliasABB)->(DbSkip())
	    EndDo
	EndIf
 	(cAliasABB)->(DbCloseArea())
	oQuery:Destroy()
	FwFreeObj(oQuery)

	Do While dDataUlt <= dDtFim
		lFncAfasta := .F.
		For nC := 1 To Len(aPerAfast)
			If dDataUlt >= aPerAfast[nC, 1] .And. dDataUlt <= aPerAfast[nC, 2]
				lFncAfasta := .T.
				Exit
			EndIf
		Next nC
		If !lFncAfasta
			aAdd( aDiaOc, {dDataUlt, TECCdow(Dow(dDataUlt))} )	    	
		EndIf
		dDataUlt++
	EndDo

	If Len(aDiaOc) > 0
		oSection0:Printline()
		aSort(aDiaOc,,, {|a,b| a[1] < b[1] })
		For nC := 1 to Len(aDiaOc)
			oSection1:Cell("DATA"):SetValue(aDiaOc[nC, 01])
			oSection1:Cell("DIASEM"):SetValue(aDiaOc[nC, 02])
			oSection1:Printline()
		Next nC
	EndIf

	(cAliasAA1)->(DbSkip(1))
EndDo

oSection1:Finish()
(cAliasAA1)->(DbCloseArea())
Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GetPerAfast
Retorna periodos de Afastamento e Ferias
@author flavio.vicco
@since 20/08/2024
@return aPerAfast, array, periodos de Afastamento e Ferias do Atendente
/*/
//-------------------------------------------------------------------------------------
Static Function GetPerAfast(cCodFil, cCodFun, dDtIni, dDtFim)

	Local aPerAfast := {}
	Local cAliasSR8 := GetNextAlias()
	Local cAliasSRF := GetNextAlias()
	Local dDtAfIni  := Ctod("")
	Local dDtAfFim  := Ctod("")
	Local dDtFrIni  := Ctod("")
	Local dDtFrFim  := Ctod("")
	Local cQuery    := ""
	Local oQuery    := Nil

	// Periodo de Afastamento do Atendente
	lTemAfast := .F.
	cQuery := "SELECT SR8.R8_DATAINI, SR8.R8_DATAFIM "
	cQuery += "FROM " + RetSqlName( "SR8" ) + " SR8 WHERE "
	cQuery += "SR8.R8_FILIAL = ? AND SR8.R8_MAT = ? AND "
	cQuery += "SR8.R8_DATAINI <= ? AND SR8.R8_DATAFIM >= ? AND "
	cQuery += "SR8.D_E_L_E_T_ = ' '"
	oQuery := FwPreparedStatement():New( cQuery )
	oQuery:SetString( 1, cCodFil )
	oQuery:SetString( 2, cCodFun )
	oQuery:SetString( 3, DToS(dDtFim) )
	oQuery:SetString( 4, DToS(dDtIni) )
	cQuery := oQuery:GetFixQuery()
	MPSysOpenQuery( cQuery, cAliasSR8 )
	Do While (cAliasSR8)->(!Eof())
		If !Empty((cAliasSR8)->R8_DATAINI) .And. !Empty((cAliasSR8)->R8_DATAFIM)
			dDtAfIni := SToD((cAliasSR8)->R8_DATAINI)
			dDtAfFim := SToD((cAliasSR8)->R8_DATAFIM)
			aAdd(aPerAfast,{dDtAfIni, dDtAfFim})
		EndIf
		(cAliasSR8)->(DbSkip())
	EndDo
	(cAliasSR8)->(DbCloseArea())
	oQuery:Destroy()
	FwFreeObj(oQuery)

	// Periodo de Ferias do Atendente
	cQuery := "SELECT "
	cQuery += "SRF.RF_DATAINI, (RF_DATAINI + RF_DFEPRO1 + RF_DABPRO1 - 1) RF_DATAFIM, "
	cQuery += "SRF.RF_DATINI2, (RF_DATINI2 + RF_DFEPRO2 + RF_DABPRO2 - 1) RF_DATAFI2, "
	cQuery += "SRF.RF_DATINI3, (RF_DATINI3 + RF_DFEPRO3 + RF_DABPRO2 - 1) RF_DATAFI3  "
	cQuery += "FROM " + RetSqlName( "SRF" ) + " SRF WHERE "
	cQuery += "SRF.RF_FILIAL = ? AND SRF.RF_MAT = ? AND "
	cQuery += "(SRF.RF_DATAINI <> ' ' OR SRF.RF_DATINI2 <> ' ' OR SRF.RF_DATINI3 <> ' ') AND "
	cQuery += "SRF.D_E_L_E_T_ = ' '"
	oQuery := FwPreparedStatement():New( cQuery )
	oQuery:SetString( 1, cCodFil )
	oQuery:SetString( 2, cCodFun )
	cQuery := oQuery:GetFixQuery()
	MPSysOpenQuery( cQuery, cAliasSRF )
	Do While (cAliasSRF)->(!Eof())
		If !Empty((cAliasSRF)->RF_DATAINI) .And. !Empty((cAliasSRF)->RF_DATAFIM)
			dDtFrIni := SToD((cAliasSRF)->RF_DATAINI)
			dDtFrFim := SToD(AllTrim(Str((cAliasSRF)->RF_DATAFIM)))
			aAdd(aPerAfast,{dDtFrIni, dDtFrFim})
		EndIf
		If !Empty((cAliasSRF)->RF_DATINI2) .And. !Empty((cAliasSRF)->RF_DATAFI2)
			dDtFrIni := SToD((cAliasSRF)->RF_DATINI2)
			dDtFrFim := SToD(AllTrim(Str((cAliasSRF)->RF_DATAFI2)))
			aAdd(aPerAfast,{dDtFrIni, dDtFrFim})
		EndIf
		If !Empty((cAliasSRF)->RF_DATINI3) .And. !Empty((cAliasSRF)->RF_DATAFI3)
			dDtFrIni := SToD((cAliasSRF)->RF_DATINI3)
			dDtFrFim := SToD(AllTrim(Str((cAliasSRF)->RF_DATAFI3)))
			aAdd(aPerAfast,{dDtFrIni, dDtFrFim})
		EndIf
		(cAliasSRF)->(DbSkip())
	EndDo
	(cAliasSRF)->(DbCloseArea())
	oQuery:Destroy()
	FwFreeObj(oQuery)

Return aPerAfast

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GetPergTRp
Retorna o nome do Pergunte utilizado no relatório
Função utilizada na automação
@author Junior Geraldo
@since 29/05/2020
@return cAutoPerg, string, nome do pergunte
/*/
//-------------------------------------------------------------------------------------
Static Function GetPergTRp()

Return cAutoPerg
