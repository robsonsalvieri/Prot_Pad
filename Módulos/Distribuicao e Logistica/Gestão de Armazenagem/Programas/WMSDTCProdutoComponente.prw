#Include "Totvs.ch"     
#Include "WMSDTCProdutoComponente.ch"
//---------------------------------------------
/*/{Protheus.doc} WMSCLS0035
Função para permitir que a classe seja visualizada
no inspetor de objetos 
@author Inovação WMS
@since 16/12/2016
@version 1.0
/*/
//---------------------------------------------
Function WMSCLS0035()
Return Nil
//-----------------------------------------------
/*/{Protheus.doc} WMSDTCProdutoComponente
Classe componente do produto
@author Inovação WMS
@since 16/12/2016
@version 1.0
/*/
//-----------------------------------------------
CLASS WMSDTCProdutoComponente FROM LongNameClass
	// Data
	DATA lD11Active
	DATA cProduto
	DATA cPrdOri
	DATA cPrdCmp
	DATA nQtMult
	DATA cSequen
	DATA nNivel
	DATA aProduto AS ARRAY
	DATA cMntPrd
	DATA aD11_QTMULT AS ARRAY
	DATA nRecno
	DATA cErro
	// Method
	METHOD New() CONSTRUCTOR
	METHOD LoadData(nIndex)
	METHOD ClearData()
	METHOD SetProduto(cProduto)
	METHOD SetPrdOri(cPrdOri)
	METHOD SetPrdCmp(cPrdCmp)
	METHOD GetProduto()
	METHOD GetPrdOri()
	METHOD GetPrdCmp()
	METHOD GetQtMult()
	METHOD GetNivel()
	METHOD HaveSon(cProdut)
	METHOD GetArrProd()
	METHOD GetErro()
	METHOD EstProduto()
	METHOD IsDad()
	METHOD Destroy()
	METHOD IsMntPrd()
ENDCLASS
//-----------------------------------------------
/*/{Protheus.doc} New
Método construtor
@author felipe.m
@since 23/12/2014
@version 1.0
/*/
//-----------------------------------------------
METHOD New() CLASS WMSDTCProdutoComponente
	Self:lD11Active := SuperGetMv("MV_WMSNEW",.F.,.F.)	
	Self:cProduto    := PadR("", Iif(Self:lD11Active,GetWmsSX3("D11_PRODUT", 1),15) )
	Self:cPrdOri     := PadR("", Iif(Self:lD11Active,GetWmsSX3("D11_PRDORI", 1),15) )
	Self:cPrdCmp     := PadR("", Iif(Self:lD11Active,GetWmsSX3("D11_PRDCMP", 1),15) )
	Self:cSequen     := PadR("", Iif(Self:lD11Active,GetWmsSX3("D11_SEQUEN", 1),06) )
	Self:aD11_QTMULT := GetWmsSX3("D11_QTMULT")
	Self:ClearData()
Return

METHOD ClearData() CLASS WMSDTCProdutoComponente
	Self:cProduto := PadR("", Iif(Self:lD11Active, Len(Self:cProduto),15) )
	Self:cPrdOri  := PadR("", Iif(Self:lD11Active, Len(Self:cPrdOri),15) )
	Self:cPrdCmp  := PadR("", Iif(Self:lD11Active, Len(Self:cPrdCmp),15) )
	Self:nQtMult  := 1
	Self:cSequen  := PadR("", Iif(Self:lD11Active, Len(Self:cSequen),06) )
	Self:cErro    := ""
	Self:nRecno   := 0
	Self:nNivel   := 0
	Self:cMntPrd  := "2"
	Self:aProduto := {}
Return Nil

METHOD Destroy() CLASS WMSDTCProdutoComponente
	//FreeObj(Self)
Return Nil
//-----------------------------------------------
/*/{Protheus.doc} LoadData
Carregamento dos dados D11
@author felipe.m
@since 23/12/2014
@version 1.0
@param nIndex, numérico, (indice para carregamento)
/*/
//-----------------------------------------------
METHOD LoadData(nIndex) CLASS WMSDTCProdutoComponente
Local aAreaAnt    := GetArea()
Local lRet        := .T.
Local aAreaD11    := {}
Local cAliasD11   := Nil

Default nIndex    := 1
	Do Case 
		Case nIndex == 1
			If (Empty(Self:cProduto) .OR. Empty(Self:cPrdOri) .OR. Empty(Self:cPrdCmp)) 
				lRet := .F.
			EndIf
		Case nIndex == 2
			If Empty(Self:cPrdCmp)
				lRet := .F.
			EndIf
		Case nIndex == 3
			If Empty(Self:cPrdOri)
				lRet := .F.
			EndIf
		Otherwise
			lRet := .F.
	EndCase
	If !lRet
		Self:cErro := STR0001 // Dados para busca não foram informados!
	ElseIf Self:lD11Active
		aAreaD11    := D11->(GetArea())
		cAliasD11   := GetNextAlias()
		Do Case
			Case nIndex == 1
				BeginSql Alias cAliasD11
					SELECT D11.D11_PRODUT,
							D11.D11_PRDORI,
							D11.D11_PRDCMP,
							D11.D11_QTMULT,
							D11.D11_SEQUEN,
							D11.D11_MNTPRD,
							D11.R_E_C_N_O_ RECNOD11
					FROM %Table:D11% D11
					WHERE D11.D11_FILIAL = %xFilial:D11%
					AND D11.D11_PRODUT = %Exp:Self:GetProduto()%
					AND D11.D11_PRDORI = %Exp:Self:cPrdOri%
					AND D11.D11_PRDCMP = %Exp:Self:cPrdCmp%
					AND D11.%NotDel%
				EndSql
			Case nIndex == 2
				BeginSql Alias cAliasD11
					SELECT D11.D11_PRODUT,
							D11.D11_PRDORI,
							D11.D11_PRDCMP,
							D11.D11_QTMULT,
							D11.D11_SEQUEN,
							D11.D11_MNTPRD,
							D11.R_E_C_N_O_ RECNOD11
					FROM %Table:D11% D11
					WHERE D11.D11_FILIAL = %xFilial:D11%
					AND D11.D11_PRDCMP = %Exp:Self:cPrdCmp%
					AND D11.%NotDel%
				EndSql
			Case nIndex == 3
				BeginSql Alias cAliasD11
					SELECT D11.D11_PRODUT,
							D11.D11_PRDORI,
							D11.D11_PRDCMP,
							D11.D11_QTMULT,
							D11.D11_SEQUEN,
							D11.D11_MNTPRD,
							D11.R_E_C_N_O_ RECNOD11
					FROM %Table:D11% D11
					WHERE D11.D11_FILIAL = %xFilial:D11%
					AND D11.D11_PRDORI = %Exp:Self:cPrdOri%
					AND D11.%NotDel%
				EndSql
		EndCase
		TCSetField(cAliasD11,'D11_QTMULT','N',Self:aD11_QTMULT[1],Self:aD11_QTMULT[2])
		If (lRet := (cAliasD11)->(!Eof()))
			Self:cProduto:= (cAliasD11)->D11_PRODUT
			Self:cPrdOri := (cAliasD11)->D11_PRDORI
			Self:cPrdCmp := (cAliasD11)->D11_PRDCMP
			Self:nQtMult := (cAliasD11)->D11_QTMULT
			Self:cSequen := (cAliasD11)->D11_SEQUEN
			Self:cMntPrd := (cAliasD11)->D11_MNTPRD
			Self:nRecno  := (cAliasD11)->RECNOD11
		EndIf	
		(cAliasD11)->(dbCloseArea())
		RestArea(aAreaD11)
	EndIf
	RestArea(aAreaAnt)
Return lRet
//-----------------------------------------------
// Setters
//-----------------------------------------------
METHOD SetProduto(cProduto) CLASS WMSDTCProdutoComponente
	Self:cProduto := PadR(cProduto, IIf(Self:lD11Active, Len(Self:cProduto),15) )
Return 

METHOD SetPrdOri(cPrdOri) CLASS WMSDTCProdutoComponente
	Self:cPrdOri := PadR(cPrdOri, IIf(Self:lD11Active, Len(Self:cPrdOri),15) )
Return  

METHOD SetPrdCmp(cPrdCmp) CLASS WMSDTCProdutoComponente
	Self:cPrdCmp := PadR(cPrdCmp, IIf(Self:lD11Active, Len(Self:cPrdCmp),15) )
Return 
//-----------------------------------------------
// Getters
//-----------------------------------------------
METHOD GetProduto() CLASS WMSDTCProdutoComponente
Return Self:cProduto

METHOD GetPrdOri() CLASS WMSDTCProdutoComponente
Return Self:cPrdOri

METHOD GetPrdCmp() CLASS WMSDTCProdutoComponente
Return Self:cPrdCmp

METHOD GetQtMult() CLASS WMSDTCProdutoComponente
Return Self:nQtMult

METHOD GetNivel() CLASS WMSDTCProdutoComponente
	Self:nNivel := 1
	Self:HaveSon(Self:cPrdOri)
Return Self:nNivel

METHOD GetErro() CLASS WMSDTCProdutoComponente
Return Self:cErro
//-----------------------------------------------
/*/{Protheus.doc} EstProduto
Carrega o array de estrutura do produto
@author felipe.m
@since 23/12/2014
@version 1.0
/*/
//-----------------------------------------------
METHOD EstProduto() CLASS WMSDTCProdutoComponente
Local lRet       := .T.
Local aAreaD11   := {}
Local cAliasD11  := Nil

	Self:nQtMult  := 1
	Self:aProduto := {}
	
	If Self:lD11Active
		aAreaD11   := D11->(GetArea())
		cAliasD11 := GetNextAlias()
		BeginSql Alias cAliasD11
			SELECT D11.D11_PRDCMP,
					D11.D11_QTMULT
			FROM %Table:D11% D11
			WHERE D11.D11_FILIAL = %xFilial:D11%
			AND D11.D11_PRODUT = %Exp:Self:cProduto%
			AND D11.D11_PRDORI = %Exp:Self:cPrdOri%
			AND D11.%NotDel%
		EndSql
		TCSetField(cAliasD11,'D11_QTMULT','N',Self:aD11_QTMULT[1],Self:aD11_QTMULT[2])
		If (cAliasD11)->(Eof())
			aAdd(Self:aProduto, {Self:cProduto, 1, Self:cPrdOri})
		Else
			Do While (cAliasD11)->(!Eof())
				aAdd(Self:aProduto, {(cAliasD11)->D11_PRDCMP, (cAliasD11)->D11_QTMULT, Self:cPrdOri})
				(cAliasD11)->(dbSkip())
			EndDo
		EndIf
		(cAliasD11)->(dbCloseArea())
		RestArea(aAreaD11)
	Else
		aAdd(Self:aProduto, {Self:cProduto, 1, Self:cPrdOri})
	EndIf
Return lRet
//-----------------------------------------------
/*/{Protheus.doc} GetArrProd
Retorna o array de estrutura do produto
@author felipe.m
@since 23/12/2014
@version 1.0
/*/
//-----------------------------------------------
METHOD GetArrProd() CLASS WMSDTCProdutoComponente
Return Self:aProduto

METHOD IsDad() CLASS WMSDTCProdutoComponente
Local lRet      := .F.
Local aAreaD11  := {}
Local cAliasQry := Nil
	If Self:lD11Active
		aAreaD11  := D11->(GetArea())
		cAliasQry := GetNextAlias()
		BeginSql Alias cAliasQry
			SELECT 1
			FROM %Table:D11% D11
			WHERE D11.D11_FILIAL = %xFilial:D11%
			AND D11.D11_PRODUT = %Exp:Self:GetProduto()%
			AND D11.%NotDel%
		EndSql
		lRet := (cAliasQry)->(!Eof())
		(cAliasQry)->(dbCloseArea())
		RestArea(aAreaD11)
	EndIf
Return lRet

METHOD HaveSon(cProdut) CLASS WMSDTCProdutoComponente
Local aAreaD11  := {}
Local cAliasQry := Nil
	If Self:lD11Active
		aAreaD11  := D11->(GetArea())
		cAliasQry := GetNextAlias()
		BeginSql Alias cAliasQry
			SELECT D11.D11_PRDORI
			FROM %Table:D11% D11
			WHERE D11.D11_FILIAL = %xFilial:D11%
			AND D11.D11_PRDCMP = %Exp:cProdut%
			AND D11.%NotDel%
		EndSql
		Do While (cAliasQry)->(!Eof())
			Self:HaveSon((cAliasQry)->D11_PRDORI)
			Self:nNivel++
			(cAliasQry)->(dbSkip())
		EndDo
		(cAliasQry)->(dbCloseArea())
		RestArea(aAreaD11)
	EndIf
Return .T.

METHOD IsMntPrd() CLASS WMSDTCProdutoComponente
Return Self:cMntPrd == "1"