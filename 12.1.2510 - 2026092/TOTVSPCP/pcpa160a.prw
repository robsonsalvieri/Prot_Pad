#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"  
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE 'PCPA160.CH'

/*/{Protheus.doc} a160BloqOp()
Função responsável por verificar se existe alguma requisição pendente 
ainda não processada para a OP / Componente.

@author michele.girardi
@since 09/02/2026
@param 01: cOp   - Ordem de produção 
@param 02: nInd  - 1 - Bloqueio encerramento da OP
				 - 2 - Bloqueio alteração Empenho
@param 03: cComp - Componente
@param 04: cMsg  - Mensagem que deverá ser exibida no HELP
@return lRet     - .T. ou .F.
/*/
Function a160BloqOp(cOp, nInd, cComp, cMsg)
	Local aArea    := GetArea()
	Local cAlias   := ""
	Local cFilProc := xFilial("HZ0")
	Local cMsg1    := ""
    Local cQry     := ""
	Local lReqPend := .F.
	Local lRet     := .T.
    Local oExec    := Nil
	
	Default cComp  := ""
	Default cMsg   := ""
	Default nInd   := 1

	lRet := FindFunction('a160Filds')

	If lRet
		lRet := a160Filds()
	EndIf

	If !lRet
		Return .T.
	EndIf

	If lRet
		//Verificar se existe requisição pendente para a OP
		cQry := " SELECT COUNT(*) COUNTRP"
		cQry +=   " FROM " + RetSqlName('HZ0') + " HZ0, " + RetSqlName('HZ1') + " HZ1 "
		cQry += "  WHERE HZ0.HZ0_FILIAL  = ? "
		cQry += "    AND HZ1.HZ1_FILIAL  = ? "
		cQry += "    AND HZ0.HZ0_OP      = ? "
        cQry += "    AND HZ0.HZ0_ESTORN  = 'N' "
		cQry += "    AND HZ0.HZ0_OP      = HZ1.HZ1_OP "
		cQry += "    AND HZ0.HZ0_IDENT   = HZ1.HZ1_IDENT "
		cQry += "    AND HZ0.HZ0_SEQ     = HZ1.HZ1_SEQ "
		cQry += "    AND HZ1.HZ1_ESTORN  = 'N' "
		cQry += "    AND HZ1.HZ1_PROCES  = 'N' "
		cQry += "    AND HZ0.D_E_L_E_T_  = ' ' "
		cQry += "    AND HZ1.D_E_L_E_T_  = ' ' "

		If !Empty(cComp)
			cQry += " AND HZ1.HZ1_COMP = ? "
		EndIf

		oExec := FwExecStatement():New(cQry)
		oExec:setString(1, cFilProc)
		oExec:setString(2, cFilProc)
		oExec:setString(3, cOp)

		If !Empty(cComp)
			oExec:setString(4, cComp)
		EndIf

		cAlias := oExec:OpenAlias()

		If (cAlias)->(!Eof())
			If (cAlias)->COUNTRP > 0
				lReqPend := .T.
				lRet     := .F.
			EndIf
		EndIf

		(cAlias)->(DbCloseArea())        
		oExec:Destroy()
		FreeObj(oExec)
	EndIf

	If lRet .And. nInd == 1
		//Verifica se existe encerramento pendente para OP
		lRet := a161EncPen(cFilProc,cOp)
	EndIf

	If !lRet
		If !Empty(cMsg)
			cMsg1 := cMsg
		Else
			If nInd == 1
				If lReqPend
					cMsg1 := STR0018 //"Não é permitido encerrar a Ordem de Produção quando existe requisição pendente para processamento."
				Else
					cMsg1 := STR0019 //"Não é permitido encerrar a Ordem de Produção quando existe encerramento pendente para processamento."
				EndIf
			Else
				If nInd == 2
					cMsg1 := STR0020 //"Não é permitido alterar o empenho quando existe requisição pendente do componente para processamento."
				EndIf
			EndIf
		EndIf

		Help(Nil,Nil,"Help",Nil,cMsg1,1,0)
	EndIf

	RestArea(aArea)
Return lRet

/*/{Protheus.doc} a161EncPen()
Verifica se existe encerramento pendente para a ordem de produção / período

@author michele.girardi
@since 10/01/2026
@param 01: cFilProc - Filial a ser processada
@param 02: cOp      - Ordem de produção 
@param 03: dDataDe  - Data início para validação
@param 04: dDataAte - Data fim para validação
@return lRet - .T. ou .F.
/*/
Function a161EncPen(cFilProc,cOp,dDataDe,dDataAte)
	Local cAlias1  := ""
	Local cQry1    := ""
	Local lRet     := .T.
	Local oExec1   := Nil

	Default cFilProc  := xFilial("HZ0")
	Default cOp       := ""
	Default dDataAte  := Nil
	Default dDataDe   := Nil
	
	lRet := FindFunction('a160Filds')

	If lRet
		lRet := a160Filds()
	EndIf

	If !lRet
		Return .T.
	EndIf

	If lRet
		//Verifica se existe registro pendente na HZ0 para encerrar a OP
        cQry1 := " SELECT COUNT(*) COUNTZ0  "    
        cQry1 += "   FROM " + RetSqlName('HZ0') + " HZ0 "
        cQry1 += "  WHERE HZ0.HZ0_FILIAL   = ? "
        cQry1 += "    AND HZ0.HZ0_REQTOT   = 'E' " //RECTOT = E - Indica que não existe requisição - Foi gerado somente o encerramento
        cQry1 += "    AND HZ0.HZ0_ENCOP    = 'S' " 
        cQry1 += "    AND HZ0.HZ0_PRCENC   = 'N' " //Ainda não foi encerrado
        cQry1 += "    AND HZ0.HZ0_ESTORN   = 'N' "
        cQry1 += "    AND HZ0.D_E_L_E_T_   = ' ' "

		If !Empty(cOp)
			cQry1 += " AND HZ0.HZ0_OP = ? " 
		Else
			If !Empty(dDataDe) .And. !Empty(dDataAte)
				cQry1 += " AND HZ0.HZ0_DTAPON >= ? "
				cQry1 += " AND HZ0.HZ0_DTAPON <= ? "
			EndIf
		EndIf

        oExec1 := FwExecStatement():New(cQry1)
        oExec1:setString(1, cFilProc)

		If !Empty(cOp)
        	oExec1:setString(2, cOP)
		Else
			If !Empty(dDataDe) .And. !Empty(dDataAte)
				oExec1:setString(2, DtoS(dDataDe))
				oExec1:setString(3, DtoS(dDataAte))
			EndIf
		EndIf

        cAlias1 := oExec1:OpenAlias()

        If (cAlias1)->(!Eof())
			If (cAlias1)->COUNTZ0 > 0
				lRet := .F.
			EndIf
		EndIf

		(cAlias1)->(DbCloseArea())        
		oExec1:Destroy()
		FreeObj(oExec1)
	EndIf

Return lRet

/*/{Protheus.doc} a160EstReq()
Função responsável por verificar se o registro a ser estornado foi gerado
pela requisição pendente.

Não permitir estornar um registro de requisição pendente no MATA241.

@author michele.girardi
@since 09/02/2026
@param 01: cOp     - Ordem de produção 
@param 02: cComp   - Produto requisitado
@param 03: cNumSeq - Sequência da movimentação 
@return lRet - .T. ou .F.
/*/
Function a160EstReq(cOp, cComp, cNumSeq)
	Local aArea    := GetArea()
	Local cAlias   := ""
	Local cAlias1  := ""
    Local cQry     := ""
	Local cQry1    := ""
	Local cMsg     := ""
	Local cMsg1    := ""
	Local lRet     := .T.

    Local oExec    := Nil
	Local oExec1   := Nil
	
	lRet := FindFunction('a160Filds')

	If lRet
		lRet := a160Filds()
	EndIf

	If !lRet
		Return .T.
	EndIf

	If lRet
		cQry := " SELECT COUNT(*) COUNTZ1 "
		cQry +=   " FROM " + RetSqlName('HZ1') + " HZ1 "
		cQry += "  WHERE HZ1.HZ1_FILIAL  = ? "
		cQry += "    AND HZ1.HZ1_OP      = ? "        
		cQry += "    AND HZ1.HZ1_NUMSEQ  = ? "        
		cQry += "    AND HZ1.HZ1_COMP    = ? "        
		cQry += "    AND HZ1.HZ1_PROCES  = 'S' "
		cQry += "    AND HZ1.HZ1_ESTORN  = 'N' "        
		cQry += "    AND HZ1.D_E_L_E_T_  = ' ' "
		
		oExec := FwExecStatement():New(cQry)
		oExec:setString(1, xFilial("HZ1"))
		oExec:setString(2, cOp)
		oExec:setString(3, cNumSeq)
		oExec:setString(4, cComp)
			
		cAlias := oExec:OpenAlias()

		If (cAlias)->(!Eof())
			If (cAlias)->COUNTZ1 > 0
				lRet := .F.
			EndIf
		EndIf

		(cAlias)->(DbCloseArea())        
		oExec:Destroy()
		FreeObj(oExec)
	EndIf

	If lRet
		cQry1 := " SELECT COUNT(*) COUNTZ2 "
		cQry1 +=   " FROM " + RetSqlName('HZ2') + " HZ2 "
		cQry1 += "  WHERE HZ2.HZ2_FILIAL  = ? "
		cQry1 += "    AND HZ2.HZ2_OP      = ? "        
		cQry1 += "    AND HZ2.HZ2_NUMSEQ  = ? "        
		cQry1 += "    AND HZ2.HZ2_COMP    = ? " 
		cQry1 += "    AND HZ2.HZ2_ESTORN  = ' ' "       
		cQry1 += "    AND HZ2.D_E_L_E_T_  = ' ' "

		oExec1 := FwExecStatement():New(cQry1)
		oExec1:setString(1, xFilial("HZ2"))
		oExec1:setString(2, cOp)
		oExec1:setString(3, cNumSeq)
		oExec1:setString(4, cComp)
			
		cAlias1 := oExec1:OpenAlias()

		If (cAlias1)->(!Eof())
			If (cAlias1)->COUNTZ2 > 0
				lRet := .F.
			EndIf
		EndIf

		(cAlias1)->(DbCloseArea())        
		oExec1:Destroy()
		FreeObj(oExec1)
	EndIf

	If !lRet
		cMsg  := STR0021 //"Não é permitido estornar um movimento realizado pela Requisição Pendente."
		cMsg1 := STR0022 //"Para estornar um movimento realizado pela Requisição Pendente é preciso estornar o Apontamento que originou a requisição."
		Help(Nil,Nil,"Help",Nil,cMsg,1,0,,,,,,{cMsg1})
	EndIf
	
	RestArea(aArea)
Return lRet

/*/{Protheus.doc} a160BlqPer()
Função responsável por verificar se existe alguma requisição pendente para o período do processamento.

@author michele.girardi
@since 10/03/2026
@param 01: cFilProc  - Filial a ser processada
@param 02: dDataDe   - Data início para validação
@param 03: dDataAte  - Data fim para validação
@param 04: cMsg      - Mensagem que será apresentada/retornada
@param 05: lShowHelp - Apresentar Help
@return lRet - .T. ou .F.
/*/
Function a160BlqPer(cFilProc, dDataDe, dDataAte, cProdDe, cProdAte, cMsg, lShowHelp)	
	Local aArea    := GetArea()	
	Local cAlias   := ""
	Local cMsg1    := ""
    Local cQry     := ""
	Local lRet     := .T.

    Local oExec    := Nil
	
	Default cFilProc  := xFilial("HZ0")
	Default cMsg      := ""
	Default cProdDe   := ""
	Default cProdAte  := ""
	Default dDataAte  := Nil
	Default dDataDe   := Nil
	Default lShowHelp := .T.

	lRet := FindFunction('a160Filds')

	If lRet
		lRet := a160Filds()
	EndIf

	If !lRet
		Return .T.
	EndIf

	If lRet
		//Verificar se existe requisição pendente para a OP
		cQry := " SELECT COUNT(*) COUNTRP"
		cQry +=   " FROM " + RetSqlName('HZ0') + " HZ0, " + RetSqlName('HZ1') + " HZ1 "
		cQry += "  WHERE HZ0.HZ0_FILIAL  = ? "
		cQry += "    AND HZ1.HZ1_FILIAL  = ? "
        cQry += "    AND HZ0.HZ0_ESTORN  = 'N' "
		cQry += "    AND HZ0.HZ0_OP      = HZ1.HZ1_OP "
		cQry += "    AND HZ0.HZ0_IDENT   = HZ1.HZ1_IDENT "
		cQry += "    AND HZ0.HZ0_SEQ     = HZ1.HZ1_SEQ "
		cQry += "    AND HZ1.HZ1_ESTORN  = 'N' "
		cQry += "    AND HZ1.HZ1_PROCES  = 'N' "
		cQry += "    AND HZ0.D_E_L_E_T_  = ' ' "
		cQry += "    AND HZ1.D_E_L_E_T_  = ' ' "

		If !Empty(dDataDe) .And. !Empty(dDataAte)
			cQry += " AND HZ0.HZ0_DTAPON >= ? "
			cQry += " AND HZ0.HZ0_DTAPON <= ? "
		Else
			If !Empty(cProdDe) .And. !Empty(cProdAte)
				cQry += " AND HZ1.HZ1_COMP >= ? "
				cQry += " AND HZ1.HZ1_COMP <= ? "
			EndIf
		EndIf

		oExec := FwExecStatement():New(cQry)
		oExec:setString(1, cFilProc)
		oExec:setString(2, cFilProc)

		If !Empty(dDataDe) .And. !Empty(dDataAte)
			oExec:setString(3, DtoS(dDataDe))
			oExec:setString(4, DtoS(dDataAte))
		Else
			If !Empty(cProdDe) .And. !Empty(cProdAte)
				oExec:setString(3 ,cProdDe)
				oExec:setString(4, cProdAte)
			EndIf
		EndIf

		cAlias := oExec:OpenAlias()

		If (cAlias)->(!Eof())
			If (cAlias)->COUNTRP > 0
				lRet := .F.
			EndIf
		EndIf

		(cAlias)->(DbCloseArea())        
		oExec:Destroy()
		FreeObj(oExec)
	EndIf

	If lRet
		//Verifica se existe encerramento pendente para o período do processamento
		lRet := a161EncPen(cFilProc,Nil,dDataDe,dDataAte)
	EndIf

	If !lRet
		If !Empty(cMsg)
			cMsg1 := cMsg
		Else
			cMsg1 := STR0023 //"Processamento não permitido. Existe requisição pendente para processamento para o período."
		EndIf
		cMsg := cMsg1

		If lShowHelp
			Help(Nil,Nil,"Help",Nil,cMsg,1,0)
		EndIf
	EndIf

	RestArea(aArea)
Return lRet
