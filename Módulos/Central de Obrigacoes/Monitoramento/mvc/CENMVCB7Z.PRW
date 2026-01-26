#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "PLSMGER.CH"


//-------------------------------------------------------------------
/*/{Protheus.doc} CENMVCB7Z

Gestao de Pedidos da Integracao PLS x HAT 
@author  renan.almeida
@version P12
@since   06/09/18
/*/
//-------------------------------------------------------------------
Function CENMVCB7Z()

    Local oBrowse := FWMBrowse():New() //Instanciamento da Classe de Browse

    oBrowse:SetAlias('B7Z') //Definição da tabela do Browse  
    oBrowse:SetDescription('Cadastro Eventos TUSS - Monitoramento') //Titulo da Browse
    oBrowse:Activate() //Ativação da Classe

Return Nil
 

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Define o menu da aplicação 

@author  renan.almeida
@version P12
@since   20/08/2018
/*/
//------------------------------------------------------------------- 
Static Function MenuDef()

    Local aRotina := {}

    ADD OPTION aRotina Title 'Visualizar' Action 'VIEWDEF.CENMVCB7Z' OPERATION 2 ACCESS 0 //'Visualizar'
    ADD OPTION aRotina Title 'Incluir'    Action 'VIEWDEF.CENMVCB7Z' OPERATION 3 ACCESS 0 //"Incluir"
    ADD OPTION aRotina Title 'Alterar'    Action 'VIEWDEF.CENMVCB7Z' OPERATION 4 ACCESS 0 //"Alterar"
    ADD OPTION aRotina Title 'Excluir'    Action 'VIEWDEF.CENMVCB7Z' OPERATION 5 ACCESS 0 //"Excluir"

Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Define o modelo de dados da aplicação   

@author  renan.almeida
@version P12
@since   20/08/2018
/*/
//------------------------------------------------------------------- 
Static Function ModelDef()

    Local oStruB7Z := FWFormStruct( 1, 'B7Z' ) //Cria as estruturas a serem usadas no Modelo de Dados
    Local oModel // Modelo de dados construído

    oModel := MPFormModel():New('CENMVCB7Z') //Cria o objeto do Modelo de Dados
    oModel:AddFields( 'B7ZMASTER', /*cOwner*/, oStruB7Z ) //Adiciona ao modelo um componente de formulário
    oModel:SetDescription( "Cadastro Eventos TUSS - Monitoramento" ) //Adiciona a descrição do Modelo de Dados
    oModel:GetModel( 'B7ZMASTER' ):SetDescription( "Eventos" ) //Adiciona a descrição dos Componentes do Modelo de Dados
    oModel:SetPrimaryKey({}) //Seta Chaves primarias

Return oModel   
        

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Define o modelo de dados da aplicação 

@author  renan.almeida
@version P12
@since   20/08/2018
/*/
//------------------------------------------------------------------- 
Static Function ViewDef()

    Local oModel   := FWLoadModel( 'CENMVCB7Z' ) //Cria um objeto de Modelo de dados baseado no ModelDef do fonte informado
    Local oStruB7Z := FWFormStruct( 2, 'B7Z' ) //Cria as estruturas a serem usadas na View
    Local oView //Interface de visualização construída

    oView := FWFormView():New() //Cria o objeto de View
    oView:SetModel( oModel ) //Define qual Modelo de dados será utilizado
    oView:AddField( 'VIEW_B7Z', oStruB7Z, 'B7ZMASTER' ) //Adiciona no nosso View um controle do tipo formulário (antiga Enchoice)

Return oView                


//-------------------------------------------------------------------
/*/{Protheus.doc} PLS244GRV
Gravação da tabela B7Z para rotinas de processamento   

@author  renan.almeida
@version P12
@since   20/08/2018
/*/
//-------------------------------------------------------------------
/*
Function PLSB7ZGRV( nOpc, aCamposB7Z )

    local oAux		:= nil
    local oStruct	:= nil
    local oModel	:= nil
    local aAux		:= {}
    local aErro		:= {}
    local cLoadModel:= 'CENMVCB7Z'
    local nI		:= 0    
    local nX        := 0
    local nPos		:= 0
    local lRet := .T.

    oModel := FWLoadModel( cLoadModel )
    oModel:setOperation( nOpc )
    oModel:activate()

    oAuxB7Z	:= oModel:getModel( 'B7ZMASTER' )
    oStructB7Z	:= oAuxB7Z:getStruct()
    aAuxB7Z	:= oStructB7Z:getFields()   

    if( nOpc <> MODEL_OPERATION_DELETE )
        begin Transaction
            //B7Z
            for nI := 1 to len( aCamposB7Z )
                if( nPos := aScan( aAuxB7Z,{| x | allTrim( x[ 3 ] ) == allTrim( aCamposB7Z[ nI,1 ] ) } ) ) > 0
                    if !( lRet := oModel:setValue( 'B7ZMASTER',aCamposB7Z[ nI,1 ],aCamposB7Z[ nI,2 ] ) )
                        aErro := oModel:getErrorMessage()				
                        
                        PlsPtuLog("------------------------------------------------------------------", "CENMVCB7Z.log")
                        PlsPtuLog("Id do campo de origem: " 	+ ' [' + AllToChar( aErro[ 2 ] ) + ']', "CENMVCB7Z.log")
                        PlsPtuLog("Mensagem do erro: " 			+ ' [' + AllToChar( aErro[ 6 ] ) + ']', "CENMVCB7Z.log")
                        PlsPtuLog("Conteudo do erro: " 			+ ' [' + AllToChar( aErro[ 9 ] ) + ']', "CENMVCB7Z.log")
                        PlsPtuLog("------------------------------------------------------------------", "CENMVCB7Z.log")
                        disarmTransaction()
                        exit
                    endif
                endIf
            next nI     
        end Transaction
    endIf		

    if( lRet := oModel:vldData() )
        oModel:commitData()
    else
        aErro := oModel:getErrorMessage()				
        PlsPtuLog("------------------------------------------------------------------", "CENMVCB7Z.log")
        PlsPtuLog("Id do campo de origem: " 	+ ' [' + AllToChar( aErro[ 2 ] ) + ']', "CENMVCB7Z.log")
        PlsPtuLog("Mensagem do erro: " 			+ ' [' + AllToChar( aErro[ 6 ] ) + ']', "CENMVCB7Z.log")	
        PlsPtuLog("------------------------------------------------------------------", "CENMVCB7Z.log")
        disarmTransaction()
    endif

    oModel:deActivate()
    oModel:destroy()
    freeObj( oModel )
    oModel := nil
    delClassInf()

return lRet */