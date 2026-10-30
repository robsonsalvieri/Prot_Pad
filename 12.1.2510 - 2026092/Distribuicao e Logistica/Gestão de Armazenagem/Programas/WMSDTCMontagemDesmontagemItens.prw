#Include "Totvs.ch"  
#Include "WMSDTCMontagemDesmontagemItens.ch"
//---------------------------------------------
/*/{Protheus.doc} WMSCLS0023
Função para permitir que a classe seja visualizada
no inspetor de objetos 
@author Inovação WMS
@since 16/12/2016
@version 1.0
/*/
//---------------------------------------------
Function WMSCLS0023()
Return Nil
//-----------------------------------------
/*/{Protheus.doc} WMSDTCMontagemDesmontagemItens
Classe estrutura física
@author Inovação WMS
@since 16/12/2016
@version 1.0
/*/
//-----------------------------------------
CLASS WMSDTCMontagemDesmontagemItens FROM LongNameClass
	// Data
	DATA lHasIdUnit
	DATA oMntDist
	DATA oProdLote
	DATA oMntEndOri
	DATA oMntEndDes
	DATA cTipoMov
	DATA cCtrl
	DATA cIdDCF
	DATA cIdUnitiz
	DATA nQuant
	DATA nRecno
	DATA cErro
	// Method
	METHOD New() CONSTRUCTOR
	METHOD GoToD0B(nRecno)
	METHOD LoadData(nIndex)
	METHOD UpdateD0B()
	METHOD SetDocto(cDocumento)
	METHOD SetTipoMov(cTipoMov)
	METHOD SetCtrl(cCtrl)
	METHOD SetIdDCF(cIdDCF)
	METHOD SetIdUnit(cIdUnitiz)
	METHOD SetQuant(nQuant)
	METHOD GetDocto()	
	METHOD GetTipoMov()	
	METHOD GetIdDCF()
	METHOD GetIdUnit()
	METHOD GetQuant()
	METHOD GetProdut()
	METHOD GetNumSeq()
	METHOD GetProces()
	METHOD GetOperac()
	METHOD GetRecno()
	METHOD GetErro() 
	METHOD Destroy()
ENDCLASS
//-----------------------------------------
/*/{Protheus.doc} New
Método construtor
@author alexsander.corra
@since 27/02/2015
@version 1.0
/*/
//-----------------------------------------
METHOD New() CLASS WMSDTCMontagemDesmontagemItens
	Self:lHasIdUnit := WmsX312118("D0B","D0B_IDUNIT")
	Self:oMntDist   := WMSDTCMontagemDesmontagem():New()
	Self:oProdLote  := WMSDTCProdutoLote():New()
	Self:oMntEndOri := WMSDTCEndereco():New()
	Self:oMntEndDes := WMSDTCEndereco():New()	
	Self:cIdDCF     := PadR("", TamSx3("D0B_IDDCF")[1])
	Self:cCtrl      := PadR("", TamSx3("D0B_CTRL")[1])
	Self:cIdUnitiz  := PadR("", Iif(Self:lHasIdUnit,TamSx3("D0B_IDUNIT")[1],6))
	Self:cTipoMov   := "1"
	Self:nQuant     := 0
	Self:nRecno     := 0
	Self:cErro      := ""
Return

METHOD Destroy() CLASS WMSDTCMontagemDesmontagemItens
	//Mantido para compatibilidade
Return Nil
//----------------------------------------
/*/{Protheus.doc} GoToDCF
Posicionamento para atualização das propriedades
@author felipe.m
@since 23/12/2014
@version 1.0
@param nRecno, numérico, (Descrição do parâmetro)
/*/
//----------------------------------------
METHOD GoToD0B(nRecno) CLASS WMSDTCMontagemDesmontagemItens
	Self:nRecno := nRecno
Return Self:LoadData(0)
//-----------------------------------------
/*/{Protheus.doc} LoadData
Carregamento dos dados D0B
@author alexsander.correa
@since 27/02/2015
@version 1.0
@param nIndex, numérico, (Descrição do parâmetro)
/*/
//-----------------------------------------
METHOD LoadData(nIndex) CLASS WMSDTCMontagemDesmontagemItens
Local lRet       := .T.
Local aAreaAnt   := GetArea()
Local aD0B_QUANT := TamSx3("D0B_QUANT")
Local aAreaD0B   := D0B->(GetArea())
Local cWhere     := ""
Local cCampos    := ""
Local cAliasD0B  := Nil
Default nIndex   := 1
	Do Case
		Case nIndex == 0 // R_E_C_N_O_
			If Empty(Self:nRecno)
				lRet := .F.
			EndIf
		Case nIndex == 1 // D0B_FILIAL+D0B_DOC+D0B_TIPMOV+D0B_LOCAL+D0B_PRODUT+D0B_LOTECT+D0B_NUMLOT+D0B_ENDORI+D0B_ENDDES
			If Empty(Self:GetDocto()) .OR. Empty(Self:oProdLote:GetArmazem()) .OR. Empty(Self:oProdLote:GetProduto()) .OR. Empty(Self:oMntEndOri:GetEnder())
				lRet := .F.
			EndIf
		Case nIndex == 2 // D0B_FILIAL+D0B_DOC+D0B_TIPMOV+D0B_CTRL
			If Empty(Self:GetDocto()) .Or. Empty(Self:cTipoMov) .Or. Empty(Self:cCtrl)
				lRet := .F.
			EndIf
		Otherwise
			lRet := .F.
	EndCase
	If !lRet
		Self:cErro := STR0002 // Dados para busca não foram informados!
	Else
		// Parâmetro Campos
		cCampos := "%"
		If Self:lHasIdUnit
			cCampos += " D0B.D0B_IDUNIT,"
		EndIf
		cCampos += "%"
		cAliasD0B:= GetNextAlias()
		Do Case
			Case nIndex == 0
				BeginSql Alias cAliasD0B
					SELECT D0B.D0B_DOC,
							D0B.D0B_LOCAL,
							D0B.D0B_PRODUT,
							D0B.D0B_LOTECT,
							D0B.D0B_NUMLOT,
							D0B.D0B_ENDORI,
							D0B.D0B_QUANT,
							D0B.D0B_TIPMOV,
							D0B.D0B_ENDDES,
							D0B.D0B_PRDORI,
							D0B.D0B_CTRL,
							D0B.D0B_IDDCF,
							%Exp:cCampos%
							D0B.R_E_C_N_O_ RECNOD0B
					FROM %Table:D0B% D0B
					WHERE D0B.D0B_FILIAL = %xFilial:D0B%
					AND D0B.R_E_C_N_O_ = %Exp:AllTrim(Str(Self:nRecno))%
					AND D0B.%NotDel%
				EndSql
			Case nIndex == 1
				// Parâmetros Where
				cWhere := "%"
				If !Empty(Self:cTipoMov)
					cWhere += " AND D0B.D0B_TIPMOV = '"+Self:cTipoMov+"'"
				EndIf
				If !Empty(Self:oProdLote:GetLoteCtl())
					cWhere += " AND D0B.D0B_LOTECT = '"+Self:oProdLote:GetLoteCtl()+"'"
				EndIf
				If !Empty(Self:oProdLote:GetNumLote())
					cWhere += " AND D0B.D0B_NUMLOT = '"+Self:oProdLote:GetNumLote()+"'"
				EndIf
				If !Empty(Self:oMntEndDes:GetEnder())
					cWhere += " AND D0B.D0B_ENDDES = '"+Self:oMntEndDes:GetEnder()+"'"
				EndIf
				cWhere += "%"
				BeginSql Alias cAliasD0B
					SELECT D0B.D0B_DOC,
							D0B.D0B_LOCAL,
							D0B.D0B_PRODUT,
							D0B.D0B_LOTECT,
							D0B.D0B_NUMLOT,
							D0B.D0B_ENDORI,
							D0B.D0B_QUANT,
							D0B.D0B_TIPMOV,
							D0B.D0B_ENDDES,
							D0B.D0B_PRDORI,
							D0B.D0B_CTRL,
							D0B.D0B_IDDCF,
							%Exp:cCampos%
							D0B.R_E_C_N_O_ RECNOD0B
					FROM %Table:D0B% D0B
					WHERE D0B.D0B_FILIAL = %xFilial:D0B%
					AND D0B.D0B_DOC = %Exp:Self:GetDocto()%
					AND D0B.D0B_LOCAL = %Exp:Self:oProdLote:GetArmazem()%
					AND D0B.D0B_PRODUT = %Exp:Self:oProdLote:GetProduto()%
					AND D0B.D0B_ENDORI = %Exp:Self:oMntEndOri:GetEnder()%
					AND D0B.%NotDel%
					%Exp:cWhere%
				EndSql			
			Case nIndex == 2
				BeginSql Alias cAliasD0B
					SELECT D0B.D0B_DOC,
							D0B.D0B_LOCAL,
							D0B.D0B_PRODUT,
							D0B.D0B_LOTECT,
							D0B.D0B_NUMLOT,
							D0B.D0B_ENDORI,
							D0B.D0B_QUANT,
							D0B.D0B_TIPMOV,
							D0B.D0B_ENDDES,
							D0B.D0B_PRDORI,
							D0B.D0B_CTRL,
							D0B.D0B_IDDCF,
							%Exp:cCampos%
							D0B.R_E_C_N_O_ RECNOD0B
					FROM %Table:D0B% D0B
					WHERE D0B.D0B_FILIAL = %xFilial:D0B%
					AND D0B.D0B_DOC = %Exp:Self:GetDocto()%
					AND D0B.D0B_TIPMOV = %Exp:Self:cTipoMov%
					AND D0B.D0B_CTRL = %Exp:Self:cCtrl%
					AND D0B.%NotDel%
				EndSql			
		EndCase
		TCSetField(cAliasD0B,'D0B_QUANT','N',aD0B_QUANT[1],aD0B_QUANT[2])
		If (lRet := (cAliasD0B)->(!Eof()))
			Self:SetDocto((cAliasD0B)->D0B_DOC)
			Self:SetTipoMov((cAliasD0B)->D0B_TIPMOV)
			Self:SetCtrl((cAliasD0B)->D0B_CTRL)
			// Montagem
			Self:oMntDist:LoadData()
			// Busca dados lote/produto			
			Self:oProdLote:SetArmazem((cAliasD0B)->D0B_LOCAL)
			Self:oProdLote:SetPrdOri((cAliasD0B)->D0B_PRDORI)
			Self:oProdLote:SetProduto((cAliasD0B)->D0B_PRODUT)
			Self:oProdLote:SetLoteCtl((cAliasD0B)->D0B_LOTECT)
			Self:oProdLote:SetNumLote((cAliasD0B)->D0B_NUMLOT)
			Self:oProdLote:SetNumSer("")
			Self:oProdLote:LoadData()
			// Busca dados endereco origem
			Self:oMntEndOri:SetArmazem((cAliasD0B)->D0B_LOCAL)
			Self:oMntEndOri:SetEnder((cAliasD0B)->D0B_ENDORI)
			Self:oMntEndOri:LoadData()
			// Busca dados endereco destino
			Self:oMntEndDes:SetArmazem((cAliasD0B)->D0B_LOCAL)
			Self:oMntEndDes:SetEnder((cAliasD0B)->D0B_ENDDES)
			Self:oMntEndDes:LoadData()
			// Dados complementares
			Self:nQuant   := (cAliasD0B)->D0B_QUANT
			Self:cIdDCF   := (cAliasD0B)->D0B_IDDCF
			If Self:lHasIdUnit
				Self:cIdUnitiz:= (cAliasD0B)->D0B_IDUNIT
			EndIf
			// Grava recno
			Self:nRecno := (cAliasD0B)->RECNOD0B
			// Controle dados anteriores
		EndIf
		(cAliasD0B)->(dbCloseArea())
	EndIf
	RestArea(aAreaD0B)
	RestArea(aAreaAnt)
Return lRet
//----------------------------------------
/*/{Protheus.doc} UpdateD0B
Atualização dos dados D0B
@author alexsander.correa
@since 04/03/2015
@version 1.0
/*/
//----------------------------------------
METHOD UpdateD0B() CLASS WMSDTCMontagemDesmontagemItens
Local lRet     := .T.
Local aAreaD0B := D0B->(GetArea())
	If D0B->(dbGoTo( Self:GetRecno() ))
		// Grava D0B
		RecLock('D0B', .F.)
		D0B->D0B_LOCAL  := Self:oProdLote:GetArmazem()
		D0B->D0B_PRDORI := Self:oProdLote:GetPrdOri() 
		D0B->D0B_PRODUT := Self:oProdLote:GetProduto()
		D0B->D0B_LOTECT := Self:oProdLote:GetLoteCtl()
		D0B->D0B_NUMLOT := Self:oProdLote:GetNumLote()
		D0B->D0B_ENDORI := Self:oMntEndOri:GetEnder()
		D0B->D0B_ENDDES := Self:oMntEndDes:GetEnder()
		D0B->D0B_QUANT  := Self:nQuant
		D0B->D0B_IDDCF  := Self:cIdDCF
		If Self:lHasIdUnit
			D0B->D0B_IDUNIT := Self:cIdUnitiz
		EndIf
		D0B->(MsUnLock())
	Else
		lRet := .F.
		Self:cErro := STR0003 // Dados não encontrados!
	EndIf
	RestArea(aAreaD0B)
Return lRet
//-----------------------------------
// Setters
//-----------------------------------
METHOD SetDocto(cDocumento) CLASS WMSDTCMontagemDesmontagemItens 
	Self:oMntDist:SetDocto(cDocumento)
Return
	
METHOD SetTipoMov(cTipoMov) CLASS WMSDTCMontagemDesmontagemItens
Return Self:cTipoMov := PadR(cTipoMov, Len(Self:cTipoMov))

METHOD SetIdDCF(cIdDCF) CLASS WMSDTCMontagemDesmontagemItens
	Self:cIdDCF := PadR(cIdDCF, Len(Self:cIdDCF))
Return

METHOD SetIdUnit(cIdUnitiz) CLASS WMSDTCMontagemDesmontagemItens
	Self:cIdUnitiz := PadR(cIdUnitiz, Iif(Self:lHasIdUnit, Len(Self:cIdUnitiz),6))
Return

METHOD SetQuant(nQuant) CLASS WMSDTCMontagemDesmontagemItens
	Self:nQuant := nQuant
Return

METHOD SetCtrl(cCtrl) CLASS WMSDTCMontagemDesmontagemItens
	Self:cCtrl := cCtrl
Return
//-----------------------------------
// Getters
//-----------------------------------
METHOD GetDocto() CLASS WMSDTCMontagemDesmontagemItens
Return Self:oMntDist:GetDocto()

METHOD GetTipoMov() CLASS WMSDTCMontagemDesmontagemItens
Return Self:cTipoMov

METHOD GetIdDCF() CLASS WMSDTCMontagemDesmontagemItens
Return Self:cIdDCF

METHOD GetIdUnit() CLASS WMSDTCMontagemDesmontagemItens
Return Self:cIdUnitiz

METHOD GetQuant() CLASS WMSDTCMontagemDesmontagemItens
Return Self:nQuant

METHOD GetProdut() CLASS WMSDTCMontagemDesmontagemItens
Return Self:oProdLote:GetProduto()

METHOD GetProces() CLASS WMSDTCMontagemDesmontagemItens
Return Self:oMntDist:GetProces()

METHOD GetOperac() CLASS WMSDTCMontagemDesmontagemItens
Return Self:oMntDist:GetOperac()

METHOD GetRecno() CLASS WMSDTCMontagemDesmontagemItens
Return Self:nRecno

METHOD GetErro() CLASS WMSDTCMontagemDesmontagemItens
Return Self:cErro
