#include 'totvs.ch'
#include 'protheus.ch' 
#include 'FWMVCDEF.CH'
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSMIGBAL
s
Funcao criada para migrar o balancete para a central de obrigacoes, chamada a partir do fonte PLSDIOPSPL

@author Roger C
@since 16/02/2018
/*/
//--------------------------------------------------------------------------------------------------
Function PLSMIGBAL(cTrimestre,cAno,cAuto)

	Local lEnd		 := .F.
	Local cArqTmp	 := GetNextAlias()
	Local aSetOfBook := {}
	Local lImpAntLP	 := .F.
	Local lVlrZerado := .T.
	Local lImpSint	 := .T.
	Local cFilUser	 := ".T."
	Local lRecDesp0  := .F.
	Local cRecDesp	 := ""
	Local dDtZeraRD	 := CtoD("")
	Local cMoedaDsc	 := ""
	Local aSelFil	 := {}
	Local dDataIni	 := CtoD('')
	Local dDataFim	 := CtoD('')
	Local lRet       := .T.
	Local lTemDados	 := .T.
	Local nQtdDatImp := 0
	Local cRefere	 := ''
	Local cCdComp	 := ''
	Local aDataImp   := {}
	Local cErrMsg    := ""
	Local oText
	Local oDlg
	Local oMeter
	Local lAuto 	 := .F.

	If !Empty(cAuto) .AND. cAuto == '.T.'
		lAuto := .T.
	Else
		lAuto := .F.
	EndIf

	If Empty(mv_par01) .OR. Empty(mv_par02)
		If !lAuto
			MsgInfo( "É necessário informar todos os parâmetros!", "Parâmetros obrigatórios" ) //"É necessário informar todos os parâmetros!"#"Parâmetros obrigatórios"			
		EndIf
		If Select(cArqTmp) > 0 
			(cArqTmp)->(dbCloseArea())
		EndIf
		Return .F.
	Endif

	aSetOfBook := CTBSetOf("")

	dDataIni := Ctod('01/' + IIf(cTrimestre=='1','01', IIf(cTrimestre=='2','04', IIf(cTrimestre=='3', '07', '10' ) ) ) + '/' + MV_PAR02)
	dDataFim := LastDay( Ctod('28/' + IIf(cTrimestre=='1','03', IIf(cTrimestre=='2','06', IIf(cTrimestre=='3', '09', '12' ) ) ) + '/' + MV_PAR02 ) )

	If !lAuto
		MsgMeter({|	oMeter, oText, oDlg, lEnd | ;
			CTGerPlan(oMeter, oText, oDlg, @lEnd,@cArqTmp,;
			dDataIni,dDataFim,"CT7","","", Repl("Z", TamSx3("CT1_CONTA")[1]),,,,,,,"01","1",aSetOfBook,"","","","",;
			.F.,.F.,2,,lImpAntLP,CtoD(''),1,lVlrZerado,,,,,,,,,,,,,,lImpSint,cFilUser,lRecDesp0,;
			cRecDesp,dDtZeraRD,,,,,,,cMoedaDsc,,aSelFil)},;
			OemToAnsi(OemToAnsi('Verificando dados passiveis de importação...')),; //"Criando Arquivo Tempor rio..."
			OemToAnsi('Gerando Balancete')) //"Balancete Verificacao"
	Else	
		CTGerPlan(oMeter, oText, oDlg, @lEnd,@cArqTmp,;
			dDataIni,dDataFim,"CT7","","", Repl("Z", TamSx3("CT1_CONTA")[1]),,,,,,,"01","1",aSetOfBook,"","","","",;
			.F.,.F.,2,,lImpAntLP,CtoD(''),1,lVlrZerado,,,,,,,,,,,,,,lImpSint,cFilUser,lRecDesp0,;
			cRecDesp,dDtZeraRD,,,,,,,cMoedaDsc,,aSelFil)
	EndIf

	nCount := cArqTmp->(RecCount())
	lTemDados := !(nCount == 0 .And. !Empty(aSetOfBook[5]))

	If lTemDados

		cArqTmp->(DbGoTop())

		// Posiciona Operadora
		BA0->(dbSetOrder(1))
		BA0->(MsSeek(xFilial('BA0')+PlsIntPad()))

		// Posiciona Obrigação - Tipo? 3 - DIOPS / Ativo? 1 - Sim
		B3A->(dbSetOrder(2))
		B3A->(MsSeek(xFilial('B3A')+BA0->BA0_SUSEP+'3'+'1' ))

		//Trimestre do compromisso
		cRefere	:= Str(val(cTrimestre))

		cCdComp := PLSEXICOM( BA0->BA0_SUSEP, B3A->B3A_CODIGO, cRefere, cAno )

		// Prepara indice para buscar Obrigação
		B3D->(dbSetOrder(1))
		B3D->(MsSeek(xFilial('B3D')+BA0->BA0_SUSEP+B3A->B3A_CODIGO+cAno+cCdComp,.F.))

		// Posiciona Indice Conta Contábil
		CT1->(dbSetOrder(1))		// CT1_FILIAL + CT1_CONTA

		If qdrPlsIniEnvDiops( '1', BA0->BA0_SUSEP, cAno, cTrimestre, .T. )

			While !cArqTmp->(Eof())

				// Atenção, não pode colocar a soma das variaveis do temporário igual a zero, pois pode haver movimentação que anule e o total seja zero, mas precisa apresentar
				If Len(AllTrim(cArqTmp->CONTA)) > 9 .or. ( cArqTmp->SALDOANT == 0 .and. cArqTmp->SALDODEB == 0 .and. cArqTmp->SALDOCRD == 0 .and. cArqTmp->SALDOATU == 0 )
					cArqTmp->(dbSkip())	
					Loop
				EndIf

				// Valida conta no CT1
				CT1->( MsSeek(xFilial('CT1')+cArqTmp->CONTA,.F.) )
				If Empty(CT1->CT1_DIOPS)
					cArqTmp->(dbSkip())	
					Loop	
				EndIf

				// Migração da conta para o balancete
				If !ExistBalance()
					IncBalance(MODEL_OPERATION_INSERT, cArqTmp, StrZero(Val(cTrimestre),2), cAno, cCdComp)
					nQtdDatImp++
				Else
					//MsgAlert('Registro já existe no quadro Balancete.')
					aAdd( aErroDIOPS, '1' )	// Variavel Private proveniente do fonte PLSDIOPSPL.prw
					lRet	:= .F.
				EndIf
					// Destruir o objeto
				DelClassIntf()
				cArqTmp->(dbSkip())

			EndDo

			// Função que informa a Central de Obrigações que o quadro do Balancete foi enviado.
			// quadroFimEnvDiops( cQuadro, cCodOpe, cAno, cRefere )
			qdrPlsFimEnvDiops( '1', BA0->BA0_SUSEP, cAno, cTrimestre )

		Else
			cErrMsg := "Balancete do compromisso DIOPS do " + allTrim(str(val(cTrimestre))) + " trimestre de " + allTrim(cAno) + " não encontrado."
			aAdd( aErroDIOPS, '1' )	// Variavel Private proveniente do fonte PLSDIOPSPL.prw
			lRet	:= .F.
		EndIf

	Else
		cErrMsg := "Balancete do compromisso DIOPS do " + allTrim(str(val(cTrimestre))) + " trimestre de " + allTrim(cAno) + " não encontrado."
		aAdd( aErroDIOPS, '1' )	// Variavel Private proveniente do fonte PLSDIOPSPL.prw
		lRet := .F.
	EndIf

	If Select(cArqTmp) > 0
		cArqTmp->(dbCloseArea())
		FErase(cArqTmp+GetDBExtension())
		FErase(cArqTmp+OrdBagExt())
	EndIf

	Aadd(aDataImp,{lRet,nQtdDatImp,cErrMsg})

Return aDataImp


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} IncBalance

Funcao inclui balancete no nucleo de informacoes e obrigacoes

@param  nOpcMVC  3-Incluir, 4-Alterar
@return lRet	 Indica se concluiu .T. ou nao .F. a operacao

@author Roger C
@since 07/11/2017
/*/
//--------------------------------------------------------------------------------------------------
Static Function IncBalance(nOpcMVC,cArqTmp, cTrimestre,cAno, cCdComp)
	
	Local lRet := .F.
	Local cPicture	:= "@E 99999999999999.99"

	Default nOpcMVC	:= MODEL_OPERATION_INSERT
	Default cArqTmp	:= 'TMP'

	oModel := FWLoadModel( 'PLSMVCBLC' )
	oModel:SetOperation( nOpcMVC )
	oModel:Activate()
	oModel:SetValue( 'B8AMASTER', 'B8A_FILIAL'	, xFilial('B8A') )
	oModel:SetValue( 'B8AMASTER', 'B8A_CODOPE'	, BA0->BA0_SUSEP )
	oModel:SetValue( 'B8AMASTER', 'B8A_CODOBR'	, B3A->B3A_CODIGO )
	oModel:SetValue( 'B8AMASTER', 'B8A_ANOCMP'	, cAno )
	oModel:SetValue( 'B8AMASTER', 'B8A_REFERE'	, cTrimestre )
	oModel:SetValue( 'B8AMASTER', 'B8A_CDCOMP'	, cCdComp )	
	oModel:SetValue( 'B8AMASTER', 'B8A_CONTA'	, AllTrim(cArqTmp->CONTA) )
	oModel:SetValue( 'B8AMASTER', 'B8A_SALANT'	, Val(StrTran(ValorCTB(cArqTmp->SALDOANT,,,17,2,.T.,cPicture,cArqTmp->NORMAL,,,,"S",,.T.,.F.),",",".")) )
	oModel:SetValue( 'B8AMASTER', 'B8A_DEBITO'	, Val(StrTran(ValorCTB(cArqTmp->SALDODEB,,,16,2,.F.,cPicture,cArqTmp->NORMAL,,,,"S",,.T.,.F.),",",".")) )
	oModel:SetValue( 'B8AMASTER', 'B8A_CREDIT'	, Val(StrTran(ValorCTB(cArqTmp->SALDOCRD,,,16,2,.F.,cPicture,cArqTmp->NORMAL,,,,"S",,.T.,.F.),",",".")) )
	oModel:SetValue( 'B8AMASTER', 'B8A_SALFIN'	, Val(StrTran(ValorCTB(cArqTmp->SALDOATU,,,17,2,.T.,cPicture,cArqTmp->NORMAL,,,,"S",,.T.,.F.),",",".")) )
	oModel:SetValue( 'B8AMASTER', 'B8A_STATUS'	, '1' )

	If oModel:VldData()
		oModel:CommitData()
		lRet := .T.
	Else
		aErro := oModel:GetErrorMessage()
		aAdd( aErroDIOPS, '1' )	// Variavel Private proveniente do fonte PLSDIOPSPL.prw
	EndIf

	oModel:DeActivate()
	oModel:Destroy()
	FreeObj(oModel)
	oModel := Nil
	//  DelClassIntf() - alterado para a função de chamada
			
Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ExistBalance

Verifica se conta contabil ja se encontra cadastrado na tabela da Central de Obrigacoes

@return lRet	Retorna .T. se encontrou o produto senao retorna .F.

@author Roger C
@since 07/11/2017
/*/
//--------------------------------------------------------------------------------------------------
Static Function ExistBalance(cArqTmp)
	
	Local lRet	:= .T.
	Local cSql	:= ""
	Default cArqTmp := 'TMP'

	cSql := " SELECT R_E_C_N_O_ FROM " + RetSqlName('B8A') + " WHERE B8A_FILIAL = '" + xFilial('B8A') + "' AND B8A_CODOPE = '" + BA0->BA0_SUSEP + "' "
	cSql += " AND B8A_CODOBR = '" + B3A->B3A_CODIGO + "' AND B8A_ANOCMP = '" + STRZERO(Val(MV_PAR02),4) + "' AND B8A_REFERE = '" +STRZERO(Val(MV_PAR01),2)+ "' " 
	cSql += " AND B8A_CONTA = '" + AllTrim(cArqTmp->CONTA) + "' AND B8A_STATUS = '" + "1" + "' "
	cSql += " AND D_E_L_E_T_ = ' ' " 
	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBT",.F.,.T.)

	If !TRBT->(Eof())
		lRet := .T.
	Else
		lRet := .F.
	EndIf

	TRBT->(dbCloseArea())

Return lRet


