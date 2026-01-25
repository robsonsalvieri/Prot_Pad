#include "Totvs.ch"
#include "TopConn.ch"
#include "TbiConn.ch"
#include "Restful.ch"
#include "fileio.ch"
#include "protheus.ch"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ QueryResult     ³ Autor ³ Dennis Calabrez ³ Data ³29.09.2024³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³ Manutencao por Dennis Calabrez                             ³±±
±±³Descricao ³ WebService: QueryResult									  ³±±
±±³          ³ Recebe uma query (SELECT), executa no banco de dados   	  ³±±
±±³          ³ e retorna o resultado em JSON.							  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
WSRESTFUL APPQueryResult DESCRIPTION "Serviço REST de Resultado de Query - V2.0"

	WSMETHOD POST DESCRIPTION "<h2>Metodo recebe a query e retorna o seu resultado.</h2><br><strong>Obrigatório {query}</strong><br><br>Enviar no corpo em formato JSON.</strong> " WSSYNTAX "/APPQueryresult"

END WSRESTFUL

WSMETHOD POST WSSERVICE APPQueryResult
Local cRet			:= ""
Local aUrl			:= ::aURLParms    	
Local oJson			:= Nil
Local cDtIni		:= DtoC(Date())
Local cHrIni		:= Time()
Local cEnvLog  		:= ""
Local bError    	:= {||}
Local aEmp			:= {}
Local aQuery 		:= {}
Local cQuery 		:= ""
Local cBody			:= DecodeUtf8(::GetContent())
Local oJson			:= Nil
Local cJson			:= ""

	
	::SetContentType("application/json; charset=iso-8859-1")
	
	// Salva bloco de código do tratamento de erro	
	bError := ErrorBlock( { |oError| xTrataError( oError,@cEnvLog ) } )
			
	Begin Sequence	
		If FWJsonDeserialize(cBody,@oJson)

			If Empty(oJson:cnpj_empresa) .OR. Len(oJson:cnpj_empresa) < 14
				cRet := "ERRO-CNPJ Inválido."
			Else
				aEmp := xVerEmp(Replace(Replace(Replace(oJson:cnpj_empresa,".",""),"/",""),"-",""))
				If (aEmp[3] == "Empresa já existente.")
					cRet := xAbreEnv(aEmp[1],aEmp[2])
					If Empty(cRet)
						If oJson:cod_query == "01" .OR. oJson:cod_query == "02" .OR. oJson:cod_query == "03";
						.OR. oJson:cod_query == "04".OR. oJson:cod_query == "05"
							cQuery := LOCA098(oJson:cod_query,oJson:cod_cli,oJson:loj_cli)
						EndIf					
						If oJson:cod_query == "06"
							cQuery := LOCA098(oJson:cod_query)
						EndIf	
						If oJson:cod_query == "07" 
							cQuery := LOCA098A(oJson:cod_query,oJson:cod_bem,oJson:placa)
						EndIf	
						If oJson:cod_query == "08"
							cQuery := LOCA098B(oJson:cod_query,oJson:cod_for,oJson:loj_for,oJson:dtini,oJson:dtfim)
						EndIf	
						If oJson:cod_query == "09"
							cQuery := LOCA098C(oJson:cod_query,oJson:cod_for,oJson:loj_for)
						EndIf	
						If oJson:cod_query == "10"
							cQuery := LOCA098D(oJson:cod_query,oJson:cod_bem)
						EndIf																								
						aQuery := QryArr(cQuery)

						cJson  := ArrJson(aQuery[1],aQuery[2]) // Cabecalho, Linha																													
					EndIf
				 EndIf
			EndIf
		EndIf
	End Sequence


	If Empty(cRet)
		cRet := "OK"
	EndIf                              
    
	::SetResponse(Alltrim(FWhttpEncode('{"Retorno":"'+cRet+'", "Dados": '+Replace(cJson,CRLF,"")+'}' )))
	//SetRestFault(400,cRet)
				
	//RpcClearEnv()
Return .T.


/* 
Dennis Calabrez
Função responsavel por verificar se existe uma empresa:
se sim, retorna empresa e filial;
se não, retorna a proxima sequencia a ser criada
Retornos:
1ªPosição: Empresa
2ªPosição: Filial
3ªPosição: com alguma mensagem
*/
Function xVerEmp(cCNPJ)
Local aRet 	   		:= {"","",""}
Local cNextEmp		:= ""
Local cNextFil		:= ""
	
	//cCNPJ 		:= Replace(Replace(Replace(cCNPJ,".",""),"/",""),"-","")
	//cRaizCNPJ	:= Replace(Replace(Replace(cRaizCNPJ,".",""),"/",""),"-","")
	
	//ConOut("Verificando Empresa")

	aEmpSM0	:= FWLoadSM0()
	nPosEmp := aScan(aEmpSM0,{|x| Alltrim(x[18]) == Alltrim( cCNPJ ) })
	if nPosEmp > 0 
		aRet[1] := aEmpSM0[nPosEmp][1]
		aRet[2] := aEmpSM0[nPosEmp][2]
	endif
	DbCloseAll()
	RpcClearEnv()

	//Se não existe
	If Empty(aRet[1])
		aRet[1] := cNextEmp
		aRet[2] := cNextFil
		aRet[3] := "Não existe empresa."
	Else
		aRet[3] := "Empresa já existente."
	EndIf
	
Return (aRet)
//Dennis Calabrez
//Funcao responsavel para abrir e preparar os ambientes
Function xAbreEnv(cEmp,cFil)
Local cEnvLog	:= ""
Local cRet		:= ""
Local lRetEmp	:= .F.
Local bError    := {||}

	//ConOut("Abrindo Ambiente")
	
	// Salva bloco de código do tratamento de erro
	bError := ErrorBlock( { |oError| xTrataError( oError,@cEnvLog ) } )
	
	Begin Sequence
		//cEmp := Alltrim(cEmp)
		//cFil := Alltrim(cFil)

		RpcClearEnv() 
		RpcSetType(3) 
			//OpenSM0()
		lRetEmp := RpcSetEnv(cEmp,cFil,,,"FAT",GetEnvServer(),{""})
		//If !lRetEmp
		//	cRet := "ERRO-Não foi possivel abrir empresa "+cEmp+" filial "+cFil+" "+DtoC(dDataBase)+" "+Time()+" na função RpcSetEnv"
		//else
		//	if cEmp <> cEmpAnt .Or. cFil <> cFilAnt
		//		cRet := "ERRO-Não foi possivel abrir empresa "+cEmp+" filial "+cFil+" "+DtoC(dDataBase)+" "+Time()+" na função RpcSetEnv"
		//	endif
		//EndIf

	End Sequence
	ErrorBlock(bError)
	//If !Empty(cEnvLog)
	//	cRet := "ERRO-Não foi possivel abrir empresa "+cEmp+" filial "+cFil+" "+DtoC(dDataBase)+" "+Time()+CRLF+cEnvLog
	//	conout(cRet)
	//EndIf
	
Return (cRet)

//Dennis Calabrez
//Funcao responsavel por tratar o Erro ocorrido em um bloco de codigo em tempo de execucao
Function xTrataError( oError,cEnvLog )
//Local cErro		:= oError:Description
//Local cStack 	:= oError:ERRORSTACK
//	cEnvLog := cErro + chr(10) + chr(13) + cStack
//	conout(cEnvLog)
	//Se deixar o BREAK, quando houver error log, o ws retornará errorcode 500 e internalservererror e não obteremos a mensagem do erro, por isso deixar comentado
	//BREAK
	
Return( Nil )

Function ArrJson(_aCab,_aLin)
Local _cJson  := ""
Local _nX                  
Local _nY

Default _aCab := {}
Default _aLin := {} 

_cJson += '[' //'{'

For _nX := 1 to Len( _aLin )
 
    _cJson += '{' //'"' + cValtoChar(_nX) + '": {'
 
    For _nY:= 1 to Len( _aCab ) 
     
        Do Case
        Case ValType(_aLin[_nX,_nY]) == "C"  
           //_cConteudo := '"' + (Alltrim(Replace(Replace(Replace(Replace(Replace(_aLin[_nX,_nY],'"',''),"'",""),"	",""),chr(65533)+" ",""),chr(65533),"") )) + '" '     //Retira ASPAS DUPLAS, SIMPLES E CARACTERE ESPECIAL
		   _cConteudo := '"' + Alltrim(Replace(Replace(Replace(_aLin[_nX,_nY],'"',''),"'",""),chr(65533),"") ) + '" '     //Retira ASPAS DUPLAS, SIMPLES E CARACTERE ESPECIAL
        Case ValType(_aLin[_nX,_nY]) == "N"
            _cConteudo := Alltrim(cValtoChar(_aLin[_nX,_nY]))
        Case ValType(_aLin[_nX,_nY]) == "D"
            _cConteudo := '"' + dtos(_aLin[_nX,_nY]) + '"'
        Case ValType(_aLin[_nX,_nY]) == "L"
            _cConteudo := iif(_aLin[_nX,_nY], '"true"','"false"') 
        //OtherWise
            //_cConteudo := '"' + _aLin[_nX,_nY] + '"'
        EndCase               
 
        _cJson += '"' + _aCab[_nY] + '":' + _cConteudo
 
        If _nY < Len(_aCab)
           _cJson += ','
        EndIf
 
    Next
    
    _cJson += '}'
    
    If _nX < Len(_aLin)
       _cJson += ','
    EndIf

Next _nX

_cJson += ']' //'}'

Return _cJson

Function QryArr(cQuery)
Local _aLin   := {} 
Local _aLin1  := {}
Local _aCab   := {}
Local _aRet   := {} 
Local nRegAtu := 0 
Local x       := 0
Local _cAlias := GetNextAlias()// "TRBWS"

//cQuery := ChangeQuery(cQuery)

	//If Select(_cAlias) > 0
	//	(_cAlias)->(dbCloseArea())
	//EndIf

	TcQuery cQuery New Alias &(_cAlias)
	
	_aLin1   := Array(Fcount()) 
	nRegAtu := 1 

	While (_cAlias)->(!Eof()) 
		
		For x:=1 To (_cAlias)->(Fcount())
			_aLin1[x] := (_cAlias)->(FieldGet(x)) 
		Next
		
		aAdd(_aLin,aClone(_aLin1))
		
		If nRegAtu == 1
			For x:=1 To (_cAlias)->(Fcount()) 
				aAdd(_aCab,(_cAlias)->(Field(x)))
			Next
		EndIf
		
		(_cAlias)->(dbSkip()) 
		nRegAtu += 1 
	EndDo
	If Select(_cAlias) > 0
		(_cAlias)->(DbCloseArea())
	EndIf
		

	_aRet := {_aCab,_aLin}

Return(_aRet)

/*
{
   "cnpj_empresa":"17162280000137",
   "query":"SELECT T9_FILIAL, T9_CODBEM, T9_NOME, T9_PLACA, T9_CODFAMI, T6_NOME FROM xEmp('ST9') ST9 JOIN xEmp('ST6') ST6 ON  T6_CODFAMI = T9_CODFAMI AND ST6.D_E_L_E_T_ <> '*' WHERE ST9.D_E_L_E_T_ <> '*' AND LTRIM(RTRIM(REPLACE(T9_PLACA,'-',''))) = 'SHT8G24' ORDER BY T9_CODBEM, T9_NOME"
}
*/

/*
json cod_query 07
{  
  "cnpj_empresa":"53485215000106",
  "cod_bem":"0000000002",
  "placa":"EEEEEEEE"
   
} 
*/
/*
json cod_query de 01 a 06
{
   "cnpj_empresa":"53485215000106",
   "cod_query":"02",
   "cod_cli":"000094",
   "loj_cli":"01"
 }
 */
