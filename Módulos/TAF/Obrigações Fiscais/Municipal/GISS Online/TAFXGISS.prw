#Include 'Protheus.ch'
#Include "ApWizard.ch"
#Include "TAFXGISS.ch"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FWLIBVERSION.CH"

#Define cObrig "GISS Online"

//--------------------------------------------------------------------------
/*/{Protheus.doc} TAFXGISS

Esta rotina tem como objetivo a geracao do Arquivo GISS Online

@Author francisco.nunes
@Since 01/02/2017
@Version 1.0
/*/
//---------------------------------------------------------------------------
Function TAFXGISS()

Local cNomWiz    as char
Local lEnd       as logical
Local cFunction	 as char
Local nOpc       as numeric

Local cCode		:= "LS006"
Local cUser		:= RetCodUsr()
Local cModule	:= "84"
Local cRoutine  := ProcName()

Private oProcess as object
Private dInicial as date
Private dFinal   as date
Private lCancel  as logical
Private lBrwServ as logical

	cNomWiz		:= cObrig + FWGETCODFILIAL
	lEnd		:= .F.	
	lCancel		:= .F.
	oProcess	:= Nil	
   	cFunction 	:= ProcName()
	nOpc      	:= 2 //View

	//Função para gravar o uso de rotinas e enviar ao LS (License Server)
	Iif(FindFunction('FWLsPutAsyncInfo'),FWLsPutAsyncInfo(cCode,cUser,cModule,cRoutine),)

	//Protect Data / Log de acesso / Central de Obrigacoes
	Iif(FindFunction('FwPDLogUser'),FwPDLogUser(cFunction, nOpc), )

	//Cria objeto de controle do processamento
	oProcess := TAFProgress():New( { |lEnd| ProcGISSON( @lEnd, @oProcess, cNomWiz ) }, STR0001 )
	oProcess:Activate()

	If !lCancel
		If (MSGYESNO( STR0037, STR0006)) //Deseja gerar o relatório de conferência?
			TGISSRelat()
		EndIf
	EndIf

	//Limpando a memória
	DelClassIntf()

Return()

//--------------------------------------------------------------------------
/*/{Protheus.doc} ProcGISSON

Inicia o processamento para geracao da Giss Online


@Param lEnd      -> Verifica se a operacao foi abortada pelo usuario
	   oProcess  -> Objeto da barra de progresso da emissao da GISS Online
	   cNomWiz   -> Nome da Wizard criada para a GISS Online


@Return ( Nil )

@Author francisco.nunes
@Since 01/02/2017
@Version 1.0
/*/
//---------------------------------------------------------------------------


Static Function ProcGISSON( lEnd as logical, oProcess as object, cNomWiz as char)

Local dIni        as date
Local dFim        as date
Local cErrorGISS  as char
Local cErrorTrd   as char
Local cYearGiss	  as char
Local nX          as numeric
Local nPos        as numeric
Local nProgress1  as numeric
Local nCont       as numeric
Local aWizard     as array
Local lProc       as logical
Local lArq        as logical
Local cTBulk	  as char
Local cAliasTT	  as char
Local lCanBulk 	  as logical
Local oTT		  as object
Local oBulk		  as object
Local aIndLay	  as array

Private lBrwNat  as logical
Private lBrwIte  as logical
Private lBrwPar  as logical
	
	cErrorGISS  := ""
	cErrorTrd   := ""
	cYearGiss	:= ""
	lBrwNat     := .F.
	lBrwIte     := .F.
	lBrwPar     := .F.
	
	nX          := 0
	nPos        := 0
	nProgress1  := 0 
	
	aWizard     := {}
	
	lProc       := .T.
	nCont       := 1
	
	//Carrega informações na wizard
	If !xFunLoadProf( cNomWiz , @aWizard )
		Return( Nil )
	EndIf

	cYearGiss := Iif(ValType(aWizard[1][4])=="N",LTRIM(STR(aWizard[1][4])),AllTrim(aWizard[1][4]))

	dInicial 	:= CTOD("01/"+Substr(aWizard[1][3],1,2)+"/"+cYearGiss)
	dFinal 	:= LastDay(dInicial)

	lCanBulk := .F.
	oTT 	 := Nil
	oBulk 	 := Nil
	aIndLay  := {}
	cAliasTT := ''
	cTBulk 	 := CriaTrab(,.F.)
	lArq     := .T.

	If TAFConsServ(dInicial, dFinal)
		If (MSGYESNO( STR0061, STR0006 )) //Para o período selecionado existem documentos fiscais com código de serviço não informado. Esses documentos não serão considerados. Deseja informá-los?     Atenção!
			If !TAFCadAdic(dIni, dFim)
			 	lProc := MSGYESNO( STR0062, STR0006 ) //"Deseja gerar a obrigação sem finalizar o cadastro de códigos de serviço?"	   Atenção!	 	 
			EndIf
		EndIF	
	EndIf
				
	If lProc
	
		TAFConout( "Tempo de Inicio " + Time() ,1,.f.,"GISS") 
	
		//Alimentando a variável de controle da barra de status do processamento
		nProgress1 := 2
		oProcess:Set1Progress( nProgress1 )
	
		//Iniciando o Processamento
		oProcess:Inc1Progress( STR0002 ) //"Preparando o Ambiente..."
		oProcess:Inc1Progress( STR0003 ) //"Executando o Processamento..."		
		
		//************************************************************************
		//Geração GISS Online - Aqui vão a chamada das funções da geração dos registros
		//************************************************************************
		//Cria estrutura temporaria
		TAFTTGISS( @lCanBulk, cTBulk, @oBulk, @oTT, @cAliasTT )

		//Insere registros
		TAFGISSNF( aWizard, @aIndLay, lCanBulk, cTBulk, @oBulk, @oTT, cAliasTT )
		//Atualizando a barra de processamento
		oProcess:Inc1Progress( STR0011 )	//"Informações processadas"
		oProcess:Inc2Progress( STR0012 )	//"Consolidando as informações e gerando arquivo..."

		//Efetiva Bulk e Cria arquivo(s)
		lArq := TAFENCGISS( aWizard, @aIndLay, lCanBulk, cTBulk, @oBulk, @oTT )
		if lArq
			oProcess:Inc2Progress( STR0013 ) 	//"Arquivo gerado com sucesso."
			MsgInfo(STR0013) 				 	//"Arquivo gerado com sucesso."
		else
			oProcess:Inc2Progress( STR0014 ) 	//"Falha na geração do arquivo.
			MsgInfo(STR0014) 					//"Falha na geração do arquivo.
		endif
		TAFConout( "Tempo Final " + Time() ,1,.f.,"GISS") 
		//************************************************************************
		//********* FIM da chamada das funções da geração dos registros **********
		//************************************************************************		
	Else
		oProcess:Inc1Progress( STR0004 )	//"Processamento cancelado"
		oProcess:Inc2Progress( STR0005 )	//"Clique em Finalizar"
		oProcess:nCancel = 1
	EndIf
	
	//Tratamento para quando o processamento tem problemas
	If oProcess:nCancel == 1 .or. !Empty( cErrorGISS ) .or. !Empty( cErrorTrd )
	
		//Cancelado o processamento
		If oProcess:nCancel == 1
	
			Aviso( STR0006, STR0007, { STR0008 } ) 	//"Atenção" "A geração do arquivo foi cancelada com sucesso!" "Sair"
			lCancel := .T.
	
		//Erro na inicialização das threads
		ElseIf !Empty( cErrorTrd )
	
			Aviso( STR0006, cErrorTrd, { STR0008 } ) //"Atenção"    "Sair"
	
		//Erro na execução dos Blocos
		Else
	
			cErrorGISS := STR0009	                      //"Ocorreu um erro fatal durante a geração do(s) Registro(s) da GISS Online"
			cErrorGISS += STR0010 + Chr( 10 ) + Chr( 10 )	 //"Favor efetuar o reprecessamento da GISS Online, caso o erro persista entre em contato com o administrador de sistemas / suporte TOTVS"			
	
			Aviso( STR0006, cErrorGISS, { STR0008 } )
	
		EndIf
	EndIf

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} getObrigParam

@Author francisco.nunes
@Since 01/02/2016
@Version 1.0

/*/
//-------------------------------------------------------------------
Static Function getObrigParam()

Local	cNomWiz	as char
Local 	cNomeAnt 	as char
Local	cTitObj1	as char
Local	aTxtApre	as array
Local	aPaineis	as array	
Local	aItens1	as array
Local	aRet		as array
	
	cNomWiz	:= cObrig + FWGETCODFILIAL
	cNomeAnt 	:= ""
	aTxtApre	:= {}
	aPaineis	:= {}	
	aItens1	:= {}	
	cTitObj1	:= ""
	aRet		:= {}
	
	aAdd (aTxtApre, STR0015)	//"Processando Empresa."	
	aAdd (aTxtApre, "")
	aAdd (aTxtApre, STR0016)	//"Preencha corretamente as informações solicitadas."	
	aAdd (aTxtApre, STR0017)	//"Informações necessárias para a geração do meio-magnético GISS Online."	

	//============= Painel 0 ==============

	aAdd (aPaineis, {})
	nPos := Len (aPaineis)
	aAdd (aPaineis[nPos], STR0016)	//"Preencha corretamente as informações solicitadas."	
	aAdd (aPaineis[nPos], STR0017)	//"Informações necessárias para a geração do meio-magnético GISS Online."
	aAdd (aPaineis[nPos], {})
																
	//LINHA 1---------------------------------------------------------------------------------------------//
	cTitObj1 := STR0018 //"Diretório do Arquivo Destino"	                 
	cTitObj2 := STR0019 //"Nome do Arquivo Destino"

	aAdd( aPaineis[nPos,3], { 1, cTitObj1,,,,,,} )
	aAdd (aPaineis[nPos,3], { 1, cTitObj2,,,,,,} )

	cTitObj1 := Replicate( "X", 50 )
	cTitObj2 := Replicate( "X", 20 )

	aAdd( aPaineis[nPos,3], { 2,, cTitObj1, 1,,,, 50,,,, { "xValWizCmp", 3 , { "", "" } } } ) //Valida campo: "Diretório do Arquivo Destino" no Botão Avançar
	aAdd( aPaineis[nPos,3], { 2,, cTitObj2, 1,,,, 20,,,, { "xValWizCmp", 4 , { "", "" } } } ) //Valida campo: "Nome do Arquivo Destino" no Botão Avançar

	aAdd (aPaineis[nPos][3], {0,"",,,,,,})					
	aAdd (aPaineis[nPos][3], {0,"",,,,,,}) //Pula Linha
   
   //LINHA 2---------------------------------------------------------------------------------------------//

	cTitObj1	:=	STR0020   //"Mês Referência"
	cTitObj2	:=	STR0021   //"Ano Referência"

	aAdd( aPaineis[nPos,3], { 1, cTitObj1,,,,,,} )
	aAdd( aPaineis[nPos,3], { 1, cTitObj2,,,,,,} )

	aAdd (aItens1, STR0022)     //"01 - Janeiro"
	aAdd (aItens1, STR0023)     //"02 - Fevereiro"
	aAdd (aItens1, STR0024)     //"03 - Março"
	aAdd (aItens1, STR0025)     //"04 - Abril"
	aAdd (aItens1, STR0026)     //"05 - Maio"
	aAdd (aItens1, STR0027)     //"06 - Junho"
	aAdd (aItens1, STR0028)     //"07 - Julho"
	aAdd (aItens1, STR0029)     //"08 - Agosto"
	aAdd (aItens1, STR0030)     //"09 - Setembro"
	aAdd (aItens1, STR0031)     //"10 - Outubro"
	aAdd (aItens1, STR0032)     //"11 - Novembro"
	aAdd (aItens1, STR0033)     //"12 - Dezembro"

	cTitObj2 :=	"@E 9999"

	aAdd (aPaineis[nPos,3], {3,,,,,aItens1,,,,,}) 
	aAdd( aPaineis[nPos,3], {2,,cTitObj2,2,0,,,4})

	aAdd (aPaineis[nPos][3], {0,"",,,,,,})					
	aAdd (aPaineis[nPos][3], {0,"",,,,,,}) //Pula Linha
   
   //--------------------------------------------------------------------------------------------------//

	aAdd(aRet, aTxtApre)
	aAdd(aRet, aPaineis)
	aAdd(aRet, cNomWiz)
	aAdd(aRet, cNomeAnt)
	aAdd(aRet, Nil )
	aAdd(aRet, Nil )
	aAdd(aRet, { || TAFXGISS() } )

Return (aRet)

//---------------------------------------------------------------------
/*/{Protheus.doc} GerTxtGISS

Geracao do Arquivo TXT da GISS Online.
Gera o arquivo de cada registros.

@Param cStrTxt -> Alias da tabela de informacoes geradas pelo GISS Online
        lCons   -> Gera o arquivo consolidado ou apenas o TXT de um registro

@Return ( Nil )

@Author francisco.nunes
@Since 01/02/2016
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function GerTxtGISS( nHandle as numeric, cTXTSys as char, cReg as char, aWizard as array )

Local cDirName	as char
Local cFileDest	as char
Local lRetDir		as logical
Local lRet			as logical

	Default aWizard := {}

	cFileDest := ''
	if len( aWizard ) > 0
		cDirName  := Alltrim( aWizard[1][1] ) 
		cFileDest := cReg + Alltrim( aWizard[1][2] )
	endif

	lRetDir	:= .T.
	lRet		:= .T.
	
	//Verifica se o diretorio de gravacao dos arquivos existe no RoothPath e cria se necessario
	if !File( cDirName )
	
		lRetDir := FWMakeDir( cDirName )
	
		if !lRetDir
	
			cDirName	:=	""
	
			Help( ,,"CRIADIR",, STR0036 + cValToChar( FError() ) , 1, 0 )   //"Não foi possível criar o diretório \Obrigacoes_TAF\GISS Online. Erro:"
	
			lRet	:=	.F.
	
		endIf
	
	endIf
	
	if lRet
	
		//Tratamento para Linux onde a barra é invertida
		If GetRemoteType() == 2
			If !Empty( cDirName ) .and. ( SubStr( cDirName, Len( cDirName ), 1 ) <> "/" )
				cDirName += "/"
			EndIf
		Else
			If !Empty( cDirName ) .and. ( SubStr( cDirName, Len( cDirName ), 1 ) <> "\" )
				cDirName += "\"
			EndIf
		EndIf
	
		//Monto nome do arquivo que será gerado
		If Upper( Right( AllTrim( cFileDest  ), 4 ) ) <> ".DAT"
			cFileDest := cFileDest + ".DAT"
		EndIf
		lRet := SaveTxt( nHandle, cTxtSys, (cDirName + cFileDest) )
	endif

Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFTTGISS
TAFTTGISS() - Monta a tabela temporaria para GISS
 
@Author Denis Souza
@Since 01/02/2016
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function TAFTTGISS( lCanBulk, cTBulk, oBulk, oTT, cAliasTT )

Local cDbAcesBld As Char
Local cDataLib   As Char
Local aCmp 		 As Array
Local cTpVal     As Char
Local nTmDoc   	 As Numeric
Local nTmSer   	 As Numeric
Local nTmVlDoc 	 As Numeric
Local nTmDcDoc 	 As Numeric
Local nTmSrv   	 As Numeric
Local nTmNome  	 As Numeric
Local nTmEnd   	 As Numeric
Local nTmCmp   	 As Numeric
Local nTmNrEnd 	 As Numeric
Local nTmCEP   	 As Numeric
Local nTmBairro	 As Numeric
Local nTmMunic 	 As Numeric
Local nTmCtCtb 	 As Numeric
Local nTmAlq   	 As Numeric
Local nTmDcAlq 	 As Numeric
Local nTmInscm	 As	Numeric

Default oTT 	 := Nil
Default oBulk 	 := Nil
Default cTBulk 	 := ''
Default lCanBulk := .F.
Default cAliasTT := ''

cDbAcesBld := TCGetBuild()//TCAPIBuild()

//Obtem o CNPJ da SCP que esta sendo processada
If FindFunction( "FWLibVersion" )
	cDataLib := FWLibVersion()
Else
	//Verifica data de um fonte da LIB que foi alterado na release 12.1.005
	cDataLib := DToS( GetAPOInfo( "PROTHEUSFUNCTIONMVC.PRX" )[4] )
EndIf

nTmDoc    := TamSX3("C20_NUMDOC")[1] //060 x 9
nTmSer    := TamSX3("C20_SERIE")[1]  //020 x 3
nTmVlDoc  := TamSX3("C20_VLDOC")[1]  //016 x
nTmDcDoc  := TamSX3("C20_VLDOC")[2]  //002 x
nTmSrv    := TamSX3("C30_SRVMUN")[1] //020 x
nTmNome   := TamSX3("C1H_NOME")[1]   //100 x 60
nTmEnd    := TamSX3("C1H_END")[1]    //220 X
nTmCmp    := TamSX3("C1H_COMPL")[1]  //060 X
nTmNrEnd  := TamSX3("C1H_NUM")[1]    //020 X
nTmCEP    := TamSX3("C1H_CEP")[1]    //008 X
nTmBairro := TamSX3("C1H_BAIRRO")[1] //060 X
nTmMunic  := TamSX3("C07_DESCRI")[1] //220 X
nTmCtCtb  := TamSX3("C1O_CODIGO")[1] //060 X
nTmAlq    := TamSX3("C35_ALIQ")[1]   //008 X
nTmDcAlq  := TamSX3("C35_ALIQ")[2]   //004 X
nTmInscm  := TamSX3("C1H_IM")[1]	 //020 X

//necessario trabalhar com tipo caracter devido tabela temporaria sql e bulk no oracle
//Error : 1722 - ORA-01722: invalid number ( From tDBServer::ROP_DBINSERT )
cTpVal 	 := 'C'
nTmVlDoc := nTmVlDoc + nTmDcDoc
nTmAlq 	 := nTmAlq + nTmDcAlq
nTmDcDoc := 0 //nao possui decimal
nTmDcAlq := 0 //nao possui decimal

//O comprimento do nome do campo deve ser no máximo 10
aCmp := {{ 'INDICADOR'	 ,'C'	, 001	 	,0}			,; //#col01 "CD_INDICADOR"              T
 		 { 'LAYOUT'	 	 ,'C'	, 001 	 	,0}			,; //#col02 "NR_LAYOUT"                 1
 		 { 'EMISSAO'	 ,'C'	, 010 	 	,0}			,; //#col03 "DT_EMISSAO_NF"             01/10/2018
 		 { 'DOCINI'	 	 ,'C'	, nTmDoc 	,0}			,; //#col04 "NR_DOC_NF_INICIAL"         0003267
 		 { 'DOCSERIE'	 ,'C'	, nTmSer 	,0}			,; //#col05 "NR_DOC_NF_SERIE"           E
 		 { 'DOCFIN'	 	 ,'C'	, nTmDoc 	,0}			,; //#col06 "NR_DOC_NF_FINAL"			0003267
 		 { 'TPDOCNF'	 ,'C'	, 001 	 	,0}			,; //#col07 "TP_DOC_NF"                 1
 		 { 'VLDOCNF'	 ,cTpVal, nTmVlDoc	,nTmDcDoc}	,; //#col08 "VL_DOC_NF"                 307000
 		 { 'VLBSCALC'	 ,cTpVal, nTmVlDoc	,nTmDcDoc}  ,; //#col09 "VL_BASE_CALCULO"		    0
 		 { 'ATIVIDADE'	 ,'C'	, nTmSrv 	,0}			,; //#col10 "CD_ATIVIDADE"              1701
 		 { 'CDPTESTAB'	 ,'C'	, 001 		,0}			,; //#col11 "CD_PREST_TOM_ESTABELECIDO" S
 		 { 'LOCALPREST'	 ,'C'	, 001 		,0}			,; //#col12 "CD_LOCAL_PRESTACAO"        F
 		 { 'RAZAOSOC' 	 ,'C'	, nTmNome 	,0}			,; //#col13 "NM_RAZAO_SOCIAL"           AIR E COMPRESS COMERCIO DE COMPRESSORES GERADORES PECAS E SE
 		 { 'NRCNPJCPF'	 ,'C'	, 014 		,0}			,; //#col14 "NR_CNPJ_CPF"	            02621808000111
 		 { 'TIPOCADAST'	 ,'C'	, 001 		,0}			,; //#col15 "CD_TIPO_CADASTRO"          2
 		 { 'INSCMUN'	 ,'C'	, nTmInscm	,0}			,; //#col16 "NR_INSCRICAO_MUNICIPAL"    02122590011
 		 { 'INSCMUNDV'	 ,'C'	, 002 		,0}			,; //#col17 "NM_INSCRICAO_MUNICIPAL_DV" 01
 		 { 'INSCESTAD'	 ,'C'	, 015 		,0}			,; //#col18 "NR_INSCRICAO_ESTADUAL"     278107240118 //parameter size 13 - Expected 12 (Row 11 Col 18)
 		 { 'TIPOLOGRAD'	 ,'C'	, 005 		,0}			,; //#col19 "NM_TIPO_LOGRADOURO"        AME
 		 { 'TITLOGRAD'	 ,'C'	, 005 		,0}			,; //#col20 "NM_TITULO_LOGRADOURO"      Avenida Marginal Esquerda
 		 { 'LOGRADOURO'	 ,'C'	, nTmEnd 	,0}			,; //#col21 "NM_LOGRADOURO"             AV MARIA SOCORRO E SILVA BEZERRA
 		 { 'COMPLOGRAD'	 ,'C'	, nTmCmp 	,0}			,; //#col22 "NM_COMPL_LOGRADOURO"       APTO
 		 { 'NRLOGRAD'	 ,'C'	, nTmNrEnd 	,0}			,; //#col23 "NR_LOGRADOURO"             1660
 		 { 'CEP'		 ,'C'	, nTmCEP	,0}			,; //#col24 "CD_CEP"                    05305003
 		 { 'BAIRRO'		 ,'C'	, nTmBairro	,0}			,; //#col25 "NM_BAIRRO"                 ARUJA CENTRO RESIDENCIAL              
 		 { 'ESTADO'		 ,'C'	, 002 		,0}			,; //#col26 "CD_ESTADO"                 SP                
 		 { 'CIDADE'		 ,'C'	, nTmMunic	,0}			,; //#col27 "NM_CIDADE"                 SAO PAULO
 		 { 'PAIS'		 ,'C'	, 002 		,0}			,; //#col28 "CD_PAIS"                   BR
 		 { 'OBS'		 ,'C'	, 100 		,0}			,; //#col29 "NM_OBSERVACAO"             ?
 		 { 'PLCONTA'	 ,'C'	, nTmCtCtb 	,0}			,; //#col30 "CD_PLANO_CONTA"            11310001
 		 { 'ALVARA'		 ,'C'	, 015 		,0}			,; //#col31 "CD_ALVARA"				 	? 				 
 		 { 'ORIGEM'		 ,'C'	, 001 		,0}			,; //#col32 "IC_ORIGEM_DADOS"           R          
 		 { 'ENQUAD'		 ,'C'	, 001 		,0}			,; //#col33 "IC_ENQUADRAMENTO"          ?         		 
		 { 'PLCONTAPAI'	 ,'C'	, nTmCtCtb	,0}			,; //#col34 "CD_PLANO_CONTA_PAI"        11310000
 		 { 'RECIMPOSTO'	 ,'C'	, 001 		,0}			,; //#col35 "IC_RECOLHE_IMPOSTO"        ?
 		 { 'ALIQ'		 ,cTpVal, nTmAlq 	,nTmDcAlq}	,; //#col36 "VL_ALIQUOTA"               5099  
 		 { 'ISENTO'		 ,'C'	, 001 		,0}			,; //#col37 "FL_ISENTO"                 S                
 		 { 'SIMPLES'	 ,'C'	, 001 		,0}			,; //#col38 "FL_SIMPLES"         	    N     
 		 { 'MESNF'		 ,'C'	, 002 		,0}			,; //#col39 "MESNF" 	 				01   
 		 { 'ANONF'		 ,'C'	, 004 		,0}}		   //#col40 "ANONF" 					2021

//Obs.: Este método não depende da classe FWBulk ser inicializada por New, por este motivo, deve-se utilizar FWBulk():CanBulk()
lCanBulk := cDbAcesBld >= "20181212" .And. cDataLib >= "20201009" .And. FwBulk():CanBulk()

if lCanBulk
	FWDBCreate( cTBulk, aCmp , 'TOPCONN' , .T.)
	DBUseArea(.F., 'TOPCONN', cTBulk, (cTBulk), .F., .F.)
	(cTBulk)->(DBCreateIndex( (cTBulk + '1'), 'INDICADOR+LAYOUT', { || 'INDICADOR+LAYOUT' }, .F. ) )
	Set Index To (cTBulk+"1")

	oBulk := FwBulk():New( cTBulk )	
	if TCCanOpen(cTBulk, (cTBulk + '1')) //retorna .T., ou seja, tabela e índice existem	
		oBulk:SetFields( aCmp )
		DbSelectArea( cTBulk )
		TafConout("--->Alias Bulk: " + cTBulk )
	endif
endif

//Cria estrutura temporaria caso o bulk nao funcione
if !lCanBulk
	cAliasTT := GetNextAlias()
	oTT := FWTemporaryTable():New(cAliasTT, aCmp)
	oTT:AddIndex("1", { 'INDICADOR', 'LAYOUT' } )
	oTT:Create()
endif

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} TGISSRelat

TGISSRelat() - Gera relatório de conferência da GISS ONLINE para os registros
que foram impressos no arquivo da obrigação

@Author Rafael Völtz
@Since 04/01/2017
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function TGISSRelat()
	Local oReport
	Private cTipoServico as char

	If FindFunction("TRepInUse") .And. TRepInUse()
		//-- Interface de impressao
		oReport := ReportDef()		
		oReport:PrintDialog()
	EndIf	
	

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportDef

ReportDef() - Gera relatório de conferência da GISS ONLINE para os registros
que foram impressos no arquivo da obrigação

@Author Rafael Völtz
@Since 04/01/2017
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function ReportDef	

	Local oReport     	as object
	Local oSectionNF   	as object
	Private cAliasRelNF  	as char	
	Private cAliasRec       as char
	
	oReport 	:= TReport():New("GISS ONLINE",UPPER(STR0052),"",{|oReport| ReportPrint(oReport)},STR0053)		//Conferência dos documentos gerados na GISS ONLINE
	cAliasRelNF	:= ""
	cAliasRec   := ""
	cAliasTot 	:= ""
	
	oSectionNF := TRSection():New(oReport,STR0054,{"(cAliasRelNF)"},{"NUM_DOC"})  //Documentos Fiscais de Serviço
	oSectionNF:SetHeaderPage(.F.)	//Define que imprime cabeçalho das células no topo da página.		
	
	oCell := TRCell():New(oSectionNF,"(cAliasRelNF)->DC_NUMDOC",	"(cAliasRelNF)",UPPER(STR0043),	/*Picture*/,  15,	/*lPixel*/,{|| (cAliasRelNF)->DC_NUMDOC }) 																//NOTA FISCAL
	oCell := TRCell():New(oSectionNF,"(cAliasRelNF)->DC_SERIE",		"(cAliasRelNF)",UPPER(STR0044),	/*Picture*/,  3,	/*lPixel*/,{|| (cAliasRelNF)->DC_SERIE })																//SÉRIE
	oCell := TRCell():New(oSectionNF,"(cAliasRelNF)->DC_DTDOC",		"(cAliasRelNF)",UPPER(OEMTOANSI(STR0045)),	/*Picture*/,  10,	/*lPixel*/,{|| SToD((cAliasRelNF)->DC_DTDOC)}) 												//DATA EMISSAO				
	oCell := TRCell():New(oSectionNF,"(cAliasRelNF)->PT_NOME",		"(cAliasRelNF)",UPPER(STR0047),	/*Picture*/,  60,	/*lPixel*/,{|| Alltrim((cAliasRelNF)->PT_CODIGO) 	+ ' - ' +  Alltrim((cAliasRelNF)->PT_NOME)}) 		//PARTICIPANTE
	oCell := TRCell():New(oSectionNF,"(cAliasRelNF)->PT_MUNPIO",	"(cAliasRelNF)",UPPER(STR0048),	/*Picture*/,  30,	/*lPixel*/,{|| Alltrim((cAliasRelNF)->PT_MUNPIO)})														//MUNICÍPIO PARTICIPANTE
	oCell := TRCell():New(oSectionNF,"(cAliasRelNF)->DC_LOCPRE",	"(cAliasRelNF)",UPPER(STR0049),	/*Picture*/,  30,	/*lPixel*/,{|| Alltrim( POSICIONE("C07", 3,  xFilial( "C07" ) + (cAliasRelNF)->DC_LOCPRE, "C07_DESCRI"))  })		//MUNICÍPIO PRESTAÇÃO
	oCell := TRCell():New(oSectionNF,"(cAliasRelNF)->DC_SRVMUN",	"(cAliasRelNF)",UPPER(STR0057),	/*Picture*/,  12,	/*lPixel*/,{||  Alltrim( Iif(Empty((cAliasRelNF)->DC_NFSRVMUN),(cAliasRelNF)->DC_SRVMUN,(cAliasRelNF)->DC_NFSRVMUN) ) })												//Código do serviço
	oCell := TRCell():New(oSectionNF,"(cAliasRelNF)->DC_CHVNF",		"(cAliasRelNF)",UPPER(STR0050),	/*Picture*/,  60,	/*lPixel*/,{|| Alltrim(TAFDescServ((cAliasRelNF)->DC_CHVNF))})											//Descrição do Serviço
	oCell := TRCell():New(oSectionNF,"(cAliasRelNF)->DC_VLDOC",		"(cAliasRelNF)",UPPER(STR0051),	"@E 999,999,999.99",  20,	/*lPixel*/,{|| (cAliasRelNF)->DC_VLDOC })														//Valor
	
	oReport:HideParamPage()   		//Define se será permitida a alteração dos parâmetros do relatório.
	oReport:SetLandScape()  		//Define orientação de página do relatório como paisagem
	oReport:ParamReadOnly()			//Parâmetros não poderão ser alterados pelo usuário
	oReport:DisableOrientation()	//Desabilita a seleção da orientação (Retrato/Paisagem)
	oReport:HideFooter()			//Define que não será impresso o rodapé padrão da página
	
	oBreak:= TRBreak():New(oSectionNF, "(cAliasRelNF)->DC_INDOPE" , {|| "TOTAL SERVIÇO " + (cTipoServico)}  , .F., 'NOMEBRK', .T.)	
	oSum  := TRFunction():New(oSectionNF:Cell('(cAliasRelNF)->DC_VLDOC'),"TOTALSERV", 'SUM',oBreak,"","@E 999,999,999.99",,.F.,.F.,.F., oSectionNF)		
	
	
	oSectionRec := TRSection():New(oReport,"Recibos de Serviços Tomados",{"(cAliasRec)"},{"LEM_NUMERO"})  //Documentos Fiscais de Serviço
	oSectionRec:SetHeaderPage(.F.)	//Define que imprime cabeçalho das células no topo da página.
	
	oCell := TRCell():New(oSectionRec,"(cAliasRec)->LEM_NUMERO",	"(cAliasRec)",UPPER("Número do Documento"),	/*Picture*/,  15,	/*lPixel*/,{|| (cAliasRec)->LEM_NUMERO }) 																//NOTA FISCAL	
	oCell := TRCell():New(oSectionRec,"(cAliasRec)->LEM_DTEMIS",		"(cAliasRec)",UPPER(OEMTOANSI(STR0045)),	/*Picture*/,  10,	/*lPixel*/,{|| SToD((cAliasRec)->LEM_DTEMIS)}) 												//DATA EMISSAO				
	oCell := TRCell():New(oSectionRec,"(cAliasRec)->C1H_NOME",		"(cAliasRec)",UPPER(STR0047),	/*Picture*/,  60,	/*lPixel*/,{|| Alltrim((cAliasRec)->C1H_CODPAR) 	+ ' - ' +  Alltrim((cAliasRec)->C1H_NOME)}) 		//PARTICIPANTE
	oCell := TRCell():New(oSectionRec,"(cAliasRec)->C07_DESCRI",	"(cAliasRec)",UPPER(STR0048),	/*Picture*/,  30,	/*lPixel*/,{|| Alltrim((cAliasRec)->C07_DESCRI)})														//MUNICÍPIO PARTICIPANTE
	oCell := TRCell():New(oSectionRec,"(cAliasRec)->LEM_CODLOC",	"(cAliasRec)",UPPER(STR0049),	/*Picture*/,  30,	/*lPixel*/,{|| Alltrim( POSICIONE("C07", 3,  xFilial( "C07" ) + (cAliasRec)->LEM_CODLOC, "C07_DESCRI"))  })		//MUNICÍPIO PRESTAÇÃO
	oCell := TRCell():New(oSectionRec,"(cAliasRec)->LEM_SRVMUN",	"(cAliasRec)",UPPER(STR0057),	/*Picture*/,  12,	/*lPixel*/,{||  Alltrim( (cAliasRec)->LEM_SRVMUN) })												//Código do serviço	
	oCell := TRCell():New(oSectionRec,"(cAliasRec)->LEM_VLBRUT",		"(cAliasRec)",UPPER(STR0051),	"@E 999,999,999.99",  20,	/*lPixel*/,{|| (cAliasRec)->LEM_VLBRUT })
	
	oBreak:= TRBreak():New(oSectionRec, "(cAliasRec)->LEM_NUMERO" , {|| "TOTAL SERVIÇO RECIBO/FATURA "}  , .F., 'NOMEBRK', .T.)	
	oSum  := TRFunction():New(oSectionRec:Cell('(cAliasRec)->LEM_VLBRUT'),"TOTALSERV", 'SUM',oBreak,"","@E 999,999,999.99",,.F.,.F.,.F., oSectionRec)			
	
	oReport:SetCustomText({|| TCabecGISS( oReport )})		
	
	                                    
Return oReport

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportPrint

ReportPrint() - Query de consulta para extração do relatório

@Param
 oReport   - Objeto do relatório
 
@Author Rafael Völtz
@Since 04/01/2017
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function ReportPrint(oReport as object)
	Local oSectionNF 	as object
	Local cNF 			as char
	
	cAliasRelNF := TAFSQLServ(DTOS(dInicial), DTOS(dFinal))	 
	
	oSectionNF  := oReport:Section(1)	
	cNF := ""
		
	While !(cAliasRelNF)->(Eof()) .And. !oReport:Cancel()		
		
		If Empty(cNF)
			oSectionNF:Init()
			cNF := (cAliasRelNF)->DC_NUMDOC
		EndIf
		 
		oSectionNF:PrintLine()
		cTipoServico := iif((cAliasRelNF)->DC_INDOPE == '0',STR0055,STR0056 )

		(cAliasRelNF)->(dbSkip())
	EndDo
			
	oSectionNF:Finish()
	
	oSectionNF:SetHeaderPage(.F.)
	oSectionNF:SetHeaderBreak(.F.)
	oSectionNF:SetHeaderSection(.F.)
	
	(cAliasRelNF)->(DbCloseArea())
		
	/* Serviços Tomados sem documentos fiscal */	
	If TAFAlsInDic( "LEM",.F. )
	
		oSectionRec := oReport:Section(2)	
	
		cAliasRec := TAFRecibosServ(DTOS(dInicial), DTOS(dFinal))						
		cNF := ""
		
		While !(cAliasRec)->(Eof()) .And. !oReport:Cancel()		
			
			If Empty(cNF)
				oSectionRec:Init()
				cNF := (cAliasRec)->LEM_NUMERO
			EndIf
			 
			oSectionRec:PrintLine()
			(cAliasRec)->(dbSkip())
		EndDo
		
		oSectionRec:Finish()
		(cAliasRec)->(DbCloseArea())
		
	EndIf	
	
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} TCabecGISS

TCabecGISS() - Montagem do cabeçalho do relatório

@Param
 oReport   - Objeto do relatório
 
@Author Rafael Völtz
@Since 04/01/2017
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function TCabecGISS( oReport as object )

Local aArea     as array
Local aCabec    as array
Local cChar     as char

	aArea     := GetArea()
	aCabec    := {}
	cChar     := chr(160)  // caracter dummy para alinhamento do cabeçalho
	
	If SM0->(Eof())                                
	    SM0->( MsSeek( cEmpAnt + cFilAnt , .T. ))
	Endif
	
	aCabec := {    "__LOGOEMP__" , cChar + "            " ;
	          + "            " + cChar + RptFolha + TRANSFORM(oReport:Page(),'9999');
	          , cChar + "            " ;
	          + "            " + cChar ;
	          , "SIGATAF /" + 'GISS ONLINE' + " /v." + cVersao ; 
	          + "            " + cChar + UPPER( oReport:CTITLE ) ; 
	          + "            " + cChar;
	          , "            " + cChar + RptEmiss + " " + Dtoc(dDataBase);
	          ,(STR0038 + "...........: " +Trim(SM0->M0_NOME) + " / " + STR0039+": " + Trim(SM0->M0_FILIAL));  //"Empresa:"  "Filial:"
	          + "            " + cChar + STR0042+":  " + " " + time();
	          ,(STR0040+"....: " + DTOC(dInicial) + " "+STR0041 + " "+ DTOC(dFinal)); //Período Gerado:	   à       
	          , cChar + "            " }
	
	RestArea( aArea )
              
Return aCabec
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFDescServ

TAFDescServ() - Busca a descrição do serviço

@Param
 cChaveNF   - Chave da Nota
 
@Author Rafael Völtz
@Since 06/02/2017
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function TAFDescServ(cChaveNF as char)

Local cDescServ  as char
Local cAliasQry  as char

	cAliasQry  := GetNextAlias()
	cDescServ  := ""
	
	BeginSql Alias cAliasQry
		SELECT C1L.C1L_DESCRI		       
	           		
		FROM %table:C20% C20
			INNER JOIN %table:C30% C30 ON C30.C30_FILIAL = C20.C20_FILIAL AND C30.C30_CHVNF = C20.C20_CHVNF  AND C30.%NotDel%
			INNER JOIN %table:C1L% C1L ON C1L.C1L_FILIAL = C30.C30_FILIAL AND C1L.C1L_ID 	= C30.C30_CODITE AND C1L.%NotDel%
			
		WHERE C20.C20_FILIAL = %xFilial:C20%
		   AND C20.C20_CHVNF = %Exp:Alltrim(cChaveNF) %
		   AND C20.%NotDel%
		
	EndSQL
	
	
	DbSelectArea(cAliasQry)
	(cAliasQry)->(DbGoTop())
	
	While (cAliasQry)->(!EOF())
		If Empty(cDescServ)
			cDescServ := Alltrim((cAliasQry)->C1L_DESCRI)
		Else
			cDescServ += ". " + Alltrim((cAliasQry)->C1L_DESCRI)
		EndIf
		
		(cAliasQry)->(DbSkip())
	EndDo
	
	(cAliasQry)->(DbCloseArea())

Return cDescServ


//-------------------------------------------------------------------
/*/{Protheus.doc} TAFCadAdic

Cadastro adicional para manutenção dos códigos de serviço

@Param
 dIni    - Data inicial informado na wizard
 dFim    - Data final informado na wizard
 

@Author Rafael Völtz
@Since 28/12/2016
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function TAFCadAdic(dIni as date, dFim as date)

Local nOpc         as numeric
Local aArea	       as array
Local aAlter       as array
Local lOk          as logical

Private aColsGrid  as array
Private aHeaGrid   as array
Private oBrowGISS   as object
Private oDlg1      as object
Private noBrw      as numeric
	
	nOpc		:= GD_UPDATE	
	aArea		:= GetArea()	
	
	If lBrwServ
		aAlter 		:= {}	
		aColsGrid	:= {}
		aHeaGrid	:= {}
		oBrowGISS	:= nil
		oDlg1		:= nil
		noBrw 		:= 0
		lOk		 	:= .T.
		
		TAFAGISSBrw("C1L")
		TAFAGISSCols("C1L",dInicial, dFinal)
	
		aAdd(aAlter,aHeaGrid[3,2]) //Código do serviço municipal
	
		oDlg1    := MSDialog():New( 091,232,502,900,STR0058,,,.F.,,,,,,.T.,,,.T. )   //str0058 Código de Serviço/Atividade Municipal por Item"
		
		DbSelectArea("C1L")
		oBrowGISS := MsNewGetDados():New(024, 016, 216, 368, nOpc, "AllwaysTrue", "AllwaysTrue", "", aAlter, 000, len(aColsGrid), "AllwaysTrue", "", "AllwaysTrue", oDlg1, aHeaGrid, aColsGrid)
		
		oBrowGISS:obrowse:align:= CONTROL_ALIGN_ALLCLIENT
		
		oDlg1:bInit 		:= EnchoiceBar(oDlg1,{||lOk:=GravaGrid("C1N"), oDlg1:End()},{|| lOk := .F., oDlg1:End()})
		oDlg1:lCentered		:= .T.
		oDlg1:Activate()
	EndIf
		
	RestArea(aArea)

Return lOk

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFAGISSBrw

TAFAGISSBrw() - Monta aHeaGrid da MsNewGetDados
@Param 
 cAlias  - Alias principal que será alterado 

@Author Rafael Völtz
@Since 28/12/2016
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function TAFAGISSBrw(cAlias as char)

	DbSelectArea("SX3")
	DbSetOrder(1)	
	
	DbSeek("C1L")	  	
  	While !Eof() .and. SX3->X3_ARQUIVO == "C1L"
  		
		If Alltrim(SX3->X3_CAMPO) $ "C1L_CODIGO"
	 		noBrw++
			aAdd( aHeaGrid, { AlLTrim( X3Titulo() ),; // 01 - Titulo
			SX3->X3_CAMPO,;
	       	SX3->X3_PICTURE,;
	       	20,;
	       	SX3->X3_DECIMAL,;
	       	SX3->X3_VALID,;
	       	SX3->X3_USADO,;
	       	SX3->X3_TIPO,;
	       	SX3->X3_F3	,;				// 09 - F3
			SX3->X3_CONTEXT ,;       	// 10 - Contexto
			SX3->X3_CBOX	,; 	  	  	// 11 - ComboBox
		    "", } ) 	   	    		// 12 - Relacao
		Endif
		
		If Alltrim(SX3->X3_CAMPO) $ "C1L_DESCRI"
	 		noBrw++
			aAdd( aHeaGrid, { AlLTrim( X3Titulo() ),; // 01 - Titulo
			SX3->X3_CAMPO,;
	       	SX3->X3_PICTURE,;
	       	40,;
	       	SX3->X3_DECIMAL,;
	       	SX3->X3_VALID,;
	       	SX3->X3_USADO,;
	       	SX3->X3_TIPO,;
	       	SX3->X3_F3	,;					// 09 - F3
			SX3->X3_CONTEXT ,;       		// 10 - Contexto
			SX3->X3_CBOX		,; 	  	  	// 11 - ComboBox
		    "", } ) 		  				// 12 - Relacao
		Endif
		
		If Alltrim(SX3->X3_CAMPO) $ "C1L_SRVMUN"
	 		noBrw++
			aAdd( aHeaGrid, { AlLTrim( X3Titulo() ),; // 01 - Titulo
			SX3->X3_CAMPO,;
	       	SX3->X3_PICTURE,;
	       	SX3->X3_TAMANHO,;
	       	20,;
	       	SX3->X3_VALID,;			       	
	       	SX3->X3_USADO,;
	       	SX3->X3_TIPO,;
	       	SX3->X3_F3	,;					// 09 - F3
			SX3->X3_CONTEXT ,;       		// 10 - Contexto
			SX3->X3_CBOX		,; 	  	  	// 11 - ComboBox
		    "", } ) 		  				// 12 - Relacao
		Endif
		  		
		DbSkip()
	EndDo	

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFConsServ()

TAFConsServ() - Consulta no cadastro de Produto para os movimentos do período,
				para verificar se existe código de serviço não preenchido. 
@Param
 dIni    - Data inicial informado na wizard
 dFim    - Data final informado na wizard
 
 @Return
 lExist  - Indica se existe algum cadastro com ANP em branco. 

@Author Rafael Völtz
@Since 28/12/2016
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function TAFConsServ(dIni as date, dFim as date)
 
 Local cAliasQry	as char 
 
 cAliasQry 		:= GetNextAlias() 
 
 BeginSQL Alias cAliasQry
		SELECT COUNT(*) COUNT
	 	  FROM %table:C20% C20	
	INNER JOIN %table:C0U% C0U ON C0U.C0U_FILIAL = %xFilial:C0U%   AND C0U.C0U_ID   = C20.C20_TPDOC  AND C0U.C0U_CODIGO = %Exp:'06'% AND C0U.%NotDel% //TIPO DE NOTA (SERVIÇO) (C0U)
	INNER JOIN %table:C30% C30 ON C30.C30_FILIAL = C20.C20_FILIAL AND C30.C30_CHVNF = C20.C20_CHVNF  AND C30.%NotDel%	
	INNER JOIN %table:C1L% C1L ON C1L.C1L_FILIAL = C30.C30_FILIAL AND C1L.C1L_ID    = C30.C30_CODITE AND C1L.%NotDel%
	 	 WHERE C20.C20_FILIAL = %xFilial:C20%	 	    
	 	   AND C20.C20_DTDOC BETWEEN %Exp:DTOS(dIni)% AND %Exp:DTOS(dFim)%	 	   
	 	   AND (C1L.C1L_SRVMUN IS NULL OR C1L.C1L_SRVMUN = ' ') 	   
	 	   AND C20.%NotDel%
 EndSQL
 
 IIF ((cAliasQry)->COUNT > 0, lBrwServ := .T., lBrwServ := .F.)  

 (cAliasQry)->(DbCloseArea())
   
Return lBrwServ

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFAGISSCols()

TAFA456Cols() - Monta aColsGrid da MsNewGetDados

@Param 
 cAlias  - Alias principal que será alterado
 dIni    - Data inicial informado na wizard
 dFim    - Data final informado na wizard 

@Author Rafael Völtz
@Since 28/12/2016
@Version 1.0
/*/
//-------------------------------------------------------------------

Static Function TAFAGISSCols(cAlias as char, dIni as date, dFim as date)
Local nX         as numeric
Local nY         as numeric
Local cAliasQry  as char

 nX        := 0
 nY        := 0
 
 cAliasQry := GetNextAlias()
 	
	BeginSQL Alias cAliasQry
		 	SELECT DISTINCT 
		 	       C1L_CODIGO,
			       C1L_DESCRI,
			       C1L_SRVMUN 
		 	  FROM %table:C20% C20
		INNER JOIN %table:C0U% C0U ON C0U.C0U_FILIAL = %xFilial:C0U%   AND C0U.C0U_ID   = C20.C20_TPDOC  AND C0U.C0U_CODIGO = %Exp:'06'% AND C0U.%NotDel% //TIPO DE NOTA (SERVIÇO) (C0U)
		INNER JOIN %table:C30% C30 ON C30.C30_FILIAL = C20.C20_FILIAL AND C30.C30_CHVNF = C20.C20_CHVNF  AND C30.%NotDel%
		INNER JOIN %table:C1L% C1L ON C1L.C1L_FILIAL = C30.C30_FILIAL AND C1L.C1L_ID    = C30.C30_CODITE AND C1L.%NotDel%				
		 	 WHERE C20.C20_FILIAL = %xFilial:C20%			 	 
		 	   AND C20.C20_DTDOC BETWEEN %Exp:DTOS(dIni)% AND %Exp:DTOS(dFim)%		 	   	 	   
		 	   AND (C1L.C1L_SRVMUN IS NULL OR C1L.C1L_SRVMUN = ' ')			 	   		
		 	   AND C20.%NotDel%		 	  
		 	  ORDER BY C1L_CODIGO
	EndSql
	 
	 While (cAliasQry)->(!Eof())
	 	AADD(aColsGrid,Array(noBrw+1))		
		aColsGrid[Len(aColsGrid)][1]  := (cAliasQry)->C1L_CODIGO
		aColsGrid[Len(aColsGrid)][2]  := substr((cAliasQry)->C1L_DESCRI,   1, 50)
		
		//Código do Serviço
		aColsGrid[Len(aColsGrid)][3]  := space(20)
		aColsGrid[Len(aColsGrid),noBrw+1]:=.F.
	
		(cAliasQry)->(DbSkip())
	EndDo
	
	(cAliasQry)->(DbCloseArea()) 
 
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GravaGrid

Atualiza código do serviço municipal na tabela informada por parâmetro

@Param 
cAlias - Tabela onde será realizada a atualização

@Return 

@Author Rafael Völtz
@Since 28/12/2016
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function GravaGrid(cAlias as char)
Local nX   		as numeric
Local lAlterou	as logical

	lAlterou := .F.
	
	Begin Transaction
		DbSelectArea("C1L")				
		
		C1L->(DbSetOrder(1))				
		
		For nX := 1 To Len(oBrowGISS:aCols)				
			If(!oBrowGISS:aCols[nX][4])						
				
				If (C1L->(DbSeek(xFilial("C1L") + oBrowGISS:aCols[nX][1])))
					While C1L->(!Eof()) .AND. (C1L->C1L_FILIAL + C1L->C1L_CODIGO) == (xFilial("C1L") + oBrowGISS:aCols[nX][1])
						
						//Código Serviço Municipal
						If !Empty(oBrowGISS:aCols[nX][3])
							RecLock("C1L",.F.) //alteração
							C1L->C1L_SRVMUN := Alltrim(oBrowGISS:aCols[nX][3])
							MsUnLock()
							lAlterou := .T.									
						EndIf
						C1L->(DbSkip())								
					EndDo
				EndIf		
			EndIf
		Next
		
		C1L->(DbCloseArea())
				
	End Transaction	
	
	If lAlterou
		msginfo( STR0059  ) 	//"Atenção" 	"Informações atualizadas com sucesso."   	"Sair"
	Else
		msginfo( STR0060 ) 	//"Atenção"		"Nenhum registro foi alterado"     			"Sair"
	EndIf

Return	.T.

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFFILGISS
Filtra na temporaria o layout e monta o arquivo

@Param
	aIndLay
	cTab
	aWizard

@Return

@Author Denis Souza
@Since 15/10/2021
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function TAFFILGISS( aIndLay, cTab, aWizard )

Local nlA 		As numeric
Local nlB 		As numeric
Local nHandle	As numeric
Local aFilter 	As array
Local aFlds     As array
Local cAliasQry	As Char
Local cSelect	As Char
Local cFrom  	As Char
Local cWhere 	As Char
Local cCab      As Char
Local cTxtSys	As Char
Local cStrTxt	As Char
Local cConcat 	As Char
Local cCont 	As Char
Local lCab      As Logical
Local lRet      As Logical
Local lArqGen	As Logical

Default aIndLay := {}
Default cTab := ''

lRet 	  := .T.
lArqGen   := .T.
cConcat   := "||"
cAliasQry := GetNextAlias()

For nlA := 1 to len(aIndLay)
	aFilter := strtokarr( aIndLay[nlA] , "|" )

	//Arquivo temporario que sera criado na system
	cTxtSys := CriaTrab( , .F. ) + ("-" + aFilter[1] + aFilter[2] + ".TXT")
	nHandle := MsFCreate( cTxtSys )

	//string de cabecalho por indicador x layout
	lCab := .T.
	cCab := TAFDPGISS( aIndLay[nlA] , lCab ) + CRLF 

	//string de campos por indicador x layout
	lCab     := .F.
	cSelect  := "% "
	cSelect  += TAFDPGISS( aIndLay[nlA] , lCab )
	cSelect  += " %"

	cFrom    := "% " + cTab + " %"
	cWhere   := "% INDICADOR = '" + aFilter[1] + "' AND LAYOUT = '" + aFilter[2] + "' AND D_E_L_E_T_ = ' ' %"

	BeginSql Alias cAliasQry
		SELECT
			%Exp:cSelect%
		FROM
			%Exp:cFrom%
		WHERE
			%Exp:cWhere%
	EndSql

	if (cAliasQry)->( !EOF() )
		//escreve cabecalho
		WrtStrTxt( nHandle, cCab )
		//monta string de itens
		cSelect := StrTran(strtran(cSelect,"%","")," ","")
		aFlds := STRTOKARR( cSelect, "," )		
		While (cAliasQry)->( !EOF() )
			cStrTxt := ''
			for nlB := 1 to len(aFlds)
				cCont := (cAliasQry)->&(aFlds[nlB] )
				if valtype( cCont ) <> 'C'
					cStrTxt += alltrim(str(cCont)) + cConcat
				else
					cStrTxt += alltrim( cCont ) + cConcat
				endif
			next nlB
			cStrTxt := substr( alltrim(cStrTxt) , 1 , (len(alltrim(cStrTxt)) - len(cConcat)) )
			cStrTxt += CRLF
			//escreve itens
			WrtStrTxt( nHandle, cStrTxt )
			(cAliasQry)->( DbSkip() )
		EndDo
		(cAliasQry)->( DbCloseArea() )

		//salva arquivo final desmembrado por indicador e layout
		lArqGen := GerTxtGISS( nHandle, cTxtSys, (aFilter[1]+aFilter[2]) , aWizard )
		if !lArqGen	//caso ocorra falha no arquivo emitira um aviso de falha na geracao
			lRet := lArqGen
		endif
	endif
next nlA

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFDPGISS
De x Para (Indicador x Layout ) de acordo com os campos da giss 
x campos tabelas temporaria ( ver array aCmp da funcao TAFTTGISS )

@Param 

@Return cCmps

@Author Denis Souza
@Since 15/10/2021
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function TAFDPGISS( cIndLay , lCab )

Local cCmps 	As Char
Local cConcat 	As Char
Local aStru 	As Array
Local nPos  	As Numeric
Local nlA		As Numeric

Default cIndLay := ''
Default lCab := .F.

cCmps := ''
aStru := {}
nPos  := 0
nlA   := 0

//BANCO - Serviço Prestado (A | 1)
if cIndLay == 'A|1' //10cmps
	aadd( aStru , {'CD_INDICADOR'				, 'INDICADOR'})
	aadd( aStru , {'NR_LAYOUT'					, 'LAYOUT'})
	aadd( aStru , {'NR_MES_NF'					, 'MESNF'})
	aadd( aStru , {'NR_ANO_NF'					, 'ANONF'})
	aadd( aStru , {'CD_PLANO_CONTA'				, 'PLCONTA'})
	aadd( aStru , {'CD_PLANO_CONTA_PAI'			, 'PLCONTAPAI'})
	aadd( aStru , {'VL_DOC_NF'					, 'VLDOCNF'})
	aadd( aStru , {'CD_ATIVIDADE'				, 'ATIVIDADE'})
	aadd( aStru , {'IC_RECOLHE_IMPOSTO'			, 'RECIMPOSTO'})
	aadd( aStru , {'IC_ORIGEM_DADOS'			, 'ORIGEM'})

//A Codesp (sigla para Companhia Docas do Estado de São Paulo) é o antigo nome da atual Autoridade Portuária de Santos S/A
//CODESP - Serviço Prestado para Pessoa Física (S | 1)
elseif cIndLay == 'S|1' //14cmps
	aadd( aStru , {'CD_INDICADOR'				, 'INDICADOR'})
	aadd( aStru , {'NR_LAYOUT'					, 'LAYOUT'})
	aadd( aStru , {'NR_DOC_NF_INICIAL'			, 'DOCINI'})
	aadd( aStru , {'NR_DOC_NF_SERIE'			, 'DOCSERIE'})
	aadd( aStru , {'NR_DOC_NF_FINAL'			, 'DOCFIN'})
	aadd( aStru , {'DT_EMISSAO_NF'				, 'EMISSAO'})
	aadd( aStru , {'TP_DOC_NF'					, 'TPDOCNF'})
	aadd( aStru , {'VL_DOC_NF'					, 'VLDOCNF'})
	aadd( aStru , {'CD_ATIVIDADE'				, 'ATIVIDADE'})
	aadd( aStru , {'CD_TIPO_CADASTRO'			, 'TIPOCADAST'})
	aadd( aStru , {'CD_LOCAL_PRESTACAO'			, 'LOCALPREST'})
	aadd( aStru , {'IC_ENQUADRAMENTO'			, 'ENQUAD'})
	aadd( aStru , {'VL_BASE_CALCULO'			, 'VLBSCALC'})
	aadd( aStru , {'IC_ORIGEM_DADOS'			, 'ORIGEM'})

//CODESP - Serviço Prestado para Tomador Fora do País (S | 2)
elseif cIndLay == 'S|2' //14cmps
	aadd( aStru , {'CD_INDICADOR'				, 'INDICADOR'})
	aadd( aStru , {'NR_LAYOUT'					, 'LAYOUT'})
	aadd( aStru , {'NR_DOC_NF_INICIAL'			, 'DOCINI'})
	aadd( aStru , {'NR_DOC_NF_SERIE'			, 'DOCSERIE'})
	aadd( aStru , {'NR_DOC_NF_FINAL'			, 'DOCFIN'})
	aadd( aStru , {'DT_EMISSAO_NF'				, 'EMISSAO'})
	aadd( aStru , {'TP_DOC_NF'					, 'TPDOCNF'})
	aadd( aStru , {'VL_DOC_NF'					, 'VLDOCNF'})
	aadd( aStru , {'CD_ATIVIDADE'				, 'ATIVIDADE'})
	aadd( aStru , {'CD_TIPO_CADASTRO'			, 'TIPOCADAST'})
	aadd( aStru , {'CD_PREST_TOM_ESTABELECIDO'	, 'CDPTESTAB'})
	aadd( aStru , {'CD_PAIS'					, 'PAIS'})
	aadd( aStru , {'NM_RAZAO_SOCIAL'			, 'RAZAOSOC'})
	aadd( aStru , {'NM_OBSERVACAO'				, 'OBS'})
	aadd( aStru , {'CD_LOCAL_PRESTACAO'			, 'LOCALPREST'})
	aadd( aStru , {'IC_ENQUADRAMENTO'			, 'ENQUAD'})
	aadd( aStru , {'VL_BASE_CALCULO'			, 'VLBSCALC'})
	aadd( aStru , {'IC_ORIGEM_DADOS'			, 'ORIGEM'})

//CODESP - Serviço Prestado para Pessoa Jurídica (S | 3)
elseif cIndLay == 'S|3' //30cmps
	aadd( aStru , {'CD_INDICADOR'				, 'INDICADOR'})
	aadd( aStru , {'NR_LAYOUT'					, 'LAYOUT'})
	aadd( aStru , {'NR_DOC_NF_INICIAL'			, 'DOCINI'})
	aadd( aStru , {'NR_DOC_NF_SERIE'			, 'DOCSERIE'})
	aadd( aStru , {'NR_DOC_NF_FINAL'			, 'DOCFIN'})
	aadd( aStru , {'DT_EMISSAO_NF'				, 'EMISSAO'})
	aadd( aStru , {'TP_DOC_NF'					, 'TPDOCNF'})
	aadd( aStru , {'VL_DOC_NF'					, 'VLDOCNF'})
	aadd( aStru , {'CD_ATIVIDADE'				, 'ATIVIDADE'})
	aadd( aStru , {'CD_TIPO_CADASTRO'			, 'TIPOCADAST'})
	aadd( aStru , {'CD_PREST_TOM_ESTABELECIDO'	, 'CDPTESTAB'})
	aadd( aStru , {'NM_RAZAO_SOCIAL'			, 'RAZAOSOC'})
	aadd( aStru , {'NR_INSCRICAO_MUNICIPAL'		, 'INSCMUN'})
	aadd( aStru , {'NM_INSCRICAO_MUNICIPAL_DV'	, 'INSCMUNDV'})
	aadd( aStru , {'NR_CNPJ_CPF'				, 'NRCNPJCPF'})
	aadd( aStru , {'FL_ISENTO'					, 'ISENTO'})
	aadd( aStru , {'NR_INSCRICAO_ESTADUAL'		, 'INSCESTAD'})
	aadd( aStru , {'CD_CEP'						, 'CEP'})
	aadd( aStru , {'NM_TIPO_LOGRADOURO'			, 'TIPOLOGRAD'})
	aadd( aStru , {'NM_TITULO_LOGRADOURO'		, 'TITLOGRAD'})
	aadd( aStru , {'NM_LOGRADOURO'				, 'LOGRADOURO'})
	aadd( aStru , {'NM_COMPL_LOGRADOURO'		, 'COMPLOGRAD'})
	aadd( aStru , {'NR_LOGRADOURO'				, 'NRLOGRAD'})
	aadd( aStru , {'NM_BAIRRO'					, 'BAIRRO'})
	aadd( aStru , {'CD_ESTADO'					, 'ESTADO'})
	aadd( aStru , {'NM_CIDADE'					, 'CIDADE'})
	aadd( aStru , {'CD_LOCAL_PRESTACAO'			, 'LOCALPREST'})
	aadd( aStru , {'IC_ENQUADRAMENTO'			, 'ENQUAD'})
	aadd( aStru , {'VL_BASE_CALCULO'			, 'VLBSCALC'})
	aadd( aStru , {'IC_ORIGEM_DADOS'			, 'ORIGEM'})

//CONSTRUCAO CIVIL - Serviço Prestado para Tomador Pessoa Física - Sem Obras (G | 1)
elseif cIndLay == 'G|1' //13cmps
	aadd( aStru , {'CD_INDICADOR'				, 'INDICADOR'})
	aadd( aStru , {'NR_LAYOUT'					, 'LAYOUT'})
	aadd( aStru , {'NR_DOC_NF_INICIAL'			, 'DOCINI'})
	aadd( aStru , {'NR_DOC_NF_SERIE'			, 'DOCSERIE'})
	aadd( aStru , {'NR_DOC_NF_FINAL'			, 'DOCFIN'})
	aadd( aStru , {'DT_EMISSAO_NF'				, 'EMISSAO'})
	aadd( aStru , {'TP_DOC_NF'					, 'TPDOCNF'})
	aadd( aStru , {'VL_DOC_NF'					, 'VLDOCNF'})
	aadd( aStru , {'CD_ATIVIDADE'				, 'ATIVIDADE'})
	aadd( aStru , {'CD_TIPO_CADASTRO'			, 'TIPOCADAST'})
	aadd( aStru , {'CD_LOCAL_PRESTACAO'			, 'LOCALPREST'})
	aadd( aStru , {'VL_BASE_CALCULO'			, 'VLBSCALC'})
	aadd( aStru , {'IC_ORIGEM_DADOS'			, 'ORIGEM'})

//CONSTRUCAO CIVIL - Serviço Prestado para Tomador Pessoa Física - Sem Obras (G | 1)
elseif cIndLay == 'G|2' //29cmps
	aadd( aStru , {'CD_INDICADOR'				, 'INDICADOR'})
	aadd( aStru , {'NR_LAYOUT'					, 'LAYOUT'})
	aadd( aStru , {'NR_DOC_NF_INICIAL'			, 'DOCINI'})
	aadd( aStru , {'NR_DOC_NF_SERIE'			, 'DOCSERIE'})
	aadd( aStru , {'NR_DOC_NF_FINAL'			, 'DOCFIN'})
	aadd( aStru , {'DT_EMISSAO_NF'				, 'EMISSAO'})
	aadd( aStru , {'TP_DOC_NF'					, 'TPDOCNF'})
	aadd( aStru , {'VL_DOC_NF'					, 'VLDOCNF'})
	aadd( aStru , {'CD_ATIVIDADE'				, 'ATIVIDADE'})
	aadd( aStru , {'CD_TIPO_CADASTRO'			, 'TIPOCADAST'})
	aadd( aStru , {'CD_PREST_TOM_ESTABELECIDO'	, 'CDPTESTAB'})
	aadd( aStru , {'NM_RAZAO_SOCIAL'			, 'RAZAOSOC'})
	aadd( aStru , {'NR_INSCRICAO_MUNICIPAL'		, 'INSCMUN'})
	aadd( aStru , {'NM_INSCRICAO_MUNICIPAL_DV'	, 'INSCMUNDV'})
	aadd( aStru , {'NR_CNPJ_CPF'				, 'NRCNPJCPF'})
	aadd( aStru , {'FL_ISENTO'					, 'ISENTO'})
	aadd( aStru , {'NR_INSCRICAO_ESTADUAL'		, 'INSCESTAD'})
	aadd( aStru , {'CD_CEP'						, 'CEP'})
	aadd( aStru , {'NM_TIPO_LOGRADOURO'			, 'TIPOLOGRAD'})
	aadd( aStru , {'NM_TITULO_LOGRADOURO'		, 'TITLOGRAD'})
	aadd( aStru , {'NM_LOGRADOURO'				, 'LOGRADOURO'})
	aadd( aStru , {'NM_COMPL_LOGRADOURO'		, 'COMPLOGRAD'})
	aadd( aStru , {'NR_LOGRADOURO'				, 'NRLOGRAD'})
	aadd( aStru , {'NM_BAIRRO'					, 'BAIRRO'})
	aadd( aStru , {'CD_ESTADO'					, 'ESTADO'})
	aadd( aStru , {'NM_CIDADE'					, 'CIDADE'})
	aadd( aStru , {'CD_LOCAL_PRESTACAO'			, 'LOCALPREST'})
	aadd( aStru , {'VL_BASE_CALCULO'			, 'VLBSCALC'})
	aadd( aStru , {'IC_ORIGEM_DADOS'			, 'ORIGEM'})

//CONSTRUCAO CIVIL - Serviço Tomado de Prestador Residente no País Com Nota Fiscal - Sem Obra (I | 3)
elseif cIndLay == 'I|3' //30cmps
	aadd( aStru , {'CD_INDICADOR'				, 'INDICADOR'})
	aadd( aStru , {'NR_LAYOUT'					, 'LAYOUT'})
	aadd( aStru , {'NR_DOC_NF_INICIAL'			, 'DOCINI'})
	aadd( aStru , {'NR_DOC_NF_SERIE'			, 'DOCSERIE'})
	aadd( aStru , {'DT_EMISSAO_NF'				, 'EMISSAO'})
	aadd( aStru , {'TP_DOC_NF'					, 'TPDOCNF'})
	aadd( aStru , {'VL_DOC_NF'					, 'VLDOCNF'})
	aadd( aStru , {'CD_ATIVIDADE'				, 'ATIVIDADE'})
	aadd( aStru , {'CD_TIPO_CADASTRO'			, 'TIPOCADAST'})
	aadd( aStru , {'CD_PREST_TOM_ESTABELECIDO'	, 'CDPTESTAB'})
	aadd( aStru , {'NM_RAZAO_SOCIAL'			, 'RAZAOSOC'})
	aadd( aStru , {'NR_INSCRICAO_MUNICIPAL'		, 'INSCMUN'})
	aadd( aStru , {'NM_INSCRICAO_MUNICIPAL_DV'	, 'INSCMUNDV'})
	aadd( aStru , {'NR_CNPJ_CPF'				, 'NRCNPJCPF'})
	aadd( aStru , {'FL_ISENTO'					, 'ISENTO'})
	aadd( aStru , {'NR_INSCRICAO_ESTADUAL'		, 'INSCESTAD'})
	aadd( aStru , {'CD_CEP'						, 'CEP'})
	aadd( aStru , {'NM_TIPO_LOGRADOURO'			, 'TIPOLOGRAD'})
	aadd( aStru , {'NM_TITULO_LOGRADOURO'		, 'TITLOGRAD'})
	aadd( aStru , {'NM_LOGRADOURO'				, 'LOGRADOURO'})
	aadd( aStru , {'NM_COMPL_LOGRADOURO'		, 'COMPLOGRAD'})
	aadd( aStru , {'NR_LOGRADOURO'				, 'NRLOGRAD'})
	aadd( aStru , {'NM_BAIRRO'					, 'BAIRRO'})
	aadd( aStru , {'CD_ESTADO'					, 'ESTADO'})
	aadd( aStru , {'NM_CIDADE'					, 'CIDADE'})
	aadd( aStru , {'CD_LOCAL_PRESTACAO'			, 'LOCALPREST'})
	aadd( aStru , {'VL_BASE_CALCULO'			, 'VLBSCALC'})
	aadd( aStru , {'FL_SIMPLES'					, 'SIMPLES'})
	aadd( aStru , {'VL_ALIQUOTA'				, 'ALIQ'})
	aadd( aStru , {'IC_ORIGEM_DADOS'			, 'ORIGEM'})

//CONSTRUCAO CIVIL - Serviço Prestado para Tomador Pessoa Física - Com Obra (X | 4)
elseif cIndLay == 'X|4' //13cmps
	aadd( aStru , {'CD_INDICADOR'				, 'INDICADOR'})
	aadd( aStru , {'NR_LAYOUT'					, 'LAYOUT'})
	aadd( aStru , {'NR_DOC_NF_INICIAL'			, 'DOCINI'})
	aadd( aStru , {'NR_DOC_NF_SERIE'			, 'DOCSERIE'})
	aadd( aStru , {'NR_DOC_NF_FINAL'			, 'DOCFIN'})
	aadd( aStru , {'DT_EMISSAO_NF'				, 'EMISSAO'})
	aadd( aStru , {'TP_DOC_NF'					, 'TPDOCNF'})
	aadd( aStru , {'VL_DOC_NF'					, 'VLDOCNF'})
	aadd( aStru , {'CD_ATIVIDADE'				, 'ATIVIDADE'})
	aadd( aStru , {'CD_TIPO_CADASTRO'			, 'TIPOCADAST'})
	aadd( aStru , {'CD_LOCAL_PRESTACAO'			, 'LOCALPREST'})
	aadd( aStru , {'VL_BASE_CALCULO'			, 'VLBSCALC'})
	aadd( aStru , {'CD_ALVARA'					, 'ALVARA'})
	aadd( aStru , {'IC_ORIGEM_DADOS'			, 'ORIGEM'})

//CONSTRUCAO CIVIL - Serviço Prestado para Tomador Pessoa Jurídica - Com Obra (X | 5)
elseif cIndLay == 'X|5' //30cmps
	aadd( aStru , {'CD_INDICADOR'				, 'INDICADOR'})
	aadd( aStru , {'NR_LAYOUT'					, 'LAYOUT'})
	aadd( aStru , {'NR_DOC_NF_INICIAL'			, 'DOCINI'})
	aadd( aStru , {'NR_DOC_NF_SERIE'			, 'DOCSERIE'})
	aadd( aStru , {'NR_DOC_NF_FINAL'			, 'DOCFIN'})
	aadd( aStru , {'DT_EMISSAO_NF'				, 'EMISSAO'})
	aadd( aStru , {'TP_DOC_NF'					, 'TPDOCNF'})
	aadd( aStru , {'VL_DOC_NF'					, 'VLDOCNF'})
	aadd( aStru , {'CD_ATIVIDADE'				, 'ATIVIDADE'})
	aadd( aStru , {'CD_TIPO_CADASTRO'			, 'TIPOCADAST'})
	aadd( aStru , {'CD_PREST_TOM_ESTABELECIDO'	, 'CDPTESTAB'})
	aadd( aStru , {'NM_RAZAO_SOCIAL'			, 'RAZAOSOC'})
	aadd( aStru , {'NR_INSCRICAO_MUNICIPAL'		, 'INSCMUN'})
	aadd( aStru , {'NM_INSCRICAO_MUNICIPAL_DV'	, 'INSCMUNDV'})
	aadd( aStru , {'NR_CNPJ_CPF'				, 'NRCNPJCPF'})
	aadd( aStru , {'FL_ISENTO'					, 'ISENTO'})
	aadd( aStru , {'NR_INSCRICAO_ESTADUAL'		, 'INSCESTAD'})
	aadd( aStru , {'CD_CEP'						, 'CEP'})
	aadd( aStru , {'NM_TIPO_LOGRADOURO'			, 'TIPOLOGRAD'})
	aadd( aStru , {'NM_TITULO_LOGRADOURO'		, 'TITLOGRAD'})
	aadd( aStru , {'NM_LOGRADOURO'				, 'LOGRADOURO'})
	aadd( aStru , {'NM_COMPL_LOGRADOURO'		, 'COMPLOGRAD'})
	aadd( aStru , {'NR_LOGRADOURO'				, 'NRLOGRAD'})
	aadd( aStru , {'NM_BAIRRO'					, 'BAIRRO'})
	aadd( aStru , {'CD_ESTADO'					, 'ESTADO'})
	aadd( aStru , {'NM_CIDADE'					, 'CIDADE'})
	aadd( aStru , {'CD_LOCAL_PRESTACAO'			, 'LOCALPREST'})
	aadd( aStru , {'VL_BASE_CALCULO'			, 'VLBSCALC'})
	aadd( aStru , {'CD_ALVARA'					, 'ALVARA'})
	aadd( aStru , {'IC_ORIGEM_DADOS'			, 'ORIGEM'})

//CONSTRUCAO CIVIL - Serviço Tomado de Prestador Residente no País Com Nota Fiscal - Com Obra (H | 6)
elseif cIndLay == 'H|6' //30cmps
	aadd( aStru , {'CD_INDICADOR'				, 'INDICADOR'})
	aadd( aStru , {'NR_LAYOUT'					, 'LAYOUT'})
	aadd( aStru , {'NR_DOC_NF_INICIAL'			, 'DOCINI'})
	aadd( aStru , {'NR_DOC_NF_SERIE'			, 'DOCSERIE'})
	aadd( aStru , {'DT_EMISSAO_NF'				, 'EMISSAO'})
	aadd( aStru , {'TP_DOC_NF'					, 'TPDOCNF'})
	aadd( aStru , {'VL_DOC_NF'					, 'VLDOCNF'})
	aadd( aStru , {'CD_ATIVIDADE'				, 'ATIVIDADE'})
	aadd( aStru , {'CD_TIPO_CADASTRO'			, 'TIPOCADAST'})
	aadd( aStru , {'CD_PREST_TOM_ESTABELECIDO'	, 'CDPTESTAB'})
	aadd( aStru , {'NM_RAZAO_SOCIAL'			, 'RAZAOSOC'})
	aadd( aStru , {'NR_INSCRICAO_MUNICIPAL'		, 'INSCMUN'})
	aadd( aStru , {'NM_INSCRICAO_MUNICIPAL_DV'	, 'INSCMUNDV'})
	aadd( aStru , {'NR_CNPJ_CPF'				, 'NRCNPJCPF'})
	aadd( aStru , {'FL_ISENTO'					, 'ISENTO'})
	aadd( aStru , {'NR_INSCRICAO_ESTADUAL'		, 'INSCESTAD'})
	aadd( aStru , {'CD_CEP'						, 'CEP'})
	aadd( aStru , {'NM_TIPO_LOGRADOURO'			, 'TIPOLOGRAD'})
	aadd( aStru , {'NM_LOGRADOURO'				, 'LOGRADOURO'})
	aadd( aStru , {'NM_COMPL_LOGRADOURO'		, 'COMPLOGRAD'})
	aadd( aStru , {'NR_LOGRADOURO'				, 'NRLOGRAD'})
	aadd( aStru , {'NM_BAIRRO'					, 'BAIRRO'})
	aadd( aStru , {'CD_ESTADO'					, 'ESTADO'})
	aadd( aStru , {'NM_CIDADE'					, 'CIDADE'})
	aadd( aStru , {'CD_LOCAL_PRESTACAO'			, 'LOCALPREST'})
	aadd( aStru , {'VL_BASE_CALCULO'			, 'VLBSCALC'})
	aadd( aStru , {'CD_ALVARA'					, 'ALVARA'})
	aadd( aStru , {'FL_SIMPLES'					, 'SIMPLES'})
	aadd( aStru , {'VL_ALIQUOTA'				, 'ALIQ'})
	aadd( aStru , {'IC_ORIGEM_DADOS'			, 'ORIGEM'})

//ORGAO PUBLICO - Serviço Tomado (D | 1)
elseif cIndLay == 'D|1' //30cmps
	aadd( aStru , {'CD_INDICADOR'				, 'INDICADOR'})
	aadd( aStru , {'NR_LAYOUT'					, 'LAYOUT'})
	aadd( aStru , {'NR_DOC_NF_INICIAL'			, 'DOCINI'})
	aadd( aStru , {'NR_DOC_NF_SERIE'			, 'DOCSERIE'})
	aadd( aStru , {'DT_EMISSAO_NF'				, 'EMISSAO'})
	aadd( aStru , {'TP_DOC_NF'					, 'TPDOCNF'})
	aadd( aStru , {'VL_DOC_NF'					, 'VLDOCNF'})
	aadd( aStru , {'CD_ATIVIDADE'				, 'ATIVIDADE'})
	aadd( aStru , {'CD_TIPO_CADASTRO'			, 'TIPOCADAST'})
	aadd( aStru , {'CD_PREST_TOM_ESTABELECIDO'	, 'CDPTESTAB'})
	aadd( aStru , {'NM_RAZAO_SOCIAL'			, 'RAZAOSOC'})
	aadd( aStru , {'NR_INSCRICAO_MUNICIPAL'		, 'INSCMUN'})
	aadd( aStru , {'NM_INSCRICAO_MUNICIPAL_DV'	, 'INSCMUNDV'})
	aadd( aStru , {'NR_CNPJ_CPF'				, 'NRCNPJCPF'})
	aadd( aStru , {'FL_ISENTO'					, 'ISENTO'})
	aadd( aStru , {'NR_INSCRICAO_ESTADUAL'		, 'INSCESTAD'})
	aadd( aStru , {'CD_CEP'						, 'CEP'})
	aadd( aStru , {'NM_TIPO_LOGRADOURO'			, 'TIPOLOGRAD'})
	aadd( aStru , {'NM_TITULO_LOGRADOURO'		, 'TITLOGRAD'})
	aadd( aStru , {'NM_LOGRADOURO'				, 'LOGRADOURO'})
	aadd( aStru , {'NM_COMPL_LOGRADOURO'		, 'COMPLOGRAD'})
	aadd( aStru , {'NR_LOGRADOURO'				, 'NRLOGRAD'})
	aadd( aStru , {'NM_BAIRRO'					, 'BAIRRO'})
	aadd( aStru , {'CD_ESTADO'					, 'ESTADO'})
	aadd( aStru , {'NM_CIDADE'					, 'CIDADE'})
	aadd( aStru , {'CD_PAIS'					, 'PAIS'})
	aadd( aStru , {'CD_LOCAL_PRESTACAO'			, 'LOCALPREST'})
	aadd( aStru , {'FL_SIMPLES'					, 'SIMPLES'})
	aadd( aStru , {'VL_ALIQUOTA'				, 'ALIQ'})
	aadd( aStru , {'IC_ORIGEM_DADOS'			, 'ORIGEM'})

//PRESTADOR - Serviço Prestado para Pessoa Física (C | 1)
elseif cIndLay == 'C|1' //12cmps
	aadd( aStru , {'CD_INDICADOR'				, 'INDICADOR'})
	aadd( aStru , {'NR_LAYOUT'					, 'LAYOUT'})
	aadd( aStru , {'NR_DOC_NF_INICIAL'			, 'DOCINI'})
	aadd( aStru , {'NR_DOC_NF_SERIE'			, 'DOCSERIE'})
	aadd( aStru , {'NR_DOC_NF_FINAL'			, 'DOCFIN'})
	aadd( aStru , {'DT_EMISSAO_NF'				, 'EMISSAO'})
	aadd( aStru , {'TP_DOC_NF'					, 'TPDOCNF'})
	aadd( aStru , {'VL_DOC_NF'					, 'VLDOCNF'})
	aadd( aStru , {'CD_ATIVIDADE'				, 'ATIVIDADE'})
	aadd( aStru , {'CD_TIPO_CADASTRO'			, 'TIPOCADAST'})
	aadd( aStru , {'CD_LOCAL_PRESTACAO'			, 'LOCALPREST'})
	aadd( aStru , {'IC_ORIGEM_DADOS'			, 'ORIGEM'})

//PRESTADOR - Serviço Prestado para Tomador Fora do País (C | 2)
elseif cIndLay == 'C|2' //16cmps
	aadd( aStru , {'CD_INDICADOR'				, 'INDICADOR'})
	aadd( aStru , {'NR_LAYOUT'					, 'LAYOUT'})
	aadd( aStru , {'NR_DOC_NF_INICIAL'			, 'DOCINI'})
	aadd( aStru , {'NR_DOC_NF_SERIE'			, 'DOCSERIE'})
	aadd( aStru , {'NR_DOC_NF_FINAL'			, 'DOCFIN'})
	aadd( aStru , {'DT_EMISSAO_NF'				, 'EMISSAO'})
	aadd( aStru , {'TP_DOC_NF'					, 'TPDOCNF'})
	aadd( aStru , {'VL_DOC_NF'					, 'VLDOCNF'})
	aadd( aStru , {'CD_ATIVIDADE'				, 'ATIVIDADE'})
	aadd( aStru , {'CD_TIPO_CADASTRO'			, 'TIPOCADAST'})
	aadd( aStru , {'CD_PREST_TOM_ESTABELECIDO'	, 'CDPTESTAB'})
	aadd( aStru , {'CD_PAIS'					, 'PAIS'})
	aadd( aStru , {'NM_RAZAO_SOCIAL'			, 'RAZAOSOC'})
	aadd( aStru , {'NM_OBSERVACAO'				, 'OBS'})
	aadd( aStru , {'CD_LOCAL_PRESTACAO'			, 'LOCALPREST'})
	aadd( aStru , {'IC_ORIGEM_DADOS'			, 'ORIGEM'})

//Prestador - Serviço Prestado para Pessoa Jurídica (C | 3)
elseif cIndLay == 'C|3' //28cmps
	aadd( aStru , {'CD_INDICADOR'				, 'INDICADOR'})
	aadd( aStru , {'NR_LAYOUT'					, 'LAYOUT'})
	aadd( aStru , {'NR_DOC_NF_INICIAL'			, 'DOCINI'})
	aadd( aStru , {'NR_DOC_NF_SERIE'			, 'DOCSERIE'})
	aadd( aStru , {'NR_DOC_NF_FINAL'			, 'DOCFIN'})
	aadd( aStru , {'DT_EMISSAO_NF'				, 'EMISSAO'})
	aadd( aStru , {'TP_DOC_NF'					, 'TPDOCNF'})
	aadd( aStru , {'VL_DOC_NF'					, 'VLDOCNF'})
	aadd( aStru , {'CD_ATIVIDADE'				, 'ATIVIDADE'})
	aadd( aStru , {'CD_TIPO_CADASTRO'			, 'TIPOCADAST'})
	aadd( aStru , {'CD_PREST_TOM_ESTABELECIDO'	, 'CDPTESTAB'})
	aadd( aStru , {'NM_RAZAO_SOCIAL'			, 'RAZAOSOC'})
	aadd( aStru , {'NR_INSCRICAO_MUNICIPAL'		, 'INSCMUN'})
	aadd( aStru , {'NM_INSCRICAO_MUNICIPAL_DV'	, 'INSCMUNDV'})
	aadd( aStru , {'NR_CNPJ_CPF'				, 'NRCNPJCPF'})
	aadd( aStru , {'FL_ISENTO'					, 'ISENTO'})
	aadd( aStru , {'NR_INSCRICAO_ESTADUAL'		, 'INSCESTAD'})
	aadd( aStru , {'CD_CEP'						, 'CEP'})
	aadd( aStru , {'NM_TIPO_LOGRADOURO'			, 'TIPOLOGRAD'})
	aadd( aStru , {'NM_TITULO_LOGRADOURO'		, 'TITLOGRAD'})
	aadd( aStru , {'NM_LOGRADOURO'				, 'LOGRADOURO'})
	aadd( aStru , {'NM_COMPL_LOGRADOURO'		, 'COMPLOGRAD'})
	aadd( aStru , {'NR_LOGRADOURO'				, 'NRLOGRAD'})
	aadd( aStru , {'NM_BAIRRO'					, 'BAIRRO'})
	aadd( aStru , {'CD_ESTADO'					, 'ESTADO'})
	aadd( aStru , {'NM_CIDADE'					, 'CIDADE'})
	aadd( aStru , {'CD_LOCAL_PRESTACAO'			, 'LOCALPREST'})
	aadd( aStru , {'IC_ORIGEM_DADOS'			, 'ORIGEM'})

//TOMADOR - Serviço Tomado de Prestador Residente no País Com Nota Fiscal (T | 1)
elseif cIndLay == 'T|1' //29cmps
	aadd( aStru , {'CD_INDICADOR'				, 'INDICADOR'})
	aadd( aStru , {'NR_LAYOUT'					, 'LAYOUT'})
	aadd( aStru , {'NR_DOC_NF_INICIAL'			, 'DOCINI'})
	aadd( aStru , {'NR_DOC_NF_SERIE'			, 'DOCSERIE'})
	aadd( aStru , {'DT_EMISSAO_NF'				, 'EMISSAO'})
	aadd( aStru , {'TP_DOC_NF'					, 'TPDOCNF'})
	aadd( aStru , {'VL_DOC_NF'					, 'VLDOCNF'})
	aadd( aStru , {'CD_ATIVIDADE'				, 'ATIVIDADE'})
	aadd( aStru , {'CD_TIPO_CADASTRO'			, 'TIPOCADAST'})
	aadd( aStru , {'CD_PREST_TOM_ESTABELECIDO'	, 'CDPTESTAB'})
	aadd( aStru , {'NM_RAZAO_SOCIAL'			, 'RAZAOSOC'})
	aadd( aStru , {'NR_INSCRICAO_MUNICIPAL'		, 'INSCMUN'})
	aadd( aStru , {'NM_INSCRICAO_MUNICIPAL_DV'	, 'INSCMUNDV'})
	aadd( aStru , {'NR_CNPJ_CPF'				, 'NRCNPJCPF'})
	aadd( aStru , {'FL_ISENTO'					, 'ISENTO'})
	aadd( aStru , {'NR_INSCRICAO_ESTADUAL'		, 'INSCESTAD'})
	aadd( aStru , {'CD_CEP'						, 'CEP'})
	aadd( aStru , {'NM_TIPO_LOGRADOURO'			, 'TIPOLOGRAD'})
	aadd( aStru , {'NM_TITULO_LOGRADOURO'		, 'TITLOGRAD'})
	aadd( aStru , {'NM_LOGRADOURO'				, 'LOGRADOURO'})
	aadd( aStru , {'NM_COMPL_LOGRADOURO'		, 'COMPLOGRAD'})
	aadd( aStru , {'NR_LOGRADOURO'				, 'NRLOGRAD'})
	aadd( aStru , {'NM_BAIRRO'					, 'BAIRRO'})
	aadd( aStru , {'CD_ESTADO'					, 'ESTADO'})
	aadd( aStru , {'NM_CIDADE'					, 'CIDADE'})
	aadd( aStru , {'CD_LOCAL_PRESTACAO'			, 'LOCALPREST'})
	aadd( aStru , {'FL_SIMPLES'					, 'SIMPLES'})
	aadd( aStru , {'VL_ALIQUOTA'				, 'ALIQ'})
	aadd( aStru , {'IC_ORIGEM_DADOS'			, 'ORIGEM'})

//TOMADOR - Serviço Tomado de Prestador Residente no País Sem Nota Fiscal (P | 2)
elseif cIndLay == 'P|2' //28cmps
	aadd( aStru , {'CD_INDICADOR'				, 'INDICADOR'})
	aadd( aStru , {'NR_LAYOUT'					, 'LAYOUT'})
	aadd( aStru , {'NR_DOC_NF_INICIAL'			, 'DOCINI'})
	aadd( aStru , {'DT_EMISSAO_NF'				, 'EMISSAO'})
	aadd( aStru , {'TP_DOC_NF'					, 'TPDOCNF'})
	aadd( aStru , {'VL_DOC_NF'					, 'VLDOCNF'})
	aadd( aStru , {'CD_ATIVIDADE'				, 'ATIVIDADE'})
	aadd( aStru , {'CD_TIPO_CADASTRO'			, 'TIPOCADAST'})
	aadd( aStru , {'CD_PREST_TOM_ESTABELECIDO'	, 'CDPTESTAB'})
	aadd( aStru , {'NM_RAZAO_SOCIAL'			, 'RAZAOSOC'})
	aadd( aStru , {'NR_INSCRICAO_MUNICIPAL'		, 'INSCMUN'})
	aadd( aStru , {'NM_INSCRICAO_MUNICIPAL_DV'	, 'INSCMUNDV'})
	aadd( aStru , {'NR_CNPJ_CPF'				, 'NRCNPJCPF'})
	aadd( aStru , {'FL_ISENTO'					, 'ISENTO'})
	aadd( aStru , {'NR_INSCRICAO_ESTADUAL'		, 'INSCESTAD'})
	aadd( aStru , {'CD_CEP'						, 'CEP'})
	aadd( aStru , {'NM_TIPO_LOGRADOURO'			, 'TIPOLOGRAD'})
	aadd( aStru , {'NM_TITULO_LOGRADOURO'		, 'TITLOGRAD'})
	aadd( aStru , {'NM_LOGRADOURO'				, 'LOGRADOURO'})
	aadd( aStru , {'NM_COMPL_LOGRADOURO'		, 'COMPLOGRAD'})
	aadd( aStru , {'NR_LOGRADOURO'				, 'NRLOGRAD'})
	aadd( aStru , {'NM_BAIRRO'					, 'BAIRRO'})
	aadd( aStru , {'CD_ESTADO'					, 'ESTADO'})
	aadd( aStru , {'NM_CIDADE'					, 'CIDADE'})
	aadd( aStru , {'CD_LOCAL_PRESTACAO'			, 'LOCALPREST'})
	aadd( aStru , {'FL_SIMPLES'					, 'SIMPLES'})
	aadd( aStru , {'VL_ALIQUOTA'				, 'ALIQ'})
	aadd( aStru , {'IC_ORIGEM_DADOS'			, 'ORIGEM'})

//TOMADOR - Serviço Tomado de Prestador Residente Fora do País Sem Nota Fiscal (P | 3)
elseif cIndLay == 'P|3' //13 cmps
	aadd( aStru , {'CD_INDICADOR'				, 'INDICADOR'})
	aadd( aStru , {'NR_LAYOUT'					, 'LAYOUT'})
	aadd( aStru , {'NR_DOC_NF_INICIAL'			, 'DOCINI'})
	aadd( aStru , {'DT_EMISSAO_NF'				, 'EMISSAO'})
	aadd( aStru , {'TP_DOC_NF'					, 'TPDOCNF'})
	aadd( aStru , {'VL_DOC_NF'					, 'VLDOCNF'})
	aadd( aStru , {'CD_ATIVIDADE'				, 'ATIVIDADE'})
	aadd( aStru , {'CD_TIPO_CADASTRO'			, 'TIPOCADAST'})
	aadd( aStru , {'CD_PAIS'					, 'PAIS'})
	aadd( aStru , {'NM_RAZAO_SOCIAL'			, 'RAZAOSOC'})
	aadd( aStru , {'CD_LOCAL_PRESTACAO'			, 'LOCALPREST'})
	aadd( aStru , {'NM_OBSERVACAO'				, 'OBS'})
	aadd( aStru , {'IC_ORIGEM_DADOS'			, 'ORIGEM'})

//TOMADOR - Serviço Tomado de Prestador Residente Fora do País Com Nota Fiscal (F | 4)
elseif cIndLay == 'F|4' //13 cmps
	aadd( aStru , {'CD_INDICADOR'				, 'INDICADOR'})
	aadd( aStru , {'NR_LAYOUT'					, 'LAYOUT'})
	aadd( aStru , {'NR_DOC_NF_INICIAL'			, 'DOCINI'})
	aadd( aStru , {'NR_DOC_NF_SERIE'			, 'DOCSERIE'})
	aadd( aStru , {'DT_EMISSAO_NF'				, 'EMISSAO'})
	aadd( aStru , {'TP_DOC_NF'					, 'TPDOCNF'})
	aadd( aStru , {'VL_DOC_NF'					, 'VLDOCNF'})
	aadd( aStru , {'CD_ATIVIDADE'				, 'ATIVIDADE'})
	aadd( aStru , {'CD_PAIS'					, 'PAIS'})
	aadd( aStru , {'NM_RAZAO_SOCIAL'			, 'RAZAOSOC'})
	aadd( aStru , {'NM_OBSERVACAO'				, 'OBS'})
	aadd( aStru , {'CD_LOCAL_PRESTACAO'			, 'LOCALPREST'})
	aadd( aStru , {'IC_ORIGEM_DADOS'			, 'ORIGEM'})

endif

if lCab
	nPos := 1
	cConcat := "||"
else
	nPos := 2
	cConcat := ","
endif

for nlA := 1 to Len( aStru )
	if valtype( aStru[nlA][nPos] ) <> "U"
		cCmps += aStru[nlA][nPos] + cConcat
	endif
next nlA

//Retira o ultimo separador
cCmps := substr( alltrim(cCmps) , 1 , (len(alltrim(cCmps)) - len(cConcat)) )

Return cCmps

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFENCGISS
Gera os arquivos finais (TAFFILGISS) e encerra as estruturas temporarias
@Param 
@Return lRet

@Author Denis Souza
@Since 15/10/2021
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function TAFENCGISS( aWizard, aIndLay, lCanBulk, cTBulk, oBulk, oTT )

local lOK 	 As Logical
local lRet 	 As Logical
local cquery As char

default aWizard  := {}
default aIndLay  := {}
default lCanBulk := .F.
default oBulk 	 := Nil
default cTBulk 	 := ''
default oTT 	 := Nil

lRet := .T.

//mecanismo para gerar arquivos atraves da populacao do bulk
if lCanBulk
	if valtype( oBulk ) == 'O'
		lOk := oBulk:Close() //verdadeiro se conseguiu fazer o flush dos dados
		if lOk
			lRet := TAFFILGISS( aIndLay , cTBulk, aWizard ) //Gera os arquivos .DAT
		endif
		oBulk:Destroy()
		FreeObj(oBulk)
		oBulk := nil
	endif
	If Select(cTBulk) > 0
		(cTBulk)->(DBCloseArea())

		cquery := "DROP TABLE " + cTBulk
		if TcSqlExec(cQuery) <> 0
		endif
		//Forcar o Commit para oracle (mesmo sem ter iniciado transacao)
		If 'ORACLE' $ Alltrim(Upper(TcGetDb()))
			if TCSQLExec("commit") <> 0
			endif
		Endif
	endif
else //mecanismo para gerar arquivos atraves da populacao da tabela temporaria
	if Valtype( oTT ) == 'O'
		lRet := TAFFILGISS( aIndLay , oTT:GetRealName(), aWizard ) //Gera os arquivos .DAT
		oTT:Delete()
		FreeObj(oTT)
		oTT := nil		
	endif
endif

Return lRet
