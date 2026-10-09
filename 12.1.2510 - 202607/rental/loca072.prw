#INCLUDE "loca072.ch"  
#INCLUDE "PRCONST.CH"
#INCLUDE "PROTHEUS.CH"

/*/{PROTHEUS.DOC} LOCA072.PRW
ITUP BUSINESS - TOTVS RENTAL
GRÁFICO DE STATUS DOS PROJETOS
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 03/12/2020
@VERSION P12
@HISTORY 03/12/2020, FRANK ZWARG FUGA, FONTE PRODUTIZADO.
/*/

FUNCTION LOCA072()
Local ASIZE     := MSADVSIZE(.F.)
Local ACOORDJAN := {}
Local oFWChart
Local oDlg 
Local DINI      := STOD( LEFT(DTOS(DDATABASE),6) + "01" )
Local DFIM      := STOD( LEFT(DTOS(DDATABASE),6) + IIF( STRZERO(MONTH(DDATABASE),2) $ "01;03;05;07;08;10;12", "31", IIF( STRZERO(MONTH(DDATABASE),2) $ "04;06;09;11", "30", "28") ) )
Local APARAMBOX := {}
Local ARET      := {}
Private aResult := {}

	AADD(APARAMBOX,{1,STR0025        , DINI    , "@E XX/XX/XXXX"   , ""                    , ""     , ""  , 50 , .T.}) // "PERÍODO DE "
	AADD(APARAMBOX,{1,STR0026        , DFIM    , "@E XX/XX/XXXX"   , ""                    , ""     , ""  , 50 , .T.}) // "PERÍODO ATÉ"

	IF PARAMBOX(APARAMBOX,"",@ARET,,,,,,,,.F.)       			
	ENDIF

	If len(aRet) == 0
		RETURN
	EndIF

	dIni := aRet[1]
	dFim := aRet[2]
	/* retiradas validações da data, pois já são validados como obrigatórios no parambox
	If valtype(dIni) <> "D" .or. valType(dFim) <> "D"
		Return
	EndIF
	If empty(dFim)
		Return
	EndIF
	*/
	PROCESSA({|| LOCA072B(dIni,dFim) })

	CTITJAN   := STR0004 //"STATUS DOS PROJETOS"

	AADD(ACOORDJAN,ASIZE[7])
	AADD(ACOORDJAN,0       )
	AADD(ACOORDJAN,ASIZE[6])
	AADD(ACOORDJAN,ASIZE[5])

	DEFINE MSDIALOG ODLG TITLE OEMTOANSI(CTITJAN) OF OMAINWND PIXEL FROM ACOORDJAN[1],ACOORDJAN[2] TO ACOORDJAN[3],ACOORDJAN[4]

	oFWChart := FWChartFactory():New()
	oFWChart := oFWChart:getInstance( BARCHART ) // cria objeto FWChartBar
	oFWChart:init( oDLG, .F. )
	oFWChart:setTitle( "Status dos Projetos", CONTROL_ALIGN_CENTER )
	oFWChart:setLegend( CONTROL_ALIGN_LEFT )
	oFWChart:oFwChartColor:SetColor("RANDOM")
	oFWChart:setPicture( "99" )
	oFWChart:addSerie( STR0005, aResult[1,2]  ) // "DIGITADO C/ CONTRATO"
	oFWChart:addSerie( STR0006, aResult[2,2]  ) //"DIGITADO"
	oFWChart:addSerie( STR0007, aResult[3,2]  ) //"EM APROVAÇÃO"
	oFWChart:addSerie( STR0008, aResult[4,2]  ) //"APROVADO"
	oFWChart:addSerie( STR0009, aResult[5,2]  ) //"NÃO APROVADO"
	oFWChart:addSerie( STR0010, aResult[6,2]  ) //"FECHADO"
	oFWChart:addSerie( STR0011, aResult[7,2]  ) //"INDISPONÍVEL"
	oFWChart:addSerie( STR0012, aResult[8,2]  ) //"REJEITADO"
	oFWChart:addSerie( STR0013, aResult[9,2]  ) //"FATURADO"
	oFWChart:addSerie( STR0014, aResult[10,2] ) //"REVISADO"
	oFWChart:addSerie( STR0015, aResult[11,2] ) //"EXCLUIDO"
	oFWChart:addSerie( STR0016, aResult[12,2] ) //"CANCELADO"

	oFWChart:build()
	ACTIVATE MSDIALOG oDlg
Return

// Calculo dos valores do gráfico
// Frank Fuga em 21/08/23
Function LOCA072B(dIni,dFim)
	FP0->(dbSetOrder(1))
	FP0->(dbSeek(xFilial("FP0")))
	ProcRegua(0)
	aResult := {}
	aadd(aResult,{1,0}) // "DIGITADO C/ CONTRATO"
	aadd(aResult,{2,0}) //"DIGITADO"
	aadd(aResult,{3,0}) //"EM APROVAÇÃO"
	aadd(aResult,{4,0}) //"APROVADO"
	aadd(aResult,{5,0}) //"NÃO APROVADO"
	aadd(aResult,{6,0}) //"FECHADO"
	aadd(aResult,{7,0}) //"INDISPONÍVEL"
	aadd(aResult,{8,0}) //"REJEITADO"
	aadd(aResult,{9,0}) //"FATURADO"
	aadd(aResult,{10,0}) //"REVISADO"
	aadd(aResult,{11,0}) //"EXCLUIDO"
	aadd(aResult,{12,0}) //"CANCELADO"

	While !FP0->(Eof()) .and. FP0->FP0_FILIAL == xFilial("FP0")
		IncProc()
		If DINI <= FP0->FP0_DATINC .AND. DFIM >= FP0->FP0_DATINC
			If FP0_STATUS=="1" .and. !EMPTY(ALLTRIM(GETADVFVAL("FQ5", "FQ5_SOT",XFILIAL("FQ5") + FP0_FILIAL + FP0_PROJET,21,""))) // "DIGITADO C/ CONTRATO"
				aResult[1,2] ++
			ElseIF FP0_STATUS=="1"
				aResult[2,2] ++
			ElseIf FP0_STATUS=="2"
				aResult[3,2] ++
			ElseIf FP0_STATUS=="3"
				aResult[4,2] ++
			ElseIf FP0_STATUS=="4"
				aResult[5,2] ++
			ElseIF FP0_STATUS=="5"
				aResult[6,2] ++
			ElseIf FP0_STATUS=="6"
				aResult[7,2] ++
			ElseIf FP0_STATUS=="7"
				aResult[8,2] ++
			ElseIf FP0_STATUS=="8"
				aResult[9,2] ++
			ElseIf FP0_STATUS=="A"
				aResult[10,2] ++
			ElseIf FP0_STATUS=="B"
				aResult[11,2] ++
			ElseIF FP0_STATUS=="C"
				aResult[12,2] ++
			EndIF

		EndIF
		FP0->(dbSkip())
	EndDo
Return
