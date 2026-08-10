#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'GPEA943.CH'

Static lCpoCCT	:= NIL
Static lCpoADN	:= NIL
Static lCpoPer	:= NIL
Static lCpoATU  := NIL
Static lTemRUK	
Static aMarca   := {.F.,.F.,.F.,.F.,.F.,.F.}
Static aCpoObrigat := {}
Static lVldSindObg := .F.

/*/{Protheus.doc} GPEA943
Cadastro de de Convenção Coletiva de Trabalho
@author Leandro Drumond
@since 21/03/2022
@Type     Function
/*/
Function GPEA943()
Local aCoors  		:= FWGetDialogSize( oMainWnd )
Local cIdBrowse
Local cIdGrid
Local oDlgPrinc
Local oTela
Local oPanelUp
Local oPanelDown
Local oBrowseSWY
Local oBrowseRCE
Local oRelacRCE
Local cFiltraRh
Local lChkSWY		:= ChkFile("SWY")

If !lChkSWY
	MsgInfo(STR0034)//"Para utilizar essa rotina é necessário atualização do dicionário de dados com o pacote da 'Convenção Coletiva de Trabalho', consulte a documentação no TDN"
	Return Nil
EndIf

DEFINE MsDialog oDlgPrinc Title OemToAnsi(STR0001) From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] OF oMainWnd Pixel  //"Convenção Coletiva de Trabalho"

	// Cria o conteiner onde serão colocados os paineis
	oTela     := FWFormContainer():New( oDlgPrinc )
	cIdBrowse := oTela:CreateHorizontalBox( 50 )
	cIdGrid   := oTela:CreateHorizontalBox( 50 )

	oTela:Activate( oDlgPrinc, .F. )

	//Cria os paineis onde serao colocados os browses
	oPanelUp  	:= oTela:GeTPanel( cIdBrowse )
	oPanelDown  := oTela:GeTPanel( cIdGrid )

	oBrowseSWY 	:= FWMBrowse():New()
	oBrowseSWY:SetOwner( oPanelUp )

	oBrowseSWY:SetAlias("SWY")
	oBrowseSWY:SetDescription(OemToAnsi(STR0001)) //"Convenção Coletiva de Trabalho"
	oBrowseSWY:DisableDetails()
	oBrowseSWY:ForceQuitButton()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicializa o filtro utilizando a funcao FilBrowse                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cFiltraRh := CHKRH("GPEA943","SWY","1")
	oBrowseSWY:SetFilterDefault( cFiltraRh )

	oBrowseSWY:Activate()

	//FWmBrowse Inferior: Sindicatos associados
	oBrowseRCE	:= FWMBrowse():New()
	oBrowseRCE:SetOwner( oPanelDown )

	oBrowseRCE:SetDescription( OemToAnsi(STR0007) )	//"Sindicatos associados"
	oBrowseRCE:DisableDetails()
	oBrowseRCE:SetAlias( 'RCE' )
	oBrowseRCE:SetCacheView(.F.)
	oBrowseRCE:SetSeek(.F.)
	oBrowseRCE:ExecuteFilter(.F.)
	oBrowseRCE:SetUseFilter(.F.)
	oBrowseRCE:SetMenuDef('')

	// Relacionamento entre os Paineis
	oRelacRCE:= FWBrwRelation():New()
	oRelacRCE:AddRelation( oBrowseSWY  , oBrowseRCE , { { 'xFilial("SWY",RCE->RCE_FILIAL)', 'WY_FILIAL' },{ 'RCE->RCE_CCT', 'SWY->WY_CODIGO' } } )

	oRelacRCE:Activate()

	oBrowseRCE:Activate()

	oBrowseSWY:Refresh()
	oBrowseRCE:Refresh()

ACTIVATE MsDialog oDlgPrinc Center

Return

/*/{Protheus.doc} ModelDef
Definição e detalhamento do Model
@author Leandro Drumond
@since 21/03/2022
@Type     Function
/*/
Static Function ModelDef()

Local oModel
Local oStructSWY
Local oStructRCE
Local oStructSYY
Local oStructRI4
Local oStructREB
Local oStructSP4
Local oStructREI
Local oStructRUK
Local aCpoNoCopy
Local bCommit		:= { |oMdl| Gpea943Grv( oMdl ) }
Local bValid		:= { |oMdl| Gpea943Vld( oMdl ) }
Local lTecXRH		:= SuperGetMV("MV_TECXRH",,.F.)

DEFAULT lTemRUK     := AliasInDic("RUK")

lCpoCCT := (lTecXRH .And. If(lCpoCCT == NIL, SP4->(ColumnPos("P4_CODCCT") > 0), lCpoCCT))
lCpoADN := If(lCpoADN == NIL, SWY->(ColumnPos("WY_ADNHN") > 0), lCpoADN)

// Criacao do Objeto de Modelagem de dados da tabela RCE //
oModel	:= MPFormModel():New("GPEA943", {|| RCEFieldsObg(@oStructRCE,oStructSWY) }, bValid , bCommit )

oModel:SetDescription( OemToAnsi(STR0001) ) //"Convenção Coletiva de Trabalho"

// Estrutura de campos do Model //
oStructSWY := FWFormStruct(1, "SWY") // Convenção coletiva
oStructSYY := FWFormStruct(1 ,"SYY") // Histórico CCT
oStructRCE := FWFormStruct(1, "RCE") // Sindicatos

oStructSYY:AddField( 	STR0013			   , ;           	// [01] Titulo do campo "Descrição"
						STR0021			   , ;	            // [02] ToolTip do campo
						"YY_DESC"	       , ;              // [03] Id do Field
						"C"           	   , ;              // [04] Tipo do campo
						12		           , ;              // [05] Tamanho do campo
						0         		   , ;              // [06] Decimal do campo
						 				   , ;  			// [07] Code-block de validação do campo
										   , ;      		// [08] Code-block de validação When do campo
										   , ;              // [09] Lista de valores permitido do campo
						.F.                , ;              // [10] Indica se o campo tem preenchimento obrigatório
						{|| Gp943DescCpo()}		   , ;      // [11] Code-block de inicializacao do campo
						NIL                , ;              // [12] Indica se trata-se de um campo chave
						Nil                , ;              // [13] Indica se o campo não pode receber valor em uma operação de update.
						.T.) 

oStructRCE:AddField( 	" "			       , ;              // [01] Titulo do campo "Periodo"
						""       		   , ;              // [02] ToolTip do campo
						"RCE_OK"	       , ;              // [03] Id do Field
						"L"           	   , ;              // [04] Tipo do campo
						1		           , ;              // [05] Tamanho do campo
						0         		   , ;              // [06] Decimal do campo
						{|oMdl| fVldMark_Ok(oMdl, 1) } , ;  // [07] Code-block de validação do campo
						{|oMdl| fWhenOK(oMdl, 1) } , ;   	// [08] Code-block de validação When do campo
										   , ;              // [09] Lista de valores permitido do campo
						.F.                , ;              // [10] Indica se o campo tem preenchimento obrigatório
						{|| .T.}		   , ;              // [11] Code-block de inicializacao do campo
						NIL                , ;              // [12] Indica se trata-se de um campo chave
						Nil                , ;              // [13] Indica se o campo não pode receber valor em uma operação de update.
						.T.)          		           		// [14] Indica se o campo é virtual

oStructRI4 := FWFormStruct(1 ,"RI4")

oStructRI4:AddField( 	" "			       , ;              // [01] Titulo do campo "Periodo"
						""        		   , ;              // [02] ToolTip do campo
						"RI4_OK"	       , ;              // [03] Id do Field
						"L"           	   , ;              // [04] Tipo do campo
						1		           , ;              // [05] Tamanho do campo
						0         		   , ;              // [06] Decimal do campo
						{|oMdl| fVldMark_Ok(oMdl, 2) } , ;  // [07] Code-block de validação do campo
						{|oMdl| fWhenOK(oMdl, 2) } , ;      // [08] Code-block de validação When do campo
										   , ;              // [09] Lista de valores permitido do campo
						.F.                , ;              // [10] Indica se o campo tem preenchimento obrigatório
						{|| .T.}		   , ;              // [11] Code-block de inicializacao do campo
						NIL                , ;              // [12] Indica se trata-se de um campo chave
						Nil                , ;              // [13] Indica se o campo não pode receber valor em uma operação de update.
						.T.)          		           		// [14] Indica se o campo é virtual

oStructRI4:AddField( 	STR0013			   , ;           	// [01] Titulo do campo "Descrição"
						STR0021			   , ;	            // [02] ToolTip do campo
						"RI4_DESC"	       , ;              // [03] Id do Field
						"C"           	   , ;              // [04] Tipo do campo
						20		           , ;              // [05] Tamanho do campo
						0         		   , ;              // [06] Decimal do campo
						 				   , ;  			// [07] Code-block de validação do campo
										   , ;      		// [08] Code-block de validação When do campo
										   , ;              // [09] Lista de valores permitido do campo
						.F.                , ;              // [10] Indica se o campo tem preenchimento obrigatório
						{|| FDesc("SRJ", RI4->RI4_CODSRJ, "RJ_DESC", NIL, RI4->RI4_FILSRJ)}		   , ;              // [11] Code-block de inicializacao do campo
						NIL                , ;              // [12] Indica se trata-se de um campo chave
						Nil                , ;              // [13] Indica se o campo não pode receber valor em uma operação de update.
						.T.)          		           		// [14] Indica se o campo é virtual

oStructREB := FWFormStruct(1 ,"REB")

oStructREB:AddField( 	" "			       , ;              // [01] Titulo do campo "Periodo"
						""        		   , ;              // [02] ToolTip do campo
						"REB_OK"	       , ;              // [03] Id do Field
						"L"           	   , ;              // [04] Tipo do campo
						1		           , ;              // [05] Tamanho do campo
						0         		   , ;              // [06] Decimal do campo
						{|oMdl| fVldMark_Ok(oMdl, 3, lTecXRH) } , ;  // [07] Code-block de validação do campo
						{|oMdl| fWhenOK(oMdl, 3) } , ;      // [08] Code-block de validação When do campo
										   , ;              // [09] Lista de valores permitido do campo
						.F.                , ;              // [10] Indica se o campo tem preenchimento obrigatório
						{|| .T.}		   , ;              // [11] Code-block de inicializacao do campo
						NIL                , ;              // [12] Indica se trata-se de um campo chave
						Nil                , ;              // [13] Indica se o campo não pode receber valor em uma operação de update.
						.T.)          		           		// [14] Indica se o campo é virtual

If lCpoCCT
	oStructSP4 := FWFormStruct(1, "SP4") // Tipos de Hora extra
	oStructSP4:SetProperty( "P4_TIPO", 		MODEL_FIELD_VALID, FwBuildFeature( STRUCT_FEATURE_VALID, "fTipoExtra(M->P4_TIPO)"))
	oStructSP4:SetProperty( "P4_DE", 		MODEL_FIELD_OBRIGAT, .T.)
	oStructSP4:SetProperty( "P4_ATE", 		MODEL_FIELD_VALID, FwBuildFeature( STRUCT_FEATURE_VALID, ""))
	oStructSP4:SetProperty( "P4_ATE",		MODEL_FIELD_OBRIGAT, .T.)
	oStructSP4:SetProperty( "P4_PERCENT", 	MODEL_FIELD_OBRIGAT, .T.)
	oStructSP4:SetProperty( "P4_FILIAL", 	MODEL_FIELD_INIT, {|| xFilial("SP4", M->WY_FILIAL)})

	oStructSP4:AddField( 	" "			       , ;              // [01] Titulo do campo
							""        		   , ;              // [02] ToolTip do campo
							"P4_OK"	      	   , ;              // [03] Id do Field
							"L"           	   , ;              // [04] Tipo do campo
							1		           , ;              // [05] Tamanho do campo
							0         		   , ;              // [06] Decimal do campo
							NIL				   , ;  			// [07] Code-block de validação do campo
							NIL				   , ;		        // [08] Code-block de validação When do campo
							NIL				   , ;              // [09] Lista de valores permitido do campo
							.F.                , ;              // [10] Indica se o campo tem preenchimento obrigatório
							{|| .T.}		   , ;              // [11] Code-block de inicializacao do campo
							NIL                , ;              // [12] Indica se trata-se de um campo chave
							Nil                , ;              // [13] Indica se o campo não pode receber valor em uma operação de update.
							.T.)          		           		// [14] Indica se o campo é virtual
	
EndIf

oStructREB:AddField( 	STR0013			   , ;           	// [01] Titulo do campo "Descrição"
						STR0021			   , ;	            // [02] ToolTip do campo
						"REB_DESC"	       , ;              // [03] Id do Field
						"C"           	   , ;              // [04] Tipo do campo
						20		           , ;              // [05] Tamanho do campo
						0         		   , ;              // [06] Decimal do campo
						 				   , ;  			// [07] Code-block de validação do campo
										   , ;      		// [08] Code-block de validação When do campo
										   , ;              // [09] Lista de valores permitido do campo
						.F.                , ;              // [10] Indica se o campo tem preenchimento obrigatório
						{|| FDesc("SRV", REB->REB_CODSRV, "RV_DESC", NIL, REB->REB_FILSRV)}		   , ;              // [11] Code-block de inicializacao do campo
						NIL                , ;              // [12] Indica se trata-se de um campo chave
						Nil                , ;              // [13] Indica se o campo não pode receber valor em uma operação de update.
						.T.)          		           		// [14] Indica se o campo é virtual

oStructREI := FWFormStruct(1 ,"REI")

oStructREI:AddField( 	" "			       , ;              // [01] Titulo do campo "Periodo"
						""        		   , ;              // [02] ToolTip do campo
						"REI_OK"	       , ;              // [03] Id do Field
						"L"           	   , ;              // [04] Tipo do campo
						1		           , ;              // [05] Tamanho do campo
						0         		   , ;              // [06] Decimal do campo
						{|oMdl| fVldMark_Ok(oMdl, 4) } , ;  // [07] Code-block de validação do campo
						{|oMdl| fWhenOK(oMdl, 4) } , ;      // [08] Code-block de validação When do campo
										   , ;              // [09] Lista de valores permitido do campo
						.F.                , ;              // [10] Indica se o campo tem preenchimento obrigatório
						{|| .T.}		   , ;              // [11] Code-block de inicializacao do campo
						NIL                , ;              // [12] Indica se trata-se de um campo chave
						Nil                , ;              // [13] Indica se o campo não pode receber valor em uma operação de update.
						.T.)          		           		// [14] Indica se o campo é virtual

oStructREI:AddField( 	STR0013			   , ;           	// [01] Titulo do campo "Descrição"
						STR0021			   , ;	            // [02] ToolTip do campo
						"REI_DESC"	       , ;              // [03] Id do Field
						"C"           	   , ;              // [04] Tipo do campo
						20		           , ;              // [05] Tamanho do campo
						0         		   , ;              // [06] Decimal do campo
						 				   , ;  			// [07] Code-block de validação do campo
										   , ;      		// [08] Code-block de validação When do campo
										   , ;              // [09] Lista de valores permitido do campo
						.F.                , ;              // [10] Indica se o campo tem preenchimento obrigatório
						{|| FDesc("AA0", REI->REI_CODAA0, "AA0_DESCRI", NIL, REI->REI_FILAA0)}		   , ;              // [11] Code-block de inicializacao do campo
						NIL                , ;              // [12] Indica se trata-se de um campo chave
						Nil                , ;              // [13] Indica se o campo não pode receber valor em uma operação de update.
						.T.)          		           		// [14] Indica se o campo é virtual

If lTecXRH .And. lTemRUK
	oStructRUK := FWFormStruct(1 ,"RUK")

	oStructRUK:AddField( 	" "			       , ;              // [01] Titulo do campo "Periodo"
							""        		   , ;              // [02] ToolTip do campo
							"RUK_OK"	       , ;              // [03] Id do Field
							"L"           	   , ;              // [04] Tipo do campo
							1		           , ;              // [05] Tamanho do campo
							0         		   , ;              // [06] Decimal do campo
							{|oMdl| fVldMark_Ok(oMdl, 5) } , ;  // [07] Code-block de validação do campo
							{|oMdl| fWhenOK(oMdl, 5) } , ;      // [08] Code-block de validação When do campo
											   , ;              // [09] Lista de valores permitido do campo
							.F.                , ;              // [10] Indica se o campo tem preenchimento obrigatório
							{|| .T.}		   , ;              // [11] Code-block de inicializacao do campo
							NIL                , ;              // [12] Indica se trata-se de um campo chave
							Nil                , ;              // [13] Indica se o campo não pode receber valor em uma operação de update.
							.T.)    

	oStructRUK:AddField( 	STR0058			   , ;           	// [01] Titulo do campo "Descrição"
							STR0063			   , ;	            // [02] ToolTip do campo
							"RUK_DESC"	       , ;              // [03] Id do Field
							"C"           	   , ;              // [04] Tipo do campo
							60		           , ;              // [05] Tamanho do campo
							0         		   , ;              // [06] Decimal do campo
											   , ;  			// [07] Code-block de validação do campo
											   , ;      		// [08] Code-block de validação When do campo
											   , ;              // [09] Lista de valores permitido do campo
							.F.                , ;              // [10] Indica se o campo tem preenchimento obrigatório
							{|| FDesc("CC2", RUK->RUK_ESTADO+RUK->RUK_CODMUN, "CC2_MUN", NIL)} , ; // [11] Code-block de inicializacao do campo
							NIL                , ;              // [12] Indica se trata-se de um campo chave
							Nil                , ;              // [13] Indica se o campo não pode receber valor em uma operação de update.
							.T.)       		  
EndIf						

oStructRCE:SetProperty( 'RCE_DESCRI', MODEL_FIELD_WHEN, {|| .F. } )
oStructRCE:SetProperty( 'RCE_CODIGO', MODEL_FIELD_WHEN, {|| .F. } )

// Se a integração com o GS não estiver habilitada remove os campos
If lCpoADN .And. !lTecXRH
	oStructSWY:RemoveField("WY_ADNHN")
	oStructSWY:RemoveField("WY_ADNHE")
EndIf

oModel:AddFields("GPEA943_SWY", NIL, oStructSWY)

oModel:SetPrimaryKey({"WY_CODIGO"})

oModel:GetModel( "GPEA943_SWY" ):SetDescription( OemToAnsi(STR0001) )  //"Convenção Coletiva de Trabalho"

oModel:AddGrid("GPEA943_RCE", "GPEA943_SWY"/*cOwner*/, oStructRCE , /*bLinePre*/, /* bLinePost*/, /*bPre*/,  /*bPost*/,/*bLoad*/)
oModel:GetModel( "GPEA943_RCE" ):SetOptional(.T.)
oModel:GetModel( "GPEA943_RCE" ):SetNoInsertLine(.T.)
oModel:GetModel( "GPEA943_RCE" ):SetNoDeleteLine(.T.)
oModel:GetModel( "GPEA943_RCE" ):SetOnlyQuery( .T. )

If xFilial("RCE") == xFilial("SWY")
	oModel:SetRelation("GPEA943_RCE",{{'RCE_FILIAL',"WY_FILIAL"},{"RCE_CCT","WY_CODIGO"}},RCE->(IndexKey()))
Else
	oModel:SetRelation("GPEA943_RCE",{{"RCE_CCT","WY_CODIGO"}},RCE->(IndexKey()))
EndIf

oModel:AddGrid("GPEA943_RI4", "GPEA943_SWY"/*cOwner*/, oStructRI4 , /*bLinePre*/, /* bLinePost*/, /*bPre*/,  /*bPost*/,/*bLoad*/)
oModel:GetModel( "GPEA943_RI4" ):SetOptional(.T.)
oModel:GetModel( "GPEA943_RI4" ):SetNoInsertLine(.T.)
oModel:GetModel( "GPEA943_RI4" ):SetNoDeleteLine(.T.)

oModel:SetRelation("GPEA943_RI4",{{"RI4_FILCCT","WY_FILIAL"},{"RI4_CODCCT","WY_CODIGO"}},RI4->(IndexKey()))

oModel:AddGrid("GPEA943_REB", "GPEA943_SWY"/*cOwner*/, oStructREB , /*bLinePre*/, /* bLinePost*/, /*bPre*/,  /*bPost*/,/*bLoad*/)
oModel:GetModel( "GPEA943_REB" ):SetOptional(.T.)
oModel:GetModel( "GPEA943_REB" ):SetMaxLine(500)
oModel:GetModel( "GPEA943_REB" ):SetNoInsertLine(.T.)
oModel:GetModel( "GPEA943_REB" ):SetNoDeleteLine(.T.)

oModel:SetRelation("GPEA943_REB",{{"REB_FILCCT","WY_FILIAL"},{"REB_CODCCT","WY_CODIGO"}},REB->(IndexKey()))

oModel:AddGrid("GPEA943_REI", "GPEA943_SWY"/*cOwner*/, oStructREI , /*bLinePre*/, /* bLinePost*/, /*bPre*/,  /*bPost*/,/*bLoad*/)
oModel:GetModel( "GPEA943_REI" ):SetOptional(.T.)
oModel:GetModel( "GPEA943_REI" ):SetMaxLine(500)
oModel:GetModel( "GPEA943_REI" ):SetNoInsertLine(.T.)
oModel:GetModel( "GPEA943_REI" ):SetNoDeleteLine(.T.)

oModel:SetRelation("GPEA943_REI",{{"REI_FILCCT","WY_FILIAL"},{"REI_CODCCT","WY_CODIGO"}},REI->(IndexKey()))

oModel:AddGrid("GPEA943_SYY", "GPEA943_SWY"/*cOwner*/, oStructSYY , /*bLinePre*/, /* bLinePost*/, /*bPre*/,  /*bPost*/,/*{|oGrid| CargaSR8(oGrid) }bLoad*/)
oModel:GetModel("GPEA943_SYY"):SetOptional(.T.)
oModel:SetRelation("GPEA943_SYY",{{"YY_FILIAL",'WY_FILIAL'},{"YY_CODIGO","WY_CODIGO"}},SYY->(IndexKey()))

// Tipos de HE
If lCpoCCT
	oModel:AddGrid("GPEA943_SP4", "GPEA943_SWY", oStructSP4, {|oGrid, nLine, cAction| GPEDelOk(oGrid, nLine, cAction)}, {|oGrid, nLine| fSP4Ok(oGrid, nLine)}, /*bPre*/, /*bPost*/, /*bLoad*/)
	oModel:GetModel( "GPEA943_SP4" ):SetOptional(.T.)
	oModel:GetModel( "GPEA943_SP4" ):SetDescription( STR0041 ) // "Tipos de Horas Extras"
	oModel:GetModel( "GPEA943_SP4" ):SetUniqueLine({"P4_TIPO", "P4_DE"})
	oModel:SetRelation("GPEA943_SP4", { {"P4_FILCCT", "WY_FILIAL"}, {"P4_CODCCT", "WY_CODIGO"}}, SP4->(IndexKey()))
EndIf

//Municípios
If lTecXRH .And. lTemRUK
	oModel:AddGrid("GPEA943_RUK", "GPEA943_SWY"/*cOwner*/, oStructRUK , /*bLinePre*/, /* bLinePost*/, /*bPre*/,  /*bPost*/,/*bLoad*/)
	oModel:GetModel( "GPEA943_RUK" ):SetOptional(.T.)
	oModel:GetModel( "GPEA943_RUK" ):SetMaxLine(1000)
	oModel:GetModel( "GPEA943_RUK" ):SetNoInsertLine(.T.)
	oModel:GetModel( "GPEA943_RUK" ):SetNoDeleteLine(.T.)

	oModel:SetRelation("GPEA943_RUK",{{"RUK_FILCCT","WY_FILIAL"},{"RUK_CODCCT","WY_CODIGO"}},RUK->(IndexKey()))
EndIf

//Não carrega os sindicatos no processo de cópia
aCpoNoCopy := {}
aScan(oModel:GetModel("GPEA943_RCE"):aHeader, {|x| aAdd(aCpoNoCopy, x[2])})

oModel:GetModel("GPEA943_RCE"):SetFldNoCopy( aCpoNoCopy )

Return( oModel )

/*/{Protheus.doc} ViewDef
Definição da viewdef
@author Leandro Drumond
@since 22/03/2022
@Type     Function
/*/
Static Function ViewDef()
Local oView
Local oModel
Local oStructSWY
Local oStructRCE
Local oStructRI4
Local oStructREB
Local oStructREI
Local oStructSP4
Local oStructRUK
Local lTecXRH		:= SuperGetMV("MV_TECXRH",,.F.)

DEFAULT lTemRUK	    := AliasInDic("RUK")

lCpoCCT := (lTecXRH .And. If(lCpoCCT == NIL, SP4->(ColumnPos("P4_CODCCT") > 0), lCpoCCT))
lCpoADN := If(lCpoADN == NIL, SWY->(ColumnPos("WY_ADNHN") > 0), lCpoADN)

// Criacao da Interface //
oView := FWFormView():New()

// Vincular o View ao Model //
oModel := FWLoadModel("GPEA943")
oStructSWY := FWFormStruct(2, "SWY")
oStructRCE := FWFormStruct(2, "RCE")

RemoveFields(@oStructRCE)

oStructRCE:AddField( 	"RCE_OK"              	, ;              // [01] Campo
						"01"  					, ;              // [02] Ordem
						" "                		, ;              // [03] Titulo
						"Ok"                	, ;              // [04] Descricao
						NIL              		, ;              // [05] Help
						"L"                		, ;              // [06] Tipo do campo   COMBO, Get ou CHECK
								                , ;              // [07] Picture
												, ;              // [08] PictVar
												, ;              // [09] F3
						.T.  		            , ;              // [10] Editavel
												, ;              // [11] Folder
						""                		, ;              // [12] Group
												, ;              // [13] Lista Combo
												, ;              // [14] Tam Max Combo
												, ;              // [15] Inic. Browse
						.T.)                                     // [16] Virtual


oStructRI4 := FWFormStruct(2, "RI4")
oStructRI4:RemoveField("RI4_CODCCT")
oStructRI4:RemoveField("RI4_FILCCT")

oStructRI4:AddField( 	"RI4_OK"              	, ;              // [01] Campo
						"01"  					, ;              // [02] Ordem
						" "                		, ;              // [03] Titulo
						"Ok"                	, ;              // [04] Descricao
						NIL              		, ;              // [05] Help
						"L"                		, ;              // [06] Tipo do campo   COMBO, Get ou CHECK
								                , ;              // [07] Picture
												, ;              // [08] PictVar
												, ;              // [09] F3
						.T.  		            , ;              // [10] Editavel
												, ;              // [11] Folder
						""                		, ;              // [12] Group
												, ;              // [13] Lista Combo
												, ;              // [14] Tam Max Combo
												, ;              // [15] Inic. Browse
						.T.)                                     // [16] Virtual

oStructRI4:AddField( 	"RI4_DESC"             	, ;              // [01] Campo
						"07"  					, ;              // [02] Ordem
						STR0013        			, ;              // [03] Titulo
						STR0013            		, ;              // [04] Descricao
						NIL              		, ;              // [05] Help
						"C"                		, ;              // [06] Tipo do campo   COMBO, Get ou CHECK
								                , ;              // [07] Picture
												, ;              // [08] PictVar
												, ;              // [09] F3
						.F.  		            , ;              // [10] Editavel
												, ;              // [11] Folder
						""                		, ;              // [12] Group
												, ;              // [13] Lista Combo
												, ;              // [14] Tam Max Combo
												, ;              // [15] Inic. Browse
						.T.)                                     // [16] Virtual

oStructREB := FWFormStruct(2, "REB")
oStructREB:RemoveField("REB_CODCCT")
oStructREB:RemoveField("REB_FILCCT")

oStructREB:AddField( 	"REB_OK"              	, ;              // [01] Campo
						"01"  					, ;              // [02] Ordem
						" "                		, ;              // [03] Titulo
						"Ok"                	, ;              // [04] Descricao
						NIL              		, ;              // [05] Help
						"L"                		, ;              // [06] Tipo do campo   COMBO, Get ou CHECK
								                , ;              // [07] Picture
												, ;              // [08] PictVar
												, ;              // [09] F3
						.T.  		            , ;              // [10] Editavel
												, ;              // [11] Folder
						""                		, ;              // [12] Group
												, ;              // [13] Lista Combo
												, ;              // [14] Tam Max Combo
												, ;              // [15] Inic. Browse
						.T.)                                     // [16] Virtual

oStructREB:AddField( 	"REB_DESC"             	, ;              // [01] Campo
						"10"  					, ;              // [02] Ordem
						STR0013        			, ;              // [03] Titulo
						STR0013            		, ;              // [04] Descricao
						NIL              		, ;              // [05] Help
						"C"                		, ;              // [06] Tipo do campo   COMBO, Get ou CHECK
								                , ;              // [07] Picture
												, ;              // [08] PictVar
												, ;              // [09] F3
						.F.  		            , ;              // [10] Editavel
												, ;              // [11] Folder
						""                		, ;              // [12] Group
												, ;              // [13] Lista Combo
												, ;              // [14] Tam Max Combo
												, ;              // [15] Inic. Browse
						.T.)

oStructREI := FWFormStruct(2, "REI")
oStructREI:RemoveField("REI_CODCCT")
oStructREI:RemoveField("REI_FILCCT")

oStructREI:AddField( 	"REI_OK"              	, ;              // [01] Campo
						"01"  					, ;              // [02] Ordem
						" "                		, ;              // [03] Titulo
						"Ok"                	, ;              // [04] Descricao
						NIL              		, ;              // [05] Help
						"L"                		, ;              // [06] Tipo do campo   COMBO, Get ou CHECK
								                , ;              // [07] Picture
												, ;              // [08] PictVar
												, ;              // [09] F3
						.T.  		            , ;              // [10] Editavel
												, ;              // [11] Folder
						""                		, ;              // [12] Group
												, ;              // [13] Lista Combo
												, ;              // [14] Tam Max Combo
												, ;              // [15] Inic. Browse
						.T.)                                     // [16] Virtual

oStructREI:AddField( 	"REI_DESC"             	, ;              // [01] Campo
						"10"  					, ;              // [02] Ordem
						STR0013        			, ;              // [03] Titulo
						STR0013            		, ;              // [04] Descricao
						NIL              		, ;              // [05] Help
						"C"                		, ;              // [06] Tipo do campo   COMBO, Get ou CHECK
								                , ;              // [07] Picture
												, ;              // [08] PictVar
												, ;              // [09] F3
						.F.  		            , ;              // [10] Editavel
												, ;              // [11] Folder
						""                		, ;              // [12] Group
												, ;              // [13] Lista Combo
												, ;              // [14] Tam Max Combo
												, ;              // [15] Inic. Browse
						.T.)

// Tipos de Hora Extra
If lCpoCCT
	oStructSP4 := FWFormStruct(2, "SP4")
	oStructSP4:RemoveField("P4_CODCCT")
	oStructSP4:RemoveField("P4_FILCCT")
	oStructSP4:RemoveField("P4_TURNO")
	oStructSP4:SetProperty( 'P4_CODNAUT', MVC_VIEW_PICT, "@!" )
	oStructSP4:SetProperty( 'P4_CODAUT', MVC_VIEW_PICT, "@!" )
EndIf

// Se a integração com o GS não estiver habilitada remove os campos
If lCpoADN .And. !lTecXRH
	oStructSWY:RemoveField("WY_ADNHN")
	oStructSWY:RemoveField("WY_ADNHE")
EndIf

If lTecXRH .And. lTemRUK
	oStructRUK := FWFormStruct(2, "RUK")
	oStructRUK:RemoveField("RUK_CODCCT")
	oStructRUK:RemoveField("RUK_FILCCT")

	oStructRUK:AddField( 	"RUK_OK"              	, ;              // [01] Campo
							"01"  					, ;              // [02] Ordem
							" "                		, ;              // [03] Titulo
							"Ok"                	, ;              // [04] Descricao
							NIL              		, ;              // [05] Help
							"L"                		, ;              // [06] Tipo do campo   COMBO, Get ou CHECK
													, ;              // [07] Picture
													, ;              // [08] PictVar
													, ;              // [09] F3
							.T.  		            , ;              // [10] Editavel
													, ;              // [11] Folder
							""                		, ;              // [12] Group
													, ;              // [13] Lista Combo
													, ;              // [14] Tam Max Combo
													, ;              // [15] Inic. Browse
							.T.)                                     // [16] Virtual

	oStructRUK:AddField( 	"RUK_DESC"             	, ;              // [01] Campo
							"60"  					, ;              // [02] Ordem
							STR0058        			, ;              // [03] Titulo
							STR0063            		, ;              // [04] Descricao
							NIL              		, ;              // [05] Help
							"C"                		, ;              // [06] Tipo do campo   COMBO, Get ou CHECK
													, ;              // [07] Picture
													, ;              // [08] PictVar
													, ;              // [09] F3
							.F.  		            , ;              // [10] Editavel
													, ;              // [11] Folder
							""                		, ;              // [12] Group
													, ;              // [13] Lista Combo
													, ;              // [14] Tam Max Combo
													, ;              // [15] Inic. Browse
							.T.)

EndIf

oView:SetModel(oModel)
oView:AddField("GPEA943_SWY", oStructSWY)

oView:CreateHorizontalBox("FIELDS", 60)

oView:CreateHorizontalBox("BOTTOM", 40)

oView:CreateFolder('PASTAS','BOTTOM')

oView:AddSheet( 'PASTAS', 'ABA01', STR0022) // Sindicatos
oView:AddSheet( 'PASTAS', 'ABA02', STR0023) // Funções
oView:AddSheet( 'PASTAS', 'ABA03', STR0026) // Verbas

If lTecXRH
	oView:AddSheet( 'PASTAS', 'ABA04', STR0035) // Base Operacional
EndIf

If lCpoCCT
	oView:AddSheet( 'PASTAS', 'ABA05', STR0042 ) // Hora Extra
EndIf

If lTecXRH .And. lTemRUK
	oView:AddSheet( 'PASTAS', 'ABA06', STR0071 ) // Municípios
EndIf

// Cria um "box" horizontal para receber cada elemento da view
oView:CreateHorizontalBox( 'ABAS1'  , 100,,, 'PASTAS', 'ABA01' )	//Sindicatos
oView:CreateHorizontalBox( 'ABAS2' ,  100,,, 'PASTAS', 'ABA02' )	//Funções
oView:CreateHorizontalBox( 'ABAS3' ,  100,,, 'PASTAS', 'ABA03' )	//Verbas

If lTecXRH
	oView:CreateHorizontalBox( 'ABAS4' ,  100,,, 'PASTAS', 'ABA04' )	//Base Operacional
EndIf

If lCpoCCT
	oView:CreateHorizontalBox( 'ABAS5' ,  100,,, 'PASTAS', 'ABA05' )	//Hora Extra
EndIf

If lTecXRH .And. lTemRUK
	oView:CreateHorizontalBox( 'ABAS6' ,  100,,, 'PASTAS', 'ABA06' )	//Municípios
EndIf

oView:AddGrid('GPEA943_RCE' , oStructRCE)
oView:AddGrid('GPEA943_RI4' , oStructRI4)
oView:AddGrid('GPEA943_REB' , oStructREB)

If lTecXRH
	oView:AddGrid('GPEA943_REI' , oStructREI)
EndIf

If lCpoCCT
	oView:AddGrid('GPEA943_SP4' , oStructSP4)
EndIf

If lTecXRH .And. lTemRUK
	oView:AddGrid('GPEA943_RUK' , oStructRUK)
EndIf

oView:addUserButton( STR0008 + " (F6)"	,"MAGIC_BMP", {|oModel| MsAguarde( { || LoadSindicato(oModel) } , OemtoAnsi(STR0030)) }	,STR0008,VK_F6	, {MODEL_OPERATION_INSERT,MODEL_OPERATION_UPDATE} ) //"Associar sindicatos"
oView:addUserButton( STR0024 + " (F7)"	,"MAGIC_BMP", {|oModel| MsAguarde( { || LoadFuncoes(oModel) } , OemtoAnsi(STR0029)) }	,STR0024,VK_F7	, {MODEL_OPERATION_INSERT,MODEL_OPERATION_UPDATE} ) //"Associar funções"
oView:addUserButton( STR0027 + " (F8)"	,"MAGIC_BMP", {|oModel| MsAguarde( { || LoadVerbas(oModel) } , OemtoAnsi(STR0028)) }	,STR0027,VK_F8	, {MODEL_OPERATION_INSERT,MODEL_OPERATION_UPDATE} ) //"Associar verbas"
If lTecXRH
	oView:addUserButton( STR0036 + " (F9)"	,"MAGIC_BMP", {|oModel| MsAguarde( { || LoadBases(oModel) } , OemtoAnsi(STR0037)) }		,STR0036,VK_F9	, {MODEL_OPERATION_INSERT,MODEL_OPERATION_UPDATE} ) //"Associar base operacional"
EndIf

If lCpoCCT
	//"Associar Tipos de Hora Extra" -- "Carregando Tipos de Hora Extra"
	oView:addUserButton( STR0043 + " (F10)", "MAGIC_BMP", {|oModel| MsAguarde( { || LoadHE(oModel) }, STR0044)}, STR0043, VK_F10, {MODEL_OPERATION_INSERT, MODEL_OPERATION_UPDATE} )
EndIf

If lTecXRH .And. lTemRUK
	oView:addUserButton( STR0059 + " (F11)"	,"MAGIC_BMP", {|oModel| MsAguarde( { || LoadMun(oModel) }, OemtoAnsi(STR0060)) }, STR0059, VK_F11, {MODEL_OPERATION_INSERT,MODEL_OPERATION_UPDATE} ) //"Associar Municípios"
EndIf

oView:addUserButton( STR0009			,"MAGIC_BMP", {|| ViewHistorico() }				,STR0009,		, {MODEL_OPERATION_UPDATE,MODEL_OPERATION_VIEW} )   //"Histórico"

oView:SetOwnerView("GPEA943_SWY", "FIELDS")
oView:SetOwnerView("GPEA943_RCE", "ABAS1")
oView:SetOwnerView("GPEA943_RI4", "ABAS2")
oView:SetOwnerView("GPEA943_REB", "ABAS3")
If lTecXRH
	oView:SetOwnerView("GPEA943_REI", "ABAS4")
EndIf

If lCpoCCT
	oView:SetOwnerView("GPEA943_SP4", "ABAS5")
EndIf

If lTecXRH .And. lTemRUK
	oView:SetOwnerView("GPEA943_RUK", "ABAS6")
EndIf

Return oView

/*/{Protheus.doc} ViewHistorico
Visualiza o histórico de alterações da CCT
@author Leandro Drumond
@since 29/03/2022
@Type     Function
/*/
Static Function ViewHistorico()

Local oView			:= Nil
Local oStructSYY 	:= Nil
Local oModel		:= FwLoadModel("GPEA943")

oView := FWFormView():New()

oStructSYY := FWFormStruct(2,"SYY")

oStructSYY:RemoveField("YY_FILIAL")
oStructSYY:RemoveField("YY_CODIGO")

oStructSYY:AddField( 	"YY_DESC"             	, ;              // [01] Campo
						"04"  					, ;              // [02] Ordem
						STR0013        			, ;              // [03] Titulo
						STR0013            		, ;              // [04] Descricao
						NIL              		, ;              // [05] Help
						"C"                		, ;              // [06] Tipo do campo   COMBO, Get ou CHECK
								                , ;              // [07] Picture
												, ;              // [08] PictVar
												, ;              // [09] F3
						.F.  		            , ;              // [10] Editavel
												, ;              // [11] Folder
						""                		, ;              // [12] Group
												, ;              // [13] Lista Combo
												, ;              // [14] Tam Max Combo
												, ;              // [15] Inic. Browse
						.T.)

oModel:SetRelation("GPEA943_SYY",{{"YY_FILIAL",'WY_FILIAL'},{"YY_CODIGO","WY_CODIGO"}},SYY->(IndexKey()))

oView:SetModel(oModel)

oView:AddGrid("GPEA943_SYY", oStructSYY)

oView:CreateHorizontalBox("SYY", 100)

oView:SetOwnerView("GPEA943_SYY", "SYY")

oFWMVCWindow := FWMVCWindow():New()
oFWMVCWindow:SetUseControlBar(.T.)
oFWMVCWindow:SetView(oView)
oFWMVCWindow:SetCentered(.T.)
oFWMVCWindow:SetPos(0,0)
oFWMVCWindow:SetSize(380,700)
oFWMVCWindow:SetTitle(STR0010)//'Histórico CCT'
oFWMVCWindow:Activate()

Return Nil

/*/{Protheus.doc} fWhenOK
Habilita o campo para seleção apenas se as colunas estiver preenchidas.
@author Leandro Drumond
@since 28/03/2022
@Type     Function
/*/
Static Function fWhenOK(oGrid, nTipo)
Local lRet 	    := .T.
Local oModelSWY 


If nTipo == 1
	If Empty(oGrid:GetValue("RCE_CODIGO"))
		lRet := .F.
	EndIf
ElseIf nTipo == 2
	If Empty(oGrid:GetValue("RI4_CODSRJ"))
		lRet := .F.
	EndIf
ElseIf nTipo == 3
	If Empty(oGrid:GetValue("REB_CODSRV"))
		lRet := .F.
	EndIf
ElseIf nTipo == 4
	If Empty(oGrid:GetValue("REI_CODAA0"))
		lRet := .F.
	EndIf
ElseIf nTipo == 5
	oModelSWY := oGrid:GetModel("GPEA943_SWY")
	If !oGrid:GetValue("RUK_OK") .And. (oGrid:GetValue("RUK_ESTADO") != oModelSWY:GetValue("GPEA943_SWY", "WY_ESTADO"))
		lRet := .F.
	EndIf
EndIf

Return lRet

/*/{Protheus.doc} LoadSindicato
Seleciona os sindicatos que serão associados a CCT
@author Leandro Drumond
@since 28/03/2022
@Type     Function
/*/
Static Function LoadSindicato(oModel)
Local aArea 		:= GetArea()
Local aStru  		:= {}
Local aLstIndices	:= {}
Local aColumns		:= {}
Local aPesq			:= {}
Local oGrid			:= oModel:GetModel("GPEA943_RCE")
Local cSindicatos   := ""
Local cIdGrid		:= ""
Local nTam          := oGrid:Length()
Local nX 			:= 0
Local nOpcX			:= 0
Local nRecRCE		:= 0
Local oSize
Local oTela
Local oDlgGrid
Local oPanel
Local oMark
Local oFont
Local oGroup
Local lInclui

Private cAliasTRB

For nX := 1 to nTam
	oGrid:GoLine(nX)
	If oGrid:GetValue("RCE_OK")
		cSindicatos += oGrid:GetValue("RCE_FILIAL") + oGrid:GetValue("RCE_CODIGO") + "#"
	EndIf
Next nX

Static cAliasTmp
Static oArqTmp

If oArqTmp == Nil //Monta temporária com filiais disponíveis
	Aadd(aStru, {"OK"		, "C", 2						, 0})
	Aadd(aStru, {"FILIAL"	, "C", FwGetTamFilial			, 0})
	Aadd(aStru, {"CODIGO"  	, "C", 2						, 0})
	Aadd(aStru, {"NOME"  	, "C", 40						, 0})
	AAdd(aLstIndices, {"FILIAL","CODIGO"})
	AAdd(aLstIndices, {"NOME"})

	cAliasTmp := cAliasTRB := GetNextAlias()

	oArqTmp := RhCriaTrab(cAliasTRB, aStru, aLstIndices)

	DbSelectArea("RCE")
	DbSetOrder(1)

	RCE->(DbGoTop())

	While RCE->(!Eof())
		RecLock(cAliasTRB, .T.)
		(cAliasTRB)->FILIAL	:= RCE->RCE_FILIAL
		(cAliasTRB)->CODIGO	:= RCE->RCE_CODIGO
		(cAliasTRB)->NOME	:= RCE->RCE_DESCRI
		(cAliasTRB)->(MsUnlock())
		RCE->(DbSkip())
	EndDo
Else
	cAliasTRB := cAliasTmp
EndIf

AAdd(aColumns,FWBrwColumn():New())
aColumns[Len(aColumns)]:SetData( &("{||(cAliasTRB)->FILIAL}") )
aColumns[Len(aColumns)]:SetTitle(STR0011) //"Filial"
aColumns[Len(aColumns)]:SetSize(FwGetTamFilial)
aColumns[Len(aColumns)]:SetDecimal(0)
aColumns[Len(aColumns)]:SetPicture("@!")

AAdd(aColumns,FWBrwColumn():New())
aColumns[Len(aColumns)]:SetData( &("{||(cAliasTRB)->CODIGO}") )
aColumns[Len(aColumns)]:SetTitle(STR0012) //"Código"
aColumns[Len(aColumns)]:SetSize(TamSX3("RCE_CODIGO")[1])
aColumns[Len(aColumns)]:SetDecimal(0)
aColumns[Len(aColumns)]:SetPicture("@!")

AAdd(aColumns,FWBrwColumn():New())
aColumns[Len(aColumns)]:SetData( &("{||(cAliasTRB)->NOME}") )
aColumns[Len(aColumns)]:SetTitle(STR0013) //"Descrição"
aColumns[Len(aColumns)]:SetSize(40)
aColumns[Len(aColumns)]:SetDecimal(0)
aColumns[Len(aColumns)]:SetPicture("@!")

Aadd( aPesq , {	STR0012, { { "CODIGO"   , "C", 02 , 0, "CODIGO", "@!"}}, 1})
Aadd( aPesq , {	STR0013, { { "NOME   "  , "C", 40 , 0, "NOME"  , "@!"}}, 1})

oSize := FwDefSize():New(.F.)

oSize:AddObject( "CABECALHO",(oSize:aWindSize[3]*1.1),(oSize:aWindSize[3]*0.4) , .F., .F. ) // Não dimensionavel
oSize:aMargins 	:= { 0, 0, 0, 0 } 		// Espaco ao lado dos objetos 0, entre eles 3
oSize:lProp 		:= .F. 				// Proporcional
oSize:Process() 	   					// Dispara os calculos

DEFINE FONT oFont NAME "Arial" SIZE 0,-11 BOLD

DEFINE MSDIALOG oDlgGrid TITLE OemToAnsi( STR0014 ) From 0,0 TO 600,1230 OF oMainWnd PIXEL //"Selecione os sindicatos que serão associados"

// Cria o conteiner onde serão colocados os paineis
oTela		:= FWFormContainer():New( oDlgGrid )
cIdGrid  	:= oTela:CreateHorizontalBox( 80 )

oTela:Activate( oDlgGrid, .F. )

//Cria os paineis onde serao colocados os browses
oPanel	:= oTela:GeTPanel( cIdGrid )

@ oSize:GetDimension("CABECALHO","LININI")+1 , oSize:GetDimension("CABECALHO","COLINI")+4	GROUP oGroup TO oSize:GetDimension("CABECALHO","LINEND") * 0.090 ,oSize:GetDimension("CABECALHO","COLEND") * 0.431  OF oDlgGrid PIXEL
oGroup:oFont:=oFont
@ oSize:GetDimension("CABECALHO","LININI")+9 , oSize:GetDimension("CABECALHO","COLINI")+6 SAY "" Of oDlgGrid Pixel

oMark := FWMarkBrowse():New()

oMark:SetOwner(oPanel)
oMark:SetAlias(cAliasTRB)
oMark:SetTemporary(.T.)
oMark:SetColumns(aColumns)
oMark:SetFieldMark('OK')
oMark:SetFilterDefault( "" )
oMark:SetIgnoreARotina(.T.)
oMark:SetMenuDef('')
oMark:SetSeek( .T., aPesq )

oMark:bAllMark := { || SetMarkAll(oMark:Mark(), aMarca[1] := !aMarca[1], cAliasTRB ), oMark:Refresh(.T.)  }

oMark:Activate()

SetMarkAll(oMark:Mark(),.F.,cAliasTRB,cSindicatos) //Desmarca todos os registros

oMark:Refresh(.T.)

ACTIVATE MSDIALOG oDlgGrid CENTERED ON INIT EnchoiceBar(oDlgGrid, {||nOpcX := 1, oDlgGrid:End() } ,{|| oDlgGrid:End() }, NIL, {})

If nOpcX == 1

	//Adiciona filiais selecionadas
	(cAliasTRB)->(dbGoTop())

	lInclui := !Empty(cSindicatos)

	If lInclui
		For nX := 1 to nTam //Desmarca todos os sindicatos
			oGrid:GoLine(nX)
			oGrid:LoadValue("RCE_OK",.F.)
		Next nX
	Else
		oGrid:GoLine(1)
	EndIf

	lVldSindObg := .F.

	While (cAliasTRB)->(!EOF())
		If !Empty((cAliasTRB)->OK)

			If lInclui
				If !oGrid:SeekLine({{"RCE_FILIAL",(cAliasTRB)->FILIAL},{"RCE_CODIGO",(cAliasTRB)->CODIGO}})
					oGrid:AddLine(.T.) //Se não encontrar, adiciona uma linha
				EndIf
			EndIf

			oGrid:LoadValue("RCE_FILIAL"	,(cAliasTRB)->FILIAL)
			oGrid:LoadValue("RCE_CODIGO"	,(cAliasTRB)->CODIGO)
			oGrid:LoadValue("RCE_DESCRI"    ,(cAliasTRB)->NOME)
			oGrid:LoadValue("RCE_OK"		,.T.)

			If Len(aCpoObrigat) > 0
				nRecRCE := RCE->(Recno())
				If RCE->(DbSeek((cAliasTRB)->FILIAL + (cAliasTRB)->CODIGO))
					For nX := 1 to Len(aCpoObrigat)
						If Empty(RCE->(&(aCpoObrigat[nX])))
							lVldSindObg := .T. //Se houver campo obrigatório que esta vazio, refaço a validação inicial do model
						EndIf
					Next nX
				EndIf
				RCE->(DbGoTo(nRecRCE))
			EndIf

			lInclui := .T.
		EndIf
		(cAliasTRB)->(dbSkip())
	EndDo

	oGrid:GoLine(1)
EndIf

RestArea(aArea)

Return Nil

/*/{Protheus.doc} LoadFuncoes
Seleciona as funções que serão associadas a CCT
@author Leandro Drumond
@since 04/04/2022
@Type     Function
/*/
Static Function LoadFuncoes(oModel)
Local aArea 		:= GetArea()
Local aStru  		:= {}
Local aLstIndices	:= {}
Local aColumns		:= {}
Local aPesq			:= {}
Local oGrid			:= oModel:GetModel("GPEA943_RI4")
Local cFuncoes   	:= ""
Local cIdGrid		:= ""
Local cFilRI4		:= xFilial("RI4", SWY->WY_FILIAL)
Local nTam          := oGrid:Length()
Local nX 			:= 0
Local nOpcX			:= 0
Local oSize
Local oTela
Local oDlgGrid
Local oPanel
Local oMark
Local oFont
Local oGroup
Local lInclui
Local nTamFunc		:= TamSx3("RJ_FUNCAO")[1]

Private cAliasTRB

For nX := 1 to nTam
	oGrid:GoLine(nX)
	If oGrid:GetValue("RI4_OK")
		cFuncoes += oGrid:GetValue("RI4_FILSRJ") + oGrid:GetValue("RI4_CODSRJ") + "#"
	EndIf
Next nX

Static cAliasRI4
Static oArqRI4

If oArqRI4 == Nil //Monta temporária com filiais disponíveis
	Aadd(aStru, {"OK"		, "C", 2						, 0})
	Aadd(aStru, {"FILIAL"	, "C", FwGetTamFilial			, 0})
	Aadd(aStru, {"CODIGO"  	, "C", nTamFunc					, 0})
	Aadd(aStru, {"NOME"  	, "C", 20						, 0})
	AAdd(aLstIndices, {"FILIAL","CODIGO"})
	AAdd(aLstIndices, {"NOME"})

	cAliasRI4 := cAliasTRB := GetNextAlias()

	oArqRI4 := RhCriaTrab(cAliasTRB, aStru, aLstIndices)

	DbSelectArea("SRJ")
	DbSetOrder(1)

	SRJ->(DbGoTop())

	While SRJ->(!Eof())
		RecLock(cAliasTRB, .T.)
		(cAliasTRB)->FILIAL	:= SRJ->RJ_FILIAL
		(cAliasTRB)->CODIGO	:= SRJ->RJ_FUNCAO
		(cAliasTRB)->NOME	:= SRJ->RJ_DESC
		(cAliasTRB)->(MsUnlock())
		SRJ->(DbSkip())
	EndDo
Else
	cAliasTRB := cAliasRI4
EndIf

AAdd(aColumns,FWBrwColumn():New())
aColumns[Len(aColumns)]:SetData( &("{||(cAliasTRB)->FILIAL}") )
aColumns[Len(aColumns)]:SetTitle(STR0011) //"Filial"
aColumns[Len(aColumns)]:SetSize(FwGetTamFilial)
aColumns[Len(aColumns)]:SetDecimal(0)
aColumns[Len(aColumns)]:SetPicture("@!")

AAdd(aColumns,FWBrwColumn():New())
aColumns[Len(aColumns)]:SetData( &("{||(cAliasTRB)->CODIGO}") )
aColumns[Len(aColumns)]:SetTitle(STR0012) //"Código"
aColumns[Len(aColumns)]:SetSize(nTamFunc)
aColumns[Len(aColumns)]:SetDecimal(0)
aColumns[Len(aColumns)]:SetPicture("@!")

AAdd(aColumns,FWBrwColumn():New())
aColumns[Len(aColumns)]:SetData( &("{||(cAliasTRB)->NOME}") )
aColumns[Len(aColumns)]:SetTitle(STR0013) //"Descrição"
aColumns[Len(aColumns)]:SetSize(20)
aColumns[Len(aColumns)]:SetDecimal(0)
aColumns[Len(aColumns)]:SetPicture("@!")

Aadd( aPesq , {	STR0012, { { "CODIGO"   , "C", nTamFunc, 0, "CODIGO", "@!"}}, 1})
Aadd( aPesq , {	STR0013, { { "NOME   "  , "C", 20 , 0, "NOME"  , "@!"}}, 1})

oSize := FwDefSize():New(.F.)

oSize:AddObject( "CABECALHO",(oSize:aWindSize[3]*1.1),(oSize:aWindSize[3]*0.4) , .F., .F. ) // Não dimensionavel
oSize:aMargins 	:= { 0, 0, 0, 0 } 		// Espaco ao lado dos objetos 0, entre eles 3
oSize:lProp 		:= .F. 				// Proporcional
oSize:Process() 	   					// Dispara os calculos

DEFINE FONT oFont NAME "Arial" SIZE 0,-11 BOLD

DEFINE MSDIALOG oDlgGrid TITLE OemToAnsi( STR0031 ) From 0,0 TO 600,1230 OF oMainWnd PIXEL //"Selecione as funções que serão associadas"

// Cria o conteiner onde serão colocados os paineis
oTela		:= FWFormContainer():New( oDlgGrid )
cIdGrid  	:= oTela:CreateHorizontalBox( 80 )

oTela:Activate( oDlgGrid, .F. )

//Cria os paineis onde serao colocados os browses
oPanel	:= oTela:GeTPanel( cIdGrid )

@ oSize:GetDimension("CABECALHO","LININI")+1 , oSize:GetDimension("CABECALHO","COLINI")+4	GROUP oGroup TO oSize:GetDimension("CABECALHO","LINEND") * 0.090 ,oSize:GetDimension("CABECALHO","COLEND") * 0.431  OF oDlgGrid PIXEL
oGroup:oFont:=oFont
@ oSize:GetDimension("CABECALHO","LININI")+9 , oSize:GetDimension("CABECALHO","COLINI")+6 SAY "" Of oDlgGrid Pixel

oMark := FWMarkBrowse():New()

oMark:SetOwner(oPanel)
oMark:SetAlias(cAliasTRB)
oMark:SetTemporary(.T.)
oMark:SetColumns(aColumns)
oMark:SetFieldMark('OK')
oMark:SetFilterDefault( "" )
oMark:SetIgnoreARotina(.T.)
oMark:SetMenuDef('')
oMark:SetSeek( .T., aPesq )

oMark:bAllMark := { || SetMarkAll(oMark:Mark(), aMarca[2] := !aMarca[2], cAliasTRB ), oMark:Refresh(.T.)  }

oMark:Activate()

SetMarkAll(oMark:Mark(),.F.,cAliasTRB,cFuncoes) //Desmarca todos os registros

oMark:Refresh(.T.)

ACTIVATE MSDIALOG oDlgGrid CENTERED ON INIT EnchoiceBar(oDlgGrid, {||nOpcX := 1, oDlgGrid:End() } ,{|| oDlgGrid:End() }, NIL, {})

If nOpcX == 1

	//Adiciona filiais selecionadas
	(cAliasTRB)->(dbGoTop())

	lInclui := !Empty(cFuncoes)

	If lInclui
		For nX := 1 to nTam //Desmarca todas as funções
			oGrid:GoLine(nX)
			oGrid:LoadValue("RI4_OK",.F.)
		Next nX
	Else
		oGrid:GoLine(1)
	EndIf

	While (cAliasTRB)->(!EOF())
		If !Empty((cAliasTRB)->OK)

			If lInclui
				If !oGrid:SeekLine({{"RI4_FILSRJ",(cAliasTRB)->FILIAL},{"RI4_CODSRJ",(cAliasTRB)->CODIGO}})
					oGrid:AddLine(.T.) //Se não encontrar, adiciona uma linha
				EndIf
			EndIf

			oGrid:LoadValue("RI4_FILIAL"	,cFilRI4)
			oGrid:LoadValue("RI4_FILCCT"	,SWY->WY_FILIAL)
			oGrid:LoadValue("RI4_CODCCT"	,SWY->WY_CODIGO)
			oGrid:LoadValue("RI4_FILSRJ"	,(cAliasTRB)->FILIAL)
			oGrid:LoadValue("RI4_CODSRJ"	,(cAliasTRB)->CODIGO)
			oGrid:LoadValue("RI4_DESC"    	,(cAliasTRB)->NOME)
			oGrid:LoadValue("RI4_OK"		,.T.)

			lInclui := .T.
		EndIf
		(cAliasTRB)->(dbSkip())
	EndDo

	oGrid:GoLine(1)
EndIf

RestArea(aArea)

Return Nil

/*/{Protheus.doc} LoadVerbas
Seleciona as verbas que serão associadas a CCT
@author Leandro Drumond
@since 06/04/2022
@Type     Function
/*/
Static Function LoadVerbas(oModel)
Local aArea 		:= GetArea()
Local aStru  		:= {}
Local aLstIndices	:= {}
Local aColumns		:= {}
Local aPesq			:= {}
Local oGrid			:= oModel:GetModel("GPEA943_REB")
Local cVerbas   	:= ""
Local cIdGrid		:= ""
Local cFilREB		:= xFilial("REB", SWY->WY_FILIAL)
Local nTam          := oGrid:Length()
Local nX 			:= 0
Local nOpcX			:= 0
Local nQtd			:= 0
Local oSize
Local oTela
Local oDlgGrid
Local oPanel
Local oMark
Local oFont
Local oGroup
Local lInclui

Private cAliasTRB

For nX := 1 to nTam
	oGrid:GoLine(nX)
	If oGrid:GetValue("REB_OK")
		cVerbas += oGrid:GetValue("REB_FILSRV") + oGrid:GetValue("REB_CODSRV") + "#"
	EndIf
Next nX

Static cAliasREB
Static oArqREB

If oArqREB == Nil //Monta temporária com filiais disponíveis
	Aadd(aStru, {"OK"		, "C", 2						, 0})
	Aadd(aStru, {"FILIAL"	, "C", FwGetTamFilial			, 0})
	Aadd(aStru, {"CODIGO"  	, "C", 3						, 0})
	Aadd(aStru, {"NOME"  	, "C", 20						, 0})
	AAdd(aLstIndices, {"FILIAL","CODIGO"})
	AAdd(aLstIndices, {"NOME"})

	cAliasREB := cAliasTRB := GetNextAlias()

	oArqREB := RhCriaTrab(cAliasTRB, aStru, aLstIndices)

	DbSelectArea("SRV")
	DbSetOrder(1)

	SRV->(DbGoTop())

	While SRV->(!Eof())
		RecLock(cAliasTRB, .T.)
		(cAliasTRB)->FILIAL	:= SRV->RV_FILIAL
		(cAliasTRB)->CODIGO	:= SRV->RV_COD
		(cAliasTRB)->NOME	:= SRV->RV_DESC
		(cAliasTRB)->(MsUnlock())
		SRV->(DbSkip())
	EndDo
Else
	cAliasTRB := cAliasREB
EndIf

AAdd(aColumns,FWBrwColumn():New())
aColumns[Len(aColumns)]:SetData( &("{||(cAliasTRB)->FILIAL}") )
aColumns[Len(aColumns)]:SetTitle(STR0011) //"Filial"
aColumns[Len(aColumns)]:SetSize(FwGetTamFilial)
aColumns[Len(aColumns)]:SetDecimal(0)
aColumns[Len(aColumns)]:SetPicture("@!")

AAdd(aColumns,FWBrwColumn():New())
aColumns[Len(aColumns)]:SetData( &("{||(cAliasTRB)->CODIGO}") )
aColumns[Len(aColumns)]:SetTitle(STR0012) //"Código"
aColumns[Len(aColumns)]:SetSize(3)
aColumns[Len(aColumns)]:SetDecimal(0)
aColumns[Len(aColumns)]:SetPicture("@!")

AAdd(aColumns,FWBrwColumn():New())
aColumns[Len(aColumns)]:SetData( &("{||(cAliasTRB)->NOME}") )
aColumns[Len(aColumns)]:SetTitle(STR0013) //"Descrição"
aColumns[Len(aColumns)]:SetSize(20)
aColumns[Len(aColumns)]:SetDecimal(0)
aColumns[Len(aColumns)]:SetPicture("@!")

Aadd( aPesq , {	STR0012, { { "CODIGO"   , "C", 03 , 0, "CODIGO", "@!"}}, 1})
Aadd( aPesq , {	STR0013, { { "NOME   "  , "C", 20 , 0, "NOME"  , "@!"}}, 1})

oSize := FwDefSize():New(.F.)

oSize:AddObject( "CABECALHO",(oSize:aWindSize[3]*1.1),(oSize:aWindSize[3]*0.4) , .F., .F. ) // Não dimensionavel
oSize:aMargins 	:= { 0, 0, 0, 0 } 		// Espaco ao lado dos objetos 0, entre eles 3
oSize:lProp 		:= .F. 				// Proporcional
oSize:Process() 	   					// Dispara os calculos

DEFINE FONT oFont NAME "Arial" SIZE 0,-11 BOLD

DEFINE MSDIALOG oDlgGrid TITLE OemToAnsi( STR0032 ) From 0,0 TO 600,1230 OF oMainWnd PIXEL //"Selecione as funções que serão associadas"

// Cria o conteiner onde serão colocados os paineis
oTela		:= FWFormContainer():New( oDlgGrid )
cIdGrid  	:= oTela:CreateHorizontalBox( 80 )

oTela:Activate( oDlgGrid, .F. )

//Cria os paineis onde serao colocados os browses
oPanel	:= oTela:GeTPanel( cIdGrid )

@ oSize:GetDimension("CABECALHO","LININI")+1 , oSize:GetDimension("CABECALHO","COLINI")+4	GROUP oGroup TO oSize:GetDimension("CABECALHO","LINEND") * 0.090 ,oSize:GetDimension("CABECALHO","COLEND") * 0.431  OF oDlgGrid PIXEL
oGroup:oFont:=oFont
@ oSize:GetDimension("CABECALHO","LININI")+9 , oSize:GetDimension("CABECALHO","COLINI")+6 SAY "" Of oDlgGrid Pixel

oMark := FWMarkBrowse():New()

oMark:SetOwner(oPanel)
oMark:SetAlias(cAliasTRB)
oMark:SetTemporary(.T.)
oMark:SetColumns(aColumns)
oMark:SetFieldMark('OK')
oMark:SetFilterDefault( "" )
oMark:SetIgnoreARotina(.T.)
oMark:SetMenuDef('')
oMark:SetSeek( .T., aPesq )

oMark:bAllMark := { || SetMarkAll(oMark:Mark(), aMarca[3] := !aMarca[3], cAliasTRB ), oMark:Refresh(.T.)  }

oMark:Activate()

SetMarkAll(oMark:Mark(),.F.,cAliasTRB,cVerbas) //Desmarca todos os registros

oMark:Refresh(.T.)

ACTIVATE MSDIALOG oDlgGrid CENTERED ON INIT EnchoiceBar(oDlgGrid, {||nOpcX := 1, oDlgGrid:End() } ,{|| oDlgGrid:End() }, NIL, {})

If nOpcX == 1

	//Adiciona filiais selecionadas
	(cAliasTRB)->(dbGoTop())

	lInclui := !Empty(cVerbas)

	If lInclui
		For nX := 1 to nTam //Desmarca todas as funções
			oGrid:GoLine(nX)
			oGrid:LoadValue("REB_OK",.F.)
			nQtd++
		Next nX
	Else
		oGrid:GoLine(1)
		nQtd++
	EndIf

	While (cAliasTRB)->(!EOF())
		If !Empty((cAliasTRB)->OK)

			If lInclui
				If !oGrid:SeekLine({{"REB_FILSRV",(cAliasTRB)->FILIAL},{"REB_CODSRV",(cAliasTRB)->CODIGO}})
					If ++nQtd > 500
						MsgInfo(STR0038) //"Número máximo de linhas para inclusão no GRID é de 500"
						Exit
					EndIf
					oGrid:AddLine(.T.) //Se não encontrar, adiciona uma linha
				EndIf
			EndIf

			oGrid:LoadValue("REB_FILIAL"	,cFilREB)
			oGrid:LoadValue("REB_FILCCT"	,SWY->WY_FILIAL)
			oGrid:LoadValue("REB_CODCCT"	,SWY->WY_CODIGO)
			oGrid:LoadValue("REB_FILSRV"	,(cAliasTRB)->FILIAL)
			oGrid:LoadValue("REB_CODSRV"	,(cAliasTRB)->CODIGO)
			oGrid:LoadValue("REB_DESC"    	,(cAliasTRB)->NOME)
			oGrid:LoadValue("REB_OK"		,.T.)

			lInclui := .T.
		EndIf
		(cAliasTRB)->(dbSkip())
	EndDo

	oGrid:GoLine(1)
EndIf

RestArea(aArea)

Return Nil

/*/{Protheus.doc} SetMarkAll
Marca/Desmarca os registros
@author Leandro Drumond
@since 28/03/2022
@version P12.1.33
@Type     Function
/*/
Static Function SetMarkAll(cMarca,lMarcar,cAliasTRB,cMarcados)

Local cAliasMark := cAliasTRB
Local aAreaMark  := (cAliasMark)->( GetArea() )

DEFAULT cMarca := ""

dbSelectArea(cAliasMark)
(cAliasMark)->( dbGoTop() )

While !(cAliasMark)->( Eof() )
	RecLock( (cAliasMark), .F. )
	If !Empty(cMarcados)
		If (cAliasMark)->FILIAL + (cAliasMark)->CODIGO $ cMarcados
			(cAliasMark)->OK := cMarca
		Else
			(cAliasMark)->OK := '  '
		EndIf
	Else
		(cAliasMark)->OK := IIf( lMarcar , cMarca, '  ' )
	EndIf
	MsUnLock()
	(cAliasMark)->( dbSkip() )
EndDo

RestArea(aAreaMark)

Return .T.

/*/{Protheus.doc} RemoveFields
Deixa apenas o código do sindicato e descrição no grid
@author Leandro Drumond
@since 28/03/2022
@Type     Function
/*/
Static Function RemoveFields(oStruct)
Local aAux 		:= aClone(oStruct:GetFields())
Local nX 		:= 0

For nX := 1 to Len(aAux)
	If !(aAux[nX, MVC_VIEW_IDFIELD ] $ "RCE_FILIAL*RCE_CODIGO*RCE_DESCRI")
		oStruct:RemoveField(aAux[nX, MVC_VIEW_IDFIELD ])
	EndIf
Next nX

Return Nil

/*/{Protheus.doc} RCEFieldsObg
Torna campos obrigatórios sem correspondente da SWY não obrigatórios
@author Leandro Drumond
@since 22/01/2025
@Type     Function
/*/
Static Function RCEFieldsObg(oStructRCE,oStructSWY)
Local aAuxRCE	:= aClone(oStructRCE:GetFields())
Local aAuxSWY   := aClone(oStructSWY:GetFields())
Local cCpoAux   := ""
Local nX 		:= 0

If !lVldSindObg .and. Empty(aCpoObrigat)
	For nX := 1 to Len(aAuxRCE)
		If !(aAuxRCE[nX, MODEL_FIELD_IDFIELD ] $ "RCE_FILIAL*RCE_CODIGO*RCE_DESCRI")
			If aAuxRCE[nX, MODEL_FIELD_OBRIGAT]
				cCpoAux := StrTran(aAuxRCE[nX, MODEL_FIELD_IDFIELD ],"RCE_","WY_")
				If ( aScan(aAuxSWY, {|x| x[MODEL_FIELD_IDFIELD] == cCpoAux})  ) == 0
					oStructRCE:SetProperty(aAuxRCE[nX, MODEL_FIELD_IDFIELD ],MODEL_FIELD_OBRIGAT, .F. )
					aAdd(aCpoObrigat,aAuxRCE[nX, MODEL_FIELD_IDFIELD ])
				EndIf
			EndIf
		EndIf
	Next nX
ElseIf lVldSindObg
	For nX := 1 to Len(aCpoObrigat)
		oStructRCE:SetProperty(aCpoObrigat[nX],MODEL_FIELD_OBRIGAT, .T. )
	Next nX
	aCpoObrigat := {}
EndIf

Return .T.

/*/{Protheus.doc} Gpea943When
When dos campos de ATS e PLR
@author Leandro Drumond
@since 22/03/2022
@Type     Function
/*/
Function Gpea943When()
Local cVar 		:= ReadVar()
Local oModel    := FWModelActive()
Local lRet 		:= .F.

oModel  := oModel:GetModel("GPEA943_SWY")

If "WY_VLR" $ cVar //When dos campos Valor ATS
	If oModel:GetValue("WY_TPCATS") $ "2*3"
		lRet := .T.
	EndIf
ElseIf "WY_PER" $ cVar //When dos campos Percentual ATS
	If oModel:GetValue("WY_TPCATS") $ "1*2"
		lRet := .T.
	EndIf
ElseIf "WY_PLRVLR" $ cVar
	If oModel:GetValue("WY_PLRTPC") == "2"
		lRet := .T.
	EndIf
ElseIf "WY_PLRPER" $ cVar
	If oModel:GetValue("WY_PLRTPC") == "1"
		lRet := .T.
	EndIf
EndIf

Return lRet

/*/{Protheus.doc} Gpea943Grv
Efetua gravação do modelo de dados
@author Leandro Drumond
@since 28/03/2022
@Type     Function
/*/
Static Function Gpea943Grv( oModel )
Local nOperation := oModel:GetOperation()
Local oGrid
Local nTam
Local nX
Local lRet		 := .T.
Local lTecXRH	 := SuperGetMV("MV_TECXRH",,.F.)

DEFAULT lTemRUK	 := AliasInDic("RUK")

Begin Transaction

	If nOperation == 4 //--Alteracao - Grava historico dos campos alterados
		fGrvHist(oModel)
	EndIf
	If nOperation == 3 .or. nOperation == 4
		oGrid := oModel:GetModel("GPEA943_RI4")
		oModel:GetModel( "GPEA943_RI4" ):SetNoDeleteLine(.F.)
		nTam  := oGrid:Length()
		For nX := 1 to nTam
			oGrid:GoLine(nX)
			If !oGrid:GetValue("RI4_OK") .or. Empty(oGrid:GetValue("RI4_CODSRJ"))
				If ValType(cAliasRI4) # "U"
					SetMarkDel(cAliasRI4, oGrid:GetValue("RI4_FILSRJ"), oGrid:GetValue("RI4_CODSRJ"))
				EndIf	
				oGrid:DeleteLine() //Se a linha foi desmarcada, deixa
			EndIf
		Next nX
		oModel:GetModel( "GPEA943_RI4" ):SetNoDeleteLine(.T.)

		oGrid := oModel:GetModel("GPEA943_REB")
		oModel:GetModel( "GPEA943_REB" ):SetNoDeleteLine(.F.)
		nTam  := oGrid:Length()
		For nX := 1 to nTam
			oGrid:GoLine(nX)
			If !oGrid:GetValue("REB_OK") .or. Empty(oGrid:GetValue("REB_CODSRV"))
				If ValType(cAliasREB) # "U"
					SetMarkDel(cAliasREB, oGrid:GetValue("REB_FILSRV"), oGrid:GetValue("REB_CODSRV"))
				EndIf
				oGrid:DeleteLine() //Se a linha foi desmarcada, deixa
			EndIf
		Next nX
		oModel:GetModel( "GPEA943_REB" ):SetNoDeleteLine(.T.)

		oGrid := oModel:GetModel("GPEA943_REI")
		oModel:GetModel( "GPEA943_REI" ):SetNoDeleteLine(.F.)
		nTam  := oGrid:Length()
		For nX := 1 to nTam
			oGrid:GoLine(nX)
			If !oGrid:GetValue("REI_OK") .or. Empty(oGrid:GetValue("REI_CODAA0"))
				oGrid:DeleteLine() //Se a linha foi desmarcada, deixa
			EndIf
		Next nX
		oModel:GetModel( "GPEA943_REI" ):SetNoDeleteLine(.T.)

		If lTecXRH .And. lTemRUK
			oGrid := oModel:GetModel("GPEA943_RUK")
			oModel:GetModel( "GPEA943_RUK" ):SetNoDeleteLine(.F.)
			nTam  := oGrid:Length()
			For nX := 1 to nTam
				oGrid:GoLine(nX)
				If !oGrid:GetValue("RUK_OK") .or. Empty(oGrid:GetValue("RUK_CODMUN"))
					oGrid:DeleteLine() //Se a linha foi desmarcada, deixa
				EndIf
			Next nX
			oModel:GetModel( "GPEA943_RUK" ):SetNoDeleteLine(.T.)
		EndIf	
	EndIf

	If nOperation == 3 //Limpa a SYY para não gravar histórico indevido em caso de cópia do registro
		oModel:GetModel("GPEA943_SYY"):ClearData(.F.)
	EndIf

	If FWFormCommit( oModel )

		If nOperation == 4 .or. nOperation == 3
			MsAguarde( { || lRet := fGrvSind(oModel) } , OemtoAnsi(STR0020)) //"Aguarde...associando sindicatos"
		EndIf

	EndIf

End Transaction

Return lRet

/*/{Protheus.doc} Gpea943Vld
Efetua validação do modelo de dados
@author Leandro Drumond
@since 29/03/2022
@Type     Function
/*/
Static Function Gpea943Vld( oModel )
Local nOperation := oModel:GetOperation()
Local oGrid
Local nX		 := 0
Local lRet		 := .T.
Local lTecXRH	 := SuperGetMV("MV_TECXRH",,.F.)

DEFAULT lTemRUK	 := AliasInDic("RUK")

If nOperation == 5 //--Exclusão
	oGrid := oModel:GetModel("GPEA943_RCE")
	If oGrid:Length() > 0
		oGrid:GoLine(1)
		If !Empty(oGrid:GetValue("RCE_CODIGO"))
			lRet := .F.
			Help(,, OemToAnsi(STR0015),, + CRLF + OemToAnsi(STR0016) , 1, 0,,,,,, { + CRLF + OemToAnsi(STR0017)})//"Atencao" ## "Esta CCT esta sendo utilizada nos sindicatos listados na grid." ### "Desassocie os sindicatos antes de excluir a CCT"
		EndIf
	EndIf
EndIf

If nOperation == 4 .or. nOperation == 3
	If lTecXRH .And. lTemRUK .And. Empty(oModel:GetValue("GPEA943_SWY", "WY_ESTADO")) 
		oGrid := oModel:GetModel("GPEA943_RUK")
		For nX := 1 to oGrid:Length()
			oGrid:GoLine(nX)
			If oGrid:GetValue("RUK_OK")  // Não deixa salvar com campo estado vazio quando existe município associado
				lRet := .F.
				Help(,, OemToAnsi(STR0015),, + CRLF + OemToAnsi(STR0064) , 1, 0,,,,,, { + CRLF + OemToAnsi(STR0067)}) //"Atencao" ## "Campo Estado está vazio." ### "Necessário desassociar os municípios."
				Exit
			EndIf
		Next nX			
	EndIf

	If lTecXRH 
		oGrid := oModel:GetModel("GPEA943_REB")
		For nX := 1 to oGrid:Length()
			oGrid:GoLine(nX)
			If !oGrid:GetValue("REB_OK") .AND. !Empty(oGrid:GetValue("REB_CODSRV"))
				If fVerPdTec(oGrid:GetValue("REB_CODSRV"))
					lRet := .F.
					Exit
				EndIf	
			EndIf
		Next nX			
	EndIf

	If lRet
		If Empty(oModel:GetValue("GPEA943_SWY", "WY_ESTADO")) .And. !Empty(oModel:GetValue("GPEA943_SWY", "WY_DESCEST")) //Limpa o campo WY_DESCEST quando o campo Estado estiver vazio
			oModel:LoadValue("GPEA943_SWY", "WY_DESCEST", "")
		EndIf
		lRet := fGrvSind( oModel, .F. )
	EndIf	
EndIf

Return lRet

/*/{Protheus.doc} fGrvHist
Grava o histórico dos campos alterados
@author Leandro Drumond
@since 28/03/2022
@Type     Function
/*/
Static Function fGrvHist( oModel )
Local aArea		:= GetArea()
Local oMyMdl01	:= oModel:GetModel("GPEA943_SWY")
Local oMdlRI4	:= oModel:GetModel("GPEA943_RI4")
Local oMdlREB	:= oModel:GetModel("GPEA943_REB")
Local oMdlREI	:= oModel:GetModel("GPEA943_REI")
Local oMdlRCE   := oModel:GetModel("GPEA943_RCE")
Local oMdlRUK
Local oStruct 	:= oMyMdl01:GetStruct()
Local aAux 		:= oStruct:GetFields()
Local aTabelas  := {}
Local cCCT		:= oMyMdl01:GetValue("WY_CODIGO")
Local cCampo	:= ""
Local cCpoAux   := ""
Local cTipo		:= ""
Local cConteudo	:= ""
Local cNewValor	:= ""
Local cFilSWY	:= xFilial("SWY")
Local cFilAux   := ""
Local nX		:= 0
Local nY 		:= 0
Local nTamMdl   := 0
Local lDelReg   := .F.
Local lNewReg   := .F.
Local lTecXRH	:= SuperGetMV("MV_TECXRH",,.F.)

DEFAULT lCpoATU := SYY->(ColumnPos("YY_CNTATU") > 0)

DbSelectArea("SYY")
DbSetOrder(1)

For nX := 1 To Len(aAux)
	cCampo 		:= aAux[nX, MODEL_FIELD_IDFIELD ]
	cTipo  		:= aAux[nX, MODEL_FIELD_TIPO ]

	If cCampo <> "WY_FILIAL"
		If cTipo == "D"
			cConteudo  	:= DtoC(&("SWY->"+cCampo))
			cNewValor   := DtoC(oMyMdl01:GetValue(cCampo))
		Else
			cConteudo   := If(cTipo=="N",AllTrim(STR(&("SWY->"+cCampo))),&("SWY->"+cCampo))
			cNewValor   := If(cTipo=="N",AllTrim(STR(oMyMdl01:GetValue(cCampo))),oMyMdl01:GetValue(cCampo))
		EndIf
		If cTipo $ "C*N*D" .and. oMyMdl01:GetValue(cCampo) <> &("SWY->"+cCampo)
			If SYY->(DbSeek(cFilSWY+cCCT+PadR(cCampo,10)+DtoS(dDataBase)))
				RecLock("SYY",.F.)
			Else
				RecLock("SYY",.T.)
			EndIf
			SYY->YY_FILIAL	:= cFilSWY
			SYY->YY_CODIGO	:= cCCT
			SYY->YY_CAMPO	:= cCampo
			SYY->YY_CONTEUD	:= cConteudo
			SYY->YY_DATA	:= dDataBase
			If lCpoATU
				SYY->YY_CNTATU	:= cNewValor
			EndIf
			SYY->(MsUnLock())
		EndIf
	EndIf
Next nX

If lCpoATU //Grava histórico das novas tabelas apenas se ovo campo YY_CNTATU existir

	//--Tratamento para gravar histórico das demais tabelas
	aAux := oMdlRCE:GetStruct():GetFields()
	aAdd(aTabelas, {"RCE", aAux})

	aAux := oMdlRI4:GetStruct():GetFields()
	aAdd(aTabelas, {"RI4", aAux})

	aAux := oMdlREB:GetStruct():GetFields()
	aAdd(aTabelas, {"REB", aAux})

	If lTecXRH
		aAux := oMdlREI:GetStruct():GetFields()
		aAdd(aTabelas, {"REI", aAux})
		If lTemRUK
			oMdlRUK	:= oModel:GetModel("GPEA943_RUK")
			aAux := oMdlRUK:GetStruct():GetFields()
			aAdd(aTabelas, {"RUK", aAux})
		EndIf
	EndIf

	For nX := 1 to Len(aTabelas)
		cTabela := aTabelas[nX,1]
		cFilAux	:= xFilial(cTabela)
		aAux    := aClone(aTabelas[nX,2])
		nTamMdl := 1
		Do Case
			Case cTabela == "RCE"
				oMdlAux	:= oModel:GetModel("GPEA943_RCE")
				cCpoOk := "RCE_OK"
				cCampo := "RCE_CODIGO"
			Case cTabela == "RI4"
				oMdlAux	:= oModel:GetModel("GPEA943_RI4")
				cCpoOk := "RI4_OK"
				cCampo := "RI4_CODSRJ"
			Case cTabela == "REB"
				oMdlAux	:= oModel:GetModel("GPEA943_REB")
				cCpoOk := "REB_OK"
				cCampo := "REB_CODSRV"
			Case cTabela == "REI"
				oMdlAux	:= oModel:GetModel("GPEA943_REI")
				cCpoOk := "REI_OK"
				cCampo := "REI_CODAA0"
			Case cTabela == "RUK"
				oMdlAux	:= oModel:GetModel("GPEA943_RUK")
				cCpoOk := "RUK_OK"
				cCampo := "RUK_CODMUN"
		EndCase

		nTamMdl := oMdlAux:Length()

		For nY := 1 to nTamMdl
			oMdlAux:GoLine(nY)
			If oMdlAux:IsInserted() .and. oMdlAux:GetValue(cCpoOk) .and. !Empty(oMdlAux:GetValue(cCampo))//Se foi incluída, grava valor anterior com vazio
				lDelReg := .F.
			ElseIf oMdlAux:IsDeleted() .or. ( !oMdlAux:GetValue(cCpoOk) .and. !Empty(oMdlAux:GetValue(cCampo)) )//Se foi deletada, grava valor anterior
				lDelReg := .T.
			Else 
				Loop //Se não incluiu ou deletou, não grava nada
			EndIf
			cCpoAux := AllTrim(oMdlAux:GetValue(cCampo))
			cKeyAux := cFilSWY+cCCT+PadR(cCampo,10)+DtoS(dDataBase)
			If SYY->(DbSeek(cKeyAux))
				lNewReg := .T.
				While SYY->(!Eof() .and. YY_FILIAL + YY_CODIGO + YY_CAMPO + DtoS(YY_DATA) == cFilSWY+cCCT+PadR(cCampo,10)+DtoS(dDataBase) )
					If lDelReg .and. ( AllTrim(SYY->YY_CONTEUD) == cCpoAux .or. ( AllTrim(SYY->YY_CNTATU) == cCpoAux .and. Empty(SYY->YY_CONTEUD) ) )
						lNewReg := .F.
						Exit 
					ElseIf !lDelReg .and. ( AllTrim(SYY->YY_CNTATU) == cCpoAux .or. ( AllTrim(SYY->YY_CONTEUD) == cCpoAux .and. Empty(SYY->YY_CNTATU) ) )
						lNewReg := .F. 
						Exit
					EndIf
					SYY->(DbSkip())
				EndDo
				RecLock("SYY",lNewReg)
			Else
				RecLock("SYY",.T.)
			EndIf

			SYY->YY_FILIAL	:= cFilSWY
			SYY->YY_CODIGO	:= cCCT
			SYY->YY_CAMPO	:= cCampo
			SYY->YY_CONTEUD	:= If(!lDelReg, "", cCpoAux)
			SYY->YY_CNTATU	:= If(lDelReg, "", cCpoAux)
			SYY->YY_DATA	:= dDataBase
			SYY->(MsUnLock())

		Next nY
	Next nX
EndIf

RestArea(aArea)

Return .T.

/*/{Protheus.doc} fGrvSind
Replica as informações para os sindicatos selecionados.
@author Leandro Drumond
@since 28/03/2022
@Type     Function
/*/
Static Function fGrvSind( oMdl, lGrava )
Local lRet 			:= .T.
Local cChave        := ""
Local cCampoSWY     := ""
Local cCampoRCE     := ""
Local nX 			:= 0
Local nY   			:= 0
Local oModel
Local oModelRCE
Local oGrid			:= oMdl:GetModel("GPEA943_RCE")
Local oModelSWY		:= oMdl:GetModel("GPEA943_SWY")
Local oStruct 		:= oModelSWY:GetStruct()
Local nTam          := oGrid:Length()
Local aAux 			:= oStruct:GetFields()
Local lExclui       := .F.

DEFAULT lGrava 		:= .T.

Begin Sequence
	For nX := 1 to nTam
		oGrid:GoLine(nX)

		If Empty(oGrid:GetValue("RCE_CODIGO"))
			Loop
		EndIf

		lExclui := !oGrid:GetValue("RCE_OK")

		cChave := oGrid:GetValue("RCE_FILIAL") + oGrid:GetValue("RCE_CODIGO")
		RCE->(DbSeek(cChave))

		oModel		:= FWLoadModel( "GPEA340")
		oModelRCE	:= oModel:GetModel("GPEA340_RCE")
		oModel:SetOperation(4)

		If lGrava
			oModel:bPost := {|| .T.} //Não valida a gravação
		EndIf

		oModel:Activate()

		If lExclui
			oModelRCE:LoadValue("RCE_CCT", "")
		Else
			For nY := 1 to Len(aAux)
				cCampoSWY := aAux[nY, MODEL_FIELD_IDFIELD ]
				If cCampoSWY $ "WY_FILIAL*WY_CODIGO*WY_DESC*WY_NCONVEN*WY_ESTADO*WY_DESCEST*WY_ADNHE*WY_ADNHN"
					Loop
				EndIf
				cCampoRCE := StrTran(cCampoSWY,"WY_","RCE_")
				oModelRCE:LoadValue(cCampoRCE, oModelSWY:GetValue(cCampoSWY))
			Next nY
			oModelRCE:LoadValue("RCE_CCT", oModelSWY:GetValue("WY_CODIGO"))
		EndIf

		If ( lRet := oModel:VldData() )
			If !lGrava
				Break //Efetua apenas validação do modelo
			EndIf
			oModel:CommitData()
		Else
			Break
		EndIf

		oModel:DeActivate()

	Next nX

End Sequence

Return lRet

/*/{Protheus.doc} fVldMark_Ok
Confirma desassociação do sindicato da CCT
@author Leandro Drumond
@since 28/03/2022
@Type     Function
/*/
Static Function fVldMark_Ok(oModel, nTipo, lTecXRH)
Local lGoto := .F.

Do Case 
	Case nTipo == 1
		lGoTo := M->RCE_OK
	Case nTipo == 2
		lGoTo := M->RI4_OK
	Case nTipo == 3
		lGoTo := M->REB_OK
	Case nTipo == 4
		lGoTo := M->REI_OK
	Case nTipo == 5
		lGoTo := M->RUK_OK
EndCase
	
DEFAULT lTecXRH := .F.

If !lGoTo
	If nTipo == 1 .and. !MsgYesNo(STR0018 + CRLF + CRLF + STR0019) //"Desassociar sindicato desta CCT?" ### "Esta ação não replicará os demais campos alterados para o sindicato"
		oModel:LoadValue("RCE_OK", .T.) //Se não confirmar, volta valor para true
	EndIf
	If nTipo == 2 .and. !MsgYesNo(STR0025) //"Desassociar função desta CCT?"
		oModel:LoadValue("RI4_OK", .T.) //Se não confirmar, volta valor para true
	EndIf
	If nTipo == 3 .And. !MsgYesNo(STR0033)  //"Desassociar verba desta CCT?"
		oModel:LoadValue("REB_OK", .T.) //Se não confirmar, volta valor para true
	ElseIf nTipo == 3 .And. lTecXRH .And. fVerPdTec(oModel:GetValue("REB_CODSRV"))
		oModel:LoadValue("REB_OK", .T.)
	EndIf
	If nTipo == 4 .and. !MsgYesNo(STR0039) //"Desassociar base desta CCT?"
		oModel:LoadValue("REI_OK", .T.) //Se não confirmar, volta valor para true
	EndIf
	If nTipo == 5 .and. !MsgYesNo(STR0057) //"Desassociar município desta CCT?"
		oModel:LoadValue("RUK_OK", .T.) //Se não confirmar, volta valor para true
	EndIf
EndIf

Return .T.

/*/{Protheus.doc} LoadBases
Seleciona as bases operacionais que serão associadas a CCT
@author Leandro Drumond
@since 29/04/2022
@Type     Function
/*/
Static Function LoadBases(oModel)
Local aArea 		:= GetArea()
Local aStru  		:= {}
Local aLstIndices	:= {}
Local aColumns		:= {}
Local aPesq			:= {}
Local oGrid			:= oModel:GetModel("GPEA943_REI")
Local cBases	   	:= ""
Local cIdGrid		:= ""
Local cFilREI		:= xFilial("REI", SWY->WY_FILIAL)
Local nTam          := oGrid:Length()
Local nX 			:= 0
Local nOpcX			:= 0
Local nQtd			:= 0
Local oSize
Local oTela
Local oDlgGrid
Local oPanel
Local oMark
Local oFont
Local oGroup
Local lInclui

Private cAliasTRB

For nX := 1 to nTam
	oGrid:GoLine(nX)
	If oGrid:GetValue("REI_OK")
		cBases += oGrid:GetValue("REI_FILAA0") + oGrid:GetValue("REI_CODAA0") + "#"
	EndIf
Next nX

Static cAliasREI
Static oArqREI

If oArqREI == Nil //Monta temporária com filiais disponíveis
	Aadd(aStru, {"OK"		, "C", 2						, 0})
	Aadd(aStru, {"FILIAL"	, "C", FwGetTamFilial			, 0})
	Aadd(aStru, {"CODIGO"  	, "C", 6						, 0})
	Aadd(aStru, {"NOME"  	, "C", 20						, 0})
	AAdd(aLstIndices, {"FILIAL","CODIGO"})
	AAdd(aLstIndices, {"NOME"})

	cAliasREI := cAliasTRB := GetNextAlias()

	oArqREI := RhCriaTrab(cAliasTRB, aStru, aLstIndices)

	DbSelectArea("AA0")
	DbSetOrder(1)

	AA0->(DbGoTop())

	While AA0->(!Eof())
		RecLock(cAliasTRB, .T.)
		(cAliasTRB)->FILIAL	:= AA0->AA0_FILIAL
		(cAliasTRB)->CODIGO	:= AA0->AA0_CODIGO
		(cAliasTRB)->NOME	:= AA0->AA0_DESCRI
		(cAliasTRB)->(MsUnlock())
		AA0->(DbSkip())
	EndDo
Else
	cAliasTRB := cAliasREI
EndIf

AAdd(aColumns,FWBrwColumn():New())
aColumns[Len(aColumns)]:SetData( &("{||(cAliasTRB)->FILIAL}") )
aColumns[Len(aColumns)]:SetTitle(STR0011) //"Filial"
aColumns[Len(aColumns)]:SetSize(FwGetTamFilial)
aColumns[Len(aColumns)]:SetDecimal(0)
aColumns[Len(aColumns)]:SetPicture("@!")

AAdd(aColumns,FWBrwColumn():New())
aColumns[Len(aColumns)]:SetData( &("{||(cAliasTRB)->CODIGO}") )
aColumns[Len(aColumns)]:SetTitle(STR0012) //"Código"
aColumns[Len(aColumns)]:SetSize(6)
aColumns[Len(aColumns)]:SetDecimal(0)
aColumns[Len(aColumns)]:SetPicture("@!")

AAdd(aColumns,FWBrwColumn():New())
aColumns[Len(aColumns)]:SetData( &("{||(cAliasTRB)->NOME}") )
aColumns[Len(aColumns)]:SetTitle(STR0013) //"Descrição"
aColumns[Len(aColumns)]:SetSize(20)
aColumns[Len(aColumns)]:SetDecimal(0)
aColumns[Len(aColumns)]:SetPicture("@!")

Aadd( aPesq , {	STR0012, { { "CODIGO"   , "C", 03 , 0, "CODIGO", "@!"}}, 1})
Aadd( aPesq , {	STR0013, { { "NOME   "  , "C", 20 , 0, "NOME"  , "@!"}}, 1})

oSize := FwDefSize():New(.F.)

oSize:AddObject( "CABECALHO",(oSize:aWindSize[3]*1.1),(oSize:aWindSize[3]*0.4) , .F., .F. ) // Não dimensionavel
oSize:aMargins 	:= { 0, 0, 0, 0 } 		// Espaco ao lado dos objetos 0, entre eles 3
oSize:lProp 		:= .F. 				// Proporcional
oSize:Process() 	   					// Dispara os calculos

DEFINE FONT oFont NAME "Arial" SIZE 0,-11 BOLD

DEFINE MSDIALOG oDlgGrid TITLE OemToAnsi( STR0040 ) From 0,0 TO 600,1230 OF oMainWnd PIXEL //"Selecione as bases operacionais que serão associadas"

// Cria o conteiner onde serão colocados os paineis
oTela		:= FWFormContainer():New( oDlgGrid )
cIdGrid  	:= oTela:CreateHorizontalBox( 80 )

oTela:Activate( oDlgGrid, .F. )

//Cria os paineis onde serao colocados os browses
oPanel	:= oTela:GeTPanel( cIdGrid )

@ oSize:GetDimension("CABECALHO","LININI")+1 , oSize:GetDimension("CABECALHO","COLINI")+4	GROUP oGroup TO oSize:GetDimension("CABECALHO","LINEND") * 0.090 ,oSize:GetDimension("CABECALHO","COLEND") * 0.431  OF oDlgGrid PIXEL
oGroup:oFont:=oFont
@ oSize:GetDimension("CABECALHO","LININI")+9 , oSize:GetDimension("CABECALHO","COLINI")+6 SAY "" Of oDlgGrid Pixel

oMark := FWMarkBrowse():New()

oMark:SetOwner(oPanel)
oMark:SetAlias(cAliasTRB)
oMark:SetTemporary(.T.)
oMark:SetColumns(aColumns)
oMark:SetFieldMark('OK')
oMark:SetFilterDefault( "" )
oMark:SetIgnoreARotina(.T.)
oMark:SetMenuDef('')
oMark:SetSeek( .T., aPesq )

oMark:bAllMark := { || SetMarkAll(oMark:Mark(), aMarca[4] := !aMarca[4], cAliasTRB ), oMark:Refresh(.T.)  }

oMark:Activate()

SetMarkAll(oMark:Mark(),.F.,cAliasTRB,cBases) //Desmarca todos os registros

oMark:Refresh(.T.)

ACTIVATE MSDIALOG oDlgGrid CENTERED ON INIT EnchoiceBar(oDlgGrid, {||nOpcX := 1, oDlgGrid:End() } ,{|| oDlgGrid:End() }, NIL, {})

If nOpcX == 1

	//Adiciona filiais selecionadas
	(cAliasTRB)->(dbGoTop())

	lInclui := !Empty(cBases)

	If lInclui
		For nX := 1 to nTam //Desmarca todas as bases
			oGrid:GoLine(nX)
			oGrid:LoadValue("REI_OK",.F.)
			nQtd++
		Next nX
	Else
		oGrid:GoLine(1)
		nQtd++
	EndIf

	While (cAliasTRB)->(!EOF())
		If !Empty((cAliasTRB)->OK)

			If lInclui
				If !oGrid:SeekLine({{"REI_FILAA0",(cAliasTRB)->FILIAL},{"REI_CODAA0",(cAliasTRB)->CODIGO}})
					If ++nQtd > 500
						MsgInfo(STR0038) //"Número máximo de linhas para inclusão no GRID é de 500"
						Exit
					EndIf
					oGrid:AddLine(.T.) //Se não encontrar, adiciona uma linha
				EndIf
			EndIf

			oGrid:LoadValue("REI_FILIAL"	,cFilREI)
			oGrid:LoadValue("REI_FILCCT"	,SWY->WY_FILIAL)
			oGrid:LoadValue("REI_CODCCT"	,SWY->WY_CODIGO)
			oGrid:LoadValue("REI_FILAA0"	,(cAliasTRB)->FILIAL)
			oGrid:LoadValue("REI_CODAA0"	,(cAliasTRB)->CODIGO)
			oGrid:LoadValue("REI_DESC"    	,(cAliasTRB)->NOME)
			oGrid:LoadValue("REI_OK"		,.T.)

			lInclui := .T.
		EndIf
		(cAliasTRB)->(dbSkip())
	EndDo

	oGrid:GoLine(1)
EndIf

RestArea(aArea)

Return Nil

/*/{Protheus.doc} MenuDef
Definição do MenuDef
@author Leandro Drumond
@since 21/03/2022
@Type     Function
/*/
Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina Title OemToAnsi(STR0002)  Action 'PesqBrw'           OPERATION 1 ACCESS 0 //"Pesquisar"
ADD OPTION aRotina Title OemToAnsi(STR0003)  Action 'VIEWDEF.GPEA943'   OPERATION 2 ACCESS 0 //"Visualizar"
ADD OPTION aRotina Title OemToAnsi(STR0004)  Action 'VIEWDEF.GPEA943'   OPERATION 3 ACCESS 0 //"Incluir"
ADD OPTION aRotina Title OemToAnsi(STR0005)  Action 'VIEWDEF.GPEA943'   OPERATION 4 ACCESS 0 //"Alterar"
ADD OPTION aRotina Title OemToAnsi(STR0006)  Action 'VIEWDEF.GPEA943'   OPERATION 5 ACCESS 0 //"Excluir"
ADD OPTION aRotina Title OemToAnsi(STR0054)  Action 'VIEWDEF.GPEA943'   OPERATION 9 ACCESS 0 //"Copiar"

Return aRotina

/*/{Protheus.doc} LoadHE
Seleciona Os tipos de Hora Extra para facilitar o cadastro na CCT
@author Cícero Alves
@since 22/07/2022
@Type Static Function
/*/
Static Function LoadHE(oModel)

	Local aArea 		:= GetArea()
	Local aStru  		:= {}
	Local aLstIndices	:= {}
	Local aColumns		:= {}
	Local aPesq			:= {}
	Local oGrid			:= oModel:GetModel("GPEA943_SP4")
	Local cTiposHE   	:= ""
	Local cIdGrid		:= ""
	Local cFilSP4		:= xFilial("SP4", SWY->WY_FILIAL)
	Local nTam          := oGrid:Length()
	Local nX 			:= 0
	Local nOpcX			:= 0
	Local nQtd			:= 0
	Local oSize
	Local oTela
	Local oDlgGrid
	Local oPanel
	Local oMark
	Local oFont
	Local oGroup
	Local lInclui

	Private cAliasTRB

	For nX := 1 to nTam
		oGrid:GoLine(nX)
		If oGrid:GetValue("P4_OK")
			cTiposHE += oGrid:GetValue("P4_FILIAL") + oGrid:GetValue("P4_TURNO") + oGrid:GetValue("P4_TIPO") + StrZero(oGrid:GetValue("P4_DE") * 100, 5) + "#"
		EndIf
	Next nX

	Static cAliasSP4
	Static oArqSP4

	If oArqSP4 == Nil // Monta tabela temporária

		Aadd(aStru, {"OK"		, "C", 2				, 0})
		Aadd(aStru, {"FILIAL"	, "C", FwGetTamFilial	, 0})
		Aadd(aStru, {"TURNO"  	, "C", 3				, 0})
		Aadd(aStru, {"TIPO"  	, "C", 1				, 0})
		Aadd(aStru, {"CODIGO"  	, "C", 9				, 0})
		Aadd(aStru, {"DE"  		, "N", 6				, 2})
		Aadd(aStru, {"ATE"  	, "N", 6				, 2})
		Aadd(aStru, {"PERC"  	, "N", 6				, 2})
		Aadd(aStru, {"CODNAUT"  , "C", 3				, 0})
		Aadd(aStru, {"CODAUT"  	, "C", 3				, 0})
		AAdd(aLstIndices, {"FILIAL", "TURNO", "TIPO"})
		AAdd(aLstIndices, {"FILIAL", "TIPO"})
		AAdd(aLstIndices, {"TIPO"})

		cAliasSP4 := cAliasTRB := GetNextAlias()

		oArqSP4 := RhCriaTrab(cAliasTRB, aStru, aLstIndices)

		DbSelectArea("SP4")
		DbSetOrder(1)
		SP4->(dbGoTop())

		While SP4->(!Eof())
			If Empty(SP4->P4_CODCCT)
				RecLock(cAliasTRB, .T.)
				(cAliasTRB)->FILIAL	:= SP4->P4_FILIAL
				(cAliasTRB)->TURNO	:= SP4->P4_TURNO
				(cAliasTRB)->TIPO	:= SP4->P4_TIPO
				(cAliasTRB)->CODIGO	:= SP4->(P4_TURNO + P4_TIPO + StrZero( P4_DE * 100, 5))
				(cAliasTRB)->DE		:= SP4->P4_DE
				(cAliasTRB)->ATE	:= SP4->P4_ATE
				(cAliasTRB)->PERC	:= SP4->P4_PERCENT
				(cAliasTRB)->CODNAUT:= SP4->P4_CODNAUT
				(cAliasTRB)->CODAUT	:= SP4->P4_CODAUT
				(cAliasTRB)->(MsUnlock())
			EndIf
			SP4->(DbSkip())
		EndDo
	Else
		cAliasTRB := cAliasSP4
	EndIf

	AAdd(aColumns, FWBrwColumn():New())
	aColumns[Len(aColumns)]:SetTitle(STR0011) //"Filial"
	aColumns[Len(aColumns)]:SetData( &("{||(cAliasTRB)->FILIAL}") )
	aColumns[Len(aColumns)]:SetSize(FwGetTamFilial)
	aColumns[Len(aColumns)]:SetDecimal(0)
	aColumns[Len(aColumns)]:SetPicture("@!")

	AAdd(aColumns, FWBrwColumn():New())
	aColumns[Len(aColumns)]:SetTitle(STR0045) // "Tipo"
	aColumns[Len(aColumns)]:SetData( &("{||(cAliasTRB)->TIPO}") )
	aColumns[Len(aColumns)]:SetSize(1)
	aColumns[Len(aColumns)]:SetDecimal(0)
	aColumns[Len(aColumns)]:SetPicture("@!")
	aColumns[Len(aColumns)]:SetOptions(StrToKArr(PonRetOpcBox(4), ";"))

	AAdd(aColumns, FWBrwColumn():New())
	aColumns[Len(aColumns)]:SetTitle(STR0046) // "Horas De"
	aColumns[Len(aColumns)]:SetData( &("{||(cAliasTRB)->DE}") )
	aColumns[Len(aColumns)]:SetSize(1)
	aColumns[Len(aColumns)]:SetDecimal(0)
	aColumns[Len(aColumns)]:SetPicture("@E 999.99")

	AAdd(aColumns, FWBrwColumn():New())
	aColumns[Len(aColumns)]:SetTitle(STR0047) // "Horas Até"
	aColumns[Len(aColumns)]:SetData( &("{||(cAliasTRB)->ATE}") )
	aColumns[Len(aColumns)]:SetSize(1)
	aColumns[Len(aColumns)]:SetDecimal(0)
	aColumns[Len(aColumns)]:SetPicture("@E 999.99")

	AAdd(aColumns, FWBrwColumn():New())
	aColumns[Len(aColumns)]:SetTitle(STR0048) // "% Adicional"
	aColumns[Len(aColumns)]:SetData( &("{||(cAliasTRB)->PERC}") )
	aColumns[Len(aColumns)]:SetSize(1)
	aColumns[Len(aColumns)]:SetDecimal(0)
	aColumns[Len(aColumns)]:SetPicture("@E 999.99")

	AAdd(aColumns, FWBrwColumn():New())
	aColumns[Len(aColumns)]:SetTitle(STR0049) // "Evento não atorizado"
	aColumns[Len(aColumns)]:SetData( &("{||(cAliasTRB)->CODNAUT}") )
	aColumns[Len(aColumns)]:SetSize(1)
	aColumns[Len(aColumns)]:SetDecimal(0)
	aColumns[Len(aColumns)]:SetPicture("")

	AAdd(aColumns, FWBrwColumn():New())
	aColumns[Len(aColumns)]:SetTitle(STR0050) // "Evento atorizado"
	aColumns[Len(aColumns)]:SetData( &("{||(cAliasTRB)->CODAUT}") )
	aColumns[Len(aColumns)]:SetSize(1)
	aColumns[Len(aColumns)]:SetDecimal(0)
	aColumns[Len(aColumns)]:SetPicture("")

	Aadd( aPesq , {	STR0045, { { "TIPO", "C", 1, 0, "TIPO", "@!"}}, 1})

	oSize := FwDefSize():New(.F.)

	oSize:AddObject( "CABECALHO", (oSize:aWindSize[3]*1.1), (oSize:aWindSize[3]*0.4) , .F., .F. ) // Não dimensionavel
	oSize:aMargins 	:= { 0, 0, 0, 0 } 		// Espaco ao lado dos objetos 0, entre eles 3
	oSize:lProp 		:= .F. 				// Proporcional
	oSize:Process() 	   					// Dispara os calculos

	DEFINE FONT oFont NAME "Arial" SIZE 0,-11 BOLD

	DEFINE MSDIALOG oDlgGrid TITLE OemToAnsi( STR0051 ) From 0,0 TO 600,1230 OF oMainWnd PIXEL // "Selecione os tipos de Hora Extra"

	// Cria o conteiner onde serão colocados os paineis
	oTela		:= FWFormContainer():New( oDlgGrid )
	cIdGrid  	:= oTela:CreateHorizontalBox( 80 )

	oTela:Activate( oDlgGrid, .F. )

	//Cria os paineis onde serao colocados os browses
	oPanel	:= oTela:GeTPanel( cIdGrid )

	@ oSize:GetDimension("CABECALHO","LININI")+1 , oSize:GetDimension("CABECALHO","COLINI")+4	GROUP oGroup TO oSize:GetDimension("CABECALHO","LINEND") * 0.090 ,oSize:GetDimension("CABECALHO","COLEND") * 0.431  OF oDlgGrid PIXEL
	oGroup:oFont:=oFont
	@ oSize:GetDimension("CABECALHO","LININI")+9 , oSize:GetDimension("CABECALHO","COLINI")+6 SAY "" Of oDlgGrid Pixel

	oMark := FWMarkBrowse():New()

	oMark:SetOwner(oPanel)
	oMark:SetAlias(cAliasTRB)
	oMark:SetTemporary(.T.)
	oMark:SetColumns(aColumns)
	oMark:SetFieldMark('OK')
	oMark:SetFilterDefault( "" )
	oMark:SetIgnoreARotina(.T.)
	oMark:SetMenuDef('')
	oMark:SetSeek( .T., aPesq )

	oMark:bAllMark := { || SetMarkAll(oMark:Mark(), aMarca[5] := !aMarca[5], cAliasTRB ), oMark:Refresh(.T.)}

	oMark:Activate()

	SetMarkAll(oMark:Mark(), .F., cAliasTRB, cTiposHE) // Desmarca todos os registros

	oMark:Refresh(.T.)

	ACTIVATE MSDIALOG oDlgGrid CENTERED ON INIT EnchoiceBar(oDlgGrid, {||nOpcX := 1, oDlgGrid:End() } ,{|| oDlgGrid:End() }, NIL, {})

	If nOpcX == 1

		//Adiciona os tipos de HE selecionadas
		(cAliasTRB)->(dbGoTop())

		lInclui := !Empty(cTiposHE)

		If lInclui
			For nX := 1 to nTam //Desmarca todos
				oGrid:GoLine(nX)
				oGrid:LoadValue("P4_OK", .F.)
				nQtd++
			Next nX
		Else
			oGrid:GoLine(1)
			nQtd++
		EndIf

		While (cAliasTRB)->(!EOF())

			If !Empty((cAliasTRB)->OK)

				oGrid:GoLine(1)

				If lInclui
					If !oGrid:SeekLine({{"P4_TIPO", (cAliasTRB)->TIPO}, {"P4_TURNO", (cAliasTRB)->TURNO}, {"P4_DE", (cAliasTRB)->DE}})
						oGrid:AddLine(.T.) //Se não encontrar, adiciona uma linha
					EndIf

					oGrid:LoadValue("P4_FILIAL", 	cFilSP4)
					oGrid:LoadValue("P4_TURNO",		(cAliasTRB)->TURNO)
					oGrid:LoadValue("P4_TIPO", 		(cAliasTRB)->TIPO)
					oGrid:LoadValue("P4_DE", 		(cAliasTRB)->DE)
					oGrid:LoadValue("P4_ATE", 		(cAliasTRB)->ATE)
					oGrid:LoadValue("P4_PERCENT",	(cAliasTRB)->PERC)
					oGrid:LoadValue("P4_CODNAUT", 	(cAliasTRB)->CODNAUT)
					oGrid:LoadValue("P4_CODAUT", 	(cAliasTRB)->CODAUT)
					oGrid:LoadValue("P4_FILCCT", 	SWY->WY_FILIAL)
					oGrid:LoadValue("P4_CODCCT", 	SWY->WY_CODIGO)

				EndIf

				oGrid:LoadValue("P4_OK", 		.T.)

				lInclui := .T.
			EndIf
			(cAliasTRB)->(dbSkip())
		EndDo
	EndIf

	oGrid:GoLine(1)

	RestArea(aArea)

Return Nil

/*/{Protheus.doc} GPEDelOk
Altera o campo P4_OK quando a linha é deletada
@type  Static Function
@author Cícero Alves
@since 26/07/2022
@param oGrid, Objeto, Submodelo da rotina, instância da classe FWFormGridModel
@param nLine, Numérico, Número da linha posicionada
@param cAction, Caractere, Ação que foi executada
@return lRet, Lógico, Indica se a ação é válida
/*/
Static Function GPEDelOk(oGrid, nLine, cAction)

	Local lRet := .T.

	If cAction == 'DELETE'
		oGrid:LoadValue("P4_OK", .F.)
	ElseIf cAction == 'UNDELETE'
		oGrid:LoadValue("P4_OK", .F.)
	EndIf

Return lRet

/*/{Protheus.doc} fSP4Ok
Validações do cadastro dos tipos de hora extra
@type  Static Function
@author Cícero Alves
@since 26/07/2022
@param oGrid, Objeto, Submodelo da rotina, instância da classe FWFormGridModel
@param nLine, Numérico, Número da linha posicionada
@return lRet, Lógico, Indica se as informações da linha são válidas
/*/
Static Function fSP4Ok(oGrid, nLine)

	Local lRet		:= .T.
	Local nI		:= 0
	Local cTipoHE	:= ""
	Local cPerHE	:= ""
	Local nTolHE	:= 0

	lCpoPer := If(lCpoPer != NIL, lCpoPer, SP4->(ColumnPos("P4_PERHEXT") > 0))

	oGrid:GoLine(nLine)

	// Valida as horas de/até
	If oGrid:GetValue("P4_ATE") <= oGrid:GetValue("P4_DE")
		lRet := .F.
		// "O campo Horas Até não pode ser menor que o campo Horas De" -- "Informe um valor válido para o campo horas até."
		Help(NIL, NIL, "Help", NIL, STR0052, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0053})
	EndIf

	If lCpoPer .And. lRet

		cTipoHE := oGrid:GetValue("P4_TIPO")
		cPerHE := oGrid:GetValue("P4_PERHEXT")
		nTolHE := oGrid:GetValue("P4_TOLHEPE")

		For nI := 1 To oGrid:Length()
			oGrid:GoLine(nI)
			If nI != nLine .And. !oGrid:IsDeleted()
				If oGrid:GetValue("P4_TIPO") == cTipoHE .And. (!oGrid:GetValue("P4_PERHEXT") == cPerHE .Or. !oGrid:GetValue("P4_TOLHEPE") == nTolHE)
					lRet := .F.
					//"Horas Extras do mesmo Tipo devem ter o mesmo Período de Apuração e a mesma Tolerância"
					Help(NIL, NIL, "Help", NIL, STR0055, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0056}) // "Ajuste o período de apuração e a tolerância das horas extras."
					EXIT
				EndIf
			EndIf
		Next nI
	EndIf

Return lRet

/*/{Protheus.doc} Gp943Est
Gatilha descrição do estado
@author Leandro Drumond
@since 22/11/2022
@Type Static Function
/*/
Function Gp943Est()
Local cUF 		:= &(ReadVar())
Local oModel    := FWModelActive()

oModel:LoadValue("GPEA943_SWY","WY_DESCEST",Left(fDesc("SX5","12"+cUF,"X5DESCRI()"),20))

Return .T.

/*/{Protheus.doc} fVldSP9AdN
Validação dos campos WY_ADNHN e WY_ADNHE
@type  Function
@author Cícero Alves
@since 16/02/2024
@version version
@return lRet, logical, Verdadeiro se o evento informado no campo estiver classificado como adicional noturno e não tiver um ID de ponto vinculado
/*/
Function fVldSP9AdN()
	Local lRet		:= .T.
	Local cEvtPon	:= &(ReadVar())
	
	If !Empty(cEvtPon) .And. (!Empty(Posicione("SP9", 1, xFilial("SP9") + cEvtPon, "P9_IDPON")) .Or. !SP9->P9_CLASEV == "06")
		lRet := .F.
		//"Evento do Ponto Inválido" - "O evento do Ponto informado não é válido para a geração do adicional noturno."
		//"O evento deve estar classificado como 06 = Adicional Noturno e não deve ter Identificador de Ponto."
		Help(,, STR0068, NIL, STR0069, 1, 0,,,,,, {STR0070})
	EndIf
	
Return lRet

/*/{Protheus.doc} LoadMun
Seleciona os municípios que serão associadas a CCT
@author Bruno Costa
@since 23/02/2024
@Type Function
/*/
Static Function LoadMun(oModel)
Local aArea 		:= GetArea()
Local aStru  		:= {}
Local aLstIndices	:= {}
Local aColumns		:= {}
Local aPesq			:= {}
Local oGrid			:= oModel:GetModel("GPEA943_RUK")
Local cMuni		   	:= ""
Local cIdGrid		:= ""
Local cEstWY		:= oModel:GetValue("GPEA943_SWY", "WY_ESTADO")
Local cFilRUK		:= xFilial("RUK", SWY->WY_FILIAL)
Local nTam          := oGrid:Length()
Local nX 			:= 0
Local nOpcX			:= 0
Local nQtd			:= 0
Local oSize
Local oTela
Local oDlgGrid
Local oPanel
Local oMark
Local oFont
Local oGroup
Local lInclui

Private cAliasTRB

If Empty(cEstWY)
	Help(,, OemToAnsi(STR0015),, + CRLF + OemToAnsi(STR0064), 1, 0,,,,,, { + CRLF + OemToAnsi(STR0065)}) //"Atencao" ## "Campo Estado está vazio." ### "Para vincular o munícipio é necessário informar o estado."
	Return
EndIf

For nX := 1 to nTam
	oGrid:GoLine(nX)
	If oGrid:GetValue("RUK_OK")
		cMuni += oGrid:GetValue("RUK_FILCCT") + oGrid:GetValue("RUK_CODMUN") + "#"
	EndIf
Next nX

Static cAliasRUK
Static oArqRUK
Static cEst			

If oArqRUK == Nil .Or. cEstWY != cEst //Monta temporária 
	Aadd(aStru, {"OK"		 , "C", 2				, 0})
	Aadd(aStru, {"FILIAL"	 , "C", FwGetTamFilial	, 0})
	Aadd(aStru, {"ESTADO"	 , "C", 2				, 0})
	Aadd(aStru, {"CODIGO"  	 , "C", 5				, 0})
	Aadd(aStru, {"MUNICIPIO" , "C", 60				, 0})
	AAdd(aLstIndices, {"CODIGO"})
	AAdd(aLstIndices, {"MUNICIPIO"})

	cEst      := cEstWY
	cAliasRUK := cAliasTRB := GetNextAlias()

	oArqRUK := RhCriaTrab(cAliasTRB, aStru, aLstIndices)

	DbSelectArea("CC2")
	DbSetOrder(1)

	dbSeek((cAliasTRB)->FILIAL+cEstWY)

	While CC2->(!Eof()) .And. CC2->CC2_EST == cEstWY
		RecLock(cAliasTRB, .T.)
		(cAliasTRB)->FILIAL	:= CC2->CC2_FILIAL
		(cAliasTRB)->ESTADO	:= CC2->CC2_EST
		(cAliasTRB)->CODIGO	:= CC2->CC2_CODMUN
		(cAliasTRB)->MUNICIPIO	:= CC2->CC2_MUN
		(cAliasTRB)->(MsUnlock())
		CC2->(DbSkip())
	EndDo
Else
	cAliasTRB := cAliasRUK
EndIf

AAdd(aColumns,FWBrwColumn():New())
aColumns[Len(aColumns)]:SetData( &("{||(cAliasTRB)->ESTADO}") )
aColumns[Len(aColumns)]:SetTitle(STR0062) //"Estado"
aColumns[Len(aColumns)]:SetSize(2)
aColumns[Len(aColumns)]:SetDecimal(0)
aColumns[Len(aColumns)]:SetPicture("@!")

AAdd(aColumns,FWBrwColumn():New())
aColumns[Len(aColumns)]:SetData( &("{||(cAliasTRB)->CODIGO}") )
aColumns[Len(aColumns)]:SetTitle(STR0012) //"Código"
aColumns[Len(aColumns)]:SetSize(5)
aColumns[Len(aColumns)]:SetDecimal(0)
aColumns[Len(aColumns)]:SetPicture("@!")

AAdd(aColumns,FWBrwColumn():New())
aColumns[Len(aColumns)]:SetData( &("{||(cAliasTRB)->MUNICIPIO}") )
aColumns[Len(aColumns)]:SetTitle(STR0058) //"Município"
aColumns[Len(aColumns)]:SetSize(60)
aColumns[Len(aColumns)]:SetDecimal(0)
aColumns[Len(aColumns)]:SetPicture("@!")

Aadd( aPesq , {	STR0012, { { "CODIGO"   , "C", 05 , 0, "CODIGO", "@!"}}, 1})
Aadd( aPesq , {	STR0058, { { "MUNICIPIO   "  , "C", 60 , 0, "MUNICIPIO"  , "@!"}}, 1})

oSize := FwDefSize():New(.F.)

oSize:AddObject( "CABECALHO",(oSize:aWindSize[3]*1.1),(oSize:aWindSize[3]*0.4) , .F., .F. ) // Não dimensionavel
oSize:aMargins 	:= { 0, 0, 0, 0 } 		// Espaco ao lado dos objetos 0, entre eles 3
oSize:lProp 		:= .F. 				// Proporcional
oSize:Process() 	   					// Dispara os calculos

DEFINE FONT oFont NAME "Arial" SIZE 0,-11 BOLD

DEFINE MSDIALOG oDlgGrid TITLE OemToAnsi( STR0061 ) From 0,0 TO 600,1230 OF oMainWnd PIXEL //"Selecione os municípios que serão associados"

// Cria o conteiner onde serão colocados os paineis
oTela		:= FWFormContainer():New( oDlgGrid )
cIdGrid  	:= oTela:CreateHorizontalBox( 80 )

oTela:Activate( oDlgGrid, .F. )

//Cria os paineis onde serao colocados os browses
oPanel	:= oTela:GeTPanel( cIdGrid )

@ oSize:GetDimension("CABECALHO","LININI")+1 , oSize:GetDimension("CABECALHO","COLINI")+4	GROUP oGroup TO oSize:GetDimension("CABECALHO","LINEND") * 0.090 ,oSize:GetDimension("CABECALHO","COLEND") * 0.431  OF oDlgGrid PIXEL
oGroup:oFont:=oFont
@ oSize:GetDimension("CABECALHO","LININI")+9 , oSize:GetDimension("CABECALHO","COLINI")+6 SAY "" Of oDlgGrid Pixel

oMark := FWMarkBrowse():New()

oMark:SetOwner(oPanel)
oMark:SetAlias(cAliasTRB)
oMark:SetTemporary(.T.)
oMark:SetColumns(aColumns)
oMark:SetFieldMark('OK')
oMark:SetFilterDefault( "" )
oMark:SetIgnoreARotina(.T.)
oMark:SetMenuDef('')
oMark:SetSeek( .T., aPesq )

oMark:bAllMark := { || SetMarkAll(oMark:Mark(), aMarca[6] := !aMarca[6], cAliasTRB ), oMark:Refresh(.T.)  }

oMark:Activate()

SetMarkAll(oMark:Mark(),.F.,cAliasTRB,cMuni) //Desmarca todos os registros

oMark:Refresh(.T.)

ACTIVATE MSDIALOG oDlgGrid CENTERED ON INIT EnchoiceBar(oDlgGrid, {||nOpcX := 1, oDlgGrid:End() } ,{|| oDlgGrid:End() }, NIL, {})

If nOpcX == 1

	//Adiciona filiais selecionadas
	(cAliasTRB)->(dbGoTop())

	lInclui := !Empty(cMuni)

	If lInclui
		For nX := 1 to nTam //Desmarca todas as funções
			oGrid:GoLine(nX)
			oGrid:LoadValue("RUK_OK",.F.)
			nQtd++
		Next nX
	Else
		oGrid:GoLine(1)
		nQtd++
	EndIf

	While (cAliasTRB)->(!EOF())
		If !Empty((cAliasTRB)->OK)

			If lInclui
				If !oGrid:SeekLine({{"RUK_FILCCT",(cAliasTRB)->FILIAL}, {"RUK_ESTADO",(cAliasTRB)->ESTADO}, {"RUK_CODMUN",(cAliasTRB)->CODIGO}})
					If ++nQtd > 1000
						MsgInfo(STR0038) //"Número máximo de linhas para inclusão no GRID é de 500"
						Exit
					EndIf
					oGrid:AddLine(.T.) //Se não encontrar, adiciona uma linha
				EndIf
			EndIf

			oGrid:LoadValue("RUK_FILIAL", cFilRUK)
			oGrid:LoadValue("RUK_FILCCT", (cAliasTRB)->FILIAL)
			oGrid:LoadValue("RUK_CODCCT", SWY->WY_CODIGO)
			oGrid:LoadValue("RUK_ESTADO", (cAliasTRB)->ESTADO)
			oGrid:LoadValue("RUK_CODMUN", (cAliasTRB)->CODIGO)
			oGrid:LoadValue("RUK_DESC"  , (cAliasTRB)->MUNICIPIO)
			oGrid:LoadValue("RUK_OK"	, .T.)

			lInclui := .T.
		EndIf
		(cAliasTRB)->(dbSkip())
	EndDo

	oGrid:GoLine(1)
EndIf

RestArea(aArea)

Return Nil

/*/{Protheus.doc} GP943VLDRUK
Validação do município na alteração do Estado da CCT
@author Bruno Costa
@since 23/02/2024
@Type Function
/*/
Function GP943VLDRUK()
Local cUF 	   := &(ReadVar())
Local nX	   := 0
Local lTecXRH  := SuperGetMV("MV_TECXRH",,.F.)
Local lRet     := .T.
Local oModel   := FWModelActive()
Local oGrid

DEFAULT lTemRUK := AliasInDic("RUK")

If lTecXRH .And. lTemRUK
	oGrid := oModel:GetModel("GPEA943_RUK")
	For nX := 1 to oGrid:Length()
		oGrid:GoLine(nX)
		If oGrid:GetValue("RUK_OK") .And. cUF != oGrid:GetValue("RUK_ESTADO") 
			lRet := .F.
			Help(,, OemToAnsi(STR0015),, + CRLF + OemToAnsi(STR0066) + " " + oGrid:GetValue("RUK_ESTADO"), 1, 0,,,,,, { + CRLF + OemToAnsi(STR0067)}) //"Atencao" ## "Existem municípios vinculados ao estado XX" ### "Necessário desassociar os municípios."
			Exit
		EndIf
	Next nX	
EndIf

Return lRet

/*/{Protheus.doc} SetMarkDel
Marcar deletado na tabela temporária
@author Bruno Costa
@since 30/07/2024
@Type Function
/*/
Static Function SetMarkDel(cAliasMark,cFil, cCod)

dbSelectArea(cAliasMark)
(cAliasMark)->( dbGoTop() )

IF (cAliasMark)->( Dbseek(cFil+cCod) )
	RecLock( (cAliasMark), .F. )

	(cAliasMark)->OK := '  '

	MsUnLock()
EndIf

Return Nil

/*/{Protheus.doc} fVerPdTec
Verifica se existe o vínculo da verba na tabela TCX - SIGATEC
@author Bruno Costa
@since 04/11/2024
@Type Function
/*/
Function fVerPdTec(cPd)
Local aArea  := GetArea()
Local cAlias := GetNextAlias()
Local cQuery := ""
Local lRet 	 := .F.
Local oStatement := Nil

cQuery := "SELECT TCX_CODTBL FROM " + RetSqlName("TCW") + " TCW "
cQuery += "INNER JOIN " + RetSqlName("SWY") + " SWY ON " + FWJoinFilial("SWY", "TCW") + " AND SWY.WY_CODIGO = TCW.TCW_CODCCT AND SWY.D_E_L_E_T_ = ? "
cQuery += "INNER JOIN " + RetSqlName("TCX") + " TCX ON " + "TCX.TCX_FILIAL = TCW.TCW_FILIAL  AND TCX.TCX_CODTCW = TCW.TCW_CODIGO AND TCX.D_E_L_E_T_ = ? "
cQuery += "WHERE SWY.WY_FILIAL = ? AND TCW.TCW_CODCCT = ? AND TCX.TCX_TABELA = ? AND TCX.TCX_CODTBL = ? AND TCW.D_E_L_E_T_ = ? "
cQuery := ChangeQuery(cQuery) 
oStatement := FwExecStatement():New(cQuery)

oStatement:SetString(1, " ")
oStatement:SetString(2, " ")
oStatement:SetString(3, FwFldGet("WY_FILIAL"))
oStatement:SetString(4, FwFldGet("WY_CODIGO"))
oStatement:SetString(5, "1")
oStatement:SetString(6, cPd)
oStatement:SetString(7, " ")

cAlias := oStatement:OpenAlias()

If (lRet := !(cAlias)->(Eof()))
	//"Atenção" ## "Verba XXX está associada na rotina Configurações de Cálculo(TECA996A). " ### "Necessário desassociar a verba da rotina TECA996A do módulo SIGATEC."
	Help(,, OemToAnsi(STR0015),, + CRLF + OemToAnsi(STR0072) + " " + cPd + " " + OemToAnsi(STR0073), 1, 0,,,,,, { + CRLF + OemToAnsi(STR0074)}) 
EndIf

(cAlias)->(DbCloseArea())

RestArea(aArea)

Return lRet

/*/{Protheus.doc} Gp943DescCpo
Retorna a descrição dos campos no histórico de alterações
@author Leandro Drumond
@since 12/02/2025
@Type Function
/*/
Static Function Gp943DescCpo()
Local cRet := FwX3Titulo(SYY->YY_CAMPO)

Return cRet
