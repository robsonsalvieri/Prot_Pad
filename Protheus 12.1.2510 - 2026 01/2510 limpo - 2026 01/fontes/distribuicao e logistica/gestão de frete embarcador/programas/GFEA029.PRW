#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#include "rwmake.ch"
#include "ap5mail.ch"

#DEFINE _CRLF CHR(13)+CHR(10)

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA029
Cadastro de Frete Referência 

@author João Leonardo Schmidt
@since 02/04/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFEA029()
	Local oBrowse

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("GUN")
	oBrowse:SetMenuDef("GFEA029")
	oBrowse:SetDescription("Frete Referência")
	// Cria o filtro para o programa exibir apenas os registro referente ao "Frete Referência""
	oBrowse:SetFilterDefault("GUN_TPTAB == '4'")
	// Define os campos que serão exibidos no Browse
	oBrowse:SetOnlyFields({'GUN_CODTAB', 'GUN_TPTAB', 'GUN_INFRTO', 'GUN_INFRTD', 'GUN_CDTPOP', 'GUN_CDTPVC', 'GUN_CDGRP', 'GUN_CDTRP', 'GUN_MODAL', 'GUN_CDCLFR', 'GUN_FRTPES', 'GUN_PERIMP'})
 
	// Inclusão das opções de visão
	oBrowse:SetAttach(.T.)
 
	oBrowse:Activate()
Return(Nil)

Static Function MenuDef()
	Local aRotina := {}
	
	ADD OPTION aRotina TITLE "Pesquisar" 					ACTION "AxPesqui"        								OPERATION 1  	ACCESS 0 // "Pesquisar"
	ADD OPTION aRotina TITLE "Visualizar" 					ACTION "VIEWDEF.GFEA029" 								OPERATION 2  	ACCESS 0 // "Visualizar"
	ADD OPTION aRotina TITLE "Incluir" 						ACTION "VIEWDEF.GFEA029" 								OPERATION 3  	ACCESS 0 // "Incluir"
	ADD OPTION aRotina TITLE "Alterar" 						ACTION "VIEWDEF.GFEA029" 								OPERATION 4  	ACCESS 0 // "Alterar"
	ADD OPTION aRotina TITLE "Excluir" 						ACTION "VIEWDEF.GFEA029" 								OPERATION 5  	ACCESS 0 // "Excluir"
	ADD OPTION aRotina TITLE "Copiar" 						ACTION "VIEWDEF.GFEA029"								OPERATION 9  	ACCESS 0 // "Copiar"
	ADD OPTION aRotina TITLE "Imprimir" 					ACTION "VIEWDEF.GFEA029" 								OPERATION 8  	ACCESS 0 // "Imprimir"
	ADD OPTION aRotina TITLE "Inclusão em lote" 			ACTION "GFEA029BLOT()"									OPERATION 10  	ACCESS 0
	ADD OPTION aRotina TITLE "Solicitar Cotação Unica" 		ACTION "GFEA029COT(GUN->GUN_FILIAL,GUN->GUN_CODTAB)"	OPERATION 13  	ACCESS 0  	
	ADD OPTION aRotina TITLE "Solicitar Cotação em lote" 	ACTION "GFEA029COT()"									OPERATION 14  	ACCESS 0
	ADD OPTION aRotina TITLE "Cancelar Recorrência" 		ACTION "GFEA29CREC()"									OPERATION 15  	ACCESS 0  	
Return aRotina

Static Function ModelDef()
	Local oModel

	oModel := MPFormModel():New("GFEA029", /* */, { |oX| GFEA029VAL( oX ) }, /**/, /**/, /*bCancel*/)
	oModel:AddFields("GFEA029_GUN", Nil, FWFormStruct(1,"GUN"),/*bPre*/,/*bPost*/,/*bLoad*/)
	oModel:SetPrimaryKey({"GUN_FILIAL", "GUN_CODTAB"})
	oModel:SetDescription("Frete Referência")
	oModel:SetActivate( {|oMod| GFEA029ACT(oMod)} )	
Return oModel

Static Function ViewDef()
	Local oModel  	 := FWLoadModel("GFEA029")
	Local oStruct 	 := FWFormStruct(2,"GUN")
	Local oView   	 := Nil
	Local nX	  	 := 0
	// Array responsável por identificar os campos que serão exibidos em tela
	Local aCmpFrtRef := {'GUN_CODTAB', 'GUN_TPTAB', 'GUN_DUPSEN', 'GUN_DATDE', 'GUN_DATATE', 'GUN_PRIOR', 'GUN_NRCIOR', 'GUN_NRREOR',;
						 'GUN_CDREM', 'GUN_NRCIDS', 'GUN_NRREDS', 'GUN_CDDEST', 'GUN_INFRTO', 'GUN_INFRTD', 'GUN_CDTPOP',;
						 'GUN_DSTPOP', 'GUN_CDTPVC', 'GUN_DSTPVC', 'GUN_CDGRP', 'GUN_DSGRP', 'GUN_CDTRP', 'GUN_NMTRP',;
						 'GUN_MODAL', 'GUN_CDCLFR', 'GUN_DSCLFR', 'GUN_FRTPES', 'GUN_PERIMP', 'GUN_EMAIL',;
						 'GUN_TPPRAZ', 'GUN_PRAZO', 'GUN_IMPINC', 'GUN_TPREF', 'GUN_SOLMOD', 'GUN_UMPESO', 'GUN_CRIUSU', 'GUN_CRIDAT',;
						 'GUN_ALTUSU', 'GUN_ALTDAT', 'GUN_PERVIG', 'GUN_QTDANT', 'GUN_QTDPRZ', 'GUN_QTDLEM', 'GUN_TPFREQ', 'GUN_RECOR',;
						 'GUN_SOLMOD', 'GUN_SOLSIT', 'GUN_WFSIT', 'GUN_SOLDTP', 'GUN_SOLDTS', 'GUN_SOLDTU', 'GUN_SOLDTL', 'GUN_SOLDTB',;
						 'GUN_SOLDTR', 'GUN_SOLDTE', 'GUN_SOLEMI', 'GUN_SOLMFE'}
	
	oView := FWFormView():New()
	
	oView:SetModel(oModel)
	oView:AddField( "GFEA029_GUN" , oStruct, /*cLinkID*/ )
	
	// Realiza a leitura da estrutura do model e retira os campos que não estão definidos no array base
	For nX := Len(oStruct:aFields) To 1 STEP -1
		If ASCAN(aCmpFrtRef,oStruct:aFields[nX][1]) == 0
			oStruct:RemoveField(oStruct:aFields[nX][1])
		EndIf		
	Next
Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA029ACT
Função responsável por setar o tipo de tabela como "4 - Frete Referência" 

@author João Leonardo Schmidt
@since 02/04/2018
@version 1.0

@param oModel - Modelo de Dados da função principal
/*/
//-------------------------------------------------------------------
Function GFEA029ACT(oModel)
	Local nOp := oModel:GetOperation()
	
	If nOp == MODEL_OPERATION_INSERT 
		oModel:SetValue("GFEA029_GUN", "GUN_TPTAB", "4")
	EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA029VAL
Função responsável por validar os dados inseridos no cadastro.
Esta função utiliza o Objeto GFEValidaPrazos que concentra as validações genérica da tabela GUN

@author João Leonardo Schmidt
@since 02/04/2018
@version 1.0

@param oModel - Modelo de Dados da função principal
/*/
//------------------------------------------------------------------- 
Function GFEA029VAL(oModel)
	Local oValPrazos  := GFEValidaPrazos():New()
	Local nOpc        := (oModel:GetOperation())
	
	// Valida se a operação é de inclusão ou alteração
	If nOpc == MODEL_OPERATION_INSERT .OR. nOpc == MODEL_OPERATION_UPDATE
		// "Seta" os dados necessários para execução do método de validação
		oValPrazos:setDataDe(FwFldGet('GUN_DATDE'))
		oValPrazos:setDataAte(FwFldGet('GUN_DATATE'))
		oValPrazos:setCdRem(FwFldGet('GUN_CDREM'))
		oValPrazos:setNrCiOr(FwFldGet('GUN_NRCIOR'))
		oValPrazos:setNrReOr(FwFldGet('GUN_NRREOR'))
		oValPrazos:setCdDest(FwFldGet('GUN_CDDEST'))
		oValPrazos:setNrCiDs(FwFldGet('GUN_NRCIDS'))
		oValPrazos:setNrReDs(FwFldGet('GUN_NRREDS'))
		oValPrazos:setTpTab(FwFldGet('GUN_TPTAB'))
		If GFXCP12123("GUN_TPREF")
			oValPrazos:setTpRef(FwFldGet('GUN_TPREF'))
		EndIf
		If GFXCP12123("GUN_SOLMOD")
			oValPrazos:setSolMod(FwFldGet('GUN_SOLMOD'))
		EndIf
		oValPrazos:setCdTrp(FwFldGet('GUN_CDTRP'))
		
		// Executa o método de validação
		oValPrazos:Validar()
		
		// Verificado a situação após a execução
		If oValPrazos:getStatus() == .F.
			// Busca o retorno da execução do método
			Help( ,, 'HELP',, oValPrazos:getMensagem(), 1, 0,)
			oValPrazos:Destroy()
			Return
		EndIf
		
		oValPrazos:Destroy()
	EndIf
	
	If nOpc == MODEL_OPERATION_UPDATE
		RecLock("GUN",.F.)
			GUN->GUN_ALTUSU	:= UsrRetName(RetCodUsr())
			GUN->GUN_ALTDAT := Date()
		GUN->(MsUnlock())
	EndIf
		
Return .T. 

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA29CONT
Função responsável por sugerir o e-mail com base no cadastro de contato do transportador

@author João Leonardo Schmidt
@since 30/01/2018
@version 1.0

/*/
//------------------------------------------------------------------- 
Function GFEA29CONT()
	Local cEmail 	:= ""
	Local cTam	 	:= TamSX3("GUN_EMAIL")[1]

	GU2->(dbSetOrder(1))
	If GU2->(dbSeek(xFilial("GU2")+M->GUN_CDTRP))
		While !(GU2->(EoF())) .And. GU2->GU2_FILIAL == xFilial("GU2") .And. GU2->GU2_CDEMIT == M->GUN_CDTRP
			If GFXCP12117("GU2_RECREF") .And. GU2->GU2_RECREF == "1"
				If cTam > (Len(AllTrim(cEmail)) + Len(AllTrim(GU2->GU2_EMAIL)) + 1) 
					If Empty(cEmail)
						cEmail := AllTrim(GU2->GU2_EMAIL)
					Else
						cEmail := cEmail + ";" + AllTrim(GU2->GU2_EMAIL)
					EndIf
				EndIf
			EndIf
			
			GU2->(dbSkip())
		EndDo
	EndIf
Return cEmail

Function GFEA29PXVIG(nOpc)
	Local dDat    := SToD("")
	Local dUltMes := 0
	Local cPxMes  := 0
	Local dDatAux := SToD("")
	Local cAux	  := ""
	
	Default nOpc := 0
		
	If M->GUN_TPFREQ == "2"
		If nOpc == 1
			dDat := M->GUN_DATATE + 1
		ElseIf nOpc == 2
			If M->GUN_PERVIG == "1"
				dUltMes := LastDay(M->GUN_DATATE)
				
				If M->GUN_DATATE == dUltMes
					dDat := M->GUN_DATATE + 1
					dUltMes := LastDay(dDat)
					
					dDat := dUltMes
				Else
					If Month(M->GUN_DATATE) < 12
						cPxMes := Month(M->GUN_DATATE) + 1
					Else
						cPxMes := 1
					EndIf
					
					If cPxMes == 1
						dDatAux := SToD(AllTrim(STR(Year(M->GUN_DATATE) + 1)) + "0101")
					ElseIf cPxMes < 10 
						dDatAux := SToD(AllTrim(STR(Year(M->GUN_DATATE))) + "0" + AllTrim(STR(cPxMes)) + "01")
					Else
						dDatAux := SToD(AllTrim(STR(Year(M->GUN_DATATE))) + AllTrim(STR(cPxMes)) + "01")
					EndIf
					
					dUltMes := LastDay(dDatAux)
					
					If Day(dUltMes) >= Day(M->GUN_DATATE)
						cAux := AllTrim(STR(Year(dUltMes)))
						
						If Month(dUltMes) < 10
							cAux += "0" + AllTrim(STR(Month(dUltMes)))
						Else
							cAux += AllTrim(STR(Month(dUltMes))) 
						EndIf
						
						If Day(M->GUN_DATATE) < 10
							cAux += "0" + AllTrim(STR(Day(M->GUN_DATATE)))
						Else
							cAux += AllTrim(STR(Day(M->GUN_DATATE)))
						EndIf
					Else
						cAux := dUltMes
					EndIf
					
					dDat := SToD(cAux)
				EndIf
			ElseIf M->GUN_PERVIG == "2"
				dDat := (M->GUN_DATATE + 1) + 13
			ElseIf M->GUN_PERVIG == "3"
				dDat := (M->GUN_DATATE + 1) + 6
			EndIf 
		EndIf
	EndIf
Return dDat

Function GFEA29EWF()
	Local cRet := "0"
	
	If M->GUN_SOLMOD == "1"
		cRet := "0"
	ElseIf M->GUN_SOLMOD == "2"
		cRet := "1"
	EndIf
Return cRet

Function GFEA29REC()
	Local cRet := "0"
	
	If M->GUN_TPFREQ == "1"
		cRet := "0"
	ElseIf M->GUN_TPFREQ == "2"
		cRet := "1"
	EndIf
Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA029COT
Função responsável por iniciar o fluxo de cotação via WorkFlow

@author João Leonardo Schmidt
@since 30/01/2019
@version 1.0

/*/
//------------------------------------------------------------------- 
Function GFEA029COT(cFilCot, cNrCot)
	Local cAliasQry	 := ""
	Local cOriRef	 := ""
	Local cDestRef	 := ""
	Local aAux 	  	 := {} 	
	Local aEmailTMP	 := {}
	Local lExecLote	 := .T.
	Local lEnvio	 := .T.
	Local lPergunteA := .F.
	Local lPergunteB := .F.
	Local cIdArq := GetNextAlias()

	Private cArqCotacao := "\workflow\templates\cotacao_" + cIdArq + "_" + FwTimeStamp(1) + ".html"

	Default cFilCot	:= ""
	Default cNrCot	:= ""

	If GFXPE12125("GFEA029A")
		lPergunteA := .T.
	EndIf

	If GFXPE12125("GFEA029B")
		lPergunteB := .T.
	EndIf

	//Busca os dados
	If Empty(cFilCot) .And. Empty(cNrCot)
		lExecLote := .F.
		If lPergunteB
			Pergunte("GFEA029B")
			If FWGetRunSchedule() .Or. IsBlind()
				cAliasQry := GFEA029ABD()
			Else
				Return
			EndIf
		Elseif lPergunteA
			Pergunte("GFEA029A")
			If FWGetRunSchedule() .Or. IsBlind()
				cAliasQry := GFEA029ABD()
			Else
				Return
			EndIf
		EndIf
	Else
		cAliasQry := GFEA029ABD(cFilCot, cNrCot)
	EndIf
	If !Empty(cAliasQry)
		If (cAliasQry)->(Eof()) 
			ApMsgAlert("Não foi encontrado registro","Frete Referencia")
			Return .F.
		EndIf
	  
		//Preenche o array	
		While (cAliasQry)->(!Eof()) 
			
			aAux := {}
			
			aAdd(aAux, (cAliasQry)->GUN_CODTAB)
			aAdd(aAux, (cAliasQry)->GUN_EMAIL)
			
			If Empty((cAliasQry)->GUN_EMAIL)
				lEnvio := .F.
				If lExecLote
					MsgAlert("E-mail para envio do WorkFlow não está preenchido. O envio não será realizado.")
					Return .F.
				EndIf
			EndIf       
			
			// Definindo a Origem do frete referência
			cOriRef := GFEA29Ori((cAliasQry)->GUN_NRCIOR, (cAliasQry)->GUN_NRCIOR, (cAliasQry)->GUN_CDREM)
			aAdd(aAux, cOriRef)
			
			// Definindo o Destino do frete referência
			cDestRef := GFEA29Dest((cAliasQry)->GUN_NRCIDS, (cAliasQry)->GUN_NRREDS, (cAliasQry)->GUN_CDDEST)
			aAdd(aAux, cDestRef)
			    
			aAdd( aAux,   POSICIONE("GUB", 1, XFILIAL("GUB") + (cAliasQry)->GUN_CDCLFR, "GUB_DSCLFR")  )               
			aAdd( aAux,   POSICIONE("GV4", 1, XFILIAL("GV4") + (cAliasQry)->GUN_CDTPOP, "GV4_DSTPOP")  )              
			aAdd( aAux,   POSICIONE("GV3", 1, XFILIAL("GV3") + (cAliasQry)->GUN_CDTPVC, "GV3_DSTPVC")  )               
			aAdd( aAux,   StrZero(Day(StoD((cAliasQry)->GUN_DATATE)),2) + "/" + StrZero(Month(StoD((cAliasQry)->GUN_DATATE)),2) + "/" + Str(Year(StoD((cAliasQry)->GUN_DATATE)),4)   	   )             
			aAdd( aAux,   GFEA019POS("GU3", (cAliasQry)->GUN_CDTRP)   	   )         
			aAdd( aAux,   StrZero(Day(StoD((cAliasQry)->GUN_DATDE)),2) + "/" + StrZero(Month(StoD((cAliasQry)->GUN_DATDE)),2) + "/" + Str(Year(StoD((cAliasQry)->GUN_DATDE)),4)   	   )             
			
			aAdd( aEmailTMP, aAux )
			
			GUN->(DbSetOrder(1))
			If GUN->(DbSeek((cAliasQry)->GUN_FILIAL+(cAliasQry)->GUN_CODTAB))		
				If GFXCP12123("GUN_SOLSIT")
					Reclock("GUN",.F.)
						GUN->GUN_SOLSIT := "2"
						GUN->GUN_SOLDTS := Date()
						If GUN->GUN_QTDPRZ != 0
							GUN->GUN_SOLDTU := Date() + GUN->GUN_QTDPRZ
						EndIf
						If GUN->GUN_QTDLEM != 0
							GUN->GUN_SOLDTL	:= Date() + GUN->GUN_QTDLEM
						EndIf
						GUN->GUN_WFSIT 	:= "2"
					GUN->(MsUnlock())
				EndIf	
			EndIf
			
			(cAliasQry)->(DbSkip())
		EndDo
	  
		(cAliasQry)->(dbCloseArea())
		//manda e-mail sobre as cotações
		If lEnvio .And. GFEA029MAIL(aEmailTMP)
			MsgAlert("Os registros de frete referência foram enviados para solicitação via WorkFlow!")		
		Else
			MsgAlert("Ocorreu algum erro no processamento do WorkFlow para o frete referência!")
		EndIf

		// Efetua a exclusão do arquivo de foi criado no servidor apos uso para adequação ao debito tecnico.
		If File(cArqCotacao) 
			FErase(cArqCotacao)
		EndIf
	EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA029MAIL
Função responsável por enviar e-mail 

@author João Leonardo Schmidt
@since 30/01/2018
@version 1.0

@param aEmailTMP - Array com chave da Requisição e Email
/*/
//------------------------------------------------------------------- 
Function GFEA029MAIL(aEmailTMP)
	Local cRemetnt		:= AllTrim( SuperGetMV("MV_RELACNT",.F.,"") )
	Local aAnexos   	:=  {} 
	Local nX			:= 1
	Local aAux          := {}
	Local cTemplate     := SUPERGETMV( "MV_AGRO036", .T., "" )
	Local cProsse       := POSICIONE("N7L",1,XFILIAL("N7L")+cTemplate,"N7L_PROCES")
	
	If Empty(cTemplate)
		ApMsgAlert("Preencher o parametro MV_AGRO036","Frete Referencia")
		Return .F.
	EndIf
	
	//Percorre todo o array com os e-mail
	While Len(aEmailTMP) >= nX
	
		If nx == 1 .OR. aEmailTMP[nX - 1][2] <> aEmailTMP[nX][2]
			aAux := {}
		EndIf
		
		AADD(aAux, aEmailTMP[nX])
	
		If Len(aEmailTMP) == nX .OR. aEmailTMP[nX][2] <> aEmailTMP[nX+1][2]
			//Cria o template para o workflow
			CriaTemplate(aAux)
			
			//Envia e-mail - Utiliza função do Agro
			OGX017(aEmailTMP[nX][2] ,	;   //E-mails dos destinatários
				   "",		;					//Corpo do e-mail
				   "",		;					//Alias do browse que chamou a tela envio de email
				   "GUN_CODTAB = '" + aEmailTMP[nX][1] + "'",; //Chave utilizada como filtro do registro pai
				   cProsse,	;					//Processo utilizado para filtro de template
				   {},		;					//Array de indices para a tabela temporaria
				   0,		;					//Numero da ordem dos indices a ser utilizada
				   aAnexos,	;					//Array de anexos para o e-mail
				   cRemetnt,;					//Remetente
				   cTemplate,;					//Codigo do Workflow
				   .T.,		;					//Executa automaticamente ?
				   .T.,		;					//Possui WF ?
				   {"GFEA029", "GUN", 	"GUN_CODTAB = '" +aEmailTMP[nX][1] + "'" , "GFEA029WFRT()", {GUN->GUN_CODTAB}})  //Array do WF
			
		EndIf
		
		nX++						
	EndDo
  
return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} CriaTemplate
Cria template para enviar o e-mail de cotação

@author João Leonardo Schmidt
@since 30/01/2019
@version 1.0

@param aEmailTMP - Array com chave da Requisição e Email
/*/
//------------------------------------------------------------------- 
Static Function CriaTemplate(aEmailTMP)
	Local nX
	Local nHandle 
	Local cHtml := ''

	If !File(cArqCotacao)
		nHandle := FCreate(cArqCotacao)
	EndIf

	cHtml += RetornaHtml('Head') + RetornaHtml('BodyIni') 
	cHtml := StrTran( cHtml , "%GUN_CDTRP%", aEmailTMP[1][9]  )

	For nX := 1 To Len(aEmailTMP)
		cHtml +=  RetornaHtml('BodyMid') 
		cHtml := StrTran( cHtml , "%CHAVE%"		, xFilial("GUN")+aEmailTMP[nX][1]  )
		cHtml := StrTran( cHtml , "%GUN_NRCIOR%", aEmailTMP[nX][3]  )
		cHtml := StrTran( cHtml , "%GUN_NRCIDS%", aEmailTMP[nX][4]  )
		cHtml := StrTran( cHtml , "%GUN_NRCLFR%", aEmailTMP[nX][5]  )
		cHtml := StrTran( cHtml , "%GUN_CDTPOP%", aEmailTMP[nX][6]  )
		cHtml := StrTran( cHtml , "%GUN_CDTPVC%", aEmailTMP[nX][7]  )
		cHtml := StrTran( cHtml , "%GUN_DATATE%", aEmailTMP[nX][8]  )
		cHtml := StrTran( cHtml , "%GUN_DATDE%" , aEmailTMP[nX][10]  )
	Next nX 

	cHtml += RetornaHtml('BodyFim') 
	FWrite(nHandle, cHtml  ) 
	
	FClose(nHandle) 
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} RetornaHtml
Retorna trechos do Html para construção 

@author João Leonardo Schmidt
@since 30/01/2019
@version 1.0

@param cParam - parametro referente ao retorno do html
/*/
//------------------------------------------------------------------- 
Static Function RetornaHtml(cParam)
	Local cRetorno := ''
	
	If cParam == "Head"
		cRetorno += "<!DOCTYPE html>																									" + _CRLF
		cRetorno += "<html>                                                                                                             " + _CRLF
		cRetorno += '<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/css/bootstrap.min.css">               ' + _CRLF
		cRetorno += '<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/css/bootstrap-theme.min.css">         ' + _CRLF
		cRetorno += "<head>                                                                                                             " + _CRLF
		cRetorno += '<script src="https://ajax.googleapis.com/ajax/libs/jquery/2.1.1/jquery.min.js" type="text/javascript"></script>    ' + _CRLF
		cRetorno += '<script src="https://cdnjs.cloudflare.com/ajax/libs/jquery-maskmoney/3.0.2/jquery.maskMoney.min.js"                type="text/javascript"></script>' + _CRLF
		cRetorno += '<script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/js/bootstrap.min.js"></script>                        ' + _CRLF
		cRetorno += "<title>Cota&ccedil;&atilde;o Frete Refer&ecirc;ncia</title>                                               " + _CRLF
		cRetorno += '    <script type="text/javascript">                                                                                ' + _CRLF
		cRetorno += "		$(document).ready(function (){                                                                              " + _CRLF
		cRetorno += '			  $(".valFretePreso").maskMoney({                                                                       ' + _CRLF
		cRetorno += "				allowNegative: false,                                                                               " + _CRLF
		cRetorno += "				decimal: '.',                                                                                       " + _CRLF
		cRetorno += "				affixesStay: false                                                                                  " + _CRLF
		cRetorno += "			  });                                                                                                   " + _CRLF
		cRetorno += '			  $(".valAliqImposto").maskMoney({                                                                      ' + _CRLF
		cRetorno += "				allowNegative: false,                                                                               " + _CRLF
		cRetorno += "				decimal: '.',                                                                                       " + _CRLF
		cRetorno += "				numeralMaxLength: true,                                                                             " + _CRLF
		cRetorno += "				affixesStay: false                                                                                  " + _CRLF
		cRetorno += "			  });		                                                                                            " + _CRLF
		cRetorno += "		});                                                                                                         " + _CRLF
	
		cRetorno += "  function Enviar(pBotao)																							" + _CRLF	
		cRetorno += " 		{																											" + _CRLF
		cRetorno += " 	  //wfForm.cObs.value = wfForm.textarea.value																	" + _CRLF
		cRetorno += " 		  wfForm.cBtRetorno.value= pBotao																			" + _CRLF
		cRetorno += " 		var primeiro = true;																						" + _CRLF
		cRetorno += ' 		var resultado = "";																							' + _CRLF
		cRetorno += ' 	  $(".linha").each(function(){																					' + _CRLF
		cRetorno += " 	    var chave =  $('#chave').val();												" + _CRLF
		cRetorno += " 		var fretePreso =  $('#fretePreso').val();									" + _CRLF
		cRetorno += " 		var aliqImposto =  $('#aliqImposto').val();									" + _CRLF
		cRetorno += " 		var incImposto =  $('#incImposto').val();									" + _CRLF
		cRetorno += " 		console.log(chave);																							" + _CRLF	
		cRetorno += " 		console.log(fretePreso);																					" + _CRLF
		cRetorno += " 		console.log(aliqImposto);                                                                                   " + _CRLF
		cRetorno += " 		console.log(incImposto);                                                                                   " + _CRLF
		cRetorno += " 	if (primeiro){																									" + _CRLF
		cRetorno += ' 			resultado = chave+";"+fretePreso+";"+aliqImposto+";"+incImposto;														' + _CRLF	
		cRetorno += ' 			primeiro = false;																						' + _CRLF	
		cRetorno += ' 		}																											' + _CRLF
		cRetorno += ' 		else																										' + _CRLF	
		cRetorno += ' 			resultado+= "|"+chave+";"+fretePreso+";"+aliqImposto+";"+incImposto;													' + _CRLF			
		cRetorno += " 	  });																											" + _CRLF
		cRetorno += ' 	  $("#resultado").val(resultado);																				' + _CRLF
		cRetorno += ' 	  wfForm.resultado.value=resultado;	 																			' + _CRLF
		cRetorno += " 	  console.log(wfForm.resultado.value);																			" + _CRLF	
		cRetorno += " 	  return true																									" + _CRLF
		cRetorno += " 	}																												" + _CRLF
	
		cRetorno += "    </script>                                                                                                      " + _CRLF
		cRetorno += '  <style type="text/css">                                                                                          ' + _CRLF
		cRetorno += "    body { padding-top: 10px;                                                                                      " + _CRLF
		cRetorno += "			background-color: #fbfbfb;                                                                              " + _CRLF
		cRetorno += "		}                                                                                                           " + _CRLF
		cRetorno += "	.ctn{                                                                                                           " + _CRLF
		cRetorno += "		background-color: #FFFFFF;                                                                                  " + _CRLF
		cRetorno += "		border-radius: .25rem;                                                                                      " + _CRLF
		cRetorno += "		 box-shadow: 0 4px 8px 0 rgba(0, 0, 0, 0.15);                                                               " + _CRLF
		cRetorno += "	}                                                                                                               " + _CRLF
		cRetorno += "	.bg {		                                                                                                    " + _CRLF
		cRetorno += "		background-color: #0c9abe;                                                                                  " + _CRLF
		cRetorno += "		 border-radius: .25rem;                                                                                     " + _CRLF
		cRetorno += "		 box-shadow: 0 4px 8px 0 rgba(0, 0, 0, 0.15);                                                               " + _CRLF
		cRetorno += "		 font-family: inherit;                                                                                      " + _CRLF
		cRetorno += "		  font-size: 16px;                                                                                          " + _CRLF
		cRetorno += "		  font-style: normal;                                                                                       " + _CRLF
		cRetorno += "		  font-stretch: normal;                                                                                     " + _CRLF
		cRetorno += "		  line-height: 1.5;                                                                                         " + _CRLF
		cRetorno += "		  letter-spacing: normal;                                                                                   " + _CRLF
		cRetorno += "		  text-align: left;                                                                                         " + _CRLF
		cRetorno += "		  color: #ffffff;                                                                                           " + _CRLF
		cRetorno += "	}                                                                                                               " + _CRLF
		cRetorno += "	                                                                                                                " + _CRLF
		cRetorno += "	.bg2{                                                                                                           " + _CRLF
		cRetorno += "		background-color: #FFFFFF;                                                                                  " + _CRLF
		cRetorno += "		border-radius: .25rem;                                                                                      " + _CRLF
		cRetorno += "		border: solid 1px #0c9abe;                                                                                  " + _CRLF
		cRetorno += "		font-family: inherit;                                                                                       " + _CRLF
		cRetorno += "		font-size: 16px;                                                                                            " + _CRLF
		cRetorno += "		font-style: normal;                                                                                         " + _CRLF
		cRetorno += "		font-stretch: normal;                                                                                       " + _CRLF
		cRetorno += "		line-height: 1.5;                                                                                           " + _CRLF
		cRetorno += "		letter-spacing: normal;                                                                                     " + _CRLF
		cRetorno += "		text-align: center;                                                                                         " + _CRLF
		cRetorno += "		color: #0c9abe;                                                                                             " + _CRLF
		cRetorno += "	}                                                                                                               " + _CRLF
		cRetorno += "	.Background-da-pgina {                                                                                          " + _CRLF
		cRetorno += "	  width: 352px;                                                                                                 " + _CRLF
		cRetorno += "	  height: 24px;                                                                                                 " + _CRLF
		cRetorno += "	  @apply --text;                                                                                                " + _CRLF
		cRetorno += "	}                                                                                                               " + _CRLF
		cRetorno += "	.fontBold {                                                                                                     " + _CRLF
		cRetorno += "	  width: 385px;                                                                                                 " + _CRLF
		cRetorno += "	  height: 66px;                                                                                                 " + _CRLF
		cRetorno += "	  font-family: inherit;                                                                                         " + _CRLF
		cRetorno += "	  font-size: 16px;                                                                                              " + _CRLF
		cRetorno += "	  font-weight: bold;                                                                                            " + _CRLF
		cRetorno += "	  font-style: normal;                                                                                           " + _CRLF
		cRetorno += "	  font-stretch: normal;                                                                                         " + _CRLF
		cRetorno += "	  line-height: normal;                                                                                          " + _CRLF
		cRetorno += "	  letter-spacing: normal;                                                                                       " + _CRLF
		cRetorno += "	  text-align: left;                                                                                             " + _CRLF
		cRetorno += "	  color: #4a5c60;	                                                                                            " + _CRLF
		cRetorno += "	}                                                                                                               " + _CRLF
		cRetorno += "	.fontBoldCab {                                                                                                  " + _CRLF
		cRetorno += "	  width: 385px;                                                                                                 " + _CRLF
		cRetorno += "	  height: 66px;                                                                                                 " + _CRLF
		cRetorno += "	  font-family: inherit;                                                                                         " + _CRLF
		cRetorno += "	  font-size: 30px;                                                                                              " + _CRLF
		cRetorno += "	  font-weight: bold;                                                                                            " + _CRLF
		cRetorno += "	  font-style: normal;                                                                                           " + _CRLF
		cRetorno += "	  font-stretch: normal;                                                                                         " + _CRLF
		cRetorno += "	  line-height: normal;                                                                                          " + _CRLF
		cRetorno += "	  letter-spacing: normal;                                                                                       " + _CRLF
		cRetorno += "	  text-align: left;                                                                                             " + _CRLF
		cRetorno += "	  color: #4a5c60;	                                                                                            " + _CRLF
		cRetorno += "	}                                                                                                               " + _CRLF
		cRetorno += "	.fontBody {                                                                                                     " + _CRLF
		cRetorno += "	  width: 478px;                                                                                                 " + _CRLF
		cRetorno += "	  height: 66px;                                                                                                 " + _CRLF
		cRetorno += "	  font-family: inherit;                                                                                         " + _CRLF
		cRetorno += "	  font-size: 16px;                                                                                              " + _CRLF
		cRetorno += "	  font-weight: 200;                                                                                             " + _CRLF
		cRetorno += "	  font-style: normal;                                                                                           " + _CRLF
		cRetorno += "	  font-stretch: normal;                                                                                         " + _CRLF
		cRetorno += "	  line-height: normal;                                                                                          " + _CRLF
		cRetorno += "	  letter-spacing: normal;                                                                                       " + _CRLF
		cRetorno += "	  text-align: left;                                                                                             " + _CRLF
		cRetorno += "	  color: #4a5c60;	                                                                                            " + _CRLF
		cRetorno += "	}                                                                                                               " + _CRLF
		cRetorno += "  </style>                                                                                                         " + _CRLF
		cRetorno += "</head>                                                                                                            " + _CRLF
	ElseIf cParam == "BodyIni"
		cRetorno += " <body>																											" + _CRLF
		cRetorno += " <br>                                                                                           					" + _CRLF
		cRetorno += ' <form action="mailto:%WFMailTo%" method="post" role="form"  class="form-inline" name="wfForm"> 					' + _CRLF
		cRetorno += '   <input type="hidden" name="cBtRetorno" id="cBtRetorno" value="%cBtRetorno%" />               					' + _CRLF
		cRetorno += '   <input type="hidden" name="resultado" id="resultado" value="%resultado%" />             						' + _CRLF
		cRetorno += '   <div class="container ctn">                                                                  					' + _CRLF
		cRetorno += '   <div class="well">	                                                                        					' + _CRLF
		cRetorno += " 	  <div>                                                                                     					" + _CRLF
		cRetorno += '       <font class="fontBoldCab" >Cota&ccedil;&atilde;o de Frete</font>                                       					' + _CRLF
		cRetorno += " 	  <p>&nbsp;</p>	                                                                            					" + _CRLF
		cRetorno += ' 	  <font class="fontBody">Prezado %GUN_CDTRP%,<br>	                                                    					' + _CRLF
		cRetorno += "       Solicitamos o preenchimento da cota&ccedil;&atilde;o de frete conforme dados a seguir:</font>                                  					" + _CRLF
		cRetorno += " 	  <p>&nbsp;</p>                                                                             					" + _CRLF
		cRetorno += "       <div>                                                                                    					" + _CRLF
		cRetorno += ' 	  <table width="100%" id="tbFretes" name="tbFretes">                                        					' + _CRLF
		cRetorno += " 		<thead>                                                                                 					" + _CRLF
		cRetorno += " 			<th>Origem</th>                                                                     					" + _CRLF
		cRetorno += " 			<th>Destino</th>                                                                    					" + _CRLF
		cRetorno += " 			<th>Classifica&ccedil;&atilde;o Frete</th>                                                        					" + _CRLF
		cRetorno += " 			<th>Tipo de Opera&ccedil;&atilde;o</th>                                                           					" + _CRLF
		cRetorno += " 			<th>Tipo Ve&iacute;culo</th>                                                               					" + _CRLF
		cRetorno += " 			<th>Dt Inicial</th>                                                                   					" + _CRLF
		cRetorno += " 			<th>Dt Final</th>                                                                   					" + _CRLF
		cRetorno += " 			<th>Frete Peso</th>                                                                 					" + _CRLF
		cRetorno += " 			<th>Aliq Imposto</th>                                                           						" + _CRLF
		cRetorno += " 			<th>Inclui Imposto?</th>                                                           						" + _CRLF
		cRetorno += " 		</thead>                                                                                					" + _CRLF
		cRetorno += " 		<tbody>                                                                                 					" + _CRLF
	ElseIf cParam == "BodyMid"
		cRetorno += '			<tr class="linha">																						' + _CRLF
		cRetorno += '				<td>%GUN_NRCIOR%</td>       																		' + _CRLF
		cRetorno += '				<td>%GUN_NRCIDS%</td>																				' + _CRLF
		cRetorno += '				<td>%GUN_NRCLFR%</td>																				' + _CRLF
		cRetorno += '				<td>%GUN_CDTPOP%</td>																				' + _CRLF
		cRetorno += '				<td>%GUN_CDTPVC%</td>       																		' + _CRLF
		cRetorno += '				<td>%GUN_DATDE%</td>       																		' + _CRLF
		cRetorno += '				<td>%GUN_DATATE%</td>       																		' + _CRLF
		cRetorno += '				<td>				        																		' + _CRLF
		cRetorno += '					<input type="hidden" name="chave" id="chave" value="%CHAVE%"/>									' + _CRLF
		cRetorno += '					<input type="text" name="fretePreso" id="fretePreso" class="valFretePreso" maxlength="8" placeholder="00000.00" />		' + _CRLF	
		cRetorno += '				</td> 																								' + _CRLF
		cRetorno += '				<td>																								' + _CRLF
		cRetorno += '					<input type="text" name="aliqImposto" id="aliqImposto" class="valAliqImposto" maxlength="5" placeholder="00.00"/>	'	 + _CRLF			
		cRetorno += '				</td>																								' + _CRLF
		cRetorno += '				<td>																								' + _CRLF
		cRetorno += '					<select name="incImposto" id="incImposto">														' + _CRLF			
		cRetorno += '						<option value="1">Com Imposto</option>																' + _CRLF
		cRetorno += '						<option value="2">Sem Imposto</option>																' + _CRLF
		cRetorno += '					</select>																						' + _CRLF
		cRetorno += '				</td>																								' + _CRLF
		cRetorno += '			</tr>																									' + _CRLF
	ElseIf cParam == "BodyFim"
		cRetorno += " 		</tbody>																									" + _CRLF
		cRetorno += " 	</table>																										" + _CRLF
		cRetorno += " 	<p>&nbsp;</p>																									" + _CRLF
		cRetorno += ' 	<table width="100%">																							' + _CRLF
		cRetorno += " 		<tr>																										" + _CRLF
		cRetorno += " 			<td>																									" + _CRLF
		cRetorno += ' 				  <h6 align="center">																				' + _CRLF
		cRetorno += ' 					<button type="submit" name="btnAprov" class="btn bg"  onclick="Enviar(' + " '4' " + ')"/>Enviar</button>' + _CRLF
		cRetorno += " 				  </h6>																								" + _CRLF	  
		cRetorno += " 			</td>																									" + _CRLF
		cRetorno += " 		</tr>																										" + _CRLF
		cRetorno += " 	</table>																										" + _CRLF
		cRetorno += " 	  <p>&nbsp;</p>																									" + _CRLF
		cRetorno += ' 	  <h6><font size="1" face="Verdana"><center>Em caso de dificuldades por gentileza, entre em contato com nosso departamento de TI</center></font></br></h6> ' + _CRLF
		cRetorno += "     </div>																										" + _CRLF
		cRetorno += "  </div> 																											" + _CRLF
		cRetorno += " </form>																											" + _CRLF
		cRetorno += " </body>																											" + _CRLF
		cRetorno += " </html>																											" + _CRLF
	EndIf

Return cRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA029WFRT
Função de retorno do workflow para atualização do negócio. 

@author João Leonardo Schmidt
@since 30/01/2019
@version 1.0
/*/
//------------------------------------------------------------------- 
Function GFEA029WFRT(oProcess, aRet)
	Local cRetorno 	:= DecodeUTF8(oProcess:oHtml:RetByName("resultado")) //Pega o retorno do html
	Local aAux 		:= {}
	Local aRetorno 	:= {}
	Local nX
	
	aAux := StrTokArr(cRetorno, "|") // divide em array cada registro (linha)
		
	For nX := 1 To Len(aAux)
		AADD(aRetorno, StrTokArr( aAux[nX], ";" ) ) // divide em array cada campo (coluna)
	Next nX 
	
	For nX := 1 To Len(aRetorno)
		GUN->(DbSetOrder(1))
		If GUN->(DbSeek(aRetorno[nX][1])) //Busca o registro e grava as informações
			If GFXCP12123("GUN_SOLSIT")
				If GUN->GUN_SOLSIT == "2"
					Reclock("GUN",.F.)
						GUN->GUN_FRTPES := VAL(	StrTran( aRetorno[nX][2], "," ) 	)
						GUN->GUN_PERIMP := VAL(	StrTran( aRetorno[nX][3], "," ) 	)
						If GFXCP12117("GUN_IMPINC") .And. Len(aRetorno[nX]) > 3
							GUN->GUN_IMPINC	:= aRetorno[nX][4]
						EndIf
						If GFXCP12123("GUN_SOLSIT")
							GUN->GUN_SOLSIT := "3"
						EndIf
						If GFXCP12123("GUN_SOLDTR")
							GUN->GUN_SOLDTR := Date()
						EndIf
					GUN->(MsUnlock())
				ElseIf GUN->GUN_SOLSIT == "4"
					Reclock("GUN",.F.)
						GUN->GUN_FRTPES := VAL(	StrTran( aRetorno[nX][2], "," ) 	)
						GUN->GUN_PERIMP := VAL(	StrTran( aRetorno[nX][3], "," ) 	)
						If GFXCP12117("GUN_IMPINC") .And. Len(aRetorno[nX]) > 3
							GUN->GUN_IMPINC	:= aRetorno[nX][4]
						EndIf
						If GFXCP12123("GUN_SOLDTE")
							GUN->GUN_SOLDTE := Date()							
						EndIf
					GUN->(MsUnlock())
				EndIf
			EndIf
		EndIf
	Next nX 
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA029ABD
Filtra responsável por filtrar os registros que serão enviados

@author João Leonardo Schmidt
@since 30/01/2019
@version 1.0
/*/
//------------------------------------------------------------------- 
Function GFEA029ABD(cFilCot, cNrCot)
	Local cTPOper     := ""
	Local cTPVeic     := ""
	Local cGrpTransp  := ""
	Local cCodTransp  := ""
	Local cClassFrt   := ""
	Local cCidOri     := ""
	Local cRegOri     := ""
	Local cCodRem     := ""
	Local cCidDest    := ""
	Local cRegDest    := ""
	Local cCodDest    := ""
	Local cQuery 	  := ''
	Local cAliasQry   := GetNextAlias()
  
	Default cFilCot := ""
	Default cNrCot	:= ""
  
	If !IsBlind()
	    cTPOper     := MV_PAR01
	    cTPVeic     := MV_PAR02
	    cGrpTransp  := MV_PAR03
	    cCodTransp  := MV_PAR04
	    cClassFrt   := MV_PAR05
	    cCidOri     := MV_PAR06
	    cRegOri     := MV_PAR07
	    cCodRem     := MV_PAR08
	    cCidDest    := MV_PAR09
	    cRegDest    := MV_PAR10
	    cCodDest    := MV_PAR11
	EndIf

    If Empty(cFilCot) .And. Empty(cNrCot)
		If IsBlind()
			If GFXCP12123("GUN_SOLSIT")
				cQuery := "SELECT * FROM "  + RetSqlName('GUN') + " GUN"
				cQuery += " WHERE GUN.D_E_L_E_T_ = ''"
				cQuery += " AND GUN_SOLSIT = '1' ORDER BY GUN_EMAIL"
			EndIf
		Else
			cQuery := " SELECT * FROM "  + RetSqlName('GUN') + " GUN "
			cQuery += "  WHERE GUN.D_E_L_E_T_ = '' "
			If !Empty(cTPOper)
				cQuery += "  AND GUN.GUN_CDTPOP = '"+cTPOper+"' "
			EndIf
			If !Empty(cTPVeic)
				cQuery += "  AND GUN.GUN_CDTPVC = '"+cTPVeic+"' "
			EndIf
			If !Empty(cGrpTransp)
				cQuery += "  AND GUN.GUN_CDGRP  = '"+cGrpTransp+"' "
			EndIf
			If !Empty(cCodTransp)
				cQuery += "  AND GUN.GUN_CDTRP  = '"+cCodTransp+"' "
			EndIf	
			If !Empty(cClassFrt)
				cQuery += "  AND GUN.GUN_CDCLFR  = '"+cClassFrt+"' "
			EndIf	
			If !Empty(cCidOri)
				cQuery += "  AND GUN.GUN_NRCIOR = '"+cCidOri+"' "
			EndIf		
			If !Empty(cRegOri)
				cQuery += "  AND GUN.GUN_NRREOR = '"+cRegOri+"' "
			EndIf		
			If !Empty(cCodRem)
				cQuery += "  AND GUN.GUN_CDREM  = '"+cCodRem+"' "
			EndIf		
			If !Empty(cCidDest)
				cQuery += "  AND GUN.GUN_NRCIDS = '"+cCidDest+"' "
			EndIf		
			If !Empty(cRegDest)
				cQuery += "  AND GUN.GUN_NRREDS = '"+cRegDest+"' "
			EndIf		
			If !Empty(cCodDest)
				cQuery += "  AND GUN.GUN_CDDEST = '"+cCodDest+"' "
			EndIf	
			If GFXCP12123("GUN_SOLSIT")
				cQuery += " AND GUN_SOLSIT = '1'"
			EndIf
			cQuery += " ORDER BY GUN_EMAIL "
		EndIf
	Else
		cQuery := "SELECT * FROM " + RetSqlName('GUN') + " GUN" 
    	cQuery += " WHERE GUN_FILIAL = '" + cFilCot + "'"
		cQuery += " AND GUN_CODTAB = '" + cNrCot + "'"
		cQuery += " AND GUN.D_E_L_E_T_ = ''"
		cQuery += " ORDER BY GUN_EMAIL"		
	EndIf	
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasQry,.T.,.T.)
	
Return cAliasQry

Function GFEA29VENC()
	Local cQuery 	:= ""
	Local cAliasQry	:= GetNextAlias()
	
	If GFXCP12123("GUN_SOLSIT")
		cQuery := "SELECT GUN.GUN_FILIAL, GUN.GUN_CODTAB FROM " + RetSqlName("GUN") + " GUN"
		cQuery += " WHERE (GUN.GUN_SOLSIT = '2'"
		cQuery += " OR GUN.GUN_SOLSIT = '1')"
		cQuery += " AND GUN.GUN_SOLDTU <> ''"
		cQuery += " AND GUN.GUN_SOLDTU <= '" + DToS(Date()) + "'"
		cQuery += " AND GUN.D_E_L_E_T_ = ''"
		
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasQry,.T.,.T.)
		
		While !((cAliasQry)->(EoF()))
			GUN->(dbSetOrder(1))
			If GUN->(dbSeek((cAliasQry)->GUN_FILIAL + (cAliasQry)->GUN_CODTAB))
				RecLock("GUN",.F.)
					GUN->GUN_SOLSIT := "4"
				GUN->(MsUnlock())
			EndIf
			
			(cAliasQry)->(DbSkip())
		EndDo
	EndIf
Return

Function GFEA29LEM()
	Local GFEMail	
	Local cOriRef	:= ""
	Local cDestRef	:= ""
	Local cQuery 	:= ""
	Local cAliasQry	:= GetNextAlias()
	
	If GFXCP12123("GUN_SOLDTB")
		cQuery := "SELECT GUN.GUN_FILIAL, GUN.GUN_CODTAB FROM " + RetSqlName("GUN") + " GUN"
		cQuery += " WHERE GUN.GUN_SOLSIT = '2'"
		cQuery += " AND GUN.GUN_SOLDTB = ''"
		cQuery += " AND GUN.GUN_SOLDTL <> ''"
		cQuery += " AND GUN.GUN_SOLDTL <= '" + DToS(Date()) + "'"
		cQuery += " AND GUN.D_E_L_E_T_ = ''"
		
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasQry,.T.,.T.)
		
		While !((cAliasQry)->(EoF()))
			GUN->(dbSetOrder(1))
			If GUN->(dbSeek((cAliasQry)->GUN_FILIAL + (cAliasQry)->GUN_CODTAB))
				// Envia E-mail de lembrete
				// Título e texto do corpo do e-mail 
				GFEMail := GFEEMail():New()
				
				GFEMail:addTextBody('A cotação de frete ainda não foi respondida! O formulário para resposta foi enviado no dia ' + StrZero(Day(GUN->GUN_SOLDTS),2) + "/" + StrZero(Month(GUN->GUN_SOLDTS),2) + "/" + Str(Year(GUN->GUN_SOLDTS),4) +;
									 ' e serão aceitas as respostas até o dia ' + StrZero(Day(GUN->GUN_SOLDTU),2) + "/" + StrZero(Month(GUN->GUN_SOLDTU),2) + "/" + Str(Year(GUN->GUN_SOLDTU),4) + '. Abaixo os dados da solicitação:')
				
				// Estrutura da tabela
				GFEMail:addTextTable('COTAÇÕES')
				GFEMail:addHeaderTable(2,'Origem')
				GFEMail:addHeaderTable(2,'Destino')
				GFEMail:addHeaderTable(2,'Classificação de Frete')
				GFEMail:addHeaderTable(2,'Tipo de Operação')
				GFEMail:addHeaderTable(2,'Tipo Veículo')
				GFEMail:addHeaderTable(2,'Data Inicial')
				GFEMail:addHeaderTable(2,'Data Final')
				
				// Definindo a Origem do frete referência
				cOriRef := GFEA29Ori(GUN->GUN_NRCIOR, GUN->GUN_NRCIOR, GUN->GUN_CDREM)
				
				// Definindo o Destino do frete referência
				cDestRef := GFEA29Dest(GUN->GUN_NRCIDS, GUN->GUN_NRREDS, GUN->GUN_CDDEST)
				
				// Dados da tabela
				GFEMail:addColumnTable(1, cOriRef)
				GFEMail:addColumnTable(1, cDestRef)
				GFEMail:addColumnTable(1, POSICIONE("GUB", 1, XFILIAL("GUB") + GUN->GUN_CDCLFR, "GUB_DSCLFR"))
				GFEMail:addColumnTable(1, POSICIONE("GV4", 1, XFILIAL("GV4") + GUN->GUN_CDTPOP, "GV4_DSTPOP"))
				GFEMail:addColumnTable(1, POSICIONE("GV3", 1, XFILIAL("GV3") + GUN->GUN_CDTPVC, "GV3_DSTPVC"))
				GFEMail:addColumnTable(1, StrZero(Day(GUN->GUN_DATATE),2) + "/" + StrZero(Month(GUN->GUN_DATATE),2) + "/" + Str(Year(GUN->GUN_DATATE),4))
				GFEMail:addColumnTable(1, StrZero(Day(GUN->GUN_DATDE),2) + "/" + StrZero(Month(GUN->GUN_DATDE),2) + "/" + Str(Year(GUN->GUN_DATDE),4)) 
				
				GFEMail:setPara(GUN->GUN_EMAIL)
				GFEMail:setAssunto("Lembrete Falta de Resposta de cotação.")
				GFEMail:setBody(GFEMail:getEmail())
				GFEMail:setMsg(.F.)
				GFEMail:sendEmail()
				
				If GFEMail:getStatus()
					RecLock("GUN",.F.)
						GUN->GUN_SOLDTB := Date()
					GUN->(MsUnlock())
				EndIf
				
				GFEMail:Destroy(GFEMail)
			EndIf
			
			(cAliasQry)->(DbSkip())
		EndDo
	EndIf
Return

Function GFEA29NOV()
	Local cQuery 	:= ""
	Local cAliasQry	:= GetNextAlias()
	Local aDadosGUN	:= {}
	Local nX		:= 0
	Local cUsrName	:= USRRETNAME(RETCODUSR())
	Local dSoldDtp	:= SToD("")
	
	If GFXCP12123("GUN_RECOR")
		cQuery := "SELECT GUN.GUN_FILIAL, GUN.GUN_CODTAB FROM " + RetSqlName("GUN") + " GUN"
		cQuery += " WHERE GUN.GUN_RECOR = '1'"
		cQuery += " AND GUN.GUN_SOLDTP <= '" + DToS(Date() + 1) + "'"
		cQuery += " AND GUN.D_E_L_E_T_ = ''"
		
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasQry,.T.,.T.)
		
		While !((cAliasQry)->(EoF()))
			GUN->(dbSetOrder(1))
			If GUN->(dbSeek((cAliasQry)->GUN_FILIAL + (cAliasQry)->GUN_CODTAB))
				Aadd(aDadosGUN, {GUN->GUN_FILIAL, GUN->GUN_DUPSEN, GUN->GUN_NRCIOR, GUN->GUN_NRREOR, GUN->GUN_CDREM,;
								 GUN->GUN_NRCIDS, GUN->GUN_NRREDS, GUN->GUN_CDDEST, GUN->GUN_CDTPOP, GUN->GUN_CDTPVC,;
								 GUN->GUN_CDGRP, GUN->GUN_CDTRP, GUN->GUN_MODAL, GUN->GUN_TPPRAZ, GUN->GUN_PRAZO,;
								 GUN->GUN_DMEST, GUN->GUN_PRIOR, GUN->GUN_CDCLFR, GUN->GUN_EMAIL, GUN->GUN_TPREF,;
								 GUN->GUN_SOLMOD, GUN->GUN_UMPESO, GUN->GUN_QTDPRZ, GUN->GUN_QTDLEM, GUN->GUN_SOLEMI,;
								 GUN->GUN_TPFREQ, GUN->GUN_PERVIG, GUN->GUN_QTDANT})
			
				RecLock("GUN",.F.)
					GUN->GUN_RECOR := "2"
				GUN->(MsUnlock())
			EndIf
			
			(cAliasQry)->(dbSkip())
		EndDo	
		
		For nX := 1 To Len(aDadosGUN)
			If aDadosGUN[nX][27] == "1"
				dSoldDtp := Date() + 30
			ElseIf aDadosGUN[nX][27] == "2"
				dSoldDtp := Date() + 15
			ElseIf aDadosGUN[nX][27] == "3"
				dSoldDtp := Date() + 7
			EndIf 
			
			RecLock("GUN",.T.)
				GUN->GUN_FILIAL	:= aDadosGUN[nX][1]
				GUN->GUN_CODTAB := GETSXENUM("GUN","GUN_CODTAB")
				GUN->GUN_TPTAB	:= "4"
				GUN->GUN_DUPSEN	:= aDadosGUN[nX][2]
				GUN->GUN_DATDE	:= Date() + 1
				GUN->GUN_DATATE	:= dSoldDtp - 1
				GUN->GUN_NRCIOR	:= aDadosGUN[nX][3]
				GUN->GUN_NRREOR	:= aDadosGUN[nX][4]
				GUN->GUN_CDREM	:= aDadosGUN[nX][5]
				GUN->GUN_NRCIDS	:= aDadosGUN[nX][6]
				GUN->GUN_NRREDS	:= aDadosGUN[nX][7]
				GUN->GUN_CDDEST	:= aDadosGUN[nX][8]
				GUN->GUN_CDTPOP	:= aDadosGUN[nX][9]
				GUN->GUN_CDTPVC	:= aDadosGUN[nX][10]
				GUN->GUN_CDGRP	:= aDadosGUN[nX][11]
				GUN->GUN_CDTRP	:= aDadosGUN[nX][12]
				GUN->GUN_MODAL	:= aDadosGUN[nX][13]
				GUN->GUN_TPPRAZ	:= aDadosGUN[nX][14]
				GUN->GUN_PRAZO	:= aDadosGUN[nX][15]
				GUN->GUN_DMEST	:= aDadosGUN[nX][16]
				GUN->GUN_PRIOR	:= aDadosGUN[nX][17]
				GUN->GUN_CDCLFR	:= aDadosGUN[nX][18]
				GUN->GUN_EMAIL	:= aDadosGUN[nX][19]
				GUN->GUN_TPREF	:= aDadosGUN[nX][20]
				GUN->GUN_SOLMOD	:= aDadosGUN[nX][21]
				GUN->GUN_UMPESO	:= aDadosGUN[nX][22]
				If GFXCP12123("GUN_RECOR")
					GUN->GUN_CRIUSU	:= cUsrName
					GUN->GUN_CRIDAT	:= Date()			
					GUN->GUN_QTDPRZ	:= aDadosGUN[nX][23]
					GUN->GUN_QTDLEM	:= aDadosGUN[nX][24]
					GUN->GUN_SOLSIT	:= "1"
					GUN->GUN_SOLEMI	:= aDadosGUN[nX][25]
					GUN->GUN_RECOR	:= "1"
					GUN->GUN_TPFREQ	:= aDadosGUN[nX][26]
					GUN->GUN_PERVIG	:= aDadosGUN[nX][27]
					GUN->GUN_QTDANT	:= aDadosGUN[nX][28]
					GUN->GUN_WFSIT	:= "1"
					GUN->GUN_SOLDTP := dSoldDtp
				EndIf
								
				ConfirmSx8()
			GUN->(MsUnLock())
		Next nX	
	EndIf
Return

Function GFEA29Ori(cCidOri, cRegOri, cRemet)
	Local cOriRef := ""
	
	Default cCidOri := ""
	Default cRegOri := ""
	Default cRemet	:= ""
	
	//Origem
	If !Empty(cCidOri)                           
		cOriRef := "Cidade: " + POSICIONE("GU7",1,XFILIAL("GU7")+cCidOri,"GU7_NMCID")                     
	ElseIf !Empty(cRegOri)  
		cOriRef := "Regiao: " + POSICIONE("GU9",1,XFILIAL("GU9")+cRegOri,"GU9_NMREG")                           
	ElseIf !Empty(cRemet)
		cOriRef := "Remetente: " + POSICIONE("GU3",1,XFILIAL("GU3")+cRemet,"GU3_NMEMIT")    
	EndIf
Return cOriRef

Function GFEA29Dest(cCidDest, cRegDest, cDest)
	Local cDestRef := ""
	
	Default cCidDest := ""
	Default cRegDest := ""
	Default cDest	 := ""
	
	//Destino 
	If !Empty(cCidDest)                    
		cDestRef := "Cidade: " + POSICIONE("GU7",1,XFILIAL("GU7")+cCidDest,"GU7_NMCID")  
	ElseIf !Empty(cRegDest)                           
		cDestRef := "Regiao: " + POSICIONE("GU9",1,XFILIAL("GU9")+cRegDest,"GU9_NMREG")  
	ElseIf !Empty(cDest)
		cDestRef := "Destinatario: " + POSICIONE("GU3",1,XFILIAL("GU3")+cDest,"GU3_NMEMIT")    
	EndIf    
Return cDestRef

Function GFEA29CREC()
	If GFXCP12123("GUN_RECOR")
		If GUN->GUN_RECOR == "1"
			If MsgYesNo("Deseja cancelar a recorrência para este frete referência?")
				RecLock("GUN",.F.)
					GUN->GUN_RECOR := "3"
				GUN->(MsUnlock())
			EndIf
		Else
			GFEHelp("Este frete referência não possui recorrência!","Este registro não se aplica recorrência ou já gerou o próximo frete referência.","Não é possível cancelar a recorrência!")
		EndIf
	EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} SchedDef
Responsável por disponbilizar o programa para Schedule

@author João Leonardo Schmidt
@since 11/03/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SchedDef()
   Local aOrd := {}
   Local aParam := {}
   
   aParam := {"P"        ,;    //Processo
              "" 		 ,;    //PERGUNTE OU PARAMDEF
              ""         ,;    //ALIAS p/ relatorio
              aOrd       ,;    //Array de Ordenacao p/ relatorio
              ""         }     //Titulo para Relatório
Return aParam
