#Include 'GCPA300.CH'
#Include 'PROTHEUS.CH'
#Include 'FWMVCDEF.CH'

Static aRecCPI := {}
Static lRepact	:= .F.
Static _cJusti  := ""
Static _lUpdSTAta := .F.
Static _cNewSitua := ""
Static _cModelId  := "GCPA300"
Static _bAftFailV := Nil

#DEFINE ST_ANALISE 	"1" //Em Análise
#DEFINE ST_ASSINAT	"2" //Aguardando Assinatura
#DEFINE ST_PUBLICA 	"3" //Publicada
#DEFINE ST_SUSPENS 	"4" //Suspensa
#DEFINE ST_CANCELA 	"5" //Cancelada
#DEFINE ST_FINALIZ 	"6" //Finalizada
#DEFINE ST_AGRDPUB 	"7" //Aguardando Publicação
#DEFINE ST_REMANES 	"8" //Processo Remanescente

#DEFINE CRLF Chr(13)+Chr(10)

PUBLISH MODEL REST NAME GCPA300 SOURCE GCPA300

//-------------------------------------------------------------------
/*/{Protheus.doc} GCPA300
Manutenção da Ata

@author Flavio Lopes Rasta
@since 06/11/2013
@version P11
@return nil
/*/
//-------------------------------------------------------------------
Function GCPA300()
Local oBrowse := FWMBrowse():New()

oBrowse:SetAlias('CPH')
oBrowse:SetDescription(STR0001)//'Manutenção da Ata'
oBrowse:AddLegend( "CPH_STATUS=='1'", "BLUE"  ,  STR0002)	//'Em Análise'
oBrowse:AddLegend( "CPH_STATUS=='2'", "GRAY"  ,  STR0003)	//'Aguardando Assinatura'
oBrowse:AddLegend( "CPH_STATUS=='3'", "GREEN",   STR0004)	//'Publicada'
oBrowse:AddLegend( "CPH_STATUS=='4'", "YELLOW" , STR0005)	//'Suspensa'
oBrowse:AddLegend( "CPH_STATUS=='5'", "RED"  ,   STR0006)	//'Cancelada'
oBrowse:AddLegend( "CPH_STATUS=='6'", "BLACK"  , STR0007)	//'Finalizada'
oBrowse:AddLegend( "CPH_STATUS=='7'", "ORANGE"  ,STR0008)	//'Aguardando Publicação'
oBrowse:AddLegend( "CPH_STATUS=='8'", "BROWN"   ,STR0022)	//'Processo Remanescente'

oBrowse:Activate()
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Definição do menu

@author Flavio Lopes Rasta
@since 06/11/2013
@version P11
@return aRotina
/*/
//-------------------------------------------------------------------

Static Function MenuDef()
Local aRotina := {}
Local aRotInc := {}

ADD OPTION aRotInc Title STR0066 	Action 'GCP300Incl(1)'	OPERATION MODEL_OPERATION_INSERT	ACCESS 0	//'Por Item'
ADD OPTION aRotInc Title STR0067 	Action 'GCP300Incl(2)'	OPERATION MODEL_OPERATION_INSERT	ACCESS 0	//'Por Lote'

ADD OPTION aRotina Title STR0015	Action 'GCP300Vis()'	OPERATION 2 ACCESS 0									//'Visualizar' 
ADD OPTION aRotina Title STR0001	Action 'GCP300Manu()'	OPERATION MODEL_OPERATION_UPDATE	ACCESS 0			//'Manutenção da Ata'
ADD OPTION aRotina Title STR0016	Action 'GCP300Susp()'	OPERATION MODEL_OPERATION_UPDATE	ACCESS 0			//'Suspender'
ADD OPTION aRotina Title STR0057	Action aRotInc			OPERATION MODEL_OPERATION_INSERT	ACCESS 0	//'Inserir'
ADD OPTION aRotina Title STR0017	Action 'GCP300Retm()'	OPERATION MODEL_OPERATION_UPDATE	ACCESS 0			//'Retomar'
ADD OPTION aRotina Title STR0018	Action 'GCP300Canc()'	OPERATION MODEL_OPERATION_UPDATE	ACCESS 0			//'Cancelar'
ADD OPTION aRotina Title STR0019	Action 'GCP300Publ()'	OPERATION MODEL_OPERATION_UPDATE	ACCESS 0			//'Publicar'
ADD OPTION aRotina TITLE STR0059 	Action 'GCP300Doc'		OPERATION 4 ACCESS 0									//'Conhecimento'
ADD OPTION aRotina Title STR0014	Action 'GCP300MSld()'	OPERATION MODEL_OPERATION_UPDATE	ACCESS 0	//'Manutenção do Saldo'
ADD OPTION aRotina Title STR0064 	Action 'GCP300GeNE()' 	OPERATION MODEL_OPERATION_INSERT ACCESS 0		//'Gerar Nota de Empenho'
ADD OPTION aRotina Title STR0065	Action 'GCPA300Prz()'	OPERATION MODEL_OPERATION_UPDATE	ACCESS 0	//'Aditamento'
ADD OPTION aRotina Title STR0091 	Action 'GCP300Rep()'	OPERATION MODEL_OPERATION_UPDATE	ACCESS 0	//'Repactuação'

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

@author Flavio Lopes Rasta
@since 06/11/2013
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function ModelDef()
	Local oStruCPH	:= FWFormStruct(1, 'CPH')// Cabeçalho da Ata
	Local oStruCPY	:= FWFormStruct(1, 'CPY')// Produtos Licitados
	Local oStruCPZ	:= FWFormStruct(1, 'CPZ')// Licitantes
	Local oStruCPI	:= FWFormStruct(1, 'CPI')// Orgão da Ata
	Local oStruCPN	:= FWFormStruct(1, 'CPN', {|cCampo| !AllTrim(cCampo) $ "CPN_NUMATA"} )//Histórico da Ata
	Local oStruCX3	:= FWFormStruct(1, 'CX3')// Ata x Solicitação de Compra
	Local oStruCX6	:= Nil
	Local oModel	:= Nil
	Local lLote		:= .F.
	Local cOwner 	:= ""
	Local cOwnerCPZ	:= ""
	Local aRelatCPY := {}
	Local cKeyCPY	:= ""
	Local aRelatCPZ := { {'CPZ_FILIAL','xFilial("CPZ")'},{ 'CPZ_NUMATA', 'CPH_NUMATA' } }
	Local aRelatCX3 := { {'CX3_FILIAL','xFilial("CX3")'},{ 'CX3_NUMATA', 'CPH_NUMATA' }, { 'CX3_CODPRO', 'CPY_CODPRO' } }
	Local aRelatCPI := 	{ {'CPI_FILIAL'	,'xFilial("CPI")'},{ 'CPI_CODEDT', 'CPH_CODEDT' }, { 'CPI_NUMPRO', 'CPH_NUMPRO' },{ 'CPI_NUMATA', 'CPH_NUMATA' },{ 'CPI_CODPRO', 'CPY_CODPRO' } }
	Local bCommit	:= {|oModel|GCP300Grv(oModel)}
	Local bPosValid := {|oModel|GCP300PVLD(oModel)}
	Local bPreVldCPY:= {|oModelGrid, nLine, cAction, cField|GCP300LCpi(oModelGrid, nLine, cAction, cField)}
	Local bPreVldCPI:= {|oModelGrid, nLine, cAction, cField|A300PreCPIN(oModelGrid, nLine, cAction, cField)}
	Local bPosVldCPI:= {|oModel| A300CPIN(oModel) }
	Local bActivate := {|oModel| GCP300Ini(oModel)}
	Local bDeActivte:= {|oModel| GC300DeAct(oModel)}
	Local bVldActive:= {|oModel| GCP300VldA( oModel ) }
	Local bTrigNome	:= {|a,b,c|USRRETNAME(c)}

	If (G300MdlId() != "GCPA301")
		G300MdlId(.T., "GCPA300")
	EndIf
	lLote := (G300MdlId() == "GCPA301")

	if lLote
		oStruCX6 := FWFormStruct(1, 'CX6')	// Lote CX6
	endif

	oStruCPI:AddField( ;                                                  
							AllTrim('') , ; 			// [01] C Titulo do campo
							AllTrim('') , ; 			// [02] C ToolTip do campo
							'CPI_LEGEND' , ;            // [03] C identificador (ID) do Field
							'C' , ;                     // [04] C Tipo do campo
							50 , ;                      // [05] N Tamanho do campo
							0 , ;                       // [06] N Decimal do campo
							NIL , ;                     // [07] B Code-block de validação do campo
							NIL , ;                     // [08] B Code-block de validação When do campo
							NIL , ;                     // [09] A Lista de valores permitido do campo
							NIL , ;                     // [10] L Indica se o campo tem preenchimento obrigatório
							FwBuildFeature( STRUCT_FEATURE_INIPAD, "A300CPILeg()" ) , ;  		// [11] B Code-block de inicializacao do campo
							NIL , ;                     // [12] L Indica se trata de um campo chave
							NIL , ;                     // [13] L Indica se o campo pode receber valor em uma operação de update.
							.T. )                       // [14] L Indica se o campo é virtual
	
	oStruCPH:AddField( ;                                                   
								STR0070 , ; 					// [01] C Titulo do campo
								AllTrim('') , ; 				// [02] C ToolTip do campo
								'CPH_AUTO' , ;              	// [03] C identificador (ID) do Field
								'C' , ;                     	// [04] C Tipo do campo
								1 , ;                      	// [05] N Tamanho do campo
								NIL , ;							// [06] N Decimal do campo
								NIL , ;                     	// [07] B Code-block de validação do campo
								NIL , ;                     	// [08] B Code-block de validação When do campo
								NIL , ;                     	// [09] A Lista de valores permitido do campo
								NIL , ;                     	// [10] L Indica se o campo tem preenchimento obrigatório
								FwBuildFeature( STRUCT_FEATURE_INIPAD, "'0'" )  			,;	// [11] B Code-block de inicializacao do campo
								NIL , ;                     	// [12] L Indica se trata de um campo chave
								NIL , ;                     	// [13] L Indica se o campo pode receber valor em uma operação de update.
									.T. )                       // [14] L Indica se o campo é virtual
	oStruCPN:AddTrigger('CPN_USER', 'CPN_NMUSER',/*bCondicao*/, bTrigNome)


	oModel	:= MPFormModel():New(G300MdlId(),/*bPreValidacao*/, bPosValid, bCommit, /*bCancel*/ )

	oModel:AddFields('CPHMASTER'  ,  /*cOwner*/  ,oStruCPH, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
	oModel:AddGrid(  'CPNDETAIL'	, 'CPHMASTER'  ,oStruCPN)
	oModel:SetRelation('CPNDETAIL', { {'CPN_FILIAL','xFilial("CPN")'},{ 'CPN_NUMATA', 'CPH_NUMATA' }}, CPN->(IndexKey(1)) )
	
	If lLote
		oModel:AddGrid( 'CX6DETAIL' , 'CPHMASTER' , oStruCX6 , /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
		oModel:SetRelation( 'CX6DETAIL' , { { 'CX6_FILIAL' , 'xFilial("CX6")' } , { 'CX6_NUMATA' , 'CPH_NUMATA' } } , CX6->( IndexKey(1) ) )

		cOwner		:= "CX6DETAIL"
		cOwnerCPZ	:= "CX6DETAIL"
		aRelatCPY := { { 'CPY_FILIAL' , 'xFilial("CPY")' } , { 'CPY_NUMATA' , 'CPH_NUMATA' } , { 'CPY_LOTE' , 'CX6_LOTE' } }
		cKeyCPY := CPY->(IndexKey(2))//CPY_FILIAL+CPY_NUMATA+CPY_LOTE+CPY_CODPRO

		aAdd(aRelatCPZ,{'CPZ_LOTE','CX6_LOTE'})

		aSize(aRelatCX3,4)
		aIns(aRelatCX3,3)
		aRelatCX3[3] := {'CX3_LOTE','CX6_LOTE'}
		
		aAdd(aRelatCPI,{'CPI_LOTE','CX6_LOTE'})
	Else
		cOwner 		:= "CPHMASTER"
		cOwnerCPZ	:= "CPYDETAIL"
		aRelatCPY :={ {'CPY_FILIAL','xFilial("CPY")'},{ 'CPY_NUMATA', 'CPH_NUMATA' }}	
		cKeyCPY := CPY->(IndexKey(1))//CPY_FILIAL+CPY_NUMATA+CPY_CODPRO	
		aAdd(aRelatCPZ,{ 'CPZ_CODPRO', 'CPY_CODPRO' })
	EndIf
	
	oModel:AddGrid('CPYDETAIL'	, cOwner  		,oStruCPY, bPreVldCPY		,/*bPosValidacao*/	, /*bCarga*/ )
	oModel:AddGrid('CPZDETAIL'	, cOwnerCPZ  	,oStruCPZ, /*bPreValidacao*/, /*bPosValidacao*/	, /*bCarga*/ )
	oModel:AddGrid('CX3DETAIL'	, 'CPYDETAIL'  	,oStruCX3, /*bPreValidacao*/, /*bPosValidacao*/	, /*bCarga*/ )
	oModel:AddGrid('CPIDETAIL'	, 'CPYDETAIL' 	,oStruCPI, bPreVldCPI		, bPosVldCPI		, /*bCarga*/ )

	//Relacionamentos
	oModel:SetRelation('CPYDETAIL' 	, aRelatCPY, cKeyCPY )
	oModel:SetRelation('CPZDETAIL' 	, aRelatCPZ, CPZ->(IndexKey(IIF(lLote,2,1))) )
	oModel:SetRelation('CX3DETAIL'	, aRelatCX3, CX3->(IndexKey(IIF(lLote,2,1))) )
	oModel:SetRelation('CPIDETAIL'	, aRelatCPI, CPI->(IndexKey(1)) )
	
	CPEConfMdl(oModel) //Configura CPEDETAIL em <oModel>, precisa ser chamado após a configuração do submodelo CPIDETAIL

	If !FwIsInCallStack("GCP300Vis") .And. !G300SitAta()
		If lLote .And. oModel:GetModel('CX6DETAIL'):HasField("CX6_STATUS")
			oModel:GetModel('CX6DETAIL'):SetLoadFilter({{'CX6_STATUS',"{' ','1'}",MVC_LOADFILTER_IS_CONTAINED }})//Filtro para verificar somente produtos válidos		
		EndIf
		oModel:GetModel('CPYDETAIL'):SetLoadFilter({{'CPY_STATUS',"{' ','1'}",MVC_LOADFILTER_IS_CONTAINED }})//Filtro para verificar somente produtos válidos		
	EndIf

	//Submodelo não será gravado se estiver sendo gerado a partir do processo licitatório
	oModel:GetModel('CPIDETAIL'):SetOnlyQuery(IsInCallStack('GCP200SRP'))

	//Modelos não obrigatórios
	oModel:GetModel( 'CPZDETAIL' ):SetOptional(.T.) 
	oModel:GetModel( 'CPNDETAIL' ):SetOptional(.T.)
	oModel:GetModel( 'CX3DETAIL' ):SetOptional(.T.)

	oModel:GetModel('CPIDETAIL'):SetUniqueLine( { 'CPI_CODORG' } )
	oModel:GetModel('CPYDETAIL'):SetUniqueLine( { 'CPY_CODPRO' } )
	oModel:GetModel('CPZDETAIL'):SetUniqueLine( { 'CPZ_TIPO', 'CPZ_CODIGO', 'CPZ_LOJA' } )
	oModel:GetModel('CPIDETAIL'):SetUniqueLine( { 'CPI_CODORG' } )

	//Descrições
	oModel:SetDescription( STR0001 )	//'Manutenção da Ata'
	oModel:GetModel( 'CPYDETAIL' ):SetDescription( STR0010 )	//'Produtos'
	oModel:GetModel( 'CPZDETAIL' ):SetDescription( STR0011 )	//'Licitantes'
	oModel:GetModel( 'CX3DETAIL' ):SetDescription( STR0068 )	//'Solicitações'
	oModel:GetModel( 'CPIDETAIL' ):SetDescription( STR0071 )	//'Orgãos'
	if lLote
		oModel:GetModel( 'CX6DETAIL' ):SetDescription( STR0106 )//Lotes
	endif

	oModel:SetVldActive(bVldActive)
	oModel:SetActivate(bActivate)
	oModel:SetDeActivate(bDeActivte)
Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição do interface

@author Flavio Lopes Rasta
@since 06/11/2013
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function ViewDef()
	Local oView		:= Nil
	Local oModel 	:= Nil
	Local oStruCPH	:= Nil
	Local oStruCPY	:= FWFormStruct(2, 'CPY', {|cCampo| !( AllTrim(cCampo) $ "CPY_NUMATA, CPY_REMAN, CPY_CODNE, CPY_LOTE" .Or. AllTrim(cCampo) == "CPY_ITEMNE" ) } )
	Local oStruCPZ	:= FWFormStruct(2, 'CPZ', {|cCampo| !AllTrim(cCampo) $ "CPZ_NUMATA, CPZ_CODPRO, CPZ_ITEM, CPZ_DESCON, CPZ_VLUNIT, CPZ_PERCRJ, CPZ_VALATU, CPZ_VLRPRE, CPZ_VALRRJ, CPZ_VALREF, CPZ_LOTE"} )
	Local oStruCPI	:= FWFormStruct(2, 'CPI', {|cCampo| !AllTrim(cCampo) $ "CPI_CODEDT,CPI_NUMPRO,CPI_CODNAT,CPI_DESNAT,CPI_CODPRO,CPI_LOTE,CPI_NUMATA"} )
	Local oStruCX3	:= FWFormStruct(2, 'CX3', {|cCampo| !AllTrim(cCampo) $ "CX3_NUMATA, CX3_CODPRO, CX3_LOTE"})
	Local oStrCPN	:= FWFormStruct(2, 'CPN', {|cCampo| !AllTrim(cCampo) $ "CPN_NUMATA"} )
	Local oStrCPE	:= FWFormStruct(2, 'CPE', {|cCampo| !AllTrim(cCampo) $ "CPE_CODORG, CPE_DESORG, CPE_TIPO, CPE_CODEDT, CPE_NUMPRO, CPE_NUMATA, CPE_LOTE, CPE_CODPRO, CPE_OK, CPE_CODNE" .Or. AllTrim(cCampo) == "CPE_ITEMNE" })
	Local oStruCX6  := Nil
	Local aPubliGrp := {STR0047,STR0048,STR0049,STR0050}
	Local aFldsCPH	:= {}
	Local nX		:= 0
	Local cSeq		:= 0
	Local aMdlIds	:= {}
	Local lLote		:= .F.
	Local bFilCpoCPH := Nil	

	If (G300MdlId() != "GCPA301")
		G300MdlId(.T., "GCPA300")
	EndIf
	oModel:= FWLoadModel(G300MdlId())
	lLote := (G300MdlId() == "GCPA301")

	If lLote
		oStruCX6 := FwFormStruct( 2 , 'CX6' , {|cCampo| !AllTrim(cCampo) $ "CX6_NUMATA"} )// Lote
		bFilCpoCPH := {|cCampo| !AllTrim(cCampo) $ "CPH_AVAL, CPH_CODIGO, CPH_LOJA"}		
	Else
		bFilCpoCPH := {|cCampo| !AllTrim(cCampo) $ "CPH_AVAL"}		
	EndIf
	oStruCPH := FWFormStruct(2, 'CPH', bFilCpoCPH)
	

	oStruCPI:AddField( ;                                                            // Ord. Tipo Desc.
												'CPI_LEGEND' , ;                    // [01] C Nome do Campo
												'00' , ;                         // [02] C Ordem
												AllTrim('') , ;				   	// [03] C Titulo do campo
												AllTrim( STR0073 ) , ;   			// [04] C Descrição do campo
												{ STR0073 } , ;           			// [05] A Array com Help
												'C' , ;                          // [06] C Tipo do campo
												'@BMP' , ;                       // [07] C Picture
												NIL , ;                          // [08] B Bloco de Picture Var
												'' , ;                           // [09] C Consulta F3
												.F. , ;                          // [10] L Indica se o campo é evitável
												NIL , ;                          // [11] C Pasta do campo
												NIL , ;                          // [12] C Agrupamento do campo
												NIL , ;                          // [13] A Lista de valores permitido do campo (Combo)
												NIL , ;                          // [14] N Tamanho Maximo da maior opção do combo
												NIL , ;                          // [15] C Inicializador de Browse
												.T. , ;                          // [16] L Indica se o campo é virtual
												NIL )                            // [17] C Picture Variável                                             

	//Remove campos do processo de repactuação de preços
	If !GetRepact()
		oStruCPY:RemoveField('CPY_PERCRJ')
		oStruCPY:RemoveField('CPY_VALRRJ')
	EndIf

	// Deixa de bloquear se for uma inclusão
	If !IsInCallStack("GCP300Incl") .And. !IsInCallStack("GCPA300Prz") 
		// Propriedades
		oStruCPH:SetProperty('*', MVC_VIEW_CANCHANGE, .F.) //Desabilita os campos
		If FunName() == 'GCPA200' .Or. IsInCallStack('GCPA600')
			oStruCPH:SetProperty('CPH_NUMATA', MVC_VIEW_CANCHANGE, .T.) //habilita num Ata
		EndIf
	Else
		oStruCPH:SetProperty('CPH_STATUS', MVC_VIEW_CANCHANGE, .F.) //Desabilita o campo
		oStruCPH:SetProperty('CPH_DTPB1', MVC_VIEW_CANCHANGE, .T.)
		oStruCPH:SetProperty('CPH_CANAL1', MVC_VIEW_CANCHANGE, .T.)
	EndIf

	oStruCPI:SetProperty('CPI_QTDRES', MVC_VIEW_CANCHANGE, .F.)	//Habilita este campo
	oStruCPI:SetProperty('CPI_QTDCON', MVC_VIEW_CANCHANGE, .F.)	//Habilita este campo

	If !IsInCallStack("GCPA300Prz")
		oStruCPI:SetProperty('CPI_SALDO', MVC_VIEW_CANCHANGE, .F.)		//Habilita este campo
	EndIf	

	for nX := 1 to Len(aPubliGrp)// Agrupadores Publicações
		cSeq := cValToChar(nX)	
		oStruCPH:AddGroup( "GRP"+cSeq , aPubliGrp[nX], "" , 1 )//Cria agrupador	
		//Adiciona campos ao Agrupador
		oStruCPH:SetProperty( "CPH_DTPB"  +cSeq, MVC_VIEW_GROUP_NUMBER, "GRP"+cSeq )
		oStruCPH:SetProperty( "CPH_CANAL" +cSeq, MVC_VIEW_GROUP_NUMBER, "GRP"+cSeq )
	next nX

	aFldsCPH := oStruCPH:GetFields()
	for nX := 1 to Len(aFldsCPH)
		If Empty(aFldsCPH[nX, MVC_VIEW_FOLDER_NUMBER])
			aFldsCPH[nX, MVC_VIEW_FOLDER_NUMBER] := "1"
		EndIf
	next nX

	If (G300SitAta() .And. G300NewSit() == ST_CANCELA)//É mudança de situação da Ata p/ Cancelada
		If lLote
			If oStruCX6:HasField("CX6_STATUS")
				oStruCX6:RemoveField("CX6_STATUS") //Remove o campo da view pois não é mais possível cancelar o lote inteiro, apenas item a item
			EndIf		
		EndIf
		oStruCPY:SetProperty("CPY_STATUS",MVC_VIEW_ORDEM	,"01")//Deve ser o primeiro campo
		oStruCPY:SetProperty("CPY_STATUS",MVC_VIEW_CANCHANGE,.T.)
		oStruCPY:SetProperty("CPY_STATUS",MVC_VIEW_COMBOBOX	,CBoxCpySt())
	ElseIf(FwIsInCallStack("GCP300Vis"))
		oStruCPY:SetProperty("CPY_STATUS",MVC_VIEW_ORDEM	,"01")
		If lLote .And. oStruCX6:HasField("CX6_STATUS")
			oStruCX6:SetProperty("CX6_STATUS",MVC_VIEW_ORDEM	,"01")			
		EndIf
	Else
		oStruCPY:RemoveField("CPY_STATUS")
		If lLote .And. oStruCX6:HasField("CX6_STATUS")
			oStruCX6:RemoveField("CX6_STATUS")
		EndIf
	EndIf

	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField('CPHMASTER' , oStruCPH )
	oView:AddGrid('VIEW_CPY'	, oStruCPY	, 'CPYDETAIL')
	oView:AddGrid('VIEW_CPZ'	, oStruCPZ	, 'CPZDETAIL')
	oView:AddGrid('VIEW_CPI'	, oStruCPI	, 'CPIDETAIL')
	oView:AddGrid('VIEW_CPN'	, oStrCPN	, 'CPNDETAIL') 
	oView:AddGrid('VIEW_CX3'	, oStruCX3	, 'CX3DETAIL') 

	oView:CreateHorizontalBox( 'TOPO', 26)
	oView:CreateHorizontalBox( 'MEIO', 34)
	oView:CreateHorizontalBox( 'INFERIOR', 40)

	//Folder do Topo
	oView:CreateFolder( 'FLDTOPO', 'CPHMASTER')
	oView:AddSheet('FLDTOPO','FLDHIST',STR0046) //'Histórico da Ata'
	oView:CreateHorizontalBox( 'HIST', 100, /*owner*/, /*lUsePixel*/, 'FLDTOPO', 'FLDHIST')	//'Participantes'
	oView:SetOwnerView('VIEW_CPN','HIST')

	//Folder do Meio
	oView:CreateVerticalBox( 'MEIOVERT', 100, 'MEIO')
	oView:CreateFolder( 'FLMEIO', 'MEIOVERT')

	If lLote		
		oView:AddGrid( 'VIEW_CX6' , oStruCX6 , 'CX6DETAIL' )
		oView:AddSheet( 'FLMEIO' , 'FLLOTES' , STR0106 )	//Lotes
		oView:CreateVerticalBox( 'LOTES' , 100 , , , 'FLMEIO' , 'FLLOTES' )
		oView:SetOwnerView( 'VIEW_CX6' 		, 'LOTES' 		)
		oView:EnableTitleView( 'VIEW_CX6' )
	EndIf

	oView:AddSheet('FLMEIO','FLPRODUTOS',STR0010)	//'Produtos'
	oView:CreateVerticalBox( 'PRODUTOS', 100,,,'FLMEIO','FLPRODUTOS')

	oView:AddSheet('FLMEIO','FLSOLICITA',STR0068)	//'Solicitações'
	oView:CreateVerticalBox( 'SOLICITA', 100,,,'FLMEIO','FLSOLICITA')

	//Folder de Baixo
	oView:CreateVerticalBox( 'INFERIORVERT', 100, 'INFERIOR')

	oView:CreateFolder( 'FLINFERIOR', 'INFERIORVERT')
	oView:AddSheet('FLINFERIOR','FLLICITANTES',STR0011)	//'Licitantes'
	oView:CreateVerticalBox( 'LICITA', 100,,,'FLINFERIOR','FLLICITANTES')

	oView:AddSheet('FLINFERIOR','FLPARTICIPA' ,STR0012)
	oView:AddGrid('VIEW_CPE' , oStrCPE,'CPEDETAIL')
			
	oView:CreateHorizontalBox( 'BPART', 100, /*owner*/, /*lPixel*/, 'FLINFERIOR', 'FLPARTICIPA')
	oView:CreateFolder( 'FLPART', 'BPART')
	oView:AddSheet('FLPART','FLORGP',STR0071)
	oView:CreateHorizontalBox( 'PARTI', 100, /*owner*/, /*lUsePixel*/, 'FLPART', 'FLORGP')
	oView:AddSheet('FLPART','FLSLDP',STR0074)
	oView:CreateHorizontalBox( 'SLDP', 100, /*owner*/, /*lUsePixel*/, 'FLPART', 'FLSLDP')	

	//Propritários
	oView:SetOwnerView('CPHMASTER' , 'TOPO')
	oView:SetOwnerView('VIEW_CPY' , 'PRODUTOS')
	oView:SetOwnerView('VIEW_CPZ' , 'LICITA')
	oView:SetOwnerView('VIEW_CPI', 'PARTI')
	oView:SetOwnerView('VIEW_CPE','SLDP')
	oView:SetOwnerView('VIEW_CX3','SOLICITA')

	//Títulos
	oView:EnableTitleView('VIEW_CPY')
	oView:EnableTitleView('VIEW_CPZ')
	oView:EnableTitleView('VIEW_CPI')
	oView:EnableTitleView('VIEW_CPE')
	oView:EnableTitleView('VIEW_CX3')

	oView:AddIncrementField('VIEW_CPE' , 'CPE_ITEM' )
	oView:AddIncrementField('VIEW_CPZ' , 'CPZ_ITEM' )
	oView:AddIncrementField('VIEW_CPY' , 'CPY_ITEM' )

	If(	G300SitAta() .And. G300NewSit() == ST_CANCELA)//É mudança de situação da Ata p/ Cancelada	
		aMdlIds := oView:GetModelsIds()

		for nX := 1 to Len(aMdlIds)			
			If !(aMdlIds[nX] $ "CPYDETAIL|CX6DETAIL")
				oView:SetViewProperty(aMdlIds[nX], "ONLYVIEW")//Define que os campos do formulário não permitem edição de dados
			EndIf
		next nX
	EndIf

	oView:showUpdateMsg(!G300SitAta())

	oView:SetAfterViewActivate({||GCPA300AtLg(oModel)} )

	oView:AddUserButton(STR0051, 'CLIPS', {|oView|  A300Legend()})//"Legenda"

	If IsInCallStack("GCP300Incl")
		oView:AddUserButton( STR0068 , 'CLIPS' , {|oView|  GCP300CaSC(oModel)} )	//'Solicitações'
	EndIf

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} GCP300Bloc
Rotina para bloqueio de modelos - Necessidade de bloquear caronas de acordo com o estado

@author guilherme.pimentel
@param oModel - modelo Ativo
@since 20/11/2013
@return lRet
@version 1.0
/*/
//-------------------------------------------------------------------
Function GCP300Bloc(oModel)
Local lRet		:= .T.
Local lPerm		:= .F.
Local oModelCPH := oModel:GetModel('CPHMASTER')
Local oModelCPI := oModel:GetModel('CPIDETAIL')
Local oModelCPE := oModel:GetModel('CPEDETAIL')
Local cRegra	:= ""
Local cOrgao	:= ""
Local cUF		:= ""
Local aSisFil	:= {}
Local nX		:= 0
Local cAliasTmp := GetNextAlias()

CO1->(dbSetOrder(1))
If CO1->(dbSeek(xFilial("CO1")+oModelCPH:GetValue("CPH_CODEDT")+oModelCPH:GetValue("CPH_NUMPRO")))
	cRegra	:= CO1->CO1_REGRA
	cOrgao	:= CO1->CO1_CODORG
EndIf

If CPA->(DbSeek(xFilial('CPA')+cOrgao))
	cUF := CPA->CPA_UF
	If CPK->(DbSeek(xFilial('CPK')+cRegra+cUF))
		lPerm := CPK->CPK_CARONA == '2'
		lRet := .T.
	EndIf
EndIf

If Empty(oModelCPH:GetValue('CPH_DTPB1'))
	lPerm := .T.	
	oModelCPE:SetNoUpdateLine(.T.)
	oModelCPE:SetNoInsertLine(.T.)
	oModelCPE:SetNoDeleteLine(.T.)
EndIf

If lRet
	If IsInCallStack('GCP300Manu')
		If !Empty(oModelCPH:GetValue("CPH_CODORG"))			
		
			BeginSQL Alias cAliasTmp
				SELECT CPA.CPA_SISFIL
				FROM 
				%table:CPA% CPA
				WHERE
				CPA.CPA_FILIAL = %exp:xFilial("CPA")% AND 
				CPA.CPA_CODORG = %exp:oModelCPH:GetValue("CPH_CODORG")% AND
				CPA.%NotDel%
			EndSql
			
			While !(cAliasTmp)->(Eof())
				aAdd(aSisFil, (cAliasTmp)->CPA_SISFIL)
				(cAliasTmp)->(dbSkip())
			EndDo
			
			(cAliasTmp)->(DbCloseArea())
			
			For nX := 1 To Len(aSisFil)
				If Substr(cNumEmp, Len(cEmpAnt)+1, Len(cFilAnt)) <> aSisFil[nX]
					lPerm := .T.
					Exit
				EndIf
			Next nX
			
			oModelCPI:SetNoInsertLine(lPerm)
		EndIf
	Else
		oModelCPI:SetNoInsertLine(lPerm)
	EndIf
EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} GCP300Dlg()
Rotina para criação da tela onde será informada a Justificativa

@author Matheus Lando Raimundo
@since 12/11/2013
@version P11
@return aRotina
/*/
//-------------------------------------------------------------------
Function GCP300Dlg(cJust, cCabecalho, lPublic, dDataDe, cCanal)
Local oDlg		:= Nil
Local oFont1	:= Nil      
Local lRet		:= .F.
Local oSize	:= Nil

Default lPublic := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Dialog                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Define Font oFont1 Name "Consolas" Size 07,17
Define MsDialog oDlg Title cCabecalho From 0,0 To 220,400 Of oDlg Pixel 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Calcula dimensões                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSize := FwDefSize():New(.T.,,,oDlg)        

oSize:AddObject( "CORPO" ,  100, 100, .T., .T. ) // Totalmente dimensionavel

oSize:lProp 	:= .T. // Proporcional             
oSize:aMargins 	:= { 3, 3, 3, 3 } // Espaco ao lado dos objetos 0, entre eles 3 
		
oSize:Process() 	   // Dispara os calculos 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Calcula dimensões                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

oSize2 := FwDefSize():New(.T.,,,oDlg)

oSize2:aWorkArea := oSize:GetNextCallArea( "CORPO" )       

oSize2:AddObject( "GET" ,  100, 100, .T., .T. ) // Totalmente dimensionavel
oSize2:lProp 	:= .T. // Proporcional             
oSize2:aMargins 	:= { 3, 3, 3, 3 } // Espaco ao lado dos objetos 0, entre eles 3 
		
oSize2:Process() 	   // Dispara os calculos 

If !lPublic
	@ oSize:GetDimension("CORPO","LININI") ,oSize:GetDimension("CORPO","COLINI")  To oSize:GetDimension("CORPO","LINEND") ,oSize:GetDimension("CORPO","COLEND") LABEL  OF oDlg PIXEL 
	@ oSize2:GetDimension("GET","LININI") ,oSize2:GetDimension("GET","COLINI")  Get oObs  Var cJust Multiline Text Font oFont1 Size oSize2:GetDimension("GET","XSIZE") ,oSize2:GetDimension("GET","YSIZE")  Valid !Empty(cJust)  Pixel Of oDlg
	
	ACTIVATE MSDIALOG oDlg CENTER ON INIT EnchoiceBar(oDlg,{|| lRet := .T. ,oDlg:End()},{|| lRet := .F., oDlg:End()})

Else
	
	@ oSize:GetDimension("CORPO","LININI") ,oSize:GetDimension("CORPO","COLINI")  To oSize:GetDimension("CORPO","LINEND") ,oSize:GetDimension("CORPO","COLEND") LABEL  OF oDlg PIXEL
	
	@ oSize2:GetDimension("GET","LININI"),oSize2:GetDimension("GET","LININI") SAY STR0021+":" OF oDlg PIXEL		//'Data de Publicação'  
	@ oSize2:GetDimension("GET","LININI")+7,oSize2:GetDimension("GET","LININI") Get oDataDe   Var dDataDe  Font oFont1 Size 50 ,10 Valid /*!Empty(dDataDe) .AND. GCP300VlP(dDataDe)*/ Pixel Of oDlg
	
	@ oSize2:GetDimension("GET","LININI"),oSize2:GetDimension("GET","LININI")+70  SAY STR0069 + ":" OF oDlg PIXEL		//'Canal de Publicação'  
	@ oSize2:GetDimension("GET","LININI")+7,oSize2:GetDimension("GET","LININI")+70 MSGet oCanal  Var cCanal Font oFont1 Size 50 ,10 Valid /*!Empty(Trim(cCanal))*/ Of oDlg PIXEL  
	
	ACTIVATE MSDIALOG oDlg CENTER ON INIT EnchoiceBar(oDlg,{||  lRet := A300VlOk(dDataDe, cCanal, oDlg) },{|| lRet := .F., oDlg:End()})

EndIf							
						
Return lRet											

//-------------------------------------------------------------------
/*/{Protheus.doc} GCP300AtSt()
Rotina para atualização do Status da Ata

@author Matheus Lando Raimundo
@since 12/11/2013
@version P11
/*/
//-------------------------------------------------------------------
Function GCP300AtSt(cStatus, cJust, lPublic, dDataDe, cTipo, cCanal, oModel, bAvalCancel)
	Local cStAnt	:= ""
	Local cStNovo	:= ""
	Local lLote		:= GCP301Lote()
	Local oModelCPN	:= Nil
	Local oMdlTemp	:= Nil
	Local cMensagem := ""
	Local lAuto		:= .F.
	Local lTelaOk 	:= FwIsInCallStack("GCPA300")//Só exibe mensagem de mudança de situação se for pela tela do GCPA300
	Local lParcCanc := .F.
	Local cSituOrig	:= ""
	Local aButtons	:= {}
	Local aSaveLines:= {}
	Default cJust	:= ""
	Default lPublic := .F.
	Default cTipo	:= "1"
	Default oModel	:= Nil
	Default bAvalCancel := {|x| .T.}	

	G300SitAta(.T., .T.)
	G300NewSit(.T., cStatus)

	If !(lAuto := oModel != Nil)	
		oModel := FwLoadModel(IIF(lLote,"GCPA301", "GCPA300"))
	EndIf

	oModel:SetOperation(MODEL_OPERATION_UPDATE)	

	If oModel:Activate()
		cSituOrig := CPH->CPH_STATUS
		cStAnt := GetDescrSt(CPH->CPH_STATUS)
		cStNovo:= GetDescrSt(cStatus)
		oModelCPN := oModel:GetModel("CPNDETAIL")	

		oModel:LoadValue("CPHMASTER", "CPH_STATUS", cStatus)	
		
		If lPublic
			If Empty(oModel:GetValue("CPHMASTER","CPH_VGATAI"))//Primeira publicação
				oModel:LoadValue("CPHMASTER", "CPH_VGATAI", dDataDe)
				oModel:LoadValue("CPHMASTER", "CPH_VGATAF", YearSum(dDataDe, 1))
			EndIf
			A300GrvPb(dDataDe,cCanal,oModel:GetModel("CPHMASTER"))
		EndIf
		
		If !Empty(oModelCPN:GetValue("CPN_DATA"))
			oModelCPN:AddLine()
		EndIf
		oModelCPN:LoadValue("CPN_DATA"	, dDataBase)
		oModelCPN:LoadValue("CPN_HORA"	, Time())
		oModelCPN:LoadValue("CPN_TIPO"	, cTipo)
		oModelCPN:LoadValue("CPN_ORIGEM", cStAnt)
		oModelCPN:LoadValue("CPN_DESTIN", cStNovo)
		oModelCPN:SetValue("CPN_USER", __cUserId)//SetValue p/ gatilhar o preenchimento do nome(CPN_NMUSER)
		If !Empty(cJust) 
			oModelCPN:LoadValue("CPN_JUST"	, cJust)			
		EndIf

		If (cStatus == ST_CANCELA)
			oMdlTemp	:= oModel:GetModel(IIF(lLote, "CX6DETAIL", "CPYDETAIL"))
			aSaveLines:= FwSaveRows()

			CancelMdl(oMdlTemp,bAvalCancel)

			FWRestRows(aSaveLines)
			FwFreeArray(aSaveLines)
		EndIf

		If (cStatus == ST_CANCELA .And. !(IsBlind() .Or. lAuto))
			aButtons := Array(15,2)
			aEval(aButtons, {|x|x[1] := .T.})
			aButtons[15,1] := .F. //Desabilita botão "Salva e Criar Novo"

			lTelaOk := (FWExecView( STR0109 + " " + cStNovo , oModel:GetId(), oModel:GetOperation(), /*oDlg*/, /*bCloseOnOK*/,/*bOk*/ , /*nPercReducao*/ , aButtons, /*bCancel*/ , /*cOperatId*/, /*cToolBar*/, oModel ) == 0)
			lParcCanc := (lTelaOk .And. cSituOrig == CPH->CPH_STATUS)

			FwFreeArray(aButtons)			
		ElseIf oModel:VldData()
			oModel:CommitData()
		EndIf
	EndIf

	If (oModel:HasErrorMessage() .And. !lAuto)
		Help(" ",1,AllTrim(oModel:GetErrorMessage()[5]),,oModel:GetErrorMessage()[6]+CRLF,1,1)
	ElseIf !IsBlind() .And. lTelaOk
		If lParcCanc
			cMensagem := STR0112//Há itens não cancelados, por conta disso a ata continuará na situação [#1]
			cMensagem := I18N(cMensagem, {cStAnt})
			FWAlertInfo(cMensagem, STR0113)//Cancelamento parcial
		Else
			cMensagem := STR0110//Situação alterada de [#1] para [#2] com sucesso.
			cMensagem := I18N(cMensagem, {cStAnt, cStNovo})
			FWAlertSuccess(cMensagem,STR0111)//Mudança realizada
		EndIf
	EndIf

	If !lAuto		
		If oModel:IsActive()
			oModel:DeActivate()
		EndIf
	EndIf

	G300SitAta(.T., .F.)
	G300NewSit(.T., "")
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} GCP300Susp()
Rotina para suspensão da Ata

@author Matheus Lando Raimundo
@since 12/11/2013
@version P11
@return aRotina
/*/
//-------------------------------------------------------------------
Function GCP300Susp()
	Local cJust := ""

	If GCP300Dlg(@cJust, STR0030)//'Informe a Justificativa da Suspensão da Ata'
		GCP300AtSt(ST_SUSPENS, cJust)
	EndIf
Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} GCP300Canc()
Rotina para cancelamento da Ata

@author Matheus Lando Raimundo
@since 12/11/2013
@version P11
@return aRotina
/*/
//-------------------------------------------------------------------
Function GCP300Canc()
	Local cJust := ""

	If GCP300Dlg(@cJust, STR0031)//'Informe a Justificativa do Cancelamento da Ata'
		GCP300AtSt(ST_CANCELA, cJust)
	EndIf	
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} GCP300Retm()
Rotina para Retomada da Ata

@author Matheus Lando Raimundo
@since 12/11/2013
@version P11
@return aRotina
/*/
//-------------------------------------------------------------------
Function GCP300Retm()
	GCP300AtSt(ST_PUBLICA, "")
Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} GCP300Publ()
Rotina para Publicação da Ata

@author Matheus Lando Raimundo
@since 12/11/2013
@version P11
@return aRotina
/*/
//-------------------------------------------------------------------
Function GCP300Publ(oModel,dDataDe,cCanal)
	Local cJust	:= ""	
	Local lAuto	:= .F.
	Default oModel	:= Nil
	Default dDataDe	:= CToD("//")
	Default cCanal	:= CriaVar('CPH_CANAL1')

	lAuto := (ValType(oModel) == "O")

	If lAuto .Or. (!lAuto .And. GCP300Dlg(, STR0034,.T., @dDataDe, @cCanal))//'Informe a Vigência da Ata'
		GCP300AtSt(ST_PUBLICA, IIF(lAuto, G300GetJus(), cJust), .T.	,dDataDe,/*cTipo*/,cCanal,IIF(lAuto,oModel,Nil))
	EndIf
Return Nil
//-------------------------------------------------------------------
/*/{Protheus.doc} GCP300Doc()
Visualiza o banco de conhecimento conforme permissão usuário.

@author  miguel.santos
@param 	  cUser Usuario Logado
@param   aGrp Grupo associado ao usuario
@return  Nil
@since   22/05/2015
@version 1.0
/*/
//------------------------------------------------------------------
Function GCP300Doc(oModel)
Local cUser		:= AllTrim(RetCodUsr())
Local aGrp			:= UsrRetGrp()
Local cPerm		:= GCP110Doc(cUser,aGrp)

//VARIAVEIS ADICIONADAS DEVIDO A UTILIZAÇÃO NA FUNÇÃO MSDOCUMENT.
Private aRotina	:= MenuDef()
Private cCadastro	:= STR0075

If cPerm == '2'
	MsDocument( 'CPH', CPH->( Recno() ), 2 ) 
ElseIf cPerm == '1'	
	MsDocument( 'CPH', CPH->( Recno()) , 1 )  
Else
	Help(" ",1,"SEMPERM")//Usuário sem permissão para utilizar esta rotina.    
EndIf

Return Nil

/*/{Protheus.doc} GCP300Alt()
Rotina que verifica se a ata não esta finalizada

@author Matheus Lando Raimundo
@since 12/11/2013
@version P11
@return aRotina
/*/
Function GCP300Alt()
	Local lRet := .T.

	If CPH->CPH_STATUS == ST_ANALISE 
		If (G300NewSit() != ST_ASSINAT) //De Em Analise somente pode prosseguir se for para Aguardando Assinatura
			lRet := .F.
			Help(' ', 1, 'A300ATAANA')		//'Não será possível alterar a situação da Ata, pois seu status está: Em Analise'
		EndIf
	ElseIf CPH->CPH_STATUS == ST_ASSINAT
		If (G300NewSit() != ST_AGRDPUB)//De Aguardando Assinatura somente pode prosseguir se for para Aguardando Publicação
			lRet := .F.
			Help(' ', 1, 'A300ATAASS')		//'Não será possível alterar a situação da Ata, pois seu status está: Aguardando Assinatura'			
		EndIf
	ElseIf CPH->CPH_STATUS == ST_PUBLICA
		If G300NewSit() == ST_PUBLICA
			lRet := .F.
			Help(' ', 1, 'A300ATAPUBL')			//'A Ata está Publicada!'
		ElseIf !Empty(CPH->CPH_DTPB4)
			lRet := .F.
			Help(' ', 1, 'A300ATAPUBLMT')			//Foi excedido o limite de 4 publicações.
		EndIf
	ElseIf CPH->CPH_STATUS == ST_SUSPENS
		If IsInCallStack('GCP300Manu')
			lRet := .F.
			Help(' ', 1, 'A300ATASUSALT')		//'Não será possível alterar a situação da Ata, pois seu status está: Suspensa'	
		ElseIf G300NewSit() == ST_SUSPENS
			lRet := .F.
			Help(' ', 1, 'A300ATASUS')	//'A Ata já está suspensa!'
		ElseIf G300NewSit() == ST_PUBLICA .And. !FwIsInCallStack("GCP300Retm")
			lRet := .F.
			Help(' ', 1, 'A300ATASUSP')	//'A Ata está suspensa!'
		Endif
	ElseIf CPH->CPH_STATUS == ST_CANCELA
		lRet := .F.
		Help(' ', 1, 'A300ATACANCEL')		//'Não será possível alterar a situação da Ata, pois seu status está: Cancelada'
	ElseIf CPH->CPH_STATUS == ST_FINALIZ
		lRet := .F.
		Help(' ', 1, 'A300ATAFIN')		//'Não será possível alterar a situação da Ata, pois seu status está: Finalizada'
	ElseIf CPH->CPH_STATUS == ST_REMANES
		lRet := .F.
		Help(' ', 1, 'A300ATAREMA')		//'Não será possível alterar a situação da Ata, pois seu status está: Processo Remanescente'
	EndIf

	If (lRet .And. (CPH->CPH_STATUS <> ST_SUSPENS .And. G300NewSit() == ST_PUBLICA) .And. FwIsInCallStack("GCP300Retm"))		
		Help(' ', 1, 'A300ATASUSR')		//'Não será possível retomar a Ata, pois ela não está suspensa!'
		lRet := .F.
	EndIf

	If lRet .And. !(G300NewSit() == ST_PUBLICA)
		If CPH->CPH_STATUS == ST_AGRDPUB 
			lRet := .F.
			Help(' ', 1, 'A300ATAPUBAG')		//'Não será possível alterar a situação da Ata, pois seu status está: Aguardando Publicacao'
		EndIf
	EndIf

	If lRet .And. !G300SitAta()
		If !(lRet := GP300VIGEX(.F.,.T.))//Exibe apenas o help...
			_bAftFailV := {|| GP300VIGEX(.T.,.F.) }//Apenas atualiza situação
		EndIf
	EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GCP300VldA()
Rotina que valida a abertura da Ata de acordo os meses de publicação.

@author Matheus Lando Raimundo
@since 12/11/2013
@version P11
@return aRotina
/*/
//-------------------------------------------------------------------
Function GCP300VldA( oModel )
	Local lRet := .T.
	Local cCodOrg := ""
	
	If (oModel:GetOperation() == MODEL_OPERATION_UPDATE)
		lRet := GCP300Alt()
	ElseIf oModel:GetOperation() == MODEL_OPERATION_INSERT .And. !(FwIsInCallStack("GCP200Srp") .Or. FwIsInCallStack("A200GerAta")) //Somente se for uma inclusão direta pela rotina
		cCodOrg := SuperGetMV("MV_GCPORG", .T., "")		
		If !(lRet := !Empty(cCodOrg))
			Help('',1,'GCP300GCPORG') // É necessário informar o Código do Órgão atual no parâmetro MV_GCPORG.
		EndIf
	EndIf		
Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} A300CarInd
Verificação individual dos caronas

@author guilherme.pimentel
@since 21/11/2013
@version 1.0
@return lRet
/*/
//-------------------------------------------------------------------

Function A300CarInd()
Local oModel	  := FWModelActive()
Local oModelCPY := oModel:GetModel('CPYDETAIL')
Local oModelCPI	:= oModel:GetModel('CPIDETAIL')
Local lRet := .T.

If oModel:GetId() == 'GCPA300'
	If oModelCPI:GetValue('CPI_QTDLIC') > oModelCPY:GetValue('CPY_QUANT')
		lRet := .F.		
	EndIf
EndIf  

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A300CarTot
Verificação total dos caronas

@author guilherme.pimentel
@since 21/11/2013
@version 1.0
@return lRet
/*/
//-------------------------------------------------------------------

Function A300CarTot()
Local oModel	  := FWModelActive()
Local oModelCPI := oModel:GetModel('CPIDETAIL')
Local oModelCPY := oModel:GetModel('CPYDETAIL')
Local aSaveLines	:= FWSaveRows()
Local nX   := 0
Local nTotQuant := 0
Local lRet := .T.

If oModel:GetId() == 'GCPA300'
	For nX := 1 To oModelCPI:Length()
		oModelCPI:GoLine(nX)
		If !oModelCPI:IsDeleted() .And. oModelCPI:GetValue('CPI_TIPO') == '2'
			nTotQuant += oModelCPI:GetValue('CPI_QTDLIC')
		EndIf	
	Next Nx
	
	If nTotQuant > (oModelCPY:GetValue('CPY_QUANT') * 5)
		lRet := .F.
	EndIf  
EndIf

FWRestRows( aSaveLines )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A300CPIN
Ajuste no tipo do não participante

@author guilherme.pimentel
@since 21/11/2013
@version 1.0
@param oModel
@return lRet
/*/
//-------------------------------------------------------------------

Function A300CPIN(oModel)
Local oMdl   		:= FWModelActive()
Local lRet 		:= .T.

If !IsInCallStack('GCP200SRP') .And. Empty(oModel:GetValue("CPI_QTDLIC"))
	lRet := .F.
	help("",1,"A300QTDLIC") //Quantidade licitada não informada. Favor informe a quantidade.
EndIf
	 
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GCP300Vis()
Função para visualização da Ata de acordo com a avaliação

@author Matheus Lando 
@since 20/11/2013
@version P11
@return aRotina
/*/
//-------------------------------------------------------------------
Function GCP300Vis()
Local cModel	:= Iif( GCP301Lote() , 'GCPA301' , 'GCPA300' )

FWExecView ( '' , cModel , MODEL_OPERATION_VIEW , /*oDlg*/ , {||.T.} , /*bOk*/ , /*nPercReducao*/ , /*aEnableButtons*/ ,  /*bCancel*/ )

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} GCP300Manu()
Função para manutenção da Ata de acordo com a avaliação

@author Matheus Lando 
@since 20/11/2013
@version P11
@return aRotina
/*/
//-------------------------------------------------------------------
Function GCP300Manu()	
	Local cModel := Iif( GCP301Lote() , 'GCPA301' , 'GCPA300' )
	Local lTelaOk:= .T.
	lTelaOk := (FWExecView('', cModel, MODEL_OPERATION_UPDATE , /*oDlg*/ , {||.T.} , /*bOk*/ , /*nPercReducao*/ , /*aEnableButtons*/ ,  /*bCancel*/ ) == 0)

	If !lTelaOk .And. ValType(_bAftFailV) == "B"//<_bAftFailV> armazena callback à ser executado caso falhe a ativação da view
		FWMsgRun(, _bAftFailV,, STR0109)
		_bAftFailV := Nil
	EndIf
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} GCP300VlP(dDataDe)
Função para validar a data de publicação da ata.

@author Flavio Lopes Rasta
@since 20/11/2013
@version P11
@return aRotina
/*/
//-------------------------------------------------------------------
Function GCP300VlP(dDataDe)
Local aArea 	:= GetArea()
Local lRet 	:= .T.


C01->(DbSetOrder(1))
If CO1->(DbSeek(xFilial('CO1')+CPH->CPH_CODEDT+CPH->CPH_NUMPRO))
	If CO1->CO1_DTHOMO > dDataDe
		Help("",1,"GCP300VlP",,STR0045+Dtoc(CO1->CO1_DTHOMO),4,1)	//"A data da publicação deve ser maior ou igual a: "
		lRet:= .F.
	Endif 
EndIf

RestArea( aArea ) 
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A300WHENNP()
Funcao when para validar se o nao participante (Carona) ja teve efetuou
alguma manutenção de saldo na ata.

@author alexandre.gimenez
@since 10/12/2013
@version 1.0
@return lRet
/*/
//-------------------------------------------------------------------
Function A300WHENNP()
Local oModel	:= FwModelActive()
Local lRet		:= .T.

If IsInCallStack("GCP300Manu") 
	//-- Caso não tenha quantidade reservada e nem quantidade consumida
	lRet := Empty(oModel:GetModel('CPIDETAIL'):GetValue('CPI_QTDRES')) .And. ;
			 Empty(oModel:GetModel('CPIDETAIL'):GetValue('CPI_QTDCON')) .And. ;
			 oModel:GetModel('CPIDETAIL'):GetValue('CPI_TIPO') == '2' 
EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} A300PreCPIN()
Pre valid da não participante

@author alexandre.gimenez
@since 10/12/2013
@version 1.0
@return lRet
/*/
//-------------------------------------------------------------------
Function A300PreCPIN(oModelGrid, nLine, cAction, cField)
Local lRet := .T.

If cAction = 'DELETE'
	lRet := A300WHENNP()
	If !lRet
		Help("",1,"A300NOEXCLUI") //Não é permitido excluir órgão que tenha reserva ou quantidade consumida.
	ElseIf oModelGrid:GetValue('CPI_TIPO') == '1' //Não é permitida a exclusão de participantes da ata.
		Help("",1,"A300NOP")
		lRet := .F.
	EndIf
EndIF

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A300VldQNP()
Funcao para validar a quantidade informada para um orgao nao participante (carona)

@author alexandre.gimenez
@since 10/12/2013
@version 1.0
@return lRet
/*/
//-------------------------------------------------------------------
Function A300VldQNP()
Local lRet		:= .T.

If IsInCallStack("GCP300Manu") .OR. IsInCallStack("GCP300Incl")

	If lRet := A300CarInd()//Valida se quantidade maior que licitada
		lRet :=  A300CarTot() //Valida se soma é 5vezes qtd licitada
		If !lRet
			Help("",1,"A300CarTot")	//"A totalidade das contratações não pode exceder 5 vezes o quantitativo total."
		EndIf
	Else
		Help("",1,"A300CarInd")	//"A contratação não pode exceder 100% do quantitativo total registrado em ata."
	EndIf
	
EndIf

Return lRet

/*/{Protheus.doc} GCP300Ini
	Função de inicialização do modelo
@author guilherme.pimentel
@Param oModel - Modelo ativo
@since 11/12/2013
@version P11
@return aRotina
/*/
Function GCP300Ini(oModel)
	Local lRet 			:= .T.
	Local oModelCPH		:= oModel:GetModel("CPHMASTER")
	Local oModelCPI		:= oModel:GetModel("CPIDETAIL")
	Local oModelCPY		:= oModel:GetModel("CPYDETAIL")
	Local oModelCX6		:= Nil
	Local oMdlTemp		:= Nil
	Local cCodOrg		:= ""
	Local cCpoCancel	:= ""
	Local aBlockMdl		:= {}
	Local lLote 		:= (oModel:GetId() == "GCPA301")
	Local bWhenNE		:= Nil
	Local bWhenSaldo	:= Nil
	Local bFalseWhen	:= FwBuildFeature( STRUCT_FEATURE_WHEN, ".F.")
	Local bTrueWhen		:= FwBuildFeature( STRUCT_FEATURE_WHEN, ".T.")
	Local bVldStatus	:= Nil
	Local aMdlCancel	:= {}
	Local nX			:= 0

	GCP300Bloc(oModel)

	If G300SitAta()//É mudança de situação da Ata
		If G300NewSit() == ST_CANCELA //Mudando situacao p/ cancelada
			aMdlCancel := {'CPYDETAIL'}
			If lLote
				aAdd(aMdlCancel,'CX6DETAIL')
			EndIf

			for nX := 1 to Len(aMdlCancel)				
				oMdlTemp	:= oModel:GetModel(aMdlCancel[nX])
				cCpoCancel	:= Left(oMdlTemp:GetId(), 3) + "_STATUS"

				oMdlTemp:SetNoUpdateLine(.F.)
				oMdlTemp:SetNoInsertLine(.T.)
				oMdlTemp:SetNoDeleteLine(.T.)
				oMdlTemp:GetStruct():SetProperty("*"		,MODEL_FIELD_WHEN, bFalseWhen)

				If oMdlTemp:HasField(cCpoCancel)
					oMdlTemp:GetStruct():SetProperty(cCpoCancel	,MODEL_FIELD_WHEN, bTrueWhen)
					
					bVldStatus := MTBlcVld(Left(cCpoCancel,3),cCpoCancel ,"G300VlStat(a,b,c)",.F.,.F.,.T.)
					oMdlTemp:GetStruct():SetProperty(cCpoCancel,MODEL_FIELD_VALID, bVldStatus)				
				EndIf
			next

			FwFreeArray(aMdlCancel)
		EndIf
	Else
		Gcp017BMod(oModel, {'CPNDETAIL','CX3DETAIL'}, .T.)	
	EndIf

	If IsInCallStack("GCP300Incl")
		cCodOrg	:= SuperGetMV("MV_GCPORG", .T., "")
		If oModel:GetId() == 'GCPA301'
			oModelCPH:LoadValue( 'CPH_AVAL' , '2' )
		EndIf

		oModelCPH:SetValue("CPH_STATUS", "3")	
		oModelCPI:LoadValue("CPI_CODORG", cCodOrg)
		
		If CPA->(DbSeek(xFilial("CPA")+cCodOrg))
			oModelCPI:LoadValue("CPI_CODORG"	, cCodOrg)
			oModelCPI:LoadValue("CPI_DESORG"	, CPA->CPA_DESORG)		
			oModelCPI:LoadValue("CPI_UF"		, CPA->CPA_UF)
		EndIf
		
	Else
		oModelCPH:GetStruct():SetProperty("CPH_VGATAI",MODEL_FIELD_OBRIGAT,.F.)
		oModelCPH:GetStruct():SetProperty("CPH_VGATAF",MODEL_FIELD_OBRIGAT,.F.)
		oModelCPH:GetStruct():SetProperty("CPH_DTPB1",MODEL_FIELD_OBRIGAT,.F.)
		oModelCPH:GetStruct():SetProperty("CPH_CANAL1",MODEL_FIELD_OBRIGAT,.F.)	
	EndIf
	
	If FwIsInCallStack('GCP300Manu')
		bWhenNE := FwBuildFeature( STRUCT_FEATURE_WHEN, "A300WhnEmp()")
		oModel:GetModel("CPEDETAIL"):GetStruct():SetProperty('CPE_CODNE'	,MODEL_FIELD_WHEN,bWhenNE)
		oModel:GetModel("CPEDETAIL"):GetStruct():SetProperty('CPE_ITEMNE'	,MODEL_FIELD_WHEN,bWhenNE)

		aBlockMdl := {'CPYDETAIL','CPZDETAIL','CX3DETAIL'}
		If lLote
			aAdd(aBlockMdl,'CX6DETAIL')
		EndIf
		Gcp017BMod(oModel, aBlockMdl,.T.)
		FwFreeArray(aBlockMdl)
	ElseIf IsInCallStack('GCPA300Prz')

		Gcp017BMod(oModel, {'CPZDETAIL','CPNDETAIL','CPEDETAIL','CX3DETAIL'},.T.)
		oModelCPH:GetStruct():SetProperty("*"			,MODEL_FIELD_WHEN,bFalseWhen)
		oModelCPH:GetStruct():SetProperty("CPH_VGATAF"	,MODEL_FIELD_WHEN,bTrueWhen)

		oModelCPY:SetNoUpdateLine(.F.)
		oModelCPY:SetNoInsertLine(.T.)
		oModelCPY:SetNoDeleteLine(.T.)
		oModelCPY:GetStruct():SetProperty("*"			,MODEL_FIELD_WHEN,bFalseWhen)
		oModelCPY:GetStruct():SetProperty("CPY_QUANT"	,MODEL_FIELD_WHEN,bTrueWhen)
		oModelCPY:GetStruct():SetProperty("CPY_QUANT2"	,MODEL_FIELD_WHEN,bTrueWhen)
		oModelCPY:Getstruct():SetProperty("CPY_SALDO"	,MODEL_FIELD_WHEN,bTrueWhen)
		oModelCPY:Getstruct():SetProperty("CPY_VLTOT"	,MODEL_FIELD_WHEN,bTrueWhen)
		oModelCPY:GetStruct():AddTrigger( "CPY_QUANT" , "CPY_SALDO ", /*bPre*/, {|oMdlCpy| CalcSald(oMdlCpy) } )	
		
		oModelCPI:SetNoUpdateLine(.F.)
		oModelCPI:SetNoInsertLine(.T.)
		oModelCPI:SetNoDeleteLine(.T.)
		bWhenSaldo := FwBuildFeature( STRUCT_FEATURE_WHEN, "A320WhnSld()")
		oModelCPI:GetStruct():SetProperty("*"			,MODEL_FIELD_WHEN,bFalseWhen)
		oModelCPI:GetStruct():SetProperty("CPI_SALDO"	,MODEL_FIELD_WHEN,bWhenSaldo)
		
		If lLote
			oModelCX6	:= oModel:GetModel("CX6DETAIL")
			oModelCX6:SetNoUpdateLine(.F.)
			oModelCX6:SetNoInsertLine(.T.)
			oModelCX6:SetNoDeleteLine(.T.)
			oModelCX6:GetStruct():SetProperty("*",MODEL_FIELD_WHEN,bFalseWhen)
			oModelCX6:Getstruct():SetProperty('CX6_VLRTOT',MODEL_FIELD_WHEN,bTrueWhen)
			oModelCX6:Getstruct():SetProperty('CX6_SLDLOT',MODEL_FIELD_WHEN,bTrueWhen)
		EndIf

	ElseIf GetRepact() //Repactuação
		
		Gcp017BMod(oModel, {'CPZDETAIL','CPNDETAIL','CPEDETAIL','CX3DETAIL','CPIDETAIL'},.T.)
		
		oModelCPH:GetStruct():SetProperty("*",MODEL_FIELD_WHEN,{||.F.})
		
		oModelCPY:SetNoUpdateLine(.F.)
		oModelCPY:SetNoInsertLine(.T.)
		oModelCPY:SetNoDeleteLine(.T.)
		oModelCPY:GetStruct():SetProperty("*",MODEL_FIELD_WHEN,{||.F.})
		oModelCPY:Getstruct():SetProperty('CPY_PERCRJ',MODEL_FIELD_WHEN,{||.T.})
		oModelCPY:Getstruct():SetProperty('CPY_VALRRJ',MODEL_FIELD_WHEN,{||.T.})
		oModelCPY:Getstruct():SetProperty('CPY_VALATU',MODEL_FIELD_WHEN,{||.T.})
		oModelCPY:Getstruct():SetProperty('CPY_VLTOT',MODEL_FIELD_WHEN,{||.T.})
		
		If GCP301Lote()
			oModelCX6	:= oModel:GetModel("CX6DETAIL")
			oModelCX6:SetNoUpdateLine(.F.)
			oModelCX6:SetNoInsertLine(.T.)
			oModelCX6:SetNoDeleteLine(.T.)
			oModelCX6:GetStruct():SetProperty("*",MODEL_FIELD_WHEN,{||.F.})
			oModelCX6:Getstruct():SetProperty('CX6_VLRTOT',MODEL_FIELD_WHEN,{||.T.})
			oModelCX6:Getstruct():SetProperty('CX6_SLDLOT',MODEL_FIELD_WHEN,{||.T.})
		EndIf
		
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A300IniSld
Inicialização dos saldos

@author guilherme.pimentel

@Param oModel - Modelo ativo
@since 11/12/2013
@version P11
@return aRotina
/*/
//-------------------------------------------------------------------

Function A300IniSld(oModel)
Local oModelCPH := Nil
Local oModelCPY := Nil
Local oModelCPI := Nil
Local nX := 0
Local nY := 0
Local lRet := .T.
Local aSaveLines	:= FWSaveRows()

Default oModel := FWModelActive() 

oModelCPH := oModel:GetModel('CPHMASTER')
oModelCPY := oModel:GetModel('CPYDETAIL')
oModelCPI := oModel:GetModel('CPIDETAIL')

For nX := 1 to oModelCPY:Length()
	oModelCPY:GoLine(nX)
	nQuant := 0	
	For nY := 1 to oModelCPI:Length()
		oModelCPI:GoLine(nY)
		nQuant += oModelCPI:GetValue('CPI_SALDO')
	Next nY		
		
	oModelCPY:SetNoUpdateLine(.F.)
	//oModelCPY:LoadValue('CPY_SALDO',nQuant)
	oModelCPY:SetNoUpdateLine(.T.)
Next nX

oModelCPY:GoLine(1)
oModelCPI:GoLine(1)

FWRestRows( aSaveLines )	

Return lRet

/*/{Protheus.doc} A300GrvPb
	Gravação das datas e canal de publicação

@author guilherme.pimentel
@Param dData - Data da publicação
@Param cCanal - Canal da publicação
@since 11/12/2013
@return Nil
/*/
Function A300GrvPb(dData,cCanal,oModelCPH)
	Local nX := 0
	Local cCpoData := ""
	Local cCpoCanal:= ""

	for nX := 1 to 4
		cCpoData := "CPH_DTPB"	+ cValToChar(nX)
		cCpoCanal:= "CPH_CANAL"	+ cValToChar(nX)

		If Empty(oModelCPH:GetValue(cCpoData))
			oModelCPH:LoadValue(cCpoData	, dData)
			oModelCPH:LoadValue(cCpoCanal	, cCanal)
			Exit
		EndIf
	next nX
Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} GCPA300AtLg(oModel, oView)
Função para atualizar as legendas dos modelos

@author Matheus Lando
@since 20/11/2013
@version P11
/*/
//-------------------------------------------------------------------
Function GCPA300AtLg(oModel)
Local nI 		:= 0
Local nI2 		:= 0
Local oModLic 	:= oModel:GetModel('CPZDETAIL')
Local oModProd	:= oModel:GetModel("CPYDETAIL")
Local oView 	:= FWViewActive() 
Local aProp 	:= GetPropMdl(oModProd)


Gcp017BMod(oModel, {'CPYDETAIL','CPZDETAIL'},.F.)

For nI := 1 To oModProd:Length()
	oModProd:GoLine(nI)
	GCP200SetLeg("CPZ_STATUS",oModProd:GetValue('CPY_STATUS'))
		
	For nI2 := 1 To oModLic:Length()
		oModLic:GoLine(nI2)
		GCP200SetLeg("CPZ_STATUS",oModlic:GetValue('CPZ_STATUS'))
	Next nI	
Next nI	 	 

Gcp017BMod(oModel, {'CPYDETAIL','CPZDETAIL'},.T.)
A300PFirst()

RstPropMdl(oModProd,aProp)

If IsInCallStack("GCP300Incl")
	Gcp017BMod(oModel, {'CPYDETAIL','CPZDETAIL'},.F.)	
EndIf	
	
oView:Refresh("VIEW_CPY")
oView:Refresh("VIEW_CPZ")

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} GCP300MSld()
Funcao para chamar a tela de manutencao do saldo com geracao de documentos	

@author alexandre.gimenez	
@since 16/12/2013
@version 1.0
@return Nil
/*/
//--------------------------------------------------------------------
Function GCP300MSld()
	FWExecView('', "GCPA320", MODEL_OPERATION_UPDATE ,/*oDlg*/ ,{||.T.},,/*nPercReducao*/ ,/*aEnableButtons*/ ,  /*bCancel*/ )
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} A300CPEPVl
Rotina de pré validação do modelo 

@author guilherme.pimentel

@param oModel = Modelo
@return lRet - Confirmação da validação
@since 17/12/2013
@version P11
/*/
//-------------------------------------------------------------------
Function A300CPEPVl(oModelCPE, nLinha, cAcao, cCampo, xNewValue, xOldValue)
Local oModel	  	:= oModelCPE:GetModel()
Local oModelCPI 	:= oModel:GetModel('CPIDETAIL')
Local nDBSaldo		:= 0
Local nReserv		:= 0
Local aSaveLines	:= FWSaveRows()
Local nSaldoAtu 	:= 0
Local lRet 			:= .T.
Default xNewValue := 0
Default xOldValue := 0

Do Case
	Case cAcao == 'SETVALUE'
		If  cCampo == "CPE_QUANT"
			nDBSaldo	:= oModelCPI:GetValue('CPI_SALDO')
			nReserv		:= oModelCPI:GetValue('CPI_QTDRES')
			nSaldoAtu	:= nDBSaldo + xOldValue 
			If !(xNewValue <= nSaldoAtu)
				lRet := .F.
				Help(' ', 1, 'A300CPEPVLM') //O valor reservado é maior que o licit1ado.
			EndIf
		EndIf		
	Case cAcao == 'DELETE'
		nReserv	:= oModelCPI:GetValue('CPI_QTDRES')
		If (oModelCPE:GetValue('CPE_TIPMOV')=='2')
			lRet := .F.
			Help(' ', 1, 'A300CPEPVl') //Não é possível deletar registros de baixa.
		ElseIf nReserv > 0
			nDBSaldo:= oModelCPI:GetValue('CPI_SALDO')
			oModelCPI:LoadValue('CPI_QTDRES',	nReserv  - oModelCPE:GetValue('CPE_QUANT'))					 		
			oModelCPI:LoadValue('CPI_SALDO',	nDBSaldo + oModelCPE:GetValue('CPE_QUANT'))	
		EndIf

	Case cAcao == 'UNDELETE'
		nDBSaldo:= oModelCPI:GetValue('CPI_SALDO')
		nReserv	:= oModelCPI:GetValue('CPI_QTDRES')
		oModelCPI:LoadValue('CPI_QTDRES',	nReserv  + oModelCPE:GetValue('CPE_QUANT'))					 		
		oModelCPI:LoadValue('CPI_SALDO',	nDBSaldo - oModelCPE:GetValue('CPE_QUANT'))	
EndCase
FWRestRows( aSaveLines )
FwFreeArray(aSaveLines)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GCP300PVLD()
Pos validação do modelo

@author Matheus Lando	
@since 16/12/2013
@version 1.0
@return Nil
/*/
//--------------------------------------------------------------------
Function GCP300PVLD(oModel)
	Local lRet 		:= .T.
	Local nI  			:= 0
	Local nX  			:= 0
	Local lLote			:= oModel:GetId() == "GCPA301"
	Local oCPHMaster 	:= oModel:GetModel('CPHMASTER')
	Local oCPIDetail	:= oModel:GetModel("CPIDETAIL")
	Local oCPZDetail	:= oModel:GetModel('CPZDETAIL')
	Local oCPYDetail 	:= oModel:GetModel('CPYDETAIL')
	Local oCX6Detail	:= Iif(lLote,oModel:GetModel('CX6DETAIL'),Nil)
	Local cJust			:= ""
	Local lIncManual	:= .F.
	Local nLength		:= 0
	Local aSaveLines	:= FWSaveRows()
	Local cMsgVld		:= ""

	//-- Verifica se a ata foi incluida manualmente ou através de um edital
	CO1->(DbSetOrder(1))	
	lIncManual := !CO1->(DbSeek(xFilial("CO1")+oCPHMaster:GetValue("CPH_CODEDT")))

	// Valida se todos os produtos/lotes possuem fornecedor ganhador
	If lRet
		lRet := A300StaFor(oModel)
	EndIf

	// Valida se todos os produtos opossuem o mesmo fornecedor
	If lRet .And. !lLote
		lRet := A300VldFor(oModel)
	EndIf

	If lRet .And. SuperGetMV("MV_NOTAEMP",.F.,.F.)

		If lIncManual
			nLength := 1
		Else
			nLength := oCPIDetail:Length() 
		EndIf		

		For nX := 1 to nLength
			oCPIDetail:Goline(nX)	
			If(Iif(lIncManual,.T.,oCPHMaster:GetValue("CPH_CODORG") == oCPIDetail:GetValue("CPI_CODORG")))
				For nI := 1 To oCPYDetail:Length()	
					oCPYDetail:GoLine(nI)
					If !oCPYDetail:IsDeleted()
						lRet := A400VldNe()		
						If !lRet
							Help("",1,"A300NEDIV")//Reajuste as reservas da Ata de acordo com o saldo disponível na Nota de Empenho.				
							Exit
						EndIf
					EndIf					
				Next nI
			EndIf		
		Next nX	
	EndIf		

	If lRet .And. GetRepact()
		cJust := G300GetJus()

		If !Empty(cJust) .Or. (!IsBlind() .And. GCP300Dlg(@cJust, STR0080))
			RecLock("CPN",.T.)
			CPN->CPN_FILIAL 	:= xFilial('CPN')
			CPN->CPN_NUMATA	:= CPH->CPH_NUMATA
			CPN->CPN_DATA 		:= dDataBase
			CPN->CPN_HORA 		:= Time()
			CPN->CPN_TIPO		:= '2'
			CPN->CPN_USER		:= __cUserId
			CPN->CPN_JUST		:= cJust
			CPN->(MsUnLock())
			lRet := .T.
		Else
			Help(' ', 1, 'GCP300JUST') //A Ata está suspensa!	
			lRet := .F.				
		EndIf		
	EndIf	

	If lRet .And. !lIncManual
		If lLote
			For nX := 1 to oCX6Detail:Length()
				oCX6Detail:GoLine(nX)
				If !oCX6Detail:IsDeleted()
					cMsgVld+=VldDistrSld(oCPYDetail,oCPIDetail)
				EndIf
			Next
		Else
			cMsgVld+=VldDistrSld(oCPYDetail,oCPIDetail)
		EndIf
		lRet := Empty(cMsgVld)
		If !lRet
			cMsgVld := STR0117 + CRLF + cMsgVld //Necessário distribuir corretamente o saldo dos produtos entre os participantes:
			Help("",1,'GCPA300SLDN',,cMsgVld,1,0,,,,,,{STR0118})
		EndIf
	EndIf
		
	If lRet .And. !lLote
		oCPZDetail:GoLine(1)
		oCPHMaster:LoadValue('CPH_CODIGO',oCPZDetail:GetValue('CPZ_CODIGO'))
		oCPHMaster:LoadValue('CPH_LOJA',oCPZDetail:GetValue('CPZ_LOJA'))
	EndIf 	

	FWRestRows( aSaveLines )
	FwFreeArray(aSaveLines)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A300WHEN()
when do campo cpe_quant

@author Alexandre.gimenez	
@since 18/12/2013
@version 1.0
@return Nil
/*/
//--------------------------------------------------------------------
Function A300WHEN(oModelCPE)
Local lRet := oModelCPE:GetValue('CPE_TIPMOV') == '1'

Return lRet

/*/{Protheus.doc} GCP300PVLD()
	Pos validação do modelo
@author Matheus Lando	
@since 16/12/2013
@version 1.0
@return Nil
/*/
Function A300POSPVl(oCPEDetail)
	Local lRet 		:= .F.	
	Local oModel	:= oCPEDetail:GetModel()
	Local oCPHMaster:= oModel:GetModel('CPHMASTER')
	Local oCPYDetail:= oModel:GetModel('CPYDETAIL')	

	If !(lRet := oCPEDetail:GetValue('CPE_QUANT') > 0)
		Help(' ', 1, 'GCP300QUANT')		//A quantidade deve ser maior do que zero
	EndIf

	If lRet .And. !Empty(oCPEDetail:GetValue('CPE_CODNE')) .And.  Empty(oCPEDetail:GetValue('CPE_ITEMNE'))
		Help( "" , 1 , "A300ITNE" )
		lRet := .F.
	EndIf
			
	If lRet .And. !Empty(oCPEDetail:GetValue('CPE_CODNE')) .And.  !Empty(oCPEDetail:GetValue('CPE_ITEMNE'))
		CX0->(DbSetOrder(2))
		If !CX0->(DbSeek(xFilial("CX0")+oCPHMaster:GetValue('CPH_CODEDT')+oCPHMaster:GetValue('CPH_NUMPRO')+oCPHMaster:GetValue('CPH_NUMATA')))
			Help( "" , 1 , "A300SNEAT" )
			lRet := .F.
		EndIf						

		CX1->(DbSetOrder(2))
		If !CX1->(DbSeek(xFilial("CX1")+oCPEDetail:GetValue('CPE_CODNE')+oCPEDetail:GetValue('CPE_ITEMNE')+oCPYDetail:GetValue('CPY_CODPRO')))
			Help( "" , 1 , "A300SLDITNE" )
			lRet := .F.		
		EndIf
	EndIf

	If lRet
		lRet := VldCPEItSC(oCPEDetail, oCPEDetail:GetValue('CPE_ITEMSC'))
	EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A300GetOrg(nTipo)
Funcao para pegar o orgao

@author Alexandre.gimenez	
@since 18/12/2013
@version 1.0
@return Nil
/*/
//--------------------------------------------------------------------
Function A300GetOrg(nTipo)
Local oModel := FwModelActive()
Local cRet := ""

If Valtype(oModel) == "O"
	cRet := IIF(nTipo = 1, oModel:GetModel('CPIDETAILP'):GetValue('CPI_CODORG'),oModel:GetModel('CPIDETAILN'):GetValue('CPI_CODORG'))
Else
	cRet := CPI->CPI_CODORG
EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A300Legend()
Funcao para mostrar legendas.	

@author alexandre.gimenez	
@since 16/12/2013
@version 1.0
@return Nil
/*/
//--------------------------------------------------------------------
Function A300Legend()
Local aLeg             := {}

aAdd(aLeg,{"BR_AZUL"     	,STR0054})	//"Participante"
aAdd(aLeg,{"BR_AMARELO"  	,STR0055 })//"Carona"
aAdd(aLeg,{"BR_VERDE"    	,STR0058 })//"Gerenciador"

BrwLegenda(STR0051,STR0056,aLeg) //"Legenda"//"Orgao"

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} A300VlOk()
Valida os campos de data e canal de publicação

@author Alexandre.gimenez	
@since 18/12/2013
@version 1.0
@return Nil
/*/
//--------------------------------------------------------------------
Function A300VlOk(dData ,cCanal,oDlg)
Local lRet := .T.

If Empty(dData)
	lRet := .F.
	Help(' ', 1, 'GCP300DTPUB') // Informe a data de Publicação
ElseIf !GCP300VlP(dData)
	lRet := .F.
ElseIf Empty(Trim(cCanal))
	lRet := .F.
	Help(' ', 1, 'GCP300NCNL') //Informe o canal de publicação		
EndIf	

If lRet
	oDlg:End()
EndIF

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A300IniTip()
Inicializador padrão do tipo do participante

@author guilherme.pimentel	
@since 19/12/2013
@version 1.0
@return Nil
/*/
//--------------------------------------------------------------------

Function A300IniTip()
local cRet := ""

cRet := IF(IsInCallStack('GCPA300'),"2","1")

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GCP300Incl()
Função para inclusão da Ata de acordo com a avaliação

@author marco.guimaraes 
@since 15/12/2014
@version P11
@param nTipo, numérico, tipo de inclusão 1 = item, 2 = lote
@return NIL
/*/
//-------------------------------------------------------------------
Function GCP300Incl(nTipo)
	Local cModel := ""
	DEFAULT ntipo = 1

	cModel := IIF((nTipo == 1), "GCPA300", "GCPA301")
	
	FWExecView(STR0057, cModel, MODEL_OPERATION_INSERT ,/*oDlg*/ , {||.T.},/*bOk*/ ,/*nPercReducao*/ ,/*aEnableButtons*/ ,{||.T.}  /*bCancel*/ ) //Inclusão

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} A300VldNumEd()
Validação do Código de  processo licitatório já existente na tabela CO1

@author marco.guimaraes	
@since 16/12/2014
@version 1.0
@return Nil
/*/
//--------------------------------------------------------------------
Function A300VldNumEd() 
Local lRet 		:= .T.
Local oModel		:= FWModelActive()
Local oModelCPH  	:= oModel:GetModel('CPHMASTER')
Local cCodEdt		:= oModelCPH:GetValue('CPH_CODEDT') 

If IsInCallStack("GCP300Incl") .And. CO1->(DbSeek(xFilial('CO1')+cCodEdt))  
	lRet := .F.
	Help('', 1, 'JAGRAVADO')		
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A300WhDocMov()
Valida o when do campo CPE_DOCMOV

@author marco.guimaraes	
@since 18/12/2014
@version 1.0
@return Nil
/*/
//--------------------------------------------------------------------
Function A300WhDocMov() 
Local lRet 		:= .T.
Local oModel		:= FWModelActive()
Local oModelCPH  	:= oModel:GetModel('CPHMASTER')
Local oModelCPI  	:= oModel:GetModel('CPIDETAIL')

If (oModelCPI:GetValue("CPI_CODORG") <> oModelCPH:GetValue('CPH_CODORG'))
	lRet := .F.
EndIf

If lRet .and. IsInCallStack("GCP300Incl")
	lRet := .F.
EndIf

Return lRet			

//-------------------------------------------------------------------
/*/{Protheus.doc} A300VldOrg()
Disponibiliza apenas a inclusão de um orgão não cadastrado no parâmetro:
MV_GCPORG

@author marco.guimaraes	
@since 22/12/2014
@version 1.0
@return Nil
/*/
//--------------------------------------------------------------------
Function A300VldOrg() 
Local lRet 		:= .T.
Local oModel		:= FWModelActive()
Local oModelCPH  	:= oModel:GetModel("CPHMASTER")
Local cCodOrgPar	:= AllTrim(SuperGetMV("MV_GCPORG", .T., ""))
Local cCodOrgCPH	:= AllTrim(oModelCPH:GetValue("CPH_CODORG"))

If IsInCallStack("GCP300Incl") .and. cCodOrgPar <> "" .and. (cCodOrgCPH == cCodOrgPar)
	lRet := .F.
	Help("", 1, "GCP300ORGGER") //M: Por ser uma inclusão, não é permitido que este Órgão seja o gerenciador. S: Inclua um Órgão diferente do que esta configurado no parâmetro: MV_GCPORG.  
EndIf
	
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A300VldIncl()
Valida se é uma inclusão de Ata manual.

@author marco.guimaraes
@since 22/12/2014
@version 1.0
@return Nil
/*/
//--------------------------------------------------------------------
Function A300VldIncl() 
Local lRet 		:= .T.
Local oModel		:= FWModelActive()
Local oModelCPH  	:= oModel:GetModel("CPHMASTER")
Local cCodOrgPar	:= SuperGetMV("MV_GCPORG", .T., "")

If IsInCallStack("GCP300Incl")
	If (AllTrim(oModelCPH:GetValue("CPH_CODORG")) == AllTrim(cCodOrgPar)) .and. CO1->(DbSeek(xFilial('CPH') + oModelCPH:GetValue("CPH_CODEDT")))
		lRet := .F.
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A300PFirst()
Função que Posiciona os grids na primeira linha

@author Flavio Lopes Rasta
@since 22/12/2014
@version P12
@return lRet
/*/
//-------------------------------------------------------------------
Function A300PFirst()
Local oModel		:= FWModelActive()
Local lUsaLote		:= oModel:GetId() == 'GCPA201'
Local oModCPY		:= oModel:GetModel("CPYDETAIL")
Local oModCPZ		:= oModel:GetModel("CPZDETAIL")
Local oModCP3		:= oModel:GetModel("CP3DETAIL")
Local nX			:= 0

//Colocado nesse ponto devido uma necessidade de atualização da view
If IsInCallStack("GCP200CPY")
	A200IniCpy(oModel,lUsaLote)
EndIf

If !lUsaLote
	For nX := 1 To oModCPY:Length() 
		oModCPY:GoLine(nX)	
		oModCPZ:GoLine(1)
	Next nX
	oModCPY:GoLine(1) 		
Else
	For nX := 1 To oModCP3:Length()
		oModCP3:GoLine(nX)
		oModCPY:GoLine(1)			 
		oModCPZ:GoLine(1)			
	Next nX
	oModCP3:GoLine(1)
EndIf	
Return Nil

//-------------------------------------------------------------------
/*{Protheus.doc} GCP200VlNPro
Validacao do campo CO1_NUMPRO

@author Alex Egydio
@since 10/09/2013
@version P11.90
*/
//-------------------------------------------------------------------
Function GCP300VlNPro()

Local oModel := FWModelActive()
Local cCodEdt:= ""
Local cNumPro:= ""
Local lRet   := .F.
Local oView 	:= FWViewActive()

cCodEdt := oModel:GetValue("CPHMASTER","CPH_CODEDT")
cNumPro := oModel:GetValue("CPHMASTER","CPH_NUMPRO")
cNumPro := PadL(AllTrim(cNumPro),Len(CPH->CPH_NUMPRO),"0")

oModel:SetValue("CPHMASTER","CPH_NUMPRO",cNumPro)
lRet := ExistChav("CPH",cCodEdt+cNumPro)

oView:Refresh()

Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} GCP300CpiL
Função para carregar o orgão ao inserir um novo produto. //TODO:>Avaliar essa função, pode apresentar lentidão

@author taniel.silva

@Param oModel - Modelo ativo
@since 09/01/2015
@version P12
@return lRet
/*/
//-------------------------------------------------------------------

Function GCP300LCpi(oModelCPY, nLine, cAction, cField)
	Local oModel 	:= oModelCPY:GetModel()
	Local oModelCPI	:= Nil
	Local oModelCX6	:= Nil
	Local cCodOrg	:= ""
	Local lRet 		:= .T.
	Local nNvSaldo	:= 0
	Local nNvTotal	:= 0

	Do Case
		
		Case (cAction == "SETVALUE" .And. ValType(nLine) <> "U" .And. (FwIsInCallStack("GCP300Incl")))
			cCodOrg		:= SuperGetMV("MV_GCPORG", .T., "")
			oModelCPI	:= oModel:GetModel("CPIDETAIL")
			If (oModelCPI:GetValue("CPI_CODORG") <> cCOdOrg)
				
				oModelCPI:LoadValue( "CPI_CODORG"	, cCodOrg )
				oModelCPI:LoadValue( "CPI_LEGEND" 	, "BR_AMARELO" )
				oModelCPI:LoadValue( "CPI_TIPO" 	, "2" )
				
				CPA->( dbSetOrder(1) )
				
				If CPA->(DbSeek(xFilial("CPA")+cCodOrg))
					oModelCPI:LoadValue( "CPI_DESORG"	, CPA->CPA_DESORG )
					oModelCPI:LoadValue( "CPI_UF" 		, CPA->CPA_UF )		
				EndIf		
			EndIf
		
		Case (cAction == "DELETE" .Or. cAction == "UNDELETE") .And. (oModel:GetId() == "GCPA301")
			oModelCX6	:= oModel:GetModel("CX6DETAIL")
		 	nNvTotal	:= oModelCX6:GetValue("CX6_VLRTOT")
			nNvSaldo	:= oModelCX6:GetValue("CX6_SLDLOT")
		
			if cAction == "DELETE"
				nNvTotal	-= oModelCPY:GetValue("CPY_VLTOT")
				nNvSaldo	-= oModelCPY:GetValue("CPY_VLTOT")
			else
				nNvTotal	+= oModelCPY:GetValue("CPY_VLTOT")
				nNvSaldo	+= oModelCPY:GetValue("CPY_VLTOT")							
			endif

			oModelCX6:SetValue( "CX6_VLRTOT" , nNvTotal )
			oModelCX6:SetValue( "CX6_SLDLOT" , nNvSaldo )			
	EndCase

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GCP300IniL
Função para inicializar o primeiro licitante como ganhador

@author taniel.silva

@since 12/01/2015
@version P12
@return cRet
/*/
//-------------------------------------------------------------------
Function GCP300IniL()
Local cRet 		:= "" 
Local oModel 		:= FWModelActive()
Local oModelCPZ	:= oModel:GetModel("CPZDETAIL")
Local nL			:= oModelCPZ:GetLine()
	
IIf(nL == 0, cRet := "5", cRet := "1")
	
Return cRet


//-------------------------------------------------------------------
/*/{Protheus.doc} GCP300IniL
Valida se a quantidade licitada é 5x maior que a quantidade do produto

@author taniel.silva

@since 12/01/2015
@version P12
@return lRet
/*/
//-------------------------------------------------------------------
Function GCP300QtL()
Local oModel	  	:= FWModelActive()
Local oModelCPI 	:= oModel:GetModel('CPIDETAIL')
Local oModelCPY 	:= oModel:GetModel('CPYDETAIL')
Local lRet 		:= .T.
Local nQuant		:= 0

If IsInCallStack("GCP300Incl") .Or. IsInCallStack("GCP300Manu")

	nTotQuant := oModelCPI:GetValue('CPI_QTDLIC')
	
	If nTotQuant > (oModelCPY:GetValue('CPY_QUANT') * 5)
		lRet := .F.
		Help("",1,"A300CarTot")
	EndIf
	
	lRet := lRet .And. A300VldQNP()
	 
EndIf	

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A300VldPar
Valida se o Orgão Gerenciador é diferente do Orgão Participante e Carona

@author taniel.silva

@since 13/01/2015
@version P12
@return lRet
/*/
//-------------------------------------------------------------------

Function A300VldPar()
Local lRet := .T.
Local oModel	  	:= FWModelActive()
Local oModelCPH 	:= oModel:GetModel('CPHMASTER')
Local cCodOrg		:= SuperGetMV("MV_GCPORG", .T., "")


If IsInCallStack("GCP300Incl")
	cCodOrg := Padr(cCodOrg,Len(CPH->CPH_CODORG))
				
	If oModelCPH:GetValue("CPH_CODORG") == cCodOrg
		lRet := .F.
		Help("",1,"A300VldPar")//Orgão Gerenciador não pode ser o mesmo que o orgão participante ou carona.
	EndIf		
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GCP300CaSC(oModel)
Rotina que carrega as Solicitações de Compra.

@author Flavio Lopes Rasta
@param oModel
@since 20/01/2015
@version 12
/*/
//-------------------------------------------------------------------
Function GCP300CaSC(oModel, lAuto as Logical, aSolComp as Array, aHeader as Array)
	Local oModelCPY	:= Nil
	Local aSaveLines := FWSaveRows()	
	Local aSCs		:= {}	
	Local aFiltrPrd	:= {}
	Local lLote 	:= .F.
	Default oModel	:= FwModelActive()
	Default lAuto	:= .F.
	Default aSolComp	:= {}
	Default aHeader   	:= {}

	oModelCPY	:= oModel:GetModel("CPYDETAIL")
	lLote 		:= GCP301Lote( oModel:GetValue( "CPHMASTER" , "CPH_NUMATA" ) , .T. )

	If !lAuto
		If lLote
			aSCs := GCPSCS(oModel,'CPYDETAIL', 'CX3DETAIL', 'CX3_NUMSC', 'CX3_ITEMSC','CX6DETAIL')
		Else
			aSCs := GCPSCS(oModel,'CPYDETAIL', 'CX3DETAIL', 'CX3_NUMSC', 'CX3_ITEMSC')
		EndIf
		aFiltrPrd := GCP300FtPrd(oModel)
		aSolComp := GCPSelSC(,,,,,,aSCs, , @aHeader,aFiltrPrd)
		FwFreeArray(aFiltrPrd)
	EndIf
	
	If Len(aSolComp) > 0 .And. A300VldScs(oModel,aSolComp,aHeader)
		
		oModelCPY:GetStruct():SetProperty("CPY_VLUNIT",MODEL_FIELD_OBRIGAT,.F.)
		oModelCPY:GetStruct():SetProperty("CPY_VALATU",MODEL_FIELD_OBRIGAT,.F.)
		oModelCPY:GetStruct():SetProperty("CPY_VLTOT",MODEL_FIELD_OBRIGAT,.F.)		

		If IsBlind()				
			GCPCadProd(@oModel, aSolComp, @aHeader,"CPY","CX3","CPZDETAIL","CX6")
		Else
			FwMsgRun(Nil,{|| GCPCadProd(@oModel, aSolComp, @aHeader,"CPY","CX3","CPZDETAIL","CX6") },,STR0105)
		EndIf
		
		oModelCPY:GetStruct():SetProperty("CPY_VLUNIT",MODEL_FIELD_OBRIGAT,.T.)
		oModelCPY:GetStruct():SetProperty("CPY_VALATU",MODEL_FIELD_OBRIGAT,.T.)
		oModelCPY:GetStruct():SetProperty("CPY_VLTOT",MODEL_FIELD_OBRIGAT,.T.)		
	EndIf		
	FWRestRows(aSaveLines)
	FwFreeArray(aSaveLines)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GCP300FtPrd(oModel)
Filtra produtos do modelo de produtos

@author Flavio Lopes Rasta
@param oModel
@since 20/01/2015
@version 12
/*/
//-------------------------------------------------------------------
Function GCP300FtPrd(oModel)
Local aSaveLines 	:= FWSaveRows()
Local aFiltro := {}
Local nX := 1
Local oModelCPY := oModel:GetModel('CPYDETAIL')

If !oModelCPY:IsDeleted() .And. !Empty(oModelCPY:GetValue('CPY_CODPRO'))
			aAdd(aFiltro,oModelCPY:GetValue('CPY_CODPRO'))
		EndIf

FWRestRows(aSaveLines)

Return aFiltro

//-------------------------------------------------------------------
/*/{Protheus.doc} GCP300GeNE()
Função para gerar nota de empenho da aglutinação das solicita

@author Israel Escorizza
@param 
@since 30/01/2015
@version 12
/*/
//-------------------------------------------------------------------
Function GCP300GeNE()
Local aArea		:= GetArea()
Local oModel 		:= FwModelActive()
Local aProd		:= {} //{CODPROD,QUANT}
Local aDadosAta	:= {}
Local aAta			:= {}
Local cCodEdt	:= CPH->CPH_CODEDT
Local cCodFil	:= ""
Local cNumAta	:= ""
Local cCodPro	:= ""
Local dDatFim	:= ""
Local cFilEnt	:= ""
Local cNumSC 	:= ""
Local cItemSC	:= ""
Local cCodOrg		:= ""
Local nPos		:= 0
Local nQuant	:= 0
Local nGravou := 0
Local nPreco  := 0	
Local lIncManual:= !CO1->(DbSeek(xFilial("CO1")+cCodEdt))
Local lLote		:= GCP301Lote(CPH->CPH_NUMATA)

If !SuperGetMV("MV_NOTAEMP",.F.,.F.)
	Help("",1,"A300PAREMP")//Funcionalidade não disponivel. Para utilizar, ative o parametro MV_NOTAEMP.
Else
	dDataFim := CPH->CPH_VGATAF
	
	If (dDataFim < dDatabase)
		Help("",1,"A300PRZVG")//Ata fora do prazo de vigência, impossivel continuar.
	Else
		If lLote
			GCP301GNLT()
		Else
			cCodFil	:= CPH->CPH_FILIAL
			cCodFor	:= CPH->CPH_CODIGO
			cLoja		:= CPH->CPH_LOJA
			cNumPro	:= CPH->CPH_NUMPRO
			cNumAta	:= CPH->CPH_NUMATA
			
			CPY->(DbSetOrder(1))
			If CPY->(DbSeek(cCodFil+cNumAta))
				While CPY->(!EOF()) .And. CPY->(CPY_NUMATA) == cNumAta	
					cCodPro := CPY->CPY_CODPRO
					nQuant := 0	
					nPreco := CPY->CPY_VLUNIT
					CX3->(DbSetOrder(1))
					If CX3->(DbSeek(cCodFil+cNumAta+cCodPro))
						While CX3->(!EOF()) .AND. CX3->(CX3_NUMATA) == cNumAta .AND. CX3->(CX3_CODPRO) == cCodPro
							If !CX3->(CX3_EMPENH)
								cNumSC 	:= CX3->CX3_NUMSC
								cItemSC	:= CX3->CX3_ITEMSC
								nQuant 	:= CX3->CX3_QUANT 
								cFilEnt	:= CX3->CX3_FILENT
								nPos := aScan( aProd, {|x| AllTrim(x[1]) == AllTrim(cCodPro)} )
								If  nPos == 0 					
									Aadd(aProd, {cCodPro, nQuant,0,cFilEnt,cNumSC,cItemSC} )
								Else
									aProd[nPos][2] := aProd[nPos][2] + nQuant
								EndIf
							EndIf					
							CX3->(dbSkip())
						EndDo
					
						For nPos := 1 To Len(aProd)
							If aProd[nPos,1] == cCodPro
								aProd[nPos][3] := aProd[nPos][2] * nPreco
							EndIf
						Next nI
					EndIf
					CPY->(dbSkip())
				EndDo
			EndIf
			
			If Len(aProd) == 0
				MsgAlert(STR0085)
			Else 
				aSort(aProd)
				If Len(aProd) > 0
				
					If lIncManual
						cCodOrg := CPI->CPI_CODORG
					Else
						cCodOrg := CPH->CPH_CODORG
					EndIf
					
					aAdd(aAta, cCodEdt)
					aAdd(aAta, cNumAta)
					aAdd(aAta, cNumPro)
					aAdd(aAta, aProd)
					
					Aadd(aDadosAta,cCodEdt)
					Aadd(aDadosAta,cNumPro)
					Aadd(aDadosAta,cCodOrg)
					
				EndIf
		
				nGravou := GCPXGeraNE(oModel,,cCodFor,cLoja,.F.,.F.,.T.,aAta,aDadosAta)
				cCodNe	 := CX0->CX0_CODNE
				
				If nGravou != 0 
					Help( "" , 1 , "GCPGENEATA" )
				EndIf
				
				If nGravou == 0
					For nPos := 1 To Len(aProd)
						CX3->(DbSetOrder(1))
						If CX3->(DbSeek(cCodFil+cNumAta+aProd[nPos][1]))
							While CX3->(!EOF()) .AND. CX3->(CX3_NUMATA) == cNumAta .AND. Alltrim(CX3->(CX3_CODPRO)) == Alltrim(aProd[nPos][1])
								If !CX3->(CX3_EMPENH)
									RecLock("CX3",.F.)
									CX3->CX3_EMPENH := .T.
									CX3->CX3_CODNE := CX0->CX0_CODNE
									
									If A400GetIt(CX0->CX0_CODNE,(aProd[nPos][1]))
										CX3->CX3_ITEMNE := CX1->CX1_ITEM 	
									EndIf
																							
									MsUnlock()
								EndIf
									CX3->(dbSkip())
							EndDo
						EndIf
					Next
				EndIf	
			EndIf	
		EndIf
	EndIf
EndIf
RestArea(aArea)
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} GCP300Grv()
Gravação do modelo.

@author taniel.silva	
@since 30/01/2015
@version 1.0
@return lRet
/*/
//--------------------------------------------------------------------
Function GCP300Grv(oModel)
	Local lRet 		:= .T.
	Local lNotaEmp 	:=  SuperGetMV("MV_NOTAEMP",.F.,.F.)
	Local lCancTotal := .F.
	Local nI		:= 0
	Local nX		:= 0
	Local nY		:= 0 

	Local cCodEdt	:= oModel:GetModel('CPHMASTER'):GetValue('CPH_CODEDT')
	Local cNumPro	:= oModel:GetModel('CPHMASTER'):GetValue('CPH_NUMPRO')
	Local cCodOrg	:= oModel:GetModel('CPHMASTER'):GetValue('CPH_CODORG')
	Local cCodPro	:= oModel:GetModel('CPYDETAIL'):GetValue('CPY_CODPRO')
	Local cNumAta	:= oModel:GetModel('CPHMASTER'):GetValue('CPH_NUMATA')
	Local cTipo		:= oModel:GetModel('CPIDETAIL'):GetValue('CPI_TIPO')
	Local cJust		:= ""
	Local cLote		:= ""

	Local aAreaCPI 	:= {}
	Local oMdlCX6	:= Nil

	If (G300SitAta() .And. G300NewSit() == ST_CANCELA)//Mudando situacao p/ cancelada
		If (oModel:GetId() == "GCPA301")
			oMdlCX6 := oModel:GetModel("CX6DETAIL")
			If CpoStatVld(oMdlCX6)				
				for nX := 1 to oMdlCX6:Length()//Percorre lotes
					oMdlCX6:GoLine(nX)
					If AllCancel(oModel:GetModel("CPYDETAIL"))//Se todos os itens do lote estiverem cancelados
						oMdlCX6:LoadValue("CX6_STATUS", "5")//Cancela o Lote(5=Cancelado)
					EndIf
				next nX
				lCancTotal := AllCancel(oMdlCX6)
			Else
				lCancTotal := .F.
				for nX := 1 to oMdlCX6:Length()//Percorre lotes
					oMdlCX6:GoLine(nX)
					lCancTotal := AllCancel( oModel:GetModel("CPYDETAIL") )
					If !lCancTotal
						Exit
					EndIf
				next nX
			EndIf
		Else
			lCancTotal := AllCancel( oModel:GetModel("CPYDETAIL") )
		EndIf
		
		If !lCancTotal//Se nem todos os itens estiverem cancelados			
			SetCancPrc(oModel) //Seta como Cancelamento Parcial
		EndIf
	EndIf

	Begin Transaction

		If lNotaEmp .And. GetRepact()
			lRet := A300GetRep(oModel)
		EndIf
			
		If lRet .And. (lRet := FwFormCommit(oModel))		
			If oModel:GetId() =="GCPA300" 		//- Ata por Item
				For	nX := 1 To oModel:GetModel('CPYDETAIL'):Length()
					oModel:GetModel('CPYDETAIL'):GoLine(nX)
					cCodPro := oModel:GetModel('CPYDETAIL'):GetValue('CPY_CODPRO')
					
					For nI := 1 To oModel:GetModel('CPIDETAIL'):Length()
						//Posicionar o registro no banco
						oModel:GetModel('CPIDETAIL'):GoLine(nI)
						cTipo	:= oModel:GetModel('CPIDETAIL'):GetValue('CPI_TIPO')
						cCodOrg := oModel:GetModel('CPIDETAIL'):GetValue('CPI_CODORG')
						
						If CPI->(DbSeek(xFilial('CPI')+cCodEdt+cNumPro+cCodOrg+cTipo+cCodPro))
							RecLock("CPI",.F.)
							CPI->CPI_NUMATA := cNumAta
							CPI->(MsUnLock())
						EndIf
					Next nI
				Next nX
				
			Else 							//- Ata Por Lote
				aAreaCPI := CPI->(GetArea())
				For nY := 1 To oModel:GetModel('CX6DETAIL'):Length()
					oModel:GetModel('CX6DETAIL'):GoLine(nY)
					cLote := oModel:GetModel('CX6DETAIL'):GetValue('CX6_LOTE')
					
					For	nX := 1 To oModel:GetModel('CPYDETAIL'):Length()
						oModel:GetModel('CPYDETAIL'):GoLine(nX)
						
						If cLote == oModel:GetModel('CPYDETAIL'):GetValue('CPY_LOTE')
							cCodPro := oModel:GetModel('CPYDETAIL'):GetValue('CPY_CODPRO')
							For nI := 1 To oModel:GetModel('CPIDETAIL'):Length()
								//Posicionar o registro no banco
								oModel:GetModel('CPIDETAIL'):GoLine(nI)
								cTipo	:= oModel:GetModel('CPIDETAIL'):GetValue('CPI_TIPO')
								cCodOrg := oModel:GetModel('CPIDETAIL'):GetValue('CPI_CODORG')
								
								CPI->(DbGoTop())
								CPI->(DbSetOrder(1)) //CPI_FILIAL+CPI_CODEDT+CPI_NUMPRO+CPI_CODORG+CPI_TIPO+CPI_CODPRO+CPI_LOTE							
								
								If CPI->(DbSeek(xFilial('CPI')+cCodEdt+cNumPro+cCodOrg+cTipo+cCodPro+cLote))
									RecLock("CPI",.F.)
									CPI->CPI_NUMATA := cNumAta
									CPI->(MsUnLock())
								EndIf
							Next nI
						EndIf
					Next nX
				Next nY
				RestArea(aAreaCPI)
			EndIf
			
			If IsInCallStack("GCPA300Prz")
				cJust := _cJusti
				If  IsBlind() .Or. GCP300Dlg(@cJust, STR0086)		//'Informe a Justificativa do Cancelamento da Ata'
					GCP300AtSt(ST_PUBLICA,cJust ,/*lPublic*/,/*dDataDe*/,'3' )
				EndIf
			EndIf							
		Else
			DisarmTransaction()
		EndIf	
			
	End Transaction	

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A300GetRep()
Função para verificar se foi reajustado algum valor na Ata e gerar nota de empenho.

@author taniel.silva	
@since 30/01/2015
@version 1.0
@return lRet
/*/
//--------------------------------------------------------------------
Function A300GetRep(oModel)
Local oCPYDetail	:= oModel:GetModel('CPYDETAIL')
Local oCX3detail	:= oModel:GetModel('CX3DETAIL')
Local oCX6Detail	:= Nil
Local nX			:= 0
Local nY			:= 0
Local nZ			:= 0
Local lRet			:= .T.
Local aRepac 		:= {}
Local aRepacNew 	:= {}
Local lLote			:=	GCP301Lote( oModel:GetValue( "CPHMASTER" , "CPH_NUMATA" ) , .T. )

If lLote
	
	CPY->(DbSetOrder(2))
	
	oCX6Detail	:= oModel:GetModel('CX6DETAIL')
	
	For nX := 1 To oCX6Detail:Length()	//-- Percorre Lotes
		
		oCX6Detail:GoLine(nX)
		
		For nY := 1 To oCPYDetail:Length()	//-- Percorre Itens do Lote
			
			oCPYDetail:GoLine(nX)
			
			If oCPYDetail:GetValue( 'CPY_PERCRJ' ) > 0 //-- Verifica se item sofreu reajuste 
			
				If CPY->( dbSeek( xFilial('CPY') + oCPYDetail:GetValue('CPY_NUMATA') + oCPYDetail:GetValue('CPY_LOTE') + oCPYDetail:GetValue('CPY_CODPRO') ) )
				
						aAdd( aRepac , {} )
				  		aAdd( aTail( aRepac ) , oCX3Detail:GetValue( 'CX3_CODNE' ) )	//-- Codigo da Nota de Empenho
				  		aAdd( aTail( aRepac ) , oCX3Detail:GetValue( 'CX3_ITEMNE' ) )	//-- Item da Nota de Empenho
				  		aAdd( aTail( aRepac ) , CPY->CPY_VALATU )  						//-- Valor Antigo do Item
				  		aAdd( aTail( aRepac ) , oCPYDetail:GetValue( 'CPY_VALATU' ) )  //-- Novo Valor do Item
											
				EndIf
			
			EndIf
			 
		Next nY
		
	Next nX
	
Else
	
	CPY->(DbSetOrder(1))
	
	For nX := 1 To oCPYDetail:Length() //-- Percorre itens da Ata
		
		oCPYDetail:GoLine(nX)
			
		If oCPYDetail:GetValue( 'CPY_PERCRJ' ) > 0 //-- Verifica se item sofreu reajuste 
			
			If CPY->( dbSeek( xFilial('CPY') + oCPYDetail:GetValue('CPY_NUMATA') + oCPYDetail:GetValue('CPY_LOTE') + oCPYDetail:GetValue('CPY_CODPRO') ) )
					
					aAdd( aRepac , {} )
			  		aAdd( aTail( aRepac ) , oCX3Detail:GetValue( 'CX3_CODNE' ) )	//-- Codigo da Nota de Empenho
			  		aAdd( aTail( aRepac ) , oCX3Detail:GetValue( 'CX3_ITEMNE' ) )	//-- Item da Nota de Empenho
			  		aAdd( aTail( aRepac ) , CPY->CPY_VALATU )  						//-- Valor Antigo do Item
			  		aAdd( aTail( aRepac ) , oCPYDetail:GetValue( 'CPY_VALATU' ) )  //-- Novo Valor do Item
			  		
			EndIf
		
		EndIf
		 
	Next nX
		
EndIf

//Aglutina os itens por nota de empenho
For nZ := 1 To Len(aRepac)

 	nPos := aScan(aRepacNew,{|x| AllTrim(x[1])== AllTrim(aRepac[nZ][1])}) 
 	
 	If nPos > 0
		aAdd( aRepacNew[nPos] , { aRepac[nZ][2] , aRepac[nZ][3] , aRepac[nZ][4] } )	
	Else		
		aAdd( aRepacNew , {} )
		aAdd( aTail( aRepacNew ) , aRepac[nZ][1] )
		aAdd( aTail( aRepacNew ) , { aRepac[nZ][2] , aRepac[nZ][3] , aRepac[nZ][4] } )
	EndIf
		
Next nZ

If !Empty(aRepacNew)
	lRet := GCPXRefCan(aRepacNew)
EndIf

Return lRet



/*-------------------------------------------------------------------
{Protheus.doc} GCP200CScs()
Função que retorna a quantidade total das SC's de um produto	

@author Matheus Lando
@since 11/11/2013
@version P11.90
-------------------------------------------------------------------*/
Function GCP300QtSc(oModel)
Local nRet := 0
Local nI	:= 0
Local oCX3Detail := oModel:GetModel('CX3DETAIL')
Local aSaveLines	:= FWSaveRows()

For nI := 1 To oCX3Detail:Length()
	oCX3Detail:GoLine(nI)	
	nRet += oCX3Detail:GetValue('CX3_QUANT')				
Next nI
	
FWRestRows( aSaveLines )

Return nRet

/*-------------------------------------------------------------------
{Protheus.doc} A300VldScs()
Função que valida as scs de compra selecionadas	

@author Matheus Lando
@since 11/11/2013
@version P11.90
-------------------------------------------------------------------*/
Function A300VldScs(oModel,aSolComp,aHeader)
Local oCPYDetail	:= oModel:GetModel('CPYDETAIL')
Local nI			:= 0
Local nPos			:= 0
Local lRet			:= .T.
Local lIncManual	:= .F.
Local aProdAux	:= {}
 
CO1->(DbSetOrder(1))	
lIncManual := !CO1->(DbSeek(xFilial("CO1")+oModel:GetModel("CPHMASTER"):GetValue("CPH_CODEDT")))

If !lIncManual
	For nI := 1 To Len(aSolComp)
		If (aSolComp[nI,  1])
			nPos := aScan( aProdAux, {|x| AllTrim(x[1]) == AllTrim(aSolComp[nI,GDFieldPos("C1_PRODUTO",aHeader) + 1])} )
			If nPos > 0
				aProdAux[nPos, 2] += aSolComp[nI, GDFieldPos("C1_QUANT",aHeader) + 1]
			Else	 			
				Aadd(aProdAux,{aSolComp[nI, GDFieldPos("C1_PRODUTO",aHeader) + 1], aSolComp[nI, GDFieldPos("C1_QUANT",aHeader) + 1]}) 
			EndIf
		EndIf					
	Next nI
	
	For nI	:= 1 To oCPYDetail:Length()	
		oCPYDetail:GoLine(nI)
		If !oCPYDetail:IsDeleted()
			nPos := aScan( aProdAux, {|x| AllTrim(x[1]) == AllTrim(oCPYDetail:GetValue('CPY_CODPRO'))}) 
			If nPos > 0 .And. aProdAux[nPos, 2] > (oCPYDetail:GetValue('CPY_QUANT') - GCP300QtSc(oModel))
				Help("",1,"A300QT")//As solicitações não podem ser carregadas pois excedem a quantidade licitada.
				lRet := .F.
				Exit				
			EndIf
		EndIf	
	Next nI
EndIf	

Return lRet

/*-------------------------------------------------------------------
{Protheus.doc} A400VldNe()
Função que valida as reservas com o saldo da NE	

@author Matheus Lando
@since 11/11/2013
@version P11.90
-------------------------------------------------------------------*/
Function A400VldNe()
Local lRet := .F.
Local oModel := FwModelActive()
Local oCPEDetail := oModel:GetModel('CPEDETAIL')
Local oCPZDetail := oModel:GetModel('CPZDETAIL')
Local oCPYDetail := oModel:GetModel('CPYDETAIL')
Local aSaveLines	:= FWSaveRows()
Local aResAgluNE	:= {}
Local nX	:= 0
Local lAltera := IIf(oModel:GetOperation() == MODEL_OPERATION_UPDATE,.T.,.F.)

For nX := 1 To oCPEDetail:Length()
	oCPEDetail:GoLine(nX)		
	If !oCPEDetail:IsDeleted() .And. !oCPEDetail:GetValue('CPE_OK')			
		If (nPosRep := aScan(aResAgluNE,{|x| AllTrim(x[1]) + AllTrim(x[2]) + AllTrim(x[3]) == AllTrim(oCPEDetail:GetValue('CPE_CODPRO')) + AllTrim(oCPEDetail:GetValue('CPE_CODNE')) + AllTrim(oCPEDetail:GetValue('CPE_ITEMNE'))}) ) > 0
			aResAgluNE[nPosRep][4]+= oCPEDetail:GetValue('CPE_QUANT') * oCPYDetail:GetValue('CPY_VALATU')
		Else
			aAdd(aResAgluNE,{oCPYDetail:GetValue('CPY_CODPRO'),oCPEDetail:GetValue('CPE_CODNE'),oCPEDetail:GetValue('CPE_ITEMNE'),oCPEDetail:GetValue('CPE_QUANT') * oCPYDetail:GetValue('CPY_VALATU')})
		Endif
	Endif
Next nX

lRet := ShowDivNe(aResAgluNE,,lAltera)

FWRestRows( aSaveLines )
Return lRet

/*-------------------------------------------------------------------
{Protheus.doc} A400AtSdSc()


@author Matheus Lando
@since 11/11/2013
@version P11.90
-------------------------------------------------------------------*/
Function A400AtSdSc(cNewSC,cNewItem,nNewQuant,cCampo,lDelete,lUnDelete)
Local oModel 		:= FwModelActive()
Local oCPEDetail 	:= oModel:GetModel('CPEDETAIL')
Local oCX3Detail 	:= oModel:GetModel('CX3DETAIL')
Local aSaveLines	:= FWSaveRows()
Local nI			:= 0
Local nX			:= 0
Local nQtTot		:= 0
Local nLinha		:= oCPEDetail:GetLine()
Local aFiltro		:= {}
Local cSC			:= ""
Local cItem		:= ""
Local nQuant		:= 0 
Local aScs      	:= {} 
Local nPos			:= 0
Local oView		:= FwViewActive()

Default lDelete := .F.
Default lUnDelete := .F.

For nI := 1 To oCPEDetail:Length()
	oCPEDetail:GoLine(nI)
	If nLinha == oCPEDetail:GetLine()
		If lDelete 
			Loop
		EndIf
		
		If !oCPEDetail:IsDeleted() .Or. lUnDelete
											
			nPos := aScan( aScs, {|x| x[1]	 + x[2]  == cNewSC + cNewItem } )
			If nPos > 0
				aScs[nPos, 3] += nNewQuant
			Else
				Aadd(aScs, {cNewSC,cNewItem,nNewQuant})
			EndIf						
		EndIf			
	ElseIf !oCPEDetail:IsDeleted()
		nPos := aScan( aScs, {|x| x[1]	 + x[2]  == oCPEDetail:GetValue('CPE_NUMSC') + oCPEDetail:GetValue('CPE_ITEMSC') } )
		If nPos > 0
			aScs[nPos, 3] += oCPEDetail:GetValue('CPE_QUANT')
		Else
			Aadd(aScs, {oCPEDetail:GetValue('CPE_NUMSC'), oCPEDetail:GetValue('CPE_ITEMSC'),oCPEDetail:GetValue('CPE_QUANT')})
		EndIf					 		
	EndIf												
	
Next nI

oCX3Detail:SetNoUpdateLine(.F.)
For nX := 1 To oCX3Detail:Length()
	oCX3Detail:GoLine(nX)
	
	nPos := aScan( aScs, {|x| x[1]	 + x[2]  == oCX3Detail:GetValue('CX3_NUMSC') + oCX3Detail:GetValue('CX3_ITEMSC') } )
	
	If nPos > 0
		oCX3Detail:LoadValue('CX3_SALDO', oCX3Detail:GetValue('CX3_QUANT') - aScs[nPos, 3])
	Else
		oCX3Detail:LoadValue('CX3_SALDO', oCX3Detail:GetValue('CX3_QUANT') )	
	EndIf		
Next nX	
oCX3Detail:SetNoUpdateLine(.T.)
	

FWRestRows( aSaveLines )

Return 

/*-------------------------------------------------------------------
{Protheus.doc} A300VSldSC()


@author Matheus Lando
@since 11/11/2013
@version P11.90
-------------------------------------------------------------------*/
Function A300VSldSC(cSC,cItem,nQuant,nOldQuant)
Local lRet := .F.
Local oModel 		:= FwModelActive()
Local oCX3Detail 	:= oModel:GetModel('CX3DETAIL')
Local aFiltro  := {}
Local nSaldo	:= 0
Aadd(aFiltro, {'CX3_NUMSC',cSC})
Aadd(aFiltro, {'CX3_ITEMSC',cItem})

If nQuant == nOldQuant
	nOldQuant := 0
EndIf

nLinha := MTFindMVC(oCX3Detail, aFiltro)

If nLinha > 0
	oCX3Detail:GoLine(nLinha) 
	nSaldo := (oCX3Detail:GetValue('CX3_SALDO') + nOldQuant) -  nQuant
	
	If nSaldo >= 0 
		lRet := .T.
	EndIf
EndIf
Return lRet


/*-------------------------------------------------------------------
{Protheus.doc} A300VSldSC()


@author Matheus Lando
@since 11/11/2013
@version P11.90
-------------------------------------------------------------------*/
Function A300VldNE(cNE)
Local lRet := .F.
Local nI	:= 0
Local oModel 		:= FwModelActive()
Local oCX3Detail 	:= oModel:GetModel('CX3DETAIL')
Local aSaveLines	:= FWSaveRows()
Local aScs			:= {}

For nI := 1 To oCX3Detail:Length()
	oCX3Detail:GoLine(nI)
	If cNE == oCX3Detail:GetValue('CX3_CODNE')
		lRet := .T.
		Exit
	EndIf		
Next nI

FWRestRows( aSaveLines )
Return lRet

/*-------------------------------------------------------------------
{Protheus.doc} A300VSldSC()


@author Matheus Lando
@since 11/11/2013
@version P11.90
-------------------------------------------------------------------*/
Function A300VldItN(cNE,cItemNE)
Local lRet := .F.
Local nI	:= 0
Local oModel 		:= FwModelActive()
Local oCX3Detail 	:= oModel:GetModel('CX3DETAIL')
Local aSaveLines	:= FWSaveRows()
Local aScs			:= {}

For nI := 1 To oCX3Detail:Length()
	oCX3Detail:GoLine(nI)
	If cNE == oCX3Detail:GetValue('CX3_CODNE') .And. cItemNE == oCX3Detail:GetValue('CX3_ITEMNE')
		lRet := .T.
		Exit
	EndIf		
Next nI

FWRestRows( aSaveLines )
Return lRet

/*{Protheus.doc} A300VSldSC()
	Verifica se <cSC> existe no submodelo da CX3
@author Matheus Lando
@since 11/11/2013
@version P11.90
*/
Function A300VldSc(cSC, oModel)
	Local lRet 			:= .F.
	Local nI			:= 0
	Local oCX3Detail 	:= Nil
	Local aSaveLines	:= FWSaveRows()
	Default oModel 		:= FwModelActive()

	oCX3Detail 	:= oModel:GetModel('CX3DETAIL')
	For nI := 1 To oCX3Detail:Length()
		oCX3Detail:GoLine(nI)
		If cSC == oCX3Detail:GetValue('CX3_NUMSC')
			lRet := .T.
			Exit
		EndIf
	Next nI

	FWRestRows( aSaveLines )
	FwFreeArray(aSaveLines)
Return lRet

/*{Protheus.doc} A300VldItS()
	Verifica se a chave <cSC> e <cItemSC> estão presentes no submodelo CX3DETAIL
@author Matheus Lando
@since 11/11/2013
@version P11.90
*/
Function A300VldItS(cSC,cItemSC)
	Local lRet			:= .F.
	Local nI			:= 0
	Local oModel 		:= FwModelActive()
	Local oCX3Detail 	:= oModel:GetModel('CX3DETAIL')
	Local aSaveLines	:= FWSaveRows()

	For nI := 1 To oCX3Detail:Length()
		oCX3Detail:GoLine(nI)
		If cSC == oCX3Detail:GetValue('CX3_NUMSC') .And. cItemSC == oCX3Detail:GetValue('CX3_ITEMSC')
			lRet := .T.
			Exit
		EndIf		
	Next nI

	FWRestRows( aSaveLines )
	FwFreeArray( aSaveLines )
Return lRet

/*-------------------------------------------------------------------
{Protheus.doc} GCP200CScs()
Função que retorna a quantidade total das SC's de um produto	

@author Matheus Lando
@since 11/11/2013
@version P11.90
-------------------------------------------------------------------*/
Function A300QtSC(oModel)
Local nRet := 0
Local nI	:= 0
Local oCX3Detail := oModel:GetModel('CX3DETAIL')
Local aSaveLines	:= FWSaveRows()

For nI := 1 To oCX3Detail:Length()
	oCX3Detail:GoLine(nI)
	If !oCX3Detail:Isdeleted()
		nRet += oCX3Detail:GetValue('CX3_QUANT')
	EndIf		
Next nI
	
FWRestRows( aSaveLines )

Return nRet

/*-------------------------------------------------------------------
{Protheus.doc} GCP200CScs()
Função que retorna a quantidade total das SC's de um produto

@author Matheus Lando
@since 11/11/2013
@version P11.90
-------------------------------------------------------------------*/
Function A300VQt()
Local lRet := .T.
Local nI	:= 0
Local oModel := FwModelActive()
Local oCPYDetail := oModel:GetModel('CPYDETAIL')
Local lIncManual	:= .F.

CO1->(DbSetOrder(1))	
lIncManual := !CO1->(DbSeek(xFilial("CO1")+oModel:GetModel("CPHMASTER"):GetValue("CPH_CODEDT")))

If SuperGetMV("MV_NOTAEMP",.F.,.F.) .And. lIncManual
	If oCPYDetail:GetValue('CPY_QUANT') <> A300QtSC(oModel)
		lRet := .F.
		Help("",1,"A300VQTD")//É necessário que a quantidade dos produtos seja igual a quantidade das solicitações de compra.
	EndIf		 		
EndIf	
	
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A300VldFor
Função para validar o mesmo fornecedor na ATA.

@author taniel.silva

@Param oModel - Modelo ativo
@since 02/03/2015		
@version P12
@return lRet
/*/
//-------------------------------------------------------------------
Function A300VldFor(oModel)
Local oCPYDetail := oModel:GetModel('CPYDETAIL')
Local oCPZDetail := oModel:GetModel('CPZDETAIL')
Local nX		:= 0
Local nZ		:= 0
Local lRet		:= .T.
Local aForn	:= {}

For nX := 1 To oCPYDetail:Length()
	oCPYDetail:GoLine(nX)
	If !oCPYDetail:GetValue("CPY_REMAN")
		For nZ := 1 To oCPZDetail:Length()
			oCPZDetail:GoLine(nZ)		
			If !oCPZDetail:IsDeleted() .And. oCPZDetail:GetValue('CPZ_STATUS') == "5"	
				If aScan( aForn, {|x| AllTrim(x[1]) == AllTrim(oCPZDetail:GetValue("CPZ_CODIGO"))} ) = 0
					aAdd(aForn, {oCPZDetail:GetValue("CPZ_CODIGO")})
				EndIf			
			EndIf		
		Next nZ	
	EndIf
Next nX	

If Len(aForn) > 1
	lRet := .F.
	Help("",1,"A300VldFor")//O Fornecedor ganhador deve ser o mesmo para todos os produto.
Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A300VldFor
Função para validar a inclusão de um fornecedor com o status ganhador.

@author taniel.silva

@Param oModel - Modelo ativo
@since 02/03/2015		
@version P12
@return lRet
/*/
//-------------------------------------------------------------------
Function A300StaFor(oModel)
Local lRet			:= .F.
Local lLote			:= oModel:GetId() == "GCPA301"
Local oModelCPZ		:= oModel:GetModel("CPZDETAIL")
Local oModelItem	:= Iif( lLote , oModel:GetModel("CX6DETAIL"), oModel:GetModel("CPYDETAIL"))
Local nContVenc		:= 0
Local nY			:= 0
Local nZ			:= 0

For nY := 1 To oModelItem:Length()
	nContVenc := 0
	oModelItem:GoLine(nY)
	If !oModelItem:IsDeleted()
		For nZ := 1 To  oModelCPZ:Length()
			oModelCPZ:GoLine(nZ)			 
			If !oModelCPZ:IsDeleted() .And. !Empty( oModelCPZ:GetValue('CPZ_CODIGO')) .And. oModelCPZ:GetValue('CPZ_STATUS') == "5"				
				nContVenc ++
			EndIf							
		Next nZ	
	EndIf
Next nY

If nContVenc == 0
	Help("",1,"A300StaFor")//É necessário selecionar um fornecedor ganhador.
	lRet := .F.
ElseIf nContVenc > 1
	If lLote
		Help("",1,"A300VenLot",,STR0093,1,1)//"Existem lotes com mais de um ganhador selecionado."
	Else
		Help("",1,"A300VenItm",,STR0094,1,1)//"Existem itens com mais de um ganhador selecionado."
	EndIF
	lRet := .F.
Else
	lRet := .T.
EndIf
	
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A300CPILeg
Função para inicializa legenda, sendo Verde: Gerenciador / Azul:  Participante /
 Amarelo: Carona

@author barbara.reis

@Param 
@since 21/05/2015		
@version P12
@return cRet
/*/
//-------------------------------------------------------------------

Function A300CPILeg()
Local oModel := FwModelActive()
Local cRet := "BR_AMARELO" 

If (CPI->CPI_CODORG == CPH->CPH_CODORG)
	cRet := "BR_VERDE"
ElseIf (oModel:GetOperation() <> 3 .And. CPI->CPI_TIPO == '1') .Or. IsInCallStack('GCP200SRP')
	cRet := "BR_AZUL"
Else 
	cRet := "BR_AMARELO"  		
EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A300CPILeg
Função para controlar a reserva de produtos para o Orgão Gerenciador (Validação de campos)

@author miguel.santos

@Param 
@since 27/05/2015		
@version P12
@return lRet
/*/
//-------------------------------------------------------------------
Function A300WhnEmp()
Local oModel := FwModelActive()
Local oCPIDetail := oModel:GetModel('CPIDETAIL')
Local oCPHMaster := oModel:GetModel('CPHMASTER')

lRet := SuperGetMV("MV_NOTAEMP",.F.,.F.) .And. (oCPHMaster:GetValue('CPH_CODORG') == oCPIDetail:GetValue('CPI_CODORG') ;
																		.Or. !Empty(oCPIDetail:GetValue('CPI_FILENT'))) 
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A300SetCPI(aRec)
Seta Valores na variavel statica aRecCPI

@author Matheus Lando

@Param 
@since 08/07/2015		
@version P12
@return lRet
/*/
//-------------------------------------------------------------------
Function A300SetCPI(aRec)
aRecCPI := aRec
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} A300GtlSld()
Gatilho do campos CPI_SALDO

@author Matheus Lando

@Param 
@since 24/02/2016		
@version P12
@return lRet
/*/
//-------------------------------------------------------------------
Function A300GtlSld()
Local oModel := FwModelActive()
Local oCPIDetail := oModel:GetModel('CPIDETAIL')
Local nPos 	:= 0
Local nRet		:= 0 

If IsInCallStack('GCP300Manu')
	nRet := oCPIDetail:GetValue('CPI_SALDO') -(oCPIDetail:GetValue('CPI_QTDRES')+oCPIDetail:GetValue('CPI_QTDCON'))
Else
	nRet := oCPIDetail:GetValue('CPI_QTDLIC')-(oCPIDetail:GetValue('CPI_QTDRES')+oCPIDetail:GetValue('CPI_QTDCON'))                              
EndIf	                               

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GCPA300Prz()
Função de alteração do prazo e quantidade da Ata

@author Matheus Lando

@Param 
@since 02/03/2016		
@version P12
@return lRet
/*/
//-------------------------------------------------------------------
Function GCPA300Prz()
Local cModel	:= Iif( GCP301Lote() , 'GCPA301' , 'GCPA300' )

If (CPH->CPH_STATUS == "3" .Or. CPH->CPH_STATUS == "6")
	nGravou := FWExecView ( '' , cModel , MODEL_OPERATION_UPDATE , /*oDlg*/ , {||.T.} , /*bOk*/ , /*nPercReducao*/ , /*aEnableButtons*/ ,  /*bCancel*/ )
Else
	Help("",1,'GCPA300ADT',,STR0092,4,1)
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} A300VlDtFim()
Validação do campo CPH_VGATAF

@author Matheus Lando

@Param 
@since 02/03/2016		
@version P12
@return lRet
/*/
//-------------------------------------------------------------------
Function A300VlDtFim()
Local oModel	:= FwModelActive()
Local oCPHMaster	:= oModel:GetModel('CPHMASTER')
Local dDataLim	:= YearSum(oCPHMaster:GetValue('CPH_VGATAI'),2)
Local cStatus	:= oCPHMaster:GetValue('CPH_STATUS')
Local lAdita	:= IsInCallStack("GCPA300Prz")
Local lInclui	:= IsInCallStack("GCP300Incl")
Local lRet 		:= .T.

If !lInclui .And. oCPHMaster:GetValue('CPH_VGATAF') <= GetDBValue('CPH','CPH_VGATAF',oCPHMaster:GetDataId())
	lRet := .F.	
	Help("",1,'GCPA300NDT',,STR0060,4,1) //"A data fim não pode ser menor do que a data fim atual"
ElseIf lInclui .And. oCPHMaster:GetValue('CPH_VGATAF') < oCPHMaster:GetValue('CPH_VGATAI')
	lRet := .F.	
	Help("",1,'GCPA300NDT',,STR0061,4,1) //"A data fim não pode ser menor do que a data de inicio da Ata"
EndIf

If lRet .And. cStatus == '3' .And. !lAdita .And. (oCPHMaster:GetValue('CPH_VGATAF')-oCPHMaster:GetValue('CPH_VGATAI') > 365) 
	lRet := .F.
	Help(' ', 1, 'A300VIG365',,STR0062,4,1) //"Vigencia da Ata não pode ser superior a 365 dias!"
EndIf

If lRet .And. lAdita 
	If oCPHMaster:GetValue('CPH_VGATAF') > dDataLim
		lRet := .F.	
		Help("",1,'GCPA300DINVL',,STR0063 + DToc(dDataLim),4,1) //"A data fim da Ata não pode ultrapassar dois anos de sua publicação, informe uma data menor ou igual a "
	EndIf 
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A300VldQtd()
Validação do campo CPY_QUANT

@author Matheus Lando

@Param 
@since 02/03/2016		
@version P12
@return lRet
/*/
//-------------------------------------------------------------------
Function A300VldQtd()
Local lRet := .T.
Local oModel	:= FwModelActive()
Local oCPYDetail	:= oModel:GetModel('CPYDETAIL')
Local nQtdMax		:= 0
Local cRecno := oCPYDetail:GetDataId()

If IsInCallStack("GCPA300Prz")
	nQtdMax := (oCPYDetail:GetValue('CPY_QTDLIC') * 2) + ( (oCPYDetail:GetValue('CPY_QTDLIC') / 100) * 25 )   
	If oCPYDetail:GetValue('CPY_QUANT') > nQtdMax			
		Help("",1,'GCPA300QTIN',, STR0087 + ' ' + Transform(nQtdMax,"@E 999,999,999.99") + ' ' + STR0088  ,4,1)
		lRet := .F. 	
	ElseIf oCPYDetail:GetValue('CPY_QUANT') < oCPYDetail:GetValue('CPY_QTDLIC')
		Help("",1,'GCPA300QTIN',, STR0089 ,4,1)
		lRet := .F.
	ElseIf oCPYDetail:GetValue('CPY_QUANT') < GetDBValue('CPY','CPY_QUANT',cRecno)
		Help("",1,'GCPA300QTAN',,STR0090 ,4,1)
		lRet := .F.
	EndIf 
	
	If lRet	
		oCPYDetail:LoadValue('CPY_SALDO',GetDBValue('CPY','CPY_SALDO',cRecno) + ;
								( oCPYDetail:GetValue('CPY_QUANT') - GetDBValue('CPY','CPY_QUANT',cRecno)))
	EndIf
EndIf	

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A300VlProd()
Validação do campo CPY_CODPRO

@author jose.delmondes

@Param 
@since 29/06/2017		
@version P12
@return lRet
/*/
//-------------------------------------------------------------------
Function A300VlProd()
Local oModel	:= FwModelActive()
Local lLote	:= oModel:GetId() == 'GCPA301'
Local lRet		:= .T.

If lLote .And. Empty( oModel:GetValue( "CX6DETAIL" , "CX6_LOTE" ) ) 
	lRet := .F.
	Help( '' , 1 , 'GCP300LOTE' )
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GCP300Tot()
Valid do campo CPY_VLTOT

@author jose.delmondes

@Param xOldValue: Valor antigo do campo
@since 29/06/2017		
@version P12
@return lRet
/*/
//-------------------------------------------------------------------
Function GCP300Tot(xOldValue)
Local oModel	:= FwModelActive()
Local oModelCPY	:= oModel:GetModel("CPYDETAIL")
Local lLote	:= oModel:GetId() == "GCPA301"
Local oModelCX6	:= Iif( lLote , oModel:GetModel("CX6DETAIL") , Nil ) 
Local lRet	:= .T.

// Valida o Valor total do item
If Round(oModelCPY:GetValue("CPY_VLTOT"),TamSX3("CPY_VLTOT")[2]) <> Round( oModelCPY:GetValue("CPY_QUANT") * oModelCPY:GetValue("CPY_VALATU") , TamSX3("CPY_VLTOT")[2]  )
	lRet := .F.
EndIf

// Atualiza valor do lote
If lRet .And. lLote 
	oModelCX6:LoadValue( "CX6_VLRTOT" , oModelCX6:GetValue("CX6_VLRTOT") + ( oModelCPY:GetValue("CPY_VLTOT") - xOldValue )  )
	oModelCX6:LoadValue( "CX6_SLDLOT" , oModelCX6:GetValue("CX6_SLDLOT") + ( oModelCPY:GetValue("CPY_VLTOT") - xOldValue )  )
EndIf

If GetRepact()
	oModelCPY:LoadValue( "CPY_VALRRJ" , oModelCPY:GetValue("CPY_VALRRJ") + ( oModelCPY:GetValue("CPY_VLTOT") - xOldValue ) )
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GCP300Reaj()
Reajusta valores da Ata

@author jose.delmondes

@since 05/07/2017		
@version P12
@return lRet
/*/
//-------------------------------------------------------------------
Function GCP300Rep()
Local cModel	:= Iif( GCP301Lote() , 'GCPA301' , 'GCPA300' )

SetRepact(.T.)

    FWExecView ( '' , cModel , MODEL_OPERATION_UPDATE , /*oDlg*/ , {||.T.} , /*bOk*/ , /*nPercReducao*/ , /*aEnableButtons*/ ,  /*bCancel*/ )

SetRepact(.F.)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GetRepact()
Retorna o conteúdo da variavel lRepact

@author jose.delmondes

@since 05/07/2017		
@version P12
@return lRepact
/*/
//-------------------------------------------------------------------
Function GetRepact()

Return lRepact

//-------------------------------------------------------------------
/*/{Protheus.doc} SetRepact()
Altera o valor da variavel lRepact

@author jose.delmondes

@since 05/07/2017		
@version P12
@return Não possui
/*/
//-------------------------------------------------------------------
Function SetRepact(lConteudo)

lRepact := lConteudo

Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} GCP300GatR()
Gatilho para preenchimento do valor atual, ao executar repactuação de preços

@author jose.delmondes

@since 05/07/2017		
@version P12
@return Valor Unitário atual do produto
/*/
//-------------------------------------------------------------------
Function GCP300GatR()
Local nVal	:= Posicione( 'CPY' , 2 , xFilial('CPY') + FwFldGet('CPY_NUMATA') + FwFldGet('CPY_LOTE') + FwFldGet('CPY_CODPRO') , 'CPY_VALATU' )

nVal	:= nVal + ( ( FwFldGet("CPY_PERCRJ") / 100 ) * nVal )

Return nVal

//-------------------------------------------------------------------
/*/{Protheus.doc} A300VldGer()
Valida orgão gerenciador para que não seja Carona na Ata
Valid ->(CPI_CODORG)

@author antenor.silva	
@since 30/10/2017
@version 1.0
@return Nil
/*/
//--------------------------------------------------------------------
Function A300VldGer() 
Local oModel	:= Nil
Local oModelCPH := Nil
Local oModelCPI	:= Nil

Local cCodOrgCPH:= ""
Local cCodOrgCPI:= ""

Local lMod		:= IsInCallStack('GCP300Incl')
Local lRet		:= .T. 

If lMod
	
	oModel	:= FWModelActive()
	oModelCPH := oModel:GetModel("CPHMASTER")
	oModelCPI	:= oModel:GetModel("CPIDETAIL")
	
	cCodOrgCPH:= AllTrim(oModelCPH:GetValue("CPH_CODORG"))
	cCodOrgCPI:= Alltrim(oModelCPI:GetValue("CPI_CODORG"))
	
	If cCodOrgCPH == cCodOrgCPI
		lRet := .F.
		Help("", 1, "GCP300VldG") //'Orgão gerenciador da ata não pode ser incluído como carona!
	EndIf

EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} P300ultPb()
função que retorna a data da ultima publicação

@author Vitor Pires
@since 12/09/2017
@version P12
@return dDataUlPb
/*/
//-------------------------------------------------------------------
Function P300ultPb()
Local dDataUlPb := cTod('')

//Pega a última data de publicação.
If !Empty(CPH->CPH_DTPB4)
	dDataUlPb := CPH->CPH_DTPB4	
ElseIf !Empty(CPH->CPH_DTPB3)
	dDataUlPb := CPH->CPH_DTPB3
ElseIf !Empty(CPH->CPH_DTPB2)
	dDataUlPb := CPH->CPH_DTPB2
ElseIf !Empty(CPH->CPH_DTPB1)
	dDataUlPb := CPH->CPH_DTPB1
EndIf

Return(dDataUlPb)

/*/{Protheus.doc} CalcSald
	Gatilho chamado na alteração do campo CPY_QUANT para
	atualizar o valor do campo CPY_SALDO.
@author PHILIPE.POMPEU
@since 20/03/2019
@return nResult, novo valor de CPY_SALDO
@param oModel, object, modelo do fonte GCPA300
/*/
Static Function CalcSald(oMdlCpy)
	Local nResult	:= 0
	Local oModel	:= oMdlCpy:GetModel()
	Local oMdlCPI	:= oModel:GetModel('CPIDETAIL')
	Local nI		:= 0
	Local aSaveLines	:= FWSaveRows()
	
	For nI := 1 To oMdlCPI:Length()
		oMdlCPI:GoLine(nI)
		If !oMdlCPI:IsDeleted()					
			nResult += oMdlCPI:GetValue('CPI_QTDCON')
		EndIf
	Next nI
	/*A quantidade total solicitada menos o total já consumido(soma de CPI_QTDCON)*/
	nResult := oMdlCpy:GetValue('CPY_QUANT') - nResult
	
	FWRestRows(aSaveLines)
Return nResult

/*/{Protheus.doc} G300SetJus
	Seta justificativa para repactuação
@author juan.felipe
@since 26/08/2021
@param cJust, string, justificativa.
@return Nil, nulo.
/*/
Function G300SetJus(cJust)
    _cJusti := cJust
Return Nil

/*/{Protheus.doc} G300GetJus
	Obtém justificativa da repactuação
@author juan.felipe
@since 26/08/2021
@return _cJusti, justificativa.
/*/
Function G300GetJus()
Return _cJusti

/*/{Protheus.doc} GetSaldoSC
	Retorna o saldo de uma SC subtraindo a quantidade já reservada
@author julio.silva
@since 01/02/2022
@param cNumSC,Caracter, número da solicitação de compra
@param ItemSC, Caracter, item da solicitação de compra 
/*/
Static Function GetSaldoSC(cNumSC,cItemSC)
	Local oModel 	 := FwModelActive()
	Local oCPEDetail := oModel:GetModel('CPEDETAIL')
	Local oCX3Detail := oModel:GetModel('CX3DETAIL')
	Local nSaldoSC	 := 0
	Local nLinhaCX3	 := 0
	Local nI		 := 0
	Local aSaveLines := {}
	Local nLinha	 := oCPEDetail:nLine

	If (nLinhaCX3 := MTFindMVC(oCX3Detail, {{'CX3_NUMSC',cNumSC},{'CX3_ITEMSC',cItemSC}})) > 0
		aSaveLines	:= FWSaveRows()
		oCX3Detail:GoLine(nLinhaCX3) 
		nSaldoSC := oCX3Detail:GetValue('CX3_QUANT') 
		For nI := 1 To oCPEDetail:Length()
			If nLinha <> nI
				oCPEDetail:GoLine(nI)
				If !oCPEDetail:IsDeleted()	
					If oCPEDetail:GetValue('CPE_NUMSC') == cNumSC .And. oCPEDetail:GetValue('CPE_ITEMSC') == cItemSC
						nSaldoSC -= oCPEDetail:GetValue('CPE_QUANT')
					EndIf
				EndIf
			EndIf
		Next nI
	EndIf
	FWRestRows(aSaveLines)
	FWFreeArray(aSaveLines)
Return nSaldoSC


/*/{Protheus.doc} VldCPEQtd
	Valid do campo CPE_QUANT
@author jose.souza2
@since 24/02/2022
@param oModelCPE,Objeto,Instância de CPEDETAIL
@param nQuant,Numérico, Quantidade informada no campo CPE_QUANT
@return lRet
*/
Function VldCPEQtd(oModelCPE, nQuant)
	Local lRet			:= .T.	
	Local nSaldoSC		:= 0	
	Local cNumSC		:= oModelCPE:GetValue('CPE_NUMSC')
	Local cItemSC		:= oModelCPE:GetValue('CPE_ITEMSC')

 	If !Empty(cNumSC) .And. !Empty(cItemSC) .And. nQuant > 0
		nSaldoSC := GetSaldoSC(cNumSC,cItemSC)
 		If nQuant > nSaldoSC
 			Help( "" , 1 , "A300SLDSC",,STR0103,1,0)	//Quantidade informada é superior ao saldo da solicitação de compra
 			lRet := .F.
 		EndIf
	EndIf
Return lRet


/*/{Protheus.doc} VldCPEItSC
	Valid do campo CPE_ITEMSC
@author jose.souza2
@since 24/02/2022
@param oModelCPE,Objeto,Instância de CPEDETAIL
@param cItemSC,Caracter, Item informado no campo CPE_ITEMSC
@return lRet
*/
Function VldCPEItSC(oModelCPE,cItemSC)
	Local lRet			:= .T.
	Local cNumSC		:= oModelCPE:GetValue("CPE_NUMSC")
	Local oModel		:= oModelCPE:GetModel()
	Local lCarona		:= oModel:GetValue("CPIDETAIL","CPI_TIPO") == "2"

	If !Empty(cNumSC) .And. Empty(cItemSC)
		Help( "" , 1 , "A300INFITE",,STR0104,1,0)	// Informe o item da solicitação de compra
		lRet := .F.
	EndIf

	If lRet.And. !lCarona .And. !A300VldItS(oModelCPE:GetValue('CPE_NUMSC'),cItemSC)
		lRet := .F.
		Help(' ', 1, 'A300CPENITSC',,STR0095, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0096}) //Item da solicitação de compra inválido
																						//Informe um item da solicitação de compra informada, listado em Solicitações
	EndIf

	If lRet
		lRet:= VldCPEQtd(oModelCPE, oModelCPE:GetValue("CPE_QUANT"))
	EndIf
Return lRet

/*/{Protheus.doc} VldCPENSC
	Valid do campo CPE_NUMSC
@author jose.souza2
@since 24/02/2022
@param oModelCPE,Objeto,Instância de CPEDETAIL
@param cNumSC,Caracter, Quantidade informada no campo CPE_NUMSC
@return lRet
*/
Function VldCPENSC(oModelCPE, cNumSC)
	Local lRet			:= .T.
	Local oModel    	:= oModelCPE:GetModel()
	Local oModelCX3		:= oModel:GetModel('CX3DETAIL')

	If oModelCX3:Length() > 0		
		If !(lRet := A300VldSc(cNumSC, oModel))
			Help("", 1, "A300CPENSC",,STR0099, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0100})//Informe uma solicitação de compra listada na aba Solicitações
																						//Número da solicitação de compra inválido.
		EndIf
	EndIf
Return lRet

/*/{Protheus.doc} CPETrigNSC
	Gatilha o número da solicitação de compra e o item da solicitação ao informar conteúdo no campo CPE_QUANT
@author jose.souza2
@since 02/03/2022
@param oModelCPE,Objeto,Instância de CPEDETAIL
@return
*/
Function CPETrigNSC(oModelCPE)
	Local oModel		:= oModelCPE:GetModel()
	Local oCX3Detail	:= oModel:GetModel("CX3DETAIL")
	Local oModelCPI		:= oModel:GetModel('CPIDETAIL')
	Local nX			:= 0
	Local aSaveLines	:= FWSaveRows()
	Local nSaldoSC		:= 0
	Local cFilEnt		:= oModelCPI:GetValue('CPI_FILENT')
	Local cNumSc		:= ""

	oModelCPI:SetValue('CPI_QTDRES',oModel:GetValue('CALC_CPI','CPI_QTDRES'))
	For nX := 1 To oCX3Detail:Length()
		oCX3Detail:GoLine(nX) 
		If oCX3Detail:GetValue('CX3_FILENT') == cFilEnt .Or. Empty(cFilEnt) 
			nSaldoSC := GetSaldoSC(oCX3Detail:GetValue('CX3_NUMSC'),oCX3Detail:GetValue('CX3_ITEMSC'))
			If nSaldoSC >= oModelCPE:GetValue('CPE_QUANT')
				cNumSC:= oCX3Detail:GetValue('CX3_NUMSC')
				oModelCPE:LoadValue('CPE_ITEMSC',oCX3Detail:GetValue('CX3_ITEMSC'))
				Exit
			EndIf
		EndIf
	Next nX

	FWRestRows(aSaveLines)
	FWFreeArray(aSaveLines)
Return cNumSC

/*/{Protheus.doc} CPEConfMdl
	Configura em <oModel> o submodelo dos Controle de Saldos(CPEDETAIL)
@author philipe.pompeu
@since 03/03/2022
@return oModel, objeto, instância de MPFormModel
/*/
Function CPEConfMdl(oModel)
	Local oStruCPE 	:= FWFormStruct(1, 'CPE')
	Local bVldQuant	:= MTBlcVld("CPE","CPE_QUANT"	,"VldCPEQtd(a,c)"	,.F.,.F.,.T.)	
	Local bVldNumSC	:= MTBlcVld("CPE","CPE_NUMSC"	,"VldCPENSC(a,c)"	,.F.,.F.,.T.)
	Local bVldItemSC:= MTBlcVld("CPE","CPE_ITEMSC"	,"VldCPEItSC(a,c)"	,.F.,.F.,.T.)
	Local bTrigNumSC:= {|a,b,c| CPETrigNSC(a) }
	Local lLote		:= (oModel:GetId() == "GCPA301")
	Local bPreValid	:= {|oModelCPE, nLinha, cAcao,cCampo,xNewValue,xOldValue|A300CPEPVl(oModelCPE, nLinha, cAcao,cCampo,xNewValue,xOldValue)}
	Local bPosValid	:= {|oModelCPE| A300POSPVl(oModelCPE)}
	Local aRelation	:= {}
	Local bCond		:= {|x|Empty(x:GetValue('CPEDETAIL','CPE_DOCMOV'))}

	//Seta valid dos campos da CPE
	oStruCPE:SetProperty("CPE_QUANT",MODEL_FIELD_VALID	,bVldQuant )
	oStruCPE:SetProperty("CPE_NUMSC",MODEL_FIELD_VALID	,bVldNumSC )
	oStruCPE:SetProperty("CPE_ITEMSC",MODEL_FIELD_VALID	,bVldItemSC )
	oStruCPE:AddTrigger('CPE_QUANT', 'CPE_NUMSC', {|| .T. },  bTrigNumSC)
	
	oModel:AddGrid('CPEDETAIL' , 'CPIDETAIL', oStruCPE, bPreValid, bPosValid)

	oModel:AddCalc('CALC_CPI','CPIDETAIL','CPEDETAIL','CPE_QUANT','CPI_QTDRES','SUM',bCond,, RetTitle("CPI_QTDRES"))

	aAdd(aRelation, { 'CPE_FILIAL' 	, 'xFilial("CPE")' })
	aAdd(aRelation, { 'CPE_CODEDT' 	, 'CPH_CODEDT' })
	aAdd(aRelation, { 'CPE_NUMATA' 	, 'CPH_NUMATA' })
	aAdd(aRelation, { 'CPE_NUMPRO'	, 'CPH_NUMPRO' })
	aAdd(aRelation, { 'CPE_CODPRO'	, 'CPY_CODPRO' })
	aAdd(aRelation, { 'CPE_CODORG'	, 'CPI_CODORG' })
	aAdd(aRelation, { 'CPE_TIPO'	, 'CPI_TIPO' })
	If lLote
		aAdd(aRelation,{ 'CPE_LOTE' , 'CX6_LOTE' })
	EndIf

	oModel:SetRelation('CPEDETAIL'	, aRelation, CPE->(IndexKey(1)) )	

	oModel:GetModel( 'CPEDETAIL' ):SetOptional(.T.)
	oModel:GetModel( 'CPEDETAIL' ):SetDescription( STR0072 )	//'Controle de Saldo"
Return

/*/{Protheus.doc} G300SitAta
	Encapsula a manipulação da variável estática _lUpdSTAta que indica que uma operação de mudança de status está ocorrendo
@author philipe.pompeu
@since 14/10/2022
@param lSet, lógico, se deve atribuir <lValue> a variável
@param lValue, lógico, novo valor a ser atribuido a variável
@return _lUpdSTAta, lógico, valor atual da variável
/*/
Function G300SitAta(lSet as Logical, lValue as Logical)
	Default lSet	:= .F.
	Default lValue	:= .F.

	if lSet
		_lUpdSTAta := lValue
	endif
Return _lUpdSTAta

/*/{Protheus.doc} G300NewSit
	Encapsula a manipulação da variável estática _cNewSitua que indica o novo status da ata durante a operação de mudança
@author philipe.pompeu
@since 14/10/2022
@param lSet, lógico, se deve atribuir <cValue> a variável
@param cValue, caractere, novo valor a ser atribuido a variável
@return _cNewSitua, caractere, valor atual da variável
/*/
Function G300NewSit(lSet as Logical, cValue as Char)
	Default lSet	:= .F.
	Default cValue	:= ""

	if lSet
		_cNewSitua := cValue
	endif
Return _cNewSitua

/*/{Protheus.doc} G300MdlId
	Encapsula a manipulação da variável estática _cModelId, que indica qual o model/view que deve ser utilizado(por item[GCPA300] ou por lote[GCPA301])
@author philipe.pompeu
@since 14/10/2022
@param lSet, lógico, se deve atribuir <cValue> a variável
@param cValue, caractere, novo valor a ser atribuido a variável
@return _cModelId, caractere, valor atual da variável
/*/
Function G300MdlId(lSet as Logical, cValue as Char)
	Default lSet	:= .F.
	Default cValue	:= ""

	if lSet
		_cModelId := cValue
	endif
Return _cModelId

/*/{Protheus.doc} GetDescrSt
	Retorna a descrição correspondente ao status informado em <cStatus>
@author philipe.pompeu
@since 14/10/2022
@param cStatus, caractere, status que se deseja obter a descrição
@return cStNovo, caractere, descrição de <cStatus>
/*/
Static Function GetDescrSt(cStatus)
	Local cStNovo := ""
	Do Case
		Case cStatus == ST_ANALISE        
			cStNovo := STR0002	//'Em Análise'
		Case cStatus == ST_ASSINAT        
			cStNovo := STR0003	//'Aguardando Assinatura'
		Case cStatus == ST_PUBLICA        
			cStNovo := STR0004	//'Publicada'
		Case cStatus == ST_SUSPENS        
			cStNovo := STR0005	//'Suspensa'
		Case cStatus == ST_CANCELA
			cStNovo := STR0006	//'Cancelada'   	 	
		Case cStatus == ST_FINALIZ
			cStNovo := STR0007	//'Finalizada'
		Case cStatus == ST_AGRDPUB
			cStNovo := STR0008	//'Aguardando Publicação'                                                      
		Case cStatus == ST_REMANES
			cStNovo := STR0022	//'Processo Remanescente'
	EndCase
Return cStNovo

/*/{Protheus.doc} GC300DeAct
	Função chamada ao desativar o modelo, realiza a limpeza das variáveis estáticas
@author philipe.pompeu
@since 14/10/2022
@param oModel, objeto, instância de MPFormModel
@return Nil, nulo
/*/
Function GC300DeAct(oModel)
	/*Limpa variáveis estáticas ao desativar o modelo*/
	G300SitAta(.T., .F.)
	G300NewSit(.T., "")
	G300SetJus("")
	G300MdlId(.T., "GCPA300")
Return Nil

/*/{Protheus.doc} CancelMdl
	Realiza a atualização do campo _STATUS do submodelo oMdlCancel
@author philipe.pompeu
@since 14/10/2022
@param oMdlCancel, objeto, instância de FwFormGrid
@param cValor, caractere, valor a ser atribuido ao campo _STATUS
@return Nil, nulo
/*/
Static Function CancelMdl(oMdlCancel,bAvalCancel)
	Local cCpoCancel := ""
	Local cModel := oMdlCancel:GetId()
	Local lLote := (cModel == "CX6DETAIL")
	Local oModel:= oMdlCancel:GetModel()
	Local nX := 0	
	Local cCancelado := "5"
	Local lVldCpo:= .F.
	Default bAvalCancel := {|x| .T. } //A ideia desse bloco é possibilitar a automação do cenário do cancelamento parcial

	cCpoCancel	:= IIF(lLote, "CX6_STATUS", "CPY_STATUS")
	
	If lLote .Or. (!lLote .And. CpoStatVld(oMdlCancel))		
		for nX := 1 to oMdlCancel:Length()
			oMdlCancel:GoLine(nX)
			If lLote
				lVldCpo := CpoStatVld(oMdlCancel)
				If 	!lVldCpo .Or.; //Caso não tenha o campo <CPY_STATUS>
					(lVldCpo .And. oMdlCancel:GetValue(cCpoCancel) != cCancelado)//Se tiver cancelado não precisa processar os itens
					CancelMdl(oModel:GetModel("CPYDETAIL"),bAvalCancel)//Cancela todos os itens do Lote
				EndIf
			Else
				If oMdlCancel:GetValue(cCpoCancel) != cCancelado .And. Eval(bAvalCancel,oMdlCancel)
					aProp := GetPropMdl(oMdlCancel)
					oMdlCancel:SetNoUpdateLine(.F.)
					MtBCMod(oModel,{{cModel,{cCpoCancel}}},{||.T.},'2')
					oMdlCancel:LoadValue(cCpoCancel, cCancelado)//Se for por item, cancela o item
					RstPropMdl(oMdlCancel,aProp)
					MtBCMod(oModel,{{cModel,{cCpoCancel}}},{||.F.},'2')
				EndIf
			EndIf
		next nX
	EndIf	
Return

/*/{Protheus.doc} AllCancel
	Verifica se todos os registros de <oMdlCancel> estão cancelados
@author philipe.pompeu
@since 14/10/2022
@param oMdlCancel, objeto, instância de FwFormGrid
@return lRet, lógico, se todos os itens estão cancelados
/*/
Static Function AllCancel(oMdlCancel)
	Local lRet := .T.
	Local cCpoCancel := ""
	Local lLote := (oMdlCancel:GetId() == "CX6DETAIL")
	Local nX := 0

	cCpoCancel := IIF(lLote, "CX6_STATUS", "CPY_STATUS")
	If CpoStatVld(oMdlCancel)
		for nX := 1 to oMdlCancel:Length()
			oMdlCancel:GoLine(nX)
			If!(lRet := (oMdlCancel:GetValue(cCpoCancel) == "5"))
				Exit
			EndIf			
		next nX		
	EndIf
Return lRet

/*/{Protheus.doc} CpoStatVld
	Verifica a existência do campo _STATUS e se a opção 5=cancelado está disponível
@author philipe.pompeu
@since 14/10/2022
@param oMdlCancel, objeto, instância de FwFormGrid
@return lResult, lógico, se o campo está válido
/*/
Static Function CpoStatVld(oMdlCancel)
	Local lResult := .F.
	Local cCampo := ""
	Local aOpcStat	:= {}

	cCampo := Left(oMdlCancel:GetId(), 3) + "_STATUS"
	If oMdlCancel:HasField(cCampo)
		aOpcStat := oMdlCancel:GetStruct():GetProperty(cCampo, MODEL_FIELD_VALUES)
		lResult := aScan(aOpcStat,{|x|Left(x,1) == "5"}) > 0 //Verifica se a opção 5=Cancelado está disponível
	EndIf
Return lResult

/*/{Protheus.doc} CBoxCpySt
	Retorna as opções de combo para o campo <CPY_STATUS>
@author philipe.pompeu
@since 14/10/2022
@return aResult, vetor, opções a serem disponibilizadas no campo CPY_STATUS
/*/
Static Function CBoxCpySt()
	Local aResult	:= {}
	Local cCbox		:= AllTrim(GetSx3Cache( "CPY_STATUS", "X3_CBOX" ))
	Local aTemp := {}
	Local nX := 0

	aTemp := StrTokArr2(cCbox,";")

	for nX := 1 to Len(aTemp)
		if Left(aTemp[nX],1) $ "1|5" //Disponibiliza apenas as opções 1=Habilitado e 5=Cancelado
			aAdd(aResult, aTemp[nX])
		endif
	next nX

	FwFreeArray(aTemp)	
Return aResult

/*/{Protheus.doc} G300VlStat
	Realiza a validação do campo _STATUS, se o mesmo já tiver sido cancelado anteriormente não permite mudança
@author philipe.pompeu
@since 14/10/2022
@param oSubModel, objeto, instância de FwFormGrid
@param cCampo, caractere, nome do campo
@param cNovoValor, caractere, valor sendo atribuido
@return lResult, lógico, se o campo está válido
/*/
Function G300VlStat(oSubModel, cCampo, cNovoValor)
	Local aArea 	:= {}
	Local lResult	:= .T.
	Local cAliasTb	:= ""
	Local nFldPos	:= 0

	If (cNovoValor == "1" .And. oSubModel:GetDataId() > 0)
		cAliasTb := Left(oSubModel:GetId(),3)		
		If (nFldPos := (cAliasTb)->(FieldPos(cCampo))) > 0
			aArea := (cAliasTb)->(GetArea())
			(cAliasTb)->(DbGoTo(oSubModel:GetDataId()))

			If (cAliasTb)->(FieldGet(nFldPos) == "5") //Se já foi cancelado anteriormente
				Help( ,, cCampo,, STR0107, 1, 0,,,,,, {STR0108} )//Item já cancelado, não é possível atualizar sua situação
				lResult := .F.
			EndIf

			RestArea(aArea)
			FwFreeArray(aArea)
		EndIf
	EndIf
Return lResult

/*/{Protheus.doc} SetCancPrc
	Caso uma operação de cancelamento parcial ocorra, gera Histórico(CPN) por item e restaura o status da Ata
@author philipe.pompeu
@since 14/10/2022
@param oModel, objeto, instância de MPFormModel
@return Nil, Nulo
/*/
Static Function SetCancPrc(oModel)	
	Local nX := 0	
	Local cStAnt	:= ""
	Local cStNova	:= "[#1] - " + GetDescrSt(oModel:GetValue('CPHMASTER','CPH_STATUS'))
	Local oMdlCX6 := 0

	CPH->(DbGoTo(oModel:GetModel('CPHMASTER'):GetDataId()))
	oModel:LoadValue('CPHMASTER','CPH_STATUS', CPH->CPH_STATUS) //Restaura status

	cStAnt := GetDescrSt(CPH->CPH_STATUS)

	If oModel:GetId() == "GCPA300"
		GenCPNxCPY(oModel, cStAnt, cStNova)
	Else
		oMdlCX6 := oModel:GetModel("CX6DETAIL")
		for nX := 1 to oMdlCX6:Length()//Percorre lotes
			oMdlCX6:GoLine(nX)

			If !oMdlCX6:IsDeleted()				
				GenCPNxCPY(oModel, cStAnt, cStNova)
			EndIf
		next nX		
	EndIf	
Return

/*/{Protheus.doc} GP300VIGEX
	Verifica a vigência(CPH_VGATAF), se já estiver passada cancela a ata e exibe help
@author philipe.pompeu
@since 22/10/2022
@param lAtuSitu	, lógico, se deve atualizar situação
@param lHelp	, lógico, se deve exiber o alerta
@return lResult, lógico, se a data fim está válida
/*/
Function GP300VIGEX(lAtuSitu,lHelp)
	Local lResult		:= .T.
	local lPosHMCO1		:= CO1->(FieldPos("CO1_HMPARC")) > 0
	Local lHmlParc		:= .F.
	Local cChvEdital	:= ""
	Local aHelp			:= {}
	Local cJustif		:= ""
	Default lAtuSitu 	:= .T.
	Default lHelp 		:= .T.

	If lPosHMCO1
		CO1->(dbSetOrder(1))//CO1_FILIAL+CO1_CODEDT+CO1_NUMPRO+CO1_REVISA
		cChvEdital	:= xFilial("CO1") + CPH->(CPH_CODEDT + CPH_NUMPRO)
		lHmlParc 	:= CO1->(dbSeek(cChvEdital) .And. CO1->CO1_HMPARC)
	EndIf	

	If !lHmlParc .And. (CPH->CPH_STATUS == '3') .And. (dDatabase > CPH->CPH_VGATAF)
		If lAtuSitu
			aHelp := GetHlpSoluc("A300ATAVIGEX")
			If !Empty(aHelp)
				cJustif := AllTrim(aHelp[1])
				FwFreeArray(aHelp)
			EndIf
			MsExecAuto({|a,b| GCP300AtSt(a, b) }, '5', cJustif) //Chama via ExecAuto p/ não realizar abertura da tela de cancelamento			
		EndIf
		If lHelp
			Help(' ', 1, 'A300ATAVIGEX')//'A Ata excedeu o prazo de vigência e será Cancelada!'			
		EndIf
		lResult := .F.				
	EndIf
Return lResult

/*/{Protheus.doc} VldDistrSld
	Valida  distribuição do saldo dos participantes em relação aos produtos licitados
@author Vitor Pires
@since 29/11/2022
@return cMsg, mensagem ao erro
@param oCPYDetail, object, modelo da CPY
@param oCPIDetail, object, modelo da CPI
/*/
Static Function VldDistrSld(oCPYDetail,oCPIDetail) 
	Local nX		:= 0
	Local nY		:= 0
	Local nSdlPrt 	:= 0
	Local nConsCar	:= 0
	Local cMsg		:= ""
	Local cPictCPY  := GetSx3Cache("CPY_SALDO","X3_PICTURE")
	Local cPictCPI  := GetSx3Cache("CPI_SALDO","X3_PICTURE")
	Local cProd		:= ""
	Local cCpySld	:= ""
	Local cCPISld	:= ""
	Local cHelp		:= ""
	Local cLote		as Character

	For nX := 1 To oCPYDetail:Length()
		oCPYDetail:GoLine(nX)
		If !oCPYDetail:IsDeleted()
			nSdlPrt := 0
			nConsCar:= 0
			For nY := 1 to oCPIDetail:Length()
				oCPIDetail:GoLine(nY)
				If !oCPIDetail:IsDeleted()
					If oCPIDetail:GetValue('CPI_TIPO') == '1'
						nSdlPrt += oCPIDetail:GetValue('CPI_SALDO') + oCPIDetail:GetValue('CPI_QTDRES')
					Else
						nConsCar += oCPIDetail:GetValue('CPI_QTDCON')
					EndIf
				EndIf
			Next nY
		
			If nSdlPrt <> (oCPYDetail:GetValue('CPY_SALDO')+nConsCar)
				cLote 	:= oCPYDetail:GetValue('CPY_LOTE')
				cMsg	+= Iif(empty(cLote),'',STR0114+cLote+ CRLF) //LOTE

				cHelp 	:= STR0119

				cProd  	:=  AllTrim(oCPYDetail:GetValue('CPY_CODPRO'))+CRLF
				cCpySld	:=  Transform((oCPYDetail:GetValue('CPY_SALDO')+nConsCar),cPictCPY)+CRLF
				cCPISld	:=  Transform(nSdlPrt,cPictCPI)+CRLF

				cMsg +=I18N(cHelp,{cProd, cCpySld, cCPISld})
			EndIf
		EndIf
		
	Next nX
Return(cMsg)

/*/{Protheus.doc} GenCPNxCPY
	Gera CPN(Histórico) para cada item(CPY) que tenha sido cancelado.
@author philipe.pompeu
@since 10/02/2023
@param oModel	, objeto, instância de MPFormModel do GCPA300
@param cStAnt	, caractere, descrição da situação anterior
@param cStNova	, caractere, descrição da nova situação
@return Nil, não há
/*/
Static Function GenCPNxCPY(oModel, cStAnt, cStNova)
	Local nX		:= 0
	Local cJust		:= ""
	Local oModelCPY := oModel:GetModel("CPYDETAIL")
	Local oMdlCPN	:= oModel:GetModel("CPNDETAIL")
	Local cDescItem	:= AllTrim(GetSx3Cache( "CPY_ITEM", "X3_TITULO" )) + "[#1] - "

	for nX := oMdlCPN:Length() to 1 Step -1
		oMdlCPN:GoLine(nX)
		If oMdlCPN:IsInserted()
			cJust := oMdlCPN:GetValue("CPN_JUST") //Obtem a última justificativa
			oMdlCPN:DeleteLine()
			Exit
		EndIf
	next nX

	for nX := 1 to oModelCPY:Length()
		oModelCPY:GoLine(nX)
		If 	oModelCPY:GetValue("CPY_STATUS") == "5" .And.;	//Gera justificativa por item cancelado.
			oModelCPY:IsFieldUpdated("CPY_STATUS")			//Gera apenas pros itens alterados no cancelamento atual

			oMdlCPN:AddLine()
			oMdlCPN:LoadValue("CPN_DATA"	, dDataBase)
			oMdlCPN:LoadValue("CPN_HORA"	, Time())
			oMdlCPN:LoadValue("CPN_TIPO"	, "1")
			oMdlCPN:LoadValue("CPN_ORIGEM"	, cStAnt)			
			oMdlCPN:LoadValue("CPN_DESTIN"	, I18N(cStNova	,{oModelCPY:GetValue("CPY_ITEM")}))
			oMdlCPN:LoadValue("CPN_JUST"	, I18N(cDescItem,{oModelCPY:GetValue("CPY_ITEM")}) + cJust)
			oMdlCPN:SetValue("CPN_USER"		, __cUserId)
			Sleep(1000) //Aguarda por conta do campo <CPN_HORA> fazer parte da chave primária
		EndIf
	next nX
Return
