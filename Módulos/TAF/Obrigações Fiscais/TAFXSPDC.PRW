#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TafxSpdC

Realiza a Geracao do Bloco C do Sped Fiscal

@param	aWizard	 ->	Wizard de geracao do Arquivo
		cFilSel	 ->	Variavel com as Filiais escolhidas pelo Usuario
		lConv115    -> Informa se a empresa se Enquadra no Convenio
		cPerfilSPD  -> Indica qual o perfil do contribuinte
		cJobAux     -> Nome da variavel responsavel pelo controle de termino do Bloco - Mult Thread
		
@return aTotRegC

@author Rodrigo Aguilar
@since 14/02/2013
@version 1.0
/*/
//------------------------------------------------------------------
Function TafxSpdC( aWizard, cFilSel, lConv115, cPerfilSPD, cTabSped, cJobAux ) 

	//Mensagem adicionada em 21/03/2025				                   
	MsgInfo("Prezado cliente, a geração do SPED Fiscal pelo TAF foi descontinuado - Bloco C.")
			
Return ( Nil )              
