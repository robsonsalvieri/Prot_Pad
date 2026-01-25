#Include "protheus.ch"

// Função para validar o T9_STATUS
// É chamado na rotina MNTA080
// Frank Z Fuga em 10/08/23

Function LOCM010
Local aRetRental := {.t.,""}
    aRetRental := LOCA070()
return aRetRental
