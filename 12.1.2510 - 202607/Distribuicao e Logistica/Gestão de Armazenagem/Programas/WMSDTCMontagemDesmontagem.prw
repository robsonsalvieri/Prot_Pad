#Include "Totvs.ch"  
#Include "WMSDTCMontagemDesmontagem.ch"
//---------------------------------------------
/*/{Protheus.doc} WMSCLS0022
Função para permitir que a classe seja visualizada
no inspetor de objetos 
@author Inovação WMS
@since 16/12/2016
@version 1.0
/*/
//---------------------------------------------
Function WMSCLS0022()
Return Nil
//-----------------------------------------
/*/{Protheus.doc} WMSDTCMontagemDesmontagem
Classe estrutura física
@author Inovação WMS
@since 16/12/2016
@version 1.0
/*/
//-----------------------------------------
CLASS WMSDTCMontagemDesmontagem FROM LongNameClass
	// Data
	DATA oProdLote
	DATA oMntEndTra
	DATA cDocumento
	DATA cOperacao
	DATA cProcesso
	DATA nQtdMov
	DATA nRecno
	DATA cErro
	// Controle dados anteriores
	DATA cDoctoAnt 
	// Method
	METHOD New() CONSTRUCTOR
	METHOD LoadData(nIndex)
	METHOD SetDocto(cDocumento)
	METHOD SetQtdMov(nQtdMov)
	METHOD GetDocto()
	METHOD GetOperac()
	METHOD GetProces() 
	METHOD GetQtdMov()
	METHOD GetArmazem()
	METHOD GetEndTran()
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
METHOD New() CLASS WMSDTCMontagemDesmontagem	
	Self:oProdLote  := WMSDTCProdutoLote():New()
	Self:oMntEndTra := WMSDTCEndereco():New()
	Self:cDocumento := PadR("", TamSx3("D0A_DOC")[1])
	Self:cDoctoAnt  := PadR("", Len(Self:cDocumento))
	Self:cOperacao  := "1"
	Self:cProcesso  := "1"
	Self:nQtdMov    := 0
	Self:cErro      := ""
	Self:nRecno     := 0
Return

METHOD Destroy() CLASS WMSDTCMontagemDesmontagem
	//Mantido para compatibilidade
Return 
//-----------------------------------------
/*/{Protheus.doc} LoadData
Carregamento dos dados D0A
@author alexsander.correa
@since 27/02/2015
@version 1.0
@param nIndex, numérico, (Descrição do parâmetro)
/*/
//-----------------------------------------
METHOD LoadData(nIndex) CLASS WMSDTCMontagemDesmontagem
Local lRet        := .T.
Local lCarrega    := .T.
Local aAreaAnt    := GetArea()
Local aD0A_QTDMOV := TamSx3("D0A_QTDMOV")
Local aAreaD0A    := D0A->(GetArea())
Local cAliasD0A   := Nil
Default nIndex    := 1
	Do Case
		Case nIndex == 1 // D0A_FILIAL+D0A_DOC
			If Empty(Self:cDocumento)
				lRet := .F.
			Else
				If Self:cDocumento == Self:cDoctoAnt
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
			cAliasD0A   := GetNextAlias()
			Do Case
				Case nIndex == 1
					BeginSql Alias cAliasD0A
						SELECT D0A.D0A_DOC,
								D0A.D0A_OPERAC,
								D0A.D0A_PRODUT,
								D0A.D0A_LOCAL,
								D0A.D0A_LOTECT,
								D0A.D0A_NUMLOT,
								D0A.D0A_QTDMOV,
								D0A.D0A_ENDER,
								D0A.D0A_PROCES,
								D0A.D0A_DTMOV,
								D0A.R_E_C_N_O_ RECNOD0A
						FROM %Table:D0A% D0A
						WHERE D0A.D0A_FILIAl = %xFilial:D0A%
						AND D0A.D0A_DOC = %Exp:Self:cDocumento%
						AND D0A.%NotDel%
					EndSql
			EndCase
			TCSetField(cAliasD0A,'D0A_QTDMOV','N',aD0A_QTDMOV[1],aD0A_QTDMOV[2])
			TCSetField(cAliasD0A,'D0A_DTMOV','D')
			If (lRet := (cAliasD0A)->(!Eof()))
				Self:SetDocto((cAliasD0A)->D0A_DOC)
				// Busca dados lote/produto
				Self:oProdLote:SetArmazem((cAliasD0A)->D0A_LOCAL)
				Self:oProdLote:SetPrdOri((cAliasD0A)->D0A_PRODUT)
				Self:oProdLote:SetProduto((cAliasD0A)->D0A_PRODUT)
				Self:oProdLote:SetLoteCtl((cAliasD0A)->D0A_LOTECT)
				Self:oProdLote:SetNumLote((cAliasD0A)->D0A_NUMLOT)
				Self:oProdLote:SetNumSer("")
				Self:oProdLote:LoadData()
				// Busca dados endereco origem
				Self:oMntEndTra:SetArmazem((cAliasD0A)->D0A_LOCAL)
				Self:oMntEndTra:SetEnder((cAliasD0A)->D0A_ENDER)
				Self:oMntEndTra:LoadData()
				// Dados complementares
				Self:cOperacao := (cAliasD0A)->D0A_OPERAC
				Self:cProcesso := (cAliasD0A)->D0A_PROCES
				Self:nQtdMov   := (cAliasD0A)->D0A_QTDMOV
				// Grava recno
				Self:nRecno    := (cAliasD0A)->RECNOD0A
				// Controle dados anteriores
				Self:cDoctoAnt := Self:cDocumento 
			EndIf
			(cAliasD0A)->(dbCloseArea())
		EndIf
	EndIf
	RestArea(aAreaD0A)
	RestArea(aAreaAnt)
Return lRet
//-----------------------------------
// Setters
//-----------------------------------
METHOD SetDocto(cDocumento) CLASS WMSDTCMontagemDesmontagem
	Self:cDocumento := PadR(cDocumento, Len(Self:cDocumento))
Return

METHOD SetQtdMov(nQtdMov) CLASS WMSDTCMontagemDesmontagem
	Self:nQtdMov := nQtdMov
Return
//-----------------------------------
// Getters
//-----------------------------------
METHOD GetDocto() CLASS WMSDTCMontagemDesmontagem
Return Self:cDocumento

METHOD GetOperac() CLASS WMSDTCMontagemDesmontagem
Return Self:cOperacao

METHOD GetProces() CLASS WMSDTCMontagemDesmontagem
Return Self:cProcesso 

METHOD GetQtdMov() CLASS WMSDTCMontagemDesmontagem
Return Self:nQtdMov

METHOD GetRecno() CLASS WMSDTCMontagemDesmontagem
Return Self:nRecno

METHOD GetErro() CLASS WMSDTCMontagemDesmontagem
Return Self:cErro

METHOD GetArmazem() CLASS WMSDTCMontagemDesmontagem
Return Self:oProdLote:GetArmazem()

METHOD GetEndTran() CLASS WMSDTCMontagemDesmontagem
Return Self:oMntEndTra:GetEnder()
