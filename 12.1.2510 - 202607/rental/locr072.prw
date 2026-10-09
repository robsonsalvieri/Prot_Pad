#INCLUDE "rwmake.ch" 
#Include "Protheus.ch"
#Include "Topconn.ch"
#Include "locr072.ch" 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLOCR072    บ Autor ณ Rogerio O Candisani บ Data ณ  08/08/08 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Relatorio de Analise das Medicoes nao faturadas para a     บฑฑ
ฑฑบ            Controladoria                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑ Alteracao -                                                             ฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP6 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Function LOCR072()
Local cDesc1     	:= STR0001	// "Este programa tem como objetivo imprimir relatorio "
Local cDesc2        := STR0002	// "de acordo com os parametros informados pelo usuario."
Local cDesc3        := STR0003	// "Disponibilidade de Frota"
//Local cPict         := ""
Local titulo       	:= STR0004	// "Medi็๕es nใo Faturadas Analํtico"
Local nLin         	:= 80
Local cPerg        	:="LOCR072"
Local Cabec1       	:= ""
Local Cabec2       	:= ""
//Local imprime      	:= .T.
Local aOrd := {}

Private lEnd        := .F.
Private lAbortPrint := .F.
//Private CbTxt       := ""
Private limite      := 120
Private tamanho     := "M"
Private nomeprog    := "LOCAR072" // Coloque aqui o nome do programa para impressao no cabecalho
Private nTipo       := 18
Private aReturn     := { STR0012, 1, STR0013, 2, 2, 1, "", 1} //"Zebrado"###"Administracao"
Private nLastKey    := 0
Private cbtxt      	:= Space(10)
Private cbcont     	:= 00
Private CONTFL     	:= 01
Private m_pag      	:= 01
Private wnrel      	:= "LOCAR072" // Coloque aqui o nome do arquivo usado para impressao em disco
Private cString 	:= ""
Private nTotHor		:=0
Private nTotVHor	:=0
Private nTotVMob	:=0
Private nTotVDes	:=0
Private nTotVSeg	:=0
Private nTotVMo		:=0
Private nTotVIss	:=0
Private nVlrTot		:=0
Private xTotHor		:=0
Private xTotVHor	:=0
Private xTotVMob	:=0
Private xTotVDes	:=0
Private xTotVSeg	:=0
Private xTotVMo		:=0
Private xTotVIss	:=0
Private xVlrTot		:=0
Private cProjet		:=""      
Private cCliente	:=""   
Private cFrota		:=""
Private cNomFro		:=""
Private cNumPV		:=""
Private cEmissao	:=""
Private cSerie		:=""

	IF !Pergunte(cPerg,.T.)        
		Return()
	Endif    

//	titulo       := "Relacao de Medicoes Nao Faturadas na Data Base:" +SUBST(DTOS(mv_par09),7,2)+"/"+SUBST(DTOS(mv_par09),5,2)+"/"+SUBST(DTOS(mv_par09),3,2)"
	Titulo := STR0004 + STR0006 + AllTrim(DtoC(mv_par07)) + STR0007 + AllTrim(DtoC(mv_par08)) //+ STR0008  + AllTrim(DtoC(mv_par09)) + STR0009 + Iif(mv_par10==1,STR0010,STR0011) //##" Perํodo de "##" a "##" na Data Base "##" pela "##"Data de Inํcio da Medi็ใo"##"Parte Diแria"
	         //         1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20        21        22
	         //1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
	Cabec1:=  STR0005 // " Data     OS        Frota               H.Ini     H.Fim     Qt.Hr     Km Ini    Km Fim    Qt.Km     Vlr.Hora       MOB            DESMOB         Seguro         Vlr.MO         Vlr.ISS        Total                                       "
	tamanho:= "G"

	wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,cString)

	If nLastKey == 27
		Return
	Endif

	nTipo := If(aReturn[4]==1,15,18)

	RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณRUNREPORT บ Autor ณ AP6 IDE            บ Data ณ  25/06/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS บฑฑ
ฑฑบ          ณ monta a janela com a regua de processamento.               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/   
Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)
//Local cCodBem	:= ""
//Local nOrdem
Local cFilatu	:= GetMv("MV_FILFAT",,xFilial("SC6"))
Local xTotKM	:= nTotKm := 0
//Local aVenc		:= {}, nDup,nVlCruz
Local cPrevis	:= CtoD("//")
Local _nDiasF	:= 2	// N๚mero de dias para gerar o faturamento

	cMedicao:="" 

	MontaMed()

	dbSelectArea("TRB")

	SetRegua(RecCount())
	dbGoTop()

	While !EOF()
		IncRegua()
		//Verificar se pedido foi faturado - candisani - definido com Leonor e Jefferson 07/08/08  	
		cFilr  := cFilAtu
		cNumNf := ""
		cSerie := ""
		cFatura:= ""
		cEmissao:= CtoD("//")

		cNumPV:=TRB->FPN_NUMPV
		cProjet:=TRB->FPN_PROJET

		SC6->(dbsetorder(1))
		If SC6->(dbseek(xfilial("SC6")+cNumPV)) .and. !Empty(cNumPV)
			cFilr  := xFilial("SC6")
			cNumNf := SC6->C6_NOTA
			cSerie := SC6->C6_SERIE
			cFatura:= "(Fil)"
			SF2->(dbSetOrder(1))
			If SF2->(dbseek(cFilr+cNumNf+cSerie)) .and. !Empty(cNumNf) .and. !Empty(cSerie)
				cEmissao := SF2->F2_EMISSAO
			Else
				cEmissao	:= CtoD("//")
			EndIf
			/*
		ElseIf SC6->(dbseek("01"+cNumPV)) .and. !Empty(cNumPV)
			cFilr  := "01"
			cNumNf := SC6->C6_NOTA
			cSerie := SC6->C6_SERIE
			cFatura:= "(Mat)"
			SF2->(dbSetOrder(1))
			If SF2->(dbseek(cFilr+cNumNf+cSerie)) .and. !Empty(cNumNf) .and. !Empty(cSerie)
				cEmissao := SF2->F2_EMISSAO
			Else
				cEmissao	:= CtoD("//")
			EndIf
		*/	
		EndIf

		If !Empty(cEmissao)
			If cEmissao <= mv_par09
				DBSKIP()
				LOOP
			Endif	
		Endif  
		
		/*
		If lAbortPrint
			@ nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif
		*/

		If nLin > 55 // Salto de Pแgina. Neste caso o formulario tem 55 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 8
		Endif

		cProjet:=TRB->FPN_PROJET
		cCliente:= Posicione("FP0",1,xFilial("FP0")  + CProjet  , "FP0_CLINOM")
		_nDiasF	:= FP0->FP0_PREVFT

		cPrevis	:= CtoD(SubStr(TRB->FPN_DTFIM,7,2) + "/" + SubStr(TRB->FPN_DTFIM,5,2) + "/" + SubStr(TRB->FPN_DTFIM,1,4))	//20080916 StoD(TRB->FPN_DTFIM)
		cPrevis := cPrevis + _nDiasF
		cPrevis := DataValida(cPrevis)
		
		cFrota:=TRB->FPP_FROTA
		cNomFro:=Posicione("ST9",1,xFilial("ST9")  + CFrota  , "T9_NOME")   				     

		DbSelectArea("TRB")
		@ nLin, 00 PSAY "Projeto:"+"-"+FPN_PROJET
		@ nLin, 40 PSAY "Obra:"+"-"+FPN_OBRA     
		@ nLin, 60 PSAY "Cliente:"+" - " +cCLiente
		@ nLin,195 PSAY "Prev Ft: "+SUBST(dtos(cPrevis),7,2)+"/"+SUBST(dtos(cPrevis),5,2)+"/"+SUBST(dtos(cPrevis),3,2)
		nLin := nLin+1
		@ nLin, 00 PSAY "Medicao:"+"-"+FPN_COD 
		@ nLin, 20 PSAY "AS:"+"-"+FPN_AS 
		@ nLin, 60 PSAY "Equipamento:"+"-"+cNomFro
		@ nLin,130 PSAY "Viagem:"+"-"+FPN_VIAGEM  
		@ nLin,160 PSAY "N. Pedido:"+FPN_NUMPV  
		@ nLin,180 PSAY "NF: "+cNumNF
		@ nLin,195 PSAY "Emissao: "+SUBST(dtos(cEmissao),7,2)+"/"+SUBST(dtos(cEmissao),5,2)+"/"+SUBST(dtos(cEmissao),3,2) + " " + cFatura
		nLin := nLin+2 	 
		cMedicao:=FPN_COD
		While !EOF() .and. cMedicao == FPN_COD
			If nLin > 64 // Salto de Pแgina. Neste caso o formulario tem 55 linhas...
				Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
				nLin := 8
			Endif
							//          1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20        21        22
							// 1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
			Cabec1:= STR0005	//" Data     OS        Frota               H.Ini     H.Fim     Qt.Hr     Km Ini    Km Fim    Qt.Km     Vlr.Hora       MOB            DESMOB         Seguro         Vlr.MO         Vlr.ISS        Total                                       "
		
			@ nLin, 00 PSAY SUBST(TRB->FPP_DTMEDI,7,2)+"/"+SUBST(TRB->FPP_DTMEDI,5,2)+"/"+SUBST(TRB->FPP_DTMEDI,3,2)
			@ nLin, 10 PSAY TRB->FPP_OS
			@ nLin, 20 PSAY SUBS(TRB->FPP_FROTA,1,11)
			@ nLin, 40 PSAY TRB->FPP_HORAI Picture "@R 99:99"
			@ nLin, 50 PSAY TRB->FPP_HORAF Picture "@R 99:99"
			
			@ nLin, 60 PSAY TRB->FPP_QTDHR Picture "@E 999.99"
			nTotHor:=nTotHor+TRB->FPP_QTDHR
		
			@ nLin, 70 PSAY TRB->FPP_KMINI Picture "@E 9,999.99"
			@ nLin, 80 PSAY TRB->FPP_KMFIM Picture "@E 9,999.99"
			
			@ nLin, 90 PSAY TRB->FPP_QTDKM Picture "@E 99,999.99"
			nTotKm:=nTotKm+TRB->FPP_QTDKM	    
			
			@ nLin, 100 PSAY TRB->FPP_VALHOR Picture "@E 999,999.99"
			
			@ nLin, 115 PSAY TRB->FPP_VLRMOB Picture "@E 999,999.99"
			nTotVMob:=nTotVMob+TRB->FPP_VLRMOB
			
			@ nLin,130 PSAY TRB->FPP_VLRDES Picture "@E 999,999.99"
			nTotVDes:=nTotVDes+TRB->FPP_VLRDES
			
			@ nLin,146 PSAY TRB->FPP_VALSEG Picture "@E 999,999.99"
			nTotVSeg:=nTotVSeg+TRB->FPP_VALSEG
			
			@ nLin,160 PSAY TRB->FPP_VLTOTM Picture "@E 999,999.99"
			nTotVMo:=nTotVMo+TRB->FPP_VLTOTM
			
			@ nLin,175 PSAY TRB->FPP_VALISS Picture "@E 999,999.99"
			nTotVIss:=nTotVIss+TRB->FPP_VALISS
			
			@ nLin,190 PSAY TRB->FPP_VLRTOT Picture "@E 999,999,999.99"
			nVlrTot:=nVlrTot+TRB->FPP_VLRTOT 
			
			nLin := nLin + 1
			DbSkip()                 
		enddo 

		@nLin, 00 PSAY "Total da Medicao: " + cMedicao
		@nLin, 60 PSAY nTotHor  Picture "@E 999.99"
		@nLin, 90 PSAY nTotKm   Picture "@E 999,999.99"
		@nLin,115 PSAY nTotVMob Picture "@E 999,999.99"
		@nLin,130 PSAY nTotVDes Picture "@E 999,999.99"
		@nLin,146 PSAY nTotVSeg Picture "@E 999,999.99"
		@nLin,160 PSAY nTotVMo  Picture "@E 999,999.99"
		@nLin,175 PSAY nTotVIss Picture "@E 999,999.99"
		@nLin,190 PSAY nVlrTot Picture  "@E 999,999,999.99"

		xTotHor  := xTotHor + nTotHor
		xTotKM   := xTotKM + nTotKm
		xTotVMob := xTotVMob + nTotVMob
		xTotVDes := xTotVDes + nTotVDes
		xTotVSeg := xTotVSeg + nTotVSeg
		xTotVMo  := xTotVMo + nTotVMo
		xTotVIss := xTotVIss + nTotVIss
		xVlrTot  := xVlrTot + nVlrTot

		nTotHor  := 0
		nTotKm   := 0
		nTotVMob := 0
		nTotVDes := 0
		nTotVSeg := 0
		nTotVMo  := 0
		nTotVIss := 0
		nVlrTot  := 0    
		nLin := nLin + 1
		nLin := nLin + 1
	EndDo

	@ nLin, 00 PSAY Replicate("-",219)
	nLin := nLin + 1
	@ nLin, 00 PSAY "Total Geral: "
	@ nLin,115 PSAY xTotVMob Picture "@E 999,999.99"
	@ nLin,130 PSAY xTotVDes Picture "@E 999,999.99"
	@ nLin,146 PSAY xTotVSeg Picture "@E 999,999.99"
	@ nLin,160 PSAY xTotVMo  Picture "@E 999,999.99"
	@ nLin,175 PSAY xTotVIss Picture "@E 999,999.99"
	@ nLin,190 PSAY xVlrTot Picture  "@E 999,999,999.99"

	SET DEVICE TO SCREEN

	If aReturn[5]==1
		dbCommitAll()
		SET PRINTER TO
		OurSpool(wnrel)
	Endif

	MS_FLUSH()

Return

//Funcao para montar os transportes e tipos de tansportes
Static Function MontaMed()
//Local cAlias 
//Local aTipo := {}
Local cQuery

	If Select("TRB") > 0
		DbSelectArea("TRB")
		DbCloseArea()
	Endif   

	/*
	+mv_par01+
	+mv_par02+
	+mv_par03+
	+mv_par04+
	+mv_par05+
	+mv_par06+
	If mv_par10 == 1
		+DTOS(mv_par07)+
		+DTOS(mv_par08)+
	else
		+DTOS(mv_par07)+
		+DTOS(mv_par08)+
	endif
	*/

	cQUery := " SELECT FPN_AS, FPN_PROJET, FPN_OBRA, FPN_VIAGEM, FPN_COD , FPN_DTINIC, FPN_DTFIM, "
	cQuery += " FPN_MOBDTP, FPN_MOBDTR, FPN_DESDTP, FPN_DESDTR, FPN_CLIENT, FPN_LOJA, FPN_VALSER, "
	cQuery += " FPN_VALTOT, FPN_SITUAC, FPN_NUMPV, FPN_VLDESC, FPN_VLACRE, FPN_ENCEAS, FPN_CONDPA, FPP_ITEM, "
	cQuery += " FPP_OS, FPP_DTMEDI, FPP_FROTA, FPP_HORAI, FPP_HORAF, FPP_HORTOT, FPP_QTDHR, FPP_BASE, "
	cQuery += " FPP_VALHOR, FPP_VLTOHR, FPP_VLRMOB, FPP_VLRDES, FPP_TIPO, FPP_VALSEG, FPP_VALISS, "
	cQuery += " FPP_VLTOTM, FPP_VLRTOT, FPP_COD, FPP_VLRDES, FPN_NUMPV, FPP_KMINI, FPP_KMFIM, FPP_QTDKM "   
	cQuery += " FROM "+ RetSqlName("FPN") + " FPN "
	cQuery += " LEFT OUTER JOIN "+ RetSqlName("FPP") + " FPP ON  FPN_FILIAL+FPN_COD=FPP_FILIAL+FPP_COD "
	cQUery += " WHERE FPN_FILIAL = '"+xFilial("FPN")+"'   
	cQUery += " AND FPN_COD  BETWEEN ? AND ? "
	cQUery += " AND FPN_AS  BETWEEN ? AND ? "
	cQUery += " AND FPN_PROJET  BETWEEN ? AND ? "
	If mv_par10 == 1
		cQUery += " AND FPN_DTINIC  BETWEEN ? AND ? "
	Else
		cQUery += " AND FPP_DTMEDI  BETWEEN ? AND ? "
	EndIf	
	cQUery += " AND FPN.D_E_L_E_T_ = ' ' AND FPP.D_E_L_E_T_ = ' ' "
	cQUery += " AND	 FPN.FPN_SITUAC <> '3'
	cQUery += " ORDER BY FPN_COD,FPP_DTMEDI" //,FPN_AS,FPN_PROJET,FPN_OBRA   "

	cQUery := ChangeQuery(cQUery)
	aBindParam := {	mv_par01,;
					mv_par02,;
					mv_par03,;
					mv_par04,;
					mv_par05,;
					mv_par06,;
					DTOS(mv_par07),;
					DTOS(mv_par08)}
	MPSysOpenQuery(cQuery,"TRB",,,aBindParam)
	//TcQuery cQuery New Alias "TRB"

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณVALIDPERG บ Autor ณ AP5 IDE            บ Data ณ  13/09/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Verifica a existencia das perguntas criando-as caso seja   บฑฑ
ฑฑบ          ณ necessario (caso nao existam).                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function ValidPerg(cPerg)
/*
Local _sAlias := Alias()
Local aRegs := {}
Local i,j

dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg,10)

//         {GRUPO,ORDEM,PERGUNT         ,PERSPA          ,PERENG             ,VARIAVL ,TIPO,TAMANHO,DECIMAL,PRESEL,GSC,VALID      ,VAR01      ,DEF01,DEFSPA1,DEFENG1                     ,CNT01,VAR02,DEF02,DEFSPA2,DEFENG2,CNT02,VAR03,DEF03,DEFSPA3,DEFENG3,CNT03,VAR04,DEF04,DEFSPA4,DEFENG4,CNT04,VAR05,DEF05,DEFSPA5,DEFENG5,CNT05,F3   ,PYME,GRPSXG,HELP,PICTURE     })
AAdd(aRegs,{cPerg,"01" ,"Medicao de?","Medicao de?","Medicao de?","mv_ch0","C",06,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","FPN","S","","",""})  
AAdd(aRegs,{cPerg,"02" ,"Medicao ate?","Medicao ate?","Medicao ate?","mv_ch0","C",06,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","FPN","S","","",""})  
AAdd(aRegs,{cPerg,"03" ,"AS de?","AS de?","AS de?","mv_ch0","C",27,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","DTQAS","S","","",""})  
AAdd(aRegs,{cPerg,"04" ,"AS ate?","AS ate?","AS ate?","mv_ch0","C",27,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","DTQAS","S","","",""}) 
AAdd(aRegs,{cPerg,"05" ,"Projeto de?","Projeto de?","Projeto de?","mv_ch0","C",22,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","ZA0","S","","",""})  
AAdd(aRegs,{cPerg,"06" ,"Projeto ate?","Projeto ate?","Projeto ate?","mv_ch0","C",22,0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","ZA0","S","","",""})
AAdd(aRegs,{cPerg,"07" ,"Periodo de?","Periodo de?","Periodo de?","mv_ch0","D",08,0,0,"G","" ,"mv_par07","","","","","","","","","","","","","","","","","","","","","","","","","","S","","",""})  
AAdd(aRegs,{cPerg,"08" ,"Periodo ate?","Periodo ate?","Periodo ate?","mv_ch0","D",08,0,0,"G","" ,"mv_par08","","","","","","","","","","","","","","","","","","","","","","","","","","S","","",""}) 
AAdd(aRegs,{cPerg,"09" ,"Data Base","Data Base","Data Base","mv_ch0","D",08,0,0,"G","","mv_par09","","","","","","","","","","","","","","","","","","","","","","","","","FPN","S","","",""})  
AAdd(aRegs,{cPerg,"10" ,"Filtrar pela Data ?" ,"Filtrar pela Data ?" ,"Filtrar pela Data ?" ,"mv_cha" ,"N" ,01     ,0      ,2     ,"C",""                                             ,"mv_par10","Inํcio Medi็ใo","Inํcio Medi็ใo","Inํcio Medi็ใo",""   ,""   ,"Parte Diแria" ,"Parte Diแria" ,"Parte Diแria" ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""   ,""      ,"S" ,"" ,"" ,""})

For i:=1 to Len(aRegs)
    If !dbSeek(cPerg+aRegs[i,2])
        RecLock("SX1",.T.)
        For j:=1 to FCount()
            If j <= Len(aRegs[i])
                FieldPut(j,aRegs[i,j])
            Endif
        Next
        MsUnlock()
    Endif
Next

dbSelectArea(_sAlias)
*/
Return

