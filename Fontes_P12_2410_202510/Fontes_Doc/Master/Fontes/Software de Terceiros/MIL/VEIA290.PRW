#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} VEIA290
	Fonte para tratar/carregar VARIAVEIS utilizadas em funções de Impostos do Mercado Internacional

	@author Andre Luis Almeida
	@since 06/12/2024
/*/

/*/{Protheus.doc} VA2900011_M460xIBP_ObtAcum
Retorna o Cliente e a Loja para a Função ObtAcum do M460xIBP.PRX

@author Andre Luis Almeida
@since 06/12/2024
/*/
Function VA2900011_M460xIBP_ObtAcum(cCliente,cLoja)
Local aRetDMS := {cCliente,cLoja}
Do Case
	Case IsInCallStack("VEIXX001")
		aRetDMS[1] := M->VV0_CODCLI
		aRetDMS[2] := M->VV0_LOJA
	Case IsInCallStack("VEIXX002")
		aRetDMS[1] := M->VV9_CODCLI
		aRetDMS[2] := M->VV9_LOJA
	Case IsInCallStack("OFIXX100")
		aRetDMS[1] := M->VOO_FATPAR
		aRetDMS[2] := M->VOO_LOJA
	Case IsInCallStack("OFIXX001")
		aRetDMS[1] := M->VS1_CLIFAT
		aRetDMS[2] := M->VS1_LOJA
EndCase
Return aRetDMS

/*/{Protheus.doc} VA2900021_M460xIBP_M100RLIM
Retorna se esta executando pela rotina do DMS e o TES para ser utilizado na Função M100RLIM do M460xIBP.PRX

@author Andre Luis Almeida
@since 06/12/2024
/*/
Function VA2900021_M460xIBP_M100RLIM()
Local aRetDMS := {.f.,""}
Do Case
	Case IsInCallStack("VEIXX001") .or. IsInCallStack("VEIXX002")
		aRetDMS[1] := .t.
		aRetDMS[2] := M->VVA_CODTES
	Case IsInCallStack("OFIXX100")
		aRetDMS[1] := .t.
		aRetDMS[2] := M->VO3_CODTES
	Case IsInCallStack("OFIXX001")
		aRetDMS[1] := .t.
		aRetDMS[2] := M->VS3_CODTES
EndCase
Return aRetDMS

/*/{Protheus.doc} VA2900031_M460xIBP
Retorna o cAlias e cTipo para a Função principal do M460xIBP.PRX

@author Andre Luis Almeida
@since 11/12/2024
/*/
Function VA2900031_M460xIBP(cAlias,cTipo)
Local aRetDMS := {cAlias,cTipo}
If	IsInCallStack("VEIXX001") .or.;
	IsInCallStack("VEIXX002") .or.;
	IsInCallStack("OFIXX100") .or.;
	IsInCallStack("OFIXX001")
	aRetDMS[1] := "SF2" // cAlias
	aRetDMS[2] := "NF"  // cTipo
EndIf
Return aRetDMS

/*/{Protheus.doc} VA2900041_M460xIB2
Retorna o cAlias e cTipo para a Função principal do M460xIB2.PRX

@author Andre Luis Almeida
@since 11/12/2024
/*/
Function VA2900041_M460xIB2(cAlias,cTipo)
Local aRetDMS := {cAlias,cTipo}
If	IsInCallStack("VEIXX001") .or.;
	IsInCallStack("VEIXX002") .or.;
	IsInCallStack("OFIXX100") .or.;
	IsInCallStack("OFIXX001")
	aRetDMS[1] := "SF2" // cAlias
	aRetDMS[2] := "NF"  // cTipo
EndIf
Return aRetDMS

/*/{Protheus.doc} VA2900051_M460xIBP_ActStaFeIBK
Retorna se esta acessando via rotinas do DMS

@author Andre Luis Almeida
@since 30/12/2024
/*/
Function VA2900051_M460xIBP_ActStaFeIBK()
Local lRet := .f.
If	IsInCallStack("VEIXX001") .or.;
	IsInCallStack("VEIXX002") .or.;
	IsInCallStack("OFIXX100") .or.;
	IsInCallStack("OFIXX001")
	lRet := .t.
EndIf
Return lRet