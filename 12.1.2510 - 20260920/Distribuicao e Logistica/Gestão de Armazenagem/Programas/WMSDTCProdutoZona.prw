#Include "Totvs.ch"  
#Include "WMSDTCProdutoZona.ch"
//---------------------------------------------
/*/{Protheus.doc} WMSCLS0039
Função para permitir que a classe seja visualizada
no inspetor de objetos 
@author Inovação WMS
@since 16/12/2016
@version 1.0
/*/
//---------------------------------------------
Function WMSCLS0039()
Return Nil
//--------------------------------------
/*/{Protheus.doc} WMSDTCProdutoZona
Classe Zona alternativa do produto
@author Inovação WMS
@since 16/12/2016
@version 1.0
/*/
//--------------------------------------
CLASS WMSDTCProdutoZona FROM LongNameClass
	// Data
	DATA cProduto
	DATA cCodZona
	DATA cOrdem
	DATA nRecno
	DATA cErro
	// Method
	METHOD New() CONSTRUCTOR
	METHOD LoadData(nIndex)
	
	METHOD SetProduto(cProduto)
	METHOD SetCodZona(cCodZona)
	METHOD SetOrdem(cOrdem)
	
	METHOD GetProduto()
	METHOD GetCodZona()
	METHOD GetOrdem()
	METHOD GetErro()
	METHOD Destroy()
ENDCLASS

//-----------------------------------------------------------------
METHOD New() CLASS WMSDTCProdutoZona
	Self:cProduto   := PadR("",TamSx3("DCH_CODPRO")[1])
	Self:cCodZona   := PadR("",TamSx3("DCH_CODZON")[1])
	Self:cOrdem     := PadR("",TamSx3("DCH_ORDEM")[1])
	Self:cErro      := ""
	Self:nRecno     := 0
Return

METHOD Destroy() CLASS WMSDTCProdutoZona
	//Mantido para compatibilidade
Return 

METHOD LoadData(nIndex) CLASS WMSDTCProdutoZona
Local lRet     := .T.
Local aAreaAnt := GetArea()
Local aAreaDCH := DCH->(GetArea())
Local cAliasDCH:= Nil
Default nIndex := 1
	Do Case 
		Case nIndex == 1 // DCH_FILIAL+DCH_CODPRO+DCH_CODZON
			If Empty(Self:cProduto) .OR. Empty(Self:cCodZona) 
				lRet := .F.
			EndIf
		Otherwise
			lRet := .F.
	EndCase
	If !lRet
		Self:cErro := STR0001 // Dados para busca não foram informados!
	Else
		cAliasDCH:= GetNextAlias()
		Do Case
			Case nIndex == 1
				BeginSql Alias cAliasDCH
					SELECT DCH.DCH_CODPRO,
							DCH.DCH_CODZON,
							DCH.DCH_ORDEM,
							DCH.R_E_C_N_O_ RECNODCH
					FROM %Table:DCH% DCH
					WHERE DCH.DCH_FILIAL = %xFilial:DCH%
					AND DCH.DCH_CODPRO = %Exp:Self:cProduto%
					AND DCH.DCH_CODZON = %Exp:Self:cCodZona%
					AND DCH.%NotDel%
				EndSql
		EndCase
		lRet := (cAliasDCH)->(!Eof())
		If lRet
			Self:cProduto   := (cAliasDCH)->DCH_CODPRO
			Self:cCodZona   := (cAliasDCH)->DCH_CODZON
			Self:cOrdem     := (cAliasDCH)->DCH_ORDEM
			Self:nRecno     := (cAliasDCH)->RECNODCH
		EndIf
		(cAliasDCH)->(dbCloseArea())
	EndIf
	RestArea(aAreaDCH)
	RestArea(aAreaAnt)
Return lRet
//-----------------------------------
// Setters
//-----------------------------------
METHOD SetProduto(cProduto) CLASS WMSDTCProdutoZona
	Self:cProduto := PadR(cProduto, Len(Self:cProduto))
Return 

METHOD SetCodZona(cCodZona) CLASS WMSDTCProdutoZona
	Self:cCodZona := PadR(cCodZona, Len(Self:cCodZona))
Return

METHOD SetOrdem(cOrdem) CLASS WMSDTCProdutoZona
	Self:cOrdem := PadR(cOrdem, Len(Self:cOrdem))
Return 
//-----------------------------------
// Getters
//-----------------------------------
METHOD GetProduto() CLASS WMSDTCProdutoZona
Return Self:cProduto

METHOD GetCodZona() CLASS WMSDTCProdutoZona
Return Self:cCodZona

METHOD GetOrdem() CLASS WMSDTCProdutoZona
Return Self:cOrdem

METHOD GetErro() CLASS WMSDTCProdutoZona
Return Self:cErro
