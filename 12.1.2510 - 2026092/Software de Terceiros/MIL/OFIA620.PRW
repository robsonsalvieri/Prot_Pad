#Include "PROTHEUS.CH"
#Include "OFIA620.CH"

/*/{Protheus.doc} OFIA620

Impressão das peças da sugestão de compra

@author Bruno M. Sabioni
@since 29/04/2026
@version 1.0
@type function
/*/
Function OFIA620(cParamOs)
Local oReport
Private cNumOsv := cParamOS
Private cAliasRep := getnextalias()
	oReport := reportdef()
	oReport:PrintDialog()   
Return Nil

Static Function reportdef()
Local cTitulo := STR0001 //"Peças da Sugestão de Compra"
Local oReport
Local oSection
Local cDesc := STR0002 //"Este programa tem como objetivo imprimir a Relação das Peças da sugestão de compra"

	oReport := TReport():New("OFIA620",cTitulo,,{|oReport| RunReport(oReport)},cDesc)

	oSection := TRSection():New(oReport, "",{cAliasRep})

	TRCell():New(oSection, "VSJ_NUMORC",cAliasRep, GetSX3Cache("VSJ_NUMORC","X3_TITULO"), "@!"            ,  30,,,,,        ,,,,,,) // Número do orçamento
	TRCell():New(oSection, "VSJ_NUMOSV",cAliasRep, GetSX3Cache("VSJ_NUMOSV","X3_TITULO"), "@!"            ,  30,,,,,        ,,,,,,) // Número da OS
	TRCell():New(oSection, "VSJ_GRUITE",cAliasRep, GetSX3Cache("VSJ_GRUITE","X3_TITULO"), "@!"            ,  20,,,,,        ,,,,,,) // Grupo
	TRCell():New(oSection, "VSJ_CODITE",cAliasRep, GetSX3Cache("VSJ_CODITE","X3_TITULO"), "@!"            ,  40,,,,,        ,,,,,,) // Código do Item
	TRCell():New(oSection, "B1_DESC"   ,cAliasRep, GetSX3Cache("B1_DESC","X3_TITULO")   , "@!"            , 100,,,,,        ,,,,,,) // Descrição
	TRCell():New(oSection, "VSJ_LOCAL" ,cAliasRep, GetSX3Cache("VSJ_LOCAL","X3_TITULO") , "@!"            ,  30,,,,,        ,,,,,,) // Armazém
	TRCell():New(oSection, "VB5_QTDSUG",cAliasRep, GetSX3Cache("VB5_QTDSUG","X3_TITULO"), "@E 999,999,999",  30,,,,, "RIGHT",,,,,,) // Qtd Disponível
Return oReport

/*/{Protheus.doc} RunReport
Impressão em TReport da Relação das Peças do Orçamento não transferidas para o reservado
@author Fernando Vitor Cavani
@since 04/06/2020
@version undefined
@type function
/*/
Function RunReport (oReport)
Local oSection   := oReport:Section(1)
Local oStatement 
Local nX
Local aProds := {}
Local aBind := {}

	for nX := 1 to oModIte:Length()
		oModIte:GoLine(nX)
		If !oModIte:IsDeleted() .and. !Empty(oModIte:GetValue('SDFCODIGO'))
			Aadd(aProds, oModIte:GetValue("VB5CODPRO"))
		EndIf
	next
	
	cQuery := "SELECT VSJ_NUMORC, VSJ_NUMOSV, VSJ_GRUITE, VSJ_CODITE, B1_DESC, VSJ_LOCAL, VB5_QTDSUG "
	cQuery += "FROM " + retSqlname("VSJ") + " VSJ "
	cQuery += "JOIN " + retSqlname("SB1") + " SB1 "
	cQuery += "ON B1_FILIAL = ? "							;	aAdd(aBind, {"C", xFilial('SB1')})
	cQuery += "AND B1_CODITE = VSJ_CODITE "
	cQuery += "AND B1_GRUPO = VSJ_GRUITE "
	cQuery += "AND SB1.D_E_L_E_T_ = ? "						;	aAdd(aBind, {"C", " "})
	cQuery += "JOIN " + retSqlname("VB5") + " VB5 "
	cQuery += "ON VB5_FILIAL = ? "							;	aAdd(aBind, {"C", xFilial('VB5')})
	cQuery += "AND VB5_CODITE = VSJ_CODITE "
	cQuery += "AND VB5_GRUITE = VSJ_GRUITE "
	cQuery += "AND VB5.D_E_L_E_T_ = ? "						;	aAdd(aBind, {"C", " "})
	cQuery += "AND VB5_CODVSJ = VSJ_CODIGO "
	cQuery += "WHERE VSJ_FILIAL = ? "						;	aAdd(aBind, {"C", xFilial('VSJ')})
	cQuery += "AND VSJ_NUMOSV = ? "							;	aAdd(aBind, {"C", cNumOsv})
	//cQuery += "AND VSJ_RESPEC = ? " 						;	aAdd(aParams, "0")
	cQuery += "AND VSJ.D_E_L_E_T_ = ? " 					;	aAdd(aBind, {"C", " "})
	cQuery += "AND VSJ_CODITE IN (?) "						;   Aadd(aBind, {"A",aProds})
	cQuery += "AND VSJ_QTDAGU = ? "							;   Aadd(aBind, {"N", 0})
	cQuery += "ORDER BY VSJ_NUMORC, VSJ_NUMOSV, VSJ_GRUITE, VSJ_CODITE "

    oStatement := FwExecStatement():new( cQuery )
    for nX := 1 to len( aBind )
        if 	aBind[nX,1] == "C"
            oStatement:setString( nX, aBind[nX,2] )
        elseif aBind[nX,1] == "A"
            oStatement:setIn( nX, aBind[nX,2] )
		elseif aBind[nX,1] == "N"
			oStatement:setNumeric( nX, aBind[nX,2] )
        endif      
    next

    cQuery := oStatement:getFixQuery()
    oStatement:OpenAlias( cAliasRep )
	oStatement:destroy()
	Fwfreeobj(oStatement)

	dbselectarea(cAliasRep)
	oSection:init()
	while ! (cAliasRep) -> (eof())
		oSection:Printline()
		(cAliasRep) -> (dbskip())
	endDo
	oSection:finish()

Return Nil
