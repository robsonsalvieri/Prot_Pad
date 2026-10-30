#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "FWEVENTVIEWCONSTS.CH"   
#INCLUDE "CRM980EventDEF.CH"   

//-------------------------------------------------------------------
/*/{Protheus.doc} CRM980EventDef
Classe responsável pelo evento das regras de negócio da 
localização Padrão.

@type 		Classe
@author 	Squad CRM / FAT
@version	12.1.17 / Superior
@since		19/05/2017 
/*/
//-------------------------------------------------------------------
Class CRM980EventDEF From FwModelEvent 
	Data aModelSA1  // Model para operações em grid de endereços complementares, onde cada linha da grid é um registro na SA1, para commit posterior no AfterTTS.
	Data lRotAutoCl  // Determina se a função foi executada em ExecAuto.

	Method New() CONSTRUCTOR

	//---------------------
	// PreValid de grid do modelo
	//---------------------
	Method GridLinePreVld()

	//---------------------
	// PreValid de campos do modelo
	//---------------------
	Method FieldPreVld()

	//---------------------
	// PosValid do Model. 
	//---------------------
	Method ModelPosVld()
	
	//--------------------------------------------------------------------
	// Bloco com regras de negócio antes da transação do modelo de dados.
	//--------------------------------------------------------------------
	Method BeforeTTS()
	
	//---------------------------------------------------------------------
	// Bloco com regras de negócio dentro da transação do modelo de dados.
	//---------------------------------------------------------------------
	Method InTTS()
	
	//-------------------------------------------------------------------
	// Bloco com regras de negócio depois transação do modelo de dados.
	//-------------------------------------------------------------------
	Method AfterTTS()

	//-------------------------------------------------------------------
	// Bloco destrutor da classe
	//-------------------------------------------------------------------
	Method Destroy()

EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New
Metodo responsável pela construção da classe.

@type 		Método
@author 	Squad CRM / FAT
@version	12.1.17 / Superior
@since		19/05/2017 
/*/
//-------------------------------------------------------------------
Method New() Class CRM980EventDEF
	self:aModelSA1  := {}
	self:lRotAutoCl := (Type("l030Auto") == "L" .And. l030Auto)
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} GridLinePreVld()
Metodo de pré-validação do grid.

@type    Metodo
@param   oSubModel    , Objeto  , Submodelo onde ocorreu a acao (SA1MASTER).
@param   cModelID     , Caracter, Id do submodelo.
@param   cAction      , Caracter, Acao (SETVALUE, CANSETVALUE, etc.).
@param   cId          , Caracter, Nome do campo alterado.
@param   xValue       , Variant , Novo valor sendo atribuido.
@param   xCurrentValue, Variant, Valor atual do campo antes da alteração.

@return  lRet         , Logico  , .T. permite a atribuicao.

@author  Squad Retail / Jesus.sjunior
@since   24/06/2026
/*/
//-------------------------------------------------------------------
Method GridLinePreVld(oSubModel, cModelID, nLine, cAction, cId, xValue, xCurrentValue) Class CRM980EventDEF
	Local lRet      as Logical
	Local oModel    as Object
	Local cProblema as Character
	Local cSolucao  as Character

	Default oSubModel     := Nil
	Default cModelID      := ""
	Default nLine         := 0
	Default cAction       := ""
	Default cId           := ""
	Default xValue        := Nil
	Default xCurrentValue := Nil

	lRet := .T.

	If cModelID == "SA1ENDCOMP" .And. "|" + AllTrim(cAction) + "|" $ "|CANSETVALUE|UNDELETE|DELETE|"
		oModel := oSubModel:GetModel()

		If oModel <> Nil .And. !A980PesFis(oModel:GetModel("SA1MASTER"))
			If AllTrim(cAction) == "DELETE" .And. oSubModel:IsInserted(oSubModel:GetLine())
				// Permite excluir a linha do grid de endereços complementares, caso o usuário tenha inserido 
				// uma linha e depois queira excluir, mesmo que o cliente não seja do tipo físico
				lRet := .T.
			Else
				// Bloqueia/Desbloqueia a edição do grid de endereços complementares, pois o cliente não é mais do tipo físico
				lRet      := .F.
				cProblema := STR0013 // "Não é possível utilizar a funcionalidade de endereços complementares, pois o cliente não é do tipo físico."
				cSolucao  := STR0014 // "Para utilizar a funcionalidade de endereços complementares, o cliente deve ser do tipo físico."
				Help('', 1, '', ProcName(0), cProblema, 1,,,,,,, {cSolucao})
			EndIf
		EndIf
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FieldPreVld
Método que é chamado pelo MVC quando ocorrer a ação de pré validação do Field

@type    Metodo
@param   oSubModel, Objeto  , Submodelo onde ocorreu a acao (SA1MASTER).
@param   cModelID , Caracter, Id do submodelo.
@param   cAction  , Caracter, Acao (SETVALUE, CANSETVALUE, etc.).
@param   cId      , Caracter, Nome do campo alterado.
@param   xValue   , Variant , Novo valor sendo atribuido.
@return  lRet     , Logico  , .T. permite a atribuicao.

@author  Squad Retail / Jesus.sjunior
@since   22/06/2026
/*/
//-------------------------------------------------------------------
Method FieldPreVld(oSubModel, cModelID, cAction, cId, xValue) Class CRM980EventDEF
	Local lRet      As Logical
	Local oModel    As Object
	Local oGridEnd  As Object
	Local lValida   As Logical

	Default oSubModel := Nil
	Default cModelID  := ""
	Default cAction   := ""
	Default cId       := ""
	Default xValue    := Nil

	lRet := .T.
	lValida := .F.

	If oSubModel <> Nil
		If cModelID == "SA1MASTER" .And. cAction == "SETVALUE" // Alterando de "F" (Física) para "J" (Jurídica)

			If cPaisLoc == 'PER' .And. cId == "A1_TIPO" .And. ValType(xValue) == "C"
				lValida := AllTrim(xValue) <> '2'
			ElseIf cPaisLoc $ 'ANG|EQU|HAI|RUS' .And. cId == "A1_TIPO" .And. ValType(xValue) == "C"
				lValida := AllTrim(xValue) <> '1'
			ElseIf cPaisLoc == 'PTG' .And. cId == "A1_TIPO" .And. ValType(xValue) == "C"
				lValida := !(AllTrim(xValue) $ '1|3')
			ElseIf cId == "A1_PESSOA" .And. ValType(xValue) == "C"
				lValida := AllTrim(xValue) <> 'F'
			EndIf

			If lValida
				oModel := oSubModel:GetModel()

				If oModel <> Nil .And. oModel:HasField("SA1MASTER", "A1_NOMEEND")
					oGridEnd := oModel:GetModel("SA1ENDCOMP")

					If oGridEnd <> Nil .And. !oGridEnd:IsEmpty()
						oGridEnd:DelAllLine() // Deleta as linhas do grid de endereços complementares
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelPosVld
Método responsável por executar as validações das regras de negócio
genéricas do cadastro antes da gravação do formulario.
Se retornar falso, não permite gravar.

@type 		Método

@param 		oModel	,objeto	,Modelo de dados de Clientes.
@param 		cID		,caracter	,Identificador do sub-modelo.

@author 	Squad CRM / FAT
@version	12.1.17 / Superior
@since		19/05/2017 
/*/
//-------------------------------------------------------------------
Method ModelPosVld(oModel,cID) Class CRM980EventDEF
	Local lValid 		:= .T.
	Local lMT030Int  	:= ExistBlock("MT030INT")
	Local lVldInt		:= .T.
	Local nOperation	:= oModel:GetOperation()
	Local oMdlSA1		:= oModel:GetModel("SA1MASTER")
	Local cAliasTrf		:= ""
	Local cFilTrf		:= ""
	Local cCpoTpP		:= "A1_PESSOA"
	
	If lMT030Int
		lVldInt := Execblock("MT030INT",.F.,.T.)
	EndIf

	If nOperation == MODEL_OPERATION_UPDATE  
		//------------------------------------------------------------------------------------------------
		// Se não for processamento pelo EAI (Mensagem Unica) não permite alterar os dados do cliente.
		//------------------------------------------------------------------------------------------------
		If !IsInCallStack("FWUMESSAGE") .And. oMdlSA1:GetValue("A1_ORIGEM") == "S1" .And. lVldInt
			Help(" ",1,"INTEGDEF",,STR0001+ oMdlSA1:GetValue("A1_ORIGEM"),3,0) //"Alteração não permitida, registro proveniente da integracao do "
			lValid := .F.
		EndIf
	EndIf

	If ( lValid .And. nOperation == MODEL_OPERATION_DELETE )
		
		//------------------------------------------------------------------------------------------------
		// Se não for processamento pelo EAI (Mensagem Unica) não permite alterar os dados do cliente.
		//------------------------------------------------------------------------------------------------
		If !IsInCallStack("FWUMESSAGE") .And. oMdlSA1:GetValue("A1_ORIGEM") == "S1" .And. lVldInt
			Help(" ",1,"INTEGDEF",,STR0002+ oMdlSA1:GetValue("A1_ORIGEM"),3,0) //"Exclusão não permitida, registro proveniente da integracao do "
			lValid := .F.
		EndIf
		
	EndIf 
	
	If ( lValid .And. ( nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE ) )
		
		//---------------------------------------------------------------
		// Validacao do campo A1_FILTRF.(UPDEST39) 
		// Verificar se a filial informada neste campo existe realmente.
		//---------------------------------------------------------------
		If lValid .And. UsaFilTrf()
			
			cFilTrf := oMdlSA1:GetValue("A1_FILTRF")
		
			If !Empty(cFilTrf)
				
				//---------------------------------------------------------------
				// Valida se a filial informada existe realmente   
				//---------------------------------------------------------------
				lValid := MtValidFil(cEmpAnt+cFilTrf)
				
				//---------------------------------------------------------------------
				// Verificar se nao existe outro cliente com a mesma filial associada.   
				//---------------------------------------------------------------------
				If lValid	
					
					cAliasTrf := GetNextAlias()
					
					BeginSql Alias cAliasTrf
						
						SELECT A1_FILTRF
							FROM %Table:SA1% SA1
								WHERE
									SA1.A1_FILIAL = %xFilial:SA1% AND 
									SA1.A1_FILTRF = %Exp:cFilTrf% AND
									SA1.%NotDel%
										
					EndSql
					
					If ( (cAliasTrf)->(!Eof()) .And. ( SA1->A1_COD <> M->A1_COD ) )
						Help("",1,"SAVALCLI",, STR0003 + SA1->A1_COD + STR0004 + SA1->A1_LOJA, 4, 11 ) //"Código: " / " - Loja: "
						lValid := .F.	
					EndIf	
				
				EndIf
				
			EndIf
			
		EndIf 
					
	EndIf
	//---------------------------------------------------------------
	// Valida se o código de Cliente e Loja existe
	//---------------------------------------------------------------
	If ( lValid .And. nOperation == MODEL_OPERATION_INSERT .And.;
		!Empty(oMdlSA1:GetValue("A1_COD")) .And. !Empty(oMdlSA1:GetValue("A1_LOJA")) .And.;
		!ExistChav("SA1",oMdlSA1:GetValue("A1_COD")+oMdlSA1:GetValue("A1_LOJA"),,"EXISTCLI") )
		lValid := .F.
	EndIf 

	//-----------------------------------------------------------------------------------------
	// Validações relacionadas aos endereços complementares do cliente (somente pessoa física)
	//-----------------------------------------------------------------------------------------
	If lValid .And. oModel:HasField("SA1MASTER", "A1_NOMEEND")
		If cPaisLoc $ 'ANG|EQU|HAI|RUS|PER|PTG' 
			cCpoTpP := "A1_TIPO"
		EndIf
		If !FwIsInCallStack("ExeSincSA1") .And. (A980PesFis(oMdlSA1) .Or. oMdlSA1:IsFieldUpdated(cCpoTpP))
			lValid := VlEndereco(oModel, @self:aModelSA1, self:lRotAutoCl)
		EndIf
	EndIf

Return lValid

//-------------------------------------------------------------------
/*/{Protheus.doc} BeforeTTS
Método responsável por executar regras de negócio genéricas do 
cadastro antes da transação do modelo de dados.

@type 		Método

@param 		oModel	,objeto	,Modelo de dados de Clientes.
@param 		cID		,caracter	,Identificador do sub-modelo.

@author 	Squad CRM / FAT
@version	12.1.17 / Superior
@since		25/05/2017 
/*/
//-------------------------------------------------------------------
Method BeforeTTS(oModel,cID) Class CRM980EventDEF
	Local lHistTab  	:= SuperGetMv("MV_HISTTAB",,.F.)
	Local oMdlSA1		:= oModel:GetModel("SA1MASTER")
	Local oStructSA1	:= oMdlSA1:GetStruct()
	Local dDataAlt 	:= Date()
	Local cHoraAlt 	:= Time()
	Local cFilialAIF	:= xFilial("AIF")
	Local cFilialSA1	:= xFilial("SA1")
	Local cCodigo		:= oMdlSA1:GetValue("A1_COD")
	Local cLoja		:= oMdlSA1:GetValue("A1_LOJA")
	Local aFields 	:= oStructSA1:GetFields()
	Local nOperation	:= oModel:GetOperation()
	Local nX			:= 0			
	
	If nOperation == MODEL_OPERATION_UPDATE	
		
		
		If lHistTab
			//--------------------------------------------------------------------------------
			// Cria o historico das alteracoes antes de gravar os novos dados do cliente.
			// Se deixa pra fazer depois de gravar, não tem como pegar os valores que estavam
			// nos campos antes da alteração
			//--------------------------------------------------------------------------------	
			For nX := 1 To Len( aFields )
				If oMdlSA1:IsFieldUpdated( aFields[nX][MODEL_FIELD_IDFIELD] ) .And. Len(FWSX3Util():GetFieldStruct(aFields[nX][MODEL_FIELD_IDFIELD]))>0
					MSGrvHist(cFilialAIF										,;			// Filial de AIF
					          cFilialSA1										,;			// Filial da tabela SA1
					          "SA1"											,;			// Tabela SA1
					          cCodigo											,;			// Codigo do cliente
					          cLoja											,;			// Loja do cliente
					          aFields[nX][MODEL_FIELD_IDFIELD]			,;			// Campo alterado
					          SA1->&(aFields[nX][MODEL_FIELD_IDFIELD])	,;			// Conteudo antes da alteracao
					          dDataAlt										,;			// Data da alteracao
					          cHoraAlt)													// Hora da alteracao	
				EndIf
			Next nX
		EndIf
		
	EndIf
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} InTTS
Método responsável por executar regras de negócio genéricas do
cadastro dentro da transação do modelo de dados.

@type 		Método

@param 		oModel	,objeto	,Modelo de dados de Clientes.
@param 		cID		,caracter	,Identificador do sub-modelo.

@author 	Squad CRM / FAT
@version	12.1.17 / Superior
@since		19/05/2017 
/*/
//-------------------------------------------------------------------
Method InTTS(oModel,cID) Class CRM980EventDEF
	
	Local nOperation	:= oModel:GetOperation()
	
	If nOperation == MODEL_OPERATION_DELETE 
	
		//--------------------------------------------------------------
		// Exclui a amarração com os contatos.
		//--------------------------------------------------------------
		FtContato("SA1",SA1->( Recno() ),2,,3) 
		
		//--------------------------------------------------------------
		// Exclui a amarração com os conhecimentos.
		//--------------------------------------------------------------
		MsDocument("SA1",SA1->( RecNo() ),2,,3) 
		
		//--------------------------------------------------------------
		// Exclui a regra da Margem Minima.
		//--------------------------------------------------------------
		FT101Exc(SA1->A1_COD,SA1->A1_LOJA)
	EndIf 
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} AfterTTS
Método responsável por executar regras de negócio genéricas do
cadastro depois da transação do modelo de dados.

@type 		Método

@param 		oModel	,objeto	,Modelo de dados de Clientes.
@param 		cID		,caracter	,Identificador do sub-modelo.

@author 	Squad CRM / FAT
@version	12.1.17 / Superior
@since		19/05/2017 
/*/
//-------------------------------------------------------------------
Method AfterTTS(oModel,cID) Class CRM980EventDEF
	Local cEventID	:= ""
	Local cMessagem	:= ""
	Local nOperation	:= oModel:GetOperation()
	
	If nOperation == MODEL_OPERATION_INSERT
		//--------------------------------------------------------------
		// Event Viewer - Envia e-mail ou RSS na inclusao de clientes.
		//--------------------------------------------------------------
		cEventID  := "032" //Inclusao de cliente
		cMessagem := STR0005 + SA1->A1_COD + "/" + SA1->A1_LOJA + Chr(13) + Chr(10) + STR0006 + SA1->A1_NOME + Chr(13) + Chr(10) + STR0007 + UsrFullName() + "." //"Inclusão do cliente de Código / Loja: "/"Razão Social: "/"Incluído no sistema pelo usuário:" / "Inclusão de cliente"
		FATPDLogUser('AFTERTTS')	// Log de Acesso LGPD
		EventInsert(FW_EV_CHANEL_ENVIRONMENT,FW_EV_CATEGORY_MODULES,cEventID,FW_EV_LEVEL_INFO,""/*cCargo*/,STR0008,cMessagem,.T./*lPublic*/)	
	EndIf

	If oModel:HasField("SA1MASTER", "A1_NOMEEND") // Endereços complementares
		//--------------------------------------------------------------------------------------------------------------------------------
		// Replica as informações que não são de endereço enviadas na ExecAuto do registro "Filho" (endereço) para o registro "Principal"
		//--------------------------------------------------------------------------------------------------------------------------------
		If (nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE) .And. self:lRotAutoCl
			If !Empty(oModel:GetValue("SA1MASTER", "A1_NOMEEND")) .And. !FwIsInCallStack("RepInfoEnd") // Inclusão/Alteração de registro de endereço (filho)
				RepInfoEnd(oModel)
			EndIf
		EndIf

		//--------------------------------------------------------------------------------------------------------------
		// Endereços Complementares - Commit de cada linha do grid de endereços complementares, 
		// onde cada linha da grid é um registro na SA1, para garantir a integridade dos dados durante a sincronização.
		//--------------------------------------------------------------------------------------------------------------
		GrvSincSA1(self:aModelSA1)
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Destroy
Destrutor da classe

@type 		Método

@author 	Squad CRM / FAT
@since		30/06/2026
/*/
//-------------------------------------------------------------------
Method Destroy() Class CRM980EventDEF

	aSize(self:aModelSA1, 0)
	self:aModelSA1 := Nil

Return Nil

//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDLogUser
    @description
    Realiza o log dos dados acessados, de acordo com as informações enviadas, 
    quando a regra de auditoria de rotinas com campos sensíveis ou pessoais estiver habilitada
	Remover essa função quando não houver releases menor que 12.1.27

   @type  Function
    @sample FATPDLogUser(cFunction, nOpc)
    @author Squad CRM & Faturamento
    @since 06/01/2020
    @version P12
    @param cFunction, Caracter, Rotina que será utilizada no log das tabelas
    @param nOpc, Numerico, Opção atribuída a função em execução - Default=0

    @return lRet, Logico, Retorna se o log dos dados foi executado. 
    Caso o log esteja desligado ou a melhoria não esteja aplicada, também retorna falso.

/*/
//-----------------------------------------------------------------------------
Static Function FATPDLogUser(cFunction, nOpc)

	Local lRet := .F.

	If FATPDActive()
		lRet := FTPDLogUser(cFunction, nOpc)
	EndIf 

Return lRet

//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDActive
    @description
    Função que verifica se a melhoria de Dados Protegidos existe.

    @type  Function
    @sample FATPDActive()
    @author Squad CRM & Faturamento
    @since 17/12/2019
    @version P12    
    @return lRet, Logico, Indica se o sistema trabalha com Dados Protegidos
/*/
//-----------------------------------------------------------------------------
Static Function FATPDActive()

    Static _lFTPDActive := Nil
  
    If _lFTPDActive == Nil
        _lFTPDActive := ( GetRpoRelease() >= "12.1.027" .Or. !Empty(GetApoInfo("FATCRMPD.PRW")) )  
    Endif

Return _lFTPDActive  

//-------------------------------------------------------------------
/*/{Protheus.doc} VlEndereco
Faz as validações (ModelPosValid) relacionadas a sessão de endereços
complementares do cliente

@type       Function
@param      oModel, object, Modelo de dados de Clientes.
@param      aModelSA1 , Array  , Array com os modelos salvos
@param      lRotAutoCl, Logical, Indica se a chamada foi via rotina automática
@return     lValid, logical, Indica se os dados de endereços complementares
                             são válidos

@author     Squad CRM / FAT
@version    12.1.2610 / Superior
@since      30/06/2026
/*/
//-------------------------------------------------------------------
Static Function VlEndereco(oModel, aModelSA1, lRotAutoCl)
	Local lValid     as Logical
	Local lPessoaF   as Logical
	Local lLinEndVld as Logical
	Local lDocGener  as Logical
	Local lAltCGC    as Logical
	Local cCGC       as Character
	Local cNomeEnd   as Character
	Local cTitNomEnd as Character
	Local cProblema  as Character
	Local cSolucao   as Character
	Local cCod       as Character
	Local cLoja      as Character
	Local cFilSA1    as Character
	Local oMdlEnd    as Object
	Local oMdlSA1    as Object
	Local nQtdEnd    as Numeric
	Local nOperation as Numeric
	Local nEnd       as Numeric
	Local aRetTemp   as Array
	Local aAreaSA1   as Array

	Default oModel     := Nil
	Default aModelSA1  := {}
	Default lRotAutoCl := .F.

	If oModel <> Nil

		lValid     := .T.
		lLinEndVld := .F.
		nOperation := oModel:GetOperation()
		oMdlSA1    := oModel:GetModel("SA1MASTER")
		cCGC       := oMdlSA1:GetValue("A1_CGC")
		lPessoaF   := A980PesFis(oMdlSA1) // Pessoa física //troncar nome da função e ajustar a proteção
		lDocGener  := .F. // Documentos genéricos do Mercado Internacional

		If lPessoaF .And. (nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE) // Inclusão ou alteração

			// Verifica se é inclusão/alteração via rotina automática, se sim...
			// - Preenche o A1_NOMEEND caso esteja vazio
			If lRotAutoCl
				lValid := SetEndComp(oMdlSA1, nOperation)
			EndIf
			
			If lValid
				oMdlEnd    := oModel:GetModel("SA1ENDCOMP")
				nQtdEnd    := oMdlEnd:GetQtdLine()
				cNomeEnd   := oMdlSA1:GetValue("A1_NOMEEND")
				cTitNomEnd := AllTrim(FwX3Titulo("A1_NOMEEND"))

				// Verifica se contém linhas válidas no grid de endereços
				If !oMdlEnd:IsEmpty()
					For nEnd := 1 To nQtdEnd
						If !oMdlEnd:IsDeleted(nEnd) .And. (!Empty(oMdlEnd:GetValue("A1_NOMEEND", nEnd)) .Or. !Empty(oMdlEnd:GetValue("A1_END", nEnd)))
							lLinEndVld := .T.
							Exit
						EndIf
					Next nEnd
				EndIf

				// Valida se o "Nome do endereço" do registro principal está vazio
				If lValid .And. Empty(cNomeEnd) .And. lLinEndVld .And. !Empty(cCGC)
					lValid    := .F.
					cProblema := I18n(STR0015, {cTitNomEnd}) // "O campo '#1' (A1_NOMEEND) não foi preenchido no formulário principal e não será possível identificar e diferenciar este endereço."
					cSolucao  := I18n(STR0016, {cTitNomEnd}) // "Preencha o campo '#1' (A1_NOMEEND) no formulário principal para realizar a identificação e diferenciação do endereço correspondente."
					Help("", 1, "ENDCOMPL",, cProblema, 1,,,,,,, {cSolucao})
				EndIf

				// Valida se o grid de endereços tem linhas válidas e se o A1_CGC está vazio (somente pessoa física)
				If lValid .And. Empty(cCGC) .And. lLinEndVld
					lValid := .F.
					cProblema := STR0011 // "Para utilizar a funcionalidade de endereços complementares, o cliente deve ter CPF identificado."
					cSolucao  := STR0012 // "Preencha o campo CPF ou exclua os endereços complementares."
					Help("", 1, "ENDCOMPL",, cProblema, 1,,,,,,, {cSolucao})
				EndIf

				// Verifica se o CGC preenchido faz parte das exceções de documentos genéricos do mercado internacional
				If cPaisLoc <> "BRA"
					If Alltrim(cCGC) $ '888888015|666666016|444444017|999999010|777777010|XEXX010101000|XAXX010101000|222222222222|444444460|00000000000' .Or. ;
					   (cPaisLoc == "ARG" .And. SubStr(cCGC, 1, 2) $ '50|51|55')
						lDocGener := .T.
					EndIf
				EndIf

				// Se for cópia do registro, força o valid do campo A1_CGC, pois na cópia o campo A1_CGC não é validado automaticamente.
				If lValid .And. oModel:IsCopy()
					lValid := oMdlSA1:LoadValue("A1_CGC", "") .And. oMdlSA1:SetValue("A1_CGC", cCGC)
				EndIf

				// Valida se o "Nome do endereço" do cliente principal já existe em algum registro no grid de endereços complementares
				If lValid .And. !Empty(cCGC)
					cCod    := oMdlSA1:GetValue("A1_COD")
					cLoja   := oMdlSA1:GetValue("A1_LOJA")
					lAltCGC := oMdlSA1:IsFieldUpdated("A1_CGC") // Verifica se o campo A1_CGC foi alterado, para não validar a duplicidade do CPF/CNPJ com ele mesmo
					cFilSA1 := xFilial("SA1")

					aAreaSA1 := SA1->(FWGetArea())

					SA1->(dbSetOrder(3)) // A1_FILIAL + A1_CGC
					If SA1->(dbSeek(cFilSA1 + cCGC))
						While !SA1->(Eof()) .And. SA1->A1_FILIAL == cFilSA1 .And. SA1->A1_CGC == cCGC
							// Verifica se já existe na base
							If SA1->A1_COD != cCod .Or. SA1->A1_LOJA != cLoja
								If lValid .And. !lRotAutoCl .And. !lDocGener .And. lAltCGC
									lValid    := .F.
									cProblema := STR0023 // "O CPF informado já está cadastrado para outro cliente."
									cSolucao  := STR0024 // "Informe um CPF/CNPJ diferente ou verifique o cadastro existente."
									Help("", 1, "ENDCOMPL",, cProblema, 1,,,,,,, {cSolucao})
									Exit
								EndIf

								If !Empty(cNomeEnd) .And. AllTrim(SA1->A1_NOMEEND) == AllTrim(cNomeEnd)
									lValid := .F.
									cProblema := I18n(STR0017, {cTitNomEnd}) // "O campo '#1' (A1_NOMEEND) foi preenchido com o mesmo nome de um dos endereços do cliente."
									cSolucao  := I18n(STR0018, {cTitNomEnd, AllTrim(cNomeEnd)}) // "Preencha o campo '#1' (A1_NOMEEND) com um nome diferente de '#2'."
									Help("", 1, "ENDCOMPL",, cProblema, 1,,,,,,, {cSolucao})
									Exit
								EndIf
							EndIf
							SA1->(dbSkip())
						EndDo
					EndIf
					FwRestArea(aAreaSA1)
					FwFreeArray(aAreaSA1)

					// Verifica também se não tem duplicidade do lado da grid
					If lValid .And. lLinEndVld
						For nEnd := 1 To nQtdEnd
							If !oMdlEnd:IsDeleted(nEnd) .And. AllTrim(Upper(oMdlEnd:GetValue("A1_NOMEEND", nEnd))) == AllTrim(Upper(cNomeEnd))
								lValid    := .F.
								cProblema := I18n(STR0019, {cTitNomEnd}) // "O campo '#1' (A1_NOMEEND) foi preenchido no formulário principal com o mesmo nome de um dos endereços preenchidos na sessão 'Endereços Complementares'."
								cSolucao  := I18n(STR0020, {AllTrim(cNomeEnd)}) // "Verifique os endereços com o nome '#1' e remova a duplicidade."
								Help("", 1, "ENDCOMPL",, cProblema, 1,,,,,,, {cSolucao})
								Exit
							EndIf
						Next nEnd
					EndIf
				EndIf
			EndIf
		EndIf
		
		//----------------------------------------------------------------------------------------
		// Endereços Complementares - Carga dos dados da grid de endereços
		// Cria os modelos (MVC) para incluir cada endereço de forma individual e já deixa
		// os modelos válidos no self:aModelSA1, para que sejam commitados nos eventos de commit
		//----------------------------------------------------------------------------------------
		If lValid
			aRetTemp := VldSincSA1(oModel) // Recebe o array com os dados da grid e o status da validação do submodelo de Endereços Complementares (SA1ENDCOMP)
			lValid := aRetTemp[1] // Atualiza o status de retorno com base no resultado da validação
			If lValid
				aModelSA1 := aRetTemp[2] // Guarda o model atualizado da grid de endereços complementares para commit
			EndIf
		EndIf
	EndIf

Return lValid

//-------------------------------------------------------------------
/*/{Protheus.doc} RepInfoEnd
Faz a replica das informações da sessão de endereços complementares
para o registro principal quando o registro de endereço for 
incluído/alterado via rotina automática (ExecAuto)

@type       Function
@param      oModel, objeto, Modelo de dados de Clientes.

@author     Squad CRM / FAT
@version    12.1.2610 / Superior
@since      30/06/2026
/*/
//-------------------------------------------------------------------
Static Function RepInfoEnd(oModel)
	Local cCGC      as Character
	Local cCod      as Character
	Local cLoja     as Character
	Local cField    as Character
	Local oMldIrmao as Object
	Local oMdlSA1   as Object
	Local aAreaSA1  as Array
	Local aExcecoes as Array
	Local aFields   as Array
	Local nMdl      as Numeric

	Default oModel := Nil

	If oModel <> Nil

		oMdlSA1 := oModel:GetModel("SA1MASTER")
		cCGC    := oMdlSA1:GetValue("A1_CGC")
		cCod    := oMdlSA1:GetValue("A1_COD")
		cLoja   := oMdlSA1:GetValue("A1_LOJA")

		//--------------------------------------------------------------------------------------------------
		// Se for rotina automática, realiza o espelhamento dos dados do cliente para os irmãos (mesmo CPF)
		//--------------------------------------------------------------------------------------------------
		If !Empty(cCGC) .And. A980PesFis(oMdlSA1)

			aFields   := oMdlSA1:GetStruct():GetFields()

			// Array de exceções: Campos de endereço e chaves não devem ser replicados
			aExcecoes := {"A1_COD", "A1_LOJA", "A1_CGC", "A1_END", "A1_BAIRRO", "A1_MUN", "A1_EST", "A1_CEP", "A1_COMPLEM", "A1_COD_MUN", "A1_NOMEEND", "A1_CONTATO", "A1_MSBLQL"}

			AddFldPE(@aExcecoes) // Adiciona campos customizados do PE para a grid de Endereços Complementares

			aAreaSA1 := SA1->(FWGetArea())
			SA1->(dbSetOrder(3)) // A1_FILIAL + A1_CGC

			// Posiciona no registro pai (cliente principal)
			If SA1->(dbSeek(xFilial("SA1") + cCGC))
				While !SA1->(Eof()) .And. SA1->A1_FILIAL == xFilial("SA1") .And. SA1->A1_CGC == cCGC
					
					// Se for um registro irmão (diferente do que está sendo editado na memória)
					If SA1->A1_COD + SA1->A1_LOJA != cCod + cLoja
						
						// Realiza o espelhamento para o registro irmão (apenas campos que não estão no array aExcecoes)
						oMldIrmao := FWLoadModel("CRMA980")
						oMldIrmao:SetOperation(MODEL_OPERATION_UPDATE)
						oMldIrmao:Activate()

						For nMdl := 1 To Len(aFields)
							cField := aFields[nMdl][MODEL_FIELD_IDFIELD]

							If oMdlSA1:IsFieldUpdated(cField)
								If aScan(aExcecoes, {|x| Alltrim(x) == cField}) == 0
									oMldIrmao:GetModel("SA1MASTER"):LoadValue(cField, oMdlSA1:GetValue(cField))
								EndIf
							EndIf
						Next nMdl

						// Valida e Comita o modelo do registro irmão
						If oMldIrmao:VldData()
							oMldIrmao:CommitData()
						EndIf

						oMldIrmao:DeActivate()
						oMldIrmao:Destroy()
						
					EndIf
					
					SA1->(dbSkip())
				EndDo
			EndIf

			FWRestArea(aAreaSA1)
			FwFreeArray(aAreaSA1)
			FwFreeArray(aExcecoes)
		EndIf
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GrvSincSA1
Commit de cada linha do grid de endereços complementares, 
onde cada linha da grid é um registro na SA1, para garantir 
a integridade dos dados durante a sincronização.

@type       Function
@param      aModelSA1, Array, Array com os modelos de SA1 a serem commitados
@author     Squad CRM / FAT
@version    12.1.2610 / Superior
@since      26/06/2026
/*/
//-------------------------------------------------------------------
Static Function GrvSincSA1(aModelSA1)
	Local nMdl     as Numeric
	Local nQtdMdls as Numeric
	Local aAreaSA1 as Array

	Default aModelSA1 := {}

	If !Empty(aModelSA1)
		aAreaSA1 := SA1->(FWGetArea())
		nQtdMdls := Len(aModelSA1)

		For nMdl := 1 To nQtdMdls
			aModelSA1[nMdl]:CommitData()
			aModelSA1[nMdl]:DeActivate()
			aModelSA1[nMdl]:Destroy()
		Next
		FWRestArea(aAreaSA1)
		aModelSA1 := {}
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} VldSincSA1
Atualiza os registros da grid de endereços complementares (SA1ENDCOMP) 
com base na sincronização com a tabela SA1 (Cadastro de Clientes).

@type    Function
@param   oModel, objeto, Modelo de dados de Clientes.
@return  {lRet, aModelSA1}, array, Indica sucesso da sincronizacao e 
                                   Array com os modelos de SA1 a serem commitados posteriormente

@author  cruz.rafael | Protheus Backoffice Retail
@since   10/06/2026
@version 1.0
*/
//-------------------------------------------------------------------
Static Function VldSincSA1(oModel)
	Local lRet       as Logical
	Local lDelete    as Logical
	Local lExist     as Logical
	Local lOpcDelete as Logical
	Local lAtuEnd    as Logical
	Local lNewLine   as Logical
	Local lGrava     as Logical
	Local aModelSA1  as Array
	Local aFieldsSA1 as Array
	Local aFieldsEnd as Array
	Local nField     as Numeric
	Local nQtdLinhas as Numeric
	Local nX         as Numeric
	Local cFilialSA1 as Character
	Local cCodigo    as Character
	Local cLoja      as Character
	Local cField     as Character
	Local oMdlSA1    as Object
	Local oGridEnd   as Object
	Local oMdlChild  as Object

	Default oModel := Nil

	lRet      := .T.
	aModelSA1 := {}

	If oModel <> Nil

		// Atribuição de Valores das Variáveis
		oMdlSA1    := oModel:GetModel("SA1MASTER")
		oGridEnd   := oModel:GetModel("SA1ENDCOMP")
		oMdlChild  := oModel:GetModel("AI0CHILD")
		aFieldsSA1 := oMdlSA1:GetStruct():GetFields()
		aFieldsEnd := {"A1_NOMEEND", "A1_END", "A1_BAIRRO", "A1_EST", "A1_COD_MUN", "A1_CEP", "A1_MUN", "A1_COMPLEM", "A1_CONTATO", "A1_COD", "A1_LOJA", "A1_MSBLQL"}

		AddFldPE(@aFieldsEnd) // Adiciona campos customizados do PE para a grid de Endereços Complementares

		cFilialSA1 := FWxFilial("SA1")
		cCodigo    := oMdlSA1:GetValue("A1_COD")
		cLoja      := oMdlSA1:GetValue("A1_LOJA")

		nQtdLinhas := oGridEnd:GetQtdLine()
		lOpcDelete := oModel:GetOperation() == MODEL_OPERATION_DELETE // Indica se é exclusão do registro principal
		lAtuEnd    := oModel:GetOperation() == MODEL_OPERATION_INSERT .Or. oMdlSA1:IsModified() .Or. (Type("oMdlChild") <> "U" .AND. oMdlChild:IsModified()) // Indica se deve atualizar os endereços complementares, caso o registro principal seja inserido ou atualizado

		// Processa grid de endereços complementares somente se houver linhas e se a grid não estiver vazia
		If nQtdLinhas > 0 .And. !oGridEnd:IsEmpty()

			For nX := 1 To nQtdLinhas // Loop para processar cada linha da grid de endereços complementares (SA1ENDCOMP)
				lGrava  := .T.
				If !lOpcDelete .And. !oGridEnd:IsDeleted(nX)

					lDelete := .F.
					lNewLine := oGridEnd:IsInserted(nX)
					oGridEnd:Goline(nX)

					// Se o registro principal foi inserido ou atualizado, ou se a linha da grid foi inserida, 
					// vai atualizar os valores da linha da grid com base no modelo da SA1
					If lAtuEnd .Or. lNewLine
						For nField := 1 To Len(aFieldsSA1) // Atribuição dos valores do modelo da SA1 para os campos da grid de endereços complementares, utilizando o array de campos para mapear os dados
							cField := aFieldsSA1[nField][MODEL_FIELD_IDFIELD]
							If !aFieldsSA1[nField][MODEL_FIELD_VIRTUAL] .And. (lNewLine .Or. oMdlSA1:IsFieldUpdated(cField))
								If aScan(aFieldsEnd, {|x| Alltrim(x) == cField}) == 0
									oGridEnd:LoadValue(cField, oMdlSA1:GetValue(cField))
								EndIf
							EndIf
						Next nField
					Else // Se não houve atualização do registro principal nem na linha do endereço, ignora a linha e vai para a próxima
						If !oGridEnd:IsUpdated(nX)
							Loop
						EndIf
					EndIf

					// Para novos endereços, coloca o mesmo A1_COD do registro principal, e pega o próximo número livre para preencher o A1_LOJA
					// para evitar criar registros duplicados na SA1 durante a sincronização
					If Empty(oGridEnd:GetValue("A1_COD", nX)) .And. Empty(oGridEnd:GetValue("A1_LOJA", nX))
						lExist := .T.
						While lExist
							cLoja  := Soma1(cLoja)
							lExist := SA1->(MsSeek(cFilialSA1 + cCodigo + cLoja))
						EndDo

						oGridEnd:LoadValue("A1_COD", cCodigo) // Gravação do Campo Código do Cliente para amarrar o endereço complementar
						oGridEnd:LoadValue("A1_LOJA", cLoja)  // Gravação do Campo Loja para amarrar os endereços complementares
					Else
						cLoja := oGridEnd:GetValue("A1_LOJA", nX)
					EndIf
				Else // Exclusão de endereço
					If Empty(oGridEnd:GetValue("A1_LOJA", nX))
						lGrava := .F.
					Else
						cLoja  := oGridEnd:GetValue("A1_LOJA", nX)
					EndIf
					lDelete := .T.
				EndIf

				If lGrava
					// Chama a função de inclusão/atualização/exclusão para cada linha da grid de endereços complementares
					lRet := ExeSincSA1(cFilialSA1, cCodigo, cLoja, lDelete, oGridEnd, oMdlChild, nX, aFieldsSA1, @aModelSA1)
					If !lRet
						Exit
					EndIf
				EndIf
			Next nX
		EndIf
	EndIf

	FwFreeArray(aFieldsEnd)

Return {lRet, aModelSA1}

//-------------------------------------------------------------------
/*/{Protheus.doc} ExeSincSA1
Realiza a inclusão, atualização ou exclusão de registros na SA1 (Cadastro de Clientes)
com base na grid de endereços complementares.

@type   Function
@param  cFil     , character, Código da filial
@param  cCodigo  , character, Código do cliente
@param  cLoja    , character, Código da loja
@param  lDelete  , logical  , Flag indicando se a operação é de exclusão (true para delete, false para insert/update)
@param  oSubModel, object   , Objeto do sub-modelo da grid de endereços complementares (SA1ENDCOMP)
@param  nLine    , numeric  , Número da linha da grid de endereços complementares sendo processada
@param  aFields  , Array    , Estrutura dos campos do modelo de dados, utilizado para mapear os campos da grid para o model da SA1
@param  aModelSA1, Array    , Para armazenar os modelos de SA1 a serem commitados posteriormente
@return lValid   , logical  , Indica sucesso da sincronizacao

@author  cruz.rafael | Protheus Backoffice Retail
@since   10/06/2026
@version 1.0
*/
//-------------------------------------------------------------------
Static Function ExeSincSA1(cFil, cCodigo, cLoja, lDelete, oSubModel, oMdlChild, nLine, aFields, aModelSA1)
	Local lValid    as Logical
	Local aAreaSA1  as Array
	Local aAuxAI0   as Array
	Local nField    as Numeric
	Local oModel    as Object
	Local cProblema as Character
	Local cSolucao  as Character

	Default cFil      := ""
	Default cCodigo   := ""
	Default cLoja     := ""
	Default lDelete   := .F.
	Default oSubModel := Nil
	Default oMdlChild := Nil
	Default nLine     := 0
	Default aFields   := {}
	Default aModelSA1 := {}

	lValid    := .T.

	If !Empty(cCodigo) .And. !Empty(cLoja) .And. Len(aFields) > 0

		aAuxAI0 := {}
		If oMdlChild <> NIL .And. (oMdlChild:IsModified() .Or. oSubModel:IsInserted(nLine))
			aAuxAI0 := oMdlChild:GetStruct():GetFields()
		Endif

		aAreaSA1 := SA1->(FwGetArea())
		SA1->(dbSetOrder(1)) // A1_FILIAL + A1_COD + A1_LOJA

		If SA1->(dbSeek(cFil + cCodigo + cLoja))
			If lDelete
				oModel := FWLoadModel('CRMA980')
				oModel:SetOperation(MODEL_OPERATION_DELETE)
				oModel:Activate()
			Else
				oModel := FWLoadModel('CRMA980')
				oModel:SetOperation(MODEL_OPERATION_UPDATE)
				oModel:Activate()

				For nField := 1 To Len(aFields)
					If !aFields[nField][MODEL_FIELD_VIRTUAL] .And. oSubModel:IsFieldUpdated(aFields[nField][MODEL_FIELD_IDFIELD]) .And. oModel:GetModel("SA1MASTER"):GetStruct():HasField(aFields[nField][MODEL_FIELD_IDFIELD])
						oModel:GetModel("SA1MASTER"):LoadValue(aFields[nField][MODEL_FIELD_IDFIELD], oSubModel:GetValue(aFields[nField][MODEL_FIELD_IDFIELD], nLine))
					EndIf
				Next nField

				If Len(aAuxAI0)>0
					For nField := 1 To Len(aAuxAI0)
						If !aAuxAI0[nField][MODEL_FIELD_VIRTUAL] .And. oMdlChild:IsFieldUpdated(aAuxAI0[nField][MODEL_FIELD_IDFIELD])
							oModel:GetModel("AI0CHILD"):LoadValue(aAuxAI0[nField][MODEL_FIELD_IDFIELD], oMdlChild:GetValue(aAuxAI0[nField][MODEL_FIELD_IDFIELD]))
						EndIf
					Next nField
				EndIF
			EndIf
		ElseIf !lDelete
			// Inclusão de cada linha da grid de endereços complementares como um novo registro na SA1, mantendo os dados do cliente e amarrando pelo código e loja
			oModel := FWLoadModel('CRMA980')
			oModel:SetOperation(MODEL_OPERATION_INSERT)
			oModel:Activate()

			For nField := 1 To Len(aFields)
				If !aFields[nField][MODEL_FIELD_VIRTUAL] .And. oModel:GetModel("SA1MASTER"):GetStruct():HasField(aFields[nField][MODEL_FIELD_IDFIELD])
					oModel:GetModel("SA1MASTER"):LoadValue(aFields[nField][MODEL_FIELD_IDFIELD], oSubModel:GetValue(aFields[nField][MODEL_FIELD_IDFIELD], nLine))
				EndIf
			Next nField

			If Len(aAuxAI0)>0
				For nField := 1 To Len(aAuxAI0)
					If !aAuxAI0[nField][MODEL_FIELD_VIRTUAL]
						oModel:GetModel("AI0CHILD"):LoadValue(aAuxAI0[nField][MODEL_FIELD_IDFIELD], oMdlChild:GetValue(aAuxAI0[nField][MODEL_FIELD_IDFIELD]))
					EndIf
				Next nField
			EndIF
		EndIf

		FwRestArea(aAreaSA1)
		FwFreeArray(aAreaSA1)

		If oModel <> Nil
			If oModel:VldData()
				Aadd(aModelSA1, oModel) // Se válido, adiciona o model atualizado da SA1 para commit posterior
			Else
				cProblema := cValToChar(oModel:GetErrorMessage()[5]) + ' - '
				cProblema += cValToChar(oModel:GetErrorMessage()[6])
				cSolucao  := cValToChar(oModel:GetErrorMessage()[7])
				lValid    := .F.
				aModelSA1 := {}

				Help('', 1, '', ProcName(1), cProblema, 1,,,,,,, {cSolucao})
			EndIf
		EndIf
	EndIf

Return lValid

//-------------------------------------------------------------------
/*/{Protheus.doc} SetEndComp
Para execuções via rotina automática (ExecAuto), caso o campo
A1_NOMEEND não seja enviado:
- Preenche o A1_NOMEEND caso esteja vazio

@type       Function
@param      oMdlSA1, object, Modelo de dados de Clientes.
@param      nOperation, numeric, Operação do modelo (3=Inclusão;4=Alteração)

@author     Squad CRM / FAT
@version    12.1.2610 / Superior
@since      26/06/2026
/*/
//-------------------------------------------------------------------
Static Function SetEndComp(oMdlSA1, nOperation)
	Local cCGC        as Character
	Local cFilSA1     as Character
	Local aAreaSA1    as Array
	Local nCountEnd   as Numeric
	Local lNmEndVazio as Logical

	Default oMdlSA1    := Nil
	Default nOperation := 0
	
	If oMdlSA1 <> Nil .And. nOperation > 0
	
		cCGC := oMdlSA1:GetValue("A1_CGC")

		If !Empty(cCGC)
			lNmEndVazio := Empty(oMdlSA1:GetValue("A1_NOMEEND")) // Nome Endereço está vazio
			cFilSA1     := xFilial("SA1")

			If nOperation == MODEL_OPERATION_INSERT
				aAreaSA1 := SA1->(FWGetArea())
				SA1->(dbSetOrder(3)) // A1_FILIAL + A1_CGC

				// Se o CPF já existe na base, força o novo registro como "Endereço Complementar"
				If SA1->(dbSeek(cFilSA1 + cCGC))
					// CPF já cadastrado e A1_NOMEEND vazio
					If lNmEndVazio
						nCountEnd := 0

						// Conta quantos registros existem com este CPF
						While !SA1->(Eof()) .And. SA1->A1_FILIAL == cFilSA1 .And. SA1->A1_CGC == cCGC
							nCountEnd++
							SA1->(dbSkip())
						EndDo

						// Preenche com "Entrega N"
						oMdlSA1:SetValue("A1_NOMEEND", STR0021 + cValToChar(nCountEnd)) // "Entrega "
					EndIf
				ElseIf lNmEndVazio // Cliente com novo CPF e A1_NOMEEND vazio
					// Preenche com "Principal"
					oMdlSA1:SetValue("A1_NOMEEND", STR0022) // "Principal"
				EndIf

				FWRestArea(aAreaSA1)
				FwFreeArray(aAreaSA1)

			Else // Operação de ALTERAÇÃO
				// Se tentar "Limpar" o campo de nome do endereço, preenche novamente com o valor original
				If lNmEndVazio
					oMdlSA1:SetValue("A1_NOMEEND", SA1->A1_NOMEEND)
				EndIf
			EndIf
		EndIf
	EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} AddFldPE
Adiciona os campos enviados pelo PE C980ENDC no array de campos
do grid de endereços complementares enviado por parâmetro (referência)

@type       Function
@param      aFieldsEnd, array, Array de campos que serão exibidos no 
                               grid de endereços complementares

@author     Squad CRM / FAT
@version    12.1.2610 / Superior
@since      01/07/2026
/*/
//-------------------------------------------------------------------
Static Function AddFldPE(aFieldsEnd)
	Local cFieldsPE as Character
	Local aFieldsPE as Array
	Local nField    as Numeric

	Default aFieldsEnd := {}

	If ExistBlock("C980ENDC") // Ponto de entrada de campos adicionais para a grid complementar
		cFieldsPE := ExecBlock("C980ENDC", .F., .F.)
		If ValType(cFieldsPE) == "C"
			aFieldsPE := StrTokarr(cFieldsPE, "|")
			For nField := 1 To Len(aFieldsPE)
				If !Empty(Alltrim(aFieldsPE[nField]))
					AAdd(aFieldsEnd, Alltrim(aFieldsPE[nField]))
				EndIf
			Next nField
		EndIf
	EndIf

Return Nil
//-------------------------------------------------------------------
/*{Protheus.doc} A980PesFis
Função para obter informações do Tipo de Pessoa (Física/Jurídica) do cliente
 para validar a regra de negócio para o Mercado Internacional.

@author  Jesus S. Junior | Protheus Retail
@since   13/07/2026
@version 1.0
@return  Lógico, Indica se o cliente é pessoa física (true) ou jurídica (false)
*/
//-------------------------------------------------------------------
Function A980PesFis(oModel)
Local lRet     := .F.
Local cTipo    := ""
Local cPessoa  := ""

Default oModel := Nil

If oModel <> Nil
	cTipo   := oModel:GetValue("A1_TIPO")
Else
	cTipo   := M->A1_TIPO
EndIf

If cPaisLoc == 'PER'
	lRet := cTipo == '2'
ElseIf cPaisLoc $ 'ANG|EQU|HAI|RUS'
	lRet := cTipo == '1'
ElseIf cPaisLoc == 'PTG'
	lRet := cTipo $ '1|3'
Else
	If oModel <> Nil
		cPessoa := oModel:GetValue("A1_PESSOA")
	Else
		cPessoa := M->A1_PESSOA
	EndIf
	lRet := cPessoa == 'F'
EndIf

Return lRet
