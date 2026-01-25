#Include "FINA060CTB.CH"
#Include "Protheus.ch"

Static __lValTit := Nil
Static __oQuery  := Nil

/*/{Protheus.doc} F060VldCtb
Rotina que indica se permite ou não a contabilização offline das rotinas de transferência.

@version    12.1.23/12.1.25/12.1.27
@author     Rafael Riego
@since      12/06/2020
@return     logical, retorno lógico informando se permite contabilizr offline as rotinas de transferência
/*/
Function F060VldCtb() As Logical

    Local aPergunte     As Array

    Local lCtbOfflin    As Logical
    
    Local nEnt          As Numeric 

    Local oFwSX1Util    As Object

    lCtbOfflin := .F.

    If GetRPORelease() > "12.1.027"
        lCtbOfflin := .T.
    ElseIf FwAliasInDic("FWI", .F.)

        If FindFunction("F060CtbOff") .And. FindFunction("F061CtbOff") .And. FindFunction("F200CtbOff") .And. FindFunction("F590CtbOff")
            aPergunte := {}
            oFwSX1Util := FwSX1Util():New()
            
            Begin Sequence
                //Valida pergunta do FINA06X
                oFwSX1Util:AddGroup("FIN060")
                oFwSX1Util:SearchGroup()
                aPergunte := oFwSX1Util:GetGroup("FIN060")

                If !(Len(aPergunte) > 1 .And. Len(aPergunte[2]) > 13 .And. Upper(AllTrim(aPergunte[2][14]:CX1_VAR01)) == "MV_PAR14")
                    Break
                EndIf

                //Valida pergunta do FINA06X (Cancelamento do Borderô)
                oFwSX1Util:AddGroup("AFIC60") //TODO verificar
                oFwSX1Util:SearchGroup()
                aPergunte := oFwSX1Util:GetGroup("AFIC60")

                If !(Len(aPergunte) > 1 .And. Len(aPergunte[2]) > 4 .And. Upper(AllTrim(aPergunte[2][5]:CX1_VAR01)) == "MV_PAR05")
                    Break
                EndIf
 
                //Valida pergunta do FINA200
                oFwSX1Util:AddGroup("AFI200")
                oFwSX1Util:SearchGroup()
                aPergunte := oFwSX1Util:GetGroup("AFI200")

                If !(Len(aPergunte) > 1 .And. Len(aPergunte[2]) > 10 .And. Upper(AllTrim(aPergunte[2][11]:CX1_VAR01)) == "MV_PAR11")
                    Break
                EndIf

                //Valida pergunta do FINA590
                oFwSX1Util:AddGroup("FIN590")
                oFwSX1Util:SearchGroup()
                aPergunte := oFwSX1Util:GetGroup("FIN590")

                If !(Len(aPergunte) > 1 .And. Iif(cPaisLoc == "BRA", Len(aPergunte[2]) > 4, Len(aPergunte[2]) == 4) .And. Iif(cPaisLoc == "BRA", Upper(AllTrim(aPergunte[2][5]:CX1_VAR01)) == "MV_PAR05", Upper(AllTrim(aPergunte[2][4]:CX1_VAR01)) == "MV_PAR05"))                                
                    Break
                EndIf

                lCtbOfflin := .T.

            End Sequence

            FwFreeArray(aPergunte)
            FreeObj(oFwSX1Util)
        EndIf
	EndIf

    If lCtbOfflin
        // Valida se o SE1 possui o mesmo compartilhamento da FWI
        For nEnt := 1 To 3
            If FwModeAccess("SE1", nEnt) <> FwModeAccess("FWI", nEnt)
                Help(' ', 1, STR0001,,STR0002, 2, 0,,,,,, {STR0003})
                // "Atenção"
                // "A tabela SE1 está com compartilhamento diferente da tabela FWI
                // "Para que o processo de contabilização Off-line da alteração da situação de cobrança possa ocorrer
                // , ajuste a tabela FWI para que tenha o mesmo compartilhamento de SE1 para Empresa, Unidade e Filial"
                lCtbOfflin := .F. 
            EndIf
        Next nEnt
    EndIf 

Return lCtbOfflin

/*/{Protheus.doc} FinAGrvFWI
Rotina que indica se permite ou não a contabilização offline das rotinas de transferência.

Sempre é necessário estar com a SE1 posicionada. Caso seja PIX deve estar com a F71 posicionada também.

@version    12.1.23/12.1.25/12.1.27
@author     Rafael Riego
@since      12/06/2020
@param      aFWI, array, array contendo os dados que serão inseridos na tabela FWI, sendo:
            [01] = FWI_LA ('S' ou 'N')
            [02] = FWI_LANPAD (Lançamento Padrão utilizado)
            [03] = FWI_VALOR (Valor da Movimentação)
            [04] = FWI_DESCON (Desconto da Movimentação)
            [05] = FWI_IOF (Valor do IOF)
            [06] = FWI_SITUAC (Carteira Atual)
            [07] = FWI_SITANT (Carteira Anterior)
            [08] = FWI_BCOANT (Portador Anterior)
            [09] = FWI_AGEANT (Agência Anterior)
            [10] = FWI_CONANT (Número da Conta Anterior)
            [11] = FWI_CONTRA (Contrato)
            [12] = FWI_IDMOV (Id da Movimentação na FK5)
            [13] = FWI_NUMBOR (Número do Borderô)
            [14] = FWI->FWI_VLRBOR (Valor do Borderô)
            [15] = FWI->FWI_DESTIT (Vlr do desconto do título)
            [16] = FWI->FWI_IOFTIT (IOF Título)

            aPix,  array, array contendo os dados pertinentes ao PIX, sendo:
            [01] = Título Pix (.T. ou .F.)
            [02] = Estorno de Pix (.T. ou .F.)
            aRecFwi,  array, para gravar os R_E_C_N_O_ dos cancelamentos dos bordero com carteira descontada
            
/*/
Function FinAGrvFWI(aFWI As Array, aPix As Array, aRecFwi As Array)

    Local cBanAtu As Character
    Local cAgeAtu As Character
    Local cConAtu As Character
    Local lPix As Logical    

    Default aFWI    := {}
    Default aPix    := {.F.,.F.}
    Default aRecFwi := {} 

    

    If __lValTit == Nil //-- Valores por título na operação de borderô de cobrança descontada
        __lValTit := FWI->(FieldPos("FWI_VLRBOR"))>0 .And. FWI->(FieldPos("FWI_DESTIT"))>0 .And. FWI->(FieldPos("FWI_IOFTIT"))>0
    EndIF

    lPix     := aPix[1]
    lCancPix := aPix[2]

    If lPix .and. !lCancPix
        cBanAtu := F71->F71_CODBAN
        cAgeAtu := F71->F71_AGENCI
        cConAtu := F71->F71_NUMCON
    Else
        cBanAtu := SE1->E1_PORTADO
        cAgeAtu := SE1->E1_AGEDEP
        cConAtu := SE1->E1_CONTA
    EndIf
    
    If Len(aFWI) >= 13
        RecLock("FWI", .T.)
        FWI->FWI_FILIAL := FwXFilial("FWI")
        FWI->FWI_PREFIX := SE1->E1_PREFIXO
        FWI->FWI_NUMERO := SE1->E1_NUM
        FWI->FWI_PARCEL := SE1->E1_PARCELA
        FWI->FWI_TIPO   := SE1->E1_TIPO
        FWI->FWI_CLIENT := SE1->E1_CLIENTE
        FWI->FWI_LOJA   := SE1->E1_LOJA
        FWI->FWI_SEQ    := RetProxSeq()
        FWI->FWI_FILORI := SE1->E1_FILORIG
        FWI->FWI_DTMOVI := dDataBase
        FWI->FWI_LA     := aFWI[01]
        FWI->FWI_LANPAD := aFWI[02]
        FWI->FWI_VALOR  := aFWI[03]
        FWI->FWI_VLRORI := SE1->E1_VALOR
        FWI->FWI_DESCON := aFWI[04]
        FWI->FWI_IOF    := aFWI[05]
        FWI->FWI_SITUAC := aFWI[06]
        FWI->FWI_SITANT := aFWI[07]
        FWI->FWI_BANCO  := cBanAtu
        FWI->FWI_AGENCI := cAgeAtu
        FWI->FWI_CONTA  := cConAtu
        FWI->FWI_BCOANT := aFWI[08]
        FWI->FWI_AGEANT := aFWI[09]
        FWI->FWI_CONANT := aFWI[10]
        FWI->FWI_CONTRA := aFWI[11]
        FWI->FWI_IDMOV  := aFWI[12]
        FWI->FWI_NUMBOR := aFWI[13]
        If lPix .and. FWI->(FieldPos("FWI_IDF71")) > 0
            FWI->FWI_IDF71 := F71->F71_IDTRAN
        EndIf
        If __lValTit .And. Len(aFWI) > 13
            FWI->FWI_VLRBOR := aFWI[14]
            FWI->FWI_DESTIT := aFWI[15]
            FWI->FWI_IOFTIT := aFWI[16]            
        EndIF
        FWI->(MsUnlock())        
        AAdd( aRecFwi, FWI->(Recno()) )
    EndIf

Return Nil

/*/{Protheus.doc} RetProxSeq
Retorna a próxima sequência na tabela FWI se baseando na chave do título posicionado.

@version    12.1.23/12.1.25/12.1.27
@author     Rafael Riego
@since      12/06/2020
@return     character, próxima sequência da tabela FWI
/*/
Static Function RetProxSeq() As Character

    Local cProxSeq  As Character
    Local cQuery    As Character
    Local cUltSeq   As Character

    Local nTamSeq   As Numeric

    cQuery := " SELECT MAX(FWI_SEQ) MAXSEQ"
    cQuery += " FROM " + RetSQLName("FWI")
    cQuery += " WHERE FWI_FILIAL = '" + FwXFilial("FWI") + "'"
    cQuery += "   AND D_E_L_E_T_ = ' '"
    cQuery += "   AND FWI_PREFIX = '" + SE1->E1_PREFIXO + "' "
    cQuery += "   AND FWI_NUMERO = '" + SE1->E1_NUM + "' "
    cQuery += "   AND FWI_PARCEL = '" + SE1->E1_PARCELA + "' "
    cQuery += "   AND FWI_TIPO   = '" + SE1->E1_TIPO + "' "
    cQuery += "   AND FWI_CLIENT = '" + SE1->E1_CLIENTE + "' "
    cQuery += "   AND FWI_LOJA   = '" + SE1->E1_LOJA + "' "

    cQuery := ChangeQuery(cQuery)

    cUltSeq := MPSysExecScalar(cQuery, "MAXSEQ")

    nTamSeq := TamSX3("FWI_SEQ")[1]

    If Empty(cUltSeq)
        cProxSeq := Soma1(Replicate("0", nTamSeq))
    Else
        cProxSeq := Soma1(cUltSeq)
    EndIf

Return cProxSeq

//---------------------------------------------------------------------------------------
/*/{Protheus.doc} FinAGetFWI

Retorna valores por título na operação de borderô de cobrança descontada

@param cFil, character, código da filial
@param cSeq, character, sequência da FWI
@param lValorBruto, logical,   Baixa valor liquido ou bruto

@author  Fabio Zanchim
@since  12/07/2023
@version 12.1.2210
@return aDados, array, valores por título na operação de inclusão do borderô
/*/
//---------------------------------------------------------------------------------------
Function FinAGetFWI(cFil As Character, cSeq As Character, lValorBruto as Logical) as Array

Local cQuery  as Character
Local cAlsFWI as Character
Local aDados  as Array

Default cFil := cFilAnt
Default cSeq := Replicate('Z', TamSX3("FWI_SEQ")[1])
Default lValorBruto := .F.

aDados := {0,0,0}

If __lValTit == Nil 
    __lValTit := FWI->(FieldPos("FWI_VLRBOR"))>0 .And. FWI->(FieldPos("FWI_DESTIT"))>0 .And. FWI->(FieldPos("FWI_IOFTIT"))>0
EndIF

iF __lValTit
	If __oQuery == Nil
		cQuery := "SELECT FWI_VLRBOR, FWI_VALOR, FWI_DESTIT, FWI_IOFTIT "
		cQuery += "From ? "
		cQuery += "Where FWI_FILIAL= ? "
	    cQuery += " And FWI_PREFIX = ? "
        cQuery += " And FWI_NUMERO = ? "
        cQuery += " And FWI_PARCEL = ? "
        cQuery += " And FWI_TIPO   = ? "
        cQuery += " And FWI_CLIENT = ? "
        cQuery += " And FWI_LOJA   = ? "
        cQuery += " And FWI_NUMBOR = ? "
        cQuery += " And D_E_L_E_T_=' ' "
        cQuery += " And FWI_SEQ < ? "
        cQuery += " Order By FWI_SEQ Desc"//Em caso de reutilização de numero de borderô, garante que esta pegando do último gerado.
		__oQuery := FWPreparedStatement():New(cQuery)
	EndIF
	__oQuery:SetNumeric(1,RetSqlName('FWI'))
	__oQuery:SetString(2,FWxFilial('FWI', cFil))
    __oQuery:SetString(3,SE1->E1_PREFIXO)
    __oQuery:SetString(4,SE1->E1_NUM)
    __oQuery:SetString(5,SE1->E1_PARCELA)
    __oQuery:SetString(6,SE1->E1_TIPO)
    __oQuery:SetString(7,SE1->E1_CLIENTE)
    __oQuery:SetString(8,SE1->E1_LOJA)
    __oQuery:SetString(9,SEA->EA_NUMBOR)
    __oQuery:SetString(10,cSeq)
	
	cQuery := __oQuery:GetFixQuery()
	cAlsFWI := MpSysOpenQuery(cQuery)
    If (cAlsFWI)->(!Eof())		
        If lValorBruto
            aDados[1] := (cAlsFWI)->FWI_VALOR
            aDados[2] := 0
            aDados[3] := 0
        else 
            aDados[1] := (cAlsFWI)->FWI_VLRBOR
            aDados[2] := (cAlsFWI)->FWI_DESTIT
            aDados[3] := (cAlsFWI)->FWI_IOFTIT
        EndIf        
    EndIF
	(cAlsFWI)->(dbCloseArea())

EndIf

Return aDados


/*/{Protheus.doc} GvIdDocFwi
    Gravação do IDMOV Gerado após a inclusão do registro de estorno na tabela SE5
    @type Function
    @param aParam, Array,     Conteudo dos RECNOS gerados nas inclusões dos registros de estorno na tabela FWI   
    @param cIdMov, Character, Conteudo do IDMOV Gravado do estorno na SE5
    @author Luiz Gustavo R. Jesus
    @since 03/09/2024
/*/
Function GvIdDocFwi(aParam as Array, cIdMov as Character)
Local nX as Numeric
Local nTotal as Numeric 
Local aAreaFWI  As Array
Local aArea     As Array 

    aAreaFWI  := FWI->( GetArea() )
    aArea     := GetArea()
    default aParam := {}
    default cIdMov := ""
    nTotal := Len(aParam)
    for nX := 1 to nTotal
        FWI->(dbGoTo(aParam[nX]))
        RecLock("FWI", .F.)
        FWI->FWI_IDMOV  := cIdMov
        FWI->(MsUnlock()) 
    next nX    
    
    RestArea(aAreaFWI)
    RestArea(aArea)

    FwFreeArray(aAreaFWI)
    FwFreeArray(aArea)
Return 
