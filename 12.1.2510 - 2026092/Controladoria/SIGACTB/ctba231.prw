#Include "CTBA231.Ch"
#Include "PROTHEUS.Ch"
#Include "FONT.CH"
#Include "COLORS.CH"

STATIC __lBlind 	
STATIC __lCtbIsCube 
STATIC __lMultiRot  
STATIC __nQtdEnt	
STATIC nMAX_LINHA	
STATIC __cSGBD
/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒø±±
±±≥ FunáÖo    ≥ Ctba231  ≥ Autor  ≥ Marcelo Akama           ≥ Data 21.05.09≥±±
±±√ƒƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ DescriáÖo ≥ AglutinaáÑo de dados Configurada. (Modelo B)               ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Sintaxe    ≥ Ctba231()                                                  ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Retorno    ≥ Nenhum                                                     ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥  Uso      ≥ SigaCTB                                                    ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ ParÑmetros≥ lBat - Indica se ser· executada com BatchProcess           ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Function Ctba231(lBat as Logical)

Local cCadastro as Character
Local cMensagem as Character
Local nOpca		as Numeric
Local aSays 	as Array
Local aButtons 	as Array
Local lret 		as Logical

DEFAULT lBat := .F.

cCadastro	:= STR0001  		//"ConsolidaáÑo de Empresas / Filiais"
cMensagem	:= ""
aSays 		:= {}
aButtons	:= {}

If ( !AMIIn(34) )		// Acesso somente pelo SIGACTB
	Return
EndIf

If CTB->(FieldPos("CTB_HAGLUT"))<=0 // Verifica se a base est· atualizada
	MsgAlert(STR0013) // "Execute o compatibilizador para o correto funcionamento da rotina"
	Return
Endif


If __lBlind == nil
	__lBlind := IsBlind()
EndIf

If __lCtbIsCube == nil
	__lCtbIsCube := CtbIsCube()
EndIf

If __lCtbIsCube .And. __nQtdEnt == nil
	__nQtdEnt := CtbQtdEntd()
EndIf

If __lMultiRot == nil
	__lMultiRot := SuperGetMV("MV_CTBMTRT",, .F.)
EndIf

If nMAX_LINHA == nil
	nMAX_LINHA := CtbLinMax(GetMv("MV_NUMLIN"))
EndIf

If Ctb240Emp() //Se estiver na empresa/filial DESTINO (de acordo com o param. MV_CONSOLD
	If __lBlind .Or. lBat
		BatchProcess( 	cCadastro, 	STR0007+chr(13)+chr(10)+STR0008, "CTB231", { || Ct231Proc(.T.) }, { || .F. }  )
		Return .T.
	Endif
	
	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	//≥ Mostra tela de aviso - processar exclusivo			         ≥
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	cMensagem := STR0005+chr(13)  		//"E melhor que os arquivos associados a esta rotina nao estejam em uso por outras estacoes."
	cMensagem += STR0006+chr(13)  		//"Faca com que os outros usuarios saiam do sistema."
	    IF !MsgYesNo(cMensagem,STR0004)		//"ATENÄéO"
			Return
		Endif
	
	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	//≥ Variaveis utilizadas para parametros                         ≥
	//≥ mv_par12     // Cod. Roteiro Consolidacao                    ≥
	//≥ mv_par02     // da data                                      ≥
	//≥ mv_par03     // Ate a data                                   ≥
	//≥ mv_par04     // Apaga? Periodo/Tudo                   		 ≥
	//≥ mv_par05     // Escolhe Moeda?                               ≥
	//≥ mv_par06     // Qual Moeda?                                  ≥
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	Pergunte("CTB231",.f.)
	AADD(aSays,STR0007 )	//Este programa tem como objetivo aglutinar os lancamentos conforme configurado
	AADD(aSays,STR0008 )	//pelo usuario na Rotina de Consolidacao.
	AADD(aSays,' ' )	//
	
	AADD(aButtons, { 5,.T.,{|| Pergunte("CTB231",.T. ) } })
	AADD(aButtons, { 1,.T.,{|| nOpca:= 1, If( CtbOk(), FechaBatch(), nOpca:=0 ) }} )
	AADD(aButtons, { 2,.T.,{|| FechaBatch() }} )
		
	FormBatch( cCadastro, aSays, aButtons,, 160 )
	
	IF nOpca == 1 
		//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒC
		//≥VALIDACAO DE AMARRA«’ES E BLOQUEIOS DE MOEDA/CALENDARIO≥
		//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒC
			MsgRun(STR0025, STR0030, {|| lRet := !CtVlDTMoed(mv_par02,mv_par03,mv_par05,mv_par06) })   // "ValidaÁ„o moedas"
	        MsgRun(STR0025, STR0031, {|| lRet := lRet .And. Ct231VldSld()})								// "ValidaÁ„o Saldos"
		
		If lRet 
			If mv_par08 == 1  // Gera Saldo Inicial
				If mv_par04 = 1  // Limpa periodo
					dbSelectArea("CT2")
					dbSetOrder(1)
					If dbSeek(xFilial("CT2")+DTOS(mv_par02-1),.F.)
						If !__lBlind
							MsgInfo(STR0018)   //"Ja existem dados na data de saldo inicial, saldo inicial nao sera gerado."
						EndIf
						mv_par08 := 2
					EndIf
				EndIf
			EndIf
			
			MsgRun(STR0025, STR0024, {|lEnd| CT231Proc()})
		EndIf
		
	Endif
Endif

Return

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒø±±
±±≥ FunáÖo    ≥ Ct231Proc≥ Autor  ≥ Marcelo Akama           ≥ Data 22.05.09≥±±
±±√ƒƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ DescriáÖo ≥ Inicia o processamento dos arquivos de consolidacao        ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Sintaxe    ≥ Ct231Proc() - Baseado na Ct230Proc()                       ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Retorno    ≥ Nenhum                                                     ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥  Uso      ≥ SigaCTB                                                    ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ ParÑmetros≥ NÑo h†                                                     ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Function Ct231Proc(lBat as Logical)
Local dDataIni	  as Date
Local dDataFim	  as Date
Local nMoedas 	  as Numeric
Local cMoeda 	  as Character
Local aEmpOri	  as Array
Local aEmpOriEnt  as Array
Local lDelFisico  as Logical
Local cArquivo	  as Character
Local aAlias 	  as Array
Local cChave      as Character
Local cQuery	  as Character
Local nMax		  as Numeric
Local nX		  as Numeric
Local i		      as Numeric
Local aModSX2     as Array
Local aModCTI     as Array
Local aModCT4     as Array
Local aModCT3     as Array
Local aModCT7     as Array
Local aModCVX     as Array
Local cArqCTI     as Character
Local cArqCT4     as Character
Local cArqCT3     as Character
Local cArqCT7     as Character
Local cArqCVX     as Character
Local cAliasCTB   as Character
Local aEmpCT2 	  as Array
Local lProcOK     as Logical
Local aCtbMoeda   as Array

DEFAULT lBat := .F.

dDataIni	:= mv_par02
dDataFim	:= mv_par03
nMoedas 	:= 0
nMax		:= 0
cMoeda 		:= ""
cChave    	:= ""
cQuery		:= ""
cAliasCTB 	:= ""  
aEmpOri		:= {}
aEmpOriEnt	:= {}
lDelFisico	:= GetNewPar('MV_CTB230D',.T.)
aAlias 		:= {}
aModSX2 	:= {}
aModCTI 	:= {}
aModCT4 	:= {}
aModCT3 	:= {}
aModCT7 	:= {}
aModCVX 	:= {}
cArqCTI 	:= {}
cArqCT4 	:= {}
cArqCT3 	:= {}
cArqCT7 	:= {}
cArqCVX 	:= {}
aEmpCT2 	:= {}
lProcOK 	:= .F.

If CTB->(FieldPos("CTB_HAGLUT"))<=0 // Verifica se a base est· atualizada
	MsgAlert(STR0013) // "Execute o compatibilizador para o correto funcionamento da rotina"
	Return
Endif

If mv_par05 == 2						// Considera Moeda Especifica
	aCtbMoeda  	:= CtbMoeda(mv_par06)
	If Empty(aCtbMoeda[1])
		Help(" ",1,"NOMOEDA")
		TRB->(DbCloseArea())
		Return .F.
	EndIf
	nMoedas  := 1
	cMoeda := aCtbMoeda[1]
Else
	nMoedas := __nQuantas
Endif

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒC
//≥VALIDACAO DE AMARRA«’ES E BLOQUEIOS DE MOEDA/CALENDARIO≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒC
If CtVlDTMoed(dDataIni,dDataFim,mv_par05,mv_par06)
	// Se houver moeda, data ou data em moeda com status bloqueado.
	Return .F.
EndIf

If	!(	MA280FLock("CT1") .And.;
		MA280FLock("CT2") .And.;
		MA280FLock("CQ0") .And.;
		MA280FLock("CQ1") .And.;
		MA280FLock("CQ2") .And.;
		MA280FLock("CQ3") .And.;
		MA280FLock("CQ4") .And.;
		MA280FLock("CQ5") .And.;
		MA280FLock("CQ6") .And.;
		MA280FLock("CQ7") .And.;
		MA280FLock("CTC") .And.;
		MA280FLock("CTD") .And.;
		MA280FLock("CTF") .And.;
		MA280FLock("CTH") .And.;
		MA280FLock("CTC") .And.;
		MA280FLock("CTB") .And.;
		MA280FLock("CTT") .And.;
		MA280FLock("CVX") .And.;
		MA280FLock("CVY") )
	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	//≥ Fecha todos os arquivos e reabre-os de forma compartilhada   ≥
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	dbCloseAll()
	OpenFile(SubStr(cNumEmp,1,2))
	Return .T.
EndIf

If mv_par01 == 1
	If lDelFisico
		If mv_par04 == 2					// Apaga os arquivos			
			aAlias := {"CT2","CQ0","CQ1","CQ2","CQ3","CQ4","CQ5","CQ6","CQ7","CQ8","CQ9","CTC","CTF","CVX","CVY"}
			For i := 1 to Len(aAlias)
				If AliasInDic(aAlias[i])
					nMax := (aAlias[i])->(LastRec())
					cQuery := "DELETE FROM "+RetSqlName(aAlias[i])
					cQuery += " WHERE "
					//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
					//≥Executa a string de execucao no banco para os proximos 1024 registro a fim de nao estourar o log do SGBD≥
					//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
					For nX := 1 To nMax STEP 1024
						cChave := "R_E_C_N_O_>="+Str(nX,10,0)+" AND R_E_C_N_O_<="+Str(nX+1023,10,0)+""
						TcSqlExec(cQuery+cChave)
					Next nX
					//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
					//≥A tabela eh fechada para restaurar o buffer da aplicacao≥
					//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
					dbSelectArea(aAlias[i])
					dbCloseArea()
					ChkFile(aAlias[i],.F.)
				EndIf
			Next		
		Else						// Zera somente o periodo informado
			//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
			//≥ Zera valores de saldos no periodo a consolidar     ≥
			//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
			Ct231Apaga()
		EndIf
		sleep(1000) // Delay para bases com poucos lanÁamentos, pois nao da tempo de limpar as tabelas antes do insert
	Endif
Else	/// Caso n„o apague os lanÁamentos na empresa consolidadora.
	dbSelectArea("CT2")
	dbSetOrder(1)
	dbSeek(xFilial("CT2")+DTOS(mv_par02),.T.)
	If !Eof() .and. CT2->CT2_DATA <= mv_par03
		If ! __lBlind
			If !MsgNoYes(STR0014+;//"Existem lanÁamentos na empresa consolidadora neste perÌodo. "
				STR0015+;//"(Recomendado processamento apagando perÌodo a ser consolidado)."
				STR0016,;//" Deseja realmente continuar ? "
				STR0017)//"Periodo j· consolidado !"
				Return
			EndIf
		EndIf
	EndIf
EndIf

If FindFunction("CTBInstPRC")
	lProcOK := CTBInstPRC("36")	
EndIf

If !lProcOK
	Help(" ",1,"PROC_36",,STR0035,3,0 )//"O processo 36 n„o pÙde ser instalado automaticamente. A instalaÁ„o dever· ser feita manualmente no configurador (SIGACFG)." 
	Return .F.
EndIf

cNomeArq:=CriaTrab( nil, .F. )
cQuery := " SELECT CTB_EMPORI EMP FROM "+RETSQLNAME('CTB')+" WHERE CTB_CODIGO BETWEEN '"+MV_PAR12+"' AND '"+MV_PAR13+"' AND D_E_L_E_T_=' ' GROUP BY CTB_EMPORI ORDER BY CTB_EMPORI "
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cNomeArq)
While (cNomeArq)->(!Eof())

	Ct231Alias("CT2",@aModSX2,@cArquivo,(cNomeArq)->EMP)
	AADD(aEmpCT2,{(cNomeArq)->EMP,aModSX2 })

	If __lCtbIsCube
		Ct231Alias("CVX",@aModCVX ,@cArqCVX,(cNomeArq)->EMP)
		Ct231Alias("CT2",@aModSX2,@cArquivo,(cNomeArq)->EMP)			
		AADD(aEmpOri,{(cNomeArq)->EMP,{aModSX2,cArquivo}})
		AADD(aEmpOriEnt,{(cNomeArq)->EMP,{aModCVX,cArqCVX}})
	Else
		Ct231Alias("CT2",@aModSX2,@cArquivo,(cNomeArq)->EMP)
		Ct231Alias("CQ7",@aModCTI ,@cArqCTI,(cNomeArq)->EMP)
		Ct231Alias("CQ5",@aModCT4 ,@cArqCT4,(cNomeArq)->EMP)
		Ct231Alias("CQ3",@aModCT3 ,@cArqCT3,(cNomeArq)->EMP)
		Ct231Alias("CQ1",@aModCT7 ,@cArqCT7,(cNomeArq)->EMP)
		AADD(aEmpOri,{(cNomeArq)->EMP,{aModSX2,cArquivo},{aModCTI,cArqCTI},{aModCT4,cArqCT4},{aModCT3,cArqCT3},{aModCT7,cArqCT7}})
	EndIf
	(cNomeArq)->(DbSkip())
End

(cNomeArq)->(dbCloseArea())

If CT231TbCTB(@cAliasCTB,aEmpCT2)
	If mv_par08 == 1
		iF __lCtbIsCube
			Ct231SldIni(aEmpOriEnt,cAliasCTB)  /* Lancatos Slds Iniciais com NOVAS ENTIDADES */
		Else
			New231SlInP(aEmpOri,cAliasCTB)  /* Lancatos Slds Iniciais */				
		EndIf
	EndIf
	
	New231ExeP(aEmpOri,cAliasCTB)
	
	//Atualiza o cashe do DBAccess apÛs executar a procedure
	TCRefresh( RetSqlName("CT2") )
	
	MsErase(cAliasCTB,,"TOPCONN")
EndIf

If mv_par16 == 1
	//CHAMA O REPROCESSAMENTO PARA ATUALIZAR OS SALDOS.
	/// ATUALIZA OS SALDOS AO FINAL DO PROCESSAMENTO
	oProcess := MsNewProcess():New({|lEnd|	CTBA190(.T., IIf( mv_par08 == 1, mv_par02-1, mv_par02 ),mv_par03,cFilAnt,cFilAnt,mv_par07,mv_par05 == 2,mv_par06)		},"","",.F.)
	oProcess:Activate()
EndIf
 
// PONTO DE ENTRADA UTILIZADO PARA MANIPULAR AS INFORMACOES DO LANCAMENTO CONTABIL DE DESTINO APOS A GRAVACAO NA TABELA CT2
If ExistBlock("Ct231PosGrv")
	ExecBlock("Ct231PosGrv",.F.,.F.)
Endif

Return

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒø±±
±±≥ FunáÖo    ≥Ct231Ok   ≥ Autor  ≥ Simone Mie Sato         ≥ Data 10.07.01≥±±
±±√ƒƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ DescriáÖo ≥ Confirma processamento                                     ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Sintaxe    ≥ Ct231Ok()                                                  ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Retorno    ≥ Mensagem para confirmacao                                  ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥  Uso      ≥ SigaCTB                                                    ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ ParÑmetros≥Nenhum                                                      ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Function Ct231OK()

Local cMensagem
Local cCodEmp	:= FWGRPCompany()
Local cNomeEmp := FWFilialName(cEmpAnt,cFilAnt,2)
Local cCodFil	:= FWGETCODFILIAL
Local cNomeFil	:= FWFilialName(cEmpAnt,cFilAnt,1)

If mv_par01 == 1
	cMensagem := STR0010+chr(13)		//"Os dados da empresa abaixo serao apagados"
	cMensagem += STR0002+cCodEmp+"-"+cNomeEmp+chr(13) //"Empresa : "
	cMensagem += STR0003+cCodFil+"-"+cNomeFil+chr(13)//"Filial  : "
	cMensagem += STR0010				//"Confirma Consolidacao nesta empresa?"
Else
	cMensagem := STR0010+chr(13)  //"Confirma Consolidacao nesta empresa?"
	cMensagem += STR0002+cCodEmp+"-"+cNomeEmp+chr(13) //"Empresa : "
	cMensagem += STR0003+cCodFil+"-"+cNomeFil        //"Filial : "
EndIf
Return MsgYesNo(cMensagem,STR0004)  //"AtenáÑo"
/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒø±±
±±≥ FunáÖo    ≥Ct231Alias≥ Autor  ≥ Simone Mie Sato         ≥ Data 10.07.01≥±±
±±√ƒƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ DescriáÖo ≥ Abre arquivo origem                                        ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Sintaxe    ≥ Ct231Alias(cAlias,cModoSX2,cArquivo)                       ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Retorno    ≥ .T./.F.                                                    ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥  Uso      ≥ SigaCTB                                                    ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ ParÑmetros≥ExpC1 = Alias do arquivo                                    ≥±±
±±≥           ≥ExpC2 = Modo de acesso                                      ≥±±
±±≥           ≥ExpC3 = Nome do arquivo                                     ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Function Ct231Alias(cAlias,aModSX2,cArquivo,cEmpAlias)
Local lRet := .T.

aModSX2 := {}

Aadd(aModSX2,FWModeAccess(cAlias,1,cEmpAlias))
Aadd(aModSX2,FWModeAccess(cAlias,2,cEmpAlias))
Aadd(aModSX2,FWModeAccess(cAlias,3,cEmpAlias))

cArquivo := Trim(RetFullName(cAlias,cEmpAlias))

Return lRet

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒø±±
±±≥ FunáÖo    ≥Ct231Apaga≥ Autor  ≥ Simone Mie Sato         ≥ Data 10.07.01≥±±
±±√ƒƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ DescriáÖo ≥ Apaga periodo desejado                                     ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Sintaxe    ≥ Ct231Apaga()                                               ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Retorno    ≥ .T./.F.                                                    ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥  Uso      ≥ SigaCTB                                                    ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ ParÑmetros≥Nenhum                                                      ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Function Ct231Apaga()

Local dDataIni := mv_par02
Local dDataFim := mv_par03
Local aAlias	:= {}
Local cChave	:= ""
Local cQuery	:= ""
Local Ct231Del	:= ""
Local nCountReg:= 0
Local nMax		:= 0
Local nMin		:= 0
Local i         := 0

aAlias := {"CT2","CQ0","CQ1","CQ2","CQ3","CQ4","CQ5","CQ6","CQ7","CTC","CTF","CVX","CVY"}
For i := 1 to Len(aAlias)
	If AliasInDic(aAlias[i])
		//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
		//≥Verifica qual eh o maior e o menor Recno que satisfaca a selecao≥
		//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
		Ct231Del	:= "Ct231Del"
		
		cQuery := "SELECT R_E_C_N_O_ RECNO "
		cQuery += "FROM "+RetSqlName(aAlias[i])
		cQuery += " WHERE " +aAlias[i]+"_FILIAL = '" + xFilial(aAlias[i])+"' AND "
		cQuery += aAlias[i]+"_DATA >= '" + DTOS(dDataIni)+ "' AND "
		cQuery += aAlias[i]+"_DATA <= '" + DTOS(dDataFim)+ "' AND "
		cQuery += " D_E_L_E_T_ = ' '"
		cQuery += " ORDER BY RECNO"
		
		cQuery := ChangeQuery(cQuery)
		
		If ( Select ( "Ct231Del" ) <> 0 )
			dbSelectArea ( "Ct231Del" )
			dbCloseArea ()
		Endif
		
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),Ct231Del)
		
		dbSelectArea(aAlias[i])
		
		//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
		//≥Monta a string de execucao no banco≥
		//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
		cQuery := "DELETE FROM "+RetSqlName(aAlias[i])
		cQuery += " WHERE " + aAlias[i]+"_FILIAL = '" + xFilial(aAlias[i])+"' AND "
		cQuery += aAlias[i]+"_DATA >= '" + DTOS(dDataIni)+ "' AND "
		cQuery += aAlias[i]+"_DATA <= '" + DTOS(dDataFim)+ "' AND "
		
		//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
		//≥Executa a string de execucao no banco para os proximos 1024 registro a fim de nao estourar o log do SGBD≥
		//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
		While Ct231Del->(!Eof())
			
			nMin := (Ct231Del)->RECNO
			
			nCountReg := 0
			
			While Ct231Del->(!Eof()) .and. nCountReg <= 4096
				
				nMax := (Ct231Del)->RECNO
				nCountReg++
				Ct231Del->(DbSkip())
				
			End
			
			cChave := "R_E_C_N_O_>="+Str(nMin,10,0)+" AND R_E_C_N_O_<="+Str(nMax,10,0)+""
			TcSqlExec(cQuery+cChave)
			
		End
		dbCloseArea()
		//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
		//≥A tabela eh fechada para restaurar o buffer da aplicacao≥
		//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
		dbSelectArea(aAlias[i])
		dbCloseArea()
		ChkFile(aAlias[i],.F.)
	EndIf
Next

Return
/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒø±±
±±≥ FunáÖo    ≥Ct231SldIni≥ Autor  ≥ TOTVS                   ≥ Data 18.05.10≥±±
±±√ƒƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ DescriáÖo ≥ Gera lancamentos de saldo inicial NOVAS ENTIDADES		    ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Sintaxe   ≥ Ct231SlInP(aEmpOri)                                         ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Retorno    ≥                                                             ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥  Uso      ≥ SigaCTB                                                     ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ ParÑmetros≥ ExpA1 - Array com os nomes das tabelas das empresas origem  ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Function Ct231SldIni(aEmpOri as Array, cAliasCTB as Character)
Local aCtbMoeda	 as Array
Local cMoeda	 as Character
Local cDataSld	 as Character
Local nX		 as Numeric
Local nZ		 as Numeric
Local cQuery	 as Character
Local cWhere	 as Character
Local cSelect	 as Character
Local cEntidade	 as Character
Local aCposEnt	 as Array 
Local aCampos	 as Array
Local cTmp1		 as Character
Local nPos 		 as Numeric 
Local cQry 		 as Character 
Local cQryAlias  as Character 
Local aTamVlr 	 as Array 
Local CTF_LOCK   as Numeric 
Local cLote 	 as Character 
Local cSubLote 	 as Character 
Local cDoc 		 as Character 
Local cLinha 	 as Character 
Local cSeqLan    as Character 
Local nLinha     as Numeric 
Local lFirst     as Logical 
Local aCpoDeb    as Array 
Local aCpoCrd    as Array
Local nQtdeEnt	 as Numeric

Private lSublote := .T.

DEFAULT aEmpOri   := {}
DEFAULT cAliasCTB := ""

aCtbMoeda	:= CtbMoeda(mv_par06)
cMoeda		:= aCtbMoeda[1]
cDataSld	:= DTOS(mv_par02-1)
cQuery		:= ""
cWhere		:= ""
cSelect		:= "CTB_EMPORI,CTB_FILORI,"
cEntidade	:= ""
aCposEnt	:= {}
aCampos		:= {}
cTmp1		:= ""
cQry		:= ""
cQryAlias	:= ""
aTamVlr  	:= TamSX3("CVX_SLDCRD")
CTF_LOCK	:= 0
cLote		:= mv_par09
cSubLote	:= mv_par10
cDoc		:= mv_par11
cLinha		:= "001"
cSeqLan		:= "001"
nLinha		:= 0
lFirst		:= .T.
aCpoDeb		:= {}
aCpoCrd		:= {}

If mv_par05==2 .And. Empty(cMoeda)
	Help(" ",1,"NOMOEDA")
	Return .F.
EndIf

nQtdeEnt := CtbQtdEntd()//sao 4 entidades padroes -> conta /centro custo /item contabil/ classe de valor

AADD(aCposEnt,{	'CVX_NIV01',;						// 1 - Nome campo temporario
'CTB_CTADES',;						// 2 - Nome do campo entidade DESTINO
'CTB_CT1INI',;						// 3 - Nome do campo entidade INICIO
'CTB_CT1FIM',;						// 4 - Nome do campo entidade FIM
'CT2_DEBITO',;						// 5 - Nome do campo tabela CT2 entidade DEBITO
'CT2_CREDIT'})						// 6 - Nome do campo tabela CT2 entidade CREDITO

AADD(aCposEnt,{	'CVX_NIV02',;						// 1 - Nome campo temporario
'CTB_CCDES',;						// 2 - Nome do campo entidade DESTINO
'CTB_CTTINI',;						// 3 - Nome do campo entidade INICIO
'CTB_CTTFIM',;						// 4 - Nome do campo entidade FIM
'CT2_CCD',;							// 5 - Nome do campo tabela CT2 entidade DEBITO
'CT2_CCC'})							// 6 - Nome do campo tabela CT2 entidade CREDITO

AADD(aCposEnt,{	'CVX_NIV03',;						// 1 - Nome campo temporario
'CTB_ITEMDE',;						// 2 - Nome do campo entidade DESTINO
'CTB_CTDINI',;						// 3 - Nome do campo entidade INICIO
'CTB_CTDFIM',;						// 4 - Nome do campo entidade FIM
'CT2_ITEMD',;						// 5 - Nome do campo tabela CT2 entidade DEBITO
'CT2_ITEMC'})						// 6 - Nome do campo tabela CT2 entidade CREDITO

AADD(aCposEnt,{	'CVX_NIV04',;						// 1 - Nome campo temporario
'CTB_CLVLDE',;						// 2 - Nome do campo entidade DESTINO
'CTB_CTHINI',;						// 3 - Nome do campo entidade INICIO
'CTB_CTHFIM',;						// 4 - Nome do campo entidade FIM
'CT2_CLVLDB',;						// 5 - Nome do campo tabela CT2 entidade DEBITO
'CT2_CLVLCR'})						// 6 - Nome do campo tabela CT2 entidade CREDITO

AADD(aCampos,{"CVX_SLDCRD"	,"N"	,aTamVlr[1]+2	,aTamVlr[2]})
AADD(aCampos,{"CVX_SLDDEB"	,"N"	,aTamVlr[1]+2	,aTamVlr[2]})
AADD(aCampos,{"CTB_EMPORI"	,"C"	,TamSX3("CTB_EMPORI")[1]+2	,0})
AADD(aCampos,{"CTB_FILORI"	,"C"	,TamSX3("CTB_FILORI")[1]+2	,0})


nPos := 2
For nZ:= 1 To nQtdeEnt
	cEntidade := StrZero(nZ,2)
	If nZ >= 5
		AADD(aCposEnt,{	'CVX_NIV'+cEntidade,;	 			// 1 - Nome campo temporario
		'CTB_E'+cEntidade+'DES',;			// 2 - Nome do campo entidade DESTINO
		'CTB_E'+cEntidade+'INI',;			// 3 - Nome do campo entidade INICIO
		'CTB_E'+cEntidade+'FIM',;			// 4 - Nome do campo entidade FIM
		CtbCposCrDb("CT2","D", cEntidade),;	// 5 - Nome do campo tabela CT2 entidade DEBITO
		CtbCposCrDb("CT2","C", cEntidade)})	// 6 - Nome do campo tabela CT2 entidade CREDITO
	EndIf
	cSelect += aCposEnt[nZ][2]+ Iif(nZ<nQtdeEnt,',','')
	cWhere  += "and ( ("+aCposEnt[nZ][1]+" between "+aCposEnt[nZ][3]+" and "+aCposEnt[nZ][4]+" and "+aCposEnt[nZ][3]+"<>' ' and "+aCposEnt[nZ][4]+"<>' ') or ( ("+aCposEnt[nZ][3]+"=' ' or "+aCposEnt[nZ][4]+"=' ') and "+aCposEnt[nZ][1]+"=' ' ) )"+CRLF
	
	AADD(aCampos,{aCposEnt[nZ][nPos],"C",TamSX3(aCposEnt[nZ][nPos])[1],0})
	
	//             campo CT2       campo QUERY
	AADD(aCpoDeb,{aCposEnt[nZ][5],aCposEnt[nZ][nPos]})
	AADD(aCpoCrd,{aCposEnt[nZ][6],aCposEnt[nZ][nPos]})
	
Next nZ

cTmp1 := CriaTrab( nil, .F. )
If CT231CrTB(cTmp1,aCampos)

	For nX:=1 to Len(aEmpOri)
		
		cQuery += "insert into "+cTmp1+" (CVX_SLDCRD,CVX_SLDDEB," + cSelect + ") "
		cQuery += "SELECT SUM(CVX_SLDCRD) CVX_SLDCRD,SUM(CVX_SLDDEB) CVX_SLDDEB,"
		cQuery += cSelect
		cQuery += " from "+aEmpOri[nX,2,2]+" CVX, "+cAliasCTB+" CTB"+CRLF
		cQuery += " where CVX.D_E_L_E_T_ = ' ' and CTB.D_E_L_E_T_ = ' '"+CRLF
		cQuery += " and CVX_FILIAL=CTB_FILORI"+CRLF
		cQuery += " and CTB_EMPORI='"+aEmpOri[nX,1]+"'"+CRLF
		cQuery += " and CVX_TPSALD=CTB_TPSLDO"+CRLF
		cQuery += " and CTB_CODIGO between '"+mv_par12+"' and '"+mv_par13+"'"+CRLF
		cQuery += cWhere
		
		If mv_par07<>'*'
			cQuery += " and CVX_TPSALD='"+mv_par07+"'"+CRLF
		EndIf
		
		If mv_par05 == 2
			cQuery += " and CVX_MOEDA='"+cMoeda+"'"+CRLF
		Endif
		
		cQuery += "	and CVX_DATA  <= '"+cDataSld+"'"+CRLF
		cQuery += "	and CVX_CONFIG  = '"+StrZero(nQtdeEnt,2)+"'"+CRLF
		
		cQuery += " GROUP BY "+ cSelect
		
		if TcSqlExec(cQuery)<>0
			if !__lBlind
				MsgAlert("Erro atualizando arquivo temp funcao Ct231SldIni : "+TCSqlError())
			endif
			conout("Erro atualizando arquivo temp funcao Ct231SldIni : "+TCSqlError())
		endif
		
		cQuery:= ""
		
	Next nX
	
	cQry += "SELECT SUM(CVX_SLDCRD) CVX_SLDCRD,SUM(CVX_SLDDEB) CVX_SLDDEB,"
	cQry += cSelect
	cQry += " FROM " + cTmp1
	cQry += " GROUP BY "+ cSelect
	cQry := ChangeQuery(cQry)
	cQryAlias := GetNextAlias()
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),cQryAlias,.T.,.T.)
	TCSetField(cQryAlias,"CVX_SLDCRD", "N",aTamVlr[1],aTamVlr[2])
	TCSetField(cQryAlias,"CVX_SLDDEB", "N",aTamVlr[1],aTamVlr[2])
	
	DbSelectArea(cQryAlias)
	DbGoTop()
	While (cQryAlias)->(!Eof())
		
		nLinha := Val(cLinha)
		
		If lFirst .or. nLinha > nMAX_LINHA
			
			//Gera numero de Lote e Documento na validacao da Data
			C050Next(Stod(cDataSld),@cLote,@cSubLote,@cDoc,,,,@CTF_LOCK,3,1)
			
			lFirst := .F.
			cLinha := "001"
			nLinha := 0
			cSeqLan:= "001"
		Else
			cSeqLan	:= Soma1(cSeqLan)
			cLinha	:= Soma1(cLinha)
		EndIf
		
		//Debito
		If (cQryAlias)->CVX_SLDDEB > 0
			
			Ct231GrvCT2(Stod(cDataSld),cLote,cSubLote,cDoc,'01'/*cMoedaLanc*/,'1',cLinha,(cQryAlias)->CVX_SLDDEB,(cQryAlias)->CTB_EMPORI,(cQryAlias)->CTB_FILORI,'1'/*cTpSaldo*/,StrZero(1,3),cSeqLan,aCpoDeb,cQryAlias)
			
		EndIf
		
		nLinha := Val(cLinha)
		
		If lFirst .or. nLinha > nMAX_LINHA
			
			//Gera numero de Lote e Documento na validacao da Data
			C050Next(Stod(cDataSld),@cLote,@cSubLote,@cDoc,,,,@CTF_LOCK,3,1)
			
			lFirst := .F.
			cLinha := "001"
			nLinha := 0
			cSeqLan:= "001"
		Else
			cSeqLan	:= Soma1(cSeqLan)
			cLinha	:= Soma1(cLinha)
		EndIf
		
		//Credito
		If (cQryAlias)->CVX_SLDCRD > 0
			
			Ct231GrvCT2(Stod(cDataSld),cLote,cSubLote,cDoc,'01'/*cMoedaLanc*/,'2',cLinha,(cQryAlias)->CVX_SLDCRD,(cQryAlias)->CTB_EMPORI,(cQryAlias)->CTB_FILORI,'1'/*cTpSaldo*/,StrZero(1,3),cSeqLan,aCpoCrd,cQryAlias)
			
		EndIf
		
		(cQryAlias)->(DbSkip())
		
	EndDo
	
	If Select(cQryAlias) > 0
		DbSelectArea(cQryAlias)
		DbCloseArea()
	EndIf
	MsErase(cTmp1,,"TOPCONN")
EndIf



Return()

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒø±±
±±≥ FunáÖo    ≥Ct231GrvCT2 ≥ Autor  ≥ TOTVS                   ≥ Data 20.05.10≥±±
±±√ƒƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ DescriáÖo ≥ Grava registro no CT2                                        ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Sintaxe    ≥ Ct231GrvCT2                                                  ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Retorno    ≥ Nenhum                                                       ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥  Uso      ≥ SigaCTB                                                      ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ ParÑmetros≥ExpD1 = Data do lancamento                                    ≥±±
±±≥           ≥ExpC2 = Numero do lote                                        ≥±±
±±≥           ≥ExpC3 = Numero do sub-lote                                    ≥±±
±±≥           ≥ExpC4 = Numero do documento                                   ≥±±
±±≥           ≥ExpC5 = Codigo da moeda                                       ≥±±
±±≥           ≥ExpC6 = tipo do lancamento 1-Debito e 2-Credito               ≥±±
±±≥           ≥ExpC7 = Numero da linha do lancamento                         ≥±±
±±≥           ≥ExpN8 = Valor                                                 ≥±±
±±≥           ≥ExpC9 = Empresa origem                                        ≥±±
±±≥           ≥ExpC10= Filial origem                                         ≥±±
±±≥           ≥ExpC11= Tipo do saldo                                         ≥±±
±±≥           ≥ExpC12= Sequencia do historico                                ≥±±
±±≥           ≥ExpC13= Sequencia do lancamento                               ≥±±
±±≥           ≥ExpA14= Array com campos do CT2 e da query                    ≥±±
±±≥           ≥ExpC15= Alias da query                                        ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Static Function Ct231GrvCT2(cData,cLote,cSbLote,cDoc,cMoedaLanc,cTpDC,cLinha,nValor,c_EmpOri,c_FilOri,cTpSaldo,cSeqHist,cSeqLan,aCpos,cQryAlias)
Local aAreaAtu	:= GetArea()
Local nCp		:= 0

DbSelectArea('CT2')
RecLock('CT2',.T.)
CT2->CT2_FILIAL	:= xFilial('CT2')
CT2->CT2_DATA	:= cData
CT2->CT2_LOTE	:= cLote
CT2->CT2_SBLOTE	:= cSbLote
CT2->CT2_DOC	:= cDoc
CT2->CT2_MOEDLC	:= cMoedaLanc
CT2->CT2_DC		:= cTpDC
CT2->CT2_VALOR	:= nValor
CT2->CT2_HIST	:= 'Saldo Inicial'
CT2->CT2_EMPORI	:= c_EmpOri
CT2->CT2_FILORI	:= c_FilOri
CT2->CT2_TPSALD	:= cTpSaldo
CT2->CT2_MANUAL	:= '1'
CT2->CT2_ROTINA	:= 'CTBA231'
CT2->CT2_AGLUT	:= '1'
CT2->CT2_SEQHIS	:= cSeqHist
CT2->CT2_SEQLAN	:= cSeqLan
CT2->CT2_LINHA	:= cLinha
CT2->CT2_CRCONV	:= '1'
CT2->CT2_CTLSLD	:= '0'

For nCp:=1 To Len(aCpos)
	CT2->&(aCpos[nCp][1]) := (cQryAlias)->&(aCpos[nCp][2])
Next nCp

MsUnlock()

RestArea(aAreaAtu)
Return()

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥Ct231VldSld  ∫Autor  ≥Microsiga        ∫ Data ≥  04/19/11   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥Valida se saldos destinos s„o iguais                        ∫±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ AP                                                         ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function Ct231VldSld()
Local lRet := .T.
Local cTpSald := ""

dbSelectArea("CTB")
dbSetOrder(1)
If !Empty(mv_par12)
	If !dbSeek(xFilial("CTB")+mv_par12)
		MsgInfo(STR0026)  //"Roteiro Inicial n„o encontrado. Verifique!"
		lRet := .F.
	EndIf
Else
	If Empty(mv_par13)
		MsgInfo(STR0027)  //"Roteiro Final n„o preenchido. Verifique!"
		lRet := .F.
	Else
		If !dbSeek(xFilial("CTB")+mv_par13)
			MsgInfo(STR0028)  //"Roteiro Final n„o encontrado. Verifique!"
			lRet := .F.
		EndIf
	EndIf
	If lRet
		dbSeek(xFilial("CTB"))
		mv_par12 := CTB_CODIGO  //qdo nao informado roteiro inicial posiciona com xFilial e pega o primeiro
	EndIf
EndIf
If lRet
	cTpSald := CTB->CTB_TPSLDE
	CTB->(dbSkip())
	While CTB->(!Eof() .And. CTB_CODIGO >= mv_par12 .And.  CTB_CODIGO <= mv_par13)
		If cTpSald != CTB->CTB_TPSLDE
			MsgInfo(STR0029) //"Tipo de saldo destino deve ser igual para todos os roteiros na consolidacao configurada. Verifique!"
			lRet := .F.
			Exit
		EndIf
		CTB->(dbSkip())
	EndDo
EndIf

Return(lRet) 

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥CT231TbCTB∫Autor  ≥Alvaro Camillo Neto ∫ Data ≥  17/04/12   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ Retorna uma cÛpia da tabela CTB mas com o campo CTB_CT2FIL ∫±±
±±∫          ≥ tratado com a filial da tabela CT2 da empresa origem       ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ AP                                                         ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function CT231TbCTB(cAliasCTB,aEmpCT2)
Local lRet		:= .T.
Local aArea		:= GetArea()
Local aAreaCTB	:= CTB->(GetArea())
Local aStruct	:= CTB->(dbStruct())
Local nX		:= 0                                       
Local nPos		:= 0
Local aAux		:= {}
Local cModoEmp	:= ""
Local cModoUn	:= ""
Local cModoFil	:= ""
Local cConteudo := ""

cAliasCTB := GetNextAlias() 

MsErase(cAliasCTB,,"TOPCONN")
MsCreate(cAliasCTB, aStruct, 'TOPCONN' ) 
dbUseArea( .T., 'TOPCONN', cAliasCTB, cAliasCTB, .T., .F. ) 
dbSelectArea( cAliasCTB ) 
CTB->(dbGoTop())
While CTB->(!EOF())
	If CTB->CTB_FILIAL == xFilial("CTB") .And. CTB->CTB_CODIGO >= MV_PAR12 .And. CTB->CTB_CODIGO <= MV_PAR13 
		RecLock(cAliasCTB,.T.)
		For nX := 1 to Len(aStruct)
			cConteudo := ""

			If aStruct[nX][1] == "CTB_CT1FIM" 
				cConteudo := CTB->&(aStruct[nX][1])
				(cAliasCTB)->&(aStruct[nX][1]) := C231RetRg(@cConteudo,aStruct[nX][3])				
			EndIf

			If Empty(cConteudo) .And. aStruct[nX][1] == "CTB_CTTFIM" 
				cConteudo := CTB->&(aStruct[nX][1])
				(cAliasCTB)->&(aStruct[nX][1]) := C231RetRg(@cConteudo,aStruct[nX][3])	
			EndIf

			If Empty(cConteudo) .And. aStruct[nX][1] == "CTB_CTDFIM" 
				cConteudo := CTB->&(aStruct[nX][1])
				(cAliasCTB)->&(aStruct[nX][1]) := C231RetRg(@cConteudo,aStruct[nX][3])	
			EndIf
			
			If Empty(cConteudo) .And. aStruct[nX][1] == "CTB_CTHFIM" 
				cConteudo := CTB->&(aStruct[nX][1])
				(cAliasCTB)->&(aStruct[nX][1]) := C231RetRg(@cConteudo,aStruct[nX][3])	
			EndIf

			If __lCtbIsCube
				If Empty(cConteudo) .And. aStruct[nX][1] == "CTB_E05FIM" 
					cConteudo := CTB->&(aStruct[nX][1])
					(cAliasCTB)->&(aStruct[nX][1]) := C231RetRg(@cConteudo,aStruct[nX][3])	
				EndIf
				
				If Empty(cConteudo) .And. aStruct[nX][1] == "CTB_E06FIM" 
					cConteudo := CTB->&(aStruct[nX][1])
					(cAliasCTB)->&(aStruct[nX][1]) := C231RetRg(@cConteudo,aStruct[nX][3])	
				EndIf
				
				If Empty(cConteudo) .And. aStruct[nX][1] == "CTB_E07FIM" 
					cConteudo := CTB->&(aStruct[nX][1])
					(cAliasCTB)->&(aStruct[nX][1]) := C231RetRg(@cConteudo,aStruct[nX][3])	
				EndIf
				
				If Empty(cConteudo) .And. aStruct[nX][1] == "CTB_E08FIM" 
					cConteudo := CTB->&(aStruct[nX][1])
					(cAliasCTB)->&(aStruct[nX][1]) := C231RetRg(@cConteudo,aStruct[nX][3])	
				EndIf

				If Empty(cConteudo) .And. aStruct[nX][1] == "CTB_E09FIM" 
					cConteudo := CTB->&(aStruct[nX][1])
					(cAliasCTB)->&(aStruct[nX][1]) := C231RetRg(@cConteudo,aStruct[nX][3])	
				EndIf
			EndIf


			If Empty(cConteudo)
				If aStruct[nX][1] == "CTB_CT2FIL"

					nPos := AScan(aEmpCT2 ,{|x| Alltrim(x[1]) == AllTrim(CTB->CTB_EMPORI)})

					If nPos > 0

						aAux := aEmpCT2[nPos][2] 

						cModoEmp := aAux[1]
						cModoUn  := aAux[2]
						cModoFil := aAux[3]

						(cAliasCTB)->CTB_CT2FIL := FWXFilial("CT2",CTB->CTB_FILORI,cModoEmp,cModoUN,cModoFil)

					Else

						lRet := .F.
						Help(" ",1,"CT231TbCTB",,STR0034,1,0) //"Problema na leitura da tabela CTB no preparo para execuÁ„o."
						Exit

					EndIf

				Else
					(cAliasCTB)->&(aStruct[nX][1]) := CTB->&(aStruct[nX][1])
				EndIf
			EndIf			

		Next nX

		MsUnLock()
	EndIf
	CTB->(dbSkip())
EndDo

(cAliasCTB)->(dbCloseArea())
RestArea(aAreaCTB)
RestArea(aArea)

Return lRet

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥CTBA231   ∫Autor  ≥Microsiga           ∫ Data ≥  04/17/12   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥                                                            ∫±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ AP                                                        ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function CT231CrTB(cTmp,aCampos)
Local lRet := .T.
Local cSQL := ""
Local nX   := 0

cSQL += 'CREATE TABLE '+cTmp+' ( ' 
For nX := 1 to Len(aCampos)
	cSQL += ' ' +aCampos[nX][1]
	If aCampos[nX][2] == "N" 
		cSQL += ' numeric'
		cSQL += '(' + cValtoChar(aCampos[nX][3]) + ',' + cValtoChar(aCampos[nX][4]) + ') '
	Else
		cSQL += ' varchar'
		cSQL += '(' + cValtoChar(aCampos[nX][3]) + ') '
	EndIf
	cSQL += ","
Next nX
cSQL := Left(cSQL,Len(cSQL)-1)
cSQL += ')'

if TcSqlExec(cSQL)<>0
	if !__lBlind
		MsgAlert(STR0019+" "+cTmp+": "+TCSqlError())  //'Erro criando a tabela temporaria'
	endif
	conout(STR0019+" "+cTmp+": "+TCSqlError())  //'Erro criando a tabela temporaria:'
	lRet := .F.
endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} C231RetRg
Retorna o valor m·ximo zzz formatado com o tamanho do campo

@author TOTVS
@since 18/09/2023
@version 12
@param
/*/
//-------------------------------------------------------------------
Static Function C231RetRg(cConteudo,nTamCpo)
DEFAULT cConteudo := ""
DEFAULT nTamCpo := 0

If Empty(cConteudo)
	cConteudo := Replicate('z',nTamCpo)
EndIf

Return cConteudo

//-------------------------------------------------------------------
/*/{Protheus.doc} C231RetRg
Retorna o valor m·ximo zzz formatado com o tamanho do campo

@author TOTVS
@since 18/09/2023
@version 12
@param
/*/
//-------------------------------------------------------------------
Static Function New231SlInP(aEmpOri as Array, cAliasCTB as Character)
Local cDataSld	as Character
Local aResult	as Array
Local lRet		as Logical

DEFAULT aEmpOri	:= {}
DEFAULT cAliasCTB := ""

cCTB231B := GetSPName("CTBA231B","36")
If ExistProc(cCTB231B,EngSPS36Signature())	
	
	C231DelTRB("TRB"+cEmpAnt+"0_36SP")	
	cDataSld := DTOS(mv_par02-1)
	
	//Prepara arquivo tempor·rio antes de chamar a procedure
	If C231PrpTmp(cAliasCTB, aEmpOri, cDataSld, .T.)		
		aResult := TCSPExec(xProcedures(cCTB231B),cFilAnt,;
										IIf(mv_par05==2,"1","0"),;
										mv_par09,;
										mv_par10,;
										mv_par11,;
										nMAX_LINHA,;
										IIf(InTransAct(),'1','0'))
		If Empty(aResult)
			If !__lBlind
				MsgAlert(STR0021+" "+cCTB231B+": "+TCSqlError())  //'Erro executando a Stored Procedure'
			EndIf			
			lRet := .F.
		ElseIf aResult[1] != 1
			If !__lBlind
				MsgAlert(STR0022+": "+cValtoChar(aResult[1]))   //'Erro na consolidacao'
			EndIf			
			lRet := .F.
		EndIf
	EndIf	
EndIf

Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} C231PrpTmp
Prepara o arquivo tempor·rio com os saldos iniciais

@author TOTVS
@since 18/09/2023
@version 12
@param
/*/
//-------------------------------------------------------------------
Static Function C231PrpTmp(cAliasCTB as Character, aEmpOri as Array, cDataSld as Character, lSldIni as Logical)
Local nX 	as Numeric
Local lRet 	as Logical 

DEFAULT cAliasCTB := ""
DEFAULT aEmpOri	 := {}
DEFAULT cDataSld := ""
DEFAULT lSldIni	 := .F.

For nX:=1 to Len(aEmpOri)
	If lSldIni
		lRet := GrvSldIni(cAliasCTB, aEmpOri[nX,1], mv_par12, mv_par13, cDataSld, aEmpOri[nX,3,2], aEmpOri[nX,4,2], aEmpOri[nX,5,2], aEmpOri[nX,6,2])
	Else
		lRet := GrvMovCT2(cAliasCTB, aEmpOri[nX,1], mv_par12, mv_par13, aEmpOri[nX,2,2])
	EndIf
Next nX

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GrvSldIni
Grava os saldos iniciais no tempor·rio 

@author TOTVS
@since 18/09/2023
@version 12
@param
/*/
//-------------------------------------------------------------------
Static Function GrvSldIni(cAliasCTB as Character, cEmpOri as Character, cCodIni as Character, cCodFim as Character, cDataSld as Character, cAliasCQ7 as Character,;
							cAliasCQ5 as Character, cAliasCQ3 as Character, cAliasCQ1 as Character)
Local cQuery  as Character
Local lRet    as Logical
Local lSQL	  as Logical

Default cAliasCTB := ""
Default cEmpOri := ""
Default cCodIni := ""
Default cCodFim := ""
Default cDataSld := ""
Default cAliasCQ7 := ""
Default cAliasCQ5 := ""
Default cAliasCQ3 := ""
Default cAliasCQ1 := ""

cQuery := ""
lSQL   := C231IsSQL()

If !lSQL
	cQuery += " INSERT INTO TRB"+cEmpAnt+"0_36SP "+CRLF+;
				" ( EMPORI, FILORI, MOEDA, TPSALD, CONTA, CUSTO, ITEM, CLVL, CONTA_ORI, CUSTO_ORI, ITEM_ORI, CLVL_ORI, DTLP, LP, "+CRLF+;
				"   DEBITO, CREDITO, CDATA, FLAG ) "+CRLF+;
				" SELECT "+CRLF+;
				"	EMPORI, FILORI, MOEDA, TPSALD, CONTA, CUSTO, ITEM, CLVL, CONTA_ORI, CUSTO_ORI, ITEM_ORI, CLVL_ORI, DTLP, LP, "+CRLF+;
				"	DEBITO, CREDITO, CDATA, FLAG "+CRLF+;
				" FROM ( "+CRLF
EndIf

cQuery += 	" WITH "+CRLF+;
			" CTB_BASE AS ( "+CRLF+;
			"	SELECT "+CRLF+;
			"		CTB.CTB_EMPORI, "+CRLF+;
			"		CTB.CTB_FILORI, "+CRLF+;
			"		CTB.CTB_TPSLDE, "+CRLF+;
			"		CTB.CTB_TPSLDO, "+CRLF+;
			"		CTB.CTB_CTADES, "+CRLF+;
			"		CTB.CTB_CCDES, "+CRLF+;
			"		CTB.CTB_ITEMDE, "+CRLF+;
			"		CTB.CTB_CLVLDE, "+CRLF+;
			"		CTB.CTB_CT1INI, "+CRLF+;
			"		CTB.CTB_CT1FIM, "+CRLF+;
			"		CTB.CTB_CTTINI, "+CRLF+;
			"		CTB.CTB_CTTFIM, "+CRLF+;
			"		CTB.CTB_CTDINI, "+CRLF+;
			"		CTB.CTB_CTDFIM, "+CRLF+;
			"		CTB.CTB_CTHINI, "+CRLF+;
			"		CTB.CTB_CTHFIM, "+CRLF+;
			"		CTB.D_E_L_E_T_ "+CRLF+;
			"	FROM "+cAliasCTB+" CTB "+CRLF+;
			"	WHERE "+CRLF+;
			"		CTB.CTB_FILIAL = '"+xFilial("CTB")+"' "+CRLF+;			
			"		AND CTB.CTB_EMPORI = '"+cEmpOri+"' "+CRLF+;
			"		AND CTB.CTB_CODIGO BETWEEN '"+cCodIni+"' AND '"+cCodFim+"' "+CRLF

If mv_par07 <> '*'
	cQuery += "     AND CTB_TPSLDO = '"+mv_par07+"' "+CRLF
EndIf

cQuery +=   "		AND CTB.D_E_L_E_T_ = ' ' "+CRLF+;
			" ) "+CRLF

If lSQL
	cQuery += " INSERT INTO TRB"+cEmpAnt+"0_36SP "+CRLF+;
			  " ( EMPORI, FILORI, MOEDA, TPSALD, CONTA, CUSTO, ITEM, CLVL, CONTA_ORI, CUSTO_ORI, ITEM_ORI, CLVL_ORI, DTLP, LP, "+CRLF+;
			  "   DEBITO, CREDITO, CDATA, FLAG ) "+CRLF			 
EndIf

cQuery += C231QrySld("CQ7", cAliasCQ7, cDataSld)
cQuery += " UNION ALL "+CRLF
cQuery += C231QrySld("CQ5", cAliasCQ5, cDataSld)
cQuery += " UNION ALL "+CRLF
cQuery += C231QrySld("CQ3", cAliasCQ3, cDataSld)
cQuery += " UNION ALL "+CRLF
cQuery += C231QrySld("CQ1", cAliasCQ1, cDataSld)

If !lSQL
	cQuery += " ) TABTRB "
EndIf

lRet := TcSqlExec(cQuery) == 0

If !lRet
	UserException(TCSqlError())	
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} C231QrySld
Monta a query de seleÁ„o dos dados de saldo inicial conforme o alias passado

@author TOTVS
@since 18/09/2023
@version 12
@param
/*/
//-------------------------------------------------------------------
Static Function C231QrySld(cAliasQry as Character, cTableCQ as Character, cDataSld as Character)
Local cRetSQL  as Character
Local cSelect  as Character
Local cJoinOn  as Character
Local cGroupBy as Character

Default cAliasQry := ""
Default cTableCQ  := ""
Default cDataSld  := ""

If cAliasQry == "CQ7"
	cSelect := 	"		"+cAliasQry+"."+cAliasQry+"_CONTA   AS CONTA_ORI, "+CRLF+;
				"		"+cAliasQry+"."+cAliasQry+"_CCUSTO  AS CUSTO_ORI, "+CRLF+;
				"		"+cAliasQry+"."+cAliasQry+"_ITEM    AS ITEM_ORI, "+CRLF+;
				"		"+cAliasQry+"."+cAliasQry+"_CLVL    AS CLVL_ORI, "+CRLF

	cJoinOn :=	"		AND (("+cAliasQry+"."+cAliasQry+"_CONTA  BETWEEN CTB.CTB_CT1INI AND CTB.CTB_CT1FIM AND CTB.CTB_CT1INI <> ' ' AND CTB.CTB_CT1FIM <> ' ' ) OR ( (CTB_CT1INI=' ' or CTB_CT1FIM=' ') and "+cAliasQry+"."+cAliasQry+"_CONTA=' ' ) )"+CRLF+;
				"		AND (("+cAliasQry+"."+cAliasQry+"_CCUSTO BETWEEN CTB.CTB_CTTINI AND CTB.CTB_CTTFIM AND CTB.CTB_CTTINI <> ' ' AND CTB.CTB_CTTFIM <> ' ' ) OR ( (CTB_CTTINI=' ' or CTB_CTTFIM=' ') and "+cAliasQry+"."+cAliasQry+"_CCUSTO=' ' ) )"+CRLF+;
				"		AND (("+cAliasQry+"."+cAliasQry+"_ITEM   BETWEEN CTB.CTB_CTDINI AND CTB.CTB_CTDFIM AND CTB.CTB_CTDINI <> ' ' AND CTB.CTB_CTDFIM <> ' ' ) OR ( (CTB_CTDINI=' ' or CTB_CTDFIM=' ') and "+cAliasQry+"."+cAliasQry+"_ITEM=' ' ) )"+CRLF+;
				"		AND (("+cAliasQry+"."+cAliasQry+"_CLVL   BETWEEN CTB.CTB_CTHINI AND CTB.CTB_CTHFIM AND CTB.CTB_CTHINI <> ' ' AND CTB.CTB_CTHFIM <> ' ' ) OR ( (CTB_CTHINI=' ' or CTB_CTHFIM=' ') and "+cAliasQry+"."+cAliasQry+"_CLVL=' ' ) )"+CRLF

	cGroupBy :=	"		"+cAliasQry+"."+cAliasQry+"_CONTA, "+CRLF+;
				"		"+cAliasQry+"."+cAliasQry+"_CCUSTO, "+CRLF+;
				"		"+cAliasQry+"."+cAliasQry+"_ITEM, "+CRLF+;
				"		"+cAliasQry+"."+cAliasQry+"_CLVL "+CRLF
ElseIf cAliasQry == "CQ5"
	cSelect := 	"		"+cAliasQry+"."+cAliasQry+"_CONTA   AS CONTA_ORI, "+CRLF+;
				"		"+cAliasQry+"."+cAliasQry+"_CCUSTO  AS CUSTO_ORI, "+CRLF+;
				"		"+cAliasQry+"."+cAliasQry+"_ITEM    AS ITEM_ORI, "+CRLF+;
				"		' ' AS CLVL_ORI, "+CRLF
				
	cJoinOn :=	"		AND (("+cAliasQry+"."+cAliasQry+"_CONTA  BETWEEN CTB.CTB_CT1INI AND CTB.CTB_CT1FIM AND CTB.CTB_CT1INI <> ' ' AND CTB.CTB_CT1FIM <> ' ' ) OR ( (CTB_CT1INI=' ' or CTB_CT1FIM=' ') and "+cAliasQry+"."+cAliasQry+"_CONTA=' ' ) )"+CRLF+;
				"		AND (("+cAliasQry+"."+cAliasQry+"_CCUSTO BETWEEN CTB.CTB_CTTINI AND CTB.CTB_CTTFIM AND CTB.CTB_CTTINI <> ' ' AND CTB.CTB_CTTFIM <> ' ' ) OR ( (CTB_CTTINI=' ' or CTB_CTTFIM=' ') and "+cAliasQry+"."+cAliasQry+"_CCUSTO=' ' ) )"+CRLF+;
				"		AND (("+cAliasQry+"."+cAliasQry+"_ITEM   BETWEEN CTB.CTB_CTDINI AND CTB.CTB_CTDFIM AND CTB.CTB_CTDINI <> ' ' AND CTB.CTB_CTDFIM <> ' ' ) OR ( (CTB_CTDINI=' ' or CTB_CTDFIM=' ') and "+cAliasQry+"."+cAliasQry+"_ITEM=' ' ) )"+CRLF+;
				"		AND ( CTB_CTHINI = ' ' OR CTB_CTHFIM = ' ' ) "+CRLF		

	cGroupBy :=	"		"+cAliasQry+"."+cAliasQry+"_CONTA, "+CRLF+;
				"		"+cAliasQry+"."+cAliasQry+"_CCUSTO, "+CRLF+;
				"		"+cAliasQry+"."+cAliasQry+"_ITEM "+CRLF	
ElseIf cAliasQry == "CQ3"
	cSelect := 	"		"+cAliasQry+"."+cAliasQry+"_CONTA   AS CONTA_ORI, "+CRLF+;
				"		"+cAliasQry+"."+cAliasQry+"_CCUSTO  AS CUSTO_ORI, "+CRLF+;
				"		' ' AS ITEM_ORI, "+CRLF+;
				"		' ' AS CLVL_ORI, "+CRLF
				
	cJoinOn :=	"		AND (("+cAliasQry+"."+cAliasQry+"_CONTA BETWEEN CTB.CTB_CT1INI AND CTB.CTB_CT1FIM AND CTB.CTB_CT1INI <> ' ' AND CTB.CTB_CT1FIM <> ' ' ) OR ( (CTB_CT1INI=' ' or CTB_CT1FIM=' ') and "+cAliasQry+"."+cAliasQry+"_CONTA=' ' ) )"+CRLF+;
				"		AND (("+cAliasQry+"."+cAliasQry+"_CCUSTO BETWEEN CTB.CTB_CTTINI AND CTB.CTB_CTTFIM AND CTB.CTB_CTTINI <> ' ' AND CTB.CTB_CTTFIM <> ' ' ) OR ( (CTB_CTTINI=' ' or CTB_CTTFIM=' ') and "+cAliasQry+"."+cAliasQry+"_CCUSTO=' ' ) )"+CRLF+;
				"		AND ( CTB_CTDINI = ' ' OR CTB_CTDFIM = ' ' ) "+CRLF+;
				"		AND ( CTB_CTHINI = ' ' OR CTB_CTHFIM = ' ' ) "+CRLF		

	cGroupBy :=	"		"+cAliasQry+"."+cAliasQry+"_CONTA, "+CRLF+;
				"		"+cAliasQry+"."+cAliasQry+"_CCUSTO "+CRLF
ElseIf cAliasQry == "CQ1"
	cSelect := 	"		"+cAliasQry+"."+cAliasQry+"_CONTA   AS CONTA_ORI, "+CRLF+;
				"		' ' AS CUSTO_ORI, "+CRLF+;
				"		' ' AS ITEM_ORI, "+CRLF+;
				"		' ' AS CLVL_ORI, "+CRLF
				
	cJoinOn :=	"		AND (("+cAliasQry+"."+cAliasQry+"_CONTA BETWEEN CTB.CTB_CT1INI AND CTB.CTB_CT1FIM AND CTB.CTB_CT1INI <> ' ' AND CTB.CTB_CT1FIM <> ' ' ) OR ( (CTB_CT1INI=' ' or CTB_CT1FIM=' ') and "+cAliasQry+"."+cAliasQry+"_CONTA=' ' ) )"+CRLF+;
				"		AND ( CTB_CTTINI = ' ' OR CTB_CTTFIM = ' ' ) "+CRLF+;
				"		AND ( CTB_CTDINI = ' ' OR CTB_CTDFIM = ' ' ) "+CRLF+;
				"		AND ( CTB_CTHINI = ' ' OR CTB_CTHFIM = ' ' ) "+CRLF

	cGroupBy :=	"		"+cAliasQry+"."+cAliasQry+"_CONTA "+CRLF				
EndIf	

cRetSQL :=  "	SELECT "+CRLF+;
			"		CTB.CTB_EMPORI  AS EMPORI, "+CRLF+;
			"		CTB.CTB_FILORI  AS FILORI, "+CRLF+;
			"		"+cAliasQry+"."+cAliasQry+"_MOEDA   AS MOEDA, "+CRLF+;
			"		CTB.CTB_TPSLDE  AS TPSALD, "+CRLF+;
			"		CTB.CTB_CTADES  AS CONTA, "+CRLF+;
			"		CTB.CTB_CCDES   AS CUSTO, "+CRLF+;
			"		CTB.CTB_ITEMDE  AS ITEM, "+CRLF+;
			"		CTB.CTB_CLVLDE  AS CLVL, "+CRLF

cRetSQL += cSelect+CRLF		
	
cRetSQL +=	"		"+cAliasQry+"."+cAliasQry+"_DTLP    AS DTLP, "+CRLF+;
			"		"+cAliasQry+"."+cAliasQry+"_LP      AS LP, "+CRLF+;
			"		SUM("+cAliasQry+"."+cAliasQry+"_DEBITO) AS DEBITO, "+CRLF+;
			"		SUM("+cAliasQry+"."+cAliasQry+"_CREDIT) AS CREDITO, "+CRLF+;
			"		'"+cDataSld+"' AS CDATA, "+CRLF+;
			"		1          AS FLAG "+CRLF+;
			"	FROM "+cTableCQ+" "+cAliasQry+" "+CRLF+;
			"	INNER JOIN CTB_BASE CTB "+CRLF+;
			"		ON  CTB.CTB_FILORI = "+cAliasQry+"."+cAliasQry+"_FILIAL "+CRLF+;
			"		AND CTB.CTB_TPSLDO = "+cAliasQry+"."+cAliasQry+"_TPSALD "+CRLF

cRetSQL += cJoinOn+CRLF		

cRetSQL +=	"	WHERE "+CRLF+"  "+cAliasQry+"."+cAliasQry+"_DATA <= '"+cDataSld+"' "+CRLF //Filtro novo - data saldo <= (data inicial -1)

If mv_par05 == 2
	cRetSQL += "    AND "+cAliasQry+"."+cAliasQry+"_MOEDA = '"+mv_par06+"' "+CRLF
Endif

cRetSQL +=	"		AND "+cAliasQry+".D_E_L_E_T_ = ' ' "+CRLF+;
			"	GROUP BY "+CRLF+;
			"		CTB.CTB_EMPORI, "+CRLF+;
			"		CTB.CTB_FILORI, "+CRLF+;
			"		"+cAliasQry+"."+cAliasQry+"_MOEDA, "+CRLF+;
			"		CTB.CTB_TPSLDE, "+CRLF+;
			"		CTB.CTB_CTADES, "+CRLF+;
			"		CTB.CTB_CCDES, "+CRLF+;
			"		CTB.CTB_ITEMDE, "+CRLF+;
			"		CTB.CTB_CLVLDE, "+CRLF+;	
			"		"+cAliasQry+"."+cAliasQry+"_DTLP, "+CRLF+;
			"		"+cAliasQry+"."+cAliasQry+"_LP, "+CRLF	

cRetSQL += cGroupBy+CRLF

Return cRetSQL

/*/-------------------------------------------------------------------
{Protheus.doc} New231ExeP
Chama a procedure de geraÁ„o do relatÛrio de saldos iniciais
@author TOTVS
@since 26/01/2025
@version 12
@param
/*/
//-------------------------------------------------------------------
Static Function New231ExeP(aEmpOri As Array, cAliasCTB As Character) 
Local cCTB231A 	as Character
Local aResult	as Array
Local lRet		as Logical
Local cAliasTmp as Character
Local aArea 	as Array
Local cNomeTab  as Character

DEFAULT aEmpOri	:= {}
DEFAULT cAliasCTB := ""


cCTB231A := GetSPName("CTBA231A","36")
If ExistProc(cCTB231A,EngSPS36Signature())	
	cNomeTab:= "TRU"+cEmpAnt+"0_36SP"
	C231DelTRB("TRA"+cEmpAnt+"0_36SP")
	C231DelTRB("TRU"+cEmpAnt+"0_36SP")	

	IF !TCCanOpen(cNomeTab, cNomeTab+'IND1')
		aArea := GetArea()
		cAliasTmp := GetNextAlias()
		DBUseArea(.F., 'TOPCONN', cNomeTab, cAliasTmp, .F., .T.)
		(cAliasTmp)->(dbCreateIndex(cNomeTab+'IND1', "CT2_FILIAL+CT2_DATA+CT2_LOTE+CT2_SBLOTE+CT2_DOC+CT2_EMPORI+CT2_FILORI"))
		RestArea(aArea)
		aSize(aArea,0)
		aArea := nil
	EndIf	

	//Prepara arquivo tempor·rio antes de chamar a procedure
	If C231PrpTmp(cAliasCTB, aEmpOri)	

		aResult := TCSPExec(xProcedures(cCTB231A), If(mv_par14==1,mv_par15,' '),;
													mv_par05,; 
													mv_par14,;
													cFilAnt,;
													IIf(InTransAct(),'1','0'))
		If Empty(aResult)
			If !__lBlind
				MsgAlert(STR0021+" "+cCTB231A+": "+TCSqlError())  //'Erro executando a Stored Procedure'
			EndIf			
			lRet := .F.
		ElseIf aResult[1] != 1
			If !__lBlind
				MsgAlert(STR0022+": "+cValtoChar(aResult[1]))   //'Erro na consolidacao'
			EndIf			
			lRet := .F.
		EndIf

	EndIf
EndIf	

Return 

/*/-------------------------------------------------------------------
{Protheus.doc} GrvMovCT2
Grava os dados de CT2 no tempor·rio
@author TOTVS
@since 26/01/2025
@version 12
@param
/*/
//-------------------------------------------------------------------
Static Function GrvMovCT2(cAliasCTB as Character, cEmpOri as Character, cCodIni as Character, cCodFim as Character, cAliasCT2 as Character)				
Local nI 		as Numeric
Local cQuery 	as Character
Local lRet		as Logical
Local cGroupEnt as Character
Local cSelectCTB as Character
Local cSelDebCT2 as character
Local cSelCrdCT2 as Character
Local cEntidade  as Character
Local cNomeEnt   as Character
Local cCaseWhen  as Character
Local cDataIni   as Character
Local cDataFim   as Character
Local cSelEntCTB as Character
Local lSQL       as Logical

DEFAULT cAliasCTB := ""
DEFAULT cEmpOri   := ""
DEFAULT cCodIni   := ""	
DEFAULT cCodFim   := ""
DEFAULT cAliasCT2 := ""

cSelectCTB := ""
cSelDebCT2 := ""
cSelCrdCT2 := ""
cSelEntCTB := ""
cGroupEnt  := ""
cQuery     := ""
cDataIni   := DtoS(mv_par02)
cDataFim   := DtoS(mv_par03)
lSQL 	   := C231IsSQL()

If __lCtbIsCube		
	For nI := 5 To __nQtdEnt
		cEntidade := StrZero(nI,2)			
	
		cNomeEnt  := "CTB_E"+cEntidade+"FIM"
		cCaseWhen := " CASE WHEN CTB."+cNomeEnt+" = ' ' THEN '"+Replicate("z",TamSX3(cNomeEnt)[1])+"' ELSE CTB."+cNomeEnt+" END AS "+cNomeEnt

		cSelectCTB += ", CTB.CTB_E"+cEntidade+"INI, "+CRLF+cCaseWhen+CRLF		

		cSelDebCT2 += " CTB_E"+cEntidade+"DES AS CTB_EC"+cEntidade+"DB,"+CRLF+" ' ' AS CTB_EC"+cEntidade+"CR,"+CRLF		
		cSelCrdCT2 += "	' ' AS CTB_EC"+cEntidade+"DB,"+CRLF+" CTB_E"+cEntidade+"DES AS CTB_EC"+cEntidade+"CR,"+CRLF

		cSelEntCTB += " CTB_EC"+cEntidade+"DB, CTB_EC"+cEntidade+"CR,"		
		
		cGroupEnt  += "CTB_E"+cEntidade+"DES, "	
	Next nI
EndIf

//========================= CTE do roteiro - InÌcio ========================================


If !lSQL
	cQuery +=	" INSERT INTO TRA"+cEmpAnt+"0_36SP "+;
				"	(EMPORI, FILORI, "
	If __lMultiRot
		cQuery += " CTB_CODIGO, "
	EndIf
	cQuery +=   " CTB_TPSLDO, CTB_CTADB, CTB_CCDB, CTB_ITEMDB, CTB_CLVLDB, CTB_CTACR, CTB_CCCR, CTB_ITEMCR, CTB_CLVLCR, "+cSelEntCTB+;
				" VALOR, CDATA, FORMUL, HAGLUT, HIST, DTLP, MOEDA, TIPO, LOTE, SBLOTE, DOC, LINHA, REC) "+CRLF+;
				" SELECT "+CRLF+;
				"	EMPORI, FILORI, "
	If __lMultiRot
		cQuery += " CTB_CODIGO, "
	EndIf

	cQuery +=   " CTB_TPSLDE, CTADB, CCDB, ITEMDB, CLVLDB, CTACR, CCCR, ITEMCR, CLVLCR, "+cSelEntCTB+;
				" VALOR, CDATA, FORMUL, HAGLUT, HIST, DTLP, MOEDA, TIPO, LOTE, SBLOTE, DOC, LINHA, REC "+CRLF+;			
				" FROM "+CRLF+;
				" ( 
EndIf				


cQuery +=   " WITH CTB_BASE AS ( "+CRLF+;
			"    SELECT  "+CRLF+;
			"		CTB.CTB_EMPORI, "+CRLF+;			
			"		CTB.CTB_FILORI, "+CRLF+;
			"		CTB.CTB_TPSLDE, "+CRLF+;
			"		CTB.CTB_CODIGO, "+CRLF+;
			"		CTB.CTB_TPSLDO, "+CRLF+;
			"		CTB.CTB_CTADES, "+CRLF+;
			"		CTB.CTB_CCDES, "+CRLF+;
			"		CTB.CTB_ITEMDE, "+CRLF+;
			"		CTB.CTB_CLVLDE, "+CRLF+;
			"		"+cGroupEnt+CRLF+;
			"		CTB.CTB_CT1INI, "+CRLF+;
			"		CTB.CTB_FORMUL, "+CRLF+;
			"		CTB.CTB_HAGLUT, "+CRLF+;
			"		CASE WHEN CTB.CTB_CT1FIM = ' ' THEN '"+Replicate("z",TamSX3("CTB_CT1FIM")[1])+"' ELSE CTB.CTB_CT1FIM END AS CTB_CT1FIM, "+CRLF+;
			"		CTB.CTB_CTTINI, "+CRLF+;
			"		CASE WHEN CTB.CTB_CTTFIM = ' ' THEN '"+Replicate("z",TamSX3("CTB_CTTFIM")[1])+"' ELSE CTB.CTB_CTTFIM END AS CTB_CTTFIM, "+CRLF+;
			"		CTB.CTB_CTDINI, "+CRLF+;
			"		CASE WHEN CTB.CTB_CTDFIM = ' ' THEN '"+Replicate("z",TamSX3("CTB_CTDFIM")[1])+"' ELSE CTB.CTB_CTDFIM END AS CTB_CTDFIM, "+CRLF+;
			"		CTB.CTB_CTHINI, "+CRLF+;
			"		CASE WHEN CTB.CTB_CTHFIM = ' ' THEN '"+Replicate("z",TamSX3("CTB_CTHFIM")[1])+"' ELSE CTB.CTB_CTHFIM END AS CTB_CTHFIM "+CRLF+;
			"      "+cSelectCTB+CRLF+;
			"    FROM "+cAliasCTB+" CTB "+CRLF+;
			"    WHERE "+CRLF+;
			"		CTB.CTB_FILIAL = '"+xFilial("CTB")+"' "+CRLF+;
			"		AND CTB.CTB_EMPORI = '"+cEmpOri+"' "+CRLF+;
			"		AND CTB.CTB_CODIGO BETWEEN '"+cCodIni+"' AND '"+cCodFim+"' "+CRLF

If mv_par07 <> '*'
	cQuery += "     AND CTB_TPSLDO = '"+mv_par07+"' "+CRLF
EndIf

cQuery +=   "		AND CTB.D_E_L_E_T_ = ' ' "+CRLF+;
			" ) "+CRLF
//========================= CTE do roteiro - Fim =========================================

cQuery += C231QryMov(cAliasCT2, cSelDebCT2, cSelCrdCT2, cSelEntCTB, cGroupEnt, lSQL)	

If !lSQL
	cQuery += " ) TABCTB "
EndIf

lRet := TcSqlExec(cQuery) == 0

If !lRet
	UserException(TCSqlError())
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} C231QryMov
Monta a query de seleÁ„o dos dados de movimento conforme o alias passado
@author TOTVS
@since 26/01/2025
@version 12
@param
/*/
//-------------------------------------------------------------------
Static Function C231QryMov(cAliasCT2 as Character, cSelDebCT2 as character, cSelCrdCT2 as Character, cSelEntCTB as Character, cGroupEnt as Character, lSQL as Logical)
Local cQuery 	as character
Local cEmpOri 	as character
Local cFilOri 	as character
Local cValor  	as character
Local cFormul 	as character
Local cHaglut 	as character
Local cHist   	as character
Local cLote		as character
Local cSub		as character
Local cDoc		as character
Local cLinha	as character
Local cRec		as character
Local cDeb		as character
Local cCrd		as character
Local cGroupBy 	as character
Local cDataIni  as character
Local cDataFim  as character

DEFAULT cAliasCT2  := ""
DEFAULT cSelDebCT2 := ""
DEFAULT cSelCrdCT2 := ""
DEFAULT cSelEntCTB := ""
DEFAULT cGroupEnt  := ""
DEFAULT lSQL       := .F.

cQuery 	 := ""
cGroupBy := ""

cDataIni   := DtoS(mv_par02)
cDataFim   := DtoS(mv_par03)

If mv_par14 == 1
	cEmpOri := "MAX(CTB.CTB_EMPORI)"
	cFilOri := "MAX(CTB.CTB_FILORI)"
	cValor  := "SUM(CT2.CT2_VALOR)"
	cFormul := "MAX(CTB.CTB_FORMUL)"
	cHaglut := "MAX(CTB.CTB_HAGLUT)"
	cHist   := "MAX(CT2.CT2_HIST)"
	cLote	:= "' '"
	cSub	:= "' '"
	cDoc	:= "' '"
	cLinha	:= "' '"
	cRec	:= "0"
	cDeb	:= "'1'"
	cCrd	:= "'2'"
	
	cGroupBy += "GROUP BY " + IIf(__lMultiRot, 'CTB_CODIGO, ', '') + "CTB_TPSLDE, CTB_CTADES, CTB_CCDES, CTB_ITEMDE, CTB_CLVLDE,"+cGroupEnt+" CT2_DATA, CT2_MOEDLC, CT2_DTLP"+CRLF	
Else
	cEmpOri := "CTB.CTB_EMPORI"
	cFilOri := "CTB.CTB_FILORI"
	cValor  := "CT2.CT2_VALOR"
	cFormul := "CTB.CTB_FORMUL"
	cHaglut := "CTB.CTB_HAGLUT"
	cHist   := "CT2.CT2_HIST"
	cLote	:= "CT2.CT2_LOTE"
	cSub	:= "CT2.CT2_SBLOTE"
	cDoc	:= "CT2.CT2_DOC"
	cLinha	:= "CT2.CT2_LINHA"
	cRec	:= "CT2.R_E_C_N_O_"
	cDeb	:= "CT2.CT2_DC"
	cCrd	:= "CT2.CT2_DC"
Endif

//========================= Query DÈbito - InÌcio ========================================

If lSQL 
	cQuery +=	" INSERT INTO TRA"+cEmpAnt+"0_36SP "+;
				"	(EMPORI, FILORI, "
	If __lMultiRot
		cQuery += " CTB_CODIGO, "
	EndIf
	cQuery +=   " CTB_TPSLDO, CTB_CTADB, CTB_CCDB, CTB_ITEMDB, CTB_CLVLDB, CTB_CTACR, CTB_CCCR, CTB_ITEMCR, CTB_CLVLCR, "+cSelEntCTB+;
				" VALOR, CDATA, FORMUL, HAGLUT, HIST, DTLP, MOEDA, TIPO, LOTE, SBLOTE, DOC, LINHA, REC) "+CRLF
EndIf				

cQuery +=   " SELECT "+CRLF+;
			"    "+cEmpOri+" AS EMPORI, "+CRLF+;
			"    "+cFilOri+" AS FILORI, "+CRLF

If __lMultiRot
	cQuery +=	"	CTB.CTB_CODIGO,"+CRLF
EndIf

cQuery +=	"    CTB.CTB_TPSLDE, "+CRLF+;
			"    CTB.CTB_CTADES AS CTADB, "+CRLF+;
			"    CTB.CTB_CCDES AS CCDB, "+CRLF+;
			"    CTB.CTB_ITEMDE AS ITEMDB, "+CRLF+;
			"    CTB.CTB_CLVLDE AS CLVLDB, "+CRLF+;
			"    ' ' AS CTACR, "+CRLF+;
			"    ' ' AS CCCR, "+CRLF+;
			"    ' ' AS ITEMCR, "+CRLF+;
			"    ' ' AS CLVLCR, "+CRLF+;
			"   "+cSelDebCT2+CRLF+;
			"    "+cValor+" AS VALOR, "+CRLF+;
			"    CT2.CT2_DATA AS CDATA, "+CRLF+;
			"    "+cFormul+" AS FORMUL, "+CRLF+;
			"    "+cHaglut+" AS HAGLUT, "+CRLF+;
			"    "+cHist+" AS HIST, "+CRLF+;
			"    CT2.CT2_DTLP AS DTLP, "+CRLF+;
			"    CT2.CT2_MOEDLC AS MOEDA, "+CRLF+;
			"    "+cDeb+" AS TIPO, "+CRLF+;
			"    "+cLote+" AS LOTE, "+CRLF+;
			"    "+cSub+" AS SBLOTE, "+CRLF+;
			"    "+cDoc+" AS DOC, "+CRLF+;
			"    "+cLinha+" AS LINHA, "+CRLF+;
			"    "+cRec+" AS REC "+CRLF+;
			" FROM "+cAliasCT2+" CT2 "+CRLF+;
			" INNER JOIN CTB_BASE CTB "+CRLF+;
			" ON CT2.CT2_FILIAL = CTB.CTB_FILORI "+CRLF+;
			" AND CT2.CT2_TPSALD = CTB.CTB_TPSLDO "+CRLF+;
			" AND CT2.CT2_DC IN ('1','3') "+CRLF+;
			" AND CT2.CT2_DEBITO BETWEEN CTB.CTB_CT1INI AND CTB.CTB_CT1FIM "+CRLF+;
			" AND CT2.CT2_CCD    BETWEEN CTB.CTB_CTTINI AND CTB.CTB_CTTFIM "+CRLF+;
			" AND CT2.CT2_ITEMD  BETWEEN CTB.CTB_CTDINI AND CTB.CTB_CTDFIM "+CRLF+;
			" AND CT2.CT2_CLVLDB BETWEEN CTB.CTB_CTHINI AND CTB.CTB_CTHFIM "+CRLF+;
			" WHERE CT2.CT2_DATA BETWEEN '"+cDataIni+"' AND '"+cDataFim+"' "+CRLF

If mv_par05 == 2
	cQuery += "AND CT2_MOEDLC= '"+mv_par06+"' "+CRLF
Endif

cQuery +=   " AND CT2.D_E_L_E_T_ = ' ' "+CRLF
			
cQuery += cGroupBy+CRLF			
//========================= Query DÈbito - Fim ==========================================

cQuery +=   " UNION ALL "+CRLF

//======================== Query CrÈdito - InÌcio ========================================
cQuery +=	" SELECT "+CRLF+;
			"    "+cEmpOri+" AS EMPORI, "+CRLF+;
			"    "+cFilOri+" AS FILORI, "+CRLF
If __lMultiRot
	cQuery +=	"	CTB.CTB_CODIGO,"+CRLF
EndIf		

cQuery +=	"    CTB.CTB_TPSLDE, "+CRLF+;
			"    ' ' AS CTADB, "+CRLF+;
			"    ' ' AS CCDB, "+CRLF+;
			"    ' ' AS ITEMDB, "+CRLF+;
			"    ' ' AS CLVLDB, "+CRLF+;
			"    CTB.CTB_CTADES AS CTACR, "+CRLF+;
			"    CTB.CTB_CCDES AS CCCR, "+CRLF+;
			"    CTB.CTB_ITEMDE AS ITEMCR, "+CRLF+;
			"    CTB.CTB_CLVLDE AS CLVLCR, "+CRLF+;
			"   "+cSelCrdCT2+CRLF+;
			"    "+cValor+" AS VALOR, "+CRLF+;
			"    CT2.CT2_DATA AS CDATA, "+CRLF+;
			"    "+cFormul+" AS FORMUL, "+CRLF+;
			"    "+cHaglut+" AS HAGLUT, "+CRLF+;
			"    "+cHist+" AS HIST, "+CRLF+;
			"    CT2.CT2_DTLP AS DTLP, "+CRLF+;
			"    CT2.CT2_MOEDLC AS MOEDA, "+CRLF+;
			"    "+cCrd+" AS TIPO, "+CRLF+;
			"    "+cLote+" AS LOTE, "+CRLF+;
			"    "+cSub+" AS SBLOTE, "+CRLF+;
			"    "+cDoc+" AS DOC, "+CRLF+;
			"    "+cLinha+" AS LINHA, "+CRLF+;
			"    "+cRec+" AS REC "+CRLF+;
			" FROM "+cAliasCT2+" CT2 "+CRLF+;
			" INNER JOIN CTB_BASE CTB "+CRLF+;
			" ON CT2.CT2_FILIAL = CTB.CTB_FILORI "+CRLF+;
			" AND CT2.CT2_TPSALD = CTB.CTB_TPSLDO "+CRLF+;
			" AND CT2.CT2_DC IN ('2','3') "+CRLF+;
			" AND CT2.CT2_CREDIT BETWEEN CTB.CTB_CT1INI AND CTB.CTB_CT1FIM "+CRLF+;
			" AND CT2.CT2_CCC    BETWEEN CTB.CTB_CTTINI AND CTB.CTB_CTTFIM "+CRLF+;
			" AND CT2.CT2_ITEMC  BETWEEN CTB.CTB_CTDINI AND CTB.CTB_CTDFIM "+CRLF+;
			" AND CT2.CT2_CLVLCR BETWEEN CTB.CTB_CTHINI AND CTB.CTB_CTHFIM "+CRLF+;
			" WHERE CT2.CT2_DATA BETWEEN '"+cDataIni+"' AND '"+cDataFim+"' "+CRLF			

If mv_par05 == 2
	cQuery += "AND CT2_MOEDLC= '"+mv_par06+"' "+CRLF
Endif

cQuery +=   " AND CT2.D_E_L_E_T_ = ' ' "+CRLF

cQuery += cGroupBy+CRLF			
//======================== Query CrÈdito - Fim ========================================
		
Return cQuery

//-----------------------------------------------------------------------------------------
/*
{Protheus.doc} EngSPS36Signature()
Controle de assinatura da procedure

@author TOTVS
@since  25/08/2025
@version 12
*/
//----------------------------------------------------------------------------------------
Function EngSPS36Signature()	
Return "001"

//-----------------------------------------------------------------------------------------
/*
{Protheus.doc} EngPre36Compile()
Ponto de entrada  antes da compilaÁ„o da procedure

@author TOTVS
@since  25/08/2025
@version 12
*/
//----------------------------------------------------------------------------------------
Function EngPre36Compile(cProcesso as character, cEmpresa as character, cError as character)
Local aCampos 	as Array
Local cNomeTab  as Character

	cNomeTab := cEmpresa+"0_36SP"
	
	//CriaÁ„o da tabela de trabalho - TRA
	aCampos := C231Struct('TRA')	

	If TcCanOpen("TRA"+cNomeTab)
		TcDelFile("TRA"+cNomeTab)
	EndIf

	EngSPSWorkTable("","TRA"+cNomeTab,aCampos,.T.)
	
	//CriaÁ„o da tabela de trabalho - TRB
	aCampos := C231Struct('TRB')

	If TcCanOpen("TRB"+cNomeTab)
		TcDelFile("TRB"+cNomeTab)
	EndIf

	EngSPSWorkTable("","TRB"+cNomeTab,aCampos,.T.)

	//CriaÁ„o da tabela de trabalho - TRU
	aCampos := C231Struct("TRU")

	If TcCanOpen("TRU"+cNomeTab)
		TcDelFile("TRU"+cNomeTab)
	EndIf

	EngSPSWorkTable("","TRU"+cNomeTab,aCampos,.T.)	
Return .T.
//-----------------------------------------------------------------------------------------
/*
{Protheus.doc} EngOn38Compile()
Ponto de durante a compilaÁ„o da procedure, antes do MSParse

@author TOTVS
@since  25/08/2025
@version 12
*/
//----------------------------------------------------------------------------------------
Function EngOn36Compile(cProcesso as character, cEmpresa as character, cProcName as character, cBuffer as character, cError as character)
	Local cDeclare 		as character
	Local cEntidade 	as character
	Local cInstCube 	as character
	Local cFetch 		as character
	Local nZ        	as Numeric
	Local nTamHaglut 	as Numeric
	Local nTamCTK 		as Numeric
	Local cCposCube 	as character
	Local cGrpCube 	    as character
	Local nTamEnt 		as Numeric
	
	cBuffer := StrTran( cBuffer, "TRA###", "TRA"+cEmpresa+"0" )
	cBuffer := StrTran( cBuffer, "TRB###", "TRB"+cEmpresa+"0" )
	cBuffer := StrTran( cBuffer, "TRU###", "TRU"+cEmpresa+"0" )

	If cProcName$'CTBA231C/CTBA231D'
		cDeclare  := ''
		cFetch    := ''
		cInstCube := ''
		cCposCube := ''
		cGrpCube  := ''
				
		__lCtbIsCube := CtbIsCube()
		
		If __lCtbIsCube

			__nQtdEnt := CtbQtdEntd()
		
			For nZ:= 5 To __nQtdEnt				
				cEntidade := StrZero(nZ,2)
				nTamEnt   := TamSx3('CT2_EC'+cEntidade+'DB')[1]

				cDeclare += 'DECLARE @cnivel'+cEntidade+'DB CHAR('+cValToChar(nTamEnt)+')'+CRLF
				cDeclare += 'DECLARE @cnivel'+cEntidade+'CR CHAR('+cValToChar(nTamEnt)+')'+CRLF

				cFetch += '@cnivel'+cEntidade+'DB, @cnivel'+cEntidade+'CR, '

				cInstCube += 'CT2_EC'+cEntidade+'DB , CT2_EC'+cEntidade+'CR , '

				If cProcName == 'CTBA231C'			
					cCposCube += "CTB_EC"+cEntidade+"DB"+","
					cCposCube += "CTB_EC"+cEntidade+"CR"+","

					cGrpCube += "CTB_EC"+cEntidade+"DB"+","
					cGrpCube += "CTB_EC"+cEntidade+"CR"+","
				Else			
					cCposCube += "MAX(CTB_EC"+cEntidade+"DB) AS CTB_EC"+cEntidade+"DB, "
					cCposCube += "MAX(CTB_EC"+cEntidade+"CR) AS CTB_EC"+cEntidade+"CR, "
				EndIf
			Next nZ
		EndIf

		cBuffer := StrTran( cBuffer, "DECLARE @FLEX CHAR(1)", cDeclare )
		cBuffer := StrTran( cBuffer, "--CFETCHCUBE", cFetch )
		cBuffer := StrTran( cBuffer, "--INSERT ENTIDADES", cInstCube )
		cBuffer := StrTran( cBuffer, "--VALUES ENTIDADES", cFetch )
		cBuffer := StrTran( cBuffer, "--SELECT ENTIDADES", cCposCube )
		cBuffer := StrTran( cBuffer, "--GROUP ENTIDADES", cGrpCube )

		nTamHaglut 	:= TamSX3('CTB_HAGLUT')[1]
		nTamCTK 	:= TamSX3('CTK_HAGLUT')[1]

		If nTamHaglut < nTamCTK
			nTamHaglut := nTamCTK
		EndIf		

		cBuffer := StrTran( cBuffer, "CHAR(231", 'CHAR('+cValtoChar(nTamHaglut) )
	EndIf

Return .T.

//-----------------------------------------------------------------------------------------
/*
{Protheus.doc} EngPos36Compile()
Ponto de entrada apÛs a compilaÁ„o da procedure, depois do MSParse

@author TOTVS
@since  25/08/2025
@version 12
*/
//----------------------------------------------------------------------------------------
Function EngPos36Compile(cProcesso as character, cEmpresa as character, cProcName as character, cLocalDB as character, cBuffer as character, cError as character)
	If 'CTBA231'$cProcName
		cBuffer := StrTran(cBuffer, "VarChar( )", "varchar")
		cBuffer := StrTran(cBuffer, "VARCHAR( )", "VARCHAR")
		cBuffer := StrTran(cBuffer, " 1 , 999", "1 ,"+cValtoChar(TamSX3('CT2_HIST')[1]) )
		If 'CTBA231B'$cProcName
			If cLocalDB == "MSSQL"
				cBuffer := StrTran(cBuffer, "TRB"+cEmpAnt+"0_36SP TRB", "FROM TRB"+cEmpAnt+"0_36SP TRB")
			Else
				If cLocalDB == "POSTGRES"
					cBuffer := StrTran(cBuffer, "SELECT 'TRATAMENTOBANCO'  TRATAMENTO", "UPDATE TRB"+cEmpAnt+"0_36SP TRB"+CRLF+"SET DEBITO  = TRB.DEBITO  - A.TOT_DEBITO, ";
					+"CREDITO = TRB.CREDITO - A.TOT_CREDITO"+CRLF)
				Else
					cBuffer := StrTran(cBuffer, "SELECT 'TRATAMENTOBANCO'  TRATAMENTO","MERGE INTO TRB"+cEmpAnt+"0_36SP TRB USING (")
					cBuffer := StrTran(cBuffer, "FROM (","")
					cBuffer := StrTran(cBuffer, "ON A.EMPORI","ON ( A. EMPORI")
					cBuffer := StrTran(cBuffer, "AND 1  = 1",") WHEN MATCHED THEN " + CRLF + "UPDATE SET"+CRLF;
    				+"TRB.DEBITO  = TRB.DEBITO  - A.TOT_DEBITO,"+CRLF+" TRB.CREDITO = TRB.CREDITO - A.TOT_CREDITO")
					cBuffer := StrTran(cBuffer, "inner join DUAL","")
				EndIf
			EndIf
		EndIf
	EndIf
Return  .T.

//-----------------------------------------------------------------------------------------
/*
{Protheus.doc} C231Struct()
Retorna a estrutura da tabela tempor·ria utilizada para armazenar os dados de movimento do CTB, conforme o alias passado
@author TOTVS						
@since 26/01/2025
@version 12
@param cStructName - Nome da estrutura a ser retornada, pode ser 'TRA' ou 'TRB'
*/
//-----------------------------------------------------------------------------------------
Function C231Struct(cTabStruct as Character)
Local aCampos  	as Array
Local cEntidade as Character
Local nCTKHist 	as Numeric
Local nCT2Hist 	as Numeric
Local nTamHag  	as Numeric
Local nCTKHag  	as Numeric
Local nTamCta  	as Numeric
Local nTamCus  	as Numeric
Local nTamIte  	as Numeric
Local nTamClv  	as Numeric
Local nTamEnt  	as Numeric
Local nI 		as Numeric

DEFAULT cTabStruct := ""

aCampos := {}

If cTabStruct == "TRA"
	nCTKHist := TamSX3('CTK_HIST')[1]
	nCT2Hist := TamSX3('CT2_HIST')[1]
	nTamHag  := TamSX3('CTB_HAGLUT')[1]
	nCTKHag  := TamSX3('CTK_HAGLUT')[1]
	nTamCta  := TamSX3('CT2_DEBITO')[1]
	nTamCus  := TamSX3('CT2_CCD')[1]
	nTamIte  := TamSX3('CT2_ITEMD')[1]
	nTamClv  := TamSX3('CT2_CLVLDB')[1]
	
	If nCT2Hist < nCTKHist
		nCT2Hist := nCTKHist
	EndIf

	If nTamHag < nCTKHag
		nTamHag := nCTKHag
	EndIf
	
	//Cria tabela tempor·ria	
	aAdd(aCampos,{"EMPORI",		"C", 2, 0})
	aAdd(aCampos,{"FILORI",		"C", FwSizeFilial(), 0})

	__lMultiRot := SuperGetMV("MV_CTBMTRT",, .F.)

	If __lMultiRot
		aAdd(aCampos,{"CTB_CODIGO",	"C", TamSX3('CT2_DEBITO')[1], 0})
	EndIf

	aAdd(aCampos,{"CTB_TPSLDO",	"C", TAMSX3('CT2_TPSALD')[1], 0})
	aAdd(aCampos,{"CTB_CTADB",	"C", nTamCta, 0})
	aAdd(aCampos,{"CTB_CCDB",	"C", nTamCus, 0})
	aAdd(aCampos,{"CTB_ITEMDB",	"C", nTamIte, 0})
	aAdd(aCampos,{"CTB_CLVLDB",	"C", nTamClv, 0})
	aAdd(aCampos,{"CTB_CTACR",	"C", nTamCta, 0})
	aAdd(aCampos,{"CTB_CCCR",	"C", nTamCus, 0})
	aAdd(aCampos,{"CTB_ITEMCR",	"C", nTamIte, 0})
	aAdd(aCampos,{"CTB_CLVLCR",	"C", nTamClv, 0})

	__lCtbIsCube := CtbIsCube()

	If __lCtbIsCube
		__nQtdEnt := CtbQtdEntd()
		For nI:= 5 To __nQtdEnt		
			cEntidade := StrZero(nI,2)
			nTamEnt   := TamSx3('CT2_EC'+cEntidade+'DB')[1]

			aAdd(aCampos,{"CTB_EC"+cEntidade+"DB",	"C", nTamEnt, 0})
			aAdd(aCampos,{"CTB_EC"+cEntidade+"CR",	"C", nTamEnt, 0})
		Next nI
	EndIf	

	aAdd(aCampos,{"VALOR",		"N", TamSX3('CT2_VALOR')[1], TamSX3('CT2_VALOR')[2]})
	aAdd(aCampos,{"CDATA",		"C", 8, 0})
	aAdd(aCampos,{"FORMUL",		"C", TamSX3('CTB_FORMUL')[1], 0})
	aAdd(aCampos,{"HAGLUT",		"C", nTamHag, 0})
	aAdd(aCampos,{"HIST",		"C", nCT2Hist, 0})
	aAdd(aCampos,{"DTLP",		"C", 8, 0})
	aAdd(aCampos,{"MOEDA",		"C", TamSX3('CT2_MOEDLC')[1], 0})
	aAdd(aCampos,{"TIPO",		"C", TamSX3('CT2_DC')[1], 0})
	aAdd(aCampos,{"LOTE",		"C", TamSX3('CT2_LOTE')[1], 0})
	aAdd(aCampos,{"SBLOTE",		"C", TamSX3('CT2_SBLOTE')[1], 0})
	aAdd(aCampos,{"DOC",		"C", TamSX3('CT2_DOC')[1], 0})
	aAdd(aCampos,{"LINHA",		"C", TamSX3('CT2_LINHA')[1], 0})	
	aAdd(aCampos,{"REC",		"N", 10, 0})	
ElseIf cTabStruct == "TRB"	
	aAdd(aCampos,{"EMPORI",		"C", 2, 0})
	aAdd(aCampos,{"FILORI",		"C", FwSizeFilial(), 0})
	aAdd(aCampos,{"CDATA",		"C", 8, 0})
	aAdd(aCampos,{"MOEDA",		"C", 2, 0})
	aAdd(aCampos,{"TPSALD",		"C", 1, 0})
	aAdd(aCampos,{"CONTA",		"C", TamSX3('CT2_DEBITO')[1], 0})
	aAdd(aCampos,{"CUSTO",		"C", TamSX3('CT2_CCD')[1], 0})
	aAdd(aCampos,{"ITEM",		"C", TamSX3('CT2_ITEMD')[1], 0})
	aAdd(aCampos,{"CLVL",		"C", TamSX3('CT2_CLVLDB')[1], 0})
	aAdd(aCampos,{"DEBITO",		"N", TamSX3('CT2_VALOR')[1], TamSX3('CT2_VALOR')[2]})
	aAdd(aCampos,{"CREDITO",	"N", TamSX3('CT2_VALOR')[1], TamSX3('CT2_VALOR')[2]})
	aAdd(aCampos,{"CONTA_ORI",	"C", TamSX3('CT2_DEBITO')[1], 0})
	aAdd(aCampos,{"CUSTO_ORI",	"C", TamSX3('CT2_CCD')[1], 0})
	aAdd(aCampos,{"ITEM_ORI",	"C", TamSX3('CT2_ITEMD')[1], 0})
	aAdd(aCampos,{"CLVL_ORI",	"C", TamSX3('CT2_CLVLDB')[1], 0})
	aAdd(aCampos,{"DTLP",		"C", 8, 0})
	aAdd(aCampos,{"LP",			"C", 1, 0})
	aAdd(aCampos,{"FLAG", 		"N", 1, 0})
ElseIf cTabStruct == "TRU"
	aAdd(aCampos,{"CT2_FILIAL",	"C", FwSizeFilial(), 0}) 
	aAdd(aCampos,{"CT2_DATA",	"C", 8, 0})
	aAdd(aCampos,{"CT2_LOTE",	"C", TamSX3('CT2_LOTE')[1],	0}) 
	aAdd(aCampos,{"CT2_SBLOTE",	"C", TamSX3('CT2_SBLOTE')[1], 0}) 
	aAdd(aCampos,{"CT2_DOC",	"C", TamSX3('CT2_DOC')[1], 0}) 
	aAdd(aCampos,{"CT2_EMPORI",	"C", TamSX3('CT2_EMPORI')[1], 0}) 
	aAdd(aCampos,{"CT2_FILORI",	"C", TamSX3('CT2_FILORI')[1], 0}) 
	aAdd(aCampos,{"CT2_SBLNEW",	"C", TamSX3('CT2_SBLOTE')[1], 0}) 
EndIf

Return aCampos

//-----------------------------------------------------------------------------------------
/*
{Protheus.doc} C231DelTRB()
Limpa tabela TRB antes de chamar a procedure
@author TOTVS
@since  25/08/2025
@version 12
*/
//-----------------------------------------------------------------------------------------
Static Function C231DelTRB(cTabTrb as Character)
DEFAULT cTabTrb := ""
Return TcSqlExec("TRUNCATE TABLE "+cTabTrb)

//-----------------------------------------------------------------------------------------
/*
{Protheus.doc} EngSPS36Delete()
Ponto de entrada para exclus„o dos dados, caso necess·rio, antes da execuÁ„o da procedure
@author TOTVS
@since  25/08/2025
@version 12
*/
//-----------------------------------------------------------------------------------------
Function EngSPS36Delete( cProcesso as character, cEmpresa as character, cError as character )
Local cNomeTab  as Character 

cNomeTab := cEmpresa+"0_36SP"

If TcCanOpen("TRA"+cNomeTab)
	TcDelFile("TRA"+cNomeTab)
EndIf

If TcCanOpen("TRB"+cNomeTab)
	TcDelFile("TRB"+cNomeTab)
EndIf

If TcCanOpen("TRU"+cNomeTab)
	TcDelFile("TRU"+cNomeTab)
EndIf

Return .T.

//Retorna a vers„o do robÙ
Function C231VerRob()
Return "001"

//-----------------------------------------------------------------------------------------
/*
{Protheus.doc} C231IsSQL()
Verifica se o banco de dados atual È SQL
@author TOTVS
@since  25/08/2025
@version 12
*/
//-----------------------------------------------------------------------------------------
Static Function C231IsSQL()
If __cSGBD == nil
	__cSGBD := TCGetDB()
EndIf
Return "SQL"$__cSGBD
