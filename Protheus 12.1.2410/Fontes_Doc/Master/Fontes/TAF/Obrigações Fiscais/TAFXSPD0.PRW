#Include 'Protheus.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} TafxSpd0

Realiza a Geracao do Bloco 0 do Sped Fiscal

@Param	aWizard	->	 Wizard de geracao do Arquivo
		cFilSel	->	Variavel com as Filiais escolhidas pelo Usuario
		lConv115   -> Indica se faz parte do convenio 115 do ICMS
		cPerfilSPD -> Indica qual o perfil do contribuinte
		cTabSped   -> Alias da tabela de geração das informações
		cJobAux    -> Nome da variavel responsavel pelo controle de termino do Bloco - Mult Thread

@Return ( Nil )

@Author Rodrigo Aguilar
@Since 14/02/2013
@Version 1.0
/*/
//-------------------------------------------------------------------
Function TafxSpd0( aWizard, cFilSel, lConv115, cPerfilSPD, cTabSped, cJobAux )

	//Mensagem adicionada em 21/03/2025				                   
	MsgInfo("Prezado cliente, a geração do SPED Fiscal pelo TAF foi descontinuado - Bloco 0.")


Return ( Nil )
