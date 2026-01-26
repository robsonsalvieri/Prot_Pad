#INCLUDE "PROTHEUS.CH" 
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"  
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWEVENTVIEWCONSTS.CH"

#DEFINE FT_NAME	1 
#DEFINE FT_DATE	3
#DEFINE FT_TIME	4

Static __cDirIn		:= ""
Static __cDirLido	:= ""
Static __cDirOut	:= ""
Static __lGeraLog	:= .F.
Static lSOWin		:= !isSrvUnix() //Se é SO Windows
Static lCkoRepro  := CKO->(FieldPos("CKO_DOC")) > 0 .And. CKO->(FieldPos("CKO_SERIE")) > 0 .And. CKO->(FieldPos("CKO_NOMFOR")) > 0 .And. !Empty(SDS->(IndexKey(4)))
//------------------------------------------------------------------
/*/{Protheus.doc} colReadDocs
Raliza o controle de leitura dos documentos.

@author  Rafael Iaquinto
@since   30/01/2014
@version 12
/*/
//------------------------------------------------------------------
function colReadDocs()

local cBarra		:= If(!lSOWin,"/","\")
local cProcesso	:= "colabautoread"
local cLockFile 	:= ""
local cDirIn		:= Alltrim( GetNewPar("MV_NGINN","\Neogrid\bin\IN") )
local cDirOut		:= Alltrim( GetNewPar("MV_NGOUT","\Neogrid\bin\OUT") )
local cDirLido	:= Alltrim( GetNewPar("MV_NGLIDOS","\Neogrid\bin\LIDOS") )

local nX			:= 0
local nHdlJob		:= 0

__lGeraLog	:= getSrvProfString( "COLAUTOREAD_DEBUG" , "0" ) == "1" .And. getSrvProfString( "FWLOGMSG_DEBUG" , "0" ) == "1" 

// Valida parametro MV_NGINN e MV_NGLIDOS
if Empty( Alltrim( cDirIn ) ) .Or. !ExistDir(cDirIn) 
	
	ColReadMsg( 'Parametro [ MV_NGINN ] nao configurado ou diretorio configurado nao existe.' )

elseif Empty( Alltrim( cDirLido ) ) .Or. !ExistDir( cDirLido )
	
	ColReadMsg( 'Parametro [ MV_NGLIDOS ] nao configurado ou diretorio configurado nao existe.'  )
	
else
	
	//-------------------------------------------
	// Inicializacao das variaveis
	//-------------------------------------------
	
	//Verifica os diretórios
	if SubStr( cDirIn, Len(cDirIn) )<> cBarra
		__cDirIn := cDirIn+cBarra
	Else
		__cDirIn := cDirIn
	endif
	if SubStr( cDirLido, Len(cDirLido) )<> cBarra
		__cDirLido := cDirLido+cBarra
	else
		__cDirLido := cDirLido
	endif
	
	if SubStr( cDirOut, Len(cDirOut) )<> cBarra
		__cDirOut := cDirOut+cBarra
	else
		__cDirOut := cDirOut
	endif
	
	cProcName	:= cProcesso
	cLockFile 	:= ""	
	
	//-------------------------------------------
	// Montagem do arquivo do job principal
	//-------------------------------------------
	cLockFile := lower( cProcName ) + ".lck"
	
	//---------------------------------------------
	// Verifica se a thread principal esta rodando
	//---------------------------------------------
	for nX := 1 To 2
	
		nHdlJob := JobSetRunning( cLockFile, .T. )

		If ( nHdlJob > 0 )
	
			ColReadMsg( "Iniciando o processo principal de " + cProcName ) 	
			colReadControl()
			
			//-------------------------------------------
			// Libera o Lock
			//-------------------------------------------

			JobSetRunning( cLockFile, .F., nHdlJob )		
			ColReadMsg( "Finalizando o processo principal de " + cProcName ) 
			
			Exit
				
		Else
			
			//-------------------------------------------
			// Thread principal em Lock
			//-------------------------------------------

			ColReadMsg( "Falha na inicialização do processo de " + cProcName + ", outro processo já iniciado." ) 			
			sleep( 3000 )
			
		Endif
	
	next
	
endif

return

//-------------------------------------------------------------------
/*/{Protheus.doc} colReadControl
Funcao que controla a execucao dos jobs dos processos do Schedule do 
TOTVS Colaboração.
  

@author  Rafael Iaquinto
@since   24/07/2014
@version 11.8
/*/
//-------------------------------------------------------------------
static function colReadControl( )

local aDocs		:= {}
Local aCodEdi	:= {"ALL"}
local nX		:= 0
local ny		:= 0
local cMsgProc	:= ""
Local lImpXML	:= SuperGetMv("MV_IMPXML",.F.,.F.) .And. CKO->(FieldPos("CKO_ARQXML")) > 0 .And. !Empty(CKO->(IndexKey(5)))

Private lCpoStran 	:= CKO->(FieldPos("CKO_STRAN")) > 0
Private lCpoChvDoc 	:= CKO->(FieldPos("CKO_CHVDOC")) > 0

ColReadMsg( "JOB Iniciado" )
for nX := 1 to len(aCodEdi)
	
	aDocs	:= {}
	cMsgProc := ""
	// Executa o filtro no diretório
	aDocs := executeFilter( aCodEdi[nX] )
		
	if len( aDocs ) > 0 
		
		ColReadMsg( "Iniciando processamento dos arquivos - " + aCodEdi[nX] )
		for ny := 1 to len( aDocs )
			ColReadMsg( "Adicionando arquivo ["+ aDocs[ny][1] +"] a base de dados( Contagem: "+allTrim(str(ny))+" )" )
			
			if processaarquivo( aDocs[nY] ,@cMsgProc )
				ColReadMsg( "Arquivo ["+ aDocs[ny][1] +"] adicionado com sucesso." )
				
				ColReadMsg( "Movendo arquivo ["+ aDocs[ny][1] +"] para diretorio de arquivos lidos." )
				
				if (movearquivo(Iif(lImpXML,Iif(lSOWin,aDocs[nY][6],aDocs[nY][7]),aDocs[nY][FT_NAME]) , @cMsgProc))
					ColReadMsg( "Arquivo ["+ Iif(lImpXML,Iif(lSOWin,aDocs[nY][6],aDocs[nY][7]),aDocs[nY][FT_NAME]) +"] movido!"  )
				else
					ColReadMsg( "Arquivo ["+ Iif(lImpXML,Iif(lSOWin,aDocs[nY][6],aDocs[nY][7]),aDocs[nY][FT_NAME]) +"] não foi movido! " + cMsgProc )
				endif
			else
				ColReadMsg( "Arquivo ["+ aDocs[ny][1] +"] não foi adicionado - "+ cMsgProc  )
			endIf
		next ny
		
		ColReadMsg( "Finalizado processamento dos arquivos - "+ aCodEdi[nX]  )
	else
		ColReadMsg( "Sem documentos a serem processados!"  )	
	endif
	
next nx	
	
ColReadMsg( "JOB Finalizado" )

return

//-----------------------------------------------------------------------
/*/{Protheus.doc} executeFilter
Funcao Converte arquivo XML em String

@author  Rafael Iaquinto
@since   24.07.2014
@version 11.9

@param	cCodEdi	Codigo iniical do documento da neogrid, se for passado
					'ALL' será considerado todos e o fitro será *.xml.

@return aDocs 
/*/
//-----------------------------------------------------------------------
static function executeFilter( cCodEdi )

local cFiltro	:= ""
local aDocs		:= {}

If cCodEdi == "ALL"
	cFiltro := "*.xml"
Endif

aDocs := RetFileDir(__cDirIn, cFiltro, cCodEdi)

aSort(aDocs,,,{|x,y| DToC(x[3])+x[4] < DToC(y[3])+y[4]})

return aDocs
//-------------------------------------------------------------------
/*/{Protheus.doc} processaarquivo
Processa o arquivo passado, gravando na tabela CKO 

TOTVS Colaboração.

@param	 aDadosArq		Dados do arquivo retornado da função Directory.  
@param	 cMsg			Mensagem para retornar o erro caso ocorra algum.  

@return lOk			.T. se conseguir processar o arquivo.

@author  Rafael Iaquinto
@since   24/07/2014
@version 11.8
/*/
//-------------------------------------------------------------------
static function processaarquivo( aDadosArq, cMsg )

local lOk	:= .T.
local lNewReg	:= .T.
Local lGrvCKO	:= .T.
Local cEDI		:= ""
local nOrder1	:= 0
local nRecno1	:= 0
Local aCKODados	:= {}
Local aCodEdi	:= &(GetNewPar("MV_COLEDI",'{}'))
Local aExcEdi   := &(GetNewPar("MV_EXCEDI",'{}'))
Local aEdiCOM	:= {"109","214","273","319"}
Local cXMl		:= ""
Local cNameArq	:= ""
Local lImpXML	:= SuperGetMv("MV_IMPXML",.F.,.F.) .And. CKO->(FieldPos("CKO_ARQXML")) > 0 .And. !Empty(CKO->(IndexKey(5)))
Local lEdiCOM	:= .F.
Local cErro 	:= ""
Local cErro1 	:= ""
Local cAviso 	:= ""
Local cAviso1 	:= "" 
Local cNumRet 	:= ""
Local cSerRet 	:= ""
Local cNumEnv 	:= ""
Local cSerEnv 	:= ""
local lColNtCan := FindFunction("ColNTCan")

Local oComTransmite := ComTransmite():New()

Private oXmlRet 
Private oXmlEnv

if convfile( @cXMl, aDadosArq[FT_NAME],__cDirIn, @cMsg )
	nOrder1	:= CKO->( indexOrd() )
	nRecno1	:= CKO->( recno() )

	//Utilizando o Importador XML é realizada a conversão da nomenclatura do nome
	//do arquivo para que seja interpretado igual ao Totvs Colaboração.	
	If lImpXML
		aDadosArq := COLIMPXML(cXMl,@aDadosArq) 
	Endif

	cNameArq := PadR(Lower(aDadosArq[1]),Len(CKO->CKO_ARQUIV)) 
	
	If SubStr(cNameArq,Len(cNameArq)-3,4) <> ".xml"
		cNameArq := PadR(lower(SubStr(aDadosArq[1],1,26)+".xml"),LEN(CKO->CKO_ARQUIV))
	Endif
		
	CKO->(dbSetorder(1))
	if CKO->(dbseek(cNameArq))
		lNewReg	:= .F.
		 if CKO->CKO_FLAG<>'1'	
			lGrvCKO := .T.
		 elseif CKO->CKO_FLAG == '1' .And. lColNtCan .and. ColNTCan(cXMl,cNameArq,.t.)
			lGrvCKO := .F.
		 endif
	Endif

	//Verifica se o documento cancelado esta na CKO e atualiza o registro cancelado.
	if !lImpXML .And. lNewReg .And. lColNtCan
		if ColNTCan(cXMl,cNameArq,.f.)
			lGrvCKO := .F.
		endif
	elseif lImpXML .And. lNewReg .And. lColNtCan
		/* aCKODados
		[1] - Chave Doc
		[2] - Numero Doc
		[3] - Serie Doc
		[4] - Nome Fornecedor
		[5] - Empresa
		[6] - Filial
		[7] - Numero Doc NFS
		*/
		aCKODados := oComTransmite:GetDadosXML(cXML)
		if lCpoChvDoc .And. ColGetCKO(cXML,aCKODados[1])
			if ColNTCan(cXMl,cNameArq,.f.)
				lGrvCKO := .F.
			endif
		endif
	endif

	If lImpXML .And. Empty(aCodEdi)
		aCodEdi := {"109","214","273","005","252","203","319"}
	Endif
	// Verifica se tipo de XML está configurado para ser importado
	If !Empty(aCodEdi)
		If aScan(aCodEdi,{|x| AllTrim(x) == AllTrim(SubStr(cNameArq,1,3))}) == 0
			lGrvCKO := .F.
		Endif
	Endif
	// Verifica se tipo de XML não está configurado como excessão de importação
	If !Empty(aExcEdi)
		If aScan(aExcEdi,{|x| AllTrim(x) == AllTrim(SubStr(cNameArq,1,3))}) > 0
			lGrvCKO := .F.
			lOk     := .F.
			cMsg    := "Tipo de arquivo configurado para não ser processado (MV_EXCEDI)."
		EndIf
	EndIf

	if !EMPTY(cXMl) .AND. !EMPTY(CKO->CKO_XMLENV) .AND. lGrvCKO
		If AllTrim(SubStr(cNameArq,1,3)) == "203" // Apenas para NFSE
			oXmlRet := xmlParser( cXMl,"_",@cErro,@cAviso )
			cNumRet := IIF(TYPE("oXmlRet:_PROCNFSE:_ERP:_RPS:_RPS:_IDENTIFICACAO:_NUMERORPS") <> "U",oXmlRet:_PROCNFSE:_ERP:_RPS:_RPS:_IDENTIFICACAO:_NUMERORPS:TEXT,"")
			cSerRet := IIF(TYPE("oXmlRet:_PROCNFSE:_ERP:_RPS:_RPS:_IDENTIFICACAO:_SERIERPS") <> "U",oXmlRet:_PROCNFSE:_ERP:_RPS:_RPS:_IDENTIFICACAO:_SERIERPS:TEXT,"")
			oXmlEnv := xmlParser( CKO->CKO_XMLENV,"_",@cErro1,@cAviso1 )
			cNumEnv := IIF(TYPE("oXmlEnv:_RPS:_IDENTIFICACAO:_NUMERORPS") <> "U",oXmlEnv:_RPS:_IDENTIFICACAO:_NUMERORPS:TEXT,"")
			cSerEnv := IIF(TYPE("oXmlEnv:_RPS:_IDENTIFICACAO:_SERIERPS") <> "U",oXmlEnv:_RPS:_IDENTIFICACAO:_SERIERPS:TEXT,"")
			lGrvCKO := IIF(!EMPTY(cNumRet) .AND. !EMPTY(cNumRet) .AND. !EMPTY(cNumRet) .AND. !EMPTY(cNumRet) .AND. cNumRet == cNumEnv .AND.cSerRet == cSerEnv,.T.,.F.)
			IF !lGrvCKO 
				lOk     := .F.
				cMsg    := "Número e Série de RPS de envio diferente dos dados de retorno."
				if ( getSrvProfString( "COLABCONTROL_LOG" , "0" ) == "1" )
					LJGRVLOG("LOG_TOTVS","XML RETORNO", cXMl,,.T.)
					LJGRVLOG("LOG_TOTVS","XML ENVIO", CKO->CKO_XMLENV,,.T.)
					LJGRVLOG("LOG_TOTVS","Nome do Arquivo", cNameArq,,.T.)
					LJGRVLOG("LOG_TOTVS","CKO_IDERP", CKO->CKO_IDERP,,.T.)
				EndIF
			EndIF
			freeObj(oXmlEnv)
			freeObj(oXmlRet)
		EndIf
	EndIF

	If lGrvCKO
		cEDI := SubStr(cNameArq,1,3) 

		Begin Transaction

			reclock("CKO",lNewReg)
			CKO->CKO_ARQUIV	:= cNameArq
			CKO->CKO_CODEDI	:= cEDI
			CKO->CKO_XMLRET	:= cXML
			CKO->CKO_DT_RET	:= aDadosArq[FT_DATE] //Data do arquivo
			CKO->CKO_HR_RET	:= aDadosArq[FT_TIME] //Hora do arquivo
			CKO->CKO_DT_IMP	:= Date() //Data da importacao pelo Schedule
			CKO->CKO_HR_IMP	:= Time() //Hora da importacao pelo Schedule
			CKO->CKO_STATUS	:= ColCKOStatus()[2][1]
			CKO->CKO_DESSTA	:= ColCKOStatus()[2][2]
			CKO->CKO_FLAG	:= "0"
			
			If lImpXML //Gravação do nome do arquivo original pelo Importador XML
				CKO->CKO_ARQXML := aDadosArq[6] 
			Endif

			lEdiCOM := (aScan(aEDICOM,{|x| x == cEDI}) > 0)

			If lEdiCOM
				oComTransmite := ComTransmite():New()

				/* aCKODados
				[1] - Chave Doc
				[2] - Numero Doc
				[3] - Serie Doc
				[4] - Nome Fornecedor
				[5] - Empresa
				[6] - Filial
				[7] - Numero Doc NFS
				*/
				
				aCKODados := oComTransmite:GetDadosXML(cXML)

				If Len(aCKODados) > 0
					If lCkoRepro
						CKO->CKO_DOC	:= aCKODados[2]
						CKO->CKO_SERIE	:= aCKODados[3]
						CKO->CKO_NOMFOR	:= aCKODados[4]
					Endif

					If lCpoChvDoc
						CKO->CKO_CHVDOC	:= aCKODados[1]
					Endif

					If lCpoStran .And. cEDI == "319" .And. lImpXML 
						CKO->CKO_STRAN = '1'
					Endif

					CKO->CKO_EMPPRO	:= aCKODados[5]
					CKO->CKO_FILPRO	:= aCKODados[6]

					If oComTransmite:lCpoNewDoc
						CKO->CKO_NFELET  := aCKODados[7]
					Endif
				Endif
			Endif

			CKO->( msUnlock() )
						
		End Transaction
	Endif	
	
	CKQ->( dbSetOrder( nOrder1 ) )
	CKQ->( dbGoTo( nRecno1 ) )
	
	MsUnLockAll()
else
	lOk := .F.
endif

FreeObj(oComTransmite)
FwFreeArray(aCKODados)

return ( lOk )

//-------------------------------------------------------------------
/*/{Protheus.doc} COLIMPXML
Função para conversão do nome do arquivo XML para interpretar igual
ao Totvs Colaboração  

@param	cXML		Conteudo do XML
@param	aDadosArq	Dados do arquivo XML

@author  Rodrigo M Pontes
@since   24/04/19
@version 12.1.23
/*/
//-------------------------------------------------------------------

Static Function COLIMPXML(cXml,aDadosArq)

Local cXMLEncod	:= ""
Local cError	:= ""
Local cWarning	:= ""
Local cCodEdi	:= ""
Local aArea		:= GetArea()
Local oFullXML	:= Nil
Local oXml252   := Nil
Local cXML252   := Nil
Local nTag      := 0
Local aEdiColab	:= {"203_"}
Local nEdiColab	:= 0
Local oObjImpTra:= Nil

nEdiColab := aScan(aEdiColab,{|x| AllTrim(SubStr(aDadosArq[1],1,4)) == AllTrim(x)})

If nEdiColab == 0
	oObjImpTra := ComTransmite():New()
	oObjImpTra:GetObjXML(cXml,@oFullXML,@cError,@cWarning)

	//Verifica se estar importando uma NFE ou CTE
	If ValType(oFullXML) == "O"
		Do Case
			Case ValType(XmlChildEx(oFullXML,"_NFE")) == "O" //-- Nota normal, devolucao, beneficiamento, bonificacao
				cCodEdi := "109_NFE_"
			Case ValType(XmlChildEx(oFullXML,"_NFEPROC")) == "O" //-- Nota normal, devolucao, beneficiamento, bonificacao
				cCodEdi := "109_NFE_"
			Case ValType(XmlChildEx(oFullXML,"_CTE")) == "O" //-- Nota de transporte
				cCodEdi := "214_CTE_"		
			Case ValType(XmlChildEx(oFullXML,"_CTEPROC")) == "O" //-- Nota de transporte
				cCodEdi := "214_CTE_"
			Case ValType(XmlChildEx(oFullXML,"_CTEOSPROC")) == "O" //-- Nota de transporte CTEOS
				cCodEdi := "273_CTE_
			Case ValType(XmlChildEx(oFullXML,"_CTESIMPPROC")) == "O" //-- Nota de transporte Simplificado
				cCodEdi := "214_CTE_"
			Case !Empty(AScan(ClassDataArr(oFullXML), {|Att| AllTrim(Upper(Att[1])) == "_BUSINESSCONTENT"})) .And. ValType(XmlChildEx(oFullXML:_BUSINESSCONTENT,"_CUSTOMERGOVINFO")) == "O" .And. ValType(XmlChildEx(oFullXML:_BUSINESSCONTENT,"_ORDERID")) == "O" //-- Pedido de Vendas
				cCodEdi := "005_PVD_"
			Case !Empty(AScan(ClassDataArr(oFullXML), {|Att| AllTrim(Upper(Att[1])) == "_BUSINESSCONTENT"})) .And. ValType(XmlChildEx(oFullXML:_BUSINESSCONTENT,"_FUNCMSGPROG")) == "O" //-- Programacao de Entrega
				cCodEdi := "252_PET_"
			Case !Empty(AScan(ClassDataArr(oFullXML), {|Att| AllTrim(Upper(Att[1])) == "_BUSINESSEVENT"}))
				cXml252 := cXMLEncod
				nTag := At('</BusinessEvent>',cXml252)
				If nTag <> 0
					cXml252 := SubStr(cXml252,nTag+16)
				EndIf
				oXML := XMLParser( cXml252, "_", @cError, @cWarning )
				If oXML <> Nil .And. ;
				Empty(cError) .And. ;
				Empty(cWarning) .And. ;
				!Empty(AScan(ClassDataArr(oXML), {|Att| AllTrim(Upper(Att[1])) == "_BUSINESSCONTENT"})) .And. ;
				ValType(XmlChildEx(oXML:_BUSINESSCONTENT,"_FUNCMSGPROG")) == "O" //-- Programacao de Entrega
					cCodEdi := "252_PET_"
				EndIf
			Case ValType(XmlChildEx(oFullXML,"_PROCTRANSMITENFSE")) == "O" //-- Nota de Serviço
                cCodEdi := "319_NFS_"
		EndCase
	Endif

	//Busca pelo arquivo original, verificando se ja foi importado
	CKO->(DbSetOrder(5))
	If CKO->(dbseek(PadR(lower(aDadosArq[1]),LEN(CKO->CKO_ARQXML)))) .Or. CKO->(dbseek(PadR(upper(aDadosArq[1]),LEN(CKO->CKO_ARQXML)))) .Or. ;
		CKO->(dbseek(PadR(aDadosArq[1],LEN(CKO->CKO_ARQXML))))
		aAdd(aDadosArq,PadR(lower(aDadosArq[1]),LEN(CKO->CKO_ARQXML)))
		aAdd(aDadosArq,PadR((aDadosArq[1]),LEN(CKO->CKO_ARQXML)))	
		aDadosArq[1] := CKO->CKO_ARQUIV
	Else
		aAdd(aDadosArq,PadR(lower(aDadosArq[1]),LEN(CKO->CKO_ARQXML)))
		aAdd(aDadosArq,PadR((aDadosArq[1]),LEN(CKO->CKO_ARQXML)))
		If SubStr(cCodEdi,1,3) $ "109|214|273|319"	
			aDadosArq[1] := oObjImpTra:GetNumSeq(cCodEdi)
		Else
			aDadosArq[1] := COLNUMSEQ(cCodEdi)
		Endif
	Endif
Else
	aAdd(aDadosArq,PadR(lower(aDadosArq[1]),LEN(CKO->CKO_ARQXML)))
	aAdd(aDadosArq,PadR((aDadosArq[1]),LEN(CKO->CKO_ARQXML)))
Endif

RestArea(aArea)

FreeObj(oFullXML)
FreeObj(oXML252)
FreeObj(oObjImpTra)
FwFreeArray(aEdiColab)
FwFreeArray(aArea)

DelClassIntF()

Return aDadosArq

//-------------------------------------------------------------------
/*/{Protheus.doc} COLNUMSEQ
Função para gerar nomenclatura do arquivo origem para nomenclatura
que seja interpretada igual ao Totvs Colaboração. 

@param	cCodEdi		Identificador do XML

@author  Rodrigo M Pontes
@since   24/04/19
@version 12.1.23
/*/
//-------------------------------------------------------------------

Static Function COLNUMSEQ(cCodEdi)

Local aArea		:= GetArea()
Local cAliasImp	:= GetNextAlias()
Local cNumSeq	:= "000000000000000001"
Local cArq		:= cCodEdi + cNumSeq + ".xml"
Local cQry		:= ""
Local cQryStat	:= ""
Local cEdiQry	:= SubStr(cCodEdi,1,3)
Local oNextDoc	:= FWPreparedStatement():New()

cQry := " SELECT MAX(CKO_ARQUIV) AS ULT"
cQry += " FROM " + RetSqlName("CKO")
cQry += " WHERE CKO_CODEDI = ?"
cQry += " AND CKO_ARQXML <> ?"
cQry += " AND D_E_L_E_T_ = ?" 

oNextDoc:SetQuery(cQry)

oNextDoc:SetString(1,cEdiQry)
oNextDoc:SetString(2,Space(TamSX3("CKO_ARQXML")[1]))
oNextDoc:SetString(3,Space(1))

cQryStat := oNextDoc:GetFixQuery()
MpSysOpenQuery(cQryStat,cAliasImp)

If (cAliasImp)->(!EOF()) .And. !Empty((cAliasImp)->ULT)
	cNumSeq := StrTran(Upper((cAliasImp)->ULT),".XML","")
	cNumSeq := StrTran(cNumSeq,cCodEdi,"")
	cNumSeq := Soma1(cNumSeq)
Endif

cArq := cCodEdi + cNumSeq + ".xml"

(cAliasImp)->(DbCloseArea())

RestArea(aArea)
FreeObj(oNextDoc)

Return cArq

//-----------------------------------------------------------------------
/*/{Protheus.doc} convfile
Funcao Converte arquivo XML em String

@author  Rafael Iaquinto
@since   24.07.2014
@version 11.9
/*/
//-----------------------------------------------------------------------
Static Function convfile(cXml,cFile,cDir,cMsg)

Local lRet	:= .T.
Local cLine	:= ""

PARAMTYPE 0 VAR cXml  AS CHARACTER
PARAMTYPE 1 VAR cDir  AS CHARACTER
PARAMTYPE 2 VAR cFile AS CHARACTER
PARAMTYPE 3 VAR cMsg  AS CHARACTER

If FT_FUse( cDir + cFile ) >= 0 

	cLine	:= ""
	cXml	:= ""
		
	While !FT_FEof() 
		cLine := FT_FReadLn()
		If ( Len(cLine) < 1023 )
			cXml += Alltrim(cLine)
		Else
			cLine := ""
			While .T.
				If ( Len(FT_fReadLn()) < 1023 )
					cLine	+= FT_FReadLn()
					cXml	+= cLine
					Exit
				Else
					cLine += FT_FReadLn()				
					FT_FSkip()
				Endif
			Enddo
		Endif
		FT_FSkip()
	Enddo
	
	//-- Fecha o arquivo aberto
	FT_FUSE()
	
	If "ObsContxCampo" $ cXML
		cXml := StrTran(cXml,"ObsContxCampo","ObsCont xCampo")
	Endif
	 	 
	If "ReferenceURI" $ cXml
		cXml := StrTran(cXml,"ReferenceURI","Reference URI") 
	Endif
				
Else
	
	lRet := .F.
	cMsg := "Nao foi possível ralizar a abertura do arquivo."
	
Endif
	
Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} movearquivo
Move o arquivo passado, para a pasta de arquivos lidos. 

@param	 cNomeArq		Nome do arquivo.  
@param	 cMsg			Mensagem para retornar o erro caso ocorra algum.

@return lOk			.T. se conseguir processar o arquivo.

@author  Rafael Iaquinto
@since   24/07/2014
@version 11.8
/*/
//-------------------------------------------------------------------
static function movearquivo(cNomeArq , cMsg)

local lOk	:= .T.

if ( __CopyFile(__cDirIn+cNomeArq, __cDirLido+cNomeArq,,,lSOWin))
	Ferase( __cDirIn+cNomeArq,,lSOWin)
	
else
	lOk	:= .F.
	cMsg := "Não foi possível mover o arquivo.)	
endif

return lOk

//-------------------------------------------------------------------
/*/{Protheus.doc} ColReadMsg
Funcao que executa conout

@param cMessage		Mensagem que sera apresentada no conout

@author  Rafael Iaquinto
@since   25/07/2014
@version 11.8
/*/
//-------------------------------------------------------------------
function ColReadMsg( cMessage )

if ( __lGeraLog )
	
	FWLogMsg('INFO',, 'COLAUTOREAD', FunName(), '', '01', "[COLABORACAO " + DtoC( date() ) + " - " + time() + " ] " + allTrim(cMessage) + CRLF, 0, 0, {})

endif   

return

//-------------------------------------------------------------------
/*/{Protheus.doc} RetFileDir
Função responsavel por retornar array com os arquivos encontrados no
diretorio.
Obs.: Foi realziado tratamento para linux para pegar maiuscula e 
minusculas

@param		cDiretorio	Diretorio com os arquivos
			cArquivo	Extensão dos arquivos
			cCodEdi		Prefixo ou tipo de arquivo a ser selecionado

@author		Felipe Sales Martinez
@since		10/03/2020
@version	12
@return		Lista de arquvios dentro do diretorio
/*/
//-------------------------------------------------------------------
Static Function RetFileDir(cDiretorio, cArquivo, cCodEdi )
Local aDocs		:= {}
Local aDocsSens	:= {}
Local lArqUp	:= .F.
Local lArqLow	:= .F.

cArquivo := AllTrim(cArquivo)

aDocs := Directory( cDiretorio+cArquivo ,,, lSOWin )

//Tratamento para Linux, case sensitive para a extensão
If !lSOWin .And. cCodEdi == "ALL"
	lArqUp	:= Upper(cArquivo) == cArquivo
	lArqLow	:= Lower(cArquivo) == cArquivo
	If lArqUp .Or. lArqLow
		cArquivo := iif(lArqUp,Lower(cArquivo),Upper(cArquivo))
		aDocsSens := Directory( __cDirIn+cArquivo ,,,lSOWin )
		//Copiando array para outro
		AEval( aDocsSens, {|x| aAdd(aDocs,aClone(x)) })
		//Limpando memoria
		AEval( aDocsSens, {|x| aSize(x,0) })
		aSize(aDocsSens, 0)
		aDocsSens := Nil
	EndIf
EndIf

Return aDocs
