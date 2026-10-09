#Include "Totvs.ch"
#Include "WMSBCCCustomizacao.ch"
//---------------------------------------------
/*/{Protheus.doc} WMSCLS0004
Função para permitir que a classe seja visualizada
no inspetor de objetos
@author Inovação WMS
@since 16/12/2016
@version 1.0
/*/
//---------------------------------------------
Function WMSCLS0004()
Return Nil
//---------------------------------------------
/*/{Protheus.doc} WMSBCCCustomizacao
Classe para chamada de funções customizadas
no inspetor de objetos
@author Inovação WMS
@since 16/12/2016
@version 1.0
/*/
//---------------------------------------------
CLASS WMSBCCCustomizacao FROM WMSDTCMovimentosServicoArmazem
	// Declaração dos Métodos da Classe
	METHOD New() CONSTRUCTOR
	METHOD SetOrdServ(oOrdServ)
	METHOD ExecFuncao()
	METHOD Destroy()
ENDCLASS

METHOD New() CLASS WMSBCCCustomizacao
	_Super:New()
Return

METHOD SetOrdServ(oOrdServ) CLASS WMSBCCCustomizacao
	Self:oOrdServ := oOrdServ
	Self:oMovServic := Self:oOrdServ:oServico
	// Carrega dados endereço origem
	Self:oMovEndOri:SetArmazem(Self:oOrdServ:oOrdEndOri:GetArmazem())
	Self:oMovEndOri:SetEnder(Self:oOrdServ:oOrdEndOri:GetEnder())
	Self:oMovEndOri:LoadData()
	Self:oMovEndOri:ExceptEnd()
	// Carrega dados endereço destino
	Self:oMovEndDes:SetArmazem(Self:oOrdServ:oOrdEndDes:GetArmazem())
	Self:oMovEndDes:SetEnder(Self:oOrdServ:oOrdEndDes:GetEnder())
	Self:oMovEndDes:LoadData()
	Self:oMovEndDes:ExceptEnd()
	// Status movimento
	Self:cStatus := IIf(Self:oMovServic:GetBlqSrv() == "1","2","4")
Return

METHOD Destroy() CLASS WMSBCCCustomizacao
	//Mantido para compatibilidade
Return

METHOD ExecFuncao() CLASS WMSBCCCustomizacao
Local lRet       := .T.
Local bFunExe    := Nil
Local cFunExe    := ""

	If Empty(Self:oMovServic:GetFuncao())
		Self:cErro := STR0001 // Função não cadastrada!
		lRet := .F.
	EndIf
	If lRet
		If !(Upper(SubStr(Self:oMovServic:GetFuncao(), 1, 2)) == 'U_')
			Self:cErro := WmsFmtMsg(STR0002,{{"[VAR01]",Self:oMovServic:GetFuncao()}})  // Função [VAR01] cadastrada não é uma DRMake!
			lRet := .F.
		EndIf
	EndIf
	If lRet
		If "()" $ Self:oMovServic:GetFuncao()
			cFunExe := StrTran(Self:oMovServic:GetFuncao(),"()","")
			cFunExe += "(oMovimento,'1')"
		EndIf
		cFunExe := "{|oMovimento| "+ cFunExe +"}"
		bFunExe := &(cFunExe)
		lRet := Eval(bFunExe,Self)
		lRet := If(!(lRet==NIL).And.ValType(lRet)=="L", lRet, .T.)
		If !lRet
			Self:cErro := WmsFmtMsg(STR0003,{{"[VAR01]",Self:oMovServic:GetFuncao()}})  // Função DRMake [VAR01] não processada com sucesso!
		EndIf
	EndIf
Return lRet
