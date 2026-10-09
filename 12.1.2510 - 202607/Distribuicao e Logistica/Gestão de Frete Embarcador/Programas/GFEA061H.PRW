#INCLUDE "GFEA061H.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

/*/--------------------------------------------------------------------------------------------------
{Protheus.doc} GFEA061H
Componente da Tarifa X Emitente.
Uso Generico.

@param  lFiltGV6        Indica se deve utilizar filtro de programa.

@sample
GFEA061H()

@author Felipe M., Felipe W.
@since 14/10/09
@version 1.0
--------------------------------------------------------------------------------------------------/*/
Function GFEA061H(lFiltGV6)
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetAlias("GUC")						 // Alias da tabela utilizada
oBrowse:SetMenuDef("GFEA061H")				 // Nome do fonte onde esta a função MenuDef
oBrowse:SetDescription(STR0001)	 // Descrição do browse //"Componente da Tarifa X Emitente"

If lFiltGV6
    oBrowse:SetFilterDefault("GUC_FILIAL == '" + GV6->(GV6_FILIAL) + "'" + " .And. GUC_CDEMIT == '" + GV6->(GV6_CDEMIT) + "'" + " .And. GUC_NRTAB == '" + GV6->(GV6_NRTAB) + "'" + " .And. GUC_NRNEG == '" + GV6->(GV6_NRNEG) + "'" + " .And. GUC_CDFXTV == '" + GV6->(GV6_CDFXTV) + "'" + " .And. GUC_NRROTA == '" + GV6->(GV6_NRROTA) + "'")
							   
EndIf

oBrowse:Activate()

Return(Nil)

//---------------------------------------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}
// Adiciona botões do browse
ADD OPTION aRotina TITLE STR0002 ACTION "AxPesqui"         OPERATION 1 ACCESS 0 //"Pesquisar"
ADD OPTION aRotina TITLE STR0003 ACTION "VIEWDEF.GFEA061H" OPERATION 2 ACCESS 0 //"Visualizar"
ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.GFEA061H" OPERATION 3 ACCESS 0 //"Incluir"
ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.GFEA061H" OPERATION 4 ACCESS 0 //"Alterar"
ADD OPTION aRotina TITLE STR0006 ACTION "VIEWDEF.GFEA061H" OPERATION 5 ACCESS 0 //"Excluir"
ADD OPTION aRotina TITLE STR0007 ACTION "VIEWDEF.GFEA061H" OPERATION 7 ACCESS 0 //"Copiar"
ADD OPTION aRotina TITLE STR0008 ACTION "VIEWDEF.GFEA061H" OPERATION 8 ACCESS 0 //"Imprimir"
//verificar rotina de criação de botões (botões faltando conforme PL)

Return aRotina

//---------------------------------------------------------------------------------------------------
Static Function ModelDef()

Local oModel

// cID     Identificador do modelo 
// bPre    Code-Block de pre-edição do formulário de edição. Indica se a edição esta liberada
// bPost   Code-Block de validação do formulário de edição
// bCommit Code-Block de persistência do formulário de edição
// bCancel Code-Block de cancelamento do formulário de edição
oModel := MPFormModel():New("GFEA061H", /*bPre*/, /*bPost*/,/*bCommit*/, /*bCancel*/)
// cId          Identificador do modelo
// cOwner       Identificador superior do modelo
// oModelStruct Objeto com  a estrutura de dados
// bPre         Code-Block de pré-edição do formulário de edição. Indica se a edição esta liberada
// bPost        Code-Block de validação do formulário de edição
// bLoad        Code-Block de carga dos dados do formulário de edição
oModel:AddFields("GFEA061H_GUC", Nil, FWFormStruct(1,"GUC"),/*bPre*/,/*bPost*/,/*bLoad*/)
oModel:SetPrimaryKey({"GUC_FILIAL", "GUC_CDEMIT", "GUC_NRTAB", "GUC_NRNEG", "GUC_CDFXTV", "GUC_NRROTA", "GUC_CDCOMP", "GUC_EMICOM"}) 
                                     
Return oModel

//---------------------------------------------------------------------------------------------------
Static Function ViewDef()

Local oModel := FWLoadModel("GFEA061H")
Local oView  := Nil

oView := FWFormView():New()
// Objeto do model a se associar a view.
oView:SetModel(oModel)
// cFormModelID - Representa o ID criado no Model que essa FormField irá representar
// oStruct - Objeto do model a se associar a view.
// cLinkID - Representa o ID criado no Model ,Só é necessári o caso estamos mundando o ID no View.
oView:AddField( "GFEA061H_GUC" , FWFormStruct(2,"GUC"), /*cLinkID*/ )	//
// cID		  	Id do Box a ser utilizado 
// nPercHeight  Valor da Altura do box( caso o lFixPixel seja .T. é a qtd de pixel exato)
// cIdOwner 	Id do Box Vertical pai. Podemos fazer diversas criações uma dentro da outra.
// lFixPixel	Determina que o valor passado no nPercHeight é na verdade a qtd de pixel a ser usada.
// cIDFolder	Id da folder onde queremos criar o o box se passado esse valor, é necessário informar o cIDSheet
// cIDSheet     Id da Sheet(Folha de dados) onde queremos criar o o box.
oView:CreateHorizontalBox( "MASTER" , 100,/*cIDOwner*/,/*lFixPixel*/,/*cIDFolder*/,/*cIDSheet*/ )
// Associa um View a um box
oView:SetOwnerView( "GFEA061H_GUC" , "MASTER" )

Return oView

/*/--------------------------------------------------------------------------------------------------
{Protheus.doc} GFE61HPOS
Validacao de Inclusao e Alteracao.
Uso GFEA061H.

@param  oModel        Objeto modelo

@sample
GFE61HPOS()

@author Felipe M., Felipe W.
@since 14/10/09
@version 1.0
--------------------------------------------------------------------------------------------------/*/
Function GFE61HPOS(oModel)
Local nOp  := (oModel:getOperation())
Local cSeek 
Local lRet := .T.

If nOp == 3 .OR. nOp == 4// Se for alteração
    
 	
	cSeek := oModel:GetValue( 'GFEA061A_GV9', 'GV9_CDCLFR' )
	cSeek += Dtos(oModel:GetValue( 'GFEA061A_GV9', 'GV9_DTVALI' ))
	cSeek += oModel:GetValue( 'GFEA061A_GV9', 'GV9_CDTPOP' )		
    
    dbSelectArea("GV9")  // seleciona a tabela
	dbSetOrder(01)       // Seta o indice
	dbGoTop()            // posiciona no primeiro registro
	While !Eof()
    	If GV9->GV9_CDCLFR + Dtos(GV9->GV9_DTVALI) + GV9->GV9_CDTPOP == cSeek
    		ShowHelpDlg(STR0009,{STR0010,""},2,{STR0011,""},2) 	 //"Erro de Inclusão"###"Já existe campo com Base Pedágio ativo"###"Campo Base Pedágio deve ser inativo"
			lRet := .F.
			Exit
		Endif
		if ExistChav("GV9",oModel:GetValue( 'GFEA061A_GV9','GV9_CDEMIT')+oModel:GetValue('GFEA061A_GV9','GV9_NRTAB')+;
		   oModel:GetValue( 'GFEA061A_GV9','GV9_NRNEG'))
			ShowHelpDlg(STR0009,{STR0012,""},2,{STR0011,""},2) 	 //"Erro de Inclusão"###"Já existe campo as chaves definidas"###"Campo Base Pedágio deve ser inativo"
			lRet := .F.
			Exit
		Endif
		GV9->(dbSkip(1)) //vai para o proximo registro     
		
    End    

EndIf

Return lRet

/*/--------------------------------------------------------------------------------------------------
{Protheus.doc} GFEA61HVL
Validacao dos campos do dicionario.
Uso GFEA061H().

@param  cCampo        Campo para validacao, não obrigatório

@sample
GFEA61HVL(cCampo,oModel)

@author Felipe W.
@since 18/11/09
@version 1.0
--------------------------------------------------------------------------------------------------/*/
Function GFEA61HVL(cCampo)

Local aArea := GetArea()
Local lRet := .T.

Default cCampo := ReadVar()

If "GUC_EMICOM" $ cCampo
	If ExistCpo("GU3",M->GUC_EMICOM)
		If Posicione("GU3",1,xFilial("GU3")+M->GUC_EMICOM,"GU3_CLIEN") != "1"
			Help(,,'HELP',,STR0013,1,0)  //"O emitente informado deve estar cadastrado como Cliente."
			lRet := .F.
		Else
			If !Empty(M->GUC_CDCOMP)
				If !ExistChav("GUC",M->GUC_CDEMIT+M->GUC_NRTAB+M->GUC_NRNEG+M->GUC_CDFXTV+M->GUC_NRROTA+M->GUC_CDCOMP+M->GUC_EMICOM)
					lRet := .F.
				EndIf
			EndIf
		EndIf
	Else
		lRet := .F.
	EndIf	
ElseIf "GUC_CDCOMP" $ cCampo
	If !ExistCpo("GV2",M->GUC_CDCOMP)
		lRet := .F.
	Else
		If !Empty(M->GUC_EMICOM)
			If !ExistChav("GUC",M->GUC_CDEMIT+M->GUC_NRTAB+M->GUC_NRNEG+M->GUC_CDFXTV+M->GUC_NRROTA+M->GUC_CDCOMP+M->GUC_EMICOM)
				lRet := .F.
			EndIf
		EndIf
	EndIf
EndIf

RestArea(aArea)

Return lRet
