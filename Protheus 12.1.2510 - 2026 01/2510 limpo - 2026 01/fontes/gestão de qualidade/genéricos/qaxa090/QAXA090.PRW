#INCLUDE "FWMVCDEF.CH"  
#INCLUDE "QAXA090.CH"
#INCLUDE "TOTVS.CH"

#DEFINE GetOrigem_LOK    1
#DEFINE GetOrigem_NRADIO 2

Static slHasQQN := Nil

/*/{Protheus.doc} QAXA090
Cadastro Arquivos da Manufatura
@author brunno.costa
@since 23/10/2025
/*/
Function QAXA090()

	Local aArea := GetArea()
	Local oBrowse

	Private lBrowse   := .T.

	If QAXA090QQN() //Valida existência de QQN
		DbSelectArea("QQN")
		DbSelectArea("QQO")

		oBrowse := BrowseDef()
		oBrowse:Activate()
	EndIf

	RestArea(aArea)

Return Nil

/*/{Protheus.doc} QAXA090QQN
Valida existência de QQN
@author brunno.costa
@since 23/10/2025
@param 01 - lHelp, lógico, indica se deve exibir mensagem de ajuda caso não exista QQN (padrão .T.)
@return lHasQQN, lógico, indica se a tabela QQN existe
/*/
Function QAXA090QQN(lHelp)

	Default lHelp := .T.

	slHasQQN := Iif(slHasQQN == Nil, !(Empty(GetSx3Cache("QQN_ORIGEM" ,"X3_TAMANHO")) .OR. Empty(FWSX2Util():GetFile( "QQN" ))), slHasQQN)

	If !slHasQQN .anD. lHelp
		//STR0001 - "Dicionário do Protheus desatualizado."
		//STR0002 - "Atualize o pacote de dicionário mais recente do módulo SIGAQIP para atualização da tabela QQN."
		Help(NIL, NIL, "QAXA090USED", NIL, STR0001, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0002})
	EndIf

Return slHasQQN

/*/{Protheus.doc} BrowseDef
Definição do browse principal (QQN)
@author brunno.costa
@since 23/10/2025
@return oBrowse, object, objeto de browse configurado
/*/
Static Function BrowseDef()

	Local oBrowse := FWMBrowse():New()

	oBrowse:SetAlias("QQN")
	oBrowse:SetDescription(STR0003) //"Arquivos da Manufatura"

Return oBrowse

/*/{Protheus.doc} MenuDef
Definição do Menu
@author brunno.costa
@since 23/10/2025
@return aRotina, array,  vetor com botoes da EnchoiceBar
/*/
Static Function MenuDef()
	
	Private aRotina := {}

	ADD OPTION aRotina TITLE STR0004 ACTION 'QAXA090VIS()' OPERATION OP_VISUALIZAR ACCESS 0 //STR0004 - Visualizar
	ADD OPTION aRotina TITLE STR0005 ACTION 'QAXA090INC()' OPERATION OP_INCLUIR ACCESS 0    //STR0005 - Incluir
	ADD OPTION aRotina TITLE STR0006 ACTION 'QAXA090ALT()' OPERATION OP_ALTERAR ACCESS 0    //STR0006 - Alterar
	ADD OPTION aRotina TITLE STR0007 ACTION 'QAXA090EXC()' OPERATION OP_EXCLUIR ACCESS 0    //STR0007 - Excluir

Return aRotina

/*/{Protheus.doc} QAXA090B
Manutenção/consulta de Arquivos da Manufatura (MVC)
@author brunno.costa
@since 23/10/2025
@param 01 - nOpc      , numérico , operação (2=Consultar, 3=Incluir, 4=Alterar, 5=Excluir)
@param 02 - cOrigRef  , caractere, origem do arquivo ("1"=Físico, "2"=URL)
@param 03 - cEntRef   , caractere, entidade de chamada (ex.: "QQN", "QP6")
@param 04 - cMcrVldUpd, caractere, string de macro execução para validaçao de exibição de tela em alteração (.T.) ou visualização (.F.) complementando nOpc
@return Nil
/*/
Function QAXA090B(nOpc, cOrigRef, cEntRef, cMcrVldUpd)

	Local cTituloView  := ""
	Local lAlteraBkp   := ALTERA
	Local lIncluiBkp   := INCLUI
	Local nPercReduc   := 0

	Default nOpc       := 0
	Default cOrigRef   := "0"
	Default cMcrVldUpd := ".T."

	If QAXA090QQN() //Valida existência de QQN

		Private cEntidade := cEntRef
		Private cCadastro := STR0003 //"Arquivos da Manufatura"
		Private cTitulo   := ""
		Private lInclui   := nOpc == 3
		Private lUpdate   := nOpc == 4
		Private lDelete   := nOpc == 5
		Private cOrigem   := cOrigRef

		DbSelectArea("QQN")

		If cEntidade == "QP6" .Or. cEntidade == "QE6" .Or. cEntidade == "QQC"
			cCadastro := STR0018 //"Arquivos da Especificação"
		EndIf

		If lInclui
			cTitulo := STR0005 //"Incluir"
			M->QQN_ORIGEM := cOrigem
		ElseIf lUpdate .And. &(cMcrVldUpd)
			cTitulo := STR0006 //"Alterar"
		ElseIf lDelete
			cTitulo := STR0007 //"Excluir"
		Else
			cTitulo := STR0004 //"Visualizar"
		EndIf

		If cOrigRef == "1"
			cTitulo += " (" + STR0008 + ")" //Físico
		ElseIf cOrigRef == "2"
			cTitulo += " (" + STR0009 + ")" //URL
		EndIf

		If cEntidade != "QQN"
			nPercReduc := 50
		EndIf

		//Ajusta bug duplicidade de nome cCadastro nas chamadas de Visualização e Inclusão
		If IsInCallStack("QAXA090VIS") .Or. IsInCallStack("QAXA090ALT")
			cTituloView := cTitulo
		Else
			cTituloView := cCadastro + " - " + cTitulo
		EndIf

		If lInclui
			nPercReduc := 50
			FWExecView(cTituloView, "QAXA090", MODEL_OPERATION_INSERT,,{|| .T. },{|| .T.}, nPercReduc)

		ElseIf lUpdate .And. &(cMcrVldUpd)
			FWExecView(cTituloView, "QAXA090", MODEL_OPERATION_UPDATE,,{|| .T. },{|| .T.}, nPercReduc)

		ElseIf lDelete
			
			//Chama formulário de exclusão apenas para acesso ao Cadastro Arquivos da Manufatura no Menu
			If IsInCallStack("QAXA090") 
				FWExecView(cTituloView, "QAXA090", MODEL_OPERATION_DELETE,,{|| .T. },{|| .T.}, nPercReduc)

			//Demais cadastros abre formulário de consulta
			Else
				FWExecView(cTituloView, "QAXA090", MODEL_OPERATION_VIEW  ,,{|| .T. },{|| .T.}, nPercReduc)	

			EndIf

		Else
			FWExecView(cTituloView, "QAXA090", MODEL_OPERATION_VIEW  ,,{|| .T. },{|| .T.}, nPercReduc)

		EndIf
	EndIf

	INCLUI := lIncluiBkp
	ALTERA := lAlteraBkp

Return Nil

/*/{Protheus.doc} QAXA090INC
Ação de inclusão do menu (QQN)
@author brunno.costa
@since 23/10/2025
@return Nil
/*/
Function QAXA090INC()

	Local aReturn := GetOrigem()

	If aReturn[GetOrigem_LOK] //Se OK
		QAXA090B( 3, aReturn[GetOrigem_NRADIO], "QQN" )
	EndIf

Return

/*/{Protheus.doc} QAXA090VIS
Ação de visualização do menu (QQN)
@author brunno.costa
@since 23/10/2025
@return Nil
/*/
Function QAXA090VIS()

	QAXA090B( 2, QQN->QQN_ORIGEM, "QQN" )

Return

/*/{Protheus.doc} QAXA090ALT
Ação de alteração do menu (QQN)
@author brunno.costa
@since 23/10/2025
@return Nil
/*/
Function QAXA090ALT()

	QAXA090B( 4, QQN->QQN_ORIGEM, "QQN" )

Return

/*/{Protheus.doc} QAXA090EXC
Ação de exclusão do menu (QQN)
@author brunno.costa
@since 23/10/2025
@return Nil
/*/
Function QAXA090EXC()

	QAXA090B( 5, QQN->QQN_ORIGEM, "QQN" )

Return

/*/{Protheus.doc} QAXA090GRV
Gravação de registros da QQO
@author brunno.costa
@since 31/10/2025
@return Nil
/*/
Function QAXA090GRV()

	Local aCols       := Nil
	Local aDeletados  := {}
	Local aHeader     := Nil
	Local aWhereExtra := {}
	Local cCampo      := ""
	Local nFldPos     := 0
	Local nHdr        := 0
	Local nPosGrp     := 0
	Local nPosItem    := -1
	Local nPosPrd     := 0
	Local nPosRvG     := 0
	Local nPosRvP     := 0
	Local nPosUID     := 0
	Local nRow        := 0

	//Avalia se tem QQN e dados para gravação
	If QAXA090QQN(.F.) .And. aDataQQO != Nil

		DbSelectArea("QQO")
		QQO->(DbSetOrder(1))

		aCols   := aDataQQO[2]
		aHeader := aDataQQO[1]

		nPosGrp := Ascan(aHeader,{|x| AllTrim(x[2])=="QQO_GRUPO"})
		nPosPrd := Ascan(aHeader,{|x| AllTrim(x[2])=="QQO_PRODUT"})
		nPosRvG := Ascan(aHeader,{|x| AllTrim(x[2])=="QQO_REVIGR"})
		nPosRvP := Ascan(aHeader,{|x| AllTrim(x[2])=="QQO_REVI"})
		nPosUID := Ascan(aHeader,{|x| AllTrim(x[2])=="QQO_MSUID"})

		//Verifica registros deletados
		For nRow := 1 to Len(aCols)
			If aTail(aCols[nRow]) // Excluído
				aAdd(aDeletados, aCols[nRow])
			EndIf
		Next nRow

		//Desconsidera exclusões re-inclusas
		For nRow := 1 to Len(aCols)
			If !aTail(aCols[nRow]) //Não Excluído
				nPosItem := Ascan(aDeletados,{|x| x[nPosUID]==aCols[nRow][nPosUID] .And.;
											 	  x[nPosPrd]==aCols[nRow][nPosPrd] .And.;
											 	  x[nPosRvP]==aCols[nRow][nPosRvP] .And.;
											 	  x[nPosGrp]==aCols[nRow][nPosGrp] .And.;
											 	  x[nPosRvG]==aCols[nRow][nPosRvG]  })
				If nPosItem > 0
					aDel(aDeletados, nPosItem)
					aSize(aDeletados, Len(aDeletados)-1)
				EndIf
			EndIf
		Next nRow

		//Exclui Registros
		For nRow := 1 to Len(aDeletados)
			cMSUID    := aDeletados[nRow][nPosUID]

			If !Empty(cMSUID)

				aWhereExtra := {}
				If !Empty(aCols[nRow][nPosPrd])
					aAdd(aWhereExtra, {"QQO_PRODUT = ?", {{aCols[nRow][nPosPrd], "S"}}})
					aAdd(aWhereExtra, {"QQO_REVI   = ?", {{aCols[nRow][nPosRvP], "S"}}})
				EndIf
				
				If !Empty(aCols[nRow][nPosGrp])
					aAdd(aWhereExtra, {"QQO_GRUPO  = ?", {{aCols[nRow][nPosGrp], "S"}}})
					aAdd(aWhereExtra, {"QQO_REVIGR = ?", {{aCols[nRow][nPosRvG], "S"}}})
				EndIf

				If QLTQueryManager():dbSeek("QQO", cMSUID, aWhereExtra)
					RecLock("QQO",.F.)
					QQO->(DbDelete())
					QQO->(MsUnLock())
				EndIf

			EndIf

		Next nRow

		//Inclusão registros inexistentes
		For nRow := 1 to Len(aCols)

			If !aTail(aCols[nRow]) //Não Excluído

				cMSUID    := aCols[nRow][nPosUID]

				If !Empty(cMSUID)

					aWhereExtra := {}
					
					If !Empty(aCols[nRow][nPosPrd])
						aAdd(aWhereExtra, {"QQO_PRODUT = ?", {{aCols[nRow][nPosPrd], "S"}}})
						aAdd(aWhereExtra, {"QQO_REVI   = ?", {{aCols[nRow][nPosRvP], "S"}}})
					EndIf
					
					If !Empty(aCols[nRow][nPosGrp])
						aAdd(aWhereExtra, {"QQO_GRUPO  = ?", {{aCols[nRow][nPosGrp], "S"}}})
						aAdd(aWhereExtra, {"QQO_REVIGR = ?", {{aCols[nRow][nPosRvG], "S"}}})
					EndIf

					If !QLTQueryManager():dbSeek("QQO", cMSUID, aWhereExtra)
						
						// Preenche os campos do registro QQO a partir do header/linha.
						// Ignora campos virtuais (X3_CONTEXT == "V") e inexistentes.
						RecLock("QQO",.T.)
						For nHdr := 1 To Len(aHeader)
							cCampo  := AllTrim(aHeader[nHdr][2])
							nFldPos := QQO->(FieldPos(cCampo))
							If GetSx3Cache(cCampo, "X3_CONTEXT") != "V" .And. nFldPos > 0 .And. aCols[nRow][nHdr] != Nil
								QQO->(FieldPut(nFldPos, aCols[nRow][nHdr]))
							EndIf
						Next nHdr
						QQO->(MsUnLock())

					EndIf

				EndIf

			EndIf

		Next nRow

	EndIf

Return

/*/{Protheus.doc} QAXA090GEA
Gravação da exclusão registros da QQO
@author brunno.costa
@since 31/10/2025
@param 01 - cEntidade, caracter, entidade relacionada ao vinculo para exclusão dos relacionamentos
@param 02 - aWhereExtra, array, array com condições extras para filtro no seek (opcional)
          {
            cQryWhere , caracter, condição extra em sintaxe SQL
            aBinds    , array   , array com os dados dos parâmetros para BIND:
                          {{oDados, cTipo}, {}, ...}
                          Sendo cTipo:
                          N -> Número, para uso com FwExecStatement():setNumeric()
                          S -> String, para uso com FwExecStatement():setString()
                          A -> Array , para uso com FwExecStatement():setInArray()
                          U -> Unsafe, para uso com FwExecStatement():setUnsafe()
          }
/*/
Function QAXA090GEA(cEntidade, aWhereExtra)

	Default aWhereExtra := {}
	
	//Avalia se tem QQN e qual entidade
	If QAXA090QQN(.F.) .And. !Empty(aWhereExtra)// cEntidade == "QP6"
		aAdd(aWhereExtra, {"QQO_ENTIDA = ?", {{cEntidade, "S"}}})

		While QLTQueryManager():dbSeek("QQO", Nil, aWhereExtra)
			RecLock("QQO",.F.)
			QQO->(DbDelete())
			QQO->(MsUnLock())
		EndDo
	EndIf

Return

/*/{Protheus.doc} QAX090VLDC
Validação de campo
@author brunno.costa
@since 23/10/2025
@param 01 - cCampo, caractere, identificador do campo validado
@return lOk, lógico, indica se a validação foi bem-sucedida
/*/
Function QAX090VLDC(cCampo)

	Local cExtensao := ""
	Local cMime     := ""
	Local lReturn   := .T.
	Local oModel    := Nil
	Local oSelf     := Nil
	Local oView     := Nil

	If cCampo == "QQN_MODOVI"
		If M->QQN_MODOVI == "1"
			cExtensao := aTail(StrtoKarr(M->QQN_NOMEOR,"."))
			oView     := FWViewActive()
			oModel    := oView:GetModel()
			oSelf     := gtMdlEvent(oModel, "QAXA090EVDEF")
			cMime     := oSelf:retornaMimeType(cExtensao)
			If !("audio" $ cMime) .And. !("image" $ cMime) .And. !("video" $ cMime)
				lReturn := .F.
				//STR0010 - "Modo de visualização inválido."
				//STR0011 - "A visualização interna é permitida apenas para documentos físicos de áudio, imagem ou vídeo."
				Help(NIL, NIL, "QAXA090MDVI", NIL, STR0010, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0011})
			EndIf
		EndIf
	EndIf
	
Return lReturn

/*/{Protheus.doc} GetOrigem
Diálogo para seleção da origem do arquivo
@author brunno.costa
@since 23/10/2025
@return aReturn, array, { lOk, cOrigem } onde cOrigem: "1"=Físico, "2"=URL
/*/
Static Function GetOrigem()
	Local lOk    := .F.
	Local nRadio := 1
	Local oDlg   := Nil
	Local oRadio := Nil

	DEFINE MSDIALOG oDlg FROM	35,37 TO 150,400 TITLE OemToAnsi(STR0012) PIXEL //"Origem do Arquivo"

	@ 005,005 TO 045,140 OF oDlg PIXEL

	//STR0008 - Físico
	//STR0009 - URL
	@ 013,011 RADIO oRadio VAR nRadio 3D SIZE 130,011 PROMPT OemToAnsi("1: " + STR0008), OemToAnsi("2: " + STR0009)  OF oDlg PIXEL

	DEFINE SBUTTON FROM 011, 150 TYPE 1 ENABLE OF oDlg Action (lOk:=.T.,oDlg:End())
	DEFINE SBUTTON FROM 024, 150 TYPE 2 ENABLE OF oDlg Action (lOk:=.F.,oDlg:End())

	ACTIVATE MSDIALOG oDlg Centered

Return ({lOk,cValToChar(nRadio)})

/*/{Protheus.doc} ModelDef
Definição do Modelo
@author brunno.costa
@since 23/10/2025
@return oModel, object, modelo de dados
/*/
Static Function ModelDef()

	Local aLoad      := {}
	Local oEventDef  := QAXA090EVDEF():New()
	Local oModel     := MPFormModel() :New('QAXA090' )
	Local oStrDetail := FWFormStruct(1,"QQO")
	Local oStrMaster := FWFormStruct(1,"QQN")

	If cEntidade != "QQN"
		
		oStrMaster:SetProperty( "QQN_MSUID" , MODEL_FIELD_OBRIGAT,.F.)
		oStrMaster:SetProperty( "QQN_DESCRI", MODEL_FIELD_OBRIGAT,.F.)
		oStrMaster:SetProperty( "QQN_ORIGEM", MODEL_FIELD_OBRIGAT,.F.)
		oStrDetail:SetProperty( "QQO_MSUID" , MODEL_FIELD_OBRIGAT,.F.)

	EndIf

	//QQN_MASTER - Modelo do campo mestre (Cabeçalho)
	oModel:AddFields("QQN_MASTER", /*cOwner*/, oStrMaster)
	oModel:GetModel("QQN_MASTER"):SetDescription(STR0013) //"Dados do Arquivo"

	//QQO_DETAIL - Modelo dos Anexos (Grid)
	oStrDetail:AddField(""                           ,; // [01] C Titulo do campo
	                    ""                           ,; // [02] C ToolTip do campo
	                    "NREG"                       ,; // [03] C Id do Field
	                    "N"                          ,; // [04] C Tipo do campo
	                    8                            ,; // [05] N Tamanho do campo
	                    0                            ,; // [06] N Decimal do campo
	                    NIL, NIL, NIL, .F.           ,;
	                    {|| 0}                       ,; // [11] B Code-block de inicializacao do campo
	                    NIL, NIL, .T.                )

	oModel:AddGrid("QQO_DETAIL", "QQN_MASTER", oStrDetail, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPost*/, /*bLoad*/)
	oModel:GetModel("QQO_DETAIL"):SetDescription(STR0014) //Onde se usa
	
	aLoad := oEventDef:carregaItensDaGrid(oModel)
	oModel:GetModel("QQO_DETAIL"):bLoad := {|| aLoad }
	oModel:GetModel('QQO_DETAIL'):SetOptional(.T.) 

	If cEntidade == "QQN"
		oModel:GetModel("QQO_DETAIL"):SetNoDeleteLine(.T.)
		oModel:GetModel("QQO_DETAIL"):SetNoInsertLine(.T.)
	EndIf

	oModel:SetRelation("QQO_DETAIL",{{"QQN_FILIAL", "xFilial('QQN')"},{"QQN_MSUID", "QQO_MSUID"}}, QQN->(IndexKey(1)))
	
	oModel:SetDescription(STR0003) //"Arquivos da Manufatura"
	oModel:InstallEvent("QAXA090EVDEF", /*cOwner*/, oEventDef)
    oModel:SetPrimaryKey( { "QQO_MSUID", "QQO_PRODUT", "QQO_REVI", "QQO_GRUPO", "QQO_ENSAIO", "QQO_ROTEIR", "QQO_OPERAC", "QQO_FILENT", "QQO_ENTIDA" } )


	If cEntidade != "QQN"
		oModel:GetModel('QQO_DETAIL'):SetUniqueLine({'QQO_MSUID'})
		oModel:GetModel("QQO_DETAIL"):SetUseOldGrid(.T.)
		
		oModel:SetCommit( {|oModel| oEventDef:vinculaRelacionamentosMemoria(oModel) }, .F. )

	EndIf

Return oModel

/*/{Protheus.doc} ViewDef
Definição da View
@author brunno.costa
@since 23/10/2025
@return oView, object, objeto de View
/*/
Static Function ViewDef()

	Local oEventDef  := Nil
	Local oModel     := FWLoadModel("QAXA090")
	Local oStrDetail := Nil
	Local oStrMaster := Nil
	Local oView      := FWFormView():New()

	oEventDef  := gtMdlEvent(oModel, "QAXA090EVDEF")

	If     cOrigem == "1" //Físico
		oStrMaster := FWFormStruct(2,"QQN", {|cCampo| "|"+AllTrim(cCampo)+"|" $ "|QQN_NOMEOR|QQN_DESCRI|QQN_MODOVI|QQN_DTVALI|"})
	ElseIf cOrigem == "2" //URL
		oStrMaster := FWFormStruct(2,"QQN", {|cCampo| "|"+AllTrim(cCampo)+"|" $ "|QQN_DESCRI|QQN_URL|QQN_DTVALI|"})
	//ElseIf cOrigem == "3" //QDO
	//	oStrMaster := FWFormStruct(2,"QQN", {|cCampo| "|"+AllTrim(cCampo)+"|" $ "|QQN_NOMEOR|QQN_DESCRI|QQN_DOCQDO|QQN_DTVALI|"})
	Else
		oStrMaster := FWFormStruct(2,"QQN", {|cCampo| "|"+AllTrim(cCampo)+"|" $ "|QQN_NOMEOR|QQN_DESCRI|QQN_DOCQDO|QQN_DTVALI|"})
	EndIf

	IF cEntidade == "QQN"
		oStrDetail := FWFormStruct(2,"QQO", {|cCampo| "|"+AllTrim(cCampo)+"|" $ "|QQO_PRODUT|QQO_REVI|QQO_GRUPO|QQO_REVIGR|QQO_FILENT|QQO_ENTIDA|"})
	Else
		oStrDetail := FWFormStruct(2,"QQO", {|cCampo| "|"+AllTrim(cCampo)+"|" $ "|QQO_NOMEOR|QQO_DESCRI|QQO_MSUID|"})
	EndIf

	oView:SetModel(oModel)

	//Seta os modelos na View
	oView:AddField("V_QQN_MASTER", oStrMaster, "QQN_MASTER")
	oView:AddGrid( "V_QQO_DETAIL", oStrDetail, "QQO_DETAIL")
	
	IF cEntidade == "QQN"
		oView:EnableTitleView("V_QQO_DETAIL", STR0014) //Onde se usa
	EndIf

	//Cria os BOXs para as Views

	//Instanciado em tela de Inclusão de Arquivo
	If cEntidade == "QQN" .And. lInclui

		oView:CreateHorizontalBox("UPPER" ,  100)
		oView:CreateHorizontalBox("BOTTOM", 0, , .T.)

	//Instanciado em tela de Alteração de Arquivo ou Consulta
	ElseIf cEntidade == "QQN"

		oView:CreateHorizontalBox("UPPER" ,  150, , .T.)
		oView:CreateHorizontalBox("BOTTOM", 100)
	
	//Instanciado em tela de Relacionamento de Arquivo
	Else

		oView:CreateHorizontalBox("UPPER" ,  0, , .T.)
		oView:CreateHorizontalBox("BOTTOM", 100)

	EndIf

	//Relaciona cada BOX com sua view
	oView:SetOwnerView("V_QQN_MASTER", "UPPER" )
	oView:SetOwnerView("V_QQO_DETAIL", "BOTTOM")

	//Habilita o filtro e busca na grid.
	oView:SetViewProperty("V_QQO_DETAIL","GRIDFILTER",{.T.})
	oView:SetViewProperty("V_QQO_DETAIL","GRIDSEEK",{.T.})

	oView:SetViewProperty( "*", "GRIDNOORDER")
	
	If lInclui .And. cOrigem == "1"
		oView:AddUserButton(STR0015, "", {|oView| oEventDef:localizaEVinculaAnexo() }, , , ,  .T. ) //"Localizar"	
	EndIf

	If !lInclui .And. cOrigem == "1"
		oView:AddUserButton(STR0016, "", {|oView| oEventDef:abrirAnexo()   }, , , ,  .T. )          //"Abrir"
	EndIf

	If !lInclui .And. cOrigem == "2"
		oView:AddUserButton(STR0017, "", {|oView| oEventDef:abrirURL()   }, , , ,  .T. )            //"Abrir URL"
	EndIf

	//Adiciona barra de progresso.
	oView:SetProgressBar(.T.)

	If cEntidade != "QQN"
		oView:lAvalRequiredFields := .F.
		oView:showInsertMsg(.F.)
		oView:showUpdateMsg(.F.)
		oView:AddUserButton(STR0016, "", {|oView| oEventDef:abrirViaQQO()   }, , , ,  .T. )            //"Abrir"
	EndIf


Return oView

/*/{Protheus.doc} gtMdlEvent
Recupera a referencia do objeto dos Eventos do modelo.
@author brunno.costa
@since 23/10/2025
@version P12
@param 01 - oModel  , Object   , Modelo de dados
@param 02 - cIdEvent, Character, ID do evento que se deseja recuperar.
@return oEvent , Object   , Referência do evento do modelo de dados.
/*/
Static Function gtMdlEvent(oModel, cIdEvent)
	Local nIndex  := 0
	Local oEvent  := Nil
	Local oMdlPai := Nil

	If oModel != Nil
		oMdlPai := oModel:GetModel()
	EndIf

	If oMdlPai != Nil .And. AttIsMemberOf(oMdlPai, "oEventHandler", .T.) .And. oMdlPai:oEventHandler != NIL
		For nIndex := 1 To Len(oMdlPai:oEventHandler:aEvents)
			If oMdlPai:oEventHandler:aEvents[nIndex]:cIdEvent == cIdEvent
				oEvent := oMdlPai:oEventHandler:aEvents[nIndex]
				Exit
			EndIf
		Next nIndex
	EndIf

Return oEvent

/*/{Protheus.doc} QAX090INIC
Inicialização dinâmica de campo
@author brunno.costa
@since 23/10/2025
@param 01 - cCampo, caractere, identificador do campo
@return cValor, caractere, valor inicial
/*/
Function QAX090INIC(cCampo)
Return ""

/*/{Protheus.doc} QAX090INIB
Inicialização dinâmica de campo no browse
@author brunno.costa
@since 31/10/2025
@param 01 - cCampo, caractere, identificador do campo
@return cValor, caractere, valor inicial
/*/
Function QAX090INIB(cCampo)
	
	Local cReturn := ""
	Local cCpoRef := ""

	If "QQO" $ cCampo
		If QLTQueryManager():dbSeek("QQN", QQO->QQO_MSUID)
			cCpoRef := StrTran(cCampo, "QQO", "QQN")
			cReturn := QQN->&(cCpoRef)
		EndIf
	EndIf

Return cReturn

/*/{Protheus.doc} QAX090GAT
Gatilho auxiliar de conversão/ajuste de valores
@author brunno.costa
@since 31/10/2025
@param 01 - cOrigem , caractere, valor de origem
@param 02 - cDestino, caractere, valor de destino
@return cRet, caractere, valor resultante
/*/
Function QAX090GAT(cOrigem, cDestino) 

	Local aWhereExtra := {}
	Local cConteudo   := AllTrim(&(ReadVar()))
	Local cCpoRef     := ""
	Local cDescricao  := ""
	Local cReturn     := ""
	//Local nRecnoQQN   := QQN->(Recno())
	Local oModel      := FWModelActive()

	If "QQO" $ cOrigem .And. !Empty(cConteudo)
		aWhereExtra := {}
		aAdd(aWhereExtra, {"UPPER(QQN_DESCRI) LIKE ? + '%'", {{Upper(cConteudo), "S"}}})

		If QLTQueryManager():dbSeek("QQN", Nil, aWhereExtra)
			cCpoRef := StrTran(cDestino, "QQO", "QQN")
			cReturn := QQN->&(cCpoRef)

			If AllTrim(cOrigem) == "QQO_DESCRI"
				cDescricao  := QQN->QQN_DESCRI
				oModel:LoadValue("QQO_DETAIL", "QQO_DESCRI", cDescricao)
			EndIf

		Else

			HelpInDark(.F.)

			//STR0019 - "Arquivo não encontrado."
			//STR0020 - "Utilize a consulta padrão para encontrar um arquivo válido."
			Help(NIL, NIL, "QAXA090NoFile", NIL, STR0019, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0020})

			HelpInDark(.T.)

			oModel:LoadValue("QQO_DETAIL", "QQO_DESCRI", Padr(" ", GetSx3Cache("QQO_DESCRI", "X3_TAMANHO")))

		EndIf

	EndIf

Return cReturn

/*/{Protheus.doc} QAXQNNFIL
Filtro adicional para o browse/consulta da QQN, é executado antes do arquivo da QQN ser listado na consulta para vinculo na especificação de produtos do SIGAQIE e SIGAQIP.
@author brunno.costa
@since 23/10/2025
@return lReturn, lógico, se verdadeiro, o registro da QQN posicionado no momento é exibido para seleção na consulta de Arquivos da especificação.
/*/
Function QAXQNNFIL()

	Local lQQNFILPE	:= ExistBlock("QQNFILPE")
	Local lReturn	:= .T.

	If lQQNFILPE
		lReturn := ExecBlock("QQNFILPE", .F., .F.)
		If ValType( lReturn ) <> "L"
			lReturn := .T.
		EndIf
	EndIf

Return lReturn
