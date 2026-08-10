#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE "GPEM026.CH"

/*/{Protheus.doc} GPEM026J
    Atualização de contrato determinado para indeterminado via job
    @type  Function
    @author isabel.noguti
    @since  21/12/2022
    @version 1.0
    @param  aParam, array, parâmetros enviados pelo Schedule
    @return return_var, return_type, return_description
    /*/
Function GPEM026J(aParam)
    Local cParam1	:= ''
	Local cParam2	:= ''
	Local lIntegTAF	:= .F.

	Private lMiddleware	:= .F.

	Default aParam  := {}

    If Len(aParam) > 0
		RpcSetType(3)
		If empty(cParam1) .and. empty(cParam2)
			cParam1 := aParam[1]
			cParam2 := aParam[2]
		Endif

		RPCsetEnv(cParam1, cParam2)
	ENDIF

	//Checa se a rotina está em execução
	If LockByName("GPEM026J"+cEmpAnt+cFilAnt,.T.,.T.,.T.)
		lIntegTAF 	:= If( cPaisLoc == 'BRA' , SuperGetMv("MV_RHTAF",,.F.), .F. )
		lMiddleware	:= If( cPaisLoc == 'BRA' .AND. Findfunction("fVerMW"), fVerMW(), .F. )

		If lIntegTAF .Or. lMiddleware
			conout(" ==================================================================")
			conout("| Iniciando o Processamento de Atualizacao do Contrato de Trabalho |")
			conout(" ==================================================================")
			IntAtuCon()
			conout(" ==================================================================")
			conout("| Termino do Processamento de Atualizacao do Contrato de Trabalho  |")
			conout(" ==================================================================")
		EndIf
		//Destrava rotina após finalizar a execução das Threads
		UnLockByName("GPEM026J"+cEmpAnt+cFilAnt,.T.,.T.,.T.)
	EndIf

	If Len(aParam) > 0
		RpcClearEnv()
	EndIf

Return .T.

/*/{Protheus.doc} IntAtuCon
Rotina responsável pela leitura e processamento das atualizações do tipo de contrato
@type Static function
@author	isabel.noguti
@since	21/12/2022
@version 1.0
/*/
Static function IntAtuCon()
	Local cCateg		:= "%" + fSqlIn(StrTran( fCatTrabEFD("TCV"), "|" ),3) + "%"
	Local cAliasQry		:= GetNextAlias()
	Local cVersEnvio	:= ""
	Local cChave		:= ""
	Local cStatus		:= "-1"
	Local aInfoC		:= {}
	Local cNrInsc		:= "0"
	Local cTpInsc		:= ""
	Local lAdmPubl		:= .F.
	Local aErros		:= {}
	Local nCont			:= 1
	Local cMsgLog		:= ""
	Local cCampoSR9		:= ""
	Local xContAnt
	Local xContNovo

	If FindFunction("fVersEsoc")
		fVersEsoc( "S2206", .F., /*aRetGPE*/, /*aRetTAF*/, @cVersEnvio )
	EndIf

	DbSelectArea("SRA")
	SRA->(dbSetOrder(1))

	BeginSQL Alias cAliasQry
		SELECT RA_FILIAL, RA_MAT, RA_CIC, RA_CODUNIC, RA_NOME
		FROM %table:SRA% SRA
		WHERE RA_FILIAL = %xfilial:SRA%
			AND RA_TPCONTR = '2'
			AND RA_CATEFD IN (%exp:cCateg%)
			AND RA_DTFIMCT < %Exp:DtoS(dDataBase)% AND RA_DTFIMCT > '0'
			AND RA_VCTEXP2 >= RA_DTFIMCT
			AND RA_SITFOLH <> 'D'
			AND RA_VIEMRAI NOT IN ('30','31','35')
			AND SRA.%NotDel%
		ORDER BY RA_FILIAL, RA_MAT
	EndSQL

	While (cAliasQry)->(!Eof())
		cFilAnt := (cAliasQry)->RA_FILIAL
		cStatus := "-1"
		cCampoSR9 := ""

				// "Processando " #	 "Nome: "			 "Matricula: "					 " Filial: "
		MSGINFO( STR0052 + " " + STR0010 + ": " + (cAliasQry)->RA_NOME + " " + STR0009 + ": "+ (cAliasQry)->RA_MAT + STR0051 + (cAliasQry)->RA_FILIAL , STR0001)

		If !lMiddleware
			cChave := (cAliasQry)->RA_CIC + ";" + (cAliasQry)->RA_CODUNIC
			cStatus := TAFGetStat( "S-2200", cChave )
		Else
			fPosFil( cEmpAnt, cFilAnt )
			cTpInsc  := ""
			lAdmPubl := .F.
			cNrInsc  := "0"
			aInfoC   := fXMLInfos()
			If Len(aInfoC) >= 4
				cTpInsc  := aInfoC[1]
				lAdmPubl := aInfoC[4]
				cNrInsc  := aInfoC[2]
			EndIf
			cChave	:= cTpInsc + PADR(If( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S2200" + Padr((cAliasQry)->RA_CODUNIC, fTamRJEKey(), " ")
			//RJE_TPINSC+RJE_INSCR+RJE_EVENTO+RJE_KEY+RJE_INI
			GetInfRJE( 2, cChave, @cStatus )
		EndIf

		If cStatus == "4"
			If SRA->(dbSeek( (cAliasQry)->RA_FILIAL + (cAliasQry)->RA_MAT ))

				Begin Transaction
					If SRA->RA_DTFIMCT == SRA->RA_VCTEXP2 //ou (cAliasQry)->RA_VCTEXP2 < database?
					//mudar tpContr p/1 e gerar 2206 sem dtTerm
						xContAnt := SRA->RA_TPCONTR
						xContNovo := "1"
						If RecLock("SRA",.F.)
							SRA->RA_TPCONTR	:= "1"
							cCampoSR9 := "RA_TPCONTR"
							MsUnLock()
						EndIf
					ElseIf SRA->RA_DTFIMCT < SRA->RA_VCTEXP2 //prorrogação
						xContAnt := SRA->RA_DTFIMCT
						xContNovo := SRA->RA_VCTEXP2
						If RecLock("SRA",.F.)
							SRA->RA_DTFIMCT	:= SRA->RA_VCTEXP2
							cCampoSR9 := "RA_DTFIMCT"
							MsUnLock()
						EndIf
					EndIf
					RegToMemory("SRA",.F.,.T.,.F.)
					If !Empty(cCampoSR9) .And. fInt2206("SRA",/*lAltCad*/,3,"S2206",/*cTFilial*/,/*dtEf*/,/*cTurno*/,/*cRegra*/,/*cSeqT*/,/*oModel*/,cVersEnvio, /*oMdlRS9*/, /*dDtAlt*/, /*lTransf*/, /*cCTT2206*/, @aErros, .F.)
						MSGINFO( STR0049, STR0001 )//"Processado com sucesso"
						fGravaSr9( cCampoSR9 , xContNovo , xContAnt, , .T. )//grava alteração da SRA na SR9
					Else
						DisarmTransaction()
						cMsgLog := If( Empty(cCampoSR9), STR0327, "" )//"Não foi possível atualizar o registro do funcionário na tabela SRA."
						For nCont:= 1 to len(aErros)
							cMsgLog += CRLF + aErros[nCont]
						Next nCont
						MSGINFO( If(!lMiddleware, STR0036, STR0137) + cMsgLog, STR0001 )//" não enviado(a) ao ###"
					EndIf
				End Transaction

			EndIf
		Else
			MSGINFO( If(!lMiddleware, STR0087, STR0139), STR0001 )//"Favor verificar o status do registro do funcionário"
		EndIf

		(cAliasQry)->(dbSkip())
	EndDo

	(cAliasQry)->(dbCloseArea())

Return .T.
