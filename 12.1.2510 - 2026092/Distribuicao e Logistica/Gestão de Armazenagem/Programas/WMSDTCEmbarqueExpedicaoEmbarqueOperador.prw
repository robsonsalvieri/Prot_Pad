#Include "Totvs.ch" 
#Include "WMSDTCEmbarqueExpedicaoEmbarqueOperador.ch"

//---------------------------------------------
/*/{Protheus.doc} WMSCLS0065
Função para permitir que a classe seja visualizada
no inspetor de objetos 
@author Inovação WMS
@since 13/12/2018
@version 1.0
/*/
//---------------------------------------------
Function WMSCLS0065()
Return Nil
//---------------------------------------------
/*/{Protheus.doc} WMSDTCEmbarqueExpedicaoEmbarqueOperador
(long_description)
@author    Squad WMS/OMS Protheus
@since     13/12/2018
@version   1.0
/*/
//---------------------------------------------
CLASS WMSDTCEmbarqueExpedicaoEmbarqueOperador FROM LongNameClass
	DATA oEmbExpIt
	DATA cCodOpe
	DATA cCodVol
	DATA nQtdEmb
	DATA dDatIni
	DATA cHorIni
	DATA dDatFim
	DATA cHorFim
	DATA nRecno
	DATA cErro
	DATA lEstorno
	
	METHOD New() CONSTRUCTOR
	METHOD GoToD16(nRecno)
	METHOD LoadData(nIndex)
	METHOD AssignD16()
	METHOD RecordD16()
	METHOD UpdateD16()
	METHOD UpdateDataFimHoraFimProduto()
	METHOD ExcludeD16()
	METHOD GetRecno()
	METHOD GetErro()
	METHOD SetEmbarq(cEmbarque)
	METHOD SetCarga(cCarga)
	METHOD SetPedido(cPedido)
	METHOD SetItem(cItem)
	METHOD SetSequen(cSequen)
	METHOD SetCodOpe(cCodOpe)
	METHOD SetProduto(cProduto)
	METHOD SetPrdOri(cPrdOri)
	METHOD SetLoteCtl(cLoteCtl)
	METHOD SetNumLote(cNumLote)
	METHOD SetNumSer(cNumSer)
	METHOD SetCodVol(cCodVol)
	METHOD SetReverse(lEstorno)
	METHOD SetQtdEmb(nQtdEmb)
	METHOD SetDatIni(dDatIni)
	METHOD SetHorIni(cHorIni)
	METHOD SetDatFim(dDatFim)
	METHOD SetHorFim(cHorFim)
	
	METHOD GetEmbarq()
	METHOD GetCarga()
	METHOD GetPedido()
	METHOD GetItem()
	METHOD GetSequen()
	METHOD GetCodOpe()
	METHOD GetProduto()
	METHOD GetPrdOri()
	METHOD GetLoteCtl()
	METHOD GetNumLote()
	METHOD GetNumSer()
	METHOD GetCodVol()
	METHOD GetReverse()
	METHOD GetQtdEmb()
	METHOD GetDatIni()
	METHOD GetHorIni()
	METHOD GetDatFim()
	METHOD GetHorFim()

	METHOD EstEmbOpe(nQuantEst)
	METHOD EstEmbItem(nQtdEst)
	
	METHOD ClearData()
	METHOD Destroy()
ENDCLASS
//-----------------------------------------
/*/{Protheus.doc} New
Método construtor
@author Squad WMS/OMS Protheus
@since 14/12/2018
@version 1.0
/*/
//-----------------------------------------
METHOD New() CLASS WMSDTCEmbarqueExpedicaoEmbarqueOperador
	Self:oEmbExpIt := WMSDTCEmbarqueExpedicaoItens():New()
	Self:cCodOpe  := PadR("", TamSx3("D16_CODOPE")[1])
	Self:cCodVol  := PadR("", TamSx3("D16_CODVOL")[1])
	Self:ClearData()
Return

METHOD ClearData() CLASS WMSDTCEmbarqueExpedicaoEmbarqueOperador
	Self:cCodOpe  := PadR("", Len(Self:cCodOpe))
	Self:cCodVol  := PadR("", Len(Self:cCodVol))
	Self:nQtdEmb  := 0
	Self:dDatIni  := dDataBase
	Self:cHorIni  := Time()
	Self:dDatFim  := CTOD("")
	Self:cHorFim  := PadR("", Len(Self:cHorIni))
	Self:lEstorno := .F.
	Self:nRecno   := 0
	Self:cErro    := ""
Return 

METHOD Destroy() CLASS WMSDTCEmbarqueExpedicaoEmbarqueOperador
	// Mantido para compatibilidade
Return
//----------------------------------------
/*/{Protheus.doc} GoToD16
Posicionamento para atualização das propriedades
@author Squad WMS/OMS Protheus
@since 13/12/2018
@version 1.0
@param nRecno, numérico, (Descrição do parâmetro)
/*/
//----------------------------------------
METHOD GoToD16(nRecno) CLASS WMSDTCEmbarqueExpedicaoEmbarqueOperador
	Self:nRecno := nRecno
Return Self:LoadData(0)

//-----------------------------------------
/*/{Protheus.doc} LoadData
Carregamento dos dados D16
@author Squad WMS/OMS Protheus
@since 14/12/2018
@version 1.0
@param nIndex, numérico, (Descrição do parâmetro)
/*/
//-----------------------------------------
METHOD LoadData(nIndex) CLASS WMSDTCEmbarqueExpedicaoEmbarqueOperador
Local lRet        := .T.
Local aAreaAnt    := GetArea()
Local aAreaD16    := D16->(GetArea())
Local aD16_QTDEMB := TamSx3("D16_QTDEMB")
Local cWhere      := ""
Local cAliasD16   := Nil

Default nIndex   := 1

	Do Case
		Case nIndex == 0
			If Empty(Self:nRecno)
				lRet := .F.
			EndIf
		Case nIndex == 1 // D16_FILIAL+D16_EMBARQ+D16_PEDIDO+D16_ITEM+D16_SEQUEN+D16_PRDORI+D16_PRODUT
			If Empty(Self:GetEmbarq()) .Or. Empty(Self:GetPedido()) .Or. Empty(Self:GetItem()) .Or. Empty(Self:GetSequen()) .Or. Empty(Self:GetPrdOri()) .Or. Empty(Self:GetProduto())
				lRet := .F.
			EndIf
		Otherwise
			lRet := .F.
	EndCase
	If !lRet
		Self:cErro := STR0001 // Dados para busca não foram informados!
	Else		
		cAliasD16 := GetNextAlias()
		Do Case
			Case nIndex == 0
				BeginSql Alias cAliasD16
					SELECT D16.D16_FILIAL,
							D16.D16_EMBARQ,
							D16.D16_CARGA,
							D16.D16_PEDIDO,
							D16.D16_ITEM,
							D16.D16_SEQUEN,
							D16.D16_PRDORI,
							D16.D16_PRODUT,
							D16.D16_LOTECT,
							D16.D16_NUMLOT,
							D16.D16_NUMSER,
							D16.D16_CODVOL,
							D16.D16_CODOPE,
							D16.D16_QTDEMB,
							D16.D16_DATINI,
							D16.D16_HORINI,
							D16.D16_DATFIM,
							D16.D16_HORFIM,
							D16.R_E_C_N_O_ RECNOD16
					FROM %Table:D16% D16
					WHERE D16.D16_FILIAL = %xFilial:D16%
					AND D16.R_E_C_N_O_ = %Exp:AllTrim(Str(Self:nRecno))%
					AND D16.%NotDel%
				EndSql
			Case nIndex == 1
				cWhere := "%"
				If !Empty(Self:GetCarga())
					cWhere += " AND D16.D16_CARGA = '"+Self:GetCarga()+"'"
				EndIf
				If !Empty(Self:GetPedido())
					cWhere += " AND D16.D16_PEDIDO = '"+Self:GetPedido()+"'"
				EndIf
				If !Empty(Self:GetItem())
					cWhere += " AND D16.D16_ITEM = '"+Self:GetItem()+"'"
				EndIf
				If !Empty(Self:GetSequen())
					cWhere += " AND D16.D16_SEQUEN = '"+Self:GetSequen()+"'"
				EndIf
				If !Empty(Self:GetLoteCtl())
					cWhere += " AND D16.D16_LOTECT = '"+Self:GetLoteCtl()+"'"
				EndIf
				If !Empty(Self:GetNumLote())
					cWhere += " AND D16.D16_NUMLOT = '"+Self:GetNumLote()+"'"
				EndIf
				If !Empty(Self:GetNumSer())
					cWhere += " AND D16.D16_NUMSER = '"+Self:GetNumSer()+"'"
				EndIf
				If !Empty(Self:cCodVol)
					cWhere += " AND D16.D16_CODVOL = '"+Self:cCodVol+"'"
				EndIf
				cWhere += "%"
				BeginSql Alias cAliasD16
					SELECT D16.D16_FILIAL,
							D16.D16_EMBARQ,
							D16.D16_CARGA,
							D16.D16_PEDIDO,
							D16.D16_ITEM,
							D16.D16_SEQUEN,
							D16.D16_PRDORI,
							D16.D16_PRODUT,
							D16.D16_LOTECT,
							D16.D16_NUMLOT,
							D16.D16_NUMSER,
							D16.D16_CODVOL,
							D16.D16_CODOPE,
							D16.D16_QTDEMB,
							D16.D16_DATINI,
							D16.D16_HORINI,
							D16.D16_DATFIM,
							D16.D16_HORFIM,
							D16.R_E_C_N_O_ RECNOD16
					FROM %Table:D16% D16
					WHERE D16.D16_FILIAL = %xFilial:D16%
					AND D16.D16_EMBARQ = %Exp:Self:GetEmbarq()%
					AND D16.D16_PRDORI = %Exp:Self:GetPrdOri()%
					AND D16.D16_PRODUT = %Exp:Self:GetProduto()%
					AND D16.%NotDel%
					%Exp:cWhere%
				EndSql
		EndCase
		TCSetField(cAliasD16,'D16_QTDEMB','N',aD16_QTDEMB[1],aD16_QTDEMB[2])
		TcSetField(cAliasD16,'D16_DATINI','D')
		TcSetField(cAliasD16,'D16_DATFIM','D')
		If (lRet := (cAliasD16)->(!Eof()))
			Self:SetEmbarq((cAliasD16)->D16_EMBARQ)
			Self:SetCarga((cAliasD16)->D16_CARGA)
			Self:SetPedido((cAliasD16)->D16_PEDIDO)
			Self:SetItem((cAliasD16)->D16_ITEM)
			Self:SetSequen((cAliasD16)->D16_SEQUEN)
			Self:SetProduto((cAliasD16)->D16_PRODUT)
			Self:SetPrdOri((cAliasD16)->D16_PRDORI)
			Self:SetLoteCtl((cAliasD16)->D16_LOTECT)
			Self:SetNumLote((cAliasD16)->D16_NUMLOT)
			Self:SetNumSer((cAliasD16)->D16_NUMSER)
			Self:oEmbExpIt:LoadData()
			// Dados adicionais
			Self:cCodOpe := (cAliasD16)->D16_CODOPE
			Self:cCodVol := (cAliasD16)->D16_CODVOL
			Self:nQtdEmb := (cAliasD16)->D16_QTDEMB
			Self:dDatIni := (cAliasD16)->D16_DATINI
			Self:cHorIni := (cAliasD16)->D16_HORINI
			Self:dDatFim := (cAliasD16)->D16_DATFIM
			Self:cHorFim := (cAliasD16)->D16_HORFIM
			Self:nRecno  := (cAliasD16)->RECNOD16
		EndIf
		(cAliasD16)->(dbCloseArea())
	EndIf	
	RestArea(aAreaD16)
	RestArea(aAreaAnt)
Return lRet
//-----------------------------------------
/*/{Protheus.doc} AssignD16
Cria registro na tabela de Operado Embarque Expedição

@author  Squad WMS/OMS Protheus
@since   09/01/2019
@version 1.0
/*/
//-----------------------------------------
METHOD AssignD16() CLASS WMSDTCEmbarqueExpedicaoEmbarqueOperador
Local lRet    := .T.
Local aAreaAnt:= GetArea()
Local aProduto:= {}
Local nQtdEmb := Self:nQtdEmb
Local nQtdConv := 0
Local nI      := 0
	// Atualiza o embarque de expedição
	If Self:oEmbExpIt:LoadData()
		// Atualiza data e hora inicio
		If Empty(Self:dDatIni)
			Self:dDatIni := dDataBase
		EndIf
		If Empty(Self:cHorIni)
			Self:cHorIni := Time()
		EndIf

		//Preenche array com os produtos componentes.
		//visto que não existe registro na tabela D16 (Conferência por Operador) para o produto pai
		If Self:GetPrdOri() == Self:GetProduto()
			aProduto := Self:oEmbExpIt:oProdLote:GetArrProd()
		EndIf
		//Caso não seja uma produto com componente, adiciona o próprio produto do objeto
		If Empty(aProduto)
			aAdd(aProduto,{Self:GetProduto(),1,Self:GetPrdOri()})
		EndIf

		For nI := 1 To Len(aProduto)
			If !(Self:oEmbExpIt:GetProduto() == aProduto[nI][1])
				Self:oEmbExpIt:SetProduto(aProduto[nI][1])
				Self:oEmbExpIt:LoadData()
			EndIf
			nQtdConv := nQtdEmb * aProduto[nI][2] //Quantidade convertida
			Self:nQtdEmb := nQtdConv 
			// Verifica se há conferência cadastrada
			If Self:LoadData()
				If !Self:lEstorno
					Self:nQtdEmb += nQtdConv
					If (Self:oEmbExpIt:GetQtdEmb() + nQtdConv == Self:oEmbExpIt:GetQtdOri())
						Self:dDatFim := dDataBase
						Self:cHorFim := Time()
					EndIf
				Else
					Self:dDatFim := CTOD("")
					Self:cHorFim := ""
					Self:nQtdEmb -= nQtdConv
				EndIf
				
				lRet := Self:UpdateD16()
			Else
				lRet := Self:RecordD16()

				If (Self:oEmbExpIt:GetQtdEmb() + nQtdConv == Self:oEmbExpIt:GetQtdOri())
					Self:UpdateDataFimHoraFimProduto()
				EndIf
			EndIf
			If !Self:lEstorno
				Self:oEmbExpIt:SetQtdEmb(Self:oEmbExpIt:GetQtdEmb() + nQtdConv)
			Else
				Self:oEmbExpIt:SetQtdEmb(Self:oEmbExpIt:GetQtdEmb() - nQtdConv)
			EndIf
			lRet := Self:oEmbExpIt:UpdateD0Z()
		Next nI
		If lRet
			lRet := Self:oEmbExpIt:oEmbExp:UpdateD0X()
		EndIf
	EndIf
	RestArea(aAreaAnt)
Return lRet
//-----------------------------------------
/*/{Protheus.doc} RecordD16
Cria registro na tabela de Itens do Embarque Expedição

@author  Squad WMS/OMS Protheus
@since   14/12/2018
@version 1.0
/*/
//-----------------------------------------
METHOD RecordD16() CLASS WMSDTCEmbarqueExpedicaoEmbarqueOperador
Local lRet   := .T.
	DbSelectArea("D16")
	D16->(DbSetOrder(1)) // D16_FILIAL+D16_EMBARQ+D16_CODOPE+D16_CARGA+D16_PEDIDO+D16_ITEM+D16_SEQUEN+D16_PRDORI+D16_PRODUT+D16_CODVOL
	If !D16->(dbSeek(xFilial("D16")+Self:GetEmbarq()+Self:cCodOpe+Self:GetCarga()+Self:GetPedido()+Self:GetItem()+Self:GetSequen()+Self:GetPrdOri()+Self:GetProduto()+Self:cCodVol))
		Reclock('D16',.T.)
		D16->D16_Filial := xFilial("D16")
		D16->D16_EMBARQ := Self:GetEmbarq()
		D16->D16_CARGA  := Self:GetCarga()
		D16->D16_PEDIDO := Self:GetPedido()
		D16->D16_ITEM   := Self:GetItem()
		D16->D16_SEQUEN := Self:GetSequen()
		D16->D16_PRDORI := Self:GetPrdOri()
		D16->D16_PRODUT := Self:GetProduto()
		D16->D16_LOTECT := Self:GetLoteCtl()
		D16->D16_NUMLOT := Self:GetNumLote()
		D16->D16_NUMSER := Self:GetNumSer()
		D16->D16_DATINI := Self:dDatIni
		D16->D16_HORINI := Self:cHorIni
		D16->D16_DATFIM := Self:dDatFim
		D16->D16_HORFIM := Self:cHorFim
		D16->D16_CODVOL := Self:cCodVol
		D16->D16_CODOPE := Self:cCodOpe
		D16->D16_QTDEMB := Self:nQtdEmb
		D16->(MsUnLock())
		// Grava recno
		Self:nRecno := D16->(Recno())
	Else
		lRet := .F.
		Self:cErro := STR0002 // Chave duplicada!
	EndIf
Return lRet

METHOD UpdateD16() CLASS WMSDTCEmbarqueExpedicaoEmbarqueOperador
Local lRet   := .T.
	If !Empty(Self:GetRecno())
		D16->(dbGoTo( Self:GetRecno() ))
		// Grava
		RecLock('D16', .F.)
		D16->D16_DATFIM := Self:dDatFim
		D16->D16_HORFIM := Self:cHorFim
		D16->D16_QTDEMB := Self:nQtdEmb
		If D16->D16_QTDEMB <= 0
			D16->(dbDelete())
		EndIf
		D16->(MsUnLock())
	Else
		lRet := .F.
		Self:cErro := STR0003 // Dados não encontrados!
	EndIf
Return lRet
//-----------------------------------------
/*/{Protheus.doc} ExcludeD16
Exclui a capa do embarque
@author Squad WMS/OMS Protheus
@since 13/12/2018
@version 1.0
/*/
//-----------------------------------------
METHOD ExcludeD16() CLASS WMSDTCEmbarqueExpedicaoEmbarqueOperador
Local lRet := .T.
	D16->(dbGoTo( Self:GetRecno() ))
	// Excluindo item do embarque de expedição
	RecLock('D16', .F.)
	D16->(dbDelete())
	D16->(MsUnlock())
Return lRet

METHOD GetRecno() CLASS WMSDTCEmbarqueExpedicaoEmbarqueOperador
Return Self:nRecno

METHOD GetErro() CLASS WMSDTCEmbarqueExpedicaoEmbarqueOperador
Return Self:cErro

//-----------------------------------
// Setters
//-----------------------------------
METHOD SetEmbarq(cEmbarque) CLASS WMSDTCEmbarqueExpedicaoEmbarqueOperador
	Self:oEmbExpIt:SetEmbarq(cEmbarque)
Return

METHOD SetCarga(cCarga) CLASS WMSDTCEmbarqueExpedicaoEmbarqueOperador
	Self:oEmbExpIt:SetCarga(cCarga)
Return

METHOD SetPedido(cPedido) CLASS WMSDTCEmbarqueExpedicaoEmbarqueOperador
	Self:oEmbExpIt:SetPedido(cPedido)
Return

METHOD SetItem(cItem) CLASS WMSDTCEmbarqueExpedicaoEmbarqueOperador
	Self:oEmbExpIt:SetItem(cItem)
Return

METHOD SetSequen(cSequen) CLASS WMSDTCEmbarqueExpedicaoEmbarqueOperador
	Self:oEmbExpIt:SetSequen(cSequen)
Return

METHOD SetProduto(cProduto) CLASS WMSDTCEmbarqueExpedicaoEmbarqueOperador
	Self:oEmbExpIt:SetProduto(cProduto)
Return

METHOD SetPrdOri(cPrdOri) CLASS WMSDTCEmbarqueExpedicaoEmbarqueOperador
	Self:oEmbExpIt:SetPrdOri(cPrdOri)
Return

METHOD SetLoteCtl(cLoteCtl) CLASS WMSDTCEmbarqueExpedicaoEmbarqueOperador
	Self:oEmbExpIt:SetLoteCtl(cLoteCtl)
Return

METHOD SetNumLote(cNumLote) CLASS WMSDTCEmbarqueExpedicaoEmbarqueOperador
	Self:oEmbExpIt:SetNumLote(cNumLote)
Return

METHOD SetNumSer(cNumSer) CLASS WMSDTCEmbarqueExpedicaoEmbarqueOperador
	Self:oEmbExpIt:SetNumSer(cNumSer)
Return

METHOD SetCodVol(cCodVol) CLASS WMSDTCEmbarqueExpedicaoEmbarqueOperador
	Self:cCodVol := PadR(cCodVol, Len(Self:cCodVol))
Return

METHOD SetCodOpe(cCodOpe) CLASS WMSDTCEmbarqueExpedicaoEmbarqueOperador
	Self:cCodOpe := PadR(cCodOpe, Len(Self:cCodOpe))
Return

METHOD SetReverse(lEstorno) CLASS WMSDTCEmbarqueExpedicaoEmbarqueOperador
	Self:lEstorno := lEstorno
Return

METHOD SetQtdEmb(nQtdEmb) CLASS WMSDTCEmbarqueExpedicaoEmbarqueOperador
	Self:nQtdEmb := nQtdEmb
Return

METHOD SetDatIni(dDatIni) CLASS WMSDTCEmbarqueExpedicaoEmbarqueOperador
	Self:dDatIni := dDatIni
Return

METHOD SetHorIni(cHorIni) CLASS WMSDTCEmbarqueExpedicaoEmbarqueOperador
	Self:cHorIni := cHorIni
Return

METHOD SetDatFim(dDatFim) CLASS WMSDTCEmbarqueExpedicaoEmbarqueOperador
	Self:dDatFim := dDatFim
Return

METHOD SetHorFim(cHorFim) CLASS WMSDTCEmbarqueExpedicaoEmbarqueOperador
	Self:cHorFim := cHorFim
Return
//-----------------------------------
// Getters
//-----------------------------------
METHOD GetEmbarq() CLASS WMSDTCEmbarqueExpedicaoEmbarqueOperador
Return Self:oEmbExpIt:GetEmbarq()

METHOD GetCarga() CLASS WMSDTCEmbarqueExpedicaoEmbarqueOperador
Return Self:oEmbExpIt:GetCarga()

METHOD GetPedido() CLASS WMSDTCEmbarqueExpedicaoEmbarqueOperador
Return Self:oEmbExpIt:GetPedido()

METHOD GetItem() CLASS WMSDTCEmbarqueExpedicaoEmbarqueOperador
Return Self:oEmbExpIt:GetItem()

METHOD GetSequen() CLASS WMSDTCEmbarqueExpedicaoEmbarqueOperador
Return Self:oEmbExpIt:GetSequen()

METHOD GetProduto() CLASS WMSDTCEmbarqueExpedicaoEmbarqueOperador
Return Self:oEmbExpIt:GetProduto()

METHOD GetPrdOri() CLASS WMSDTCEmbarqueExpedicaoEmbarqueOperador
Return Self:oEmbExpIt:GetPrdOri()

METHOD GetLoteCtl() CLASS WMSDTCEmbarqueExpedicaoEmbarqueOperador
Return Self:oEmbExpIt:GetLoteCtl()

METHOD GetNumLote() CLASS WMSDTCEmbarqueExpedicaoEmbarqueOperador
Return Self:oEmbExpIt:GetNumLote()

METHOD GetNumSer() CLASS WMSDTCEmbarqueExpedicaoEmbarqueOperador
Return Self:oEmbExpIt:GetNumSer()

METHOD GetCodVol() CLASS WMSDTCEmbarqueExpedicaoEmbarqueOperador
Return Self:cCodVol

METHOD GetReverse() CLASS WMSDTCEmbarqueExpedicaoEmbarqueOperador
Return Self:lEstorno

METHOD GetCodOpe() CLASS WMSDTCEmbarqueExpedicaoEmbarqueOperador
Return Self:cCodOpe

METHOD GetQtdEmb() CLASS WMSDTCEmbarqueExpedicaoEmbarqueOperador
Return Self:nQtdEmb

METHOD GetDatIni() CLASS WMSDTCEmbarqueExpedicaoEmbarqueOperador
Return Self:dDatIni

METHOD GetHorIni() CLASS WMSDTCEmbarqueExpedicaoEmbarqueOperador
Return Self:cHorIni

METHOD GetDatFim() CLASS WMSDTCEmbarqueExpedicaoEmbarqueOperador
Return Self:dDatFim

METHOD GetHorFim() CLASS WMSDTCEmbarqueExpedicaoEmbarqueOperador
Return Self:cHorFim

METHOD UpdateDataFimHoraFimProduto() CLASS WMSDTCEmbarqueExpedicaoEmbarqueOperador
Local cAliasD16 := GetNextAlias()
Local cWhere    := ""
	cWhere := "%"
	If !Empty(Self:GetCarga())
		cWhere += " AND D16.D16_CARGA = '"+Self:GetCarga()+"'"
	EndIf
	If !Empty(Self:GetPedido())
		cWhere += " AND D16.D16_PEDIDO = '"+Self:GetPedido()+"'"
	EndIf
	If !Empty(Self:GetItem())
		cWhere += " AND D16.D16_ITEM = '"+Self:GetItem()+"'"
	EndIf
	If !Empty(Self:GetSequen())
		cWhere += " AND D16.D16_SEQUEN = '"+Self:GetSequen()+"'"
	EndIf
	If !Empty(Self:GetNumSer())
		cWhere += " AND D16.D16_NUMSER = '"+Self:GetNumSer()+"'"
	EndIf
	cWhere += "%"

	
	BeginSql Alias cAliasD16
	SELECT D16.R_E_C_N_O_ RECNOD16
	  FROM %Table:D16% D16
	 WHERE D16.D16_FILIAL = %xFilial:D16%
	   AND D16.D16_EMBARQ = %Exp:Self:GetEmbarq()%
	   AND D16.D16_CODOPE = %Exp:Self:cCodOpe%
	   AND D16.D16_PRDORI = %Exp:Self:GetPrdOri()%
	   AND D16.D16_PRODUT = %Exp:Self:GetProduto()%
	   AND D16.%NotDel%
	   %Exp:cWhere%
	EndSql
	
	While (cAliasD16)->(!EoF())
		D16->(DbGoTo((cAliasD16)->RECNOD16))
		RecLock('D16',.F.)
		D16->D16_DATFIM := dDataBase
		D16->D16_HORFIM := Time()
		D16->(MsUnLock())
		(cAliasD16)->(DbSkip())
	EndDo
	(cAliasD16)->(DbCloseArea())
	
Return .T.
/*/{Protheus.doc} EstEmbItem
Estorna embarque do operador carregado no objeto
@author amanda.vieira
@since 15/06/2020
@param nQuantEst, numérico, quantidade que deve ser estornada do operador / item
@return lRet, lógico, se retorno igual à true indica que operador / item foi estornado
/*/
METHOD EstEmbOpe(nQuantEst) CLASS WMSDTCEmbarqueExpedicaoEmbarqueOperador
Local lRet := .T.
Default nQuantEst := Self:nQtdEmb
	//Estorna D0Z (Item do Embarque)
	lRet := Self:EstEmbItem(nQuantEst)
	//Estorna D16 (Conferência por operador)
	If lRet
		Self:nQtdEmb -= nQuantEst
		lRet := Self:UpdateD16()
	EndIf
	//Atualiza D0X (Status do Embarque)
	If lRet
		lRet := Self:oEmbExpIt:oEmbExp:UpdateD0X()
	EndIf
Return lRet
/*/{Protheus.doc} EstEmbItem
Estorna embarque por item, conforme quantidade definida para estorno
@author amanda.vieira
@since 15/06/2020
@param nQuantEst, numérico, quantidade que deve ser estornada do item
@return lRet, lógico, se retorno igual à true indica que item foi estornado da tabela D0Z
/*/
METHOD EstEmbItem(nQtdEst) CLASS WMSDTCEmbarqueExpedicaoEmbarqueOperador
Local cAliasD0Z   := GetNextAlias()
Local oEstEmbItem := WMSDTCEmbarqueExpedicaoItens():New()
Local lRet        := .T.
Local nQtdEmb     := 0
	BeginSql Alias cAliasD0Z
		SELECT R_E_C_N_O_ RECNOD0Z
		  FROM %Table:D0Z% D0Z
		 WHERE D0Z.D0Z_FILIAL = %xFilial:D0Z%
		   AND D0Z.D0Z_EMBARQ = %Exp:Self:GetEmbarq()%
		   AND D0Z.D0Z_CARGA = %Exp:Self:GetCarga()%
		   AND D0Z.D0Z_PEDIDO = %Exp:Self:GetPedido()%
		   AND D0Z.D0Z_ITEM = %Exp:Self:GetItem()%
		   AND D0Z.D0Z_SEQUEN = %Exp:Self:GetSequen()%
		   AND D0Z.D0Z_PRDORI = %Exp:Self:GetPrdOri()%
		   AND D0Z.D0Z_PRODUT = %Exp:Self:GetProduto()%
		   AND D0Z.%NotDel%
	EndSql
	While (cAliasD0Z)->(!EoF()) .And. nQtdEst > 0
		oEstEmbItem:GoToD0Z((cAliasD0Z)->RECNOD0Z)
		nQtdEmb := oEstEmbItem:GetQtdEmb()
		If (nQtdEmb >= nQtdEst)
			oEstEmbItem:SetQtdEmb(nQtdEmb - nQtdEst)
		Else
			oEstEmbItem:SetQtdEmb(0)
		EndIf
		nQtdEst -= nQtdEmb
		oEstEmbItem:UpdateD0Z()
		(cAliasD0Z)->(DbSkip())
	EndDo
	(cAliasD0Z)->(DbCloseArea())
	FreeObj(oEstEmbItem)

Return lRet
