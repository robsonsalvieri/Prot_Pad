#INCLUDE "TOTVS.CH"
#INCLUDE "PCPA141.CH"

#DEFINE BUFFER_INTEGRACAO 1000

Static _lSMQExist := FWAliasInDic("SMQ", .F.) .And. Findfunction("mrpInSMQ")

/*/{Protheus.doc} PCPA141OP
Executa o processamento dos registros de Ordens de produção

@type  Function
@author marcelo.neumann
@since 16/08/2019
@version P12
@param 01 cUUID    , Caracter, Identificador do processo para buscar os dados na tabela T4R
@param 02 lMultiThr, Lógico  , Indica se a integração será feita em mais de uma thread
@return oErros     , Objeto  , Json com os erros que ocorreram no processamento
/*/
Function PCPA141OP(cUUID, lMultiThr)
	Local aDados      := {}
	Local aErroJson   := {}
	Local cAlias      := PCPAliasQr()
	Local cGlbErros   := "ERROS_141" + cUUID
	Local lLock       := .F.
	Local nCountLoop  := 0
	Local nPos        := 0
	Local nRecnoSC2   := 0
	Local oErros      := JsonObject():New()
	Local oPCPLock    := PCPLockControl():New()
	Default lMultiThr := .F.

	BeginSql Alias cAlias
		SELECT T4R.T4R_IDREG,
		       T4R.R_E_C_N_O_
		  FROM %Table:T4R% T4R
		 WHERE T4R.T4R_FILIAL = %xfilial:T4R%
		   AND T4R.T4R_API    = 'MRPPRODUCTIONORDERS'
		   AND T4R.T4R_IDPRC  = %Exp:cUUID%
		   AND T4R.%NotDel%
	EndSql

	If (cAlias)->(!Eof())
		lLock := oPCPLock:lock("MRP_MEMORIA", "PCPA141", "MRPPRODUCTIONORDERS", .F., {"PCPA712", "PCPA145", "PCPA151"}, 2)
	EndIf

	PutGlbValue(cGlbErros, "0")

	nPos := 0
	While (cAlias)->(!Eof())
		nRecnoSC2 := Val((cAlias)->T4R_IDREG)
		SC2->(dbGoTo(nRecnoSC2))
		If SC2->(!EoF())
			If _lSMQExist .And. !mrpInSMQ(SC2->C2_FILIAL)
				nCountLoop++

				T4R->(dbGoTo((cAlias)->R_E_C_N_O_))
				RecLock('T4R', .F.)
					T4R->(dbDelete())
				T4R->(MsUnlock())

			Else
				A650AddInt(@aDados, , IIf(SC2->(!Deleted()), "INSERT", "DELETE"))
				nPos++
			EndIf
		Else
			aAdd(aErroJson, {(cAlias)->R_E_C_N_O_, STR0021}) // "O campo T4R_IDREG não é um recno válido."
		EndIf

		(cAlias)->(dbSkip())

		If nPos > BUFFER_INTEGRACAO .Or. ((cAlias)->(Eof()) .And. Len(aDados) > 0)
			nPos += nCountLoop

			If lMultiThr
				PCPIPCGO(P141IdThr(), .F., "P141Intgra", "MRPPRODUCTIONORDERS", nPos, "MATA650INT", cGlbErros, "", aDados, Nil, Nil, cUUID)
			Else
				P141Intgra("MRPPRODUCTIONORDERS", nPos, "MATA650INT", cGlbErros, "", aDados, Nil, Nil, cUUID)
			EndIf

			nPos       := 0
			nCountLoop := 0
			aSize(aDados, 0)
		EndIf
	End
	(cAlias)->(dbCloseArea())

	If nCountLoop > 0
		P141AttGlb("MRPPRODUCTIONORDERS", nCountLoop)
	EndIf

	If lMultiThr
		PCPIPCWait(P141IdThr())
	EndIf

	If lLock
		oPCPLock:unlock("MRP_MEMORIA", "PCPA141", "MRPPRODUCTIONORDERS")
	EndIf

	If Len(aErroJson) > 0
		oErros["ERRO_JSON"] := aClone(aErroJson)
	EndIf
	oErros["ERROR_LOG"] := Val(GetGlbValue(cGlbErros))
	ClearGlbValue(cGlbErros)

	FwFreeArray(aErroJson)
	FwFreeArray(aDados)

Return oErros