#include "protheus.ch"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"

PUBLISH MODEL REST NAME FISA177 SOURCE FISA177

//-------------------------------------------------------------------
/*/{Protheus.doc} FISA161()

Esta rotina é apenas para montar a Tela com base nas informações
da tabela CIN (Cabeçalho Regra Conf Tributos)

Esta rotina estará disponível somente na versão 12.

@author Renato Rezende
@since 07/02/2020
@version P12.1.30
/*/
//-------------------------------------------------------------------
Function FISA177()

Local   oBrowse := Nil
//Verifico se as tabelas existem antes de prosseguir
IF AliasIndic("CIN")
    dbSelectArea("CIN")
    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("CIN")
    oBrowse:SetDescription("Cabeçalho Regra Conf Tributos")
    oBrowse:Activate()
Else
    Help("",1,"Help","Help","Dicionário desatualizado, verifique as atualizações do motor tributário fiscal.",1,0)
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc}MenuDef
Funcao responsável por gerar o menu.

@author Renato Rezende
@since 07/02/2020
@version P12.1.30

/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

//Habilitar no menu apenas visualização, essa tabela é manipulada apenas pelo sistema
ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.FISA177" OPERATION 2 ACCESS 0 //"Visualizar"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc}  ModelDef
Função que criará o modelo

@author Renato Rezende
@since 07/02/2020
@version P12.1.30

/*/
//-------------------------------------------------------------------
Static Function ModelDef()

//Criação do objeto do modelo de dados
Local oModel := Nil

//Estrutura da tabela CIN com os campos da Regra Conf Tributos
Local oCabecalho := FWFormStruct(1, "CIN" )

//Instanciando o modelo
oModel	:=	MPFormModel():New('FISA177')

//Atribuindo estruturas para o modelo
oModel:AddFields("FISA177",,oCabecalho)

//Chave do Modelo
oModel:SetPrimaryKey( {"CIN_FILIAL","CIN_CODIGO","CIN_ALTERA","CIN_ID"} )

//Adicionando descrição ao modelo
oModel:SetDescription("Cabeçalho Regra Conf Tributos")

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@author Renato Rezende
@since 07/02/2020
@version P12.1.30

/*/
//-------------------------------------------------------------------
Static Function ViewDef()

//Criação do objeto do modelo de dados
Local oModel        := FWLoadModel( "FISA177" )
Local oCabecalho    := FWFormStruct(2, "CIN")
Local oView         := Nil

oView := FWFormView():New()
oView:SetModel( oModel )

//Atribuindo formulários para interface
oView:AddField( 'VIEW_FSA177' , oCabecalho  , 'FISA177'   )

//Retirando os campos do View
oCabecalho:RemoveField("CIN_ID")
oCabecalho:RemoveField("CIN_IREGRA")
oCabecalho:RemoveField("CIN_FNPI")
oCabecalho:RemoveField("CIN_ALTERA")
oCabecalho:RemoveField("CIN_CONSUL")

Return oView



//-------------------------------------------------------------------
/*/{Protheus.doc} X177TIPO
Função para Retornar conteudo para combo do campo CIN_TPREGRA

@parametros
cStr - String que será trabalhada
cCampo - Campo que verificaremos o tamanho
cOper - Operador utilizado para saber onde sera adicionado o espaço em branco

@author Matheus Massarotto
@since 12/02/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Function X177TIPO()
Local cRet := ""

    cRet := '0=Valor Origem;1=Regra Base de Cálculo;2=Regra Alíquota;4=URF;6=Base do Tributo;7=Alíquota do Tributo;8=Valor do Tributo;9=Índices de Cálculo;11=Alíquota da Tabela Progressiva;12=Dedução da Tabela Progressiva'

Return cRet
