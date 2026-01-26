#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} STWTotDisc
Function Desconto no Total da Venda

@param   nValDesc			Valor do Desconto
@param   cType				Tipo do Desconto. Se P - Percentual ou V - Valor.
@param   cOrigin			Define a procedência do desconto
@author  Varejo
@version P11.8
@since   29/03/2012
@return  lRet 				Retorna se efetuou desconto no total
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STWTotDisc( nValDesc , cType , cOrigin , lAccumulate, aDescOrc)

Local		lRet			:= .T.						// Retorno se efetuou desconto

Default		nValDesc		:= 0						// Valor do desconto
Default		cType			:= ""						// Tipo do Desconto. Se P - Percentual ou V - Valor.
Default		cOrigin			:= ""						// Define a procedência do desconto
Default		lAccumulate		:= .F.						// Acumula com descontos anteriores
Default		aDescOrc		:= {0,0}					// Desconto no orçamento (Caso Exista)

ParamType 0 Var nValDesc  AS Numeric	Default 0
ParamType 1 Var cType	  AS Character	Default ""
ParamType 2 Var cOrigin   AS Character	Default ""

If lRet
	lRet := STBValDisc( nValDesc + Iif(cType == "V",aDescOrc[1],aDescOrc[2]) , cType , cOrigin, aDescOrc) // Valida o valor do desconto
EndIf

// TODO: Zerar descontos ao dar esc na tela pois o desconto sendo concomitante ja foi pra impressora
// If nVlrDesc > 0 .AND. LjAnalisaLeg(14)[1] 
// analisaleg(22) verificar se eh a mesma coisa!!!!

If lRet
	STBTotDiscApply(  nValDesc , cType , cOrigin , lAccumulate )

	// Indica que foi concedido Desconto no Total da Venda pelo PDV
	STBSetDiscTotPDV(.T.)
	
	/*
	Se um desconto no total for aplicado, o Caixa poderá alterar as parcelas, 
	já que o valor da Venda foi alterado
	*/
	If FindFunction("STIGetPayRO") .AND. STIGetPayRO()
		STISetPayRO(-1)	//permite editar os pagamzentos
	EndIf
EndIf

STFShowMessage("TotDesc")	
	
Return lRet