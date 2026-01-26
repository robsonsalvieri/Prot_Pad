#INCLUDE "TOTVS.CH" 
#INCLUDE "TAFTICKET.CH"

/*/{Protheus.doc} TafTBrwLayout
Browse com os regitros agrupados pelo Layout (Visão por Cadastro)
@type class
@author Evandro dos Santos O. Teixeira
@since 24/07/2016
@version 1.0
/*/
Class TafTBrwLayout From TafBrowseTrb

	Data nVisao	    as numeric
	Data cDataIni	as char
	Data cDataFim   as char
	Data cCodFil	as char
	Data oHashLay   as object
	Data cQuery     as char
	Data aIndice    as array

	Method New(aCampos,lCria,aParam,cVarBrowse) Constructor	
	Method CreateQry()
	Method CreateFields()
	Method GetDescLayout(cLayout)
	Method LimpaHash()
	Method LimpaTrb()

EndClass

/*/{Protheus.doc} New
Metodo Construtor

@param - aCampos 	- Array com os campos utilizados tanto na browse
						quanto no arquivo de trabalho. (opcional)
@param - lCria 		- Determina que o browse vai obrigatoriamente utilizar
					 	um arquivo de trabalho com estrutura (opcional)
@param - aParam		- Parâmetros para criação do browse.
@param - cVarBrowse 	- Nome utilizado na criação do objeto FWMBrowse (obrigatorio) 	
@type Method
@author Evandro dos Santos O. Teixeira
@since 24/07/2016
@version 1.0
/*/
Method New(aCampos,lCria,aParam,cVarBrowse,aParamT) Class TafTBrwLayout

	Default aCampos		:= {}
	Default aParam  	:= {}
	Default lCria 		:= .F.
	Default cVarBrowse 	:= "" 
    Default aParamT     := {}
	
	//Parameter aCampos 	as array
	//Parameter lCria 		as logical
	//Parameter aParam 		as array
	//Parameter cVarBrowse 	as char

	::nVisao   := aParam[3]
	::cDataIni := DTOS(aParam[1])
	::cDataFim := DTOS(aParam[2])
	::cCodFil  := aParam[4]
	::oHashLay := Nil 

	_Super:New(aCampos,lCria,cVarBrowse)
	::CreateQry(aParamT)
	::CreateFields()
	::CreateTrb(.T.)
	::SetCollumns()
	If !::lTempInDb
		::SetArea(.T.,,,.F.,.F.)
	EndIf
	::SetIndice()
	::SetFiltro()
	If ::lTempInDb
		::CreateTabInDb()
	EndIf
	::PreencheTrb()
	::SetDescription(STR0145) //'Registro do Layout TOTVS'
	::DisableDetails()
	::SetAmbiente(.F.)
	::SetWalkThru(.F.)
	::SetProfileID('1')

Return Nil 

/*/{Protheus.doc} CreateQry
Método responsavel pela criação da Query utilizada
para preencher o arquivo de trabalho.

@type Method
@author Evandro dos Santos O. Teixeira
@since 24/07/2016
@version 1.0
@obs A ordem do select deve respeitar a ordem dos campos do CreateFields
/*/
Method CreateQry(aParamT) Class TafTBrwLayout

	Local cQuery as char
	
	If aParamT[6] == 1 
		cQuery := "SELECT LAYOUT,DESCRICAO,CODMSG,XSTATUS,QTDNOTINT FROM ("
		cQuery += " SELECT 	ST2A.TAFTPREG								    LAYOUT   	"  
		cQuery += " 	   		,C8E.C8E_DESCRI 							DESCRICAO	"
		cQuery += " 	   		,ST2A.TAFCODMSG							    CODMSG		"
		cQuery += " 	   		,' '										XSTATUS	    " 	
		cQuery += " 		  	, (	SELECT COUNT(TAFSTATUS) 	                        "
		cQuery += "				FROM TAFST2 S1A "
		cQuery += "				WHERE S1A.TAFSTATUS <> '3' AND S1A.D_E_L_E_T_ = ' ' 	"
		cQuery += "				AND ST2A.TAFTPREG = S1A.TAFTPREG) 	QTDNOTINT	"
		cQuery += " FROM TAFST2 ST2A						"	
		
		cQuery += " INNER JOIN " + RetSqlName("C8E") +  " C8E ON ST2A.TAFTPREG = C8E.C8E_CODIGO	 AND C8E.D_E_L_E_T_ = ' ' "
		cQuery += " WHERE ST2A.TAFDATA BETWEEN '" + ::cDataIni + " ' AND '"  + ::cDataFim + "'"
		cQuery += " AND ST2A.TAFFIL IN(" + ::cCodFil + ") "
		cQuery += " AND ST2A.D_E_L_E_T_ = ' ' "
		cQuery += " AND ST2A.TAFCODMSG = '2' "
		
		cQuery += " GROUP BY  ST2A.TAFTPREG "
		cQuery += " 			,ST2A.TAFCODMSG "
		cQuery += " 			,C8E.C8E_DESCRI "
		
		cQuery += ") VISAOUNI GROUP BY LAYOUT,DESCRICAO,CODMSG,XSTATUS,QTDNOTINT"

		If !(Upper( AllTrim( TcGetDB() ) ) $ 'DB2') 
			cQuery := ChangeQuery(cQuery)
		EndIf
	Else //2=Escopo Fiscal
		cQuery := "SELECT LAYOUT,DESCRICAO,CODMSG,XSTATUS,QTDNOTINT FROM"
		cQuery += " (SELECT ST2.TAFTPREG LAYOUT,' ' DESCRICAO,ST2.TAFCODMSG CODMSG,' ' XSTATUS"
		cQuery += " ,(SELECT COUNT(TAFSTATUS) FROM TAFST2 S1 WHERE S1.TAFSTATUS <> '3' AND S1.D_E_L_E_T_ = ' ' AND ST2.TAFTPREG = S1.TAFTPREG) QTDNOTINT"
		cQuery += " FROM TAFST2 ST2 WHERE ST2.TAFDATA BETWEEN '" + ::cDataIni + "' AND '" + ::cDataFim + "'"
		cQuery += " AND ST2.TAFCODMSG = '1' AND ST2.TAFFIL IN(" + ::cCodFil + ") AND ST2.D_E_L_E_T_ = ' '"
		cQuery += " GROUP BY ST2.TAFTPREG, ST2.TAFCODMSG"
		cQuery += " ) VISAOUNI GROUP BY LAYOUT, DESCRICAO, CODMSG, XSTATUS, QTDNOTINT"
	
		If !(Upper( AllTrim( TcGetDB() ) ) $ 'DB2|POSTGRES') 
			cQuery := ChangeQuery(cQuery)
		EndIf
	Endif

	If 'INFORMIX' $ Upper( AllTrim( TcGetDB() ) )
		cQuery := 'SELECT * FROM (' + cQuery + ')'
	EndIf

	::cQuery := cQuery

Return Nil

/*/{Protheus.doc} CreateFields
Método responsavel pela criação dos campos e índices utilizados
no arquivo de trabalho e na browse.

@type Method
@author Evandro dos Santos O. Teixeira
@since 24/07/2016
@version 1.0
@obs Ver a definição do array na descrição do método SetCampos da superclasse.
/*/
Method CreateFields() Class TafTBrwLayout

	Local aCmpsBrw 	    as array
	Local aIndice		as array
	Local cDescri	 	as char
	Local cStatus	 	as char
	
	
	aCmpsBrw 	:= {}
	aIndice	:= {}
	cDescri	:= ""
	cStatus	:= ""
	
	cDescri := "{||IIf(CODMSG == '2',DESCRICAO,"+ ::cVarBrowse + ":GetDescLayout(LAYOUT))}"
	cStatus := "{||IIf(QTDNOTINT > 0,'" + STR0172 + "','" + STR0173 + "')}"  //'Com Pendência'#'Sem Pendência'
	
	//Posicao 8 Indica que o campo deve aparecer no Browse
	aCmpsBrw := {	 {"{||LAYOUT}"			,STR0145,015,0,"C","!@","LAYOUT"		,.T.}; //Layout
					,{cDescri					,STR0091,220,0,"C","!@","DESCRICAO"	,.T.}; //Descrição
	      			,{"{||CODMSG}"			,STR0150,001,0,"C","!@","CODMSG"		,.F.}; //Codigo Msg
	      			,{cStatus					,STR0076,025,0,"C","!@","XSTATUS"		,.T.}; //Status
	      			,{"{||QTDNOTINT}"			,STR0151,005,0,"N","!@","QTDNOTINT"	,.F.}} //Qtd não Integrada
	
	aIndice := {{STR0145,"LAYOUT"}} //"Layout"
	
	::SetCampos(aCmpsBrw)
	::aIndice := aIndice

Return Nil

/*/{Protheus.doc} GetDescLayout
Retorna Descrição do Layout (ECF e Fiscal)

@param cLayout - Layout para busca da descrição
@type Method
@author Evandro dos Santos O. Teixeira
@since 24/07/2016
@version 1.0
/*/
Method GetDescLayout(cLayout) Class TafTBrwLayout

	Local aAuxLay  	    as array
	Local aLay		  	as array
	Local nI		  	as numeric
	Local cDescricao 	as char
	Local aRetLay		as array
	
	//Parameter cLayout	as char
	
	aAuxLay  	:= {}  
	aLay		:= {}
	nI		  	:= 0
	cDescricao 	:= ""
	aRetLay		:= {}	
	
	If (::oHashLay == Nil)
		aLay := GetLayout()
		
		For nI := 1 To Len(aLay)
			If Substr(aLay[nI],1,2) == "[T"
				nPosIni := At("-"		,aLay[nI]) + 1
				nPosFim := Rat("]"	,aLay[nI]) - nPosIni
				aAdd(aAuxLay,{RTrim(Substr(aLay[nI],2,nPosIni-4)),LTrim(Substr(aLay[nI],nPosIni,nPosFim))})
			EndIf
		Next Nil
		::oHashLay	:=	AToHM(aAuxLay,1,3)
	EndIf
	
	HMGet(::oHashLay,RTrim(cLayout),@aRetLay )
	If !Empty(aRetLay)
		cDescricao := aRetLay[1][2]
	EndIf

Return cDescricao

/*/{Protheus.doc} LimpaHash
Limpa e Destroi tabela de Hash

@param cLayout - Layout para busca da descrição
@type Method
@author Evandro dos Santos O. Teixeira
@since 24/07/2016
@version 1.0
/*/
Method LimpaHash() Class TafTBrwLayout

  If Valtype(::oHashLay) <> "U" .OR. ::oHashLay <> Nil
	  // Limpa os dados do HashMap
	  HMClean(::oHashLay)
	  // Libera o objeto de HashMap
	  FreeObj(::oHashLay)
	  ::oHashLay := Nil
  EndIf
  

Return Nil

/*/{Protheus.doc} LimpaTrb

Fecha a área e elimina o arquivo de trabalho
@type Method
@author Evandro dos Santos O. Teixeira
@since 24/07/2016
@version 1.0
@obs Metodo Sobrescrito
/*/
Method LimpaTrb() Class TafTBrwLayout

	Local nX    as numeric
	Local cErro as char
	
	nX := 0
	cErro := ""
	
	If ::lTempInDb
		::oTempTable:Delete() 
	Else
		(::cAliasTrb)->(dbCloseArea())
	
		If FErase(::cArqTrb + GetDbExtension()) != 0
			cErro := STR0134 + ::cArqTrb + GetDbExtension() + ": " + STR0136 + ": " + Str(Ferror(),4) //"Erro ao apagar Arquivo Temporario"#Erro
		EndIf
	
		For nX := 1 To Len(::aIndTrab)
			If FErase( ::aIndTrab[nX] + OrdBagExt() ) != 0
				cErro += Chr(13)+Chr(10) + STR0135 + ::aIndTrab[nX] + OrdBagExt() + ": " + STR0136 + ": " + Str(FError(),4) //"Erro ao apagar Indice"#Erro
			EndIf
		Next nX
	EndIf

	::LimpaHash()
	
	TAFConOut(cErro)
	
Return Nil

//*************************************************************************************************************************************
//* NEW CLASS - KEY																														 *
//*************************************************************************************************************************************
/*/{Protheus.doc} TafTBrwTafKey
Browse com os regitros agrupados pelo TafKey
A forma de agrupamento do browse muda conforme a visão selecionada 

@type class
@author Evandro
@since 24/07/2016
@version 1.0
/*/
Class TafTBrwTafKey From TafBrowseTrb

	Data nVisao	    as numeric
	Data cBusca	    as char
	Data cDataIni   as char
	Data cDataFim   as char
	Data cCodFil	as char
	Data cQuery     as char
	Data aIndice    as array
    Data nEscopo    as numeric

	Method New() Constructor	
	Method CreateQry(cBusca,cVarBrowse)
	Method CreateFields()
	Method FiltroAvancado()
	Method visualizarRegistro(oBrowseHis)
	Method alterarRegistro(oBrowseHis) 
	Method excluirRegistro(oBrowseHis,oBrowseLay) 

EndClass

/*/{Protheus.doc} New
Metodo Construtor

@param - aCampos 		- Array com os campos utilizados tanto na browse
						quanto no arquivo de trabalho. (opcional)
@param - lCria 		- Determina que o browse vai obrigatoriamente utilizar
					 	um arquivo de trabalho com estrutura (opcional)
@param - aParam		- Parâmetros para criação do browse.
@param - cVarBrowse 	- Nome utilizado na criação do objeto FWMBrowse (obrigatorio) 	
@type Method
@author Evandro dos Santos O. Teixeira
@since 24/07/2016
@version 1.0
/*/
Method New(aCampos,lCria,aParam,cVarBrowse,aParamT) Class TafTBrwTafKey

	Default aCampos 	:= {}
	Default lCria 	    := .F.
	Default aParam 	    := {}
	Default cVarBrowse  := "" 
    Default aParamT     := []

	//Parameter aCampos		as array
	//Parameter lCria		as logical
	//Parameter aParam		as array
	//Parameter cVarBrowse	as char
	
	::nVisao 	 := aParam[3]
	::cDataIni	 := DTOS(aParam[1])
	::cDataFim	 := DTOS(aParam[2])
	::cBusca 	 := ""
	::cCodFil	 := aParam[4]
    ::nEscopo    := aParamT[6]

	_Super:New(aCampos,lCria,cVarBrowse)
	::CreateFields()
	::CreateTrb(.T.)
	::SetCollumns()
	::CreateQry("")
	If !::lTempInDb
		::SetArea(.T.,,,.F.,.F.)
	EndIf
	::SetIndice()
	::SetFiltro()
	If ::lTempInDb
		::CreateTabInDb()
	EndIf
	::PreencheTrb()
	::SetDescription(STR0146) //"Chave do Registro (TAFKEY)"
	::DisableDetails()
	::SetAmbiente(.F.)
	::SetWalkThru(.F.)
	::SetProfileID('2')
		
Return Nil 

/*/{Protheus.doc} CreateQry
Método responsavel pela criação da Query utilizada
para preencher o arquivo de trabalho.
A consulta muda conforme a visão selecionada para permitir
o relacionamente entre os browses.
Nesta consulta em particular também pode filtrar os registros 
conforme o atributo cBusca que pode ser passado por parâmetro
caso este método esteja sendo chamado pela funcionalide de 
Filtro/Pesquisa Avançado que visa realizar uma pesquisa dentro
do TAFMSG.

@type Method
@param cBusca - Chave para Filtro dos registros.
@author Evandro dos Santos O. Teixeira
@since 24/07/2016
@version 1.0
@obs A ordem do select deve respeitar a ordem dos campos do CreateFields
/*/
Method CreateQry(cBusca) Class TafTBrwTafKey

	Local cQuery  	as char
	Local cBancoDB 	as char
	Local cConcat	as char
	
	//Parameter cBusca	as char
	Default cBusca := ""
	
	cQuery := ""
	cBancoDB := Upper(AllTrim(TcGetDB()))
	cConcat := IIf(cBancoDB $ "ORACLE|INFORMIX|POSTGRES|DB2","||","+")

	If ::nVisao == 1
		cQuery :=	" SELECT "
		cQuery +=		" C1ECR9.C1E_FILTAF, "
		cQuery +=		" ST2.TAFKEY TAFKEY, "
		cQuery +=		" ST2.TAFTPREG	LAYOUT, "
		cQuery +=		" ST2.TAFSTATUS TAFSTATUS "
		cQuery +=	" FROM TAFST2 ST2 "
		cQuery +=		"INNER JOIN "
		cQuery +=			"( SELECT "
		cQuery +=				" C1E.C1E_FILTAF, "
		cQuery +=				" C1E.C1E_CODFIL, "
		cQuery +=				" CR9.CR9_CODFIL "
		cQuery +=			" FROM "
		cQuery +=				RetSqlName( "C1E" ) + " C1E "
		cQuery +=				" LEFT JOIN " + RetSqlName( "CR9" ) + " CR9 ON "
		cQuery +=				" C1E.C1E_ID = CR9.CR9_ID "
		cQuery +=				" AND CR9.D_E_L_E_T_ = ' ' "
        cQuery +=			" WHERE "
		cQuery +=				" C1E.C1E_FILIAL = '" + xFilial( "C1E" ) + "' "
		cQuery +=				" AND C1E.D_E_L_E_T_ = ' ' "
		cQuery +=			" ) C1ECR9 ON "
		cQuery +=		" C1ECR9.C1E_CODFIL = ST2.TAFFIL OR C1ECR9.CR9_CODFIL = ST2.TAFFIL "
		cQuery +=	" LEFT JOIN TAFXERP XERP ON "
		cQuery +=		" ST2.TAFKEY = XERP.TAFKEY "
		cQuery +=		" AND ST2.TAFTICKET = XERP.TAFTICKET "
		cQuery +=	" WHERE "
		cQuery +=		" ST2.TAFDATA BETWEEN '" + ::cDataIni + "' AND '" + ::cDataFim + "'"
		cQuery +=		" AND ST2.TAFFIL IN(" + ::cCodFil + ") "

		If !Empty(cBusca)
			cQuery +=	" AND ST2.TAFMSG LIKE '%" + AllTrim(cBusca) + "%'"
		EndIf
		cQuery +=		" AND ST2.D_E_L_E_T_ = ' ' "
        
		cQuery +=	" GROUP BY "
		cQuery +=		" C1ECR9.C1E_FILTAF, "
		cQuery +=		" ST2.TAFKEY, "
		cQuery +=		" ST2.TAFTPREG, "
		cQuery +=		" ST2.TAFSTATUS "

	Else

		cQuery := " SELECT C1E.C1E_FILTAF,  ST2A.TAFKEY		TAFKEY "
		cQuery += " ,ST2A.TAFTPREG			LAYOUT "
		cQuery += " ,'A'					TAFSTATUS "
		cQuery += " FROM TAFST2 ST2A "
		
		cQuery += "INNER JOIN  " + RetSqlName( "C1E" ) + " C1E " 
		cQuery += "ON C1E.C1E_CODFIL = ST2A.TAFFIL AND C1E.C1E_FILIAL = '" + xFilial( "C1E" ) + "' AND C1E.D_E_L_E_T_ <> '*' " 

         If ::nEscopo == 1
            cQuery += " AND TAFCODMSG = '2' "
        Else
            cQuery += " AND TAFCODMSG = '1' "
        EndIf

		cQuery += " WHERE (ST2A.TAFSTATUS = '1' OR ST2A.TAFSTATUS = '2')"
		cQuery += " AND ST2A.TAFDATA  BETWEEN '" + ::cDataIni + "' AND '" + ::cDataFim + "'" 
    	cQuery += " AND ST2A.TAFFIL IN(" + ::cCodFil + ") "
		If !Empty(cBusca)
			cQuery += " AND ST2A.TAFMSG LIKE '%" + AllTrim(cBusca) + "%'"	
		EndIf
		cQuery += " AND ST2A.D_E_L_E_T_ <> '*' "
		
		cQuery += " UNION ALL "
	
		cQuery += " SELECT C1E.C1E_FILTAF, XERP.TAFKEY				TAFKEY " 
		cQuery += " , ST2.TAFTPREG					LAYOUT "
		cQuery += " ,CASE WHEN XERP.TAFSTATUS	< '4' "
		cQuery += " THEN 'I' ELSE 'E' END 			TAFSTATUS "
		cQuery += " FROM TAFXERP XERP INNER JOIN TAFST2 ST2 " 
		cQuery += " ON  XERP.TAFKEY = ST2.TAFKEY "

        If ::nEscopo == 1
            cQuery += " AND TAFCODMSG = '2' "
        Else
            cQuery += " AND TAFCODMSG = '1' "
        EndIf 

		cQuery += " AND XERP.TAFTICKET = ST2.TAFTICKET AND ST2.D_E_L_E_T_ <> '*' "
		cQuery += " AND ST2.TAFFIL IN(" + ::cCodFil + ") "
		If !Empty(cBusca)
			cQuery += " AND ST2.TAFMSG LIKE '%" + AllTrim(cBusca) + "%'"	
		EndIf

		cQuery += "INNER JOIN  " + RetSqlName( "C1E" ) + " C1E " 
		cQuery += "ON C1E.C1E_CODFIL = TAFFIL AND C1E.C1E_FILIAL = '" + xFilial( "C1E" ) + "' AND C1E.D_E_L_E_T_ <> '*' "

		cQuery += " INNER JOIN "
		cQuery += " ( "
		cQuery += " SELECT TAFKEY , MAX(TAFDATA " + cConcat + " TAFHORA) CHAVE "
		cQuery += " FROM TAFXERP "
		cQuery += " WHERE D_E_L_E_T_ <> '*' "
		cQuery += " AND TAFDATA  BETWEEN '" + ::cDataIni + "' AND '" + ::cDataFim + "'"  
		cQuery += " GROUP BY TAFKEY	, TAFTICKET"
		cQuery += " ) MAXREG ON (XERP.TAFDATA " + cConcat + " XERP.TAFHORA) = MAXREG.CHAVE "
		cQuery += " WHERE XERP.D_E_L_E_T_ <> '*' "


		cQuery += " AND XERP.TAFDATA  BETWEEN '" + ::cDataIni + "' AND '" + ::cDataFim + "'"  
		cQuery += " GROUP BY   C1E.C1E_FILTAF, XERP.TAFKEY "
		cQuery += " 			,XERP.TAFSTATUS "
		cQuery += " 			,ST2.TAFTPREG "
			
	EndIf

	If 'INFORMIX' $ Upper( AllTrim( TcGetDB() ) )
 		cQuery := 'SELECT * FROM (' + cQuery + ')'
 	EndIf

	if Upper( AllTrim( TcGetDB() ) ) != 'DB2'
		cQuery := ChangeQuery(cQuery)
	endif	

	::cQuery := cQuery

Return Nil 

/*/{Protheus.doc} CreateFields
Método responsavel pela criação dos campos e índices utilizados
no arquivo de trabalho e na browse.

@type Method
@author Evandro dos Santos O. Teixeira
@since 24/07/2016
@version 1.0
@obs Ver a definição do array na descrição do método SetCampos da superclasse.
/*/
Method CreateFields() Class TafTBrwTafKey

	Local aCmpsBrw as array
	Local aIndice  as array
	
	aCmpsBrw := {}
	aIndice  := {}

	aCmpsBrw := {	 {"{||TAFFIL}"	,"Filial",040,0,"C","!@","TAFFIL"		,.T.};
					,{"{||TAFKEY}"	,STR0146,100,0,"C","!@","TAFKEY"		,.T.,"{||" + ::cVarBrowse + ":visualizarRegistro(oBrowseHis)}",.T.}; //TafKey	
					,{"{||LAYOUT}"	,STR0145,015,0,"C","!@","LAYOUT"		,.F.};	//Layout
					,{"{||TAFSTATUS}"	,STR0076,025,0,"C","!@","TAFSTATUS"	,.F.}} //Status

		
	If ::nVisao == 1
		aIndice := {{STR0146,"TAFKEY"},{STR0145+ "+" + STR0146,"LAYOUT+TAFKEY"}} //"Tafkey"#"Layout+Tafkey"
	Else
		aIndice := {{STR0146,"TAFKEY"},{STR0149+ "+" + STR0146,"TAFSTATUS+TAFKEY"}} //"Tafkey"#"TAFStatus+Tafkey"
	Endif
	
	::SetCampos(aCmpsBrw)
	::aIndice := aIndice

Return Nil

/*/{Protheus.doc} FiltroAvancado
Método responsavel em realizar a operação de Filtro Avançado,
o mesmo deve ser utilizado em conjunto com o ::CreateQry(valor para busca)
Caso a pesquisa não retorne dados o sistema chama novamente o ::CreateQry()
sem parâmetros e refaz a criação do arquivo de trabalho com a Query original.

@type Method
@author Evandro dos Santos O. Teixeira
@since 24/07/2016
@version 1.0
/*/
Method FiltroAvancado() Class TafTBrwTafKey

	If (!::RefazDadosTrb())
		MsgInfo(STR0147) //"Não houve resultados para este Filtro."
		::CreateQry()
		::RefazDadosTrb()
	EndIf

Return Nil 

/*/{Protheus.doc} visualizarRegistro
Visualiza Registro no TAF

@type Method
@param oBrowseHis - Browse Historico de Registro
@author Evandro dos Santos O. Teixeira
@since 24/07/2016
@version 1.0
/*/
Method visualizarRegistro(oBrowseHis) Class TafTBrwTafKey

	//Parameter oBrowseHis	as object

	If AllTrim((oBrowseHis:oBrowse:Alias())->TAFSTATUS) $ "1|2"
	
		FMonGoToView( "INTEGRACAO", 1, oBrowseHis:oBrowse,0)
	ElseIf AllTrim((oBrowseHis:oBrowse:Alias())->TAFSTATUS) == "A"
	
		Aviso( STR0037, STR0177, { STR0036 }, 2 ) //"Registro Excluído"#"Este registro foi excluído do TAF. Aguardando Processamento."#"Fechar"
	Else

		If AllTrim((oBrowseHis:oBrowse:Alias())->TAFSTATUS) == "3"
			Aviso( STR0034, STR0035, { STR0036 }, 3 ) //"Registro Excluído"#"Este registro foi excluído do TAF. Não é possível realizar operações."#"Fechar"
		Else
			Aviso( STR0037, STR0038, { STR0036 }, 3 ) //"Registro Não Integrado"#"Este registro não foi integrado ao TAF. Verifique a inconsistência informada e realize a correção."#"Fechar"
		EndIf
	EndIf

Return Nil

/*/{Protheus.doc} alterarRegistro
Visualiza Registro no TAF

@type Method
@param oBrowseHis - Browse Historico de Registro
@author Evandro dos Santos O. Teixeira
@since 24/07/2016
@version 1.0
/*/
Method alterarRegistro(oBrowseHis) Class TafTBrwTafKey
	
	//Parameter oBrowseHis	as object

	If AllTrim((oBrowseHis:oBrowse:Alias())->TAFSTATUS) $ "1|2"
		
		FMonGoToView( "INTEGRACAO", 4, oBrowseHis:oBrowse,0)
	Else
	
		If AllTrim((oBrowseHis:oBrowse:Alias())->TAFSTATUS) == "3"
			Aviso( STR0034, STR0035, { STR0036 }, 3 ) //"Registro Excluído"#"Este registro foi excluído do TAF. Não é possível realizar operações."#"Fechar"
		Else
			Aviso( STR0037, STR0038, { STR0036 }, 3 ) //"Registro Não Integrado"#"Este registro não foi integrado ao TAF. Verifique a inconsistência informada e realize a correção."#"Fechar"
		EndIf
	EndIf
	
Return Nil


/*/{Protheus.doc} excluirRegistro
Visualiza Registro no TAF

@type Method
@param oBrowseHis - Browse Historico de Registro
@param oBrowseLay - Browse Layout
@author Evandro dos Santos O. Teixeira
@since 24/07/2016
@version 1.0
/*/
Method excluirRegistro(oBrowseHis,oBrowseLay) Class TafTBrwTafKey

	Local lVazio	  := .F.
	Local lRetView  := .T.
	
	//Parameter oBrowseHis	as object
	//Parameter oBrowseLay	as object

	If (AllTrim((oBrowseHis:oBrowse:Alias())->TAFSTATUS) $ "1|2")
		lRetView := FMonGoToView( "INTEGRACAO", 5, oBrowseHis:oBrowse,0)
	EndIf
	
	If lRetView 
	
		lVazio := (::self:oBrowse:nLen == 1)   
	
		oBrowseHis:apagaHistorico(.T.,.T.)
		oBrowseHis:Refresh()
		
		::RefazDadosTrb(.T.)
		::self:oBrowse:Refresh()
		
		If lVazio
			oBrowseLay:RefazDadosTrb(.T.)
			oBrowseLay:Refresh()
		EndIf
	EndIf 

Return Nil

//*************************************************************************************************************************************
//* NEW CLASS - HISTORICO																															 *
//*************************************************************************************************************************************
/*/{Protheus.doc} TafTBrwHist
Browse com os regitros da tabela TAFXERP que serão 
relacionados ao browse TafTBrwTafKey que mostrará ao 
usuário o histórico de cada TAFKEY.

@type class
@author Evandro
@since 24/07/2016
@version 1.0
/*/
Class TafTBrwHist From TafBrowseTrb

	Data nVisao	    as char
	Data cErro 	    as char
	Data cCodFil	as char
	Data cDataIni	as char
	Data cDataFim   as char
	Data cQuery     as char
	Data aIndice    as array
    Data nEscopo    as numeric



	Method New(aCampos,lCria,aParam,cVarBrowse) Constructor	
	Method CreateQry()
	Method CreateFields()
	Method apagaHistorico(lAll,lST2)
	Method exibeMensagem()
	
EndClass

/*/{Protheus.doc} New
Metodo Construtor

@param - aCampos 		- Array com os campos utilizados tanto na browse
						quanto no arquivo de trabalho. (opcional)
@param - lCria 		- Determina que o browse vai obrigatoriamente utilizar
					 	um arquivo de trabalho com estrutura (opcional)
@param - aParam		- Parâmetros para criação do browse.
@param - cVarBrowse 	- Nome utilizado na criação do objeto FWMBrowse (obrigatorio) 	
@type Method
@author Evandro dos Santos O. Teixeira
@since 24/07/2016
@version 1.0
/*/
Method New(aCampos,lCria,aParam,cVarBrowse,aParamT) Class TafTBrwHist

	Default aCampos 	:= {}
	Default lCria 		:= .F.
	Default aParam		:= {}
	Default cVarBrowse 	:= ""
    Default aParamT     := {}

	//Parameter aCampos		as array
	//Parameter lCria		as logical
	//Parameter aParam		as array
	//Parameter cVarBrowse	as char

	::cErro  := ""
	::cCodFil := aParam[1]
	::cDataIni	:= DtoS(aParam[2])
	::cDataFim	:= DtoS(aParam[3])
    ::nEscopo   := aParamT[6]

	_Super:New(aCampos,lCria,cVarBrowse)
	::CreateQry(aParamT)
	::CreateFields()
	::CreateTrb(.T.)
	::SetCollumns()
	If !::lTempInDb
		::SetArea(.T.,,,.F.,.F.)
	EndIf
	::SetIndice()
	::SetFiltro()
	If ::lTempInDb
		::CreateTabInDb()
	EndIf
	::PreencheTrb()
	::SetDescription(STR0148) //"Histórico do Ticket (Registros Processados)"
	::DisableDetails()
	::SetAmbiente(.F.)
	::SetWalkThru(.F.)
	::SetProfileID('3')
	
Return Nil 

/*/{Protheus.doc} CreateQry
Método responsavel pela criação da Query utilizada
para preencher o arquivo de trabalho.

@type Method
@author Evandro dos Santos O. Teixeira
@since 24/07/2016
@version 1.0
@obs A ordem do select deve respeitar a ordem dos campos do CreateFields
/*/
Method CreateQry() Class TafTBrwHist

	Local cQuery as char

	cQuery := ""

	cQuery := " SELECT "
	cQuery +=	" C1ECR9.C1E_FILTAF	TAFFIL "
	cQuery +=	" ,XERP.TAFDATA		TAFDATA "
	cQuery +=	" ,XERP.TAFHORA		TAFHORA "
	cQuery +=	" ,XERP.TAFKEY		TAFKEY "
	cQuery +=	" ,XERP.TAFTICKET	TAFTICKET "
	cQuery +=	" ,XERP.TAFSTATUS	TAFSTATUS "	
	cQuery +=	" ,XERP.R_E_C_N_O_	RECNOXERP "
	cQuery +=	" ,XERP.TAFCODERR	TAFCODERR "
	cQuery +=	" ,XERP.TAFALIAS	TAFALIAS "
	cQuery +=	" ,XERP.TAFRECNO	TAFRECNO "
	cQuery +=	" ,ST2.TAFTPREG		LAYOUT "
	cQuery +=	" ,ST2.R_E_C_N_O_	ST2REC "

	If ( cST2Alias )->( FieldPos( 'TAFSTQUEUE' ) ) > 0
		cQuery += " ,ST2.TAFSTQUEUE TAFSTQUEUE "
	Else
		cQuery += " ,' ' TAFSTQUEUE "
	EndIf

	If ( cST2Alias )->( FieldPos( 'TAFREGPRED' ) ) > 0
		cQuery += " ,ST2.TAFREGPRED TAFREGPRED "
	Else
		cQuery += " ,' ' TAFREGPRED "
	EndIf

	cQuery += " FROM TAFST2 ST2 "

	cQuery += 	" INNER JOIN "

	cQuery +=		" ( SELECT "
	cQuery +=			" C1E.C1E_FILTAF, C1E.C1E_CODFIL, CR9.CR9_CODFIL "
	cQuery +=		" FROM "
	cQuery +=			RetSQLName("C1E") + " C1E "
	cQuery +=		" LEFT JOIN " + RetSQLName("CR9") +" CR9 ON "
	cQuery +=			" C1E.C1E_ID = CR9.CR9_ID "
	cQuery +=			" AND CR9.D_E_L_E_T_ = ' ' "
	cQuery +=		" WHERE "
	cQuery +=			" C1E.C1E_FILIAL = '" + xFilial( "C1E" ) + "' "
	cQuery +=			" AND C1E.D_E_L_E_T_ = ' ' "
	cQuery +=		" ) C1ECR9 ON "

	cQuery +=		" C1ECR9.C1E_CODFIL = ST2.TAFFIL OR C1ECR9.CR9_CODFIL = ST2.TAFFIL "

    cQuery +=	" LEFT JOIN TAFXERP XERP ON " 
	cQuery +=		" ST2.TAFKEY = XERP.TAFKEY "
	cQuery +=		" AND XERP.TAFTICKET = ST2.TAFTICKET "

    If ::nEscopo == 1
		cQuery += " AND ST2.TAFCODMSG = '2' "
	Else
		cQuery += " AND ST2.TAFCODMSG = '1' "
	EndIf
	
	cQuery +=	" WHERE XERP.D_E_L_E_T_ <> '*' "
	cQuery +=		" AND ST2.TAFFIL IN(" + ::cCodFil + ") "
	cQuery += 		" AND ST2.TAFDATA  BETWEEN '" + ::cDataIni + "' AND '" + ::cDataFim + "'"      
    cQuery +=		" AND ST2.D_E_L_E_T_ = ' ' "

	cQuery +=	" GROUP BY "
	cQuery +=		" C1ECR9.C1E_FILTAF, "
	cQuery +=		" XERP.TAFDATA, "
	cQuery +=		" XERP.TAFHORA, "
	cQuery +=		" XERP.TAFKEY, "
	cQuery +=		" XERP.TAFTICKET, "
	cQuery +=		" XERP.TAFSTATUS, "
	cQuery +=		" XERP.R_E_C_N_O_, "
	cQuery +=		" XERP.TAFCODERR, "
	cQuery +=		" XERP.TAFALIAS, "
	cQuery +=		" XERP.TAFRECNO, "
	cQuery +=		" ST2.TAFTPREG, "
	cQuery +=		" ST2.R_E_C_N_O_, "
	cQuery +=		" ST2.TAFSTQUEUE, "
	cQuery +=		" ST2.TAFREGPRED "

	cQuery += " UNION ALL "

	cQuery += " SELECT TAFFIL TAFFIL, TAFDATA	TAFDATA "
	cQuery += " ,TAFHORA		TAFHORA "
	cQuery += " ,TAFKEY			TAFKEY "
	cQuery += " ,TAFTICKET		TAFTICKET "
	cQuery += " ,'A'			TAFSTATUS "
	cQuery += " ,0	 			RECNOXERP "
	cQuery += " ,' '			TAFCODERR "
	cQuery += " ,' ' 			TAFALIAS "
	cQuery += " ,0 				TAFRECNO "
	cQuery += " ,TAFTPREG		LAYOUT "
	cQuery += " ,R_E_C_N_O_ 	ST2REC "

	If ( cST2Alias )->( FieldPos( 'TAFSTQUEUE' ) ) > 0
		cQuery += "	,TAFSTQUEUE 	TAFSTQUEUE "
	Else
		cQuery += "	,' ' 	TAFSTQUEUE "
	EndIf

	If ( cST2Alias )->( FieldPos( 'TAFREGPRED' ) ) > 0
		cQuery += "	,TAFREGPRED 	TAFREGPRED "
	Else
		cQuery += "	,' ' 	TAFREGPRED "
	EndIf

	cQuery += " FROM TAFST2 "

	cQuery += " WHERE (TAFSTATUS = '1' OR TAFSTATUS = '2') "
	cQuery += " AND TAFFIL IN(" + ::cCodFil + ") "
	cQuery += " AND TAFDATA  BETWEEN '" + ::cDataIni + "' AND '" + ::cDataFim + "'"  
	
    If ::nEscopo == 1
		cQuery += " AND TAFCODMSG = '2' "
	Else
		cQuery += " AND TAFCODMSG = '1' "
	EndIf
    
    cQuery += " AND D_E_L_E_T_ <> '*' "

	If 'INFORMIX' $ Upper( AllTrim( TcGetDB() ) )
 		cQuery := 'SELECT * FROM (' + cQuery + ')'
 	EndIf

	if Upper( AllTrim( TcGetDB() ) ) != 'DB2'
		cQuery := ChangeQuery(cQuery)
	endif	

	::cQuery := cQuery

Return Nil

/*/{Protheus.doc} CreateFields
Método responsavel pela criação dos campos e índices utilizados
no arquivo de trabalho e na browse.

@type Method
@author Evandro dos Santos O. Teixeira
@since 24/07/2016
@version 1.0
@obs Ver a definição do array na descrição do método SetCampos da superclasse.
/*/
Method CreateFields() Class TafTBrwHist

	Local aCmpsBrw as array
	Local aIndice  as array
	

	aCmpsBrw := {{"{||TAFFIL}"																,"Filial"		,040,0,"C","!@","TAFFIL"		,.T.}; //Filial	  
				,{"{||TAFDATA}"																,STR0070		,008,0,"D","!@","TAFDATA"		,.T.}; //Data	
				,{"{||TAFHORA}"																	,STR0071 		,008,0,"C","!@","TAFHORA"		,.T.}; //Hora
	      		,{"{||TAFKEY}"																	,STR0146 		,100,0,"C","!@","TAFKEY"			,.F.}; //TafKey
	      		,{"{||TAFTICKET}"																	,STR0069 		,100,0,"C","!@","TAFTICKET"		,.T.,"{||" + ::cVarBrowse + ":exibeMensagem()}",.T.}; //Ticket
	    	   	,{"{||" + ::cVarBrowse + ":GetNameStatus(TAFSTATUS,2,TAFCODERR)" + "}"	,STR0076 		,025,0,"C","!@","TAFSTATUS"		,.T.,"{||" + ::cVarBrowse + ":exibeMensagem()}",.T.}; 	//Status  
	      		,{"{||''}"																			,'' 			,016,0,"N","!@","RECNOXERP"		,.F.}; //*RecNo da XERP
	      		,{"{||''}"																			,'' 			,006,0,"C","!@","TAFCODERR"		,.F.}; //*Código de Erro na Integração
	      		,{"{||''}"																			,'' 			,003,0,"C","!@","TAFALIAS"		,.F.}; //*Alias do Registro no TAF
	      		,{"{||''}"																			,'' 			,016,0,"N","!@","TAFRECNO"		,.F.}; //*RecNo do Registro no TAF
	    	   	,{"{||LAYOUT}"																	,STR0145 		,015,0,"C","!@","LAYOUT"			,.F.}; //Layout
	      		,{"{||''}"																			,'' 			,016,0,"N","!@","ST2REC"			,.F.}; //*RecNo da ST2
				,{"{||''}"																			,'' 			,001,0,"C","!@","TAFSTQUEUE"	,.F.}; //*Status da Fila
				,{"{||''}"																			,''				,100,0,"C","!@","TAFREGPRED"	,.F.}} //*Predecessão

	If ::lTempInDb

		aIndice := {}

		aAdd( aIndice,	{ STR0145+"+"+STR0146+"+"+STR0069+"+"+STR0070+"+"+STR0071,"LAYOUT+TAFKEY+TAFTICKET+TAFDATA+TAFHORA+TAFSTATUS" } )
		aAdd( aIndice,	{ STR0069,"TAFTICKET"} )
		aAdd( aIndice,	{ STR0070+"+"+STR0071,"TAFDATA+TAFHORA" } )

	Else
		aIndice := {	{STR0070+"+"+STR0071,"DESCEND(DTOS(TAFDATA)+TAFHORA)","D"}; //"Data+Hora"
					  ,	{STR0069,"TAFTICKET"}; //"Ticket"
					  ,	{STR0145+"+"+STR0146+"+"+STR0069+"+"+STR0070+"+"+STR0071,"LAYOUT+TAFKEY+TAFTICKET+DESCEND(DTOS(TAFDATA)+TAFHORA)","D"}} //"Layout+Tafkey+Ticket+Data+Hora"
	EndIf
	::SetCampos(aCmpsBrw)
	::aIndice := aIndice
	
	::oBrowse:AddLegend('AllTrim(TAFSTATUS) ==  "A" '		,"BR_AZUL_CLARO" 		,STR0178) //"Aguardando Processamento"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          
	::oBrowse:AddLegend('AllTrim(TAFSTATUS) ==  "1" '		,"BR_VERDE" 			,STR0179) //"Registro Incluido no TAF" 
	::oBrowse:AddLegend('AllTrim(TAFSTATUS) ==  "2" '		,"BR_AMARELO" 		,STR0180) //"Registro Alterado no TAF"  
	::oBrowse:AddLegend('AllTrim(TAFSTATUS) ==  "3" '		,"BR_PRETO" 			,STR0181) //"Registro Excluido do TAF"  
	::oBrowse:AddLegend('AllTrim(TAFSTATUS) ==  "4" '		,"BR_LARANJA" 		,STR0187) //"Registro retornado para a Fila"
	::oBrowse:AddLegend('AllTrim(TAFSTATUS) ==  "7" '		,"BR_MARRON_OCEAN"	,STR0229) //"Registro não integrado devido erro de Predecessão."
	::oBrowse:AddLegend('!(AllTrim(TAFSTATUS) $ "1234A") '	,"BR_VERMELHO" 		,STR0182) //"Registro não Integrado no TAF"
	
Return Nil

/*/{Protheus.doc} apagaHistorico
Apaga todo o histórico do TAFKEY posicionado mantendo apenas o 
mais recente.

@type Method

@param	lAll - Determina se deve ser apagado todas as linhas do historio ou 
				se deve manter a última
@param	lST2 - Define se o TAFKEY deve ser apagado também da tabela TAFST2

@author Evandro dos Santos O. Teixeira
@since 24/07/2016
@version 1.0
/*/
Method apagaHistorico(lAll,lST2) Class TafTBrwHist

	Local cQuery   as char
	Local cBancoDB as char
	Local cConcat	 as char
	Local lRetorno as logical
	
	//Parameter lAll	as logical
	//Parameter lST2	as logical
	
	Default lAll := .F.
	Default lST2 := .F.
	
	
	
	cQuery := ""
	cBancoDB := Upper(AllTrim(TcGetDB()))
	cConcat := IIf(cBancoDB $ "ORACLE|INFORMIX|POSTGRES|DB2","||","+")
	lRetorno := .T.
	
	dbSelectArea(::cAliasTrb)
	//Posiciono no primeiro registro por que é o mais atual e o unico que não será apagado.
	(::cAliasTrb)->(dbGotop())
	
	if fPerAcess(,Alltrim( (::cAliasTrb)->LAYOUT ) )
	
		//Apago manualmente todos os itens deixando somente o ultimo ticket
		cQuery := " UPDATE TAFXERP "
		cQuery += " SET D_E_L_E_T_ = '*' ,"
		cQuery += "   R_E_C_D_E_L_ = "  + AllTrim(Str((::cAliasTrb)->RECNOXERP)) + " "
		cQuery += " WHERE TAFKEY   = '" + (::cAliasTrb)->TAFKEY +  "'"  
		If !lAll
			cQuery += " AND R_E_C_N_O_ <> " + AllTrim(Str((::cAliasTrb)->RECNOXERP))
		EndIf
		cQuery += " AND D_E_L_E_T_ <> '*'
		
		If TCSQLExec (cQuery) < 0
			::cErro := TCSQLError()
			lRetorno := .F.
		EndIf
		
		If lRetorno .And. lST2
		
			//Apago o TAFKEY na tabela ST2 
			cQuery := " UPDATE TAFST2 "
			cQuery += " SET D_E_L_E_T_ 		= '*' ,"
			cQuery += " 	  R_E_C_D_E_L_  	= '" 	+ AllTrim(Str((::cAliasTrb)->ST2REC))+ "'"
			cQuery += " WHERE TAFKEY 		= '" 	+ (::cAliasTrb)->TAFKEY +  "'"
			cQuery += "     AND R_E_C_N_O_ 	= " 	+ AllTrim(Str((::cAliasTrb)->ST2REC))+ " "
			cQuery += " AND D_E_L_E_T_ <> '*'
			
			If TCSQLExec (cQuery) < 0
				::cErro := TCSQLError()
				lRetorno := .F.
			EndIf
		EndIf
		
		::RefazDadosTrb(lST2,!lST2)
	
	endif
	
Return (lRetorno)

/*/{Protheus.doc} exibeMensagem
Retorna a Mensagem do campo TAFMSG da tabela compartilhada
TAFST2

@type Method
@author Evandro dos Santos O. Teixeira
@since 03/03/2017
@version 1.0
/*/
Method exibeMensagem() Class TafTBrwHist

	Local nRecST2 	as numeric
	Local nRecXERP 	as numeric
	Local aArea 	 	as array
	Local oModal		as object
	Local cErro		as char

	nRecST2 	:= 0
	nRecXERP 	:= 0
	aArea 		:=	{}
	oModal		:= Nil	
	cErro		:= ""	

	nRecST2  := &(::cAliasTrb + "->ST2REC")
	nRecXERP := &(::cAliasTrb + "->RECNOXERP")
	
	aArea := (cST2Alias)->(GetArea())
	
	if fPerAcess(,Alltrim( &( ::cAliasTrb + "->LAYOUT" ) ) )
	
		oModal := FWDialogModal():new()
		oModal:setTitle(STR0168) //"Mensagem de Integração"
		oModal:setFreeArea(250, 250)
		oModal:setEscClose(.T.)
		oModal:setBackground(.T.)
		oModal:setCloseButton(.F.)
		oModal:createDialog()
		oModal:addCloseButton(,STR0169)
		
		If nRecXERP > 0
			(cXERPAlias)->(dBGoTo(nRecXERP))
			cErro := (cXERPAlias)->TAFERR
		EndIf
	
		(cST2Alias)->(dBGoTo(nRecST2))
		If (cST2Alias)->TAFCODMSG == "2"
			cTafMsg := xIdentXML((cST2Alias)->TAFMSG)
		Else
			cTafMsg := (cST2Alias)->TAFMSG	
		EndIf
	
		//Nos casos em que exista mensagem de erro do registro, a tela exibe as duas informações
		If Empty( cErro )
			TMultiGet():New( 030, 020, { || cTafMsg }, oModal:GetPanelMain(), 210, 190,, .T. ,,,, .T.,,,,,, .T.,,,,, .T. )
		Else
			TSay():New( 010, 020, {||STR0170}, oModal:GetPanelMain(),,,,,, .T.,,, 210, 010 ) //"Ocorrência(s) de erro"
			TMultiGet():New( 020, 020, { || cErro }, oModal:GetPanelMain(), 210, 095,, .T. ,,,, .T.,,,,,, .T.,,,,, .T. )
			TSay():New( 125, 020, {||STR0171}, oModal:GetPanelMain(),,,,,, .T.,,, 210, 010 ) //"Mensagem"
			TMultiGet():New( 135, 020, { || cTafMsg }, oModal:GetPanelMain(), 210, 095,, .T. ,,,, .T.,,,,,, .T.,,,,, .T. )
		EndIf
		
		oModal:Activate()
	
	endif
	
	RestArea(aArea)
	TAFEncArr(@aArea)
	
Return Nil

//*************************************************************************************************************************************
//* NEW CLASS - STATUS																															 *
//*************************************************************************************************************************************
/*/{Protheus.doc} TafTBrwStatus
Browse com os registros agrupados de acordo com seu status

@type class
@author Evandro
@since 24/07/2016
@version 1.0
/*/
Class TafTBrwStatus From TafBrowseTrb

	Data nVisao
	Data cDataIni
	Data cDataFim
	Data cCodFil
	Data cQuery as char
	Data aIndice as array

	Method New(aCampos,lCria,aParam,cVarBrowse) Constructor	
	Method CreateQry()
	Method CreateFields()

EndClass

/*/{Protheus.doc} New
Metodo Construtor

@param - aCampos 		- Array com os campos utilizados tanto na browse
						quanto no arquivo de trabalho. (opcional)
@param - lCria 		- Determina que o browse vai obrigatoriamente utilizar
					 	um arquivo de trabalho com estrutura (opcional)
@param - aParam		- Parâmetros para criação do browse.
@param - cVarBrowse 	- Nome utilizado na criação do objeto FWMBrowse (obrigatorio) 	
@type Method
@author Evandro dos Santos O. Teixeira
@since 24/07/2016
@version 1.0
/*/
Method New(aCampos,lCria,aParam,cVarBrowse) Class TafTBrwStatus

	//Parameter aCampos		as array
	//Parameter lCria			as logical
	//Parameter aParam		as array
	//Parameter cVarBrowse	as char

	Default aCampos := {}
	Default lCria := .F.
	
	::cDataIni	:= DTOS(aParam[1])
	::cDataFim	:= DTOS(aParam[2])
	::nVisao 	:= aParam[3]
	::cCodFil	:= aParam[4]

	_Super:New(aCampos,lCria,cVarBrowse)
	::CreateFields()
	::CreateTrb(.T.)
	::SetCollumns()
	::CreateQry()
	If !::lTempInDb
		::SetArea(.T.,,,.F.,.F.)
	EndIf
	::SetIndice(,.F.)
	::SetFiltro(.F.)
	If ::lTempInDb
		::CreateTabInDb()
	EndIf
	::PreencheTrb()
	::SetDescription(STR0176) //"Status de Integração dos Registros"
	::DisableDetails()
	::SetAmbiente(.F.)
	::SetWalkThru(.F.)
	::SetProfileID('1')
	
Return Nil 

/*/{Protheus.doc} CreateQry
Método responsavel pela criação da Query utilizada
para preencher o arquivo de trabalho.

Os Status definidos para o retorno da consulta são:
E = Com Erros Impeditivos
Registro da TAFXERP com Status maior que 3 
I = Integrados
Registro da TAFXERP com Status menor ou igual a 3
A = Aguardando Processamento (Job 2)
Registros na TAFST2 que ainda não foram integrados

Para evitar duplicidade no retorno da consulta o método
realiza uma busca para indentificar o ultimo registro da TAFXERP olhando 
data e hora do processamento de acordo com o TAFKEY, pois podem
existir N tafkeys iguais na TAFXERP.

@type Method
@author Evandro dos Santos O. Teixeira
@since 24/07/2016
@version 1.0
/*/
Method CreateQry() Class TafTBrwStatus

	Local cQuery   as char
	Local cBancoDB as char
	Local cConcat	 as char

	cQuery := ""
	cBancoDB := Upper(AllTrim(TcGetDB()))
	cConcat := IIf(cBancoDB $ "ORACLE|INFORMIX|POSTGRES|DB2","||","+")
	
	cQuery := " SELECT	'A'					TAFSTATUS "
	cQuery += " 		,COUNT(*)				TOTAL "
	cQuery += " FROM TAFST2 XST2 "
	cQuery += " WHERE (XST2.TAFSTATUS = '1' OR XST2.TAFSTATUS = '2') "
	cQuery += " AND XST2.D_E_L_E_T_ <> '*' "
	cQuery += " AND XST2.TAFFIL IN(" + ::cCodFil + ") "
	cQuery += " AND XST2.TAFDATA BETWEEN '" + ::cDataIni + "' AND '" + ::cDataFim + "' "
	
	cQuery += "UNION ALL "

	cQuery += " SELECT	'E'								TAFSTATUS "
	cQuery += " 			,COUNT(*)						TOTAL "
	cQuery += " FROM TAFXERP K1 INNER JOIN "
	cQuery += " ( "
	cQuery += " SELECT TAFKEY , MAX(TAFDATA " + cConcat + " TAFHORA) CHAVE "
	cQuery += " FROM TAFXERP "
	cQuery += " WHERE D_E_L_E_T_ <> '*' "
	cQuery += " AND TAFDATA  BETWEEN '" + ::cDataIni + "' AND '" + ::cDataFim + "' " 
	cQuery += " GROUP BY TAFKEY "	
	cQuery += " ) MAXREG ON (K1.TAFDATA " + cConcat + " K1.TAFHORA) = MAXREG.CHAVE "
	cQuery += " AND K1.TAFKEY = MAXREG.TAFKEY "
	cQuery += " INNER JOIN TAFST2 ST2 ON K1.TAFKEY = ST2.TAFKEY " 
	cQuery += " AND K1.TAFTICKET = ST2.TAFTICKET "
	cQuery += " WHERE K1.D_E_L_E_T_ <> '*' " 
	cQuery += " AND ST2.TAFFIL IN(" + ::cCodFil + ") "
	cQuery += " AND ST2.D_E_L_E_T_ <> '*' "
	cQuery += " AND K1.TAFSTATUS > '3' "
	cQuery += " AND K1.TAFDATA  BETWEEN '" + ::cDataIni + "' AND '" + ::cDataFim + "' "

	cQuery += " UNION ALL "

	cQuery += " SELECT	'I'					TAFSTATUS "
	cQuery += " 		,COUNT(*)				TOTAL "
	cQuery += " FROM TAFXERP K2 INNER JOIN "
	cQuery += " ( "
	cQuery += " SELECT TAFKEY , MAX(TAFDATA " + cConcat + " TAFHORA) CHAVE "
	cQuery += " FROM TAFXERP " 
	cQuery += " WHERE D_E_L_E_T_ <> '*' "
	cQuery += " AND TAFDATA  BETWEEN '" + ::cDataIni + "' AND '" + ::cDataFim + "' " 
	cQuery += " GROUP BY TAFKEY "	
	cQuery += " ) MAXREG ON (K2.TAFDATA " + cConcat + " K2.TAFHORA) = MAXREG.CHAVE "
	cQuery += " AND K2.TAFKEY = MAXREG.TAFKEY "
	cQuery += " INNER JOIN TAFST2 ST2 ON K2.TAFKEY = ST2.TAFKEY " 
	cQuery += " AND ST2.D_E_L_E_T_ <> '*' "
	cQuery += " AND ST2.TAFFIL IN(" + ::cCodFil + ") "
	cQuery += " AND K2.TAFTICKET = ST2.TAFTICKET "
	cQuery += " WHERE K2.D_E_L_E_T_ <> '*' "
	cQuery += " AND (K2.TAFSTATUS = '1' OR K2.TAFSTATUS = '2' OR K2.TAFSTATUS = '3') "
	cQuery += " AND K2.TAFDATA  BETWEEN '" + ::cDataIni + "' AND '" + ::cDataFim + "' "
	
	If 'INFORMIX' $ cBancoDB
 		cQuery := 'SELECT * FROM (' + cQuery + ')'
 	EndIf
	
	If Upper( AllTrim( TcGetDB() ) ) != 'DB2'
		cQuery := ChangeQuery(cQuery)
	EndIf 

	::cQuery := cQuery

Return Nil 

/*/{Protheus.doc} CreateFields
Método responsavel pela criação dos campos e índices utilizados
no arquivo de trabalho e na browse.

@type Method
@author Evandro dos Santos O. Teixeira
@since 24/07/2016
@version 1.0
@obs Ver a definição do array na descrição do método SetCampos da superclasse.
/*/
Method CreateFields() Class TafTBrwStatus

	Local aCmpsBrw as array
	Local aIndice  as array
	
	aCmpsBrw := {}
	aIndice  := {}
	
	aCmpsBrw := {	 {"{||" + ::cVarBrowse + ":GetNameStatus(TAFSTATUS)}"	,STR0076,025,0,"C","!@","TAFSTATUS"	,.T.}; //Status  
	    	     	,{"{||TOTAL}"													,STR0152,006,0,"N","!@","TOTAL"			,.T.}} //Total

	aIndice := {{STR0076,"TAFSTATUS"}} //"Status"  
	
	::SetCampos(aCmpsBrw)
	::aIndice := aIndice

Return Nil


