#Include "protheus.ch"
#Include "TBICONN.ch"
#include "ap5mail.ch"


//-------------------------------------------------------------------
/*/{Protheus.doc} 

@author Vitor Kwon
@since 19/09/2025
@RClasse para estoque - FSM
@version 1.0
*/
//-------------------------------------------------------------------

Class FSM_ESTO

    Method New() Constructor
    Method FSMTransfer()
    Method QuantEnd()
    Method ExisteSBF()

EndClass
Method New() Class FSM_ESTO
Return Self

//-------------------------------------------------------------------
/*/{Protheus.doc} 

@author Vitor Kwon
@since 10/09/2025
@Retorna se tem a quantidade solicitada x disponivel no endereço
@version 1.0
*/
//-------------------------------------------------------------------

Method QuantEnd(cCodPro,cArmOrig,cLocOrig, nQtdSol) Class FSM_ESTO

Local cQuery := ''
local oQry
LOCAL nQuant := 0
Local aArea 	:= GetArea()
Local lRet      	:= .F.
Local cAliasTmp		:= GetNextAlias()

    Default cCodPro  := ""
    Default cArmOrig := ""
    Default cLocOrig := ""
    Default nQtdSol := 0

	cQuery :=  "SELECT SUM(SBF.BF_QUANT) SLD_PRODUT "
	cQuery +=  " FROM "+RetSqlName("SBF")+" SBF"
	cQuery += "  WHERE SBF.BF_FILIAL =  ? "
	cQuery +=   " AND SBF.BF_LOCAL =  ? "
	cQuery +=   " AND SBF.BF_LOCALIZ =  ? "
	cQuery +=   " AND SBF.BF_PRODUTO =  ? "
	cQuery +=   " AND SBF.D_E_L_E_T_ = ' '"
	cQuery +=   " GROUP BY SBF.BF_LOCAL,"
	cQuery +=   " SBF.BF_LOCALIZ"

    oQry := FwPreparedStatement():New(cQuery)
    oQry:SetString(1, xFilial("SBF"))
    oQry:SetString(2, cArmOrig)
    oQry:SetString(3, cLocOrig)
    oQry:SetString(4, cCodPro)
    cQuery := oQry:GetFixQuery()
    MPSysOpenQuery(cQuery, cAliasTmp)
    nQuant := (cAliasTmp)->SLD_PRODUT
    IF nQuant >= GetDToVal(nQtdSol)
       lRet := .T.
    Endif

    (cAliasTmp)->(dbCloseArea())

    oQry:Destroy()

    FwFreeObj( oQry )

    RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} 

@author Vitor Kwon
@since 10/09/2025
@Rprepara para Execauto mata261
@version 1.0
*/
//-------------------------------------------------------------------


Method FSMTransfer(cCodPro,cArmOrig,cArmDest,cLocOrig,cLocDest,nQtdTrf,cLotect,cNumLot,cNumSer,dDtValid) Class FSM_ESTO

    Local aItensSD3 := {}
	Local cD3Poten := criavar('D3_POTENCI')
	Local cD3QtSeg := criavar('D3_QTSEGUM')
	Local cD3Estor := criavar('D3_ESTORNO')
	Local cD3NumSq := criavar('D3_NUMSEQ')
	Local cD3Servi := criavar("D3_SERVIC")
	Local cD3ItemG := criavar("D3_ITEMGRD")
	Local cD3IDDCF := criavar("D3_IDDCF")
	Local cD3Obser := criavar("D3_OBSERVA")

    Default cCodPro  := ""
    Default cArmOrig := ""
    Default cArmDest := ""
    Default cLocOrig := ""
    Default cLocDest := ""
    Default nQtdTrf  := 0
    Default cLotect  := ""
    Default cNumLot  := ""
    Default cNumSer  := ""
    Default dDtValid := Ctod("")

    SB1->(DbSetOrder(1))
    SB1->(DbSeek( xFilial('SB1') + cCodPro ))
    
	AADD( aItensSD3 , SB1->B1_COD )
	AADD( aItensSD3 , SB1->B1_DESC )
	AADD( aItensSD3 , SB1->B1_UM )
	AADD( aItensSD3 , cArmOrig )
	AADD( aItensSD3 , cLocOrig )
	AADD( aItensSD3 , SB1->B1_COD )
	AADD( aItensSD3 , SB1->B1_DESC )
	AADD( aItensSD3 , SB1->B1_UM )
	AADD( aItensSD3 , cArmDest )
	AADD( aItensSD3 , cLocDest )
	AADD( aItensSD3 , cNumSer )
	AADD( aItensSD3 , cLotect )
	AADD( aItensSD3 , cNumLot )
	AADD( aItensSD3 , dDtValid )
	AADD( aItensSD3 , cD3Poten )
	AADD( aItensSD3 , nQtdTrf )
	AADD( aItensSD3 , cD3QtSeg )
	AADD( aItensSD3 , cD3Estor )
	AADD( aItensSD3 , cD3NumSq )
	AADD( aItensSD3 , cLotect )
	AADD( aItensSD3 , dDtValid )
	AADD( aItensSD3 , cD3Servi )
	AADD( aItensSD3 , cD3ItemG )
	AADD( aItensSD3 , cD3IDDCF )
	AADD( aItensSD3 , cD3Obser )

Return aItensSD3
