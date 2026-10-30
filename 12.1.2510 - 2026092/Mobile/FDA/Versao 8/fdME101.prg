#include "eADVPL.ch"    
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ MECrgCamp()         ³Autor: Paulo Amaral  ³ Data ³         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Modulo de Merchandising   	 			                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function MECrgCamp(aCamp,oBrwCamp)
aSize(aCamp,0)
dbSelectArea("HUO")
dbSetOrder(1)
dbGoTop()
While !Eof()
	AADD(aCamp,{HUO->HUO_CODCAMP	,AllTrim(HUO->HUO_DESC)})
	dbSkip()
Enddo
 
if oBrwCamp<>Nil
	SetArray(oBrwCamp,aCamp)
Endif

Return Nil


/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ MECrgScr()          ³Autor: Paulo Amaral  ³ Data ³         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Modulo de Merchandising   	 			                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function MECrgScr(cCodCamp,aScr,oBrwScr)
aSize(aScr,0)
dbSelectArea("HUW")
dbSetOrder(1)
dbSeek(RetFilial("HUW")+cCodCamp)

While !Eof() .And. HUW->HUW_FILIAL == RetFilial("HUW") .And. AllTrim(HUW->HUW_CODCAMP) == AllTrim(cCodCamp)
    HUZ->(dbSetOrder(1))
    if HUZ->(dbSeek(RetFilial("HUZ")+HUW->HUW_CODSCRI))
		AADD(aScr,{HUW->HUW_CODSCRI	,AllTrim(HUZ->HUZ_DESC)})
	endif
	dbSelectArea("HUW")
	dbSkip()
Enddo
SetArray(oBrwScr,aScr) 
Return Nil    


/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ MEClickCamp()       ³Autor: Paulo Amaral  ³ Data ³         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Modulo de Merchandising   	 			                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function MEClickCamp(aCamp,oBrwCamp,aScr,oBrwScr)
Local nLinha:=0
if Len(aCamp) == 0
	Return Nil
Endif
nLinha:=GridRow(oBrwCamp)

dbSelectArea("HUW")
dbSetOrder(1)
dbSeek(RetFilial("HUW")+aCamp[nLinha,1])

MECrgScr(aCamp[nLinha,1],aScr,oBrwScr)

Return Nil

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ InitPergunta()      ³Autor: Paulo Amaral  ³ Data ³         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Modulo de Merchandising   	 			                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/                                                
Function InitPergunta(aScr,oBrwScr)
Local aPergC := {}
Local cCodScr:="",cSep:="0000000" ,cTipo:=""
Local nLinha:=0, nPergC:=1
// Hora Inicial da Pesquisa
Local tIni
Local lScript := .T.
Local cTitle := "" // <===== COLOQUE AQUI O TITULO
if Len(aScr) == 0
	Return Nil
Endif
nLinha:=GridRow(oBrwScr)
cCodScr:=AllTrim(aScr[nLinha,1])
cTitle:=AllTrim(aScr[nLinha,2])
dbSelectArea("HUP")
dbSetOrder(2)
dbSeek(RetFilial("HUP")+cCodScr+cSep)
While !Eof() .And. HUP->HUP_FILIAL == RetFilial("HUP") .And. HUP->HUP_CODSCRI == cCodScr .And. HUP->HUP_IDTREE == cSep
	AADD(aPergC,{HUP->HUP_CODPERG , HUP->HUP_DESC , HUP->HUP_TIPOOBJ})	
	dbSkip()
Enddo

if Len(aPergC) == 0 
	Return Nil
Endif

tIni:=Time()
nPergC:=1  
While lScript
	//Carrega a pergunta
	cTipo:=aPergC[nPergC,3]     
	if cTipo == "1"
			// Unica Escolha	
			MEUnicEsc(cCodScr,aPergC,@nPergC,tIni,@lScript, cTitle) 
	Elseif cTipo == "2"
			// Multipla Escolha	
			MEMultEsc(cCodScr,aPergC,@nPergC,tIni,@lScript, cTitle)
	Elseif cTipo == "3"
			// Dissertativa
			MEDissert(cCodScr,aPergC,@nPergC,tIni,@lScript, cTitle)
	Endif
Enddo	

Return Nil                  




Function MEProxPerg(cCodScr,aPergC,nPergC,tIni,aRespI,cRespI,oBrw,lScript)
// Grava a Resposta Selecionada da Pergunta Selecionada
MEGrvTmpResp(aPergC,nPergC,aRespI, cRespI,oBrw)

//Verifica se eh a ultima Pergunta
if nPergC > Len(aPergC)
	Return Nil
Endif                                 

nPergC:=nPergC+1 

//Fecha a Tela Atual da Pergunta Atual
CloseDialog()       
//Retorna para a Funcao InitPerg()
Return Nil

Function MEAntPerg(cCodScr,aPergC,nPergC,tIni,aRespI,cRespI,oBrw,lScript)
// Grava a Resposta Selecionada da Pergunta Selecionada                          
MEGrvTmpResp(aPergC,nPergC,aRespI, cRespI,oBrw)

//Verifica se eh a Primeira Pergunta
if nPergC == 1
	Return Nil
Endif

nPergC:=nPergC-1 
//Fecha a Tela Atual da Pergunta Atual
CloseDialog()      
//Retorna para a Funcao InitPerg()
Return Nil



/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ MEGrvTmpResp()      ³Autor: Paulo Amaral  ³ Data ³30/01/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Grava Temporariamente as Respostas da Pergunta Corrente    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±³Parametros³ aPergC -> Array das Perguntas do Script					  ³±±
±±³			 ³ [nPergC,1] -> Codigo da Pergunta							  ³±±
±±³			 ³ [nPergC,2] -> Descricao da Pergunta						  ³±±
±±³			 ³ [nPergC,3] -> Tipo da Pergunta (1-Un. Escolha, 			  ³±±
±±³			 ³ 2-Mult. Escolha,  3-Dissertativa)						  ³±±
±±³ 		 ³ nPergC -> Pergunta Selecionada							  ³±±
±±³			 ³ aRespI -> Array das Respostas							  ³±±
±±³			 ³ [nRespI,1] -> Codigo da Resposta							  ³±±
±±³			 ³ [nRespI,2] -> Resposta Dissertativa 						  ³±±
±±³			 ³ [nRespI,3] -> Score (Pontuacao desse Item Selecionado)	  ³±±
±±³			 ³ Se Tipo == 3 											  ³±±
±±³			 ³ 		[nRespI,4] -> Indicacao(Flag)de Item(s)selecionado(s) ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/     
Function MEGrvTmpResp(aPergC,nPergC,aRespI,cRespI,oBrw)
Local cTipo:=aPergC[nPergC,3], nRespI:=1      

dbSelectArea("HRE")
dbSetOrder(1)
if dbSeek(RetFilial("HRE")+aPergc[nPergC,1])
	While !Eof() .And. HRE->HRE_FILIAL == RetFilial("HRE") .And. HRE->HRE_CODPERG == aPergc[nPergC,1]
		dbDelete()
		dbCommit()
		dbSkip()
	Enddo
Endif

if cTipo == "1"                               
	if !Empty(aRespI[nRespI,2])
		nRespI:=GridRow(oBrw)              
		dbAppend()
		HRE->HRE_FILIAL := RetFilial("HRE")
		HRE->HRE_CODPERG := aPergc[nPergC,1]
		HRE->HRE_CODRESP := aRespI[nRespI,1]
//		HRE->HRE_RESMEMO	:= aRespI[nRespI,2]
		HRE->HRE_SCORE	:= aRespI[nRespI,3]
		dbCommit()
	Endif
Elseif cTipo == "2"
	For nI:=1 to Len(aRespI)	
		// Se o Item foi escolhido
		if aRespI[nI,4] != .F.
			dbAppend()
			HRE->HRE_FILIAL := RetFilial("HRE")
			HRE->HRE_CODPERG := aPergc[nPergC,1]
			HRE->HRE_CODRESP := aRespI[nI,1]
//			HRE->HRE_RESMEMO	:= aRespI[nRespI,2]
			HRE->HRE_SCORE	:= aRespI[nI,3]	
			dbCommit()
		Endif
	Next
Elseif cTipo == "3"
	if !Empty(cRespI)
   	    dbAppend()
		HRE->HRE_FILIAL := RetFilial("HRE")
		HRE->HRE_CODPERG := aPergc[nPergC,1]
		HRE->HRE_RESMEMO	:= Alltrim(cRespI)
		dbCommit()
	Endif
Endif
Return Nil

Function MECancResp(lScript)
lScript:= .F.
CloseDialog()
Return Nil
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ MEGrvResp()         ³Autor: Paulo Amaral  ³ Data ³30/01/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Grava as Respostas na Base de Dados					      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±³Parametros³ cCodScr -> Script					  					  ³±±
±±³			 ³ aPergC -> Array das Perguntas do Script					  ³±±
±±³			 ³ [nPergC,1] -> Codigo da Pergunta							  ³±±
±±³			 ³ [nPergC,2] -> Descricao da Pergunta						  ³±±
±±³			 ³ [nPergC,3] -> Tipo da Pergunta (1-Un. Escolha, 			  ³±±
±±³			 ³ 2-Mult. Escolha,  3-Dissertativa)						  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/  
Function MEGrvResp(cCodScr,aPergC,tIni,lScript)
Local cCodigo:= "",cIte:="0"
dbSelectArea("HUC")
dbSetOrder(1)
dbGoTop()
cCodigo:=StrZero(Val(HUC->HUC_CODIGO)+1,Len(HUC->HUC_CODIGO))
For nI:=1 to Len(aPergC)
	// TelemarketC
	dbSelectArea("HRE")
	dbSetOrder(1)
	if dbSeek(RetFilial("HRE")+aPergc[nI,1])
		HUC->(dbAppend())
		HUC->HUC_FILIAL := RetFilial("HUC")
		HUC->HUC_CODIGO		:=cCodigo
		HUC->HUC_CODCAMP		:=HUW->HUW_CODCAMP
		HUC->HUC_CLIENTE 	:=HA1->HA1_COD
		HUC->HUC_LOJA		:=HA1->HA1_LOJA
		HUC->HUC_CODCONT		:=HU5->HU5_CODCON
		HUC->HUC_DATA		:=Date()
		HUC->HUC_INICIO      :=tIni
		HUC->HUC_FIM			:=Time()
		HUC->(dbCommit())
		dbSelectArea("HRE")
		While !Eof() .And. HRE->HRE_FILIAL == RetFilial("HRE") .And. HRE->HRE_CODPERG == aPergc[nI,1]	
			// TelemarketI
			HUK->(dbAppend())
			HUK->HUK_FILIAL := RetFilial("HUK")
			cIte:= StrZero(Val(cIte)+1,Len(HUK->HUK_ITEM))
			HUK->HUK_CODIGO  	:= cCodigo
			HUK->HUK_ITEM		:= cIte
			HUK->HUK_CODSCRI    	:= cCodScr
			HUK->HUK_CODPERG	:= HRE->HRE_CODPERG 
			HUK->HUK_CODRESP     	:= HRE->HRE_CODRESP
			HUK->HUK_RESMEMO 	:= HRE->HRE_RESMEMO
			HUK->HUK_SCORE 		:= HRE->HRE_SCORE
			HUK->(dbCommit())
			dbSelectArea("HRE")
			dbSkip()		
		Enddo
	Endif
	cCodigo:=StrZero(Val(cCodigo)+1,Len(HUC->HUC_CODIGO))
Next

MECancResp(@lScript)

Return Nil





/************************* AQUI **********************/
/*
Function TempRespost()
Local aRespI:= {}

//AADD(aRespI, { "RE_CODSCRI", "C", 6, 0 } )
AADD(aRespI, { "RE_CODPERG", "C", 7, 0 } )
AADD(aRespI, { "RE_CODRESP", "C", 7, 0 } )
AADD(aRespI, { "RE_RESMEMO", "C", 90, 0 } )
AADD(aRespI, { "RE_SCORE", "N", 6, 0 } )

dbCreate("HRE010", aRespI, "LOCAL" )
USE HRE010 ALIAS HRE SHARED NEW VIA "LOCAL"
INDEX ON RE_CODPERG + RE_CODRESP TO HRE0101
dbClearIndex()
dbSetIndex("HRE0101")

/*dbAppend()
HRE->HRE_FILIAL := RetFilial("HRE")
HRE->HRE_CODPERG := "0000018"
HRE->HRE_CODRESP := "0000018"
HRE->HRE_RESMEMO := "SE ISSO APARECER A PARTE DISSERTATIVA FUNCIONOU"
HRE->HRE_SCORE   := 50
dbCommit()*/

//Return Nil
