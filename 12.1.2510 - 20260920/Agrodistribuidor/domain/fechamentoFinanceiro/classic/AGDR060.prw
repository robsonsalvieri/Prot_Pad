#include "protheus.ch"
#include "report.ch"
#include "AGDR060.ch"

/*{Protheus.doc} AGDR060
Rotina para emissão do relatório do fechamento financeiro
@author Gilson.Venturi
@since 15/04/2025
@version P12
@type function
*/
Function AGDR060(lPergunte)
 	Local aAreaAtu 	:= GetArea()
	Local oReport	:= Nil
	Default lPergunte := .T.

	if !lPergunte
  		SetMvValue("AGDR060", "MV_PAR01", NEJ->NEJ_FILIAL)
  		SetMvValue("AGDR060", "MV_PAR02", NEJ->NEJ_FILIAL)
  		SetMvValue("AGDR060", "MV_PAR03", NEJ->NEJ_CODBRT)
  		SetMvValue("AGDR060", "MV_PAR04", NEJ->NEJ_CODBRT)
  		SetMvValue("AGDR060", "MV_PAR05", NEJ->NEJ_CODCLI)
  		SetMvValue("AGDR060", "MV_PAR06", NEJ->NEJ_CODCLI)
  		SetMvValue("AGDR060", "MV_PAR07", NEJ->NEJ_CODVEN)
  		SetMvValue("AGDR060", "MV_PAR08", NEJ->NEJ_CODVEN)
  		SetMvValue("AGDR060", "MV_PAR09", NEJ->NEJ_CODIGO)
  		SetMvValue("AGDR060", "MV_PAR10", NEJ->NEJ_CODIGO)
  		SetMvValue("AGDR060", "MV_PAR11", 3)
	EndIf

	If FindFunction("TRepInUse") .And. TRepInUse()
		
		if !lPergunte
			Pergunte( "AGDR060", lPergunte )
			oReport:= ReportDef()
			oReport:PrintDialog()
		else
			If Pergunte( "AGDR060", lPergunte )
				oReport:= ReportDef()
				oReport:PrintDialog()
			EndIf
		EndIf
	EndIf
	
	RestArea( aAreaAtu )
Return( Nil )


/*{Protheus.doc} ReportDef
Função de definição de seções e layout do relatório
@author Gilson.Venturi
@since 15/04/2025
@version P12
@type function
*/
Static Function ReportDef()
	Local oReport	:= Nil
	Local oSection1	:= Nil
	Local oSection2	:= Nil
	Local oSection3	:= Nil
	Local oSection4	:= Nil

	//Chamada Relatório
	oReport := TReport():New("AGDR060", STR0001, , {| oReport | PrintReport( oReport ) }, STR0002)

	oReport:oPage:SetPageNumber(1)
	oReport:lBold 		   := .F.
	oReport:lUnderLine     := .F.
	oReport:lHeaderVisible := .T.
	oReport:lFooterVisible := .T.
	oReport:lParamPage     := .F.

	//Seção 1 - Relatório
	oSection1 := TRSection():New( oReport, STR0001, { "NEJ" } ) //Fechamento Financeiro
	oSection1:lLineStyle := .T.

	//Linha 1
	TRCell():New( oSection1, "NEJ_FILIAL", "NEJ", /*Title*/, /*Mask*/, 30, .T., , , , "LEFT" )
	TRCell():New( oSection1, "NEJ_CODBRT", "NEJ", /*Title*/, /*Mask*/, 30, .T., , , , "LEFT" )
	TRCell():New( oSection1, "NEJ_CODIGO", "NEJ", /*Title*/, /*Mask*/, 30, .T., , , , "LEFT" )
	TRCell():New( oSection1, "NEJ_CODCLI", "NEJ", /*Title*/, /*Mask*/, 50, .T., , , , "LEFT" )
	TRCell():New( oSection1, "NEJ_CODVEN", "NEJ", /*Title*/, /*Mask*/, 50, .T., , , , "LEFT" )
	TRCell():New( oSection1, "NEJ_STATUS", "NEJ", /*Title*/, /*Mask*/, 20, .T., , , , "LEFT" )

	//Seção 2 - Titulos Contas a Pagar
	oSection2 := TRSection():New( oReport, STR0003, { "NEK" } ) //"Itens Fechamento Financeiro"
	oSection2:lAutoSize := .T.
	TRCell():New( oSection2, "NEK_CODMOD" , "NEK")
	TRCell():New( oSection2, "NEK_FILTIT" , "NEK")
	TRCell():New( oSection2, "NEK_CODFOR" , "NEK")
	TRCell():New( oSection2, "NEK_LOJA"   , "NEK")
	TRCell():New( oSection2, "NEK_CODTIT" , "NEK")
	TRCell():New( oSection2, "NEK_PARCEL" , "NEK")
	TRCell():New( oSection2, "NEK_PREFIX" , "NEK")
	TRCell():New( oSection2, "NEK_SERTIT" , "NEK")
	TRCell():New( oSection2, "NEK_CODNF"  , "NEK")
	TRCell():New( oSection2, "NEK_SERNF"  , "NEK")
	TRCell():New( oSection2, "NEK_TIPO"   , "NEK")
	TRCell():New( oSection2, "NEK_DTEMIS" , "NEK",,PesqPict('NEK',"NEK_DTEMIS"))
	TRCell():New( oSection2, "NEK_DTVENC" , "NEK",,PesqPict('NEK',"NEK_DTVENC"))
	TRCell():New( oSection2, "NEK_VALOR"  , "NEK",,PesqPict('NEK',"NEK_VALOR"))

	//Seção 3 - Titulos Contas a Receber
	oSection3 := TRSection():New( oReport, STR0003, { "NEK" } ) //"Itens Fechamento Financeiro"
	oSection3:lAutoSize := .T.
	TRCell():New( oSection3, "NEK_CODMOD" , "NEK")

	TRCell():New( oSection3, "NEK_FILTIT" , "NEK")
	TRCell():New( oSection3, "NEK_CODFOR" , "NEK")
	TRCell():New( oSection3, "NEK_LOJA"   , "NEK")
	TRCell():New( oSection3, "NEK_CODTIT" , "NEK")
	TRCell():New( oSection3, "NEK_PARCEL" , "NEK")
	TRCell():New( oSection3, "NEK_PREFIX" , "NEK")
	TRCell():New( oSection3, "NEK_SERTIT" , "NEK")
	TRCell():New( oSection3, "NEK_CODNF"  , "NEK")
	TRCell():New( oSection3, "NEK_SERNF"  , "NEK")
	TRCell():New( oSection3, "NEK_TIPO"   , "NEK")
	TRCell():New( oSection3, "NEK_DTEMIS" , "NEK",,PesqPict('NEK',"NEK_DTEMIS"))
	TRCell():New( oSection3, "NEK_DTVENC" , "NEK",,PesqPict('NEK',"NEK_DTVENC"))
	TRCell():New( oSection3, "NEK_VALOR"  , "NEK",,PesqPict('NEK',"NEK_VALOR"))

	//Seção 4 - Totalizadores
	oSection4 := TRSection():New( oReport, '', '')
	oSection4:lLineStyle := .T.
	TRCell():New( oSection4, "VL_PAG", , STR0007, "@E 9999,999,999,999.99" , 12, .T., , , , "LEFT" )
	TRCell():New( oSection4, "VL_REC", , STR0009, "@E 9999,999,999,999.99" , 12, .T., , , , "LEFT" )
	TRCell():New( oSection4, "VL_DIF", , STR0011, "@E 9999,999,999,999.99" , 12, .T., , , , "LEFT" )

Return (oReport)


/*{Protheus.doc} PrintReport
Função de impressão do relatório
@author Gilson.Venturi
@since 14/04/2025
@version P12
@param oReport, object, descricao
@type function
*/
Static Function PrintReport(oReport)
	Local cQueryPri		:= ""
	Local cNomeVendedor	:= ""
	Local cNomeCliente	:= ""
	Local vTotPagar		:= 0
	Local vTotReceber	:= 0
	Local aAreaAtu		:= GetArea()
	Local cAliasQryPri	:= GetNextAlias()
	Local oS1			:= oReport:Section( 1 )
	Local oS2			:= oReport:Section( 2 )
	Local oS3			:= oReport:Section( 3 )
	Local oS4			:= oReport:Section( 4 )

	cQueryPri += " SELECT NEJ.* ,"

	cQueryPri += "		(SELECT SUM(NEKP.NEK_VALOR) "
	cQueryPri += "			FROM " + RetSqlName('NEK') + " NEKP "
	cQueryPri += "			WHERE NEKP.NEK_FILIAL = NEJ.NEJ_FILIAL"
	cQueryPri += "			  AND NEKP.NEK_CODFEC = NEJ.NEJ_CODIGO"
	cQueryPri += "			  AND NEKP.NEK_CODMOD = '1'" //Pagar
	cQueryPri += "			  AND NEKP.D_E_L_E_T_ = ' ') AS PAGAR,"

	cQueryPri += "		(SELECT SUM(NEKR.NEK_VALOR) "
	cQueryPri += "			FROM " + RetSqlName('NEK') + " NEKR "
	cQueryPri += "			WHERE NEKR.NEK_FILIAL = NEJ.NEJ_FILIAL"
	cQueryPri += "			  AND NEKR.NEK_CODFEC = NEJ.NEJ_CODIGO"
	cQueryPri += "			  AND NEKR.NEK_CODMOD = '2'" //Receber
	cQueryPri += "			  AND NEKR.D_E_L_E_T_ = ' ') AS RECEBER"

	cQueryPri += "   FROM " + RetSqlName('NEJ') + " NEJ "
	
	cQueryPri += " WHERE NEJ.D_E_L_E_T_  = ' '"
	cQueryPri += "   AND NEJ.NEJ_FILIAL >= ? "
	cQueryPri += "   AND NEJ.NEJ_FILIAL <= ? "
	cQueryPri += "   AND NEJ.NEJ_CODBRT >= ? "
	cQueryPri += "   AND NEJ.NEJ_CODBRT <= ? "
	cQueryPri += "   AND NEJ.NEJ_CODCLI >= ? "
	cQueryPri += "   AND NEJ.NEJ_CODCLI <= ? "
	cQueryPri += "   AND NEJ.NEJ_CODVEN >= ? "
	cQueryPri += "   AND NEJ.NEJ_CODVEN <= ? "
	cQueryPri += "   AND NEJ.NEJ_CODIGO >= ? "
	cQueryPri += "   AND NEJ.NEJ_CODIGO <= ? "

	if MV_PAR11 == 3
		cQueryPri += "   AND NEJ.NEJ_STATUS < ? "
	else
		cQueryPri += "   AND NEJ.NEJ_STATUS = ? "
	EndIf	

	cQueryPri += " ORDER BY NEJ.NEJ_FILIAL, NEJ.NEJ_CODBRT"
	
	oStatement := FWPreparedStatement():New()
	oStatement:SetQuery(cQueryPri)
	oStatement:SetString(1, MV_PAR01)
	oStatement:SetString(2, MV_PAR02)
	oStatement:SetString(3, MV_PAR03)
	oStatement:SetString(4, MV_PAR04)
	oStatement:SetString(5, MV_PAR05)
	oStatement:SetString(6, MV_PAR06)
	oStatement:SetString(7, MV_PAR07)
	oStatement:SetString(8, MV_PAR08)
	oStatement:SetString(9, MV_PAR09)
	oStatement:SetString(10, MV_PAR10)
	oStatement:SetString(11, cValToChar(MV_PAR11))

	cQueryPri := oStatement:GetFixQuery()
	cQueryPri := ChangeQuery(cQueryPri)
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQueryPri), cAliasQryPri, .T., .T.)

	DbSelectArea( cAliasQryPri )
	(cAliasQryPri)->(DbGoTop())

	oS1:Init()

	While .Not. (cAliasQryPri)->(Eof())

		cNomeCliente	:= (cAliasQryPri)->NEJ_CODCLI + " " + (cAliasQryPri)->NEJ_LOJA + " " +;
							Alltrim(Posicione("SA1",1,xFilial("SA1")+(cAliasQryPri)->NEJ_CODCLI+(cAliasQryPri)->NEJ_LOJA,"A1_NOME"))
		cNomeVendedor	:= (cAliasQryPri)->NEJ_CODVEN + " " +;
							Alltrim(Posicione("SA3",1,xFilial("SA3")+(cAliasQryPri)->NEJ_CODVEN,"A3_NOME"))

		oS1:aCell[1]:SetValue((cAliasQryPri)->NEJ_FILIAL)
		oS1:aCell[2]:SetValue((cAliasQryPri)->NEJ_CODBRT)
		oS1:aCell[3]:SetValue((cAliasQryPri)->NEJ_CODIGO)
		oS1:aCell[4]:SetValue(cNomeCliente)
		oS1:aCell[5]:SetValue(cNomeVendedor)
		oS1:aCell[6]:SetValue(X3Combo( "NEJ_STATUS", (cAliasQryPri)->NEJ_STATUS))

		oS1:PrintLine()

		DbSelectArea( "NEK" )
		NEK->( dbGoTop() )
		if NEK->( dbSeek((cAliasQryPri)->NEJ_FILIAL+(cAliasQryPri)->NEJ_CODIGO) )

			oS2:Init()
			oS3:Init()

			While .Not. NEK->( Eof( ) ) .and. alltrim( NEK->(NEK_FILIAL+NEK_CODFEC) ) == alltrim( (cAliasQryPri)->NEJ_FILIAL+(cAliasQryPri)->NEJ_CODIGO )

				If NEK->NEK_CODMOD == '1' // Pagar
					oS2:aCell[1]:SetValue(STR0014)
					oS2:aCell[2]:SetValue(NEK->(NEK_FILTIT))
					oS2:aCell[3]:SetValue(NEK->(NEK_CODFOR))
					oS2:aCell[4]:SetValue(NEK->(NEK_LOJA))
					oS2:aCell[5]:SetValue(NEK->(NEK_CODTIT))
					oS2:aCell[6]:SetValue(NEK->(NEK_PARCEL))
					oS2:aCell[7]:SetValue(NEK->(NEK_PREFIX))
					oS2:aCell[8]:SetValue(NEK->(NEK_SERTIT))
					oS2:aCell[9]:SetValue(NEK->(NEK_CODNF))
					oS2:aCell[10]:SetValue(NEK->(NEK_SERNF))
					oS2:aCell[11]:SetValue(NEK->(NEK_TIPO))
					oS2:aCell[12]:SetValue(NEK->(NEK_DTEMIS))
					oS2:aCell[13]:SetValue(NEK->(NEK_DTVENC))
					oS2:aCell[14]:SetValue(NEK->(NEK_VALOR))

					oS2:PrintLine()
				else
					oS3:aCell[1]:SetValue(STR0015)
					oS3:aCell[2]:SetValue(NEK->(NEK_FILTIT))
					oS3:aCell[3]:SetValue(NEK->(NEK_CODFOR))
					oS3:aCell[4]:SetValue(NEK->(NEK_LOJA))
					oS3:aCell[5]:SetValue(NEK->(NEK_CODTIT))
					oS3:aCell[6]:SetValue(NEK->(NEK_PARCEL))
					oS3:aCell[7]:SetValue(NEK->(NEK_PREFIX))
					oS3:aCell[8]:SetValue(NEK->(NEK_SERTIT))
					oS3:aCell[9]:SetValue(NEK->(NEK_CODNF))
					oS3:aCell[10]:SetValue(NEK->(NEK_SERNF))
					oS3:aCell[11]:SetValue(NEK->(NEK_TIPO))
					oS3:aCell[12]:SetValue(NEK->(NEK_DTEMIS))
					oS3:aCell[13]:SetValue(NEK->(NEK_DTVENC))
					oS3:aCell[14]:SetValue(NEK->(NEK_VALOR))

					oS3:PrintLine()			
				EndIf
				NEK->( dbSkip() )
			EndDo

			vTotPagar   += (cAliasQryPri)->PAGAR
			vTotReceber += (cAliasQryPri)->RECEBER

			oS4:Init()
			oS4:aCell[1]:SetValue((cAliasQryPri)->PAGAR)
			oS4:aCell[2]:SetValue((cAliasQryPri)->RECEBER)
			oS4:aCell[3]:SetValue((cAliasQryPri)->PAGAR - (cAliasQryPri)->RECEBER)
			oS4:PrintLine()

			oS2:Finish()
			oS3:Finish()
			oS4:Finish()

			oReport:SkipLine(2)			
		EndIf

		(cAliasQryPri)->(dbSkip())
	EndDo

	//Total Geral

	oreport:PrintText ( STR0012, oreport:row(), 10)
	oreport:SkipLine(1)
	oreport:PrintText ( STR0008, oreport:row(), 10)
	oreport:PrintText ( Transform(vTotPagar, "@E 9999,999,999,999.99"),oreport:row(), 200)
	oreport:SkipLine(1)
	oreport:PrintText ( STR0010, oreport:row(), 10)
	oreport:PrintText ( Transform(vTotReceber, "@E 9999,999,999,999.99"),oreport:row(), 200)
	oreport:SkipLine(1)
	oreport:PrintText ( STR0011, oreport:row(), 10)
	oreport:PrintText ( Transform(vTotPagar - vTotReceber, "@E 9999,999,999,999.99"), oreport:row(),  200)
	oreport:SkipLine(2)

	oS1:Finish()
			
	(cAliasQryPri)->( dbCloseArea() )

	RestArea(aAreaAtu)		
Return .t.

