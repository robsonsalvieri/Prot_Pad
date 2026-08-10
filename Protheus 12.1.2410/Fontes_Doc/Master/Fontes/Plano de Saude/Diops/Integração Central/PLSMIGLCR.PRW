#include 'protheus.ch'
#include 'FWMVCDEF.CH' 
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSMIGLCR

Funcao criada para migrar o quadro Lucros e Prejuizos para a central de obrigacoes 

@author	timoteo.bega
@since	27/11/2017
/*/
//--------------------------------------------------------------------------------------------------
Function PLSMIGLCR(cTrimestre, cAno, cAuto)

	Local lRet  := .T.
	Local aRet  := {}
	Local nCont := 0
	Local lAuto := .F.
	Local nQtdDatImp := 0
	Local cErrMsg := ""
	Local aDataImp := {}
	
	Default cAno		:= StrZero(Val(MV_PAR02),4)
	Default cTrimestre	:= StrZero(Val(MV_PAR01),2)

	If !Empty(cAuto) .AND. cAuto == '.T.'
		lAuto := .T.
	Else
		lAuto := .F.
	EndIf

	aRet := PLSDLCRP( cTrimestre, cAno, .F., MV_PAR03, lAuto)

	If aRet[1]

		// Posiciona Operadora
		BA0->(dbSetOrder(1))
		BA0->(dbSeek(xFilial('BA0')+PlsIntPad()))

		// Prepara indice para buscar Código da Obrigação
		B3A->(dbSetOrder(2))
		B3A->(dbSeek(xFilial('B3A')+BA0->BA0_SUSEP+'3'+'1'))		// Filial + Operadora + Código Fixo da DIOPS + Registro Ativo

		// Prepara indice do Lucros e Prejuízos
		//B8E->(dbSetOrder(1))

		// Chama função que informa a Central de Obrigações que enviaremos o quadro "6" Lucros e Prejuízos
		//If qdrPlsIniEnvDiops( '6', BA0->BA0_SUSEP, cAno, StrZero(Val(cTrimestre),2), .T. )
		If qdrPlsIniEnvDiops( '6', BA0->BA0_SUSEP, cAno, cTrimestre, .T. )

			If Len(aRet) > 0

				For nCont := 2 TO Len(aRet)

					If IncLucrPrej(aRet[nCont],cTrimestre,cAno)
						nQtdDatImp++
					Else
						aAdd( aErroDIOPS, '6' )	// Variavel Private proveniente do fonte PLSDIOPSPL.prw
						lRet	:= .F.
						Exit
					EndIf

					DelClassInTf()

				Next nFor

			EndIf

			// Função que informa a Central de Obrigações que o quadro foi enviado.
			qdrPlsFimEnvDiops( '6', BA0->BA0_SUSEP, cAno, StrZero(Val(cTrimestre),2)  )

		Else
			cErrMsg := "Balancete para o compromisso DIOPS do " + allTrim(str(val(cTrimestre))) + " trimestre de " + allTrim(cAno) + " não encontrado. Permissão para importação negada."
			aAdd( aErroDIOPS, '6' )	// Variavel Private proveniente do fonte PLSDIOPSPL.prw
			lRet	:= .F.
		EndIf 

	EndIf
	
	Aadd(aDataImp,{lRet,nQtdDatImp,cErrMsg})

Return aDataImp

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} IncLucrPrej

Funcao inclui balancete no nucleo de informacoes e obrigacoes
@param nOpcMVC	3-Incluir, 4-Alterar
@return lRet	Indica se concluiu .T. ou nao .F. a operacao

@author timoteo.bega
@since 27/11/2017
/*/
//--------------------------------------------------------------------------------------------------
Static Function IncLucrPrej(aReg,cTrimestre,cAno)
	
	Local lRet		:= .F.
	Local aErro		:= {}
	Local cRefere	:= ''
	Local cCdComp	:= ''
	Default aReg	:= {}

	If Len(aReg) > 0 .and. !Empty(aReg[1])

		//Trimestre do compromisso
		cRefere	:= StrZero(Val(cTrimestre),2)

		cCdComp := PLSEXISCO( BA0->BA0_SUSEP, B3A->B3A_CODIGO, cRefere, cAno )

		oModel	:= FWLoadModel( 'PLSMVCLCR' )

		If B8E->(msSeek(xFilial('B8E')+BA0->BA0_SUSEP+B3A->B3A_CODIGO+cAno+cCdComp+aReg[1], .F.))
			oModel:SetOperation( MODEL_OPERATION_UPDATE )
		Else
			oModel:SetOperation( MODEL_OPERATION_INSERT )
		EndIf

		oModel:Activate()
		oModel:SetValue( 'B8EMASTER', 'B8E_FILIAL'	, xFilial('B8E') )
		oModel:SetValue( 'B8EMASTER', 'B8E_CODOPE'	, BA0->BA0_SUSEP )
		oModel:SetValue( 'B8EMASTER', 'B8E_CODOBR'	, B3A->B3A_CODIGO )
		oModel:SetValue( 'B8EMASTER', 'B8E_ANOCMP'	, cAno )
		oModel:SetValue( 'B8EMASTER', 'B8E_REFERE'	, cRefere )
		oModel:SetValue( 'B8EMASTER', 'B8E_CDCOMP'	, cCdComp )
		oModel:SetValue( 'B8EMASTER', 'B8E_DESCRI'	, aReg[1] )
		oModel:SetValue( 'B8EMASTER', 'B8E_VLRCON'	, aReg[3] )
		oModel:SetValue( 'B8EMASTER', 'B8E_STATUS'	, "1" )

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