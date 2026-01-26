#INCLUDE "GFEA061D.ch" 
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
/*/--------------------------------------------------------------------------------------------------
{Protheus.doc} GFEA061D
Rota da tabela de frete.
Uso Generico.

@param  lFiltGV9        Inicia com filtro default

@sample
GFEA061D()

@author Felipe M., Felipe W.
@since 14/10/09
@version 1.0
--------------------------------------------------------------------------------------------------/*/
Function GFEA061D( lFiltGV9 )
Local oBrowse

Default lFiltGV9 := .F. 
  
/*Utiliza o comando Chkfile para abrir a Tabela com outro nome */
DbSelectArea('GV8')
Chkfile( 'GV8',,'GV8BF')  

oBrowse := FWMBrowse():New()
oBrowse:SetAlias("GV8")						 // Alias da tabela utilizada
oBrowse:SetMenuDef("GFEA061D")				 // Nome do fonte onde esta a função MenuDef
oBrowse:SetDescription(STR0001)	 // Descrição do browse //"Rota da tabela de frete"
If lFiltGV9
	
	oBrowse:SetFilterDefault("GV8_FILIAL == '" + GV9->(GV9_FILIAL) + "'" + " .And. GV8_CDEMIT == '" + GV9->(GV9_CDEMIT) + "'" + " .And. GV8_NRTAB == '" + GV9->(GV9_NRTAB) + "'" + " .And. GV8_NRNEG == '" + GV9->(GV9_NRNEG) + "'")
	
Endif
oBrowse:Activate()

/* Fecha a tabela */
GV8BF->( dbCloseArea() )

Return(Nil)

//---------------------------------------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}
// Adiciona botões do browse
ADD OPTION aRotina TITLE STR0002 ACTION "AxPesqui"         OPERATION 1 ACCESS 0 //"Pesquisar"
ADD OPTION aRotina TITLE STR0003 ACTION "VIEWDEF.GFEA061D" OPERATION 2 ACCESS 0 //"Visualizar"
ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.GFEA061D" OPERATION 3 ACCESS 0 //"Incluir"
ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.GFEA061D" OPERATION 4 ACCESS 0 //"Alterar"
ADD OPTION aRotina TITLE STR0006 ACTION "VIEWDEF.GFEA061D" OPERATION 5 ACCESS 0 //"Excluir"
ADD OPTION aRotina TITLE STR0007 ACTION "VIEWDEF.GFEA061D" OPERATION 7 ACCESS 0 //"Copiar"
ADD OPTION aRotina TITLE STR0008 ACTION "VIEWDEF.GFEA061D" OPERATION 8 ACCESS 0 //"Imprimir"

Return aRotina

//---------------------------------------------------------------------------------------------------
Static Function ModelDef()

Local oModel

// cID     Identificador do modelo 
// bPre    Code-Block de pre-edição do formulário de edição. Indica se a edição esta liberada
// bPost   Code-Block de validação do formulário de edição
// bCommit Code-Block de persistência do formulário de edição
// bCancel Code-Block de cancelamento do formulário de edição
oModel := MPFormModel():New("GFEA061D", /*bPre*/, {|oX|GFE61DPOS(oX)},/*bCommit*/, /*bCancel*/)
// cId          Identificador do modelo
// cOwner       Identificador superior do modelo
// oModelStruct Objeto com  a estrutura de dados
// bPre         Code-Block de pré-edição do formulário de edição. Indica se a edição esta liberada
// bPost        Code-Block de validação do formulário de edição
// bLoad        Code-Block de carga dos dados do formulário de edição
oModel:AddFields("GFEA061D_GV8", Nil, FWFormStruct(1,"GV8"),/*bPre*/,/*bPost*/,/*bLoad*/)
oModel:SetPrimaryKey({"GV8_FILIAL", "GV8_CDEMIT", "GV8_NRTAB", "GV8_NRNEG", "GV8_NRROTA"}) 

Return oModel

//---------------------------------------------------------------------------------------------------
Static Function ViewDef()

Local oModel := FWLoadModel("GFEA061D")
Local oView  := Nil

oView := FWFormView():New()
// Objeto do model a se associar a view.
oView:SetModel(oModel)
// cFormModelID - Representa o ID criado no Model que essa FormField irá representar
// oStruct - Objeto do model a se associar a view.
// cLinkID - Representa o ID criado no Model ,Só é necessári o caso estamos mundando o ID no View.
oView:AddField( "GFEA061D_GV8" , FWFormStruct(2,"GV8"), /*cLinkID*/ )	//
// cID		  	Id do Box a ser utilizado 
// nPercHeight  Valor da Altura do box( caso o lFixPixel seja .T. é a qtd de pixel exato)
// cIdOwner 	Id do Box Vertical pai. Podemos fazer diversas criações uma dentro da outra.
// lFixPixel	Determina que o valor passado no nPercHeight é na verdade a qtd de pixel a ser usada.
// cIDFolder	Id da folder onde queremos criar o o box se passado esse valor, é necessário informar o cIDSheet
// cIDSheet     Id da Sheet(Folha de dados) onde queremos criar o o box.
oView:CreateHorizontalBox( "MASTER" , 100,/*cIDOwner*/,/*lFixPixel*/,/*cIDFolder*/,/*cIDSheet*/ )
// Associa um View a um box
oView:SetOwnerView( "GFEA061D_GV8" , "MASTER" )

Return oView  

/*/--------------------------------------------------------------------------------------------------
{Protheus.doc} GFE61DPOS
Validacao de Inclusao e Alteracao.
Uso GFEA061D.

@param  oModel        Objeto modelo

@sample
GFE61DPOS(oModel)

@author Felipe M., Felipe W.
@since 14/10/09
@version 1.0
--------------------------------------------------------------------------------------------------/*/
Function GFE61DPOS(oModel)
Local aArea      := GetArea()
Local aAreaGV8   := GV8->( GetArea() )
Local nOp  := (oModel:getOperation())
Local lRet := .T.
Local cDest, cOrig
Local lCndD := .T.
Local lCndO := .T.
Local lBFO := .T.  //Verifica se cadastramento de rotas com origem e destino iguais.
Local lBFD := .T.

If nOp == MODEL_OPERATION_INSERT .OR. nOp == MODEL_OPERATION_UPDATE// Se for inclusao ou alteração
	cDest := oModel:GetValue( 'GFEA061D_GV8', 'GV8_TPDEST' )
	cOrig := oModel:GetValue( 'GFEA061D_GV8', 'GV8_TPORIG' )
	
	Do Case
		Case cDest $ "1"  //"Cidade"
			If Empty(oModel:GetValue( 'GFEA061D_GV8', 'GV8_NRCIDS' )) //Verifica se o campo está vazio
				lCndD = .F.
			EndIf 

		Case cDest $ "2" //"Distancia"
			If Empty(oModel:GetValue( 'GFEA061D_GV8', 'GV8_DSTDEF' )) .And. Empty(oModel:GetValue( 'GFEA061D_GV8', 'GV8_DSTDEI' ))
				lCndD = .F.
			Else
				If oModel:GetValue( 'GFEA061D_GV8', 'GV8_DSTDEF' ) < oModel:GetValue( 'GFEA061D_GV8', 'GV8_DSTDEI' )
					Help( ,, 'Help',, STR0010, 1, 0 )  //"Distância Destino Inicial deve ser menor ou igual à Distância Destino Final."
					lRet := .F.
				EndIf
			EndIf 
			
		Case cDest $ "3" //"Regiao"
			If Empty(oModel:GetValue( 'GFEA061D_GV8', 'GV8_NRREDS' ))//Verifica se o campo está vazio
				lCndD = .F.
			EndIf  

		Case cDest $ "4"  //"Pais/UF"
			If Empty(oModel:GetValue( 'GFEA061D_GV8', 'GV8_CDUFDS' )) .Or. Empty(oModel:GetValue( 'GFEA061D_GV8', 'GV8_CDPADS' ))//Verifica se o campo está vazio
				lCndD = .F.
			EndIf    

		Case cDest $ "5"  //"Filial"
			If Empty(oModel:GetValue( 'GFEA061D_GV8', 'GV8_CDDEST' ))//Verifica se o campo está vazio
				lCndD = .F.
			EndIf  

	Endcase
	
	Do Case
		Case cOrig $ "1"//"Cidade"
			If Empty(oModel:GetValue( 'GFEA061D_GV8', 'GV8_NRCIOR' )) //Verifica se o campo está vazio
				lCndO := .F.
			EndIf
			
		Case cOrig $ "2"//"Distancia"
			If Empty(oModel:GetValue( 'GFEA061D_GV8', 'GV8_DSTORF' )) .And. Empty(oModel:GetValue( 'GFEA061D_GV8', 'GV8_DTTORI' ))//Verifica se o campo está vazio
				lCndO := .F.
			Else
				If oModel:GetValue( 'GFEA061D_GV8', 'GV8_DSTORF' ) < oModel:GetValue( 'GFEA061D_GV8', 'GV8_DSTORI' )
					Help( ,, 'Help',, STR0011, 1, 0 )  //"Distância Origem Inicial deve ser menor ou igual à Distância Origem Final."
					lRet := .F.
				EndIf
			EndIf   
			
		Case cOrig $ "3"//"Regiao"
			If Empty(oModel:GetValue( 'GFEA061D_GV8', 'GV8_NRREOR' ))//Verifica se o campo está vazio
				lCndO := .F.	
			EndIf  
	
		Case cOrig $ "4"//"Pais/UF"
			If Empty(oModel:GetValue( 'GFEA061D_GV8', 'GV8_CDUFOR' )) .Or. Empty(oModel:GetValue( 'GFEA061D_GV8', 'GV8_CDPAOR' ))//Verifica se o campo está vazio 
				lCndO := .F.
			EndIf   
			
		Case cOrig $ "5"//"Filial"
			If Empty(oModel:GetValue( 'GFEA061D_GV8', 'GV8_CDREM' ))//Verifica se o campo está vazio
				lCndO := .F.
			EndIf
			
	Endcase
	
	// Verifica se existe uma rota com os mesmos dados de origem e destino cadastrados
 	dbSelectArea('GV8BF')
    dbSetOrder(1)
    If dbSeek(xFilial('GV8')+oModel:GetValue( 'GFEA061D_GV8', 'GV8_CDEMIT')+oModel:GetValue('GFEA061D_GV8','GV8_NRTAB')+oModel:GetValue('GFEA061D_GV8','GV8_NRNEG')) 
            
		While !Eof() .And. (xFilial('GV8')+oModel:GetValue( 'GFEA061D_GV8', 'GV8_CDEMIT')+oModel:GetValue('GFEA061D_GV8','GV8_NRTAB')+oModel:GetValue('GFEA061D_GV8','GV8_NRNEG') == ;
		GV8BF->GV8_FILIAL + GV8BF->GV8_CDEMIT + GV8BF->GV8_NRTAB + GV8BF->GV8_NRNEG)
            
            // Quando se trata de alteração, a rota que está em tela também esta gravada na base               
            If GV8BF->GV8_NRROTA != oModel:getValue('GFEA061D_GV8','GV8_NRROTA')

	            //Verifica se exite uma rota com os mesmo dados de origem, se existir ativa a flag de origem (lBFO)             
	            Do Case
	            	//"Cidade"
	            	Case (cOrig $ "1" .And. GV8BF->GV8_TPORIG $ "1" ) .And. oModel:GetValue( 'GFEA061D_GV8', 'GV8_NRCIOR' ) == GV8BF->GV8_NRCIOR 
						lBFO := .F. 
						 
					//"Distancia" 	
	            	Case (cOrig $ "2" .And. GV8BF->GV8_TPORIG $ "2") .And. oModel:GetValue( 'GFEA061D_GV8', 'GV8_DSTORI' ) == GV8BF->GV8_DSTORI .And. oModel:GetValue( 'GFEA061D_GV8', 'GV8_DSTORF' ) == GV8BF->GV8_DSTORF 
					 	lBFO := .F. 
					 	
					//"Regiao" 		 
		            Case (cOrig $ "3" .And. GV8BF->GV8_TPORIG $ "3") .And. oModel:GetValue( 'GFEA061D_GV8', 'GV8_NRREOR' )  == GV8BF->GV8_NRREOR
		            	lBFO := .F. 
		            	
					//"Pais/UF" 		
		            Case (cOrig $ "4" .And. GV8BF->GV8_TPORIG $ "4") .And. oModel:GetValue( 'GFEA061D_GV8', 'GV8_CDPAOR' ) + oModel:GetValue( 'GFEA061D_GV8', 'GV8_CDUFOR' )  == GV8BF->GV8_CDPAOR + GV8BF->GV8_CDUFOR 
		       			lBFO := .F.  
		       			
					//"Filial" 	
		            Case (cOrig $ "5" .And. GV8BF->GV8_TPORIG $ "5") .And. oModel:GetValue( 'GFEA061D_GV8', 'GV8_CDREM' ) == GV8BF->GV8_CDREM  
				    	lBFO := .F. 
				    	
				Endcase 
				
				//Verifica se exite uma rota com os mesmo dados de destino, se existir ativa a flag de destino (lBFD)     
				Do Case 
					//"Cidade"
					Case (cDest $ "1" .And. GV8BF->GV8_TPDEST $ "1") .And. oModel:GetValue( 'GFEA061D_GV8', 'GV8_NRCIDS' ) == GV8BF->GV8_NRCIDS
				   		lBFD := .F.
				   		
					//"Distancia" 
					Case (cDest $ "2" .And. GV8BF->GV8_TPDEST $ "2") .And. oModel:GetValue( 'GFEA061D_GV8', 'GV8_DSTDEI' ) == GV8BF->GV8_DSTDEI .And. oModel:GetValue( 'GFEA061D_GV8', 'GV8_DSTDEF' ) == GV8BF->GV8_DSTDEF
						lBFD := .F.  
						
				 	//"Regiao" 
				 	Case (cDest $ "3" .And. GV8BF->GV8_TPDEST $ "3") .And. oModel:GetValue( 'GFEA061D_GV8', 'GV8_NRREDS' )  == GV8BF->GV8_NRREDS
				   		lBFD := .F. 
				   		
				 	//"Pais/UF"
				 	Case (cDest $ "4" .And. GV8BF->GV8_TPDEST $ "4") .And. oModel:GetValue( 'GFEA061D_GV8', 'GV8_CDPADS' ) + oModel:GetValue( 'GFEA061D_GV8', 'GV8_CDUFDS' )  == GV8BF->GV8_CDPADS + GV8BF->GV8_CDUFDS
				 		lBFD := .F.
				 		
				 	//"Filial" 
			    	Case (cDest $ "5" .And. GV8BF->GV8_TPDEST $ "5") .And. oModel:GetValue( 'GFEA061D_GV8', 'GV8_CDDEST' ) == GV8BF->GV8_CDDEST 
			    
				Endcase
				
			EndIf
			GV8BF->(dbSkip()) 
                	
		EndDo  
	EndIf  
    
	If !lCndD .Or. !lCndO
		lRet := .F.
		Help( ,, 'Help',, STR0009, 1, 0 ) //"Campos relacionados aos Tipos 'Origem' e 'Destino' devem ser preenchidos."
	EndIf 
	//Se encontrar um registro que tenha os mesmo dados de origem e destino 
	If !lBFO .And. !lBFD
   		lRet := .F.
		Help( ,, 'Help',, STR0012, 1, 0 ) //"Não é permitido o cadastramento de rotas com origem e destino já cadastradas "
	EndIf
	
EndIf

RestArea(aAreaGV8)
RestArea(aArea)

Return lRet
