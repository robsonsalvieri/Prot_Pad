#include 'agra080.ch'
#include 'protheus.ch'
#include 'fwmvcdef.ch'

/*-----------------------------------------------------------
{Protheus.doc} AGRA080
Parametro Integracao Agro

@author Gilson Venturi
@since 13/03/2024
@version 1.0
-----------------------------------------------------------*/
Function AGRA080()
    Local oBrowse   := Nil              // Recebe o  Browse

    If .not. AGR80DIC()
        MsgNextRel() //-- É necessário a atualização do sistema para a expedição mais recente
        Return()
    EndIf

    Private  aRotina   := MenuDef()     // Recebe as rotinas do menu

    oBrowse:= FWMBrowse():New()
    oBrowse:SetAlias("ND7")             // Alias da tabela utilizada
    oBrowse:SetMenuDef("AGRA080")       // Nome do fonte onde esta a fun‡Æo MenuDef
    oBrowse:SetDescription( STR0001 )   // Integracao Agro
    oBrowse:Activate()

Return ( Nil )

/*-----------------------------------------------------------
{Protheus.doc} menudef()
Menu da rotina

@author Gilson Venturi
@since 13/03/2024
@version 1.0
-----------------------------------------------------------*/
Static Function MenuDef()

    Local aRotina := {}

    ADD OPTION aRotina TITLE STR0002  ACTION "AxPesqui"          OPERATION 1 ACCESS 0 // "Pesquisar"
    ADD OPTION aRotina TITLE STR0003  ACTION "VIEWDEF.AGRA080"   OPERATION 2 ACCESS 0 // "Visualizar"
    ADD OPTION aRotina TITLE STR0004  ACTION "VIEWDEF.AGRA080"   OPERATION 3 ACCESS 0 // "Incluir"
    ADD OPTION aRotina TITLE STR0005  ACTION "VIEWDEF.AGRA080"   OPERATION 4 ACCESS 0 // "Alterar"
    ADD OPTION aRotina TITLE STR0006  ACTION "VIEWDEF.AGRA080"   OPERATION 5 ACCESS 0 // "Excluir"
    ADD OPTION aRotina TITLE STR0007  ACTION "AGRA080Con()"      OPERATION 6 ACCESS 0 // "Testar Conexao"

Return(aRotina)

/*-----------------------------------------------------------
{Protheus.doc} ModelDef()
Modelo de dados

@author Gilson Venturi
@since 13/03/2024
@version 1.0
-----------------------------------------------------------*/
Static Function ModelDef()
    Local oModel    := Nil      // Objeto do Model
    Local oStruND7  := Nil      // Recebe a Estrutura da tabela ND7
    Local bCommit   := { |oModel| CommitMdl(oModel) }
    Local bPosValid := { |oModel| PosVldMdl(oModel) }

    oStruND7:= FWFormStruct( 1, "ND7" )

    oModel := MPFormModel():New( "AGRA080",,bPosValid, bCommit , /*bCancel*/ )
    oModel:AddFields( 'MdFieldND7',, oStruND7,,,/*Carga*/ )
    oModel:GetModel( 'MdFieldND7' ):SetDescription( STR0001 )   // Integracao Agro
    oModel:SetPrimaryKey({"ND7_FILIAL" , "ND7_ID"})
    oModel:SetActivate( )

Return oModel

/*-----------------------------------------------------------
{Protheus.doc} ViewDef()
Cria‡Æo da View

@author Gilson Venturi
@since 13/03/2024
@version 1.0
-----------------------------------------------------------*/
Static Function ViewDef()
    Local oModel    := Nil      // Objeto do Model
    Local oStruND7  := Nil      // Recebe a Estrutura da tabela ND7
    Local oView                 // Recebe o objeto da View

    oModel   := FwLoadModel("AGRA080")
    oStruND7 := FWFormStruct( 2,"ND7")

    oView := FwFormView():New()
    oView:SetModel(oModel)

    oView:AddField('VwFieldND7', oStruND7 , 'MdFieldND7')

    oView:CreateHorizontalBox('CABECALHO', 100)
    oView:SetOwnerView('VwFieldND7','CABECALHO')

Return oView

/*-----------------------------------------------------------
{Protheus.doc} PosVldMdl()
P¢s-valida‡Æo do modelo de dados

@author Gilson Venturi
@since 13/03/2024
@version 1.0
-----------------------------------------------------------*/
Static Function PosVldMdl(oModel)
    Local lRet          := .T.
    Local aAreaND7      := ND7->(GetArea())

    dbSelectArea("ND7")
    ND7->(dbSetorder(2))
    If FwFldGet("ND7_BLOQU") == "2" .And. ND7->(MsSeek(xFilial("ND7") + "2" ))

        While ND7->ND7_FILIAL + ND7->ND7_BLOQU == xFilial("ND7") + "2"

            If ND7->ND7_ID <> FwFldGet("ND7_ID")
                lRet    := .F.
                Agrhelp(STR0001,STR0008,"") // Integracao Agro, NÆo ‚ permitido mais de um ID ativos, ""
                Exit
            EndIf

            ND7->(dbSkip())
        EndDo

    EndIf

    RestArea(aAreaND7)

Return lRet

/*-----------------------------------------------------------
{Protheus.doc} CommitMdl()
Commit do modelo de dados

@author Gilson Venturi
@since 13/03/2024
@version 1.0
-----------------------------------------------------------*/
Static Function CommitMdl(oModel)
    Local lRet	:= .T.

    lRet := FwFormCommit(oModel)

Return lRet

/*-----------------------------------------------------------
{Protheus.doc} AGRA080Con()
Verifica se a conexÆo est  ativa

@author Gilson Venturi
@since 13/03/2024
@version 1.0
-----------------------------------------------------------*/
Function AGRA080Con()
    Local oConAtv   := Nil
    Local cToken    := ""
    Local cTipInt   := ND7->ND7_TPINTE
    Local oJson   As Object

    If ND7->ND7_BLOQU == "2"

        oConAtv := AGRAIntegrAgro():New(cTipInt)
        If ND7->ND7_TPINTE == "1"
            cResult := oConAtv:GetTokenApiBen()
        Else
            cResult := oConAtv:GetAccessToken() 
        EndIf       

        oJson := JsonObject():New()
        oJson:fromJson( cResult )
    
        If !( Empty( oConAtv:access_token ) )
            cToken := oConAtv:access_token
        Else
            cToken := ""
        Endif

        If !Empty(cToken)
            Agrhelp(STR0001,STR0009, "") // Integracao Agro, Conexao realizado com sucesso
        Else
            Agrhelp(STR0001,STR0010 + " " + cResult, "") // Integracao Agro, Falha ao tentar conexao
        EndIf
    Else
        Agrhelp(STR0001,STR0011,"") // Integracao Agro, Integra‡Æo desativada
    Endif

Return .T.

/*{Protheus.doc} AGR80DIC
Função para validar se existe tabelas e campos no dicionario 
@type function
@version P12
@author Vanilda Moggio
@since 04/24/2024
@return Logical, valor logico 
*/
Function AGR80DIC()
	Local lRet := .T.
	
	If !TableInDic("ND7") 
		lRet := .F.
	EndIf

Return lRet
