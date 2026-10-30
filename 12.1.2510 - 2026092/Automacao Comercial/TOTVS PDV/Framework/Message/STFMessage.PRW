#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "POSCSS.CH"
#INCLUDE "FWCSS.CH"
#INCLUDE "STFMESSAGE.CH"


Static nNumMsg := SuperGetMv("MV_LJTLOG",,40) // Tamanho do Array que armazena as mensagens 

Static aMessage     := {}           // Array de mensagens
Static aMsgBkp  := Iif (nNumMsg == 40,Array(40),Array(nNumMsg)) // Array de mensagens de bkp para exibicao em tela quando necessario
Static lClientHtml	:= GetCliHTML()

//-------------------------------------------------------------------
/*/{Protheus.doc} STFMessage
Recebe e armazena as mensagens que serao enviadas ao display no comando showmessage
@param   cIdentify		ID da funcao						
@param   cType 			Tipo de mensagem
@param   cMessage		Mensagem						
@param   bBlock 		Bloco de codigo
@author  Varejo
@version P11.8
@since   23/07/2012
@return  Nil
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STFMessage( cIdentify , cType , cMessage , bBlock )

Local nPos          := 0    //Posicao

Default cIdentify 	:= ""
Default cType		:= ""
Default cMessage		:= "" 
Default bBlock		:= NIL

If !Empty(cIdentify) .AND. !Empty(cType) .AND. !Empty(cMessage)
	
	nPos := AscanMessage(cIdentify)
	
	If nPos > 0
		aMessage[nPos][3] += IIf(!(IsBlind()),CRLF," ") + cMessage
	Else
		Aadd(aMessage,{UPPER(Alltrim(cIdentify)),AvaliableType(cType),cMessage, bBlock})
	EndIf

    // Guarda ultimas mensagens exibidas no sistema
    //Adiciona Mensagem sempre na primeira posicao do array 
    //para manter sempre o mesmo tamanho, o ultimo elemento eh descartado
    
    
    AINS(aMsgBkp , 1) 
    aMsgBkp[1] := {UPPER(Alltrim(cIdentify)),AvaliableType(cType),cMessage, Time()}
  
    
EndIf

Return NIL


//-------------------------------------------------------------------
/*/{Protheus.doc} AvaliableType
avalia o tipo de mensagem recebida				
@param   cType 			Tipo de mensagem
@author  Varejo
@version P11.8
@since   23/07/2012
@return  cType 			Tipo de mensagem
@obs     
@sample
/*/
//-------------------------------------------------------------------
Static Function AvaliableType(cType)
    
Default cType := ""

If UPPER(Alltrim(cType)) == "ALERT"
	cType := "MSGALERT"
ElseIf UPPER(Alltrim(cType)) == "STOP" 
	cType := "MSGSTOP"
ElseIf UPPER(Alltrim(cType)) == "YESNO" 
	cType := "MSGYESNO"
ElseIf UPPER(Alltrim(cType)) == "NOYES" 
	cType := "MSGNOYES"   
ElseIf UPPER(Alltrim(cType)) == "OK" 
	cType := "MSGINFO"  
ElseIf UPPER(Alltrim(cType)) == "RUN" 
	cType := "MSGRUN"
ElseIf UPPER(Alltrim(cType)) == "FWMSGRUN" 
    cType := "FWMSGRUN"
ElseIf UPPER(Alltrim(cType)) == "POPUP" 
	cType := "POPUP"		
ElseIf UPPER(Alltrim(cType)) == "STOPPOPUP" 
	cType := "STOPPOPUP"		
Else
	cType := ""
EndIf

Return cType


//-------------------------------------------------------------------
/*/{Protheus.doc} STFGetMessage
Retorna as mensagens armazenadas para o ID informado por parametros				
@param   cIdentify 			ID da mensagem que deseja receber
@author  Varejo
@version P11.8
@since   23/07/2012
@return  cMessage 			retorna mensagens armazenadas para o ID informado
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STFGetMessage(cIdentify)

Local nPos          := 0        //Posicao da mensagem no array
Local cMessage      := ""       //Mensagem

Default cIdentify := ""

nPos := AscanMessage(cIdentify)

If nPos > 0
	cMessage := aMessage[nPos][3]
EndIf

Return cMessage


//-------------------------------------------------------------------
/*/{Protheus.doc} STFShowMessage
Exibe as mensagens do ID indicado			
@param   cIdentify 			ID da mensagem que deseja exibir
@author  Varejo
@version P11.8
@since   23/07/2012
@return  uRet 			retorna mensagens armazenadas para o ID informado
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STFShowMessage(cIdentify)

Local nPos 		:= 0 
Local uRet		:= NIL

Default cIdentify := ""
    
PARAMTYPE 0 Var cIdentify   AS Character    DEFAULT ""

nPos := AscanMessage(cIdentify) 
	
If nPos > 0 
	
	//Exibe as mensagens dependendo do tipo de execucao atual	
	uRet := STIMessage(aMessage[nPos][3], aMessage[nPos][2], aMessage[nPos][4] , cIdentify )
							 
							
                                                                            
EndIf

STFCleanMessage(cIdentify)
	
Return uRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STFCleanMessage
apaga as mensagens do ID indicado			
@param   cIdentify 			ID da mensagem que deseja exibir
@author  Varejo
@version P11.8
@since   23/07/2012
@return  Nil
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STFCleanMessage(cIdentify)
	
Local nPos := 0

Default cIdentify := ""

PARAMTYPE 0 Var cIdentify   AS Character    DEFAULT ""

If Empty(cIdentify)
	aMessage := {}
Else
	nPos := AscanMessage(cIdentify)
	If nPos > 0
		aDel(aMessage,nPos)
		aSize(aMessage,Len(aMessage)-1)
	EndIf
EndIf
	
Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} STFCleanInterfaceMessage
Apaga as mensagens do inteface atual			
@author  Varejo
@version P11.8
@since   23/07/2012
@return  Nil
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STFCleanInterfaceMessage()

STIMessage("")

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} AscanMessage
Procura as mensagens do ID indicado			
@param   cIdentify 			ID da mensagem que deseja exibir
@author  Varejo
@version P11.8
@since   23/07/2012
@return  nRet 			Posicao da mensagens no array de mensagen
@obs     
@sample
/*/
//-------------------------------------------------------------------
Static Function AscanMessage(cIdentify)
      
Local nPos := 0
Local nRet := 0

Default cIdentify := ""

nPos := aScan(aMessage,{ |x| UPPER(Alltrim(x[1])) == UPPER(Alltrim(cIdentify)) })

If nPos > 0 .AND. !Empty(aMessage[nPos][2])	
	nRet := nPos
EndIf

Return nRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STIMessage
STIMessage  Exibe as mensagens dependendo do tipo de execucao atual		
@param   cMsg 			Mensagem a ser exibida
@param   cType 			Tipo da mensagem
@param   bBlock 			Bloco a ser a ser executado
@param   cIdentify 		ID da mensagem
@author  Varejo
@version P11.8
@since   23/07/2012
@return  uRet 			retorno generico
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STIMessage(cMsg, cType, bBlock , cIdentify )
 
Local uRet 		:= NIL
Local oMessage 	:= Nil
Local nPos 		:= 0
Local lMobile 	:= STFGetCfg("lMobile", .F.)		//Smart Client Mobile

Default cMsg        := ""
Default cType       := "" 
Default bBlock          := NIL
Default cIdentify   := ""

lMobile := ValType(lMobile) == "L" .AND. lMobile

If FindFunction("STIGetObjTela")
	oMessage := STIGetObjTela()
EndIf


If ValType(oMessage) == "O" 

	If cType == "MSGRUN" .AND. ValType(bBlock) == "B"
		If lMobile
		nPos := AscanMessage(cIdentify)
		Eval(aMessage[nPos][4]) 
		Else
			FWMsgRun(,bBlock, STR0004,cMsg)
		EndIf			
		STFCleanInterfaceMessage()
    ElseIf cType == "FWMSGRUN" .AND. ValType(bBlock) == "B"
  		FWMsgRun( ,bBlock , "Aguarde", cMsg  ) //"Aguarde"
	ElseIf cType $ "MSGNOYES#MSGYESNO#MSGINFO"			
		
		//Versao Mobile exibe novas janelas de mensagens
		If lMobile
			Do Case
			Case cType == "MSGNOYES"
				cType := "FWAlertNoYes"
				
			Case cType == "MSGYESNO"
				cType := "FWAlertYesNo"
				
			Case cType == "MSGINFO"
				cType := "FWAlertInfo"
				
			EndCase
		EndIf
		
		uRet := &(Upper(cType) +"('" + StrTran(StrTran(StrTran(StrTran(cMsg, CHR(10), " " ), CHR(13), ""),"'",""), '"', "") + "')")
	ElseIF AllTrim(cType) == "POPUP"
		If lMobile
			FWAlertInfo(cMsg)
		Else
		MsgAlert(cMsg)		
		EndIf	
	ElseIF AllTrim(cType) == "STOPPOPUP"
		If lMobile
			FWAlertError(cMsg)
		Else
		MsgStop(cMsg)
		EndIf	

	Else	
		STISetMsg(Upper(cMsg))
	EndIf	
		
	
Else 

     //To Do Tratar mensagem yes/no e ok
	If IsBlind()
		If cType $ "MSGNOYES#MSGYESNO#MSGINFO#POPUP#STOPPOPUP"
			uRet := .T.	
		EndIf
		ConOut(cType + " | " + cMsg) 
        If ( cType == "MSGRUN" .OR. cType == "FWMSGRUN") .AND. ValType(bBlock) == "B"        	 
        	FWMsgRun( ,bBlock ,"Aguarde", cMsg ) //"Aguarde" 				
        EndIf   
	ElseIF AllTrim(cType) == "POPUP"
		If lMobile
			FWAlertInfo(cMsg)
		Else
		MsgAlert(cMsg)
		EndIf
	ElseIF AllTrim(cType) == "STOPPOPUP"
		If lMobile
			FWAlertError(cMsg)
		Else
		MsgStop(cMsg)						 				
		EndIf
    ElseIf !Empty(cType) .AND. (   !( cType == "MSGRUN" .OR. cType == "FWMSGRUN") .OR.  ValType(bBlock) <> "B")
        uRet := &(Upper(cType) +"('" + StrTran(StrTran(StrTran(StrTran(cMsg, CHR(10), " " ), CHR(13), ""),"'",""), '"', "") + "')")
    ElseIf ( cType == "MSGRUN" .OR. cType == "FWMSGRUN") .AND. ValType(bBlock) == "B"  
 		FWMsgRun( ,bBlock ,"Aguarde", cMsg ) //"Aguarde"   
	EndIf
EndIf

Return uRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STFLatestMsg()
Mostra as ultimas mensagens exibidas no sistema     
@param  lBorder     	Mostra borda da janela
@param  lShowEmail  	Mostra opcao de email
@param  lShowArq  	Mostra opcao de Salvar em arquivo
@param  lShowWind  	Mostra janela com mensagem

@author  Varejo
@version P11.8
@since   08/01/2015
@return  cMSG           Retorna texto com as ultimas mensagens exibidas no sistema
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STFLatestMsg( lBorder ,lShowEmail , lShowArq , lShowWind)

Local cMSG := ""        // Mensagem
Local nX   := 0         // Contador

Default lBorder     	:= .T.
Default lShowEmail  	:= .T.
Default lShowArq	   	:= .T.
Default lShowWind	   	:= .T.


For nX := 1 To Len(aMsgBkp)
    If ValType( aMsgBkp[nX] ) == "A" 
        cMsg += Alltrim(Str(nX)) + (" - ")
        cMsg += aMsgBkp[nX][4]
        cMsg += " - " + aMsgBkp[nX][3] 
		if lClientHtml
			cMsg += "<br><br>"
		Else
			cMsg += Chr(10)+Chr(13) 
		Endif

    Endif	
Next nX

if lClientHtml
	cMsg:= "<font size=4>" + cMsg + "</font>""
Endif

If lShowWind
	STPosMSG( "Histórico de mensagens" , cMSG ,lBorder ,lShowEmail ,; 
			   lShowArq) //"Histórico de mensagens"
EndIf			   


Return cMSG



//-------------------------------------------------------------------   
/*/{Protheus.doc} STPosMSG
Exibe mensagem em tela com o padrao do TOTVS PDV
@param  cTitulo      	Titulo da janela
@param  cMsg     		Mensagem a ser exibida
@param  lBorder     	Mostra borda da janela
@param  lShowEmail  	Mostra opcao de email
@param  lShowArq  	Mostra opcao de Salvar em arquivo
@param  lHtml  	    Formato do texto é html?
@param  lFullScreen   Abre tela cheia?
@author  Varejo
@version P11.8
@since   08/01/2014
@return  Nil
@obs     
@sample
/*/
//-------------------------------------------------------------------   
Function STPosMSG(  cTitulo  	, cMsg 	, lBorder 		,lShowEmail	, ;
					 lShowArq 	, lHtml , lFullScreen)
	
Local oBtnOk        := Nil      //Obj botao sair
Local oBtnMail      := Nil      //Obj botao opcoes Copiar colar recortar
Local oLstMsg       := Nil      //Obj say mensagem
Local oDlg          := Nil      //Obj tela
Local oEdit         := Nil      //Objeto para texto apresentada na tela
Local nWidth		:= 500		//Largura 
Local nHeight		:= 500		//Altura 
Local nSEWidth		:= 240		//Simple Editor Largura 
Local nSEHeight		:= 220		//Simple Editor Altura
Local aRes			:= {}	   	//Recupera Resolução atual
Local nLineBtns		:= 	231	   	//Linha dos Botoes
Local nColBtOk		:= 	185	   	//Coluna do Botao Ok
Local nColBtEmail	:= 	95	   	//Coluna do Botao Email
Local nColBtArq		:= 	005	   	//Coluna do Botao Arquivo      

Default cTitulo     	:= ""
Default cMsg        	:= ""
Default lBorder     	:= .T.
Default lShowEmail  	:= .T.
Default lShowArq	   	:= .T.
Default lHtml	      	:= .F.
Default lFullScreen		:= .F.

If lFullScreen
	aRes			:= GetScreenRes()	// Recupera Resolução atual
	nWidth			:= aRes[1]			// Largura 
	nHeight			:= aRes[2]			// Altura
	nSEWidth		:= (nWidth/2) * 0.96	// Largura 
	nSEHeight		:= (nHeight/2) * 0.88	// Altura
EndIf 

DEFINE FONT oFont NAME "Courier New" SIZE 09,21

// Se exibir a borda da janela
If lBorder
	DEFINE MSDIALOG oDlg TITLE cTitulo FROM 000, 000  TO nHeight, nWidth COLORS 0, 16777215 PIXEL
Else
	DEFINE MSDIALOG oDlg TITLE cTitulo FROM 000, 000  TO nHeight, nWidth COLORS 0, 12632256 PIXEL STYLE nOR(WS_VISIBLE,WS_POPUP)
EndIf

oEdit := TSimpleEditor():New(   005     	,005    ,oDlg   ,nSEWidth    ,;
                                nSEHeight ,       ,.T.    ,       ,;
                                oFont   	,.T.    )

oEdit:TextFormat(IIF(lHtml,1,2))//1=Html 2=Texto simples
oEdit:Load(cMsg)    

nLineBtns := (oEdit:nClientHeight/2) + 10 //Posicao da linha dos Botoes

If lFullScreen
	nColBtOk	:= 	(oEdit:nClientHeight)-75    //Coluna do Botao Ok
	nColBtEmail	:= 	(oEdit:nClientHeight/2)-25  //Coluna do Botao Email
EndIf 

oBtnOk  := TButton():New( nLineBtns,nColBtOk, STR0005  ,oDlg,{|| oDlg:End() },    60,15,,,.F.,.T.,.F.,,.F.,,,.F. )//"Ok"
oBtnOk:SetCSS(  POSCSS (GetClassName(oBtnOk)    , CSS_BTN_FOCAL ))

If lShowEmail
	oBtnMail  := TButton():New( nLineBtns,nColBtEmail, STR0006 ,oDlg,{|| STFSendMail(cMsg,cTitulo,.T.) },60,15,,,.F.,.T.,.F.,,.F.,,,.F. )//"Email"
	oBtnMail:SetCSS(    POSCSS (GetClassName(oBtnMail)  , CSS_BTN_FOCAL ))
EndIf

If lShowArq
	oBtnSave    := TButton():New( nLineBtns,005, STR0002 ,oDlg,{|| STFGrvArq(cMsg) },60,15,,,.F.,.T.,.F.,,.F.,,,.F. )//"Arquivo..."
	oBtnSave:SetCSS(    POSCSS (GetClassName(oBtnSave)  , CSS_BTN_FOCAL ))
EndIf

SetKey(VK_F10, Nil )

ACTIVATE MSDIALOG oDlg CENTERED

SetKey(VK_F10, { || STFLatestMsg() } )

Return Nil

//-------------------------------------------------------------------   
/*/{Protheus.doc} STDGrvArq
Gera e grava o Arquivo texto com as Mensagens de Log

@author  Varejo
@version P11.8
@since   18/02/2014
@return  Nil
@obs     
@sample
/*/
//-------------------------------------------------------------------   
Function STFGrvArq(cMsg)

Local aArea := GetArea()        // Area atual
Local nHandle := ""             // Handle do arquivo texto
Local aParametros := {}         // Array que armazena os parametros MV_LJ
Local cCaixa := STDNumCash()    // Código do Caixa logado
Local cStation  := STFGetStation("CODIGO")  // Estacao atual
Local cHora := Substr(Time(),1,2) + SUBSTR(TIME(), 4, 2) // Hora formatada sem dois pontos
Local cData := Substr(Dtoc(dDataBase),1,2) + SUBSTR(Dtoc(dDataBase), 4, 2) + SUBSTR(Dtoc(dDataBase), 7, 4) // Data formatada sem as barras   
Local nI    := 0                // Contador
Local cParametro := ""          // Parâmetro recebidos do Array para envio no FCreate
Local cLocal := SuperGetMV("MV_LJLLOG",,"")    // Local em que será gravado o arquivo

Default cMsg   := ""            // Mensagens a serem exibidas

DbSelectArea("SX6")

DbGoTop()
While SX6->(!EoF()) 
    If "MV_LJ" $ SX6->X6_VAR  
        Aadd (aParametros, {SX6->X6_VAR , SX6->X6_CONTEUD})
    Endif
SX6->(DbSkip())
End

If Empty(cLocal)
    nHandle := FCreate(cCaixa + cStation + cData + cHora + '.txt',0) // Grava na System
Else
    nHandle := FCreate(cLocal + cCaixa + cStation + cData + cHora + '.txt',0) // grava no local determinado via parâmetro
EndIf    
    
cParametro := cMsg 
cParametro += Chr(10)+Chr(13) + Chr(10)+Chr(13)    
    
For nI := 1 To Len(aParametros) 

    If Empty(cParametro)
        cParametro := aParametros[nI][1] + " " +  AllTrim(aParametros[nI][2]) + Chr(10)+Chr(13) 
    Else 
        cParametro += aParametros[nI][1] + " " +  AllTrim(aParametros[nI][2]) + Chr(10)+Chr(13) 
    EndIf
    
Next nI


FWRITE(nHandle, cParametro ) // Grava arquivo texto 

MsgAlert("Arquivo gerado com sucesso") //"Arquivo gerado com sucesso"

FClose(nHandle)

RestArea(aArea)

Return Nil


