#INCLUDE "PLSA300.ch"
#include "PROTHEUS.CH"
#include "PLSMGER.CH"
#include "COLORS.CH"
#include "TCBROWSE.CH"
#include "JPEG.CH"
                                                                                                                
#define K_Agenda  	1
#define K_Editar  	2
#define K_Cancel  	3
#define K_Remarca 	4
#define K_Marcar  	5
#define K_Encaixe 	6
#define K_Sair     7

Static aInd := {}
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSA300CARºAutor  ³Geraldo Felix Juniorº Data ³  11-08-03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Analiza carencia... agora com o forca                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSA300CAR(cMatric,cAterna,cComboMed,cCodLoc,cCodEsp,lShowCri)
LOCAL aDadUsr 	  := PLSDADUSR(cMatric,"1",.T.,dDatabase)
LOCAL aDadRDA 	  := {} 
LOCAL cCodPro 	  := GetNewPar("MV_PLSCDCO","0110101012") //Codigo padrao da consulta Agenda Medica
LOCAL cCodPad 	  := Left(cCodPro,2)
LOCAL cDesPro
LOCAL cNivel 
LOCAL aHisCri	  := {}
LOCAL lRetorno    := .T.
LOCAL lRet
LOCAL lForcou	  := .T.
LOCAL oMemo
LOCAL cMemo 	  := ""
LOCAL oDlg
LOCAL nOpca		  := 2               
LOCAL cCodRDA     := ""
LOCAL nOrdBB8       := BB8->(IndexOrd())
LOCAL nRecBB8       := BB8->(Recno())   
LOCAL dDatPro		:= IIf(GetNewPar("MV_PLSPEAG","0") == "1" .And. FunName()$'PLSA300,PLSA315,TMKA271' .and. type('M->BBO_DATA')<> 'U',M->BBO_DATA,dDataBase)

DEFAULT cCodLoc    := ""
DEFAULT cAterna	  := "0"              
DEFAULT cComboMed := GetNewPar("MV_PLSRDAG","999999")//Rede de Atendimento Generica Utilizada na rotina de liberacao
DEFAULT lShowCri  := .T.

If Type("cCombo") == "C"
   cCodRDA := Left(cCombo,Len(BAU->BAU_CODIGO))   
Else          
   cCodRDA := Left(cComboMed,Len(BAU->BAU_CODIGO))   
EndIf
                   
//Procura o correto local de atendimento a partir do BB8
BB8->(DbSetOrder(3))
BB8->(DbSeek(xFilial("BB8")+cCodRda+PLSIntPad()+cCodLoc))
cCodLoc := BB8->BB8_CODLOC

BB8->(DbSetOrder(nOrdBB8))
BB8->(DbGoTo(nRecBB8))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Redefine as variaveis...                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cCodPro 	:= Substr(cCodPro,3,8)
lForcaUsr	:= .F.
lForcaPro	:= .F.         
aAutFor 	:= {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se existe o procedimento...                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cSQL := "SELECT BR8_NIVEL, BR8_DESCRI, R_E_C_N_O_ AS REGBR8 FROM "+RetSQLName("BR8")+" WHERE "
cSQL += "BR8_FILIAL = '"+xFilial("BR8")+"' AND "
cSQL += "BR8_CODPAD = '"+cCodPad+"' AND "
cSQL += "BR8_CODPSA = '"+cCodPro+"' AND "
cSQL += "D_E_L_E_T_ = '' AND BR8_ANASIN = '1'"

PLSQuery(cSQL,"PLSA090AUT")

If PLSA090AUT->(Eof())
   lRet := .F.
Else
   BR8->(DbGoTo(PLSA090AUT->REGBR8))
   cDesPro := PLSA090AUT->BR8_DESCRI
   cNivel  := PLSA090AUT->BR8_NIVEL
   lRet   := .T.
Endif   
PLSA090AUT->(DbCloseArea())

BCT->(dbSetOrder(1))

If lShowCri .Or. !aDadUsr[1]
	aRet := PLSA090USR(cMatric,dDatabase,Time(),,.F.,.T.,.F.)
	lCritica := aRet[1]
	aCritica := aRet[2]                                       
Else 
	lCritica := .F.
	aCritica := {}                                       
Endif     
     
If Len(aCritica) > 0  
	If BCT->(MsSeek(xFilial("BCT")+PlsIntPad()+aCritica[1][1]))
		lRet := PLSMOVCRI("2",{},aCritica,BCT->BCT_PERFOR == "1") 
		If !lRet 	
			Return({lRet,aCritica})
		EndIf
		lCritica := lRet
		lShowCri := .F.
	Else	
		PLSMOVCRI("2",{},aCritica) 
		lCritica := .F.	
	EndIf
Endif

If lCritica
   aDadUsr := PLSGETUsr()
Endif
     
If !aDadUsr[1]
	Return({lCritica, aCritica})
Endif
                                   
If Type("cCombo") == "C"
   cCodRDA := Left(cCombo,Len(BAU->BAU_CODIGO))   
Else          
   cCodRDA := Left(cComboMed,Len(BAU->BAU_CODIGO))   
EndIf
	
aDadRDA := PLSDADRDA(BA1->BA1_CODINT,cCodRda,'1' ,dDatabase,cCodLoc,cCodEsp)

If !aDadRDA[1]  
	If BCT->(MsSeek(xFilial("BCT")+PlsIntPad()+aDadRDA[2][1][1]))
		lRet := PLSMOVCRI("2",{},aDadRDA[2],BCT->BCT_PERFOR == "1") 
		lCritica := lRet
		lShowCri := .F.
	Else	
		PLSMOVCRI("2",{},aDadRDA[2]) 
		lCritica := .F.	
	EndIf
Endif

If !aDadRDA[1]
	Return({aDadRDA[1], {}})
Endif
                                          
aRet := PLSAUTP(dDatPro,Time(),cCodPad,cCodPro,1,aDadUsr,0,aDadRDA,"1",.T.,'',,NIL,,,,,,,,,,,,,,,cAterna,,,,,,,,,,,;
        ,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,.F.)

lRet := aRet[1]

If !aRet[1]   	                                                      
	If BCT->(MsSeek(xFilial("BCT")+PlsIntPad()+aRet[2][1][1]))
		lRet := PLSMOVCRI("2",{},aRet[2],BCT->BCT_PERFOR == "1") 
		lCritica := lRet
		lShowCri := .F.
	Else	
		PLSMOVCRI("2",{},aRet[2]) 
		lCritica := .F.	
	EndIf
Endif

If !lRet .and. Len(aDadUsr) > 0 .and. Len(aDadRDA) > 0
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Caso nao seja autorizada analiso o campo que trata se e permitido forcar ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ! lRet
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta aHisCri...                                                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aHisCri := aClone(aRet[2])
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Parametro que permite ou nao a visualizacao das criticas...              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
		If lShowCri
			aRet[1] := PLSMOVCRI("1",{cCodPad,cCodPro,cDesPro,"001"},aHisCri,BR8->BR8_PERFOR == "1")
			
			lRet := Iif( ValType(aRet[1]) == 'L', aRet[1], .F.)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Forcou, abrir tela de digitacao de observacoes...                        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
			If lRet
				nPos := Ascan(aAutFor,{|x| x[2]+x[3] == cCodPad+cCodPro})
				If nPos == 0
					aadd(aAutFor,{.T.,cCodPad,cCodPro,"","","","",0,BCS->(RetCodUsr()),Date(),Time()})
				Endif    			
				lForcaPro := .T.
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Forcou, abrir tela de digitacao de observacoes...                        ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				DEFINE MSDIALOG oDlg TITLE STR0129 FROM 005,005 TO 19, 045  //"Observacoes"
	    
					@ 016,003 GROUP oGrupo TO 104, 157 PIXEL OF oDlg LABEL STR0130  COLOR CLR_HBLUE, CLR_HRED        //" Observacoes "
					@ 024,006 GET oMemo  VAR cMemo MEMO SIZE 145,075 OF oDlg PIXEL

				ACTIVATE MSDIALOG oDlg ON INIT Eval({||EnChoiceBar(oDlg,{||nOpca:=1,oDlg:End()},{||nOpca:=2,oDlg:End()}, .F.)} )
				If nOpca == 1
					Aadd(aAutFor[Len(aAutFor)], cMemo)
				Else	
					Aadd(aAutFor[Len(aAutFor)], '')
				Endif			
			Else
				lForcaPro := .F.
			Endif
		Endif
	Endif
Endif

lRetorno :=  lRet
Return({lRetorno, aHisCri})
