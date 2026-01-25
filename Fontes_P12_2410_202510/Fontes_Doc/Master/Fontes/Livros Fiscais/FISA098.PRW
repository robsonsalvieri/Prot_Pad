#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FISA098.CH"

PUBLISH MODEL REST NAME FISA098 SOURCE FISA098
//-------------------------------------------------------------------
/*/{Protheus.doc} FISA098
Tabela de Movimentação Acumulada de Produtos

@author Mauro Afonso Gonçalves
@since 14.04.2015
@version 1.0

/*/
//-------------------------------------------------------------------
Function FISA098()
Local oBrowse := Nil

IF  AliasIndic("F0D") 
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("F0D")
	oBrowse:SetDescription(STR0001) //Movimentação Acumulada de Produtos
	oBrowse:Activate()
Else
	Help("",1,"Help","Help",STR0002,1,0) //Tabela F0D não cadastrada no sistema!
EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc}MenuDef                                     
Funcao generica MVC com as opcoes de menu

@author Mauro Afonso Gonçalves
@since 16.02.2015
@version 1.0

/*/
//-------------------------------------------------------------------                                                                                            
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.FISA098' OPERATION 2 ACCESS 0 //'Visualizar'
ADD OPTION aRotina TITLE STR0004 ACTION 'GerAcuProd()'    OPERATION 3 ACCESS 0 // 'Gerar'
ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.FISA098' OPERATION 5 ACCESS 0 //'Excluir'
		
Return aRotina
//-------------------------------------------------------------------
/*/{Protheus.doc}  ModelDef
Funcao generica MVC do model

@author Mauro Afonso Gonçalves
@since 16.02.2015
@version 1.0

/*/
//-------------------------------------------------------------------

Static Function ModelDef()
Local oModel  := MPFormModel():New('FISA098MOD')
Local oStruct := FWFormStruct(1,"F0D")    

oModel:AddFields('FISA098MOD',,oStruct)	   
oModel:SetPrimaryKey({'F0D_CODPRD', 'F0D_DTINIP', 'F0D_DTFIMP'})	
	
Return oModel 

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@author Mauro Afonso Gonçalves
@since 16.02.2015
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView   := FWFormView():New()
Local oModel  := FWLoadModel("FISA098")
Local oStruct := FWFormStruct(2,"F0D")	

oView:SetModel(oModel)
oView:AddField("VIEW_CAB",oStruct,'FISA098MOD')	
oView:CreateHorizontalBox("CABEC",100)
oView:SetOwnerView("VIEW_CAB","CABEC")	
	
Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} GerAcuProd
Gera o acumulado dos produtos

@author Mauro Afonso Gonçalves
@since 15.04.2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function GerAcuProd(lAuto,cProd,dDtIni,dDtFim)

Local oTProces  := Nil
Local bProcesso	:= { || FSA98PROC( ) }

Pergunte("FSA098",.F.)

oTProces := tNewProcess():New( "FISA098" , STR0001 , bProcesso , STR0006 + STR0007 + STR0008, "FSA098",,,,,.T.,.T.) 
//oTProces:SaveLog(OemToAnsi(STR0008))

Return(.T.)

//-------------------------------------------------------------------
/*/{Protheus.doc} AtuCLN
Popula a tabela CLN

@author Mauro Afonso Gonçalves
@since 15.04.2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function FSA98PROC()
Local nRazao		:=  0
Local nAlqCrPres	:=  0
Local nAliqPrev		:=  3
Local cAlsQry		:= ""
Local cEstEx		:= "EX"
Local dDatabase     := Date()
Local dDtFim		:= lastDay(MonthSub(dDatabase, 1))
Local dCalc			:= dDtFim - (MV_PAR01 * 30)
Local dDtIni		:= CTOD("01"+"/"+StrZero(Month(dCalc),2,0)+"/"+Alltrim(Str(Year(dCalc))))
Local cMVEstado		:= GetMv("MV_ESTADO")
Local oStatement    := Nil
Local cQuery        := ""
Local cSelect       := ""
Local cFrom         := ""
Local cWhere        := ""
Local cGroupBy      := ""

dbSelectArea("SB1")
dbSetOrder(1)

If !Empty(MV_PAR06)
	nAliqPrev := MV_PAR06
EndIf

Begin Sequence   
	
	//Query filtrando filial e regra
	//cSelect += "COLUMN D1_EMISSAO AS DATE "

	cSelect += " SELECT SD1.D1_COD, "
	cSelect += " SUM(CASE WHEN SF1.F1_EST= ? AND SF1.F1_EST<> ? THEN SD1.D1_TOTAL END) AS VlrAcuEst, "
	cSelect += " SUM(CASE WHEN SF1.F1_EST <> ? AND SF1.F1_EST<> ? THEN SD1.D1_TOTAL END) AS VlrAcuInt, "
	cSelect += " SUM(CASE WHEN SF1.F1_EST= ? THEN SD1.D1_TOTAL END) AS VlrAcuExt "

	cFrom   += " FROM ? SD1 "
	cFrom   += " JOIN ? SF1 ON(SF1.F1_FILIAL= ? AND SF1.F1_DOC=SD1.D1_DOC AND SF1.F1_SERIE=SD1.D1_SERIE AND SF1.F1_FORNECE=SD1.D1_FORNECE AND SF1.F1_LOJA=SD1.D1_LOJA AND SF1.D_E_L_E_T_ = ' ') "
	cFrom   += " JOIN ? SB1 ON(SB1.B1_FILIAL= ? AND SB1.B1_COD=SD1.D1_COD AND  SB1.B1_GRUPO >= ? AND SB1.B1_GRUPO <= ? AND SB1.D_E_L_E_T_ = ' ') "

	cWhere  += " WHERE	SD1.D1_FILIAL = ? AND "
	cWhere  += " SD1.D1_EMISSAO BETWEEN ? AND ? AND "
	cWhere  += " SD1.D1_COD >= ? AND SD1.D1_COD <= ? AND SD1.D_E_L_E_T_='' " 
				
	cGroupBy += " GROUP BY SD1.D1_COD "
	cGroupBy += " HAVING SUM(CASE WHEN SF1.F1_EST = ? THEN SD1.D1_TOTAL END) > 0 OR "
	cGroupBy += "		 SUM(CASE WHEN SF1.F1_EST <> ? THEN SD1.D1_TOTAL END) > 0 OR "
	cGroupBy += "		 SUM(CASE WHEN SF1.F1_EST = ? THEN SD1.D1_TOTAL END) > 0 "

	//Prepara classe para query
	oStatement := FwExecStatement():New(cSelect+cFrom+cWhere+cGroupBy)

	//Informa a query a ser executada ja com ChangeQuery
	oStatement:setString(1,  cMVEstado)
	oStatement:setString(2,  cEstEx)
	oStatement:setString(3,  cMVEstado)
	oStatement:setString(4,  cEstEx)
	oStatement:setString(5,  cEstEx)
	oStatement:SetUnsafe(6,  RetSQLName("SD1"))
	oStatement:SetUnsafe(7,  RetSQLName("SF1"))
	oStatement:SetString(8,  xFilial("SF1"))
	oStatement:SetUnsafe(9,  RetSQLName("SB1"))
	oStatement:SetString(10, xFilial("SB1"))
	oStatement:setString(11, MV_PAR04)
	oStatement:setString(12, MV_PAR05)
	oStatement:SetString(13,  xFilial("SD1"))
	oStatement:SetDate(  14, dDtIni)
	oStatement:SetDate(  15, dDtFim)
	oStatement:setString(16, MV_PAR02)
	oStatement:setString(17, MV_PAR03)
	oStatement:setString(18, cMVEstado)
	oStatement:setString(19, cMVEstado)
	oStatement:setString(20, cEstEx)

	cQuery	:= oStatement:GetFixQuery()
	cAlsQry	:= oStatement:OpenAlias(GetNextAlias())
	
	DbSelectArea(cAlsQry)
	(cAlsQry)->(DbGoTop())

	While !(cAlsQry)->(EOF())
		If !F0D->(MsSeek(xFilial("F0D") + (cAlsQry)->D1_COD + DTOS(dDtIni)))
			RecLock('F0D',.T.)
			F0D->F0D_FILIAL	:= xFilial("F0D")
			F0D->F0D_CODPRD	:= (cAlsQry)->D1_COD 
			F0D->F0D_DTINIP	:= dDtIni
			F0D->F0D_DTFIMP	:= dDtFim
		Else
			RecLock('F0D',.F.)
		EndIf
		F0D->F0D_VLEEST	:= (cAlsQry)->VlrAcuEst 
		F0D->F0D_VLEINT	:= (cAlsQry)->VlrAcuInt
		F0D->F0D_VLEEXT := (cAlsQry)->VlrAcuExt 
		F0D->(MsUnlock())
		/*
		+--------------------------------------------------------------------------------------------------+
		|             Exemplo do calculo para o crédito presumido sobre arroz (Santa Catarina).            |
		+--------------------------------------------------------------------------------------------------+
		|                                                                                                  |
		| A) Percentual previsto para o crédito presumido previsto: 3%;                                    |
		| B) Total de saída no período do Estabelecimento: 500.000,00;                                     |
		| C) Entrada Estadual nos últimos 12 meses: 800.000,00;                                            |
		| D) Estrada total nos últimos 12 meses: 1.000.000,00;                                             |
		| E) Total da saída interestadual de arroz beneficiado pelo próprio estabelecimento: 200.000,00.   |
		|                                                                                                  |
		| Cálculo:                                                                                         |
		| F) Razão: C / D (800.000 / 1.000.000) = 0,8                                                      |
		| G) F * A (0,80 * 3) = 2,4                                                                        |
		| H) E * G (200.000 * 2,4%) = 4.800,00                                                             |
		+--------------------------------------------------------------------------------------------------+
		| O resultado do item "G" será gravado na alíquota de crédito presumido no produto para utilização |
		| do processo de faturamento padrão do protheus.                                                   |
		+--------------------------------------------------------------------------------------------------+
		*/
		nRazao 		:= F0D->F0D_VLEEST / (  F0D->F0D_VLEINT + F0D->F0D_VLEEST + F0D->F0D_VLEEXT )
		nAlqCrPres	:= ( nRazao * nAliqPrev )
		IF SB1->(MsSeek(xFilial("SB1")+F0D->F0D_CODPRD))
			RecLock('SB1',.F.)
			SB1->B1_CRDPRES := nAlqCrPres
			SB1->(MsUnlock())
		Endif
		(cAlsQry)->(DbSkip())
	Enddo	
	(cAlsQry)->(DbCloseArea())

	//Destroi a classe
	oStatement:Destroy()

End Sequence

Return .T.
