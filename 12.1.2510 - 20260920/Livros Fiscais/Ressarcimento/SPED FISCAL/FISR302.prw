#Include "FISR302.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "REPORT.CH" 

//-------------------------------------------------------------------
/*/{Protheus.doc} FISR302

Relatorio de conferencia Apuração do ICMS Presumido e Efetivo.

@return	Nil

@author Eduardo Vicente da Silva
@since 30/01/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Function FISR302()
Local	oReport

						
If TRepInUse() //Verifica se relatorios personalizaveis esta disponivel

	If Pergunte("FISR302",.T.)
		oReport:= ReportDef(mv_par01,mv_par02)
		oReport:PrintDialog()
	Endif	

Else
	Alert(STR0001)  //"Rotina disponível apenas em TReport (Relatório Personalizável)."
Endif

Return    

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportDef

Impressao do relatorio

@return Nil

@author Eduardo V. da Silva
@since 30/01/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ReportDef(cAnoMes, cTpImp)
Local	oReport
Local	oSection, oSection1, oBreak, oBreak2
Local	aSF2Stru	:= {} 
Local	aCD0Stru	:= {} 
Local	cQuery		:= GetNextAlias()
Local 	cTitRel		:= STR0002  //"Relatório de Conferência"

Private lAutomato := Iif(IsBlind(),.T.,.F.)

IF lAutomato
    cAnoMes := MV_PAR01      
    cTpImp  := MV_PAR02
EndIF

oReport := TReport():New("FISR302",cTitRel,"FISR302",{|oReport| ReportPrint(oReport,oSection,cQuery,cAnoMes,cTpImp)},cTitRel)
oReport:SetTotalInLine(.F.)
oReport:lHeaderVisible := .T.

oSection := TRSection():New(oReport,cTitRel,{cQuery,"CIG","CIH","CII","CIL","SA1","SA2","SB1"},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/)
oSection:lHeaderVisible := .F.
oSection:SetHeaderSection(.T.)
oSection:SetHeaderPage(.T.)
oSection:SetLinesBefore(2)

If cTpImp == 1
    TRCell():New(oSection,"CIG_PERIOD"	,cQuery,STR0003    ,/*cPicture*/		        ,TamSx3("CIG_PERIOD")[1],/*lPixel*/,/*{|| code-block de impressao }*/)  
    TRCell():New(oSection,"CIG_VCREDI"	,cQuery,STR0004    ,PesqPict("CIG","CIG_VCREDI"),TamSx3("CIG_VCREDI")[1], /*lPixel*/,/*{|| code-block de impressao }*/) 
    TRCell():New(oSection,"CIG_VRESSA"	,cQuery,STR0005    ,PesqPict("CIG","CIG_VRESSA"),TamSx3("CIG_VRESSA")[1],/*lPixel*/,/*{|| code-block de impressao }*/)  
    TRCell():New(oSection,"CIG_REFECP"	,cQuery,STR0006    ,PesqPict("CIG","CIG_REFECP"),TamSx3("CIG_REFECP")[1],/*lPixel*/,/*{|| code-block de impressao }*/)  
    TRCell():New(oSection,"CIG_VCMPL"	,cQuery,STR0007    ,PesqPict("CIG","CIG_VCMPL "),TamSx3("CIG_VCMPL ")[1],/*lPixel*/,/*{|| code-block de impressao }*/)  
    TRCell():New(oSection,"CIG_VCMFCP"	,cQuery,STR0008    ,PesqPict("CIG","CIG_VCMFCP"),TamSx3("CIG_VCMFCP")[1],/*lPixel*/,/*{|| code-block de impressao }*/)  
ElseIf cTpImp == 2      
    TRCell():New(oSection,"CIH_PERIOD"	,cQuery,STR0003     ,/*cPicture*/				 ,TamSx3("CIH_PERIOD")[1], /*lPixel*/,/*{|| code-block de impressao }*/) 
    TRCell():New(oSection,"CIH_ENQLEG"	,cQuery,STR0009     ,/*cPicture*/				 ,TamSx3("CIH_ENQLEG")[1], /*lPixel*/,/*{|| code-block de impressao }*/) 
    TRCell():New(oSection,"CIH_REGRA"	,cQuery,STR0010     ,/*cPicture*/				 ,TamSx3("CIH_REGRA ")[1],/*lPixel*/,/*{|| code-block de impressao }*/)  
    TRCell():New(oSection,"CIH_VCREDI"	,cQuery,STR0004     ,PesqPict("CIH","CIH_VCREDI"),TamSx3("CIH_VCREDI")[1],/*lPixel*/,/*{|| code-block de impressao }*/)  
    TRCell():New(oSection,"CIH_VRESSA"	,cQuery,STR0005     ,PesqPict("CIH","CIH_VRESSA"),TamSx3("CIH_VRESSA")[1],/*lPixel*/,/*{|| code-block de impressao }*/)  
    TRCell():New(oSection,"CIH_REFECP"	,cQuery,STR0006     ,PesqPict("CIH","CIH_REFECP"),TamSx3("CIH_REFECP")[1],/*lPixel*/,/*{|| code-block de impressao }*/)  
    TRCell():New(oSection,"CIH_VCOMPL"	,cQuery,STR0007     ,PesqPict("CIH","CIH_VCOMPL"),TamSx3("CIH_VCOMPL")[1],/*lPixel*/,/*{|| code-block de impressao }*/)  
    TRCell():New(oSection,"CIH_VCMFCP"	,cQuery,STR0008     ,PesqPict("CIH","CIH_VCMFCP"),TamSx3("CIH_VCMFCP")[1],/*lPixel*/,/*{|| code-block de impressao }*/)  
ElseIf cTpImp == 3
    TRCell():New(oSection,"CII_PERIOD"	,cQuery,STR0003     ,/*cPicture*/				 ,TamSx3("CII_PERIOD")[1],/*lPixel*/,/*{|| code-block de impressao }*/)  
    TRCell():New(oSection,"CII_NFISCA"	,cQuery,STR0011     ,/*cPicture*/				 ,TamSx3("CII_NFISCA")[1],/*lPixel*/,/*{|| code-block de impressao }*/)  
    TRCell():New(oSection,"CII_SERIE"	,cQuery,STR0012     ,/*cPicture*/				 ,TamSx3("CII_SERIE ")[1],/*lPixel*/,/*{|| code-block de impressao }*/)  
    TRCell():New(oSection,"CII_PARTIC"	,cQuery,STR0013     ,/*cPicture*/				 ,TamSx3("CII_PARTIC")[1], /*lPixel*/,/*{|| code-block de impressao }*/)  
    TRCell():New(oSection,"CII_LOJA"	,cQuery,STR0014     ,/*cPicture*/				 ,TamSx3("CII_LOJA  ")[1],  /*lPixel*/,/*{|| code-block de impressao }*/) 
    TRCell():New(oSection,"CII_ITEM"	,cQuery,STR0015     ,/*cPicture*/				 ,TamSx3("CII_ITEM  ")[1],/*lPixel*/,/*{|| code-block de impressao }*/)  
    TRCell():New(oSection,"CII_PRODUT"	,cQuery,STR0016     ,/*cPicture*/				 ,TamSx3("CII_PRODUT")[1],  /*lPixel*/,/*{|| code-block de impressao }*/)  
    TRCell():New(oSection,"CII_ENQLEG"	,cQuery,STR0009     ,/*cPicture*/                ,TamSx3("CII_ENQLEG")[1],/*lPixel*/,/*{|| code-block de impressao }*/)  
    TRCell():New(oSection,"CII_QTDMOV"	,cQuery,STR0017     ,PesqPict("CII","CII_QTDMOV"),TamSx3("CII_QTDMOV")[1],/*lPixel*/,/*{|| code-block de impressao }*/)  
    TRCell():New(oSection,"CII_VCREDI"	,cQuery,STR0004     ,PesqPict("CII","CII_VCREDI"),TamSx3("CII_VCREDI")[1],/*lPixel*/,/*{|| code-block de impressao }*/)  
    TRCell():New(oSection,"CII_VRESSA"	,cQuery,STR0005     ,PesqPict("CII","CII_VRESSA"),TamSx3("CII_VRESSA")[1],/*lPixel*/,/*{|| code-block de impressao }*/)  
    TRCell():New(oSection,"CII_VREFCP"	,cQuery,STR0006     ,PesqPict("CII","CII_VREFCP"),TamSx3("CII_VREFCP")[1],/*lPixel*/,/*{|| code-block de impressao }*/)  
    TRCell():New(oSection,"CII_VCMPL"	,cQuery,STR0007     ,PesqPict("CII","CII_VCMPL") ,TamSx3("CII_VCMPL ")[1],/*lPixel*/,/*{|| code-block de impressao }*/)  
    TRCell():New(oSection,"CII_VCMFCP"	,cQuery,STR0008     ,PesqPict("CII","CII_VCMFCP"),TamSx3("CII_VCMFCP")[1],/*lPixel*/,/*{|| code-block de impressao }*/)  
EndIf

Return(oReport)

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportPrint

Impressao do relatorio

@return Nil

@author Mauro A. Gonçalves
@since 05/01/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ReportPrint(oReport,oSection,cQuery,cAnoMes,cTpImp)

Local cSelect	:= ""
Local cFrom     := ""
Local cWhere    := ""
Local cOrder     := ""

If cTpImp == 1
    cSelect := "CIG.CIG_FILIAL,CIG.CIG_PERIOD,CIG.CIG_IDAPUR,CIG.CIG_VCREDI,CIG.CIG_VRESSA,CIG.CIG_REFECP,CIG.CIG_VCMPL ,CIG.CIG_VCMFCP"
    cFrom   := RetSqlName("CIG") + " CIG "
    cWhere  := "CIG.CIG_FILIAL = '" + xFilial("CIG") + "' AND "
    cWhere  += "CIG.CIG_PERIOD = '" + cAnoMes + "' AND "    
    cWhere  += "CIG.D_E_L_E_T_ = ' ' "
    
ElseIf cTpImp == 2
    cSelect := "CIH.CIH_FILIAL,CIH.CIH_PERIOD,CIH.CIH_IDAPUR,CIH.CIH_ENQLEG,CIH.CIH_VCREDI,CIH.CIH_VRESSA,CIH.CIH_REFECP,CIH.CIH_VCOMPL,CIH.CIH_VCMFCP,CIH.CIH_REGRA"    
    cFrom   := RetSqlName("CIH") + " CIH "
    cWhere  := "CIH.CIH_FILIAL = '" + xFilial("CIH") + "' AND "
    cWhere  += "CIH.CIH_PERIOD = '" + cAnoMes + "' AND "    
    cWhere  += "CIH.D_E_L_E_T_ = ' ' "     

ElseIf cTpImp == 3
    cSelect := "CII.CII_FILIAL, CII.CII_PERIOD, CII.CII_LIVRO , CII.CII_IDAPUR, CII.CII_NFISCA, CII.CII_SERIE , CII.CII_PARTIC, CII.CII_LOJA  , CII.CII_DTMOV , CII.CII_TPMOV , CII.CII_ESPECI, CII.CII_ITEM  , CII.CII_PRODUT, CII.CII_CST   , CII.CII_CFOP  , CII.CII_ENQLEG, CII.CII_QTDMOV,"
    cSelect += "CII.CII_UNID  , CII.CII_VUNIT , CII.CII_ICMEFS, CII.CII_VUCRED, CII.CII_MUBST , CII.CII_MUVSTF, CII.CII_MUVSF , CII.CII_VUREST, CII.CII_VURTFC, CII.CII_VUCST , CII.CII_VUCFC , CII.CII_CODRES, CII.CII_ICMEFE, CII.CII_BURET , CII.CII_VURET , CII.CII_VURFCP, CII.CII_NUMDA ,"
    cSelect += "CII.CII_CODDA , CII.CII_MUCRED, CII.CII_QTDSLD, CII.CII_VCREDI, CII.CII_VRESSA, CII.CII_VREFCP, CII.CII_VCMPL , CII.CII_VCMFCP, CII.CII_TPREG , CII.CII_PDV   , CII.CII_REGRA , CII.CII_ORDEM "
    cFrom   := RetSqlName("CII") + " CII "
    cWhere  := "CII.CII_FILIAL = '" + xFilial("CII") + "' AND "
    cWhere  += "CII.CII_PERIOD = '" + cAnoMes + "' AND "    
    cWhere  += "CII.D_E_L_E_T_ = ' ' " 

EndIf

cSelect := "%" + cSelect + "%"
cFrom   := "%" + cFrom   + "%"
cWhere  := "%" + cWhere  + "%"
cOrder	:= '%'+cOrder+'%'

oSection:BeginQuery()

BeginSql Alias cQuery
    /*
	If cTpImp == 3
        COLUMN F3R_DTMOV AS DATE
    EndIf
	*/		
    SELECT %Exp:cSelect%
	FROM  %Exp:cFrom% 
	WHERE %Exp:cWhere%
    //Order by %Exp:cOrder%

EndSQL

oSection:EndQuery()

oReport:SetMeter((cQuery)->(RecCount()))

//-- Necessario para que o usuario possa acrescentar qualquer coluna das tabelas que compoem a secao.
If cTpImp == 2
    TRPosition():New(oSection ,"CIM",1,{||xFilial("CIM")+(cQuery)->CIH_REGRA})
EndIf
If cTpImp == 3
    TRPosition():New(oSection,"SA1",1,{||xFilial("SA1")+(cQuery)->(CII_PARTIC+CII_LOJA)})
    TRPosition():New(oSection,"SA2",1,{||xFilial("SA2")+(cQuery)->(CII_PARTIC+CII_LOJA)})
    TRPosition():New(oSection,"SB1",1,{||xFilial("SB1")+(cQuery)->(CII_PRODUT)})
EndIf

oReport:Section(1):Init()

While !oReport:Cancel() .And. !(cQuery)->(Eof())

    If cTpImp == 1
        oSection:Cell("CIG_PERIOD"):SetValue((cQuery)->CIG_PERIOD)
        oSection:Cell("CIG_VCREDI"):SetValue((cQuery)->CIG_VCREDI)
        oSection:Cell("CIG_VRESSA"):SetValue((cQuery)->CIG_VRESSA)
        oSection:Cell("CIG_REFECP"):SetValue((cQuery)->CIG_REFECP)
        oSection:Cell("CIG_VCMPL") :SetValue((cQuery)->CIG_VCMPL)
        oSection:Cell("CIG_VCMFCP"):SetValue((cQuery)->CIG_VCMFCP)        
    
    ElseIf cTpImp == 2
        oSection:Cell("CIH_PERIOD"):SetValue((cQuery)->CIH_PERIOD)
        oSection:Cell("CIH_ENQLEG"):SetValue((cQuery)->CIH_ENQLEG)
        oSection:Cell("CIH_REGRA"):SetValue((cQuery)->CIH_REGRA)
        oSection:Cell("CIH_VCREDI"):SetValue((cQuery)->CIH_VCREDI)
        oSection:Cell("CIH_VRESSA"):SetValue((cQuery)->CIH_VRESSA)
        oSection:Cell("CIH_REFECP"):SetValue((cQuery)->CIH_REFECP)
        oSection:Cell("CIH_VCOMPL"):SetValue((cQuery)->CIH_VCOMPL)
        oSection:Cell("CIH_VCMFCP"):SetValue((cQuery)->CIH_VCMFCP)        
    
    ElseIf cTpImp == 3
        oSection:Cell("CII_PERIOD"):SetValue((cQuery)->CII_PERIOD)
        oSection:Cell("CII_NFISCA"):SetValue((cQuery)->CII_NFISCA)
        oSection:Cell("CII_SERIE"):SetValue((cQuery)->CII_SERIE)
        oSection:Cell("CII_PARTIC"):SetValue((cQuery)->CII_PARTIC)
        oSection:Cell("CII_LOJA"):SetValue((cQuery)->CII_LOJA)
        oSection:Cell("CII_ITEM"):SetValue((cQuery)->CII_ITEM)
        oSection:Cell("CII_PRODUT"):SetValue((cQuery)->CII_PRODUT)
        oSection:Cell("CII_ENQLEG"):SetValue((cQuery)->CII_ENQLEG)
        oSection:Cell("CII_QTDMOV"):SetValue((cQuery)->CII_QTDMOV)
        oSection:Cell("CII_VCREDI"):SetValue((cQuery)->CII_VCREDI)
        oSection:Cell("CII_VRESSA"):SetValue((cQuery)->CII_VRESSA)        
        oSection:Cell("CII_VREFCP"):SetValue((cQuery)->CII_VREFCP)        
        oSection:Cell("CII_VCMPL"):SetValue((cQuery)->CII_VCMPL)        
        oSection:Cell("CII_VCMFCP"):SetValue((cQuery)->CII_VCMFCP)        
    EndIf

	oReport:Section(1):PrintLine()
				
	(cQuery)->(dbSkip())
	oReport:IncMeter()
EndDo

(cQuery)->(dbCloseArea())

oReport:Section(1):Finish()
oReport:Section(1):SetPageBreak(.T.)

Return(oReport)
