#include 'protheus.ch'
#include 'FWMVCDEF.CH' 
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSMIGINT

Funcao criada para migrar o INTERCAMBIO EVENTUAL para a central de obrigacoes 

@author Roger C
@since 14/11/2017
/*/
//--------------------------------------------------------------------------------------------------
Function PLSMIGINT(cTrimestre, cAno)

Local lRet			:= .T.
Local cArqTmp		:= GetNextAlias()
local aDados	    := {}
Local aRet			:= {}
Local nVez			:= 0
Local dDatDe		:= CtoD('01/01/1900')
Local dDatAte		:= LastDay( CtoD('01/'+IIf(cTrimestre=='1','03',IIf(cTrimestre=='2','06', IIf(cTrimestre=='3','09', '12') ) )+'/'+cAno ) )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Prepara os Dados para contas a receber               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aRet := PlDIntR(.F.,dDatDe,dDatAte)

If aRet[1]		
	aDados := aClone(aRet[2])
EndIf

// Limpa os arrays
aSize(aRet,1)
aDel(aRet,1)
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Prepara os Dados para contas a pagar                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aRet := PlDIntP(.F.,dDatDe,dDatAte)		// Mostra Tela, Data Inicio, Data Fim - será considerado o último dia do mês 
If aRet[1]
	For nVez := 1 to Len(aRet[2])
		aAdd( aDados, aRet[2,nVez] )
	Next nVez
EndIf	

If Len(aDados) > 0

	// Posiciona Operadora
	BA0->(dbSetOrder(1))
	BA0->(dbSeek(xFilial('BA0')+PlsIntPad()))

	// Chama função que informa a Central de Obrigações que enviaremos o INTERCAMBIO EVENTUAL
	// quadroIniEnvDiops( cQuadro, cCodOpe, cAno, cRefere )
	If quadroIniEnvDiops( '10', BA0->BA0_SUSEP, cAno, StrZero(Val(cTrimestre),2), .T. )
		
		For nVez := 1 to Len( aDados )
		
			// chamada da funcao de inclusão do INTERCAMBIO EVENTUAL - a função quadroIniEnvDiops() limpou os registros do periodo, se existiam
			If !IncIntEven(MODEL_OPERATION_INSERT, aDados[nVez] )
				aAdd( aErroDIOPS, '10' )	// Variavel Private proveniente do fonte PLSDIOPSPL.prw
				lRet	:= .F.
			EndIf
	
			// Destruir o objeto
			DelClassIntf()		
	
		Next
	
		// Função que informa a Central de Obrigações que o quadro do INTERCAMBIO EVENTUAL foi enviado.
		// quadroFimEnvDiops( cQuadro, cCodOpe, cAno, cRefere )
		quadroFimEnvDiops( '10', BA0->BA0_SUSEP, cAno, StrZero(Val(cTrimestre),2) )

	Else
		MsgAlert('Não foi possível inicializar o quadro Intercâmbio Eventual.')
		aAdd( aErroDIOPS, '10' )	// Variavel Private proveniente do fonte PLSDIOPSPL.prw
		lRet	:= .F.
			
	EndIf

Else
	MsgAlert('Não foram encontrados dados para exportação do quadro Intercâmbio Eventual.')
	aAdd( aErroDIOPS, '10' )	// Variavel Private proveniente do fonte PLSDIOPSPL.prw
	lRet	:= .F.
		
EndIf		
	
If Select(cArqTmp) > 0
	cArqTmp->(dbCloseArea())
	FErase(cArqTmp+GetDBExtension())
	FErase(cArqTmp+OrdBagExt())
EndIf

Return(lRet)

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} IncIntEven

Funcao inclui INTERCAMBIO EVENTUAL no nucleo de informacoes e obrigacoes

@param nOpcMVC	3-Incluir, 4-Alterar

@return lRet	Indica se concluiu .T. ou nao .F. a operacao

@author Roger C
@since 16/11/2017
/*/
//--------------------------------------------------------------------------------------------------
Static Function IncIntEven(nOpcMVC, aDados)
Local lRet := .T.
Default nOpcMVC	:= MODEL_OPERATION_INSERT

oModel	:= FWLoadModel( 'PLSMVCINEV' )
oModel:SetOperation( nOpcMVC )
oModel:Activate()
oModel:SetValue( 'B8UMASTER', 'B8U_FILIAL'	, xFilial('B8U') )
oModel:SetValue( 'B8UMASTER', 'B8U_CODOPE'	, BA0->BA0_SUSEP )
oModel:SetValue( 'B8UMASTER', 'B8U_CODOBR'	, "000" )
oModel:SetValue( 'B8UMASTER', 'B8U_ANOCMP'	, MV_PAR02 )
oModel:SetValue( 'B8UMASTER', 'B8U_CDCOMP'	, "000" )
oModel:SetValue( 'B8UMASTER', 'B8U_REFERE'	, STRZERO(Val(MV_PAR01), 2) )
oModel:SetValue( 'B8UMASTER', 'B8U_OPEINT'	, aDados[2] )		
oModel:SetValue( 'B8UMASTER', 'B8U_NOME'	, aDados[3] )
oModel:SetValue( 'B8UMASTER', 'B8U_VENCTO'	, aDados[4] )
oModel:SetValue( 'B8UMASTER', 'B8U_TIPCOB'	, aDados[5] )		// MEDICO/HOSPITALAR - Odonto
oModel:SetValue( 'B8UMASTER', 'B8U_SALDO'	, aDados[6] )
oModel:SetValue( 'B8UMASTER', 'B8U_TIPO'	, aDados[7] )		// Pagar - Receber - Faturar				
oModel:SetValue( 'B8UMASTER', 'B8U_STATUS'	, "1" )		
		
If oModel:VldData()
	oModel:CommitData()
Else
	aErro	:= oModel:GetErrorMessage()
	lRet	:= .F.
EndIf

oModel:DeActivate()
oModel:Destroy()
FreeObj(oModel)
oModel := Nil
		
Return lRet
