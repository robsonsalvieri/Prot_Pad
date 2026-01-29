#INCLUDE "TOTVS.CH"
#INCLUDE "MSOBJECT.CH" 
#INCLUDE "DEFECF.CH"
#INCLUDE "AUTODEF.CH"
#INCLUDE "FILEIO.CH"

Function LOJA1351 
Return 	 // "dummy" function - Internal Use

//----------------------------------------------------------
/*{Protheus.doc}LJCEpsonTMT800F
Classe responsável pelos modelos T800 e T990
do Convênio ECF 09/09

@author  	Julio.Nery
@version 	P11 e P12
@since   	02/02/2018
*/
//--------------------------------------------------------
Class LJCEpsonTMT800F From LJAEpson
	Data oFormasVen					//Formas da venda, objeto do tipo LJCFormasEcf
	Data cPathBin					//Diretorio dos Arquivos binários
	
	Method New(oTotvsApi)
	Method GetCodEcf() 				//Retorna codigo da impressora
	Method LeCOO()
	Method GetInterve()
	Method GetCancela()
	Method ReducaoZ()
	Method LeCupIni()
	Method GetNumCnf()
	Method GetNumCrg()	
	Method GetNumCcc()
	Method AbrirCF(cCnpj, cCliente, cEndereco)
	Method EstNFiscVinc(cCPFCNPJ,cCliente,cEndereco,cMensagem,cCOOCCD)
	Method DownloadMFD(cBinario,cTipo,cInicio,cFinal)
	Method IdCliente(cCnpj, cNome, cEnd)
EndClass

//----------------------------------------------------------
/*{Protheus.doc} PrepEpRel
Prepara o relatório para o ECF 

@author  	Julio.Nery
@version 	P11 e P12
@since   	02/02/2018
*/
//--------------------------------------------------------
Static Function PrepEpRel(cDados, nVias)
Local oRetorno 	:= Nil					//Retorno da funcao do tipo LJCRelatoriosEcf
Local cDelimit 	:= CHR(10)				//Delimitador
Local cDelimit13:= CHR(13)				//Delimitador sera retirado da string 
Local lLoop		:= .T.					//Variavel de controle do While
Local cAux		:= ""				    //Variavel para guardar linha a linha do relatorio
Local nCount	:= 1					//Variavel de controle contador
Local nViasAux	:= 1					//Controla o numero de vias
Local cTexto	:= ""					//Guarda o conteudo da variavel cDados
   	
//Instancia o objeto LJCRelatoriosEcf
oRetorno := LJCRelatoriosEcf():New()
   	   			
//Retira o delimitador do inicio da string
If Substr(cDados, 1, 1) == cDelimit
	cDados := Substr(cDados, 2)
EndIf

//Retira o delimitador do fim da string
If Substr(cDados, Len(cDados), 1) == cDelimit
	cDados := Substr(cDados, 1, Len(cDados) - 1)
EndIf

//Guarda o conteudo original
cTexto := cDados

While lLoop
    //Procura o delimitador na string
	nPos := At(cDelimit, cDados)
    
    //Verifica se encontrou o delimitador
	If nPos > 0 
		cAux := Substr(cDados, 1, nPos-1)
		cDados := Substr(cDados, nPos + 1)
		
		If cAux == cDelimit .OR. cAux == cDelimit13
			oRetorno:ADD(nCount++, " ")
		Else
			//Retira esse caracter para nao apresentar erro na impressora
			cAux := Alltrim( StrTran(cAux, cDelimit13, " "))
			oRetorno:ADD(nCount++, cAux)
		Endif
	Else         
		//Retira esse caracter para nao apresentar erro na impressora
		cDados := Alltrim( StrTran(cDados, cDelimit13, " "))
	
		oRetorno:ADD(nCount++, cDados)	
		
		If nViasAux == nVias
			lLoop := .F.
		Else
			//Adiciona a proxima via
			nViasAux++
			
			oRetorno:ADD(nCount++, Space(40))
			oRetorno:ADD(nCount++, Replicate("-", 15) + AllTrim(Str(nViasAux)) + " Via" + Replicate("-", 15))
			oRetorno:ADD(nCount++, Space(40))
			
			cDados := cTexto
		EndIf
	EndIf
End
	
Return oRetorno

//----------------------------------------------------------
/*{Protheus.doc} New

@author  	Julio.Nery
@version 	P11 e P12
@since   	02/02/2018
*/
//--------------------------------------------------------
Method New(oTotvsApi) Class LJCEpsonTMT800F
Local oXML 		:= NIL
Local nXML		:= 0
Local nFimXML	:= 0
Local cXML 		:= ""
LOcal cError	:= ""
Local cWarning	:= ""
Local cRetorno 	:= ""			//String contendo o retorno da funcao que envia o comando para a serial
Local cLocalDir	:= GetClientDir()

//Executa o metodo construtor da classe pai
_Super:New(oTotvsApi)

If File(cLocalDir+"\paflista.txt") .And. File(cLocalDir + "\InterfaceEpson.XML")//só faz isso se for PAF-ECF
	cXML := cLocalDir + "\InterfaceEpson.XML"
	nXML := FOpen(cXML)
	cXML := ""
	nFimXML := FSeek(nXML,0,FS_END)
	FSeek(nXML,0,FS_SET)
	FRead(nXML,@cXML,nFimXML)
	FClose(nXML)
	oXML := XmlParser(EncodeUTF8(cXML),"_", @cError, @cWarning)
	LjGrvLog( Nil, " Log do Arquivo [InterfaceEpson.XML] ", oXML)
	
	::cPathMFD  := "C:\LeituraMFD_ESP.txt"
	::cPathMF   := "C:\LeituraMF.txt"
	::cPathTipoE:= oXML:_EPSON:_FISCAL:_PATH:TEXT + "\Cotepe1704_CTP.txt"
	
	::cPathBin	:= AllTrim(GetPvProfString("PAF-ECF","patharqmfd", "C:" , cLocalDir +"SIGALOJA.INI") + "\")
	If Empty(AllTrim(::cPathBin))
		::cPathBin := "C:\"
	EndIf
EndIf

Return Self

//----------------------------------------------------------
/*{Protheus.doc} GetCodEcf

@author  	Julio.Nery
@version 	P11 e P12
@since   	02/02/2018
*/
//--------------------------------------------------------
Method GetCodEcf() Class LJCEpsonTMT800F
Local oRetorno 	:= Nil			 //Objeto que sera retornado pela funcao   

oRetorno := Self:TratarRet("0000") //Trata o retorno 
oRetorno:oRetorno := "151002"	//Copia o valor da propriedade da classe

Return oRetorno

//----------------------------------------------------------
/*{Protheus.doc} LeCOO

@author  	Julio.Nery
@version 	P11 e P12
@since   	02/02/2018
*/
//--------------------------------------------------------
Method LeCOO() Class LJCEpsonTMT800F
Local oParams 	:= Nil			//Objeto para passagem dos parametros
Local oRetorno	:= Nil
Local cRetorno	:= ""
Local cDados  	:= Space(11)	//String que recebera os contadores da impressora

//Prepara os parametros de envio 
oParams := ::PrepParam({EPSON, "EPSON_ESC_ECF_Obter_Dados","1","1",cDados})
cRetorno:= ::EnviarCom(oParams)
cRetorno:= ::ObterEst()
oRetorno:= ::TratarRet(cRetorno) 
	
If (oRetorno:cAcao == OK)
	oRetorno:oRetorno := Substr(oParams:Elements(3):cParametro,3,9) //COO com 9 dígitos
EndIf
	
Return oRetorno

//----------------------------------------------------------
/*{Protheus.doc} GetInterve
	Captura do CRO

@author  	Julio.Nery
@version 	P11 e P12
@since   	02/02/2018
*/
//--------------------------------------------------------
Method GetInterve() Class LJCEpsonTMT800F
Local oParams 	:= Nil			//Objeto para passagem dos parametros
Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
Local cRetorno	:= ""
Local cDados  	:= Space(5)	//String que recebera os contadores da impressora

oParams := ::PrepParam({EPSON, "EPSON_ESC_ECF_Obter_Dados","1","3",cDados})
cRetorno:= ::EnviarCom(oParams)
cRetorno:= ::ObterEst()
oRetorno:= ::TratarRet(cRetorno) 
	
If (oRetorno:cAcao == OK)
	oRetorno:oRetorno := Substr(oParams:Elements(3):cParametro,3,3)
EndIf

Return oRetorno

//----------------------------------------------------------
/*{Protheus.doc} GetNumCnf
	Contador de operação não fiscal

@author  	Julio.Nery
@version 	P11 e P12
@since   	02/02/2018
*/
//--------------------------------------------------------
Method GetNumCnf() Class LJCEpsonTMT800F
Local oParams 	:= Nil			//Objeto para passagem dos parametros
Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
Local cRetorno	:= ""	
Local cDados  	:= Space(20)	//String que recebera os contadores da impressora

oParams := ::PrepParam({EPSON, "EPSON_ESC_ECF_Obter_Dados","1","2", cDados})
cRetorno:= ::EnviarCom(oParams)
cRetorno:= ::ObterEst()
oRetorno:= ::TratarRet(cRetorno) 
	
If oRetorno:cAcao == OK   	
	oRetorno:oRetorno := Substr(oParams:Elements(3):cParametro,3,9)
EndIf

Return oRetorno

//----------------------------------------------------------
/*{Protheus.doc} GetNumCrg
	Contador de Relatório Gerencial

@author  	Julio.Nery
@version 	P11 e P12
@since   	02/02/2018
*/
//--------------------------------------------------------
Method GetNumCrg() Class LJCEpsonTMT800F
Local oParams 	:= Nil			//Objeto para passagem dos parametros
Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
Local cRetorno	:= ""	
Local cDados  	:= Space(20)	//String que recebera os contadores da impressora

oParams := ::PrepParam({EPSON, "EPSON_ESC_ECF_Obter_Dados","1","9", cDados})
cRetorno:= ::EnviarCom(oParams)
cRetorno:= ::ObterEst()
oRetorno:= ::TratarRet(cRetorno) 
	
If oRetorno:cAcao == OK   	
	oRetorno:oRetorno := Substr(oParams:Elements(3):cParametro,3,9)
EndIf

Return oRetorno

//----------------------------------------------------------
/*{Protheus.doc} GetNumCcc
	Contador de Comprovante de Crédito e Débito

@author  	Julio.Nery
@version 	P11 e P12
@since   	02/02/2018
*/
//--------------------------------------------------------
Method GetNumCcc() Class LJCEpsonTMT800F
Local oParams 	:= Nil			//Objeto para passagem dos parametros
Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
Local cRetorno	:= ""	
Local cDados  	:= Space(20)	//String que recebera os contadores da impressora

oParams := ::PrepParam({EPSON, "EPSON_ESC_ECF_Obter_Dados","1","8", cDados})
cRetorno:= ::EnviarCom(oParams)
cRetorno:= ::ObterEst()
oRetorno:= ::TratarRet(cRetorno) 
	
If oRetorno:cAcao == OK   	
	oRetorno:oRetorno := Substr(oParams:Elements(3):cParametro,3,9)
EndIf

Return oRetorno  

//----------------------------------------------------------
/*{Protheus.doc} GetCancela
	Retorna o número de cupons cancelados

@author  	Julio.Nery
@version 	P11 e P12
@since   	02/02/2018
*/
//--------------------------------------------------------
Method GetCancela() Class LJCEpsonTMT800F
Local oParams 	:= Nil			//Objeto para passagem dos parametros
Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
Local cRetorno	:= ""	
Local cDados  	:= Space(20)	//String que recebera os contadores da impressora

oParams := ::PrepParam({EPSON, "EPSON_ESC_ECF_Obter_Dados","1","11", cDados})
cRetorno:= ::EnviarCom(oParams)
cRetorno:= ::ObterEst()
oRetorno:= ::TratarRet(cRetorno) 

If(oRetorno:cAcao == OK)    	
	oRetorno:oRetorno := Substr(oParams:Elements(3):cParametro,4,9)
EndIf
	
Return oRetorno

//----------------------------------------------------------
/*{Protheus.doc} LeCupIni
	Captura do COO Inicial

@author  	Julio.Nery
@version 	P11 e P12
@since   	02/02/2018
*/
//--------------------------------------------------------
Method LeCupIni() Class LJCEpsonTMT800F
Local oParams 	:= Nil			//Objeto para passagem dos parametros
Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
Local cRetorno	:= ""	
Local cDados  	:= Space(100)	//String que recebera os contadores da impressora
Local aRet		:= {}

oParams := ::PrepParam({EPSON, "EPSON_ESC_ECF_Obter_Dados","17","1", cDados})
cRetorno:= ::EnviarCom(oParams)
cRetorno:= ::ObterEst()
oRetorno:= ::TratarRet(cRetorno) 
	
If oRetorno:cAcao == OK
	aRet := StrToKArr(oParams:Elements(3):cParametro,"|")
	oRetorno:oRetorno := StrZero(Val(aRet[5]),9)
EndIf

Return oRetorno

//----------------------------------------------------------
/*{Protheus.doc} AbrirCF
	Abertura do Cupom Fiscal

@author  	Julio.Nery
@version 	P11 e P12
@since   	02/02/2018
*/
//--------------------------------------------------------
Method AbrirCF(cCnpj, cCliente, cEndereco) Class LJCEpsonTMT800F
Local oParams 	:= Nil			//Objeto para passagem dos parametros
Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
Local cRetorno	:= ""	
Local cEnd		:= Space(79)	
	
//Inicializando variaveis
::InicVar()
     
cEnd	:= SubStr(cEndereco,1,79)
cCliente:= SubStr(cCliente,1,30)
	
oParams := ::PrepParam({EPSON, "EPSON_ESC_ECF_Fiscal_Abrir_CupomEX", AllTrim(cCnpj), cCliente, cEnd})
cRetorno:= ::EnviarCom(oParams)
cRetorno:= ::ObterEst()
oRetorno:= ::TratarRet(cRetorno)
	
Return oRetorno

//----------------------------------------------------------
/*{Protheus.doc} EstNFiscVinc
	Estorno do Cupom Vinculado (CCD)

@author  	Julio.Nery
@version 	P11 e P12
@since   	02/02/2018
*/
//--------------------------------------------------------
Method EstNFiscVinc(cCPFCNPJ,cCliente,cEndereco,cMensagem,;
					cCOOCCD) Class LJCEpsonTMT800F
Local oParams 	:= Nil			//Objeto para passagem dos parametros
Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao	
Local cRetorno	:= ""
Local cEndereco1:= Space(79)
Local oRelatorio:= NIL		//Objeto que armazena o conteudo de cMensagem para ser impresso

Default cCPFCNPJ := ""
Default cCliente := ""
Default cEndereco:= ""

oRelatorio:= PrepEpRel(cMensagem,1)
	
//Inicializando variaveis
::InicVar()
     
cEndereco1 := SubStr(cEndereco,1,79)

If Len(cCliente) > 30
	cCliente	:= SubStr(cCliente,1,30)	
EndIf
	
oParams := ::PrepParam({EPSON, "EPSON_ESC_ECF_NaoFiscal_Cancelar_CCDEX",cCOOCCD,AllTrim(cCPFCNPJ),cCliente,cEndereco1})
cRetorno:= ::EnviarCom(oParams)
cRetorno:= ::ObterEst()
oRetorno:= ::TratarRet(cRetorno) 

If oRetorno:cAcao == OK
	oRetorno:= ::ImpTxtNF(oRelatorio,.F.)
	
	If oRetorno:cAcao == OK
		oRetorno := ::FecharCNFV()
	EndIf
EndIf
	
Return oRetorno

//----------------------------------------------------------
/*{Protheus.doc} ReducaoZ

@author  	Julio.Nery
@version 	P11 e P12
@since   	02/02/2018
*/
//--------------------------------------------------------
Method ReducaoZ() Class LJCEpsonTMT800F
Local oParams 	:= Nil						//Objeto para passagem dos parametros
Local cRetorno 	:= ""		   				//String contendo o retorno da funcao que envia o comando para a serial
Local oRetorno 	:= Nil		   				//Objeto que sera retornado pela funcao
Local cNumRedZ	:= Space(4)	   				//String temporaria que recupera o numero da reducao Z
Local oRedZ		:= LJCDadosReducaoZ():New()//Objeto contendo os dados da reducao Z  
Local nDX		:= 1						//Contador utilizado no comando "For"
Local cSimbolo	:= Space(2)					//String temporaria para armazenamento do simbolo da aliquota
Local cValor	:= Space(4)	   				//String temporaria para armazenamento do valor numerico da aliquota
Local cVendido	:= Space(17)				//String temporaria para armazenamento do valor vendido na aliquota	
Local nImposto	:= 0						//Valor do imposto devido.
Local cDados  	:= Space(533)  				//String que receber a tabela de aliquotas cadastradas no ECF

//Inicia o preenchimento do objeto LJCDadosReducaoZ
oRedZ:cNumEcf	:= ::cNumEcf
oRedZ:cNrSerie	:= ::cNrSerie
    
oRetorno := ::LeDataJor()

If( oRetorno:cAcao == OK )
	oRedZ:dDataMov := CTOD(oRetorno:oRetorno)
	oRetorno := ::LeGT()
EndIf

If( oRetorno:cAcao == OK )
	oRedZ:nGranTotal := Val(oRetorno:oRetorno) / 100
	oRetorno := ::LeCOO()
EndIf

If( oRetorno:cAcao == OK )
	oRedZ:cNumCupFim := oRetorno:oRetorno
	oRetorno := ::LeTotCanc()
EndIf

If( oRetorno:cAcao == OK )
	oRedZ:nTotCancel := oRetorno:oRetorno
	oRetorno := ::LeTotCanISS()
EndIf

If ( oRetorno:cAcao == OK )
	oRedZ:nTotCanISS := oRetorno:oRetorno
	oRetorno := ::LeTotDesc() 
EndIf	
   		
If( oRetorno:cAcao == OK )
	oRedZ:nTotDesc := oRetorno:oRetorno
	oRetorno := ::LeTotDesISS()
EndIf

If ( oRetorno:cAcao == OK )
	oRedZ:nTotDesISS := oRetorno:oRetorno
	oRetorno := ::LeTotIsent() 
EndIf	

If( oRetorno:cAcao == OK )
	oRedZ:nTotIsent	:= oRetorno:oRetorno
	oRetorno := ::LeTotNTrib()
EndIf

If( oRetorno:cAcao == OK )
	oRedZ:nTotNTrib := oRetorno:oRetorno
	oRetorno := ::LeTotIss()
EndIf

If( oRetorno:cAcao == OK )
	oRedZ:nTotIss := oRetorno:oRetorno
	oRetorno := ::LeVndLiq()
EndIf

If( oRetorno:cAcao == OK )
	oRedZ:nVendaLiq := oRetorno:oRetorno
	oRetorno := ::LeVndBrut()
EndIf

If( oRetorno:cAcao == OK )
	oRedZ:nVendaBrut := oRetorno:oRetorno
	oRetorno := ::GetSubstit()
EndIf

If( oRetorno:cAcao == OK )
	oRedZ:nTotSubst := oRetorno:oRetorno
	oRetorno := ::GetDatHora()
EndIf

If( oRetorno:cAcao == OK )
	oRedZ:dDataRed := CTOD(Substr(oRetorno:oRetorno, 1, 10))
	oRetorno := ::GetInterve()
EndIf

If( oRetorno:cAcao == OK )
	oRedZ:cCro := oRetorno:oRetorno
    oRetorno := ::LeCupIni()
EndIf

If( oRetorno:cAcao == OK )
	oRedZ:cNumCupIni := oRetorno:oRetorno
EndIf

oRedZ:cCoo := StrZero(Val(oRedZ:cNumCupFim) + 1, 9)
		
//Prepara os parametros de envio 
oRetorno := ::ExcTabAlq( @oParams )

// Caso o comando tenha sido executado com sucesso	
If (oRetorno:cAcao == OK)
	For nDX := 1 To Len(oParams:Elements(3):cParametro)
		cSimbolo := AllTrim(SubStr(oParams:Elements(3):cParametro,nDX,2))	// Copia o simbolo da aliquota
		nDX += 2															
		cValor := AllTrim(SubStr(oParams:Elements(3):cParametro,nDX,4))	// Copia o valor numerico da aliquota
		nDX += 4
		cVendido := AllTrim(SubStr(oParams:Elements(3):cParametro,nDX,17))	// Copia o valor vendido na aliquota
		nDX += 16
		//Caso o simbolo seja preenchido
		If !Empty(AllTrim(cSimbolo))
			If SubStr(cSimbolo,1,1) $ "T|S"
				nImposto := NoRound(((Val(cValor) / 100) * (Val(cVendido) / 100)) /100, 2)
				oRedZ:AdicImp(Val(cValor) / 100, Val(cVendido) / 100, nImposto, SubStr(cSimbolo,1,1))
			EndIf
		EndIf
	Next nDX
	
	oRetorno := ::GetISSIsen()
	oRedZ:nTotIssIse := oRetorno:oRetorno
	
	oRetorno := ::GetIssNTri()
	oRedZ:nTotIssNTr := oRetorno:oRetorno
	
	oRetorno := ::GetIssSubs()
	oRedZ:nTotIssSub := oRetorno:oRetorno
EndIf

oParams	:= ::PrepParam({EPSON, "EPSON_RelatorioFiscal_RZ","","","9",cNumRedZ})
cRetorno:= ::EnviarCom(oParams)
cRetorno:= ::ObterEst()
oRetorno:= ::TratarRet(cRetorno) 

If oRetorno:cAcao == OK
    oRedZ:cNumRedZ	:= oParams:Elements(6):cParametro
	::oDadosRedZ	:= oRedZ
	::InicVar() //Inicializa variaveis
EndIf

Return oRetorno

//--------------------------------------------------------
/*/{Protheus.doc} DownloadMFD
Abre o cupom fiscal
@param1		cTipo -
@param2		cInicio -  
@param3		cFinal - 
@author  	Varejo
@version 	P12
@since   	14/03/2018
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
/*/
//--------------------------------------------------------
Method DownloadMFD(cBinario,cTipo,cInicio,cFinal) Class LJCEpsonTMT800F
Local oParams 	:= Nil			//Objeto para passagem dos parametros
Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
Local cRetorno 	:= ""			//String contendo o retorno da funcao que envia o comando para a serial
Local cPath		:= ""
Local cTpArq	:= IIf(cTipo=="1","1","2") //1=Data ; 2=CRZ; 3=COO; 4=Total

Default cBinario := "0"

oRetorno := ::GetPathTipoE(cBinario)
cPath := AllTrim(oRetorno:oRetorno) //Já contem o nome do arquivo "DOWNLOAD.BIN"
If !Empty(cPath)
	oParams	:= ::PrepParam({EPSON, "EPSON_ESC_ECF_Obter_Binario_MFD",cTpArq,cInicio,cFinal,cPath})
	cRetorno:= ::EnviarCom(oParams)
	cRetorno:= ::ObterEst()
	oRetorno:= ::TratarRet(cRetorno)
Else
	LjGrvLog(Nil,"Erro ao capturar caminho de geração do arquivo")
EndIf

Return oRetorno

//--------------------------------------------------------
/*/{Protheus.doc} IdCliente
Abre o cupom fiscal
@param1		cCNPJ - Indica o cliente do cupom fiscal
@param2		cNome - Nome
@param3		cEnd - Endereco
@author  	Varejo
@version 	P11.8
@since   	28/04/2016
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
/*/
//--------------------------------------------------------
Method IdCliente(cCnpj, cNome, cEnd) Class LJCEpsonTMT800F
Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao	

::InicVar() //Inicializando variaveis

oRetorno := ::TratarRet("0000")
LjGrvLog(Nil, "Esse modelo não aceita esse comando, retorno OK")
	
Return oRetorno