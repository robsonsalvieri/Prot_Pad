#Include "Totvs.ch"
#Include "WMSDTCMovimentosEstoqueEndereco.ch"
//---------------------------------------------
/*/{Protheus.doc} WMSCLS0026
Função para permitir que a classe seja visualizada
no inspetor de objetos
@author Inovação WMS
@since 16/12/2016
@version 1.0
/*/
//---------------------------------------------
Function WMSCLS0026()
Return Nil
//------------------------------------------------
/*/{Protheus.doc} WMSDTCMovimentosEstoqueEndereco
Classe movimentos estoque endereço
@author Inovação WMS
@since 16/12/2016
@version 1.0
/*/
//------------------------------------------------
CLASS WMSDTCMovimentosEstoqueEndereco FROM LongNameClass
	DATA lHasUsaCal // Utilizado para suavizar o campo D13_USACAL
	DATA cDocumento
	DATA cSerieDoc
	DATA cSerie
	DATA cCliFor
	DATA cLoja
	DATA cOrigem
	DATA cNumSeq
	DATA cIdDCF
	DATA cUsaCalc
	DATA cIdMovto
	DATA cIdOpera
	DATA cIdUnitiz
	DATA cPrdOri
	DATA cProduto
	DATA cLoteCtl
	DATA cNumLote
	DATA cNumSer
	DATA cArmazem
	DATA cEndereco
	DATA cTipoMovto
	DATA nQtdEst
	DATA nQtdEs2
	DATA dDtEsto
	DATA cHrEsto
	DATA dUlMes
	DATA dDataFech
	DATA lFechto
	DATA nRecno
	DATA cErro
	DATA cIdDCFAnt
	DATA cIdMovAnt
	DATA cIdOperAnt
	// Method
	METHOD New() CONSTRUCTOR
	METHOD GoToD13(nRecno)
	METHOD LoadData(nIndex)
	METHOD AssignD12(oMovimento)
	// Dados da ordem de serviço
	METHOD SetDocto(cDocumento)
	METHOD SetSerie(cSerie)
	METHOD SetCliFor(cCliFor)
	METHOD SetLoja(cLoja)
	METHOD SetOrigem(cOrigem)
	METHOD SetNumSeq(cNumSeq)
	METHOD SetIdDCF(cIdDCF)
	// Dados do movimento
	METHOD SetIdMovto(cIdMovto)
	METHOD SetIdOpera(cIdOpera)
	METHOD SetIdUnit(cIdUnitiz)
	// Dados do produto
	METHOD SetPrdOri(cPrdOri)
	METHOD SetProduto(cProduto)
	METHOD SetLoteCtl(cLoteCtl)
	METHOD SetNumLote(cNumLote)
	METHOD SetNumSer(cNumSer)
	// Dados do endereço
	METHOD SetArmazem(cArmazem)
	METHOD SetEnder(cEnder)
	// Dados do movimento estoque endereço
	METHOD SetTipMov(cTipoMovto)
	METHOD SetQtdEst(nQtdEst)
	METHOD SetDtEsto(dDtEsto)
	METHOD SetHrEsto(cHrEsto)
	METHOD SetFechto(lFechto)
	METHOD SetUsaCalc(cUsaCalc)
	METHOD SetlUsaCal(lUsaCalc)
	// Dados da ordem de serviço
	METHOD GetDocto()
	METHOD GetSerie()
	METHOD GetCliFor()
	METHOD GetLoja()
	METHOD GetOrigem()
	METHOD GetNumSeq()
	METHOD GetIdDCF()
	// Dados do movimento
	METHOD GetIdMovto()
	METHOD GetIdOpera()
	METHOD GetIdUnit()
	// Dados do produto
	METHOD GetPrdOri()
	METHOD GetProduto()
	METHOD GetLoteCtl()
	METHOD GetNumLote()
	METHOD GetNumSer()
	// Dados do endereço
	METHOD GetArmazem()
	METHOD GetEnder()
	// Dados movimento estoque endereço
	METHOD GetQtdEst()
	METHOD GetQtdEs2()
	METHOD GetDtEsto()
	METHOD GetHrEsto()
	METHOD GetTipMov()
	METHOD GetUsaCalc()
	METHOD GetlUsaCal()

	METHOD GetRecno()
	METHOD GetErro()
	METHOD RecordD13()
	METHOD UpdateD13()
	// Saldo Inicial
	METHOD WmsFechto()
	METHOD SldPeriod()
	METHOD MontQryPer()
	METHOD MontQryD13()
	METHOD MtQryD13A()
	METHOD SetUlMes()
	METHOD SetDatFech()
	METHOD Destroy()
ENDCLASS
//------------------------------------------------
/*/{Protheus.doc} New
Método construtor
@author felipe.m
@since 23/12/2014
@version 1.0
/*/
//------------------------------------------------
METHOD New() CLASS WMSDTCMovimentosEstoqueEndereco
	Self:lHasUsaCal := WmsX312118("D13","D13_USACAL")
	// Dados da ordem de serviço
	Self:cDocumento := PadR("",GetWmsSX3("D13_DOC", 1))
	Self:cSerieDoc  := PadR("",GetWmsSX3("D13_SDOC", 1))
	Self:cSerie     := PadR("",GetWmsSX3("D13_SERIE", 1))
	Self:cCliFor    := PadR("",GetWmsSX3("D13_CLIFOR", 1))
	Self:cLoja      := PadR("",GetWmsSX3("D13_LOJA", 1))
	Self:cOrigem    := PadR("",GetWmsSX3("D13_ORIGEM", 1))
	Self:cNumSeq    := PadR("",GetWmsSX3("D13_NUMSEQ", 1))
	Self:cIdDCF     := PadR("",GetWmsSX3("D13_IDDCF", 1))
	Self:cIdDCFAnt  := PadR("",Len(Self:cIdDCF))
	// Dados do movimento
	Self:cIdMovto   := PadR("",GetWmsSX3("D13_IDMOV", 1))
	Self:cIdOpera   := PadR("",GetWmsSX3("D13_IDOPER", 1))
	Self:cIdUnitiz  := PadR("",GetWmsSX3("D13_IDUNIT", 1))
	Self:cIdMovAnt  := PadR("",Len(Self:cIdMovto))
	Self:cIdOperAnt := PadR("",Len(Self:cIdOpera))
	// Dados do produto
	Self:cPrdOri    := PadR("",GetWmsSX3("D13_PRDORI", 1))
	Self:cProduto   := PadR("",GetWmsSX3("D13_PRODUT", 1))
	Self:cLoteCtl   := PadR("",GetWmsSX3("D13_LOTECT", 1))
	Self:cNumLote   := PadR("",GetWmsSX3("D13_NUMLOT", 1))
	Self:cNumSer    := PadR("",GetWmsSX3("D13_NUMSER", 1))
	// Dados do endereço
	Self:cArmazem   := PadR("",GetWmsSX3("D13_LOCAL", 1))
	Self:cEndereco  := PadR("",GetWmsSX3("D13_ENDER", 1))
	// Dados do movimento estoque endereço
	Self:cTipoMovto := "999"
	Self:cUsaCalc   := "1"
	Self:nQtdEst    := 0
	Self:nQtdEs2    := 0
	If IsInCallStack("MATA241") 
		Self:dDtEsto    := SD3->D3_EMISSAO
	Else
		Self:dDtEsto    := dDataBase
	EndIf
	Self:cHrEsto    := Time()
	Self:nRecno     := 0
	// Saldo inicial
	Self:dUlMes     := SuperGetMv("MV_ULMES",.F.,"14990101")
	Self:dDataFech  := dDataBase
	Self:lFechto    := .T.
Return

METHOD Destroy() CLASS WMSDTCMovimentosEstoqueEndereco
	//Mantido para compatibilidade
Return
//--------------------------------------------------
/*/{Protheus.doc} GoToD13
Método utilizado para posicionamentos dos dados
@author felipe.m
@since 23/12/2014
@version 1.0
@param nRecno, numérico, (Descrição do parâmetro)
/*/
//--------------------------------------------------
METHOD GoToD13(nRecno) CLASS  WMSDTCMovimentosEstoqueEndereco
	Self:nRecno := nRecno
Return Self:LoadData(0)
//------------------------------------------------
/*/{Protheus.doc} LoadData
Carregamento dos dados D13
@author felipe.m
@since 23/12/2014
@version 1.0
@param nIndex, numérico, (Descrição do parâmetro)
/*/
//------------------------------------------------
METHOD LoadData(nIndex) CLASS WMSDTCMovimentosEstoqueEndereco
Local lRet       := .T.
Local lCarrega   := .T.
Local aAreaAnt   := GetArea()
Local aD13_QTDEST:= GetWmsSX3("D13_QTDEST")
Local aD13_QTDES2:= GetWmsSX3("D13_QTDES2")
Local aAreaD13   := D13->(GetArea())
Local cCampos    := ""
Local cAliasD13  := Nil

Default nIndex   := 3
	Do Case
		Case nIndex == 0
			If Empty(Self:nRecno)
				lRet := .F.
			EndIf
		Case nIndex == 3 // D13_FILIAL+D13_IDDCF+D13_IDMOV+D13_IDOPER
			If (Empty(Self:GetIdDCF()) .OR. Empty(Self:GetIdMovto()) .OR. Empty(Self:GetIdOpera()))
				lRet := .F.
			Else
				If Self:GetIdDCF() == Self:cIdDCFAnt .And. Self:GetIdMovto() == Self:cIdMovAnt .And. Self:GetIdOpera() == Self:cIdOperAnt
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
			cCampos := "%"
			cCampos += IIf(Self:lHasUsaCal," D13.D13_USACAL,","")
			cCampos += "%"
			cAliasD13  := GetNextAlias()
			Do Case
				Case nIndex == 0
					BeginSql Alias cAliasD13
						SELECT D13.D13_LOCAL,
								%Exp:cCampos%
								D13.D13_ENDER,
								D13.D13_PRODUT,
								D13.D13_LOTECT,
								D13.D13_NUMLOT,
								D13.D13_NUMSER,
								D13.D13_DOC,
								D13.D13_SERIE,
								D13.D13_CLIFOR,
								D13.D13_LOJA,
								D13.D13_TM,
								D13.D13_QTDEST,
								D13.D13_QTDES2,
								D13.D13_DTESTO,
								D13.D13_HRESTO,
								D13.D13_ORIGEM,
								D13.D13_IDDCF,
								D13.D13_IDMOV,
								D13.D13_NUMSEQ,
								D13.D13_SDOC,
								D13.D13_IDOPER,
								D13.D13_PRDORI,
								D13.D13_IDUNIT,
								D13.R_E_C_N_O_ RECNOD13
						FROM %Table:D13% D13
						WHERE D13.D13_FILIAL = %xFilial:D13%
						AND D13.R_E_C_N_O_ = %Exp:AllTrim(Str(Self:nRecno))%
						AND D13.%NotDel%
					EndSql
				Case nIndex == 3
					BeginSql Alias cAliasD13
						SELECT D13.D13_LOCAL,
								%Exp:cCampos%
								D13.D13_ENDER,
								D13.D13_PRODUT,
								D13.D13_LOTECT,
								D13.D13_NUMLOT,
								D13.D13_NUMSER,
								D13.D13_DOC,
								D13.D13_SERIE,
								D13.D13_CLIFOR,
								D13.D13_LOJA,
								D13.D13_TM,
								D13.D13_QTDEST,
								D13.D13_QTDES2,
								D13.D13_DTESTO,
								D13.D13_HRESTO,
								D13.D13_ORIGEM,
								D13.D13_IDDCF,
								D13.D13_IDMOV,
								D13.D13_NUMSEQ,
								D13.D13_SDOC,
								D13.D13_IDOPER,
								D13.D13_PRDORI,
								D13.D13_IDUNIT,
								D13.R_E_C_N_O_ RECNOD13
						FROM %Table:D13% D13
						WHERE D13.D13_FILIAL = %xFilial:D13%
						AND D13.D13_IDDCF = %Exp:Self:GetIdDCF()%
						AND D13.D13_IDMOV = %Exp:Self:GetIdMovto()%
						AND D13.D13_IDOPER = %Exp:Self:GetIdOpera()%
						AND D13.%NotDel%
					EndSql
			EndCase
			TCSetField(cAliasD13,'D13_QTDEST','N',aD13_QTDEST[1],aD13_QTDEST[2])
			TCSetField(cAliasD13,'D13_QTDES2','N',aD13_QTDES2[1],aD13_QTDES2[2])
			TCSetField(cAliasD13,'D13_DTESTO','D')
			If (lRet := (cAliasD13)->(!Eof()))
				// Dados da ordem de serviço
				Self:SetDocto((cAliasD13)->D13_DOC)
				Self:SetSerie((cAliasD13)->D13_SERIE)
				Self:SetCliFor((cAliasD13)->D13_CLIFOR)
				Self:SetLoja((cAliasD13)->D13_LOJA)
				Self:SetOrigem((cAliasD13)->D13_ORIGEM)
				Self:SetNumSeq((cAliasD13)->D13_NUMSEQ)
				Self:SetIdDCF((cAliasD13)->D13_IDDCF)
				// Dados do movimento
				Self:SetIdMovto((cAliasD13)->D13_IDMOV)
				Self:SetIdOpera((cAliasD13)->D13_IDOPER)
				Self:SetIdUnit((cAliasD13)->D13_IDUNIT)
				// Dados do produto
				Self:SetPrdOri((cAliasD13)->D13_PRDORI)
				Self:SetProduto((cAliasD13)->D13_PRODUT)
				Self:SetLoteCtl((cAliasD13)->D13_LOTECT)
				Self:SetNumLote((cAliasD13)->D13_NUMLOT)
				Self:SetNumSer((cAliasD13)->D13_NUMSER)
				// Dados endereco
				Self:SetArmazem((cAliasD13)->D13_LOCAL)
				Self:SetEnder((cAliasD13)->D13_ENDER)
				// Dados movimento estoque endereço
				Self:cTipoMovto := (cAliasD13)->D13_TM
				Self:nQtdEst    := (cAliasD13)->D13_QTDEST
				Self:nQtdEs2    := (cAliasD13)->D13_QTDES2
				Self:dDtEsto    := (cAliasD13)->D13_DTESTO
				Self:cHrEsto    := (cAliasD13)->D13_HRESTO
				If Self:lHasUsaCal
					Self:cUsaCalc := (cAliasD13)->D13_USACAL
				EndIf
				Self:nRecno     := (cAliasD13)->RECNOD13
				// Controle dados anteriores
				Self:cIdDCFAnt  := Self:GetIdDCF()
				Self:cIdMovAnt  := Self:GetIdMovto()
				Self:cIdOperAnt := Self:GetIdOpera()
			EndIf
			(cAliasD13)->(dbCloseArea())
		EndIf
	EndIf
	RestArea(aAreaD13)
	RestArea(aAreaAnt)
Return lRet
//------------------------------------------------
/*/{Protheus.doc} AssignD12
Seta o movimentos correspondente D12
@author felipe.m
@since 23/12/2014
@version 1.0
@param oMovimento, objeto, (Objeto movimento serviço armazem)
/*/
//------------------------------------------------
METHOD AssignD12(oMovimento) CLASS WMSDTCMovimentosEstoqueEndereco
	Self:cIdMovto   := oMovimento:GetIdMovto()
	Self:cIdOpera   := oMovimento:GetIdOpera()
	Self:cIdUnitiz  := oMovimento:GetIdUnit()
	// Dados da ordem de serviço
	Self:cDocumento := oMovimento:oOrdServ:GetDocto()
	Self:cSerie     := oMovimento:oOrdServ:GetSerie()
	Self:cCliFor    := oMovimento:oOrdServ:GetCliFor()
	Self:cLoja      := oMovimento:oOrdServ:GetLoja()
	Self:cOrigem    := oMovimento:oOrdServ:GetOrigem()
	Self:cNumSeq    := oMovimento:oOrdServ:GetNumSeq()
	Self:cIdDCF     := oMovimento:oOrdServ:GetIdDCF()
	// Dados do produto
	Self:cPrdOri    := oMovimento:oMovPrdLot:GetPrdOri()
	Self:cProduto   := oMovimento:oMovPrdLot:GetProduto()
	Self:cLoteCtl   := oMovimento:oMovPrdLot:GetLoteCtl()
	Self:cNumLote   := oMovimento:oMovPrdLot:GetNumLote()
	Self:cNumSer    := oMovimento:oMovPrdLot:GetNumSer()
Return
//-----------------------------------
// Setters
//-----------------------------------
// Dados da ordem de serviço
METHOD SetDocto(cDocumento) CLASS WMSDTCMovimentosEstoqueEndereco
	Self:cDocumento := PadR(cDocumento, Len(Self:cDocumento))
Return

METHOD SetSerie(cSerie) CLASS WMSDTCMovimentosEstoqueEndereco
	Self:cSerie := PadR(cSerie, Len(Self:cSerie))
Return

METHOD SetCliFor(cCliFor) CLASS WMSDTCMovimentosEstoqueEndereco
	Self:cCliFor := PadR(cCliFor, Len(Self:cCliFor))
Return

METHOD SetLoja(cLoja) CLASS WMSDTCMovimentosEstoqueEndereco
	Self:cLoja := PadR(cLoja, Len(Self:cLoja))
Return

METHOD SetOrigem(cOrigem) CLASS WMSDTCMovimentosEstoqueEndereco
	Self:cOrigem := PadR(cOrigem, Len(Self:cOrigem))
Return

METHOD SetNumSeq(cNumSeq) CLASS WMSDTCMovimentosEstoqueEndereco
	Self:cNumSeq := PadR(cNumSeq, Len(Self:cNumSeq))
Return

METHOD SetIdDCF(cIdDCF) CLASS WMSDTCMovimentosEstoqueEndereco
	Self:cIdDCF := PadR(cIdDCF, Len(Self:cIdDCF))
Return
//----------------------------------
// Dados do movimento
//----------------------------------
METHOD SetIdMovto(cIdMovto) CLASS WMSDTCMovimentosEstoqueEndereco
	Self:cIdMovto := PadR(cIdMovto, Len(Self:cIdMovto))
Return

METHOD SetIdOpera(cIdOpera) CLASS WMSDTCMovimentosEstoqueEndereco
	Self:cIdOpera := PadR(cIdOpera, Len(Self:cIdOpera))
Return

METHOD SetIdUnit(cIdUnitiz) CLASS WMSDTCMovimentosEstoqueEndereco
	Self:cIdUnitiz := PadR(cIdUnitiz, Len(Self:cIdUnitiz))
Return
//----------------------------------
// Dados do produto
//----------------------------------
METHOD SetPrdOri(cPrdOri) CLASS WMSDTCMovimentosEstoqueEndereco
	Self:cPrdOri := PadR(cPrdOri, Len(Self:cPrdOri))
Return

METHOD SetProduto(cProduto) CLASS WMSDTCMovimentosEstoqueEndereco
	Self:cProduto := PadR(cProduto, Len(Self:cProduto))
Return

METHOD SetLoteCtl(cLoteCtl) CLASS WMSDTCMovimentosEstoqueEndereco
	Self:cLoteCtl := PadR(cLoteCtl, Len(Self:cLoteCtl))
Return

METHOD SetNumLote(cNumLote) CLASS WMSDTCMovimentosEstoqueEndereco
	Self:cNumLote := PadR(cNumLote, Len(Self:cNumLote))
Return 

METHOD SetNumSer(cNumSer) CLASS WMSDTCMovimentosEstoqueEndereco
	Self:cNumSer := PadR(cNumSer, Len(Self:cNumSer))
Return
//----------------------------------
// Dados do endereço
//----------------------------------
METHOD SetArmazem(cArmazem) CLASS WMSDTCMovimentosEstoqueEndereco
	Self:cArmazem := PadR(cArmazem, Len(Self:cArmazem))
Return

METHOD SetEnder(cEndereco) CLASS WMSDTCMovimentosEstoqueEndereco
	Self:cEndereco := PadR(cEndereco, Len(Self:cEndereco))
Return
//----------------------------------
// Dados do movimento estoque endereço
//----------------------------------
METHOD SetTipMov(cTipoMovto) CLASS WMSDTCMovimentosEstoqueEndereco
	Self:cTipoMovto := cTipoMovto
Return

METHOD SetQtdEst(nQtdEst) CLASS WMSDTCMovimentosEstoqueEndereco
	Self:nQtdEst := nQtdEst
Return

METHOD SetDtEsto(dDtEsto) CLASS WMSDTCMovimentosEstoqueEndereco
	Self:dDtEsto := dDtEsto
Return

METHOD SetHrEsto(cHrEsto) CLASS WMSDTCMovimentosEstoqueEndereco
	Self:cHrEsto := cHrEsto
Return

METHOD SetUlMes(dUlMes) CLASS WMSDTCMovimentosEstoqueEndereco
	Self:dUlMes := dUlMes
Return

METHOD SetFechto(lFechto) CLASS WMSDTCMovimentosEstoqueEndereco
	Self:lFechto := lFechto
Return

METHOD SetDatFech(dDataFech) CLASS WMSDTCMovimentosEstoqueEndereco
	Self:dDataFech := dDataFech
Return

METHOD SetUsaCalc(cUsaCalc) CLASS WMSDTCMovimentosEstoqueEndereco
	If Self:lHasUsaCal
		Self:cUsaCalc := PadR(cUsaCalc, Len(Self:cUsaCalc))
	Else
		Self:cUsaCalc := cUsaCalc
	EndIf
Return

METHOD SetlUsaCal(lUsaCalc) CLASS WMSDTCMovimentosEstoqueEndereco
Default lUsaCalc := .T.
Return Self:cUsaCalc := IIf(lUsaCalc,"1","2")
//-----------------------------------
// Getters
//-----------------------------------
// Dados da ordem de serviço
METHOD GetDocto() CLASS WMSDTCMovimentosEstoqueEndereco
Return Self:cDocumento

METHOD GetSerie() CLASS WMSDTCMovimentosEstoqueEndereco
Return Self:cSerie

METHOD GetCliFor() CLASS WMSDTCMovimentosEstoqueEndereco
Return Self:cCliFor

METHOD GetLoja() CLASS WMSDTCMovimentosEstoqueEndereco
Return Self:cLoja

METHOD GetOrigem() CLASS WMSDTCMovimentosEstoqueEndereco
Return Self:cOrigem

METHOD GetNumSeq() CLASS WMSDTCMovimentosEstoqueEndereco
Return Self:cNumSeq

METHOD GetIdDCF() CLASS WMSDTCMovimentosEstoqueEndereco
Return Self:cIdDCF
// Dados do movimento
METHOD GetIdMovto() CLASS WMSDTCMovimentosEstoqueEndereco
Return Self:cIdMovto

METHOD GetIdOpera() CLASS WMSDTCMovimentosEstoqueEndereco
Return Self:cIdOpera

METHOD GetIdUnit() CLASS WMSDTCMovimentosEstoqueEndereco
Return Self:cIdUnitiz
// Dados do produto
METHOD GetPrdOri() CLASS WMSDTCMovimentosEstoqueEndereco
Return Self:cPrdOri

METHOD GetProduto() CLASS WMSDTCMovimentosEstoqueEndereco
Return Self:cProduto

METHOD GetLoteCtl() CLASS WMSDTCMovimentosEstoqueEndereco
Return Self:cLoteCtl

METHOD GetNumLote() CLASS WMSDTCMovimentosEstoqueEndereco
Return Self:cNumLote

METHOD GetNumSer() CLASS WMSDTCMovimentosEstoqueEndereco
Return Self:cNumSer
// Dados do endereço
METHOD GetArmazem() CLASS WMSDTCMovimentosEstoqueEndereco
Return Self:cArmazem

METHOD GetEnder() CLASS WMSDTCMovimentosEstoqueEndereco
Return Self:cEndereco
// Dados do movimento estoque endereço
METHOD GetQtdEst() CLASS WMSDTCMovimentosEstoqueEndereco
Return Self:nQtdEst

METHOD GetQtdEs2() CLASS WMSDTCMovimentosEstoqueEndereco
Return Self:nQtdEs2

METHOD GetDtEsto() CLASS WMSDTCMovimentosEstoqueEndereco
Return Self:dDtEsto

METHOD GetHrEsto() CLASS WMSDTCMovimentosEstoqueEndereco
Return Self:cHrEsto

METHOD GetTipMov() CLASS WMSDTCMovimentosEstoqueEndereco
Return Self:cTipoMovto

METHOD GetUsaCalc() CLASS WMSDTCMovimentosEstoqueEndereco
Return Self:cUsaCalc

METHOD GetlUsaCal() CLASS WMSDTCMovimentosEstoqueEndereco
Return Self:cUsaCalc == "1"

METHOD GetRecno() CLASS WMSDTCMovimentosEstoqueEndereco
Return Self:nRecno

METHOD GetErro() CLASS WMSDTCMovimentosEstoqueEndereco
Return Self:cErro
//------------------------------------------------
/*/{Protheus.doc} RecordD13
Gravação dos dados D13
@author felipe.m
@since 23/12/2014
@version 1.0
/*/
//------------------------------------------------
METHOD RecordD13() CLASS WMSDTCMovimentosEstoqueEndereco
Local lRet         := .T.
Local aAreaD13     := D13->(GetArea())
	// Grava dados
	Self:nQtdEs2 := ConvUm(Self:GetProduto(),Self:nQtdEst,0,2)

	RecLock("D13",.T.)
	D13->D13_FILIAL := xFilial("D13")
	D13->D13_DOC    := Self:GetDocto()
	D13->D13_SERIE  := Self:GetSerie()
	D13->D13_SDOC   := Self:GetSerie()
	D13->D13_CLIFOR := Self:GetCliFor()
	D13->D13_LOJA   := Self:GetLoja()
	D13->D13_ORIGEM := Self:GetOrigem()
	D13->D13_NUMSEQ := Self:GetNumSeq()
	D13->D13_IDDCF  := Self:GetIdDCF()
	D13->D13_IDMOV  := Self:GetIdMovto()
	D13->D13_IDOPER := Self:GetIdOpera()
	D13->D13_IDUNIT := Self:GetIdUnit()
	D13->D13_PRDORI := Self:GetPrdOri()
	D13->D13_PRODUT := Self:GetProduto()
	D13->D13_LOTECT := Self:GetLoteCtl()
	D13->D13_NUMLOT := Self:GetNumLote()
	D13->D13_NUMSER := Self:GetNumSer()
	D13->D13_LOCAL  := Self:GetArmazem()
	D13->D13_ENDER  := Self:GetEnder()
	D13->D13_TM     := Self:cTipoMovto
	D13->D13_QTDEST := Self:nQtdEst
	D13->D13_QTDES2 := Self:nQtdEs2
	D13->D13_DTESTO := Self:dDtEsto
	D13->D13_HRESTO := Self:cHrEsto
	If Self:lHasUsaCal
		D13->D13_USACAL := Self:cUsaCalc
	EndIf
	D13->(MsUnlock())
	RestArea(aAreaD13)
Return lRet
//------------------------------------------------
/*/{Protheus.doc} UpdateD13
Atualização dos dados D13
@author felipe.m
@since 23/12/2014
@version 1.0
/*/
//------------------------------------------------
METHOD UpdateD13() CLASS WMSDTCMovimentosEstoqueEndereco
Local aAreaD13     := D13->(GetArea())
Local lRet         := .T.
Local Self:nQtdEs2 := ConvUm(Self:GetProduto(),Self:nQtdEst,0,2)

	// Grava dados
	Self:nQtdEs2 := ConvUm(Self:GetProduto(),Self:nQtdEst,0,2)
	// Garante que a D12 está posicionada
	D13->(dbGoTo(Self:nRecno))

	RecLock("D13",.F.)
	D13->D13_FILIAL := xFilial("D13")
	D13->D13_DOC    := Self:GetDocto()
	D13->D13_SERIE  := Self:GetSerie()
	D13->D13_SDOC   := Self:GetSerie()
	D13->D13_CLIFOR := Self:GetCliFor()
	D13->D13_LOJA   := Self:GetLoja()
	D13->D13_ORIGEM := Self:GetOrigem()
	D13->D13_NUMSEQ := Self:GetNumSeq()
	D13->D13_IDDCF  := Self:GetIdDCF()
	D13->D13_IDMOV  := Self:GetIdMovto()
	D13->D13_IDOPER := Self:GetIdOpera()
	D13->D13_IDUNIT := Self:GetIdUnit()
	D13->D13_PRDORI := Self:GetPrdOri()
	D13->D13_PRODUT := Self:GetProduto()
	D13->D13_LOTECT := Self:GetLoteCtl()
	D13->D13_NUMLOT := Self:GetNumLote()
	D13->D13_NUMSER := Self:GetNumSer()
	D13->D13_LOCAL  := Self:GetArmazem()
	D13->D13_ENDER  := Self:GetEnder()
	D13->D13_TM     := Self:cTipoMovto
	D13->D13_QTDEST := Self:nQtdEst
	D13->D13_QTDES2 := Self:nQtdEs2
	D13->D13_DTESTO := Self:dDtEsto
	D13->D13_HRESTO := Self:cHrEsto
	If Self:lHasUsaCal
		D13->D13_USACAL := Self:cUsaCalc
	EndIf	
	D13->(MsUnlock())
	RestArea(aAreaD13)
Return lRet
//------------------------------------------------------------//
//--------Função que realiza o fechamento dos saldos----------//
//-------------chamada do programa MATA280--------------------//
//------------------------------------------------------------//
METHOD WmsFechto() CLASS WMSDTCMovimentosEstoqueEndereco
Local aAreaAnt := GetArea()
Local lRet := .T.
Local cAliasQry := ""
Local cQuery := Self:MontQryPer()

	Begin Transaction

		cAliasQry := GetNextAlias()
		BeginSql Alias cAliasQry
			SELECT %Exp:cQuery%
		EndSql

		D15->(dbSetOrder(1)) // D15_FILIAL+D15_LOCAL+D15_ENDER+D15_PRDORI+D15_PRODUT+D15_LOTECT+D15_NUMLOT+D15_NUMSER+D15_IDUNIT+DTOS(D15_DATA)

		Do While (cAliasQry)->(!Eof())

				If !D15->(dbSeek( xFilial("D15")+(cAliasQry)->(D15_LOCAL+D15_ENDER+D15_PRDORI+D15_PRODUT+D15_LOTECT+D15_NUMLOT+D15_NUMSER+D15_IDUNIT)+DTOS(Self:dDataFech)))
					RecLock("D15",.T.)
					D15->D15_FILIAL := xFilial("D15")
					D15->D15_LOCAL  := (cAliasQry)->D15_LOCAL   // Armazém
					D15->D15_ENDER  := (cAliasQry)->D15_ENDER   // Endereço
					D15->D15_PRDORI := (cAliasQry)->D15_PRDORI  // Produto Origem
					D15->D15_PRODUT := (cAliasQry)->D15_PRODUT  // Produto
					D15->D15_LOTECT := (cAliasQry)->D15_LOTECT  // Lote
					D15->D15_NUMLOT := (cAliasQry)->D15_NUMLOT  // Sub-Lote
					D15->D15_NUMSER := (cAliasQry)->D15_NUMSER  // Número de Série
					D15->D15_IDUNIT := (cAliasQry)->D15_IDUNIT  // Id Unitizador
					D15->D15_QINI   := (cAliasQry)->D15_QINI + (cAliasQry)->D13_SOMA1UM - (cAliasQry)->D13_SUBT1UM     // Saldo
					D15->D15_QISEGU := (cAliasQry)->D15_QISEGU + (cAliasQry)->D13_SOMA2UM - (cAliasQry)->D13_SUBT2UM // Saldo 2 UM 
					D15->D15_DATA   := Self:dDataFech // Data de Fechamento
					D15->D15_PRIOR  := ""             // Prioridade do Endereço
					D15->(MsUnlock())
				EndIf
	
			(cAliasQry)->(dbSkip())
		EndDo
	
		(cAliasQry)->(dbCloseArea())
	End Transaction
	
	RestArea(aAreaAnt)

Return lRet

METHOD SldPeriod() CLASS WMSDTCMovimentosEstoqueEndereco
Local cQuery := ""
Local cAliasQry := ""
Local aSldPeriod := {}
Local nPos := 0

	cQuery := Self:MontQryPer()

	cAliasQry := GetNextAlias()
	BeginSql Alias cAliasQry
		SELECT %Exp:cQuery%
	EndSql
	Do While (cAliasQry)->(!Eof())
		nPos := aScan(aSldPeriod,{ |x| x[1]+x[2]+x[3]+x[4]+x[5]+x[6]+x[7]+x[8] == (cAliasQry)->(D15_LOCAL+D15_ENDER+D15_PRDORI+D15_PRODUT+D15_LOTECT+D15_NUMLOT+D15_NUMSER+D15_IDUNIT) })
		If nPos == 0
			(cAliasQry)->( aAdd(aSldPeriod,{D15_LOCAL,D15_ENDER,D15_PRDORI,D15_PRODUT,D15_LOTECT,D15_NUMLOT,D15_NUMSER,D15_IDUNIT,D15_QINI+D13_SOMA1UM-D13_SUBT1UM,D15_QISEGU+D13_SOMA2UM-D13_SUBT2UM}) )
		EndIf
		(cAliasQry)->(dbSkip())
	EndDo
	(cAliasQry)->(dbCloseArea())
Return aSldPeriod

METHOD MontQryPer() CLASS WMSDTCMovimentosEstoqueEndereco
Local cQuery := ""

	// Saldo do fechamento anterior
	cQuery :=       "%  D15.D15_LOCAL,"
	cQuery +=         " D15.D15_ENDER,"
	cQuery +=         " D15.D15_PRDORI,"
	cQuery +=         " D15.D15_PRODUT,"
	cQuery +=         " D15.D15_LOTECT,"
	cQuery +=         " D15.D15_NUMLOT,"
	cQuery +=         " D15.D15_NUMSER,"
	cQuery +=         " D15.D15_IDUNIT,"
	cQuery +=         " D15.D15_QINI,"
	cQuery +=         " D15.D15_QISEGU"

	cQuery += Self:MontQryD13('D13_QTDEST', '499', 'D13_SOMA1UM')
	cQuery += Self:MontQryD13('D13_QTDES2', '499', 'D13_SOMA2UM')
	cQuery += Self:MontQryD13('D13_QTDEST', '999', 'D13_SUBT1UM')
	cQuery += Self:MontQryD13('D13_QTDES2', '999', 'D13_SUBT2UM')

	cQuery +=    " FROM "+RetSqlName("D15")+" D15"
	cQuery +=   " WHERE D15.D15_FILIAL = '"+xFilial("D15")+"'"
	cQuery +=  " AND D15.D15_DATA = (SELECT COALESCE(MAX(D151.D15_DATA),' ')"
	cQuery +=     " 	FROM "+RetSqlName("D15")+" D151"
	cQuery +=     " 	WHERE D151.D15_FILIAL = '"+xFilial("D15")+"'"
	cQuery +=     " 	AND D151.D15_DATA <= '"+DTOS(Self:dUlMes)+"'"
	cQuery +=     " 	AND D151.D_E_L_E_T_ = ' ' "
	cQuery +=     " 	AND D151.D15_ENDER = D15.D15_ENDER "
	cQuery +=     " 	AND D151.D15_PRDORI = D15.D15_PRDORI "
	cQuery +=     " 	AND D151.D15_PRODUT = D15.D15_PRODUT "
	cQuery +=     " 	AND D151.D15_LOTECT = D15.D15_LOTECT "
	cQuery +=     " 	AND D151.D15_NUMLOT = D15.D15_NUMLOT "
	cQuery +=     " 	AND D151.D15_NUMSER = D15.D15_NUMSER "
	cQuery +=     " 	AND D151.D15_IDUNIT = D15.D15_IDUNIT) "
	// Verifica se Armazem informado
	If !Empty(Self:GetArmazem())
		cQuery += " AND D15.D15_LOCAL = '"+Self:GetArmazem()+"'"
	EndIf
	// Verifica se produto origem informado
	If !Empty(Self:GetPrdOri())
		cQuery += " AND D15.D15_PRDORI = '"+Self:GetPrdOri()+"'"
	EndIf
	// Verifica se produto informado
	If !Empty(Self:GetProduto())
		cQuery += " AND D15.D15_PRODUT = '"+Self:GetProduto()+"'"
	EndIf
	// Verifica se lote informado
	If !Empty(Self:GetLoteCtl())
		cQuery += " AND D15.D15_LOTECT = '"+Self:GetLoteCtl()+"'"
	EndIf
	// Verifica se sub-lote informado
	If !Empty(Self:GetNumLote())
		cQuery += " AND D15.D15_NUMLOT = '"+Self:GetNumLote()+"'"
	EndIf
	// Verifica se numero de serie informado
	If !Empty(Self:GetNumSer())
		cQuery += " AND D15.D15_NUMSER = '"+Self:GetNumSer()+"'"
	EndIf
	// Verifica se unitizador informado
	If !Empty(Self:GetIdUnit())
		cQuery += " AND D15.D15_IDUNIT = '"+Self:GetIdUnit()+"'"
	EndIf
	// Verifica se endereço informado
	If !Empty(Self:GetEnder())
		cQuery += " AND D15.D15_ENDER = '"+Self:GetEnder()+"'"
	EndIf
	cQuery +=    " AND D15.D_E_L_E_T_ = ' '"
	cQuery += " UNION  "
	cQuery += " SELECT DISTINCT D13.D13_LOCAL "
	cQuery +=                " ,D13.D13_ENDER "
	cQuery +=                " ,D13.D13_PRDORI "
	cQuery +=                " ,D13.D13_PRODUT "
	cQuery += 	             " ,D13.D13_LOTECT "
	cQuery +=                " ,D13.D13_NUMLOT "
	cQuery +=                " ,D13.D13_NUMSER "
	cQuery +=                " ,D13.D13_IDUNIT "
	cQuery +=                " ,0 "
	cQuery +=                " ,0 "
	cQuery += Self:MtQryD13A('D13_QTDEST', '499', 'D13_SOMA1UM')
	cQuery += Self:MtQryD13A('D13_QTDES2', '499', 'D13_SOMA2UM')
	cQuery += Self:MtQryD13A('D13_QTDEST', '999', 'D13_SUBT1UM')
	cQuery += Self:MtQryD13A('D13_QTDES2', '999', 'D13_SUBT2UM')

	cQuery +=    " FROM "+RetSqlName("D13")+" D13"
	cQuery +=   " WHERE D13.D13_FILIAL = '"+xFilial("D13")+"'"
	If Self:lFechto
		cQuery += " AND D13.D13_DTESTO > (SELECT COALESCE(MAX(D151.D15_DATA),' ')"		
		cQuery += "		FROM " + RetSqlName("D15") + " D151 "
		cQuery += "		WHERE D151.D15_FILIAL =  '"+xFilial("D13")+"'"
		cQuery += "			AND D151.D15_DATA <= '"+DTOS(Self:dUlMes)+"'"
		cQuery += "			AND D151.D_E_L_E_T_ = ' ' "
		cQuery += "			AND D151.D15_ENDER = D13.D13_ENDER "
		cQuery += "			AND D151.D15_PRDORI = D13.D13_PRDORI "
		cQuery += "			AND D151.D15_PRODUT = D13.D13_PRODUT "
		cQuery += "			AND D151.D15_LOTECT = D13.D13_LOTECT "
		cQuery += "			AND D151.D15_NUMLOT = D13.D13_NUMLOT "
		cQuery += "			AND D151.D15_NUMSER = D13.D13_NUMSER "
		cQuery += "			AND D151.D15_IDUNIT = D13.D13_IDUNIT) "
		cQuery += " AND D13.D13_DTESTO <= '"+DTOS(Self:dDataFech)+"'"
	Else
		cQuery += " AND D13.D13_DTESTO = '"+DTOS(Self:dUlMes)+"'"
	EndIf
	// Verifica se Armazem informado
	If !Empty(Self:GetArmazem())
		cQuery += " AND D13.D13_LOCAL = '"+Self:GetArmazem()+"'"
	EndIf
	// Verifica se produto origem informado
	If !Empty(Self:GetPrdOri())
		cQuery += " AND D13.D13_PRDORI = '"+Self:GetPrdOri()+"'"
	EndIf
	// Verifica se produto informado
	If !Empty(Self:GetProduto())
		cQuery += " AND D13.D13_PRODUT = '"+Self:GetProduto()+"'"
	EndIf
	// Verifica se lote informado
	If !Empty(Self:GetLoteCtl())
		cQuery += " AND D13.D13_LOTECT = '"+Self:GetLoteCtl()+"'"
	EndIf
	// Verifica se sub-lote informado
	If !Empty(Self:GetNumLote())
		cQuery += " AND D13.D13_NUMLOT = '"+Self:GetNumLote()+"'"
	EndIf
	// Verifica se numero de serie informado
	If !Empty(Self:GetNumSer())
		cQuery += " AND D13.D13_NUMSER = '"+Self:GetNumSer()+"'"
	EndIf
	// Verifica se unitizador informado
	If !Empty(Self:GetIdUnit())
		cQuery += " AND D13.D13_IDUNIT = '"+Self:GetIdUnit()+"'"
	EndIf
	// Verifica se endereço informado
	If !Empty(Self:GetEnder())
		cQuery += " AND D13.D13_ENDER = '"+Self:GetEnder()+"'"
	EndIf
	cQuery +=    " AND D13.D_E_L_E_T_ = ' '"

	cQuery += " AND NOT EXISTS ( SELECT DISTINCT 1
	cQuery +=                  " FROM "+RetSqlName("D15")+" D15"
	cQuery +=                  " WHERE D15.D15_FILIAL = '"+xFilial("D15")+"'"
	cQuery +=                  " AND D15.D15_LOCAL	= D13.D13_LOCAL "
	cQuery +=                  " AND D15.D15_ENDER	= D13.D13_ENDER "
	cQuery +=	               " AND D15.D15_PRDORI = D13.D13_PRDORI "
	cQuery +=				   " AND D15.D15_PRODUT = D13.D13_PRODUT "
	cQuery +=				   " AND D15.D15_LOTECT = D13.D13_LOTECT "
	cQuery +=	   			   " AND D15.D15_NUMLOT = D13.D13_NUMLOT "
	cQuery +=				   " AND D15.D15_NUMSER =  D13.D13_NUMSER "
	cQuery +=				   " AND D15.D15_IDUNIT = D13.D13_IDUNIT  "
	cQuery +=				   " AND D15.D15_DATA = (SELECT COALESCE(MAX(D151.D15_DATA),' ')"		
	cQuery += 				   "		   	FROM "+RetSqlName("D15")+" D151"
	cQuery +=                  "			WHERE D151.D15_FILIAL = '"+xFilial("D15")+"'"
	cQuery +=                  "			AND D151.D15_DATA <= '"+DTOS(Self:dUlMes)+"'"
	cQuery +=                  "			AND D151.D_E_L_E_T_ = ' ' "
	cQuery +=                  "			AND D151.D15_ENDER = D13.D13_ENDER "
	cQuery +=                  "			AND D151.D15_PRDORI = D13.D13_PRDORI "
	cQuery +=                  "			AND D151.D15_PRODUT = D13.D13_PRODUT "
	cQuery +=                  "			AND D151.D15_LOTECT = D13.D13_LOTECT "
	cQuery +=                  "			AND D151.D15_NUMLOT = D13.D13_NUMLOT "
	cQuery +=                  "			AND D151.D15_NUMSER = D13.D13_NUMSER "
	cQuery +=                  "			AND D151.D15_IDUNIT = D13.D13_IDUNIT) "
	cQuery +=				   " AND D15.D_E_L_E_T_ = ' ') "
	cQuery +=  " ORDER BY 1,2,3,4,5,6,7,8 " 
	cQuery += "%"

Return cQuery

METHOD MontQryD13(cCampo, cTM, cCampoTot) CLASS WMSDTCMovimentosEstoqueEndereco
Local cQuery := ""

	cQuery := ", (SELECT SUM(" + cCampo + ") "
	cQuery += " FROM " + RetSqlName("D13") + " D13 "
	cQuery += " WHERE D13.D13_FILIAL = '"+xFilial("D13")+"'"
	If Self:lFechto
		cQuery += " AND D13.D13_DTESTO > (SELECT COALESCE(MAX(D151.D15_DATA),' ')"		
		cQuery += "		FROM " + RetSqlName("D15") + " D151 "
		cQuery += "		WHERE D151.D15_FILIAL =  '"+xFilial("D13")+"'"
		cQuery += "			AND D151.D15_DATA <= '"+DTOS(Self:dUlMes)+"'"
		cQuery += "			AND D151.D_E_L_E_T_ = ' ' "
		cQuery += "			AND D151.D15_ENDER = D13.D13_ENDER "
		cQuery += "			AND D151.D15_PRDORI = D13.D13_PRDORI "
		cQuery += "			AND D151.D15_PRODUT = D13.D13_PRODUT "
		cQuery += "			AND D151.D15_LOTECT = D13.D13_LOTECT "
		cQuery += "			AND D151.D15_NUMLOT = D13.D13_NUMLOT "
		cQuery += "			AND D151.D15_NUMSER = D13.D13_NUMSER "
		cQuery += "			AND D151.D15_IDUNIT = D13.D13_IDUNIT) "
		cQuery += " AND D13.D13_DTESTO <= '"+DTOS(Self:dDataFech)+"'"
	Else
		cQuery += " AND D13.D13_DTESTO = '"+DTOS(Self:dUlMes)+"'"
	EndIf
	// Verifica se Armazem informado
	If !Empty(Self:GetArmazem())
		cQuery += " AND D13.D13_LOCAL = '"+Self:GetArmazem()+"'"
	EndIf
	// Verifica se produto origem informado
	If !Empty(Self:GetPrdOri())
		cQuery += " AND D13.D13_PRDORI = '"+Self:GetPrdOri()+"'"
	EndIf
	// Verifica se produto informado
	If !Empty(Self:GetProduto())
		cQuery += " AND D13.D13_PRODUT = '"+Self:GetProduto()+"'"
	EndIf
	// Verifica se lote informado
	If !Empty(Self:GetLoteCtl())
		cQuery += " AND D13.D13_LOTECT = '"+Self:GetLoteCtl()+"'"
	EndIf
	// Verifica se sub-lote informado
	If !Empty(Self:GetNumLote())
		cQuery += " AND D13.D13_NUMLOT = '"+Self:GetNumLote()+"'"
	EndIf
	// Verifica se numero de serie informado
	If !Empty(Self:GetNumSer())
		cQuery += " AND D13.D13_NUMSER = '"+Self:GetNumSer()+"'"
	EndIf
	// Verifica se unitizador informado
	If !Empty(Self:GetIdUnit())
		cQuery += " AND D13.D13_IDUNIT = '"+Self:GetIdUnit()+"'"
	EndIf
	// Verifica se endereço informado
	If !Empty(Self:GetEnder())
		cQuery += " AND D13.D13_ENDER = '"+Self:GetEnder()+"'"
	EndIf
	cQuery +=    " AND D13.D13_TM = '" + AllTrim(cTM) + "'"
	If Self:lHasUsaCal
		cQuery += " AND D13.D13_USACAL <> '2'"
	EndIf
	cQuery += " AND D13.D_E_L_E_T_ = ' '"
	cQuery += " AND D13.D13_LOCAL = D15.D15_LOCAL" 
	cQuery += " AND D13.D13_ENDER = D15.D15_ENDER" 
	cQuery += " AND D13.D13_PRDORI = D15.D15_PRDORI" 
	cQuery += " AND D13.D13_PRODUT = D15.D15_PRODUT" 
	cQuery += " AND D13.D13_LOTECT = D15.D15_LOTECT" 
	cQuery += " AND D13.D13_NUMLOT = D15.D15_NUMLOT"
	cQuery += " AND D13.D13_NUMSER = D15.D15_NUMSER" 
	cQuery += " AND D13.D13_IDUNIT = D15.D15_IDUNIT) " + cCampoTot

Return cQuery

METHOD MtQryD13A(cCampo, cTM, cCampoTot) CLASS WMSDTCMovimentosEstoqueEndereco
Local cQuery := ""

	cQuery := ", (SELECT SUM(" + cCampo + ") "
	cQuery += " FROM " + RetSqlName("D13") + " D13A "
	cQuery += " WHERE D13A.D13_FILIAL = '"+xFilial("D13")+"'"
	If Self:lFechto
		cQuery += " AND D13A.D13_DTESTO > (SELECT COALESCE(MAX(D151.D15_DATA),' ')"
		cQuery +=     " 	FROM "+RetSqlName("D15")+" D151"
		cQuery +=     " 	WHERE D151.D15_FILIAL = '"+xFilial("D15")+"'"
		cQuery +=     " 	AND D151.D15_DATA <= '"+DTOS(Self:dUlMes)+"'"
		cQuery +=     " 	AND D151.D_E_L_E_T_ = ' ' "
		cQuery +=     " 	AND D151.D15_ENDER = D13A.D13_ENDER "
		cQuery +=     " 	AND D151.D15_PRDORI = D13A.D13_PRDORI "
		cQuery +=     " 	AND D151.D15_PRODUT = D13A.D13_PRODUT "
		cQuery +=     " 	AND D151.D15_LOTECT = D13A.D13_LOTECT "
		cQuery +=     " 	AND D151.D15_NUMLOT = D13A.D13_NUMLOT "
		cQuery +=     " 	AND D151.D15_NUMSER = D13A.D13_NUMSER "
		cQuery +=     " 	AND D151.D15_IDUNIT = D13A.D13_IDUNIT) "
		cQuery += " AND D13A.D13_DTESTO <= '"+DTOS(Self:dDataFech)+"'"
	Else
		cQuery += " AND D13A.D13_DTESTO = '"+DTOS(Self:dUlMes)+"'"
	EndIf
	// Verifica se Armazem informado
	If !Empty(Self:GetArmazem())
		cQuery += " AND D13A.D13_LOCAL = '"+Self:GetArmazem()+"'"
	EndIf
	// Verifica se produto origem informado
	If !Empty(Self:GetPrdOri())
		cQuery += " AND D13A.D13_PRDORI = '"+Self:GetPrdOri()+"'"
	EndIf
	// Verifica se produto informado
	If !Empty(Self:GetProduto())
		cQuery += " AND D13A.D13_PRODUT = '"+Self:GetProduto()+"'"
	EndIf
	// Verifica se lote informado
	If !Empty(Self:GetLoteCtl())
		cQuery += " AND D13A.D13_LOTECT = '"+Self:GetLoteCtl()+"'"
	EndIf
	// Verifica se sub-lote informado
	If !Empty(Self:GetNumLote())
		cQuery += " AND D13A.D13_NUMLOT = '"+Self:GetNumLote()+"'"
	EndIf
	// Verifica se numero de serie informado
	If !Empty(Self:GetNumSer())
		cQuery += " AND D13A.D13_NUMSER = '"+Self:GetNumSer()+"'"
	EndIf
	// Verifica se unitizador informado
	If !Empty(Self:GetIdUnit())
		cQuery += " AND D13A.D13_IDUNIT = '"+Self:GetIdUnit()+"'"
	EndIf
	// Verifica se endereço informado
	If !Empty(Self:GetEnder())
		cQuery += " AND D13A.D13_ENDER = '"+Self:GetEnder()+"'"
	EndIf
	cQuery +=    " AND D13A.D13_TM = '" + AllTrim(cTM) + "'"
	If Self:lHasUsaCal
		cQuery += " AND D13A.D13_USACAL <> '2'"
	EndIf
	cQuery += " AND D13A.D_E_L_E_T_ = ' '"
	cQuery += " AND D13A.D13_LOCAL = D13.D13_LOCAL" 
	cQuery += " AND D13A.D13_ENDER = D13.D13_ENDER" 
	cQuery += " AND D13A.D13_PRDORI = D13.D13_PRDORI" 
	cQuery += " AND D13A.D13_PRODUT = D13.D13_PRODUT" 
	cQuery += " AND D13A.D13_LOTECT = D13.D13_LOTECT" 
	cQuery += " AND D13A.D13_NUMLOT = D13.D13_NUMLOT"
	cQuery += " AND D13A.D13_NUMSER = D13.D13_NUMSER" 
	cQuery += " AND D13A.D13_IDUNIT = D13.D13_IDUNIT) " + cCampoTot
Return cQuery
