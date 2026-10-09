#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} GtpjGerTit
Fila de geração dos títulos de receita e despesas
@author flavio.martins
@since 12/04/2026
@version 1.00
/*/
//-------------------------------------------------------------------
Function GTPA703()
Local oBrowse := Nil	

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('H8C')
oBrowse:SetDescription("Fila de Geração de Títulos") 
oBrowse:Activate()
	
Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Definições do menu
@author flavio.martins
@since 12/04/2026
@version 1.00
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}
	
ADD OPTION aRotina TITLE "Processar Fila"   ACTION 'G703GerTit()'  OPERATION 9 ACCESS 0 // "Processar Fila"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} G703GerTit
Função que faz a chamada da rotina de geração de títulos
@author flavio.martins
@since 12/04/2026
@version 1.00
/*/
//-------------------------------------------------------------------
Function G703GerTit()
Local aParam := {}

If FindFunction('GTPJGERTIT')
    FwMsgRun( , {|oSelf| lRet := GTPJGERTIT(aParam, oSelf)}, , "Processando fila de geração de títulos... Aguarde!")
Else
    FwAlertWarning("Rotina de geração de títulos não encontrada. Verifique se a rotina GTPJGERTIT está presente e atualizada.")
Endif

Return
