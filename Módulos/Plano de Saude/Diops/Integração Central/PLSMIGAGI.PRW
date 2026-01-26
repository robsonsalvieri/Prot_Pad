#include 'protheus.ch'
#include 'FWMVCDEF.CH'
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSMIGAGI

Funcao criada para migrar o quadro ativos garantidores imobiliario para a central de obrigacoes

@author	timoteo.bega
@since	27/11/2017
/*/
//--------------------------------------------------------------------------------------------------
Function PLSMIGAGI( cTrimestre, cAno , cAuto)

	Local lRet       := .T.
	local aDados     := {}
	Local nVez       := 0
	Local dDataFim   := CtoD('')
	Local nRefere    := 0
	Local cRefere    := ''
	Local lAuto      := .F.
	Local nQtdDatImp := 0
	Local aDataImp   := {}
	Local cErrMsg    := ""

	If !Empty(cAuto) .AND. cAuto == '.T.'
		lAuto := .T.
	Else
		lAuto := .F.
	EndIf

	dDataFim:= LastDay( CtoD( IIf(cTrimestre=='1','31/03/'+cAno, IIf(cTrimestre=='2','30/06/'+cAno, IIf(cTrimestre=='3','30/09/'+cAno,'31/12/'+cAno) ) ) ) )
	aDados:= PLSATGARIM(dDataFim, .F., MV_PAR05)

	If aDados[1]

		// Posiciona Operadora
		BA0->(dbSetOrder(1))
		BA0->(dbSeek(xFilial('BA0')+PlsIntPad()))

		// Prepara indice para buscar Código da Obrigação
		B3A->(dbSetOrder(2))
		B3A->(dbSeek(xFilial('B3A')+BA0->BA0_SUSEP+'3'+'1'))		// Filial + Operadora + Código Fixo da DIOPS + Registro Ativo

		//Trimestre do compromisso
		cRefere	:= Str(val(cTrimestre))
		cCdComp := PLSEXISCO( BA0->BA0_SUSEP, B3A->B3A_CODIGO, cRefere, cAno )

		// Prepara indice para buscar Obrigação
		B3D->(dbSetOrder(1))
		B3D->(MsSeek(xFilial('B3D')+BA0->BA0_SUSEP+B3A->B3A_CODIGO+cAno+cCdComp,.F.))

		// Chama função que informa a Central de Obrigações que enviaremos o quadro
		If qdrPlsIniEnvDiops( '3', BA0->BA0_SUSEP, cAno, StrZero(Val(cTrimestre),2), .T. ) .Or. (IsBlind() .And. Len(aDados[2])>0)

			For nVez := 1 to Len( aDados[2] )

				If IncAtGrImo(MODEL_OPERATION_INSERT,aDados[2][nVez],cAno,cTrimestre,cCdComp)
					nQtdDatImp++
				Else
					aAdd( aErroDIOPS, '3' )	// Variavel Private proveniente do fonte PLSDIOPSPL.prw
					lRet	:= .F.
					Exit
				EndIf

				DelClassInTf()

			Next nFor

			// FunÃ§Ã£o que informa a Central de ObrigaÃ§Ãµes que o quadro foi enviado.
			qdrPlsFimEnvDiops( '3', BA0->BA0_SUSEP, cAno, StrZero(Val(cTrimestre),2) )

		Else
			cErrMsg := "Balancete do compromisso DIOPS do " + allTrim(str(val(cTrimestre))) + " trimestre de " + allTrim(cAno) + " não encontrado."
			aAdd( aErroDIOPS, '3' )	// Variavel Private proveniente do fonte PLSDIOPSPL.prw
			lRet	:= .F.
		EndIf

	EndIf

	Aadd(aDataImp,{lRet,nQtdDatImp,cErrMsg})

Return aDataImp

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} IncAtGrImo

Funcao inclui balancete no nucleo de informacoes e obrigacoes
@param nOpcMVC	3-Incluir, 4-Alterar

@return lRet	Indica se concluiu .T. ou nao .F. a operacao

@author timoteo.bega
@since 27/11/2017
/*/
//--------------------------------------------------------------------------------------------------
Static Function IncAtGrImo(nOpcMVC,aReg,cAno,cTrimestre,cCdComp)

	Local lRet		:= .F.
	Local aErro		:= {}
	Default nOpcMVC	:= nOpcMVC
	Default aReg	:= {}
	// Retorno[2] PLSATGARIM:	{ (cATIMO)->N1_CODRGI, (cATIMO)->N1_REDE, ''/* ASSISTENCIAL AONDE BUSCAR??? */, nResidual }

	If ExistBlock( "PLATVASS" )
		aReg := ExecBlock( "PLATVASS", .F., .F., {aReg} )
	EndIf

	If Len(aReg) > 0

		oModel := FWLoadModel( 'PLSMVCAGI' )
		oModel:SetOperation( nOpcMVC )
		oModel:Activate()
		oModel:SetValue( 'B8CMASTER', 'B8C_FILIAL'	, xFilial('B8C') )
		oModel:SetValue( 'B8CMASTER', 'B8C_CODOPE'	, BA0->BA0_SUSEP )
		oModel:SetValue( 'B8CMASTER', 'B8C_CODOBR'	, B3A->B3A_CODIGO )/*000*///X3_VALID ExistCpo("B3A",M->B8C_CODOPE+M->B8C_CODOBR+"3"+"1",1)
		oModel:SetValue( 'B8CMASTER', 'B8C_ANOCMP'	, cAno )
		oModel:SetValue( 'B8CMASTER', 'B8C_REFERE'	, StrZero(Val(cTrimestre),2) )
		oModel:SetValue( 'B8CMASTER', 'B8C_CDCOMP'	, cCdComp )/*000*///ExistCpo("B3D",M->B8C_CODOPE+M->B8C_CODOBR+M->B8C_ANOCMP+M->B8C_CDCOMP+"3",1)
		oModel:SetValue( 'B8CMASTER', 'B8C_CODRGI'	, aReg[1] )
		oModel:SetValue( 'B8CMASTER', 'B8C_REDPRO'	, IIf(aReg[2]=='S','1','0') )
		oModel:SetValue( 'B8CMASTER', 'B8C_ASSIST'	, IIF(!Empty(aReg[3]),Alltrim(aReg[3]),"0" ))
		oModel:SetValue( 'B8CMASTER', 'B8C_VLRCON'	, aReg[4] )
		//		oModel:SetValue( 'B8CMASTER', 'B8C_VIGINI'	, CTOD('') )
		//		oModel:SetValue( 'B8CMASTER', 'B8C_VIGFIN'	, CTOD('') )
		oModel:SetValue( 'B8CMASTER', 'B8C_STATUS'	, "1" )

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