#Include "Totvs.ch"  
#Include "WMSDTCClienteEnderecoBlocado.ch"
//---------------------------------------------
/*/{Protheus.doc} WMSCLS0047
Função para permitir que a classe seja visualizada
no inspetor de objetos 
@author Inovação WMS
@since 16/12/2016
@version 1.0
/*/
//---------------------------------------------
Function WMSCLS0047()
Return Nil
//------------------------------------------------
/*/{Protheus.doc} WMSDTCClienteEnderecoBlocado
Classe Cliente x endereço blocado
@author Inovação WMS
@since 16/12/2016
@version 1.0
/*/
//------------------------------------------------
CLASS WMSDTCClienteEnderecoBlocado FROM LongNameClass
	// Data
	DATA cCliente
	DATA cLoja
	DATA cLocal
	DATA cEndereco
	DATA nRecno
	DATA cErro
	// Controle dados anteriores
	DATA cClienteAnt
	DATA cLojaAnt
	DATA cLocalAnt
	// Mehotd
	METHOD New() CONSTRUCTOR
	METHOD LoadData(nIndex)
	// Setters
	METHOD SetCliente(cCliente)
	METHOD SetLoja(cLoja)
	METHOD SetLocal(cLocal)
	// Getters
	METHOD GetCliente()
	METHOD GetLoja()
	METHOD GetLocal()
	METHOD GetEnder()
	METHOD GetErro()
	METHOD Destroy()
ENDCLASS
//------------------------------------------------
/*/{Protheus.doc} New
Método contrutor
@author felipe.m
@since 23/12/2014
@version 1.0
/*/
//------------------------------------------------
METHOD New() CLASS WMSDTCClienteEnderecoBlocado
	Self:cCliente    := PadR("",TamSx3("D10_CLIENTE")[1])
	Self:cLoja       := PadR("",TamSx3("D10_LOJA")[1])
	Self:cLocal      := PadR("",TamSx3("D10_LOCAL")[1])
	Self:cClienteAnt := PadR("",Len(Self:cCliente))
	Self:cLojaAnt    := PadR("",Len(Self:cLoja))
	Self:cLocalAnt   := PadR("",Len(Self:cLocal))
	Self:cEndereco   := PadR("",TamSx3("D10_ENDER")[1])
	Self:cErro       := ""
	Self:nRecno      := 0
Return

METHOD Destroy() CLASS WMSDTCClienteEnderecoBlocado
//Mantido para compatibilidade
Return

//------------------------------------------------
/*/{Protheus.doc} LoadData
Carregamento dos dados D10
@author felipe.m
@since 23/12/2014
@version 1.0
@param nIndex, numérico, (Descrição do parâmetro)
/*/
//------------------------------------------------
METHOD LoadData(nIndex) CLASS WMSDTCClienteEnderecoBlocado
Local lRet      := .T.
Local lCarrega  := .T. 
Local aAreaAnt  := GetArea()
Local aAreaD10  := D10->(GetArea())
Local cAliasD10 := Nil
Default nIndex  := 1
	Do Case
		Case nIndex == 1 // D10_FILIAL+D10_CLIENT+D10_LOJA+D10_LOCAL
			If (Empty(Self:cCliente) .OR. Empty(Self:cLoja) .OR. Empty(Self:cLocal))
				lRet := .F.
			Else
				If Self:cCliente == Self:cClienteAnt .And. Self:cLoja == Self:cLojaAnt .And. Self:cLocal == Self:cLocalAnt
					lCarrega := .F.
				EndIf
			EndIf
		Otherwise
			lRet := .F.
	EndCase	
	If !lRet
		Self:cErro := STR0001 // Dados para busca não foram informados!
	Else
		If lCarrega
			cAliasD10:= GetNextAlias()
			Do Case
				Case nIndex == 1
					BeginSQl Alias cAliasD10
						SELECT D10.D10_CLIENT,
								D10.D10_LOJA,
								D10.D10_LOCAL,
								D10.D10_ENDER,
								D10.R_E_C_N_O_ RECNOD10
						FROM %Table:D10% D10
						WHERE D10.D10_FILIAL = %xFilial:D10%
						AND D10.D10_CLIENT = %Exp:Self:cCliente%
						AND D10.D10_LOJA = %Exp:Self:cLoja%
						AND D10.D10_LOCAL = %Exp:Self:cLocal%
						AND D10.%NotDel%
					EndSql
			EndCase
			If (lRet := (cAliasD10)->(!Eof()))
				Self:cCliente    := (cAliasD10)->D10_CLIENT
				Self:cLoja       := (cAliasD10)->D10_LOJA
				Self:cLocal      := (cAliasD10)->D10_LOCAL
				Self:cEndereco   := (cAliasD10)->D10_ENDER
				Self:nRecno      := (cAliasD10)->RECNOD10
				// Controle dados anteriores
				Self:cClienteAnt := Self:cCliente
				Self:cLojaAnt    := Self:cLoja
				Self:cLocalAnt   := Self:cLocal  
			EndIf
			(cAliasD10)->(dbCloseArea())
		EndIf
	EndIf
	RestArea(aAreaD10)
	RestArea(aAreaAnt)
Return lRet
//-----------------------------------------------
// Setters
//-----------------------------------------------
METHOD SetCliente(cCliente) CLASS WMSDTCClienteEnderecoBlocado
	Self:cCliente := PadR(cCliente, Len(Self:cCliente))
Return 

METHOD SetLoja(cLoja) CLASS WMSDTCClienteEnderecoBlocado
	Self:cLoja := PadR(cLoja, Len(Self:cLoja))
Return 

METHOD SetLocal(cLocal) CLASS WMSDTCClienteEnderecoBlocado
	Self:cLocal := PadR(cLocal, Len(Self:cLocal))
Return 
//-----------------------------------------------
// Getters
//-----------------------------------------------
METHOD GetCliente() CLASS WMSDTCClienteEnderecoBlocado
Return Self:cCliente

METHOD GetLoja() CLASS WMSDTCClienteEnderecoBlocado
Return Self:cLoja

METHOD GetLocal() CLASS WMSDTCClienteEnderecoBlocado
Return Self:cLocal

METHOD GetEnder() CLASS WMSDTCClienteEnderecoBlocado
Return Self:cEndereco

METHOD GetErro() CLASS WMSDTCClienteEnderecoBlocado
Return Self:cErro
