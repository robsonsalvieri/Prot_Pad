#Include "locw034.ch"
#Include "TOTVS.CH"
#Include "RESTFUL.CH"
#Include "Protheus.ch" 
#Include "tbiconn.ch"
#Include "Topconn.CH"  
#Include "fileio.ch"

/*/{Protheus.doc} LOCW034
@description	API Lista Cadastro de Aprovadores RENTAL
@author			Dennis Calabrez
@since     		15/10/2025 
/*/   
WSRESTFUL LOCW034 DESCRIPTION STR0001  //"Lista Cadastro de Aprovadores RENTAL"

   WSMETHOD GET DESCRIPTION STR0002 WSSYNTAX "/LOCW034/{param1}/{param2}"

END WSRESTFUL

/*/{Protheus.doc} METODO GET
@description	API Lista Cadastro de Aprovadores RENTAL
@author			Dennis Calabrez
@since     		15/10/2025
/*/   
WSMETHOD GET WSSERVICE LOCW034
Local cResponse := ""
Local cusuario  := ""
Local cParam1   := ""
Local cParam2   := ""
Local aPar      := {}

	aPar := GetUrlParams2(AllTrim(Upper(::GetPath(1)))) //Busco os parâmetros informados na URL/API

	cParam1 := aPar[1]
   cParam2 := aPar[2]

	cusuario := AllTrim(SubStr(cParam1, At("=", cParam1) + 1))//Pego o Código do Usuário se informado
   cAut     := AllTrim(SubStr(cParam2, At("=", cParam2) + 1))//Pego o CNPJ da Empresa para Logar no Protheus na empresa correta

   cResponse :=  LOCW0341(cusuario,cAut)

   ::SetContentType("application/json; charset=iso-8859-1")
   ::SetResponse(Alltrim(FWhttpEncode(cResponse)) )

Return .T.

/*/{Protheus.doc} LOCW0341
@description	Query de consulta de Aprovadores
@author			Dennis Calabrez
@since     		15/10/2025
/*/   
Static Function LOCW0341(cusuario,cAut)
Local cAliasApr  := GetNextAlias()
Local cQuery     := ""
Local cRetorno   := ""
Local cAprovs    := ""
Local cErro      := ""
Local cRet       := ""
Local aBindParam := {}

   aEmp := xVerEmp1(Replace(Replace(Replace(cAut,".",""),"/",""),"-",""))
   If (aEmp[3] == "Empresa já existente.")
      cRet := xAbreEnv1(aEmp[1],aEmp[2])
      If Empty(cRet)
         cQuery += " SELECT " 
         cQuery += "     FPR_CODUSR AS CODUSER, "
         cQuery += "     FPR_NIVEL AS NIVEL, " 
         cQuery += "     FPR_TIPAPR AS TIPO_APROVACAO, " 
         cQuery += "     FPR_PRCDES AS PERCENTUAL_DESCONTO, "
         cQuery += "     FPR_PRCMRG AS PERCENTUAL_MARGEM " 
         cQuery += " FROM " + RetSqlName("FPR") + " FPR   " 
         cQuery += " WHERE  " 
         cQuery += "     FPR.D_E_L_E_T_ = ' ' AND " 
         cQuery += "     FPR_FILIAL = '"+xFilial("FPR")+" ' 
         //caso tenha informado parametro
         If !Empty(cusuario)
            cQuery += " AND  FPR_CODUSR = ? " + CRLF
            aadd(aBindParam,AllTrim(cusuario))
         EndIf
         cQuery += " ORDER BY FPR_FILIAL, FPR_CODUSR " + CRLF

         cQuery := ChangeQuery(cQuery)
         MPSysOpenQuery(cQuery,cAliasApr,,,aBindParam)

         If !(cAliasApr)->(Eof())
            
            cRetorno += ' { ' + CRLF
            cRetorno += STR0003 + CRLF //'        "DESCRICAO" : "OK ",'
            cRetorno += STR0004 + CRLF //'	"LISTA_APROVADORES": ['

            While !(cAliasApr)->(Eof())
               //fecha linha caso tenha mais de uma
               If !Empty(cAprovs)
                  cRetorno += '		},' + CRLF
                  cAprovs := ""
               EndIf

               //abre linha
               cAprovs += '		{' + CRLF
               cAprovs += STR0005 + AllTrim((cAliasApr)->CODUSER) + '",'   + CRLF //'			"CODUSER": "'
               cAprovs += STR0006 + AllTrim((cAliasApr)->NIVEL) + '",'   + CRLF //'			"NIVEL": "'
               cAprovs += STR0007 + AllTrim((cAliasApr)->TIPO_APROVACAO)+ '",'   + CRLF //'			"TIPO_APROVACAO": "'
               cAprovs += STR0008 + cValToChar((cAliasApr)->PERCENTUAL_DESCONTO) + '",'    + CRLF //'			"PERCENTUAL_DESCONTO": "'
               cAprovs += STR0009 + cValToChar((cAliasApr)->PERCENTUAL_MARGEM) + '"'     + CRLF //'			"PERCENTUAL_MARGEM": "'
                  
               cRetorno += cAprovs
               
               (cAliasApr)->(dbSkip())
            EndDo

            //Fecha o ultimo
            cRetorno += '		}' + CRLF      

            cRetorno += '	]' + CRLF
            cRetorno += '}' + CRLF
         Else
            cErro := STR0010 //"APROVADOR NAO LOCALIZADO"

            cRetorno += ' { ' + CRLF
            cRetorno += STR0011 + CRLF //'    "RETORNO"   : { '
            cRetorno += STR0012 + cErro + '" ' + CRLF //'        "DESCRICAO" : "'
            cRetorno += '    } ' + CRLF
            cRetorno += ' } ' + CRLF
         EndIf
      EndIf
   EndIf      
Return cRetorno

/*/{PROTHEUS.DOC}
ITUP BUSINESS - TOTVS RENTAL
Alimenta os parâmetros da URL em um Array
@TYPE STATIC FUNCTION
@AUTHOR Dennis Calabrez
@SINCE 20/10/2025
/*/
Static Function GetUrlParams2(cUrl)
Local cQry    := ""
Local aParams := {}

    // Captura apenas a parte dos parâmetros após o '?'
   If At("?", cUrl) > 0
      cQry := AllTrim(SubStr(cUrl, At("?", cUrl) + 1))
   Else
      cQry := ""
   EndIf

    // Verifica se existem parâmetros
   If !Empty(cQry)
      // Quebra os parâmetros pelo '&'
      aParams := StrTokArr(cQry, "&")
   EndIf

Return (aParams)
