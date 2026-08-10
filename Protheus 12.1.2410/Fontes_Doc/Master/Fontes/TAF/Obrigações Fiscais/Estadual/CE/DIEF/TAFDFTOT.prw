#Include 'Protheus.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFDFTOT           
Gera o registro TOT da DIEF-CE 
Registro tipo TOT - Totalizador e Fechamento do Documento Fiscal

@author David Costa
@since  29/10/2015
@version 1.0
				
/*/
//-------------------------------------------------------------------
Function TAFDFTOT( nHandle, cAliasQry, cRegime, lCupom )

Local cNomeReg	:= "TOT"
Local cStrReg		:= ""
Local cAliasQry2	:= GetNextAlias()
Local oLastError	:= ErrorBlock({|e| AddLogDIEF("Não foi possível montar o registro TOT, erro: " + CRLF + e:Description + Chr( 10 )+ e:ErrorStack)})
Local lError		:= .F.

Begin Sequence
	
	QryTOT( cAliasQry2, cAliasQry, lCupom )
	
	DbSelectArea(cAliasQry2)
	(cAliasQry2)->(DbGoTop())
	
	cStrReg	:= cNomeReg
	cStrReg	+= GetVrPr(cAliasQry, cRegime, lCupom)						//Valor total dos produtos ou serviços.
	cStrReg	+= GetFret(cAliasQry, cRegime, lCupom)						//Valor do frete.
	cStrReg	+= GetDesp(cAliasQry, cRegime, lCupom)						//Valor de outras despesas  acessórias.
	cStrReg	+= GetDesc(cAliasQry, cRegime, lCupom, cAliasQry2)		//Valor de desconto.
	cStrReg	+= GetVrDo(cAliasQry, lCupom)								//Valor total do documento
	cStrReg	+= GetReti(cAliasQry2, cAliasQry, cRegime, lCupom)		//Valor do ICMS Retido. 
	cStrReg	+= GetBCIc(cAliasQry2, cRegime)								//Valor total da base de cálculo do ICMS. 
	cStrReg	+= GetICMS(cAliasQry2, cRegime)								//Valor total do ICMS.
	cStrReg	+= GetIsen(cAliasQry2)										//Valor total de Isentas ou não Tributadas.
	cStrReg	+= GetOutr(cAliasQry2)										//Valor total de Outras.
	cStrReg	+= GetBCSu(cAliasQry2, cRegime)								//Valor total da base de cálculo do ICMS ST.
	cStrReg	+= GetICSu(cAliasQry2, cRegime)								//Valor total do ICMS ST do declarante.
	cStrReg	+= GetBCIp(cAliasQry2, cRegime)								//Valor da base de cálculo referente ao IPI.
	cStrReg	+= GetIsIp(cAliasQry2, cRegime)								//Valor de isentas e não tributadas do IPI.
	cStrReg	+= GetOuIp(cAliasQry2, cRegime)								//Valor outros referente ao IPI. 
	cStrReg	+= GetIPI(cAliasQry2, cRegime)								//Valor do IPI. 
	cStrReg	+= GetSegu(cAliasQry, cRegime, lCupom)						//Valor do seguro. 
	cStrReg	+= CRLF
	
	AddLinDIEF( )
	
	WrtStrTxt( nHandle, cStrReg )
	
	( cAliasQry2 )->( DbCloseArea())

Recover
	lError := .T.
	
End Sequence

ErrorBlock(oLastError)

Return( lError )

//-------------------------------------------------------------------
/*/{Protheus.doc} QryTOT             
Seleciona os dados para geração do registro TOT 

@author David Costa
@since  04/11/2015
@version 1.0
				
/*/
//-------------------------------------------------------------------
Static Function QryTOT( cAliasQry2, cAliasQry, lCupom )

Local cSelect		:=	""
Local cFrom		:=	""
Local cWhere		:=	""

If( !lCupom )
	cSelect 	:= " SUM(IPI.C35_VLISEN) VLISN_IPI, SUM(IPI.C35_VLOUTR) VLOUT_IPI, SUM(IPI.C35_BASE) BS_IPI, SUM(IPI.C35_VALOR) VL_IPI, "
	cSelect 	+= " SUM(ICMS.C35_VLISEN) VLISN_ICMS, SUM(ICMS.C35_VLOUTR) VLOUT_ICMS, SUM(ICMS.C35_VALOR) VL_ICMS, SUM(ICMS.C35_BASE) BS_ICMS, "
	cSelect 	+= " SUM(ICMSST.C35_VALOR) VL_ICMSST, SUM(ICMSST.C35_BASE) BS_ICMSST, "
	cSelect 	+= " SUM(ICMSSTANT.C35_VALOR) VL_STANT "
	
	cFrom   	:= RetSqlName("C30") + " C30 "
	//----ICMS
	cFrom   	+= " LEFT JOIN " + RetSqlName("C35") + " ICMS  "
	cFrom   	+= " 	JOIN " + RetSqlName("C3S") + " C3SICMS ON "
	cFrom   	+= " 		ICMS.C35_CODTRI = C3SICMS.C3S_ID AND  "
	cFrom   	+= " 		C3SICMS.D_E_L_E_T_ = '' AND  "
	cFrom   	+= " 		C3SICMS.C3S_CODIGO IN ('02', '03') ON "
	cFrom   	+= " 	C30.C30_CHVNF = ICMS.C35_CHVNF AND  "
	cFrom   	+= " 	C30.C30_NUMITE = ICMS.C35_NUMITE AND  "
	cFrom   	+= " 	C30.C30_CODITE = ICMS.C35_CODITE AND  "
	cFrom   	+= " 	ICMS.D_E_L_E_T_ = '' "
	//------IPI
	cFrom   	+= " LEFT JOIN " + RetSqlName("C35") + " IPI "
	cFrom   	+= " 	JOIN " + RetSqlName("C3S") + " C3SIPI ON "
	cFrom   	+= " 		IPI.C35_CODTRI = C3SIPI.C3S_ID AND  "
	cFrom   	+= " 		C3SIPI.D_E_L_E_T_ = '' AND  "
	cFrom   	+= " 		C3SIPI.C3S_CODIGO IN ('05') ON "
	cFrom   	+= " 	C30.C30_CHVNF = IPI.C35_CHVNF AND  "
	cFrom   	+= " 	C30.C30_NUMITE = IPI.C35_NUMITE AND "
	cFrom   	+= " 	C30.C30_CODITE = IPI.C35_CODITE AND  "
	cFrom   	+= " 	IPI.D_E_L_E_T_ = '' "
	//------ICMSST
	cFrom   	+= " LEFT JOIN " + RetSqlName("C35") + " ICMSST "
	cFrom   	+= " 	JOIN " + RetSqlName("C3S") + " C3ICMSST ON "
	cFrom   	+= " 		ICMSST.C35_CODTRI = C3ICMSST.C3S_ID AND  "
	cFrom   	+= " 		C3ICMSST.D_E_L_E_T_ = '' AND  " 
	cFrom   	+= " 		C3ICMSST.C3S_CODIGO IN ('04') ON " 
	cFrom   	+= " 	C30.C30_CHVNF = ICMSST.C35_CHVNF AND  " 
	cFrom   	+= " 	C30.C30_NUMITE = ICMSST.C35_NUMITE AND  " 
	cFrom   	+= " 	C30.C30_CODITE = ICMSST.C35_CODITE AND  "
	cFrom   	+= " 	ICMSST.D_E_L_E_T_ = '' "
	//------ICMS Antecipado
	cFrom   	+= " LEFT JOIN " + RetSqlName("C35") + " ICMSSTANT "
	cFrom   	+= " 	JOIN " + RetSqlName("C3S") + " C3ICMSSTANT ON "
	cFrom   	+= " 		ICMSSTANT.C35_CODTRI = C3ICMSSTANT.C3S_ID AND  "
	cFrom   	+= " 		C3ICMSSTANT.D_E_L_E_T_ = '' AND  " 
	cFrom   	+= " 		C3ICMSSTANT.C3S_CODIGO IN ('17') ON " 
	cFrom   	+= " 	C30.C30_CHVNF = ICMSSTANT.C35_CHVNF AND  " 
	cFrom   	+= " 	C30.C30_NUMITE = ICMSSTANT.C35_NUMITE AND  " 
	cFrom   	+= " 	C30.C30_CODITE = ICMSSTANT.C35_CODITE AND  "
	cFrom   	+= " 	ICMSSTANT.D_E_L_E_T_ = '' "
	
	cWhere  	:= " C30.D_E_L_E_T_ = '' "
	cWhere  	+= " AND C30_FILIAL = '" + xFilial( "C30" ) + "' "
	cWhere  	+= " AND C30_CHVNF = '" + (cAliasQry)->C20_CHVNF + "' "
//Cupom
Else
	cSelect 	:= " SUM(IPI.C6K_VLISEN) VLISN_IPI, SUM(IPI.C6K_VLOUT) VLOUT_IPI, SUM(IPI.C6K_VLRBC) BS_IPI, SUM(IPI.C6K_VLRTRB) VL_IPI, "
	cSelect 	+= " SUM(ICMS.C6K_VLISEN) VLISN_ICMS, SUM(ICMS.C6K_VLOUT) VLOUT_ICMS, SUM(ICMS.C6K_VLRTRB) VL_ICMS, SUM(ICMS.C6K_VLRBC) BS_ICMS, "
	cSelect 	+= " SUM(ICMSST.C6K_VLRTRB) VL_ICMSST, SUM(ICMSST.C6K_VLRBC) BS_ICMSST, "
	cSelect 	+= " SUM(ICMSSTANT.C6K_VLRTRB) VL_STANT, SUM(C6J_VLDESC) VL_DESC "
	
	cFrom   	:= RetSqlName("C6J") + " C6J "
	//----ICMS
	cFrom   	+= " LEFT JOIN " + RetSqlName("C6K") + " ICMS  "
	cFrom   	+= " 	JOIN " + RetSqlName("C3S") + " C3SICMS ON "
	cFrom   	+= " 		ICMS.C6K_CODTRI = C3SICMS.C3S_ID AND "
	cFrom   	+= " 		C3SICMS.D_E_L_E_T_ = '' AND  "
	cFrom   	+= " 		C3SICMS.C3S_CODIGO IN ('02', '03') ON "
	cFrom   	+= " 	C6J_ID = ICMS.C6K_ID AND "
	cFrom   	+= " 	C6J_FILIAL = ICMS.C6K_FILIAL AND "
	cFrom   	+= " 	C6J_DTMOV = ICMS.C6K_DTMOV AND "
	cFrom   	+= " 	C6J_CMOD = ICMS.C6K_CMOD AND "
	cFrom   	+= " 	C6J_CODSIT = ICMS.C6K_CODSIT AND "
	cFrom   	+= " 	C6J_NUMDOC = ICMS.C6K_NUMDOC AND "
	cFrom   	+= " 	C6J_DTEMIS = ICMS.C6K_DTEMIS AND "
	cFrom   	+= " 	C6J_IT = ICMS.C6K_IT AND "
	cFrom   	+= " 	ICMS.D_E_L_E_T_ = '' "
	//------IPI
	cFrom   	+= " LEFT JOIN " + RetSqlName("C6K") + " IPI "
	cFrom   	+= " 	JOIN " + RetSqlName("C3S") + " C3SIPI ON "
	cFrom   	+= " 		IPI.C6K_CODTRI = C3SIPI.C3S_ID AND "
	cFrom   	+= " 		C3SIPI.D_E_L_E_T_ = '' AND "
	cFrom   	+= " 		C3SIPI.C3S_CODIGO IN ('05') ON "
	cFrom   	+= " 	C6J_ID = IPI.C6K_ID AND "
	cFrom   	+= " 	C6J_FILIAL = IPI.C6K_FILIAL AND "
	cFrom   	+= " 	C6J_DTMOV = IPI.C6K_DTMOV AND "
	cFrom   	+= " 	C6J_CMOD = IPI.C6K_CMOD AND "
	cFrom   	+= " 	C6J_CODSIT = IPI.C6K_CODSIT AND "
	cFrom   	+= " 	C6J_NUMDOC = IPI.C6K_NUMDOC AND "
	cFrom   	+= " 	C6J_DTEMIS = IPI.C6K_DTEMIS AND "
	cFrom   	+= " 	C6J_IT = IPI.C6K_IT AND "
	cFrom   	+= " 	IPI.D_E_L_E_T_ = '' "
	//------ICMSST
	cFrom   	+= " LEFT JOIN " + RetSqlName("C6K") + " ICMSST "
	cFrom   	+= " 	JOIN " + RetSqlName("C3S") + " C3ICMSST ON "
	cFrom   	+= " 		ICMSST.C6K_CODTRI = C3ICMSST.C3S_ID AND "
	cFrom   	+= " 		C3ICMSST.D_E_L_E_T_ = '' AND "
	cFrom   	+= " 		C3ICMSST.C3S_CODIGO IN ('04') ON "
	cFrom   	+= " 	C6J_ID = ICMSST.C6K_ID AND "
	cFrom   	+= " 	C6J_FILIAL = ICMSST.C6K_FILIAL AND "
	cFrom   	+= " 	C6J_DTMOV = ICMSST.C6K_DTMOV AND "
	cFrom   	+= " 	C6J_CMOD = ICMSST.C6K_CMOD AND "
	cFrom   	+= " 	C6J_CODSIT = ICMSST.C6K_CODSIT AND "
	cFrom   	+= " 	C6J_NUMDOC = ICMSST.C6K_NUMDOC AND "
	cFrom   	+= " 	C6J_DTEMIS = ICMSST.C6K_DTEMIS AND "
	cFrom   	+= " 	C6J_IT = ICMSST.C6K_IT AND "
	cFrom   	+= " 	ICMSST.D_E_L_E_T_ = '' "
	//------ICMS Antecipado
	cFrom   	+= " LEFT JOIN " + RetSqlName("C6K") + " ICMSSTANT "
	cFrom   	+= " 	JOIN " + RetSqlName("C3S") + " C3ICMSSTANT ON "
	cFrom   	+= " 		ICMSSTANT.C6K_CODTRI = C3ICMSSTANT.C3S_ID AND "
	cFrom   	+= " 		C3ICMSSTANT.D_E_L_E_T_ = '' AND "
	cFrom   	+= " 		C3ICMSSTANT.C3S_CODIGO IN ('17') ON "
	cFrom   	+= " 	C6J_ID = ICMSSTANT.C6K_ID AND "
	cFrom   	+= " 	C6J_FILIAL = ICMSSTANT.C6K_FILIAL AND " 
	cFrom   	+= " 	C6J_DTMOV = ICMSSTANT.C6K_DTMOV AND "
	cFrom   	+= " 	C6J_CMOD = ICMSSTANT.C6K_CMOD AND "
	cFrom   	+= " 	C6J_CODSIT = ICMSSTANT.C6K_CODSIT AND "
	cFrom   	+= " 	C6J_NUMDOC = ICMSSTANT.C6K_NUMDOC AND "
	cFrom   	+= " 	C6J_DTEMIS = ICMSSTANT.C6K_DTEMIS AND "
	cFrom   	+= " 	C6J_IT = ICMSSTANT.C6K_IT AND "
	cFrom   	+= " 	ICMSSTANT.D_E_L_E_T_ = '' "
	
	cWhere  	:= " C6J.D_E_L_E_T_ = '' "
	cWhere  	+= " AND C6J_FILIAL = '" + xFilial( "C6J" ) + "' "
	cWhere  	+= " AND C6J_ID = '" + (cAliasQry)->C6I_ID + "' "
	cWhere  	+= " AND C6J_DTMOV = '" + (cAliasQry)->C6I_DTMOV + "' "
	cWhere  	+= " AND C6J_CMOD = '" + (cAliasQry)->C6I_CMOD + "' "
	cWhere  	+= " AND C6J_CODSIT = '" + (cAliasQry)->C6I_CODSIT + "' "
	cWhere  	+= " AND C6J_NUMDOC = '" + (cAliasQry)->C6I_NUMDOC + "' "
	cWhere  	+= " AND C6J_DTEMIS = '" + (cAliasQry)->C6I_DTEMIS + "' "
EndIf
  
cSelect 	:= "%" + cSelect 		+ "%"
cFrom   	:= "%" + cFrom   		+ "%"
cWhere  	:= "%" + cWhere   	+ "%"

BeginSql Alias cAliasQry2

	SELECT
		%Exp:cSelect%
	FROM
		%Exp:cFrom%
	WHERE
		%Exp:cWhere%
EndSql


Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GetVrPr             
Valor total dos produtos ou serviços.

@author David Costa
@since  16/11/2015
@version 1.0
				
/*/
//-------------------------------------------------------------------
Static Function GetVrPr( cAliasQry, cRegime, lCupom )

Local cVrPr	:= ""

If(cRegime $ "|05|06|")
	cVrPr := TAFDecimal(0, 13, 2, Nil)
ElseIf( lCupom )
	cVrPr := TAFDecimal((cAliasQry)->C6I_VLDOC, 13, 2, Nil)
Else
	cVrPr := TAFDecimal((cAliasQry)->C20_VLMERC + (cAliasQry)->C20_VLSERV, 13, 2, Nil)
EndIf	

Return(cVrPr)

//-------------------------------------------------------------------
/*/{Protheus.doc} GetFret             
Valor do frete indicado no documento  fiscal. Informar o valor se indicado na Nota Fiscal. 
Preencher  com ZERO, quando o Regime de Pagamento for ME, MS, Especial e Outros.

@author David Costa
@since  16/11/2015
@version 1.0
				
/*/
//-------------------------------------------------------------------
Static Function GetFret( cAliasQry, cRegime, lCupom )

Local cFrete	:= ""

If(cRegime $ "|05|06|07|12|" .Or. lCupom)
	cFrete := TAFDecimal(0, 13, 2, Nil)
Else
	cFrete := TAFDecimal((cAliasQry)->C20_VLRFRT, 13, 2, Nil)
EndIf	

Return(cFrete)

//-------------------------------------------------------------------
/*/{Protheus.doc} GetDesp             
Valor de outras despesas  acessórias  indicadas  no documento fiscal.Preencher com ZERO, quando o Regime de 
Pagamento  for ME, MS, Especial e Outros

@author David Costa
@since  16/11/2015
@version 1.0
				
/*/
//-------------------------------------------------------------------
Static Function GetDesp( cAliasQry, cRegime, lCupom )

Local cDesp	:= ""

If(cRegime $ "|05|06|07|12|" .Or. lCupom)
	cDesp := TAFDecimal(0, 13, 2, Nil)
Else
	cDesp := TAFDecimal((cAliasQry)->C20_VLRDA, 13, 2, Nil)
EndIf	

Return(cDesp)

//-------------------------------------------------------------------
/*/{Protheus.doc} GetDesc             
Valor de desconto indicado no documento  fiscal. Se foram dados descontos  aos itens e ao total do documento,  
somá-los  neste campo. Preencher  com ZERO, quando o Regime de Pagamento  for ME, MS, Especial e Outros

@author David Costa
@since  16/11/2015
@version 1.0
				
/*/
//-------------------------------------------------------------------
Static Function GetDesc( cAliasQry, cRegime, lCupom, cAliasQry2 )

Local cDesc	:= ""

If(cRegime $ "|05|06|07|12|")
	cDesc := TAFDecimal(0, 13, 2, Nil)
ElseIf(lCupom)
	cDesc := TAFDecimal((cAliasQry2)->VL_DESC, 13, 2, Nil)
Else
	cDesc := TAFDecimal((cAliasQry)->C20_VLDESC, 13, 2, Nil)
EndIf	

Return(cDesc)

//-------------------------------------------------------------------
/*/{Protheus.doc} GetVrDo             
Valor total do documento  fiscal computados  todos os acréscimos  ou decréscimos.

@author David Costa
@since  16/11/2015
@version 1.0
				
/*/
//-------------------------------------------------------------------
Static Function GetVrDo( cAliasQry, lCupom )

Local cVrDo	:= ""

If( lCupom )
	cVrDo := TAFDecimal((cAliasQry)->C6I_VLDOC, 13, 2, Nil)
Else
	cVrDo := TAFDecimal((cAliasQry)->C20_VLDOC, 13, 2, Nil)
EndIf	

Return(cVrDo)

//-------------------------------------------------------------------
/*/{Protheus.doc} GetReti             
Valor do ICMS Retido, informado  no documento  fiscal de entrada, quando ocorrer retenção do ICMS substituição  
pelo fornecedor, ou quando recolhido através de GNRE. Preencher  com ZERO,  quando o Regime de Pagamento  
for ME, MS, Especial e Outros

@author David Costa
@since  16/11/2015
@version 1.0
				
/*/
//-------------------------------------------------------------------
Static Function GetReti( cAliasQry2, cAliasQry, cRegime, lCupom )

Local cReti	:= ""

//Lançamentos de entrada
If(!lCupom .And. (cAliasQry)->C20_INDOPE == "0")
	If(cRegime $ "|05|06|07|12|")
		cReti := TAFDecimal(0, 13, 2, Nil)
	Else
		cReti := TAFDecimal((cAliasQry2)->VL_STANT, 13, 2, Nil)
	EndIf
Else
	cReti := TAFDecimal(0, 13, 2, Nil)
EndIf

Return(cReti)

//-------------------------------------------------------------------
/*/{Protheus.doc} GetBCIc             
Valor total da base de cálculo do ICMS. A partir de JUL/07, preencher com ZERO, quando o regime de pagamento  for EPP ou ME.

@author David Costa
@since  16/11/2015
@version 1.0
				
/*/
//-------------------------------------------------------------------
Static Function GetBCIc( cAliasQry2, cRegime )

Local cBCIc	:= ""

If(cRegime $ "|07|08|")
	cBCIc := TAFDecimal(0, 13, 2, Nil)
Else
	cBCIc := TAFDecimal((cAliasQry2)->BS_ICMS, 13, 2, Nil)
EndIf	

Return(cBCIc)

//-------------------------------------------------------------------
/*/{Protheus.doc} GetICMS             
Valor total do ICMS.  Em caso de EPP, prencher com ZERO nas saídas. A partir de Jul/07, 
preencher  com ZERO nas entradas e nas saidas, quando o regime de pagamento  for ME ou EPP.

@author David Costa
@since  16/11/2015
@version 1.0
				
/*/
//-------------------------------------------------------------------
Static Function GetICMS( cAliasQry2, cRegime )

Local cICMS	:= ""

If(cRegime $ "|07|08|")
	cICMS := TAFDecimal(0, 13, 2, Nil)
Else
	cICMS := TAFDecimal((cAliasQry2)->VL_ICMS, 13, 2, Nil)
EndIf	

Return(cICMS)

//-------------------------------------------------------------------
/*/{Protheus.doc} GetIsen             
Valor total de Isentas ou não Tributadas.

@author David Costa
@since  16/11/2015
@version 1.0
				
/*/
//-------------------------------------------------------------------
Static Function GetIsen( cAliasQry2 )

Local cIsen	:= ""

cIsen := TAFDecimal((cAliasQry2)->VLISN_ICMS, 13, 2, Nil)

Return(cIsen)

//-------------------------------------------------------------------
/*/{Protheus.doc} GetOutr            
Valor total de Outras. 

@author David Costa
@since  16/11/2015
@version 1.0
				
/*/
//-------------------------------------------------------------------
Static Function GetOutr( cAliasQry2 )

Local cOutr	:= ""

cOutr := TAFDecimal((cAliasQry2)->VLOUT_ICMS, 13, 2, Nil)
	
Return(cOutr)

//-------------------------------------------------------------------
/*/{Protheus.doc} GetBCSu             
Valor total da base de cálculo do ICMS Substituição Tributária. 
Preencher  com ZERO, quando o Regime de Pagamento  for ME, MS, Especial e Outros 

@author David Costa
@since  16/11/2015
@version 1.0
				
/*/
//-------------------------------------------------------------------
Static Function GetBCSu( cAliasQry2, cRegime )

Local cBCSu	:= ""

If(cRegime $ "|05|06|07|12|")
	cBCSu := TAFDecimal(0, 13, 2, Nil)
Else
	cBCSu := TAFDecimal((cAliasQry2)->BS_ICMSST, 13, 2, Nil)
EndIf	

Return(cBCSu)

//-------------------------------------------------------------------
/*/{Protheus.doc} GetICSu             
Valor total do ICMS Substituição Tributária  de responsabilidade do declarante. 
Preencher  com ZERO, quando o Regime de Pagamento  for ME, MS, Especial e Outros

@author David Costa
@since  16/11/2015
@version 1.0
				
/*/
//-------------------------------------------------------------------
Static Function GetICSu( cAliasQry2, cRegime )

Local cICSu	:= ""

If(cRegime $ "|05|06|07|12|")
	cICSu := TAFDecimal(0, 13, 2, Nil)
Else
	cICSu := TAFDecimal((cAliasQry2)->VL_ICMSST, 13, 2, Nil)
EndIf	

Return(cICSu)

//-------------------------------------------------------------------
/*/{Protheus.doc} GetBCIp             
Valor da base de cálculo referente ao IPI. Preencher  com ZERO, quando o 
Regime de Pagamento  for ME, MS, Especial e Outros. 

@author David Costa
@since  16/11/2015
@version 1.0
				
/*/
//-------------------------------------------------------------------
Static Function GetBCIp( cAliasQry2, cRegime )

Local cBCIp	:= ""

If(cRegime $ "|05|06|07|12|")
	cBCIp := TAFDecimal(0, 13, 2, Nil)
Else
	cBCIp := TAFDecimal((cAliasQry2)->BS_IPI, 13, 2, Nil)
EndIf

Return(cBCIp)

//-------------------------------------------------------------------
/*/{Protheus.doc} GetIsIp             
Valor de isentas e não tributadas  referente ao IPI. Preencher  com ZERO, quando o 
Regime de Pagamento  for ME, MS, Especial e Outros 

@author David Costa
@since  16/11/2015
@version 1.0
				
/*/
//-------------------------------------------------------------------
Static Function GetIsIp( cAliasQry2, cRegime )

Local cIsIp	:= ""

If(cRegime $ "|05|06|07|12|")
	cIsIp := TAFDecimal(0, 13, 2, Nil)
Else
	cIsIp := TAFDecimal((cAliasQry2)->VLISN_IPI, 13, 2, Nil)
EndIf

Return(cIsIp)

//-------------------------------------------------------------------
/*/{Protheus.doc} GetOuIp             
Valor outros referente ao IPI. Preencher  com ZERO, quando o 
Regime de Pagamento  for ME, MS, Especial e Outros

@author David Costa
@since  16/11/2015
@version 1.0
				
/*/
//-------------------------------------------------------------------
Static Function GetOuIp( cAliasQry2, cRegime )

Local cOuIp	:= ""

If(cRegime $ "|05|06|07|12|")
	cOuIp := TAFDecimal(0, 13, 2, Nil)
Else
	cOuIp := TAFDecimal((cAliasQry2)->VLOUT_IPI, 13, 2, Nil)
EndIf

Return(cOuIp)

//-------------------------------------------------------------------
/*/{Protheus.doc} GetIPI             
"Valor do IPI. Preencher  com ZERO, quando o Regime de Pagamento  for
ME, MS, Especial e Outros"

@author David Costa
@since  16/11/2015
@version 1.0
				
/*/
//-------------------------------------------------------------------
Static Function GetIPI( cAliasQry2, cRegime )

Local cIPI	:= ""

If(cRegime $ "|05|06|07|12|")
	cIPI := TAFDecimal(0, 13, 2, Nil)
Else
	cIPI := TAFDecimal((cAliasQry2)->VL_IPI, 13, 2, Nil)
EndIf

Return(cIPI)

//-------------------------------------------------------------------
/*/{Protheus.doc} GetSegu             
Valor do seguro indicado no documento  fiscal. Preencher  com ZERO, quando o 
Regime de Pagamento  for ME, MS, Especial e Outros

@author David Costa
@since  16/11/2015
@version 1.0
				
/*/
//-------------------------------------------------------------------
Static Function GetSegu( cAliasQry, cRegime, lCupom )

Local cSegu	:= ""

If(cRegime $ "|05|06|07|12|" .Or. lCupom)
	cSegu := TAFDecimal(0, 13, 2, Nil)
Else
	cSegu := TAFDecimal((cAliasQry)->C20_VLRSEG, 13, 2, Nil)
EndIf

Return(cSegu)
