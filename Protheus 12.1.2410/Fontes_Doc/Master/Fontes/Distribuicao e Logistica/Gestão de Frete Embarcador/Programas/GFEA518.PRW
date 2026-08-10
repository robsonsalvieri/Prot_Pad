#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GFEA518.CH"

//-------------------------------------------------------------------
//Inclusão Pátios 12.1.4
/*/{Protheus.doc} GFEA518

Configuração da operação

@author Jorge Matos Valcanaia
@since 07/09/2010
@version 1.0
/*/
//-------------------------------------------------------------------
//-------------------------------------------------------------------
Function GFEA518()
	Local oBrowse
	Private lCopy := .F.

	If !GFECheckGX4()
		Return .F.
	EndIF

	If !GFEA510COMP()
		MsgStop( "Necessário aplicar o update U_GFE11I20 para utilizar o processo de pátios e portarias." )
		Return .F.
	EndIf

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("GVI")				// Alias da tabela utilizada
	oBrowse:SetMenuDef("GFEA518")		// Nome do fonte onde esta a função MenuDef
	oBrowse:SetDescription(STR0001) //"Configuração da operação"
	oBrowse:Activate()
Return(Nil)

//-------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina := {}
	Local s_GFEA5181 := ExistBlock("GFEA5181")
	//-------------------------------------------------------
	// Adiciona botões do browse
	//-------------------------------------------------------
	ADD OPTION aRotina TITLE STR0002 ACTION "AxPesqui"        OPERATION 1 ACCESS 0 //"Pesquisar"
	ADD OPTION aRotina TITLE STR0003 ACTION "VIEWDEF.GFEA518" OPERATION 2 ACCESS 0 //"Visualizar"
	ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.GFEA518" OPERATION 3 ACCESS 0 //"Incluir"
	ADD OPTION aRotina TITLE STR0005 ACTION "GFEA518OPC(4)"   OPERATION 4 ACCESS 0 //"Alterar"
	ADD OPTION aRotina TITLE STR0006 ACTION "GFEA518OPC(5)"   OPERATION 5 ACCESS 0 //"Excluir"
	ADD OPTION aRotina TITLE STR0007 ACTION "GFEA518COP()"    OPERATION 6 ACCESS 0 //"Copiar"
	ADD OPTION aRotina TITLE STR0008 ACTION "VIEWDEF.GFEA518" OPERATION 8 ACCESS 0 //"Imprimir"

	
	If s_GFEA5181
		aRotAdic := ExecBlock("GFEA5181",.f.,.f.)
		If ValType(aRotAdic) == "A"
			AEval(aRotAdic, {|x| AAdd(aRotina ,x)})
		EndIf
	EndIf

Return aRotina

//-------------------------------------------------------------------

Static Function ModelDef()
	Local oModel
	Local oStructGVI := FWFormStruct(1,"GVI")
	Local oStructGVJ := FWFormStruct(1,"GVJ")
	
	// cID     Identificador do modelo 
	// bPre    Code-Block de pre-edição do formulário de edição. Indica se a edição esta liberada
	// bPost   Code-Block de validação do formulário de edição
	// bCommit Code-Block de persistência do formulário de edição
	// bCancel Code-Block de cancelamento do formulário de edição
	oModel := MPFormModel():New("GFEA518",, {|oMod| GFEA518POS(oMod)}, /*bCommit*/, /*bCancel*/)
	
	oStructGVI:setProperty("GVI_CDOPER",MODEL_FIELD_WHEN,{||INCLUI})
	
	// cId          Identificador do modelo
	// cOwner       Identificador superior do modelo
	// oModelStruct Objeto com  a estrutura de dados
	// bPre         Code-Block de pré-edição do formulário de edição. Indica se a edição esta liberada
	// bPost        Code-Block de validação do formulário de edição
	// bLoad        Code-Block de carga dos dados do formulário de edição
	oModel:AddFields("GFEA518_GVI", Nil, oStructGVI,,,/*bLoad*/)
	oModel:SetPrimaryKey({"GVI_FILIAL", "GVI_CDOPER", "GVI_SEQ"})        
	
	oModel:AddGrid("GFEA518_GVJ","GFEA518_GVI",oStructGVJ,/**/,{|oMod| GFEA518VLD(oMod)},/*bLinePost*/,/*bPre*/,/**/)
	oModel:SetRelation("GFEA518_GVJ",{{"GVJ_FILIAL",'xFilial("GVJ")'},{"GVJ_CDOPER","GVI_CDOPER"},{"GVJ_SEQ","GVI_SEQ"}}, GVJ->( IndexKey(1) ))
	oModel:GetModel("GFEA518_GVJ"):SetDelAllLine(.T.)  

	oModel:SetActivate({|oMod| GFEA518ACT(oMod)})
Return oModel

//-------------------------------------------------------------------
Static Function ViewDef()
	Local oModel := FWLoadModel("GFEA518")
	Local oView  := Nil
	Local oStructGVI := FWFormStruct(2,"GVI")
	Local oStructGVJ := FWFormStruct(2,"GVJ")
	
	oStructGVJ:RemoveField( "GVJ_FILIAL" )
	oStructGVJ:RemoveField( "GVJ_CDOPER" )	    
	oStructGVJ:RemoveField( "GVJ_SEQ"    )	    

	oView := FWFormView():New()
	// Objeto do model a se associar a view.
	oView:SetModel(oModel)
	// cFormModelID - Representa o ID criado no Model que essa FormField irá representar
	// oStruct - Objeto do model a se associar a view.
	// cLinkID - Representa o ID criado no Model ,Só é necessári o caso estamos mundando o ID no View.
	oView:AddField( "GFEA518_GVI" , oStructGVI )	
	oView:AddGrid(  "GFEA518_GVJ" , oStructGVJ )
	
	oView:AddIncrementField("GFEA518_GVJ","GVJ_ORDEM")
	
	// cID		  	Id do Box a ser utilizado 
	// nPercHeight  Valor da Altura do box( caso o lFixPixel seja .T. é a qtd de pixel exato)
	// cIdOwner 	Id do Box Vertical pai. Podemos fazer diversas criações uma dentro da outra.
	// lFixPixel	Determina que o valor passado no nPercHeight é na verdade a qtd de pixel a ser usada.
	// cIDFolder	Id da folder onde queremos criar o o box se passado esse valor, é necessário informar o cIDSheet
	// cIDSheet     Id da Sheet(Folha de dados) onde queremos criar o o box.
	oView:CreateHorizontalBox( "MASTER" , 50, /*cIDOwner*/, /*lFixPixel*/, /*cIDFolder*/,/*cIDSheet*/ ) 
	oView:CreateHorizontalBox( "DETAIL" , 50 )

	oView:CreateFolder("IDFOLDER","DETAIL")
	oView:AddSheet("IDFOLDER","IDSHEET01",STR0009) //"Pontos de Controle"
	
	oView:CreateHorizontalBox( "DETAILPC"  , 100,,,"IDFOLDER","IDSHEET01" )
	// Associa um View a um box
	oView:SetOwnerView( "GFEA518_GVI" , "MASTER" ) 
	oView:SetOwnerView( "GFEA518_GVJ" , "DETAILPC" )    
			
Return oView                                                            

Function GFEA518PRE()
Local aAreaGVI := GVI->( GetArea() )   
Local cRetorno := 0
	
	dbSelectArea("GVI")
	dbSetOrder(1)
	dbSeek(xFilial("GVI")+FwFldGet("GVI_CDOPER"))
	While !Eof() .And. xFilial("GVI") == GVI->GVI_FILIAL .And. GVI->GVI_CDOPER == FwFldGet("GVI_CDOPER")
		cRetorno := VAL(GVI->GVI_SEQ)					
		dbSelectArea("GVI")
		dbSkip()
	EndDo                      
	                      
	If cRetorno == 0
		cRetorno := 1
	Else             
		cRetorno += 1
	Endif            
	
	cRetorno := STRZERO(cRetorno,3)
		
	RestArea(aAreaGVI)
Return cRetorno       

Function GFEA518OPC(nOpc)
Local aAreaGVI := GVI->( GetArea() )
Local aAreaGX3 := GX3->( GetArea() )      
	dbSelectArea("GX3")
	dbSetOrder(2)
	If dbSeek(xFilial("GX3")+GVI->GVI_CDOPER+GVI->GVI_SEQ)         
		If nOpc == 4
			Help( ,, 'HELP',, STR0010, 1, 0) //"Operação já está vinculada a um movimento, a mesma não pode ser alterada."
			Return .F. 	
		ElseIf nOpc == 5
			Help( ,, 'HELP',, STR0011, 1, 0) //"Operação já está vinculada a um movimento, a mesma não pode ser excluída."
			Return .F. 	
		Endif		
	Else
		If nOpc == 4
			FWExecView(STR0012,'GFEA518',4,,{||.T.}) //"Alteração"
		ElseIf nOpc == 5 //"Exclusão"
			If APMSGYESNO("Deseja realmente excluir esta operação?")
						
				GVJ->( dbSetOrder(1) )
				GVJ->( dbSeek(xFilial("GVJ") + GVI->GVI_CDOPER + GVI->GVI_SEQ) )
				While !GVJ->( Eof() ) .And. GVJ->GVJ_FILIAL == xFilial("GVJ") .And. GVJ->GVJ_CDOPER == GVI->GVI_CDOPER .And. GVJ->GVJ_SEQ == GVI->GVI_SEQ 
					RecLock( "GVJ", .F. )
					dbDelete()
					GVJ->( MsUnLock() )
									
					GVJ->( dbSkip() )
				EndDo
					
				RecLock( "GVI", .F. )
				dbDelete()
				GVI->( MsUnLock() )
					
				MsgInfo( "Exclusão realizada com sucesso.", "Exclusão de Operação" )
									
			EndIf		
		Endif
	Endif  
	RestArea(aAreaGX3)
	RestArea(aAreaGVI)
Return .T.  

/*---------------------------------------------------------------------------------------------------
{Protheus.doc} GFEA518VLD
Função de validação para não permitir informar registros iguais de ponto de controle.

@sample
GFEA518VLD(oMod)

@author Octávio Augusto Felippe de Macedo
@since 02/02/2011
@version 1.0
----------------------------------------------------------------------------------------------------*/

Function GFEA518VLD(oModelGVJ)
Local nLine := oModelGVJ:GetLine()
Local nI
                             

	
If nLine == 1 .And. !oModelGVJ:IsDeleted() .And. (FwFldGet("GVJ_REPROV" ,nLine) == "1") .And. (FwFldGet("GVJ_REPOCO" ,nLine) == "2") .and. !lcopy
	Help( ,, 'HELP',, "Somente a partir do segundo Ponto de Controle pode-se retornar ao Ponto de Controle anterior. ", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Alterar a opção Reprov Oco para 1-Cancelar Movimentação"})
	oModelGVJ:GoLine( nLine )
	Return .F. 		
EndIf 

	
If nLine == 1 .And. !oModelGVJ:IsDeleted() .And. (FwFldGet("GVJ_REPROV" ,nLine) == "6") .and. !lCopy
	Help( ,, 'HELP',, "Somente a partir do segundo Ponto de Controle pode-se retornar ao Ponto de Controle anterior. ", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Alterar a opção de Ação Reprov. do primeiro Ponto de controle."})
	oModelGVJ:GoLine( nLine )
	Return .F. 		
EndIf 

For nI := 1 To oModelGVJ:Length()
	oModelGVJ:GoLine(nI)
	If nI != nLine  .And. !oModelGVJ:IsDeleted() .And. FwFldGet("GVJ_CDPTCT",nLine) == FwFldGet("GVJ_CDPTCT",nI) .And. ;
	   FwFldGet("GVJ_ORDEM",nLine) == FwFldGet("GVJ_ORDEM",nI)		
		Help( ,, 'HELP',, STR0014+AllTrim(Str(nI))+" .", 1, 0) //"O ponto de controle já foi informado com a mesma ordem na linha "
		oModelGVJ:GoLine( nLine )
		Return .F. 		
	EndIf 
Next nI

oModelGVJ:GoLine( nLine )

GVC->(dbSetOrder(01))
GVC->(dbSeek(xFilial("GVC")+FwFldGet("GVI_CDOPER")))
	If GVC->GVC_VINCPC != "1"
		Help( ,, 'HELP',, " O campo Vincula PC do cadastro de Operações está como 'Não', não poderá haver pontos de controle vinculados à operação.", 1, 0)
		Return .F.
	EndIf

Return .T. 

/*---------------------------------------------------------------------------------------------------
{Protheus.doc} GFEA518ACT
Função chamada ao ativar o model

@sample
GFEA518ACT(oModel)

@author Octávio Augusto Felippe de Macedo
@since 30/03/2011
@version 1.0
----------------------------------------------------------------------------------------------------*/
                                                                                                       
Function GFEA518ACT(oModel)
Local nI
Local lFirst     := .T.
Local oModelGVI  := oModel:GetModel("GFEA518_GVI")
Local aFieldsGVI := oModelGVI:GetStruct():aFields
Local oModelGVJ  := oModel:GetModel("GFEA518_GVJ")
Local aFieldsGVJ := oModelGVJ:GetStruct():aFields
Local cNextSeq	:= "" 
Local lIdcoag := .F. 


	If IsInCallStack("GFEA518") .And. lCopy 

		For nI := 1 To Len(aFieldsGVI) 
			If aFieldsGVI[nI][3] == "GVI_IDCOAG" .And. &("GVI->"+aFieldsGVI[nI][3]) = '2' 
				lIdcoag := .T. 
			EndIf 
			
			If aFieldsGVI[nI][14] .Or. (lIdCoag .And. (aFieldsGVI[nI][3] == "GVI_QTHRNE" .Or. aFieldsGVI[nI][3] == "GVI_QTHRPO")) 
				Loop 
			ElseIf aFieldsGVI[nI][3] == "GVI_SEQ" 
				oModelGVI:SetValue(aFieldsGVI[nI][3], cNextSeq := GFEA518PRE()) 
			Else 
				oModelGVI:SetValue(aFieldsGVI[nI][3], &("GVI->"+aFieldsGVI[nI][3])) 
			EndIf 
		Next nI 
	
		dbSelectArea("GVJ")
		GVJ->( dbSetOrder(1) )
		GVJ->( dbSeek(xFilial("GVJ") + GVI->GVI_CDOPER + GVI->GVI_SEQ) )
		While !GVJ->( Eof() ) .And. GVJ->GVJ_FILIAL == xFilial("GVJ") .And. GVJ->GVJ_CDOPER == GVI->GVI_CDOPER .And. GVJ->GVJ_SEQ == GVI->GVI_SEQ 
			
			If lFirst
				lFirst := .F.
				oModelGVJ:GoLine(1)
			Else
				oModelGVJ:AddLine()
			EndIf		
			
			For nI := 1 To Len(aFieldsGVJ)
				If !aFieldsGVJ[nI][14]
					If aFieldsGVJ[nI][3] == "GVJ_SEQ"
						oModelGVJ:SetValue(aFieldsGVJ[nI][3], cNextSeq)
					ElseIf !Empty(&("GVJ->"+aFieldsGVJ[nI][3]))
						oModelGVJ:SetValue(aFieldsGVJ[nI][3], &("GVJ->"+aFieldsGVJ[nI][3]))
					EndIf
				EndIf
			Next nI
	
			dbSelectArea("GVJ")
			GVJ->( dbSkip() )
		EndDo		
		lCopy := .F.
	
	EndIf

Return

/*---------------------------------------------------------------------------------------------------
{Protheus.doc} GFEA518COP
Função que executa a viwe em forma de inserção para a cópia

@sample
GFEA518COP()

@author Octávio Augusto Felippe de Macedo
@since 30/03/2011
@version 1.0
----------------------------------------------------------------------------------------------------*/

Function GFEA518COP() 
	
	lCopy := .T.
	
	FWExecView(STR0015,"GFEA518",3,,{|| .T.}) //"Cópia"
	
Return .T. 


//---------------------------------

Static Function GFEA518POS(oModel)
Local oModelGVJ := oModel:GetModel("GFEA518_GVJ")
Local nLine     := oModelGVJ:GetLine()
Local nLen      := oModelGVJ:Length()
Local aOrd
Local nPos
Local aOp       := {}
Local nCont     := 1
Local nVlLn     := 0

If Val(oModelGVJ:GetValue("GVJ_ORDEM")) == 1
	If (FwFldGet("GVJ_REPROV" ,1) == "1" .And. FwFldGet("GVJ_REPOCO" ,1) == "2") .or. (oModelGVJ:GetValue("GVJ_REPROV") == "1" .and. oModelGVJ:GetValue("GVJ_REPOCO")== "2")
		Help( ,, 'HELP',, "Somente a partir do segundo Ponto de Controle pode-se retornar ao Ponto de Controle anterior. ", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Alterar a opção Reprov Oco para 1-Cancelar Movimentação"})
		oModelGVJ:GoLine( nLine )
		Return .F. 		
	EndIf 
			
				
	If FwFldGet("GVJ_REPROV" ,1) == "6" .or. oModelGVJ:GetValue("GVJ_REPROV") == "6" 
		Help( ,, 'HELP',, "Somente a partir do segundo Ponto de Controle pode-se retornar ao Ponto de nCont anterior. ", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Alterar a opção de Ação Reprov. do primeiro Ponto de controle."})
		oModelGVJ:GoLine( nLine )
		Return .F. 		
	EndIf
EndIf


If nLen > 0
	
	For nCont := 1 To nLen
		oModelGVJ:GoLine(nCont)
		
		If !oModelGVJ:IsDeleted()
			nVlLn++
			
			If (nPos := AScan(aOp, {|x| x[1] == oModelGVJ:GetValue("GVJ_CDPTCT")})) == 0
				AAdd(aOp, {oModelGVJ:GetValue("GVJ_CDPTCT"),oModelGVJ:GetValue("GVJ_IDACES")})
			ElseIf aOp[nPos][2] != oModelGVJ:GetValue("GVJ_IDACES")
				Help( ,, 'HELP',, STR0018 + AllTrim(aOp[nPos][1]) + STR0019, 1, 0) //"O campo 'Acesso PC' dos Pontos de Controle '" ### "' devem ser iguais."
				oModelGVJ:GoLine(nLine)
				Return .F.	
			EndIf
		EndIf
	Next nCont
	
	nCont := 1
	
	aOrd := Array(nVlLn)
	
	AEval(aOrd,{|x| aOrd[nCont] := nCont,nCont++})
	
	For nCont := 1 To nLen
		oModelGVJ:GoLine(nCont)
		
		If !oModelGVJ:IsDeleted()
			If AScan(aOrd,{|x| x == Val(oModelGVJ:GetValue("GVJ_ORDEM"))}) == 0
				Help( ,, 'HELP',, STR0016 + oModelGVJ:GetValue("GVJ_ORDEM") + STR0017, 1, 0) //"Há inconsistência na sequência dos Pontos de Controle. A ordem '" ### "' está fora da sequência. "
				oModelGVJ:GoLine(nLine)
				Return .F.				
			EndIf
		EndIf
	
	Next nCont
	
	oModelGVJ:GoLine(nLine)
	
		
EndIf

Return .T.

//---------------------------------------------------------------

Function GFEA518ORD()
	Local oView     := FWViewActive()
	Local oModel    := FWModelActive()
	Local oModelGVJ := oModel:GetModel("GFEA518_GVJ")
	Local cOrder    := FwFldGet("GVJ_ORDEM")
	
	If Len(AllTrim(cOrder)) != 3 .And. !Empty(cOrder)
	
		oModelGVJ:SetValue("GVJ_ORDEM",PadL(AllTrim(cOrder),3,"0"))
	
	EndIf
	
	If IsInCallStack("GFEA518") .And. !lCopy
		oView:Refresh("GFEA518_GVJ")
	Endif
	
Return .T.


Function GFEA518WHEN()
	Local oModel
	Local oModelGVJ
	Local nLine
	
	if lCopy
		Return .T.
	EndIf
	
	oModel := FwModelActive()
	oModelGVJ := oModel:GetModel('GFEA518_GVJ')
	nLine := oModelGVJ:GetLine()
	
Return (FwFldGet("GVJ_REPROV" ,nLine) == "1")

Function GFEA518BSI()
	Local cTexto := ""
	Local oTMultiget
	Local cAux := ""
	
	If GFXCP12117("GVI_INSTRU") 
		cTexto := Posicione("GVI",1,xFilial("GVI")+GVI->GVI_CDOPER + GVI->GVI_SEQ,"GVI_INSTRU")
		cAux := StrTran(cTexto, Chr(13)+Chr(10), "")
		If AllTrim(cAux) <> ""		
			DEFINE DIALOG oDlg TITLE "Instruções" FROM 180, 110 TO 400, 628 PIXEL
			oTMultiget := tMultiget():new( 01, 01, {| u | if( pCount() > 0, cTexto := u, cTexto ) }, oDlg, 260, 92, , , , , , .T. ,,,,,,.T.,,,,,.T.)  	
			DEFINE SBUTTON oSBtnEnd FROM 95, 01 TYPE 01 OF oDlg ENABLE ACTION oDlg:End()
			ACTIVATE DIALOG oDlg CENTERED
		Else
			MsgAlert("Não há instruções cadastradas para esta Configuração da Operação.","Aviso")
		EndIf
	EndIf
Return
