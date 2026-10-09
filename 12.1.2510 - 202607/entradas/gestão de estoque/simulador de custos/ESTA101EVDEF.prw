#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "ESTA101.CH"

//----------------------------------------------------------------------------------
/*/{Protheus.doc} ESTA101EVDEF
    Eventos padrões para ESTA101 (Simulador de Custos)
    @type Class
    @author Squad Entradas
    @since 13/05/2026
    @version 12.1.2510
/*/
//----------------------------------------------------------------------------------

CLASS ESTA101EVDEF FROM FWModelEvent

    DATA oCacheD5B
    DATA oCacheD5C
    DATA oCacheD5D

    METHOD New() CONSTRUCTOR
    METHOD Activate()
    METHOD DeActivate()
    METHOD GridLinePreVld()
    METHOD GridLinePosVld()
    METHOD FieldPosVld()
    METHOD ModelPosVld()
    METHOD InTTS()
    METHOD PropagarTaxa(oSubModel, nNewTax)

ENDCLASS

//----------------------------------------------------------------------------------
/*/{Protheus.doc} New
    Metodo construtor da classe
    @type Method
    @author Squad Entradas
    @since 13/05/2026
/*/
//----------------------------------------------------------------------------------
METHOD New() CLASS ESTA101EVDEF
    ::oCacheD5B := JsonObject():New()
    ::oCacheD5C := JsonObject():New()
    ::oCacheD5D := JsonObject():New()
Return Nil

//----------------------------------------------------------------------------------
/*/{Protheus.doc} Activate
    Metodo chamado na ativação do modelo
    @type Method
    @author Squad Entradas
    @since 13/05/2026
/*/
//----------------------------------------------------------------------------------
METHOD Activate() CLASS ESTA101EVDEF
Return Nil

//----------------------------------------------------------------------------------
/*/{Protheus.doc} DeActivate
    Metodo chamado na desativação do modelo
    @type Method
    @author Squad Entradas
    @since 13/05/2026
/*/
//----------------------------------------------------------------------------------
METHOD DeActivate() CLASS ESTA101EVDEF
Return Nil

//----------------------------------------------------------------------------------
/*/{Protheus.doc} GridLinePreVld
    Metodo chamado antes da validação de uma linha da grid
    @type Method
    @author Squad Entradas
    @since 15/05/2026
/*/
//----------------------------------------------------------------------------------
METHOD GridLinePreVld(oSubModel, cModelID, nLine, cAction, cId, xValue, xCurrentValue) CLASS ESTA101EVDEF
    Local lRet        := .T.
    Local cCargo      := ""
    Local cComp       := ""
    Local nLinhaAtual := 0

    If cModelID == "D5BDETAIL"
        nLinhaAtual := oSubModel:GetLine()

        If cAction == "DELETE"
            oSubModel:GoLine(nLine)
            cCargo := oSubModel:GetValue("CARGO")
            oSubModel:GoLine(nLinhaAtual)

            If !Empty(cCargo)
                ESTA101Del(cCargo)
            EndIf

        ElseIf cAction == "UNDELETE"
            oSubModel:GoLine(nLine)
            cComp  := oSubModel:GetValue("D5B_COMP")
            cCargo := oSubModel:GetValue("CARGO")
            oSubModel:GoLine(nLinhaAtual)

            If !Empty(cComp) .And. !Empty(cCargo)
                ESTA101Add(cComp, cCargo)
            EndIf

        ElseIf cAction == "SETVALUE"

            If cId == "D5B_QUANT" .And. !Empty(xValue) .And. xValue > 0 .And. !Empty(oSubModel:GetValue("D5B_COMP"))
                ESTA101Upd(oSubModel)
            EndIf

        ElseIf cAction == "CANSETVALUE"

            If cId == "D5B_QUANT" .And. Empty(oSubModel:GetValue("D5B_COMP"))
                Help(,,'Help',,STR0048,; // "O componente deve ser preenchido antes de informar a quantidade."
			     1,0,,,,,,{STR0049}) // "Preencha o campo Componente antes de informar a quantidade."
                lRet := .F.
            EndIf
            
        EndIf
    EndIf

    If cModelID == "D5CDETAIL"
        If cAction == "SETVALUE" .And. cId == "D5C_TAXASM" .And. xValue != xCurrentValue
            If MsgYesNo(STR0061, STR0062) // "Deseja propagar essa alteração para todas as operações com esse recurso?" "Propagar nova taxa simulada?"
                ::PropagarTaxa(oSubModel, xValue)
            Else
                lRet := .T.
            EndIf
        EndIf
    EndIf
    
Return lRet

//----------------------------------------------------------------------------------
/*/{Protheus.doc} ModelPosVld
    Metodo chamado após a validação do modelo, antes do commit dos dados
    @type Method
    @author Squad Entradas
    @since 15/05/2026
/*/
//----------------------------------------------------------------------------------
METHOD ModelPosVld(oModel, cModelId) CLASS ESTA101EVDEF
    Local lRet := .T.
    
    If cModelId == "ESTA101"
        ESTA101Sav(oModel)
    EndIf
    
Return lRet

//----------------------------------------------------------------------------------
/*/{Protheus.doc} InTTS
    Metodo chamado durante o processo de commit dos dados, dentro de uma transação
    Carrega o model de gravação com os dados da linha editada.
    @type Method
    @author Squad Entradas
    @since 15/05/2026
/*/
//----------------------------------------------------------------------------------
METHOD InTTS(oModel, cModelId) CLASS ESTA101EVDEF
    Local cPai       := ""
    Local aComponent := {}
    Local aOperacoes := {}
    Local aCustos    := {}
    Local nI         := 0
    Local nJ         := 0
    Local aFieldsD5B := oModel:GetModel("D5BDETAIL"):GetStruct():GetFields()
    Local aFieldsD5C := oModel:GetModel("D5CDETAIL"):GetStruct():GetFields()
    Local aFieldsD5D := oModel:GetModel("D5DDETAIL"):GetStruct():GetFields()
    
    // D5B
    Local nPosNreg   := aScan(aFieldsD5B, {|x| AllTrim(x[3]) == "NREG"})
    Local nPosLinDel := aScan(aFieldsD5B, {|x| AllTrim(x[3]) == "LINDEL"})
    
    // D5C
    Local nPosNregC  := aScan(aFieldsD5C, {|x| AllTrim(x[3]) == "NREG"})
    Local nPosDelC   := aScan(aFieldsD5C, {|x| AllTrim(x[3]) == "LINDEL"})

    // D5D
    Local nPosNregD  := aScan(aFieldsD5D, {|x| AllTrim(x[3]) == "NREG"})

    Local nNregAtu   := 0
    Local lDeletada  := .F.
    Local oModelGrv  := Nil
    Local oFormGrv   := Nil
    Local cCampo     := ""
    Local aPais      := {}
    Local nIdxPai    := 0

    If cModelId == "ESTA101" 
        
        // GRID D5B - (Modelo ESTA101Grv)
        If ::oCacheD5B != Nil
            aPais := ::oCacheD5B:GetNames()
            
            For nIdxPai := 1 To Len(aPais)
                cPai := aPais[nIdxPai]
                aComponent := ::oCacheD5B[cPai]
                
                For nI := 1 To Len(aComponent)
                    nNregAtu  := aComponent[nI][2][nPosNreg]
                    lDeletada := aComponent[nI][2][nPosLinDel]

                    oModelGrv := FWLoadModel("ESTA101Grv")
                    oFormGrv  := oModelGrv:GetModel("D5BMASTER")

                    If nNregAtu == 0 .And. !lDeletada
                        oModelGrv:SetOperation(MODEL_OPERATION_INSERT)
                    ElseIf nNregAtu > 0 .And. !lDeletada
                        D5B->(DbGoTo(nNregAtu))
                        oModelGrv:SetOperation(MODEL_OPERATION_UPDATE)
                    ElseIf nNregAtu > 0 .And. lDeletada
                        D5B->(DbGoTo(nNregAtu))
                        oModelGrv:SetOperation(MODEL_OPERATION_DELETE)
                    EndIf

                    oModelGrv:Activate()

                    If oModelGrv:GetOperation() != MODEL_OPERATION_DELETE
                        For nJ := 1 To Len(aFieldsD5B)
                            cCampo := AllTrim(aFieldsD5B[nJ][3])
                            If aFieldsD5B[nJ][14] == .F.
                                oFormGrv:LoadValue(cCampo, aComponent[nI][2][nJ])
                            EndIf
                        Next nJ
                    EndIf

                    If oModelGrv:VldData()
                        FWFormCommit(oModelGrv)
                    EndIf

                    oModelGrv:DeActivate()
                    oModelGrv:Destroy()

                Next nI
            Next nIdxPai
        EndIf

        // GRID D5C - (Modelo ESTA101OPE)
        If ::oCacheD5C != Nil
            aPais := ::oCacheD5C:GetNames()
            
            For nIdxPai := 1 To Len(aPais)
                cPai := aPais[nIdxPai]
                aOperacoes := ::oCacheD5C[cPai]
                
                For nI := 1 To Len(aOperacoes)
                    nNregAtu  := IIf(nPosNregC > 0, aOperacoes[nI][2][nPosNregC], 0)
                    lDeletada := IIf(nPosDelC > 0, aOperacoes[nI][2][nPosDelC], .F.)

                    oModelGrv := FWLoadModel("ESTA101OPE")
                    oFormGrv  := oModelGrv:GetModel("D5CMASTER")

                    If nNregAtu == 0 .And. !lDeletada
                        oModelGrv:SetOperation(MODEL_OPERATION_INSERT)
                    ElseIf nNregAtu > 0 .And. !lDeletada
                        D5C->(DbGoTo(nNregAtu))
                        oModelGrv:SetOperation(MODEL_OPERATION_UPDATE)
                    ElseIf nNregAtu > 0 .And. lDeletada
                        D5C->(DbGoTo(nNregAtu))
                        oModelGrv:SetOperation(MODEL_OPERATION_DELETE)
                    EndIf

                    oModelGrv:Activate()

                    If oModelGrv:GetOperation() != MODEL_OPERATION_DELETE
                        For nJ := 1 To Len(aFieldsD5C)
                            cCampo := AllTrim(aFieldsD5C[nJ][3])
                            If aFieldsD5C[nJ][14] == .F. 
                                oFormGrv:LoadValue(cCampo, aOperacoes[nI][2][nJ])
                            EndIf
                        Next nJ
                    EndIf

                    If oModelGrv:VldData()
                        FWFormCommit(oModelGrv)
                    EndIf

                    oModelGrv:DeActivate()
                    oModelGrv:Destroy()

                Next nI
            Next nIdxPai
        EndIf

        // GRID D5D - (Modelo ESTA101CST)
        If ::oCacheD5D != Nil
            aPais := ::oCacheD5D:GetNames()
            For nIdxPai := 1 To Len(aPais)
                cPai := aPais[nIdxPai]
                aCustos := ::oCacheD5D[cPai]
                
                For nI := 1 To Len(aCustos)
                    nNregAtu := IIf(nPosNregD > 0, aCustos[nI][2][nPosNregD], 0)

                    oModelGrv := FWLoadModel("ESTA101CST")
                    oFormGrv  := oModelGrv:GetModel("D5DMASTER")

                    If nNregAtu == 0
                        oModelGrv:SetOperation(MODEL_OPERATION_INSERT)
                    Else
                        D5D->(DbGoTo(nNregAtu))
                        oModelGrv:SetOperation(MODEL_OPERATION_UPDATE)
                    EndIf

                    oModelGrv:Activate()

                    For nJ := 1 To Len(aFieldsD5D)
                        cCampo := AllTrim(aFieldsD5D[nJ][3])
                        If aFieldsD5D[nJ][14] == .F. 
                            oFormGrv:LoadValue(cCampo, aCustos[nI][2][nJ])
                        EndIf
                    Next nJ

                    If oModelGrv:VldData()
                        FWFormCommit(oModelGrv)
                    EndIf

                    oModelGrv:DeActivate()
                    oModelGrv:Destroy()
                Next nI
            Next nIdxPai
        EndIf

    EndIf
Return Nil

//----------------------------------------------------------------------------------
/*/{Protheus.doc} GridLinePosVld
    Metodo chamado após a validação de uma linha da grid
    @type Method
    @author Squad Entradas
    @since 21/05/2026
/*/
//----------------------------------------------------------------------------------
METHOD GridLinePosVld(oSubModel, cModelID, nLine, cAction, cId, xValue, xCurrentValue) CLASS ESTA101EVDEF
    Local lRet     := .T.
    Local cComp    := ""
    Local cOperac  := ""
    Local nQuant   := 0
    Local nTempPad := 0

    If cModelID == "D5BDETAIL"
        cComp  := oSubModel:GetValue("D5B_COMP")
        nQuant := oSubModel:GetValue("D5B_QUANT")

        If !Empty(cComp) .And. nQuant <= 0
            Help(,,'Help',,STR0050,; // "O componente deve ter uma quantidade maior que zero."
			     1,0,,,,,,{STR0051}) // "Preencha o campo Quantidade com um valor maior que zero."
            lRet := .F.
        EndIf
    
    EndIf

    If cModelID == "D5CDETAIL"
        nTempPad := oSubModel:GetValue("D5C_TEMPAD")
        cOperac  := oSubModel:GetValue("D5C_OPERAC")
        cDescri  := oSubModel:GetValue("D5C_DESCRI")

        If (Empty(cOperac) .Or. Empty(cDescri))
            Help(,,'Help',,STR0052,; // "Não é permitido o cadastro de operações com descrição ou código vazios."
                1,0,,,,,,{STR0053}) // "Preencha os campos Código e Descrição para esta operação"
            lRet := .F.
        ElseIf (!Empty(cOperac) .Or. !Empty(cDescri)) .And. nTempPad = 0
            Help(,,'Help',,STR0054,; // "Não é permitido o cadastro de operações com Tempo Padrão zerado."
			     1,0,,,,,,{STR0055}) // "Digite o tempo padrão para esta operação"!
            lRet := .F.
        EndIf

    EndIf

Return lRet

//----------------------------------------------------------------------------------
/*/{Protheus.doc} FieldPosVld
    Metodo chamado após a validação de um campo
    @type Method
    @author Squad Entradas
    @since 21/05/2026
/*/
//----------------------------------------------------------------------------------
METHOD FieldPosVld() CLASS ESTA101EVDEF
    Local lRet := .T.

Return lRet

//----------------------------------------------------------------------------------
/*/{Protheus.doc} PropagarTaxa
    Metodo para propagar a taxa de um recurso para as outras operações que utilizam o mesmo recurso
    @type Method
    @author Squad Entradas
    @since 16/06/2026
/*/
//----------------------------------------------------------------------------------
METHOD PropagarTaxa(oSubModel, nNewTax) CLASS ESTA101EVDEF
    Local cRecurso   := oSubModel:GetValue("D5C_RECURS")
    Local nLineAtu   := oSubModel:GetLine()
    Local nI         := 0
    Local nJ         := 0
    Local aFields    := oSubModel:GetStruct():GetFields()
    Local nPosRec    := aScan(aFields, {|x| AllTrim(x[3]) == "D5C_RECURS"})
    Local nPosTax    := aScan(aFields, {|x| AllTrim(x[3]) == "D5C_TAXASM"})
    Local aPais      := {}
    Local aOperacoes := {}
    Local cPaiAtu    := ""
    Local oView      := FWViewActive()

    // se a operação não tem recurso, retorna
    If Empty(cRecurso)
        Return Nil
    EndIf

    // Atualizar a grid atual
    For nI := 1 To oSubModel:GetQtdLine()
        If nI != nLineAtu
            oSubModel:GoLine(nI)
            If !oSubModel:IsDeleted() .And. oSubModel:GetValue("D5C_RECURS") == cRecurso
                oSubModel:LoadValue("D5C_TAXASM", nNewTax)
            EndIf
        EndIf
    Next nI
    
    // Atualiza o cache JSON
    If ::oCacheD5C != Nil
        aPais := ::oCacheD5C:GetNames()
        
        For nI := 1 To Len(aPais)
            cPaiAtu    := aPais[nI]
            aOperacoes := ::oCacheD5C[cPaiAtu]
            
            For nJ := 1 To Len(aOperacoes)
                If aOperacoes[nJ][2][nPosRec] == cRecurso
                    aOperacoes[nJ][2][nPosTax] := nNewTax
                EndIf
            Next nJ
        Next nI
    EndIf

    oSubModel:GoLine(nLineAtu)
    oView:Refresh(oSubModel:GetId())

Return Nil
