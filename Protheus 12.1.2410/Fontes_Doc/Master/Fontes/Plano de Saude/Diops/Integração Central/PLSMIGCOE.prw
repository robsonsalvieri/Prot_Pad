#include 'protheus.ch'
#include 'FWMVCDEF.CH'
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSMIGCOE

Funcao de importacao do Contratos Estipulados do PLS para a Central de Obrigações


@author Roger C
@since 14/11/2017
/*/
//--------------------------------------------------------------------------------------------------
Function PLSMIGCOE( cTrimestre, cAno )

Local lRet			:= .T.
local aDados	    := {}
Local nVez			:= 0
Local nItem			:= 0

//aDados := PLDCONEST(cTrimestre,cAno)

If aDados[1]
	
	// Posiciona Operadora
	BA0->(dbSetOrder(1))
	BA0->(dbSeek(xFilial('BA0')+PlsIntPad()))

	// Chama função que informa a Central de Obrigações que enviaremos o Contratos Estipulados
	// quadroIniEnvDiops( cQuadro, cCodOpe, cAno, cRefere )
	If quadroIniEnvDiops( '7', BA0->BA0_SUSEP, cAno, cTrimestre, .T. )
	
		For nVez := 2 to Len( aDados )
	
			For nItem := 2 to Len(aDados[nVez])
			
				// chamada da funcao de inclusão do Contratos Estipulados - a função quadroIniEnvDiops() limpou os registros do periodo, se existiam
				If !IncConEst(MODEL_OPERATION_INSERT,aDados[nVez,1], aDados[nVez,nItem])
					aAdd( aErroDIOPS, '7' )	// Variavel Private proveniente do fonte PLSDIOPSPL.prw
					lRet	:= .F.
				EndIf					
				
				// Destruir o objeto
				DelClassIntf()		
			
			Next				    
		Next
	
		// Função que informa a Central de Obrigações que o quadro do Contratos Estipulados foi enviado.
		// quadroFimEnvDiops( cQuadro, cCodOpe, cAno, cRefere )
		quadroFimEnvDiops( '7', BA0->BA0_SUSEP, cAno, cTrimestre )

	Else
		MsgAlert('Não foi possível inicializar o quadro Contratos Estipulados.' )
		aAdd( aErroDIOPS, '7' )	// Variavel Private proveniente do fonte PLSDIOPSPL.prw
		lRet	:= .F.
			
	EndIf
	
Else
	MsgAlert('Não foram encontrados dados para exportação do quadro Contratos Estipulados.')
	aAdd( aErroDIOPS, '7' )	// Variavel Private proveniente do fonte PLSDIOPSPL.prw
	lRet	:= .F.
		
EndIf		

Return(lRet)


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} IncConEst

Funcao inclui Contratos Estipulados no nucleo de informacoes e obrigacoes

@param nOpcMVC	3-Incluir, 4-Alterar

@return lRet	Indica se concluiu .T. ou nao .F. a operacao

@author Roger C
@since 16/11/2017
/*/ 
//--------------------------------------------------------------------------------------------------
Static Function IncConEst(nOpcMVC, cPlano, aDados)
Local lRet := .F.
Default nOpcMVC	:= MODEL_OPERATION_INSERT
Default cPlano	:= '1'
Default aDados	:= {}

If !Empty(aDados)

	oModel	:= FWLoadModel( 'PLSMVCCOE' )
	oModel:SetOperation( MODEL_OPERATION_INSERT )
	oModel:Activate()
	oModel:SetValue( 'BUPMASTER', 'BUP_FILIAL'	, xFilial('BUP') )
	oModel:SetValue( 'BUPMASTER', 'BUP_CODOPE'	, BA0->BA0_SUSEP )
	oModel:SetValue( 'BUPMASTER', 'BUP_CODOBR'	, "000" )
	oModel:SetValue( 'BUPMASTER', 'BUP_ANOCMP'	, MV_PAR02 )
	oModel:SetValue( 'BUPMASTER', 'BUP_CDCOMP'	, "000" )
	oModel:SetValue( 'BUPMASTER', 'BUP_REFERE'	, StrZero(Val(MV_PAR01),2) )
	oModel:SetValue( 'BUPMASTER', 'BUP_OPECOE'	, aDados[1] )
	oModel:SetValue( 'BUPMASTER', 'BUP_VLRFAT'	, aDados[2] )
	oModel:SetValue( 'BUPMASTER', 'BUP_STATUS'	, "1" )
			
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

