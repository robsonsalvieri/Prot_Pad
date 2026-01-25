#Include "protheus.ch"
#Include "rwmake.ch"
#Include "fwlibversion.ch"
#Include "FISR088.ch"

Static __lVerLib	:= Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ FISR088  ³ Autor ³ Gpe Santacruz         ³ Data ³21/04/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Informe de DIOT                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FISR088                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Alf. Medrano³17/05/18³DMINA-2612³En Fun PrintReport por cada sucursal  ³±±
±±³            ³        ³          ³se crea un query asignando UNION ALL  ³±±
±±³            ³        ³          ³para uso de Xfilial en tablas con dif.³±±
±±³            ³        ³          ³permisos en tablas SA2 y CE8 (Exclusi-³±±
±±³            ³        ³          ³vas vs Compartidas)                   ³±±
±±³Alf. Medrano³21/05/18³DMINA-3163³En fun PrintReport se asigna Order by ³±±
±±³            ³        ³          ³al Final de query para Union ALL      ³±±
±±³LuisEnríquez³14/03/19³DMINA-6191³Se agrega columna para impresión del  ³±±
±±³            ³        ³          ³campo CE8_BASE8 de IVA Fronterizo del ³±±
±±³            ³        ³          ³8% para tipo analítico y resumen.(MEX)³±±
±±³  Marco A.  ³02/09/19³DMINA-7263³Se realizan cambios para evitar error ³±±
±±³            ³        ³          ³en impresion de Base 8 de IVA y se    ³±±
±±³            ³        ³          ³depura el fuente. (MEX)               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function FISR088()
Local aArea		:= GetArea()
Local oReport	:= Nil
Local cDiotVer	:= "1"

Private NomeProg	:= "FISR088"
Private _cPar01		:= ""
Private _cPar02		:= ""
Private _cPar03		:= ""
Private cPerg		:= "FISR088"

If cPaisLoc == "MEX"
	cDiotVer := SuperGetMV("MV_DIOTVER", .F., "1")
EndIf

If Pergunte(cPerg,.t.)
	_cPar01:=MV_PAR01
	_cPar02:=MV_PAR02
	_cPar03:=MV_PAR03

	If cDiotVer == "1"
	   if _cPar03==1 //Analitico
		   oReport := ReportDef()
	   else //resumen
		  oReport := RepDef_RESUMEN()
	   ENDIF
	Else	// Año >= 2025
		If _cPar03 == 1 //Analitico
			oReport := ReportDef2()
		Else //resumen
			oReport := RepDefRes2()
		EndIf
	EndIf

	oReport:PrintDialog()
ENDIF

RestArea(aArea)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³ ReportDef ³ Autor ³ Gpe Santacruz        ³ Data ³21/04/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripcio³ Funcion que genera el Reporte                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ReportDef
Local aArea		:= GetArea()
Local oReport	:= Nil
Local oSection1	:= Nil
Local oSection2	:= Nil
Local oSection3	:= Nil

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01       // Mes y año                                  ³
//³ mv_par02       // Rango de sucursales                        ³
//³ mv_par03       // Tipo de informe                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cTitulo:=OEMTOANSI(STR0002) // "DECLARACION INFORMATIVA DE OPERACIONES CON TERCEROS"

cTitulo := Trim(cTitulo)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao do componente de impressao                                      ³
//³TReport():New                                                           ³
//³ExpC1 : Nome do relatorio                                               ³
//³ExpC2 : Titulo                                                          ³
//³ExpC3 : Pergunte                                                        ³
//³ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  ³
//³ExpC5 : Descricao                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oReport:=TReport():New(NomeProg,OemToAnsi(cTitulo),"FISR088",{|oReport| PrintReport(oReport)})

Pergunte("FISR088",.F.)
oReport:SetLandscape()       // Define a orientacao de pagina do relatorio como retrato.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao da celulas da secao do relatorio                                ³
//³TRCell():New                                                            ³
//³ExpO1 : Objeto TSection que a secao pertence                            ³
//³ExpC2 : Nome da celula do relatório. O SX3 será consultado              ³
//³ExpC3 : Nome da tabela de referencia da celula                          ³
//³ExpC4 : Titulo da celula                                                ³
//³        Default : X3Titulo()                                            ³
//³ExpC5 : Picture                                                         ³
//³        Default : X3_PICTURE                                            ³
//³ExpC6 : Tamanho                                                         ³
//³        Default : X3_TAMANHO                                            ³
//³ExpL7 : Informe se o tamanho esta em pixel                              ³
//³        Default : False                                                 ³
//³ExpB8 : Bloco de código para impressao.                                 ³
//³        Default : ExpC2                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criacao da Primeira Secao: Encabezado de la Sucursal  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

oSection1:= TRSection():New(oReport,oemtoansi(STR0003),{"QRYCE8"},,/*Campos do SX3*/,/*Campos do SIX*/) // "EncSucur"

oSection1:SetTotalInLine(.F.)
oSection1:SetHeaderSection(.T.)	//Exibe Cabecalho da Secao
oSection1:SetHeaderPage(.F.)	//Exibe Cabecalho da Secao
oSection1:SetLineStyle(.t.)   //Pone titulo del campo y aun lado el y valor
oSection1:SetCharSeparator(":")
oSection1:SetHeaderBreak(.T.)

TRCell():New(oSection1,"CE8_FILIAL","QRYCE8",STR0030 ,PesqPict("CE8","D4_FILIAL")     ,TamSx3("D4_FILIAL")[1])//"Sucursal  "
TRCell():New(oSection1,"M0_NOME","QRYCE8","" ,/*Pespiq*/    ,50)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criacao da 2da.     Secao: Proveedor  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSection2:= TRSection():New(oReport,oemtoansi(STR0004),{"QRYCE8"},,/*Campos do SX3*/,/*Campos do SIX*/)
oSection2:SetTotalInLine(.F.)
oSection2:SetHeaderSection(.T.)	//Exibe Cabecalho da Secao
oSection2:SetHeaderPage(.F.)

oSection2:SetLineStyle(.t.)   //Pone titulo del campo y aun lado el y valor

oSection2:SetCharSeparator(":")
oSection2:SetHeaderBreak(.T.)

TRCell():New(oSection2,"CE8_PROV"	,"QRYCE8",STR0006		,PesqPict("CE8","CE8_PROV")		,TamSx3("CE8_PROV")[1]) 		//"Proveedor"
TRCell():New(oSection2,"CE8_TIENDA","QRYCE8",""			,PesqPict("CE8","CE8_TIENDA")  	,TamSx3("CE8_TIENDA")[1])
TRCell():New(oSection2,"A2_NOME"	,"QRYCE8",""			,PesqPict("SA2","A2_NOME")     ,TamSx3("A2_NOME")[1])
TRCell():New(oSection2,"CE8_RFC"	,"QRYCE8",STR0007		,PesqPict("CE8","CE8_RFC")     ,TamSx3("CE8_RFC")[1])		// "R.F.C."
TRCell():New(oSection2,"CE8_IDFISC","QRYCE8",STR0008		,PesqPict("CE8","CE8_IDFISC")  	,TamSx3("CE8_IDFISC")[1])	// "ID"
TRCell():New(oSection2,"CE8_TIPTER","QRYCE8",STR0009		,/*PesqPict("CE8","CE8_TIPTER")  */	,TamSx3("CE8_TIPTER")[1])	// "Tipo Ter"
TRCell():New(oSection2,"CE8_sep1"  ,""     ,""     	,/*PesqPict("CE8","CE8_TIPTER")  */	,2)	// "Tipo Ter"
TRCell():New(oSection2,"CE8_TIPOPE","QRYCE8",STR0010 	,/*PesqPict("CE8","CE8_TIPOPE")*/  	,TamSx3("CE8_TIPOPE")[1])	// "Operación"
TRCell():New(oSection2,"CE8_sep2"  ,""     ,""     	,/*PesqPict("CE8","CE8_TIPTER")  */	,2)	// "Tipo Ter"
TRCell():New(oSection2,"CE8_PAIS"	,"QRYCE8",STR0011		,/*PesqPict("CE8","CE8_PAIS")*/   	,TamSx3("CE8_PAIS")[1])		// "Pais"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criacao da 3ra.     Secao: Detalle  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSection3:= TRSection():New(oReport,oemtoansi(STR0005),{"QRYCE8"},,/*Campos do SX3*/,/*Campos do SIX*/) //"dET"

oSection3:SetTotalInLine(.f.)
oSection3:SetHeaderBreak(.T.)
oSection3:SetHeaderSection(.T.)
oSection3:SetHeaderPage(.T.)
oSection3:SetLinesBefore(0)

oSection3:SetLineStyle(.F.)   //Pone titulo del campo y aun lado el y valor

TRCell():New(oSection3,"CE8_FILIAL","QRYCE8",STR0012) // "Filial"
TRCell():New(oSection3,"CE8_PROV",  "QRYCE8",STR0013) // "Prov"
TRCell():New(oSection3,"CE8_TIENDA","QRYCE8",STR0014) // "Tda"

TRCell():New(oSection3,"CE8_NUMDOC","QRYCE8",STR0015,,TamSx3("CE8_NUMDOC")[1]+TamSx3("CE8_SERIE")[1]+1,,,"LEFT",,"LEFT") // "Documento"
TRCell():New(oSection3,"CE8_FECDOC","QRYCE8",STR0016,,10,,,"LEFT",,"LEFT")	// "Fecha"
TRCell():New(oSection3,"CE8_TIPO"  ,"QRYCE8",STR0017,,5,,,"LEFT",,"LEFT")		// "Tipo"

TRCell():New(oSection3,"CE8_BA1516","QRYCE8",STR0018		,"999,999,999.99",19,,,"RIGHT",,"RIGHT") 	// "Base 15/16%"
TRCell():New(oSection3,"CE8_BASE15","QRYCE8",STR0019		,"999,999,999.99",19,,,"RIGHT",,"RIGHT")	// "Base 15%"
TRCell():New(oSection3,"CE8_BA1011","QRYCE8",STR0020		,"999,999,999.99",19,,,"RIGHT",,"RIGHT")	// "Base 10/11%"
TRCell():New(oSection3,"CE8_BASE10","QRYCE8",STR0021		,"999,999,999.99",19,,,"RIGHT",,"RIGHT")	// "Base 10%"
If CE8->(ColumnPos("CE8_BASE8")) > 0
	TRCell():New(oSection3,"CE8_BASE8", "QRYCE8",STR0052        ,"999,999,999.99",19,,,"RIGHT",,"RIGHT")	// "Bs. 8%"
EndIf
TRCell():New(oSection3,"CE8_BI1516","QRYCE8",STR0022		,"999,999,999.99",19,,,"RIGHT",,"RIGHT")	// "Bs.Imp.15/16%"
TRCell():New(oSection3,"CE8_BI1011","QRYCE8",STR0023 	    ,"999,999,999.99",19,,,"RIGHT",,"RIGHT")	// "Bs.Imp.10/11%"
TRCell():New(oSection3,"CE8_BASIEX","QRYCE8",STR0024		,"999,999,999.99",14,,,"RIGHT",,"RIGHT")	// "Bs.Imp.Exenta"
TRCell():New(oSection3,"CE8_BASE0", "QRYCE8",STR0025		,"999,999,999.99",14,,,"RIGHT",,"RIGHT")	// "Base 0%"
TRCell():New(oSection3,"CE8_BASEEX","QRYCE8",STR0026		,"999,999,999.99",14,,,"RIGHT",,"RIGHT")	// "Base Exenta"
TRCell():New(oSection3,"CE8_IVARET","QRYCE8",STR0027		,"999,999,999.99",14,,,"RIGHT",,"RIGHT")	// "I.V.A. Ret."
TRCell():New(oSection3,"CE8_IVADEV","QRYCE8",STR0028		,"999,999,999.99",14,,,"RIGHT",,"RIGHT")	// "I.V.A. Dev."

oSection3:Cell("CE8_FILIAL"):HideHeader()
oSection3:Cell("CE8_FILIAL"):hide()

oSection3:Cell("CE8_PROV"):HideHeader()
oSection3:Cell("CE8_PROV"):hide()
oSection3:Cell("CE8_TIENDA"):HideHeader()
oSection3:Cell("CE8_TIENDA"):hide()

//Total por proveedor
oBreak := TRBreak():New(oSection3,oSection3:Cell("CE8_PROV"),"SubTotal",.f.,"")  //Falso para que muestre el total debajo de la columna correspondiente

TRFunction():New(oSection3:Cell("CE8_BA1516"),NIL,"SUM",oBreak,"","999,999,999.99",/*uFormula*/,.F.,.F.)
TRFunction():New(oSection3:Cell("CE8_BASE15"),NIL,"SUM",oBreak,"","999,999,999.99",/*uFormula*/,.F.,.F.)
TRFunction():New(oSection3:Cell("CE8_BA1011"),NIL,"SUM",oBreak,"","999,999,999.99",/*uFormula*/,.F.,.F.)
TRFunction():New(oSection3:Cell("CE8_BASE10"),NIL,"SUM",oBreak,"","999,999,999.99",/*uFormula*/,.F.,.F.)
If CE8->(ColumnPos("CE8_BASE8")) > 0
	TRFunction():New(oSection3:Cell("CE8_BASE8"),NIL,"SUM",oBreak,"","999,999,999.99",/*uFormula*/,.F.,.F.)
EndIf
TRFunction():New(oSection3:Cell("CE8_BI1516"),NIL,"SUM",oBreak,"","999,999,999.99",/*uFormula*/,.F.,.F.)
TRFunction():New(oSection3:Cell("CE8_BI1011"),NIL,"SUM",oBreak,"","999,999,999.99",/*uFormula*/,.F.,.F.)
TRFunction():New(oSection3:Cell("CE8_BASIEX"),NIL,"SUM",oBreak,"","999,999,999.99",/*uFormula*/,.F.,.F.)
TRFunction():New(oSection3:Cell("CE8_BASE0" ),NIL,"SUM",oBreak,"","999,999,999.99",/*uFormula*/,.F.,.F.)
TRFunction():New(oSection3:Cell("CE8_BASEEX"),NIL,"SUM",oBreak,"","999,999,999.99",/*uFormula*/,.F.,.F.)
TRFunction():New(oSection3:Cell("CE8_IVARET"),NIL,"SUM",oBreak,"","999,999,999.99",/*uFormula*/,.F.,.F.)
TRFunction():New(oSection3:Cell("CE8_IVADEV"),NIL,"SUM",oBreak,"","999,999,999.99",/*uFormula*/,.F.,.F.)

//Total por Filial
oBreak1 := TRBreak():New(oSection1,oSection1:Cell("CE8_FILIAL"),"Total Filial",.f.,"")  //Falso para que muestre el total debajo de la columna correspondiente

TRFunction():New(oSection3:Cell("CE8_BA1516"),NIL,"SUM",oBreak1,"","999,999,999.99",/*uFormula*/,.f.,.F.)
TRFunction():New(oSection3:Cell("CE8_BASE15"),NIL,"SUM",oBreak1,"","999,999,999.99",/*uFormula*/,.f.,.F.)
TRFunction():New(oSection3:Cell("CE8_BA1011"),NIL,"SUM",oBreak1,"","999,999,999.99",/*uFormula*/,.f.,.F.)
TRFunction():New(oSection3:Cell("CE8_BASE10"),NIL,"SUM",oBreak1,"","999,999,999.99",/*uFormula*/,.f.,.F.)
If CE8->(ColumnPos("CE8_BASE8")) > 0
	TRFunction():New(oSection3:Cell("CE8_BASE8"),NIL,"SUM",oBreak1,"","999,999,999.99",/*uFormula*/,.f.,.F.)
EndIf
TRFunction():New(oSection3:Cell("CE8_BI1516"),NIL,"SUM",oBreak1,"","999,999,999.99",/*uFormula*/,.f.,.F.)
TRFunction():New(oSection3:Cell("CE8_BI1011"),NIL,"SUM",oBreak1,"","999,999,999.99",/*uFormula*/,.f.,.F.)
TRFunction():New(oSection3:Cell("CE8_BASIEX"),NIL,"SUM",oBreak1,"","999,999,999.99",/*uFormula*/,.f.,.F.)
TRFunction():New(oSection3:Cell("CE8_BASE0" ),NIL,"SUM",oBreak1,"","999,999,999.99",/*uFormula*/,.f.,.F.)
TRFunction():New(oSection3:Cell("CE8_BASEEX"),NIL,"SUM",oBreak1,"","999,999,999.99",/*uFormula*/,.f.,.F.)
TRFunction():New(oSection3:Cell("CE8_IVARET"),NIL,"SUM",oBreak1,"","999,999,999.99",/*uFormula*/,.f.,.F.)
TRFunction():New(oSection3:Cell("CE8_IVADEV"),NIL,"SUM",oBreak1,"","999,999,999.99",/*uFormula*/,.f.,.F.)

//TOTAL GENERAL

oBreakF := TRBreak():New(oReport,{|| .t. },STR0029,.f.,"")  //"Total general"  Falso para que muestre el total debajo de la columna correspondiente

TRFunction():New(oSection3:Cell("CE8_BA1516"),NIL,"SUM",oBreakF,"","999,999,999.99",/*uFormula*/,.F.,.f.)
TRFunction():New(oSection3:Cell("CE8_BASE15"),NIL,"SUM",oBreakF,"","999,999,999.99",/*uFormula*/,.F.,.F.)
TRFunction():New(oSection3:Cell("CE8_BA1011"),NIL,"SUM",oBreakF,"","999,999,999.99",/*uFormula*/,.F.,.f.)
TRFunction():New(oSection3:Cell("CE8_BASE10"),NIL,"SUM",oBreakF,"","999,999,999.99",/*uFormula*/,.F.,.f.)
If CE8->(ColumnPos("CE8_BASE8")) > 0
	TRFunction():New(oSection3:Cell("CE8_BASE8"),NIL,"SUM",oBreakF,"","999,999,999.99",/*uFormula*/,.F.,.f.)
EndIf
TRFunction():New(oSection3:Cell("CE8_BI1516"),NIL,"SUM",oBreakF,"","999,999,999.99",/*uFormula*/,.F.,.f.)
TRFunction():New(oSection3:Cell("CE8_BI1011"),NIL,"SUM",oBreakF,"","999,999,999.99",/*uFormula*/,.F.,.f.)
TRFunction():New(oSection3:Cell("CE8_BASIEX"),NIL,"SUM",oBreakF,"","999,999,999.99",/*uFormula*/,.F.,.f.)
TRFunction():New(oSection3:Cell("CE8_BASE0" ),NIL,"SUM",oBreakF,"","999,999,999.99",/*uFormula*/,.F.,.f.)
TRFunction():New(oSection3:Cell("CE8_BASEEX"),NIL,"SUM",oBreakF,"","999,999,999.99",/*uFormula*/,.F.,.f.)
TRFunction():New(oSection3:Cell("CE8_IVARET"),NIL,"SUM",oBreakF,"","999,999,999.99",/*uFormula*/,.F.,.f.)
TRFunction():New(oSection3:Cell("CE8_IVADEV"),NIL,"SUM",oBreakF,"","999,999,999.99",/*uFormula*/,.F.,.f.)

RESTAREA(aArea)
Return oReport

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³ RepDef_RESUMEN³ Autor ³ Gpe Santacruz   ³ Data ³21/04/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripcio³ Funcion que genera el Reporte                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function RepDef_RESUMEN
Local aArea		:= GetArea()
Local oReport	:= Nil
Local oSection1	:= Nil

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01       // Mes y año                                  ³
//³ mv_par02       // Rango de sucursales                        ³
//³ mv_par03       // Tipo de informe                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cTitulo:=OEMTOANSI(STR0002) // "DECLARACION INFORMATIVA DE OPERACIONES CON TERCEROS"

cTitulo := Trim(cTitulo)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao do componente de impressao                                      ³
//³TReport():New                                                           ³
//³ExpC1 : Nome do relatorio                                               ³
//³ExpC2 : Titulo                                                          ³
//³ExpC3 : Pergunte                                                        ³
//³ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  ³
//³ExpC5 : Descricao                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oReport:=TReport():New(NomeProg,OemToAnsi(cTitulo),"FISR088",{|oReport| PrnResumen(oReport)})

Pergunte("FISR088",.F.)
oReport:SetLandscape()       // Define a orientacao de pagina do relatorio como retrato.

oReport:nColSpace:=2
oReport:nFontBody	:= 8 // Define o tamanho da fonte.
oReport:nLineHeight	:= 45 // Define a altura da linha.
oReport:CFONTBODY:="COURIER NEW"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao da celulas da secao do relatorio                                ³
//³TRCell():New                                                            ³
//³ExpO1 : Objeto TSection que a secao pertence                            ³
//³ExpC2 : Nome da celula do relatório. O SX3 será consultado              ³
//³ExpC3 : Nome da tabela de referencia da celula                          ³
//³ExpC4 : Titulo da celula                                                ³
//³        Default : X3Titulo()                                            ³
//³ExpC5 : Picture                                                         ³
//³        Default : X3_PICTURE                                            ³
//³ExpC6 : Tamanho                                                         ³
//³        Default : X3_TAMANHO                                            ³
//³ExpL7 : Informe se o tamanho esta em pixel                              ³
//³        Default : False                                                 ³
//³ExpB8 : Bloco de código para impressao.                                 ³
//³        Default : ExpC2                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criacao da Primeira Secao: Encabezado de la Sucursal                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

oSection1:= TRSection():New(oReport,oemtoansi(STR0003),{"QRYCE8"},,/*Campos do SX3*/,/*Campos do SIX*/) // "EncSucur"

oSection1:SetTotalInLine(.F.)
oSection1:SetHeaderSection(.T.)	//Exibe Cabecalho da Secao
oSection1:SetHeaderPage(.F.)	//Exibe Cabecalho da Secao
oSection1:SetLineStyle(.t.)   //Pone titulo del campo y aun lado el y valor
oSection1:SetCharSeparator(":")
oSection1:SetHeaderBreak(.T.)

TRCell():New(oSection1,"CE8_FILIAL","QRYCE8",STR0030 ,PesqPict("CE8","D4_FILIAL")     ,TamSx3("D4_FILIAL")[1])//"Sucursal  "
TRCell():New(oSection1,"M0_NOME","QRYCE8","" ,/*Pespiq*/    ,50)

//Resumen
oSection2:= TRSection():New(oReport,oemtoansi(STR0031),{"QRYCE8"},,/*Campos do SX3*/,/*Campos do SIX*/) // "Resumen"

oSection2:SetLineStyle(.F.)   //Pone titulo del campo y aun lado el y valor
oSection2:SetHeaderSection(.T.)	//Exibe Cabecalho da Secao
oSection2:SetHeaderPage(.t.)	//Exibe Cabecalho da Secao
oSection2:SetLeftMargin(20)

TRCell():New(oSection2,"DESC"		,"QRYCE8",STR0032,"",88,,,"LEFT",,"LEFT") // "Descripción"
TRCell():New(oSection2,"IMPORTE"	,"QRYCE8",STR0033,"999,999,999.99",20,,,"RIGHT",,"LEFT") // "Importe"

RESTAREA(aArea)
Return oReport

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao     ³ PrintReport³ Autor ³ Gpe Santacruz      ³ Data ³21/04/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripción³ Función para impresion del Reporte                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxis   ³ PrintReport()                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function PrintReport(oReport)
Local oSection1
Local oSection2
Local oSection3
Local cTitle	:= ""
Local nOrdem	:=0
Local cAliasCE8 := "QRYCE8"

Local cQuery	:= ""
Local aFils   	:= {}
Local nTamFil	:= 0
Local nCont		:= 0

if empty(_cPar01)
   msgalert(STR0034) // "Seleccione un periodo"
   return
endif

if empty(_cPar02)
   msgalert(STR0035) // "Seleccione al menos una sucursal"
   return
endif

If !Empty(_cPar02)
    _cPar02:=FS088Traduce(_cPar02)
Endif

Pergunte(oReport:GetParam(),.F.)

		oSection1 	:= oReport:Section(1)
		oSection2 	:= oReport:Section(2)
		oSection3 	:= oReport:Section(3)
		nOrdem	  	:= oReport:GetOrder()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³  Altera o Titulo do Relatorio conforme o parametro selecionado   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cDesMes:=ObtDesMesAnio()
		cTitle 	:= AllTrim(oReport:Title())+ cDesMEs + STR0036	// " - ANALITICO"
		oReport:SetTitle(cTitle)


		If !Empty(_cPar02)
			aFils := STRTOKARR(_cPar02, ',')
			nTamFil := len(aFils)
			For nCont := 1 to nTamFil

				If nCont > 1
					cQuery += " UNION ALL "
				Else
					cQuery := " "
				EndIf

				cXfils = aFils[nCont]

				cQuery += "Select CE8.* ,A2_NOME "
				cQuery += " From "  + RetSqlName("CE8") + " CE8, " + RetSqlName("SA2") + " SA2 "
				cQuery += " WHERE "
				cQuery += " CE8_MESANO='"+_cPar01 + "' "
				cQuery += " AND CE8_FILIAL = " + cXfils + "  AND  A2_FILIAL = '" + xFilial("SA2" , STRTRAN( aFils[nCont], "'", "")) + "'"
				cQuery += " AND CE8_PROV = A2_COD "
				cQuery += " AND CE8_TIENDA = A2_LOJA "
				cQuery += " AND CE8.D_E_L_E_T_=' '"
				cQuery += " AND SA2.D_E_L_E_T_=' '"

				If nCont == nTamFil
					cQuery +=" ORDER BY CE8_FILIAL,CE8_PROV,CE8_TIENDA,CE8_FECDOC "
				EndIf

			Next
		Endif

		Begin Sequence

			cQuery := ChangeQuery(cQuery)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasCE8,.T.,.T.)
			count to nTotal
			oReport:SetMeter(nTotal)
			(cAliasCE8)->(DbGoTop())

			While (cAliasCE8)->(!Eof())
			    cFilRes:=(cAliasCE8)->CE8_filial
				oSection1:Init()
				oSection1:PrintLine()

				While (cAliasCE8)->(!Eof())  .and. cFilRes==(cAliasCE8)->CE8_filial
					cProRes:=(cAliasCE8)->CE8_prov+(cAliasCE8)->CE8_tienda
					oSection2:Init()
					oSection2:PrintLine()
					oSection2:Finish()
					oSection3:Init()

					While (cAliasCE8)->(!Eof())  .and. cFilRes==(cAliasCE8)->CE8_filial .and. 	cProRes==(cAliasCE8)->CE8_prov+(cAliasCE8)->CE8_tienda
							oSection3:Cell("CE8_NUMDOC"):SetValue(alltrim((cAliasCE8)->CE8_NUMDOC)+"-"+alltrim((cAliasCE8)->CE8_SERIE))
							oSection3:PrintLine()
							oReport:IncMeter()
							(cAliasCE8)->(dbskip())
					EndDo
					oSection3:Finish()
				EndDo

				oSection1:Finish()
			EndDo
		End Sequence
		(cAliasCE8)->(dbCloseArea())

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao     ³ PrnResumen ³ Autor ³ Gpe Santacruz      ³ Data ³21/04/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripción³ Función para impresion del Reporte de Resumen             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxis   ³ PrnResumen()                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function PrnResumen(oReport)
Local oSection1		:= Nil
Local oSection2		:= Nil

Local cTitle		:= ""
Local nOrdem		:=	0
Local cAliasCE8		:= "QRYCE8"
Local cOrdem		:= ""
Local lFieldBse8	:= .F.

Local cCposQuery	:= ""
Local cCposFrom		:= ""
Local cWhere		:= ""
Local cGroup		:= ""
Local nTot			:= 0

if empty(_cPar01)
   msgalert(STR0034) // "Seleccione un periodo"
   return
endif

if empty(_cPar02)
   msgalert(STR0035) // "Seleccione al menos una sucursal"
   return
endif

If !Empty(_cPar02)
    _cPar02:=FS088Traduce(_cPar02)
Endif

Pergunte(oReport:GetParam(),.F.)

		oSection1 := oReport:Section(1)
		oSection2 := oReport:Section(2)
		nOrdem	:= oReport:GetOrder()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³  Altera o Titulo do Relatorio conforme o parametro selecionado   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cDesMes:=ObtDesMesAnio()
		cTitle 	:= AllTrim(oReport:Title())+ cDesMEs + STR0037 // " - RESUMEN"
		oReport:SetTitle(cTitle)

				cCposQuery 	:= "% CE8_FILIAL,CE8_MESANO, SUM(CE8_BA1516) nBA1516, SUM(CE8_BASE15) nBA15, SUM(CE8_BA1011) nBA1011,  "
				cCposQuery 	+= " SUM(CE8_BASE10) nBASE10, SUM(CE8_BI1516) nBI1516, SUM(CE8_BI1011) nBAI011,  "
				cCposQuery 	+= " SUM(CE8_BASIEX) nBASIEX, SUM(CE8_BASE0) nBASE0, SUM(CE8_BASEEX) nBASEEX,  "
				cCposQuery 	+= " SUM(CE8_IVARET) nIVARET, SUM(CE8_IVADEV) nIVADEV, SUM(CE8_IVAPAG) nIVAPAG,SUM(CE8_IVPAGI) nIVPAGI "
				If CE8->(ColumnPos("CE8_BASE8")) > 0
					lFieldBse8 := .T.
					cCposQuery += ", SUM(CE8_BASE8) nBASE8 "
				EndIf
				cCposQuery += " %"
				cCposFrom   := "%" + RetSqlName("CE8") + " CE8 "
				cCposFrom   += "%"

				cWhere :="%  "
			    cWhere +=" CE8_MESANO='"+_cPar01+"' and "
				cWhere +=" CE8_FILIAL IN ("+_cPar02+") "

				cWhere+="     AND CE8.D_E_L_E_T_  = ' ' %"

				cGroup:= "% CE8_FILIAL,CE8_MESANO %"
				cOrdem:="%  CE8_FILIAL,CE8_MESANO %"

			BeginSql alias cAliasCE8
				SELECT  %exp:cCposQuery%
				FROM  %exp:cCposFrom%
				WHERE %exp:cWhere%
				GROUP BY %exp:cGroup%
				ORDER BY %exp:cOrdem%
			EndSql

		Begin Sequence
			count to nTotal
			oReport:SetMeter(nTotal)
			(cAliasCE8)->(DbGoTop())

			dbSelectArea( cAliasCE8 )
			While (cAliasCE8)->(!Eof())
			    cFilRes:=(cAliasCE8)->CE8_filial
				oSection1:Init()
				oSection1:PrintLine()
				While (cAliasCE8)->(!Eof())  .and. cFilRes==(cAliasCE8)->CE8_filial
						oSection2:Init()
						nTot := fGetOper((cAliasCE8)->CE8_filial)

						oSection2:Cell("DESC"):SetValue(STR0051)		// "Valor Total pagado a la tasa del 15% o 16% de IVA"
						oSection2:Cell("IMPORTE"):SetValue(nTot)
						oSection2:PrintLine()

						oSection2:Cell("DESC"):SetValue(STR0038)		// "Valor Total pagado a la tasa del 15% o 16% de IVA"
						oSection2:Cell("IMPORTE"):SetValue((cAliasCE8)->nBA1516)
						oSection2:PrintLine()


						oSection2:Cell("DESC"):SetValue(STR0039)		// "Valor Total pagado a la tasa del 15% de IVA"
						oSection2:Cell("IMPORTE"):SetValue((cAliasCE8)->nBA15)
						oSection2:PrintLine()

						oSection2:Cell("DESC"):SetValue(STR0040)		// "Valor Total pagado a la tasa del 10% u 11% de IVA"
						oSection2:Cell("IMPORTE"):SetValue((cAliasCE8)->nBA1011)
						oSection2:PrintLine()

						oSection2:Cell("DESC"):SetValue(STR0041)		// "Valor Total pagado a la tasa del 10%  de IVA"
						oSection2:Cell("IMPORTE"):SetValue((cAliasCE8)->nBASE10)
						oSection2:PrintLine()

						If lFieldBse8
							oSection2:Cell("DESC"):SetValue(STR0053)		// "Valor Total pagado de los actos o actividades sujeto al estímulo de la región fronteriza norte"
							oSection2:Cell("IMPORTE"):SetValue((cAliasCE8)->nBASE8)
							oSection2:PrintLine()
                        EndIf

						oSection2:Cell("DESC"):SetValue(STR0042)		// "Valor Total pagado de importación de bienes y servicios a la tasa del 15% o 16% de IVA"
						oSection2:Cell("IMPORTE"):SetValue((cAliasCE8)->nBI1516)
						oSection2:PrintLine()

						oSection2:Cell("DESC"):SetValue(STR0043)		// "Valor Total pagado de importación de bienes y servicios a la tasa del 10% o 11% de IVA"
						oSection2:Cell("IMPORTE"):SetValue((cAliasCE8)->nBAI011)
						oSection2:PrintLine()

						oSection2:Cell("DESC"):SetValue(STR0044)		// "Valor Total pagado de importación de bienes y servicios que no pagara IVA (Exentos)"
						oSection2:Cell("IMPORTE"):SetValue((cAliasCE8)->nBASIEX)
						oSection2:PrintLine()

						oSection2:Cell("DESC"):SetValue(STR0045)		// "Valor Total pagado a la tasa del 0% de IVA"
						oSection2:Cell("IMPORTE"):SetValue((cAliasCE8)->nBASE0)
						oSection2:PrintLine()

						oSection2:Cell("DESC"):SetValue(STR0046)		// "Valor Total pagado por los que no se pagara el IVA (Exentos)"
						oSection2:Cell("IMPORTE"):SetValue((cAliasCE8)->nBASEEX)
						oSection2:PrintLine()

						oSection2:Cell("DESC"):SetValue(STR0047)		// "IVA Total Retenido por el contribuyente"
						oSection2:Cell("IMPORTE"):SetValue((cAliasCE8)->nIVARET)
						oSection2:PrintLine()

						oSection2:Cell("DESC"):SetValue(STR0048)		// "IVA Total Correspondiente a las devoluciones, descuentos y bonificaciones sobre compras"
						oSection2:Cell("IMPORTE"):SetValue((cAliasCE8)->nIVADEV)
						oSection2:PrintLine()

						oSection2:Cell("DESC"):SetValue(STR0049)		// "IVA Total transferido (pagado) de bienes y servicios excepto importaciones"
						oSection2:Cell("IMPORTE"):SetValue((cAliasCE8)->nIVAPAG)
						oSection2:PrintLine()

						oSection2:Cell("DESC"):SetValue(STR0050)		// "IVA Total pagado en las importaciones de bienes y servicios"
						oSection2:Cell("IMPORTE"):SetValue((cAliasCE8)->nIVPAGI)
						oSection2:PrintLine()

						oSection2:Finish()
						oReport:IncMeter()
						(cAliasCE8)->(dbskip())
				enddo
				oSection1:Finish()
			EndDo
		End Sequence
    	(cAliasCE8)->(dbCloseArea())

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao     ³ObtDesMesAnio³ Autor ³ Gpe Santacruz     ³ Data ³21/04/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripción³ Función para obtener nombre del mes                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxis   ³ ObtDesMesAnio()                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static function ObtDesMesAnio
Local cDes:=''
Local nMes:=val(substr(_cPar01,1,2))
Local cAnio:=alltrim(substr(_cPar01,3,4))
Local cDMes:=''
Do case
	Case  nMes==1
	     cDMes:="ENERO"
	Case  nMes==2
	     cDMes:="FEBRERO"
	Case  nMes==3
	     cDMes:="MARZO"
	Case  nMes==4
	     cDMes:="ABRIL"
	Case  nMes==5
	     cDMes:="MAYO"
	Case  nMes==6
	     cDMes:="JUNIO"
	Case  nMes==7
	     cDMes:="JULIO"
	Case  nMes==8
	     cDMes:="AGOSTO"
	Case  nMes==9
	     cDMes:="SEPTIEMBRE"
	Case  nMes==10
	     cDMes:="OCTUBRE"
	Case  nMes==11
	     cDMes:="NOVIEMBRE"
	Case  nMes==12
	     cDMes:="DICIEMBRE"

EndCase
cDes:=" "+cDMes+" "+cAnio+" "
Return cDes

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao     ³ fGetOper   ³ Autor ³ Gpe Santacruz      ³ Data ³21/04/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripción³ Obtiene Valor Total pagado a la tasa del 15% o 16% de IVA ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxis   ³ fGetOper(ExpC1)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ ExpC1: Filial de tabla CE8                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static function fGetOper(cFilSel)
	Local nRet			:= 0
	Local aArea			:= GetArea()
	Local cAl			:= "QRYCONT"
	Local cWhere		:= ""
	Local lIsDBMsSQL	:= AllTrim(Upper(TcGetDb())) $ "MSSQL7|MSSQL"
	Local cSelect		:= IIf(lIsDBMsSQL, "%COUNT(DISTINCT(CE8_PROV+CE8_TIENDA)) AS TOTAL%",  "%COUNT(DISTINCT(CE8_PROV||CE8_TIENDA)) AS TOTAL%")

	cWhere := "%  "
	cWhere += " CE8_MESANO='"+_cPar01+"' and "
	cWhere += " CE8_FILIAL IN ('"+ cFilSel+ "') "
	cWhere += "     AND CE8.D_E_L_E_T_  = ' ' %"

	BeginSQL alias cAl
		SELECT %exp:cSelect%
		FROM %table:CE8% CE8
		WHERE %exp:cWhere% and %notDel%
	EndSQl

	While (cAl)->(!EOF())
		nRet := (cAl)->TOTAL
		(cAl)->(dbSkip())
	EndDo
	(cAl)->(dbCloseArea())

	RestArea(aArea)

Return nRet

/********************************************* Versión 2025 ***********************************************/

/*/{Protheus.doc} ReportDef2
	Define informe DIOT versión 2025
	@type  Static Function
	@author ARodriguez
	@since 01/03/2025
	@version 12.1.2310
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function ReportDef2
Local oReport		:= Nil
Local oSection1		:= Nil
Local oSection2		:= Nil
Local oSection3		:= Nil
Local oBreak		:= Nil
Local nLenDoc		:= GetSx3Cache("CE8_NUMDOC","X3_TAMANHO")+GetSx3Cache("CE8_SERIE","X3_TAMANHO")+6
Local nLenImp		:= 19
Local cPicImp		:= "999,999,999.99"

Private cTitulo		:= OemToAnsi(STR0002) // "DECLARACION INFORMATIVA DE OPERACIONES CON TERCEROS"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01       // Mes y año                                  ³
//³ mv_par02       // Rango de sucursales                        ³
//³ mv_par03       // Tipo de informe                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Pergunte("FISR088",.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao do componente de impressao                                      ³
//³TReport():New                                                           ³
//³ExpC1 : Nome do relatorio                                               ³
//³ExpC2 : Titulo                                                          ³
//³ExpC3 : Pergunte                                                        ³
//³ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  ³
//³ExpC5 : Descricao                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oReport := TReport():New(NomeProg, OemToAnsi(cTitulo), "FISR088", {|oReport| PrintRep2(oReport)})
oReport:SetDevice(4)			// Planilla Excel
oReport:ParamReadOnly()			// Define se o usuário terá acesso aos parâmetros do relatório

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao da celulas da secao do relatorio                                ³
//³TRCell():New                                                            ³
//³ExpO1 : Objeto TSection que a secao pertence                            ³
//³ExpC2 : Nome da celula do relatório. O SX3 será consultado              ³
//³ExpC3 : Nome da tabela de referencia da celula                          ³
//³ExpC4 : Titulo da celula                                                ³
//³        Default : X3Titulo()                                            ³
//³ExpC5 : Picture                                                         ³
//³        Default : X3_PICTURE                                            ³
//³ExpC6 : Tamanho                                                         ³
//³        Default : X3_TAMANHO                                            ³
//³ExpL7 : Informe se o tamanho esta em pixel                              ³
//³        Default : False                                                 ³
//³ExpB8 : Bloco de código para impressao.                                 ³
//³        Default : ExpC2                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criacao da Primeira Secao: Encabezado de la Sucursal  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

oSection1 := TRSection():New(oReport, OemToAnsi(STR0003), {"QRYCE8"},,/*Campos do SX3*/,/*Campos do SIX*/)	// "EncSucur"
oSection1:SetTotalInLine(.F.)
oSection1:SetHeaderSection(.T.)	//Exibe Cabecalho da Secao
oSection1:SetHeaderPage(.F.)	//Exibe Cabecalho da pagina
oSection1:SetLineStyle(.T.)   	//Pone titulo del campo y aun lado el valor
oSection1:SetCharSeparator(":")
oSection1:SetHeaderBreak(.T.)

TRCell():New(oSection1,"CE8_FILIAL"	, "QRYCE8"	,STR0030	,PesqPict("CE8","CE8_FILIAL")	,GetSx3Cache("CE8_FILIAL","X3_TAMANHO"))	//"Sucursal  "
TRCell():New(oSection1,"M0_NOME"	, "QRYCE8"	,""			,/*Pespiq*/						,50)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criacao da 2da.     Secao: Proveedor  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSection2 := TRSection():New(oReport, OemToAnsi(STR0004), {"QRYCE8"},,/*Campos do SX3*/,/*Campos do SIX*/)	//"EncProve"
oSection2:SetTotalInLine(.F.)
oSection2:SetHeaderSection(.T.)	//Exibe Cabecalho da Secao
oSection2:SetHeaderPage(.F.)
oSection2:SetLineStyle(.T.)		//Pone titulo del campo y aun lado el valor
oSection2:SetCharSeparator(":")
oSection2:SetHeaderBreak(.T.)

TRCell():New(oSection2,"CE8_PROV"	,"QRYCE8"	,STR0006	,PesqPict("CE8","CE8_PROV")			,GetSx3Cache("CE8_PROV","X3_TAMANHO"))		//"Proveedor"
TRCell():New(oSection2,"CE8_TIENDA"	,"QRYCE8"	,""			,PesqPict("CE8","CE8_TIENDA")		,GetSx3Cache("CE8_TIENDA","X3_TAMANHO"))
TRCell():New(oSection2,"A2_NOME"	,"QRYCE8"	,""			,PesqPict("SA2","A2_NOME")			,GetSx3Cache("A2_NOME","X3_TAMANHO"))
TRCell():New(oSection2,"CE8_RFC"	,"QRYCE8"	,STR0007	,PesqPict("CE8","CE8_RFC")			,GetSx3Cache("CE8_RFC","X3_TAMANHO")+3)		// "R.F.C."
TRCell():New(oSection2,"CE8_IDFISC"	,"QRYCE8"	,STR0008	,PesqPict("CE8","CE8_IDFISC")		,GetSx3Cache("CE8_IDFISC","X3_TAMANHO"))	// "ID"
TRCell():New(oSection2,"CE8_TIPTER"	,"QRYCE8"	,STR0009	,/*PesqPict("CE8","CE8_TIPTER")*/	,GetSx3Cache("CE8_TIPTER","X3_TAMANHO"))	// "Tipo Ter"
TRCell():New(oSection2,"CE8_TIPOPE"	,"QRYCE8"	,STR0010	,/*PesqPict("CE8","CE8_TIPOPE")*/  	,GetSx3Cache("CE8_TIPOPE","X3_TAMANHO"))	// "Operación"
TRCell():New(oSection2,"CE8_PAIS"	,"QRYCE8"	,STR0011	,/*PesqPict("CE8","CE8_PAIS")*/   	,GetSx3Cache("CE8_PAIS","X3_TAMANHO"))		// "Pais"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criacao da 3ra.     Secao: Detalle  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSection3 := TRSection():New(oReport, OemToAnsi(STR0005), {"QRYCE8"},,/*Campos do SX3*/,/*Campos do SIX*/)	//"Det"
oSection3:SetTotalInLine(.F.)
oSection3:SetHeaderBreak(.T.)
oSection3:SetHeaderSection(.T.)
oSection3:SetHeaderPage(.T.)
oSection3:SetLinesBefore(0)
oSection3:SetLineStyle(.F.)

TRCell():New(oSection3,"CE8_PROV"	,"QRYCE8"	,STR0013)	// "Prov"
TRCell():New(oSection3,"CE8_TIENDA"	,"QRYCE8"	,STR0014)	// "Tda"
TRCell():New(oSection3,"CE8_NUMDOC"	,"QRYCE8"	,STR0015	,,nLenDoc,,,"LEFT",,"LEFT")	// "Documento"
TRCell():New(oSection3,"CE8_FECDOC"	,"QRYCE8"	,STR0016	,,10,,,"LEFT",,"LEFT")	// "Fch Emis"
TRCell():New(oSection3,"CE8_TIPO"	,"QRYCE8"	,STR0017	,,5,,,"LEFT",,"LEFT")	// "Tipo"
// "Valor de los Actos o Actividades"
TRCell():New(oSection3,"CE8_BA1011"	,"QRYCE8"	,STR0059	,cPicImp	,nLenImp	,,,"RIGHT",,"RIGHT")	// "Pagos RFN"
TRCell():New(oSection3,"CE8_BASE8"	,"QRYCE8"	,STR0060	,cPicImp	,nLenImp	,,,"RIGHT",,"RIGHT")	// "Devols RFN"
TRCell():New(oSection3,"CE8_BASE10"	,"QRYCE8"	,STR0061	,cPicImp	,nLenImp	,,,"RIGHT",,"RIGHT")	// "Pagos RFS"
TRCell():New(oSection3,"CE8_BI1011"	,"QRYCE8"	,STR0062	,cPicImp	,nLenImp	,,,"RIGHT",,"RIGHT")	// "Devols RFS"
TRCell():New(oSection3,"CE8_BA1516"	,"QRYCE8"	,STR0063	,cPicImp	,nLenImp	,,,"RIGHT",,"RIGHT")	// "Pagos Interior"
TRCell():New(oSection3,"CE8_BI1516"	,"QRYCE8"	,STR0064	,cPicImp	,nLenImp	,,,"RIGHT",,"RIGHT")	// "Devols Interior"
TRCell():New(oSection3,"CE8_BASE15"	,"QRYCE8"	,STR0065	,cPicImp	,nLenImp	,,,"RIGHT",,"RIGHT")	// "Pag Imp Tang"
TRCell():New(oSection3,"CE8_BASDVA"	,"QRYCE8"	,STR0066	,cPicImp	,nLenImp	,,,"RIGHT",,"RIGHT")	// "Dev Imp Tang"
TRCell():New(oSection3,"CE8_BASDVB"	,"QRYCE8"	,STR0067	,cPicImp	,nLenImp	,,,"RIGHT",,"RIGHT")	// "Val Imp Intang"
TRCell():New(oSection3,"CE8_BASDVC"	,"QRYCE8"	,STR0068	,cPicImp	,nLenImp	,,,"RIGHT",,"RIGHT")	// "Dev Imp Intang"
// "IVA Acreditable"
TRCell():New(oSection3,"CE8_IVAACA","QRYCE8"	,STR0069	,cPicImp	,nLenImp	,,,"RIGHT",,"RIGHT")	// "No Prop RFN"
TRCell():New(oSection3,"CE8_IVAACB","QRYCE8"	,STR0070	,cPicImp	,nLenImp	,,,"RIGHT",,"RIGHT")	// "Propor RFN"
TRCell():New(oSection3,"CE8_IVAACC","QRYCE8"	,STR0071	,cPicImp	,nLenImp	,,,"RIGHT",,"RIGHT")	// "No Prop RFS"
TRCell():New(oSection3,"CE8_IVAACD","QRYCE8"	,STR0072	,cPicImp	,nLenImp	,,,"RIGHT",,"RIGHT")	// "Propor RFS"
TRCell():New(oSection3,"CE8_IVAACE","QRYCE8"	,STR0073	,cPicImp	,nLenImp	,,,"RIGHT",,"RIGHT")	// "No Prop Inter"
TRCell():New(oSection3,"CE8_IVAACF","QRYCE8"	,STR0074	,cPicImp	,nLenImp	,,,"RIGHT",,"RIGHT")	// "Propor Interior"
TRCell():New(oSection3,"CE8_IVAACG","QRYCE8"	,STR0075	,cPicImp	,nLenImp	,,,"RIGHT",,"RIGHT")	// "No Prop Tangib"
TRCell():New(oSection3,"CE8_IVAACH","QRYCE8"	,STR0076	,cPicImp	,nLenImp	,,,"RIGHT",,"RIGHT")	// "Propor Tangib"
TRCell():New(oSection3,"CE8_IVAACI","QRYCE8"	,STR0077	,cPicImp	,nLenImp	,,,"RIGHT",,"RIGHT")	// "No Prop Intang"
TRCell():New(oSection3,"CE8_IVAACJ","QRYCE8"	,STR0078	,cPicImp	,nLenImp	,,,"RIGHT",,"RIGHT")	// "Propor Intang"
// "IVA No Acreditable"
TRCell():New(oSection3,"CE8_IVANAA","QRYCE8"	,STR0079	,cPicImp	,nLenImp	,,,"RIGHT",,"RIGHT")	// "Propor RFN"
TRCell():New(oSection3,"CE8_IVANAB","QRYCE8"	,STR0080	,cPicImp	,nLenImp	,,,"RIGHT",,"RIGHT")	// "No Prop RFN"
TRCell():New(oSection3,"CE8_IVANAC","QRYCE8"	,STR0081	,cPicImp	,nLenImp	,,,"RIGHT",,"RIGHT")	// "Exento RFN"
TRCell():New(oSection3,"CE8_IVANAD","QRYCE8"	,STR0082	,cPicImp	,nLenImp	,,,"RIGHT",,"RIGHT")	// "No Objeto RFN"
TRCell():New(oSection3,"CE8_IVANAE","QRYCE8"	,STR0083	,cPicImp	,nLenImp	,,,"RIGHT",,"RIGHT")	// "Propor RFS"
TRCell():New(oSection3,"CE8_IVANAF","QRYCE8"	,STR0084	,cPicImp	,nLenImp	,,,"RIGHT",,"RIGHT")	// "No Prop RFS"
TRCell():New(oSection3,"CE8_IVANAG","QRYCE8"	,STR0085	,cPicImp	,nLenImp	,,,"RIGHT",,"RIGHT")	// "Exento RFS"
TRCell():New(oSection3,"CE8_IVANAH","QRYCE8"	,STR0086	,cPicImp	,nLenImp	,,,"RIGHT",,"RIGHT")	// "No Objeto RFS"
TRCell():New(oSection3,"CE8_IVANAI","QRYCE8"	,STR0087	,cPicImp	,nLenImp	,,,"RIGHT",,"RIGHT")	// "Propor Interior"
TRCell():New(oSection3,"CE8_IVANAJ","QRYCE8"	,STR0088	,cPicImp	,nLenImp	,,,"RIGHT",,"RIGHT")	// "No Prop Interior"
TRCell():New(oSection3,"CE8_IVANAK","QRYCE8"	,STR0089	,cPicImp	,nLenImp	,,,"RIGHT",,"RIGHT")	// "Exento Interior"
TRCell():New(oSection3,"CE8_IVANAL","QRYCE8"	,STR0090	,cPicImp	,nLenImp	,,,"RIGHT",,"RIGHT")	// "No Objeto Int"
TRCell():New(oSection3,"CE8_IVANAM","QRYCE8"	,STR0091	,cPicImp	,nLenImp	,,,"RIGHT",,"RIGHT")	// "Propor Tangib"
TRCell():New(oSection3,"CE8_IVANAN","QRYCE8"	,STR0092	,cPicImp	,nLenImp	,,,"RIGHT",,"RIGHT")	// "No Prop Tangib"
TRCell():New(oSection3,"CE8_IVANAO","QRYCE8"	,STR0093	,cPicImp	,nLenImp	,,,"RIGHT",,"RIGHT")	// "Exento Tangib"
TRCell():New(oSection3,"CE8_IVANAP","QRYCE8"	,STR0094	,cPicImp	,nLenImp	,,,"RIGHT",,"RIGHT")	// "No Objeto Tang"
TRCell():New(oSection3,"CE8_IVANAQ","QRYCE8"	,STR0095	,cPicImp	,nLenImp	,,,"RIGHT",,"RIGHT")	// "Propor Intangib"
TRCell():New(oSection3,"CE8_IVANAR","QRYCE8"	,STR0096	,cPicImp	,nLenImp	,,,"RIGHT",,"RIGHT")	// "No Prop Intang"
TRCell():New(oSection3,"CE8_IVANAS","QRYCE8"	,STR0097	,cPicImp	,nLenImp	,,,"RIGHT",,"RIGHT")	// "Exento Intangib"
TRCell():New(oSection3,"CE8_IVANAT","QRYCE8"	,STR0098	,cPicImp	,nLenImp	,,,"RIGHT",,"RIGHT")	// "No Objeto Intan"
// "Datos Adicionales"
TRCell():New(oSection3,"CE8_IVARET","QRYCE8"	,STR0099	,cPicImp	,nLenImp	,,,"RIGHT",,"RIGHT")	// "IVA Retenido"
TRCell():New(oSection3,"CE8_BASIEX","QRYCE8"	,STR0100	,cPicImp	,nLenImp	,,,"RIGHT",,"RIGHT")	// "Pagos Imp Exen"
TRCell():New(oSection3,"CE8_BASEEX","QRYCE8"	,STR0101	,cPicImp	,nLenImp	,,,"RIGHT",,"RIGHT")	// "Pagos Exentos"
TRCell():New(oSection3,"CE8_BASE0" ,"QRYCE8"	,STR0102	,cPicImp	,nLenImp	,,,"RIGHT",,"RIGHT")	// "Pagos Tasa 0%"
TRCell():New(oSection3,"CE8_VALTOT","QRYCE8"	,STR0103	,cPicImp	,nLenImp	,,,"RIGHT",,"RIGHT")	// "No Obj IVA Nal"
TRCell():New(oSection3,"CE8_IVADEV","QRYCE8"	,STR0104	,cPicImp	,nLenImp	,,,"RIGHT",,"RIGHT")	// "No Obj IVA Ext"

oSection3:Cell("CE8_PROV"):HideHeader()
oSection3:Cell("CE8_PROV"):hide()
oSection3:Cell("CE8_TIENDA"):HideHeader()
oSection3:Cell("CE8_TIENDA"):hide()

//Total por proveedor
oBreak := TRBreak():New(oSection3, oSection3:Cell("CE8_PROV"), , .F., "")  // Falso para que muestre el total debajo de la columna correspondiente
// "Valor de los Actos o Actividades"
TRFunction():New(oSection3:Cell("CE8_BA1011"),NIL,"SUM",oBreak,"",cPicImp,/*uFormula*/,.F.,.F.)
TRFunction():New(oSection3:Cell("CE8_BASE8") ,NIL,"SUM",oBreak,"",cPicImp,/*uFormula*/,.F.,.F.)
TRFunction():New(oSection3:Cell("CE8_BASE10"),NIL,"SUM",oBreak,"",cPicImp,/*uFormula*/,.F.,.F.)
TRFunction():New(oSection3:Cell("CE8_BI1011"),NIL,"SUM",oBreak,"",cPicImp,/*uFormula*/,.F.,.F.)
TRFunction():New(oSection3:Cell("CE8_BA1516"),NIL,"SUM",oBreak,"",cPicImp,/*uFormula*/,.F.,.F.)
TRFunction():New(oSection3:Cell("CE8_BI1516"),NIL,"SUM",oBreak,"",cPicImp,/*uFormula*/,.F.,.F.)
TRFunction():New(oSection3:Cell("CE8_BASE15"),NIL,"SUM",oBreak,"",cPicImp,/*uFormula*/,.F.,.F.)
TRFunction():New(oSection3:Cell("CE8_BASDVA"),NIL,"SUM",oBreak,"",cPicImp,/*uFormula*/,.F.,.F.)
TRFunction():New(oSection3:Cell("CE8_BASDVB"),NIL,"SUM",oBreak,"",cPicImp,/*uFormula*/,.F.,.F.)
TRFunction():New(oSection3:Cell("CE8_BASDVC"),NIL,"SUM",oBreak,"",cPicImp,/*uFormula*/,.F.,.F.)
// "IVA Acreditable"
TRFunction():New(oSection3:Cell("CE8_IVAACA"),NIL,"SUM",oBreak,"",cPicImp,/*uFormula*/,.F.,.F.)
TRFunction():New(oSection3:Cell("CE8_IVAACB"),NIL,"SUM",oBreak,"",cPicImp,/*uFormula*/,.F.,.F.)
TRFunction():New(oSection3:Cell("CE8_IVAACC"),NIL,"SUM",oBreak,"",cPicImp,/*uFormula*/,.F.,.F.)
TRFunction():New(oSection3:Cell("CE8_IVAACD"),NIL,"SUM",oBreak,"",cPicImp,/*uFormula*/,.F.,.F.)
TRFunction():New(oSection3:Cell("CE8_IVAACE"),NIL,"SUM",oBreak,"",cPicImp,/*uFormula*/,.F.,.F.)
TRFunction():New(oSection3:Cell("CE8_IVAACF"),NIL,"SUM",oBreak,"",cPicImp,/*uFormula*/,.F.,.F.)
TRFunction():New(oSection3:Cell("CE8_IVAACG"),NIL,"SUM",oBreak,"",cPicImp,/*uFormula*/,.F.,.F.)
TRFunction():New(oSection3:Cell("CE8_IVAACH"),NIL,"SUM",oBreak,"",cPicImp,/*uFormula*/,.F.,.F.)
TRFunction():New(oSection3:Cell("CE8_IVAACI"),NIL,"SUM",oBreak,"",cPicImp,/*uFormula*/,.F.,.F.)
TRFunction():New(oSection3:Cell("CE8_IVAACJ"),NIL,"SUM",oBreak,"",cPicImp,/*uFormula*/,.F.,.F.)
// "IVA No Acreditable"
TRFunction():New(oSection3:Cell("CE8_IVANAA"),NIL,"SUM",oBreak,"",cPicImp,/*uFormula*/,.F.,.F.)
TRFunction():New(oSection3:Cell("CE8_IVANAB"),NIL,"SUM",oBreak,"",cPicImp,/*uFormula*/,.F.,.F.)
TRFunction():New(oSection3:Cell("CE8_IVANAC"),NIL,"SUM",oBreak,"",cPicImp,/*uFormula*/,.F.,.F.)
TRFunction():New(oSection3:Cell("CE8_IVANAD"),NIL,"SUM",oBreak,"",cPicImp,/*uFormula*/,.F.,.F.)
TRFunction():New(oSection3:Cell("CE8_IVANAE"),NIL,"SUM",oBreak,"",cPicImp,/*uFormula*/,.F.,.F.)
TRFunction():New(oSection3:Cell("CE8_IVANAF"),NIL,"SUM",oBreak,"",cPicImp,/*uFormula*/,.F.,.F.)
TRFunction():New(oSection3:Cell("CE8_IVANAG"),NIL,"SUM",oBreak,"",cPicImp,/*uFormula*/,.F.,.F.)
TRFunction():New(oSection3:Cell("CE8_IVANAH"),NIL,"SUM",oBreak,"",cPicImp,/*uFormula*/,.F.,.F.)
TRFunction():New(oSection3:Cell("CE8_IVANAI"),NIL,"SUM",oBreak,"",cPicImp,/*uFormula*/,.F.,.F.)
TRFunction():New(oSection3:Cell("CE8_IVANAJ"),NIL,"SUM",oBreak,"",cPicImp,/*uFormula*/,.F.,.F.)
TRFunction():New(oSection3:Cell("CE8_IVANAK"),NIL,"SUM",oBreak,"",cPicImp,/*uFormula*/,.F.,.F.)
TRFunction():New(oSection3:Cell("CE8_IVANAL"),NIL,"SUM",oBreak,"",cPicImp,/*uFormula*/,.F.,.F.)
TRFunction():New(oSection3:Cell("CE8_IVANAM"),NIL,"SUM",oBreak,"",cPicImp,/*uFormula*/,.F.,.F.)
TRFunction():New(oSection3:Cell("CE8_IVANAN"),NIL,"SUM",oBreak,"",cPicImp,/*uFormula*/,.F.,.F.)
TRFunction():New(oSection3:Cell("CE8_IVANAO"),NIL,"SUM",oBreak,"",cPicImp,/*uFormula*/,.F.,.F.)
TRFunction():New(oSection3:Cell("CE8_IVANAP"),NIL,"SUM",oBreak,"",cPicImp,/*uFormula*/,.F.,.F.)
TRFunction():New(oSection3:Cell("CE8_IVANAQ"),NIL,"SUM",oBreak,"",cPicImp,/*uFormula*/,.F.,.F.)
TRFunction():New(oSection3:Cell("CE8_IVANAR"),NIL,"SUM",oBreak,"",cPicImp,/*uFormula*/,.F.,.F.)
TRFunction():New(oSection3:Cell("CE8_IVANAS"),NIL,"SUM",oBreak,"",cPicImp,/*uFormula*/,.F.,.F.)
TRFunction():New(oSection3:Cell("CE8_IVANAT"),NIL,"SUM",oBreak,"",cPicImp,/*uFormula*/,.F.,.F.)
// "Datos Adicionales"
TRFunction():New(oSection3:Cell("CE8_IVARET"),NIL,"SUM",oBreak,"",cPicImp,/*uFormula*/,.F.,.F.)
TRFunction():New(oSection3:Cell("CE8_BASIEX"),NIL,"SUM",oBreak,"",cPicImp,/*uFormula*/,.F.,.F.)
TRFunction():New(oSection3:Cell("CE8_BASEEX"),NIL,"SUM",oBreak,"",cPicImp,/*uFormula*/,.F.,.F.)
TRFunction():New(oSection3:Cell("CE8_BASE0") ,NIL,"SUM",oBreak,"",cPicImp,/*uFormula*/,.F.,.F.)
TRFunction():New(oSection3:Cell("CE8_VALTOT"),NIL,"SUM",oBreak,"",cPicImp,/*uFormula*/,.F.,.F.)
TRFunction():New(oSection3:Cell("CE8_IVADEV"),NIL,"SUM",oBreak,"",cPicImp,/*uFormula*/,.F.,.F.)

Return oReport

/*/{Protheus.doc} PrintRep2
	Impresión del informe DIOT versión 2025
	@type  Static Function
	@author ARodriguez
	@since 02/03/2025
	@version 12.1.2310
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function PrintRep2(oReport)
Local oSection1
Local oSection2
Local oSection3
Local oQry
Local cTitle	:= ""
Local nOrdem	:= 0
Local cAliasCE8 := "QRYCE8"
Local cQuery	:= ""
Local aFils   	:= {}
Local nTamFil	:= 0
Local nCont		:= 0
Local aCampos	:= {}
Local cSelect	:= ""
Local cNameCE8	:= RetSqlName("CE8")
Local cNameSA2	:= RetSqlName("SA2")
Local cFilRes	:= ""
Local cProRes	:= ""
Local aExentos	:= {"CE8_IVANAG", "CE8_IVANAK", "CE8_IVANAO", "CE8_IVANAS"}
Local aFiltros	:= {}
Local nResiduo	:= 0

If __lVerLib == Nil
	__lVerLib := (FwLibVersion() >= "20211116")
EndIf

If Empty(_cPar01)
   MsgAlert(STR0034) // "Seleccione un periodo"
   Return
EndIf

If Empty(_cPar02)
   MsgAlert(STR0035) // "Seleccione al menos una sucursal"
   Return
EndIf

If oReport:nDevice <> 4
	MsgAlert(STR0152) // "Este informe está diseñado para generarse en planilla Excel, proceso cancelado."
	Return
EndIf

Pergunte(oReport:GetParam(),.F.)
oSection1 	:= oReport:Section(1)
oSection2 	:= oReport:Section(2)
oSection3 	:= oReport:Section(3)
nOrdem	  	:= oReport:GetOrder()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³  Altera o Titulo do Relatorio conforme o parametro selecionado   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cTitle 	:= AllTrim(oReport:Title())+ ObtDesMesAnio() + STR0036	// " - ANALITICO"
oReport:SetTitle(cTitle)

aFils := StrTokArr(Alltrim(_cPar02), ';')
nTamFil := Len(aFils)
aCampos := CE8->(dbStruct())

For nCont := 1 to Len(aCampos)
	If aScan(aExentos, aCampos[nCont][1]) == 0
		cSelect += aCampos[nCont][1] + ", "
	EndIf
Next nCont

For nCont := 1 to Len(aExentos)
	cSelect += "0 " + aExentos[nCont] + ", "
Next nCont

cSelect += " A2_NOME "

For nCont := 1 To nTamFil
	If nCont > 1
		cQuery += " UNION ALL "
	Else
		cQuery := " "
	EndIf

	cQuery += "Select ?" 
	cQuery += " From ? CE8, ? SA2"
	cQuery += " WHERE"
	cQuery += " CE8_MESANO = ?"
	cQuery += " AND CE8_FILIAL = ? AND A2_FILIAL = ?"
	cQuery += " AND CE8_PROV = A2_COD"
	cQuery += " AND CE8_TIENDA = A2_LOJA"
	cQuery += " AND CE8.D_E_L_E_T_ = ' '"
	cQuery += " AND SA2.D_E_L_E_T_ = ' '"

	If nCont == nTamFil
		cQuery += " ORDER BY CE8_FILIAL,CE8_PROV,CE8_TIENDA,CE8_FECDOC"
	EndIf

	aAdd(aFiltros, cSelect)
	aAdd(aFiltros, cNameCE8)
	aAdd(aFiltros, cNameSA2)
	aAdd(aFiltros, _cPar01)
	aAdd(aFiltros, aFils[nCont])
	aAdd(aFiltros, xFilial("SA2" , Strtran( aFils[nCont], "'", "")))
Next nCont

Begin Sequence

	cQuery := ChangeQuery(cQuery)
	oQry := IIf(__lVerLib, FwExecStatement():New( cQuery ), FWPreparedStatement():New( cQuery ))

	For nCont := 1 To Len(aFiltros)
		nResiduo := (nCont % 6)
		If (nResiduo > 0 .And. nResiduo < 4)
			oQry:SetUnsafe(nCont,aFiltros[nCont])
		Else
			oQry:SetString(nCont,aFiltros[nCont])
		EndIf
	Next nCont
	
	cAliasCE8 := IIf(__lVerLib, oQry:OpenAlias(cAliasCE8), MpSysOpenQuery(oQry:GetFixQuery(),cAliasCE8))

	dbSelectArea(cAliasCE8)
	Count To nTotal
	(cAliasCE8)->(DbGoTop())

	For nCont := 1 To Len(aCampos)
		If aCampos[nCont][2] <> "C"
			TCSetField(cAliasCE8, aCampos[nCont][1], aCampos[nCont][2], aCampos[nCont][3], aCampos[nCont][4])
		EndIf
	Next nCont

	oReport:SetMeter(nTotal)

	While (cAliasCE8)->(!Eof())
		cFilRes := (cAliasCE8)->CE8_filial
		oSection1:Init()
		oSection1:PrintLine()

		While (cAliasCE8)->(!Eof()) .And. cFilRes == (cAliasCE8)->CE8_FILIAL
			cProRes := (cAliasCE8)->CE8_PROV + (cAliasCE8)->CE8_TIENDA
			oSection2:Init()
			oSection2:PrintLine()
			oSection2:Finish()

			oSection3:Init()

			While (cAliasCE8)->(!Eof()) .And. cFilRes == (cAliasCE8)->CE8_FILIAL .And. cProRes == (cAliasCE8)->CE8_PROV + (cAliasCE8)->CE8_TIENDA
				oSection3:Cell("CE8_NUMDOC"):SetValue(Alltrim((cAliasCE8)->CE8_NUMDOC) + "-" + Alltrim((cAliasCE8)->CE8_SERIE))
				oSection3:PrintLine()

				oReport:IncMeter()
				(cAliasCE8)->(dbSkip())
			EndDo

			oSection3:Finish()
		EndDo

		oSection1:Finish()
	EndDo
End Sequence

(cAliasCE8)->(dbCloseArea())

If oQry <> Nil
	oQry:Destroy()	
	oQry := Nil
EndIf

Return Nil

/*/{Protheus.doc} RepDefRes2
	Define informe DIOT resumido versión 2025
	@type  Static Function
	@author ARodriguez
	@since 02/03/2025
	@version 12.1.2310
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function RepDefRes2
Local oReport	:= Nil
Local oSection1	:= Nil

Private cTitulo := OemToAnsi(STR0002)	// "DECLARACION INFORMATIVA DE OPERACIONES CON TERCEROS"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01       // Mes y año                                  ³
//³ mv_par02       // Rango de sucursales                        ³
//³ mv_par03       // Tipo de informe                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Pergunte("FISR088",.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao do componente de impressao                                      ³
//³TReport():New                                                           ³
//³ExpC1 : Nome do relatorio                                               ³
//³ExpC2 : Titulo                                                          ³
//³ExpC3 : Pergunte                                                        ³
//³ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  ³
//³ExpC5 : Descricao                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oReport := TReport():New(NomeProg, OemToAnsi(cTitulo), "FISR088", {|oReport| PrintRes2(oReport)})
oReport:SetLandscape()		// Define a orientacao de pagina do relatorio como retrato.
oReport:nColSpace	:= 2
oReport:nFontBody	:= 8	// Define o tamanho da fonte.
oReport:nLineHeight	:= 45	// Define a altura da linha.
oReport:cFontBody	:= "COURIER NEW"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao da celulas da secao do relatorio                                ³
//³TRCell():New                                                            ³
//³ExpO1 : Objeto TSection que a secao pertence                            ³
//³ExpC2 : Nome da celula do relatório. O SX3 será consultado              ³
//³ExpC3 : Nome da tabela de referencia da celula                          ³
//³ExpC4 : Titulo da celula                                                ³
//³        Default : X3Titulo()                                            ³
//³ExpC5 : Picture                                                         ³
//³        Default : X3_PICTURE                                            ³
//³ExpC6 : Tamanho                                                         ³
//³        Default : X3_TAMANHO                                            ³
//³ExpL7 : Informe se o tamanho esta em pixel                              ³
//³        Default : False                                                 ³
//³ExpB8 : Bloco de código para impressao.                                 ³
//³        Default : ExpC2                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criacao da Primeira Secao: Encabezado de la Sucursal                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

oSection1 := TRSection():New(oReport, OemToAnsi(STR0003), {"QRYCE8"},,/*Campos do SX3*/,/*Campos do SIX*/)	// "EncSucur"
oSection1:SetTotalInLine(.F.)
oSection1:SetHeaderSection(.T.)	//Exibe Cabecalho da Secao
oSection1:SetHeaderPage(.F.)	//Exibe Cabecalho da Secao
oSection1:SetHeaderBreak(.T.)
oSection1:SetLineStyle(.T.)		//Pone titulo del campo y aun lado el y valor
oSection1:SetCharSeparator(":")

TRCell():New(oSection1,"CE8_FILIAL"	,"QRYCE8"	,STR0030	,PesqPict("CE8","CE8_FILIAL")	,GetSx3Cache("CE8_FILIAL","X3_TAMANHO"))	//"Sucursal  "

//Resumen
oSection2 := TRSection():New(oReport, OemToAnsi(STR0031),	{"QRYCE8"},,/*Campos do SX3*/,/*Campos do SIX*/)	// "Resumen"
oSection2:SetHeaderSection(.T.)	//Exibe Cabecalho da Secao
oSection2:SetHeaderPage(.T.)	//Exibe Cabecalho da Secao
oSection2:SetLineStyle(.F.)		//Pone titulo del campo y aun lado el y valor

TRCell():New(oSection2,"DESC"		,"QRYCE8"	,STR0032	,""					,220,,,"LEFT",,"CENTER")	// "Descripción"
TRCell():New(oSection2,"IMPORTE"	,"QRYCE8"	,STR0033	,"999,999,999.99"	,20,,,"RIGHT",,"CENTER")	// "Importe"

Return oReport

/*/{Protheus.doc} PrintRes2
	Impresión del informe DIOT resumido versión 2025
	@type  Static Function
	@author ARodriguez
	@since 02/03/2025
	@version 12.1.2310
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function PrintRes2(oReport)
Local oSection1		:= Nil
Local oSection2		:= Nil
Local cTitle		:= ""
Local nOrdem		:= 0
Local cAliasCE8		:= "QRYCE8"
Local cQuery		:= ""
Local nTotal		:= 0
Local cFilRes		:= ""
Local aFiltros		:= {}

If Empty(_cPar01)
   MsgAlert(STR0034) // "Seleccione un periodo"
   Return
EndIf

If Empty(_cPar02)
   MsgAlert(STR0035) // "Seleccione al menos una sucursal"
   Return
EndIf

Pergunte(oReport:GetParam(),.F.)

oSection1 := oReport:Section(1)
oSection2 := oReport:Section(2)
nOrdem	:= oReport:GetOrder()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³  Altera o Titulo do Relatorio conforme o parametro selecionado   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cTitle := AllTrim(oReport:Title()) + ObtDesMesAnio() + STR0037 // " - RESUMEN"
oReport:SetTitle(cTitle)

// Periodo
cQuery := "SELECT CE8_FILIAL, CE8_MESANO, "
// Valor de los actos o actividades
cQuery += "SUM(CE8_BA1011) CE8_BA1011, SUM(CE8_BASE8) CE8_BASE8, SUM(CE8_BASE10) CE8_BASE10, SUM(CE8_BI1011) CE8_BI1011, SUM(CE8_BA1516) CE8_BA1516, SUM(CE8_BI1516) CE8_BI1516, "
cQuery += "SUM(CE8_BASE15) CE8_BASE15, SUM(CE8_BASDVA) CE8_BASDVA, SUM(CE8_BASDVB) CE8_BASDVB, SUM(CE8_BASDVC) CE8_BASDVC, "
// IVA acreditable
cQuery += "SUM(CE8_IVAACA) CE8_IVAACA, SUM(CE8_IVAACB) CE8_IVAACB, SUM(CE8_IVAACC) CE8_IVAACC, SUM(CE8_IVAACD) CE8_IVAACD, SUM(CE8_IVAACE) CE8_IVAACE, SUM(CE8_IVAACF) CE8_IVAACF, "
cQuery += "SUM(CE8_IVAACG) CE8_IVAACG, SUM(CE8_IVAACH) CE8_IVAACH, SUM(CE8_IVAACI) CE8_IVAACI, SUM(CE8_IVAACJ) CE8_IVAACJ, "
// IVA no acreditable
cQuery += "SUM(CE8_IVANAA) CE8_IVANAA, SUM(CE8_IVANAB) CE8_IVANAB, SUM(CE8_IVANAC) CE8_IVANAC, SUM(CE8_IVANAD) CE8_IVANAD, SUM(CE8_IVANAE) CE8_IVANAE, SUM(CE8_IVANAF) CE8_IVANAF, "
cQuery += "0 CE8_IVANAG, SUM(CE8_IVANAH) CE8_IVANAH, SUM(CE8_IVANAI) CE8_IVANAI, SUM(CE8_IVANAJ) CE8_IVANAJ, 0 CE8_IVANAK, SUM(CE8_IVANAL) CE8_IVANAL, "
cQuery += "SUM(CE8_IVANAM) CE8_IVANAM, SUM(CE8_IVANAN) CE8_IVANAN, 0 CE8_IVANAO, SUM(CE8_IVANAP) CE8_IVANAP, SUM(CE8_IVANAQ) CE8_IVANAQ, SUM(CE8_IVANAR) CE8_IVANAR, "
cQuery += "0 CE8_IVANAS, SUM(CE8_IVANAT) CE8_IVANAT, "
// Datos adicionales
cQuery += "SUM(CE8_IVARET) CE8_IVARET, SUM(CE8_BASIEX) CE8_BASIEX, SUM(CE8_BASEEX) CE8_BASEEX, SUM(CE8_BASE0) CE8_BASE0, SUM(CE8_VALTOT) CE8_VALTOT, SUM(CE8_IVADEV) CE8_IVADEV "

cQuery += "FROM ? CE8 "
cQuery += "WHERE "
cQuery += "CE8_MESANO = ? AND "
cQuery += "CE8_FILIAL IN (?) AND "
cQuery += "CE8.D_E_L_E_T_ = ' ' "
cQuery += "GROUP BY CE8_FILIAL,CE8_MESANO"
cQuery += "ORDER BY CE8_FILIAL,CE8_MESANO"

aAdd(aFiltros, RetSqlName("CE8"))
aAdd(aFiltros, _cPar01)
aAdd(aFiltros, StrToKArr(Alltrim(_cPar02), ';'))

Begin Sequence

	cQuery := ChangeQuery(cQuery)
	oQry := IIf(__lVerLib, FwExecStatement():New( cQuery ), FWPreparedStatement():New( cQuery ))

	oQry:SetUnsafe(1,aFiltros[1])
	oQry:SetString(2,aFiltros[2])
	oQry:SetIn(3,aFiltros[3])

	cAliasCE8 := IIf(__lVerLib, oQry:OpenAlias(cAliasCE8), MpSysOpenQuery(oQry:GetFixQuery(),cAliasCE8))

	dbSelectArea(cAliasCE8)
	Count To nTotal
	oReport:SetMeter(nTotal)
	(cAliasCE8)->(DbGoTop())

	While (cAliasCE8)->(!Eof())
		cFilRes := (cAliasCE8)->CE8_FILIAL
		oSection1:Init()
		oSection1:PrintLine()

		While (cAliasCE8)->(!Eof()) .And. cFilRes == (cAliasCE8)->CE8_FILIAL
			oSection2:Init()

			// Valor de los actos o actividades
			oSection2:Cell("DESC"):SetValue(STR0106)		// "Valor Total pagado a la tasa del 15% o 16% de IVA"
			oSection2:Cell("IMPORTE"):SetValue((cAliasCE8)->CE8_BA1011)
			oSection2:PrintLine()

			oSection2:Cell("DESC"):SetValue(STR0107)		// "Valor Total pagado a la tasa del 15% o 16% de IVA"
			oSection2:Cell("IMPORTE"):SetValue((cAliasCE8)->CE8_BASE8)
			oSection2:PrintLine()

			oSection2:Cell("DESC"):SetValue(STR0108)		// "Valor Total pagado a la tasa del 15% de IVA"
			oSection2:Cell("IMPORTE"):SetValue((cAliasCE8)->CE8_BASE10)
			oSection2:PrintLine()

			oSection2:Cell("DESC"):SetValue(STR0109)		// "Valor Total pagado a la tasa del 10% u 11% de IVA"
			oSection2:Cell("IMPORTE"):SetValue((cAliasCE8)->CE8_BI1011)
			oSection2:PrintLine()

			oSection2:Cell("DESC"):SetValue(STR0110)		// "Valor Total pagado a la tasa del 10%  de IVA"
			oSection2:Cell("IMPORTE"):SetValue((cAliasCE8)->CE8_BA1516)
			oSection2:PrintLine()

			oSection2:Cell("DESC"):SetValue(STR0111)		// "Valor Total pagado de los actos o actividades sujeto al estímulo de la región fronteriza norte"
			oSection2:Cell("IMPORTE"):SetValue((cAliasCE8)->CE8_BI1516)
			oSection2:PrintLine()

			oSection2:Cell("DESC"):SetValue(STR0112)		// "Valor Total pagado de importación de bienes y servicios a la tasa del 15% o 16% de IVA"
			oSection2:Cell("IMPORTE"):SetValue((cAliasCE8)->CE8_BASE15)
			oSection2:PrintLine()

			oSection2:Cell("DESC"):SetValue(STR0113)		// "Valor Total pagado de importación de bienes y servicios a la tasa del 10% o 11% de IVA"
			oSection2:Cell("IMPORTE"):SetValue((cAliasCE8)->CE8_BASDVA)
			oSection2:PrintLine()

			oSection2:Cell("DESC"):SetValue(STR0114)		// "Valor Total pagado de importación de bienes y servicios que no pagara IVA (Exentos)"
			oSection2:Cell("IMPORTE"):SetValue((cAliasCE8)->CE8_BASDVB)
			oSection2:PrintLine()

			oSection2:Cell("DESC"):SetValue(STR0115)		// "Valor Total pagado a la tasa del 0% de IVA"
			oSection2:Cell("IMPORTE"):SetValue((cAliasCE8)->CE8_BASDVC)
			oSection2:PrintLine()

			// IVA Acreditable
			oSection2:Cell("DESC"):SetValue(STR0116)		// "Valor Total pagado por los que no se pagara el IVA (Exentos)"
			oSection2:Cell("IMPORTE"):SetValue((cAliasCE8)->CE8_IVAACA)
			oSection2:PrintLine()

			oSection2:Cell("DESC"):SetValue(STR0117)		// "IVA Total Retenido por el contribuyente"
			oSection2:Cell("IMPORTE"):SetValue((cAliasCE8)->CE8_IVAACB)
			oSection2:PrintLine()

			oSection2:Cell("DESC"):SetValue(STR0118)		// "IVA Total Correspondiente a las devoluciones, descuentos y bonificaciones sobre compras"
			oSection2:Cell("IMPORTE"):SetValue((cAliasCE8)->CE8_IVAACC)
			oSection2:PrintLine()

			oSection2:Cell("DESC"):SetValue(STR0119)		// "IVA Total transferido (pagado) de bienes y servicios excepto importaciones"
			oSection2:Cell("IMPORTE"):SetValue((cAliasCE8)->CE8_IVAACD)
			oSection2:PrintLine()

			oSection2:Cell("DESC"):SetValue(STR0120)		// "IVA Total pagado en las importaciones de bienes y servicios"
			oSection2:Cell("IMPORTE"):SetValue((cAliasCE8)->CE8_IVAACE)
			oSection2:PrintLine()

			oSection2:Cell("DESC"):SetValue(STR0121)		// "Valor Total pagado por los que no se pagara el IVA (Exentos)"
			oSection2:Cell("IMPORTE"):SetValue((cAliasCE8)->CE8_IVAACF)
			oSection2:PrintLine()

			oSection2:Cell("DESC"):SetValue(STR0122)		// "IVA Total Retenido por el contribuyente"
			oSection2:Cell("IMPORTE"):SetValue((cAliasCE8)->CE8_IVAACG)
			oSection2:PrintLine()

			oSection2:Cell("DESC"):SetValue(STR0123)		// "IVA Total Correspondiente a las devoluciones, descuentos y bonificaciones sobre compras"
			oSection2:Cell("IMPORTE"):SetValue((cAliasCE8)->CE8_IVAACH)
			oSection2:PrintLine()

			oSection2:Cell("DESC"):SetValue(STR0124)		// "IVA Total transferido (pagado) de bienes y servicios excepto importaciones"
			oSection2:Cell("IMPORTE"):SetValue((cAliasCE8)->CE8_IVAACI)
			oSection2:PrintLine()

			oSection2:Cell("DESC"):SetValue(STR0125)		// "IVA Total pagado en las importaciones de bienes y servicios"
			oSection2:Cell("IMPORTE"):SetValue((cAliasCE8)->CE8_IVAACJ)
			oSection2:PrintLine()

			// IVA No Acreditable
			oSection2:Cell("DESC"):SetValue(STR0126)		// "Valor Total pagado por los que no se pagara el IVA (Exentos)"
			oSection2:Cell("IMPORTE"):SetValue((cAliasCE8)->CE8_IVANAA)
			oSection2:PrintLine()

			oSection2:Cell("DESC"):SetValue(STR0127)		// "Valor Total pagado por los que no se pagara el IVA (Exentos)"
			oSection2:Cell("IMPORTE"):SetValue((cAliasCE8)->CE8_IVANAB)
			oSection2:PrintLine()

			oSection2:Cell("DESC"):SetValue(STR0128)		// "Valor Total pagado por los que no se pagara el IVA (Exentos)"
			oSection2:Cell("IMPORTE"):SetValue((cAliasCE8)->CE8_IVANAC)
			oSection2:PrintLine()

			oSection2:Cell("DESC"):SetValue(STR0129)		// "Valor Total pagado por los que no se pagara el IVA (Exentos)"
			oSection2:Cell("IMPORTE"):SetValue((cAliasCE8)->CE8_IVANAD)
			oSection2:PrintLine()

			oSection2:Cell("DESC"):SetValue(STR0130)		// "Valor Total pagado por los que no se pagara el IVA (Exentos)"
			oSection2:Cell("IMPORTE"):SetValue((cAliasCE8)->CE8_IVANAE)
			oSection2:PrintLine()

			oSection2:Cell("DESC"):SetValue(STR0131)		// "Valor Total pagado por los que no se pagara el IVA (Exentos)"
			oSection2:Cell("IMPORTE"):SetValue((cAliasCE8)->CE8_IVANAF)
			oSection2:PrintLine()

			oSection2:Cell("DESC"):SetValue(STR0132)		// "Valor Total pagado por los que no se pagara el IVA (Exentos)"
			oSection2:Cell("IMPORTE"):SetValue((cAliasCE8)->CE8_IVANAG)
			oSection2:PrintLine()

			oSection2:Cell("DESC"):SetValue(STR0133)		// "Valor Total pagado por los que no se pagara el IVA (Exentos)"
			oSection2:Cell("IMPORTE"):SetValue((cAliasCE8)->CE8_IVANAH)
			oSection2:PrintLine()

			oSection2:Cell("DESC"):SetValue(STR0134)		// "Valor Total pagado por los que no se pagara el IVA (Exentos)"
			oSection2:Cell("IMPORTE"):SetValue((cAliasCE8)->CE8_IVANAI)
			oSection2:PrintLine()

			oSection2:Cell("DESC"):SetValue(STR0135)		// "Valor Total pagado por los que no se pagara el IVA (Exentos)"
			oSection2:Cell("IMPORTE"):SetValue((cAliasCE8)->CE8_IVANAJ)
			oSection2:PrintLine()

			oSection2:Cell("DESC"):SetValue(STR0136)		// "Valor Total pagado por los que no se pagara el IVA (Exentos)"
			oSection2:Cell("IMPORTE"):SetValue((cAliasCE8)->CE8_IVANAK)
			oSection2:PrintLine()

			oSection2:Cell("DESC"):SetValue(STR0137)		// "Valor Total pagado por los que no se pagara el IVA (Exentos)"
			oSection2:Cell("IMPORTE"):SetValue((cAliasCE8)->CE8_IVANAL)
			oSection2:PrintLine()

			oSection2:Cell("DESC"):SetValue(STR0138)		// "Valor Total pagado por los que no se pagara el IVA (Exentos)"
			oSection2:Cell("IMPORTE"):SetValue((cAliasCE8)->CE8_IVANAM)
			oSection2:PrintLine()

			oSection2:Cell("DESC"):SetValue(STR0139)		// "Valor Total pagado por los que no se pagara el IVA (Exentos)"
			oSection2:Cell("IMPORTE"):SetValue((cAliasCE8)->CE8_IVANAN)
			oSection2:PrintLine()

			oSection2:Cell("DESC"):SetValue(STR0140)		// "Valor Total pagado por los que no se pagara el IVA (Exentos)"
			oSection2:Cell("IMPORTE"):SetValue((cAliasCE8)->CE8_IVANAO)
			oSection2:PrintLine()

			oSection2:Cell("DESC"):SetValue(STR0141)		// "Valor Total pagado por los que no se pagara el IVA (Exentos)"
			oSection2:Cell("IMPORTE"):SetValue((cAliasCE8)->CE8_IVANAP)
			oSection2:PrintLine()

			oSection2:Cell("DESC"):SetValue(STR0142)		// "Valor Total pagado por los que no se pagara el IVA (Exentos)"
			oSection2:Cell("IMPORTE"):SetValue((cAliasCE8)->CE8_IVANAQ)
			oSection2:PrintLine()

			oSection2:Cell("DESC"):SetValue(STR0143)		// "Valor Total pagado por los que no se pagara el IVA (Exentos)"
			oSection2:Cell("IMPORTE"):SetValue((cAliasCE8)->CE8_IVANAR)
			oSection2:PrintLine()

			oSection2:Cell("DESC"):SetValue(STR0144)		// "Valor Total pagado por los que no se pagara el IVA (Exentos)"
			oSection2:Cell("IMPORTE"):SetValue((cAliasCE8)->CE8_IVANAS)
			oSection2:PrintLine()

			oSection2:Cell("DESC"):SetValue(STR0145)		// "Valor Total pagado por los que no se pagara el IVA (Exentos)"
			oSection2:Cell("IMPORTE"):SetValue((cAliasCE8)->CE8_IVANAT)
			oSection2:PrintLine()

			// Datos adicionales
			oSection2:Cell("DESC"):SetValue(STR0146)		// "Valor Total pagado por los que no se pagara el IVA (Exentos)"
			oSection2:Cell("IMPORTE"):SetValue((cAliasCE8)->CE8_IVARET)
			oSection2:PrintLine()

			oSection2:Cell("DESC"):SetValue(STR0147)		// "Valor Total pagado por los que no se pagara el IVA (Exentos)"
			oSection2:Cell("IMPORTE"):SetValue((cAliasCE8)->CE8_BASIEX)
			oSection2:PrintLine()

			oSection2:Cell("DESC"):SetValue(STR0148)		// "Valor Total pagado por los que no se pagara el IVA (Exentos)"
			oSection2:Cell("IMPORTE"):SetValue((cAliasCE8)->CE8_BASEEX)
			oSection2:PrintLine()

			oSection2:Cell("DESC"):SetValue(STR0149)		// "Valor Total pagado por los que no se pagara el IVA (Exentos)"
			oSection2:Cell("IMPORTE"):SetValue((cAliasCE8)->CE8_BASE0)
			oSection2:PrintLine()

			oSection2:Cell("DESC"):SetValue(STR0150)		// "Valor Total pagado por los que no se pagara el IVA (Exentos)"
			oSection2:Cell("IMPORTE"):SetValue((cAliasCE8)->CE8_VALTOT)
			oSection2:PrintLine()

			oSection2:Cell("DESC"):SetValue(STR0151)		// "Valor Total pagado por los que no se pagara el IVA (Exentos)"
			oSection2:Cell("IMPORTE"):SetValue((cAliasCE8)->CE8_IVADEV)
			oSection2:PrintLine()

			oSection2:Finish()
			oReport:IncMeter()
			(cAliasCE8)->(dbSkip())
		EndDo

		oSection1:Finish()
	EndDo

End Sequence

(cAliasCE8)->(dbCloseArea())

If oQry <> Nil
	oQry:Destroy()	
	oQry := Nil
EndIf

Return Nil
