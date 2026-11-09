#INCLUDE "PROTHEUS.CH"
#INCLUDE "fwcommand.ch"
#INCLUDE "pcoa310.ch"
#Define BMP_ON  "LBOK"
#Define BMP_OFF "LBNO"
//AMARRACAO ALTERACAO FONTE ADMXPROC 
/*
_F_U_N_C_ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFUNCAO    ณ PCOA310  ณ AUTOR ณ Edson Maricate        ณ DATA ณ 08.07.2005 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDESCRICAO ณ Programa para reprocessamento dos pontos de lan็amento       ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ USO      ณ SIGAPCO                                                      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ_DOCUMEN_ ณ PCOA310                                                      ณฑฑ
ฑฑณ_DESCRI_  ณ Programa para reprocessamento dos ppontos de lan็amento      ณฑฑ
ฑฑณ_FUNC_    ณ Esta funcao podera ser utilizada com a sua chamada normal    ณฑฑ
ฑฑณ          ณ partir do Menu ou a partir de uma funcao pulando assim o     ณฑฑ
ฑฑณ          ณ browse principal e executando a chamada direta da rotina     ณฑฑ
ฑฑณ          ณ selecionada.                                                 ณฑฑ
ฑฑณ          ณ Exemplo: PCOA310(2) - Executa a chamada da funcao de visua-  ณฑฑ
ฑฑณ          ณ                        zacao da rotina.                      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ_PARAMETR_ณ ExpN1 : Chamada direta sem passar pela mBrowse               ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static lFWCodFil := FindFunction("FWCodFil")
Static lPLogIni  := FindFunction('PROCLOGINI')
Static lPLogAtu  := FindFunction('PROCLOGATU')
Static __lBlind  := IsBlind()
Static _lFKInUse
Static _lAuto    := .F.
Static _aRetPar1 := {}
Static _aRetPar2 := {}

Static _aRet_SM0 := Nil

Function PCOA310( nCallOpcx, cProcesso, cItProces, aPar1, aPar2 )

Private cCadastro	:= STR0001 //"Reprocessamento de Lan็amentos"
Private aRotina 	:= MenuDef()
	
		ProcLogIni( {}/*aButtons*/, "PCOA310" )
If nCallOpcx <> Nil

	_lAuto := .T.
	_aRetPar1 := aClone(aPar1)
	_aRetPar2 := aClone(aPar2)
	
	dbSelectArea("AKB")
	dbSetOrder(1)
	
	If !Empty(_aRetPar1) .And. dbSeek(xFilial("AKB")+cProcesso+cItProces) .AND. AKB->AKB_PERMR $ "1|3"
			
		A310DLG("AKB",AKB->(RecNo()),nCallOpcx)
		
	EndIf

Else

	mBrowse(6,1,22,75,"AKB")

EndIf


Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA310DLG   บAutor  ณEdson Maricate      บ Data ณ  08/07/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Dialog de reprocessamento                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP8                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function A310Dlg(cAlias As Character,nRecnoAKB As Numeric,nCallOpcx As Numeric)
Local aRet	      As Array
Local aParametros As Array

Local aRetFil     As Array
Local lRet        As Logical
Local cFiltAKD    As Character
Local aAreaOri    As Array

//*********************************************
// variaves para reprocessamento Multi-Filial *
//*********************************************
Local cAliasEnt	  As Character	
Local nThreads 	  As Numeric
Local cTbField    As Character
Local lEnd		  As Logical
Local cFiltro	  As Character
//*********************************************
// variaves para reprocessamento Multi-Filial *
//*********************************************
Local cFilAtu	  As Character
Local nRegSM0	  As Numeric
Local cProcess    As Character
Local cItem       As Character
Local lMultFil	  As Logical
Local lPCO310Aux  As Logical
Local cLoadParam  As Character

Local aFilLoc	  As Array
Local lContinua	  As Logical
Local cChave	  As Character
Local nX          As Numeric
Local nTotReg 	  As Numeric

Local cFil_Log    As Character
Local cEntidade   As Character
//*********************************
// Utilizado no vetor da parambox *
//*********************************

Private DEF_DATINI := 2
Private DEF_DATFIN := 3
Private DEF_FILTRO := 4

Private lDelPeriodo
Private cFilialDe
Private cFilialAte
Private dPeriodoDe
Private dPeriodoAte
Private lVisualiza
Private lAtuSld

aRet	      := {}
aParametros   := {}

aRetFil     := {}
lRet        := .F.
cFiltAKD    := ""
aAreaOri    := {}

//*********************************************
// variaves para reprocessamento Multi-Filial *
//*********************************************
cAliasEnt	  := GetEntFilt(AKB->AKB_PROCES,AKB->AKB_ITEM)	
nThreads 	  := SuperGetMv("MV_PCOTHRE",.T.,1)
cTbField      := If(SubStr(cAliasEnt,1,1)== "S",SubStr(cAliasEnt,2),cAliasEnt)
lEnd		  := .T.
cFiltro	      := ""
//*********************************************
// variaves para reprocessamento Multi-Filial *
//*********************************************
cFilAtu	    := cFilAnt
nRegSM0	    := SM0->(Recno())
cProcess    := ""
cItem       := ""
lMultFil	:= .F.
lPCO310Aux  := ExistBlock("PCO310AUX")
cLoadParam  := cEmpAnt + "_" + cFilAnt + "_A310DLG"  

aFilLoc	  := {}
lContinua := .T.
cChave	  := "" 
nX        := 0
nTotReg 	:= 0

cFil_Log := cFilAnt
cEntidade:= ""

dbSelectArea("AL1")
dbSetOrder(1)
dbSelectArea("AL2")
dbSetOrder(1)
dbSelectArea("AK5")
dbSetOrder(1)
dbSelectArea("AKD")
dbSetOrder(1)
dbSelectArea("AKS")
dbSetOrder(1)
dbSelectArea("AKT")
dbSetOrder(1)
dbSelectArea("ALA")
dbSetOrder(1)
dbSelectArea("AKB")

If AKB->AKB_PERMR $ "1|3"

	If	FWModeAccess("AK8",3) == "C" .And.;	// Processos de Sistema
		FWModeAccess("AKB",3) == "C" .And.;	// Pontos de Lan็amento
		FWModeAccess("AKC",3) == "C" 		// Configuracao de Lancamento

		lMultFil := .T.
		
		cLoadParam += "_C" //Compartilhado
		
		aParametros := { 	{ 5, STR0004,.F.,120,,.F.},; //"Apagar lan็amantos do periodo ?"					
							{ 1, STR0022,IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL ),"" 	 ,"Empty() .or. ExistCpo('SM0',cEmpAnt+mv_par02)"  ,"SM0"    ,"" ,50 ,.F. },; //"Filial de"
							{ 1, STR0023,IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL ),"" 	 ,"MV_PAR03>='ZZ' .or. ExistCpo('SM0',cEmpAnt+mv_par03)"  ,"SM0"    ,"" ,50 ,.F. },; //"Filial ate"
							{ 1, STR0005,CTOD("  /  /  "),"" 	 ,""  ,""    ,"" ,50 ,.F. },; //"Periodo de"
							{ 1, STR0006,CTOD("  /  /  "),"" 	 ,""  ,""    ,"" ,50 ,.F. },; //"Periodo Ate"
							{ 7, STR0007+GetEntFilt(AKB->AKB_PROCES,AKB->AKB_ITEM),GetEntFilt(AKB->AKB_PROCES,AKB->AKB_ITEM),""},; //"Filtro "
							{ 5, STR0008,.F.,120,,.F.},;
							{ 5, STR0042,.F.,120,,.F.,nThreads>1}} //"Atualizar Saldos ?"

	Else
		
		aParametros := { 	{ 5, STR0004,.F.,120,,.F.},; //"Apagar lan็amantos do periodo ?"					
							{ 1, STR0005,CTOD("  /  /  "),"" 	 ,""  ,""    ,"" ,50 ,.F. },; //"Periodo de"
							{ 1, STR0006,CTOD("  /  /  "),"" 	 ,""  ,""    ,"" ,50 ,.F. },; //"Periodo Ate"
							{ 7, STR0007+GetEntFilt(AKB->AKB_PROCES,AKB->AKB_ITEM),GetEntFilt(AKB->AKB_PROCES,AKB->AKB_ITEM),""},; //"Filtro "
							{ 5, STR0008,.F.,120,,.F.},;
							{ 5, STR0042,.F.,120,,.F.,nThreads>1} } //"Atualizar Saldos ?"

	EndIf
	If lMultFil
		DEF_DATINI := 4
		DEF_DATFIN := 5
		DEF_FILTRO := 6
		DEF_VISUAL := 7
	Else
		DEF_DATINI 			:= 2
		DEF_DATFIN 			:= 3
		DEF_FILTRO 			:= 4
		DEF_VISUAL 			:= 5												
	EndIf	    

	If nThreads>1
		//***********************************************************
		// Avalia se tem Trhead rodando para o processo selecionado *
		// e apresenta tela com processamento Multi-Thread.         *
		//***********************************************************
		//Carrega parametros da ultima execu็ใo do parambox par amonitorar as Threads
		If Empty(aRet)
			aRet := Array(Len(aParametros))
			For nX := 1 to Len(aRet)
				aRet[nX]:=ParamLoad(cLoadParam,,nX,Iif(Valtype(aParametros[nX,3])=='C',Padr(aParametros[nX,3],200),aParametros[nX,3]),.F.)
			Next
			aRet[DEF_FILTRO] := Alltrim(aRet[DEF_FILTRO])
		EndIf
		lEnd	:= MoniThread(aRet)
	EndIf
	
	If lEnd // So continua se nใo tem Thread rodando

		MV_PAR06 := CHR(10) //Limpa Filtro

		If _lAuto
			aRet := aClone(_aRetPar1)
		EndIf

		If _lAuto .OR. ParamBox(aParametros,STR0009,aRet,,,,,,,cLoadParam) //"Parametros"
			//salva respostas do parambox
			ParamSave(cLoadParam,aParametros,"1")
			If lPCO310Aux
				ExecBlock("PCO310AUX",.F.,.F.)
			EndIf    
			//*******************************
			// reprocessamento Multi-Filial *
			//*******************************
			If lMultFil
				lDelPeriodo			:= aRet[1]
				cFilialDe			:= aRet[2]
				cFilialAte			:= aRet[3]
				lAtuSld				:= aRet[8]
			Else
				lDelPeriodo			:= aRet[1]
				cFilialDe			:= cFilAnt
				cFilialAte			:= cFilAnt 
				lAtuSld				:= aRet[6]
			EndIf	    
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ Inicia o log de processamento  - nao tirar a linha abaixo  ณ
			//ณ pois funcao ProcLogIni utiliza as variaveis mv_par private ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			AEval( aRet, { |x,y| SetPrvt("MV_PAR"+AllTrim(STRZERO(y,2,0))), &("MV_PAR"+AllTrim(STRZERO(y,2,0))) := x } )
            
			If	FWModeAccess("AL1",3) == "C"
            	dbSelectArea("AL1")
				cChave := AllTrim(SM0->M0_CODIGO)+"_"+StrTran(AllTrim(xFilial("AL1"))," ","_")				
				If LockByName("PCOA300"+cChave,.F.,.F.)
					aAdd(aFilLoc,"PCOA300"+cChave)
				Else
					Help(" ",1,"PCOA301US",,STR0043,1,0) //"Outro usuario estแ reprocessando saldos. Aguarde!"
					Return
				EndIf					
            Else
	            dbSelectArea("SM0")
				dbSeek(cEmpAnt+cFilialDe,.t.)
				While !SM0->(Eof()) .and. SM0->M0_CODIGO == cEmpAnt .and.	SM0->M0_CODFIL >= cFilialDe .and. SM0->M0_CODFIL <= cFilialAte
					cFilAnt := IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL )
					dbSelectArea("AL1")
					cChave := AllTrim(SM0->M0_CODIGO)+"_"+StrTran(AllTrim(xFilial("AL1"))," ","_")				
					If LockByName("PCOA300"+cChave,.F.,.F.)
						aAdd(aFilLoc,"PCOA300"+cChave)
					Else
						lContinua := .F.
						Exit	
					EndIf					
					SM0->(DbSkip())
				EndDo
				DbSelectArea("SM0")
				DbGoTo(nRegSM0)            
			
				If !lContinua
					For nX := 1 To Len(aFilLoc)
						UnLockByName(aFilLoc[nX],.F.,.F.)
					Next
					Help(" ",1,"PCOA301US",,STR0043,1,0) //"Outro usuario estแ reprocessando saldos. Aguarde!"
					Return
				EndIf						
			EndIf            

			If _lAuto .And. lDelPeriodo
				If _lAuto
					aRetFil :=  aClone(_aRetPar2)
				EndIf
	
				If Len(aRetFil) > 0 .And. !Empty(aRetFil[1])
					cFiltAKD := aRetFil[1]
				EndIf
				//Qdo eh rotina automatica considera .T. sempre
				lRet := .T.				
			
			ElseIf lDelPeriodo
				If Aviso(STR0010, STR0016, {STR0017, STR0018} )==1  //"Atencao"##"Filtrar os lancamentos existentes para exclusao do processo selecionado ?"##"Sim"##"Nao"
				
					If  ParamBox( { { 7 , STR0007+STR0019,"AKD",""} }, STR0009, aRetFil,,,,,,, "PCOA310_1", .F., .F.) //"Parametros"##"[ Excluir os Movimentos - AKD ]"
						If !Empty(aRetFil[1])
							cFiltAKD := aRetFil[1]
							lRet := .T.
						EndIf
					EndIf
		
					If !lRet
						Aviso(STR0010, STR0020, {"Ok"})  //"Atencao"##"Filtro nao informado. Operacao Cancelada!"
					EndIf	
					
					AEval( aRet, { |x,y| SetPrvt("MV_PAR"+AllTrim(STRZERO(y,2,0))), &("MV_PAR"+AllTrim(STRZERO(y,2,0))) := x } )
						
				Else
		
					If Aviso(STR0010, STR0021,{STR0017, STR0018} ) == 1  //"Atencao"##"Confirma a exclusao de todos os lancamentos para o processo selecionado?"##"Sim"##"Nao"
						lRet := .T.
					EndIf	
		
				EndIf
			
			Else
			   
				lRet	:= .T.
				
			EndIf

			dbSelectArea("SM0")
			If ! DbSeek(cEmpAnt+cFilialDe)
				Aviso(STR0010, STR0044,{"Ok"} )  //"Atencao"##"Filial Inicial Invalida. Abandonando reprocessamento de lan็amentos. Selecione uma filial vแlida."
				lRet := .F.
			ElseIf ! DbSeek(cEmpAnt+cFilialAte)
				Aviso(STR0010, STR0045,{"Ok"} )  //"Atencao"##""Filial Final Invalida. Abandonando reprocessamento de lan็amentos. Selecione uma filial vแlida."
				lRet := .F.
			EndIf	

			DbSelectArea("SM0")
			DbGoTo(nRegSM0)
			cFilAnt := cFil_Log  //restaura pois F3 da filial de...ate desposiciona cFilAnt
	
			If lRet

				//*******************************
				// reprocessamento Multi-Thread *
					//*******************************

					nTotReg   := TotLanc(aRet, cFilialDe, cFilialAte) //Retorna a quantidade de registros  validando se o processamento serแ multi-thread

					cAliasEnt := GetEntFilt(AKB->AKB_PROCES,AKB->AKB_ITEM)
					cTbField  := If(SubStr(cAliasEnt,1,1)== "S",SubStr(cAliasEnt,2),cAliasEnt)
					If nThreads>1 .And. nTotReg >= nThreads 
						aAreaOri := GetArea()
						dbSelectArea(GetEntFilt(AKB->AKB_PROCES,AKB->AKB_ITEM))
						dbSetOrder(1)
	
						If lDelPeriodo
							cFiltro	:= aRet[DEF_FILTRO]
							dbSelectArea("SM0")
					      	DbSeek(cEmpAnt+cFilialDe,.t.)
							While !SM0->(Eof()) .and. SM0->M0_CODIGO == cEmpAnt .and.	SM0->M0_CODFIL >= cFilialDe .and.; 
																	 					SM0->M0_CODFIL <= cFilialAte
								cFilAnt := IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL )
								Processa({|| ProcDel(aRet, cFiltAKD)}, STR0013, STR0014 )	// "Processando lan็amentos" ### "Excluindo lancamentos..."
								SM0->(DbSkip())
							EndDo
							DbSelectArea("SM0")
							DbGoTo(nRegSM0)
		            	EndIf
	
						If  SubStr( cAliasEnt, 1, 1) == "S" 
							//se a primeira letra do alias for "S" entao	
							//considera campo filial a partir da segunda exemplo tabela SA1 - campo A1_FILIAL
							If !Empty(xFilial(cAliasEnt, cFilialDe)) .And. xFilial(cAliasEnt, cFilialDe) <> xFilial(cAliasEnt, cFilialAte)   //Len(xFilial(cAliasEnt)) == 2
								aRet[DEF_FILTRO] += If(Empty(aRet[DEF_FILTRO]),"",".and.") + cAliasEnt +"->"+ SubStr( cAliasEnt, 2, 2 )+"_FILIAL>='"+xFilial(cAliasEnt, cFilialDe)+"' .and. "
								aRet[DEF_FILTRO] += cAliasEnt +"->"+ SubStr( cAliasEnt, 2, 2 )+"_FILIAL<='"+xFilial(cAliasEnt, cFilialAte)+"'"
							Else
								aRet[DEF_FILTRO] += If(Empty(aRet[DEF_FILTRO]),"",".and.") + cAliasEnt +"->"+SubStr(cAliasEnt, 2, 2)+"_FILIAL=='"+xFilial(cAliasEnt, cFilialDe)+"'"
							EndIf
						Else			
							If !Empty(xFilial(cAliasEnt, cFilialDe)) .And. xFilial(cAliasEnt, cFilialDe) <> xFilial(cAliasEnt, cFilialAte)   //Len(xFilial(cAliasEnt)) == 2
								aRet[DEF_FILTRO] += If(Empty(aRet[DEF_FILTRO]),"",".and.") + cAliasEnt +"->"+cAliasEnt+"_FILIAL>='"+xFilial(cAliasEnt, cFilialDe)+"' .and. "
								aRet[DEF_FILTRO] += cAliasEnt +"->"+cAliasEnt+"_FILIAL<='"+xFilial(cAliasEnt, cFilialAte)+"'"
							Else
								aRet[DEF_FILTRO] += If(Empty(aRet[DEF_FILTRO]),"",".and.") + cAliasEnt +"->"+cAliasEnt+"_FILIAL=='"+xFilial(cAliasEnt, cFilialDe)+"'"
							Endif
						EndIf
						RestArea(aAreaOri)
				
						If lRet
							cSql := A310Slq(AKB->AKB_PROCES,AKB->AKB_ITEM,aRet)
							If !Empty(aRet[DEF_FILTRO]) .and. !Empty(cSql)
								aRet[DEF_FILTRO] += " .AND. " + cSql + " "
							Elseif !Empty(cSql)
								aRet[DEF_FILTRO] += cSql + " "
							EndIf
								Processa({|| ThreadLanc(aRet,cFilialDe, cFilialAte )}, STR0013, STR0024 )		// "Processando lan็amentos" ### "Selecionando lan็amentos"
						EndIf
						
						//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
						//ณ Atualiza o log de processamento   ณ
						//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
						ProcLogAtu("FIM")
					Else
			 			cFiltro	:= aRet[DEF_FILTRO]
						dbSelectArea("SM0")
				      	DbSeek(cEmpAnt+cFilialDe,.t.)
						While !SM0->(Eof()) .and. SM0->M0_CODIGO == cEmpAnt .and.	SM0->M0_CODFIL >= cFilialDe .and.; 
																 					SM0->M0_CODFIL <= cFilialAte
							cFilAnt := IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL )
						
							ProcLogIni( {}/*aButtons*/, "PCOA310" )
	
							//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
							//ณ Atualiza o log de processamento   ณ
							//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
							ProcLogAtu("INICIO")
							
							cEntidade := GetEntFilt(AKB->AKB_PROCES,AKB->AKB_ITEM)
							If cEntidade <> NIL .AND. !EMPTY(cEntidade)
								aAreaOri := GetArea()
								dbSelectArea(cEntidade)
								dbSetOrder(1)
								aRet[DEF_FILTRO] := cFiltro
								If  SubStr( cAliasEnt, 1, 1) == "S" 
									//se a primeira letra do alias for "S" entao	
									//considera campo filial a partir da segunda exemplo tabela SA1 - campo A1_FILIAL
									aRet[DEF_FILTRO] += If(Empty(aRet[DEF_FILTRO]),"",".and.") + cAliasEnt +"->"+ SubStr( cAliasEnt, 2, 2 )
									If cEntidade=="SC7" .And. AKB->AKB_PROCES=="000054" .And. (AKB->AKB_ITEM=="15" .Or. AKB->AKB_ITEM=="16")
										aRet[DEF_FILTRO] += "_FILENT"
									Else
										aRet[DEF_FILTRO] += "_FILIAL"
									Endif
									aRet[DEF_FILTRO] += "=='"+xFilial(cAliasEnt)+"'"
								Else			
									aRet[DEF_FILTRO] += If(Empty(aRet[DEF_FILTRO]),"",".and.") + cAliasEnt +"->"+cAliasEnt+"_FILIAL=='"+xFilial(cAliasEnt)+"'"
								EndIf
								RestArea(aAreaOri)
								If lDelPeriodo
					
									Processa({|| ProcDel(aRet, cFiltAKD)}, STR0013, STR0014 )	// "Processando lan็amentos" ### "Excluindo lancamentos..."
											
								EndIf 
					
								If lRet
									conout('INI = NO THREAD as ' + TIME())
									Processa({|| ProcLanc(aRet,,,lAtuSld)}, STR0013, STR0015 )		// "Processando lan็amentos" ### "Gerando lancamentos..."
									conout('FIM = EMP:' + cEmpAnt + ' FIL:' + cFilAnt  + ' NO THREAD as ' + TIME() )
								EndIf
							Endif
							
							//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
							//ณ Atualiza o log de processamento   ณ
							//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
							ProcLogAtu("FIM")
				            									
							SM0->(DbSkip())
						EndDo
						DbSelectArea("SM0")
						DbGoTo(nRegSM0)
					
						If _lAuto .And. !lAtuSld
			   				Conout( STR0033 +"--->"+STR0034+CRLF+STR0035 ) //"Aviso!" //"Reprocessamento dos lan็amentos finalizado." //" ษ recomendada a atualiza็ใo dos saldos dos Cubos."
						ElseIf !lAtuSld
			   				Aviso( STR0033 , STR0034+CRLF+STR0035,{STR0012} ) //"Aviso!" //"Reprocessamento dos lan็amentos finalizado." //" ษ recomendada a atualiza็ใo dos saldos dos Cubos."
						EndIf  
					
					EndIf
				
			EndIf
			cFilAnt	:= cFilAtu
		
			For nX := 1 To Len(aFilLoc)
				UnLockByName(aFilLoc[nX],.F.,.F.)
			Next
			
		EndIf
	EndIf
Else
	If _lAuto
		Conout(STR0010+"-->"+STR0011) //"Aten็ใo"###"Este ponto nใo pode ser reprocessado"
	Else
		Aviso(STR0010,STR0011,{STR0012},2) //"Aten็ใo"###"Este ponto nใo pode ser reprocessado"###"Fechar"
	EndIf
EndIf

Return



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCOA310   บAutor  ณMicrosiga           บ Data ณ  05/22/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function A310FilInt(cProcesso,cItem,aRet)
Local lRet := .F.

Do Case
	Case cProcesso+cItem == "00025201"  // Inclusao de itens da Planilha
		lRet	:=	( AK2->AK2_DATAI >= aRet[DEF_DATINI] .And. AK2->AK2_DATAF <= aRet[DEF_DATFIN] )
		If lRet	
			AK1->(dbSetOrder(1))
			lRet := ( AK1->(MsSeek(xFilial('AK1')+AK2->AK2_ORCAME)) .And. AK2->AK2_VERSAO == AK1->AK1_VERSAO ) 	
		Endif
	Case cProcesso+cItem == "00025202"  // Inclusao de itens da Planilha versoes revisadas
		lRet	:=	( AK2->AK2_DATAI >= aRet[DEF_DATINI] .And. AK2->AK2_DATAF <= aRet[DEF_DATFIN] )
		If lRet	
			AKR->(dbSetOrder(1))
			AK1->(dbSetOrder(1))
			lRet := !( AKR->(MsSeek(xFilial('AKR')+AK2->AK2_ORCAME+AK2->AK2_VERSAO))).And.( AK1->(MsSeek(xFilial('AK1')+AK2->AK2_ORCAME)) .And. AK2->AK2_VERSAO <> AK1->AK1_VERSAO ) 
		Endif
	Case cProcesso+cItem == "00025203"  // Inclusao de itens da Planilha versoes simuladas
		lRet	:=	( AK2->AK2_DATAI >= aRet[DEF_DATINI] .And. AK2->AK2_DATAF <= aRet[DEF_DATFIN] )
		If lRet	
			AKR->(dbSetOrder(1))
			lRet := ( AKR->(MsSeek(xFilial('AKR')+AK2->AK2_ORCAME+AK2->AK2_VERSAO)))
		Endif
	Case cProcesso+cItem == "00035801"  // Inclusao de movimentos de planejamento
		lRet	:=	( ALY->ALY_DTINI >= aRet[DEF_DATINI] .And. ALY->ALY_DTFIM <= aRet[DEF_DATFIN] )
/*		If lRet	
			AKR->(dbSetOrder(1))
			lRet := ( AKR->(MsSeek(xFilial('AKR')+AK2->AK2_ORCAME+AK2->AK2_VERSAO)))
		Endif */
	Case cProcesso+cItem == "00008201"  // Lan็amentos contabeis CT2
		lRet	:=	( CT2->CT2_DATA >= aRet[DEF_DATINI] .And. CT2->CT2_DATA <= aRet[DEF_DATFIN] )
		
OtherWise 
	lRet := .T.
EndCase

If lRet .And.  ExistBlock( "PCOA3102" )
	//P_Eฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//P_Eณ Ponto de entrada utilizado para inclusao de funcoes de usuarios na     ณ
	//P_Eณ validacao do reprocessamento dos Lancamentos                           ณ
	//P_Eณ Parametros : Nenhum                                                    ณ
	//P_Eณ Retorno    : .T.ou .F.  //.T.validacao de usuario OK  .F.-Falhou       ณ
	//P_Eณ               Ex. :  User Function PCOA3102                            ณ
	//P_Eณ                      Return(If(U_FuncUsr(), .T., .F.))                 ณ
	//P_Eภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	lRet := ExecBlock( "PCOA3102", .F., .F.,{cProcesso,cItem,aClone(aRet)})
EndIf

Return lRet



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCOA310   บAutor  ณMicrosiga           บ Data ณ  05/22/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function A310Slq(cProcesso,cItem,aRet)
Local cRet := ""

Do Case
	Case cProcesso == "000252"  // Inclusao de itens da Planilha versoes simuladas
		cRet :=	"AK2_DATAI >='" + Dtos(aRet[DEF_DATINI]) + "' .AND. AK2_DATAF<='" + Dtos(aRet[DEF_DATFIN]) + "'" 
	Case cProcesso+cItem == "00035801"  // Inclusao de movimentos de planejamento
		cRet := "ALY_DTINI >='" + Dtos(aRet[DEF_DATINI]) + "' .AND. ALY_DTFIM <= '" + Dtos(aRet[DEF_DATFIN]) + "'" 
	Case cProcesso+cItem == "00008201"  //Lancamentos contabeis
		cRet := "CT2_DATA >='" + Dtos(aRet[DEF_DATINI]) + "' .AND. CT2_DATA <= '" + Dtos(aRet[DEF_DATFIN]) + "'" 

OtherWise 
	cRet := ""
EndCase

Return cRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCOA310   บAutor  ณMicrosiga           บ Data ณ  05/22/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function ProcDel(aRet, cFiltAKD)

	Local cQuery := ""
	Local cQryCond		:= ""
	Local lResolvQry 	:= .F.
	Local cFiltQry 		:= ""
	Local cQryFim       := ""
	Local nX, nMin, nMax
	Local cCampos
	Local dDatIni := aRet[DEF_DATINI]
	Local dDatFim := aRet[DEF_DATFIN]
	Local cAliasQry
	Local dDataAnt
	Local nDias
	Local lDelAll := SuperGetMV("MV_PCODELR",.T.,"1")=="2" // Deleta todos os movimentos (Validos e Invalidos)
	Local cFilOrg := iIf( FWModeAccess("AKB",3) == "E" ,xFilial(AKB->AKB_ENTIDA),cFilAnt)

	If _lFKInUse == NIL
		_lFKInUse := FKInUse()
	EndIf

	//verifica se filtro digitado por usuario e resolvido na query
	If !Empty(cFiltAKD)
		cFiltQry := PcoParseFil(cFiltAKD, "AKD")
		If ! Empty(cFiltQry)
			lResolvQry 	:= .T.
		EndIf
	Else
		lResolvQry 	:= .T.	
	EndIf	

	Begin Transaction

	dbSelectArea("AL1")
	dbSetOrder(1)
	DbgoTop()
	//***********************************************************
	// Verrica se existe cubo cadastrado e tem query de delecao *
	//***********************************************************
	If lResolvQry .and. dbSeek( xFilial("AL1") )

		nMin	:=	0
		nMax    := 	0
		
		cQryCond := "   AKD_FILIAL = '" + xFilial("AKD")  + "' AND "
		cQryCond += "   AKD_FILORI = '" + cFilOrg + "' AND "
		cQryCond += "   AKD_PROCES = '" + AKB->AKB_PROCES + "' AND "
		cQryCond += "   AKD_ITEM   = '" + AKB->AKB_ITEM   + "' AND "
		cQryCond += "   ( "
		cQryCond += "		AKD_DATA = ' ' OR ( AKD_DATA BETWEEN '" + DtoS( dDatIni ) + "' AND '" + DtoS( dDatFim ) + "' )" 
		cQryCond += "   ) AND "
		cQryCond += "   D_E_L_E_T_ = ' ' "
		//*************************************
		// utilizado para Deletar todos os    *
		// lan็amentos (validos e invalidos). *
		//*************************************
		If !lDelAll
			cQryCond +=	" AND AKD_STATUS='1' "
		EndIf
		cQryCond +=	" AND AKD_TIPO IN ( '1', '2') "

		// Adiciona expressao de filtro convertida para SQL	
		If !Empty(cFiltQry)
			cQryCond += " AND (" + cFiltQry +")"
		EndIf
		
		cQuery	:=	" SELECT Min(R_E_C_N_O_) MinRecno, "
		cQuery	+=	" Max(R_E_C_N_O_) MaxRecno "
		cQuery	+=	" FROM " + RetSqlName("AKD")
		cQuery	+=	" WHERE "
		cQuery	+=	cQryCond
		cQuery	:=	ChangeQuery(cQuery)
		
		dbUseArea( .T., "TopConn", TCGenQry(,,cQuery),"QRYTRB", .F., .F. )
		
		If !Eof()                                           
			nMin	:=	MINRECNO
			nMax	:=	MAXRECNO
		Endif	                                                                             
		
		QRYTRB->( dbCloseArea() )
		
		ProcRegua(Round((nMax-nMin)/10000,0))	
		
		For nX := nMin To nMax	STEP 10000
		
			If _lFKInUse
				cQryFim := " UPDATE " + RetSqlName('AKD') + " SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ "
			Else
				cQryFim	:= " DELETE FROM  "+RetSqlName('AKD') 
			EndIf
			
			cQryFim += " WHERE "
			cQryFim += cQryCond
			cQryFim += " AND R_E_C_N_O_ BETWEEN "+Str(nX)+ ' AND '+Str(nX+10000)
			
			IncProc(STR0036) //"Apagando Movimentos ..."
			
			If TcSqlExec(cQryFim) <> 0
			
				UserException(STR0037 + CRLF + STR0038 + CRLF + TCSqlError() ) //"Erro na exclusao de movimentos " //"Processo cancelado..."
						lRet	:=	.F.
				Exit 		
			Else		    	
				//Forcar o Commit para DB2 para nao estourar o LOG (mesmo sem ter iniciado transacao)
				If Upper(TcGetDb()) == 'DB2'
					TcSqlExec('commit')
				Endif   			
			Endif
			
		Next

		TcRefresh(RetSqlName("AKD"))

		dbSelectArea( "AKD" )
		
	Else

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Conta linhas que serao processadas para montar gauge ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	cQuery := "SELECT COUNT(R_E_C_N_O_) TOTREG "
	cQuery += "FROM " + RetSQLName("AKD") + " AKD "
	cQuery += "WHERE "
	cQuery += "   AKD_FILIAL = '" + xFilial("AKD")  + "' AND "
	cQuery += "   AKD_FILORI = '" + xFilial(AKB->AKB_ENTIDA)  + "' AND "
	cQuery += "   AKD_PROCES = '" + AKB->AKB_PROCES + "' AND "
	cQuery += "   AKD_ITEM   = '" + AKB->AKB_ITEM   + "' AND "
	cQuery += "   D_E_L_E_T_ = ' ' "
	
	cQuery	:=	ChangeQuery(cQuery)
	dbUseArea( .T., "TopConn", TCGenQry(,,cQuery),"QRYTRB", .F., .F. )
	
	ProcRegua(QRYTRB->TOTREG)
	
	QRYTRB->( dbCloseArea() )
	dbSelectArea("AKD")

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Seleciona os lan็amentos do processo para exclusใo ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	cQuery := "SELECT R_E_C_N_O_ NUMREC "
	cQuery += "FROM " + RetSQLName("AKD") + " AKD "
	cQuery += "WHERE "
	cQuery += "   AKD_FILIAL = '" + xFilial("AKD")  + "' AND "
	cQuery += "   AKD_FILORI = '" + xFilial(AKB->AKB_ENTIDA)  + "' AND "
	cQuery += "   AKD_PROCES = '" + AKB->AKB_PROCES + "' AND "
	cQuery += "   AKD_ITEM   = '" + AKB->AKB_ITEM   + "' AND "
	cQuery += "   ( "
	cQuery += "		AKD_DATA = ' ' OR ( AKD_DATA BETWEEN '" + DtoS( aRet[DEF_DATINI] ) + "' AND '" + DtoS( aRet[DEF_DATFIN] ) + "' )" 
	cQuery += "   ) AND "
	cQuery += "   D_E_L_E_T_ = ' ' "


	cQuery	:=	ChangeQuery(cQuery)
	dbUseArea( .T., "TopConn", TCGenQry(,,cQuery),"QRYAKD", .F., .F. )

	Do While QRYAKD->( !Eof() )

		IncProc()

		AKD->( dbGoTo( QRYAKD->NUMREC ) )	
		
		If ! Empty(cFiltAKD) .And. ! lResolvQry .And. ! AKD->(&cFiltAKD)
			QRYAKD->(dbSkip())
			Loop
		EndIf	
		
		RecLock("AKD",.F.,.T.)
		AKD->(dbDelete())
		AKD->(MsUnlock())

		QRYAKD->(dbSkip())

	EndDo

	QRYAKD->( dbCloseArea() )
	dbSelectArea( "AKD" )	

EndIf

End Transaction

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMoniThreadบAutor  ณ Acacio Egas        บ Data ณ  05/18/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao para mapear as threads em uso pela rotina de        บฑฑ
ฑฑบ          ณ reprocessamento.                                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPCO                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MoniThread(aRet As Array, cFilVer As Character, nPosFil As Numeric) As Logical

Local aArea		As Array
Local aAreaSM0  As Array
Local cAliasEnt	As Character
Local cTbField 	As Character
Local cQuery	As Character
Local lRet		As Logical
Local cThreads	As Character
Local cCdFil	As Character
Local nThreads 	As Numeric
Local nX        As Numeric
Local nCtdFile  As Numeric
Local nFilEmpr  As Numeric
Local cFilThre  As Character
Local cFilAntB  :="" as Character  //Backup cFilAnt

Default aRet    := {.F.,Ctod(""),Ctod("31/12/20"),"", .F., .F.}
Default cFilVer := ""
Default nPosFil := 1

aArea		:= GetArea()
aAreaSM0    := SM0->(GetArea())
cAliasEnt	:= GetEntFilt(AKB->AKB_PROCES,AKB->AKB_ITEM)
cTbField 	:= If(SubStr(cAliasEnt,1,1)== "S",SubStr(cAliasEnt,2),cAliasEnt)
cQuery	    := ""
lRet		:= .T.
cThreads	:= ""
nThreads 	:= SuperGetMv("MV_PCOTHRE",.T.,1) 
nX          := 0
nCtdFile    := 0
nFilEmpr    := 0
cCdFil      := If(!Empty(cFilVer),cFilVer,StrTran(cFilAnt," ",""))
cFilThre	:= ""

If _aRet_SM0 == NIL
	_aRet_SM0	:= FWLoadSM0()
	RestArea( aAreaSM0 )
EndIf
nFilEmpr  := Qtd_Fil(_aRet_SM0, cEmpAnt)

Do While .T.
	nCtdFile++
	If Empty(cFilVer)
		cFilThre := _aRet_SM0[nCtdFile][2]
	Else
		nCtdFile := aScan(_aRet_SM0, {|x| x[SM0_GRPEMP] == cEmpAnt .And. Alltrim(FWxFilial(cAliasEnt,x[SM0_CODFIL])) == Alltrim(cFilVer)})
		cFilThre := _aRet_SM0[nCtdFile][2]
		nCtdFile := nPosFil
		nFilEmpr := nPosFil
	EndIf

	dbSelectArea("SM0")
	DbSeek(cEmpAnt+cFilThre,.t.)

	cFilAntB := cFilAnt //Backup cFilAnt
	cFilAnt  := IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL )
	cCdFil   := StrTran(cFilAnt," ","")
	lRet	 := .T.

	cThreads := ""
	For nX := 1 to nThreads	
		cTabMult	:= "TMP" + cCdFil + cAliasEnt + cValToChar(nCtdFile) + StrZero(nX,2)
		If TCCanOpen(cTabMult)
			If Select(cTabMult)>0
				(cTabMult)->(DbCloseArea())				
			EndIf			
			dbUseArea( .T., 'TOPCONN', cTabMult, cTabMult, .T., .F. )
		EndIf
		If Select(cTabMult)>0
			cQuery := "SELECT COUNT(*) AS TOT,THREAD FROM " + cTabMult + " " 
			cQuery += "WHERE D_E_L_E_T_='' AND THREAD<>'' GROUP BY THREAD"
			
			cQuery := ChangeQuery(cQuery)
			DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),"TRBRUN",.T.,.T.)
			
			If TRBRUN->(!Eof())
			    Do While TRBRUN->(!Eof())
			    	cThreads += TRBRUN->THREAD + ": " + Alltrim(Str(TRBRUN->TOT)) + STR0025 + CHR(10)+CHR(13) //"registros Pendentes de processamento."
			    	If LockByName("PCOA310_RUN_"  + cValToChar(nCtdFile) + TRBRUN->THREAD ,.T.,.T.,.T.) 
						If Aviso(  STR0010 , STR0026 + TRBRUN->THREAD + STR0027,{STR0018,STR0017} )==2 //"Aten็ใo!"##"Foram encontrador registros pendentes de processamento para a Thread "##". Desejแ continuar o processamento?"##"Nใo"##"Sim"
					    	lRet:= .F.
							(cTabMult)->(DbCloseArea())
							conout('INI = THREAD:' + TRBRUN->THREAD + "[" + Alltrim(Str(TRBRUN->TOT)) + " " + STR0028 + "] " + " as " + TIME()) //registros
							UnLockByName("PCOA310_RUN_" + cValToChar(nCtdFile) + TRBRUN->THREAD ,.T.,.T.,.T.)
							StartJob("PcoThr310",GetEnvServer(),.F., cTabMult ,cEmpAnt,cFilAnt, cValToChar(nCtdFile)+TRBRUN->THREAD,AKB->(GetArea()),aRet)
			    	    Else
			    	    	UnLockByName("PCOA310_RUN_"  + cValToChar(nCtdFile) + TRBRUN->THREAD ,.T.,.T.,.T.)
							(cTabMult)->(DbCloseArea())
							MsErase(cTabMult)			    	    	
			    	    EndIf
			    	Else
				    	lRet:= .F.
			    		(cTabMult)->(DbCloseArea())
			    	EndIf
				    TRBRUN->(DbSkip())
			    EndDo		  
			ElseIf LockByName("PCOA310_RUN_"  + cValToChar(nCtdFile) + StrZero(nX,2) ,.T.,.T.,.T.)
				UnLockByName("PCOA310_RUN_"  + cValToChar(nCtdFile) + TRBRUN->THREAD ,.T.,.T.,.T.)
				(cTabMult)->(DbCloseArea())
				MsErase(cTabMult)
			Else
		    	lRet:= .F.
		    	cThreads += StrZero(nX,2) + ": " + STR0029 + CHR(10)+CHR(13) //"Atualizando Saldos."
		    	(cTabMult)->(DbCloseArea())
			EndIf
			TRBRUN->(DbCloseArea())
		ElseIf TCCanOpen(cTabMult)
			(cTabMult)->(DbCloseArea())
			MsErase(cTabMult)
		EndIf
	Next
	cFilAnt := cFilAntB //Restaura cFilAnt
	If lRet .or. Aviso( STR0010 , STR0030 + CHR(10)+CHR(13) + cThreads, {STR0031} )==1 //"Aten็ใo!"##"Existem processamento sendo executados:"##"Sair"
		Exit
	EndIf
	If nCtdFile >= nFilEmpr  //somente sair quando varrer todas as filiais
		Exit
	EndIf	
EndDo

RestArea( aAreaSM0 )
RestArea(aArea)

Return lRet

//---------------------------------------------------------------------------------
/*/{Protheus.doc} Qtd_Fil
Retorna o numero de filiais do GrupoEmpresa passada como parametro
@since 02/07/2021
@version P12

/*/
//---------------------------------------------------------------------------------
Static Function Qtd_Fil( aRetSM0, cGrpEmpr)
Local nRet := 0
Local nX

Default aRetSM0 := {}
Default cGrpEmpr := cEmpAnt

For nX := 1 To Len(_aRet_SM0)
	If aRetSM0[nX, SM0_GRPEMP] == cGrpEmpr
		nRet++
	EndIf
Next
Return nRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณThreadLancบAutor  ณ Acacio Egas        บ Data ณ  05/18/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina de reprocessamento de lan็amentos por Multi-Thread  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ThreadLanc(aRet As Array,cFilialDe As Character, cFilialAte As Character)

Local nThreads  As Numeric
Local cAliasEnt	As Character
Local cTbField 	As Character
Local aProcs 	As Array
Local cQuery	As Character
Local cUpdate	As Character
Local cFiltro	As Character
Local nMed		As Numeric
Local nMin		As Numeric
Local nMax      As Numeric
Local nTot      As Numeric
Local nX        As Numeric

Local cTabMult  As Character
Local nThr		As Numeric


Local aFilxProc As Array
Local nCtd      As Numeric

Local cxFil     As Character
Local nPercThrd As Numeric
Local aProcFil  As Array
Local cCdFil    As Character
Local aArea 	As array
Local aAreaSM0  As array
Local cFilAntB  := "" As Character
Local cTxtFil   := "" As Character

nThreads 	:= SuperGetMv("MV_PCOTHRE",.T.,1)
cAliasEnt	:= GetEntFilt(AKB->AKB_PROCES,AKB->AKB_ITEM)
cTbField 	:= If(SubStr(cAliasEnt,1,1)== "S",SubStr(cAliasEnt,2),cAliasEnt)
aProcs 	    := {}
cQuery	    := ""
cUpdate	    := ""
cFiltro	    :=	PcoParseFil(aRet[DEF_FILTRO],GetEntFilt(AKB->AKB_PROCES,AKB->AKB_ITEM),AKB->AKB_PROCES,AKB->AKB_ITEM)
nMed		:= 0
nMin		:= 0
nMax        := 0
nTot        := 0
nX          := 0

cTabMult    := ""
nThr		:= 0

aFilxProc := {} 
nCtd      := 0

cxFil     := ""
nPercThrd := 0
aProcFil  := {}
cCdFil    := StrTran(cFilAnt," ","")

aArea 	 := GetArea()
aAreaSM0 := SM0->(GetArea())
cFilAntB := cFilant

If cAliasEnt=="SC7" .And. AKB->AKB_PROCESS=="000054" .And. (AKB->AKB_ITEM=="15" .Or. AKB->AKB_ITEM="16")
	cTxtFil += "_FILENT"
Else
	cTxtFil += "_FILIAL"
Endif

if cAliasEnt <> NIL .AND. !empty(cAliasEnt)
	cQuery := "SELECT COUNT(*) AS TOT FROM " + RetSqlName(cAliasEnt) +  " " + cAliasEnt + " "
	cQuery += "WHERE D_E_L_E_T_=' ' AND " + cTbField + cTxtFil + " >= '" + xFilial(cAliasEnt,cFilialDe) +"'  AND  "+ cTbField + cTxtFil + " <='" + xFilial(cAliasEnt,cFilialAte) + If(Empty(cFiltro),"'","' AND (" + cFiltro + ")") 
	cQuery := ChangeQuery(cQuery)

	DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),"TRBTHR",.T.,.T.)

	nTot	:= TRBTHR->TOT
	TRBTHR->(DbCLoseArea())

	nThreads := iIf( nTot <= 999 .OR. nTot < nThreads, 1,nThreads)   //menor que 1000 lancamentos nao faz em multi-thread

	If nThreads > 1 .And. nTot >= nThreads

		cQuery := " SELECT "+cTbField + "_FILIAL TRBXFIL, "+" COUNT(*) AS TOTREG FROM " + RetSqlName(cAliasEnt) +  " " + cAliasEnt + " "
		cQuery += " WHERE D_E_L_E_T_=' ' AND " + cTbField + cTxtFil + " >= '" + xFilial(cAliasEnt,cFilialDe) +"'  AND  "+ cTbField + cTxtFil + " <='" + xFilial(cAliasEnt,cFilialAte) + If(Empty(cFiltro),"'","' AND (" + cFiltro + ")") 
		cQuery += " GROUP BY "+cTbField + "_FILIAL "

		cQuery := ChangeQuery(cQuery)

		DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),"TRBTHR",.T.,.T.)
		aFilxProc := {}
		Do While TRBTHR->(!Eof())
			nPercThrd :=TRBTHR->TOTREG/nTot
			//aFilxProc 
			//Elemento 1 - Campo Filial da Tabela Origem
			//Elemento 2 - Total de Registro existente
			//Elemento 3 - Percentual --> Total de Registros da Filial / Total de Registros a serem processados de todas as filiais
			//Elemento 4 - Percentual de treads a ser levantada com base no parametro 
			//Elemento 5 - Numero de Treads a ser levantada -- se percentual for menor que 1 entao considera 1 thread
			aAdd(aFilxProc, { TRBTHR->TRBXFIL, TRBTHR->TOTREG, nPercThrd, nPercThrd*nThreads, If(nPercThrd*nThreads<1, 1, Int(nPercThrd*nThreads)) })

			TRBTHR->(DbSkip())
		EndDo
		TRBTHR->(DbCLoseArea())
		
		For nCtd := 1 TO Len(aFilxProc)
			If !MoniThread(aRet,aFilxProc[nCtd,1], nCtd)
				Return
			EndIf
		Next

		For nCtd := 1 TO Len(aFilxProc)
			cxFil := aFilxProc[nCtd,1]
			nTot  := aFilxProc[nCtd,2]
			aProcs := {}

			nMed	:= Round( nTot / aFilxProc[nCtd,5] /*nThreads*/ ,0) + 1  //Colocado +1 para nao 

			dbSelectArea("SM0")
			DbSeek(cEmpAnt+cxFil,.t.)
			
			bEmpWhile := {|| SM0->(!Eof()) .and. SM0->M0_CODIGO == cEmpAnt .and. ;
							Alltrim(FWxFilial(cAliasEnt,SM0->M0_CODFIL)) == Alltrim(cxFil) }
			While Eval(bEmpWhile)
				cFilAnt := IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL )
				cCdFil    := StrTran(cFilAnt," ","")

				cQuery := "SELECT R_E_C_N_O_ AS REC FROM " + RetSqlName(cAliasEnt) + " " + cAliasEnt + " " 
				cQuery += "WHERE D_E_L_E_T_=' ' AND " + cTbField + cTxtFil + "='" + xFilial(cAliasEnt) + If(Empty(cFiltro),"'","' AND (" + cFiltro + ")") +" ORDER BY R_E_C_N_O_" 
			
				cQuery := ChangeQuery(cQuery)
				DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),"TRBTHR",.T.,.T.)

				nX	:= 0   //controle de quantos registros por thread
				ProcRegua(nTot)

				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณCria uma tabela para Thread. ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				aStruSQL := {}
				AADD(aStruSQL,{"R_E_C_"  	,"N",10,00})
				AADD(aStruSQL,{"THREAD"  	,"C",02,00})
				
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณCaptura a query  para os registrosณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณMonta a Clausula da SELECTณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				If TRBTHR->(!Eof())

					cTabMult	:= "TMP" + cCdFil + cAliasEnt + cValToChar(nCtd) + StrZero(1,2)
					If TCCanOpen(cTabMult)
						If Select(cTabMult)>0
							(cTabMult)->(DbCloseArea())				
						EndIf			
						MsErase(cTabMult)
					EndIf
							
					MsCreate(cTabMult, aStruSQL, 'TOPCONN' )
					dbUseArea( .T., 'TOPCONN', cTabMult, cTabMult, .T., .F. )		
					
					aAdd( aProcs , { StrZero(1,2) , 0 , TRBTHR->REC , TRBTHR->REC+nMed , cTabMult } )

					Do While TRBTHR->(!Eof())

						DbSelectArea(cAliasEnt)
						DbGoto(TRBTHR->REC)
						DbSelectArea(cTabMult)

						RecLock(cTabMult,.T.)
						(cTabMult)->(R_E_C_) := (cAliasEnt)->(Recno())
						(cTabMult)->(THREAD) := StrZero(Len(aProcs),2)
						(cTabMult)->(MsUnlock())
						IncProc()
						nX++

						TRBTHR->(DbSkip())

						If TRBTHR->(!Eof()) .And. nMed == nX   //para quebrar em multiplas threads

							(cTabMult)->(DbCloseArea())
							cTabMult	:= "TMP" + cCdFil + cAliasEnt + cValToChar(nCtd) + StrZero(Len(aProcs)+1,2 ) 
							If TCCanOpen(cTabMult)
								MsErase(cTabMult)
							EndIf
							MsCreate(cTabMult, aStruSQL, 'TOPCONN' )
							dbUseArea( .T., 'TOPCONN', cTabMult, cTabMult, .T., .F. )
							aAdd( aProcs , { StrZero(Len(aProcs)+1,2) , 0 , TRBTHR->REC , TRBTHR->REC+nMed , cTabMult } )						
							
							nX	:= 1
						EndIf	

					EndDo
					TRBTHR->(DbCLoseArea())
					(cTabMult)->(DbCloseArea())

				EndIf
					
				For nX := 1 to Len(aProcs)
					conout('INI = THREAD:' + aProcs[nX][1] + "[" + Alltrim(Str(aProcs[nX][3])) + "][" + Alltrim(Str(aProcs[nX][4])) + "] " + " as " + TIME())
					StartJob("PcoThr310",GetEnvServer(),.F., aProcs[nX][5] ,cEmpAnt,cFilAnt,cValToChar(nCtd)+aProcs[nX][1],AKB->(GetArea()),aRet)
					nThr++
				Next nX
				
				aSize(aProcs,0)

				While Eval(bEmpWhile)
					SM0->(dbSkip())
				Enddo
			EndDo

		Next

		If !lAtuSld
			Aviso( STR0033 , STR0039 +AllTrim(STR(nThr))+ STR0040 +CRLF +STR0041, {STR0012} ) //"Aviso!" //"Foram iniciados " //" processos simultaneos (Threads) para reprocessamento." //"Assim que todos os processos forem finalizados, ้ recomendada a atualiza็ใo dos saldos dos Cubos." //"Fechar"
		EndIf

	else  
		//faz processamento normal sem multiThread
		cFltAux := aRet[DEF_FILTRO]
		dbSelectArea("SM0")
		DbSeek(cEmpAnt+cFilialDe,.t.)
		While !SM0->(Eof()) .and. SM0->M0_CODIGO == cEmpAnt .and.	SM0->M0_CODFIL >= cFilialDe .and.; 
																	SM0->M0_CODFIL <= cFilialAte
				
			cFilAnt := IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL )
			If aScan(aProcFil, xFilial(cAliasEnt)) == 0
				aRet[DEF_FILTRO] := cFltAux + " .and. "+cAliasEnt+"->"+cTbField+"_FILIAL == '"+xFilial(cAliasEnt)+"' "
				Processa({|| ProcLanc(aRet,,,lAtuSld)}, STR0013, STR0015 )		// "Processando lan็amentos" ### "Gerando lancamentos..."
				aAdd(aProcFil, xFilial(cAliasEnt) )
			EndIf
			SM0->(DbSkip())	
		
		EndDo
	EndIf
Endif
cFilant := cFilAntB
RestArea(aArea)
RestArea(aAreaSM0)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCOA310   บAutor  ณMicrosiga           บ Data ณ  05/22/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function PcoThr310(cTable As Character,cEmp As Character,cFil As Character,cMark As Character,aAreaAKB As Array,aRet As Array)

Local cAliasEnt As Character
Local cTbField  As Character
Local lAtuSld 	As Logical

Default cTable := ""
Default cEmp   := ""
Default cFil   := ""
Default cMark  := ""
Default aAreaAKB := {}
Default aRet     := {}

cAliasEnt := ""
cTbField  := ""  
lAtuSld   := .F.		

RpcSetType(3)
// Seta job para empresa filial desejada
RpcSetEnv( cEmp, cFil,,,'PCO')

//*******************************
// reprocessamento Multi-Filial *
//*******************************
If Len(aRet)>6
	DEF_DATINI := 4
	DEF_DATFIN := 5
	DEF_FILTRO := 6
	lAtuSld	   := aRet[8]
Else
	DEF_DATINI := 2
	DEF_DATFIN := 3
	DEF_FILTRO := 4
	lAtuSld	   := aRet[6]
EndIf	    
                                                	
If LockByName("PCOA310_RUN_" + cMark ,.T.,.T.,.T.) 
	     
	DbSelectArea("AKB")
	DbSelectArea("AKD")
	DbSelectArea("AKS")
	DbSelectArea("AKT")
	
	RestArea(aAreaAKB)
	
	cAliasEnt	:= GetEntFilt(AKB->AKB_PROCES,AKB->AKB_ITEM)
	dbUseArea( .T., 'TOPCONN', cTable, cTable, .T., .F. )
	DbSelectArea(cTable)

	ProcLanc(aRet,.T.,cTable,lAtuSld)
		
	conout('FIM = EMP:' + cEmp + ' FIL:' + cFil  + 'THREAD:' + cMark + " as " + TIME() + " ----" + aRet[DEF_FILTRO])
	UnLockByName("PCOA310_RUN_" + cMark ,.T.,.T.,.T.)
	(cTable)->(DbCloseArea())
	MsErase(cTable)
Else
	conout('ERRO= EMP:' + cEmp + ' FIL:' + cFil  + 'THREAD:' + cMark + " as " + TIME())
EndIf

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCOA310   บAutor  ณMicrosiga           บ Data ณ  05/22/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function ProcLanc(aRet As Array, lThread As Logical, cTable As Character, lAtuSld As Logical)

Local nIndex As Numeric
Local cIndex As Character
Local cFiltro As Character
Local lCloseArea As Logical
Local bWhile As Codeblock
Local cAlias As Character
Local cProcesso As Character
Local cItem As Character
Local cAliasEntid As Character
Local cTbField As Character
Local nLimTran As Numeric
Local nLimCount As Numeric
Local cCubIni As Character
Local cCubFim As Character
Local lTemReg As Logical
Local lProc054 As Logical
Local __oQry As Object
Local nParam As Numeric

nIndex      := 0
cIndex      := ""
cFiltro     := ""
lCloseArea  := .F.
bWhile      := {||}
cAlias      := ""
cProcesso   := ""
cItem       := ""
cAliasEntid := ""
cTbField    := ""
nLimTran    := SuperGetMv("MV_PCOLIMI",.T.,9999)
nLimCount   := 0 
cCubIni     := ""
cCubFim     := ""
lTemReg     := .F.
lProc054    := .F.
__oQry      := Nil
nParam      := 1

//****************************************************
// Esta variavel so esta com .T. quando a fun็ใo ้   *
// solicitada por uma Thread de processamento. Neste *
// caso serแ utilizada uma tabela temporaria para    *
// posicionar os recnos a serem processados.         *
//****************************************************
Default lThread := .F.
Default lAtuSld := .F.

cProcesso := AKB->AKB_PROCES
cItem := AKB->AKB_ITEM
cAliasEntid := GetEntFilt(cProcesso,cItem)

PcoIniLan(AKB->AKB_PROCES)

Begin Transaction
	dbSelectArea(GetEntFilt(AKB->AKB_PROCES,AKB->AKB_ITEM))
	dbSetOrder(1) 
	If !lThread
		ProcRegua(RecCount())
	Else
		(cTable)->(ProcRegua(RecCount()))
	EndIf
	
	//************************************************
	// Coni็ใo para Filtro SQL e quando nใo ้ Thread *
	//************************************************
	If !Empty(aRet[DEF_FILTRO]) .and. !lThread
		cFiltro	:=	PcoParseFil(aRet[DEF_FILTRO],GetEntFilt(AKB->AKB_PROCES,AKB->AKB_ITEM),AKB->AKB_PROCES,AKB->AKB_ITEM)
		If !Empty(cFiltro)
			If AKB->AKB_PROCES == "000054" .And. (AKB->AKB_ITEM == "15" .Or. AKB->AKB_ITEM == "16")
				lProc054 := .T.
			EndIf
			
			cQuery 	:= " SELECT " + GetEntFilt(AKB->AKB_PROCES,AKB->AKB_ITEM) + ".R_E_C_N_O_ RECTAB "
			If lProc054
				cQuery += ", SD1.R_E_C_N_O_ RECSD1 "
			EndIf
			cQuery 	+= "  FROM " + RetSQLName(GetEntFilt(AKB->AKB_PROCES,AKB->AKB_ITEM)) + " " +GetEntFilt(AKB->AKB_PROCES,AKB->AKB_ITEM)
			If lProc054
				cQuery += " INNER JOIN " + RetSQLName("SD1") + " SD1 ON "
				cQuery += " SD1.D1_FILIAL = ? " // Ordens dos campos conforme o indice 22 - D1_FILIAL+D1_PEDIDO+D1_ITEMPC
				cQuery += " AND SD1.D1_PEDIDO = " + GetEntFilt(AKB->AKB_PROCES,AKB->AKB_ITEM) + ".C7_NUM "
				cQuery += " AND SD1.D1_ITEMPC = " + GetEntFilt(AKB->AKB_PROCES,AKB->AKB_ITEM) + ".C7_ITEM "
				cQuery += " AND SD1.D_E_L_E_T_ = ' ' "
			EndIf
			cQuery 	+= "  WHERE (?) AND "// Adiciona expressao de filtro convertida para SQL
			cQuery 	+= GetEntFilt(AKB->AKB_PROCES,AKB->AKB_ITEM) + ".D_E_L_E_T_ = ' ' "
			If ExistBlock( "PCOA3103" )
				//P_Eฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//P_Eณ Ponto de entrada utilizado para inclusao de funcoes de usuarios na     ณ
				//P_Eณ preparacao da query para reprocessamento dos Lancamentos               ณ
				//P_Eณ Parametros : cProcesso, cItem, aClone(aRet), cAliasEntid, cQuery       ณ
				//P_Eณ Retorno    : cQuery      expressao da query                            ณ
				//P_Eภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				cQuery := ExecBlock( "PCOA3103", .F., .F.,{cProcesso,cItem,aClone(aRet),cAliasEntid,cQuery})
			EndIf
						
			cQuery 	+= " ORDER BY  " + SqlOrder((GetEntFilt(AKB->AKB_PROCES,AKB->AKB_ITEM))->(IndexKey()))			
			cQuery 	:= ChangeQuery(cQuery)

			__oQry := FWPreparedStatement():New(cQuery)
			
			If lProc054
				__oQry:SetString(nParam++, FWxFilial("SD1"))
			EndIf
			__oQry:SetNumeric(nParam++, cFiltro)

			MPSYSOpenQuery(__oQry:GetFixQuery(), "PCOTRB")
			DbSelectArea("PCOTRB")
			cAlias := Alias()
			lCloseArea	:=	.T.
		Else
			cIndex := CriaTrab(,.F.)
			IndRegua(GetEntFilt(AKB->AKB_PROCES,AKB->AKB_ITEM),cIndex,IndexKey(),,aRet[DEF_FILTRO])
			nIndex := RetIndex(GetEntFilt(AKB->AKB_PROCES,AKB->AKB_ITEM))
			dbSelectArea(GetEntFilt(AKB->AKB_PROCES,AKB->AKB_ITEM))
			dbSetOrder(nIndex+1)
			cAlias := Alias()
		Endif
		DbGoTop()
		bWhile := { || ! (cAlias)->(Eof()) }
	Else

		//*****************************
		// Condi็ใo para Filtro ADVPL *
		//*****************************
		If !lThread
			dbSeek(xFilial())
			cAlias := Alias()
			
			If  SubStr( cAlias, 1, 1) == "S" 
				//se a primeira letra do alias for "S" entao	
				//considera campo filial a partir da segunda exemplo tabela SA1 - campo A1_FILIAL
				bWhile := {|| (cAlias)->(!Eof()) .And. &(SubStr( cAlias, 2, 2 ) + "_FILIAL") == xFilial() }
			Else			
				bWhile := {|| (cAlias)->(!Eof()) .And. &(cAlias + "_FILIAL") == xFilial() }
			EndIf
		Else
		//***************************************
		// Condi็ใo para utiliza็ใo com Threads *
		//***************************************
			bWhile := {|| (cTable)->(!Eof()) }
		EndIf
	Endif
	
	While Eval(bWhile)
		
		lTemReg := .T.
		
		dbSelectArea(GetEntFilt(AKB->AKB_PROCES,AKB->AKB_ITEM))
		If lThread
			//*****************************************
			// Posiciona Recno da tabela temporaria   *
			// utilizada pela Thread de Processamento *
			//*****************************************
	  		(cAliasEntid)->(DbGoto((cTable)->(R_E_C_)))
	  	Endif		
		If lCloseArea
			(GetEntFilt(AKB->AKB_PROCES,AKB->AKB_ITEM))->(MsGoTo(PCOTRB->RECTAB))
			If lProc054
				SD1->(MsGoTo(PCOTRB->RECSD1))
			EndIf
		Endif	
		IncProc()
		If A310FilInt(AKB->AKB_PROCES,AKB->AKB_ITEM,aRet)
			
			If !DetProc(AKB->AKB_PROCES,AKB->AKB_ITEM)    //processos normais

				If nLimCount >= nLimTran
					//*****************************************
					// O Comentario deste Bloco deve ser      *
					// retirado em caso de DeadLock no banco  *
					//*****************************************
					/*nXz := 1
					While nXz<4 .and. !LockByName("PCOA310_RUN_FINLAN",.T.,.T.,.T.)
						Sleep(1)
						nXz++
					EndDo
               	    If nXz<4*/
						EndTran()
						PcoFinLan(AKB->AKB_PROCES,.F.,.T.,,.F./*lAtuSld*/)
						//UnLockByName("PCOA310_RUN_FINLAN",.T.,.T.,.T.)
						PcoIniLan(AKB->AKB_PROCES)
						BeginTran()
						nLimCount := 0
					/*Else
						nLimCount++
					EndIf*/
				Else
					nLimCount++
				EndIf
				PcoDetLan(AKB->AKB_PROCES,AKB->AKB_ITEM,"PCOA310")			

			Else
                //processos de rateio que utilizam outra tabela alem da de origem
			    If  (AKB->AKB_PROCES == "000002" .And. (AKB->AKB_ENTIDA == "SEZ" .OR.AKB->AKB_ENTIDA == "SEV") .OR. ;
					AKB->AKB_PROCES == "000001" .And. (AKB->AKB_ENTIDA == "SEZ" .OR.AKB->AKB_ENTIDA == "SEV") )			    

					aDetProc	:=	GetDetProc(AKB->AKB_PROCES,AKB->AKB_ITEM)
					DbSelectArea(aDetProc[1,1])
					DbSetOrder(aDetProc[1,2])
					DbSeek(Eval(aDetProc[1,3]))
					While !Eof() .And. Eval(aDetProc[1,4])
						//SEV
						If Len(aDetProc)==1
							PcoDetLan(AKB->AKB_PROCES,AKB->AKB_ITEM,"PCOA310")
							DbSelectArea(aDetProc[1,1])
							DbSkip()
						Else
						//SEZ
							DbSelectArea(aDetProc[2,1])
							DbSetOrder(aDetProc[2,2])
							DbSeek(Eval(aDetProc[2,3]))
							While !Eof() .And. Eval(aDetProc[2,4])
								PcoDetLan(AKB->AKB_PROCES,AKB->AKB_ITEM,"PCOA310")
								DbSelectArea(aDetProc[2,1])
								DbSkip()
							Enddo
							DbSelectArea(aDetProc[1,1])
							DbSkip()
						Endif
					Enddo					
					dbSelectArea(GetEntFilt(AKB->AKB_PROCES,AKB->AKB_ITEM))

			    ElseIf AKB->AKB_PROCES == "000054" 
			    			    
			    	If	AKB->AKB_ITEM $ '09|10|11' .And. AKB->AKB_ENTIDA == "SDE"
						aDetProc :=	GetDetProc(AKB->AKB_PROCES,AKB->AKB_ITEM)
						DbSelectArea(aDetProc[1,1])
						DbSetOrder(aDetProc[1,2])
						If DbSeek(Eval(aDetProc[1,3])) 
							Posic_Tabelas( aDetProc[1,5] )
						EndIf	
						Do While !Eof() .And. Eval(aDetProc[1,4])
							PcoDetLan(AKB->AKB_PROCES,AKB->AKB_ITEM,"PCOA310")
							DbSelectArea(aDetProc[1,1])
							DbSkip()
						EndDo
						dbSelectArea(GetEntFilt(AKB->AKB_PROCES,AKB->AKB_ITEM))
					ElseIf AKB->AKB_ITEM $ '01|05' .And. AKB->AKB_ENTIDA == "SD1"	
						aDetProc :=	GetDetProc(AKB->AKB_PROCES,AKB->AKB_ITEM)
						DbSelectArea(aDetProc[1,1])
						DbSetOrder(aDetProc[1,2])
						DbSeek(Eval(aDetProc[1,3])) 
   						If Eval(aDetProc[1,6])
							PcoDetLan(AKB->AKB_PROCES,AKB->AKB_ITEM,"PCOA310")
						EndIf
						DbSelectArea(aDetProc[1,1])
						dbSelectArea(GetEntFilt(AKB->AKB_PROCES,AKB->AKB_ITEM))
					EndIf
					
				// Processos de movimentacao internas, producao e acerto de inventario devem gerar os 
				// lancamentos na tabela AKD de acordo com o campo D3_TM da tabela SD3.
				ElseIf AKB->AKB_PROCES $ "000151|000152|000153" .And.;
						AKB->AKB_ITEM $ "01|02" .And.;
						AKB->AKB_ENTIDA == "SD3"

					// Movimentos internos
					If AKB->AKB_PROCES == "000151"
						If AKB->AKB_ITEM == "01" .And. SD3->D3_TM <= "500"
							PcoDetLan(AKB->AKB_PROCES,AKB->AKB_ITEM,"PCOA310")
						ElseIf AKB->AKB_ITEM == "02" .And. SD3->D3_TM > "500"
							PcoDetLan(AKB->AKB_PROCES,AKB->AKB_ITEM,"PCOA310")
						EndIf             
					// Producao
					ElseIf AKB->AKB_PROCES == "000152" .And. SubStr(SD3->D3_CF,1,2) $ "PR|ER"
						If AKB->AKB_ITEM == "01" .And. SD3->D3_TM <= "500"
							PcoDetLan(AKB->AKB_PROCES,AKB->AKB_ITEM,"PCOA310")
						ElseIf AKB->AKB_ITEM == "02" .And. SD3->D3_TM > "500"
							PcoDetLan(AKB->AKB_PROCES,AKB->AKB_ITEM,"PCOA310")
						EndIf                                            
					// Inventario
					ElseIf AKB->AKB_PROCES == "000153" .And. SD3->D3_DOC == "INVENT"
						If AKB->AKB_ITEM == "01" .And. SD3->D3_TM <= "500"
							PcoDetLan(AKB->AKB_PROCES,AKB->AKB_ITEM,"PCOA310")
						ElseIf AKB->AKB_ITEM == "02" .And. SD3->D3_TM > "500"
							PcoDetLan(AKB->AKB_PROCES,AKB->AKB_ITEM,"PCOA310")
						EndIf
					EndIf	
				ElseIf AKB->AKB_PROCES == "000358" .And. AKB->AKB_ITEM == '01' // Rotina de planejamento orcamentario
					DbSelectArea("ALX")
					DbSetOrder(2)
					If DbSeek(xFilial("ALX")+ALY->ALY_PLANEJ+ALY->ALY_VERSAO+ALY->ALY_SEQ) // Posiciona Tabela ALX
					
						PcoDetLan(AKB->AKB_PROCES,AKB->AKB_ITEM,"PCOA310")
					
					EndIf
				EndIf            

			Endif			
		EndIf
		
		If lCloseArea
			dbSelectArea("PCOTRB")
		Else
			dbSelectArea(GetEntFilt(AKB->AKB_PROCES,AKB->AKB_ITEM))
		Endif
		If !lThread
			(cAlias)->(dbSkip())		
		Else
			If (cTable)->(FieldPos("THREAD"))>0
				//***********************************
				// Retira flag para reprocessamento *
				// da na Thread.                    *
				//***********************************
				RecLock(cTable,.F.)
				(cTable)->(FieldPut(FieldPos("THREAD"),""))
				MsUnlock()
			EndIf		
			(cTable)->(dbSkip())
		EndIf
	EndDo                        
	If lCloseArea
		DbSelectArea("PCOTRB")
		DbCloseArea()
		DbSelectArea(GetEntFilt(AKB->AKB_PROCES,AKB->AKB_ITEM))
	Endif		
End Transaction		      

PcoFinLan(AKB->AKB_PROCES,.F.,.T.,,.F./*lAtuSld*/)

If lAtuSld .And. lTemReg
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Atualiza Saldos dos Cubos         ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	dbSelectArea("AL1")
	AL1->(dbSetOrder(1))
	If AL1->(dbSeek(xFilial("AL1"))) //Verifica se existe Cubo cadastrado
		cCubIni := AL1->AL1_CONFIG
		AL1->(dbSeek(xFilial("AL1")+Replicate('z',TamSX3("AL1_CONFIG")[1]),.T.))
		AL1->(dbSkip(-1)) 
	 	cCubFim := AL1->AL1_CONFIG
	  	PCOA301EXE(,.T.,{cCubIni,cCubFim,aRet[DEF_DATINI],aRet[DEF_DATFIN],.T.,""}) //Atualizar Saldo dos Cubos
	EndIf	
EndIf

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCOA310   บAutor  ณMicrosiga           บ Data ณ  05/22/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function GetEntFilt(cProcesso,cItem)
	Local aArea := GetArea()
	Local cRet as Character
	
	cRet := ""
	DbSelectArea('AKB')
	DbSetOrder(1)
	If MsSeek(xFilial()+cProcesso+cItem)
		cRet	:=	AKB->AKB_ENTIDA
		If cProcesso == "000002" .And. (AKB->AKB_ENTIDA == "SEZ" .OR.AKB->AKB_ENTIDA == "SEV")
			cRet	:=	"SE2"                                                                       
		ElseIf cProcesso == "000001" .And. (AKB->AKB_ENTIDA == "SEZ" .OR.AKB->AKB_ENTIDA == "SEV")
			cRet	:=	"SE1"       
		ElseIf cProcesso == "000054" .And. AKB->AKB_ENTIDA == "SDE"
			cRet	:=	"SD1"       
		Endif
	Endif

	RestArea(aArea)
Return cRet              


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCOA310   บAutor  ณMicrosiga           บ Data ณ  05/22/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function DetProc(cProcesso, cItem)
Local lRet	:=	.F.
If cProcesso == "000002" .And. (cItem == '04' .OR. cItem == '05')
	lRet	:=	.T.
ElseIf cProcesso == "000001" .And. (cItem == '04' .OR. cItem == '05')
	lRet	:=	.T.
ElseIf cProcesso == "000054" .And. cItem $ '09|10|11'
	lRet	:=	.T.
ElseIf cProcesso == "000054" .And. cItem $ '01|05'
	lRet	:=	.T.
ElseIf cProcesso $ "000151|000152|000153" .And. cItem $ '01|02'
	lRet	:=	.T.
ElseIf cProcesso $ "000358" .And. cItem $ '01' // Rotina de planejamento orcamentario
	lRet	:=	.T.
Endif	                                                                	
Return lRet              


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCOA310   บAutor  ณMicrosiga           บ Data ณ  05/22/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function GetDetProc(cProcesso, cItem)
// Local lRet		:=	.F.
Local aDetProc	:=	{}
Local cChaveSEV	:= ""
Local cChaveSDE	:= ""
Local cChaveSD1	:= ""
         
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณEstrutura do Array aDetProc                                                                ณ
//ณ                                                                                           ณ
//ณaDetProc[n,1] - Alias da tabela principal do lancamento na AKD                             ณ
//ณaDetProc[n,2] - Indice para posicionamento (dbSetOrder)                                    ณ
//ณaDetProc[n,3] - Chave do registro posicionado para pesquisa na tabela principal            ณ
//ณaDetProc[n,4] - Chave para condicao do loop                                                ณ
//ณaDetProc[n,5] - Tabelas para posicionar a partir da tabela principal (funcao Posic_Tabelas)ณ
//ณaDetProc[n,5,1] - Alias da tabela secundaria                                               ณ
//ณaDetProc[n,5,2] - Ordem para pesquisa                                                      ณ
//ณaDetProc[n,5,3] - Chave para pesquisa                                                      ณ
//ณaDetProc[n,6] - Condicao de filtro para nao processar linha da tabela principal            ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If cProcesso == "000002"  .And. (cItem == '04' .Or. cItem == '05')
	aDetProc	:=	Array(1,4)
	aDetProc[1,1]	:=	"SEV"
	aDetProc[1,2]	:=	2                
	cChaveSeV := RetChaveSev("SE2")
	aDetProc[1,3]	:=	&('{|| "' + cChaveSEV + '"}')
	aDetProc[1,4]	:=	&('{|| xFilial("SEV")+SEV->(EV_PREFIXO+EV_NUM+EV_PARCELA+EV_TIPO+EV_CLIFOR+EV_LOJA+EV_IDENT) == "' + cChaveSEV +"1"+'"}')
	If cItem == '05'
		AAdd(aDetProc,Array(4))
		aDetProc[2,1]	:=	"SEZ"
		aDetProc[2,2]	:=	4
		cChaveSeV := RetChaveSev("SE2",,"SEZ")
		aDetProc[2,3]	:=	&('{|| "' + cChaveSEV + '"+ SEV->EV_NATUREZ }')
		aDetProc[2,4]	:=	&('{|| xFilial("SEZ")+SEZ->(EZ_PREFIXO+EZ_NUM+EZ_PARCELA+EZ_TIPO+EZ_CLIFOR+EZ_LOJA+EZ_NATUREZ+EZ_IDENT) == "' + cChaveSEV +'"+SEV->EV_NATUREZ+"1"}')
	Endif
ElseIf cProcesso == "000001" .And. (cItem == '04' .OR. cItem == '05')
	aDetProc	:=	Array(1,4)
	aDetProc[1,1]	:=	"SEV"
	aDetProc[1,2]	:=	2                
	cChaveSeV := RetChaveSev("SE1")
	aDetProc[1,3]	:=	&('{|| "' + cChaveSEV + '"}')
	aDetProc[1,4]	:=	&('{|| xFilial("SEV")+SEV->(EV_PREFIXO+EV_NUM+EV_PARCELA+EV_TIPO+EV_CLIFOR+EV_LOJA+EV_IDENT) == "' + cChaveSEV +"1"+'"}')
	If cItem == '05'      
		AAdd(aDetProc,Array(4))
		aDetProc[2,1]	:=	"SEZ"
		aDetProc[2,2]	:=	4
		cChaveSeV := RetChaveSev("SE1",,"SEZ")
		aDetProc[2,3]	:=	&('{|| "' + cChaveSEV + '"+ SEV->EV_NATUREZ }')
		aDetProc[2,4]	:=	&('{|| xFilial("SEZ")+SEZ->(EZ_PREFIXO+EZ_NUM+EZ_PARCELA+EZ_TIPO+EZ_CLIFOR+EZ_LOJA+EZ_NATUREZ+EZ_IDENT) == "' + cChaveSEV +'"+SEV->EV_NATUREZ+"1"}')
	Endif
ElseIf cProcesso == "000054" .And. cItem $ '09|10|11'
	aDetProc	:=	Array(1,5)
	aDetProc[1,1]	:=	"SDE"
	aDetProc[1,2]	:=	1
	cChaveSDE 		:=  RetChaveSDE("SD1")
	aDetProc[1,3]	:=	&('{|| "' + cChaveSDE  + '"}')
	aDetProc[1,4]	:=	&('{|| xFilial("SDE")+SDE->(DE_DOC+DE_SERIE+DE_FORNECE+DE_LOJA+DE_ITEMNF) == "' + cChaveSDE +'" }')
	aDetProc[1,5]	:=	{}   //ARRAY PARA POSICIONAR TABELAS CONFORME ITEM 	
	aAdd(aDetProc[1,5], { "SF1", 1, &('{|| "' + RetChaveSDE("SD1",,"SF1") + '"}') })
	aAdd(aDetProc[1,5], { "SB1", 1, &('{|| xFilial("SB1")+'+GetEntFilt(cProcesso,cItem)+'->D1_COD }') })
	aAdd(aDetProc[1,5], { "SA2", 1, &('{||  xFilial("SA2")+'+GetEntFilt(cProcesso,cItem)+'->(D1_FORNECE+D1_LOJA) }') })
ElseIf cProcesso == "000054" .And. cItem $ '01|05'
	aDetProc	:=	Array(1,6)
	aDetProc[1,1]	:=	"SD1"
	aDetProc[1,2]	:=	1                   
	cChaveSD1		:=	SD1->(IndexKey(1))
	aDetProc[1,3]	:=	&("{|| "+cChaveSD1+"}")
	aDetProc[1,4]	:=	{}
	aDetProc[1,5]	:=	{}   
	If cItem == "01"
		aDetProc[1,6] := {|| SD1->D1_TIPO <> "D"}
	Else	
		aDetProc[1,6] := {|| SD1->D1_TIPO == "D"}
	EndIf	
Endif	                                                                	

Return aDetProc


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCOA310   บAutor  ณMicrosiga           บ Data ณ  05/22/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function RetChaveSDE(cAlias,cCampo,cArqKey)
Local cChave

cArqKey := IIf(cArqKey == NIL,"SDE",cArqKey)

If cAlias $ "SD1|SF1"
	cCampo := Right(cAlias,2)
Endif
cChave := xFilial(cArqKey)+(cAlias)->&(cCampo+"_DOC")+(cAlias)->&(cCampo+"_SERIE")+;
		  					    (cAlias)->&(cCampo+"_FORNECE")+(cAlias)->&(cCampo+"_LOJA")+;
								If(cArqKey=='SF1', "", (cAlias)->&(cCampo+"_ITEM"))		  					    
Return cChave


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCOA310   บAutor  ณMicrosiga           บ Data ณ  05/22/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function Posic_Tabelas(aPosic)
Local nX
Local aArea := GetArea()
Local nOrdem := 0
Local nPosAlias

nPosAlias := ASCAN(aPosic, {|aVal| aVal[1] == aArea[1] })

For nX := 1 TO Len(aPosic)
	dbSelectArea(aPosic[nX,1])
	nOrdem := IndexOrd()
	dbSetOrder(aPosic[nX,2])
	dbSeek(Eval(aPosic[nX,3]))
	//depois que posicionou retorna para dbsetorder() de origem
	//atencao -> nao pode ser utilizado Getarea() / RestArea() - deve ficar posicionado
	dbSetOrder(nOrdem)
Next

If nPosAlias > 0   //se tiver que posicionar na tabela atual soh retorna para alias
	dbSelectArea(aArea[1])
Else  //senao restaura a area
	RestArea(aArea)
EndIf	

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณPrograma  ณMenuDef   ณ Autor ณ Ana Paula N. Silva     ณ Data ณ29/11/06 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Utilizacao de menu Funcional                               ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณArray com opcoes da rotina.                                 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณParametros do array a Rotina:                               ณฑฑ
ฑฑณ          ณ1. Nome a aparecer no cabecalho                             ณฑฑ
ฑฑณ          ณ2. Nome da Rotina associada                                 ณฑฑ
ฑฑณ          ณ3. Reservado                                                ณฑฑ
ฑฑณ          ณ4. Tipo de Transao a ser efetuada:                        ณฑฑ
ฑฑณ          ณ		1 - Pesquisa e Posiciona em um Banco de Dados     ณฑฑ
ฑฑณ          ณ    2 - Simplesmente Mostra os Campos                       ณฑฑ
ฑฑณ          ณ    3 - Inclui registros no Bancos de Dados                 ณฑฑ
ฑฑณ          ณ    4 - Altera o registro corrente                          ณฑฑ
ฑฑณ          ณ    5 - Remove o registro corrente do Banco de Dados        ณฑฑ
ฑฑณ          ณ5. Nivel de acesso                                          ณฑฑ
ฑฑณ          ณ6. Habilita Menu Funcional                                  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ   DATA   ณ Programador   ณManutencao efetuada                         ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ          ณ               ณ                                            ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function MenuDef()
Local aUsRotina := {}
Local aRotina 	:= {	{ STR0002,		"AxPesqui", 0 , 1},;     //"Pesquisar // Buscar"
							{ STR0003, 	"A310DLG" , 0 , 2}, ; //"Reprocessar"
							{ "View Log", 	"ProcLogView()" , 0 , 2} } 
						
If AMIIn(57) // AMIIn do modulo SIGAPCO ( 57 )

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Adiciona botoes do usuario no aRotina                                  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If ExistBlock( "PCOA3101" )
		//P_Eฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//P_Eณ Ponto de entrada utilizado para inclusao de funcoes de usuarios no     ณ
		//P_Eณ browse da tela de Configuracao dos Lancamentos                         ณ
		//P_Eณ Parametros : Nenhum                                                    ณ
		//P_Eณ Retorno    : Array contendo as rotinas a serem adicionados na enchoice ณ
		//P_Eณ               Ex. :  User Function PCOA3101                            ณ
		//P_Eณ                      Return {{"Titulo", {|| U_Teste() } }}             ณ
		//P_Eภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If ValType( aUsRotina := ExecBlock( "PCOA3101", .F., .F. ) ) == "A"
			AEval( aUsRotina, { |x| AAdd( aRotina, x ) } )
		EndIf
	EndIf
EndIf
Return(aRotina)

//-------------------------------------------------------------------
/*/{Protheus.doc}TotLanc()
Retorna quantidade de lan็amentos
@author Andr้ Brito
@since  14/03/2018
@version 12
/*/
//-------------------------------------------------------------------

Static Function TotLanc(aRet, cFilialDe, cFilialAte)

Local cAliasEnt	:= GetEntFilt(AKB->AKB_PROCESS,AKB->AKB_ITEM)
Local cTbField 	:= If(SubStr(cAliasEnt,1,1)== "S",SubStr(cAliasEnt,2),cAliasEnt)
Local cQuery	:= ""
Local cFiltro	:=	PcoParseFil(aRet[DEF_FILTRO],GetEntFilt(AKB->AKB_PROCESS,AKB->AKB_ITEM),AKB->AKB_PROCESS,AKB->AKB_ITEM)
Local nTotal    := 0
Local cTxtFil   :="" as Character

Default aRet    := {}

cQuery := " SELECT COUNT(*) AS TOT, MIN(R_E_C_N_O_) AS MIN, MAX(R_E_C_N_O_) AS MAX FROM " + RetSqlName(cAliasEnt) +  " " + cAliasEnt + " "
cQuery += " WHERE D_E_L_E_T_=' ' AND "

If cAliasEnt=="SC7" .And. AKB->AKB_PROCESS=="000054" .And. (AKB->AKB_ITEM=="15" .Or. AKB->AKB_ITEM="16")
	cTxtFil += "_FILENT"
Else
	cTxtFil += "_FILIAL"
Endif

If xFilial(cAliasEnt, cFilialDe) == xFilial(cAliasEnt, cFilialAte) 
	cQuery +=  cTbField + cTxtFil + "='" + xFilial(cAliasEnt, cFilialDe)
Else
	cQuery +=  cTbField + cTxtFil + ">='" + xFilial(cAliasEnt,cFilialDe) + "' AND " + cTbField + cTxtFil + "<='" + xFilial(cAliasEnt,cFilialAte)
EndIf
cQuery +=  If(Empty(cFiltro),"'","' AND (" + cFiltro + ")")
cQuery := ChangeQuery(cQuery)
DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),"TRBTOT",.T.,.T.)

nTotal	:= TRBTOT->TOT

TRBTOT->(DbCLoseArea())

Return nTotal
