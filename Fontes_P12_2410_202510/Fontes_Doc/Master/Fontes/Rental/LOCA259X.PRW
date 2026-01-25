#Include "loca259x.ch"
#INCLUDE "TOTVS.CH"


/*
Fonte com funções genericas de uso pela Gestão de Demandas
*/
/*/{Protheus.doc} GERANUMAS
Gera novo numero da A.S. conforme regras
@type function
@version 25.10
@author Alexandre Circenis
@since 5/9/2025
@param PSRV, variant, Codigo do Serviço
@param PPROJETO, variant, Codigo do Projeto
@param POBRA, variant, Codigo da Obra
@param PSEQ, variant, Sequencia
@param PFILIAL, variant, Filial
@return variant, Codigo da A.S.
/*/
FUNCTION GERANUMAS( PSRV , PPROJETO, POBRA, PSEQ, PFILIAL)

LOCAL AAREA     := GETAREA()
LOCAL AAREADTQ  := FQ5->(GETAREA())
LOCAL LCONTINUA := .T.
LOCAL CSERVICO  := ALLTRIM( PSRV )
LOCAL CPROJETO  := SUBSTR( ALLTRIM( PPROJETO ), 5, 5 )
LOCAL COBRA     := ALLTRIM( POBRA )
LOCAL CNEWSEQ   := ALLTRIM( IIF( VALTYPE(PSEQ) == "N", STRZERO(PSEQ, 3), PSEQ ) )
LOCAL _CFILIAL  := ALLTRIM( PFILIAL )
Local lLOCA59XE := EXISTBLOCK("LOCA59XE")

	nForca := 0
	If lLOCA59XE
		nForca := EXECBLOCK("LOCA59XE",.T.,.T.,{})
	EndIf

	IF LEN( CSERVICO ) != 2 .or. nForca == 1
		FINAL(STR0003+CSERVICO+STR0002, STR0001) //"Geracao de AS " //" invalido!" //"Servico informado "
	ENDIF

	IF LEN( CPROJETO ) != 5 .or. nForca == 2
		FINAL(STR0004+CPROJETO+STR0002, STR0001) //"Projeto informado ["###"] invalido"### //"Geracao de AS " //" invalido!" //"Projeto informado"
	ENDIF

	IF LEN( COBRA ) != 3 .or. nForca == 3
		FINAL(STR0006+COBRA+STR0005, STR0001) // "Obra/Viagem informada ["###"] invalida"### //"Geracao de AS " //" invalida!" //"Obra/Viagem informada "
	ENDIF

	IF LEN( CNEWSEQ ) != 3 .or. nForca == 4
		CNEWSEQ := RIGHT( "000" + CNEWSEQ, 3 )
	ENDIF

	IF EMPTY( _CFILIAL ) .or. nForca == 5	 			// CASO NÃƒO TENHA CONTEÃšDO
		_CFILIAL := REPLICATE("0", LEN( CFILANT ) )		// PREENCHE O TAMANHO DO XFILIAL() COM ZEROS
	ENDIF

	FQ5->(DBSETORDER(9))								// FQ5_FILIAL + FQ5_AS + FQ5_VIAGEM
	WHILE LCONTINUA
		CNRAS     := CSERVICO + CPROJETO + COBRA + CNEWSEQ + _CFILIAL
		LCONTINUA := FQ5->(DBSEEK( XFILIAL("FQ5") + CNRAS, .T.))
		CNEWSEQ   := SOMA1(CNEWSEQ)
	ENDDO

	FQ5->(RESTAREA(AAREADTQ))
	RESTAREA( AAREA )

RETURN CNRAS

/*/{Protheus.doc} Loca259XCn
Realiza o cancelamento (rejeição) da A.S.
@type function
@version 25.10 
@author Alexandre Circenis
@since 5/9/2025
@return variant, Rejeição bem sucedida
/*/
FUNCTION Loca259XCn()
LOCAL _AAREAOLD  := GETAREA()
LOCAL _AAREADTQ  := FQ5->(GETAREA())
LOCAL _AAREAZLG  := FPO->(GETAREA())
LOCAL _AAREAZAG  := FPA->(GETAREA())
LOCAL _AAREAZA5  := FP4->(GETAREA())
LOCAL _AAREAST9  := ST9->(GETAREA())
LOCAL _CQUERY    := ""
LOCAL CQUERY     := ""
LOCAL NCOUNT     := 0
LOCAL LVERZBX    := SUPERGETMV("MV_LOCX097",,.F.) // HABILITA CONTROLE DE MINUTA
LOCAL _LEXCZAG   := SUPERGETMV("MV_LOCX274",,.F.) // EXCLUÍ ZAG NO CANCELAMENTO DA AS
Local _LC145ACE  := EXISTBLOCK("LC145ACE")
Local lMvGSxRent := SuperGetMv("MV_GSXRENT",.F.,.F.)
Local aBindParam
Local lRet       := .T.

BEGIN TRANSACTION

	FPA->(DBSETORDER(3)) //FPA_FILIAL+FPA_AS+FPA_VIAGEM
	ST9->(DBSETORDER(1)) //T9_FILIAL+T9_CODBEM
	FPO->(DBSETORDER(5)) //FPO_FILIAL+FPO_NRAS+FPO_FROTA+FPO_CODBEM

	IF FPA->(DBSEEK(XFILIAL("FPA") + FQ5->FQ5_AS))
		// Jose Eulalio - 16/01/2023 - SIGALOC94-619 - Integração com GS, Gestão de Serviços
		If lMvGSxRent
			LOCA084(.T.)
		EndIf
		//Atualiza Status
		IF ST9->(DBSEEK(XFILIAL("ST9") + FQ5->FQ5_GUINDA)) .AND. !EMPTY(ALLTRIM(FQ5->FQ5_GUINDA))
			IF GETADVFVAL("FQD", "FQD_STAREN",XFILIAL("FQD")+ST9->T9_STATUS,2,"") == "10" .and. !empty(ST9->T9_STATUS)
				IF LVERZBX // TEM MINUTA? SE TIVER CHAMA ROTINA P/ EXCLUIR PROGRAMACAO E CANCELAR MINUTA
					LOCA00519( FQ5->FQ5_AS )
				ENDIF
						
				_CQUERY          := " SELECT FQD_STATQY"
				_CQUERY          += " FROM " + RETSQLNAME("FQD") + " FQD"
				_CQUERY          += " WHERE FQD_STAREN = '00' "
				_CQUERY          += " AND FQD.D_E_L_E_T_ = ' ' "

				MPSysOpenQuery(_CQUERY,"TRBTQY")

				IF TRBTQY->(!EOF())
					LOCXITU21(ST9->T9_STATUS,TRBTQY->FQD_STATQY,FPA->FPA_PROJET,"","",.T.)
					IF RECLOCK("ST9",.F.)
						ST9->T9_STATUS   := TRBTQY->FQD_STATQY
						ST9->(MSUNLOCK())
					ENDIF
				
					TRBTQY->(DBCLOSEAREA())
				ENDIF
			ENDIF
		endif	

		//Deleta registros da FPO para a A.S. cancelada/rejeitada
		IF FPO->(DBSEEK(XFILIAL("FPO") + FQ5->FQ5_AS))
			WHILE FPO->(!EOF()) .AND. FPO->FPO_FILIAL == XFILIAL("FPO") .AND. FPO->FPO_NRAS == FQ5->FQ5_AS
				IF RECLOCK("FPO",.F.)
					FPO->(DBDELETE())
					FPO->(MSUNLOCK())
				ENDIF
				FPO->(DBSKIP())
			ENDDO
		ENDIF
					
		// exclui FPA ou apaga viagem e AS
		IF _LEXCZAG
			IF RECLOCK("FPA",.F.)
				FPA->FPA_AS      := ""
				FPA->FPA_VIAGEM  := ""
				FPA->(DBDELETE())
				FPA->(MSUNLOCK())
			ENDIF
		ELSE
			IF RECLOCK("FPA",.F.)
				FPA->FPA_AS      := ""
				FPA->FPA_VIAGEM  := ""
				FPA->(MSUNLOCK())
			ENDIF
		ENDIF
					
		// Circenis - 25/01/2024 - Excluir as minutas antes de cancelar a AS
		msAguarde( {||LOCA04003(FQ5->FQ5_AS)}, STR0007) //"Aguarde! Excluindo informações de Minuta"

		IF FQ5->(RECLOCK("FQ5",.F.)) // Rejeitando a A.S.
			FQ5->FQ5_STATUS  := "9"
			FQ5->(MSUNLOCK())
		ENDIF
					
		IF _LC145ACE //EXISTBLOCK("LC145ACE") //PONTO DE ENTRADA PARA CANCELAMENTO DE AS DE ACESSÓRIO.
			EXECBLOCK("LC145ACE",.T.,.T.,{LVERZBX, _LEXCZAG, FPA->FPA_PROJET, FQ5->FQ5_AS, FQ5->FQ5_VIAGEM})
		ENDIF
		NCOUNT++
		
			
	ENDIF
	
	//DENNIS
	/*
	+ FP0->FP0_PROJET +
	*/
	CQUERY           := " SELECT R_E_C_N_O_ AS REG"
	CQUERY           += " FROM " + RETSQLNAME("FPA") + " ZAG"
	CQUERY           += " WHERE FPA_PROJET = ? "
	CQUERY           += " AND FPA_AS <> '' "
	CQUERY           += " AND ZAG.D_E_L_E_T_ = ' ' "

	CQUERY           := CHANGEQUERY(CQUERY)
	aBindParam       := {FP0->FP0_PROJET}
	MPSysOpenQuery(cQuery,"TRBFPA",,,aBindParam)

	//TCQUERY CQUERY NEW ALIAS "TRBFPA"

	IF TRBFPA->(EOF())
		IF RECLOCK("FP0", .F.)
			FP0->FP0_DATAS   := CTOD(" / / ") // GRAVO A DATA DA GERAÇÃO DA AS
			FP0->(MSUNLOCK())
		ENDIF
	ENDIF

END TRANSACTION

RESTAREA( _AAREAST9 )
RESTAREA( _AAREADTQ )
RESTAREA( _AAREAZA5 )
RESTAREA( _AAREAZAG )
RESTAREA( _AAREAZLG )
RESTAREA( _AAREAOLD )

RETURN lRet

/*/{PROTHEUS.DOC} LOCA059B1
ITUP BUSINESS - TOTVS RENTAL
VALIDA SE UM CAMPO EXISTE NO SX3
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 15/05/2024
/*/
Function LOCA059B1(cCampo, cAlias)
Local a1Struct
Local nP
Local lRet := .F.
    If !empty(cCampo) .and. !empty(cAlias)
        a1Struct := FWSX3Util():GetListFieldsStruct( cAlias, .F.)
        For nP := 1 to len(a1Struct)
            If upper(alltrim(a1Struct[nP][01])) == upper(alltrim(cCampo))
                lRet := .T.
                exit
            EndIf
        Next
    EndIF
Return lRet
