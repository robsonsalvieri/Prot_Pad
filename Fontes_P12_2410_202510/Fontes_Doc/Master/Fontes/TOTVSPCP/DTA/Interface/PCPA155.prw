#Include "TOTVS.CH"
#Include "PCPA155.CH"

/*/{Protheus.doc} PCPA155
Rotina de manutenção do catálogo do DTA

@type  Function
@author lucas.franca / renan.roeder
@since 07/03/2025
@version P12
@return Nil
/*/
Function PCPA155()

	If !AliasInDic("HZV")
		Help(' ', 1,"Help" ,, STR0001, 1, 1, , , , , , {STR0002}) //"Dicionário de dados desatualizado." # "As tabelas necessárias para utilização do DTA não estão presentes no sistema. Atualize o ambiente para utilizar esta rotina."
		Return Nil
	EndIf
	If CmpBuildStr(GetSrvVersion(), "24.3.0.5") < 0
		Help(' ', 1,"Help" ,, I18N(STR0073, {GetSrvVersion()}), 1, 1, , , , , , {STR0074}) //"Versão #1[version]# do AppServer não homologada para utilização do DTA." # "Atualize o AppServer para uma versão igual ou superior à 24.3.0.5 para utilizar o DTA."
		Return Nil
	EndIf
	If PCPVldApp()
		DTAUtils():initializeTables()
		FWMsgRun(, {|| updTools() }, , STR0003) //"Atualizando ferramentas..."
		FwCallApp('dta-tool-catalog')
	EndIf
Return

/*/{Protheus.doc} updTools
Executa a atualização das ferramentas

@type  Static Function
@author lucas.franca / renan.roeder
@since 07/03/2025
@version P12
@return Nil
/*/
Static Function updTools()
	Local aErrors := {}

	If DTAParameters():loadDefaultParameters()
		aErrors := DTALoad():loadDefaultTools()
		If !Empty(aErrors)
			DTALoad():showErrors(aErrors)
		EndIf
	EndIf
Return
