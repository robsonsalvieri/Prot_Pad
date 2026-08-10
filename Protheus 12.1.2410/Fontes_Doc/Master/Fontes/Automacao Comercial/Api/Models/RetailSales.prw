#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'RetailSales.CH'

Static oMStruSL1 	:= Nil //Struct do Model
Static oMStruSL2 	:= Nil //Struct do Model
Static oMStruSL4 	:= Nil //Struct do Model
Static oVStruSL1 	:= Nil //Struct do View
Static oVStruSL2 	:= Nil //Struct do View
Static oVStruSL4 	:= Nil //Struct do View
Static oModelDef 	:= Nil //Modelo de dados construído
Static lIntegICM    := .F.

//--------------------------------------------------------
/*/{Protheus.doc} RetailSales
Realiza gravação da venda
@type function
@author  	rafael.pessoa
@since   	05/06/2019
@version 	P12
@param 		aAutoCab  	, Array, Cabeçalho da venda - SL1
@param 		aAutoItens  , Array, Itens da Venda - SL2
@param 		aAutoPagtos , Array, Pagamentos da Venda - SL4
@return	lRet - Retorna se executou corretamente
/*/
//--------------------------------------------------------
Function RetailSales(aAutoCab, aAutoItens, aAutoPagtos, nOpcAuto)

    Local lRotAuto 	:= aAutoCab <> Nil	   	//Cadastro por rotina automatica
    Local lRet		:= .F.
    Local nX        := 0

    Private aRotina := MenuDef()       		//Array com os menus disponiveis
    
    Default aAutoCab 	:= {}
    Default aAutoItens	:= {}
    Default aAutoPagtos	:= {}
    Default nOpcAuto	:= 3

    If lRotAuto

          
        //Ordena os arrays da MsExecAuto com base no SX3, para não ter problemas nos gatilhos
        aAutoCab    := FwVetByDic(aAutoCab   , "SL1", .F., 1)

        aAutoItens  := FwVetByDic(aAutoItens , "SL2", .T., 1)

        aAutoPagtos := FwVetByDic(aAutoPagtos, "SL4", .T., 1)
        
        If nOpcAuto == 4
            For nX := 1 to len(aAutoItens) //Adiciona LIMPOS e AUTDELETA para Frame saber que pode alterar o item.
                If Len(aAutoItens) > 1 //Quando existe apenas 1 iten não é preciso passar LINPOS.
                    Aadd(aAutoItens[nX], {"LINPOS", 'L2_ITEM', STBPegaIT(nX)} )
                    Aadd(aAutoItens[nX], {"AUTDELETA","N",Nil} )
                EndIf
            next
        EndIf
        
        lRet := FWMVCRotAuto(ModelDef(), "SL1", nOpcAuto, { {"SL1MASTER", aAutoCab}, {"SL2DETAIL", aAutoItens} , {"SL4DETAIL", aAutoPagtos} })
    Else
        // Não disponivel melhoria futura
        /*
        oBrowse := FWmBrowse():New()
        oBrowse:SetAlias( 'SL1' )
        oBrowse:SetDescription(STR0001) //"Venda Assistida"
        oBrowse:Activate()
        */
    EndIf

    lIntegICM := .F.
Return lRet

//--------------------------------------------------------
/*/{Protheus.doc} MenuDef
MenuDef MVC
@type function
@author  	rafael.pessoa
@since   	05/06/2019
@version 	P12
@return	    aRotina - Rotinas disponiveis
/*/
//--------------------------------------------------------
Static Function MenuDef()

    Local aRotina := {}

    aAdd( aRotina, { STR0002, 'VIEWDEF.RetailSales', 0, 2, 0, NIL } )   //"Visualizar"
    aAdd( aRotina, { STR0003, 'VIEWDEF.RetailSales', 0, 3, 0, NIL } )   //"Incluir"
    aAdd( aRotina, { STR0004, 'VIEWDEF.RetailSales', 0, 4, 0, NIL } )   //"Alterar"
    aAdd( aRotina, { STR0005, 'VIEWDEF.RetailSales', 0, 8, 0, NIL } )   //"Imprimir"

Return aRotina

//--------------------------------------------------------
/*/{Protheus.doc} ModelDef
ModelDef MVC
@type function
@author  	rafael.pessoa
@since   	05/06/2019
@version 	P12
@return	    oModel - modelo de dados
/*/
//--------------------------------------------------------
Static Function ModelDef()

    If oModelDef == Nil

        LoadStrModel() //Carrega Struct do Model

        oModelDef := MPFormModel():New( 'RetailSales',,{|| RSFormaId()}) // Cria o objeto do Modelo de Dados

        oModelDef:AddFields( 'SL1MASTER', /*cOwner*/ , oMStruSL1, {|oModelSL1,cAction,cIDField,xValue| ValidaSL1(oModelSL1)} )   // Adiciona ao modelo um componente de formulário
        oModelDef:AddGrid(   "SL2DETAIL", "SL1MASTER", oMStruSL2, /*bLinePre*/, {|oModelSL2, nLinhaAtu| ValidaSL2(oModelSL2, nLinhaAtu)}, /*bPre*/, /*bPost*/ )
        oModelDef:AddGrid(   'SL4DETAIL', 'SL1MASTER', oMStruSL4, /*bLinePre*/, {|oModelSL4, nLinhaAtu| ValidaSL4(oModelSL4, nLinhaAtu)}, /*bPre*/, /*bPost*/ )    // Adiciona ao modelo uma componente de grid

        oModelDef:SetRelation( 'SL2DETAIL', { { 'L2_FILIAL', 'xFilial( "SL2" )' }, { 'L2_NUM', 'L1_NUM' } }, SL2->( IndexKey( 1 ) ) )
        oModelDef:SetRelation( 'SL4DETAIL', { { 'L4_FILIAL', 'xFilial( "SL4" )' }, { 'L4_NUM', 'L1_NUM' } }, SL4->( IndexKey( 1 ) ) )

        oModelDef:SetDescription(STR0001)//"Venda Assistida"
        oModelDef:GetModel( 'SL1MASTER' ):SetDescription(STR0006)	//"Cabeçalho da Venda"
        oModelDef:GetModel( 'SL2DETAIL' ):SetDescription(STR0007)	//"Itens da Venda"
        oModelDef:GetModel( 'SL4DETAIL' ):SetDescription(STR0008)   //"Pagamentos da Venda"
        oModelDef:GetModel( 'SL4DETAIL' ):SetOptional(.T.)
                
        oModelDef:GetModel( 'SL2DETAIL' ):SetUniqueLine( { 'L2_ITEM'} )
        //oModelDef:GetModel( 'SL4DETAIL' ):SetUniqueLine( { 'L4_ITEM' } ) 

    EndIf

Return oModelDef

//--------------------------------------------------------
/*/{Protheus.doc} ViewDef
ViewDef MVC
@type function
@author  	rafael.pessoa
@since   	05/06/2019
@version 	P12
@return	    ViewDef - View do modelo
/*/
//--------------------------------------------------------
Static Function ViewDef()

    Local oModel    	:= FWLoadModel( 'RetailSales' )
    Local oView		    := Nil    

    LoadStrView() //Carrega Struct da View

    oView := FWFormView():New()
    oView:SetModel( oModel )

    oView:AddField( 'VIEW_SL1', oVStruSL1, 'SL1MASTER' )
    oView:AddGrid(  'VIEW_SL2', oVStruSL2, 'SL2DETAIL' )
    oView:AddGrid(  'VIEW_SL4', oVStruSL4, 'SL4DETAIL' )

    oView:CreateHorizontalBox( 'BOX_SL1', 15 )
    oView:CreateHorizontalBox( 'BOX_SL2', 65 )
    oView:CreateHorizontalBox( 'BOX_SL4', 20 )

    oView:SetOwnerView( 'VIEW_SL1', 'BOX_SL1' )
    oView:SetOwnerView( 'VIEW_SL2', 'BOX_SL2' )
    oView:SetOwnerView( 'VIEW_SL4', 'BOX_SL4' )

Return oView

//--------------------------------------------------------
/*/{Protheus.doc} LoadStrModel
Carrega struct do Model necessarios e adiciona demais propriedades
@type function
@author  	rafael.pessoa
@since   	05/06/2019
@version 	P12
@return	    Nil 
/*/
//--------------------------------------------------------
Static Function LoadStrModel()

    oMStruSL1 	:= FWFormStruct( 1, 'SL1' ) // Cria as estruturas a serem usadas no Modelo de Dados
    oMStruSL2 	:= FWFormStruct( 1, 'SL2' )	// Cria as estruturas a serem usadas no Modelo de Dados
    oMStruSL4 	:= FWFormStruct( 1, 'SL4' )	// Cria as estruturas a serem usadas no Modelo de Dados

    //Deixa os campos como utilizados
    LjxAddFil('SL1', oMStruSL1, 1)
    LjxAddFil('SL2', oMStruSL2, 1)
    LjxAddFil('SL4', oMStruSL4, 1)

    //----------------------------------------------
    // SL1 | Cabeçalho da Venda 
    oMStruSL1:SetProperty("*",MODEL_FIELD_OBRIGAT,.F.)	
    oMStruSL1:SetProperty("*",MODEL_FIELD_VALID,{|| .T.} )
    oMStruSL1:SetProperty("*",MODEL_FIELD_INIT,{|| } )

    oMStruSL1:AddTrigger("L1_LOJA"      ,"L1_NOMCLI"    , {||.T.} , {|| Posicione("SA1",1,xFilial("SA1")+FwFldGet("L1_CLIENTE") + FwFldGet("L1_LOJA"),"A1_NOME")          })

    oMStruSL1:SetProperty("L1_FILIAL"   ,MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD , 'xFilial("SL1")' ))
    oMStruSL1:SetProperty("L1_NUM"      ,MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD , 'GetSxENum("SL1","L1_NUM")' ))
    oMStruSL1:SetProperty("L1_DTLIM"    ,MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD , 'dDataBase + SuperGetMV("MV_DTLIMIT", .F., 0 )' ))
    oMStruSL1:SetProperty("L1_EMISSAO"  ,MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD , 'dDataBase' ))
    oMStruSL1:SetProperty("L1_CONFVEN"  ,MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD , '"SSSSSSSSNSSS"' ))
    oMStruSL1:SetProperty("L1_VEND"     ,MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD , 'SuperGetMV( "MV_VENDPAD",.F.,"" )' ))
    oMStruSL1:SetProperty("L1_IMPRIME"  ,MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD , 'RSImprime()' ))
    oMStruSL1:SetProperty("L1_CONDPG"   ,MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD , '"CN"' ))
    oMStruSL1:SetProperty("L1_TABELA"   ,MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD , 'AllTrim(SuperGetMv("MV_TABPAD"))' ))

    //----------------------------------------------
    // SL2 | Itens da Venda 
    oMStruSL2:SetProperty("*",MODEL_FIELD_OBRIGAT,.F.)
    oMStruSL2:SetProperty("*",MODEL_FIELD_VALID,{|| .T.} )
    oMStruSL2:SetProperty("*",MODEL_FIELD_INIT,{|| } )

    oMStruSL2:SetProperty("L2_PRODUTO" ,MODEL_FIELD_OBRIGAT, .T. ) 
    oMStruSL2:SetProperty("L2_ITEM"    ,MODEL_FIELD_OBRIGAT, .T. ) 
    oMStruSL2:SetProperty("L2_LOCAL"   ,MODEL_FIELD_OBRIGAT, .T. ) 
    oMStruSL2:SetProperty("L2_UM"      ,MODEL_FIELD_OBRIGAT, .T. ) 

    oMStruSL2:SetProperty("L2_ITEM"    ,MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD , 'RSNumItem("SL2DETAIL")' ))
    oMStruSL2:SetProperty("L2_QUANT"   ,MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD , '1'           ))
    oMStruSL2:SetProperty("L2_VENDIDO" ,MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD , '""'          ))
    oMStruSL2:SetProperty("L2_EMISSAO" ,MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD , 'dDataBase'   ))
    oMStruSL2:SetProperty("L2_GRADE"   ,MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD , '"N"'         ))
    oMStruSL2:SetProperty("L2_ENTREGA" ,MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD , '"2"'         ))
    oMStruSL2:SetProperty("L2_ITEMSD1" ,MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD , '"000000"'    ))
    oMStruSL2:SetProperty("L2_TURNO"   ,MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD , 'SuperGetMv("MV_LJTURNO",,"M")' ) )
    oMStruSL2:SetProperty("L2_VLTROCA" ,MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD , '"2"'         ))
    oMStruSL2:SetProperty("L2_VEND"    ,MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD , 'FwFldGet("L1_VEND")'         ))
    oMStruSL2:SetProperty("L2_PDV"     ,MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD , 'FwFldGet("L1_PDV")'         ))

    oMStruSL2:AddTrigger("L2_PRODUTO"   ,"L2_DESCRI"    , {||.T.} , {|| Posicione('SB1',1,xFilial('SB1')+FwFldGet("L2_PRODUTO"),'B1_DESC')   })
    oMStruSL2:AddTrigger("L2_PRODUTO"   ,"L2_UM"        , {||.T.} , {|| Posicione('SB1',1,xFilial('SB1')+FwFldGet("L2_PRODUTO"),'B1_UM')     })
    oMStruSL2:AddTrigger("L2_PRODUTO"   ,"L2_LOCAL"     , {||.T.} , {|| Posicione('SB1',1,xFilial('SB1')+FwFldGet("L2_PRODUTO"),'B1_LOCPAD') })

    //----------------------------------------------
    // SL4 | Pagamentos 
    oMStruSL4:SetProperty("*",MODEL_FIELD_OBRIGAT,.F.)
    oMStruSL4:SetProperty("*",MODEL_FIELD_INIT,{|| } )
    oMStruSL4:SetProperty("*",MODEL_FIELD_VALID,{|| .T.} )

    oMStruSL4:SetProperty("L4_ITEM", MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD , 'RSNumItem("SL4DETAIL")' ))

    oMStruSL4:SetProperty("L4_VALOR",MODEL_FIELD_VALID,{|| RSPgFields() } )
    oMStruSL4:SetProperty("L4_FORMA",MODEL_FIELD_VALID,{|| RSPgFields() } )

    oMStruSL4:AddTrigger("L4_VALOR"   ,"L1_PARCELA", {||.T.} , {|| RSParcel()  })
  
Return Nil

//--------------------------------------------------------
/*/{Protheus.doc} LoadStrView
Carrega struct do View e demais propriedades
@type function
@author  	rafael.pessoa
@since   	05/06/2019
@version 	P12
@return	    Nil 
/*/
//--------------------------------------------------------
Static Function LoadStrView()

    oVStruSL1 	:= FWFormStruct( 2, 'SL1' )
    oVStruSL2 	:= FWFormStruct( 2, 'SL2' )
    oVStruSL4 	:= FWFormStruct( 2, 'SL4' )

    //Deixa os campos como utilizados
    LjxAddFil('SL1', oVStruSL1, 2)
    LjxAddFil('SL2', oVStruSL2, 2)
    LjxAddFil('SL4', oVStruSL4, 2)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} ValidaSL1()
Valida a linha da SL1 e atualiza valores

@param 	oModelSL2 	- Model da SL1
@param 	nLinhaAtu	- Linha posicionada
@return lRetorno	- .T./.F. Determina se as informações foram alteradas corretamente
@author Rafael Tenorio da Costa
@since  15/01/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ValidaSL1(oModelSL1)
Local lRetorno := .T.

Static oMdlSL1 := NIL

//Valida se veio o valor de ICMS pois na integracao CHEF esse campo pode vir preenchido
//com isso não posso acumular imposto baseado na SL2
If !(FwFldGet("L1_VALICM") > 0)
    If !lIntegICM
        LjGrvLog("RetailSales","Foi constatado que o valor de ICM (L1_VALICM) não esta acumulado portanto "+;
                                "será somado nesse campo o valor de cada item (L2_VALICM)")
    EndIf
    lIntegICM := .T.
    oMdlSL1 := oModelSL1
EndIf

Return lRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} ValidaSL2()
Valida a linha da SL2 e atualiza valores

@param 	oModelSL2 	- Model da SL2
@param 	nLinhaAtu	- Linha posicionada
@return lRetorno	- .T./.F. Determina se as informações foram alteradas corretamente
@author Rafael Tenorio da Costa
@since  15/01/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ValidaSL2(oModelSL2, nLinhaAtu)
Local lRetorno   := .T.
Local nX         := 0
Local nValICM    := 0

If !oModelSL2:IsDeleted(nLinhaAtu)

    //Acumula os valores de ICMS do itens no total
    If lIntegICM
        For nX := 1 to oModelSL2:Length()
            nValICM += FwFldGet("L2_VALICM",nX)
        Next nX
        oMdlSL1:LoadValue("L1_VALICM",nValICM)
    EndIf

    If FwFldGet("L2_PRCTAB") <= 0
        oModelSL2:LoadValue("L2_PRCTAB", FwFldGet("L2_VRUNIT") )
    EndIf

    //Carrega corretamente o código do item
    If FwFldGet("L2_ITEM") == "**"
        oModelSL2:LoadValue("L2_ITEM", RSNumItem("SL2DETAIL", oModelSL2:Length()) )
    EndIf
EndIf

Return lRetorno

//--------------------------------------------------------
/*/{Protheus.doc} RSNumItem
Retorna o numero do Item de acordo com as regras do Protheus
@type function
@author  	rafael.pessoa
@since   	05/06/2019
@version 	P12
@return	    cRet - Numero do Item formatado 
/*/
//--------------------------------------------------------
Function RSNumItem(cModelo, nItem)

    Local cRet := ""

    Default nItem := oModelDef:GetModel(cModelo):Length() + 1

    cRet := STBPegaIT(nItem)

Return cRet

//--------------------------------------------------------
/*/{Protheus.doc} RSImprime
Retorna valor para o campo IMPRIME de acordo com a regra
@type function
@author  	rafael.pessoa
@since   	05/06/2019
@version 	P12
@return	    cRet - Valor do campo IMPRIME
/*/
//--------------------------------------------------------
Function RSImprime()

    Local cRet := "1N"

    If AllTrim(FwFldGet("L1_ESPECIE")) $ "NFM|SPED"
        cRet := "2N" 
    EndIf

Return cRet

//--------------------------------------------------------
/*/{Protheus.doc} RSPgFields
Grava valores complementares do cabeçalho da venda
apos ser preenchido nas linhas do pagamento.
@type function
@author  	rafael.pessoa
@since   	05/06/2019
@version 	P12
@return	    lRet - Retorno da Execução
/*/
//--------------------------------------------------------
Function RSPgFields()

    Local cFormaPgto := AllTrim(FwFldGet("L4_FORMA"))
    Local lRet := .T.

    If FwFldGet("L4_VALOR") > 0 .And. !Empty(cFormaPgto)

        Do Case
            Case IsMoney(cFormaPgto) 
                FwFldPut( "L1_DINHEIR" , FwFldGet("L4_VALOR") - FwFldGet("L4_TROCO"))            
            Case cFormaPgto == 'CH'
                FwFldPut( "L1_CHEQUES" , FwFldGet("L1_CHEQUES") + FwFldGet("L4_VALOR"))          
            Case cFormaPgto $ 'CC|CD'
                FwFldPut("L1_VENDTEF","S")
                IF cFormaPgto == 'CC'  
                    FwFldPut( "L1_CARTAO" , FwFldGet("L1_CARTAO") + FwFldGet("L4_VALOR"))
                Else
                    FwFldPut( "L1_VLRDEBI", FwFldGet("L1_VLRDEBI") + FwFldGet("L4_VALOR"))
                EndIf
            Case cFormaPgto == 'CO'
                FwFldPut( "L1_CONVENI", FwFldGet("L1_CONVENI") + FwFldGet("L4_VALOR"))
            Case cFormaPgto == 'VA'
                FwFldPut( "L1_VALES", FwFldGet("L1_VALES") + FwFldGet("L4_VALOR"))
            Case cFormaPgto == 'FI'
                FwFldPut( "L1_FINANC", FwFldGet("L1_FINANC") + FwFldGet("L4_VALOR"))
            Case cFormaPgto == 'CR'
                FwFldPut( "L1_CREDITO", FwFldGet("L4_VALOR"))
            OtherWise
                FwFldPut( "L1_OUTROS", FwFldGet("L1_OUTROS") + FwFldGet("L4_VALOR"))
        EndCase 

        If !(cFormaPgto $ SuperGetMV("MV_ENTEXCE",.F.,""))	// Formas de pagamento nao consideradas como entrada
            If IsMoney(cFormaPgto) 
                FwFldPut( "L1_ENTRADA" , FwFldGet("L4_VALOR") - FwFldGet("L4_TROCO"))
            Else
                FwFldPut( "L1_ENTRADA" , FwFldGet("L1_ENTRADA") + FwFldGet("L4_VALOR"))
            EndIf
        EndIf

        FwFldPut( "L1_FORMPG" , cFormaPgto)//Armazena ultima forma de pagamento 
        FwFldPut( "L1_PARCELA" , oModelDef:GetModel("SL4DETAIL"):Length())

    EndIf

Return lRet

//--------------------------------------------------------
/*/{Protheus.doc} RSParcel
Retorna a quantidade de poarcelas da venda
@type function
@author  	rafael.pessoa
@since   	05/06/2019
@version 	P12
@return	    nParcel - Retorna o quantidade de parcelas
/*/
//--------------------------------------------------------
Function RSParcel()

    Local nParcel := FwFldGet("L1_PARCELA")

    If FwFldGet("L1_PARCELA") <= 0
        nParcel := oModelDef:GetModel("SL4DETAIL"):Length()
    EndIf    
 
Return nParcel

//--------------------------------------------------------
/*/{Protheus.doc} RsGrvVenda
Rotina para gravação de venda\cancelamento utilizada pelo RMI

@author Rafael Tenorio da Costa
@since  11/12/19
@return { lRet, GetAutoGrLog() }
@uso    RetailSalesObj.prw e RmiEnvProtheusObj.prw
/*/
//--------------------------------------------------------
Function RsGrvVenda(aCab, aItens, aPagtos, nOpc)

    Local nPosSitua := 0
    Local lRet      := .T.
    Local aErroAuto := {}
    Local cErro     := ""
    Local nCont     := 0

    Private lMsHelpAuto     := .T. //Variavel de controle interno do ExecAuto
    Private lMsErroAuto 	:= .F. //Variavel que informa a ocorrência de erros no ExecAuto
    Private lAutoErrNoFile  := .T. //Força a gravação das informações de erro em array

    //Carrega a situação da venda\cancelamento
    nPosSitua := Ascan(aCab, {|x| x[1] == "L1_SITUA"})

    //Para manter o Legado de cancelamento do RMI JOB de Cancelamento 
    If nPosSitua > 0 .And. aCab[nPosSitua][2] == "IC"

        lRet := RMISLXGRV(aCab)
    Else
        If nOpc == 4
            DelSL4(aPagtos)//Deleta forma de pagamento execauto MVC não funciona Loja não grava ITEM e SL4 não tem Chave Unica.
        EndIf
        lRet := MsExecAuto( {|a,b,c,d| RetailSales(a,b,c,d)}, aCab, aItens, aPagtos, nOpc)
    EndIf

    If lMsErroAuto .Or. !lRet
        lRet      := .F.
        aErroAuto := GetAutoGrLog()

        For nCont := 1 To Len(aErroAuto)
            cErro += aErroAuto[nCont] + CRLF
        Next nCont
    EndIf

    Asize(aErroAuto, 0)

Return {lRet, cErro}

//--------------------------------------------------------
/*/{Protheus.doc} RSFormaId
Preenche o numero do ID do cartão na SL4

@author Varejo
@since  01/04/2021
@return { .T. }
@uso    RetailSalesObj.prw
/*/
//--------------------------------------------------------
Function RSFormaId()

Local oMdl       := oModelDef:GetModel('SL4DETAIL') //Pega o model da SL4
Local nX         := 0                               //Variavel de loop
Local aCartao    := {}                              //Guarda sempre o proximo NSU e Codigo de Autorizacao
Local nPos       := 0
Local nId        := 0
Local cFormaPgto := ""
Local nPosDin    := 0
Local nValor     := 0
Local nTroco     := 0
Local nItem      := 1

If !oMdl:IsEmpty()

    For nX := 1 to oMdl:Length()
        oMdl:GoLine(nX)

        cFormaPgto := AllTrim(FwFldGet("L4_FORMA",nX))

        Do Case

            Case cFormaPgto $ 'CC|CD'
                nPos  := aScan(aCartao,{|x| x[1] == AllTrim(FwFldGet("L4_AUTORIZ",nX))})
                If nPos > 0
                    oMdl:LoadValue("L4_FORMAID",cValToChar(aCartao[nPos][2]))
                Else
                    nId++
                    aAdd(aCartao,{AllTrim(FwFldGet("L4_AUTORIZ",nX)),nId})
                    oMdl:LoadValue("L4_FORMAID",cValToChar(aCartao[Len(aCartao)][2]))
                EndIf
            
            Case IsMoney(cFormaPgto)
                
                nValor += oMdl:GetValue("L4_VALOR")
                nTroco += oMdl:GetValue("L4_TROCO")

                If nPosDin == 0
                    nPosDin := nX
                Else
                    oMdl:DeleteLine()
                EndIf
            
        End Case

    Next nX

    //Agrupando a forma de pagamento dinheiro
    If nPosDin > 0
        oMdl:GoLine(nPosDin)
        oMdl:LoadValue("L4_VALOR", nValor)
        oMdl:LoadValue("L4_TROCO", nTroco)       
    EndIf

    For nX := 1 to oMdl:Length()
        oMdl:GoLine(nX)
        If !oMdl:IsDeleted()
            oMdl:LoadValue("L4_ITEM", STBPegaIT(nItem))
            nItem ++
        EndIf
    Next nX 

EndIf

Return .T.
//-------------------------------------------------------------------
/*/{Protheus.doc} ValidaSL4()
Valida a linha da SL4 e atualiza valores

@param 	oModelSL4 	- Model da SL4
@param 	nLinhaAtu	- Linha posicionada
@return lRetorno	- .T./.F. Determina se as informações foram alteradas corretamente
@author Everson S P Junior
@since  08/07/2022
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ValidaSL4(oModelSL4, nLinhaAtu)
Local lRetorno   := .T.

If !oModelSL4:IsDeleted(nLinhaAtu)

    If Len(FWGetSX5('24', PadR(FwFldGet("L4_FORMA"), TamSx3("X5_CHAVE")[1]))) == 0
        lRetorno := .F.
        Help( ,, 'FORMA DE PAGAMENTO' ,, '('+Alltrim(FwFldGet("L4_FORMA")) + ') - Forma de pagamento nao cadastrado no tabela SX5 !', 1,0)
    endIf

EndIf

Return lRetorno
//-------------------------------------------------------------------
/*/{Protheus.doc} DelSL4()
Deleta SL4 para poder atualizar incluir novamente via execAuto

@param 	aPagtos 	- Array ExecAuto da SL4
@author Everson S P Junior
@since  08/07/2022
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function DelSL4(aPagtos)
Local aArea      := GetArea()
Local aAreaSL4   := SL4->(GetArea())
Local nNum       := Ascan(aPagtos[1], {|x| x[1] == "L4_NUM"})
Local cNumOrc    := ""

cNumOrc := PadR(aPagtos[1][nNum][2],TAMSX3("L4_NUM")[1])

SL4->(dbSetOrder(1))
If SL4->(dbSeek(xFilial("SL4")+cNumOrc))
    While SL4->(!EoF()) .AND.  Alltrim(cNumOrc) == Alltrim(SL4->L4_NUM) .AND. xFilial("SL4") == SL4->L4_FILIAL
	    RecLock("SL4",.F.,.T.)
	    SL4->(dbDelete())
	    SL4->(dbSkip())
    EndDo
EndIf

RestArea(aAreaSL4)
RestArea(aArea)
Return
