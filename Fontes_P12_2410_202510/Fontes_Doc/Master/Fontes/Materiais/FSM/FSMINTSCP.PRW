#INCLUDE "PROTHEUS.CH"

Function FSMintSCP(nOrigem,cNumSCP,cItemSCP,cCodProduto,cArmazem,cNumOs,codSolici,nQtdSolicitado,nQtdEntregue,cStatus,cPreRequsitado )

Local cSatSCP  := ''
Local cStaJO4  := ''
Local aAreaJO3 := {}
Local aAreaJO4 := {}
Local aAreaJNA := {}
Local aAreaJN7 := {}
Local lAtuJN7  := .T.
Local cCodOrc  := ''

DEFAULT nOrigem   := 0
DEFAULT cNumSCP   := ''
DEFAULT cItemSCP := ''
DEFAULT cCodProduto   := ''
DEFAULT cArmazem := ''
DEFAULT cNumOs :=  ''    
DEFAULT codSolici	 := ''
DEFAULT nQtdSolicitado	 := 0
DEFAULT nQtdEntregue	 := 0
DEFAULT cStatus	 := ''
DEFAULT cPreRequsitado := ''
 
IF (FWAliasInDic("JO4") .And. FWAliasInDic("JO3")) .And. !Empty(cNumOs)

    aAreaJO3  := JO3->( GetArea() )
    aAreaJO4  := JO4->( GetArea() )
    aAreaJNA  := JNA->( GetArea() )
    aAreaJN7  := JN7->( GetArea() )

    If ( (IsInCallStack('A106PreReq') .And. nOrigem == 2 .And. cPreRequsitado == 'S') .Or. (nOrigem == 3) )
        cSatSCP := '09'  
        cStaJO4 := '2'
    ElseIf IsInCallStack('A185Baixar') .And. cStatus == 'E' .And. nQtdEntregue > 0 .And. nQtdSolicitado == nQtdEntregue
        cSatSCP := '11'
        cStaJO4 := '5'
    ElseIf nQtdEntregue > 0 .And. nQtdEntregue < nQtdSolicitado  
        cSatSCP := '10' 
        cStaJO4 := '4'                
    EndIf

    IF JO3->(MsSeek(xFilial("JO3")+cNumOs))
        JO3->(Reclock("JO3",.f.))
            JO3->JO3_STATUS = cSatSCP
        JO3->(msUnLock()) 

        JO4->(DbsetOrder(3))

        IF JO4->(MsSeek(xFilial("JO4")+JO3->JO3_CODJN5))
            JO4->(Reclock("JO4",.f.))
                JO4->JO4_LIBEST = cStaJO4
            JO4->(msUnLock()) 
        Endif

        IF  cSatSCP == '11' 
            IF JNA->(MsSeek(xFilial("JNA")+JO3->JO3_CODJNA)) 
                JNA->(Reclock("JNA",.f.))
                    JNA->JNA_REQUIS = '4'
                JO4->(msUnLock()) 
                cCodOrc := JO3->JO3_CODJN7
            Endif
            IF !Empty(cCodOrc)
                lAtuJN7 := CheckJN7(cCodOrc)
            Endif
            IF lAtuJN7
                IF JN7->(MsSeek(xFilial("JN7")+JO3->JO3_CODJN7))
                    JN7->(Reclock("JN7",.f.))
                        JN7->JN7_SITUA = '6' // Liberado O.S
                    JN7->(msUnLock()) 
                Endif
            Endif
        Endif    
    Endif

    RestArea(aAreaJO3)
    RestArea(aAreaJO4)
    RestArea(aAreaJNA)
    RestArea(aAreaJN7)
    
Endif   

Return

Static Function CheckJN7(cCodOrc)

Local aArea 	:= GetArea()
Local lRet      	:= .F.
Local cAliasTmp		:= GetNextAlias()
Local cQry := ''
local oQry
Local nQuant      := 0
Local nQuantTot   := 0
local nI          := 0

    For nI := 1 to 2

        cQry := " SELECT COUNT(*) QUANT "
        cQry += " from "+RetSqlName("JO3")+"  JO3 "
        cQry += " WHERE JO3.D_E_L_E_T_ = ' ' "
        cQry += " AND JO3.JO3_FILIAL  = ? "
        cQry += " AND JO3_CODJN7 = ? " 

        if nI == 2
            cQry += " AND JO3_STATUS = '11' "  // Entrega Total
        Endif   

        oQry := FwPreparedStatement():New(cQry)
        oQry:SetString(1, xFilial("JO3"))
        oQry:SetString(2, cCodOrc)
        cQry := oQry:GetFixQuery()
        MPSysOpenQuery(cQry, cAliasTmp)

        if nI == 1
            nQuant := (cAliasTmp)->QUANT
        Else
            nQuantTot := (cAliasTmp)->QUANT
        Endif    

    Next 

    If nQuant == nQuantTot
      lRet := .T.
    Endif

(cAliasTmp)->(dbCloseArea())

oQry:Destroy()

FwFreeObj( oQry )

RestArea(aArea)

Return lRet
         


	