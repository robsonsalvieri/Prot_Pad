#INCLUDE "PROTHEUS.CH"

Function FSMintSCP(nOrigem,cNumSCP,cItemSCP,cCodProduto,cArmazem,cNumOs,codSolici,nQtdSolicitado,nQtdEntregue,cStatus,cPreRequsitado )

Local cSatSCP  := ''
Local cStaJO4  := ''
Local aAreaJO3 := {}
Local aAreaJO4 := {}
Local aAreaJNA := {}
Local aAreaJN7 := {}
Local lAtuJN7  := .T.
Local lAtuEstTec := .F.
Local lAtuTransTec := .F.
Local cCodOrc  := ''
Local cCodTecnico := ''
Local cEndTecBoas := ''
Local cArmTec     := ''
local lRet        := .T.
Local nQtdMov     := 0

Private lEstorno := IsInCallStack('A185ESTORN')
Private lBaixa185 := IsInCallStack('A185Baixar')

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
    aAreaAA1  := AA1->( GetArea() )

    nQtdMov := nQtdSolicitado

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

    If (!Empty(cSatSCP) .And. !Empty(cStaJO4)) .Or. lEstorno

        JNU->(dbSetOrder(1))

        lAtuEstTec   := JNU->(dbSeek(xFilial('JNU')+'ESTOQUETECNICO')) .And. AllTrim(JNU->JNU_CONTEU) == '1'
        lAtuTransTec := JNU->(dbSeek(xFilial('JNU')+'TRANSFAUTESTTEC')) .And. AllTrim(JNU->JNU_CONTEU) == '1'

        If lEstorno .Or. (lAtuEstTec .And. lAtuTransTec .And. cSatSCP == '11')

            cCodTecnico := codTecSCP(cNumSCP)

            cEndTecBoas :=  Posicione("AA1",1,xFilial("AA1")+cCodTecnico,"AA1_LOCLZB")
            cArmTec     :=  Posicione("AA1",1,xFilial("AA1")+cCodTecnico,"AA1_LOCAL")

            lRet := TrfArmTec(cCodProduto, SD3->D3_LOCAL, cArmTec, SD3->D3_LOCALIZ, cEndTecBoas, nQtdMov)

        Endif

        IF lRet .And. !Empty(cSatSCP) .And. JO3->(MsSeek(xFilial("JO3")+cNumOs)) 

            JO3->(Reclock("JO3",.f.))
                JO3->JO3_STATUS = cSatSCP
            JO3->(msUnLock()) 

            JO4->(DbsetOrder(1))

            IF JO4->(MsSeek(xFilial("JO4")+JO3->JO3_CODJO4))
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
    Endif    

    RestArea(aAreaJO3)
    RestArea(aAreaJO4)
    RestArea(aAreaJNA)
    RestArea(aAreaJN7)
    RestArea(aAreaAA1)
    
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
         


//-------------------------------------------------------------------
/*/{Protheus.doc} TrfArmTec
@author Vitor kwon
@since 28/08/2026
Transferencia entre armazem de estoque e armazem do tecnico
/*/
//-------------------------------------------------------------------

Function TrfArmTec(cProduto, cArmazemOri, cArmazemDes, cEndOri, cEndDes, nQtd)


Local lRet      := .T.
Local cDocumento := ""
Local cNumSeq   := ""
Local cSerieDoc := ""
Local cEspec    := ""
Local cItemSdb  := ""

DEFAULT cProduto    := ''
DEFAULT cArmazemOri := ''
DEFAULT cArmazemDes := ''
DEFAULT cEndOri     := ''
DEFAULT cEndDes     := ''
DEFAULT nQtd        := 0


Private lMsErroAuto := .F.

Begin Transaction

    If lEstorno  
        cDocumento := NextNumero("SD3",2,"D3_DOC",.T.)
        cNumSeq := ProxNum()
        cEspec := CriaVar("F1_ESPECIE")
        cSerieDoc := SerieNfId("SDB",4,"DB_SERIE",dDataBase,cEspec,"")
        cItemSdb := StrZero(1, TamSx3("DB_ITEM")[1])

        CriaSDB(cProduto,;
                cArmazemDes,;
                nQtd,;
                cEndDes,;
                "",;
                cDocumento,;
                cSerieDoc,;
                "",;
                "",;
                "",;
                "FSM",;
                dDataBase,;
                "",;
                "",;
                cNumSeq,;
                "999",;
                "M",;
                cItemSdb,;
                .T.,;
                0,;
                0)

        GravaSBF("SDB")
    ElseIf lBaixa185
        cDocumento := NextNumero("SD3",2,"D3_DOC",.T.)
        cNumSeq := ProxNum()
        cEspec := CriaVar("F1_ESPECIE")
        cSerieDoc := SerieNfId("SDB",4,"DB_SERIE",dDataBase,cEspec,"")
        cItemSdb := StrZero(1, TamSx3("DB_ITEM")[1])

        CriaSDB(cProduto,;
                cArmazemDes,;
                nQtd,;
                cEndDes,;
                "",;
                cDocumento,;
                cSerieDoc,;
                "",;
                "",;
                "",;
                "FSM",;
                dDataBase,;
                "",;
                "",;
                cNumSeq,;
                "499",;
                "M",;
                cItemSdb,;
                .F.,;
                0,;
                0)

        GravaSBF("SDB")
    EndIf

End Transaction

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} codTecSCP
@author Vitor kwon
@since 28/08/2026
Busca o codigo do tecnico pela SCP
/*/
//-------------------------------------------------------------------

Static Function codTecSCP(cNUmSCP)

Local aArea 	:= GetArea()
Local cAliasTmp		:= GetNextAlias()
Local cQry := ''
local oQry
local cCodJOC := ''

    cQry := " SELECT JO3_CODAA1  "
    cQry += " from "+RetSqlName("JO3")+"  JO3 "
    cQry += " WHERE JO3.D_E_L_E_T_ = ' ' "
    cQry += " AND JO3.JO3_FILIAL  = ? "
    cQry += " AND JO3_NUMSCP = ? " 

    oQry := FwPreparedStatement():New(cQry)
    oQry:SetString(1, xFilial("JO3"))
    oQry:SetString(2, cNUmSCP)
    cQry := oQry:GetFixQuery()
    MPSysOpenQuery(cQry, cAliasTmp)

    If !(cAliasTmp)->(Eof())
        cCodJOC := (cAliasTmp)->JO3_CODAA1
    Endif

    (cAliasTmp)->(dbCloseArea())

    oQry:Destroy()

    FwFreeObj( oQry )

    RestArea(aArea)

Return cCodJOC
         
