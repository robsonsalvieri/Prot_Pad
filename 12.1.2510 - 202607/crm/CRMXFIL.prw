#INCLUDE "PROTHEUS.CH"
#INCLUDE "CRMXFIL.CH"

//-------------------------------------------------------------------
/*{Protheus.doc} CRMXFilSA1
Filtro da consulta padrão SA1EN2 (Cliente de entrega)

@author  Jorge Martins | Protheus Retail
@since   03/06/2026
@version 1.0
*/
//-------------------------------------------------------------------
Function CRMXFilSA1()
	Local cFiltro as Character
	Local cCGC    as Character

	cFiltro := "@#@#"

	cCGC := CRMInfoCli()[1] // Obtem CGC do cliente principal selecionado
	cCGC := PadR(AllTrim(cCGC), TamSX3("A1_CGC")[1])
	
	If !Empty(cCGC)
		cFiltro := "@#SA1->A1_FILIAL == '" + xFilial("SA1") + "' .And. SA1->A1_CGC == '" + cCGC + "'@#" // Cliente principal e endereços de entrega do mesmo cliente
	EndIf

Return cFiltro

//-------------------------------------------------------------------
/*{Protheus.doc} CRMXConSA1
Consulta específica para o campo de cliente de entrega.

Função da consulta específica SA1ENT

@author  Jorge Martins | Protheus Retail
@since   03/06/2026
@version 1.0
@return  lRet, Logical, Indica se a consulta foi realizada com sucesso
*/
//-------------------------------------------------------------------
Function CRMXConSA1()
	Local lEntrega  as Logical
	Local lRet      as Logical
	Local aInfoCli  as Array
	Local cConsulta as Character
	Local cCGC      as Character
	Local cNomeCli  as Character
	Local cTipoP    as Character

	lEntrega  := .F.
	cConsulta := ""
	aInfoCli  := CRMInfoCli() // Obtem CGC, nome e tipo do cliente principal selecionado
	cCGC      := aInfoCli[1] // Obtem CGC do cliente principal selecionado
	cNomeCli  := aInfoCli[2] // Obtem nome do cliente principal selecionado
	cTipoP    := aInfoCli[3] // Obtem tipo (Fisica/Juridica) do cliente principal selecionado

	If !Empty(cCGC) .And. cTipoP == "F" // Se for cliente do tipo físico, pergunta se deseja consultar apenas os endereços de entrega do cliente
		lEntrega := ApMsgYesNo(I18n(STR0001, {AllTrim(cNomeCli)})) // "Deseja consultar apenas os endereços do cliente '#1'?"
	EndIf

	If lEntrega
		cConsulta := "SA1EN2" // Consulta clientes de entrega
	Else
		cConsulta := "SA1" // Consulta todos os clientes
	EndIf

	lRet := ConPad1(,,, cConsulta)

	VAR_IXB := {}

	If lRet
		aadd(VAR_IXB, SA1->A1_COD)
		aadd(VAR_IXB, SA1->A1_LOJA)
	EndIf

Return lRet

//-------------------------------------------------------------------
/*{Protheus.doc} CRMInfoCli
Função para obter informações do cliente, como CGC (CNPJ/CPF) 
e nome do cliente selecionado no momento da consulta.

@author  Jorge Martins | Protheus Retail
@since   03/06/2026
@version 1.0
@return  aInfoCli, Array, Valores do cliente selecionado (CGC, nome e tipo)
*/
//-------------------------------------------------------------------
Static Function CRMInfoCli()
	Local aCliente as Array
	Local cCampo   as Character
	Local cCGC     as Character
	Local cNomeCli as Character
	Local cTipoP   as Character
	Local aAreaSA1 as Array
	Local aInfoCli as Array

	aCliente := {"", ""} // Código e loja do cliente
	cCampo   := AllTrim(ReadVar())
	cCGC     := ""
	cNomeCli := ""
	cTipoP   := ""

	If !Empty(cCampo)
		Do Case 
			Case "C5_CLIENT" $ cCampo
				aCliente := {M->C5_CLIENTE, M->C5_LOJACLI}
		End Case
	EndIf

	If !Empty(aCliente[1]) .And. !Empty(aCliente[2])
		aAreaSA1 := SA1->(GetArea())
		SA1->(dbSetOrder(1))
		If SA1->(MsSeek(xFilial("SA1") + aCliente[1] + aCliente[2]))
			cCGC     := SA1->A1_CGC
			cNomeCli := SA1->A1_NOME
			cTipoP   := SA1->A1_PESSOA
		EndIf
		RestArea(aAreaSA1)
	EndIf

	aInfoCli := {cCGC, cNomeCli, cTipoP}

Return aInfoCli
