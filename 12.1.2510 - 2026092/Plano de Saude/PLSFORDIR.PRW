#Include 'Protheus.ch'
#Include 'FWMVCDEF.CH'
#Include 'FWBROWSE.CH'
#INCLUDE "PLSForDIR.CH"
#INCLUDE "TCBROWSE.CH"
#INCLUDE "PLSMGER.CH"

Static objCENFUNLGP := CENFUNLGP():New() 
Static cCodint      := ""
Static cCodRda      := ""
Static aDadRda      := {}
Static lEstoque		:= .F.

//-------------------------------------------------------------------
/*/ {Protheus.doc } PLSForDIR
Tela inicial
@since 05/2023
@version P12 
/*/
//-------------------------------------------------------------------
Function PLSForDIR(lAutoma)

	Local oBrowse   := nil
	Default lAutoma := .f.

	PlLoadStat()

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('BJF')
	oBrowse:SetDescription(STR0001) //Fornecimento Direto

	if lEstoque
		oBrowse:AddLegend("Empty(BJF_CODPEG)  .And. Empty(BJF_DOCREQ)"	, 'BR_AMARELO'	, 'Pendente gerar Guia' )
		oBrowse:AddLegend("!Empty(BJF_CODPEG) .And. Empty(BJF_DOCREQ)"	, 'BR_VERMELHO'	, 'Pendente gerar Req. Estoque' )
		oBrowse:AddLegend("!Empty(BJF_CODPEG) .And. !Empty(BJF_DOCREQ)"	, 'BR_VERDE'	, 'Guia Gerada/Req. Est. Gerada' )
	endif

	iIf(!lAutoma,oBrowse:Activate(),)

Return nil


//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menus
@since 05/2023
@version P12 
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina := {}

	Add Option aRotina Title  STR0002	Action 'VIEWDEF.PLSForDIR' 	    Operation 2 Access 0  //Visualizar
	Add Option aRotina Title  STR0003 	Action 'VIEWDEF.PLSForDIR' 	    Operation 3 Access 0  //Incluir
	Add Option aRotina Title  STR0004   Action 'VIEWDEF.PLSForDIR'      Operation 4 Access 0  //Alterar
	Add Option aRotina Title  STR0005   Action 'VIEWDEF.PLSForDIR'      Operation 5 Access 0  //Excluir
	Add Option aRotina Title  STR0041   Action 'PlIncGuIfD()'           Operation 1 Access 0  //Cria guia de Fornecimento direto
	Add Option aRotina Title  STR0048   Action 'PlCanGuIfD()'           Operation 1 Access 0  //Cancelar guia de Fornecimento direto
	if lEstoque
		Add Option aRotina Title  "Gerar requisição de estoque"    Action 'PlGerReqfD()'     Operation 1 Access 0  
		Add Option aRotina Title  "Estornar requisição de estoque" Action 'PlGerReqfD("2")'  Operation 1 Access 0  
	endif

Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de Dados.
@since 05/2023
@version P12
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

	Local oModel	:= nil 
	Local oStrBJF	:= FWFormStruct(1,'BJF')
	Local oStrBJG	:= FWFormStruct(1,'BJG')
	Local cCodint   := Plsintpad()
	Local aGatilho := {}

	oModel := MPFormModel():New( 'PLSForDIR', , { |oMdl| PlValidPOS( oMdl ) } )

	aGatilho := FwStruTrigger('BJG_CODPRO', 'BJG_DESPRO', 'BR8->BR8_DESCRI', .f., 'BR8', 1, 'xFilial("BR8") + FwFldGet("BJG_CODPAD") + FwFldGet("BJG_CODPRO")','!empty(FwFldGet("BJG_CODPRO"))') 
	oStrBJG:AddTrigger( aGatilho[1], aGatilho[2], aGatilho[3], aGatilho[4] )

	oStrBJG := PLAddFldStruct(1, oStrBJG, {"BJG_CODGRU"}, .t.)

	oModel:AddFields( 'BJFMASTER', /*cOwner*/, oStrBJF )
	oModel:AddGrid('BJGDetail', 'BJFMASTER', oStrBJG,{|oModelGrid, nLine, cAction, cField| VldLinPre(oModelGrid, nLine, cAction, cField)},{|| VldLinha(oModel)})
	oModel:SetRelation( 'BJGDetail', { { 'BJG_FILIAL', 'xFilial( "BJG" ) ' } , ;
									{ 'BJG_CDRELA', 'BJF_IDENTI' }} , ;
										BJG->(indexkey(1)) )

	oStrBJF:SetProperty( 'BJF_MATRIC', MODEL_FIELD_OBRIGAT, .T. )

	oStrBJF:SetProperty( "BJF_CODOPE", MODEL_FIELD_INIT , { || cCodint } )
	oStrBJF:SetProperty( "BJF_TIPREG", MODEL_FIELD_INIT , { || "1" } )

	oStrBJF:SetProperty( "BJF_CODOPE",  MODEL_FIELD_WHEN ,{ || .f. } )
	oStrBJG:SetProperty( "BJG_CODUND",  MODEL_FIELD_WHEN ,{ || empty(oModel:Getmodel("BJGDetail"):GetValue("BJG_CODGRU")) } )
	oStrBJG:SetProperty( "BJG_CODGRU",  MODEL_FIELD_WHEN ,{ || empty(oModel:Getmodel("BJGDetail"):GetValue("BJG_CODPRO")) } )
	oStrBJG:SetProperty( "BJG_SEQUEN",  MODEL_FIELD_WHEN ,{ || .F. } )

	oStrBJG:SetProperty( "BJG_QUANTI",  MODEL_FIELD_VALID ,{ || PlVldQtd(oModel) } )
	oStrBJG:SetProperty( "BJG_CODPRO",  MODEL_FIELD_VALID ,{ || PVldCodPro(oModel) } )
	oStrBJG:SetProperty( "BJG_CODPAD",  MODEL_FIELD_VALID ,{ || PlVldCdPad(oModel)} )
	oStrBJG:SetProperty( "BJG_CODGRU",  MODEL_FIELD_VALID ,{ || PlVldGru(oModel)} )
	oStrBJG:SetProperty( "BJG_CODUND",  MODEL_FIELD_VALID ,{ || Vazio() .or. PLSUndVld(oModel)} )

	oStrBJG:SetProperty( "BJG_VLRFOR",  MODEL_FIELD_VALID ,{ ||  PLSVldVlr(oModel)} )

	oStrBJG:SetProperty( 'BJG_DESPRO',  MODEL_FIELD_TAMANHO, 300 )

	oModel:GetModel( 'BJGDetail' ):SetOptional(.t.)
	oModel:GetModel( 'BJFMASTER' ):SetDescription( STR0001 )

Return oModel


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição da interface.
@since 05/2023
@version P12
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

	Local oView 
	Local oModel	:= FWLoadModel( 'PLSForDIR' )
	Local oStrBJF	:= FWFormStruct(2,'BJF')
	Local oStrBJG	:= FWFormStruct(2,'BJG',{ |cCampo| OcultaCmp(cCampo) })

	oView := FWFormView():New()
	
	oStrBJG := PLAddFldStruct(2, oStrBJG, {"BJG_CODGRU"}, .t.)

	oView:SetModel( oModel )
	oView:AddField( 'ViewBJF', oStrBJF, 'BJFMASTER' )
	oView:AddGrid( 'ViewBJG' , oStrBJG,'BJGDetail' )

	oView:AddIncrementField('ViewBJG', 'BJG_SEQUEN')

	oView:CreateHorizontalBox( 'SUPERIOR', 50 )
	oView:CreateHorizontalBox( 'INFERIOR', 50 )
	oView:SetOwnerView( 'ViewBJF', 'SUPERIOR' )
	oView:SetOwnerView( 'ViewBJG', 'INFERIOR' )
	oView:SetProgressBar(.t.)
	oView:EnableTitleView('ViewBJG', "Eventos - Tabela BJG")
	oView:SetViewProperty("ViewBJG", "GRIDSEEK",    {.T.})
	oView:SetViewProperty("ViewBJG", "GRIDFILTER",  {.T.})

	oView:SetDescription(STR0001) //Fornecimento Direto

Return oView


/*/{Protheus.doc} PlValidPOS
Validacao de deleção
@type function
@version 12.1.2410
@author claudiol
@since 10/25/2024
@param oModel, object, model
@return logical, .T. validado
/*/
Static Function PlValidPOS( oModel )
Local nOperation := oModel:GetOperation()
Local lRet := .T.

If nOperation == MODEL_OPERATION_DELETE .or. nOperation == MODEL_OPERATION_UPDATE
   If !Empty( oModel:GetValue( 'BJFMASTER', 'BJF_CODPEG' ) )
      Help( ,, 'HELP',, 'Guia já foi gerada. Cancele a guia primeiro!', 1, 0)
      lRet := .F.
   EndIf
EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} PlIncForDi
//Função que define se o model está incluindo ou não. Se For inclusão, apenas o campo Matrícula deverá estar
aberto para edição e gatilhar para os demais. Essa função deverá ser colocada no X3_WHEN dos campos relativos ao
beneficiário.
@since 05/2023
@version P12
/*/
//-------------------------------------------------------------------
Function PlIncForDi()

	Local oModelAtivo 	:= FWModelActive()
	Local lRetFun		:= .f.

	If oModelAtivo:IsActive()
		lRetFun := oModelAtivo:GetOperation() == MODEL_OPERATION_INSERT
	EndIf

Return lRetFun

/*/{Protheus.doc} nomeStaticFunction
	Campos que não devem ser exibidos no Grid BJG
	@type  Static Function
	@author Thiago Rodrigues
	@since 21/07/2023
	@version version
	@see (links_or_references)
/*/
Static Function OcultaCmp(cCampo)

	Local lRet := .T.

	If alltrim(cCampo) $ 'BJG_CDRELA'
		lRet := .f.
	EndIf

Return lRet


/*/{Protheus.doc} PlVldQtd
	(Valida a quantidade)
	@type  Static Function
	@author Thiago Rodrigues
	@since 21/07/2023
	@version version
	@see (links_or_references)
/*/
Static Function PlVldQtd(oModel)

	Local lRet:= .t.
	Local objBJG := oModel:GetModel("BJGDetail")

	If empty(objBJG:Getvalue("BJG_QUANTI")) .OR. objBJG:Getvalue("BJG_QUANTI") <= 0 
		lRet := .f.
		Help(nil, nil , STR0006, nil, STR0007, 1, 0, nil, nil, nil, nil, nil, {STR0008} )
	Else 
		PlAtuVlTot(oModel)//Atualiza Valor Total
	EndIf

Return lRet

/*/{Protheus.doc} PVldCodPro
	(Valida o procedimento e carrega a descrição)
	@type  Static Function
	@author Thiago Rodrigues
	@since 21/07/2023
	@version version
	@see (links_or_references)
/*/
Static Function PVldCodPro(oModel)

	Local lRet    := .T.
	Local oObjBJG := oModel:Getmodel("BJGDetail") 
	Local cCodpad := oObjBJG:GetValue("BJG_CODPAD")
	Local cCodPro := oObjBJG:GetValue("BJG_CODPRO")
	Local cChave  := cCodpad+cCodPro
	Local cAlias  := GetNextAlias()
	Local cExp    := "%(" + "UPPER(BTQ_FENVIO) = 'INDIVIDUALIZADO'"+ ")%"
	Local cVigIni := ""
	Local cVigFim := ""
	Local dDataFor:= oModel:GetModel("BJFMASTER"):GetValue("BJF_DATFOR")
	Local lTemVig := .f.

	If empty(cCodpad) .and. !empty(cCodPro)
		Help(nil, nil , STR0006, nil, STR0011, 1, 0, nil, nil, nil, nil, nil, {STR0012} ) //'O código da tabela esta vazio. InForme o código da tabela
		lRet:= .f.
	EndIf

	//Se o setValue veio da função do grupo, preciso validar a vigência do grupo (Forma de envio 'CONSOLIDADO')
	//O Código do procedimento foi setado porque será necessário para a criação da guia
	If FwIsInCallStack("PLVLDGRU")
		cExp := "%(" + "UPPER(BTQ_FENVIO) = 'CONSOLIDADO'"+ ")%"
	EndIf

	If lRet .and. !empty(cCodPro)
		If BR8->(MsSeek(xFilial("BR8")+cChave))
			dDataFor := Dtos(iIf(empty(dDataFor),ddatabase,dDataFor))

			BeginSql Alias cAlias
				SELECT 
					BTQ_VIGDE,
					BTQ_VIGATE 
				FROM %table:BTQ% BTQ
				WHERE BTQ_FILIAL = %xfilial:BTQ%
				AND   BTQ_CDTERM = %Exp:cCodPro%
				AND   BTQ_CODTAB = '64'  
				AND   %Exp:cExp%
				AND   BTQ.%NotDel%
			EndSql

			while !(cAlias)->(Eof())
				cVigIni := (cAlias)->BTQ_VIGDE
				cVigFim := (cAlias)->BTQ_VIGATE

				If ( dDataFor < cVigIni ) .or. (!empty(cVigFim) .and. dDataFor > cVigFim )
					(cAlias)->(DbSkip())
				Else 
					lTemVig := .t.
					exit
				EndIf
			EndDo 

			If !lTemVig
				Help(nil, nil , STR0006, nil, STR0033, 1, 0, nil, nil, nil, nil, nil, {STR0034} ) //" Atenção O Procedimento inFormado está Fora do período de vigência. InForme um grupo válido."
			Else
				oObjBJG:SetValue("BJG_DESPRO",BR8->BR8_DESCRI)
			EndIf

			(cAlias)->(DbCloseArea())

		Else
			Help(nil, nil , STR0006, nil, STR0036, 1, 0, nil, nil, nil, nil, nil, {STR0034} )
			lRet := .f.
		EndIf	
	EndIf


	If empty(cCodPro)
		oObjBJG:SetValue("BJG_DESPRO","")
	EndIf

Return lRet

/*/{Protheus.doc} PlVldCdPad
	(Validação do codigo da tabela)
	@type  Static Function
	@author Thiago Rodrigues
	@since 25/07/2023
	@version version
	@see (links_or_references)
/*/
Static Function PlVldCdPad(oModel)

	Local objBJG := oModel:Getmodel("BJGDetail")
	Local lRet   := .t.

	BR4->(DbSetOrder(1))

	If !empty(objBJG:GetValue("BJG_CODPRO"))
		Help(nil, nil , STR0006, nil, STR0027, 1, 0, nil, nil, nil, nil, nil, {STR0028} ) //"Não é possível alterar o codigo da tabela sem antes limpar o procedimento"
		lRet := .f.
	ElseIf !empty(objBJG:GetValue("BJG_CODPAD")) .and. !BR4->( MsSeek( xFilial("BR4")+objBJG:GetValue("BJG_CODPAD") ) )
		Help(nil, nil , STR0006, nil, STR0029, 1, 0, nil, nil, nil, nil, nil, {STR0030} ) //"Não foi possível encontrar na base de dados a tabela inFormada."
		lRet := .f.
	EndIf				

Return lRet

/*/{Protheus.doc} VldLinha
	(Função de pos validação do Grid)
	@type  Static Function
	@author Thiago Rodrigues
	@since 21/07/2023
	@version version
	@see (links_or_references)
/*/
Static Function VldLinha(oModel)

	Local lRet 	     := .t.
	Local oObjBJG    := oModel:Getmodel("BJGDetail") 
	Local cCodpad    :=""
	Local cCodpro    :=""
	Local cCodGru    :=""


	cCodpad := oObjBJG:getvalue("BJG_CODPAD")
	cCodpro := oObjBJG:getvalue("BJG_CODPRO")
	cCodGru := oObjBJG:getvalue("BJG_CODGRU")

	If  empty(cCodGru) .and. !empty(cCodpad) .and. empty(cCodpro)
		lRet := .F.
		Help(nil, nil , STR0006, nil, STR0009, 1, 0, nil, nil, nil, nil, nil, {STR0010} )//"O código do procedimento está vazio." / "InForme o código do procedimento!"
	EndIf

	If lRet .and. empty(oObjBJG:getvalue("BJG_QUANTI")) 
		lRet := .F.
		Help(nil, nil , STR0006, nil, "Deve ser inFormado a quantidade:BJG_QUANTI ", 1, 0, nil, nil, nil, nil, nil, {"InForme a quantidade"} )//"O código do procedimento está vazio." / "InForme o código do procedimento!"
	EndIf

Return lRet 

 /*/{Protheus.doc} PlPeBJGPRO
	(Pesquisa F3 especIfica para o BJG_CODPRO)
	@type  Function
	@author Thiago Rodrigues
	@since 24/07/2023
	@version version
	@see (links_or_references)
	/*/
Function PlPeBJGPro()

	Local nLin       	:= 1
	Local nOpca      	:= 0
	Local cChave     	:= Space(40)
	Local cTipoPes   	:= ""
	Local oDlgPesPro    := NIL
	Local oTipoPes		:= NIL
	Local oBrowPro		:= NIL
	Local oGetChave		:= NIL
	Local oChkChk		:= NIL
	Local oModelAtivo 	:= FWModelActive()
	Local aBrowPro   	:= {}
	Local aVetPad    	:= { {"","",0,"",""} }
	Local bRefresh   	:= { || If(!Empty(cChave),PlBusPro(AllTrim(cChave),Subs(cTipoPes,1,1),aBrowPro,oBrowPro,oModelAtivo,aVetPad,.f.,.f.),.T.), If( Empty(aBrowPro[1,1]) .And. !Empty(cChave),.F.,.T. )  }
	Local cValid     	:= "{|| Eval(bRefresh) }"
	Local bOK        	:= { || If(!Empty(cChave),(nLin := oBrowPro:nAt,nOpca := 1,lOk:=.T.,oDlgPesPro:End()),Help(nil, nil , STR0006, nil, STR0015, 1, 0, nil, nil, nil, nil, nil, {STR0016} )) }
	Local bCanc      	:= { || nOpca := 3,oDlgPesPro:End() }
	Local aTipoPes   	:= {}
	Local lChkChk    	:= .F.
	Local lRet		 	:= .F.
	Local aButtons   	:= {}
	Local aCampos := {}
	Local aBls    := {}
	Local cCodPad      := ""

	PRIVATE aOpcoes   	:= {}

	If oModelAtivo:IsActive()
		cCodPad:=oModelAtivo:GetModel("BJGDetail"):GetValue("BJG_CODPAD")
		If empty(cCodPad)
				Help(nil, nil , STR0006, nil, STR0011, 1, 0, nil, nil, nil, nil, nil, {STR0012} )
				Return .f.
		EndIf
	EndIf

	dbSelectArea("BR8")

	aBrowPro := aClone(aVetPad)
		
	aTipoPes := {STR0017,STR0018}//"1-Nome do Procedimento"##"2-Codigo do Procedimento"
	aadd(aOpcoes,{"BR8_DESCRI"})
	aadd(aOpcoes,{"BR8_CODPSA"})

		
	DEFINE MSDIALOG oDlgPesPro TITLE STR0019 FROM 008.2,000 TO 030,ndColFin OF GetWndDefault() //"Pesquisa de Procedimentos"

	//Monta objeto que recebera o a chave de pesquisa  ...
	oGetChave := TGet():New(040,085,{ | U | If( PCOUNT() == 0, cChave, cChave := U ) },oDlgPesPro,210,008 ,"@!",&cValid,nil,nil,nil,nil,nil,.T.,nil,.F.,nil,.F.,nil,nil,.F.,nil,nil,cChave)

	//Monta Browse...
	oBrowPro := TcBrowse():New( 058, 008, 378, If(cPaisLoc=="BRA",075,090),,,, oDlgPesPro,,,,,,,,,,,, .F.,, .T.,, .F., )

	ADD COLUMN TO oBrowPro BITMAP DATA { || LoadBitmap( GetResources(), aBrowPro[oBrowPro:nAt,4] ) } TITLE "" WIDTH 015 ALIGN CENTERED NOHILITE

	oBrowPro:AddColumn(TcColumn():New(STR0020,nil,;
				nil,nil,nil,nil,030,.F.,.F.,nil,nil,nil,.F.,nil))//"Tabela"
				oBrowPro:ACOLUMNS[2]:BDATA := { || aBrowPro[oBrowPro:nAt,5] }
	oBrowPro:AddColumn(TcColumn():New(STR0020,nil,;
				nil,nil,nil,nil,060,.F.,.F.,nil,nil,nil,.F.,nil))//"Procedimento"
				oBrowPro:ACOLUMNS[3]:BDATA := { || aBrowPro[oBrowPro:nAt,1] }
	oBrowPro:AddColumn(TcColumn():New(STR0022,nil,;
				nil,nil,nil,nil,090,.F.,.F.,nil,nil,nil,.F.,nil))//"Descricao"
				oBrowPro:ACOLUMNS[4]:BDATA := { || aBrowPro[oBrowPro:nAt,2] }

	@ 040,008 COMBOBOX oTipoPes  Var cTipoPes ITEMS aTipoPes SIZE 077,010 OF oDlgPesPro PIXEL COLOR CLR_HBLUE
	@ 040,315 CHECKBOX oChkChk   Var lChkChk PROMPT STR0023 PIXEL SIZE 080, 010 OF oDlgPesPro//"Pesquisar Palavra Chave"

	oBrowPro:SetArray(aBrowPro)
	oBrowPro:BLDBLCLICK := bOK
	oTipoPes:bLostFocus := {|| oGetChave:Refresh(),oGetChave:SetFocus(),.T.}

	If cPaisLoc == "BRA"
		@ 142,013 BITMAP oBmp RESNAME "BR_VERMELHO"   OF oDlgPesPro SIZE 40,20 NOBORDER WHEN .F. PIXEL
		@ 142,025 Say oSay PROMPT STR0024 SIZE 100,010 OF oDlgPesPro PIXEL//"Nao Pertence ao ROL da ANS"

		@ 142,120 BITMAP oBmp RESNAME "BR_VERDE"   OF oDlgPesPro SIZE 40,20 NOBORDER WHEN .F. PIXEL
		@ 142,130 Say oSay PROMPT  STR0025 SIZE 100,010 OF oDlgPesPro PIXEL //"Pertence ao ROL da ANS"
	EndIf
		
	//-- LGPD -------- 
	If objCENFUNLGP:isLGPDAt() 
		aCampos := {.F.,"BR8_CODPAD","BR8_CODPSA","BR8_DESCRI"} 
		aBls := objCENFUNLGP:getTcBrw(aCampos) 
		oBrowPro:aObfuscatedCols := aBls 
	EndIf 
	//---------------- 
		
	ACTIVATE MSDIALOG oDlgPesPro ON INIT Eval({ || oGetChave:SetFocus(), EnChoiceBar(oDlgPesPro,bOK,bCanc,.F.,aButtons) }) CENTERED
		
		If nOpca == K_OK
			If !Empty( aBrowPro[nLin,1] )
				BR8->( DbGoTo(aBrowPro[nLin,3]) )
				lRet := .T.
			EndIf
		EndIf
	
Return(lRet)


/*/{Protheus.doc} PlBusPro
	(Monta o Retorno para a pesquisa de procedimentos
	Terminologia 64 de Forma de envio de procedimentos e itens assistenciais para ANS)
	@type  Static Function
	@author Thiago Rodrigues
	@since 24/07/2023
	@see (links_or_references)
/*/
Static Function PlBusPro(cChave,cTipoPes,aBrowPro,oBrowPro,oModelAtivo,aVetPad,lAuto,lGrupo)

	Local cAlias   := GetNextAlias()
	Local cCodTerm := "64" 
	Local cCodPad  := "" 
	Local cExp     := ""
	Local lret     := .T.
	Local cFormEnv := ""
	Default lAuto  := .f.
	Default lGrupo := .f.

	cFormEnv := iIf(lGrupo,"CONSOLIDADO","INDIVIDUALIZADO")

	BTQ->(DbSetOrder(1))

	If '"' $ cChave .Or. "'" $ cChave
		Help(nil, nil , STR0006, nil, STR0013, 1, 0, nil, nil, nil, nil, nil, {STR0014} )//Foram encontrados caracteres inválidos na consulta. InForme uma descrição válida
		lRet := .f.
	EndIf

	If lRet

		If oModelAtivo:IsActive()
			cCodPad:= oModelAtivo:GetModel("BJGDetail"):GetValue("BJG_CODPAD")
		EndIf

		cExp := PlStrQuery(aOpcoes[val(cTipoPes),1], cChave)
		aBrowPro := {}

		BeginSql Alias cAlias

			SELECT BR8_CODROL Codrol, BR8_CODPAD Codpad, BR8_CODPSA Codpro,
				BR8_DESCRI Descri, BR8.R_E_C_N_O_ BR8REG
			FROM %table:BR8% BR8
			WHERE BR8.BR8_FILIAL = %xfilial:BR8% 
			AND	  %exp:cExp %
			AND	  BR8.BR8_CODPAD  = %exp:cCodPad %
			AND	  BR8.BR8_BENUTL  = %exp:'1' %
			AND   BR8.%notDel%

		EndSql

		while !(cAlias)->(eof())

			If BTQ->(dbSeek(xFilial("BTQ")+cCodTerm+(cAlias)->CodPro)) .And. UPPER(Alltrim(BTQ->BTQ_FENVIO)) == cFormEnv
				
				If Ascan(aBrowPro,{ |x| AllTrim(x[1]) == AllTrim((cAlias)->Codpro) } ) == 0
					AaDd( aBrowPro,{ (cAlias)->Codpro,(cAlias)->Descri,(cAlias)->BR8REG,iIf(cPaisLOC=="BRA",iIf(Empty((cAlias)->Codrol),"BR_VERMELHO","BR_VERDE"),"BR_VERDE" ),(cAlias)->Codpad, iIf(lGrupo,BTQ->BTQ_CODGRU,),BTQ->(RECNO()) } )
				EndIf

			EndIf
		(cAlias)->(dbSkip())
		End

		(cAlias)->(DbCloseArea())

		If Len(aBrowPro) == 0
			aBrowPro := aClone(aVetPad)
		EndIf

		If !lAuto
			oBrowPro:nAt := 1
			oBrowPro:SetArray(aBrowPro)
			oBrowPro:Refresh()
			oBrowPro:SetFocus()
		EndIf
	EndIf

	BTQ->(DbCloseArea())

Return lret


/*/{Protheus.doc} PlStrQuery
	(Ajusta String para query)
	@type  Static Function
	@author Thiago Rodrigues
	@since 24/07/2023
	@see (links_or_references)
/*/
Static Function PlStrQuery(cCampo,cContBusca)

	Local nTam		:= 0
	Local cWhere		:= ""
	Local cConteudo	:= ''

	nTam		:= tamSx3(cCampo)[1]
	cConteudo	:= substr(cContBusca,1,nTam)

	If cCampo == "BR8_DESCRI"
		cWhere := cCampo + " like " + "'" + cConteudo + "%' "
	Else
		cWhere := cCampo + " = '" + cConteudo + "' "
	EndIf

	cWhere:= "%(" + cWhere + ")%"

Return(cWhere)


/*/{Protheus.doc} PlBGFGRP
	(Pesquisa específica do Forneceimento direto
	Para o Grupo de procedimentos conForme padrão Tiss
	Tabela de domínio 63)
	@type  Function
	@author Thiago Rodrigues
	@since 25/07/2023
	/*/
Function PlBGFGRP()

	Local nLin       	:= 1
	Local nOpca      	:= 0
	Local cChave     	:= Space(40)
	Local cTipoPes   	:= ""
	Local oDlgPesPro    := NIL
	Local oTipoPes		:= NIL
	Local oGetChave		:= NIL
	Local oChkChk		:= NIL
	Local oModelAtivo 	:= FWModelActive()
	Local aBrowPro   	:= {}
	Local aVetPad    	:= { {"","",0,"","", ,""} }
	Local bRefresh   	:= { || If(!Empty(cChave),PlBusPro(AllTrim(cChave),Subs(cTipoPes,1,1),aBrowPro,oBrowPro,oModelAtivo,aVetPad,.f.,.t.),.T.), If( Empty(aBrowPro[1,1]) .And. !Empty(cChave),.F.,.T. )  }
	Local cValid     	:= "{|| Eval(bRefresh) }"
	Local bOK        	:= { || If(!Empty(cChave),(nLin := oBrowPro:nAt,nOpca := 1,lOk:=.T.,oDlgPesPro:End()),Help(nil, nil , STR0006, nil, STR0015, 1, 0, nil, nil, nil, nil, nil, {STR0016} )) }
	Local bCanc      	:= { || nOpca := 3,oDlgPesPro:End() }
	Local aTipoPes   	:= {}
	Local lChkChk    	:= .F.
	Local lRet		 	:= .F.
	Local aButtons   	:= {}
	Local aCampos       := {}
	Local aBls          := {}
	Local cCodPad       := ""
	Local lMdlAtivo     := .f.
	PRIVATE aOpcoes   	:= {}

	lMdlAtivo := oModelAtivo:IsActive()

	If lMdlAtivo
		cCodPad:=oModelAtivo:GetModel("BJGDetail"):GetValue("BJG_CODPAD")
		If empty(cCodPad)
				Help(nil, nil , STR0006, nil, STR0011, 1, 0, nil, nil, nil, nil, nil, {STR0012} )
				Return .f.
		EndIf
	EndIf

	dbSelectArea("BR8")

	aBrowPro := aClone(aVetPad)
		
	aTipoPes := {STR0017,STR0018}//"1-Nome do Procedimento"##"2-Codigo do Procedimento"
	aadd(aOpcoes,{"BR8_DESCRI"})
	aadd(aOpcoes,{"BR8_CODPSA"})

		
	DEFINE MSDIALOG oDlgPesPro TITLE STR0019 FROM 008.2,000 TO 030,ndColFin OF GetWndDefault() //"Pesquisa de Procedimentos"

	//Monta objeto que recebera o a chave de pesquisa  ...
	oGetChave := TGet():New(040,085,{ | U | If( PCOUNT() == 0, cChave, cChave := U ) },oDlgPesPro,210,008 ,"@!",&cValid,nil,nil,nil,nil,nil,.T.,nil,.F.,nil,.F.,nil,nil,.F.,nil,nil,cChave)

	//Monta Browse...
	oBrowPro := TcBrowse():New( 058, 008, 378, If(cPaisLoc=="BRA",075,090),,,, oDlgPesPro,,,,,,,,,,,, .F.,, .T.,, .F., )

	ADD COLUMN TO oBrowPro BITMAP DATA { || LoadBitmap( GetResources(), aBrowPro[oBrowPro:nAt,4] ) } TITLE "" WIDTH 015 ALIGN CENTERED NOHILITE

	oBrowPro:AddColumn(TcColumn():New(STR0020,nil,;
				nil,nil,nil,nil,030,.F.,.F.,nil,nil,nil,.F.,nil))//"Tabela"
				oBrowPro:ACOLUMNS[2]:BDATA := { || aBrowPro[oBrowPro:nAt,5] }
	oBrowPro:AddColumn(TcColumn():New(STR0021,nil,;
				nil,nil,nil,nil,060,.F.,.F.,nil,nil,nil,.F.,nil))//"Procedimento"
				oBrowPro:ACOLUMNS[3]:BDATA := { || aBrowPro[oBrowPro:nAt,1] }
	oBrowPro:AddColumn(TcColumn():New(STR0026,nil,;
				nil,nil,nil,nil,060,.F.,.F.,nil,nil,nil,.F.,nil))//"Grupo do Procedimento"
				oBrowPro:ACOLUMNS[4]:BDATA := { || aBrowPro[oBrowPro:nAt,6] }
	oBrowPro:AddColumn(TcColumn():New(STR0022,nil,;
				nil,nil,nil,nil,070,.F.,.F.,nil,nil,nil,.F.,nil))//"Descricao"
				oBrowPro:ACOLUMNS[5]:BDATA := { || aBrowPro[oBrowPro:nAt,2] }


	@ 040,008 COMBOBOX oTipoPes  Var cTipoPes ITEMS aTipoPes SIZE 077,010 OF oDlgPesPro PIXEL COLOR CLR_HBLUE
	@ 040,315 CHECKBOX oChkChk   Var lChkChk PROMPT STR0023 PIXEL SIZE 080, 010 OF oDlgPesPro//"Pesquisar Palavra Chave"

	oBrowPro:SetArray(aBrowPro)
	oBrowPro:BLDBLCLICK := bOK
	oTipoPes:bLostFocus := {|| oGetChave:Refresh(),oGetChave:SetFocus(),.T.}

	If cPaisLoc == "BRA"
		@ 142,013 BITMAP oBmp RESNAME "BR_VERMELHO"   OF oDlgPesPro SIZE 40,20 NOBORDER WHEN .F. PIXEL
		@ 142,025 Say oSay PROMPT STR0024 SIZE 100,010 OF oDlgPesPro PIXEL//"Nao Pertence ao ROL da ANS"

		@ 142,120 BITMAP oBmp RESNAME "BR_VERDE"   OF oDlgPesPro SIZE 40,20 NOBORDER WHEN .F. PIXEL
		@ 142,130 Say oSay PROMPT  STR0025 SIZE 100,010 OF oDlgPesPro PIXEL //"Pertence ao ROL da ANS"
	EndIf
		
	//-- LGPD -------- 
	If objCENFUNLGP:isLGPDAt() 
		aCampos := {.F.,"BR8_CODPAD","BR8_CODPSA","BR8_DESCRI"} 
		aBls := objCENFUNLGP:getTcBrw(aCampos) 
		oBrowPro:aObfuscatedCols := aBls 
	EndIf 
	//---------------- 
		
	ACTIVATE MSDIALOG oDlgPesPro ON INIT Eval({ || oGetChave:SetFocus(), EnChoiceBar(oDlgPesPro,bOK,bCanc,.F.,aButtons) }) CENTERED
		
		If nOpca == K_OK
			If !Empty( aBrowPro[nLin,1] )
				BR8->( DbGoTo(aBrowPro[nLin,3]) )
				BTQ->( DbGoTo(aBrowPro[nLin,7]))
				lRet := .T.
			EndIf
		EndIf
	
Return (.T.)

/*/{Protheus.doc} PlVldGru
	(Faz a validação do grupo de procedimento 
	 tipo de envio (Tab 64) = consolidado ConForme padrão TISS )
	@type  Static Function
	@author Thiago Rodrigues
	@since 27/07/2023
	@see (links_or_references)
/*/
Static Function PlVldGru(oModel)

	Local oObjBjg := oModel:GetModel("BJGDetail")
	Local oObjBjf := oModel:GetModel("BJFMASTER")
	Local cCodGru := "" 
	Local cCodPro := ""
	Local cAlias  := GetNextAlias()
	Local lRet    := .f.
	Local dDataFor := oObjBjf:GetValue("BJF_DATFOR")
	Local cVigIni := ""
	Local cVigFim := ""
	Local lIsF3   := isInCallStack("F3GET")
	Local cExp   := "%(" + "UPPER(BTQ_FENVIO) = 'CONSOLIDADO'"+ ")%"
	Local lCont  := .t.

	cCodGru  := oObjBjg:GetValue("BJG_CODGRU")
	dDataFor := Dtos(iIf(empty(dDataFor),ddatabase,dDataFor ))

	If !empty(cCodGru)

		//No F3 esta filtrado o grupo e procedimento, assim não onera a pesquisa ja que a tabela BTQ é gigante
		//Se inFormar só o grupo e tabela, a query retornará milhares registros
		If !lIsF3 .and. empty(cCodPro)
			Help(nil, nil , STR0006, nil, STR0035, 1, 0, nil, nil, nil, nil, nil, {""} )
			lCont := .f.
		EndIf 

		If lCont
			cCodPro  := BR8->BR8_CODPSA

			BeginSql Alias cAlias 
				SELECT 
					BTQ_DESTER, 
					BTQ_VIGDE,
					BTQ_VIGATE 
				FROM %table:BTQ% BTQ
				WHERE BTQ_FILIAL = %xfilial:BTQ%
				AND   BTQ_CDTERM = %Exp:cCodPro%
				AND   BTQ_CODGRU = %Exp:cCodGru%
				AND   BTQ_CODTAB = '64'
				AND   %Exp:cExp%  
				AND   BTQ.%NotDel%
			EndSql

			while !(cAlias)->(Eof())
				cVigIni := (cAlias)->BTQ_VIGDE
				cVigFim := (cAlias)->BTQ_VIGATE

				If ( dDataFor < cVigIni ) .or. (!empty(cVigFim) .and. dDataFor > cVigFim )
					(cAlias)->(DbSkip())
				Else
					lRet  := .t.
					exit
				EndIf
			EndDo 

			If !lRet
				Help(nil, nil , STR0006, nil, STR0031, 1, 0, nil, nil, nil, nil, nil, {STR0032} ) // " Atenção O grupo inFormado está Fora do período de vigência. InForme um grupo válido."
			Else
				oObjBJG:SetValue("BJG_CODPRO",Alltrim(cCodPro))
			EndIf

			(cAlias)->(DbCloseArea())
		EndIf	

	Else
		lRet :=.t.
		oObjBJG:SetValue("BJG_DESPRO","")
		oObjBJG:SetValue("BJG_CODPRO","")
	EndIf	

Return lRet

/*/{Protheus.doc} PLSUndVld
	(Valida a unidade e caso ela tenha vindo da rotina de medicamentos
	realiza o de-para conForme a tiss para o envio do monitoramento)
	@type  Static Function
	@author Thiago Rodrigues
	@since 16/08/2023
	@see (links_or_references)
/*/
Static Function PLSUndVld(oModel)

	Local oObjBJF := oModel:getModel("BJFMASTER")
	Local oObjBJG := oModel:getModel("BJGDetail")
	Local cAlias  := GetNextAlias()
	Local lRet    := .f. 
	Local dData   := oObjBJF:GetValue("BJF_DATFOR")
	Local cUnd    := ""

	dData := Dtos(iIf(empty(dData),ddatabase,dData))
	cUnd  :=  oObjBJG:GetValue("BJG_CODUND")

	BeginSql Alias cAlias 
		SELECT 
			BTQ_VIGDE, BTQ_VIGATE
		FROM %table:BTQ% BTQ
		WHERE BTQ_FILIAL = %xfilial:BTQ%
		AND   BTQ_CDTERM = %Exp: cUnd %
		AND   BTQ_CODTAB = '60'
		AND   BTQ.%NotDel%
	EndSql

	while !(cAlias)->(Eof())
		If Empty(BTQ->BTQ_VIGATE) .OR. ( dData >= BTQ->BTQ_VIGDE .AND. dData <= BTQ->BTQ_VIGATE)
			lRet := .t.
			exit
		EndIf
	End

	If !lret 
		Help(nil, nil , STR0006, nil, STR0037, 1, 0, nil, nil, nil, nil, nil, {STR0038} ) // Atenção "Unidade não encontrada no período de vigência inFormado. InForme uma unidade válida"
	EndIf


Return lRet

/*/{Protheus.doc} PLSVldVlr
	(Valida o valor do Fornecimento
	e atualiza os valores totais)
	@type  Static Function
	@author Thiago Rodrigues
	@since 16/08/2023
	@see (links_or_references)
/*/
Static Function PLSVldVlr(oModel)

	Local lret := .t.

	If oModel:GetModel("BJGDetail"):GetValue("BJG_VLRFOR") < 0 
		Help(nil, nil , STR0006, nil, STR0039, 1, 0, nil, nil, nil, nil, nil, {STR0040} ) // Atenção "Valor deve ser maior que zero. InForme  um valor válido"
		lret := .f.
	Else 
		PlAtuVlTot(oModel)
	EndIf

Return lret


/*/{Protheus.doc} VldLinPre
	(Pré Validação do Grid)
	@type  Static Function
	@author Thiago Rodrigues
	@since 16/08/2023
	@see (links_or_references)
/*/
Static Function VldLinPre(oModelGrid, nLine, cAction, cField)

	Local lRet       := .t.
	Local nValor     := 0
	Local oObjCab    := Fwmodelactive()

	oModelGrid:goline(nLine) //Posiciona na linha atual

	If ! empty(oModelGrid:GetValue("BJG_CODPAD"))
		nValor := oObjCab:GetModel("BJFMASTER"):getValue("BJF_VLTOFO")
	EndIf

	If cAction == 'DELETE' .and. nValor> 0
		nValor -= (oModelGrid:GetValue("BJG_VLRFOR") * oModelGrid:GetValue("BJG_QUANTI"))
		oObjCab:GetModel("BJFMASTER"):SetValue("BJF_VLTOFO",nValor)
	ElseIf  cAction == 'UNDELETE'
		nValor += (oModelGrid:GetValue("BJG_VLRFOR") * oModelGrid:GetValue("BJG_QUANTI"))
		oObjCab:GetModel("BJFMASTER"):SetValue("BJF_VLTOFO",nValor)
	EndIf

Return lRet


/*/{Protheus.doc} PlAtuVlTot
	(Atualiza valor total)
	@type  Static Function
	@author Thiago Rodrigues
	@since 17/08/2023
	@see (links_or_references)
/*/
Static Function PlAtuVlTot(oModel)

	Local oObjBJF  := oModel:GetModel("BJFMASTER")
	Local oObjBJG  := oModel:GetModel("BJGDetail")
	Local nFor     := 1
	Local nLinha   := oObjBJG:GetLine()
	Local nVlrTot  := 0

	For nFor := 1 to oObjBJG:length()
		oObjBJG:goline(nFor)

		If !oObjBJG:IsDeleted()
			nVlrTot  += (oObjBJG:GetValue("BJG_VLRFOR")  * oObjBJG:GetValue("BJG_QUANTI"))
		EndIf	
	Next

	oObjBJF:SetValue("BJF_VLTOFO",nVlrTot) 
	oObjBJG:goline(nLinha)

Return


/*/{Protheus.doc} PlIncGuIfD
	(VerIfica os dados obrigatórios e chama a função que
	Cria guia especIfica de Fornecimento direto)
	@type  Function
	@author Thiago Rodrigues
	@since 18/08/2023
/*/
Function PlIncGuIfD(lAuto)

	Local lNetxt := .T.
	Local lNextNF := .F.
	local lReqEst := .T.
	Local cAlias := GetNextAlias()
	local aChavGui:= {"","","",""}
	local cMenEst := ""

	default lAuto:= .F.

	//VerIfica se ja existe guia criada
	If !empty(BJF->BJF_CODPEG)
		Help(nil, nil , STR0006, nil, STR0052 + CRLF + STR0050 + cValToChar(BJF->BJF_CODPEG) + CRLF + STR0051 + cValToChar(BJF->BJF_NUMERO) , 1, 0, nil, nil, nil, nil, nil, {} )
		lNetxt:= .f.
	EndIf

	//VerIfica as inFormações obrigatórias do cabeçalho
	If lNetxt .and. empty(BJF->BJF_DATFOR)
		lNetxt := .f.
		Help(nil, nil , STR0006, nil, STR0042, 1, 0, nil, nil, nil, nil, nil, {STR0043} ) // Atenção "Para criar a guia é obrigatório o preenchimento da data de Fornecimento: BJF_DATFOR"
	EndIf

	//VerIfica as inFormações obrigatórias dos itens
	If lNetxt

		BeginSql Alias cAlias 

			SELECT 
				BJG_CODPAD CODPAD, BJG_CODPRO CODPRO, BJG_QUANTI QUANTI,
				BJG_VLRFOR VLRFor
			FROM %table:BJG% BJG
			WHERE BJG_FILIAL = %xfilial:BJG%
			AND   BJG_CDRELA = %Exp: BJF->BJF_IDENTI %
			AND   BJG.%NotDel%

		EndSql

		while !(cAlias)->(eof()) 

			If empty((cAlias)->CODPAD) .or. empty((cAlias)->CODPRO) .or. empty((cAlias)->QUANTI) .or.;
			   empty((cAlias)->VLRFor)
			
				lNext:=.f.
				Help(nil, nil , STR0006, nil, STR0044, 1, 0, nil, nil, nil, nil, nil, {STR0045} ) //"Existem inFormações não preenchidas que são obrigatórias para criação da guia"
			EndIf	
			(cAlias)->(DbSkip())
		End

		(cAlias)->(DbCloseArea())
	EndIf

	If lNetxt 

		//parametros para gerar requisicao de estoque
		if !lAuto .and. lEstoque .and. !(TelaPerg("PLSFORDIR"))
			return
		endif

//		Begin Transaction

			//Faz a inclusão da guia
			FwMsgRun(, {|| lNextNF := PIncConMed(@aChavGui) },"Processando","Gerando Guia ...")

//		End Transaction

		if lNextNF .And. lEstoque
			//requisição de estoque
			lReqEst:= PlGerReqfD()
			cMenEst:= CRLF + iif(lReqEst,CRLF + "Requisição: " + BJF->BJF_DOCREQ,"")
		endif

		ApMsgInfo(STR0053 + CRLF + STR0050 + aChavGui[3] + CRLF + STR0051 + aChavGui[4] + cMenEst, STR0006)
	EndIf

Return

/*/{Protheus.doc} PIncConMed
	(Faz inclusão da conta medica)
	@type Function
	@author Thiago Rodrigues
	@since 18/08/2023
	@see (links_or_references)
/*/
Static Function PIncConMed(aChavGui)

	Local cCodLdp := PLSRETLDP(9)
	Local cAlias := "BD5"
	Local cLocalExec := "1"
	Local cMatric := ""
	Local cTipoGrv := "1" //1-Remote
	Local dDatPro := dDatabase 
	Local cCodLoc := ""
	Local cTipGui := "14"
	Local lHonor := .f.
	Local lAtuPeg := .t.
	Local cTipCon := "1"
	Local cTipoAte := "04"
	Local cFase := "1"
	Local lChkByFase := .t.
	Local aItens := {}
	Local cRet := ""
	Local aCriticas := {}
	Local cArqImp := ""
	Local lGuiaInc := .F.

	cMatric    := BJF->BJF_MATRIC
	lChkByFase := PlPegExist(cCodLdp) // Se .f. Irá criar a guia no PEG existente

	If len(aDadRda) >=15
		cCodLoc := aDadRda[12]
		cCodEsp := aDadRda[15]
	Else
		Help(nil, nil , "Não foi possível criar a Guia.", nil, "Definir através do parâmetro MV_RDAPROP qual o prestador referente a operadora para envio do fornecimento direto, utilizado no monitoramento ";
		, 1, 0, nil, nil, nil, nil, nil, {} ) 
		Return lGuiaInc
	EndIf

	aItens := PlMontItem()

	cRet := PLSICM(	cCodint, cMatric, cTipoGrv, cLocalExec,/*cCDPFSO*/, /*cCDPFEX*/, dDatPro, /*cHora*/, /*cNumImp*/, cCodRda, cCodLdp,; //11
					/*cTipo*/, cCodLoc, cCodEsp, cTipGui, /*cCidPri*/, /*nQtNasV*/,/*nQtNasM*/, /*nQtNasP*/, /*nQtObtP*/, /*nQtObAR*/, /*cTipFat*/, /*cCidObt*/,/*cNrdCob*/,;//24
					/*cObtMul*/, /*cTipAlt*/,/*cNrdCnv*/,/*cLotGui*/,aItens,cArqImp,/*cNumLib*/,/*aTipPart*/,cAlias,lHonor,/*cOriMovRC*/,/*cNumSol*/,nil,lAtuPeg,;//38
					/*cPadCon*/, /*dDtAlta*/,/*cHrAlta*/,/*cEmgest*/,/*cAbt*/, /*cTraGra*/, /*cComurp*/,/*cAtespa*/,/*cComnal*/,/*cBaipes*/,/*cPaareo*/,/*cPatnor*/,/*cTipSai*/,;//51
					cTipCon, /*cNomUsrCar*/,/*dDtPar*/,cTipoAte,/*cGrpInt*/,/*cTipInt*/,/*cIndAci*/,/*cUndDoe*/,/*nTmpDoe*/,/*cTipDoe*/,/*cMsg01*/,/*cMsg02*/,/*cEspSol*/,; //64
					/*cEspExe*/, /*cTipAdm*/,/*cRegint*/,/*cCarSol*/,nil,/*cAteRN*/,/*lImpTxt*/,cFase,/*cSituac*/,/*cGuiOri*/,/*cCnes*/,aCriticas,/*dDtInIfat*/,/*cHrInIfat*/,; //78
					/*dDtFimFat*/, /*cHrFimFat*/, /*lnInfEquip*/, /*lXmlOrigS*/, /*aEspCbXML*/, /*cGuiPri*/, /*lImpXml*/, lChkByFase, /*cTipPac*/, /*cTipAto*/, /*cParCop*/,; //89
					/*cTipMaj*/, /*iIf( cTipRec == "1", {cTipRec, cNewPegPro}, {'',''})*/,,/*cGuiInt*/,/*nDestino*/,/*aSituIni*/,/*cCodEspNw*/,; //96
					/*cRegAtdNw*/, /*cSadOcuNw*/,/*cRegimAte*/)

	If !Empty(cRet)
		
		PlMudFasFD(cRet) //Muda a fase

		aChavGui := StrTokArr2(Strtran(cRet," ",""),"-")

		BJF->(recLock("BJF",.f.)) //Deu tudo certo, grava os dados da guia
			BJF->BJF_CODOPE := aChavGui[1]
			BJF->BJF_CODPEG := aChavGui[3]
			BJF->BJF_NUMERO := aChavGui[4]
			BJF->BJF_CODLDP := aChavGui[2]
		BJF->(msUnLock())

		If BD5->BD5_FASE == "3"
			PlAtVlrCOP()//Atualiza os valores de coparticipação
		EndIf

		lGuiaInc := .T.
	EndIf

Return lGuiaInc


/*/{Protheus.doc} PlMontItem
	(Monta o array com os itens da guia
	evento e composição)
	@type  Static Function
	@author Thiago
	@since 21/08/2023
	@see (links_or_references)
/*/
Static Function PlMontItem()

	Local cAlias  := GetNextAlias()
	Local aCompo  := {}
	Local nX      := 1
	Local cCodEsp := ""
	Local aTpPRec := {}
	Local nSequen := 0
	Local aResult :={}

	If len(aDadRda) >= 15
		cCodEsp := aDadRda[15]
	EndIf

	BeginSql Alias cAlias 
		SELECT 
			BJG_CODPAD CODPAD, BJG_CODPRO CODPRO, BJG_QUANTI QUANTI,
			BJG_VLRFOR VLRFor
		FROM %table:BJG% BJG
		WHERE BJG_FILIAL = %xfilial:BJG%
		AND   BJG_CDRELA = %Exp: BJF->BJF_IDENTI %
		AND   BJG.%NotDel%
	EndSql

	while !(cAlias)->(eof()) 
		
		nSequen++
		aCompo := PLSCOMEVE(/*cCodTab*/,(cAlias)->CODPAD,(cAlias)->CODPRO,cCodint,dDatabase)

		For nX := 1 to len(aCompo)
			AaDd( aTpPRec,;
			{ aCompo[nX][16],;
			cCodRda,;
			"",;
			"",;
			"",;
			"",;
			"",;
			.T.,;
			cCodRda,;
			cCodEsp,;
			{ aCompo[nX][1]} } )
		Next
		
		aadd(aResult,{	{"SEQMOV" , StrZero(nSequen,3) },;
					{"CODPAD" , (cAlias)->CODPAD },;
					{"CODPRO" , (cAlias)->CODPRO },;	
					{"VLRAPR" , (cAlias)->VLRFor },;				
					{"PRTXPG" , 0				},;
					{"QTD"	  , (cAlias)->QUANTI },;
					{"QTDAUT" , (cAlias)->QUANTI },;
					{"ATPPAR" , aclone(aTpPRec) };
					} )

					aTpPRec := {}
			
		(cAlias)->(DbSkip())
	End

	(cAlias)->(DbCloseArea())

Return aResult

/*/{Protheus.doc} PlLoadStat()
	(Carrega váriaveis Staticas. 
	Chamada em Function na função inicial do fonte
	pois em casos que o acesso ao sistema é feito direto 
	pelo sigapls pode ocorrer problemas se declarar Fora)
	@type  Static Function
	@author Thiago Rodrigues
	@since 21/08/2023
	@see (links_or_references)
/*/
Static Function PlLoadStat()

	cCodint := PlsIntPAd()
	cCodRda := GetNewPar("MV_RDAPROP","")
	lEstoque:= (BJF->(FieldPos("BJF_DOCREQ")) > 0) .and. (BR8->(FieldPos("BR8_CODPRD")) > 0)

	aDadRda := PLSDADRDA(cCodint,cCodRda)

Return 


/*/{Protheus.doc} PlCanGuIfD
	(Cancela a guia de Fornecimento direto, 
	caso a mesma não tenha sido enviada no monitoramento)
	@type  Static Function
	@author Thiago Rodrigues
	@since 23/08/2023
	@version version
	@see (links_or_references)
/*/
Function PlCanGuIfD(lAuto)

	Local cCodope := BJF->BJF_CODOPE
	Local cCodPEg := BJF->BJF_CODPEG
	Local cCodNum := BJF->BJF_NUMERO
	Local cCodLdp := BJF->BJF_CODLDP
	local lRet	  := .T.
	local lReqEst := .T.
	local cMenEst := ""

	default lAuto:= .F.

	if Empty(BJF->BJF_CODPEG)
		Help(nil, nil , STR0006, nil, "Guia não gerada!", 1, 0, nil, nil, nil, nil, nil, {} )
		return
	endif

	BD5->(DbSetOrder(1))
	If BD5->(MsSeek(xFilial("BD5")+cCodope+cCodLdp+cCodPEg+cCodNum))
		If empty(BD5->BD5_LOTMOP) .and. empty(BD5->BD5_LOTMOF) .and. empty(BD5->BD5_LOTMOE) //VerIfica se já foi enviado o monitoramento

			If lAuto .or. MsgYesNo(STR0049 + CRLF + STR0050 + cValToChar(BJF->BJF_CODPEG) + CRLF + STR0051 + cValToChar(BJF->BJF_NUMERO)) //"Deseja realmente cancelar a guia? Código da PEG:   Numero da Guia: "

				Begin Transaction

					//deleta guia
					If (lRet:= PlsDelGuias(cCodOpe,cCodLdp,cCodPEg,cCodNum))
						BJF->(recLock("BJF",.f.)) //Deu tudo certo, limpa os dados da guia
							BJF->BJF_CODPEG := ""
							BJF->BJF_NUMERO := ""
							BJF->BJF_CODLDP := ""
							BJF->BJF_VLTOCP := 0
						BJF->(msUnLock())
						PlZerCop()
					EndIf
				
				End Transaction

				if lRet .and. lEstoque
					//estorna requisição
					if !empty(BJF->BJF_DOCREQ)
						lReqEst:= PlGerReqfD('2')
						cMenEst:= CRLF + iif(lReqEst,CRLF+"Requisição estornada com sucesso.","")
					endif
				endif
				ApMsgInfo(STR0054 + cMenEst, STR0006) //"Guia cancelada com sucesso."
			EndIf
		Else 
			Help(nil, nil , STR0006, nil, STR0046, 1, 0, nil, nil, nil, nil, nil, {} ) //"Não foi possível excluir a guia, pois já foi enviado o monitoramento"
		EndIf
	
	Else 
		Help(nil, nil , STR0006, nil, STR0047, 1, 0, nil, nil, nil, nil, nil, {} ) //"Não foi possível realizar o cancelamento."
	EndIf

Return

/*/{Protheus.doc} PlMudFasFD
	(Posiciona na guia e muda a fase)
	@type  Static Function
	@author Thiago Rodrigues
	@since 23/08/2023
	@version version
	@see (links_or_references)
/*/
Static Function PlMudFasFD(cGuiaPeg)

	Local cCodigo := alltrim(STRTRAN(STRTRAN(cGuiaPeg,"-","")," ",""))
	Local nRecBD5 := 0

	BD5->(DbSetOrder(1)) 
	If ( BD5->(MsSeek(xfilial("BD5") + cCodigo)) ) 
		nRecBD5 := BD5->(recno())
		PLSA500FAS("BD5", nRecBD5, 5, nil, .f., .f., .t.)
		PLSM190Pro(,,,,,,,,,,,.f.,.t.,BCI->(recno()))
	EndIf

Return


/*/{Protheus.doc} PlsDelGuias
	(Cancela uma guia |Cabeçalho, eventos e composição| )
	@type  Static Function
	@author Thiago Rodrigues
	@since 23/08/2023
	@version version
	@see (links_or_references)
/*/
Static Function PlsDelGuias(cCodOpe,cCodLdp,cCodPEg,cNumero)

	Local lRet 	 := .t.
	Local cAlias := GetNextAlias()

	//Exclui o cabeçalho da guia
	BeginSql Alias cAlias 
		SELECT R_E_C_N_O_ REC
		FROM %table:BD5% BD5
		WHERE BD5_FILIAL = %xfilial:BD5%
		AND   BD5_CODOPE = %Exp:cCodOpe%
		AND   BD5_CODLDP = %Exp:cCodLdp%
		AND   BD5_CODPEG = %Exp:cCodPEg%
		AND   BD5_NUMERO = %Exp:cNumero%
		AND   BD5.%NotDel%
	EndSql

	While !(cAlias)->(Eof())
		
		BD5->(DbGoTo((cAlias)->REC))
		BD5->(RecLock("BD5",.F.))
		BD5->(DbDelete())
		BD5->(MsUnLock())

		(cAlias)->(DbSkip())
	End
	(cAlias)->(DbCloseArea())

	//Exclui os eventos da guia
	BeginSql Alias cAlias 
		SELECT R_E_C_N_O_ REC
		FROM %table:BD6% BD6
		WHERE BD6_FILIAL = %xfilial:BD6%
		AND   BD6_CODOPE = %Exp:cCodOpe%
		AND   BD6_CODLDP = %Exp:cCodLdp%
		AND   BD6_CODPEG = %Exp:cCodPEg%
		AND   BD6_NUMERO = %Exp:cNumero%
		AND   BD6.%NotDel%
	EndSql

	While !(cAlias)->(Eof())

		BD6->(DbGoTo((cAlias)->REC))
		BD6->(RecLock("BD6",.F.))
		BD6->(DbDelete())
		BD6->(MsUnLock())

		(cAlias)->(DbSkip())
	End
	(cAlias)->(DbCloseArea())

	//Exclui a composição dos eventos
	BeginSql Alias cAlias 
		SELECT R_E_C_N_O_ REC
		FROM %table:BD7% BD7
		WHERE BD7_FILIAL = %xfilial:BD7%
		AND   BD7_CODOPE = %Exp:cCodOpe%
		AND   BD7_CODLDP = %Exp:cCodLdp%
		AND   BD7_CODPEG = %Exp:cCodPEg%
		AND   BD7_NUMERO = %Exp:cNumero%
		AND   BD7.%NotDel%
	EndSql

	While !(cAlias)->(Eof())

		BD7->(DbGoTo((cAlias)->REC))
		BD7->(RecLock("BD7",.F.))
		BD7->(DbDelete())
		BD7->(MsUnLock())

		(cAlias)->(DbSkip())
	End
	(cAlias)->(DbCloseArea())

Return lRet


/*/{Protheus.doc} nomeStaticFunction
	(Atualiza os valores de coparticipação)
	@type  Static Function
	@author Thiago Rodrigues
	@since 24/08/2023
	@version version
	@see (links_or_references)
/*/
Static Function PlAtVlrCop()

	Local cAliasBD6  := GetNextAlias()
	Local cAliasBJG  := GetNextAlias()
	Local nVlrTotCop := 0

	BeginSql Alias cAliasBD6 
		SELECT BD6_VLRTPF VLRTPF, 
			BD6_CODPAD CODPAD,
			BD6_CODPRO CODPRO
		FROM %table:BD6% BD6
		WHERE BD6_FILIAL = %xfilial:BD6%
		AND   BD6_CODOPE = %Exp:BD5->BD5_CODOPE%
		AND   BD6_CODLDP = %Exp:BD5->BD5_CODLDP%
		AND   BD6_CODPEG = %Exp:BD5->BD5_CODPEG%
		AND   BD6_NUMERO = %Exp:BD5->BD5_NUMERO%
		AND   BD6.%NotDel%
	EndSql

	While !(cAliasBD6)->(Eof())
		
		nVlrTotCop += (cAliasBD6)->VLRTPF
		
		BeginSql Alias cAliasBJG 
			SELECT R_E_C_N_O_ REC
			FROM %table:BJG% BJG
			WHERE BJG_FILIAL = %xfilial:BJG%
			AND   BJG_CDRELA = %Exp:BJF->BJF_IDENTI%
			AND   BJG_CODPAD = %Exp:(cAliasBD6)->CODPAD%
			AND   BJG_CODPRO = %Exp:(cAliasBD6)->CODPRO%
			AND   BJG.%NotDel%
		EndSql
		
			// Atualiza os valores unitários de coparticipação
		If !(cAliasBJG)->(eof())
			BJG->(DbGoTo((cAliasBJG)->REC))
			BJG->(RecLock("BJG",.F.))
			BJG->BJG_VLRCOP := (cAliasBD6)->VLRTPF
			BJG->(MsUnLock())
		EndIf
		(cAliasBJG)->(DbCloseArea())


		(cAliasBD6)->(DbSkip())
	End
	(cAliasBD6)->(DbCloseArea())

	//Atualiza o total de coparticipação
	If nVlrTotCop > 0 
		BJF->(DbGoTo( BJF->(Recno() )))
		BJF->(RecLock("BJF",.F.))
		BJF->BJF_VLTOCP := nVlrTotCop
		BJF->(MsUnLock())
	EndIf

Return 

/*/{Protheus.doc} PlZerCop
	(Limpa Coparticipação)
	@type  Static Function
	@author Thiago Rodrigues
	@since 24/08/2023
	@see (links_or_references)
/*/
Static Function PlZerCop()

	Local cAliasBJG  := GetNextAlias()

	BeginSql Alias cAliasBJG 
		SELECT R_E_C_N_O_ REC
		FROM %table:BJG% BJG
		WHERE BJG_FILIAL = %xfilial:BJG%
		AND   BJG_CDRELA = %Exp:BJF->BJF_IDENTI%
		AND   BJG.%NotDel%
	EndSql

	// zera os valores de coparticipação
	While !(cAliasBJG)->(eof())
		BJG->(DbGoTo((cAliasBJG)->REC))
		BJG->(RecLock("BJG",.F.))
		BJG->BJG_VLRCOP := 0
		BJG->(MsUnLock())
		(cAliasBJG)->(DbSkip())
	End
	(cAliasBJG)->(DbCloseArea())

Return 


/*/{Protheus.doc} PlPegExist
	(VerIfica se no mês atual já existe um PEG
	com as caracteristicas da guia de Fornecimento direto)
	@type  Static Function
	@author Thiago Rodrigues
	@since 28/08/2023
	@see (links_or_references)
/*/
Static Function PlPegExist(cCodLdp)

	Local lRet       := .t.
	Local cAliasBCI  := GetNextAlias()
	Local cAnoAtual  := SubStr(DtoS(dDatabase),1,4)
	Local cMesAtual  := SubStr(DtoS(dDatabase),5,2)

	BeginSql Alias cAliasBCI 

		SELECT 1
		FROM %table:BCI% BCI
		WHERE BCI_FILIAL = %xfilial:BCI%
		AND   BCI_CODOPE = %Exp:cCodint%
		AND   BCI_TIPGUI = '14'
		AND   BCI_MES    = %Exp:cMesAtual%
		AND   BCI_ANO    = %Exp:cAnoAtual%
		AND   BCI_CODLDP = %Exp:cCodLdp%
		AND   BCI_CODRDA = %Exp:cCodRda%
		AND   BCI.%NotDel%

	EndSql

	If !(cAliasBCI)->(eof()) 
		lRet := .f.  //Irá criar a guia no PEG existente
	EndIf

	(cAliasBCI)->(DbCloseArea())

Return lRet


/*/{Protheus.doc} PlGerReqfD
Gera/Estorna requisicao de estoque
@type function
@version 12.1.2410
@author claudiol
@since 10/23/2024
@param cOper, character, 1=Requisicao;2=Estorno
@return logical, .T. ok   .F. nok
/*/
Function PlGerReqfD(cOper,lAuto)

local lRet:= .T.

default cOper:= '1' //1=Requisicao;2=Estorno
default lAuto:= .F.

FwMsgRun(, {|| lRet := GerReqfD(cOper,lAuto) },"Processando", iif(cOper=="1","Gerando", "Estornando") + " Requisição ...")

Return(lRet)


/*/{Protheus.doc} GerReqfD
Gera/Estorna requisicao de estoque
@type function
@version 12.1.2410
@author claudiol
@since 10/23/2024
@param cOper, character, 1=Requisicao;2=Estorno
@return logical, .T. ok   .F. nok
/*/
Static Function GerReqfD(cOper,lAuto)

local aAreOld	:= {SD3->(GetArea()),GetArea()}
local cErrLog	:= ""
local lRet:= .T.
local aCabec:= {}
local aItens:= {}
local cTipMov:= ""
local cCenCus:= ""
local cDocReq:= ""

default lAuto:= .F.

//verIfica se ja existe a requisicao
if cOper == '1'
	if empty(BJF->BJF_CODPEG)
		Help(nil, nil , STR0006, nil, "Não existe Guia criada" + CRLF + "para este fornecimento!", 1, 0, nil, nil, nil, nil, nil, {} )
		return(.F.)
	endIf

	if !empty(BJF->BJF_DOCREQ)
		Help(nil, nil , STR0006, nil, "Já existe requisição criada" + CRLF + "para este fornecimento!" + CRLF + "Requisição: " + cValToChar(BJF->BJF_DOCREQ) , 1, 0, nil, nil, nil, nil, nil, {} )
		return(.F.)
	endIf
elseif cOper == '2'
	if empty(BJF->BJF_DOCREQ)
		Help(nil, nil , STR0006, nil, "Não existe requisição criada" + CRLF + "para este fornecimento!", 1, 0, nil, nil, nil, nil, nil, {} )
		return(.F.)
	endIf
endif

if !FwIsInCallStack("PlIncGuIfD") .and. !FwIsInCallStack("PlCanGuIfD")
	if !lAuto .and. !ApMsgYesNo("Confirma " + iif(cOper=='1','Geração','Estorno') + ' Requisição de Estoque?',"Atenção")
		return(.F.)
	endif

	if cOper=='1'
		//parametros para gerar requisicao de estoque
		if !lAuto .and. !(TelaPerg("PLSFORDIR"))
			return(.F.)
		endif
	endif
endif

lMsErroAuto		:= .F.
lMsHelpAuto		:= .T.

if cOper=='1' //requisicao

	SD3->(dbSetOrder(2))
	while .T.
		cDocReq:= NextNumero("SD3",2,"D3_DOC",.T.)
		if !(SD3->(msSeek(xFilial()+cDocReq)))
			exit
		endif
	enddo

	cTipMov:= MV_PAR01
	cCenCus:= MV_PAR02

	aadd(aCabec, {"D3_DOC" 		, cDocReq	, NIL})
	aadd(aCabec, {"D3_TM" 		, cTipMov 	, NIL})
	aadd(aCabec, {"D3_CC" 		, cCenCus	, NIL})
	aadd(aCabec, {"D3_EMISSAO" 	, ddatabase	, NIL})
 
	aItens:= ItensReq(@cErrLog)

	//avalia se tem erros de validacao
	if empty(cErrLog)
		MSExecAuto({|x,y,z| MATA241(x,y,z)},aCabec,aItens,3) //inclusao
	else
		cDocReq:= ""
	endif

elseif cOper=='2' //estorno

	cDocReq:= BJF->BJF_DOCREQ

	SD3->(dbSetOrder(2))
	if SD3->(dbSeek(xFilial()+cDocReq))
		aCabec := { {"D3_DOC" ,SD3->D3_DOC,Nil}}
	
		MSExecAuto({|x,y,z| MATA241(x,y,z)},aCabec,Nil,6) //estorno
	endif

	cDocReq:= ""
endif

if lMsErroAuto
	lRet:= .F.
	cErrLog:= MemoRead(NomeAutoLog())
	Ferase(NomeAutoLog())
	cDocReq:= ""
endif

//atualiza doc. requisicao
BJF->(recLock("BJF",.f.))
BJF->BJF_DOCREQ := cDocReq
BJF->(msUnLock())

if !empty(cErrLog)
	cErrLog:= iif(cOper=='1',"REQUISIÇÃO NÃO GERADA. AVALIE O MOTIVO DA NÃO GERAÇÃO E GERE MANUALMENTE A REQUISIÇÃO A PARTIR DO MENU:","ESTORNO DA REQUISIÇÃO NÃO GERADA:") + CRLF + cErrLog
	ApMsgAlert(cErrLog,"Atenção")
elseif !FwIsInCallStack("PlIncGuIfD") .and. !FwIsInCallStack("PlCanGuIfD")
	cMsgHlp:= iif(cOper=='1', "gerada", "estornada")
	ApMsgInfo('Requisição ' + cMsgHlp + ' com sucesso!', STR0006)
endif

aEval(aAreOld, {|x| RestArea(x) }) 

Return(lRet)


/*/{Protheus.doc} ItensReq
Carrega itens para requisicao estoque
@type function
@version 12.1.2410
@author claudiol
@since 10/23/2024
@return array, aRet
/*/
Static Function ItensReq(cErrLog)

	local aItem   := {}
	local aItens  := {}
	local cErrPrd := ""
	local cUnid   := ""
	local cLocal  := ""
	local cCodPrd := ""
	local nQuant  := 0

	local cAliasBJG  := GetNextAlias()

	beginSql Alias cAliasBJG 
		SELECT BJG_CODPAD, BJG_CODPRO, BR8_CODPRD, BJG_QUANTI
		FROM %table:BJG% BJG
		INNER JOIN %table:BR8% BR8
			ON 	BJG_CODPAD=BR8_CODPAD 
			AND BJG_CODPRO=BR8_CODPSA
		WHERE BJG_FILIAL = %xfilial:BJG%
		AND   BR8_FILIAL = %xfilial:BR8%
		AND   BJG_CDRELA = %Exp:BJF->BJF_IDENTI%
		AND   BJG.%NotDel%
		AND   BR8.%NotDel%
	endSql

	while !(cAliasBJG)->(eof())
		cCodPrd	:= (cAliasBJG)->BR8_CODPRD
		nQuant	:= (cAliasBJG)->BJG_QUANTI

		if empty(cCodPrd)
			cErrPrd:= "=> Tabela: " + (cAliasBJG)->BJG_CODPAD + " Procedimento: " + (cAliasBJG)->BJG_CODPRO + CRLF
			cErrPrd+= iif(empty(cCodPrd),"Código do Produto não informado (BR8_CODPRD)!" + CRLF,"")
		endif

		SB1->(dbSetOrder(1))
		if SB1->(msseek(xfilial("SB1")+cCodPrd))
			cUnid	:= SB1->B1_UM
			cLocal	:= iif(empty(MV_PAR03), SB1->B1_LOCPAD, MV_PAR03)

			cErrPrd+= iif(empty(cUnid)	,"Unidade não informado (B1_UM)!" + CRLF,"")
			cErrPrd+= iif(empty(cLocal)	,"Armazem do Produto não informado no parametro ou no campo (B1_LOCPAD)!" + CRLF,"")
		endif

		aItem:= {}
		aadd(aItem, {"D3_COD" 	,cCodPrd 	, NIL})
		aadd(aItem, {"D3_UM" 	,cUnid 		, NIL})
		aadd(aItem, {"D3_QUANT" ,nQuant 	, NIL})
		aadd(aItem, {"D3_LOCAL" ,cLocal 	, NIL})

		Aadd(aItens, aClone(aItem))

		cErrLog+= iif(!empty(cErrPrd), cErrPrd, "")

		(cAliasBJG)->(DbSkip())
	enddo
	(cAliasBJG)->(DbCloseArea())

Return(aItens)


/*/{Protheus.doc} TelaPerg
Perguntas da rotina
@type function
@author claudiol
@since 7/10/2024
@version 12.1.2310
@param cNomRot, characters, descricao
@return logical, lret
/*/
static Function TelaPerg(cNomRot)

	local aParambox	:= {}
	local aRet 		:= {}
	local lRet		:= .T.
	local nX		:= 0

	Private lWhen	:= .T.

	aAdd( aParambox ,{1,"TP Movimento  : "  , Space(03),"@9","ExistCpo('SF5')","SF5","lWhen",20,.T.})	  //01
	aAdd( aParambox ,{1,"Centro Custo: : "	, Space(09),"@9","vazio() .or. ctb105cc()","CTT","lWhen",20,.F.})      //02
	aAdd( aParambox ,{1,"Local         : "  , Space(02),"@!","vazio() .or. ExistCpo('NNR')","NNR","lWhen",20,.F.})	  //03

	//Carrega o array com os valores utilizados na última tela ou valores default de cada campo.
	For nX := 1 To Len(aParamBox)
		aParamBox[nX][3] := ParamLoad(cNomRot,aParamBox,nX,aParamBox[nX][3])
	Next nX

	lRet := ParamBox(aParamBox,"Parâmetros para Movimentação de Estoque",aRet,{|| .T.},{},.T.,Nil,Nil,Nil,cNomRot,.F.,.F.)

	If lRet
		//Carrega perguntas em variaveis usadas no programa
		If ValType(aRet) == "A" .And. Len(aRet) == Len(aParamBox)
			For nX := 1 to Len(aParamBox)
				&("Mv_Par"+StrZero(nX,2)) := aRet[nX]
			Next nX
		endif

		//Salva parametros
		ParamSave(cNomRot,aParamBox,"1")
	endif

return(lRet)
