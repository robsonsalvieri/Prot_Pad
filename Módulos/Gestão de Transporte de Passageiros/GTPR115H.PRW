#INCLUDE "RPTDEF.CH"
#INCLUDE "TOTVS.ch"
#INCLUDE "GTPR115H.CH"


//-------------------------------------------------------------------
/*/{Protheus.doc} GTPR115H()
Relatório de mapa de viagens

@sample GTPR115H()

@author João Pires
@since 09/12/2024
@version P12
/*/
//-------------------------------------------------------------------
Function GTPR115H()

	Local oReport
	Local cPerg  	:= 'GTPR115H'
	Local aAreaAtu 	:= GetArea()

	If ( !FindFunction("GTPHASACCESS") .Or.; 
		( FindFunction("GTPHASACCESS") .And. GTPHasAccess() ) ) 

		If GTPxVldDic('H7X') .And. FWSIXUtil():ExistIndex( "GIC" , "C" )
			If Pergunte(cPerg, .T.)
				oReport := ReportDef(cPerg)
				oReport:PrintDialog()
			EndIf 
		Else
			FwAlertHelp(STR0001 ,STR0002) 	//"Dicionário desatualizado." ,"Atenção"
		EndIf 

	EndIf

	RestArea( aAreaAtu )

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportDef()

@sample ReportDef(cPerg)

@param cPerg - caracter - Nome da Pergunta

@return oReport - Objeto - Objeto TREPORT

@author João Pires 
@since 11/11/2024
@version P12
/*/
//-------------------------------------------------------------------
Static Function ReportDef(cPerg)

	Local cTitle     := STR0003	//"Mapa de viagens"
	Local cHelp      := STR0004	//"Relatório de mapa de viagem"
	Local cAliasQry  := GetNextAlias()
	Local aCpos      := {}
	Local nVezes     := 0
	Local nTam       := 0
	Local nColSpace  := 1
	Local lLandscape := .T. 
	Local cExpressao := ''
	Local oReport
	Local oSecao

	aCpos := {	'GIC_BILHET','H7X_NUMBPE','H7X_DTVEND','H7X_DTVIAG','H7X_LOCORI','H7X_LOCDES','H7X_LINHA','H7X_AGENCI',;
				'H7X_POLTRO','H7X_PASNOM','H7X_TAR','H7X_TAX','H7X_PED','H7X_OUTTOT','GIC_VLRPGT','H7X_VLRDSC','H7X_DESDSC'}


	cExpressao := ArrTokStr(aCpos, ",")				

	oReport := TReport():New('GTPR115H',cTitle,cPerg,{|oReport|ReportPrint(oReport,oSecao,cAliasQry,cExpressao)},cHelp,lLandscape/*lLandscape*/,/*uTotalText*/,/*lTotalInLine*/,/*cPageTText*/,.F./*lPageTInLine*/,/*lTPageBreak*/,nColSpace/*nColSpace*/)
	oReport:nFontBody := 5
	oReport:SetTotalInLine(.F.)

	oSecao := TRSection():New(oReport, 'CABECALHO', NIL)
	oSecao:SetTotalInLine(.F.)

	For nVezes:=1 To Len(aCpos)		
		nTam := TamSX3(aCpos[nVezes])[1]
		nTam := Iif(nTam>35,35,nTam)
		TRCell():New(oSecao,aCpos[nVezes], cAliasQry, RetTitle(aCpos[nVezes]) , /*Picture*/, nTam /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/) 		
	Next nVezes

	TRFunction():New(oSecao:Cell('GIC_VLRPGT') , , 'SUM' ,,,,,.F.,.T.,.F.,oSecao,,,)
	TRFunction():New(oSecao:Cell('H7X_VLRDSC') , , 'SUM' ,,,,,.F.,.T.,.F.,oSecao,,,)

Return oReport

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportPrint()

@sample ReportPrint(oReport, cAliasQry)

@param oReport - Objeto - Objeto TREPORT
	   cAliasQry  - Alias  - Nome do Alias para utilização na Query

@author João Pires 
@since 09/12/2024
@version P12
/*/
//-------------------------------------------------------------------
Static Function ReportPrint(oReport,oSecao,cAliasQry,cExpressao)
	Local cWhere   := ""	

	if MV_PAR01 == 1
		cWhere += " AND H7X_DTVEND BETWEEN "+DTOS(MV_PAR02)+" AND "+DTOS(MV_PAR03) 		
	else
		cWhere += " AND H7X_DTVIAG BETWEEN "+DTOS(MV_PAR02)+" AND "+DTOS(MV_PAR03) 		
	endif

	If !Empty(MV_PAR05)
		cWhere += " AND H7X_AGENCI BETWEEN '"+ALLTRIM(MV_PAR04)+"' AND '"+ALLTRIM(MV_PAR05)+"' " 		
	Endif
	
	cWhere := "%"+cWhere+"%"

	cExpressao := '%' + cExpressao + '%'	

	oSecao:BeginQuery()

	BeginSQL Alias cAliasQry

		SELECT 
			%Exp:cExpressao%
		FROM %Table:H7X% H7X 
		INNER JOIN %Table:GIC% GIC ON GIC_FILIAL = %xFilial:GIC% AND GIC_CHVBPE = H7X_CHVBPE AND GIC.%notDel%
		WHERE 
			    H7X_FILIAL = %xFilial:H7X%
			%exp:cWhere%
			AND H7X.%notDel%			
		ORDER BY H7X_DTVIAG

	EndSql 
	
	oSecao:EndQuery()

	oSecao:Print()	
   
Return
