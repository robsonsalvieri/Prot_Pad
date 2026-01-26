#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "VEIA180.CH"

/*/{Protheus.doc} VEIA181()
Conhecimento de Frete (Mercado Internacional) - Chamadas do MATA101N 

@author Andre Luis Almeida
@since 21/08/2024
@version 1.0
@return NIL
/*/
Function VEIA181()
Private cCadastro := STR0001 // Conhecimento de Frete
If cPaisLoc <> "BRA"
	nModulo := 2
	SetFunName("MATA101N")
	LocxNf(14,,,3,"MATA101N",,,) // Mercado Internacional - Browse do Conhecimento de Frete
	SetKey(VK_F4	,{|| Nil })
	SetKey(VK_F5	,{|| Nil })
	SetKey(VK_F6	,{|| Nil })
	SetKey(VK_F7	,{|| Nil })
	SetKey(VK_F8	,{|| Nil })
	SetKey(VK_F9	,{|| Nil })
	SetKey(VK_F10	,{|| Nil })
	SetKey(VK_F11	,{|| Nil })
	SetKey(VK_F12	,{|| Nil })
	nModulo := 11
	SetFunName("VEIA180")
EndIf
Return NIL

/*/{Protheus.doc} VA1810011_GravaNfGeral
Chamada da Funcao GravaNfGeral - Mercado Internacional

@author Andre Luis Almeida
@since 21/08/2024
@version 1.0
/*/
Function VA1810011_GravaNfGeral( nTipo , cAliasFat , nRecFat , aRecsSF1 )
Local cTRACPA := ""
If nTipo == 14 // 14 = Conhecimento de Frete (F1_TIPODOC)
	If VA1800091_NF_Veiculo( nRecFat ) // Verifica se a NF de Entrada corresponde a Veiculos/Maquinas
		cTRACPA := VA1800041_Incluir_VVF( nRecFat ) // Incluir VVF
		VA1800051_Atualiza_VVG( nRecFat , cTRACPA , aRecsSF1 ) // Atualiza VVF/VVG relacionados
		VA1800061_Parcelas_VS9( .t. , cTRACPA ) // .T. = Incluir VS9
	EndIf
EndIf
Return .t.

/*/{Protheus.doc} VA1810021_LocxDelNF
Chamada da Funcao LocxDelNF - Mercado Internacional

@author Andre Luis Almeida
@since 22/08/2024
@version 1.0
/*/
Function VA1810021_LocxDelNF( cAliasFat , nRecFat )
If cAliasFat == "SF1" // Entrada
	If VA1800091_NF_Veiculo( nRecFat , .t. ) .and. VA1800101_ValidarA116Inclui( 5 , nRecFat , {} ) // Verifica se a NF de Entrada corresponde a Veiculos/Maquinas
		VA1800071_Cancelar_VVFVVG( nRecFat )
	EndIf
EndIf
Return .t.

/*/{Protheus.doc} VA1810031_Filtro_Browse
Filtro do Browse na rotina LOCXNF - Mercado Internacional

@author Andre Luis Almeida
@since 23/09/2024
@version 1.0
/*/
Function VA1810031_Filtro_Browse(cFilD1D2,cFilSQL)
If FM_PILHA("VEIA181") // VEIA181 - Chamada pela rotina de Conhecimento de Frete para todos os PAISES diferente do BRASIL
	cFilD1D2 := "F1_TIPODOC = '14'" // Variavel utilizada para Filtro do Browse - Filtrar somente NOTAS DE FRETE
	cFilSQL  := "F1_TIPODOC = '14'" // Variavel utilizada para Filtro do Browse - Filtrar somente NOTAS DE FRETE
EndIf
Return