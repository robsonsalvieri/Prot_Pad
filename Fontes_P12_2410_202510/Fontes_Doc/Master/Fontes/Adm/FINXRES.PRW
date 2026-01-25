#INCLUDE "FWBROWSE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TBICODE.CH" 
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "FINXRES.CH"
#INCLUDE 'FWMVCDEF.CH'

//Static para contingência do uso da função MTFLUIGATV
Static __lMTFLUIGATV := FindFunction("MTFLUIGATV")
Static __lEncViag As Logical

//--------------------------------
// Funcao para abertura da sessao
//--------------------------------
Function FinXRESOSe(cSessao,oSvc,cEntidade,cRegistro,cLicenc)
Local cUserReser	:= ""
Local cSenha		:= ""
Local lRet			:= .T.
Local aErro			:= {}
Local nX			:= 0

Default cSessao		:= ""
Default oSvc		:= Nil
Default cEntidade	:= ""
Default cRegistro	:= ""
Default cLicenc	:= ""

dbSelectArea("FL2")
dbSetOrder(1) //FL2_FILIAL+FL2_BKOEMP+FL2_LICENC
If FWLSEnable(3124) //TOTVS Reserve
	
	If dbSeek(xFilial("FL2")+PadR(cEmpAnt+cFilAnt,TamSX3("FL2_BKOEMP")[1])+cLicenc)
		
		cUserReser	:= AllTrim(FL2->FL2_USER)
		cSenha		:= AllTrim(FL2->FL2_PSWRES)

		oSvc := WSAutenticacao():New()

		oSvc:OWSAUTENTICARRQ:cUsuario	:= cUserReser
		oSvc:OWSAUTENTICARRQ:cSenha		:= cSenha
		
		oSvc:Autenticar()

		If ValType(oSvc:OWSAUTENTICARRESULT:OWSERROS) == "U"
			if ValType(oSvc:OWSAUTENTICARRESULT:cSessao) == "U"
				lRet := .F.
				Aadd(aErro,STR0021)	//"Erro de Conexão com o Reserve"
				Aadd(aErro,STR0022)	//"Não foi possivel iniciar a sessão de comunicação"
				FINXRESLog(cEntidade,STR0023,cRegistro,aErro)	//"Abertura de sessão"
			else
				cSessao := oSvc:OWSAUTENTICARRESULT:cSessao
			endif
		Else

			lRet := .F.

			For nX := 1 To Len(oSvc:OWSAUTENTICARRESULT:OWSERROS:OWSERRO)
				Aadd(aErro,"CCODERRO: " + oSvc:OWSAUTENTICARRESULT:OWSERROS:OWSERRO[nX]:CCODERRO)
				Aadd(aErro,"CMENSAGEM: "+ oSvc:OWSAUTENTICARRESULT:OWSERROS:OWSERRO[nX]:CMENSAGEM)
			Next nX

			FINXRESLog(cEntidade,STR0023,cRegistro,aErro)	//"Abertura de sessão"
		
		EndIf
	Else
		Aadd(aErro,STR0022)	//"Dados de conexao não definidos"
		Aadd(aErro,STR0025)	//"Verificar os dados de Usuario e senha da empresa"
		FINXRESLog(cEntidade,STR0023,cRegistro,aErro)//"Abertura de sessão"
		lRet := .F.
	EndIf
Else
	Aadd(aErro,STR0062)	//"Licensa para integração com reserve não encontrada"
	Aadd(aErro,STR0063)	//"Verificar com o Admnistrador do Sistema"
	FINXRESLog(cEntidade,STR0023,cRegistro,aErro)//"Abertura de sessão"
	lRet := .F.
EndIf

Return lRet

//--------------------------------
// Funcao para fechamento da sessao
//--------------------------------
Function FINXRESCSe(cSessao, oSvc)
Default cSessao	:= ""
Default oSvc	:= Nil

If ValType(oSvc) == "O"
	oSvc:oWSSairRq:cSessao := cSessao
	oSvc:Sair()
EndIf

Return

//-----------------------------------
// Funcao para acionar as rotinas de  
// geração de log e envio de e-mail
//-----------------------------------
Function FinXResLog(cEntidade,cProcesso,cRegistro,aErro,lEnvEMail,cLog)

Local aCampos		:= {}
Local cMensagem		:= ""
Local cMsgMail		:= ""
Local nX			:= 0
Local cModoExec		:= If(GetRemoteType() == -1,STR0047,STR0048)	 //Schedule - Rotina de Cadastro 

Default cEntidade	:= ""
Default cProcesso	:= ""
Default cRegistro	:= ""
Default aErro		:= {}
Default lEnvEMail	:= .T.
Default cLog        := ""

//-----------------------------
//Processo de geração do Log
//-----------------------------
cMensagem += STR0026 + cEntidade + CRLF	//"Entidade: "
cMensagem += STR0027 + cProcesso + CRLF	//"Processo: "
cMensagem += STR0028 + cRegistro + CRLF	//"Registro: "
cMensagem += STR0029 + cModoExec + CRLF	//"Modo de Execução: "
cMensagem += STR0030 + CRLF	//"Erro(s):"

For nX := 1 To Len(aErro)
	cMensagem	+= aErro[nX] + CRLF
Next nX

cMensagem += cLog

Aadd(aCampos,{'FL0_ENTIDA',cEntidade})
Aadd(aCampos,{'FL0_DESCRI',cMensagem})

Fina663Log(aCampos)

If lEnvEMail
	//-----------------------------
	// Processo de envio de e-mail
	//-----------------------------
	cMsgMail += STR0026 + cEntidade + "<br>"
	cMsgMail += STR0027 + cProcesso + "<br>"
	cMsgMail += STR0028 + cRegistro + "<br>"
	cMsgMail += STR0029 + cModoExec + "<br>"
	cMsgMail += STR0030 + "<br>"

	For nX := 1 To Len(aErro)
		cMsgMail += aErro[nX] + "<br>"
	Next nX

	FinXResEMa(cMsgMail,cEntidade,cProcesso,cRegistro)
EndIf

Return

//--------------------------------------------------------------------
/*/{Protheus.doc} FNXRESMONTAEMAIL
Função para pegar o e-mail do interessado (destinatário), montar o HTML 
do corpo do e-mail e chamar a função de envio de e-mail. 
  	
@author pedro.alencar
@since 22/10/2013
@version 11.90	
@param nLayout, 1=Adiantamento,2=Prestação de Contas
@param nInteressado, 1=Participante,2=Departamento de Viagem
@param cMensagem, Mensagem a ser enviada
@param cAssunto, Assunto do e-mail
@return lRet, Se .T., enviou o e-mail. Se .F., Não enviou. 
/*/
//--------------------------------------------------------------------
Function FNXRESMONTAEMAIL(nLayout, nInteressado, cMensagem, cAssunto,cOrigem)
Local lRet 		:= .F.
local cHTML 	:= ""
Local cAreaAnt 	:= GetArea()
Local cCodPartic:= ""
Local cTO 		:= ""
Local cEnvia 	:= ""
Local cDeptoViagem := ""
Local nCont 	:= 0
Local aDeptoViagem := {}
Local lDestinatario := .F.
Local cQuery 	:= ""
Local cEntida 	:= ""
Local cRegistro	:= ""
Local cProcWF	:= "SOLADIANTA"
Local cProcWFP	:= "APVPRESTCO"
Default nLayout := 0
Default cMensagem := ""
Default nInteressado := 1
Default cAssunto := ""
Default cOrigem := ""

//Proteção WF Fluig. Caso esteja configurado o email será usado do fluig.
cEnvia := SuperGetMV("MV_RESAVIS",,"") //Se o valor do parâmetro for diferente de '1', não envia e-mail

If nLayout == 1 .Or. nLayout == 3 //Layout 1 = Adiantamento/Layout 3 = Aprovador Adiantamento
	If __lMTFLUIGATV
		If MTFluigAtv("WFFINA667", cProcWF, "WFFIN667" )
			cEnvia	:= ""	
		Endif
	EndIf
ElseIf nLayout == 2 .Or. nLayout == 4  //Layout 2 = Prestação de Contas/Layout 4 = Aprovador Prestação
	If __lMTFLUIGATV
		If MTFluigAtv("WFFINA677", cProcWFP, "WFFIN677" ) .and. (cOrigem == '2' .OR. EMPTY(cOrigem))
			cEnvia	:= ""
		Endif
	EndIf
Endif
	If 	cEnvia == "1"
		cHTML := "<HTML><HEAD></HEAD><BODY><Font face='arial'>"
		If nLayout == 1 //Layout 1 = Adiantamento 
			cHTML += FNXRESCABEC(FLD->FLD_VIAGEM)		
			cHTML += FNXRESADT()
			cCodPartic := FLD->FLD_PARTIC 
			cEntida	:= "FLD"		
			cRegistro := STR0017 + FLD->FLD_VIAGEM		//"Viagem: "
		ElseIf nLayout == 2 //Layout 2 = Prestação de Contas
			If !Empty(FLF->FLF_VIAGEM)
				cHTML += FNXRESCABEC(FLF->FLF_VIAGEM)	
			EndIf
			cHTML += FNXRESPREST()
			cCodPartic := FLF->FLF_PARTIC
			cEntida	:= "FLF"	
			cRegistro := STR0018 + FLF->FLF_TIPO +" "+ FLF->FLF_PRESTA			
		ElseIf nLayout == 3 //Layout 3 = Aprovador Adiantamento
			cHTML += FNXRESCABEC(FLM->FLM_VIAGEM)
			cHTML += FNXRESAPRV()
			cCodPartic := FLM->FLM_APROV			
			cEntida	:= "FLM"
			cRegistro := STR0017 + FLM->FLM_VIAGEM  	//"Viagem: "
		ElseIf nLayout == 4 //Layout 3 = Aprovador Prestação
			If !Empty(FLF->FLF_VIAGEM)
				cHTML += FNXRESCABEC(FLF->FLF_VIAGEM)
			EndIf
			cHTML += FNXRESPREST()
			cCodPartic := FLN->FLN_APROV			
			cEntida	:= "FLN"
			cRegistro := STR0018 + FLN->FLN_TIPO +" "+ FLN->FLN_PRESTA
		Endif 
		cHTML += FNXRESMSG(cMensagem)
		cHTML += "</Font></BODY></HTML>"
			
		If nInteressado == 1 //Interessado 1 = Participante
			dbSelectArea("RD0")
			dbSetOrder(1) //FILIAL+CÒDIGO			
			If dbSeek(xFilial("RD0")+cCodPartic)
				lDestinatario := .T.
				cTO := RD0->RD0_EMAIL			
			Endif
		ElseIf nInteressado == 2 //Interessado 2 = Departamento de Viagem
			cDeptoViagem := SuperGetMV("MV_RESGVIA",,"") 
			aDeptoViagem := StrToKarr(cDeptoViagem, ";")
			
			For nCont := 1 To Len(aDeptoViagem)				
				cQuery += "SELECT RD0_EMAIL"
				cQuery += " FROM " + RetSqlName("RD0")  + " RD0"
				cQuery += " WHERE RD0_FILIAL ='" + xFilial("RD0") + "' AND RD0.D_E_L_E_T_ = '' "
				cQuery += " AND RD0_USER = '" + aDeptoViagem[nCont] + "'"		
				cQuery := ChangeQuery(cQuery)
				
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"RD0TMP",.T.,.T.)
				dbSelectArea("RD0TMP")
				
				If RD0TMP->(!EOF())
					lDestinatario := .T.
					cTo += RD0TMP->RD0_EMAIL 
				Endif
				RD0TMP->(dbCloseArea())				
			Next
		Endif
		
		If lDestinatario == .T.		
			lRet := FINXRESEMa(cHTML,cEntida,"FNXRESMONTAEMAIL",cRegistro,cTO,cAssunto)
		Else 
			lRet := .F.
		Endif
	Endif
		
	RestArea(cAreaAnt) 
Return lRet

//--------------------------------------------------------------------
/*/{Protheus.doc} FNXRESCABEC
Função para montar o HTML do cabeçalho do e-mail de aviso, com base na 
tabela FL5
  	
@author pedro.alencar
@since 22/10/2013
@version 11.90	
@param cCodViagem, Código da viagem
@return cRet, String contendo o HTML 
/*/
//--------------------------------------------------------------------
Function FNXRESCABEC(cCodViagem)
	Local cRet	:= ""
	Local cHTML := ""
	Local dIni	:= CTOD("//")
	Local dFim	:= CTOD("//")
	Local cOrigem := ""
	Local cDestino := ""
	Local cAreaAnt := GetArea()	
	
	dbSelectArea("FL5")
	dbSetOrder(1)	//FILIAL+CÒDIGO
	If dbSeek(xFilial("FL5")+cCodViagem)  	  
		cCodViagem := FL5->FL5_VIAGEM
		dIni := FL5->FL5_DTINI
		dFim := FL5->FL5_DTFIM
		cOrigem := FL5->FL5_DESORI
		cDestino := FL5->FL5_DESDES		
	Else		
		dIni := FW3->FW3_DTINI
		dFim := FW3->FW3_DTFIM
		cOrigem  := AllTrim(FWGetSx5("12", AllTrim(FW3->FW3_CODORI))[1][4])
		cDestino  := AllTrim(FWGetSx5("12", AllTrim(FW3->FW3_CODDES))[1][4])		
	Endif
	  
	cHTML := "<TABLE width=700>"
	cHTML += "   <tr width=700><td colspan=2 width=700 bgColor=#538ED5><font color=White>"+OemToANSI(STR0001)+"</font></td></tr>" //STR0001: "VIAGEM"
	cHTML += "   <tr width=700>"
	cHTML += "       <td width=200 align='center'><font size=5><b>" + cCodViagem + "</b></font></td>"
	cHTML += "       <td width=500>"
	cHTML += "           <table width=500>"
	cHTML += "                <tr><td width=100>"+OemToANSI(STR0002)+"</td><td width=150>" + Dtoc(dIni) + "</td>" //STR0002: "De"
    cHTML += "                    <td width=100>"+OemToANSI(STR0003)+"</td><td width=150>" + Dtoc(dFim) + "</td>" //STR0003: "Até"
	cHTML += "                </tr>"
	cHTML += "                <tr width=500><td width=225>"+OemToANSI(STR0004)+"</td><td width=275>" + cOrigem + "</td></tr>" //STR0004: "Origem"
	cHTML += "                <tr width=500><td width=225>"+OemToANSI(STR0005)+"</td><td width=275>" + cDestino + "</td></tr>" //STR0005: "Destino"
	cHTML += "           </table>"
	cHTML += "       </td>"
	cHTML += "    </tr>"
 	cHTML += "</TABLE>"

	cRet := cHTML
	RestArea(cAreaAnt)	
Return cRet

//--------------------------------------------------------------------
/*/{Protheus.doc} FNXRESADT
Função para montar o HTML com informações do Adiantamento de Viagem
  	
@author pedro.alencar
@since 22/10/2013
@version 11.90
@return cRet, String contendo o HTML 
/*/
//--------------------------------------------------------------------
Function FNXRESADT()
	Local cRet := ""
	Local cHTML := ""
	Local cCodAdt := FLD->FLD_ADIANT
	Local dPagt := FLD->FLD_DTPREV
	Local cValor := TransForm(FLD->FLD_VALOR,PesqPict('FLD',"FLD_VALOR"))
	Local cPartic := FLD->FLD_PARTIC
	Local cNomePartic := ""
	Local cAreaAnt := GetArea()
	
	cNomePartic := GETADVFVAL("RD0","RD0_NOME",XFILIAL("RD0")+cPartic,1,"")
	cHTML := "<TABLE width=700>"
	cHTML += "   <tr width=700><td colspan=2 width=700 bgColor=#538ED5><font color=White>"+OemToANSI(STR0006)+"</font></td></tr>" //STR0006: "ADIANTAMENTO"
	cHTML += "   <tr width=700>"
	cHTML += "       <td width=200 align='center'><font size=5><b>" + cCodAdt + "</b></font></td>"
	cHTML += "       <td width=500>"
	cHTML += "           <table width=500>"
	cHTML += "                <tr><td width=100>"+OemToANSI(STR0020)+"</td><td width=150>" + Dtoc(dPagt) + "</td>" //STR0020: "Data Previsão Pagrto."
    cHTML += "                    <td width=100>"+OemToANSI(STR0008)+"</td><td width=150>" + cValor + "</td>" //STR0008: "Valor"
	cHTML += "                </tr>"
	cHTML += "                <tr width=500><td width=225>"+OemToANSI(STR0009)+"</td><td width=275>" + cPartic + " - " + cNomePartic + "</td></tr>" //STR0009: "Passageiro"	
	cHTML += "           </table>"
	cHTML += "       </td>"
	cHTML += "    </tr>"
 	cHTML += "</TABLE>"

	cRet := cHTML
	RestArea(cAreaAnt)	
Return cRet

//--------------------------------------------------------------------
/*/{Protheus.doc} FNXRESPREST
Função para montar o HTML com informações de Prestação De Contas
  	
@author pedro.alencar
@since 22/10/2013
@version 11.90
@return cRet, String contendo o HTML 
/*/
//--------------------------------------------------------------------
Function FNXRESPREST()
	Local cRet 			:= ""
	Local cHTML 			:= ""
	Local cCodPresta 	:= FLF->FLF_PRESTA
	Local cPartic 		:= FLF->FLF_PARTIC
	Local cNomePartic 	:= ""
	Local cAreaAnt 		:= GetArea()
	Local cTpPresta 		:= IIf(FLF->FLF_TIPO == "2","["+STR0019+"]","")
	
	cNomePartic := GETADVFVAL("RD0","RD0_NOME",XFILIAL("RD0")+cPartic,1,"") 
	cHTML := "<TABLE width=700>"
	cHTML += "   <tr width=700><td colspan=2 width=700 bgColor=#538ED5><font color=White>"+OemToANSI(STR0010)+" "+cTpPresta+"</font></td></tr>" //STR0010: "PRESTAÇÃO DE CONTAS"
	cHTML += "   <tr width=700>"
	cHTML += "       <td width=200 align='center'><br><font size=5><b>" + cCodPresta + "</b></font></td>"
	cHTML += "       <td width=500>"
	cHTML += "           <br><table width=500>"
	cHTML += "                <tr width=500><td width=100>"+OemToANSI(STR0009)+"</td><td width=400>" + cPartic + " - " + cNomePartic + "</td></tr>" //STR0009: "Passageiro"	
	cHTML += "           </table>"
	cHTML += "       </td>"
	cHTML += "    </tr>"
 	cHTML += "</TABLE><br>"

	cRet := cHTML
	RestArea(cAreaAnt)	
Return cRet

//--------------------------------------------------------------------
/*/{Protheus.doc} FNXRESAPRV
Função para montar o HTML com informações do Adiantamento de Viagem
  	
@author pedro.alencar
@since 22/10/2013
@version 11.90
@return cRet, String contendo o HTML 
/*/                   
//--------------------------------------------------------------------
Function FNXRESAPRV()
	Local cRet		:= ""
	Local cHTML		:= ""
	Local cCodAdt	:= FLM->FLM_ADIANT
	Local cAprov	:= FLM->FLM_APROV
	Local cPartic	:= FLM->FLM_PARTIC
	Local cNomeApr	:= ""
	Local cNomePart	:= "" 
	Local dPagt		:= CTOD('//')
	Local cValor	:= ""
	Local cAreaAnt	:= GetArea()

	FLD->(dbSetOrder(1))
	If FLD->(MsSeek(xFilial("FLD")+FLM->(FLM_VIAGEM+FLM_PARTIC+FLM_ADIANT)))
		dPagt 	:= FLD->FLD_DTPREV 
		cValor  := TransForm(FLD->FLD_VALOR,PesqPict('FLD',"FLD_VALOR"))
	Endif

	cNomeApr  := GETADVFVAL("RD0","RD0_NOME",XFILIAL("RD0")+cAprov,1,"")	
	cNomePart := GETADVFVAL("RD0","RD0_NOME",XFILIAL("RD0")+cPartic,1,"")
	cHTML := "<TABLE width=700>"
	cHTML += "   <tr width=700><td colspan=2 width=700 bgColor=#538ED5><font color=White>"+OemToANSI(STR0006)+"</font></td></tr>" //STR0006: "ADIANTAMENTO"
	cHTML += "   <tr width=700>"
	cHTML += "       <td width=200 align='center'><font size=5><b>" + cCodAdt + "</b></font></td>"
	cHTML += "       <td width=500>"
	cHTML += "           <table width=500>"
	cHTML += "                <tr><td width=100>"+OemToANSI(STR0020)+"</td><td width=150>" + Dtoc(dPagt) + "</td>" //STR0020: "Data Previsão Pagrto."
    cHTML += "                    <td width=100>"+OemToANSI(STR0008)+"</td><td width=150>" + cValor		 + "</td>" //STR0008: "Valor"
	cHTML += "                </tr>"
	cHTML += "                <tr width=500><td width=225>"+OemToANSI(STR0009)+"</td><td width=275>" + cPartic + " - " + cNomePart + "</td></tr>" //STR0009: "Passageiro"	
	cHTML += "           </table>"
	cHTML += "       </td>"
	cHTML += "    </tr>"
 	cHTML += "</TABLE>"

	cRet := cHTML
	RestArea(cAreaAnt)	
Return cRet

//--------------------------------------------------------------------
/*/{Protheus.doc} FNXRESMSG
Função para tratar a mensagem que será enviada por e-mail, retornando-a
em formato HTML e com quebras de linha se for muito grande 
  	
@author pedro.alencar
@since 22/10/2013
@version 11.90
@param cMSG, Mensagem a ser enviada
@return cRet, String contendo o HTML 
/*/
//--------------------------------------------------------------------
Function FNXRESMSG(cMSG)
	Local cRet := ""
	Local cHTML := ""
	Local nCont := 0
	
	cHTML := "<TABLE width=700>"
	cHTML += "    <tr width=700>"
	cHTML += "        <Td width=80><b>"+OemToANSI(STR0011)+"</b></td>" //STR0011: "Mensagem"
	cHTML += "        <td width=620>" + SubStr(cMSG,1,85) + "</td>"
	cHTML += "    </tr>"
	
	//Se a mensagem conter mais do que 85 caracteres, quebra a string para não estourar o tamnho da linha no HTML
	If Len(cMSG) > 85		
		nCont := 86
		While nCont <= Len(cMSG)			
			cHTML += "<tr width=700>"
			cHTML += "  <Td width=80></td>"
			cHTML += "  <td width=620>" + SubStr(cMSG,nCont,85) + "</td>"		
			cHTML += "</tr>"
			nCont += 86
		EndDo		
	Endif
		
	cHTML += "</TABLE>"	
    cRet := cHTML
Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FINXRESEMa
Função genérica para envio de e-mail de registro de log

@param aDestinat Array com os e-mails destinatários
@param cAssunto	 Assunto do e-mail (Título)
@param cMensagem Mensagem do corpo do e-mail
@return lRet Retorno que indica se o e-mail foi enviado ou não.
@author Totvs
@since 02/09/2013
@version MP11 R9
/*/
//-------------------------------------------------------------------
Function FINXRESEMa(cMensagem,cEntidade,cProcesso,cRegistro,cTO,cAssunto) 
Local lRet			:= .T.
Local cCC			:= ""
Local cFrom			:= GETMV("MV_RELFROM",.F.,"")
Local cSMTPServer	:= GETMV("MV_RELSERV",.F.,"")
Local cSMTPUser 	:= GETMV("MV_RELACNT",.F.,"")
Local cSMTPPass 	:= GETMV("MV_RELPSW",.F.,"")
Local lUseTLSMail 	:= SuperGetMv("MV_RELTLS",,.F.)
Local lUseSSLMail 	:= SuperGetMv("MV_RELSSL",,.F.)
Local nSMTPPort		:= If(GETMV("MV_PORSMTP") == 0, 25, GETMV("MV_PORSMTP"))
Local oMail			:= Nil
Local oMessage 		:= Nil
Local nErro			:= 0
Local lRelAuth 		:= GetMv("MV_RELAUTH",.F., .F.)
Local lAlterEnv 	:= ExistBlock("FNXRESMAIL")
Local aRetEnv		:= {}

Default cMensagem	:= ""
Default cEntidade	:= ""
Default cProcesso	:= ""
Default cRegistro	:= ""
Default cTO := SuperGetMV("MV_RESMAIL",,"")
Default cAssunto	:= STR0032	  //"Log TotvsReserve"

Private cError	:= ""
Private lSendOk	:=	.T.

cProcesso := STR0031 + cProcesso	//"E-mail de log de "

If lAlterEnv
//Altera os dados de envio do e-mail
	//[1] - Destinatario
	//[2] - Assunto
	//[3] - Mensagem
	aRetEnv := ExecBlock("FNXRESMAIL",.F.,.F.)
	
	If Len(aRetEnv) = 3
		cTO 		:= aRetEnv[1] 
		cAssunto 	:= aRetEnv[2]
		cMensagem 	:= aRetEnv[3]
	EndIf
EndIf

//---Tratamento para caso a porta esteja apenas no parametro MV_RELSERV.
If (nPos := AT(':',cSMTPServer)) > 0 
 	nSMTPPort 		:= Val(Substr(cSMTPServer, nPos + 1,Len(cSMTPServer)))
 	cSMTPServer := Substr(cSMTPServer, 0, nPos - 1)  
EndIf

If !Empty(cTO) //Envio de e-mail só ocorre se existirem destinatários

	oMail := TMailManager():New() //Iniciando conexão com o servidor de e-mails
	
	oMail:SetUseSSL(lUseSSLMail)
	oMail:SetUseTLS(lUseTLSMail)

	//conout('Inicializando SMTP')
	oMail:Init( '', cSMTPServer , cSMTPUser, cSMTPPass, 0, nSMTPPort )

	//conout('Setando Time-Out')
	oMail:SetSmtpTimeOut( 500 )

	//conout('Conectando com servidor...')
	nErro := oMail:SmtpConnect()

	//conout('Status de Retorno = '+str(nErro,6))

	If lRelAuth //Autenticando o usuário no servidor de e-mails
		//Conout("Autenticando Usuario ")
		nErro := oMail:SmtpAuth(cSMTPUser ,cSMTPPass)
		//conout('Status de Retorno = '+str(nErro,6))
		If nErro <> 0

			// Recupera erro ...
			cMAilError := oMail:GetErrorString(nErro)
			DEFAULT cMailError := '***UNKNOW***'
			//Conout("Erro de Autenticacao "+str(nErro,4)+' ('+cMAilError+')')
			lRet := .F.
			FinXResLog(cEntidade,cProcesso,cRegistro,{STR0033+str(nErro,4)+' ('+cMAilError+')'},.F.) //"Erro de Autenticacao "
		Endif
	EndIf

	If nErro <> 0
		// Recupera erro
		cMAilError := oMail:GetErrorString(nErro)
		DEFAULT cMailError := '***UNKNOW***'
		//conout(cMAilError)
		//Conout("Erro de Conexão SMTP "+str(nErro,4))
		//conout('Desconectando do SMTP')
		oMail:SMTPDisconnect()
		lRet := .F.

			FinXResLog(cEntidade,cProcesso,cRegistro,{cMAilError,STR0034+str(nErro,4)},.F.) //"Erro de Conexão SMTP "

	Endif

	//conout('Compondo mensagem em memória')

	//Criando o objeto da mensagem do e-mail
	oMessage := TMailMessage():New()
	oMessage:Clear()      
	oMessage:cFrom		:= cFrom
	oMessage:cTo			:= cTo
	oMessage:cBcc			:= cCC
	oMessage:cSubject		:= cAssunto
	oMessage:cBody		:= cMensagem
	oMessage:MsgBodyType( "text/html" )

	//conout(oMessage:cBody)
	//conout('Enviando Mensagem para ['+cTo+'] ')
	nErro := oMessage:Send( oMail )

	If nErro <> 0
		xError := oMail:GetErrorString(nErro)
		//Conout("Erro de Envio SMTP "+str(nErro,4)+" ("+xError+")")
		lRet := .F.
		FinXResLog(cEntidade,cProcesso,cRegistro,{STR0035+str(nErro,4)+" ("+xError+")"},.F.)	//"Erro de Envio SMTP "
	Endif

	//conout('Desconectando do SMTP')
	oMail:SMTPDisconnect()
Else
	FinXResLog(cEntidade,cProcesso,cRegistro,{STR0036},.F.)	//"Parâmetro MV_RESMAIL sem destinatários para envio do e-mail de log."
	lRet := .F.
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³JobResImp ºAutor  ³Alexandre Circenis  º Data ³  10/09/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina do JOB para processar a importacao de solicitacao   º±±
±±º          ³ de viagem em BATCH                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAFIN                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function JobResImp(aParam)
Local aProcessa	:= {}
Local nX		:= 0

Private lManual	:= .F.

Conout(STR0037)	//"Iniciou JOB de Importacao Reserve"
RpcSetType(3)
RPCSetEnv(aParam[1],aParam[2],,,"FIN")

DbSelectArea("FL2")
FL2->(DbSetOrder(1))
While FL2->(!Eof())
	If !Empty(FL2->FL2_USER) .And. !Empty(FL2->FL2_PSWRES)
		Aadd( aProcessa, {FL2->FL2_BKOEMP,FL2->FL2_USER,FL2->FL2_PSWRES, FL2->FL2_LICENC})
	Endif
	FL2->(DbSkip())
EndDo

For nX := 1 to Len(aProcessa)
	DbSelectArea("SM0")
	If SM0->(DbSeek(aProcessa[nX,1]))

		_cEmpresa	:= SM0->M0_CODIGO
		_cFilial	:= SM0->M0_CODFIL
		Conout("Empresa "+ _cEmpresa + " Filial "+ _cFilial)
		RPCClearEnv()
		RpcSetType(3)
		RPCSetEnv(_cEmpresa,_cFilial,,,"FIN")

		//---------------------------------------------
		// Processa a Importacao de Pedidos do Reserve
		//---------------------------------------------
		Fina661(aProcessa[nX,4])

	Endif
Next nX

RPCSetEnv(aParam[1],aParam[2],,,"FIN")

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³JobResExp ºAutor  ³Alexandre Circenis  º Data ³  10/09/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina do JOB para processar a exportação do cadastro de   º±±
±±º          ³ Centro de Custo e Usuarios em BATCH                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAFIN                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function JobResExp(aParam)
Local aProcessa	:= {}
Local nX		:= 0

Private lManual	:= .F.

Conout(STR0038)
RpcSetType(3)
RPCSetEnv(aParam[1],aParam[2],,,"FIN")

DbSelectArea("FL2")
FL2->(DbSetOrder(1))
While FL2->(!Eof())
	If !Empty(FL2->FL2_USER) .And. !Empty(FL2->FL2_PSWRES)
		Aadd( aProcessa, {FL2->FL2_BKOEMP,FL2->FL2_USER,FL2->FL2_PSWRES, FL2->FL2_LICENC})
	Endif
	FL2->(DbSkip())
EndDo

For nX := 1 to Len(aProcessa)

	DbSelectArea("SM0")
	If SM0->(DbSeek(aProcessa[nX,1]))

		_cEmpresa	:= SM0->M0_CODIGO
		_cFilial	:= SM0->M0_CODFIL
		Conout(STR0039+ _cEmpresa + STR0040 + _cFilial)	//Empresa - Filial
		RPCClearEnv()
		RpcSetType(3)
		RPCSetEnv(_cEmpresa,_cFilial,,,"FIN")

		//--------------------------------------------
		// Processa a Exportacao dos Centros de Custo
		//--------------------------------------------
		Fina655Job()

		//------------------------------------
		// Processa a Exportacao dos Usuarios
		//------------------------------------
		Fina657()

		//------------------------------------
		// Processa a Exportacao dos Clientes
		//------------------------------------
		Fina659Job()

		//------------------------------------------------
		// Processa a Exportacao dos Historicos de Pedido
		//------------------------------------------------
		FN661RHist()

	Endif
	
Next nX
RPCClearEnv()

Return

/* ===============================================================================
WSDL Location    http://homolog.totvs.reserve.com.br/ReserveXml300/Autenticacao.asmx?WSDL
Gerado em        12/06/13 10:55:59
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

/* -------------------------------------------------------------------------------
WSDL Service WSAutenticacao
------------------------------------------------------------------------------- */

WSCLIENT WSAutenticacao

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD Autenticar
	WSMETHOD Sair
	WSMETHOD Versao

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   oWSAutenticarRQ           AS Autenticacao_AutenticarRQ
	WSDATA   oWSAutenticarResult       AS Autenticacao_AutenticarRS
	WSDATA   oWSSairRQ                 AS Autenticacao_SairRQ
	WSDATA   oWSSairResult             AS Autenticacao_SairRS
	WSDATA   cVersaoResult             AS string

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSAutenticacao
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.121227P-20130625] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSAutenticacao
	::oWSAutenticarRQ    := Autenticacao_AUTENTICARRQ():New()
	::oWSAutenticarResult := Autenticacao_AUTENTICARRS():New()
	::oWSSairRQ          := Autenticacao_SAIRRQ():New()
	::oWSSairResult      := Autenticacao_SAIRRS():New()
Return

WSMETHOD RESET WSCLIENT WSAutenticacao
	::oWSAutenticarRQ    := NIL 
	::oWSAutenticarResult := NIL 
	::oWSSairRQ          := NIL 
	::oWSSairResult      := NIL 
	::cVersaoResult      := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSAutenticacao
Local oClone := WSAutenticacao():New()
	oClone:_URL          := ::_URL
	oClone:oWSAutenticarRQ :=  IIF(::oWSAutenticarRQ = NIL , NIL ,::oWSAutenticarRQ:Clone() )
	oClone:oWSAutenticarResult :=  IIF(::oWSAutenticarResult = NIL , NIL ,::oWSAutenticarResult:Clone() )
	oClone:oWSSairRQ     :=  IIF(::oWSSairRQ = NIL , NIL ,::oWSSairRQ:Clone() )
	oClone:oWSSairResult :=  IIF(::oWSSairResult = NIL , NIL ,::oWSSairResult:Clone() )
	oClone:cVersaoResult := ::cVersaoResult
Return oClone

// WSDL Method Autenticar of Service WSAutenticacao

WSMETHOD Autenticar WSSEND oWSAutenticarRQ WSRECEIVE oWSAutenticarResult WSCLIENT WSAutenticacao
Local cSoap	:= "" , oXmlRet
Local cUrlAmb	:= SuperGetMv("MV_RESAMB",,"")

cUrlAmb += "/ReserveXml300/Autenticacao.asmx"

BEGIN WSMETHOD

::_URL := cUrlAmb

cSoap += '<Autenticar xmlns="http://www.reserve.com.br/ReserveXML300/">'
cSoap += WSSoapValue("AutenticarRQ", ::oWSAutenticarRQ, oWSAutenticarRQ , "AutenticarRQ", .F. , .F., 0 , NIL, .F.) 
cSoap += "</Autenticar>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.reserve.com.br/ReserveXML300/Autenticar",; 
	"DOCUMENT","http://www.reserve.com.br/ReserveXML300/",,,; 
	cUrlAmb)

::Init()
::oWSAutenticarResult:SoapRecv( WSAdvValue( oXmlRet,"_AUTENTICARRESPONSE:_AUTENTICARRESULT","AutenticarRS",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method Sair of Service WSAutenticacao

WSMETHOD Sair WSSEND oWSSairRQ WSRECEIVE oWSSairResult WSCLIENT WSAutenticacao
Local cSoap	:= "" , oXmlRet
Local cUrlAmb	:= SuperGetMv("MV_RESAMB",,"")

cUrlAmb += "/ReserveXml300/Autenticacao.asmx"

BEGIN WSMETHOD

cSoap += '<Sair xmlns="http://www.reserve.com.br/ReserveXML300/">'
cSoap += WSSoapValue("SairRQ", ::oWSSairRQ, oWSSairRQ , "SairRQ", .F. , .F., 0 , NIL, .F.) 
cSoap += "</Sair>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.reserve.com.br/ReserveXML300/Sair",; 
	"DOCUMENT","http://www.reserve.com.br/ReserveXML300/",,,; 
	cUrlAmb)

::Init()
::oWSSairResult:SoapRecv( WSAdvValue( oXmlRet,"_SAIRRESPONSE:_SAIRRESULT","SairRS",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method Versao of Service WSAutenticacao

WSMETHOD Versao WSSEND NULLPARAM WSRECEIVE cVersaoResult WSCLIENT WSAutenticacao
Local cSoap := "" , oXmlRet
Local cUrlAmb	:= SuperGetMv("MV_RESAMB",,"")

cUrlAmb += "/ReserveXml300/Autenticacao.asmx"


BEGIN WSMETHOD

cSoap += '<Versao xmlns="http://www.reserve.com.br/ReserveXML300/">'
cSoap += "</Versao>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.reserve.com.br/ReserveXML300/Versao",; 
	"DOCUMENT","http://www.reserve.com.br/ReserveXML300/",,,; 
	cUrlAmb)

::Init()
::cVersaoResult      :=  WSAdvValue( oXmlRet,"_VERSAORESPONSE:_VERSAORESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure AutenticarRQ

WSSTRUCT Autenticacao_AutenticarRQ
	WSDATA   cUsuario                  AS string OPTIONAL
	WSDATA   cSenha                    AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Autenticacao_AutenticarRQ
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Autenticacao_AutenticarRQ
Return

WSMETHOD CLONE WSCLIENT Autenticacao_AutenticarRQ
	Local oClone := Autenticacao_AutenticarRQ():NEW()
	oClone:cUsuario             := ::cUsuario
	oClone:cSenha               := ::cSenha
Return oClone

WSMETHOD SOAPSEND WSCLIENT Autenticacao_AutenticarRQ
	Local cSoap := ""
	cSoap += WSSoapValue("Usuario", ::cUsuario, ::cUsuario , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("Senha", ::cSenha, ::cSenha , "string", .F. , .F., 0 , NIL, .F.) 
Return cSoap

// WSDL Data Structure AutenticarRS

WSSTRUCT Autenticacao_AutenticarRS
	WSDATA   cSessao                   AS string OPTIONAL
	WSDATA   oWSErros                  AS Autenticacao_ArrayOfErro OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Autenticacao_AutenticarRS
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Autenticacao_AutenticarRS
Return

WSMETHOD CLONE WSCLIENT Autenticacao_AutenticarRS
	Local oClone := Autenticacao_AutenticarRS():NEW()
	oClone:cSessao              := ::cSessao
	oClone:oWSErros             := IIF(::oWSErros = NIL , NIL , ::oWSErros:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Autenticacao_AutenticarRS
	Local oNode2
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cSessao            :=  WSAdvValue( oResponse,"_SESSAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	oNode2 :=  WSAdvValue( oResponse,"_ERROS","ArrayOfErro",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode2 != NIL
		::oWSErros := Autenticacao_ArrayOfErro():New()
		::oWSErros:SoapRecv(oNode2)
	EndIf
Return

// WSDL Data Structure SairRQ

WSSTRUCT Autenticacao_SairRQ
	WSDATA   cSessao                   AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Autenticacao_SairRQ
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Autenticacao_SairRQ
Return

WSMETHOD CLONE WSCLIENT Autenticacao_SairRQ
	Local oClone := Autenticacao_SairRQ():NEW()
	oClone:cSessao              := ::cSessao
Return oClone

WSMETHOD SOAPSEND WSCLIENT Autenticacao_SairRQ
	Local cSoap := ""
	cSoap += WSSoapValue("Sessao", ::cSessao, ::cSessao , "string", .F. , .F., 0 , NIL, .F.) 
Return cSoap

// WSDL Data Structure SairRS

WSSTRUCT Autenticacao_SairRS
	WSDATA   cSessao                   AS string OPTIONAL
	WSDATA   oWSErros                  AS Autenticacao_ArrayOfErro OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Autenticacao_SairRS
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Autenticacao_SairRS
Return

WSMETHOD CLONE WSCLIENT Autenticacao_SairRS
	Local oClone := Autenticacao_SairRS():NEW()
	oClone:cSessao              := ::cSessao
	oClone:oWSErros             := IIF(::oWSErros = NIL , NIL , ::oWSErros:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Autenticacao_SairRS
	Local oNode2
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cSessao            :=  WSAdvValue( oResponse,"_SESSAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	oNode2 :=  WSAdvValue( oResponse,"_ERROS","ArrayOfErro",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode2 != NIL
		::oWSErros := Autenticacao_ArrayOfErro():New()
		::oWSErros:SoapRecv(oNode2)
	EndIf
Return

// WSDL Data Structure ArrayOfErro

WSSTRUCT Autenticacao_ArrayOfErro
	WSDATA   oWSErro                   AS Autenticacao_Erro OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Autenticacao_ArrayOfErro
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Autenticacao_ArrayOfErro
	::oWSErro              := {} // Array Of  Autenticacao_ERRO():New()
Return

WSMETHOD CLONE WSCLIENT Autenticacao_ArrayOfErro
	Local oClone := Autenticacao_ArrayOfErro():NEW()
	oClone:oWSErro := NIL
	If ::oWSErro <> NIL 
		oClone:oWSErro := {}
		aEval( ::oWSErro , { |x| aadd( oClone:oWSErro , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Autenticacao_ArrayOfErro
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_ERRO","Erro",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSErro , Autenticacao_Erro():New() )
			::oWSErro[len(::oWSErro)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure Erro

WSSTRUCT Autenticacao_Erro
	WSDATA   cCodErro                  AS string OPTIONAL
	WSDATA   cMensagem                 AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Autenticacao_Erro
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Autenticacao_Erro
Return

WSMETHOD CLONE WSCLIENT Autenticacao_Erro
	Local oClone := Autenticacao_Erro():NEW()
	oClone:cCodErro             := ::cCodErro
	oClone:cMensagem            := ::cMensagem
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Autenticacao_Erro
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cCodErro           :=  WSAdvValue( oResponse,"_CODERRO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cMensagem          :=  WSAdvValue( oResponse,"_MENSAGEM","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return
        


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DatIntRes ºAutor  ³Microsiga           º Data ³  09/11/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Dados de Integração com o Reserver                          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function DatIntRes()
Local nPos		  := 0
Local aRet      := {}									// Conteudo de retorno da ParamBox
Local aPerg     := {}									// Array de parametros a serem passados para a ParamBox
Local cDescPar2 := STR0042 // Nivel de Cargo			//"Gerar rev. para taxa existente?"
Local cPictPar  := "@!"									// Mascara de edicao do parametro
Local cWhenPar  := ""									// Validacao anterior do parametro
Local cTitulo   := STR0043//"Dados Complementares Integração Reserve"	// Titulo da tela de parametros(### "Importar  - CSV")
Local aOpc		  := {}
Local aOpcAd	  := {}
Local aOpcVig	  := {}
Local aArea	  := GetArea() 
Local aRetPerg := {}                               

aOpc	 := &('{"'	+ StrTran(Posicione("SX3", 2, "RD0_DVIAGE", "X3CBox()" ),';','","') + '"}') 
aOpcAd  :=	&('{"' + StrTran(Posicione("SX3", 2, "RD0_PERMAD", "X3CBox()" ),';','","') + '"}') 
aOpcVig :=	&('{"' + StrTran(Posicione("SX3", 2, "RD0_DVIAGE", "X3CBox()" ),';','","') + '"}')
 //{"1=Nao Viaja","2=Curtas(-3 Meses)","3=Longas(+3 Meses)","4=Mercado Internacional"}
if Empty(RD0->RD0_NVLCAR) .or. Empty(RD0_DVIAGE)
	
	If IsInCallStack('Apda020Rd0Upd') //Apda020Mnt
		RecLock("RD0",.F.)
		RD0->RD0_DVIAGE := CriaVar("RD0_DVIAGE",.T.)
		RD0->RD0_NVLCAR := CriaVar("RD0_NVLCAR",.T.)
		RD0->RD0_LOGINR := CriaVar("RD0_LOGINR",.T.)
		RD0->RD0_PERMAD := CriaVar("RD0_PERMAD",.T.)
		RD0->RD0_APSUBS := CriaVar("RD0_APSUBS",.T.)
		RD0->RD0_APROPC := CriaVar("RD0_APROPC",.T.)
		RD0->RD0_FORNEC := CriaVar("RD0_FORNEC",.T.)
		RD0->RD0_LOJA   := CriaVar("RD0_LOJA"	,.T.)  	
		RD0->RD0_EMPATU := CriaVar("RD0_EMPATU",.T.)
		RD0->RD0_FILATU := CriaVar("RD0_FILATU",.T.)
		RD0->RD0_LOGINR := CriaVar("RD0_LOGINR",.T.)
		RD0->RD0_FORNEC := CriaVar("RD0_FORNEC",.T.)
		RD0->RD0_LOJA   := CriaVar("RD0_LOJA"	,.T.)
		RD0->RD0_APROPC := CriaVar("RD0_USRPRE",.T.)
		RD0->(MsUnlock())
	Else
		
		//Ponto de entrada para preencher X3_RELACAO do Parambox, retorna array.
		If ExistBlock("FNXRESPAR")
			aRetPerg := ExecBlock("FNXRESPAR",.F.,.F.)
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Array a ser passado para ParamBox quando tipo(6) ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		//
		nPos := aScan(aRetPerg,{|x| x[1] = 'RD0_DVIAGE'} )
		If nPos > 0
			aAdd( aPerg,{2,"Disp. Viagem", aRetPerg[nPos][2], aOpcVig, 60, 'Pertence(" 1234")', .F.}) 
		Else
			aAdd( aPerg,{2,"Disp. Viagem", CriaVar("RD0_DVIAGE",.T.), aOpcVig, 60, 'Pertence(" 1234")', .F.}) 
		EndIf
		//
		nPos := aScan(aRetPerg,{|x| x[1] = 'RD0_NVLCAR'} )
		If nPos > 0
			aAdd( aPerg,{1,cDescPar2,aRetPerg[nPos][2],cPictPar,"ExistCpo('FL3')","FL3",cWhenPar,TamSx3("RD0_NVLCAR")[1],.F.})
		Else
			aAdd( aPerg,{1,cDescPar2,CriaVar("RD0_NVLCAR", .T.),cPictPar,"ExistCpo('FL3')","FL3",cWhenPar,TamSx3("RD0_NVLCAR")[1],.F.})
		EndIf
		nPos := aScan(aRetPerg,{|x| x[1] = 'RD0_LOGINR'} )
		If nPos > 0
			aAdd( aPerg,{1,"Login Reserve", aRetPerg[nPos][2] ,/*Picture*/,/*Valid*/,/**/,/**/,TamSx3("RD0_LOGINR")[1],.F.}) 	
		Else
			aAdd( aPerg,{1,"Login Reserve", CriaVar("RD0_LOGINR",.T.),/*Picture*/,/*Valid*/,/**/,/**/,TamSx3("RD0_LOGINR")[1],.F.}) 
		EndIf
		//
		nPos := aScan(aRetPerg,{|x| x[1] = 'RD0_PERMAD'} )
		If nPos > 0
			aAdd( aPerg,{2,"Permite Adto.", aRetPerg[nPos][2], aOpcAd, 60, 'Pertence("12")', .F.}) 
		Else
			aAdd( aPerg,{2,"Permite Adto.", CriaVar("RD0_PERMAD",.T.), aOpcAd, 60, 'Pertence("12")', .F.}) 
		EndIf
		//
		nPos := aScan(aRetPerg,{|x| x[1] = 'RD0_APROPC'} )
		If nPos > 0
			aAdd( aPerg,{1,"Aprovador",aRetPerg[nPos][2],cPictPar,;
													"Vazio() .Or. (Existcpo('RD0') .And. (RD0->RD0_APROPC <> RD0->RD0_CODIGO .OR. GetMV('MV_RESAPRT') == '1'))","RD0",;
													/**/,TamSx3("RD0_APROPC")[1],.F.})
		Else
			aAdd( aPerg,{1,"Aprovador",CriaVar("RD0_APROPC",.T.),cPictPar,;
													"Vazio() .Or. (Existcpo('RD0') .And. (RD0->RD0_APROPC <> RD0->RD0_CODIGO .OR. GetMV('MV_RESAPRT') == '1'))","RD0",;
													/**/,TamSx3("RD0_APROPC")[1],.F.})
		EndIf
		//
		nPos := aScan(aRetPerg,{|x| x[1] = 'RD0_APSUBS'} )
		If nPos > 0
			aAdd( aPerg,{1,"Substituto",aRetPerg[nPos][2],cPictPar,;
													"Vazio() .Or. (Existcpo('RD0') .And. (RD0->RD0_APSUBS <> RD0->RD0_CODIGO .OR. GetMV('MV_RESAPRT') == '1'))","RD0",;
													/**/,TamSx3("RD0_APSUBS")[1],.F.})										
		Else
			aAdd( aPerg,{1,"Substituto",CriaVar("RD0_APSUBS",.T.),cPictPar,;
													"Vazio() .Or. (Existcpo('RD0') .And. (RD0->RD0_APSUBS <> RD0->RD0_CODIGO .OR. GetMV('MV_RESAPRT') == '1'))","RD0",;
													/**/,TamSx3("RD0_APSUBS")[1],.F.})										
		EndIf
		//
		nPos := aScan(aRetPerg,{|x| x[1] = 'RD0_FORNEC'} )
		If nPos > 0
			aAdd( aPerg,{1,"Fornecedor",aRetPerg[nPos][2],cPictPar,;
													"FINXVLDFNV(1)","SA2",;
													/**/,TamSx3("RD0_FORNEC")[1],.F.})										
		Else
			aAdd( aPerg,{1,"Fornecedor",CriaVar("RD0_FORNEC",.T.),cPictPar,;
													"FINXVLDFNV(1)","SA2",;
													/**/,TamSx3("RD0_FORNEC")[1],.F.})											
		EndIf
		//
		nPos := aScan(aRetPerg,{|x| x[1] = 'RD0_LOJA'} )
		If nPos > 0
			aAdd( aPerg,{1,"Loja",aRetPerg[nPos][2],cPictPar,;
												"FINXVLDFNV(2)",/**/,;
												/**/,TamSx3("RD0_LOJA")[1],.F.})		
		Else
			aAdd( aPerg,{1,"Loja",CriaVar("RD0_LOJA"	,.T.),cPictPar,;
												"FINXVLDFNV(2)",/**/,;
												/**/,TamSx3("RD0_LOJA")[1],.F.})						
		EndIf
		//
		nPos := aScan(aRetPerg,{|x| x[1] = 'RD0_USRPRE'} )
		If nPos > 0
			aAdd( aPerg,{1,"Sub.Pre.Cta",aRetPerg[nPos][2],cPictPar,;
												"Vazio() .Or. Existcpo('RD0')",/**/,;
												/**/,TamSx3("RD0_USRPRE")[1],.F.})		
		Else
			aAdd( aPerg,{1,"Sub.Pre.Cta",CriaVar("RD0_USRPRE",.T.),cPictPar,;
												"Vazio() .Or. Existcpo('RD0')",/**/,;
												/**/,TamSx3("RD0_USRPRE")[1],.F.})
		EndIf												                                                                             													
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Caso confirme a tela de parametros atualiza os dados de integracao ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
		If !IsBlind()//NÃ£o apresentar tela de pergunte quando via rest
			If ParamBox(aPerg,cTitulo,@aRet)
				RecLock("RD0",.F.)
				RD0->RD0_DVIAGE 	:= aRet[1]
				RD0->RD0_NVLCAR 	:= aRet[2]
				RD0->RD0_LOGINR 	:= AllTrim(aRet[3])
				RD0->RD0_PERMAD 	:= aRet[4]
				RD0->RD0_APROPC 	:= aRet[5]
				RD0->RD0_APSUBS 	:= aRet[6]
				RD0->RD0_EMPATU 	:= Criavar("RD0_EMPATU",.T.)
				RD0->RD0_FILATU 	:= Criavar("RD0_FILATU",.T.)
				RD0->RD0_FORNEC 	:= aRet[7]
				RD0->RD0_LOJA	:= aRet[8]
				RD0->RD0_USRPRE 	:= aRet[9]
				RD0->(MsUnlock())
			EndIf
		Endif
	EndIf
	
Endif  

RestArea(aArea)

Return


//-------------------------------------------------------------------------------
/*/{Protheus.doc} FINXUser
Função genérica para obter matricula e nome do usuário no cadastro
de recursos (RD0)

@param cUserId		Código do usuário logado no sistema
@param aUser		Array que conterá: [1] Matricula   [2] Nome do recurso.
@param lHelp		Apresenta Help ou não
@return lRet		Retorna se existe cadastro de participante para o usuário
@author Totvs
@since 02/09/2013
@version MP11 R9
/*/
//-------------------------------------------------------------------------------
Function FINXUser(cUserId,aUser,lHelp) 

	Local aArea			:= GetArea()
	Local cQuery 		:= ""
	Local cTab			:= "RD0SRV"
	Local lRet			:= .T.
	Local lRD0_VIAJA	:= RD0->(FieldPos("RD0_FVIAJ")) > 0

	DEFAULT lHelp := .F.
	DEFAULT aUser := {}

	cQuery   := " SELECT "
	cQuery   += " RD0_CODIGO, RD0_NOME, RD0_MSBLQL, RD0_DTADEM "
	cQuery   += " FROM " + RetSQLTab("RD0")
	cQuery   += " WHERE "
	cQuery   += " RD0_FILIAL = '"+ xFilial("RD0") +"' AND "
	cQuery   += " RD0_USER = '"  + cUserId        +"' AND "
	cQuery   += " RD0_MSBLQL <> '1' AND "
	If lRD0_VIAJA
		cQuery   += " RD0_FVIAJ IN ('1', '') AND "
	EndIf
	cQuery   += " D_E_L_E_T_ = ' ' "
	cQuery   := ChangeQuery(cQuery)

	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cTab, .T., .T.)

	If (cTab)->(!EOF())
		If !Empty((cTab)->RD0_DTADEM)
			Help("  ",1,"USERBLQ",,STR0044,1,0)	//"Usuário consta como demitido no cadastro de Pessoas/Participantes. Verifique."  
			lRet := .F.
		Else
			aUser := {RD0_CODIGO,RD0_NOME}
		Endif

	Else
		Help("  ",1,"NOUSERADT",,STR0045 +CRLF+ STR0046 ,1,0)	
		lRet := .F.
	EndIf

	(cTab)->(dbCloseArea())

	RestArea(aArea)

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} ProxTitulo
Gera numeracao sequencial dos titulos a serem gerados no financeiro
quando da aprovação de pagamento

@author pequim

@since 23/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function ProxTitulo(cAlias,cPrefixo)
 		
Local cQuery	:= ""
Local cTmp   	:= GetNextAlias()
Local aArea 	:= GetArea()
Local cAux		:= ""
Local nTamNum	:= TamSx3("E2_NUM")[1]
Local cRet		:= STRZERO(0,nTamNum)

Default cAlias := "SE2" 
cAux := Right(cAlias,2)      
cRet := Criavar(cAux+"_NUM",.T.)

cQuery := "Select Max("+cAux+"_NUM) NUM"
cQuery += " FROM " + RetSqlName( cAlias ) 
cQuery += " WHERE "+cAux+"_FILIAL='" + xFilial( cAlias ) + "'"
cQuery += " AND "+cAux+"_PREFIXO ='" + cPrefixo +"'"
cquery += " AND D_E_L_E_T_ = ' ' "
cQuery := ChangeQuery(cQuery)                         

dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cTmp, .F., .T. )
if !(Empty((cTmp)->NUM))
	cRet := (cTmp)->NUM
endif
cRet := Soma1(cRet,nTamNum)      

while !MayIUseCode( cAlias+xFilial(cALias)+cPrefixo+cRet)  //verifica se esta na memoria, sendo usado
	cRet := Soma1(cRet)      
enddo

(cTmp)->( dbCloseArea() ) 

RestArea( aArea ) 
                
Return cRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FINATURES ºAutor  ³TOTVS			        º Data ³  01/11/13º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Atualiza Status do adiantamento de viagem                   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ7ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ FINA080/FINA090/FINA091/FINA340/FINA450/					   º±± 
±± 				FINXATU/FINA070/FINA110/FINA330						    	±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FINATURES(cChave As Char, lBaixa As Logical, cOrigem As Char, cRecPag As Char, cFilOriFLD As Char)
	
	Local lOutraMoed As Logical
	Local cMensagem  As Char
	Local cValor     As Char
	Local aAreaAtual As Array	

	//Inicializa variáveis
	lOutraMoed := .T.
	cMensagem  := ""
	cValor     := ""
	aAreaAtual := GetArea()	
	
	Default cChave  	:= ""
	Default lBaixa  	:= .T. //.T. - Baixa, .F. - cancela a baixa     
	Default cOrigem 	:= ""     
	Default cRecPag 	:= ""
	Default cFilOriFLD	:= cFilAnt

	If __lEncViag == Nil 
	    __lEncViag := FindFunction("F677EncVia")
	EndIf
	
	If ALLTRIM(cOrigem) == "FINA667"
		DbSelectArea("FLD")
		FLD->(DbSetOrder(6))//FLD_FILIAL+FLD_PREFIX+FLD_TITULO+FLD_PARCEL+FLD_TIPO+FLD_FORNEC+FLD_LOJA
		
		If FLD->(DbSeek(xFilial("FLD", cFilOriFLD)+cChave))
			FLD->(RecLock("FLD", .F.))
			If lBaixa
				FLD->FLD_DTPAGT := dDatabase
				FLD->FLD_STATUS := "4"
			Else	
				FLD->FLD_STATUS := "3"
				FLD->FLD_DTPAGT := CtoD("")
			Endif
			FLD->(MSUNLOCK())
		Endif	
	Else
		//Atualiza o título da prestação de contas.
		DbSelectArea("FO7")
		FO7->(DbSetOrder(3))
		
		If FO7->(DbSeek(xFilial("FO7") + cRecPag + cChave))
			RecLock("FO7",.F.)
			
			If lBaixa   
				FO7->FO7_DTBAIX := dDatabase
			Else  
				FO7->FO7_DTBAIX := CtoD("") 
			EndIf
			
			FO7->(MsUnlock())  	
		EndIf
		
		DbSelectArea("FLF")
		FLF->(DbSetOrder(1)) //FILIAL + TIPO + PRESTA
		
		If FLF->(DbSeek(xFilial("FLF") + FO7->FO7_TPVIAG + FO7->FO7_PRESTA))
			lOutraMoed := (FLF->FLF_TVLRE2 - (FLF->FLF_TADIA2 + FLF->FLF_TDESC2)) <> 0 .Or. (FLF->FLF_TVLRE3 - (FLF->FLF_TADIA3 + FLF->FLF_TDESC3)) <> 0
		
			If !lOutraMoed .Or. (lOutraMoed .And. FLF->FLF_STATMX == "1") //Se não tem outras moedas ou se tem e está finalizada 
				RecLock("FLF",.F.)
				If lBaixa   
					FLF->FLF_STATUS := "8"
					FLF->FLF_DTFECH := dDataBase
				Else  
					FLF->FLF_STATUS := "7"
					FLF->FLF_DTFECH := CToD("  /  /    ")	       	
				Endif 
				FLF->(MsUnlock()) 
			EndIf
			
			If __lEncViag .And. FLF->FLF_TIPO == "1" .And. ( FLF->FLF_STATUS $ "7/8" )
				F677EncVia(FLF->FLF_VIAGEM, FLF->FLF_STATUS)
			EndIf		
			
			If lBaixa
				cValor    := Transform(FLF->FLF_TVLRE1, PesqPict("FLF", "FLF_TVLRE1"))
				cMensagem := STR0066 + CRLF								//'Realizado o acerto financeiro da prestação.'
				cMensagem += STR0067 + FO7->FO7_PRESTA + CRLF 			//'Número da prestação: '
				cMensagem += STR0068 + FO7->FO7_TITULO + CRLF 			//'Número do título: '
				cMensagem += STR0069 + Dtoc( dDatabase ) + CRLF 		//'Título baixado em: '
				cMensagem += STR0070 + Alltrim( cValor ) + CRLF 		//'Valor do título: ' 
				
				//Notifica o usuário pelo aplicativo Meu Protheus
				F677PushNotification( 101, NIL, STR0071 + " - " + STR0072, cMensagem )	//'Prestação de Contas'###'Baixa do título a pagar'
			EndIf

		EndIf
	EndIf
	
	RestArea(aAreaAtual)
	FwFreeArray(aAreaAtual)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FINVERRES ºAutor  ³TOTVS			        º Data ³  01/11/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica Status do adiantamento de viagem                   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ FINA080/FINA340/FINA450/FINA070/FINA330			           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FINVERRES(cChave, cOrigem,cRecPag)

Local lRetorno := .T.    
Local aAreaSE2:=SE2->(GetArea())
Local aAreaSE1:=SE1->(GetArea())

Default cChave	  := ""       
Default cOrigem	  := ""
Default cRecPag	  := ""

If ALLTRIM(cOrigem)== "FINA667"
	DbSelectArea("FLD")
	DbSetOrder (6) //FLD_FILIAL+FLD_PREFIX+FLD_TITULO+FLD_PARCEL+FLD_TIPO+FLD_FORNEC+FLD_LOJA
	If dbSeek(xFilial("FLD")+cChave)
		lRetorno := !(FLD_STATUS=="5") //Impede o cancelamento
	Endif  
Else	    

	DbSelectArea("FLF")
	DbSetOrder (3) //FLF_FILIAL+FLF_RECPAG+FLF_PREFIX+FLF_TITULO+FLF_PARCEL+FLF_TIPTIT+FLF_CLIFOR+FLF_FLOJA
	If dbSeek(xFilial("FLF")+cRecPag+cChave)
		lRetorno := !(FLF->FLF_STATUS=="9") //Impede o cancelamento
	Endif      
Endif

RestArea(aAreaSE2)
RestArea(aAreaSE1)
	
Return (lRetorno)

//-------------------------------------------------------------------------------
/*/{Protheus.doc} FINXVALPC
Função para validação de pendencias de prestação de contas do Participante.
Avalia Prestação em atraso e excesso de prestação em aberto

@param cUserId		Código do participante
@param lHelp		Apresenta Help ou não
@return lRet		Retorna .F. se participante possuir pendencia de prestação de contas
@author Totvs
@since 29/10/2013
@version MP11 R9
/*/
//-------------------------------------------------------------------------------
Function FINXVALPC(cPartic,lHelp)
Local aArea		 := Nil
Local cAliasTrb	 := ""
Local lRet 		 := .T.
Local nQtdDias	 := SuperGetmv("MV_RESPCAT",,1)
Local nQtdPresta := SuperGetmv("MV_RESQTPC",,1)
Local nY		 := 0
Local nTotal     := 0 
Local lBlqADTO   := SuperGetMV("MV_FBQADTO",.T.,"2") == "1"	
Local cQuery     := ""
Local nRecnoAnt  := 0
Local dDataPrazo := CToD("  /  /    ")

Default cPartic	:= ""

If !Empty(cPartic)		
	aArea := GetArea()
	
	//Cria tabela com Participantes e seus Pedido
	cQuery := " SELECT FLF_PARTIC, RD0_NOME, FLF_PRESTA, FLF_DTFIM " 
	cQuery += " FROM " + RetSqlName("FLF") + " FLF "
	cQuery += " INNER JOIN " + RetSqlName("FLD") + " FLD "
	cQuery += " ON FLD.FLD_FILIAL = FLF.FLF_FILIAL "	
	cQuery += "	AND FLD.FLD_VIAGEM = FLF.FLF_VIAGEM "
	cQuery += " AND FLD.FLD_PARTIC = FLF.FLF_PARTIC "	
	
	If lBlqADTO
		cQuery += " AND FLD.FLD_STATUS <> '1' "
	EndIf		
	
	cQuery += " AND FLD.D_E_L_E_T_ = ' ' "		
	cQuery += " INNER JOIN " + RetSqlName("RD0") + " RD0 "
	cQuery += "	ON RD0.RD0_CODIGO = FLF.FLF_PARTIC "
	cQuery += "	AND  RD0.D_E_L_E_T_ = ' ' "		
	cQuery += "	WHERE FLF_FILIAL = '"+ xFilial("FLF") + "' "
	cQuery += "	AND  FLF_PARTIC = '" + cPartic + "' "
	cQuery += "	AND FLF_STATUS IN ('1','2','3') "
	cQuery += "	AND  FLF.D_E_L_E_T_ = ' ' "			   			
	cQuery += " GROUP BY FLF_PARTIC, RD0_NOME, FLF_PRESTA, FLF_DTFIM "	   			
	cQuery += " ORDER BY FLF_DTFIM "		
	cQuery := ChangeQuery(cQuery)
	cAliasTrb := MpSysOpenQuery(cQuery)
	
	If (cAliasTrb)->(!Eof())
		dDataPrazo := StoD((cAliasTrb)->FLF_DTFIM)
		
		For nY := 1 to nQtdDias
			dDataPrazo := DataValida(dDataPrazo + 1)
			
			If dDataPrazo >= dDataBase
				Exit
			EndIf  			
		Next nY
		
		If dDataPrazo < dDataBase
			lRet := .F.
			If lHelp
				Help(" ",1,"FIXVALDTPC",,STR0012+ AllTrim( (cAliasTrb)->RD0_NOME ) +STR0013+CRLF +; //'O participante '//", possui pendências na prestação de contas. "
						STR0014+ (cAliasTrb)->FLF_PRESTA +CRLF +; //"Prestação pendênte:"
						STR0015+ DTOC(STOD((cAliasTrb)->FLF_DTFIM)),1,0) //"Data Chegada: "		
			EndIf
		EndIf	

		nRecnoAnt := (cAliasTrb)->(Recno())
		nTotal    := Contar(cAliasTrb, "!EOF()")		
		
		(cAliasTrb)->(dbGotop())
		(cAliasTrb)->(dbGoto(nRecnoAnt))
		
		If lRet .And. lBlqADTO .And. nTotal >= nQtdPresta
			lRet := .F.
			If lHelp
				Help(" ",1,"FIXVALQTPC",,STR0012+ AllTrim( (cAliasTrb)->RD0_NOME ) +STR0016,1,0)	//'O participante '//", excedeu a quantidade de prestações de contas pendente. "				
			EndIf
		EndIf
	EndIf
	
	(cAliasTrb)-> (DbCloseArea())
	RestArea(aArea)
EndIf
Return lRet


//-------------------------------------------------------------------------------
/*/{Protheus.doc} FINXVLDFNV
Função para validação de pendencias de prestação de contas do Participante.
Avalia Prestação em atraso e excesso de prestação em aberto

@param cUserId		Código do participante
@param lHelp		Apresenta Help ou não
@return lRet		Retorna .F. se participante possuir pendencia de prestação de contas
@author Totvs
@since 29/10/2013
@version MP11 R9
/*/
//-------------------------------------------------------------------------------

Function FINXVLDFNV(nCpo)
 
Local lValid 	 := .T.

DEFAULT nCpo := 0

If MV_PAR04 = "1" //Permite Adiantamento
	Do Case
		Case Empty(MV_PAR07) .Or. Empty(MV_PAR08) 
			lValid := .F.
			MsgAlert ("Para participantes com adiantamento, é necessário informar o Fornecedor e Loja.")
		Case nCpo = 1 .And. !ExistCpo("SA2",MV_PAR07)
			MsgAlert ("O fornecedor informado não existe, Favor informar um código válido.")
		Case nCpo = 2 .And. !ExistCpo("SA2",MV_PAR07+MV_PAR08,1) //nCpo = 2 - Loja
			lValid := .F.
			MsgAlert ("A loja do fornecedor informado não existe. Favor informar um código válido.")
	EndCase
EndIf

Return lValid

/*/{Protheus.doc} FNXRESCANC
Função de processamento dos pedidos que foram cancelados no Reserve.
@param cViagem - Código da viagem que o pedido está sendo cancelado.
@param cPedido - Código do pedido.
@author William Matos
@since 22/08/2014
@version 12
/*/
Function FNXRESCANC(oModel,nIdPedido)
Local cLogCanc	:= ""
Local nY			:= 1
Local aArea		:=	GetArea()
Local lRet 		:= oModel:GetOperation() == 4 //Caso seja outra operação o pedido não foi encontrado.
Local lPedidos	:= .T.	
Local oFL6			:= oModel:GetModel('FL6DETAIL')
Default nIdPedido	:= 0

If lRet

	//Cancela a prestação de contas se todas estiverem como em abertas.
	If FResCancPC(oModel,nIdPedido,@cLogCanc)	 
		FResBuscaAdt(oModel,nIdPedido,@cLogCanc)	//Busca por adiantamentos da viagem que o pedido será cancelado. 
	
		//Atualiza pedido para cancelado.
		oModel:SetValue('FL6DETAIL','FL6_STATUS','3')
		
		//Atualiza o status da viagem para cancelado.
		While nY <= oFL6:Length() .AND. lPedidos 
			lPedidos := oFL6:GetValue('FL6_STATUS', nY) == '3' //Pedido Cancelado.
			nY ++
		EndDo		
		If lPedidos
			oModel:SetValue('FL5MASTER','FL5_STATUS','4') //Cancelada.			
		EndIf
			
	EndIf
	
	If oModel:VldData()
		oModel:CommitData()
	Else
		For nY := 1 To Len(oModel:GetErrorMessage())
			cLogCanc += cValToChar(oModel:GetErrorMessage()[nY]) + CRLF
		Next nY
	EndIf

EndIf	
RestArea(aArea)
Return cLogCanc

/*/{Protheus.doc} FResCancPC
Cancelamento da prestação de contas.
@param oModel - Modelo de dados do FINA665
@param nIdPedido - Código do pedido que será cancelado.
@author William Matos
@since 22/08/2014
@version 12
/*/
Function FResCancPC(oModel, nIdPedido, cLog)
Local aArea			:= GetArea()
Local lPC 				:= .T.
Local nX					:= 0
Local nY					:= 0
Local oFLU				:= oModel:GetModel('FLUDETAIL')
Local oFL6				:= oModel:GetModel('FL6DETAIL')
Local oModelPC	:= FWLoadModel("FINA677") 
Local cViagem		:= oModel:GetValue('FL5MASTER','FL5_VIAGEM')
	
//Posiciona na tabela de prestação de contas para saber a situação do pedido,
//pedido não poderá ser cancelado com prestação de contas iniciadas.
dbSelectArea("FLF")
dbSetOrder(2) //FLF_FILIAL+FLF_VIAGEM+FLF_PARTIC                                                                                        
If FLF->(dbSeek( xFilial("FLF") + cViagem ))
	
	While !FLF->(Eof()) .AND. lPC .AND. xFilial('FLF') + FLF->FLF_VIAGEM  == (xFilial('FLF') + cViagem)	
		lPC := FLF->FLF_STATUS $ '1|8' //Prestação de contas em aberto.
		FLF->(dbSkip())
	EndDo

EndIf

If lPC 

	//Posiciona no pedido.	
	oFL6:SeekLine({{"FL6_IDRESE",cValToChar(nIdPedido)}})
	//Procura se o participante faz parte de outro pedido para cancelar a prestação de contas.
	For nX := 1 To oFLU:Length()
		
		If !FResBPartc(oFLU:GetValue("FLU_PARTIC", nX), oFL6, oFLU)	
		
			FLF->(dbSetOrder(2))
			FLF->(dbSeek( xFilial("FLF") + cViagem + oFLU:GetValue("FLU_PARTIC", nX))) 
			oModelPC:SetOperation(MODEL_OPERATION_UPDATE)
			oModelPC:Activate()
			oModelPC:SetValue('FLFMASTER','FLF_STATUS', '8') //Finalizada.
			oModelPC:SetValue('FLFMASTER','FLF_MOTIVO',STR0049 + cValToChar(nIdPedido) + STR0050)
			If oModelPC:VldData()
				oModelPC:CommitData()
				oModelPC:DeActivate()
			Else
				For nY := 1 To Len(oModel:GetErrorMessage())
					cLog += cValToChar(oModel:GetErrorMessage()[nY]) + CRLF
				Next nY
			EndIf
			
		EndIf
		
	Next nX
Else
	cLog = STR0051 + cViagem + STR0052	
EndIf
RestArea(aArea)

Return lPC

/*/{Protheus.doc} FResBPartc
Pesquisa pelo participante em outro pedido da mesma viagem.
@param cPartic - código do participante.
@param nLinFL6 - Linha posicionada da FL6.
@param oFL6 - Objeto com os dados do pedido da viagem.
@param oFLU - 
@author William Matos
@since 22/08/2014
@version 12
/*/
Function FResBPartc(cPartic,oFL6, oFLU)
Local lRet := .F.
Local nX	  := 0
Local nZ	  := 1
Local nLinFL6 := oFL6:GetLine()

For nX := 1 To oFL6:Length()
	If nX <> nLinFL6 .AND. oFL6:GetValue('FL6_STATUS', nX) <> '3' .AND. !lRet 	
		oFL6:SetLine(nX)	
		While !lRet .AND. nZ <= oFLU:Length()
			lRet := oFLU:GetValue('FLU_PARTIC', nZ) == cPartic
			nZ ++
		EndDo
	EndIf		 
Next nX

oFL6:SetLine(nLinFL6)
Return lRet

/*/{Protheus.doc} FResBuscaAdt
Busca por adiantamentos da viagem que pedido será cancelado.
@param oModel - Dados da viagem.
@param nIdPedido - Id do Pedido no Reserve.
@param cLog - Variavel para gravar log da rotina. 
@author William Matos
@since 22/08/2014
@version 12
/*/
Function FResBuscaAdt(oModel, nIdPedido, cLog)	
Local oFLC, oFLD, oFL6, oFLU
Local nX	   := 0 			
Default oModel := FWModelActive()
	
oFLC := oModel:GetModel("FLCDETAIL")
oFLD := oModel:GetModel("FLDDETAIL")
oFL6 := oModel:GetModel("FL6DETAIL")
oFLU := oModel:GetModel("FLUDETAIL")

	//Posiciona no pedido.	
	oFL6:SeekLine({{"FL6_IDRESE",cValToChar(nIdPedido)}})
	nLinha := oFL6:GetLine()
	
	//Procura adiantamento do participante do pedido.
	For nX := 1 To oFLU:Length()
			 
	 //FLC - Passageiro x Adiantamento. 			
		oFLC:SeekLine({{"FLC_PARTIC",oFLU:GetValue("FLU_PARTIC", nX)}})
		If !oFLD:IsEmpty() //Participante possui adiantamento.
			//Retorna se o participante faz parte de outro pedido, se faz o adiantamento ainda não precisa ser cancelado.
			If !FResBPartc(oFLU:GetValue("FLU_PARTIC", nX), oFL6, oFLU)		
					//Não faz parte de outro pedido, verifica status do adiantamento para ser cancelado.
					FResCancAdt(oFLD, @cLog)						
			EndIf
		EndIf
						
	Next nX
oFL6:SetLine(nLinha)
Return 

/*/{Protheus.doc} FResCancAdt
Cancelamento do adiantamento.
@param oFLD - Objeto com informações sobre adiantamento dos participantes.
@param cLog - Variavel para gravar log da rotina.
@author William Matos
@since 22/08/2014
@version 12
/*/
Function FResCancAdt(oFLD, cLog)
Local aArea		:= GetArea()
Local cLoja		:= ''
Local cCliente 	:= ''
Local cTipo		:= SuperGetMV("MV_RESTPAD",.T.,"DP ")
Local cAuxCli		:= SuperGetMV("MV_RESCLIP",," ")
Local nDiasUteis 	:= SuperGetMV("MV_RESADDU",.T.,3)
Local cNaturez   	:= SuperGetMV("MV_RESNTCR",.T.,"")
Local cPrefixo	:= SuperGetMV("MV_RESPRFP",.T.,Padr(" ",TamSx3("E1_PREFIXO")[1]))
Local aAuxCli		:= {}
Local cNumTit		:= ''
Local nX	  		:= 0
Local nZ			:= 0
Local aTitulo		:= {}
Local dDataVenc	:= dDataBase
Local oModelAdt	:= FWLoadModel('FINA667')
Local aAuxSEV  	:= {}
Local aAuxSEZ  	:= {}
Local aRatSEZ  	:= {}
Local aRatSEVEZ	:= {}
Local aCC		   := {}
Local aLog			:= {}

lMsErroAuto := .F.
dbSelectArea('FLD')
dbSelectArea("SE2")

For nX := 1 To oFLD:Length()

		Do Case
			
			Case oFLD:GetValue('FLD_STATUS', nX) == '3' //Liberado Pagamento.
			
				//Exclui o título do contas a pagar por rotina automatica.	
				SE2->(dbSetOrder(1))
				If SE2->(dbSeek( xFilial("SE2")    + oFLD:GetValue('FLD_PREFIX', nX) + oFLD:GetValue('FLD_TITULO', nX) + ;
				 		oFLD:GetValue('FLD_PARCEL', nX) + oFLD:GetValue('FLD_TIPO'  , nX) + oFLD:GetValue('FLD_FORNEC', nX) + ;
				 		oFLD:GetValue('FLD_LOJA'  , nX)))
				 
					aTitulo := {}
		
					AADD(aTitulo , {"E2_NUM"    , oFLD:GetValue('FLD_TITULO', nX) ,NIL })
					AADD(aTitulo , {"E2_PREFIXO", oFLD:GetValue('FLD_PREFIX', nX) ,NIL })
					AADD(aTitulo , {"E2_PARCELA", oFLD:GetValue('FLD_PARCEL', nX) ,NIL })
					AADD(aTitulo , {"E2_TIPO"   , oFLD:GetValue('FLD_TIPO'  , nX) ,NIL })
					AADD(aTitulo , {"E2_FORNECE", oFLD:GetValue('FLD_FORNEC', nX) ,NIL })
					AADD(aTitulo , {"E2_LOJA"   , oFLD:GetValue('FLD_LOJA'  , nX) ,NIL })
				
					MSExecAuto({|x,y,z| FINA050(x,y,z)}, aTitulo, 5, 5)
						
					If lMsErroAuto
						aLog := GetAutoGrLog()
					EndIf
				EndIf	

			Case oFLD:GetValue('FLD_STATUS', nX) == '4' //Pago.
			
				//Gera um título a receber.
				nValor := oFLD:GetValue('FLD_VALAPR',nX)
				cNumTit	:= ProxTitulo("SE1",cPrefixo)
				aAuxCli := StrToKArr(cAuxCli,"|")
				cCliente := AllTrim(aAuxCli[1])
				If Len(aAuxCli) > 1
					cLoja := AllTrim(aAuxCli[2])
				Else
					cLoja := Space(nTamLoja)
				EndIf
				aTitulo := {}
			
				aAdd(aTitulo , {"E1_NUM"    ,PadR(cNumTit,TamSx3("E1_NUM")[1])   ,NIL})
				aAdd(aTitulo , {"E1_PREFIXO",cPrefixo								  ,NIL})
				aAdd(aTitulo , {"E1_PARCELA",Space(TamSx3("E1_PARCELA")[1])      ,NIL})
				aAdd(aTitulo , {"E1_TIPO"   ,PadR(cTipo,TamSx3("E1_TIPO")[1])    ,NIL})
				aAdd(aTitulo , {"E1_NATUREZ",PadR(cNaturez,TamSx3("E1_NATUREZ")[1]),NIL})
				aAdd(aTitulo , {"E1_CLIENTE",cCliente                			    ,NIL})
				aAdd(aTitulo , {"E1_LOJA"   ,cLoja                   			    ,NIL})
				aAdd(aTitulo , {"E1_EMISSAO",dDatabase               			    ,NIL})
				aAdd(aTitulo , {"E1_VENCTO" ,DataValida(dDataVenc + nDiasUteis)    ,NIL})
				aAdd(aTitulo , {"E1_VENCREA",DataValida(dDataVenc + nDiasUteis)    ,NIL})			
				aAdd(aTitulo , {"E1_EMIS1"  ,dDatabase               			    ,NIL})
				aAdd(aTitulo , {"E1_MOEDA"  ,1                       			    ,NIL})               
				aAdd(aTitulo , {"E1_VALOR"  ,nValor 								    ,NIL})			
				aAdd(aTitulo , {"E1_ORIGEM" ,"FINA665"            	  			    ,NIL})
				aAdd(aTitulo , {"E1_HIST"	,STR0053 + oFLD:GetValue('FLD_VIAGEM', nX) + STR0054 + oFLD:GetValue('FLD_PARTIC', nX)	,NIL})
					
				aCC := F677CalcCC(oFLD:GetValue('FLD_VIAGEM',nX), nValor)				

				If Len(aCC) > 0
					aAdd( aAuxSEV ,{"EV_NATUREZ" , PadR(cNaturez,TamSx3("E1_NATUREZ")[1]),NIL})
			   aAdd( aAuxSEV ,{"EV_VALOR"   , nValor ,NIL })//valor do rateio na natureza
			   aAdd( aAuxSEV ,{"EV_PERC"    , "100"  ,NIL })//percentual do rateio na natureza
			   aAdd( aAuxSEV ,{"EV_RATEICC" , "1"	  ,NIL })//indicando que há rateio por centro de custo
				   
			   For nZ := 1 To Len(aCC)
				   
				   aAdd( aAuxSEZ ,{"EZ_CCUSTO" ,aCC[nZ][1] ,NIL})//centro de custo da natureza
				   aAdd( aAuxSEZ ,{"EZ_VALOR"  ,aCC[nZ][2] ,NIL})//valor do rateio neste centro de custo
				   aAdd( aAuxSEZ ,{"EZ_PERC"   ,aCC[nZ][3] ,NIl})
				   aAdd( aRatSEZ,aClone(aAuxSEZ))
				   aSize(aAuxSEZ,0)
				   aAuxSEZ := {}
					Next nZ
						
					aAdd(aAuxSEV,{"AUTRATEICC" , aRatSEZ ,NIL})//recebendo dentro do array da natureza os multiplos centros de custo
					aAdd(aRatSEVEZ,aAuxSEV)//adicionando a natureza ao rateio de multiplas naturezas
					//
					aAdd(aTitulo ,{"E1_MULTNAT", "1"	,NIL}) 	
				EndIf

				MSExecAuto({|x,y,z,a| FINA040(x,y,z,a)}, aTitulo, 3,/**/,aRatSEVEZ)
				If lMsErroAuto
					aLog := GetAutoGrLog()
				EndIf
				aSize(aCC, 0)
				aSize(aAuxSEZ,0)
				aSize(aRatSEVEZ,0)
				aSize(aRatSEZ,0)
				aCC := {}
				aAuxSEZ   := {}
				aRatSEZ   := {}
				aRatSEVEZ := {}
			
			OtherWise
										
		EndCase
		
		If !lMsErroAuto //Não deu erro na rotina automatica.
		
			FLD->(dbSetOrder(1))
			If FLD->(dbSeek( xFilial('FLD') + oFLD:GetValue('FLD_VIAGEM', nX) + oFLD:GetValue('FLD_PARTIC', nX) + oFLD:GetValue('FLD_ADIANT', nX)))
			
				oModelAdt:SetOperation(MODEL_OPERATION_UPDATE)
				oModelAdt:Activate()
				oModelAdt:SetValue('FLDMASTER','FLD_STATUS', '9') //Cancelado.
				oModelAdt:SetValue('FLDMASTER','FLD_JUSTIF',STR0006 + STR0050)
				If oModelAdt:VldData()
					oModelAdt:CommitData()
					oModelAdt:DeActivate()
				Else
					For nZ := 1 To Len(oModel:GetErrorMessage())
						cLog += cValToChar(oModel:GetErrorMessage()[nY]) + CRLF
					Next nZ
				EndIf
				
			EndIf
			
		EndIf

Next nX

RestArea(aArea)
Return cLog

//-------------------------------------------------------------------
/*/{Protheus.doc}  FXRESNUM
Gera numeracao sequencial da Numeração de Viagens

@author Antonio Domingos

@since 17/04/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function FXRESNUM(cNacion)
Local cQuery	  		:= ""
Local cTmp   	  		:= GetNextAlias()
Local aArea 	  		:= GetArea()
Local nTamNum	  		:= TamSx3("FL5_VIAGEM")[1]
Local cRet		  		:= STRZERO(0,nTamNum)
Local cMV_RESNUM		:= ""
Default cNacion		:= "1" //Sim

If SuperGetMV("MV_RESNUM",,"") > 0
	cMV_RESNUM := Str(SuperGetMV("MV_RESNUM",,""),1) //Verifique se o parâmetro MV_RESNUM esta preenchido
EndIF
	
If !Empty(cMV_RESNUM)
	
	If cNacion == "2" //viagem internacional - busca no banco de dados na tabela FL5 por viagens que o primeiro digito seja o valor do MV_RESNUM, ordene por código da viagem
	
		cQuery := " SELECT MAX(FL5_VIAGEM) VIAGEM"
		cQuery += " FROM " + RetSqlName( "FL5" ) 
		cQuery += " WHERE FL5_FILIAL = '" + xFilial( "FL5" ) + "'"
		cQuery += " AND SUBSTRING(FL5_VIAGEM,1,1) = '" + cMV_RESNUM +"'"
		cQuery += " AND D_E_L_E_T_ = ' ' "
		cQuery := ChangeQuery(cQuery)                         
		//
		cRet   := cMV_RESNUM + STRZERO(0,nTamNum-1)
	
	Else //busca no banco de dados na tabela FL5 por viagens onde o primeiro dígito seja menor do que MV_RESNUM.
	
		cQuery := " SELECT MAX(FL5_VIAGEM) VIAGEM"
		cQuery += " FROM " + RetSqlName( "FL5" ) 
		cQuery += " WHERE FL5_FILIAL = '" + xFilial( "FL5" ) + "'"
		cQuery += " AND SUBSTRING(FL5_VIAGEM,1,1) < '" + cMV_RESNUM +"'"
		cQuery += " AND D_E_L_E_T_ = ' ' "
		cQuery := ChangeQuery(cQuery)                         
	
	EndIf	

	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cTmp, .F., .T. )
	//
	If !(Empty((cTmp)->VIAGEM))
		cRet := (cTmp)->VIAGEM
	Endif
	cRet := Soma1(cRet,nTamNum)      
	
	(cTmp)->( dbCloseArea() ) 
		
	RestArea( aArea ) 

Else
	cRet := GetSxeNum("FL5","FL5_VIAGEM")                                                                                                   
EndIf                

Return cRet


//-------------------------------------------------------------------
/*/{Protheus.doc}FResAprov

Retorna as configurações de aprovação de acordo com a classificação passada por parametro ou realiza validações

@author julio.teixeira
@since 29/06/2015
@version 1.0
@param cClass - Classificação a ser consultada
		"1" - Adiantamentos
		"2" - Prestação de Contas
		"3" - Solicitações de Viagens
		"4" - Validações para liberação do financeiro
@return 	aRet - Array com as configurações de aprovação encontradas (.T. or .F.)
/*/
//-------------------------------------------------------------------
Function FResAprov(cClass)

Local aRet 	:= {}
Local aArea 	:= GetArea()
Local aAreaFW0 := FW0->(GetArea())
Local aAreaRD0 := RD0->(GetArea())
Local nY 		:= Iif(cClass != "3",3,2)
Local nX 		:= 1
Local lRet 	:= .T.
Local cNaturez	:= SuperGetMV("MV_RESNTAD",.T.,"")
Local nTamNat		:= TamSx3("E2_NATUREZ")[1]

If cClass == "4"//Validação
	
	RD0->(dbSetOrder(1))	//Filial + Codigo
	If RD0->(MsSeek( xFilial("RD0") + FLD->FLD_PARTIC ))
		If Empty(RD0->RD0_FORNEC) .or. Empty(RD0->RD0_LOJA)
			Help("  ",1,"NO_FORNEC",,STR0060,1,0)	//"Participante não possui cadastro de fornecedor relacionado ao mesmo para geração de adiantamento."
			lRet := .F.
		Endif
	Endif
	//Valida a natureza do titulo a ser gerado
	If lRet
		If !Empty(cNaturez)
			lRet := FinVldNat( .F., PadR(cNaturez,nTamNat), 0 , 2 )
		Else
			Help("  ",1,"NO_NATUREZ",,STR0061,1,0)	//"Para efetivação da liberação é necessário parametrizar a natureza do titulo a ser gerado."###"Verifique o parâmetro < MV_RESNTAD >."
			lRet := .F.
		Endif
	Endif
	aAdd(aRet,lRet)
	
Else
	DbSelectArea("FW0")
	FW0->(DbSetOrder(Val(cClass)))
	For nX := 1 to nY 
		If FW0->(DbSeek(xFilial("FW0")+cClass+cValtoChar(nX)))
			aAdd(aRet,.T.)
		Else
			aAdd(aRet,.F.)
		Endif
	Next nX
Endif

RestArea(aAreaRD0)
RestArea(aAreaFW0)
RestArea(aArea)

Return aClone(aRet)

//-------------------------------------------------------------------
/*/
{Protheus.doc} FXNMoedas
Tratamento para validação de titulos em outras moedas, gerados por 
adiantamento de viagens ou prestação de contas e que não tenham 
cotação (E2_TXMOEDA) cadastrada.     

@author pequim

@param	Tipo de retorno ((obrigatório):	“1” = Lógico ou  “2” = Expressão para filtro
@param	Variável lógica (lQuery) informando se a expressão retornada deve ter padrão SQL ou Codebase (opcional, tendo efeito apenas para processo com tipo de retorno 2 (Expressão para filtro))
@param	Variável lógica (lHelp) informando se deve ser apresentado mensagem ao usuário (opcional, tendo efeito apenas para processo com tipo de retorno 1 (lógico))
 
@since 01/07/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function FXNMoedas(cTipo,lQuery,lHelp)

Local uRet := ""

DEFAULT cTipo 		:= "1"
DEFAULT	lQuery		:= .F.
DEFAULT	lHelp		:= .T.

If cTipo == "1"	//Retorno Lógico - validação unitária
	uRet := .T.
	//Verifico se o titulo: 
	// - foi gerado por adiantamento de viagens ou prestação de contas
	// - é em moeda estrangeira
	// - possui cotação cadastrada
	If (Alltrim(SE2->E2_ORIGEM) $ "FINA667|FINA677") .and. SE2->E2_MOEDA > 1 .and. SE2->E2_TXMOEDA == 0
		If lHelp
			Help( " ", 1, "FXNMOEDAS",,STR0058+CRLF+STR0059,1,0) //"Este título em moeda estrangeira foi originado de um adiantamento de viagens ou uma prestação de contas mas não possui cotação cadastrada para o mesmo. "###"Cadastre a cotação para este título alterando o mesmo ou utilizando a rotina Cotação em lote.", 1, 0 ) 
			uRet := .F.
		Endif
	Endif

ElseIf cTipo == "2"		//Retorna expressão de filtro					
	If lQuery
		uRet := " AND ((E2_ORIGEM IN ('FINA667','FINA677') AND ((E2_MOEDA > 1 AND E2_TXMOEDA <> 0) OR (E2_MOEDA = 1) ))" 
		uRet += " OR (E2_ORIGEM NOT IN ('FINA667','FINA677'))) "
	Else		
		uRet := ".AND. ( (Alltrim(E2_ORIGEM) $ 'FINA667|FINA677' .and. ((E2_MOEDA > 1 .and. E2_TXMOEDA <> 0) .OR. (E2_MOEDA = 1)))"
		uRet += " .OR. (!(Alltrim(E2_ORIGEM) $ 'FINA667|FINA677')))"
	Endif
Endif

Return uRet

//-----------------------------------------------------------------
/*/{Protheus.doc} FW4IsType6
Retorna se o tipo do servico da viagem eh 6 (Outros),
	considerando todos os itens de servico contidos.
A FW3 DEVE estar posicionada (solicitacao da viagem).

@author Igor Nascimento
@since 04/01/2021
@version 12.1.27
/*/
//-----------------------------------------------------------------
Function FW4IsType6() As Logical

	Local aArea		As Array
	Local aAreaFW4	As Array
	Local lRet		As Logical
	Local nLenFW4	As Numeric
	Local nTipo6	As Numeric

	aArea 	  := GetArea()
	aAreaFW4  := FW4->(GetArea())
	lRet	  := .F.
	nLenFW4   := 0
	nTipo6	  := 0

	dbSelectArea("FW4")
	FW4->(dbSetOrder(1))
	FW4->(dbSeek( FW3->(FW3_FILIAL+FW3_SOLICI) ))
	While FW4->(FW4_FILIAL+FW4_SOLICI) == FW3->(FW3_FILIAL+FW3_SOLICI)
		nLenFW4++
		If FW4->FW4_TIPO == "6"
			nTipo6++
		Else
			Exit
		EndIf
		FW4->(dbSkip())
	EndDo

	If nLenFW4 == nTipo6
		lRet := .T.
	EndIf

	RestArea(aAreaFW4)
	RestArea(aArea)

Return lRet 
