#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"

#DEFINE DMPAPER_A4 9 // A4 210 x 297 mm
#DEFINE __RELIMP GETMV("MV_RELT")

Static cBanco := AllTrim( TCGetDB() )

//--------------------------------------------------------------------
/*/{Protheus.doc} PLSR002
Impressão de relatório de Beneficiários Ativos

@author Raphael Gonçalves
@since 2025-06
@version 1.0
/*/
//-------------------------------------------------------------------
Function PLSR002(cmv_par01, cmv_par02, cmv_par03, cmv_par04, lWeb, cPathRelW)

Local aArea				:= GetArea()
Local aSays				:= {}
Local aButtons			:= {}
Local nRet				:= 0
Local cPerg 			:= PadR("PLSR002",Len(SX1->X1_GRUPO))
Local lSucesso			:= .T.
Local aRecDetal			:= {}
Local cMsgErro			:= ""
Local cCodint			:= ""
Local cCodemp			:= ""

Private cNomeArq			:= "beneficiarios_ativos_"+DtoS(Date())+SubStr(Time(),1,2)+SubStr(Time(),4,2)+SubStr(Time(),7,2)
Private oPrinter			:= Nil
Private lEnd				:= .F.
Private oPrint				:= Nil					//Nome do Objeto a ser criado a classe de Impressão
Private lAdjustToLegacy 	:= .T.					//Se .T. recalcula as coordenadas para manter o legado de proporções com a classe TMSPrinter
Private lDisableSetup		:= .T.					//Se .T. não exibe a tela de Setup
Private lTReport			:= .F.					//Indica que a classe foi chamada pelo TReport
Private oPrinterSetup		:= Nil					//Objeto FWPrintSetup instanciado pelo usuário
Private cPrinter			:= ""					//Impressora destino "forçada" pelo usuário
Private lServer				:= .T.					//Indica impressão via Server (.REL Não será copiado para o Client)
Private lPDFAsPNG			:= .F.					//Se .T. Indica que será gerado o PDF no formato PNG
Private lRaw				:= .F.					//.T. indica impressão RAW/PCL, enviando para o dispositivo de impressão caracteres binários(RAW) ou caracteres programáveis específicos da impressora(PCL)                                                                                                        
Private lViewPDF			:= .T.					//Quando o tipo de impressão for PDF, define se arquivo será exibido após a impressão
Private nQtdCopy			:= 2					//Define a quantidade de cópias a serem impressas
Private cPathInServer		:= ""

Default cmv_par01 := ""
Default cmv_par02 := ""
Default cmv_par03 := ""
Default cmv_par04 := ""
Default lWeb := .F.
Default cPathRelW := GETMV("MV_RELT")

If !lWeb
	aAdd(aSays,OemToAnsi("Este programa tem como objetivo a Geração de um relatório de Beneficiários Ativos"	))
	aAdd(aSays,OemToAnsi(""))
	aAdd(aSays,OemToAnsi(""))
	aAdd(aSays,OemToAnsi(""))
	aAdd(aSays,OemToAnsi("Clique no botão de OK para iniciar o processo."	))
	aAdd(aButtons, { 1,.T.,{|o| FechaBatch(),nRet:=1						}})
	aAdd(aButtons, { 2,.T.,{|o| FechaBatch()								}})
	FormBatch( OemToAnsi("Beneficiários Ativos"), aSays, aButtons )
	lSucesso := ( nRet == 1 ) .And. Pergunte(cPerg,.T.)
Else
	MV_PAR01 := cmv_par01
	MV_PAR02 := cmv_par02
	MV_PAR03 := cmv_par03
	MV_PAR04 := cmv_par04
EndIf

If lSucesso
    cMsgErro	:= IIF(Empty(AllTrim(MV_PAR01)), "Favor informar o código da Operadora", "")
	lSucesso	:= IIF(Empty(cMsgErro), .T., .F.)

	If lSucesso
		cMsgErro	:= IIF(Empty(AllTrim(MV_PAR02)), "Favor informar o código da Empresa", "")
		lSucesso	:= IIF(Empty(cMsgErro), .T., .F.)
	EndIf

	If !lWeb .And. !lSucesso
		MsgInfo(cMsgErro)
    Endif

EndIf
    
If lSucesso
    
    cCodint		:= MV_PAR01
    cCodemp		:= MV_PAR02
	cContrato	:= MV_PAR03
	cSubCon		:= MV_PAR04

	If lWeb 
		aRecDetal	:= EVRDAFil(cCodint,cCodemp, cContrato, cSubCon) 
	Else
		Processa({|| aRecDetal	:= EVRDAFil(cCodint, cCodemp, cContrato, cSubCon)  }, "Aguarde...Preparando Dados Para Impressão")
	EndIf

	cMsgErro	:= IIF(Len(aRecDetal) == 0, "Não ha Dados Para serem Exibidos", "")
	lSucesso	:= IIF(Empty(cMsgErro), .T., .F.)	
	
	If !lWeb .And. !lSucesso
		MsgInfo(cMsgErro)
	EndIf
	
	If lSucesso	
		    
		If lWeb
			
			cPathInServer := cPathRelW //"\web\pp\imagens-pls\relatorios\"
			
			oPrint:= FWMSPrinter():New(cNomeArq,IMP_PDF,lAdjustToLegacy,cPathInServer,lDisableSetup,lTReport,/*@oPrinterSetup*/,cPrinter,lServer,lPDFAsPNG,lRaw,lViewPDF,nQtdCopy)
			oPrint:SetResolution(72)		
			oPrint:SetLandscape() // Paisagem
			oPrint:SetPaperSize(DMPAPER_A4)		//Tamanho do Papel A4
			oPrint:SetMargin(00,00,00,00)		//Margem da Folha 
			oPrint:cPathPDF:= cPathInServer		//Diretório do Arquivo PDF
			oPrint:lInJob  := lWeb
			oPrint:lServer := lWeb			
			
			SPImpBenAt(oPrint,lEnd,cCodint,cCodemp,aRecDetal)
		
		Else
			
			lAdjustToLegacy := .T.
			lDisableSetup	:= .T.
			
			oPrint:= FWMSPrinter():New(cNomeArq+".rel",IMP_PDF,lAdjustToLegacy,"",lDisableSetup,,,,,,.F.,)
			oPrint:SetResolution(72)
			oPrint:SetLandscape() // Paisagem
			oPrint:SetPaperSize(DMPAPER_A4) 	//Tamanho do Papel A4
			oPrint:SetMargin(00,00,00,00)		//Margem da Folha
			oPrint:Setup()
		
			If oPrint:nModalResult == 1
			
				oPrint:SetLandscape() // Paisagem
				oPrint:SetResolution(72)
				oPrint:SetPaperSize(DMPAPER_A4)
				oPrint:SetMargin(00,00,00,00)
			
				Processa({|| SPImpBenAt(oPrint,lEnd,cCodint,cCodemp,aRecDetal) },"Aguarde...Processando Relatório de Beneficiários Ativos")
		
			EndIf
		
		EndIf
	
	EndIf

EndIf

aRet := {lSucesso,cMsgErro,cPathInServer+cNomeArq+".pdf",cNomeArq+".pdf",cNomeArq+".rel"}

RestArea(aArea)

Return(aRet)

//--------------------------------------------------------------------
/*/{Protheus.doc} SPImpBenAt
Impressão dos Beneficiários Ativos

@author Raphael Gonçalves
@since 2025-06
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SPImpBenAt(oPrint,lEnd,cCodint,cCodemp,aRecDetal)

Local aArea			:= GetArea()
Local nI			:= 0
Local oFont13		:= TFont():New("Arial",,13,,.F.,,,,.F.,.F.)
Local oFont18n		:= TFont():New("Arial",,18,,.T.,,,,.F.,.F.)
Local oFont20n		:= TFont():New("Arial",,20,,.T.,,,,.F.,.F.)
Local oFont13n		:= TFont():New("Arial",,13,,.T.,,,,.F.,.F.)

DbSelectArea("BA0")
BA0->(DbSetOrder(1))
If BA0->(DbSeek(xFilial("BA0")+PLSINTPAD()))

	//Inicia Pagina
	oPrint:StartPage() 
	
	oPrint:Say(0220,1000,"RELATÓRIO DE BENEFICIÁRIOS ATIVOS",oFont20n,100)
	oPrint:Say(0330,1000,cCodemp+" - "+Posicione("BG9",1,xFilial("BG9")+cCodint+cCodemp,"BG9_DESCRI"),oFont18n,100)
	
	oPrint:Say(0550,0250,"NOME DO",oFont13N,100) 
	oPrint:Say(0588,0250,"BENEFICIARIO",oFont13N,100)
	oPrint:Say(0550,0805,"CPF DO",oFont13N,100)
	oPrint:Say(0588,0805,"BENEFICIARIO",oFont13N,100)
	oPrint:Say(0550,1015,"MATRICULA",oFont13N,100)
	oPrint:Say(0550,1315,"CÓDIGO DO",oFont13N,100)
	oPrint:Say(0588,1315,"CONTRATO",oFont13N,100)
	oPrint:Say(0550,1565,"CÓDIGO DO",oFont13N,100)
	oPrint:Say(0588,1565,"SUBCONTRATO",oFont13N,100)
	oPrint:Say(0550,1790,"DESCRIÇÃO DO",oFont13N,100)
	oPrint:Say(0588,1790,"SUBCONTRATO",oFont13N,100)
	oPrint:Say(0550,2375,"VIGÊNCIA",oFont13N,100)
	oPrint:Say(0550,2580,"VALOR DA",oFont13N,100)
	oPrint:Say(0588,2580,"MENSALIDADE",oFont13N,100)
	
	nLinIni := 0630
	oPrint:Line(nLinIni,0240,nLinIni,2760)
	For nI:= 1 to Len(aRecDetal)
		//Linha Horizontal
		oPrint:Line(nLinIni+68,0240,nLinIni+68,2760)
		//Linha Vertical
		oPrint:Line(nLinIni ,0240 ,nLinIni+68,0240 )//1
		oPrint:Line(nLinIni ,0795 ,nLinIni+68,0795 )//2
		oPrint:Line(nLinIni ,1005 ,nLinIni+68,1005 )//3
		oPrint:Line(nLinIni ,1305 ,nLinIni+68,1305 )//4
		oPrint:Line(nLinIni ,1555 ,nLinIni+68,1555 )//5
		oPrint:Line(nLinIni ,1760 ,nLinIni+68,1760 )//6
		oPrint:Line(nLinIni ,2340 ,nLinIni+68,2340 )//7
		oPrint:Line(nLinIni ,2560 ,nLinIni+68,2560 )//8
		oPrint:Line(nLinIni ,2760 ,nLinIni+68,2760 )//9
		
		oPrint:Say(nLinIni+50,0250,SubStr(AllTrim(aRecDetal[nI,1]),1,30),oFont13,100) //NOME BENEFICIARIO
		oPrint:Say(nLinIni+50,0805,AllTrim(aRecDetal[nI,2]),oFont13,100) //CPF BENEFICIARIO
		oPrint:Say(nLinIni+50,1015,AllTrim(aRecDetal[nI,3]),oFont13,100) //MATRICULA
		oPrint:Say(nLinIni+50,1315,AllTrim(aRecDetal[nI,4]),oFont13,100) //CODIGO CONTRATO
		oPrint:Say(nLinIni+50,1565,AllTrim(aRecDetal[nI,5]),oFont13,100) //CODIGO SUBCONTRATO
		oPrint:Say(nLinIni+50,1790,SubStr(AllTrim(aRecDetal[nI,6]),1,30),oFont13,100) //DESCRICAO SUBCONTRATO
		oPrint:Say(nLinIni+50,2375,AllTrim(aRecDetal[nI,7]),oFont13,100) //VIGENCIA
		oPrint:Say(nLinIni+50,2580,"R$ "+AllTrim( TransForm( aRecDetal[nI,8] ,"@E 999,999,999,999,999.99" ) ),oFont13,100) //VALOR MENSALIDADE
		nLinIni += 68	
		
		If nLinIni > 2390
			oPrint:EndPage() // Finaliza a pagina
			oPrint:StartPage()
			oPrint:Say(0550,0250,"NOME DO",oFont13N,100) 
			oPrint:Say(0588,0250,"BENEFICIARIO",oFont13N,100)
			oPrint:Say(0550,0805,"CPF DO",oFont13N,100)
			oPrint:Say(0588,0805,"BENEFICIARIO",oFont13N,100)
			oPrint:Say(0550,1015,"MATRICULA",oFont13N,100)
			oPrint:Say(0550,1315,"CÓDIGO DO",oFont13N,100)
			oPrint:Say(0588,1315,"CONTRATO",oFont13N,100)
			oPrint:Say(0550,1565,"CÓDIGO DO",oFont13N,100)
			oPrint:Say(0588,1565,"SUBCONTRATO",oFont13N,100)
			oPrint:Say(0550,1790,"DESCRIÇÃO DO",oFont13N,100)
			oPrint:Say(0588,1790,"SUBCONTRATO",oFont13N,100)
			oPrint:Say(0550,2375,"VIGÊNCIA",oFont13N,100)
			oPrint:Say(0550,2580,"VALOR DA",oFont13N,100)
			oPrint:Say(0588,2580,"MENSALIDADE",oFont13N,100)
			nLinIni := 0630
			oPrint:Line(nLinIni,0240,nLinIni,2760)
		Endif  
		
	Next nI

	//Finaliza Pagina
	oPrint:EndPage()	
	oPrint:Print()

EndIf

FreeObj(oPrint)
oPrint := Nil

Sleep(4500)

RestArea(aArea)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} EVRDAFil
Monta a query para buscar os dados dos beneficiários ativos
@author Raphael Gonçalves
@since 2025-06
/*/
//-------------------------------------------------------------------
Static Function EVRDAFil(cCodint, cCodemp, cContrato, cSubCon)
Local 	aRet	:=	{}
Local 	cQuery	:=	""

cQuery := "SELECT "
cQuery += "	BT5.BT5_NUMCON COD_CONTRATO, "
cQuery += "	BQC.BQC_SUBCON COD_SUBCONTRATO, "
cQuery += "	TRIM(BQC.BQC_DESCRI) SUBCONTRATO, "
cQuery += iIf( cBanco $ "ORACLE/DB2/POSTGRES",;
	" BA1.BA1_CODINT || BA1.BA1_CODEMP || BA1.BA1_MATRIC || BA1.BA1_TIPREG || BA1.BA1_DIGITO MATRICULA,",;
	" BA1.BA1_CODINT + BA1.BA1_CODEMP + BA1.BA1_MATRIC + BA1.BA1_TIPREG + BA1.BA1_DIGITO MATRICULA,")

cQuery += "	TRIM(BA1.BA1_NOMUSR) NOME_BENEFICIARIO, "

cQuery += iIf( cBanco $ "ORACLE/DB2/POSTGRES",;
	"	SUBSTRING(BA1.BA1_DATINC,7,2)||'/'||SUBSTRING(BA1.BA1_DATINC,5,2)||'/'||SUBSTRING(BA1.BA1_DATINC,1,4) DATA_INCLUSAO, ",;
	"	SUBSTRING(BA1.BA1_DATINC,7,2)+'/'+SUBSTRING(BA1.BA1_DATINC,5,2)+'/'+SUBSTRING(BA1.BA1_DATINC,1,4) DATA_INCLUSAO, ")

cQuery += " CASE WHEN BA1.BA1_TIPUSU = 'T' THEN 'TITULAR' ELSE 'DEPENDENTE' END TIPO_BENEFICIARIO, "
cQuery += "	BA1.BA1_CPFUSR CPF_BENEFICIARIO, "

cQuery += iIf( cBanco $ "ORACLE/DB2/POSTGRES",;
	"	SUBSTRING(BA1.BA1_DATNAS,7,2)||'/'||SUBSTRING(BA1.BA1_DATNAS,5,2)||'/'||SUBSTRING(BA1.BA1_DATNAS,1,4) DATA_NASCIMENTO, ",;
	"	SUBSTRING(BA1.BA1_DATNAS,7,2)+'/'+SUBSTRING(BA1.BA1_DATNAS,5,2)+'/'+SUBSTRING(BA1.BA1_DATNAS,1,4) DATA_NASCIMENTO, ")

cQuery += "	CASE  BA1.BA1_CONSID "
cQuery += "		WHEN  'U' THEN  (SELECT BG3_DESBLO FROM "+RetSqlName("BG3")+" BG3 WHERE BG3.BG3_FILIAL = BA1.BA1_FILIAL AND BG3.BG3_CODBLO = BA1.BA1_MOTBLO AND BG3.D_E_L_E_T_ = ' ') "
cQuery += "		WHEN  'F' THEN  (SELECT BG1_DESBLO FROM "+RetSqlName("BG1")+" BG1 WHERE BG1.BG1_FILIAL = BA1.BA1_FILIAL AND BG1.BG1_CODBLO = BA1.BA1_MOTBLO AND BG1.D_E_L_E_T_ = ' ') "
cQuery += "		WHEN  'S' THEN  (SELECT BQU_DESBLO FROM "+RetSqlName("BQU")+" BQU WHERE BQU.BQU_FILIAL = BA1.BA1_FILIAL AND BQU.BQU_CODBLO = BA1.BA1_MOTBLO AND BQU.D_E_L_E_T_ = ' ') "
cQuery += "		ELSE ' ' "
cQuery += "	END MOTIVO_BLOQUEIO, "
cQuery += " BBU.BBU_VALFAI MENSALIDADE "
cQuery += "FROM "+RetSqlName("BA1")+" BA1 "
cQuery += "INNER JOIN "+RetSqlName("BA3")+" BA3	 "
cQuery += "  ON  BA3.BA3_FILIAL = BA1.BA1_FILIAL "
cQuery += "  AND BA3.BA3_CODINT = BA1.BA1_CODINT "
cQuery += "  AND BA3.BA3_CODEMP = BA1.BA1_CODEMP "
cQuery += "  AND BA3.BA3_CONEMP = BA1.BA1_CONEMP "
cQuery += "  AND BA3.BA3_VERCON = BA1.BA1_VERCON "
cQuery += "  AND BA3.BA3_SUBCON = BA1.BA1_SUBCON "
cQuery += "  AND BA3.BA3_VERSUB = BA1.BA1_VERSUB "
cQuery += "  AND BA3.BA3_MATRIC = BA1.BA1_MATRIC "
cQuery += "  AND BA3.D_E_L_E_T_ = ' '			 "
cQuery += "INNER JOIN "+RetSqlName("BG9")+" BG9	 "
cQuery += "  ON  BG9.BG9_FILIAL = BA3.BA3_FILIAL "
cQuery += "  AND BG9.BG9_CODINT = BA3.BA3_CODINT "
cQuery += "  AND BG9.BG9_CODIGO = BA3.BA3_CODEMP "
cQuery += "  AND BG9.D_E_L_E_T_ = ' ' 			 "
cQuery += "LEFT JOIN "+RetSqlName("BT5")+" BT5	 "
cQuery += "  ON  BT5.BT5_FILIAL = BA3.BA3_FILIAL "
cQuery += "  AND BT5.BT5_CODINT = BA3.BA3_CODINT "
cQuery += "  AND BT5.BT5_CODIGO = BA3.BA3_CODEMP "
cQuery += "  AND BT5.BT5_NUMCON = BA3.BA3_CONEMP "
cQuery += "  AND BT5.BT5_VERSAO = BA3.BA3_VERCON "
cQuery += "  AND BT5.D_E_L_E_T_ = ' '            "           
cQuery += "LEFT JOIN "+RetSqlName("BQC")+" BQC	 "
cQuery += "  ON  BQC.BQC_FILIAL = BA3.BA3_FILIAL "
cQuery += "  AND BQC.BQC_CODINT = BA3.BA3_CODINT "
cQuery += "  AND BQC.BQC_CODEMP = BA3.BA3_CODEMP "
cQuery += "  AND BQC.BQC_NUMCON = BA3.BA3_CONEMP "
cQuery += "  AND BQC.BQC_VERCON = BA3.BA3_VERCON "
cQuery += "  AND BQC.BQC_SUBCON = BA3.BA3_SUBCON "
cQuery += "  AND BQC.BQC_VERSUB = BA3.BA3_VERSUB "
cQuery += "  AND BQC.D_E_L_E_T_ = ' '            "
cQuery += "INNER JOIN "+RetSqlName("BI3")+" BI3	 "
cQuery += "  ON  BI3.BI3_FILIAL = BA3.BA3_FILIAL "
cQuery += "  AND BI3.BI3_CODINT = BA3.BA3_CODINT "
cQuery += "  AND BI3.BI3_VERSAO = BA3.BA3_VERSAO "
cQuery += "  AND BI3.BI3_CODIGO = BA3.BA3_CODPLA "
cQuery += "  AND BI3.D_E_L_E_T_ = ' '            "
cQuery += "INNER JOIN "+RetSqlName("BTS")+" BTS  "
cQuery += "  ON  BTS.BTS_FILIAL = BA1.BA1_FILIAL "
cQuery += "  AND BTS.BTS_MATVID = BA1.BA1_MATVID "
cQuery += "  AND BTS.D_E_L_E_T_ = ' '            "
cQuery += "INNER JOIN "+RetSqlName("BBU")+" BBU ON BBU.BBU_FILIAL = BA3.BA3_FILIAL "
cQuery += "	 AND BBU.BBU_CODOPE = BA3.BA3_CODINT "
cQuery += "	 AND BBU.BBU_CODEMP = BA3.BA3_CODEMP "
cQuery += "	 AND BBU.BBU_MATRIC = BA3.BA3_MATRIC "
cQuery += "	 AND BBU.BBU_CODFOR = BA3.BA3_FORPAG "

cQuery += iIf( cBanco $ "ORACLE/DB2/POSTGRES",;
	"	AND (TRUNC(MONTHS_BETWEEN(SYSDATE, BA1.BA1_DATNAS) / 12) BETWEEN BBU.BBU_IDAINI AND BBU.BBU_IDAFIN) ",;
	"	AND DATEDIFF(YEAR,BA1.BA1_DATNAS, GETDATE()) BETWEEN BBU.BBU_IDAINI AND BBU.BBU_IDAFIN ")

cQuery += "	 AND (BBU.BBU_TIPUSR = '' OR BBU.BBU_TIPUSR = BA1.BA1_TIPUSU) "
cQuery += "	 AND BBU.D_E_L_E_T_ = ' ' "
cQuery += "LEFT JOIN "+RetSqlName("BQL")+" BQL ON BQL.BQL_FILIAL = BA3.BA3_FILIAL"
cQuery += "	 AND BQL.BQL_CODIGO = COALESCE(TRIM(BA3_TIPPAG), TRIM(BQC_TIPPAG), TRIM(BT5_TIPPAG), TRIM(BG9_TIPPAG))  "
cQuery += "	 AND BQL.D_E_L_E_T_ = ' ' "
cQuery += "WHERE BA1.BA1_FILIAL = '"+xFilial("BA1")+"' "
cQuery += "	 AND BA1.BA1_CODINT = '"+cCodint+"' "
cQuery += "	 AND BA1.BA1_CODEMP = '"+cCodemp+"' "

cQuery += IIf( cBanco $ "ORACLE/DB2/POSTGRES",;
			IIf(!Empty(cContrato),"	 AND BA1.BA1_CONEMP||BA1.BA1_VERCON = '"+cContrato+"' ",""),;
			IIf(!Empty(cContrato),"	 AND BA1.BA1_CONEMP+BA1.BA1_VERCON = '"+cContrato+"' ",""))
	
cQuery += IIf( cBanco $ "ORACLE/DB2/POSTGRES",;
			IIf(!Empty(cSubCon),"	 AND BA1.BA1_SUBCON||BA1.BA1_VERSUB = '"+cSubCon+"' ",""),;
			IIf(!Empty(cSubCon),"	 AND BA1.BA1_SUBCON+BA1.BA1_VERSUB = '"+cSubCon+"' ",""))

cQuery += "	 AND BA1.BA1_DATBLO = ' ' " // SOMENTE BENEFICIARIOS ATIVOS
cQuery += "	 AND BA1.D_E_L_E_T_ = ' ' "
cQuery += "ORDER BY BA1_NOMUSR "

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),"TRBR4",.F.,.T.)

If !TRBR4->(Eof())
	While !TRBR4->(Eof())
		aadd(aRet,{;
			TRBR4->NOME_BENEFICIARIO	,;	//NOME 
			TRBR4->CPF_BENEFICIARIO		,;	//CPF
			TRBR4->MATRICULA			,;	//MATRICULA
			TRBR4->COD_CONTRATO			,;	//CODIGO DO CONTRATO
			TRBR4->COD_SUBCONTRATO		,;	//CODIGO DO SUBCONTRATO
			TRBR4->SUBCONTRATO			,;	//DESCRIÇÃO DO SUBCONTRATO
			TRBR4->DATA_INCLUSAO		,;	//VIGENCIA
			TRBR4->MENSALIDADE			};	//VALOR DA MENSALIDADE
		)
		TRBR4->(dbSkip())
	 Enddo
Endif
TRBR4->(DbCloseArea())

Return(aRet)
