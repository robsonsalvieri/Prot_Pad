#INCLUDE "plsa226.ch"
#include "PROTHEUS.CH"
#include "PLSMGER.CH"

STATIC cMatric := ""
STATIC lB40B49 
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLSA226 ³ Autor ³ Alexander Santos	    ³ Data ³ 27.01.12 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Atualizacao do Cadastro de Usuarios WEB                    ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSA226(xAutoCab,xAutoItens,xOpcAuto,nReg)                                            
                                           
LOCAL aAliasItem 	:= { { "BSO","Prestador","PLSVLDLI('1')","PLSVLDDEL('1')",,,{||PLSVLDFOC('1')},,{||PLSINIDL(1)} } ,{ "B40","Empresa","PLSVLDLI('2')","PLSVLDDEL('2')",,,{||PLSVLDFOC('2')},,{||PLSINIDL(2)} } ,{"B49","Beneficiário","PLSVLDLI('3')","PLSVLDDEL('3')",,,{||PLSVLDFOC('3')}}} 
LOCAL aKeyItem 	 	:= { "M->BSW_CODUSR","M->BSW_CODUSR","M->BSW_CODUSR" }
LOCAL aCondItem  	:= { "BSO_CODUSR","B40_CODUSR","B49_CODUSR" }
LOCAL aChavCab 	 	:= { {{"BSO_CODUSR","M->BSW_CODUSR"}},{{"B40_CODUSR","M->BSW_CODUSR"}},{{"B49_CODUSR","M->BSW_CODUSR"}}}
LOCAL nIndice		:= 0
LOCAL aButtons 		:= {}

PRIVATE aCols    	:= {}
PRIVATE aHeader  	:= {}
PRIVATE n        	:= 1                                                            
PRIVATE cCodInt 	:= PLSINTPAD()
PRIVATE cCodEmp 	:= ""
PRIVATE cCodConVer	:= ""
PRIVATE cCodRda 	:= ""
PRIVATE cCodPortal
Private aRotAdic := {"Alterar Senha" , "PLSPORSEN(Nil,'BSW_SENHA')", 0,2}
Default lB40B49 := ( PLSALIASEXI("B40") .And. PLSALIASEXI("B49") )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Verifica se o alias existe
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If PLSALIASEXI("B95")
     aAdd(aAliasItem, {"B95","Atalhos Portal","PLSVLDLI('4')","PLSVLDDEL('4')",,, } )  
     aAdd(aKeyItem, "M->BSW_CODUSR" )
     aAdd(aCondItem, "B95_CODUSR")
     aAdd(aChavCab, {{"B95_CODUSR","M->BSW_CODUSR"}} ) 
     
    aAdd(aAliasItem,{"BX1","Historico de Acesso Portal","PLSVLDLI('5')","PLSVLDDEL('5')",,,.F.})
Else
	aAdd(aAliasItem,{"BX1","Historico de Acesso Portal","PLSVLDLI('4')","PLSVLDDEL('4')",,,.F.})
EndIf
aAdd(aKeyItem, "M->BSW_CODUSR" )
aAdd(aCondItem, "BX1_CODUSR")
aAdd(aChavCab, {{"BX1_CODUSR","M->BSW_CODUSR"}} )

If !lB40B49

	AxCadastro("BSW" ,STR0001,,,aRotAdic,,{|| Iif(Inclui ,(A226USRCOD(),PLSPORSEN(Nil,"BSW_SENHA")),.T.) } ) //"Usuários do Portal"
Else	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³ CabItem
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	IF BX1->(FieldPos("BX1_CODUSR")) > 0 .AND. BX1->(FieldPos("BX1_QTACES")) > 0 .AND. BSW->(FieldPos("BSW_DTSEN")) > 0
		nIndice := 6
	Else
		nIndice := 1
	ENDIF	
	
	aadd(aButtons,{"Import. Login Empresa",{||PLSAUTOIMP()},"Import. Login Empresa","Import. Login Empresa"})

	PlsCabItem("BSW","Usuarios do Portal",aAliasItem,IIF(PLSALIASEXI("B95"),{1,1,1,1,nIndice},{1,1,1,nIndice}),aKeyItem,aCondItem,aChavCab,nil,nil,xAutoCab,xAutoItens,xOpcAuto,nReg,{|| Iif(Inclui,(A226USRCOD(),PLSPORSEN(Nil,"BSW_SENHA",.T.)),.T.) },nil,aButtons,nil,nil,nil,.T.,,.T.)
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Fim da Rotina...                                                         
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Return
/*                                                                                              
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSCV     ºAutor  ³Microsiga           º Data ³  17/09/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Atualiza variavel e campos								  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSCV(cTp)
LOCAL lRet := .T.

Do Case
	Case cTp == '0'  
		cCodRda := M->BSO_CODIGO                   

	Case cTp == '1'
		cCodEmp := M->B40_CODEMP
		
	Case cTp == '2'
		cCodConVer := M->(B40_NUMCON+B40_VERCON)
		
	Case cTp == '3'
		cCodInt := PLSINTPAD()
		cCodEmp := M->B40_CODEMP

	Case cTp == '4'
 	cCodInt := PLSINTPAD()
	
	Case cTp == '5'
		cCodInt := PLSINTPAD()
EndCase		
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Fim da Rotina...                                                         
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Return(lRet)		
/*                                                                                              
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSVLDFOC ºAutor  ³Microsiga           º Data ³  17/09/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica se e permitido edicao no folder					  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSVLDFOC(cTp)
local nLine     := aObjGD[2]:oBrowse:nat
Local aSelected := aObjGD[2]:aCols[nLine]

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Atualiza variavel privada
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
cCodInt 	:= PLSINTPAD()                                                  
cCodRda 	:= BSO->BSO_CODIGO             
If !Empty(M->BSW_TPPOR)
    If M->BSW_TPPOR ==  '1'
       cCodPortal := "000008"
    Else 
       cCodPortal := "000010"     
    EndIf 
EndIf  

cCodEmp 	:= aSelected[GdFieldPos("B40_CODEMP",  aObjGD[2]:aHeader)]
cCodConVer	:= aSelected[GdFieldPos("B40_NUMCON",  aObjGD[2]:aHeader)] + aSelected[GdFieldPos("B40_VERCON",  aObjGD[2]:aHeader)]	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Verifica se o tipo de portal permite edicao para o folder
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If !Empty(M->BSW_TPPOR)
	If M->BSW_TPPOR != cTp
		If ValType(oEnchoice) == "O"
			oEnchoice:SetFocus()
		EndIf	                             
	EndIf
EndIf	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Fim da Rotina...                                                         
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Return(.T.)                                                               
/*                                                                                              
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSVLDLI  ºAutor  ³Microsiga           º Data ³  26/01/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Validacao na linha do browse								  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSVLDLI(cTp)
LOCAL lRet 		:= .T.
LOCAL _oObj 	:= NIL
LOCAL cSubCon 	:= ""
LOCAL cVerCon 	:= ""
LOCAL nI		:= 0
LOCAL nLin		:= 0
LOCAL nTamFam	:= TamSx3("BA1_CODINT")[1]+TamSx3("BA1_CODEMP")[1]+TamSx3("BA1_MATRIC")[1]
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Prestador
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If cTp == '1'

	lRet := PlsVldGD( {"BSO_CODINT","BSO_CODIGO","BSO_CODLOC"} )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Empresa
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
ElseIf cTp == '2'                                    
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³ Verifica se ja foi informado contrato sem subcontrato
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
    If !Empty( M->(B40_SUBCON+B40_VERSUB) )
		cSubCon 		:= M->B40_SUBCON
		cVerCon 		:= M->B40_VERSUB    
		M->B40_SUBCON 	:= Space(TamSx3("B40_SUBCON")[1])
		M->B40_VERSUB 	:= Space(TamSx3("B40_VERSUB")[1])
    
		lRet := PlsVldGD( {"B40_CODINT","B40_CODEMP","B40_NUMCON","B40_VERCON","B40_SUBCON","B40_VERSUB"})
		
		M->B40_SUBCON 	:= cSubCon
		M->B40_VERSUB 	:= cVerCon
	Else
		lRet := PlsVldGD( {"B40_CODINT","B40_CODEMP","B40_NUMCON","B40_VERCON"})
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³ Verifica contrato e subcontrato
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	If lRet	
		lRet := PlsVldGD( {"B40_CODINT","B40_CODEMP","B40_NUMCON","B40_VERCON","B40_SUBCON","B40_VERSUB"} )
	EndIf	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Familia
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
ElseIf cTp == '3'

	lRet := PlsVldGD( {"B49_BENEFI"} )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³ Se nao existe ja cadastrado
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	If lRet                    
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		//³ Monta obj do browse
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		_oObj := aObjGD[Val(cTp)]
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		//³ Pega o primeiro nao deletado para checar se e da mesma familia
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		For nI:=1 To Len(_oObj:aCols)
			If !_oObj:aCols[nI, Len(_oObj:aHeader)+1 ]
				nLin := nI
				Exit
			EndIf	
		Next
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		//³ Verifica se o usuario informado pertence a mesma familia
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		If nLin > 0 .And. !Empty( _oObj:aCols[ nLin, _oObj:FieldPos("B49_BENEFI") ] )
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
			//³ Se nao pertencer a mesma familia nega a inclusao
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
			lRet := ( Left(M->B49_BENEFI,nTamFam) $ _oObj:aCols[ nLin, _oObj:FieldPos("B49_BENEFI") ] )
			
			If !lRet
				MsgStop('Beneficiário não pertence a esta famú‰ia!')
			EndIf                    
		EndIf	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		//³ Verifica se e o titular
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		If lRet .And. SubStr(M->B49_BENEFI,(nTamFam+1),2) == GetNewPar("MV_PLTRTIT","00")
			If MsgYesNo("Deseja incluir também os dependentes?")
				cMatric	:= M->B49_BENEFI              
				_oObj:lInAddLine := .F.
				_oObj:bAfterAdd := {||PLSINDEP(_oObj)}
			EndIf
		EndIf	
	EndIf
ElseIf (PLSALIASEXI("B95") .And. cTp == '5').Or. (!PLSALIASEXI("B95") .And. cTp == '4')
	lRet := PlsVldGD( {"BX1_ALIAS","BX1_RECNO","BX1_TIPO","BX1_USUARI","BX1_DATA","BX1_HORA","BX1_ROTINA"} )
EndIf	                                
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Se foi informado item atribui o tipo de portal
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
M->BSW_TPPOR := cTp
IF (PLSALIASEXI("B95") .And. cTp == '5').Or. (!PLSALIASEXI("B95") .And. cTp == '4')
	cTp	:= '1'
	M->BSW_TPPOR := cTp
ENDIF	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Refresh do browse
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oEnchoice:Refresh()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Fim da Rotina...                                                         
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Return(lRet)
/*                                                                                              
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSVLDDEL ºAutor  ³Microsiga           º Data ³  26/01/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida del												  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSVLDDEL(cTp)
LOCAL lRet 		:= .T.
LOCAL nI		:= 1
LOCAL _oObj 	:= aObjGD[ Val(cTp) ]
LOCAL lLinDel	:= _oObj:IsDeleted( _oObj:Linha() )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Alinha sera deletada
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If !lLinDel
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³ Verifico se tem alguma linha valida (nao deletada)
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	For nI:=1 To Len(_oObj:aCols)                           
		If nI <> _oObj:Linha() .And. !_oObj:IsDeleted(nI)
			lRet := .F.
		EndIf
	Next
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Estava deletada e sera restaurada
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Else 
	lRet := .F.
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Se deletou todos os registro do item limpa o tipo de portal
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If lRet
	M->BSW_TPPOR := ''
ElseIf Empty(M->BSW_TPPOR) .And. PLSVLDDLG( Val(cTp) )
	M->BSW_TPPOR := cTp
ElseIF (PLSALIASEXI("B95") .And. cTp == '5').Or. (!PLSALIASEXI("B95") .And. cTp == '4')
	cTp := '1'
	M->BSW_TPPOR := cTp
EndIf

oEnchoice:Refresh()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Fim da Rotina...                                                         
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Return(.T.)
/*                                                                                              
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSINIDL  ºAutor  ³Microsiga           º Data ³  26/01/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Seta a operadora referete ao item multi-operadora		  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSINIDL(nTp)
LOCAL _oObj := aObjGD[nTp]
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Atualiza statica para multi-operadora
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If !Inclui
	If nTp == 1
		__cOpePad 	:= _oObj:aCols[ _oObj:Linha(), _oObj:FieldPos("BSO_CODINT") ]
		cCodRda		:= _oObj:aCols[ _oObj:Linha(), _oObj:FieldPos("BSO_CODIGO") ]

	ElseIf	nTp == 2
		__cOpePad 	:= _oObj:aCols[ _oObj:Linha(), _oObj:FieldPos("B40_CODINT") ]
		cCodEmp 	:= _oObj:aCols[ _oObj:Linha(), _oObj:FieldPos("B40_CODEMP") ]
		cCodConVer	:= _oObj:aCols[ _oObj:Linha(), _oObj:FieldPos("B40_NUMCON") ]+_oObj:aCols[ _oObj:Linha(), _oObj:FieldPos("B40_VERCON") ]
	EndIf 
EndIf

cCodInt := PLSINTPAD()                                                  
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Fim da Rotina...                                                         
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Return
/*                                                                                              
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSVLDDLG ºAutor  ³Microsiga           º Data ³  26/01/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida se foi informado item								  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSVLDDLG(nTp)
LOCAL _oObj := aObjGD[nTp]
LOCAL nI	:= 1
LOCAL nPos	:= 0
LOCAL lRet	:= .F.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Neste passo a linha nao esta mais deletada mesmo a acols ainda nao estando atualizada
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
For nI:=1 To Len(_oObj:aCols)                           
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³ Verifico se tem conteudo
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	If (nPos := _oObj:FieldPos("BSO_CODIGO")) > 0
		lRet := !Empty(_oObj:aCols[ nI, nPos ])
	ElseIf (nPos := _oObj:FieldPos("BX1_USUARI")) > 0
		lRet := !Empty(_oObj:aCols[ nI, nPos ])	
	ElseIf (nPos := _oObj:FieldPos("B40_CODEMP")) > 0
		lRet := !Empty(_oObj:aCols[ nI, nPos ])
	ElseIf (nPos := _oObj:FieldPos("B49_BENEFI")) > 0
		lRet := !Empty(_oObj:aCols[ nI, nPos ])
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³ Aborto a checagem
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	If lRet
		Exit
	EndIf
Next
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Fim da Rotina...                                                         
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Return(lRet)
/*                                                                                              
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSMREL   ºAutor  ³Microsiga           º Data ³  26/01/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Mostra senha real										  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSMREL()
LOCAL cRet := ""   

If M->BSW_TPPOR == '2'
	cRet := PLSCRIDEC(2,AllTrim(M->BSW_SENHA))
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Fim da Rotina...                                                         
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Return(cRet)
/*                                                                                              
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSINDEP  ºAutor  ³Microsiga           º Data ³  26/01/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Inclui dependentes										  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                                           
Static Function PLSINDEP(oObj)
LOCAL nLin  	:= 0
LOCAL nI		:= 0
LOCAL cConteudo := ""           
LOCAL nTamFam	:= TamSx3("BA1_CODINT")[1]+TamSx3("BA1_CODEMP")[1]+TamSx3("BA1_MATRIC")[1]
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Posiciona na familia correspondente
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
BA1->( DbSetOrder(1) ) //BA1_FILIAL + BA1_CODINT + BA1_CODEMP + BA1_MATRIC + BA1_TIPUSU + BA1_TIPREG + BA1_DIGITO
BA1->( MsSeek( xFilial("BA1") + Left(cMatric,nTamFam) ) )	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Pega todos os componentes da familia
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
While !BA1->( Eof() ) .And. Left(cMatric,nTamFam) == BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³ Se for diferente do usuario titular informado
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	If cMatric <> BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO) .And. aScan(oObj:aCols,{|x| !x[Len(oObj:aHeader)+1] .And. x[PLRETPOS('B49_BENEFI',oObj:aHeader)] == BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO) }) == 0
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		//³ Inclui linha vazia
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
  	    oObj:AddBlank()
  	    nLin := Len(oObj:aCols) 
		oObj:SetPos( nLin )  
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		//³ monta a cols
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		For nI:=1 To Len(oObj:aHeader)+1
			
			If nI <= Len(oObj:aHeader)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
				//³ Campos correspondentes na aheader
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
				cConteudo := ""
				Do Case
					Case oObj:aHeader[nI,2] == 'B49_CODUSR'
						cConteudo := CriaVar(oObj:aHeader[nI,2],.T.)
						
					Case oObj:aHeader[nI,2] == 'B49_BENEFI'
						cConteudo := BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO)
						
					Case oObj:aHeader[nI,2] == 'B49_NOMBEN'
						cConteudo := BA1->BA1_NOMUSR
						
				EndCase
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
				//³ coloca o conteudo na acols
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
				oObj:FieldPut(oObj:aHeader[nI,2],cConteudo,nLin)
			EndIf
		Next
	EndIf
BA1->( DbSkip() )
EndDo
           
oObj:Refresh()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Fim da Rotina...                                                         
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSA226NLC ³ Autor ³ 		             ³ Data ³ 28/06/12³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Exibe Desc. Local	 no INIBRW BSO_DESLOC                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PLSA226NLC()  
Return(BB8->(Posicione("BB8",1,xFilial("BB8")+BSO->BSO_CODIGO+PLSINTPAD()+BSO->BSO_CODLOC,"BB8_DESLOC")))

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³  PLSEdiSDir   ³ Autor ³ Karine Riquena   ³ Data ³21/11/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³  Função para selecionar imagem para atalho no portal       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³  Retorna Verdadeiro ou Falso                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³  PLS                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSEdiSDir()

Local aArea	   := GetArea()
Local cTipo			 := ""
Local cCpoVld  := ReadVar()
LOCAL cWebDir  := getWebDir()
LOCAL cSkinPls := getSkinPls()
LOCAL cFile    := ""
LOCAL nAt

 	cFile := cGetFile("*.JPG|*.jpg|*.bmp|*.BMP|*.png|*.PNG","Selecione a Imagem",1,'SERVIDOR' + cWebDir + cSkinPls,.F.,GETF_NETWORKDRIVE+GETF_NOCHANGEDIR)   //"Selecione o Arquivo"
 	nAt := At(cSkinPls, cFile)
	&(cCpoVld) := Substr(cFile, nAt, Len(cFile))
	RestArea(aArea)

Return(.T.) 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³  A226USRCOD   ³ Autor ³ Geraldo Felix   ³ Data ³23/08/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³  Gera código do usuário       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³  nulo                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³  PLS                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A226USRCOD(lAuto)
LOCAL cSql 		:= ""
LOCAL cCodBSW 	:= ""
LOCAL nCnt 		:= 0
LOCAL _oObj 	:= nil
LOCAL cAlias 	:= ""
LOCAL nPos 		:= 0  
LOCAL nX		:= 0

Default lAuto := .F.

//Seleciona o titulo de maio recno, desde que ele nao seja um titulo de imposto.
cSQL := "SELECT MAX(BSW_CODUSR) CODUSR"
cSQL += " FROM " + RetSqlName("BSW")
cSQL += " WHERE BSW_FILIAL = '" + xFilial("BSW") + "' "
cSQL += " AND BSW_CODUSR NOT LIKE '%AUTO%'"
cSQL += " AND D_E_L_E_T_ = ' '"

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"BSWMAX",.F.,.T.)
DbSelectArea("BSWMAX")

If BSWMAX->( Eof() )
	cCodBSW := StrZero(1,Len(BSW->BSW_CODUSR))
Else
	cCodBSW := Soma1(BSWMAX->CODUSR)
Endif




if !lAuto
	// Atualiza o campo chave no cabecalho
	M->BSW_CODUSR := cCodBSW
	
	// Atualiza todos os browses 
	For nCnt := 1 To len(aObjGD)
		_oObj := aObjGD[nCnt]
			
		cAlias := _oObj:cAlias	
		nPos := _oObj:FieldPos(cAlias+"_CODUSR")
		If nPos > 0
			For nX := 1 to Len(_oObj:aCols) 
				_oObj:FieldPut(cAlias+"_CODUSR", cCodBSW, nX)
			Next
		Endif
	Next
EndIf
 
// Fecha a área de trabalho
BSWMAX->( dbCloseArea() )

Return(cCodBSW)

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao para criar o menu da tela
@author Oscar Zanin
@since 08/04/2019
@version P12
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina 	:= PLSMnDefY( .T., "BSW", , )

Return(aRotina)

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSMINGMEN

@author Lucas Nonato
@since 05/04/2024
@version P12
/*/
function PLSMINGMEN()

	local aMenu2 := {} as array
	local nX := 1 as numeric
	local cSeq := '' as character
	local lCria	:= .f. as logical
	local aMenu3 := {} as array
	local aMenu4 := {} as array

	AI8->(dbsetorder(1))
	AI9->(dbsetorder(1))

	if !AI9->(msseek(xfilial('AI9')+'000013'))
		AI9->(reclock("AI9",.t.))
		AI9->AI9_FILIAL := xfilial("AI9")
		AI9->AI9_PORTAL := '000013'
		AI9->AI9_DESCRI := 'Portal do Beneficiario Mingle'
		AI9->(msunlock())
	endif

	if !AI9->(msseek(xfilial('AI9')+'000014'))
		AI9->(reclock("AI9",.t.))
		AI9->AI9_FILIAL := xfilial("AI9")
		AI9->AI9_PORTAL := '000014'
		AI9->AI9_DESCRI := 'Portal da Operadora'
		AI9->(msunlock())
	endif

	if !AI9->(msSeek(xfilial("AI9") + "000015"))
		AI9->(reclock("AI9", .T.))
		AI9->AI9_FILIAL := xFilial("AI9")
		AI9->AI9_PORTAL := '000015'
		AI9->AI9_DESCRI := 'Portal da Empresa Mingle'
		AI9->(msUnlock())
	endif

	//Plano de Saude - Beneficiario Mingle
	aadd( aMenu2, { "000013","",'Boleto','','','',""	,"HealthRest" ,"bank-slips"	,1 } )
	aadd( aMenu2, { "000013","",'Demonstrativo IR','','','',""	,"HealthRest" ,"income-tax"	,1 } )
	aadd( aMenu2, { "000013","",'Extrato de Debitos','','','',""	,"HealthRest" ,"stmt-anual-debts"	,1 } )
	aadd( aMenu2, { "000013","",'Reembolso','','','',""	,"HealthRest" ,"refund-request"	,1 } )
	aadd( aMenu2, { "000013","",'Status de Reembolso','','','',""	,"HealthRest" ,"refund-status"	,1 } )
	aadd( aMenu2, { "000013","",'Extrato de Utilização','','','',""	,"HealthRest" ,"stmt-utilization"	,1 } )
	aadd( aMenu2, { "000013","",'Extrato Financeiro','','','',""	,"HealthRest" ,"stmt-finance"	,1 } )
	aadd( aMenu2, { "000013","",'Buscar Credenciados','','','',""	,"HealthRest" ,"accrediteds"	,1 } )
	aadd( aMenu2, { "000013","",'Cartão Digital','','','',""	,"HealthRest" ,"digital-card"	,1 } )
	aadd( aMenu2, { "000013","",'Meus Dependentes','','','',""	,"HealthRest" ,"beneficiaries"	,1 } )
	aadd( aMenu2, { "000013","",'Solicitar Cancelamento','','','',""	,"HealthRest" ,"cancel-plan"	,1 } )
	aadd( aMenu2, { "000013","",'Elegibilidade','','','',""	,"HealthRest" ,"eligibility"	,1 } )
	aadd( aMenu2, { "000013","",'Informações Cadastrais','','','',""	,"HealthRest" ,"beneficiary-data"	,1 } )
	aadd( aMenu2, { "000013","",'Autorizar Procedimentos','','','',""	,"HealthRest" ,"authorization"	,1 } )

	//Plano de Saude - Portal da Operadora
	aadd( aMenu3, { "000014","",'Auditoria Pós','','','',""	,"HealthRest" ,"pos-audit"	,1 } )
	aadd( aMenu3, { "000014","",'Auditar','','','',""	,"HealthRest" ,"auditoria-lote"	,1 } )
	aadd( aMenu3, { "000014","",'Lote','','','',""	,"HealthRest" ,"detalhe-lote"	,1 } )
	// aadd( aMenu3, { "000014","",'Protocolos de Saúde','','','',""	,"HealthRest" ,"protocolos-de-saude"	,1 } )
	// aadd( aMenu3, { "000014","",'Grupos de Itens','','','',""	,"HealthRest" ,"grupos-de-itens"	,1 } )
	aadd( aMenu3, { "000014","",'Tabela de Referência','','','',""	,"HealthRest" ,"rede-atendimento"	,1 } )

	//Plano de Saude - Portal da Empresa
	aadd(aMenu4, {"000015", "000001", "Gerenciar Beneficiários", "", "HealthRest", "manage-beneficiaries", 1})
	aadd(aMenu4, {"000015", "000002", "Central de Solicitações", "", "HealthRest", "beneficiary-requests", 2})
	aadd(aMenu4, {"000015", "000003", "Importar Beneficiários", "", "HealthRest", "import-beneficiaries", 3})
	aadd(aMenu4, {"000015", "000004", "Faturas", "", "HealthRest", "invoices", 1})
	aadd(aMenu4, {"000015", "000005", "Extrato de Utilização", "", "HealthRest", "utilization-stmt", 1})
	aadd(aMenu4, {"000015", "000006", "Demonstrativo de IR", "", "HealthRest", "income-tax", 2})
	aadd(aMenu4, {"000015", "000007", "Lotes de Cartões", "", "HealthRest", "card-batches", 4})

	For nX := 1 To Len(aMenu2)
		cSeq := StrZero(nX,Len(AI8->AI8_CODMNU))
		lCria := !AI8->(msseek(xfilial("AI8")+aMenu2[nX][1]+cSeq))
		AI8->(RecLock("AI8",lCria))
		AI8->AI8_FILIAL := xFilial("AI8")
		AI8->AI8_PORTAL := aMenu2[nX][1]
		AI8->AI8_CODMNU := cSeq
		AI8->AI8_TEXTO  := aMenu2[nX][3]
		AI8->AI8_TEXTOS := aMenu2[nX][5]
		AI8->AI8_TEXTOE := aMenu2[nX][4]
		AI8->AI8_WEBSRV := aMenu2[nX][8]
		AI8->AI8_ROTINA := aMenu2[nX][9]
		AI8->AI8_ORDEM  := aMenu2[nX][10]
		AI8->(MsUnLock())
	Next nX

	For nX := 1 To Len(aMenu3)
		cSeq := StrZero(nX,Len(AI8->AI8_CODMNU))
		lCria := !AI8->(msseek(xfilial("AI8")+aMenu3[nX][1]+cSeq))
		AI8->(RecLock("AI8",lCria))
		AI8->AI8_FILIAL := xFilial("AI8")
		AI8->AI8_PORTAL := aMenu3[nX][1]
		AI8->AI8_CODMNU := cSeq
		AI8->AI8_CODPAI := iif(aMenu3[nX][3] == "Auditoria Pós", "", "000001")
		AI8->AI8_TEXTO  := aMenu3[nX][3]
		AI8->AI8_TEXTOS := aMenu3[nX][5]
		AI8->AI8_TEXTOE := aMenu3[nX][4]
		AI8->AI8_WEBSRV := aMenu3[nX][8]
		AI8->AI8_ROTINA := aMenu3[nX][9]
		AI8->AI8_ORDEM  := aMenu3[nX][10]
		AI8->(MsUnLock())
	Next nX

	for nX := 1 To len(aMenu4)
		lCria := !AI8->(msSeek(xfilial("AI8") + aMenu4[nX][1] + aMenu4[nX][2]))

		AI8->(recLock("AI8", lCria))
			AI8->AI8_FILIAL := xFilial("AI8")
			AI8->AI8_PORTAL := aMenu4[nX][1]
			AI8->AI8_CODMNU := aMenu4[nX][2]
			AI8->AI8_TEXTO := aMenu4[nX][3]
			AI8->AI8_CODPAI := aMenu4[nX][4]
			AI8->AI8_WEBSRV := aMenu4[nX][5]
			AI8->AI8_ROTINA := aMenu4[nX][6]
			AI8->AI8_ORDEM := aMenu4[nX][7]
		AI8->(msUnLock())
	next nX

	fwFreeArray(aMenu2)
	fwFreeArray(aMenu3)
	fwFreeArray(aMenu4)

	msgInfo("Menus atualizados com sucesso.")

return 


/*/{Protheus.doc} PLSAUTOIMP
Função para importar contratos da Empresa selecionada no grid
@type method
@version 12.1.2510
@author guilherme.bonni
@since 15/04/2025
*/
function PLSAUTOIMP()
	local nLine     := aObjGD[2]:oBrowse:nat as numeric
	local aSelected := {}
	local aRet      := {}
	local lOk       := .T.

	local nOpc as numeric
	local jEmp as json

	jEmp := JsonObject():new()

	if Type("aObjGD[2]:aCols") == "A" .and. !Empty(aObjGD[2]:aCols[nLine][3])
		aSelected := aObjGD[2]:aCols[nLine]
		nOpc:= Aviso("Título", "Voce deseja Selecionar todos os contratos da Empresa "+aSelected[3]+;
						" ou somente os subcontratos do contrato "+aSelected[5]+"?", {"Empresa", "Contrato", "Cancelar"}, 1)
		
		
		jEmp["codigo"] := aSelected[2]+aSelected[3]
		jEmp["descri"] := aSelected[4]
		
		If nOpc == 2
			jEmp["numcon"] := aSelected[5]
			jEmp["vercon"] := aSelected[6]
		elseIf nOpc == 3
			lOk := .F.
		endif

		if lOk
			aRet:= GetContracts(jEmp)

			SetGridContracts(aObjGD[2]:aCols, aRet)
		EndiF

	else
		FwAlertWarning("Nenhuma empresa foi adicionada. Para continuar, adicione ao menos uma empresa na lista.", "Atenção")
	endif
	freeObj(jEmp)
	FwFreeArray(aSelected)
return

/*/{Protheus.doc} GetContracts
Função que retorna os contratos da empresa selecionada no grid
@type method
@version 12.1.2510
@author guilherme.bonni
@since 15/04/2025
@param jEmp, json, json da empresa selecionada no grid
*/
static function GetContracts(jEmp as json)
	local aRet   := {}
	local nOrder := 1

	local cQuery    as character
	local cAlias    as character
	local oExecStmt as object
	local jRet      as json

	cQuery := " SELECT ? "
	cQuery += " FROM ? BQC "
	cQuery += " WHERE "
	cQuery += " 	BQC.BQC_FILIAL = ? AND "
	cQuery += " 	BQC.BQC_CODIGO = ? AND "

	if jEmp:HasProperty("numcon") .and. jEmp:HasProperty("vercon")
		cQuery += " 	BQC.BQC_NUMCON = ? AND "
		cQuery += " 	BQC.BQC_VERCON = ? AND "
	endIf
	
	cQuery += " 	BQC.D_E_L_E_T_ = ? "

	oExecStmt := FwExecStatement():new(cQuery)

	oExecStmt:setUnsafe(nOrder++,"BQC.BQC_CODINT, BQC.BQC_CODEMP, BQC.BQC_NUMCON, BQC.BQC_VERCON, BQC.BQC_SUBCON, BQC.BQC_VERSUB, BQC.BQC_DESCRI")
	oExecStmt:setUnsafe(nOrder++, retSqlName("BQC"))
	oExecStmt:setString(nOrder++, xFilial("BQC"))
	oExecStmt:setString(nOrder++, jEmp["codigo"])

	if jEmp:HasProperty("numcon") .and. jEmp:HasProperty("vercon")
		oExecStmt:setString(nOrder++, jEmp["numcon"])
		oExecStmt:setString(nOrder++, jEmp["vercon"])
	endIf
	
	oExecStmt:setString(nOrder++, " ")

	cAlias := oExecStmt:openAlias()

	if !(cAlias)->(eof())
		While !(cAlias)->(Eof())
			jRet := JsonObject():new()

			jRet['codint'] := (cAlias)->BQC_CODINT
			jRet['codemp'] := (cAlias)->BQC_CODEMP
			jRet['descri'] := jEmp["descri"]
			jRet['numcon'] := (cAlias)->BQC_NUMCON
			jRet['vercon'] := (cAlias)->BQC_VERCON
			jRet['subcon'] := (cAlias)->BQC_SUBCON
			jRet['versub'] := (cAlias)->BQC_VERSUB
			jRet['subconDescri'] := (cAlias)->BQC_DESCRI

			aadd(aRet, jRet)

			(cAlias)->(DbSkip())
		EndDo
	endIf

	(cAlias)->(dbCloseArea())

	freeObj(oExecStmt)
	freeObj(jRet)

return aRet

/*/{Protheus.doc} SetGridContracts
Função seta os contratos na grid
@type method
@version 12.1.2510
@author guilherme.bonni
@since 15/04/2025
@param aObj, array, array do grid
@param aRet, array, array da empresa selecionada no grid
*/
Static Function SetGridContracts(aObj as array, aRet as array)
	Local aDiff      := {}
	Local aGridAtual := aObjGD[2]:aCols
	Local nLen       := Len(aRet)
	Local nObjLen    := Len(aGridAtual)
	Local nHeader    := Len(aObjGD[2]:aHeader)
	Local nLenObj    := Len(aObj)

	Local i 		  as numeric
	Local j 		  as numeric
	Local nI 		  as numeric
	Local nDiffLen 	  as numeric
	Local lEncontrado as Logical

	// Identifica os registros que estão em aRet, mas não estão em aObj
	For i := 1 To nLen
		lEncontrado := .F.

		For j := 1 To nLenObj
			If aRet[i]["codemp"] == aObj[j][GdFieldPos("B40_CODEMP", aObjGD[2]:aHeader)] .And. ;
			aRet[i]["numcon"] == aObj[j][GdFieldPos("B40_NUMCON", aObjGD[2]:aHeader)] .And. ;
			aRet[i]["vercon"] == aObj[j][GdFieldPos("B40_VERCON", aObjGD[2]:aHeader)] .And. ;
			aRet[i]["subcon"] == aObj[j][GdFieldPos("B40_SUBCON", aObjGD[2]:aHeader)] .And. ;
			aRet[i]["versub"] == aObj[j][GdFieldPos("B40_VERSUB", aObjGD[2]:aHeader)]
				lEncontrado := .T.
				Exit
			EndIf
		Next j

		If !lEncontrado
			AAdd(aDiff, aRet[i])
		EndIf
	Next i

	nDiffLen := Len(aDiff)

	// Adiciona os registros novos
	For nI := 1 To nDiffLen
		AAdd(aGridAtual, Array(nHeader+1))

		aGridAtual[nObjLen + 1][GdFieldPos("B40_CODUSR",  aObjGD[2]:aHeader)] := CriaVar("B40_CODUSR", .T.)
		aGridAtual[nObjLen + 1][GdFieldPos("B40_CODINT",  aObjGD[2]:aHeader)] := aDiff[nI]["codint"]
		aGridAtual[nObjLen + 1][GdFieldPos("B40_CODEMP",  aObjGD[2]:aHeader)] := aDiff[nI]["codemp"]
		aGridAtual[nObjLen + 1][GdFieldPos("B40_NUMCON",  aObjGD[2]:aHeader)] := aDiff[nI]["numcon"]
		aGridAtual[nObjLen + 1][GdFieldPos("B40_VERCON",  aObjGD[2]:aHeader)] := aDiff[nI]["vercon"]
		aGridAtual[nObjLen + 1][GdFieldPos("B40_SUBCON",  aObjGD[2]:aHeader)] := aDiff[nI]["subcon"]
		aGridAtual[nObjLen + 1][GdFieldPos("B40_VERSUB",  aObjGD[2]:aHeader)] := aDiff[nI]["versub"]
		aGridAtual[nObjLen + 1][GdFieldPos("B40_DESEMP",  aObjGD[2]:aHeader)] := aDiff[nI]["descri"]
		aGridAtual[nObjLen + 1][GdFieldPos("B40_DESSUB",  aObjGD[2]:aHeader)] := aDiff[nI]["subconDescri"]
		aGridAtual[nObjLen + 1][Len(aGridAtual[nObjLen + 1])] := .F.

		nObjLen++
	Next

	// Atualiza a grid com os dados antigos + novos
	aObjGD[2]:setArray(aGridAtual)
	aObjGD[2]:ForceRefresh()
Return
