#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "CTBS400.CH"

Static __nLayout	:= 10
Static __lRegX485   := .F.

//Compatibilização de fontes 30/05/2018

//-------------------------------------------------------------------
/*/{Protheus.doc} CTBS400
Cadastro de Identificacao dos tipos de programas - Registro 0021 do ECF leiaute 3.0


@author Paulo Carnelossi
@since 27-04-2017
@version P12.1.16
/*/
//-------------------------------------------------------------------
Function CTBS400()
    Local oBrowse

    //Valida existência da tabela QLO e campos
	If !validQLO()
      Return MsgInfo("Atualizar o dicionario de dados !!"+CRLF+CRLF+" Aplicar pacote para o Leiaute 10 do ECF ", "Atenção")
	EndIf

    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("CQL")
    oBrowse:SetDescription(STR0001)  // "Cadastro Identificacao Tipos de Programas - Registro 0021 ECF"
    oBrowse:SetCacheView(.F.)// Não realiza o cache da viewdef
    oBrowse:Activate()
Return NIL

//-------------------------------------------------------------------
Static Function MenuDef()
    Local aRotina := {}

    ADD OPTION aRotina TITLE STR0002 ACTION "VIEWDEF.CTBS400" OPERATION 2 ACCESS 0  //"Visualizar" 	
    ADD OPTION aRotina TITLE STR0003 ACTION "VIEWDEF.CTBS400" OPERATION 3 ACCESS 0  //"Incluir"    	
    ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.CTBS400" OPERATION 4 ACCESS 0  //"Alterar"    	
    ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.CTBS400" OPERATION 5 ACCESS 0  //"Excluir"    	
    ADD OPTION aRotina TITLE STR0006 ACTION "VIEWDEF.CTBS400" OPERATION 8 ACCESS 0  //"Imprimir"  	
    ADD OPTION aRotina TITLE STR0007 ACTION "VIEWDEF.CTBS400" OPERATION 9 ACCESS 0  //"Copiar"    	
Return aRotina


//-------------------------------------------------------------------
Static Function ModelDef()
    Local oStru := FWFormStruct(1, "CQL", /*bAvalCampo*/,/*lViewUsado*/)
    Local oStruQLO := FWFormStruct(1, "QLO", /*bAvalCampo*/,/*lViewUsado*/)
    Local oModel := MPFormModel():New("CTBS400", /*bPre*/, {|oModel| CTBS400POS(oModel)})

    oModel:AddFields("CQLMASTER", /*cOwner*/, oStru)

    oModel:AddGrid('QLOX485','CQLMASTER',oStruQLO,/*bLinePre*/,/*bLinePost*/,/*bPreVal*/,/*BLoad*/)

    oModel:SetRelation('QLOX485',{{'QLO_FILIAL','XFilial("QLO")'},{'QLO_CODID','CQL_CODID'}},QLO->(IndexKey(1)))
    oModel:GetModel('QLOX485'):SetOptional(.T.)

    oModel:SetDescription(STR0001 )  //"Cadastro Identificacao Tipos de Programas - Registro 0021 ECF"

    oModel:GetModel("CQLMASTER"):SetDescription(STR0001)  //Cadastro Identificacao Tipos de Programas - Registro 0021 ECF
    oModel:GetModel('QLOX485'):SetDescription('Registro X485') //"Registro X485:

Return oModel


//-------------------------------------------------------------------
Static Function ViewDef()
    Local oView
    Local oModel := FWLoadModel("CTBS400")
    Local oStru := FWFormStruct(2, "CQL")
    Local oStruQLO	:= FWFormStruct(2,'QLO')

    // tira o campo da visualizacao
    oStru:RemoveField("CQL_REG")
    oStru:RemoveField("CQL_LEIAUT")

    oStruQLO:RemoveField("QLO_LEIAUT")
    oStruQLO:RemoveField("QLO_REG")
    oStruQLO:RemoveField("QLO_CODID")

    If INCLUI
       
        ECFSelLayout()

        If __nLayout < 10
            oStru:RemoveField("CQL_OLEOBK")
            oStru:RemoveField("CQL_REPRTO")
            oStru:RemoveField("CQL_RETII") 
            oStru:RemoveField("CQL_RPMCMV")
            oStru:RemoveField("CQL_RETEEI")
            oStru:RemoveField("CQL_EBAS")  
            oStru:RemoveField("CQL_REPIND")
            oStru:RemoveField("CQL_REPNAC")
            oStru:RemoveField("CQL_REPPER")
            oStru:RemoveField("CQL_REPTMP")
            __lRegX485  := .F.
        Else
            oStru:RemoveField("CQL_PADTVD")
            oStru:RemoveField("CQL_REPENE")
            oStru:RemoveField("CQL_REICOM")
            oStru:RemoveField("CQL_RETAER")
            oStru:RemoveField("CQL_RESIDU")
            oStru:RemoveField("CQL_RECOPA")
            oStru:RemoveField("CQL_COPMUN")
            oStru:RemoveField("CQL_REPNBL")
            oStru:RemoveField("CQL_REIF")
            oStru:RemoveField("CQL_OLIMPI")
            __lRegX485  := .T.
        Endif

    Else
        CTS400CPYEXCL(oStru)    
    Endif

    oView := FWFormView():New()
    oView:SetCloseOnOk({||.T.})
    oView:SetModel(oModel)

    oView:AddField("VIEW_CQL", oStru, "CQLMASTER")

    If __lRegX485

        oStruQLO:SetProperty('QLO_SEQUEN', MVC_VIEW_CANCHANGE,.F.)

        oView:AddGrid('VIEW_QLO',oStruQLO,'QLOX485')

        oView:CreateHorizontalBox("TOP", 60)
        oView:CreateHorizontalBox('DOWN',40)

        oView:SetOwnerView("VIEW_CQL", "TOP")
        oView:SetOwnerView("VIEW_QLO","DOWN")

        oView:AddIncrementField('VIEW_QLO','QLO_SEQUEN')

        oView:EnableTitleView('VIEW_CQL')
        oView:EnableTitleView('VIEW_QLO')
    
    Else 
        oView:CreateHorizontalBox("TELA", 100)
        oView:SetOwnerView("VIEW_CQL", "TELA")
    EndIf

Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} CTBS400POS
Validacoes do cadastro
 - nao permite que o registro seja incluido com todas opcoes como "nao"

@author Daniel Lira
@since 08-05-2017
@version P12.1.16
@param oModel sera passado 
/*/
//-------------------------------------------------------------------
Function CTBS400POS(oModel as Object)
    Local nI            as Numeric
    Local lRet          as Logical
    Local oStruct       as Object
    Local aFields       as Array
    Local oStructQLO    as Object
    Local aFieldsQLO    as Array
    Local nJ            as Numeric
    Local lRetX485      as Logical
    Local nLinha		as Numeric
    Local nTemReg       as Numeric
    Local nPosDtFim     as Numeric
    Local nPosDtIni     as Numeric
    Local nPosCnpj      as Numeric
    Local nPosObra18    as Numeric
    Local nPosObra20    as Numeric
    Local nPosObraEE    as Numeric
    Local nPosPorCeb    as Numeric
    Local nPosDtPubl    as Numeric

    Default  oModel     := Nil

    nI          := 0
    lRet        := .F.
    oStruct     := oModel:GetModelStruct("CQLMASTER")[3]
    aFields     := oStruct:GetStruct():GetFields()
    oStructQLO  := oModel:GetModelStruct("QLOX485")[3]
    aFieldsQLO  := oStructQLO:GetStruct():GetFields()
    nJ          := 0
    lRetX485    := .T.
    nLinha		:= 0
    nTemReg     := 0
    nPosDtFim   := Ascan(aFieldsQLO, {|e| Alltrim(e[3]) == "QLO_DTFIMV" } )
    nPosDtIni   := Ascan(aFieldsQLO, {|e| Alltrim(e[3]) == "QLO_DTINIV" } )
    nPosCnpj    := Ascan(aFieldsQLO, {|e| Alltrim(e[3]) == "QLO_CNPJ" } )
    nPosObra18  := Ascan(aFieldsQLO, {|e| Alltrim(e[3]) == "QLO_IDOBRA" } )
    nPosObra20  := Ascan(aFieldsQLO, {|e| Alltrim(e[3]) == "QLO_OBRA20" } )
    nPosObraEE  := Ascan(aFieldsQLO, {|e| Alltrim(e[3]) == "QLO_OBRAEE" } )
    nPosPorCeb  := Ascan(aFieldsQLO, {|e| Alltrim(e[3]) == "QLO_PORCEB" } )
    nPosDtPubl  := Ascan(aFieldsQLO, {|e| Alltrim(e[3]) == "QLO_DTPUBL" } )

    // se ao menos um combobox tiver conteudo sim, formulario valido
    For nI := 1 To Len(aFields)
        If !Empty(aFields[nI][9]) .And. oStruct:GetValue(aFields[nI][3]) == "1"
            lRet := .T.
            Exit
        EndIf
    Next nI

    // caso o formulario nao esteja valido
    If ! lRet
        oModel:SetErrorMessage(oStruct:GetId(), /*cIdField*/, oStruct:GetId(), /*cIdFieldErr*/, "TODOSNAO", ;
                STR0011 , ;   //"Todas opcoes estao preenchidas com [ Nao ]"
                STR0012 )     //"Para utilizar o bloco alguma informacao deve ser preenchida com [ Sim ] "
    EndIf

    If lRet 
        If ALTERA .OR. INCLUI
            If !Empty( oModel:GetValue('CQLMASTER','CQL_LEIAUT') )
                oModel:LoadValue( 'CQLMASTER','CQL_LEIAUT',oModel:GetValue('CQLMASTER','CQL_LEIAUT') )
            ElseIf INCLUI
                oModel:LoadValue('CQLMASTER','CQL_LEIAUT',StrZero(__nLayout,4,0))
            Endif
        Endif 
    Endif

    If lRet
        // Se o leiaute escolhido for o 10 os campos referente ao registro X485 deve ser preenhido e validado.
        If (ALTERA .OR. INCLUI) .AND. Val(oModel:GetValue('CQLMASTER','CQL_LEIAUT')) >= 10
            For nJ := 1 to oStructQLO:Length()
               oStructQLO:GoLine(nJ)

                    If oStruct:GetValue(aFields[23][3]) == "1" //RET-II
                        For nLinha := 1 to oStructQLO:Length()
                            oStructQLO:GoLine(nLinha) 
                            If oModel:GetValue( 'QLOX485','QLO_TPBENE') == "09" .AND. !oModel:GetModel( "QLOX485" ):IsDeleted()
                                nTemReg := nTemReg+1
                            Endif
                        Next nLinha
                        oStructQLO:GoLine(nJ)

                        If nTemReg == 0
                            oModel:SetErrorMessage(oStructQLO:GetId(), /*cIdField*/, oStructQLO:GetId(), /*cIdFieldErr*/, "RET-II", ;
                                    'Para o tipo de beneficio RET-II é obrigatorio o preenchimento do Registro X485' , ;
                                    'Preencha as informações' )
                            lRetX485 := .F. 

                        ElseIf nTemReg > 0
                                If  oModel:GetValue( 'QLOX485','QLO_TPBENE') == "09" ;
                                    .AND. Empty( oStructQLO:GetValue(aFieldsQLO[nPosCnpj][3]) ) ;// QLO_CNPJ - Insc.Incorpo
                                    .AND. !oModel:GetModel( "QLOX485" ):IsDeleted()

                                    oModel:SetErrorMessage(oStructQLO:GetId(), /*cIdField*/, oStructQLO:GetId(), /*cIdFieldErr*/, "CNPJ_INCORP", ;
                                            'Para o tipo de beneficio (9 - RET-II) é obrigatorio o preenchimento do CNPJ' , ;
                                            'Preencha as informações' )
                                    lRetX485 := .F.
                                Endif
                        Endif
                        nTemReg := 0
                    Endif

                    If lRetX485 .AND. oModel:GetValue( 'QLOX485','QLO_TPBENE') == "09" .AND. !oModel:GetModel( "QLOX485" ):IsDeleted()
                        If oStruct:GetValue(aFields[23][3]) == "2" //RET-II
                                    oModel:SetErrorMessage(oStructQLO:GetId(), /*cIdField*/, oStructQLO:GetId(), /*cIdFieldErr*/, "RET-II", ;
                                        'Para o tipo de beneficio (9 - RET-II) é obrigatorio responder com Sim (RETII)' , ;
                                        'Corrija a seleção' )
                                    lRetX485 := .F.
                        EndIf
                    EndIf
                
                    If lRetX485 .AND. oStruct:GetValue(aFields[24][3]) == "1" //RPMCMV
                        For nLinha := 1 to oStructQLO:Length()
                            oStructQLO:GoLine(nLinha) 
                            If oModel:GetValue( 'QLOX485','QLO_TPBENE') == "10" .AND. !oModel:GetModel( "QLOX485" ):IsDeleted() //PMCMV e/ou RET – PCVA  
                                nTemReg := nTemReg+1
                            Endif
                        Next nLinha
                        oStructQLO:GoLine(nJ)

                        If nTemReg == 0
                            oModel:SetErrorMessage(oStructQLO:GetId(), /*cIdField*/, oStructQLO:GetId(), /*cIdFieldErr*/, "PMCMV e/ou RET-PCVA", ;
                                    'Para o tipo de beneficio PMCMV e/ou RET-PCVA é obrigatorio o preenchimento do Registro X485' , ;
                                    'Preencha as informações' )
                            lRetX485 := .F.
                            
                        ElseIf nTemReg > 0 
                            If (Empty( oStructQLO:GetValue(aFieldsQLO[nPosObra18][3]) ) .OR. ;// QLO_IDOBRA - OBRA_2018
                                Empty( oStructQLO:GetValue(aFieldsQLO[nPosObra20][3]) ) ) ;// QLO_OBRA20 - OBRA_2020 
                                .AND. oModel:GetValue( 'QLOX485','QLO_TPBENE') == "10"  ;
                                .AND. !oModel:GetModel( "QLOX485" ):IsDeleted()
                            
                                oModel:SetErrorMessage(oStructQLO:GetId(), /*cIdField*/, oStructQLO:GetId(), /*cIdFieldErr*/, "Obra/Constr", ;
                                        'Para o tipo de beneficio (10 - PMCMV e/ou RET-PCVA) é obrigatorio o preenchimento da Identificação Obra/Const' , ;
                                        'Preencha as informações' )
                                lRetX485 := .F.
                            Endif
                        Endif
                        nTemReg := 0
                    EndIf

                    If  lRetX485 .AND. oModel:GetValue( 'QLOX485','QLO_TPBENE') == "10" .AND. !oModel:GetModel( "QLOX485" ):IsDeleted()
                        If oStruct:GetValue(aFields[24][3]) == "2" //RPMCMV
                                oModel:SetErrorMessage(oStructQLO:GetId(), /*cIdField*/, oStructQLO:GetId(), /*cIdFieldErr*/, "Obra/Constr", ;
                                            'Para o tipo de beneficio (10 - PMCMV e/ou RET-PCVA) é obrigatorio responder com Sim (RPMCMV)' , ;
                                            'Corrija a seleção' )
                                lRetX485 := .F.
                        EndIf
                    EndIf

                    If lRetX485 .AND. oStruct:GetValue(aFields[25][3]) == "1" //RETEEI
                        For nLinha := 1 to oStructQLO:Length()
                            oStructQLO:GoLine(nLinha) 
                            If oModel:GetValue( 'QLOX485','QLO_TPBENE') == "11" .AND. !oModel:GetModel( "QLOX485" ):IsDeleted()// Identificação Obra/Constr
                                nTemReg := nTemReg+1
                            Endif
                        Next nLinha
                        oStructQLO:GoLine(nJ)

                        If nTemReg == 0
                            oModel:SetErrorMessage(oStructQLO:GetId(), /*cIdField*/, oStructQLO:GetId(), /*cIdFieldErr*/, "RETEEI", ;
                                    'Para o tipo de beneficio RETEEI é obrigatorio o preenchimento do Registro X485' , ;
                                    'Preencha as informações' )
                            lRetX485 := .F.

                        ElseIf nTemReg > 0
                            If Empty( oStructQLO:GetValue(aFieldsQLO[nPosObraEE][3]) ) ;// QLO_OBRAEE - OBRA_EEI
                                .AND. oModel:GetValue( 'QLOX485','QLO_TPBENE') == "11" ;
                                .AND. !oModel:GetModel( "QLOX485" ):IsDeleted()
                            
                                oModel:SetErrorMessage(oStructQLO:GetId(), /*cIdField*/, oStructQLO:GetId(), /*cIdFieldErr*/, "OBRA_EEI", ;
                                            'Para o tipo de beneficio (11 - OBRA_EEI) é obrigatorio o preenchimento da OBRA_EEI' , ;
                                            'Preencha as informações' )
                                lRetX485 := .F.
                            EndIf 
                        EndIf 
                        nTemReg := 0
                    EndIf 

                    If lRetX485 .AND. oModel:GetValue( 'QLOX485','QLO_TPBENE') == "11" .AND. !oModel:GetModel( "QLOX485" ):IsDeleted()
                        If oStruct:GetValue(aFields[25][3]) == "2" //RETEEI
                                oModel:SetErrorMessage(oStructQLO:GetId(), /*cIdField*/, oStructQLO:GetId(), /*cIdFieldErr*/, "RETEEI", ;
                                            'Para o tipo de beneficio (11 - OBRA_EEI) é obrigatorio responder com Sim (RETEEI)' , ;
                                            'Corrija a seleção' )
                                lRetX485 := .F.
                        EndIf
                    EndIf

                    If lRetX485 .AND. oStruct:GetValue(aFields[26][3]) == "1" //EBAS
                        For nLinha := 1 to oStructQLO:Length()
                            oStructQLO:GoLine(nLinha) 
                            If oModel:GetValue( 'QLOX485','QLO_TPBENE') == "12" .AND. !oModel:GetModel( "QLOX485" ):IsDeleted() // ENTID. BENEF. ASSIST. SOCIAL IMUNE  DE CONTRIB. SOCIAIS
                                nTemReg := nTemReg+1
                            Endif
                        Next nLinha
                        oStructQLO:GoLine(nJ)

                        If nTemReg == 0
                            oModel:SetErrorMessage(oStructQLO:GetId(), /*cIdField*/, oStructQLO:GetId(), /*cIdFieldErr*/, "EBAS", ;
                                    'Para o tipo de beneficio EBAS é obrigatorio o preenchimento do Registro X485' , ;
                                    'Preencha as informações' )
                            lRetX485 := .F.

                        ElseIf nTemReg > 0
                                If ( Empty( oStructQLO:GetValue(aFieldsQLO[nPosPorCeb][3]) ) .OR. ; //QLO_PORCEB - Número da Portaria
                                    Empty( oStructQLO:GetValue(aFieldsQLO[nPosDtPubl][3]) ) .OR. ; //QLO_DTPUBL - Dt.Publ.Port
                                    Empty( oStructQLO:GetValue(aFieldsQLO[nPosDtIni][3]) ) .OR. ; //QLO_DTINIV - Dt Ini Vigên
                                    Empty( oStructQLO:GetValue(aFieldsQLO[nPosDtFim][3]) ) );      //QLO_DTFIMV - Dt Fim Vigên
                                    .AND. oModel:GetValue( 'QLOX485','QLO_TPBENE') == "12" ;
                                    .AND. !oModel:GetModel( "QLOX485" ):IsDeleted()
                                    
                                    oModel:SetErrorMessage(oStructQLO:GetId(), /*cIdField*/, oStructQLO:GetId(), /*cIdFieldErr*/, "Inform_Portaria", ;
                                                'Para o tipo de beneficio (12 - ENTID. BENEF. ASSIST. SOCIAL IMUNE  DE CONTRIB. SOCIAIS) é obrigatorio o preenchimento das informações: Número da Portaria/Dt.Publ.Port/Dt Ini Vigên/Dt Fim Vigên' , ;
                                                'Preencha as informações' )
                                    lRetX485 := .F.
                                EndIf 
                        EndIf
                        nTemReg := 0
                    EndIf

                    If lRetX485 .AND. oModel:GetValue( 'QLOX485','QLO_TPBENE') == "12" .AND. !oModel:GetModel( "QLOX485" ):IsDeleted()
                        If oStruct:GetValue(aFields[26][3]) == "2" //EBAS
                                oModel:SetErrorMessage(oStructQLO:GetId(), /*cIdField*/, oStructQLO:GetId(), /*cIdFieldErr*/, "EBAS", ;
                                            'Para o tipo de beneficio (12 - ENTID. BENEF. ASSIST. SOCIAL IMUNE  DE CONTRIB. SOCIAIS) é obrigatorio responder com Sim (EBAS)' , ;
                                            'Corrija a seleção' )
                                lRetX485 := .F.
                        EndIf
                    EndIf

                    If lRetX485 .AND. oStructQLO:GetValue(aFieldsQLO[nPosDtFim][3]) < oStructQLO:GetValue(aFieldsQLO[nPosDtIni][3]) ; //Dt Fim Vigên < Dt Ini Vigên
                        .AND. !oModel:GetModel( "QLOX485" ):IsDeleted()

                        oModel:SetErrorMessage(oStructQLO:GetId(), /*cIdField*/, oStructQLO:GetId(), /*cIdFieldErr*/, "DT_FIN_MENOR", ;
                            'A Dt. Fim Vigên. não pode ser menor que a Dt. Ini. Vigên.' , ;
                            'Confira as datas' )
                        lRetX485 := .F.
                    Endif 

                    If lRetX485 
                        oModel:LoadValue('QLOX485','QLO_CODID',oModel:GetValue( 'CQLMASTER','CQL_CODID') )
                        oModel:LoadValue('QLOX485','QLO_LEIAUT',oModel:GetValue( 'CQLMASTER','CQL_LEIAUT') )
                    Else 
                        // caso o formulario nao esteja valido
                        oModel:SetErrorMessage(oStructQLO:GetId(), /*cIdField*/, oStructQLO:GetId(), /*cIdFieldErr*/, "X485", ;
                                'As informações referente ao registro X485 não foram preenchidas.' , ;
                                'Preencha todas as informações referente ao registro X485' )
                        lRet := .F.
                    EndIf
            Next nJ
        Endif
    Endif


Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ECFSelLayout
Parambox com retorno do leiaute da ECF a incluir

@author Totvs
@since 08-02-2024
@version P12.1.2310
/*/
//-------------------------------------------------------------------

Static Function ECFSelLayout() as Logical
Local lRet          as Logical
Local aParLeiaute   as Array
Local aRespLeiaute  as Array
Local aECFLeiaute   as Array

lRet          := .T.
aParLeiaute   := {}
aRespLeiaute  := {}
aECFLeiaute   := ECF_Leiaute()

aAdd(aParLeiaute ,{3,"Informe o leiaute da ECF?",__nLayout,aECFLeiaute,90,"",.T.,.T.}) 
aRespLeiaute := {__nLayout}

If ParamBox( aParLeiaute," [ ECF ] - Selecione o leiaute da ECF.", @aRespLeiaute)
    __nLayout	:= aRespLeiaute[1]
Else
    lRet := .F.
EndIf

Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} ECF_Leiaute
Retorna array com a lista de leiautes da ECF


@author Totvs
@since 08-02-2024
@version P12.1.2310
/*/
//-------------------------------------------------------------------
Static Function ECF_Leiaute() as Array

Local aLeiaute as Array

aLeiaute := {"Leiaute 1.0" , "Leiaute 2.0","Leiaute 3.0","Leiaute 4.0","Leiaute 5.0",;
            "Leiaute 6.0","Leiaute 7.0","Leiaute 8.0","Leiaute 9.0","Leiaute 10.0"}

Return(aLeiaute)


//-------------------------------------------------------------------
/*/{Protheus.doc} CTS400CPYEXCL
A função recebera e devolvera o objeto de estrutura conforme o campo CQL_LEIAUT

@author vinicius.snascimento
@since 09/02/2024
@version P12.1.2310
@param oModel sera passado 
/*/
//-------------------------------------------------------------------
Function CTS400CPYEXCL(oStru as Object)

Local	oModel as Object

Default	oStru  := Nil

oModel := FWLoadModel("CTBS400")
oModel:Activate(.T.) // Ativa o modelo com os dados posicionados

    If !Empty( oModel:GetValue('CQLMASTER','CQL_LEIAUT') )

        If Val( oModel:GetValue('CQLMASTER','CQL_LEIAUT') ) < 10

            oStru:RemoveField("CQL_OLEOBK")
            oStru:RemoveField("CQL_REPRTO")
            oStru:RemoveField("CQL_RETII") 
            oStru:RemoveField("CQL_RPMCMV")
            oStru:RemoveField("CQL_RETEEI")
            oStru:RemoveField("CQL_EBAS")  
            oStru:RemoveField("CQL_REPIND")
            oStru:RemoveField("CQL_REPNAC")
            oStru:RemoveField("CQL_REPPER")
            oStru:RemoveField("CQL_REPTMP")
            __lRegX485  := .F.
        Else
            oStru:RemoveField("CQL_PADTVD")
            oStru:RemoveField("CQL_REPENE")
            oStru:RemoveField("CQL_REICOM")
            oStru:RemoveField("CQL_RETAER")
            oStru:RemoveField("CQL_RESIDU")
            oStru:RemoveField("CQL_RECOPA")
            oStru:RemoveField("CQL_COPMUN")
            oStru:RemoveField("CQL_REPNBL")
            oStru:RemoveField("CQL_REIF")
            oStru:RemoveField("CQL_OLIMPI")
            __lRegX485  := .T.

        Endif
    Else //Se o registro não possui CQL_LEIAUT preenhido significa que o mesmo foi incluido no leiaute anterior ao 10.
            oStru:RemoveField("CQL_OLEOBK")
            oStru:RemoveField("CQL_REPRTO")
            oStru:RemoveField("CQL_RETII") 
            oStru:RemoveField("CQL_RPMCMV")
            oStru:RemoveField("CQL_RETEEI")
            oStru:RemoveField("CQL_EBAS")  
            oStru:RemoveField("CQL_REPIND")
            oStru:RemoveField("CQL_REPNAC")
            oStru:RemoveField("CQL_REPPER")
            oStru:RemoveField("CQL_REPTMP")
            __lRegX485  := .F.
    Endif
Return oStru
/*/{Protheus.doc} validQLO() 
    Valida existencia da tabela QLO e campos necessario para atender X485 do ECF leiaute 10
    @type  Static Function
    @author wilton.santos
    @since lRet
    @version 12.1.2310
    @return lRet - Verdadeiro caso algum campo não exista
/*/
Static Function validQLO()
Local lRet as logical 
lRet := .T.
    If CQL->(FieldPos("CQL_OLEOBK")) == 0 .AND. ;
	   CQL->(FieldPos("CQL_REPRTO")) == 0 .AND. ;
	   CQL->(FieldPos("CQL_RETII") ) == 0 .AND. ;
	   CQL->(FieldPos("CQL_RPMCMV")) == 0 .AND. ;
	   CQL->(FieldPos("CQL_RETEEI")) == 0 .AND. ;
	   CQL->(FieldPos("CQL_EBAS")  ) == 0 .AND. ;
	   CQL->(FieldPos("CQL_REPIND")) == 0 .AND. ;
	   CQL->(FieldPos("CQL_REPNAC")) == 0 .AND. ;
	   CQL->(FieldPos("CQL_REPPER")) == 0 .AND. ;
	   CQL->(FieldPos("CQL_REPTMP")) == 0 .AND. ;
	   CQL->(FieldPos("CQL_LEIAUT")) == 0 .AND. ;
	   CSZ->(FieldPos("CSZ_PRCTRN")) == 0 .AND. !TableInDic('QLO') 
	    lRet := .F.
    EndIf    
Return lRet
