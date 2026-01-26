//Bibliotecas
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#include "TopConn.ch"
#include "LOCA088.ch" 
//Variáveis Estáticas
Static cTitulo := STR0001 //"Cabeçalho CheckList"
 
/*/{Protheus.doc} LOCA089
Rotina que cadastra Cabeçalho do check-list
@author Dennis Calabrez
@since 04/09/2024
@version 1.0
/*/
Function LOCA088()
Local oBrowse
Private aRotina := {}

    //Definicao do menu
    aRotina := MenuDef()

    //Instanciando o browse
    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("FPJ")
    //oBrowse:SetMenuDef("LOCA089")
    oBrowse:SetDescription(cTitulo)
    //oBrowse:DisableDetails()

    //Ativa a Browse
    oBrowse:Activate()

    //FWRestArea(aArea)
Return Nil

/*/{Protheus.doc} MenuDef
Menu de opcoes
@author Dennis Calabrez
@since 04/09/2024
@version 1.0
/*/

Static Function MenuDef()
Local aRotina := {}

    //Adicionando opcoes do menu
    ADD OPTION aRotina TITLE STR0002 ACTION "VIEWDEF.LOCA088" OPERATION 1 ACCESS 0 // //"Visualizar"
    ADD OPTION aRotina TITLE STR0003 ACTION "VIEWDEF.LOCA088" OPERATION 3 ACCESS 0 // //"Incluir"
    ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.LOCA088" OPERATION 4 ACCESS 0 // //"Alterar"
    ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.LOCA088" OPERATION 5 ACCESS 0 // //"Excluir"


Return aRotina    

/*/{Protheus.doc} ModelDef
Modelo de dados
@author Dennis Calabrez
@since 04/09/2024
@version 1.0
/*/

Static Function ModelDef()

Local oStruct		:= FWFormStruct( 1, 'FPJ' )
Local oModel		// Modelo de dados que será construído

    oModel := MPFormModel():New( 'LOCA088' )
    //Antiga enchoice
    oModel:AddFields( 'FPJMASTER', /*cOwner*/, oStruct )
    //Setando a chave primária da rotina
    oModel:SetPrimaryKey({'FPJ_FILIAL','FPJ_CODFOR'})
    //Descrição do modelo
    oModel:SetDescription( cTitulo ) 		//"Cadastro de operações com controle de aprovação"

Return oModel

/*/{Protheus.doc} ViewDef
Visualizacao de dados
@author Dennis Calabrez
@since 04/09/2024
@version 1.0
/*/

Static Function ViewDef()
Local oModel 	:= FWLoadModel( 'LOCA088' ) 		// Cria um objeto de Modelo de dados baseado no ModelDef() do fonte informado
Local oStruFNH 	:= FWFormStruct( 2, 'FPJ' ) 		// Cria a estrutura a ser usada na View
Local oView  									// Interface de visualização construída

    // Cria o objeto de View
    oView := FWFormView():New()
    // Define qual o Modelo de dados será utilizado na View
    oView:SetModel( oModel )
    // Adiciona no nosso View um controle do tipo formulário
    oView:AddField( 'VIEWFPJ', oStruFNH, 'FPJMASTER' )
    // Criar um "box" horizontal para receber algum elemento da view
    oView:CreateHorizontalBox( 'TELA' , 100 )
    // Relaciona o identificador (ID) da View com o "box" para exibição
    oView:SetOwnerView( 'VIEWFPJ', 'TELA' )
    /* Desabilita o novo botao "salvar e criar novo" */
    oView:SetCloseOnOK({ || .T. })

Return oView


Function LOCA088A(cOrigem)
Local lRet          := .T.
    If cOrigem == "FPJ_CODFOR"
        If M->FPJ_CODFOR == "1"
            M->FPJ_NOMFOR  := "PREPARAÇÃO QA"
        Endif             
        If M->FPJ_CODFOR == "2"
            M->FPJ_NOMFOR  := "CHECK-LIST DE ENTREGA E DEVOLUÇÃO"
        Endif             
        If M->FPJ_CODFOR == "3"
            M->FPJ_NOMFOR  := "CHECK-LIST DE TRANSPORTE"
        Endif             
        If M->FPJ_CODFOR == "4"
            M->FPJ_NOMFOR  := "AVARIA"
        Endif             
        If M->FPJ_CODFOR == "5"
            M->FPJ_NOMFOR  := "VENDA"
        Endif                                             
        UltSeq()
    ElseIf cOrigem == "FPJ_CODFAM"
        ST6->(DbSetOrder(1))
        ST6->(DbGoTop())
        If ST6->(DbSeek(xFilial("ST6")+M->FPJ_CODFAM))
            M->FPJ_DESFAM  := ST6->T6_NOME
            UltSeq()
        Else
            lRet := .F.
            //MsgStop("Família não cadastrada.") //A tela via consulta padrão já mostra mensagem padrão
        EndIf  
    Endif      
Return(lRet)

Static Function UltSeq()
Local cSeq  := ""
Local cQry  := ""

    cQry := "SELECT MAX(FPJ_SEQ) MAXSEQ FROM "+RetSqlName("FPJ")+" FPJ"
    cQry += " WHERE FPJ_FILIAL = '"+xFilial("FPJ")+"'"
    cQry += " AND FPJ_CODFOR = ? "
    cQry += " AND FPJ_CODFAM = ? "
    cQry += " AND FPJ.D_E_L_E_T_ = ''"

	If Select("TRBFPJ") > 0
		Dbselectarea("TRBFPJ")
		TRBFPJ->(DbCloseArea())
	EndIF
	cQry := ChangeQuery(cQry)

	aBindParam := {M->FPJ_CODFOR,M->FPJ_CODFAM}
	
	MPSysOpenQuery(cQry,"TRBFPJ",,,aBindParam)

    //If TRBFPJ->(EoF())
    //    cSeq := PadL("1",TamSx3("FPJ_SEQ")[1,"0"])
    //Else
        cSeq := Soma1(TRBFPJ->MAXSEQ)
    //EndIf

    M->FPJ_SEQ := cSeq

Return (Nil)
