#INCLUDE "FISA302F.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"

/*
Fonte responsavel por funções de regra
*/

//-------------------------------------------------------------------
/*/{Protheus.doc} FISA302F()

Cadastro de Regra, gera uma carga inicial com as regras x descrição dos codigos de ajuste 
da tabela 5.7.
 O cliente precisa apenas relacinar o codigo da regra com o codigo de ajuste correspondente.

@author Rafael.soliveira
@since 04/11/2019
@version 12.1.25
/*/
//-------------------------------------------------------------------
Function FISA302F()

Local   oBrowse := Nil

Private lAutomato := Iif(IsBlind(),.T.,.F.)

//Verifico se as tabelas existem antes de prosseguir
If AliasIndic("CIM")	
    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("CIM")	
    oBrowse:SetDescription("") // Cadastro de Regras - Ressarcimento ICMS-ST
    oBrowse:SetFilterDefault("CIM_FILIAL == " + ValToSql(xFilial("CIM")))
	If !lAutomato
    	oBrowse:Activate()
	EndIF
Else
	If !lAutomato
    	Help("",1,"Help","Help",STR0001,1,0)  //"Dicionário desatualizado, verifique as atualizações Decreto 54.308"
	EndIF
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc}MenuDef
Funcao responsável por gerar menu

@author Rafael.soliveira
@since 04/11/2019
@version P12.1.25

/*/
//-------------------------------------------------------------------
Static Function MenuDef()
//Return FWMVCMenu("FISA302F")

Local aRotina	:= {}

ADD OPTION aRotina Title "Visualizar"    Action 'VIEWDEF.FISA302F' OPERATION 2 ACCESS 0 // 'Visualizar'
ADD OPTION aRotina Title "Alterar"       Action 'VIEWDEF.FISA302F' OPERATION 4 ACCESS 0 // 'Alterar'


Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc}  ModelDef
Função que criará o modelo o cadastro de regra na tabela CIM

@author bruce.Mello
@since 2
@version P12.1.25

/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oModel := Nil
Local oCabecalho := FWFormStruct(1, "CIM" )

//Instanciando o modelo
oModel	:=	MPFormModel():New('FISA302F') 

//Atribuindo estruturas para o modelo
oModel:AddFields("FISA302F",,oCabecalho)

//Adicionando descrição ao modelo
oModel:SetDescription(STR0002) //"Cadastro de Regras"


//Bloqueia o campo CIM_DESCRI para alteração.
oCabecalho:SetProperty('CIM_DESCRI' , MODEL_FIELD_WHEN ,{||.F.} )

//Bloqueia o campo CIM_REGRA para alteração.
oCabecalho:SetProperty('CIM_REGRA' , MODEL_FIELD_WHEN ,{||.F.} )

//Validação do campo CIM_CODIGO.
oCabecalho:SetProperty('CIM_CODIGO', MODEL_FIELD_VALID  ,{|| VldCod57(oModel)})
oCabecalho:SetProperty('CIM_CODIGO', MODEL_FIELD_OBRIGAT,.F.)

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@author 
@since 27/11/2018
@version P12.1.25

/*/
//-------------------------------------------------------------------
Static Function ViewDef()

//Criação do objeto do modelo de dados da Interface do Cadastro
Local oModel     := FWLoadModel( "FISA302F" )

//Criação da estrutura de dados utilizada na interface do cadastro
Local oCabecalho    := FWFormStruct(2, "CIM")
Local oView         := Nil
Local cVersao       := GetVersao(.F.)

oView := FWFormView():New()
oView:SetModel( oModel )


//Ajuste do Título do campo CIM_DESCRI.
oCabecalho:SetProperty("CIM_DESCRI", MVC_VIEW_TITULO, STR0003)  //"Descrição da Regra"

//Ajuste do Título do campo CIM_REGRA.
oCabecalho:SetProperty("CIM_REGRA", MVC_VIEW_TITULO, STR0004)  //"Regra de Cálculo"

//Atribuindo formulários para interface
oView:AddField( 'VIEW_CABECALHO', oCabecalho    , 'FISA302F')

//Criando um container com nome tela com 100%
oView:CreateHorizontalBox( 'SUPERIOR'  , 20 )
oView:CreateHorizontalBox( 'INFERIOR'  , 80 )

//O formulário da interface será colocado dentro do container
oView:SetOwnerView( 'VIEW_CABECALHO', 'SUPERIOR' )

//Colocando título do formulário
oView:EnableTitleView('VIEW_CABECALHO', STR0005 ) //"CADASTRO DE REGRA"

If cVersao == '12'
	oView:SetViewProperty("*", "ENABLENEWGRID")
	oView:SetViewProperty("*", "GRIDNOORDER")
EndIf

Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} FISA302Carga
Funcao responsável por realizar a carga inicial dos registros.

@author Rafael.soliveira
@since 04/11/2019
@version 1.0

/*/
//-------------------------------------------------------------------
Function FISA302Carga()
Local aRegra := {{'00','Operação não ensejadora de Ressarcimento, Restituição ou Complemento de ICMS-ST'},;                                                                  //---UF000 ---//
                 {'01','Ressarcimento/Restituição - Saída a Consumidor Final com valor de saída inferior ao valor da BC ICMS ST'},;                                          //---UF100 ---//
                 {'02','Ressarcimento/Restituição - Relativo ao fato gerador presumido não realizado (perda, roubo, furto ou deterioração)'},;                               //---UF200 ---//
                 {'03','Ressarcimento/Restituição - Saída que promover ou saída subseqüente amparada por isenção ou não-incidência'},;                                       //---UF200 ---//
	             {'04','Ressarcimento/Restituição - Saída destinada a outro Estado.'},;                                                                                      //---UF200 ---//
                 {'06','Complemento -Saída a Consumidor Final com valor de saída superior ao valor da BC ICMS ST'},;                                                         //---UF300 ---//
                 {'07','Devolução de entrada - Saída sem ressarcimento ou complemento'},;                                                                                    //---UF400 ---//
                 {'08','Devolução de saída - Entrada sem estorno de ressarcimento ou complemento'},;                                                                         //---UF500 ---//
                 {'09','Devolução de saída - Entrada com estorno de ressarcimento calculado com base no valor saída inferior a BC ICMS ST'},;                                //---UF600 ---//
                 {'10','Devolução de saída - Entrada com estorno de complemento calculado com base no valor saída superior a BC ICMS ST'},;                                  //---UF800 ---//
                 {'11','Devolução de saída - Entrada com estorno de ressarcimento relativo ao fato gerador presumido não realizado (perda, roubo, furto ou deterioração)'},; //---UF700 ---//
                 {'12','Devolução de saída - Entrada com estorno de ressarcimento - Saída amparada por isenção ou não-incidência'},;                                         //---UF700 ---//
                 {'13','Devolução de saída - Entrada com estorno de ressarcimento - Saída destinada a outro Estado'}}                                                        //---UF700 ---//
Local nX := 0

DbSelectArea("CIM")
DbGoTop()
For nX:= 1 to Len(aRegra)
	If !CIM->(DBSEEK(XFILIAL("CIM")+aRegra[NX][1],.F.))
		RECLOCK("CIM",.T.)
		CIM->CIM_FILIAL   := xFilial("CIM")
		CIM->CIM_REGRA    := aRegra[NX][1]
		CIM->CIM_DESCRI	  := aRegra[NX][2]
		MsUnLock()
	Endif
Next Nx

return

//-------------------------------------------------------------------
/*/{Protheus.doc} FISA302Enq
Funcao responsável por retornar código definido pelo cliente

@author Rafael.soliveira
@since 04/11/2019
@version 1.0

/*/
//-------------------------------------------------------------------
Function FISA302Enq(cCodEnquad)
Local cRegra := ""
Local CodEnq := ""

DbSelectArea("CIM")
If CIM->(DbSeek(xFilial("CIM")+cCodEnquad))
	CodEnq := CIM->CIM_CODIGO
	cRegra := CIM->CIM_REGRA
Endif

Return {cRegra,CodEnq}

//-------------------------------------------------------------------
/*/{Protheus.doc} VldCod57
Funcao de validação do código da tabela 5.7

@author Ulisses.Oliveira
@since 26/01/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function VldCod57(oModel)
Local nOperation := oModel:GetOperation()
Local lRet       := .T.
Local cCod57     := oModel:GetValue('FISA302F',"CIM_CODIGO")

If nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE
    If !Empty(AllTrim(cCod57)) .And. !ExistCpo("CIF", cCod57)
	    lRet := .F.
    EndIf
EndIf

Return lRet