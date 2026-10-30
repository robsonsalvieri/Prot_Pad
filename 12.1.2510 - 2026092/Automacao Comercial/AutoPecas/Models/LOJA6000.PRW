#include "Totvs.ch"
#include "FWMVCDef.ch"
#include "LOJA6000.ch"

/*/{Protheus.doc} LOJA6000
    Cadastro de Modelo de Veiculo
    @type    function
    @author  eduardo.FLima
    @since   01/06/2026
    @version P12
    @return  Nil
/*/
Function LOJA6000()
    Local oBrowse   := FWMBrowse():New()
    Private aRotina := MenuDef()

    oBrowse:SetAlias('MEC')
    oBrowse:SetDescription(STR0001) //"Modelo de Veiculo"

    oBrowse:Activate()

    oBrowse:Destroy()
Return Nil

/*/{Protheus.doc} MenuDef
    Definicao do Menu para o cadastro de Modelo de Veiculo
    @type    function
    @author  eduardo.FLima
    @since   01/06/2026
    @version P12
    @return  Array com as opcoes do menu para o cadastro de Modelo de Veiculo
/*/
Static Function MenuDef()
    Local aRet := {}

    ADD OPTION aRet Title STR0005 Action "VIEWDEF.LOJA6000" Operation 2 Access 0 //"Visualizar"
    ADD OPTION aRet Title STR0002 Action "VIEWDEF.LOJA6000" Operation 3 Access 0 //"Incluir"
    ADD OPTION aRet Title STR0003 Action "VIEWDEF.LOJA6000" Operation 4 Access 0 //"Modificar"
    ADD OPTION aRet Title STR0004 Action "VIEWDEF.LOJA6000" Operation 5 Access 0 //"Excluir"
    ADD OPTION aRet Title STR0006 Action "VIEWDEF.LOJA6000" Operation 9 Access 0 //"Copiar"
Return aRet

/*/{Protheus.doc} ModelDef
    Definicao do Model para o cadastro de Modelo de Veiculo
    @type    function
    @author  eduardo.FLima
    @since   01/06/2026
    @version P12
    @return  Objeto de Model para o cadastro de Modelo de Veiculo
/*/
Static Function ModelDef()
    Local oStruct := FWFormStruct(1, 'MEC')
    Local oModel  := MPFormModel():New('LOJA6000', /*Pre-Validacao*/,/*Valid Model*/,/*Commit*/,/*Cancel*/)

    oModel:SetDescription(STR0001) //"Modelo de Veiculo"
    oModel:AddFields('MECMASTER', /*cOwner*/, oStruct)
    oModel:SetPrimaryKey({'MEC_FILIAL', 'MEC_MSUID'})

Return oModel

/*/{Protheus.doc} ViewDef
    Definicao da View para o cadastro de Modelo de Veiculo
    @type    function
    @author  eduardo.FLima
    @since   01/06/2026
    @version P12
    @return  Objeto de View para o cadastro de Modelo de Veiculo
/*/
Static Function ViewDef()
    Local oView   := FWFormView():New()
    Local oStruct := FWFormStruct(2, 'MEC')
    Local oModel  := FWLoadModel('LOJA6000')

    oView:SetDescription(STR0001) //"Modelo de Veiculo"
    oView:SetModel(oModel)
    oView:AddField('MEC', oStruct, 'MECMASTER')
    oView:EnableTitleView('MEC', STR0001) //"Modelo de Veiculo"

Return oView




/*/{Protheus.doc} MecVldFab
    Validação personalizada para o campo de Mês/Ano de Fabricação (MEC_FABINI e MEC_FABFIM)
     - Permite valor vazio ou no formato MM/AAAA
     - Valida mês entre 01 e 12, e ano maior que 1900
     - Garante que MEC_FABINI não seja maior que MEC_FABFIM quando ambos preenchidos
     - Exibe mensagens de erro específicas para cada tipo de validação falha
     - Deve ser associada aos campos MEC_FABINI e MEC_FABFIM na definição do Model ou View
    @type    function
    @author  eduardo.FLima
    @since   01/06/2026
    @version P12
    @return  Logical indicando se o valor é válido ou não
/*/
function MecVldFab()
    Local cCampo:= ""   AS Character  
    Local cValor:= ""   AS Character  
    Local cMes  := ""   AS Character  
    Local cAno  := ""   AS Character  
    Local cIni  := ""   AS Character 
    Local cFim  := ""   AS Character 
    Local nMes  := 0    AS Numeric    
    Local nAno  := 0    AS Numeric    
    Local lRet  := .T.  AS Logical    

    cCampo:= ReadVar()
    cValor:= FwFldGet(StrTran(cCampo,"M->","")) 

    // Se o campo estiver vazio, é permitido — retorna válido
    If Empty(AllTrim(cValor))
        Return .T.
    EndIf

    cValor := StrTran(cValor,"/","")// Remove barra caso tenha sido enviada, para validar apenas os números
    lRet := IsNumeric(cValor) // Valida se mês e ano são totalmente numéricos
    lRet :=  lRet .And. Len(cValor) == 6 // Valida se tem exatamente 6 dígitos (MMYYYY)
    If lRet
        // Extrai mês (posições 1-2) e ano (posições 3-6)
        // Lembrando: @R 99/9999 não armazena a barra, campo tem 6 chars
        cMes := SubStr(cValor, 1, 2)
        cAno := SubStr(cValor, 3, 4)
        nMes := Val(cMes)
        nAno := Val(cAno)
    EndIf

    // Valida intervalo do mês: 01 a 12
    If lRet .And. (nMes < 1 .Or. nMes > 12)
        lRet := .F.
    EndIf

    // Valida ano: deve ser maior que zero (ajuste o limite conforme regra de negócio)
    If lRet .And. nAno < 1900
        lRet := .F.
    EndIf

    // Exibe mensagem de erro ao usuário caso inválido
    If !lRet
        Help(" ", 1, "VLDDTFAB", , STR0007 + Chr(13) + Chr(10) + STR0008, 1, 0,) //""Mês/Ano de fabricação inválido!" "Informe um valor no formato MM/AAAA ou deixe em branco.""
    EndIf
    // Valida que MEC_FABINI <= MEC_FABFIM quando ambos estão preenchidos.
    cIni := FwFldGet("MEC_FABINI")
    cFim := FwFldGet("MEC_FABFIM")    
    If lRet .and. !Empty(allTrim(cIni)) .and. !Empty(allTrim(cFim))
        If SubStr(cIni, 3, 4)+SubStr(cIni, 1, 2) > SubStr(cFim, 3, 4)+SubStr(cFim, 1, 2)
            lRet := .F.
            Help(" ", 1, "VLDDTFAB", , STR0009, 1, 0,) //""Mês/Ano de fabricação inicial não pode ser maior que Mês/Ano de fabricação final!""
        EndIf    
    EndIf
Return lRet

/*/{Protheus.doc} Lj6000VMec
    Validação de UUID do campo UUID para o cadastro de Mod Veiculo Prod / Aplicação
    @type Function
    @author eduardo.FLima
    @since 22/06/2026
    @version P12
    @param cUuid, Character, Valor do campo UUID a ser validado Default cUuid := &(readvar())
    @return Logical, Resultado da validação
/*/
Function Lj6000VMec(cUuid)
    Local lFound      := .F. as Logical
    Default cUuid   := &(readvar())

    If Empty(AllTrim(cUuid))
        return .T. // Permite valor vazio
    Endif
    If Lj6000VUid(cUuid)         
        lFound := RecnByUuid(cUuid)> 0
        If !lFound
            Help(" ", 1, "Lj6000VMec", , STR0012, 1, 0; //"UUID não encontrado na tabela MEC. O código deve ser um uuid cadastrado")
            ,,,,,,{STR0011}) //"Verifique os dados informados"
        EndIf
    EndIf
Return lFound



/*/{Protheus.doc} Lj6000VUid
    Verifica se uma string é um UUID válido no formato RFC 4122.
    @type  Function
    @author eduardo.FLima
    @since 22/06/2026
    @version P12
    @param cUUID, Character, string a ser validada
    @return Logical, .T. se o UUID for válido, .F. caso contrário
/*/
Function Lj6000VUid(cUUID As Character) As Logical
    Local aPartes  := {}  As Array
    Local aTamanho := {8, 4, 4, 4, 12} As Array // Tamanho esperado de cada parte do UUID
    Local nParte   := 0   As Numeric
    Local nChar    := 0   As Numeric
    Local cChar    := ""  As Character
    Local cHex     := "0123456789abcdefABCDEF" As Character // Caracteres hexadecimais válidos
    Local lRet     := .T. As Logical
    Default cUuid   := &(readvar())

    // UUID deve ter exatamente 36 caracteres (32 hex + 4 hífens)
    lRet := lRet .And. Len(AllTrim(cUUID)) == 36

    // Divide pelo separador "-"
    aPartes := StrTokArr(cUUID, "-")

    // Deve ter exatamente 5 grupos
    lRet := lRet .and.  Len(aPartes) == 5

    // Valida o tamanho de cada grupo e se contém apenas caracteres hexadecimais
    if lRet
        For nParte := 1 To Len(aPartes)
            If Len(aPartes[nParte]) <> aTamanho[nParte]
                lRet := .F.
                Exit
            EndIf
            For nChar := 1 To Len(aPartes[nParte])
                cChar := SubStr(aPartes[nParte], nChar, 1)
                If At(cChar, cHex) == 0
                    lRet := .F.
                    Exit
                EndIf
            Next nChar
            If !lRet
                Exit
            EndIf
        Next nParte
    EndIf
    If !lRet
        Help(" ", 1, "Lj6000VUid", , STR0010, 1, 0; //"UUID inválido. O código deve ser um uuid vlido")
        ,,,,,,{STR0011}) //"Verifique os dados informados"
    Endif 
Return lRet


/*/{Protheus.doc} RecnByUuid
    Retorna o R_E_C_N_O_ de um registro na tabela MEC com base no UUID fornecido.
    retornará 0 se o UUID não for encontrado ou se estiver vazio.
    @type  Static Function
    @author eduardo.FLima
    @since 22/06/2026
    @version P12
    @param cUuid, Character, UUID do registro
    @return Numeric, R_E_C_N_O_ do registro
/*/
Static Function RecnByUuid(cUuid As Character) As Numeric
    Local nRecno := 0 as Numeric
    Local cQuery := "" as Character
    Local oExec  := Nil as Object

    If !Empty(AllTrim(cUuid))
        cQuery := " SELECT R_E_C_N_O_ FROM " + RetSQLName("MEC")
        cQuery += " WHERE MEC_MSUID = ? "
        cQuery += " AND D_E_L_E_T_ = ? "
        cQuery := ChangeQuery(cQuery)
        oExec := FwExecStatement():New(cQuery)
        oExec:SetString(1,cUuid)
        oExec:SetString(2,' ')
        nRecno := Val(cValToChar(oExec:ExecScalar('R_E_C_N_O_')))
    EndIf
    
Return nRecno

/*/{Protheus.doc} Lj6000GFld
    Retorna o valor de um campo específico de um registro na tabela MEC com base no UUID fornecido.
    Se o UUID não for encontrado, retorna Nil.
    @type  Function
    @author Eduardo.FLima
    @since 22/06/2026
    @version P12
    @param cUUID, Character, UUID do registro
    @param cField, Character, Nome do campo a ser retornado
    @return Variant, Valor do campo ou Nil se não encontrado
/*/
Function Lj6000GFld(cUUID as character, cField as Character) as Variant
    Local aArea := GetArea() as Array
    Local aMecArea := MEC->(GetArea()) as Array
    Local xRet := Nil as Variant
    Local nRecno := 0 as Numeric

    nRecno := RecnByUuid(cUUID)
    If nRecno > 0
        MEC->(dbGoTo(nRecno))
        xRet := MEC->(FieldGet(FieldPos('MEC_MODELO')))
    Endif 
    MEC->(RestArea(aMecArea))    
    RestArea(aArea)
Return xRet
