#Include "Protheus.ch"
#Include "FWMVCDef.ch"
#INCLUDE "OFIA005.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} OFIA005()
MVC - Processamento Reserva 

@author Rafael do Nascimento Pereira
@since 11/09/2025
/*/
//-------------------------------------------------------------------
Function OFIA005()
Local lNewRes := GetNewPar("MV_MIL0181",.f.) // Controla nova reserva no ambiente?
Local lVSJManRes := GetNewPar("MV_MIL0155",.f.) // Reservar automaticamente na digitação das Peças da os (Depende do MV_RITEORC)
Local lMovtoReserva := GetNewPar("MV_RITEORC",.f.) // Reserva item do orcamento na importacao
Local oBrwSB1

    //Valida se o Técnico pode reservar peças
    DbSelectArea("VAI")
    DbSetOrder(4)
    If DbSeek( xFilial("VAI") + __cUserID ) .And. VAI->VAI_RESERV != "1"
		FMX_HELP("OFIA005ERR002", STR0007, STR0009) // "Opção indisponível". "Técnico não permitido Reservar peças"
        Return
    EndIf

    // Validação dos parâmetros obrigatórios
    If !( AllTrim(lMovtoReserva) == "S" .And. AllTrim(lVSJManRes) == "1" .And. lNewRes == .T. )
    	FMX_HELP("OFIA005ERR001", STR0007, STR0008) // "Opção indisponível". "Necessário habilitar os parametros MV_RITEORC, MV_MIL0155 e MV_MIL0181"
        Return
    EndIf


oBrwSB1 := FWMBrowse():New()
oBrwSB1:SetAlias("SB1")
oBrwSB1:SetMenuDef("OFIA005")
oBrwSB1:SetDescription( STR0001 ) // Cadastro de Produtos
oBrwSB1:SetOnlyFields({ "B1_COD", "B1_DESC", "B1_UM", "B1_TIPO", "B1_GRUPO" })
oBrwSB1:DisableLocate()
oBrwSB1:DisableDetails()
oBrwSB1:SetAmbiente(.F.)
oBrwSB1:SetWalkthru(.F.)
oBrwSB1:SetUseFilter()
oBrwSB1:lOptionReport := .f.
oBrwSB1:AddButton( STR0002, { || CloseBrowse() }) // Fechar
oBrwSB1:Activate()
//
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
    Criação do menu 

	@type Static Function
	@author Rafael do Nascimento Pereira	
	@since 11/09/2025
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}
ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.OFIA005' OPERATION 4 ACCESS 0 // Manutenção
Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
	Definição do Modelo
	
	@type Static Function
	@author Rafael do Nascimento Pereira	
	@since 11/09/2025
/*/
//-------------------------------------------------------------------
Static Function ModelDef(aParam)
    Local cCodProd := ""
    Local oModel    
    Local oStruSB1  
    Local oStruVSJ  
    
    If ValType(aParam) == "A" .AND. Len(aParam) > 0
        cCodProd := aParam[1]
    EndIf

    oModel    := MPFormModel():New("OFIA005M")
    oStruSB1  := FWFormStruct(1, "SB1")
    oStruVSJ  := FWFormStruct(1, "VSJ")

    // Cabeçalho SB1 - Cadastro de Produto
    oModel:AddFields("SB1MASTER", NIL, oStruSB1)
    oModel:GetModel("SB1MASTER"):SetDescription(STR0004) // Produto

    // Grid VSJ - Peças em espera para aplicação
    oModel:AddGrid("VSJDETAIL","SB1MASTER",oStruVSJ)
    oModel:GetModel("VSJDETAIL"):SetDescription(STR0005) // Movimento Peças em espera para aplicação
    oModel:GetModel('VSJDETAIL'):SetLoadFilter( , " VSJ_QTDRES = '0'" )// INCLUIR OS CAMPOS VSJ_QTDSUG == 0 e VSJ_QTDTRA == 0. OBS: NÃO CONTEM NO DICIONARIO
    oModel:SetRelation( 'VSJDETAIL', { { 'VSJ_FILIAL', 'xFilial( "VSJ" )' }, { 'VSJ_CODITE', 'B1_COD' } }, VSJ->( IndexKey( 5 ) ) )

    oStruVSJ:AddField('FLAG', '', 'FLAG', 'L' , 1 , 0, NIL , NIL , NIL, .F., , .F., .F. , .T.) //Adiciona campo virtual na Grid

    // Não permite alteração da Grid 
    oModel:GetModel("VSJDETAIL"):SetNoDeleteLine(.T.) //Deleta Linha
    oModel:GetModel("VSJDETAIL"):SetNoInsertLine(.T.) //Insere Linha

    // Inicializador padrão
    bAuxRelacao := FWBuildFeature(STRUCT_FEATURE_INIPAD, 'IIf(!Inclui,Posicione("SB1",7,xFilial("SB1")+VSJ->VSJ_GRUITE+VSJ->VSJ_CODITE,"B1_DESC"),"") ')
    oStruVSJ:SetProperty("VSJ_DESITE", MODEL_FIELD_INIT, bAuxRelacao)
    
    bAuxRelacao := FWBuildFeature(STRUCT_FEATURE_INIPAD, 'IIf(!Inclui,Posicione("SA1",1,xFilial("SA1")+VSJ->VSJ_FATPAR+VSJ->VSJ_LOJA,"A1_NOME"),"") ')
    oStruVSJ:SetProperty("VSJ_NOMCLI", MODEL_FIELD_INIT, bAuxRelacao)

    // Não permite editar Campo
    bModelWhen := {|| oModel:getOperation() == 3 }  //Incluir permite edição
    oStruVSJ:setProperty('VSJ_NUMOSV'    ,MODEL_FIELD_WHEN,bModelWhen)
    oStruVSJ:setProperty('VSJ_NUMORC'    ,MODEL_FIELD_WHEN,bModelWhen) 
    oStruVSJ:setProperty('VSJ_ORIDAD'    ,MODEL_FIELD_WHEN,bModelWhen)
    oStruVSJ:setProperty('VSJ_TIPTEM'    ,MODEL_FIELD_WHEN,bModelWhen)
    oStruVSJ:setProperty('VSJ_GRUITE'    ,MODEL_FIELD_WHEN,bModelWhen)
    oStruVSJ:setProperty('VSJ_CODITE'    ,MODEL_FIELD_WHEN,bModelWhen)
    oStruVSJ:setProperty('VSJ_QTDDIG'    ,MODEL_FIELD_WHEN,bModelWhen)
    oStruVSJ:setProperty('VSJ_QTDINI'    ,MODEL_FIELD_WHEN,bModelWhen)
    oStruVSJ:setProperty('VSJ_QTDREQ'    ,MODEL_FIELD_WHEN,bModelWhen)
    oStruVSJ:setProperty('VSJ_QESTNA'    ,MODEL_FIELD_WHEN,bModelWhen)
    oStruVSJ:setProperty('VSJ_RESPEC'    ,MODEL_FIELD_WHEN,bModelWhen)
    oStruVSJ:setProperty('VSJ_VALPEC'    ,MODEL_FIELD_WHEN,bModelWhen)
    oStruVSJ:setProperty('VSJ_VALCUS'    ,MODEL_FIELD_WHEN,bModelWhen)
    oStruVSJ:setProperty('VSJ_LOCAL'     ,MODEL_FIELD_WHEN,bModelWhen)
    oStruVSJ:setProperty('VSJ_QTDRES'    ,MODEL_FIELD_WHEN,bModelWhen)

    // Se veio código do produto, aplica filtro
    If !Empty(cCodProd)
        oModel:SetFilter("SB1MASTER", {|| SB1->B1_COD == cCodProd })
    EndIf

    oModel:SetDescription(STR0006) // Processa Reserva 

Return oModel


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
	Definição da tela principal
	
	@type Static Function
	@author Rafael do Nascimento Pereira	
	@since 11/09/2025
/*/
//-------------------------------------------------------------------
Static Function ViewDef(aParam)
    Local oView  := FWFormView():New()
    Local oModel := FWLoadModel("OFIA005")
    Local oStruSB1 
    Local oStruVSJ

    oView:SetModel(oModel)
    oView:SetAfterViewActivate({|oView| OFIA005016_Btn_Checkbox(oView)})
    oView:SetCloseOnOk({|oView|OFIA005036_Processa_Reserva(oView)})

    // Cabeçalho
    oStruSB1 := FWFormStruct(2, "SB1", {|cCampo| alltrim(cCampo) $ 'B1_COD|B1_DESC|B1_UM|B1_TIPO|B1_GRUPO'})
    oView:AddField("VIEW_SB1", oStruSB1, "SB1MASTER")
    oStruSB1:SetNoFolder()

    //Não permite alterar o campo
    oStruSB1:SetProperty( "B1_COD"      ,MVC_VIEW_CANCHANGE, .f. )
    oStruSB1:SetProperty( "B1_DESC"     ,MVC_VIEW_CANCHANGE, .f. )
    oStruSB1:SetProperty( "B1_UM"       ,MVC_VIEW_CANCHANGE, .f. )
    oStruSB1:SetProperty( "B1_TIPO"     ,MVC_VIEW_CANCHANGE, .f. )
    oStruSB1:SetProperty( "B1_GRUPO"    ,MVC_VIEW_CANCHANGE, .f. )

    // Grid
    oStruVSJ := FWFormStruct(2, "VSJ",{ |cCampo| alltrim(cCampo) $ 'FLAG|VSJ_NUMOSV|VSJ_NUMORC|VSJ_ORIDAD|VSJ_TIPTEM|VSJ_GRUITE|VSJ_CODITE|VSJ_QTDDIG|VSJ_QTDINI|VSJ_QTDREQ|VSJ_QESTNA|VSJ_RESPEC|VSJ_VALPEC|VSJ_VALCUS|VSJ_LOCAL|VSJ_QTDRES'})
    oStruVSJ:AddField( ;    // Adicionando campo checkbox (Virtual) pra ser apresentado no grid. Obs: Não existe no dicionário de dados
                "FLAG",;  // [01]  C   Nome do Campo
                "00",;          // [02]  C   Ordem
                "Titulo",;      // [03]  C   Titulo do campo    
                "FLAG",;        // [04]  C   Descricao do campo
                NIL,;           // [05]  A   Array com Help
                "CHECK",;       // [06]  C   Tipo do campo
                "!",;           // [07]  C   Picture
                ,;              // [08]  B   Bloco de Picture Var
                ,;              // [09]  C   Consulta F3
                ,;              // [10]  L   Indica se o campo é alteravel
                ,;              // [11]  C   Pasta do campo
                ,;              // [12]  C   Agrupamento do campo
                ,;              // [13]  A   Lista de valores permitido do campo (Combo)
                ,;              // [14]  N   Tamanho maximo da maior opção do combo
                ,;              // [15]  C   Inicializador de Browse
                .T.,;           // [16]  L   Indica se o campo é virtual
                )               // [17]  C   Picture Variavel
    
    oStruVSJ:SetProperty("FLAG", MODEL_FIELD_INIT, .F.)
    oView:AddGrid("GRID_VSJ", oStruVSJ, "VSJDETAIL")

    // Layout
    oView:createHorizontalBox('BOXSB1',40)
    oView:createHorizontalBox('BOXVSJ',60)
    
    oView:setOwnerView('SB1MASTER','BOXSB1')
    oView:setOwnerView('VSJDETAIL','BOXVSJ')


Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} OFIA0056_Btn_Checkbox
	Criando o Botão para Marcar/Desmarcar
	
	@type Static Function
	@author Rafael do Nascimento Pereira
	@since 11/09/2025
/*/
//-------------------------------------------------------------------
Static Function OFIA005016_Btn_Checkbox(oView)

	Local oBrow := Nil

	oBrow := oView:GetViewObj("VSJDETAIL")[3]
	
	oBrow:oBrowse:aColumns[1]:SetHeaderImage("")
	oBrow:oBrowse:aColumns[1]:SetHeaderClick({|| OFIA005026_Marca_Desmarca()})

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} OFIA005026_Marca_Desmarca
	Criando o Botão para Marcar/Desmarcar
	
	@type Static Function
	@author Rafael do Nascimento Pereira
	@since 11/09/2025
/*/
//-------------------------------------------------------------------
Static Function OFIA005026_Marca_Desmarca()

    Local oModel  := FwModelActive()
    Local oView   := FwViewActive()
    Local oGrid   := oModel:GetModel("VSJDETAIL") 
    Local nI      := 0
    Local lMarked := .T.

    // Verifica se todos já estão marcados
    For nI := 1 To oGrid:Length()
		oGrid:GoLine(nI)
        If !oGrid:GetValue("FLAG", nI) 
            lMarked:= .F.
            Exit
        Endif
    Next

    // Marca ou desmarca todos
    For nI := 1 To oGrid:Length()
		oGrid:GoLine(nI)
        oGrid:SetValue("FLAG", !lMarked)
    Next

	oGrid:GoLine(1)
    oView:Refresh("VSJDETAIL")

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} OFIA005036_Processa_Reserva
	Chama a função para reservar os itens
	
	@type Static Function
	@author Rafael do Nascimento Pereira
	@since 11/09/2025
/*/
//-------------------------------------------------------------------

Static Function OFIA005036_Processa_Reserva(oView)
    Local oModel  := oView:GetModel()
    Local oGrid   := oModel:GetModel("VSJDETAIL")
    Local nI
    Local aVSJIte := {}

    DBSelectArea("VSJ")
    VSJ->(DbSetOrder(3))
    
    For nI := 1 To oGrid:Length()
        oGrid:GoLine(nI)
        VSJ->(DbSeek(xFilial("VSJ")+oGrid:GetValue("VSJ_CODIGO")))
        If oGrid:GetValue("FLAG", nI)
             aAdd(aVSJIte,{VSJ->(RecNo()),0,""})
        EndIf
    Next
    If Len(aVSJIte) > 0
        OA4820015_ProcessaReservaItem("OF", , "M", "R", aVSJIte , "16")
    EndIf

Return .T.

