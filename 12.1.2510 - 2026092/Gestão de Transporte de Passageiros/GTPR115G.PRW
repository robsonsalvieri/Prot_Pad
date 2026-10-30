#INCLUDE "RPTDEF.CH"
#INCLUDE "TOTVS.ch"
#INCLUDE "GTPR115G.CH"


//-------------------------------------------------------------------
/*/{Protheus.doc} GTPR115G()
Relatório Eventos de não embarque

@sample GTPR115G()

@author jose.darocha
@since 11/11/2024
@version P12
/*/
//-------------------------------------------------------------------
Function GTPR115G()

	Local oReport
	Local cPerg  	:= 'GTPR115G'
	Local aAreaAtu 	:= GetArea()

	If ( !FindFunction("GTPHASACCESS") .Or.; 
		( FindFunction("GTPHASACCESS") .And. GTPHasAccess() ) ) 

		If GTPxVldDic('H7W') .And. FWSIXUtil():ExistIndex( "GIC" , "C" )
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

@author jose.darocha 
@since 11/11/2024
@version P12
/*/
//-------------------------------------------------------------------
Static Function ReportDef(cPerg)

	Local cTitle     := STR0003	//"Bilhetes - Eventos não embarque"
	Local cHelp      := STR0004	//"Relatório de eventos de não embarque"
	Local cAliasQry  := GetNextAlias()
	Local aCpos      := {}
	Local nVezes     := 0
	Local nTam       := 0
	Local nColSpace  := 1
	Local lLandscape := .T. 
	Local cExpressao := ''
	Local oReport
	Local oSecao

	aCpos := {	'GIC_BILHET','GIC_DTVIAG','GIC_LOCORI','GIC_LOCDES','GIC_LINHA','GIC_AGENCI','GIC_STATUS',;
				'GIC_VALTOT','GIC_VLRBPE','GIC_VLRDSC','GIC_VLIBPE','GIC_ALIBPE',;
				'H7W_NUMBPE','H7W_DTEVEN','H7W_HREVEN','H7W_TPEVEN','H7W_PROTOC','H7W_DESCEV','H7W_JUSTIF'}

	cExpressao := ArrTokStr(aCpos, ",")				

	oReport := TReport():New('GTPR115G',cTitle,cPerg,{|oReport|ReportPrint(oReport,oSecao,cAliasQry,cExpressao)},cHelp,lLandscape/*lLandscape*/,/*uTotalText*/,/*lTotalInLine*/,/*cPageTText*/,.F./*lPageTInLine*/,/*lTPageBreak*/,nColSpace/*nColSpace*/)
	oReport:nFontBody := 5
	oReport:SetTotalInLine(.F.)

	oSecao := TRSection():New(oReport, 'CABECALHO', NIL)
	oSecao:SetTotalInLine(.F.)

	For nVezes:=1 To Len(aCpos)
		If aCpos[nVezes] <> 'H7W_HREVEN'
			If aCpos[nVezes] == 'GIC_STATUS'
				nTam := 25
			Else 
				nTam := TamSX3(aCpos[nVezes])[1]
				nTam := Iif(nTam>35,35,nTam)
			EndIF 
			TRCell():New(oSecao,aCpos[nVezes], cAliasQry, RetTitle(aCpos[nVezes]) , /*Picture*/, nTam /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/) 
		EndIf 
	Next nVezes

	TRFunction():New(oSecao:Cell('GIC_VALTOT') , , 'SUM' ,,,,,.F.,.T.,.F.,oSecao,,,)
	TRFunction():New(oSecao:Cell('GIC_VLIBPE') , , 'SUM' ,,,,,.F.,.T.,.F.,oSecao,,,)

Return oReport

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportPrint()

@sample ReportPrint(oReport, cAliasQry)

@param oReport - Objeto - Objeto TREPORT
	   cAliasQry  - Alias  - Nome do Alias para utilização na Query

@author jose.darocha 
@since 31/01/2024
@version P12
/*/
//-------------------------------------------------------------------
Static Function ReportPrint(oReport,oSecao,cAliasQry,cExpressao)

	cExpressao := '%' + cExpressao + '%'

	oSecao:BeginQuery()

	BeginSQL Alias cAliasQry

		SELECT 
			%Exp:cExpressao%
		FROM %Table:H7W% H7W 
		INNER JOIN %Table:GIC% GIC ON GIC_FILIAL = %xFilial:GIC% AND GIC_CHVBPE = H7W_CHVBPE AND GIC.%notDel%
		WHERE 
			    H7W_FILIAL = %xFilial:H7W%
			AND H7W_DTEVEN BETWEEN %Exp:DtoS(MV_PAR01)% AND %Exp:DtoS(MV_PAR02)%
			AND H7W.%notDel%
		ORDER BY H7W_DTEVEN,H7W_HREVEN			

	EndSql 
	
	oSecao:EndQuery()

	oSecao:Print()	
   
Return
