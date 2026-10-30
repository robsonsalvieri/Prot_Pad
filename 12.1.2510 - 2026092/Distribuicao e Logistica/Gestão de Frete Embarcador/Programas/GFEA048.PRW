#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GFEA048.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA048

Cadastro Filtro Documento de Carga

@author Felipe Rafael Mendes
@since 27/10/09
@version 1.0
/*/
//-------------------------------------------------------------------

Function GFEA048()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetAlias("GUJ")					// Alias da tabela utilizada
oBrowse:SetMenuDef("GFEA048")			    // Nome do fonte onde esta a função MenuDef
oBrowse:SetDescription("Configuração de Filtros de Documento de Carga") //"Filtro Documento de Carga"

oBrowse:Activate()                                       

Return(Nil)

//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0011 ACTION "AxPesqui"        OPERATION 1  ACCESS 0 //"Pesquisar"
ADD OPTION aRotina TITLE STR0012 ACTION "VIEWDEF.GFEA048" OPERATION 2  ACCESS 0 //"Visualizar"
ADD OPTION aRotina TITLE STR0013 ACTION "VIEWDEF.GFEA048" OPERATION 3  ACCESS 0 //"Incluir"
ADD OPTION aRotina TITLE STR0014 ACTION "VIEWDEF.GFEA048" OPERATION 4  ACCESS 0 //"Alterar"  
ADD OPTION aRotina TITLE STR0015 ACTION "VIEWDEF.GFEA048" OPERATION 5  ACCESS 0 //"Excluir" 
ADD OPTION aRotina TITLE STR0016 ACTION "VIEWDEF.GFEA048" OPERATION 8  ACCESS 0 //"Imprimir"

Return aRotina

//-------------------------------------------------------------------
Static Function ModelDef()

Local oModel

Local oStructGUJ := FWFormStruct(1,"GUJ")

// cID     Identificador do modelo 
// bPre    Code-Block de pre-edição do formulário de edição. Indica se a edição esta liberada
// bPost   Code-Block de validação do formulário de edição
// bCommit Code-Block de persistência do formulário de edição
// bCancel Code-Block de cancelamento do formulário de edição
oModel := MPFormModel():New("GFEA048", /*bPre*/, {|oMod| GFEA048POS(oMod)}/*bPost*/, /*bCommit*/, /*bCancel*/)
// cId          Identificador do modelo
// cOwner       Identificador superior do modelo
// oModelStruct Objeto com  a estrutura de dados
// bPre         Code-Block de pré-edição do formulário de edição. Indica se a edição esta liberada
// bPost        Code-Block de validação do formulário de edição
// bLoad        Code-Block de carga dos dados do formulário de edição

oStructGUJ:setProperty("GUJ_VALOR",MODEL_FIELD_WHEN,{||GFE048WHEN()})

oModel:AddFields("GFEA048_GUJ", Nil, oStructGUJ,/*bPre*/,/*bPost*/,/*bLoad*/)
oModel:SetPrimaryKey({"GUJ_FILIAL", "GUJ_CAMPO"})


Return oModel

//---------------------------------------------------------------------------

Static Function ViewDef()

Local oModel := FWLoadModel("GFEA048")
Local oView  := FWFormView():New()
Local oStructGUJ := FWFormStruct(2,"GUJ")
oView:SetModel(oModel)

oView:AddField( "GFEA048_GUJ" ,oStructGUJ , /*cLinkID*/ ) //

oView:CreateHorizontalBox( "MASTER" , 100,/*cIDOwner*/,/*lFixPixel*/,/*cIDFolder*/,/*cIDSheet*/ )

oView:SetOwnerView( "GFEA048_GUJ" , "MASTER" )    

oView:AddUserButton( 'Montar Expressão', 'MAGIC_BMP', {|oModel| GFE48EXPRE(oModel)} )
oView:SetFieldAction( 'GUJ_TABELA', { || GFEA048ACT()} ) 

Return oView    

/*
{Protheus.doc} GFEF3SX3
Função de cria a consulta específica.

@sample
GFEF3SX3()

@author Octávio Augusto Felippe de Macedo
@since 15/04/2011
@version 1.0
*/

Function GFEF3SX3( cFiltro )
	Local lRet     := .F.
	Local aFill    := {}
	Local aHead    := {STR0017,STR0018,STR0019} //"Campo" ### "Descrição" ### "Tabela"
	Local nNr
	Local nX
	Local aStructSX
	Local oStructX3	:= GFESeekSX():New()
	
	Default cFiltro := AllTrim(FwFldGet("GUJ_TABELA"))
	
	aStructSX	:= FWFormStruct(3,cFiltro)[1] //Todos os Campos
	
	For nX := 1 to Len(aStructSX)
		
		oStructX3:SeekX3(aStructSX[nX,3],.T.,.F.,.F.)
	
		If GetSx3Cache(aStructSX[nX,3],"X3_CONTEXT")  != "V"
			lRet := .T.
			AAdd(aFill, {aStructSX[nX,3], oStructX3:getX3Titulo(), cFiltro})
		EndIf
	Next nX
	oStructX3:Destroy()

	If lRet
		dbSelectArea(cFiltro)
		nNr := TmsF3Array(aHead, aFill, STR0020 + cFiltro + "'") // "Campos da tabela '"
		If nNr > 0
			dbSelectArea("SX3")
			SX3->( dbSetOrder(2) )
			SX3->( dbSeek(aFill[nNr][1]) )		
		Else
			lRet := .F.
		EndIf
	EndIf
	
Return lRet
            
/*
{Protheus.doc} GFEA048FTM
Função de validação do campo, chamada pelo valid.

@sample
GFEA048FTM()

@author Octávio Augusto Felippe de Macedo
@since 15/04/2011
@version 1.0
*/

Function GFEA48VLDT()

If Vazio()
	Help( ,, 'HELP',, STR0021, 1, 0,) //"Nenhuma tabela selecionada."
	Return .F.
EndIf
	
Return .T.

/*
{Protheus.doc} GFEA048FTM
Função de validação do campo, chamada pelo valid.

@sample
GFEA048FTM()

@author Octávio Augusto Felippe de Macedo
@since 15/04/2011
@version 1.0
*/

Function GFEA48VLDC()

	Local cTab := AllTrim(FwFldGet("GUJ_TABELA"))
	Local cCmp := FwFldGet("GUJ_CAMPO")
	Local aStructSX
	Local nX
		
	If Vazio() .Or.  AllTrim(cCmp) == "EXPRESSAO" 
		Return .T.
	EndIf
	
	aStructSX	:= FWFormStruct(3,cTab)[1] //Todos os Campos
	
	For nX := 1 to Len(aStructSX)
		If GetSx3Cache(aStructSX[nX,3],"X3_CONTEXT")  != "V"
			If AllTrim(aStructSX[nX,3]) == AllTrim(cCmp)
				Return .T.
			EndIf
		EndIf
	Next nX

	Help( ,, 'HELP',, STR0023, 1, 0,) //"O campo não pertence a tabela selecionada."
Return .F.
	
/*
{Protheus.doc} GFEA048FTM
Função de formatação do valor informado pelo usuário

@sample
GFEA048FTM()

@author Octávio Augusto Felippe de Macedo
@since 15/04/2011
@version 1.0
*/

Function GFEA048FTM()

	Local oView := FWViewActive()
	Local cTp	:= ""
	Local cCmp := FwFldGet("GUJ_CAMPO")
	Local cVal := FwFldGet("GUJ_VALOR")
	Local cRet := cVal
	Local aDt  := {}
	Local nX
	Local aStructSX
	
	If Empty(cVal) .Or. cCmp == "EXPRESSAO"
		Return .T.	
	EndIf
	
	aStructSX	:= FWFormStruct(3,SubStr(cCmp,1,AT('_',cCmp)-1))[1] //Todos os Campos
	
	For nX := 1 to Len(aStructSX)
		If AllTrim(aStructSX[nX,3]) == AllTrim(cCmp)
			cTp	:= aStructSX[nX,4]
		EndIf
	Next nX

	If cTp == "N"
		
		If Rat(".", cVal) > Rat(",", cVal)
			cRet := StrTran(cVal,",","")
		Else
			cRet := StrTran(cVal,".","")
		EndIf
		
		cRet := AllTrim(Str(GetDtoVal(cRet)))
	
	ElseIf cTp == "D"
	    
	    aDt := StrToKarr(cVal, "/")
	    
	    If Len(aDt) == 1
	    	cVal := SubStr(cVal,1,2)+"/"+SubStr(cVal,3,2)+"/"+SubStr(cVal,5,4)
	    	aDt := StrToKarr(cVal, "/")
	    EndIf
	    
		If Len(aDt) != 3 .Or. Empty(CToD(AllTrim(cVal)))
			Help( ,, 'HELP',, STR0024, 1, 0,) //"A data é inválida."
			Return .F.
		EndIf
			
		If Len(AllTrim(Str(GetDtoVal(cVal)))) != If(Val(aDt[1]) < 10, 7, 8)
			Help( ,, 'HELP',, STR0024, 1, 0,) //"A data é inválida."
			Return .F.
		EndIf
		
		cRet := AllTrim(cVal)
	
	EndIf
	
	If !IsBlind()
		oView:oModel:GetModel("GFEA048_GUJ"):SetValue("GUJ_VALOR", cRet)
		oView:Refresh()
	EndIf

Return .T.

/*
{Protheus.doc} GFEA048POS
Função de validação do model após a confirmação

@sample
GFEA048POS()

@author Octávio Augusto Felippe de Macedo
@since 15/04/2011
@version 1.0
*/

Function GFEA048POS(oModel)

Local cTab := AllTrim(FwFldGet("GUJ_TABELA"))
Local cCmp := FwFldGet("GUJ_CAMPO")
Local cValor := AllTrim(FwFldGet("GUJ_VALOR"))
Private lErroFiltro := .F.

If !ExistChav("GUJ", FwFldGet("GUJ_CAMPO") + FwFldGet("GUJ_VALOR"))
	Help( ,, 'HELP',, "Esse registro já está cadastrado!", 1, 0,)
	Return .F.
EndIf

If !Empty(cCmp) .And. !(cTab+"_" $ cCmp) .And. cCmp != "EXPRESSAO"
	Help( ,, 'HELP',, STR0022, 1, 0,) //"O campo não pertence a tabela selecionada."
	Return .F.
EndIf

If AllTrim(cCmp)=="EXPRESSAO" .And. Empty (cValor)
	Help( ,, 'HELP',, "Campo valor é obrigatório", 1, 0,)
	Return .F.	
EndIf 

//Deve-se declarar lErroFiltro como Private lErroFiltro := .F. e testar como está abaixo
If AllTrim(cCmp)=="EXPRESSAO" .And. (!GFE48VldExp(cValor,cTab) .Or. lErroFiltro)
	Help( ,, 'HELP',, "A expressão é inválida, verifique!", 1, 0,)
	Return .F.
EndIf

Return .T.


/*/{Protheus.doc} GFE48EXPRE
	
@author siegklenes.beulke
@since 03/09/2013
@version 1.0

@description

Abre tela que monta a expressão advpl que servirá para validação

@example

GFE48EXPRE(oModel)

/*/


Static Function GFE48EXPRE(oMod)
	Local oModel := FWModelActive()
	Local oView := FWViewActive()
	Local cExpres := ""

	If oModel:GetOperation() == 1
		Help( ,, 'HELP',, "Opção disponivel somente para operações de Inclusão/Alteração", 1, 0,)
		Return .F.
	EndIf
	
	If Empty(oModel:GetValue("GFEA048_GUJ","GUJ_TABELA"))
		Help( ,, 'HELP',, STR0021, 1, 0,) //"Nenhuma tabela selecionada."
		Return .F.
	EndIf
	
	cExpres := BuildExpr (AllTrim(oModel:GetValue("GFEA048_GUJ","GUJ_TABELA")),,;
					IIf(AllTrim(oModel:GetValue("GFEA048_GUJ","GUJ_CAMPO"))=="EXPRESSAO",AllTrim(oModel:GetValue("GFEA048_GUJ","GUJ_VALOR")),"")	,,,,,,,,,,.F.,)
	
	If Len(cExpres) > TamSX3("GUJ_VALOR")[1]
		Help( ,, 'HELP',, "O tamanho da expressão (" + cValToChar(Len(cExpres)) + ") é maior do que o sistema comporta (" + cValTochar(TamSX3("GUJ_VALOR")[1]) + ")", 1, 0,)
		Return .F. 
	EndIf
			
	oModel:SetValue("GFEA048_GUJ","GUJ_CAMPO","EXPRESSAO")
	oModel:LoadValue("GFEA048_GUJ","GUJ_VALOR",cExpres)
	
	oMod:LMODIFY:=.T.
	oView:Refresh()
Return .T.

/*/{Protheus.doc} GFEA048ACT
	
@author siegklenes.beulke
@since 03/09/2013
@version 1.0

@description

Realiza a limpeza do campo expressão quando a tabela for substituida

@example

GFEA048ACT()

/*/

Static Function GFEA048ACT()	
	Local oModel := FWModelActive()
	Local oView := FWViewActive()
	oModel:LoadValue("GFEA048_GUJ","GUJ_CAMPO","")
	oModel:LoadValue("GFEA048_GUJ","GUJ_VALOR","")
	oView:Refresh()
	
Return .T.

/*/{Protheus.doc} GFE048WHEN
	
@author siegklenes.beulke
@since 03/09/2013
@version 1.0

@description

Se o campo Campo for "EXPRESSAO", bloqueia edição do campo Valor pelo usuário

@example

GFE048WHEN()

/*/
Function GFE048WHEN() 
	Local oModel := FWModelActive()
	
	If AllTrim(oModel:GetValue("GFEA048_GUJ","GUJ_CAMPO"))=="EXPRESSAO"
		Return .F.
	Else
		Return .T.
	EndIf
Return .F.

Function GFE48VldExp(cExpr,cAlias)
Local lRet    := .f. 
Local cRet    := ""
Local aExpr   := {}
Local nI      := 0
Local cFiltro := ""
Local oErro := ErrorBlock({|e| FilterErro(e)})
       
dbSelectArea(cAlias)
If ( ! Empty(cExpr) ) 
       /*/
       #ifdef TOP                                     // Limpando o dToS(
       While (nAt := AT("dToS(",cExpr)) > 0
             cExpr := Subs(cExpr,1,nAT-1)+Subs(cExpr,nAt+5)
             For ni:= nAT to Len(cExpr)
                    If Subs(cExpr,ni,1) == ")"
                           cExpr := Subs(cExpr,1,ni-1)+Subs(cExpr,ni+1)
                           Exit
                    EndIf
             Next
       End
       #endif
       /*/
       BEGIN SEQUENCE                                                                                             
             If ".AND." $ cExpr .Or. ".OR." $ cExpr
                    cFiltro := cExpr
                    cFiltro := StrTran(cFiltro,".AND.",chr(255)+"AND"+chr(255))
                    cFiltro := StrTran(cFiltro,".OR.",chr(255)+"OR"+chr(255))
                    aExpr   := StrtokArr(cFiltro,chr(255))                
                    cFiltro := ""
                    For nI := 1 to len(aExpr)      
                           IF aExpr[nI] == "AND" .Or. aExpr[nI] == "OR" 
                                  cFiltro += " ."
                           EndIf
                           cFiltro += aExpr[ni]                          
                           IF aExpr[nI] == "AND" .Or. aExpr[nI] == "OR" 
                                  cFiltro += ". " 
                           Else                    
                                  If !( RAt("(",cFiltro) > RAt(")",cFiltro) ) .And. ;
                                        ((! "(" $ aExpr[ni] .And. ! "(" $ cFiltro ) .Or. ;
                                        ( (Len(aExpr[ni])-Len(STRTRAN(aExpr[ni],"(",""))) == (Len(aExpr[ni])-Len(STRTRAN(aExpr[ni],")",""))) ))
                                        If ".AND." $ Substr(cFiltro, 1, 6) .Or. ".OR." $ Substr(cFiltro, 1, 6) 
                                               cFiltro := Alltrim(Subs(cFiltro, 7))
                                        EndIf
                                        cRet := &(cFiltro)                                                              
                                  EndIf
                           EndIf
                    Next                     
                    If !Empty(cFiltro)
                           cRet := &(cfiltro)                
                    Endif
                    lRet := .T.                
             Else   
             		lRet := (&(cExpr)) == NIL
                    If lRet == NIL // é advpl, mas nao é expressao valida
                    	lRet := .F.
                    ElseIf lRet == .T.
                    	lRet := .F. // não é advpl
                    Else
                    	lRet:= .T.
                    EndIf
             EndIf
       END SEQUENCE
Else
       lRet := .t.
EndIf
ErrorBlock(oErro)

Return lRet
Static Function FilterErro(e)
	lErroFiltro := .T.	
Return