#include 'protheus.ch'
#include 'FWMVCDEF.CH'
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSMIGFLX

Funcao criada para migrar o Fluxo de Caixa para a central de obrigacoes 

@author Roger C
@since 14/11/2017
/*/
//--------------------------------------------------------------------------------------------------
Function PLSMIGFLX(cTrimestre, cAno, cAuto)

	Local lRet       := .T.
	Local cArqTmp    := GetNextAlias()
	Local lAuto      := .F.
	Local nQtdDatImp := 0
	Local cErrMsg    := ""
	Local aDataImp   := {}

	Default cTrimestre	:= StrZero(MV_PAR01,2)
	Default cAno		:= MV_PAR02

	If !Empty(cAuto) .AND. cAuto == '.T.'
		lAuto := .T.
	Else
		lAuto := .F.
	EndIf

	PLSDFLCXTM(@cArqTmp, cTrimestre, cAno, .F.)

	If Select(cArqTmp) > 0 .AND. !(cArqTmp)->(EOF())

		(cArqTmp)->(dbGotop())

		// Posiciona Operadora
		BA0->(dbSetOrder(1))
		BA0->(dbSeek(xFilial('BA0')+PlsIntPad()))

		// Chama função que informa a Central de Obrigações que enviaremos o Fluxo de Caixa
		// quadroIniEnvDiops( cQuadro, cCodOpe, cAno, cRefere )
		If qdrPlsIniEnvDiops( '4', BA0->BA0_SUSEP, cAno, cTrimestre, .T. )

			nValor		:= 0
			cLastCod	:= (cArqTmp)->B8V_CODIGO	//  SUM(FK2_VALOR) AS VALORBAIXA	
			While (cArqTmp)->(!Eof())

				If cLastCod == (cArqTmp)->B8V_CODIGO
					nValor += (cArqTmp)->VALORBAIXA
					(cArqTmp)->(dbSkip())
					Loop
				Else	
					// chamada da funcao de inclusão do fluxo de caixa
					If  nValor > 0
						If IncFlxCaixa(MODEL_OPERATION_INSERT, cArqTmp, cLastCod, nValor)
							nQtdDatImp++
						Else
							cErrMsg := "Erro ao processar Fluxo de Caixa."
							aAdd( aErroDIOPS, '4' )	// Variavel Private proveniente do fonte PLSDIOPSPL.prw
							lRet	:= .F.
						EndIf

						nValor	:= 0

					EndIf
					// Destruir o objeto
					DelClassIntf()		

				EndIf
				(cArqTmp)->(dbSkip())

			Enddo

			// Grava ultimo codigo do arquivo	
			// chamada da funcao de inclusão do fluxo de caixa
			If nValor > 0 
				If IncFlxCaixa(MODEL_OPERATION_INSERT, cArqTmp, cLastCod, nValor)
					nQtdDatImp++
				Else
					aAdd( aErroDIOPS, '4' )	// Variavel Private proveniente do fonte PLSDIOPSPL.prw
					lRet	:= .F.
				EndIf		
			EndIf
			// Destruir o objeto
			DelClassIntf()
			// Função que informa a Central de Obrigações que o quadro do Fluxo de Caixa foi enviado.
			// quadroFimEnvDiops( cQuadro, cCodOpe, cAno, cRefere )
			qdrPlsFimEnvDiops( '4', BA0->BA0_SUSEP, cAno, cTrimestre )

		Else
			cErrMsg := "Balancete do compromisso DIOPS do " + allTrim(str(val(cTrimestre))) + " trimestre de " + allTrim(cAno) + " não encontrado."
			aAdd( aErroDIOPS, '4' )	// Variavel Private proveniente do fonte PLSDIOPSPL.prw
			lRet	:= .F.
		EndIf

	EndIf
		
	//If !lAuto
	//	MsgAlert('Não foram encontrados dados para exportação do quadro Fluxo de Caixa.')
	//EndIf
	//aAdd( aErroDIOPS, '4' )	// Variavel Private proveniente do fonte PLSDIOPSPL.prw
	//lRet	:= .F.	

	If Select(cArqTmp) > 0
		(cArqTmp)->(dbCloseArea())
		FErase(cArqTmp+GetDBExtension())
		FErase(cArqTmp+OrdBagExt())
	EndIf

	Aadd(aDataImp,{lRet,nQtdDatImp,cErrMsg})

Return aDataImp


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} IncFlxCaixa

Funcao inclui Fluxo de Caixa no nucleo de informacoes e obrigacoes

@param nOpcMVC	3-Incluir, 4-Alterar

@return lRet	Indica se concluiu .T. ou nao .F. a operacao

@author Roger C
@since 16/11/2017
/*/
//--------------------------------------------------------------------------------------------------
Static Function IncFlxCaixa(nOpcMVC, cArqTmp, cCodigo, nValor)
Local lRet := .F.
Default nOpcMVC	:= MODEL_OPERATION_INSERT
Default cArqTmp	:= 'TMP'
Default cCodigo := ''
Default nValor 	:= 0

oModel	:= FWLoadModel( 'PLSMVCFLCX' )
oModel:SetOperation( nOpcMVC )
oModel:Activate()
oModel:SetValue( 'B8HMASTER', 'B8H_FILIAL'	, xFilial('B8H') )
oModel:SetValue( 'B8HMASTER', 'B8H_CODOPE'	, BA0->BA0_SUSEP )
oModel:SetValue( 'B8HMASTER', 'B8H_CODOBR'	, '000'	)		// B3D->B3D_CODIGO )
oModel:SetValue( 'B8HMASTER', 'B8H_ANOCMP'	, MV_PAR02 )	// B3D->B3D_ANOCMP )
oModel:SetValue( 'B8HMASTER', 'B8H_REFERE'	, StrZero(Val(MV_PAR01),2) )	// B3D->B3D_REFERE )
oModel:SetValue( 'B8HMASTER', 'B8H_CDCOMP'	, '000' )		// B3D->B3D_CDCOMP )	
oModel:SetValue( 'B8HMASTER', 'B8H_CODIGO'	, cCodigo )
oModel:SetValue( 'B8HMASTER', 'B8H_VLRCON'	, nValor )
oModel:SetValue( 'B8HMASTER', 'B8H_STATUS'	, '1' )
				
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


