#include "totvs.ch"
#include "fwmvcdef.ch"
#include "TAFA639.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA639
Cadastro MVC - DeRE - Cadastro de Informações do Contribuinte

@author Carlos Pister
@since 03/03/2026
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA639()
Local oBrw := FWmBrowse():New()

If TAFAlsInDic( "T7T" )
	oBrw:SetDescription( STR0001 ) //Cadastro de Informações do Contribuinte
	oBrw:SetAlias( 'T7T')
	oBrw:SetMenuDef( 'TAFA639' )
	oBrw:SetFilterDefault( "T7T_ATIVO == '1' .Or. (T7T_EVENTO == 'E' .And. T7T_STATUS == '4' .And. T7T_ATIVO == '2')" ) //Filtro para que apenas os registros ativos sejam exibidos ( 1=Ativo, 2=Inativo )

	oBrw:AddLegend( "T7T_EVENTO == 'I' ", "GREEN" , STR0002 ) //"Registro Incluído"
	oBrw:AddLegend( "T7T_EVENTO == 'A' ", "YELLOW", STR0003 ) //"Registro Alterado"
	oBrw:AddLegend( "T7T_EVENTO == 'E' .And. T7T_STATUS <> '4' ", "RED"   , STR0004 ) //"Registro excluído não transmitido"
	//Importante Monitoramento de Transmissão Inativa quando exclusão protocolada.
	oBrw:AddLegend( "T7T_EVENTO == 'E' .And. T7T_STATUS == '4' .And. T7T_ATIVO == '2' ", "BLACK"   , STR0005 ) //"Registro excluído transmitido"
	
	oBrw:Activate()
else
	Aviso(STR0006,TafAmbInvMsg(),{STR0007},3) //##"Dicionário Incompatível" ##"Encerrar"
endif

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Carlos Pister
@since 03/03/2026
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aFuncao := {}
Local aRotina := {}

Aadd( aFuncao, {STR0059	, "TAF639Xml" } ) //"Gerar XML"
Aadd( aFuncao, {STR0060	, "TAF639MExc"} ) //"Mot. Exclusão"

aRotina	:=	xFunMnuTAF( "TAFA639", , aFuncao )

Return( aRotina )

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@obs NOSONAR CA2015: O bloco bCommit ({|oModel| SaveModel(oModel)}) é passado diretamente
no 4º parâmetro de MPFormModel():New() por decisão técnica deliberada no projeto do TAF.

Justificativa:
  - Este fonte é exclusivo do TAF (SIGATAF) e não possui localização por país,
    nem está sujeito a manutenção por outros módulos ou equipes externas.
  - O mecanismo FWModelEvent/InstallEvent destina-se a cenários onde localizações
    ou módulos distintos precisam encadear eventos sem conflito. Esse cenário
    não se aplica aqui.
  - A lógica de gravação (SaveModel) é autocontida neste fonte e não há
    previsão de versões A/B/C ou desvios por país.

Impacto aceito: InstallEvent não pode ser utilizado neste modelo.
Não há risco funcional dado o escopo restrito do fonte.

@author Carlos Pister
@since 03/03/2026
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oModel    as object
Local oStruT7T	as object
Local aGrupos   as array
Local nI        as numeric

oModel    := MPFormModel():New( "TAFA639", ,{|oModel| ValidModel(oModel)}, { |oModel| SaveModel( oModel ) } )
oStruT7T  := FWFormStruct( 1, "T7T" )
aGrupos   := {{"'1'", "FIN"}, {"'2'", "ASS"}, {"'3'", "CON"}, {"'4'", "UF"}}
nI := 0

oModel:AddFields( "MODEL_T7T",, oStruT7T )
oModel:SetPrimaryKey( {"T7T_FILIAL","T7T_ID","T7T_VERSAO","T7T_ATIVO"} )

For nI := 1 to Len( aGrupos )
    AddModelGr( @oModel, aGrupos[nI] )
Next nI

oModel:SetDescription(STR0035) //"DeRE - Informações do Contribuinte"

Return oModel 

//-------------------------------------------------------------------
/*/{Protheus.doc} AddModelGr
Funcao de inclusao dos grids de cada grupo de atividades

@param oModel, Object, Modelo MVC passado por referencia
@param aGrupo, Array,  { cId, cSufixo } identificando o grupo a adicionar
@return Nil

@author Carlos Pister
@since 03/03/2026
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function AddModelGr( oModel, aGrupo )

Local oStruT7U	as object
Local oStruT7V	as object

oStruT7U	:=	FWFormStruct( 1, "T7U" )
oStruT7V	:=	FWFormStruct( 1, "T7V" )

If "4" $ aGrupo[1]
	oModel:AddGrid( "MODEL_T7V", "MODEL_T7T", oStruT7V )
	oModel:GetModel( "MODEL_T7V" ):SetOptional( .T. )
	oModel:GetModel( "MODEL_T7V" ):SetUniqueLine( { "T7V_ATIVO", "T7V_CODUFC" } )
	oModel:SetRelation( "MODEL_T7V", { { "T7V_FILIAL", 'xFilial( "T7V" )' }, { "T7V_ID", "T7T_ID" }, { "T7V_VERSAO", "T7T_VERSAO" }, { "T7V_ATIVO", "T7T_ATIVO" } }, T7V->( IndexKey( 2 ) ) )
Else
	oStruT7U:SetProperty( "T7U_TPATIV", MODEL_FIELD_INIT, { |oModel| StrTran(aGrupo[1],"'","") } )
	oStruT7U:SetProperty( "T7U_TPATIV", MODEL_FIELD_VALID, { || Pertence("1239") } )
	oStruT7U:SetProperty( "T7U_CODATI", MODEL_FIELD_VALID, { || Vazio() .Or. ExistCpo("T7P", StrTran(aGrupo[1],"'","") + M->T7U_CODATI, 2) } )

	oModel:AddGrid( "MODEL_T7U_"+ aGrupo[2], "MODEL_T7T", oStruT7U, { |oModelGrid, nLine, cAction, cField, xValNew, xValOld| PutModel( "MODEL_T7U_" + aGrupo[2], cField ) }, { |oModelGrid, nLine| VldLinGrid(oModel, oModelGrid, nLine )} )
	oModel:GetModel( "MODEL_T7U_"+ aGrupo[2] ):SetOptional( .T. )
	oModel:GetModel( "MODEL_T7U_"+ aGrupo[2] ):SetUniqueLine( { "T7U_TPATIV", "T7U_CODATI", "T7U_ATIVO" } ) //T7U_FILIAL+T7U_ID+T7U_VERSAO+T7U_IDCDAT+T7U_TPATIV+T7U_CODATI+T7U_ATIVO
	oModel:GetModel( "MODEL_T7U_"+ aGrupo[2] ):SetLoadFilter( { { "T7U_TPATIV",  aGrupo[1]  } } )
	oModel:SetRelation( "MODEL_T7U_"+ aGrupo[2], { { "T7U_FILIAL", 'xFilial( "T7U" )' }, { "T7U_ID", "T7T_ID" }, { "T7U_VERSAO", "T7T_VERSAO" }, { "T7U_ATIVO", "T7T_ATIVO" } }, T7U->( IndexKey( 3 ) ) )
EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Carlos Pister
@since 03/03/2026
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oModel    as object
Local oView     as object
Local oStruT7T	as object
Local aGrupos   as array
Local nI        as numeric

oModel    := FwLoadModel( "TAFA639" )
oView     := FwFormView():New()
oStruT7T  := FwFormStruct( 2, "T7T" )
aGrupos   := {{"'1'", "FIN",STR0061}, {"'2'", "ASS",STR0062}, {"'3'", "CON",STR0063}, {"'4'", "UF",STR0064}} //"Financeiros"#"Assistência à Saúde"#"Concursos de Prognósticos"#"Unidades Federativas"
nI        := 0

oView:SetModel( oModel )

oView:AddField( "VIEW_T7T", oStruT7T, "MODEL_T7T" )
oView:EnableTitleView( "VIEW_T7T", STR0008 ) //Informações do Contribuinte

oStruT7T:SetProperty( 'T7T_RECIBO', MVC_VIEW_TITULO ,STR0009 ) //"Nº Recibo"
oStruT7T:SetProperty( 'T7T_MOTEXC', MVC_VIEW_TITULO ,STR0040 ) //"Motivo da Exclusão"
oStruT7T:SetProperty( 'T7T_NRPROC', MVC_VIEW_TITULO ,STR0041 ) //"Número do Processo"
oStruT7T:SetProperty( 'T7T_MSGRET', MVC_VIEW_TITULO ,STR0054 ) //"Número do Processo"

oView:CreateHorizontalBox("PAINEL_PRINCIPAL",50)
oView:CreateFolder("FOLDER_PRINCIPAL","PAINEL_PRINCIPAL")

oView:CreateHorizontalBox("PAINEL_INFERIOR",50)
oView:CreateFolder("FOLDER_INFERIOR","PAINEL_INFERIOR")

oView:SetOwnerView( "VIEW_T7T", "PAINEL_PRINCIPAL" )

For nI := 1 to Len( aGrupos )
    AddViewItem( @oView, aGrupos[nI] )
Next nI

oStruT7T:RemoveField( "T7T_ID"  )
oStruT7T:RemoveField( "T7T_ATIVO"  )
oStruT7T:RemoveField( "T7T_EVENTO" )
oStruT7T:RemoveField( "T7T_VERSAO" )
oStruT7T:RemoveField( "T7T_STATUS" )
oStruT7T:RemoveField( "T7T_VERANT" )
oStruT7T:RemoveField( "T7T_XMLID"  )
oStruT7T:RemoveField( "T7T_PROTPN" )
oStruT7T:RemoveField( "T7T_PROTUL" )
If TAFColumnPos( "T7T_RECANT" )  //Adicionado pos-dicionario
    oStruT7T:RemoveField( "T7T_RECANT" )
EndIf

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} AddViewItem
Funcao de inclusao dos itens da view de cada grupo de atividades

@param oView,   Object, View MVC passada por referencia
@param aGrupos, Array,  { cId, cSufixo, cTitulo } identificando o item a adicionar
@return Nil

@author Carlos Pister
@since 03/03/2026
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function AddViewItem( oView, aGrupos )

Local oStruT7U	as object
Local oStruT7V	as object

oStruT7U	:=	FwFormStruct( 2, "T7U" )
oStruT7V	:=	FwFormStruct( 2, "T7V" )

If "4" $ aGrupos[1]
	oView:AddGrid( "VIEW_T7V", oStruT7V, "MODEL_T7V" )
	oView:EnableTitleView( "VIEW_T7V", aGrupos[3] ) 
	oView:AddSheet("FOLDER_INFERIOR","ABA_" + aGrupos[2] , STR0042) //"UFs Credenciadoras "

    oView:CreateHorizontalBox("PAINEL_T7V_"+ aGrupos[2],100,,,"FOLDER_INFERIOR","ABA_" + aGrupos[2]) 
	oView:SetOwnerView( "VIEW_T7V", "PAINEL_T7V_"+ aGrupos[2] )

	oStruT7V:RemoveField( "T7V_ID" )
	oStruT7V:RemoveField( "T7V_VERSAO" )
	oStruT7V:RemoveField( "T7V_ATIVO" )
Else
    oView:AddGrid( "VIEW_T7U_"+ aGrupos[2], oStruT7U, "MODEL_T7U_" + aGrupos[2] )
    oView:EnableTitleView( "VIEW_T7U_"+ aGrupos[2], aGrupos[3] )

	oView:AddSheet("FOLDER_INFERIOR","ABA_" + aGrupos[2] , STR0011 + aGrupos[3]) //"Regimes Específicos Serviços "
	oView:CreateHorizontalBox("PAINEL_T7U_"+ aGrupos[2],100,,,"FOLDER_INFERIOR","ABA_" + aGrupos[2]) 
	oView:SetOwnerView( "VIEW_T7U_"+ aGrupos[2], "PAINEL_T7U_"+ aGrupos[2] )
EndIf

oStruT7U:RemoveField( "T7U_ID" )
oStruT7U:RemoveField( "T7U_TPATIV" )
oStruT7U:RemoveField( "T7U_IDCDAT" )
oStruT7U:RemoveField( "T7U_ATIVO" )

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao de gravacao dos dados, chamada no final, no momento da
confirmacao do modelo
                                                                                                                               
@param  oModel -> Modelo de dados

@return .T.

@author Carlos Pister
@since 03/03/2026
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SaveModel( oModel )

Local cVerAnt		as character
Local cProtocolo	as character
Local cRecibo       as character
Local cEvento		as character
Local cVersao		as character
Local cChvRegAnt	as character
Local nOperation	as numeric
Local nT7T          as numeric
Local nT7U	        as numeric
Local nT7V          as numeric
Local nI        	as numeric
Local nX			as numeric
Local aGrava		as array
Local aGravaT7U		as array
Local aGrupoT7U     as array
Local aGravaT7V		as array
Local aGrupos   	as array
Local oModelT7T		as object
Local lRetorno		as logical
Local lExibirEx     as logical
Local oModelT7V 	as object

cVerAnt		:= ""
cProtocolo	:= ""
cRecibo     := ""
cEvento		:= ""
cVersao		:= ""
cChvRegAnt	:= ""
nOperation	:= oModel:GetOperation()
nT7T		:= 0	 
nT7U		:= 0
nT7V		:= 0
nI        	:= 0
nX			:= 0
aGrava		:= {}
aGravaT7U	:= {}
aGrupoT7U   := {}
aGravaT7V	:= {}
aGrupos   	:= {"FIN", "ASS", "CON"}
oModelT7T	:= Nil
lRetorno	:= .T.
lExibirEx 	:= .F.
oModelT7V   := Nil

if nOperation == MODEL_OPERATION_UPDATE
	if T7T->T7T_EVENTO == "E" .And. AllTrim(T7T->T7T_STATUS) $ "2|4|9"
		TAFMsgVldOp(oModel,"7") //"Registro não pode ser alterado, pois o evento de exclusão já se encontra na base do RET"
		lRetorno := .F.
	endif
elseif nOperation == MODEL_OPERATION_DELETE
	if T7T->T7T_EVENTO == "E" .And. AllTrim(T7T->T7T_STATUS) $ "2|4|9"
		TAFMsgVldOp(oModel,"4") //"Não é possível alterar/excluir evento de exclusão já processado"
		lRetorno := .F.
	endif
endif

if lRetorno

	Begin Transaction

		If nOperation == MODEL_OPERATION_INSERT
			
			oModel:LoadValue( "MODEL_T7T", "T7T_VERSAO", xFunGetVer() )

			FwFormCommit( oModel )

		ElseIf nOperation == MODEL_OPERATION_UPDATE .or. nOperation == MODEL_OPERATION_DELETE

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Seek para posicionar no registro antes de realizar as validacoes,³
			//³visto que quando nao esta posicionado nao eh possivel analisar   ³
			//³os campos nao usados como _STATUS                                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			T7T->( DbSetOrder( 3 ) )
			If T7T->( MsSeek( xFilial( 'T7T' ) + FwFldGet('T7T_ID') + '1' ) )

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Se o registro ja foi transmitido³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If T7T->T7T_STATUS == "4"

					oModelT7T := oModel:GetModel( "MODEL_T7T" )
					oModelT7V := oModel:GetModel( "MODEL_T7V" )

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Busco a versao anterior do registro para gravacao do rastro³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					cVerAnt    := oModelT7T:GetValue( "T7T_VERSAO" )
					cProtocolo := oModelT7T:GetValue( "T7T_PROTUL" )
					cRecibo    := oModelT7T:GetValue( "T7T_RECIBO" )
					cEvento    := oModelT7T:GetValue( "T7T_EVENTO" )

					If !(nOperation == MODEL_OPERATION_DELETE .And. cEvento == "E")

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Neste momento eu gravo as informacoes que foram carregadas na tela³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						For nT7T := 1 to Len( oModelT7T:aDataModel[ 1 ] )
							aAdd( aGrava, { oModelT7T:aDataModel[ 1, nT7T, 1 ], oModelT7T:aDataModel[ 1, nT7T, 2 ] } )
						Next nT7T

						For nI := 1 To Len( aGrupos )
							If !oModel:GetModel( 'MODEL_T7U_' + aGrupos[nI] ):IsEmpty()
								For nT7U := 1 To oModel:GetModel( 'MODEL_T7U_' + aGrupos[nI] ):Length()
									oModel:GetModel( 'MODEL_T7U_' + aGrupos[nI] ):GoLine(nT7U)
									If !oModel:GetModel( 'MODEL_T7U_' + aGrupos[nI] ):IsDeleted()
										aAdd (aGrupoT7U ,{oModel:GetModel( 'MODEL_T7U_' + aGrupos[nI] ):GetValue('T7U_REGIME');
														, oModel:GetModel( 'MODEL_T7U_' + aGrupos[nI] ):GetValue('T7U_IDCDAT');
														, oModel:GetModel( 'MODEL_T7U_' + aGrupos[nI] ):GetValue('T7U_TPATIV');
														, oModel:GetModel( 'MODEL_T7U_' + aGrupos[nI] ):GetValue('T7U_CODATI')} )
									EndIf
								Next nT7U
								aAdd(aGravaT7U, aGrupoT7U)
								aGrupoT7U := {}
							Else
								aAdd(aGravaT7U, {})
							EndIf
						Next nI

						If !oModel:GetModel( 'MODEL_T7V' ):IsEmpty()
							For nT7V := 1 To oModel:GetModel( 'MODEL_T7V' ):Length()
								oModel:GetModel( 'MODEL_T7V' ):GoLine(nT7V)
								If !oModel:GetModel( 'MODEL_T7V' ):IsDeleted()
									aAdd (aGravaT7V ,{oModelT7V:GetValue('T7V_CODUFC')} )
								EndIf
							Next nT7V
						EndIf

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Seto o campo como Inativo e gravo a versao do novo registro³
						//³no registro anterior                                       ³
						//|                                                           |
						//|ATENCAO -> A alteracao destes campos deve sempre estar     |
						//|abaixo do Loop do For, pois devem substituir as informacoes|
						//|que foram armazenadas no Loop acima                        |
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						FAltRegAnt( 'T7T', '2' ,.F.,"","","" )

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Neste momento eu preciso setar a operacao do model como Inclusao³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						oModel:DeActivate()
						oModel:SetOperation( 3 )
						oModel:Activate()

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Neste momento eu realizo a inclusao do novo registro ja³
						//³contemplando as informacoes alteradas pelo usuario     ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						For nT7T := 1 to Len( aGrava )
							oModel:LoadValue( "MODEL_T7T", aGrava[ nT7T, 1 ], aGrava[ nT7T, 2 ] )
						Next nT7T

						For nX := 1 to Len( aGrupos )
							For nT7U := 1 To Len( aGravaT7U[nX] )
								If nT7U > 1
									oModel:GetModel( 'MODEL_T7U_' + aGrupos[nX] ):AddLine()
								EndIf

								oModel:LoadValue( "MODEL_T7U_" + aGrupos[nX], "T7U_REGIME", aGravaT7U[nX][nT7U][1] )
								oModel:LoadValue( "MODEL_T7U_" + aGrupos[nX], "T7U_IDCDAT", aGravaT7U[nX][nT7U][2] )
								oModel:LoadValue( "MODEL_T7U_" + aGrupos[nX], "T7U_TPATIV", aGravaT7U[nX][nT7U][3] )
								oModel:LoadValue( "MODEL_T7U_" + aGrupos[nX], "T7U_CODATI", aGravaT7U[nX][nT7U][4] )

							Next nT7U
						Next nX

						For nT7V := 1 To Len( aGravaT7V )
							If nT7V > 1
								oModel:GetModel( 'MODEL_T7V' ):AddLine()
							EndIf
							oModel:LoadValue( "MODEL_T7V", "T7V_CODUFC", aGravaT7V[nT7V][1] )
						Next nT7V
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Busco a versao que sera gravada³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						cVersao := xFunGetVer()

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//|ATENCAO -> A alteracao destes campos deve sempre estar     |
						//|abaixo do Loop do For, pois devem substituir as informacoes|
						//|que foram armazenadas no Loop acima                        |
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						oModel:LoadValue( "MODEL_T7T", "T7T_VERSAO", cVersao )
						oModel:LoadValue( "MODEL_T7T", "T7T_VERANT", cVerAnt )
						oModel:LoadValue( "MODEL_T7T", "T7T_PROTPN", cProtocolo )
						oModel:LoadValue( "MODEL_T7T", "T7T_RECANT", cRecibo )
						oModel:LoadValue( "MODEL_T7T", "T7T_PROTUL", "" )
						oModel:LoadValue( "MODEL_T7T", "T7T_RECIBO", "" )
						oModel:LoadValue( "MODEL_T7T", "T7T_STATUS", "" )

						If nOperation == MODEL_OPERATION_DELETE
							oModel:LoadValue( 'MODEL_T7T', 'T7T_EVENTO', "E" )
							lExibirEx := .T.
						Else
							oModel:LoadValue( 'MODEL_T7T', 'T7T_EVENTO', "A" )
						EndIf

						FwFormCommit( oModel )
					EndIf

				Elseif T7T->T7T_STATUS == "1" //1 AGUARDANDO RETORNO
					//Não é possível alterar um registro com aguardando validação
					TAFMsgVldOp(oModel,"2")
					lRetorno := .F.

				Else

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Caso o registro nao tenha sido transmitido ainda, gravo sua chave³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					cChvRegAnt := T7T->( T7T_ID + T7T_VERANT )

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³No caso de um evento de Exclusao deve-se perguntar ao usuario se ele realmente deseja realizar a exclusao.³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If T7T->T7T_EVENTO == "E"
						If nOperation == MODEL_OPERATION_DELETE
							If Aviso( STR0016, STR0017, { STR0018, STR0019 }, 1 ) == 2 //##"Registro Excluído" ##"O Evento de exclusão não foi transmitido. Deseja realmente exclui-lo ou manter o evento de exclusão para transmissão posterior ?" ##"Excuir" ##"Manter"
									cChvRegAnt := ""
							EndIf
						Else
							oModel:LoadValue( "MODEL_T7T", "T7T_EVENTO", "A" )
						EndIf				
					EndIf

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Executo a operacao escolhida³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If !Empty( cChvRegAnt )

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Funcao responsavel por setar o Status do registro para Branco³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						TAFAltStat( "T7T", " " )

						FwFormCommit( oModel )

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Caso a operacao seja uma exclusao...³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If nOperation == MODEL_OPERATION_DELETE
							//Funcao para setar o registro anterior como Ativo
							TAFRastro( "T7T", 1, cChvRegAnt, .T. , , Nil )
						EndIf

					EndIf
				EndIf
			EndIf

		EndIf

	End Transaction
Endif

if lExibirEx
	MsgInfo(STR0043, STR0044)//"Após confirmar a exclusão é preciso cadastrar o motivo em 'Outras Ações'", "Informações do Contribuinte" //"Informações do Contribuinte"
endif

Return( lRetorno )

//-------------------------------------------------------------------
/*/{Protheus.doc} ValidModel

Funcao que valida os dados do registro posicionado,
verificando se ha incoerencias nas informacoes

@param  oModel, Object, Modelo de dados MVC
@return lRet, Logical, .T. se os dados são válidos, .F. caso contrário

@author Carlos Pister
@since 03/03/2026
@version 1.0
/*/                                                                                                                                          
//-------------------------------------------------------------------
Static Function ValidModel( oModel)

Local oModelT7T as object
Local lRet      as logical

Default oModel := Nil

lRet := .T.	

If !(oModel == Nil)
	oModelT7T := oModel:GetModel( "MODEL_T7T" )
	If !Empty(oModelT7T:GetValue( "T7T_DTINVA" )) .and. !Empty(oModelT7T:GetValue( "T7T_DTFIVA" )) .and. oModelT7T:GetValue( "T7T_DTFIVA" ) < oModelT7T:GetValue( "T7T_DTINVA" )
		Help( ,,STR0020,,STR0021, 1, 0,,,,,,{STR0022} ) // "Atenção"##""Data fim não pode ser anterior à data de início"# "Informe uma data posterior a data de início."
		lRet :=	.F.	
	ElseIF !Empty(oModelT7T:GetValue( "T7T_DTFIVA" )) .and. !Empty(oModelT7T:GetValue( "T7T_DTINVA" )) .and. oModelT7T:GetValue( "T7T_DTINVA" ) == oModelT7T:GetValue( "T7T_DTFIVA" )
		Help( ,,STR0020,,STR0023, 1, 0,,,,,,{STR0022} ) // "Atenção"##""Data início não pode ser posterior à data de fim"# "Informe uma data inferior a data de início."
		lRet :=	.F.
	EndIf
	If lRet .and. !(oModelT7T:GetValue( "T7T_EVENTO" ) == "I") .AND. !(oModelT7T:GetValue( "T7T_DTINVA" ) == T7T->T7T_DTINVA)
		Help( ,,STR0020,,STR0025, 1, 0,,,,,,{STR0026} ) // "Atenção"##"Não é possível a alteração da data de início de validade do evento. " # "Para uma nova data de início de validade, favor inclua um novo registro."
		lRet := .F.	
	EndIf

	If lRet
		lRet := VldVigenc( oModel )
	EndIf

	If lRet .And. !(oModel:GetOperation() == MODEL_OPERATION_DELETE)
		lRet := VldGrid( oModel )
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} VldVigenc
Funcao que valida sobreposicao de periodos de vigencia na inclusao
de um novo registro D-1001. Verifica se ja existe registro ativo
com periodo que se sobreponha ao informado (T7T_DTINVA/T7T_DTFIVA).

@param  oModel -> Modelo de dados

@return lRet   -> .T. se nao ha sobreposicao, .F. se ha conflito

@author Jose Felipe
@since 27/08/2026
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function VldVigenc( oModel )

Local oModelT7T  as object
Local cFilT7T    as character
Local cDtIni     as character
Local cDtFim     as character
Local cIdAtual   as character
Local cQuery     as character
Local cAlias     as character
Local oExec      as object
Local lRet       as logical
Local lSemFimDt  as logical
Local nParam     as numeric
Local nOperation as numeric

oModelT7T  := oModel:GetModel( "MODEL_T7T" )
lRet       := .T.
nOperation := oModel:GetOperation()

If nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE

	cFilT7T   := xFilial( "T7T" )
	cIdAtual  := AllTrim( oModelT7T:GetValue( "T7T_ID" ) )
	cDtIni    := DToS( oModelT7T:GetValue( "T7T_DTINVA" ) )
	cDtFim    := DToS( oModelT7T:GetValue( "T7T_DTFIVA" ) )
	lSemFimDt := Empty( cDtFim )

	If !Empty( cDtIni )

		cQuery := " SELECT COUNT(T7T.T7T_ID) QTD"
		cQuery += " FROM "  + RetSqlName( "T7T" ) + " T7T"
		cQuery += " WHERE T7T.T7T_FILIAL = ?"                                         // param 1
		cQuery += "   AND T7T.T7T_ATIVO  = ?"                                         // param 2
		cQuery += "   AND T7T.D_E_L_E_T_ = ?"                                         // param 3
		cQuery += "   AND T7T.T7T_ID    <> ?"                                         // param 4 (auto-exclusao)
		cQuery += "   AND NOT (T7T.T7T_EVENTO = ? AND T7T.T7T_STATUS IN (?, ?, ?))"   // params 5..8
		cQuery += "   AND ( ? <= T7T.T7T_DTFIVA OR T7T.T7T_DTFIVA = ' ' )"            // param 9

		If !lSemFimDt
			cQuery += "   AND ? >= T7T.T7T_DTINVA"                                    // param 10
		EndIf

		cQuery := ChangeQuery( cQuery )
		nParam := 0

		oExec := FWExecStatement():New( cQuery )
		oExec:SetString( ++nParam, cFilT7T   )   // 1 - filial
		oExec:SetString( ++nParam, "1"       )   // 2 - T7T_ATIVO
		oExec:SetString( ++nParam, " "       )   // 3 - D_E_L_E_T_
		oExec:SetString( ++nParam, cIdAtual  )   // 4 - T7T_ID <> (auto-exclusao)
		oExec:SetString( ++nParam, "E"       )   // 5 - T7T_EVENTO - Exclusao
		oExec:SetString( ++nParam, "2"       )   // 6 - T7T_STATUS - Transmitido
		oExec:SetString( ++nParam, "4"       )   // 7 - T7T_STATUS - Transmitido valido
		oExec:SetString( ++nParam, "9"       )   // 8 - T7T_STATUS - Em processamento
		oExec:SetString( ++nParam, cDtIni    )   // 9 - nova DTINVA vs. T7T_DTFIVA existente

		If !lSemFimDt
			oExec:SetString( ++nParam, cDtFim )  // 10 - nova DTFIVA vs. T7T_DTINVA existente
		EndIf

		cAlias := oExec:OpenAlias()

		If ( cAlias )->QTD > 0
			Help( ,,STR0020,,STR0052, 1, 0,,,,,,{STR0053} ) //"Atenção"#"Existe um período ativo com o intervalo de datas informado" # "Informe um novo intervalo"
			lRet := .F.
		EndIf

		( cAlias )->( DbCloseArea() )
		oExec:Destroy()
		oExec := Nil

	EndIf

EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Taf639Cbox
Funcao que retorna a string de opções para o ComboBox de Regimes Específicos
@author Carlos Pister
@since 03/03/2026
@version 1.0
/*/                                                                                                                                          
//-------------------------------------------------------------------
Function Taf639Cbox(cCampo)

Local cString := ""
Default cCampo := ""

Do Case
	Case cCampo == 'T7T_REGPRI'
		cString := "1="+ STR0012 + ";" //"Regime Específico de Serviços Financeiros"
		cString += "2="+ STR0013 + ";" //"Regime Específico de Plano de Assistência à Saúde"
		cString += "3="+ STR0014 + ";" //"Regime Específico de Concursos de Prognósticos"
		cString += "9="+ STR0015 + ";" //"Normas Gerais de Tributação"
	Case cCampo == 'T7T_MOTEXC'
		cString := "1="+ STR0045 + ";" //"Determinação judicial ou administrativa"
		cString += "2="+ STR0046 + ";" //"Envio indevido (fato inexistente)"
		cString += "3="+ STR0047 + ";" //"Erro na identificação (CNPJ/período incorretos)"
		cString += "9="+ STR0048 + ";" //"Outro"
EndCase

Return cString  

//-------------------------------------------------------------------
/*/{Protheus.doc} Taf639SXB
Funcao que retorna a string de opções para o ComboBox de Regimes Específicos
@author Carlos Pister
@since 03/03/2026
@version 1.0
/*/                                                                                                                                          
//-------------------------------------------------------------------
Function Taf639SXB()

Local cModel		as character
Local oModel		as object
Local oModelEdit	as object
Local cRet			as character
Local cString		as character

cModel		:= GetGlbValue( "cModel" )
oModel		:= FWModelActive()
oModelEdit	:= oModel:GetModel( cModel )
cRet		:= ""
cString     := ""

If !Empty( cModel ) 
	oModelEdit := oModel:GetModel( cModel )
	cRet := oModelEdit:GetValue( "T7U_TPATIV" )
EndIf

cRet := StrTran(cRet,"'","")
cString := "@# T7P->T7P_TPATIV == '" + cRet + "' @#"

Return cString

//-------------------------------------------------------------------
/*/{Protheus.doc} PutModel
Função responsável por alimentar a variavel global cModel com o nome do model em edição no momento
@author Carlos Pister
@since 03/03/2026
@version 1.0
/*/                                                                                                                                          
//-------------------------------------------------------------------
Static Function PutModel( cModel, cField  )

Default cModel := ""
Default cField := ""

If !Empty( cField ) .and. cField $ "|T7U_TPATIV|T7U_CODATI|" 
	PutGlbValue( "cModel" , cModel )
EndIf

Return .T. 

//-------------------------------------------------------------------
/*/{Protheus.doc} VldLinGrid
Função responsável por validar a data de início de validade do evento
@author Carlos Pister
@since 03/03/2026
@version 1.0
/*/                                                                                                                                          
//-------------------------------------------------------------------
Static Function VldLinGrid(oModel, oModelGrid, nLine)

Local oModelT7T as object
Local lRet as logical

Default oModel := Nil
Default oModelGrid := Nil

oModelT7T := oModel:GetModel( "MODEL_T7T" )
lRet := .T.

If !(oModelT7T == Nil .or. oModelGrid == Nil) .and. !oModelGrid:IsDeleted()
	If oModelT7T:GetValue( "T7T_REGPRI" ) == "9" .and. oModelGrid:GetValue( "T7U_REGIME" ) == "1"
		Help( ,,STR0020,,STR0029, 1, 0,,,,,,{STR0030} ) // "Atenção"# "Regime principal de Normas Gerais de Tributação não possui atividades como regime específico." # "Deverão ser vinculados apenas regime secundário."
		lRet := .F.
	ElseIf oModelT7T:GetValue( "T7T_REGPRI" ) == oModelGrid:GetValue( "T7U_TPATIV" ) .and. !( oModelGrid:GetValue( "T7U_REGIME" ) == "1")
		Help( ,,STR0020,,STR0027, 1, 0,,,,,,{STR0028} ) // "Atenção"#"O campo Regime não poder ser vinculado ao regime secundário."# "Informe o campo Regime como Regime Principal."
		lRet := .F.		
	ElseIf !(oModelT7T:GetValue( "T7T_REGPRI" ) == oModelGrid:GetValue( "T7U_TPATIV" )) .and. oModelGrid:GetValue( "T7U_REGIME" ) == "1"
		Help( ,,STR0020,,STR0027, 1, 0,,,,,,{STR0028} ) // "Atenção"# "O campo Regime não poder ser vinculado ao regime secundário."# "Informe o campo Regime como Regime Principal."
		lRet := .F.
	EndIf
EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} VldGrid
Função responsável por validar dados de regime específico para o regime 
principal selecionado 
@author Carlos Pister
@since 03/03/2026
@version 1.0
/*/                                                                                                                                          
//-------------------------------------------------------------------
Static Function VldGrid(oModel)

Local aGrupos   as array
Local lRet 	    as logical
Local nX 	    as numeric
Local oModelT7T as object
Local oModelT7V as object
Local nT7U      as numeric
Local nAteT7U   as numeric
Local nDel      as numeric

Default oModel := Nil

aGrupos   := {"FIN", "ASS", "CON"}
nX 	      := 0
oModelT7T := oModel:GetModel( "MODEL_T7T" )
oModelT7V := oModel:GetModel( "MODEL_T7V" )
lRet 	  := .T.
nT7U	  := 0
nAteT7U   := 0
nDel      := 0

If !(oModel == Nil)
	For nX := 1 to Len( aGrupos )
		If !oModel:GetModel( 'MODEL_T7U_' + aGrupos[nX] ):IsEmpty()
			If ( "3" $ oModel:GetModel( 'MODEL_T7U_' + aGrupos[nX] ):GetValue( "T7U_TPATIV" ) .and. ( oModelT7V == Nil .Or. oModelT7V:IsEmpty() ) ) .or. ;
				( "3" $  oModelT7T:GetValue( "T7T_REGPRI" ) .and. ( oModelT7V == Nil .Or. oModelT7V:IsEmpty() ) )
	            Help( ,,STR0020,,STR0031, 1,0,,,,,,{STR0032}) // "Atenção"#"O registro possui Regime Específico de Concursos Prognósticos."#"Favor cadastrar ao menos uma UF Credenciadora."
	            lRet := .F.
	            exit
			Else
				nAteT7U := oModel:GetModel( 'MODEL_T7U_' + aGrupos[nX] ):Length()
				nDel := 0
				For nT7U := 1 to nAteT7U
					oModel:GetModel( 'MODEL_T7U_' + aGrupos[nX] ):GoLine( nT7U )
					If oModel:GetModel( 'MODEL_T7U_' + aGrupos[nX] ):IsDeleted()
						nDel++
					EndIf
					If nT7U == nAteT7U .and. nDel == nAteT7U
						If oModel:GetModel( 'MODEL_T7U_' + aGrupos[nX] ):GetValue( "T7U_TPATIV" ) == oModelT7T:GetValue( "T7T_REGPRI" )
							Help( ,,STR0020,,STR0033, 1, 0,,,,,,{STR0034} ) // "Atenção"#"O Regime Principal selecionado não possui regime específico cadastrado."#"Favor cadastrar ao menos uma atividade no regime específico para o Regime Principal selecionado."
							lRet := .F.
							exit
						Endif
					EndIf
				Next nT7U
	        EndIf
		ElseIf oModel:GetModel( 'MODEL_T7U_' + aGrupos[nX] ):IsEmpty()
			If oModel:GetModel( 'MODEL_T7U_' + aGrupos[nX] ):GetValue( "T7U_TPATIV" ) == oModelT7T:GetValue( "T7T_REGPRI" ) 
	            Help( ,,STR0020,,STR0033, 1, 0,,,,,,{STR0034} ) // "Atenção"#"Regime"#"O Regime Principal selecionado não possui regime específico cadastrado. Favor cadastrar ao menos uma atividade no regime específico para o Regime Principal selecionado."
	            lRet := .F.
	            exit
	        EndIf
		EndIf
	Next nX
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF639Xml
Gera o XML do evento D-1001 para o registro T7T posicionado
e abre o visualizador de XML via xTafGerXml.

@type    Function
@author  Rafael Leme \ Carlos Pister \ Denis Souza
@since   03/03/2026
@version 1.0
@param cAlias, Character, alias do registro posicionado
@param nRecno, Numeric,   recno do registro posicionado
@param nOpc,   Numeric,   opcao de menu acionada
@param lJob,   Logical,   .T. quando chamado em batch/job
@return Nil
/*/
//-------------------------------------------------------------------
Function TAF639Xml(cAlias,nRecno,nOpc,lJob)

	Local oXml as object
	Local cXML as character

	oXml := Nil
	cXML := ""

	oXml := backoffice.taf.dere.xml.TAFDereXmlEvents():New()

	FWMsgRun(, {|| cXml := oXml:TafDereGetXmlEvent('D-1001', T7T->T7T_ID, T7T->T7T_VERSAO) }, STR0055, STR0056) //"Verificando Registros"#"Aguarde..."

	FWMsgRun(, {|| xTafGerXml(cXML,'1001',,,,,,"D-") } , STR0057, STR0058 ) //"Gerando XML"#"Aguarde alguns minutos."

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF639MExc
Chama a função responsável por exibir tela de Motivo de Exclusão
Permite informar o motivo da exclusão e número do processo
@author Rafael de Paula Leme
@since 17/08/2026
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAF639MExc() 
	
	If T7T->T7T_EVENTO <> 'E'
		MsgInfo(STR0049, STR0050) //"Opção disponível apenas para registros excluídos e não transmitidos." //"Motivo da Exclusão"
	ElseIf T7T->T7T_STATUS == '4'
		MsgInfo(STR0051, STR0050) //"A exclusão desse Cadastro de Informações do Contribuinte já foi transmitida e por isso não pode ser alterada" //"Motivo da Exclusão"
	Else
		MotExc1001('T7T')
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} MotExc1001
Função responsável por exibir tela de Motivo de Exclusão
Permite informar o motivo da exclusão e número do processo
@author Rafael de Paula Leme
@since 17/08/2026
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MotExc1001(cAlias)

Local oDlg        as object
Local oComboMotiv as object
Local oGetNrProc  as object
Local cMotivoExc  as character
Local cNrProcesso as character
Local nOpcao      as numeric
Local aMotivos    as array
Local lConfirma   as logical

oDlg        := Nil
oComboMotiv := Nil
oGetNrProc  := Nil
cMotivoExc  := "1"
cNrProcesso := Space(21)
nOpcao      := 0
aMotivos    := {}
lConfirma   := .F.

// Carrega valores existentes nos campos
If !Empty((cAlias)->&(cAlias + "_MOTEXC"))
	Do Case
		Case (cAlias)->&(cAlias + "_MOTEXC") == "1"
			cMotivoExc := "1-" + STR0065 //"Determinação judicial ou administrativa"
		Case (cAlias)->&(cAlias + "_MOTEXC") == "2"
			cMotivoExc := "2-" + STR0066 //"Envio indevido (fato inexistente)"
		Case (cAlias)->&(cAlias + "_MOTEXC") == "3"
			cMotivoExc := "3-" + STR0067 //"Erro na identificação (CNPJ/período incorretos)"
		Case (cAlias)->&(cAlias + "_MOTEXC") == "9"
			cMotivoExc := "9-" + STR0068 //"Outro"
	EndCase
EndIf

If !Empty((cAlias)->&(cAlias + "_NRPROC"))
	cNrProcesso := PadR((cAlias)->&(cAlias + "_NRPROC"), 21)
EndIf

// Monta array com as opções da combo
aAdd(aMotivos, "1-" + STR0065) //"Determinação judicial ou administrativa"
aAdd(aMotivos, "2-" + STR0066) //"Envio indevido (fato inexistente)"
aAdd(aMotivos, "3-" + STR0067) //"Erro na identificação (CNPJ/período incorretos)"
aAdd(aMotivos, "9-" + STR0068) //"Outro"

// Define a dialog
Define MsDialog oDlg Title STR0069 From 000,000 To 200,400 Pixel //"Motivo da Exclusão"

	@ 015,010 Say STR0069 + ":" Size 060,008 Of oDlg Pixel //"Motivo da Exclusão"
	@ 013,070 ComboBox oComboMotiv Var cMotivoExc Items aMotivos Size 120,010 Of oDlg Pixel
	
	@ 035,010 Say STR0070 + ":" Size 060,008 Of oDlg Pixel //"Número do Processo"
	@ 033,070 Get oGetNrProc Var cNrProcesso Size 120,010 Of oDlg Pixel Valid .T.
	
	@ 070,070 Button STR0071 Size 040,012 Of oDlg Pixel Action (lConfirma := .T., oDlg:End()) //"Salvar"
	@ 070,120 Button STR0072 Size 040,012 Of oDlg Pixel Action (lConfirma := .F., oDlg:End()) //"Cancelar"

Activate MsDialog oDlg Centered

// Se confirmou, grava os dados
If lConfirma
	If SubStr(cMotivoExc, 1, 1) == '1' .and. Empty(AllTrim(cNrProcesso))
		MsgAlert(STR0073 + CRLF + STR0074) //"O campo Número do Processo é obrigatório quando o motivo da exclusão é a opção 1." //"O motivo da exclusão não será gravado."
	Else
		RecLock(cAlias, .F.)
			(cAlias)->&(cAlias + "_MOTEXC") := SubStr(cMotivoExc, 1, 1)
			(cAlias)->&(cAlias + "_NRPROC") := AllTrim(cNrProcesso)
			(cAlias)->&(cAlias + "_STATUS") := ""
			(cAlias)->&(cAlias + "_MSGRET") := ""
			(cAlias)->&(cAlias + "_PROTUL") := ""
			(cAlias)->&(cAlias + "_RECIBO") := ""
			(cAlias)->&(cAlias + "_XMLID")  := ""
		(cAlias)->(MsUnlock())
		MsgInfo(STR0075, STR0069) //"Dados gravados com sucesso!" //"Motivo da Exclusão"
	EndIf
EndIf

Return
