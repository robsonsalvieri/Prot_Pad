#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PGCA020.CH"

/*/{Protheus.doc} MATA061EVDEF
    Eventos padrões da rotina de cotações
    Documentação sobre eventos do MVC: https://tdn.totvs.com/x/pgoRE
@author juan.felipe
@since 06/01/2023
/*/
CLASS PGCA020EVDEF FROM FWModelEvent
    Data lNoGenInTTS As Logical
    Data lCtrGrv As Logical
    Data lPcoInte As Logical
    
	Method New() CONSTRUCTOR
    Method ModelPosVld()
    Method BeforeTTS()
    Method InTTS()
    Method AfterTTS()
    Method ReverseRequest()
    Method AnalyzeQuote()
    Method PosVldPCO()
ENDCLASS


/*/{Protheus.doc} New
Construtor da classe.

@author juan.felipe
@since 06/01/2023
@version 1.0
 
/*/
Method New() CLASS PGCA020EVDEF
    Self:lCtrGrv := FindFunction('NFCCtrGRV') .And. FwIsInCallStack('NFCCtrGRV')
    Self:lPcoInte := SuperGetMV("MV_PCOINTE", .F., "2") == "1"
Return Self

/*/{Protheus.doc} ModelPosVld
    Metodo executado uma vez no contexto de validação do modelo principal.
@author juan.felipe
@since 04/01/2021
@param oModel, object, modelo de dados.
@return Nil, nulo.
/*/
Method ModelPosVld(oModel, cModelId) CLASS PGCA020EVDEF
    Local lRet As Logical
    Local cDocType As Character
    Local oModelDHU As Object
    Default oModel := FwModelActive()
    Default cModelId := ''

    lRet := .T.

    If oModel:GetOperation() == MODEL_OPERATION_UPDATE .And. PG020GetOp() == 9
        lRet := Self:PosVldPCO(oModel)
        
        If lRet
            oModelDHU := oModel:GetModel('DHUMASTER')
            cDocType := oModelDHU:GetValue('DHU_TPDOC')
            Self:lNoGenInTTS := FwIsInCallStack('PGCA010') .And. Self:lPcoInte .And. cDocType == '2' .And. !Self:lCtrGrv

            If Self:lNoGenInTTS
                Self:AnalyzeQuote(oModel) //-- Executa a análise da cotação para validação do PCO de contratos sem gravar SC8/SCE.
                lRet := .F. //-- Deve retornar falso para não prosseguir com a gravação.
            EndIf
        EndIf
    EndIf
Return lRet

/*/{Protheus.doc} BeforeTTS
    Metodo executado uma vez no contexto de gravação do modelo principal e antes da transação.
@author juan.felipe
@since 06/01/2023
@param oModel, object, modelo de dados.
@return Nil, nulo.
/*/
Method BeforeTTS(oModel) CLASS PGCA020EVDEF
Return Nil

/*/{Protheus.doc} InTTS
    Metodo executado uma vez no contexto de gravação do modelo principal e durante a transação.
@author juan.felipe
@since 06/01/2023
@param oModel, object, modelo de dados.
@return Nil, nulo.
/*/
Method InTTS(oModel) CLASS PGCA020EVDEF
    Local oModelDHU As Object
    Default oModel := FwModelActive()

    If oModel <> Nil .And. oModel:IsActive() .And. oModel:GetId() == 'PGCA020'
        oModelDHU := oModel:GetModel('DHUMASTER')

        If oModel:GetOperation() == MODEL_OPERATION_DELETE .Or.;
           oModel:GetOperation() == MODEL_OPERATION_UPDATE .And. ( PG020GetOp() == 8 .or. PG020GetOp() == 11 )
            Self:ReverseRequest(oModel)
        Elseif !Self:lNoGenInTTS .And. oModel:GetOperation() == MODEL_OPERATION_UPDATE .And. PG020GetOp() == 9
            Self:AnalyzeQuote(oModel)
        EndIf

        If !Self:lNoGenInTTS .And. oModel:GetOperation() != MODEL_OPERATION_DELETE
            setQuoteStatus(oModelDHU:GetValue('DHU_NUM')) //-- Atualiza status da cotação
        EndIf
    EndIf
Return Nil

/*/{Protheus.doc} AfterTTS
    Metodo executado uma vez no contexto de gravação do modelo principal e após a transação.
@author juan.felipe
@since 06/01/2023
@param oModel, object, modelo de dados.
@return Nil, nulo.
/*/
Method AfterTTS(oModel) Class PGCA020EVDEF
Return Nil

/*/{Protheus.doc} ReverseRequest
    Estorna solicitação de compra na exclusão da cotação completa ou por item
@author juan.felipe
@since 17/01/2023
@param oModel, object, modelo de dados.
@return Nil, nulo.
/*/
Method ReverseRequest(oModel) Class PGCA020EVDEF
    Local aDelLines As Array
    Local oModelDHV As Object
    Local oModelSC8 As Object
    Local nX        As Numeric
    Default oModel := FwModelActive()

    oModelDHV := oModel:GetModel('DHVDETAIL')
    oModelSC8 := oModel:GetModel('SC8DETAIL')

    If oModel:GetOperation() == MODEL_OPERATION_DELETE //-- Exclusão da completa da cotação
        For nX := 1 To oModelDHV:Length() //-- Percorre os itens da cotação para estornar as solicitações de compra
            oModelDHV:GoLine(nX)
            MaAvalCot('SC8', 3,,,,,,,,,, oModelSC8:GetValue('C8_NUM'), oModelSC8:GetValue('C8_PRODUTO'), oModelSC8:GetValue('C8_IDENT'))
        Next nX
    ElseIf oModel:GetOperation() == MODEL_OPERATION_UPDATE .And. (PG020GetOp() == 8 .or. PG020GetOp() == 11)//-- Exclusão de item da cotação
        aDelLines := oModelDHV:GetLinesChanged(MODEL_GRID_LINECHANGED_DELETED)

        For nX := 1 To Len(aDelLines) //-- Percorre as linhas deletadas para estornar as solicitações de compra
            oModelDHV:GoLine(aDelLines[nX])
            MaAvalCot('SC8', 3,,,,,,,,,, oModelSC8:GetValue('C8_NUM'), oModelSC8:GetValue('C8_PRODUTO'), oModelSC8:GetValue('C8_IDENT'))
        Next nX
    EndIf
Return Nil

/*/{Protheus.doc} AnalyzeQuote
    Executa a análise da cotação para geração de documentos.
@author Leandro Fini
@since 26/01/2023
@param oModel, object, modelo de dados.
@return Nil, nulo.
/*/
Method AnalyzeQuote(oModel) Class PGCA020EVDEF
    Local cMessage := ''
    Local cHelpCode := ''
    Private lMsErroAuto := .F.
    Private lMsHelpAuto := .F.
    Private lAutoErrNoFile := .F.

    If FwIsInCallStack('PGCA010') //-- Geração de documentos via PGCA010
        PGCGerDoc()
    Else //-- Geração de documentos via API.
        lMsHelpAuto := .T.
        lAutoErrNoFile := .T.
        
        MSExecAuto({|| PGCGerDoc()}) //-- Executa função de validação com ExecAuto para ser possível obeter as mensagens de help
    
        If lMsErroAuto
            cMessage := PGCMsgAuto(@cHelpCode, .T.)
            oModel:SetErrorMessage(,,,, cHelpCode, cMessage) //-- Obtém mensagens de help
        EndIf
    EndIf
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} PosVldPCO
    Validação do PCO executada no PosValid do modelo.
@author juan.felipe
@since 26/05/2025
@version 1.0
@param oModel, object, modelo de dados.
@return lRet, logical, PCO validado com sucesso.
/*/
//-------------------------------------------------------------------
Method PosVldPCO(oModel) Class PGCA020EVDEF
    Local aAreas As Array
    Local aProducts As Array
    Local aSeekLine As Array
    Local aWinPropLines As Array
	Local cDocType As Character
    Local cMessage As Character
    Local lRet As Logical
    Local lIntPCO As Logical
    Local lPcoTot As Logical
    Local lPcoVld As Logical
    Local lRecSC1 As Logical
    Local lSeekLine As Logical
    Local nX As Numeric
    Local nY As Numeric
    Local nField As Numeric
    Local nTotPco As Numeric
    Local nTamNumped As Numeric
    Local nTamNumCtr As Numeric
    Local nPosNumCtr As Numeric
    Local nPosItemPco As Numeric
    Local nRecSC1 As Numeric
    Local oModelDHU As Object
    Local oModelDHV As Object
    Local oModelSC8 As Object
    Local oModelSCE As Object
    Default oModel := FwModelActive()

    aAreas := {SC8->(GetArea()), SC1->(GetArea()), GetArea()}
    aProducts := {}
    aSeekLine := {}
    aWinPropLines := {}

    lRet := .T.
    lIntPCO := SuperGetMV('MV_PCOINTE',.F.,'2') == '1'
    lPcoTot := FindFunction('NFCPcoTot')
    lPcoVld := FindFunction('NFCPcoVld') 
    lRecSC1 := FindFunction('NFCRecSC1') 

    nX := 0
    nY := 0
    nTotPco := 0

    // Efetua a totalização do lancamento para o PCO
    If lIntPCO .And. lPcoVld .And. lPcoTot .And. lRecSC1
        nTamNumped := TamSX3("CE_NUMPED")[1]
        nTamNumCtr := TamSX3("CE_NUMCTR")[1]
        nPosNumCtr := SCE->(FieldPos("CE_NUMCTR"))
        nPosItemPco := SC8->(FieldPos("C8_ITEMPCO"))

        oModelDHU := oModel:GetModel('DHUMASTER')
        oModelDHV := oModel:GetModel('DHVDETAIL')
        oModelSC8 := oModel:GetModel('SC8DETAIL')
        oModelSCE := oModel:GetModel('SCEDETAIL')

		cDocType := oModelDHU:GetValue("DHU_TPDOC")

        nField := NFCPcoTot()

        SC8->(DbSetOrder(1)) //--C8_FILIAL+C8_NUM+C8_FORNECE+C8_LOJA+C8_ITEM+C8_NUMPRO+C8_ITEMGRD
        SC8->(DbGoTop())

        PcoIniLan("000051")
		PcoIniLan("000052")

        For nX := 1 To oModelDHV:Length()
            oModelDHV:GoLine(nX)
            aWinPropLines := {}

            For nY := 1 to oModelSC8:Length()
                oModelSC8:GoLine(nY)
                If !oModelSC8:IsDeleted()
                    aSeekLine := {}

                    AAdd(aSeekLine, {"CE_FORNECE", oModelSC8:GetValue("C8_FORNECE")})
                    AAdd(aSeekLine, {"CE_LOJA"   , oModelSC8:GetValue("C8_LOJA"   )})
                    AAdd(aSeekLine, {"CE_NUMPRO" , oModelSC8:GetValue("C8_NUMPRO" )}) 
                    AAdd(aSeekLine, {"CE_ITEMCOT", oModelSC8:GetValue("C8_ITEM"   )})
                    AAdd(aSeekLine, {"CE_ITEMGRD", oModelSC8:GetValue("C8_ITEMGRD")})
                    AAdd(aSeekLine, {"CE_PRODUTO", oModelSC8:GetValue("C8_PRODUTO")})
                    AAdd(aSeekLine, {"CE_NUMPED" , Space(nTamNumped)})
                    
                    If nPosNumCtr > 0
                        AAdd(aSeekLine, {"CE_NUMCTR" , Space(nTamNumCtr)})
                    EndIf

                    lSeekLine := oModelSCE:SeekLine(aSeekLine)

                    cSCENumPed := oModelSCE:Getvalue('CE_NUMPED')
                    cSCENumCtr := oModelSCE:Getvalue('CE_NUMCTR')

                    if !lSeekLine .Or. !Empty(cSCENumPed) .Or. !Empty(cSCENumCtr)//Se não existir SCE no modelo, não é a proposta vencedora.
                        Loop
                    endif

                    Aadd(aWinPropLines, {;
                        {'C8_FORNECE', oModelSC8:GetValue("C8_FORNECE")},;
                        {'C8_LOJA'   , oModelSC8:GetValue("C8_LOJA"   )},;
                        {'C8_NUMPRO' , oModelSC8:GetValue("C8_NUMPRO" )},;
                        {'C8_ITEM'   , oModelSC8:GetValue("C8_ITEM"   )},;
                        {'C8_ITEMGRD', oModelSC8:GetValue("C8_ITEMGRD")},;
                        {'C8_PRODUTO', oModelSC8:GetValue("C8_PRODUTO")};
                    })

                    SC8->(DbGoTo(oModelSC8:GetDataId()))
                    
                    If nField > 0 .And. oModelSC8:GetValue('C8_TOTAL') > 0
                        If cDocType == '1'
                            If nField == 1 //-- Totaliza C8_TOTPCO
                                nTotPco += oModelSCE:GetValue('CE_QUANT') * oModelSC8:GetValue('C8_PRECO') //-- Totaliza o total de lançamento do PCO.
                            ElseIf nPosItemPco > 0 //-- Totaliza C8_ITEMPCO
                                SC8->(RecLock("SC8",.F.))
                                SC8->C8_ITEMPCO := oModelSCE:GetValue('CE_QUANT') * oModelSC8:GetValue('C8_PRECO') //-- Totaliza o total de lançamento do PCO por item.
                                SC8->(MsUnlock())
                            EndIf
                        EndIf
                    Endif
                EndIf
            Next nY

            Aadd(aProducts, aWinPropLines)
        Next nX

        For nX := 1 To Len(aProducts)  // Atualiza o campo de lancamento do PCO.
            oModelDHV:GoLine(nX)
            aWinPropLines := aProducts[nX]

            For nY := 1 To Len(aWinPropLines)
                aSeekLine := aWinPropLines[nY]

                If oModelSC8:SeekLine(aSeekLine)
                    SC8->(DbGoTo(oModelSC8:GetDataId()))
                    nRecSC1 := NFCRecSC1(SC8->(Recno()))

                    If lRet := nRecSC1 > 0
                        SC1->(DbGoTo(nRecSC1))

                        If lRet := NFCPcoVld(.F., .F., .T., @cMessage) //-- Valida SC1
                            If cDocType == '1' .And. nField == 1//-- Totaliza apenas se for geração de pedido de compra
                                SC8->(RecLock("SC8",.F.))
                                SC8->C8_TOTPCO := nTotPco
                                SC8->(MsUnlock())
                            EndIf
                        Else
                            PcoFreeBlq('000051')
                            oModel:SetErrorMessage(,,,, 'PG020INVALIDPCO1', Iif(Empty(cMessage), STR0019, cMessage)) //-- A validação do PCO não foi realizada corretamente.
                            Exit
                        EndIf
                    Else
                        oModel:SetErrorMessage(,,,, 'PG020INVALIDSC1', STR0020) //-- As solicitações de compras vinculadas a esta cotação não foram localizadas.
                        Exit
                    EndIf
                EndIf
            Next nY

            If !lRet
                Exit
            EndIf
        Next nX

        If lRet .And. cDocType == '1' //-- Valida apenas se for geração de pedidos
            If nField == 1
                lRet := NFCPcoVld(.F., .F., .F., @cMessage) // faz a chamada do lancamento de contingencia do PCO pelo campo C8_TOTPCO
                PcoFreeBlq("000052")

                If !lRet
                    oModel:SetErrorMessage(,,,, 'PG020INVALIDPCO2', Iif(Empty(cMessage), STR0019, cMessage)) //-- A validação do PCO não foi realizada corretamente.
                EndIf
            EndIf
            
            If (!lRet .And. nField == 1) .Or. (nField == 2 .And. nPosItemPco > 0) .Or. (nField == 0)
                For nX := 1 To Len(aProducts)  
                    oModelDHV:GoLine(nX)
                    aWinPropLines := aProducts[nX]

                    For nY := 1 To Len(aWinPropLines)
                        aSeekLine := aWinPropLines[nY]

                        If oModelSC8:SeekLine(aSeekLine)
                            SC8->(DbGoTo(oModelSC8:GetDataId()))
                            SC8->(RecLock("SC8",.F.))
                            
                            If lRet .And. ((nField == 2 .And. nPosItemPco > 0) .Or. nField == 0) // Faz a chamada do lancamento de contingencia do PCO pelo campo C8_ITEMPCO
                                lRet := NFCPcoVld(.F., .F., .F., @cMessage)

                                If !lRet
                                    If !oModel:HasErrorMessage()
                                        oModel:SetErrorMessage(,,,, 'PG020INVALIDPCO2', Iif(Empty(cMessage), STR0019, cMessage)) //-- A validação do PCO não foi realizada corretamente.
                                        PcoFreeBlq("000052")
                                    EndIf
                                    
                                    If nField == 2
                                        SC8->C8_ITEMPCO := 0 // Restaura o campo de lancamento do PCO.
                                    EndIf
                                EndIf
                            ElseIf !lRet .And. nField > 0 // Restaura o campo de lancamento do PCO.
                                If nField == 1
                                    SC8->C8_TOTPCO := 0
                                Else
                                    SC8->C8_ITEMPCO := 0
                                EndIf
                            Endif

                            SC8->(MsUnlock())
                        EndIf
                    Next nY
                Next nX
            EndIf
        Endif
    EndIf

    aEval(aAreas, {|x| RestArea(x), FwFreeArray(x)})
    FwFreeArray(aProducts)
    FwFreeArray(aSeekLine)
    FwFreeArray(aWinPropLines)
Return lRet
