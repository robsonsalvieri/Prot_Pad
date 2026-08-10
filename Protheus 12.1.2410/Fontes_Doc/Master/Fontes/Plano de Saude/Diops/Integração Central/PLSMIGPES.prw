#include 'protheus.ch'
#include 'FWMVCDEF.CH' 
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSMIGPES

Funcao criada para migrar o Provisão de Eventos e Sinistros a Liquidar para a central de obrigacoes 

@author Roger C
@since 14/11/2017
/*/
//--------------------------------------------------------------------------------------------------
Function PLSMIGPES(cTrimestre, cAno, cAuto)

	Local aDados  := {}
	Local lRet    := .T.
	Local cRefere := ''
	Local cCdComp := ''
	Local lAuto   := .F.
	Local nQtdDatImp := 0
	Local cErrMsg := ""
	Local aDataImp := {}	
	
	Default cTrimestre	:= MV_PAR01
	Default cAno		:= MV_PAR02

	If !Empty(cAuto) .AND. cAuto == '.T.'
		lAuto := .T.
	Else
		lAuto := .F.
	EndIf

	dDatRef := LastDay(STOD(alltrim(MV_PAR02)+IIf(cTrimestre=='1','03',IIf(cTrimestre=='2','06',IIf(cTrimestre=='3','09','12')))+'01'))

	// Obrigatoriedade de apresentação de dados até 36 meses anteriores
	dDatDe	:= FirstDay( dDatRef - (36*30) )

	aDados := PLSEGPESL(dDatDe, dDatRef, .F., lAuto) 

	If aDados[1]

		// Posiciona Operadora
		BA0->(dbSetOrder(1))
		BA0->(dbSeek(xFilial('BA0')+PlsIntPad()))

		// Prepara indice para buscar Código da Obrigação
		B3A->(dbSetOrder(2))
		B3A->(MsSeek(xFilial('B3A')+BA0->BA0_SUSEP+'3'+'1',.F.))		// Filial + Operadora + Código Fixo da DIOPS + Registro Ativo

		//Trimestre do compromisso
		cRefere	:= Str(val(cTrimestre))

		cCdComp := PLSEXISCO( BA0->BA0_SUSEP, B3A->B3A_CODIGO, cRefere, cAno )

		// Prepara indice para buscar Obrigação
		B3D->(dbSetOrder(1))
		B3D->(MsSeek(xFilial('B3D')+BA0->BA0_SUSEP+B3A->B3A_CODIGO+cAno+cCdComp,.F.))

		// Chama função que informa a Central de Obrigações que enviaremos o Provisão de Eventos e Sinistros a Liquidar
		// quadroIniEnvDiops( cQuadro, cCodOpe, cAno, cRefere )
		If qdrPlsIniEnvDiops( '13', BA0->BA0_SUSEP, cAno, StrZero(Val(cTrimestre),2), .T. )

			// chamada da funcao de inclusão do Provisão de Eventos e Sinistros a Liquidar - a função quadroIniEnvDiops() limpou os registros do periodo, se existiam
			If IncPESL(MODEL_OPERATION_INSERT, aDados[2])
				nQtdDatImp++
			Else
				aAdd( aErroDIOPS, '13' )	// Variavel Private proveniente do fonte PLSDIOPSPL.prw
				lRet	:= .F.
			EndIf

			// Destruir o objeto
			DelClassIntf()		

			// Função que informa a Central de Obrigações que o quadro do Provisão de Eventos e Sinistros a Liquidar foi enviado.
			// quadroFimEnvDiops( cQuadro, cCodOpe, cAno, cRefere )
			qdrPlsFimEnvDiops( '13', BA0->BA0_SUSEP, cAno, StrZero(Val(cTrimestre),2) )

		Else
			cErrMsg := 'Não foi possível inicializar o quadro Provisão de Eventos e Sinistros a Liquidar.'
			aAdd( aErroDIOPS, '13' )	// Variavel Private proveniente do fonte PLSDIOPSPL.prw
			lRet	:= .F.

		EndIf

	Else
		cErrMsg := 'Não foram encontrados dados para exportação do quadro Provisão de Eventos e Sinistros a Liquidar.'
		aAdd( aErroDIOPS, '13' )	// Variavel Private proveniente do fonte PLSDIOPSPL.prw
		lRet	:= .F.
	EndIf

	Aadd(aDataImp,{lRet,nQtdDatImp,cErrMsg})	

Return aDataImp


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} IncPESL

Funcao inclui Provisão de Eventos e Sinistros a Liquidar no nucleo de informacoes e obrigacoes

@param nOpcMVC	3-Incluir, 4-Alterar

@return lRet	Indica se concluiu .T. ou nao .F. a operacao

@author Roger C
@since 16/11/2017
/*/
//--------------------------------------------------------------------------------------------------
Static Function IncPESL(nOpcMVC, aDados)
	
	Local lRet := .F.
	Default nOpcMVC	:= MODEL_OPERATION_INSERT
	Default aDados	:= {}

	If !Empty(aDados)

		oModel:= FWLoadModel( 'PLSMVCPESL' )
		oModel:SetOperation( nOpcMVC )
		oModel:Activate()
		oModel:SetValue( 'B8JMASTER', 'B8J_FILIAL'	, xFilial('B8J') )
		oModel:SetValue( 'B8JMASTER', 'B8J_CODOPE'	, BA0->BA0_SUSEP )
		oModel:SetValue( 'B8JMASTER', 'B8J_CODOBR'	, "000" )
		oModel:SetValue( 'B8JMASTER', 'B8J_ANOCMP'	, MV_PAR02 )
		oModel:SetValue( 'B8JMASTER', 'B8J_CDCOMP'	, "000" )
		oModel:SetValue( 'B8JMASTER', 'B8J_REFERE'	, StrZero(Val(MV_PAR01),2) )
		oModel:SetValue( 'B8JMASTER', 'B8J_STATUS'	, "1" )

		oModel:SetValue( 'B8JMASTER', 'B8J_QTDE'	, aDados[1] )
		oModel:SetValue( 'B8JMASTER', 'B8J_EVULTI'	, aDados[2] )
		oModel:SetValue( 'B8JMASTER', 'B8J_EVMAIS'	, aDados[3] )

		// Normativa RN 430 insere campos a partir da competencia 2018
		If B3D->B3D_ANO >= '2018'
			oModel:SetValue( 'B8JMASTER', 'B8J_CAULTI'	, aDados[4] )
			oModel:SetValue( 'B8JMASTER', 'B8J_CAMAIS'	, aDados[5] )
		EndIf

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

	EndIf
		
Return lRet

