#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FISA313.CH"
#Include "Dbstruct.ch"

Static cPart    := ""
Static lPart    := Nil
Static nTamCod
Static nTamCJR
Static o1601Fil := Nil
Static lAutomato:= .F.

//-------------------------------------------------------------------
/*/{Protheus.doc} FISA313
Rotina que irá fazer o cadastro das informações para o registro 1601 do SPED FISCAL, com opção de importação de infos do financeiro.
@author Matheus Massarotto_
@since 17/04/2023
@version 12.1.2210

/*/
//-------------------------------------------------------------------
Function FISA313(cAlias,nReg,nOpc)
	local nOperation := MODEL_OPERATION_UPDATE

	if nOpc == 1
		nOperation := MODEL_OPERATION_VIEW
	elseif nOpc == 2
		nOperation := MODEL_OPERATION_INSERT
	elseif nOpc == 4
		nOperation := MODEL_OPERATION_DELETE
	endif

	FWExecView('Filial: ' + FWGETCODFILIAL + ' - ' +SM0->M0_FILIAL,'FISA313', nOperation,,, { || .T. } )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@return aRotina - Array com as opcoes de menu

@author Matheus Massarotto
@since 17/04/2023
@version 12.1.2210
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return FWMVCMenu( 'FISA313' )


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Matheus Massarotto
@since 17/04/2023
@version 12.1.2210
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
	Local oStruGener := Nil
	Local oStruItem  := Nil
	Local oModel
	Local cAlias     := "CJQ"

	oStruGener := FWFormStruct( 1,cAlias)

//Estrutura do grid
	oStruItem := FWFormStruct(1,"CJR")

	oModel	:=	MPFormModel():New('FISA313MOD',,{ |oModel| ValidForm(oModel) })

	AddCampos(@oStruGener,1)

	oModel:AddFields( 'FISA313MOD' ,, oStruGener )

//Adicionando o grid  com o detalhamento dos pagtos
	oModel:AddGrid( 'FISA313ITEM', 'FISA313MOD', oStruItem)
	oModel:SetRelation( 'FISA313ITEM', { { 'CJR_FILIAL', 'xFilial( "CJR" )' }, { 'CJR_MANAUT', 'CJQ_MANAUT' }  },CJR->( IndexKey( 1 ) )  )
	oModel:SetPrimaryKey( { "CJR_MANAUT","CJR_ITEM" } )
	oModel:SetOptional("FISA313ITEM", .T.)
	oModel:GetModel("FISA313ITEM"):SetMaxLine(999999)

	if cAlias == 'CJQ'
		oStruGener:SetProperty( 'CJQ_PERIOD' , MODEL_FIELD_WHEN  , { || (oModel:GetOperation()==3) })
		oStruGener:SetProperty( 'CJQ_TPPAR'  , MODEL_FIELD_WHEN  , { || (oModel:GetOperation()==3) })

		oStruGener:SetProperty( 'CJQ_CLIFOR' , MODEL_FIELD_WHEN  , { || oModel:GetOperation()==3 .and. A312CanEd("CJQ_CLIFOR",'FISA313MOD','VIEW_GEN') } )
		oStruGener:SetProperty( 'CJQ_LOJA'   , MODEL_FIELD_WHEN  , { || oModel:GetOperation()==3 .and. A312CanEd("CJQ_LOJA",'FISA313MOD','VIEW_GEN') } )

		oStruGener:SetProperty( 'CJQ_BANCO' , MODEL_FIELD_WHEN  , { || oModel:GetOperation()==3 .and. A312CanEd("CJQ_BANCO",'FISA313MOD','VIEW_GEN') } )
		oStruGener:SetProperty( 'CJQ_AGENC' , MODEL_FIELD_WHEN  , { || oModel:GetOperation()==3 .and. A312CanEd("CJQ_AGENC",'FISA313MOD','VIEW_GEN') } )
		oStruGener:SetProperty( 'CJQ_NUMCON', MODEL_FIELD_WHEN  , { || oModel:GetOperation()==3 .and. A312CanEd("CJQ_NUMCON",'FISA313MOD','VIEW_GEN') } )

		oStruGener:SetProperty('CJQ_CLIFOR', MODEL_FIELD_VALID , {|| ValidCpo('FISA313MOD','CJQ_CLIFOR') })
		oStruGener:SetProperty('CJQ_LOJA'  , MODEL_FIELD_VALID , {|| ValidCpo('FISA313MOD','CJQ_LOJA'  ) })
		oStruGener:SetProperty('CJQ_BANCO' , MODEL_FIELD_VALID , {|| ValidCpo('FISA313MOD','CJQ_BANCO' ) })
		oStruGener:SetProperty('CJQ_AGENC' , MODEL_FIELD_VALID , {|| ValidCpo('FISA313MOD','CJQ_AGENC' ) })
		oStruGener:SetProperty('CJQ_NUMCON', MODEL_FIELD_VALID , {|| ValidCpo('FISA313MOD','CJQ_NUMCON') })

		oStruGener:SetProperty('CJQ_PERIOD'  , MODEL_FIELD_VALID , {|| ValidRegex('FISA313MOD','CJQ_PERIOD'  ) })
	endif


Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Matheus Massarotto
@since 17/04/2023
@version 12.1.2210
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
	Local	oModel 		:= 	FWLoadModel('FISA313')
	Local	oStruGener 	:= 	Nil
	Local	oView 		:= 	FWFormView():New()
	Local cAlias        := "CJQ"

	oView:SetModel(oModel)
	oStruGener	:= 	FWFormStruct(2,cAlias)
	oStruItem	:= 	FWFormStruct(2,"CJR")

	AddCampos(@oStruGener,2)

	oStruGener:AddGroup( 'GRUPO01', OemToAnsi(STR0017), '', 2 )//"Definição do período"
	oStruGener:AddGroup( 'GRUPO02', OemToAnsi(STR0018), '', 2 )//"Definição do participante"
	oStruGener:AddGroup( 'GRUPO03', OemToAnsi(STR0019), '', 2 )//"Definições de valores"


	if F312USADO("CJQ_PERIOD")
		oStruGener:SetProperty( 'CJQ_PERIOD'    ,   MVC_VIEW_GROUP_NUMBER, 'GRUPO01' )
	endif
	if F312USADO("CJQ_TPPAR")
		oStruGener:SetProperty( 'CJQ_TPPAR'     ,   MVC_VIEW_GROUP_NUMBER, 'GRUPO02' )
	endif
	if F312USADO("CJQ_CLIFOR")
		oStruGener:SetProperty( 'CJQ_CLIFOR'    ,   MVC_VIEW_GROUP_NUMBER, 'GRUPO02' )
	endif
	if F312USADO("CJQ_LOJA")
		oStruGener:SetProperty( 'CJQ_LOJA'      ,   MVC_VIEW_GROUP_NUMBER, 'GRUPO02' )
	endif
	if F312USADO("CJQ_BANCO")
		oStruGener:SetProperty( 'CJQ_BANCO'     ,   MVC_VIEW_GROUP_NUMBER, 'GRUPO02' )
	endif
	if F312USADO("CJQ_AGENC")
		oStruGener:SetProperty( 'CJQ_AGENC'     ,   MVC_VIEW_GROUP_NUMBER, 'GRUPO02' )
	endif
	if F312USADO("CJQ_NUMCON")
		oStruGener:SetProperty( 'CJQ_NUMCON'    ,   MVC_VIEW_GROUP_NUMBER, 'GRUPO02' )
	endif
	if F312USADO("CJQ_INTERM")
		oStruGener:SetProperty( 'CJQ_INTERM'    ,   MVC_VIEW_GROUP_NUMBER, 'GRUPO02' )
	endif
	if F312USADO("CJQ_DESPAR")
		oStruGener:SetProperty( 'CJQ_DESPAR'    ,   MVC_VIEW_GROUP_NUMBER, 'GRUPO02' )
	endif
	if F312USADO("CJQ_DESINT")
		oStruGener:SetProperty( 'CJQ_DESINT'    ,   MVC_VIEW_GROUP_NUMBER, 'GRUPO02' )
	endif
	if F312USADO("CJQ_TOTVS")
		oStruGener:SetProperty( 'CJQ_TOTVS'     ,   MVC_VIEW_GROUP_NUMBER, 'GRUPO03' )
	endif
	if F312USADO("CJQ_TOTISS")
		oStruGener:SetProperty( 'CJQ_TOTISS'    ,   MVC_VIEW_GROUP_NUMBER, 'GRUPO03' )
	endif
	if F312USADO("CJQ_TOTOUT")
		oStruGener:SetProperty( 'CJQ_TOTOUT'    ,   MVC_VIEW_GROUP_NUMBER, 'GRUPO03' )
	endif

	oView:AddField( 'VIEW_GEN'  , oStruGener, 'FISA313MOD' )
	oView:AddGrid(  'VIEW_ITEM' , oStruItem , 'FISA313ITEM' )

	oView:CreateHorizontalBox( 'SUPERIOR'  , 60 )
	oView:CreateHorizontalBox( 'INFERIOR'  , 40 )


	if F312USADO("CJQ_CLIFOR")
		//Consulta F3
		oStruGener:SetProperty( 'CJQ_CLIFOR' , MVC_VIEW_LOOKUP  , { || A312ChgF3("CJQ_CLIFOR",'FISA313MOD') } )
	endif
	if F312USADO("CJQ_TPPAR")
		//Indica se o campo é editável
		oView:SetFieldAction( 'CJQ_TPPAR' , { || F312TpPar('FISA313MOD','VIEW_GEN') } )
	endif
	if F312USADO("CJQ_CLIFOR")
		oView:SetFieldAction( 'CJQ_CLIFOR', { || F312CODPAR('FISA313MOD','VIEW_GEN') } )
	endif
	if F312USADO("CJQ_LOJA")
		oView:SetFieldAction( 'CJQ_LOJA'  , { || F312CODPAR('FISA313MOD','VIEW_GEN') } )
	endif
	if F312USADO("CJQ_BANCO")
		oView:SetFieldAction( 'CJQ_BANCO' , { || F312CODPAR('FISA313MOD','VIEW_GEN') } )
	endif
	if F312USADO("CJQ_AGENC")
		oView:SetFieldAction( 'CJQ_AGENC' , { || F312CODPAR('FISA313MOD','VIEW_GEN') } )
		oStruGener:SetProperty( 'CJQ_AGENC' , MVC_VIEW_CANCHANGE, .F. )
	endif
	if F312USADO("CJQ_NUMCON")
		oView:SetFieldAction( 'CJQ_NUMCON', { || F312CODPAR('FISA313MOD','VIEW_GEN') } )
		oStruGener:SetProperty( 'CJQ_NUMCON' , MVC_VIEW_CANCHANGE, .F. )
	endif

	oStruGener:RemoveField( 'CJQ_CODPAR' )
	oStruGener:RemoveField( 'CJQ_MANAUT' )
	oStruItem:RemoveField( 'CJR_MANAUT' )

	oView:SetViewProperty("VIEW_ITEM", "ONLYVIEW") //deixar somente visual o grid
	oView:SetNoDeleteLine("VIEW_ITEM") //não pode receber exclusão de linha
	oView:SetNoInsertLine("VIEW_ITEM") //não pode receber inserção de linha

	oView:SetOwnerView( 'VIEW_GEN'   , 'SUPERIOR'   )
	oView:SetOwnerView( 'VIEW_ITEM'  , 'INFERIOR'   )

	oView:EnableTitleView('VIEW_ITEM'  , STR0020)//"Detalhamento das operações importadas pelo facilitador"

Return oView
//-------------------------------------------------------------------
/*/{Protheus.doc} AddCampos
Funcao generica para adicionar campos no model e view

@author Matheus Massarotto
@since 02/05/2023
@version 12.1.2210
/*/
//-------------------------------------------------------------------
Static function AddCampos(oStruGener,nOpc)
	if nOpc==1
		oStruGener:AddField( ;                    // Ord. Tipo Desc.
		STR0021                                                     , ;      // [01]  C   Titulo do campo //"Desc Part"
		STR0022                                                     , ;      // [02]  C   ToolTip do campo //"Descrição Partici"
		"CJQ_DESPAR"                                                , ;      // [03]  C   Id do Field
		'C'                                                         , ;      // [04]  C   Tipo do campo
		FWSX3Util():GetFieldStruct("A1_NOME")[3]                    , ;      // [05]  N   Tamanho do campo
		0                                                           , ;      // [06]  N   Decimal do campo
		NIL                                                         , ;      // [07]  B   Code-block de validação do campo
		NIL                                                         , ;      // [08]  B   Code-block de validação When do campo
		NIL                                                         , ;      // [09]  A   Lista de valores permitido do campo
		NIL                                                         , ;      // [10]  L   Indica se o campo tem preenchimento obrigatório
		&( ' { | oModel |  F313IniCpo(oModel,"CJQ_DESPAR") } ' )    , ;      // [11]  B   Code-block de inicializacao do campo
		NIL                                                         , ;      // [12]  L   Indica se trata-se de um campo chave
		NIL                                                         , ;      // [13]  L   Indica se o campo pode receber valor em uma operação de update.
		.T.                                                         )        // [14]  L   Indica se o campo é virtual

		oStruGener:AddField( ;                    // Ord. Tipo Desc.
		STR0023                                                     , ;      // [01]  C   Titulo do campo //"Desc Interm"
		STR0024                                                     , ;      // [02]  C   ToolTip do campo //"Descrição Intermediário"
		"CJQ_DESINT"                                                , ;      // [03]  C   Id do Field
		'C'                                                         , ;      // [04]  C   Tipo do campo
		FWSX3Util():GetFieldStruct("A1U_NOME")[3]                   , ;      // [05]  N   Tamanho do campo
		0                                                           , ;      // [06]  N   Decimal do campo
		NIL                                                         , ;      // [07]  B   Code-block de validação do campo
		NIL                                                         , ;      // [08]  B   Code-block de validação When do campo
		NIL                                                         , ;      // [09]  A   Lista de valores permitido do campo
		NIL                                                         , ;      // [10]  L   Indica se o campo tem preenchimento obrigatório
		&( ' { | oModel |  F313IniCpo(oModel,"CJQ_DESINT") } ' )    , ;      // [11]  B   Code-block de inicializacao do campo
		NIL                                                         , ;      // [12]  L   Indica se trata-se de um campo chave
		NIL                                                         , ;      // [13]  L   Indica se o campo pode receber valor em uma operação de update.
		.T.                                                         )        // [14]  L   Indica se o campo é virtual


		oStruGener:AddTrigger( ;
			"CJQ_INTERM", ;                                                         // [01] Id do campo de origem
		"CJQ_DESINT" , ;                                                        // [02] Id do campo de destino
		{|| .T. }   , ;                                                         // [03] Bloco de codigo de validação da execução do gatilho
		&( ' { | oModel |  IIF(!empty(oModel:GetValue("CJQ_INTERM")),A1U->A1U_NOME,"") } ' ) )  // [04] Bloco de codigo de execução do gatilho

	else
		oStruGener:AddField( ;                    // Ord. Tipo Desc.
		"CJQ_DESPAR"        , ; // [01] C Nome do Campo
		"10"                , ;	// [02] C Ordem
		STR0021             , ;	// [03] C Titulo do campo  //"Desc Part"
		STR0022             , ;	// [04] C Descrição do campo //"Descrição Partici"
		{}                  , ; // [05] A Array com Help
		"C"                 , ; // [06] C Tipo do campo
		"@!"                , ; // [07] C Picture
		NIL 			    , ;	// [08] B Bloco de Picture Var
		''                  , ; // [09] C Consulta F3
		.F.	                , ; // [10] L Indica se o campo é evitável
		nil				    , ; // [11] C Pasta do campo
		NIL                 , ;	// [12] C Agrupamento do campo
		{}                  , ; // [13] A Lista de valores permitido do campo
		NIL                 , ;	// [14] N Tamanho Maximo da maior opção do combo
		NIL                 , ; // [15] C Inicializador de Browse
		.T.                 , ; // [16] L Indica se o campo é virtual
		NIL )

		oStruGener:AddField( ;                    // Ord. Tipo Desc.
		"CJQ_DESINT"        , ; // [01] C Nome do Campo
		"12"                , ;	// [02] C Ordem
		STR0023             , ;	// [03] C Titulo do campo //"Desc Interm"
		STR0024             , ;	// [04] C Descrição do campo //"Descrição Intermediário"
		{}                  , ; // [05] A Array com Help
		"C"                 , ; // [06] C Tipo do campo
		"@!"                , ; // [07] C Picture
		NIL 			    , ;	// [08] B Bloco de Picture Var
		''                  , ; // [09] C Consulta F3
		.F.	                , ; // [10] L Indica se o campo é evitável
		nil				    , ; // [11] C Pasta do campo
		NIL                 , ;	// [12] C Agrupamento do campo
		{}                  , ; // [13] A Lista de valores permitido do campo
		NIL                 , ;	// [14] N Tamanho Maximo da maior opção do combo
		NIL                 , ; // [15] C Inicializador de Browse
		.T.                 , ; // [16] L Indica se o campo é virtual
		NIL )
	endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} F312USADO
Função para verifica campo usado

@author Matheus Massarotto
@since 03/05/2023
@version 12.1.2210
/*/
//-------------------------------------------------------------------
Static function F312USADO(cCampo)
	Local cX3Usado := GetSx3Cache(cCampo,"X3_USADO")
	Local lRet     := .F.
	if X3Uso(cX3Usado)
		lRet:=.T.
	endif
Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} F313IniCpo
Função para tratamento de inicialização de campos

@author Matheus Massarotto
@since 03/05/2023
@version 12.1.2210
/*/
//-------------------------------------------------------------------
Static Function F313IniCpo(oModel,cCampo)
	Local cRet      := ""
	Local cTipoPar  := oModel:GetValue('CJQ_TPPAR')
	Local cValor    := ""
	Local aArea     := GetArea()

	if oModel:GetOperation() != 3 // Diferente de Incluir
		if cCampo == "CJQ_DESPAR"

			cValor    := oModel:GetValue('CJQ_CODPAR')
			Do Case
			Case cTipoPar == "1"
				cRet:= Posicione("SA2",1,xFilial("SA2")+cValor,"A2_NOME")
			Case cTipoPar == "2"
				cRet:= Posicione("SA1",1,xFilial("SA1")+cValor,"A1_NOME")
			Case cTipoPar == "3"
				cRet:= Posicione("SA6",1,xFilial("SA6")+cValor,"A6_NOME")
			End Case
		elseif cCampo == "CJQ_DESINT"
			cValor    := oModel:GetValue('CJQ_INTERM')
			cRet:= Posicione("A1U",1,xFilial("A1U")+cValor,"A1U_NOME")
		endif
	endif

	RestArea(aArea)
Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PERG313
Função que pergunta para usuário e processa. 

@author Matheus Massarotto
@since 17/04/2023
@version 12.1.2210
/*/
//-------------------------------------------------------------------
Function PERG313(aAutoFil)
	Local oProcess  as Object
	Local aFil      as array
	Local cPergunt   := "FISA313"
	Local lAtuFinanc := AliasInDic('F7G') .And. FindFunction("FinSpd1601") .And. F7G->(ColumnPos("F7G_FORMRC")) > 0
	Local lAtuFiscal := Ver002(cPergunt)
	
	Default aAutoFil := {{.T., cFilAnt}}

	lAutomato  := IsBlind()


	If lAtuFiscal .And. lAtuFinanc

		If nTamCod == Nil .and. nTamCJR == Nil
			nTamCod := FWSX3Util():GetFieldStruct("CJQ_CODPAR")[3]
			nTamCJR := FWSX3Util():GetFieldStruct("CJR_MANAUT")[3]			
		EndIf

		If Pergunte(cPergunt, .T.)
			aFil := GetFilial(lAutomato,aAutoFil)

			If len(aFil)>0
				If lAutomato
					PrImpSPED(@oProcess,aFil)
				Else
					oProcess := FISProgress():New({|| PrImpSPED(@oProcess,aFil)},STR0008,.T.)//'Realizando Importação'
					oProcess:Activate()
				EndIf	
			EndIf

		EndIf
	ElseIf !lAtuFiscal
		HELP(' ',1,"F1601DESATU",, STR0029 ,2, 0,,,,,, {STR0030} )	// "Módulo Fiscal desatualizado para uso dessa funcionalidade." ## "Necessário atualizar componentes do Fiscal."
	ElseIf !lAtuFinanc
		HELP(' ',1,"F1601DESATU",, STR0027 ,2, 0,,,,,, {STR0028} )	// "Módulo Financeiro desatualizado para uso dessa funcionalidade." ## "Necessário atualizar componentes do Financeiro."
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PrImpSPED
Função intermediária de processamento que chama a montagem a temporária do financeiro a montagem a query, a iserção/deleção nas tabelas auxiliares

@author Matheus Massarotto
@since 17/04/2023
@version 12.1.2210
/*/
//-------------------------------------------------------------------
Static Function PrImpSPED(oProcess,aFil)
	Local oFinR190Tb
	Local cAliascTMP:= ""
	Local oJsBank   := JsonObject():new()
	Local oSizeCpSX3:= SizeCpoSX3()
	Local nContFil  := 1
	Local cFilBackup:= FWGETCODFILIAL
	Local aAreaSM0  := SM0->(GetArea())
	Local oModel 	:= 	FWLoadModel('FISA313')
	Local oMontQry  := Nil

	If !lAutomato
		oProcess:Inc1Progress(STR0009)//'Processando registros do Financeiro : '
	Endif
	
	o1601Fil := JsonObject():New()

	DbSelectArea("SM0")

	For nContFil := 1 to Len(aFil)

		SM0->(DbGoTop ())
		SM0->(MsSeek (cEmpAnt+aFil[nContFil], .T.))	//Pego a filial mais proxima
		cFilAnt := FWGETCODFILIAL

		fCacheFil() //Cache xFilial

		If !lAutomato
			oProcess:Inc1Progress(STR0009+cFilAnt)//'Processando registros do Financeiro : '
		Endif	

		//Chama função cópia do financeiro, baseado no fonte FINR190
		oFinR190Tb := FinSpd1601(, MV_PAR01, MV_PAR02, CValToChar(MV_PAR03))

		if oFinR190Tb != Nil

			cAliascTMP := getNextAlias()

			MontQry(oFinR190Tb, oMontQry, @cAliascTMP)

			if !(cAliascTMP)->(Eof())
				//Deleto Registros caso ja existam.
				DelCJQ(cAliascTMP,@oProcess,@oJsBank,oSizeCpSX3,oModel)

				//Processo os registros para gravação na CJQ
				ProcCJQ(cAliascTMP,@oProcess,@oJsBank,oSizeCpSX3,oModel)
			else
				oProcess:Inc1Progress(STR0011+cFilAnt)//"Não há informações com os parâmetros informados."
			endif

			(cAliascTMP)->(DbCloseArea())
			oFinR190Tb:Delete()
			oFinR190Tb := Nil

		endif

	Next

	If !lAutomato
		oProcess:Inc1Progress(STR0026)//"Importação concluída"
		oProcess:Inc2Progress(STR0010)//'Concluído'
	Endif	

	FreeObj(oJsBank)
	oJsBank:=Nil
	FreeObj(oSizeCpSX3)
	oSizeCpSX3:=Nil
	FreeObj(o1601Fil)
	o1601Fil:=Nil
    FreeObj(oMontQry)
    oMontQry := Nil 

	SM0->(RestArea(aAreaSM0))
	cFilant := cFilBackup

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MontQry
Função monta a query

@author Matheus Massarotto
@since 17/04/2023
@version 12.1.2210
/*/
//-------------------------------------------------------------------
Static Function MontQry(oFinR190Tb, oMontQry, cAliascTMP)
	Local cQuery := ""
	Local cQry   := ""
	Local nPos   := 0
	Local nTamBco:= FWSX3Util():GetFieldStruct("A6_COD")[3]

	If oMontQry == Nil

		cQuery += " SELECT "
		cQuery += " CASE WHEN ISNULL(SFTISS.FT_TIPOMOV,' ')=' ' THEN SFTICMS.FT_TIPOMOV ELSE SFTISS.FT_TIPOMOV END AS FT_TIPOMOV, "
		cQuery += " CASE WHEN ISNULL(SFTISS.FT_NFISCAL,' ')=' ' THEN SFTICMS.FT_NFISCAL ELSE SFTISS.FT_NFISCAL END AS FT_NFISCAL, "
		cQuery += " CASE WHEN ISNULL(SFTISS.FT_SERIE,' ')=' ' THEN SFTICMS.FT_SERIE ELSE SFTISS.FT_SERIE END AS FT_SERIE, "
		cQuery += " FIN.FILORIG, FIN.DT_BAIXA, FIN.DT_EMISSAO, FIN.FORMA_PGTO, "
		cQuery += " CONCAT(SUBSTRING((CASE WHEN CJS.CJS_REGIME='1' THEN FIN.DT_BAIXA ELSE FIN.DT_EMISSAO END),5,2),SUBSTRING((CASE WHEN CJS.CJS_REGIME='1' THEN FIN.DT_BAIXA ELSE FIN.DT_EMISSAO END),1,4)) AS PERIODO, "
		cQuery += " FIN.CLIFOR, FIN.LOJA, "
		cQuery += " FIN.BANCO, FIN.CNPJBCO, "
		cQuery += " FIN.PREFIXO,FIN.NUMERO,FIN.TIPO,FIN.PARCELA,FIN.VALOR, "
		cQuery += " ISNULL(CASE "
		cQuery += "	WHEN ISNULL(VALISS,0)>0 AND ISNULL(VALICMS,0)>0 THEN VALOR/QTD "
		cQuery += "	ELSE "
		cQuery += "	CASE WHEN ISNULL(VALICMS,0)>0 THEN VALOR ELSE 0 END "
		cQuery += " END,0) AS VLRICMS, "
		cQuery += " ISNULL(CASE "
		cQuery += "	WHEN ISNULL(VALISS,0)>0 AND ISNULL(VALICMS,0)>0 THEN VALOR/QTD "
		cQuery += "	ELSE "
		cQuery += "	CASE WHEN ISNULL(VALISS,0)>0 THEN VALOR ELSE 0 END "
		cQuery += " END,0) AS VLRISS, "
		cQuery += " ISNULL(CASE "
		cQuery += "	WHEN ISNULL(VALISS,0)=0 AND ISNULL(VALICMS,0)=0 THEN VALOR "
		cQuery += " END,0) AS VLROUT, "
		cQuery += " INTERMED AS CODA1U, ORIGEM "
		
		cQuery	+=	" FROM ? FIN "

		cQuery	+=	" LEFT JOIN  "+RetSqlName("SF2")+" SF2 ON SF2.F2_FILIAL = ? AND SF2.F2_DOC=(CASE WHEN FIN.ORIGEM LIKE 'LOJ%' THEN FIN.E1_NUMNOTA ELSE FIN.NUMERO END) AND SF2.F2_PREFIXO = FIN.PREFIXO AND SF2.D_E_L_E_T_ = ? "
		cQuery	+=	" INNER JOIN "+RetSqlName("CJS")+" CJS ON CJS.CJS_FILIAL = ? AND CJS_FORMA = FIN.FORMA_PGTO AND (CASE WHEN CJS_REGIME = '1' THEN 'CAIXA' ELSE 'COMPETENCIA' END) = RTRIM(FIN.REGIME) AND CJS.D_E_L_E_T_ = ? "
		// Retornar Valores - ISS
		cQuery	+=	" LEFT JOIN (SELECT FT_FILIAL,FT_TIPOMOV,FT_SERIE,FT_NFISCAL,FT_CLIEFOR,FT_LOJA,SUM(FT_VALICM+FT_OUTRICM+FT_ISENICM) VALISS FROM " + RetSqlName("SFT")
		cQuery	+=	            " WHERE FT_FILIAL = ? AND FT_TIPO = ? AND D_E_L_E_T_ = ? "
		cQuery	+=	            " GROUP BY FT_FILIAL,FT_TIPOMOV,FT_SERIE,FT_NFISCAL,FT_CLIEFOR,FT_LOJA) SFTISS ON SFTISS.FT_SERIE=SF2.F2_SERIE AND SFTISS.FT_NFISCAL=SF2.F2_DUPL AND SFTISS.FT_CLIEFOR=SF2.F2_CLIENTE AND SFTISS.FT_LOJA=SF2.F2_LOJA AND SFTISS.FT_TIPOMOV = ? "
		// Retornar Valores - ICMS
		cQuery	+=	" LEFT JOIN (SELECT FT_FILIAL,FT_TIPOMOV,FT_SERIE,FT_NFISCAL,FT_CLIEFOR,FT_LOJA,SUM(FT_VALICM+FT_OUTRICM+FT_ISENICM) VALICMS FROM " + RetSqlName("SFT")
		cQuery	+=	            " WHERE FT_FILIAL = ? AND FT_TIPO <> ? AND D_E_L_E_T_ = ? "
		cQuery	+=	            " GROUP BY FT_FILIAL,FT_TIPOMOV,FT_SERIE,FT_NFISCAL,FT_CLIEFOR,FT_LOJA) SFTICMS ON SFTICMS.FT_SERIE=SF2.F2_SERIE AND SFTICMS.FT_NFISCAL=SF2.F2_DUPL AND SFTICMS.FT_CLIEFOR=SF2.F2_CLIENTE AND SFTICMS.FT_LOJA=SF2.F2_LOJA AND SFTICMS.FT_TIPOMOV = ? "
		// Retornar Valores - Outros
		cQuery	+=	" LEFT JOIN (SELECT FT_FILIAL,FT_TIPOMOV,FT_SERIE,FT_NFISCAL,FT_CLIEFOR,FT_LOJA,COUNT(FT_NFISCAL) QTD FROM "+RetSqlName("SFT")+" "
		cQuery	+=	            " WHERE FT_FILIAL = ? AND D_E_L_E_T_ = ? "
		cQuery	+=	            " GROUP BY FT_FILIAL,FT_TIPOMOV,FT_SERIE,FT_NFISCAL,FT_CLIEFOR,FT_LOJA) SFTQTD ON SFTQTD.FT_SERIE=SF2.F2_SERIE AND SFTQTD.FT_NFISCAL=SF2.F2_DUPL AND SFTQTD.FT_CLIEFOR=SF2.F2_CLIENTE AND SFTQTD.FT_LOJA=SF2.F2_LOJA AND SFTQTD.FT_TIPOMOV = ? "
		
		cQuery  +=  " WHERE "
		cQuery  +=  " SUBSTRING(FIN.BANCO, 1, ?)  BETWEEN ? AND ? AND "
		cQuery  +=  " FIN.CLIFOR BETWEEN ? AND ? AND "
		cQuery  +=  " FIN.LOJA BETWEEN ? AND ? AND "
		cQuery  +=  " FIN.PREFIXO BETWEEN ? AND ? "

		If !Empty(MV_PAR13) // Considerar tipos ?  
			cQuery += " AND FIN.TIPO IN ( ? ) "
		EndIf
		If !Empty(MV_PAR14) // Não considerar tipos ?    
			cQuery += " AND FIN.TIPO NOT IN ( ? ) "
		EndIf

		oMontQry := FWPreparedStatement():New( ChangeQuery(cQuery) )

	EndIf

	oMontQry:SetUnsafe(nPos += 1, oFinR190Tb:GetRealName())
	oMontQry:SetString(nPos += 1, o1601Fil["SF2"])
	oMontQry:SetString(nPos += 1,  " ")
	oMontQry:SetString(nPos += 1, o1601Fil["CJS"])
	oMontQry:SetString(nPos += 1,  " ")
	oMontQry:SetString(nPos += 1, o1601Fil["SFT"])
	oMontQry:SetString(nPos += 1,  "S")     //FT_TIPO = S (Servicos)
	oMontQry:SetString(nPos += 1,  " ")     //D_E_L_E_T_ 
	oMontQry:SetString(nPos += 1,  "S")     //SFTISS.FT_TIPOMOV 
	oMontQry:SetString(nPos += 1, o1601Fil["SFT"])
	oMontQry:SetString(nPos += 1,  "S")     //FT_TIPO <> S (Servicos) 
	oMontQry:SetString(nPos += 1,  " ")     //D_E_L_E_T_ 
	oMontQry:SetString(nPos += 1,  "S")     //SFTICMS.FT_TIPOMOV
	oMontQry:SetString(nPos += 1, o1601Fil["SFT"])
	oMontQry:SetString(nPos += 1,  " ")     //D_E_L_E_T_ 
	oMontQry:SetString(nPos += 1,  "S")     //SFTQTD.FT_TIPOMOV
	oMontQry:SetNumeric(nPos+= 1, nTamBco ) //Tamanho do campo A6_COD
	oMontQry:SetString(nPos += 1, MV_PAR05) //Do Banco ?                    
	oMontQry:SetString(nPos += 1, MV_PAR06) //Até o Banco ?                 
	oMontQry:SetString(nPos += 1, MV_PAR07) //Do Cliente ?                  
	oMontQry:SetString(nPos += 1, MV_PAR08) //Até o Cliente ?               
	oMontQry:SetString(nPos += 1, MV_PAR09) //Da Loja do Cliente ?          
	oMontQry:SetString(nPos += 1, MV_PAR10) //Até a Loja do Cliente ?       
	oMontQry:SetString(nPos += 1, MV_PAR11) //Do prefixo ?                  
	oMontQry:SetString(nPos += 1, MV_PAR12) //Até o prefixo ?               

	If !Empty(MV_PAR13) // Considerar tipos ?            
		oMontQry:SetIn(nPos += 1, StrTokArr(Alltrim(MV_PAR13), ";"))
	EndIf
	If !Empty(MV_PAR14) // Não considerar tipos ?                   
		oMontQry:SetIn(nPos += 1, StrTokArr(Alltrim(MV_PAR14), ";"))
	EndIf
	
	cQry := oMontQry:GetFixQuery()
 
	MPSysOpenQuery(cQry, cAliascTMP)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcCJQ
Função que percorre o alias montado (Financeiro + Fiscal) e chama a gravação da tabela CJQ e CJR 

@author Matheus Massarotto
@since 17/04/2023
@version 12.1.2210
/*/
//-------------------------------------------------------------------
Static Function ProcCJQ(cAliascTMP,oProcess,oJsBank,oSizeCpSX3,oModel)
	Local aRet          := {}
	Local cItem         := STRZERO(0,TamSx3("CJR_ITEM")[1])
	Local cCodMd5       := ""
	Local cBkpItem      := cItem
	Local cTipoPar      := ""
	Local cCodPar       := ""
	Local cCliefor      := ""
	Local cLoja         := ""
	Local cBanco        := ""
	Local cAgenc        := ""
	Local cNumConta     := ""
	Local cIntermed     := ""
	Local cPeriod       := ""
	Local cFil_         := ""
	Local nTOT_VS       := 0
	Local nTOT_ISS      := 0
	Local nTOT_OUT      := 0
	Local oJsCJQ        := JsonObject():new()
	Local cChvBanco     := ""
	Local cLog          := ""
	Local oModelDet  

	(cAliascTMP)->(DbGoTop())

	Do While !(cAliascTMP)->(Eof())

        oModel:SetOperation( MODEL_OPERATION_INSERT )
        oModel:Activate()
        oModelDet:= oModel:GetModel( "FISA313ITEM" )

		If !lAutomato
			oProcess:Inc2Progress(STR0013)//'Processando inclusão: '
		Endif	
		cChvBanco   := (cAliascTMP)->BANCO
		WhatBank(@oJsBank,cChvBanco,oSizeCpSX3)

		cTipoPar    := ""
		cCodPar     := ""
		cCliefor    := (cAliascTMP)->CLIFOR
		cLoja       := (cAliascTMP)->LOJA
		cBanco      := oJsBank[cChvBanco][1]
		cAgenc      := oJsBank[cChvBanco][2]
		cNumConta   := oJsBank[cChvBanco][3]
		cIntermed   := (cAliascTMP)->CODA1U
		nTOT_VS     := (cAliascTMP)->VLRICMS
		nTOT_ISS    := (cAliascTMP)->VLRISS
		nTOT_OUT    := (cAliascTMP)->VLROUT

		aRet        := VerPart(cCliefor,cLoja,cBanco,cAgenc,cNumConta,(cAliascTMP)->ORIGEM)
		cTipoPar    := aRet[1]
		cCodPar     := aRet[2]
		cPeriod     := alltrim((cAliascTMP)->PERIODO)
		cFil_       := o1601Fil["CJQ"]
		cCodMd5     := MD5(cFil_+cPeriod+cTipoPar+cCodPar+cIntermed,2) //Hash hexadecimal

		if !empty(cTipoPar) .and. !empty(cCodMd5)

			If !lAutomato
				oProcess:Inc2Progress(STR0013+cCodPar)//'Processando inclusão: '
			Endif	

			GrvCJQ(oModel,cFil_, cPeriod, cTipoPar, cCodPar, cCliefor, cLoja, cBanco, cAgenc, cNumConta, cIntermed, nTOT_VS, nTOT_ISS, nTOT_OUT,cCodMd5)

			cItem:=SOMAJS(@oJsCJQ,cCodMd5,cBkpItem)

			GrvCJR(oModelDet,cFil_,cCodMd5,cItem,(cAliascTMP)->FT_TIPOMOV,(cAliascTMP)->FT_NFISCAL,(cAliascTMP)->FT_SERIE,(cAliascTMP)->FILORIG,(cAliascTMP)->PREFIXO,;
				(cAliascTMP)->NUMERO,(cAliascTMP)->PARCELA,(cAliascTMP)->TIPO,"R",(cAliascTMP)->CLIFOR,(cAliascTMP)->LOJA,;
				(cAliascTMP)->VALOR,nTOT_VS,nTOT_ISS,nTOT_OUT,(cAliascTMP)->DT_BAIXA,(cAliascTMP)->DT_EMISSAO,(cAliascTMP)->FORMA_PGTO)

		endif

		(cAliascTMP)->(dbSkip())

        if oModel:VldData()
            oModel:CommitData()            
        else
            cLog := cValToChar(oModel:GetErrorMessage()[4]) + ' - '
            cLog += cValToChar(oModel:GetErrorMessage()[5]) + ' - '
            cLog += cValToChar(oModel:GetErrorMessage()[6])        	
            Help( "",1,"Help",,cLog, 1, 0 )
        endif

		oModel:DeActivate()

	Enddo

	aSize(aRet, 0)
	FreeObj(oJsCJQ)
	oJsCJQ:=Nil

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} SOMAJS
Função controla soma de itens no Json 

@author Matheus Massarotto
@since 17/04/2023
@version 12.1.2210
/*/
//-------------------------------------------------------------------
Static Function SOMAJS(oJson,cCodMd5,cItem)
	Local cValor := ""

	if oJson[cCodMd5]==Nil
		cValor:=SOMA1(cItem)
	else
		cValor:=SOMA1(oJson[cCodMd5])
	endif

	oJson[cCodMd5]:=cValor

Return(cValor)

//-------------------------------------------------------------------
/*/{Protheus.doc} GrvCJQ
Função que grava a tabela CJQ

@author Matheus Massarotto
@since 17/04/2023
@version 12.1.2210
/*/
//-------------------------------------------------------------------
Static Function GrvCJQ(oModel,cFil_,cPeriod,cTipoPar,cCodPar,cCliefor,cLoja,cBanco,cAgenc,cNumConta,cIntermed,nTOT_VS,nTOT_ISS,nTOT_OUT,cCodMd5)
	Local cChave := cFil_+cPeriod+cTipoPar+cCodPar+cIntermed

	//CJQ_FILIAL+CJQ_PERIOD+CJQ_TPPAR+CJQ_CODPAR
	If !CJQ->(dbSeek(cChave))
        oModel:SetValue( "FISA313MOD", "CJQ_FILIAL", cFil_    )
        oModel:SetValue( "FISA313MOD", "CJQ_PERIOD", cPeriod  )
        oModel:SetValue( "FISA313MOD", "CJQ_TPPAR" , cTipoPar )
        oModel:SetValue( "FISA313MOD", "CJQ_CODPAR", cCodPar  )
		If cTipoPar <> "3"
			oModel:SetValue( "FISA313MOD", "CJQ_CLIFOR", cCliefor )
			oModel:SetValue( "FISA313MOD", "CJQ_LOJA"  , cLoja    )
		Else
			oModel:SetValue( "FISA313MOD", "CJQ_BANCO" , cBanco   )
			oModel:SetValue( "FISA313MOD", "CJQ_AGENC" , cAgenc   )
			oModel:SetValue( "FISA313MOD", "CJQ_NUMCON", cNumConta)
		EndIf
        oModel:SetValue( "FISA313MOD", "CJQ_INTERM", cIntermed)
        oModel:SetValue( "FISA313MOD", "CJQ_TOTVS" , nTOT_VS  )
        oModel:SetValue( "FISA313MOD", "CJQ_TOTISS", nTOT_ISS )
        oModel:SetValue( "FISA313MOD", "CJQ_TOTOUT", nTOT_OUT )
        oModel:SetValue( "FISA313MOD", "CJQ_MANAUT", cCodMd5  )
	Else

		if !(MV_PAR15==2 .and. empty(CJQ->CJQ_MANAUT))
            oModel:DeActivate()
            oModel:SetOperation( MODEL_OPERATION_UPDATE  )
            oModel:Activate()
            oModel:LoadValue( "FISA313MOD", "CJQ_TOTVS" , oModel:GetValue("FISA313MOD", "CJQ_TOTVS")  + nTOT_VS  )
            oModel:LoadValue( "FISA313MOD", "CJQ_TOTISS", oModel:GetValue("FISA313MOD", "CJQ_TOTISS") + nTOT_ISS )
            oModel:LoadValue( "FISA313MOD", "CJQ_TOTOUT", oModel:GetValue("FISA313MOD", "CJQ_TOTOUT") + nTOT_OUT )
        
		endif

	Endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} DelCJQ
Função que deleta itens marcando com D_E_L_E_T_='*' da tabela CJQ

@author Matheus Massarotto
@since 17/04/2023
@version 12.1.2210
/*/
//-------------------------------------------------------------------
Static Function DelCJQ(cAliascTMP,oProcess,oJsBank,oSizeCpSX3,oModel)
	Local aRet      := {}
	Local cCliefor  := ""
	Local cLoja     := ""
	Local cBanco    := ""
	Local cAgenc    := ""
	Local cNumConta := ""
	Local cTipoPar  := ""
	Local cCodPar   := ""
	Local cPeriod   := ""
	Local cFil_     := ""
	Local cCodMd5   := ""
	Local cChave    := ""
	Local cIntermed := ""
	Local cChvBanco := ""
	Local oDelCJR   := Nil

	(cAliascTMP)->(DbGoTop())

	Do While !(cAliascTMP)->(Eof())
		If !lAutomato
			oProcess:Inc2Progress(STR0014)//Processando exclusão:
		Endif	
		cChvBanco   := (cAliascTMP)->BANCO
		WhatBank(@oJsBank,cChvBanco,oSizeCpSX3)

		cCliefor    := (cAliascTMP)->CLIFOR
		cLoja       := (cAliascTMP)->LOJA
		cBanco      := oJsBank[cChvBanco][1]
		cAgenc      := oJsBank[cChvBanco][2]
		cNumConta   := oJsBank[cChvBanco][3]

		aRet        := VerPart(cCliefor,cLoja,cBanco,cAgenc,cNumConta,(cAliascTMP)->ORIGEM)

		cTipoPar    := aRet[1]
		cCodPar     := aRet[2]
		cPeriod     := alltrim((cAliascTMP)->PERIODO)
		cFil_       := o1601Fil["CJQ"]
		cIntermed   := (cAliascTMP)->CODA1U
		cCodMd5     := MD5(cFil_+cPeriod+cTipoPar+cCodPar+cIntermed,2) //Hash hexadecimal
		cChave      := cFil_+cPeriod+cTipoPar+cCodPar+cIntermed

		if CJQ->(dbSeek(cChave)) .and. !(MV_PAR15==2 .and. empty(CJQ->CJQ_MANAUT))
			
			If !lAutomato
				oProcess:Inc2Progress(STR0014+cCodPar)//Processando exclusão:
			Endif	

            oModel:SetOperation( MODEL_OPERATION_DELETE ) 
            oModel:Activate()
            if oModel:VldData()
                oModel:CommitData()
            endif			
			oModel:DeActivate()

			DelCJR(cCodMd5, @oDelCJR)

		endif

		(cAliascTMP)->(DbSkip())
	Enddo

	aSize(aRet, 0)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GrvCJR
Função que grava a tabela CJR

@author Matheus Massarotto
@since 17/04/2023
@version 12.1.2210
/*/
//-------------------------------------------------------------------
Static Function GrvCJR(oModelDet,cFil_,cCodMd5,cItem,cTpMov,cDoc,cSerie,cFilOri,cPrefix,cNumtit,cParc,cTipo,cRecpag,cCliefor,cLoja,nValor,nTOT_VS,nTOT_ISS,nTOT_OUT,;
						cDT_BAIXA,cDT_EMISSAO,cFORMA_PGTO)
	
	If !CJR->(dbSeek(cFil_+PADR(cCodMd5,nTamCJR)+cItem)) //CJR_FILIAL+CJR_MANAUT+CJR_ITEM
       
	   if val(cItem) > 1
            oModelDet:AddLine()
        endif
         
        oModelDet:SetValue( "CJR_FILIAL"    , o1601Fil["CJR"]   )
        oModelDet:SetValue( "CJR_ITEM"      , cItem             )
        oModelDet:SetValue( "CJR_TPMOV"     , cTpMov            )
        oModelDet:SetValue( "CJR_DOC"       , cDoc              )
        oModelDet:SetValue( "CJR_SERIE"     , cSerie            )
        oModelDet:SetValue( "CJR_FILORI"    , cFilOri           )
        oModelDet:SetValue( "CJR_PREFIX"    , cPrefix           )
        oModelDet:SetValue( "CJR_NUMTIT"    , cNumtit           )
        oModelDet:SetValue( "CJR_PARCEL"    , cParc             )
        oModelDet:SetValue( "CJR_TIPO"      , cTipo             )
        oModelDet:SetValue( "CJR_RECPAG"    , cRecpag           )
        oModelDet:SetValue( "CJR_CLIFOR"    , cCliefor          )
        oModelDet:SetValue( "CJR_LOJA"      , cLoja             )
        oModelDet:SetValue( "CJR_VALOR"     , nValor            )
        oModelDet:SetValue( "CJR_VLRICM"    , nTOT_VS           )
        oModelDet:SetValue( "CJR_VLRISS"    , nTOT_ISS          )
        oModelDet:SetValue( "CJR_VLROUT"    , nTOT_OUT          )
        oModelDet:SetValue( "CJR_EMISSA"    , SToD(cDT_EMISSAO) )
        oModelDet:SetValue( "CJR_BAIXA"     , SToD(cDT_BAIXA)   )
        oModelDet:SetValue( "CJR_FORMA"     , cFORMA_PGTO       )
		 
	Endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} DelCJR
Função que deleta, removendo do banco itens  da tabela CJR

@author Matheus Massarotto
@since 17/04/2023
@version 12.1.2210
/*/
//-------------------------------------------------------------------
Static Function DelCJR(cCodMd5, oDelCJR)
Local cQuery := ""

	If oDelCJR == Nil
		oDelCJR := FWPreparedStatement():New()
		cQuery := "DELETE FROM ? WHERE D_E_L_E_T_ = ' ' AND CJR_MANAUT = ?"
		//Define a consulta
		oDelCJR:SetQuery(cQuery)
	EndIf

	//Define os parâmetros
	oDelCJR:SetUnsafe(1, RetSqlName("CJR"))
	oDelCJR:SetString(2, cCodMd5)
 
	TCSqlExec(oDelCJR:GetFixQuery()) //Recupera a consulta já com os parâmetros injetados e executa a query

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} VerPart
Função que verifica o tipo do participante e devolve o tipo e o código pronto

@author Matheus Massarotto
@since 17/04/2023
@version 12.1.2210
/*/
//-------------------------------------------------------------------
Static function VerPart(cCliefor,cLoja,cBanco,cAgenc,cNumConta,cORIGEM)

	Local cTipoPar := ""
	Local cCodPar  := ""

	If "LOJA" $ cORIGEM
		cTipoPar := "2"
		cCodPar  := cCliefor+cLoja
	ElseIf !empty(cBanco) .and. !empty(cAgenc) .and. !empty(cNumConta)
		cTipoPar := "3"
		cCodPar  := cBanco+cAgenc+cNumConta
	EndIf

Return{cTipoPar,PadR(cCodPar,nTamCod)}

//-------------------------------------------------------------------
/*/{Protheus.doc} ValidForm
Validação das informações digitadas no form.

@author Matheus Massarotto
@since 17/04/2023
@version 12.1.2210
/*/
//-------------------------------------------------------------------
Static Function ValidForm(oModel)

	Local lRet		:=	.T.

	Local nOp		:=	oModel:GetOperation()
	Local cPeriodo  :=  oModel:GetValue('FISA313MOD','CJQ_PERIOD')
	Local cTipoPar  :=  oModel:GetValue('FISA313MOD','CJQ_TPPAR')
	Local cCodPArt  :=  oModel:GetValue('FISA313MOD','CJQ_CODPAR')
	Local cCodInte  :=  oModel:GetValue('FISA313MOD','CJQ_INTERM')

//CJQ_FILIAL+CJQ_PERIOD+CJQ_TPPAR+CJQ_CODPAR
	If nOp == 3   //Inclusão
		DbSelectArea ("CJQ")
		CJQ->(DbSetOrder (1))
		If CJQ->(DbSeek(xFilial("CJQ")+cPeriodo+cTipoPar+cCodPArt+cCodInte))
			Help(" ",1,"Help","Help",STR0015,1,0)//Registro já cadastrado
			lRet:= .F.
		EndIF
	EndIF

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A312ChgF3
Funcao utilizada para trocar a consulta F3 em momento de execucao dependendo
da opcao informada

@param 	cCmpF3 - Nomde do campo para fazer a validacao, o conteudo eh retornado pela classe GetValue( cModel , cCmpF3 )
		cModel - Id do modelo para passar na funcao GetValue( cModel , cCmpF3 )
		
@return cF3 - Retorna o nome da consulta F3 a ser utilizada
			
@author Matheus Massarotto
@since 17/04/2023
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function A312ChgF3(cCmpF3,cModel)
	Local	oModel	:= FWModelActive()
	Local	cF3		:= ""
	Local   cPart	:= ""

	lPart:= TemCamp()

	If lPart
		cPart:=oModel:GetValue(cModel,'CJQ_TPPAR')
	EndiF

	If lPart .AND. !Empty(cPart)
		IF cPart == "2"
			cF3			:=	"SA1"
		Else
			cF3			:=	"SA2A"
		EndIF
	Else
		cF3			:=	"SA2A"
	EndIF
	Limpa(oModel)

Return cF3

//-------------------------------------------------------------------
/*/{Protheus.doc} A312CanEd
Funcao determina os campos não editáveis

@param 	cCmpF3 - Nomde do campo para fazer a validacao, o conteudo eh retornado pela classe GetValue( cModel , cCmpF3, cView )
		cModel - Id do modelo para passar na funcao GetValue( cModel , cCmpF3, cView ) 
		cView  - Id do view para passar na funcao GetValue( cModel , cCmpF3, cView )

@return lRet - Retorna .T. ou .F. se pode editar
			
@author Matheus Massarotto
@since 17/04/2023
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function A312CanEd(cCmpF3,cModel,cView)
	Local	oModel	:= 	FWModelActive()
	Local	lRet	:=	.F.
	Local   cPart	:= ""

	lPart   := TemCamp()

	if lPart
		cPart:=oModel:GetValue(cModel,'CJQ_TPPAR')


		if cCmpF3 $ "CJQ_CLIFOR/CJQ_LOJA" .and. cPart $ "1/2"
			lRet:=.T.

		elseif cCmpF3 $ "CJQ_BANCO/CJQ_AGENC/CJQ_NUMCON" .and. cPart == "3"
			lRet:=.T.

		EndIF

	endif
	Limpa(oModel)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F312CODPAR
Funcao que adiciona o valor no campo CJQ_CODPAR, código do participante

@param 	cModel - Id do modelo para passar na funcao GetValue( cModel , cView ) 
		cView  - Id do view para passar na funcao GetValue( cModel , cView )

@return lRet - .T.
			
@author Matheus Massarotto
@since 17/04/2023
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function F312CODPAR(cModel,cView)
	Local	lRet	:=	.T.

	Local	oModel	:= 	FWModelActive()
	Local   oView   :=  FWViewActive()
	Local   cCliefor:=  oModel:GetValue(cModel,'CJQ_CLIFOR')
	Local   cLoja   :=  oModel:GetValue(cModel,'CJQ_LOJA')
	Local   cBanco  :=  oModel:GetValue(cModel,'CJQ_BANCO')
	Local   cAgenc  :=  oModel:GetValue(cModel,'CJQ_AGENC')
	Local   cConta  :=  oModel:GetValue(cModel,'CJQ_NUMCON')
	Local   cPart   :=  oModel:GetValue(cModel,'CJQ_TPPAR')

	if cPart $ "1/2"
		oModel:SetValue(cModel,'CJQ_CODPAR',cCliefor+cLoja)
	elseif cPart == "3"
		oModel:SetValue(cModel,'CJQ_CODPAR',cBanco+cAgenc+cConta)
	endif

	oView:Refresh(cView)
	Limpa(oModel,oView)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Limpa
Funcao limpa os objetos model e view

@param 	cModel - Id do modelo para passar na funcao GetValue( cModel , cView ) 
		cView  - Id do view para passar na funcao GetValue( cModel , cView )

@author Matheus Massarotto
@since 17/04/2023
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Limpa(oModel,oView)
	oModel:=Nil
	oView:=Nil
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} TemCamp
Funcao que verifica se existem os campos para a rotina

@author Matheus Massarotto
@since 17/04/2023
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function TemCamp()

	if lPart==Nil
		lPart	:= CJQ->(FieldPos("CJQ_TPPAR")) > 0 .and. CJQ->(FieldPos("CJQ_CLIFOR")) > 0 .and. ;
			CJQ->(FieldPos("CJQ_LOJA")) > 0 .and. CJQ->(FieldPos("CJQ_BANCO")) > 0 .and.;
			CJQ->(FieldPos("CJQ_AGENC")) > 0 .and. CJQ->(FieldPos("CJQ_NUMCON")) > 0 .and.;
			CJQ->(FieldPos("CJQ_CODPAR")) > 0 .and. CJQ->(FieldPos("CJQ_MANAUT")) > 0
	endif

Return(lPart)

//-------------------------------------------------------------------
/*/{Protheus.doc} F312TpPar
Funcao para limpar os campos pertinentes ao código do participante qd mudar o tipo do participante.

@author Matheus Massarotto
@since 17/04/2023
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function F312TpPar(cModel,cView)
	Local	oModel	:= 	FWModelActive()
	Local   oView   :=  FWViewActive()

	lPart   :=  TemCamp()

	if lPart .and. cPart <> oModel:GetValue(cModel,'CJQ_TPPAR')

		oModel:ClearField(cModel,'CJQ_CLIFOR')
		oModel:ClearField(cModel,'CJQ_LOJA')
		oModel:ClearField(cModel,'CJQ_CODPAR')
		oModel:ClearField(cModel,'CJQ_BANCO')
		oModel:ClearField(cModel,'CJQ_AGENC')
		oModel:ClearField(cModel,'CJQ_NUMCON')
		oModel:ClearField(cModel,'CJQ_DESPAR')

		oView:Refresh(cView)

	endif

	cPart:=oModel:GetValue(cModel,'CJQ_TPPAR')

	Limpa(oModel,oView)

Return(.T.)

//-------------------------------------------------------------------
/*/{Protheus.doc} ValidCpo
Validação de campos.

@author Matheus Massarotto
@since 19/04/2023
@version 12.1.2210
/*/
//-------------------------------------------------------------------
Static Function ValidCpo(cModel,cCampo)

	Local aArea   := GetArea()
	Local lRet    := .T.
	Local oModel  := FWModelActive()
	Local oItens  := oModel:GetModel(cModel)
	Local cPart   := oModel:GetValue(cModel,'CJQ_TPPAR')
	Local cCliFor := ""
	Local cLoja   := ""
	Local cBanco  := ""
	Local cAgenc  := ""
	Local cConta  := ""

	cCliFor := oModel:GetValue(cModel, "CJQ_CLIFOR")
	cLoja   := oModel:GetValue(cModel, "CJQ_LOJA"  )
	cBanco  := oModel:GetValue(cModel, "CJQ_BANCO" )
	cAgenc  := oModel:GetValue(cModel, "CJQ_AGENC" )
	cConta  := oModel:GetValue(cModel, "CJQ_NUMCON" )

	Do Case
	Case cCampo $ "CJQ_CLIFOR"

		If cPart $ "1/2"

			If cPart == "1" .And. !Empty(cCliFor)
				If !Empty(cLoja)
					cCliFor += cLoja
				EndIf
				SA2->(DbSetOrder(1))
				lRet := SA2->(DbSeek(xFilial("SA2") + cCliFor ))
				If lRet .And. Empty(cLoja)
					oItens:LoadValue('CJQ_LOJA', SA2->A2_LOJA )
				EndIf

				if lRet
					oItens:LoadValue('CJQ_DESPAR', SA2->A2_NOME )
				endif

			ElseIf cPart == "2" .And. !Empty(cCliFor)
				If !Empty(cLoja)
					cCliFor += cLoja
				EndIf
				SA1->(DbSetOrder(1))
				lRet := SA1->(DbSeek(xFilial("SA1") + cCliFor))
				If lRet .And. Empty(cLoja)
					oItens:LoadValue('CJQ_LOJA', SA1->A1_LOJA )
				EndIf

				if lRet
					oItens:LoadValue('CJQ_DESPAR', SA1->A1_NOME )
				endif
			ElseIf Empty(cCliFor)
				lRet:=.F.
			EndIf
		EndIf

	Case cCampo $ "CJQ_LOJA"

		If cPart $ "1/2"

			If cPart == "1" .And. !Empty(cLoja)
				SA2->(DbSetOrder(1))
				lRet := SA2->(DbSeek(xFilial("SA2") + cCliFor + cLoja))
				if lRet
					oItens:LoadValue('CJQ_DESPAR', SA2->A2_NOME )
				endif
			ElseIf cPart == "2" .And. !Empty(cLoja)
				SA1->(DbSetOrder(1))
				lRet := SA1->(DbSeek(xFilial("SA1") + cCliFor + cLoja))
				if lRet
					oItens:LoadValue('CJQ_DESPAR', SA1->A1_NOME )
				endif
			ElseIf Empty(cLoja)
				lRet:=.F.
			EndIf
		EndIf

	Case cCampo $ "CJQ_BANCO/CJQ_AGENC/CJQ_NUMCON"

		if cPart $ "3"

			if !empty(cBanco) .and. !empty(cAgenc) .and. !empty(cConta)
				lRet := SA6->(DbSeek(xFilial("SA6") + cBanco + cAgenc + cConta))
				if lRet
					oItens:LoadValue('CJQ_DESPAR', SA6->A6_NOME )
				endif
			endif
		endif

	EndCase

	RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ValidRegex
Validação de campos.

@author Matheus Massarotto
@since 19/04/2023
@version 12.1.2210
/*/
//-------------------------------------------------------------------
Static Function ValidRegex(cModel,cCampo)

	Local lRet    := .T.
	Local oModel  := FWModelActive()
	Local cPeriod := ""
	Local oRegex

	// Inicializa objeto com Pattern de mes e ano
	oRegex := tRegex():new('^("?0[1-9]|1[012])(20)(\d{2}"?)$',.T.) //mês aceita de 1 a 12, ano aceita de 19,20 com 2 digitos finais de 0-9

    /*  oRegex := tRegex():new('^("?0[1-9]|1[012])(20)(\d{2}"?)$', .T.)
        Pegamos um problema da versão utilizada do motor de expressão regular configurada do linux não reconhece esta expressão de busca.
        Para corrigir este problema basta utilizar o RE2 como motor de busca, passando ".T." no segundo parâmetro.
    */
	if  ValType(oRegex) == "O"
		cPeriod := oModel:GetValue(cModel, "CJQ_PERIOD")

		// Valida o valor do campo data.
		lRet := oRegex:Search(cPeriod)
	endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Ver002
Funcao para verificar se o dicionário está atualizado para a nova versão

@author Matheus Massarotto
@since 13/06/2023
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Ver002(cPergunt)
	Local lRet      := .F.
	Local oFwSX1Util
	Local aPergunte	:= {}

	//Verifico o SX2
	lRet := "CJQ_INTERM" $ FwSX2Util():GetSX2data('CJQ', {"X2_UNICO"}) [1][2]

	If lRet
		//Verifico o SX1
		oFwSX1Util := FwSX1Util():New()
		oFwSX1Util:AddGroup(cPergunt)
		oFwSX1Util:SearchGroup()
		aPergunte := oFwSX1Util:GetGroup(cPergunt)

		//Verifico se o parâmetro existe
		If !(len(aPergunte)>1 .and. len(aPergunte[2])>=15 )
			lRet := .F.
		EndIf
		//Limpo o array e limpo o objeto
		FwFreeArray(aPergunte)
		oFwSX1Util := Nil
	EndIf

Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} GetFilial
 
Esta função retorna um array com as filiais selecionadas pelo
usuário através da MatFilCacl. 

@return array com informações da pergunta MV_PARXX
@author Erick G. Dias
@since 11/08/2014
@version 11.80
/*/
//-------------------------------------------------------------------
Static Function GetFilial(lAutomato, aAutoFil)

	Local aFil	:= {}
	Local aSM0	:= {}
	Local aAreaSM0	:= {}
	Local nFil	:= 0

	If MV_PAR04 == 1
		If lAutomato
			aFil:= MatFilCalc( .F., aAutoFil )
		Else
			//chama função para usuário escolher filial
			aFil:= MatFilCalc( .T. )
			If len(aFil) ==0
				MsgAlert('Nenhuma filial foi selecionada, o processamento não será realizado.')
			EndiF
		EndIf
	EndIF

	IF MV_PAR04 <> 1
		//Adiciona filial logada para realizar o processamento
		AADD(aFil,{.T.,SM0->M0_CODFIL,SM0->M0_FILIAL,SM0->M0_CGC})
	EndIF
	IF  Len(aFil) > 0

		aAreaSM0 := SM0->(GetArea())
		DbSelectArea("SM0")
		//--------------------------------------------------------
		//Irá preencher aSM0 somente com as filiais selecionadas
		//pelo cliente
		//--------------------------------------------------------

		SM0->(DbGoTop())
		If SM0->(MsSeek(cEmpAnt))
			Do While !SM0->(Eof())
				nFil := Ascan(aFil,{|x|AllTrim(x[2])==Alltrim(SM0->M0_CODFIL) .And. x[4] == SM0->M0_CGC})
				If nFil > 0 .And. aFil[nFil][1] .AND. cEmpAnt == SM0->M0_CODIGO
					Aadd(aSM0,SM0->M0_CODFIL)
				EndIf
				SM0->(dbSkip())
			Enddo
		EndIf

		SM0->(RestArea(aAreaSM0))
	EndIF

Return  aSM0

//-------------------------------------------------------------------
/*/{Protheus.doc} WhatBank
Retorna dados bancarios

@author Delleon Fernandes
@since 04/10/2023
@version 12.1.2310
/*/
//-------------------------------------------------------------------
Static Function WhatBank(oJsBank,cChvBanco, oSizeCpSX3)

	Local nA6COD     := oSizeCpSX3["A6_COD"]
	Local nA6AGENCIA := oSizeCpSX3["A6_AGENCIA"]
	Local nA6NUMCON  := oSizeCpSX3["A6_NUMCON"]

	If !oJsBank:hasProperty(cChvBanco)
		oJsBank[cChvBanco] := {Substr(cChvBanco, 1,nA6COD),;
			Substr(cChvBanco, nA6COD+1,nA6AGENCIA),;
			Substr(cChvBanco, (nA6COD+nA6AGENCIA)+1,nA6NUMCON)}
	EndIf

Return()


//-------------------------------------------------------------------
/*/{Protheus.doc} SizeCpoSX3
Retorna objeto com tamanho dos campos na SX3

@author Delleon Fernandes
@since 08/11/2023
@version 12.1.2310
/*/
//-------------------------------------------------------------------
Static Function SizeCpoSX3()
	Local oSizeCpSX3 := JsonObject():New()

	oSizeCpSX3['A6_COD']     := FWSX3Util():GetFieldStruct("A6_COD")[3]
	oSizeCpSX3['A6_AGENCIA'] := FWSX3Util():GetFieldStruct("A6_AGENCIA")[3]
	oSizeCpSX3['A6_NUMCON']  := FWSX3Util():GetFieldStruct("A6_NUMCON")[3]

Return(oSizeCpSX3)

//-------------------------------------------------------------------
/*/{Protheus.doc} fCacheFil
Funcao responsavel por realizar o cache do xFilial das tabelas envolvidas
 no processamento da importação dos titulos.

@return o1601Fil - json com o cache da filial de cada tabela.

@author Delleon Fernandes
/*/
//-------------------------------------------------------------------
Static Function fCacheFil()
	Local nX   := 0
	Local nLen := 0
	Local aDic := {}

	If cFilAnt<>o1601Fil["Filial"]
		
		aDic  := { "CJR",; //01
					"SA1",; //02
					"SA2",; //03
					"SA6",; //04
					"A1U",; //05
					"SF2",; //06
					"CJS",; //07
					"SFT",; //08
					"CJQ" } //09

		o1601Fil["Filial"] := cFilAnt

		nLen := Len(aDic)
		For nX:=1 to nLen
			o1601Fil[aDic[nX]] := xFilial(aDic[nX])
		Next nX
	EndIf

Return o1601Fil
