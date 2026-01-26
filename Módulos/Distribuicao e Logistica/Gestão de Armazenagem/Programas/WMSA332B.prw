#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "WMSA332B.CH"
#define WMSA322B01 "WMSA322B01"

//-----------------------------------------------------
/*/{Protheus.doc} WMSA332B
Apontamento de movimentação
@author Amanda Rosa Vieira
@since 25/05/2015
@version 1.0
/*/
//-----------------------------------------------------
Function WMSA332B()
Local aAreaD12  := D12->(GetArea())
Local lRet      := .T.
Local cAliasD12 := GetNextAlias()
Local lRetPE    := .T.

	// Permite efetuar validações, apresentar mensagem e abortar o programa quando desejado
	If !WMSChkPrg(FunName(),"1")
		Return Nil
	EndIf
	If Pergunte('WMSA332B',,,.T.)
		// Verifica se existem atividades com o mapa de separação para serem executadas
		BeginSql Alias cAliasD12
			SELECT D12.R_E_C_N_O_ D12RECNO
			FROM %Table:D12% D12
			WHERE D12.D12_FILIAL = %xFilial:D12%
			AND D12.D12_MAPSEP = %Exp:MV_PAR01%
			AND D12.D12_STATUS IN ('2','3','4')
			AND D12.%NotDel%
		EndSql
		If (cAliasD12)->(!EoF())
			D12->(dbGoTo((cAliasD12)->D12RECNO))
			// Ponto de Entrada WMSA332BVM - permite executar validações antes da execução.
			If ExistBlock( "WMSA332BVM" )
				lRetPE := ExecBlock( "WMSA332BVM", .F., .F., {MV_PAR01})
				If ValType(lRetPE) == 'L'
					lRet := lRetPE
				EndIf
			EndIf
			If lRet
				//Grava opções selecionadas
				WmsOpc332("5")
				WmsAcao332("0")
				Processa( {|| ProcRegua(0), FWExecView(STR0001,"WMSA332A", MODEL_OPERATION_UPDATE ,, { || .T. } ,, ) } , STR0002, STR0003 + '...', .F.) //"Apontar Movimentação"##"Carregando tela de confirmação"
			EndIf
		Else
			WmsMessage(STR0004,WMSA322B01,1,,,STR0005) // "O mapa informado não existe ou não possuí atividades pendentes para finalização." //Informe um mapa de separação válido que possua atividades pendentes de execução.
		EndIf
	EndIf
	RestArea(aAreaD12)
Return