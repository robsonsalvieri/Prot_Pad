#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "RMIPROCESSO.CH"

//Definições do array aProcessos
#DEFINE MIMFUNCOES  7
#DEFINE MIMDELET    5
#DEFINE MHNGATILH   8
#DEFINE ATUALIZA    9   //Define que ira atualizar este processo se encontrar
#DEFINE MHNF3       10
#DEFINE MHNCMPDES   11

#DEFINE MHSTABSEC   4  
#DEFINE MHSDELET    6

//-------------------------------------------------------------------
/*/{Protheus.doc} RmiCadProc
Processos

@author  Rafael Tenorio da Costa
@since   24/09/19
@version 1.0
/*/
//-------------------------------------------------------------------
Function RmiCadProc()

	Local oBrowse := Nil
    If AmIIn(12)// Acesso apenas para modulo e licença do Varejo
    
        //Carrega registros padrões
        Processa( {|| RmiCargaPr()}, STR0010, STR0011 )   //"Carregando Processos Padrões"   //"Aguarde. . ."
        
        oBrowse := FWMBrowse():New()
        
        oBrowse:SetDescription(STR0001)   //"Processos"
        oBrowse:SetAlias("MHN")
        oBrowse:SetLocate()
        oBrowse:Activate()
    else
        MSGALERT(STR0020)// "Esta rotina deve ser executada somente pelo módulo 12 (Controle de Lojas)"
    EndIf
Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Funcional

@return aRotina - Estrutura
[n,1] Nome a aparecer no cabecalho
[n,2] Nome da Rotina associada
[n,3] Reservado
[n,4] Tipo de Transação a ser efetuada:
1 - Pesquisa e Posiciona em um Banco de Dados
2 - Simplesmente Mostra os Campos
3 - Inclui registros no Bancos de Dados
4 - Altera o registro corrente
5 - Remove o registro corrente do Banco de Dados
6 - Alteração sem inclusão de registros
7 - Cópia
8 - Imprimir
[n,5] Nivel de acesso
[n,6] Habilita Menu Funcional

@author  Rafael Tenorio da Costa
@since   24/09/19
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina := {}
	
	aAdd( aRotina, { STR0002, "PesqBrw"           , 0, 1, 0, .T. } ) //"Pesquisar"
	aAdd( aRotina, { STR0003, "VIEWDEF.RMICADPROC", 0, 2, 0, NIL } ) //"Visualizar"
	aAdd( aRotina, { STR0004, "VIEWDEF.RMICADPROC", 0, 3, 0, NIL } ) //"Incluir"
	aAdd( aRotina, { STR0005, "VIEWDEF.RMICADPROC", 0, 4, 0, NIL } ) //"Alterar"
	aAdd( aRotina, { STR0006, "VIEWDEF.RMICADPROC", 0, 5, 0, NIL } ) //"Excluir"
	aAdd( aRotina, { STR0007, "VIEWDEF.RMICADPROC", 0, 8, 0, NIL } ) //"Imprimir"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Base da Decisão

@author  Rafael Tenorio da Costa
@since   24/09/19
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

	Local oView      := Nil
	Local oModel     := FWLoadModel("RMICADPROC")
	Local oStructMHN := FWFormStruct(2, "MHN")
    Local oStructMHS := FWFormStruct(2, "MHS")
    Local oStructMIM := Nil
    Local lMIM       := FwAliasInDic("MIM")
    Local aTamanho   := {40, 60}
    Local aEtapaCmb  := {}

    If lMIM
        oStructMIM := FWFormStruct(2, "MIM")
        oStructMIM:RemoveField("MIM_CPROCE")

        If MIM->( ColumnPos("MIM_DESCRI") ) > 0 .And. !oStructMIM:HasField("MIM_DESCRI")
            oStructMIM:AddField("MIM_DESCRI", GetSx3Cache("MIM_DESCRI", "X3_ORDEM"), RetTitle("MIM_DESCRI"), "", {}, "C", "", Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil, .T.)
        EndIf

        aEtapaCmb := StrTokArr( GetSx3Cache("MIM_ETAPA", "X3_CBOX"), ";" )

        If Len(aEtapaCmb) < 3
            Aadd(aEtapaCmb, "3=Pós Publicação")

            oStructMIM:SetProperty("MIM_ETAPA", MVC_VIEW_COMBOBOX, aEtapaCmb)
        EndIf

        aTamanho   := {30, 35, 35}
    EndIf

    If MHN->(FieldPos("MHN_CMPDES")) > 0 
        oStructMHN:SetProperty("MHN_CMPDES", MVC_VIEW_LOOKUP , "PSHSX3")
    endif

    oStructMHS:RemoveField("MHS_CPROCE")
	
	oView := FWFormView():New()
	oView:SetModel( oModel )
	oView:SetDescription(STR0001)   //"Processos"

	oView:AddField("MHNVIEW", oStructMHN, "MHNMASTER")
	oView:CreateHorizontalBox("MHNFIELD"  , aTamanho[1])
	oView:SetOwnerView("MHNVIEW", "MHNFIELD")
    oView:EnableTitleView("MHNVIEW", STR0001)           //"Processos"

   	oView:AddGrid("MHSVIEW", oStructMHS, "MHSDETAIL")
    oView:CreateHorizontalBox("MHSGRID", aTamanho[2])
    oView:SetOwnerView("MHSVIEW", "MHSGRID")
    oView:EnableTitleView("MHSVIEW", STR0008)           //"Tabelas Secundárias"

    If lMIM
        oView:AddGrid("MIMVIEW", oStructMIM, "MIMDETAIL")
        oView:CreateHorizontalBox("MIMGRID", aTamanho[3])
        oView:SetOwnerView("MIMVIEW", "MIMGRID")
        oView:EnableTitleView("MIMVIEW", STR0023)       //"Funções"
    EndIf

	oView:EnableControlBar(.T.)

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Base da Decisão

@author  Rafael Tenorio da Costa
@since   24/09/19
@version 1.0

@obs MHNMASTER - Processos
/*/
//-------------------------------------------------------------------
Static Function Modeldef()

	Local oModel     := Nil
	Local oStructMHN := FWFormStruct(1, "MHN")
    Local oStructMHS := FWFormStruct(1, "MHS")
    Local oStructMIM := Nil
    Local lMIM       := FwAliasInDic("MIM")
    Local aEtapaCmb  := {}

    If lMIM
        oStructMIM := FWFormStruct(1, "MIM")

        If MIM->( ColumnPos("MIM_DESCRI") ) > 0 .And. !oStructMIM:HasField("MIM_DESCRI")
            oStructMIM:AddField(RetTitle("MIM_DESCRI"), "", "MIM_DESCRI" , "C", TamSx3("MIM_DESCRI")[1], 0, Nil, Nil, Nil, Nil, Nil, Nil, Nil, .T.)
        EndIf

        aEtapaCmb := StrTokArr( GetSx3Cache("MIM_ETAPA", "X3_CBOX"), ";" )

        If Len(aEtapaCmb) < 3
            Aadd(aEtapaCmb, "3=Pós Publicação")

            oStructMIM:SetProperty("MIM_ETAPA", MODEL_FIELD_VALUES, aEtapaCmb)
        EndIf
    EndIf

    If MHS->(ColumnPos("MHS_TIPO")) > 0 
        oStructMHS:SetProperty("MHS_TIPO", MODEL_FIELD_WHEN, {|| FwFldGet('MHS_TABELA') == 'MIL'})
    EndIf
	
	//-----------------------------------------
	//Monta o modelo do formulário
	//-----------------------------------------
	oModel:= MPFormModel():New( "RMICADPROC", /*Pre-Validacao*/, {|oModel| RmiVldCmp(oModel)}, /*Commit*/, /*Cancel*/)
	oModel:SetDescription( STR0009 )    //"Modelo de Processo"

	oModel:AddFields( "MHNMASTER", NIL, oStructMHN, /*Pre-Validacao*/, /*Pos-Validacao*/ )
	oModel:GetModel( "MHNMASTER" ):SetDescription( STR0001 )    //"Processos"

    oModel:AddGrid("MHSDETAIL", "MHNMASTER", oStructMHS, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPost*/)
	oModel:GetModel("MHSDETAIL"):SetDescription(STR0008)  //"Tabelas Secundárias"
    iF !MHS->(ColumnPos("MHS_TIPO")) > 0 
        oModel:GetModel("MHSDETAIL"):SetUniqueLine( {"MHS_TABELA"})    
    else
        oModel:GetModel("MHSDETAIL"):SetUniqueLine( {"MHS_TABELA", "MHS_TIPO" } )    
    EndIf
	oModel:SetRelation("MHSDETAIL", { { "MHS_FILIAL", "MHN_FILIAL" }, { "MHS_CPROCE", "MHN_COD" } }, MHS->( IndexKey(1) ))  //MHS_FILIAL+MHS_CPROCE+MHS_TABELA
    oModel:SetOptional("MHSDETAIL", .T.)

    If lMIM
        oModel:AddGrid("MIMDETAIL", "MHNMASTER", oStructMIM, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPost*/)
        oModel:GetModel("MIMDETAIL"):SetDescription(STR0023)  //"Funções"
        oModel:GetModel("MIMDETAIL"):SetUniqueLine( {"MIM_ETAPA", "MIM_FUNCAO"} )
        oModel:SetRelation("MIMDETAIL", { { "MIM_FILIAL", "MHN_FILIAL" }, { "MIM_CPROCE", "MHN_COD" } }, MIM->( IndexKey(1) ))  //MIM_FILIAL+MIM_CPROCE+MIM_ETAPA
        oModel:SetOptional("MIMDETAIL", .T.)
    EndIf

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} RmiCargaPr
Rotina que ira efetuar a carga inicial caso não existão registros na tabela.

@author  Rafael Tenorio da Costa
@since   04/10/19
@version 1.0
/*/
//-------------------------------------------------------------------
Function RmiCargaPr()

    Local aProcessos := {}
    Local aTabSecund := {}
    Local aFuncoes   := {}
    Local lFieldTipo := MHS->( ColumnPos("MHS_TIPO") ) > 0
    Local lAtualiza  := .F.

    aTabSecund := {}
    Aadd(aTabSecund, {"MEU", "MEU_FILIAL+MEU_CODIGO","","1"})  
    Aadd(aTabSecund, {"MEV", "MEV_FILIAL+MEV_CODKIT","","1"})
    Aadd(aTabSecund, {"ACV", "ACV_FILIAL+ACV_CODPRO","","1"})
    Aadd(aTabSecund, {"SB5", "B5_FILIAL+B5_COD"     ,"","1"})
    If lFieldTipo
        Aadd(aTabSecund, {"MIL", "MIL_FILIAL+MIL_ENTRAD","MIL_TIPREL = 'FECP'"      ,"1", "FECP"        })
        Aadd(aTabSecund, {"MIL", "MIL_FILIAL+MIL_ENTRAD","MIL_TIPREL = 'ICMS'"      ,"1", "ICMS"        })
        Aadd(aTabSecund, {"MIL", "MIL_FILIAL+MIL_ENTRAD","MIL_TIPREL = 'PIS/COFINS'","1", "PIS/COFINS"  })
    EndIf
    aFuncoes := {}
    Aadd(aFuncoes  , {"2", "RMIPUBGRAD", STR0026, "1"})     //"Publica a variação da grade do produto"
    Aadd(aFuncoes  , {"1", "RMIIMPPRO" , STR0027, "2"})     //"Gera impostos na tabela auxiliar"
    Aadd(aFuncoes  , {"3", "RMIMIXPROD", STR0030, "2"}) //"Mix de Produto - Motor de promoções"
    Aadd(aFuncoes  , {"3", "RMISITPROD", STR0031,"2"})//"Situação do Produto - Motor de promoções"
    Aadd(aFuncoes  , {"1", "RMIMARCA", STR0036,"2"})//"Publicaçao de marca do produto - Venda Digital"
    Aadd(aProcessos, {"PRODUTO", "SB1", "B1_FILIAL+B1_COD", aClone(aTabSecund), "", "", aClone(aFuncoes),"",.F.,"SB1","B1_DESC"})

    aTabSecund := {}
    aFuncoes   := {}
    Aadd(aTabSecund, {"SB1", "B1_FILIAL+B1_COD","B1_TIPO IN ('PA','ME')","2"})  
    Aadd(aProcessos, {"PRODUTO SLK", "SLK", "LK_FILIAL+LK_CODIGO+LK_CODBAR", aClone(aTabSecund),"","1",aClone(aFuncoes),""}) //processo Código de barras PRODUTO SLK


    aTabSecund := {}
    aFuncoes   := {}
    Aadd(aProcessos, {"CLIENTE", "SA1", "A1_FILIAL+A1_COD+A1_LOJA", aClone(aTabSecund),"","",aClone(aFuncoes),"",.F.,"SA1","A1_NOME"})

    aTabSecund := {}
    aFuncoes   := {}
    MHN->( DBSetOrder(1) )  //MHN_FILIAL+MHN_COD
    If MHN->( Dbseek( xFilial("MHN") + PadR("PRECO", TamSx3("MHN_COD")[1]) ) )
        lAtualiza := !( (MHN->MHN_TABELA == "SB0" .And. !SuperGetMv("MV_LJCNVDA", , .F.)) .Or. (MHN->MHN_TABELA == "DA1" .And. SuperGetMv("MV_LJCNVDA", , .F.)) )
    EndIf
    If !SuperGetMv("MV_LJCNVDA", , .F.)
        Aadd(aProcessos, {"PRECO"   , "SB0", "B0_FILIAL+B0_COD"                         , aClone(aTabSecund), "", "" , aClone(aFuncoes), "", lAtualiza})
    Else
        Aadd(aTabSecund, {"DA0"     , "DA0_FILIAL+DA0_CODTAB"})
        Aadd(aProcessos, {"PRECO"   , "DA1", "DA1_FILIAL+DA1_CODPRO+DA1_CODTAB+DA1_ITEM", aClone(aTabSecund), "", "1", aClone(aFuncoes), "", lAtualiza})
    EndIf

    aTabSecund := {}
    Aadd(aTabSecund, {"SL2", "L2_FILIAL+L2_NUM"})
    Aadd(aTabSecund, {"SL4", "L4_FILIAL+L4_NUM"})                      	
    Aadd(aProcessos, {"VENDA"  , "SL1", "L1_FILIAL+L1_NUM" ,aClone(aTabSecund)})

    aTabSecund := {}
    Aadd(aTabSecund, {"SL2", "L2_FILIAL+L2_NUM"})
    Aadd(aTabSecund, {"SL4", "L4_FILIAL+L4_NUM"})                      	
    Aadd(aProcessos, {"PEDIDO", "SL1", "L1_FILIAL+L1_NUM", aClone(aTabSecund)})

    aTabSecund := {}
    aFuncoes   := {}    
    Aadd(aProcessos, {"CONFIRMA PAGTO", "SL1", "L1_FILIAL+L1_NUM", aClone(aTabSecund), "", "", aClone(aFuncoes), ""})

    aTabSecund := {}
    aFuncoes   := {}
    Aadd(aFuncoes  , {"2", "RMIPUBSTPE", STR0028, "1"})     //"Publica o status do pedido"
    Aadd(aProcessos, {"STATUS PEDIDO", "", "", aClone(aTabSecund), "", "", aClone(aFuncoes), "STATUSPEDIDO"})

    aTabSecund := {}
    aFuncoes   := {}
    Aadd(aProcessos, {"NCM","CLK","CLK_FILIAL+ CLK_CODNCM+ CLK_EX+ CLK_CODNBS+ CLK_UF+ CLK_VERSAO",aTabSecund,"&RMIFiltPro('NCM')","1"})
    
    
    aTabSecund := {}
    Aadd(aProcessos, {"CATEGORIA","ACU","ACU_FILIAL+ACU_COD",aTabSecund})

    aTabSecund := {}
    Aadd(aProcessos, {"UN MEDIDA","SAH","AH_FILIAL+AH_UNIMED",aTabSecund})

    aTabSecund := {}
    Aadd(aProcessos, {"CEST","F0G","F0G_FILIAL+F0G_CEST",aTabSecund})
    
    aTabSecund := {}
    Aadd(aProcessos, {"OPERADOR CAIXA","SA6","A6_FILIAL+A6_COD",aTabSecund})

    aTabSecund := {}
    Aadd(aProcessos, {"INVENTARIO","SB7","B7_FILIAL+B7_DATA+B7_COD+B7_LOCAL+B7_LOCALIZ+B7_NUMSERI+B7_LOTECTL+B7_NUMLOTE+B7_CONTAGE",aTabSecund})
    
    aTabSecund := {}
    Aadd(aProcessos, {"IMPOSTO PROD","XXX","PROCESSO EXCLUSIVO DO SISTEMA",aTabSecund})

    aTabSecund := {}
    Aadd(aProcessos, {"IMPOSTO VENDA","YYY","PROCESSO EXCLUSIVO DO SISTEMA",aTabSecund})

    aTabSecund  := {}
    Aadd(aTabSecund, {"MEN", "MEN_FILIAL+MEN_CODADM"})
    aFuncoes    := {}
    Aadd(aFuncoes  , {"3", "RMIPUBCNPG", STR0029, "2"})     //"Publica a Condição de Pagamento"
    Aadd(aProcessos, {"ADMINISTRADORA", "SAE", "AE_FILIAL+AE_COD", aClone(aTabSecund), "", "", aClone(aFuncoes), ""})

    aTabSecund  := {}
    aFuncoes    := {}
    Aadd(aProcessos, {"CONDICAO PAGTO", "", "", aClone(aTabSecund), "", "", aClone(aFuncoes), "CONDICAOPAGTO"})

    aTabSecund  := {}
    aFuncoes    := {}
    Aadd(aProcessos, {"CONSOLIDADO", "", "", aClone(aTabSecund), "", "", aClone(aFuncoes), "CONSOLIDADO"})


    aTabSecund := {}
    aFuncoes   := {}
    Aadd(aProcessos, {"SANGRIA"     , "SE5", "", aClone(aTabSecund), "", "", aClone(aFuncoes), ""})

    aTabSecund := {}
    aFuncoes   := {}
    Aadd(aProcessos, {"SUPRIMENTO"  , "SE5", "", aClone(aTabSecund), "", "", aClone(aFuncoes), ""})    

    aTabSecund := {}
    Aadd(aProcessos, {"FORNECEDOR", "SA2", "A2_FILIAL+A2_COD+A2_LOJA", aTabSecund})

    aTabSecund := {}
    Aadd(aTabSecund, {"SD1", "D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA"})
    Aadd(aProcessos, {"NOTA DE ENTRADA" , "SF1", "F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA", aClone(aTabSecund), "F1_CHVNFE <> '' AND F1_ORIGEM <> 'SMARTCON' AND D_E_L_E_T_ = ' '"})
    
    aTabSecund := {}
    Aadd(aTabSecund, {"SD2", "D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA"})
    Aadd(aProcessos, {"NOTA DE SAIDA"   , "SF2", "F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA", aClone(aTabSecund), "F2_CHVNFE <> '' AND D_E_L_E_T_ = ' '"})

    aTabSecund := {}
    Aadd(aTabSecund, {"SD2", "D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA", "D_E_L_E_T_ = '*'"})
    Aadd(aProcessos, {"NOTA SAIDA CANC" , "SF2", "F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA", aClone(aTabSecund), "F2_CHVNFE <> '' AND D_E_L_E_T_ = '*'"})

    If FwAliasInDic("MIH")
        aTabSecund := {}
        Aadd(aProcessos, {"PERFIL OPERADOR" , "MIH", "MIH_FILIAL+MIH_TIPCAD+MIH_DESC", aClone(aTabSecund), "MIH_TIPCAD = '" + PadR("PERFIL DE OPERADOR" , TamSX3("MIH_TIPCAD")[1] ) + "'"})

        aTabSecund := {}
        Aadd(aProcessos, {"OPERADOR LOJA"   , "MIH", "MIH_FILIAL+MIH_TIPCAD+MIH_DESC", aClone(aTabSecund), "MIH_TIPCAD = '" + PadR("OPERADOR DE LOJA"   , TamSX3("MIH_TIPCAD")[1] ) + "'"})

        aTabSecund := {}
        Aadd(aProcessos, {"FORMA PAGAMENTO" , "MIH", "MIH_FILIAL+MIH_TIPCAD+MIH_DESC", aClone(aTabSecund), "MIH_TIPCAD = '" + PadR("FORMA DE PAGAMENTO" , TamSX3("MIH_TIPCAD")[1] ) + "'"})

        aTabSecund := {}
        aFuncoes   := {}
        Aadd(aFuncoes  , {"1", "RmiPubPais",STR0032, "2"}) // "Publica Pais Motor de Promoções"
        Aadd(aFuncoes  , {"1", "RmiPubEst", STR0033, "2"})   // "Publica Estado Motor de Promoções"
        Aadd(aFuncoes  , {"1", "RmiPubCid",  STR0034, "2"})   //"Publica Cidade Motor de Promoções"
        Aadd(aFuncoes  , {"1", "RmiPubRegi",STR0035 , "2"})   //"Publica Região Motor de Promoções"
        Aadd(aProcessos, {"CADASTRO LOJA" , "MIH", "MIH_FILIAL+MIH_TIPCAD+MIH_DESC", aClone(aTabSecund), "MIH_TIPCAD = '" + PadR("CADASTRO DE LOJA" , TamSX3("MIH_TIPCAD")[1] ) + "'","",aClone(aFuncoes)})

        aTabSecund := {}
        aFuncoes   := {}
        Aadd(aProcessos, {"GRUPO DE LOJAS" , "MIH", "MIH_FILIAL+MIH_TIPCAD+MIH_DESC", aClone(aTabSecund), "MIH_TIPCAD = '" + PadR("GRUPO DE LOJAS" , TamSX3("MIH_TIPCAD")[1] ) + "'"})

        aTabSecund := {}
        aFuncoes   := {}
        Aadd(aProcessos, {"COMPARTILHAMENT" , "MIH", "MIH_FILIAL+MIH_TIPCAD+MIH_DESC", aClone(aTabSecund), "MIH_TIPCAD = '" + PadR("COMPARTILHAMENTOS" , TamSX3("MIH_TIPCAD")[1] ) + "'"})

        aTabSecund := {}
        Aadd(aProcessos, {"ICMS" , "MIH", "MIH_FILIAL+MIH_TIPCAD+MIH_DESC", aClone(aTabSecund), "MIH_TIPCAD = '" + PadR("ICMS" , TamSX3("MIH_TIPCAD")[1] ) + "'"})

        aTabSecund := {}
        Aadd(aProcessos, {"PIS/COFINS" , "MIH", "MIH_FILIAL+MIH_TIPCAD+MIH_DESC", aClone(aTabSecund), "MIH_TIPCAD = '" + PadR("PIS/COFINS" , TamSX3("MIH_TIPCAD")[1] ) + "'"})
    
        aTabSecund := {}
        Aadd(aProcessos, {"MARCAS" , "MIH", "MIH_FILIAL+MIH_TIPCAD+MIH_DESC", aClone(aTabSecund), "MIH_TIPCAD = '" + PadR("MARCAS" , TamSX3("MIH_TIPCAD")[1] ) + "'"})

        aTabSecund := {}
        Aadd(aProcessos, {"COMPL PAGAMENTO" , "MIH", "MIH_FILIAL+MIH_TIPCAD+MIH_DESC", aClone(aTabSecund), "MIH_TIPCAD = '" + PadR("COMPLEM PAGAMENTO" , TamSX3("MIH_TIPCAD")[1] ) + "'"})
    
        aTabSecund  := {}
        aFuncoes    := {}
        Aadd(aProcessos, {"PRACA" , "MIH", "MIH_FILIAL+MIH_TIPCAD+MIH_DESC", aClone(aTabSecund), "MIH_TIPCAD = '" + PadR("PRACA" , TamSX3("MIH_TIPCAD")[1] ) + "'","",aClone(aFuncoes)})
    
    EndIf
    
    aTabSecund := {}
    Aadd(aProcessos, {"SALDO ESTOQUE", "SB2", "B2_FILIAL+B2_LOCAL+B2_COD", aTabSecund})
    
    aTabSecund := {}
    Aadd(aProcessos, {"GRADE", "SBV", "BV_FILIAL+BV_TABELA+BV_CHAVE", aTabSecund})

    aTabSecund := {}
    aFuncoes    := {}
    Aadd(aProcessos, {"EMBALAGEM","SB1", "B1_FILIAL+B1_COD", aClone(aTabSecund), "", "", aClone(aFuncoes),"",.F.,"SB1","B1_DESC"})

    aTabSecund  := {}
    aFuncoes    := {}
    Aadd(aProcessos, {"PAIS", "", "", aClone(aTabSecund), "", "", aClone(aFuncoes), "PAIS"})
    
    aTabSecund  := {}
    aFuncoes    := {}
    Aadd(aProcessos, {"ESTADO", "", "", aClone(aTabSecund), "", "", aClone(aFuncoes), "ESTADO"})
    
    aTabSecund  := {}
    aFuncoes    := {}
    Aadd(aProcessos, {"CIDADE", "", "", aClone(aTabSecund), "", "", aClone(aFuncoes), "CIDADE"})

    aTabSecund  := {}
    aFuncoes    := {}
    Aadd(aProcessos, {"MIX DE PRODUTO", "", "", aClone(aTabSecund), "", "", aClone(aFuncoes), "MIXPROD"})

    aTabSecund  := {}
    aFuncoes    := {}
    Aadd(aProcessos, {"SITUACAO PRODUT", "", "", aClone(aTabSecund), "", "", aClone(aFuncoes), "SITPROD"})
    
    aTabSecund  := {}
    aFuncoes    := {}
    Aadd(aProcessos, {"PRACA" , "MIH", "MIH_FILIAL+MIH_TIPCAD+MIH_DESC", aClone(aTabSecund), "MIH_TIPCAD = '" + PadR("PRACA" , TamSX3("MIH_TIPCAD")[1] ) + "'","",aClone(aFuncoes)})

    aTabSecund  := {}
    aFuncoes    := {}
    Aadd(aProcessos, {"REGIAO", "", "", aClone(aTabSecund), "", "", aClone(aFuncoes), "REGIAO"})

    aTabSecund  := {}
    Aadd(aFuncoes  , {"2", "RMIPUBCONF","Criação de publicação de conferencia", "2"}) // "Criação de publicação de conferencia"
    Aadd(aProcessos, {"CONFERENCIA", "", "", aClone(aTabSecund), "", "", aClone(aFuncoes), "CONFERENCIA"})
    aTabSecund  := {}
    aFuncoes    := {}
    Aadd(aProcessos, {"PROMOCOES", "", "", aClone(aTabSecund), "", "", aClone(aFuncoes), "PROMOCOES"})    

    aTabSecund := {}
    Aadd(aFuncoes  , {"1", "SHPSTATUS",STR0028 , "1"})  //"Publica o status do pedido"
    Aadd(aProcessos, {"PEDIDO RETIRA", "SL1", "L1_FILIAL+L1_NUM", aClone(aTabSecund),"L1_ECPEDEC <> '' AND L1_SITUA = 'OK' AND L1_KEYNFCE != '' AND L1_ORCRES = '' AND L1_ORIGEM = 'N' AND L1_UMOV != ''",,aClone(aFuncoes)})

    aTabSecund  := {}
    Aadd(aProcessos, {"MUNICIPIOS","CC2","CC2_FILIAL+CC2_EST+CC2_CODMUN",aTabSecund})

    If FwAliasInDic("U25")

        aTabSecund := {}
        Aadd(aProcessos, {"PARAMETROS","MIH","MIH_FILIAL+MIH_TIPCAD+MIH_DESC",aTabSecund,"MIH_TIPCAD = '" + PadR("PARAMETROS" , TamSX3("MIH_TIPCAD")[1] ) + "'"})

        aTabSecund := {}
        Aadd(aProcessos, {"NEGOCIACAO","U44","U44_FILIAL+U44_FORMPG+U44_CONDPG",aTabSecund})

        aTabSecund := {}
        Aadd(aProcessos, {"NEG. CLIENTE","U53","U53_FILIAL+U53_FORMPG+U53_CONDPG+U53_CODCLI+U53_LOJA+U53_GRPVEN+U53_ITEM",aTabSecund})

        aTabSecund := {}
        Aadd(aProcessos, {"PRECO NEGOCIADO","U25","U25_FILIAL+U25_REPLIC",aTabSecund})

    endif

    aTabSecund  := {}
    aFuncoes    := {}
    Aadd(aProcessos, {"IMPOSTO" , "MIH", "MIH_FILIAL+MIH_TIPCAD+MIH_DESC", aClone(aTabSecund), "MIH_TIPCAD = '" + PadR("IMPOSTO" , TamSX3("MIH_TIPCAD")[1] ) + "'","",aClone(aFuncoes)})

    aTabSecund  := {}
    aFuncoes    := {}
    Aadd(aProcessos, {"PRODUTO IMPOSTO" , "MIL", "MIL_FILIAL+MIL_TIPREL+MIL_FILENT+MIL_ENTRAD+MIL_SAIDA", aClone(aTabSecund), "MIL_TIPREL LIKE 'IMPOSTO_%'","",aClone(aFuncoes)})

    aTabSecund := {}
    aFuncoes   := {}
    Aadd(aProcessos, {"LOG", "MHL", "MHL_FILIAL+MHL_ALIAS+STR(MHL_RECNO, 12, 0)+STR(MHL_SEQ, 5, 0)", aClone(aTabSecund),"MHL_CASSIN = 'SMARTLINK'","",aClone(aFuncoes)})

    RmiGrvProc(aProcessos,.T.) //Efetua a gravação dos processos e de suas dependências

    FwFreeArray(aProcessos)
    FwFreeArray(aTabSecund)
    FwFreeArray(aFuncoes)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} RmiVldCmp
Rotina que ira efetuar a validação de todos os campos chaves, tanto
do cabeçalho quanto das tabelas secundarias

@author  Bruno Almeida
@since   13/11/2019
@version 1.0

/*/
//-------------------------------------------------------------------
Function RmiVldCmp(oModel)

Local lRet      := .T. //Variavel de retorno
Local oCab      := oModel:GetModel('MHNMASTER') //Model do cabecalho
Local oItens    := oModel:GetModel('MHSDETAIL') //Model dos itens
Local nX        := 0 //Variavel de loop
Local nI        := 0 //Variavel de loop
Local aCab      := {} //Campos do cabecalho
Local aItens    := {} //Campos de itens
Local cTabela   := "" //Tabela
Local nOperation:= oModel:GetOperation() //Operacao executada no modelo de dados.
Local lIsDelete := nOperation == MODEL_OPERATION_DELETE

If lIsDelete .OR. nOperation == MODEL_OPERATION_UPDATE
    If Alltrim(oCab:GetValue('MHN_TABELA')) == "XXX" .OR. Alltrim(oCab:GetValue('MHN_COD')) == "IMPOSTO PROD"
        lRet := .F.
        Help( ,, 'HELP',, oCab:GetValue('MHN_CHAVE'), 1, 0)//"É necessario preencher o campo Chave da tabela "
    EndIf

    If lRet .And. lIsDelete

        lRet := MsgNoYes( STR0021, Upper(STR0022) )     //"Será excluida a informação cadastrada na tabela MHP - Assinantes X Processos. Deseja prosseguir com a exclusão ?"    "Confirma Exclusão?"

        If lRet
            lRet := RMCPDelMHP(AllTrim(oCab:GetValue('MHN_COD')))
        EndIf
    EndIf
EndIf

If lRet .And. ( nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE )

    //Valida os campos do cabecalho
    If !Empty(oCab:GetValue('MHN_CHAVE')) .AND. !Empty(oCab:GetValue('MHN_TABELA'))

        aCab    := Separa(oCab:GetValue('MHN_CHAVE'),'+')
        cTabela := oCab:GetValue('MHN_TABELA')

        For nX := 1 To Len(aCab)
            If (cTabela)->(ColumnPos(aCab[nX])) == 0
                lRet := .F.
                MsgAlert(STR0012 + AllTrim(aCab[nX]) + STR0013 + cTabela) //"O campo " # " não existe na tabela "
                Exit
            EndIf

        Next nX

    EndIf

    //Valida os campos das tabelas secundarias
    If lRet

        For nX := 1 To oItens:Length()
            oItens:GoLine(nX)
            If !Empty(oItens:GetValue('MHS_TABELA'))
                If !Empty(oCab:GetValue('MHN_CHAVE'))
                    If !Empty(oItens:GetValue('MHS_CHAVE'))
                        aItens  := Separa(oItens:GetValue('MHS_CHAVE'),'+')
                        cTabela := oItens:GetValue('MHS_TABELA')

                        For nI := 1 To Len(aItens)
                            If (cTabela)->(ColumnPos(aItens[nI])) == 0
                                lRet := .F.
                                Help( ,, 'HELP',, STR0012 + AllTrim(aItens[nI]) + STR0013 + cTabela, 1, 0)//"O campo " # " não existe na tabela "
                                Exit
                            EndIf

                        Next nX
                    Else
                        lRet := .F.
                        Help( ,, 'HELP',, STR0014 + oItens:GetValue('MHS_TABELA'), 1, 0)//"É necessario preencher o campo Chave da tabela "
                    EndIf
                Else
                    lRet := .F.
                    Help( ,, 'HELP',, STR0014 + oCab:GetValue('MHN_TABELA'), 1, 0)//"É necessario preencher o campo Chave da tabela "
                EndIf

                If !lRet
                    Exit
                EndIf

            EndIf

        Next nX
    EndIf

    If lRet

        If oCab:HasField("MHN_GATILH")

            If Empty( oCab:GetValue("MHN_TABELA") ) .And. Empty( oCab:GetValue("MHN_GATILH") )
                lRet := .F.            
                oModel:SetErrorMessage("MHNMASTER", , , , , STR0024)    //"Processo inválido, um dos campos, tabela ou gatilho deve ser preenchido."
            EndIf
        Else

            If Empty( oCab:GetValue("MHN_TABELA") )
                lRet := .F.            
                oModel:SetErrorMessage("MHNMASTER", , , , , STR0025)    //"Processo inválido, campo tabela deve ser preenchido."
            EndIf
        EndIf
    EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} RmiVldFilt
Essa função tem o objetivo de validar os campos que foram digitados no 
filtro.

@author  Bruno Almeida
@since   02/07/2020
@version 1.0

/*/
//-------------------------------------------------------------------
Function RmiVldFilt(oCab, oItens)

Local lRet      := .T.  //Variavel de retorno
Local aFiltro   := {}   //Recebe os campos que foram digitados no filtro
Local nI        := 0    //Variavel de loop
Local nX        := 0    //Variavel de loop
Local cTags     := "AND|OR|=|D_E_L_E_T_|R_E_C_N_O_|R_E_C_D_E_L_" //Tags que não fazem parte da comparação

Default oCab    := Nil
Default oItens  := Nil

If ValType(oCab) == "O" .AND. ValType(oItens) == "O"
    If !Empty(oCab:GetValue('MHN_FILTRO'))
        //Transforma em um array o conteudo do filtro
        aFiltro := Separa(AllTrim(oCab:GetValue('MHN_FILTRO'))," ")

        //Caso o array aFiltro não seja no minimo um tamanho de 3 posições,
        //significa que o filtro não é valido.
        If Len(aFiltro) >= 3
            If !(AllTrim(aFiltro[1]) $ 'AND|OR')
                //Percorre cada uma das posições do array para validar todos os campos
                For nI := 1 To Len(aFiltro)

                    //Caso a posição do array seja um espaço em branco ou algumas das palavras listados no contém, não é necessario validar
                    If !Empty(aFiltro[nI]) .AND. !(AllTrim(aFiltro[nI]) $ cTags)

                        //Pega o conteudo do array e tenta verificar se é um campo
                        If (AllTrim(SubStr(aFiltro[nI],4,1)) == "_" ) .OR. (AllTrim(SubStr(aFiltro[nI],3,1)) == "_")
                            
                            If (oCab:GetValue('MHN_TABELA'))->(ColumnPos(aFiltro[nI])) == 0
                                lRet := .F.
                                Help( ,, 'HELP',, STR0012 + AllTrim(aFiltro[nI]) + STR0013 + AllTrim(oCab:GetValue('MHN_TABELA')), 1, 0,,,,,,{STR0015 + AllTrim(oCab:GetValue('MHN_FILTRO'))})//"O campo " # " não existe na tabela " # "Por favor, corrija o filtro -> "
                                Exit
                            EndIf

                        EndIf
                    EndIf
                Next nI
            Else
                lRet := .F.
                Help( ,, 'HELP',, STR0018 + AllTrim(oCab:GetValue('MHN_TABELA')) + STR0019, 1, 0,,,,,,{STR0015 + AllTrim(oCab:GetValue('MHN_FILTRO'))})//"O filtro da tabela " # " não pode iniciar com as palavras AND ou OR." # "Por favor, corrija o filtro -> "
            EndIf
        Else
            lRet := .F.
            Help( ,, 'HELP',, STR0016 + AllTrim(oCab:GetValue('MHN_TABELA')) + STR0017, 1, 0,,,,,,{STR0015 + AllTrim(oCab:GetValue('MHN_FILTRO'))}) //"O filtro informado para a tabela " # " não é valido." # "Por favor, corrija o filtro -> "
        EndIf
    EndIf

    If lRet
        //Lê cada linha do grid
        For nX := 1 To oItens:Length()
            oItens:GoLine(nX)
            
            If !Empty(oItens:GetValue('MHS_FILTRO'))

                //Transforma em um array o conteudo do filtro
                aFiltro := Separa(AllTrim(oItens:GetValue('MHS_FILTRO'))," ")
                
                //Para o filtro, deve-se haver pelo menos três posições 
                //para considerar um filtro valido
                If Len(aFiltro) >= 3
                    If !(AllTrim(aFiltro[1]) $ 'AND|OR')

                        //Loop para percorrer cada uma das posições
                        For nI := 1 To Len(aFiltro)

                            //Caso não seja nenhuma das palavras abaixo, então entra no IF
                            If !Empty(aFiltro[nI]) .AND. !(AllTrim(aFiltro[nI]) $ cTags)

                                If (AllTrim(SubStr(aFiltro[nI],4,1)) == "_") .OR. (AllTrim(SubStr(aFiltro[nI],3,1)) == "_")

                                    If (oItens:GetValue('MHS_TABELA'))->(ColumnPos(aFiltro[nI])) == 0
                                        lRet := .F.
                                        Help( ,, 'HELP',, STR0012 + AllTrim(aFiltro[nI]) + STR0013 + AllTrim(oItens:GetValue('MHS_TABELA')), 1, 0,,,,,,{STR0015 + AllTrim(oItens:GetValue('MHS_FILTRO'))})//"O campo " # " não existe na tabela " # "Por favor, corrija o filtro -> "
                                        Exit
                                    EndIf
                                EndIf
                            EndIf
                        Next nI
                    Else
                        lRet := .F.
                        Help( ,, 'HELP',, STR0018 + AllTrim(oItens:GetValue('MHS_TABELA')) + STR0019, 1, 0,,,,,,{STR0015 + AllTrim(oItens:GetValue('MHS_FILTRO'))})//"O filtro da tabela " # " não pode iniciar com as palavras AND ou OR." # "Por favor, corrija o filtro -> "
                    EndIf
                Else
                    lRet := .F.
                    Help( ,, 'HELP',, STR0016 + AllTrim(oItens:GetValue('MHS_TABELA')) + STR0017, 1, 0,,,,,,{STR0015 + AllTrim(oItens:GetValue('MHS_FILTRO'))}) //"O filtro informado para a tabela " # " não é valido." # "Por favor, corrija o filtro -> "
                EndIf
                If !lRet
                    Exit
                EndIf
            EndIf
        Next nX
    EndIf

EndIf

Return lRet

/*/{Protheus.doc} RMCPDelMHP
    Usado para deletar o dado que está associado na tabela MHP
    @type  Function
    @author Julio.Nery
    @since 12/01/2021
    @version 12
    @param cProcesso, caracter, processo que será pesquisado
    @return lRet, lógico, se excluiu ou não
/*/
Static Function RMCPDelMHP(cProcesso)
Local lRet  := .F.
Local cQuery:= ""
Local cTabela:= "XTABMHP"

If !Empty(cProcesso)
    LjGrvLog("RMICADPROC","Inicio do processo de deleção da MHP associada a MHN")
    cQuery := " SELECT R_E_C_N_O_ REC "
    cQuery += " FROM " + RetSqlName("MHP")
    cQuery += " WHERE MHP_FILIAL = '" + xFilial("MHP") + "' AND MHP_CPROCE = '" + cProcesso + "'"
    cQuery += " AND D_E_L_E_T_ = '' "
    DbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cTabela, .T., .F.)

    If (cTabela)->(Eof())
        LjGrvLog("RMICADPROC","Não existe MHP associada a MHN")
    EndIf

    While (cTabela)->(!Eof())
        MHP->(DBGoTo((cTabela)->REC))
        RecLock("MHP",.F.)
            MHP->(DBDelete())
        MHP->(DBUnlock())
        LjGrvLog("RMICADPROC","Registro MHP Deletado com sucesso - Processo [" + cProcesso + "]" +;
                            " / Recno [" + cValToChar((cTabela)->REC) + "]")
        (cTabela)->( DbSkip() )
    EndDo

    (cTabela)->( DbCloseArea() )
    lRet := .T.
    LjGrvLog("RMICADPROC","Término do processo de deleção da MHP associada a MHN")
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} RMIFiltPro
Rotina para armazenar os filtros padrão dos processos cadastrados.

@author  Evandro Pattaro
@since   27/07/2022
@version 1.0
/*/
//-------------------------------------------------------------------
Function RMIFiltPro(cProce)
    Local cFilter := ""
    Local cEndFis := ""
    Local cEst    := ""
    
    
    Do Case
        Case cProce == 'NCM'

            cEndFis := IIf(SuperGetMv("MV_SPEDEND",, .F.),"M0_ESTCOB","M0_ESTENT")		// Se estiver como F refere-se ao endereço de Cobrança se estiver T  ao  endereço de Entrega.
            cEst := FWSM0Util():GetSM0Data( cEmpAnt , cFilAnt  ,{cEndFis})[1][2]
            cFilter :=  "(CLK_DTINIV <= '"+DTOS(DATE())+"' AND CLK_DTFIMV >= '"+ DTOS(DATE())+"') AND CLK_UF = '"+cEst+"' "
            cFilter += " AND CLK_CODNCM != '' AND EXISTS(SELECT (1) FROM "+RetSqlName("SB1")+" B1 WHERE B1.B1_POSIPI = CLK_CODNCM AND B1.D_E_L_E_T_ = ' ') "

            If Empty(cEst)
                LjGrvLog("RMICADPROC","Campo "+cEndFis+" vazio! Verifique o parametro MV_SPEDEND")
            EndIf
            
        Case cProce == "SALDO ESTOQUE" //Filtra se o produto tem configuração para envio ao E-commerce (B5_ECFLAG = '1')
            cFilter := "B2_COD IN (SELECT B5_COD FROM "+RetSqlName("SB5")+" Where B5_FILIAL = '"+xFilial("SB5")+"' AND B5_ECFLAG = '1' AND B5_MARCA != ''  ) "

        Case cProce == "PRECO"
            If !SuperGetMv("MV_LJCNVDA", , .F.)
                cFilter := "B0_COD IN (SELECT B5_COD FROM "+RetSqlName("SB5")+" Where B5_FILIAL = '"+xFilial("SB5")+"' AND B5_ECFLAG = '1' AND B5_MARCA != '' ) "
            else
                cFilter := "DA1_CODPRO IN (SELECT B5_COD FROM "+RetSqlName("SB5")+" Where B5_FILIAL = '"+xFilial("SB5")+"' AND B5_ECFLAG = '1' AND B5_MARCA != '' ) "
            EndIf            
        Case cProce == "PROD VENDA DIGITAL"// Filtro no produto utilizado no venda digital.
            cFilter := "B1_TIPO IN ('PA','ME') AND EXISTS(SELECT (1) FROM  "+RetSqlName("SB5")+" B5 WHERE B5.B5_COD = B1_COD  AND B5.B5_FILIAL = '"+fwXfilial("SB5")+"' AND  B5.B5_MARCA <>'' AND B5.B5_ECFLAG = '1' AND B5.D_E_L_E_T_ = ' ')" 
    End Case

Return cFilter

//-------------------------------------------------------------------
/*/{Protheus.doc} RmiGrvProc
Efetua a gravação dos dados referentes ao processo, tabelas> MHN, MHS e MIM
Anteriormente feito pela função RmiCargaPr.

@author
@since
@version 12.1.2310
/*/
//-------------------------------------------------------------------
Function RmiGrvProc(aProcessos,lInclui)

    Local aArea      := GetArea()
    Local lCmpMhnFil := MHN->( ColumnPos("MHN_FILTRO")  ) > 0
    Local lCmpMhsFil := MHS->( ColumnPos("MHS_FILTRO")  ) > 0
    Local lCmpMhnSec := MHN->( ColumnPos("MHN_SECOBG")  ) > 0
    Local lFieldPub  := MHS->( ColumnPos("MHS_CONPUB")  ) > 0
    Local lFieldTipo := MHS->( ColumnPos("MHS_TIPO")    ) > 0
    Local lMIM       := FwAliasInDic("MIM")
    Local nProc      := 1
    Local nCont      := 1
    Local lCmpDescri := .F.
    Local lCmpAtivo  := .F.
    Local lExistMHN  := .F.
    Local lExistMHS  := .F.
    Local lExistMIM  := .F.
    Local lAtualiza  := .F.

    Default aProcessos := {}
    Default lInclui := .T.

    If lMIM
        lCmpDescri := MIM->( ColumnPos("MIM_DESCRI") ) > 0
        lCmpAtivo  := MIM->( ColumnPos("MIM_ATIVO" ) ) > 0
    EndIf

    MHN->( DBSetOrder(1) )  //MHN_FILIAL+MHN_COD
    ProcRegua(3)
    
    Begin Transaction

        For nProc:=1 To Len(aProcessos)

            lAtualiza := .F.

            If Len(aProcessos[nProc]) >= ATUALIZA
                lAtualiza := aProcessos[nProc][ATUALIZA]
            EndIf

            IncProc()
            lExistMHN := MHN->( Dbseek( xFilial("MHN") + PadR(aProcessos[nProc][1], TamSx3("MHN_COD")[1]) ) )
            If (lInclui .AND. !lExistMHN) .OR. !lInclui .Or. lAtualiza

                RecLock("MHN", IIF( !lExistMHN, .T., .F.) )
                    MHN->MHN_FILIAL := xFilial("MHN")
                    MHN->MHN_COD    := aProcessos[nProc][1]
                    MHN->MHN_TABELA := aProcessos[nProc][2]
                    MHN->MHN_CHAVE  := aProcessos[nProc][3]

                    If lCmpMhnFil  .And. Len(aProcessos[nProc]) > 4
                        MHN->MHN_FILTRO := aProcessos[nProc][5]
                    EndIf

                    If lCmpMhnSec  .And. Len(aProcessos[nProc]) > 5
                        MHN->MHN_SECOBG := aProcessos[nProc][6]
                    EndIf

                    If MHN->( ColumnPos("MHN_GATILH") ) > 0 .And. Len(aProcessos[nProc]) >= MHNGATILH
                        MHN->MHN_GATILH := aProcessos[nProc][MHNGATILH]
                    EndIf

                    If MHN->( ColumnPos("MHN_F3") ) > 0 .And. Len(aProcessos[nProc]) >= MHNF3
                        MHN->MHN_F3 := aProcessos[nProc][MHNF3]
                    EndIf
                    
                    If MHN->( ColumnPos("MHN_CMPDES") ) > 0 .And. Len(aProcessos[nProc]) >= MHNCMPDES
                        MHN->MHN_CMPDES := aProcessos[nProc][MHNCMPDES]
                    EndIf                       
                MHN->( MsUnLock() )

                //Inclui Tabelas Secundárias
                aTabSecund := aProcessos[nProc][MHSTABSEC]

                For nCont:=1 To Len(aTabSecund)
                    lExistMHS := MHS->( Dbseek( xFilial("MHS") + PadR(aProcessos[nProc][1], TamSx3("MHS_CPROCE")[1]) + PadR(aTabSecund[nCont][1],TamSx3("MHS_TABELA")[1]) + IIf(Len(aTabSecund[nCont]) > 4,aTabSecund[nCont][5],"") ) )
                    
                        RecLock("MHS", IIF( !lExistMHS, .T., .F.) )
                            If !lInclui .AND. Len(aTabSecund[nCont]) >= MHSDELET .AND. aTabSecund[nCont][MHSDELET] == "*"
                                MHS->(DBDelete())        
                            Else
                                MHS->MHS_FILIAL := MHN->MHN_FILIAL
                                MHS->MHS_CPROCE := MHN->MHN_COD
                                MHS->MHS_TABELA := aTabSecund[nCont][1]
                                MHS->MHS_CHAVE  := aTabSecund[nCont][2]

                                If lCmpMhsFil  .And. Len(aTabSecund[nCont]) > 2
                                    MHS->MHS_FILTRO := aTabSecund[nCont][3]
                                EndIf

                                // -- Indica se considera secundária na publicaçao
                                If lFieldPub .And. Len(aTabSecund[nCont]) > 3
                                    MHS->MHS_CONPUB := aTabSecund[nCont][4]
                                EndIf

                                If lFieldTipo .And. Len(aTabSecund[nCont]) > 4
                                    MHS->MHS_TIPO := aTabSecund[nCont][5]
                                EndIf
                            EndIf
                        MHS->( MsUnLock() )
                    

                Next nCont

                //Inclui Funções
                If lMIM .And. Len( aProcessos[nProc] ) >= MIMFUNCOES

                    aFuncoes := aProcessos[nProc][MIMFUNCOES]

                    For nCont:=1 To Len(aFuncoes)
                        lExistMIM := MIM->(Dbseek(xFilial("MIM") + PadR(aProcessos[nProc][1], TamSx3("MIM_CPROCE")[1]) + aFuncoes[nCont][1] + PadR(aFuncoes[nCont][2],TamSx3("MIM_FUNCAO")[1]) ))
                        
                        RecLock("MIM", IIF( !lExistMIM, .T., .F.) )
                            If !lInclui .AND. Len(aFuncoes[nCont]) >= MIMDELET .AND. aFuncoes[nCont][MIMDELET] == "*"
                                MIM->(DBDelete())
                            Else
                                MIM->MIM_FILIAL := MHN->MHN_FILIAL
                                MIM->MIM_CPROCE := MHN->MHN_COD
                                MIM->MIM_ETAPA  := aFuncoes[nCont][1]
                                MIM->MIM_FUNCAO := aFuncoes[nCont][2]

                                If lCmpDescri
                                    MIM->MIM_DESCRI := aFuncoes[nCont][3]
                                EndIf

                                If lCmpAtivo
                                    MIM->MIM_ATIVO  := aFuncoes[nCont][4]
                                EndIf
                            EndIf
                        MIM->( MsUnLock() )
                        
                    Next nCont
                EndIf

            EndIf
        Next nProc

    End Transaction

    RestArea(aArea)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} PSHVldCDes
Função que valida se o campo informado pelo usuário existe na tabela principal do processo.

@author Evandro Pattaro
@since 05/03/2024
@version 12.1.2310
/*/
//-------------------------------------------------------------------
Function PSHVldCDes(cTable,cField)
Local lExist := .F.
Local aArea := GetArea()

Default cTable := ""
Default cField := ""

If !Empty(cTable) .And. !Empty(cField)
    
    DbSelectArea(cTable)
    lExist := &(cTable)->(FieldPos(cField)) > 0 

EndIf

If !lExist
    Help( " ", 1, "Help",, STR0038 + cTable , 1 ) //"Campo não existe na tabela principal selecionada: "
EndIf
RestArea(aArea)
Return lExist

//-------------------------------------------------------------------
/*/{Protheus.doc} PSHFilTbl
Função que retorna o filtro conforme o campo selecionado como tabela principal (MHN_TABELA) no cadastro de processo.

@author Evandro Pattaro
@since 05/03/2024
@version 12.1.2310
/*/
//-------------------------------------------------------------------
Function PSHFilTbl()
Local cFilter := ""
Local oModel  := FWModelActive()

cFilter := "X3_ARQUIVO == '"+ oModel:GetModel('MHNMASTER'):GetValue('MHN_TABELA') +"'"

Return cFilter
