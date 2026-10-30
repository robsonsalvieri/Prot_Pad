#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"  
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE 'PCPA161.CH'

/*/{Protheus.doc} PCPA161c()
Função responsável por processar a opção:
Parâmetros Iniciais - Monitor Requisições Pendentes 

@author michele.girardi
@since 25/02/2026
@return Nil
/*/
Function PCPA161C()
    Local oBrowse
    
    Private aRotina := MenuDef()

    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias('HZ4')
    oBrowse:SetDescription(STR0042) //"Parâmetros Iniciais"
    oBrowse:Activate()

Return NIL

/*/{Protheus.doc} MenuDef()
Menu de Operações MVC

@author michele.girardi
@since 25/02/2026
@return oModel - Objeto do Modelo MVC
/*/
Static Function MenuDef()
    Local aRotina := {}

    ADD OPTION aRotina TITLE STR0043 ACTION "VIEWDEF.PCPA161C" OPERATION 2 ACCESS 0  //"Visualizar"
    ADD OPTION aRotina TITLE STR0044 ACTION "VIEWDEF.PCPA161C" OPERATION 3 ACCESS 0  //"Incluir"
    ADD OPTION aRotina TITLE STR0045 ACTION "VIEWDEF.PCPA161C" OPERATION 4 ACCESS 0  //"Alterar"
    ADD OPTION aRotina TITLE STR0046 ACTION "VIEWDEF.PCPA161C" OPERATION 5 ACCESS 0  //"Excluir"

Return aRotina

/*/{Protheus.doc} ModelDef()
Funcao generica MVC do model

@author michele.girardi
@since 25/02/2026
@return oModel - Objeto do Modelo MVC
/*/
Static Function ModelDef()
    Local oStructHZ4 := FWFormStruct( 1, "HZ4", /*bAvalCampo*/,/*lViewUsado*/ )
    Local oModel    

    oModel := MPFormModel():New("PCPA161C", /*bPreValidacao*/,{|oModel|a161VldCpo(oModel)} , /*bCommit*/, /*bCancel*/ )

    oModel:AddFields( "HZ4MASTER", /*cOwner*/, oStructHZ4, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
    
    oModel:SetDescription(STR0042) //"Parâmetros Iniciais"
    
    oModel:GetModel("HZ4MASTER"):SetDescription(STR0042)   //"Parâmetros Iniciais"

Return oModel

/*/{Protheus.doc} ViewDef()
Funcao generica MVC do View

@author michele.girardi
@since 25/02/2026
@return oView - Objeto da View MVC
/*/
Static Function ViewDef()
    Local oModel     := FWLoadModel("PCPA161C")
    Local oStructHZ4 := FWFormStruct( 2, "HZ4" )

    oView := FWFormView():New()
    oView:SetModel(oModel)

    oView:AddField("VIEW_HZ4", oStructHZ4, "HZ4MASTER")

    oView:CreateHorizontalBox("TELA", 100)
    oView:SetOwnerView("VIEW_HZ4", "TELA")

    oView:SetViewCanActivate({|oView| a161VldInc(oView)})
          
Return oView

/*/{Protheus.doc} a161VldCpo()
Verifica se todos os campos foram preenchidos.

@author michele.girardi
@since 25/02/2026
@param01: oView - Objeto da View MVC
@return: T ou F
/*/
Function a161VldCpo(oModel)
    Local lRet := .T.

    If Empty(oModel:GetModel("HZ4MASTER"):GetValue("HZ4_TMREQ"))
        Help(Nil,Nil,"Help",Nil,STR0047,1,0,,,,,,{STR0048}) //"Tipo de Requisição não preenchido." //"Informe o Tipo de Requisição."
        lRet := .F.
    EndIf

    If Empty(oModel:GetModel("HZ4MASTER"):GetValue("HZ4_TMDEV"))
        Help(Nil,Nil,"Help",Nil,STR0049,1,0,,,,,,{STR0050}) //"Tipo de Devolução não preenchido." //"Informe o Tipo de Devolução."
        lRet := .F.
    EndIf

    If Empty(oModel:GetModel("HZ4MASTER"):GetValue("HZ4_ANALIS"))
        Help(Nil,Nil,"Help",Nil,STR0051,1,0,,,,,,{STR0052}) //"Indicador Envia Análise não preenchido." //"Informe o indicador Envia Análise."
        lRet := .F.
    Else
        If oModel:GetModel("HZ4MASTER"):GetValue("HZ4_ANALIS") == "S" .And. oModel:GetModel("HZ4MASTER"):GetValue("HZ4_QTDTEN") <= 0
            Help(Nil,Nil,"Help",Nil,STR0053,1,0,,,,,,{STR0054})   //"Tentativas deve ser maior que zero." //"Informe a quantidade de tentativas válida."
            lRet := .F.
        EndIf
    EndIf

Return lRet

/*/{Protheus.doc} a161VldInc()
Valida se existe registro na HZ4 para permitir inclusão.
Pode existir somente um registro na HZ4 por filial.

@author michele.girardi
@since 25/02/2026
@param01: oView - Objeto da View MVC
@return: T ou F
/*/
Function a161VldInc(oView) 
    Local lRet := .T.

    If oView:GetOperation() == MODEL_OPERATION_INSERT
        dbSelectArea("HZ4")
	    HZ4->(dbSetOrder(1))
	    If HZ4->(dbSeek(xFilial("HZ4")))
            Help(Nil,Nil,"Help",Nil,STR0055,1,0,,,,,,{STR0056}) //"Já existe cadastro dos parâmetros iniciais para a filial." //"Altere o cadastro dos parâmetros iniciais existente."
            lRet := .F.
        EndIf
    EndIf
    
Return lRet

/*/{Protheus.doc} a161aVldTp()
Valida o Tipo do Movimento 

@author michele.girardi
@since 25/02/2026
@param01: cInd - 1-Requisição | 2-Devolução
@return lRet
/*/
Function a161aVldTp(cInd,cTipo)
    Local lRet := .T.
    
    Default cInd := "1"

    dbSelectArea("SF5")
	SF5->(dbSetOrder(1))
	If SF5->(dbSeek(xFilial("SF5")+cTipo))

        If cInd == "1" //Requisição        
            If SF5->F5_CODIGO <= '500'
                Help(Nil,Nil,"Help",Nil,STR0057,1,0,,,,,,{STR0058}) //"Tipo de movimento de Requisição deve ser maior que 500." //"Informe um tipo de movimento maior que 500."
                lRet := .F.
            EndIf
        Else
            //Devolução
            If SF5->F5_CODIGO > '500'
                Help(Nil,Nil,"Help",Nil,STR0059,1,0,,,,,,{STR0060}) //"Tipo de movimento de Devolução deve ser menor ou igual a 500." //"Informe um tipo de movimento menor ou igual a 500."
                lRet := .F.
            EndIf
        EndIf
    Else
        Help(Nil,Nil,"Help",Nil,STR0061,1,0,,,,,,{STR0062}) //"Tipo de movimento não cadastrado." //"Informe um tipo de movimento cadastrado no MATA230 - Tipos de Movimentação."
        lRet := .F.
    EndIf

Return lRet
