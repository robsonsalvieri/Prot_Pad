#Include "Totvs.ch" 
#Include "WMSDTCEmbarqueExpedicaoItens.ch"

//---------------------------------------------
/*/{Protheus.doc} WMSCLS0064
Função para permitir que a classe seja visualizada
no inspetor de objetos 
@author Inovação WMS
@since 13/12/2018
@version 1.0
/*/
//---------------------------------------------
Function WMSCLS0064()
Return Nil
//---------------------------------------------
/*/{Protheus.doc} WMSDTCEmbarqueExpedicaoItens
(long_description)
@author    Squad WMS/OMS Protheus
@since     13/12/2018
@version   1.0
/*/
//---------------------------------------------
CLASS WMSDTCEmbarqueExpedicaoItens FROM LongNameClass
	DATA oEmbExp
	DATA oProdLote
	DATA aVolume
	DATA aDocEmb
	DATA cCarga
	DATA cPedido
	DATA cItem
	DATA cSequen
	DATA cNFiscal
	DATA cNFSerie
	DATA cRomEmb
	DATA cStatus
	DATA cIdDCF
	DATA cArmazem
	DATA cEnder
	DATA nQtdOri
	DATA nQtdEmb
	DATA nQuant
	DATA nTotOri
	DATA nTotEmb
	DATA lEstorno
	DATA lD0ZLocal
	DATA cErro
	DATA nRecno
	
	METHOD New() CONSTRUCTOR
	METHOD Destroy()
	METHOD GoToD0Z(nRecno)
	METHOD LoadData(nIndex)
	METHOD ClearData()
	METHOD AssignD17()
	METHOD AssignD0Z()
	METHOD RecordD0Z()
	METHOD UpdateD0Z(nQuantEst)
	METHOD ExcludeD0Z()
	METHOD ExcludeD17()
	METHOD GetRecno()
	METHOD GetErro()
	METHOD SetEmbarq(cEmbarque)
	METHOD SetTransp(cTransp)
	METHOD SetCarga(cCarga)
	METHOD SetPedido(cPedido)
	METHOD SetItem(cItem)
	METHOD SetSequen(cSequen)
	METHOD SetNFiscal(cNFiscal)
	METHOD SetNFSerie(cNFSerie)
	METHOD SetRomEmb(cRomEmb)
	METHOD SetPrdOri(cPrdOri)
	METHOD SetProduto(cProduto)
	METHOD SetLoteCtl(cLoteCtl)
	METHOD SetNumLote(cNumLote)
	METHOD SetNumSer(cNumSer)
	METHOD SetStatus(cStatus)
	METHOD SetIdDCF(cIdDCF)
	METHOD SetArmazem(cArmazem)
	METHOD SetEnder(cEnder)
	METHOD SetQtdOri(nQtdOri)
	METHOD SetQtdEmb(nQtdEmb)
	METHOD SetQuant(nQuant)
	METHOD SetArrVol(aVolume)
	METHOD SetReverse(lEstorno)
	
	METHOD GetEmbarq()
	METHOD GetTransp()
	METHOD GetCarga()
	METHOD GetPedido()
	METHOD GetItem()
	METHOD GetSequen()
	METHOD GetNFiscal()
	METHOD GetNFSerie()
	METHOD GetRomEmb()
	METHOD GetPrdOri()
	METHOD GetProduto()
	METHOD GetLoteCtl()
	METHOD GetNumLote()
	METHOD GetNumSer()
	METHOD GetStatus()
	METHOD GetIdDCF()
	METHOD GetArmazem()
	METHOD GetEnder()
	METHOD GetQtdOri()
	METHOD GetQtdEmb()
	METHOD GetQuant()
	METHOD GetArrVol()
	METHOD GetArrDoc()
	METHOD GetReverse()
	
	METHOD CalcEmbExp()
	METHOD ChangeData(nOpc)
	METHOD FindDocEmb()
	METHOD CanEstEmb()
	METHOD EstEmbItem(nQuantEst)
	METHOD EstEmbOp(nQtdEst)
	METHOD WmsEndD00(nOpcao)
ENDCLASS
//---------------------------------------------
/*/{Protheus.doc} New
Metodo construtor
@author    Squad WMS/OMS Protheus
@since     13/12/2018
@version   1.0
/*/
//---------------------------------------------
METHOD New() CLASS WMSDTCEmbarqueExpedicaoItens
	Self:oEmbExp   := WMSDTCEmbarqueExpedicao():New()
	Self:oProdLote := WMSDTCProdutoLote():New()
	Self:cCarga   := PadR("",TamSx3("D0Z_CARGA")[1])
	Self:cPedido  := PadR("",TamSx3("D0Z_PEDIDO")[1])
	Self:cItem    := PadR("",TamSx3("D0Z_ITEM")[1])
	Self:cSequen  := PadR("",TamSx3("D0Z_SEQUEN")[1])
	Self:cRomEmb  := PadR("",TamSx3("C9_ROMEMB")[1])
	Self:cNFiscal := PadR("",TamSx3("C9_NFISCAL")[1])
	Self:cNFSerie := PadR("",TamSx3("C9_SERIENF")[1])
	Self:cIdDCF   := PadR("",TamSx3("D17_IDDCF")[1])
	Self:cArmazem := PadR("",TamSx3("BE_LOCAL")[1])
	Self:cEnder   := PadR("",TamSx3("BE_LOCALIZ")[1])
	Self:lD0ZLocal:= D0Z->(ColumnPos("D0Z_LOCAL")) > 0
	Self:aVolume  := {}
	Self:aDocEmb  := {}
	Self:ClearData()
return
//-----------------------------------------
/*/{Protheus.doc} ClearData
Inicializa os campos
@author    Squad WMS/OMS Protheus
@since     12/12/2018
@version   1.0
/*/
//-----------------------------------------
METHOD ClearData() CLASS WMSDTCEmbarqueExpedicaoItens
	Self:oEmbExp:ClearData()
	Self:oProdLote:ClearData()
	Self:cCarga   := PadR("",Len(Self:cCarga))
	Self:cPedido  := PadR("",Len(Self:cPedido))
	Self:cItem    := PadR("",Len(Self:cItem))
	Self:cSequen  := PadR("",Len(Self:cSequen))
	Self:cRomEmb  := PadR("",Len(Self:cRomEmb))
	Self:cNFiscal := PadR("",Len(Self:cNFiscal))
	Self:cNFSerie := PadR("",Len(Self:cNFSerie))
	Self:cIdDCF   := PadR("",Len(Self:cIdDCF))
	Self:cArmazem := PadR("",Len(Self:cArmazem))
	Self:cEnder   := PadR("",Len(Self:cEnder))
	Self:cStatus  := "1"
	Self:nQtdOri  := 0
	Self:nQtdEmb  := 0
	Self:nQuant   := 0
	Self:lEstorno := .F.
	Self:cErro    := ""
	Self:nRecno   := 0
Return
//-----------------------------------------
/*/{Protheus.doc} Destroy
Destroi o objeto da memória
@author Squad WMS/OMS Protheus
@since 13/12/2018
@version 1.0
/*/
//-----------------------------------------
METHOD Destroy() CLASS WMSDTCEmbarqueExpedicaoItens
	/*Mantido para compatibilidade*/
Return
//----------------------------------------
/*/{Protheus.doc} GoToD0Z
Posicionamento para atualização das propriedades
@author Squad WMS/OMS Protheus
@since 13/12/2018
@version 1.0
@param nRecno, numérico, (Descrição do parâmetro)
/*/
//----------------------------------------
METHOD GoToD0Z(nRecno) CLASS WMSDTCEmbarqueExpedicaoItens
	Self:nRecno := nRecno
Return Self:LoadData(0)
//-----------------------------------------
/*/{Protheus.doc} LoadData
Carregamento dos dados D0X
@author alexsander.correa
@since 13/12/2018
@version 1.0
@param nIndex, numérico, (Descrição do parâmetro)
/*/
//-----------------------------------------
METHOD LoadData(nIndex) CLASS WMSDTCEmbarqueExpedicaoItens
Local lRet        := .T.
Local aAreaAnt    := GetArea()
Local aD0Z_QTDORI := TamSx3("D0Z_QTDORI")
Local aD0Z_QTDEMB := TamSx3("D0Z_QTDEMB")
Local aAreaD0Z    := D0Z->(GetArea())
Local cAliasD0Z   := Nil
Local cWhere      := ""
Local cSelect     := ""
Default nIndex := 1
	Do Case
		Case nIndex == 0
			If Empty(Self:nRecno)
				lRet := .F.
			EndIf
		Case nIndex == 1 // D0Z_FILIAL+D0Z_EMBARQ+D0Z_CARGA+D0Z_PEDIDO+D0Z_ITEM+D0Z_SEQUEN+D0Z_PRDORI+D0Z_PRODUT
			If Empty(Self:GetEmbarq()) .Or. Empty(Self:cPedido) .Or. Empty(Self:cItem) .Or. Empty(Self:cSequen) .Or. Empty(Self:oProdLote:GetPrdOri()) .Or. Empty(Self:oProdLote:GetProduto())
				lRet := .F.
			EndIf
		Otherwise
			lRet := .F.
	EndCase
	If !lRet
		Self:cErro := STR0001 // Dados para busca não foram informados!
	Else
		cSelect := "%"
		If Self:lD0ZLocal
			cSelect += ",D0Z_LOCAL"
		EndIf
		cSelect += "%"
		cWhere := "%"
		If !Empty(Self:cCarga)
			cWhere += " AND D0Z.D0Z_CARGA = '"+Self:cCarga+"'"
		EndIf
		If !Empty(Self:cPedido)
			cWhere += " AND D0Z.D0Z_PEDIDO = '"+Self:cPedido+"'"
		EndIf
		If !Empty(Self:cItem)
			cWhere += " AND D0Z.D0Z_ITEM = '"+Self:cItem+"'"
		EndIf
		If !Empty(Self:cSequen)
			cWhere += " AND D0Z.D0Z_SEQUEN = '"+Self:cSequen+"'"
		EndIf
		If !Empty(Self:oProdLote:GetLoteCtl())
			cWhere += " AND D0Z.D0Z_LOTECT = '"+Self:oProdLote:GetLoteCtl()+"'"
		EndIf
		If !Empty(Self:oProdLote:GetNumLote())
			cWhere += " AND D0Z.D0Z_NUMLOT = '"+Self:oProdLote:GetNumLote()+"'"
		EndIf
		If !Empty(Self:oProdLote:GetNumSer())
			cWhere += " AND D0Z.D0Z_NUMSER = '"+Self:oProdLote:GetNumSer()+"'"
		EndIf
		If Self:lD0ZLocal
			If !Empty(Self:cArmazem)
				cWhere += " AND (D0Z.D0Z_LOCAL = '"+Self:cArmazem+"' OR D0Z.D0Z_LOCAL = ' ')"
			EndIf
			If !Empty(Self:cEnder)
				cWhere += " AND (D0Z.D0Z_ENDER = '"+Self:cEnder+"' OR D0Z.D0Z_ENDER = ' ')"
			EndIf
		EndIf
		cWhere += "%"
		cAliasD0Z := GetNextAlias()
		Do Case
			Case nIndex == 0
				BeginSql Alias cAliasD0Z
					SELECT D0Z.D0Z_EMBARQ,
							D0Z.D0Z_CARGA,
							D0Z.D0Z_PEDIDO,
							D0Z.D0Z_ITEM,
							D0Z.D0Z_SEQUEN,
							D0Z.D0Z_PRDORI,
							D0Z.D0Z_PRODUT,
							D0Z.D0Z_LOTECT,
							D0Z.D0Z_NUMLOT,
							D0Z.D0Z_NUMSER,
							D0Z.D0Z_STATUS,
							D0Z.D0Z_QTDORI,
							D0Z.D0Z_QTDEMB,
							D0Z.R_E_C_N_O_ RECNOD0Z
							%Exp:cSelect%
					FROM %Table:D0Z% D0Z
					WHERE D0Z.D0Z_FILIAL = %xFilial:D0Z%
					AND D0Z.R_E_C_N_O_ = %Exp:AllTrim(Str(Self:nRecno))%
					AND D0Z.%NotDel%
				EndSql
			Case nIndex == 1
				BeginSql Alias cAliasD0Z
					SELECT D0Z.D0Z_EMBARQ,
							D0Z.D0Z_CARGA,
							D0Z.D0Z_PEDIDO,
							D0Z.D0Z_ITEM,
							D0Z.D0Z_SEQUEN,
							D0Z.D0Z_PRDORI,
							D0Z.D0Z_PRODUT,
							D0Z.D0Z_LOTECT,
							D0Z.D0Z_NUMLOT,
							D0Z.D0Z_NUMSER,
							D0Z.D0Z_STATUS,
							D0Z.D0Z_QTDORI,
							D0Z.D0Z_QTDEMB,
							D0Z.R_E_C_N_O_ RECNOD0Z
							%Exp:cSelect%
					FROM %Table:D0Z% D0Z
					WHERE D0Z.D0Z_FILIAL = %xFilial:D0Z%
					AND D0Z.D0Z_EMBARQ = %Exp:Self:GetEmbarq()%
					AND D0Z.D0Z_PRDORI = %Exp:Self:oProdLote:GetPrdOri()%
					AND D0Z.D0Z_PRODUT = %Exp:Self:oProdLote:GetProduto()%
					AND D0Z.%NotDel%
					%Exp:cWhere%
				EndSql
		EndCase
		TCSetField(cAliasD0Z,'D0Z_QTDORI','N',aD0Z_QTDORI[1],aD0Z_QTDORI[2])
		TCSetField(cAliasD0Z,'D0Z_QTDEMB','N',aD0Z_QTDEMB[1],aD0Z_QTDEMB[2])
		If (lRet := (cAliasD0Z)->(!Eof()))
			// Carrega embarque de expedição
			Self:SetEmbarq((cAliasD0Z)->D0Z_EMBARQ)
			Self:oEmbExp:LoadData()
			// Carrega dados do produto
			If Self:lD0ZLocal
				Self:oProdLote:SetArmazem((cAliasD0Z)->D0Z_LOCAL)
			EndIf
			Self:oProdLote:SetPrdOri((cAliasD0Z)->D0Z_PRDORI)
			Self:oProdLote:SetProduto((cAliasD0Z)->D0Z_PRODUT)
			Self:oProdLote:SetLoteCtl((cAliasD0Z)->D0Z_LOTECT)
			Self:oProdLote:SetNumLote((cAliasD0Z)->D0Z_NUMLOT)
			Self:oProdLote:SetNumSer((cAliasD0Z)->D0Z_NUMSER)
			Self:oProdLote:LoadData()
			// Atribui informações dos itens do embarque de expedição
			Self:cCarga   := (cAliasD0Z)->D0Z_CARGA
			Self:cPedido  := (cAliasD0Z)->D0Z_PEDIDO
			Self:cItem    := (cAliasD0Z)->D0Z_ITEM
			Self:cSequen  := (cAliasD0Z)->D0Z_SEQUEN
			Self:cStatus  := (cAliasD0Z)->D0Z_STATUS
			Self:nQtdOri  := (cAliasD0Z)->D0Z_QTDORI
			Self:nQtdEmb  := (cAliasD0Z)->D0Z_QTDEMB
			Self:nRecno   := (cAliasD0Z)->RECNOD0Z
		EndIf
		(cAliasD0Z)->(dbCloseArea())
	EndIf
	RestArea(aAreaD0Z)
	RestArea(aAreaAnt)
Return lRet
//-----------------------------------------
/*/{Protheus.doc} AssignD17
Cria registro na tabela de Embarque Expedição x OS

@author  Squad WMS/OMS Protheus
@since   14/12/2018
@version 1.0
/*/
//-----------------------------------------
METHOD AssignD17() CLASS WMSDTCEmbarqueExpedicaoItens
	D17->(DbSetOrder(1)) // D0H_FILIAL+D0H_CODEXP+D0H_IDDCF
	If !D17->(DbSeek(xFilial('D17')+Self:GetEmbarq()+Self:cIdDCF))
		RecLock('D17',.T.)
		D17->D17_FILIAL := xFilial('D17')
		D17->D17_EMBARQ := Self:GetEmbarq()
		D17->D17_IDDCF  := Self:cIdDCF
		D17->(MsUnlock())
	EndIf
Return .T.
//-----------------------------------------
/*/{Protheus.doc} AssignD0Z
Cria registro na tabela de Embarque Expedição 
e itens do embarque de expedição

@author  Squad WMS/OMS Protheus
@since   14/12/2018
@version 1.0
/*/
//-----------------------------------------
METHOD AssignD0Z() CLASS WMSDTCEmbarqueExpedicaoItens
Local lRet    := .T.
Local nQtdOri := Self:nQtdOri
Local aAreaAnt:= GetArea()
	// Verifica se há conferência cadastra
	If !Self:oEmbExp:LoadData()
		// Cria nova conferência
		If !Self:oEmbExp:RecordD0X()
			lRet := .F.
			Self:cErro := Self:oEmbExp:GetErro()
		EndIf
	EndIf
	If lRet
		// Atualiza codigo da conferência
		If Self:LoadData()
			Self:nQtdOri += nQtdOri
			lRet := Self:UpdateD0Z()
		Else
			lRet := Self:RecordD0Z()
		EndIf
		If lRet
			Self:AssignD17()
		EndIf
	EndIf
	RestArea(aAreaAnt)
Return lRet
//-----------------------------------------
/*/{Protheus.doc} RecordD0Z
Cria registro na tabela de Itens do Embarque Expedição

@author  Squad WMS/OMS Protheus
@since   14/12/2018
@version 1.0
/*/
//-----------------------------------------
METHOD RecordD0Z() CLASS WMSDTCEmbarqueExpedicaoItens
Local lRet   := .T.
Local lDbSeek := .T. 

	Self:cStatus := "1"
	DbSelectArea("D0Z")
	D0Z->(DbSetOrder(1)) // D0Z_FILIAL+D0Z_CARGA+D0Z_EMBARQ+D0Z_PEDIDO+D0Z_ITEM+D0Z_SEQUEN+D0Z_PRDORI+D0Z_PRODUT+D0Z_LOCAL+D0Z_ENDER
	If Self:lD0ZLocal
		lDbSeek := D0Z->(dbSeek(xFilial("D0Z")+Self:GetEmbarq()+Self:cCarga+Self:cPedido+Self:cItem+Self:cSequen+Self:oProdLote:GetPrdOri()+Self:oProdLote:GetProduto()+Self:cArmazem+Self:cEnder))
	Else
		lDbSeek:= D0Z->(dbSeek(xFilial("D0Z")+Self:GetEmbarq()+Self:cCarga+Self:cPedido+Self:cItem+Self:cSequen+Self:oProdLote:GetPrdOri()+Self:oProdLote:GetProduto()))
	EndIf 
	If !lDbSeek
		Reclock('D0Z',.T.)
		D0Z->D0Z_Filial := xFilial("D0Z")
		D0Z->D0Z_EMBARQ := Self:GetEmbarq()
		D0Z->D0Z_CARGA  := Self:cCarga
		D0Z->D0Z_PEDIDO := Self:cPedido
		D0Z->D0Z_ITEM   := Self:cItem
		D0Z->D0Z_SEQUEN := Self:cSequen
		D0Z->D0Z_PRDORI := Self:oProdLote:GetPrdOri()
		D0Z->D0Z_PRODUT := Self:oProdLote:GetProduto()
		D0Z->D0Z_LOTECT := Self:oProdLote:GetLoteCtl()
		D0Z->D0Z_NUMLOT := Self:oProdLote:GetNumLote()
		D0Z->D0Z_NUMSER := Self:oProdLote:GetNumSer()
		D0Z->D0Z_STATUS := Self:cStatus
		D0Z->D0Z_QTDORI := Self:nQtdOri
		D0Z->D0Z_QTDEMB := Self:nQtdEmb
		If Self:lD0ZLocal
			D0Z->D0Z_ENDER  := Self:cEnder
			D0Z->D0Z_LOCAL  := Self:cArmazem
		EndIf
		D0Z->(MsUnLock())
		// Grava recno
		Self:nRecno := D0Z->(Recno())
		// Analise se produto é componente
		If D0Z->D0Z_PRODUT <> D0Z->D0Z_PRDORI
			// D0Z_FILIAL+D0Z_EMBARQ+D0Z_CARGA+D0Z_PEDIDO+D0Z_ITEM+D0Z_SEQUEN+D0Z_PRDORI+D0Z_PRODUT+D0Z_LOCAL+D0Z_ENDER
			If Self:lD0ZLocal
				lDbSeek := D0Z->(dbSeek(xFilial("D0Z")+Self:GetEmbarq()+Self:cCarga+Self:cPedido+Self:cItem+Self:cSequen+Self:oProdLote:GetPrdOri()+Self:oProdLote:GetProduto()+Self:cArmazem+Self:cEnder))
			Else
				lDbSeek:= D0Z->(dbSeek(xFilial("D0Z")+Self:GetEmbarq()+Self:cCarga+Self:cPedido+Self:cItem+Self:cSequen+Self:oProdLote:GetPrdOri()+Self:oProdLote:GetProduto()))
			EndIf 
			If !lDbSeek
				RecLock('D0Z', .T.)
				D0Z->D0Z_Filial := xFilial("D0Z")
				D0Z->D0Z_EMBARQ := Self:GetEmbarq()
				D0Z->D0Z_CARGA  := Self:cCarga
				D0Z->D0Z_PEDIDO := Self:cPedido
				D0Z->D0Z_ITEM   := Self:cItem
				D0Z->D0Z_SEQUEN := Self:cSequen
				D0Z->D0Z_PRDORI := Self:oProdLote:GetPrdOri()
				D0Z->D0Z_PRODUT := Self:oProdLote:GetPrdOri()
				D0Z->D0Z_LOTECT := Self:oProdLote:GetLoteCtl()
				D0Z->D0Z_NUMLOT := Self:oProdLote:GetNumLote()
				D0Z->D0Z_NUMSER := Self:oProdLote:GetNumSer()
				D0Z->D0Z_STATUS := Self:cStatus
				If Self:lD0ZLocal
					D0Z->D0Z_ENDER  := Self:cEnder
					D0Z->D0Z_LOCAL  := Self:cArmazem
				EndIf
				D0Z->(MsUnLock())
			EndIf
			Self:CalcEmbExp()
			RecLock('D0Z', .F.)
			D0Z->D0Z_QTDORI := Self:nTotOri
			D0Z->D0Z_QTDEMB := Self:nTotEmb
			D0Z->D0Z_STATUS := Self:cStatus
			D0Z->(MsUnLock())
		EndIf
	Else
		lRet := .F.
		Self:cErro := STR0003 // Chave duplicada!
	EndIf
Return lRet

METHOD UpdateD0Z(nQuantEst) CLASS WMSDTCEmbarqueExpedicaoItens
Local aProduto   := {}
Local cStatus    := ""
Local lRet       := .T.
Local nI         := 0
Local nQtdEmbCon := 0
Local lDbSeek    := .T.
Default nQuantEst := 0

	If !Empty(Self:GetRecno())
		D0Z->(dbGoTo( Self:GetRecno() ))
		// Status
		If QtdComp(Self:nQtdEmb) == 0
			Self:cStatus := "1" // Aguardando Conferencia
		ElseIf QtdComp(Self:nQtdOri) == QtdComp(Self:nQtdEmb)
			Self:cStatus := "3" // Conferido
		Else
			Self:cStatus := "2" // Conferencia em Andamento
		EndIf
		// Grava
		RecLock('D0Z', .F.)
		D0Z->D0Z_QTDORI := Self:nQtdOri
		D0Z->D0Z_QTDEMB := Self:nQtdEmb
		D0Z->D0Z_STATUS := Self:cStatus
		D0Z->(MsUnLock())
		If D0Z->D0Z_PRODUT <> D0Z->D0Z_PRDORI
			If Self:lD0ZLocal
				lDbSeek := D0Z->(dbSeek(xFilial("D0Z")+D0Z_EMBARQ+D0Z_CARGA+D0Z_PEDIDO+D0Z_ITEM+D0Z_SEQUEN+D0Z_PRDORI+D0Z_PRODUT+D0Z_LOCAL+D0Z_ENDER))
			Else
				lDbSeek:= D0Z->(dbSeek(xFilial("D0Z")+D0Z_EMBARQ+D0Z_CARGA+D0Z_PEDIDO+D0Z_ITEM+D0Z_SEQUEN+D0Z_PRDORI+D0Z_PRODUT))
			EndIf 
			If lDbSeek
				Self:CalcEmbExp()
				If QtdComp(Self:nTotEmb) == 0
					cStatus := "1" // Aguardando Conferencia
				ElseIf QtdComp(Self:nTotEmb) > 0 .And. QtdComp(Self:nTotEmb) == QtdComp(D0Z->D0Z_QTDORI)
					cStatus := "3" // Conferido
				Else
					cStatus := "2" // Conferencia em Andamento
				EndIf

				Self:CalcEmbExp()
				RecLock('D0Z', .F.)
				D0Z->D0Z_QTDEMB := Self:nTotEmb
				D0Z->D0Z_STATUS := cStatus
				D0Z->(MsUnLock())
			EndIf
		ElseIf Self:lEstorno .And. D0Z->D0Z_PRODUT == D0Z->D0Z_PRDORI
			aProduto := Self:oProdLote:GetArrProd()
			If !Empty(aProduto)
				For nI := 1 To Len(aProduto)
					If !(aProduto[nI][1] == aProduto[nI][3])
						If Self:lD0ZLocal
							lDbSeek := D0Z->(dbSeek(xFilial("D0Z")+D0Z_EMBARQ+D0Z_CARGA+D0Z_PEDIDO+D0Z_ITEM+D0Z_SEQUEN+D0Z_PRDORI+aProduto[nI][1]+D0Z_LOCAL+D0Z_ENDER))
						Else
							lDbSeek:= D0Z->(dbSeek(xFilial("D0Z")+D0Z_EMBARQ+D0Z_CARGA+D0Z_PEDIDO+D0Z_ITEM+D0Z_SEQUEN+D0Z_PRDORI+aProduto[nI][1]))
						EndIf 
						If lDbSeek 
							nQtdEmbCon := D0Z->D0Z_QTDEMB - (nQuantEst * aProduto[nI][2]) //Quantidade embalada convertida para o produto componente
							If QtdComp(nQtdEmbCon) == 0
								cStatus := "1" // Aguardando Conferencia
							ElseIf QtdComp(D0Z->D0Z_QTDORI) == QtdComp(nQtdEmbCon)
								cStatus := "3" // Conferido
							Else
								cStatus := "2" // Conferencia em Andamento
							EndIf
							RecLock('D0Z', .F.)
							D0Z->D0Z_QTDEMB := nQtdEmbCon
							D0Z->D0Z_STATUS := cStatus
							D0Z->(MsUnLock())
						EndIf
					EndIf
				Next nI
			EndIf
		EndIf
	Else
		lRet := .F.
		Self:cErro := STR0002 // Dados não encontrados!
	EndIf
Return lRet
//-----------------------------------------
/*/{Protheus.doc} ExcludeD0Z
Exclui a capa do embarque
@author Squad WMS/OMS Protheus
@since 13/12/2018
@version 1.0
/*/
//-----------------------------------------
METHOD ExcludeD0Z() CLASS WMSDTCEmbarqueExpedicaoItens
Local lRet := .T.
	D0Z->(dbGoTo( Self:GetRecno() ))
	// Excluindo item do embarque de expedição
	RecLock('D0Z', .F.)
	D0Z->(dbDelete())
	D0Z->(MsUnlock())
Return lRet
//-----------------------------------------
/*/{Protheus.doc} ExcludeD17
Exclui a capa do embarque
@author Squad WMS/OMS Protheus
@since 13/12/2018
@version 1.0
/*/
//-----------------------------------------
METHOD ExcludeD17() CLASS WMSDTCEmbarqueExpedicaoItens
Local lRet := .T.
	D17->(dbGoTo( Self:GetRecno() ))
	// Excluindo a capa do embarque de expedição
	RecLock('D17', .F.)
	D17->(dbDelete())
	D17->(MsUnlock())
Return lRet

METHOD GetRecno() CLASS WMSDTCEmbarqueExpedicaoItens
Return Self:nRecno

METHOD GetErro() CLASS WMSDTCEmbarqueExpedicaoItens
Return Self:cErro

//-----------------------------------
// Setters
//-----------------------------------
METHOD SetEmbarq(cEmbarque) CLASS WMSDTCEmbarqueExpedicaoItens
	Self:oEmbExp:SetEmbarq(cEmbarque)
Return

METHOD SetCarga(cCarga) CLASS WMSDTCEmbarqueExpedicaoItens
	Self:cCarga := PadR(cCarga, Len(Self:cCarga))
Return

METHOD SetPedido(cPedido) CLASS WMSDTCEmbarqueExpedicaoItens
	Self:cPedido := PadR(cPedido, Len(Self:cPedido))
Return

METHOD SetItem(cItem) CLASS WMSDTCEmbarqueExpedicaoItens
	Self:cItem := PadR(cItem, Len(Self:cItem))
Return

METHOD SetSequen(cSequen) CLASS WMSDTCEmbarqueExpedicaoItens
	Self:cSequen := PadR(cSequen, Len(Self:cSequen))
Return

METHOD SetNFiscal(cNFiscal) CLASS WMSDTCEmbarqueExpedicaoItens
	Self:cNFiscal := PadR(cNFiscal, Len(Self:cNFiscal))
Return

METHOD SetNFSerie(cNFSerie) CLASS WMSDTCEmbarqueExpedicaoItens
	Self:cNFSerie := PadR(cNFSerie, Len(Self:cNFSerie))
Return

METHOD SetRomEmb(cRomEmb) CLASS WMSDTCEmbarqueExpedicaoItens
	Self:cRomEmb := PadR(cRomEmb, Len(Self:cRomEmb))
Return

METHOD SetPrdOri(cPrdOri) CLASS WMSDTCEmbarqueExpedicaoItens
	Self:oProdLote:SetPrdOri(cPrdOri)
Return

METHOD SetProduto(cProduto) CLASS WMSDTCEmbarqueExpedicaoItens
	Self:oProdLote:SetProduto(cProduto)
Return

METHOD SetLoteCtl(cLoteCtl) CLASS WMSDTCEmbarqueExpedicaoItens
	Self:oProdLote:SetLoteCtl(cLoteCtl)
Return

METHOD SetNumLote(cNumLote) CLASS WMSDTCEmbarqueExpedicaoItens
	Self:oProdLote:SetNumLote(cNumLote)
Return

METHOD SetNumSer(cNumSer) CLASS WMSDTCEmbarqueExpedicaoItens
	Self:oProdLote:SetNumSer(cNumSer)
Return

METHOD SetStatus(cStatus) CLASS WMSDTCEmbarqueExpedicaoItens
	Self:cStatus := PadR(cStatus, Len(Self:cStatus))
Return

METHOD SetIdDCF(cIdDCF) CLASS WMSDTCEmbarqueExpedicaoItens
	Self:cIdDCF := PadR(cIdDCF, Len(Self:cIdDCF))
Return

METHOD SetArmazem(cArmazem) CLASS WMSDTCEmbarqueExpedicaoItens
	Self:cArmazem := PadR(cArmazem, Len(Self:cArmazem))
Return

METHOD SetEnder(cEnder) CLASS WMSDTCEmbarqueExpedicaoItens
	Self:cEnder := PadR(cEnder, Len(Self:cEnder))
Return

METHOD SetQtdOri(nQtdOri) CLASS WMSDTCEmbarqueExpedicaoItens
	Self:nQtdOri := nQtdOri
Return

METHOD SetQtdEmb(nQtdEmb) CLASS WMSDTCEmbarqueExpedicaoItens
	Self:nQtdEmb := nQtdEmb
Return

METHOD SetQuant(nQuant) CLASS WMSDTCEmbarqueExpedicaoItens
	Self:nQuant := nQuant
Return

METHOD SetArrVol(aVolume) CLASS WMSDTCEmbarqueExpedicaoItens
	Self:aVolume := aVolume
Return

METHOD SetReverse(lEstorno) CLASS WMSDTCEmbarqueExpedicaoItens
	Self:lEstorno := lEstorno
Return

METHOD SetTransp(cTransp) CLASS WMSDTCEmbarqueExpedicaoItens
	Self:oEmbExp:SetTransp(cTransp)
Return
//-----------------------------------
// Getters
//-----------------------------------
METHOD GetEmbarq() CLASS WMSDTCEmbarqueExpedicaoItens
Return Self:oEmbExp:GetEmbarq()

METHOD GetTransp() CLASS WMSDTCEmbarqueExpedicaoItens
Return Self:oEmbExp:GetTransp()

METHOD GetCarga() CLASS WMSDTCEmbarqueExpedicaoItens
Return Self:cCarga

METHOD GetPedido() CLASS WMSDTCEmbarqueExpedicaoItens
Return Self:cPedido

METHOD GetItem() CLASS WMSDTCEmbarqueExpedicaoItens
Return Self:cItem

METHOD GetSequen() CLASS WMSDTCEmbarqueExpedicaoItens
Return Self:cSequen

METHOD GetNFiscal() CLASS WMSDTCEmbarqueExpedicaoItens
Return Self:cNFiscal

METHOD GetNFSerie() CLASS WMSDTCEmbarqueExpedicaoItens
Return Self:cNFSerie

METHOD GetRomEmb() CLASS WMSDTCEmbarqueExpedicaoItens
Return Self:cRomEmb

METHOD GetPrdOri() CLASS WMSDTCEmbarqueExpedicaoItens
Return Self:oProdLote:GetPrdOri()

METHOD GetProduto() CLASS WMSDTCEmbarqueExpedicaoItens
Return Self:oProdLote:GetProduto()

METHOD GetLoteCtl() CLASS WMSDTCEmbarqueExpedicaoItens
Return Self:oProdLote:GetLoteCtl()

METHOD GetNumLote() CLASS WMSDTCEmbarqueExpedicaoItens
Return Self:oProdLote:GetNumLote()

METHOD GetNumSer() CLASS WMSDTCEmbarqueExpedicaoItens
Return Self:oProdLote:GetNumSer()

METHOD GetStatus() CLASS WMSDTCEmbarqueExpedicaoItens
Return Self:cStatus

METHOD GetIdDCF() CLASS WMSDTCEmbarqueExpedicaoItens
Return Self:cIdDCf

METHOD GetArmazem() CLASS WMSDTCEmbarqueExpedicaoItens
Return Self:cArmazem

METHOD GetEnder() CLASS WMSDTCEmbarqueExpedicaoItens
Return Self:cEnder

METHOD GetQtdOri() CLASS WMSDTCEmbarqueExpedicaoItens
Return Self:nQtdOri

METHOD GetQtdEmb() CLASS WMSDTCEmbarqueExpedicaoItens
Return Self:nQtdEmb

METHOD GetQuant() CLASS WMSDTCEmbarqueExpedicaoItens
Return Self:nQuant

METHOD GetArrVol() CLASS WMSDTCEmbarqueExpedicaoItens
Return Self:aVolume

METHOD GetArrDoc() CLASS WMSDTCEmbarqueExpedicaoItens
Return Self:aDocEmb

METHOD GetReverse() CLASS WMSDTCEmbarqueExpedicaoItens
Return Self:lEstorno
//-----------------------------------------
/*/{Protheus.doc} CalcEmbExp
Exclui a capa do embarque
@author Squad WMS/OMS Protheus
@since 13/12/2018
@version 1.0
/*/
//-----------------------------------------
METHOD CalcEmbExp() CLASS WMSDTCEmbarqueExpedicaoItens
Local lRet      := .T.
Local aTamSx3   := TamSx3("D0Z_QTDEMB")
Local aAreaAnt  := GetArea()
Local cAliasD0Z := GetNextAlias()
	// ----------nAcao-----------
	// Totalizador dos itens da conferencia
	Self:nTotOri := 0
	Self:nTotEmb := 0
	BeginSql Alias cAliasD0Z
		SELECT MIN(D0Z.D0Z_QTDORI / CASE WHEN D11.D11_QTMULT IS NULL THEN 1 ELSE D11.D11_QTMULT END) D0Z_QTDORI,
				MIN(D0Z.D0Z_QTDEMB / CASE WHEN D11.D11_QTMULT IS NULL THEN 1 ELSE D11.D11_QTMULT END) D0Z_QTDEMB
		FROM %Table:D0Z% D0Z
		LEFT JOIN %Table:D11% D11
		ON D11_FILIAL = %xFilial:D11%
		AND D11.D11_PRDORI = D0Z.D0Z_PRDORI
		AND D11.D11_PRDCMP = D0Z.D0Z_PRODUT
		AND D11.%NotDel%
		WHERE D0Z.D0Z_FILIAL = %xFilial:D0Z%
		AND D0Z.D0Z_EMBARQ = %Exp:Self:GetEmbarq()%
		AND D0Z.D0Z_CARGA =  %Exp:Self:cCarga%
		AND D0Z.D0Z_PEDIDO = %Exp:Self:cPedido%
		AND D0Z.D0Z_ITEM = %Exp:Self:cItem%
		AND D0Z.D0Z_SEQUEN = %Exp:Self:cSequen%
		AND D0Z.D0Z_PRDORI = %Exp:Self:oProdLote:GetPrdOri()%
		AND D0Z.D0Z_LOTECT = %Exp:Self:oProdLote:GetLoteCtl()%
		AND D0Z.D0Z_NUMLOT = %Exp:Self:oProdLote:GetNumLote()%
		AND D0Z.D0Z_NUMSER = %Exp:Self:oProdLote:GetNumSer()%
		AND D0Z.D0Z_PRDORI <> D0Z.D0Z_PRODUT
		AND D0Z.%NotDel%
	EndSql
	TcSetField(cAliasD0Z,'D02_QTDORI','N',aTamSX3[1],aTamSX3[2])
	TcSetField(cAliasD0Z,'D02_QTDEMB','N',aTamSX3[1],aTamSX3[2])
	If (cAliasD0Z)->(!Eof())
		Self:nTotOri := (cAliasD0Z)->D0Z_QTDORI
		Self:nTotEmb := (cAliasD0Z)->D0Z_QTDEMB
	Else
		lRet := .F.
	EndIf
	(cAliasD0Z)->(dbCloseArea())
	RestArea(aAreaAnt)
Return lRet
//-----------------------------------------
/*/{Protheus.doc} ChangeData
Entrada de dados para o embarque
@author Squad WMS/OMS Protheus
@since 13/12/2018
@version 1.0
/*/
//-----------------------------------------
METHOD ChangeData(nOpcao) CLASS WMSDTCEmbarqueExpedicaoItens
Local lRet      := .T.
Local aTamSx3   := {}
Local aProduto  := {}
Local aAreaAnt  := GetArea()
Local cAliasQry := Nil
Local cAliasSC9 := Nil
Local cAliasD0Z := Nil
Local cAliasD00 := Nil
Local cEmbarque  := ""
Local nI        := 0
Local cWhere    := ""
Local lWMSAltDca:= SuperGetMV('MV_WMSALDC', .F., .F.) //Permite alterar DOCA
Local lD00Local := D00->( ColumnPos( "D00_LOCDOC" ) ) > 0
Local cSelD00   := ""
Local cSelRom   := '% 1=1 %'

Default nOpcao := 1

	cWhere := "%"
	If !Empty(Self:oEmbExp:GetTransp()) .And. nOpcao == 2
		cWhere += " AND NOT EXISTS (SELECT DISTINCT 1 "
        cWhere +=  " FROM " + RetSqlName('SC9')+" SC92"
		cWhere += " INNER JOIN " + RetSqlName('SD2')+" SD2" 
		cWhere += " ON SD2.D2_FILIAL = '"+xFilial('SD2')+"'"
		cWhere += " AND SD2.D2_PEDIDO = SC92.C9_PEDIDO "
		cWhere += " AND SD2.D2_ITEMPV = SC92.C9_ITEM "
		cWhere += " AND SD2.D2_DOC = SC92.C9_NFISCAL "
		cWhere += " AND SD2.D_E_L_E_T_ = ' ' "
		cWhere += " INNER JOIN " +  RetSqlName('SF2')+" SF2" 
		cWhere += " ON SF2.F2_FILIAL = '"+xFilial('SF2')+"'"
		cWhere += " AND SF2.F2_DOC = SD2.D2_DOC "
	    cWhere += " AND (SF2.F2_TRANSP IS NOT NULL  AND SF2.F2_TRANSP <> ' ' AND SF2.F2_TRANSP <> '"+Self:oEmbExp:GetTransp()+"') "
		cWhere += " AND SF2.D_E_L_E_T_ = ' ' "
		cWhere += " WHERE SC92.C9_FILIAL = '"+xFilial('SC9')+"'"
		cWhere += " AND SC92.C9_PEDIDO =  SC9.C9_PEDIDO "
		cWhere += " AND SC92.C9_ITEM   = SC9.C9_ITEM "
		cWhere += " AND SC92.C9_SEQUEN  = SC9.C9_SEQUEN "
		cWhere += " AND SC92.C9_PRODUTO = SC9.C9_PRODUTO "
		cWhere += " AND SC92.C9_NFISCAL <> ' ' "
		cWhere += " AND SC9.D_E_L_E_T_ = ' ' ) "
	EndIf
	cWhere += "%"

	cSelD00   := "%"
	If lD00Local .AND. lWMSAltDca
		If nOpcao == 1 .OR. nOpcao == 2
			cSelD00   += " AND NOT EXISTS (SELECT 1 "
			cSelD00   += "	FROM "+RetSqlName('D00')+ " D00"
			cSelD00   += "	WHERE D00.D00_FILIAL = '"+xFilial('D00')+"'"
			If nOpcao == 1
				cSelD00   += "	AND D00.D00_CARGA = SC9.C9_CARGA"
			EndIf 
			cSelD00   += "	AND D00.D00_PEDIDO = SC9.C9_PEDIDO "
			cSelD00   += "	AND D00.D00_CODDOC = ' '"
			cSelD00   += "	AND D00.D00_LOCDOC = ' '"
			cSelD00   += "  AND D00.D_E_L_E_T_ = ' ')"
		ElseIf nOpcao == 3
			cSelD00   += " AND NOT EXISTS (SELECT 1 "
			cSelD00   += "   FROM "+RetSqlName('DCV')+ " DCV" 
			cSelD00   += "	INNER JOIN "+RetSqlName('D00')+ " D00" 
			cSelD00   += "	ON 	D00.D00_FILIAL = '"+xFilial('D00')+"'"
			cSelD00   += "	AND D00.D00_PEDIDO = SC9.C9_PEDIDO "
			cSelD00   += "	AND D00.D00_CODVOL = DCV.DCV_CODVOL "
			cSelD00   += "	AND D00.D_E_L_E_T_ = ' ' "
			cSelD00   += "	AND D00.D00_CODDOC = ' ' "
			cSelD00   += "	AND D00.D00_LOCDOC = ' ' "
			cSelD00   += "  WHERE DCV.DCV_FILIAL =  '"+xFilial('DCV')+"'"
			cSelD00   += "  AND DCV.DCV_PEDIDO = SC9.C9_PEDIDO "
			cSelD00   += "  AND DCV.DCV_ITEM = SC9.C9_ITEM "
			cSelD00   += "	AND DCV.DCV_SEQUEN = SC9.C9_SEQUEN "
			cSelD00   += "	AND DCV.D_E_L_E_T_ = ' ' ) "
		else
			cSelD00   += " AND NOT EXISTS (SELECT 1  FROM " + RetSqlName('SC9') + " SC9"
			cSelD00   +=	" INNER JOIN " + RetSqlName('SD2') + " SD2"
			cSelD00   +=	" ON (SD2.D2_FILIAL = '"+xFilial('SD2')+"'"
			cSelD00   +=		" AND SD2.D2_PEDIDO = SC9.C9_PEDIDO"
			cSelD00   +=		" AND SD2.D2_ITEMPV = SC9.C9_ITEM"
			cSelD00   +=		" AND SD2.D2_DOC = SC9.C9_NFISCAL"
			cSelD00   += 		" AND SD2.D2_SERIE  = SC9.C9_SERIENF"
			cSelD00   +=		" AND SD2.D_E_L_E_T_ = ' ')"
			cSelD00   +=	" INNER JOIN " + RetSqlName('D00') + " D00"
			cSelD00   +=		" ON (D00.D00_FILIAL =  '"+xFilial('D00')+"'"
			cSelD00   +=	 		" AND D00.D00_PEDIDO = SC9.C9_PEDIDO"
			cSelD00   +=			" AND D00.D_E_L_E_T_ = ' ')"
			cSelD00   +=	" WHERE SC9.C9_FILIAL = '"+xFilial('SC9')+"'"
			cSelD00   += " AND SC9.C9_NFISCAL = '"+Self:cNFiscal+"'"
			cSelD00   +=	" AND SC9.C9_SERIENF = '"+Self:cNFSerie+"'"
			cSelD00   +=	" AND D00.D00_CODDOC = ' '"
			cSelD00   +=	" AND D00.D00_LOCDOC = ' '"
			cSelD00   +=	" AND SC9.D_E_L_E_T_ = ' ')"
		ENDIF
		cSelRom   := "% SC9.C9_ROMEMB = '"+Self:cRomEmb+"' %"
	EndIf
	cSelD00   += "%"


	// Busca itens para incluir no embarque
	cAliasSC9 := GetNextAlias()
	Do Case
		Case nOpcao == 1 // Carga
			BeginSql Alias cAliasSC9
				SELECT SC9.C9_LOCAL,
						SC9.C9_ENDPAD,
						SC9.C9_CARGA,
						SC9.C9_PEDIDO,
						SC9.C9_ITEM,
						SC9.C9_SEQUEN,
						SC9.C9_PRODUTO,
						SC9.C9_LOTECTL,
						SC9.C9_NUMLOTE,
						SC9.C9_NUMSERI,
						SC9.C9_QTDLIB,
						SC9.C9_IDDCF
				FROM %Table:SC9% SC9
				WHERE SC9.C9_FILIAL = %xFilial:SC9%
				AND SC9.C9_CARGA = %Exp:Self:cCarga%
				AND SC9.C9_BLWMS = '05'
				AND NOT EXISTS (SELECT 1
								FROM %Table:D0Z% D0Z
								WHERE D0Z.D0Z_FILIAL = %xFilial:D0Z%
								AND D0Z.D0Z_PEDIDO = SC9.C9_PEDIDO
								AND D0Z.D0Z_ITEM = SC9.C9_ITEM
								AND D0Z.D0Z_SEQUEN = SC9.C9_SEQUEN
								AND D0Z.%NotDel% )
				AND NOT EXISTS (SELECT 1
								FROM %Table:DCV% DCV
								WHERE DCV.DCV_FILIAL = %xFilial:DCV%
								AND DCV.DCV_PEDIDO = SC9.C9_PEDIDO
								AND DCV.DCV_ITEM = SC9.C9_ITEM
								AND DCV.DCV_SEQUEN = SC9.C9_SEQUEN
								AND DCV.%NotDel% )
								%Exp:cSelD00%
				AND SC9.%NotDel%
				UNION ALL
				SELECT SC9.C9_LOCAL,
						SC9.C9_ENDPAD,
						SC9.C9_CARGA,
						SC9.C9_PEDIDO,
						SC9.C9_ITEM,
						SC9.C9_SEQUEN,
						SC9.C9_PRODUTO,
						SC9.C9_LOTECTL,
						SC9.C9_NUMLOTE,
						SC9.C9_NUMSERI,
						SC9.C9_QTDLIB,
						SC9.C9_IDDCF
				FROM ( SELECT DCV.DCV_CODVOL
						FROM %Table:SC9% SC9
						INNER JOIN %Table:DCV% DCV
						ON DCV.DCV_FILIAL = %xFilial:DCV%
						AND DCV.DCV_PEDIDO = SC9.C9_PEDIDO
						AND DCV.DCV_ITEM = SC9.C9_ITEM
						AND DCV.DCV_SEQUEN = SC9.C9_SEQUEN
						AND DCV.%NotDel%
						WHERE SC9.C9_FILIAL = %xFilial:SC9%
						AND SC9.C9_CARGA = %Exp:Self:cCarga%
						AND SC9.C9_BLWMS = '05'
						AND NOT EXISTS (SELECT 1
										FROM %Table:D0Z% D0Z
										WHERE D0Z.D0Z_FILIAL = %xFilial:D0Z%
										AND D0Z.D0Z_PEDIDO = SC9.C9_PEDIDO
										AND D0Z.D0Z_ITEM = SC9.C9_ITEM
										AND D0Z.D0Z_SEQUEN = SC9.C9_SEQUEN
										AND D0Z.%NotDel% )
						%Exp:cSelD00%
						AND SC9.%NotDel%
						GROUP BY DCV.DCV_CODVOL) VOL
				INNER JOIN %Table:DCV% DCV
				ON DCV.DCV_FILIAL = %xFilial:DCV%
				AND DCV.DCV_CODVOL = VOL.DCV_CODVOL
				AND DCV.%NotDel%
				INNER JOIN %Table:SC9% SC9
				ON SC9.C9_FILIAL = %xFilial:SC9%
				AND SC9.C9_PEDIDO = DCV.DCV_PEDIDO
				AND SC9.C9_ITEM = DCV.DCV_ITEM
				AND SC9.C9_SEQUEN = DCV.DCV_SEQUEN
				AND SC9.C9_PRODUTO = DCV.DCV_PRDORI
				AND SC9.%NotDel%
				GROUP BY SC9.C9_LOCAL,
							SC9.C9_ENDPAD,
							SC9.C9_CARGA,
							SC9.C9_PEDIDO,
							SC9.C9_ITEM,
							SC9.C9_SEQUEN,
							SC9.C9_PRODUTO,
							SC9.C9_LOTECTL,
							SC9.C9_NUMLOTE,
							SC9.C9_NUMSERI,
							SC9.C9_QTDLIB,
							SC9.C9_IDDCF
			EndSql
		Case nOpcao == 2 // Pedido
			BeginSql Alias cAliasSC9
				SELECT SC9.C9_LOCAL,
						SC9.C9_ENDPAD,
						SC9.C9_CARGA,
						SC9.C9_PEDIDO,
						SC9.C9_ITEM,
						SC9.C9_SEQUEN,
						SC9.C9_PRODUTO,
						SC9.C9_LOTECTL,
						SC9.C9_NUMLOTE,
						SC9.C9_NUMSERI,
						SC9.C9_QTDLIB,
						SC9.C9_IDDCF
				FROM %Table:SC9% SC9
				WHERE SC9.C9_FILIAL = %xFilial:SC9%
				AND SC9.C9_PEDIDO = %Exp:Self:cPedido%
				AND SC9.C9_BLWMS = '05'
				AND NOT EXISTS (SELECT 1
								FROM %Table:D0Z% D0Z
								WHERE D0Z.D0Z_FILIAL = %xFilial:D0Z%
								AND D0Z.D0Z_PEDIDO = SC9.C9_PEDIDO
								AND D0Z.D0Z_ITEM = SC9.C9_ITEM
								AND D0Z.D0Z_SEQUEN = SC9.C9_SEQUEN
								AND D0Z.%NotDel% )
				AND NOT EXISTS (SELECT 1
								FROM %Table:DCV% DCV
								WHERE DCV.DCV_FILIAL = %xFilial:DCV%
								AND DCV.DCV_PEDIDO = SC9.C9_PEDIDO
								AND DCV.DCV_ITEM = SC9.C9_ITEM
								AND DCV.DCV_SEQUEN = SC9.C9_SEQUEN
								AND DCV.%NotDel% )
				%Exp:cWhere%
				AND SC9.%NotDel%
				%Exp:cSelD00%

				UNION ALL
				SELECT SC9.C9_LOCAL,
						SC9.C9_ENDPAD,
						SC9.C9_CARGA,
						SC9.C9_PEDIDO,
						SC9.C9_ITEM,
						SC9.C9_SEQUEN,
						SC9.C9_PRODUTO,
						SC9.C9_LOTECTL,
						SC9.C9_NUMLOTE,
						SC9.C9_NUMSERI,
						SC9.C9_QTDLIB,
						SC9.C9_IDDCF
				FROM ( SELECT DCV.DCV_CODVOL
						FROM %Table:SC9% SC9
						INNER JOIN %Table:DCV% DCV
						ON DCV.DCV_FILIAL = %xFilial:DCV%
						AND DCV.DCV_PEDIDO = SC9.C9_PEDIDO
						AND DCV.DCV_ITEM = SC9.C9_ITEM
						AND DCV.DCV_SEQUEN = SC9.C9_SEQUEN
						AND DCV.%NotDel%
						WHERE SC9.C9_FILIAL = %xFilial:SC9%
						AND SC9.C9_PEDIDO = %Exp:Self:cPedido%
						AND SC9.C9_BLWMS = '05'
						AND NOT EXISTS (SELECT 1 
										FROM %Table:D0Z% D0Z
										WHERE D0Z.D0Z_FILIAL = %xFilial:D0Z%
										AND D0Z.D0Z_PEDIDO = SC9.C9_PEDIDO
										AND D0Z.D0Z_ITEM = SC9.C9_ITEM
										AND D0Z.D0Z_SEQUEN = SC9.C9_SEQUEN
										AND D0Z.%NotDel% )
						%Exp:cSelD00%
						AND SC9.%NotDel%
						GROUP BY DCV.DCV_CODVOL) VOL
				INNER JOIN %Table:DCV% DCV
				ON DCV.DCV_FILIAL = %xFilial:DCV%
				AND DCV.DCV_CODVOL = VOL.DCV_CODVOL
				AND DCV.%NotDel%
				INNER JOIN %Table:SC9% SC9
				ON SC9.C9_FILIAL = %xFilial:SC9%
				AND SC9.C9_PEDIDO = DCV.DCV_PEDIDO
				AND SC9.C9_ITEM = DCV.DCV_ITEM
				AND SC9.C9_SEQUEN = DCV.DCV_SEQUEN
				AND SC9.C9_PRODUTO = DCV.DCV_PRDORI
				AND SC9.%NotDel%
				GROUP BY SC9.C9_LOCAL,
							SC9.C9_ENDPAD,
							SC9.C9_CARGA,
							SC9.C9_PEDIDO,
							SC9.C9_ITEM,
							SC9.C9_SEQUEN,
							SC9.C9_PRODUTO,
							SC9.C9_LOTECTL,
							SC9.C9_NUMLOTE,
							SC9.C9_NUMSERI,
							SC9.C9_QTDLIB,
							SC9.C9_IDDCF
			EndSql
		Case nOpcao == 3 // Romaneio de embarque
			BeginSql Alias cAliasSC9
				SELECT SC9.C9_LOCAL,
						SC9.C9_ENDPAD,
						SC9.C9_CARGA,
						SC9.C9_PEDIDO,
						SC9.C9_ITEM,
						SC9.C9_SEQUEN,
						SC9.C9_PRODUTO,
						SC9.C9_LOTECTL,
						SC9.C9_NUMLOTE,
						SC9.C9_NUMSERI,
						SC9.C9_QTDLIB,
						SC9.C9_IDDCF
				FROM %Table:SC9% SC9
				WHERE SC9.C9_FILIAL = %xFilial:SC9%
				AND SC9.C9_ROMEMB = %Exp:Self:cRomEmb%
				AND SC9.C9_BLWMS = '05'
				AND NOT EXISTS (SELECT 1
								FROM %Table:D0Z% D0Z
								WHERE D0Z.D0Z_FILIAL = %xFilial:D0Z%
								AND D0Z.D0Z_PEDIDO = SC9.C9_PEDIDO
								AND D0Z.D0Z_ITEM = SC9.C9_ITEM
								AND D0Z.D0Z_SEQUEN = SC9.C9_SEQUEN
								AND D0Z.%NotDel% )
				AND NOT EXISTS (SELECT 1
								FROM %Table:DCV% DCV
								WHERE DCV.DCV_FILIAL = %xFilial:DCV%
								AND DCV.DCV_PEDIDO = SC9.C9_PEDIDO
								AND DCV.DCV_ITEM = SC9.C9_ITEM
								AND DCV.DCV_SEQUEN = SC9.C9_SEQUEN
								AND DCV.%NotDel% )
				%Exp:cSelD00%
				AND SC9.%NotDel%
				UNION ALL
				SELECT SC9.C9_LOCAL,
						SC9.C9_ENDPAD,
						SC9.C9_CARGA,
						SC9.C9_PEDIDO,
						SC9.C9_ITEM,
						SC9.C9_SEQUEN,
						SC9.C9_PRODUTO,
						SC9.C9_LOTECTL,
						SC9.C9_NUMLOTE,
						SC9.C9_NUMSERI,
						SC9.C9_QTDLIB,
						SC9.C9_IDDCF
				FROM ( SELECT DCV.DCV_CODVOL
						FROM %Table:SC9% SC9
						INNER JOIN %Table:DCV% DCV
						ON DCV.DCV_FILIAL = %xFilial:DCV%
						AND DCV.DCV_PEDIDO = SC9.C9_PEDIDO
						AND DCV.DCV_ITEM = SC9.C9_ITEM
						AND DCV.DCV_SEQUEN = SC9.C9_SEQUEN
						AND DCV.%NotDel%
						WHERE SC9.C9_FILIAL = %xFilial:SC9%
						AND SC9.C9_ROMEMB = %Exp:Self:cRomEmb%
						AND SC9.C9_BLWMS = '05'
						AND NOT EXISTS (SELECT 1 
										FROM %Table:D0Z% D0Z
										WHERE D0Z.D0Z_FILIAL = %xFilial:D0Z%
										AND D0Z.D0Z_PEDIDO = SC9.C9_PEDIDO
										AND D0Z.D0Z_ITEM = SC9.C9_ITEM
										AND D0Z.D0Z_SEQUEN = SC9.C9_SEQUEN
										AND D0Z.%NotDel% )
						%Exp:cSelD00%
						AND SC9.%NotDel%
						GROUP BY DCV.DCV_CODVOL) VOL
				INNER JOIN %Table:DCV% DCV
				ON DCV.DCV_FILIAL = %xFilial:DCV%
				AND DCV.DCV_CODVOL = VOL.DCV_CODVOL
				AND DCV.%NotDel%
				INNER JOIN %Table:SC9% SC9
				ON SC9.C9_FILIAL = %xFilial:SC9%
				AND SC9.C9_PEDIDO = DCV.DCV_PEDIDO
				AND SC9.C9_ITEM = DCV.DCV_ITEM
				AND SC9.C9_SEQUEN = DCV.DCV_SEQUEN
				AND SC9.C9_PRODUTO = DCV.DCV_PRDORI
				AND SC9.%NotDel%
				GROUP BY SC9.C9_LOCAL,
							SC9.C9_ENDPAD,
							SC9.C9_CARGA,
							SC9.C9_PEDIDO,
							SC9.C9_ITEM,
							SC9.C9_SEQUEN,
							SC9.C9_PRODUTO,
							SC9.C9_LOTECTL,
							SC9.C9_NUMLOTE,
							SC9.C9_NUMSERI,
							SC9.C9_QTDLIB,
							SC9.C9_IDDCF
			EndSql
		OtherWise // Nota fiscal
			BeginSql Alias cAliasSC9
				SELECT SC9.C9_LOCAL,
						SC9.C9_ENDPAD,
						SC9.C9_CARGA,
						SC9.C9_PEDIDO,
						SC9.C9_ITEM,
						SC9.C9_SEQUEN,
						SC9.C9_PRODUTO,
						SC9.C9_LOTECTL,
						SC9.C9_NUMLOTE,
						SC9.C9_NUMSERI,
						SC9.C9_QTDLIB,
						SC9.C9_IDDCF
				FROM %Table:SC9% SC9
				WHERE SC9.C9_FILIAL = %xFilial:SC9%
				AND SC9.C9_NFISCAL = %Exp:Self:cNFiscal%
				AND SC9.C9_SERIENF = %Exp:Self:cNFSerie%
				AND SC9.C9_BLWMS = '05'
				AND NOT EXISTS (SELECT 1
								FROM %Table:D0Z% D0Z
								WHERE D0Z.D0Z_FILIAL = %xFilial:D0Z%
								AND D0Z.D0Z_PEDIDO = SC9.C9_PEDIDO
								AND D0Z.D0Z_ITEM = SC9.C9_ITEM
								AND D0Z.D0Z_SEQUEN = SC9.C9_SEQUEN
								AND D0Z.%NotDel% )
				AND NOT EXISTS (SELECT 1
								FROM %Table:DCV% DCV
								WHERE DCV.DCV_FILIAL = %xFilial:DCV%
								AND DCV.DCV_PEDIDO = SC9.C9_PEDIDO
								AND DCV.DCV_ITEM = SC9.C9_ITEM
								AND DCV.DCV_SEQUEN = SC9.C9_SEQUEN
								AND DCV.%NotDel% )
				%Exp:cSelD00%
				AND SC9.%NotDel%
				UNION ALL
				SELECT SC9.C9_LOCAL,
						SC9.C9_ENDPAD,
						SC9.C9_CARGA,
						SC9.C9_PEDIDO,
						SC9.C9_ITEM,
						SC9.C9_SEQUEN,
						SC9.C9_PRODUTO,
						SC9.C9_LOTECTL,
						SC9.C9_NUMLOTE,
						SC9.C9_NUMSERI,
						SC9.C9_QTDLIB,
						SC9.C9_IDDCF
				FROM ( SELECT DCV.DCV_CODVOL
						FROM %Table:SC9% SC9
						INNER JOIN %Table:DCV% DCV
						ON DCV.DCV_FILIAL = %xFilial:DCV%
						AND DCV.DCV_PEDIDO = SC9.C9_PEDIDO
						AND DCV.DCV_ITEM = SC9.C9_ITEM
						AND DCV.DCV_SEQUEN = SC9.C9_SEQUEN
						AND DCV.%NotDel%
						WHERE SC9.C9_FILIAL = %xFilial:SC9%
						AND SC9.C9_NFISCAL = %Exp:Self:cNFiscal%
						AND SC9.C9_SERIENF = %Exp:Self:cNFSerie%
						AND SC9.C9_BLWMS = '05'
						AND NOT EXISTS (SELECT 1 
										FROM %Table:D0Z% D0Z
										WHERE D0Z.D0Z_FILIAL = %xFilial:D0Z%
										AND D0Z.D0Z_PEDIDO = SC9.C9_PEDIDO
										AND D0Z.D0Z_ITEM = SC9.C9_ITEM
										AND D0Z.D0Z_SEQUEN = SC9.C9_SEQUEN
										AND D0Z.%NotDel% )
						AND SC9.%NotDel%
						%Exp:cSelD00%
						GROUP BY DCV.DCV_CODVOL) VOL
				INNER JOIN %Table:DCV% DCV
				ON DCV.DCV_FILIAL = %xFilial:DCV%
				AND DCV.DCV_CODVOL = VOL.DCV_CODVOL
				AND DCV.%NotDel%
				INNER JOIN %Table:SC9% SC9
				ON SC9.C9_FILIAL = %xFilial:SC9%
				AND SC9.C9_PEDIDO = DCV.DCV_PEDIDO
				AND SC9.C9_ITEM = DCV.DCV_ITEM
				AND SC9.C9_SEQUEN = DCV.DCV_SEQUEN
				AND SC9.C9_PRODUTO = DCV.DCV_PRDORI
				AND SC9.%NotDel%
				GROUP BY SC9.C9_LOCAL,
							SC9.C9_ENDPAD,
							SC9.C9_CARGA,
							SC9.C9_PEDIDO,
							SC9.C9_ITEM,
							SC9.C9_SEQUEN,
							SC9.C9_PRODUTO,
							SC9.C9_LOTECTL,
							SC9.C9_NUMLOTE,
							SC9.C9_NUMSERI,
							SC9.C9_QTDLIB,
							SC9.C9_IDDCF
			EndSql
	EndCase
	aTamSx3 := TamSx3("C9_QTDLIB");TcSetField(cAliasSC9,'C9_QTDLIB','N',aTamSX3[1],aTamSX3[2])
	If (cAliasSC9)->(!Eof())
		Do While (cAliasSC9)->(!Eof())
			cEmbarque := Self:oEmbExp:GetEmbarq()
			// Gera embarque de expedição por produto
			Self:oProdLote:SetArmazem((cAliasSC9)->C9_LOCAL)
			Self:oProdLote:SetPrdOri((cAliasSC9)->C9_PRODUTO)
			Self:oProdLote:SetProduto((cAliasSC9)->C9_PRODUTO)
			Self:oProdLote:LoadData()
			aProduto := Self:oProdLote:GetArrProd()
			For nI := 1 To Len(aProduto)

				// Atribui embarque expedição
				Self:oEmbExp:SetEmbarq(cEmbarque)
				Self:cArmazem := (cAliasSC9)->C9_LOCAL
				Self:cEnder := (cAliasSC9)->C9_ENDPAD
				// Atribui os itens da embarque de expedição
				Self:oProdLote:SetArmazem((cAliasSC9)->C9_LOCAL)
				Self:oProdLote:SetPrdOri((cAliasSC9)->C9_PRODUTO)
				Self:oProdLote:SetProduto(aProduto[nI,1])
				Self:oProdLote:SetLoteCtl((cAliasSC9)->C9_LOTECTL)
				Self:oProdLote:SetNumLote((cAliasSC9)->C9_NUMLOTE)
				Self:oProdLote:SetNumSer((cAliasSC9)->C9_NUMSERI)
				Self:oProdLote:LoadData()
				// Dados complementares
				Self:cCarga   := (cAliasSC9)->C9_CARGA
				Self:cPedido  := (cAliasSC9)->C9_PEDIDO
				Self:cItem    := (cAliasSC9)->C9_ITEM
				Self:cSequen  := (cAliasSC9)->C9_SEQUEN
				Self:cStatus  := "1"
				Self:cIdDCF   := (cAliasSC9)->C9_IDDCF
				Self:nQtdOri  := (cAliasSC9)->C9_QTDLIB * aProduto[nI,2]
				Self:nQtdEmb  := 0
				Self:AssignD0Z()
				cEmbarque := Iif(Empty(cEmbarque),Self:oEmbExp:GetEmbarq(),cEmbarque)
				If lWMSAltDca .AND. lD00Local
					Self:WmsEndD00(nOpcao)
				EndIf
			Next nI
			(cAliasSC9)->(dbSkip())
		EndDo
	Else
		// Busca itens para incluir no embarque
		cAliasQry := GetNextAlias()
		Do Case
			Case nOpcao == 1 // Carga
				BeginSql Alias cAliasQry
					SELECT SC9.C9_CARGA,
							SC9.C9_PEDIDO,
							SC9.C9_ITEM,
							SC9.C9_SEQUEN,
							SC9.C9_LOCAL,
							SC9.C9_ENDPAD
					FROM %Table:SC9% SC9
					WHERE SC9.C9_FILIAL = %xFilial:SC9%
					AND SC9.C9_CARGA = %Exp:Self:cCarga%
					AND SC9.C9_BLWMS = '05'
					AND SC9.%notDel%
					%Exp:cSelD00%
				EndSql
			Case nOpcao == 2 // Pedido
				BeginSql Alias cAliasQry
					SELECT SC9.C9_CARGA,
							SC9.C9_PEDIDO,
							SC9.C9_ITEM,
							SC9.C9_SEQUEN,
							SC9.C9_LOCAL,
							SC9.C9_ENDPAD
					FROM %Table:SC9% SC9
					WHERE SC9.C9_FILIAL = %xFilial:SC9%
					AND SC9.C9_PEDIDO = %Exp:Self:cPedido%
					AND SC9.C9_BLWMS = '05'
					AND SC9.%notDel%
					%Exp:cSelD00%
				EndSql
			Case nOpcao == 3 // Romaneio de embarque
				BeginSql Alias cAliasQry
					SELECT SC9.C9_CARGA,
							SC9.C9_PEDIDO,
							SC9.C9_ITEM,
							SC9.C9_SEQUEN,
							SC9.C9_LOCAL,
							SC9.C9_ENDPAD
					FROM %Table:SC9% SC9
					WHERE SC9.C9_FILIAL = %xFilial:SC9%
					AND SC9.C9_NFISCAL = %Exp:Self:cNFiscal%
					AND SC9.C9_SERIENF = %Exp:Self:cNFSerie%
					AND SC9.C9_BLWMS = '05'
					AND %Exp:cSelRom%
					AND SC9.%notDel%
					%Exp:cSelD00%
				EndSql
			Case nOpcao == 4 // Nota fiscal
				BeginSql Alias cAliasQry
					SELECT SC9.C9_CARGA,
							SC9.C9_PEDIDO,
							SC9.C9_ITEM,
							SC9.C9_SEQUEN,
							SC9.C9_LOCAL,
							SC9.C9_ENDPAD
					FROM %Table:SC9% SC9
					WHERE SC9.C9_FILIAL = %xFilial:SC9%
					AND SC9.C9_NFISCAL = %Exp:Self:cNFiscal%
					AND SC9.C9_SERIENF = %Exp:Self:cNFSerie%
					AND SC9.C9_BLWMS = '05'
					AND SC9.%notDel%
					%Exp:cSelD00%
				EndSql
		EndCase
		If (cAliasQry)->(!Eof())
			cAliasD0Z := GetNextAlias()
			BeginSql Alias cAliasD0Z
				SELECT D0Z.D0Z_EMBARQ
				FROM %Table:D0Z% D0Z
				WHERE D0Z.D0Z_FILIAL = %xFilial:D0Z%
				AND D0Z.D0Z_PEDIDO = %Exp:(cAliasQry)->C9_PEDIDO%
				AND D0Z.D0Z_ITEM = %Exp:(cAliasQry)->C9_ITEM% 
				AND D0Z.D0Z_SEQUEN = %Exp:(cAliasQry)->C9_SEQUEN%
				AND D0Z.%NotDel%
			EndSql
			If (cAliasD0Z)->(!Eof())
				If nOpcao == 1
					Self:cErro := WmsFmtMsg(STR0004,{{"[VAR01]",AllTrim(Self:cCarga)},{"[VAR02]",AllTrim((cAliasD0Z)->D0Z_EMBARQ)}}) // Carga [VAR01] já cadastrada no embarque de expedição [VAR02].
				ElseIf nOpcao == 2
					Self:cErro := WmsFmtMsg(STR0005,{{"[VAR01]",AllTrim(Self:cPedido)},{"[VAR02]",AllTrim((cAliasD0Z)->D0Z_EMBARQ)}}) // Pedido [VAR01] já cadastrado no embarque de expedição [VAR02].
				ElseIf nOpcao == 3
					Self:cErro := WmsFmtMsg(STR0006,{{"[VAR01]",AllTrim(Self:cRomEmb)},{"[VAR02]",AllTrim((cAliasD0Z)->D0Z_EMBARQ)}}) // Romaneio de embarque [VAR01] já cadastrado no embarque de expedição [VAR02].
				Else
					Self:cErro := WmsFmtMsg(STR0007,{{"[VAR01]",AllTrim(Self:cNFiscal)},{"[VAR02]",AllTrim(Self:cNFSerie)},{"[VAR03]",AllTrim((cAliasD0Z)->D0Z_EMBARQ)}}) // Nota-Fiscal [VAR01] série [VAR02] já cadastrada no embarque de expedição [VAR03].
				EndIf
			Else
				If nOpcao == 1
					Self:cErro := WmsFmtMsg(STR0008,{{"[VAR01]",AllTrim(Self:cCarga)},{"[VAR02]",AllTrim((cAliasQry)->C9_LOCAL)},{"[VAR03]",AllTrim((cAliasQry)->C9_ENDPAD)}}) // Carga [VAR01] não encontra-se no armazém [VAR02] e endereço [VAR03].
				ElseIf nOpcao == 2
					Self:cErro := WmsFmtMsg(STR0009,{{"[VAR01]",AllTrim(Self:cPedido)},{"[VAR02]",AllTrim((cAliasQry)->C9_LOCAL)},{"[VAR03]",AllTrim((cAliasQry)->C9_ENDPAD)}}) // Pedido [VAR01] não encontra-se no armazém [VAR02] e endereço [VAR03].
				ElseIf nOpcao == 3
					Self:cErro := WmsFmtMsg(STR0010,{{"[VAR01]",AllTrim(Self:cRomEmb)},{"[VAR02]",AllTrim((cAliasQry)->C9_LOCAL)},{"[VAR03]",AllTrim((cAliasQry)->C9_ENDPAD)}}) // Romaneio de embarque [VAR01] não encontra-se no armazém [VAR02] e endereço [VAR03].
				Else
					Self:cErro := WmsFmtMsg(STR0011,{{"[VAR01]",AllTrim(Self:cNFiscal)},{"[VAR02]",AllTrim(Self:cNFSerie)},{"[VAR03]",AllTrim((cAliasQry)->C9_LOCAL)},{"[VAR04]",AllTrim((cAliasQry)->C9_ENDPAD)}}) // Nota-Fiscal [VAR01] série [VAR02] não encontra-se no armazém [VAR03] e endereço [VAR04].
				EndIf
			EndIf
			(cAliasD0Z)->(dbCloseArea())
		Else
			If lD00Local .AND. lWMSAltDca
				cAliasD00 := GetNextAlias()
				Do Case
					Case nOpcao == 1 // Carga
						BeginSql Alias cAliasD00
							SELECT D00.D00_CODEND
								FROM %Table:D00% D00
								WHERE D00.D00_FILIAL = %xFilial:D00%
								AND D00.D00_CARGA = %Exp:Self:cCarga%
								AND D00.D00_CODDOC = ' ' 
								AND D00.D00_LOCDOC = ' '
								AND D00.%NotDel%
						EndSql
					Case nOpcao == 2 // Pedido
						BeginSql Alias cAliasD00
							SELECT D00.D00_CODEND
								FROM %Table:D00% D00
								WHERE D00.D00_FILIAL = %xFilial:D00%
								AND D00.D00_PEDIDO = %Exp:Self:cPedido%
								AND D00.D00_CODDOC = ' ' 
								AND D00.D00_LOCDOC = ' '
								AND D00.%NotDel%
						EndSql
					Case nOpcao == 3 // Romaneio embarque
						BeginSql Alias cAliasD00
							SELECT SC9.C9_CARGA,
									SC9.C9_PEDIDO,
									SC9.C9_ITEM,
									SC9.C9_SEQUEN,
									SC9.C9_LOCAL,
									SC9.C9_ENDPAD
							FROM %Table:SC9% SC9
							WHERE SC9.C9_FILIAL = %xFilial:SC9%
							AND SC9.C9_ROMEMB = %Exp:Self:cRomEmb%
							AND SC9.C9_BLWMS = '05'
							AND SC9.%notDel%
							AND EXISTS ( SELECT 1
										FROM %Table:DCV% DCV
										INNER JOIN %Table:D00% D00 
										ON D00.D00_FILIAL = %xFilial:D00%
										AND D00.D00_PEDIDO = SC9.C9_PEDIDO
										AND D00.D00_CODVOL = DCV.DCV_CODVOL
										AND D00.%NotDel%
										AND D00.D00_CODDOC = ' '
										AND D00.D00_LOCDOC = ' '
										WHERE DCV.DCV_FILIAL = %xFilial:DCV%
										AND DCV.DCV_PEDIDO = SC9.C9_PEDIDO
										AND DCV.DCV_ITEM = SC9.C9_ITEM
										AND DCV.DCV_SEQUEN = SC9.C9_SEQUEN
										AND DCV.%NotDel% )
						EndSql
					Case nOpcao == 4 // NF
						BeginSql Alias cAliasD00
							SELECT SC9.C9_CARGA,
									SC9.C9_PEDIDO,
									SC9.C9_ITEM,
									SC9.C9_SEQUEN,
									SC9.C9_LOCAL,
									SC9.C9_ENDPAD
							FROM %Table:SC9% SC9
							WHERE SC9.C9_FILIAL = %xFilial:SC9%
							AND SC9.C9_NFISCAL = %Exp:Self:cNFiscal%
							AND SC9.C9_SERIENF = %Exp:Self:cNFSerie%
							AND SC9.C9_BLWMS = '05'
							AND SC9.%notDel%
							AND EXISTS (SELECT 1
											FROM %Table:SC9% SC9
											INNER JOIN %Table:SD2% SD2
											ON (SD2.D2_FILIAL = %xFilial:SD2%
											AND SD2.D2_PEDIDO = SC9.C9_PEDIDO
											AND SD2.D2_ITEMPV = SC9.C9_ITEM
											AND SD2.D2_DOC    = SC9.C9_NFISCAL
											AND SD2.D2_SERIE  = SC9.C9_SERIENF
											AND SD2.%NotDel%)
											INNER JOIN %Table:D00% D00  
											ON (D00.D00_FILIAL = %xFilial:D00%
											AND D00.D00_PEDIDO = SC9.C9_PEDIDO
											AND D00.%NotDel%)
											WHERE SC9.C9_FILIAL = %xFilial:SC9%
											AND SC9.C9_NFISCAL = %Exp:Self:cNFiscal%
											AND SC9.C9_SERIENF = %Exp:Self:cNFSerie%
											AND D00.D00_CODDOC = ' ' 
											AND D00.D00_LOCDOC = ' '
											AND SC9.%NotDel%)
						EndSql
				EndCase
				If (cAliasD00)->(!Eof())
					If nOpcao == 1
						Self:cErro := WmsFmtMsg(STR0024,{{"[VAR01]",AllTrim(Self:cCarga)}})//Transf. box/doca pendente para a carga [VAR01].
					ElseIf nOpcao == 2
						Self:cErro := WmsFmtMsg(STR0025,{{"[VAR01]",AllTrim(Self:cPedido)}})//Transf. box/doca pendente para o pedido [VAR01].
					ElseIf nOpcao == 3
						Self:cErro := WmsFmtMsg(STR0026,{{"[VAR01]",AllTrim(Self:cRomEmb)},{"[VAR02]",AllTrim((cAliasD00)->C9_PEDIDO)}})//Transf. box/doca pendente para o romaneio [VAR01] e pedido [VAR02].
					ElseIf nOpcao == 4
						Self:cErro := WmsFmtMsg(STR0027,{{"[VAR01]",AllTrim(Self:cNFiscal)},{"[VAR02]",AllTrim(Self:cNFSerie)}})//Transf. box/doca pendente para a nf [VAR01] e serie [VAR02].
					EndIf 
					(cAliasD00)->(dbCloseArea())
				EndIf
			Else
				If nOpcao == 1
					Self:cErro := WmsFmtMsg(STR0012,{{"[VAR01]",AllTrim(Self:cCarga)}}) // Carga [VAR01] não possui pedidos com produtos liberados para faturamento.
				ElseIf nOpcao == 2
					Self:cErro := WmsFmtMsg(STR0013,{{"[VAR01]",AllTrim(Self:cPedido)}}) // Pedido [VAR01] não possui produtos liberados para faturamento.
				ElseIf nOpcao == 3
					Self:cErro := WmsFmtMsg(STR0014,{{"[VAR01]",AllTrim(Self:cRomEmb)}}) // Romaneio de embarque [VAR01] não possui volumes liberados para faturamento.
				Else
					Self:cErro := WmsFmtMsg(STR0015,{{"[VAR01]",AllTrim(Self:cNFiscal)},{"[VAR02]",AllTrim(Self:cNFSerie)}}) // Nota-Fiscal [VAR01] série [VAR02] não gerada.
				EndIf
			EndIf
		EndIf
		(cAliasQry)->(dbCloseArea())
		lRet := .F.
	EndIf
	(cAliasSC9)->(dbCloseArea())
	RestArea(aAreaAnt)
Return lRet
//----------------------------------------------------------
/*/{Protheus.doc} FindDocEmb
Busca documentos do embarque de expedição
@author Squad WMS/OMS Protheus
@version P12
@since 04/01/2019
/*/
//----------------------------------------------------------
METHOD FindDocEmb(lValVolume) CLASS WMSDTCEmbarqueExpedicaoItens
Local lRet      := .T.
Local aAreaAnt  := GetArea()
Local cWhereDCV    := ""
Local cWhereD0Z := ""
Local cAliasD0Z := Nil
Local cAliasQry := Nil
Local cVolume   := ""
Local cPedido   := ""
Local cItem     := ""
Local cSequen   := ""
Local cSelect   := ""
Local nI        := 0
Default lValVolume := .T.

	cSelect := "%"
	If Self:lD0ZLocal
		cSelect += " ,D0Z.D0Z_LOCAL"
		cSelect += " ,D0Z.D0Z_ENDER"
	EndIf
	cSelect += "%"

	// Inicializa array de documentos do embarque
	Self:aDocEmb := {}
	// Parâmetro Where
	cWhereDCV := "%"
	If !Empty(Self:oProdLote:GetProduto())
		cWhereDCV += " AND D0Z.D0Z_PRODUT = '"+Self:oProdLote:GetProduto()+"'"
	EndIf
	If !Empty(Self:oProdLote:GetLoteCtl())
		cWhereDCV += " AND D0Z.D0Z_LOTECT = '"+Self:oProdLote:GetLoteCtl()+"'"
	EndIf
	If !Empty(Self:oProdLote:GetNumLote())
		cWhereDCV += " AND D0Z.D0Z_NUMLOT = '"+Self:oProdLote:GetNumLote()+"'"
	EndIf
	If !Empty(Self:oProdLote:GetNumSer())
		cWhereDCV += " AND D0Z.D0Z_NUMSER = '"+Self:oProdLote:GetNumSer()+"'"
	EndIf
	If Self:lD0ZLocal
		If !Empty(Self:cArmazem)
			cWhereDCV += " AND (D0Z.D0Z_LOCAL = '"+Self:cArmazem+"' OR D0Z.D0Z_LOCAL = ' ')"
		EndIf
		If !Empty(Self:cEnder)
			cWhereDCV += " AND (D0Z.D0Z_ENDER = '"+Self:cEnder+"' OR D0Z.D0Z_ENDER = ' ')"
		EndIf
	EndIf
	cWhereDCV += "%"

	cWhereD0Z := "%"
	If !Empty(Self:oProdLote:GetProduto())
		cWhereD0Z += " AND D0Z.D0Z_PRODUT = '"+Self:oProdLote:GetProduto()+"'"
	EndIf
	If !Empty(Self:oProdLote:GetLoteCtl())
		cWhereD0Z += " AND D0Z.D0Z_LOTECT = '"+Self:oProdLote:GetLoteCtl()+"'"
	EndIf
	If !Empty(Self:oProdLote:GetNumLote())
		cWhereD0Z += " AND D0Z.D0Z_NUMLOT = '"+Self:oProdLote:GetNumLote()+"'"
	EndIf
	If !Empty(Self:oProdLote:GetNumSer())
		cWhereD0Z += " AND D0Z.D0Z_NUMSER = '"+Self:oProdLote:GetNumSer()+"'"
	EndIf
	If Self:lD0ZLocal
		If !Empty(Self:cArmazem)
			cWhereD0Z += " AND (D0Z.D0Z_LOCAL = '"+Self:cArmazem+"' OR D0Z.D0Z_LOCAL = ' ')"
		EndIf
		If !Empty(Self:cEnder)
			cWhereD0Z += " AND (D0Z.D0Z_ENDER = '"+Self:cEnder+"' OR D0Z.D0Z_ENDER = ' ')"
		EndIf
	EndIf
	If lValVolume
		cWhereD0Z += " AND NOT EXISTS( SELECT 1"
		cWhereD0Z +=                   " FROM "+RetSqlName('DCV')+" DCV"
		cWhereD0Z +=                  " WHERE DCV.DCV_FILIAL = '"+xFilial('DCV')+"'"
		cWhereD0Z +=                    " AND DCV.DCV_CARGA = D0Z.D0Z_CARGA"
		cWhereD0Z +=                    " AND DCV.DCV_PEDIDO = D0Z.D0Z_PEDIDO"
		cWhereD0Z +=                    " AND DCV.DCV_ITEM = D0Z.D0Z_ITEM"
		cWhereD0Z +=                    " AND DCV.DCV_SEQUEN = D0Z.D0Z_SEQUEN"
		cWhereD0Z +=                    " AND DCV.D_E_L_E_T_ = ' ' )"
	EndIf
	cWhereD0Z += "%"

	// Verificar é volume ou produto
	If Empty(Self:aVolume)
		cAliasD0Z := GetNextAlias()
		If !Self:lEstorno
			BeginSql Alias cAliasD0Z
				SELECT D0Z.D0Z_CARGA,
						D0Z.D0Z_PEDIDO,
						D0Z.D0Z_ITEM,
						D0Z.D0Z_SEQUEN,
						SC9.C9_NFISCAL,
						SC9.C9_SERIENF,
						D0Z.D0Z_PRODUT,
						D0Z.D0Z_PRDORI,
						D0Z.D0Z_QTDORI,
						D0Z.D0Z_QTDEMB
						%Exp:cSelect%
				FROM %Table:D0Z% D0Z
				INNER JOIN %Table:SC9% SC9
				ON SC9.C9_FILIAL = %xFilial:SC9%
				AND SC9.C9_CARGA = D0Z.D0Z_CARGA
				AND SC9.C9_PEDIDO = D0Z.D0Z_PEDIDO
				AND SC9.C9_ITEM = D0Z.D0Z_ITEM
				AND SC9.C9_SEQUEN = D0Z.D0Z_SEQUEN
				AND SC9.%NotDel%
				WHERE D0Z.D0Z_FILIAL = %xFilial:D0Z%
				AND D0Z.D0Z_EMBARQ = %Exp:Self:oEmbExp:GetEmbarq()%
				AND D0Z.D0Z_QTDORI <> D0Z.D0Z_QTDEMB 
				AND (D0Z.D0Z_QTDEMB + %Exp:Self:nQuant% ) <= D0Z.D0Z_QTDORI
				%Exp:cWhereD0Z%
				AND D0Z.%NotDel%
			EndSql
		Else
			BeginSql Alias cAliasD0Z
				SELECT D0Z.D0Z_CARGA,
						D0Z.D0Z_PEDIDO,
						D0Z.D0Z_ITEM,
						D0Z.D0Z_SEQUEN,
						SC9.C9_NFISCAL,
						SC9.C9_SERIENF,
						D0Z.D0Z_PRODUT,
						D0Z.D0Z_PRDORI,
						D0Z.D0Z_QTDORI,
						D0Z.D0Z_QTDEMB
						%Exp:cSelect%
				FROM %Table:D0Z% D0Z
				INNER JOIN %Table:SC9% SC9
				ON SC9.C9_FILIAL = %xFilial:SC9%
				AND SC9.C9_CARGA = D0Z.D0Z_CARGA
				AND SC9.C9_PEDIDO = D0Z.D0Z_PEDIDO
				AND SC9.C9_ITEM = D0Z.D0Z_ITEM
				AND SC9.C9_SEQUEN = D0Z.D0Z_SEQUEN
				AND SC9.%NotDel%
				WHERE D0Z.D0Z_FILIAL = %xFilial:D0Z%
				AND D0Z.D0Z_EMBARQ = %Exp:Self:oEmbExp:GetEmbarq()%
				AND D0Z.D0Z_QTDEMB > 0
				AND (D0Z.D0Z_QTDEMB - %Exp:Self:nQuant% ) >= 0
				%Exp:cWhereD0Z%
				AND D0Z.%NotDel%
			EndSql
		EndIf
		aTamSx3 := TamSx3('D0Z_QTDORI')
		TcSetField(cAliasD0Z,'D0Z_QTDORI','N',aTamSx3[1],aTamSx3[2])
		TcSetField(cAliasD0Z,'D0Z_QTDEMB','N',aTamSx3[1],aTamSx3[2])
		If (cAliasD0Z)->(!Eof())
			Do While (cAliasD0Z)->(!Eof())
				If Self:lD0ZLocal
					aAdd(Self:aDocEmb,{(cAliasD0Z)->D0Z_CARGA,(cAliasD0Z)->D0Z_PEDIDO,(cAliasD0Z)->D0Z_ITEM,(cAliasD0Z)->D0Z_SEQUEN,(cAliasD0Z)->C9_NFISCAL,(cAliasD0Z)->C9_SERIENF,(cAliasD0Z)->D0Z_PRODUT,(cAliasD0Z)->D0Z_PRDORI,(cAliasD0Z)->D0Z_LOCAL,(cAliasD0Z)->D0Z_ENDER})
				Else
					aAdd(Self:aDocEmb,{(cAliasD0Z)->D0Z_CARGA,(cAliasD0Z)->D0Z_PEDIDO,(cAliasD0Z)->D0Z_ITEM,(cAliasD0Z)->D0Z_SEQUEN,(cAliasD0Z)->C9_NFISCAL,(cAliasD0Z)->C9_SERIENF,(cAliasD0Z)->D0Z_PRODUT,(cAliasD0Z)->D0Z_PRDORI})

				EndIf
				(cAliasD0Z)->(dbSkip())
			EndDo
			// Verifica se encontrou os documentos
			If Empty(Self:aDocEmb)
				If !Self:lEstorno
					Self:cErro := STR0016 // Quantidade informada superior a quantidade pendente a ser embarcada.
				Else
					Self:cErro := STR0021 // Quantidade informada superior a quantidade embarcada.
				EndIf
				lRet := .F.
			EndIf
		Else
			If lValVolume
				lRet := .F.
				cAliasQry := GetNextAlias()
				If !Self:lEstorno
					BeginSql Alias cAliasQry
						SELECT D0Z.D0Z_EMBARQ
						%Exp:cSelect%
						FROM %Table:D0Z% D0Z
						INNER JOIN %Table:DCV% DCV
						ON DCV.DCV_FILIAL = %xFilial:DCV%
						AND DCV.DCV_CARGA = D0Z.D0Z_CARGA
						AND DCV.DCV_PEDIDO = D0Z.D0Z_PEDIDO
						AND DCV.DCV_ITEM = D0Z.D0Z_ITEM
						AND DCV.DCV_SEQUEN = D0Z.D0Z_SEQUEN
						AND DCV.%NotDel%
						WHERE D0Z.D0Z_FILIAL = %xFilial:D0Z%
						AND D0Z.D0Z_EMBARQ = %Exp:Self:oEmbExp:GetEmbarq()%
						AND D0Z.D0Z_QTDORI <> D0Z.D0Z_QTDEMB
						AND (D0Z.D0Z_QTDEMB + %Exp:Self:nQuant% ) <= D0Z.D0Z_QTDORI
						%Exp:cWhereDCV%
						AND D0Z.%NotDel%
					EndSql
				Else
					BeginSql Alias cAliasQry
						SELECT D0Z.D0Z_EMBARQ
						%Exp:cSelect%
						FROM %Table:D0Z% D0Z
						INNER JOIN %Table:DCV% DCV
						ON DCV.DCV_FILIAL = %xFilial:DCV%
						AND DCV.DCV_CARGA = D0Z.D0Z_CARGA
						AND DCV.DCV_PEDIDO = D0Z.D0Z_PEDIDO
						AND DCV.DCV_ITEM = D0Z.D0Z_ITEM
						AND DCV.DCV_SEQUEN = D0Z.D0Z_SEQUEN
						AND DCV.%NotDel%
						WHERE D0Z.D0Z_FILIAL = %xFilial:D0Z%
						AND D0Z.D0Z_EMBARQ = %Exp:Self:oEmbExp:GetEmbarq()%
						AND D0Z.D0Z_QTDEMB > 0
						AND (D0Z.D0Z_QTDEMB - %Exp:Self:nQuant% ) >= 0
						%Exp:cWhereDCV%
						AND D0Z.%NotDel%
					EndSql
				EndIf
				If (cAliasQry)->(!Eof())
					Self:cErro := STR0017 // Produto pertence a um volume, informe o volume!
				Else
					Self:cErro := WmsFmtMsg(STR0022,{{"[VAR01]",AllTrim((cAliasQry)->D0Z_EMBARQ)}}) // Informações não localizadas no embarque de expedição [VAR01] 
				EndIf
				(cAliasQry)->(dbCloseArea())
			EndIf
		EndIf
		(cAliasD0Z)->(dbCloseArea())
	Else
		cVolume  := Self:aVolume[1][11]
		cAliasD16 := GetNextAlias()
		BeginSql Alias cAliasD16
			SELECT D16.D16_EMBARQ
			FROM %Table:D16% D16
			WHERE D16.D16_FILIAL = %xFilial:D16%
			AND D16.D16_CODVOL = %Exp:cVolume%
			AND D16.%NotDel%
		EndSql
		If (cAliasD16)->(!Eof()) .And. !Self:lEstorno
			Self:cErro := WmsFmtMsg(STR0019,{{"[VAR01]",AllTrim((cAliasD16)->D16_EMBARQ)}}) // Volume já embarcado no embarque de expedição [VAR01]
			lRet := .F.
		Else
			For nI := 1 To Len(Self:aVolume)
				cPedido  := Self:aVolume[nI][5]
				cItem    := Self:aVolume[nI][8]
				cSequen  := Self:aVolume[nI][9]
				cAliasD0Z := GetNextAlias()
				If !Self:lEstorno
					BeginSql Alias cAliasD0Z
						SELECT D0Z.D0Z_CARGA,
								D0Z.D0Z_PEDIDO,
								D0Z.D0Z_ITEM,
								D0Z.D0Z_SEQUEN,
								SC9.C9_NFISCAL,
								SC9.C9_SERIENF,
								D0Z.D0Z_PRODUT,
								D0Z.D0Z_PRDORI
								%Exp:cSelect%
						FROM %Table:D0Z% D0Z
						INNER JOIN %Table:SC9% SC9
						ON SC9.C9_FILIAL = %xFilial:SC9%
						AND SC9.C9_CARGA = D0Z.D0Z_CARGA
						AND SC9.C9_PEDIDO = D0Z.D0Z_PEDIDO
						AND SC9.C9_ITEM = D0Z.D0Z_ITEM
						AND SC9.C9_SEQUEN = D0Z.D0Z_SEQUEN
						AND SC9.%NotDel%
						WHERE D0Z.D0Z_FILIAL = %xFilial:D0Z%
						AND D0Z.D0Z_EMBARQ = %Exp:Self:oEmbExp:GetEmbarq()%
						AND D0Z.D0Z_PEDIDO = %Exp:cPedido%
						AND D0Z.D0Z_ITEM = %Exp:cItem%
						AND D0Z.D0Z_SEQUEN = %Exp:cSequen%
						AND D0Z.D0Z_QTDORI <> D0Z.D0Z_QTDEMB
						AND (D0Z.D0Z_QTDEMB + %Exp:Self:nQuant% ) <= D0Z.D0Z_QTDORI
						AND D0Z.%NotDel%
					EndSql
				Else
					BeginSql Alias cAliasD0Z
						SELECT D0Z.D0Z_CARGA,
								D0Z.D0Z_PEDIDO,
								D0Z.D0Z_ITEM,
								D0Z.D0Z_SEQUEN,
								SC9.C9_NFISCAL,
								SC9.C9_SERIENF,
								D0Z.D0Z_PRODUT,
								D0Z.D0Z_PRDORI
								%Exp:cSelect%
						FROM %Table:D0Z% D0Z
						INNER JOIN %Table:SC9% SC9
						ON SC9.C9_FILIAL = %xFilial:SC9%
						AND SC9.C9_CARGA = D0Z.D0Z_CARGA
						AND SC9.C9_PEDIDO = D0Z.D0Z_PEDIDO
						AND SC9.C9_ITEM = D0Z.D0Z_ITEM
						AND SC9.C9_SEQUEN = D0Z.D0Z_SEQUEN
						AND SC9.%NotDel%
						WHERE D0Z.D0Z_FILIAL = %xFilial:D0Z%
						AND D0Z.D0Z_EMBARQ = %Exp:Self:oEmbExp:GetEmbarq()%
						AND D0Z.D0Z_PEDIDO = %Exp:cPedido%
						AND D0Z.D0Z_ITEM = %Exp:cItem%
						AND D0Z.D0Z_SEQUEN = %Exp:cSequen%
						AND D0Z.D0Z_QTDEMB > 0
						AND (D0Z.D0Z_QTDEMB - %Exp:Self:nQuant% ) >= 0
						AND D0Z.%NotDel%
					EndSql
				EndIf
				If (cAliasD0Z)->(!Eof())
					Do While (cAliasD0Z)->(!Eof())
						If Self:lD0ZLocal
							aAdd(Self:aDocEmb,{(cAliasD0Z)->D0Z_CARGA,(cAliasD0Z)->D0Z_PEDIDO,(cAliasD0Z)->D0Z_ITEM,(cAliasD0Z)->D0Z_SEQUEN,(cAliasD0Z)->C9_NFISCAL,(cAliasD0Z)->C9_SERIENF,(cAliasD0Z)->D0Z_PRODUT,(cAliasD0Z)->D0Z_PRDORI,(cAliasD0Z)->D0Z_LOCAL,(cAliasD0Z)->D0Z_ENDER})
						Else
							aAdd(Self:aDocEmb,{(cAliasD0Z)->D0Z_CARGA,(cAliasD0Z)->D0Z_PEDIDO,(cAliasD0Z)->D0Z_ITEM,(cAliasD0Z)->D0Z_SEQUEN,(cAliasD0Z)->C9_NFISCAL,(cAliasD0Z)->C9_SERIENF,(cAliasD0Z)->D0Z_PRODUT,(cAliasD0Z)->D0Z_PRDORI})
						EndIf
						(cAliasD0Z)->(dbSkip())
					EndDo
				Else
					Self:cErro := WmsFmtMsg(STR0020,{{"[VAR01]",AllTrim(cVolume)},{"[VAR02]",AllTrim(Self:oEmbExp:GetEmbarq())}}) // Volume [VAR01] não cadastrado para o embarque de expedição [VAR02]
					lRet := .F.
				EndIf
				(cAliasD0Z)->(dbCloseArea())
			Next nI
		EndIf
		(cAliasD16)->(dbCloseArea())
	EndIf
	RestArea(aAreaAnt)
Return lRet
/*/{Protheus.doc} CanEstEmb
Verifica se embarque do item pode ser estornado
@author amanda.vieira
@since 15/06/2020
@return lRet, lógico, se retorno igual à true indica que item pode ser estornado
/*/
METHOD CanEstEmb() CLASS WMSDTCEmbarqueExpedicaoItens
Local lRet := .T.
	If Self:nQtdEmb <= 0
		Self:cErro := STR0023 //Item sem quantidade para estorno.
		lRet := .F.
	EndIf
Return lRet
/*/{Protheus.doc} EstEmbItem
Estorna embarque do item carregado no objeto
@author amanda.vieira
@since 15/06/2020
@param nQuantEst, numérico, quantidade que deve ser estornada do item
@return lRet, lógico, se retorno igual à true indica que item foi estornado
/*/
METHOD EstEmbItem(nQuantEst) CLASS WMSDTCEmbarqueExpedicaoItens
Local lRet := .T.
Default nQuantEst := Self:nQtdEmb
	Self:lEstorno := .T.
	If lRet := Self:CanEstEmb()
		//Estorna D16 (Conferência por operador)
		lRet := Self:EstEmbOp(nQuantEst)
		//Estorna D0Z (Item do Embarque)
		If lRet
			Self:nQtdEmb -= nQuantEst
			lRet := Self:UpdateD0Z(nQuantEst)
		EndIf
		//Atualiza D0X (Status do Embarque)
		If lRet
			lRet := Self:oEmbExp:UpdateD0X()
		EndIf
	EndIf
Return lRet
/*/{Protheus.doc} EstEmbOp
Estorna embarque por operador, conforme quantidade definida para estorno
@author amanda.vieira
@since 15/06/2020
@param nQuantEst, numérico, quantidade que deve ser estornada do item
@return lRet, lógico, se retorno igual à true indica que item foi estornado da tabela D16
/*/
METHOD EstEmbOp(nQtdEst) CLASS WMSDTCEmbarqueExpedicaoItens
Local aProduto  := {}
Local cAliasD16 := GetNextAlias()
Local oEmbExpOp := WMSDTCEmbarqueExpedicaoEmbarqueOperador():New()
Local lRet      := .T.
Local nQtdEmb   := 0
Local nQtdEstCon:= 0
Local nI        := 1

	aProduto := Self:oProdLote:GetArrProd()
	If Empty(aProduto)
		aAdd(aProduto,{Self:oProdLote:GetProduto(),1,Self:oProdLote:GetPrdOri()})
	EndIf

	For nI := 1 To Len(aProduto)
		nQtdEstCon := nQtdEst * aProduto[nI][2]
		BeginSql Alias cAliasD16
			SELECT R_E_C_N_O_ RECNOD16
			  FROM %Table:D16% D16
			 WHERE D16.D16_FILIAL = %xFilial:D16%
			   AND D16.D16_EMBARQ = %Exp:Self:GetEmbarq()%
			   AND D16.D16_CARGA = %Exp:Self:cCarga%
			   AND D16.D16_PEDIDO = %Exp:Self:cPedido %
			   AND D16.D16_ITEM = %Exp:Self:cItem%
			   AND D16.D16_SEQUEN = %Exp:Self:cSequen%
			   AND D16.D16_PRDORI = %Exp:Self:oProdLote:GetPrdOri()%
			   AND D16.D16_PRODUT = %Exp:aProduto[nI][1]%
			   AND D16.%NotDel%
		EndSql
		While (cAliasD16)->(!EoF()) .And. nQtdEstCon > 0
			oEmbExpOp:GoToD16((cAliasD16)->RECNOD16)
			nQtdEmb := oEmbExpOp:GetQtdEmb()
			If (nQtdEmb >= nQtdEstCon)
				oEmbExpOp:SetQtdEmb(nQtdEmb - nQtdEstCon)
			Else
				oEmbExpOp:SetQtdEmb(0)
			EndIf
			oEmbExpOp:UpdateD16()
			nQtdEstCon -= nQtdEmb
			(cAliasD16)->(DbSkip())
		EndDo
		(cAliasD16)->(DbCloseArea())
	Next nI
	FreeObj(oEmbExpOp)

Return lRet

METHOD WmsEndD00(nOpcao) CLASS WMSDTCEmbarqueExpedicaoItens
	Local aArea := GetArea()
	Local cWhereD00 := ""
	Local cWhereD0Z := ""
	Local cQuery 	:= ""
	Local cJoin  := ""
	Local cAliasQry := GetNextAlias()
	Local cAliasD0Z := GetNextAlias()
	Local lD00Local := D00->( ColumnPos( "D00_LOCDOC" ) ) > 0
	Local cSelD00   := IIF(lD00Local,"D00.D00_CODDOC,D00.D00_LOCDOC,D00.R_E_C_N_O_ RECNOD00","D00.D00_CODDOC,D00.R_E_C_N_O_ RECNOD00")
	Local cEmbarque := Self:oEmbExp:GetEmbarq()
	Local cCarga    := Self:cCarga
	Local cPedido   := Self:cPedido
	Local cItem     := Self:cItem
	Local cSequen   := Self:cSequen
	Local cRomEmb   := Self:cRomEmb
	Local cNFiscal  := Self:cNFiscal
	Local cNFSerie  := Self:cNFSerie
	Local cNovoLoc  := ""
	Local cNovoEnd  := ""

	If nOpcao = 1
		cWhereD00 += " AND D00.D00_CARGA = '"+cCarga+"'"
	EndIf
	cWhereD00 += " AND D00.D00_PEDIDO = '"+cPedido+"'"
	If lD00Local
		cWhereD00 += " AND D00.D00_LOCDOC <> ' '"
	EndIf

	cJoin += " INNER JOIN "+RetSqlName('SC9')+" SC9 "
	cJoin += 	" ON (SC9.C9_FILIAL = '"+xFilial('SC9')+"'"
	cJoin += 		" AND SC9.C9_PEDIDO = '"+cPedido+"'"
	cJoin += 		" AND SC9.C9_ITEM = '"+cItem+"'"
	cJoin += 		" AND SC9.C9_SEQUEN = '"+cSequen+"'"
	If nOpcao = 3
		cJoin += 		" AND SC9.C9_ROMEMB = '"+cRomEmb+"'"
	EndIf
	If nOpcao = 4
		cJoin += 		" AND SC9.C9_NFISCAL = '"+cNFiscal+"'"
		cJoin += 		" AND SC9.C9_SERIENF = '"+cNFSerie+"'"
	Endif
	cJoin += 		" AND SC9.D_E_L_E_T_ = ' ')"
	
	If nOpcao = 3
		cJoin += " INNER JOIN "+RetSqlName('DCV')+" DCV "
		cJoin += 	" ON (DCV.DCV_FILIAL = '"+xFilial('DCV')+"'"
		cJoin += 		" AND DCV.DCV_PEDIDO = SC9.C9_PEDIDO"
		cJoin += 		" AND DCV.DCV_ITEM = SC9.C9_ITEM"
		cJoin += 		" AND DCV.DCV_SEQUEN = SC9.C9_SEQUEN"
		cJoin += 		" AND DCV.DCV_CODVOL = D00.D00_CODVOL
		cJoin += 		" AND DCV.D_E_L_E_T_ = ' ')"
	EndIf

	cJoin += " INNER JOIN "+RetSqlName('D0Z')+" D0Z "
	cJoin += 	" ON (D0Z.D0Z_FILIAL = '"+xFilial('D0Z')+"'"
	cJoin += 		" AND D0Z.D0Z_PEDIDO = D00.D00_PEDIDO"
	cJoin += 		" AND D0Z.D0Z_ITEM = SC9.C9_ITEM "
	cJoin += 		" AND D0Z.D0Z_SEQUEN = SC9.C9_SEQUEN"
	cJoin += 		" AND D0Z.D_E_L_E_T_ = ' ')"

	cQuery := " SELECT " + cSelD00
	cQuery +=	" FROM "+RetSqlName('D00')+" D00 "
	cQuery +=		cJoin
	cQuery +=		" WHERE D00.D00_FILIAL = '"+xFilial('D00')+"'"
	cQuery +=		cWhereD00
	cQuery +=		" AND D00.D00_CODDOC <> ' ' "
	cQuery +=				" AND (( D00.D00_OPEEMB = ' '"
	cQuery +=		" AND D00.D00_HOREMB = ' '"
	cQuery +=		" AND D00.D00_DATEMB = ' '"
	cQuery +=		" AND D00.D00_EMBARQ = ' ')"
	cQuery += 				" OR "
	cQuery += 			" (D00.D00_OPEEMB <> ' '"
	cQuery += 			" AND D00.D00_HOREMB <> ' '"
	cQuery += 			" AND D00.D00_DATEMB <> ' '"
	cQuery += 			" AND D0Z.D0Z_EMBARQ = '"+cEmbarque+"'))"
	cQuery +=		" AND D00.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)	
	If (cAliasQry)->(!EoF()) 
		If lD00Local
			cNovoLoc := (cAliasQry)->D00_LOCDOC
		EndIf
		cNovoEnd := (cAliasQry)->D00_CODDOC
	EndIf
	While((cAliasQry)->(!EoF()))
		D00->(dbGoTo((cAliasQry)->RECNOD00))
			RecLock('D00',.F.)
				D00->D00_OPEEMB := __cUserID
				D00->D00_DATEMB := dDatabase
				D00->D00_HOREMB := Time()
				D00->D00_EMBARQ := cEmbarque
			D00->(MsUnLock())
		(cAliasQry)->(DbSkip())
	EndDo
	(cAliasQry)->(DbCloseArea())

	If nOpcao = 1
		cWhereD0Z += " AND D0Z.D0Z_CARGA = '"+cCarga+"'"
	EndIf
	cWhereD0Z += " AND D0Z.D0Z_PEDIDO = '"+cPedido+"'"
	cWhereD0Z += " AND D0Z.D0Z_ITEM = '"+cItem+"'"
	cWhereD0Z += " AND D0Z.D0Z_SEQUEN = '"+cSequen+"'"
	cWhereD0Z += " AND D0Z.D0Z_EMBARQ = '"+cEmbarque+"'"

	If !Empty(cNovoLoc) .And. !Empty(cNovoEnd)
		cQuery := " SELECT R_E_C_N_O_ RECNOD0Z"
		cQuery +=	" FROM "+RetSqlName('D0Z')+" D0Z "
		cQuery +=		" WHERE D0Z.D0Z_FILIAL = '"+xFilial('D0Z')+"'"
		cQuery +=		cWhereD0Z
		cQuery +=		" AND D0Z.D_E_L_E_T_ = ' '"
		cQuery := ChangeQuery(cQuery)
		DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasD0Z,.F.,.T.)	
		While((cAliasD0Z)->(!EoF()))
			D0Z->(dbGoTo((cAliasD0Z)->RECNOD0Z))
				RecLock('D0Z',.F.)
				If lD00Local
					D0Z->D0Z_LOCAL := cNovoLoc
					D0Z->D0Z_ENDER := cNovoEnd
				EndIf
				D0Z->(MsUnLock())
			(cAliasD0Z)->(DbSkip())
		EndDo
		(cAliasD0Z)->(DbCloseArea())
	EndIf
	RestArea(aArea)
Return

