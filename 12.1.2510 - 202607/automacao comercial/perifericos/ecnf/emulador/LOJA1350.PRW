#INCLUDE "MSOBJECT.CH"
#INCLUDE "DEFECF.CH"
#INCLUDE "AUTODEF.CH"
#include 'fileio.ch'
#INCLUDE "PROTHEUS.CH"


Function LOJA1350 ; Return 	 // "dummy" function - Internal Use
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบClasse    ณLJANfEmulador    บAutor  ณVendas Clientes     บ Data ณ  27/07/17   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณClasse abstrata, possui as funcoes comuns para todos os ECF'S do   บฑฑ
ฑฑบ			 ณmodelo LJANfEmulador											     บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        		 บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Class LJANfEmulador From LJAEcnf
	
	Data oFormasVen																//Formas da venda, objeto do tipo LJCFormasEcf
	Data cFile 
	Data aTagBar							//Tag de C๓digo de Barras
	Data aTagFor							//Tag de Formata็ใo
	Data cDirectory							//Diretorio do arquivo
	Data cFileIni							//Arquivo de configuracao
	Data cTxtIni							//Texto Inicial
	Data cTxtFin							//Texto Final
	Data cImgDef							//Imagem Padrใo da Impressora
	Data cCodeBarSize						//Tamanho do codigo de barra
	Data cQrCodeSize						//Tamanho do QRCode				
	
	Method New(oTotvsApi)					//Metodo construtor
	Method AbrirPorta(cPorta)				//Abre a porta serial para comunicacao com o ECF
	Method FechaPorta()						//Fechar a porta serial	
	Method ImpTextoNf(cTexto)				//Metodo para Impressใo de Texto comum
	Method TrataTexto(cTexto)				//Metodo para Tratar o texto e enviar para as fun็๕es caso haja formata็ใo
	Method TrataTags(cTexto)				//Metodo para tratamento das tags enviadas
	Method ImpCodeBar(cTipo,cTexto)			//Metodo para Impressใo de C๓digo de Barras
	Method ImpBitMap(cArquivo)				//Metodo para impressao de imagem com extensao .bmp
	Method SetModelImp(cModelo)				//Metodo para setar modelo de Impressora
	Method CarregMsg()
	Method VerPapel()						//Metodo para verificar se tem Papel na impressora
	Method ImpTxtFmt(cTexto)				//Metodo para separar o texto de forma que seja usado no negritado, italico, etc. junto com qrcode e/ou bitmap
	Method Imprimir(cTexto)					//Metodo para envio de texto 
	Method AbrirGavet()
	Method CortaPapel()
	Method CarregaTag()
	Method CarregTag()
	Method WriteTamFile(nPosFile) 
	Method RetTamFile() 
	Method GeraBitMap()
	Method GeraCodeBar()			//Metodo para Impressใo de C๓digo de Barras
	Method RetImpdef()
	Method RetCodeBar()
	Method CriaArq()
	

EndClass

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบMetodo    ณNew   	       บAutor  ณVendas Clientes     บ Data ณ  27/07/17   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo construtor da classe LJANfEmulador.   			    	     บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        		 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ																	 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto														     บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Method New(oTotvsApi) Class LJANfEmulador
	Local cFontName := ""  //Nome da Fonte do Emulador
	Local cFonSize 	:= "" //Tamanho da Fonte do Emulador
	Local cPageSize := "" //Tamanho da pแgina do Emulador
	

	If Type("cEstacao") == "U"
		cEstacao := "001"
	EndIf
	//Executa o metodo construtor da classe pai
	_Super:New(oTotvsApi)
    
    //Carrega as mensagens
    ::CarregMsg()
    
    //Carrega as Tags
    

	//cEstacao // variavel publica do sigaloja/sigafrt
	If !IsBlind()
		::cDirectory := GetClientDir()
	Else
		::cDirectory :=  "log\ecf"+cEmpAnt+StrTran(cFilAnt, " ", "")+"\"
	EndIf
	
	::cFileIni :=  ::cDirectory+ "enfhtml.ini"
	
	If ::RetImpdef("GERAL", "DIARY_FILE", "0") == "1"
		::cFile := "enf"+cEstacao+"_"+Dtos(	Date() ) + ".html"
	Else
		::cFile := "enf"+cEstacao + ".html"
	EndIf

	::cFile 		:= ::cDirectory  + ::cFile
  	cFontName 		:=  ::RetImpdef("GERAL", "FONT_NAME", "courier new") 
	cFonSize 		:= ::RetImpdef("GERAL", "FONT_SIZE", "12") 
	cPageSize 		:= ::RetImpdef("GERAL", "PAGE_SIZE", "300")  
	::cCodeBarSize	:= 	::RetImpdef("GERAL", "CODEBAR_SIZE", "100")				//Tamanho do codigo de barra
	::cQrCodeSize 	:= ::RetImpdef("GERAL", "QRCODE_SIZE", "300")						//Tamanho do QRCode				
	

	::cImgDef := ::RetImpdef("GERAL", "IMAGE_DEF", "logonfce.jpg") 
	
	::cTxtIni	:=  "<html><style> body {  width:"+ cPageSize + "px; font-family: " + cFontName + "; font-size: " +cFonSize + "px }</style><head><script>"+CRLF+;
										"window.location.href='#botton';" + CRLF+"</script>"+ CRLF + ;
										"<title>Emulador Grแfico " + "- Esta็ใo " + cEstacao + "</title><body>"+CRLF						//Texto Inicial
	::cTxtFin	:= CRLF+'<p id="botton"></p></body></html>'						//Texto Final
	
	::CarregTag()
Return Self

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณSetModelImpบAutor  ณVendas Clientes     บ Data ณ  27/07/17  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel pela abertura da porta serial.           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณcModelo - Modelo de Impressora Utilizado					  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Method SetModelImp(cModelo) Class LJANfEmulador
	
	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno 	:= "1"       	//String contendo o retorno da funcao que envia o comando para a serial
   
 	//Trata o retorno
	oRetorno := ::TratarRet(cRetorno)
    
Return oRetorno

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณAbrirPortaบAutor  ณVendas Clientes     บ Data ณ  27/07/17   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel pela abertura da porta serial.           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณNumero da porta COM (nao utilizado)						  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										  บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Method AbrirPorta(cPorta) Class LJANfEmulador
	
Local cRetorno 	:= "1"       	//String contendo o retorno da funcao que envia o comando para a serial
Local oRetorno 	:= Nil      	//Objeto que sera retornado pela funcao
Local lFuncOk	:= FindFunction("StrTokArr2")

If lFuncOk
	If !ExistDir(::cDirectory)
		MakeDir(::cDirectory)
	EndIf
	
	If !::CriaArq()
		cRetorno := "-1"
	EndIf
Else
	cRetorno := "-4" 
EndIf
oRetorno := ::TratarRet(cRetorno)
    
Return oRetorno

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณFecharPortaบAutor  ณVendas Clientes     บ Data ณ  27/07/17  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel pelo fechamento da porta serial.         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณNumero da porta COM 										  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										  บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Method FechaPorta(cPorta) Class LJANfEmulador
	
	Local cRetorno 	:= "1"       	//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil      	//Objeto que sera retornado pela funcao
	
	oRetorno := ::TratarRet(cRetorno)
    
Return oRetorno

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบMetodo    ณImpTextoNf       บAutor  ณVendas Clientes     บ Data ณ  27/07/17   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณResponsavel pela impressใo do texto						    	 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja 			                                        		 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณcTexto - Texto que serแ enviado para impressใo		   	         บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto														     บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Method ImpTextoNf(cTexto) Class LJANfEmulador
Local oRetorno 	:= Nil      	//Objeto que sera retornado pela funcao	

Default cTexto	:= ""

::GravarLog("Comando Enviado: ImpTextoNf:(" + cTexto +")" )
	
If !Empty(AllTrim(cTexto))
	oRetorno	:= Nil
	oRetorno	:= ::TrataTexto(cTexto)
Else
	
	oRetorno := ::Imprimir(cTexto)
EndIf
		
Return oRetorno

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบMetodo    ณTrataTexto       บAutor  ณVendas Clientes     บ Data ณ  12/07/13   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณTrata as tags enviadas por cTexto e enviar para as respectivas   	 บฑฑ
ฑฑบ			 ณfun็๕es da Bematech												 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja 			                                        		 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณcTexto - Texto que serแ enviado para impressใo		   	         บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto														     บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Method TrataTexto(cTexto) Class LJANfEmulador
Local oRetorno 	:= Nil      	//Objeto que sera retornado pela funcao	
Local cTextoAux	:= ""			//Auxiliar para cTexto

Default cTexto := ""

cTextoAux	:= ::TrataTags(cTexto)

oRetorno	:= ::VerPapel()    
If oRetorno:cAcao == OK
	
	oRetorno := NIL
	oRetorno := ::Imprimir(cTextoAux)
EndIf

Return oRetorno

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบMetodo    ณImpCodeBar       บAutor  ณVendas Clientes     บ Data ณ  27/07/17   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFaz a impressใo dos c๓digos de barra e qrcode				    	 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja 			                                        		 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณcTipo - Tipo do C๓digo de Barras, baseado nas tags do AUTODEF.CH	 บฑฑ
ฑฑบ			 |cTexto - Texto que serแ convertido em Cod de Barras				 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto														     บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Method ImpCodeBar(cTipo,cTexto) Class LJANfEmulador 
	
	Local oRetorno 	:= Nil      	//Objeto que sera retornado pela funcao	
	Local cRetorno 	:= ""       	//String contendo o retorno da funcao que envia o comando para a serial
    Local cRet		:= ""

	Default cTexto	:= ""
	Default cTipo	:= ""
	
	::GravarLog("Comando Enviado: ImpCodeBar:(" + cTipo + "," + cTexto +")" )

	cRet := ::RetCodeBar(cTipo,@cTexto) 	//Retorno = {lRet,cTipo,lConfigDef,cComando,cTxtAux}
	
	If !Empty(cRet)
    	oRetorno := ::Imprimir( cRet )
    Else
    	oRetorno := ::TratarRet("1")
    EndIf

Return oRetorno

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบMetodo    ณImpBitMap        บAutor  ณVendas Clientes     บ Data ณ  17/07/13   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณResponsavel pela impressใo da imagem .BMP					    	 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja 			                                        		 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณcArquivo - caminho e nome do arquivo .BMP que serแ impresso 		 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto														     บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Method ImpBitMap(cArquivo) Class LJANfEmulador

	Local cRetorno 	:= "1"       	//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil      	//Objeto que sera retornado pela funcao
	Local cTexto	:= 0

	Default cArquivo	:= ""
    
    ::GravarLog("Comando Enviado: ImpBitMap:(" + cArquivo +")" )
    oRetorno	:= ::VerPapel()
    
    If oRetorno:cAcao == OK
    	oRetorno := NIL
    	cTexto := ::GeraBitMap(cArquivo)
    	oRetorno := ::Imprimir( cTexto )
	EndIf
	

Return oRetorno

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณCarregMsg บAutor  ณVendas Clientes     บ Data ณ  27/07/17   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel pelo carregamento das mensagens de    	  บฑฑ
ฑฑบ          ณresposta possiveis da impressora.			  		  	  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณnenhum													  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณnenhum													  บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Method CarregMsg() Class LJANfEmulador
	::AdicMsgECF("0", "Problemas ao abrir porta de comunicacao", ERRO)
	::AdicMsgECF("1", "Resultado sem erro", OK)
	::AdicMsgECF("2", "Impressora sem papel", ERRO)
	::AdicMsgECF("3","Erro desconhecido",ERRO)
	::AdicMsgECF("-1", "Erro de execucao na funcao", ERRO)
	::AdicMsgECF("-2", "Parametro Invalido", ERRO)
	::AdicMsgECF("-3", "Erro na leitura do arquivo ou arquivo invalido", ERRO)
	::AdicMsgECF("-4", "Fun็ใo StrTokArr2 nใo compilada no RPO. Por favor, atualize a build 7.00.131227A com data de gera็ใo superior a 08/09/2014.", ERRO)

Return Nil



/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบMetodo    ณVerPapel         บAutor  ณVendas Clientes     บ Data ณ  27/07/2017 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณverifica papel na impressora    				                     บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        		 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณoRetorno												             บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Method VerPapel() Class LJANfEmulador
Local oRetorno 	:= Nil      	//Objeto que sera retornado pela funcao
Local cRetorno 	:= "1"       	//String contendo o retorno da funcao que envia o comando para a serial

//Verifica se tem papel pra prosseguir com o comando
oRetorno:= ::TratarRet(cRetorno)

Return oRetorno

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบMetodo    ณImprimir         บAutor  ณVendas Clientes     บ Data ณ  27/07/2017 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณManda o texto simples para impressใo    				             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        		 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณoRetorno												             บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Method Imprimir( cTexto ) Class LJANfEmulador
Local cRetorno 	:= "1"			//Objeto para passagem dos parametros
Local oRetorno 	:= Nil      	//Objeto que sera retornado pela funcao
Local nHandle	:= 0			//Handle do arquivo
Local lRet		:= .T.			//Criou o arquivo



If !File(::cFile)
	If !(lRet := ::CriaArq())
		cRetorno := "-1"
	EndIf
EndIf

If lRet
	nHandle := fOpen(::cFile)
	
	If nHandle <> -1
		FSeek(nHandle, 0 , FS_END)
		FSeek(nHandle, (Len(::cTxtFin)*-1) , FS_END)
		FwRITE(nHandle, cTexto + ::cTxtFin )
		FClose(nHandle)
		
	Else
		cRetorno := "-1"
	EndIf

EndIf

::GravarLog("Retorno: " + cRetorno +")" )

oRetorno:= ::TratarRet(cRetorno)

Return oRetorno

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบMetodo    ณImpTxtFmt        บAutor  ณVendas Clientes     บ Data ณ  27/07/2017 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEfetua a impressใo de texto formatado com qrcode/bitmap            บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        		 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณoRetorno												             บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Method ImpTxtFmt( cTexto ) Class LJANfEmulador
Local oRetorno 	:= Nil      	//Objeto que sera retornado pela funcao

DEFAULT cTexto	:= ""

::GravarLog("Comando Enviado: ImpTxtFmt:(" + cTexto +")" )
//Se ainda houver texto imprime o restante como texto comum
If !Empty(AllTrim(cTexto))
	oRetorno:= ::Imprimir(cTexto)
EndIf

Return { .T. , oRetorno }

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบMetodo    ณGeraCodeBar        บAutor  ณVendas Clientes    บ Data ณ  27/07/17  บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVerifica se no texto hแ c๓digos  				                     บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        		 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณaRet - {lRet,cTipo,lConfigDef,cComando,cTxtAux}		             บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Method GeraCodeBar(cTexto) Class LJANfEmulador

Local cTxtAux		:= "" //Texto do c๓digo de Barras
Local nPos			:= 0 //Posicao da tag inicial
Local cRetorno      := "" //Retorno da Rotina
Local nPos2			:= 0 //Posicao da Tag Final
Local cTagIni		:= "" //Tag Inicial
Local cTagFim		:= "" //Tag Final
Local nLinhas 		:= Len(::aTagBar) //Tags do codigo de Barras
Local nI 			:= 0 //Contador

DEFAULT cTexto:= ""

If !Empty(cTexto)
	For nI := 1 to nLinhas
		
		cTagIni		:= ::aTagBar[nI, 01]
		cTagFim		:=  ::aTagBar[nI, 02]
		nPos := At(cTagIni,cTexto)
		cRetorno := ""
		cTxtAux := ""
		
		If nPos > 0
			If !Empty( ::aTagBar[nI, 02])
				nPos2 := At(cTagFim,cTexto)
			Else
				nPos2 := Len(cTexto)
			EndIf
			
			cTxtAux := Substr(cTexto,nPos+Len(cTagIni),nPos2-(nPos+Len(cTagIni)))
			If !Empty(::aTagBar[nI, 05])
				cTxtAux := StrTran(cTxtAux, ::aTagBar[nI, 05], ::aTagBar[nI, 06])
			EndIf
			cRetorno := ::aTagBar[nI, 03]+AllTrim(cTxtAux)+ ::aTagBar[nI, 04] + AllTrim(cTxtAux)+ '" > '	
			cTexto := Stuff( cTexto, nPos,(nPos2+Len(cTagFim)) - nPos , cRetorno + CRLF)
			If Empty( ::aTagBar[nI, 02])
				Exit
			EndIf
		EndIf	
	
	Next nI
EndIf

Return cTexto

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบMetodo    ณRetCodeBar        บAutor  ณVendas Clientes    บ Data ณ  27/07/20117บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna C๓digo de Barras  				                         บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        		 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณaRet - {lRet,cTipo,lConfigDef,cComando,cTxtAux}		             บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Method RetCodeBar(cTag, cTexto) Class LJANfEmulador
Local nI := 0	//Contador

Default cTag := ""
DEFAULT cTexto:= ""

nI := aScan(::aTagBar, { |x| x[1] == cTag} )
If nI > 0
	
		If !Empty(::aTagBar[nI, 05])
			cTexto := StrTran(cTexto, ::aTagBar[nI, 05], ::aTagBar[nI, 06])
		EndIf
		cTexto := ::aTagBar[nI, 03]+AllTrim(cTexto)+ ::aTagBar[nI, 04]	
Else
	cTexto := "" 
EndIf

Return cTexto

//--------------------------------------------------------
/*/
Efetua o envio do comando de abrir gaveta
@param   Sem parametro
@author  Varejo
@version P11.8
@since   27/07/2017
@return  oRetorno
/*/
//-------------------------------------------------------
Method AbrirGavet() Class LJANfEmulador
Local oRetorno 	:= Nil      	//Objeto que sera retornado pela funcao	
Local cRetorno 	:= "1"       	//String contendo o retorno da funcao que envia o comando para a serial

oRetorno:= ::TratarRet(cRetorno)

Return oRetorno

//--------------------------------------------------------
/*/
Efetua o envio do corte de papel
@param   Sem parametro
@author  Varejo
@version P11.8
@since   27/07/2017
@return  oRetorno
/*/
//-------------------------------------------------------
Method CortaPapel() Class LJANfEmulador
Local oRetorno 	:= Nil      	//Objeto que sera retornado pela funcao	
Local cRetorno 	:= "1"       	//String contendo o retorno da funcao que envia o comando para a serial

cRetorno:= ::TratarRet(cRetorno)

Return oRetorno

//--------------------------------------------------------
/*/
Gera a imagem
@param   Sem parametro
@author  Varejo
@version P11.8
@since   29/03/2016
@return  oRetorno
/*/
//-------------------------------------------------------
Method GeraBitMap(cFileName) Class LJANfEmulador
Local cFileNoExt 	:= "" //Arquivo sem extensใo
Local nPos 			:= 0 //Posicao da Extensao

If Empty(cFileName)
	cFileName := ::cImgDef
EndIf

//Retira a extensใo do arquivo

If (nPos := At( ".", cFileName)) > 0
	cFileNoExt  := Left(cFileName, nPos-1)
EndIf

If !File( ::cDirectory  + cFileName )

	If !RepExtract(cFileNoExt , ::cDirectory  + cFileName )
		cFileName := ""
	EndIf

EndIf
     
cRetorno := '<img src="'+::cDirectory  + cFileName+'" alt ="' + cFileName + '" >'+CRLF

Return cRetorno

//--------------------------------------------------------
/*/
Traduz o Texto
@param   Sem parametro
@author  Varejo
@version P11.8
@since   27/07/2017
@return  oRetorno
/*/
//-------------------------------------------------------
Method TrataTags( cTexto ) Class LJANfEmulador

Local nLinhas 		:= 0				//N๚mero de Linhas do Texto
Local nI 			:= 0				//Contador do Texto
Local cTmpLinhas 	:= ""				//Linha temporแria
Local cLinhaRet 	:= ""				//Linha de Retorno
Local cAlign 		:= ""				//Alinhamento
Local nPosIni 		:= 0				//Posicao Inicial
Local nPosFin 		:= 0				//Posicao Final
Local cLinhaIni 	:= ""				//Linha Inicial
Local aLinhas 		:= {}				//Array de Linhas
Local lEndPar 		:= .T.				//Final de Paramento
Local cStrTokArr2		:= "StrTokArr2" //Funcao de conversao

aLinhas := &cStrTokArr2.(cTexto, CHR(10),.T.)

nLinhas := Len(aLinhas)

For nI := 1 to nLinhas
	
	cAlign := ""
	cTmpLinhas := StrTran(aLinhas[nI], space(1), "&nbsp;")
	cLinhaIni := ""
	lEndPar := .F.
	
	//cTmpLinhas := ""
	If At( TAG_CENTER_INI, cTmpLinhas) > 0 
		cTmpLinhas :=  StrTran( cTmpLinhas,  TAG_CENTER_INI, '<p align = "center">')
	EndIf
	If At( TAG_DIREITA_INI, cTmpLinhas) > 0 
		cTmpLinhas := StrTran( cTmpLinhas,  TAG_DIREITA_INI, '<p align = "right">')
	EndIf
	If At( TAG_CENTER_FIM, cTmpLinhas) > 0
		cTmpLinhas :=  StrTran( cTmpLinhas,  TAG_CENTER_FIM, "</p>")
		lEndPar := .T.
	EndIf
	If At( TAG_DIREITA_FIM, cTmpLinhas) > 0
		cTmpLinhas := StrTran( cTmpLinhas,  TAG_DIREITA_FIM, "</p>")
		lEndPar := .T.
	EndIf 
		cTmpLinhas := StrTran( StrTran( cTmpLinhas,  TAG_PULALI_FIM, "<BR>"), TAG_PULALI_INI,"")
		cTmpLinhas := StrTran( StrTran( cTmpLinhas,  TAG_RISCALN_FIM, "<HR>"), TAG_RISCALN_INI,"")
		cTmpLinhas := StrTran( StrTran( cTmpLinhas,  TAG_TXTEXGG_FIM, "</h2>"), TAG_RISCALN_INI,'<h2 align = "center" >')
		cTmpLinhas := StrTran( StrTran( cTmpLinhas,  TAG_CONDEN_FIM, "</h5>"), TAG_CONDEN_INI,'<h5 align = "center">')
		cTmpLinhas := StrTran( StrTran( cTmpLinhas,  TAG_SUBLI_FIM, "</u>"), TAG_SUBLI_INI,"<u>")
		cTmpLinhas := StrTran( StrTran( cTmpLinhas,  TAG_NORMAL_FIM, "</p>"), TAG_NORMAL_INI,"<p>")
		cTmpLinhas := StrTran( StrTran( cTmpLinhas,  TAG_EXPAN_FIM, ""), TAG_EXPAN_INI,"")
		cTmpLinhas := StrTran( StrTran( cTmpLinhas,  TAG_GUIL_FIM, "<HR>"+CRLF), TAG_GUIL_INI,"")
		cTmpLinhas := StrTran( StrTran( cTmpLinhas,  TAG_ELITE_FIM, ""), TAG_ELITE_INI,"")		
		cTmpLinhas := StrTran( StrTran( cTmpLinhas,  TAG_TABS_FIM, ""), TAG_TABS_INI,"")

		If ( nPosIni := At( TAG_PULANL_INI, cTmpLinhas )) > 0 .AND. ( nPosFin := At( TAG_PULALI_FIM, cTmpLinhas)) > 0
			cTmpLinhas := Left(cTmpLinhas, nPosIni-1) + Replicate("<BR>"+CRLF, Val(Substr(cTmpLinhas,nPosIni+Len(TAG_PULANL_INI)-1, nPosFin-1 ))) + Left(cTmpLinhas, nPosFin+Len(TAG_PULALI_FIM))
		EndIf
		
		If ( nPosIni := At(TAG_BMP_INI, cTmpLinhas) ) > 0  .AND. ( nPosFin := At( TAG_BMP_FIM, cTmpLinhas)) > 0


			cTmpLinhas := Left(cTmpLinhas, nPosIni-1)  + ::GeraBitMap(Substr(cTmpLinhas,nPosIni+Len(TAG_BMP_INI), nPosFin-(nPosIni+Len(TAG_BMP_FIM)) )) +  Substr(cTmpLinhas, nPosFin+Len(TAG_BMP_FIM))
			cTmpLinhas := StrTran( cTmpLinhas,  TAG_BMP_FIM, "")
		EndIf
		cTmpLinhas := ::GeraCodeBar(cTmpLinhas)
		


		
	cLinhaRet += cTmpLinhas + IIF(!lEndPar, "<br>"+CRLF, "")

Next nI


Return cLinhaRet


//--------------------------------------------------------
/*/{Protheus.doc} CarregTag
Realiza a alimenta็ใo do array de de-para de tags
@author  	Varejo
@version 	P11.8
@since   	27/07/2017
@sample
/*/
//--------------------------------------------------------
Method CarregTag() Class LJANfEmulador
Local cUrlMsg := '<img height=' +::cCodeBarSize +' src="https://api-bwipjs.rhcloud.com/?bcid='


::aTagBar := Array(16)


::aTagBar[1] := { TAG_COD128_INI, TAG_COD128_FIM,  cUrlMsg + 'code128&text=' , '&includetext" alt ="',,}
::aTagBar[2] := { TAG_UPCA_INI, TAG_UPCA_FIM,   cUrlMsg + 'upca&text=' , '&includetext" alt ="',,}
::aTagBar[3] := { TAG_EAN13_INI, TAG_EAN13_FIM, cUrlMsg + 'ean13&text=' , '&includetext" alt ="',,}
::aTagBar[4] := { TAG_EAN8_INI, TAG_EAN8_FIM, cUrlMsg + 'ean8&text=' , '&includetext" alt ="',,}
::aTagBar[5] := { TAG_CODE39_INI, TAG_CODE39_FIM, cUrlMsg + 'code39&text=' , '&includetext&hidestars" alt ="',,}	
::aTagBar[6] := { TAG_CODE93_INI, TAG_CODE93_FIM, cUrlMsg + 'code93&text=' ,'&includetext&parsefnc" alt ="',,}
::aTagBar[7] := { TAG_CODABAR_INI, TAG_CODABAR_FIM, cUrlMsg + 'rationalizedCodabar&text=' ,'&includetext" alt ="',,}	
::aTagBar[8] := { TAG_PDF_INI, TAG_PDF_FIM,  cUrlMsg + 'hibcpdf417&text=' ,'" alt ="',,}	
::aTagBar[9] := { TAG_QRCODE_INI, TAG_QRCODE_FIM, '<img src="https://chart.googleapis.com/chart?chs='+ ::cQrCodeSize + "x" + ::cQrCodeSize +'&cht=qr&chl=' ,'" alt ="', "&", "%26"}

::aTagBar[10] := { TAG_CODE11_INI, TAG_CODE11_FIM, cUrlMsg + 'code11&text=' ,'&includetext" alt ="',,}
::aTagBar[11] := { TAG_I2OF5_INI+"<txt>", "</txt>"+TAG_I2OF5_FIM, cUrlMsg + 'interleaved2of5&text=' ,'&includetext" alt ="',,}
::aTagBar[12] := { TAG_S2OF5_INI, TAG_S2OF5_FIM, cUrlMsg + 'iata2of5&text=' ,'&includetext" alt ="',,}

//Segundo o boletim para este comando nใo tem tag que encerra o texto portanto 
//tudo que vier ap๓s o comando serแ considerado como c๓digo ITF, recomenda-se imprimir este c๓digo separadamente de outros textos	
::aTagBar[13] := { TAG_ITF, "", cUrlMsg + 'interleaved2of5&text=' ,+'&includetext" alt ="',,}
::aTagBar[14] := { TAG_ISBN, "", cUrlMsg + 'isbn&text=',+'&includetext" alt ="',,}
::aTagBar[15] := { TAG_MSI_INI,"" , cUrlMsg + 'msi&text=',+'&includetext" alt ="',,}
::aTagBar[16] := { TAG_PLESSEY,"" , cUrlMsg + 'plessey&text=',+'&includetext" alt ="',,}




Return

//--------------------------------------------------------
/*/{Protheus.doc} RetImpdef
Retorna configura็๕es do emulador
@author  	Varejo
@version 	P11.8
@since   	27/07/2017
@sample
/*/
//--------------------------------------------------------
Method RetImpdef(cSecao, cChave, uDef) Class LJANfEmulador
Local  uRet := NIL //Retorno da rotina

	uRet := GetPvProfString( cSecao, cChave, uDef, ::cFileIni )

Return uRet


//--------------------------------------------------------
/*/{Protheus.doc} CriarArq
Cria o arquivo html do emulador
@author  	Varejo
@version 	P11.8
@since   	27/07/2017
@sample
/*/
//--------------------------------------------------------
Method CriaArq() Class LJANfEmulador
Local lCreated := .T. //Arquivo Criado
Local nHandle	:= 0 //Handle do arquivo

If !File(::cFile)
  		nHandle := FCreate(::cFile)

		If (nHandle <>  -1)
		   fWrite(nHandle, ::cTxtIni+::cTxtFin)
		   If !fClose(nHandle)
		       lCreated := .F.
		   EndIf
			
		Else
		  lCreated := .F.

		Endif
EndIf


Return lCreated