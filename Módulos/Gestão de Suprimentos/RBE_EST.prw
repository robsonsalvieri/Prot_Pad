#include 'protheus.ch'
#INCLUDE "FWLIBVERSION.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} RBE_EST
Funções de compatibilização e/ou conversão de dados para as tabelas do sistema.
@param cVersion   - Versão do Protheus
@param cMode      - Modo de execução   - "1" = Por grupo de empresas / "2" = Por grupo de empresas + filial (filial completa)
@param cRelStart  - Release de partida - (Este seria o Release no qual o cliente está)
@param cRelFinish - Release de chegada - (Este seria o Release ao final da atualização)
@param cLocaliz   - Localização (país) - Ex. "BRA"
@Return lRet
@author Fabio José Batista
@since 07/02/24
@version P12
/*/
//-------------------------------------------------------------------
Function RBE_EST( cVersion as Char, cMode as Char, cRelStart as Char, cRelFinish as Char, cLocaliz as Char )
	
	Local lRet    as Logical

	Default cVersion   := ''
	Default cMode      := ''
	Default cRelStart  := ''
	Default cRelFinish := ''
	Default cLocaliz   := ''

	lRet := .T.

	If cMode == '1'  // Nivel do grupo de empresas

		//--------------------------------------------------------------
		//- Avalia ajuste do grupo de campos 171 Descrição do Produto
		//- Será avaliado da release de saída cliente para qualquer
		//- release final.
		//--------------------------------------------------------------
		If cRelStart < '2410' .AND. cRelFinish >= '2410'
			lRet := totvs.pt.engineering.update.preprocess.RBESXG( '171',cRelStart, cRelFinish)
			lRet := UpdSXG170()
		EndIf

	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} UpdSXG170
Avalia ajuste do grupo de campos 170 Número de Série de Produto    
@author Fabio José Batista
@since 21/02/24
@version P12
/*/
//-------------------------------------------------------------------
Static Function UpdSXG170() As Logical
	Local aArea       As Array
	Local cQry      As Character
	Local nTamAjuste  As Numeric
	Local nTamMaxGrp  As Numeric
	Local nTamMinGrp  As Numeric
	Local nTamPadGrp  As Numeric
	Local __oQry

	aArea := GetArea()

	cQry := "SELECT MAX( X3_TAMANHO ) TAMMAX FROM SX3"+ cEmpAnt + "0 "
	cQry += " WHERE D_E_L_E_T_ =  ' ' "
	cQry += "   AND X3_CAMPO IN ( ? ) " 
	cQry += "   AND X3_CONTEXT <> 'V' "

	cQry := ChangeQuery(cQry)
	
	__oQry := FwExecStatement():New(cQry)
	
	__oQry:SetIn(1,{'NNT_NSERIE','B7_NUMSERI','BF_NUMSERI','BK_NUMSERI','D3_NUMSERI','D7_NUMSERI','DA_NUMSERI','DB_NUMSERI','DC_NUMSERI','DD_NUMSERI'})

	nTamAjuste := __oQry:ExecScalar('TAMMAX')

	// Informações do Grupo
	nTamPadGrp  :=  20  // Tamanho Default do Grupo
	nTamMinGrp  :=  20  // Tamanho Mnimo do Grupo
	nTamMaxGrp  :=  40  // Tamanho Máximo do Grupo

	// Verifica se está nos limites
	nTamAjuste  := Max( nTamAjuste, nTamMinGrp )
	nTamAjuste  := Min( nTamAjuste, nTamMaxGrp )

	DbSelectArea( 'SXG' )
	DbSetOrder( 1 )

	If !SXG->( DbSeek('170') ) .AND. nTamAjuste <> nTamPadGrp
		RecLock('SXG', .T.)
		SXG->XG_GRUPO   := '170'
		SXG->XG_DESCRI  := 'Número de Série de Produto    '    
		SXG->XG_DESSPA  := 'Número de Serie del Producto  '    
		SXG->XG_DESENG  := 'Product Serial Number         '    
		SXG->XG_SIZE    := nTamAjuste
		SXG->XG_SIZEMIN := nTamMinGrp
		SXG->XG_SIZEMAX := nTamMaxGrp
		SXG->( MsUnlock() )
	EndIf

	RestArea( aArea )

	FwFreeArray( aArea )

Return .T.
