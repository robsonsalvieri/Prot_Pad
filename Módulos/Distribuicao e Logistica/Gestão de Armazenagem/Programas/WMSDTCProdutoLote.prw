#Include "Totvs.ch"
#Include "WMSDTCProdutoLote.ch"
//---------------------------------------------
/*/{Protheus.doc} WMSCLS0038
Função para permitir que a classe seja visualizada
no inspetor de objetos
@author Inovação WMS
@since 16/12/2016
@version 1.0
/*/
//---------------------------------------------
Function WMSCLS0038()
Return Nil
//--------------------------------------
/*/{Protheus.doc} WMSDTCProdutoLote
Classe lote produto
@author Inovação WMS
@since 16/12/2016
@version 1.0
/*/
//--------------------------------------
CLASS WMSDTCProdutoLote FROM LongNameClass
	// Data
	DATA oProduto
	DATA cArmazem
	DATA cLoteCtl
	DATA cNumLote
	DATA dDtValid
	DATA dDtFabric
	DATA nSaldo
	DATA nSaldo2
	DATA cPrdOrigem
	DATA cNumser
	DATA aB8_SALDO AS ARRAY
	DATA aB8_SALDO2 AS ARRAY
	DATA nRecno
	DATA cErro
	DATA lVldArm
	// Method
	METHOD New() CONSTRUCTOR
	METHOD LoadData(nIndex)
	METHOD ClearData()
	METHOD SetProduto(cProduto)
	METHOD SetArmazem(cArmazem)
	METHOD SetLoteCtl(cLoteCtl)
	METHOD SetNumLote(cNumLote)
	METHOD SetDtValid(dDtValid)
	METHOD SetDtFabr(dDtFabric)
	METHOD SetPrdOri(cPrdOrigem)
	METHOD SetNumSer(cNumSer)
	METHOD SetVldArm(lVldArm)
	METHOD GetArmazem()
	METHOD GetLoteCtl()
	METHOD GetNumLote()
	METHOD GetDtValid()
	METHOD GetDtFabr()
	METHOD GetPrdOri()
	METHOD GetNumSer()
	METHOD GetSaldo()
	METHOD GetSaldo2()
	// Dados Adicionais
	METHOD GetCodZona()
	METHOD GetEnder()
	METHOD GetNumSeri()
	METHOD GetCtrlWMS()
	METHOD GetCateg()
	METHOD GetWmsEmb()
	METHOD GetUMInd()
	METHOD GetSerEmb()
	METHOD GetSerTran()
	METHOD GetSerTrDv()
	METHOD GetSerEnt()
	METHOD GetEndEnt()
	METHOD GetSerSai()
	METHOD GetEndSai()
	METHOD GetSerReq()
	METHOD GetEndReq()
	METHOD GetSerDev()
	METHOD GetEndDev()
	METHOD GetSerECD()
	METHOD GetEndECD()
	METHOD GetSerSCD()
	METHOD GetEndSCD()
	METHOD GetArrProd()
	// Dados Genéricos
	METHOD GetProduto()
	METHOD GetPrdAnt()
	METHOD GetDesc()
	METHOD GetTipo()
	METHOD GetUM()
	METHOD GetArmPadr()
	METHOD GetGrupo()
	METHOD GetSegum()
	METHOD GetConv()
	METHOD GetTipConv()
	METHOD GetFamilia()
	METHOD GetRastro()
	METHOD GetCtrlEnd()
	METHOD GetCodNor()
	METHOD GetCodBar()
	METHOD GetProdCol()
	METHOD HasRastro()
	METHOD HasRastSub()
	METHOD Destroy()
	METHOD GetRecno()
	METHOD GetErro()
ENDCLASS
//--------------------------------------
/*/{Protheus.doc} New
Método construtor
@author felipe.m
@since 23/12/2014
@version 1.0
/*/
//--------------------------------------
METHOD New() CLASS WMSDTCProdutoLote
	Self:oProduto   := WMSDTCProdutoDadosAdicionais():New()
	Self:cArmazem   := PadR("", GetWmsSX3("B8_LOCAL", 1))
	Self:cLoteCtl   := PadR("", GetWmsSX3("B8_LOTECTL", 1))
	Self:cNumLote   := PadR("", GetWmsSX3("B8_NUMLOTE", 1))
	Self:cPrdOrigem := PadR("", GetWmsSX3("B8_PRODUTO", 1))
	Self:cNumSer    := PadR("", GetWmsSX3("D14_NUMSER", 1))
	Self:aB8_SALDO  := GetWmsSX3('B8_SALDO')
	Self:aB8_SALDO2 := GetWmsSX3('B8_SALDO2')

	Self:ClearData()
Return

METHOD ClearData() CLASS WMSDTCProdutoLote
	Self:oProduto:ClearData()
	Self:cArmazem   := PadR("", Len(Self:cArmazem))
	Self:cLoteCtl   := PadR("", Len(Self:cLoteCtl))
	Self:cNumLote   := PadR("", Len(Self:cNumLote))
	Self:cPrdOrigem := PadR("", Len(Self:cPrdOrigem))
	Self:cNumSer    := PadR("", Len(Self:cNumSer))
	Self:dDtValid   := CtoD('  /  /  ')
	Self:dDtFabric  := CtoD('  /  /  ')
	Self:nSaldo     := 0
	Self:nSaldo2    := 0
	Self:lVldArm    := .T.  // Quando este parâmetro for enviado como .F. Indica que não irá validar para que o armazém esteja informado na busca por saldo por lote.
Return Nil

METHOD Destroy() CLASS WMSDTCProdutoLote
	//FreeObj(Self)
Return Nil
//--------------------------------------
/*/{Protheus.doc} LoadData
Carregamento dos dados SB8
@author felipe.m
@since 23/12/2014
@version 1.0
@param nIndex, numérico, (Descrição do parâmetro)
/*/
//--------------------------------------
METHOD LoadData(nIndex) CLASS WMSDTCProdutoLote
Local lRet      := .T.
Local aAreaAnt  := GetArea()
Local aAreaSB8  := SB8->(GetArea())
Local cAliasSB8 := Nil
Local cWhere    := ""
Default nIndex  := 3

	If Empty(Self:GetProduto()) .Or. Empty(Self:cPrdOrigem)
		lRet := .F.
	EndIf
	If !lRet
		Self:cErro := STR0001 // Dados para busca não foram informados!
	Else
		If Self:oProduto:LoadData()
			// Se o armazem estiver vazio, busca o armazem padrão.
			If Empty(Self:cArmazem) .AND. Self:lVldArm   //Quando esta F não validar o armazem
				Self:cArmazem := Self:oProduto:GetArmPadr()
			EndIf
			Do Case
				Case nIndex == 3 // B8_FILIAL+B8_PRODUTO+B8_LOCAL+B8_LOTECTL+B8_NUMLOTE+DTOS(B8_DTVALID)
					If Empty(Self:cLoteCtl) .OR. (Self:lVldArm .AND. Empty(Self:cArmazem))
						lRet := .F.
					EndIf
				OtherWise
					lRet := .F.
			EndCase
			If lRet
				cAliasSB8 := GetNextAlias()
				Do Case
					Case nIndex == 3
						cWhere := '%'
						If Self:lVldArm
							cWhere += " AND SB8.B8_LOCAL = '" +Self:cArmazem+"'"
						EndIf
						cWhere += '%'
						BeginSql Alias cAliasSB8
							SELECT SB8.B8_PRODUTO,
									SB8.B8_LOCAL,
									SB8.B8_LOTECTL,
									SB8.B8_NUMLOTE,
									SB8.B8_DTVALID,
									SB8.B8_DFABRIC,
									SB8.B8_SALDO,
									SB8.B8_SALDO2,
									SB8.R_E_C_N_O_ RECNOSB8
							FROM %Table:SB8% SB8
							WHERE SB8.B8_FILIAL = %xFilial:SB8%
							AND SB8.B8_PRODUTO = %Exp:Self:cPrdOrigem%
							AND SB8.B8_LOTECTL = %Exp:Self:cLoteCtl%
							AND SB8.B8_NUMLOTE = %Exp:Self:cNumLote%
							AND SB8.%NotDel%
							%Exp:cWhere%
						EndSql
				EndCase
				TcSetField(cAliasSB8,'B8_DTVALID','D')
				TcSetField(cAliasSB8,'B8_DFABRIC','D')
				TCSetField(cAliasSB8,'B8_SALDO' ,'N',Self:aB8_SALDO[1] ,Self:aB8_SALDO[2])
				TCSetField(cAliasSB8,'B8_SALDO2','N',Self:aB8_SALDO2[1],Self:aB8_SALDO2[2])
				If (lRet := (cAliasSB8)->(!Eof()))
					Self:cArmazem := (cAliasSB8)->B8_LOCAL
					Self:cLoteCtl := (cAliasSB8)->B8_LOTECTL
					Self:cNumLote := (cAliasSB8)->B8_NUMLOTE
					Self:dDtValid := (cAliasSB8)->B8_DTVALID
					Self:dDtFabric:= (cAliasSB8)->B8_DFABRIC
					Self:nSaldo   := (cAliasSB8)->B8_SALDO
					Self:nSaldo2  := (cAliasSB8)->B8_SALDO2
					Self:nRecno   := (cAliasSB8)->RECNOSB8
				EndIf
				(cAliasSB8)->(dbCloseArea())
			Else
				Self:cErro := WmsFmtMsg(STR0002,{{"[VAR01]",Self:cLoteCtl},{"[VAR02]",Self:GetProduto()}}) // Lote [VAR01] e produto [VAR02] não cadastrado (SB8)!"
			EndIf
		Else
			lRet := .F.
			Self:cErro := Self:oProduto:GetErro()
		EndIf
	EndIf
	RestArea(aAreaSB8)
	RestArea(aAreaAnt)
Return lRet
//-----------------------------------
// Setters
//-----------------------------------
METHOD SetArmazem(cArmazem) CLASS WMSDTCProdutoLote
	Self:cArmazem := PadR(cArmazem, Len(Self:cArmazem))
Return

METHOD SetLoteCtl(cLoteCtl) CLASS WMSDTCProdutoLote
	Self:cLoteCtl := PadR(cLoteCtl, Len(Self:cLoteCtl))
Return

METHOD SetNumLote(cNumLote) CLASS WMSDTCProdutoLote
	Self:cNumLote := PadR(cNumLote, Len(Self:cNumLote))
Return

METHOD SetDtValid(dDtValid) CLASS WMSDTCProdutoLote
	Self:dDtValid := dDtValid
Return

METHOD SetDtFabr(dDtFabric) CLASS WMSDTCProdutoLote
	Self:dDtFabric := dDtFabric
Return

// Dados Genericos
METHOD SetProduto(cProduto) CLASS WMSDTCProdutoLote
	Self:oProduto:SetProduto(cProduto)
Return

METHOD SetPrdOri(cPrdOrigem) CLASS WMSDTCProdutoLote
	Self:cPrdOrigem := PadR(cPrdOrigem, Len(Self:cPrdOrigem))
Return

METHOD SetNumSer(cNumSer) CLASS WMSDTCProdutoLote
	Self:cNumSer := PadR(cNumSer, Len(Self:cNumSer))
Return

METHOD SetVldArm(lVldArm) CLASS WMSDTCProdutoLote
	Self:lVldArm := lVldArm
Return

//-----------------------------------
// Getters
//-----------------------------------
METHOD GetArmazem() CLASS WMSDTCProdutoLote
Return Self:cArmazem

METHOD GetLoteCtl() CLASS WMSDTCProdutoLote
Return Self:cLoteCtl

METHOD GetNumLote() CLASS WMSDTCProdutoLote
Return Self:cNumLote

METHOD GetDtValid() CLASS WMSDTCProdutoLote
Return Self:dDtValid

METHOD GetDtFabr() CLASS WMSDTCProdutoLote
Return Self:dDtFabric

// Dados Adicionais
METHOD GetCodZona() CLASS WMSDTCProdutoLote
Return Self:oProduto:GetCodZona()

METHOD GetEnder() CLASS WMSDTCProdutoLote
Return Self:oProduto:GetEnder()

METHOD GetNumSeri() CLASS WMSDTCProdutoLote
Return Self:oProduto:GetNumSeri()

METHOD GetCtrlWMS() CLASS WMSDTCProdutoLote
Return Self:oProduto:GetCtrlWMS()

METHOD GetCateg() CLASS WMSDTCProdutoLote
Return Self:oProduto:GetCateg()

METHOD GetWmsEmb() CLASS WMSDTCProdutoLote
Return Self:oProduto:GetWmsEmb()

METHOD GetUMInd() CLASS WMSDTCProdutoLote
Return Self:oProduto:GetUMInd()

METHOD GetSerEmb() CLASS WMSDTCProdutoLote
Return Self:oProduto:GetSerEmb()

METHOD GetSerTran() CLASS WMSDTCProdutoLote
Return Self:oProduto:GetSerTran()

METHOD GetSerTrDv() CLASS WMSDTCProdutoLote
Return Self:oProduto:GetSerTrDv()

METHOD GetSerEnt() CLASS WMSDTCProdutoLote
Return Self:oProduto:GetSerEnt()

METHOD GetEndEnt() CLASS WMSDTCProdutoLote
Return Self:oProduto:GetEndEnt()

METHOD GetSerSai() CLASS WMSDTCProdutoLote
Return Self:oProduto:GetSerSai()

METHOD GetEndSai() CLASS WMSDTCProdutoLote
Return Self:oProduto:GetEndSai()

METHOD GetSerReq() CLASS WMSDTCProdutoLote
Return Self:oProduto:GetSerReq()

METHOD GetEndReq() CLASS WMSDTCProdutoLote
Return Self:oProduto:GetEndReq()

METHOD GetSerDev() CLASS WMSDTCProdutoLote
Return Self:oProduto:GetSerDev()

METHOD GetEndDev() CLASS WMSDTCProdutoLote
Return Self:oProduto:GetEndDev()

METHOD GetSerECD() CLASS WMSDTCProdutoLote
Return Self:oProduto:GetSerECD()

METHOD GetEndECD() CLASS WMSDTCProdutoLote
Return Self:oProduto:GetEndECD()

METHOD GetSerSCD() CLASS WMSDTCProdutoLote
Return Self:oProduto:GetSerSCD()

METHOD GetEndSCD() CLASS WMSDTCProdutoLote
Return Self:oProduto:GetEndSCD()

METHOD GetArrProd() CLASS WMSDTCProdutoLote
Return Self:oProduto:GetArrProd()
// Dados Genéricos
METHOD GetProduto() CLASS WMSDTCProdutoLote
Return Self:oProduto:GetProduto()

METHOD GetPrdAnt() CLASS WMSDTCProdutoLote
Return Self:oProduto:GetPrdAnt()

METHOD GetPrdOri() CLASS WMSDTCProdutoLote
Return Self:cPrdOrigem

METHOD GetNumSer() CLASS WMSDTCProdutoLote
Return Self:cNumSer

METHOD GetDesc() CLASS WMSDTCProdutoLote
Return Self:oProduto:GetDesc()

METHOD GetTipo() CLASS WMSDTCProdutoLote
Return Self:oProduto:GetTipo()

METHOD GetUM() CLASS WMSDTCProdutoLote
Return Self:oProduto:GetUM()

METHOD GetArmPadr() CLASS WMSDTCProdutoLote
Return Self:oProduto:GetArmPadr()

METHOD GetGrupo() CLASS WMSDTCProdutoLote
Return Self:oProduto:GetGrupo()

METHOD GetSegum() CLASS WMSDTCProdutoLote
Return Self:oProduto:GetSegum()

METHOD GetConv() CLASS WMSDTCProdutoLote
Return Self:oProduto:GetConv()

METHOD GetTipConv() CLASS WMSDTCProdutoLote
Return Self:oProduto:GetTipConv()

METHOD GetFamilia() CLASS WMSDTCProdutoLote
Return Self:oProduto:GetFamilia()

METHOD GetRastro() CLASS WMSDTCProdutoLote
Return Self:oProduto:GetRastro()

METHOD GetCtrlEnd() CLASS WMSDTCProdutoLote
Return Self:oProduto:GetCtrlEnd()

METHOD GetCodNor() CLASS WMSDTCProdutoLote
Return Self:oProduto:GetCodNor()

METHOD GetCodBar() CLASS WMSDTCProdutoLote
Return Self:oProduto:GetCodBar()

METHOD GetProdCol() CLASS WMSDTCProdutoLote
Return Self:oProduto:GetProdCol()

METHOD HasRastro() CLASS WMSDTCProdutoLote
Return Self:oProduto:HasRastro()

METHOD HasRastSub() CLASS WMSDTCProdutoLote
Return Self:oProduto:HasRastSub()

METHOD GetRecno() CLASS WMSDTCProdutoLote
Return Self:nRecno

METHOD GetErro() CLASS WMSDTCProdutoLote
Return Self:cErro
