#INCLUDE "WMSA080.CH"
#Include 'Protheus.ch'
#Include "FWMVCDEF.CH"

#DEFINE WMSA08001 "WMSA08001"
#DEFINE WMSA08002 "WMSA08002"
#DEFINE WMSA08003 "WMSA08003"
#DEFINE WMSA08004 "WMSA08004"
#DEFINE WMSA08005 "WMSA08005"
#DEFINE WMSA08006 "WMSA08006"
#DEFINE WMSA08007 "WMSA08007"
//---------------------------------------------------------------------------
/*/{Protheus.doc} WMSA080
Cadastro de Tarefas x Atividades
Sequencia de endereco de apanha dos produtos no armazem
@author Renato ABPL
@since 05/12/2000
@version 1.0
@param cCodPro, Character, (Código do produto)
@obs Mauro Paladini 23/08/13 -> Conversao da rotina para o padrao MVC
@obs Mauro Paladini 07/12/13 -> Ajustes para o funcionamento do Mile
/*/
//---------------------------------------------------------------------------
Function WMSA080(cCodPro)
Local oBrowse 	:= Nil
Local cFiltro	:= ""
Private aRotina	:= MenuDef()

	If !AMiIn(39,42,43) // Somente autorizado para OMS, WMS e TMS
		Return Nil
	EndIf
	
	DC6->(DbSetOrder(1))
	
	If cCodPro <> NIL
		cFiltro := 'xFilial("DC6")+cCodPro'
	EndIf
	
	oBrowse:= FWMBrowse():New()
	oBrowse:SetAlias("DC6")
	oBrowse:SetDescription(STR0001) // "Tarefas x Atividades"
	
	If !Empty(cFiltro)
		oBrowse:SetFilterDefault( cFiltro )
	Endif
	
	oBrowse:Activate()
	
	// Devolve os indices padroes do SIGA.
	RetIndex("DC6")
Return NIL

/*---------------------------------------------------------------------------
---ModelDef
---Modelo de dados 
---Mauro Paladini 23/08/2013
---------------------------------------------------------------------------*/
Static Function ModelDef()
Local oModel	:= Nil
Local oStruCDC6 := FwFormStruct( 1, "DC6", { |cCampo|  AllTrim( cCampo ) + "|" $ "DC6_FILIAL|DC6_TAREFA|DC6_DESTAR|" } )
Local oStruIDC6 := FwFormStruct( 1, "DC6", { |cCampo| !AllTrim( cCampo ) + "|" $ "DC6_DESTAR|DC6_TAREFA|" } )

Local bPreValid	:= Nil
Local bPosValid := { |oMdl| PosVldMdl(oMdl) }
Local bComValid := Nil
Local bCancel	:= Nil

// Validacoes da Grid
Local bLinePost	:= { |oMdl| PosVldLine(oMdl) }

Private oModel2	:= oModel	
	oModel:= MpFormMOdel():New("WMSA080",  /*bPreValid*/ , bPosValid , /*bComValid*/ ,/*bCancel*/ )
	oModel:SetDescription(STR0001) 			// Tarefas x Atividades
	oModel:AddFields("MdFieldCDC6",Nil,oStruCDC6,/*prevalid*/,,/*bCarga*/)
	oModel:SetPrimaryKey({ 'DC6_FILIAL','DC6_TAREFA' })
	
	oModel:AddGrid("MdGridIDC6", "MdFieldCDC6" /*cOwner*/, oStruIDC6 , /*bLinePre*/ , bLinePost , /*bPre*/ , /*bPost*/,/*bLoad*/)
	oModel:SetRelation( "MdGridIDC6", { { "DC6_FILIAL", "xFilial('DC6')" }, { 'DC6_TAREFA', 'DC6_TAREFA' }	 }, DC6->( IndexKey( 1 ) ) )
	If nModulo == 42
		oModel:GetModel( "MdGridIDC6" ):SetUniqueLine( {'DC6_ORDEM','DC6_ATIVID'} )
	Else
		oModel:GetModel( "MdGridIDC6" ):SetUniqueLine( {'DC6_ATIVID','DC6_FILATI'} )
	EndIf
Return ( oModel )
/*---------------------------------------------------------------------------
---ViewDef
---Exibe browse de acordo com a estrutura
---Mauro Paladini 23/08/2013
---------------------------------------------------------------------------*/
Static Function ViewDef()
Local oModel 	:= FwLoadModel("WMSA080")
Local oView 	:= Nil
Local lWmsNew   := SuperGetMV("MV_WMSNEW",.F.,.F.)
Local oStruCDC6 := FwFormStruct( 2, "DC6", { |cCampo|  AllTrim( cCampo ) + "|" $ "DC6_FILIAL|DC6_TAREFA|DC6_DESTAR|" } )
Local oStruIDC6 := FwFormStruct( 2, "DC6", { |cCampo| !AllTrim( cCampo ) + "|" $ "DC6_DESTAR|DC6_TAREFA|" } )
	If nModulo == 43
		oStruIDC6:RemoveField( "DC6_FUNCAO" )
		oStruIDC6:RemoveField( "DC6_DESFUN"	)
		oStruIDC6:RemoveField( "DC6_TPREC"  )
		oStruIDC6:RemoveField( "DC6_DESREC"	)
	EndIf
	If nModulo <> 42
		oStruIDC6:RemoveField( "DC6_RADIOF"	)
		oStruIDC6:RemoveField( "DC6_TPAGLU"	)
		oStruIDC6:RemoveField( "DC6_PERMUL"	)
		If oStruIDC6:HasField("DC6_SOLEND") 
			oStruIDC6:RemoveField( "DC6_SOLEND"	)
		EndIf			
	Else 
		If oStruIDC6:HasField("DC6_SOLEND") .And. !lWmsNew
			oStruIDC6:RemoveField( "DC6_SOLEND"	)
		EndIf
	EndIf
	oView := FwFormView():New()
	oView:SetModel(oModel)
	
	oView:AddField('VwFieldCDC6', oStruCDC6 , 'MdFieldCDC6')
	oView:AddGrid( 'VwGridIDC6', oStruIDC6 , 'MdGridIDC6')
	
	oView:CreateHorizontalBox("SUPERIOR",20)
	oView:CreateHorizontalBox("INFERIOR",80)
	
	oView:EnableTitleView('VwFieldCDC6',STR0008 ) // Tarefa
	oView:EnableTitleView('VwGridIDC6',STR0009)   // Atividades
	
	oView:AddIncrementField( 'VwGridIDC6', 'DC6_ORDEM' )
	
	oView:SetOwnerView("VwFieldCDC6","SUPERIOR")
	oView:SetOwnerView("VwGridIDC6","INFERIOR")
Return(oView)
/*---------------------------------------------------------------------------
---MenuDef
---MenuDef com as rotinas do Browse
---Mauro Paladini 14/08/2013
---------------------------------------------------------------------------*/
Static Function MenuDef()
Private aRotina := {}
	ADD OPTION aRotina TITLE STR0002 	ACTION "PesqBrw"         OPERATION 1 ACCESS 0  // Pesquisar
	ADD OPTION aRotina TITLE STR0003 	ACTION "VIEWDEF.WMSA080" OPERATION 2 ACCESS 0  // Visualizar
	ADD OPTION aRotina TITLE STR0004 	ACTION "VIEWDEF.WMSA080" OPERATION 3 ACCESS 0  // Incluir
	ADD OPTION aRotina TITLE STR0005 	ACTION "VIEWDEF.WMSA080" OPERATION 4 ACCESS 0  // Alterar
	ADD OPTION aRotina TITLE STR0006 	ACTION "VIEWDEF.WMSA080" OPERATION 5 ACCESS 0  // Excluir
	ADD OPTION aRotina TITLE STR0007 	ACTION "VIEWDEF.WMSA080" OPERATION 9 ACCESS 0  // Copiar	
	// Ponto de entrada utilizado para inserir novas opcoes no array aRotina
	If ExistBlock("DLG080MNU")
		ExecBlock("DLG080MNU",.F.,.F.)
	EndIf
Return ( aRotina )

/*---------------------------------------------------------------------------
---PosVldMdl
---Funcao de validacao da model (compatibilizacao)
---Mauro Paladini 27/08/2013
---oMdl, Objeto, (Modelo de dados)
---------------------------------------------------------------------------*/
Static Function PosVldMdl(oMdl)
Local lRet       := .T.
Local oMdlDC6Grd := oMdl:GetModel("MdGridIDC6")
Local cAtvSaiCli := SuperGetMv('MV_ATVSAIC',,'')  //-- Atividade de Saída do cliente
Local cAtvChgCli := SuperGetMv('MV_ATVCHGC',,'')  //-- Atividade de Chegada em Cliente
Local cAtvSaiApo := SuperGetMv('MV_ATVSAPA',,'')   //-- Atividade de Saida do Ponto de Apoio
Local cAtvChgApo := SuperGetMv('MV_ATVCHPA',,'')   //-- Atividade de Chegada no Ponto de Apoio
Local nAtivApo   := 0
Local nAtivChg   := 0
Local nI         := 0
Local aSaveLine  := {}

	If oMdl <> Nil 
		If oMdl:GetOperation() == MODEL_OPERATION_DELETE
			lRet := WMSA080DEL()
		ElseIf ( oMdl:GetOperation() == MODEL_OPERATION_INSERT .Or. oMdl:GetOperation() ==  MODEL_OPERATION_UPDATE )

			//Validação Chegada/Saida em Cliente x Chegada/Saida em Ponto de Apoio
			If nModulo == 43  //TMS

				For nI := 1 To oMdlDC6Grd:Length()
					oMdlDC6Grd:GoLine(nI)
					If !oMdlDC6Grd:IsDeleted(nI)
						If oMdlDC6Grd:GetValue("DC6_ATIVID") $   cAtvSaiApo + " | " + cAtvChgApo 
							nAtivApo++
						EndIf
						If oMdlDC6Grd:GetValue("DC6_ATIVID") $   cAtvSaiCli + " | " + cAtvChgCli 
							nAtivChg++
						EndIf
					EndIf
				Next nI

				If nAtivApo > 0 .And. nAtivChg > 0
					WmsMessage(STR0018,WMSA08007,5 /*MSG_HELP*/) //"Não é permitido selecionar Atividade de Saida/Chegada em Cliente com Atividade de Saida/Chegada de Apoio na mesma Tarefa."  
					lRet:= .F.
				EndIf
			EndIf
		EndIf	
	EndIf

Return lRet
/*---------------------------------------------------------------------------
---PosVldLine
---Funcao de validacao da linha do Grid (compatibilizacao)
---Mauro Paladini 27/08/2013
---oMdl, Objeto, (Objeto do modelo de dados)
---------------------------------------------------------------------------*/
Static Function PosVldLine(oMdl)
Local lRet     := .T.
Local oModel	 := FWModelActive()
Local cAtivid  := oModel:GetValue( "MdGridIDC6" , "DC6_ATIVID" )
Local cAtivChg := ""
Local cAtivSai := ""

	If !oMdl:IsDeleted()
		If Empty( cAtivid )
			WmsMessage(STR0012,WMSA08001,5 /*MSG_HELP*/) // Código da Atividade que será executada  utilizando um recurso físico e um recurso humano.
			lRet := .F.
		ElseIf nModulo == 43 // Transporte.
			cAtivChg := SuperGetMv( 'MV_ATIVCHG',.F., '' )
			cAtivSai := SuperGetMv( 'MV_ATIVSAI',.F., '' )
			SX5->( DbSetOrder( 1 ) )
			If Empty( cAtivChg ) .Or. SX5->( ! MsSeek( xFilial("SX5") + "L3" + cAtivChg ) )
				WmsMessage(STR0013,WMSA08002,5 /*MSG_HELP*/) // Este parâmetro está vazio. É obrigatório preenchê-lo.
				lRet := .F.
			ElseIf Empty( cAtivSai ) .Or. SX5->( ! MsSeek( xFilial("SX5") + "L3" + cAtivSai ) )
				WmsMessage(STR0013,WMSA08003,5 /*MSG_HELP*/) // Este parâmetro está vazio. É obrigatório preenchê-lo.
				lRet := .F.
			ElseIf ( cAtivid == cAtivChg .Or. cAtivid == cAtivSai ) .And. Empty( oModel:GetValue( "MdGridIDC6" , 'DC6_FILATI' ) )
				WmsMessage(STR0014,WMSA08004,5 /*MSG_HELP*/) // Para esta atividade é obrigatório informar a filial da atividade.
				lRet := .F.
			ElseIf ( cAtivid == cAtivChg .Or. cAtivid == cAtivSai ) .And. Empty( oModel:GetValue( "MdGridIDC6" , 'DC6_DURAC' ) )
				WmsMessage(STR0015,WMS08005,5 /*MSG_HELP*/) // Duração desta atividade.
				lRet := .F.
			EndIf
		EndIf
	EndIf
Return lRet
/*---------------------------------------------------------------------------
---WMSA080DEL
---Consiste a exclusao
---Renato ABPL 19/12/2000
---------------------------------------------------------------------------*/
Function WMSA080DEL()
Local lRet := .T.
Local cQuery := ""
Local cAliasTmp := GetNextAlias()
	DC5->(DBSetOrder(2))
	If !SuperGetMv("MV_WMSNEW",.F.,.F.)
		SDB->(DBSetOrder(5))
		If SDB->(DBSeek(xFilial("SDB")+M->DC6_TAREFA))
			lres := .F.
			WmsMessage(STR0016,WMSA08005,5/*MSG_HELP*/)  // Não foi possível excluir esta tarefa, pois já foram executadas operações com  esta configuração.
		Elseif DC5->(DBSeek(xFilial("DC5")+M->DC6_TAREFA))
			lres := .F.
			WmsMessage(STR0017,WMSA08006,5 /*MSG_HELP*/) // Não foi possivel excluir esta tarefa, pois a mesma faz parte de um serviço em uso.
		Else
			lres := .T.
		Endif      
	Else
		cQuery := " SELECT 1"
		cQuery +=   " FROM "+RetSqlName("D12")+" D12"
		cQuery +=  " WHERE D12.D12_TAREFA = '"+M->DC6_TAREFA+"'"
		cQuery +=    " AND D12.D12_FILIAL = '"+xFilial("D12")+"'"
		cQuery +=    " AND D12.D12_STATUS <> '1'"
		cQuery +=    " AND D12.D_E_L_E_T_ = ' '"
		cQuery := ChangeQuery(cQuery)
		DBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasTmp,.F.,.T.)
	
		If (cAliasTmp)->(!Eof())
			WmsMessage(STR0016,WMSA08005,5/*MSG_HELP*/) // Não foi possível excluir esta tarefa, pois já foram executadas operações com  esta configuração.
			lRet := .F.		
		ElseIf DC5->(DBSeek(xFilial("DC5")+M->DC6_TAREFA))
			WmsMessage(STR0017,WMSA08006,5 /*MSG_HELP*/) // Não foi possivel excluir esta tarefa, pois a mesma faz parte de um serviço em uso.
			lRet := .F.		
		EndIf
		(cAliasTmp)->(DbCloseArea())
	EndIf
Return(lRet)

/*-----------------------------------------------------------------------------
---WMSA080XBI
---Chama a rotina de Inclusao de Tarefa x Atividade
---Patricia A. Salomao 01/08/2003
---Mauro Paladini      23/08/2013 -> Conversao da rotina para o padrao MVC
-----------------------------------------------------------------------------*/
Function WMSA080XBI()
Local aArea := GetArea()
	//--Salva as variaveis utilizadas na GetDados Anterior.
	SAVEINTER()	
	FWExecView(STR0010,"VIEWDEF.WMSA080", MODEL_OPERATION_INSERT,, { || .T. } ,,  /*nPerReducTela*/ ) //'Inclusão'	
	// Restaura as variaveis utilizadas na GetDados Anterior.
	RESTINTER()	
	RestArea(aArea)
Return
/*-----------------------------------------------------------------------------
---WMSA080XBV
---Chama a rotina de Visualizacao de Tarefa x Atividade
---Patricia A. Salomao 01/08/2003
---Mauro Paladini      23/08/2013 -> Conversao da rotina para o padrao MVC
----------------------------------------------------------------------------*/
Function WMSA080XBV()
Local aArea      := GetArea()
Local cOldFilter := DC6->(dbFilter())
Local IncOld     := Inclui
	Inclui := .F.
	// Salva as variaveis utilizadas na GetDados Anterior.
	SAVEINTER()
	// Limpa o Filtro que a Consulta SXB faz no DC6 (DC6_ORDEM == 1)
	DC6->( dbClearFilter() )	
	FWExecView(STR0011,"VIEWDEF.WMSA080", MODEL_OPERATION_VIEW ,, { || .T. } ,, /*nPerReducTela*/ ) // Visualizar	
	// Restaura as variaveis utilizadas na GetDados Anterior.
	RESTINTER()	
	// Restaura o Filtro
	If !Empty( cOldFilter )
		Set Filter to &cOldFilter
	EndIf	
	Inclui := IncOld	
	RestArea(aArea)
Return
//------------------------------------------------------------------------//
//--------- Retorna descrição da atividade, do recurso humano e ----------//
//-------------------- do recurso físico para o Grid ---------------------//
//------------------------------------------------------------------------//
Function WMSA80DESC(nCampo)
Local oModel    := FWModelActive()
Local oModelDC6 := oModel:GetModel( 'MdGridIDC6' ) 
Local nLinha    := oModelDC6:GetQtdLine()
Local cRetorno  := ''
	// Impede que a descrição apareça na inclusão de itens durante a alteração
	If nLinha > 0
		cRetorno := ''
	Else
		If nCampo == 1
			cRetorno := Tabela('L3',DC6->DC6_ATIVID,.F.)
		ElseIf nCampo == 2
			cRetorno := Posicione('SRJ',1,xFilial('SRJ')+DC6->DC6_FUNCAO,'RJ_DESC')
		ElseIf nCampo == 3
			cRetorno := Tabela('L1',DC6->DC6_TPREC,.F.)                                                                   
		EndIf
	EndIf
Return cRetorno
