#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"   
#INCLUDE "STWMULTIMEDIAREGISTER.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} STBMultimediaRegister
Function registro Multi-Media

@param cCodMedia  Codigo da midia
@param lShowScreen	Mostra tela
@author  Varejo
@version P11.8
@since   29/03/2012
@return   lRet					Retorna se registrou a midia
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STWMultimediaRegister( cCodMedia , lShowScreen )

Local lRet				:= .F.				// Retorna se registrou a midia
Local cMultimidia 		:= ""				// Armazena consulta do parâmetro

Default cCodMedia		:= ""
Default lShowScreen		:= .T.

ParamType 0 Var cCodMedia	AS Character	Default ""
ParamType 1 Var lShowScreen	AS Logical		Default .T.

/*/
	0 - Nao utiliza
	1 - Usa registro de Midia com preenchimento opcional.
	2 - Usa registro de Midia com preenchimento obrigatorio.
/*/
cMultimidia := AllTrim(Str(SuperGetMv("MV_LJRGMID",,0)))

Do Case

	Case cMultimidia == "0" // Nao utiliza
		
		lRet := .T.
		
		If lShowScreen
			STFMessage("STWMultimediaRegister","ALERT",STR0001) //"Não utiliza Registro de Midia. para utilizar habilitar o parâmetro MV_LJRGMID"			
		EndIf
	
	Case cMultimidia == "1" // Opcional

		If !Empty(cCodMedia)			
			lRet := STBMRSetMedia(cCodMedia)			
		Else			
			lRet := .T.				
		EndIf
		
	Case cMultimidia == "2" // Obrigatório
			
		If !Empty(cCodMedia)						
			lRet := STBMRSetMedia(cCodMedia)			
		Else
		
			/*/
				Caso venha vazio e for obrigatorio, ver se ja foi registrado, senao chama tela
			/*/
		
			lIsRegistered := STBMRIsRegistered()
			
			If lShowScreen		
				cCodMedia := "000001" // STIMultimediaRegister() // TODO: Get da Tela de registro multimidia
				lRet := STBMRSetMedia(cCodMedia)		
			EndIf
		
			If !lIsRegistered
			
				cCodMedia := "000001" // STIMultimediaRegister( lObrigatório ) // TODO: Get da Tela de registro multimidia, Obrigatório, nao sair da tela enquanto nao informar
				lRet := STBMRSetMedia(cCodMedia)
				
			Else			
				lRet := .T.				
			EndIf

		EndIf
		
EndCase
				
STFShowMessage("STWMultimediaRegister")				
				
Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STWMRIniVal
Verifica as configurações do Registro Multi-Media na inicialização do sistema

@param 
@author  Varejo
@version P11.8
@since   29/03/2012
@return  lRet					Retorna se a configuracao de registro de midia é válida
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STWMRIniVal()

Local lRet := .T.		// Retorno da funcao

If STBMRObrigat() 		// Verifia se o registro de mìdia é obrigatório

	/*/
		Sendo obrigatorio, verifica se existem registros válidos
	/*/	
	lRet := STDMRValid()
	
	If !lRet 
		//"O parametro MV_LJRGMID esta com o preenchimento obrigatorio 
		// porem nao existem midias cadastradas, favor regularizar."
		STFMessage("STWMultimediaRegister","ALERT",STR0002)		 
	EndIf	  	
	
EndIf 

STFShowMessage("STWMultimediaRegister")	

Return lRet