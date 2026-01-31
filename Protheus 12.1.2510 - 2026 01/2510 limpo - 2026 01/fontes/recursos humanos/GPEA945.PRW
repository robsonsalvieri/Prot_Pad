#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "GPEA945.CH"
Static lIntTAF		:= ((SuperGetMv("MV_RHTAF",, .F.) == .T.) .AND. Val(SuperGetMv("MV_FASESOC",/*lHelp*/,' ')) >= 1 )
Static lMiddleware	:= If( cPaisLoc == 'BRA' .AND. Findfunction("fVerMW"), fVerMW(), .F. )
Static cVersEnvio	:= ""
Static cVersGPE		:= ""

/*/{Protheus.doc} GPEA945
//Informações Complementares Menor Aprendiz
@author raquel.andrade
@since 31/07/2023
/*/
Function GPEA945()
Local oMBrowse
Local cFiltraRh

	// Verifica existência da tabela no dicionário de dados
	If !ChkFile("RU2")
		// "Atenção"
		//"Tabela RU2 - Inf. Complementares Menor Aprendiz não encontrada. 
		// Execute o UPDDISTR - atualizador de dicionário e base de dados."
		Help( " ", 1, OemToAnsi(STR0005),, OemToAnsi(STR0006), 1, 0 )
		Return
	EndIf

	oMBrowse := FWMBrowse():New()
	oMBrowse:SetAlias("SRA")
	oMBrowse:SetDescription(OemToAnsi(STR0013)) // "Informações Complementares Menor Aprendiz"

	// Inicializa o filtro utilizando a funcao FilBrowse
	cFiltraRh := CHKRH("GPEA945","SRA","1")
	oMBrowse:SetFilterDefault( cFiltraRh )
	oMBrowse:SetLocate()
	GpLegMVC(@oMBrowse)

	oMBrowse:SetFilterDefault("RA_CATEFD $ '103'")
	oMBrowse:ExecuteFilter(.T.)

	oMBrowse:Activate()

Return

/*/{Protheus.doc} MenuDef
Definição do MenuDef
@author raquel.andrade
@since 31/07/2023
/*/
Static Function MenuDef()
Local aRotina := {}

	aAdd( aRotina, { OemToAnsi(STR0001)	, "PesqBrw"        , 0, 1, 0, .T. } ) // "Pesquisar"
	aAdd( aRotina, { OemToAnsi(STR0002)	, "VIEWDEF.GPEA945", 0, 2, 0, NIL } ) // "Visualizar"
	aAdd( aRotina, { OemToAnsi(STR0003)	, "VIEWDEF.GPEA945", 0, 4, 0, NIL } ) // "Manutenção"
	aAdd( aRotina, { OemToAnsi(STR0004)	, "VIEWDEF.GPEA945", 0, 5, 0, NIL } ) // "Excluir"

Return aRotina

/*/{Protheus.doc} ModelDef
Definição do ModelDef
@author raquel.andrade
@since 31/07/2023
/*/
Static Function ModelDef()
Local oModel		:= Nil
Local oStruSRA 		:= FWFormStruct( 1, 'SRA')
Local oStruRU2 		:= FWFormStruct( 1, 'RU2')
Local bRU2posVal	:= {|oModel| fG945RU2po()}
Local bCommit		:= {|oModel| f945Comm(oModel)}
Local cVersEnvio	:= ""

	If FindFunction("fVersEsoc")
		fVersEsoc( "S2200", .F., /*aRetGPE*/, /*aRetTAF*/, @cVersEnvio )
	EndIf

	oModel     	:= MPFormModel():New('GPEA945',, ,bCommit )
	oStruSRA	:= FWFormStruct(1,"SRA",{|cCampo|  AllTrim(cCampo) $ "|RA_MAT|RA_NOME|RA_ADMISSA|"})
	If cVersEnvio <= "9.1"
		oStruRU2	:= FWFormStruct(1,"RU2",{|cCampo|  !(AllTrim(cCampo) $ "|RU2_ENTQA|RU2_ATPR|")})
	EndIf

	// Gatilhos
	If cVersEnvio >= "9.2"
		oStruRU2:AddTrigger( "RU2_INDMOD", "RU2_TPINSC", {|| .T. }, {|oMdl| fGP945Lp(1) }  )
		oStruRU2:AddTrigger( "RU2_INDMOD", "RU2_NUMINS", {|| .T. }, {|oMdl| fGP945Lp(2) }  )	
		oStruRU2:AddTrigger( "RU2_INDMOD", "RU2_ENTQA" , {|| .T. }, {|oMdl| fGP945Lp(3) }  )
	EndIf
	// Propriedades
	If !IsBlind() .And. cVersEnvio >= "9.2"
		oStruRU2:SetProperty( "RU2_ENTQA" , MODEL_FIELD_WHEN, { |oGrid| !(Empty(oGrid:GetValue("RU2_INDMOD"))) .And. oGrid:GetValue("RU2_INDMOD") == "1" } )
		oStruRU2:SetProperty( "RU2_TPINSC", MODEL_FIELD_WHEN, { |oGrid| !(Empty(oGrid:GetValue("RU2_INDMOD"))) .And. oGrid:GetValue("RU2_INDMOD") == "2" } )
		oStruRU2:SetProperty( "RU2_NUMINS", MODEL_FIELD_WHEN, { |oGrid| !(Empty(oGrid:GetValue("RU2_INDMOD"))) .And. oGrid:GetValue("RU2_INDMOD") == "2" } )
	EndIf

	oModel:AddFields( 'SRATITLE',				, oStruSRA )
	oModel:AddFields( 'RU2MASTER', 'SRATITLE'	, oStruRU2,,bRU2posVal )

	oModel:GetModel( 'SRATITLE' ):SetDescription(OemToAnsi(STR0007)) // "Funcionário"
	oModel:GetModel( 'RU2MASTER' ):SetDescription(OemToAnsi(STR0013)) // "Informações Complementares Menor Aprendiz"
	oModel:SetRelation( "RU2MASTER", { { 'RU2_FILIAL', 'SRA->RA_FILIAL'},  { 'RU2_MAT', 'SRA->RA_MAT' }} , RU2->(IndexKey(1)) )

	oModel:GetModel( "SRATITLE" ):SetOnlyQuery(.T.)
	
	oModel:SetVldActivate( { |oModel| fG945VldIni(oModel:GetOperation()) } )	

Return( oModel )

/*/{Protheus.doc} ViewDef
Definição do ViewDef
@author raquel.andrade
@since 31/07/2023
/*/
Static Function ViewDef()
Static cEFDAviso	:= If(cPaisLoc == 'BRA' .AND. Findfunction("fEFDAviso"), fEFDAviso(), "0")			//Se nao encontrar este parametro apenas emitira alertas
Local oView		:= NIL
Local oModel	:= FWLoadModel( 'GPEA945' )
Local oStruSRA	:= FWFormStruct(2, 'SRA')
Local oStruRU2	:= FWFormStruct(2, 'RU2')
Local cVersEnvio	:= ""

	If FindFunction("fVersEsoc")
		fVersEsoc( "S2200", .F., /*aRetGPE*/, /*aRetTAF*/, @cVersEnvio )
	EndIf

	oStruSRA	:= FWFormStruct(2,"SRA",{|cCampo|  AllTrim(cCampo) $ "|RA_MAT|RA_NOME|RA_ADMISSA|"})

	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField("VIEW_SRA",oStruSRA,"SRATITLE")
	oView:AddField("VIEW_RU2",oStruRU2,"RU2MASTER")

	oStruSRA:RemoveField("RA_FILIAL")
	oStruRU2:RemoveField("RU2_FILIAL")
	oStruRU2:RemoveField("RU2_MAT")

	If cVersEnvio <= "9.1"
		oStruRU2:RemoveField("RU2_ENTQA")
		oStruRU2:RemoveField("RU2_ATPR")	
	EndIf	

	oStruSRA:SetNoFolder()

	oView:SetOnlyView('VIEW_SRA')

	oView:CreateHorizontalBox( 'SUPERIOR', 20 )
	oView:CreateHorizontalBox( 'INFERIOR', 80 )

	oView:SetOwnerView( 'VIEW_SRA', 'SUPERIOR' )
	oView:SetOwnerView( 'VIEW_RU2', 'INFERIOR' )

	oView:EnableTitleView('VIEW_SRA')
	oView:EnableTitleView('VIEW_RU2')

Return oView


/*/{Protheus.doc} fG945VldIni
Verifica se já foi executado o RDMAKE para conversão dos dados do funcionário selecionado
@author raquel.andrade
@since 31/07/2023
/*/
Function fG945VldIni(nOperacao)
Local	lRet		:= .T.

	If nOperacao == 4		
		dbSelectArea("RU2")
		dbSetOrder(1)
		If !RU2->(DbSeek(xFilial("RU2",SRA->RA_FILIAL)+SRA->RA_MAT)) .And. !Empty(SRA->RA_TIPCTA)
			// "Os dados ref. ao Menor Aprendiz não foram  carregados para a Tabela RU2 - Inf. Complementares do Menor Aprendiz!"
			// "Utilize o rdmake ATURU2.PRW para carga dos dados"
			Help(,,OemToAnsi(STR0005),, OemTOAnsi(STR0009),1,,,,,,, { OemToAnsi(STR0010) })
			lRet	:= .F.
		EndIf
	ElseIf nOperacao == 5	
		dbSelectArea("RU2")
		dbSetOrder(1)
		If !RU2->(DbSeek(xFilial("RU2",SRA->RA_FILIAL)+SRA->RA_MAT)) 			
			// "Atenção"
			// "Não há dados a serem excluídos." 
			// "Para incluir dados acesse a opção de Manutenção." 
			Help(,,OemToAnsi(STR0005),, OemTOAnsi(STR0015),1,,,,,,, { OemToAnsi(STR0016) })
			lRet	:= .F.
		EndIf
	EndIf

Return lRet

/*/{Protheus.doc} fG945RU2po
Verifica preenchimento de campos obrigatórios.
@author raquel.andrade
@since 31/07/2023
/*/
Function fG945RU2po()
Local	oModel		:=	FWModelActive()
Local	oModelRU2	:=	oModel:GetModel('RU2MASTER')
Local	lRet		:= .T.
Local  	cVersEnvio	:= ""

	If FindFunction("fVersEsoc")
		fVersEsoc( "S2200", .F., /*aRetGPE*/, /*aRetTAF*/, @cVersEnvio )
	EndIf

	If cEFDAviso <> "2"	.And. cVersEnvio >= "9.2"
		If oModelRU2:GetValue('RU2_INDMOD') == "2".And. (Empty(oModelRU2:GetValue('RU2_TPINSC')) .Or. Empty(oModelRU2:GetValue('RU2_NUMINS')))
			// "Atenção!"###"Campos Tipo de Inscrição (RU2_TPINSC)e  Número de Inscrição (RU2_NUMINS) são de preenchimento obrigatório quando Ind. Modalidade é igual a 2-Contratação Indireta."	
			If cEFDAviso == "1"
				Help(,,OemToAnsi(STR0005),, OemTOAnsi(STR0011),1,,,,,,, { OemToAnsi(STR0014) })
				lRet := .F.
			ElseIf cEFDAviso == "0"
				MsgInfo(OemTOAnsi(STR0011), OemToAnsi(STR0005))//"Atenção"
			EndIf
		ElseIf oModelRU2:GetValue('RU2_INDMOD') == "1".And. Empty(oModelRU2:GetValue('RU2_ENTQA'))
			// "Atenção!"###"Campo CNPJ Ent.Qa. (RU2_ENTQA) é de preenchimento obrigatório quando Ind. Modalidade é igual a 1-Contratação Direta."	
			If cEFDAviso == "1"
				Help(,,OemToAnsi(STR0005),, OemTOAnsi(STR0012),1,,,,,,, { OemToAnsi(STR0014) })
				lRet := .F.
			ElseIf cEFDAviso == "0"
				MsgInfo(OemTOAnsi(STR0012), OemToAnsi(STR0005))//"Atenção"
			EndIf
		EndIf
	EndIf

	If cVersEnvio <= "9.1"
		If oModelRU2:GetValue('RU2_INDMOD') == "1"
			// "Para o leiaute S-1.1 utilizar apenas a opção 2-Contratação Indireta."  
			// "Preencher o campo Ind. Modalidade (RU2_INDMOD) com valor igual a 2-Contratação Indireta."
			Help(,,OemToAnsi(STR0005),, OemTOAnsi(STR0017),1,,,,,,, { OemToAnsi(STR0018) })
			lRet := .F.
		ElseIf oModelRU2:GetValue('RU2_INDMOD') == "2" .And. (Empty(oModelRU2:GetValue('RU2_TPINSC')) .Or. Empty(oModelRU2:GetValue('RU2_NUMINS')))
			// "Atenção!"###"Campos Tipo de Inscrição (RU2_TPINSC)e  Número de Inscrição (RU2_NUMINS) são de preenchimento obrigatório quando Ind. Modalidade é igual a 2-Contratação Indireta."	
			Help(,,OemToAnsi(STR0005),, OemTOAnsi(STR0019),1,,,,,,, { OemToAnsi(STR0014) })
			lRet := .F.
		EndIf
	EndIf

Return lRet

/*/{Protheus.doc} fGP945Lp
Limpa conteúdo de campos na troca de conteúdo
@author raquel.andrade
@since 31/07/2023
/*/
Function fGP945Lp(nCpo)
Local	oModel		:=	FWModelActive()
Local	oGrid		:=	oModel:GetModel('RU2MASTER')
Local  	cRet		:= ""
Local   nIndMod		:= oGrid:GetValue('RU2_INDMOD')

DEFAULT nCpo	:= ""

	If nIndMod == "1" .And. nCpo == 1 .And. !Empty(oGrid:GetValue('RU2_TPINSC'))
		cRet	:= Space(TamSx3("RU2_TPINSC")[1])
	ElseIf nIndMod == "1" .And. nCpo == 2 .And. !Empty(oGrid:GetValue('RU2_NUMINS'))
		cRet	:= Space(TamSx3("RU2_NUMINS")[1])
	ElseIf nIndMod == "2" .And. nCpo == 3 .And. !Empty(oGrid:GetValue('RU2_ENTQA'))
		cRet	:= Space(TamSx3("RU2_ENTQA")[1])
	EndIf

Return cRet

/*/{Protheus.doc} f945Comm
Commit do Model para integracao com o TAF 
@author raquel.andrade
@since 31/07/2023
/*/
Static Function f945Comm(oModel)
Local aArea			:= GetArea()
Local lRet			:= .T.
Local aTpAlt		:= {.F., .F., .F., .F.}
Local lTpMAp		:= .F.
Local lIntegra		:= .F.
Local oMdlRU2		:= oModel:GetModel("RU2MASTER")
Local cVersEnvio	:= ""
Local aErros        := {}
Local cMsgErro		:= ""

// Verifica se existe integração
If (lIntTAF .Or. lMiddleware) 

	If FindFunction("fVersEsoc")
		fVersEsoc( "S2200", .F., /*aRetGPE*/, /*aRetTAF*/, @cVersEnvio )
	EndIf
	
	// Verificação de qual o tipo de alteração foi realizada - RU2
	fGP945Alt(@lTpMAp, oMdlRU2,cVersEnvio)		

	// Verificação de qual o tipo de alteração foi realizada - SRA
	If IsBlind() .Or. FunName() == "GPEA945"
		RegToMemory("SRA",,, .F.)
	EndIf
	lRet := fVerTpAlt(@aTpAlt,lRet,lTpMAp, cVersEnvio)

	If lRet 
		//---------------------------------------
		//| Verifica existencia ou Status <> "4"
		//| Se status <> "4" ou não existir, cria reg
		//--------------------------------------------
		If ( aTpAlt[1] .Or. aTpAlt[2] )
			lIntegra := fIntAdmiss("SRA", /*lAltCad*/, 3, "S2200", Nil, Nil, Nil, oMdlRU2, Nil, @aErros, cVersEnvio, /*oMdlRFZ*/, /*aFilial*/, /*oMdlRS9*/, /*cFilTrf*/, /*dDtAdm*/, /*aVinc*/, /*cFilDe*/, .F.)
		Else
			If aTpAlt[4]
				lIntegra := fInt2206("SRA",/*lAltCad*/, 4,"S2206",SRA->RA_FILIAL,/*dtEf*/,/*cTurno*/,/*cRegra*/,/*cSeqT*/,oMdlRU2,cVersEnvio, /*oMdlRS9*/, /*dDtAlt*/, /*lTransf*/, /*cCTT2206*/, @aErros)	 
			EndIf
		EndIf

		If lIntegra
			If !IsBlind() .And. FindFunction("fEFDMsg")
				fEFDMsg()
			EndIf
			FWFormCommit(oModel)
		ElseIf Len(aErros) > 0
			FeSoc2Err( aErros[1], @cMsgErro ,IIF(aErros[1]!='000026',1,2))			
			oModel:SetErrorMessage("",,oModel:GetId(),"","",cMsgErro)
		EndIf	
	Else
		// "Cadastro não será salvo - rever dados do cadastro e/ou eventos."
		cMsgErro	:= OemToAnsi(STR0020)
		oModel:SetErrorMessage("",,oModel:GetId(),"","",cMsgErro)
	EndIf
Else
	FWFormCommit(oModel)
	lIntegra	:= .T.
EndIf

RestArea(aArea)

Return lIntegra

/*/{Protheus.doc} fGP945Alt
Verifica se houve alguma alteração no registro corrente do Menor Aprendiz
@author raquel.andrade
@since 31/07/2023
@version 1.0
/*/
Static Function fGP945Alt( lTpMAp, oMdl , cVersEnvio)
Local aCpos 	:= {}
Local cCpoTab	:= ""
Local cCpoMod	:= ""
Local nI 		:= 0

Default lTpMAp 		:= .F.
Default cVersEnvio	:= ""

	If cVersEnvio >= "9.2"
		aCpos := {"RU2_TPINSC", "RU2_NUMINS", "RU2_INDMOD", "RU2_ENTQA ", "RU2_ATPR"}
	Else
		aCpos := {"RU2_TPINSC", "RU2_NUMINS"}
	EndIf

	For nI := 1 To Len(aCpos)
		cCpoTab :=  &('RU2->' + aCpos[nI])
		cCpoMod	:=  oMdl:GetValue(aCpos[nI]) 
		If cCpoTab <> cCpoMod 
			lTpMAp := .T.
		EndIf
	neXT nI

Return
