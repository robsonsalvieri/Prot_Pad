#Include "Totvs.ch"
#include "WMSBCCEnderecamentoUnitizado.ch"

#define RELDETUNI  06
#define RELDETEND  09

// Deve fazer assim para permitir criar as TEMPs fora da transação
Static __aTemps := {Nil,Nil,Nil,Nil,Nil,Nil}
Static __nCount := 0

//------------------------------------------------------------------------------
Function WMSCLS0092()
Return Nil

Static Function ConvNum(nVal)
Return LTrim(Str(nVal))

//------------------------------------------------------------------------------
// Crias as tabelas temporárias necessárias para o funcionamento da rotina
//------------------------------------------------------------------------------
Function WMSCTPENDU()
	// Se não existir a tabela temporária cria nesse momento
	If WmsX212118("D0Y")
		If __nCount == 0
			__aTemps[1] := TmpUnitiz()
			__aTemps[2] := TmpItClas()
			__aTemps[3] := TmpEndDes()
			__aTemps[4] := TmpEndOut()
			__aTemps[5] := TmpSldD14()
			__aTemps[6] := TmpEndOcp()
		EndIf
	EndIf
	__nCount++
Return __aTemps

//------------------------------------------------------------------------------
// Deleta as tabelas tabelas temporárias criadas para a rotina
//------------------------------------------------------------------------------
Function WMSDTPENDU()
	__nCount--
	If __nCount == 0
		If __aTemps[1] != Nil
			__aTemps[1]:Delete()
			FreeObj(__aTemps[1])
		EndIf
		If __aTemps[2] != Nil
			__aTemps[2]:Delete()
			FreeObj(__aTemps[2])
		EndIf
		If __aTemps[3] != Nil
			__aTemps[3]:Delete()
			FreeObj(__aTemps[3])
		EndIf
		If __aTemps[4] != Nil
			__aTemps[4]:Delete()
			FreeObj(__aTemps[4])
		EndIf
		If __aTemps[5] != Nil
			__aTemps[5]:Delete()
			FreeObj(__aTemps[5])
		EndIf
		If __aTemps[6] != Nil
			__aTemps[6]:Delete()
			FreeObj(__aTemps[6])
		EndIf
	EndIf
Return

//------------------------------------------------------------------------------
// Retorna a referência das tabelas tabelas temporárias criadas para a rotina
//------------------------------------------------------------------------------
Function WMSGTPENDU()
Return __aTemps

Function WMSGTPSD14()
Return __aTemps[5]

//------------------------------------------------------------------------------
Static Function TmpUnitiz()
Local aCampos := {}
Local aTamSX3 := {}
Local oTmpUnitiz := Nil

	aTamSX3 := TamSx3('D14_IDUNIT'); AAdd(aCampos,{"TP1_IDUNIT","C",aTamSX3[1],aTamSX3[2]})
	aTamSX3 := TamSx3('D14_CODUNI'); AAdd(aCampos,{"TP1_CODUNI","C",aTamSX3[1],aTamSX3[2]})
	aTamSX3 := TamSx3('D14_LOCAL');  AAdd(aCampos,{"TP1_LOCORI" ,"C",aTamSX3[1],aTamSX3[2]})
	AAdd(aCampos,{"TP1_LOCDES" ,"C",aTamSX3[1],aTamSX3[2]})
	aTamSX3 := TamSx3('D14_ENDER');  AAdd(aCampos,{"TP1_ENDDES" ,"C",aTamSX3[1],aTamSX3[2]})
	AAdd(aCampos,{"TP1_ENDORI" ,"C",aTamSX3[1],aTamSX3[2]})
	AAdd(aCampos,{"TP1_CODCLA","N",10,0})
	AAdd(aCampos,{"TP1_DCFREC","N",10,0})

	CriaTabTmp(aCampos,{"TP1_IDUNIT","TP1_CODCLA"},Nil,@oTmpUnitiz)
Return oTmpUnitiz

//------------------------------------------------------------------------------
Static Function TmpItClas()
Local aCampos := {}
Local aTamSX3 := {}
Local oTmpItClas := Nil

	AAdd(aCampos,{"TP2_CODCLA","N",10,0})
	aTamSX3 := TamSx3('D14_LOCAL');  AAdd(aCampos,{"TP2_LOCAL" ,"C",aTamSX3[1],aTamSX3[2]})
	aTamSX3 := TamSx3('D14_PRODUT'); AAdd(aCampos,{"TP2_PRODUT","C",aTamSX3[1],aTamSX3[2]})
	aTamSX3 := TamSx3('D14_LOTECT'); AAdd(aCampos,{"TP2_LOTECT","C",aTamSX3[1],aTamSX3[2]})
	aTamSX3 := TamSx3('D14_PRDORI'); AAdd(aCampos,{"TP2_PRDORI","C",aTamSX3[1],aTamSX3[2]})

	CriaTabTmp(aCampos,{"TP2_CODCLA","TP2_LOCAL+TP2_PRODUT+TP2_LOTECT"},Nil,@oTmpItClas)
Return oTmpItClas

//------------------------------------------------------------------------------
Static Function TmpEndDes()
Local aCampos := {}
Local aTamSX3 := {}
Local oTmpEndDes := Nil

	aTamSX3 := TamSx3('DCH_ORDEM'); AAdd(aCampos,{"TP3_ORDZON","C",aTamSX3[1],aTamSX3[2]})
	AAdd(aCampos,{"TP3_ORDDC8","C",2,0})
	aTamSX3 := TamSx3('DC8_TPESTR'); AAdd(aCampos,{"TP3_TPESTR","C",aTamSX3[1],aTamSX3[2]})
	aTamSX3 := TamSx3('DC3_ORDEM'); AAdd(aCampos,{"TP3_ORDDC3","C",aTamSX3[1],aTamSX3[2]})
	AAdd(aCampos,{"TP3_ORDPRD","N",5,0}) // Ordem do Produto - Endereço Cativo
	AAdd(aCampos,{"TP3_ORDSLD","N",5,0}) // Ordem de Saldo
	AAdd(aCampos,{"TP3_ORDMOV","N",5,0}) // Ordem de Movimentação
	aTamSX3 := TamSx3('DC3_TIPEND'); AAdd(aCampos,{"TP3_TIPEND","C",aTamSX3[1],aTamSX3[2]})
	AAdd(aCampos,{"TP3_TIPOUT","C",aTamSX3[1],aTamSX3[2]}) // Tipo de endereçamento outros produtos
	aTamSX3 := TamSx3('DC3_NUNITI'); AAdd(aCampos,{"TP3_UNTTOT","N",aTamSX3[1],aTamSX3[2]}) // Numero de unitizadores (Mesmo valor para DC8_NRUNIT e BE_NRUNIT)
		/*Mesmo tamanho DC3_NUNITI*/ AAdd(aCampos,{"TP3_UNTOCU","N",aTamSX3[1],aTamSX3[2]})
	aTamSX3 := TamSx3('BE_LOCAL'); AAdd(aCampos,{"TP3_LOCAL","C",aTamSX3[1],aTamSX3[2]})
	aTamSX3 := TamSx3('BE_LOCALIZ'); AAdd(aCampos,{"TP3_ENDER","C",aTamSX3[1],aTamSX3[2]})
	aTamSX3 := TamSx3('BE_ESTFIS'); AAdd(aCampos,{"TP3_ESTFIS","C",aTamSX3[1],aTamSX3[2]})
	aTamSX3 := TamSx3('BE_CAPACID'); AAdd(aCampos,{"TP3_CAPTOT","N",aTamSX3[1],aTamSX3[2]})
	/*Mesmo tamanho BE_CAPACID*/ AAdd(aCampos,{"TP3_CAPOCU","N",aTamSX3[1],aTamSX3[2]})
	aTamSX3 := TamSx3('BE_ALTURLC'); AAdd(aCampos,{"TP3_ALTURA","N",aTamSX3[1],aTamSX3[2]})
	aTamSX3 := TamSx3('BE_LARGLC'); AAdd(aCampos,{"TP3_LARGUR","N",aTamSX3[1],aTamSX3[2]})
	aTamSX3 := TamSx3('BE_COMPRLC'); AAdd(aCampos,{"TP3_COMPRI","N",aTamSX3[1],aTamSX3[2]})
	AAdd(aCampos,{"TP3_M3ENDE","N",15,3})
	AAdd(aCampos,{"TP3_M3OCUP","N",15,3})
	aTamSX3 := TamSx3('BE_CODPRO'); AAdd(aCampos,{"TP3_CODPRO","C",aTamSX3[1],aTamSX3[2]})
	/*Mesmo tamanho BE_CODPRO*/ AAdd(aCampos,{"TP3_PRDAUX","C",aTamSX3[1],aTamSX3[2]}) // Grava o primeiro produto da classificação
	AAdd(aCampos,{"TP3_PEROCP","N",5,0}) // Uso no picking
	aTamSX3 := TamSx3('D14_QTDEST'); AAdd(aCampos,{"TP3_SLDPRD","N",aTamSX3[1],aTamSX3[2]})
	/*Mesmo tamanho D14_QTDEST*/ AAdd(aCampos,{"TP3_SLDOUT","N",aTamSX3[1],aTamSX3[2]})
	/*Mesmo tamanho D14_QTDEST*/ AAdd(aCampos,{"TP3_MOVPRD","N",aTamSX3[1],aTamSX3[2]})
	/*Mesmo tamanho D14_QTDEST*/ AAdd(aCampos,{"TP3_MOVOUT","N",aTamSX3[1],aTamSX3[2]})
	AAdd(aCampos,{"TP3_DISTAN","N",10,0})
	AAdd(aCampos,{"TP3_UTILIZ","C",1,0})

	CriaTabTmp(aCampos,{"TP3_ENDER"},Nil,@oTmpEndDes)
Return oTmpEndDes

//------------------------------------------------------------------------------
Static Function TmpEndOut()
Local aCampos := {}
Local aTamSX3 := {}
Local oTmpEndOut := Nil

	aTamSX3 := TamSx3('BE_LOCAL'); AAdd(aCampos,{"TP4_LOCAL","C",aTamSX3[1],aTamSX3[2]})
	aTamSX3 := TamSx3('BE_LOCALIZ'); AAdd(aCampos,{"TP4_ENDER","C",aTamSX3[1],aTamSX3[2]})

	CriaTabTmp(aCampos,{"TP4_ENDER"},Nil,@oTmpEndOut)
Return oTmpEndOut

//------------------------------------------------------------------------------
// Nesta temporária os campos devem ter exatamente o mesmo nome da tabela D14
Static Function TmpSldD14()
Local aCampos := {}
Local aTamSX3 := {}
Local oTmpSldD14 := Nil

	aTamSX3 := TamSx3('D14_FILIAL'); AAdd(aCampos,{"D14_FILIAL","C",aTamSX3[1],aTamSX3[2]})
	aTamSX3 := TamSx3('D14_IDUNIT'); AAdd(aCampos,{"D14_IDUNIT","C",aTamSX3[1],aTamSX3[2]})
	aTamSX3 := TamSx3('D14_CODUNI'); AAdd(aCampos,{"D14_CODUNI","C",aTamSX3[1],aTamSX3[2]})
	aTamSX3 := TamSx3('D14_LOCAL');  AAdd(aCampos,{"D14_LOCAL" ,"C",aTamSX3[1],aTamSX3[2]})
	aTamSX3 := TamSx3('D14_ENDER');  AAdd(aCampos,{"D14_ENDER" ,"C",aTamSX3[1],aTamSX3[2]})
	aTamSX3 := TamSx3('D14_ESTFIS'); AAdd(aCampos,{"D14_ESTFIS","C",aTamSX3[1],aTamSX3[2]})
	aTamSX3 := TamSx3('D14_PRDORI'); AAdd(aCampos,{"D14_PRDORI","C",aTamSX3[1],aTamSX3[2]})
	aTamSX3 := TamSx3('D14_PRODUT'); AAdd(aCampos,{"D14_PRODUT","C",aTamSX3[1],aTamSX3[2]})
	aTamSX3 := TamSx3('D14_LOTECT'); AAdd(aCampos,{"D14_LOTECT","C",aTamSX3[1],aTamSX3[2]})
	aTamSX3 := TamSx3('D14_NUMLOT'); AAdd(aCampos,{"D14_NUMLOT","C",aTamSX3[1],aTamSX3[2]})
	aTamSX3 := TamSx3('D14_QTDEST'); AAdd(aCampos,{"D14_QTDEST","N",aTamSX3[1],aTamSX3[2]})
	aTamSX3 := TamSx3('D14_QTDEPR'); AAdd(aCampos,{"D14_QTDEPR","N",aTamSX3[1],aTamSX3[2]})

	CriaTabTmp(aCampos,{"D14_IDUNIT","D14_LOCAL+D14_ENDER","D14_PRODUT+D14_LOTECT+D14_NUMLOT"},Nil,@oTmpSldD14)
Return oTmpSldD14

//------------------------------------------------------------------------------
Static Function TmpEndOcp()
Local aCampos := {}
Local aTamSX3 := {}
Local oTmpEndOcp := Nil
	AAdd(aCampos,{"TP6_RECTP3","N",10,0}) // TP6_RECTP3
	aTamSX3 := TamSx3('BE_LOCAL'); AAdd(aCampos,{"TP6_LOCAL","C",aTamSX3[1],aTamSX3[2]})
	aTamSX3 := TamSx3('BE_LOCALIZ'); AAdd(aCampos,{"TP6_ENDER","C",aTamSX3[1],aTamSX3[2]})
	AAdd(aCampos,{"TP6_ORDSLD","N",5,0})    // Ordem de Saldo
	AAdd(aCampos,{"TP6_ORDMOV","N",5,0})    // Ordem de Movimentação
	aTamSX3 := TamSx3('D14_QTDEST'); AAdd(aCampos,{"TP6_SLDPRD","N",aTamSX3[1],aTamSX3[2]})
	/*Mesmo tamanho D14_QTDEST*/ AAdd(aCampos,{"TP6_SLDOUT","N",aTamSX3[1],aTamSX3[2]})
	/*Mesmo tamanho D14_QTDEST*/ AAdd(aCampos,{"TP6_MOVPRD","N",aTamSX3[1],aTamSX3[2]})
	/*Mesmo tamanho D14_QTDEST*/ AAdd(aCampos,{"TP6_MOVOUT","N",aTamSX3[1],aTamSX3[2]})
	aTamSX3 := TamSx3('DC3_TIPEND'); AAdd(aCampos,{"TP6_TIPOUT","C",aTamSX3[1],aTamSX3[2]}) // Tipo de endereçamento outros produtos
	aTamSX3 := TamSx3('DC3_NUNITI'); AAdd(aCampos,{"TP6_UNTOCU","N",aTamSX3[1],aTamSX3[2]}) // Numero de unitizadores (Mesmo valor para DC8_NRUNIT e BE_NRUNIT)

	CriaTabTmp(aCampos,{"TP6_RECTP3"},Nil,@oTmpEndOcp)
Return oTmpEndOcp

//------------------------------------------------------------------------------
CLASS WMSBCCEnderecamentoUnitizado FROM WMSDTCMovimentosServicoArmazem
	DATA aIdUnitiz AS Array
	DATA cQryUnitiz
	DATA lPriorSA
	DATA lMultPkg
	DATA nLimtPkg
	DATA lFoundPkg
	DATA nQuantPkg
	DATA lExeMovto
	DATA aNivEndOri // Array que irá conter os níveis do primeiro endereço encontrado
	DATA oTmpUnitiz // Temp Table Unitizadores (TP1)
	DATA oTmpItClas // Temp Table Itens Classificação (TP2)
	DATA oTmpEndDes // Temp Table Endereços Destino Disponíveis (TP3)
	DATA oTmpEndOut // Temp Table Endereços Destino Outros Produtos (TP4)
	DATA oTmpSldD14 // Temp Table com Saldo do Unitizador (D14)
	DATA oTmpEndOcp // Temp Table Saldos dos Endereços Destino Disponíveis (TP6)
	DATA aLogEnd
	DATA lTrfCol
	DATA lTrfUnit
	// Method
	METHOD New() CONSTRUCTOR
	METHOD Destroy()
	METHOD SetOrdServ(oOrdServ)
	METHOD SetLstUnit(aIdUnitiz)
	METHOD SetQryUnit(cQryUnitiz)
	METHOD SetLogEnd(aLogEnd)
	METHOD SetTrfCol(lTrfCol)
	METHOD SetExeMov(lExeMovto)
	METHOD GetLstUnit()

	//Method
	METHOD DelIdUnit(cIdUnitiz)
	METHOD DelItClas(nItemClass)
	METHOD DelEndDes(cArmazem,cEndereco)
	METHOD DelEndOut()
	METHOD ExecFuncao()
	METHOD FindEndUni()
	METHOD DelSldD14()
	METHOD LoadSldD14(nRecnoDCF)
	METHOD ClassUnit()
	METHOD HasClassIt(cItInClas)
	METHOD GetClasUni(cItInClas,nQtdItUnit)
	METHOD QtdItClas(nItemClass)
	METHOD ProcEndCls()
	METHOD ProcItClas(nItemClass)
	METHOD FindEndSld()
	METHOD FindNivSBE(cArmazem,cEndereco)
	METHOD FindEndPrd()
	METHOD FindEndOut()
	METHOD DelEndPer()
	METHOD DelEndPrd(cProduto)
	METHOD DelEndNot()
	METHOD OrdSldMov()
	METHOD DelEndOpc()
	METHOD ProcUnClas(nItemClass,lEndClass)
	METHOD CalcOcupac()
	METHOD ValLotUnit()
	METHOD VldProcPkg()
	METHOD GerMovClas(nItemClass)
	METHOD UnitCanEnd(lExeMovto)
	METHOD LogSemEnd(nItemClass)
	METHOD AddClasLog(nItemClass,cArmazem,cProduto,cLoteCtl,nQtdEndDis)
	METHOD AddUnitLog(cIdUnitiz,nPeso,nVolume,nAltura,nLargura,nComprim,lIsMisto)
	METHOD AddMsgLog(cOrdZon,cOrdSeq,cOrdEst,cOrdPrd,cOrdSld,cOrdMov,cTipEnd,cEstrtura,cEndereco,nPesoMax,nPesoDisp,nVolMax,nVolDisp,nAltura,nLargura,nComprim,nQtdUnMax,nQtdUnDisp,cMensagem)

ENDCLASS

//------------------------------------------------------------------------------
METHOD New() CLASS WMSBCCEnderecamentoUnitizado
	_Super:New()
	Self:oTmpUnitiz := __aTemps[1]
	Self:oTmpItClas := __aTemps[2]
	Self:oTmpEndDes := __aTemps[3]
	Self:oTmpEndOut := __aTemps[4]
	Self:oTmpSldD14 := __aTemps[5]
	Self:oTmpEndOcp := __aTemps[6]
	// MV_WMSZNSA
	// .T. = Utiliza zona de armazenagem alternativa somente se for a ultima sequencia de abastecimento
	// .F. = Utiliza zona de armazenagem alternativa para cada estrutura da sequencia de abastecimento
	Self:lPriorSA   := SuperGetMV('MV_WMSZNSA',.F.,.F.)
	Self:lMultPkg   := (SuperGetMV('MV_WMSMULP',.F.,'N')=='S') // Utiliza multiplos pickings
	Self:nLimtPkg   := SuperGetMV('MV_WMSNRPO',.F.,10) // Limite de enderecos picking ocupados
	Self:lFoundPkg  := .F.
	Self:nQuantPkg  := 0
	Self:aIdUnitiz  := {}
	Self:cQryUnitiz := ""
	Self:aNivEndOri := {}
	Self:aLogEnd    := {}
	Self:lTrfCol    := .F.
	Self:lTrfUnit   := .F.
	Self:lExeMovto  := .F.
Return

//------------------------------------------------------------------------------
METHOD Destroy() CLASS WMSBCCEnderecamentoUnitizado
	// Anula as referencia das TEMPs para não deletar
	Self:oTmpUnitiz := Nil
	Self:oTmpItClas := Nil
	Self:oTmpEndDes := Nil
	Self:oTmpEndOut := Nil
	Self:oTmpSldD14 := Nil
	Self:oTmpEndOcp := Nil
Return

//------------------------------------------------------------------------------
METHOD SetLstUnit(aIdUnitiz) CLASS WMSBCCEnderecamentoUnitizado
	Self:aIdUnitiz := aIdUnitiz
Return

//------------------------------------------------------------------------------
METHOD SetQryUnit(cQryUnitiz) CLASS WMSBCCEnderecamentoUnitizado
	Self:cQryUnitiz := cQryUnitiz
Return

//------------------------------------------------------------------------------
METHOD SetLogEnd(aLogEnd) CLASS WMSBCCEnderecamentoUnitizado
	Self:aLogEnd := aLogEnd
Return

//------------------------------------------------------------------------------
METHOD SetTrfCol(lTrfCol) CLASS WMSBCCEnderecamentoUnitizado
	Self:lTrfCol := lTrfCol
Return

//------------------------------------------------------------------------------
METHOD SetExeMov(lExeMovto) CLASS WMSBCCEnderecamentoUnitizado
	Self:lExeMovto := lExeMovto
Return

//------------------------------------------------------------------------------
METHOD GetLstUnit() CLASS WMSBCCEnderecamentoUnitizado
Return Self:aIdUnitiz

//------------------------------------------------------------------------------
METHOD SetOrdServ(oOrdServ) CLASS WMSBCCEnderecamentoUnitizado
	Self:oOrdServ := oOrdServ
	Self:oMovServic := Self:oOrdServ:oServico

	If !oOrdServ:IsMovUnit() .And. oOrdServ:oServico:HasOperac({'8'})
		Self:lTrfUnit := .T.
	EndIf
Return

//------------------------------------------------------------------------------
METHOD ExecFuncao() CLASS WMSBCCEnderecamentoUnitizado
Local lRet  := .T.

	If Self:oTmpUnitiz == Nil .Or. Self:oTmpItClas == Nil .Or.;
		Self:oTmpEndDes == Nil .Or. Self:oTmpEndOut == Nil .Or.;
		Self:oTmpSldD14 == Nil .Or. Self:oTmpEndOcp == Nil
		Self:cErro := STR0001 // Não foram criadas as temporárias necessárias para o processamento.
		lRet := .F.
	EndIf

	If lRet
		lRet := Self:FindEndUni()
	EndIf
Return lRet

//------------------------------------------------------------------------------
METHOD FindEndUni() CLASS WMSBCCEnderecamentoUnitizado
Local lRet       := .T.
Local aAreaAnt   := GetArea()
Local cAliasTP1  := ""
Local cQuery     := ""
Local nX         := 0

	// Apaga algum registro que possa existir na temporária
	If !Self:DelIdUnit()
		Return .F.
	EndIf

	If !Empty(Self:aIdUnitiz)
		cAliasTP1 := Self:oTmpUnitiz:GetAlias()
		// Carrega o array na temporária - O array deve trazer a listagem de ID de unitizadores {{'ID0001',DCF_RECNO},{'ID0002',DCF_RECNO},{'ID000N',DCF_RECNO}}
		For nX := 1 To Len(Self:aIdUnitiz)
			RecLock(cAliasTP1,.T.)
			(cAliasTP1)->TP1_IDUNIT := Self:aIdUnitiz[nX,1]
			(cAliasTP1)->TP1_DCFREC := Self:aIdUnitiz[nX,2]
			(cAliasTP1)->(MsUnlock())
		Next
	Else
		// Carrega a temporária com base no SQL passado - O SQL deve retornar apenas o ID do unitizador
		If !Empty(Self:cQryUnitiz)
			cQuery := "INSERT INTO "+Self:oTmpUnitiz:GetRealName()+" (TP1_IDUNIT,TP1_DCFREC) "
			cQuery += Self:cQryUnitiz
			If !(lRet := (TcSQLExec(cQuery) >= 0))
				Self:cErro := STR0002 // "Problema ao incluir os registros temporários de unitizador."
			EndIf
		Else
			lRet := .F.
			Self:cErro := STR0003 // "Não foram passados os unitizadores para busca de endereço."
		EndIf
	EndIf

	If lRet
		lRet := Self:ClassUnit()
	EndIf

	If lRet
		lRet := Self:ProcEndCls()
	EndIf

	RestArea(aAreaAnt)
Return lRet

//------------------------------------------------------------------------------
METHOD ClassUnit() CLASS WMSBCCEnderecamentoUnitizado
Local lRet       := .T.
Local lIsNewClas := .F.
Local cAliasD14  := ""
Local cItInClas  := ""
Local cTipUnitiz := ""
Local cLocOriUni := ""
Local cEndOriUni := ""
Local cAliasTP1  := Self:oTmpUnitiz:GetAlias()
Local cAliasTP2  := Self:oTmpItClas:GetAlias()
Local cTmpSldD14 := "%"+Self:oTmpSldD14:GetRealName()+"%"
Local nMaxClas   := 0
Local nItemClas  := 0
Local nUnitClas  := 0
Local nQtdItUnit := 0

	If !Self:DelItClas()
		Return .F.
	EndIf

	If Self:lTrfUnit
		If !Self:DelSldD14()
			Return .F.
		EndIf
	EndIf

	// Busca todos os unitizadores que estão pendentes de endereçamento
	(cAliasTP1)->(DbSetOrder(1))
	(cAliasTP1)->(DbGoTop())
	Do While lRet .And. (cAliasTP1)->(!Eof())
		Self:cIdUnitiz := (cAliasTP1)->TP1_IDUNIT

		// Se for uma transferência com unitizador destino
		// Deve carregar o saldo da OS como se fosse o saldo do unitizador
		If Self:lTrfUnit
			If !Self:LoadSldD14((cAliasTP1)->TP1_DCFREC)
				lRet := .F.
				Exit
			EndIf
		EndIf

		lIsNewClas := .F.
		nQtdItUnit := 0
		cItInClas  := ""
		cTipUnitiz := ""
		cLocOriUni := ""
		cEndOriUni := ""
		If nMaxClas == 0
			nMaxClas := 1
			lIsNewClas := .T.
		EndIf
		cAliasD14 := GetNextAlias()
		If Self:lTrfUnit
			BeginSql Alias cAliasD14
				SELECT D14.D14_CODUNI,
						D14.D14_LOCAL,
						D14.D14_ENDER,
						D14.D14_PRDORI,
						D14.D14_PRODUT,
						D14.D14_LOTECT
				FROM %Exp:cTmpSldD14% D14
				WHERE D14.D14_FILIAL = %xFilial:D14%
				AND D14.D14_IDUNIT = %Exp:Self:cIdUnitiz%
				AND D14.%NotDel%
				ORDER BY D14.D14_PRODUT,
							D14.D14_LOTECT,
							D14.D14_NUMLOT
			EndSql
		Else
			BeginSql Alias cAliasD14
				SELECT D14.D14_CODUNI,
						D14.D14_LOCAL,
						D14.D14_ENDER,
						D14.D14_PRDORI,
						D14.D14_PRODUT,
						D14.D14_LOTECT
				FROM %Table:D14% D14
				WHERE D14.D14_FILIAL = %xFilial:D14%
				AND D14.D14_IDUNIT = %Exp:Self:cIdUnitiz%
				AND D14.%NotDel%
				ORDER BY D14.D14_PRODUT,
							D14.D14_LOTECT,
							D14.D14_NUMLOT
			EndSql
		EndIf
		Do While lRet .And. (cAliasD14)->(!Eof())
			nQtdItUnit += 1
			cTipUnitiz := (cAliasD14)->D14_CODUNI
			cLocOriUni := (cAliasD14)->D14_LOCAL
			cEndOriUni := (cAliasD14)->D14_ENDER
			// A busca de endereços pela classificação deve ser sempre para o armazém destino
			Self:oMovPrdLot:SetArmazem(Self:oOrdServ:oOrdEndDes:GetArmazem())
			Self:oMovPrdLot:SetPrdOri((cAliasD14)->D14_PRDORI)
			Self:oMovPrdLot:SetProduto((cAliasD14)->D14_PRODUT)
			Self:oMovPrdLot:SetLoteCtl((cAliasD14)->D14_LOTECT)

			// Pode fazer parte de uma classificacao existente
			If !lIsNewClas
				// Verifica se o item já está classificado
				cItInClas := Self:HasClassIt(cItInClas)
				// Não foi encontrada classificacao que contem o item
				If Empty(cItInClas)
					nMaxClas += 1
					lIsNewClas := .T.
				EndIf
			EndIf

			If lIsNewClas
				nItemClas := nMaxClas
			Else
				// Registro 'temporariamente' cadastrado com o código da próxima classificacao
				nItemClas := nMaxClas + 1
			EndIf

			// Grava o item na tabela de classificações
			RecLock(cAliasTP2,.T.)
			(cAliasTP2)->TP2_CODCLA := nItemClas
			(cAliasTP2)->TP2_PRDORI := Self:oMovPrdLot:GetPrdOri()
			(cAliasTP2)->TP2_PRODUT := Self:oMovPrdLot:GetProduto()
			(cAliasTP2)->TP2_LOTECT := Self:oMovPrdLot:GetLoteCtl()
			(cAliasTP2)->TP2_LOCAL  := Self:oMovPrdLot:GetArmazem()
			(cAliasTP2)->(MsUnlock())

			(cAliasD14)->(DbSkip())
		EndDo
		(cAliasD14)->(DbCloseArea())
		If lRet .And. nQtdItUnit == 0
			lRet := .F.
			Self:cErro :=  WmsFmtMsg(STR0004,{{"[VAR01]",Self:cIdUnitiz}}) // Não foram encontrados itens para o unitizador [VAR01].
		EndIf
		If lRet
			// Os itens podem fazer parte de uma classificacao já cadastrada
			If !lIsNewClas
				// Verifica se existe pelo menos um item na lista de classificacao
				If Empty(cItInClas)
					lIsNewClas := .T.
				Else
					// Verificar se uma das classificações que compõe o cItInClas
					// Possui a mesma quantidade de itens que o palete
					nUnitClas := Self:GetClasUni(cItInClas,nQtdItUnit)
					// O código da classificacao deve ser o código que retornou
					If nUnitClas > 0
						// Deleta registros da tabela classificacao, a classificacao é igual a uma já cadastrada
						lRet := Self:DelItClas(nItemClas)
					Else
						// Nenhuma das classificacões tem a mesma quantidade de itens do palete
						lIsNewClas := .T.
					EndIf
				EndIf
				// Se deve gerar uma nova classificação, soma um a última encontrada
				If lIsNewClas
					nUnitClas := nMaxClas + 1
				EndIf
			Else
				nUnitClas := nMaxClas
			EndIf
			If lRet
				RecLock(cAliasTP1,.F.)
				(cAliasTP1)->TP1_CODUNI := cTipUnitiz
				(cAliasTP1)->TP1_LOCORI := cLocOriUni
				(cAliasTP1)->TP1_ENDORI := cEndOriUni
				(cAliasTP1)->TP1_LOCDES := Self:oMovPrdLot:GetArmazem()
				(cAliasTP1)->TP1_CODCLA := nUnitClas
				(cAliasTP1)->(MsUnlock())
				(cAliasTP1)->(DbCommit()) // Força atualização no banco, necessário apenas para UPDATE
			EndIf
		EndIf
		(cAliasTP1)->(DbSkip())
	EndDo
Return lRet
//------------------------------------------------------------------------------
METHOD HasClassIt(cItInClas) CLASS WMSBCCEnderecamentoUnitizado
Local cAliasQry  := GetNextAlias()
Local cItemClass := ""
Local cTmpItClas := "%"+Self:oTmpItClas:GetRealName()+"%"

Default cItInClas := ""
	If !Empty(cItInClas)
		BeginSql Alias cAliasQry
			SELECT TP2.TP2_CODCLA
			FROM %Exp:cTmpItClas% TP2
			WHERE TP2.TP2_LOCAL = %Exp:Self:oMovPrdLot:GetArmazem()%
			AND TP2.TP2_PRODUT = %Exp:Self:oMovPrdLot:GetProduto()%
			AND TP2.TP2_LOTECT = %Exp:Self:oMovPrdLot:GetLoteCtl()%
			AND TP2.TP2_CODCLA IN ( %Exp:cItInClas% )
			AND TP2.%NotDel%
		EndSql
	Else
		BeginSql Alias cAliasQry
			SELECT TP2.TP2_CODCLA
			FROM %Exp:cTmpItClas% TP2
			WHERE TP2.TP2_LOCAL = %Exp:Self:oMovPrdLot:GetArmazem()%
			AND TP2.TP2_PRODUT = %Exp:Self:oMovPrdLot:GetProduto()%
			AND TP2.TP2_LOTECT = %Exp:Self:oMovPrdLot:GetLoteCtl()%
			AND TP2.%NotDel%
		EndSql
	EndIf
	TCSetField(cAliasQry,"TP2_CODCLA","N",10,0)
	Do While (cAliasQry)->(!Eof())
		If Empty(cItemClass)
			cItemClass := ConvNum((cAliasQry)->TP2_CODCLA)
		Else
			cItemClass += "," + ConvNum((cAliasQry)->TP2_CODCLA)
		EndIf
		(cAliasQry)->(DbSkip())
	EndDo
	(cAliasQry)->(DbCloseArea())
Return cItemClass
//------------------------------------------------------------------------------
METHOD GetClasUni(cItInClas,nQtdItUnit) CLASS WMSBCCEnderecamentoUnitizado
Local aItemClas  := StrTokArr2(cItInClas,",")
Local nItemClass := 0
Local nQtdItClas := 0
Local nX         := 0
	For nX := 1 To Len(aItemClas)
		nItemClass := Val(aItemClas[nX])
		nQtdItClas := Self:QtdItClas(nItemClass)
		If QtdComp(nQtdItClas) == QtdComp(nQtdItUnit)
			Return nItemClass
		EndIf
	Next
Return nItemClass
//------------------------------------------------------------------------------
METHOD QtdItClas(nItemClass) CLASS WMSBCCEnderecamentoUnitizado
Local cAliasQry  := GetNextAlias()
Local cTmpItClas := "%"+Self:oTmpItClas:GetRealName()+"%"
Local nQtdItClas := 0
	BeginSql Alias cAliasQry
		SELECT COUNT(TP2.TP2_CODCLA) TP2_QTDITE
		FROM %Exp:cTmpItClas% TP2
		WHERE TP2.TP2_CODCLA = %Exp:ConvNum(nItemClass)%
		AND TP2.%NotDel%
	EndSql
	TCSetField(cAliasQry,"TP2_QTDITE","N",10,0)
	If (cAliasQry)->(!Eof())
		nQtdItClas := (cAliasQry)->TP2_QTDITE
	EndIf
	(cAliasQry)->(DbCloseArea())
Return nQtdItClas
//------------------------------------------------------------------------------
METHOD DelIdUnit(cIdUnitiz) CLASS WMSBCCEnderecamentoUnitizado
Local lRet    := .T.
Local cQuery  := ""
	cQuery := "DELETE FROM "+ Self:oTmpUnitiz:GetRealName()
	If !Empty(cIdUnitiz)
		cQuery += " WHERE TP1_IDUNIT = '"+cIdUnitiz+"'"
	EndIf
	If !(lRet := (TcSQLExec(cQuery) >= 0))
		Self:cErro := STR0005 // "Problema ao excluir os registros temporários de unitizador."
	EndIf
Return lRet
//------------------------------------------------------------------------------
METHOD DelItClas(nItemClass) CLASS WMSBCCEnderecamentoUnitizado
Local lRet    := .T.
Local cQuery  := ""
	cQuery := "DELETE FROM "+ Self:oTmpItClas:GetRealName()
	If !Empty(nItemClass)
		cQuery += " WHERE TP2_CODCLA = "+ ConvNum(nItemClass)
	EndIf
	If !(lRet := (TcSQLExec(cQuery) >= 0))
		Self:cErro := STR0006 // "Problema ao excluir a classificação temporária dos itens do unitizador."
	EndIf
Return lRet
//------------------------------------------------------------------------------
METHOD ProcEndCls() CLASS WMSBCCEnderecamentoUnitizado
Local lRet       := .T.
Local lEndClass := .F.
Local cAliasQry  := GetNextAlias()
Local cTmpItClas := "%"+Self:oTmpItClas:GetRealName()+"%"
	// Agrupa os itens por classificação, buscando os endereços para classificação
	BeginSQl Alias cAliasQry
		SELECT TP2.TP2_CODCLA
		FROM %Exp:cTmpItClas% TP2
		WHERE TP2.%NotDel%
		GROUP BY TP2.TP2_CODCLA
		ORDER BY TP2.TP2_CODCLA
	EndSql
	TCSetField(cAliasQry,"TP2_CODCLA","N",10,0)
	Do While lRet .And. (cAliasQry)->(!Eof())
		// Carrega os endereços possíveis para a classificação
		lRet := Self:ProcItClas((cAliasQry)->TP2_CODCLA)
		// Carrega os saldos por endereço para os endereços encontrados
		If lRet
			lRet := Self:OrdSldMov()
		EndIf
		If lRet
			lRet := Self:ProcUnClas((cAliasQry)->TP2_CODCLA,@lEndClass)
		EndIf
		If !lEndClass
			Self:oOrdServ:HasLogEnd(.T.)
		EndIf
		If lRet .And. lEndClass .And. !Self:lTrfCol
			lRet := Self:GerMovClas((cAliasQry)->TP2_CODCLA)
		EndIf
		(cAliasQry)->(DbSkip())
	EndDo
	(cAliasQry)->(DbCloseArea())
Return lRet
//------------------------------------------------------------------------------
METHOD ProcItClas(nItemClass) CLASS WMSBCCEnderecamentoUnitizado
Local lRet       := .T.
Local lPrimPrd   := .T.
Local cAliasQry  := GetNextAlias()
Local cTmpItClas := "%"+Self:oTmpItClas:GetRealName()+"%"
Local cPrimPrd   := ""
Local cLastPrd   := ""
Local nPosLog    := 0
	If !Self:DelEndDes()
		Return .F.
	EndIf
	BeginSql Alias cAliasQry
		SELECT TP2.TP2_LOCAL,
				TP2.TP2_PRODUT,
				TP2.TP2_LOTECT,
				TP2.TP2_PRDORI
		FROM %Exp:cTmpItClas% TP2
		WHERE TP2.TP2_CODCLA = %Exp:ConvNum(nItemClass)%
		AND TP2.%NotDel%
		ORDER BY TP2.TP2_LOCAL,
					TP2.TP2_PRODUT,
					TP2.TP2_LOTECT
	EndSql
	Do While lRet .And. (cAliasQry)->(!Eof())
		Self:oMovPrdLot:SetArmazem((cAliasQry)->TP2_LOCAL)
		Self:oMovPrdLot:SetPrdOri((cAliasQry)->TP2_PRDORI)
		Self:oMovPrdLot:SetProduto((cAliasQry)->TP2_PRODUT)
		Self:oMovPrdLot:SetLoteCtl((cAliasQry)->TP2_LOTECT)
		Self:oMovPrdLot:oProduto:LoadData()
		// Se for o mesmo produto, não busca novamente, pois não considera endereços por lote
		If cLastPrd == (cAliasQry)->TP2_PRODUT
			(cAliasQry)->(DbSkip())
			Loop
		EndIf
		If lPrimPrd
			cPrimPrd := (cAliasQry)->TP2_PRODUT
			nPosLog := Self:AddClasLog(nItemClass,(cAliasQry)->TP2_LOCAL,(cAliasQry)->TP2_PRODUT,(cAliasQry)->TP2_LOTECT,0)
			// Tenta encontrar um endereço com saldo para o produto, para buscar endereços "próximos"
			If (lRet := Self:FindEndSld())
				// Busca os endereços do primeiro produto da classificação carregando as informações de ordenação dos endereços
				If (lRet := Self:FindEndPrd())
					lRet := Self:DelEndPer()
				EndIf
			EndIf
		Else
			// Se tem outros produtos no unitizador, descarta os endereços fixos do primeiro produto
			If !Empty(cPrimPrd)
				lRet := Self:DelEndPrd(cPrimPrd)
				cPrimPrd := "" // Apaga o produto para executar só uma vez
			EndIf
			// Busca os endereços para os outros produtos sem considerar regras de ordenação
			If lRet .And. (lRet := Self:FindEndOut())
				// Exclui so endereços que não são comuns aos dois produtos - Primeiro e Atual
				lRet := Self:DelEndNot()
			EndIf
		EndIf
		lPrimPrd := .F.
		cLastPrd := (cAliasQry)->TP2_PRODUT
		(cAliasQry)->(DbSkip())
	EndDo
	(cAliasQry)->(DbCloseArea())
Return lRet
//------------------------------------------------------------------------------
METHOD DelEndDes(cArmazem,cEndereco) CLASS WMSBCCEnderecamentoUnitizado
Local lRet    := .T.
Local cQuery  := ""
	cQuery := "DELETE FROM "+ Self:oTmpEndDes:GetRealName()
	cQuery += " WHERE 1 = 1"
	If !Empty(cArmazem)
		cQuery += " AND TP3_LOCAL = '"+cArmazem+"'"
	EndIf
	If !Empty(cEndereco)
		cQuery += " AND TP3_ENDER = '"+cEndereco+"'"
	EndIf
	If !(lRet := (TcSQLExec(cQuery) >= 0))
		Self:cErro := STR0007 // "Problema ao excluir os registros temporários de endereços disponíveis."
	EndIf
Return lRet
//------------------------------------------------------------------------------
METHOD DelEndOut() CLASS WMSBCCEnderecamentoUnitizado
Local lRet    := .T.
Local cQuery  := ""
	cQuery := "DELETE FROM "+ Self:oTmpEndOut:GetRealName()
	If !(lRet := (TcSQLExec(cQuery) >= 0))
		Self:cErro := STR0008 // "Problema ao excluir os registros temporários de endereços de outros produtos."
	EndIf
Return lRet
//------------------------------------------------------------------------------
METHOD FindEndSld() CLASS WMSBCCEnderecamentoUnitizado
Local lRet      := .T.
Local lCross    := Self:oMovServic:ChkCross()
Local aAreaAnt  := GetArea()
Local cAliasSBE := GetNextAlias()
Local cCross    := "%"+Iif(lCross,"'01'","'06'")+"%"

	If Self:lPriorSA
		BeginSql Alias cAliasSBE
			SELECT ZON.ZON_ORDEM,
					CASE DC8.DC8_TPESTR
						WHEN '1' THEN (CASE WHEN DC3.DC3_PRIEND = '2' THEN '02' ELSE '03' END)
						WHEN '2' THEN (CASE WHEN DC3.DC3_PRIEND = '1' THEN '02' ELSE '03' END)
						WHEN '6' THEN '04'
						WHEN '4' THEN '05'
						WHEN '3' THEN %Exp:cCross%
						ELSE '99' END DC8_ORDEM,
					DC3.DC3_ORDEM,
					SBE.BE_LOCALIZ
			FROM %Table:SBE% SBE
			INNER JOIN %Table:DC3% DC3
			ON DC3.DC3_FILIAL = %xFilial:DC3%
			AND DC3.DC3_LOCAL = SBE.BE_LOCAL
			AND DC3.DC3_CODPRO = %Exp:Self:oMovPrdLot:GetProduto()%
			AND DC3.DC3_TPESTR = SBE.BE_ESTFIS
			AND DC3.%NotDel%
			INNER JOIN %Table:DC8% DC8
			ON DC8.DC8_FILIAL = %xFilial:DC8%
			AND DC8.DC8_CODEST = DC3.DC3_TPESTR
			AND DC8.DC8_TPESTR IN ('1','2','3','4','6') // Considera somente as estruturas: (1=Pulmao;2=Picking;3=Cross Docking;4=Blocado;6=Blocado Fracionado)
			AND DC8.%NotDel%
			// Verifica se já considera as zonas de armazenagem na query
			INNER JOIN (SELECT '00' ZON_ORDEM,
								B5_CODZON ZON_CODZON
						FROM %Table:SB5% SB5
						WHERE SB5.B5_FILIAL = %xFilial:SB5%
						AND SB5.B5_COD = %Exp:Self:oMovPrdLot:GetProduto()%
						AND SB5.%NotDel%
						UNION ALL
						SELECT DCH_ORDEM ZON_ORDEM,
								DCH_CODZON ZON_CODZON
						FROM %Table:DCH% DCH
						WHERE DCH.DCH_FILIAL = %xFilial:DCH%
						AND DCH.DCH_CODPRO =  %Exp:Self:oMovPrdLot:GetProduto()%
						AND DCH.DCH_CODZON <> %Exp:Self:oMovPrdLot:GetCodZona()%
						AND DCH.%NotDel% ) ZON
			ON ZON.ZON_CODZON = SBE.BE_CODZON
			// Filtros sobre o cadatro de endereço
			WHERE SBE.BE_FILIAL = %xFilial:SBE%
			AND SBE.BE_LOCAL = %Exp:Self:oMovPrdLot:GetArmazem()%
			AND SBE.%NotDel%
			AND ( EXISTS (  SELECT 1
							FROM %Table:D14% D14
							WHERE D14.D14_FILIAL = %xFilial:D14%
							AND D14.D14_LOCAL = SBE.BE_LOCAL
							AND D14.D14_ESTFIS = SBE.BE_ESTFIS
							AND D14.D14_ENDER = SBE.BE_LOCALIZ
							AND D14.D14_PRODUT = %Exp:Self:oMovPrdLot:GetProduto()%
							AND (D14.D14_QTDEST+D14.D14_QTDEPR) > 0
							AND D14.%NotDel% )
				OR (SBE.BE_CODPRO = %Exp:Self:oMovPrdLot:GetProduto()% )
				OR EXISTS ( SELECT 1 
							FROM %Table:DCP% DCP
							WHERE DCP.DCP_FILIAL = %xFilial:DCP%
							AND DCP.DCP_LOCAL = SBE.BE_LOCAL
							AND DCP.DCP_ENDERE = SBE.BE_LOCALIZ
							AND DCP.DCP_ESTFIS = SBE.BE_ESTFIS
							AND DCP.DCP_NORMA =  %Exp:Self:oMovSeqAbt:GetCodNor()%
							AND DCP.DCP_CODPRO = %Exp:Self:oMovPrdLot:GetProduto()%
							AND DCP.%NotDel% ))
			ORDER BY ZON.ZON_ORDEM,
						DC8_ORDEM,
						DC3.DC3_ORDEM,
						SBE.BE_LOCALIZ
		EndSql
	Else
		BeginSql Alias cAliasSBE
			SELECT ZON.ZON_ORDEM,
					CASE DC8.DC8_TPESTR
						WHEN '1' THEN (CASE WHEN DC3.DC3_PRIEND = '2' THEN '02' ELSE '03' END)
						WHEN '2' THEN (CASE WHEN DC3.DC3_PRIEND = '1' THEN '02' ELSE '03' END)
						WHEN '6' THEN '04'
						WHEN '4' THEN '05'
						WHEN '3' THEN %Exp:cCross%
						ELSE '99' END DC8_ORDEM,
					DC3.DC3_ORDEM,
					SBE.BE_LOCALIZ
			FROM %Table:SBE% SBE
			INNER JOIN %Table:DC3% DC3
			ON DC3.DC3_FILIAL = %xFilial:DC3%
			AND DC3.DC3_LOCAL = SBE.BE_LOCAL
			AND DC3.DC3_CODPRO = %Exp:Self:oMovPrdLot:GetProduto()%
			AND DC3.DC3_TPESTR = SBE.BE_ESTFIS
			AND DC3.%NotDel%
			INNER JOIN %Table:DC8% DC8
			ON DC8.DC8_FILIAL = %xFilial:DC8%
			AND DC8.DC8_CODEST = DC3.DC3_TPESTR
			AND DC8.DC8_TPESTR IN ('1','2','3','4','6') // Considera somente as estruturas: (1=Pulmao;2=Picking;3=Cross Docking;4=Blocado;6=Blocado Fracionado)
			AND DC8.%NotDel%
			// Verifica se já considera as zonas de armazenagem na query
			INNER JOIN (SELECT '00' ZON_ORDEM,
								B5_CODZON ZON_CODZON
						FROM %Table:SB5% SB5
						WHERE SB5.B5_FILIAL = %xFilial:SB5%
						AND SB5.B5_COD = %Exp:Self:oMovPrdLot:GetProduto()%
						AND SB5.%NotDel%
						UNION ALL
						SELECT DCH_ORDEM ZON_ORDEM,
								DCH_CODZON ZON_CODZON
						FROM %Table:DCH% DCH
						WHERE DCH.DCH_FILIAL = %xFilial:DCH%
						AND DCH.DCH_CODPRO =  %Exp:Self:oMovPrdLot:GetProduto()%
						AND DCH.DCH_CODZON <> %Exp:Self:oMovPrdLot:GetCodZona()%
						AND DCH.%NotDel% ) ZON
			ON ZON.ZON_CODZON = SBE.BE_CODZON
			// Filtros sobre o cadatro de endereço
			WHERE SBE.BE_FILIAL = %xFilial:SBE%
			AND SBE.BE_LOCAL = %Exp:Self:oMovPrdLot:GetArmazem()%
			AND SBE.%NotDel%
			AND ( EXISTS (  SELECT 1
							FROM %Table:D14% D14
							WHERE D14.D14_FILIAL = %xFilial:D14%
							AND D14.D14_LOCAL = SBE.BE_LOCAL
							AND D14.D14_ESTFIS = SBE.BE_ESTFIS
							AND D14.D14_ENDER = SBE.BE_LOCALIZ
							AND D14.D14_PRODUT = %Exp:Self:oMovPrdLot:GetProduto()%
							AND (D14.D14_QTDEST+D14.D14_QTDEPR) > 0
							AND D14.%NotDel% )
				OR (SBE.BE_CODPRO = %Exp:Self:oMovPrdLot:GetProduto()% )
				OR EXISTS ( SELECT 1 
							FROM %Table:DCP% DCP
							WHERE DCP.DCP_FILIAL = %xFilial:DCP%
							AND DCP.DCP_LOCAL = SBE.BE_LOCAL
							AND DCP.DCP_ENDERE = SBE.BE_LOCALIZ
							AND DCP.DCP_ESTFIS = SBE.BE_ESTFIS
							AND DCP.DCP_NORMA =  %Exp:Self:oMovSeqAbt:GetCodNor()%
							AND DCP.DCP_CODPRO = %Exp:Self:oMovPrdLot:GetProduto()%
							AND DCP.%NotDel% ))
			ORDER BY DC8_ORDEM,
						DC3.DC3_ORDEM,
						ZON.ZON_ORDEM,
						SBE.BE_LOCALIZ
		EndSql
	EndIf
	If (cAliasSBE)->(!Eof()) .And. !Empty((cAliasSBE)->BE_LOCALIZ)
		Self:FindNivSBE(Self:oMovPrdLot:GetArmazem(),(cAliasSBE)->BE_LOCALIZ)
	EndIf
	(cAliasSBE)->(dbCloseArea())
	RestArea(aAreaAnt)
Return lRet
//------------------------------------------------------------------------------
METHOD FindNivSBE(cArmazem,cEndereco) CLASS WMSBCCEnderecamentoUnitizado
Local lRet      := .T.
Local cAliasSBE := GetNextAlias()
Local nValNv    := 0
	Self:aNivEndOri := {}
	BeginSql Alias cAliasSBE
		SELECT DC7.DC7_SEQUEN,
				DC7.DC7_POSIC,
				DC7.DC7_PESO1,
				DC7.DC7_PESO2,
				SBE.BE_LOCALIZ,
				SBE.BE_LOCALIZ,
				SBE.BE_VALNV1,
				SBE.BE_VALNV2,
				SBE.BE_VALNV3,
				SBE.BE_VALNV4,
				SBE.BE_VALNV5,
				SBE.BE_VALNV6	
		FROM %Table:DC7% DC7
		INNER JOIN %Table:SBE% SBE
		ON SBE.BE_FILIAL = %xFilial:SBE%
		AND SBE.BE_LOCAL = %Exp:cArmazem%
		AND SBE.BE_LOCALIZ = %Exp:cEndereco%
		AND SBE.%NotDel%
		WHERE DC7.DC7_FILIAL = %xFilial:DC7%
		AND DC7.DC7_CODCFG = SBE.BE_CODCFG
		AND DC7.%NotDel%
		ORDER BY DC7_SEQUEN,
					DC7_POSIC,
					DC7_PESO1,
					DC7_PESO2
	EndSql
	TcSetField(cAliasSBE,'DC7_PESO1','N',15,0)
	TcSetField(cAliasSBE,'DC7_PESO2','N',15,0)
	TcSetField(cAliasSBE,'BE_VALNV1','N',15,0)
	TcSetField(cAliasSBE,'BE_VALNV2','N',15,0)
	TcSetField(cAliasSBE,'BE_VALNV3','N',15,0)
	TcSetField(cAliasSBE,'BE_VALNV4','N',15,0)
	TcSetField(cAliasSBE,'BE_VALNV5','N',15,0)
	TcSetField(cAliasSBE,'BE_VALNV6','N',15,0)
	Do While (cAliasSBE)->(!Eof()) .And. !Empty((cAliasSBE)->BE_LOCALIZ)
		// Niveis
		nValNv := 0
		If (cAliasSBE)->DC7_SEQUEN == "01"
			nValNv := (cAliasSBE)->BE_VALNV1
		ElseIf (cAliasSBE)->DC7_SEQUEN == "02"
			nValNv := (cAliasSBE)->BE_VALNV2
		ElseIf (cAliasSBE)->DC7_SEQUEN == "03"
			nValNv := (cAliasSBE)->BE_VALNV3
		ElseIf (cAliasSBE)->DC7_SEQUEN == "04"
			nValNv := (cAliasSBE)->BE_VALNV4
		ElseIf (cAliasSBE)->DC7_SEQUEN == "05"
			nValNv := (cAliasSBE)->BE_VALNV5
		ElseIf (cAliasSBE)->DC7_SEQUEN == "06"
			nValNv := (cAliasSBE)->BE_VALNV6
		EndIf
		aAdd(Self:aNivEndOri,{nValNv,(cAliasSBE)->DC7_PESO2,(cAliasSBE)->DC7_PESO1})
		(cAliasSBE)->(dbSkip())
	EndDo
	(cAliasSBE)->(DbCloseArea())
Return lRet
//------------------------------------------------------------------------------
// Dever carregar os endereços disponíveis numa temporária, já com saldos dos
// endereços previamente carregados e calculados, de forma a agilizar o processo
// de busca de endereços
METHOD FindEndPrd() CLASS WMSBCCEnderecamentoUnitizado
Local lRet      := .T.
Local lCross    := Self:oMovServic:ChkCross()
Local cQuery    := ""
Local cDBMS     := Upper(TCGETDB())
Local cPrdVazio := Space(TamSx3("BE_CODPRO")[1])
	cQuery :=  "INSERT INTO "+Self:oTmpEndDes:GetRealName()
	cQuery +=         "(TP3_ORDZON,"
	cQuery +=         " TP3_ORDDC8,"
	cQuery +=         " TP3_ORDDC3,"
	cQuery +=         " TP3_ORDPRD,"
	cQuery +=         " TP3_ORDSLD,"
	cQuery +=         " TP3_ORDMOV,"
	cQuery +=         " TP3_TPESTR,"
	cQuery +=         " TP3_TIPEND,"
	cQuery +=         " TP3_UNTTOT,"
	cQuery +=         " TP3_LOCAL,"
	cQuery +=         " TP3_ENDER,"
	cQuery +=         " TP3_ESTFIS,"
	cQuery +=         " TP3_CAPTOT,"
	cQuery +=         " TP3_ALTURA,"
	cQuery +=         " TP3_LARGUR,"
	cQuery +=         " TP3_COMPRI,"
	cQuery +=         " TP3_M3ENDE,"
	cQuery +=         " TP3_DISTAN,"
	cQuery +=         " TP3_CODPRO,"
	cQuery +=         " TP3_PEROCP,"
	cQuery +=         " TP3_PRDAUX,"
	cQuery +=         " TP3_UTILIZ)"
	cQuery +=  " SELECT ZON.ZON_ORDEM,"
	// Pegando as informações das sequencias de abastecimento
	// Prioridade de endereçamento 1-Picking/2-Pulmão
	cQuery += " CASE DC8.DC8_TPESTR"
	cQuery +=    " WHEN '1' THEN (CASE WHEN DC3.DC3_PRIEND = '2' THEN '02' ELSE '03' END)"
	cQuery +=    " WHEN '2' THEN (CASE WHEN DC3.DC3_PRIEND = '1' THEN '02' ELSE '03' END)"
	cQuery +=    " WHEN '6' THEN '04'"
	cQuery +=    " WHEN '4' THEN '05'"
	cQuery +=    " WHEN '3' THEN "+Iif(lCross,"'01'","'06'")
	cQuery +=    " ELSE '99' END DC8_ORDEM,"
	cQuery += " DC3.DC3_ORDEM,"
	// Se foi informado o produto no endereço ele tem prioridade
	cQuery += " CASE WHEN SBE.BE_CODPRO = '"+cPrdVazio+"' THEN 2 ELSE 1 END PRD_ORDEM,"
	cQuery += " 99 TP3_ORDSLD," // Ordem de Saldo
	cQuery += " 99 TP3_ORDMOV," // Ordem de Movimentação
	cQuery += " DC8.DC8_TPESTR,"
	cQuery += " DC3.DC3_TIPEND,"
	If WmsX312120("SBE","BE_NRUNIT")
		cQuery += "CASE WHEN (DC8.DC8_TPESTR = '2' OR DC8.DC8_TPESTR = '7') THEN (CASE WHEN (DC3.DC3_NUNITI IS NULL OR DC3.DC3_NUNITI = 0) THEN 1 ELSE DC3.DC3_NUNITI END)"
		cQuery +=     " ELSE (CASE WHEN (SBE.BE_NRUNIT IS NULL OR SBE.BE_NRUNIT = 0) THEN 1 ELSE SBE.BE_NRUNIT END) END NR_UNIIT,"
	Else
		cQuery +=  " CASE WHEN (DC3.DC3_NUNITI IS NULL OR DC3.DC3_NUNITI = 0) THEN 1 ELSE DC3.DC3_NUNITI END NR_UNIIT,"
	EndIf
	// Pegando as informações do endereço
	cQuery += " SBE.BE_LOCAL,"
	cQuery += " SBE.BE_LOCALIZ,"
	cQuery += " SBE.BE_ESTFIS,"
	cQuery += " SBE.BE_CAPACID," // BE_CAPOCUP
	cQuery += " SBE.BE_ALTURLC,"
	cQuery += " SBE.BE_LARGLC,"
	cQuery += " SBE.BE_COMPRLC,"
	cQuery += " (SBE.BE_ALTURLC*SBE.BE_LARGLC*SBE.BE_COMPRLC) BE_M3ENDER," // BE_M3OCUP
	// Calcula um Endereco Alvo com base nos Pesos atribuidos aos Niveis
	cQuery += " ((ABS(SBE.BE_VALNV1 - "+Str(Iif(Len(Self:aNivEndOri)>0,Self:aNivEndOri[1,1],0))+") * "+Str(Iif(Len(Self:aNivEndOri)>0,Self:aNivEndOri[1,2],0))+") +"
	cQuery +=  " (ABS(SBE.BE_VALNV2 - "+Str(Iif(Len(Self:aNivEndOri)>1,Self:aNivEndOri[2,1],0))+") * "+Str(Iif(Len(Self:aNivEndOri)>1,Self:aNivEndOri[2,2],0))+") +"
	cQuery +=  " (ABS(SBE.BE_VALNV3 - "+Str(Iif(Len(Self:aNivEndOri)>2,Self:aNivEndOri[3,1],0))+") * "+Str(Iif(Len(Self:aNivEndOri)>2,Self:aNivEndOri[3,2],0))+") +"
	cQuery +=  " (ABS(SBE.BE_VALNV4 - "+Str(Iif(Len(Self:aNivEndOri)>3,Self:aNivEndOri[4,1],0))+") * "+Str(Iif(Len(Self:aNivEndOri)>3,Self:aNivEndOri[4,2],0))+") +"
	cQuery +=  " (ABS(SBE.BE_VALNV5 - "+Str(Iif(Len(Self:aNivEndOri)>4,Self:aNivEndOri[5,1],0))+") * "+Str(Iif(Len(Self:aNivEndOri)>4,Self:aNivEndOri[5,2],0))+") +"
	cQuery +=  " (ABS(SBE.BE_VALNV6 - "+Str(Iif(Len(Self:aNivEndOri)>5,Self:aNivEndOri[6,1],0))+") * "+Str(Iif(Len(Self:aNivEndOri)>5,Self:aNivEndOri[6,2],0))+")"
	// Inclui o Peso  "LADO"  para  Enderecos  localizados  no  Mesmo  Nivel
	// Primario e Secundario (Ex.:Na mesma Rua e mesmo Predio)
	If Len(Self:aNivEndOri) > 1
		If "MSSQL" $ cDBMS .Or. "POSTGRES" $ cDBMS
			cQuery += "+(CASE WHEN (ABS(SBE.BE_VALNV1-"+Str(Self:aNivEndOri[1,1])+") = 0 AND ( ( SBE.BE_VALNV1-(2*( CAST(SBE.BE_VALNV1/2 AS INTEGER))) ) != ( "+Str(Self:aNivEndOri[2,1])+"-(2*( CAST("+Str(Self:aNivEndOri[2,1])+"/2 AS INTEGER))) ) )) THEN (1*"+Str(Self:aNivEndOri[1,3])+") ELSE 0 END)"
		Else
			cQuery += "+(CASE WHEN (ABS(SBE.BE_VALNV1-"+Str(Self:aNivEndOri[1,1])+") = 0 AND (MOD(SBE.BE_VALNV1,2) != MOD("+Str(Self:aNivEndOri[2,1])+",2))) THEN (1*"+Str(Self:aNivEndOri[1,3])+") ELSE 0 END)"
		EndIf
	EndIf
	cQuery += ") BE_DISTANC,"
	cQuery += " SBE.BE_CODPRO,"
	// Carregando as informações de endereço compartilhado via percentual de ocupação
	cQuery += " CASE WHEN DCP.DCP_CODPRO IS NULL THEN 0"
	cQuery +=      " WHEN (DCP.DCP_NORMA = DC3.DC3_CODNOR AND DCP.DCP_CODPRO = '"+Self:oMovPrdLot:GetProduto()+"') THEN 1"
	cQuery +=      " WHEN (DCP.DCP_NORMA = DC3.DC3_CODNOR AND DCP.DCP_CODPRO = '"+Space(TamSx3("DCP_CODPRO")[1])+"') THEN 2"
	cQuery +=      " ELSE 3"
	cQuery += " END DCP_PEROCP,"
	cQuery += "'"+Self:oMovPrdLot:GetProduto()+"' TP3_PRDAUX," // Produto usado como base para busca de saldo
	cQuery +=      " '2' TP3_UTILIZ"
	cQuery +=  " FROM "+RetSqlName("SBE")+" SBE"
	cQuery += " INNER JOIN "+RetSqlName("DC3")+" DC3"
	cQuery +=    " ON DC3.DC3_FILIAL = '"+xFilial("DC3")+"'"
	cQuery +=   " AND DC3.DC3_LOCAL  = '"+Self:oMovPrdLot:GetArmazem()+"'"
	cQuery +=   " AND DC3.DC3_CODPRO = '"+Self:oMovPrdLot:GetProduto()+"'"
	cQuery +=   " AND DC3.DC3_TPESTR = SBE.BE_ESTFIS"
	cQuery +=   " AND DC3.D_E_L_E_T_ = ' '"
	cQuery += " INNER JOIN "+RetSqlName('DC8')+" DC8"
	cQuery +=    " ON DC8.DC8_FILIAL = '"+xFilial("DC8")+"'"
	cQuery +=   " AND DC8.DC8_CODEST = DC3.DC3_TPESTR"
	cQuery +=   " AND DC8.DC8_TPESTR IN ('1','2','3','4','6')" // Considera somente as estruturas: (1=Pulmao;2=Picking;3=Cross Docking;4=Blocado;6=Blocado Fracionado)
	cQuery +=   " AND DC8.D_E_L_E_T_ = ' '"
	// Verifica se já considera as zonas de armazenagem na query
	cQuery += " INNER JOIN ("
	cQuery += "SELECT '00' ZON_ORDEM, B5_CODZON ZON_CODZON"
	cQuery += "  FROM "+RetSqlName("SB5")
	cQuery += " WHERE B5_FILIAL = '"+xFilial("SB5")+"'"
	cQuery += "   AND B5_COD    = '"+Self:oMovPrdLot:GetProduto()+"'"
	cQuery += "   AND D_E_L_E_T_ = ' '"
	cQuery += " UNION ALL "
	cQuery += "SELECT DCH_ORDEM ZON_ORDEM, DCH_CODZON ZON_CODZON"
	cQuery += "  FROM "+RetSqlName("DCH")
	cQuery += " WHERE DCH_FILIAL = '"+xFilial("DCH")+"'"
	cQuery += "   AND DCH_CODPRO = '"+Self:oMovPrdLot:GetProduto()+"'"
	cQuery += "   AND DCH_CODZON <> '"+Self:oMovPrdLot:GetCodZona()+"'"
	cQuery += "   AND D_E_L_E_T_ = ' ') ZON"
	cQuery += " ON ZON.ZON_CODZON = SBE.BE_CODZON"
	// Carrega as informações se o endereço possui percentual de ocupação
	cQuery += " LEFT JOIN "+RetSqlName("DCP")+" DCP"
	cQuery +=   " ON DCP.DCP_FILIAL = '"+xFilial("DCP")+"'"
	cQuery +=  " AND DCP.DCP_LOCAL  = SBE.BE_LOCAL"
	cQuery +=  " AND DCP.DCP_ENDERE = SBE.BE_LOCALIZ"
	cQuery +=  " AND DCP.DCP_ESTFIS = SBE.BE_ESTFIS"
	cQuery +=  " AND DCP.D_E_L_E_T_ = ' ' "
	// Filtros em cima da SBE - Endereços
	cQuery += " WHERE SBE.BE_FILIAL = '"+xFilial("SBE")+"'"
	cQuery +=   " AND SBE.BE_LOCAL  = '"+Self:oMovPrdLot:GetArmazem()+"'"
	// No caso de transferência sem informar endereço destino, não pode sugerir o mesmo
	cQuery +=   " AND SBE.BE_LOCALIZ <> '"+Self:oOrdServ:oOrdEndOri:GetEnder()+"'"
	cQuery +=   " AND (SBE.BE_CODPRO = '"+cPrdVazio+"' OR SBE.BE_CODPRO = '"+Self:oMovPrdLot:GetProduto()+"')"
	cQuery +=   " AND (DCP.DCP_CODPRO IS NULL OR DCP.DCP_CODPRO = '"+cPrdVazio+"' OR DCP.DCP_CODPRO = '"+Self:oMovPrdLot:GetProduto()+"')"
	// Desconsidera endereços com '3=Bloqueio Endereço', '4=Bloqueio Entrada' e '6=Bloqueio Inventário'
	cQuery +=   " AND SBE.BE_STATUS NOT IN ('3','4','6')"
	cQuery +=   " AND SBE.D_E_L_E_T_ = ' '"
	If !(lRet := (TcSQLExec(cQuery) >= 0))
		Self:cErro := STR0009 // "Problema ao carregar os endereços disponíveis para o primeiro produto."
	EndIf
Return lRet
//------------------------------------------------------------------------------
METHOD FindEndOut() CLASS WMSBCCEnderecamentoUnitizado
Local lRet      := .T.
Local cQuery    := ""
Local cPrdVazio := Space(TamSx3("BE_CODPRO")[1])
	If !Self:DelEndOut()
		Return .F.
	EndIf
	cQuery := "INSERT INTO "+Self:oTmpEndOut:GetRealName()
	cQuery +=       " (TP4_ENDER)"
	cQuery += " SELECT SBE.BE_LOCALIZ"
	cQuery +=  " FROM "+RetSqlName("SBE")+" SBE"
	cQuery += " INNER JOIN "+RetSqlName("DC3")+" DC3"
	cQuery +=    " ON DC3.DC3_FILIAL = '"+xFilial("DC3")+"'"
	cQuery +=   " AND DC3.DC3_LOCAL  = '"+Self:oMovPrdLot:GetArmazem()+"'"
	cQuery +=   " AND DC3.DC3_CODPRO = '"+Self:oMovPrdLot:GetProduto()+"'"
	cQuery +=   " AND DC3.DC3_TPESTR = SBE.BE_ESTFIS"
	cQuery +=   " AND DC3.D_E_L_E_T_ = ' '"
	// Verifica se já considera as zonas de armazenagem na query
	cQuery += " INNER JOIN ("
	cQuery += "SELECT '00' ZON_ORDEM, B5_CODZON ZON_CODZON"
	cQuery += "  FROM "+RetSqlName("SB5")
	cQuery += " WHERE B5_FILIAL = '"+xFilial("SB5")+"'"
	cQuery += "   AND B5_COD    = '"+Self:oMovPrdLot:GetProduto()+"'"
	cQuery += "   AND D_E_L_E_T_ = ' '"
	cQuery += " UNION ALL "
	cQuery += "SELECT DCH_ORDEM ZON_ORDEM, DCH_CODZON ZON_CODZON"
	cQuery += "  FROM "+RetSqlName("DCH")
	cQuery += " WHERE DCH_FILIAL = '"+xFilial("DCH")+"'"
	cQuery += "   AND DCH_CODPRO = '"+Self:oMovPrdLot:GetProduto()+"'"
	cQuery += "   AND DCH_CODZON <> '"+Self:oMovPrdLot:GetCodZona()+"'"
	cQuery += "   AND D_E_L_E_T_ = ' ') ZON"
	cQuery += " ON ZON.ZON_CODZON = SBE.BE_CODZON"
	// Filtros em cima da SBE - Endereços
	cQuery += " WHERE SBE.BE_FILIAL = '"+xFilial("SBE")+"'"
	cQuery +=   " AND SBE.BE_LOCAL  = '"+Self:oMovPrdLot:GetArmazem()+"'"
	cQuery +=   " AND SBE.BE_CODPRO = '"+cPrdVazio+"'" // Se for outros produtos deve ser endereços vazios
	// Desconsidera endereços com '3=Bloqueio Endereço', '4=Bloqueio Entrada' e '6=Bloqueio Inventário'
	cQuery +=   " AND SBE.BE_STATUS NOT IN ('3','4','6')"
	cQuery +=   " AND SBE.D_E_L_E_T_ = ' '"
	If !(lRet := (TcSQLExec(cQuery) >= 0))
		Self:cErro := STR0010 // "Problema ao carregar os endereços disponíveis para os outros produtos."
	EndIf
Return lRet

//------------------------------------------------------------------------------
METHOD DelEndPer() CLASS WMSBCCEnderecamentoUnitizado
Local lRet    := .T.
Local cQuery  := ""
	cQuery := "DELETE FROM "+ Self:oTmpEndDes:GetRealName()
	cQuery += " WHERE TP3_PEROCP = 3"
	If !(lRet := (TcSQLExec(cQuery) >= 0))
		Self:cErro := STR0040 //"Problema ao excluir os registros temporários com percentual de ocupação para outros produtos."
	EndIf
	If lRet
		cQuery := "DELETE FROM "+ Self:oTmpEndDes:GetRealName()
		cQuery += " WHERE TP3_PEROCP = 2"
		cQuery +=   " AND EXISTS (SELECT 1 "
		cQuery +=                 " FROM "+ Self:oTmpEndDes:GetRealName() +" TP3"
		cQuery +=                " WHERE TP3.TP3_LOCAL = "+Self:oTmpEndDes:GetRealName()+".TP3_LOCAL"
		cQuery +=                  " AND TP3.TP3_ENDER = "+Self:oTmpEndDes:GetRealName()+".TP3_ENDER"
		cQuery +=                  " AND TP3.TP3_PEROCP = 1)"
		If !(lRet := (TcSQLExec(cQuery) >= 0))
			Self:cErro := STR0040 //"Problema ao excluir os registros temporários com percentual de ocupação para outros produtos."
		EndIf
	EndIf
Return lRet
//------------------------------------------------------------------------------
METHOD DelEndPrd(cProduto) CLASS WMSBCCEnderecamentoUnitizado
Local lRet    := .T.
Local cQuery  := ""
	cQuery := "DELETE FROM "+ Self:oTmpEndDes:GetRealName()
	cQuery += " WHERE TP3_CODPRO = '"+cProduto+"'"
	If !(lRet := (TcSQLExec(cQuery) >= 0))
		Self:cErro := STR0011 // "Problema ao excluir os registros temporários cativos do primeiro produto."
	EndIf
Return lRet
//------------------------------------------------------------------------------
METHOD DelEndNot() CLASS WMSBCCEnderecamentoUnitizado
Local lRet    := .T.
Local cQuery  := ""
	cQuery := "DELETE FROM "+ Self:oTmpEndDes:GetRealName()
	cQuery += " WHERE TP3_ENDER NOT IN ("
	cQuery += "SELECT TP4_ENDER FROM "+ Self:oTmpEndOut:GetRealName()+")"
	If !(lRet := (TcSQLExec(cQuery) >= 0))
		Self:cErro := STR0012 // "Problema ao excluir os registros temporários de endereços não comuns entre os produtos."
	EndIf
Return lRet
//------------------------------------------------------------------------------
METHOD OrdSldMov() CLASS WMSBCCEnderecamentoUnitizado
Local lRet      := .T.
Local cQuery    := ""
Local lDesNotUni:= Self:lExeMovto .And. Self:DesNotUnit()
	If !Self:DelEndOpc()
		Return .F.
	EndIf
	cQuery := "INSERT INTO "+Self:oTmpEndOcp:GetRealName()
	cQuery +=       " (TP6_RECTP3,"
	cQuery +=       " TP6_LOCAL,"
	cQuery +=       " TP6_ENDER,"
	cQuery +=       " TP6_ORDSLD,"
	cQuery +=       " TP6_ORDMOV,"
	cQuery +=       " TP6_SLDPRD,"
	cQuery +=       " TP6_SLDOUT,"
	cQuery +=       " TP6_MOVPRD,"
	cQuery +=       " TP6_MOVOUT,"
	cQuery +=       " TP6_TIPOUT,"
	cQuery +=       " TP6_UNTOCU)"
	cQuery += " SELECT MAX(RECNOTP3) RECNOTP3,"
	cQuery +=        " SLD_LOCAL,"
	cQuery +=        " SLD_ENDER,"
	cQuery +=        " CASE SUM(SLD_ORDEM) WHEN 1 THEN 1 WHEN 4 THEN 2 WHEN 3 THEN 3 ELSE 99 END SLD_ORDEM,"
	cQuery +=        " CASE SUM(MOV_ORDEM) WHEN 1 THEN 1 WHEN 4 THEN 2 WHEN 3 THEN 3 ELSE 99 END MOV_ORDEM,"
	cQuery +=        " SUM(SLD_PRODUT) SLD_PRODUT,"
	cQuery +=        " SUM(SLD_OUTROS) SLD_OUTROS,"
	cQuery +=        " SUM(MOV_PRODUT) MOV_PRODUT,"
	cQuery +=        " SUM(MOV_OUTROS) MOV_OUTROS,"
	cQuery +=        " MIN(DC3_TIPEND) TIP_OUTROS,"
	cQuery +=       " ( SELECT COUNT(DISTINCT D14A.D14_IDUNIT)"
	cQuery +=           " FROM "+RetSqlName("D14")+" D14A"
	cQuery +=          " WHERE D14A.D14_FILIAL = '"+xFilial("D14")+"'"
	cQuery +=            " AND D14A.D14_LOCAL = SLD_LOCAL"
	cQuery +=            " AND D14A.D14_ENDER = SLD_ENDER"
	If Self:lExeMovto
		// Se estiver executando o movimento, não deve considerar o unitizador movimentado
		cQuery +=        " AND D14A.D14_IDUNIT <> '"+Self:cIdUnitiz+"'"
	EndIf
	cQuery +=            " AND D14A.D_E_L_E_T_ = ' ') TOT_IDUNIT"
	cQuery += " FROM ("
	// Consultando saldo do produto
	cQuery +=        " SELECT TP3.R_E_C_N_O_ RECNOTP3,"
	cQuery +=               " D14_LOCAL SLD_LOCAL,"
	cQuery +=               " D14_ENDER SLD_ENDER,"
	cQuery +=               " CASE WHEN SUM(D14_QTDEST) <= 0 THEN 0 ELSE 1 END SLD_ORDEM,"
	cQuery +=               " CASE WHEN SUM(D14_QTDEPR) <= 0 THEN 0 ELSE 1 END MOV_ORDEM,"
	cQuery +=               " SUM(D14_QTDEST) SLD_PRODUT,"
	cQuery +=               " 0 SLD_OUTROS,"
	If lDesNotUni
		cQuery +=           " SUM(D14_QTDEPR-D0S_QUANT) MOV_PRODUT,"
		cQuery +=           " 0 MOV_OUTROS,"
	Else
		cQuery +=           " SUM(D14_QTDEPR) MOV_PRODUT,"
		cQuery +=           " 0 MOV_OUTROS,"
	EndIf
	cQuery +=               " DC3_TIPEND"
	cQuery +=         "  FROM "+RetSqlName("D14")+" D14,"
	cQuery +=                  Self:oTmpEndDes:GetRealName()+" TP3,"
	cQuery +=                  RetSqlName("DC3")+" DC3"
	If lDesNotUni
		cQuery += ","+RetSqlName('D0S')+" D0S"
	EndIf
	cQuery +=         " WHERE D14_FILIAL = '"+xFilial("D14")+"'"
	cQuery +=           " AND D14_LOCAL  = TP3.TP3_LOCAL"
	cQuery +=           " AND D14_ENDER  = TP3.TP3_ENDER"
	cQuery +=           " AND D14_PRODUT = TP3.TP3_PRDAUX"
	cQuery +=           " AND (D14_QTDEST+D14_QTDEPR) > 0"
	cQuery +=           " AND D14.D_E_L_E_T_ = ' '"
	If lDesNotUni
		//Desconta quantidade do próprio untizador no cálculo, quando o endereço não possui controle do unitizador
		cQuery +=        " AND D0S_FILIAL = '"+xFilial('D0S')+"'"
		cQuery +=        " AND D0S_IDUNIT = '"+Self:cIdUnitiz+"'"
		cQuery +=        " AND D0S_PRDORI = D14_PRDORI"
		cQuery +=        " AND D0S_CODPRO = D14_PRODUT"
		cQuery +=        " AND D0S_LOTECT = D14_LOTECT"
		cQuery +=        " AND D0S_NUMLOT = D14_NUMLOT"
		cQuery +=        " AND D0S.D_E_L_E_T_ = ' '"
	ElseIf Self:lExeMovto
		// Se estiver executando o movimento, não deve considerar o unitizador movimentado
		cQuery +=       " AND D14.D14_IDUNIT <> '"+Self:cIdUnitiz+"'"
	EndIf
	cQuery +=          " AND DC3_FILIAL = '"+xFilial("DC3")+"'"
	cQuery +=          " AND DC3_LOCAL  = D14_LOCAL"
	cQuery +=          " AND DC3_CODPRO = D14_PRODUT"
	cQuery +=          " AND DC3_TPESTR = D14_ESTFIS"
	cQuery +=          " AND DC3.D_E_L_E_T_ = ' '"
	cQuery +=        " GROUP BY TP3.R_E_C_N_O_,"
	cQuery +=                 " D14_LOCAL,"
	cQuery +=                 " D14_ENDER,"
	cQuery +=                 " DC3_TIPEND"
	// Consultando o saldo de outros produtos
	cQuery +=         " UNION ALL "
	cQuery +=        " SELECT TP3.R_E_C_N_O_ RECNOTP3,"
	cQuery +=               " D14_LOCAL SLD_LOCAL,"
	cQuery +=               " D14_ENDER SLD_ENDER,"	
	cQuery +=               " CASE WHEN SUM(D14_QTDEST) <= 0 THEN 0 ELSE 3 END SLD_ORDEM,"
	cQuery +=               " CASE WHEN SUM(D14_QTDEPR) <= 0 THEN 0 ELSE 3 END MOV_ORDEM,"
	cQuery +=               " 0 SLD_PRODUT,"
	cQuery +=               " SUM(D14_QTDEST) SLD_OUTROS,"
	If lDesNotUni
		cQuery +=           " 0 MOV_PRODUT,"
		cQuery +=           " SUM(D14_QTDEPR-D0S_QUANT) MOV_OUTROS,"
	Else
		cQuery +=           " 0 MOV_PRODUT,"
		cQuery +=           " SUM(D14_QTDEPR) MOV_OUTROS,"
	EndIf
	cQuery +=               " DC3_TIPEND"
	cQuery +=       "  FROM "+RetSqlName("D14")+" D14,"
	cQuery +=                 Self:oTmpEndDes:GetRealName()+" TP3,"
	cQuery +=                 RetSqlName("DC3")+" DC3"
	If lDesNotUni
		cQuery += ","+RetSqlName('D0S')+" D0S"
	EndIf
	cQuery +=       " WHERE D14_FILIAL = '"+xFilial("D14")+"'"
	cQuery +=         " AND D14_LOCAL = TP3.TP3_LOCAL"
	cQuery +=         " AND D14_ENDER = TP3.TP3_ENDER"
	cQuery +=         " AND D14_PRODUT <> TP3.TP3_PRDAUX"
	cQuery +=         " AND (D14_QTDEST+D14_QTDEPR) > 0"
	cQuery +=         " AND D14.D_E_L_E_T_ = ' '"
	If lDesNotUni
		//Desconta quantidade do próprio untizador no cálculo, quando o endereço não possui controle do unitizador
		cQuery +=     " AND D0S_FILIAL = '"+xFilial('D0S')+"'"
		cQuery +=     " AND D0S_IDUNIT = '"+Self:cIdUnitiz+"'"
		cQuery +=     " AND D0S_PRDORI = D14_PRDORI"
		cQuery +=     " AND D0S_CODPRO = D14_PRODUT"
		cQuery +=     " AND D0S_LOTECT = D14_LOTECT"
		cQuery +=     " AND D0S_NUMLOT = D14_NUMLOT"
		cQuery +=     " AND D0S.D_E_L_E_T_ = ' '"
	ElseIf Self:lExeMovto
		// Se estiver executando o movimento, não deve considerar o unitizador movimentado
		cQuery +=     " AND D14.D14_IDUNIT <> '"+Self:cIdUnitiz+"'"
	EndIf
	cQuery +=         " AND DC3_FILIAL = '"+xFilial("DC3")+"'"
	cQuery +=         " AND DC3_LOCAL  = D14_LOCAL"
	cQuery +=         " AND DC3_CODPRO = D14_PRODUT"
	cQuery +=         " AND DC3_TPESTR = D14_ESTFIS"
	cQuery +=         " AND DC3.D_E_L_E_T_ = ' '"
	cQuery +=       " GROUP BY TP3.R_E_C_N_O_,"
	cQuery +=                " D14_LOCAL,"
	cQuery +=                " D14_ENDER,"
	cQuery +=                " DC3_TIPEND"
	cQuery += ") SLD "
	cQuery +=" GROUP BY SLD_LOCAL,"
	cQuery +=         " SLD_ENDER"	
	If !(lRet := (TcSQLExec(cQuery) >= 0))
		Self:cErro := STR0043 // Problema ao carregar os saldos dos endereços disponíveis.
	EndIf
	If lRet
		cQuery := "INSERT INTO "+Self:oTmpEndDes:GetRealName()
		cQuery +=       "( TP3_ORDZON,"
		cQuery +=        " TP3_ORDDC8,"
		cQuery +=        " TP3_TPESTR,"
		cQuery +=        " TP3_ORDDC3,"
		cQuery +=        " TP3_ORDPRD,"
		cQuery +=        " TP3_ORDSLD,"
		cQuery +=        " TP3_ORDMOV,"
		cQuery +=        " TP3_TIPEND,"
		cQuery +=        " TP3_TIPOUT,"
		cQuery +=        " TP3_UNTTOT,"
		cQuery +=        " TP3_UNTOCU,"
		cQuery +=        " TP3_LOCAL,"
		cQuery +=        " TP3_ENDER,"
		cQuery +=        " TP3_ESTFIS,"
		cQuery +=        " TP3_CAPTOT,"
		cQuery +=        " TP3_CAPOCU,"
		cQuery +=        " TP3_ALTURA,"
		cQuery +=        " TP3_LARGUR,"
		cQuery +=        " TP3_COMPRI,"
		cQuery +=        " TP3_M3ENDE,"
		cQuery +=        " TP3_M3OCUP,"
		cQuery +=        " TP3_CODPRO,"
		cQuery +=        " TP3_PRDAUX,"
		cQuery +=        " TP3_PEROCP,"
		cQuery +=        " TP3_SLDPRD,"
		cQuery +=        " TP3_SLDOUT,"
		cQuery +=        " TP3_MOVPRD,"
		cQuery +=        " TP3_MOVOUT,"
		cQuery +=        " TP3_DISTAN,"
		cQuery +=        " TP3_UTILIZ)"
		cQuery += " SELECT TP3.TP3_ORDZON,"
		cQuery +=        " TP3.TP3_ORDDC8,"
		cQuery +=        " TP3.TP3_TPESTR,"
		cQuery +=        " TP3.TP3_ORDDC3,"
		cQuery +=        " TP3.TP3_ORDPRD,"
		cQuery +=        " TP6.TP6_ORDSLD,"
		cQuery +=        " TP6.TP6_ORDMOV,"
		cQuery +=        " TP3.TP3_TIPEND,"
		cQuery +=        " TP6.TP6_TIPOUT,"
		cQuery +=        " TP3.TP3_UNTTOT,"
		cQuery +=        " TP6.TP6_UNTOCU,"
		cQuery +=        " TP3.TP3_LOCAL,"
		cQuery +=        " TP3.TP3_ENDER,"
		cQuery +=        " TP3.TP3_ESTFIS,"
		cQuery +=        " TP3.TP3_CAPTOT,"
		cQuery +=        " TP3.TP3_CAPOCU,"
		cQuery +=        " TP3.TP3_ALTURA,"
		cQuery +=        " TP3.TP3_LARGUR,"
		cQuery +=        " TP3.TP3_COMPRI,"
		cQuery +=        " TP3.TP3_M3ENDE,"
		cQuery +=        " TP3.TP3_M3OCUP,"
		cQuery +=        " TP3.TP3_CODPRO,"
		cQuery +=        " TP3.TP3_PRDAUX,"
		cQuery +=        " TP3.TP3_PEROCP,"
		cQuery +=        " TP6.TP6_SLDPRD,"
		cQuery +=        " TP6.TP6_SLDOUT,"
		cQuery +=        " TP6.TP6_MOVPRD,"
		cQuery +=        " TP6.TP6_MOVOUT,"
		cQuery +=        " TP3.TP3_DISTAN,"
		cQuery +=        " '1' TP3_UTILIZ"
		cQuery +=   " FROM "+Self:oTmpEndDes:GetRealName()+" TP3"
		cQuery +=  " INNER JOIN "+Self:oTmpEndOcp:GetRealName()+" TP6"
		cQuery +=     " ON TP6.TP6_RECTP3 = TP3.R_E_C_N_O_"
		cQuery +=    " AND TP6.D_E_L_E_T_ = ' '"
		cQuery +=  " WHERE TP3.TP3_UTILIZ = '2'"
		cQuery +=    " AND TP3.D_E_L_E_T_ = ' '"
		If !(lRet := (TcSQLExec(cQuery) >= 0))
			Self:cErro := STR0044 // Problema ao atualizar os saldos dos endereços disponíveis.
		EndIf
		// Apaga os registros com status não utilizado TP3_UTILIZ
		If lRet
			cQuery := "DELETE FROM "+ Self:oTmpEndDes:GetRealName()
			cQuery +=      " WHERE TP3_UTILIZ = '2'"
			cQuery +=        " AND EXISTS ( SELECT 1"
			cQuery +=                       " FROM "+ Self:oTmpEndOcp:GetRealName()+" TP6"
			cQuery +=                     "  WHERE TP6.TP6_RECTP3 = "+Self:oTmpEndDes:GetRealName()+".R_E_C_N_O_"
			cQuery +=                        " AND TP6.D_E_L_E_T_ = ' ')"
			cQuery +=        " AND D_E_L_E_T_ = ' '"
			If !(lRet := (TcSQLExec(cQuery) >= 0))
				Self:cErro := STR0042 // Problema ao excluir os registros temporários dos saldos dos endereços disponíveis.
			EndIf
		EndIf
	EndIf
Return lRet
//------------------------------------------------------------------------------
METHOD DelEndOpc() CLASS WMSBCCEnderecamentoUnitizado
Local lRet    := .T.
Local cQuery  := ""
	cQuery := "DELETE FROM "+ Self:oTmpEndOcp:GetRealName()
	If !(lRet := (TcSQLExec(cQuery) >= 0))
		Self:cErro := STR0042 // Problema ao excluir os registros temporários dos saldos dos endereços disponíveis.
	EndIf
Return lRet
//------------------------------------------------------------------------------
METHOD ProcUnClas(nItemClass,lEndClass) CLASS WMSBCCEnderecamentoUnitizado
Local lRet       := .T.
Local lUnitMisto := .F.
Local lLoteMisto := .F.
Local lEndUnitiz := .F.
Local aAreaAnt   := GetArea()
Local aTamSX3    := {}
Local oMntUnitiz := WMSDTCMontagemUnitizador():New()
Local cAliasUni  := Nil
Local cAliasEnd  := Nil
Local cAliasCnt  := Nil
Local cAliasTP1  := Self:oTmpUnitiz:GetAlias()
Local cAliasTP3  := Self:oTmpEndDes:GetAlias()
Local cTmpEndDes := "%"+Self:oTmpEndDes:GetRealName()+"%"
Local cTmpUnitiz := "%"+Self:oTmpUnitiz:GetRealName()+"%"
Local cTmpSldD14 := "%"+Self:oTmpSldD14:GetRealName()+"%"
Local cLastOrd   := ""
Local nPesoUnit  := 0
Local nVolUnit   := 0
Local nPosLog    := 0
Local nQtdEndDis := 0
Local nCapEstru  := 0
Local nCapEnder  := 0
Local nSaldoEnd  := 0
Local nSaldoRF   := 0
	If ValType(lEndClass) == "L"
		lEndClass := .F.
	EndIf
	cAliasEnd := GetNextAlias()
	If Self:lPriorSA
		BeginSql Alias cAliasEnd
			SELECT TP3_ORDZON,
					TP3_ORDDC8,
					TP3_ORDDC3,
					TP3_ORDPRD,
					TP3_ORDSLD,
					TP3_ORDMOV,
					TP3_DISTAN,
					TP3_ENDER,
					TP3.R_E_C_N_O_ RECNOTP3
			FROM %Exp:cTmpEndDes% TP3
			WHERE TP3.%NotDel%
			AND ( (TP3_TIPEND = '1' AND (TP3_SLDPRD+TP3_SLDOUT+TP3_MOVPRD+TP3_MOVOUT) = 0.0)
				OR (TP3_TIPEND IN ('2','3') AND (TP3_SLDOUT+TP3_MOVOUT) = 0.0)
				OR (TP3_TIPEND > '3' ))
			ORDER BY TP3_ORDZON,
						TP3_ORDDC8,
						TP3_ORDDC3,
						TP3_ORDPRD,
						TP3_ORDSLD,
						TP3_ORDMOV,
						TP3_DISTAN,
						TP3_ENDER
		EndSql
	Else
		BeginSql Alias cAliasEnd
			SELECT TP3_ORDZON,
					TP3_ORDDC8,
					TP3_ORDDC3,
					TP3_ORDPRD,
					TP3_ORDSLD,
					TP3_ORDMOV,
					TP3_DISTAN,
					TP3_ENDER,
					TP3.R_E_C_N_O_ RECNOTP3
			FROM %Exp:cTmpEndDes% TP3
			WHERE TP3.%NotDel%
			AND ( (TP3_TIPEND = '1' AND (TP3_SLDPRD+TP3_SLDOUT+TP3_MOVPRD+TP3_MOVOUT) = 0.0)
				OR (TP3_TIPEND IN ('2','3') AND (TP3_SLDOUT+TP3_MOVOUT) = 0.0)
				OR (TP3_TIPEND > '3' ))
			ORDER BY TP3_ORDDC8,
						TP3_ORDDC3,
						TP3_ORDZON,
						TP3_ORDPRD,
						TP3_ORDSLD,
						TP3_ORDMOV,
						TP3_DISTAN,
						TP3_ENDER"
		EndSql
	EndIf
	TcSetField(cAliasEnd,"TP3_ORDPRD",'N',5,0)
	TcSetField(cAliasEnd,"TP3_ORDSLD",'N',5,0)
	TcSetField(cAliasEnd,"TP3_ORDMOV",'N',5,0)
	TcSetField(cAliasEnd,"TP3_DISTAN",'N',10,0)
	If (cAliasEnd)->(Eof())
		Self:cErro := STR0013 // "Não exitem endereços disponíveis para armazenar os unitizadores."
		(cAliasEnd)->(dbCloseArea())
		Self:LogSemEnd(nItemClass)
		RestArea(aAreaAnt)
		Return .T.
	EndIf
	cAliasCnt := GetNextAlias()
	BeginSql Alias cAliasCnt
		SELECT COUNT(1) TMP_QTDEND 
		FROM (SELECT TP3_ORDZON,
					TP3_ORDDC8,
					TP3_ORDDC3,
					TP3_ORDPRD,
					TP3_ORDSLD,
					TP3_ORDMOV,
					TP3_DISTAN,
					TP3_ENDER,
					TP3.R_E_C_N_O_ RECNOTP3
				FROM %Exp:cTmpEndDes% TP3
				WHERE TP3.%NotDel%
				AND ( (TP3_TIPEND = '1' AND (TP3_SLDPRD+TP3_SLDOUT+TP3_MOVPRD+TP3_MOVOUT) = 0.0)
					OR (TP3_TIPEND IN ('2','3') AND (TP3_SLDOUT+TP3_MOVOUT) = 0.0)
					OR (TP3_TIPEND > '3' ))) TMP
	EndSql
	nQtdEndDis := (cAliasCnt)->TMP_QTDEND
	(cAliasCnt)->(DbCloseArea())
	Self:aLogEnd[Len(Self:aLogEnd),(RELDETUNI-1)] := nQtdEndDis
	// VarInfo("LOGCLS",Self:aLogEnd[Len(Self:aLogEnd)])
	(cAliasTP1)->(DbSetOrder(1))
	// Busca todos os unitizadores que estão pendentes de endereçamento para aquela classificação
	cAliasUni := GetNextAlias()
	If Self:lTrfUnit
		BeginSql Alias cAliasUni
			SELECT TP1.R_E_C_N_O_ RECNOTP1,
					SUM(D14.D14_QTDEST) D14_QTDEST
			FROM %Exp:cTmpUnitiz% TP1
			INNER JOIN %Exp:cTmpSldD14% D14
			ON D14.D14_FILIAL = %xFilial:D14%
			AND D14.D14_IDUNIT = TP1.TP1_IDUNIT
			AND D14.%NotDel%
			WHERE TP1.TP1_CODCLA = %Exp:ConvNum(nItemClass)%
			AND TP1.%NotDel%
			GROUP BY TP1.R_E_C_N_O_
			ORDER BY D14_QTDEST,
						RECNOTP1 // Do menor para o maior unitizador
		EndSql
	Else
		BeginSql Alias cAliasUni
			SELECT TP1.R_E_C_N_O_ RECNOTP1,
					SUM(D14.D14_QTDEST) D14_QTDEST
			FROM %Exp:cTmpUnitiz% TP1
			INNER JOIN %Table:D14% D14
			ON D14.D14_FILIAL = %xFilial:D14%
			AND D14.D14_IDUNIT = TP1.TP1_IDUNIT
			AND D14.%NotDel%
			WHERE TP1.TP1_CODCLA = %Exp:ConvNum(nItemClass)%
			AND TP1.%NotDel%
			GROUP BY TP1.R_E_C_N_O_
			ORDER BY D14_QTDEST,
						RECNOTP1 // Do menor para o maior unitizador
		EndSql
	EndIf
	aTamSX3 := TamSx3('D14_QTDEST'); TcSetField(cAliasUni,'D14_QTDEST','N',aTamSX3[1],aTamSX3[2])
	Do While lRet .And. (cAliasUni)->(!Eof())
		(cAliasTP1)->(DbGoTo((cAliasUni)->RECNOTP1))
		Self:cIdUnitiz := (cAliasTP1)->TP1_IDUNIT
		lEndUnitiz := .F.
		lLoteMisto := .F.
		// Atribui as informações do unitizador para calcular as informações
		oMntUnitiz:SetIdUnit(Self:cIdUnitiz)
		oMntUnitiz:SetTipUni((cAliasTP1)->TP1_CODUNI)
		oMntUnitiz:oTipUnit:LoadData()
		oMntUnitiz:SetArmazem((cAliasTP1)->TP1_LOCORI)
		oMntUnitiz:SetEnder((cAliasTP1)->TP1_ENDORI)
		lUnitMisto := oMntUnitiz:IsMultPrd(/*cProduto*/,Iif(Self:lTrfUnit,Self:oTmpSldD14,Nil))
		If !lUnitMisto
			lLoteMisto := oMntUnitiz:IsMultLot(/*cProduto*/,/*cLoteCtl*/,Iif(Self:lTrfUnit,Self:oTmpSldD14,Nil))
		EndIf
		// Calcula o peso e volume dos produtos do unitizador
		oMntUnitiz:CalcOcupac(Iif(Self:lTrfUnit,Self:oTmpSldD14,Nil))
		nPesoUnit := oMntUnitiz:GetPeso() + oMntUnitiz:oTipUnit:GetTara()
		// Se controla a altura do unitizador por 1=ProdutoxCamada, deve somar o volume do unitizador
		If oMntUnitiz:oTipUnit:GetCtrAlt() == "1"
			nVolUnit := oMntUnitiz:GetVolume() + (oMntUnitiz:oTipUnit:GetLargura() * oMntUnitiz:oTipUnit:GetComprim() * oMntUnitiz:oTipUnit:GetAltura())
		Else
			// Caso seja pela altura do unitizador, sempre será considerado o volume do unitizador por completo
			nVolUnit := (oMntUnitiz:oTipUnit:GetLargura() * oMntUnitiz:oTipUnit:GetComprim() * oMntUnitiz:oTipUnit:GetAltura())
		EndIf
		// Calcula as dimensões do unitizador (Largura, Comprimento e Altura)
		oMntUnitiz:CalcDimens(Iif(Self:lTrfUnit,Self:oTmpSldD14,Nil))
		nPosLog := Self:AddUnitLog(Self:cIdUnitiz,oMntUnitiz:GetTipUni(),nPesoUnit,nVolUnit,oMntUnitiz:GetAltura(),oMntUnitiz:GetLargura(),oMntUnitiz:GetComprim(),lUnitMisto)
		Do While lRet .And. (cAliasEnd)->(!Eof())
			(cAliasTP3)->(DbGoTo((cAliasEnd)->RECNOTP3))
			Self:oMovPrdLot:SetArmazem((cAliasTP3)->TP3_LOCAL)
			Self:oMovPrdLot:SetProduto((cAliasTP3)->TP3_PRDAUX)

			Self:oMovEndDes:SetArmazem((cAliasTP3)->TP3_LOCAL)
			Self:oMovEndDes:SetEnder((cAliasTP3)->TP3_ENDER)
			Self:oMovEndDes:SetEstFis((cAliasTP3)->TP3_ESTFIS)
			// Se mudou a ordem de estrutura fisica, deve buscar
			If !(cLastOrd == (cAliasTP3)->TP3_ORDZON+(cAliasTP3)->TP3_ORDDC8+(cAliasTP3)->TP3_ORDDC3)
				Self:nQuantPkg := 0
				Self:lFoundPkg := .F.
				If (cAliasTP3)->TP3_TPESTR == "2"
					// Para picking deve validar a norma, pois não controla o número de unitizadores
					// Calcula a norma somente uma vez para a estrtura fisica, pois todos os endereços
					// devem posuir a mesma norma, exceto quando possui percentual de ocupação
					nCapEstru := DLQtdNorma(Self:oMovPrdLot:GetProduto(),Self:oMovEndDes:GetArmazem(),Self:oMovEndDes:GetEstFis())
					If !lUnitMisto
						// Carrega a quantidade de endereço de picking já ocupados
						Self:VldProcPkg()
					EndIf
				EndIf
			EndIf
			cLastOrd := (cAliasTP3)->TP3_ORDZON+(cAliasTP3)->TP3_ORDDC8+(cAliasTP3)->TP3_ORDDC3
			If (cAliasTP3)->TP3_CAPOCU <= 0 .And. ((cAliasTP3)->TP3_ORDSLD <> 99 .Or. (cAliasTP3)->TP3_ORDMOV <> 99)
				Self:CalcOcupac()
			EndIf
			// Valida número máximo de unitizadores do endereço quando tipo de endereçamento 
			// não for de produtos diferentes
			// Estruturas do tipo picking não controla número de unitizadores
			If !((cAliasTP3)->TP3_TPESTR == "2")
				If (cAliasTP3)->TP3_UNTOCU >= (cAliasTP3)->TP3_UNTTOT
					// Estouro máximo de unitizadores
					(cAliasTP3)->(Self:AddMsgLog(TP3_ORDZON,TP3_ORDDC8,TP3_ORDDC3,TP3_ORDPRD,TP3_ORDSLD,TP3_ORDMOV,TP3_TIPEND,TP3_ESTFIS,TP3_ENDER,TP3_CAPTOT,TP3_CAPOCU,TP3_M3ENDE,TP3_M3OCUP,TP3_ALTURA,TP3_LARGUR,TP3_COMPRI,TP3_UNTTOT,TP3_UNTOCU,STR0014)) // Estouro máximo de unitizadores
					(cAliasEnd)->(DbSkip())
					Loop
				EndIf
			EndIf
			// Valida se há saldo no endereço de outros produtos
			If (cAliasTP3)->TP3_TIPEND != "4"
				If QtdComp((cAliasTP3)->TP3_SLDOUT+(cAliasTP3)->TP3_MOVOUT) > 0
					(cAliasTP3)->(Self:AddMsgLog(TP3_ORDZON,TP3_ORDDC8,TP3_ORDDC3,TP3_ORDPRD,TP3_ORDSLD,TP3_ORDMOV,TP3_TIPEND,TP3_ESTFIS,TP3_ENDER,TP3_CAPTOT,TP3_CAPOCU,TP3_M3ENDE,TP3_M3OCUP,TP3_ALTURA,TP3_LARGUR,TP3_COMPRI,TP3_UNTTOT,TP3_UNTOCU,"Endereço já utilizado por outro produto")) // Endereço já utilizado por outro produto
					(cAliasEnd)->(DbSkip())
					Loop
				ElseIf lUnitMisto
					// Tipo endereçamento não permite unitizador misto
					(cAliasTP3)->(Self:AddMsgLog(TP3_ORDZON,TP3_ORDDC8,TP3_ORDDC3,TP3_ORDPRD,TP3_ORDSLD,TP3_ORDMOV,TP3_TIPEND,TP3_ESTFIS,TP3_ENDER,TP3_CAPTOT,TP3_CAPOCU,TP3_M3ENDE,TP3_M3OCUP,TP3_ALTURA,TP3_LARGUR,TP3_COMPRI,TP3_UNTTOT,TP3_UNTOCU,STR0018)) // "Tipo endereçamento não permite unitizador misto"
					(cAliasEnd)->(DbSkip())
					Loop
				EndIf
			Else
				// Valida se o produto a ser armazenado permite compartilhar endereco
				If QtdComp((cAliasTP3)->TP3_SLDOUT+(cAliasTP3)->TP3_MOVOUT) > 0 .And. (cAliasTP3)->TP3_TIPOUT < "4"
					(cAliasTP3)->(Self:AddMsgLog(TP3_ORDZON,TP3_ORDDC8,TP3_ORDDC3,TP3_ORDPRD,TP3_ORDSLD,TP3_ORDMOV,TP3_TIPOUT,TP3_ESTFIS,TP3_ENDER,TP3_CAPTOT,TP3_CAPOCU,TP3_M3ENDE,TP3_M3OCUP,TP3_ALTURA,TP3_LARGUR,TP3_COMPRI,TP3_UNTTOT,TP3_UNTOCU,"Possui produto que não compartilha endereço")) // "Possui produto que não compartilha endereço"
					(cAliasEnd)->(dbSkip())
					Loop
				EndIf
			EndIf
			// No picking não deve guardar unitizador misto
			If (cAliasTP3)->TP3_TPESTR == "2"
				// Somente valida as informações de picking se o endereço não possui saldo
				// Se possui saldo, vai validar a se ainda pode guardar no endereço na sequência
				If !Self:lExeMovto .And. !lUnitMisto .And. QtdComp((cAliasTP3)->TP3_SLDPRD+(cAliasTP3)->TP3_MOVPRD) <= 0
					// Encontrou endereço de picking. Múltiplos = Não
					If !Self:lMultPkg .And. Self:lFoundPkg
						(cAliasTP3)->(Self:AddMsgLog(TP3_ORDZON,TP3_ORDDC8,TP3_ORDDC3,TP3_ORDPRD,TP3_ORDSLD,TP3_ORDMOV,TP3_TIPEND,TP3_ESTFIS,TP3_ENDER,TP3_CAPTOT,TP3_CAPOCU,TP3_M3ENDE,TP3_M3OCUP,TP3_ALTURA,TP3_LARGUR,TP3_COMPRI,TP3_UNTTOT,TP3_UNTOCU,STR0016)) // "Encontrou endereço de picking. Múltiplos = Não"
						(cAliasEnd)->(DbSkip())
						Loop
					EndIf
					// MV_WMSNRPO = Limite de enderecos picking ocupados
					If Self:nLimtPkg > 0 .And. Self:nLimtPkg <= Self:nQuantPkg
						(cAliasTP3)->(Self:AddMsgLog(TP3_ORDZON,TP3_ORDDC8,TP3_ORDDC3,TP3_ORDPRD,TP3_ORDSLD,TP3_ORDMOV,TP3_TIPEND,TP3_ESTFIS,TP3_ENDER,TP3_CAPTOT,TP3_CAPOCU,TP3_M3ENDE,TP3_M3OCUP,TP3_ALTURA,TP3_LARGUR,TP3_COMPRI,TP3_UNTTOT,TP3_UNTOCU,WmsFmtMsg(STR0017,{{"[VAR01]",Str(Self:nLimtPkg)}}))) // Limite de endereços picking ocupados ([VAR01])
						(cAliasEnd)->(DbSkip())
						Loop
					EndIf
				EndIf
			EndIf
			// Se não permite misturar lotes de um mesmo produto
			If (cAliasTP3)->TP3_TIPEND == "3"
				// Verifica se o unitizador a ser armazenado possui mais de um lote
				If lLoteMisto
					// Tipo endereçamento não permite misturar lotes
					(cAliasTP3)->(Self:AddMsgLog(TP3_ORDZON,TP3_ORDDC8,TP3_ORDDC3,TP3_ORDPRD,TP3_ORDSLD,TP3_ORDMOV,TP3_TIPEND,TP3_ESTFIS,TP3_ENDER,TP3_CAPTOT,TP3_CAPOCU,TP3_M3ENDE,TP3_M3OCUP,TP3_ALTURA,TP3_LARGUR,TP3_COMPRI,TP3_UNTTOT,TP3_UNTOCU,STR0019)) // "Tipo end. não permite misturar lotes (Unitizador)"
					(cAliasEnd)->(DbSkip())
					Loop
				EndIf
				// Verifica se o unitizador a ser armazenado possui um lote diferente do existente no endereço
				If (cAliasTP3)->TP3_ORDSLD <> 99 .Or. (cAliasTP3)->TP3_ORDMOV <> 99
					If !Self:ValLotUnit()
						// Endereço possui lote diferente unitizador
						(cAliasTP3)->(Self:AddMsgLog(TP3_ORDZON,TP3_ORDDC8,TP3_ORDDC3,TP3_ORDPRD,TP3_ORDSLD,TP3_ORDMOV,TP3_TIPEND,TP3_ESTFIS,TP3_ENDER,TP3_CAPTOT,TP3_CAPOCU,TP3_M3ENDE,TP3_M3OCUP,TP3_ALTURA,TP3_LARGUR,TP3_COMPRI,TP3_UNTTOT,TP3_UNTOCU,STR0020)) // "Tipo end. não permite misturar lotes (Endereço)"
						(cAliasEnd)->(DbSkip())
						Loop
					EndIf
				EndIf
			EndIf
			// Não precisa validar se não permite misturar produtos, já desconsidera no SELECT
			// Valida peso máximo do endereço
			If QtdComp((cAliasTP3)->TP3_CAPOCU + nPesoUnit) > QtdComp((cAliasTP3)->TP3_CAPTOT)
				// Estouro peso máximo
				(cAliasTP3)->(Self:AddMsgLog(TP3_ORDZON,TP3_ORDDC8,TP3_ORDDC3,TP3_ORDPRD,TP3_ORDSLD,TP3_ORDMOV,TP3_TIPEND,TP3_ESTFIS,TP3_ENDER,TP3_CAPTOT,TP3_CAPOCU,TP3_M3ENDE,TP3_M3OCUP,TP3_ALTURA,TP3_LARGUR,TP3_COMPRI,TP3_UNTTOT,TP3_UNTOCU,STR0021)) // "Estouro peso máximo"
				(cAliasEnd)->(DbSkip())
				Loop
			EndIf
			// Valida volume máximo do endereço
			If QtdComp((cAliasTP3)->TP3_M3OCUP + nVolUnit) > QtdComp((cAliasTP3)->TP3_M3ENDE)
				// Estouro volume máximo
				(cAliasTP3)->(Self:AddMsgLog(TP3_ORDZON,TP3_ORDDC8,TP3_ORDDC3,TP3_ORDPRD,TP3_ORDSLD,TP3_ORDMOV,TP3_TIPEND,TP3_ESTFIS,TP3_ENDER,TP3_CAPTOT,TP3_CAPOCU,TP3_M3ENDE,TP3_M3OCUP,TP3_ALTURA,TP3_LARGUR,TP3_COMPRI,TP3_UNTTOT,TP3_UNTOCU,STR0022)) // "Estouro volume máximo"
				(cAliasEnd)->(DbSkip())
				Loop
			EndIf
			// Valida largura máxima do endereço
			If QtdComp(oMntUnitiz:GetLargura()) > QtdComp((cAliasTP3)->TP3_LARGUR)
				// Largura unitizador maior que endereço
				(cAliasTP3)->(Self:AddMsgLog(TP3_ORDZON,TP3_ORDDC8,TP3_ORDDC3,TP3_ORDPRD,TP3_ORDSLD,TP3_ORDMOV,TP3_TIPEND,TP3_ESTFIS,TP3_ENDER,TP3_CAPTOT,TP3_CAPOCU,TP3_M3ENDE,TP3_M3OCUP,TP3_ALTURA,TP3_LARGUR,TP3_COMPRI,TP3_UNTTOT,TP3_UNTOCU,STR0023)) // "Largura unitizador maior que endereço"
				(cAliasEnd)->(DbSkip())
				Loop
			EndIf
			// Valida comprimento máximo do endereço
			If QtdComp(oMntUnitiz:GetComprim()) > QtdComp((cAliasTP3)->TP3_COMPRI)
				// Comprimento unitizador maior que endereço
				(cAliasTP3)->(Self:AddMsgLog(TP3_ORDZON,TP3_ORDDC8,TP3_ORDDC3,TP3_ORDPRD,TP3_ORDSLD,TP3_ORDMOV,TP3_TIPEND,TP3_ESTFIS,TP3_ENDER,TP3_CAPTOT,TP3_CAPOCU,TP3_M3ENDE,TP3_M3OCUP,TP3_ALTURA,TP3_LARGUR,TP3_COMPRI,TP3_UNTTOT,TP3_UNTOCU,STR0024)) // "Comprimento unitizador maior que endereço"
				(cAliasEnd)->(DbSkip())
				Loop
			EndIf
			// Valida altura máxima do endereço
			If QtdComp(oMntUnitiz:GetAltura()) > QtdComp((cAliasTP3)->TP3_ALTURA)
				// Altura unitizador maior que endereço
				(cAliasTP3)->(Self:AddMsgLog(TP3_ORDZON,TP3_ORDDC8,TP3_ORDDC3,TP3_ORDPRD,TP3_ORDSLD,TP3_ORDMOV,TP3_TIPEND,TP3_ESTFIS,TP3_ENDER,TP3_CAPTOT,TP3_CAPOCU,TP3_M3ENDE,TP3_M3OCUP,TP3_ALTURA,TP3_LARGUR,TP3_COMPRI,TP3_UNTTOT,TP3_UNTOCU,STR0025)) // "Altura unitizador maior que endereço
				(cAliasEnd)->(DbSkip())
				Loop
			EndIf
			// Se for picking, como não valida Qtd Unitizador, deve validar ainda a norma do produto
			If (cAliasTP3)->TP3_TPESTR == "2"
				// Se não utiliza percentual de ocupação utiliza a capacidade da estrutura, senão calcula a do endereço
				nCapEnder := Iif((cAliasTP3)->TP3_PEROCP==0,nCapEstru,DLQtdNorma(Self:oMovPrdLot:GetProduto(),Self:oMovEndDes:GetArmazem(),Self:oMovEndDes:GetEstFis(),/*cDesUni*/,.T.,Self:oMovEndDes:GetEnder())) // Considerar a qtd pelo nr de unitizadores
				If QtdComp(nCapEnder) <= 0
					(cAliasTP3)->(Self:AddMsgLog(TP3_ORDZON,TP3_ORDDC8,TP3_ORDDC3,TP3_ORDPRD,TP3_ORDSLD,TP3_ORDMOV,TP3_TIPEND,TP3_ESTFIS,TP3_ENDER,TP3_CAPTOT,TP3_CAPOCU,TP3_M3ENDE,TP3_M3OCUP,TP3_ALTURA,TP3_LARGUR,TP3_COMPRI,TP3_UNTTOT,TP3_UNTOCU,STR0026)) // Endereço com capacidade zerada.
					(cAliasEnd)->(DbSkip())
					Loop
				EndIf
				// Verifica se o endereço possui capacidade, para comportar o produto
				nSaldoEnd := Iif((cAliasTP3)->TP3_PEROCP==1,(cAliasTP3)->TP3_SLDPRD,((cAliasTP3)->TP3_SLDPRD + (cAliasTP3)->TP3_SLDOUT))
				nSaldoRF  := Iif((cAliasTP3)->TP3_PEROCP==1,(cAliasTP3)->TP3_MOVPRD,((cAliasTP3)->TP3_MOVPRD + (cAliasTP3)->TP3_MOVOUT))
				If QtdComp(nSaldoEnd + nSaldoRF) > QtdComp(nCapEnder)
					(cAliasTP3)->(Self:AddMsgLog(TP3_ORDZON,TP3_ORDDC8,TP3_ORDDC3,TP3_ORDPRD,TP3_ORDSLD,TP3_ORDMOV,TP3_TIPEND,TP3_ESTFIS,TP3_ENDER,TP3_CAPTOT,TP3_CAPOCU,TP3_M3ENDE,TP3_M3OCUP,TP3_ALTURA,TP3_LARGUR,TP3_COMPRI,TP3_UNTTOT,TP3_UNTOCU,STR0027)) // Saldo do endereço utiliza toda capacidade.
					(cAliasEnd)->(DbSkip())
					Loop
				EndIf
				// Verifica se o endereço possui capacidade para comportar a quantidade a ser unitizada
				If QtdComp(nSaldoEnd + nSaldoRF + (cAliasUni)->D14_QTDEST) > QtdComp(nCapEnder)
					(cAliasTP3)->(Self:AddMsgLog(TP3_ORDZON,TP3_ORDDC8,TP3_ORDDC3,TP3_ORDPRD,TP3_ORDSLD,TP3_ORDMOV,TP3_TIPEND,TP3_ESTFIS,TP3_ENDER,TP3_CAPTOT,TP3_CAPOCU,TP3_M3ENDE,TP3_M3OCUP,TP3_ALTURA,TP3_LARGUR,TP3_COMPRI,TP3_UNTTOT,TP3_UNTOCU,STR0028)) // Saldo Endereço+Unitizador ultrapassa capacidade.
					(cAliasEnd)->(DbSkip())
					Loop
				EndIf
			EndIf
			(cAliasTP3)->(Self:AddMsgLog(TP3_ORDZON,TP3_ORDDC8,TP3_ORDDC3,TP3_ORDPRD,TP3_ORDSLD,TP3_ORDMOV,TP3_TIPEND,TP3_ESTFIS,TP3_ENDER,TP3_CAPTOT,TP3_CAPOCU,TP3_M3ENDE,TP3_M3OCUP,TP3_ALTURA,TP3_LARGUR,TP3_COMPRI,TP3_UNTTOT,TP3_UNTOCU,STR0029)) // "Endereço utilizado"
			lEndUnitiz := .T.
			// Indicador que endereçou alguma coisa para a classificação
			If ValType(lEndClass) == "L"
				lEndClass := .T.
			EndIf
			// Indicando que encontrou um endereço de picking
			Self:lFoundPkg := ((cAliasTP3)->TP3_TPESTR == "2")
			// Deve verificar se o número de pickings ocupados não ultrapasou
			// Só deve considerar o que não tinha saldo, pois os que continham saldo já foram considerados
			If (cAliasTP3)->TP3_TPESTR == "2" .And. QtdComp((cAliasTP3)->TP3_SLDPRD+(cAliasTP3)->TP3_MOVPRD) <= QtdComp(0)
				Self:nQuantPkg++
			EndIf
			// Deve ajustar os dados do endereço para o próximo item
			RecLock(cAliasTP3,.F.)
			(cAliasTP3)->TP3_UNTOCU += 1
			(cAliasTP3)->TP3_CAPOCU += nPesoUnit
			(cAliasTP3)->TP3_M3OCUP += nVolUnit
			(cAliasTP3)->TP3_MOVPRD += (cAliasUni)->D14_QTDEST
			(cAliasTP3)->(MsUnlock())
			(cAliasTP3)->(DbCommit())
			Exit
		EndDo
		If !lEndUnitiz
			Self:oOrdServ:HasLogEnd(.T.)
			Self:AddMsgLog("00","00","00",0,0,0,"0","000000",STR0030,0,0,0,0,0,0,0,0,0,STR0031) // "Sem Endereço" ## "Sem endereços disponíveis para o unitizador"
			// Adiciona esta mensagem nos erros da execução da ordem de serviço
			AAdd(Self:oOrdServ:aWmsAviso, WmsFmtMsg(STR0032,{{"[VAR01]",Self:oOrdServ:GetDocto()+Iif(!Empty(Self:oOrdServ:GetSerie()),"/"+AllTrim(Self:oOrdServ:GetSerie()),'')},{"[VAR02]",(cAliasTP1)->TP1_IDUNIT}}) + CRLF + STR0031) // SIGAWMS - OS [VAR01] - Unitizador: [VAR02]
		Else
			RecLock(cAliasTP1,.F.)
			(cAliasTP1)->TP1_ENDDES := (cAliasTP3)->TP3_ENDER
			(cAliasTP3)->(MsUnlock())
			(cAliasTP1)->(DbCommit())
		EndIf

		// VarInfo("LOGEND",Self:aLogEnd[Len(Self:aLogEnd),nPosLog])

		(cAliasUni)->(DbSkip())
	EndDo
	(cAliasUni)->(DbCloseArea())
	(cAliasEnd)->(DbCloseArea())
Return lRet
//------------------------------------------------------------------------------
METHOD CalcOcupac() CLASS WMSBCCEnderecamentoUnitizado
Local aAreaAnt  := GetArea()
Local lRet      := .T.
Local cQuery    := ""
Local cAliasQry := ""
Local cAliasTP3 := Self:oTmpEndDes:GetAlias()
Local aTamSx3   := {}
Local lDesNotUni:= Self:lExeMovto .And. Self:DesNotUnit()

	// Realiza o cálculo do peso dos produtos que já estão no endereço destino
	cQuery :=          "% SUM ( ( SB1.B1_PESO + ("
	cQuery +=                  " CASE WHEN (SB1.B1_CONV > 0 AND SB1.B1_TIPCONV = 'D')"
	cQuery +=                       " THEN (SB5.B5_ECPESOE / SB1.B1_CONV)"
	cQuery +=                       " ELSE  SB5.B5_ECPESOE"
	cQuery +=                   " END ) ) * ( D14.D14_QTDEST + "+Iif(lDesNotUni,"(D14.D14_QTDEPR - D0S.D0S_QUANT)","D14.D14_QTDEPR")+" ) ) D14_PESUNI,"
	// Se o unitizador que está no endereço controla altura pelo unitizador, não calcula o volume dos itens
	cQuery +=           " SUM( CASE WHEN D0T.D0T_CTRALT = '2' THEN 0 ELSE "
	cQuery +=            " ( ( B5_COMPRLC * B5_LARGLC * B5_ALTURLC ) * ("
	cQuery +=                " CASE WHEN (SB1.B1_CONV > 0 AND SB1.B1_TIPCONV = 'D')"
	cQuery +=                      " THEN ( ( D14.D14_QTDEST + "+Iif(lDesNotUni,"(D14.D14_QTDEPR - D0S.D0S_QUANT)","D14.D14_QTDEPR")+" ) / SB1.B1_CONV)"
	cQuery +=                      " ELSE   ( D14.D14_QTDEST + "+Iif(lDesNotUni,"(D14.D14_QTDEPR - D0S.D0S_QUANT)","D14.D14_QTDEPR")+" )"
	cQuery +=                  "END ) ) END ) D14_VOLUNI"
	cQuery +=      " FROM "+RetSqlName("D14")+" D14"
	// Se estiver executando o movimento, não deve considerar o unitizador movimentado
	If lDesNotUni
		cQuery += " INNER JOIN "+RetSqlName('D0S')+" D0S"
		//Desconta quantidade do próprio untizador no cálculo, quando o endereço não possui controle do unitizador
		cQuery +=    " ON D0S_FILIAL = '"+xFilial('D0S')+"'"
		cQuery +=   " AND D0S_IDUNIT = '"+Self:cIdUnitiz+"'"
		cQuery +=   " AND D0S_PRDORI = D14_PRDORI"
		cQuery +=   " AND D0S_CODPRO = D14_PRODUT"
		cQuery +=   " AND D0S_LOTECT = D14_LOTECT"
		cQuery +=   " AND D0S_NUMLOT = D14_NUMLOT"
		cQuery +=   " AND D0S.D_E_L_E_T_ = ' '"
	EndIf
	cQuery +=     " INNER JOIN "+RetSqlName("SB1")+" SB1"
	cQuery +=        " ON SB1.B1_FILIAL = '"+xFilial("SB1")+"'"
	cQuery +=       " AND SB1.B1_COD = D14.D14_PRODUT"
	cQuery +=       " AND SB1.D_E_L_E_T_ = ' '"
	cQuery +=     " INNER JOIN "+RetSqlName("SB5")+" SB5"
	cQuery +=        " ON SB5.B5_FILIAL = '"+xFilial("SB5")+"'"
	cQuery +=       " AND SB5.B5_COD = SB1.B1_COD"
	cQuery +=       " AND SB5.D_E_L_E_T_ = ' '"
	cQuery +=      " LEFT JOIN "+RetSqlName("D0T")+" D0T"
	cQuery +=        " ON D0T.D0T_FILIAL = '"+xFilial("D0T")+"'"
	cQuery +=       " AND D0T.D0T_CODUNI = D14.D14_CODUNI"
	cQuery +=     " WHERE D14.D14_FILIAL = '"+xFilial("D14")+"'"
	cQuery +=       " AND D14.D14_LOCAL = '"+Self:oMovEndDes:GetArmazem()+"'"
	cQuery +=       " AND D14.D14_ENDER = '"+Self:oMovEndDes:GetEnder()+"'"
	If !lDesNotUni .And. Self:lExeMovto
		// Se estiver executando o movimento, não deve considerar o unitizador movimentado
		cQuery +=   " AND D14.D14_IDUNIT <> '"+Self:cIdUnitiz+"'"
	EndIf
	cQuery +=       " AND D14.D_E_L_E_T_ = ' '"
	cQuery += "%"
	cAliasQry:= GetNextAlias()
	BeginSql Alias cAliasQry
		SELECT %Exp:cQuery%
	EndSql
	aTamSx3 := TamSx3("B1_PESO"); TcSetField(cAliasQry,'D14_PESUNI','N',aTamSx3[1],aTamSx3[2])
	TcSetField(cAliasQry,'D14_VOLUNI','N',16,6)
	If (cAliasQry)->(!Eof())
		RecLock(cAliasTP3,.F.)
		(cAliasTP3)->TP3_CAPOCU := (cAliasQry)->D14_PESUNI
		(cAliasTP3)->TP3_M3OCUP := (cAliasQry)->D14_VOLUNI
		(cAliasTP3)->(MsUnlock())
		(cAliasTP3)->(DbCommit())
	EndIf
	(cAliasQry)->(DbCloseArea())
	
	If !Self:DesNotUnit()
		// Realiza o cálculo do peso dos unitizadores que já estão no endereço destino
		cQuery :=       "% SUM (D0T_TARA * NRU.D14_NRUNIT) D0T_PESUNI,"
		cQuery +=        " SUM ((D0T_ALTURA * D0T_LARGUR * D0T_COMPRI)* NRU.D14_NRUNIT) D0T_VOLUNI"
		cQuery +=   " FROM "+RetSqlName("D0T")+" D0T"
		cQuery +=  " INNER JOIN (SELECT COUNT(DISTINCT D14.D14_IDUNIT) D14_NRUNIT,"
		cQuery +=                     " D14.D14_CODUNI"
		cQuery +=                " FROM "+RetSqlName("D14")+" D14"
		cQuery +=               " WHERE D14.D14_FILIAL = '"+xFilial("D14")+"'"
		cQuery +=                 " AND D14.D14_LOCAL = '"+Self:oMovEndDes:GetArmazem()+"'"
		cQuery +=                 " AND D14.D14_ENDER = '"+Self:oMovEndDes:GetEnder()+"'"
		// Se estiver executando o movimento, não deve considerar o unitizador movimentado
		If Self:lExeMovto
			cQuery +=             " AND D14.D14_IDUNIT <> '"+Self:cIdUnitiz+"'"
		EndIf
		cQuery +=                 " AND D14.D_E_L_E_T_ = ' '"
		cQuery +=               " GROUP BY D14.D14_CODUNI) NRU"
		cQuery +=     " ON D0T.D0T_CODUNI = NRU.D14_CODUNI"
		cQuery +=  " WHERE D0T.D0T_FILIAL = '"+xFilial("D0T")+"'"
		cQuery +=    " AND D0T.D_E_L_E_T_ = ' '"
		cQuery += "%"
		cAliasQry:= GetNextAlias()
		BeginSql Alias cAliasQry
			SELECT %Exp:cQuery%
		EndSql
		aTamSx3 := TamSx3("D0T_TARA"); TcSetField(cAliasQry,'D0T_PESUNI','N',aTamSx3[1],aTamSx3[2])
		TcSetField(cAliasQry,'D0T_VOLUNI','N',16,6)
		If (cAliasQry)->(!Eof())
			RecLock(cAliasTP3,.F.)
			(cAliasTP3)->TP3_CAPOCU += (cAliasQry)->D0T_PESUNI
			(cAliasTP3)->TP3_M3OCUP += (cAliasQry)->D0T_VOLUNI
			(cAliasTP3)->(MsUnlock())
			(cAliasTP3)->(DbCommit())
		EndIf
		(cAliasQry)->(DbCloseArea())
	EndIf
	RestArea(aAreaAnt)
Return lRet
//------------------------------------------------------------------------------
METHOD ValLotUnit() CLASS WMSBCCEnderecamentoUnitizado
Local lRet      := .T.
Local aAreaAnt  := GetArea()
Local cAliasQry := GetNextAlias()
	BeginSql Alias cAliasQry
		SELECT DISTINCT D141.D14_ENDER
		FROM %Table:D14% D141
		WHERE D141.D14_FILIAL = %xFilial:D14%
		AND D141.D14_LOCAL = %Exp:Self:oMovEndDes:GetArmazem()%
		AND D141.D14_ENDER = %Exp:Self:oMovEndDes:GetEnder()%
		AND D141.%NotDel%
		AND NOT EXISTS (SELECT DISTINCT 1
						FROM %Table:D14% D142
						WHERE D142.D14_FILIAL = %xFilial:D14%
						AND D142.D14_IDUNIT = %Exp:Self:cIdUnitiz%
						AND D142.D14_PRODUT = D141.D14_PRODUT
						AND D142.D14_LOTECT = D141.D14_LOTECT
						AND D142.%NotDel% )
	EndSql
	If (cAliasQry)->(!Eof())
		lRet := .F.
	EndIf
	(cAliasQry)->(DbCloseArea())
	RestArea(aAreaAnt)
Return lRet

//------------------------------------------------------------------------------
METHOD VldProcPkg() CLASS WMSBCCEnderecamentoUnitizado
Local lRet      := .T.
Local aAreaAnt  := GetArea()
Local cAliasD14 := GetNextAlias()
	BeginSql Alias cAliasD14
		SELECT COUNT(DISTINCT D14.D14_ENDER) D14_QTDPKG
		FROM %Table:D14% D14
		WHERE D14.D14_FILIAL = %xFilial:D14%
		AND D14.D14_LOCAL = %Exp:Self:oMovPrdLot:GetArmazem()%
		AND D14.D14_PRODUT = %Exp:Self:oMovPrdLot:GetProduto()%
		AND D14.D14_ESTFIS = %Exp:Self:oMovEndDes:GetEstFis()%
		AND D14.%NotDel%
	EndSql
	If (cAliasD14)->(!Eof())
		Self:nQuantPkg := (cAliasD14)->D14_QTDPKG
		Self:lFoundPkg := ((cAliasD14)->D14_QTDPKG > 0)
	EndIf
	(cAliasD14)->(dbCloseArea())
	RestArea(aAreaAnt)
Return lRet

//------------------------------------------------------------------------------
METHOD GerMovClas(nItemClass) CLASS WMSBCCEnderecamentoUnitizado
Local lRet       := .T.
Local aAreaAnt   := GetArea()
Local cAliasUni  := GetNextAlias()
Local cTmpUnitiz := "%"+Self:oTmpUnitiz:GetRealName()+"%"
Local cEndOriAnt := ""
Local cEndDesVz  := Space(TamSX3("D14_ENDER")[1])
Local cIdUniMov  := "" // Salva o unitizador do movimento, pois quando é picking apaga
Local nPos       := 0

	Self:oMovPrdLot:ClearData() // Limpa o produto/lote para não gravar na movimentação
	// Busca todos os unitizadores que estão pendentes de endereçamento para aquela classificação
	cAliasUni := GetNextAlias()
	BeginSql Alias cAliasUni
		SELECT TP1.TP1_IDUNIT,
				TP1.TP1_CODUNI,
				TP1.TP1_DCFREC,
				TP1.TP1_LOCORI,
				TP1.TP1_ENDORI,
				TP1.TP1_LOCDES,
				TP1.TP1_ENDDES
		FROM %Exp:cTmpUnitiz% TP1
		WHERE TP1.TP1_CODCLA = %Exp:ConvNum(nItemClass)%
		AND TP1.TP1_ENDDES <>  %Exp:cEndDesVz%
		AND TP1.%NotDel%
		ORDER BY TP1.TP1_LOCORI,
					TP1.TP1_ENDORI,
					TP1.TP1_IDUNIT // Do menor para o maior unitizador
	EndSql
	Do While lRet .And. (cAliasUni)->(!Eof())
		If Self:lTrfUnit
			Self:cUniDes := (cAliasUni)->TP1_IDUNIT
			cIdUniMov := Self:cUniDes
		Else
			Self:cIdUnitiz := (cAliasUni)->TP1_IDUNIT
			cIdUniMov := Self:cIdUnitiz
		EndIf
		Self:cTipUni := (cAliasUni)->TP1_CODUNI

		//--Carrega dados endereço origem
		If !(cEndOriAnt == ((cAliasUni)->TP1_LOCORI+(cAliasUni)->TP1_ENDORI))
			Self:oMovEndOri:SetArmazem((cAliasUni)->TP1_LOCORI)
			Self:oMovEndOri:SetEnder((cAliasUni)->TP1_ENDORI)
			Self:oMovEndOri:LoadData()
			Self:oMovEndOri:ExceptEnd()
			cEndOriAnt := (cAliasUni)->TP1_LOCORI+(cAliasUni)->TP1_ENDORI
		EndIf

		Self:oMovEndDes:SetArmazem((cAliasUni)->TP1_LOCDES)
		Self:oMovEndDes:SetEnder((cAliasUni)->TP1_ENDDES)
		Self:oMovEndDes:LoadData()
		// Verifica se a Atividade utiliza Radio Frequencia
		// Carregas as exceções das atividades no destino
		Self:oMovEndDes:ExceptEnd()

		If (cAliasUni)->TP1_DCFREC != Self:oOrdServ:GetRecno()
			Self:oOrdServ:GoToDCF((cAliasUni)->TP1_DCFREC) // Recarrega a DCF original do unitizador
		EndIf
		Self:cStatus   := Iif(Self:oMovServic:GetBlqSrv() == '1','2','4')
		// Se for um serviço de transferencia que está endereçando, deve preencher o produto
		If Self:lTrfUnit
			Self:oMovPrdLot:SetArmazem(Self:oOrdServ:oProdLote:GetArmazem())
			Self:oMovPrdLot:SetPrdOri(Self:oOrdServ:oProdLote:GetPrdOri())
			Self:oMovPrdLot:SetProduto(Self:oOrdServ:oProdLote:GetProduto())
			Self:oMovPrdLot:SetLoteCtl(Self:oOrdServ:oProdLote:GetLoteCtl())
			Self:oMovPrdLot:SetNumLote(Self:oOrdServ:oProdLote:GetNumLote())
			Self:cIdUnitiz := Self:oOrdServ:GetIdUnit() // Pega o unitizador original da OS
			Self:nQtdMovto := Self:oOrdServ:GetQuant()
		Else
			// Quando endereçamento assume o unitizador destino como o mesmo da origem
			Self:cUniDes := Self:cIdUnitiz
			Self:nQtdMovto := 1
		EndIf
		// Gera a movimentação de estoque por endereco
		If lRet .And. !Self:MakeInput()
			lRet := .F.
		EndIf
		// Gera movimentos WMS
		If !Self:AssignD12()
			lRet := .F.
		EndIf
		If lRet .And. !Empty(Self:aIdUnitiz)
			// Marca que o unitizador foi gerado a movimentação para marcar a OS como executada
			If (nPos := AScan(Self:aIdUnitiz,{|x| x[1] == cIdUniMov})) > 0
				If Len(Self:aIdUnitiz[nPos]) < 3
					AAdd(Self:aIdUnitiz[nPos], .F.)
				EndIf
				Self:aIdUnitiz[nPos,3] := .T.
			EndIf
		EndIf
		(cAliasUni)->(dbSkip())
	EndDo
	(cAliasUni)->(dbCloseArea())
	RestArea(aAreaAnt)
Return lRet
//------------------------------------------------------------------------------
METHOD UnitCanEnd(lExeMovto) CLASS WMSBCCEnderecamentoUnitizado
Local lRet      := .T.
Local aAreaAnt  := GetArea()
Local cAliasTP1 := Nil
Local cAliasTP3 := Nil
Local cAliasD14 := Nil
Local cAliasDC3 := Nil
Local oProdZona := Nil

	If Empty(Self:cIdUnitiz) .Or. Empty(Self:oMovEndDes:GetArmazem()) .Or. Empty(Self:oMovEndDes:GetEnder())
		Self:cErro := STR0033 // "Não foram passadas as informações para a validação do endereçamento do unitizador."
		Return .F.
	EndIf
	If Self:oTmpUnitiz == Nil .Or. Self:oTmpEndDes == Nil
		Self:cErro := STR0001 // Não foram criadas as temporárias necessárias para o processamento.
		Return .F.
	EndIf
	// Apaga algum registro que possa existir na temporária
	If !Self:DelIdUnit()
		Return .F.
	EndIf
	If !Self:DelEndDes()
		Return .F.
	EndIf
	Self:SetExeMov(lExeMovto)
	// Valida se foi feito o LoadData do endereço destino
	If Empty(Self:oMovEndDes:GetEstFis())
		Self:oMovEndDes:LoadData()
	EndIf
	cAliasD14 := GetNextAlias()
	BeginSql Alias cAliasD14
		SELECT D14.D14_CODUNI,
				D14.D14_PRODUT,
				D14.D14_LOTECT,
				SB5.B5_CODZON
		FROM %Table:D14% D14
		INNER JOIN %Table:SB5% SB5
		ON SB5.B5_FILIAL = %xFilial:SB5%
		AND SB5.B5_COD = D14.D14_PRODUT
		AND SB5.%NotDel%
		WHERE D14.D14_FILIAL = %xFilial:D14%
		AND D14.D14_IDUNIT = %Exp:Self:cIdUnitiz%
		AND D14.D14_LOCAL = %Exp:Self:oMovEndOri:GetArmazem()%
		AND D14.D14_ENDER = %Exp:Self:oMovEndOri:GetEnder()%
		AND D14.D14_QTDEST > 0
		AND D14.%NotDel%
	EndSql
	If (cAliasD14)->(Eof())
		Self:cErro := STR0034 // "Não foi encontrado o saldo por endereço do unitizador."
		lRet := .F.
	Else
		cAliasDC3 := GetNextAlias()
		If WmsX312120("SBE","BE_NRUNIT")
			BeginSql Alias cAliasDC3
				SELECT DC3.DC3_ORDEM,
						DC8.DC8_TPESTR,
						DC3.DC3_TIPEND,
						CASE WHEN (SBE.BE_NRUNIT IS NULL OR SBE.BE_NRUNIT = 0) THEN 1 ELSE SBE.BE_NRUNIT END NRUNIT
				FROM %Table:DC3% DC3 
				INNER JOIN %Table:DC8% DC8
				ON DC8.DC8_FILIAL = %xFilial:DC8%
				AND DC8.DC8_CODEST = DC3.DC3_TPESTR
				AND DC8.%NotDel%
				INNER JOIN %Table:SBE% SBE
				ON SBE.BE_FILIAL = %xFilial:SBE%
				AND SBE.BE_LOCALIZ = %Exp:Self:oMovEndDes:GetEnder()%
				AND SBE.BE_ESTFIS = DC3.DC3_TPESTR
				AND SBE.BE_LOCAL = DC3.DC3_LOCAL
				AND SBE.%NotDel%
				WHERE DC3.DC3_FILIAL = %xFilial:DC3%
				AND DC3.DC3_LOCAL = %Exp:Self:oMovEndDes:GetArmazem()%
				AND DC3.DC3_CODPRO = %Exp:(cAliasD14)->D14_PRODUT%
				AND DC3.DC3_TPESTR = %Exp:Self:oMovEndDes:GetEstFis()%
				AND DC3.%NotDel%
			EndSql
		Else
			BeginSql Alias cAliasDC3
				SELECT DC3.DC3_ORDEM,
						DC8.DC8_TPESTR,
						DC3.DC3_TIPEND,
						CASE WHEN (DC3.DC3_NUNITI IS NULL OR DC3.DC3_NUNITI = 0) THEN 1 ELSE DC3.DC3_NUNITI END NRUNIT
				FROM %Table:DC3% DC3 
				INNER JOIN %Table:DC8% DC8
				ON DC8.DC8_FILIAL = %xFilial:DC8%
				AND DC8.DC8_CODEST = DC3.DC3_TPESTR
				AND DC8.%NotDel%
				INNER JOIN %Table:SBE% SBE
				ON SBE.BE_FILIAL = %xFilial:SBE%
				AND SBE.BE_LOCALIZ = %Exp:Self:oMovEndDes:GetEnder()%
				AND SBE.BE_ESTFIS = DC3.DC3_TPESTR
				AND SBE.BE_LOCAL = DC3.DC3_LOCAL
				AND SBE.%NotDel%
				WHERE DC3.DC3_FILIAL = %xFilial:DC3%
				AND DC3.DC3_LOCAL = %Exp:Self:oMovEndDes:GetArmazem()%
				AND DC3.DC3_CODPRO = %Exp:(cAliasD14)->D14_PRODUT%
				AND DC3.DC3_TPESTR = %Exp:Self:oMovEndDes:GetEstFis()%
				AND DC3.%NotDel%
			EndSql
		EndIf
		If (cAliasDC3)->(Eof())
			Self:cErro := WmsFmtMsg(STR0035,{{"[VAR01]",Self:oMovEndDes:GetArmazem()},{"[VAR02]",(cAliasD14)->D14_PRODUT},{"[VAR03]",Self:oMovEndDes:GetEstFis()}}) // "Não foi encontrado a sequência de abastecimento para o Armazém/Produto/Est.Fis [VAR01]/[VAR02]/[VAR03]."
			lRet := .F.
		Else
			cAliasTP1 := Self:oTmpUnitiz:GetAlias()
			RecLock(cAliasTP1,.T.)
			(cAliasTP1)->TP1_IDUNIT := Self:cIdUnitiz
			(cAliasTP1)->TP1_CODUNI := (cAliasD14)->D14_CODUNI
			(cAliasTP1)->TP1_LOCORI := Self:oMovEndOri:GetArmazem()
			(cAliasTP1)->TP1_ENDORI := Self:oMovEndOri:GetEnder()
			(cAliasTP1)->TP1_LOCDES := Self:oMovEndDes:GetArmazem()
			(cAliasTP1)->TP1_CODCLA := 1
			(cAliasTP1)->(MsUnlock())
	
			cAliasTP3 := Self:oTmpEndDes:GetAlias()
			RecLock(cAliasTP3,.T.)
			(cAliasTP3)->TP3_ORDZON := '00'
			(cAliasTP3)->TP3_ORDDC8 := '00'
			(cAliasTP3)->TP3_ORDDC3 := (cAliasDC3)->DC3_ORDEM
			(cAliasTP3)->TP3_ORDPRD := Iif(Self:oMovEndDes:GetProduto()==(cAliasD14)->D14_PRODUT,1,2)
			(cAliasTP3)->TP3_ORDSLD := 99
			(cAliasTP3)->TP3_ORDMOV := 99
			(cAliasTP3)->TP3_TPESTR := (cAliasDC3)->DC8_TPESTR
			(cAliasTP3)->TP3_TIPEND := (cAliasDC3)->DC3_TIPEND
			(cAliasTP3)->TP3_UNTTOT := (cAliasDC3)->NRUNIT
			(cAliasTP3)->TP3_LOCAL  := Self:oMovEndDes:GetArmazem()
			(cAliasTP3)->TP3_ENDER  := Self:oMovEndDes:GetEnder()
			(cAliasTP3)->TP3_ESTFIS := Self:oMovEndDes:GetEstFis()
			(cAliasTP3)->TP3_CAPTOT := Self:oMovEndDes:GetCapacid()
			(cAliasTP3)->TP3_ALTURA := Self:oMovEndDes:GetAltura()
			(cAliasTP3)->TP3_LARGUR := Self:oMovEndDes:GetLargura()
			(cAliasTP3)->TP3_COMPRI := Self:oMovEndDes:GetComprim()
			(cAliasTP3)->TP3_M3ENDE := Self:oMovEndDes:GetCubagem()
			(cAliasTP3)->TP3_DISTAN := 0
			(cAliasTP3)->TP3_CODPRO := Self:oMovEndDes:GetProduto()
			(cAliasTP3)->TP3_PRDAUX := (cAliasD14)->D14_PRODUT
			(cAliasTP3)->TP3_UTILIZ := '2'
			(cAliasTP3)->(MsUnlock())
		EndIf
		// Deve gravar pro primeiro produto apenas
		If lRet
			Self:cErro := ""
			Self:AddClasLog(1,Self:oMovEndDes:GetArmazem(),(cAliasD14)->D14_PRODUT,(cAliasD14)->D14_LOTECT,0)
		EndIf
		(cAliasDC3)->(dbCloseArea())
		// Deve validar a zona de armazenagem dos produtos
		// Verifica Zona Armazenagem Alternativa
		Do While lRet .And. (cAliasD14)->(!Eof())
			If (cAliasD14)->B5_CODZON <> Self:oMovEndDes:GetCodZona()
				If oProdZona == Nil
					oProdZona := WMSDTCProdutoZona():New()
				EndIf
				oProdZona:SetProduto((cAliasD14)->D14_PRODUT)
				oProdZona:SetCodZona(Self:oMovEndDes:GetCodZona())
				If !oProdZona:LoadData()
					Self:cErro := WmsFmtMsg(STR0039,{{"[VAR01]",(cAliasD14)->D14_PRODUT},{"[VAR02]",Self:oMovEndDes:GetCodZona()}}) // Produto [VAR01] não está cadastrado para a zona armazenagem [VAR02]. (SB5,DCH)
					lRet := .F.
				EndIf
			EndIf
			(cAliasD14)->(dbSkip())
		EndDo
	EndIf
	(cAliasD14)->(DbCloseArea())
	// Carrega os saldos por endereço para os endereços encontrados
	If lRet
		lRet := Self:OrdSldMov()
	EndIf

	If lRet
		lRet := Self:ProcUnClas(1)
		If lRet .And. !Empty(Self:cErro)
			If (cAliasTP3)->(TP3_TIPEND == '1' .And. QtdComp(TP3_SLDPRD+TP3_SLDOUT+TP3_MOVPRD+TP3_MOVOUT) > 0.0)
				Self:cErro := STR0036 // "Endereça somente endereços vazios e endereço já possui saldo armazenado."
			ElseIf (cAliasTP3)->(TP3_TIPEND $ '2|3' .And. QtdComp(TP3_SLDOUT+TP3_MOVOUT) > 0.0)
				Self:cErro := STR0037 // "Endereça sem misturar produtos e endereço já possui saldo armazenado de outro produto."
			EndIf
			lRet := .F.
		EndIf
	EndIf
	// Mesmo retornando TRUE deve verificar se preencheu o endereço
	If lRet .And. Empty((cAliasTP1)->TP1_ENDDES)
		If !Empty(Self:aLogEnd[Len(Self:aLogEnd),RELDETUNI])
			Self:cErro := Self:aLogEnd[Len(Self:aLogEnd),RELDETUNI,1,RELDETEND,1,19]
		EndIf
		lRet := .F.
	EndIf

	RestArea(aAreaAnt)
Return  lRet

//-----------------------------------------------------------------------------
METHOD LogSemEnd(nItemClass) CLASS WMSBCCEnderecamentoUnitizado
Local lUnitMisto := .F.
Local oMntUnitiz := WMSDTCMontagemUnitizador():New()
Local cAliasTP1  := Self:oTmpUnitiz:GetAlias()
Local nPesoUnit  := 0
Local nVolUnit   := 0

	Self:aLogEnd[Len(Self:aLogEnd),(RELDETUNI-1)] := 0
	(cAliasTP1)->(DbSetOrder(2))
	(cAliasTP1)->(DbSeek(nItemClass))
	Do While (cAliasTP1)->(!Eof()) .And. (cAliasTP1)->TP1_CODCLA == nItemClass

		oMntUnitiz:SetIdUnit((cAliasTP1)->TP1_IDUNIT)
		oMntUnitiz:SetTipUni((cAliasTP1)->TP1_CODUNI)
		oMntUnitiz:oTipUnit:LoadData()
		lUnitMisto := oMntUnitiz:IsMultPrd(/*cProduto*/,Iif(Self:lTrfUnit,Self:oTmpSldD14,Nil))

		// Calcula o peso e volume dos produtos do unitizador
		oMntUnitiz:SetArmazem((cAliasTP1)->TP1_LOCORI)
		oMntUnitiz:SetEnder((cAliasTP1)->TP1_ENDORI)
		oMntUnitiz:CalcOcupac(Iif(Self:lTrfUnit,Self:oTmpSldD14,Nil))
		nPesoUnit := oMntUnitiz:GetPeso() + oMntUnitiz:oTipUnit:GetTara()
		// Se controla a altura do unitizador por 1=ProdutoxCamada, deve somar o volume do unitizador
		If oMntUnitiz:oTipUnit:GetCtrAlt() == "1"
			nVolUnit := oMntUnitiz:GetVolume() + (oMntUnitiz:oTipUnit:GetLargura() * oMntUnitiz:oTipUnit:GetComprim() * oMntUnitiz:oTipUnit:GetAltura())
		Else
			// Caso seja pela altura do unitizador, sempre será considerado o volume do unitizador por completo
			nVolUnit := (oMntUnitiz:oTipUnit:GetLargura() * oMntUnitiz:oTipUnit:GetComprim() * oMntUnitiz:oTipUnit:GetAltura())
		EndIf
		// Calcula as dimensões do unitizador (Largura, Comprimento e Altura)
		oMntUnitiz:CalcDimens(Iif(Self:lTrfUnit,Self:oTmpSldD14,Nil))

		Self:AddUnitLog((cAliasTP1)->TP1_IDUNIT,(cAliasTP1)->TP1_CODUNI,nPesoUnit,nVolUnit,oMntUnitiz:GetAltura(),oMntUnitiz:GetLargura(),oMntUnitiz:GetComprim(),lUnitMisto)
		Self:AddMsgLog("00","00","00",0,0,0,"0","000000",STR0030,0,0,0,0,0,0,0,0,0,STR0031) // "Sem Endereço" ## "Sem endereços disponíveis para o unitizador"
		// Adiciona esta mensagem nos erros da execução da ordem de serviço
		AAdd(Self:oOrdServ:aWmsAviso, WmsFmtMsg("SIGAWMS - OS [VAR01] - Unitizador: [VAR02]",{{"[VAR01]",Self:oOrdServ:GetDocto()+Iif(!Empty(Self:oOrdServ:GetSerie()),"/"+AllTrim(Self:oOrdServ:GetSerie()),'')},{"[VAR02]",(cAliasTP1)->TP1_IDUNIT}}) + CRLF +"Sem endereços disponíveis para o unitizador") // SIGAWMS - OS [VAR01] - Produto: [VAR02]

		(cAliasTP1)->(DbSkip())
	EndDo
Return Nil

//------------------------------------------------------------------------------
METHOD DelSldD14() CLASS WMSBCCEnderecamentoUnitizado
//------------------------------------------------------------------------------
Local lRet    := .T.
Local cQuery  := ""

	cQuery := "DELETE FROM "+ Self:oTmpSldD14:GetRealName()
	If !(lRet := (TcSQLExec(cQuery) >= 0))
		Self:cErro := STR0005 // "Problema ao excluir os registros temporários do saldo do endereço."
	EndIf

Return lRet

//------------------------------------------------------------------------------
METHOD LoadSldD14(nRecnoDCF) CLASS WMSBCCEnderecamentoUnitizado
//------------------------------------------------------------------------------
Local lRet      := .T.
Local oOrdServ  := Nil
Local cAliasTmp := Self:oTmpSldD14:GetAlias()
Local cAliasQry := Nil

	If nRecnoDCF == Self:oOrdServ:GetRecno()
		oOrdServ := Self:oOrdServ
	Else
		oOrdServ := WMSDTCOrdemServico():New()
		If !oOrdServ:GoToDCF(nRecnoDCF)
			Self:lErro := oOrdServ:GetErro()
			lRet := .F.
		EndIf
	EndIf

	// Caso não esteja preenchido o tipo de untizador destino, busca do tipo da etiqueta
	If lRet .And. Empty(Self:cTipUni)
		cAliasQry := GetNextAlias()
		BeginSql Alias cAliasQry
			SELECT D0Y.D0Y_TIPUNI
			FROM %Table:D0Y% D0Y
			WHERE D0Y.D0Y_FILIAL = %xFilial:D0Y%
			AND D0Y.D0Y_IDUNIT = %Exp:Self:cIdUnitiz%
			AND D0Y.%NotDel%
		EndSql
		If (cAliasQry)->(!Eof())
			Self:cTipUni := (cAliasQry)->D0Y_TIPUNI
		EndIf
		(cAliasQry)->(dbCloseArea())
		If Empty(Self:cTipUni)
			Self:cErro := STR0045 // Não foi informado o tipo do unitizador destino.
			lRet := .F.
		EndIf
	EndIf
	If lRet
		RecLock(cAliasTmp,.T.)
		(cAliasTmp)->D14_FILIAL := xFilial("D14")
		(cAliasTmp)->D14_IDUNIT := Self:cIdUnitiz
		(cAliasTmp)->D14_CODUNI := Self:cTipUni
		(cAliasTmp)->D14_LOCAL  := oOrdServ:oOrdEndOri:GetArmazem()
		(cAliasTmp)->D14_ENDER  := oOrdServ:oOrdEndOri:GetEnder()
		(cAliasTmp)->D14_ESTFIS := oOrdServ:oOrdEndOri:GetEstFis()
		(cAliasTmp)->D14_PRDORI := oOrdServ:oProdLote:GetPrdOri()
		(cAliasTmp)->D14_PRODUT := oOrdServ:oProdLote:GetProduto()
		(cAliasTmp)->D14_LOTECT := oOrdServ:oProdLote:GetLoteCtl()
		(cAliasTmp)->D14_NUMLOT := oOrdServ:oProdLote:GetNumLote()
		(cAliasTmp)->D14_QTDEST := oOrdServ:GetQuant()
		(cAliasTmp)->D14_QTDEPR := 0
		(cAliasTmp)->(MsUnlock())
		(cAliasTmp)->(DbCommit()) // Para forçar atualizar no banco
	EndIf
Return lRet

/*/-----------------------------------------------------------------------------
Adiciona mensagens ao registro de LOG de busca de endereços.
Formato aLogEnd
	aLogEnd[nX,01] = Classificação
	aLogEnd[nX,02] = Local
	aLogEnd[nX,03] = Produto
	aLogEnd[nX,04] = Lote
	aLogEnd[nX,05] = Qtd Endereços Disponíveis
	aLogEnd[nX,06] = Array(9)
		aLogEnd[nX,06,nY,01] = Unitizador
		aLogEnd[nX,06,nY,02] = Tipo Unitizador
		aLogEnd[nX,06,nY,03] = Peso
		aLogEnd[nX,06,nY,04] = Cubagem
		aLogEnd[nX,06,nY,05] = Altura
		aLogEnd[nX,06,nY,06] = Largura
		aLogEnd[nX,06,nY,07] = Comprimento
		aLogEnd[nX,06,nY,08] = Unitizador Misto
		aLogEnd[nX,06,nY,09] = Array(19)
			aLogEnd[nX,06,nY,09,nZ,01] = Ordem Zona Armazenagem
			aLogEnd[nX,06,nY,09,nZ,02] = Ordem Sequencia Abastecimento
			aLogEnd[nX,06,nY,09,nZ,03] = Ordem Estrutura Sequencia Abastecimento
			aLogEnd[nX,06,nY,09,nZ,04] = Ordem Produto
			aLogEnd[nX,06,nY,09,nZ,05] = Ordem Saldo
			aLogEnd[nX,06,nY,09,nZ,06] = Ordem Movimento
			aLogEnd[nX,06,nY,09,nZ,07] = Tipo Endereçamento
			aLogEnd[nX,06,nY,09,nZ,08] = Estrutura Fisica
			aLogEnd[nX,06,nY,09,nZ,09] = Endereço
			aLogEnd[nX,06,nY,09,nZ,10] = Peso Máximo
			aLogEnd[nX,06,nY,09,nZ,11] = Peso Ocupado
			aLogEnd[nX,06,nY,09,nZ,12] = Cubagem Máxima
			aLogEnd[nX,06,nY,09,nZ,13] = Cubagem Ocupada
			aLogEnd[nX,06,nY,09,nZ,14] = Altura
			aLogEnd[nX,06,nY,09,nZ,15] = Largura
			aLogEnd[nX,06,nY,09,nZ,16] = Comprimento
			aLogEnd[nX,06,nY,09,nZ,17] = QTD Max Pal
			aLogEnd[nX,06,nY,09,nZ,18] = QTD Ocup Pal
			aLogEnd[nX,06,nY,09,nZ,19] = Mensagem
-----------------------------------------------------------------------------/*/
METHOD AddClasLog(nItemClass,cArmazem,cProduto,cLoteCtl,nQtdEndDis) CLASS WMSBCCEnderecamentoUnitizado
	AAdd(Self:aLogEnd,{nItemClass,cArmazem,cProduto,cLoteCtl,nQtdEndDis,{}})
Return Len(Self:aLogEnd)

METHOD AddUnitLog(cIdUnitiz,cTipUnit,nPeso,nVolume,nAltura,nLargura,nComprim,lIsMisto,nQtdEndDis) CLASS WMSBCCEnderecamentoUnitizado
Local aLogUnit := Nil
	aLogUnit := Self:aLogEnd[Len(Self:aLogEnd),RELDETUNI]
	AAdd(aLogUnit,{cIdUnitiz,cTipUnit,nPeso,nVolume,nAltura,nLargura,nComprim,lIsMisto,{}})
Return Len(aLogUnit)

METHOD AddMsgLog(cOrdZon,cOrdSeq,cOrdEst,cOrdPrd,cOrdSld,cOrdMov,cTipEnd,cEstrtura,cEndereco,nPesoMax,nPesoDisp,nVolMax,nVolDisp,nAltura,nLargura,nComprim,nQtdUnMax,nQtdUnDisp,cMensagem) CLASS WMSBCCEnderecamentoUnitizado
Local aLogMsg := Nil
	aLogMsg := Self:aLogEnd[Len(Self:aLogEnd),RELDETUNI]
	aLogMsg := aLogMsg[Len(aLogMsg),RELDETEND]
	AAdd(aLogMsg,{cOrdZon,cOrdSeq,cOrdEst,cOrdPrd,cOrdSld,cOrdMov,cTipEnd,cEstrtura,cEndereco,nPesoMax,nPesoDisp,nVolMax,nVolDisp,nAltura,nLargura,nComprim,nQtdUnMax,nQtdUnDisp,cMensagem})
Return Len(aLogMsg)
