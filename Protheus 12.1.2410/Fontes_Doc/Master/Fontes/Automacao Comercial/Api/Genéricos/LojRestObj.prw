#INCLUDE "PROTHEUS.CH"
#INCLUDE "LOJRESTOBJ.CH"
#INCLUDE "DEFRESTOBJ.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} Classe LojRestObj
    Classe para tratamento de APIs em Rest do Varejo
/*/
//-------------------------------------------------------------------
Class LojRestObj

    Data lSuccess       As Logical
	Data cError         As Character
	Data cDetail        As Character
    Data nStatusCode    As Numeric

    Data cInternalId    As Character    //Chave única do registro

	Data oWsRestObj     As Object       //Objeto WsResFul recebido
    Data oFields        As Object       //HashMap com todos os campos
    Data aRetFields     As Array        //Campos que serão retornados
    Data aTables        As Object       //Tabelas utilizadas na manipulação dos dados
    Data aExecAuto      As Array        //Array com campos carregados com conteúdopara realizar ExecAuto
    Data oEaiObjRet     As Object
    Data oEaiObjRec     As Object
    Data lRetHasNext    As Logical      //Define se o tipo do retorno será um array

    Data nPage          As Numeric
    Data nPageSize      As Numeric
    Data aOrder         As Array
    Data oJsonFilter    As Object
    Data aGroupBy       As Array
    Data cSum           As Character

    Data cBody          As Character    
    Data cSelect        As Character
    Data cFields        As Character
    Data cWhere         As Character
    Data cGroupBy       As Character
    Data cOrderBy       As Character
    Data cTable         As Character
    Data cAliasQuery    As Character

    Data cFil           As Character 
    Data cFilBkp        As Character
    Data lChangeFil     As Logical

	Method New(oWsRestObj)  Constructor

    Method Get()
    Method Post()
    Method Success()
    Method GetReturn()
    Method SelectFields()
    Method GetError()
    Method GetStatus()
    Method BindFields()
    Method PostLoja701()
    
    Method SetFields()
    Method SetTables()
    Method SetSelect(cTable)
    Method Select()
    Method ExecAuto()    
    Method ChangeBranch()
    Method RestoreBranch()

    //Metodos auxiliares para tratamento interno da classe
    Method TreatField(aField)  //Metodo para efetuar o tratamento das Tags que serão retornadas no resultado da consulta

EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New
Método construtor da Classe

@param oWsRestObj - Objeto WSRESTFUL da API 

@author  Rafael Tenorio da Costa
@since   16/07/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Method New(oWsRestObj) Class LojRestObj

    self:oFields     := HmNew()
    self:aTables     := {}
	self:oWsRestObj  := oWsRestObj
    self:aRetFields  := {}
    self:nPage       := 1
    self:nPageSize   := 10
    self:aOrder      := {}
    self:aGroupBy    := {}
    self:cSum        := ""
    self:aExecAuto   := {}
    self:oJsonFilter := JsonObject():New()
    self:oEaiObjRet  := Nil //Utilizado o FwEaiObj, porque ele facilita o retorno para definir se eh um array ou não
    self:oEaiObjRec  := Nil
    self:lSuccess    := .T.
	self:cError      := ""
	self:cDetail     := ""
    self:cSelect     := ""
    self:cFields     := ""
    self:cWhere      := ""
    self:cGroupBy    := ""
    self:cOrderBy	 := ""
    self:cTable      := ""
    self:cAliasQuery := GetNextAlias()
    self:lRetHasNext := .F.
    self:cBody       := ""
    self:nStatusCode := 500
    self:cInternalId := ""

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Get
Carrega as propriedade de filtros e ordenação e chama a execução da consulta

@author  Rafael Tenorio da Costa
@since   16/07/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Method Get() Class LojRestObj

    Local nX := 1

    //Carrega os campos que serão retornados
    self:SetFields()

    If self:oWsRestObj:Fields <> Nil .And. !Empty(self:oWsRestObj:Fields)
        self:aRetFields := StrTokArr( Alltrim( Upper(self:oWsRestObj:Fields) ), ",")
    EndIf

    If self:oWsRestObj:Page <> Nil .And. self:oWsRestObj:Page > 0
        self:nPage := self:oWsRestObj:Page
    EndIf

    If self:oWsRestObj:PageSize <> Nil .And. self:oWsRestObj:PageSize > 0
        self:nPageSize := self:oWsRestObj:PageSize
    EndIf

    If self:oWsRestObj:Order <> Nil .And. !Empty(self:oWsRestObj:Order)
        self:aOrder := StrTokArr( Alltrim( Upper(self:oWsRestObj:Order) ), ",")
    EndIf

    If self:oWsRestObj:aQueryString <> Nil .And. ValType(self:oWsRestObj:aQueryString) == "A" .And. Len(self:oWsRestObj:aQueryString) > 0 

        For nX := 1 To Len(self:oWsRestObj:aQueryString)
            If !( Upper( AllTrim(self:oWsRestObj:aQueryString[nX][1]) ) $ "FIELDS|PAGE|PAGESIZE|ORDER" )
                self:oJsonFilter[self:oWsRestObj:aQueryString[nX][1]] := self:oWsRestObj:aQueryString[nX][2]
            EndIf
        Next nX
    EndIf

    self:Select()

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} Post
Carrega as propriedades e chama a execução da Inclusão

@author  rafael.pessoa
@since   09/08/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Method Post() Class LojRestObj

    //Carrega as tabelas que serão manipuladas
    self:SetTables()

    //Carrega o que foi recebido pelo Post
    self:cBody := self:oWsRestObj:GetContent()

    self:oEaiObjRec := FwEaiObj():New()
    self:oEaiObjRec:SetRestMethod("POST")
    self:oEaiObjRec:Activate()
    self:oEaiObjRec:LoadJson( self:cBody )

    self:BindFields()
    self:ChangeBranch()

    If self:lSuccess
        Begin Transaction
            self:ExecAuto()      
        End Transaction
    EndIf

    If self:lSuccess

        self:oEaiObjRet := FwEaiObj():New()
        self:oEaiObjRet:SetRestMethod("POST")
        self:oEaiObjRet:Activate()
        self:oEaiObjRet:LoadJson( self:cBody )
    EndIf

    self:RestoreBranch()

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} PostLoja701
Carrega as propriedades e chama a execução da Inclusão da venda
por ExecAuto do LOJA701

@author  Bruno Almeida
@since   08/06/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Method PostLoja701() Class LojRestObj

    //Carrega as tabelas que serão manipuladas
    Self:SetTables()

    //Carrega o que foi recebido pelo Post
    Self:cBody := Self:oWsRestObj:GetContent()

    Self:oEaiObjRec := FwEaiObj():New()
    Self:oEaiObjRec:SetRestMethod("POST")
    Self:oEaiObjRec:Activate()
    Self:oEaiObjRec:LoadJson( Self:cBody )

    Self:BindFields()
    Self:ChangeBranch()

    If Self:lSuccess
        Begin Transaction
            Self:ExecLoja701()      
        End Transaction
    EndIf

    If Self:lSuccess

        Self:oEaiObjRet := FwEaiObj():New()
        Self:oEaiObjRet:SetRestMethod("POST")
        Self:oEaiObjRet:Activate()
        Self:oEaiObjRet:LoadJson( Self:cBody )
    EndIf

    Self:RestoreBranch()

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} SetFields
Carrega os campos da tabela

@author  Rafael Tenorio da Costa
@since   16/07/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Method SetFields() Class LojRestObj

    Local aFields := FwSX3Util():GetAllFields(self:cTable, .F.)
    Local nField  := 0

    For nField:=1 To Len(aFields)
        //O preenchimento do HashMap abaixo, ficou desta maneira por compatibilidade com versões anteriores
        //                   Tag			  Campo           Expressão que será executada para gerar o retorno   Tag que será utilizada para preencher o objeto de retorno   Tipo do campo
        HmAdd(self:oFields, {aFields[nField], aFields[nField], aFields[nField]                                  , aFields[nField]                                           , GetSx3Cache(aFields[nField], 'X3_TIPO'),"" } , 1, 3)
    Next nField

    aSize(aFields, 0)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} SetTables
Carrega as tabelas que serão manipuladas

@author  rafael.pessoa
@since   09/08/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Method SetTables() Class LojRestObj
    Aadd(self:aTables, {self:cTable, ""})
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} ExecAuto
Executa a gravação

@author  rafael.pessoa
@since   20/08/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Method ExecAuto() Class LojRestObj

    self:lSuccess   := .F.
    self:cError     := STR0011          //"Não existem tabelas para serem retornadas."

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} SetSelect
Carrega a query que será executada

@author  Rafael Tenorio da Costa
@since   16/07/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Method SetSelect(cTable) Class LojRestObj

    Default cTable := ""

    If !Empty(cTable)

        self:cTable := cTable

        self:cSelect := "SELECT * FROM " + RetSqlName(cTable)
        self:cWhere  := "WHERE D_E_L_E_T_ = ' '"
    Else

        self:lSuccess   := .F.
        self:cError     := STR0009      //"Tabela não foi informada."
    EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Select
Valida os campos de pesquisa e ordem da query e executa a consulta

@author  Rafael Tenorio da Costa
@since   16/07/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Method Select() Class LojRestObj

	Local nX 		   	:= 0
    Local cQuery        := ""
	Local cWhere       	:= IIF( !Empty(self:cWhere), self:cWhere, " WHERE 1=1" )
	Local cOrder	   	:= ""
	Local aTemp		   	:= {}
	Local cProperty		:= ""
	Local aAux			:= {}
    Local cDataBase     := Upper( AllTrim( TcGetDb() ) )
    Local cRecords      := cValToChar( (self:nPage * self:nPageSize) + 1)   //Foi somado 1 a mais para ajudar a definir a TAG "hasNext": no retorno do json

    If Empty(self:cSelect)

        self:lSuccess := .F.
        self:cError   := STR0003    //"Não existe select para ser executado."
    Else

        //Carrega Filtros
        If self:oJsonFilter <> Nil

            aTemp := self:oJsonFilter:getNames()

            For nX := 1 To Len(aTemp)

                aAux	  := {}
                cProperty := AllTrim( Upper(aTemp[nX]) )

                If HmGet(self:oFields, cProperty, @aAux) .And. Len(aAux) > 0

                    cWhere += " AND "

                    If ValType(self:oJsonFilter[aTemp[nX]]) == "C"
                        self:oJsonFilter[aTemp[nX]] := "'" + self:oJsonFilter[aTemp[nX]] + "'"
                    Else
                        self:oJsonFilter[aTemp[nX]] := cValToChar( self:oJsonFilter[aTemp[nX]] )
                    EndIf

                    cWhere += aAux[1][CAMPO] + " = " + self:oJsonFilter[aTemp[nX]]
                Else
                    self:lSuccess := .F.
                    self:cError  += I18n(STR0004, {cProperty, STR0005}) + CRLF	//"A propriedade #1 não é valida para #2"	//"filtro"
                EndIf
            Next nX
        EndIf

        //Seta Ordem
        aTemp  := self:aOrder
        For nX := 1 To Len(aTemp)
                
            aAux := {}

            If SubStr(aTemp[nX],1,1) == "-"

                cProperty := AllTrim( Upper( SubStr(aTemp[nX], 2) )	)

                If !Empty(cProperty)

                    If HmGet(self:oFields, cProperty, @aAux) .And. !Empty(aAux[1][CAMPO])
                        cOrder += aAux[1][CAMPO] + " desc,"
                    Else
                        self:lSuccess := .F.
                        self:cError  += I18n(STR0004, {cProperty, STR0006}) + CRLF	//"A propriedade #1 não é valida para #2"	//"ordenação"
                    EndIf
                EndIf
            Else

                cProperty := AllTrim( Upper( IIF(SubStr(aTemp[nX], 1, 1) == "+", SubStr(aTemp[nX], 2), aTemp[nX]) )	)

                If !Empty(cProperty)

                    If HmGet(self:oFields, cProperty, @aAux) .And. !Empty(aAux[1][CAMPO])
                        cOrder += aAux[1][CAMPO] + ","
                    Else
                        self:lSuccess := .F.
                        self:cError  += I18n(STR0004, {cProperty, STR0006}) + CRLF	//"A propriedade #1 não é valida para #2"	//"ordenação"
                    EndIf
                EndIf
            EndIf
        Next nX

        If !Empty(cOrder)
            cOrder := SubStr(cOrder, 1, Len(cOrder) - 1)
            cOrder := " ORDER BY " + cOrder
        EndIf

        //Executa query
        If self:lSuccess

            //Carrega campos retornados pela query
            self:SelectFields()
            self:cSelect  := StrTran(self:cSelect , "*", self:cFields)
            self:cGroupBy := StrTran(self:cGroupBy, "*", self:cFields)

            //Adiciona controle de paginação direto na query
            If cDataBase <> "ORACLE"
                If SubStr( Upper(self:cSelect), 1, 6) == "SELECT"
                    self:cSelect := "SELECT TOP " + cRecords + SubStr(self:cSelect, 7)
                EndIf
            Else
                cWhere := cWhere + " AND ROWNUM <= " + cRecords
            EndIf

            //Carrega query
            cQuery := self:cSelect +" "+ cWhere +" "+ self:cGroupBy +" "+ cOrder
            cQuery := ChangeQuery(cQuery)

            self:cSelect := cQuery
            self:cWhere  := cWhere

            DbUseArea(.T., "TOPCONN", TcGenQry( , , self:cSelect), self:cAliasQuery, .T., .F.)

            If (self:cAliasQuery)->( Eof() )
                self:lSuccess := .F.
                self:cError   := STR0007                    //"Não foram localizados registros com esses parâmetros."
                self:cDetail  := STR0008 + self:cSelect     //"Consulta executada: "
            EndIf
        EndIf
    EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Success
Define o resultado da operação

@author  Rafael Tenorio da Costa
@since   16/07/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Method Success() Class LojRestObj
Return self:lSuccess

//-------------------------------------------------------------------
/*/{Protheus.doc} GetReturn
Retorna json com resultado da consulta

@author  Rafael Tenorio da Costa
@since   16/07/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Method GetReturn() Class LojRestObj

    Local nCount     := 0
    Local nFields    := Len(self:aRetFields)    
    Local nX         := 0
    Local aAux       := {}
    Local lFirst     := .T.
    Local nPageStart := IIF(self:nPage > 1, ((Self:nPage - 1) * Self:nPageSize) + 1, self:nPage)
    Local nPageTotal := self:nPageSize * self:nPage

    If self:oEaiObjRet == Nil

        self:oEaiObjRet := FwEaiObj():New()
        self:oEaiObjRet:Activate()

        if Select(self:cAliasQuery) > 0
        
            //Define retorno do json como array se existir mais que 1 registro
            (self:cAliasQuery)->( DbSkip() )
            If self:lRetHasNext .Or. !(self:cAliasQuery)->( Eof() )
                self:oEaiObjRet:setBatch(1)
            EndIf
            (self:cAliasQuery)->( DbGoTop() )

            While !(self:cAliasQuery)->( Eof() )

                nCount++

                //Controla paginação e carregamento do proximo item
                If nCount < nPageStart
                    (self:cAliasQuery)->( DbSkip() )
                    Loop
                ElseIf nCount > nPageTotal
                    Exit
                ElseIf !lFirst
                    self:oEaiObjRet:NextItem()            
                EndIf

                //Preenche retorno com tags selecionadas
                If nFields > 0

                    For nX:=1 To nFields
                        If HmGet(self:oFields, self:aRetFields[nX], @aAux)

                            self:TreatField(aAux[1])
                        EndIf
                    Next nX
                
                //Preenche retorno com todas as tags
                Else

                    If HmList(self:oFields, @aAux)
                        For nX:=1 To Len(aAux)

                            self:TreatField(aAux[nX][2][1])
                        Next nX
                    EndIf
                EndIf

                (self:cAliasQuery)->( DbSkip() )
                lFirst := .F.
            EndDo
            (self:cAliasQuery)->( DBCloseArea() )            
        
        endif
        
        If nCount > nPageTotal
            self:oEaiObjRet:SetHasNext(.T.)
        EndIf
        
    EndIf
    
Return self:oEaiObjRet:getJson( , .T.)

//-------------------------------------------------------------------
/*/{Protheus.doc} SelectFields
Campos utilizados no select

@author  Rafael Tenorio da Costa
@since   16/07/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Method SelectFields() Class LojRestObj

    Local nX        := 0
    Local aAux      := {}
    Local cField    := ""

    If Empty(self:cFields)

        If HmList(self:oFields, @aAux)
            For nX:=1 To Len(aAux)

                cField := aAux[nX][2][1][CAMPO]

                If !Empty(cField)
                    self:cFields += cField + ", "
                EndIf
            Next nX
        EndIf

        self:cFields := SubStr(self:cFields, 1, Len(self:cFields) - 2)
    EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} BindFields
Mepeia e adiciona os campos em array para realizar ExectAuto

@author  rafael.pessoa
@since   16/08/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Method BindFields() Class LojRestObj

    Local nX        := 0    
    Local nCont     := 0
    Local nTable    := 0
    Local nItem     := 0
    Local aAuxExec  := {}
    Local aAux      := {}
    Local aList     := {}    
    Local aItem     := {}
    Local oList     := Nil
        
    If self:oEaiObjRec <> Nil

        For nTable:=1 To Len(self:aTables)

            self:cTable  := self:aTables[nTable][1]
            self:oFields := HmNew()                

            //Carrega os campos que serão alterados
            self:SetFields()

            HmList(self:oFields, @aAux)

            If Empty( self:aTables[nTable][2] )

                For nX:=1 To Len(aAux)

                    If !Empty( aAux[nX][2][1][CAMPO] ) .And. self:oEaiObjRec:getPropValue( aAux[nX][2][1][TAG] ) <> Nil .And. (self:cTable)->( ColumnPos(aAux[nX][2][1][CAMPO]) ) > 0
                        Aadd( aAuxExec, {aAux[nX][2][1][CAMPO], LjiOVldTag( self:oEaiObjRec, aAux[nX][2][1][TAG], aAux[nX][2][1][TIPOCAMPO], .T.) , Nil} )

                        If aAux[nX][2][1][CHAVE] == 'BRANCHID'
                            Self:cFil := aAuxExec[Len(aAuxExec)][2]
                        EndIf

                    EndIf
                Next nX

            Else

                aList := Separa( self:aTables[nTable][2], ":")
                If Len(aList) > 0

                    oList := self:oEaiObjRec:getPropValue( aList[1] )
                    For nCont:=2 To Len(aList)
                        oList := oList:getPropValue( aList[nCont] )
                    Next nCont
                EndIf
                aSize(aList, 0)

                If oList <> Nil

                    For nItem := 1 To Len(oList)
                        
                        For nX:=1 To Len(aAux)

                            If !Empty( aAux[nX][2][1][CAMPO] ) .And. oList[nItem]:getPropValue( aAux[nX][2][1][TAG] ) <> Nil  .And. (self:cTable)->( ColumnPos(aAux[nX][2][1][CAMPO]) ) > 0
                                Aadd( aItem, {aAux[nX][2][1][CAMPO], LjiOVldTag(oList[nItem], aAux[nX][2][1][TAG], aAux[nX][2][1][TIPOCAMPO], .T.) , Nil} )
                            EndIf
                        Next nX

                        Aadd(aAuxExec, aClone(aItem))
                        aSize(aItem, 0)
                    Next nItem

                    FwFreeObj(oList)
                EndIf
            EndIf

            Aadd(self:aExecAuto, aClone(aAuxExec))

            aSize(aAux    , 0)
            aSize(aAuxExec, 0)

            FwFreeObj(self:oFields)
        Next nTable

    EndIf

    aSize(aAuxExec, 0)
    aSize(aAux    , 0)
    aSize(aList   , 0)
    aSize(aItem   , 0)

    FwFreeObj(oList)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} GetError
Retorna descrição do erro

@author  Rafael Tenorio da Costa
@since   16/07/2019 	 
@version 1.0
/*/
//-------------------------------------------------------------------
Method GetError() Class LojRestObj

    Local cError := self:cError + CRLF + self:cDetail

    /*
    self:oJsonReturn["code"]            := 404
    self:oJsonReturn["message"]         := self:cError
    self:oJsonReturn["detailedMessage"] := self:cDetail
    self:oJsonReturn["helpUrl"]         := ""
    self:oJsonReturn["details"]         := {}
    Aadd(self:oJsonReturn["details"], JsonObject():New() )
        self:oJsonReturn["details"][1]["code"]            := ""
        self:oJsonReturn["details"][1]["message"]         := ""
        self:oJsonReturn["details"][1]["detailedMessage"] := ""
        self:oJsonReturn["details"][1]["helpUrl"]         := ""
    */

Return cError

//-------------------------------------------------------------------
/*/{Protheus.doc} GetStatus
Retorna Status da Requisição HTTP

@author  rafael.pessoa
@since   09/08/2019 	 
@version 1.0
/*/
//-------------------------------------------------------------------
Method GetStatus() Class LojRestObj
Return self:nStatusCode


//-------------------------------------------------------------------
/*/{Protheus.doc} ChangeBranch
Troca a filial caso o que foi passado para o POST seja diferente
da variavel cFilAnt

@author  Varejo
@since   10/09/2019 	 
@version 1.0
/*/
//-------------------------------------------------------------------
Method ChangeBranch() Class LojRestObj

    If Self:cFil <> cFilAnt
        If FWFilExist(,Self:cFil)
            Self:cFilBkp    := cFilAnt
            cFilAnt         := Self:cFil
            self:lChangeFil := .T.
        Else
            self:lChangeFil := .F.
            self:lSuccess   := .F.
            self:cError     := STR0012 + Self:cFil //"Filial informada não existe no sistema. TAG: BRANCHID = "
            self:nStatusCode:= 404
        EndIf
    EndIf
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} RestoreBranch
Volta a filial para o cFilAnt

@author  Varejo
@since   10/09/2019 	 
@version 1.0
/*/
//-------------------------------------------------------------------
Method RestoreBranch() Class LojRestObj
    If self:lChangeFil
        cFilAnt := self:cFilBkp
    EndIf
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} TreatField
Metodo para efetuar o tratamento das Tags que serão retornadas no resultado da consulta

@author  Rafael Tenorio da Costa
@version 1.0
/*/
//-------------------------------------------------------------------
Method TreatField(aField,cValue,nMomento) Class LojRestObj

    Local cTag       := ""
    Local cExpResult := ""
    Local xResult	 := Nil

    Default nMomento := RETORNO

    If nMomento == BUSCA .Or. Empty(aField[CAMPO]) .Or. (self:cAliasQuery)->( ColumnPos(aField[CAMPO]) ) > 0
 
        If nMomento == RETORNO

            cTag	   	:= aField[TAG]
            cExpResult 	:= aField[EXPRESSAO]
            
            If (self:cAliasQuery)->( ColumnPos(cExpResult) ) > 0
                xResult		:= (self:cAliasQuery)->&(cExpResult)
            Else
                xResult		:= &(cExpResult)
            Endif

            self:oEaiObjRet:setProp(cTag, xResult)

        ElseIf nMomento == BUSCA 
            
            If Len(aField) >= EXPRESSAOBUSCA .And. !Empty(aField[EXPRESSAOBUSCA])
                
                cExpResult := aField[EXPRESSAOBUSCA]
                xResult    := &(cExpResult)
                cValue     := xResult
            EndIf

        Else
            // -- Momento não implementado
        EndIf 

    EndIf

Return Nil
