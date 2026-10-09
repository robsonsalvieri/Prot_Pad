#INCLUDE "PROTHEUS.CH"  
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFMONREI.CH"
#INCLUDE "TAFCSS.CH"
#INCLUDE "TOPCONN.CH"

#DEFINE SETA_TEMA 15

Static __aWidgets		:= {}		//Array de objetos com os Widgets ativos.
//------------------------------------------------------------------------------
/*/{Protheus.doc} TAFMONREI

Monta a área de trabalho

@sample		CRMA290WA()
					
@return		Nenhum

@author		Leoardo Kichitaro
@since			15/04/2014
@version		P12
/*/
//------------------------------------------------------------------------------
Function TAFMONREI( cPeriodo )

	Local aSize				as array
	Local aButtons			as array
	Local bVldPer			as codeblock
	Local cMenuItem  		as char
	Local cAmbReinf			as char
	Local cNmAmb			as char
	Local cIdEnt			as char
	Local cCNPJFil			as char 
	Local cMsgPar			as char
	Local lOk				as logical
	Local lOkT9B			as logical
	Local lMatriz			as logical
	Local lReinfAtu			as logical
	Local nTop				as numeric
	Local nLeft				as numeric
	Local nBottom			as numeric
	Local nRight			as numeric
	Local oMenu      		as object
	Local oWorkArea			as object
	Local oDlgWA			as object
	Local oDlgT				as object
	Local oPanel			as object
	Local oSayPar			as object
	Local oGDataIni			as object
	Local oSize				as object

	//Se o cadastro de clientes for convertido para MVC excluir essas variaveis private.
	Private aStatus		as array
	Private aRotina		as array

	Private aColsCCust	as array
	Private aBkpAgg		as array
	Private aParamRei	as array

	//Tabelas temporarias
	Private cAliasTab	as char
	Private cAliasEvp	as char
	Private cAliasEvn	as char
	Private cVerSchema	as char
	Private oAliasTab	as object
	Private oAliasEvp	as object
	Private oAliasEvn	as object

	Default cPeriodo	:= TafPeReinf()
	
	If NewPaREINF()
		Return
	EndIf

	aStatus := { {01,"Pendente/Inválido" ,"TRANSMISSÃO NÃO EFETUADA - Informações inválidas que necessitam de revisão."}; //"Pendente/Inválido"#"TRANSMISSÃO NÃO EFETUADA - Informações inválidas que necessitam de revisão."
				,{02,"Transmitido/Aguardando" ,"Aguardando retorno do RET."}; //"Transmitido/Aguardando"#"Aguardando retorno do RET."
				,{03,"Retornado/Inconsistente" ,"Retornado do Governo com inconsitências. NECESSÁRIO INTERVENÇÃO MANUAL."}; //"Retornado/Inconsitente"#"Retornado do Governo com inconsitências. NECESSÁRIO INTERVENÇÃO MANUAL."
				,{04,"Retornado/Consistente" ,"Validado e Protocolado pelo Governo"}; //"Retornado/Consistente"#"Validado e Protocolado pelo Governo"
				,{06,"Transmitido/Aguardando Exclusão" ,"Aguardando retorno da Exclusão do RET."}; //"Transmitido/Aguardando Exclusão"#"Aguardando retorno da Exclusão do RET."
				,{07,"Retornado/Consistente" ,"Evento de Exclusão validado e protocolado pelo Governo."}; //"Evento de Exclusão validado e protocolado pelo Governo."
				,{99,"Pendente/Não Validado" ,"Não realizado a validação do registro pelo usuário."}; //"Pendente/Não Validado"#"Não realizado a validação do registro pelo usuário."
				,{00,"Pendente/Valido" ,"Pronto para Transmissão."}; //"Pendente/Valido"#"Pronto para Transmissão."
				}

	aSize		:= FWGetDialogSize( oMainWnd )
	aButtons	:= {}
	aColsCCust	:= {}
	aBkpAgg		:= {}
	aParamRei	:= Array(1)
	oAliasTab	:= Nil
	oAliasEvp	:= Nil
	oAliasEvn	:= Nil
	cAliasTab	:= GetNextAlias()
	cAliasEvp	:= GetNextAlias()
	cAliasEvn	:= GetNextAlias()
	cPeriodo	:= StrTran(cPeriodo,"-","")
	oSize		:= FwDefSize():New(.F.)

	nTop    := 0		//oSize:aWindSize[1] - (oSize:aWindSize[1] * 0.73)
	nLeft   := 1.5		//oSize:aWindSize[2] - (oSize:aWindSize[2] * 0.70)
	nBottom := 197.34	//oSize:aWindSize[3] - (oSize:aWindSize[3] * 0.67)
	nRight  := 405.6	//oSize:aWindSize[4] - (oSize:aWindSize[4] * 0.70)

	SetStyle( 5 )

	lMatriz 	:= .F.
	lOkT9B		:= .T.
	cCNPJFil	:= ""
	bVldPer		:= {|| VldPer(cPeriodo)}

	//--------------------------------------
	// Busca Versão do Schema do REINF
	//--------------------------------------
	cVerSchema := SuperGetMv('MV_TAFVLRE',.F.,'1_03_02')

	DBSelectArea("C1E")
	C1E->( DBSetOrder(3) )
	If C1E->( DbSeek( xFilial("C1E") + PadR( SM0->M0_CODFIL, TamSX3( "C1E_FILTAF" )[1] ) + "1" ) )
		If C1E->C1E_MATRIZ == .T.
			lMatriz := .T.
		EndIf
		cCNPJFil:= AllTrim(Posicione("SM0",1,cEmpAnt+C1E->C1E_FILTAF, "M0_CGC"))
	EndIf

	DbSelectArea("T9B")
	T9B->(DbGoTop())
	If T9B->( Eof() )
		lOkT9B := .F. 
	EndIf

	lReinfAtu := TAFVdReinf( .T., "o Monitoramento" ,"o Monitoramento/Transmissão REINF") 

	//Verifica a versão da EFD-Reinf e verifica se o dicionario esta atualizado verificando um campo criado paraa versão.
	if lReinfAtu
		if strtran(cVerSchema,'_','') >= '10400' 
			lReinfAtu := TafColumnPos('V0W_CNOEST')
		endif	
	endif

	//APRESENTA TELA PARA SELEÇÃO DO PERÍODO DO MOMNITOR. 
	If !(FunName() == "TAFXREINF")
		//Verifica se existe período salvo no profile do usuário.

		If !FLoadProf()
			aParamRei[1] :=	TafPeReinf()
		EndIf

		cPeriodo := aParamRei[1]

		Define MsDialog oDlgT Title "Parâmetros Detalhamento" From nTop,nLeft To nBottom,nRight  Pixel 
			oPanel := TPanel():New(00,00,"",oDlgT,,.F.,.F.,,,10,20,.F.,.F.)
			oPanel:Align := CONTROL_ALIGN_ALLCLIENT
			oPanel:setCSS(QLABEL_AZUL_D)

			cMsgPar := "Informe o período de apuração:"

			oSayPar := TSay():New(005,oPanel:NCLIENTWIDTH  * 0.02,{||cMsgPar},oPanel,,,,,,.T.,,,oPanel:NCLIENTWIDTH * 0.45,030,,,,,,.F.)
			oGDataIni 	:= TGet():New(005,oPanel:NCLIENTWIDTH * 0.220,{|u|If( PCount()==0,cPeriodo,cPeriodo := u )},oPanel,035,009,"@R 99-9999", bVldPer ,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,"Período",,,,.T.)

		Activate MsDialog oDlgT ON INIT (EnchoiceBar(oDlgT,{||lOk :=.T.,oDlgT:End()},{||oDlgT:End()},,,,,.F.,.F.,.F.,.T.,.F.))
	ElseIf FunName() == "TAFXREINF"
		lOk := .T.
	EndIf


	If lMatriz .And. Len( cCNPJFil ) >= 11 .And. lOkT9B .And. lReinfAtu .And. lOk

		//--------------------------------------
		// Criação das tabelas temporarias
		//--------------------------------------
		FWMsgRun(,{||TafReiAtu(@oAliasTab,cAliasTab , 1,, cPeriodo)},"Carregando Registros do Monitor do Reinf","Carregando registros dos eventos de tabelas")

		FWMsgRun(,{||TafReiAtu(@oAliasEvp,cAliasEvp , 2,, cPeriodo)},"Carregando Registros do Monitor do Reinf","Carregando registros dos eventos periódicos")

		FWMsgRun(,{||TafReiAtu(@oAliasEvn,cAliasEvn , 3,, cPeriodo)},"Carregando Registros do Monitor do Reinf","Carregando registros dos eventos não periódicos")

		//--------------------------------------
		// Busca Entida no TSS
		//--------------------------------------
		cIdEnt  := TAFRIdEnt()

		//Verifica qual tipo de ambiente foi configurado 
		//pela wizard de configuração do reinf
		cNmAmb		:= ""
		cAmbReinf	:= GetNewPar( "MV_TAFAMBR", "2" )

		If cAmbReinf == "1"
			cNmAmb	:= "1 - Produção"
		ElseIf cAmbReinf == "2"
			cNmAmb	:= "2 - Pré-produção - dados reais"
		ElseIf cAmbReinf == "3"
			cNmAmb	:= "3 - Pré-produção - dados fictícios"
		Else
			cNmAmb	:= cAmbReinf + " - Inválido"		
		EndIf
		//--------------------------------------
		// Monitor REINF - Nome do Usuário.Ç
		//--------------------------------------
		cCadastro := "Monitor de Transmissão EFD Reinf" //STR0001 //"Monitor de Transmissão do Reinf"
		cCadastro += "- Entidade: " + AllTrim( cIdEnt )
		cCadastro += "- Versão Layout: " + AllTrim( StrTran( cVerSchema , "_","." ) )
		cCadastro += "- Ambiente: " + AllTrim( cNmAmb )
		cCadastro += "- Período: " + AllTrim(SubStr(cPeriodo,1,2) + "-" + SubStr(cPeriodo,3,4))

		oDlgWA := MSDialog():New( aSize[1], aSize[2], aSize[3], aSize[4], STR0001, , , , nOr( WS_VISIBLE, WS_POPUP ), , , , , .T., , , , .F. ) 

		oWorkArea := FWUIWorkArea():New( oDlgWA )
		oWorkArea:SetMenuWidth( 200 )

		oMenu := FWMenu():New()
		oMenu:Init()

		//---------------------
		// Monta menu padrão
		//---------------------
		cMenuItem := oMenu:AddFolder("Reinf ", "A")								//"Reinf"
		oMenuItem := oMenu:GetItem( cMenuItem )

		oMenuItem:AddContent( STR0004, "E", "TafMonAtu('" + cPeriodo + "')" )						//"Atualizar Tela"
		oMenuItem:AddContent( STR0016, "E", "TafDetRei(1, '" + cIdEnt + "', '" + cPeriodo + "')" )	//"Transmitir ao Governo" 
		oMenuItem:AddContent( STR0017, "E", "TafDetRei(2, '" + cIdEnt + "', '" + cPeriodo + "')" )	//"Monitorar Transmissões"

		If cAmbReinf == "2" .And. FindFunction("TafLimpRei")
			oMenuItem:AddContent(STR0018, "E", "TafLimpRei()")					//"Remover Contribuinte"
		EndIf 
		// Monitor Padrão.
		TAFMonMenu( oMenu )				
		oWorkArea:SetMenu( oMenu )

		aMonArea := {aSize[3] * 0.24 ,aSize[3] * 0.43,aSize[3] * 0.27 }// {130,250,180}

		oWorkArea:CreateHorizontalBox( "LINE01", aMonArea[01], .T. ) // 220
		oWorkArea:SetBoxCols( "LINE01", { "WDGT01" } )

		oWorkArea:CreateHorizontalBox( "LINE02", aMonArea[02], .T. )//330
		oWorkArea:SetBoxCols( "LINE02", { "WDGT02" } )

		oWorkArea:CreateHorizontalBox( "LINE03", aMonArea[03], .T. )//300
		oWorkArea:SetBoxCols( "LINE03", { "WDGT03" } )

		oWorkArea:Activate()

		aAdd(__aWidgets, TAFMonWG( oWorkArea:GetPanel( "WDGT01" ), cAliasTab, "WDGT01" ))	//GRID Eventos de Tabela
		aAdd(__aWidgets, TAFMonWG( oWorkArea:GetPanel( "WDGT02" ), cAliasEvp, "WDGT02" ))	//GRID Eventos Periódicos
		aAdd(__aWidgets, TAFMonWG( oWorkArea:GetPanel( "WDGT03" ), cAliasEvn, "WDGT03" ))	//GRID Eventos Não Periódicos

		oDlgWA:Activate( , , , , , , EnchoiceBar( oDlgWA, {||}, { || oDlgWA:End() }, ,aButtons, , , , , .F., .F. ) ) //ativa a janela criando uma enchoicebar

		//----------------------------------------
		// Destroi os objetos criados nos Widgets 
		//----------------------------------------		
		__aWidgets	:= {}

		oAliasTab:Delete() 
		oAliasEvp:Delete() 
		oAliasEvn:Delete() 
	Else
		If !lMatriz
			Aviso(STR0020, STR0021, { "Ok" }, 2 ) //"Rotina indisponível"###"Só é possivel acessar a rotina de Monitoramento/Transmissão logado na filial matriz."
		ElseIf Len( cCNPJFil ) < 11
			Aviso(STR0020, STR0022, { "Ok" }, 2 )  //"Rotina indisponível"##"O Código de Inscrição (CNPJ) da matriz está em branco no cadastro de empresas."
		ElseIf !lOkT9B
			Aviso(STR0020, STR0023, { "Ok" }, 2 ) //"Rotina indisponível" ###"Autocontidas desatualizadas. É necessário executar o Wizard de Configuração do TAF e a atualização das Tabelas AutoContidas para o correto funcionamento do monitor."
		ElseIf !lReinfAtu
			Aviso(STR0027, STR0024+CRLF+CRLF+STR0025+CRLF+CRLF+STR0026, { "Ok" }, 3 ) //"Ambiente desatualizado!" ###"O ambiente TAF encontra-se desatualizado com relação as alterações referentes ao layout 1.04.00 da EFD Reinf." ###"As rotinas disponíveis no repositório de dados (RPO) estão mais atualizadas que o dicionário de dados."###"Para atualização dessa funcionalidade, será necessário atualizar o dicionário de dados, utilizando o último DIFERENCIAL disponibilizado no portal da TOTVS, utilizando a ferramenta UPDDISTR e, em seguida, executar o compatibilizador de dicionário de dados UPDTAF.""Para atualização dessa funcionalidade, será necessário atualizar o dicionário de dados, utilizando o último DIFERENCIAL disponibilizado no portal da TOTVS, utilizando a ferramenta UPDDISTR e, em seguida, executar o compatibilizador de dicionário de dados UPDTAF.""Para atualização dessa funcionalidade, será necessário atualizar o dicionário de dados, utilizando o último DIFERENCIAL disponibilizado no portal da TOTVS, utilizando a ferramenta UPDDISTR e, em seguida, executar o compatibilizador de dicionário de dados UPDTAF.""Para atualização dessa funcionalidade, será necessário atualizar o dicionário de dados, utilizando o último DIFERENCIAL disponibilizado no portal da TOTVS, utilizando a ferramenta UPDDISTR e, em seguida, executar o compatibilizador de dicionário de dados UPDTAF.""Para atualização dessa funcionalidade, será necessário atualizar o dicionário de dados, utilizando o último DIFERENCIAL disponibilizado no portal da TOTVS, utilizando a ferramenta UPDDISTR e, em seguida, executar o compatibilizador de dicionário de dados UPDTAF." 	
		EndIf
	EndIf	

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Leonardo Kichitaro
@since 31/10/2017
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function MenuDef()

Local aRotina as array

aRotina := {}

Return( aRotina )

//-------------------------------------------------------------------*/
/*/{Protheus.doc} TAFMonMenu
Função que monta o menu a partir do XML   

@param		cXML, caracter, Expressão retornada pelo FWFilterEdit. 
@return	Nenhum

@author	Jonatas Martins
@version	P12.1.7
@since		14/10/2015 
/*/
//-------------------------------------------------------------------
Function TAFMonMenu(oMenu, cXml)

	Local aFolders	:= {}
	Local aItens	:= {}
	Local cRotina	:= ""
	Local nFolder	:= 0
	Local nItens	:= 0
	Local oXML 		:= TXMLManager():New()

	Default cXml	:= ""
	Default oMenu	:= Nil

	//-------------------------------------------------------------------
	// Parseia o XML.  
	//-------------------------------------------------------------------	
	If ( ! Empty( cXML ) .And. ( oXML:Read( cXML,,"ISO-8859-1" ) ) ) 
		//-------------------------------------------------------------------
		// Recupera os menus principais do XML  
		//-------------------------------------------------------------------		
		aFolders := oXML:XPathGetChildArray("/MenuContent")
				
		For nFolder := 1 To Len(aFolders)
			//-------------------------------------------------------------------
			// Recupera os submenus do XML 
			//-------------------------------------------------------------------
			aItens := oXML:XPathGetChildArray( aFolders[nFolder][2] )

			//-------------------------------------------------------------------
			// Cria menus principais no objeto do menu  
			//-------------------------------------------------------------------
			cMenuItem := oMenu:AddFolder( aItens[1][3], "E" ) //Descrição do Menu principal
			oMenuItem := oMenu:GetItem( cMenuItem )
				
			For nItens := 1 To Len(aItens)	
				If aItens[nItens][1]   == "Content" 
					//-------------------------------------------------------------------
					// monta a string com a expressão da rotina para execução no menu 
					//-------------------------------------------------------------------
					cRotina := TafMonFormat(	oXML:XPathGetNodeValue( aItens[nItens][2] + "/Function"  ) ,;
												oXML:XPathGetNodeValue( aItens[nItens][2] + "/RotName"   ) ,;
												oXML:XPathGetNodeValue( aItens[nItens][2] + "/Operation" ) ,;
												oXML:XPathGetNodeValue( aItens[nItens][2] + "/Alias" )	)
					//-------------------------------------------------------------------
					// Coloca rotina no objeto do menu  
					//-------------------------------------------------------------------					
					oMenuItem:AddContent( oXML:XPathGetNodeValue( aItens[nItens][2] +"/Description" ), "E", cRotina  )				
				EndIf
			Next nItens
			
		Next nFolder
	EndIf 

	If oXML <> Nil
		FreeObj( oXML )
	EndIf

Return

//------------------------------------------------------------------------------------
/*/{Protheus.doc} TafMonFormat 

Função que monta a string com a expressão da rotina para execução no menu da área de trabalho    

@sample	TafMonFormat( cBFunction )

@param		cBFunction, caracter, String com nome da rotina a ser utilizada no bloco de execução
				
@return	Nenhum 

@author	Jonatas Martins
@since		05/10/2015
@version	P12.1.6
/*/
//------------------------------------------------------------------------------------
Static Function TafMonFormat( cFunction, cRotName, uOperation, cAlias )

Local cExpRot			:= ""

Default cFunction		:= ""
Default cRotName		:= ""
Default uOperation		:= ""
Default cAlias			:= ""

If !Empty( cFunction )
	If Len(uOperation) > 1 .Or. cRotName $ "(|)"
		uOperation	:= ""
		cRotName	:= "" 
	EndIf  
	cExpRot := "CRMA290RFun({|| " + cFunction + " }, '" + cRotName + "', " + uOperation + ", '" + cAlias + "' )"
EndIf
	
Return( cExpRot )

//---------------------------------------------------------------------------
/*/{Protheus.doc} TAFMonWG

Cria Widget 

@sample	TAFMonWG( ooPanel, cAliasEnt, cFonte, nViewIni, nChartIni, nType )        

@param		oPanel		,Objeto 	,Objeto onde será montada a GRID
			cAliasEnt	,Caracter	,Entidade para qual sera montada a grid
			cFonte		,Caracter	,Fonte responsavel pelo Widget.
			nViewIni	,Numerico	,Numero da Visao inicial
			nchartIni	,Numerico	,Numero do Grafico inicial
			nType		,Numerico	,Tipo 1=Tabela -> MODE_BROWSE 2=Grafico -> MODE_VIEW_CHART

@return	oWidget 	,Objeto 	,Widget1

@author	Thiago Tavares
@since		02/05/2014
@version	P12
/*/
//---------------------------------------------------------------------------
Static Function TAFMonWG(oPanel, cAliasEnt, cFonte)

	Local aCampos		:= {}
	Local aHeaderT		:= {}
	Local cTitle		:= ""
	Local aArea        	:= GetArea()
	Local nX			:= 1
	Local oMBrowse		:= Nil

	Default cAliasEnt	:= ""
	Default cFonte		:= ""
	Default oPanel		:= Nil

	aCampos:= {	{STR0005	, "XEVENTO"	, "C" ,"@!"				,1, 080	, 0	},; //"Evento"
					{STR0019	, "REGVALID"	, "N" ,"@E 9999999999"	,0, 010	, 0 },; //"Pré-Validado" 
					{STR0006	, "REGNPROC"	, "N" ,"@E 9999999999"	,0, 010	, 0 },; //"Não processados" 
					{STR0009	, "REGSRET"	, "N" ,"@E 9999999999"	,0, 010	, 0 },; //"Sem retorno"  
					{STR0010	, "REGINCOS"	, "N" ,"@E 9999999999"	,0, 010	, 0 },; //"Inconsistente" 
					{STR0011	, "REGCONST"	, "N" ,"@E 9999999999"	,0, 010	, 0 },; //"Consistente"
					{STR0012	, "TOTAL"		, "N" ,"@E 9999999999"	,0, 010	, 0 } } //"Total de Registros"

	If  cFonte == "WDGT01"
		cTitle := STR0013 //"Eventos de Tabela"
	ElseIf cFonte == "WDGT02"
		cTitle := STR0014 //"Eventos Periódicos"
	ElseIf cFonte == "WDGT03"
		cTitle := STR0015 //"Evento Não Periódicos"
	EndIf		


	If !Empty( cAliasEnt )
				
		aRotina := Nil
		
		DbSelectArea(cAliasEnt)
		
		//Permite criar widget do tipo browse sem as visões.
		aRotina	:= FwLoadMenuDef( 'TAFMONREI' )
		
		/*+--------------------------+
	    | Cria colunas para o Browse |
	    +----------------------------+*/
		For nX := 1 to Len( aCampos )
			
			aAdd( aHeaderT, FWBrwColumn():New() )
			
			aHeaderT[nX]:SetData( &( "{ || (cAliasEnt)->" + aCampos[nX][2] + " }" ) )

			aHeaderT[nX]:SetTitle( aCampos[nX][1] )
			aHeaderT[nX]:SetSize( aCampos[nX][6] )
			aHeaderT[nX]:SetType( aCampos[nX][3] )
			aHeaderT[nX]:SetDecimal( 0 )
			aHeaderT[nX]:SetPicture( aCampos[nX][4] )
			aHeaderT[nX]:SetAlign( aCampos[nX][5] )
			
		Next nX

		oMBrowse := FWMBrowse():New()
	    oMBrowse:SetAlias( cAliasEnt )
	    oMBrowse:SetColumns( aHeaderT )
	    oMBrowse:SetDescription( cTitle )

		oMBrowse:OptionReport(.F.)
		oMBrowse:OptionConfig(.F.)
		oMBrowse:DisableConfig()
		oMBrowse:DisableReport()
		oMBrowse:DisableLocate()
	    oMBrowse:DisableFilter()
	    oMBrowse:DisableDetails()
		
		oMBrowse:Activate(oPanel)
		
	EndIf

	RestArea( aArea )

Return oMBrowse

//--------------------------------------------------------------------
/*/{Protheus.doc} FLoadProf
Lê arquivo de profile e "alimenta" os parâmetros
@author Leonardo Kichitaro
@since 19/04/2018
@version 1.0
@return ${lRetorno}, ${Informa se a rotina foi executada com sucesso}
/*/
//--------------------------------------------------------------------
Static Function FLoadProf()
	Local nJ			as numeric
	Local cBarra 		as char
	Local cUserName		as char
	Local cNomeProf 	as char
	Local aParLoad		as array
	Local aAuxPar		as array
	Local lRetorno		as logical
	Local cJsonProf		as char
	Local aObjProf		as array
	Local cArquivo		as char
	Private cLinha		as char
	
	nJ			:=	0
	cBarra 		:= 	Iif ( IsSrvUnix() , "/" , "\" )
	cUserName	:= __cUserID
	cNomeProf 	:= ""
	aParLoad	:= {}
	aAuxPar		:= {}
	lRetorno	:= .F.
	cJsonProf	:= ""
	aObjProf	:= Nil
	cLinha		:=	""
	cArquivo	:= ""
	
	If !ExistDir ( cBarra + "PROFILE" + cBarra )
		Makedir ( cBarra + "PROFILE" + cBarra )
	EndIf
	
	cNomeProf	:=	FunName() +"_" +cUserName
	cArquivo := cBarra + "PROFILE" + cBarra + Alltrim ( cNomeProf ) + ".PRB" 
	If File (cArquivo)
	
		If FT_FUse (cArquivo ) <> -1
	
			FT_FGoTop ()
			While ( !FT_FEof () )
				cLinha := FT_FReadLn () 
				//aAdd(aParLoad,&(cLinha))
				cJsonProf += cLinha 
				FT_FSkip ()
			Enddo		
			If FT_FUse() != -1
				lRetorno := .T.
			EndIf
			
			// Deserializa a String JSON 
			If FwJsonDeserialize(cJsonProf, @aObjProf)
				If Len(aObjProf) == Len(aParamRei)
					For nJ := 1 To Len(aObjProf)
						If nJ <> 15 .And. nJ <> 14  //filiais e paramTAFKEY não devem ser reaproveitáveis
							aParamRei[nJ] := aObjProf[nJ]
						EndIf
					Next nJ
				Else
					lRetorno := .F.
				EndIf
			Else
				//Apago o arquivo quando não está de acordo para que na proxima execução
				//o sistema recrie corretamente evitando error.log.
				FErase(cArquivo,,.T.)
				lRetorno := .F.
			EndIf
		EndIf
	EndIf
Return (lRetorno)

//--------------------------------------------------------------------
/*/{Protheus.doc} TafTmpTab
Cria tabelas temporarias

@author leonardo.kichitaro
@since 03/05/2016
@param aEvents,array, (Eventos para filtro da query)
@param aIdsSel		->	Array com os Eventos selecionados no monitor
@param aInfoTrab	->  Array de informações do trabalhador
@version 1.0
@return ${nil}
/*/
//--------------------------------------------------------------------
Function TafReiAtu(oTmpTab, cAliasTmp, nTpTab, lOper, cPeriodo)

Local aArea		as array
Local aCampos		as array
Local aRotinas	as array
Local nCount		as Numeric
Local nCount1		as Numeric
Local nCount2		as Numeric
Local nCount3		as Numeric
Local nValid		as Numeric
Local nNProc		as Numeric
Local nSemRet		as Numeric
Local nIncons		as Numeric
Local nConsis		as Numeric
Local nTotal		as Numeric
Local cQry			as char
Local cAliasEvt	as char
Local cEvento		as char

Default lOper		:= .T.
Default cPeriodo	:= TafPeReinf()

aArea	:= GetArea()

aCampos	:= {	{"XEVENTO"		, "C" , 080, 0, .T. },; //EVENTO
					{"REGVALID"	, "N" , 010, 0, .T. },; //VALIDADO
					{"REGNPROC"	, "N" , 010, 0, .T. },; //NÃO PROCESSADO
					{"REGSRET"	  	, "N" , 010, 0, .T. },; //SEM RETORNO
					{"REGINCOS"	, "N" , 010, 0, .T. },; //INCONSISTENTE
					{"REGCONST"	, "N" , 010, 0, .T. },; //CONSISTENTE
					{"TOTAL"		, "N" , 010, 0, .T. },; //TOTAL
					{"CODEVEN"		, "C" , 006, 0, .T. } } //CODIGO EVENTO

nCount		:= 0
nCount1		:= 0
nCount2		:= 0
nCount3		:= 0
nValid		:= 0	
nNProc		:= 0
nSemRet		:= 0
nIncons		:= 0
nConsis		:= 0
nTotal		:= 0
cQry		:= ""
cAliasEvt	:= ""
cEvento		:= ""
aRotinas	:= {}

If lOper
	oTmpTab := FWTemporaryTable():New(cAliasTmp)
	oTmpTab:SetFields( aCampos )
	oTmpTab:AddIndex("1", {"CODEVEN"})
	oTmpTab:Create()
EndIf

If nTpTab == 1
	cEvento := "R-1000|R-1070"
Elseif nTpTab == 2
	cEvento := "R-2010|R-2020|R-2030|R-2040|R-2050|R-2060|R-2099"
Else
	cEvento := "R-2098|R-3010|R-9000"
EndIf

DbSelectArea("T9B")
DbSetOrder(2)
DbGoTop()
While !T9B->(Eof())

	If T9B->T9B_CODIGO $ cEvento
		If TAFAlsInDic("V1O") .Or. T9B->T9B_CODIGO $ "R-1000|R-1070|R-2010|R-2020|R-2030|R-2040|R-2050|R-2060|R-2099|R-2098|R-3010|R-9000|"
			//Chamar aqui a rotina de consulta das tabelas
			aRotinas  := TAFRotinas( T9B->T9B_CODIGO, 4, .F., 5 )
			
			If !Empty(aRotinas)
				cAliasEvt := aRotinas[3] // alias
				cCpoPer	:= cAliasEvt+"_PERAPU"
	
				cQry := "SELECT COUNT(*) QUANT "
				cQry += "      , "   + cAliasEvt + "_STATUS XSTATUS "
				cQry += " FROM "     + RetSqlName( cAliasEvt ) + " " + cAliasEvt + " "
				cQry += " WHERE "    + cAliasEvt + "." + cAliasEvt + "_FILIAL = '" + xFilial(cAliasEvt) + "' "
				cQry += " AND " + cAliasEvt + "." + cAliasEvt + "_ATIVO = '1' "	
				
				If "R-1000" $ AllTrim( cEvento ) .and. cAliasEvt == 'T9U' // exclusivo para o R-1000
					cQry += " AND " + cAliasEvt + "." + cAliasEvt + "_NRINSC = '" + SM0->M0_CGC +"' "
				EndIf
	
				If TafColumnPos( cCpoPer ) .And. !Empty( cPeriodo ) .And. !( T9B->T9B_CODIGO $ "R-3010" )
					cQry 	+= " AND "+cCpoPer+" = '"+cPeriodo+"'"
				EndIf
	
				cQry += " AND "      + cAliasEvt + ".D_E_L_E_T_ = ''" 
				cQry += " GROUP BY " + cAliasEvt + "." + cAliasEvt + "_STATUS "
				
				cQry := ChangeQuery( cQry )
				
				TCQuery cQry New Alias "AliasTot"
				
				While AliasTot->( !Eof() )
					
					If Empty(AliasTot->XSTATUS) 	 //Não Processado 
						nNProc 	:= AliasTot->QUANT
						nTotal		+= AliasTot->QUANT 
					ElseIf AliasTot->XSTATUS $ '2|6' //Sem Retorno - Aguardando Retorno
						nSemRet	:= AliasTot->QUANT
						nTotal		+= AliasTot->QUANT 
					ElseIf AliasTot->XSTATUS == '3'  //Inconsistente
						nIncons	:= AliasTot->QUANT
						nTotal		+= AliasTot->QUANT 
					ElseIf AliasTot->XSTATUS == '4'  //Consistente
						nConsis	:= AliasTot->QUANT
						nTotal		+= AliasTot->QUANT 
					ElseIf AliasTot->XSTATUS == '0'  //Validado
						nValid 	:= AliasTot->QUANT
						nTotal		+= AliasTot->QUANT 					
					EndIf			
					
					AliasTot->( DBSkip() )
				EndDo
				
				AliasTot->( DBCloseArea() )
			EndIf
		EndIf
	EndIf

	If !lOper
		If !(cAliasTmp)->(dbSeek(T9B->T9B_CODIGO))
			T9B->(DbSkip())
			Loop
		EndIf
	EndIf

	If nTpTab == 1 .And. T9B->T9B_CODIGO $ "R-1000|R-1070"
		RecLock(cAliasTmp, lOper)
		(cAliasTmp)->XEVENTO	:= T9B->T9B_CODIGO + " - " + T9B->T9B_DESCRI
		(cAliasTmp)->CODEVEN	:= T9B->T9B_CODIGO
		(cAliasTmp)->REGVALID	:= nValid
		(cAliasTmp)->REGNPROC	:= nNProc
		(cAliasTmp)->REGSRET	:= nSemRet
		(cAliasTmp)->REGINCOS	:= nIncons
		(cAliasTmp)->REGCONST	:= nConsis
		(cAliasTmp)->TOTAL		:= nTotal
		(cAliasTmp)->( msUnlock() )

		nCount1++
	
	ElseIf nTpTab == 2 .And. T9B->T9B_CODIGO $ "R-2010|R-2020|R-2030|R-2040|R-2050|R-2060|R-2099"
		RecLock(cAliasTmp, lOper)
		(cAliasTmp)->XEVENTO	:= T9B->T9B_CODIGO + " - " + T9B->T9B_DESCRI
		(cAliasTmp)->CODEVEN	:= T9B->T9B_CODIGO
		(cAliasTmp)->REGVALID	:= nValid
		(cAliasTmp)->REGNPROC	:= nNProc
		(cAliasTmp)->REGSRET	:= nSemRet
		(cAliasTmp)->REGINCOS	:= nIncons
		(cAliasTmp)->REGCONST	:= nConsis
		(cAliasTmp)->TOTAL		:= nTotal
		(cAliasTmp)->( msUnlock() )

		nCount2++
	ElseIf nTpTab == 3 .And. T9B->T9B_CODIGO $ "R-2098|R-3010|R-9000"
		RecLock(cAliasTmp, lOper)
		(cAliasTmp)->XEVENTO	:= T9B->T9B_CODIGO + " - " + T9B->T9B_DESCRI
		(cAliasTmp)->CODEVEN	:= T9B->T9B_CODIGO
		(cAliasTmp)->REGVALID	:= nValid
		(cAliasTmp)->REGNPROC	:= nNProc
		(cAliasTmp)->REGSRET	:= nSemRet
		(cAliasTmp)->REGINCOS	:= nIncons
		(cAliasTmp)->REGCONST	:= nConsis
		(cAliasTmp)->TOTAL		:= nTotal
		(cAliasTmp)->( msUnlock() )

		nCount3++
	EndIf

	nCount++
	nValid	:= 0
	nNProc 	:= 0
	nSemRet	:= 0
	nIncons := 0
	nConsis := 0
	nTotal	:= 0
	
	T9B->(DbSkip())
EndDo

RestArea( aArea )

Return Nil 

Function TafMonStat()
REturn (__aWidgets)

//--------------------------------------------------------------------
/*/{Protheus.doc} VldPer
Valida periodo informado ao entrar no Monitor da Reinf
@author silva.carlos
@since 26/10/2018
@version 1.0
@return ${lRetorno}, ${Informa se a rotina foi executada com sucesso}
/*/
//--------------------------------------------------------------------
Static Function VldPer(cPeriodo)
Local lRet as logical
Local dPeriodo as date
dPeriodo := stod(right(cPeriodo,4)+left(cPeriodo,2)+'01')

lRet := at(' ',cPeriodo) = 0 .and. len(StrTran(cPeriodo,'-','')) = 6 .and. !empty( dPeriodo ) 

if !lRet
	Aviso(STR0028,STR0029,{'OK'},2) //STR0028 #"Aviso"  STR0029 #O Período de apuração deve ser informado no formato MM-AAAA.
endif

return lRet
