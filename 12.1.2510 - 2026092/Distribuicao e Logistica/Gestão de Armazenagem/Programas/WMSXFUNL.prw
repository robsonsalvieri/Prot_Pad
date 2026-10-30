#include "protheus.ch"
#include "wmsxfunl.ch"
//------------------------------------------------------------------------------
Function WmsCalcEnd(cArmazem,cEndereco,cIdUnitiz,lExeMovto)
Local aTamSx3   := {}
Local aCalcOcup := {0,0}
Local aAreaAnt  := GetArea()
Local cAliasQry := Nil
Local cWhere    := ""

Default cIdUnitiz := " "
Default lExeMovto := .F.

	// Realiza o cálculo do peso dos produtos que já estão no endereço destino
	cWhere := "%"
	// Se estiver executando o movimento, não deve considerar o unitizador movimentado
	If !Empty(cIdUnitiz)
		If lExeMovto
			cWhere += " AND D14.D14_IDUNIT <> '"+cIdUnitiz+"'"
		Else
			cWhere += " AND D14.D14_IDUNIT = '"+cIdUnitiz+"'"
		EndIf
	EndIf
	cWhere += "%"
	cAliasQry:= GetNextAlias()
	BeginSql Alias cAliasQry
		SELECT SUM( (SB1.B1_PESO + (CASE WHEN (SB1.B1_CONV > 0 AND SB1.B1_TIPCONV = 'D') 
									THEN (SB5.B5_ECPESOE / SB1.B1_CONV) 
									ELSE  SB5.B5_ECPESOE END )) * (D14.D14_QTDEST + D14.D14_QTDEPR)) D14_PESUNI,
				// Se o unitizador que está no endereço controla altura pelo unitizador, não calcula o volume dos itens
				SUM(CASE WHEN D0T.D0T_CTRALT = '2' THEN 0 ELSE((B5_COMPRLC * B5_LARGLC * B5_ALTURLC ) * ( CASE WHEN (SB1.B1_CONV > 0 AND SB1.B1_TIPCONV = 'D')
					THEN ((D14.D14_QTDEST + D14.D14_QTDEPR ) / SB1.B1_CONV) ELSE (D14.D14_QTDEST + D14.D14_QTDEPR) END )) END ) D14_VOLUNI
		FROM %Table:D14% D14
		INNER JOIN %table:SB1% SB1
		ON SB1.B1_FILIAL = %xFilial:SB1%
		AND SB1.B1_COD = D14.D14_PRODUT
		AND SB1.%NotDel%
		INNER JOIN %Table:SB5% SB5
		ON SB5.B5_FILIAL = %xFilial:SB5%
		AND SB5.B5_COD = SB1.B1_COD
		AND SB5.%NotDel%
		LEFT JOIN %Table:D0T% D0T
		ON D0T.D0T_FILIAL = %xFilial:D0T%
		AND D0T.D0T_CODUNI = D14.D14_CODUNI
		AND D0T.%NotDel%
		WHERE D14.D14_FILIAL = %xFilial:D14%
		AND D14.D14_LOCAL = %Exp:cArmazem%
		AND D14.D14_ENDER = %Exp:cEndereco%
		AND D14.%NotDel%
		%Exp:cWhere%
	EndSql
	aTamSx3 := TamSx3("B1_PESO"); TcSetField(cAliasQry,'D14_PESUNI','N',aTamSx3[1],aTamSx3[2])
	TcSetField(cAliasQry,'D14_VOLUNI','N',16,6)
	If (cAliasQry)->(!Eof())
		aCalcOcup[1] := (cAliasQry)->D14_PESUNI
		aCalcOcup[2] := (cAliasQry)->D14_VOLUNI
	EndIf
	(cAliasQry)->(DbCloseArea())
	// Realiza o cálculo do peso dos unitizadores que já estão no endereço destino
	cAliasQry:= GetNextAlias()
	BeginSql Alias cAliasQry
		SELECT SUM (D0T_TARA * NRU.D14_NRUNIT) D0T_PESUNI,
				SUM ((D0T_ALTURA * D0T_LARGUR * D0T_COMPRI) * NRU.D14_NRUNIT) D0T_VOLUNI
		FROM %Table:D0T% D0T
		INNER JOIN (SELECT COUNT(DISTINCT D14.D14_IDUNIT) D14_NRUNIT,
							D14.D14_CODUNI
					FROM %Table:D14% D14
					WHERE D14.D14_FILIAL = %xFilial:D14%
					AND D14.D14_LOCAL = %Exp:cArmazem%
					AND D14.D14_ENDER = %Exp:cEndereco%
					AND D14.D14_IDUNIT <> ' '
					AND D14.%NotDel%
					%Exp:cWhere%
					GROUP BY D14.D14_CODUNI) NRU
		ON D0T.D0T_CODUNI = NRU.D14_CODUNI
		WHERE D0T.D0T_FILIAL = %xFilial:D0T%
		AND D0T.%NotDel%
	EndSql
	aTamSx3 := TamSx3("D0T_TARA"); TcSetField(cAliasQry,'D0T_PESUNI','N',aTamSx3[1],aTamSx3[2])
	TcSetField(cAliasQry,'D0T_VOLUNI','N',16,6)
	If (cAliasQry)->(!Eof())
		aCalcOcup[1] += (cAliasQry)->D0T_PESUNI
		aCalcOcup[2] += (cAliasQry)->D0T_VOLUNI
	EndIf
	(cAliasQry)->(DbCloseArea())
	RestArea(aAreaAnt)
Return aCalcOcup

//------------------------------------------------------------------------------
Function WmsCalcIt(cProduto,nQtde)
Local aAreaAnt  := GetArea()
Local aTamSx3   := {}
Local aCalcItem := {0,0}
Local cAliasQry := Nil
	// Realiza o cálculo do peso do produto que está sendo movimentado
	cAliasQry:= GetNextAlias()
	BeginSql Alias cAliasQry
		SELECT SUM ((SB1.B1_PESO + (CASE WHEN (SB1.B1_CONV > 0 AND SB1.B1_TIPCONV = 'D')
									THEN (SB5.B5_ECPESOE / SB1.B1_CONV) ELSE  SB5.B5_ECPESOE END )) * %Exp:nQtde% ) PESOITEM,
				// Realiza o cálculo do volume do produto que está sendo movimentado
				SUM((B5_COMPRLC * B5_LARGLC * B5_ALTURLC ) * (CASE WHEN (SB1.B1_CONV > 0 AND SB1.B1_TIPCONV = 'D')
																THEN ( %Exp:nQtde% / SB1.B1_CONV)
																ELSE %Exp:nQtde% END ) ) VOLITEM
		FROM %Table:SB1% SB1
		INNER JOIN %Table:SB5% SB5
		ON SB5.B5_FILIAL = %xFilial:SB5%
		AND SB5.B5_COD = SB1.B1_COD
		AND SB5.%NotDel%
		WHERE SB1.B1_FILIAL = %xFilial:SB1%
		AND SB1.B1_COD = %Exp:cProduto%
		AND SB1.%NotDel%
	EndSql
	aTamSx3 := TamSx3("B1_PESO"); TcSetField(cAliasQry,"PESOITEM","N",aTamSx3[1],aTamSx3[2])
	TcSetField(cAliasQry,"VOLITEM",'N',16,6)
	If (cAliasQry)->(!Eof())
		aCalcItem[1] := (cAliasQry)->PESOITEM
		aCalcItem[2] := (cAliasQry)->VOLITEM
	EndIf
	(cAliasQry)->(DbCloseArea())
	RestArea(aAreaAnt)
Return aCalcItem

//------------------------------------------------------------
/*/{Protheus.doc} WMSAjuBlIv
Função para atualização da quantidade bloqueada em estoque quando a quantidade empenhada se refere somente a bloqueio de saldo e mestoque,
e é efetuado a contagem do inventário com uma quantidade menor que e bloqueada.
Esta função e acionada através da rotina de acerto de saldos do inventário. (MATA340)
@author roselaine.adriano
@since 23/09/2012
/*/
Function WMSAjuBlIv(cLocal,cProduto,cLocaliza,cLoteCtl,cSublote,cNumSerie,nEmpenho,nQtdInv,cIdUnitiz,cLog)
Local nSomaBL := 0
Local cAliasQry := ""
Local cAliasD0V := ""
Local oBlqSaldoItens := Nil
Local cWhere:= ""
Local nQtdlib:= 0
Local lRet := .T. 
Local lAtubl := .F. 

    //Para os itens que possuem estrutura de armazenagem (Componentes), não será considerado na rotina de ajuste de saldo bloqueado
	//devido e não ser possível verificar se o bloqueio atualmente e somente do item avulso ou da estrututa
	//desta forma para estes casos, deverá ser removida a quantidade de boqueio antes de processor a rotina de ajustes
	cAliasQry:= GetNextAlias()
	BeginSql Alias cAliasQry
 		SELECT DISTINCT 1 
		FROM %Table:D11% D11
		WHERE D11.D11_FILIAL = %xFilial:D11%
    	AND ( D11.D11_PRDCMP =  %Exp:cProduto% OR D11.D11_PRODUT = %Exp:cProduto% )
		AND D11.%NotDel% 
	EndSql
	If (cAliasQry)->(!Eof())
		Return .T. 
	EndIf
	(cAliasQry)->(DbCloseArea())

	//Quando existe unitizador considerar
	cWhere := "%"
	If !Empty(cIdUnitiz)
		cWhere += " AND D0V.D0V_IDUNIT = '"+cIdUnitiz+"'"
	EndIf
	If !Empty(cLoteCtl)
		cWhere += " AND D0V.D0V_LOTECT = '"+cLoteCtl+"'"
	EndIF
	If !Empty(cSublote)
		cWhere += " AND D0V.D0V_NUMLOT = '"+cSublote+"'"
	EndIF
	cWhere += "%"

	cAliasD0V:= GetNextAlias()
	BeginSql Alias cAliasD0V
 		SELECT SUM(D0V.D0V_QTDBLQ) as SomaBl
    	FROM %Table:D0V% D0V
    	WHERE D0V.D0V_FILIAL = %xFilial:SB5%
    	AND D0V.D0V_LOCAL =  %Exp:cLocal%
    	AND D0V.D0V_PRODUT = %Exp:cProduto%
    	AND D0V.D0V_ENDER =  %Exp:cLocaliza%
		AND D0V.D0V_QTDBLQ > 0 
		AND D0V.%NotDel%
		%Exp:cWhere%
	EndSql
	If (cAliasD0V)->(!Eof())
		nSomaBL := (cAliasD0V)->SomaBl
		//Para que o ajuste da quantidade bloqueada seja efetuado é necessário que exista somente bloqueio como empenho.
		//Foi mantido esta regra para que fique se acordo com o mata340 quando faz ajuste na tabela SDD
		If QtdComp(nSomaBL) == QtdComp(nEmpenho)
			oBlqSaldoItens := WMSDTCBloqueioSaldoItens():New()
			//Caso a quantidade total de empenho seja igual a quantidade empenhada faz select nos registros pra ir diminuindo as quantidades bloqueadas
			//nos documentos 
			cAliasQry:= GetNextAlias()
			BeginSql Alias cAliasQry
 				SELECT D0V.D0V_IDBLOQ, 
        			D0U.D0U_IDDCF,
       			 	D0U.D0U_DOCTO,
         			D0U.D0U_motivo,
         			D0U.D0U_OBSERV,
        			D0U.D0U_ORIGEM,
        			D0U.D0U_TIPBLQ,
        			D0V.D0V_PRDORI,
        			D0V.D0V_PRODUT,
        			D0V.D0V_LOTECT,
					D0V.D0V_NUMLOT,
        			D0V.D0V_LOCAL,
        			D0V.D0V_ENDER,
        			D0V.D0V_IDUNIT,
        			D0V.D0V_QTDBLQ,
        			D0V.D0V_DTVALD
    			FROM %Table:D0V% D0V
				INNER JOIN %Table:D0U% D0U
    			ON D0U.D0U_FILIAL = %xFilial:D0U%
    			AND D0U.D0U_IDBLOQ = D0V.D0V_IDBLOQ
				AND D0U.%NotDel%
    			WHERE D0V.D0V_FILIAL = %xFilial:D0V%
    			AND D0V.D0V_LOCAL =  %Exp:cLocal%
    			AND D0V.D0V_PRODUT = %Exp:cProduto%
    			AND D0V.D0V_ENDER =  %Exp:cLocaliza%
				AND D0V.D0V_QTDBLQ > 0 
				AND D0V.%NotDel%
				%Exp:cWhere%
			EndSql
			Do While (cAliasQry)->(!Eof())
				If nQtdInv > (cAliasQry)->D0V_QTDBLQ
					nQtdInv := nQtdInv - (cAliasQry)->D0V_QTDBLQ
				Else
				 	nQtdlib := (cAliasQry)->D0V_QTDBLQ - nQtdInv
					nQtdinv := 0
					oBlqSaldoItens:ClearData()
					oBlqSaldoItens:SetIdBlq((cAliasQry)->D0V_IDBLOQ)
					oBlqSaldoItens:SetIdDCF((cAliasQry)->D0U_IDDCF)
					oBlqSaldoItens:SetDocto((cAliasQry)->D0U_DOCTO)
					oBlqSaldoItens:SetMotivo((cAliasQry)->d0u_motivo)
					oBlqSaldoItens:SetObserv((cAliasQry)->D0U_OBSERV)
					oBlqSaldoItens:SetOrigem((cAliasQry)->D0U_ORIGEM)
					oBlqSaldoItens:SetTipBlq((cAliasQry)->D0U_TIPBLQ)
					oBlqSaldoItens:SetPrdOri((cAliasQry)->D0V_PRDORI)
					oBlqSaldoItens:SetProduto((cAliasQry)->D0V_PRODUT)
					oBlqSaldoItens:SetLoteCtl((cAliasQry)->D0V_LOTECT)
					oBlqSaldoItens:SetNumLote((cAliasQry)->D0V_NUMLOT)
					oBlqSaldoItens:SetArmazem((cAliasQry)->D0V_LOCAL)
					oBlqSaldoItens:SetEnder((cAliasQry)->D0V_ENDER)
					oBlqSaldoItens:SetIdUnit((cAliasQry)->D0V_IDUNIT) //Necessário infomar apenas se o saldo no endereço possuí unitizador, ou seja, D14_IDUNIT não encontra-se em branco
					oBlqSaldoItens:SetQtdlib(nQtdlib)
					oBlqSaldoItens:SetDtValid((cAliasQry)->D0V_DTVALD)
					If oBlqSaldoItens:LoadData(1)
						If !(lRet := oBlqSaldoItens:RemoverBloqueio())  // com esta função sera possivel alterar o bloqueio. 
							cLog := "D14"
							lRet := .F. 
							Exit
						Else
							lAtubl := .T. 
						EndIf
					EndIf

				EndIf
				(cAliasQry)->(DbSkip())
			EndDo
			(cAliasQry)->(DbCloseArea())
		EndIf
	EndIf
	(cAliasD0V)->(DbCloseArea())
	If lRet
       	If lAtubl 
			nEmpenho :=0
		EndIf
    EndIf
Return lRet

/*/{Protheus.doc} 

PrcWMSBloq(cProduto)	
	Função criada com objetivo de criar registros de bloqueio de item.
	Chamada pela função ProcLote, que é executada na inicialização do Protheus.
	Usada somente quando WMS Novo e Produto integra com WMS.
	
	Em vez de ser chamado o processo de bloqueio da função Bloqdata, são gerados registros nas Tabelas 
	D0U e D0V, e depois chamada função para criação/atualização de SB2, SB8, SDD, SDC, D14, da mesma forma
	que ocorre no WMSA560.

	@type  Function
	@author wander.horongoso
	@since 07/12/2021
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Function PrcWMSBloq(nRecnoSB8, nQtde)
Local lRet := .T.
Local nQtdD14 := 0
Local cDocto := ''
Local cAliasD14 := GetNextAlias()
Local oBlqSaldo := WmsDtcBloqueioSaldoItens():New()

	SB8->(dbGoto(nRecnoSB8))

	//Cálculo do saldo retirado do filtro do WMSA560A
	BeginSql Alias cAliasD14
		SELECT D14.D14_QTDEST,
			   D14.D14_QTDSPR, 
			   D14.D14_QTDEMP, 
   			   D14.D14_QTDBLQ,
			   D14.D14_PRDORI,
			   D14.D14_PRODUT,
			   D14.D14_LOTECT,
			   D14.D14_NUMLOT,
			   D14.D14_LOCAL,
			   D14.D14_ENDER,
			   D14.D14_DTVALD
		FROM %Table:D14% D14
		WHERE D14.D14_FILIAL = %xFilial:D14%
		AND D14.D14_LOCAL = %Exp:SB8->B8_LOCAL%
		AND D14.D14_PRODUT = %Exp:SB8->B8_PRODUTO%
		AND D14.D14_LOTECT = %Exp:SB8->B8_LOTECTL%
		AND (D14.D14_QTDEST - (D14.D14_QTDSPR+D14.D14_QTDEMP+D14.D14_QTDBLQ)) > 0
		AND D14.%NotDel%
		ORDER BY D14.D14_ENDER
	EndSQL

	While (cAliasD14)->(!Eof()) .And. nQtde > 0

 		nQtdD14 := Min(nQtde, (cAliasD14)->(D14_QTDEST - (D14_QTDSPR+D14_QTDEMP+D14_QTDBLQ)))
		nQtde -= nQtdD14

		cDocto := GetSX8Num("D0U","D0U_DOCTO")
		Iif(__lSX8,ConfirmSX8(),)

		oBlqSaldo:SetDocto(cDocto)
		oBlqSaldo:SetIdBlq(ProxNum())
		oBlqSaldo:SetObserv()
		oBlqSaldo:SetOrigem('D0U')
		oBlqSaldo:SetTipBlq('2')
		
		oBlqSaldo:SetMotivo('VV')
		oBlqSaldo:SetPrdOri((cAliasD14)->D14_PRDORI)
		oBlqSaldo:SetProduto((cAliasD14)->D14_PRODUT)
		oBlqSaldo:SetLoteCtl((cAliasD14)->D14_LOTECT)
		oBlqSaldo:SetNumLote((cAliasD14)->D14_NUMLOT)
		oBlqSaldo:SetArmazem((cAliasD14)->D14_LOCAL)
		oBlqSaldo:SetEnder((cAliasD14)->D14_ENDER)		
		oBlqSaldo:SetQtdBlq(nQtdD14)
		
		oBlqSaldo:SetDtValid(sToD((cAliasD14)->D14_DTVALD))
		
		lRet := oBlqSaldo:RealizarBloqueio()		
		
		(cAliasD14)->(dbSkip())
	EndDo

	(cAliasD14)->(DbCloseArea())
	
Return lRet
