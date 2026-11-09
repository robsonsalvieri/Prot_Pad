#INCLUDE "MSOBJECT.CH" 
#INCLUDE "AUTODEF.CH"

#DEFINE FINALTEXT Chr(13) + Chr(10)

User Function STFWCFile() ; Return  // "dummy" function - Internal Use

//--------------------------------------------------------
/*/{Protheus.doc} STFWCFile
Classe responsavel em manipular um arquivo.

@param   
@author  Varejo
@version P11.8
@see                                                  
@since   11/04/2012
@return  Self
@todo    
@obs                                     
@sample
/*/
//--------------------------------------------------------

Class STFWCFile
	
	Data cFileName									//Nome do arquivo
	Data cPath										//Caminho do arquivo
	Data nHandle									//Handle do arquivo
	Data cFile										//cPath + cFileName
	Data oData										//Objeto do tipo Dados com as linhas de texto do arquivo
	Data cBar										//barra "/" para Linux "\" para windows
	
	Method STFWCFile(cFile)							//Metodo construtor
	Method File(cPath, cFileName)					//Metodo que ira receber o Path e Nome do Arquivo
	Method Open(nModo) 								//Metodo que ira abrir o arquivo
	Method Close()                                	//Metodo que ira fechar o arquivo
	Method Write(cTexto)							//Metodo que ira escrever no final arquivo
	Method Read()                                  //Metodo que ira ler o arquivo
	Method Create()								//Metodo que ira criar o arquivo
	Method Exist()									//Metodo que ira verificar se o arquivo existe
	Method Erase()									//Metodo que ira apagar um arquivo    
	Method Data()									//Metodo que ira retornar uma colecao com o conteudo do arquivo    
	Method WriteXML(cTexto)    						//Metodo que ira escrever no inicio do arquivo (PROVISORIO)
	Method Rename(cFileName)						//Metodo que ira renomear o arquivo    

EndClass

//--------------------------------------------------------
/*/{Protheus.doc} STFWCFile
Classe responsavel em manipular um arquivo.

@param	  EXPC1 (1 - cFile) - Caminho do arquivo e Nome do Arquivo.    
@author  Varejo
@version P11.8
@see                                                  
@since   11/04/2012
@return  Self
@todo    
@obs                                     
@sample
/*/
//--------------------------------------------------------

Method STFWCFile(cFile) Class STFWCFile

 	Self:cFile		:= cFile            
	
	Self:nHandle  	:= 0
		
	Self:oData		:= STFWCHashTable():STFWCHashTable() 

Return Self

//--------------------------------------------------------
/*/{Protheus.doc} File
Classe responsavel em manipular um arquivo atraves de um caminho especifico.

@param	  EXPC1 (1 - cPath)    - Caminho do arquivo.    
@param	  EXPC2 (2 - cFileName) - Nome do arquivo.
@author  Varejo
@version P11.8
@see                                                  
@since   11/04/2012
@return  Self
@todo    
@obs                                     
@sample
/*/
//--------------------------------------------------------

Method File(cPath, cFileName) Class STFWCFile
	
	Default cFileName 	:= ""
	Default cPath 		:= ""
	
	Self:cFileName 	:= cFileName
	Self:cPath		:= cPath
	Self:nHandle  	:= 0
	
	//Verifica se o path esta vindo com barra no final
	If GetRemoteType() <> REMOTE_LINUX
		
		Self:cBar := "\"
		
		If Substr(Self:cPath, Len(Self:cPath), 1) == Self:cBar
			Self:cFile	:= Self:cPath + Self:cFileName	
		Else
			Self:cFile	:= Self:cPath + Self:cBar + Self:cFileName
		EndIf
	Else

		Self:cBar := "/"
		
		If Substr(Self:cPath, Len(Self:cPath), 1) == Self:cBar
			Self:cFile	:= Self:cPath + Self:cFileName	
		Else
			Self:cFile	:= Self:cPath + Self:cBar + Self:cFileName
		EndIf
	EndIf
	
	Self:oData	:= STFWCHashTable():STFWCHashTable() 
	
Return Self

//--------------------------------------------------------
/*/{Protheus.doc} Open
Responsavel em abrir um arquivo.

@param	  ExpN1 (1 - nModo) - Modo de abertura do arquivo. 0 - Abrir para ler | 1 - abrir para escrever | 2 - abri para ler e escrever(default)	     
@author  Varejo
@version P11.8
@see                                                  
@since   11/04/2012
@return  Logico
@todo    
@obs                                     
@sample
/*/
//--------------------------------------------------------

Method Open(nMode) Class STFWCFile
	
	Local lReturn := .T.					//Variavel de retorno do metodo
	
	Default nMode := 2
	
	//Abre o arquivo
	Self:nHandle := FOPEN(Self:cFile, nMode)
	
	If Self:nHandle == -1
		lReturn := .F.	
	EndIf 
	
Return lReturn

//--------------------------------------------------------
/*/{Protheus.doc} Close
Responsavel em fechar um arquivo.

@param	  	     
@author  Varejo
@version P11.8
@see                                                  
@since   11/04/2012
@return  Logico
@todo    
@obs                                     
@sample
/*/
//--------------------------------------------------------

Method Close() Class STFWCFile
	
	Local lReturn := .F.					//Variavel de retorno do metodo
	
	//Fecha o arquivo
	lReturn := FCLOSE(Self:nHandle)
	
	Self:nHandle := 0

Return lReturn

//--------------------------------------------------------
/*/{Protheus.doc} Write
Responsavel em escrever no final do arquivo.

@param	  ExpC1 (1 - cTexto) - Texto do arquivo.	     
@author  Varejo
@version P11.8
@see                                                  
@since   11/04/2012
@return  Logico
@todo    
@obs                                     
@sample
/*/
//--------------------------------------------------------

Method Write(cText) Class STFWCFile
	
	Local lReturn 	:= .T.						//Variavel de retorno do metodo
	Local nSizeText	:= 0						//Tamanho do texto a ser escrito
	Local nReturn 	:= 0						//Variavel de retorno do metodo FWRITE
	Local nSize		:= 0						//Tamanho de bytes do arquivo
	
	cText += FINALTEXT
	
	//Posiciona no final do arquivo
	nSize := FSEEK(Self:nHandle, 0, 2)
	
	//Escreve no Arquivo
	nReturn := FWRITE(Self:nHandle, cText)
	
	//Verifica se o comando foi executado
	nSizeText := Len(cText)
	
	If nReturn <> nSizeText
		lReturn := .F.
	EndIf
	
Return lReturn

//--------------------------------------------------------
/*/{Protheus.doc} EscrevXML
Responsavel em escrever no final do arquivo.

@param	  ExpC1 (1 - cTexto) - Texto do arquivo.	     
@author  Varejo
@version P11.8
@see                                                  
@since   11/04/2012
@return  Logico
@todo    
@obs                                     
@sample
/*/
//--------------------------------------------------------

Method WriteXML(cText) Class STFWCFile
	
	Local lReturn 	:= .T.						//Variavel de retorno do metodo
	Local nSizeText	:= 0						//Tamanho do texto a ser escrito
	Local nReturn 	:= 0						//Variavel de retorno do metodo FWRITE
	Local nSize		:= 0						//Tamanho de bytes no arquivo
	Local cReturn	:= ""                       //Retorno do conteudo do arquivo
	
	cText += FINALTEXT
			
	//Posiciona no inicio do arquivo para pegar o total de bytes escrito no arquivo
	nSize := FSEEK(Self:nHandle, 0, 2)
	
	//Posiciona no inicio do arquivo
	FSEEK(Self:nHandle, 0, 0)	
	
	//Le o Arquivo
	FREAD(Self:nHandle, cReturn, nSize)
	
	//Posiciona no inicio do arquivo
	FSEEK(Self:nHandle, 0, 0)
	
	//Escreve no arquivo
	nReturn := FWRITE(Self:nHandle, cText + cReturn)
		
	//Verifica se o comando foi executado
	nSizeText := Len(cText + cReturn)
	
	If nReturn <> nSizeText
		lReturn := .F.
	EndIf
	
Return lReturn

//--------------------------------------------------------
/*/{Protheus.doc} Create
Responsavel em criar o arquivo.

@param	  	     
@author  Varejo
@version P11.8
@see                                                  
@since   11/04/2012
@return  Logico
@todo    
@obs                                     
@sample
/*/
//--------------------------------------------------------

Method Create() Class STFWCFile
	
	Local lReturn 	:= .T.						//Variavel de retorno do metodo
		
	//Cria o arquivo
	Self:nHandle := FCREATE(Self:cFile)	
	
	If Self:nHandle == -1
		lReturn := .F.	
	EndIf 
			
Return lReturn

//--------------------------------------------------------
/*/{Protheus.doc} Exist
Responsavel em verificar se o arquivo existe.

@param	  	     
@author  Varejo
@version P11.8
@see                                                  
@since   11/04/2012
@return  Logico
@todo    
@obs                                     
@sample
/*/
//--------------------------------------------------------

Method Exist() Class STFWCFile
	
	Local lReturn 	:= .F.						//Variavel de retorno do metodo
	
	//Verifica se o arquivo existe
	lReturn := File(Self:cFile)
			
Return lReturn

//--------------------------------------------------------
/*/{Protheus.doc} Exist
Responsavel em apagar um arquivo.

@param	  	     
@author  Varejo
@version P11.8
@see                                                  
@since   11/04/2012
@return  Logico
@todo    
@obs                                     
@sample
/*/
//--------------------------------------------------------

Method Erase() Class STFWCFile
	
	Local lReturn 	:= .T.						//Variavel de retorno do metodo
	Local nReturn	:= 0						//Retorno da funcao FERASE
	
	//Apaga o arquivo
	nReturn := FERASE(Self:cFile)
	
	If nReturn == -1
		lReturn := .F.	
	EndIf 
			
Return lReturn

//--------------------------------------------------------
/*/{Protheus.doc} Read
Responsavel em ler o conteudo do arquivo.

@param	  	     
@author  Varejo
@version P11.8
@see                                                  
@since   11/04/2012
@return  Logico
@todo    
@obs                                     
@sample
/*/
//--------------------------------------------------------

Method Read() Class STFWCFile
	
	Local cLine			:= ""				//Retorno da leitura do arquivo
	Local nCount		:= 0 				//Variavel de controle do tipo contador
	Local oDateLine		:= Nil				//Objeto do tipo DadoLinha
	
	//Estancia o objeto Dados (esta inicializando)
	Self:oData := STFWCHashTable():STFWCHashTable()  		
	
	//Coloca o arquivo em uso
	FT_FUSE(Self:cFile)
	//Posiciona na primeira linha
	FT_FGOTOP()
 
	//Varre o arquivo
	While !FT_FEOF()
	   
	   nCount++
	   
	   //Estancia o objeto DadoLinha
	   oDateLine 		:= STFWCDateLine():STFWCDateLine()  
	   //Pega a linha
	   cLine 			:= FT_FREADLN()
	   //Atribui a linha de texto ao objeto
	   oDateLine:cLine 	:= cLine
	   //Adiciona o objeto DadoLinha na colecao
	   Self:oData:Add("L" + AllTrim(Str(nCount)), oDateLine)   
	   //Pula a linha
	   FT_FSKIP()
	End 
    
 	//Libera o arquivo
	FT_FUSE()
			
Return Self:oData

//--------------------------------------------------------
/*/{Protheus.doc} Data
Responsavel em retorna uma colecao com os dados do arquivo.

@param	  	     
@author  Varejo
@version P11.8
@see                                                  
@since   11/04/2012
@return  Objeto Colecao
@todo    
@obs                                     
@sample
/*/
//--------------------------------------------------------

Method Data() Class STFWCFile
Return Self:oData

//--------------------------------------------------------
/*/{Protheus.doc} Rename
Responsavel em renomear um arquivo.

@param	  EXPC1 (1 - cFileName) - Nome para qual será renomeado	  	     
@author  Varejo
@version P11.8
@see                                                  
@since   11/04/2012
@return  Numerico
@todo    
@obs                                     
@sample
/*/
//--------------------------------------------------------

Method Rename(cFileName) Class STFWCFile

	Local nReturn := 0 				//Retorno do metodo
	
	//Renomeia o arquivo
	nReturn := FRENAME(Self:cFile , cFileName) 

Return nReturn