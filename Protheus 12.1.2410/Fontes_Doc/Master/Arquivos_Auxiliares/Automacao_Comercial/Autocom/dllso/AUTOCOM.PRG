/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ DLL/SO   ³ BemaFI32.DLL    ³ Autor ³ Cesar Valadao  ³ Data ³ 21/09/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Inicializa as definicoes das funcoes da DLL BemaFI32.DLL   ³±±
±±³          ³ utilizada pela AUTOCOM.DLL                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
#IFNDEF LINUX
	DLL FUNCTION Bematech_FI_AbrePortaSerial		LOCALNAME BEMA_ABRSE PARAMTYPE PASCAL () AS INTEGER LIB "BemaFI32.DLL"
	DLL FUNCTION Bematech_FI_FechaPortaSerial		LOCALNAME BEMA_FCHSE PARAMTYPE PASCAL () AS INTEGER LIB "BemaFI32.DLL"
	DLL FUNCTION Bematech_FI_LeituraX				LOCALNAME BEMA_LEITX PARAMTYPE PASCAL () AS INTEGER LIB "BemaFI32.DLL"
	DLL FUNCTION Bematech_FI_RetornoImpressora		LOCALNAME BEMA_RETIM PARAMTYPE PASCAL ( ACK AS PINTEGER, ST1 AS PINTEGER, ST2 AS PINTEGER ) AS INTEGER LIB "BemaFI32.DLL"
	DLL FUNCTION Bematech_FI_NumeroCupom   			LOCALNAME BEMA_PEGCU PARAMTYPE PASCAL ( NumeroCupom AS PCHAR ) AS INTEGER LIB "BemaFI32.DLL"
#ELSE
	DLL FUNCTION Bematech_FI_AbrePortaSerial		LOCALNAME BEMA_ABRSE PARAMTYPE PASCAL () AS INTEGER LIB "./bemafi32.so"
	DLL FUNCTION Bematech_FI_FechaPortaSerial		LOCALNAME BEMA_FCHSE PARAMTYPE PASCAL () AS INTEGER LIB "./bemafi32.so"
	DLL FUNCTION Bematech_FI_LeituraX				LOCALNAME BEMA_LEITX PARAMTYPE PASCAL () AS INTEGER LIB "./bemafi32.so"
	DLL FUNCTION Bematech_FI_RetornoImpressora		LOCALNAME BEMA_RETIM PARAMTYPE PASCAL ( ACK AS PINTEGER, ST1 AS PINTEGER, ST2 AS PINTEGER ) AS INTEGER LIB "./bemafi32.so"
	DLL FUNCTION Bematech_FI_NumeroCupom   			LOCALNAME BEMA_PEGCU PARAMTYPE PASCAL ( NumeroCupom AS PCHAR ) AS INTEGER LIB "./bemafi32.so"
#ENDIF

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ DLL/SO   ³ SerSweda.DLL    ³Autora ³Adrianne Furtado³ Data ³ 17/01/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Inicializa as definicoes das funcoes da DLL Sersweda.DLL   ³±±
±±³          ³ utilizada pela AUTOCOM.DLL                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
#IFNDEF LINUX
	DLL FUNCTION ECFOpen		LOCALNAME SWED_ECFOP PARAMTYPE PASCAL ( NumeroPorta AS LONG, TimeOut AS LONG, Log AS LONG, ShowErro AS LONG) AS LONG LIB "SwEcf.DLL"
	DLL FUNCTION ECFWrite		LOCALNAME SWED_WRITE PARAMTYPE PASCAL ( Comando AS PCHAR ) AS LONG LIB "SwEcf.DLL"
	DLL FUNCTION ECFRead		LOCALNAME SWED_READ  PARAMTYPE PASCAL ( Status AS PCHAR , ext AS LONG) AS LONG LIB "SwEcf.DLL"
	DLL FUNCTION ECFClose  		LOCALNAME SWED_CLOSE PARAMTYPE PASCAL ( ) AS LONG LIB "SwEcf.DLL"
#ENDIF

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ DLL/SO   ³ CliSiTef32i.DLL ³ Autor ³ Cesar Valadao  ³ Data ³ 21/09/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Inicializa as definicoes das funcoes da DLL BemaFI32.DLL   ³±±
±±³          ³ utilizada pela AUTOCOM.DLL                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
#IFNDEF LINUX
	//Processo de Venda e Recarga de Celular
	DLL FUNCTION ConfiguraIntSiTefInterativo						LOCALNAME SIT_CONF   PARAMTYPE PASCAL ( pEnderecoIP AS PCHAR, pCodigoLoja AS PCHAR, pNumeroTerminal AS PCHAR, ConfiguraResultado AS SMALLINT) AS INTEGER LIB "CliSiTEF32i.DLL"
	DLL FUNCTION IniciaFuncaoSiTefInterativo						LOCALNAME SIT_INICIA PARAMTYPE PASCAL ( Modalidade AS INTEGER, pValor AS PCHAR, pNumeroCupomFiscal AS PCHAR, pDataFiscal AS PCHAR, pHorario AS PCHAR, pOperador AS PCHAR, pRestricoes AS PCHAR) AS INTEGER LIB "CliSiTEF32i.DLL"
	DLL FUNCTION FinalizaTransacaoSiTefInterativo					LOCALNAME SIT_FINAL  PARAMTYPE PASCAL ( nConfirma AS INTEGER, pNumeroCupomFiscal AS PCHAR, pDataFiscal AS PCHAR, pHorario AS PCHAR) AS VOID LIB "CliSiTEF32i.DLL"
	DLL FUNCTION ContinuaFuncaoSiTefInterativo						LOCALNAME SIT_CONTIN PARAMTYPE PASCAL ( ProximoComando AS PINTEGER, TipoCampo AS PINTEGER, TamanhoMinimo AS PSMALLINT, TamanhoMaximo AS PSMALLINT, pBuffer AS PCHAR, TamMaxBuffer AS INTEGER, ContinuaNavegacao AS INTEGER) AS INTEGER LIB "CliSiTEF32i.DLL"

	//PinPad
	DLL FUNCTION EscreveMensagemPermanentePinPad					LOCALNAME SIT_MSNPIN PARAMTYPE PASCAL ( pMensagem AS PCHAR ) AS INTEGER LIB "CliSiTEF32i.DLL"
	DLL FUNCTION VerificaPresencaPinPad								LOCALNAME SIT_VERPIN PARAMTYPE PASCAL ( ) AS INTEGER LIB "CliSiTEF32i.DLL"

	//Correspondentes Bancarios
	DLL FUNCTION CorrespondenteBancarioSiTefInterativo				LOCALNAME SIT_CORRES PARAMTYPE PASCAL ( pNumeroCupomFiscal AS PCHAR, pDataFiscal AS PCHAR, pHorario AS PCHAR, pOperador AS PCHAR, pRestricoes AS PCHAR) AS INTEGER LIB "CliSiTEF32i.DLL"
	DLL FUNCTION ValidaCampoCodigoEmBarras							LOCALNAME SIT_VLDBAR PARAMTYPE PASCAL ( pDados AS PCHAR, pTipo AS PCHAR ) AS INTEGER LIB "CliSiTEF32i.DLL"

	//Funcoes VidaLink
	DLL FUNCTION IniciaFuncaoSiTefInterativoConsultaVidalink 		LOCALNAME SIT_VDLCON PARAMTYPE PASCAL ( pCodigoAutorizacao AS PCHAR, pCodigoProduto AS PCHAR, pCuponFiscal AS PCHAR, pDataFiscal AS PCHAR, pHorario AS PCHAR, pOperador AS PCHAR ) AS INTEGER LIB "CliSiTEF32i.DLL"
	DLL FUNCTION InformaProdutoVendaVidalink						LOCALNAME SIT_VDLPRO PARAMTYPE PASCAL ( nIndiceProduto AS INTEGER, pCodigoProduto AS PCHAR,  nQuantidade AS INTEGER, pValorVenda AS PCHAR ) AS INTEGER LIB "CliSiTEF32i.DLL"
	DLL FUNCTION IniciaFuncaoSiTefInterativoVendaVidalink			LOCALNAME SIT_VDLVEN PARAMTYPE PASCAL ( pCodigoAutorizacao AS PCHAR, nNumeroProdutos AS INTEGER, pCuponFiscal AS PCHAR,  pDataFiscal AS PCHAR,  pHorario AS PCHAR, pOperador AS PCHAR) AS INTEGER LIB "CliSiTEF32i.DLL"
	DLL FUNCTION IniciaFuncaoSiTefInterativoCancelamentoVidalink	LOCALNAME SIT_VDLCAN PARAMTYPE PASCAL ( nParcialTotal AS INTEGER,  pCuponFiscal AS PCHAR, pDataFiscal AS PCHAR, pHorario AS PCHAR,  pOperador AS PCHAR) AS INTEGER LIB "CliSiTEF32i.DLL"

	//Estas opções abaixo ainda não foram utilizadas
	DLL FUNCTION LeSimNaoPinPad										LOCALNAME SIT_LSNPIN PARAMTYPE PASCAL ( pMensagem AS PCHAR ) AS INTEGER LIB "CliSiTEF32i.DLL"
	DLL FUNCTION LeCartaoDireto										LOCALNAME SIT_LECART PARAMTYPE PASCAL ( pMensagem AS PCHAR, pTrilha1 AS PCHAR, pTrilha2 AS PCHAR) AS INTEGER LIB "CliSiTEF32i.DLL"
	DLL FUNCTION InterrompeLeCartaoDireto							LOCALNAME SIT_CANCLE PARAMTYPE PASCAL ( ) AS INTEGER LIB "CliSiTEF32i.DLL"
	DLL FUNCTION LeSenhaDireto										LOCALNAME SIT_LESENH PARAMTYPE PASCAL ( pParam AS PCHAR, pSenha AS PCHAR ) AS INTEGER LIB "CliSiTEF32i.DLL"
	DLL FUNCTION ObtemQuantidadeTransacoesPendentes					LOCALNAME SIT_OBTQTR PARAMTYPE PASCAL ( pDataFiscal AS PCHAR , pCupomFiscal AS PCHAR ) AS INTEGER LIB "CliSiTEF32i.DLL"	
#ELSE
	//Processo de Venda e Recarga de Celular
	DLL FUNCTION ConfiguraIntSiTefInterativo						LOCALNAME SIT_CONF   PARAMTYPE PASCAL ( pEnderecoIP AS PCHAR, pCodigoLoja AS PCHAR, pNumeroTerminal AS PCHAR, ConfiguraResultado AS SMALLINT) AS INTEGER LIB "./libclisitef.so"
	DLL FUNCTION IniciaFuncaoSiTefInterativo						LOCALNAME SIT_INICIA PARAMTYPE PASCAL ( Modalidade AS INTEGER, pValor AS PCHAR, pNumeroCupomFiscal AS PCHAR, pDataFiscal AS PCHAR, pHorario AS PCHAR, pOperador AS PCHAR, pRestricoes AS PCHAR) AS INTEGER LIB "./libclisitef.so"
	DLL FUNCTION FinalizaTransacaoSiTefInterativo					LOCALNAME SIT_FINAL  PARAMTYPE PASCAL ( nConfirma AS INTEGER, pNumeroCupomFiscal AS PCHAR, pDataFiscal AS PCHAR, pHorario AS PCHAR) AS VOID LIB "./libclisitef.so"
	DLL FUNCTION ContinuaFuncaoSiTefInterativo						LOCALNAME SIT_CONTIN PARAMTYPE PASCAL ( ProximoComando AS PINTEGER, TipoCampo AS PINTEGER, TamanhoMinimo AS PSMALLINT, TamanhoMaximo AS PSMALLINT, pBuffer AS PCHAR, TamMaxBuffer AS INTEGER, ContinuaNavegacao AS INTEGER) AS INTEGER LIB "./libclisitef.so"

	//PinPad
	DLL FUNCTION EscreveMensagemPermanentePinPad					LOCALNAME SIT_MSNPIN PARAMTYPE PASCAL ( pMensagem AS PCHAR ) AS INTEGER LIB "./libclisitef.so"
	DLL FUNCTION VerificaPresencaPinPad								LOCALNAME SIT_VERPIN PARAMTYPE PASCAL ( ) AS INTEGER LIB "./libclisitef.so"

	//Correspondentes Bancarios
	DLL FUNCTION CorrespondenteBancarioSiTefInterativo				LOCALNAME SIT_CORRES PARAMTYPE PASCAL ( pNumeroCupomFiscal AS PCHAR, pDataFiscal AS PCHAR, pHorario AS PCHAR, pOperador AS PCHAR, pRestricoes AS PCHAR) AS INTEGER LIB "./libclisitef.so"
	DLL FUNCTION ValidaCampoCodigoEmBarras							LOCALNAME SIT_VLDBAR PARAMTYPE PASCAL ( pDados AS PCHAR, pTipo AS PCHAR ) AS INTEGER LIB "./libclisitef.so"

	//Funcoes VidaLink
	DLL FUNCTION IniciaFuncaoSiTefInterativoConsultaVidalink 		LOCALNAME SIT_VDLCON PARAMTYPE PASCAL ( pCodigoAutorizacao AS PCHAR, pCodigoProduto AS PCHAR, pCuponFiscal AS PCHAR, pDataFiscal AS PCHAR, pHorario AS PCHAR, pOperador AS PCHAR ) AS INTEGER LIB "./libclisitef.so"
	DLL FUNCTION InformaProdutoVendaVidalink						LOCALNAME SIT_VDLPRO PARAMTYPE PASCAL ( nIndiceProduto AS INTEGER, pCodigoProduto AS PCHAR,  nQuantidade AS INTEGER, pValorVenda AS PCHAR ) AS INTEGER LIB "./libclisitef.so"
	DLL FUNCTION IniciaFuncaoSiTefInterativoVendaVidalink			LOCALNAME SIT_VDLVEN PARAMTYPE PASCAL ( pCodigoAutorizacao AS PCHAR, nNumeroProdutos AS INTEGER, pCuponFiscal AS PCHAR,  pDataFiscal AS PCHAR,  pHorario AS PCHAR, pOperador AS PCHAR) AS INTEGER LIB "./libclisitef.so"
	DLL FUNCTION IniciaFuncaoSiTefInterativoCancelamentoVidalink	LOCALNAME SIT_VDLCAN PARAMTYPE PASCAL ( nParcialTotal AS INTEGER,  pCuponFiscal AS PCHAR, pDataFiscal AS PCHAR, pHorario AS PCHAR,  pOperador AS PCHAR) AS INTEGER LIB "./libclisitef.so"

	//Estas opções abaixo ainda não foram utilizadas
	DLL FUNCTION LeSimNaoPinPad										LOCALNAME SIT_LSNPIN PARAMTYPE PASCAL ( pMensagem AS PCHAR ) AS INTEGER LIB "./libclisitef.so"
	DLL FUNCTION LeCartaoDireto										LOCALNAME SIT_LECART PARAMTYPE PASCAL ( pMensagem AS PCHAR, pTrilha1 AS PCHAR, pTrilha2 AS PCHAR) AS INTEGER LIB "./libclisitef.so"
	DLL FUNCTION InterrompeLeCartaoDireto							LOCALNAME SIT_CANCLE PARAMTYPE PASCAL ( ) AS INTEGER LIB "./libclisitef.so"
	DLL FUNCTION LeSenhaDireto										LOCALNAME SIT_LESENH PARAMTYPE PASCAL ( pParam AS PCHAR, pSenha AS PCHAR ) AS INTEGER LIB "./libclisitef.so"
	DLL FUNCTION ObtemQuantidadeTransacoesPendentes					LOCALNAME SIT_OBTQTR PARAMTYPE PASCAL ( pDataFiscal AS PCHAR , pCupomFiscal AS PCHAR ) AS INTEGER LIB "./libclisitef.so"	
#ENDIF

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿±±
±±³ DLL/SO   ³Banorte.dll ³ Autor ³ Marcos Alves-En Mexico³ Data ³03/12/04³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Inicializa as definicoes das funcoes da DLL BANORTE.DLL    ³±±
±±³          ³ utilizada pela AUTOCOM.DLL                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
#IFNDEF LINUX
DLL FUNCTION ProcessTransaction		LOCALNAME BANORTE	PARAMTYPE PASCAL ( pNumCart AS PCHAR,pNomeCli AS PCHAR,pSenha AS PCHAR,pClientID AS PCHAR,pPipeline AS PCHAR,pMode AS PCHAR,pTransType AS PCHAR,pCartao AS PCHAR,pValid AS PCHAR,pOrderId AS PCHAR,pTotal AS PCHAR,pResp AS PCHAR) AS INTEGER LIB "BANORTE.DLL"
#ENDIF

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao   ³ ExecInClientDLL ³ Autor ³ Cesar Valadao  ³ Data ³ 21/09/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Camada DLL/SO que encapsula as funcoes dos fabricantes     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AUTOCOM(nID, aParams, cBuffer, nBuffSize)
Local cString, nPos
Local aParm := {}
Local cFunction
Local xRet
Local nInteger1, nInteger2, nInteger3, nInteger4, nInteger5, nInteger6
Local cPChar1, cPChar2, cPChar3, cPChar4, cPChar5
Local cPChar6, cPChar7, cPChar8,cPChar9,cPChar10,cPChar11,cPChar12
Local nHandle
Local lLinux := .F.

EXPORT FUNCTION AS ExecInClientDLL(nFuncID AS INTEGER, aParams AS PCHAR, cBuf AS PCHAR, nTam AS INTEGER) RETURNING INTEGER

//If File("msglog.log")
//	WRITELOG(DToC(Date())+" "+Time()+" -> ["+Substr(aParams,1,At(Chr(2),aParams))+"]"+Chr(13)+Chr(10))
//EndIf

If nId == 999
	// <TecnologiaDLL>.<Equip.Homologados>.<VersãoProtheus>.<VersãoDLL>
	cBuffer := "3.4.1.5"
	//	If File("msglog.log")
	//		WRITELOG(DToC(Date())+" "+Time()+" <- ["+cBuffer+"]"+Chr(13)+Chr(10))
	//	EndIf
	Return 1
ElseIf nId == 997
	cBuffer := "11"
	Return 1
EndIf

cString := aParams

While .T.
	// O Chr(1) é o separador de campos
	nPos := At(Chr(1), cString)
	If nPos == 0
		// O Chr(2) é o marcador do final do aParams, o resto é somente buffer		
		If At(Chr(2), cString) == 1					// Foi enviado o ultimo parametro vazio
			AAdd(aParm, "")
		Else
			AAdd(aParm, Substr(cString,1,At(Chr(2),cString)-1))
		EndIf
		Exit
	EndIf
	If nPos == 1									// Foi enviado um parametro vazio
		AAdd(aParm, "")
	Else
		AAdd(aParm, Substr(cString,1,nPos-1))
	EndIf
	cString := Substr(cString,nPos+1)
End

cFunction := Upper(AllTrim(aParm[1]))

If cFunction == Upper("ConfiguraIntSiTefInterativo")
	xRet := SIT_CONF( aParm[2], aParm[3], aParm[4], Val(aParm[5]) )
	cBuffer := AllTrim(Str(xRet))
		
ElseIf cFunction == Upper("IniciaFuncaoSiTefInterativo")
	xRet := SIT_INICIA( Val(aParm[2]), aParm[3], aParm[4], aParm[5], aParm[6], aParm[7], aParm[8] )
	cBuffer := AllTrim(Str(xRet))
		
ElseIf cFunction == Upper("ContinuaFuncaoSiTefInterativo")
	nInteger1 := Val(aParm[2])				//Proximo comando a ser executado
	nInteger2 := Val(aParm[3])				//Tipo de Campo para tratamento (Vide Tabela no Manual)
	nInteger3 := Val(aParm[4])				//Tamanho Mínimo
	nInteger4 := Val(aParm[5])				//Tamanho Máximo
	cPChar1   := AllTrim(aParm[6])			//Conteudo para o buffer
	nInteger5 := Len(cPChar1) 				//Tamanho do Buffer				
	nInteger6 := Val(aParm[8])				//Indica o comando para continuacao da navegacao dentro da rotina

	SETBUFFSIZE(cPChar1,20000)

	xRet := SIT_CONTIN( nInteger1, nInteger2, nInteger3, nInteger4, cPChar1, nInteger5, nInteger6 )
	cBuffer :=  AllTrim(Str(xRet))+Chr(1)+;
				AllTrim(Str(nInteger1))+Chr(1)+;
				AllTrim(Str(nInteger2))+Chr(1)+;
				AllTrim(Str(nInteger3))+Chr(1)+;
				AllTrim(Str(nInteger4))+Chr(1)+;
				cPChar1

ElseIf cFunction == Upper("FinalizaTransacaoSiTefInterativo")
	cPChar1 := aParm[3]
	cPChar2 := aParm[4]
	cPChar3 := aParm[5]
	SIT_FINAL( Val(aParm[2]) , cPChar1, cPChar2, cPChar3 )
	cBuffer :=  cPChar1+Chr(1)+;
				cPChar2+Chr(1)+;
				cPChar3+Chr(1)
	
ElseIf cFunction == Upper("CorrespondenteBancarioSiTefInterativo")
	xRet := SIT_CORRES( aParm[2], aParm[3], aParm[4], aParm[5], aParm[6] )
	cBuffer := AllTrim(Str(xRet))
		
ElseIf cFunction == Upper("ValidaCampoCodigoEmBarras")
	xRet := SIT_VLDBAR( aParm[2],aParm[3] )
	cBuffer := AllTrim(Str(xRet))
		
ElseIf cFunction == Upper("VerificaPresencaPinPad")
	xRet := SIT_VERPIN( )
	cBuffer := AllTrim(Str(xRet))

ElseIf cFunction == Upper("EscreveMensagemPermanentePinPad")
	xRet := SIT_MSNPIN( aParm[2] )
	cBuffer := AllTrim(Str(xRet))

ElseIf cFunction == Upper("IniciaFuncaoSiTefInterativoConsultaVidalink")
	xRet := SIT_VDLCON( aParm[2],aParm[3],aParm[4],aParm[5],aParm[6],aParm[7] )
	cBuffer := AllTrim(Str(xRet))

ElseIf cFunction == Upper("InformaProdutoVendaVidalink")
	xRet := SIT_VDLPRO( Val(aParm[2]),aParm[3],Val(aParm[4]),aParm[5] )
	cBuffer := AllTrim(Str(xRet))
		
ElseIf cFunction == Upper("IniciaFuncaoSiTefInterativoVendaVidalink")
	xRet := SIT_VDLVEN( aParm[2],Val(aParm[3]),aParm[4],aParm[5],aParm[6],aParm[7] )
	cBuffer := AllTrim(Str(xRet))
		
ElseIf cFunction == Upper("IniciaFuncaoSiTefInterativoCancelamentoVidalink")
	xRet := SIT_VDLCAN( Val(aParm[2]),aParm[3],aParm[4],aParm[5],aParm[6] )
	cBuffer := AllTrim(Str(xRet))
		
ElseIf cFunction == Upper("LeCartaoDireto")
	cPChar1	:= aParm[2]
	cPChar2	:= aParm[3]
	cPChar3	:= aParm[4]
	xRet	:= SIT_LECART( cPChar1 , cPChar2, cPChar3 )
	cBuffer	:= AllTrim(Str(xRet))+Chr(1)+;			//Retorno da funcao 0=OK <>0 erro
			   cPChar1+Chr(1)+;						//Mensagem
			   cPChar2+Chr(1)+;						//Trilha 1 qdo existir
			   cPChar3								//Trilha 2 do cartão quando existir

ElseIf cFunction == Upper("InterrompeLeCartaoDireto")
	xRet := SIT_CANCLE()
	cBuffer := AllTrim(Str(xRet))

ElseIf cFunction == Upper("LeSenhaDireto")
	xRet := SIT_LESENH( aParm[2], aParm[3] )
	cBuffer := AllTrim(Str(xRet))
		
ElseIf cFunction == Upper("LeSimNaoPinPad")
	xRet := SIT_LSNPIN( aParm[2] )
	cBuffer := AllTrim(Str(xRet))

ElseIf cFunction == Upper("ObtemQuantidadeTransacoesPendentes")
	xRet := SIT_OBTQTR(aParm[2], aParm[3])
	cBuffer := AllTrim(Str(xRet))

ElseIf cFunction == Upper("Bematech_FI_AbrePortaSerial")
	xRet := BEMA_ABRSE()
	cBuffer := AllTrim(Str(xRet))
		
ElseIf cFunction == Upper("Bematech_FI_FechaPortaSerial")
	xRet := BEMA_FCHSE()
	cBuffer := AllTrim(Str(xRet))

ElseIf cFunction == Upper("Bematech_FI_LeituraX")
	xRet := BEMA_LEITX()
	cBuffer := AllTrim(Str(xRet))
		
ElseIf cFunction == Upper("Bematech_FI_RetornoImpressora")
	nInteger1 := 0
	nInteger2 := 0
	nInteger3 := 0
	xRet := BEMA_RETIM(nInteger1, nInteger2, nInteger3)
	cBuffer := AllTrim(Str(xRet))+Chr(1)+StrZero(nInteger1,2)+StrZero(nInteger2,2)+StrZero(nInteger3,2)
		
ElseIf cFunction == Upper("Bematech_FI_NumeroCupom")
	cPChar1 := Space(6)
	xRet := BEMA_PEGCU( cPChar1 )
	cBuffer := AllTrim(Str(xRet))+Chr(1)+cPChar1

#IFNDEF LINUX
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Este trecho somente eh utilizado para a plataforma WINDOWS. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ElseIf cFunction == Upper("Sweda_FI_AbrePortaSerial")
	cPChar1   := Val(aParm[2])
	xRet := SWED_ECFOP(cPChar1, 2, 1, 1)
	If ValType(xRet) == "N" 
		cBuffer := Str(xRet)
	Else 
		cBuffer := "1"
	EndIf                

ElseIf cFunction == Upper("Sweda_FI_FechaPortaSerial")
	xRet := SWED_CLOSE()
	cBuffer := AllTrim(Str(xRet))

ElseIf cFunction == Upper("Sweda_FI_EnviaComando")
	cPChar1   := aParm[2]			
	cPChar2   := aParm[3]			//Conteudo para o buffer
	xRet := SWED_WRITE( cPChar1 )
	xRet := SWED_READ( cPChar2, Len(cPChar2) )
	cBuffer :=  AllTrim(Str(xRet))+Chr(1)+AllTrim(cPChar2)

ElseIf cFunction == Upper("ProcessTransaction")
	cPChar1   := aParm[2]
	cPChar2   := aParm[3]
	cPChar3   := aParm[4]
	cPChar4   := aParm[5]
	cPChar5   := aParm[6]
	cPChar6   := aParm[7]
	cPChar7   := aParm[8]
	cPChar8   := aParm[9]
	cPChar9   := aParm[10]
	cPChar10  := aParm[11]
	cPChar11  := aParm[12]
	cPChar12   := Space(2000)
	xRet := BANORTE(cPChar1, cPChar2, cPChar3, cPChar4, cPChar5, cPChar6, cPChar7, cPChar8, cPChar9, cPChar10, cPChar11, cPChar12)
	cBuffer := AllTrim(Str(xRet))+chr(1)+cPChar12

#ENDIF
Else
	cBuffer := "Function not found in AUTOCOM.DLL/SO -> "+cFunction
	MsgStop(cBuffer, "Library AUTOCOM")
EndIf

//If File("msglog.log")
//	WRITELOG(DToC(Date())+" "+Time()+" <- ["+cBuffer+"]"+Chr(13)+Chr(10))
//EndIf

Return 1
