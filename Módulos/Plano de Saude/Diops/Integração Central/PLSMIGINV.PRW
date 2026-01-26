#include 'protheus.ch'
#include 'FWMVCDEF.CH' 
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSMIGINV

Funcao criada para migrar o quadro Ativos Garantidores - Investimentos para a central de obrigacoes 

@author	timoteo.bega
@since	27/11/2017
/*/
//--------------------------------------------------------------------------------------------------
Function PLSMIGINV( cTrimestre, cAno )
Local lRet		:= .T.
local aDados	:= {}
Local nVez		:= 0
Local dDataFim	:= CtOD('')
Local cRefere	:= ''
Local cCdComp	:= ''

dDataFim := LastDay( CtoD( IIf(cTrimestre=='1','31/03/'+cAno, IIf(cTrimestre=='2','30/06/'+cAno, IIf(cTrimestre=='3','30/09/'+cAno,'31/12/'+cAno) ) ) ) ) 

aDados:= PLSATGARIN(dDataFim, .F., MV_PAR04, .T.)		// Função está no fonte Plano de Saude/Diops/Relatorios/PLSDATVIN.prw

If aDados[1]
	
	// Posiciona Operadora
	BA0->(dbSetOrder(1))
	BA0->(dbSeek(xFilial('BA0')+PlsIntPad()))

	// Prepara indice para buscar Código da Obrigação
	B3A->(dbSetOrder(2))
	B3A->(dbSeek(xFilial('B3A')+BA0->BA0_SUSEP+'3'+'1'))		// Filial + Operadora + Código Fixo da DIOPS + Registro Ativo
	
	//Trimestre do compromisso
	cRefere	:= Str(val(cTrimestre))

	cCdComp := PLSEXICOM( BA0->BA0_SUSEP, B3A->B3A_CODIGO, cRefere, cAno )
	
	// Prepara indice para buscar Obrigação
	B3D->(dbSetOrder(1))
	B3D->(MsSeek(xFilial('B3D')+BA0->BA0_SUSEP+B3A->B3A_CODIGO+cAno+cCdComp,.F.))
	
	// Chama função que informa a Central de Obrigações que enviaremos o quadro
	If quadroIniEnvDiops( '17', BA0->BA0_SUSEP, cAno, cTrimestre, .T. )

		For nVez := 1 to Len( aDados[2] )
	
			If !IncAtGrInv(aDados[2][nVez],cAno,cTrimestre,cCdComp)
				aAdd( aErroDIOPS, '17' )	// Variavel Private proveniente do fonte PLSDIOPSPL.prw
				lRet	:= .F.
				Exit
			EndIf					
			
			DelClassInTf()
	
		Next nFor
	
		// FunÃ§Ã£o que informa a Central de ObrigaÃ§Ãµes que o quadro foi enviado.
		quadroFimEnvDiops( '17', BA0->BA0_SUSEP, cAno, cTrimestre )

	Else
		MsgAlert('Não foi possível inicializar o quadro Ativos Garantidores - Investimento.')
		aAdd( aErroDIOPS, '17' )	// Variavel Private proveniente do fonte PLSDIOPSPL.prw
		lRet	:= .F.
		
	EndIf

Else
	MsgAlert('Não foram encontrados dados para exportação do quadro Ativos Garantidores - Investimento.')
	aAdd( aErroDIOPS, '17' )	// Variavel Private proveniente do fonte PLSDIOPSPL.prw
	lRet	:= .F.

EndIf

Return( lRet )


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} IncAtGrInv

Funcao inclui balancete no nucleo de informacoes e obrigacoes

@param nOpcMVC	3-Incluir, 4-Alterar

@return lRet	Indica se concluiu .T. ou nao .F. a operacao

@author Roger C
@since 07/11/2017
/*/
//--------------------------------------------------------------------------------------------------
Static Function IncAtGrInv(aReg,cAno,cTrimestre,cCdComp)
Local lRet		:= .F.
Local aErro		:= {}

If Len(aReg) > 0

	oModel	:= FWLoadModel( 'PLSMVCINV' )
	oModel:SetOperation( MODEL_OPERATION_INSERT )
	oModel:Activate()

	oModel:SetValue( 'B8DMASTER', 'B8D_FILIAL'	, xFilial('B8D') )
	oModel:SetValue( 'B8DMASTER', 'B8D_CODOPE'	, BA0->BA0_SUSEP )
	oModel:SetValue( 'B8DMASTER', 'B8D_CODOBR'	, B3A->B3A_CODIGO )/*000*///X3_VALID ExistCpo("B3A",M->B8D_CODOPE+M->B8D_CODOBR+"3"+"1",1)
	oModel:SetValue( 'B8DMASTER', 'B8D_REFERE'	, StrZero(Val(cTrimestre),2) )
	oModel:SetValue( 'B8DMASTER', 'B8D_ANOCMP'	, cAno )
	oModel:SetValue( 'B8DMASTER', 'B8D_CDCOMP'	, cCdComp )/*000*///ExistCpo("B3D",M->B8D_CODOPE+M->B8D_CODOBR+M->B8D_ANOCMP+M->B8D_CDCOMP+"3",1)
	oModel:SetValue( 'B8DMASTER', 'B8D_TPCUST'	, IIf(Empty(aReg[01]),'3',aReg[01]) )
	oModel:SetValue( 'B8DMASTER', 'B8D_CODATI'	, aReg[02] )
	oModel:SetValue( 'B8DMASTER', 'B8D_DATEMI'	, aReg[03] )
	oModel:SetValue( 'B8DMASTER', 'B8D_DATVEN'	, aReg[04] )
	oModel:SetValue( 'B8DMASTER', 'B8D_OUTBEM'	, aReg[05] )
	oModel:SetValue( 'B8DMASTER', 'B8D_TIPBEM'	, aReg[06] )
	oModel:SetValue( 'B8DMASTER', 'B8D_QUANTI'	, aReg[07] )
	oModel:SetValue( 'B8DMASTER', 'B8D_VLRUNI'	, aReg[08] )
	oModel:SetValue( 'B8DMASTER', 'B8D_VLRCON'	, aReg[09] )
	oModel:SetValue( 'B8DMASTER', 'B8D_NOMEMI'	, aReg[10] )
	oModel:SetValue( 'B8DMASTER', 'B8D_CNPJEM'	, aReg[11] )
	oModel:SetValue( 'B8DMASTER', 'B8D_VINANS'	, aReg[12] )
	oModel:SetValue( 'B8DMASTER', 'B8D_VIGINI'	, aReg[03] )
	oModel:SetValue( 'B8DMASTER', 'B8D_VIGFIN'	, aReg[04] )
	oModel:SetValue( 'B8DMASTER', 'B8D_STATUS'	, "1" )

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
