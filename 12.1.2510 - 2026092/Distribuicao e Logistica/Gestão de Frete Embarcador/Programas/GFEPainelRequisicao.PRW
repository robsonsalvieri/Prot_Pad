#INCLUDE 'PROTHEUS.CH'

Function GFEPainelRequisicao()
Return Nil
//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc}GFEPainelRequisicao()

@author
@since 10/4/2018
@version 1.0
/*/
//---------------------------------------------------------------------------------------------------
CLASS GFEPainelRequisicao FROM LongNameClass 

   DATA cIdReq
   DATA cUsuNegoc
   DATA cSitReq
   DATA lStatus
   DATA cMensagem
   DATA cCdTrp
   DATA cNrTab
   DATA cNrNeg	
   DATA lSel
   DATA cJustifSel
   DATA cResulSeq
   DATA cFilTabelaFrete
   DATA cFilReferencia
   DATA cFilContrato
   DATA cNrContrato
   DATA cNrReferencia
   DATA nTypeMail
   DATA cAviso
   DATA nFrtPes
   DATA nTpPrazo
   DATA nPrazo
   DATA nReqDtIni
   DATA nReqDtFim
   DATA nReqAct

   METHOD New() CONSTRUCTOR
   METHOD ClearData()
   METHOD Destroy(oObject)

   METHOD ValidarAssociarRequisicao()
   METHOD ValidarDesassociarRequisicao()
   METHOD ValidarConcluirRequisicao()
   METHOD ValidarAlterarDados()
   METHOD ValidarResultado()
   METHOD AlterarSituacao()
   METHOD AlterarAviso()
   METHOD SendMail()
   METHOD SendMailConclusion()
   METHOD SendMailAccept()
   METHOD SendMailReject()  
   METHOD SendMailCancel() 

   METHOD setIdReq(cIdReq)
   METHOD setUsuNegoc(cUsuNegoc)
   METHOD setSitReq(cSitReq)
   METHOD setStatus(lStatus)
   METHOD setMensagem(cMensagem)
   METHOD setCdTrp(cCdTrp)
   METHOD setNrTab(cNrTab)
   METHOD setNrNeg(cNrNeg)
   METHOD setSel(lSel)
   METHOD setJustifSel(cJustifSel)
   METHOD setResulSeq(cResulSeq)
   METHOD setFilTabelaFrete(cFilTabelaFrete)
   METHOD setFilReferencia(cFilReferencia)
   METHOD setFilContrato(cFilContrato)
   METHOD setNrContrato(cNrContrato)
   METHOD setNrReferencia(cNrReferencia)
   METHOD setTypeMail(nTypeMail)
   METHOD setAviso(cAviso)
   METHOD setFrtPes(nFrtPes)
   METHOD setTpPrazo(nTpPrazo)
   METHOD setPrazo(nPrazo)
   METHOD setReqDtIni(nReqDtIni)
   METHOD setReqDtFim(nReqDtFim)
   METHOD setReqAct(nReqAct)

   METHOD getIdReq()
   METHOD getUsuNegoc()
   METHOD getSitReq()
   METHOD getStatus()
   METHOD getMensagem()
   METHOD getCdTrp()
   METHOD getNrTab()
   METHOD getNrNeg()
   METHOD getSel()
   METHOD getJustifSel()
   METHOD getResulSeq()
   METHOD getFilTabelaFrete()
   METHOD getFilReferencia()
   METHOD getFilContrato()
   METHOD getNrContrato()
   METHOD getNrReferencia()
   METHOD getTypeMail()
   METHOD getAviso()
   METHOD getFrtPes()
   METHOD getTpPrazo()
   METHOD getPrazo()
   METHOD getReqDtIni()
   METHOD getReqDtFim()
   METHOD getReqAct()
ENDCLASS

METHOD New() Class GFEPainelRequisicao
   Self:ClearData()
Return

METHOD Destroy(oObject) CLASS GFEPainelRequisicao
   FreeObj(oObject)
Return

METHOD ClearData() Class GFEPainelRequisicao
	Self:setIdReq("")
	Self:setUsuNegoc("")
	Self:setStatus(.F.)
	Self:setMensagem("")
	Self:setFrtPes(0)
Return

//-----------------------------------
// Métodos de Negócio
//-----------------------------------
METHOD ValidarAssociarRequisicao() Class GFEPainelRequisicao
	If (!Empty(Self:getIdReq()))
		GXR->(dbSetOrder(1))
		If GXR->(dbSeek(xFilial("GXR") + Self:getIdReq()))
			If GXR->GXR_SIT == "3" .And. (AllTrim(GXR->(GXR_USUNEG)) == Self:getUsuNegoc())
				Self:setStatus(.F.)
				Self:setMensagem("Esta requisição já está em Negociação com o seu usuário.")
				Return
			EndIf
			
			If !Empty(GXR->GXR_USUNEG) .And. (AllTrim(GXR->(GXR_USUNEG)) <> Self:getUsuNegoc())
				Self:setStatus(.F.)
				Self:setMensagem("Esta requisição já está em Negociação com outro usuário.")
				Return
			EndIf
			
			If GXR->(GXR_SIT <> "2")
				Self:setStatus(.F.)
				Self:setMensagem("A requisição não está na situação Requisitada. Apenas requisições nesta situação podem ser associadas.")
				Return
			EndIf
			
			Self:setStatus(.T.)
			Self:setMensagem("")
		EndIf
	EndIf	
Return

METHOD ValidarDesassociarRequisicao() Class GFEPainelRequisicao
	If (!Empty(Self:getIdReq()))
		GXR->(dbSetOrder(1))
		If GXR->(dbSeek(xFilial("GXR") + Self:getIdReq()))
			If !Empty(GXR->GXR_USUNEG) .And. (AllTrim(GXR->(GXR_USUNEG)) <> Self:getUsuNegoc())
				Self:setStatus(.F.)
				Self:setMensagem("Esta requisição não está vinculada ao seu usuário.")
				Return
			EndIf
			
			If GXR->(GXR_SIT <> "3")
				Self:setStatus(.F.)
				Self:setMensagem("A requisição não está na situação Em negociação. Apenas requisições nesta situação podem ser desassociadas.")
				Return
			EndIf
			
			Self:setStatus(.T.)
			Self:setMensagem("")
		EndIf
	EndIf	
Return

METHOD ValidarConcluirRequisicao() Class GFEPainelRequisicao
	Local nCount := 0
	If (!Empty(Self:getIdReq()))
		GXR->(dbSetOrder(1))
		If GXR->(dbSeek(xFilial("GXR") + Self:getIdReq()))
			If !Empty(GXR->GXR_USUNEG) .And. (AllTrim(GXR->(GXR_USUNEG)) <> Self:getUsuNegoc())
				Self:setStatus(.F.)
				Self:setMensagem("Esta requisição não está vinculada ao seu usuário.")
				Return
			EndIf
			If GXR->(GXR_SIT <> "3")
				Self:setStatus(.F.)
				Self:setMensagem("A requisição não está na situação Em negociação. Apenas requisições nesta situação podem ser desassociadas.")
				Return
			EndIf
		EndIf
		GXS->(dbSetOrder())
		If GXS->(dbSeek(xFilial("GXS") + Self:getIdReq()))
			While !GXS->(Eof()) .And. GXS->GXS_IDREQ == Self:getIdReq()  
				If GXS->GXS_MRKBR
					nCount += 1
				EndIf 
				GXS->(dbSkip())
			EndDo
		Else
			Self:setStatus(.F.)				
			Self:setMensagem("Não existe nenhuma cotação para esta requisição. É necessário selecionar uma cotação para poder concluir a requisição.")
			Return
		EndIf
		If nCount == 0
			Self:setStatus(.F.)				
			Self:setMensagem("É necessário selecionar uma cotação para poder concluir a requisição.")
			Return
		EndIf
		Self:setStatus(.T.)
		Self:setMensagem("")
	EndIf	
Return

METHOD ValidarAlterarDados() Class GFEPainelRequisicao
	If Self:getSitReq() <> '3'
		Self:setStatus(.F.)
		Self:setMensagem("A requisição não está na situação Em negociação. Apenas requisições nesta situação podem ser alteradas.")
		Return
	EndIf
	
	If Self:getUsuNegoc() <> AllTrim(GXR->GXR_USUNEG)
		Self:setStatus(.F.)
		Self:setMensagem("A requisição não está assumida pelo seu usuário. Apenas requisições assumidas pelo seu usuário podem ser alteradas.")
		Return
	EndIf
	
	Self:setStatus(.T.)
	Self:setMensagem("")
Return

METHOD ValidarResultado() Class GFEPainelRequisicao
	Local cFilBkp := cFilAnt
	Local aDtFRet
	
	cFilAnt := Self:getFilTabelaFrete()
	
	If(!Empty(Self:getNrTab()))
		If !GFEExistC("GVA", , Self:getCdTrp()+Self:getNrTab(),)
			Self:setStatus(.F.)
			Self:setMensagem("A tabela de frete informada para o resultado " + Self:getResulSeq() + " não é válida. Favor informar uma tabela válida.")
			Return
		EndIf
	EndIf
	
	If(!Empty(Self:getNrNeg()))
		If !GFEExistC("GV9", , Self:getCdTrp()+Self:getNrTab()+Self:getNrNeg(),"GV9->GV9_SIT=='2'")
			Self:setStatus(.F.)
			Self:setMensagem("A negociação de frete informada para o resultado " + Self:getResulSeq() + " não é válida. Favor informar uma negociação válida.")
			Return
		EndIf
	EndIf
	
	cFilAnt := Self:getFilContrato()
	
	If(!Empty(Self:getNrContrato()))
		If !GFEExistC("GXT", , Self:getNrContrato(),"GXT->GXT_CDTRP=='" + Self:getCdTrp() + "'")
			Self:setStatus(.F.)
			Self:setMensagem("O contrato de frete informado para o resultado " + Self:getResulSeq() + " não é válido. Favor informar um contrato válido.")
			Return
		EndIf
	EndIf
	
	cFilAnt := Self:getFilReferencia()
	
	If(!Empty(Self:getNrReferencia()))
		If !GFEExistC("GUN", , Self:getNrReferencia(),"GUN->GUN_TPTAB=='4' .AND. GUN->GUN_CDTRP=='" + Self:getCdTrp() + "'")
			Self:setStatus(.F.)
			Self:setMensagem("O registro de frete referência informado para o resultado " + Self:getResulSeq() + " não é válido. Favor informar um registro de frete referência válido.")
			Return
		EndIf
	EndIf
	
	cFilAnt := cFilBkp
	
	If(Self:getSel() == .T. .And. Self:getFrtPes() <= 0)
		Self:setStatus(.F.)
		Self:setMensagem("O resultado " + Self:getResulSeq() + " está selecionado, porém o campo Frete Peso Negociado está zerado. Favor informar um valor para a seleção do resultado.")
		Return
	EndIf
	
	If Self:getSel() == .T. .And. !Empty(Self:getReqDtIni()) .And. !Empty(Self:getReqDtFim())
		aDtFRet := GerarDtFret(Self:getReqDtFim(),Self:getPrazo(),Self:getTpPrazo())
		
		If aDtFRet[1] == .T.
			If Self:getReqDtIni() > aDtFRet[2]
				Self:setStatus(.F.)
				Self:setMensagem("Em pelo menos uma das cotações selecionadas, o prazo informado de entrega é incompatível com a duração do contrato. Informe um prazo menor para a cotação ou aumente o tempo de duração requisitado!")
				Return
			EndIf
		Else
			Self:setStatus(.F.)
			Self:setMensagem("Não foi possível calcular a data para verificar se o prazo das cotações é compatível com o tempo de duração requisitado. Verificar se o calendário de transporte foi gerado.")
			Return
		EndIf
	EndIf
	
	Self:setStatus(.T.)
	Self:setMensagem("")
Return

METHOD AlterarSituacao() Class GFEPainelRequisicao
	If (!Empty(Self:getIdReq()))
		GXR->(dbSetOrder(1))
		If GXR->(dbSeek(xFilial("GXR") + Self:getIdReq()))
			RecLock("GXR", .F.)
				GXR->GXR_SIT    := Self:getSitReq()
				GXR->GXR_USUNEG := Self:getUsuNegoc()
				GXR->GXR_AVISO  := Self:getAviso()
			GXR->(MsUnlock())
		EndIf
	EndIf
Return

METHOD AlterarAviso() Class GFEPainelRequisicao
	If (!Empty(Self:getIdReq()))
		GXR->(dbSetOrder(1))
		If GXR->(dbSeek(xFilial("GXR") + Self:getIdReq()))
			RecLock("GXR", .F.)
				GXR->GXR_AVISO  := Self:getAviso()
			GXR->(MsUnlock())
		EndIf
	EndIf
Return

METHOD SendMailConclusion() Class GFEPainelRequisicao
	Self:setTypeMail(1)
	Self:setStatus(.T.)
	Self:setMensagem("")
	Self:SendMail()
Return

METHOD SendMailAccept() Class GFEPainelRequisicao
	Self:setTypeMail(2)
	Self:setStatus(.T.)
	Self:setMensagem("")
	Self:SendMail()
Return

METHOD SendMailReject() Class GFEPainelRequisicao
	Self:setTypeMail(3)
	Self:setStatus(.T.)
	Self:setMensagem("")
	Self:SendMail()
Return

METHOD SendMailCancel() Class GFEPainelRequisicao
	Self:setTypeMail(4)
	Self:setStatus(.T.)
	Self:setMensagem("")
	Self:SendMail()
Return

METHOD SendMail() Class GFEPainelRequisicao
	Local cMsg1	:= ''
	Local cMsg2 := ''
	Local cTmp	:= ''
	Local leMail := .F.
	Local ceMail := ""
	Local GFEMail	:= GFEEMail():New()
	
	If Self:getTypeMail() == 1
		cMsg1	:= 'concluída'
		cMsg2	:= 'Conclusão'
	elseif Self:getTypeMail() == 2
	 	cMsg2	:= 'Aceite'
	elseif Self:getTypeMail() == 3
		cMsg2	:= 'Recusa'	
	else
		cMsg2	:= 'Cancelamento'		
	EndIf
	
	If (!Empty(Self:getIdReq()))
		GXR->(dbSetOrder(1))
		If GXR->(dbSeek(xFilial("GXR") + Self:getIdReq()))
			if !(Empty(GXR->GXR_EMAIL)) .OR. !(Empty(GXR->GXR_CC))
				leMail := .T.

				ceMail	:= GXR->GXR_EMAIL
				if Empty(ceMail)
					ceMail := GXR->GXR_CC
				Else
					If !Empty(GXR->GXR_CC)
						ceMail += ',' + GXR->GXR_CC
					EndIf
				EndIf
				
			EndIf
			
			If Self:getTypeMail() == 2 .Or. Self:getTypeMail() == 3 
				GXR->(dbSetOrder(1))
				If GXR->(dbSeek(xFilial("GXR") + Self:getIdReq()))
					leMail := .T.
					If Empty(ceMail)
						ceMail := USRRETMAIL(GXR->GXR_USUNEG)
					Else
						ceMail += ',' + USRRETMAIL(GXR->GXR_USUNEG)
					EndIf
				EndIf	
			ElseIf Self:getTypeMail() == 4 
				GXR->(dbSetOrder(1))				
				If GXR->(dbSeek(xFilial("GXR") + Self:getIdReq()))
					leMail := .T.	
					If !Empty(USRRETMAIL(GXR->GXR_USUNEG))	
						If Empty(ceMail)				
							ceMail := USRRETMAIL(GXR->GXR_USUNEG)	
						else	
							ceMail += ',' + USRRETMAIL(GXR->GXR_USUNEG)
						EndIf	
					else 
						leMail := .F.			
					EndIf
				EndIf			
			EndIf 
			
			If leMail				
				
				leMail := .F.
					
					If Self:getTypeMail() == 1	
						GFEMail:addTextBody('A Requisição de Negociação de Frete ['+Self:getIdReq()+'] foi '+cMsg1+' com as seguintes cotações:')
						If Self:getReqAct() == "2"
							GFEMail:addTextSummary('O aceite da negociação foi efetuado de forma automática conforme configuração.')
						Else
							GFEMail:addTextSummary('Efetue o aceite ou recusa da negociação por meio do programa de Requisições de Negociação de Frete.')
						EndIf
						GFEMail:addTextTable('COTAÇÕES')
						GFEMail:addHeaderTable(2,'Transportador')
						GFEMail:addHeaderTable(2,'Frete Peso')
						GFEMail:addHeaderTable(2,'Total Frete')
						GFEMail:addHeaderTable(2,'Prazo')
						GFEMail:addHeaderTable(2,'Tabela de Frete')
					  	GFEMail:addHeaderTable(2,'Número Contrato')
		
						GXS->(dbSetOrder(1))
						If GXS->(dbSeek(xFilial("GXS") + Self:getIdReq()))
							while !GXS->(Eof()) .AND. GXS->GXS_IDREQ == Self:getIdReq() 						
								If GXS->GXS_MRKBR
									leMail := .T.
									cTmp := AllTrim(STRToKArr(GetSx3Cache("GXS_TPPRAZ","X3_CBOX"),";")[3])
									cTmp := SubStr(cTmp,3,Len(cTmp))
									
									GFEMail:addColumnTable(1,AllTrim(GXS->GXS_CDTRP) +'-'+ AllTrim(Posicione('GU3', 1, xFilial('GU3') + GXS->GXS_CDTRP, 'GU3->GU3_NMEMIT')))
									GFEMail:addColumnTable(3,AllTrim(TRANSFORM(GXS->GXS_FRTPES, '@E 99,999,999.99')))
									GFEMail:addColumnTable(3,AllTrim(TRANSFORM(GXS->GXS_TOTFRT, '@E 99,999,999.99')))
									GFEMail:addColumnTable(2,cValToChar(GXS->GXS_PRAZO) + '-' + cTmp)
									GFEMail:addColumnTable(1,AllTrim(GXS->GXS_FILTAB) +'/'+ AllTrim(GXS->GXS_NRTAB) +'/'+ AllTrim(GXS->GXS_NRNEG))
									GFEMail:addColumnTable(1,AllTrim(GXS->GXS_FILCT) +'/'+ AllTrim(GXS->GXS_NRCT))
								EndIf
								GXS->(dbSkip())
							EndDo
						EndIf
					EndIf
					If Self:getTypeMail() == 2
						leMail := .T.
						GFEMail:addTextBody('A Requisição de Negociação de Frete ['+Self:getIdReq()+'] será utilizada pelo requisitante.')
					EndIf
					
					If Self:getTypeMail() == 3
						leMail := .T.
						GFEMail:addTextBody('A Requisição de Negociação de Frete ['+Self:getIdReq()+'] não será utilizada pelo requisitante.' + CRLF +'Justificativa: '+GXR->GXR_MOTREJ)
					EndIf
					
					If Self:getTypeMail() == 4 
						leMail := .T.
						GFEMail:addTextBody('A Requisição de Negociação de Frete ['+Self:getIdReq()+'] foi cancelada pelo requisitante.' + CRLF +'Justificativa: '+GXR->GXR_MOTCAN)
					EndIf
	
					If leMail
						GFEMail:setPara(ceMail)
						GFEMail:setAssunto("Requisição de Negociação de Frete ["+Self:getIdReq()+"] - " + cMsg2)
						GFEMail:setBody(GFEMail:getEmail())
						GFEMail:setMsg(.F.)
						GFEMail:sendEmail()
						Self:setStatus(GFEMail:getStatus())
						Self:setMensagem(GFEMail:getMensagem())
					EndIf				
			Else
				Self:setStatus(.F.)
				Self:setMensagem("Envio de Email da Requisição. Para o envio de e-mail é necessário informar e-mail ou e-mail cópia na requisição. Requisição:["+Self:getIdReq()+"]")
			EndIf
		Else
			Self:setStatus(.F.)
			Self:setMensagem("Envio de Email da Requisição. Não é possível realizar o envio de email pois a requisição não foi encontrada. Requisição:["+Self:getIdReq()+"]")
		EndIf
	EndIf
	GFEMail:Destroy(GFEMail)
Return

//-----------------------------------
//Setters
//-----------------------------------
METHOD setIdReq(cIdReq) CLASS GFEPainelRequisicao
   Self:cIdReq := cIdReq
Return

METHOD setUsuNegoc(cUsuNegoc) CLASS GFEPainelRequisicao
   Self:cUsuNegoc := cUsuNegoc
Return

METHOD setSitReq(cSitReq) CLASS GFEPainelRequisicao
   Self:cSitReq := cSitReq
Return

METHOD setStatus(lStatus) CLASS GFEPainelRequisicao
   Self:lStatus := lStatus
Return

METHOD setMensagem(cMensagem) CLASS GFEPainelRequisicao
   Self:cMensagem := cMensagem
Return

METHOD setCdTrp(cCdTrp) CLASS GFEPainelRequisicao
   Self:cCdTrp := cCdTrp
Return

METHOD setNrTab(cNrTab) CLASS GFEPainelRequisicao
   Self:cNrTab := cNrTab
Return

METHOD setNrNeg(cNrNeg) CLASS GFEPainelRequisicao
   Self:cNrNeg := cNrNeg
Return

METHOD setSel(lSel) CLASS GFEPainelRequisicao
   Self:lSel := lSel
Return

METHOD setJustifSel(cJustifSel) CLASS GFEPainelRequisicao
   Self:cJustifSel := cJustifSel
Return

METHOD setResulSeq(cResulSeq) CLASS GFEPainelRequisicao
   Self:cResulSeq := cResulSeq
Return

METHOD setFilTabelaFrete(cFilTabelaFrete) CLASS GFEPainelRequisicao
   Self:cFilTabelaFrete := cFilTabelaFrete
Return

METHOD setFilReferencia(cFilReferencia) CLASS GFEPainelRequisicao
   Self:cFilReferencia := cFilReferencia
Return

METHOD setFilContrato(cFilContrato) CLASS GFEPainelRequisicao
   Self:cFilContrato := cFilContrato
Return

METHOD setNrContrato(cNrContrato) CLASS GFEPainelRequisicao
   Self:cNrContrato := cNrContrato
Return

METHOD setNrReferencia(cNrReferencia) CLASS GFEPainelRequisicao
   Self:cNrReferencia := cNrReferencia
Return

METHOD setTypeMail(nTypeMail) CLASS GFEPainelRequisicao
   Self:nTypeMail := nTypeMail
Return

METHOD setAviso(cAviso) CLASS GFEPainelRequisicao
   Self:cAviso := cAviso
Return

METHOD setFrtPes(nFrtPes) CLASS GFEPainelRequisicao
   Self:nFrtPes := nFrtPes
Return

METHOD setTpPrazo(nTpPrazo) CLASS GFEPainelRequisicao
   Self:nTpPrazo := nTpPrazo
Return

METHOD setPrazo(nPrazo) CLASS GFEPainelRequisicao
   Self:nPrazo := nPrazo
Return

METHOD setReqDtIni(nReqDtIni) CLASS GFEPainelRequisicao
   Self:nReqDtIni := nReqDtIni
Return

METHOD setReqDtFim(nReqDtFim) CLASS GFEPainelRequisicao
   Self:nReqDtFim := nReqDtFim
Return

METHOD setReqAct(nReqAct) CLASS GFEPainelRequisicao
   Self:nReqAct := nReqAct
Return

//-----------------------------------
//Getters
//-----------------------------------
METHOD getIdReq() CLASS GFEPainelRequisicao
Return Self:cIdReq

METHOD getUsuNegoc() CLASS GFEPainelRequisicao
Return Self:cUsuNegoc

METHOD getSitReq() CLASS GFEPainelRequisicao
Return Self:cSitReq

METHOD getStatus() CLASS GFEPainelRequisicao
Return Self:lStatus

METHOD getMensagem() CLASS GFEPainelRequisicao
Return Self:cMensagem

METHOD getCdTrp() CLASS GFEPainelRequisicao
Return Self:cCdTrp

METHOD getNrTab() CLASS GFEPainelRequisicao
Return Self:cNrTab

METHOD getNrNeg() CLASS GFEPainelRequisicao
Return Self:cNrNeg

METHOD getSel() CLASS GFEPainelRequisicao
Return Self:lSel

METHOD getJustifSel() CLASS GFEPainelRequisicao
Return Self:cJustifSel

METHOD getResulSeq() CLASS GFEPainelRequisicao
Return Self:cResulSeq

METHOD getFilTabelaFrete() CLASS GFEPainelRequisicao
Return Self:cFilTabelaFrete

METHOD getFilReferencia() CLASS GFEPainelRequisicao
Return Self:cFilReferencia

METHOD getFilContrato() CLASS GFEPainelRequisicao
Return Self:cFilContrato

METHOD getNrContrato() CLASS GFEPainelRequisicao
Return Self:cNrContrato

METHOD getNrReferencia() CLASS GFEPainelRequisicao
Return Self:cNrReferencia

METHOD getTypeMail() CLASS GFEPainelRequisicao
Return Self:nTypeMail

METHOD getAviso() CLASS GFEPainelRequisicao
Return Self:cAviso

METHOD getFrtPes() CLASS GFEPainelRequisicao
Return Self:nFrtPes

METHOD getTpPrazo() CLASS GFEPainelRequisicao
Return Self:nTpPrazo

METHOD getPrazo() CLASS GFEPainelRequisicao
Return Self:nPrazo

METHOD getReqDtIni() CLASS GFEPainelRequisicao
Return Self:nReqDtIni

METHOD getReqDtFim() CLASS GFEPainelRequisicao
Return Self:nReqDtFim

METHOD getReqAct() CLASS GFEPainelRequisicao
Return Self:nReqAct