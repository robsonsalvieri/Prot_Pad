#include 'protheus.ch'
#include 'FWMVCDEF.CH' 
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSMIGISA

Job de integracao com a central de obrigacoes

@author timoteo.bega
@since 21/11/2017
/*/
//--------------------------------------------------------------------------------------------------
Function PLSMIGISA( cTrimestre, cAno, cAuto )
	
	Local nFor     := 0
	Local aDados   := {}
	Local dDataRef := dDataBase
	Local lRet     := .T.
	Local lAuto    := .F.
	Local nQtdDatImp := 0
	Local cErrMsg := ""
	Local aDataImp := {}

	If !Empty(cAuto) .AND. cAuto == '.T.'
		lAuto := .T.
	Else
		lAuto := .F.
	EndIf

	dDataRef	:= LastDay( CtoD( IIf(cTrimestre=='1','31/03/'+cAno, IIf(cTrimestre=='2','30/06/'+cAno, IIf(cTrimestre=='3','30/09/'+cAno,'31/12/'+cAno) ) ) ) ) 

  /*
	If !lAuto
		Processa( {|| aDados := PLSDISR(dDataRef,.T.)}, 'Processando Idade de Saldos - Ativo')
	Else
		If FindFunction('PLSDISR')
			aDados := PLSDISR(dDataRef,.T., lAuto)
		endif
	EndIf
   */

	If Len(aDados) .And. aDados[1] 

		// Posiciona Operadora
		BA0->(dbSetOrder(1))
		BA0->(dbSeek(xFilial('BA0')+PlsIntPad()))

		// Prepara indice para buscar Código da Obrigação
		B3A->(dbSetOrder(2))
		B3A->(dbSeek(xFilial('B3A')+BA0->BA0_SUSEP+'3'+'1'))		// Filial + Operadora + Código Fixo da DIOPS + Registro Ativo

		// Prepara indice do Idade de Saldos a Pagar
		B8F->(dbSetOrder(1))

		//Inicia Quadro - "16"//Idade de Saldos Ativo -- A Receber
		If qdrPlsIniEnvDiops( '16', BA0->BA0_SUSEP, cAno, cTrimestre, .T. )

			For nFor := 1 to Len(aDados[2])
				// Despreza totalizador
				If aDados[2,nFor,1] == 999	
					Loop
				EndIf

				/*
				If !PreencheModel(aDados[2,nFor],dDataRef,cTrimestre)
					aAdd( aErroDIOPS, '16' )	// Variavel Private proveniente do fonte PLSDIOPSPL.prw
					lRet	:= .F.
				EndIf
				*/

				DelClassInTf()

			Next nFor

			//Termina quadro
			qdrPlsFimEnvDiops( '16', BA0->BA0_SUSEP, cAno, cTrimestre )

		Else
			cErrMsg := 'Não foi possível iniciar o quadro Idade de Saldos Passivo.'
			aAdd( aErroDIOPS, '16' )	// Variavel Private proveniente do fonte PLSDIOPSPL.prw
			lRet	:= .F.

		EndIf

	Else
		cErrMsg := "Balancete do compromisso DIOPS do " + allTrim(str(val(cTrimestre))) + " trimestre de " + allTrim(cAno) + " não encontrado."
		aAdd( aErroDIOPS, '16' )	// Variavel Private proveniente do fonte PLSDIOPSPL.prw
		lRet	:= .F.
	EndIf

	Aadd(aDataImp,{lRet,nQtdDatImp,cErrMsg})

Return aDataImp

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PreencheAtivo

Preenche o model para gravacao da idade dos saldos ativo - receber

@author timoteo.bega
@since 21/11/2017
/*/
//--------------------------------------------------------------------------------------------------
Static Function PreencheAtivo(aDados,dDataRef,cTrimestre)

	Local nFor := 0
	Local lRet := .F.

	//Ano do compromisso
	cAnoCmp	:= AllTrim(Str(Year(dDataRef)))

	//Trimestre do compromisso
	cRefere	:= Str(val(cTrimestre))

	//Vencimento do item da idade do saldo
	If ValType(aDados[1]) == "N"
		If aDados[1] == 0
			cVencto := "000"
		ElseIf aDados[1] == 30
			cVencto := "030"
		ElseIf aDados[1] == 60
			cVencto := "060"
		ElseIf aDados[1] == 90
			cVencto := "090"
		ElseIf aDados[1] == 99
			cVencto := "099"
		ElseIf aDados[1] == 1000		// PPSC
			cVencto := "400"
		Else
			// Se preencheu incorreto, retorna erro
			Return lRet
		EndIf
	Else
		// Se preencheu incorreto, retorna erro
		Return lRet
	EndIf

	////Vencimento do item da idade do saldo
	//If ValType(aDados[1]) == "N"
	//	If aDados[1] == 30
	//		cVencto := "030"
	//	ElseIf aDados[1] == 60
	//		cVencto := "060"
	//	ElseIf aDados[1] == 90
	//		cVencto := "090"
	//	ElseIf aDados[1] == 120
	//		cVencto := "120"
	//	ElseIf aDados[1] == 121
	//		cVencto := "999"
	//	Else
	//		cVencto := "000"
	//	EndIf
	//Else
	//	cVencto := "000"
	//EndIf

	cCdComp := PLSEXISCO( BA0->BA0_SUSEP, B3A->B3A_CODIGO, cRefere, cAnoCmp )
	oModel	:= FWLoadModel( 'PLSMVCIDSA' )

	
	If B8F->(msSeek(xFilial('B8F')+BA0->BA0_SUSEP+B3A->B3A_CODIGO+cAnoCmp+cCdComp+cVencto, .F.))
		oModel:SetOperation( MODEL_OPERATION_UPDATE )
		oModel:Activate()
	Else
		oModel:SetOperation( MODEL_OPERATION_INSERT )
		oModel:Activate()
		oModel:SetValue( 'B8FMASTER', 'B8F_FILIAL'	, xFilial('B8F') )
		oModel:SetValue( 'B8FMASTER', 'B8F_CODOPE'	, BA0->BA0_SUSEP )
		oModel:SetValue( 'B8FMASTER', 'B8F_CODOBR'	, B3A->B3A_CODIGO )
		oModel:SetValue( 'B8FMASTER', 'B8F_ANOCMP'	, cAnoCmp )
		oModel:SetValue( 'B8FMASTER', 'B8F_REFERE'	, StrZero(Val(cRefere),2,0) )
		oModel:SetValue( 'B8FMASTER', 'B8F_CDCOMP'	, cCdComp )
		oModel:SetValue( 'B8FMASTER', 'B8F_VENCTO'	, cVencto )
	EndIf

	oModel:SetValue( 'B8FMASTER', 'B8F_EVESUS', aDados[2])
	oModel:SetValue( 'B8FMASTER', 'B8F_EVENTO', aDados[3])
	oModel:SetValue( 'B8FMASTER', 'B8F_COMERC', aDados[4])
	oModel:SetValue( 'B8FMASTER', 'B8F_DEBOPE', aDados[5])
	oModel:SetValue( 'B8FMASTER', 'B8F_OUDBOP', aDados[6])
	oModel:SetValue( 'B8FMASTER', 'B8F_TITSEN', aDados[7])
	oModel:SetValue( 'B8FMASTER', 'B8F_DEPBEN', aDados[8])
	oModel:SetValue( 'B8FMASTER', 'B8F_SERASS', aDados[9])
	oModel:SetValue( 'B8FMASTER', 'B8F_AQUCAR', aDados[10])
	oModel:SetValue( 'B8FMASTER', 'B8F_OUDBPG', aDados[11])
	oModel:SetValue( 'B8FMASTER', 'B8F_STATUS', "1")

	If oModel:VldData()
		oModel:CommitData()
		lRet := .T.
	Else
		aErro := oModel:GetErrorMessage()
	EndIf

	oModel:DeActivate()
	oModel:Destroy()
	FreeObj(oModel)
	oModel := Nil

Return lRet