#include 'protheus.ch' 
#include 'FWMVCDEF.CH'
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSMIGEVI

Funcao criada para migrar o MOV EVENTOS INDENIZAVEIS para a central de obrigacoes 

@author Roger C
@since 14/11/2017
/*/
//--------------------------------------------------------------------------------------------------
Function PLSMIGEVI(cTrimestre, cAno, cAuto)

	Local cArqTmp := GetNextAlias()
	Local aDados  := {}
	Local nVez    := 0
	Local lRet    := .T.
	Local nRefere := 0
	Local cRefere := ''
	Local cCdComp := ''
	Local lAuto   := .F.
	Local nQtdDatImp := 0
	Local cErrMsg := ""
	Local aDataImp := {}	

	Default cTrimestre := MV_PAR01
	Default cAno	   := MV_PAR02

	If !Empty(cAuto) .AND. cAuto == '.T.'
		lAuto := .T.
	Else
		lAuto := .F.
	EndIf

	aDados := PLDMOVPD2(cTrimestre, cAno, .F., lAuto) 

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

		// Chama função que informa a Central de Obrigações que enviaremos o MOV EVENTOS INDENIZAVEIS
		// quadroIniEnvDiops( cQuadro, cCodOpe, cAno, cRefere )
		If qdrPlsIniEnvDiops( '11', BA0->BA0_SUSEP, cAno, cTrimestre, .T. )

			For nVez := 1 to Len( aDados[2] )

				// Descarta vazios e espaço 61 a 64 que não existe para a ANS
				If Val(aDados[2,nVez,1])<= 0 .or. ( aDados[2,nVez,1] >= '61' .and. aDados[2,nVez,1] <= '64' )
					Loop
				EndIf

				// chamada da funcao de inclusão do MOV EVENTOS INDENIZAVEIS - a função quadroIniEnvDiops() limpou os registros do periodo, se existiam
				If IncMovInd(MODEL_OPERATION_INSERT,aDados[2,nVez])
					nQtdDatImp++
				Else
					cErrMsg := "CODIGO:"+aDados[2,nVez,1]+CHR(13)+" - VAL1:"+STR(aDados[2,nVez,2])+CHR(13)+" - VAL2:"+STR(aDados[2,nVez,3])+CHR(13)+" - VAL3:"+STR(aDados[2,nVez,4])
					aAdd( aErroDIOPS, '11' )	// Variavel Private proveniente do fonte PLSDIOPSPL.prw
					lRet	:= .F.
				EndIf

				// Destruir o objeto
				DelClassIntf()		
			Next

			// Função que informa a Central de Obrigações que o quadro do MOV EVENTOS INDENIZAVEIS foi enviado.
			// quadroFimEnvDiops( cQuadro, cCodOpe, cAno, cRefere )
			qdrPlsFimEnvDiops( '11', BA0->BA0_SUSEP, MV_PAR02, StrZero(Val(MV_PAR01),2) )

		Else
			cErrMsg := 'Não foi possível inicializar o quadro Movimentação de Eventos Indenizáveis.'
			aAdd( aErroDIOPS, '11' )	// Variavel Private proveniente do fonte PLSDIOPSPL.prw
			lRet	:= .F.
		EndIf

	Else
		cErrMsg := 'Não foram encontrados dados para exportação do quadro Movimentação de Eventos Indenizáveis.'
		aAdd( aErroDIOPS, '11' )	// Variavel Private proveniente do fonte PLSDIOPSPL.prw
		lRet	:= .F.
	EndIf		
	
	If Select(cArqTmp) > 0
		cArqTmp->(dbCloseArea())
		FErase(cArqTmp+GetDBExtension())
		FErase(cArqTmp+OrdBagExt())
	EndIF

	Aadd(aDataImp,{lRet,nQtdDatImp,cErrMsg})	

Return aDataImp


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} IncMovInd

Funcao inclui MOV EVENTOS INDENIZAVEIS no nucleo de informacoes e obrigacoes

@param nOpcMVC	3-Incluir, 4-Alterar

@return lRet	Indica se concluiu .T. ou nao .F. a operacao

@author Roger C
@since 16/11/2017
/*/
//--------------------------------------------------------------------------------------------------
Static Function IncMovInd(nOpcMVC, aDados)
Local lRet := .T.
Default nOpcMVC	:= MODEL_OPERATION_INSERT
Default aDados	:= {}

If !Empty(aDados)

	oModel:= FWLoadModel( 'PLSMVCEVIN' )
	oModel:SetOperation( nOpcMVC )
	oModel:Activate()
	oModel:SetValue( 'B8LMASTER', 'B8L_FILIAL'	, xFilial('B8L') )
	oModel:SetValue( 'B8LMASTER', 'B8L_CODOPE'	, BA0->BA0_SUSEP )
	oModel:SetValue( 'B8LMASTER', 'B8L_CODOBR'	, "000" )
	oModel:SetValue( 'B8LMASTER', 'B8L_ANOCMP'	, MV_PAR02 )
	oModel:SetValue( 'B8LMASTER', 'B8L_CDCOMP'	, "000" )
	oModel:SetValue( 'B8LMASTER', 'B8L_REFERE'	, StrZero(Val(MV_PAR01),2) )
	oModel:SetValue( 'B8LMASTER', 'B8L_CODIGO'	, aDados[1] )
	oModel:SetValue( 'B8LMASTER', 'B8L_VLMES1'	, aDados[2] )
	oModel:SetValue( 'B8LMASTER', 'B8L_VLMES2'	, aDados[3] )
	oModel:SetValue( 'B8LMASTER', 'B8L_VLMES3'	, aDados[4] )
	oModel:SetValue( 'B8LMASTER', 'B8L_STATUS'	, "1" )
			
	If oModel:VldData()
		oModel:CommitData()
	Else
		aErro := oModel:GetErrorMessage()
		lRet := .F.
	EndIf
	
	oModel:DeActivate()
	oModel:Destroy()
	FreeObj(oModel)
	oModel := Nil

EndIf
		
Return lRet
