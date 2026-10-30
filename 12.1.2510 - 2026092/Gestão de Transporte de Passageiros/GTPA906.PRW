#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'GTPA906.CH'

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPA906()
Cadastro Revogação de bilhetes
 
@sample	GTPA906()
 
@return	oBrowse  
 
@author	    José Carlos
@since		10/03/2026
@version 	P12
/*/
//------------------------------------------------------------------------------------------
Function GTPA906()
    Local oBrowse 	:= Nil

    If GTPxVldDic('H8A')

        If ( !FindFunction("GTPHASACCESS") .Or.; 
            ( FindFunction("GTPHASACCESS") .And. GTPHasAccess() ) ) 

            DbSelectArea("H8A")
            H8A->(DbSetOrder(1))
            oBrowse := FWMBrowse():New()
            oBrowse:SetAlias("H8A")
            oBrowse:SetDescription( STR0001 )   //'Cadastro Revogação de Bilhetes'
            oBrowse:Activate()

        EndIf

    Else 

        FwAlertHelp (STR0002 +CRLF+ STR0003,STR0004)  //"Dicionário desatualizado." "Não localizado estrutura tabela H8A." "Solicite atualização do ambiente."

    EndIF 

Return()

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Definição do Menu
 
@sample	MenuDef()
 
@return	aRotina - Array com opções do Menu
 
@author	    José Carlos 
@since		10/03/2026
@version 	P12
/*/
//------------------------------------------------------------------------------------------
Static Function MenuDef()
    Local aRotina := {}

    ADD OPTION aRotina TITLE STR0005 ACTION 'PesqBrw' 		   OPERATION 1 ACCESS 0 // #Pesquisar
    ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.GTPA906'  OPERATION 2 ACCESS 0 // #Visualizar
    ADD OPTION aRotina TITLE STR0007 ACTION 'GTPA906B()'       OPERATION 3 ACCESS 0 // #Revogar

Return( aRotina )

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Definição do modelo de Dados
 
@sample	ModelDef()
 
@return	oModel  Retorna o Modelo de Dados
 
@author	    José Carlos
@since		10/03/2026
@version 	P12
/*/
//------------------------------------------------------------------------------------------
Static Function ModelDef()
    Local oModel   
    Local oStruH8A := FWFormStruct(1,'H8A')

    oModel := MPFormModel():New('GTPA906',/*bPreValid*/, /*bPosValid*/, /*bCommit*/, /*bCancel*/)

    If ValType(oStruH8A) == "O"
        oStruH8A:AddField("Nome","Nome","USRNOME","C",30,,,,,.F.,,.F.,.F.,.T.,) //"Nome"
        oStruH8A:SetProperty("USRNOME"   , MODEL_FIELD_INIT, {|| LEFT(ALLTRIM(UsrRetName(H8A->H8A_USRRV)),30) })
    EndIf 

    oModel:AddFields('H8AMASTER',/*cOwner*/,oStruH8A)
    oModel:SetDescription(STR0008)  //'Revogação de Bilhetes'
    oModel:GetModel('H8AMASTER'):SetDescription(STR0009)	//'Dados da Revogação'
    oModel:SetPrimaryKey({"H8A_FILIAL","H8A_CODIGO"})

Return ( oModel )

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()
Definição da Interface
 
@sample	ViewDef()
 
@return	oView - Objeto da Interface
 
@author	    José Carlos
@since		10/03/2026
@version 	P12
/*/
//------------------------------------------------------------------------------------------
Static Function ViewDef()
    Local oModel   := ModelDef()
    Local oView    := FWFormView():New()
    Local oStruH8A := FWFormStruct(2,'H8A')

    oStruH8A:RemoveField("H8A_FILIAL")

    If ValType(oStruH8A) == "O"
        oStruH8A:AddField(;
                    "USRNOME",;						// [01]  C   Nome do Campo
                    "07",;							// [02]  C   Ordem
                    'Nome',;						// [03]  C   Titulo do campo // "Data de"
                    'Nome',;						// [04]  C   Descricao do campo // "Data de"
                    {""},;							// [05]  A   Array com Help // "Data de"
                    "GET",;							// [06]  C   Tipo do campo
                    "@!",;							// [07]  C   Picture
                    Nil,;							// [08]  B   Bloco de Picture Var
                    "",;							// [09]  C   Consulta F3
                    .F.,;							// [10]  L   Indica se o campo é alteravel
                    Nil,;							// [11]  C   Pasta do campo
                    "",;							// [12]  C   Agrupamento do campo
                    Nil,;							// [13]  A   Lista de valores permitido do campo (Combo)
                    Nil,;							// [14]  N   Tamanho maximo da maior opção do combo
                    Nil,;							// [15]  C   Inicializador de Browse
                    .T.,;							// [16]  L   Indica se o campo é virtual
                    Nil,;							// [17]  C   Picture Variavel
                    .F.) 							// [18]  L   Indica pulo de linha após o campo
    EndIf 

    //Sepração dos campos
    oStruH8A:AddGroup( "REGISTRO", STR0010, "" , 2 )    //"Bilhetes:"
    oStruH8A:SetProperty("H8A_CODIGO" , MVC_VIEW_GROUP_NUMBER, "REGISTRO" )
    oStruH8A:SetProperty("H8A_DTVEND" , MVC_VIEW_GROUP_NUMBER, "REGISTRO" )
    oStruH8A:SetProperty("H8A_AGENCI" , MVC_VIEW_GROUP_NUMBER, "REGISTRO" )
    oStruH8A:SetProperty("H8A_DESAGE" , MVC_VIEW_GROUP_NUMBER, "REGISTRO" )

    oStruH8A:AddGroup( "REVOGADO", STR0011, "" , 2 )    //"Revogado por:"
    oStruH8A:SetProperty("H8A_USRRV" , MVC_VIEW_GROUP_NUMBER, "REVOGADO" )
    oStruH8A:SetProperty("H8A_DATA"  , MVC_VIEW_GROUP_NUMBER, "REVOGADO" )
    oStruH8A:SetProperty("H8A_HORA"  , MVC_VIEW_GROUP_NUMBER, "REVOGADO" )
    oStruH8A:SetProperty("USRNOME"   , MVC_VIEW_GROUP_NUMBER, "REVOGADO" )

    //Ordenação dos campos
    oStruH8A:SetProperty("H8A_CODIGO" 	, MVC_VIEW_ORDEM,'01')
    oStruH8A:SetProperty("H8A_DTVEND" 	, MVC_VIEW_ORDEM,'02')
    oStruH8A:SetProperty("H8A_AGENCI" 	, MVC_VIEW_ORDEM,'03')
    oStruH8A:SetProperty("H8A_DESAGE" 	, MVC_VIEW_ORDEM,'04')
    oStruH8A:SetProperty("H8A_USRRV" 	, MVC_VIEW_ORDEM,'05')
    oStruH8A:SetProperty("USRNOME" 	    , MVC_VIEW_ORDEM,'06')
    oStruH8A:SetProperty("H8A_DATA" 	, MVC_VIEW_ORDEM,'07')
    oStruH8A:SetProperty("H8A_HORA" 	, MVC_VIEW_ORDEM,'08')

    oView:SetModel(oModel)
    oView:SetDescription(STR0009) //'Dados Revogação'
    oView:AddField('VIEW_H8A',oStruH8A,'H8AMASTER')
    oView:CreateHorizontalBox('TELA',100)
    oView:SetOwnerView('VIEW_H8A','TELA')

Return ( oView )
