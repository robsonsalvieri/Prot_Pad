#include 'protheus.ch'
#include 'FWMVCDEF.CH'
#DEFINE ARQ_LOG_CARGA	"diops_carga_agrupamento_contratos.log"
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSMIGAGC

Funcao criada para migrar o AGRUPAMENTOS DE CONTRATOS para a central de obrigacoes

@author Roger C
@since 14/11/2017
/*/
//--------------------------------------------------------------------------------------------------
Function PLSMIGAGC(cTrimestre, cAno, cAuto)

	Local aDados := {}
	Local nItem	 := 0
	Local lRet	 := .T.
	Local cMes	 := IIf(cTrimestre=='1', '03', IIf(cTrimestre=='2', '06', IIf(cTrimestre=='3', '09', '12') ) )
	Local lAuto  := .F.
	Local nQtdDatImp := 0
	Local cErrMsg := ""
	Local aDataImp := {}

	If !Empty(cAuto) .AND. cAuto == '.T.'
		lAuto := .T.
	Else
		lAuto := .F.
	EndIf

	PlsLogFil(CENDTHRL("I") + " Inicio da migração do quadro AGRUPAMENTO DE CONTRATOS.",ARQ_LOG_CARGA)
	PlsLogFil(CENDTHRL("I") + " Recuperando dados do quadro.",ARQ_LOG_CARGA)
	aDados 	:= PLSDAGRP(LastDay(CtoD('01/'+cMes+'/'+cAno)),.F.)

	If aDados[1]

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

		// Chama função que informa a Central de Obrigações que enviaremos o AGRUPAMENTOS DE CONTRATOS
		PlsLogFil(CENDTHRL("I") + " Iniciando o envido do quadro.",ARQ_LOG_CARGA)
		If qdrPlsIniEnvDiops( '12', BA0->BA0_SUSEP, cAno, cTrimestre, .T. )
			PlsLogFil(CENDTHRL("I") + " Inicio do envido do quadro confirmado.",ARQ_LOG_CARGA)
			// Posiciona Operadora
			BA0->(dbSetOrder(1))
			BA0->(dbSeek(xFilial('BA0')+PlsIntPad()))

			For nItem := 1 to 2 //Len(aDados[2])

				// chamada da funcao de inclusão do AGRUPAMENTOS DE CONTRATOS - a função quadroIniEnvDiops() limpou os registros do periodo, se existiam
				If IncAGCCNT(MODEL_OPERATION_INSERT, IIf(nItem==1,'1','2'), aDados[2,nItem])
					nQtdDatImp++
				Else
					aAdd( aErroDIOPS, '12' )	// Variavel Private proveniente do fonte PLSDIOPSPL.prw
					lRet := .F.
				EndIf

				// Destruir o objeto
				DelClassIntf()

			Next

			// Função que informa a Central de Obrigações que o quadro do AGRUPAMENTOS DE CONTRATOS foi enviado.
			// quadroFimEnvDiops( cQuadro, cCodOpe, cAno, cRefere )
			PlsLogFil(CENDTHRL("I") + " Finalizando o envido do quadro.",ARQ_LOG_CARGA)
			qdrPlsFimEnvDiops( '12', BA0->BA0_SUSEP, MV_PAR02, StrZero(Val(MV_PAR01),2) )
			PlsLogFil(CENDTHRL("I") + " Fim do envido do quadro confirmado.",ARQ_LOG_CARGA)

		Else
			cErrMsg := 'Não foi possível inicializar o quadro Agrupamento de Contratos.'
			PlsLogFil(CENDTHRL("E") + " Não foi possível inicializar o quadro Agrupamento de Contratos.",ARQ_LOG_CARGA)
			aAdd( aErroDIOPS, '12' )	// Variavel Private proveniente do fonte PLSDIOPSPL.prw
			lRet	:= .F.

		EndIf

	Else
		cErrMsg := 'Não foram encontrados dados para exportação do quadro Agrupamento de Contratos.'
		PlsLogFil(CENDTHRL("E") + " Não foram encontrados dados para exportação do quadro Agrupamento de Contratos.",ARQ_LOG_CARGA)
		aAdd( aErroDIOPS, '12' )	// Variavel Private proveniente do fonte PLSDIOPSPL.prw
		lRet	:= .F.

	EndIf

	PlsLogFil(CENDTHRL("I") + " Fim da migração do quadro AGRUPAMENTO DE CONTRATOS.",ARQ_LOG_CARGA)
	Aadd(aDataImp,{lRet,nQtdDatImp,cErrMsg})

Return aDataImp


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} IncAGCCNT

Funcao inclui AGRUPAMENTOS DE CONTRATOS no nucleo de informacoes e obrigacoes

@param nOpcMVC	3-Incluir, 4-Alterar

@return lRet	Indica se concluiu .T. ou nao .F. a operacao

@author Roger C
@since 16/11/2017
/*/
//--------------------------------------------------------------------------------------------------
Static Function IncAGCCNT(nOpcMVC, cTipo, aDados)

	Local lRet := .F.
	Default nOpcMVC	:= MODEL_OPERATION_INSERT
	Default cTipo	:= ''
	Default aDados	:= {}

	If !Empty(aDados)

		oModel:= FWLoadModel( 'PLSMVCAGCN' )
		oModel:SetOperation( nOpcMVC )
		oModel:Activate()
		oModel:SetValue( 'B8KMASTER', 'B8K_FILIAL'	, xFilial('B8K') )
		oModel:SetValue( 'B8KMASTER', 'B8K_CODOPE'	, BA0->BA0_SUSEP )
		oModel:SetValue( 'B8KMASTER', 'B8K_CODOBR'	, "000" )
		oModel:SetValue( 'B8KMASTER', 'B8K_ANOCMP'	, MV_PAR02 )
		oModel:SetValue( 'B8KMASTER', 'B8K_CDCOMP'	, "000" )
		oModel:SetValue( 'B8KMASTER', 'B8K_REFERE'	, StrZero(Val(MV_PAR01),2) )
		oModel:SetValue( 'B8KMASTER', 'B8K_STATUS'	, "1" )

		oModel:SetValue( 'B8KMASTER', 'B8K_TIPO'	, cTipo )
		oModel:SetValue( 'B8KMASTER', 'B8K_PLACE'	, aDados[1] ) // Contraprestação Emitida em Planos Coletivos por Adesão        '31111104'
		oModel:SetValue( 'B8KMASTER', 'B8K_PLAEV'	, aDados[2] ) // Eventos/Sinistros conhecidos em Planos Coletivos por Adesão   '41111104','41121104','41131104','41141104','41151104','41171104','41181104','41191104'}
		oModel:SetValue( 'B8KMASTER', 'B8K_PCECE'	, aDados[3] ) // Contraprestação Emitida em Planos Coletivos Empresariais      '31111106'
		oModel:SetValue( 'B8KMASTER', 'B8K_PCEEV'	, aDados[4] ) // Eventos/Sinistros conhecidos em Planos Coletivos Empresariais '41111106','41121106','41131106','41141106','41151106','41171106','41181106','41191106'
		oModel:SetValue( 'B8KMASTER', 'B8K_PLACC'	, aDados[5] ) // Correspondencia Cedida em Planos Coletivos Adesão             '31171104'
		oModel:SetValue( 'B8KMASTER', 'B8K_PCECC'	, aDados[6] ) // Correspondencia Cedida em Planos Coletivos Empresariais       '31171106'

		If oModel:VldData()
			oModel:CommitData()
			lRet := .T.
		Else
			aErro := oModel:GetErrorMessage()
			PlsLogFil(CENDTHRL("E") + " Erro ao gravar registro: " + aErro[6],ARQ_LOG_CARGA)
		EndIf

		oModel:DeActivate()
		oModel:Destroy()
		FreeObj(oModel)
		oModel := Nil

	EndIf

Return lRet

