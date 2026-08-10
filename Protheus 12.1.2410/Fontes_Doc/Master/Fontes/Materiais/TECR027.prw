#Include "Rwmake.ch"
#Include "Protheus.ch"      
#Include "TOPCONN.CH" 
#Include "TECR027.CH"
Static cAutoPerg := "TECR027"

//-------------------------------------------------------------------
/*/{Protheus.doc} TECR027
Relatorio de Locais x Supervisores

@author Junior Geraldo Dos Santos
@since 05/02/2020
@version P12.1.30
/*/
//-------------------------------------------------------------------

Function TECR027()

Local oReport     

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ PARAMETROS                                                             ³
//³ MV_PAR01 : Supervisor de ?											   ³
//³ MV_PAR02 : Supervisor ate ?											   ³
//³ MV_PAR03 : Local de ?												   ³
//³ MV_PAR04 : Local ate ?												   ³
//³ MV_PAR05 : Data de ?												   ³
//³ MV_PAR06 : Data ate?												   ³
//³ MV_PAR07 : Área de Supervisor ?                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 

If !Pergunte("TECR027",.T.)
	Return
EndIf

oReport := ReportDef()
oReport:PrintDialog()
Return
//-------------------------------------------------------------------------------------
/*/{Protheus.doc} ReportDef
Monta as definições do relatorio de Supervisores de Locais de Atendimento

@author  Junior Geraldo Dos Santos
@version P12.1.30
@since 	 05/02/2020
@return  Nil
/*/
//-------------------------------------------------------------------------------------
Static Function ReportDef()

Local cTitulo := STR0001 //"Relatório de Supervisores de Locais"	
Local oReport
Local oSection1
Local oSection2	
Local oSection3

oReport	:= TReport():New("TECR027", cTitulo, "TECR027" , {|oReport| PrintReport(oReport)},STR0001)//"Relatório de Supervisores"

oSection1 := TRSection():New(oReport,"Supervisores","AA1")
oSection1:SetHeaderPage()
TRCell():New(oSection1,"AA1_CODTEC","AA1", STR0003)//Cód. Supervisor
TRCell():New(oSection1,"AA1_NOMTEC","AA1", STR0004)//Supervisor
TRCell():New(oSection1,"AA1_FUNCAO","AA1", STR0005)//Função
TRCell():New(oSection1,"AA1_FONE"  ,"AA1", STR0006)//Telefone

oSection2 := TRSection():New(oSection1,STR0016,"TGS")//"Área de supervisão"
TRCell():New(oSection2,"TGS_COD" 	,"TGS", STR0017) //"Código da área"
TRCell():New(oSection2,"TGS_DESCRI" ,"TGS", STR0018) //"Área"
oSection2:SetLeftMargin(02)

oSection3 := TRSection():New(oSection2,STR0013,"TXI")//Locais
TRCell():New(oSection3,"TXI_LOCAL" ,"TXI", STR0007) //"Código do Local"
TRCell():New(oSection3,"TXI_DESLOC","TXI", STR0008) //"Local"
TRCell():New(oSection3,"TXI_FUNCAO","TXI", STR0014) //"Código da Função"
TRCell():New(oSection3,"TXI_DFUNC" ,"TXI", STR0009,,20) //"Função"
TRCell():New(oSection3,"TXI_TURNO" ,"TXI", STR0015) //"Código do Turno"
TRCell():New(oSection3,"TXI_DTURNO","TXI", STR0010,,20) //"Turno"
TRCell():New(oSection3,"TXI_PERIOD","TXI", STR0019) //"Período"
TRCell():New(oSection3,"TXI_DTINI" ,"TXI", STR0011) //"Ínicio"
TRCell():New(oSection3,"TXI_DTFIM" ,"TXI", STR0012) //"Fim"
oSection3:SetLeftMargin(04)

Return oReport

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} PrintReport
Gera o Relatorio Supervisores por locais	

@author  Junior Geraldo dos Santos
@version P12.1.30
@since 	 05/02/2020
@return  Nil
/*/
//-------------------------------------------------------------------------------------

Static Function PrintReport(oReport)

Local oSection1 := oReport:Section(1)
Local oSection2 := oReport:Section(1):Section(1)
Local oSection3 := oReport:Section(1):Section(1):Section(1)
Local cSql := ""

MakeSqlExpr("TECR027")
If TableInDic("TXI")

	cSql += "AND TXI.TXI_CODTEC BETWEEN '"+mv_par01+"' AND '"+mv_par02+"'"
	cSql += "AND TXI.TXI_LOCAL BETWEEN '"+mv_par03+"' AND '"+mv_par04+"'"
	cSql += "AND ((TXI.TXI_DTINI <= '"+DTOS(mv_par05)+"' OR TXI.TXI_DTINI BETWEEN '"+DTOS(mv_par05)+"'AND '"+DTOS(mv_par06)+"')"
	cSql += "AND (TXI.TXI_DTFIM >= '"+DTOS(mv_par06)+"' OR TXI.TXI_DTFIM BETWEEN '"+DTOS(mv_par05)+"'AND '"+DTOS(mv_par06)+"') OR TXI_DTINI = '"+ '' + "' OR TXI_DTFIM = '"+ '' + "')"
	If !Empty(Alltrim(mv_par07))
		cSql += "AND " + mv_par07
	EndIf
	cSql := "%"+cSql+"%" 
	Private cAliasTXI	:= GetNextAlias()

	BEGIN REPORT QUERY oSection1
		BEGIN REPORT QUERY oSection2
			BEGIN REPORT QUERY oSection3
			BeginSql Alias cAliasTXI
					
				SELECT 
					AA1_CODTEC, AA1_NOMTEC, AA1_FUNCAO, AA1_FONE, TXI_LOCAL, ABS.ABS_LOCAL, ABS.ABS_DESCRI AS TXI_DESLOC, TXI_CODTEC, SRJ.RJ_FUNCAO, TXI_FUNCAO, SRJ.RJ_DESC AS  TXI_DFUNC, TXI_TURNO, SR6.R6_TURNO, SR6.R6_DESC AS  TXI_DTURNO, TXI_DTINI, TXI_DTFIM,TXI_CODTGS,TGS_COD, ISNULL(TGS_DESCRI,'AREA VAZIA') TGS_DESCRI,TXI_PERIOD
				FROM %table:AA1% AA1
					INNER JOIN %Table:TXI% TXI
						ON TXI.TXI_CODTEC = AA1.AA1_CODTEC 
						AND TXI.%NotDel%
					LEFT JOIN %Table:TGS% TGS ON TXI.TXI_CODTGS = TGS.TGS_COD
						AND TGS.%NotDel%
					LEFT JOIN %table:ABS% ABS
						ON ABS.ABS_FILIAL = %xfilial:ABS%
						AND ABS.ABS_LOCAL = TXI.TXI_LOCAL
						AND ABS.%notDel%		
					LEFT JOIN %table:SRJ% SRJ
						ON SRJ.RJ_FILIAL = %xfilial:SRJ%
						AND SRJ.RJ_FUNCAO = TXI.TXI_FUNCAO
						AND SRJ.%notDel%	
					LEFT JOIN %table:SR6% SR6
						ON SR6.R6_FILIAL = %xfilial:SR6%
						AND SR6.R6_TURNO = TXI.TXI_TURNO
						AND SR6.%notDel%									
				WHERE 
					AA1_FILIAL = %xfilial:AA1%
					AND TXI_FILIAL = %xfilial:TXI%
					AND AA1_SUPERV = "1"
					AND AA1.%notDel%
					AND TXI.%notDel%	
				%exp:cSql%	      		     	
			EndSql
			END REPORT QUERY oSection3
		END REPORT QUERY oSection2
	END REPORT QUERY oSection1

	(cAliasTXI)->(DbGoTop())

	oSection2:SetParentQuery()
	oSection2:SetParentFilter({|cParam| (cAliasTXI)->TXI_CODTEC == cParam},{|| (cAliasTXI)->AA1_CODTEC })

	oSection3:SetParentQuery()
	oSection3:SetParentFilter({|cParam| (cAliasTXI)->TXI_CODTGS + (cAliasTXI)->TXI_CODTEC  == cParam },{||  (cAliasTXI)->TGS_COD + (cAliasTXI)->AA1_CODTEC  })

	//Executa impressão
	oSection1:Print()

	(cAliasTXI)->(DbCloseArea())
EndIf

Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GetPergTRp
Retorna o nome do Pergunte utilizado no relatório
Função utilizada na automação
@author Junior Geraldo
@since 05/02/2020
@return cAutoPerg, string, nome do pergunte
/*/
//-------------------------------------------------------------------------------------
Static Function GetPergTRp()

Return cAutoPerg
