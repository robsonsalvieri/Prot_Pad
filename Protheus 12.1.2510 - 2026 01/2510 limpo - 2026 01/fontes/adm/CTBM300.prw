#include "ctbm300.ch"
#include "protheus.ch"

Static __lBlind   := IsBlind()
Static _oCtbm3002
Static __IsCtbJob
Static __lExistTRW
Static __cTabTrw
Static _lMVLotDoc := .F.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณPrograma  ณ CTBM300  ณAutor  ณ Felipe Aurelio de Meloณ Data ณ 17/11/08 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Permitir copiar saldos analiticos ou sinteticos de uma     ณฑฑ
ฑฑณ          ณ determinada conta, cc, item ou classe de valor para um     ณฑฑ
ฑฑณ          ณ segundo tipo de saldo informado pelo usuario.              ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ Contabilidade Gerencial - Movimentacoes                    ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ            ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.          ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณProgramador ณ Data   ณ BOPS/FNC  ณ  Motivo da Alteracao                ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Jose Glez  ณ        ณ  MMI-5346 ณNumero de p๓liza debe ser consecutivoณฑฑ
ฑฑณ            ณ        ณ           ณpor mes.                             ณฑฑ
ฑฑณ  Marco A.  ณ28/05/18ณDMINA-2113 ณSe modifica funcion CTM103ProxDoc(), ณฑฑ
ฑฑณ            ณ        ณ           ณpara Numero de Poliza Consecutivo porณฑฑ
ฑฑณ            ณ        ณ           ณmes. (MEX)                           ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Ctbm300(lAuto)

Local nOpca       := 0
Local aSays       := {}
Local aButt       := {}
Local aArea       := GetArea()
Local cPerg       := "CTBM30"
Local cProg       := "CTBM300"
Local oSx1        := FWSX1Util():New()
Local aPergRel    := {}

Private cRetSX5SL := ""
Default lAuto     := .F.

//Guarda variaveis dos parametros em memoria
If !FWGetRunSchedule()
	Pergunte(cPerg,.F.)
EndIf

oSx1:AddGroup(cPerg)
oSx1:SearchGroup()
aPergRel := oSx1:GetGroup(cPerg)
If Len(aPergRel) > 0 .And. Len(aPergRel[2]) >= 19
	_lMVLotDoc := .T.
Else 
	_lMVLotDoc := .F.
EndIf

If IsBlind() .Or. lAuto
   If VldCtbm300(.T.)
		BatchProcess(STR0001,; //"C๓pia de saldos"
						 STR0002 + Chr(13) + Chr(10) +; //"Esta rotina tem como objetivo copiar um conjunto de lan็amentos ou saldos de um"
						 STR0003 + Chr(13) + Chr(10) +; //"tipo de saldo origem para um tipo de saldo destino. ษ possํvel c๓piar tanto os"
						 STR0004 + Chr(13) + Chr(10) +; //"lan็amentos contแbeis como os saldos por conta, centro de custo, item e classe"
						 STR0005 + Chr(13) + Chr(10) ,; //"de valor, de acordo com a informa็ใo dos parโmetros."
						 cProg,{|| ExeCtbm300(.T.) }, { || .F. })
	EndIf
Else
	aAdd(aSays, STR0002 )	// "Esta rotina tem como objetivo copiar um conjunto de lan็amentos ou saldos em um"
	aAdd(aSays, STR0003 )	// "tipo de saldo origem para um tipo de saldo destino. ษ possํvel c๓piar tanto os"
	aAdd(aSays, STR0004 )	// "lan็amentos contแbeis como dos saldos por conta, centro de custo, item e classe"
	aAdd(aSays, STR0005 )	// "de valor, de acordo com a sele็ใo do usuแrio."

	aAdd(aButt, { 5, .T., {|| Pergunte(cPerg,.T.) } } )
	aAdd(aButt, { 1, .T., {|| nOpca:= 1,IIf(VldCtbm300(.F.),FechaBatch(),nOpca:=0)}})
	aAdd(aButt, { 2, .T., {|| FechaBatch() }} )

	FormBatch(STR0001,aSays,aButt,,190) // Copia de saldos

	If nOpca == 1
		FWMsgRun(, {|oSay| ExeCtbm300(.F., oSay) }, STR0112, STR0113) // #"Processando" ##"Processando c๓pia de saldos..."
	EndIf
EndIf


RestArea(aArea)

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออออหออออออัออออออออออปฑฑ
ฑฑบPrograma  ณExeCtbm300บAutor  ณ Felipe Aurelio de Meloบ Data ณ 17/11/08 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออออสออออออฯออออออออออนฑฑ
ฑฑบDescricao ณ Executa processo de copia de registros                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Contabilidade Gerencial - Movimentacoes                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function ExeCtbm300(lAuto, oSay)

Local lAnalitico  := MV_PAR07 == 2 // 1=Sintetico / 2=Analitico
Local lTdsMoedas  := MV_PAR11 == 1 // 1=Totas     / 2=Especificar
Local dDataIni    := MV_PAR09     // Data Inicial
Local dDataFim    := MV_PAR10     // Data Final
Local lAtuSld1    := .F.          // Indicar se atualiza saldos apos o exclusao dos lancamentos
Local lAtuSld2    := .F.          // Indicar se atualiza saldos apos o gravacao de lancamentos de saldo
Local lAtuSld3    := .F.          // Indicar se atualiza saldos apos o gravacao de lancamentos de movimentos
Local lConfirma   := .F.          // Indicar se confirma exclusao dos lancamentos
Local cMsg        := ""
Local nX          := 0
Local lProcedure  := .F.
Local lRet        := .T.
Local nMaxLinha   := IIf(SuperGetMV("MV_NUMLIN")<1,999,CtbLinMax(GetMv("MV_NUMLIN")))
Local aDatabase	  :={}
Local cTDataBase  := ""
Local cTpSalDest  :=""
Local cAssProc    := EngSPS25Signature("25")
Local oCTBM300    :=  Nil
Local cCTBM300    := ""
Local cMvsoma     := Str(SuperGetMV("MV_SOMA",.F.,1),1,0)
Local lMudaTRT    := .F.

Private aResult   := {}
Private cLoteDe	  := " "
Private cLoteAte  := Replicate("Z", TamSx3("CT2_LOTE")[1])
Private cSbLoteDe := " "
Private cSbLoteAte:= Replicate("Z", TamSx3("CT2_LOTE")[1])
Private cDocDe	  := " "
Private cDocAte   := Replicate("Z", TamSx3("CT2_LOTE")[1])


Default oSay := Nil


//Tratamento para caso usuแrio escolha
//metodo de copia = multiplos saldos 
If MV_PAR01 == 2
	MV_PAR02 := 2 //Sele็ใo dos saldos    = Mov. multi saldos
	MV_PAR05 := 1 //Metodo de copia       = Adicionar
	MV_PAR06 := 2 //Tipo de copia simples = Movimentos
	MV_PAR07 := 2 //Movimentos copiados   = Analiticos
	lAnalitico := .T.
EndIf

Do Case
	Case MV_PAR06 == 1  //Tipo de copia simples - saldos
		dDataIni := MV_PAR09
		dDataFim := MV_PAR10
	Case MV_PAR06 == 2  //Tipo de copia simples - movimentos
	    If lAnalitico
	    	dDataIni := MV_PAR09
	    Else
	    	dDataIni := MV_PAR10
	    EndIf
	Case MV_PAR06 == 3  //Tipo de copia simples - ambos
		dDataIni := MV_PAR09
EndCase

If _lMVLotDoc
	cLoteDe    := MV_PAR19
	cLoteAte   := If(Empty(AllTrim(MV_PAR20)),cLoteAte,  MV_PAR20)
	cSbLoteDe  := MV_PAR21
	cSbLoteAte := If(Empty(AllTrim(MV_PAR22)),cSbLoteAte,MV_PAR22)
	cDocDe	   := MV_PAR23
	cDocAte	   := If(Empty(AllTrim(MV_PAR24)),cDocAte ,  MV_PAR24)
EndIf

/*  O Processo sera executado via procedure nas situacoes abaixo
	1 - Copia simples de Movimentos ( Lancamentos ) com adicao de lancamentos
    2 - Copia de Multiplos Saldos
    3 - Se os cpos relativos a copia de multiplos saldos existir, CT2_CTLSLD, CT2_MLTSLD */

If TcSrvType() != 'AS/400'
	aadd(aDatabase,{"MSSQL" })
	aadd(aDatabase,{"MSSQL7" })
	aadd(aDatabase,{"ORACLE" })
	aadd(aDatabase,{"DB2" })
	aadd(aDatabase,{"SYBASE" })
//	aadd(aDatabase,{"INFORMIX" })
	If Trim(Upper(TcSrvType())) = "ISERIES"
		// Top 4 para AS400, instala procedures = DB2
		aadd(aDatabase,{"DB2/400"})
	EndIf
	cTDataBase = Trim(Upper(TcGetDb()))
	nPos:= Ascan( aDataBase, {|z| z[1] == cTDataBase })
	
	If nPos != 0 .and. MV_PAR06 <> 1  .and. MV_PAR07 <> 1  //MV_PAR06= 1 -> Saldos / MV_PAR07 = 1 - Sintetico
		lProcedure := .T.
	EndIf
EndIf

//*Verificar se a rotina CTBA190 estแ sendo executada
If !CT190ATUMV(dDataFim)
	If !isBlind()
		Help(" ", 1, "NOREPROC", , STR0115, 2, 0,,,,,,)//Existe uma execu็ใo do reprocessamento de saldos, aguarde o fim do processo. //Aten็ใo
	EndIF
	Return
EndIf

//*Valida็๕es para executar procedure
If lProcedure
	If __IsCtbJob == Nil
		__IsCtbJob := IsCtbJob()
	EndIf

	If __cTabTrw == Nil
		lMudaTRT := SuperGetMV("MV_MUDATRT",.F.,.T.)
		__cTabTRW := "TRW"+SM0->M0_CODIGO+"0"+Iif(lMudaTRT, "_SP", "")
	EndIf

	If __lExistTRW == Nil
		__lExistTRW := TcCanOpen(__cTabTRW)
	EndIf

	If SPSMigrated()//se jแ estแ usando o novo processo de procedures		
		oCTBM300 	:= EngSPSStatus("25",cEmpAnt)				
		lProcedure 	:= (oCTBM300["signature"] == cAssProc)
		cCTBM300 	:= GetSPName("CTB301","25")
	EndIf
EndIF	

/* --------------------------------------------------------------------
	Execucao do processo sem as procedures
	-------------------------------------------------------------------- */
If MV_PAR05 == 2 .Or. MV_PAR05 == 3  // Metodo copia simples - 2=Sobrepor / 3=Apagar
	lConfirma := IIF( lAuto,.T.,MsgYesNo( STR0101, STR0102 ) )
	If !lConfirma
		Return .T.
	EndIf

	If !lProcedure
		lAtuSld1 := ApagaCtbm300( dDataIni, dDataFim, MV_PAR03, MV_PAR04, MV_PAR12, lTdsMoedas )	
	EndIf

EndIf

If lProcedure 

	cTpSalDest := Trim(mv_par04)+"#"
	cTpSalDest := Strtran(StrTran(cTpSalDest,";"),"0")//tratamento para nใo ser enviado o tipo 0	
	
	MsgRun( STR0081+ STR0082, STR0083, {||aResult := TCSPExec( xProcedures(cCTBM300),;  //"Processando, ""aguarde..", "Copia de Saldos"
				cFilAnt,;                         			// Filial corrente
				Dtos(dDataIni),;                        			// data inicio para o processo
				Dtos(dDataFim),;                        			// Data final para o processo
				If(lTdsMoedas, "1", "0" ),;       			// '1' tds as moedas serao processadas, '0' moeda especifica
				If(lTdsMoedas,"00",Trim(mv_par12)),; 		//moeda a processar 
				cTpSalDest,;                 			//Tipos de saldos DESTINOS para copia simples
				MV_PAR01,;                       			//1 - Copia Simples , 2 - Multiplos Saldos
				MV_PAR03,;                       			//Tipo de saldo Origem
				MV_PAR13,;                       			//1-Mantem Lote e Sblote do Lancto Origem, 2 - pega do parametro
				MV_PAR16,;                       			//1 - Mantem historico do lancamento, 2 - Pegar historico do CT8 ( @IN_MVPAR17 )
				If(Empty(MV_PAR17), " ", Trim(MV_PAR17)),; //1 - Codigo do historico padrao usado para copia de lanctos CT8_HIST
				If(Empty(MV_PAR14), " ", Trim(MV_PAR14)),; //Lote do parametro
				If(Empty(MV_PAR15), " ", Trim(MV_PAR15)),; //Sblote
				nMaxLinha,;                                 // Nro maximo de linhas
				If( MV_PAR01 == 1, '1','0'),;// Se copias simples envio '1'
				cMvsoma,; 					//MV_SOMA
				If(MV_PAR18 == 1,"1","0"),; //Limpa Controle de C๓pia
				cValToChar(MV_PAR05),; //Define se apaga registros
				If(__IsCtbJob .And. __lExistTRW, "1", "0"),; //Se atualiza os saldos em fila
				If(MV_PAR06 == 3,"1","0"),;
				cLoteDe,;    // Lote de
				cLoteAte,;   // Lote Ate
				cSbLoteDe,;  // SubLote de
				cSbLoteAte,; // SubLote Ate
				cDocDe,; 	 // Doc de
				cDocAte,; 	 // Doc Ate
				CTBInTrans())})             // CtbInTrans   

	If Empty(aResult) .Or. aResult[1] = "0"
		If !__lBlind
			MsgAlert(tcsqlerror(),STR0084)  //"Erro na Copia de Saldos!"
		EndIf
		lRet := .F.	
	EndIf    

	If MV_PAR06 == 3 .And. !(__IsCtbJob .And. __lExistTRW)
		//Se tem mais de um tipo de saldo, processo todos para economizar chamadas da CTBA190
		cTpSalDest := alltrim(strtran(strtran(MV_PAR04,';'),'9'))	
		CTBA190( .T., dDataIni, dDataFim,,,IIf(Len(cTpSalDest)>1,"*",cTpSalDest), (MV_PAR11 == 2), Iif( (MV_PAR11 == 2), MV_PAR12, "" ), .F. )	
	EndIf
Else	
	If MV_PAR05 != 3
		Do Case
			// Gera lancamentos de saldo ateh a data
			Case MV_PAR06 == 1  //Tipo de copia simples - saldos
				lAtuSld2 := CTM300Proc( lAnalitico, .T., lTdsMoedas, MV_PAR08 )
				If !lAtuSld2 .And. !lAuto
					Aviso( STR0006, STR0028, { "Ok" } )		// "Nใo foram encontrados lan็amentos de saldos at้ a data inicial informada."
				EndIf
	
			// Gera lancamentos analiticos ou sinteticos (saldos) no periodo
			Case MV_PAR06 == 2  //Tipo de copia simples - movimentos
				lAtuSld3 := CTM300Proc( lAnalitico, .F., lTdsMoedas, MV_PAR08 )
				If !lAtuSld3 .And. !lAuto
					Aviso( STR0006, STR0026, { "Ok" } )		// "Nใo foram encontrados movimentos no perํodo informado."
				EndIf
	
			// Gera lancamentos de saldo ateh a data e lancamentos analiticos ou sinteticos (saldos) no periodo
			Case MV_PAR06 == 3  //Tipo de copia simples - ambos				
				lAtuSld3 := CTM300Proc( lAnalitico, .F., lTdsMoedas, MV_PAR08 )				
				If !lAtuSld3
					cMsg := STR0024 //"Nใo foram encontrados lan็amentos de saldos ou movimentos no perํodo informado."
				EndIf
				If !Empty(cMsg) .And. !lAuto
					Aviso( STR0006, cMsg, { "Ok" } )
				EndIf
		EndCase
	EndIf
		

	If lAtuSld1 .Or. lAtuSld2 .Or. lAtuSld3
		If !lAuto .And. oSay != Nil
			oSay:SetText(STR0114) // "Executando reprocessamento de saldos para os lan็amentos gerados..."
		EndIf
		If MV_PAR01 == 2
			// Tratamento para caso usuแrio escolha metodo de copia = multiplos saldos
			// Executa o reprocessamento de saldos para os lancamentos gerados
			CTBA190( .T., dDataIni, dDataFim,,,"*", (MV_PAR11 == 2), Iif( (MV_PAR11 == 2), MV_PAR12, "" ), .F. )
		Else
			// Executa o reprocessamento de saldos para os lancamentos gerados
			// Nใo processar o saldo tipo 9 e tipo 0.
			cTpSalDest := alltrim(strtran(strtran(MV_PAR04,';'),'9'))
			For nX:=1 To len(cTpSalDest)
					CTBA190( .T., dDataIni, dDataFim,,,SubStr(cTpSalDest,nX,1), (MV_PAR11 == 2), Iif( (MV_PAR11 == 2), MV_PAR12, "" ), .F. )
			Next nX
		EndIf
	EndIf

EndIf	
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออออหออออออัออออออออออปฑฑ
ฑฑบPrograma  ณVldCtbm300บAutor  ณ Felipe Aurelio de Meloบ Data ณ 17/11/08 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออออสออออออฯออออออออออนฑฑ
ฑฑบDescricao ณ Valida o preenchimento dos parametros da pergunta cPerg    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Contabilidade Gerencial - Movimentacoes                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function VldCtbm300(lAuto)

Local x        := 1
Local lRet     := .T.
Local QtdParam := 18

For x:=1 To QtdParam
	lRet := PrmCtbm300(StrZero(x,2))
	If !lRet
		x:=QtdParam
	EndIf
Next x

//Pergunta se confirma configuracoes dos parametros
If lRet .And. !lAuto
	lRet := CtbOk()
EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออออหออออออัออออออออออปฑฑ
ฑฑบPrograma  ณPrmCtbm300บAutor  ณ Felipe Aurelio de Meloบ Data ณ 17/11/08 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออออสออออออฯออออออออออนฑฑ
ฑฑบDescricao ณ Valida o preenchimento de cada parametro da pergunta cPerg บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Contabilidade Gerencial - Movimentacoes                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function PrmCtbm300(cNumPar)

Local lRet    := .T.
Local cTexto1 := {}
Local cTexto2 := {}

Do Case
//----------------------------------------------------------
	Case cNumPar == "01"
		If lRet .And. Empty(MV_PAR01)
			ShowHelpDlg(STR0029, {STR0059,STR0076},5,{STR0046,STR0037},5) //"NAOVAZIO"###"O parโmetro 'm้todo de c๓pia' nใo foi"###"preenchido."###"Favor preencher o parโmetro 'm้todo de"###"c๓pia' com uma das op็๕es disponํveis."   
			lRet := .F.
		EndIf
		If lRet .And. MV_PAR01 = 1
			MV_PAR02 := 1
		EndIf
		If lRet .And. MV_PAR01 = 2
			MV_PAR02 := 2
			MV_PAR05 := 1
			MV_PAR06 := 2
			MV_PAR07 := 2
		EndIf

//----------------------------------------------------------
	Case cNumPar == "02"
		If lRet .And. Empty(MV_PAR02)
			ShowHelpDlg(STR0029, {STR0065,STR0076},5,{STR0047,STR0078},5)//"NAOVAZIO"###"O parโmetro 'sele็ใo dos saldos' nใo foi"###"preenchido."###"Favor preencher o parโmetro 'sele็ใo dos"###"saldos' com uma das op็๕es disponํveis."   
			lRet := .F.
		EndIf
		If lRet .And. MV_PAR01 = 1 .And. MV_PAR02 = 2
			cTexto1:= {STR0032,STR0079,STR0033,STR0050} //"A informa็ใo preenchida no parโmetro"###"'sele็ใo dos saldos' nใo ้ compatํvel com"###"a informa็ใo preenchida no parโmetro"###"'m้todo de copia'."
			cTexto2:= {STR0075,STR0035,STR0071,STR0069} //"Por escolher no parโmetro 'm้todo de "###"copia' a op็ใo 'copia simples', no "###"parโmetro 'sele็ใo dos saldos' deverแ"###" optar por 'parโmetros'."
			ShowHelpDlg(STR0030,cTexto1,5,cTexto2,5)//"INCOMPATIVEL"   
			lRet := .F.
		EndIf
		If lRet .And. MV_PAR01 = 2 .And. MV_PAR02 = 1
			cTexto1:= {STR0032,STR0079,STR0033,STR0050} //"A informa็ใo preenchida no parโmetro"###"'sele็ใo dos saldos' nใo ้ compatํvel com"###"a informa็ใo preenchida no parโmetro"###"'m้todo de copia'."
			cTexto2:= {STR0075,STR0036,STR0071,STR0068} //"Por escolher no parโmetro 'm้todo de "###"copia' a op็ใo 'm๚ltiplos saldos', no "###"parโmetro 'sele็ใo dos saldos' deverแ"###"optar por 'movimentos multi saldos'."
			ShowHelpDlg(STR0030,cTexto1,5,cTexto2,5)//"INCOMPATIVEL"  
			lRet := .F.
		EndIf
		
//----------------------------------------------------------
	Case cNumPar == "03"
		If lRet .And. MV_PAR01 = 1 .And. Empty(MV_PAR03)
			ShowHelpDlg(STR0029, {STR0063,STR0076},5,{STR0077,STR0048,STR0070},5) //"NAOVAZIO"###"O parโmetro 'saldo origem' nใo foi","preenchido."###"Quando o parโmetro 'm้todo de c๓pia' estแ"###"marcado como 'c๓pia simples' este"###"parโmetro passa a ser obrigat๓rio."
			lRet := .F.
		EndIf

//----------------------------------------------------------
	Case cNumPar == "04"
		If lRet .And. MV_PAR01 = 1 .And. Empty(MV_PAR04)
			ShowHelpDlg(STR0029, {STR0064,STR0076},5,{STR0077,STR0048,STR0070},5) //"NAOVAZIO"###"O parโmetro 'saldos destinos' nใo foi"###"preenchido."###"Quando o parโmetro 'm้todo de c๓pia' estแ"###"marcado como 'c๓pia simples' este"###"parโmetro passa a ser obrigat๓rio."   
			lRet := .F.
		EndIf

//----------------------------------------------------------
	Case cNumPar == "07"
		If lRet .And. MV_PAR07 = 1 .And. MV_PAR16 = 1 
			ShowHelpDlg(STR0029, {STR0053,STR0110},5,{STR0045,STR0111,STR0073,STR0061,STR0041},5) //"NAOVAZIO"###"O parโmetro "###"hist๓rico padrใo nใo pode ser Mante"###"Favor preencher o parโmetro em questใo,"###" com o conteudo de especificar hist๓rico"###"pois o mesmo ้ obrigatorio quando"###"o parametro 'movimentos copiados'"###"esta marcado como 'sint้tico'."   
			lRet := .F.
		EndIf
		If lRet .And. MV_PAR01 = 1 .And. MV_PAR07 = 1 .And. Empty(MV_PAR17)
			ShowHelpDlg(STR0029, {STR0053,STR0034,STR0052},5,{STR0045,STR0073,STR0061,STR0041},5) //"NAOVAZIO"###"O parโmetro "###"'c๓digo de hist๓rico padrใo'"###" nใo foi preenchido."###"Favor preencher o parโmetro em questใo,"###"pois o mesmo ้ obrigatorio quando"###"o parametro 'movimentos copiados'"###"esta marcado como 'sint้tico'."   
			MV_PAR16 := 2
			lRet := .T.
		EndIf
//----------------------------------------------------------
	Case cNumPar == "06"
		If lRet .And. MV_PAR01 = 1 .And. MV_PAR06 = 3 .And.  MV_PAR16 == 2 .And. Empty(MV_PAR17)
			ShowHelpDlg(STR0029, {STR0053,STR0034,STR0052},5,{STR0045,STR0073,STR0061,STR0041},5) //"NAOVAZIO"###"O parโmetro "###"'c๓digo de hist๓rico padrใo'"###" nใo foi preenchido."###"Favor preencher o parโmetro em questใo,"###"pois o mesmo ้ obrigatorio quando"###"o parametro 'movimentos copiados'"###"esta marcado como 'sint้tico'."   
			lRet := .F.
		EndIf
				
//----------------------------------------------------------
	Case cNumPar == "09"
		If lRet .And. Empty(MV_PAR09)
			ShowHelpDlg(STR0029, {STR0055,STR0076},5,{STR0045,STR0074},5) //"NAOVAZIO"###"O parโmetro 'data inicial' nใo foi"###"preenchido."###"Favor preencher o parโmetro em questใo,"###"pois o mesmo ้ obrigatorio."   
			lRet := .F.
		EndIf

//----------------------------------------------------------
	Case cNumPar == "10"
		If lRet .And. Empty(MV_PAR10)
			ShowHelpDlg(STR0029, {STR0054,STR0076},5,{STR0045,STR0074},5) //"NAOVAZIO"###"O parโmetro 'data final' nใo foi","preenchido."###"Favor preencher o parโmetro em questใo,"###"pois o mesmo ้ obrigatorio."
			lRet := .F.
		EndIf

//----------------------------------------------------------
	Case cNumPar == "12"
		If lRet .And. MV_PAR11 = 2 .And. Empty(MV_PAR12)
			ShowHelpDlg(STR0029, {STR0062,STR0076},5,{STR0045,STR0073,STR0060,STR0039},5)//"NAOVAZIO"###"O parโmetro 'qual moeda' nใo foi","preenchido."###"Favor preencher o parโmetro em questใo,"###"pois o mesmo ้ obrigatorio quando"###"o parametro 'moeda' esta marcado como"###"'especificar'."   
			lRet := .F.
		EndIf
		If lRet .And. !Empty(MV_PAR12)
			CTO->(DbSetOrder(1))
			If CTO->(!DbSeek(xFilial("CTO")+MV_PAR12))
				ShowHelpDlg(STR0031, {STR0067},5,{STR0043},5) //"NAOEXISTE"###"O registro escolhido nใo existe."###"Favor escolher um registro existente."
				lRet := .F.
			EndIf
		EndIf

//----------------------------------------------------------
	Case cNumPar == "14"
		If lRet .And. MV_PAR13 = 2 .And. Empty(MV_PAR14)
			ShowHelpDlg(STR0029, {STR0057,STR0052},5,{STR0045,STR0073,STR0058,STR0040},5)//"NAOVAZIO"###"O parโmetro 'lote contแbil'"###"nใo foi preenchido."###"Favor preencher o parโmetro em questใo,"###"pois o mesmo ้ obrigatorio quando"###"o parametro 'lote e sub-lote contแbil'"###"esta marcado como 'especificar'."   
			lRet := .F.
		EndIf

//----------------------------------------------------------
	Case cNumPar == "15"
		If lRet .And. MV_PAR13 = 2 .And. Empty(MV_PAR15)
			ShowHelpDlg(STR0029, {STR0066,STR0052},5,{STR0045,STR0073,STR0058,STR0040},5)//"NAOVAZIO"###"O parโmetro 'sub-lote contแbil'"###" nใo foi preenchido."###"Favor preencher o parโmetro em questใo,"###"pois o mesmo ้ obrigatorio quando"###"o parametro 'lote e sub-lote contแbil'"###"esta marcado como 'especificar'."   
			lRet := .F.
		EndIf

//----------------------------------------------------------
	Case cNumPar == "17"
		If lRet .And. MV_PAR16 = 2 .And. Empty(MV_PAR17)
			ShowHelpDlg(STR0029, {STR0053,STR0034,STR0052},5,{STR0045,STR0073,STR0056,STR0040},5)//"NAOVAZIO"###"O parโmetro "###"'c๓digo de hist๓rico padrใo'"###" nใo foi preenchido."###"Favor preencher o parโmetro em questใo,"###"pois o mesmo ้ obrigatorio quando"###"o parametro 'hist๓rico padrใo'"###"esta marcado como 'especificar'."   
			lRet := .F.
		EndIf
		If lRet .And. !Empty(MV_PAR17)
			CT8->(DbSetOrder(1))
			If CT8->(!DbSeek(xFilial("CT8")+MV_PAR17))
				ShowHelpDlg(STR0031, {STR0067},5,{STR0043},5) //"NAOEXISTE"###"O registro escolhido nใo existe."###"Favor escolher um registro existente."
				lRet := .F.
			EndIf
		EndIf
		If lRet .And. MV_PAR01 = 1 .And. MV_PAR07 = 1 .And. Empty(MV_PAR17)
			ShowHelpDlg(STR0029, {STR0053,STR0034,STR0052},5,{STR0045,STR0073,STR0061,STR0041},5)//"NAOVAZIO"###"O parโmetro "###"'c๓digo de hist๓rico padrใo'"###" nใo foi preenchido."###"Favor preencher o parโmetro em questใo,"###"pois o mesmo ้ obrigatorio quando"###"o parametro 'movimentos copiados'"###"esta marcado como 'sint้tico'."   
			MV_PAR16 := 2
			lRet := .F.
		EndIf
//----------------------------------------------------------
EndCase

Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัอออออออออออออออออออออออหออออัออออออออปฑฑ
ฑฑบPrograma  ณ ApagaCtbm300 บ Autor ณ Gustavo Henrique      บDataณ28/12/06บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯอออออออออออออออออออออออสออออฯออออออออนฑฑ
ฑฑบDescricao ณ Exclui os lancamnetos da tabela CT2                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ EXPD1 - Data inicial para exclusao dos lancamentos         บฑฑ
ฑฑบ          ณ EXPD2 - Data final para exclusao dos lancamentos           บฑฑ
ฑฑบ          ณ EXPC3 - Tipo de saldo de destino para selecao dos lanctos. บฑฑ
ฑฑบ          ณ EXPC4 - Indica se processa todas as moedas ou especifica   บฑฑ
ฑฑบ          ณ EXPC5 - Moeda informada para selecao dos lancamentos       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Contabilidade Gerencial                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ApagaCtbm300( dDataIni as Date, dDataFim as Date, cTpSldOri as Character, cTpSldDes as Character, cMoeda as Character, lTodas as Logical ) as Logical
         
Local lRet			as Logical        

Default dDataIni	:= cTod('') 
Default dDataFim    := cTod('')
Default cTpSldOri	:= "" 
Default cTpSldDes	:= "" 
Default cMoeda		:= "" 
Default lTodas		:= .F.
Default lProcedure  := .F.

lRet  := .T.    

Processa( { || lRet := SelLancCtbm300( dDataIni, dDataFim, cTpSldDes, cMoeda, lTodas ) },, STR0025 ) //"Selecionando lan็amentos para exclusใo..."

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหออออออัออออออออออออออออออออหออออออัออออออออออปฑฑ
ฑฑบPrograma  ณSelLancCtbm300บAutor ณ Gustavo Henrique   บ Data ณ 28/12/06 บฑฑ
ฑฑฬออออออออออุออออออออออออออสออออออฯออออออออออออออออออออสออออออฯออออออออออนฑฑ
ฑฑบDescricao ณ Seleciona os numeros de RECNO dos lancamentos contabeis no บฑฑ
ฑฑบ          ณ tipo de saldo de origem, para gravacao posterior no tipo   บฑฑ
ฑฑบ          ณ de saldo de destino selecionado nos parametros.            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ EXPD1 - Data inicial do periodo para selecao dos lanctos.  บฑฑ
ฑฑบ          ณ EXPD2 - Data final do periodo para selecao dos lanctos.    บฑฑ
ฑฑบ          ณ EXPC3 - Tipo de saldo de origem para selecao dos lanctos.  บฑฑ
ฑฑบ          ณ EXPC4 - Moeda especifica caso informado "Especifico" no    บฑฑ
ฑฑบ          ณ         parametro "Qual Moeda"                             บฑฑ
ฑฑบ          ณ EXPC5 - Indica se devem ser selecionadas todas as moedas   บฑฑ
ฑฑบ          ณ         ou apenas uma moeda especifica.                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Contabilidade Gerencial                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function SelLancCtbm300( dDataIni as Date, dDataFim as Date, cTpSald as Character, cMoeda as Character, lTodas as Logical) as Logical
          
Local aArea		as Array    
Local aRecExcl  as Array    
Local aIDThread as Array

Local cFilCT2	as Character
Local cDataIni	as Character
Local cDataFim	as Character
Local cQuery	as Character
Local cThreadID as Character
Local cAliasTrb as Character

Local nCont		as Numeric
Local nI        as Numeric
Local nNroThrds as Numeric

Local lGrava	as Logical
Local lRet		as Logical
Local oQryExec	as Object
Local nQry		as numeric

Default dDataIni	:= cTod('')
Default dDataFim 	:= cTod('')
Default cTpSald		:= ""
Default cMoeda		:= "" 
Default lTodas		:= .F.

aArea			:= GetArea()                      
cFilCT2			:= xFilial("CT2")
cDataIni		:= DtoS(dDataIni)
cDataFim		:= DtoS(dDataFim)
cQuery			:= ""
nCont			:= 0
lGrava			:= .T.
lRet			:= .F.
aRecExcl        := {}
aIDThread       := {}
oQryExec    	:= Nil
nNroThrds       := SuperGetMV("MV_CM300TH",.F.,5)
nQry			:= 1

cQuery := "SELECT CT2_TPSALD, CT2_MOEDLC, R_E_C_N_O_ REC"
cQuery += "  FROM " + RetSqlName("CT2") + " " 
cQuery += " WHERE CT2_FILIAL = ? " 
cQuery += " AND CT2_DATA BETWEEN ? AND ? " 

If _lMVLotDoc
	cQuery += " AND CT2_LOTE   BETWEEN ? AND ? " 
	cQuery += " AND CT2_SBLOTE BETWEEN ? AND ? " 
	cQuery += " AND CT2_DOC    BETWEEN ? AND ? " 
EndIf

If Len( Alltrim(cTpSald)) == 1
	cQuery += "   AND CT2_TPSALD = ? " 
Endif

cQuery += " AND CT2_CTLSLD <> ? " 
cQuery += " AND D_E_L_E_T_ = ? " 

cQuery := ChangeQuery(cQuery)
oQryExec := FWExecStatement():New(cQuery)

oQryExec:SetString(nQry++,cFilCT2)
oQryExec:SetString(nQry++,cDataIni)
oQryExec:SetString(nQry++,cDataFim)
If _lMVLotDoc
	oQryExec:SetString(nQry++,cLoteDe)
	oQryExec:SetString(nQry++,cLoteAte)
	oQryExec:SetString(nQry++,cSbLoteDe)
	oQryExec:SetString(nQry++,cSbLoteAte)
	oQryExec:SetString(nQry++,cDocDe)
	oQryExec:SetString(nQry++,cDocAte)
EndIf

If Len( Alltrim(cTpSald)) == 1
	oQryExec:SetString(nQry++,Alltrim( cTpSald ))
EndIf

oQryExec:SetString(nQry++, '0')
oQryExec:SetString(nQry++, Space(1))

cAliasTrb := oQryExec:OpenAlias(GetNextAlias())
dbSelectArea(cAliasTrb)

Count To nCont
ProcRegua( nCont )
lRet := (nCont > 0)

If nNroThrds > 10
	nNroThrds := 10
EndIf

If lRet 
	//Se a quantidade for menor do que 10.000 por thread, recalculo o nro de threads
	If nCont < (nNroThrds*10000)
		nNroThrds := Int(nCont/10000)		
	EndIf

	//Somo 1 para que a ๚ltima thread nใo fique com uma carga muito pequena
	nMaxRegThread := Int(nCont/IIf(nNroThrds==0,1,nNroThrds))+1 
	
	nCont := 0

	(cAliasTrb) ->(dbGoTop())													
	While (cAliasTrb)->(!EoF())	
		IncProc()    
		nCont ++    
		
		If (cAliasTrb)->CT2_TPSALD $ cTpSald
			If !lTodas   
				If cMoeda == "01"
					lGrava := ((cAliasTrb)->CT2_MOEDLC == cMoeda)
				Else
					lGrava := (cAliasTrb)->( (CT2_MOEDLC == cMoeda .Or. CT2_MOEDLC == "01") )
				EndIf	
			EndIf		
		EndIf	

		If lGrava
			aAdd(aRecExcl, (cAliasTrb)->REC)			
		EndIf 

		If nCont >= nMaxRegThread
			cThreadID := FWUUIDV4()
			aAdd(aIDThread, cThreadID)		
			aRecJob := aClone(aRecExcl)
			StartJob("CTBDELCT2",GetEnvServer(),.F.,cEmpAnt,cFilAnt,aRecJob,cThreadID)
			aRecExcl := {}
			nCont := 0
		EndIf		

		(cAliasTrb)->( dbSkip() )
	EndDo
	(cAliasTrb)->(dbCloseArea())

	If nCont >= 0
		aRecJob := aClone(aRecExcl)
		//lWait = .T. - Seguro a ๚ltima thread para aguarda a dele็ใo de todos os itens
		StartJob("CTBDELCT2",GetEnvServer(),.T.,cEmpAnt,cFilAnt,aRecJob)		
	EndIf	
EndIf

//Verifico se todas as threads jแ terminaram
For nI := 1 to Len(aIDThread)
	While !LockByName(aIDThread[nI],.T.,.T.)		
	EndDo
Next nI

RestArea( aArea )
oQryExec:Destroy()
oQryExec := Nil

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ CTM300Proc บ Autor ณ Gustavo Henrique บ Data ณ  15/01/07   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Gera lancamentos contabeis no tipo de saldo de destino a   บฑฑ
ฑฑบ          ณ partir dos movimentos ou saldos no tipo de saldo de origem บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ EXPL1 - Indica se o processamento eh analitico (de CT2 paraบฑฑ
ฑฑบ          ณ CT2) ou sintetico (de CT7,CQ3,CQ5 ou CQ7) para CT2.        บฑฑ
ฑฑบ          ณ EXPL2 - Indica se deve processar saldo ou movimento.       บฑฑ
ฑฑบ          ณ EXPL3 - Indica se processa todas as moedas ou especifica.  บฑฑ
ฑฑบ          ณ EXPN4 - A partir de que nivel deve compor os lancamentos.  บฑฑ
ฑฑบ          ณ Utilizado apenas para processamento sintetico.             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Contabilidade Gerencial                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CTM300Proc( lAnalitico as Logical, lSaldo as Logical, lTodas as Logical, nNivel as Numeric ) as Logical
                                    
Local aArea		as Array
Local aAreaCT2	as Array
Local aAreaCQ1	as Array
Local aCtaProc	as Array
Local aCampos	as Array               
Local aStruct	as Array
Local aTamVlr	as Array

Local cArqTrb	as Character
Local cArqInd1	as Character
Local cArqInd2	as Character
Local cMsgProc	as Character

Local lClVl		as Logical
Local lItem		as Logical
Local lCusto	as Logical
Local lRet		as Logical
Local cFieldUID as Character

aArea		:= GetArea()
aAreaCT2	:= CT2->( GetArea() )
aAreaCQ1	:= CQ1->( GetArea() )
aCtaProc	:= {}
aCampos	    := {}                  
aStruct	    := {} 
aTamVlr	    := TamSX3("CQ1_DEBITO")

cArqTrb	    := ""
cArqInd1	:= ""
cArqInd2	:= ""
cMsgProc	:= ""   

lClVl		:= CtbMovSaldo("CTH")
lItem		:= CtbMovSaldo("CTD")
lCusto		:= CtbMovSaldo("CTT")
lRet		:= .T.
cFieldUID 	:= CtbCpoUID("CT2")

If lAnalitico

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Executa selecao e gravacao dos movimentos analiticos (CT2 para CT2)					  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	AAdd( aStruct, { "NUMREC", "N", 17, 0 }  )
	AAdd( aStruct, { "RECTRB", "N", 17, 0 }  )

	If _oCtbm3002 <> Nil
		_oCtbm3002:Delete()
		_oCtbm3002 := Nil
	Endif
	
	_oCtbm3002 := FWTemporaryTable():New( "TRB" )  
	_oCtbm3002:SetFields(aStruct) 
	_oCtbm3002:AddIndex("1", {"RECTRB"})
				
	//------------------
	//Cria็ใo da tabela temporaria
	//------------------
	_oCtbm3002:Create()

	Processa( { || lRet := CTM300SelLanc( mv_par09, mv_par10, mv_par03, mv_par12, lTodas) },, STR0020 )
	If lRet
		Processa( { || CTM300GrvLanc( lTodas, mv_par12 ) },, STR0021 )	// "Gravando lan็amentos no tipo de saldo destino..."
	EndIf	
	dbSelectArea( "CT2" )
	TRB->( dbCloseArea() )

	If _oCtbm3002 <> Nil
		_oCtbm3002:Delete()
		_oCtbm3002 := Nil
	Endif

Else	// Sinteticos

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Executa selecao e gravacao dos saldos e/ou movimentos sinteticos (CQ1, CQ3, CQ5, CQ7) ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	aCampos := {{"IDENT"    ,"C", 3, 0},;
               {"CONTA"    ,"C",Len(CriaVar("CT1_CONTA")),0},;
               {"CUSTO"    ,"C",Len(CriaVar("CTT_CUSTO")),0},;
               {"ITEM"     ,"C",Len(CriaVar("CTD_ITEM")),0},;
               {"CLVL"     ,"C",Len(CriavAr("CTH_CLVL")),0},;
               {"CREDIT"   ,"N",aTamVlr[1],aTamVlr[2]},;
               {"DEBITO"   ,"N",aTamVlr[1],aTamVlr[2]},;
               {"TPSALDO"  ,"C",1,0},;
               {"MOEDA"    ,"C",2,0}}

	If _oCtbm3002 <> Nil
		_oCtbm3002:Delete()
		_oCtbm3002 := Nil
	Endif
	
	_oCtbm3002 := FWTemporaryTable():New( "TRB" )  
	_oCtbm3002:SetFields(aCampos) 
	_oCtbm3002:AddIndex("1", {"TPSALDO","MOEDA","CONTA","CUSTO","ITEM","CLVL","IDENT"})
	_oCtbm3002:AddIndex("2", {"TPSALDO","MOEDA","IDENT","CONTA","CUSTO","ITEM","CLVL"})
				
	//------------------
	//Cria็ใo da tabela temporaria
	//------------------
	_oCtbm3002:Create()
    
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Gera lancamentos temporarios no tipo de saldo de origem e no nivel selecionado ณ
	//ณ na pergunta "Ate o nivel?". 1=Conta; 2=C.Custo; 3=Item; 4=Classe               ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If lClVl .And. nNivel == 4
		cMsgProc := STR0011 + RTrim(CtbSayApro("CTH")) + " ..."	// Selecionando saldos por Classe
		Processa( { ||	CTM300SelSint( lSaldo, "CQ7", mv_par09, mv_par10, mv_par12, mv_par03, lCusto, lItem, lClvl, lTodas, nNivel ) },, cMsgProc )
	EndIf
	
	If lItem .And. nNivel >= 3	
		cMsgProc := STR0011 + RTrim(CtbSayApro("CTD")) + " ..."	// Selecionando saldos por Item
		Processa( { || CTM300SelSint( lSaldo, "CQ5", mv_par09, mv_par10, mv_par12, mv_par03, lCusto, lItem, lClvl, lTodas, nNivel ) },, cMsgProc )
	EndIf
	
	If lCusto .And. nNivel >= 2	
		cMsgProc := STR0011 + RTrim(CtbSayApro("CTT")) + " ..." 	// Selecionando saldos por C.Custo ...
		Processa( { || CTM300SelSint( lSaldo, "CQ3", mv_par09, mv_par10, mv_par12, mv_par03, lCusto, lItem, lClvl, lTodas, nNivel ) },, cMsgProc )
	EndIf
	
	cMsgProc := STR0011 + STR0023 + " ..."	// Selecionando saldos por Conta ...
	Processa( { || CTM300SelSint( lSaldo, "CQ1", mv_par09, mv_par10, mv_par12, mv_par03, lCusto, lItem, lClvl, lTodas, nNivel ) },, cMsgProc )	
                     
	TRB->( dbGoTop() )
	lRet := TRB->( !EoF() )
	
	If lRet

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Calcula a data para gravacao dos lancamentos na tabela CT2                     ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If lSaldo
			dDataLanc := mv_par09 - 1	// Dia anterior a data inicial informada 
		Else
			dDataLanc := mv_par10		// Data final do periodo informado
		EndIf		

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Gera lancamentos contabeis no tipo de saldo de destino                         ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		Processa( { || CTM300GrvSint( dDataLanc, mv_par14, mv_par15, mv_par12, mv_par04, mv_par17 ) },, STR0021 )	// Gravando lan็amentos no tipo de saldo destino...	
		
	EndIf	

	dbSelectArea("TRB")
	dbCloseArea()

	If _oCtbm3002 <> Nil
		_oCtbm3002:Delete()
		_oCtbm3002 := Nil
	Endif

	dbSelectArea("CT2")

EndIf

RestArea( aArea )
RestArea( aAreaCT2 )
RestArea( aAreaCQ1 )

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหออออออัออออออออออออออออออออหออออออัออออออออออปฑฑ
ฑฑบPrograma  ณCTBM300SelLancบAutor ณ Gustavo Henrique   บ Data ณ 28/12/06 บฑฑ
ฑฑฬออออออออออุออออออออออออออสออออออฯออออออออออออออออออออสออออออฯออออออออออนฑฑ
ฑฑบDescricao ณ Seleciona os numeros de RECNO dos lancamentos contabeis no บฑฑ
ฑฑบ          ณ tipo de saldo de origem, para gravacao posterior no tipo   บฑฑ
ฑฑบ          ณ de saldo de destino selecionado nos parametros.            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ EXPD1 - Data inicial do periodo para selecao dos lanctos.  บฑฑ
ฑฑบ          ณ EXPD2 - Data final do periodo para selecao dos lanctos.    บฑฑ
ฑฑบ          ณ EXPC3 - Tipo de saldo de origem para selecao dos lanctos.  บฑฑ
ฑฑบ          ณ EXPC4 - Moeda especifica caso informado "Especifico" no    บฑฑ
ฑฑบ          ณ         parametro "Qual Moeda"                             บฑฑ
ฑฑบ          ณ EXPC5 - Indica se devem ser selecionadas todas as moedas   บฑฑ
ฑฑบ          ณ         ou apenas uma moeda especifica.                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Contabilidade Gerencial                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CTM300SelLanc( dDataIni as Date, dDataFim as Date, cTpSald as Character, cMoeda as Character, lTodas as Logical ) as Logical
          
Local aArea		as Array
                      
Local cFilCT2	as Character
Local cDataIni	as Character
Local cDataFim	as Character
Local cQuery	as Character

Local nCont		as Numeric

Local lGrava	as Logical
Local lPosMoeda	as Logical
Local lRetLanc	as Logical
Local _oQryCT2  as Object
Local nQry		as Numeric 
Local bCondic	as codeBlock

Default dDataIni := cTod('') 
Default dDataFim := cTod('') 
Default cTpSald	 := "" 
Default cMoeda 	 := "" 
Default lTodas	 := .F.
                                                                                                   
If _lMVLotDoc
	bCondic 	:= { ||	CT2->CT2_LOTE >= cLoteDe .and. CT2->CT2_LOTE <= cLoteAte .and. 	CT2->CT2_SBLOTE >= cSbLoteDe .and. CT2->CT2_SBLOTE <= cSbLoteAte .and. CT2->CT2_DOC >= cDocDe .and. CT2->CT2_DOC <= cDocAte   } 
Else
	bCondic 	:= { ||	.T. }   	
EndIf	
aArea		:= GetArea()
                      
cFilCT2		:= xFilial("CT2")
cDataIni	:= DtoS(dDataIni)
cDataFim	:= DtoS(dDataFim)
cQuery		:= ""
_oQryCT2    := Nil
nQry		:= 1

nCont		:= 0

lGrava		:= .T.
lPosMoeda	:= TRB->( FieldPos("MOEDLC") ) > 0
lRetLanc	:= .F.

cQuery := "SELECT COUNT(R_E_C_N_O_) TOTREC "
cQuery += "FROM " + RetSqlName("CT2") + " " 
cQuery += "WHERE "
cQuery += "    CT2_FILIAL = ? "
cQuery += "AND CT2_DATA BETWEEN ? AND ? "
If _lMVLotDoc
	cQuery += " AND CT2_LOTE   BETWEEN ?  AND  ? "
	cQuery += " AND CT2_SBLOTE BETWEEN ?  AND  ? "
	cQuery += " AND CT2_DOC    BETWEEN ?  AND  ? "	
Endif
cQuery += " AND D_E_L_E_T_ = ? "
cQuery := ChangeQuery(cQuery)

_oQryCT2 := FWExecStatement():New(cQuery)

_oQryCT2:SetString(nQry++,cFilCT2)
_oQryCT2:SetString(nQry++,cDataIni)
_oQryCT2:SetString(nQry++,cDataFim)
If _lMVLotDoc
	_oQryCT2:SetString(nQry++,cLoteDe)
	_oQryCT2:SetString(nQry++,cLoteAte)

	_oQryCT2:SetString(nQry++,cSbLoteDe)
	_oQryCT2:SetString(nQry++,cSbLoteAte)

	_oQryCT2:SetString(nQry++,cDocDe)
	_oQryCT2:SetString(nQry++,cDocAte)	
EndIf
_oQryCT2:SetString(nQry++, Space(1))

nCont	:= _oQryCT2:ExecScalar('TOTREC') 

dbSelectArea("CT2")
CT2->( dbSetOrder( 1 ) )
                          
ProcRegua( nCont )

CT2->( MsSeek( cFilCT2 + cDataIni, .T. ) )

Do While CT2->( !EoF() .And. CT2_FILIAL == cFilCT2 .And. DtoS(CT2_DATA) <= cDataFim )
	IncProc()
	If CT2->CT2_TPSALD $ cTpSald .and. Eval(bCondic)
		If !lTodas   
			If cMoeda == "01"
				lGrava := (CT2->CT2_MOEDLC == cMoeda)
			Else
				lGrava := CT2->( (CT2_MOEDLC == cMoeda .Or. CT2_MOEDLC == "01") )
			EndIf	
		EndIf
		If lGrava
			RecLock( "TRB", .T. )
			TRB->NUMREC := CT2->( Recno() )
			TRB->RECTRB := TRB->( Recno() )

			If lPosMoeda
				TRB->MOEDLC := CT2->CT2_MOEDLC
			EndIf	
			TRB->( MsUnlock() )
		EndIf	
	EndIf	
	CT2->( dbSkip() )
EndDo
              
TRB->( dbGoTop() )

lRetLanc := TRB->(!EoF())

RestArea( aArea )
_oQryCT2:Destroy()
_oQryCT2 := Nil

Return lRetLanc

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหออออออัออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณCTBM300GrvLancบAutor ณ Gustavo Henrique บ Data ณ 28/12/06   บฑฑ
ฑฑฬออออออออออุออออออออออออออสออออออฯออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDescricao ณ Grava lancamentos analiticos a partir dos registros que jahบฑฑ
ฑฑบ          ณ foram gravados em arquivo temporario.                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ EXPL1 - Indica se deve processar todas as moedas           บฑฑ
ฑฑบ          ณ EXPC2 - Caso moeda especifica, recebe a moeda informada nosบฑฑ
ฑฑบ          ณ         parametros.                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Contabilidade Gerencial                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CTM300GrvLanc( lTodas as Logical, cMoeda as Character)

Local nX		 	as Numeric
Local nInc			as Numeric
Local nCpos			as Numeric
Local CTF_LOCK		as Numeric
Local nPosLinha		as Numeric
Local nPosLote		as Numeric
Local nPosSLote		as Numeric
Local nPosDoc		as Numeric
Local nPosTPSal		as Numeric
Local nPosCtSal		as Numeric
Local cLote			as Character
Local cSubLote		as Character
Local cDoc			as Character
Local cDocOri		as Character
Local cLoteOri		as Character
Local cDataOri		as Character
Local cTpSldOri		as Character
Local cMtSldOri		as Character
Local lSemValor		as Logical
Local cHistPadr		as Character
Local aDadosCT2		as Array
Local aTpSaldos		as Array
Local lMltSaldos	as Logical
Local lFirst 		as Logical
Local nLinha 		as Numeric
Local cLinha 		as Character
Local cLinIncl 		as Character
Local dDtLanc		as Date
Local nMaxLinha		as Numeric
Local cUltLanc 		as Character
Local cTpSalDest 	as Character

Local nPosHP		as Numeric
Local nPosHist		as Numeric	

Local nPosValor		as Numeric
Local nPosRecno		as Numeric
Local cQryUpd       as Character
Local cStatAtu		as Character

Default lTodas	 	:= .F. 
Default cMoeda		:= ""

nX		 		:= 0
nInc			:= 0
nCpos			:= CT2->(FCount())
CTF_LOCK		:= 0
cLote			:= ""
cSubLote		:= ""
cDoc			:= ""
cDocOri			:= ""
cLoteOri		:= ""
cDataOri		:= ""
cTpSldOri		:= ""
cMtSldOri		:= ""
lSemValor		:= (!lTodas .And. cMoeda <> "01")
cHistPadr		:= IIf(MV_PAR16=1,"",MV_PAR17)
aTpSaldos		:= {}
lFirst 			:= .T.
nLinha 			:= 1
cLinha 			:= StrZero(nLinha,3)
cLinIncl 		:= cLinha
dDtLanc			:= StoD("")
nMaxLinha		:= IIf(SuperGetMV("MV_NUMLIN")<1,999,CtbLinMax(SuperGetMv("MV_NUMLIN")))
cUltLanc 		:= ""
cTpSalDest 		:= alltrim(strtran(MV_PAR04,';'))
cQryUpd			:= ""

aDadosCT2 := Array(nCpos)
		
nPosHP     := CT2->( FieldPos( "CT2_HP" ) )
nPosHist   := CT2->( FieldPos( "CT2_HIST" ) )
nPosLinha  := CT2->( FieldPos( "CT2_LINHA" ) )
nPosLote   := CT2->( FieldPos( "CT2_LOTE" ) )
nPosSLote  := CT2->( FieldPos( "CT2_SBLOTE" ) )
nPosDoc    := CT2->( FieldPos( "CT2_DOC" ) )
nPosTPSal  := CT2->( FieldPos( "CT2_TPSALD" ) )
nPosValor  := CT2->( FieldPos( "CT2_VALOR" ) )
nPosCtSal  := CT2->( FieldPos( "CT2_CTLSLD" ) )
nPosRecno  := CT2->( FieldPos( "R_E_C_N_O_" ) )

lMltSaldos := MV_PAR01==2

//DbSelectArea( "CT2" )
//DbGoTop()

DbSelectArea( "TRB" )
ProcRegua( TRB->(LastRec()))
		
TRB->( dbGoTop() )                          
	    
Do While TRB->(!EoF())

	IncProc()                  
	// Volta ao registro de origem 		        
    CT2->( dbGoTo( TRB->NUMREC ) )

    cStatAtu := CT2->CT2_CTLSLD

    If MV_PAR18 == 1 .OR. MV_PAR05 == 2
		//Realizado Update para nใo alterar USERGA via Reclock
		cQryUpd := "UPDATE "+RetSQLName("CT2")+" SET CT2_CTLSLD = '0'"
		cQryUpd += " WHERE CT2_FILIAL = '"+xFilial("CT2")+"'"
		cQryUpd += " AND R_E_C_N_O_   = "+cValtochar(CT2->(Recno()))+" "
		cQryUpd += " AND D_E_L_E_T_   = ' '"

		IIF(TcSqlExec(cQryUpd) == 0,"" , Conout(TCSqlError()))	
		cStatAtu:= "0"
    EndIf

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณse o parametro (Multiplos Tipos de Saldos) for igual a desconsidera   ณ
	//ณentao deve seguir o fluxo normal.                                     ณ
	//ณ                                                                      ณ
	//ณse controla deve copiar para todos os tipos de saldos escolhidos.     ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If MV_PAR01 == 1

		cTpSldOri := AllTrim(CT2->CT2_TPSALD) //Variavel criada para comparar com registro a ser criado
		cMtSldOri := AllTrim(StrTran(StrTran(CT2->CT2_MLTSLD,";",""),cTpSldOri,"")) //Variavel criada para tratar um possivel erro

		If (( cStatAtu == "0") .Or. Empty( cStatAtu) ) .And. Empty(cMtSldOri)

			cQryUpd := "UPDATE "+RetSQLName("CT2")+" SET CT2_CTLSLD = '2'"
			cQryUpd += " WHERE CT2_FILIAL = '"+xFilial("CT2")+"'"
			cQryUpd += " AND R_E_C_N_O_   = "+cValtochar(CT2->(Recno()))+" "
			cQryUpd += " AND D_E_L_E_T_   = ' '"

			IIF(TcSqlExec(cQryUpd) == 0,"" , Conout(TCSqlError()))	
			cStatAtu:= "2"

			If cDataOri+cDocOri+cLoteOri != CT2->(DtoS(CT2_DATA)+CT2_DOC+CT2_LOTE) .Or. nLinha > nMaxLinha
				// Atualiza numeracao de lote, sub-lote e documento
				If MV_PAR13 = 1
					cLote    := CT2->CT2_LOTE
					cSubLote := CT2->CT2_SBLOTE
				Else
					cLote		:= IIf(Empty(cLote)   ,mv_par14,cLote)
					cSubLote	:= IIf(Empty(cSubLote),mv_par15,cSubLote)
				EndIf
				cDataOri:= DtoS(CT2->CT2_DATA)
				cDocOri := CT2->CT2_DOC
				cLoteOri:= CT2->CT2_LOTE

				cDoc    := CT2->CT2_DOC
				dDtLanc := CT2->CT2_DATA
				lFirst  := .T.
			EndIf

			//tratamento para NรO gerar CT2 com saldo 0
			cTpSalDest := alltrim(strtran(cTpSalDest,'0')) 
			For nInc := 1 To Len(cTpSalDest)
				If SubStr(cTpSalDest,nInc,1) == AllTrim(cTpSldOri)
					Loop
				EndIf
				
				If lFirst .Or. nLinha > nMaxLinha
					CTM300ProxDoc(dDtLanc,cLote,cSubLote,@cDoc,@CTF_LOCK)
					If MV_PAR13 = 1
						cLote    := IIf(Empty(cLote)   ,Soma1(Space(TamSx3("CT2_LOTE")[1]))  ,cLote)    //CT2->CT2_LOTE
						cSubLote := IIf(Empty(cSubLote),Soma1(Space(TamSx3("CT2_SBLOTE")[1])),cSubLote) //CT2->CT2_SBLOTE
					Else
						cLote		:= IIf(Empty(cLote)   ,mv_par14,cLote)
						cSubLote	:= IIf(Empty(cSubLote),mv_par15,cSubLote)
					EndIf
					lFirst := .F.
					nLinha := 1
					cLinha := StrZero(nLinha,3)
				Else
					If cUltLanc != CT2->(CT2_FILIAL+DTOS(CT2_DATA)+CT2_LOTE+CT2_SBLOTE+CT2_DOC+CT2_LINHA+CT2_EMPORI+CT2_FILORI)
						nLinha ++
						cLinha := Soma1(cLinIncl)
					EndIf	
				EndIf

				// Copia os campos padrao da tabela de lancamentos contabeis (CT2)
				For nX := 1 To nCpos
					If nX <> nPosTpSal
						If CT2->(FieldPos('CT2_USERGI')) # nX .And. CT2->(FieldPos('CT2_USERGA')) # nX
							aDadosCT2[nX] := CT2->(FieldGet(nX))
						EndIf
					EndIf
				Next nX
				
				aDadosCT2[nPosLote]  := cLote
				aDadosCT2[nPosSLote] := cSubLote
				aDadosCT2[nPosDoc]   := cDoc
				aDadosCT2[nPosTPSal] := SubStr(cTpSalDest,nInc,1)
				aDadosCT2[nPosCtSal] := "2"							// Geracao Off-Line - Controle de Copia
				aDadosCT2[nPosLinha] := cLinha
				
				If !Empty(cHistPadr)
					aDadosCT2[nPosHP]  := cHistPadr
					aDadosCT2[nPosHist] := Posicione("CT8",1,xFilial("CT8")+cHistPadr,"CT8_DESC")
				EndIf
				
				If lSemValor .And. CT2->CT2_MOEDLC == "01"
					aDadosCT2[nPosValor] := 0
				EndIf

	            //deve ser armazenado antes de gravar o registro no CT2 pois se refere ao registro de origem da copia
				cUltLanc := CT2->(CT2_FILIAL+DTOS(CT2_DATA)+CT2_LOTE+CT2_SBLOTE+CT2_DOC+CT2_LINHA+CT2_EMPORI+CT2_FILORI)
								
				// Cria novo registro na tabela CT2 e grava os dados do lancamento de origem
				RecLock( "CT2", .T. )
				For nX := 1 To nCpos
					If CT2->(FieldPos('CT2_USERGI')) # nX .And. CT2->(FieldPos('CT2_USERGA')) # nX
						CT2->( FieldPut( nX, aDadosCT2[nX] ) )
					EndIf
				Next nX
				CT2->( MsUnlock() )
				
				cLinIncl := CT2->CT2_LINHA
			Next nInc
		EndIf
		
	ElseIf lMltSaldos
		
		aTpSaldos := CTM300GetTpSaldos( CT2->CT2_MLTSLD, ";" )
		cTpSldOri := CT2->CT2_TPSALD //Variavel criada para comparar com registro a ser criado
		cMtSldOri := AllTrim(StrTran(StrTran(CT2->CT2_MLTSLD,";",""),cTpSldOri,"")) //Variavel criada para tratar um possivel erro

		If ( cStatAtu == "0" .Or. Empty(cStatAtu) ) .And. !Empty(cMtSldOri)

			cQryUpd := "UPDATE "+RetSQLName("CT2")+" SET CT2_CTLSLD = '2'"
			cQryUpd += " WHERE CT2_FILIAL = '"+xFilial("CT2")+"'"
			cQryUpd += " AND R_E_C_N_O_   = "+cValtochar(CT2->(Recno()))+" "
			cQryUpd += " AND D_E_L_E_T_   = ' '"

			IIF(TcSqlExec(cQryUpd) == 0,"" , Conout(TCSqlError()))	
			cStatAtu:= "2"

			If cDataOri+cDocOri+cLoteOri != CT2->(DtoS(CT2_DATA)+CT2_DOC+CT2_LOTE) .Or. nLinha > nMaxLinha
				// Atualiza numeracao de lote, sub-lote e documento
				If MV_PAR13 = 1
					cLote    := CT2->CT2_LOTE
					cSubLote := CT2->CT2_SBLOTE
				Else
					cLote		:= IIf(Empty(cLote)   ,mv_par14,cLote)
					cSubLote	:= IIf(Empty(cSubLote),mv_par15,cSubLote)
				EndIf
				cDataOri:= DtoS(CT2->CT2_DATA)
				cDocOri := CT2->CT2_DOC
				cLoteOri:= CT2->CT2_LOTE
				
				cDoc    := CT2->CT2_DOC
				dDtLanc := CT2->CT2_DATA
				lFirst  := .T.
			EndIf

			For nInc := 1 To Len( aTpSaldos )
				
				//Nใo cria registro que jแ existe
				If AllTrim(aTpSaldos[nInc]) == AllTrim(cTpSldOri) .Or. Empty(aTpSaldos[nInc])
					Loop
				EndIf

				If lFirst .Or. nLinha > nMaxLinha
					CTM300ProxDoc(dDtLanc,cLote,cSubLote,@cDoc,@CTF_LOCK)
					If MV_PAR13 = 1
						cLote    := IIf(Empty(cLote)   ,Soma1(Space(TamSx3("CT2_LOTE")[1]))  ,cLote)    //CT2->CT2_LOTE
						cSubLote := IIf(Empty(cSubLote),Soma1(Space(TamSx3("CT2_SBLOTE")[1])),cSubLote) //CT2->CT2_SBLOTE
					Else
						cLote		:= IIf(Empty(cLote)   ,mv_par14,cLote)
						cSubLote	:= IIf(Empty(cSubLote),mv_par15,cSubLote)
					EndIf
					lFirst := .F.
					nLinha := 1
					cLinha := StrZero(nLinha,3)
				Else
					If cUltLanc != CT2->(CT2_FILIAL+DTOS(CT2_DATA)+CT2_LOTE+CT2_SBLOTE+CT2_DOC+CT2_LINHA+CT2_EMPORI+CT2_FILORI)
						nLinha ++
						cLinha := Soma1(cLinIncl)
					EndIf
				EndIf

				// Copia os campos padrao da tabela de lancamentos contabeis (CT2)           
				For nX := 1 To nCpos         
					If nX <> nPosTpSal            
						If CT2->(FieldPos('CT2_USERGI')) # nX .And. CT2->(FieldPos('CT2_USERGA')) # nX
							aDadosCT2[nX] := CT2->(FieldGet(nX))
						EndIf
					EndIf
				Next nX
				
				aDadosCT2[nPosLote]  := cLote
				aDadosCT2[nPosSLote] := cSubLote
				aDadosCT2[nPosDoc]   := cDoc
				aDadosCT2[nPosTPSal] := aTpSaldos[nInc]				// Tipo de Saldo
				aDadosCT2[nPosCtSal] := "2"							// Geracao Off-Line - Controle de Copia
 				aDadosCT2[nPosLinha] := cLinha

				If !Empty(cHistPadr)
					aDadosCT2[nPosHP]  := cHistPadr
					aDadosCT2[nPosHist] := Posicione("CT8",1,xFilial("CT8")+cHistPadr,"CT8_DESC")
				EndIf

				If lSemValor .And. CT2->CT2_MOEDLC == "01"
					aDadosCT2[nPosValor] := 0
				EndIf

	            //deve ser armazenado antes de gravar o registro no CT2 pois se refere ao registro de origem da copia
				cUltLanc := CT2->(CT2_FILIAL+DTOS(CT2_DATA)+CT2_LOTE+CT2_SBLOTE+CT2_DOC+CT2_LINHA+CT2_EMPORI+CT2_FILORI)

				// Cria novo registro na tabela CT2 e grava os dados do lancamento de origem
				RecLock( "CT2", .T. )
				For nX := 1 To nCpos
					If CT2->(FieldPos('CT2_USERGI')) # nX .And. CT2->(FieldPos('CT2_USERGA')) # nX
						CT2->( FieldPut( nX, aDadosCT2[nX] ) )
					EndIf
				Next nX
			    CT2->( MsUnlock() )
				
				cLinIncl := CT2->CT2_LINHA
			Next nInc
		EndIf
	EndIf
	

    TRB->( dbSkip() )
EndDo

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณ CTM300SelSintบ Autor ณ Gustavo Henrique บ Data ณ 20/12/06  บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDescricao ณ Seleciona registros das tabelas de saldos e grava arquivo  บฑฑ
ฑฑบ          ณ de trabalho quando selecionado na pergunta "Tipo" a opcao  บฑฑ
ฑฑบ          ณ movimentos sinteticos.                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ EXPL1 - Indicar se deve processar saldo ateh a data inicialบฑฑ
ฑฑบ          ณ         ou movimento sintetico do periodo.                 บฑฑ
ฑฑบ          ณ EXPC2 - Alias da tabela de saldos (CQ1,CQ3,CQ5,CQ7)        บฑฑ
ฑฑบ          ณ EXPD3 - Data inicial para selecao dos lancamentos de saldo บฑฑ
ฑฑบ          ณ EXPD4 - Data final para selecao dos lancamentos de saldo   บฑฑ
ฑฑบ          ณ EXPC5 - Moeda para selecao e gravacao dos lancamentos      บฑฑ
ฑฑบ          ณ EXPC6 - Tipo de saldo para selecao e gravacao dos lanctos. บฑฑ
ฑฑบ          ณ EXPL7 - Indica se movimenta centro de custo no CTB         บฑฑ
ฑฑบ          ณ EXPL8 - Indica se movimenta item contabil no CTB           บฑฑ
ฑฑบ          ณ EXPL9 - Indica se movimenta classe de valor no CTB         บฑฑ
ฑฑบ          ณ EXPL10- Indica se deve processar todas as moedas           บฑฑ
ฑฑบ          ณ EXPN11- Indica ateh que nivel de entidade do CTB deve      บฑฑ
ฑฑบ          ณ         processar os lancamentos.                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Contabilidade Gerencial                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CTM300SelSint( lSaldo, cAlias, dDataIni, dDataFim, cMoeda, cTpSaldo, lCusto, lItem, lClVl, lTodas, nNivel )

Local aSldAtu	:= {}
Local aSldIni	:= {}
Local aSldFim	:= {}

Local nDebTrb	:= 0 
Local nCrdTrb	:= 0
Local nTrbSlD	:= 0
Local nTrbSlC	:= 0
Local nMovCrd	:= 0
Local nMovDeb	:= 0
Local nSaldo	:= 0

Local cKeyAtu	:= ""             

Local cConta 	:= Space(Len(CriaVar("CT1_CONTA")))
Local cCusto 	:= Space(Len(CriaVar("CTT_CUSTO")))
Local cItem  	:= Space(Len(CriaVar("CTD_ITEM")))
Local cClVl		:= Space(Len(CriavAr("CTH_CLVL")))

Local dDataAtu	      
Local bCond		:= { || .T. }
Local cVarAux		:= ""

                                                                                                           
If lTodas
	bCond 	:= { ||	(cAlias)->&(cAlias + "_TPSALD") $ cTpSaldo .And.; 	// Processa apenas tipo de saldo de origem
					dDataAtu >= dDataIni .And.	dDataAtu <= dDataFim }      // Dentro do periodo informado
Else
	bCond 	:= { ||	(cAlias)->&(cAlias + "_TPSALD") $ cTpSaldo .And.; 	// Processa apenas tipo de saldo de origem
					dDataAtu >= dDataIni .And.	dDataAtu <= dDataFim .And.;	// Dentro do periodo informado
					(cAlias)->&(cAlias + "_MOEDA") == cMoeda }  			// Na moeda especifica ou para todas as moedas
EndIf					


cFilAlias := xFilial(cAlias)

(cAlias)->(dbSetOrder(2))
(cAlias)->(MsSeek(cFilAlias,.T.)) //Procuro pela primeira conta a ser zerada

// Calcula numero de dias que serao processados para incremento do gauge
ProcRegua( (cAlias)->(LastRec()) )

Do While (cAlias)->( !Eof() .And. &(cAlias+"_FILIAL") == cFilAlias )

	dDataAtu := (cAlias)->&(cAlias+"_DATA")

	IncProc()
	
	If lTodas
		cMoeda := (cAlias)->&(cAlias + "_MOEDA")
	EndIf	 
	
	// Verifica se atende as condicoes de filtro especificadas nos parametros
	If !Eval( bCond )
		(cAlias)->( dbSkip() )
		Loop
	EndIf

	If cAlias == 'CQ7'
		cChave := CQ7->(CQ7_CONTA+CQ7_CCUSTO+CQ7_ITEM+CQ7_CLVL)
	ElseIf cAlias == 'CQ5'
		cChave := CQ5->(CQ5_CONTA+CQ5_CCUSTO+CQ5_ITEM)
	ElseIf cAlias == 'CQ3'       
		cChave := CQ3->(CQ3_CONTA+CQ3_CCUSTO)
	ElseIf cAlias == 'CQ1'
		cChave := CQ1->CQ1_CONTA
	EndIf

	//--------------------------------------
	// Pula registro caso a chave se repita
	//--------------------------------------
	If cChave+cMoeda+cTpSaldo == cVarAux
		(cAlias)->( DBSkip() )
		Loop
	Else
		cVarAux := cChave+cMoeda+cTpSaldo
	EndIf

	If cAlias == 'CQ7'
		cConta := CQ7->CQ7_CONTA
		cCusto := CQ7->CQ7_CCUSTO
		cItem  := CQ7->CQ7_ITEM
		cClVl  := CQ7->CQ7_CLVL
		If lSaldo
			aSldAtu := SaldoCTI(cConta,cCusto,cItem,cClVL,dDataIni-1,cMoeda,cTpSaldo,'CTBM300',.F.)
		Else
			aSldIni	:= SaldoCTI(cConta,cCusto,cItem,cClVL,dDataIni,cMoeda,cTpSaldo,'CTBM300',.F.)
			aSldFim	:= SaldoCTI(cConta,cCusto,cItem,cClVL,dDataFim,cMoeda,cTpSaldo,'CTBM300',.F.)	
		EndIf	
	ElseIf cAlias == 'CQ5'
		cConta := CQ5->CQ5_CONTA
		cCusto := CQ5->CQ5_CCUSTO
		cItem  := CQ5->CQ5_ITEM
		If lSaldo
			aSldAtu	:= SaldoCT4(cConta,cCusto,cItem,dDataIni-1,cMoeda,cTpSaldo,'CTBM300',.F.)
		Else
			aSldIni	:= SaldoCT4(cConta,cCusto,cItem,dDataIni,cMoeda,cTpSaldo,'CTBM300',.F.)
			aSldFim	:= SaldoCT4(cConta,cCusto,cItem,dDataFim,cMoeda,cTpSaldo,'CTBM300',.F.)	
		EndIf	
	ElseIf cAlias == 'CQ3'
		cConta := CQ3->CQ3_CONTA
		cCusto := CQ3->CQ3_CCUSTO
		If lSaldo
			aSldAtu	:= SaldoCT3(cConta,cCusto,dDataIni-1,cMoeda,cTpSaldo,'CTBM300',.F.)
		Else
			aSldIni	:= SaldoCT3(cConta,cCusto,dDataIni,cMoeda,cTpSaldo,'CTBM300',.F.)	
			aSldFim	:= SaldoCT3(cConta,cCusto,dDataFim,cMoeda,cTpSaldo,'CTBM300',.F.)	
		EndIf	
	ElseIf cAlias == 'CQ1'
		cConta := CQ1->CQ1_CONTA
		If lSaldo
			aSldAtu	:= SaldoCT7(cConta,dDataIni-1,cMoeda,cTpSaldo,'CTBM300',.F.)	
		Else
			aSldIni	:= SaldoCT7(cConta,dDataIni,cMoeda,cTpSaldo,'CTBM300',.F.)	
			aSldFim	:= SaldoCT7(cConta,dDataFim,cMoeda,cTpSaldo,'CTBM300',.F.)	
		EndIf	
	EndIf			
                   
  	If lSaldo
		nSaldo	:= aSldAtu[1]
		lTemSld	:= (nSaldo <> 0)
	Else
		nMovDeb	:= iif( dDataIni == dDataFim , aSldFim[4]  , aSldFim[4] - aSldIni[4] )
		nMovCrd	:= iif( dDataIni == dDataFim , aSldFim[5]  , aSldFim[5] - aSldIni[5] )
		lTemSld	:= (nMovDeb <> 0 .Or. nMovCrd <> 0)
	EndIf	

	If lTemSld	// Se houver saldo
	
		nTrbSlD := 0
		nTrbSlC := 0
	
		TRB->( dbSetOrder(2) )
                               
		If cAlias <> "CQ7"	// Saldos x Classe de Valor
			If cAlias == "CQ5"	// Saldos x Item contabil
				If lClVl .And. nNivel == 4
					cKeyAtu := cTpSaldo+cMoeda+"CQ7"+cConta+cCusto+cItem
					CTM300CalcTRB( cAlias, cKeyAtu, @nTrbSlD, @nTrbSlC )
				EndIf	
			ElseIf cAlias == "CQ3" 	// Saldos x Centro de Custo
				If lItem .And. nNivel >= 3 
					cKeyAtu := cTpSaldo+cMoeda+"CQ3"+cConta+cCusto
					CTM300CalcTRB( cAlias, cKeyAtu, @nTrbSlD, @nTrbSlC )
				EndIf
				If lClVl .And. nNivel == 4	                      
					cKeyAtu := cTpSaldo+cMoeda+"CQ7"+cConta+cCusto
					CTM300CalcTRB( cAlias, cKeyAtu, @nTrbSlD, @nTrbSlC )
				EndIf	
			ElseIf cAlias == "CQ1"	// Saldos x Conta
				If lCusto .And. nNivel >= 2
					cKeyAtu := cTpSaldo+cMoeda+"CQ3"+cConta
					CTM300CalcTRB( cAlias, cKeyAtu, @nTrbSlD, @nTrbSlC )
				EndIf
				If lItem .And. nNivel >= 3
					cKeyAtu := cTpSaldo+cMoeda+"CQ5"+cConta
					CTM300CalcTRB( cAlias, cKeyAtu, @nTrbSlD, @nTrbSlC )
				EndIf
				If lClVl .And. nNivel == 4
					cKeyAtu := cTpSaldo+cMoeda+"CQ7"+cConta
					CTM300CalcTRB( cAlias, cKeyAtu, @nTrbSlD, @nTrbSlC )
				EndIf
			EndIf
		EndIf	
                
		If lSaldo
			nDebTrb := aSldAtu[4] - nTrbSlD
			nCrdTrb := aSldAtu[5] - nTrbSlC
		Else
			nDebTrb := nMovDeb - nTrbSlD
			nCrdTrb := nMovCrd - nTrbSlC
		EndIf	

		If (nDebTrb <> 0 .Or. nCrdTrb <> 0) 
			TRB->(dbSetOrder(1))		
			If ! TRB->(MsSeek(cTpSaldo+cMoeda+cConta+cCusto+cItem+cClvl+cAlias,.F.))
				RecLock("TRB",.T.)
				TRB->TPSALDO	:= cTpSaldo
				TRB->MOEDA		:= cMoeda
				TRB->CONTA		:= cConta
				TRB->CUSTO		:= cCusto
				TRB->ITEM		:= cItem
				TRB->CLVL		:= cClVL
				TRB->IDENT		:= cAlias
				TRB->DEBITO		:= nDebTrb
				TRB->CREDIT		:= nCrdTrb
				TRB->(MsUnlock())
			EndIf
			TRB->(dbSetOrder(2))			
		EndIf	
	EndIf	

	(cAlias)->(dbSkip())

EndDo

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออออัออออออออออออออออออหออออออัออออออออออปฑฑ
ฑฑบPrograma  ณ CTM300CalcTRB บ Autor ณ Gustavo Henrique บ Data ณ 26/12/06 บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯออออออออออออออออออสออออออฯออออออออออนฑฑ
ฑฑบDescricao ณ Calcula o saldo total de debito e credito para nas entida_ บฑฑ
ฑฑบ          ณ des de centro de custo, item ou classe de valor.           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ EXPC1 - Indica a entidade que deve ser apurado os debitos  บฑฑ
ฑฑบ          ณ         e creditos (CQ3, CQ5 ou CQ1)                       บฑฑ
ฑฑบ          ณ EXPC2 - Chave de busca dos valores de saldo da entidade.   บฑฑ
ฑฑบ          ณ EXPN3 - Saldo total de debitos para a entidade.            บฑฑ
ฑฑบ          ณ EXPN4 - Saldo total de credito para a entidade.            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Contabilidade Gerencial                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CTM300CalcTrb( cAlias, cKeyAtu, nTrbSlD, nTrbSlC )
                                                  
Local bCond	

If cAlias == "CQ5"
	bCond := { || cKeyAtu == TPSALDO+MOEDA+IDENT+CONTA+CUSTO+ITEM }
ElseIf cAlias == "CQ3"	
	bCond := { || cKeyAtu == TPSALDO+MOEDA+IDENT+CONTA+CUSTO }        
ElseIf cAlias == "CQ1"
	bCond := { || cKeyAtu == TPSALDO+MOEDA+IDENT+CONTA }
EndIf

TRB->( MsSeek( cKeyAtu, .F. ) )
TRB->( dbEval(	{ || nTrbSlD += DEBITO, nTrbSlC += CREDIT },, bCond ) )

Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณ CTM300GrvSintบ Autor ณ Gustavo Henrique บ Data ณ  21/12/06 บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDescricao ณ Grava lancamentos contabeis a partir do arquivo de trabalhoบฑฑ
ฑฑบ          ณ gerado, com os movimentos sinteticos de acordo com os      บฑฑ
ฑฑบ          ณ parametros informados.                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ EXPD1 - Data em que serao gravados os lancamentos          บฑฑ
ฑฑบ          ณ EXPC2 - Numero do lote do lancamento                       บฑฑ
ฑฑบ          ณ EXPC3 - Numero do sub-lote do lancamento                   บฑฑ
ฑฑบ          ณ EXPC4 - Codigo da moeda do lancamento                      บฑฑ
ฑฑบ          ณ EXPC5 - Tipo de saldo do lancamento                        บฑฑ
ฑฑบ          ณ EXPC6 - Historico padrao do lancamento                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Contabilidade Gerencial                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CTM300GrvSint( dDataLanc as Date, cLote as Character, cSubLote as Character, cMoeda as Character, cTpSaldo as Character, cHP as Character) as Logical

Local aArea			as Array
Local aCols			as Array
Local lFirst		as Logical
Local nLinha		as Numeric
Local nConta		as Numeric
Local cSeqLan		as Character
Local cLinha		as Character
Local cLinIncl 	 	as Character
Local cTipo			as Character
Local cDebito		as Character
Local cCustoDeb		as Character
Local cItemDeb		as Character
Local cClVlDeb		as Character
Local cCredito		as Character
Local cCustoCrd		as Character
Local cItemCrd		as Character
Local cClVlCrd		as Character
Local cDoc			as Character
Local nMaxLinha		as Numeric
Local CTF_LOCK		as Numeric

Default dDataLanc 	:= cTod('')
Default cLote		:= ""  
Default cSubLote 	:= "" 
Default cMoeda 		:= "" 
Default cTpSaldo 	:= "" 
Default cHP			:= "" 

aArea		:= GetArea()
aCols		:= {}
lFirst		:= .T.
nLinha		:= 1
nConta		:= 1
cSeqLan		:= ""
cLinha		:= ""
cLinIncl  	:= Space(Len(CT2->CT2_LINHA))
cTipo		:= ""
cDebito		:= ""
cCustoDeb	:= ""
cItemDeb	:= ""
cClVlDeb	:= ""
cCredito	:= ""
cCustoCrd	:= ""
cItemCrd	:= ""
cClVlCrd	:= ""
cDoc		:= ""
nMaxLinha	:= IIf(SuperGetMV("MV_NUMLIN")<1,999,CtbLinMax(SuperGetMv("MV_NUMLIN")))
CTF_LOCK	:= 0

ProcRegua( TRB->(LastRec()) )

CT2->( dbSetOrder( 1 ) )

CT8->( dbSetOrder( 1 ) )
CT8->( MsSeek( xFilial("CT8") + cHP ) )
cDescHP	:= CT8->CT8_DESC

TRB->( dbSetOrder(1) )
TRB->( dbGoTop() )

Do While TRB->( ! EoF() )
     
	IncProc()

	nSaldo := TRB->(CREDIT-DEBITO)
               
	If nSaldo <> 0

		If lFirst .Or. nLinha > nMaxLinha
			If Empty(mv_par14)
				cLote		:= IIf(Empty(cLote),Soma1(Space(TamSx3("CT2_LOTE")[1])),cLote) //CT2->CT2_LOTE
			Else
				cLote		:= IIf(Empty(cLote),mv_par14,cLote)
			EndIf

			If Empty(mv_par15)
				cSubLote := IIf(Empty(cSubLote),Soma1(Space(TamSx3("CT2_SBLOTE")[1])),cSubLote) //CT2->CT2_SBLOTE
			Else
				cSubLote	:= IIf(Empty(cSubLote),mv_par15,cSubLote)
			EndIf

			//Gera numero do documento
			CTM300ProxDoc(dDataLanc,cLote,cSubLote,@cDoc,@CTF_LOCK)

			lFirst := .F.
			nLinha := 1
			cLinha := StrZero(nLinha,3)
			cSeqLan:= StrZero(nLinha,3)
		Else   
		/*
			nLinha ++
			cLinha := StrZero(nLinha,3)
			cSeqLan:= StrZero(nLinha,3)
		*/			
		EndIf
	
		If nSaldo > 0	
			cTipo		:= "2"		/// LANCAMENTO A CREDITO
			cDebito	:= ""
			cCustoDeb:= ""
			cItemDeb	:= ""
			cClVlDeb	:= ""
	
			cCredito	:= TRB->CONTA
			cCustoCrd	:= TRB->CUSTO
			cItemCrd	:= TRB->ITEM
			cClVlCrd	:= TRB->CLVL			
		Else
			cTipo 		:= "1"		/// LANCAMENTO A DEBITO
			cDebito		:= TRB->CONTA
			cCustoDeb	:= TRB->CUSTO
			cItemDeb	:= TRB->ITEM	
			cClVlDeb	:= TRB->CLVL
	
			cCredito	:= ""
			cCustoCrd	:= ""
			cItemCrd	:= ""
			cClVlCrd	:= ""
		EndIf 
	
		//Grava lancamento na moeda 01
		nSaldo := Abs(nSaldo)
		cTpSald := AllTrim(cTpSald)	
		//BEGIN TRANSACTION
	
		If TRB->MOEDA == "01"
	
			aCols := { { "01", " ", nSaldo, "2", .F., nSaldo } }
	
			For nConta := 1 To Len(cTpSaldo)
				If !(SubStr(cTpSaldo,nConta,1) $ "|;| |") .And. SubStr(cTpSaldo,nConta,1) != TRB->TPSALDO
					GravaLanc(dDataLanc,cLote,cSubLote,cDoc,cLinha,cTipo,'01',cHP,cDebito,cCredito,;
						  cCustoDeb,cCustoCrd,cItemDeb,cItemCrd,cClVlDeb,cClVlCrd,nSaldo,cDescHP,;
						  SubStr(cTpSaldo,nConta,1),cSeqLan,3,.F.,aCols,cEmpAnt,cFilAnt,,,,,,,.F.)
					nRecCT2 := CT2->( Recno() )
					cLinIncl := CT2->CT2_LINHA

					If CT2->( MsSeek(xFilial("CT2")+DTOS(dDataLanc)+cLote+cSubLote+cDoc+cLinha+SubStr(cTpSaldo,nConta,1)+cEmpAnt+cFilAnt+"01") )
						nLinha ++
						cLinha := Soma1(cLinIncl)
						cSeqLan:= cLinha
					EndIf
					CT2->( dbGoto(nRecCT2) )
				EndIf
			Next nConta
	
		Else	/// Grava Lancamento na moeda 02 com valor zerado na moeda 01

			//aCols := { { "01", " ", 0.00, "2", .F., 0 },{ TRB->MOEDA, "4", nSaldo, "2", .F., nSaldo } }
	
			If Val(TRB->MOEDA) >= 2
				nForaCols	:= Val(TRB->MOEDA)-1
			Else                
				nForaCols	:= 0
			EndIf
			
			aCols := { { "01", " ", 0.00, "2", .F., 0 } }
			For nConta := 1 To Len(cTpSaldo)
				If !(SubStr(cTpSaldo,nConta,1) $ "|;| |") .And. SubStr(cTpSaldo,nConta,1) != TRB->TPSALDO
					GravaLanc(dDatalanc,cLote,cSubLote,cDoc,cLinha,cTipo,'01',cHP,cDebito,cCredito,;
						  cCustoDeb,cCustoCrd,cItemDeb,cItemCrd,cClVlDeb,cClVlCrd,0,cDescHP,;
						  SubStr(cTpSaldo,nConta,1),cSeqLan,3,.F.,aCols,cEmpAnt,cFilAnt,0,,,,,,.F.)
					nRecCT2 := CT2->( Recno() )
					cLinIncl := CT2->CT2_LINHA

					If CT2->( MsSeek(xFilial("CT2")+DTOS(dDataLanc)+cLote+cSubLote+cDoc+cLinha+SubStr(cTpSaldo,nConta,1)+cEmpAnt+cFilAnt+"01") )
						nLinha ++
						cLinha := Soma1(cLinIncl)
						cSeqLan:= cLinha
					EndIf
					CT2->( dbGoto(nRecCT2) )
				EndIf
			Next nConta

			aCols := { { TRB->MOEDA, "4", nSaldo, "2", .F., nSaldo } }
			For nConta := 1 To Len(cTpSaldo)
				If !(SubStr(cTpSaldo,nConta,1) $ "|;| |") .And. SubStr(cTpSaldo,nConta,1) != TRB->TPSALDO
					GravaLanc(dDataLanc,cLote,cSubLote,cDoc,cLinha,cTipo,TRB->MOEDA,cHP,cDebito,cCredito,;
						  cCustoDeb,cCustoCrd,cItemDeb,cItemCrd,cClVlDeb,cClVlCrd,0,cDescHP,;
						  SubStr(cTpSaldo,nConta,1),cSeqLan,3,.F.,aCols,cEmpAnt,cFilAnt,nForaCols,,,,,,.F.)
					nRecCT2 := CT2->( Recno() )
					cLinIncl := CT2->CT2_LINHA

					If CT2->( MsSeek(xFilial("CT2")+DTOS(dDataLanc)+cLote+cSubLote+cDoc+cLinha+SubStr(cTpSaldo,nConta,1)+cEmpAnt+cFilAnt+cMoeda) )
						nLinha ++
						cLinha := Soma1(cLinIncl)
						cSeqLan:= cLinha
					EndIf
					CT2->( dbGoto(nRecCT2) )
				EndIf
			Next nConta
		EndIf
	
		//END TRANSACTION
	
	EndIf


	TRB->( dbSkip() )

EndDo      

RestArea( aArea )

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหออออออัออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณCTBM300ProxDocบAutor ณ Gustavo Henrique บ Data ณ  15/01/07  บฑฑ
ฑฑฬออออออออออุออออออออออออออสออออออฯออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDescricao ณ Gera proxima numeracao de documento para gravar no novo    บฑฑ
ฑฑบ          ณ Lancamento. Caso estoure a numeracao de documento,         บฑฑ
ฑฑบ          ณ incrementa numero de lote.                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ EXPD1 - Data do lancamento a ser gravado                   บฑฑ
ฑฑบ          ณ EXPC2 - Numero do lote                                     บฑฑ
ฑฑบ          ณ EXPC3 - Numero do sub-lote                                 บฑฑ
ฑฑบ          ณ EXPC4 - Numero do documento                                บฑฑ
ฑฑบ          ณ EXPC5 - Numero do RECNO da tabela de numeracao de doctos.  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Contabilidade Gerencial                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function CTM300ProxDoc( dDataLanc, cLote, cSubLote, cDoc, CTF_LOCK )

// Verifica o Numero do Proximo documento contabil                         
Do While !ProxDoc(dDataLanc,cLote,cSubLote,@cDoc,@CTF_LOCK)
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Caso o Nง do Doc estourou, incrementa o lote         ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	cLote := Soma1(cLote)
Enddo

FreeUsedCode()  //libera codigos ainda travados

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCTM300GetTบAutor  ณ Totvs              บ Data ณ  13/10/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ retorna os tipos de saldos em um array.                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Contabilidade Gerencial                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CTM300GetTpSaldos( cTpSaldos, cSepara )
	Local aReturn 	:= {}
	Local cAux		:= ""
	Local nInc		:= 0
	
	cTpSaldos := AllTrim( cTpSaldos )
	For nInc := 1 To Len( cTpSaldos )
		cAux += substr( cTpSaldos, nInc, 1 )
		If substr( cTpSaldos, nInc, 1 ) == cSepara .OR. nInc == Len( cTpSaldos )
			If aScan( aReturn, StrTran( cAux, cSepara, "" ) ) == 0
				aAdd( aReturn, StrTran( cAux, cSepara, "" ) )
			EndIf

			cAux := ""
		EndIf
	Next
	
Return aReturn
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCTBA105   บAutor  ณMicrosiga           บ Data ณ  08/04/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function CtbLinMax(nMv_NumLin)
Local nRet := 0

If nMv_NumLin >= 35658  //limite estabelecido em razao do tamanho campo CT2_LINHA  = 3 e utilizar a funcao Soma1() para incremento
	nRet := 35658
Else
	nRet := nMv_NumLin
EndIf

Return(nRet)   
//-------------------------------------------------------------------
/*/{Protheus.doc} SchedDef
Retorna os parametros no schedule.

@return aReturn			Array com os parametros

@author  TOTVS
@since   07/04/2014
@version 12
/*/
//-------------------------------------------------------------------
Static Function SchedDef()

Local aParam  := {}

aParam := { "P",;			//Tipo R para relatorio P para processo
            "CTBM30",;		//Pergunte do relatorio, caso nao use passar ParamDef
            ,;				//Alias
            ,;				//Array de ordens
            STR0001,;		//Titulo - Copia de saldos
			,;				//Nome do Relat๓rio
			.T.,;			//Indica se permite que o agendamento possa ser cadastrado como sempre ativo
			.T. }			//Indica que o agendamento pode ser realizado por filiais

Return aParam

/*/{Protheus.doc} ctb300val
	(Valida se o numero de linhas ultrapassara o conteudo do MV_NUMLIN e serแ preciso criar um novo doc, caso sim serแ retorแ Verdadeiro)
	
	@author Wilton.Santos
	@since 18/01/2023
	@version 1.0
	/*/
Static Function ctb300val(cTpSldOri, cTpSalDest,dDataIni,dDataFim,lTdsMoedas,cMoeda)
Local aArea       := getArea()
Local lRet 		  := .F.
Local nMaxLinha   := SuperGetMV("MV_NUMLIN",.F.,999)
Local cQuery      := " "
Local TMPCT2	  := GetNextAlias()
Local nQtdTpSald  := len(alltrim(strtran(cTpSalDest,';')))

Default cTpSldOri := '1'
Default cMoeda 	  := '01'

cQuery+= " SELECT CT2_DATA, CT2_LOTE,CT2_SBLOTE,CT2_DOC,CT2_TPSALD,CT2_MOEDLC "  +CRLF
cQuery+= ",(COUNT(CT2_LINHA)*"+str(nQtdTpSald)+") QTDLIN "+CRLF
cQuery+= ", MAX(CT2_LINHA) MAXLIN "+CRLF
cQuery+= " FROM "+REtSqlName('CT2')+" CT2 "+CRLF
cQuery+= " WHERE CT2_FILIAL='"+FWxFilial('CT2')+"' AND  D_E_L_E_T_=' '"+CRLF
cQuery+= " AND CT2_DATA >='"+dtos(dDataIni)+"'"+CRLF
cQuery+= " AND CT2_DATA <='"+dtos(dDataFim)+"'"+CRLF
cQuery+= " AND CT2_CTLSLD = '0'"+CRLF
cQuery+= " AND CT2_TPSALD = '"+cTpSldOri+"'"+CRLF
if !lTdsMoedas
	cQuery+= " AND CT2_MOEDLC = '"+cMoeda+"'"+CRLF
EndIF
cQuery+= " GROUP BY CT2_DATA, CT2_LOTE,CT2_SBLOTE,CT2_DOC,CT2_TPSALD,CT2_MOEDLC "+CRLF
cQuery+= " ORDER BY QTDLIN DESC "+CRLF
cQuery:= changequery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),TMPCT2,.T.,.F.)

TcSetField(TMPCT2,'QTDLIN','N',GetSX3Cache("CT2_LINHA", "X3_TAMANHO"))
TcSetField(TMPCT2,'MAXLIN','N',GetSX3Cache("CT2_LINHA", "X3_TAMANHO"))

(TMPCT2)->(DbGoTop())
If (TMPCT2)->(!EOF())
	If (TMPCT2)->MAXLIN + (TMPCT2)->QTDLIN > nMaxLinha  
		lRet := .T.
	EndIf
EndIF
(TMPCT2)->(dbCloseArea())

restArea(aArea)
Return lRet

//-------------------------------------------------------------------
/*{Protheus.doc} EngSPS25Signature
Identifica a seqUencia de controle do fonte ADVPL com a     
stored procedure, qualquer alteracao que envolva diretamente
a stored procedure a variavel sera incrementada.            
Procedure CTB301                                           

@author Douglas Silva 
@version P12
@since   21.03.2023
@return  versใo
@obs	 
*/
//-------------------------------------------------------------------   

         
// Processo 25 - COPIA DE SALDOS
Function EngSPS25Signature(cProcess as character)
Return "004"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหออออออัออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณCTM300SOMA    บAutor ณ TOTVS            บ Data ณ  23/01/09  บฑฑ
ฑฑฬออออออออออุออออออออออออออสออออออฯออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDescricao ณ Gera mssoma1 para banco respectivo                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ EXPC1 - Nome da procedure                                  บฑฑ
ฑฑบ          ณ EXPC2 - MsstrZero criado previamente                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Contabilidade Gerencial                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function CTM300SOMA(cProc, cStrZero)
Local aSaveArea as array
Local lRet as logical
Local cQuery as character
Local cProcUso as character

aSaveArea := GetArea()
lRet := .T.
cQuery := cProcSOMA1(cProc, cStrZero)
cQuery := CtbAjustaP(.F., cQuery, 0)
cProcUso := cProc+"_"+cEmpAnt

If !TCSPExist(cProcUso) .And. TcSqlExec(cQuery) <> 0	
	lRet := .F.
	If !__lBlind
		MsgAlert(STR0095+cProcUso+CRLF+TcSqlError(),"CTM300SOMA")  //"Erro na criacao da procedure StrZero "
	EndIf	
EndIf

RestArea(aSaveArea)
aSize(aSaveArea,0)
aSaveArea := nil
Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} CTBInTrans
Indica se estแ ou nใo em transa็ใo, esta fun็ใo ้ para simplica็ใo
para retorna:
0 - Indica NรO ESTAR em transa็ใo 
1 - Indica ESTAR em transa็ใo

@author TOTVS
@since 18/09/2024
@version 12
@param
/*/
//-------------------------------------------------------------------
Static Function CTBInTrans()
Return if(InTransAct(),'1','0')

//-------------------------------------------------------------------
/*/{Protheus.doc} CTBDELCT2
Deleta a CT2

@author TOTVS
@since 18/09/2023
@version 12
@param
/*/
//-------------------------------------------------------------------
Function CTBDELCT2(cCodEmp, cCodFil, aRecnos, cThreadID)
Local nI := 0

DEFAULT cCodEmp := ""
DEFAULT cCodFil := ""
DEFAULT cThreadID := ""
DEFAULT aRecnos := {}

//Seta job para nao consumir licensas
RpcSetType(3)
// Seta job para empresa filial desejada
RpcSetEnv( cCodEmp, cCodFil,,,'CTB','CTBM300')

If !Empty(cThreadID)
	LockByName(cThreadID,.T.,.T.)
EndIf

dbSelectArea("CT2")

For nI := 1 to Len(aRecnos)
	CT2->(dbGoTo(aRecnos[nI]))
	CT2->( GravaLanc(CT2_DATA,CT2_LOTE,CT2_SBLOTE,CT2_DOC,CT2_LINHA,CT2_DC,CT2_MOEDLC,CT2_HP,CT2_DEBITO,;
				CT2_CREDIT,CT2_CCD,CT2_CCC,CT2_ITEMD,CT2_ITEMC,CT2_CLVLDB,CT2_CLVLCR,CT2_VALOR,CT2_HIST,;
				CT2_TPSALD,CT2_SEQLAN,5,.F.,,CT2_EMPORI,CT2_FILORI,,,,,,,.F. ) )
Next nI

If !Empty(cThreadID)
	UnLockByName(cThreadID,.T.,.T.)
EndIf
RpcClearEnv()
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} EngPre25Compile
Deleta a CT2

@author TOTVS
@since 18/09/2023
@version 12
@param
/*/
//-------------------------------------------------------------------
Function EngOn25Compile( cProcesso as character, cEmpresa as character, cProcName as character, cBuffer as character, cError as character )

If __cTabTrw == Nil
	lMudaTRT := SuperGetMV("MV_MUDATRT",.F.,.T.)
	__cTabTRW := "TRW"+SM0->M0_CODIGO+"0"+Iif(lMudaTRT, "_SP", "")
EndIf

cBuffer := StrTran( cBuffer, "TRW###", __cTabTRW )
   
Return .T.
