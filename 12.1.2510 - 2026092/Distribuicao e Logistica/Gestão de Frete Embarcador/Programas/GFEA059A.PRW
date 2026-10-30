#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA059A
Comentários da Requisição

@author João Leonardo Schmidt
@since 02/04/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFEA059A()
	Local oBrowse

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("GXW")
	oBrowse:SetMenuDef("GFEA059A")
	oBrowse:SetDescription("Comentários da Requisição")
	
	oBrowse:AddLegend("GXW_PAPEL=='1'", "BLUE"  , "Requisitante") 
	oBrowse:AddLegend("GXW_PAPEL=='2'", "YELLOW", "Negociador")   
	
	// Cria o filtro para o programa exibir apenas os comentários da requisição posicionada
	oBrowse:SetFilterDefault("@ GXW_IDREQ = '" + GXR->GXR_IDREQ + "'") 
		
	oBrowse:Activate()
Return(Nil)

Static Function MenuDef()
	Local aRotina := {}
	
	AAdd(aRotina, {"Pesquisar"  , 'AxPesqui'       	, 0, 1  , 0, .T. /*Habilita Menu Funcional*/})
	AAdd(aRotina, {"Visualizar" , "VIEWDEF.GFEA059A" , 0, 2  , 0, .T. /*Habilita Menu Funcional*/})
	AAdd(aRotina, {"Incluir"    , "VIEWDEF.GFEA059A" , 0, 3  , 0, .F. /*Habilita Menu Funcional*/})
	AAdd(aRotina, {"Imprimir"   , "VIEWDEF.GFEA059A" , 0, 8  , 0, .T. /*Habilita Menu Funcional*/})
    
Return aRotina

Static Function ModelDef()
	Local oModel

	oModel := MPFormModel():New("GFEA059A", /*bPre*/, {|oMod| GFE059APVL(oMod)} ,/**/, /**/, /*bCancel*/)
	oModel:AddFields("GFEA059A_GXW", Nil, FWFormStruct(1,"GXW"),/*bPre*/,/*bPost*/,/*bLoad*/)
	oModel:SetPrimaryKey({"GXW_FILIAL", "GXW_IDREQ", "GXW_SEQ"})
	oModel:SetDescription("Comentários da Requisição")
	
	oModel:SetActivate( {|oMod| GFEA059ComACT(oMod)} )
Return oModel

Static Function ViewDef()
	Local oModel  	 := FWLoadModel("GFEA059A")
	Local oStruct 	 := FWFormStruct(2,"GXW")
	Local oView   	 := Nil
	
	oView := FWFormView():New()
	
	oView:SetModel(oModel)
	oView:AddField("GFEA059A_GXW", oStruct, /*cLinkID*/ )
	
	oStruct:RemoveField("GXW_RESCOM")	
Return oView

Function GFE059APVL(oModel)	
	GFE059ARES(oModel)
Return .T.

//Função responsavel por gravar o resumo do comentário.
Function GFE059ARES(oModel)
	Local nOp    := oModel:GetOperation()
	Local cResum := ""
	 
	If nOp == MODEL_OPERATION_INSERT .OR. nOp == MODEL_OPERATION_UPDATE// Se for inclusao ou alteração
		cResum := SUBSTR(oModel:GetValue('GFEA059A_GXW','GXW_COMENT'),1,47) + "..." 
		oModel:SetValue('GFEA059A_GXW','GXW_RESCOM',cResum)
		Return 
	EndIf
Return  

Function GFEA059ComACT(oModel)
	Local nOp  := oModel:GetOperation()
	Local aSeq := GFEA59AProxSeqComent() 
	
	If aSeq[1] == .T.	
		If nOp == MODEL_OPERATION_INSERT 
			oModel:SetValue("GFEA059A_GXW", "GXW_IDREQ", GXR->GXR_IDREQ)
			oModel:SetValue("GFEA059A_GXW", "GXW_SEQ"  , aSeq[2])
		EndIf
	Else
		GFEHelp("Ocorreu Erro para encontrar próxima sequência!")
	EndIf	
Return

Static Function GFEA59AProxSeqComent()
	Local cQuery   := ""
	Local nNum	   := 0
	Local cAlQuery
	
	cQuery := "SELECT MAX(GXW_SEQ) AS MAXSEQ FROM " + RetSqlName("GXW") + " GXW "
	cQuery += " WHERE GXW.GXW_FILIAL = '" + xFilial("GXW") + "' AND GXW.GXW_IDREQ = '" + GXR->GXR_IDREQ + "'"
	cQuery += " AND GXW.D_E_L_E_T_ = ' '"
	
	cAlQuery := MpSysOpenQuery(ChangeQuery(cQuery))
	
	If !((cAlQuery)->(Eof()))
		nNum := Val((cAlQuery)->MAXSEQ) + 1  
		
		Return {.T.,PADL(nNum,TamSX3("GXW_SEQ")[1],"0")}
	Else
		Return {.T.,PADL("1",TamSX3("GXW_SEQ")[1],"0")}
	EndIf
Return {.F.,""}

Function GFE059ACOM(cPapel)
	Local oModel := FwLoadModel("GFEA059A")	
	Local oGFEComment := GFEComment():New()
	Local oModelGXW := oModel:GetModel("GFEA059A_GXW")
	oModel:SetOperation(MODEL_OPERATION_INSERT)
	oModel:Activate()
	
	oGFEComment:setTitleWindow("Comentário")
	oGFEComment:setTitleMemo("Digite um comentário para a requisição: " + GXR->GXR_IDREQ)
	oGFEComment:setBtnConfirm("Confirmar")
	oGFEComment:setBtnCancel("Cancelar")
	oGFEComment:createWindow()
	
	If !oGFEComment:getStatus()
		Return		
	Else
		If AllTrim(oGFEComment:getText()) != ""
			oModelGXW:SetValue("GXW_PAPEL",cPapel)
			oModelGXW:SetValue("GXW_COMENT",oGFEComment:getText())
			If oModel:VldData()
				oModel:CommitData()
			EndIf
		Else
			GFEHelp("É necessário que exista conteúdo no comentário para realizar esta ação!")
			GFE059ACOM()
		EndIf
	EndIf
	oGFEComment:destroy(oGFEComment)
	oModel:DeActivate()
Return