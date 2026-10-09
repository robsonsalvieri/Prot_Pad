#INCLUDE "PROTHEUS.CH"
#INCLUDE "LOJA1104.CH"
#INCLUDE 'FWMVCDEF.CH'
/* 
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LOJA1104  ºAutor  ³Vendas Clientes     º Data ³  22/02/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Cadastro de Processos de Replicacao                        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGALOJA                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LOJA1104()
 
Local oBrowse 		:= Nil

Private oCadastro 	:= Nil 
          
LjPopMD1() // Popula tabela de processos de integracao Off-Line

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('MD1')
oBrowse:SetDescription(STR0001) // "Cadastro de Processos"
oBrowse:Activate()

Return (Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºClasse³LjCCadProcesso ºAutor  ³Vendas Clientes  º Data ³ 25/02/08     º±±
±±ÌÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc. ³ Responsavel pela montagem do Cadastro de Processos            º±±
±±º      ³                                                               º±±
±±ÌÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso   ³ SIGALOJA                                                      º±±
±±ÈÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Class LjCCadProcesso From LjACadastro
	Method New()
	Method ValExc()
	Method ValOK()
	Method ValFim()
EndClass

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºMetodo³New            ºAutor  ³Vendas Clientes  º Data ³ 25/02/08     º±±
±±ÌÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc. ³ Instancia a Classe LjCCadProcesso a partir da heranca da      º±±
±±º      ³ Classe LjACadastro                                            º±±
±±ÌÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso   ³ LjCCadProcesso                                                º±±
±±ÈÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Method New() Class LjCCadProcesso
	//"Cadastro de Processos"
	_Super:New(	"MD1", STR0001, "oCadastro:ValExc()", "oCadastro:ValOK()",{||oCadastro:ValFim()})
Return Self
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºMetodo³ ValExc        ºAutor  ³Vendas Clientes  º Data ³ 25/02/08     º±±
±±ÌÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc. ³ Validacao de exclusao da tabela de Processos                  º±±
±±ÌÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRet.  ³ ExpL1 - Permite ou nao a exclusao do Registro                 º±±
±±ÌÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso   ³ LjCCadProcesso                                                º±±
±±ÈÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Method ValExc() Class LjCCadProcesso
	
	Local cCodigo	:= MD1->MD1_CODIGO				//Codigo do Processo
	Local lRetorno	:= .T.							//Retorno da Funcao
	Local cTipo		:=	"DELETE"					//Como os dados vao ser integrados no processo offline    
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se existe algum cadastro³
	//³utilizando a Tabela de Processos.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !ALTERA .AND. !INCLUI
		DbSelectArea("MD2")
		DbSetOrder(1)	//Filial + Processo + Tabela
		If DbSeek(xFilial("MD2") + cCodigo)
			lRetorno := .F.
		Else
			DbSelectArea("MD5")
			DbSetOrder(2)	//Filial + Processo
			If DbSeek(xFilial("MD5") + cCodigo)
				lRetorno := .F.
			EndIf
		EndIf
		
		If !lRetorno
			MsgAlert(STR0002)	//"Nao sera possivel excluir este registro, pois ele esta sendo utilizado em outro cadastro."
		Else
			//Insere o registro no processo off-line
		   	::ProcessOff("MD1", xFilial("MD1") + cCodigo, 1, cTipo, "001")
		EndIf
	EndIf

Return lRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºMetodo³ ValOK         ºAutor  ³Vendas Clientes  º Data ³ 25/02/08     º±±
±±ÌÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc. ³ Validacao do botao OK.                                        º±±
±±ÌÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRet.  ³ ExpL1 - Permite ou nao a confirmacao da Alteracao ou Inclusao º±±
±±ÌÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso   ³ LjCCadProcesso                                                º±±
±±ÈÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Method ValOK() Class LjCCadProcesso
	
	Local aArea		:= GetArea()						//Guarda a Area
	Local cCodigo	:= M->MD1_CODIGO					//Codigo do Processo
	Local lRetorno	:= .T.								//Retorno da Funcao

	If INCLUI
		DbSelectArea("MD1")
		DbSetOrder(1)	//Filial + Processo
		
		If DbSeek(xFilial("MD1") + cCodigo)
			lRetorno := .F.
			MsgAlert(STR0003)		//"Ja existe um processo com este Codigo."
		EndIf
	EndIf
	
	RestArea(aArea)
	
Return lRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºMetodo³ ValFim        ºAutor  ³Vendas Clientes  º Data ³ 25/02/08     º±±
±±ÌÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc. ³ Validacao do fim do processo.                                 º±±
±±ÌÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso   ³ LjCCadProcesso                                                º±±
±±ÈÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Method ValFim() Class LjCCadProcesso
	
	Local cTipo := ""					//Como os dados vao ser integrados no processo offline    
	
	If INCLUI
		cTipo := "INSERT"
	ElseIf ALTERA
		cTipo := "UPDATE"
	EndIf
    
	If !Empty(cTipo)
		::ProcessOff("MD1", xFilial("MD1") + MD1->MD1_CODIGO, 1, cTipo, "001")    
	EndIf

Return Nil 




/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    |MenuDef   ³ Autor ³Vendas CRM             ³ Data ³26/01/12  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao de definição do aRotina                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ aRotina   retorna a array com lista de aRotina             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ LOJA1104                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()
Local aRotina := {}                                                                

ADD OPTION aRotina TITLE STR0004  	ACTION "PesqBrw" 		  OPERATION 1 ACCESS 0 //"Pesquisar"
ADD OPTION aRotina TITLE STR0005 	ACTION "VIEWDEF.LOJA1104" OPERATION 2 ACCESS 0 //"Visualizar" 
ADD OPTION aRotina TITLE STR0006    ACTION "VIEWDEF.LOJA1104" OPERATION 3 ACCESS 0 //"Incluir"
ADD OPTION aRotina TITLE STR0007    ACTION "VIEWDEF.LOJA1104" OPERATION 4 ACCESS 0 //"Alterar"
ADD OPTION aRotina TITLE STR0008    ACTION "VIEWDEF.LOJA1104" OPERATION 5 ACCESS 0 //"Excluir"

Return aRotina

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ModelDef  ºAutor  ³Vendas CRM          º Data ³  26/01/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Define o modelo de dados (MVC)                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       |LOJA1104                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ModelDef()

Local oStruMD1 := FWFormStruct( 1, 'MD1',,)
Local bCommit  := { |oModel| LJ1104Grava( oModel ) } 	// Grava os dados e faz chamada para loja off line
Local oModel   := Nil

oModel := MPFormModel():New('MD1M',,, bCommit,)
oModel:AddFields( 'MD1MASTER',, oStruMD1,,,)
oModel:GetModel( 'MD1MASTER' ):SetDescription( STR0001 )// "Cadastro de Processos"

Return oModel

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ViewDef   ºAutor  ³Vendas CRM          º Data ³  26/01/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Define a interface para cadastro de Processos em MVC.       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³LOJA1104                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ViewDef() 

Local oModel   := FWLoadModel( 'LOJA1104' )
Local oStruMD1 := FWFormStruct( 2, 'MD1',)
Local oView    := Nil

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( 'VIEW_MD1', oStruMD1, 'MD1MASTER' )
oView:CreateHorizontalBox( 'TELA' , 100 )
oView:SetOwnerView( 'VIEW_MD1', 'TELA' )

Return oView 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  |LJ1104Grava    ºAutor  ³Vendas CRM          º Data ³  26/01/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Bloco executado na gravacao dos dados do formulario.		  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³LOJA1104                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LJ1104Grava(oModel)     
Local aArea		:= GetArea()
Local nOperation	:= oModel:GetOperation()
Local cCodigo	 	:= oModel:GetValue( 'MD1MASTER', 'MD1_CODIGO' )
Local lRet			:= .T.
 
// Grava os dados 
lRet := FWFormCommit( oModel )

If lRet
	// Chamada loja off line
	Lj1104Of("001","MD1",cCodigo, 1)
EndIf

RestArea( aArea )

Return lRet

/*                         
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Lj1104Of  ³ Autor ³ IP-Vendas 			³ Data ³ 27/01/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Define a operacao que sera realizada na tabela de 	      ³±±
±±³			 ³ integracao de acordo com o processo de replicacao executado³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Registros utilizados na integracao Off-line                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Lj1104Of( cProcess, cTabela, cChave, nOrdem, cTipo)
		
	Local oProcessOff 	:= Nil											//Objeto do tipo LJCProcessoOffLine
	Local lAmbOffLn		:= .F.	        
			
	lAmbOffLn	 		:= SuperGetMv("MV_LJOFFLN", Nil, .F.)	//Identifica se o ambiente esta operando em offline		

	//Verifica se o ambiente esta em off-line
	If lAmbOffLn
		//Instancia o objeto LJCProcessoOffLine
		oProcessOff := LJCProcessoOffLine():New(cProcess)
		
		//Determina o tipo de operacao 
		If Empty(cTipo)
			If INCLUI
				cTipo := "INSERT"
			ElseIf ALTERA
				cTipo := "UPDATE"
			Else
				cTipo := "DELETE"				
			EndIf
		Endif    
		
		If cTipo = "DELETE"				
			//Considera os registros deletados
			SET DELETED OFF
		EndIf
			    
		If !Empty(cTipo)
			//Insere os dados do processo (registro da tabela)
			oProcessOff:Inserir(cTabela, xFilial(cTabela) + cChave, nOrdem, cTipo)	
				
			//Processa os dados 
			oProcessOff:Processar()	
		EndIf
		
		//Desconsidera os registros deletados
		SET DELETED ON
	EndIf
	
Return Nil 

/*                         
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    |LjPopMD1  ³ Autor ³ IP-Vendas 			³ Data ³ 27/01/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Popula Tabela de Processos de Integracao Off-Line 	      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ LOJA1104									                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LjPopMD1()
 
Local aArea	:= GetArea()	  		// Guarda a Area corrente
Local aProcessos := IIf(ExistFunc("LjProcOff"),LjProcOff("MD1"),{}) 	// Carrega array com processos padrao
Local aEstrut	 := {}             // Estrutura MD1
Local aEstTabXProc := {}			// Estrutura de relacao entre as posicoes dos campos da tabela MD1 com o array aProcessos
Local nI := 0						// Contador 
Local nX := 0						// Contador

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Array configurado com a posicao corespondente dos       |
//|campos da MD1 com os campos do array de processos padrao³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aEstTabXProc := {"MD1_FILIAL","MD1_CODIGO","MD1_DESCRI","MD1_TIPO","MD1_ENABLE"}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Processamento dos campos no MD1   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ProcRegua(Len(aProcessos))
DbSelectArea("MD1")
aEstrut := DbStruct()
For nI := 1 To Len(aProcessos)
	IncProc()
	If !Empty(aProcessos[nI][2])
	MD1->(DbSetOrder(1)) //MD1_FILIAL + MD1_CODIGO
		If !(MD1->(DbSeek(aProcessos[nI][1] + aProcessos[nI][2])))
			RecLock("MD1",.T.)
			For nX := 1 To Len(aProcessos[nI]) 
				nPos := 0
				If MD1->(FieldPos(aEstrut[nX][1])) > 0 
					nPos := Ascan(aEstTabXProc,{|x| x == aEstrut[nX][1]}) // Posicao do campo da MD1 no aEstrutProcessos
					If nPos > 0
						FieldPut(FieldPos(aEstrut[nX][1]),aProcessos[nI,nPos])
					EndIf
				EndIf
			Next nX
			DbCommit()
			MsUnLock()
		Endif
	Endif
Next nI                  
  	
RestArea(aArea)                      

Return Nil    


/*                         
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    |LjProcOff ³ Autor ³ IP-Vendas 			³ Data ³ 27/01/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna Array com os Processos de Integracao Off-Line      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Integracao Off-Line						                  ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExp1 - Tabela que sera gravada	Ex: "MD1", "MD2"		  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjProcOff(cTabela) 

Local aProcessos 	:= {}  			// Array com processos padrao 
Local aArea			:= GetArea()   // Guarda area corrente

DbSelectArea(cTabela)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Para adicionar/alterar processos, modificar o array     |
//|conforme estrutura atual. Este Array trata MD1 e MD2	   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//						FILIAL 				CODIGO		DESCRICAO	   		TIPO		ENABLE	   		TABELA 
//	  	VALORES DEFAULT ->												I=INTEGRACAO    FALSO

AADD(aProcessos,{	xFilial(cTabela),		"001",		"CAD PROCESSOS",	"I", 		.F.,			{"MD1"}		})												   		
AADD(aProcessos,{	xFilial(cTabela),		"002",		"CAD PRAC X TAB",	"I", 		.F.,			{"MD2"}     })		
AADD(aProcessos,{	xFilial(cTabela),		"003",		"CAD WS",			"I", 		.F.,			{"MD3"}     })		
AADD(aProcessos,{	xFilial(cTabela),		"004",		"CAD AMBIENTES",	"I", 		.F.,			{"MD4"}     })		
AADD(aProcessos,{	xFilial(cTabela),		"005",		"CAD PROC X AMB",	"I", 		.F.,			{"MD5"}     })		
AADD(aProcessos,{	xFilial(cTabela),		"006",		"VENDA ASSISTIDA",	"I", 		.F.,			{"SD2","SE1","SE5","SEF","SL1","SL2","SC0","SL4","SB2"}	})		
AADD(aProcessos,{	xFilial(cTabela),		"007",		"CLIENTES",			"I", 		.F.,			{"SA1", "AI0"}     })		
AADD(aProcessos,{	xFilial(cTabela),		"008",		"DEVOLUCAO",   		"I", 		.F.,			{"SF1","SE5","SD1"} }) 		
AADD(aProcessos,{	xFilial(cTabela),		"009",		"RESUMO REDUCAO",	"I", 		.F.,			{"SFI"}     })
AADD(aProcessos,{	xFilial(cTabela),		"010",		"PRECO E PRODUTO",	"I", 		.F.,			{"SB0","SB1"} })		
AADD(aProcessos,{	xFilial(cTabela),		"011",		"CODIGO DE BARRA",	"I", 		.F.,			{"SLK"}     })		
AADD(aProcessos,{	xFilial(cTabela),		"012",		"ADM FINANCEIRA",	"I", 		.F.,			{"SAE", "MDE"}     })		
AADD(aProcessos,{	xFilial(cTabela),		"013",		"COND PAGAMENTO",	"I", 		.F.,			{"SE4"}     })		
AADD(aProcessos,{	xFilial(cTabela),		"014",		"TES",				"I", 		.F.,			{"SF4"}     })		
AADD(aProcessos,{	xFilial(cTabela),		"015",		"BANCOS",  			"I", 		.F.,			{"SA6"}     })		
AADD(aProcessos,{	xFilial(cTabela),		"016",		"CAIXA",			"I", 		.F.,			{"SLF"}     }) 		
AADD(aProcessos,{	xFilial(cTabela),		"017",		"SENHAS",  			"I", 		.F.,			{"SLF"}     })	
AADD(aProcessos,{	xFilial(cTabela),		"018",		"BAIXA DE TITULO",	"I", 		.F.,			{"SE1","SEF","SE5"} })		
AADD(aProcessos,{	xFilial(cTabela),		"019",		"CAB TAB PRECOS",	"I", 		.F.,			{"DA0"}     })		
AADD(aProcessos,{	xFilial(cTabela),		"020",		"ITENS TAB PRECO",	"I", 		.F.,			{"DA1"}     })		
AADD(aProcessos,{	xFilial(cTabela),		"021",		"CAB REGRA DESC",	"I", 		.F.,			{"ACO"}     })		
AADD(aProcessos,{	xFilial(cTabela),		"022",		"ITENS REGRA DES",	"I", 		.F.,			{"ACP"}     })		
AADD(aProcessos,{	xFilial(cTabela),		"023",		"CAB TAB BONIFIC",	"I", 		.F.,			{"ACQ"}     })		
AADD(aProcessos,{	xFilial(cTabela),		"024",		"ITENS TAB BONIF",	"I", 		.F.,			{}	        })		
AADD(aProcessos,{	xFilial(cTabela),		"025",		"VENDEDORES",		"I", 		.F.,			{"SA3"}     })		
AADD(aProcessos,{	xFilial(cTabela),		"026",		"SIMILARIDADE PRC",	"I", 		.F.,			{"MHC"}     })		
AADD(aProcessos,{	xFilial(cTabela),		"027",		"KIT DE VENDAS",	"I", 		.F.,			{"MHD","MHE"} })		
AADD(aProcessos,{	xFilial(cTabela),		"028",		"REGRAS DE DESC",	"I", 		.F.,			{"ACO","ACP"} })		
AADD(aProcessos,{	xFilial(cTabela),		"029",		"PLANO FIDELIDAD",	"I", 		.F.,			{"MHG","LHF"} })		
AADD(aProcessos,{	xFilial(cTabela),		"030",		"APRESENTACAO",		"I", 		.F.,			{"MHB"}     })		
AADD(aProcessos,{	xFilial(cTabela),		"031",		"MOT VENDA PERD",	"I", 		.F.,			{"MBQ"}     })	
AADD(aProcessos,{	xFilial(cTabela),		"032",		"MOVIMENT VND PERD","I", 		.F.,			{"MBR"}     })		
AADD(aProcessos,{	xFilial(cTabela),		"033",		"CAD MIDIA",		"I", 		.F.,			{"SUH"}     })		
AADD(aProcessos,{	xFilial(cTabela),		"034",		"CAD MOTIVO DESC",	"I", 		.F.,			{"MDT"}     })		
AADD(aProcessos,{	xFilial(cTabela),		"035",		"MOTIVO DESCONTO",	"I", 		.F.,			{"MDU"}     }) 

RestArea( aArea )
	
Return (aProcessos)      
