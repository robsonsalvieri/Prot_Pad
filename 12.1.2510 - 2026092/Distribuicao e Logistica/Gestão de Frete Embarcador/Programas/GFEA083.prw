#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
 
//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA083
Rotina para relacionamento da tabela x contrato 
@author Gabriela Lima
@since 29/11/18
@version 1.0
/*/
//-------------------------------------------------------------------

Function GFEA083()

	Local oBrowse
	
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("GVW")			// Alias da tabela utilizada
	oBrowse:SetMenuDef("GFEA083")	// Nome do fonte onde esta a função MenuDef
	oBrowse:SetDescription("Cadastro Contrato X Tabela de Frete")	// Descrição do browse
	oBrowse:Activate()    

Return(Nil)

//-------------------------------------------------------------------//
//-------------------------Funcao MenuDEF----------------------------//
//-------------------------------------------------------------------//
Static Function MenuDef()

	Local aRotina := {}

	//-------------------------------------------------------
	// Adiciona botões do browse
	//-------------------------------------------------------    
	ADD OPTION aRotina TITLE "Pesquisar"   	ACTION "AxPesqui"        OPERATION 1 ACCESS 0 
	ADD OPTION aRotina TITLE "Visualizar" 	ACTION "VIEWDEF.GFEA083" OPERATION 2 ACCESS 0 
  ADD OPTION aRotina TITLE "Incluir"      ACTION "VIEWDEF.GFEA083" OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE "Excluir"      ACTION "VIEWDEF.GFEA083" OPERATION 5 ACCESS 0 
	ADD OPTION aRotina TITLE "Imprimir"     ACTION "VIEWDEF.GFEA083" OPERATION 8 ACCESS 0 

Return aRotina

//-------------------------------------------------------------------//
//-------------------------Funcao ModelDEF----------------------------//
//-------------------------------------------------------------------//
Static Function ModelDef()

	Local oStruGVW := FWFormStruct( 1, 'GVW' ) // Estrutura da tabela
	Local oModel
		
	oStruGVW:SetProperty("GVW_CDEMIT", MODEL_FIELD_VALID, FwBuildFeature(STRUCT_FEATURE_VALID, 'ExistCpo("GU3", M->GVW_CDEMIT)'))

	oModel := MPFormModel():New("GFEA083", /*bPre*/, { |oX| GFEA083POS( oX ) }, /*{|oModel| GFEA083CMT(oModel)}*/, /*bCancel*/)
	oModel:AddFields("GFEA083_GVW", Nil, oStruGVW)
	oModel:SetPrimaryKey({"GVW_FILIAL", "GVW_CDEMIT", "GVW_NRTAB", "GVW_NRNEG", "GVW_FILGXT", "GVW_NRCT"}) 

Return oModel

//-------------------------------------------------------------------//
//-------------------------Funcao ViewDef----------------------------//                                                  
//-------------------------------------------------------------------//
Static Function ViewDef()

	Local oView   := Nil 
	Local oModel  := FWLoadModel("GFEA083")
	Local oStruct := FWFormStruct(2,"GVW")
	
	// Cria a View
	oView := FWFormView():New()

	// Objeto do model a se associar a view
	oView:SetModel(oModel)

	//Adicionando os campos do cabeçalho
	oView:AddField("GFEA083_GVW", oStruct)	

	//Setando o dimensionamento de tamanho
	oView:CreateHorizontalBox("MASTER", 100)
	
	// Associa um View a um box
	oView:SetOwnerView("GFEA083_GVW", "MASTER")	
	
Return oView

//-------------------------

Function GFEA083POS(oModel)
	Local lRet     := .T.
	local nOpc     := (oModel:GetOperation())
	Local aArea    := GetArea()
	Local aAreaGVW := GVW->(GetArea())	
	
	// Eliminação
	if nOpc == MODEL_OPERATION_DELETE
		
		GXY->(dbSetOrder(1))
		GXY->(dbSeek(GVW->GVW_FILGXT + GVW->GVW_NRCT)) 
		While !Eof() .AND. GXY->GXY_FILIAL == GVW->GVW_FILGXT .AND. GXY->GXY_NRCT == GVW->GVW_NRCT  
	    	Help( ,, 'Help',, "Contrato relacionado ao cálculo " + GXY->GXY_NRCALC, 1, 0 ) //"Já existe registro com chaves informadas"
			lRet := .F.
			Exit
				
			GXY->( dbSkip() )
		EndDo	
		
		GXZ->(dbSetOrder(01))       // seta o indice
		GXZ->(dbSeek(GVW->GVW_FILGXT + GVW->GVW_NRCT)) 
		While !Eof() .AND. GXZ->GXZ_FILIAL == GVW->GVW_FILGXT .AND. GXZ->GXZ_NRCT == GVW->GVW_NRCT  
	    	Help( ,, 'Help',, "Contrato relacionado ao documento de frete " + GXY->GXY_NRDF, 1, 0 ) //"Já existe registro com chaves informadas"
			lRet := .F.
			Exit
				
			GXZ->( dbSkip() )
		EndDo							
		
	Endif	
	
	/* Não permite salvar quando: 
	Tabela ou Negociação não existirem, Negociação com status em Negociação ou Contrato não existir	 */
	If lRet .AND. nOpc == 3 .Or. nOpc == 4
		
	 	//armazena conteudo de campos em variaveis
	 	cChave := FwFldGet("GVW_CDEMIT") 
	 	cChave += FwFldGet("GVW_NRTAB") 
	 	cChave += FwFldGet("GVW_NRNEG") 
	 	cChave += FwFldGet("GVW_FILGXT")
	 	cChave += FwFldGet("GVW_NRCT")
	 	
		GVW->(dbSetOrder(01))       // seta o indice
		GVW->(dbSeek(xFilial('GVW')+cChave)) // posiciona no primeiro registro
		While !Eof() .AND. GVW->GVW_CDEMIT == FwFldGet("GVW_CDEMIT") .AND. GVW->GVW_NRTAB  == FwFldGet("GVW_NRTAB")  .AND. GVW->GVW_NRNEG  == FwFldGet("GVW_NRNEG")  .AND. GVW->GVW_FILGXT  == xFilial('GXT')  .AND. GVW->GVW_NRCT  == FwFldGet("GVW_NRCT")
			If nOpc == MODEL_OPERATION_INSERT .AND. (GVW->GVW_CDEMIT + GVW->GVW_NRTAB + GVW->GVW_NRNEG + GVW->GVW_FILGXT + GVW->GVW_NRCT == cChave)
	    		Help( ,, 'Help',, "Já existe registro com chaves informadas", 1, 0 ) //"Já existe registro com chaves informadas"
				lRet := .F.
				Exit
			EndIf
	
			GVW->( dbSkip(1) )
		EndDo	
		

		GVA->(DbSetOrder(1))
		If !GVA->(DbSeek(xFilial('GVA') + FwFldGet("GVW_CDEMIT") + FwFldGet("GVW_NRTAB")))
			Help( ,, 'HELP',, 'Tabela inexistente.', 1, 0) 
			lRet := .F.
		EndIf

		GV9->(DbSetOrder(1))
		If !GV9->(DbSeek(xFilial('GV9') + FwFldGet("GVW_CDEMIT") + FwFldGet("GVW_NRTAB") + FwFldGet("GVW_NRNEG")))
			Help( ,, 'HELP',, 'Negociação inexistente.', 1, 0) 
			lRet := .F.
		EndIf

		GXT->(DbSetOrder(1))
		If !GXT->(DbSeek(FwFldGet("GVW_FILGXT") + Padr(FwFldGet("GVW_NRCT"), TamSX3("GVW_NRCT")[1])))	
			Help( ,, 'HELP',, 'Contrato inexistente.', 1, 0) 
			lRet := .F.
		elseif GXT->GXT_CDTRP != FwFldGet("GVW_CDEMIT")		
			Help( ,, 'HELP',, 'Transportador do contrato e da tabela de frete são diferentes!', 1, 0) 
			lRet := .F.			
		elseif GXT->GXT_SIT == '1' .OR. GXT->GXT_SIT >= '4' 
			Help( ,, 'HELP',, 'Situação do contrato não permite vínculo com tabela de frete!', 1, 0) 
			lRet := .F.	
		EndIf	

		cQuery := "SELECT * FROM " + RetSQLName("GVW") + " GVW "
		cQuery += "WHERE "
		cQuery += " GVW_CDEMIT = '" + FwFldGet("GVW_CDEMIT") + "'"
		cQuery += " AND GVW_NRTAB  = '" + FwFldGet("GVW_NRTAB") + "'"
		cQuery += " AND GVW_NRNEG = '" + FwFldGet("GVW_NRNEG") + "'"
		cQuery += " AND GVW_NRCT <> '" + FwFldGet("GVW_NRCT") + "'"
		cQuery += " AND GVW.D_E_L_E_T_ = ''"
		
		cQuery := ChangeQuery(cQuery)
		cAliasGVW := GetNextAlias()
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasGVW, .F., .T.)

		(cAliasGVW)->( dbGoTop() )
		While !(cAliasGVW)->(Eof())
		
			Help( ,, 'HELP',, 'Tabela já relacionada ao contrato ' + (cAliasGVW)->GVW_NRCT, 1, 0) 
			lRet := .F.					
			
			(cAliasGVW)->(dbSkip())
		EndDo	
		(cAliasGVW)->(dbCloseArea())								

	EndIf
	
	RestArea(aAreaGVW)
	RestArea(aArea)

Return lRet 

User Function fValidTab()
	
	Local lRet := .T.
	
	GVW->(dbGoTop())
	While !GVW->(Eof())
		If Alltrim(GVW->GVW_NRTAB) == AllTrim(FwFldGet("GVW_NRTAB")) .And. Alltrim(GXT->GXT_NRCT) <>  AllTrim(FwFldGet("GVW_NRCT"))
			Help( ,, 'HELP',, 'Tabela já relacionada a outro contrato.', 1, 0) 
			lRet := .F.
			Exit
		EndIf
		GXT->( dbSkip() )
	EndDo
Return lRet
