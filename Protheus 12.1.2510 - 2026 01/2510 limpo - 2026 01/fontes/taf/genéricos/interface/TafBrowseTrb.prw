#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TAFBROWSETRB.CH"        

/*/{Protheus.doc} TafBrowseTrb
Classe para facilitar a construção do objeto FWMBrowse utilizando arquivo 
de Trabalho
@type class
@author Evandro dos Santos O. Teixeira
@since 24/07/2016
@version 1.0
@example (Ver implementação nos fontes TAFTICKET e TafClassMonTicket)
@obs CLASSE ABSTRATA, não instanciar.
/*/
Class TafBrowseTrb 
	   	
	Data aCampos	
	Data aIndice	
	Data lCria			
	Data cArqTrb	
	Data cAliasTrb
	Data aIndTrab		
	Data cQuery		
	Data oBrowse		
	Data aFiltro		
	Data cVarBrowse	
	Data lTempInDb	
	Data oTempTable	
	Data nRows				
	Data cErro			
	
	//Metodos Obrigatórios antes do Activate
	Method New(aCampos,lCria) Constructor
	Method SetOwner(oOwner)
	Method SetArea(lFechaArea,cDriver,cQuery,lOutConex,lSomenteLeitura)	
	Method Activate()
	
	//Metodo opcionais 
	Method SetCampos(aCampos)
	Method CreateTrb(lCria)
	Method SetFiltro(lFiltro)
	Method SetIndice(aIndice,lPesq)
	Method SetDescription(cDescricao)
	Method SetMenuDef(cMenu)
	Method DisableDetails()
	Method SetProfileID(cId)
	Method AddButton(cName,bExec)
	Method Refresh()
	Method RefazDadosTrb(lSetArea) 
	Method GetNameStatus(cStatus)
	Method LimpaTrb()
	Method SetWalkThru(lHabilita)
	Method SetAmbiente(lHabilita)
	Method CreateTabInDb()
	Method EraseTableTemp()


	//Metodos auxiliares da classe
	Method SetIndiceTrb(cExpress,cFiltro,xOrdem,cMens,lMostra)	
	Method SetCollumns()
	Method PreencheTrb()
	
	/*Criar os seguintes métodos nas Sub Classes:
	Method CreateQry()
	Method CreateFields()*/
	
EndClass

/*/{Protheus.doc} New
Metodo Construtor
@type Method

@param - aCampos 		- Array com os campos utilizados tanto na browse 
						quanto no arquivo de trabalho. (opcional)
@param - lCria 		- Determina que o browse vai obrigatoriamente utilizar
					 	um arquivo de trabalho com estrutura (opcional)
@param - cVarBrowse 	- Nome utilizado na criação do objeto FWMBrowse (obrigatorio) 					 
					 
@author Evandro dos Santos O. Teixeira
@since 24/07/2016
@version 1.0
/*/
Method New(aCampos,lCria,cVarBrowse) Class TafBrowseTrb
	
	Default lCria := .F.
	Default aCampos := {}
	Default cVarBrowse := ""
	
	//Parameter aCampos		as array
	//Parameter lCria			as logical
	//Parameter cVarBrowse	as char
	
	::oBrowse 	:= FWMBrowse():New()  
	::aCampos 	:= aCampos
	::lCria 	:= lCria
	::aIndTrab	:= {} 
	::cVarBrowse := cVarBrowse
	::nRows := 0
	
	::lTempInDb := .T.
	
Return Nil

/*/{Protheus.doc} SetCampos
Atribui atributo aCampos responvel pela criação dos campos 
na browse e no arquivo de trabalho.

@param - aCampos - Array com os campos utilizados tanto na browse 
					 quanto no arquivo de trabalho. (obrigatório)
					 
Valores do Array:
[x][1] - CodeBlock 	- Valor do campo (que será exibido no browse)
						  passar o codeblock dentro de aspas por que o mesmo 
						  será macroexecutado pela rotina.
[x][2] - Caracter		- Titulo do campo
[x][3] - Numerico		- Tamanho do campo
[x][4] - Numerico		- Decimal
[x][5] - Caracter		- Tipo de Dado
[x][6] - Catacter		- Picture
[x][7] - Catacter		- Nome do campo no Arquivo de Trabalho, o mesmo deve
						  existir na consulta (Query) com exceção quando 
						  [x][9] for igual a .F.
[x][8] - boolean		- Determina se o campo deve aparecer no browse	
[x][9] - codeBlock	- Code block executado na ação de Duplo Clique no campo
						  (deve ser passado entre aspas)
[x][10] - boolean		- Determina se o campo deve ser persistido (Default .T.)
					      						  

@type Method
@author Evandro dos Santos O. Teixeira
@since 24/07/2016
@version 1.0
/*/
Method SetCampos(aCampos) Class TafBrowseTrb

	//Parameter aCampos		as array
	
	::aCampos := aCampos
Return Nil

/*/{Protheus.doc} CreateTrb
Cria arquivo de Trabalho
@type Method
@param lCria - Determina se será criado um arquivo de trabalho vazio
				 ou com uma estrutura. Se for criado com uma estrurura
				 o método setCampos deverá ser executado antes da criação
				 do arquivo. (opcional se não informado será considerado .F.)
				 *Esse parâmetro só tem uso nas versões 11 e 12 abaixo do
				 release 15.

@author Evandro dos Santos O. Teixeira
@since 24/07/2016
@version 1.0
/*/
Method CreateTrb(lCria) Class TafBrowseTrb

	Local nX   	 	:= 0
	Local aStruct  	:= {}

	//Parameter lCria as logical
	Default lCria := .F.
	

	::lCria := lCria
	
	If lCria .Or. ::lTempInDb
		For nX := 1 To Len(::aCampos)
			aAdd(aStruct,{ ::aCampos[nX][7]	, ::aCampos[nX][5], ::aCampos[nX][3], ::aCampos[nX][4]})
		Next nX
		
		::cAliasTrb := GetNextAlias()
		::oTempTable := FWTemporaryTable():New(::cAliasTrb)
		::oTempTable:SetFields(aStruct)
	
	Else
		::cArqTrb := CriaTrab(,.F.)
	EndIf
	
Return Nil 

/*/{Protheus.doc} SetArea
Determina um alias lógico para o arquivo de trabalho.
@type Method
@param lCloseArea - 	permite que o alias especificado, caso já esteja em uso, 
					 	seja fechado antes da abertura do arquivo de dados 
					 	(opcional, default .T.)
@param cDriver 	-	Driver para a manipulação do arquivo de dados especificado
						(opcional default __LocalDriver)
@param cQuery 		-	Query para criação do arquivo de trabalho.
						(opcional, se não informado criar um método na subclasse 
						para atribuição do cQuery)
@param lOutConex 	-   Define se o arquivo poderá ser utilizado por outras conexões.
						(opcional, default .F.)
@param lReadOnly 	-	Define se o arquivo será aberto como somente leitura.
						(opcional, default .F.)

@author Evandro dos Santos O. Teixeira
@since 24/07/2016
@version 1.0
/*/
Method SetArea(lCloseArea,cDriver,cQuery,lOutConex,lReadOnly) Class TafBrowseTrb

	//Parameter lCloseArea as logical
	//Parameter cDriver 	as char
	//Parameter cQuery 		as char
	//Parameter lOutConex 	as logical
	//Parameter lReadOnly 	as logical
	
	Default lCloseArea	:= .T.
	Default cDriver		:= __LocalDriver
	Default lOutConex		:= .F.
	Default lReadOnly		:= .F.
	Default cQuery		:= ""
	
	If !Empty(cQuery)
		::cQuery := cQuery
	EndIf
	
	If ::lCria
		::cAliasTrb := GetNextAlias()
		dbUseArea(lCloseArea,cDriver,::cArqTrb,::cAliasTrb,lOutConex)
		
		//::PreencheTrb()
		::oBrowse:SetAlias(::cAliasTrb) 
	Else
		dbUseArea(lCloseArea,cDriver,TcGenQry(,,cQuery),::cArqTrb,lOutConex,lOutConex)
	EndIf  
	
Return Nil

/*/{Protheus.doc} PreencheTrb
Método auxiliar para o preenchimento do arquivo de trabalho
@type Method
@return nItens - Quantidade de Itens preenchidos no arquivo de trabalho.
@author Evandro dos Santos O. Teixeira
@since 24/07/2016
@version 1.0
@obs 	Antes de chamar este método o atributo cQuery e aCampos já devem 
		estar atribuidos 
/*/
Method PreencheTrb() Class TafBrowseTrb

	Local cAliasTmp	:= ""
	Local nX		:= 0
	Local nQtdRegs	:= 0
	Local cSql		:= ""
	Local cSqlCount := ""
	Local lVirgula	:= .F.
	
 	cSql := "INSERT INTO " + ::oTempTable:GetRealName() 
 	cSql += "("
	For nX := 1 To Len(::aCampos)
		If Len(::aCampos[nX]) < 10 .Or. ::aCampos[nX][10]
			IIf (lVirgula,cSql += ",",lVirgula := .T.)
			cSql +=  ::aCampos[nX][7]
		EndIf
	Next nX
 	cSql += ") "
 	cSql += ::cQuery

	//Tratamento Error : 1 (XX000) (RC=-1) - ERROR: failed to find conversion function from unknown to text
	if Upper( AllTrim( TcGetDB() ) ) $ 'POSTGRES'
		cSql := strtran( cSql, "' ' DESCRICAO", "CAST( ' ' AS CHAR(1)) DESCRICAO" )
		cSql := strtran( cSql, "' ' XSTATUS", "CAST( ' ' AS CHAR(1)) XSTATUS" )
	endif

	If TCSQLExec(cSql) < 0
		::cErro := TCSQLError()
		MsgInfo(TCSQLError(),"Warning")
	EndIf

	cAliasTmp := GetNextAlias()
	cSqlCount := "SELECT COUNT(*) NoREGS FROM " + ::oTempTable:GetRealName()
	TCQuery cSqlCount New Alias (cAliasTmp)
	nQtdRegs := (cAliasTmp)->NoREGS
	(cAliasTmp)->(dbCloseArea())

Return(nQtdRegs)

/*/{Protheus.doc} LimpaTrb
Fecha a área e elimina o arquivo de trabalho
@type Method
@author Evandro dos Santos O. Teixeira
@since 24/07/2016
@version 1.0
/*/
Method LimpaTrb() Class TafBrowseTrb

	Local nX    := 0
	Local cErro := ""
	
	If ::lTempInDb
		::oTempTable:Delete() 
	Else
		(::cAliasTrb)->(dbCloseArea())
	
		If FErase(::cArqTrb + GetDbExtension()) != 0
			cErro := STR0001 + ::cArqTrb + GetDbExtension() + ": " + STR0002 + ": " + Str(Ferror(),4) //"Erro ao apagar Arquivo Temporario"#Erro
		EndIf
	
		For nX := 1 To Len(::aIndTrab)
			If FErase( ::aIndTrab[nX] + OrdBagExt() ) != 0
				cErro += Chr(13)+Chr(10) + STR0003 + ::aIndTrab[nX] + OrdBagExt() + ": " + STR0002 + ": " + Str(FError(),4) //"Erro ao apagar Indice"#Erro
			EndIf
		Next nX
	EndIf
	
	If !Empty(cErro)
		::cErro := cErro
	EndIf
	
Return Nil

/*/{Protheus.doc} SetCollumns
Método auxiliar para criação das colunas e filtros da browse
@type Method
@author Evandro dos Santos O. Teixeira
@since 24/07/2016
@version 1.0
@obs pré condição: método setCampos()
/*/
Method SetCollumns() Class TafBrowseTrb

	Local aColsEvt 	:= {}
	Local nX 	   	:= 0
	Local nPosCols 	:= 0
	
	::aFiltro := {}

	For nX := 1 To Len(::aCampos)

		If ::aCampos[nX][8]
			aAdd(aColsEvt,FWBrwColumn():New())
			nPosCols := Len(aColsEvt)
			aColsEvt[nPosCols]:SetTitle(::aCampos[nX][2])
			aColsEvt[nPosCols]:SetData(&(::aCampos[nX][1]))	
			aColsEvt[nPosCols]:SetPicture(::aCampos[nX][6])
			aColsEvt[nPosCols]:SetSize(::aCampos[nX][3])
			aColsEvt[nPosCols]:SetDecimal( ::aCampos[nX][4] )
			If Len(::aCampos[nX]) > 8 .And. !Empty(::aCampos[nX][9])
				aColsEvt[nPosCols]:SetDoubleClick(&(::aCampos[nX][9]))
			EndIf
			

			//Obs: A diferença do ::aCampos[nX][1] para o ::aCampos[nX][7] é que o primeiro é um codBlock 
			//que contem a expressão a ser executada no campo.
			aAdd(::aFiltro		,{::aCampos[nX][7];		//1 Nome do Campo 
						 		,::aCampos[nX][2];		//2 Titulo
						 		,::aCampos[nX][5];		//3 Tipo de Dado
						 		,::aCampos[nX][3];		//4 Tamanho
						 		,::aCampos[nX][4];		//5 Decimal
						 		,::aCampos[nX][6]})		//6 Picture

						 	 
		EndIf
	Next nX
	
	//Seto os Campos na Browse
	::oBrowse:SetColumns(aColsEvt)
Return Nil 

/*/{Protheus.doc} SetFiltro
Habilia o filtro no browse
@type Method

@param - Determina se o Filtro deve ser exibido no Browse
@author Evandro dos Santos O. Teixeira
@since 24/07/2016
@version 1.0
@obs pré condição: método SetCollumns()
/*/
Method SetFiltro(lFiltro) Class TafBrowseTrb

	Default lFiltro := .T.
	
	If lFiltro
		::oBrowse:SetUseFilter(.T.)  
		::oBrowse:SetFieldFilter(::aFiltro)
		::oBrowse:SetDBFFilter()	
	Else
		::oBrowse:SetUseFilter(.F.) 
		::oBrowse:SetDBFFilter(.F.)	
	EndIf
	
Return Nil

/*/{Protheus.doc} SetIndice
Cria Indices para a Browse e prepara a criação dos indices do arquivo de
trabalho.

@param - aIndice 	- Array de com as Informações para os Indices
[x][1] 	 - Caracter 	- Descrição do Indice
[x][2]	 - Caracter 	- Chave do Indice
[x][3]  - Caracter 	- Ordem do Indice, para ordem descrecente informar "D" (opcional)
						  Obs: posição 3 só funciona com CriaTrab
@param - Ativa Pesquisa no Browse

@type Method
@author Evandro dos Santos O. Teixeira
@since 24/07/2016
@version 1.0
/*/
Method SetIndice(aIndice,lPesq) Class TafBrowseTrb

	Local nI := 0
	Local nZ := 0
	Local nX := 0
	Local aAuxCmps := {}
	Local aAuxSeek := {}
	Local aIndexBrw := {}
	Local nPos := 0
	
	//Parameter aIndice	as array
	//Parameter lPesq 	as logical
	
	Default aIndice := {}
	Default lPesq	  := .T.
	
	nI := 0
	nZ := 0
	nX := 0
	aAuxCmps := {}
	aAuxSeek := {}
	aIndexBrw := {}
	nPos := 0
	
	If !Empty(aIndice)
		::aIndice := aIndice
	Endif
	
	For nI := 1 To Len(::aIndice)
	
		//A segunda posição do aIndice são os campos do indice concatenados com + ex: SA1_COD+SA1_NOME
		//estou pegando os campos individualmente para verificar a inclusão dos seus respectivos atributos
		//que estão contindos no array ::aCampos.
		
		aAuxCmps := StrTran( ::aIndice[nI][2]	, "DTOS("		, "" )
		aAuxCmps := StrTran( aAuxCmps			, "STR("		, "" )
		aAuxCmps := StrTran( aAuxCmps			, "DESCEND("	, "" )
		aAuxCmps := StrTran( aAuxCmps			, ")"			, "" )
		
		aAuxCmps := StrTokArr(aAuxCmps,"+")
		
		If Len(aAuxCmps) > 0
			For nZ := 1 To Len(aAuxCmps)
				//Procuro o Indice no array de campos
				nPos := aScan(::aCampos,{|x|x[7] == aAuxCmps[nZ]})
				If nPos > 0
					aAdd( aAuxSeek, {"" ;					//LookUp
									, ::aCampos[nPos][5]; 	//Tipo de Dado
									, ::aCampos[nPos][3];	//Tamanho
									, ::aCampos[nPos][4];	//Decimal
									, ::aCampos[nPos][7];	//Campo
									, ::aCampos[nPos][6];	//Mascara
									, }) 						//???
				Else
					//Fazer tratamento para eventuais erros
				EndIf
			Next nZ
		Else
			//Fazer tratamento para eventuais erros
		EndIf
		
		aAdd(aIndexBrw,{::aIndice[nI][1],Nil})
		aIndexBrw[Len(aIndexBrw)][2] := aAuxSeek
		aAuxSeek := {}
		
		If ::lTempInDb
			::oTempTable:AddIndex("I" + AllTrim(Str(nI)), aAuxCmps ) 
		EndIf
	
	Next nI
	
	If Len(aIndexBrw) > 0
		//Seto Indice no Browse
		::oBrowse:SetSeek(lPesq,aIndexBrw)
	EndIf
	
	If !(::lTempInDb)
		//Tenho q setar os indices de tras para frente para ficar na mesma ordem da browse
		For nI := Len(::aIndice) To 1 Step -1
			//Seto Indice no Arquivo de Trabalho
			::SetIndiceTrb(::aIndice[nI][2],,IIf(Len(::aIndice[nI]) > 2,::aIndice[nI][3],""))
		Next nI
		
		//Quando tem mais de 1 indice eh obrigado utilizar dbSetIndex para ativa-los.
		For nX := 1 To Len(::aIndTrab)
			DBSetIndex( ::aIndTrab[nX] + OrdBagExt() )
		Next nX
	EndIf
	
	::oBrowse:lTemporary := .T.
Return Nil

/*/{Protheus.doc} SetIndiceTrb
Função Auxiliar para criação dos indices do arquivo de trabalho

@Param cExpress	- Expressão do Indice (obrigatorio)
@Param cFiltro 	- Expressão de filtro(opcional)
@Param	 xOrdem		- Ordem de exibição dos registros (opcional)
@Param 	 cMens 		- Mensagem do diálogo de progressão (opcional)
@Param	 lShow		- Indica se exibirá o diálogo de progressão (opcional)


@type Method
@author Evandro dos Santos O. Teixeira
@since 24/07/2016
@version 1.0
@obs Esta função não deve ser chamada diretamente.
/*/
Method SetIndiceTrb(cExpress,cFiltro,xOrdem,cMens,lShow) Class TafBrowseTrb

	//Parameter cExpress 	as char
	//Parameter cFiltro 		as char
	//Parameter cMens 		as char
	//Parameter lShow 		as logical
	
	Default cFiltro 	:= ""
	Default xOrdem 	:= ""
	Default cMens  	:= ""
	Default lShow	 	:= .T.
		
	cIndex := CriaTrab(Nil, .F.)
	
	aAdd(::aIndTrab,cIndex)
	IndRegua ((::cAliasTrb),cIndex,cExpress,xOrdem,cFiltro,cMens,lShow)

Return Nil

/*/{Protheus.doc} RefazDadosTrb
Limpa os dados do arquivo de trabalho e refaz o processo 
de criação do mesmo.

@param lSetArea	- Define se a área do arquivo deve ser posicionada
@param lRefreshBrw - Determina que deve ser executado o metodo Refresh 
		do browse após a atualização da tabela temporaria.

	
@type Method
@author Evandro dos Santos O. Teixeira
@since 24/07/2016
@version 1.0
/*/
Method RefazDadosTrb(lSetArea,lRefreshBrw) Class TafBrowseTrb

	Local lEmpty  := .T. 
	Local cQuery  := ""
	
	//Parameter lSetArea 	as logical
	//Parameter lRefreshBrw 	as logical
	
	Default lSetArea := .T.
	Default lRefreshBrw := .T.
	
	//Limpo a Tabela Temporaria
	If ::lTempInDb
		cQuery := "DELETE FROM "+ ::oTempTable:GetRealName()
		If TCSQLExec (cQuery) < 0
			::cErro := TCSQLError()
			MsgInfo(TCSQLError(),"Warning")
		EndIf	
	Else
		If (lSetArea)
			dbSelectArea(::cAliasTrb)
		EndIf
		ZAP
	EndIf
	
	//Insiro novamente os dados 
	lEmpty := IIf(::PreencheTrb() <= 0,.F.,.T.)
	
	If lRefreshBrw
		::oBrowse:Refresh(.T.)
	EndIf

Return (lEmpty) 

/*/{Protheus.doc} GetNameStatus
Metodo para a definição do "nome/descrição" do status 
na rotina TAFTICKET

@param cStatus	- Valor atual do status
@param nTipo  	- Tipo do Status
@param cErro  	- Descrição do Erro	
@type Method
@return cRetorno - Descrição do Status
@author Evandro dos Santos O. Teixeira
@since 24/07/2016
@version 1.0
@obs Esse método só é utilizado pelo monitor TAFTICKET
/*/
Method GetNameStatus(cStatus,nTipo,cErro,cSTQueue) Class TafBrowseTrb

	Local cRetorno := ""
	
	//Parameter cStatus	as char
	//Parameter nTipo  	as numeric
	//Parameter cErro  	as char
	
	Default nTipo 		:= 1
	Default cErro 		:= ""
	Default cSTQueue	:= ''
	
	If nTipo == 1
		If AllTrim(cStatus) == "E"
			cRetorno := STR0004 //"Com Erros Impeditivos"
		ElseIf AllTrim(cStatus) == "I"
			cRetorno := STR0005 //"Integrados"
		ElseIf Alltrim(cStatus) == "A"
			cRetorno := STR0006 //"Aguardando Processamento (Job 2)"
		EndIf
	ElseIf  nTipo == 2
		If AllTrim(cStatus) == "A"
			cRetorno := STR0006 //"Aguardando Processamento (Job 2)"
			
			//quando se tratar de um registro da fila de integração, acrescento a mensagem abaixo para que o usuário identifique no monitor
			if cSTQueue == 'F'
				cRetorno += ' - ' + STR0012 //'Fila de Integração'
			endif			
		Else
			cRetorno := TafStatusInt(AllTrim(cErro),AllTrim(cStatus))
		EndIf
	EndIf

Return (cRetorno)

/*/{Protheus.doc} AddButton
Método de redirecionamento para criação de botões na browse

@param cName	- Nome do Botão
@param bExec  	- CodeBlock para execução do botão
	
@type Method
@author Evandro dos Santos O. Teixeira
@since 24/07/2016
@version 1.0
/*/
Method AddButton(cName,bExec) Class TafBrowseTrb

	//Parameter cName  	as char
	//Parameter bExec  	as char

	::oBrowse:AddButton( cName, bExec ) 
Return Nil 

/*/{Protheus.doc} SetDescription
Método de redirecionamento para criação de um titulo na browse

@param cDescricao	- Titulo da Browse

@type Method
@author Evandro dos Santos O. Teixeira
@since 24/07/2016
@version 1.0
/*/
Method SetDescription(cDescricao) Class TafBrowseTrb
	
	//Parameter cDescricao	as char
	
	::oBrowse:SetDescription(cDescricao)
Return Nil 

/*/{Protheus.doc} SetOwner
Método de redirecionamento para atribuição do objeto no qual o
browse será criado.

@param cOwner	- Objeto Pai

@type Method
@author Evandro dos Santos O. Teixeira
@since 24/07/2016
@version 1.0
/*/
Method SetOwner(oOwner) Class TafBrowseTrb

	//Parameter oOwner	as object
	
	::oBrowse:SetOwner( oOwner )
Return Nil 

/*/{Protheus.doc} SetMenuDef
Método de redirecionamento definição do MenuDef da rotina

@param cMenu - Nome do menu
@type Method
@author Evandro dos Santos O. Teixeira
@since 24/07/2016
@version 1.0
/*/
Method SetMenuDef(cMenu) Class TafBrowseTrb

	//Parameter cMenu as char
	
	::oBrowse:SetMenuDef(cMenu)
Return Nil 

/*/{Protheus.doc} DisableDetails
Método de redirecionamento desabilitar os detalhes da Browse

@type Method
@author Evandro dos Santos O. Teixeira
@since 24/07/2016
@version 1.0
/*/
Method DisableDetails() Class TafBrowseTrb
	::oBrowse:DisableDetails()
Return Nil 

/*/{Protheus.doc} SetProfileID
Método de redirecionamento para definição de um Id para browse
@param cId - Id para a Browse
@type Method
@author Evandro dos Santos O. Teixeira
@since 24/07/2016
@version 1.0
/*/
Method SetProfileID(cId) Class TafBrowseTrb

	//Parameter cId as char
	
	::oBrowse:SetProfileID(cId)
Return Nil

/*/{Protheus.doc} Refresh
Método de redirecionamento para Atualização do browse

@type Method
@author Evandro dos Santos O. Teixeira
@since 24/07/2016
@version 1.0
/*/
Method Refresh() Class TafBrowseTrb
	::oBrowse:Refresh(.T.)
Return Nil

/*/{Protheus.doc} Activate
Método de redirecionamento para ativação do browse

@type Method
@author Evandro dos Santos O. Teixeira
@since 24/07/2016
@version 1.0
/*/
Method Activate() Class TafBrowseTrb
	::oBrowse:Activate() 
Return Nil

/*/{Protheus.doc} SetWalkThru
Método de redirecionamento para habiltar ou desabilitar
o botão WalkThru do browse

@type Method
@param lHabilita - Habilita ou Desabilita o botão
@author Evandro dos Santos O. Teixeira
@since 24/07/2016
@version 1.0
/*/
Method SetWalkThru(lHabilita)Class TafBrowseTrb

	//Parameter lHabilita as logical

	::oBrowse:SetWalkThru(lHabilita)
Return Nil

/*/{Protheus.doc} SetAmbiente
Método de redirecionamento para habiltar ou desabilitar
o botão Ambiente do browse

@type Method
@param lHabilita - Habilita ou Desabilita o botão
@author Evandro dos Santos O. Teixeira
@since 24/07/2016
@version 1.0
/*/
Method SetAmbiente(lHabilita) Class TafBrowseTrb
	
	//Parameter lHabilita as logical

	::oBrowse:SetAmbiente(lHabilita)
Return Nil 

/*/{Protheus.doc} CreateTabInDb
Método para a Inclusão de fato da tabela temporaria 
no banco de dados.
@type Method
@author Evandro dos Santos O. Teixeira
@since 06/03/2017
@version 1.0
/*/
Method CreateTabInDb() Class TafBrowseTrb
	::oTempTable:Create()
	::oBrowse:SetAlias(::cAliasTrb)
Return Nil 

Method EraseTableTemp() Class TafBrowseTrb

	Local cErroSQL := ""
	Local nX := 0

	If ::lTempInDb
		TafDelTempTable(::oTempTable:GetRealName(),::cErro)
	Else
		dbSelectArea(::cAliasTrb)
		ZAP
	EndIf 

Return Nil 





