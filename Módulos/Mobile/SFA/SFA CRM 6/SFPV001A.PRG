#INCLUDE "SFPV001A.ch"
// Folder da condição de pagamento negociada
// Marcelo Vieira  - 15/07/2005
//
Function FldCndNeg(aObj,oObj,aCabPed,oDlg,oFldCN,cTipoCnd)

ADD FOLDER oFldCN CAPTION STR0001 ON ACTIVATE ExibeCdN(aObj,aCabPed) OF oDlg //"Condicao Negociada" //"Cond.Negociada"
@ 30,001 TO 127,158 CAPTION STR0002 OF oFldCN //"Condicao Negociada" //"Condicao Negociada"
#IFDEF __PALM__
	// Para tela Palm
	@ 38,03 BUTTON oObj CAPTION STR0003 SIZE 20,15 of oFldCN //"1a"
	AADD(aObj[5],oObj) // 1-Label Parc 1
	@ 40,30 GET oObj VAR aCabPed[18,1] PICTURE "@E 99,999.99" SIZE 45,15 VALID vldTipo(cTipoCnd) of oFldCN
	// VALID VldTot(1,nTotalPed,oParc1,oParc2,oParc3,oParc4,oParc5,@nParc1,@nParc2,@nParc3,@nParc4,@nParc5) SIZE 50,15 of oFldCN
	AADD(aObj[5],oObj) // 2-Variavel da Parc 1
	@ 40,76 BUTTON oObj CAPTION STR0004 ACTION SelData(aObj[5,4],aCabPed[19,1])  SIZE 30,12 OF oFldCN //"Venc.1"
	AADD(aObj[5],oObj) // 3-Botao do venc 1
	@ 40,115 GET oObj VAR aCabPed[19,1] Picture "@D" READONLY of oFldCN
	AADD(aObj[5],oObj) // 4-Varivel venc 1
	@ 58,03 BUTTON oObj CAPTION  STR0005 SIZE 20,15 of oFldCN //"2a"
	AADD(aObj[5],oObj) // 5- Label Venc2
	@ 60,30 GET oObj VAR aCabPed[20,1] PICTURE "@E 99,999.99" SIZE 45,15 VALID vldTipo(cTipoCnd) of oFldCN
	//VALID VldTot(2,nTotalPed,oParc1,oParc2,oParc3,oParc4,oParc5,@nParc1,@nParc2,@nParc3,@nParc4,@nParc5) SIZE 50,15 of oFldCN
	AADD(aObj[5],oObj) // 6- Variavel parc 2
	@ 60,76 BUTTON oObj CAPTION STR0006 ACTION SelData(aObj[5,8],aCabPed[21,1]) SIZE 30,12 OF oFldCN //"Venc.2"
	AADD(aObj[5],oObj) // 7- Botao venc 2
	@ 60,115 GET oObj VAR aCabPed[21,1] Picture "@D" READONLY of oFldCN
	AADD(aObj[5],oObj)	// 8 - Variavel venc 3
	@ 78,03 BUTTON oObj CAPTION  STR0007 SIZE 20,15 of oFldCN //"3a"
	AADD(aObj[5],oObj) // 9 - Label Parc 3
	@ 80,30 GET oObj VAR aCabPed[22,1] PICTURE "@E 99,999.99" SIZE 45,15 VALID vldTipo(cTipoCnd) of oFldCN
	//VALID VldTot(3,nTotalPed,oParc1,oParc2,oParc3,oParc4,oParc5,@nParc1,@nParc2,@nParc3,@nParc4,@nParc5) SIZE 50,15 of oFldCN
	AADD(aObj[5],oObj) // 10 - Variavel parc 3
	@ 80,76 BUTTON oObj CAPTION STR0008 ACTION SelData(aObj[5,12],aCabPed[23,1])  SIZE 30,12 OF oFldCN //"Venc.3"
	AADD(aObj[5],oObj) // 11 - botao venc 3
	@ 80,115 GET oObj VAR aCabPed[23,1] Picture "@D" READONLY of oFldCN
	AADD(aObj[5],oObj) // 12 - variavel venc 3
	@ 98,03 BUTTON oObj CAPTION STR0009 SIZE 20,15 of oFldCN //"4a"
	AADD(aObj[5],oObj) // 13 - Label parc 4
	@ 100,30 GET oObj VAR aCabPed[24,1] PICTURE "@E 99,999.99" SIZE 45,15 VALID vldTipo(cTipoCnd) of oFldCN
	//VALID VldTot(4,nTotalPed,oParc1,oParc2,oParc3,oParc4,oParc5,@nParc1,@nParc2,@nParc3,@nParc4,@nParc5) SIZE 50,15 of oFldCN
	AADD(aObj[5],oObj) // 14 - Variavel parc 4
	@ 100,76 BUTTON oObj CAPTION STR0010 ACTION SelData(aObj[5,16],aCabPed[25,1])  SIZE 30,12 OF oFldCN //"Venc.4"
	AADD(aObj[5],oObj) // 15 - botao venc 4
	@ 100,115 GET oObj VAR aCabPed[25,1] Picture "@D" READONLY of oFldCN
	AADD(aObj[5],oObj) // 16 - Variavel venc 4
#ELSE
	// Pocket PC
	@ 38,03 BUTTON oObj CAPTION STR0003 SIZE 20,15 of oFldCN //"1a"
	AADD(aObj[5],oObj) // 1-Label Parc 1
	@ 40,30 GET oObj VAR aCabPed[18,1] PICTURE "@E 99,999.99" SIZE 50,15 of oFldCN
	// VALID VldTot(1,nTotalPed,oParc1,oParc2,oParc3,oParc4,oParc5,@nParc1,@nParc2,@nParc3,@nParc4,@nParc5) SIZE 50,15 of oFldCN
	AADD(aObj[5],oObj) // 2-Variavel da Parc 1
	@ 40,76 BUTTON oObj CAPTION STR0004 ACTION SelData(aObj[5,4],aCabPed[19,1])  SIZE 35,12 OF oFldCN //"Venc.1"
	AADD(aObj[5],oObj) // 3-Botao do venc 1
	@ 40,115 GET oObj VAR aCabPed[19,1] Picture "@D" READONLY of oFldCN
	AADD(aObj[5],oObj) // 4-Varivel venc 1
	@ 58,03 BUTTON oObj CAPTION  STR0005 SIZE 20,15 of oFldCN //"2a"
	AADD(aObj[5],oObj) // 5- Label Venc2
	@ 60,30 GET oObj VAR aCabPed[20,1] PICTURE "@E 99,999.99" SIZE 50,15 of oFldCN
	//VALID VldTot(2,nTotalPed,oParc1,oParc2,oParc3,oParc4,oParc5,@nParc1,@nParc2,@nParc3,@nParc4,@nParc5) SIZE 50,15 of oFldCN
	AADD(aObj[5],oObj) // 6- Variavel parc 2
	@ 60,76 BUTTON oObj CAPTION STR0006 ACTION SelData(aObj[5,8],aCabPed[21,1])  SIZE 35,12 OF oFldCN //"Venc.2"
	AADD(aObj[5],oObj) // 7- Botao venc 2
	@ 60,115 GET oObj VAR aCabPed[21,1] Picture "@D" READONLY of oFldCN
	AADD(aObj[5],oObj)	// 8 - Variavel venc 3
	@ 78,03 BUTTON oObj CAPTION  STR0007 SIZE 20,15 of oFldCN //"3a"
	AADD(aObj[5],oObj) // 9 - Label Parc 3
	@ 80,30 GET oObj VAR aCabPed[22,1] PICTURE "@E 99,999.99" SIZE 50,15 of oFldCN
	//VALID VldTot(3,nTotalPed,oParc1,oParc2,oParc3,oParc4,oParc5,@nParc1,@nParc2,@nParc3,@nParc4,@nParc5) SIZE 50,15 of oFldCN
	AADD(aObj[5],oObj) // 10 - Variavel parc 3
	@ 80,76 BUTTON oObj CAPTION STR0008 ACTION SelData(aObj[5,12],aCabPed[23,1])  SIZE 35,12 OF oFldCN //"Venc.3"
	AADD(aObj[5],oObj) // 11 - botao venc 3
	@ 80,115 GET oObj VAR aCabPed[23,1] Picture "@D" READONLY of oFldCN
	AADD(aObj[5],oObj) // 12 - variavel venc 3
	@ 98,03 BUTTON oObj CAPTION STR0009 SIZE 20,15 of oFldCN //"4a"
	AADD(aObj[5],oObj) // 13 - Label parc 4
	@ 100,30 GET oObj VAR aCabPed[24,1] PICTURE "@E 99,999.99" SIZE 50,15 of oFldCN
	//VALID VldTot(4,nTotalPed,oParc1,oParc2,oParc3,oParc4,oParc5,@nParc1,@nParc2,@nParc3,@nParc4,@nParc5) SIZE 50,15 of oFldCN
	AADD(aObj[5],oObj) // 14 - Variavel parc 4
	@ 100,76 BUTTON oObj CAPTION STR0010 ACTION SelData(aObj[5,16],aCabPed[25,1])  SIZE 35,12 OF oFldCN //"Venc.4"
	AADD(aObj[5],oObj) // 15 - botao venc 4
	@ 100,115 GET oObj VAR aCabPed[25,1] Picture "@D" READONLY of oFldCN
	AADD(aObj[5],oObj) // 16 - Variavel venc 4
#ENDIF

Return  

Function vldTipo(cTipoCnd)
Local lRet:=.f.
If cTipoCnd="9"
   lRet:=.T. 
endif
Return lRet 
