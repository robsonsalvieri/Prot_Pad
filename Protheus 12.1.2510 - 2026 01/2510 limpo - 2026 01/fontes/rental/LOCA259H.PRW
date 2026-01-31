#Include "loca259h.ch"
#INCLUDE "TOTVS.CH"
#include "FWMVCDEF.CH"
#INCLUDE "FWEditPanel.CH "

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
MODELO de estorno de A.S. na demanda
@type function
@version 24.10
@author Alexandre Circenis
@since 2/27/2025
/*/
//-------------------------------------------------------------------/*/
Static Function ModelDef()
local oModel    := FWLoadModel("LOCA259C")

oModel := Loca259HMD(oModel)
oModel:GetModel("GRID"):bLoad :=   {|oGrid| Loca259HLG(oGrid)}
//Adicionando descrição ao modelo
oModel:SetDescription( "A.S. Separadas") //"A.S. DIPONIVEL"
// Adiciona a descricao do Componente do Modelo de Dados
//  oModel:GetModel( 'CABEC' ):SetDescription( 'MODEL FAKE' )
oModel:GetModel( 'GRID' ):SetDescription( "A.S. Separadas" ) //"A.S. Disponiveis"
//  oModel:SetPrimaryKey( { 'X_ZMVC' } )
   
Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Função estática do ViewDef Estorno Separação
@type function
@version 24.10 
@author Alexandre Circenis
@since 2/12/2025
@return variant, retorna o objeto view
/*///-------------------------------------------------------------------/*/
Static Function ViewDef()
	local oView    := FwLoadView("LOCA259C")
	local oModel   := FWLoadModel( 'LOCA259H' )

oView := LOCA259HVI(oView, oModel)
oView:SetViewAction("BUTTONOK", { |oView| Loca259HOk()})
oView:SetDescription( STR0019 )  //"Itens Separados"

Return oView

/*/{Protheus.doc} Loca259BFl
Define a lista de campos usado pelo MODEL e VIEW
@type function
@version 24.10 
@author Alexandre Circenis
@since 2/27/2025
@return variant, Bloco de codigo com os campos usado pelo model e view
/*/
Static Function Loca259BFl()
	bCampos := {|cCampo| cCampo $ "FQ5_FILORI FQ5_AS     FQ5_VIAGEM FQ5_DATGER FQ5_HORGER FQ5_XPROD   FQ5_XQTD  FQ5_GUINDA FQ5_DTINI  FQ5_DTFIM  FQ5_QTD2   FQ5_SOT    FQ5_OBRA   FQ5_STATUS FQ5_PESLIQ  FQ5_PESBRU  FQ5_M3      " }

Return bCampos

/*/{Protheus.doc} Loca259LdG
Função para gerar a carga do model conforme os parametros de entrada na rotina
@type function
@version 24.10
@author Alexandre Circenis
@since 2/27/2025
@param oMdl, object, model a ser preenchido
@return variant, array com os dados no formato do model
/*/
Static Function Loca259HLG( oMdl)

	Local aArea      := GetArea()
	Local cAliasT    := GetNextAlias()
	Local aDados     := {}
	Local aStruQry   := {}
	Local nLinha     := 0
	Local cQuery 	:= ''
	Local cTmp		:= ''
	Local aParam    := {}

	cTmp := GetNextAlias()
	
	cQuery += "SELECT FQ5.*,FPA.FPA_LOCAL, FPA.FPA_DESGRU, SB1.B1_DESC, 'F' MARK
	
	cQuery += " FROM " + RetSqlName("FQ5") + " FQ5 "  					//-- Cadastro de Viagem

	cQuery += " INNER JOIN  " +	RetSqlName("FPA") + " FPA "  					//-- AgendametosS Itens
	cQuery += " ON  FPA.FPA_FILIAL  =  '" + xFilial("FPA") + "' "
	cQuery += " AND	FPA.FPA_AS = FQ5.FQ5_AS"
	cQuery += " AND	FPA.FPA_TIPOSE = 'L'"
	cQuery += " AND	FPA.FPA_NFREM = ''"

	cQuery += " AND	FPA.D_E_L_E_T_  =  ' ' "

	cQuery += " INNER JOIN  " +	RetSqlName("SB1") + " SB1 "  					//-- AgendametosS Itens
	cQuery += " ON  SB1.B1_FILIAL  =  '" + xFilial("SB1") + "' "
	cQuery += " AND	SB1.B1_COD = FQ5_XPROD"
	cQuery += " AND	SB1.D_E_L_E_T_  =  ' ' "

	cQuery += " LEFT JOIN  " +	RetSqlName("ST9") + " ST9 "  					//-- Solicitantes
	cQuery += " ON  ST9.T9_FILIAL  =  '" + xFilial("ST9") + "' "
	cQuery += " AND ST9.T9_CODBEM  =  FQ5.FQ5_GUINDA "
	cQuery += " AND ST9.D_E_L_E_T_  =  ' ' "

	cQuery += " WHERE FQ5.FQ5_FILIAL = '" + xFilial("FQ5") + "' "

	cQuery += " AND  FQ5_DEMAND = ?" // AS não ligada a demanda
    aadd( aParam, FQT->FQT_DEMAND)
	cQuery += " AND  FQ5_TPAS = 'L'" // AS do tipo Locação
	cQuery += " AND  FQ5_STATUS = '6'" // AS Separada

	cQuery += " AND NOT EXISTS ( " // AS Está num Romaneio
	cQuery += " SELECT  FQ3_AS "
	cQuery += " FROM " + RetSqlName("FQ3") +" FQ3 "
	cQuery += " WHERE FQ3_FILIAL = '"+xFilial("FQ3")+"'"
	cQuery += " AND FQ3_AS = FQ5.FQ5_AS "
	cQuery += " AND FQ3.D_E_L_E_T_ = ' ')"

	cQuery += " AND NOT EXISTS ( " // AS Está num Pedido
	cQuery += " SELECT  FPZ_AS "
	cQuery += " FROM " + RetSqlName("FPZ") +" FPZ "
	cQuery += " WHERE FPZ_FILIAL = '"+xFilial("FPZ") +"'"
	cQuery += " AND FPZ_AS = FQ5.FQ5_AS "
	cQuery += " AND FPZ.D_E_L_E_T_ = ' ')"
	cQuery += " ORDER BY FQ5_SOT, FQ5_OBRA, FQ5_AS"

	cQuery := ChangeQuery(cQuery)

//-- Executa QUERY
	MPSysOpenQuery(cQuery,cAliasT,,,aParam)

//-- Formata Campos Da Query
	aStruQry := (cAliasT)->(DbStruct())

	For nLinha := 1 To Len(aStruQry)
		If GetSX3Cache(aStruQry[nLinha][1],"X3_TIPO") == "D" .Or. GetSX3Cache(aStruQry[nLinha][1],"X3_TIPO") == "N"
			TCSetField( cAliasT , aStruQry[nLinha][1], GetSX3Cache(aStruQry[nLinha][1],"X3_TIPO"), GetSX3Cache(aStruQry[nLinha][1],"X3_TAMANHO") , GetSX3Cache(aStruQry[nLinha][1],"X3_DECIMAL"))
		Endif
	Next nLinha
	TCSetField( cAliasT , "MARK", "L")
/*
FWLoadByAlias
Função que realiza a carga de um submodelo baseado em um alias existente

@param oObj         Objeto do submodelo (FWFormFieldsModel ou FWFormGridModel)
@param cAlias       Alias para carga .
@param cAliasReal   Alias Real. Utilizado para carga de campos MEMO reais na tabela, se houver e para uso real de inicializadores padrao, 
	                                                           se nao for informado usa a tabela definida na estrutura do objeto.
@param cFieldRecno  Nome do campo que contem o numero do recno. Quando a tabela foi criada a partir de uma query
	                                                           deve ter uma coluna contendo o recno() real do registro. Se o nome desta coluna for R_E_C_N_O_ ou 
	                                                           RECNO ou Alias+RECNO, nao é preciso informar o nome da coluna neste parametro, caso contrario deve-se informar.
@param lCopy        Apenas para compatibilidade, Nao usar
@param lQuery       Indica que o alias foi criado a partir de uma query.
*/

// Como tem o campo R_E_C_N_O_, nao é preciso informar qual o campo contem o Recno() real
	aDados := FWLoadByAlias( oMdl , cAliasT , 'FQ5' , Nil , Nil , .t. )

//-- Fecha Arquivo Temporário
	If Select(cAliasT) > 0
		(cAliasT)->(DbCloseArea())
	EndIf

	RestArea(aArea)

Return( aDados )

/*/{Protheus.doc} LOCA259HCHK
Processa a marcação de um item da Grid 
@type function
@version 24.10
@author Alexandre Circenis
@since 2/27/2025
@return variant, returna .T.
/*/
FUNCTION LOCA259HCHK()
	Local oModel := FwModelActive()
	Local oGrid  := oModel:GetModel("GRID")


	if FwFldGet("MARK")

		// Gatilhar os campos calculados 
		if Empty(FwFldGet("QTDNEW"))

			oGrid:LoadValue( "QTDNEW", FWFldGet("FQ5_XQTD"))

		endif

	else

		oGrid:LoadValue( "QTDNEW", 0 )

	endif

Return .T.

/*/{Protheus.doc} Loca259HOk
Botão de ação para Estornar a separação
@type function
@version 25.10
@author Alexandre Circenis
@since 5/19/2025
@return variant, return true por ser como prova de sucesso.
/*/
FUNCTION  Loca259HOk()
Local oModel := FwModelActive()
Local oGrid  := oModel:GetModel("GRID")
Local aAlteradas := oGrid:GetLinesChanged(MODEL_GRID_LINECHANGED_ALL)
Local _nItem
Local cMsg    := ""
Local aRomaneios := {}
Local nX

private lImplemento := LOCA059B1("FQG_FILIAL", "FQG") .and. GETMV("MV_NG1LOC",,.F.)

	Begin Transaction
		//Passa em todos os itens, verifica se está marcada
		//caso sim, diminui a quantidade e gera uma nova
		For _nItem := 1 To Len(aAlteradas)
			IncProc()
			oGrid:Goline(aAlteradas[_nItem])
			//No registro atual da FPA - reduz a quantidade atual, conforme a quantidade passada
			If FwFldGet("MARK") 

				FQ5->(dbGoTo(oGrid:GetDataID()))  //Posiciona no registro da FQ5
				cMsg += Loca05906(.T.)

				if FQ5->FQ5_STATUS = '1' // Voltou para aberto
				
					RecLock("FQ5", .F.)
					FQ5->FQ5_STDEMA := '1'
					FQ5->(msUnlock())
		
					dbSelectArea("FQT")
					if FQT->FQT_DEMAND <> FQ5->FQ5_DEMAND
						FQT->(dbSetOrder(1))
						FQT->(dbSeek(xFilial("FQT")+FQ5->FQ5_DEMAND))
					endif
					RecLock("FQT", .F.)
					FQT->FQT_SEPARA := FQT->FQT_SEPARA - FQ5->FQ5_XQTD
					FQT->FQT_PENDEN := FQT->FQT_PENDEN + FQ5->FQ5_XQTD
					msUnlock()
			
					// Verificar se está no romaneio e ajustar
					IF !Empty(FQ5->FQ5_XROMAN)
						FQV->(dbSetOrder(2))
						if FQV->(dbSeek(xFilial("FQV")+FQ5->FQ5_AS))
							RecLock("FQV", .F.)
							FQV->FQV_STATUS := FQ5->FQ5_STATUS
							msUnLock()
							if Len(aRomaneios) = 0 .or. aScan(aRomaneios,FQ5->FQ5_XROMAN) = 0
							Aadd(aRomaneios, FQ5->FQ5_XROMAN)
							endif   
						endif
					endif
				endif
			endif
		next
		// Processar o romaneios para marcar as separações
		For nX := 1 to Len(aRomaneios)
			FQU->(dbSetOrder(1))
			FQU->(dbSeek(xFilial("FQU")+aRomaneios[nX]))
			RecLock("FQU", .F.)
			FQU->FQU_STATUS := '2' // Em Separaçao
			MsUnlock()
		next

	END TRANSACTION

	if !Empty(cMsg)
		Aviso(STR0001,cMsg,{"Ok"}) //"Problemas no estorno da separação"
	endif

Return .T.


/*/{Protheus.doc} LOCA259HMD
Função com as definições do model do estorno da separação
@type function
@version 25.10
@author Alexandre Circenis
@since 5/19/2025
@return variant, return o model definido
/*/
FUNCTION LOCA259HMD( oModel)
//   local oStrCampo as object
local oStrGrid  as object

//Estrutura de Grid
oStrGrid := FWFormStruct( 1, "FQ5", Loca259BFl() )
oStrGrid:AddField('', ' ', 'MARK', 'L', 1, 0, , , {}, .F.,FWBuildFeature( STRUCT_FEATURE_INIPAD,".F."),,, .T.)
oStrGrid:AddField(STR0002, ' ', 'B1_DESC', 'C',TamSx3("B1_DESC")[1], 0, , , {}, .F.)  //"Desc"
oStrGrid:AddField(STR0003, ' ', 'FPA_LOCAL', 'C',TamSx3("FPA_LOCAL")[1], 0, , , {}, .F.)  //"Armazem"
oStrGrid:AddField(STR0004, ' ', 'FPA_DESGRU', 'C',TamSx3("FPA_DESGRU")[1],0, , , {}, .F.)  //"Desc Equip"
oStrGrid:AddField(STR0005, ' ', 'QTDNEW', 'N', TamSx3("FQ5_XQTD")[1], TamSx3("FQ5_XQTD")[2], , , {}, .F.)  //"Qtde Nova"
oStrGrid:AddField( ;
                        AllTrim('') , ; 			// [01] C Titulo do campo
                        AllTrim('') , ; 			// [02] C ToolTip do campo
                        'LEGEND' , ;               // [03] C identificador (ID) do Field
                        'C' , ;                     // [04] C Tipo do campo
                        50 , ;                      // [05] N Tamanho do campo
                        0 , ;                       // [06] N Decimal do campo
                        NIL , ;                     // [07] B Code-block de validação do campo
                        NIL , ;                     // [08] B Code-block de validação When do campo
                        NIL , ;                     // [09] A Lista de valores permitido do campo
                        NIL , ;                     // [10] L Indica se o campo tem preenchimento obrigatório
                        { || if( FQ5->FQ5_STATUS == "1", 'BR_VERDE' ,; //  PENDENTE
				 			 if(!FQ5->FQ5_STATUS $ "1/6"  , 'BR_VERMELHO' ,; //  REJEITADO
						     if(FQ5->FQ5_STATUS == "6", 'BR_LARANJA' , 'BR_BRANCO')))} , ;  		// [11] B Code-block de inicializacao do campo
                        NIL , ;                     // [12] L Indica se trata de um campo chave
                        NIL , ;                     // [13] L Indica se o campo pode receber valor em uma operação de update.
                        .T. )                       // [14] L Indica se o campo é virtual

oStrGrid:SetProperty("QTDNEW",MODEL_FIELD_WHEN, FWBuildFeature(STRUCT_FEATURE_WHEN, ".F." ))
oStrGrid:SetProperty("FQ5_QTD2",MODEL_FIELD_WHEN, FWBuildFeature(STRUCT_FEATURE_WHEN, ".F." ))
oStrGrid:SetProperty("FQ5_PESLIQ",MODEL_FIELD_WHEN, FWBuildFeature(STRUCT_FEATURE_WHEN, ".F." ))
oStrGrid:SetProperty("FQ5_PESBRU",MODEL_FIELD_WHEN, FWBuildFeature(STRUCT_FEATURE_WHEN, ".F." ))
oStrGrid:SetProperty("FQ5_M3",MODEL_FIELD_WHEN, FWBuildFeature(STRUCT_FEATURE_WHEN, ".F." ))

oStrGrid:SetProperty("MARK",MODEL_FIELD_VALID, FWBuildFeature(STRUCT_FEATURE_VALID,"LOCA259HCHK()" ))

//Atribuindo formulários para o modelo
// oModel:AddFields('CABEC', , oStrCampo ,,,{|oSub| LOCA259BCL(oSub) })
oModel:AddGrid( 'GRID', 'CABEC', oStrGrid, , , , ,)
//oModel:GetModel( 'GRID' ):SetLoadFilter( aFilter )
//Setando a chave primária da rotina
//oModel:SetRelation( 'GRID', { { 'FQ5_FILIAL', 'xFilial("FQ5")' } ,{"FQ5_DEMAND","'      '"},{"FQ5_TPAS","'L'"}}, FQ5->( IndexKey( 1 ) ) )
    
oModel:GetModel( 'GRID' ):SetNoInserLine(.T.)
oModel:GetModel( 'GRID' ):SetNoDeleteLine(.T.)
// Adiciona ao modelo uma estrutura de formulário de campos calculados
// AddCalc(cId, cOwner , cIdForm , cIdField , cIdCalc, cOperation, bCond
oModel:AddCalc( 'RODAPE', 'CABEC', 'GRID', 'MARK', 'QTDITEM', 'FORMULA', /*{ | oFW | oModel:GetValue( 'GRID', 'MARK' ) }*/,,STR0006,{|oModel| Loca259BCO(oModel:GetModel("GRID"))},10 ) //STR0006
oModel:AddCalc( 'RODAPE', 'CABEC', 'GRID', 'QTDNEW', 'QTD', 'SUM', { | oFW | oModel:GetValue( 'GRID', 'MARK' ) },,STR0007,,10,2 ) //STR0007
oModel:AddCalc( 'RODAPE', 'CABEC', 'GRID', 'FQ5_QTD2  ', 'QTD2U', 'SUM', { | oFW | oModel:GetValue( 'GRID', 'MARK' ) },,STR0008,,10,2 ) //STR0008
oModel:AddCalc( 'RODAPE', 'CABEC', 'GRID', 'FQ5_PESLIQ', 'PLIQ', 'SUM', { | oFW | oModel:GetValue( 'GRID', 'MARK' ) },,STR0009,,13,5 ) //STR0009
oModel:AddCalc( 'RODAPE', 'CABEC', 'GRID', 'FQ5_PESBRU', 'PBRUTO', 'SUM', { | oFW | oModel:GetValue( 'GRID', 'MARK' ) },,STR0010,,13,5 ) //STR0010
oModel:AddCalc( 'RODAPE', 'CABEC', 'GRID', 'FQ5_M3', 'VOLUME', 'SUM', { | oFW | oModel:GetValue( 'GRID', 'MARK' ) },,'m3',,13,5 )


Return oModel

/*/{Protheus.doc} LOCA259HVI
Função com as definições da VIEW do estorno de separação
@type function
@version 25.10
@author Alexandre Circenis
@since 5/19/2025
@return variant, returna a view dfinida
/*/
FUNCTION LOCA259HVI(oView, oModel)
	local oStrGrid as object
	Local oCalc

// Instancia a Estrutura
//    oStrCabec := FWFormViewStruct():New()
//    oStrCabec:AddField( 'X_ZMVC' , '01' , 'X_ZMVC' , 'X_ZMVC',{},'@!'  )

// Instancia a Estrutura
	oStrGrid := FWFormStruct( 2, "FQ5",  Loca259BFl() )
	oStrGrid:AddField( 'MARK','01',' ',' ',, 'Check')
	oStrGrid:AddField( 'B1_DESC', '02', STR0012, STR0011, , "C" )  //"Descrição do Produto"
	oStrGrid:AddField( 'FPA_LOCAL', '03',STR0003,STR0013, , "C" )  //"Armazem"
	oStrGrid:AddField( 'FPA_DESGRU', '04', STR0012, STR0014, , "C")  //"Descricao"
	oStrGrid:AddField( 'QTDNEW', '05', STR0015, STR0016,, "N",X3Picture("FQ5_QTD"))  //'Qtde Nova'
	oStrGrid:AddField( ;            		// Ord. Tipo Desc.
	'LEGEND'                   	, ;   	// [01]  C   Nome do Campo
	"00"                         	, ;     // [02]  C   Ordem
	AllTrim( ''    )         , ;     // [03]  C   Titulo do campo
	AllTrim( '' )       , ;     // [04]  C   Descricao do campo
	{ STR0017} 		, ;     // [05]  A   Array com Help //STR0017
	'C'                             , ;     // [06]  C   Tipo do campo
	'@BMP'                , ;     // [07]  C   Picture
	NIL                             , ;     // [08]  B   Bloco de Picture Var
	''                              , ;     // [09]  C   Consulta F3
	.T.                             , ;     // [10]  L   Indica se o campo é alteravel
	NIL                             , ;     // [11]  C   Pasta do campo
	NIL                             , ;     // [12]  C   Agrupamento do campo
	NIL				               	, ;     // [13]  A   Lista de valores permitido do campo (Combo)
	NIL                             , ;     // [14]  N   Tamanho maximo da maior opção do combo
	NIL                             , ;     // [15]  C   Inicializador de Browse
	.T.                             , ;     // [16]  L   Indica se o campo é virtual
	NIL                             , ;     // [17]  C   Picture Variavel
	NIL                             )       // [18]  L   Indica pulo de linha após o campo


	oStrGrid:SetProperty("*", MVC_VIEW_CANCHANGE, .F.)
	oStrGrid:SetProperty("MARK", MVC_VIEW_CANCHANGE, .T.)
	oStrGrid:SetProperty("QTDNEW", MVC_VIEW_CANCHANGE, .T.)
	oStrGrid:SetProperty("FQ5_QTD2", MVC_VIEW_CANCHANGE, .T.)
	oStrGrid:SetProperty("FQ5_PESLIQ", MVC_VIEW_CANCHANGE, .T.)
	oStrGrid:SetProperty("FQ5_PESBRU", MVC_VIEW_CANCHANGE, .T.)
	oStrGrid:SetProperty("FQ5_M3", MVC_VIEW_CANCHANGE, .T.)

	oStrGrid:SetProperty("LEGEND"     , MVC_VIEW_ORDEM, '000')
	oStrGrid:SetProperty("MARK"     , MVC_VIEW_ORDEM, '001')
	oStrGrid:SetProperty("FQ5_FILORI" , MVC_VIEW_ORDEM, '002')
	oStrGrid:SetProperty("FQ5_SOT"    , MVC_VIEW_ORDEM, '003')
	oStrGrid:SetProperty("FQ5_OBRA"   , MVC_VIEW_ORDEM, '004')
	oStrGrid:SetProperty("FQ5_AS"     , MVC_VIEW_ORDEM, '005')
	oStrGrid:SetProperty("FQ5_VIAGEM" , MVC_VIEW_ORDEM, '006')
	oStrGrid:SetProperty("FQ5_DATGER" , MVC_VIEW_ORDEM, '008')
	oStrGrid:SetProperty("FQ5_HORGER" , MVC_VIEW_ORDEM, '009')
	oStrGrid:SetProperty("FQ5_XPROD"  , MVC_VIEW_ORDEM, '010')
	oStrGrid:SetProperty("B1_DESC"    , MVC_VIEW_ORDEM, '011')
	oStrGrid:SetProperty("FQ5_XQTD"   , MVC_VIEW_ORDEM, '012')
	oStrGrid:SetProperty("QTDNEW"     , MVC_VIEW_ORDEM, '013')
	oStrGrid:SetProperty("FQ5_QTD2"   , MVC_VIEW_ORDEM, '014')
	oStrGrid:SetProperty("FQ5_PESLIQ" , MVC_VIEW_ORDEM, "015")
	oStrGrid:SetProperty("FQ5_PESBRU" , MVC_VIEW_ORDEM, "016")
	oStrGrid:SetProperty("FQ5_M3" , MVC_VIEW_ORDEM, "017")
	oStrGrid:SetProperty("FPA_LOCAL"  , MVC_VIEW_ORDEM, '018')
	oStrGrid:SetProperty("FQ5_GUINDA" , MVC_VIEW_ORDEM, '019')
	oStrGrid:SetProperty("FPA_DESGRU" , MVC_VIEW_ORDEM, '020')
	oStrGrid:SetProperty("FQ5_DTINI"  , MVC_VIEW_ORDEM, '021')
	oStrGrid:SetProperty("FQ5_DTFIM"  , MVC_VIEW_ORDEM, '022')
	oStrGrid:RemoveField("FQ5_STATUS")

// Carrega o Modelo
//oModel  := FWLoadModel( "LOCA259B")
	oCalc  	:= FWCalcStruct(oModel:GetModel('RODAPE'))

// Seta o Modelo da View
	oView:SetModel( oModel )

// Estrutura visual dos campos
//  oView:AddField('CAB', oStrCabec, 'CABEC')

// Estrutura visual das grids
	oView:AddGrid('VIEW_GRID', oStrGrid, 'GRID')

	oView:AddField( 'VIEW_CALC', oCalc, 'RODAPE' )
	oView:SetViewProperty("GRID", "GRIDSEEK",    {.T.})
	oView:SetViewProperty("GRID", "GRIDFILTER", {.T.})
	oView:SetViewProperty("GRID","GRIDDOUBLECLICK",{{|oFormulario,cFieldName,nLineGrid,nLineModel| Loca259bLg(oFormulario,cFieldName,nLineGrid,nLineModel,oView)}})
    oView:CreateVerticalBox( 'TELA2', 100,'GRID' )
//Criando um container com nome tela com 100%
	oView:CreateHorizontalBox( 'CABEC', 0, "TELA2" )
	oView:CreateHorizontalBox( 'DADOS', 100, "TELA2" )

	oView:CreateFolder( 'FOLDER', 'DADOS')
	oView:AddSheet('FOLDER','SHEET1',STR0018) //STR0018
	oView:CreateHorizontalBox( 'GRID2', 80, , , 'FOLDER', 'SHEET1')
	oView:CreateHorizontalBox( 'FOOT', 20 , , , 'FOLDER', 'SHEET1')
	oView:CreateVerticalBox( 'RODAPE', 80, 'FOOT',, 'FOLDER', 'SHEET1')
	oView:CreateVerticalBox( 'BOTAO', 20, 'FOOT',, 'FOLDER', 'SHEET1')

	oView:AddOtherObject("btnMarcaDesm1", {|oPanel,oView| LOCA259EBT(oPanel, "GRID")})

	oView:AddSheet('FOLDER','SHEET2','Resumo', {|| Loca259bRS()}) //'Resumo'

	oView:CreateHorizontalBox( 'RESUMO', 100, , , 'FOLDER', 'SHEET2')

	oView:SetOwnerView('VIEW_CAB' , 'CABEC' )
	oView:SetOwnerView('GRID', 'GRID2')
	oView:SetOwnerView('VIEW_CALC', 'RODAPE')
	oView:SetOwnerView("btnMarcaDesm1", 'BOTAO')
	
	oView:SetOwnerView('VIEW_RESUMO', 'RESUMO')

	oView:SetCloseOnOk({|| .T.})

    oView:SetViewProperty( "VIEW_CALC", "SETLAYOUT", { FF_LAYOUT_HORZ_DESCR_TOP , 6, 85} )
    oView:SetViewProperty("*", "GRIDSEEK", {.T.})
    oView:SetViewProperty("*", "GRIDFILTER", {.T.})

RETURN oView
