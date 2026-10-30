#include "Totvs.ch"
#include "TopConn.ch"
#include "TbiConn.ch"
#include "Restful.ch"
#include "fileio.ch"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ParamResult ³ Autor ³ Rafael P Goncalves ³ Data ³20.05.2021³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³ Metodo retorna o conteudo de um parametro                  ³±±
±±³Descricao ³ 															  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
WSRESTFUL ParamResult DESCRIPTION "Filial de Faturamento do Fornecedor"

	WSMETHOD POST DESCRIPTION "<h2>Metodo retorna o CNPJ que o fornecedor irá faturar.</h2>" WSSYNTAX "/ParamResult"

END WSRESTFUL



WSMETHOD POST WSSERVICE ParamResult
	
	Local cDtIni		:= DtoC(Date())
	Local cHrIni		:= Time()
	Local cEnvLog  		:= ""
	Local bError    	:= {||}
	Local cBody			:= DecodeUtf8(::GetContent())
	Local oJson			:= Nil
	Local cConteudo		:= ""
    Local xAux          := Nil
	Local cRet			:= ""
	Local aEmp			:= {}
	Local aParam        := {}
	Local i             := 0
	Local cComando		:= ""

	//conout("INICIO-Consumido o WebService ParamResult - Data e Hora Inicial "+cDtIni+" - "+cHrIni)
	
	::SetContentType("application/json; charset=iso-8859-1")
	
	// Salva bloco de código do tratamento de erro	
	bError := ErrorBlock( { |oError| xTrataError( oError,@cEnvLog ) } )
			
	Begin Sequence	
		If FWJsonDeserialize(cBody,@oJson)
			aParam := oJson["Param"]
			aEmp := xVerEmp1(Replace(Replace(Replace(oJson:cnpj_empresa,".",""),"/",""),"-",""))//aEmp := FwLoadSm0()
				If (aEmp[3] == "Empresa já existente.")//If RpcSetEnv(aEmp[1,1],aEmp[1,2],,,"FIN",GetEnvServer(),{""})
					cRet := xAbreEnv1(aEmp[1],aEmp[2])
					If Empty(cRet)
						For i := 1 To Len(aParam)
							cComando := 'SuperGetMv(Alltrim(aParam[i]["Param"]),.F.,Alltrim(aParam[i]["DefaultValue"]))'
							xAux := &(cComando) //SuperGetMv(Alltrim(aParam[i]["Param"]),.F.,Alltrim(aParam[i]["DefaultValue"]))
							If ValType(xAux) == "N"
								cConteudo := cValToChar(xAux)
							ElseIf ValType(xAux) == "D"
								cConteudo := DtoC(xAux)
							ElseIf ValType(xAux) == "L"
								If xAux
									cConteudo := "true"
								Else
									cConteudo := "false"
								EndIf
							Else
								cConteudo := xAux
							EndIf
							ErrorBlock(bError)

							cRet := Alltrim(aParam[i]["Param"]) 					
							::SetResponse('{"Retorno":"'+cRet+'", "Conteudo": "'+cConteudo+'"}' )
						next
					EndIf 
				EndIf
		EndIf
	End Sequence

	//conout("TERMINO-Consumido o WebService ParamResult - Data e Hora Termino "+DtoC(Date())+" - "+Time()+" / Data e Hora Inicial "+cDtIni+" - "+cHrIni)
Return .T.

/*
{
   "cnpj_empresa":{{cCNPJ}},
   "Param":[
      {
         "Param":"MV_EASYOP",
         "DefaultValue":"NAO LOCALIZADO"
      },
      {
         "Param":"MV_ULMES",
         "DefaultValue":"NAO LOCALIZADO"
      },
      {
         "Param":"MV_DUPNAT",
         "DefaultValue":"NAO LOCALIZADO"
      }            
   ]
}
*/
