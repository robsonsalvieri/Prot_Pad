#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#include 'PGCXANL.CH'

Static _oJsonCtr := JsonObject():New() //-- Define Json para geração de contratos, estrutura esperada: { "contractgenerationtype": "1", "contracts":  [  { "cn9_condpg": "001", "cn9_tpcto": "001" } ] }
Static _nPosSup := 1 //-- Posição do código do fornecedor
Static _nPosStore := 2 //-- Posição da loja do fornecedor
Static _nPosProd := 1 //-- Posição do produto
Static _nPosQt := 2 //-- Posição da quantidade
Static _nPosNumSC := 3 //-- Posição do número da SC
Static _nPosItSC := 4 //-- Posição do item da SC
Static _nPosVlUn := 5 //-- Posição do valor unitário
Static _nPosVlTot := 6 //-- Posição do valor total
Static _nPosIdnt := 7 //-- Posição do identificador
Static _nPosDesc := 8 //-- Posição do desconto
Static _aCN9Flds := {'CN9_NUMERO','CN9_DTINIC','CN9_UNVIGE','CN9_MOEDA','CN9_CONDPG','CN9_TPCTO','CN9_FLGREJ','CN9_FLGCAU'} //-- Todos os campos obrigatórios da CN9
Static _aCNCFlds := {'CNC_NUMERO','CNC_CODIGO','CNC_LOJA',} //-- Todos os campos obrigatórios da CNC
Static _aCNAFlds := {'CNA_CONTRA','CNA_NUMERO','CNA_FORNEC','CNA_LJFORN','CNA_DTINI','CNA_DTFIM','CNA_TIPPLA',; //-- Todos os campos obrigatórios da CNA
                     'CNA_CRONOG','CNA_ESPEL' ,'CNA_FLREAJ','CNA_DIAMES','CNA_PROMED','CNA_ULTMED','CNA_MEDEFE'}
Static _aCNBFlds := {'CNB_NUMERO','CNB_CONTRA','CNB_ITEM','CNB_PRODUT','CNB_UM','CNB_QUANT','CNB_VLUNIT'} //-- Todos os campos obrigatórios da CNB
  
// Private __aGenContra := {} //-- Adiciona números dos contratos gerados pela análise.
// Private __aSupError := {} //-- Adiciona fornecedor do contrato que deu erro de gravação

/*/{Protheus.doc} PGCGerDoc
    Analisa cotação por proposta e por item.
    Realiza a compatibilização dos dados da SCE e SC8
    para gerar o pedido de compra ou contrato.
@author Leandro Fini
@since 26/01/2023
@param oModel, object, modelo de dados.
@return Nil, nulo.
/*/
Function PGCGerDoc(oModel)
    Local nLenHdSCE as Numeric
    Local nPosCENumPr as Numeric
    Local nPosCEQnt as Numeric
    Local nPosCEForn as Numeric
    Local nPosCELoja as Numeric
    Local nPosCEMot as Numeric
    Local nPosCEMtVnc as Numeric
    Local nPosCEEntr as Numeric
    Local nPosCEReg as Numeric
    Local nPosCEItGr as Numeric
    Local nPosCEItem as Numeric
    Local nPosCECot as Numeric
    Local nPosCEAli as Numeric
    Local nPosCERec as Numeric
    Local nTamNumped as Numeric
    Local nTamNumCtr as Numeric
    Local nPosNumCtr as Numeric
    Local oModelDHU as Object
    Local oModelDHV as Object
    Local oModelSC8 as Object
    Local oModelSCE as Object

    Local aSeekLine as Array
    Local aSeekSCE as Array
    Local aSC8 as Array
    Local aItem as Array
    Local aDocs as Array
    Local aAreaSC8 as Array
    Local aSaveLines as Array

    Local cFilDHU as Char
    Local cFilSC8 as Char
    Local cFilSCE as Char
    Local cRefer as Char

    Local nX as Numeric
    Local nY as Numeric
    Local nCount as Numeric
    Local nIProp as Numeric
    Local nItem as Numeric
    Local nWin as Numeric
    Local nSaveSX8 as Numeric
    Local lReference as Logical
    Local lRet as Logical
    Local lHasSupObs as Logical
    Local lSeekLine As Logical
    Local lIntPCO As Logical
    Local lPcoTot As Logical
    Local lPcoVld As Logical
    Local lRecSC1 As Logical

    Local cSCENumPed as Char
    Local cSCENumCtr as Char

    Local cSupplier as Char
    Local cStore as Char
    Local cLastProp as Char

    Private aColsSCE as Array
    Private aHeadSCE as Array
    
    Default oModel := FWModelActive()

    lRet := .T.

    //-- Obter aHeader da SCE por compatibilização com a MaAvalCot
    aHeadSCE := COMXHDCO("SCE")
            
    //-- Adicionar os campos de Alias e Recno
    ADHeadRec("SCE", aHeadSCE)

    //-- Obter tamanho do aHeader
    nLenHdSCE := Len(aHeadSCE)

    //-- Padronizar o X3_CAMPO com AllTrim
    AEval(aHeadSCE, {|x| x[2] := AllTrim(x[2])})

    //-- Obter posições do Header
    nPosCENumPr := AScan(aHeadSCE, {|x| x[2] == "CE_NUMPRO"})
    nPosCEQnt   := AScan(aHeadSCE, {|x| x[2] == "CE_QUANT"})
    nPosCEForn  := AScan(aHeadSCE, {|x| x[2] == "CE_FORNECE"})
    nPosCELoja  := AScan(aHeadSCE, {|x| x[2] == "CE_LOJA"})
    nPosCEMot   := AScan(aHeadSCE, {|x| x[2] == "CE_MOTIVO"})
    nPosCEMtVnc := AScan(aHeadSCE, {|x| x[2] == "CE_MOTVENC"})
    nPosCEEntr  := AScan(aHeadSCE, {|x| x[2] == "CE_ENTREGA"})
    nPosCEReg   := AScan(aHeadSCE, {|x| x[2] == "CE_REGIST"})
    nPosCEItGr  := AScan(aHeadSCE, {|x| x[2] == "CE_ITEMGRD"})
    nPosCEItem  := AScan(aHeadSCE, {|x| x[2] == "CE_ITEMCOT"})
    nPosCECot   := AScan(aHeadSCE, {|x| x[2] == "CE_NUMCOT"})
    nPosCEAli   := AScan(aHeadSCE, {|x| x[2] == "CE_ALI_WT"})
    nPosCERec   := AScan(aHeadSCE, {|x| x[2] == "CE_REC_WT"})
    lHasSupObs  := SC8->(FieldPos('C8_OBSFOR')) > 0

    lIntPCO := SuperGetMV('MV_PCOINTE',.F.,'2') == '1'
    lPcoTot := FindFunction('NFCPcoTot')
    lPcoVld := FindFunction('NFCPcoVld') 
    lRecSC1 := FindFunction('NFCRecSC1') 

    If oModel <> Nil

        //-- Inicializar as variáveis
        DbSelectArea('SCE')
        oModelDHU := oModel:GetModel("DHUMASTER")
        oModelDHV := oModel:GetModel("DHVDETAIL")
        oModelSC8 := oModel:GetModel("SC8DETAIL")
        oModelSCE := oModel:GetModel("SCEDETAIL")

        aItem := {}
        aSC8 := {}
        aColsSCE := {}
        aSaveLines := FWSaveRows()
        aSeekLine := {}
        aSeekSCE := {}
        aDocs := {}
        aAreaSC8 := SC8->(GetArea())

        cRefer := ""
        cFilSC8 := xFilial("SC8")
        cPedNbr := ""
        cFilSCE := xFilial("SCE")
        cFilDHU := xFilial("DHU")

        nX := 0
        nY := 1
        nCount := 1
        nIProp := 0
        nItem := 0
        nWin := 0
        nSaveSX8 := GetSX8Len()
        nTamNumped := TamSX3("CE_NUMPED")[1]
        nTamNumCtr := TamSX3("CE_NUMCTR")[1]
        nPosNumCtr := FieldPos("CE_NUMCTR")

        //-- Montar o aColsSCE e aSC8 para passagem de parâmetro da MaAvalCot
        For nX := 1 To oModelDHV:Length()
            oModelDHV:GoLine(nX)
            nY := 1

            AAdd(aSC8, {})
            AAdd(aColsSCE, {})

            nItem := Len(aSC8)
            nWin := Len(aColsSCE)

            While nY <= oModelSC8:Length()
                oModelSC8:GoLine(nY)
                SC8->(MsGoTo(oModelSC8:GetDataId()))

                If !oModelSC8:IsDeleted()
                    aSeekLine := {}

                    AAdd(aSeekLine, {"CE_FORNECE", oModelSC8:GetValue("C8_FORNECE")})
                    AAdd(aSeekLine, {"CE_LOJA"   , oModelSC8:GetValue("C8_LOJA")})
                    AAdd(aSeekLine, {"CE_NUMPRO" , oModelSC8:GetValue("C8_NUMPRO")}) 
                    AAdd(aSeekLine, {"CE_ITEMCOT", oModelSC8:GetValue("C8_ITEM")})
                    AAdd(aSeekLine, {"CE_ITEMGRD", oModelSC8:GetValue("C8_ITEMGRD")})
                    AAdd(aSeekLine, {"CE_PRODUTO", oModelSC8:GetValue("C8_PRODUTO")})
                    AAdd(aSeekLine, {"CE_NUMPED", Space(nTamNumped)})
                    
                    If nPosNumCtr > 0
                        AAdd(aSeekLine, {"CE_NUMCTR" , Space(nTamNumCtr)})
                    EndIf

                    lSeekLine := oModelSCE:SeekLine(aSeekLine)//Se não existir SCE no modelo, não é a proposta vencedora.

                    cSCENumPed := oModelSCE:Getvalue('CE_NUMPED')
                    cSCENumCtr := oModelSCE:Getvalue('CE_NUMCTR')

                    if !lSeekLine .Or. !Empty(cSCENumPed) .Or. !Empty(cSCENumCtr)//Se não existir SCE no modelo, não é a proposta vencedora.
                        nY++
                        Loop
                    endif

                    cRefer := oModelSC8:GetValue("C8_PRODUTO")
                    lReference := MatGrdPrRf(@cRefer, .T.)

                    If lReference 
                        SC8->(DbSetOrder(4))//C8_FILIAL+C8_NUM+C8_IDENT+C8_PRODUTO
                        cSeek := cFilSC8 + SC8->C8_NUM + SC8->C8_IDENT + SC8->C8_PRODUTO
                        SC8->(DbSeek(cSeek))
                        cSupplier := oModelSCE:GetValue("CE_FORNECE")
                        cStore    := oModelSCE:GetValue("CE_LOJA")
                        cLastProp := oModelSCE:GetValue("CE_NUMPRO")
                    EndIf
                
                    While !lReference .Or. (!SC8->(Eof()) .And. SC8->(C8_FILIAL + C8_NUM + C8_IDENT + C8_PRODUTO) == cSeek)
                        If lReference .And. SC8->(C8_FORNECE + C8_LOJA + C8_NUMPRO) != cSupplier + cStore + cLastProp
                            SC8->(DbSkip())
                            Loop
                        EndIf

                        AAdd(aSC8[nItem], {})
                        nIProp := Len(aSC8[nItem])

                        AAdd(aSC8[nItem, nIProp], {"C8_ITEM"	, SC8->C8_ITEM })
                        AAdd(aSC8[nItem, nIProp], {"C8_NUMPRO"	, SC8->C8_NUMPRO })
                        AAdd(aSC8[nItem, nIProp], {"C8_PRODUTO"	, SC8->C8_PRODUTO })
                        AAdd(aSC8[nItem, nIProp], {"C8_COND"	, SC8->C8_COND })
                        AAdd(aSC8[nItem, nIProp], {"C8_FORNECE"	, SC8->C8_FORNECE })
                        AAdd(aSC8[nItem, nIProp], {"C8_LOJA"	, SC8->C8_LOJA })
                        AAdd(aSC8[nItem, nIProp], {"C8_NUM"		, SC8->C8_NUM })
                        AAdd(aSC8[nItem, nIProp], {"C8_ITEMGRD"	, SC8->C8_ITEMGRD })
                        AAdd(aSC8[nItem, nIProp], {"C8_NUMSC"	, SC8->C8_NUMSC })
                        AAdd(aSC8[nItem, nIProp], {"C8_ITEMSC"	, SC8->C8_ITEMSC })
                        AAdd(aSC8[nItem, nIProp], {"C8_FILENT"	, SC8->C8_FILENT })			
                        AAdd(aSC8[nItem, nIProp], {"C8_DATPRF"	, SC8->C8_DATPRF })
                        AAdd(aSC8[nItem, nIProp], {"C8_OBS"		, SC8->C8_OBS })
                        AAdd(aSC8[nItem, nIProp], {"SC8RECNO"   , SC8->(Recno()) })

                        If lHasSupObs
                            AAdd(aSC8[nItem, nIProp], {"C8_OBSFOR", SC8->C8_OBSFOR })
                        EndIf

                        aItem := Array(nLenHdSCE)

                        //-- Montar aCols da SCE para envio a MaAvalCot
                            If nPosCENumPr > 0
                                aItem[nPosCENumPr] := SC8->C8_NUMPRO
                            EndIf

                            If nPosCEQnt > 0
                                If oModelSCE:SeekLine(aSeekLine, .F., .T.)
                                    aItem[nPosCEQnt] := oModelSCE:GetValue("CE_QUANT")
                                EndIf
                            EndIf

                            If nPosCEForn > 0
                                aItem[nPosCEForn] := SC8->C8_FORNECE
                            EndIf
                            
                            If nPosCELoja > 0
                                aItem[nPosCELoja] := SC8->C8_LOJA
                            EndIf
                            
                            Iif(nPosCEMot > 0, aItem[nPosCEMot] := SC8->C8_MOTIVO, Nil)

                            If nPosCEMtVnc > 0 
                                aItem[nPosCEMtVnc] := SC8->C8_MOTVENC
                            EndIf
                            
                            If nPosCEEntr > 0
                                aItem[nPosCEEntr] := SC8->C8_DATPRF
                            EndIf
                            
                            If nPosCEReg > 0
                                aItem[nPosCEReg] := 0
                            EndIf
                            
                            If nPosCEItGr > 0
                                aItem[nPosCEItGr] := SC8->C8_ITEMGRD
                            EndIf

                            If nPosCEItem > 0 
                                aItem[nPosCEItem] := SC8->C8_ITEM
                            EndIf
                            
                            If nPosCECot > 0 
                                aItem[nPosCECot] := SC8->C8_NUM
                            EndIf

                            If nPosCEAli > 0
                                aItem[nPosCEAli] := "SC8"
                            EndIf

                            If nPosCERec > 0
                                aItem[nPosCERec] := SC8->(Recno())				
                            EndIf

                            AAdd(aColsSCE[nWin], aItem)
                        //-- Fim da montagem do aColsSCE[n]

                        If !lReference
                            aSeekLine := {}
                            Exit
                        Else
                            SC8->(DbSkip())
                        EndIf							
                    EndDo
                EndIf
                nY++
            End
        Next nX

        RestArea(aAreaSC8)
        FWRestRows(aSaveLines)

        //-- Gerar: 1 = Pedido de Compras  
        If oModelDHU:GetValue("DHU_TPDOC") ==  '1'
            //-- Avaliar parâmetros da MaAvalCot
            If Len(aColsSCE) > 0 .And. Len(aSC8) > 0
                //-- Gerar pedidos de compra
                MaAvalCOT("SC8", 4, aSC8, aHeadSCE, aColsSCE, .F.,, {|| .T.},, aDocs, .T.)
                
                //-- Executar gatilhos
                EvalTrigger()
            EndIf
        ElseIf oModelDHU:GetValue("DHU_TPDOC") ==  '2'
            _oJsonCtr := PG020GetCtr()
            lRet := GerContra(aColsSCE, aHeadSCE)
                
            If !lRet
                While (GetSX8Len() > nSaveSX8) //-- Restaurar controle de numeração
                    RollBackSx8()
                EndDo
            EndIf
        EndIf

        If lIntPCO .And. lPcoTot .And. lPcoVld .And. lRecSC1 //-- Finaliza lançamentos do PCO
            PcoFinLan("000051")
            PcoFinLan("000052")
            PcoFreeBlq("000051")
            PcoFreeBlq("000052")
        EndIf

        If lRet //-- Atualizar a tela do PO-UI
            PG010Saved(.T.)
        EndIf

        FwFreeArray(aItem)
        FwFreeArray(aSC8)
        FwFreeArray(aColsSCE)
        FwFreeArray(aSaveLines)
        FwFreeArray(aSeekLine)
        FwFreeArray(aSeekSCE)
        FwFreeArray(aDocs)
        FwFreeArray(aAreaSC8)
    EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GerContra
    Função para geração de Contrato.
@author juan.felipe
@since 08/08/2023
@version 1.0
@param aWinners, array, Array com o resultado das cotações para a geração do contrato.
@param aHdSCE, array, cabeçalho da SCE.
@return lRet, logical, contrato inserido com sucesso.
/*/
//-------------------------------------------------------------------
Static Function GerContra(aWinners, aHdSCE)
    Local aArea as Array 
    Local lRet as Logical
    Local aData as Array
    Local cTpContr as Character	
    Local nX as Numeric
    Default aWinners := {}
    Default aHdSCE := {}

    //-- Inicializar variáveis
    aArea := GetArea()
    lRet := .T.
    aData	:= WinOrder(aWinners, aHdSCE)
    nTpContr := ''
    nX := 1

    Begin Transaction
        If FwIsInCallStack("PGCA010")
            If !ExecModCtr(aData, aHdSCE, .T.)
                lRet := .F.					
                DisarmTransaction()
            EndIf
        Else 
            //-- Processar a geração de contratos
            If Len(aData) > 0 .And. _oJsonCtr:hasProperty('contractgenerationtype') .And. _oJsonCtr:hasProperty('contracts') .And. Len(_oJsonCtr['contracts']) > 0
                If lRet
                    cTpContr := _oJsonCtr['contractgenerationtype']

                    If cTpContr == '1' //-- Um unico contrato, com N planilhas
                        If !ExecModCtr(aData, aHdSCE)
                            lRet := .F.					
                            DisarmTransaction()
                        EndIf
                    Else
                        For nX := 1 To Len(aData) //-- Um contrato por fornecedor
                            If !ExecModCtr({aData[nX]}, aHdSCE)
                                lRet := .F.			
                                DisarmTransaction()
                                Exit
                            EndIf
                        Next				
                    EndIf
                EndIf
            Else
                Help("", 1, "PGCANALYZECNTR",, STR0003, 1, 0) //-- "PGCANALYZECNTR" - "Não há vencedores selecionados nesta análise!"
                lRet:= .F.
            EndIf		

        EndIf
    End Transaction

    RestArea(aArea)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} WinOrder()
    Agrupa vencedores por fornecedor.
@author juan.felipe
@since 08/08/2023
@version 1.0
@return lRet
/*/
//-------------------------------------------------------------------
Static Function WinOrder(aWin, aHdSCE)
    Local aAux	as Array
    Local aRet  as Array
    Local aData as Array
    Local nPosQuant	as Numeric
    Local nPosSup as Numeric
    Local nPosStore as Numeric
    Local cSupplier as Char	 
    Local cStore as Char
    Local nX as Numeric 
    Local nY as Numeric

    Default aWin := {}
    Default aHdSCE := {}

    //-- Inicializar as variáveis
    aAux :=	{}
    aRet :=	{}
    aData := {}
    nPosQuant := 0
    nPosSup := 0
    nPosStore	:= 0
    nPosQuant := AScan(aHdSCE, {|x| x[2] == "CE_QUANT"})
    nPosSup := AScan(aHdSCE, {|x| x[2] == "CE_FORNECE"})
    nPosStore := AScan(aHdSCE, {|x| x[2] == "CE_LOJA"})
    cSupplier := ""	 
    cStore := ""
    nX := 0
    nY := 0

    //-- Buscar os Fornecedores vencedores da cotação
    If nPosQuant > 0
        For nX := 1 To Len(aWin)
            For nY := 1 To Len(aWin[nX])
                If aWin[nX][nY][nPosQuant] > 0
                    AADD(aAux, aWin[nX][nY])
                EndIf
            Next nY	
        Next nX
    EndIf

    If Len(aAux) > 0
        //-- Agrupar vencedores por fornecedor 
        For nX := 1 To Len(aAux)
            
            cSupplier := aAux[nX][nPosSup]		
            cStore := aAux[nX][nPosStore]

            If AScan(aRet, {|x| x[1] + x[2] == cSupplier + cStore }) == 0
                AAdd(aData, cSupplier)
                AAdd(aData, cStore)
                
                For nY :=1 To Len(aAux)
                    If cSupplier == aAux[nY][nPosSup] .And. cStore == aAux[nY][nPosStore]
                        AAdd(aData, aAux[nY])
                    EndIf 
                Next nY

                AAdd(aRet, aData)
                aData := {}
            EndIf
        Next nX
    EndIf
	
Return aRet


/*/{Protheus.doc} ExecModCtr
	Carrega o modelo do CNTA300, seta a operacao como inclusao, ativa e preenche com os dados informados
    em <aContract> atraves da funcao <A161MdlCot>. Caso <aContract> contenha dados invalidos, exibe alerta.
@author juan.felipe
@since 08/08/2023
@return lRet, boolean, verdadeiro se gravado com sucesso.
@param aContract, array, contem o registro esperado pela funcao <LoadModCtr> 
@param aHdSCE, array, cabeçalho da SCE.
@param oModel300, object, modelo do CANTA300 (retornado por referência para que seja feita uma única instância).
/*/
Static Function ExecModCtr(aContract, aHdSCE, lCallPGC)
    Local lRet as Logical
    Local lHasErrorMessage As Logical
    Local nGravou as Numeric
    Local aError As Array
    Local cField As Character
    Local cTitle As Character
    Local cMessage As Character
    Local cSupName As Character
    Local cSupCode As Character
    Local cSupStore As Character
    Default aContract := {}
    Default aHdSCE := {}
    Default lCallPGC := .F.

    INCLUI := .T.

    //-- Inicializar as variáveis
    lRet := .F.
    aError := {}
    cField := ''
    cTitle := ''
    cMessage := ''
    cSupName := ''
    cSupCode := ''
    cSupStore := ''
    
    oModel300 := FWLoadModel("CNTA300")

    If !lCallPGC
        C300VldFixo(.T., .T.) //-- Seta .T. para indicar ao CNTA300 que é uma chamada do PGC, e deve validar o tipo fixo

        PGCReqFlds(oModel300, 'CN9MASTER', _aCN9Flds, .F.) //-- Remove obrigatoriedade dos modelos
        PGCReqFlds(oModel300, 'CNCDETAIL', _aCNCFlds, .F.)
        PGCReqFlds(oModel300, 'CNADETAIL', _aCNAFlds, .F.)
        PGCReqFlds(oModel300, 'CNBDETAIL', _aCNBFlds, .F.)
    EndIf

    oModel300:SetOperation(MODEL_OPERATION_INSERT)                                 
	oModel300:Activate()
	oModel300 := LoadModCtr(oModel300, aContract, aHdSCE)

    If lCallPGC //Processo NFC
        lHasErrorMessage := oModel300:HasErrorMessage()

        If !lHasErrorMessage
            nGravou := FWExecView (STR0006, "CNTA300", MODEL_OPERATION_INSERT ,, {||.T.},,,,,,, oModel300)
        EndIf
        
        If nGravou == 0 .Or. lHasErrorMessage
            If lRet := !lHasErrorMessage
                
                If lRet
                    If Type("__aGenContra") == "A" .And. aScan(__aGenContra, CN9->CN9_NUMERO) == 0
                        aAdd(__aGenContra, CN9->CN9_NUMERO)
                    EndIf
                    UpdateSC8(aContract, CN9->CN9_NUMERO, aHdSCE)
                EndIf
            Else
                aError := oModel300:GetErrorMessage()
                cField := AllTrim(aError[4])
                cMessage := AllTrim(aError[6]) + CRLF + CRLF + AllTrim(aError[7])

                If !Empty(cField)
                    cTitle := AllTrim(GetSX3Cache(cField, 'X3_TITULO'))
                    cMessage := STR0001 + '"' + cTitle + '" - ' + cMessage //-- Verifique o campo XXXX
                EndIf

                SA2->(DbSetOrder(1)) //-- A2_FILIAL+A2_COD+A2_LOJA

                cSupCode := aContract[1][_nPosSup]
                cSupStore := aContract[1][_nPosStore]

                If SA2->(MsSeek(FWxFilial('SA2') + cSupCode + cSupStore)) //-- Obtém nome do fornecedor
                    cSupName := AllTrim(SA2->A2_NOME)
                EndIf

                If Type("__aSupError") == "A" //-- Adiciona fornecedor do contrato que deu erro de gravação
                    __aSupError := {cSupCode, cSupStore}
                EndIf

                If _oJsonCtr['contractgenerationtype'] == '2'
                    cMessage := STR0002 + cSupName + CRLF + CRLF + cMessage //-- Erro no contrato do fornecedor XXXX
                EndIf

                MsgAlert(cMessage, AllTrim(aError[5]))
            EndIf

            oModel300:DeActivate()
            oModel300:Destroy()
            FreeObj(oModel300)
        EndIf
    Else //Processo Padrão
        If lRet := !oModel300:HasErrorMessage() .And. oModel300:VldData() .And. oModel300:CommitData()
            
            If lRet
                If Type("__aGenContra") == "A" .And. aScan(__aGenContra, CN9->CN9_NUMERO) == 0
                    aAdd(__aGenContra, CN9->CN9_NUMERO)
                EndIf
                UpdateSC8(aContract, CN9->CN9_NUMERO, aHdSCE)
            EndIf
        Else
            aError := oModel300:GetErrorMessage()
            cField := AllTrim(aError[4])
            cMessage := AllTrim(aError[6]) + ' ' + AllTrim(aError[7])

            If !Empty(cField)
                cTitle := AllTrim(GetSX3Cache(cField, 'X3_TITULO'))
                cMessage := STR0001 + '"' + cTitle + '" - ' + cMessage //-- Verifique o campo XXXX
            EndIf

            SA2->(DbSetOrder(1)) //-- A2_FILIAL+A2_COD+A2_LOJA

            cSupCode := aContract[1][_nPosSup]
            cSupStore := aContract[1][_nPosStore]

            If SA2->(MsSeek(FWxFilial('SA2') + cSupCode + cSupStore)) //-- Obtém nome do fornecedor
                cSupName := AllTrim(SA2->A2_NOME)
            EndIf

            If Type("__aSupError") == "A" //-- Adiciona fornecedor do contrato que deu erro de gravação
                __aSupError := {cSupCode, cSupStore}
            EndIf

            If _oJsonCtr['contractgenerationtype'] == '2'
                cMessage := STR0002 + cSupName + ' - ' + cMessage //-- Erro no contrato do fornecedor XXXX
            EndIf

            Help("", 1, AllTrim(aError[5]),, cMessage, 1, 0)
        EndIf

        oModel300:DeActivate()
        oModel300:Destroy()
        FreeObj(oModel300)
    EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} LoadModCtr()
    Função para carregar os dados para o modelo do CNTA300.
@param oModel300, Object, Objeto da CNTA300
@param aData, array, Array com resultado das cotações para a geração do contrato.
@param aHdSCE, array, cabeçalho da SCE.
@author juan.felipe
@since 08/08/2023
@version 1.0
@return lRet, Boolean, True se o objeto foi populado sem erros
/*/
//-------------------------------------------------------------------
Static Function LoadModCtr(oModel300, aData, aHdSCE)
    Local aArea		as Array
    Local aAreaSC1 	as Array
    Local aServ		as Array
    Local aContracts as Array

    Local cItem		 as Char
    Local cItPla	 as Char
    Local cTpPla	 as Char
    Local cItemRat	 as Char
    Local cCpEntAdic as Char
    Local cSeekCNZ	 as Char

    Local lRateio	 as Logical
    Local lItem 	 as Logical
    Local lAddPlaSv  as Logical
    Local lSetCond   as Logical

    Local nPosNumCot as Numeric
    Local nPosSup   as Numeric
    Local nPosStore	 as Numeric
    Local nPosItCot  as Numeric
    Local nPosNPro   as Numeric
    Local nPosQuant  as Numeric
    Local nQtEntAdic as Numeric
    Local nI 		 as Numeric
    Local nX		 as Numeric
    Local nY		 as Numeric
    Local nW		 as Numeric
    Local nPosCtr    as Numeric

    Local oModelCN9 as Object
    Local oModelCNA as Object
    Local oModelCNB as Object
    Local oModelCNC as Object
    Local oModelCNZ as Object
    Local oJsonCtr as Object

    Default oModel300 := Nil
    Default aData := {}
    Default aHdSCE := {}

    aArea := GetArea( )
    aAreaSC1 := SC1->( GetArea( ) )
    aServ := {}
    aContracts := {}

    cItem := Replicate("0", (TamSx3('CNB_ITEM')[1]))
    cItPla := Replicate("0",(TamSx3('CNA_NUMERO')[1]))
    cTpPla := SuperGetMV("MV_TPPLA", .T., "")
    cItemRat := ""
    cCpEntAdic := ""
    cSeekCNZ := ""

    lSetCond := .T.
    lRateio := .F.
    lItem := .F.
    lAddPlaSv := .F.

    nPosNumCot := AScan(aHdSCE, {|x| x[2] == "CE_NUMCOT"})
    nPosSup := AScan(aHdSCE, {|x| x[2] == "CE_FORNECE"})
    nPosStore := AScan(aHdSCE, {|x| x[2] == "CE_LOJA"})
    nPosItCot := AScan(aHdSCE, {|x| x[2] == "CE_ITEMCOT"})
    nPosNPro := AScan(aHdSCE, {|x| x[2] == "CE_NUMPRO"})
    nPosQuant := AScan(aHdSCE, {|x| x[2] == "CE_QUANT"})
    nQtEntAdic := 0
    nI := 0
    nX := 0
    nY := 0
    nW := 0

    oModelCN9 := oModel300:GetModel('CN9MASTER')
    oModelCNA := oModel300:GetModel('CNADETAIL')
    oModelCNB := oModel300:GetModel('CNBDETAIL')
    oModelCNC := oModel300:GetModel('CNCDETAIL')
    oModelCNZ := oModel300:GetModel('CNZDETAIL')
    oJsonCtr := JsonObject():New()

    aContracts := _oJsonCtr['contracts']

    If _oJsonCtr['contractgenerationtype'] == '2' //-- Quando gerado um contrato por fornecedor, deve buscar o contrato referente ao fornecedor

        nPosCtr := aScan(aContracts, {|x| AllTrim(x['c8_fornece']) + AllTrim(x['c8_loja']) == AllTrim(aData[1][_nPosSup]) + AllTrim(aData[1][_nPosStore])})
        
        If nPosCtr > 0
            oJsonCtr := aContracts[nPosCtr]
        EndIf
    Else
        oJsonCtr := aContracts[1]
    EndIf

    //-- Popular o modelo do contrato
    oModelCN9:SetValue('CN9_ESPCTR', "1")//Contrato de Compra
    oModelCN9:SetValue('CN9_DTINIC', dDataBase)
    oModelCN9:SetValue('CN9_UNVIGE', "4")//Ideterminada
    oModelCN9:SetValue('CN9_NUMCOT', SC8->C8_NUM)
    oModelCN9:SetValue('CN9_TPCTO' , oJsonCtr['cn9_tpcto'])

    If !oModel300:HasErrorMessage()
        cItPla	:= soma1(cItPla)

        //-- Verificar se há entidades contábeis adicionais criadas no ambiente
        nQtEntAdic := CtbQtdEntd()

        For nX := 1 To Len(aData)
            
            cItem	:= Replicate("0", (TamSx3('CNB_ITEM')[1]))
            cItem	:= soma1(cItem)
            
            If nX > 1
                CNTA300BlMd(oModelCNA, .F.)
                oModelCNC:AddLine()
                oModelCNA:AddLine()
                cItPla	:= soma1(cItPla)
            Endif
            
            oModelCNC:SetValue('CNC_CODIGO',aData[nX][_nPosSup])
            oModelCNC:SetValue('CNC_LOJA',aData[nX][_nPosStore])
            oModelCNA:SetValue('CNA_FORNEC',aData[nX][_nPosSup])
            oModelCNA:SetValue('CNA_LJFORN',aData[nX][_nPosStore])
            oModelCNA:SetValue('CNA_TIPPLA',cTpPla)
            oModelCNA:SetValue('CNA_NUMERO',cItPla)

            lItem := .F.

            For nY:=3 To Len(aData[nX])
            
                SC1->(dbSetOrder(1))
                SC8->(dbSetOrder(1))//C8_NUM+CO_FORNECE+C8_LOJA+C8_ITEM+C8_NUMPRO+C8_ITEMGRD
                SC8->(DbSeek(xFilial('SC8')+aData[nX][nY][nPosNumCot]+aData[nX][nY][nPosSup]+aData[nX][nY][nPosStore]+aData[nX][nY][nPosItCot]+aData[nX][nY][nPosNPro]))		    
                
                If lSetCond
                    oModelCN9:SetValue('CN9_CONDPG', SC8->C8_COND) //Cond. Pag
                    oModelCN9:SetValue('CN9_MOEDA' , SC8->C8_MOEDA) //Moeda	
                    lSetCond := .F.
                EndIf

                IF Posicione("SB5",1,xFilial("SB5")+ SC8->C8_PRODUTO,"B5_TIPO") <> '2'
                    lItem := .T.
                    If !Empty( oModelCNB:GetValue('CNB_PRODUT') )
                        CNTA300BlMd(oModelCNB, .F.)
                        oModelCNB:AddLine()
                        cItem	:= Soma1(cItem)
                    EndIf	
                
                    oModelCNB:SetValue('CNB_ITEM',cItem)
                    oModelCNB:SetValue('CNB_PRODUT',SC8->C8_PRODUTO)
                    oModelCNB:SetValue('CNB_QUANT',aData[nX][nY][nPosQuant])
                    oModelCNB:SetValue('CNB_NUMSC',SC8->C8_NUMSC)
                    oModelCNB:SetValue('CNB_ITEMSC',SC8->C8_ITEMSC)
                    oModelCNB:SetValue('CNB_VLUNIT',SC8->C8_PRECO)
                    oModelCNB:SetValue('CNB_VLTOTR',SC8->C8_TOTAL)
                    oModelCNB:SetValue('CNB_IDENT',SC8->C8_IDENT)
                    oModelCNB:SetValue('CNB_DESC',((SC8->C8_VLDESC/SC8->C8_TOTAL)*100))
                    oModelCNB:SetValue('CNB_DTPREV', SC8->C8_DATPRF)

                    //-- Verificar se possui rateio
                    SCX->(DbSetOrder(1))
                    lRateio := SCX->(dbSeek(cSeekCNZ := xFilial("SCX")+SC8->(C8_NUMSC+C8_ITEMSC)))
                
                    If lRateio
                        cItemRat := Replicate("0", (TamSx3('CNZ_ITEM')[1]))
                        While SCX->(!Eof()) .And. SCX->(CX_FILIAL+CX_SOLICIT+CX_ITEMSOL) == cSeekCNZ 
                            If cItemRat <> Replicate("0", (TamSx3('CNZ_ITEM')[1]))
                                oModelCNZ:AddLine()		
                            EndIf
                            cItemRat := Soma1(cItemRat)
                                    
                            oModelCNZ:SetValue('CNZ_ITEM',cItemRat)
                            oModelCNZ:SetValue('CNZ_PERC',SCX->CX_PERC)
                            oModelCNZ:SetValue('CNZ_CC',SCX->CX_CC)
                            oModelCNZ:SetValue('CNZ_CONTA',SCX->CX_CONTA)
                            oModelCNZ:SetValue('CNZ_ITEMCT',SCX->CX_ITEMCTA)
                            oModelCNZ:SetValue('CNZ_CLVL',SCX->CX_CLVL)
                            
                            //-- Se tem entidades contábeis adicionais criadas (por padrão, já existem 4 entidades no Protheus), então informa as mesmas para o contrato 
                            If nQtEntAdic > 4
                                For nI := 5 To nQtEntAdic
                                    cCpEntAdic := "EC" + StrZero( nI, 2 ) + "DB"
                                    oModelCNZ:SetValue( ( "CNZ_" + cCpEntAdic ), &( "SCX->CX_" + cCpEntAdic ) )
                                    
                                    cCpEntAdic := "EC" + StrZero( nI, 2 ) + "CR"
                                    oModelCNZ:SetValue( ( "CNZ_" + cCpEntAdic ), &( "SCX->CX_" + cCpEntAdic ) )
                                Next nI
                            EndIf
                            
                            SCX->(dbSkip())			
                        EndDo			
                    Else

                        SC1->(dbSeek(xFilial("SC1")+SC8->(C8_NUMSC+C8_ITEMSC)))
                        oModelCNB:SetValue('CNB_CC',SC1->C1_CC)
                        oModelCNB:SetValue('CNB_CLVL',SC1->C1_CLVL)
                        oModelCNB:SetValue('CNB_CONTA',SC1->C1_CONTA)
                        oModelCNB:SetValue('CNB_ITEMCT',SC1->C1_ITEMCTA)
                        
                        //-- Se tem entidades contábeis adicionais criadas (por padrão, já existem 4 entidades no Protheus), então informa as mesmas para o contrato 
                        If nQtEntAdic > 4
                            For nI := 5 To nQtEntAdic
                                cCpEntAdic := "EC" + StrZero( nI, 2 ) + "DB"
                                oModelCNB:SetValue( ( "CNB_" + cCpEntAdic ), &( "SC1->C1_" + cCpEntAdic ) )
                                
                                cCpEntAdic := "EC" + StrZero( nI, 2 ) + "CR"
                                oModelCNB:SetValue( ( "CNB_" + cCpEntAdic ), &( "SC1->C1_" + cCpEntAdic ) )
                            Next nI
                        EndIf
                        
                    EndIf	
                Else
                    oModel300:SetErrorMessage(,,,, 'PGCNOSERV', STR0004) //-- A geração de contratos com produtos do tipo de serviço ainda esta em fase de desenvolvimento.
                    Exit                    
                EndIf       
            Next nY
            
            If oModel300:HasErrorMessage()
                Exit
            Endif

        Next nX

        oModelCNA:GoLine(1)
        oModelCNB:GoLine(1) 
        oModelCNC:GoLine(1) 
        oModelCNZ:GoLine(1) 

        If ExistFunc('CN300BlqCot')
            CN300BlqCot(oModel300)        
        EndIf
    EndIf

    RestArea(aAreaSC1)	
    RestArea(aArea)

    FwFreeArray(aAreaSC1)
    FwFreeArray(aArea)
Return oModel300

//-------------------------------------------------------------------
/*/{Protheus.doc} UpdateSC8()
    Função para atualização da cotação após geração do contrato
@param aData, Array, Vetor com o resultado das cotações para a geração do contrato
@param cContract, character, número do contrato.
@param aHdSCE, array, cabeçalho da SCE.
@author juan.felipe
@since 08/08/2023
@version 1.0
@return lRet
/*/
//-------------------------------------------------------------------
Static Function UpdateSC8(aData, cContract, aHdSCE)
    Local aArea 	    as Array
	Local aAreaSC8	    as Array
    Local aAreaSCE      as Array
    Local cFilSCE       as Character
	Local cKeySC8       as Character
	Local lPrjCni	    as Logical
	Local nX 		    as Numeric
	Local nY 		    as Numeric
	Local nPosRec	    as Numeric
    Local nPosNumPed    as Numeric
    Local nPosItemPed   as Numeric
    Local nPosNumCtr    as Numeric

    Default aData := {}
    Default cContract := ""
    Default aHdSCE := {}
	
    //-- Inicializar as variáveis
    DbSelectArea("SCE")
    aArea := GetArea()
	aAreaSC8 := SC8->(GetArea())
    aAreaSCE := SCE->(GetArea())
    cFilSCE := xFilial("SCE")
	lPrjCni := Iif(FindFunction("ValidaCNI"), ValidaCNI(), .F.)
	nX := 0
	nY := 0
	nPosRec := aScan(aHdSCE, {|x| x[2] == "CE_REC_WT"})
    nPosNumPed := FieldPos("CE_NUMPED")
    nPosItemPed := FieldPos("CE_ITEMPED")
    nPosNumCtr := FieldPos("CE_NUMCTR")

    SCE->(DbSetOrder(1))

	For nX := 1 To Len(aData)
		For nY := 3 To Len(aData[nX])
			//-- Posicionar no registro vencedor
			SC8->(DbGoTo(aData[nX][nY][nPosRec]))
			
			cKeySC8 := SC8->C8_FILIAL + SC8->C8_NUM + SC8->C8_IDENT
			
			//-- Gravar C8_NUMCON para registro vencedor e inibe utilização de C8_NUMPED
			RecLock("SC8",.F.)
				SC8->C8_NUMCON  := cContract
				SC8->C8_NUMPED  := Replicate("X", Len(SC8->C8_NUMPED))
                SC8->C8_ITEMPED := Replicate("X", Len(SC8->C8_ITEMPED))
			SC8->(MsUnlock())

            If nPosNumPed > 0 .and. nPosItemPed > 0 .And. nPosNumCtr > 0
                UpdateSCE(SC8->C8_NUM, SC8->C8_ITEM, SC8->C8_PRODUTO, SC8->C8_FORNECE, SC8->C8_LOJA, SC8->C8_NUMPED, SC8->C8_ITEMPED, SC8->C8_NUMCON)
            EndIf
			
            //-- Gerar log de inclusao de contrato via analise de cotacao
			If lPrjCni				
				RSTSCLOG("CTR", 4)
			EndIf

            //-- Percorrer os demais registros da chave (não vencedores) e inibir a utilização de C8_NUMCON e C8_NUMPED
			SC8->(DbSetOrder(4)) //-- C8_FILIAL+C8_NUM+C8_IDENT+C8_PRODUTO
			If SC8->(MsSeek(cKeySC8, .T.))
				While SC8->(!Eof()) .And. (SC8->C8_FILIAL + SC8->C8_NUM + SC8->C8_IDENT == cKeySC8)
					If Empty(SC8->C8_NUMCON) .And. Empty(SC8->C8_NUMPED)
						RecLock("SC8",.F.)
							SC8->C8_NUMCON := Replicate("X", Len(SC8->C8_NUMCON))
							SC8->C8_NUMPED := Replicate("X", Len(SC8->C8_NUMPED))
                            SC8->C8_ITEMPED := Replicate("X", Len(SC8->C8_ITEMPED))
						SC8->(MsUnlock())	
					EndIf
					SC8->(DbSkip())
				EndDo
			EndIf
		Next nY
	Next nX
	
    //-- Restaurar areas
    SCE->(RestArea(aAreaSCE))
	SC8->(RestArea(aAreaSC8))
	RestArea(aArea)

	//-- Limpar a memória
    FwFreeArray(aArea)
    FwFreeArray(aAreaSC8)
Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} UpdateSCE()
    Função para atualizar SCE, após geração do contrato, para que cada contrato seja gravado corretamente na SCE, com seus dados e quantidades.
@param C8NUM, String, Número do contrato.
@param C8Item, string, número do item da cotação.
@param C8Produto, string, Produto.
@param C8Fornece, String, código do fornecedor.
@param C8Loja, string, número da loja.
@param C8Produto, string, Produto.
@param C8NumPed, String, Número do pedido.
@param C8NumCon, string, Número do Contrato.
@author renan.martins
@since 01/2024
@version 1.0
@return Nil - Nulo
/*/
//-------------------------------------------------------------------
static function UpdateSCE(C8Num, C8Item, C8Produto, C8Fornece, C8Loja, C8NumPed, C8ItemPed, C8NumCon)
    local cQuery        as character
    local oQuery        as Object
    local cAliasTemp    as character
    default C8Num       := ""
    default C8Item      := ""
    default C8Produto   := ""
    default C8Fornece   := ""
    default C8Loja      := ""
    default C8NumPed    := ""
    default C8ItemPed   := ""
    default C8NumCon    := ""

    cQuery := "  SELECT R_E_C_N_O_ REC "
    cQuery += " FROM "+ RetSQLName("SCE") +" SCE"
    cQuery += " WHERE SCE.CE_FILIAL = ?"
    cQuery += "     AND SCE.CE_NUMCOT = ?"
    cQuery += "     AND SCE.CE_ITEMCOT = ?"
    cQuery += "     AND SCE.CE_PRODUTO = ?"
    cQuery += "     AND SCE.CE_FORNECE = ?"
    cQuery += "     AND SCE.CE_LOJA = ? "
    cQuery += "     AND SCE.CE_NUMCTR = ?" 
    cQuery += "     AND ( (SCE.CE_NUMPED = ? AND SCE.CE_ITEMPED = ?) "
    cQuery += "           OR (SCE.CE_NUMPED = ? AND SCE.CE_ITEMPED = ?) )"
    cQuery += "     AND SCE.D_E_L_E_T_ = ' '"

    oQuery := FWPreparedStatement():New(cQuery)

    oQuery:SetString(1, FWxFilial('SC7'))
    oQuery:SetString(2, C8Num)
    oQuery:SetString(3, C8Item)
    oQuery:SetString(4, C8Produto)
    oQuery:SetString(5, C8Fornece)
    oQuery:SetString(6, C8Loja)
    oQuery:SetString(7, space(TamSX3("CE_NUMCTR")[1]))
    oQuery:SetString(8, space(TamSX3("CE_NUMPED")[1]))
    oQuery:SetString(9, space(TamSX3("CE_ITEMPED")[1]))
    oQuery:SetString(10, C8NumPed)
    oQuery:SetString(11, C8ItemPed)

    cAliasTemp := GetNextAlias()
    cAliasTemp := MpSysOpenQuery(oQuery:getFixQuery())
    
    if !(cAliasTemp)->(Eof())
        SCE->( DBGOTO((cAliasTemp)->REC))
        SCE->(Reclock("SCE", .F.))
            SCE->CE_NUMPED  := C8NumPed
            SCE->CE_ITEMPED := C8ItemPed
            SCE->CE_NUMCTR  := C8NumCon
        SCE->(MsUnlock())  
    endif
    (cAliasTemp)->(DbCloseArea())
    FreeObj(oQuery)

return nil

/*/{Protheus.doc} NFCRegSup()
    Função que registra os fornecedores participantes da cotação por meio do MATA020.
@param oWebChannel, objeto de comunicação com o app do NFC.
@param oJsonSup, object, objeto Json com os dados da cotação ex: {'c8_num': 'XXX', 'c8_fornome': 'YYYY'}
@author juan.felipe
@since 21/02/2024
@version 1.0
@return lRet, logical, indica se pode ativar o modelo.
/*/
Function NFCRegSup(oWebChannel, oJsonSup)
    Local lRet As Logical
    Local oJson As Object
    Local oModel As Object
    Local aAreas As Array
    Local aItems As Array
    Local nX As Numeric
    Local nRecord As Numeric
    Local nLen As Numeric
    Local nLenCorpName As Numeric
    Local cModel As Character
    Local cQuotationCode As Character
    Local cCorporateName As Character
    Local cBranchSC8 As Character

    Default oWebChannel := Nimnnnnnml
    Default oJsonSup :=  JsonObject():New()

    oJson := JsonObject():New()
    cModel := 'MATA020M'
    aItems := oJsonSup['items']
    aAreas := {SA2->(GetArea()), SC8->(GetArea()), GetArea()}
    cQuotationCode := oJsonSup['c8_num']
    nLen := Len(aItems)
    lRet := .F.
    cBranchSC8 := FWxFilial('SC8')
    
    nLenCorpName := TamSX3('C8_FORNOME')[1]

    SA2->(dbSetOrder(1)) //-- A2_FILIAL+A2_COD+A2_LOJA
    SC8->(dbSetOrder(8)) //-- C8_FILIAL+C8_NUM+C8_FORNECE+C8_LOJA+C8_FORNOME
    

    For nX := 1 To Len(aItems)
        cCorporateName := PadR(aItems[nX]['corporatename'], nLenCorpName)

        If Empty(cCorporateName)
            cCorporateName := PadR(aItems[nX]['suppliername'], nLenCorpName)
        EndIf

        oJson['c8_num'] := cQuotationCode
        oJson['c8_fornome'] := cCorporateName
        A020SetNFC(oJson, .T.)

        oModel := FWLoadModel('MATA020M')
        
        if oModel == Nil //Verifico se está NIL, indicando que não existe localização. Se ocorrer, chamo a model MATA020, para gravar os dados
            oModel := FWLoadModel('MATA020')
            cModel := 'MATA020'
        endif

        oModel:SetOperation(MODEL_OPERATION_INSERT)
        oModel:GetModel("SA2MASTER"):GetStruct():SetProperty('A2_NOME', MODEL_FIELD_WHEN, {||.F.})
	    oModel:Activate()

        oModel:LoadValue('SA2MASTER', 'A2_NOME', AllTrim(cCorporateName))

        Begin Transaction
            Inclui := .T.
            nRecord := FWExecView ("Inclusão fornecedor NFC" + ' - ' + AllTrim(Str(nX)) + '/' + AllTrim(Str(nLen)), cModel, MODEL_OPERATION_INSERT ,, {||.T.},,,,,,, oModel) 

            If lRet := nRecord != 0
                DisarmTransaction()
            EndIf
        End Transaction

        oJsonSup['supplier'] := JsonObject():New()
        oJsonSup['supplier']['a2_cod' ] := SA2->A2_COD
        oJsonSup['supplier']['a2_loja'] := SA2->A2_LOJA
        oJsonSup['supplier']['a2_nome'] := SA2->A2_NOME
        oJsonSup['supplier']['a2_est' ] := SA2->A2_EST
        oJsonSup['supplier']['a2_mun' ] := SA2->A2_MUN

        oWebChannel:AdvPLToJS('supplierUpdated', oJsonSup:ToJson())

        oModel:DeActivate()
        oModel:Destroy()
        FreeObj(oModel)
    Next nX

    aEval(aAreas, {|x| RestArea(x), FwFreeArray(x)})
Return lRet

/*/{Protheus.doc} NFCRegSup()
    Função valida/atualiza os fornecedores da cotação inseridos via MATA020.
@param cQuotationCode, character, código da cotação.
@param cCorporateName, character, nome do fornecedor.
@param lValidate, logical,  nome do fornecedor.
@param oModel, object, modelo de dados do MATA020.
@author juan.felipe
@since 21/02/2024
@version 1.0
@return lRet, logical, indica se pode ativar o modelo.
/*/
Function NFCUpdCot(cQuotationCode, cCorporateName, lValidate, oModel)
    Local lRet As Logical
    Local cKey As Character
    Local cLastKey As Character
    Local cBranchSC8 As Character
    Local cSupCode As Character
    Local cSupStore As Character
    Default cQuotationCode := ''
    Default cCorporateName := ''
    Default lValidate := .F.
    Default oModel := FwModelActive()

    cBranchSC8 := FWxFilial('SC8')
    cSupCode := Space(TamSX3('C8_FORNECE')[1])
    cSupStore := Space(TamSX3('C8_LOJA')[1])

    If lRet := !lValidate .And. SC8->(MsSeek(cBranchSC8+cQuotationCode+cSupCode+cSupStore+cCorporateName)) // Posiciona na Cotação do Fornecedor
        A161AtuCot(SC8->C8_FORNOME, SA2->A2_COD, SA2->A2_LOJA) //-- Atualiza cotação do fornecedor para receber o código e loja
    ElseIf lRet := SC8->(MsSeek(cBranchSC8+cQuotationCode))
        While SC8->(!Eof()) .And. SC8->(C8_FILIAL+C8_NUM+C8_FORNOME) <> cBranchSC8+cQuotationCode+cCorporateName
            cLastKey := PadR(SC8->C8_FORNECE, TamSX3('A2_COD')[1]) + PadR(SC8->C8_LOJA, TamSX3('A2_LOJA')[1])
            SC8->(DbSkip())
        EndDo

        If !Empty(SC8->(C8_FORNECE+C8_LOJA)) .Or. !Empty(cLastKey) //-- Valida se a cotação já teve fornecedor cadastrado
            oModel:SetErrorMessage(,,,, 'NFCANLHASREG', STR0005) //-- Esta proposta já teve um fornecedor cadastrado.
            lRet := .F.

            cKey := PadR(SC8->C8_FORNECE, TamSX3('A2_COD')[1]) + PadR(SC8->C8_LOJA, TamSX3('A2_LOJA')[1])
            cKey := Iif(Empty(cLastKey) .Or. (SC8->C8_NUM == cQuotationCode .And. SC8->C8_FORNOME == cCorporateName), cKey, cLastKey)

            SA2->(MsSeek(FWxFilial('SA2') + cKey)) //-- Posiciona na SA2 para retornar os dados do fornecedor
        EndIf
    EndIf
Return lRet

/*{Protheus.doc} NFCPcoVld
    Valida bloqueios na integracao com SIGAPCO.
@author juan.felipe
@since 03/06/2025
@version 1.0
@param lDeleta, logical, operação de deleção.
@param lPcoTot, logical, indica se totaliza por meio do campo C8_TOTPCO.
@param lVldSC1, logical, indica se valida a SC1.
@param cMessage, character, mensagem de erro retornada quando a execução é via ExecAuto.
@return lRetorno, logical, validação realizada corretamente.
*/
Function NFCPcoVld(lDeleta, lPcoTot, lVldSC1, cMessage)
    Local aAreaAnt	:= GetArea()
    Local lRetPCO	:= .T.
    Local lRetorno	:= .T.
    Default lDeleta  := .F.
    Default lPcoTot  := .F.
    Default lVldSC1 := .T.
    Default cMessage  := ''

    // Verifica se Solicitacao de Compra possui rateio e gera lancamentos no PCO
    If lVldSC1
        SCX->(dbSetOrder(1))
        If SCX->(MsSeek(xFilial("SCX")+SC1->(C1_NUM+C1_ITEM)))
            While SCX->(!Eof()) .And. SCX->(CX_FILIAL+CX_SOLICIT+CX_ITEMSOL) == xFilial("SCX")+SC1->(C1_NUM+C1_ITEM)
                lRetPCO := PcoVldLan('000051', '03',,, lDeleta,, @cMessage)	// Solicitacao de compras - Rateio por CC na cotacao

                If !lRetPCO
                    lRetorno := .F.
                    Exit
                EndIf

                SCX->(DbSkip())
            End
        EndIf
    Endif

    // Inclusao de pedido de compras por cotacao"
    If lRetorno .And. !lPcoTot .And. !lVldSC1
        lRetPCO := PcoVldLan('000052', '02',,, lDeleta,, @cMessage)

        If !lRetPCO
            lRetorno := .F.
        EndIf
    EndIf

    RestArea(aAreaAnt)
Return lRetorno

/*{Protheus.doc} NFCPcoTot
    Verifica se o bloqueio utiliza o campo de total da cotação (C8_TOTPCO).
@author juan.felipe
@since 03/06/2025
@version 1.0
@return nField, numeric, -1=Nenhum campo; 0=Campo desconhecido; 1=Totaliza PCO pelo campo C8_TOTPCO; 2=Totaliza PCO pelo campo C8_ITEMPCO
*/
Function NFCPcoTot()
    Local nField As Numeric
	Local cPcoVtot As Character

    nField := -1

    dbSelectArea("AKI")
    cPcoVtot := ALLTRIM(GetAdvFval("AKI","AKI_VALOR1",xFilial("AKI") + "0000520201" ,1))

    If !Empty(cPcoVtot)
        If "C8_TOTPCO" $ UPPER(cPcoVtot)
            nField := 1
        ElseIf "C8_ITEMPCO" $ UPPER(cPcoVtot)
            nField := 2
        Else
            nField := 0
        EndIf
    EndIf
Return nField
