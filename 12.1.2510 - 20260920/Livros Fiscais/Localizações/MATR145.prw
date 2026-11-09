#INCLUDE "PROTHEUS.CH"  
#INCLUDE "MATR145.CH"
#INCLUDE "TOPCONN.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ MATR145   ºAutor  ³ FSW Argentina      º Data ³  11/02/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Reporte Lista de embarques arribados resumido               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                        ºModulo ³ Facturacionº±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³Data    ³BOPS      ³Motivo da Alteracao                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Jonathan Glz³6/07/15 ³PCREQ-4256³Se elimina la funcion AjustaSX1() que ³±±
±±³            ³        ³          ³hace modificacion a SX1 por motivo de ³±±
±±³            ³        ³          ³adecuacion a fuentes a nuevas estruc- ³±±
±±³            ³        ³          ³turas SX para Version 12.             ³±±
±±³M.Camargo   ³09.11.15³PCREQ-4262³Merge sistemico v12.1.8		          ³±±
±±³A.Rodriguez ³21/04/18³DMINA-2464³Ampliar ancho de Val.Total	          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MATR145()
Local oReport

   oReport := ReportDef()
   oReport:PrintDialog()
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcion   ³ ReportDef³ Autor ³                       ³ Data ³ 05/11/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrip.  ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportDef
Local oReport
Local oSection1
Local oCell

Local cTitSec1    := STR0001
Local oBreak



Private cPerg     := "MTR145"
Private cTit      := OemToAnsi(STR0001)
Private lArchExcel:= .F.
Private cClient   :=''
Private cDestip   :=''


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Creaci¢n del componente de impresion                                    ³
//³                                                                        ³
//³TReport():New                                                           ³
//³ExpC1 : Nombre del Informe                                              ³
//³ExpC2 : Titulo                                                          ³
//³ExpC3 : Pregunta                                                        ³
//³ExpB4 : Bloque de codigo que ser  ejecutado al confirmar la impresion   ³
//³ExpC5 : Descripcion                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

oReport:= TReport():New('MATR145',OemToAnsi(STR0001),cPerg, ;
                        {|oReport| ReportPrint(oReport)}, cTit)

oReport:SetPortrait()
oReport:SetTotalInLine(.F.)
Pergunte(cPerg,.F.)

oSection1 := TRSection():New(oReport,"MATR145")

oSection1:SetHeaderPage() //El titulo de la seccion se imprime al principio

TRCell():New(oSection1,'PROCESO' ,,STR0002  , /*Picture */    , TamSx3("DBB_HAWB")[1], /*lPixel */, /*{|| code-block de impressao } */ )
TRCell():New(oSection1,'ESPACIO' ,,' '      , /*Picture */    ,  2, /*lPixel */, /*{|| code-block de impressao } */ )

If Alltrim(cPaisLoc) <> "BRA" .and. Alltrim(cPaisLoc) <> "MEX"
	TRCell():New(oSection1,'TIPO'    ,,STR0003  , /*Picture */    , 12, /*lPixel */, /*{|| code-block de impressao } */ )
Endif

TRCell():New(oSection1,'ESPACIO' ,,' '      , /*Picture */    ,  2, /*lPixel */, /*{|| code-block de impressao } */ )
TRCell():New(oSection1,'FECHAPRO',,STR0004  , /*Picture */    , 10, /*lPixel */, /*{|| code-block de impressao } */ )
TRCell():New(oSection1,'ESPACIO' ,,' '      , /*Picture */    ,  2, /*lPixel */, /*{|| code-block de impressao } */ )
TRCell():New(oSection1,'FECHADEC',,STR0005  , /*Picture */    , 10, /*lPixel */, /*{|| code-block de impressao } */ )
TRCell():New(oSection1,'ESPACIO' ,,' '      , /*Picture */    ,  2, /*lPixel */, /*{|| code-block de impressao } */ )
TRCell():New(oSection1,'FINALIZ' ,,STR0006  , /*Picture */    , 10, /*lPixel */, /*{|| code-block de impressao } */ )
TRCell():New(oSection1,'ESPACIO' ,,' '      , /*Picture */    ,  2, /*lPixel */, /*{|| code-block de impressao } */ )
TRCell():New(oSection1,'TOTAL'   ,,STR0007  ,"@E 9,999,999,999,999.99", 22, /*lPixel */, /*{|| code-block de impressao } */ )
TRCell():New(oSection1,'ESPACIO' ,,' '      , /*Picture */    ,  2, /*lPixel */, /*{|| code-block de impressao } */ )
TRCell():New(oSection1,'ORIGINAL',,STR0015  ,"@E 9,999,999,999,999.99", 22, /*lPixel */, /*{|| code-block de impressao } */ )

Return( oReport )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcion   ³ ReportDef³ Autor ³                       ³ Data ³ 05/11/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrip.  ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportPrint(oReport)
#IFDEF TOP
	Local oSection1	:= oReport:Section(1)
	Local oBreak
	Local oBreak1
	Local aArea
	Local cDesEst     := ""
	Local cOrden      := ""
	Local nTotReg     := 0
	Local cCorte      := ""
	Local bPrim       := .T.
	Local xImpu       :={}
	Local nAuxTotBru  := 0
	Local nAuxTotal   := 0
	Local cDescri     := ""
	Local nAuxAliq    := 0
	Local nAuxImp     := 0
	Local nTxMoeda    := 0
	Local nVlrUnit    := 0
	Local nVlrTot     := 0
	Local cQuery      := ""
	Local cAntProc    := ""
	Local nTasa       := 0
	Local cAliasTRB	:= GetNextAlias()
	oReport:SetTitle(oReport:Title() + Iif(MV_PAR09 == 1,' - Pesos',' - Moneda Original'))
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Filtragem do relatorio                                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	cQuery := "SELECT A.DBB_HAWB AS PROCESO,A.DBB_TXMOED AS TXMOEDA, " + CRLF
	cQuery +=         "A.DBB_MOEDA AS MONEDA,C.DBA_DTHAWB AS FECHAPRO,C.DBA_DT_DTA AS FECHADEC,C.DBA_DT_ENC AS FINALIZ, " + CRLF
	
	If Alltrim(cPaisLoc) $ "BRA/MEX"
		cQuery +=  "B.DBC_PRECO AS PRECIO,B.DBC_TOTAL AS TOTAL " + CRLF
	Else
		cQuery +=  "B.DBC_PRECO AS PRECIO,B.DBC_TOTAL AS TOTAL, A.DBB_TIPONF TIPO, B.DBC_TOTAL AS ORIGINAL " + CRLF
	Endif
	
	cQuery += "FROM " + CRLF
	cQuery += "    " + RetSqlName("DBB") + " A, " + RetSqlName("DBC") + " B, " + RetSqlName("DBA") + " C " + CRLF
	cQuery += "WHERE A.DBB_HAWB >= '"+MV_PAR01+"' AND " + CRLF
	cQuery +=       "A.DBB_HAWB <= '"+MV_PAR02+"' AND " + CRLF
	cQuery +=       "C.DBA_DTHAWB>='"+Dtos(MV_PAR03)+"' AND " + CRLF
	cQuery +=       "C.DBA_DTHAWB<='"+Dtos(MV_PAR04)+"' AND "	 + CRLF
	cQuery +=       "(C.DBA_DT_DTA=' ' OR (C.DBA_DT_DTA >= '"+Dtos(MV_PAR05)+"' AND C.DBA_DT_DTA <= '"+Dtos(MV_PAR06)+"' )) AND " + CRLF
	cQuery +=       "(C.DBA_DT_ENC=' ' OR (C.DBA_DT_ENC >= '"+Dtos(MV_PAR07)+"' AND C.DBA_DT_ENC <= '"+Dtos(MV_PAR08)+"' )) AND " + CRLF
	cQuery +=       "A.DBB_HAWB = C.DBA_HAWB AND " + CRLF
	cQuery +=       "A.DBB_HAWB = B.DBC_HAWB AND " + CRLF
	cQuery +=       "A.DBB_ITEM = B.DBC_ITDOC AND " + CRLF
	cQuery +=       "A.D_E_L_E_T_ <> '*' AND " + CRLF
	cQuery +=       "B.D_E_L_E_T_ <> '*' AND " + CRLF
	cQuery +=       "C.D_E_L_E_T_ <> '*' " + CRLF
	
	If Alltrim(cPaisLoc) $ "BRA/MEX"
		cQuery +=    "ORDER BY PROCESO " + CRLF
	else
		cQuery +=    "ORDER BY PROCESO, TIPO " + CRLF
	Endif
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., 'TOPCONN', TCGENQRY(,,cQuery), cAliasTRB, .F., .T.)
	
	DbSelectArea(cAliasTRB)
	
	DbGoTop()
	oSection1:Init()
	oSection1:Cell("PROCESO"):SetBlock({|| allTrim((cAliasTRB)->PROCESO)} )
	
	If cPaisLoc <> "BRA" .and. cPaisLoc <> "MEX"
		oSection1:Cell("TIPO"):SetBlock( {|| BuTipoFac(cAliasTRB)  }  )
	Endif
	
	oSection1:Cell("FECHAPRO"):SetBlock({|| Stod((cAliasTRB)->FECHAPRO) })
	oSection1:Cell("FECHADEC"):SetBlock({||  Stod((cAliasTRB)->FECHADEC)})
	oSection1:Cell("FINALIZ"):SetBlock({|| Stod((cAliasTRB)->FINALIZ) })
	oSection1:Cell("ORIGINAL"):SetBlock({|| (cAliasTRB)->ORIGINAL })

	cAntProc:= allTrim((cAliasTRB)->PROCESO)
	
	SM2->(dbSeek(dDataBase))
	nTasa  := SM2->M2_MOEDA2
	If nTasa == 0
	   nTasa:=1
	EndIf
	
	(cAliasTRB)->(DbGoTop())
	While !oReport:Cancel() .And. !(cAliasTRB)->(Eof())
	
		oReport:IncMeter()
		If oReport:Cancel()
			Exit
		EndIf
	
		While !(cAliasTRB)->(EOF())
	
			If MV_PAR10 == 1     //Del Movimiento
				nTxMoeda := IIF((cAliasTRB)->TXMOEDA > 0,(cAliasTRB)->TXMOEDA,1)
			Else
				nTxMoeda := Recmoeda(dDatabase,(cAliasTRB)->MONEDA)
			EndIf
	
			Do Case
				Case (MV_PAR09 == 1 .And. (cAliasTRB)->MONEDA == 1) .Or. (MV_PAR09 == 2 .And. (cAliasTRB)->MONEDA >= 2)
					nVlrUnit := (cAliasTRB)->PRECIO
					nVlrTot  := (cAliasTRB)->TOTAL
				Case MV_PAR09 == 1 .And. (cAliasTRB)->MONEDA >= 2
					nVlrUnit := ((cAliasTRB)->PRECIO * nTxMoeda)
					nVlrTot  := ((cAliasTRB)->TOTAL * nTxMoeda)
				Case MV_PAR09 >= 2 .And. (cAliasTRB)->MONEDA == 1
					nTxMoeda := Recmoeda(dDatabase,(cAliasTRB)->MONEDA)
					nVlrUnit := ((cAliasTRB)->PRECIO / nTxMoeda)
					nVlrTot  := ((cAliasTRB)->TOTAL / nTxMoeda)
			EndCase
	
			oSection1:Cell("TOTAL"):SetBlock({|| nVlrTot})
	
			If allTrim((cAliasTRB)->PROCESO)<> cAntProc
				cAntProc:= allTrim((cAliasTRB)->PROCESO)
				oReport:SkipLine()
			EndIf
			oSection1:PrintLine()
			(cAliasTRB)->(dbSkip())
	
		EndDo
	
	EndDo
	
	oSection1:Finish()
	//Cierra tabla temporal
	DbSelectArea(cAliasTRB)
	(cAliasTRB)->(DbCloseArea())
	
	Return NIL
	
	Static Function BuTipoFac(cAliasTRB)
	Local cTipoFac := ''
	
	If cPaisLoc <> "BRA" .and. cPaisLoc <> "MEX"
	
		Do Case
		   Case (cAliasTRB)->TIPO == '5'
	      	cTipoFac := STR0010
	   	Case (cAliasTRB)->TIPO == '6'
	      	cTipoFac := STR0011
	   	Case (cAliasTRB)->TIPO == '7'
	      	cTipoFac := STR0012
	   	Case (cAliasTRB)->TIPO == '8'
	      	cTipoFac := STR0013
	   	Case (cAliasTRB)->TIPO == 'A'
	      	cTipoFac := STR0014
		EndCase
		
	Endif
	
#ELSE
	Aviso(STR0001,STR0008,{STR0009})//"Relatório disponível apenas para ambiente TopConnect."  
#ENDIF   

Return cTipoFac
