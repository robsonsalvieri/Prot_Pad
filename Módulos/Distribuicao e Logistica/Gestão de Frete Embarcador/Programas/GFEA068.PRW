#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GFEA068.CH"

/*
{Protheus.doc} GFEA068
Tabela de taxa Suframa

@sample
GFEA068()

@author Octávio Augusto Felippe de Macedo
@since 23/11/2010
@version 1.0
*/

Function GFEA068()

Local oBrowse

//GVN->Tabela Suframa
//GVO->Faixas da tabela suframa
oBrowse := FWMBrowse():New()
oBrowse:SetAlias("GVN")
oBrowse:SetMenuDef("GFEA068")
oBrowse:SetDescription("Configuração de Tabela Suframa")
oBrowse:Activate()

Return Nil

//-----------------------------

Static Function MenuDef()  

Local aRotina := {}

ADD OPTION aRotina TITLE STR0002 ACTION "AxPesqui"        OPERATION 1 ACCESS 0 //"Pesquisar" 
ADD OPTION aRotina TITLE STR0003 ACTION "VIEWDEF.GFEA068" OPERATION 2 ACCESS 0 //"Visualizar" 
ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.GFEA068" OPERATION 3 ACCESS 0 //"Incluir" 
ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.GFEA068" OPERATION 4 ACCESS 0 //"Alterar" 
ADD OPTION aRotina TITLE STR0006 ACTION "VIEWDEF.GFEA068" OPERATION 5 ACCESS 0 //"Excluir" 
ADD OPTION aRotina TITLE STR0007 ACTION "VIEWDEF.GFEA068" OPERATION 9 ACCESS 0 //"Copiar" 
ADD OPTION aRotina TITLE STR0008 ACTION "VIEWDEF.GFEA068" OPERATION 8 ACCESS 0 //"Imprimir" 

Return aRotina  

//-----------------------------

Static Function ModelDef()

Local oModel   
Local oModelGVO

//estanciamento do objeto do model, validação com a função GFEA068POS()
oModel := MPFormModel():New("GFEA068",,{|oMod| GFEA068POS(oMod)},,)

//Adicionado formulário da tabela suframa
oModel:AddFields("GFEA068_GVN", Nil, FWFormStruct(1,"GVN"),,,)
oModel:SetPrimaryKey({"GVN_FILIAL", "GVN_TABSUF"}) 

//Adicionado grid da tabela de faixas
oModel:AddGrid("GFEA068_GVO","GFEA068_GVN", FWFormStruct(1,"GVO"),,{|oMod| GFA68GVOPS(oMod)},,,,)
oModel:SetRelation("GFEA068_GVO",{{"GVO_FILIAL","xFilial('GVO')"},{"GVO_TABSUF","GVN_TABSUF"}/*,{"GVO_INIVIG","GVN_INIVIG"}*/},"GVO_FILIAL+GVO_TABSUF+GVO_SEQ")

oModelGVO = oModel:GetModel("GFEA068_GVO")
oModelGVO:SetDescription("GVO")

Return oModel       

//-----------------------------

Static Function ViewDef() 

Local oModel := FWLoadModel("GFEA068")
Local oView  := Nil
Local oStructGVO := FWFormStruct(2,"GVO")   

oView := FWFormView():New()
oView:SetModel(oModel)

oView:AddField("GFEA068_GVN", FWFormStruct(2,"GVN"))
 	
oView:AddGrid("GFEA068_GVO", oStructGVO)
//Removido campo do código da tabela suframa do grid
oStructGVO:RemoveField("GVO_TABSUF")                
//Campo da sequência de faixas é incrementado automaticamente.
oView:AddIncrementField("GFEA068_GVO","GVO_SEQ")

oView:CreateHorizontalBox("MASTER", 50, /*cIDOwner*/, /*lFixPixel*/, /*cIDFolder*/, /*cIDSheet*/ )
oView:CreateHorizontalBox("DETAIL", 50, /*cIDOwner*/, /*lFixPixel*/, /*cIDFolder*/, /*cIDSheet*/ )

oView:CreateFolder("IDFOLDER","DETAIL")
oView:AddSheet("IDFOLDER","IDSHEET01",STR0009) //Faixas

oView:CreateHorizontalBox( "DETAIL_GVO", 100,,,"IDFOLDER","IDSHEET01" )

oView:SetOwnerView("GFEA068_GVN" , "MASTER" )
oView:SetOwnerView("GFEA068_GVO" , "DETAIL_GVO" )
	
Return oView                   

//----------------------------- 

/*
{Protheus.doc} GFEA068
Função para validação dos valores das faixas da tabela suframa.

@sample GFA68GVOPS(oModel)
@author Octávio Augusto Felippe de Macedo
@since 23/11/2010
@version 1.0
*/ 

Static Function GFA68GVOPS(oModel)
//Local lRet  := .T. 
Local nLine := oModel:GetLine()   
Local nI   

If (FwFldGet("GVO_VALINI") > FwFldGet("GVO_VALFIN"))
	Help( ,, 'HELP',, STR0013, 1, 0,)
	Return .F.		
EndIf

For nI := 1 To oModel:GetQtdLine()
	If nI != nLine    
		oModel:GoLine( nI )
		If !oModel:IsDeleted() 
			If (FwFldGet("GVO_VALINI", nLine) >= FwFldGet("GVO_VALINI", nI) .And. FwFldGet("GVO_VALINI", nLine) <= FwFldGet("GVO_VALFIN", nI)) .Or. ;
			   (FwFldGet("GVO_VALFIN", nLine) >= FwFldGet("GVO_VALINI", nI) .And. FwFldGet("GVO_VALFIN", nLine) <= FwFldGet("GVO_VALFIN", nI)) .Or. ;
			   (FwFldGet("GVO_VALINI", nLine) <= FwFldGet("GVO_VALINI", nI) .And. FwFldGet("GVO_VALFIN", nLine) >= FwFldGet("GVO_VALINI", nI)) .Or. ;
			   (FwFldGet("GVO_VALINI", nLine) <= FwFldGet("GVO_VALFIN", nI) .And. FwFldGet("GVO_VALFIN", nLine) >= FwFldGet("GVO_VALFIN", nI))
			    oModel:GoLine( nLine )
				Help( ,, 'HELP',, (STR0012+AllTrim(Str(nLine))+STR0014), 1, 0,)
				Return .F.
			EndIf
		EndIf
	EndIf		
Next nI

oModel:GoLine( nLine )

Return .T.  

//------------------------------

/*
{Protheus.doc} GFEA068
Função para validação das datas da tabela suframa.

@sample GFEA068POS(oModel)
@author Octávio Augusto Felippe de Macedo
@since 23/11/2010
@version 1.0
*/

Static Function GFEA068POS(oModel)
Local lRet := .T.
Local dDtIni := oModel:GetValue( "GFEA068_GVN", "GVN_INIVIG")
Local dDtFin := oModel:GetValue("GFEA068_GVN", "GVN_FINVIG")
Local nOpc := (oModel:GetOperation())
//filtro para buscar datas que estejam na faixa da data informada.
Local bFiltro := {|| (GVN->GVN_FINVIG >= dDtIni .And. GVN->GVN_FINVIG <= dDtFin) .Or.;
					 ((GVN->GVN_INIVIG <= dDtIni .And. dDtIni <= GVN->GVN_FINVIG) .And. (GVN->GVN_INIVIG <= dDtFin .And. dDtFin <= GVN->GVN_FINVIG)) .Or.;
					 (GVN->GVN_INIVIG >= dDtIni .And. GVN->GVN_INIVIG <= dDtFin)}            

If (nOpc == MODEL_OPERATION_INSERT .Or. nOpc == MODEL_OPERATION_UPDATE ) 

	dbSelectArea("GVN")
	GVN->( dbSetOrder(2) )
	GVN->( dbSeek(xFilial("GVN")+DToS(oModel:GetValue( "GFEA068_GVN", "GVN_INIVIG"))) )
	
	If GVN->( Found() )	
		While !GVN->( Eof() ) .And. GVN->GVN_FILIAL == xFilial("GVN") .And. DToS(GVN->GVN_INIVIG) == DToS(oModel:GetValue( "GFEA068_GVN", "GVN_INIVIG"))
		
			If DToS(GVN->GVN_FINVIG) == DToS(oModel:GetValue( "GFEA068_GVN", "GVN_FINVIG")) .And. GVN->GVN_TABSUF != oModel:GetValue( "GFEA068_GVN", "GVN_TABSUF") 
				Help( ,, 'HELP',, STR0010, 1, 0,)
				lRet := .F.
				Exit   
			EndIf
			
			dbSelectArea("GVN")
			GVN->( dbSkip() )
			
		EndDo
	EndIf
	
	dbSelectArea("GVN")
	GVN->( dbSetOrder(1) )
	GVN->( dbSetFilter(bFiltro,""))
	GVN->( dbGoTop() )
	
	If !GVN->( Eof() ) 
		If GVN->GVN_TABSUF != oModel:GetValue( "GFEA068_GVN", "GVN_TABSUF")		     
			Help( ,, 'HELP',, STR0011, 1, 0,)
			lRet := .F.
		EndIf
	EndIf
	
EndIf

Return lRet

//------------------------------

/*
{Protheus.doc} GFEA068
Função para validar os valores inicial e final das faixas da tabela suframa.

@sample
GFEA068VLF(oModel)

@author Octávio Augusto Felippe de Macedo
@since 23/11/2010
@version 1.0
*/

Function GFEA068VLF()
Local lRet := .T.

If FWFldGet("GVO_VALFIN") <= FWFldGet("GVO_VALINI")
	Help( ,, 'HELP',, STR0013, 1, 0,)	  
	lRet := .F.
EndIf
     
Return lRet
