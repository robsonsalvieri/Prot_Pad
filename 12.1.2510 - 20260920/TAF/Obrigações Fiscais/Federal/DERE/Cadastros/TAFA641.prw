#include "totvs.ch"
#include "fwmvcdef.ch"
#include "TAFA641.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA641
Cadastro MVC - DeRE - Plano Geral de Contas

@author Carlos Pister
@since 13/03/2026
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA641()
Local	oBrw :=	FWmBrowse():New()

If TAFAlsInDic( "T7Z" )
	oBrw:SetDescription( STR0001 ) //Plano Geral de Contas
	oBrw:SetAlias( 'T7Z')
	oBrw:SetMenuDef( 'TAFA641' )
	oBrw:SetFilterDefault( "T7Z_ATIVO == '1' .Or. (T7Z_EVENTO == 'E' .And. T7Z_STATUS == '4' .And. T7Z_ATIVO == '2')" ) //Filtro para que apenas os registros ativos sejam exibidos ( 1=Ativo, 2=Inativo )

	oBrw:AddLegend( "T7Z_EVENTO == 'I' ", "GREEN" , STR0002 ) //"Registro Incluído"
	oBrw:AddLegend( "T7Z_EVENTO == 'A' ", "YELLOW", STR0003 ) //"Registro Alterado"
	oBrw:AddLegend( "T7Z_EVENTO == 'E' .And. T7Z_STATUS <> '4' ", "RED"   , STR0004 ) //"Registro excluído não transmitido"
	//Importante Monitoramento de Transmissão Inativa quando exclusão protocolada.
	oBrw:AddLegend( "T7Z_EVENTO == 'E' .And. T7Z_STATUS == '4' .And. T7Z_ATIVO == '2' ", "BLACK"   , STR0005 ) //"Registro excluído transmitido"

	oBrw:Activate()
else
	Aviso(STR0006,TafAmbInvMsg(),{STR0007},3) //##"Dicionário Incompatível" ##"Encerrar"
endif

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@Obs Importação via arquivo JSON usa cGetFile client-side, não disponível em Smart Client versão HTML.
@author Carlos Pister
@since 13/03/2026
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aFuncao := {}
Local aRotina := {}

Aadd( aFuncao, {STR0054, "Taf641Vld" } ) //"Validação"
Aadd( aFuncao, {STR0055, "TAF641Xml" } ) //"Gerar XML"
Aadd( aFuncao, {STR0056, "TAF641MExc"} ) //"Mot. Exclusão"
Aadd( aFuncao, {STR0057, "TAF641Int" } ) //"Integ.Contábil"
If GetRemoteType() <> 5 // Smart Client versão HTML.
	Aadd( aFuncao, {STR0058, "TAF641Imp" } ) //"Importação"
EndIf
aRotina	:= xFunMnuTAF( "TAFA641" , , aFuncao )

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
@since 13/03/2026
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oModel    as object
Local oStruT7Z	as object
Local oStruT8A  as object

oModel    := MPFormModel():New( "TAFA641", , {|oModel| ValidModel(oModel)}, { |oModel| SaveModel( oModel ) } )
oStruT7Z  := FWFormStruct( 1, "T7Z" )
oStruT8A  := FWFormStruct( 1, "T8A" )


oModel:AddFields( "MODEL_T7Z",, oStruT7Z )
oModel:SetPrimaryKey( {"T7Z_FILIAL","T7Z_ID","T7Z_VERSAO","T7Z_ATIVO"} )

oModel:AddGrid( "MODEL_T8A", "MODEL_T7Z", oStruT8A )
oModel:GetModel( "MODEL_T8A" ):SetOptional( .T. )
oModel:GetModel( "MODEL_T8A" ):SetUniqueLine( { "T8A_CONTA", "T8A_DESDCT" } )
oModel:GetModel( "MODEL_T8A" ):SetMaxLine(150000)
oModel:SetRelation( "MODEL_T8A", { { "T8A_FILIAL", 'xFilial( "T8A" )' }, { "T8A_ID", "T7Z_ID" }, { "T8A_VERSAO", "T7Z_VERSAO" }, { "T8A_ATIVO", "T7Z_ATIVO" } }, T8A->( IndexKey( 2 ) ) )

oModel:SetDescription(STR0008) //DeRE - Plano Geral de Contas

oModel:SetOnDemand(.T.)

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Carlos Pister
@since 13/03/2026
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oModel    as object
Local oView     as object
Local oStruT7Z	as object
Local oStruT8A  as object

oModel    := FwLoadModel( "TAFA641" )
oView     := FwFormView():New()
oStruT7Z  := FwFormStruct( 2, "T7Z" )
oStruT8A  := FwFormStruct( 2, "T8A" )

oView:SetModel( oModel )

oView:AddField( "VIEW_T7Z", oStruT7Z, "MODEL_T7Z" )
oView:EnableTitleView( "VIEW_T7Z", STR0009 ) //Plano Geral de Contas
    
oView:CreateHorizontalBox("PAINEL_PRINCIPAL",30)
oView:CreateFolder("FOLDER_PRINCIPAL","PAINEL_PRINCIPAL")
oView:SetOwnerView( "VIEW_T7Z", "PAINEL_PRINCIPAL" )
oView:CreateHorizontalBox("PAINEL_INFERIOR",70)
oView:CreateFolder("FOLDER_INFERIOR","PAINEL_INFERIOR")

oView:AddGrid( "VIEW_T8A", oStruT8A,"MODEL_T8A" )

oView:AddSheet("FOLDER_INFERIOR","ABA_01" , STR0010 ) //"Plano de Contas - Desdobramento"
oView:CreateHorizontalBox("PAINEL_T8A",100,,,"FOLDER_INFERIOR","ABA_01") 
oView:SetOwnerView( "VIEW_T8A", "PAINEL_T8A" )

//Ativando o campo de pesquisar e ativando o botão de Filtrar
oView:SetViewProperty("VIEW_T8A", "GRIDSEEK",    {.T.})
oView:SetViewProperty("VIEW_T8A", "GRIDFILTER",  {.T.})

oStruT7Z:SetProperty( 'T7Z_RECIBO', MVC_VIEW_TITULO , STR0059 ) //"Nº Recibo"
oStruT7Z:SetProperty( 'T7Z_MOTEXC', MVC_VIEW_TITULO , STR0061 ) //"Motivo da Exclusão"
oStruT7Z:SetProperty( 'T7Z_NRPROC', MVC_VIEW_TITULO , STR0062 ) //"Número do Processo"
oStruT7Z:SetProperty( 'T7Z_MSGRET', MVC_VIEW_TITULO , STR0060 ) //"Retorno do Processamento"

oStruT7Z:RemoveField( "T7Z_ID"  )
oStruT7Z:RemoveField( "T7Z_ATIVO"  )
oStruT7Z:RemoveField( "T7Z_EVENTO" )
oStruT7Z:RemoveField( "T7Z_VERSAO" )
oStruT7Z:RemoveField( "T7Z_STATUS" )
oStruT7Z:RemoveField( "T7Z_VERANT" )
oStruT7Z:RemoveField( "T7Z_PROTPN" )
oStruT7Z:RemoveField( "T7Z_PROTUL" )
oStruT7Z:RemoveField( "T7Z_XMLID"  )
If TAFColumnPos( "T7Z_RECANT" )  //Adicionado pos-dicionario
    oStruT7Z:RemoveField( "T7Z_RECANT" )
EndIf
oStruT8A:RemoveField( "T8A_ID" )
oStruT8A:RemoveField( "T8A_ATIVO" )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Função de gravação dos dados, chamada no final, no momento da confirmação do modelo

A estrutura do SaveModel ficou assim:

Begin Transaction
    If nOperation == MODEL_OPERATION_INSERT
        FwFormCommit( oModel ) //inalterado

    ElseIf nOperation == MODEL_OPERATION_UPDATE .or. nOperation == MODEL_OPERATION_DELETE

        If T7Z->T7Z_STATUS == "4"
            // FAltRegAnt + RecLock + FWBulk, sem FwFormCommit (devido problema de perfomance >2h na alteração de carga já transmitida)
        ElseIf T7Z->T7Z_STATUS == "1"
            TAFMsgVldOp(...) //inalterado
        Else
            TAFAltStat + FwFormCommit + TAFRastro //inalterado
        EndIf

    EndIf
End Transaction

@param  oModel -> Modelo de dados

@obs NOSONAR CS1000: DML parametrizado via FWPreparedStatement/FWExecStatement.
FWPreparedStatement/FWExecStatement não possui executeQuery/executeUpdate para DML.
GetFixQuery() + TcSqlExec() é o padrão correto para UPDATE/INSERT/DELETE com bind.
Nenhuma das classes possui método nativo para execução de DML:
- FWPreparedStatement.executeQuery() abre alias (SELECT), não executa DML.
- FWExecStatement.OpenAlias() / ExecScalar() são exclusivos para SELECT.
O bind via SetString()/SetNumeric() garante a sanitização dos parâmetros,
eliminando o risco de SQL Injection que a regra CS1000 visa prevenir.

@return .T.
@author Carlos Pister / Denis Souza / Jose Felipe
@since 13/03/2026
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
Local nT7Z          as numeric
Local nT8A          as numeric
Local aGrava		as array
Local aGravaT8A		as array
Local aGrupoT8A     as array
Local oModelT7Z		as object
Local oModelT8A		as object
Local lRetorno		as logical
Local cTblT8A		as character
Local oBulk			as object
Local aStruBulk		as array
Local cSqlUpd		as character
Local oStmtUpd		as object
Local lExibirExc    as logical

cVerAnt		:= ""
cProtocolo	:= ""
cRecibo     := ""
cEvento		:= ""
cVersao		:= ""
cChvRegAnt	:= ""
nOperation	:= oModel:GetOperation() 
nT7Z		:= 0
nT8A		:= 0
aGrava		:= {}
aGravaT8A	:= {}
aGrupoT8A   := {}
oModelT7Z	:= Nil
oModelT8A	:= Nil
lRetorno	:= .T.
cTblT8A 	:= ""
oBulk   	:= Nil
aStruBulk   := {}
cSqlUpd  	:= ""
oStmtUpd 	:= Nil
lExibirExc  := .F.

if nOperation == MODEL_OPERATION_UPDATE
	if T7Z->T7Z_EVENTO == "E" .And. AllTrim(T7Z->T7Z_STATUS) $ "2|4|9"
		TAFMsgVldOp(oModel,"7") //"Registro não pode ser excluído, pois o evento de exclusão já se encontra na base do RET"
		lRetorno := .F.
	endif
elseif nOperation == MODEL_OPERATION_DELETE
	if T7Z->T7Z_EVENTO == "E" .And. AllTrim(T7Z->T7Z_STATUS) $ "2|4|9"
		TAFMsgVldOp(oModel,"4") //"Nao e possivel alterar/excluir evento de exclusao ja processado"
		lRetorno := .F.
	endif
endif

if lRetorno
	Begin Transaction

		If nOperation == MODEL_OPERATION_INSERT
			
			oModel:LoadValue( "MODEL_T7Z", "T7Z_VERSAO", xFunGetVer() )

			FwFormCommit( oModel )
		
		ElseIf nOperation == MODEL_OPERATION_UPDATE .or. nOperation == MODEL_OPERATION_DELETE

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Seek para posicionar no registro antes de realizar as validacoes,³
			//³visto que quando nao esta posicionado nao eh possivel analisar   ³
			//³os campos nao usados como _STATUS                                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

			T8A->( DbSetOrder( 1 ) ) //T8A_FILIAL, T8A_ID, T8A_VERSAO, T8A_CONTA, T8A_DESDCT, T8A_CODTRI, T8A_ATIVO, R_E_C_N_O_, D_E_L_E_T_

			T7Z->( DbSetOrder( 3 ) )
			If T7Z->( MsSeek( xFilial( 'T7Z' ) + '1' + FwFldGet('T7Z_ID') ) )

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Se o registro ja foi transmitido³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If T7Z->T7Z_STATUS == "4"

					T8A->( MsSeek( xFilial( 'T8A' ) + FwFldGet('T7Z_ID') + FwFldGet('T7Z_VERSAO') ) )

					oModelT7Z := oModel:GetModel( "MODEL_T7Z" )
					oModelT8A := oModel:GetModel( "MODEL_T8A" )

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Busco a versao anterior do registro para gravacao do rastro³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					cVerAnt    := oModelT7Z:GetValue( "T7Z_VERSAO" )
					cProtocolo := oModelT7Z:GetValue( "T7Z_PROTUL" )
					cRecibo    := oModelT7Z:GetValue( "T7Z_RECIBO" )
					cEvento    := oModelT7Z:GetValue( "T7Z_EVENTO" )

					If !(nOperation == MODEL_OPERATION_DELETE .And. cEvento == "E")
						// Remove loops LoadValue T8A no model (50k iterações) SaveModel bloco STATUS=4	Elimina o gargalo principal
						// Remove DeActivate/SetOperation/Activate + FwFormCommit SaveModel bloco STATUS=4 Evita o commit MVC linha a linha
						// Adiciona RecLock direto para T7Z	SaveModel bloco STATUS=4 Mesmo resultado, sem overhead do model
						// Adiciona FWBulk para T8A	SaveModel bloco STATUS=4 Mesmo padrão já testado no ProcLoad do backoffice.taf.dere.tafa641import1011.tlpp

						// 1. Captura os campos do cabeçalho ANTES de inativar (loop aGrava já existe)
						For nT7Z := 1 to Len( oModelT7Z:aDataModel[ 1 ] )
							aAdd( aGrava, { oModelT7Z:aDataModel[ 1, nT7Z, 1 ], oModelT7Z:aDataModel[ 1, nT7Z, 2 ] } )
						Next nT7Z

						// 2. Cópia T8A do model para aGrupoT8A (mantém o loop existente, necessário para montar o Bulk)
						If !oModel:GetModel( 'MODEL_T8A' ):IsEmpty()
							For nT8A := 1 To oModel:GetModel( 'MODEL_T8A' ):Length()
								oModel:GetModel( 'MODEL_T8A' ):GoLine(nT8A)
								If !oModel:GetModel( 'MODEL_T8A' ):IsDeleted()
									aAdd(aGrupoT8A, { oModelT8A:GetValue('T8A_CONTA')  ;
													, oModelT8A:GetValue('T8A_DESDCT') ;
													, oModelT8A:GetValue('T8A_DESCCT') ;
													, oModelT8A:GetValue('T8A_INDCTA') ;
													, oModelT8A:GetValue('T8A_DESNAT') ;
													, oModelT8A:GetValue('T8A_CNTSUP') ;
													, oModelT8A:GetValue('T8A_CODREF') ;
													, oModelT8A:GetValue('T8A_NIVCTA') ;
													, oModelT8A:GetValue('T8A_NATCTA') ;
													, oModelT8A:GetValue('T8A_CODNAT') ;
													, oModelT8A:GetValue('T8A_CODTRI') ;
													, oModelT8A:GetValue('T8A_INDTIS') ;
													, oModelT8A:GetValue('T8A_IDLEID') ;
													, oModelT8A:GetValue('T8A_INIVIG') ;
													, oModelT8A:GetValue('T8A_FIMVIG') } )
								EndIf
							Next nT8A
						EndIf

						// 3. Inativa o registro pai (mesmo comportamento anterior)
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Seto o campo como Inativo e gravo a versao do novo registro³
						//³no registro anterior                                       ³
						//|                                                           |
						//|ATENCAO -> A alteracao destes campos deve sempre estar     |
						//|abaixo do Loop do For, pois devem substituir as informacoes|
						//|que foram armazenadas no Loop acima                        |
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						FAltRegAnt( 'T7Z', '2', .F., "", "", "" )

						// 4. Grava novo cabeçalho T7Z diretamente via RecLock (sem passar pelo model)
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Busco a versao que será gravada³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						cVersao := xFunGetVer()

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Neste momento realiza inclusão do novo registro já     ³
						//³contemplando as informações alteradas pelo usuário     ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						RecLock( "T7Z", .T. )
							T7Z->T7Z_FILIAL := xFilial("T7Z")
							T7Z->T7Z_ID     := FwFldGet("T7Z_ID")
							T7Z->T7Z_VERSAO := cVersao
							T7Z->T7Z_VERANT := cVerAnt
							T7Z->T7Z_PROTPN := cProtocolo
							T7Z->T7Z_RECANT := cRecibo
							T7Z->T7Z_PROTUL := ""
							T7Z->T7Z_RECIBO := ""
							T7Z->T7Z_STATUS := ""
							T7Z->T7Z_ATIVO  := "1"
							If nOperation == MODEL_OPERATION_DELETE
								T7Z->T7Z_EVENTO := "E"
							Else
								T7Z->T7Z_EVENTO := "A"
							EndIf
							// Campos de negócio, replicados de aGrava para não depender de posição fixa
							For nT7Z := 1 To Len( aGrava )
								Do Case
									Case aGrava[nT7Z, 1] == "T7Z_DTINVA"
										T7Z->T7Z_DTINVA := aGrava[nT7Z, 2]
									Case aGrava[nT7Z, 1] == "T7Z_DTFIVA"
										T7Z->T7Z_DTFIVA := aGrava[nT7Z, 2]
									Case aGrava[nT7Z, 1] == "T7Z_PLANCT"
										T7Z->T7Z_PLANCT := aGrava[nT7Z, 2]
									Case aGrava[nT7Z, 1] == "T7Z_FREQEN"
										T7Z->T7Z_FREQEN := aGrava[nT7Z, 2]
									Case aGrava[nT7Z, 1] == "T7Z_MOTEXC"
										T7Z->T7Z_MOTEXC := aGrava[nT7Z, 2]
									Case aGrava[nT7Z, 1] == "T7Z_NRPROC"
										T7Z->T7Z_NRPROC := aGrava[nT7Z, 2]
									Case aGrava[nT7Z, 1] == "T7Z_CODPLA"
										T7Z->T7Z_CODPLA := aGrava[nT7Z, 2]
									Case aGrava[nT7Z, 1] == "T7Z_VERPLA"
										T7Z->T7Z_VERPLA := aGrava[nT7Z, 2]
								EndCase
							Next nT7Z
						T7Z->(MsUnLock())

						If nOperation == MODEL_OPERATION_DELETE
							// Migra os filhos T8A da versão anterior (cVerAnt) para a nova (cVersao),
							// mantendo T8A_ATIVO = '1', para que o SetRelation do MODEL_T8A os encontre
							// com a chave {T8A_ID + T8A_VERSAO + T8A_ATIVO} que aponta para o novo T7Z.
							If !Empty(cVerAnt) .And. !Empty(cVersao) .And. cVerAnt <> cVersao
								//Para manter performance e não precisar realizar nova carga via bulk com a nova versão, 
								//para essa operação é feito um update, pois podem existir até 150.000 registros para um ID, Versão e ativo.
								cSqlUpd := "UPDATE " + RetSqlName("T8A") + " SET T8A_VERSAO = ? WHERE T8A_FILIAL = ? AND T8A_ID = ? AND T8A_VERSAO = ? AND T8A_ATIVO = ? AND D_E_L_E_T_ = ? "																
								oStmtUpd := FWExecStatement():New(cSqlUpd)
								oStmtUpd:SetString(1, cVersao)            // novo T8A_VERSAO
								oStmtUpd:SetString(2, xFilial("T8A"))     // T8A_FILIAL
								oStmtUpd:SetString(3, FwFldGet("T7Z_ID")) // T8A_ID
								oStmtUpd:SetString(4, cVerAnt)            // versão antiga (origem)
								oStmtUpd:SetString(5, "1")                // T8A_ATIVO
								oStmtUpd:SetString(6, Space(1))           // D_E_L_E_T_
								cSqlUpd := oStmtUpd:GetFixQuery()
								TcSqlExec(cSqlUpd)

								oStmtUpd:Destroy()
								oStmtUpd := Nil
								
								lExibirExc := .T.
							EndIf
						else
							//Substituição do FwFormCommit por Bulk
							// 5. Grava T8A via FWBulk (sem loop de AddLine/LoadValue no model) perfomance melhorou muito >2h para 2m
							If Len(aGrupoT8A) > 0
								cTblT8A  := RetSqlName("T8A")
								aStruBulk := T641AStruSave()
								oBulk := FWBulk():New(cTblT8A)
								oBulk:SetFields(aStruBulk)
								For nT8A := 1 To Len(aGrupoT8A)
									oBulk:AddData({ xFilial("T8A")    ;  // T8A_FILIAL
												, FwFldGet("T7Z_ID")  ;  // T8A_ID
												, cVersao             ;  // T8A_VERSAO (nova versao)
												, "1"                 ;  // T8A_ATIVO
												, aGrupoT8A[nT8A][1]  ;  // T8A_CONTA
												, aGrupoT8A[nT8A][2]  ;  // T8A_DESDCT
												, aGrupoT8A[nT8A][3]  ;  // T8A_DESCCT
												, aGrupoT8A[nT8A][4]  ;  // T8A_INDCTA
												, aGrupoT8A[nT8A][5]  ;  // T8A_DESNAT
												, aGrupoT8A[nT8A][6]  ;  // T8A_CNTSUP
												, aGrupoT8A[nT8A][7]  ;  // T8A_CODREF
												, aGrupoT8A[nT8A][8]  ;  // T8A_NIVCTA
												, aGrupoT8A[nT8A][9]  ;  // T8A_NATCTA
												, aGrupoT8A[nT8A][10] ;  // T8A_CODNAT
												, aGrupoT8A[nT8A][11] ;  // T8A_CODTRI
												, aGrupoT8A[nT8A][12] ;  // T8A_INDTIS
												, aGrupoT8A[nT8A][13] ;  // T8A_IDLEID
												, aGrupoT8A[nT8A][14] ;  // T8A_INIVIG
												, aGrupoT8A[nT8A][15] })  // T8A_FIMVIG
								Next nT8A

								If !(oBulk == Nil)
									oBulk:Close()
									oBulk:Destroy()
									oBulk := Nil
								EndIf
							EndIf
						endif
					EndIf

				Elseif T7Z->T7Z_STATUS == "1" //AGUARDANDO RETORNO
					//Não é possível alterar um registro com aguardando validação
					TAFMsgVldOp(oModel,"2")
					lRetorno := .F.	
				Else
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Caso o registro nao tenha sido transmitido ainda, gravo sua chave³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					cChvRegAnt := T7Z->( T7Z_ID + T7Z_VERANT )

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³No caso de um evento de Exclusao deve-se perguntar ao usuario se ele realmente deseja realizar a exclusao.³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If T7Z->T7Z_EVENTO == "E"
						If nOperation == MODEL_OPERATION_DELETE
							If Aviso( STR0011, STR0012, { STR0013, STR0014 }, 1 ) == 2 //##"Registro Excluído" ##"O Evento de exclusão não foi transmitido. Deseja realmente exclui-lo ou manter o evento de exclusão para transmissão posterior ?" ##"Excuir" ##"Manter"
								cChvRegAnt := ""
								lRetorno   := .F. //Se escolher o MANTER não emitirá aviso de excluído com sucesso, ou seja, permanecerá no formulário e o usuário poderá fechar
								oModel:SetErrorMessage( , , oModel:GetId(), "", "",STR0111,STR0112,"", "" ) //"Operação Cancelada"#"O usuário manteve o cadastro, o registro permanecerá inalterado."
							EndIf
						Else
							oModel:LoadValue( "MODEL_T7Z", "T7Z_EVENTO", "A" )
						EndIf
					EndIf

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Executo a operacao escolhida³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If !Empty( cChvRegAnt )
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Funcao responsavel por setar o Status do registro para Branco³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						TAFAltStat( "T7Z", " " )

						FwFormCommit( oModel )

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Caso a operacao seja uma exclusao...³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If nOperation == MODEL_OPERATION_DELETE
							//Funcao para setar o registro anterior como Ativo
							TAFRastro( "T7Z", 1, cChvRegAnt, .T. , , Nil )
							if T7Z->T7Z_EVENTO == "E"
								if !Empty( FwFldGet('T7Z_VERANT') )
									//Migra os filhos T8A da exclusao para a versao anterior, para que o SetRelation do modelo encontre os filhos da chave {T8A_ID + T8A_VERSAO + T8A_ATIVO}
									//Para manter performance e não precisar realizar nova carga via bulk com a nova versão, 
									//para essa operação é feito um update, pois podem existir até 150.000 registros para um ID, Versão e ativo
									cSqlUpd := "UPDATE " + RetSqlName("T8A") + " SET T8A_VERSAO = ? , D_E_L_E_T_ = ? , R_E_C_D_E_L_ = ? WHERE T8A_FILIAL = ? AND T8A_ID = ? AND T8A_VERSAO = ? AND T8A_ATIVO = ? AND D_E_L_E_T_ = ? "
									oStmtUpd := FWExecStatement():New(cSqlUpd)
									oStmtUpd:SetString( 1, FwFldGet('T7Z_VERANT'))  // versão antiga (origem)
									oStmtUpd:SetString( 2, Space(1))           	    // D_E_L_E_T_
									oStmtUpd:SetNumeric(3, 0 )           		    // R_E_C_D_E_L_
									oStmtUpd:SetString( 4, xFilial("T8A"))          // T8A_FILIAL
									oStmtUpd:SetString( 5, FwFldGet("T7Z_ID"))      // T8A_ID
									oStmtUpd:SetString( 6, FwFldGet('T7Z_VERSAO') ) // versão atual que foi excluída
									oStmtUpd:SetString( 7, "1")                	    // T8A_ATIVO
									oStmtUpd:SetString( 8, "*")                	    // D_E_L_E_T_
									cSqlUpd := oStmtUpd:GetFixQuery()
									TcSqlExec(cSqlUpd)
									oStmtUpd:Destroy()
									oStmtUpd := Nil
								endif
							endif
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
	End Transaction
endif

if lExibirExc
	MsgInfo(STR0050, STR0001)//"Após confirmar a exclusão é preciso cadastrar o motivo em 'Outras Ações'" //"Plano Geral de Contas"	
endif

Return lRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} ValidModel

Funcao que valida os dados do registro posicionado,
verificando se ha incoerencias nas informacoes

Alem das validacoes de cabecalho (T7Z), verifica se na grid T8A,
todos os campos obrigatórios (T8A_CONTA, T8A_INDCTA, T8A_NIVCTA, T8A_NATCTA, T8A_CODNAT, T8A_CODREF, ...)
estao preenchidos em cada linha, necessário pois a carga via bulk não realiza validação.

@param  oModel, Object, Modelo de dados MVC
@return lRet, Logical, .T. se os dados são válidos, .F. caso contrário

@author Carlos Pister / Denis Souza
@since 13/03/2026
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ValidModel( oModel)

Local oModelT7Z  as object
Local oModelT8A  as object
Local lRet       as logical
Local cIdAtual   as character
Local cQryDup    as character
Local oStmDup    as object
Local nTotReg    as numeric
Local nOperation as numeric
Local cQrySob    as character
Local oStmSob    as object
Local aErrosT8A  as array
Local nQtdLin    as numeric
Local aLineMod   as array
Local nPar       as numeric

Default oModel := Nil

oModelT7Z  := oModel:GetModel( "MODEL_T7Z" )
oModelT8A  := oModel:GetModel( "MODEL_T8A" )
lRet       := .T.
cIdAtual   := ""
cQryDup    := ""
oStmDup    := Nil
nOperation := oModelT7Z:GetOperation()
cQrySob    := ""
oStmSob    := Nil
aErrosT8A  := {}
nQtdLin    := 0
aLineMod   := {}
nPar       := 0

If !(oModel == Nil)
	If !Empty(oModelT7Z:GetValue( "T7Z_DTINVA" )) .and. !Empty(oModelT7Z:GetValue( "T7Z_DTFIVA" )) .and. oModelT7Z:GetValue( "T7Z_DTFIVA" ) < oModelT7Z:GetValue( "T7Z_DTINVA" )
		Help( ,,STR0015,,STR0037, 1, 0,,,,,,{STR0038} ) // "Atenção"##""Data fim não pode ser anterior à data de início"# "Informe uma data posterior a data de início."
		lRet :=	.F.	
	ElseIF !Empty(oModelT7Z:GetValue( "T7Z_DTFIVA" )) .and. !Empty(oModelT7Z:GetValue( "T7Z_DTINVA" )) .and. oModelT7Z:GetValue( "T7Z_DTINVA" ) == oModelT7Z:GetValue( "T7Z_DTFIVA" )
		Help( ,,STR0015,,STR0039, 1, 0,,,,,,{STR0038} ) // "Atenção"##""Data início não pode ser posterior à data de fim"# "Informe uma data inferior a data de início."
		lRet :=	.F.
	EndIf

	If lRet .and. !(oModelT7Z:GetValue( "T7Z_EVENTO" ) == "I") .AND. !(oModelT7Z:GetValue( "T7Z_DTINVA" ) == T7Z->T7Z_DTINVA)
		Help( ,,STR0015,,STR0041, 1, 0,,,,,,{STR0042} ) // "Atenção"##"Não é possível a alteração da data de início de validade do evento. " # "Para uma nova data de início de validade, favor inclua um novo registro."
		lRet := .F.	
	EndIf

	//O XSD correto do D-1011 (evtPGCC) confirma algo importante: o idePeriodo tem iniValid + fimValid sem nenhuma restrição de unicidade por tipo de plano no schema — é o regulador que define isso na validação de negócio. Mas o XSD mostra que planoCtaRef e freqEncerr ficam dentro de infoPGCC, o que significa que uma empresa pode ter um único PGCC ativo por vez (o XSD não permite múltiplos infoPGCC no mesmo evento).
	//Isso responde a questão do manual: o controle de período deve ser geral (independente do tipo de plano), porque o evento D-1011 representa o plano de contas da empresa — não um plano por regulador. Só pode existir um período ativo por filial/freqüência.

	if nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE
		//Bloquear período duplicado (mesma combinação PLANCT+FREQEN+DTINVA)
		If lRet
			cIdAtual := AllTrim(oModelT7Z:GetValue("T7Z_ID"))
			cQryDup := "SELECT COUNT(T7Z.T7Z_ID) REGISTROS FROM " + RetSqlName("T7Z") + " T7Z WHERE T7Z.T7Z_FILIAL = ? "
			cQryDup += "AND T7Z.T7Z_PLANCT = ? AND T7Z.T7Z_FREQEN = ? AND T7Z.T7Z_DTINVA = ? AND T7Z.T7Z_ATIVO = ? AND T7Z.T7Z_ID <> ? AND T7Z.D_E_L_E_T_ = ? "
			cQryDup += "AND NOT (T7Z.T7Z_EVENTO = ? AND T7Z.T7Z_STATUS IN (?, ?, ?)) "
			cQryDup := ChangeQuery(cQryDup)
			oStmDup := FWExecStatement():New(cQryDup)
			oStmDup:SetString(1, xFilial("T7Z"))
			oStmDup:SetString(2, AllTrim(oModelT7Z:GetValue("T7Z_PLANCT")))
			oStmDup:SetString(3, AllTrim(oModelT7Z:GetValue("T7Z_FREQEN")))
			oStmDup:SetDate  (4, oModelT7Z:GetValue("T7Z_DTINVA"))
			oStmDup:SetString(5, '1') //T7Z_ATIVO
			oStmDup:SetString(6, cIdAtual)
			oStmDup:SetString(7, space(1))
			oStmDup:SetString(8, 'E') //T7Z_EVENTO - Exclusão
			oStmDup:SetString(9, '2') //T7Z_STATUS - Transmitido
			oStmDup:SetString(10,'4') //T7Z_STATUS - Transmitido válido
			oStmDup:SetString(11,'9') //T7Z_STATUS - Em processamento
			nTotReg := oStmDup:ExecScalar('REGISTROS')
			If nTotReg > 0
				Help(,,STR0015,,STR0052, 1, 0,,,,,,{STR0053}) //"Período duplicado. Ja existe registro ativo com mesma combinação."##"Encerre o período existente antes de incluir um novo."
				lRet := .F.
			EndIf
			oStmDup:Destroy()
			oStmDup := Nil
		EndIf

		//Bloquear sobreposição de período de vigência (T7Z_DTINVA/T7Z_DTFIVA)
		If lRet
			cIdAtual := AllTrim(oModelT7Z:GetValue("T7Z_ID"))

			cQrySob := "SELECT COUNT(T7Z.T7Z_ID) REGISTROS FROM " + RetSqlName("T7Z") + " T7Z"
			cQrySob += " WHERE T7Z.T7Z_FILIAL = ? AND T7Z.T7Z_ATIVO = ? AND T7Z.D_E_L_E_T_ = ? AND T7Z.T7Z_ID <> ?"
			cQrySob += " AND NOT (T7Z.T7Z_EVENTO = ? AND T7Z.T7Z_STATUS IN (?, ?, ?))"
			cQrySob += " AND ( ? <= T7Z.T7Z_DTFIVA OR T7Z.T7Z_DTFIVA = ? )"

			If !Empty(oModelT7Z:GetValue("T7Z_DTFIVA"))
				cQrySob += " AND ? >= T7Z.T7Z_DTINVA"
			EndIf

			cQrySob := ChangeQuery(cQrySob)

			nPar := 0
			oStmSob := FWExecStatement():New(cQrySob)
			oStmSob:SetString(++nPar, xFilial("T7Z"))
			oStmSob:SetString(++nPar, '1')                                //T7Z_ATIVO
			oStmSob:SetString(++nPar, Space(1))                           //D_E_L_E_T_
			oStmSob:SetString(++nPar, cIdAtual)                           //T7Z_ID (auto-exclusãoo)
			oStmSob:SetString(++nPar, 'E')                                //T7Z_EVENTO - Exclusão
			oStmSob:SetString(++nPar, '2')                                //T7Z_STATUS - Transmitido
			oStmSob:SetString(++nPar, '4')                                //T7Z_STATUS - Transmitido válido
			oStmSob:SetString(++nPar, '9')                                //T7Z_STATUS - Em processamento
			oStmSob:SetDate  (++nPar, oModelT7Z:GetValue("T7Z_DTINVA"))   //nova DTINVA vs. T7Z_DTFIVA existente
			oStmSob:SetString(++nPar, Space(1))                           //T7Z_DTFIVA existente vazio

			If !Empty(oModelT7Z:GetValue("T7Z_DTFIVA"))
				oStmSob:SetDate(++nPar, oModelT7Z:GetValue("T7Z_DTFIVA")) //nova DTFIVA vs. T7Z_DTINVA existente
			EndIf

			nTotReg := oStmSob:ExecScalar('REGISTROS')
			If nTotReg > 0
				Help(,,STR0015,,STR0052, 1, 0,,,,,,{STR0053}) //"Atenção"##"Existe um período ativo com o intervalo de datas informado"##"Informe um novo intervalo"
				lRet := .F.
			EndIf

			oStmSob:Destroy()
			oStmSob := Nil
		EndIf
	endif
EndIf

//-----------------------------------------------------------------------
// Valida a grid T8A: campos obrigatórios acumulados - exibe log único
// Esta validação é necessária para evitar a perda de dados vindos da integração contábil.
// Caso existam campos obrigatórios não preenchidos (como a conta referencial em registros sintéticos), 
// a ausência desta trava faz com que o MVC considere as linhas afetadas inválidas. 
// Consequentemente, ao confirmar a alteração, o modelo remove esses registros da tabela T8A. 
// Em uma carga de 50.000 itens com apenas 100 preenchidos corretamente, por exemplo, os 49.900 
// restantes seriam ignorados e apagados no momento da gravação.
//-----------------------------------------------------------------------
If lRet .And. ( nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE )
	nQtdLin := oModelT8A:Length()
	aLineMod := oModelT8A:GetLinesChanged( MODEL_GRID_LINECHANGED_UPDATED )

	if nQtdLin >= 1 .And. ( !oModelT8A:IsEmpty() .Or. Len(aLineMod) > 0 )
		aErrosT8A := T8AVldCampos( oModelT8A )
		If Len( aErrosT8A ) > 0
			T641VldMd( aErrosT8A, oModelT8A:Length(), STR0063 )//"Não será possível efetuar a gravação."
			lRet := .F.
		EndIf
	EndIf
endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Taf641Cbox
Funcao que retorna a string de opções para o ComboBox 
@author Carlos Pister
@since 13/03/2026
@version 1.0
/*/
//-------------------------------------------------------------------
Function Taf641Cbox(cCampo)

Local cString := ""
Default cCampo := ""

Do Case
	Case cCampo == 'T8A_CODNAT'
		cString := "1="+ STR0030 + ";" //"Contas do ativo"
		cString += "2="+ STR0031 + ";" //"Contas do passivo"
		cString += "3="+ STR0032 + ";" //"Contas do patrimônio líquido"
		cString += "4="+ STR0033 + ";" //"Contas de receita"
		cString += "5="+ STR0034 + ";" //"Contas de despesa"
	Case cCampo == 'T7Z_MOTEXC'
		cString := "1="+ STR0043 + ";" //"Determinação judicial ou administrativa"
		cString += "2="+ STR0044 + ";" //"Envio indevido (fato inexistente)"
		cString += "3="+ STR0045 + ";" //"Erro na identificação (CNPJ/período incorretos)"
		cString += "9="+ STR0046 + ";" //"Outro"
EndCase

Return cString 

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF641Xml
Gera o XML do evento D-1011 para o registro T7Z posicionado
e abre o visualizador de XML via xTafGerXml.

@type    Function
@author  Carlos Pister / Denis Souza
@since   13/03/2026
@version 1.0
@param cAlias, Character, alias do registro posicionado
@param nRecno, Numeric,   recno do registro posicionado
@param nOpc,   Numeric,   opcao de menu acionada
@param lJob,   Logical,   .T. quando chamado em batch/job
@return Nil
/*/
//-------------------------------------------------------------------
Function TAF641Xml(cAlias,nRecno,nOpc,lJob)

	Local oXml as object
	Local cXML as character

	oXml := Nil
	cXML := ""

	oXml := backoffice.taf.dere.xml.TAFDereXmlEvents():New()

	FWMsgRun(, {|| cXml := oXml:TafDereGetXmlEvent('D-1011', T7Z->T7Z_ID, T7Z->T7Z_VERSAO) }, STR0120, STR0121 ) //"Verificando Registros"#"Aguarde..."

	FWMsgRun(, {||  xTafGerXml(cXML,'1011',,,,,,"D-" )}, STR0122, STR0123) //"Gerando XML"#"Aguarde alguns minutos."

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF641MExc
Chama a função responsável por exibir tela de Motivo de Exclusão
Permite informar o motivo da exclusão e número do processo
@author Rafael de Paula Leme
@since 17/08/2026
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAF641MExc()
	If T7Z->T7Z_EVENTO <> 'E'
		MsgInfo(STR0047, STR0048) //"Opção disponível apenas para registros excluídos e não transmitidos." //"Motivo da Exclusão"
	ElseIf T7Z->T7Z_STATUS == '4'
		MsgInfo(STR0051, STR0048) //"A exclusão desse Plano de Contas já foi transmitida e por isso não pode ser alterada" //"Motivo da Exclusão"
	Else
		MotExc1011('T7Z')	
	EndIf
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF641Int
Entry point do botao Integrar no TAFA641. Verifica posicionamento
do registro T7Z e orquestra o fluxo de integração contábil via
classe T641IntCls: confirmação antecipada, extração do SIGACTB e
carga das contas na tabela T8A.

@author Denis De Souza Naves
@since  19/08/2026
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAF641Int()

    Local oInteg      := Nil as Object
    Local oJson       := Nil as Object
    Local aRet        := {}  as Array
    Local lEscolh1    := .F. as Logical
	Local lT641IntCls := .F. as Logical 
    Local cId         := "" as Character
    Local cT7ZVer     := "" as Character
    Local cFil        := "" as Character
    Local cStat       := "" as Character
    Local cCodPla     := "" as Character
    Local cVerPla     := "" as Character
    Local cProtul     := "" as Character
	Local cRecibo     := "" as Character

	lT641IntCls := FindClass("backoffice.taf.dere.tafa641import1011.T641IntCls")

    cId     := AllTrim(T7Z->T7Z_ID)
    cT7ZVer := AllTrim(T7Z->T7Z_VERSAO)
    cFil    := AllTrim(T7Z->T7Z_FILIAL)
    cStat   := AllTrim(T7Z->T7Z_STATUS)
    cProtul := AllTrim(T7Z->T7Z_PROTUL)
    cCodPla := AllTrim(T7Z->T7Z_CODPLA)
	cVerPla := AllTrim(T7Z->T7Z_VERPLA)
	cRecibo := AllTrim(T7Z->T7Z_RECIBO)

	//0=Reg.Válido;1=Reg.Inválido;2=Reg.Transmitido;3=Reg.Transmitido com inconsistência;4=Reg.Transmitido válido;9=Em Processamento
	if !(cStat $ "2|9")
    	If T7Z->T7Z_EVENTO == "E"
        	MsgAlert(STR0113,STR0114) //"Importação Contábil não disponível para registros excluídos. Inclua/Altere uma nova competência antes."#"Plano Geral de Contas"
		else
			if lT641IntCls
				oInteg := backoffice.taf.dere.tafa641import1011.T641IntCls():New(cId, cT7ZVer, cFil, cStat, cCodPla, cVerPla, cProtul, cRecibo)
				lEscolh1 := oInteg:ConfirmarCarga("integracao") // confirmacoes antecipadas — instantaneo
				If lEscolh1
					FWMsgRun(, {|| oJson := oInteg:ExecSgActb()}, STR0115, STR0116 ) //"Extraindo os dados do contábil ( SIGACTB )."#"Aguarde alguns minutos"
					If ValType(oJson) == "O" .Or. ValType(oJson) == "J"
						FWMsgRun(, {|| aRet := oInteg:ProcLoad(oJson)}, STR0067, STR0117) //"Integrar"#"Gravando o plano geral de contas."
						// Limpa o status apos importacao para que o monitor considere pendente de transmissao. Aplica apenas para status diferentes de 2 e 9, ja garantido pela guarda acima (!(cStat $ "2|9")).
						TAFAltStat( "T7Z", " " )
						If ValType(aRet) == "A" .And. Len(aRet) >= 4
							If !Empty(aRet[4])
								MsgInfo(aRet[4], STR0001) //"Plano Geral de Contas"
							EndIf
							If aRet[3]
								oInteg:ExibLog(aRet[1], aRet[2], oInteg:GetInconsis())
							EndIf
						EndIf
						DBSelectArea("T7Z") //Refresh do browse
						T7Z->(DBGoTop())
					EndIf
				Else
					MsgAlert(STR0069) //"Rotina Cancelada."
				EndIf
				// Libera o objeto em um único ponto, independente do caminho percorrido
				If ValType(oInteg) == "O"
					FreeObj(oInteg)
					oInteg := Nil
				EndIf
			else
				MsgAlert(STR0070) //"O fonte backoffice.taf.dere.tafa641import1011.tlpp não foi localizado no repositório. Favor Atualizar."
			endif
		endif
	else
		MsgAlert(STR0071) //"Em processamento. Não será possível realizar a Integração."
	endif

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF641Imp
"Importar JSON" no browse do TAFA641,
voltado para plano de contas oriundo de linhas de outros produtos
(fora do Protheus/SIGACTB). O usuario seleciona um arquivo .json
(ou .txt no mesmo formato) via cGetFile para integrar as contas
na tabela T8A atraves da classe
backoffice.taf.dere.tafa641import1011.T641IntCls. 

Fluxo:
    1. Valida a presenca da classe de importacao.
    2. Coleta o contexto do registro T7Z posicionado.
    3. Abre modal de confirmacao (T641ImpMd) ANTES do cGetFile,
       com pergunta "Deseja realmente importar?" e botao para
       exibir/ocultar o contrato JSON esperado - o usuario pode
       consultar o padrao antes de escolher o arquivo.
    4. Se confirmado, delega ao metodo ExecJson (cGetFile + parse +
       validacao estrutural minima). Se o usuario cancelar ou o
       arquivo for invalido, ExecJson retorna Nil e o fluxo encerra.
    5. JSON valido, executa ProcLoad e ExibLog.

@author Denis Souza / José Felipe
@since  31/08/2026
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAF641Imp()

    Local oInteg      := Nil as Object
    Local oJson       := Nil as Object
    Local aRet        := {}  as Array
    Local lT641IntCls := .F. as Logical
	Local lOk		  := .T. as Logical
    Local cId         := ""  as Character
    Local cT7ZVer     := ""  as Character
    Local cFilAux     := ""  as Character
    Local cStat       := ""  as Character
    Local cCodPla     := ""  as Character
    Local cVerPla     := ""  as Character
    Local cProtul     := ""  as Character
    Local cRecibo     := ""  as Character

    lT641IntCls := FindClass("backoffice.taf.dere.tafa641import1011.T641IntCls")

    If !lT641IntCls
        lOk := .F.
        MsgAlert(STR0070) //"O fonte backoffice.taf.dere.tafa641import1011.tlpp não foi localizado no repositório. Favor Atualizar."
    EndIf

    if lOk
		cId     := AllTrim(T7Z->T7Z_ID)
		cT7ZVer := AllTrim(T7Z->T7Z_VERSAO)
		cFilAux := AllTrim(T7Z->T7Z_FILIAL)
		cStat   := AllTrim(T7Z->T7Z_STATUS)
		cProtul := AllTrim(T7Z->T7Z_PROTUL)
		cCodPla := AllTrim(T7Z->T7Z_CODPLA)
		cVerPla := AllTrim(T7Z->T7Z_VERPLA)
		cRecibo := AllTrim(T7Z->T7Z_RECIBO)

        //0=Reg.Válido;1=Reg.Inválido;2=Reg.Transmitido;3=Reg.Transmitido com inconsistência;4=Reg.Transmitido válido;9=Em Processamento
        if !(cStat $ "2|9")
            If T7Z->T7Z_EVENTO == "E"
				MsgAlert(STR0118,STR0119) // "Integração Contábil não disponível para registros excluídos." //"Importação Contábil não disponível para registros excluídos. Inclua/Altere uma nova competência antes."#"Plano Geral de Contas"
            else
                oInteg := backoffice.taf.dere.tafa641import1011.T641IntCls():New(cId, cT7ZVer, cFilAux, cStat, cCodPla, cVerPla, cProtul, cRecibo)
                lOk := T641ImpMd()
                If !lOk
                    MsgAlert(STR0072) //"Importação cancelada pelo usuário."
                else
                    lOk := oInteg:ConfirmarCarga("importacao")
                    If !lOk
                        MsgAlert(STR0069) //"Rotina Cancelada."
                    else
                        oJson := oInteg:ExecJson()
                        If ValType(oJson) == "O" .Or. ValType(oJson) == "J"
                            FWMsgRun(, {|| aRet := oInteg:ProcLoad(oJson)}, STR0067, STR0068) //"Integrar"#"Processando contas..."
                            // Limpa o status apos importacao para que o monitor considere pendente de transmissao. Aplica apenas para status diferentes de 2 e 9, ja garantido pela guarda acima (!(cStat $ "2|9")).
                            TAFAltStat( "T7Z", " " )
                            If ValType(aRet) == "A" .And. Len(aRet) >= 4
                                If !Empty(aRet[4])
                                    MsgInfo(aRet[4], STR0001) //"Plano Geral de Contas"
                                EndIf
                                If aRet[3]
                                    oInteg:ExibLog(aRet[1], aRet[2], oInteg:GetInconsis())
                                EndIf
                            EndIf
                            DBSelectArea("T7Z") //Refresh do browse
                            T7Z->(DBGoTop())
                        EndIf
                    endif
                endif
                // Libera o objeto em um único ponto, independente do caminho percorrido
                If ValType(oInteg) == "O"
                    FreeObj(oInteg)
                    oInteg := Nil
                EndIf
            endif
        else
            MsgAlert(STR0071) //"Em processamento. Não será possível realizar a Importação."
        endif
    endif

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} T641ImpMd
Modal de confirmacao ANTES do cGetFile, usada pelo entry point
TAF641Imp. Apresenta a pergunta "Deseja realmente importar um plano
de contas via arquivo JSON?" e permite ao usuario consultar o
contrato esperado ANTES de escolher o arquivo.

Componentes:
    - Cabecalho (TSay) com a pergunta de confirmacao.
    - Botao (TButton) "Exibir/Ocultar formato do JSON esperado"
      que alterna a visibilidade de um TMultiGet contendo o
      contrato do arquivo (T641JsTpl).
    - Botoes "Confirmar" e "Cancelar" na base do modal.
      Confirmar sinaliza aRet[1] = .T. e libera o fluxo para
      TAF641Imp chamar ExecJson (cGetFile + parse).

@type  function
@author  Denis Souza / Jose Felipe
@since  31/08/2026
@version 1.0
@return Logical, .T. quando o usuario confirma a importacao
/*/
//-------------------------------------------------------------------
Static Function T641ImpMd()

    Local oModal    := Nil   as Object
    Local oPanel    := Nil   as Object
    Local oMemo     := Nil   as Object
    Local oBtnFmt   := Nil   as Object
    Local cCabec    := "" 	 as Character
    Local cContrato := "" 	 as Character
    Local cLbShow   := "" 	 as Character
    Local cLbHide   := "" 	 as Character
    Local aFlag     := {.F.} as Array
    Local aRet      := {.F.} as Array

    cLbShow   := STR0073 //"Exemplo Leiaute Integração"
    cLbHide   := STR0074 //"Ocultar"
    cContrato := T641JsTpl()
    cCabec    := STR0075 //"Deseja selecionar um arquivo de integração para importar o plano de contas?"

    oModal := FWDialogModal():New()
    oModal:SetTitle(STR0076) 	//"Importação"
    oModal:SetSubTitle(STR0077) //"Plano de Contas"
    oModal:SetFreeArea(225, 156)
    oModal:SetEscClose(.T.)
    oModal:SetBackground(.T.)
    oModal:CreateDialog()
    oModal:AddCloseButton(Nil, STR0078) //"Cancelar"
    oModal:AddButton(STR0079, {|| aRet[1] := .T., oModal:DeActivate()}, STR0079, , .T., .F., .T.,) //"Importar"

    oPanel := oModal:GetPanelMain()

    TSay():New(005, 010, {|| cCabec}, oPanel,,,,,, .T.,,, 205, 030,,,,,, .T., 3)

    oBtnFmt := TButton():New(025, 010, cLbShow, oPanel, {|| T641Tgl(aFlag, oMemo, oBtnFmt, cLbShow, cLbHide) }, 100, 012,,,, .T.,,,,,,)

    oMemo := TMultiGet():New(040, 010, {|| cContrato}, oPanel, 205, 90,,,,,, .T.,,,,,, .T.,,,,, .T.)

    oMemo:Hide()

    oModal:Activate()

Return aRet[1]

//-------------------------------------------------------------------
/*/{Protheus.doc} T641Tgl
Alterna a visibilidade do memo de contrato JSON e atualiza o rótulo do botão correspondente.

@type  function
@author  Denis Souza / Jose Felipe
@since  31/08/2026
@version 1.0
@param aFlag, Array, array de 1 posicao com o estado (.T. = visivel)
@param oMemo, Object, TMultiGet a exibir/ocultar
@param oBtn, Object, TButton cujo rotulo sera trocado
@param cShow, Character, rotulo "exibir formato"
@param cHide, Character, rotulo "ocultar formato"
@return Nil, sem retorno
/*/
//-------------------------------------------------------------------
Static Function T641Tgl(aFlag as array, oMemo as object, oBtn as object, cShow as character, cHide as character)

    aFlag[1] := !aFlag[1]

    If aFlag[1]
        oMemo:Show()
        oBtn:SetText(cHide)
    Else
        oMemo:Hide()
        oBtn:SetText(cShow)
    EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} T641JsTpl
Retorna o contrato JSON esperado pelo importador do TAFA641 em
forma de string, para exibicao no modal de confirmacao. Contempla
um exemplo de conta sintetica ("S") e outro de conta analitica
("A") com detalhamento misto, cobrindo os campos consumidos por
ProcLoad na classe backoffice.taf.dere.tafa641import1011.T641IntCls.

@type  function
@author  Denis Souza / Jose Felipe
@since  31/08/2026
@version 1.0
@return cTpl, Character, contrato JSON em texto formatado
/*/
//-------------------------------------------------------------------
Static Function T641JsTpl()

    Local cTpl := "" as Character

	cTpl := "{"                                                                       		+ CRLF
	cTpl += '  "infoContas": {'                                                       		+ CRLF
	cTpl += '    "infoConta": ['                                                      		+ CRLF
	cTpl += '      {'                                                                 		+ CRLF
	cTpl += '        "cCta": "1",'                                                    		+ CRLF
	cTpl += '        "cCtaInterna": "1000",'                                          		+ CRLF
	cTpl += '        "cDbrMista": "000",'                                             		+ CRLF
	cTpl += '        "nomeCta": "Conta 1",'                                           		+ CRLF
	cTpl += '        "descCta": "",'                                                  		+ CRLF
	cTpl += '        "indCta": "S",'                                                  		+ CRLF
	cTpl += '        "cCtaSup": "",'                                                  		+ CRLF
	cTpl += '        "cCtaRef": "1",'                                                 		+ CRLF
	cTpl += '        "nivelCta": 1,'                                                  		+ CRLF
	cTpl += '        "natCta": "D",'                                                  		+ CRLF
	cTpl += '        "codNat": "1",'                                                  		+ CRLF
	cTpl += '        "codTrib": "",'                                                  		+ CRLF
	cTpl += '        "indTribISS": "",'                                               		+ CRLF
	cTpl += '        "idLeiDisp": "00-00",'                                           		+ CRLF
	cTpl += '        "iniVig": "20261001",'                                           		+ CRLF
	cTpl += '        "fimVig": "20261031"'                                            		+ CRLF
	cTpl += '      },'                                                                		+ CRLF
	cTpl += '      {'                                                                 		+ CRLF
	cTpl += '        "cCta": "2",'                                                    		+ CRLF
	cTpl += '        "cCtaInterna": "2001",'                                          		+ CRLF
	cTpl += '        "cDbrMista": "001",'                                             		+ CRLF
	cTpl += '        "nomeCta": "Conta 2",'                                           		+ CRLF
	cTpl += '        "descCta": "Conta 2 com superior igual a cCtaInterna mais cDbrMista",' + CRLF
	cTpl += '        "indCta": "A",'                                                  		+ CRLF
	cTpl += '        "cCtaSup": "1000000",'                                           		+ CRLF
	cTpl += '        "cCtaRef": "1",'                                                 		+ CRLF
	cTpl += '        "nivelCta": 2,'                                                  		+ CRLF
	cTpl += '        "natCta": "D",'                                                  		+ CRLF
	cTpl += '        "codNat": "1",'                                                  		+ CRLF
	cTpl += '        "codTrib": "110112002",'                                         		+ CRLF
	cTpl += '        "indTribISS": "0",'                                              		+ CRLF
	cTpl += '        "idLeiDisp": "00-00",'                                           		+ CRLF
	cTpl += '        "iniVig": "20261001",'                                           		+ CRLF
	cTpl += '        "fimVig": "20261031"'                                            		+ CRLF
	cTpl += '      }'                                                                 		+ CRLF
	cTpl += '    ]'                                                                   		+ CRLF
	cTpl += '  }'                                                                     		+ CRLF
	cTpl += '}'                                                                       		+ CRLF
	cTpl += CRLF

    cTpl += STR0105 + CRLF //"Observações:"
    cTpl += STR0106 + CRLF //" infoContas \ infoConta é um array de contas."
    cTpl += STR0107 + CRLF //" indCta: 'S' = sintética, 'A' = analítica."
    cTpl += STR0108 + CRLF //" codTrib aceita número (analítica) ou string vazia (sintética)."
    cTpl += STR0109 + CRLF //" iniVig / fimVig no formato AAAAMMDD; fimVig vazio indica vigência em aberto."

Return cTpl

//-------------------------------------------------------------------
/*/{Protheus.doc} Taf641Vld
Função que exibe a janela de aviso de validação.
@type    Function
@author  Denis Souza / Jose Felipe
@since   04/09/2026
@version 1.0
@return Nil
/*/
//-------------------------------------------------------------------
Function Taf641Vld()
	FWMsgRun(, {|| Taf641PVld() }, STR0124, STR0125) //"Validação dos Registros"#"Aguarde alguns minutos."
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Taf641PVld
Processa validação percorrendo todas as linhas da grid T8A do registro 
T7Z posicionado, aplicando as mesmas regras utilizadas pela funcao VLDLinGrid, porém
sem interromper o processo linha a linha: os avisos são concatenados
em um único log em memória e, ao final, apresentados em um modal
consolidado (T641VldMd) que permite ao usuário copiar o log para o
clipboard ou salvá-lo como arquivo TXT.

Diferente da VLDLinGrid, que continua vinculada ao AddGrid do model
e roda a cada gravacao de linha, Taf641Vld:
    - captura T7Z_ID/T7Z_VERSAO do registro posicionado ANTES de
      carregar o model, para nao depender do reposicionamento apos
      o DeActivate;
    - carrega o model TAFA641 em modo MODEL_OPERATION_VIEW via
      FWLoadModel, o que arrasta a grid T8A pelo relacionamento
      T7Z->T8A ja definido em ModelDef;
    - itera pelo tamanho (Length) da grid, ignorando linhas
      IsDeleted (preserva comportamento historico do model);
    - para cada linha aplica o mesmo conjunto de regras em ordem
      de precedencia If/ElseIf da VLDLinGrid;
    - devolve o array acumulado, permitindo bypass da tela quando
      chamado em automacao AdvPR (IsBlind() == .T.) ou lJob == .T.

@type    Function
@author  Denis Souza / Jose Felipe
@since   31/08/2026
@version 1.0
@return aErros, Array, erros no formato { { nLin, cConta, cDesdct, cMsg }, ... }
/*/
//-------------------------------------------------------------------
Function Taf641PVld()

Local oModel      as object
Local oModelT8A   as object
Local aErros      as array
Local aErrosObrg  as array
Local nT8A        as numeric
Local nQtdLin 	  as numeric
Local cCodDesb    as character
Local cIndCta     as character
Local cNivCta     as character
Local cCntSup     as character
Local cCodTri     as character
Local cIndTis     as character
Local cConta      as character
Local cDesNat     as character
Local cT7ZId      as character
Local cT7ZVer     as character
Local aLineMod    as array
Local cAlias 	  as character
Local nRecno 	  as numeric
Local nOpc   	  as numeric
Local lJob   	  as logical
Local oHashCtas   as Object
Local nPre        as Numeric

aErros      := {}
aErrosObrg  := {}
nT8A        := 0
nQtdLin	    := 0
cCodDesb    := ""
cIndCta     := ""
cNivCta     := ""
cCntSup     := ""
cCodTri     := ""
cIndTis     := ""
cConta      := ""
cDesNat     := "" 
cT7ZId      := ""
cT7ZVer     := ""
cAlias 		:= "T7Z"
nRecno 		:= 0
nOpc   		:= 2
lJob   		:= .F.
oHashCtas   := Nil
nPre		:= 0

// Captura a chave do registro posicionado ANTES do FWLoadModel para que a tela consolidada nao dependa do reposicionamento do T7Z apos o DeActivate do model.
cT7ZId  := AllTrim(T7Z->T7Z_ID)
cT7ZVer := AllTrim(T7Z->T7Z_VERSAO)

// Carrega o model em modo Visualizacao para reaproveitar o relacionamento T7Z->T8A ja definido no ModelDef - o tamanho da grid (Length) reflete exatamente o que sera transmitido no evento D-1011.
oModel := FWLoadModel("TAFA641")
oModel:SetOperation(MODEL_OPERATION_VIEW)
oModel:Activate()

oModelT8A := oModel:GetModel("MODEL_T8A")
nQtdLin   := oModelT8A:Length()
// Obtém apenas as linhas que foram alteradas (não inseridas/excluídas)
aLineMod := oModelT8A:GetLinesChanged( MODEL_GRID_LINECHANGED_UPDATED )

//Se a grid tiver ao menos um item e houver modificação, ou se não houver modificação e houver ao menos 2 itens, realiza verificação e validação.
if ( nQtdLin == 1 .and. ( !oModelT8A:IsEmpty() .Or. Len(aLineMod) > 0 ) ) .Or. ( nQtdLin > 1 .And. Len(aLineMod) == 0 )

	// Monta hash com todas as T8A_CONTA do lote para verificacao de conta superior
	oHashCtas := JsonObject():New()
	For nPre := 1 To nQtdLin
		oModelT8A:GoLine(nPre)
		If !oModelT8A:IsDeleted()			
			//Precisa ser indexado com T8A_CONTA + T8A_DESDCT, que é exatamente o formato que o governo usa como cCtaSup:
			oHashCtas["K" + AllTrim(oModelT8A:GetValue("T8A_CONTA")) + AllTrim(oModelT8A:GetValue("T8A_DESDCT"))] := .T.
		EndIf
	Next nPre

	// Regras estruturais de negocio (Desdct, IndCta, CodTri, IndTis...) mantidas separadas pois tem logica condicional propria (If/ElseIf).
	For nT8A := 1 To nQtdLin

		oModelT8A:GoLine(nT8A)

		cCodDesb := oModelT8A:GetValue("T8A_DESDCT")
		cIndCta  := oModelT8A:GetValue("T8A_INDCTA")
		cNivCta  := oModelT8A:GetValue("T8A_NIVCTA")
		cCntSup  := oModelT8A:GetValue("T8A_CNTSUP")
		cCodTri  := oModelT8A:GetValue("T8A_CODTRI")
		cIndTis  := oModelT8A:GetValue("T8A_INDTIS")
		cConta   := oModelT8A:GetValue("T8A_CONTA")
		cDesNat  := oModelT8A:GetValue("T8A_DESNAT")

		If !(Empty(cCodDesb)) .and. Len(AllTrim(cCodDesb)) < 3
			aAdd(aErros, {nT8A, AllTrim(cConta), AllTrim(cCodDesb), "T8A_DESDCT: " + STR0016})
		ElseIf !(Empty(cCodDesb)) .and. !(AllTrim(cCodDesb) == '000') .and. cIndCta == "S"
			aAdd(aErros, {nT8A, AllTrim(cConta), AllTrim(cCodDesb), "T8A_DESDCT: " + STR0020})
		ElseIf !(Empty(cNivCta)) .and. Val(AllTrim(cNivCta)) == 1 .and. !(Empty(cCntSup))
			aAdd(aErros, {nT8A, AllTrim(cConta), AllTrim(cCodDesb), "T8A_CNTSUP: " + STR0022})
		ElseIf !(Empty(cIndCta)) .and. cIndCta == "S" .and. !(Empty(cCodTri))
			aAdd(aErros, {nT8A, AllTrim(cConta), AllTrim(cCodDesb), "T8A_CODTRI: " + STR0024})
		ElseIf !(Empty(cIndCta)) .and. cIndCta == "A" .and. Empty(cCodTri)
			aAdd(aErros, {nT8A, AllTrim(cConta), AllTrim(cCodDesb), "T8A_CODTRI: " + STR0026})
		ElseIf !(Empty(cIndCta)) .and. cIndCta == "A" .and. Empty(cIndTis)
			aAdd(aErros, {nT8A, AllTrim(cConta), AllTrim(cCodDesb), "T8A_INDTIS: " + STR0027})
		ElseIf !(Empty(cIndCta)) .and. cIndCta == "S" .and. !(Empty(cIndTis))
			aAdd(aErros, {nT8A, AllTrim(cConta), AllTrim(cCodDesb), "T8A_INDTIS: " + STR0029})
		EndIf
		/*
		No leiaute (campo cCtaSup), a regra de dispensa é só nivelCta = 1; para qualquer nível > 1, a conta pai é obrigatória, 
		independente de ser sintética ou analítica. Então o certo é inverter a lógica: entrar no bloco sempre que nivelCta > 1, 
		e dentro dele tratar dois erros distintos: "não informou" vs. "informou mas não existe".
		Verifica se a conta superior é obrigatória e, quando informada, se existe no lote
		(regra independente das regras acima, vale para SINTÉTICA e ANALÍTICA, exceto nível 1/raiz)
		*/
		If !(Empty(cNivCta)) .And. Val(AllTrim(cNivCta)) > 1
			If Empty(cCntSup)
				aAdd(aErros, {nT8A, AllTrim(cConta), AllTrim(cCodDesb), "T8A_CNTSUP: " + STR0139 }) //"Conta superior deve ser informada para conta que não seja de nível 1 (raiz)."
			ElseIf !oHashCtas:HasProperty("K" + AllTrim(cCntSup))
				aAdd(aErros, {nT8A, AllTrim(cConta), AllTrim(cCodDesb), "T8A_CNTSUP: " + STR0140 }) //"Conta superior informada não foi encontrada em Cod Conta + Cod Desdob."
			EndIf
		EndIf
		// descCta (T8A_DESNAT) obrigatorio para conta analitica (indCta = "A")
		// Regra do governo: O preenchimento do campo [descCta] e obrigatorio se a conta for analitica.
		If !(Empty(cIndCta)) .And. cIndCta == "A" .And. Empty(AllTrim(cDesNat))
			aAdd(aErros, {nT8A, AllTrim(cConta), AllTrim(cCodDesb), "T8A_DESNAT: " + STR0148 }) //"Descrição da conta obrigatória para conta analítica (indCta = A)."
		EndIf
	Next nT8A
	If !(oHashCtas == Nil)
		FreeObj(oHashCtas)
		oHashCtas := Nil
	EndIf

	// Acumula erros de campos obrigatorios usando a mesma lista centralizada em T8AVldCampos - merge no array principal.
	aErrosObrg := T8AVldCampos( oModelT8A )
	AEval( aErrosObrg, { |aItem| aAdd( aErros, aItem ) } )

	oModel:DeActivate()
	oModel := Nil

	T641VldMd( aErros, nQtdLin )

else
	MsgAlert(STR0080) //"Não foram encontrados registros ou modificações na tabela de contas, realize a integração, importação ou inclua manualmente as contas para prosseguir."
endif

Return aErros

//-------------------------------------------------------------------
/*/{Protheus.doc} T8AVldCampos
Percorre todas as linhas nao deletadas do model da grid T8A e
verifica se os campos obrigatorios estao preenchidos.

Os campos sao definidos em um array interno { campo, titulo } para
que futuras alteracoes na lista se concentrem em um unico lugar.
Cada violacao gera uma entrada no formato padrao do log consolidado:
{ nLin, cConta, cDesdct, cMsg }.

O retorno acumula erros de TODAS as linhas (sem Exit/Loop antecipado),
permitindo exibir um log completo de uma so vez via T641VldMd.

@type   Static Function
@author  Denis Souza / Jose Felipe
@since  01/09/2026
@version 1.0

@param  oModelT8A  Object  Model da grid T8A ja posicionado
@return aErros     Array   { { nLin, cConta, cDesdct, cMsg }, ... }
/*/
//-------------------------------------------------------------------
Static Function T8AVldCampos( oModelT8A )

Local aCampos  := {}  as array
Local aErros   := {}  as array
Local nLin     := 0   as numeric
Local nCampo   := 0   as numeric
Local cConta   := ""  as character
Local cCodDesb := ""  as character
Local xValue   := Nil

Default oModelT8A := Nil

aCampos := {}
aAdd( aCampos, { "T8A_CONTA" , "Cod Conta"   } )
aAdd( aCampos, { "T8A_DESDCT", "Cod Desdob." } )
aAdd( aCampos, { "T8A_DESCCT", "Desc Conta"  } )
aAdd( aCampos, { "T8A_INDCTA", "Tipo"        } )
aAdd( aCampos, { "T8A_CODREF", "Cod Cta Ref" } )
aAdd( aCampos, { "T8A_NIVCTA", "Nivel"       } )
aAdd( aCampos, { "T8A_NATCTA", "Nat Cta"     } )
aAdd( aCampos, { "T8A_CODNAT", "Cod Nat"     } )
aAdd( aCampos, { "T8A_INIVIG", "Ini Vigencia"} )

For nLin := 1 To oModelT8A:Length()
    oModelT8A:GoLine( nLin )
    If oModelT8A:IsDeleted()
        Loop
    EndIf
    cConta   := oModelT8A:GetValue( "T8A_CONTA"  )
    cCodDesb := oModelT8A:GetValue( "T8A_DESDCT" )
    For nCampo := 1 To Len( aCampos )
		xValue := oModelT8A:GetValue( aCampos[nCampo][1] )
        If ( aCampos[nCampo][1] <> "T8A_INIVIG" .And. Empty( AllTrim( xValue ) ) ) .Or. ( aCampos[nCampo][1] == "T8A_INIVIG" .And. DTOC(xValue) == "  /  /    " )
            aAdd( aErros, { nLin, AllTrim(cConta), AllTrim(cCodDesb), aCampos[nCampo][1] + " (" + aCampos[nCampo][2] + "): " + STR0081 } ) //"Campo obrigatório não preenchido."
        EndIf
    Next nCampo
Next nLin

Return aErros

//-------------------------------------------------------------------
/*/{Protheus.doc} T641VldMd
Modal apresentado pela Taf641Vld ao final da validacao consolidada
na tabela de contas. Exibe o cabeçalho com totais em um painel superior fixo e
as inconsistências num LISTBOX com colunas (Linha | Conta | Desdct |
Mensagem), garantindo alinhamento correto independente de fonte.
Oferece botoes para copiar o log (texto tabulado) para o clipboard
ou grava-lo em arquivo TXT.

Quando o array de erros está vazio, o LISTBOX exibe uma linha de
sucesso; os botoes de copiar/salvar permanecem funcionais para que
o usuário possa arquivar o comprovante.

@type    Static Function
@author  Denis Souza / Jose Felipe
@since   31/08/2026
@version 1.0
@param aErros,  Array,     erros no formato { { nLin, cConta, cDesdct, cMsg }, ... }
@param nTotLin, Numeric,   quantidade de linhas percorridas na grid T8A
@param cT7ZId,  Character, chave T7Z_ID do registro validado (para cabecalho)
@param cT7ZVer, Character, versao T7Z_VERSAO do registro validado (para cabecalho)
@param cTitle,  Character, título da modal
@return Nil
/*/
//-------------------------------------------------------------------
Static Function T641VldMd(aErros, nTotLin, cTitle)

Local oModal      as object
Local oPanelTop   as object
Local oPanelList  as object
Local oList       as object
Local aLinhas     as array
Local cLog        as character
Local cLogCopia   as character
Local cResumo     as character
Local nI          as numeric
Local nTmCt       as numeric

Default aErros  := {}
Default nTotLin := 0
Default cTitle  := STR0082 //"Resultado da validação"

aLinhas   := {}
cLog      := ""
cLogCopia := ""
cResumo   := ""
nI        := 0
nTmCt     := FWSX3Util():GetFieldStruct("T8A_CONTA")[3]

// ---------------------------------------------------------------
// Ordena o array de erros por Conta (pos 2) e Desdct (pos 3) para
// agrupar todas as mensagens da mesma conta+desdobramento juntas.
// ---------------------------------------------------------------
If Len(aErros) > 1
    ASort(aErros,,, {|x, y| AllTrim(x[2]) + AllTrim(x[3]) < AllTrim(y[2]) + AllTrim(y[3])})
EndIf

// ---------------------------------------------------------------
// Monta o array de linhas para o LISTBOX — 4 colunas:
// [1] Linha (numero da linha na grid, ex: 001) [2] Conta (T8A_CONTA) [3] Desdct (T8A_DESDCT) [4] Mensagem
// ---------------------------------------------------------------
If Len(aErros) == 0
	AAdd(aLinhas, {"", "", "", STR0147}) //"Não foram encontrados erros críticos."
Else
    For nI := 1 To Len(aErros)
        AAdd(aLinhas, { StrZero(aErros[nI][1], 6), AllTrim(aErros[nI][2]), AllTrim(aErros[nI][3]), aErros[nI][4] } )
    Next nI
EndIf

// ---------------------------------------------------------------
// Monta o texto do log (para Copiar/Salvar)
// ---------------------------------------------------------------
cLog := STR0085 + AllTrim(Str(nTotLin)) + CRLF + STR0086 + AllTrim(Str(Len(aErros))) + CRLF //"Linhas validadas: "#"Inconsistências : "

If Len(aErros) == 0
    cLog += CRLF + STR0147 + CRLF //"Não foram encontrados erros críticos."
Else
    cLog += CRLF + STR0088 + CRLF //"--- Detalhamento das inconsistências ---"
    cLog += PadR(STR0089 , 7) + " | " + PadR(STR0090, nTmCt) + " | " + PadR(STR0091, 6) + " | " + STR0092 + CRLF //"Linha"#"Conta"#"Desdct"#"Mensagem"
    cLog += Replicate("-", 7) + "-+-" + Replicate("-", nTmCt) + "-+-" + Replicate("-", 6) + "-+-" + Replicate("-", 60) + CRLF
    For nI := 1 To Len(aErros)
        cLog += PadR( StrZero(aErros[nI][1], 6), 7) + " | " + PadR(AllTrim(aErros[nI][2]), nTmCt) + " | " + PadR(AllTrim(aErros[nI][3]), 6) + " | " + aErros[nI][4] + CRLF
    Next nI
EndIf

cLogCopia := cLog

// ---------------------------------------------------------------
// Monta o dialogo
// ---------------------------------------------------------------
oModal := FWDialogModal():New()
oModal:SetTitle(cTitle)
oModal:SetSubTitle(STR0093) //"Copie ou salve o log consolidado."
oModal:SetFreeArea(450, 220)
oModal:SetEscClose(.T.)
oModal:SetBackground(.T.)
oModal:CreateDialog()

cResumo := STR0094 + AllTrim(Str(nTotLin)) + "  |  " + STR0095 + AllTrim(Str(Len(aErros))) //"Qtd. Registros Verificados: "#"Inconsistências: "
oPanelTop := TPanel():New(,,, oModal:GetPanelMain())
oPanelTop:nHeight := 020
oPanelTop:Align   := CONTROL_ALIGN_TOP
@ 004, 006 SAY cResumo SIZE 440, 012 OF oPanelTop PIXEL

// Painel de lista (ocupa o restante da area util)
oPanelList := TPanel():New(,,, oModal:GetPanelMain())
oPanelList:Align := CONTROL_ALIGN_ALLCLIENT

// LISTBOX com 4 colunas: Linha | Conta | Desdct | Mensagem
@ 000, 000 LISTBOX oList FIELDS HEADER STR0089, STR0090, STR0091, STR0092 FIELDSIZES 40, 100, 40, 220 SIZE 000, 000 PIXEL OF oPanelList //"Linha"#"Conta"#"Desdct"#"Mensagem"
oList:Align := CONTROL_ALIGN_ALLCLIENT
oList:SetArray(aLinhas)
oList:bLine := {|| {aLinhas[oList:nAt][1], aLinhas[oList:nAt][2], aLinhas[oList:nAt][3], aLinhas[oList:nAt][4]}}

If GetRemoteType() <> 5 // Smart Client versão HTML.
	oModal:AddButtons({{0,STR0098,{|| T641VldSv(@cLogCopia)},STR0099, 0, .T.,.T.}}) //"Salvar"#"Salvar log como .TXT"
endif

oModal:AddCloseButton(Nil, STR0100) //"Fechar"

oModal:Activate()

FreeObj(oModal)
oModal := Nil

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} T641VldSv
Abre dialogo "salvar como" no cliente e grava o conteudo do log de
validacao em arquivo TXT via cGetFile + MemoWrite. Quando a gravação
e bem-sucedida, acrescenta ao final do log em memoria o caminho do
arquivo (por referência), disponibilizando a informação ao chamador.

@type    Static Function
@author  Denis Souza / Jose Felipe
@since   31/08/2026
@version 1.0
@param cLog, Character, conteudo textual do log a salvar (passado por referencia)

@obs CA1001-2 (linha 1473): cGetFile e MemoWrite (linha 1480) operam no filesystem do servidor/SmartClient. 
Em ambiente SmartERP com filesystem compartilhado, GetTempPath() pode apontar para um diretório não acessível 
ou compartilhado entre sessões, causando colisão de arquivos entre usuários simultâneos.

O MemoWrite só executa sobre cArq, que é o caminho que o usuário efetivamente escolheu e confirmou no diálogo.
Se dois usuários abrirem o diálogo ao mesmo tempo, cada um escolhe seu próprio destino, não há gravação automática em GetTempPath().

O CA1001-2 é um falso positivo neste contexto. 
A sugestão seria válida se o arquivo fosse gravado silenciosamente em GetTempPath() sem diálogo, 
mas aqui GetTempPath() + cNomeSug é apenas o valor padrão pré-preenchido no seletor de arquivo,
o usuário sempre confirma ou altera o destino antes de qualquer gravação acontecer.

@return Nil
/*/
//-------------------------------------------------------------------
Static Function T641VldSv(cLog)

Local cArq      := ""  as character
Local cNomeSug  := ""  as character
Local lOk       := .F. as logical

Default cLog := ""

// Nome sugerido com usuario, data e hora para facilitar identificacao no diretorio escolhido pelo usuario.
cNomeSug := "taf641_vld_" + cUserName + "_" + DToS(Date()) + "_" + StrTran(Time(), ":", "") + ".txt"

// CA1001-2: GetTempPath()+cNomeSug e apenas valor pré-preenchido no diálogo, o usuário confirma o destino antes de qualquer gravação.
cArq := cGetFile("*.txt", STR0101, 1, GetTempPath() + cNomeSug, .F.) //"Selecione um local e digite o nome do arquivo..."

If !Empty(cArq)
    lOk := .T.
EndIf

If lOk
    If MemoWrite(cArq, cLog) //Acrescenta o caminho ao final do log (por referencia) para que o chamador possa usar o valor atualizado se necessario.
        cLog += CRLF + "===" + CRLF + STR0102 + CRLF + cArq //"Salvo em:"
		MsgInfo( STR0110 + CRLF + cArq ) //"Arquivo Salvo em: "
    Else
        MsgAlert( STR0103 + CRLF + CRLF + STR0104 + CRLF + cArq ) //"Falha ao salvar o log."#"no caminho:"
    EndIf
EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} T641AStruSave
Estrutura da tabela para salvar o bulk.

@type    Static Function
@author  Denis Souza / Jose Felipe
@since   31/08/2026
@version 1.0
@return aStru, array com a estrutura
/*/
//-------------------------------------------------------------------
Static Function T641AStruSave()

	Local aStru as array
	aStru := {}
	AAdd(aStru, {"T8A_FILIAL", "C", FWSX3Util():GetFieldStruct("T8A_FILIAL")[3], 0})
	AAdd(aStru, {"T8A_ID"    , "C", FWSX3Util():GetFieldStruct("T8A_ID"    )[3], 0})
	AAdd(aStru, {"T8A_VERSAO", "C", FWSX3Util():GetFieldStruct("T8A_VERSAO")[3], 0})
	AAdd(aStru, {"T8A_ATIVO" , "C", FWSX3Util():GetFieldStruct("T8A_ATIVO" )[3], 0})
	AAdd(aStru, {"T8A_CONTA" , "C", FWSX3Util():GetFieldStruct("T8A_CONTA" )[3], 0})
	AAdd(aStru, {"T8A_DESDCT", "C", FWSX3Util():GetFieldStruct("T8A_DESDCT")[3], 0})
	AAdd(aStru, {"T8A_DESCCT", "C", FWSX3Util():GetFieldStruct("T8A_DESCCT")[3], 0})
	AAdd(aStru, {"T8A_INDCTA", "C", FWSX3Util():GetFieldStruct("T8A_INDCTA")[3], 0})
	AAdd(aStru, {"T8A_DESNAT", "M", FWSX3Util():GetFieldStruct("T8A_DESNAT")[3], 0})
	AAdd(aStru, {"T8A_CNTSUP", "C", FWSX3Util():GetFieldStruct("T8A_CNTSUP")[3], 0})
	AAdd(aStru, {"T8A_CODREF", "C", FWSX3Util():GetFieldStruct("T8A_CODREF")[3], 0})
	AAdd(aStru, {"T8A_NIVCTA", "C", FWSX3Util():GetFieldStruct("T8A_NIVCTA")[3], 0})
	AAdd(aStru, {"T8A_NATCTA", "C", FWSX3Util():GetFieldStruct("T8A_NATCTA")[3], 0})
	AAdd(aStru, {"T8A_CODNAT", "C", FWSX3Util():GetFieldStruct("T8A_CODNAT")[3], 0})
	AAdd(aStru, {"T8A_CODTRI", "C", FWSX3Util():GetFieldStruct("T8A_CODTRI")[3], 0})
	AAdd(aStru, {"T8A_INDTIS", "C", FWSX3Util():GetFieldStruct("T8A_INDTIS")[3], 0})
	AAdd(aStru, {"T8A_IDLEID", "C", FWSX3Util():GetFieldStruct("T8A_IDLEID")[3], 0})
	AAdd(aStru, {"T8A_INIVIG", "D", FWSX3Util():GetFieldStruct("T8A_INIVIG")[3], 0})
	AAdd(aStru, {"T8A_FIMVIG", "D", FWSX3Util():GetFieldStruct("T8A_FIMVIG")[3], 0})

Return aStru

//-------------------------------------------------------------------
/*/{Protheus.doc} MotExc1011
Função responsável por exibir tela de Motivo de Exclusão
Permite informar o motivo da exclusão e número do processo
@author Rafael de Paula Leme
@since 17/08/2026
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MotExc1011(cAlias)

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
			cMotivoExc := "1-" + STR0126 //"Determinação judicial ou administrativa"
		Case (cAlias)->&(cAlias + "_MOTEXC") == "2"
			cMotivoExc := "2-" + STR0127 //"Envio indevido (fato inexistente)"
		Case (cAlias)->&(cAlias + "_MOTEXC") == "3"
			cMotivoExc := "3-" + STR0128 //"Erro na identificação (CNPJ/período incorretos)"
		Case (cAlias)->&(cAlias + "_MOTEXC") == "9"
			cMotivoExc := "9-" + STR0129 //"Outro"
	EndCase
EndIf

If !Empty((cAlias)->&(cAlias + "_NRPROC"))
	cNrProcesso := PadR((cAlias)->&(cAlias + "_NRPROC"), 21)
EndIf

// Monta array com as opções da combo
aAdd(aMotivos, "1-" + STR0126) //"Determinação judicial ou administrativa"
aAdd(aMotivos, "2-" + STR0127) //"Envio indevido (fato inexistente)"
aAdd(aMotivos, "3-" + STR0128) //"Erro na identificação (CNPJ/período incorretos)"
aAdd(aMotivos, "9-" + STR0129) //"Outro"

// Define a dialog
Define MsDialog oDlg Title STR0130 From 000,000 To 200,400 Pixel //"Motivo da Exclusão"

	@ 015,010 Say STR0130 + ":" Size 060,008 Of oDlg Pixel //"Motivo da Exclusão"
	@ 013,070 ComboBox oComboMotiv Var cMotivoExc Items aMotivos Size 120,010 Of oDlg Pixel
	
	@ 035,010 Say STR0131 + ":" Size 060,008 Of oDlg Pixel //"Número do Processo"
	@ 033,070 Get oGetNrProc Var cNrProcesso Size 120,010 Of oDlg Pixel Valid .T.
	
	@ 070,070 Button STR0132 Size 040,012 Of oDlg Pixel Action (lConfirma := .T., oDlg:End()) //"Salvar"
	@ 070,120 Button STR0133 Size 040,012 Of oDlg Pixel Action (lConfirma := .F., oDlg:End()) //"Cancelar"

Activate MsDialog oDlg Centered

// Se confirmou, grava os dados
If lConfirma
	If SubStr(cMotivoExc, 1, 1) == '1' .and. Empty(AllTrim(cNrProcesso))
		MsgAlert(STR0134 + CRLF + STR0135) //"O campo Número do Processo é obrigatório quando o motivo da exclusão é a opção 1." //"O motivo da exclusão não será gravado."
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
		MsgInfo(STR0136, STR0130) //"Dados gravados com sucesso!" //"Motivo da Exclusão"
	EndIf
EndIf

Return
