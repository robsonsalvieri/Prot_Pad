#INCLUDE "PROTHEUS.CH"
#INCLUDE "PSHTOOLSOBJ.CH"

#DEFINE CHAVE       1
#DEFINE CAMPO       2
#DEFINE EXPRESSAO   3
#DEFINE TAG         4
#DEFINE TIPOCAMPO   5

//-------------------------------------------------------------------
/*/{Protheus.doc} Classe RetailItemObj
    Classe para tratamento da API de logs do Varejo integração
/*/
//-------------------------------------------------------------------
Class SHPApiMonitorObj From LojRestObj

	Method New(oWsRestObj)  Constructor

    Method SetFields()
    Method Select()
    Method Delete(cId)

EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New
Método construtor da Classe
@param oWsRestObj - Objeto WSRESTFUL da API
@version 1.0
/*/
//-------------------------------------------------------------------
Method New(oWsRestObj) Class SHPApiMonitorObj

    _Super:New(oWsRestObj)

    self:SetSelect("MHL")

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} SetFields
Carrega os campos que serão retornados
@version 1.0
/*/
//-------------------------------------------------------------------
Method SetFields() Class SHPApiMonitorObj

    HmAdd(self:oFields, {"EMPRESA"					, ""			, "cEmpAnt"		, "empresa"					}, 1, 3)
    HmAdd(self:oFields, {"FILIAL"					, "MHL_FILIAL"  , "MHL_FILIAL"  , "filial"					}, 1, 3)
    HmAdd(self:oFields, {"SEQUECIA"					, "MHL_SEQ"     , "MHL_SEQ"     , "sequencia"				}, 1, 3)
    HmAdd(self:oFields, {"TABELA"					, "MHL_ALIAS"   , "MHL_ALIAS"   , "tabela"				    }, 1, 3)
    HmAdd(self:oFields, {"RECNO"					, "MHL_RECNO"   , "MHL_RECNO"   , "recno"					}, 1, 3)
    HmAdd(self:oFields, {"STATUS"					, "MHL_STATUS"  , "MHL_STATUS"  , "status"		    		}, 1, 3)
    HmAdd(self:oFields, {"DATA"						, "MHL_DATA"    , "MHL_DATA"    , "data"	    			                         }, 1, 3)
    HmAdd(self:oFields, {"HORA"						, "MHL_HORA"    , "MHL_HORA"    , "hora"				                             }, 1, 3)
    HmAdd(self:oFields, {"LOCALERRO"				, "MHL_CODMEN"  , "MHL_CODMEN"  , "localerro"				                         }, 1, 3)
    HmAdd(self:oFields, {"ERROMSG"					, "MHL_ERROR"   , "MHL_ERROR"   , "erromsg"                 }, 1, 3)
    HmAdd(self:oFields, {"INDICE"					, "MHL_INDICE"  , "MHL_INDICE"  , "indice"				                             }, 1, 3)
    HmAdd(self:oFields, {"CHAVEUNI"					, "MHL_CHAVE"   , "MHL_CHAVE"   , "chaveuni"				}, 1, 3)
    HmAdd(self:oFields, {"SISTEMA"					, "MHL_CASSIN"  , "MHL_CASSIN"  , "sistema"					}, 1, 3)
    HmAdd(self:oFields, {"PROCESSO"					, "MHL_CPROCE"  , "MHL_CPROCE"  , "processo"			    }, 1, 3)
    HmAdd(self:oFields, {"ID"		             	, "MHL_UIDORI"  , "MHL_UIDORI"  , "id"           		  	}, 1, 3)
Return Nil
//-------------------------------------------------------------------
/*/{Protheus.doc} Select
Valida os campos de pesquisa e ordem da query e executa a consulta

@author  totvs
@since   16/07/2022
@version 1.0
/*/
//-------------------------------------------------------------------
Method Select() Class SHPApiMonitorObj

	Local nX 		   	:= 0
    Local cQuery        := ""
	Local cWhere       	:= IIF( !Empty(self:cWhere), self:cWhere, " WHERE 1=1" )
	Local cOrder	   	:= ""
	Local aTemp		   	:= {}
	Local cProperty		:= ""
	Local aAux			:= {}
    Local cDataBase     := Upper( AllTrim( TcGetDb() ) )
    Local cRecords      := cValToChar( (self:nPage * self:nPageSize) + 1)   //Foi somado 1 a mais para ajudar a definir a TAG "hasNext": no retorno do json

    
        //Carrega Filtros
    If self:oJsonFilter <> Nil

        aTemp := self:oJsonFilter:getNames()

        For nX := 1 To Len(aTemp)

            aAux	  := {}
            cProperty := AllTrim( Upper(aTemp[nX]) )

            If HmGet(self:oFields, cProperty, @aAux) .And. Len(aAux) > 0

                cWhere += " AND "

                IiF(ValType(self:oJsonFilter[aTemp[nX]]) == "C",self:oJsonFilter[aTemp[nX]] := "'" + self:oJsonFilter[aTemp[nX]] + "'",;
                self:oJsonFilter[aTemp[nX]] := cValToChar( self:oJsonFilter[aTemp[nX]] ))
                
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
        self:cSelect  := StrTran(self:cSelect , "MHL_ERROR", "ISNULL(CONVERT(VARCHAR(8000), CONVERT(VARBINARY(8000), MHL_ERROR)),'') AS MHL_ERROR")
        self:cGroupBy := StrTran(self:cGroupBy, "*", self:cFields)
            
        //Adiciona controle de paginação direto na query
        IIF(cDataBase <> "ORACLE",;
        IIF(SubStr( Upper(self:cSelect), 1, 6) == "SELECT",self:cSelect := "SELECT TOP " + cRecords + SubStr(self:cSelect, 7),""),;
        cWhere := cWhere + " AND ROWNUM <= " + cRecords)
        
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

Return Nil
//-------------------------------------------------------------------
/*/{Protheus.doc} Delete
Carrega os campos que serão retornados
@version 1.0
/*/
//-------------------------------------------------------------------
Method Delete(cId) Class SHPApiMonitorObj
Local oId     := JsonObject():New()
Local cUUIds  := ""
Local nX      := 0
Local cQuery    := "" //Armazena a query a ser executada
Local cAlias    := GetNextAlias() //Pega o proximo alias
Local lRet      := .T.


oId:FromJson(cId)

For nX:= 1 To Len(oId)
    cUUIds += "'"+oId[nX]['id']+"',"    
Next
cUUIds := SubString(cUUIds,1,Len(cUUIds)-1) 

cQuery := "SELECT MHL.R_E_C_N_O_ MHLREC "
cQuery += " FROM " + RetSqlName("MHL") + " MHL "
cQuery += " WHERE MHL.MHL_UIDORI IN ("+cUUIds+")"
cQuery += " AND MHL.D_E_L_E_T_ != '*'"
DbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAlias, .T., .F.)

While (cAlias)->(!EOF())
    
    MHL->(dbGoto((cAlias)->MHLREC))
    RecLock("MHL",.F.)
        MHL->( DbDelete() ) //Deleta o Registro na MHQ
    MHL->( MsUnLock() )
    (cAlias)->(dbSkip())
EndDo
(cAlias)->( DbCloseArea() )

return lRet
