#include 'protheus.ch'
#include 'FWMVCDEF.CH' 
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSMIGISP

Job de integracao com a central de obrigacoes - Idade de Saldos Passivo

@author timoteo.bega
@since 21/11/2017
/*/
//--------------------------------------------------------------------------------------------------
Function PLSMIGISP( cTrimestre, cAno, cAuto)

	Local nFor     := 0
	Local aDados   := {}
	Local dDataRef := dDataBase
	Local lRet     := .T.
	Local lAuto    := .F.
	Local nQtdDatImp := 0
	Local cErrMsg  := ""
	Local aDataImp := {}	

	If !Empty(cAuto) .AND. cAuto == '.T.'
		lAuto := .T.
	Else
		lAuto := .F.
	EndIf

	dDataRef := LastDay( CtoD( IIf(cTrimestre=='1','31/03/'+cAno, IIf(cTrimestre=='2','30/06/'+cAno, IIf(cTrimestre=='3','30/09/'+cAno,'31/12/'+cAno) ) ) ) ) 
	aDados   := PLSRDIQRP(dDataRef,.F., lAuto)

	If aDados[1]

		// Posiciona Operadora
		BA0->(dbSetOrder(1))
		BA0->(MsSeek(xFilial('BA0')+PlsIntPad()))

		// Prepara indice para buscar Código da Obrigação
		B3A->(dbSetOrder(2))
		B3A->(MsSeek(xFilial('B3A')+BA0->BA0_SUSEP+'3'+'1',.F.))		// Filial + Operadora + Código Fixo da DIOPS + Registro Ativo

		//Trimestre do compromisso
		cRefere	:= Str(val(cTrimestre))

		cCdComp := PLSEXISCO( BA0->BA0_SUSEP, B3A->B3A_CODIGO, cRefere, cAno )

		// Prepara indice para buscar Obrigação
		B3D->(dbSetOrder(1))
		B3D->(MsSeek(xFilial('B3D')+BA0->BA0_SUSEP+B3A->B3A_CODIGO+cAno+cCdComp,.F.))

		// Prepara indice do Idade de Saldos a Pagar
		B8G->(dbSetOrder(1))

		//Inicia Quadro - "5"//Idade de Saldos Passivo  -  a Pagar
		If qdrPlsIniEnvDiops( '5', BA0->BA0_SUSEP, cAno, cTrimestre, .T. )

			For nFor := 1 to Len(aDados[2])

				// Descarta se for o Totalizador ('999')
				If aDados[2,nFor,1] == 999
					Loop
				EndIf

				If PreenchePassivo(aDados[2,nFor],dDataRef,cAno,cRefere,cCdComp)
					nQtdDatImp++
				Else
					aAdd( aErroDIOPS, '5' )	// Variavel Private proveniente do fonte PLSDIOPSPL.prw
					lRet	:= .F.
				EndIf

				DelClassInTf()

			Next nFor

			//Termina quadro
			qdrPlsFimEnvDiops( '5', BA0->BA0_SUSEP, cAno, cTrimestre)

		Else
			cErrMsg := 'Não foi possível iniciar o quadro Idade de Saldos Ativo.'
			aAdd( aErroDIOPS, '5' )	// Variavel Private proveniente do fonte PLSDIOPSPL.prw
			lRet	:= .F.
		EndIf

	Else
		cErrMsg := "Balancete para o compromisso DIOPS do " + allTrim(str(val(cTrimestre))) + " trimestre de " + allTrim(cAno) + " não encontrado. Permissão para importação negada."
		aAdd( aErroDIOPS, '5' )	// Variavel Private proveniente do fonte PLSDIOPSPL.prw
		lRet := .F.
	EndIf

	Aadd(aDataImp,{lRet,nQtdDatImp,cErrMsg})

Return aDataImp

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PreenchePassivo

Preenche o model para gravacao da idade dos saldos passivo - pagar

@author timoteo.bega
@since 21/11/2017
/*/
//--------------------------------------------------------------------------------------------------
Static Function PreenchePassivo(aDados,dDataRef,cAnoCmp,cRefere,cCdComp)
	
	Local lRet := .F.

	//Vencimento do item da idade do saldo
	If ValType(aDados[1]) == "N"
		If aDados[1] == 30
			cVencto := "030"
		ElseIf aDados[1] == 60
			cVencto := "060"
		ElseIf aDados[1] == 90
			cVencto := "090"
		ElseIf aDados[1] == 120
			cVencto := "120"
		ElseIf aDados[1] == 121
			cVencto := "999"
		Else
			cVencto := "000"
		EndIf
	Else
		cVencto := "000"
	EndIf	

	oModel	:= FWLoadModel( 'PLSMVCIDSP' )
	
	If B8G->(msSeek(xFilial('B8G')+BA0->BA0_SUSEP+B3A->B3A_CODIGO+cAnoCmp+cCdComp+cVencto, .F.))
		oModel:SetOperation( MODEL_OPERATION_UPDATE )
	Else
		oModel:SetOperation( MODEL_OPERATION_INSERT )
	EndIf

	oModel:Activate()
	oModel:SetValue( 'B8GMASTER', 'B8G_FILIAL'	, xFilial('B8G') )
	oModel:SetValue( 'B8GMASTER', 'B8G_CODOPE'	, BA0->BA0_SUSEP )
	oModel:SetValue( 'B8GMASTER', 'B8G_CODOBR'	, B3A->B3A_CODIGO )
	oModel:SetValue( 'B8GMASTER', 'B8G_ANOCMP'	, cAnoCmp )
	oModel:SetValue( 'B8GMASTER', 'B8G_REFERE'	, cRefere )
	oModel:SetValue( 'B8GMASTER', 'B8G_CDCOMP'	, cCdComp )		// Sistema buscará o código correto na pré-validação
	oModel:SetValue( 'B8GMASTER', 'B8G_VENCTO'	, cVencto )
	oModel:SetValue( 'B8GMASTER', 'B8G_INDPRE'	, aDados[2] )
	oModel:SetValue( 'B8GMASTER', 'B8G_INDPOS'	, aDados[3] )
	oModel:SetValue( 'B8GMASTER', 'B8G_COLPRE'	, aDados[4] )
	oModel:SetValue( 'B8GMASTER', 'B8G_COLPOS'	, aDados[5] )
	oModel:SetValue( 'B8GMASTER', 'B8G_CREADM'	, aDados[6] )
	oModel:SetValue( 'B8GMASTER', 'B8G_PARBEN'	, aDados[7] )
	oModel:SetValue( 'B8GMASTER', 'B8G_OUCROP'	, aDados[8] )
	oModel:SetValue( 'B8GMASTER', 'B8G_CROPPO'	, aDados[9] )
	oModel:SetValue( 'B8GMASTER', 'B8G_OUCRPL'	, aDados[10] )
	oModel:SetValue( 'B8GMASTER', 'B8G_OUTCRE'	, aDados[11] )
	oModel:SetValue( 'B8GMASTER', 'B8G_STATUS'	, "1" )

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
