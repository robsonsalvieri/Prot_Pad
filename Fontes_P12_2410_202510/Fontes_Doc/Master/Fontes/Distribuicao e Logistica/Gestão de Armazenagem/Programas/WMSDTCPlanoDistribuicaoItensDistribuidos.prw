#Include "Totvs.ch"  
#INCLUDE "FWMVCDEF.CH"
#Include "WMSDTCPlanoDistribuicaoItensDistribuidos.ch"
//---------------------------------------------
/*/{Protheus.doc} WMSCLS0052
Função para permitir que a classe seja visualizada
no inspetor de objetos 
@author Inovação WMS
@since 16/12/2016
@version 1.0
/*/
//---------------------------------------------
Function WMSCLS0052()
Return Nil
//-----------------------------------------
/*/{Protheus.doc} WMSDTCPlanoDistribuicaoItensDistribuidos
Classe distribuição de produtos, pedidos e itens
@author Inovação WMS
@since 16/12/2016
@version 1.0
/*/
//-----------------------------------------
CLASS WMSDTCPlanoDistribuicaoItensDistribuidos FROM LongNameClass
	// Data
	DATA oPlnDisItem // D0P
	DATA cCodDis 
	DATA nQtdDis
	DATA nQtdDi2
	DATA cErro
	DATA nRecno
	// Method
	METHOD New() CONSTRUCTOR
	METHOD LoadData(nIndex)
	METHOD GoToD0P(nRecno)
	METHOD RecordD0P()
	METHOD UpdateD0P()
	METHOD DeleteD0P()
	// Setters
	METHOD SetCodPln(cCodPln)
	METHOD SetItem(cItem)
	METHOD SetCodDis(cCodDis)
	METHOD SetQtdDis(nQtdDis)
	METHOD SetQtdDi2(nQtdDi2)
	// Getters
	METHOD GetCodPln()
	METHOD GetItem()
	METHOD GetCodDis()
	METHOD GetQtdDis()
	METHOD GetQtdDi2()
	METHOD GetErro()
	METHOD GetRecno()
	METHOD Destroy()
ENDCLASS

//-----------------------------------------------------------------
METHOD New() CLASS WMSDTCPlanoDistribuicaoItensDistribuidos
	Self:oPlnDisItem := WMSDTCPlanoDistribuicaoItens():New()
	Self:cCodDis     := PadR("", TamSx3("D0P_CODDIS")[1])
	Self:nQtdDis     := 0
	Self:nQtdDi2     := 0
	Self:cErro       := ""
	Self:nRecno      := 0
Return

METHOD Destroy() CLASS WMSDTCPlanoDistribuicaoItensDistribuidos
	//Mantido para compatibilidade
Return

METHOD GoToD0P(nRecno) CLASS WMSDTCPlanoDistribuicaoItensDistribuidos
	Self:nRecno := nRecno
Return Self:LoadData(0)

METHOD LoadData(nIndex) CLASS WMSDTCPlanoDistribuicaoItensDistribuidos
Local lRet        := .T.
Local aAreaAnt    := GetArea()
Local aD0P_QTDDIS := TamSx3("D0P_QTDDIS")
Local aD0P_QTDDI2 := TamSx3("D0P_QTDDI2")
Local aAreaD0P    := D0P->(GetArea())
Local cAliasD0P   := Nil

Default nIndex    := 1

	Do Case
		Case nIndex == 0
			If Empty(Self:nRecno)
				lRet := .F.
			EndIf
		Case nIndex == 1 // D0P_FILIAL+D0P_CODPLN+D0P_ITEM
			If Empty(Self:GetCodPln()) .Or. Empty(Self:GetItem()) .Or. Empty(Self:cCodDis)
				lRet := .F.
			EndIf
		Otherwise
			lRet := .F.
	EndCase
	If !lRet
		Self:cErro := STR0001 // Dados para busca não foram informados!
	Else
		Self:oPlnDisItem:LoadData()
		cAliasD0P  := GetNextAlias()
		Do Case
			Case nIndex == 0
				BeginSql Alias cAliasD0P
					SELECT D0P.D0P_CODPLN,
						D0P.D0P_ITEM,
						D0P.D0P_CODDIS,
						D0P.D0P_QTDDIS,
						D0P.D0P_QTDDI2,
						D0P.R_E_C_N_O_ RECNOD0P
					FROM %Table:D0P% D0P
					WHERE D0P.D0P_FILIAL = %xFilial:D0P%
					AND D0P.R_E_C_N_O_ = %Exp:AllTrim(Str(Self:nRecno))%
					AND D0P.%NotDel%
				EndSql
			Case nIndex == 1
				BeginSql Alias cAliasD0P
					SELECT D0P.D0P_CODPLN,
						D0P.D0P_ITEM,
						D0P.D0P_CODDIS,
						D0P.D0P_QTDDIS,
						D0P.D0P_QTDDI2,
						D0P.R_E_C_N_O_ RECNOD0P
					FROM %Table:D0P% D0P
					WHERE D0P.D0P_FILIAL = %xFilial:D0P%
					AND D0P.D0P_CODPLN = %Exp:Self:GetCodPln()%
					AND D0P.D0P_ITEM =   %Exp:Self:GetItem()%
					AND D0P.D0P_CODDIS = %Exp:Self:cCodDis%
					AND D0P.%NotDel%
				EndSql
		EndCase
		TCSetField(cAliasD0P,'D0P_QTDDIS','N',aD0P_QTDDIS[1],aD0P_QTDDIS[2])
		TCSetField(cAliasD0P,'D0P_QTDDI2','N',aD0P_QTDDI2[1],aD0P_QTDDI2[2])
		If (lRet := (cAliasD0P)->(!Eof()))
			Self:cCodDis   := (cAliasD0P)->D0P_CODDIS
			Self:nQtdDis   := (cAliasD0P)->D0P_QTDDIS
			Self:nQtdDi2   := (cAliasD0P)->D0P_QTDDI2
			Self:nRecno    := (cAliasD0P)->RECNOD0P
		EndIf
		(cAliasD0P)->(dbCloseArea())
	EndIf
	RestArea(aAreaD0P)
	RestArea(aAreaAnt)
Return lRet

METHOD RecordD0P() CLASS WMSDTCPlanoDistribuicaoItensDistribuidos
Local lRet := .T.
	Self:nQtdDi2 := ConvUm(Self:oPlnDisItem:GetProduto(),Self:nQtdDis,0,2)
	// D0P_FILIAL+D0P_CODPLN+D0P_ITEM
	If !D0P->(dbSeek(xFilial("D0P")+Self:GetCodPln()+Self:GetItem()+Self:cCodDis))
		RecLock('D0P', .T.)
		D0P->D0P_FILIAL := xFilial("D0P")
		D0P->D0P_CODPLN := Self:GetCodPln()
		D0P->D0P_ITEM   := Self:GetItem()
		D0P->D0P_CODDIS := Self:cCodDis
		D0P->D0P_QTDDIS := Self:nQtdDis
		D0P->D0P_QTDDI2 := Self:nQtdDi2
		D0P->(MsUnLock())
		//--
		Self:nRecno     := D0P->(Recno())
		// Ajusta quantidade distribuida no plano de distribuição item
		If Self:oPlnDisItem:LoadData()
			Self:oPlnDisItem:SetQtdDis(Self:oPlnDisItem:GetQtdDis()+Self:nQtdDis)
			lRet := Self:oPlnDisItem:UpdateD0M()
		EndIf
	Else
		lRet := .F.
		Self:cErro := STR0002 // Chave duplicada
	EndIf
Return lRet

METHOD UpdateD0P() CLASS WMSDTCPlanoDistribuicaoItensDistribuidos
Local lRet := .T.
Local aAreaD0P := D0P->(GetArea())	
	// Converte 2UM
	Self:nQtdDi2 := ConvUm(Self:oPlnDisItem:GetProduto(),Self:nQtdDis,0,2)
	If !Empty(Self:nRecno)
		D0P->(dbGoTo( Self:nRecno ))
		// Grava D07
		RecLock('D0P', .F.)
		D0P->D0P_QTDDIS := Self:nQtdDis
		D0P->D0P_QTDDI2 := Self:nQtdDi2
		D0P->(MsUnLock())
		// Atualiza status do plano
		Self:UpdStatus()
	Else
		lRet := .F.
		Self:cErro := STR0003 // Dados não encontrados!
	EndIf
	RestArea(aAreaD0P)
Return lRet

METHOD DeleteD0P() CLASS WMSDTCPlanoDistribuicaoItensDistribuidos
Local lRet := .T.
Local aAreaD0P := D0P->(GetArea())
	If !Empty(Self:nRecno)
		D0P->(dbGoTo( Self:nRecno ))
		// Ajusta quantidade distribuida no plano de distribuição item
		If Self:oPlnDisItem:LoadData()
			Self:oPlnDisItem:SetQtdDis(Self:oPlnDisItem:GetQtdDis()-D0P->D0P_QTDDIS)
			lRet := Self:oPlnDisItem:UpdateD0M()
		EndIf
		// Grava D07
		RecLock('D0P', .F.)
		D0P->(dbDelete())
		D0P->(MsUnLock())
	Else
		lRet := .F.
		Self:cErro := STR0003 // Dados não encontrados!
	EndIf
	RestArea(aAreaD0P)
Return lRet
//-----------------------------------
// Setters
//-----------------------------------
METHOD SetCodPln(cCodPln) CLASS WMSDTCPlanoDistribuicaoItensDistribuidos
Return Self:oPlnDisItem:oPlnDist:SetCodPln(cCodPln)

METHOD SetItem(cItem) CLASS WMSDTCPlanoDistribuicaoItensDistribuidos
Return Self:oPlnDisItem:SetItem(cItem)

METHOD SetCodDis(cCodDis) CLASS WMSDTCPlanoDistribuicaoItensDistribuidos
Return Self:cCodDis := PadR(cCodDis, Len(Self:cCodDis))

METHOD SetQtdDis(nQtdDis)CLASS WMSDTCPlanoDistribuicaoItensDistribuidos
Return Self:nQtdDis := nQtdDis

METHOD SetQtdDi2(nQtdDi2) CLASS WMSDTCPlanoDistribuicaoItensDistribuidos
Return Self:nQtdDi2 := nQtdDi2
//-----------------------------------
// Getters
//-----------------------------------
METHOD GetCodPln() CLASS WMSDTCPlanoDistribuicaoItensDistribuidos
Return Self:oPlnDisItem:oPlnDist:GetCodPln()

METHOD GetItem() CLASS WMSDTCPlanoDistribuicaoItensDistribuidos
Return Self:oPlnDisItem:GetItem()

METHOD GetCodDis() CLASS WMSDTCPlanoDistribuicaoItensDistribuidos
Return Self:cCodDis

METHOD GetQtdDis()CLASS WMSDTCPlanoDistribuicaoItensDistribuidos
Return Self:nQtdDis

METHOD GetQtdDi2() CLASS WMSDTCPlanoDistribuicaoItensDistribuidos
Return Self:nQtdDi2
