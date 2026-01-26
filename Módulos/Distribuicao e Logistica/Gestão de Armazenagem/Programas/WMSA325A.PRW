#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "WMSA325A.CH"

#DEFINE WMSA325A01 "WMSA325A01"
#DEFINE WMSA325A02 "WMSA325A02"
#DEFINE WMSA325A03 "WMSA325A03"
#DEFINE WMSA325A04 "WMSA325A04"
#DEFINE WMSA325A05 "WMSA325A05"
#DEFINE WMSA325A06 "WMSA325A06"
#DEFINE WMSA325A07 "WMSA325A07"
#DEFINE WMSA325A08 "WMSA325A08"
#DEFINE WMSA325A09 "WMSA325A09"
#DEFINE WMSA325A10 "WMSA325A10"
#DEFINE WMSA325A11 "WMSA325A11"
#DEFINE WMSA325A12 "WMSA325A12"
#DEFINE WMSA325A13 "WMSA325A13"
#DEFINE WMSA325A14 "WMSA325A14"
#DEFINE WMSA325A15 "WMSA325A15"
#DEFINE WMSA325A16 "WMSA325A16"
#DEFINE WMSA325A17 "WMSA325A17"
#DEFINE WMSA325A18 "WMSA325A18"
#DEFINE WMSA325A19 "WMSA325A19"

Static cAliasSD1 := ""
Static cAliasD08 := ""
Static lWMS325C9 := ExistBlock("WMS325C9QR")
//----------------------------------------------------------
// ModelDef - Distribuição de Produtos
//----------------------------------------------------------
Static Function ModelDef()
Local oModel     := MPFormModel():New('WMSA325A',,{|oModel| ValidModel(oModel) },{|oModel| CommitMdl(oModel)})
Local oStrD06    := FWFormStruct( 1, 'D06')
Local oStrGrdD07 := FWFormStruct( 1, 'D07')
Local oStrGrdD08 := FWFormStruct( 1, 'D08')
Local oStrGrdD09 := FWFormStruct( 1, 'D09')
Local oStrGrdD0F := FWFormStruct( 1, 'D0F')
Local aColsSx3   := {}
	If D07->(FieldPos('D07_SDOC'))>0
		oStrGrdD07:RemoveField('D07_SDOC')
	EndIf
	// [01] C Titulo do campo
	// [02] C ToolTip do campo
	// [03] C identificador (ID) do Field
	// [04] C Tipo do campo
	// [05] N Tamanho do campo
	// [06] N Decimal do campo
	// [07] B Code-block de validação do campo
	// [08] B Code-block de validação When do campo
	// [09] A Lista de valores permitido do campo
	// [10] L Indica se o campo tem preenchimento obrigatório
	// [11] B Code-block de inicializacao do campo
	// [12] L Indica se trata de um campo chave
	// [13] L Indica se o campo pode receber valor em uma operação de update.
	// [14] L Indica se o campo é virtual
	buscarSX3('D09_QTDADI',,aColsSX3)
	oStrGrdD09:AddField( aColsSX3[1],aColsSX3[1],'D09_QTDPED','N',aColsSX3[3],aColsSX3[4],NIL,NIL,NIL,NIL,{ || 0 },NIL,.F.,.T. )
	buscarSX3('D09_QTDADI',,aColsSX3)
	oStrGrdD09:AddField( aColsSX3[1],aColsSX3[1],'D09_QTDPEN','N',aColsSX3[3],aColsSX3[4],NIL,NIL,NIL,NIL,{ || 0 },NIL,.F.,.T. )
	buscarSX3('D1_PEDIDO',,aColsSX3)
	oStrGrdD07:AddField( aColsSX3[1],aColsSX3[1],'D07_PEDIDO','C',aColsSX3[3],aColsSX3[4],NIL,NIL,NIL,NIL,Nil     ,NIL,.F.,.T. )
	buscarSX3('D1_ITEMPC',,aColsSX3)
	oStrGrdD07:AddField( aColsSX3[1],aColsSX3[1],'D07_ITEMPC','C',aColsSX3[3],aColsSX3[4],NIL,NIL,NIL,NIL,Nil     ,NIL,.F.,.T. )

	oStrGrdD07:SetProperty("D07_QTDENT",MODEL_FIELD_OBRIGAT,.F.)
	oStrGrdD07:SetProperty("D07_QTDEN2",MODEL_FIELD_OBRIGAT,.F.)
	oStrGrdD09:SetProperty("D09_QTDADI",MODEL_FIELD_OBRIGAT,.F.)
	oStrGrdD09:SetProperty("D09_QTDAD2",MODEL_FIELD_OBRIGAT,.F.)

	oStrGrdD08:SetProperty('D08_QTDDIS',MODEL_FIELD_VALID,{ |A,B,C,D,nValAnt| UpdSldD09(nValAnt,oModel) })
	oStrGrdD08:AddTrigger("D08_QTDDIS","D08_QTDDI2",,{|oModelD08,cField,nVal| ConvUm(oModelD08:GetValue('D08_PRODUT'), nVal, 0, 2) } )
	oStrGrdD08:AddTrigger("D08_QTDEND","D08_QTDEN2",,{|oModelD08,cField,nVal| ConvUm(oModelD08:GetValue('D08_PRODUT'), nVal, 0, 2) } )
	oStrGrdD09:AddTrigger("D09_QTDDIS","D09_QTDDI2",,{|oModelD09,cField,nVal| ConvUm(oModelD09:GetValue('D09_PRODUT'), nVal, 0, 2) } )
	oStrGrdD09:AddTrigger("D09_QTDADI","D09_QTDAD2",,{|oModelD09,cField,nVal| ConvUm(oModelD09:GetValue('D09_PRODUT'), nVal, 0, 2) } )

	oStrGrdD08:AddTrigger("D08_QTDDI2","D08_QTDDIS",,{|oModelD08,cField,nVal| ConvUm(oModelD08:GetValue('D08_PRODUT'), 0, nVal, 1) } )
	oStrGrdD08:AddTrigger("D08_QTDEN2","D08_QTDEND",,{|oModelD08,cField,nVal| ConvUm(oModelD08:GetValue('D08_PRODUT'), 0, nVal, 1) } )
	oStrGrdD09:AddTrigger("D09_QTDDI2","D09_QTDDIS",,{|oModelD09,cField,nVal| ConvUm(oModelD09:GetValue('D09_PRODUT'), 0, nVal, 1) } )
	oStrGrdD09:AddTrigger("D09_QTDAD2","D09_QTDADI",,{|oModelD09,cField,nVal| ConvUm(oModelD09:GetValue('D09_PRODUT'), 0, nVal, 1) } )

	oModel:AddFields('D06FIELDS',/*cOwner*/,oStrD06)
	oModel:GetModel('D06FIELDS'):SetPrimaryKey( { 'D06_FILIAL','D06_CODDIS' } )
	oModel:GetModel('D06FIELDS'):SetDescription( STR0001 ) // Distribuição

	oModel:AddGrid('D07GRID','D06FIELDS',oStrGrdD07)
	oModel:SetRelation('D07GRID',{ {'D07_FILIAL',"xFilial('D07')"},{'D07_CODDIS','D06_CODDIS'} }, D07->( IndexKey(1) ))
	oModel:GetModel('D07GRID'):SetOptional(.T.)
	oModel:GetModel('D07GRID'):SetDescription( STR0002 ) // Documentos de Entrada

	oModel:AddGrid('D08GRID','D06FIELDS',oStrGrdD08)
	oModel:SetRelation('D08GRID',{ {'D08_FILIAL',"xFilial('D08')"},{'D08_CODDIS','D06_CODDIS'} }, D08->( IndexKey(1) ))
	oModel:GetModel('D08GRID'):SetOptional(.T.)
	oModel:GetModel('D08GRID'):SetDescription(STR0003) // Pedidos de Venda/Planos de Distribuição

	oModel:AddGrid('D09GRID','D06FIELDS',oStrGrdD09)
	oModel:SetRelation('D09GRID',{ {'D09_FILIAL',"xFilial('D09')"},{'D09_CODDIS','D06_CODDIS'} }, D09->( IndexKey(1) ))
	oModel:GetModel('D09GRID'):SetOptional(.T.)
	oModel:GetModel('D09GRID'):SetDescription( STR0004 ) // Produtos

	oModel:AddGrid('D0FGRID','D06FIELDS',oStrGrdD0F)
	oModel:SetRelation('D0FGRID',{ {'D0F_FILIAL',"xFilial('D0F')"},{'D0F_CODDIS','D06_CODDIS'} }, D0F->( IndexKey(1) ))
	oModel:GetModel('D0FGRID'):SetOptional(.T.)
	oModel:GetModel('D0FGRID'):SetDescription( STR0040 ) // Endereços Produtos Distribuídos

	oModel:GetModel('D07GRID'):SetNoDeleteLine(.T.)
	oModel:GetModel('D08GRID'):SetNoDeleteLine(.T.)
	oModel:GetModel('D09GRID'):SetNoDeleteLine(.T.)

	oModel:GetModel('D07GRID'):SetNoInsertLine(.T.)
	oModel:GetModel('D08GRID'):SetNoInsertLine(.T.)
	oModel:GetModel('D09GRID'):SetNoInsertLine(.T.)

	oModel:SetActivate({|| ActiveModel(oModel) })

Return oModel
//----------------------------------------------------------
// ViewDef
//----------------------------------------------------------
Static Function ViewDef()
Local oModel :=	FWLoadModel( 'WMSA325A' )
Local oStrD06 := FWFormStruct( 2, 'D06',,/*lViewUsado*/ )
Local oStrD07 := FWFormStruct( 2, 'D07',,/*lViewUsado*/ )
Local oStrD08 := FWFormStruct( 2, 'D08',,/*lViewUsado*/ )
Local oStrD09 := FWFormStruct( 2, 'D09',,/*lViewUsado*/ )
Local oView := FWFormView():New()
Local aColsSx3 := {}

	oStrD07:RemoveField('D07_CODDIS')
	oStrD07:RemoveField('D07_SERIE')
	oStrD07:RemoveField('D07_QTDDIS')
	oStrD07:RemoveField('D07_QTDDI2')
	oStrD07:RemoveField('D07_QTORIE')
	oStrD07:RemoveField('D07_QTORID')

	oStrD08:RemoveField('D08_CODDIS')
	oStrD08:RemoveField('D08_QTORID')

	oStrD09:RemoveField('D09_CODDIS')

	// [01] C Nome do Campo
	// [02] C Ordem
	// [03] C Titulo do campo
	// [04] C Descrição do campo
	// [05] A Array com Help
	// [06] C Tipo do campo
	// [07] C Picture
	// [08] B Bloco de Picture Var
	// [09] C Consulta F3
	// [10] L Indica se o campo é evitável
	// [11] C Pasta do campo
	// [12] C Agrupamento do campo
	// [13] A Lista de valores permitido do campo (Combo)
	// [14] N Tamanho Maximo da maior opção do combo
	// [15] C Inicializador de Browse
	// [16] L Indica se o campo é virtual
	// [17] C Picture Variável
	buscarSX3('D09_QTDADI',,aColsSX3)
	oStrD09:AddField( 'D09_QTDPED','03',STR0026,aColsSX3[1],NIL,'N',aColsSX3[2],NIL,'',.F.,NIL,NIL,NIL,NIL,NIL,.T.,NIL) //"Qtd. Pedidos/Planos"
	buscarSX3('D09_QTDADI',,aColsSX3)
	oStrD09:AddField( 'D09_QTDPEN','05',STR0027,aColsSX3[1],NIL,'N',aColsSX3[2],NIL,'',.F.,NIL,NIL,NIL,NIL,NIL,.T.,NIL) //"Qtd. Pendente"

	oStrD06:SetProperty('*',MVC_VIEW_CANCHANGE,.F.)
	oStrD07:SetProperty('*',MVC_VIEW_CANCHANGE,.F.)
	oStrD08:SetProperty('*',MVC_VIEW_CANCHANGE,.F.)
	oStrD09:SetProperty('*',MVC_VIEW_CANCHANGE,.F.)

	oStrD07:SetProperty('D07_DOC'   ,MVC_VIEW_ORDEM,'01')
	oStrD07:SetProperty('D07_ITEM'  ,MVC_VIEW_ORDEM,'02')
	oStrD07:SetProperty('D07_LOCAL' ,MVC_VIEW_ORDEM,'03')
	oStrD07:SetProperty('D07_PRODUT',MVC_VIEW_ORDEM,'04')
	oStrD07:SetProperty('D07_LOTECT',MVC_VIEW_ORDEM,'05')
	oStrD07:SetProperty('D07_NUMLOT',MVC_VIEW_ORDEM,'06')
	oStrD07:SetProperty('D07_QTDENT',MVC_VIEW_ORDEM,'07')
	//oStrD07:SetProperty('D07_SDOC'  ,MVC_VIEW_ORDEM,'08')
	oStrD07:SetProperty('D07_FORNEC',MVC_VIEW_ORDEM,'09')
	oStrD07:SetProperty('D07_LOJA'  ,MVC_VIEW_ORDEM,'10')
	oStrD07:SetProperty('D07_DTEMIS',MVC_VIEW_ORDEM,'11')
	oStrD07:SetProperty('D07_DPROD' ,MVC_VIEW_ORDEM,'12')
	oStrD07:SetProperty('D07_QTDEN2',MVC_VIEW_ORDEM,'13')

	oStrD09:SetProperty('D09_PRODUT',MVC_VIEW_ORDEM,'01')
	oStrD09:SetProperty('D09_QTDADI',MVC_VIEW_ORDEM,'02')
	// Qtd Pedido
	oStrD09:SetProperty('D09_QTDDIS',MVC_VIEW_ORDEM,'04')
	// Qtd Pendente
	oStrD09:SetProperty('D09_LOCAL' ,MVC_VIEW_ORDEM,'06')
	oStrD09:SetProperty('D09_DPROD' ,MVC_VIEW_ORDEM,'07')
	oStrD09:SetProperty('D09_QTDAD2',MVC_VIEW_ORDEM,'08')
	oStrD09:SetProperty('D09_QTDDI2',MVC_VIEW_ORDEM,'09')

	oStrD08:SetProperty('D08_PEDIDO',MVC_VIEW_ORDEM,'01')
	oStrD08:SetProperty('D08_CLIENT',MVC_VIEW_ORDEM,'02')
	oStrD08:SetProperty('D08_LOJA'  ,MVC_VIEW_ORDEM,'03')
	oStrD08:SetProperty('D08_LOCAL' ,MVC_VIEW_ORDEM,'04')
	oStrD08:SetProperty('D08_ITEM'  ,MVC_VIEW_ORDEM,'05')
	oStrD08:SetProperty('D08_PRODUT',MVC_VIEW_ORDEM,'06')
	oStrD08:SetProperty('D08_LOTECT',MVC_VIEW_ORDEM,'07')
	oStrD08:SetProperty('D08_NUMLOT',MVC_VIEW_ORDEM,'08')
	oStrD08:SetProperty('D08_QTDVEN',MVC_VIEW_ORDEM,'09')
	oStrD08:SetProperty('D08_QTDDIS',MVC_VIEW_ORDEM,'10')
	oStrD08:SetProperty('D08_DPROD' ,MVC_VIEW_ORDEM,'11')
	oStrD08:SetProperty('D08_SEQUEN',MVC_VIEW_ORDEM,'12')
	oStrD08:SetProperty('D08_DATENT',MVC_VIEW_ORDEM,'13')
	oStrD08:SetProperty('D08_QTDVE2',MVC_VIEW_ORDEM,'14')
	oStrD08:SetProperty('D08_QTDDI2',MVC_VIEW_ORDEM,'15')

	oStrD08:SetProperty('D08_QTDDIS',MVC_VIEW_CANCHANGE,.T.)

	oView:SetModel( oModel )
	oView:AddField('VIEW_D06',oStrD06,'D06FIELDS')
	oView:AddGrid('VIEW_D07',oStrD07,'D07GRID')
	oView:AddGrid('VIEW_D08',oStrD08,'D08GRID')
	oView:AddGrid('VIEW_D09',oStrD09,'D09GRID')

	oView:EnableTitleView('VIEW_D07', STR0002) // Documentos de Entrada
	oView:EnableTitleView('VIEW_D08', STR0003) // Pedidos de Venda/Planos de Distribuição
	oView:EnableTitleView('VIEW_D09', STR0004) // Produtos

	oView:CreateHorizontalBox('UP',10)
	oView:CreateHorizontalBox('MID',40)
	oView:CreateHorizontalBox('DOWN',50)

	oView:CreateVerticalBox('MIDLEFT',50,'MID')
	oView:CreateVerticalBox('MIDRIGHT',50,'MID')

	oView:SetOwnerView('VIEW_D06','UP')
	oView:SetOwnerView('VIEW_D07','MIDLEFT')
	oView:SetOwnerView('VIEW_D09','MIDRIGHT')
	oView:SetOwnerView('VIEW_D08','DOWN')

	oView:SetCloseOnOk({||.T.})

	oView:AddUserButton(STR0005,'',{ |oModel| Processa({ || ProcRegua(0),WMSA325ADC(oModel,MODEL_OPERATION_INSERT) },STR0028), oView:Refresh() }) // Incluir Documento##"Processando Pré-Notas..."
	oView:AddUserButton(STR0006,'',{ |oModel| Processa({ || ProcRegua(0),WMSA325ADC(oModel,MODEL_OPERATION_DELETE) },STR0029), oView:Refresh() }) // Excluir Documento##"Aguarde..."
	oView:AddUserButton(STR0007,'',{ |oModel| Processa({ || ProcRegua(0),WMSA325APD(oModel,MODEL_OPERATION_INSERT) },STR0030), oView:Refresh() }) // Incluir Pedido##"Processando Pedidos de Venda..."
	oView:AddUserButton(STR0008,'',{ |oModel| Processa({ || ProcRegua(0),WMSA325APD(oModel,MODEL_OPERATION_DELETE) },STR0029), oView:Refresh() }) // Excluir Pedido##"Aguarde..."
	oView:AddUserButton(STR0047,'',{ |oModel| Processa({ || ProcRegua(0),WMSA325APL(oModel,MODEL_OPERATION_INSERT) },STR0049), oView:Refresh() }) // Incluir Plano##"Processando Plano de Distribuição..."
	oView:AddUserButton(STR0048,'',{ |oModel| Processa({ || ProcRegua(0),WMSA325APL(oModel,MODEL_OPERATION_DELETE) },STR0029), oView:Refresh() }) // Excluir Plano##"Aguarde..."
	oView:AddUserButton(STR0010,'',{ |oModel| WMSA325ART(oModel,1), oView:Refresh() }) // Rateio Direto
	oView:AddUserButton(STR0009,'',{ |oModel| WMSA325ART(oModel,2), oView:Refresh() }) // Rateio Proporcional
	oView:AddUserButton(STR0043,'',{ |oModel| WMSA325ART(oModel,3), oView:Refresh() }) // Rateio 1UM + Proporcional
	oView:AddUserButton(STR0050,'',{ |oModel| WMSA325ART(oModel,4), oView:Refresh() }) // Rateio Direto Pedido de Venda + Proporcional Plano de Distribuição
Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ValidModel
Validação do modelo de dados após o Confirmar
@author felipe.m
@since 19/09/2014
@version 1.0
@param oModel, objeto, Modelo de dados da aplicação
/*/
//-------------------------------------------------------------------
Static Function ValidModel(oModel)
Local oModelD07 := oModel:GetModel('D07GRID')
Local oModelD08 := oModel:GetModel('D08GRID')
Local oModelD09 := oModel:GetModel('D09GRID')
Local cMsg := ""
Local lRet := .T.
Local nI := 0
Local lAuto := FwIsInCallStack("WmsAvalSF1") // Chamado da distribuição automatica no momento da classificação
Local lRecalc := FwIsInCallStack("A320FINCOF") .Or. FwIsInCallStack("ReabCofRec") // Chamado da conferência de recebimento com divergencia negativa para recalcular a distribuição

	For nI := 1 To oModelD08:Length()
		lRet := .F.
		oModelD08:GoLine(nI)
		If oModelD08:GetValue("D08_QTDDIS") != 0
			lRet := .T.
			Exit
		EndIf
	Next nI

	// Atualiza a situação na reabertura da conferencia de recebimento
	If lRet .And. lRecalc .And. oModel:GetModel("D06FIELDS"):GetValue("D06_SITDIS") == "3"
		oModel:GetModel("D06FIELDS"):SetValue("D06_SITDIS","2")
	EndIf

	If !lRet
		If !lRecalc
			oModel:GetModel():SetErrorMessage( , ,  , '', WMSA325A01, STR0031, "", '', '') // Não exitem pedidos para serem distribuídos.
		Else
			oModel:GetModel("D06FIELDS"):SetValue("D06_SITDIS","3")
			lRet := .T.
		EndIf
	EndIf

	If lRet .And. !lAuto .And. !lRecalc
		If oModelD08:SeekLine( { {"D08_QTDDIS",0 } } )
			oModel:GetModel():SetErrorMessage( , , , '', WMSA325A02, STR0032, STR0033, '', '') // Exitem pedidos que não foram distribuídos. // Rever distribuição
			lRet := .F.
		EndIf
	EndIf

	If lRet
		For nI := 1 To oModelD09:Length()
			oModelD09:GoLine(nI)
			If !oModelD09:IsDeleted()
				If oModelD09:GetValue('D09_QTDADI') < oModelD09:GetValue('D09_QTDDIS')
					oModel:GetModel():SetErrorMessage( , ,  , '', WMSA325A03, STR0012+oModelD09:GetValue('D09_PRODUT'), "", '', '') // Quantidade informada ultrapassa a quantidade a distribuir para o produto:
					lRet := .F.
					Exit
				EndIf
			EndIf
		Next nI

		If lRet
			If !lRecalc
				oModelD08:SetNoDeleteLine(.F.)
				// Deleta os pedidos de venda que não foram distribuídos (D08_QTDDIS == 0)
				For nI := 1 To oModelD08:Length()
					oModelD08:GoLine(nI)
					If oModelD08:GetValue("D08_QTDDIS") == 0
						If !oModelD08:IsDeleted()
							If !Empty( oModelD08:GetValue('D08_LOTECT') )
								If Empty(cMsg)
									cMsg := STR0013 + CRLF // Existem pedidos selecionados com Lote/Sub-Lote que não foram distribuídos e serão desconsiderados!
									cMsg += STR0014 + CRLF // Pedido|Produto|Lote|Sub-Lote
								EndIf
								cMsg += AllTrim(oModelD08:GetValue('D08_PEDIDO'))+"|"+AllTrim(oModelD08:GetValue('D08_PRODUT'))+"|"+AllTrim(oModelD08:GetValue('D08_LOTECT'))+"|"+AllTrim(oModelD08:GetValue('D08_NUMLOT')) + CRLF
							EndIf
							oModelD08:DeleteLine()
						EndIf
					EndIf
				Next nI

				If !Empty(cMsg) .And. !lAuto .And. !lRecalc
					WmsMessage(cMsg,WMSA325A04,10,,{STR0039}) // Ok
				EndIf

				oModelD08:SetNoDeleteLine(.T.)
			EndIf
			// Cálculo da quantidade distribuida D07
			QtdDisD07(oModel)
			// Criação dos dados D0F
			QtdDisD0F(oModel)
		EndIf
	EndIf

	If lRet .And. !lRecalc
		// Guarda a quantidade do documento e quantidades distribuidas da primeira distribuição.
		// Quanto é realizado um recalculo pela conferencia de recebimento, esses valores nao serão
		// alterados, possibilitando que ao estornar a confencia de recebiemnto, as quantidades retornem
		// com seus valores originais.
		For nI := 1 To oModelD07:Length()
			oModelD07:GoLine(nI)
			oModelD07:LoadValue("D07_QTORIE", oModelD07:GetValue("D07_QTDENT"))
			oModelD07:LoadValue("D07_QTORID", oModelD07:GetValue("D07_QTDDIS"))
		Next nI

		For nI := 1 To oModelD08:Length()
			oModelD08:GoLine(nI)
			oModelD08:LoadValue("D08_QTORID", oModelD08:GetValue("D08_QTDDIS"))
		Next nI
	EndIf
Return lRet

Static Function CommitMdl(oModel)
Return FwFormCommit(oModel,,,,{|oModel| InTTSAtuMVC(oModel)})

Static Function InTTSAtuMVC(oModel)
Local oProcess
Local oModelD07 := oModel:GetModel('D07GRID')
Local oModelD08 := oModel:GetModel('D08GRID')
Local lRet := .T.
Local nI := 0
Local lAuto := FwIsInCallStack("WmsAvalSF1") // Chamado da distribuição automatica no momento da classificação
Local lRecalc := FwIsInCallStack("A320FINCOF") .Or. FwIsInCallStack("ReabCofRec") // Chamado da conferência de recebimento com divergencia negativa

	// Quando não for um recalculo das quantidades, pois quando for, já foi feita a classificação e não pode alterar a SD1.
	If !lRecalc
		If !Empty(oModelD08:GetValue("D08_PEDIDO"))
			If lAuto .Or. WmsQuestion(STR0038,WMSA325A05)// Distribuir montagem?
				oProcess := MsNewProcess():New( { || QuebraSD1(oModel,oProcess)  }, STR0001, STR0034, .F. ) // Distribuição // Aguarde, distribuindo...
				oProcess:Activate()

				Replace D06->D06_SITDIS With "2"
			EndIf
		EndIf
		// Atualiza documento de entrada
		lRet := WMS325UPD1(oModelD07,.T.)
		If lRet
			// Atualiza plano de distribuição
			lRet := WMS325UPPL(oModelD08, .F.)
			If lRet
				lRet := WMS325UPPL(oModelD08, .T.)
			EndIf
		EndIf
	EndIf
Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} ActiveModel
Atribuição da data e hora da montagem ao iniciar a operação de inclusão
@author felipe.m
@since 19/09/2014
@version 1.0
@param oModel, objeto, Modelo de dados da aplicação
/*/
//-------------------------------------------------------------------
Static Function ActiveModel(oModel)
	// Verifica se operação é de inclusão
	If oModel:GetOperation() == MODEL_OPERATION_INSERT
		oModel:GetModel('D06FIELDS'):SetValue('D06_DTGDIS', dDataBase)
		oModel:GetModel('D06FIELDS'):SetValue('D06_HRGDIS', Time())
	EndIf
	// Verifica se operação é de exclusão
	If oModel:GetOperation() == MODEL_OPERATION_UPDATE
		WMS325RD09(oModel)
	EndIf
Return .T.
//-------------------------------------------------------------------
/*/{Protheus.doc} WMSA325ADC
Criação do MarkBrowse de Itens do Documento de Entrada
@author felipe.m
@since 19/09/2014
@version 1.0
@param oModel, objeto, Modelo de dados da oplicação
@param nOperacao, numérico, Operação de manipulação dos dados
/*/
//-------------------------------------------------------------------
Function WMSA325ADC(oModel,nOperacao)
Local aAreaD06   := D06->(GetArea())
Local aAreaD07   := D07->(GetArea())
Local aAreaD08   := D08->(GetArea())
Local aAreaD09   := D09->(GetArea())
Local aCoors     := FWGetDialogSize(oMainWnd)
Local aColsSX3   := {}
Local aFieldSD1  := {}
Local aCamposSD1 := {}
Local lDelete    := nOperacao == MODEL_OPERATION_DELETE
Local lMarcar    := .F.
Local lContinua  := .T.
Local oDlgEnt, oBrwSD1
Local cWMSLCFT   := SuperGetMV('MV_WMSLCFT',.F.,'') // Local de falta
Local cWMSLCEX   := SuperGetMV('MV_WMSLCEX',.F.,'') // Local de excesso
	If !lDelete .And. !pergunte('WMSA3251',.T.)
		lContinua := .F.
	EndIf
	If lContinua
		If MV_PAR01 $ cWMSLCFT
			WmsMessage(STR0041,WMSA325A11) // Armazém configurado como local para itens com divergências de 'falta' na conferência do recebimento (MV_WMSLCFT), não pode ser considerado na distribuição.
			lContinua := .F.
		ElseIf MV_PAR01 $ cWMSLCEX
			WmsMessage(STR0042,WMSA325A12) // Armazém configurado como local para itens com divergências de 'excesso' na conferência do recebimento (MV_WMSLCEX), não pode ser considerado na distribuição.
			lContinua := .F.
		EndIf
		If lContinua
			// Cria campos busca documentos de entrada
			Aadd(aFieldSD1,{buscarSX3("D1_LOCAL"  ,,aColsSX3),"D1_LOCAL"  ,"C" ,aColsSX3[3],aColsSX3[4],aColsSX3[2]})
			Aadd(aFieldSD1,{buscarSX3("D1_COD"    ,,aColsSX3),"D1_COD"    ,"C" ,aColsSX3[3],aColsSX3[4],aColsSX3[2]})
			Aadd(aFieldSD1,{buscarSX3("B1_DESC"   ,,aColsSX3),"D1_DESC"   ,"C" ,aColsSX3[3],aColsSX3[4],aColsSX3[2]})
			Aadd(aFieldSD1,{buscarSX3("D1_ITEM"   ,,aColsSX3),"D1_ITEM"   ,"C" ,aColsSX3[3],aColsSX3[4],aColsSX3[2]})
			Aadd(aFieldSD1,{buscarSX3("D1_QUANT"  ,,aColsSX3),"D1_QUANT"  ,"N" ,aColsSX3[3],aColsSX3[4],aColsSX3[2]})
			Aadd(aFieldSD1,{buscarSX3("D1_QTSEGUM",,aColsSX3),"D1_QTSEGUM","N" ,aColsSX3[3],aColsSX3[4],aColsSX3[2]})
			Aadd(aFieldSD1,{buscarSX3("D1_DOC"    ,,aColsSX3),"D1_DOC"    ,"C" ,aColsSX3[3],aColsSX3[4],aColsSX3[2]})
			Aadd(aFieldSD1,{buscarSX3("D1_SERIE"  ,,aColsSX3),"D1_SERIE"  ,"C" ,aColsSX3[3],aColsSX3[4],aColsSX3[2]})
			Aadd(aFieldSD1,{buscarSX3("D1_FORNECE",,aColsSX3),"D1_FORNECE","C" ,aColsSX3[3],aColsSX3[4],aColsSX3[2]})
			Aadd(aFieldSD1,{buscarSX3("D1_EMISSAO",,aColsSX3),"D1_EMISSAO","D" ,aColsSX3[3],aColsSX3[4],aColsSX3[2]})
			Aadd(aFieldSD1,{buscarSX3("D1_SERIE"  ,,aColsSX3),"D1_SERIE"  ,"C" ,aColsSX3[3],aColsSX3[4],aColsSX3[2]})
			Aadd(aFieldSD1,{buscarSX3("D1_LOTECTL",,aColsSX3),"D1_LOTECTL","C" ,aColsSX3[3],aColsSX3[4],aColsSX3[2]})
			Aadd(aFieldSD1,{buscarSX3("D1_NUMLOTE",,aColsSX3),"D1_NUMLOTE","C" ,aColsSX3[3],aColsSX3[4],aColsSX3[2]})
			// Cria Tabela temporária
			CriaTbSD1(@aCamposSD1)

			If !lDelete
				DadosTbSD1(oModel,nOperacao,aCamposSD1)
			Else
				RecalcTmp(oModel,aCamposSD1,'SD1')
			EndIf
			// Verifica se há dados
			If (cAliasSD1)->(Eof())
				WmsMessage(STR0045,WMSA325A15) // Não há dados para seleção informada!
				lContinua := .F.
			EndIf
		EndIf
		If lContinua

			Define MsDialog oDlgEnt Title STR0002 From aCoors[1],aCoors[2] To aCoors[3] ,aCoors[4] Pixel // Documentos de Entrada

			oBrwSD1 := FWMarkBrowse():New()
			oBrwSD1:SetDescription(STR0020) // Itens Documentos de Entrada
			oBrwSD1:SetOwner(oDlgEnt)
			oBrwSD1:SetAlias(cAliasSD1)
			oBrwSD1:SetTemporary(.T.)
			oBrwSD1:SetFields( aFieldSD1 )
			oBrwSD1:SetFieldMark('D1_OK')
			oBrwSD1:oBrowse:SetDBFFilter(.T.)
			oBrwSD1:oBrowse:SetUseFilter()
			oBrwSD1:bAllMark := { || SetMarkAll(oBrwSD1:Mark(),lMarcar := !lMarcar, 'SD1', oModel, nOperacao ), oBrwSD1:Refresh(.T.)  }
			oBrwSD1:SetMenuDef('')
			// Ao excluir um documento serão zeradas as quantidades de produtos já distribuídos que ultrapassam a quantidade a distribuir.
			oBrwSD1:AddButton(STR0018,{ || MontaD07(oBrwSD1:Mark(),oModel,nOperacao,oDlgEnt ),oBrwSD1:Refresh(.T.)  },, 2, 0) // Confirmar
			oBrwSD1:DisableDetails()
			oBrwSD1:SetFixedBrowse(.T.)
			oBrwSD1:Activate()

			Activate MsDialog oDlgEnt Center
		EndIf
	EndIf
	oModel:GetModel('D07GRID'):GoLine( 1 )
	oModel:GetModel('D08GRID'):GoLine( 1 )
	oModel:GetModel('D09GRID'):GoLine( 1 )

	RestArea(aAreaD09)
	RestArea(aAreaD08)
	RestArea(aAreaD07)
	RestArea(aAreaD06)
Return Nil
//-------------------------------------------------------------------
/*/{Protheus.doc} CriaTabD1
(long_description)
@author felipe.m
@since 10/11/2014
@version 1.0
@param aCamposSD1, array, (Descrição do parâmetro)
@example
(examples)
@see (links_or_references)
/*/
//-------------------------------------------------------------------
Static Function CriaTbSD1(aCamposSD1)
Local aColsSX3 := {}

	buscarSX3("D1_OKISS",,aColsSX3)
	Aadd(aCamposSD1,{"D1_OK","C",aColsSX3[3],aColsSX3[4]})

	buscarSX3("D1_LOCAL",,aColsSX3)
	Aadd(aCamposSD1,{"D1_LOCAL","C",aColsSX3[3],aColsSX3[4]})

	buscarSX3("D1_COD",,aColsSX3)
	Aadd(aCamposSD1,{"D1_COD","C",aColsSX3[3],aColsSX3[4]})

	buscarSX3("B1_DESC",,aColsSX3)
	Aadd(aCamposSD1,{"D1_DESC","C",aColsSX3[3],aColsSX3[4]})

	buscarSX3("D1_ITEM",,aColsSX3)
	Aadd(aCamposSD1,{"D1_ITEM","C",aColsSX3[3],aColsSX3[4]})

	buscarSX3("D1_QUANT",,aColsSX3)
	Aadd(aCamposSD1,{"D1_QUANT","N",aColsSX3[3],aColsSX3[4]})

	buscarSX3("D1_QTSEGUM",,aColsSX3)
	Aadd(aCamposSD1,{"D1_QTSEGUM","N",aColsSX3[3],aColsSX3[4]})

	buscarSX3("D1_DOC",,aColsSX3)
	Aadd(aCamposSD1,{"D1_DOC","C",aColsSX3[3],aColsSX3[4]})

	buscarSX3("D1_SERIE",,aColsSX3)
	Aadd(aCamposSD1,{"D1_SERIE","C",aColsSX3[3],aColsSX3[4]})

	buscarSX3("D1_FORNECE",,aColsSX3)
	Aadd(aCamposSD1,{"D1_FORNECE","C",aColsSX3[3],aColsSX3[4]})

	buscarSX3("D1_LOJA",,aColsSX3)
	Aadd(aCamposSD1,{"D1_LOJA","C",aColsSX3[3],aColsSX3[4]})

	buscarSX3("D1_EMISSAO",,aColsSX3)
	Aadd(aCamposSD1,{"D1_EMISSAO","D",aColsSX3[3],aColsSX3[4]})

	buscarSX3("D1_LOTECTL",,aColsSX3)
	Aadd(aCamposSD1,{"D1_LOTECTL","C",aColsSX3[3],aColsSX3[4]})

	buscarSX3("D1_NUMLOTE",,aColsSX3)
	Aadd(aCamposSD1,{"D1_NUMLOTE","C",aColsSX3[3],aColsSX3[4]})

	buscarSX3("D1_PEDIDO",,aColsSX3)
	Aadd(aCamposSD1,{"D1_PEDIDO","C",aColsSX3[3],aColsSX3[4]})

	buscarSX3("D1_ITEMPC",,aColsSX3)
	Aadd(aCamposSD1,{"D1_ITEMPC","C",aColsSX3[3],aColsSX3[4]})

	If Empty(cAliasSD1) .Or. Select(cAliasSD1) == 0 // Criação da temporária de seleção SD1
		cAliasSD1 := CriaTabTmp(aCamposSD1,{"D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM"},"SELSD1")
	EndIf
Return Nil
//-------------------------------------------------------------------
/*/{Protheus.doc} DadosTabD1
(long_description)
@author felipe.m
@since 10/11/2014
@version 1.0
@param aCamposSD1, array, (Descrição do parâmetro)
@param oModel, objeto, (Descrição do parâmetro)
@param nOperacao, numérico, (Descrição do parâmetro)
@example
(examples)
@see (links_or_references)
/*/
//-------------------------------------------------------------------
Static Function DadosTbSD1(oModel,nOperacao,aCamposSD1)
Local cAliasQRY := GetNextAlias()
Local aArrayQRY := {}
Local cQuery    := ""
Local nI        := 0
Local oModelD07 := oModel:GetModel('D07GRID')
Local lModelUpd := oModel:GetOperation() == MODEL_OPERATION_UPDATE
	cQuery := " SELECT SD1.D1_LOCAL,"
	cQuery +=        " SD1.D1_COD,"
	cQuery +=        " SD1.D1_ITEM,"
	cQuery +=        " SD1.D1_QUANT,"
	cQuery +=        " SD1.D1_QTSEGUM,"
	cQuery +=        " SD1.D1_DOC,"
	cQuery +=        " SD1.D1_SERIE,"
	cQuery +=        " SD1.D1_FORNECE,"
	cQuery +=        " SD1.D1_LOJA,"
	cQuery +=        " SD1.D1_EMISSAO,"
	cQuery +=        " SD1.D1_LOTECTL,"
	cQuery +=        " SD1.D1_NUMLOTE,"
	cQuery +=        " SD1.D1_TIPO,"
	cQuery +=        " SD1.D1_PEDIDO,"
	cQuery +=        " SD1.D1_ITEMPC"
	cQuery +=   " FROM (SELECT SD1A.D1_FILIAL,"
	cQuery +=                " SD1A.D1_LOCAL,"
	cQuery +=                " SD1A.D1_COD,"
	cQuery +=                " SD1A.D1_ITEM,"
	cQuery +=                " SD1A.D1_QUANT,"
	cQuery +=                " SD1A.D1_QTSEGUM,"
	cQuery +=                " SD1A.D1_DOC,"
	cQuery +=                " SD1A.D1_SERIE,"
	cQuery +=                " SD1A.D1_FORNECE,"
	cQuery +=                " SD1A.D1_LOJA,"
	cQuery +=                " SD1A.D1_EMISSAO,"
	cQuery +=                " SD1A.D1_LOTECTL,"
	cQuery +=                " SD1A.D1_NUMLOTE,"
	cQuery +=                " SD1A.D1_TIPO,"
	cQuery +=                " SD1A.D1_PEDIDO,"
	cQuery +=                " SD1A.D1_ITEMPC"
	cQuery +=           " FROM "+RetSqlName("SD1")+" SD1A"
	cQuery +=          " WHERE SD1A.D_E_L_E_T_ = ' '"
	cQuery +=            " AND SD1A.D1_FILIAL = '"+xFilial("SD1")+"' "
	cQuery +=            " AND SD1A.D1_LOCAL = '"+MV_PAR01+"'"
	cQuery +=            " AND SD1A.D1_DOC >= '"+MV_PAR02+"'"
	cQuery +=            " AND SD1A.D1_DOC <= '"+MV_PAR03+"'"
	cQuery +=            " AND SD1A.D1_FORNECE >= '"+MV_PAR04+"'"
	cQuery +=            " AND SD1A.D1_FORNECE <= '"+MV_PAR05+"'"
	cQuery +=            " AND SD1A.D1_LOJA >= '"+MV_PAR06+"'"
	cQuery +=            " AND SD1A.D1_LOJA <= '"+MV_PAR07+"'"
	cQuery +=            " AND SD1A.D1_DTDIGIT >= '"+DTOS(MV_PAR08)+"'"
	cQuery +=            " AND SD1A.D1_DTDIGIT <= '"+DTOS(MV_PAR09)+"'"
	cQuery +=            " AND SD1A.D1_TES = ' '"
	cQuery +=            " AND SD1A.D1_TIPO = 'N'"
	cQuery +=            " AND (SD1A.D1_CODDIS = ' ' OR SD1A.D1_CODDIS = '"+oModel:GetModel("D06FIELDS"):GetValue('D06_CODDIS',1)+"')"
	//----------------------------------------
	// Caso a opção Restringir Pedido de Compra == "Sim",
	// considera apenas as pré-notas com pedido de compra atrelado
	//----------------------------------------
	cQuery +=           " AND SD1A.D1_PEDIDO >= '"+MV_PAR10+"'"
	cQuery +=           " AND SD1A.D1_PEDIDO <= '"+MV_PAR11+"'"
	If MV_PAR12 == 1 // Restringir Pedido de Compra == "Sim"
		cQuery +=        " AND SD1A.D1_PEDIDO <> ' '"
	EndIf
	If ExistBlock("WMS325D1QR")
		cQuery += ExecBlock("WMS325D1QR")
	EndIf

	cQuery +=            " ) SD1 WHERE 1 = 1"

	If lModelUpd
		//----------------------------------------
		// Quando a operação for 3 (Incluir Documento), precisa desconsiderar
		// os documentos que já estão em alguma distribuição
		//----------------------------------------
		cQuery += " AND NOT EXISTS ("
		cQuery +=         " SELECT 1"
		cQuery +=           " FROM "+RetSqlName('D07')+" D07"
		cQuery +=          " INNER JOIN "+RetSqlName('D06')+" D06"
		cQuery +=             " ON D07.D07_CODDIS = D06.D06_CODDIS "
		cQuery +=          " WHERE D07.D_E_L_E_T_ = ' '"
		cQuery +=            " AND D07.D07_FILIAL = '"+xFilial("D07")+"'"
		cQuery +=            " AND D06.D06_FILIAL = '"+xFilial("D06")+"'"
		cQuery +=            " AND D06.D_E_L_E_T_ = ' '"
		cQuery +=            " AND D06.D06_SITDIS IN ('1','2')"
		cQuery +=            " AND D07.D07_LOCAL = SD1.D1_LOCAL"
		cQuery +=            " AND D07.D07_DOC = SD1.D1_DOC"
		cQuery +=            " AND D07.D07_SERIE = SD1.D1_SERIE"
		cQuery +=            " AND D07.D07_FORNEC = SD1.D1_FORNECE"
		cQuery +=            " AND D07.D07_LOJA = SD1.D1_LOJA"
		cQuery +=            " AND D07.D07_PRODUT = SD1.D1_COD"
		cQuery +=            " AND D07.D07_ITEM = SD1.D1_ITEM"

		//----------------------------------------
		// Desconsidera os documentos que já estão em alguma distribuição
		// EXCETO aqueles que ele acabou de excluir no modelo de dados D07
		//----------------------------------------
		cQuery += " AND D07.D07_DOC || D07.D07_SERIE || D07.D07_FORNEC || D07.D07_LOJA || D07.D07_PRODUT || D07.D07_ITEM || D07.D07_LOTECT || D07.D07_NUMLOT NOT IN ("

		For nI := 1 To oModelD07:Length(.F.)

			oModelD07:GoLine(nI)
			If oModelD07:IsDeleted()

				cQuery += "'"
				If !Empty(oModelD07:GetValue('D07_DOC',nI))
					cQuery += oModelD07:GetValue('D07_DOC',nI)+oModelD07:GetValue('D07_SERIE',nI)+oModelD07:GetValue('D07_FORNEC',nI)+oModelD07:GetValue('D07_LOJA',nI)+oModelD07:GetValue('D07_PRODUT',nI)+oModelD07:GetValue('D07_ITEM',nI)+oModelD07:GetValue('D07_LOTECT',nI)+oModelD07:GetValue('D07_NUMLOT',nI)
				EndIf
				cQuery += "',"

			EndIf

		Next nI
		cQuery += "'')"

		cQuery += ")"
	EndIf
	//----------------------------------------
	// Considerar apenas os documentos (SD1) que possuem um
	// pedido de venda com o produto
	//----------------------------------------
	cQuery += " AND (EXISTS ("
	cQuery +=     " SELECT 1"
	cQuery +=       " FROM "+RetSqlName("SC9")+" SC9"
	cQuery +=      " WHERE SC9.C9_FILIAL = '"+xFilial("SC9")+"'"
	cQuery +=        " AND SC9.C9_PRODUTO = SD1.D1_COD"
	cQuery +=        " AND SC9.C9_NFISCAL = ''"
	cQuery +=        " AND SC9.C9_BLEST = '02'"
	cQuery +=        " AND SC9.C9_BLCRED = '"+Space(TamSx3("C9_BLCRED")[1])+"'"
	cQuery +=        " AND SC9.C9_SERVIC IN (SELECT DC5.DC5_SERVIC"
	cQuery +=                                " FROM "+RetSqlName("DC5")+" DC5"
	cQuery +=                               " WHERE DC5.DC5_FILIAL = '"+xFilial("DC5")+"'"
	cQuery +=                                 " AND DC5.DC5_OPERAC = '4'"
	cQuery +=                                 " AND DC5.D_E_L_E_T_ = ' ')"
	cQuery +=        " AND SC9.D_E_L_E_T_ = ' ')"
	//----------------------------------------
	// Considerar apenas os documentos (SD1) que possuem um
	// plano de distribuição com o produto
	//----------------------------------------
	cQuery += " OR EXISTS ("
	cQuery +=     " SELECT 1"
	cQuery +=       " FROM "+RetSqlName("D0M")+" D0M"
	cQuery +=      " WHERE D0M.D0M_FILIAL = '"+xFilial("D0M")+"'"
	cQuery +=        " AND D0M.D0M_PRODUT = SD1.D1_COD"
	cQuery +=        " AND (D0M.D0M_QTDDEM - D0M.D0M_QTDDIS) > 0"
	cQuery +=        " AND D0M.D_E_L_E_T_ = ' '))"
	//----------------------------------------
	// Desconsiderar os itens ja inclusos na grid D07;
	//----------------------------------------
	cQuery += " AND SD1.D1_FILIAL || SD1.D1_DOC || SD1.D1_SERIE || SD1.D1_FORNECE || SD1.D1_LOJA || SD1.D1_COD || SD1.D1_ITEM"

	If nOperacao == MODEL_OPERATION_INSERT
		cQuery += " NOT "
	EndIf
	cQuery += " IN ( "

	For nI := 1 To oModelD07:Length()

		oModelD07:GoLine(nI)
		If !oModelD07:IsDeleted()

			cQuery += "'"
			If !Empty(oModelD07:GetValue('D07_DOC',nI))
				cQuery += oModelD07:GetValue('D07_FILIAL',nI)+oModelD07:GetValue('D07_DOC',nI)+oModelD07:GetValue('D07_SERIE',nI)+oModelD07:GetValue('D07_FORNEC',nI)+oModelD07:GetValue('D07_LOJA',nI)+oModelD07:GetValue('D07_PRODUT',nI)+oModelD07:GetValue('D07_ITEM',nI)
			EndIf
			cQuery += "',"

		EndIf
	Next
	cQuery += "'')"
	cQuery += " AND NOT EXISTS (SELECT 1"
	cQuery +=                   " FROM "+RetSqlName("DCX")+" DCX"
	cQuery +=                  " INNER JOIN "+RetSqlName("DCW")+" DCW"
	cQuery +=                     " ON DCW.DCW_FILIAL = '"+xFilial("DCW")+"'"
	cQuery +=                    " AND DCW.DCW_EMBARQ = DCX.DCX_EMBARQ"
	cQuery +=                    " AND DCW.DCW_SITEMB IN ('1','2','3','4','5')"
	cQuery +=                    " AND DCW.D_E_L_E_T_ = ' '"
	cQuery +=                  " WHERE DCX.DCX_FILIAL = '"+xFilial("DCX")+"'"
	cQuery +=                    " AND DCX.DCX_DOC = SD1.D1_DOC"
	cQuery +=                    " AND DCX.DCX_SERIE = SD1.D1_SERIE"
	cQuery +=                    " AND DCX.DCX_FORNEC = SD1.D1_FORNECE"
	cQuery +=                    " AND DCX.DCX_LOJA = SD1.D1_LOJA"
	cQuery +=                    " AND DCX.D_E_L_E_T_ = ' ')"
	cQuery := ChangeQuery(cQuery)
	DBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQRY,.F.,.T.)

	TCSETFIELD( cAliasQRY,'D1_EMISSAO','D')

	(cAliasQRY)->(dbGoTop())
	While !(cAliasQRY)->(Eof())
		Aadd(aArrayQRY,{ " ",;
					(cAliasQRY)->D1_LOCAL, ;
					(cAliasQRY)->D1_COD, ;
					Posicione("SB1",1,xFilial("SB1")+(cAliasQRY)->D1_COD,"B1_DESC"), ;
					(cAliasQRY)->D1_ITEM, ;
					(cAliasQRY)->D1_QUANT, ;
					(cAliasQRY)->D1_QTSEGUM, ;
					(cAliasQRY)->D1_DOC, ;
					(cAliasQRY)->D1_SERIE, ;
					(cAliasQRY)->D1_FORNECE, ;
					(cAliasQRY)->D1_LOJA, ;
					(cAliasQRY)->D1_EMISSAO, ;
					(cAliasQRY)->D1_LOTECTL, ;
					(cAliasQRY)->D1_NUMLOTE, ;
					(cAliasQRY)->D1_PEDIDO, ;
					(cAliasQRY)->D1_ITEMPC })
		(cAliasQRY)->(DbSkip())
	EndDo
	(cAliasQRY)->(DbCloseArea())

	cAliasSD1 := MntCargDad(cAliasSD1,aArrayQRY,aCamposSD1)
Return Nil
//-------------------------------------------------------------------
/*/{Protheus.doc} WMSA325APD
Criação do MarkBrowse de Itens do Pedido de Venda
@author felipe.m
@since 19/09/2014
@version 1.0
@param oModel, objeto, Modelo de dados da aplicação
@param nOperacao, numérico, Operação de manipulação dos dados
/*/
//-------------------------------------------------------------------
Function WMSA325APD(oModel,nOperacao)
Local oDlgPed, oBrwSC9
Local aAreaD06   := D06->(GetArea())
Local aAreaD07   := D07->(GetArea())
Local aAreaD08   := D08->(GetArea())
Local aAreaD09   := D09->(GetArea())
Local aCoors     := FWGetDialogSize(oMainWnd)
Local aColsSX3   := {}
Local aFieldD08  := {}
Local aCamposD08 := {}
Local lDelete    := nOperacao == MODEL_OPERATION_DELETE
Local lContinua  := .T.
Local lMarcar    := .F.
Local cWMSLCFT   := SuperGetMV('MV_WMSLCFT',.F.,'') // Local de falta
Local cWMSLCEX   := SuperGetMV('MV_WMSLCEX',.F.,'') // Local de excesso
	If !lDelete .And. !pergunte('WMSA3252',.T.)
		lContinua := .F.
	EndIf
	If lContinua
		If MV_PAR01 $ cWMSLCFT
			WmsMessage(STR0041,WMSA325A13) // Armazém configurado como local para itens com divergências de 'falta' na conferência do recebimento (MV_WMSLCFT), não pode ser considerado na distribuição.
			lContinua := .F.
		ElseIf MV_PAR01 $ cWMSLCEX
			WmsMessage(STR0042,WMSA325A14) // Armazém configurado como local para itens com divergências de 'excesso' na conferência do recebimento (MV_WMSLCEX), não pode ser considerado na distribuição.
			lContinua := .F.
		EndIf
		If lContinua
			// Cria campos busca de pedidos/planos
			Aadd(aFieldD08,{buscarSX3("D08_PEDIDO",,aColsSX3),"D08_PEDIDO","C",aColsSX3[3],aColsSX3[4],aColsSX3[2]})
			Aadd(aFieldD08,{buscarSX3("D08_ITEM"  ,,aColsSX3),"D08_ITEM"  ,"C",aColsSX3[3],aColsSX3[4],aColsSX3[2]})
			Aadd(aFieldD08,{buscarSX3("D08_CLIENT",,aColsSX3),"D08_CLIENT","C",aColsSX3[3],aColsSX3[4],aColsSX3[2]})
			Aadd(aFieldD08,{buscarSX3("D08_LOJA"  ,,aColsSX3),"D08_LOJA"  ,"C",aColsSX3[3],aColsSX3[4],aColsSX3[2]})
			Aadd(aFieldD08,{buscarSX3("D08_PRODUT",,aColsSX3),"D08_PRODUT","C",aColsSX3[3],aColsSX3[4],aColsSX3[2]})
			Aadd(aFieldD08,{buscarSX3("D08_DPROD" ,,aColsSX3),"D08_DPROD" ,"C",aColsSX3[3],aColsSX3[4],aColsSX3[2]})
			Aadd(aFieldD08,{buscarSX3("D08_QTDVEN",,aColsSX3),"D08_QTDVEN","N",aColsSX3[3],aColsSX3[4],aColsSX3[2]})
			Aadd(aFieldD08,{buscarSX3("D08_SEQUEN",,aColsSX3),"D08_SEQUEN","C",aColsSX3[3],aColsSX3[4],aColsSX3[2]})
			Aadd(aFieldD08,{buscarSX3("D08_DATENT",,aColsSX3),"D08_DATENT","D",aColsSX3[3],aColsSX3[4],aColsSX3[2]})
			// Cria Tabela temporária
			CriaTbD08(@aCamposD08)

			If !lDelete
				DadosTbSC9(oModel,nOperacao,aCamposD08)
			Else
				RecalcTmp(oModel,aCamposD08,'SC9')
			EndIf
			// Verifica se há dados
			If (cAliasD08)->(Eof())
				WmsMessage(STR0045,WMSA325A16) // Não há dados para seleção informada!
				lContinua := .F.
			EndIf
		EndIf
		If lContinua
			Define MsDialog oDlgPed Title STR0003 From aCoors[1],aCoors[2] To aCoors[3],aCoors[4] Pixel // Pedidos de Venda/Planos de Distribuição
			oBrwSC9 := FWMarkBrowse():New()
			oBrwSC9:SetAlias(cAliasD08)
			oBrwSC9:SetOwner(oDlgPed)
			oBrwSC9:SetFieldMark('D08_OK')
			oBrwSC9:SetTemporary(.T.)
			oBrwSC9:oBrowse:SetDBFFilter(.T.)
			oBrwSC9:oBrowse:SetUseFilter()
			oBrwSC9:SetFields( aFieldD08 )
			oBrwSC9:bAllMark := { || SetMarkAll(oBrwSC9:Mark(),lMarcar := !lMarcar, 'D08', oModel, nOperacao ), oBrwSC9:Refresh(.T.)  }
			oBrwSC9:SetMenuDef('')
			oBrwSC9:SetWalkThru(.F.)
			oBrwSC9:AddButton(STR0018,{ || MontaD08( oBrwSC9:Mark(), oModel, nOperacao, oDlgPed, 'SC9' ),oBrwSC9:Refresh(.T.) },, 2, 0)
			oBrwSC9:SetDescription(STR0021) // Itens Pedidos de Venda
			oBrwSC9:DisableDetails()
			oBrwSC9:SetFixedBrowse(.T.)

			oBrwSC9:Activate()

			Activate MsDialog oDlgPed Center
		EndIf
	EndIf

	oModel:GetModel('D07GRID'):GoLine( 1 )
	oModel:GetModel('D08GRID'):GoLine( 1 )
	oModel:GetModel('D09GRID'):GoLine( 1 )

	RestArea(aAreaD09)
	RestArea(aAreaD08)
	RestArea(aAreaD07)
	RestArea(aAreaD06)
Return Nil
//-------------------------------------------------------------------
/*/{Protheus.doc} CriaTbD08
(long_description)
@author felipe.m
@since 11/11/2014
@version 1.0
@param aCamposSC9, array, (Descrição do parâmetro)
@example
(examples)
@see (links_or_references)
/*/
//-------------------------------------------------------------------
Static Function CriaTbD08(aCamposD08)
Local aColsSX3 := {}

	buscarSX3("C9_OK",,aColsSX3)
	Aadd(aCamposD08,{"D08_OK","C",aColsSX3[3],aColsSX3[4]})

	buscarSX3("D08_LOCAL",,aColsSX3)
	Aadd(aCamposD08,{"D08_LOCAL","C",aColsSX3[3],aColsSX3[4]})

	buscarSX3("D08_PEDIDO",,aColsSX3)
	Aadd(aCamposD08,{"D08_PEDIDO","C",aColsSX3[3],aColsSX3[4]})

	buscarSX3("D08_ITEM",,aColsSX3)
	Aadd(aCamposD08,{"D08_ITEM","C",aColsSX3[3],aColsSX3[4]})

	buscarSX3("D08_CLIENT",,aColsSX3)
	Aadd(aCamposD08,{"D08_CLIENT","C",aColsSX3[3],aColsSX3[4]})

	buscarSX3("D08_LOJA",,aColsSX3)
	Aadd(aCamposD08,{"D08_LOJA","C",aColsSX3[3],aColsSX3[4]})

	buscarSX3("D08_PRODUT",,aColsSX3)
	Aadd(aCamposD08,{"D08_PRODUT","C",aColsSX3[3],aColsSX3[4]})

	buscarSX3("D08_DPROD",,aColsSX3)
	Aadd(aCamposD08,{"D08_DPROD","C",aColsSX3[3],aColsSX3[4]})

	buscarSX3("D08_QTDVEN",,aColsSX3)
	Aadd(aCamposD08,{"D08_QTDVEN","N",aColsSX3[3],aColsSX3[4]})

	buscarSX3("D08_QTDVE2",,aColsSX3)
	Aadd(aCamposD08,{"D08_QTDVE2","N",aColsSX3[3],aColsSX3[4]})

	buscarSX3("D08_SEQUEN",,aColsSX3)
	Aadd(aCamposD08,{"D08_SEQUEN","C",aColsSX3[3],aColsSX3[4]})

	buscarSX3("D08_LOTECT",,aColsSX3)
	Aadd(aCamposD08,{"D08_LOTECT","C",aColsSX3[3],aColsSX3[4]})

	buscarSX3("D08_NUMLOT",,aColsSX3)
	Aadd(aCamposD08,{"D08_NUMLOT","C",aColsSX3[3],aColsSX3[4]})

	buscarSX3("D08_DATENT",,aColsSX3)
	Aadd(aCamposD08,{"D08_DATENT","D",aColsSX3[3],aColsSX3[4]})

	If Empty(cAliasD08) .Or. Select(cAliasD08) == 0 // Criação da temporária de seleção SC9
		cAliasD08 := CriaTabTmp(aCamposD08,{"D08_PEDIDO+D08_ITEM+D08_SEQUEN+D08_PRODUT"},"SELD08")
	EndIf
Return Nil
//-------------------------------------------------------------------
/*/{Protheus.doc} DadosTabC9
(long_description)
@author felipe.m
@since 11/11/2014
@version 1.0
@param aCamposSC9, array, (Descrição do parâmetro)
@param oModel, objeto, (Descrição do parâmetro)
@param nOperacao, numérico, (Descrição do parâmetro)
@example
(examples)
@see (links_or_references)
/*/
//-------------------------------------------------------------------
Static Function DadosTbSC9(oModel,nOperacao, aCamposD08)
Local cAliasQRY := GetNextAlias()
Local aArrayQRY := {}
Local cQuery := ""
Local nI := 0
Local oModelD07 := oModel:GetModel('D07GRID')
Local oModelD08 := oModel:GetModel('D08GRID')
Local lModelUpd := oModel:GetOperation() == MODEL_OPERATION_UPDATE

	cQuery := " SELECT SC9A.C9_FILIAL,"
	cQuery +=        " SC9A.C9_PEDIDO,"
	cQuery +=        " SC9A.C9_ITEM,"
	cQuery +=        " SC9A.C9_CLIENTE,"
	cQuery +=        " SC9A.C9_LOJA,"
	cQuery +=        " SC9A.C9_PRODUTO,"
	cQuery +=        " SC9A.C9_QTDLIB,"
	cQuery +=        " SC9A.C9_SEQUEN,"
	cQuery +=        " SC9A.C9_QTDLIB2,"
	cQuery +=        " SC9A.C9_SERVIC,"
	cQuery +=        " SC9A.C9_LOCAL,"
	cQuery +=        " SC9A.C9_LOTECTL,"
	cQuery +=        " SC9A.C9_NUMLOTE,"
	cQuery +=        " SC9A.C9_DATENT"
	cQuery +=   " FROM (SELECT SC9B.C9_FILIAL,"
	cQuery +=                " SC9B.C9_PEDIDO,"
	cQuery +=                " SC9B.C9_ITEM,"
	cQuery +=                " SC9B.C9_CLIENTE,"
	cQuery +=                " SC9B.C9_LOJA,"
	cQuery +=                " SC9B.C9_PRODUTO,"
	cQuery +=                " SC9B.C9_QTDLIB,"
	cQuery +=                " SC9B.C9_SEQUEN,"
	cQuery +=                " SC9B.C9_QTDLIB2,"
	cQuery +=                " SC9B.C9_SERVIC,"
	cQuery +=                " SC9B.C9_LOCAL,"
	cQuery +=                " SC9B.C9_LOTECTL,"
	cQuery +=                " SC9B.C9_NUMLOTE,"
	cQuery +=                " SC9B.C9_NFISCAL,"
	cQuery +=                " SC9B.C9_DATALIB,"
	cQuery +=                " SC9B.C9_DATENT,"
	cQuery +=                " SC9B.C9_BLEST,"
	cQuery +=                " SC9B.C9_BLCRED"
	cQuery +=           " FROM "+RetSqlName("SC9")+" SC9B"
	cQuery +=          " WHERE SC9B.C9_FILIAL = '"+xFilial("SC9")+"'"
	cQuery +=            " AND SC9B.D_E_L_E_T_ = ' ') SC9A"
	cQuery +=  " WHERE SC9A.C9_NFISCAL = ' '"
	cQuery +=    " AND SC9A.C9_LOCAL = '"+MV_PAR01+"'"
	cQuery +=    " AND SC9A.C9_PEDIDO >= '"+MV_PAR02+"'"
	cQuery +=    " AND SC9A.C9_PEDIDO <= '"+MV_PAR03+"'"
	cQuery +=    " AND SC9A.C9_CLIENTE >= '"+MV_PAR04+"'"
	cQuery +=    " AND SC9A.C9_CLIENTE <= '"+MV_PAR05+"'"
	cQuery +=    " AND SC9A.C9_LOJA >= '"+MV_PAR06+"'"
	cQuery +=    " AND SC9A.C9_LOJA <= '"+MV_PAR07+"'"
	cQuery +=    " AND SC9A.C9_DATALIB >= '"+DTOS(MV_PAR08)+"'"
	cQuery +=    " AND SC9A.C9_DATALIB <= '"+DTOS(MV_PAR09)+"'"
	cQuery +=    " AND SC9A.C9_BLEST = '02'"
	cQuery +=    " AND SC9A.C9_BLCRED = '"+Space(TamSx3("C9_BLCRED")[1])+"'"
	cQuery +=    " AND SC9A.C9_SERVIC IN (SELECT DC5.DC5_SERVIC"
	cQuery +=                             " FROM "+RetSqlName("DC5")+" DC5"
	cQuery +=                            " WHERE DC5.DC5_FILIAL = '"+xFilial("DC5")+"'"
	cQuery +=                              " AND DC5.DC5_OPERAC = '4'"
	cQuery +=                              " AND DC5.D_E_L_E_T_ = ' ')"
	If lWMS325C9
		cQuery += ExecBlock("WMS325C9QR")
	EndIf
	//----------------------------------------
	// Desconsiderar os pedidos que já estão em alguma distribuição
	//----------------------------------------
	cQuery +=    " AND NOT EXISTS ("
	cQuery +=            " SELECT 1 FROM "+RetSqlName("D08")+" D08"
	cQuery +=             " INNER JOIN "+RetSqlName('D06')+" D06"
	cQuery +=                " ON D06.D06_CODDIS = D08.D08_CODDIS"
	cQuery +=             " WHERE D08.D_E_L_E_T_ = ' '"
	cQuery +=               " AND D06.D06_SITDIS IN ('1','2')"
	cQuery +=               " AND D06.D_E_L_E_T_ = ' '"
	cQuery +=               " AND D08.D08_FILIAL = '"+xFilial("D08")+"'"
	cQuery +=               " AND D08.D08_LOCAL = SC9A.C9_LOCAL"
	cQuery +=               " AND D08.D08_PEDIDO = SC9A.C9_PEDIDO"
	cQuery +=               " AND D08.D08_ITEM = SC9A.C9_ITEM"
	cQuery +=               " AND D08.D08_SEQUEN = SC9A.C9_SEQUEN"
	cQuery +=               " AND D08.D08_PRODUT = SC9A.C9_PRODUTO"
	//----------------------------------------
	// Considerar os pedidos que não foram totalmente distribuídos,
	// em montagens de status "2=Distribuída"
	//----------------------------------------
	cQuery +=               " AND ( (D08.D08_QTDDIS = SC9A.C9_QTDLIB AND D06.D06_SITDIS = '2') OR D06.D06_SITDIS = '1' )"
	//----------------------------------------
	// Desconsidera os pedidos que já estão em alguma distribuição
	// EXCETO aqueles que ele acabou de excluir no modelo de dados D08
	//----------------------------------------
	If lModelUpd
		cQuery +=           " AND D08.D08_PEDIDO || D08.D08_ITEM || D08.D08_SEQUEN || D08.D08_PRODUT NOT IN ( "

		For nI := 1 To oModelD08:Length(.F.)

			oModelD08:GoLine(nI)
			If oModelD08:IsDeleted()

				cQuery += "'"
				If !Empty(oModelD08:GetValue('D08_PEDIDO',nI))
					cQuery += oModelD08:GetValue('D08_PEDIDO',nI)+oModelD08:GetValue('D08_ITEM',nI)+oModelD08:GetValue('D08_SEQUEN',nI)+oModelD08:GetValue('D08_PRODUT',nI)
				EndIf
				cQuery += "',"

			EndIf

		Next nI
		cQuery += "'' )"

	EndIf
	cQuery += " ) "

	cQuery := ChangeQuery(cQuery)

	DBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQRY,.F.,.T.)
	TcSetField(cAliasQRY,'C9_DATENT','D')
	(cAliasQRY)->(dbGoTop())
	While !(cAliasQRY)->(Eof())
		//----------------------------------------
		// Considerar apenas os pedidos de venda que possuem produtos
		// referentes aos documentos selecionados anterirormente
		//----------------------------------------
		If oModelD07:SeekLine( { {"D07_PRODUT",(cAliasQRY)->C9_PRODUTO} } )
			//----------------------------------------
			// Desconsiderar os itens ja inclusos na grid D08;
			//----------------------------------------
			If Empty( oModelD08:GetValue('D08_PEDIDO',1) ) .Or. !oModelD08:SeekLine( { {"D08_PEDIDO",(cAliasQRY)->C9_PEDIDO},{"D08_ITEM",(cAliasQRY)->C9_ITEM},{"D08_SEQUEN",(cAliasQRY)->C9_SEQUEN},{"D08_PRODUT",(cAliasQRY)->C9_PRODUTO} } )
				Aadd(aArrayQRY,{ " ",;
							(cAliasQRY)->C9_LOCAL,;
							(cAliasQRY)->C9_PEDIDO,;
							(cAliasQRY)->C9_ITEM,;
							(cAliasQRY)->C9_CLIENTE,;
							(cAliasQRY)->C9_LOJA,;
							(cAliasQRY)->C9_PRODUTO,;
							Posicione("SB1",1,xFilial("SB1")+(cAliasQRY)->C9_PRODUTO,"B1_DESC"),;
							(cAliasQRY)->C9_QTDLIB,;
							(cAliasQRY)->C9_QTDLIB2,;
							(cAliasQRY)->C9_SEQUEN,;
							(cAliasQRY)->C9_LOTECTL,;
							(cAliasQRY)->C9_NUMLOTE,;
							(cAliasQRY)->C9_DATENT})
			EndIf
		EndIf
		(cAliasQRY)->(DbSkip())
	EndDo
	(cAliasQRY)->(DbCloseArea())

	cAliasD08 := MntCargDad(cAliasD08,aArrayQRY,aCamposD08)
Return Nil
//-------------------------------------------------------------------
/*/{Protheus.doc} WMSA325APL
Criação do MarkBrowse de Itens do Plano de distribuiçaõ
@version 1.0
@param oModel, objeto, Modelo de dados da aplicação
@param nOperacao, numérico, Operação de manipulação dos dados
/*/
//-------------------------------------------------------------------
Function WMSA325APL(oModel,nOperacao)
Local oDlgPed, oBrwD0M
Local aAreaD06   := D06->(GetArea())
Local aAreaD07   := D07->(GetArea())
Local aAreaD08   := D08->(GetArea())
Local aAreaD09   := D09->(GetArea())
Local aCoors     := FWGetDialogSize(oMainWnd)
Local aColsSX3   := {}
Local aFieldD08  := {}
Local aCamposD08 := {}
Local lDelete    := nOperacao == MODEL_OPERATION_DELETE
Local lContinua  := .T.
Local lMarcar    := .F.
Local cWMSLCFT   := SuperGetMV('MV_WMSLCFT',.F.,'') // Local de falta
Local cWMSLCEX   := SuperGetMV('MV_WMSLCEX',.F.,'') // Local de excesso
	If !lDelete .And. !pergunte('WMSA3253',.T.)
		lContinua := .F.
	EndIf
	If lContinua
		If MV_PAR01 $ cWMSLCFT
			WmsMessage(STR0041,WMSA325A16) // Armazém configurado como local para itens com divergências de 'falta' na conferência do recebimento (MV_WMSLCFT), não pode ser considerado na distribuição.
			lContinua := .F.
		ElseIf MV_PAR01 $ cWMSLCEX
			WmsMessage(STR0042,WMSA325A17) // Armazém configurado como local para itens com divergências de 'excesso' na conferência do recebimento (MV_WMSLCEX), não pode ser considerado na distribuição.
			lContinua := .F.
		EndIf
		If lContinua
			// Cria campos busca de pedidos/planos
			Aadd(aFieldD08,{buscarSX3("D08_PEDIDO",,aColsSX3),"D08_PEDIDO","C",aColsSX3[3],aColsSX3[4],aColsSX3[2]})
			Aadd(aFieldD08,{buscarSX3("D08_ITEM"  ,,aColsSX3),"D08_ITEM"  ,"C",aColsSX3[3],aColsSX3[4],aColsSX3[2]})
			Aadd(aFieldD08,{buscarSX3("D08_CLIENT",,aColsSX3),"D08_CLIENT","C",aColsSX3[3],aColsSX3[4],aColsSX3[2]})
			Aadd(aFieldD08,{buscarSX3("D08_LOJA"  ,,aColsSX3),"D08_LOJA"  ,"C",aColsSX3[3],aColsSX3[4],aColsSX3[2]})
			Aadd(aFieldD08,{buscarSX3("D08_PRODUT",,aColsSX3),"D08_PRODUT","C",aColsSX3[3],aColsSX3[4],aColsSX3[2]})
			Aadd(aFieldD08,{buscarSX3("D08_DPROD" ,,aColsSX3),"D08_DPROD" ,"C",aColsSX3[3],aColsSX3[4],aColsSX3[2]})
			Aadd(aFieldD08,{buscarSX3("D08_QTDVEN",,aColsSX3),"D08_QTDVEN","N",aColsSX3[3],aColsSX3[4],aColsSX3[2]})
			Aadd(aFieldD08,{buscarSX3("D08_SEQUEN",,aColsSX3),"D08_SEQUEN","C",aColsSX3[3],aColsSX3[4],aColsSX3[2]})
			Aadd(aFieldD08,{buscarSX3("D08_DATENT",,aColsSX3),"D08_DATENT","D",aColsSX3[3],aColsSX3[4],aColsSX3[2]})
			// Cria Tabela temporária
			CriaTbD08(@aCamposD08)

			If !lDelete
				DadosTbD0M(oModel,nOperacao,aCamposD08)
			Else
				RecalcTmp(oModel,aCamposD08,'D0M')
			EndIf
			// Verifica se há dados
			If (cAliasD08)->(Eof())
				WmsMessage(STR0045,WMSA325A18) // Não há dados para seleção informada!
				lContinua := .F.
			EndIf
		EndIf
		If lContinua

			Define MsDialog oDlgPed Title STR0003 From aCoors[1],aCoors[2] To aCoors[3],aCoors[4] Pixel // Pedidos de Venda

			oBrwD0M := FWMarkBrowse():New()
			oBrwD0M:SetAlias(cAliasD08)
			oBrwD0M:SetOwner(oDlgPed)
			oBrwD0M:SetFieldMark('D08_OK')
			oBrwD0M:SetTemporary(.T.)
			oBrwD0M:oBrowse:SetDBFFilter(.T.)
			oBrwD0M:oBrowse:SetUseFilter()
			oBrwD0M:SetFields( aFieldD08 )
			oBrwD0M:bAllMark := { || SetMarkAll(oBrwD0M:Mark(),lMarcar := !lMarcar, 'D08', oModel, nOperacao ), oBrwD0M:Refresh(.T.)  }
			oBrwD0M:SetMenuDef('')
			oBrwD0M:SetWalkThru(.F.)
			oBrwD0M:AddButton(STR0018,{ || MontaD08( oBrwD0M:Mark(), oModel, nOperacao, oDlgPed, 'D0M' ),oBrwD0M:Refresh(.T.) },, 2, 0)
			oBrwD0M:SetDescription(STR0051) // Itens plano de distribuição
			oBrwD0M:DisableDetails()
			oBrwD0M:SetFixedBrowse(.T.)

			oBrwD0M:Activate()

			Activate MsDialog oDlgPed Center
		EndIf
	EndIf

	oModel:GetModel('D07GRID'):GoLine( 1 )
	oModel:GetModel('D08GRID'):GoLine( 1 )
	oModel:GetModel('D09GRID'):GoLine( 1 )

	RestArea(aAreaD09)
	RestArea(aAreaD08)
	RestArea(aAreaD07)
	RestArea(aAreaD06)
Return Nil
//-------------------------------------------------------------------
/*/{Protheus.doc} DadosTbD0M
(long_description)
@author felipe.m
@since 11/11/2014
@version 1.0
@param aCamposSC9, array, (Descrição do parâmetro)
@param oModel, objeto, (Descrição do parâmetro)
@param nOperacao, numérico, (Descrição do parâmetro)
@example
(examples)
@see (links_or_references)
/*/
//-------------------------------------------------------------------
Static Function DadosTbD0M(oModel,nOperacao, aCamposD08)
Local cAliasQRY := GetNextAlias()
Local aArrayQRY := {}
Local cQuery := ""
Local nI := 0
Local oModelD07 := oModel:GetModel('D07GRID')
Local oModelD08 := oModel:GetModel('D08GRID')
Local lModelUpd := oModel:GetOperation() == MODEL_OPERATION_UPDATE

	cQuery := " SELECT D0MA.D0M_FILIAL,"
	cQuery +=        " D0MA.D0M_CODPLN,"
	cQuery +=        " D0MA.D0M_ITEM,"
	cQuery +=        " D0MA.D0M_CLIENT,"
	cQuery +=        " D0MA.D0M_LOJA,"
	cQuery +=        " D0MA.D0M_PRODUT,"
	cQuery +=        " D0MA.D0M_QTDDEM,"
	cQuery +=        " D0MA.D0M_QTDDE2,"
	cQuery +=        " D0MA.D0M_LOCAL,"
	cQuery +=        " D0MA.D0M_LOTECT,"
	cQuery +=        " D0MA.D0M_NUMLOT,"
	cQuery +=        " D0MA.D0M_DATENT"
	cQuery +=   " FROM (SELECT D0MB.D0M_FILIAL,"
	cQuery +=                " D0MB.D0M_CODPLN,"
	cQuery +=                " D0MB.D0M_ITEM,"
	cQuery +=                " D0MB.D0M_CLIENT,"
	cQuery +=                " D0MB.D0M_LOJA,"
	cQuery +=                " D0MB.D0M_PRODUT,"
	cQuery +=                " (D0MB.D0M_QTDDEM - D0MB.D0M_QTDDIS) D0M_QTDDEM,"
	cQuery +=                " (D0MB.D0M_QTDDE2 - D0MB.D0M_QTDDI2) D0M_QTDDE2,"
	cQuery +=                " D0MB.D0M_LOCAL,"
	cQuery +=                " D0MB.D0M_LOTECT,"
	cQuery +=                " D0MB.D0M_NUMLOT,"
	cQuery +=                " D0MB.D0M_DATENT"
	cQuery +=           " FROM "+RetSqlName("D0M")+" D0MB"
	cQuery +=          " WHERE D0MB.D0M_FILIAL = '"+xFilial("D0M")+"'"
	cQuery +=            " AND D0MB.D_E_L_E_T_ = ' ') D0MA"
	cQuery +=  " WHERE D0MA.D0M_FILIAL = '"+xFilial("D0M")+"'"
	cQuery +=    " AND D0MA.D0M_LOCAL = '"+MV_PAR01+"'"
	cQuery +=    " AND D0MA.D0M_CODPLN >= '"+MV_PAR02+"'"
	cQuery +=    " AND D0MA.D0M_CODPLN <= '"+MV_PAR03+"'"
	cQuery +=    " AND D0MA.D0M_CLIENT >= '"+MV_PAR04+"'"
	cQuery +=    " AND D0MA.D0M_CLIENT <= '"+MV_PAR05+"'"
	cQuery +=    " AND D0MA.D0M_LOJA >= '"+MV_PAR06+"'"
	cQuery +=    " AND D0MA.D0M_LOJA <= '"+MV_PAR07+"'"
	cQuery +=    " AND D0MA.D0M_DATENT >= '"+DTOS(MV_PAR08)+"'"
	cQuery +=    " AND D0MA.D0M_DATENT <= '"+DTOS(MV_PAR09)+"'"
	If lWMS325C9
		cQuery += ExecBlock("WMS325C9QR")
	EndIf
	//----------------------------------------
	// Desconsiderar os pedidos que já estão em alguma distribuição
	//----------------------------------------
	cQuery +=    " AND NOT EXISTS ("
	cQuery +=            " SELECT 1 FROM "+RetSqlName("D08")+" D08"
	cQuery +=             " INNER JOIN "+RetSqlName('D06')+" D06"
	cQuery +=                " ON D06.D06_CODDIS = D08.D08_CODDIS"
	cQuery +=             " WHERE D08.D_E_L_E_T_ = ' '"
	cQuery +=               " AND D06.D06_SITDIS IN ('1','2')"
	cQuery +=               " AND D06.D_E_L_E_T_ = ' '"
	cQuery +=               " AND D08.D08_FILIAL = '"+xFilial("D08")+"'"
	cQuery +=               " AND D08.D08_LOCAL = D0MA.D0M_LOCAL"
	cQuery +=               " AND D08.D08_PEDIDO = D0MA.D0M_CODPLN"
	cQuery +=               " AND D08.D08_ITEM = D0MA.D0M_ITEM"
	cQuery +=               " AND D08.D08_SEQUEN = '01'"
	cQuery +=               " AND D08.D08_PRODUT = D0MA.D0M_PRODUT"
	//----------------------------------------
	// Considerar os pedidos que não foram totalmente distribuídos,
	// em montagens de status "2=Distribuída"
	//----------------------------------------
	cQuery +=               " AND ( (D08.D08_QTDDIS = D0MA.D0M_QTDDEM AND D06.D06_SITDIS = '2') OR D06.D06_SITDIS = '1' )"
	//----------------------------------------
	// Desconsidera os pedidos que já estão em alguma distribuição
	// EXCETO aqueles que ele acabou de excluir no modelo de dados D08
	//----------------------------------------
	If lModelUpd
		cQuery +=           " AND D08.D08_PEDIDO || D08.D08_ITEM || D08.D08_SEQUEN || D08.D08_PRODUT NOT IN ( "

		For nI := 1 To oModelD08:Length(.F.)

			oModelD08:GoLine(nI)
			If oModelD08:IsDeleted()

				cQuery += "'"
				If !Empty(oModelD08:GetValue('D08_PEDIDO',nI))
					cQuery += oModelD08:GetValue('D08_PEDIDO',nI)+oModelD08:GetValue('D08_ITEM',nI)+oModelD08:GetValue('D08_SEQUEN',nI)+oModelD08:GetValue('D08_PRODUT',nI)
				EndIf
				cQuery += "',"

			EndIf

		Next nI
		cQuery += "'' )"

	EndIf
	cQuery += " ) "

	cQuery := ChangeQuery(cQuery)

	DBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQRY,.F.,.T.)
	TcSetField( cAliasQRY,'D0M_DATENT','D')
	(cAliasQRY)->(dbGoTop())
	While !(cAliasQRY)->(Eof())
		//----------------------------------------
		// Considerar apenas os pedidos de venda que possuem produtos
		// referentes aos documentos selecionados anterirormente
		//----------------------------------------
		If oModelD07:SeekLine( { {"D07_PRODUT",(cAliasQRY)->D0M_PRODUT} } )
			//----------------------------------------
			// Desconsiderar os itens ja inclusos na grid D08;
			//----------------------------------------
			If Empty( oModelD08:GetValue('D08_PEDIDO',1) ) .Or. !oModelD08:SeekLine( { {"D08_PEDIDO",(cAliasQRY)->D0M_CODPLN},{"D08_ITEM",(cAliasQRY)->D0M_ITEM},{"D08_SEQUEN",'01'},{"D08_PRODUT",(cAliasQRY)->D0M_PRODUT} } )
				Aadd(aArrayQRY,{ " ",;
							(cAliasQRY)->D0M_LOCAL,;
							(cAliasQRY)->D0M_CODPLN,;
							(cAliasQRY)->D0M_ITEM,;
							(cAliasQRY)->D0M_CLIENT,;
							(cAliasQRY)->D0M_LOJA,;
							(cAliasQRY)->D0M_PRODUT,;
							Posicione("SB1",1,xFilial("SB1")+(cAliasQRY)->D0M_PRODUT,"B1_DESC"),;
							(cAliasQRY)->D0M_QTDDEM,;
							(cAliasQRY)->D0M_QTDDE2,;
							"01",;
							(cAliasQRY)->D0M_LOTECT,;
							(cAliasQRY)->D0M_NUMLOT,;
							(cAliasQRY)->D0M_DATENT})
			EndIf
		EndIf
		(cAliasQRY)->(DbSkip())
	EndDo
	(cAliasQRY)->(DbCloseArea())

	cAliasD08 := MntCargDad(cAliasD08,aArrayQRY,aCamposD08)
Return Nil
//-------------------------------------------------------------------
/*/{Protheus.doc} SetMarkAll
Marca Todos dos itens do respectivo MarkBrowse
@author felipe.m
@since 19/09/2014
@version 1.0
@param cMarca, character, Marca utilizada pelo MarkBrowse
@param lMarcar, ${Logico}, Se marca todos ou desmarca todos
@param cTable, character, Tabela do MarkBrowse [SD1,SC9]
@param oModel, objeto, Modelo de dados da aplicação
@param nOperacao, numérico, Operação de manipulação dos dados
/*/
//-------------------------------------------------------------------
Static Function SetMarkAll(cMarca,lMarcar,cTable,oModel,nOperacao )
Local aAreaTable  := (cTable)->( GetArea() )
	If cTable == 'SD1'
		//----------------------------------------
		// Seleciona todos SD1 para marcação/desmarcação
		//----------------------------------------
		(cAliasSD1)->(dbSetOrder(1))
		(cAliasSD1)->(dbGoTop() )
		While !(cAliasSD1)->(Eof())
			RecLock( cAliasSD1, .F. )
			(cAliasSD1)->D1_OK := IIf( lMarcar, cMarca, '  ' )
			MsUnLock()
			(cAliasSD1)->(dbSkip())
		EndDo
	ElseIf cTable == 'D08'
		//----------------------------------------
		// Seleciona todos SC9 para marcação/desmarcação
		//----------------------------------------
		(cAliasD08)->(dbSetOrder(1))
		(cAliasD08)->(dbGoTop() )
		While !(cAliasD08)->(Eof())
			RecLock( cAliasD08, .F. )
			(cAliasD08)->D08_OK := IIf( lMarcar, cMarca, '  ' )
			MsUnLock()
			(cAliasD08)->(dbSkip())
		EndDo
	EndIf
	RestArea( aAreaTable )
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} MontaD07
Atribui/Exclui à Grid D07 os itens selecionados pela operação "Incluir Documento"
@author felipe.m
@since 19/09/2014
@version 1.0
@param cMarca, character, Marca utilizada pelo MarkBrowse
@param oModel, objeto, Modelo de dados da aplicação
@param nOperacao, numérico, Operação de manipulação dos dados
/*/
//-------------------------------------------------------------------
Static Function MontaD07( cMarca, oModel, nOperacao,oDlgEnt )
Local aAreaAnt := GetArea()
Local nI := 1
Local cCodDis := oModel:GetModel('D06FIELDS'):GetValue('D06_CODDIS')
Local lModelUpd := oModel:GetOperation() == MODEL_OPERATION_UPDATE
Local lInsert   := nOperacao == MODEL_OPERATION_INSERT
Local lDelete   := nOperacao == MODEL_OPERATION_DELETE
Local oModelD07 := oModel:GetModel('D07GRID')
Local oModelD09 := oModel:GetModel('D09GRID')
Local lRet      := .F.


	// Verifica se há dados para operação
	(cAliasSD1)->(dbGoTop())
	Do While !lRet .And. (cAliasSD1)->(!Eof())
		If (cAliasSD1)->D1_OK == cMarca
			lRet := .T.
		EndIf
		(cAliasSD1)->(dbSkip())
	EndDo

	If lRet .And. lDelete .And. !WmsQuestion(STR0035,WMSA325A09)
		lRet := .F.
	EndIf

	If lRet

		If lDelete .And. !lModelUpd
			oModelD07:ClearData()
			oModelD07:InitLine()
			oModelD07:GoLine(1)

			oModelD09:ClearData()
			oModelD09:InitLine()
			oModelD09:GoLine(1)
		EndIf

		oModelD07:SetNoInsertLine(.F.)
		oModelD07:SetNoDeleteLine(.F.)
		oModelD09:SetNoInsertLine(.F.)

		(cAliasSD1)->(dbGoTop())
		If lInsert .Or. ( lDelete .And. !lModelUpd )
			Do While (cAliasSD1)->(!Eof())
				// Tratamento para montar o model com os itens válidos
				// Quando inclusão os marcados são considerados
				// Quando exclusão os marcados são desconsiderados
				If lInsert .And. (cAliasSD1)->D1_OK != cMarca
					(cAliasSD1)->(dbSkip())
					Loop
				ElseIf lDelete .And. (cAliasSD1)->D1_OK == cMarca
					(cAliasSD1)->(dbSkip())
					Loop
				EndIf

				If !Empty( oModelD07:GetValue('D07_DOC',1) )
					oModelD07:AddLine()
				EndIf

				oModelD07:SetValue('D07_FILIAL', xFilial('D07') )
				oModelD07:SetValue('D07_CODDIS', cCodDis )
				oModelD07:SetValue('D07_DOC',    (cAliasSD1)->D1_DOC)
				//oModelD07:SetValue('D07_DPROD',  (cAliasSD1)->D1_DESC)
				oModelD07:SetValue('D07_ITEM',   (cAliasSD1)->D1_ITEM)
				oModelD07:SetValue('D07_LOCAL',  (cAliasSD1)->D1_LOCAL)
				oModelD07:SetValue('D07_PRODUT', (cAliasSD1)->D1_COD)
				oModelD07:SetValue('D07_LOTECT', (cAliasSD1)->D1_LOTECTL)
				oModelD07:SetValue('D07_NUMLOT', (cAliasSD1)->D1_NUMLOTE)
				oModelD07:SetValue('D07_QTDENT', (cAliasSD1)->D1_QUANT)
				//oModelD07:SetValue('D07_SDOC',   (cAliasSD1)->D1_SERIE)
				oModelD07:SetValue('D07_FORNEC', (cAliasSD1)->D1_FORNECE)
				oModelD07:SetValue('D07_LOJA',   (cAliasSD1)->D1_LOJA)
				oModelD07:SetValue('D07_DTEMIS', (cAliasSD1)->D1_EMISSAO)
				oModelD07:SetValue('D07_SERIE',  (cAliasSD1)->D1_SERIE)
				oModelD07:SetValue('D07_QTDEN2', (cAliasSD1)->D1_QTSEGUM)
				oModelD07:SetValue('D07_PEDIDO', (cAliasSD1)->D1_PEDIDO)
				oModelD07:SetValue('D07_ITEMPC', (cAliasSD1)->D1_ITEMPC)

				MontaD09(oModel, nOperacao, cCodDis)

				(cAliasSD1)->(dbSkip())
			EndDo
		Else
			For nI := 1 To oModelD07:Length()
				oModelD07:GoLine(nI)
				If !oModelD07:IsDeleted()
					// D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
					If ( (cAliasSD1)->( dbSeek( oModelD07:GetValue('D07_DOC',nI)+oModelD07:GetValue('D07_SERIE',nI)+oModelD07:GetValue('D07_FORNEC',nI)+oModelD07:GetValue('D07_LOJA',nI)+oModelD07:GetValue('D07_PRODUT',nI)+oModelD07:GetValue('D07_ITEM',nI) ) );
						.And. (cAliasSD1)->D1_OK == cMarca )
						oModelD07:DeleteLine()
						lRet := .T.
					EndIf
				EndIf
			Next nI
		EndIf
	EndIf

	If lRet

		//----------------------------------------
		// Busca os pedidos de venda que tenham o pedido de compra
		// informado caso parametro == "Sim"
		//----------------------------------------
		If lInsert .And. MV_PAR12 == 1//-- Restringe Pedido de Compra == "Sim"
			PedComD08(oModel, nOperacao, cCodDis)
		EndIf

		//----------------------------------------
		// Recalcula as quantidades distribuidas na D08 e
		// Exclui D08 que não agrega ao documento de entrada
		//----------------------------------------
		If lDelete
			RecalcD08(oModel)
		EndIf
		WMS325RD09(oModel)

		oModelD09:SetNoInsertLine(.T.)
		oModelD07:SetNoDeleteLine(.T.)
		oModelD07:SetNoInsertLine(.T.)
		RestArea(aAreaAnt)
	EndIf
	// Comportamento da tela
	If !lRet
		WmsMessage(STR0046) //Não há registros marcados!
	Else
		oDlgEnt:End()
	EndIf
Return Nil
//-------------------------------------------------------------------
/*/{Protheus.doc} RecalcTmp
(long_description)
@author felipe.m
@since 10/11/2014
@version 1.0
@param oModel, objeto, (Descrição do parâmetro)
@param lSD1, ${param_type}, (Descrição do parâmetro)
@param lSC9, ${param_type}, (Descrição do parâmetro)
@param aCamposSD1, array, (Descrição do parâmetro)
@example
(examples)
@see (links_or_references)
/*/
//-------------------------------------------------------------------
Static Function RecalcTmp(oModel,aCamposTab,cOrigem)
Local oModelTab
Local nI := 0
Local aTab := {}

	If cOrigem == 'SD1'
		oModelTab := oModel:GetModel('D07GRID')
		For nI := 1 To oModelTab:Length()
			oModelTab:GoLine(nI)
			If !oModelTab:IsDeleted() .And. !Empty(oModelTab:GetValue('D07_LOCAL',nI))
				Aadd(aTab,{ " ",;
						oModelTab:GetValue('D07_LOCAL',nI), ;
						oModelTab:GetValue('D07_PRODUT',nI), ;
						oModelTab:GetValue('D07_DPROD',nI), ;
						oModelTab:GetValue('D07_ITEM',nI), ;
						oModelTab:GetValue('D07_QTDENT',nI), ;
						oModelTab:GetValue('D07_QTDEN2',nI), ;
						oModelTab:GetValue('D07_DOC',nI), ;
						oModelTab:GetValue('D07_SERIE',nI), ;
						oModelTab:GetValue('D07_FORNEC',nI), ;
						oModelTab:GetValue('D07_LOJA',nI), ;
						oModelTab:GetValue('D07_DTEMIS',nI), ;
						oModelTab:GetValue('D07_LOTECT',nI), ;
						oModelTab:GetValue('D07_NUMLOT',nI),;
						oModelTab:GetValue('D07_PEDIDO',nI),;
						oModelTab:GetValue('D07_ITEMPC',nI) })
			EndIf
		Next nI
		cAliasSD1 := MntCargDad(cAliasSD1,aTab,aCamposTab)
	ElseIf cOrigem $ 'SC9|D0M'
		oModelTab := oModel:GetModel('D08GRID')
		For nI := 1 To oModelTab:Length()
			oModelTab:GoLine(nI)
			If !oModelTab:IsDeleted() .And. !Empty(oModelTab:GetValue('D08_LOCAL',nI))
				If oModelTab:GetValue('D08_ORIGEM',nI) == cOrigem
					Aadd(aTab,{ " ",;
							oModelTab:GetValue('D08_LOCAL',nI), ;
							oModelTab:GetValue('D08_PEDIDO',nI), ;
							oModelTab:GetValue('D08_ITEM',nI), ;
							oModelTab:GetValue('D08_CLIENT',nI), ;
							oModelTab:GetValue('D08_LOJA',nI), ;
							oModelTab:GetValue('D08_PRODUT',nI), ;
							oModelTab:GetValue('D08_DPROD',nI), ;
							oModelTab:GetValue('D08_QTDVEN',nI), ;
							oModelTab:GetValue('D08_QTDVE2',nI), ;
							oModelTab:GetValue('D08_SEQUEN',nI), ;
							oModelTab:GetValue('D08_LOTECT',nI), ;
							oModelTab:GetValue('D08_NUMLOT',nI), ;
							oModelTab:GetValue('D08_DATENT',nI) })
				EndIf
			EndIf
		Next nI
		cAliasD08 := MntCargDad(cAliasD08,aTab,aCamposTab)
	EndIf
Return Nil
//-------------------------------------------------------------------
/*/{Protheus.doc} MontaD09
Atribui à Grid D09 os produtos dos documentos selecionados
@author felipe.m
@since 19/09/2014
@version 1.0
@param oModel, objeto, Modelo de dados da aplicação
@param nOperacao, numérico, Operação de manipulação dos dados
@param cCodDis, character, Código da distribuição
@param cAliasTmp, character, Alias temporário
/*/
//-------------------------------------------------------------------
Static Function MontaD09(oModel, nOperacao, cCodDis)
Local oModelD09 := oModel:GetModel('D09GRID')

	If !oModelD09:SeekLine( { {'D09_LOCAL',(cAliasSD1)->D1_LOCAL},{'D09_PRODUT',(cAliasSD1)->D1_COD} } )

		If !Empty( oModelD09:GetValue('D09_PRODUT',1) )
			oModelD09:AddLine()
		EndIf

		oModelD09:SetValue('D09_FILIAL', xFilial('D09') )
		oModelD09:SetValue('D09_CODDIS', cCodDis )
		oModelD09:SetValue('D09_LOCAL',	 (cAliasSD1)->D1_LOCAL)
		oModelD09:SetValue('D09_PRODUT', (cAliasSD1)->D1_COD)
		oModelD09:SetValue('D09_QTDADI', (cAliasSD1)->D1_QUANT)
		oModelD09:SetValue('D09_QTDAD2', (cAliasSD1)->D1_QTSEGUM)
	Else
		oModelD09:SetValue('D09_QTDADI', oModelD09:GetValue('D09_QTDADI') + (cAliasSD1)->D1_QUANT)
		oModelD09:SetValue('D09_QTDAD2', oModelD09:GetValue('D09_QTDAD2') + (cAliasSD1)->D1_QTSEGUM)
	EndIf
Return Nil
/*------------------------------------------
---PedComD08
---Busca os pedidos de venda que tenham o pedido de compra
---informado caso parametro MV_PAR12 == "Sim"
---felipe.m 24/07/2015
---oModel, Objeto, (Modelo de dados)
---nOperacao, Numerico, (Operação)
---cCodDis, Caracter, (Código da distribuição)
------------------------------------------*/
Static Function PedComD08(oModel, nOperacao, cCodDis)
Local aAreaAnt   := GetArea()
Local aPedComD07 := {}
Local aD08Qtds   := {}
Local oModelD07  := oModel:GetModel('D07GRID')
Local oModelD08  := oModel:GetModel('D08GRID')
Local cQuery     := ""
Local cAliasQRY  := ""
Local nI         := 0
Local lInsert    := (nOperacao == MODEL_OPERATION_INSERT)
Local lModelUpd  := (oModel:GetOperation() == MODEL_OPERATION_UPDATE)
Local lDelete    := (nOperacao == MODEL_OPERATION_DELETE)

	For nI := 1 To oModelD07:Length()
		oModelD07:GoLine(nI)
		If !oModelD07:IsDeleted()

			If Empty(oModelD07:GetValue("D07_PEDIDO"))
				Loop
			EndIf

			If aScan(aPedComD07, { |x| x[1]+x[2] == oModelD07:GetValue("D07_PEDIDO")+oModelD07:GetValue("D07_ITEMPC") }) == 0
				aAdd(aPedComD07,{ oModelD07:GetValue("D07_PEDIDO"),oModelD07:GetValue("D07_ITEMPC") })
			EndIf
		EndIf
	Next nI
	// Verifica se há pedido de venda para o pedido de compra
	cQuery := " SELECT SC9A.C9_FILIAL,"
	cQuery +=        " SC9A.C9_PEDIDO,"
	cQuery +=        " SC9A.C9_ITEM,"
	cQuery +=        " SC9A.C9_CLIENTE,"
	cQuery +=        " SC9A.C9_LOJA,"
	cQuery +=        " SC9A.C9_PRODUTO,"
	cQuery +=        " SC9A.C9_QTDLIB,"
	cQuery +=        " SC9A.C9_SEQUEN,"
	cQuery +=        " SC9A.C9_QTDLIB2,"
	cQuery +=        " SC9A.C9_SERVIC,"
	cQuery +=        " SC9A.C9_LOCAL,"
	cQuery +=        " SC9A.C9_LOTECTL,"
	cQuery +=        " SC9A.C9_NUMLOTE,"
	cQuery +=        " SC9A.C9_DATENT"
	cQuery +=   " FROM (SELECT SC9B.C9_FILIAL,"
	cQuery +=                " SC9B.C9_PEDIDO,"
	cQuery +=                " SC9B.C9_ITEM,"
	cQuery +=                " SC9B.C9_CLIENTE,"
	cQuery +=                " SC9B.C9_LOJA,"
	cQuery +=                " SC9B.C9_PRODUTO,"
	cQuery +=                " SC9B.C9_QTDLIB,"
	cQuery +=                " SC9B.C9_SEQUEN,"
	cQuery +=                " SC9B.C9_QTDLIB2,"
	cQuery +=                " SC9B.C9_SERVIC,"
	cQuery +=                " SC9B.C9_LOCAL,"
	cQuery +=                " SC9B.C9_LOTECTL,"
	cQuery +=                " SC9B.C9_NUMLOTE,"
	cQuery +=                " SC9B.C9_NFISCAL,"
	cQuery +=                " SC9B.C9_DATALIB,"
	cQuery +=                " SC9B.C9_DATENT,"
	cQuery +=                " SC9B.C9_BLEST,"
	cQuery +=                " SC9B.C9_BLCRED"
	cQuery +=           " FROM "+RetSqlName("SC9")+" SC9B"
	cQuery +=          " WHERE SC9B.C9_FILIAL = '"+xFilial("SC9")+"'"
	cQuery +=            " AND SC9B.D_E_L_E_T_ = ' ' ) SC9A"
	cQuery +=  " INNER JOIN ( SELECT SC6B.C6_FILIAL,"
	cQuery +=                      " SC6B.C6_NUM,"
	cQuery +=                      " SC6B.C6_ITEM,"
	cQuery +=                      " SC6B.C6_PRODUTO,"
	cQuery +=                      " SC6B.C6_PEDCOM,"
	cQuery +=                      " SC6B.C6_ITPC"
	cQuery +=                 " FROM "+RetSqlName("SC6")+" SC6B"
	cQuery +=                " WHERE SC6B.C6_FILIAL  = '"+xFilial("SC6")+"'"
	cQuery +=                  " AND SC6B.D_E_L_E_T_ = ' ' ) SC6A"
	cQuery +=     " ON SC6A.C6_NUM = SC9A.C9_PEDIDO"
	cQuery +=    " AND SC6A.C6_ITEM = SC9A.C9_ITEM"
	cQuery +=    " AND SC6A.C6_PRODUTO = SC9A.C9_PRODUTO"
	cQuery +=    " AND SC6A.C6_PEDCOM || SC6A.C6_ITPC IN ("
	If Len(aPedComD07) == 0
		cQuery += "''"
	Else
		For nI := 1 To Len(aPedComD07)
			If nI != 1
				cQuery += ","
			EndIf
			cQuery += "'"+aPedComD07[nI][1]+aPedComD07[nI][2]+"'"
		Next nI
	EndIf
	cQuery += ")"
	cQuery +=  " WHERE SC9A.C9_NFISCAL = ' '"
	cQuery +=    " AND SC9A.C9_BLEST = '02'"
	cQuery +=    " AND SC9A.C9_BLCRED = '"+Space(TamSx3("C9_BLCRED")[1])+"'"
	//----------------------------------------
	// Desconsidera os pedidos que já estão no model
	//----------------------------------------
	cQuery +=    " AND SC9A.C9_PEDIDO || SC9A.C9_ITEM || SC9A.C9_SEQUEN || SC9A.C9_PRODUTO NOT IN ( "
	For nI := 1 To oModelD08:Length(.F.)
		oModelD08:GoLine(nI)
		If !oModelD08:IsDeleted()
			cQuery += "'"
			If !Empty(oModelD08:GetValue('D08_PEDIDO',nI))
				cQuery += oModelD08:GetValue('D08_PEDIDO',nI)+oModelD08:GetValue('D08_ITEM',nI)+oModelD08:GetValue('D08_SEQUEN',nI)+oModelD08:GetValue('D08_PRODUT',nI)
			EndIf
			cQuery += "',"
		EndIf
	Next nI
	cQuery += "'' )"
	cQuery +=    " AND SC9A.C9_SERVIC IN (SELECT DC5.DC5_SERVIC"
	cQuery +=                             " FROM "+RETSQLNAME("DC5")+" DC5"
	cQuery +=                            " WHERE DC5.DC5_FILIAL = '"+xFilial("DC5")+"'"
	cQuery +=                              " AND DC5.DC5_OPERAC = '4'"
	cQuery +=                              " AND DC5.D_E_L_E_T_ = ' ')"

	If lWMS325C9
		cQuery += ExecBlock("WMS325C9QR")
	EndIf
	//----------------------------------------
	// Desconsiderar os pedidos que já estão em alguma distribuição
	//----------------------------------------
	cQuery +=    " AND NOT EXISTS ("
	cQuery +=            " SELECT 1 FROM "+RETSQLNAME("D08")+" D08"
	cQuery +=             " INNER JOIN "+RETSQLNAME('D06')+" D06"
	cQuery +=                " ON D06.D06_CODDIS = D08.D08_CODDIS"
	cQuery +=             " WHERE D08.D_E_L_E_T_ = ' '"
	cQuery +=               " AND D06.D06_SITDIS IN ('1','2')"
	cQuery +=               " AND D06.D_E_L_E_T_ = ' '"
	cQuery +=               " AND D08.D08_FILIAL = '"+xFilial("D08")+"'"
	cQuery +=               " AND D08.D08_LOCAL = SC9A.C9_LOCAL"
	cQuery +=               " AND D08.D08_PEDIDO = SC9A.C9_PEDIDO"
	cQuery +=               " AND D08.D08_ITEM = SC9A.C9_ITEM"
	cQuery +=               " AND D08.D08_SEQUEN = SC9A.C9_SEQUEN"
	cQuery +=               " AND D08.D08_PRODUT = SC9A.C9_PRODUTO"
	//----------------------------------------
	// Considerar os pedidos que não foram totalmente distribuídos,
	// em montagens de status "2=Distribuída"
	//----------------------------------------
	cQuery +=               " AND ( (D08.D08_QTDDIS = SC9A.C9_QTDLIB AND D06.D06_SITDIS = '2') OR D06.D06_SITDIS = '1' )"
	//----------------------------------------
	// Desconsidera os pedidos que já estão em alguma distribuição
	// EXCETO aqueles que ele acabou de excluir no modelo de dados D08
	//----------------------------------------
	If lModelUpd
		cQuery +=           " AND D08.D08_PEDIDO || D08.D08_ITEM || D08.D08_SEQUEN || D08.D08_PRODUT NOT IN ( "

		For nI := 1 To oModelD08:Length(.F.)

			oModelD08:GoLine(nI)
			If oModelD08:IsDeleted()

				cQuery += "'"
				If !Empty(oModelD08:GetValue('D08_PEDIDO',nI))
					cQuery += oModelD08:GetValue('D08_PEDIDO',nI)+oModelD08:GetValue('D08_ITEM',nI)+oModelD08:GetValue('D08_SEQUEN',nI)+oModelD08:GetValue('D08_PRODUT',nI)
				EndIf
				cQuery += "',"

			EndIf

		Next nI
		cQuery += "'' )"
	EndIf
	cQuery += ") ORDER BY SC6A.C6_PEDCOM, SC6A.C6_ITPC"

	cQuery := ChangeQuery(cQuery)
	cAliasQRY := GetNextAlias()
	DBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQRY,.F.,.T.)
	TcSetField(cAliasQRY,'C9_DATENT','D')

	oModelD08:SetNoInsertLine(.F.)
	oModelD08:SetNoDeleteLine(.F.)

	nI := oModelD08:Length()

	(cAliasQRY)->(dbGoTop())
	If lInsert .Or. ( lDelete .And. !lModelUpd )
		While !(cAliasQRY)->(Eof())

			If !Empty( oModelD08:GetValue('D08_PEDIDO',1) )
				oModelD08:AddLine()
				oModelD08:GoLine(++nI)
			EndIf

			oModelD08:SetValue('D08_FILIAL', xFilial('D08') )
			oModelD08:SetValue('D08_CODDIS', cCodDis )
			oModelD08:SetValue('D08_PEDIDO', (cAliasQRY)->C9_PEDIDO )
			oModelD08:SetValue('D08_CLIENT', (cAliasQRY)->C9_CLIENTE )
			oModelD08:SetValue('D08_LOCAL',  (cAliasQRY)->C9_LOCAL )
			oModelD08:SetValue('D08_LOJA',   (cAliasQRY)->C9_LOJA )
			oModelD08:SetValue('D08_ITEM',   (cAliasQRY)->C9_ITEM )
			oModelD08:SetValue('D08_PRODUT', (cAliasQRY)->C9_PRODUTO )
			oModelD08:SetValue('D08_DPROD',  Posicione("SB1",1,xFilial("SB1")+(cAliasQRY)->C9_PRODUTO,"B1_DESC"))
			oModelD08:SetValue('D08_LOTECT', (cAliasQRY)->C9_LOTECTL )
			oModelD08:SetValue('D08_NUMLOT', (cAliasQRY)->C9_NUMLOTE )
			oModelD08:SetValue('D08_SEQUEN', (cAliasQRY)->C9_SEQUEN )
			oModelD08:SetValue('D08_DATENT', (cAliasQRY)->C9_DATENT )
			oModelD08:SetValue('D08_QTDVEN', (cAliasQRY)->C9_QTDLIB - QtdDistrib( (cAliasQRY)->C9_PEDIDO,(cAliasQRY)->C9_ITEM,(cAliasQRY)->C9_SEQUEN,(cAliasQRY)->C9_PRODUTO,cCodDis )) //Desconta a quantidade já distribuída em outra montagem de status "2=Distribuída"
			oModelD08:SetValue('D08_QTDVE2', (cAliasQRY)->C9_QTDLIB2 )
			oModelD08:SetValue("D08_ENDER",  Posicione('D10',1,xFilial('D10')+(cAliasQRY)->(C9_CLIENTE+C9_LOJA+C9_LOCAL),'D10_ENDER'))
			oModelD08:SetValue('D08_QTDDIS', 0 )
			oModelD08:SetValue('D08_QTDDI2', 0 )
			oModelD08:SetValue('D08_ORIGEM', 'SC9')

			(cAliasQRY)->(dbSkip())
		EndDo
	Else
		For nI := 1 To oModelD08:Length()
			oModelD08:GoLine(nI)
			If !oModelD08:IsDeleted()
				// D08_FILIAL+D08_CODDIS+D08_PEDIDO+D08_ITEM+D08_SEQUEN+D08_PRODUT
				If !( (cAliasQRY)->( dbSeek( oModelD08:GetValue('D08_PEDIDO',nI)+oModelD08:GetValue('D08_ITEM',nI)+oModelD08:GetValue('D08_SEQUEN',nI)+oModelD08:GetValue('D08_PRODUT',nI) ) );
					.And. (cAliasQRY)->( C9_LOTECTL+C9_NUMLOTE) == oModelD08:GetValue('D08_LOTECT',nI)+oModelD08:GetValue('D08_NUMLOT',nI) )
					oModelD08:DeleteLine()
				EndIf
			EndIf
		Next nI
	EndIf
	(cAliasQRY)->(dbCloseArea())

	// Verifica e há plano de distribuição para o pedido de compra
	cQuery := " SELECT D0M.D0M_FILIAL,"
	cQuery +=        " D0M.D0M_CODPLN,"
	cQuery +=        " D0M.D0M_ITEM,"
	cQuery +=        " D0M.D0M_CLIENT,"
	cQuery +=        " D0M.D0M_LOJA,"
	cQuery +=        " D0M.D0M_PRODUT,"
	cQuery +=        " (D0M.D0M_QTDDEM - D0M.D0M_QTDDIS) D0M_QTDDEM,"
	cQuery +=        " (D0M.D0M_QTDDE2 - D0M.D0M_QTDDI2) D0M_QTDDE2,"
	cQuery +=        " D0M.D0M_LOCAL,"
	cQuery +=        " D0M.D0M_LOTECT,"
	cQuery +=        " D0M.D0M_NUMLOT,"
	cQuery +=        " D0M.D0M_DATENT"
	cQuery +=   " FROM "+RetSqlName("D0M")+" D0M"
	cQuery +=  " WHERE D0M.D0M_FILIAL = '"+xFilial("D0M")+"'"
	cQuery +=    " AND D0M.D0M_PEDCOM || D0M.D0M_ITPC IN ("
	If Len(aPedComD07) == 0
		cQuery += "''"
	Else
		For nI := 1 To Len(aPedComD07)
			If nI != 1
				cQuery += ","
			EndIf
			cQuery += "'"+aPedComD07[nI][1]+aPedComD07[nI][2]+"'"
		Next nI
	EndIf
	cQuery +=  ")"
	//----------------------------------------
	// Desconsidera os pedidos que já estão no model
	//----------------------------------------
	cQuery +=    " AND D0M.D0M_CODPLN || D0M.D0M_ITEM || '01' || D0M.D0M_PRODUT NOT IN ( "
	For nI := 1 To oModelD08:Length(.F.)
		oModelD08:GoLine(nI)
		If !oModelD08:IsDeleted()
			cQuery += "'"
			If !Empty(oModelD08:GetValue('D08_PEDIDO',nI))
				cQuery += oModelD08:GetValue('D08_PEDIDO',nI)+oModelD08:GetValue('D08_ITEM',nI)+oModelD08:GetValue('D08_SEQUEN',nI)+oModelD08:GetValue('D08_PRODUT',nI)
			EndIf
			cQuery += "',"
		EndIf
	Next nI
	cQuery += "'' )"
	//----------------------------------------
	// Desconsiderar os pedidos que já estão em alguma distribuição
	//----------------------------------------
	cQuery +=    " AND NOT EXISTS ("
	cQuery +=            " SELECT 1 FROM "+RetSqlName("D08")+" D08"
	cQuery +=             " INNER JOIN "+RetSqlName('D06')+" D06"
	cQuery +=                " ON D06.D06_CODDIS = D08.D08_CODDIS"
	cQuery +=             " WHERE D08.D_E_L_E_T_ = ' '"
	cQuery +=               " AND D06.D06_SITDIS IN ('1','2')"
	cQuery +=               " AND D06.D_E_L_E_T_ = ' '"
	cQuery +=               " AND D08.D08_FILIAL = '"+xFilial("D08")+"'"
	cQuery +=               " AND D08.D08_LOCAL = D0M.D0M_LOCAL"
	cQuery +=               " AND D08.D08_PEDIDO = D0M.D0M_CODPLN"
	cQuery +=               " AND D08.D08_ITEM = D0M.D0M_ITEM"
	cQuery +=               " AND D08.D08_SEQUEN = '01'"
	cQuery +=               " AND D08.D08_PRODUT = D0M.D0M_PRODUT"
	//----------------------------------------
	// Considerar os pedidos que não foram totalmente distribuídos,
	// em montagens de status "2=Distribuída"
	//----------------------------------------
	cQuery +=               " AND ( (D08.D08_QTDDIS = D0M.D0M_QTDDEM AND D06.D06_SITDIS = '2') OR D06.D06_SITDIS = '1' )"
	//----------------------------------------
	// Desconsidera os pedidos que já estão em alguma distribuição
	// EXCETO aqueles que ele acabou de excluir no modelo de dados D08
	//----------------------------------------
	If lModelUpd
		cQuery +=           " AND D08.D08_PEDIDO || D08.D08_ITEM ||  D08.D08_SEQUEN || D08.D08_PRODUT NOT IN ( "

		For nI := 1 To oModelD08:Length(.F.)

			oModelD08:GoLine(nI)
			If oModelD08:IsDeleted()

				cQuery += "'"
				If !Empty(oModelD08:GetValue('D08_PEDIDO',nI))
					cQuery += oModelD08:GetValue('D08_PEDIDO',nI)+oModelD08:GetValue('D08_ITEM',nI)+oModelD08:GetValue('D08_SEQUEN',nI)+oModelD08:GetValue('D08_PRODUT',nI)
				EndIf
				cQuery += "',"

			EndIf

		Next nI
		cQuery += "'' )"
	EndIf
	cQuery += ") ORDER BY D0M.D0M_PEDCOM, D0M.D0M_ITPC"

	cQuery := ChangeQuery(cQuery)
	cAliasQRY := GetNextAlias()
	DBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQRY,.F.,.T.)
	TcSetField(cAliasQRY,'D0M_DATENT','D')

	oModelD08:SetNoInsertLine(.F.)
	oModelD08:SetNoDeleteLine(.F.)

	nI := oModelD08:Length()

	(cAliasQRY)->(dbGoTop())
	If lInsert .Or. ( lDelete .And. !lModelUpd )
		While !(cAliasQRY)->(Eof())

			If !Empty( oModelD08:GetValue('D08_PEDIDO',1) )
				oModelD08:AddLine()
				oModelD08:GoLine(++nI)
			EndIf

			oModelD08:SetValue('D08_FILIAL', xFilial('D08') )
			oModelD08:SetValue('D08_CODDIS', cCodDis )
			oModelD08:SetValue('D08_PEDIDO', (cAliasQRY)->D0M_CODPLN)
			oModelD08:SetValue('D08_CLIENT', (cAliasQRY)->D0M_CLIENT)
			oModelD08:SetValue('D08_LOCAL',  (cAliasQRY)->D0M_LOCAL)
			oModelD08:SetValue('D08_LOJA',   (cAliasQRY)->D0M_LOJA)
			oModelD08:SetValue('D08_ITEM',   (cAliasQRY)->D0M_ITEM)
			oModelD08:SetValue('D08_PRODUT', (cAliasQRY)->D0M_PRODUT)
			oModelD08:SetValue('D08_DPROD',  Posicione("SB1",1,xFilial("SB1")+(cAliasQRY)->D0M_PRODUT,"B1_DESC"))
			oModelD08:SetValue('D08_LOTECT', (cAliasQRY)->D0M_LOTECT)
			oModelD08:SetValue('D08_NUMLOT', (cAliasQRY)->D0M_NUMLOT)
			oModelD08:SetValue('D08_SEQUEN', '01')
			oModelD08:SetValue('D08_DATENT', (cAliasQRY)->D0M_DATENT)
			oModelD08:SetValue('D08_QTDVEN', (cAliasQRY)->D0M_QTDDEM)
			oModelD08:SetValue('D08_QTDVE2', (cAliasQRY)->D0M_QTDDE2)
			oModelD08:SetValue("D08_ENDER",  Posicione('D10',1,xFilial('D10')+(cAliasQRY)->(D0M_CLIENT+D0M_LOJA+D0M_LOCAL),'D10_ENDER'))
			oModelD08:SetValue('D08_QTDDIS', 0 )
			oModelD08:SetValue('D08_QTDDI2', 0 )
			oModelD08:SetValue('D08_ORIGEM', 'D0M')

			(cAliasQRY)->(dbSkip())
		EndDo
	Else
		For nI := 1 To oModelD08:Length()
			oModelD08:GoLine(nI)
			If !oModelD08:IsDeleted()
				// D08_FILIAL+D08_CODDIS+D08_PEDIDO+D08_ITEM+D08_SEQUEN+D08_PRODUT
				If !( (cAliasQRY)->( dbSeek( oModelD08:GetValue('D08_PEDIDO',nI)+oModelD08:GetValue('D08_ITEM',nI)+oModelD08:GetValue('D08_SEQUEN',nI)+oModelD08:GetValue('D08_PRODUT',nI) ) );
					.And. (cAliasQRY)->(D0M_LOTECT+D0M_NUMLOT) == oModelD08:GetValue('D08_LOTECT',nI)+oModelD08:GetValue('D08_NUMLOT',nI) )
					oModelD08:DeleteLine()
				EndIf
			EndIf
		Next nI
	EndIf
	(cAliasQRY)->(dbCloseArea())

	WMS325RD09(oModel)

	oModelD08:SetNoDeleteLine(.T.)
	oModelD08:SetNoInsertLine(.T.)

	RestArea(aAreaAnt)
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} MontaD08
Atribui/Exclui à Grid D08 os Itens dos Pedidos de Venda selecionados
@author felipe.m
@since 19/09/2014
@version 1.0
@param cMarca, character, Marca utilizada pelo MarkBrowse
@param oModel, objeto, Modelo de dados da aplicação
@param nOperacao, numérico, Operação de manipulação dos dados
/*/
//-------------------------------------------------------------------
Static Function MontaD08( cMarca, oModel, nOperacao, oDlgPed, cOrigem)
Local aAreaAnt  := GetArea()
Local aD08Qtds  := {}
Local aD08      := {}
Local oModelD08 := oModel:GetModel('D08GRID')
Local cCodDis   := oModel:GetModel('D06FIELDS'):GetValue('D06_CODDIS')
Local cPedido   := ""
Local cItem     := ""
Local cSequen   := ""
Local cProduto  := ""
Local nQtdDis   := 0
Local nQtdDi2   := 0
Local nI        := 1
Local lModelUpd := oModel:GetOperation() == MODEL_OPERATION_UPDATE
Local lInsert   := nOperacao == MODEL_OPERATION_INSERT
Local lDelete   := nOperacao == MODEL_OPERATION_DELETE
Local lRet      := .F.

	(cAliasD08)->(dbGoTop())
	While !lRet .And. (cAliasD08)->(!Eof())
		If (cAliasD08)->D08_OK == cMarca
			lRet := .T.
		EndIf
		(cAliasD08)->(dbSkip())
	EndDo
	If lRet
		If lDelete .And. !lModelUpd
			// Verifica pedidos de vendas selecionados
			(cAliasD08)->(dbGoTop())
			While !(cAliasD08)->(Eof())
				If lInsert .And. (cAliasD08)->D08_OK != cMarca
					(cAliasD08)->(dbSkip())
					Loop
				ElseIf lDelete .And. (cAliasD08)->D08_OK == cMarca
					(cAliasD08)->(dbSkip())
					Loop
				EndIf
				If oModelD08:SeekLine( { {"D08_PEDIDO",(cAliasD08)->D08_PEDIDO},{"D08_ITEM",(cAliasD08)->D08_ITEM},{"D08_SEQUEN",(cAliasD08)->D08_SEQUEN},{"D08_PRODUT",(cAliasD08)->D08_PRODUT}})
					If !oModelD08:IsDeleted()
						aAdd(aD08Qtds, {oModelD08:GetValue('D08_PEDIDO'),;
										oModelD08:GetValue('D08_ITEM'),;
										oModelD08:GetValue('D08_SEQUEN'),;
										oModelD08:GetValue('D08_PRODUT'),;
										oModelD08:GetValue('D08_QTDDIS'),;
										oModelD08:GetValue('D08_QTDDI2')})
					EndIf
				EndIf
				(cAliasD08)->(dbSkip())
			EndDo
			// Apaga os registros da origem selecionada
			For nI := 1 To oModelD08:Length()
				oModelD08:GoLine(nI)
				If !oModelD08:IsDeleted() .And. !Empty(oModelD08:GetValue('D08_LOCAL',nI))
					If oModelD08:GetValue('D08_ORIGEM',nI) <> cOrigem
						aAdd(aD08,{oModelD08:GetValue('D08_FILIAL', nI),;
									oModelD08:GetValue('D08_CODDIS', nI),;
									oModelD08:GetValue('D08_PEDIDO', nI),;
									oModelD08:GetValue('D08_CLIENT', nI),;
									oModelD08:GetValue('D08_LOCAL' , nI),;
									oModelD08:GetValue('D08_LOJA'  , nI),;
									oModelD08:GetValue('D08_ITEM'  , nI),;
									oModelD08:GetValue('D08_PRODUT', nI),;
									oModelD08:GetValue('D08_DPROD' , nI),;
									oModelD08:GetValue('D08_LOTECT', nI),;
									oModelD08:GetValue('D08_NUMLOT', nI),;
									oModelD08:GetValue('D08_QTDVEN', nI),;
									oModelD08:GetValue('D08_SEQUEN', nI),;
									oModelD08:GetValue('D08_QTDVE2', nI),;
									oModelD08:GetValue('D08_QTDDIS', nI),;
									oModelD08:GetValue('D08_QTDDI2', nI),;
									oModelD08:GetValue('D08_ENDER' , nI),;
									oModelD08:GetValue('D08_DATENT', nI),;
									oModelD08:GetValue('D08_ORIGEM', nI)})
					EndIf
				EndIf
			Next nI

			oModelD08:ClearData()
			oModelD08:InitLine()
			oModelD08:GoLine(1)
		EndIf
		oModelD08:SetNoInsertLine(.F.)
		oModelD08:SetNoDeleteLine(.F.)

		If cOrigem == 'D0M'
			Recarga(oModelD08,aD08)
		EndIf

		nI := oModelD08:Length()

		(cAliasD08)->(dbGoTop())
		If lInsert .Or. ( lDelete .And. !lModelUpd )
			While !(cAliasD08)->(Eof())
				If lInsert .And. (cAliasD08)->D08_OK != cMarca
					(cAliasD08)->(dbSkip())
					Loop
				ElseIf lDelete .And. (cAliasD08)->D08_OK == cMarca
					(cAliasD08)->(dbSkip())
					Loop
				EndIf
				If !Empty( oModelD08:GetValue('D08_PEDIDO',1) )
					oModelD08:AddLine()
					oModelD08:GoLine(++nI)
				EndIf

				oModelD08:SetValue('D08_FILIAL', xFilial('D08') )
				oModelD08:SetValue('D08_CODDIS', cCodDis )
				oModelD08:SetValue('D08_PEDIDO', (cAliasD08)->D08_PEDIDO)
				oModelD08:SetValue('D08_CLIENT', (cAliasD08)->D08_CLIENT)
				oModelD08:SetValue('D08_LOCAL',  (cAliasD08)->D08_LOCAL)
				oModelD08:SetValue('D08_LOJA',   (cAliasD08)->D08_LOJA)
				oModelD08:SetValue('D08_ITEM',   (cAliasD08)->D08_ITEM)
				oModelD08:SetValue('D08_PRODUT', (cAliasD08)->D08_PRODUT)
				oModelD08:SetValue('D08_DPROD',  Posicione("SB1",1,xFilial("SB1")+(cAliasD08)->D08_PRODUT,"B1_DESC"))
				oModelD08:SetValue('D08_LOTECT', (cAliasD08)->D08_LOTECT)
				oModelD08:SetValue('D08_NUMLOT', (cAliasD08)->D08_NUMLOT)
				oModelD08:SetValue('D08_SEQUEN', (cAliasD08)->D08_SEQUEN)
				oModelD08:SetValue('D08_DATENT', (cAliasD08)->D08_DATENT)
				oModelD08:SetValue('D08_QTDVEN', (cAliasD08)->D08_QTDVEN - Iif(!lDelete,QtdDistrib( (cAliasD08)->D08_PEDIDO,(cAliasD08)->D08_ITEM,(cAliasD08)->D08_SEQUEN,(cAliasD08)->D08_PRODUT,cCodDis),0)) //Desconta a quantidade já distribuída em outra montagem de status "2=Distribuída"
				oModelD08:SetValue('D08_QTDVE2', (cAliasD08)->D08_QTDVE2)
				oModelD08:SetValue("D08_ENDER",  Posicione('D10',1,xFilial('D10')+(cAliasD08)->(D08_CLIENT+D08_LOJA+D08_LOCAL),'D10_ENDER'))
				oModelD08:SetValue('D08_QTDDIS', 0 )
				oModelD08:SetValue('D08_QTDDI2', 0 )
				oModelD08:SetValue('D08_ORIGEM',cOrigem)
				(cAliasD08)->(dbSkip())
			EndDo
			// Atualiza quantidade já distribuida
			If lDelete .And. !lModelUpd
				For nI := 1 to Len(aD08Qtds)
					cPedido  := aD08Qtds[nI][1]
					cItem    := aD08Qtds[nI][2]
					cSequen  := aD08Qtds[nI][3]
					cProduto := aD08Qtds[nI][4]
					nQtdDis  := aD08Qtds[nI][5]
					nQtdDi2  := aD08Qtds[nI][6]
					If oModelD08:SeekLine( { {"D08_PEDIDO",cPedido},{"D08_ITEM",cItem},{"D08_SEQUEN",cSequen},{"D08_PRODUT",cProduto} } )
						oModelD08:LoadValue('D08_QTDDIS', nQtdDis )
						oModelD08:LoadValue('D08_QTDDI2', nQtdDi2 )
					EndIf
				Next nI
			EndIf
			If cOrigem == 'SC9'
				Recarga(oModelD08,aD08)
			EndIf
		Else
			For nI := 1 To oModelD08:Length()
				oModelD08:GoLine(nI)
				If !oModelD08:IsDeleted()
					// D08_FILIAL+D08_CODDIS+D08_PEDIDO+D08_ITEM+D08_SEQUEN+D08_PRODUT
					If ( (cAliasD08)->( dbSeek( oModelD08:GetValue('D08_PEDIDO',nI)+oModelD08:GetValue('D08_ITEM',nI)+oModelD08:GetValue('D08_SEQUEN',nI)+oModelD08:GetValue('D08_PRODUT',nI))) .And. (cAliasD08)->D08_OK == cMarca )
						oModelD08:DeleteLine()
					EndIf
				EndIf
			Next nI
		EndIf

		WMS325RD09(oModel)

		oModelD08:SetNoDeleteLine(.T.)
		oModelD08:SetNoInsertLine(.T.)

		RestArea(aAreaAnt)
	EndIf
	// Comportamento Tela
	If !lRet
		WmsMessage(STR0046) //Não há registros marcados!
	Else
		oDlgPed:End()
	EndIf
Return Nil
//-------------------------------------------------------------------
/*/{Protheus.doc} UpdSldD09
Atualização dos saldos distribuidos na D09
@author felipe.m
@since 19/09/2014
@version 1.0
@param nValAnt, numérico, Valor anterior
@param oModel, objeto, Modelo de dados da aplicação
/*/
//-------------------------------------------------------------------
Static Function UpdSldD09(nValAnt,oModel)
Local oModelD08 := oModel:GetModel('D08GRID')
Local oModelD09 := oModel:GetModel('D09GRID')
Local oView := FWViewActive()
Local lRet := .T.

	If oModelD08:GetValue('D08_QTDVEN') < oModelD08:GetValue('D08_QTDDIS')
		oModel:GetModel():SetErrorMessage( , ,  , '', WMSA325A06, STR0022+" (D08).", "", '', '') // Quantidade informada ultrapassa a quantidade a distribuir (D08).
		lRet := .F.
	Else
		oModelD09:SeekLine( { {"D09_LOCAL",oModelD08:GetValue('D08_LOCAL')},{"D09_PRODUT",oModelD08:GetValue('D08_PRODUT') } } )

		If nValAnt < oModelD08:GetValue('D08_QTDDIS')
			oModelD09:SetValue( 'D09_QTDDIS', oModelD09:GetValue('D09_QTDDIS') + (oModelD08:GetValue('D08_QTDDIS') - nValAnt) )
			nValAnt := (oModelD08:GetValue('D08_QTDDIS') - nValAnt)
		ElseIf nValAnt > oModelD08:GetValue('D08_QTDDIS')
			oModelD09:SetValue( 'D09_QTDDIS', oModelD09:GetValue('D09_QTDDIS') - (nValAnt - oModelD08:GetValue('D08_QTDDIS')) )
		EndIf

		If oModelD09:GetValue( 'D09_QTDDIS') > oModelD09:GetValue('D09_QTDADI' )
			oModelD09:SetValue( 'D09_QTDDIS', oModelD09:GetValue('D09_QTDDIS') - nValAnt )
			oModel:GetModel():SetErrorMessage( , ,  , '', WMSA325A07, STR0022+" (D09)", "", '', '') // Quantidade informada ultrapassa a quantidade a distribuir (D09).
			lRet := .F.
		EndIf
	EndIf

	oModelD09:SetValue('D09_QTDPEN', oModelD09:GetValue('D09_QTDADI') - oModelD09:GetValue('D09_QTDDIS') )

	oModelD09:GoLine(1)
	If oView != Nil .And. FwIsInCallStack("WMSA325A")
		oView:Refresh(/*'D09GRID'*/)
	EndIf
Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} WMS325RD09
Recalculo das quantidades distribuídas e a distribuir do grid D09
@author felipe.m
@since 19/09/2014
@version 1.0
@param oModel, objeto, Modelo de dados da aplicação
/*/
//-------------------------------------------------------------------
Function WMS325RD09(oModel)
Local nI := 1
Local nJ := 1
Local nQtdAdi := 0
Local nQtdDis := 0
Local nQtdPed := 0
Local oModelD09 := oModel:GetModel('D09GRID')
Local oModelD08 := oModel:GetModel('D08GRID')
Local oModelD07 := oModel:GetModel('D07GRID')
Local cMsg := ""
Local lRecalc := FwIsInCallStack("A320FINCOF") .Or. FwIsInCallStack("ReabCofRec") // Chamado da conferência de recebimento com divergencia negativa para recalcular a distribuição

	oModelD09:SetNoDeleteLine(.F.)

	For nI := 1 To oModelD09:Length()

		nQtdAdi := 0
		nQtdDis := 0
		nQtdPed := 0
		nJ := 0

		oModelD09:GoLine(nI)
		If oModelD07:SeekLine( { {"D07_LOCAL",oModelD09:GetValue('D09_LOCAL')},{"D07_PRODUT",oModelD09:GetValue('D09_PRODUT',nI)} } )
			//----------------------------------------
			// Recalculo da quantidade a distribuir, com base nos documentos de entrada
			//----------------------------------------
			For nJ := 1 To oModelD07:Length()

				oModelD07:GoLine(nJ)
				If !oModelD07:IsDeleted()
					If oModelD07:GetValue('D07_LOCAL',nJ)+oModelD07:GetValue('D07_PRODUT',nJ) == oModelD09:GetValue('D09_LOCAL',nI)+oModelD09:GetValue('D09_PRODUT',nI)
						nQtdAdi += oModelD07:GetValue('D07_QTDENT')
					EndIf
				EndIf

			Next nJ
			//----------------------------------------
			// Recalculo da quantidade distribuida, com base nos pedidos de venda
			//----------------------------------------
			For nJ := 1 To oModelD08:Length()

				oModelD08:GoLine(nJ)
				If !oModelD08:IsDeleted()
					If oModelD08:GetValue('D08_LOCAL',nJ)+oModelD08:GetValue('D08_PRODUT',nJ) == oModelD09:GetValue('D09_LOCAL',nI)+oModelD09:GetValue('D09_PRODUT',nI)
						nQtdDis += oModelD08:GetValue('D08_QTDDIS',nJ)
						nQtdPed += oModelD08:GetValue('D08_QTDVEN',nJ)
					EndIf
				EndIf

			Next nJ

			oModelD09:SetValue('D09_QTDADI', nQtdAdi )
			oModelD09:SetValue('D09_QTDDIS', nQtdDis )
			oModelD09:SetValue('D09_QTDPED', nQtdPed )
			oModelD09:SetValue('D09_QTDPEN', nQtdAdi - nQtdDis )

			If nQtdAdi < nQtdDis
				cMsg += AllTrim(oModelD09:GetValue('D09_LOCAL'))+"|"+AllTrim(oModelD09:GetValue('D09_PRODUT')) + CRLF

				For nJ := 1 To oModelD08:Length()

					oModelD08:GoLine(nJ)
					If oModelD08:GetValue('D08_LOCAL')+oModelD08:GetValue('D08_PRODUT') == oModelD09:GetValue('D09_LOCAL')+oModelD09:GetValue('D09_PRODUT')
						oModelD08:LoadValue('D08_QTDDIS',0)
					EndIf

				Next nJ

				oModelD09:SetValue('D09_QTDDIS',0)
				oModelD09:SetValue('D09_QTDPEN',0)

			EndIf

		Else
			oModelD09:DeleteLine()
		EndIf

	Next nI

	If !Empty(cMsg) .And. !lRecalc
		cMsg := STR0023 + CRLF +; // Foram excluídos documentos de entrada com produtos já distribuídos. As quantidades distribuidas serão zeradas para os produtos:
				 STR0024 + CRLF +cMsg // Local|Produto

		WmsMessage(cMsg,WMSA325A10,10,,{STR0039}) // Ok
	EndIf

	oModelD09:SetNoDeleteLine(.T.)
Return Nil
//-------------------------------------------------------------------
/*/{Protheus.doc} RecalcD08
Recalculo da Grid D08 quando excluído um documento
@author felipe.m
@since 19/09/2014
@version 1.0
@param oModel, objeto, Modelo de dados da aplicação
/*/
//-------------------------------------------------------------------
Static Function RecalcD08(oModel)
Local nI := 0
Local cCodDis := oModel:GetModel('D06FIELDS'):GetValue('D06_CODDIS')
Local oModelD08 := oModel:GetModel('D08GRID')
Local oModelD07 := oModel:GetModel('D07GRID')
Local lModelUpd := oModel:GetOperation() == MODEL_OPERATION_UPDATE
Local aD08 := {}

	oModelD08:SetNoInsertLine(.F.)
	oModelD08:SetNoDeleteLine(.F.)

	For nI := 1 To oModelD08:Length()

		oModelD08:GoLine(nI)

		If oModelD07:SeekLine( { {"D07_PRODUT",oModelD08:GetValue('D08_PRODUT',nI) } } )

			If !oModelD07:IsDeleted()
				aAdd(aD08,{ oModelD08:GetValue('D08_PEDIDO', nI),;
							oModelD08:GetValue('D08_CLIENT', nI),;
							oModelD08:GetValue('D08_LOCAL' , nI),;
							oModelD08:GetValue('D08_LOJA'  , nI),;
							oModelD08:GetValue('D08_ITEM'  , nI),;
							oModelD08:GetValue('D08_PRODUT', nI),;
							oModelD08:GetValue('D08_DPROD' , nI),;
							oModelD08:GetValue('D08_LOTECT', nI),;
							oModelD08:GetValue('D08_NUMLOT', nI),;
							oModelD08:GetValue('D08_QTDVEN', nI),;
							oModelD08:GetValue('D08_SEQUEN', nI),;
							oModelD08:GetValue('D08_QTDVE2', nI),;
							oModelD08:GetValue('D08_QTDDIS', nI),;
							oModelD08:GetValue('D08_QTDDI2', nI),;
							oModelD08:GetValue('D08_ENDER' , nI),;
							oModelD08:GetValue('D08_DATENT', nI),;
							oModelD08:GetValue('D08_ORIGEM', nI)})
			EndIf
		Else
			oModelD08:DeleteLine()
		EndIf

	Next nI

	If !lModelUpd
		oModelD08:ClearData()
		oModelD08:InitLine()
		oModelD08:GoLine(1)

		For nI := 1 To Len(aD08)

			If !Empty( oModelD08:GetValue('D08_PEDIDO',1) )
				oModelD08:AddLine()
				oModelD08:GoLine(nI)
			EndIf

			oModelD08:SetValue('D08_FILIAL' ,xFilial('D08'))
			oModelD08:SetValue('D08_CODDIS' ,cCodDis)
			oModelD08:SetValue('D08_PEDIDO' ,aD08[nI][1])
			oModelD08:SetValue('D08_CLIENT' ,aD08[nI][2])
			oModelD08:SetValue('D08_LOCAL'  ,aD08[nI][3])
			oModelD08:SetValue('D08_LOJA'   ,aD08[nI][4])
			oModelD08:SetValue('D08_ITEM'   ,aD08[nI][5])
			oModelD08:SetValue('D08_PRODUT' ,aD08[nI][6])
			oModelD08:SetValue('D08_DPROD'  ,aD08[nI][7])
			oModelD08:SetValue('D08_LOTECT' ,aD08[nI][8])
			oModelD08:SetValue('D08_NUMLOT' ,aD08[nI][9])
			oModelD08:SetValue('D08_QTDVEN' ,aD08[nI][10])
			oModelD08:SetValue('D08_SEQUEN' ,aD08[nI][11])
			oModelD08:SetValue('D08_QTDVE2' ,aD08[nI][12])
			oModelD08:LoadValue('D08_QTDDIS',aD08[nI][13])
			oModelD08:LoadValue('D08_QTDDI2',aD08[nI][14])
			oModelD08:LoadValue('D08_ENDER' ,aD08[nI][15])
			oModelD08:LoadValue('D08_DATENT',aD08[nI][16])
			oModelD08:LoadValue('D08_ORIGEM',aD08[nI][17])
		Next nI
	EndIf

	oModelD08:SetNoDeleteLine(.T.)
	oModelD08:SetNoInsertLine(.T.)
Return Nil
//-------------------------------------------------------------------
/*/{Protheus.doc} QtdDisD07
Atribui as quantidades distribuídas aos documentos de entrada
@author felipe.m
@since 19/09/2014
@version 1.0
@param oModel, objeto, Modelo de dados da aplicação
/*/
//-------------------------------------------------------------------
Static Function QtdDisD07(oModel)
Local nI := 0
Local nPosD09 := 0
Local nQtdDis := 0
Local oModelD07 := oModel:GetModel('D07GRID')
Local oModelD09 := oModel:GetModel('D09GRID')
Local aD09 := {}
Local aD07OrdLte := {}
Local aD07 := {}

	For nI := 1 To oModelD09:Length()
		oModelD09:GoLine(nI)
		If !oModelD09:IsDeleted()
			aAdd(aD09,{ oModelD09:GetValue('D09_LOCAL',nI),;
						oModelD09:GetValue('D09_PRODUT',nI),;
						oModelD09:GetValue('D09_QTDDIS',nI) })
		EndIf
	Next nI

	For nI := 1 To oModelD07:Length()
		oModelD07:GoLine(nI)
		If !oModelD07:IsDeleted()
			If !Empty(oModelD07:GetValue('D07_LOTECT',nI))
				aAdd(aD07OrdLte,{ oModelD07:GetValue('D07_DOC',nI),;
							oModelD07:GetValue('D07_SERIE',nI),;
							oModelD07:GetValue('D07_FORNEC',nI),;
							oModelD07:GetValue('D07_LOJA',nI),;
							oModelD07:GetValue('D07_LOCAL',nI),;
							oModelD07:GetValue('D07_PRODUT',nI),;
							oModelD07:GetValue('D07_LOTECT',nI),;
							oModelD07:GetValue('D07_NUMLOT',nI),;
							oModelD07:GetValue('D07_ITEM',nI),;
							oModelD07:GetValue('D07_QTDENT',nI),;
							oModelD07:GetValue('D07_QTDEN2',nI) })
			Else
				aAdd(aD07,{ oModelD07:GetValue('D07_DOC',nI),;
							oModelD07:GetValue('D07_SERIE',nI),;
							oModelD07:GetValue('D07_FORNEC',nI),;
							oModelD07:GetValue('D07_LOJA',nI),;
							oModelD07:GetValue('D07_LOCAL',nI),;
							oModelD07:GetValue('D07_PRODUT',nI),;
							oModelD07:GetValue('D07_LOTECT',nI),;
							oModelD07:GetValue('D07_NUMLOT',nI),;
							oModelD07:GetValue('D07_ITEM',nI),;
							oModelD07:GetValue('D07_QTDENT',nI),;
							oModelD07:GetValue('D07_QTDEN2',nI) })
			EndIf
		EndIf
	Next nI
	//----------------------------------------
	// Priorização de produtos com Lote/Sub-Lote
	//----------------------------------------
	For nI := 1 To Len(aD07)
		aAdd(aD07OrdLte, { aD07[nI][1],;
							aD07[nI][2],;
							aD07[nI][3],;
							aD07[nI][4],;
							aD07[nI][5],;
							aD07[nI][6],;
							aD07[nI][7],;
							aD07[nI][8],;
							aD07[nI][9],;
							aD07[nI][10],;
							aD07[nI][11] })
	Next nI

	For nI := 1 To Len(aD07OrdLte)
		nPosD09 := aScan(aD09,{ |x| x[1]+x[2] == aD07OrdLte[nI][5]+aD07OrdLte[nI][6] } )
		If nPosD09 != 0
			nQtdDis := aD09[nPosD09][3]
		Endif

		oModelD07:SeekLine( { {'D07_DOC',aD07OrdLte[nI][1]},;
								{'D07_SERIE',aD07OrdLte[nI][2]},;
								{'D07_FORNEC',aD07OrdLte[nI][3]},;
								{'D07_LOJA',aD07OrdLte[nI][4]},;
								{'D07_LOCAL',aD07OrdLte[nI][5]},;
								{'D07_PRODUT',aD07OrdLte[nI][6]},;
								{'D07_ITEM',aD07OrdLte[nI][9]},;
								{'D07_LOTECT',aD07OrdLte[nI][7]},;
								{'D07_NUMLOT',aD07OrdLte[nI][8]} } )

		If nQtdDis > 0
			If aD07OrdLte[nI][10] <= nQtdDis
				oModelD07:SetValue('D07_QTDDIS', aD07OrdLte[nI][10] )
				oModelD07:SetValue('D07_QTDDI2', aD07OrdLte[nI][11] )
			Else
				oModelD07:SetValue('D07_QTDDIS', nQtdDis )
				oModelD07:SetValue('D07_QTDDI2', ConvUm(aD07OrdLte[nI][6], nQtdDis, 0, 2) )
			EndIf

			aD09[nPosD09][3] -= oModelD07:GetValue('D07_QTDDIS')
		Else
			oModelD07:SetValue('D07_QTDDIS', 0 )
			oModelD07:SetValue('D07_QTDDI2', 0 )
		EndIf
	Next nI
Return Nil

Static Function QtdDisD0F(oModel)
Local oModelD07 := oModel:GetModel("D07GRID")
Local oModelD08 := oModel:GetModel("D08GRID")
Local oModelD0F := oModel:GetModel("D0FGRID")
Local lModelUpd := oModel:GetOperation() == MODEL_OPERATION_UPDATE
Local nI := 0
Local nY := 0
Local nQtdD07 := 0
Local nQtdD0F := 0
	//-------------------------------------
	// Limpa o modelo para criar novamente
	// quando a operação é Manutenção
	//-------------------------------------
	If lModelUpd
		For nI := 1 To oModelD0F:Length()
			oModelD0F:GoLine(nI)
			If !Empty( oModelD0F:GetValue('D0F_CODDIS',1) )
				oModelD0F:DeleteLine()
			EndIf
		Next nI
		For nY := 1 To oModelD08:Length()
			oModelD08:GoLine(nY)
			oModelD08:SetValue("D08_QTDEND",0)
		NExt nY
	EndIf

	For nI := 1 To oModelD07:Length()
		oModelD07:GoLine(nI)
		nQtdD07 := oModelD07:GetValue("D07_QTDDIS")

		//-------------------------------------
		// Desconsidera os documentos não utilizados na distribuição
		//-------------------------------------
		If nQtdD07 == 0
			Loop
		EndIf

		For nY := 1 To oModelD08:Length()
			oModelD08:GoLine(nY)

			//-------------------------------------
			// Desconsidera D08 com o produto diferente, independente do lote
			//-------------------------------------
			If oModelD07:GetValue("D07_PRODUT") != oModelD08:GetValue("D08_PRODUT")
				Loop
			EndIf
			//-------------------------------------
			// Desconsidera os pedidos já processados
			//-------------------------------------
			If oModelD08:GetValue("D08_QTDDIS") == oModelD08:GetValue("D08_QTDEND")
				Loop
			EndIf

			//-------------------------------------
			// Calcula o saldo a ser considerado
			//-------------------------------------
			nQtdD0F := oModelD08:GetValue("D08_QTDDIS") - oModelD08:GetValue("D08_QTDEND")

			If nQtdD07 < nQtdD0F
				nQtdD0F := nQtdD07
				nQtdD07 := 0
			Else
				nQtdD07 -= nQtdD0F
			EndIf

			//-------------------------------------
			// Adiciona as quantidades quando ja existe D0F
			//-------------------------------------
			If oModelD0F:SeekLine( {{"D0F_DOC"   ,oModelD07:GetValue("D07_DOC")},;
			                        {"D0F_SERIE" ,oModelD07:GetValue("D07_SERIE")},;
			                        {"D0F_FORNEC",oModelD07:GetValue("D07_FORNEC")},;
			                        {"D0F_LOJA"  ,oModelD07:GetValue("D07_LOJA")},;
			                        {"D0F_PRODUT",oModelD07:GetValue("D07_PRODUT")},;
			                        {"D0F_ITEM"  ,oModelD07:GetValue("D07_ITEM")},;
			                        {"D0F_ENDER" ,oModelD08:GetValue("D08_ENDER")}} )

				oModelD0F:LoadValue('D0F_QTDDIS', oModelD0F:GetValue('D0F_QTDDIS') + nQtdD0F)
				oModelD0F:LoadValue('D0F_QTDDI2', ConvUm(oModelD0F:GetValue("D0F_PRODUT"), oModelD0F:GetValue('D0F_QTDDIS'), 0, 2))
			Else
				If !Empty( oModelD0F:GetValue('D0F_CODDIS',1) )
					oModelD0F:AddLine()
					oModelD0F:GoLine(oModelD0F:Length())
				EndIf

				oModelD0F:LoadValue('D0F_FILIAL', xFilial('D0F'))
				oModelD0F:LoadValue('D0F_CODDIS', oModelD07:GetValue("D07_CODDIS"))
				oModelD0F:LoadValue('D0F_ENDER' , oModelD08:GetValue("D08_ENDER"))
				oModelD0F:LoadValue('D0F_QTDDIS', nQtdD0F)
				oModelD0F:LoadValue('D0F_DOC'   , oModelD07:GetValue("D07_DOC"))
				oModelD0F:LoadValue('D0F_ITEM'  , oModelD07:GetValue("D07_ITEM"))
				oModelD0F:LoadValue('D0F_LOCAL' , oModelD07:GetValue("D07_LOCAL"))
				oModelD0F:LoadValue('D0F_PRODUT', oModelD07:GetValue("D07_PRODUT"))
				oModelD0F:LoadValue('D0F_LOTECT', oModelD07:GetValue("D07_LOTECT"))
				oModelD0F:LoadValue('D0F_NUMLOT', oModelD07:GetValue("D07_NUMLOT"))
				//oModelD0F:LoadValue('D0F_SDOC'  , oModelD07:GetValue("D07_SDOC"))
				oModelD0F:LoadValue('D0F_FORNEC', oModelD07:GetValue("D07_FORNEC"))
				oModelD0F:LoadValue('D0F_LOJA'  , oModelD07:GetValue("D07_LOJA"))
				oModelD0F:LoadValue('D0F_DTEMIS', oModelD07:GetValue("D07_DTEMIS"))
				oModelD0F:LoadValue('D0F_SERIE' , oModelD07:GetValue("D07_SERIE"))
				oModelD0F:LoadValue('D0F_QTDDI2', ConvUm(oModelD07:GetValue("D07_PRODUT"), nQtdD0F, 0, 2))
			EndIf

			//-------------------------------------
			// Atualiza o saldo considerar no processo seguinte
			//-------------------------------------
			oModelD08:SetValue('D08_QTDEND', oModelD08:GetValue("D08_QTDEND") + nQtdD0F)

			If nQtdD07 == 0
				Exit
			EndIf
		NExt nY
	NExt nI

Return Nil
//-------------------------------------------------------------------
/*/{Protheus.doc} WMSA325ART
Rateio Proporcional e Direto
@author felipe.m
@since 19/09/2014
@version 1.0
@param oModel, objeto, (Modelo de dados da aplicação)
@param nTipRat, numérico, (Tipo de rateio 1=Direto, 2=Proporcional, 3=Unidade + Proporcional)
/*/
//-------------------------------------------------------------------
Function WMSA325ART(oModel,nTipRat)
Local oModelD08  := oModel:GetModel('D08GRID')
Local oModelD09  := oModel:GetModel('D09GRID')
Local lRet       := .T.
Local nI         := 0
Local nJ         := 0
Local nX         := 1
Local nY         := 0
Local nPosD09    := 0
Local nPosD08    := 0
Local nQtdDis    := 0
Local aD08       := {}
Local aD09       := {}
Local nQtdUmaPro := 0
Local lUM        := .T.
Local lArredonda := .F.
Local nResRound  := 0

	If Empty(oModelD08:GetValue('D08_PEDIDO',1))
		oModel:GetModel():SetErrorMessage( , ,  , '', WMSA325A08, STR0025, "", '', '') // Não existe pedido de venda selecionado!
		lRet := .F.
	Else
		For nI := 1 To oModelD09:Length()
			oModelD09:GoLine(nI)
			If !oModelD09:IsDeleted()
				// lUM = .T. (Considera a primeira unidade de medida = "1")
				// lUM = .F. (Considera a segunda unidade de medida = "2")
				lUM := (Posicione("SB5",1,xFilial("SB5")+oModelD09:GetValue('D09_PRODUT',nI),"B5_UMIND") = "1")
				aAdd(aD09,{ oModelD09:GetValue('D09_LOCAL',nI),; // [1]
							oModelD09:GetValue('D09_PRODUT',nI),; // [2]
							oModelD09:GetValue(Iif(lUM,'D09_QTDADI','D09_QTDAD2'),nI),; // [3]
							0,;  // Quantidade dos pedidos de venda por produto            [4]
							0 }) // Quantidade distribuida para comparação                 [5]
			EndIf
		Next nI

		For nI := 1 To oModelD08:Length()
			oModelD08:GoLine(nI)
			If !oModelD08:IsDeleted()
				// lUM = .T. (Considera a primeira unidade de medida = "1")
				// lUM = .F. (Considera a segunda unidade de medida = "2")
				lUm := (Posicione("SB5",1,xFilial("SB5")+oModelD08:GetValue('D08_PRODUT'),"B5_UMIND") = "1")
				lArredonda := (Posicione("SB5",1,xFilial("SB5")+oModelD08:GetValue('D08_PRODUT'),"B5_ARREQTD") == "1")
				aAdd(aD08,{ oModelD08:GetValue('D08_PEDIDO',nI),; // [1]
							oModelD08:GetValue('D08_ITEM',nI),;     // [2]
							oModelD08:GetValue('D08_SEQUEN',nI),;   // [3]
							oModelD08:GetValue('D08_LOCAL',nI),;    // [4]
							oModelD08:GetValue('D08_PRODUT',nI),;   // [5]
							oModelD08:GetValue('D08_LOTECT',nI),;   // [6]
							oModelD08:GetValue('D08_NUMLOT',nI),;   // [7]
							Iif(lUm,oModelD08:GetValue('D08_QTDVEN',nI),ConvUm(oModelD08:GetValue('D08_PRODUT',nI),oModelD08:GetValue('D08_QTDVEN',nI),0,2)),; //[8]
							oModelD08:GetValue('D08_DATENT',nI),; // [9]
							IIf(oModelD08:GetValue('D08_ORIGEM',nI) == 'SC9',"1","2"),; //[10]
							lUm,; // [11]
							lArredonda,; //[12]
							nI}) // [13] - Posição no ModelD08
				//----------------------------------------
				// Soma a quantidade dos pedidos de venda por produto
				//----------------------------------------
				nPosD09 := aScan( aD09,{ |x| x[1]+x[2] == oModelD08:GetValue('D08_LOCAL',nI)+oModelD08:GetValue('D08_PRODUT',nI) } )
				If nPosD09 != 0
					aD09[nPosD09][4] += Iif(lUM,oModelD08:GetValue('D08_QTDVEN',nI),ConvUm(oModelD08:GetValue('D08_PRODUT',nI),oModelD08:GetValue('D08_QTDVEN',nI),0,2))
				EndIf
				//----------------------------------------
				// Limpa as quantidades distribuidas da D08
				//----------------------------------------
				oModelD08:SetValue(Iif(lUM,'D08_QTDDIS','D08_QTDDI2'),0)
			EndIf
		Next nI
		//----------------------------------------
		// Priorização de produtos com Lote/Sub-Lote
		//----------------------------------------
		// D08_ORIGEM+D08_DATENT+D08_PEDIDO+D08_ITEM+D08_PRODUT
		ASort(aD08,,,{|x,y| x[10]+DTOS(x[9])+x[1]+x[2]+x[5] < y[10]+DTOS(y[9])+y[1]+y[2]+y[5]})
		// Rateio Direto
		If nTipRat == 1 .Or. nTipRat == 4
			For nI := 1 To Len(aD08)
				If nTipRat == 4 .And. aD08[nI][10] == '2'
					nX := nI
					Exit
				EndIf
				nPosD09 := aScan(aD09,{ |x| x[1]+x[2] == aD08[nI][4]+aD08[nI][5] } )
				If nPosD09 > 0
					nQtdDis := aD09[nPosD09][3]
				Else
					nQtdDis := 0
				EndIf
				oModelD08:GoLine(aD08[nI][13])
				// lUm = .T. (Considera a primeira unidade de medida = "1")
				// lUm = .F. (Considera a segunda unidade de medida = "2")
				lUm        := aD08[nI][11]
				lArredonda := aD08[nI][12]

				If nPosD09 > 0 .And. nQtdDis > 0
					If IIf(lArredonda,Int(aD08[nI][8]) <= Int(nQtdDis),QtdComp(aD08[nI][8]) <= QtdComp(nQtdDis))
						oModelD08:SetValue(Iif(lUM,'D08_QTDDIS','D08_QTDDI2'), IIf(lArredonda,Int(aD08[nI][8]),aD08[nI][8]) )
					Else
						oModelD08:SetValue(Iif(lUM,'D08_QTDDIS','D08_QTDDI2'), IIf(lArredonda,Int(nQtdDis),nQtdDis) )
					EndIf
					aD08[nI][8] -= oModelD08:GetValue(Iif(lUM,'D08_QTDDIS','D08_QTDDI2'))        // Diminui do total que tem para distribuir para o calculo não considerá-lo
					aD09[nPosD09][3] -= oModelD08:GetValue(Iif(lUM,'D08_QTDDIS','D08_QTDDI2'))
					aD09[nPosD09][4] -= oModelD08:GetValue(Iif(lUM,'D08_QTDDIS','D08_QTDDI2'))
				EndIf
			Next nI
		EndIf
		// Rateio Proporcional # Uma Unidade + Proporcional
		If nTipRat == 2 .Or. nTipRat == 3 .Or. nTipRat == 4
			If nTipRat == 4
				nTipRat := 2
			EndIf
			For nI := 1 To Len(aD09)
				//-----------------------------------------
				// Uma Unidade + Proporcional
				// Garante que pelo menos uma unidade seja distribuída
				//-----------------------------------------
				nQtdUmaPro := 0
				nQtdPrdD08 := 0
				nPosD08    := 0

				For nJ := 1 To Len(aD08)
					If aD09[nI][1]+aD09[nI][2] == aD08[nJ][4]+aD08[nJ][5]
						If nTipRat == 3
							If aD09[nI][3] == nQtdUmaPro
								Exit
							EndIf
							// lUM = .T. (Considera a primeira unidade de medida = "1")
							// lUM = .F. (Considera a segunda unidade de medida = "2")
							lUm := aD08[nJ][11]
							If aD08[nJ][8] >= 1
								aD08[nJ][8]-- // Diminui do total que tem para distribuir para o calculo não considerá-lo
								nQtdUmaPro++ // Soma o total distribuído para o produto nesta primeira parte
								aD09[nI][5]++ // Soma uma quantidade distribuída para o produto

								oModelD08:GoLine(aD08[nJ][13])
								oModelD08:SetValue(Iif(lUM,'D08_QTDDIS','D08_QTDDI2'), 1)
							EndIf
						EndIf
						// Calcula quantas linhas do produto existem na grid
						nQtdPrdD08++
						// Guarda a posição do primeiro produto encontrado
						If nPosD08 == 0
							nPosD08 := nJ
						EndIf
					EndIf
				Next nJ

				For nJ := nX To Len(aD08)
					If aD09[nI][1]+aD09[nI][2] == aD08[nJ][4]+aD08[nJ][5]
						nQtdPrdD08--
						If aD08[nJ][8] <= 0
							Loop
						EndIf

						oModelD08:GoLine(aD08[nJ][13])
						// lUM = .T. (Considera a primeira unidade de medida = "1")
						// lUM = .F. (Considera a segunda unidade de medida = "2")
						lUm        := aD08[nJ][11]
						lArredonda := aD08[nJ][12]

						If aD09[nI][4] <= aD09[nI][3]
							//----------------------------------------
							// Caso a quantidade dos pedidos de venda seja menor,
							// preenche a quantidade a distribuir por completo
							//----------------------------------------
							nQtdDis := IIf(lArredonda,Int(aD08[nJ][8]),aD08[nJ][8])
						Else
							If lArredonda
								nQtdDis := Round( (aD08[nJ][8] / (aD09[nI][4] - nQtdUmaPro)) * (aD09[nI][3] - nQtdUmaPro),0)
							Else
								nQtdDis := Round( (aD08[nJ][8] / (aD09[nI][4] - nQtdUmaPro)) * (aD09[nI][3] - nQtdUmaPro),2)
							EndIf
						EndIf

						// aD09[nI][3] -> Quantidade total que tem para distribuir
						// aD09[nI][5] -> Quantidade total que foi distribuída
						aD09[nI][5] += nQtdDis
						// Verifica se é <ultimo registro> ou <se há saldo a distribuir> ou <se é a ultima vez que o produto aparece na grid>
						If nJ == Len(aD08) .Or. (aD09[nI][5] > Min(aD09[nI][3],aD09[nI][4])) .Or. nQtdPrdD08 == 0
							If !lArredonda
								If aD09[nI][5] > Min(aD09[nI][3],aD09[nI][4])
									nResRound := (aD09[nI][5] - aD09[nI][3])
									If (nResRound > 0 .And. nResRound < 1)
										aD09[nI][5] -= nResRound
										nQtdDis     -= nResRound
									EndIf
								ElseIf aD09[nI][5] < Min(aD09[nI][3],aD09[nI][4])
									nResRound := (aD09[nI][3] - aD09[nI][5])
									If (nResRound > 0 .And. nResRound < 1)
										aD09[nI][5] += nResRound
										// Adiciona no primeiro produto encontrado, pois tem maior prioridade de entrega
										oModelD08:GoLine(nPosD08)
										oModelD08:SetValue(Iif(lUm,'D08_QTDDIS','D08_QTDDI2'), oModelD08:GetValue(Iif(lUm,'D08_QTDDIS','D08_QTDDI2')) + nResRound)
										// Restaura a linha atual do modelo
										oModelD08:GoLine(aD08[nJ][13])
									EndIf
								EndIf
							ElseIf nJ == Len(aD08) .And. (aD09[nI][5] < Min(aD09[nI][3],aD09[nI][4])) .Or. nQtdPrdD08 == 0
								nResRound := Min(aD09[nI][3],aD09[nI][4]) - aD09[nI][5]
								If nResRound > 1
									For nY := 1 To oModelD08:Length()
										oModelD08:GoLine(nY)

										If !(oModelD08:GetValue("D08_LOCAL")+oModelD08:GetValue("D08_PRODUT") == aD08[nJ][4]+aD08[nJ][5])
											Loop
										EndIf

										If (oModelD08:GetValue(Iif(lUM,'D08_QTDDIS','D08_QTDDI2')) + 1) <= oModelD08:GetValue(Iif(lUM,'D08_QTDVEN','D08_QTDVE2'))
											oModelD08:SetValue(Iif(lUM,'D08_QTDDIS','D08_QTDDI2'), oModelD08:GetValue(Iif(lUM,'D08_QTDDIS','D08_QTDDI2')) + 1)
											aD09[nI][5] += 1
											nResRound--
										EndIf

										If nResRound == 0
											Exit
										EndIf
									Next nY
									// Restaura a linha atual do modelo
									oModelD08:GoLine(aD08[nJ][13])
								ElseIf nResRound < 0
									// Ajusta quantidade arrendonda pendente maior que a disponível
									nQtdDis -= Abs(nResRound)
									aD09[nI][5] -= Abs(nResRound)
								EndIf
							EndIf
							//----------------------------------------
							// Casos em que o último aredondamento acaba faltando 1 quantidade do máximo.
							// Quantidade distribuída menor que quantidade maxima
							//----------------------------------------
							If aD09[nI][5] < IIf(lArredonda,Int(Min(aD09[nI][3],aD09[nI][4])),Min(aD09[nI][3],aD09[nI][4]))
								// Adiciona no primeiro produto encontrado, pois tem maior prioridade de entrega
								oModelD08:GoLine(nPosD08)
								oModelD08:SetValue(Iif(lUM,'D08_QTDDIS','D08_QTDDI2'), oModelD08:GetValue(Iif(lUM,'D08_QTDDIS','D08_QTDDI2')) + 1)
								// Restaura a linha atual do modelo
								oModelD08:GoLine(aD08[nJ][13])
							ElseIf aD09[nI][5] > IIf(lArredonda,Int(Min(aD09[nI][3],aD09[nI][4])),Min(aD09[nI][3],aD09[nI][4]))
								//----------------------------------------
								// Casos em que o último aredondamento acaba ultrapassando 1 quantidade a mais do máximo.
								//----------------------------------------
								If lArredonda
									Exit
								Else
									If ((nQtdDis + oModelD08:GetValue(Iif(lUM,'D08_QTDDIS','D08_QTDDI2'),nLinha)) - 1) > 0
										nQtdDis -= 1
									EndIf
								EndIf
							EndIf
						EndIf

						// Atualiza quantidade distribuida
						oModelD08:SetValue(Iif(lUM,'D08_QTDDIS','D08_QTDDI2'), nQtdDis + oModelD08:GetValue(Iif(lUM,'D08_QTDDIS','D08_QTDDI2')))
					EndIf
				Next nJ
			Next nI
		EndIf
	EndIf

	oModelD08:GoLine(1)
	oModelD09:GoLine(1)
Return lRet

Static Function QuebraSD1(oModel,oProcess)
Local oModelD07 := oModel:GetModel("D07GRID")
Local nI := 0

	oProcess:SetRegua1( oModelD07:Length() )
	For nI := 1 To oModelD07:Length()

		oModelD07:GoLine(nI)
		If !oModelD07:IsDeleted()
			oProcess:IncRegua1( WmsFmtMsg(STR0036,{{"[VAR01]",oModelD07:GetValue("D07_DOC")},{"[VAR02]",oModelD07:GetValue("D07_PRODUT")}}) ) // Distribuindo documento: [VAR01] Produto: [VAR02] ...
			WMS325DIST(oModelD07,oProcess)
		EndIf

	Next nI
Return
//-----------------------------------------------------
/*/	Sugestao de servico e quebra de itens para a classificao.
@author Tiago Filipe da Silva
@version P12
@since 03/09/2014
/*/
//------------------------------------------------------
Static Function WMS325DIST(oModelD07,oProcess)
Local aAreaSD1  := {}
Local aCopiaSD1 := {}
Local aAreaD07  := {}
Local lDistAuto := FwIsInCallStack("WmsAvalSF1")

	oProcess:SetRegua2( 2 )
	SD1->(dbSetOrder(1)) // D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
	SD1->(dbSeek(xFilial('SD1')+oModelD07:GetValue("D07_DOC")+oModelD07:GetValue("D07_SERIE")+oModelD07:GetValue("D07_FORNEC")+oModelD07:GetValue("D07_LOJA")+oModelD07:GetValue("D07_PRODUT")+oModelD07:GetValue("D07_ITEM")))

	// Quebra os itens, se possivel, e altera servico, endereco e estrutura fisica
	If SD1->(!Eof()) .AND. SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM) == xFilial('SD1')+oModelD07:GetValue("D07_DOC")+oModelD07:GetValue("D07_SERIE")+oModelD07:GetValue("D07_FORNEC")+oModelD07:GetValue("D07_LOJA")+oModelD07:GetValue("D07_PRODUT")+oModelD07:GetValue("D07_ITEM")

		oProcess:IncRegua2( WmsFmtMsg( STR0037,{{"[VAR01]",Str(oModelD07:GetValue("D07_QTDDIS"))},{"[VAR02]",oModelD07:GetValue("D07_PRODUT")}} ) )// Quantidade: [VAR01] Produto: [VAR02] ...

		If oModelD07:SeekLine( { {"D07_DOC", SD1->D1_DOC },{"D07_SERIE",SD1->D1_SERIE},{"D07_FORNEC", SD1->D1_FORNECE},{"D07_LOJA", SD1->D1_LOJA},{"D07_PRODUT", SD1->D1_COD},{"D07_ITEM",SD1->D1_ITEM} } )
			// Verifica se o item nao foi separado
			If SD1->D1_QUANT != oModelD07:GetValue("D07_QTDDIS") .AND. oModelD07:GetValue("D07_QTDDIS") != 0
				// Se a qtd. distribuida for menor que a qtd do item do doc
				If oModelD07:GetValue("D07_QTDDIS") < oModelD07:GetValue("D07_QTDENT") .AND. oModelD07:GetValue("D07_QTDDIS") > 0
					aAreaSD1 := SD1->(GetArea())
					aAreaD07 := D07->(GetArea())

					// Quebra o item da SD1 e recalcula impostos, despesas, etc, de acordo a quantidade de quebra
					WmsSplitD1("WMSA325",oModelD07:GetValue("D07_QTORIE"),(oModelD07:GetValue("D07_QTORIE")-oModelD07:GetValue("D07_QTDDIS")),.T.,.F.,,,,,oModelD07:GetValue("D07_CODDIS"))

					// Posiciona no registro do modelo de dados
					D07->(dbSetOrder(1)) //D07_FILIAL+D07_CODDIS+D07_DOC+D07_SERIE+D07_FORNEC+D07_LOJA+D07_PRODUT+D07_ITEM
					D07->(dbSeek(xFilial("D07")+oModelD07:GetValue("D07_CODDIS")+oModelD07:GetValue("D07_DOC")+oModelD07:GetValue("D07_SERIE")+oModelD07:GetValue("D07_FORNEC")+oModelD07:GetValue("D07_LOJA")+oModelD07:GetValue("D07_PRODUT")+oModelD07:GetValue("D07_ITEM")))
					// Necessário pois durante a montagem manual, o registro D07 está locado pela transação do modelo
					If lDistAuto
						RecLock("D07",.F.)
					EndIf
					// Atualizar quantidade original da D07 posicionada
					Replace D07->D07_QTDENT With (D07->D07_QTDENT - SD1->D1_QUANT)
					Replace D07->D07_QTDEN2 With ConvUm(SD1->D1_COD, D07->D07_QTDENT, 0, 2)
					
					If lDistAuto
						D07->(MsUnlock())
					EndIf

					RestArea(aAreaD07)
					RestArea(aAreaSD1)
					aCopiaSD1 := {}
				EndIf
			ElseIf oModelD07:GetValue("D07_QTDDIS") == oModelD07:GetValue("D07_QTDENT") .AND. oModelD07:GetValue("D07_QTDDIS") > 0 // Se a qtd distribuida for igual a qtd. do item apenas altera o serv/ender/estrut
				RecLock('SD1',.F.)
				SD1->D1_SERVIC := BuscSerEnd(1,SD1->D1_COD)
				SD1->D1_ENDER  := BuscSerEnd(2,SD1->D1_COD)
				SD1->(MsUnlock())
			ElseIf oModelD07:GetValue("D07_QTDDIS") == 0 // Se a qtd distribuida for igual a zero apenas altera o serv/ender/estrut
				RecLock('SD1',.F.)
				SD1->D1_SERVIC := BuscSerEnd(3,SD1->D1_COD)
				SD1->D1_ENDER  := BuscSerEnd(4,SD1->D1_COD)
				SD1->(MsUnlock())
			EndIf
		EndIf
	EndIf
Return
//-----------------------------------------------------
/*/	Busca o Servico, Endereco Origem e Estrutura fisica conforme o parametro
@author Tiago Filipe da Silva
@version P12
@since 04/09/2014
/*/
//------------------------------------------------------
Static Function BuscSerEnd(nOpc,cCodProd,cEnderec)
Local cRetorno   := ""
Default cCodProd := ""
Default cEnderec := ""

	dbSelectArea("SB5")
	SB5->(dbSetOrder(1))
	If SB5->(dbSeek(xFilial("SB5")+cCodProd)) .And. nOpc < 5
		If nOpc == 1 // Servico de distribuicao
			cRetorno := SB5->B5_SERECD
		ElseIf nOpc == 2 // Endereco Origem Cross-docking
			cRetorno := SB5->B5_ENDECD
		ElseIf nOpc == 3 // Servico de Armazenagem
			cRetorno := SB5->B5_SERVENT
		ElseIf nOpc == 4 // Endereco Origem
			cRetorno := SB5->B5_ENDENT
		EndIf
	EndIf
Return cRetorno
//----------------------------------------------------------------
/*/{Protheus.doc} QtdDistrib
Retorna a quantidade já distribuída do pedido de venda que está em outras distribuições
@author felipe.m
@since 16/10/2014
@version 1.0
@param cChave, character, (Descrição do parâmetro)
/*/
//----------------------------------------------------------------
Static Function QtdDistrib(cPedido,cItem,cSequen,cProdut,cCodDis)
Local cAliasD08 := ""
Local cQuery    := ""
Local nQtdDist  := 0

	cQuery := " SELECT SUM(D08.D08_QTDDIS) D08_QTDDIS"
	cQuery +=   " FROM "+RetSqlName('D08')+" D08"
	cQuery +=  " INNER JOIN "+RetSqlName('D06')+" D06"
	cQuery +=     " ON D06.D06_FILIAL = D08.D08_FILIAL"
	cQuery +=    " AND D06.D06_CODDIS = D08.D08_CODDIS"
	cQuery +=    " AND D06.D06_SITDIS IN ('1','2')"
	cQuery +=    " AND D06.D_E_L_E_T_ = ' '"
	cQuery +=  " WHERE D08.D08_FILIAL = '"+xFilial('D08')+"'"
	cQuery +=    " AND D08.D08_PEDIDO = '"+cPedido+"'"
	cQuery +=    " AND D08.D08_ITEM   = '"+cItem+"'"
	cQuery +=    " AND D08.D08_SEQUEN = '"+cSequen+"'"
	cQuery +=    " AND D08.D08_PRODUT = '"+cProdut+"'"
	cQuery +=    " AND D08.D08_CODDIS <> '"+cCodDis+"'"
	cQuery +=    " AND D08.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	cAliasD08 := GetNextAlias()
	DBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasD08,.F.,.T.)
	If (cAliasD08)->(!EoF())
		nQtdDist := (cAliasD08)->D08_QTDDIS
	EndIf
	(cAliasD08)->(dbCloseArea())
Return nQtdDist

/*--------------------------------------------------
---WMS325UPD1
---Atualiza o SD1 com o código da distribuição
---felipe.m 24/07/2015
---oModelD07, Obejto, (Modelo de dados do D07)
---lAssoc, Lógico, (Indica se associa ou se desassocia)
--------------------------------------------------*/
Function WMS325UPD1(oModelD07,lAssoc)
Local nI      := 0
Local lRet    := .T.

	SD1->( dbSetOrder(1) )
	For nI := 1 To oModelD07:Length()
		oModelD07:GoLine(nI)
		// D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
		If SD1->( dbSeek(xFilial("SD1")+oModelD07:GetValue('D07_DOC')+oModelD07:GetValue('D07_SERIE')+oModelD07:GetValue('D07_FORNEC')+oModelD07:GetValue('D07_LOJA')+oModelD07:GetValue('D07_PRODUT')+oModelD07:GetValue('D07_ITEM')) )
			RecLock("SD1",.F.)
			SD1->D1_CODDIS := Iif(lAssoc .And. !oModelD07:IsDeleted(),oModelD07:GetValue("D07_CODDIS"),"")
			SD1->( MsUnlock() )
		Else
			lRet := .F.
		EndIf
	Next nI
Return lRet
/*--------------------------------------------------
---WMS325UPPL
---Atualiza o D0M com a quantidade distribuida
---felipe.m 24/07/2015
---oModelD08, Obejto, (Modelo de dados do D08)
---lAssoc, Lógico, (Indica se associa ou se desassocia)
--------------------------------------------------*/
Function WMS325UPPL(oModelD08, lAssoc)
Local nI         := 0
Local lRet       := .T.
Local oPlDiItDis := Nil
	If oModelD08:Length() > 0
		oPlDiItDis := WMSDTCPlanoDistribuicaoItensDistribuidos():New()
	EndIf
	For nI := 1 To oModelD08:Length()
		oModelD08:GoLine(nI)
		If oModelD08:GetValue("D08_ORIGEM") == 'D0M' .And. (!lAssoc .Or. (lAssoc .And. !oModelD08:IsDeleted()))
			nQtdDis := oModelD08:GetValue("D08_QTDDIS")
			// D0M_FILIAL+D0M_CODPLN+D0M_ITEM
			oPlDiItDis:SetCodPln(oModelD08:GetValue('D08_PEDIDO'))
			oPlDiItDis:SetItem(oModelD08:GetValue('D08_ITEM'))
			oPlDiItDis:SetCodDis(oModelD08:GetValue('D08_CODDIS'))
			oPlDiItDis:SetQtdDis(nQtdDis)
			If lAssoc
				If !oPlDiItDis:LoadData()
					lRet := oPlDiItDis:RecordD0P()
				EndIf
			Else
				If oPlDiItDis:LoadData()
					lRet := oPlDiItDis:DeleteD0P()
				EndIf
			EndIf
		EndIf
	Next nI
Return lRet

Static Function Recarga(oModelD08,aD08)
Local nI := 0
Local nJ := 0
	// Atualiza
	nI := oModelD08:Length()
	For nJ := 1 To Len(aD08)
		If !Empty( oModelD08:GetValue('D08_PEDIDO',1) )
			oModelD08:AddLine()
			oModelD08:GoLine(++nI)
		EndIf
		// Ajusta
		oModelD08:LoadValue("D08_FILIAL", aD08[nJ][01])
		oModelD08:LoadValue("D08_CODDIS", aD08[nJ][02])
		oModelD08:LoadValue('D08_PEDIDO', aD08[nJ][03])
		oModelD08:LoadValue('D08_CLIENT', aD08[nJ][04])
		oModelD08:LoadValue('D08_LOCAL' , aD08[nJ][05])
		oModelD08:LoadValue('D08_LOJA'  , aD08[nJ][06])
		oModelD08:LoadValue('D08_ITEM'  , aD08[nJ][07])
		oModelD08:LoadValue('D08_PRODUT', aD08[nJ][08])
		oModelD08:LoadValue('D08_DPROD' , aD08[nJ][09])
		oModelD08:LoadValue('D08_LOTECT', aD08[nJ][10])
		oModelD08:LoadValue('D08_NUMLOT', aD08[nJ][11])
		oModelD08:LoadValue('D08_QTDVEN', aD08[nJ][12])
		oModelD08:LoadValue('D08_SEQUEN', aD08[nJ][13])
		oModelD08:LoadValue('D08_QTDVE2', aD08[nJ][14])
		oModelD08:LoadValue('D08_QTDDIS', aD08[nJ][15])
		oModelD08:LoadValue('D08_QTDDI2', aD08[nJ][16])
		oModelD08:LoadValue('D08_ENDER' , aD08[nJ][17])
		oModelD08:LoadValue('D08_DATENT', aD08[nJ][18])
		oModelD08:LoadValue('D08_ORIGEM', aD08[nJ][19])
	Next nJ
Return Nil
