#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "EICSJE.CH"
/*
Programa   : EICSJE
Objetivo   : Utilizar as funcionalides dos Menus Funcionais em funções que não estão 
             definidas em um programa com o mesmo nome da função. 
Autor      : Rodrigo Mendes Diaz 
Data/Hora  : 25/04/07 11:46:09 
Obs.       : Criado com gerador automático de fontes 
Revisão    : Clayton Fernandes - 04/04/2011
Obs        : Adaptação do Codigo para o padrão MVC 
*/ 

/* 
Funcao     : MenuDef() 
Parametros : Nenhum 
Retorno    : aRotina 
Objetivos  : Chamada da função MenuDef no programa onde a função está declarada. 
Autor      : Rodrigo Mendes Diaz 
Data/Hora  : 25/04/07 11:46:09                     
Revisão    : Clayton Fernandes - 04/04/2011
Obs        : Adaptação do Codigo para o padrão MVC 
*/ 


Static Function MenuDef() 
Local aRotina := {}                       

//Adiciona os botões na MBROWSE
ADD OPTION aRotina TITLE "Pesquisar"  ACTION "AxPesqui"        OPERATION 1 ACCESS 0
ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.EICSJE" OPERATION 2 ACCESS 0
ADD OPTION aRotina TITLE "Incluir"    ACTION "VIEWDEF.EICSJE" OPERATION 3 ACCESS 0
ADD OPTION aRotina TITLE "Alterar"    ACTION "VIEWDEF.EICSJE" OPERATION 4 ACCESS 0
ADD OPTION aRotina TITLE "Excluir"    ACTION "VIEWDEF.EICSJE" OPERATION 5 ACCESS 0

Return aRotina  
                                           
                      
Function MVC_SJEEIC()
Local oBrowse                                             
                                      
//CRIAÇÃO DA MBROWSE
oBrowse := FWMBrowse():New() //Instanciando a Classe
oBrowse:SetAlias("SJE") //Informando o Alias                                             `
oBrowse:SetMenuDef("EICSJE") //Nome do fonte do MenuDef
oBrowse:SetDescription(STR0001)//Doc.p/ Instr.desp.
oBrowse:Activate()

Return 
 
//CRF 
*-------------------------*
Static Function ModelDef()
*-------------------------*
Local oModel  
Local oStruSJE := FWFormStruct( 1, "SJE") //Monta a estrutura da tabela SJO
//Local bCommit  := {|oMdl| EasyMVCGrava(oMdl,"SJE")}                                                

// Nova função de pré-validação: verifica duplicidade JE_TIPOREG+JE_CODIGO
Local bPosValidacao := {|oMdl,oView| ProsValSJE(oMdl,oView)}

/*Criação do Modelo com o cID = "EXPP018", este nome deve conter como as tres letras inicial de acordo com o
  módulo. Exemplo: SIGAEEC (EXP), SIGAEIC (IMP) */
oModel := MPFormModel():New( 'IMPP018', /*bPreValid*/, bPosValidacao, /*bCommit*/, /*bCancel*/ )

//Modelo para criação da antiga Enchoice com a estrutura da tabela SJO
oModel:AddFields( 'EICP018_SJE',/*nOwner*/,oStruSJE, /*bPreValidacao*/, /*bPosValidacao*/,/*bCarga*/)    

//Adiciona a descrição do Modelo de Dados
oModel:SetDescription(STR0001)//Doc.p/ Instr.desp.

//Utiliza a chave primaria
oModel:SetPrimaryKey({''})
  
  
Return oModel
  
                                                               
//CRF
*------------------------*
Static Function ViewDef()
*------------------------*

// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel := FWLoadModel("EICSJE")

// Cria a estrutura a ser usada na View
Local oStruSJE:=FWFormStruct(2,"SJE")                        

Local oView  
 
// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados a ser utilizado
oView:SetModel( oModel ) 

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField('EICP018_SJE', oStruSJE)

//Relaciona a quebra com os objetos
oView:SetOwnerView( 'EICP018_SJE') 

//Habilita ButtonsBar
oView:EnableControlBar(.T.)

Return oView

// ------------------------------------------------------------------
// Pré-validação de duplicidade para tabela SJE
// ------------------------------------------------------------------
Static Function ProsValSJE(oMdl,oView)
Local lRet := .T.
Local cTipo := ""
Local cCod  := ""
Local aArea := GetArea()
Local oMdlSJE := nil

if AvFlags('TIPOREG_DOCS_IMP')
   If ValType(oMdl) == "O" .and. (oMdl:GetOperation() == 3)
      // Tenta obter campos (nomes conforme estrutura SJE)
      oMdlSJE := oMdl:GetModel():GetModel("EICP018_SJE")
         
      cTipo := oMdlSJE:GetValue("JE_TIPOREG")            
      cCod  := oMdlSJE:GetValue("JE_CODIGO")
      
      if !Empty(Posicione("SJE", 2, xFilial("SJE") + cTipo + cCod, "JE_CODIGO") )
         easyHelp(STR0002,STR0003,STR0004) //'Já existe registro com esta informação', 'ATENÇÃO', 'Troque a chave principal deste registro.'
         lRet := .F.
      EndIf
   EndIf
Endif   
RestArea(aArea)
Return lRet
