#INCLUDE "FINA910B.ch"
#Include "Protheus.ch"             
#Include "ApWizard.ch"
#include "fileio.ch"

#Define LOG_ERRO STR0017 
#Define LOG_INFO STR0001 

//Header do Arquivo de Conciliacao do Sitef
#Define HD_TPREG 1			//Tipo de Registro
#Define HD_DTARQ 2			//Data do Arquivo
#Define HD_HRARQ 3			//Hora do Arquivo
#Define HD_DTINI 4			//Data Inicial do Periodo
#Define HD_DTFIM 5			//Data Final do Periodo
#Define HD_VSARQ 6			//Versao do Arquivo
#Define HD_CODRD 7			//Codigo de Identificacao de Rede
#Define HD_SQARQ 8			//Numero sequencial do arquivo
#Define HD_SQREG 9			//Numero sequencial do registro
#Define HD_TOTRG 9			//Total de Campos do Heade

//Detalhes do Arquivo de Conciliacao do Sitef - Crédito
#Define DT_TPREG 01			//V01 - Tipo de Registro
#Define DT_IDTRA 02			//V02 - Identificador da Transação
#Define DT_ESTAB 03			//V03 - Código do Estabelecimento
#Define DT_DTVND 04			//V04 - Data da venda
#Define DT_NRESU 05			//V05 - Numero do Resumo
#Define DT_NCOMP 06			//V06 - Numero do Comprovante
#Define DT_NSUST 07			//V07 - NSU do SiTef
#Define DT_NCART 08			//V08 - Numero do Cartão
#Define DT_VLBRT 09			//V09 - Valor Bruto
#Define DT_TOTPA 10			//V10 - Total Parcelas
#Define DT_VLLIQ 11			//V11 - Valor Líquido
#Define DT_VLORG 12			//V12 - Valor Original
#Define DT_DTCRD 13			//V13 - Data Crédito	
#Define DT_DTORG 14			//V14 - Data Crédito	
#Define DT_NPARC 15			//V15 - Numero da Parcela
#Define DT_TPPRO 16			//V16 - Tipo Produto
#Define DT_CAPTU 17			//V17 - Captura
#Define DT_IDRED 18			//V18 - Código Ident. Rede
#Define DT_CDBCO 19			//V19 - Código do Banco
#Define DT_CDAGE 20 		//V20 - Código da Agencia
#Define DT_CDCC  21			//V21 - Numero da Conta Corrente
#Define DT_VLCOM 22			//V22 - Valor da Comissão
#Define DT_VLTXS 23			//V23 - Valor da Taxa de Serviço
#Define DT_LJSIT 24			//V24 - CodLojaSiTef
#Define DT_AUTOR 25			//V25 - Código de Autorização
#Define DT_CFISC 26			//V26 - Cupom fiscal
#Define DT_CBAND 27			//V27 - Codigo da bandeira
#Define DT_SQREG 28			//V28 - Seq. do Registro no Arquivo
#Define DT_TOTRG 28			//Total de Campos do Trailer
#Define DT_DTSIT 28			//V28 - Data Venda Sitef
#Define DT_HRSIT 29			//V29 - Hora Venda Sitef
#Define DT_SQRE3 30			//V28 - Seq. do Registro no Arquivo

//Detalhes do Arquivo de Conciliacao do Sitef - Venda
#Define V_DT_TPREG 01			//V01 - Tipo de Registro
#Define V_DT_IDTRA 02			//V02 - Identificador da Transação
#Define V_DT_ESTAB 03			//V03 - Código do Estabelecimento
#Define V_DT_DTVND 04			//V04 - Data da venda
#Define V_DT_NRESU 05			//V05 - Numero do Resumo
#Define V_DT_NCOMP 06			//V06 - Numero do Comprovante
#Define V_DT_NSUST 07			//V07 - NSU do SiTef
#Define V_DT_NCART 08			//V08 - Numero do Cartão
#Define V_DT_VLBRT 09			//V09 - Valor Bruto
#Define V_DT_TOTPA 10			//V10 - Total Parcelas
#Define V_DT_VLLIQ 11			//V11 - Valor Líquido
#Define V_DT_DTCRD 12			//V13 - Data Crédito	
#Define V_DT_NPARC 13			//V15 - Numero da Parcela
#Define V_DT_TPPRO 14			//V16 - Tipo Produto
#Define V_DT_CAPTU 15			//V17 - Captura
#Define V_DT_IDRED 16			//V18 - Código Ident. Rede
#Define V_DT_CDBCO 17			//V19 - Código do Banco
#Define V_DT_CDAGE 18 		    //V20 - Código da Agencia
#Define V_DT_CDCC  19			//V21 - Numero da Conta Corrente
#Define V_DT_VLCOM 20			//V22 - Valor da Comissão
#Define V_DT_VLTXS 21			//V23 - Valor da Taxa de Serviço
#Define V_DT_LJSIT 22			//V24 - CodLojaSiTef
#Define V_DT_AUTOR 23			//V25 - Código de Autorização
#Define V_DT_CFISC 24			//V26 - Cupom fiscal
#Define V_DT_CBAND 25			//V25 - Código da Bandeira
#Define V_DT_SQREG 26			//V27 - Seq. do Registro no Arquivo
#Define V_DT_TOTRG 26			//Total de Campos do Trailer
#Define V_DT_DTSIT 26			//V26 - Data Venda Sitef
#Define V_DT_HRSIT 27			//V27 - Hora Venda Sitef
#Define V_DT_SQRE3 28			//V28 - Seq. do Registro no Arquivo

//Trailer do Arquivo de Conciliacao do Sitef
#Define TR_TPREG 1			//Tipo de Registro
#Define TR_SQREG 2			//Numero sequencial do registro
#Define TR_TOTRG 2			//Total de Campos do Trailer

//-------- Arquivo de Conciliacao Direcao
#Define DI_CODEST 	01		//01 - Codigo Empresa
#Define DI_CODLOJ 	02		//02 - Codigo Loja
#Define DI_CODRED 	03		//03 - Codigo Ident. Rede
#Define DI_DTTEF  	04		//04 - Data da venda
#Define DI_HRTEF  	05		//05 - Hora da venda
#Define DI_NSUTEF 	06		//06 - NSU do SiTef
#Define DI_NUCOMP 	07      //07 - NSU REDE
#Define DI_TPPROD 	08      //08 - Tipo Operacao   
#Define DI_DESCOP 	09		//09 - Descricao Operacao
#Define DI_CODPDV 	10		//10 - Codigo PDV
#Define DI_ESTTRA 	11		//11 - Estado da Transacao
#Define DI_RESPTRA 	12 		//12 - Codigo Resposta da Transacao
#Define DI_NUCART 	13		//13 - NRO Cartao 
#Define DI_VLRVND   14		//14 - Valor Venda
#Define DI_DTPREVL  15 		//15 - Data Prevista Pagto Loja
#Define DI_DTPREVR  16		//16 - Data Prevista Pagto Rede
#Define DI_PARCEL   17		//17 - Numero da Parcela
#Define DI_TOTPARC  18		//18 - Total Parcelas
#Define DI_VLRPARC  19		//19 - Valor da Parcela  
#Define DI_VLCOM	20		//20 - Valor Comissao
#Define DI_VLLIQ	21 		//21 - Valor Liquido
#Define DI_NURESU   22		//22 - Numero RO
#Define DI_CAPTUR	23		//23 - Capturada
#Define DI_DTANT	24		//24 - Data Antecipação
#Define DI_VLRANT   25		//25 - Valor Antecipacao
#Define DI_NROOA	26 		//26 - NRO_OA
#Define DI_DTDEP	27      //27 - Data Deposito Rede
#Define DI_TPARQ	28		//28 - Tipo de arquivo
#Define DI_ORIGEM	29		//29 - Origem da transação, cadastrada na tela de terminais

//Detalhes do Arquivo de Antecipacao do Sitef 
#Define 100_TPREG 	01			//V01 - Tipo de Registro
#Define 100_ESTAB 	02			//V02 - Código do Estabelecimento
#Define 100_LJSIT 	03			//V03 - CodLojaSiTef
#Define 100_NRESU 	04			//V04 - Numero do Resumo
#Define 100_DTANT 	05			//V05 - Data de credito antecipada
#Define 100_VLPG	06			//V06 - Valor Liquido Pago
#Define 100_IDRED 	07			//V07 - Código Ident. Rede
#Define 100_NPARC 	08			//V08 - Numero da Parcela a ser antecipada 
#Define 100_DTCRE 	09			//V09 - Data de Credito Original
#Define 100_VLLIQ 	10			//V10 - Valor Líquido antes da antecipacao
#Define 100_VLBRU 	11			//V11 - Valor Bruto da antecipação.
#Define 100_CDBCO 	12			//V12 - Código do Banco
#Define 100_CDAGE 	13 			//V13 - Código da Agencia
#Define 100_CDCC  	14			//V14 - Numero da Conta Corrente
#Define 100_RESUN 	15			//V15 - Codigo Resumo Unico
#Define 100_SQREG 	16			//V16 - Seq. do Registro no Arquivo

//Detalhes do Arquivo de Antecipacao do Sitef 
#Define 200_TPREG 	01			//V01 - Tipo de Registro
#Define 200_IDTRA 	02			//V02 - Identificador de Transacao
#Define 200_ESTAB 	03			//V03 - Código do Estabelecimento 
#Define 200_DTVND 	04			//V04 - Data da venda
#Define 200_NRESU 	05			//V05 - Numero do Resumo
#Define 200_NCOMP 	06			//V06 - Numero do Comprovante   
#Define 200_NSUST 	07			//V07 - NSU do SiTef
#Define 200_NCART 	08			//V08 - Numero do Cartão
#Define 200_VLBRT 	09			//V09 - Valor Bruto
#Define 200_TOTPA 	10			//V10 - Total Parcelas
#Define 200_TPPRO 	11			//V11 - Tipo Produto
#Define 200_CAPTU 	12			//V12 - Captura 
#Define 200_IDRED 	13			//V13 - Código Ident. Rede    
#Define 200_LJSIT 	14			//V14 - CodLojaSiTef
#Define 200_AUTOR 	15			//V15 - Código de Autorização
#Define 200_CFISC 	16			//V16 - Cupom fiscal
#Define 200_CBAND 	17			//V17 - Código da Bandeira
#Define 200_DTCRD 	18			//V18 - Data Venda Sitef
#Define 200_NPARC 	25	        //V25 - Numero da Parcela a ser antecipada

Static nTamEmis 	:= TamSX3("E1_EMISSAO")[1]
Static nTamParc 	:= TamSX3("E1_PARCELA")[1]
Static nTamTEF 		:= TamSX3("E1_NSUTEF")[1]
Static nTamTPE1 	:= TamSX3("E1_TIPO")[1]    
Static nFIFParc		:= TamSX3("FIF_PARCEL")[1]  
Static nTamNSU		:= TamSX3("FIF_NSUTEF")[1]
Static nTamDtVnd	:= TamSX3("FIF_DTTEF")[1]
Static nTamAgen		:= TamSX3("FIF_CODAGE")[1]
Static nTamConta	:= TamSX3("FIF_NUMCC")[1]  
Static nTamNuComp   := TamSX3("FIF_NUCOMP")[1]  
Static nTamVLLIQ 	:= TAMSX3("FIF_VLLIQ")[2]
Static nTamTX		:= TAMSX3("FIF_TXSERV")[2]

//Detalhes do Arquivo de Conciliacao do Sitef - Crédito
Static nPosSqReg 	:= 0 		//Seq. do Registro no Arquivo
Static nPosToReg 	:= 0		//Total de Campos do Trailer

//Detalhes do Arquivo de Conciliacao do Sitef - Venda
Static nVPosSqReg 	:= 0		//Seq. do Registro no Arquivo
Static nVPosToReg 	:= 0		//Total de Campos do Trailer

Static cVerCon		:= ""
Static oParamFil   := Nil		//Objeto do tipo LJCHasheTable com as filiais cadastradas nos parametros 
Static aCompSA1		:= {}
Static aCompSA6		:= {} 

Static lFin910Fil	:= (ExistBlock("FIN910FIL")) //PE para seleção de filiais.
Static lFinFif 		:= (ExistBlock("FINFIF")) //PE para Gravação de campos Extras na FIF 
Static _oFINA910B //Objeto para receber comandos da classe FwTemporaryTable
Static _oImp200B //Objeto para receber comandos da classe FwTemporaryTable, para registro do tipo 200
Static __cFIFNaoPro	:= "1/6" // Status Não Processados - 1-"Não Processado" - 6-"Ant. Nao Processada"
Static __lMVCONCV
Static __oTmpFIF1	:= Nil
Static __oTmpFIF2	:= Nil

/*/{Protheus.doc} FINA910b
	Rotina que importa os Arquivos do SITEF e D-TEF

	@type function
	@author Rafael Rosa da Silva
	@since 05/08/2009
/*/
Function FINA910B()

	Local oWizard	:= Nil
	Local oCamArq	:= Nil
	Local cCamArq	:= "                                                                                     "
	Local lOk		:= .F.

	Private lEnd 	:= .T.

	DEFINE WIZARD oWizard TITLE STR0002 HEADER STR0003;			//"STR0002 Conciliação TEF"	### STR0003 "Wizard utilizado para importacao de arquivos de conciliação TEF"
	MESSAGE "";
	TEXT STR0004;										//"Esta rotina tem por objetivo importar os arquivos de conciliação TEF" 
	PANEL NEXT {|| .T. } FINISH {|| .T. };

	CREATE PANEL oWizard HEADER STR0005;					//"Dados conciliação"
	MESSAGE STR0006;									//"Selecione o arquivo de integração de conciliação do SITEF"
	PANEL BACK {|| .T. } NEXT {|| A910ExtArq(cCamArq) } FINISH {|| .T. } EXEC {|| .T. }

	@ C(005),C(005) Say STR0007 			  Size C(051),C(008) COLOR CLR_BLACK PIXEL OF oWizard:oMPanel[2]				//"Arquivo"
	@ C(004),C(055) MsGet oCamArq Var cCamArq Size C(105),C(009) COLOR CLR_BLACK PIXEL OF oWizard:oMPanel[2]

	@ C(004),C(162) Button STR0008 Size C(037),C(009) Action A910BscArq(@cCamArq,@oCamArq) PIXEL OF oWizard:oMPanel[2]	//"&Procurar"

	CREATE PANEL oWizard HEADER STR0009;					//"Finalizar"
	MESSAGE STR0010;									//"Para confirmar a importação do arquivo de conciliação do SITEF clique em Finalizar ou clique em Cancelar para sair da rotina"
	PANEL BACK {|| .T. } FINISH {|| lOk := .T. } EXEC {|| .T.}

	ACTIVATE WIZARD oWizard CENTERED

	If lOk
			Processa({|lEnd| A910VldArq(cCamArq,@lEnd) },STR0011, ,@lEnd)				//"Processando..."
		
	EndIf

Return

/*/{Protheus.doc} A910ExtArq
	

	@type function
	@author Rafael Rosa da Silva
	@since 08/11/09
/*/
Static Function A910ExtArq(cCamArq)

	Local lRet := .T.

	If Empty(cCamArq)
		MsgInfo(STR0012)							//"Para continuar é necessario a pesquisa do arquivo"
		lRet := .F.
	ElseIf !File(cCamArq)
		MsgInfo(STR0013 + cCamArq + STR0014)		//"Arquivo "	### " nao encontrado!"
		lRet := .F.
	EndIf

Return lRet

/*/{Protheus.doc} A910BscArq
	

	@type function
	@author Rafael Rosa da Silva
	@since 08/11/09
/*/
Static Function A910BscArq(cCamArq,oCamArq)

	Local cType := STR0015 + "(*.csv) |*.csv|" //"Arquivos CSV"

	cCamArq := Upper(Alltrim(cGetFile(cType ,STR0016,0,,.F.,GETF_LOCALHARD + GETF_NETWORKDRIVE))) //"Selecione o Arquivo"
	oCamArq:Refresh()

Return 

/*/{Protheus.doc} A910VldArq
	

	@type function
	@author Rafael Rosa da Silva
	@since 08/11/09
/*/
Function A910VldArq(cCamArq as Character, lEnd as Logical, nQtdLinha as Numeric, nQtdNProc as Numeric, nQtdFilOk as Numeric, cCodSOFEX as Character, cNomArq as Character, nQtdLida as Numeric, nLinTotal as Numeric, nQtdImp as Numeric, nQtdAlt as Numeric, lAutomato as Logical, lOpt as Logical, cDescLeg as Character, cIdProc as Character)

	Local aLinha		As Array
	Local aDados		As Array
	Local aLog			As Array
	Local aCampos		As Array
	Local aTam     		As Array
	Local aParc			As Array
	Local aDfif 		As Array
	Local cLinha		As Character
	Local cNSUSitef		As Character
	Local cNuComp  		As Character
	Local cParcela		As Character
	Local _cConta   	As Character
	Local cParc     	As Character
	Local cNPARC		As Character
	Local cEstab		As Character
	Local cIdRed		As Character
	Local cCodLoj   	As Character
	Local cCodBan		As Character
	Local cMsFilAnt 	As Character
	Local cMsFil    	As Character
	Local cFilFif    	As Character
	Local cChaveTmp 	As Character
	Local cChaveAnt 	As Character
	Local cValliq		As Character
	Local cChavNSUST	As Character
	Local cTef 			As Character
	Local cTime			As Character
	Local cHoraIni 		As Character
	Local cArqReg100	As Character
	Local cArqReg200	As Character
	Local cCodAut		As Character
	Local cSeqReg 		As Character
	Local dHoje			As Date
	Local nI			As Numeric
	Local nEx1			As Numeric
	Local nEx2			As Numeric
	Local nSeq			As Numeric
	Local nRegExist		As Numeric
	Local nFator 		As Numeric
	Local lRet			As Logical
	Local lTemHead		As Logical
	Local lTemVnd		As Logical
	Local lIncVnd		As Logical
	Local lFirst		As Logical
	Local lTemRod		As Logical
	Local lContinua		As Logical
	Local lParcel 		As Logical
	Local lCarEsp       As Logical
	Local lNsuTef 		As Logical
	Local lNuComp		As Logical
	Local lAltera		As Logical
	Local lDisarmTran   As Logical
	
	aLinha		:= {}
	aDados		:= {}
	aLog		:= {}
	aCampos		:= {}
	aTam     	:= {}
	aParc		:= {}
	aDfif 		:= {}
	cLinha		:= ""
	cNSUSitef	:= ""
	cNuComp  	:= ""
	cParcela	:= ""
	_cConta   	:= ""
	cParc     	:= ""
	cNPARC		:= ""
	cEstab		:= ""
	cIdRed		:= ""
	cCodLoj   	:= ""
	cCodBan		:= ""
	cMsFilAnt 	:= ""
	cMsFil    	:= ""
	cFilFif    	:= ""
	cChaveTmp 	:= ""
	cChaveAnt 	:= ""
	cValliq		:= ""
	cChavNSUST	:= ""
	cTef 		:= ""
	cTime		:= Time()
	cHoraIni 	:= SubStr( cTime, 01, 08 )
	cArqReg100	:= "TMP100"
	cArqReg200	:= "TMP200"
	cCodAut		:= ""
	dHoje		:= dTos(Date())
	nI			:= 0
	nEx1		:= 0
	nEx2		:= 0
	nSeq		:= 1
	nRegExist	:= 0
	nFator 		:= 1
	lRet		:= .T.
	lTemHead	:= .F.
	lTemVnd		:= .F.
	lIncVnd		:= .T.
	lFirst		:= .T.
	lTemRod		:= .F.
	lContinua	:= .T.
	lParcel 	:= .F.
	lCarEsp     := .F.
	lNsuTef 	:= .F.
	lNuComp		:= .F.
	lAltera		:= .F.
	lDisarmTran := .F.

	Default cIdProc  := GetSxeNum("FVR","FVR_IDPROC")

	Private cSeqFIF  	:= ""
	Private nTamNSUTEF 	:= TamSX3("FIF_NSUTEF")[1]
	Private nTamParcel 	:= TamSX3("FIF_PARCEL")[1]
	Private nTamCodEst 	:= TamSX3("FIF_CODEST")[1]
	Private nTAmCodRed 	:= TamSX3("FIF_CODRED")[1]
	Private nTAmCodFil 	:= TamSX3("FIF_CODFIL")[1]
	Private nDecTxServ 	:= TamSX3("FIF_TXSERV")[2]
	Private nDecVlBrut 	:= TamSX3("FIF_VLBRUT")[2]
	Private nDecVlliq  	:= TamSX3("FIF_VLLIQ")[2]
	Private nDecVlCom 	:= TamSX3("FIF_VLCOM")[2]

	Default nQtdLinha	:= 0
	Default nQtdNProc	:= 0
	Default nQtdFilOk	:= 0
	Default nLinTotal	:= 0
	Default nQtdLida	:= 0
	Default nQtdImp     := 0
	Default nQtdAlt		:= 0
	Default cCodSOFEX	:= ""
	Default cNomArq		:= ""
	Default lAutomato	:= .F.
	Default lOpt		:= .T.
	Default cDescLeg	:= ""

	aCampos := {}	
	AADD(aCampos,{"CODEST"  ,"C",15,0})    
	AADD(aCampos,{"CODLOJ"  ,"C",TamSX3('FIF_CODLOJ')[1],0})    
	AADD(aCampos,{"NRORES"  ,"C",15,0})   

	aTam:=TamSX3("E1_EMISSAO")
	AADD(aCampos,{"DTANTEC" ,"C",8,0})

	aTam:=TamSX3("E1_VALOR")
	AADD(aCampos,{"VRANT"   ,"N",aTam[1],aTam[2]})
	AADD(aCampos,{"PARC"    ,"C",2,0})    
	AADD(aCampos,{"DTCRED" ,"C",8,0})

	aTam:=TamSX3("E1_VALOR")
	AADD(aCampos,{"VRORIG"   ,"N",aTam[1],aTam[2]})
	AADD(aCampos,{"VRBRUTO"  ,"N",aTam[1],aTam[2]})
	AADD(aCampos,{"CODBCO"  ,"C",6,0})    
	AADD(aCampos,{"CODAG"   ,"C",6,0})    
	AADD(aCampos,{"CODCTA"  ,"C",15,0})      			
	AADD(aCampos,{"RESUN"   ,"C",22,0})

	If(_oFINA910B <> NIL)
		_oFINA910B:Delete()
		_oFINA910B := NIL
	EndIf

	_oFINA910B := FwTemporaryTable():New(cArqReg100)
	_oFINA910B:SetFields(aCampos)
	_oFINA910B:AddIndex("1", {"CODEST","CODLOJ","NRORES","PARC"})
	_oFINA910B:Create()

	aFields := {}
	aAdd( aFields, { "CODEST", "C", 15, 0 } )
	aAdd( aFields, { "CODLOJ", "C", TamSX3('FIF_CODLOJ')[1], 0 } )	
	aAdd( aFields, { "NURESU", "C", 15, 0 } )
	aAdd( aFields, { "NCOMP", "C", nTamNuComp, 0 } )
	aAdd( aFields, { "DTVEND", "C", 8, 0 } )
	aAdd( aFields, { "NSUTEF", "C", TamSX3( "FIF_NSUTEF" )[1], 0 } )
	aAdd( aFields, { "VLR200", "N", TamSX3('FIF_VLBRUT')[1], TamSX3('FIF_VLBRUT')[2] } )
	aAdd( aFields, { "CUPOM", "C", 20, 0 } )
	aAdd( aFields, { "DTSITEF", "C", 8, 0 } )
	aAdd( aFields, { "PARC"	, "C", 2, 0 } )
	aAdd( aFields, { "TOTPA"	, "C", 2, 0 } )
	aAdd( aFields, { "DTTEF", "C", 8, 0 } )
	aAdd( aFields, { "SEQFIF", "C", TamSX3('FIF_SEQFIF')[1], 0 } )
	aAdd( aFields, { "KEYFIF", "C", TamSX3( "FIF_FILIAL" )[1] + TamSX3( "FIF_DTTEF" )[1] + TamSX3( "FIF_NSUTEF" )[1] + TamSX3( "FIF_PARCEL" )[1] + TamSX3( "FIF_CODLOJ" )[1] + TamSX3( "FIF_DTCRED" )[1] + TamSX3( "FIF_SEQFIF" )[1], 0 } )

	If(_oImp200B <> NIL)
		_oImp200B:Delete()
		_oImp200B := NIL
	EndIf

	_oImp200B := FwTemporaryTable():New(cArqReg200)
	_oImp200B:SetFields(aFields)
	_oImp200B:AddIndex("1", {"CODEST","CODLOJ","NURESU"})
	_oImp200B:Create()

	/*======================================\
	|Estrutura do Array aLog				|
	|---------------------------------------|
	|aLog[n][1] -> Linha da Ocorrencia		|
	|aLog[n][2] -> Tipo da Ocorrencia		|
	|aLog[n][1] -> Descricao da Ocorrencia	|
	\======================================*/
	ConoutR("Conciliador TEF - FINA910B - A910VldArq - INICIO IMPORTANDO ARQUIVO - " + DToC(Date()) + " - Hora: " + TIME())
	If !LockByName( "FINA910B"+cEmpAnt, .F. , .F. )
		MsgStop(STR0059,"FINA910B" )//"Esta rotina está sendo utilizada por outro usuário. Tente novamente mais tarde."
		Return
	EndIf

	lContinua := A910CarFil()

	dbSelectArea("FIF")
	dbSetOrder(5)	//FIF_FILIAL+FIF_DTTEF+FIF_NSUTEF+FIF_PARCEL+FIF_CODLOJ+FIF_DTCRED+FIF_SEQFIF

	nHdlFile := FT_FUse(cCamArq)
	nRecCount := FT_FLASTREC()
	fClose(nHdlFile)
	FT_FUSE()

	nHdlFile := fOpen(cCamArq)
	//se arquivo tiver mais de 2 mil registros realiza o commit e atualização de tela a cada 1000               
	If nRecCount > 2000
		nFator := 1000
	EndIf

	DbSelectArea("FVR")
	DbSetOrder(2) //FVR_NOMARQ+DTOS(FVR_DTPROC)+FVR_HRPROC	

	nTam := 1000

	If __lMVCONCV == Nil
		__lMVCONCV := SuperGetMV("MV_FCONCSE", .F., .F.)
	EndIf	

	If !(nHdlFile == -1)  .and. lContinua

		//inicia transacao  -- somente na leitura do arquivo texto eh permitido abortar
		//                     transacao existe pq em algum momento ele deleta registro na tabela FIF
		Begin Transaction
			While fReadLn(nHdlFile,@cLinha,nTam)

				lContinua	:= .T.
				lAltera		:= .F.	
				cSeqReg 	:= ""
							
				//caso usuario aborte pressionando botao cancelar
				If lEnd .And. Aviso( "Atencao","Abortar Processamento ?", {"Sim","Nao"} ) == 1 
					lDisarmTran := .T.
					RollBackDelTran()
				Else
					lEnd := .F.
				EndIf

				If Empty(cLinha)
					Loop
				EndIf

				nLinTotal++

				//Retira as aspas duplas e troca por espaco em branco
				//senao a funcao strtokarr nao traz a coluna         
				cLinha	:= StrTran(cLinha,'""'," ")

				//Retira os caracteres especiais, no caso o " que separa os registros
				cLinha	:= StrTran(cLinha,'"',"")

				//Transforma a linha em um array com todos os registros
				aLinha	:= StrToKArr(cLinha,";")

				If Alltrim(aLinha[1]) == "0"	// Cabeçalho do arquivo
					lTemHead := .T.

					If Len(aLinha) == HD_TOTRG
						
						nQtdLida++
						//Verifico se as versoes dos arquivos sao homologadas
						If !(Alltrim(aLinha[HD_VSARQ]) $ ("V2.0|V3.0|V3.6")) 
							aAdd(aLog,{	Alltrim(aLinha[HD_SQREG]),;
							LOG_INFO,;
							STR0018 + Alltrim(aLinha[HD_VSARQ]) + STR0019})			//"Versao do arquivo("	### ") divergente das homologadas(V2.0, V3.0, V3.6)"	
							nQtdNProc++
							cDescLeg := STR0018 + Alltrim(aLinha[HD_VSARQ]) + STR0019
							lTemHead := .F.
						Else
							cVerCon := Alltrim(aLinha[HD_VSARQ])

							If cVerCon == "V2.0"
								nPosSqReg 	:= 27
								nPosToReg 	:= 27
							Else
								nPosSqReg 	:= 28
								nPosToReg 	:= 28
							EndIf

							If cVerCon == "V2.0"
								nVPosSqReg 	:= 25
								nVPosToReg 	:= 25
							Else
								nVPosSqReg 	:= 26
								nVPosToReg 	:= 26
							EndIf

							If Val(aLinha[HD_SQREG]) <> nSeq
								aAdd(aLog,{	Alltrim(aLinha[HD_SQREG]),;
								LOG_ERRO,;
								STR0020 + Alltrim(aLinha[HD_SQREG]) + STR0021 + StrZero(nSeq,6) + ")"})		//"Numero de Sequencia do arquivo ("	### ") errado para o Header ("
								nQtdNProc++
								cDescLeg := STR0020 + Alltrim(aLinha[HD_SQREG]) + STR0021 + StrZero(nSeq,6) + ")"
								lTemHead := .F.
							EndIf
						EndIf
					Else
						aAdd(aLog,{	"000000",;
						LOG_ERRO,;
						STR0066 + Alltrim(Str(Len(aLinha))) + STR0067 + STR0023 + Alltrim(Str(HD_TOTRG)) + STR0067})		//"Header ("	### ") nao possui todos os campos que deveria ("
						
						cDescLeg := STR0066 + Alltrim(Str(Len(aLinha))) + STR0067 + STR0023 + Alltrim(Str(HD_TOTRG)) + STR0067
						lTemHead := .F.
						nQtdNProc++
					EndIf				
				ElseIf lTemHead .And. Alltrim(aLinha[1]) == "10"	// Detalhes do arquivo							
					lIncVnd := .T.
					If cVerCon == "V3.0" .and. Len(aLinha) > nPosSqReg
						nPosSqReg 	:= 30
						nPosToReg 	:= 30
					ElseIf cVerCon == "V3.6" .and. Len(aLinha) > nPosSqReg .and. Len(aLinha) <=34
						nPosSqReg 	:= Len(aLinha)
						nPosToReg 	:= Len(aLinha)
					EndIf	

					If Len(aLinha) == nPosToReg
						
						If Val(aLinha[nPosSqReg]) <> nSeq
							aAdd(aLog,{	Alltrim(aLinha[nPosSqReg]),;
							LOG_ERRO,;
							STR0024 + Alltrim(aLinha[nPosSqReg]) + STR0025 + StrZero(nSeq,6) + ")"})		//"Numero de Sequencia do arquivo ("	### ") errado para o Detalhe ("
							lIncVnd := .F.
						EndIf

						//Verifica se o registro ja existe na base de dados
						cNSUSitef 	:= PADR("", nTamNSUTEF - len(Alltrim(aLinha[DT_NSUST])),'0') + Alltrim(aLinha[DT_NSUST])
						cNuComp  	:= PADR("", nTamNuComp - len(Alltrim(aLinha[DT_NCOMP])),'0') + Alltrim(aLinha[DT_NCOMP])
						cParcela	:= Alltrim(aLinha[DT_NPARC]) + Space(nTamParcel - Len(Alltrim(aLinha[DT_NPARC])) )

						cEstab		:= Alltrim(aLinha[DT_ESTAB]) + Space(nTamCodEst - Len(Alltrim(aLinha[DT_ESTAB])) )								
						cIdRed		:= Alltrim(aLinha[DT_IDRED]) + Space(nTAmCodRed - Len(Alltrim(aLinha[DT_IDRED])) )								
						cCodLoj     := Alltrim(aLinha[DT_LJSIT]) + Space(nTAmCodFil - Len(Alltrim(aLinha[DT_LJSIT])) )								
						cCodAut		:= Right(aLinha[DT_AUTOR],6)

						cParc := StrZero(Val(cParcela),nTamParcel)

						If cParcela == '00'
							cParc := StrZero(Val("1"),nTamParcel)
						Endif

						cTef := RIGHT(cNSUSitef,12)	
						cTef += Space(nTamNSUTEF - len(Alltrim(RIGHT(cNSUSitef,12))))		   

						lContinua := Fa910Cont(aLinha[DT_DTVND], cTef, cNSUSitef, cParc, cCodAut, cCodLoj, aLinha[DT_DTCRD])

						If lContinua

							If __lMVCONCV .And. FIF->FIF_STVEND == "1" .And. Alltrim(aLinha[1]) <> "200"
								cTipoReg	:= Alltrim(aLinha[1])
								lAltera		:= AtuRegVend( cNomArq, cTipoReg)
								lIncVnd		:= .F.
								nQtdAlt++
								nQtdLida++
								nQtdLinha++
							Else
								If nRegExist == 0 .AND. FIF->FIF_STATUS $ __cFIFNaoPro
									If !lAutomato
										lOpt :=  Aviso(STR0026,STR0027,{STR0028,STR0029},2,STR0002) == 1 //"Atenção"	### "Existem registros no arquivo que ja constam como importados. Deseja que todos os registros nessa mesma situação sejam?"	### Substituir	### Pular Registro	"Conciliação TEF"						
									EndIf
									If lOpt							
										nRegExist := 1							
									Else							
										nRegExist := 2							
									EndIf
								EndIf
							EndIf

							If FIF->FIF_STATUS $ __cFIFNaoPro
								If nRegExist == 1 //Foi Selecionado para sobrepor os registros
									aAdd(aLog,{	Alltrim(aLinha[nPosSqReg]),;
									LOG_INFO,;
									STR0030 + cUserName})			//"Ja gravado. Foi substituido o registro, conforme selecionado pelo usuario "

									RecLock("FIF",.F.)
									FIF->(DBDelete())
									FIF->(MsUnlock())

									nQtdAlt++
									lIncVnd := .T.
								ElseIf nRegExist == 2 //Foi selecionado para pular o registro
									aAdd(aLog,{	Alltrim(aLinha[nPosSqReg]),;
									LOG_INFO,;
									STR0031 + cUserName})			//"Ja gravado. Foi pulado o registro, conforme selecionado pelo usuario "
									nQtdImp++
									lIncVnd := .F.	

									cDescLeg := STR0031 + cUserName		
								EndIf
							Else
								aAdd(aLog,{	Alltrim(aLinha[nPosSqReg]),;
								LOG_ERRO,;
								STR0032 + FIF->FIF_STATUS + STR0033})		//"Registro ja gravado e com status modificado ("	### ") do status original (1)"
								lIncVnd := .F.

								cDescLeg := STR0032 + FIF->FIF_STATUS + STR0033
							EndIf

						EndIf

						If lIncVnd

							lIncVnd	:= Fa914VldImp(aLinha[DT_LJSIT], "SOFEX") // Valida se filial poderá ser importada (FVZ)
													
							If lIncVnd
								nQtdFilOk++
							EndIf
						EndIf						

						lCarEsp := FINCARCESP(cNSUSitef,cNuComp,@lNsuTef,@lNuComp)

						If lIncVnd .and. !lCarEsp

							If((aLinha[DT_NPARC] == '0') .Or. (aLinha[DT_NPARC] == '00'))
								cNPARC := StrZero(Val("01"),nTamParcel)
							Else
								cNPARC := STRZERO(VAL(aLinha[15]),nTamParcel)
							EndIf

							_cConta := ALLTRIM(aLinha[DT_CDCC])
							cSeqFIF := A910SeqFIF(aLinha[DT_DTVND] ,aLinha[DT_NSUST], aLinha[DT_NPARC], aLinha[DT_LJSIT], ;
							aLinha[DT_DTCRD])

							If cMsFilAnt <> cCodloj  	 
								// Busca a filial somente se mudar
								cMsFil := Fa914MsFil( aLinha[DT_LJSIT], "SOFEX" )

								cMsFilAnt := cCodloj
							EndIf

							If cVerCon == "V2.0"
								cCodBan := ""
							Else
								CCodBan := aLinha[DT_CBAND]
							EndIf

							If lFin910fil
								cFilFif := ExecBlock("FIN910FIL",.F.,.F.,aLinha)
							Else
								cFilFif := xFilial("FIF", cMsFil)
							EndIf

							If aLinha[DT_TPPRO]	== "H"
								aLinha[DT_TPPRO] := "D"
							ElseIf aLinha[DT_TPPRO]	== "E"
								aLinha[DT_TPPRO] := "C"
							Endif
							
							aAdd(aDados,{	{"FIF_FILIAL"	,cFilFif		   							,Nil},;
							{"FIF_TPREG"	,aLinha[DT_TPREG]											,Nil},;
							{"FIF_INTRAN"	,aLinha[DT_IDTRA]											,Nil},;
							{"FIF_CODEST"	,aLinha[DT_ESTAB]											,Nil},;
							{"FIF_DTTEF"	,sTod(aLinha[DT_DTVND])										,Nil},;
							{"FIF_NURESU"	,aLinha[DT_NRESU]											,Nil},;
							{"FIF_NUCOMP"	,cNuComp													,Nil},;
							{"FIF_NSUTEF"	,cNSUSitef													,Nil},;
							{"FIF_NUCART"	,aLinha[DT_NCART]											,Nil},;
							{"FIF_VLBRUT"	,Round(Val(aLinha[DT_VLBRT])/100,nDecVlBrut)				,Nil},;
							{"FIF_TOTPAR"	,aLinha[DT_TOTPA]											,Nil},;
							{"FIF_VLLIQ"	,Round(Val(aLinha[DT_VLLIQ])/100,nDecVlliq )				,Nil},;
							{"FIF_DTCRED"	,sTod(aLinha[DT_DTCRD])										,Nil},;
							{"FIF_PARCEL"	,cNPARC														,Nil},;
							{"FIF_TPPROD"	,aLinha[DT_TPPRO]											,Nil},;
							{"FIF_CAPTUR"	,aLinha[DT_CAPTU]											,Nil},;
							{"FIF_CODRED"	,Alltrim(Str(Val(aLinha[DT_IDRED])))						,Nil},;
							{"FIF_CODBCO"	,aLinha[DT_CDBCO]											,Nil},;
							{"FIF_CODAGE"	,xStrCmp("FIF_CODAGE",aLinha[DT_CDAGE])						,Nil},;
							{"FIF_NUMCC"	,xStrCmp("FIF_NUMCC",_cConta)								,Nil},;
							{"FIF_VLCOM"	,Round(Val(aLinha[DT_VLCOM])/100,nDecVlCom)					,Nil},;
							{"FIF_TXSERV"	,Round(Val(aLinha[DT_VLTXS])/100,nDecTxServ)				,Nil},;
							{"FIF_CODLOJ"	,aLinha[DT_LJSIT]											,Nil},;
							{"FIF_CODAUT"	,cCodAut													,Nil},;	
							{"FIF_CUPOM"	,aLinha[DT_CFISC]										    ,Nil},;	
							{"FIF_SEQREG"	,aLinha[nPosSqReg]											,Nil},;
							{"FIF_STATUS"	,"1"														,Nil},;
							{"FIF_STVEND"	, ""														,Nil},; 
							{"FIF_CODADM"	,cCodSOFEX													,Nil},;
							{"FIF_MSIMP"	,dHoje														,Nil},;
							{"FIF_CODFIL"	,cMsFil														,Nil},;
							{"FIF_CODBAN"	,cCodBan										            ,Nil},;
							{"FIF_SEQFIF"	,cSeqFIF        								            ,Nil},;
							{"FIF_ARQPAG"	,cNomArq        								            ,Nil},;
							{"FIF_DTIMP"	,dDatabase        								            ,Nil},;
							{"FIF_PARALF"   ,Chr(64 + Val(cNPARC))										,Nil}})

							nQtdLinha++
							nQtdLida++
							
							If lFINFIF
								aDfif := ExecBlock("FINFIF",.F.,.F.,aDados)
								If Valtype(aDfif) == "A"
									aDados := Aclone(aDfif)
								EndIf
							EndIf


							//Tratamento para que somente uma vez seja estanciada a variavel lTemVnd
							//que determina a existencia de um item do tipo Detalhe
							If lFirst
								lTemVnd := .T.
								lFirst	:= .F.
							EndIf
						ElseIf lCarEsp 
							nQtdNProc++
							lCarEsp  := .F.

							F914GrvLog('2',cIdProc,AllTrim(Str(nLinTotal)),cNomArq,dDataBase,cHoraIni,aLinha[DT_ESTAB],IIf(lNsutef,cNSUSitef,cNuComp),STR0064,"") // Grava detalhes do Log
							lNsuTef  := .F.
							lNuComp  := .F.

							cDescLeg := STR0064
						ElseIf Empty(Fa914MsFil(aLinha[DT_LJSIT], "SOFEX"))	
							nQtdNProc++
							lCarEsp  := .F.
							cDescLeg := STR0062
							F914GrvLog('2',cIdProc,AllTrim(Str(nLinTotal)),cNomArq,dDataBase,cHoraIni,aLinha[DT_ESTAB],Iif(lNsutef,cNSUSitef,cNuComp),STR0062,"")
						ElseIf !lIncVnd .And. !lAltera
							nQtdNProc++
							lCarEsp  := .F.
							cDescLeg := STR0065
							F914GrvLog('2',cIdProc,AllTrim(Str(nLinTotal)),cNomArq,dDataBase,cHoraIni,aLinha[DT_ESTAB],Iif(lNsutef,cNSUSitef,cNuComp),STR0065,"") 
						ElseIf !lAltera
								nQtdNProc++
								lCarEsp  := .F.
								F914GrvLog('2',cIdProc,AllTrim(Str(nLinTotal)),cNomArq,dDataBase,cHoraIni,aLinha[DT_ESTAB],Iif(lNsutef,cNSUSitef,cNuComp),STR0068,"") // Grava detalhes do Log						
						EndIf
					Else
						aAdd(aLog,{	"000000",;
						LOG_ERRO,;
						STR0034 + Alltrim(Str(Len(aLinha))) + STR0023 + Alltrim(Str(nPosToReg)) + ")"})			//"Detalhes ("	### ") nao possui todos os campos que deveria ("
						lTemRod := .F.
						lIncVnd := .F.
						nQtdNProc++	

						cDescLeg := STR0034 + Alltrim(Str(Len(aLinha))) + STR0023 + Alltrim(Str(nPosToReg)) + ")"
					EndIf

				ElseIf lTemHead .And. Alltrim(aLinha[1]) == "100"	// Lote da Antecipacao 	      
					
					nQtdLida++

					(cArqReg100)->(DbAppend())
					(cArqReg100)-> CODEST	:=	Alltrim(aLinha[100_ESTAB])
					(cArqReg100)-> CODLOJ	:=	Alltrim(aLinha[100_LJSIT])
					(cArqReg100)-> NRORES	:=	Alltrim(aLinha[100_NRESU])
					(cArqReg100)-> DTANTEC	:=  Alltrim(aLinha[100_DTANT])   //data credito da antecipacao
					(cArqReg100)-> VRANT	:=  Round(Val(aLinha[100_VLPG])/100,nDecVlliq) //Valor liquido antecipado
					(cArqReg100)-> PARC		:=  Alltrim(aLinha[100_NPARC]) + Space(nTamParcel - Len(Alltrim(aLinha[100_NPARC])) )				
					(cArqReg100)-> DTCRED	:=  Alltrim(aLinha[100_DTCRE])   // data credito original
					(cArqReg100)-> VRORIG	:=  Round(Val(aLinha[100_VLLIQ])/100,nDecVlliq) //Valor liquido antes da antecipacao
					If Len(aLinha) >= 16  //Posição do array que identifica o código da rede, neste caso 5 = Cielo2
						(cArqReg100)-> VRBRUTO	:=  Round(Val(aLinha[100_VLBRU])/100,nDecVlliq) //Valor liquido antes da antecipacao
						(cArqReg100)-> CODBCO	:=	Alltrim(aLinha[100_CDBCO]) //Código do Banco 
						(cArqReg100)-> CODAG	:=  Alltrim(aLinha[100_CDAGE]) //Código da Agencia
						(cArqReg100)-> CODCTA	:=  Alltrim(aLinha[100_CDCC])  //Código da Conta
						(cArqReg100)-> RESUN	:=	Alltrim(aLinha[100_RESUN]) //Codigo Resumo Unico
					Else //Para redes diferentes de Cielo2 as posições do registro 100 são diferentes, pois não há valor bruto
						(cArqReg100)-> VRBRUTO	:=  Round(Val(aLinha[100_VLLIQ])/100,nDecVlliq) //Valor liquido, pois não temos o Valor Bruto
						(cArqReg100)-> CODBCO	:=	Alltrim(aLinha[100_VLBRU]) //Código do Banco 
						(cArqReg100)-> CODAG	:=  Alltrim(aLinha[100_CDBCO]) //Código da Agencia
						(cArqReg100)-> CODCTA	:=  Alltrim(aLinha[100_CDAGE]) //Código da Conta
					EndIf

				ElseIf lTemHead .And. Alltrim(aLinha[1]) == "200"	// Transação da Antecipacao 	         

					lIncVnd 		:= .T.

					If cVerCon == "V3.0" .and. Len(aLinha) > nPosSqReg
						nPosSqReg 	:= 30
						nPosToReg 	:= 30
					ElseIf cVerCon == "V3.6" .and. Len(aLinha) <=32
						nPosSqReg 	:= Len(aLinha)
						nPosToReg 	:= Len(aLinha)
					EndIf	
					
					lParcel     := Len(aLinha) >= 25 .And. !Empty(aLinha[25])

					If Len(aLinha) == nPosToReg 
						//Tratamento incluído para não gerar divergência na chave de pesq do arq tmp que contém os tít de lote antecip, 
						//pois o arq tmp grava os valores com espaço mesmo com o tratamento alltrim na atribuiç dos valores
						If len(Alltrim(aLinha[200_ESTAB])) <> len((cArqReg100)->CODEST)
							cChaveTmp := Alltrim(aLinha[200_ESTAB]) + (space(len((cArqReg100)->CODEST) - len(Alltrim(aLinha[200_ESTAB])))) 	
						Else
							cChaveTmp := Alltrim(aLinha[200_ESTAB])
						EndIf

						If len(Alltrim(aLinha[200_LJSIT])) <> len((cArqReg100)->CODLOJ)
							cChaveTmp += Alltrim(aLinha[200_LJSIT]) + (space(len((cArqReg100)->CODLOJ) - len(Alltrim(aLinha[200_LJSIT]))))
						Else
							cChaveTmp += Alltrim(aLinha[200_LJSIT]) 	
						EndIf 

						If len(Alltrim(aLinha[200_NRESU])) <> len((cArqReg100)->NRORES)
							cChaveTmp += Alltrim(aLinha[200_NRESU]) + (space(len((cArqReg100)->NRORES) - len(Alltrim(aLinha[200_NRESU])))) 
						Else
							cChaveTmp += Alltrim(aLinha[200_NRESU]) 
						EndIf	

						If lParcel
							If len(Alltrim(aLinha[200_NPARC])) <> len((cArqReg100)->PARC)
								cChaveTmp += Alltrim(aLinha[200_NPARC]) + (space(len((cArqReg100)->PARC) - len(Alltrim(aLinha[200_NPARC])))) 
							Else
								cChaveTmp += Alltrim(aLinha[200_NPARC]) 
							EndIf	
						EndIf 
						//				
						aParc := {}
						If cChaveTmp <> cChaveAnt .Or. cChavNSUST <> aLinha[200_NSUST] //vld para n?o importar parcelas em duplicidade
							(cArqReg100)->(Dbgotop())//Procurar na tabela temporaria os registros que estao amarrados ao tipo 200.
							If (cArqReg100)->(Dbseek(cChaveTmp))
								cChaveAnt := cChaveTmp
								cChavNSUST	:= aLinha[200_NSUST]
								While !(cArqReg100)->(Eof()) .And.;
								Alltrim((cArqReg100)->CODEST) + Alltrim((cArqReg100)->CODLOJ) + Alltrim((cArqReg100)->NRORES) + Alltrim((cArqReg100)->PARC)==;
								Alltrim(aLinha[200_ESTAB]) + Alltrim(aLinha[200_LJSIT]) + Alltrim(aLinha[200_NRESU]) + IIf(lParcel,Alltrim(aLinha[200_NPARC]),Alltrim((cArqReg100)->PARC))

									If Val((cArqReg100)->PARC) <= Val(aLinha[10])
										Aadd(aParc, {(cArqReg100)->DTANTEC,;  //1 data da antecipacao
										(cArqReg100)->VRANT,;  //2 valor liquido antecipado
										(cArqReg100)->PARC,;   //3 parcela que sera antecipada
										(cArqReg100)->DTANTEC,; //4 data da antecipacao
										(cArqReg100)->VRORIG,; //5 valor liquido antes da antecipacao
										(cArqReg100)->DTCRED,; //6 data credito original
										(cArqReg100)->CODBCO,;//7 codigo banco
										(cArqReg100)->CODAG,; //8 codigo agencia
										(cArqReg100)->CODCTA,; //9 codigo conta
										(cArqReg100)->RESUN})	 //10 resumo unico - exclusivo Cielo
									EndIf

									(cArqReg100)->(Dbskip())							
								Enddo
							Endif 
						Endif  

						If Len(aParc) > 0					  

							cNSUSitef 	:= PADR("", nTamNSUTEF - len(Alltrim(aLinha[200_NSUST])),'0') + Alltrim(aLinha[200_NSUST])
							cNuComp 	:= PADR("", nTamNuComp - len(Alltrim(aLinha[200_NCOMP])),'0') + Alltrim(aLinha[200_NCOMP])
							cEstab		:= Alltrim(aLinha[200_ESTAB]) + Space(nTamCodEst - Len(Alltrim(aLinha[200_ESTAB])) )								
							cIdRed		:= Alltrim(aLinha[200_IDRED]) + Space(nTAmCodRed  - Len(Alltrim(aLinha[200_IDRED])) )								
							cCodLoj     := Alltrim(aLinha[200_LJSIT]) + Space(nTAmCodFil  - Len(Alltrim(aLinha[200_LJSIT])) )								
							cCodAut		:= Right(aLinha[200_AUTOR],6)

							For nI:= 1 to Len(aParc)						                  

								lContinua 	:= .T.

								cParcela	:= aParc[nI,3]
								cParc		:= StrZero(Val(cParcela),nTamParcel)

								If cParcela == '00'
									cParc := StrZero(Val("1"),nTamParcel)
								Endif

								cTef := RIGHT(cNSUSitef,12)	
								cTef += Space(nTamNSUTEF - len(Alltrim(RIGHT(cNSUSitef,12))))		   

								lContinua := Fa910Cont(aLinha[200_DTVND], cTef, cNSUSitef, cParc, cCodAut, cCodLoj)

								If lContinua
									If __lMVCONCV .And. FIF->FIF_STVEND == "1" .And. Alltrim(aLinha[1]) <> "10"
										cTipoReg	:= Alltrim(aLinha[1])
										lAltera		:= AtuRegVend( cNomArq, cTipoReg)
										lIncVnd		:= .F.
										nQtdAlt++
										nQtdLida++
										nQtdLinha++
									Else
										If nRegExist == 0 .AND. FIF->FIF_STATUS $ __cFIFNaoPro
											If !lAutomato
											lOpt :=  Aviso(STR0026,STR0027,{STR0028,STR0029},2,STR0002) == 1						
											EndIf
											If lOpt							
												nRegExist := 1							
											Else							
												nRegExist := 2							
											EndIf
										EndIf
									EndIf

									If FIF->FIF_STATUS $ __cFIFNaoPro
										If nRegExist == 1 //Foi Selecionado para sobrepor os registros
											aAdd(aLog,{	Alltrim(aLinha[18]),;
											LOG_INFO,;
											STR0030 + cUserName})			//"Ja gravado. Foi substituido o registro, conforme selecionado pelo usuario "

											RecLock("FIF",.F.)
											FIF->(DBDelete())
											FIF->(MsUnlock())

											nQtdAlt++
											lIncVnd := .T.
										ElseIf nRegExist == 2 //Foi selecionado para pular o registro
											aAdd(aLog,{	Alltrim(aLinha[18]),;
											LOG_INFO,;
											STR0031 + cUserName})			//"Ja gravado. Foi pulado o registro, conforme selecionado pelo usuario "
											nQtdImp++
											lIncVnd := .F.	
											cDescLeg := STR0031 + cUserName		
										EndIf
									Else
										aAdd(aLog,{	Alltrim(aLinha[18]),;
										LOG_ERRO,;
										STR0032 + FIF->FIF_STATUS + STR0033})		//"Registro ja gravado e com status modificado ("	### ") do status original (1)"
										lIncVnd := .F.
										cDescLeg := STR0032 + FIF->FIF_STATUS + STR0033
									EndIf		
								EndIf               	   	

								If lIncVnd
									lIncVnd	:= Fa914VldImp(aLinha[200_LJSIT], "SOFEX") // Valida se filial poderá ser importada (FVZ)
									
									If lIncVnd
										nQtdFilOk++
									EndIf
								EndIf	

								lCarEsp := FINCARCESP(cNSUSitef,cNuComp,@lNsuTef,@lNuComp)
								
								If lIncVnd .and. !lCarEsp

									If((aParc[nI,3] == '0') .Or. (aParc[nI,3] == '00'))
										cNPARC := StrZero(Val("01"),nTamParcel)
									Else
										cNPARC := StrZero(Val(aParc[nI,3]),nTamParcel)
									EndIf

									_cConta := ALLTRIM(aParc[nI,9])
									cSeqFIF := A910SeqFIF(aLinha[200_DTVND] ,aLinha[200_NSUST], aParc[nI,3], aLinha[200_LJSIT], aParc[nI,3])

									If cMsFilAnt <> aLinha[200_LJSIT]
										cMsFil := Fa914MsFil( aLinha[200_LJSIT], "SOFEX" )
										
										cMsFilAnt := aLinha[200_LJSIT] 
									EndIf	  		   			  					

									If cVerCon == "V2.0"
										cCodBan := ""
									Else
										CCodBan := aLinha[200_CBAND]
									EndIf

									If lFin910fil
										cFilFif := ExecBlock("FIN910FIL",.F.,.F.,aLinha)
									Else
										cFilFif := xFilial("FIF", cMsFil)
									EndIf

									If ValType(aLinha[09]) == "C"
										cValliq	:= SubStr(aLinha[09],1,Len(aLinha[09]) - 2)
										cValliq	+=  "." + SubStr(aLinha[09],Len(aLinha[09]) - 1,Len(aLinha[09]))
									EndIf

									If Len(aLinha) > 18
										cSeqReg := aLinha[18]
									EndIf

									aAdd(aDados,{	{"FIF_FILIAL"	,cFilFif			,Nil},;
									{"FIF_TPREG"	,aLinha[200_TPREG]					,Nil},;
									{"FIF_INTRAN"	,aLinha[200_IDTRA]					,Nil},;
									{"FIF_CODEST"	,aLinha[200_ESTAB]					,Nil},;
									{"FIF_DTTEF"	,Stod(aLinha[200_DTVND])			,Nil},;
									{"FIF_NURESU"	,aLinha[200_NRESU]					,Nil},;
									{"FIF_NUCOMP"	,cNuComp							,Nil},;
									{"FIF_NSUTEF"	,cNSUSitef							,Nil},;
									{"FIF_NUCART"	,aLinha[200_NCART]					,Nil},;
									{"FIF_VLBRUT"	,Round(aParc[nI,5],nDecVlBrut)		,Nil},; //Valor antes da antecipacao
									{"FIF_TOTPAR"	,aLinha[200_TOTPA]					,Nil},;
									{"FIF_VLLIQ"	,Round(Val(cValliq),nDecVlliq)		,Nil},; //Valor antecipado
									{"FIF_DTCRED"	,Stod(aParc[nI,4])					,Nil},;
									{"FIF_PARCEL"	,cNPARC								,Nil},;
									{"FIF_TPPROD"	,aLinha[200_TPPRO]					,Nil},;
									{"FIF_CAPTUR"	,aLinha[200_CAPTU]					,Nil},;
									{"FIF_CODRED"	,Alltrim(Str(Val(aLinha[200_IDRED])))	,Nil},;
									{"FIF_CODBCO"	,aParc[nI,7]						,Nil},;
									{"FIF_CODAGE"	,xStrCmp("FIF_CODAGE",aParc[nI,8])	,Nil},;
									{"FIF_NUMCC"	,xStrCmp("FIF_NUMCC",_cConta)		,Nil},;
									{"FIF_VLCOM"	,0									,Nil},;
									{"FIF_TXSERV"	,0									,Nil},;
									{"FIF_CODLOJ"	,aLinha[200_LJSIT]					,Nil},;
									{"FIF_CODAUT"	,cCodAut							,Nil},;		
									{"FIF_CUPOM"	,aLinha[200_CFISC]					,Nil},;	
									{"FIF_SEQREG"	,cSeqReg							,Nil},;
									{"FIF_STATUS"	,"6"								,Nil},;
									{"FIF_STVEND"	,""									,Nil},; 
									{"FIF_CODADM"	,cCodSOFEX							,Nil},;
									{"FIF_MSIMP"	,dHoje								,Nil},;
									{"FIF_CODFIL"	,cMsFil								,Nil},;									
									{"FIF_CODBAN"	,cCodBan							,Nil},;									
									{"FIF_DTANT"	,Stod(aParc[nI,4])					,Nil},;														
									{"FIF_SEQFIF"	,cSeqFIF							,Nil},;						
									{"FIF_ARQPAG"	,cNomArq							,Nil},;						
									{"FIF_DTIMP"	,dDatabase							,Nil},;						
									{"FIF_PARALF"	,Chr(64 + Val(cNPARC))				,Nil}})
									
									nQtdLinha++
									nQtdLida++
								
									//Armazeno os registros 200 em tabela temporária para posterior tratamento
									(cArqReg200)->(DbAppend())
									(cArqReg200)->CODEST	:= aLinha[200_ESTAB]
									(cArqReg200)->CODLOJ	:= aLinha[200_LJSIT]
									(cArqReg200)->NURESU	:= aLinha[200_NRESU]
									(cArqReg200)->NCOMP		:= aLinha[200_NCOMP]	
									(cArqReg200)->DTVEND	:= aLinha[200_DTVND]
									(cArqReg200)->NSUTEF	:= cNSUSitef
									(cArqReg200)->VLR200	:= Round(Val(aLinha[200_VLBRT])/100,nDecVlliq)
									(cArqReg200)->CUPOM		:= aLinha[200_CFISC]
									If Len(aLinha) > 18 
										(cArqReg200)->DTSITEF	:= aLinha[200_DTCRD]
									EndIf
									(cArqReg200)->PARC		:= aParc[ nI,3 ]
									(cArqReg200)->TOTPA		:= aLinha[200_TOTPA]
									(cArqReg200)->DTTEF     := aLinha[200_DTVND]
									(cArqReg200)->SEQFIF    := cSeqFIF
									(cArqReg200)->KEYFIF	:= cFilFif + (cArqReg200)->DTTEF + (cArqReg200)->NSUTEF + cNPARC + (cArqReg200)->CODLOJ + aParc[nI,4] + (cArqReg200)->SEQFIF
																																					
									If lFINFIF
										aDfif := ExecBlock("FINFIF",.F.,.F.,aDados)
										If Valtype(aDfif) == "A"
											aDados := Aclone(aDfif)
										EndIf
									EndIf

									If Alltrim(cEstab) = '000000007948428'
										If aLinha[200_NRESU] = '70529'
											nEx2	:=	nEx2 + 1
										ElseIf  aLinha[200_NRESU] $ '20526_20527_20528'
											nEx1	:=	nEx1 + 1								   
										Endif								
									EndIf

									//Tratamento para que somente uma vez seja estanciada a variavel lTemVnd,
									// que determina a existencia de um item o tipo Detalhe.
									If lFirst
										lTemVnd := .T.
										lFirst	:= .F.
									EndIf
								ElseIf lCarEsp
									nQtdNProc++	
									lCarEsp  := .F.
									F914GrvLog('2',cIdProc,AllTrim(Str(nLinTotal)),cNomArq,dDataBase,cHoraIni,aLinha[200_ESTAB],Iif(lNsutef,cNSUSitef,cNuComp),STR0064,"") // Grava detalhes do Log
									lNsuTef  := .F.
									lNuComp  := .F.

									cDescLeg := STR0064
								ElseIf Empty(Fa914MsFil(aLinha[200_LJSIT], "SOFEX"))			
									nQtdNProc++
									lCarEsp  := .F.
									F914GrvLog('2',cIdProc,AllTrim(Str(nLinTotal)),cNomArq,dDataBase,cHoraIni,aLinha[200_ESTAB],Iif(lNsutef,cNSUSitef,cNuComp),STR0062,"")

									cDescLeg := STR0062
								ElseIf !lIncVnd .And. !lAltera
									nQtdNProc++
									lCarEsp  := .F.
									F914GrvLog('2',cIdProc,AllTrim(Str(nLinTotal)),cNomArq,dDataBase,cHoraIni,aLinha[200_ESTAB],Iif(lNsutef,cNSUSitef,cNuComp),STR0065,"") // Grava detalhes do Log

									cDescLeg := STR0065
								ElseIf !lAltera
									nQtdNProc++	
									lCarEsp  := .F.
									F914GrvLog('2',cIdProc,AllTrim(Str(nLinTotal)),cNomArq,dDataBase,cHoraIni,aLinha[200_ESTAB],Iif(lNsutef,cNSUSitef,cNuComp),STR0068,"") // Grava detalhes do Log
								EndIf
							Next																				
						Endif					
					Else
						aAdd(aLog,{	"000000",;
						LOG_ERRO,;
						STR0034 + Alltrim(Str(Len(aLinha))) + STR0023 + Alltrim(Str(nPosToReg)) + ")"})			//"Detalhes ("	### ") nao possui todos os campos que deveria ("
						lTemRod := .F.
						lIncVnd := .F.
						nQtdNProc++
					EndIf
				ElseIf lTemHead .And. Alltrim(aLinha[1]) == "1"		// Detalhes do arquivo							
					lIncVnd := .T.         

					If cVerCon == "V3.0" .and. Len(aLinha) > nVPosToReg
						nVPosSqReg 	:= 28
						nVPosToReg 	:= 28
					ElseIf cVerCon == "V3.6" .and. Len(aLinha) > nVPosToReg	.and. Len(aLinha) <=30
						nVPosSqReg 	:= Len(aLinha)
						nVPosToReg 	:= Len(aLinha)
					EndIf	

					If Len(aLinha) == nVPosToReg
											
						If Val(aLinha[nVPosSqReg]) <> nSeq
							aAdd(aLog,{	Alltrim(aLinha[nVPosSqReg]),;
							LOG_ERRO,;
							STR0020 + Alltrim(aLinha[nVPosSqReg]) + STR0025 + StrZero(nSeq,6) + ")"})		//"Numero de Sequencia do arquivo ("	### ") errado para o Detalhe ("
							lIncVnd := .F.
						EndIf

						//Verifica se o registro ja existe na base de dados
						cNSUSitef 	:= PADR("", nTamNSUTEF - len(Alltrim(aLinha[V_DT_NSUST])),'0') + Alltrim(aLinha[V_DT_NSUST])
						cNuComp 	:= PADR("", nTamNuComp - len(Alltrim(aLinha[V_DT_NCOMP])),'0') + Alltrim(aLinha[V_DT_NCOMP])
						cParcela	:= aLinha[V_DT_NPARC]
						cEstab		:= Alltrim(aLinha[V_DT_ESTAB]) + Space(nTamCodEst - Len(Alltrim(aLinha[V_DT_ESTAB])) )								
						cIdRed		:= Alltrim(aLinha[V_DT_IDRED]) + Space(nTAmCodRed - Len(Alltrim(aLinha[V_DT_IDRED])) )												
						cCodLoj     := Alltrim(aLinha[V_DT_LJSIT]) + Space(nTAmCodFil - Len(Alltrim(aLinha[V_DT_LJSIT])) )								
						cCodAut		:= Right(aLinha[V_DT_AUTOR],6)

						cParc := StrZero(Val(cParcela),nTamParcel)

						If cParcela == '00'
							cParc := StrZero(Val("1"),nTamParcel)
						Endif	

						cTef := RIGHT(cNSUSitef,12)	
						cTef += Space(nTamNSUTEF - len(Alltrim(RIGHT(cNSUSitef,12))))		   

						lContinua := Fa910Cont(aLinha[V_DT_DTVND], cTef, cNSUSitef, cParc, cCodAut, cCodLoj)

						If lContinua

							If (nRegExist == 0 .AND. FIF->FIF_STATUS $ __cFIFNaoPro) .Or. FIF->FIF_STVEND = '1'
								If !lAutomato
									lOpt :=  Aviso(STR0026,STR0027,{STR0028,STR0029},2,STR0002) == 1 //"Atenção"	### "Existem registros no arquivo que ja constam como importados. Deseja que todos os registros nessa mesma situação sejam?"	### Substituir	### Pular Registro	"Conciliação TEF"
								EndIf
								If lOpt
									nRegExist := 1
								Else
									nRegExist := 2
								EndIf
							EndIf

							If FIF->FIF_STATUS $ __cFIFNaoPro .Or. FIF->FIF_STVEND = '1'
								If nRegExist == 1 //Foi Selecionado para sobrepor os registros
									aAdd(aLog,{	Alltrim(aLinha[nVPosSqReg]),;
									LOG_INFO,;
									STR0030 + cUserName})			//"Ja gravado. Foi substituido o registro, conforme selecionado pelo usuario "

									RecLock("FIF",.F.)
									FIF->(DBDelete())
									FIF->(MsUnlock())

									nQtdAlt++
									lIncVnd := .T.
								ElseIf nRegExist == 2 //Foi selecionado para pular o registro
									aAdd(aLog,{	Alltrim(aLinha[nVPosSqReg]),;
									LOG_INFO,;
									STR0031 + cUserName})			//"Ja gravado. Foi pulado o registro, conforme selecionado pelo usuario "
									nQtdImp++
									lIncVnd := .F.			
								EndIf
							Else
								aAdd(aLog,{	Alltrim(aLinha[nVPosSqReg]),;
								LOG_ERRO,;
								STR0032 + FIF->FIF_STATUS + STR0033})		//"Registro ja gravado e com status modificado ("	### ") do status original (1)"
								lIncVnd := .F.
							EndIf

						EndIf

						If lIncVnd
							
							lIncVnd	:= Fa914VldImp(aLinha[V_DT_LJSIT], "SOFEX") // Valida se filial poderá ser importada (FVZ)
							
							If lIncVnd
								nQtdFilOk++
							EndIf
						EndIf	

						lCarEsp := FINCARCESP(cNSUSitef,cNuComp,@lNsuTef,@lNuComp)
						
						If lIncVnd .and. !lCarEsp                        

							If((aLinha[V_DT_NPARC] == '0') .OR. (aLinha[V_DT_NPARC] == '00'))
								cNPARC := StrZero(Val("01"),nTamParcel)
							Else
								cNPARC := STRZERO(VAL(aLinha[V_DT_NPARC]),nTamParcel)
							EndIf
							
							_cConta := ALLTRIM(aLinha[V_DT_CDCC]) 

							cSeqFIF := A910SeqFIF(aLinha[V_DT_DTVND] ,aLinha[V_DT_NSUST], aLinha[V_DT_NPARC], aLinha[V_DT_LJSIT], ;
							aLinha[V_DT_DTCRD])

							If cMsFilAnt <> cCodloj
								cMsFil := Fa914MsFil( aLinha[V_DT_LJSIT], "SOFEX" )
								cMsFilAnt := cCodloj 
							EndIf	

							If cVerCon == "V2.0"
								cCodBan := ""
							Else
								CCodBan := aLinha[V_DT_CBAND]
							EndIf

							If lFin910fil
								cFilFif := ExecBlock("FIN910FIL",.F.,.F.,aLinha)
							Else
								cFilFif := xFilial("FIF", cMsFil)
							EndIf

							If aLinha[V_DT_TPPRO]	== "H"
								aLinha[V_DT_TPPRO] := "D"
							ElseIf aLinha[V_DT_TPPRO]	== "E"
								aLinha[V_DT_TPPRO] := "C"
							Endif
													
							aAdd(aDados,{	{"FIF_FILIAL"	,cFilFif		   											,Nil},;
											{"FIF_TPREG"	,aLinha[V_DT_TPREG]											,Nil},;
											{"FIF_INTRAN"	,aLinha[V_DT_IDTRA]											,Nil},;
											{"FIF_CODEST"	,aLinha[V_DT_ESTAB]											,Nil},;
											{"FIF_DTTEF"	,sTod(aLinha[V_DT_DTVND])									,Nil},;
											{"FIF_NURESU"	,aLinha[V_DT_NRESU]											,Nil},;
											{"FIF_NUCOMP"	,cNuComp													,Nil},;
											{"FIF_NSUTEF"	,cNSUSitef													,Nil},;
											{"FIF_NUCART"	,aLinha[V_DT_NCART]											,Nil},;
											{"FIF_VLBRUT"	,Round(Val(aLinha[V_DT_VLBRT])/100,nDecVlBrut)				,Nil},;
											{"FIF_TOTPAR"	,aLinha[V_DT_TOTPA]								 			,Nil},;
											{"FIF_VLLIQ"	,Round(Val(aLinha[V_DT_VLLIQ])/100,nDecVlliq)				,Nil},;
											{"FIF_DTCRED"	,sTod(aLinha[V_DT_DTCRD])									,Nil},;
											{"FIF_PARCEL"	,cNPARC														,Nil},;
											{"FIF_TPPROD"	,aLinha[V_DT_TPPRO]											,Nil},;
											{"FIF_CAPTUR"	,aLinha[V_DT_CAPTU]											,Nil},;
											{"FIF_CODRED"	,Alltrim(Str(Val(aLinha[V_DT_IDRED])))						,Nil},;
											{"FIF_CODBCO"	,aLinha[V_DT_CDBCO]											,Nil},;
											{"FIF_CODAGE"	,xStrCmp("FIF_CODAGE",aLinha[V_DT_CDAGE])					,Nil},;
											{"FIF_NUMCC"	,xStrCmp("FIF_NUMCC",_cConta)								,Nil},;
											{"FIF_VLCOM"	,Round(Val(aLinha[V_DT_VLCOM])/100,nDecVlCom)				,Nil},;
											{"FIF_TXSERV"	,Round(Val(aLinha[V_DT_VLTXS])/100,nDecTxServ)				,Nil},;
											{"FIF_CODLOJ"	,aLinha[V_DT_LJSIT]											,Nil},;
											{"FIF_CODAUT"	,cCodAut													,Nil},;		
											{"FIF_CUPOM"	,aLinha[V_DT_CFISC]										    ,Nil},;	
											{"FIF_SEQREG"	,aLinha[nVPosSqReg]											,Nil},;
											{"FIF_CODADM"	,cCodSOFEX													,Nil},;
											{"FIF_MSIMP"	,dHoje														,Nil},;
											{"FIF_CODFIL"	,cMsFil							   							,Nil},;									
											{"FIF_CODBAN"	,cCodBan            								        ,Nil},;									
											{"FIF_SEQFIF"	,cSeqFIF           								            ,Nil},;
											{"FIF_PARALF"   ,Chr(64 + Val(cNPARC))										,Nil},;
											{"FIF_DTIMP"	,dDatabase													,Nil}})
							
							If __lMVCONCV
								aAdd(aDados[Len(aDados)], {"FIF_ARQVEN", cNomArq, Nil})
								aAdd(aDados[Len(aDados)], {"FIF_STVEND", "1", Nil})
							Else
								aAdd(aDados[Len(aDados)], {"FIF_ARQPAG", cNomArq, Nil})
								aAdd(aDados[Len(aDados)], {"FIF_STATUS", "1", Nil})
							EndIf

							nQtdLinha++
							nQtdLida++
							
							If lFINFIF
								aDfif := ExecBlock("FINFIF",.F.,.F.,aDados)
								If Valtype(aDfif) == "A"
									aDados := Aclone(aDfif)
								EndIf
							EndIf	

							// Tratamento para que somente uma vez seja estanciada avariavel lTemVnd,
							// que determina a existencia de um item do tipo Detalhe.
							If lFirst
								lTemVnd := .T.
								lFirst	:= .F.
							EndIf
						ElseIf lCarEsp 
							nQtdNProc++
							lCarEsp  := .F.
							F914GrvLog('2',cIdProc,AllTrim(Str(nLinTotal)),cNomArq,dDataBase,cHoraIni,aLinha[V_DT_ESTAB],Iif(lNsutef,cNSUSitef,cNuComp),STR0064,"") // Grava detalhes do Log
							lNsuTef  := .F.
							lNuComp  := .F.	

							cDescLeg := STR0064
						ElseIf Empty(Fa914MsFil(aLinha[V_DT_LJSIT], "SOFEX"))			
							nQtdNProc++
							F914GrvLog('2',cIdProc,AllTrim(Str(nLinTotal)),cNomArq,dDataBase,cHoraIni,aLinha[V_DT_ESTAB],Iif(lNsutef,cNSUSitef,cNuComp),STR0062,"") // Grava detalhes do Log
						
							cDescLeg := STR0062
						ElseIf !lIncVnd
							nQtdNProc++
							F914GrvLog('2',cIdProc,AllTrim(Str(nLinTotal)),cNomArq,dDataBase,cHoraIni,aLinha[V_DT_ESTAB],Iif(lNsutef,cNSUSitef,cNuComp),STR0065,"") // Grava detalhes do Log
						
							cDescLeg := STR0065					
						Else
							nQtdNProc++
							lCarEsp  := .F.
							F914GrvLog('2',cIdProc,AllTrim(Str(nLinTotal)),cNomArq,dDataBase,cHoraIni,aLinha[V_DT_ESTAB],Iif(lNsutef,cNSUSitef,cNuComp),STR0068,"") // Grava detalhes do Log
						EndIf
					Else
						aAdd(aLog,{	"000000",;
						LOG_ERRO,;
						STR0034 + Alltrim(Str(Len(aLinha))) + STR0023 + Alltrim(Str(nVPosToReg)) + ")"})		//"Detalhes ("	### ") nao possui todos os campos que deveria ("
						lTemRod := .F.						
						lIncVnd := .F.
						nQtdNProc++
					EndIf   

				ElseIf lTemHead .And. Alltrim(aLinha[1]) == "9"		// Trailler

					lTemRod := .T.				
					
					If Len(aLinha) == TR_TOTRG
						
						nQtdLida++
						
						If Val(aLinha[TR_SQREG]) <> nSeq
							aAdd(aLog,{	Alltrim(aLinha[Len(aLinha)]),;
							LOG_ERRO,;
							STR0020 + Alltrim(aLinha[Len(aLinha)]) + STR0021 + StrZero(nSeq,6) + ")"})		//"Numero de Sequencia do arquivo ("	### ") errado para o Trailer ("
							lTemHead := .F.
						EndIf

					Else
						aAdd(aLog,{	"000000",;
						LOG_ERRO,;
						STR0022 + Alltrim(Str(Len(aLinha))) + STR0023 + Alltrim(Str(TR_TOTRG)) + ")"})		//"Header ("	### ") nao possui todos os campos que deveria ("
						lTemRod := .F.
						nQtdNProc++
					EndIf
				
				ElseIf lTemHead
					nQtdNProc++
				EndIf
				
				//Soma um no sequenciador do arquivo
				nSeq++
			End
		End Transaction
		MsUnlockAll()

		If !lDisarmTran

			//Verifico se todos os dados do arquivo estao corretos e chamo a rotina para gravar as informacoes na tabela
			If lTemHead .AND. lTemVnd .AND. lTemRod .And. Len(aDados) > 0
				A910GrvArq( aDados )
			EndIf

			ConoutR("Conciliador TEF - FINA910B - A910VldArq - FIM IMPORTANDO ARQUIVO - " + DToC(Date()) + " - Hora: " + TIME())
		Else
			lRet := .F.
			ConoutR("Conciliador TEF - FINA910B - A910VldArq - PROCESSO ABORTADO - " + DToC(Date()) + " - Hora: " + TIME())
		EndIf
		


	ElseIf !lContinua
		// O Parametro MV_EMPTEF não esta exclusivo por filial.
		Help(" ",1,"A910PARAM",,STR0062 ,1,0,,,,,,{STR0063})
		// Para o correto funcionamento da rotina é necessário que esse parametro esteja exclusivo por filial!"
		lRet := .F. 
	Else 
		MsgInfo(STR0007 + cCamArq + STR0037 )		//"Arquivo "	### " nao possui registros"
		lRet := .F.
	EndIf

	If lContinua .and. Select( cArqReg100 ) > 0 .And. Select( cArqReg200 ) > 0
		A910ATUFIF( cArqReg100, cArqReg200 )
	EndIf

	If(_oFINA910B <> NIL)
		_oFINA910B:Delete()
		_oFINA910B := NIL
	EndIf

	If(_oImp200B <> NIL)
		_oImp200B:Delete()
		_oImp200B := NIL
	EndIf

      
	aDados := aSize(aDados,0)
	aDados := nil
	fClose( nHdlFile)
	UnlockByName("FINA910B"+cEmpAnt, .F., .F. )

Return lRet

/*/{Protheus.doc} A910SeqFIF
	Retorna o proximo numero do campo FIF_SEQFIF

	@type static function
	@author TOTVS
	@since 08/11/09
/*/
Static Function A910SeqFIF(cDtVend, cNsuTef, cParcela, cCodLoja, ;
	cDtCred)

	Local aOrdFIF := FIF->(GetArea())
	Local cQuery := ""

	cNsuTef		:= Alltrim(cNsuTef)  + Space(nTamNSUTEF - Len(Alltrim(cNsuTef)))
	cParcela	:= Alltrim(cParcela) + Space(nTamParcel - Len(Alltrim(cParcela)))				
	cCodLoja    := Alltrim(cCodLoja) + Space(nTAmCodFil - Len(Alltrim(cCodLoja)))

	// se cSeqFif em branco, ainda não buscou o ultimo sequencial
	If Empty(cSeqFIF)                                      
		cQuery := " SELECT MAX(FIF_SEQFIF) MAXFIF FROM " + RetSqlName("FIF") 
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRB")
		If TRB->(!Eof())                      
			cSeqFIF := Soma1(TRB->MAXFIF) 
		Else                        
			cSeqFIF := Soma1("000000")	   	
		EndIf   	
		TRB->(DbCloseArea())
	Else
		//se já estiver preenchido o sequencial, só somar 1 
		cSeqFIF := Soma1(cSeqFIF)
	EndIf

	RestArea(aOrdFIF)

Return cSeqFIF

/*/{Protheus.doc} A910GrvArq
	Funcao que efetua a gravacao dos registrosn na tabela FIF
	(Conciliacao do SITEF)

	@type function
	@author Rafael Rosa da Silva
	@since 08/12/09
/*/
Static Function A910GrvArq(aDados)

	Local nI			:= 0
	Local nX			:= 0
	Local nFator 		:= If(Len(aDados) > 2000, 1000, 1)

	dbSelectArea("FIF")

	CONOUTR("Conciliador TEF - FINA910B - A910GrvArq - INICIO GRAVANDO ARQUIVO - " + DToC(Date()) + " - Hora: " + TIME())

	BeginTran()
	For nI := 1 to Len(aDados)
		If nI%nFator == 0  
			EndTran()
			BeginTran()
		EndIf	 
		RecLock("FIF",.T.)
		For nX := 1 to Len(aDados[nI])
				FIF->&(aDados[nI][nX][1]) := aDados[nI][nX][2]
		Next nX

		FIF->( MsUnLock() )
	Next nI
	EndTran()

	CONOUTR("Conciliador TEF - FINA910B - A910GrvArq - FIM GRAVANDO ARQUIVO - " + DToC(Date()) + " - Hora: " + TIME())

Return

/*/{Protheus.doc} A910GrvLog
	Funcao que efetua a gravacao dos Logs

	@type function
	@author Rafael Rosa da Silva
	@since 08/12/09
/*/
Static Function A910GrvLog(aLog)

	Local cType := STR0038 + STR0039
	Local cDir	:= cGetFile(cType ,STR0040,0,,.F.,GETF_LOCALHARD + GETF_NETWORKDRIVE + GETF_RETDIRECTORY)
	Local nHdl	:= 0 
	Local cDados:= "" 
	Local nI	:= 0 
	Local cLin	:= ""
	Local cEOL	:= CHR(13)+CHR(10) 
	Local nFator := If(Len(alog) > 2000, 1000, 1)

	//Incluo o nome do arquivo no caminho ja selecionado pelo usuario
	cDir := Upper(Alltrim(cDir)) + "LOG_FINA910_" + dTos(dDataBase) + StrTran(Time(),":","") + ".LOG"

	If (nHdl := FCreate(cDir)) == -1
		MsgInfo(STR0041 + cDir + STR0042)			//"O arquivo de nome "	### " nao pode ser executado! Verifique os parametros."
		Return
	EndIf

	cDados	:= STR0043								//"Linha da Ocorrencia;Tipo da Ocorrencia;Descricao da Ocorrencia"
	cLin	:= Space(Len(cDados)) + cEOL
	cLin	:= Stuff(cLin,01,Len(cDados),cDados)

	If FWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
		If Aviso(STR0026,STR0044,{STR0045,STR0046}) == 2		//"Atencao"	### "Ocorreu um erro na gravacao do arquivo. Continua?"	### "Sim"	### "Não"
			FClose(nHdl)
			Return
		EndIf
	EndIf

	CONOUTR("Conciliador TEF - FINA910B - A910GrvLog - INICIO GRAVANDO LOG - " + DToC(Date()) + " - Hora: " + TIME())

	ProcRegua(Len(aLog)/nFator)                      

	For nI := 1 to Len(aLog)

		If nI%nFator == 0
			IncProc(STR0036 + "(" + AllTrim(Str(nI)) + "/" + AllTrim(Str(Len(aLog))) + ")")			//"Gravando os Log's..."
		EndIf
		cDados	:= aLog[nI][1] + ';' + aLog[nI][2] + ';' + aLog[nI][3]
		cLin	:= Space( Len(cDados) ) + cEOL
		cLin	:= Stuff(cLin,01,Len(cDados),cDados)

		If FWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
			If Aviso(STR0026,STR0044,{STR0045,STR0046}) == 2		//"Atencao"	### "Ocorreu um erro na gravacao do arquivo. Continua?"	### "Sim"	### "Não"
				FClose(nHdl)
				Return
			EndIf
		EndIf
	Next nI

	FClose(nHdl)

	CONOUTR("Conciliador TEF - FINA910B - A910GrvLog - FIM GRAVANDO LOG - " + DToC(Date()) + " - Hora: " + TIME())

Return

/*/{Protheus.doc} A910CarFil
	Carrega as filiais do parametro MV_EMPTEF mediante loja TEF

	@type function
	@author Rafael Rosa da Silva
	@since 18/03/11
/*/
Static Function A910CarFil()

	Local cFilSitef := ''
	Local lRet 		:= .F.
	Local aArrFil   as Array 
	Local nX		as Numeric

	oParamFil := LJCHashTable():New()

	// Recupera todas as filias 
	aArrFil := FWAllFilial(,,,.F.)

	For nX := 1 to Len(aArrFil)
		cFilSitef := SuperGetMv("MV_EMPTEF",.F.,"",aArrFil[nX])
		If !Empty(cFilSitef)
			oParamFil:Add(UPPER(ALLTRIM(cFilSitef)), aArrFil[nX])
			lRet := .T. 
		EndIf 
	Next nX 

Return lRet

/*/{Protheus.doc} A910MsFil
	Pega filial do parametro MV_EMPTEF mediante loja TEF

	@type function
	@author Rafael Rosa da Silva
	@since 18/03/11
/*/
Static Function A910MsFil(cFifCodLoj)

	Local cRetorno  := ''

	If oParamFil:Count() > 0
		If oParamFil:Contains(UPPER(ALLTRIM(cFifCodLoj)))
			cRetorno := oParamFil:ElementKey(UPPER(ALLTRIM(cFifCodLoj)))
		Else
			cRetorno := Space(nTAmCodFil)
		EndIf
	Else
		cRetorno := Space(nTAmCodFil)
	EndIf

Return cRetorno

/*/{Protheus.doc} A910ATUFIF
Função para atualizar os registros da tabela FIF após o processamento
do arquivo SiTef, adequando os valores de parcela dos registros de
antecipação

@type Static Function

@author Pedro Pereira Lima
@since 09/06/2017
@version 11.80
/*/
Static Function A910ATUFIF( cArqReg100, cArqReg200 )
	Local nValOrig	:= 0
	Local nValAnt	:= 0
	Local nValTot	:= 0
	Local aArea		:= GetArea()
	Local nTxServ 	:= 0 
	Local nVlLiq 	:= 0

	(cArqReg100)->(DbGoTop())
	(cArqReg200)->(DbGoTop())

	While !(cArqReg100)->(Eof())

		If (cArqReg100)->PARC == "00" //Lote "aglutinado"  

			nValTot := 0

			nValAnt100 := (cArqReg100)->VRANT

			If (cArqReg200)->( DbSeek( (cArqReg100)->( CODEST + CODLOJ + NRORES ) ) ) // CODEST + CODLOJ + NURESU

				While !(cArqReg200)->( Eof() ) .And. (cArqReg100)->( CODEST + CODLOJ + NRORES ) == (cArqReg200)->( CODEST + CODLOJ + NURESU )
					FIF->( DbSetOrder(5) )
					FIF->( DbSeek( (cArqReg200)->KEYFIF ) )
					nValTot += FIF->FIF_VLLIQ
					(cArqReg200)->( DbSkip() )
				EndDo

				(cArqReg200)->( DbGoTop() )

				(cArqReg200)->( DbSeek( (cArqReg100)->( CODEST + CODLOJ + NRORES ) ) )

				While !(cArqReg200)->( Eof() ) .And. (cArqReg100)->( CODEST + CODLOJ + NRORES ) == (cArqReg200)->( CODEST + CODLOJ + NURESU )

					FIF->( DbSetOrder(5) )
					If FIF->( DbSeek( (cArqReg200)->KEYFIF ) )

						nValOrig	:= FIF->FIF_VLLIQ //Valor "bruto"
						nValAnt		:= Round( ( nValOrig * nValAnt100 ) / nValTot , nDecVlliq ) //Valor "antecipado"

						RecLock('FIF',.F.)
						FIF->FIF_VLBRUT	:= nValOrig
						FIF->FIF_VLLIQ	:= nValAnt
						MsUnlock()
					EndIf

					(cArqReg200)->( DbSkip() )
				EndDo

			EndIf

		Else //Lote de parcelas normais, apenas acerto o valor já existente no registro 100

			If (cArqReg200)->( DbSeek( (cArqReg100)->( CODEST + CODLOJ + NRORES ) ) ) // CODEST + CODLOJ + NURESU

				While !(cArqReg200)->( Eof() ) .And. (cArqReg100)->( CODEST + CODLOJ + NRORES ) == (cArqReg200)->( CODEST + CODLOJ + NURESU )

					If (cArqReg100)->PARC == (cArqReg200)->PARC

						nValOrig:= (cArqReg200)->VLR200 / Val((cArqReg200)->TOTPA)
						nTxServ := (cArqReg100)->VRANT /(cArqReg100)-> VRBRUTO
						nVlLiq  := Round (nValOrig * nTxServ, nTamVLLIQ)
					
						FIF->( DbSetOrder(5) )
						If FIF->( DbSeek( (cArqReg200)->KEYFIF ) )
							RecLock('FIF',.F.)
							If Round(nValOrig,nTamVLLIQ) == nVlLiq
								FIF->FIF_VLBRUT	:= (cArqReg100)->VRORIG
								FIF->FIF_VLLIQ	:= (cArqReg100)->VRANT
							Else
								FIF->FIF_VLBRUT	:= nValOrig
								FIF->FIF_VLLIQ	:= nVlLiq
							Endif
							MsUnlock()
						EndIf
				
					EndIf

					(cArqReg200)->( DbSkip() )
				EndDo

			EndIf

		EndIf

		(cArqReg100)->(DbSkip())

	EndDo

	RestArea( aArea )
Return

/*/{Protheus.doc} xStrCmp
Função criada para atender a issue DSERFINR-3197 - Conciliação SITEF

@param cCampo    = Campo a ser considerado na tratativa
@param cConteudo = Conteudo que será tratado para posterior gravação

@return cRet	 = String tratada respeitando a estrutura dos campos

@author Rodrigo dos Santos
@since 06/11/2019
@version 1.0
/*/
Static Function xStrCmp(cCampo As Character,cConteudo As Character) As Character
	Local cRet	As Character

	Default cCampo 		:= ""
	Default cConteudo	:= ""

	If cCampo == "FIF_CODAGE"
		If Len(Alltrim(cConteudo)) > nTamAgen
			cRet := SubStr(Alltrim(cConteudo),(Len(Alltrim(cConteudo))-nTamAgen)+1,nTamAgen)
		Else
			cRet := Alltrim(cConteudo)
		EndIf
	ElseIf cCampo == "FIF_NUMCC"
		If Len(Alltrim(cConteudo)) > nTamConta
			cRet := SubStr(Alltrim(cConteudo),(Len(Alltrim(cConteudo))-nTamConta)+1,nTamConta)
		Else
			cRet := Alltrim(cConteudo)
		EndIf
	EndIf

Return cRet

/*/{Protheus.doc} AtuRegVend
Atualiza o registro de conciliação de venda para pagamento.

@param cNomarq  = Nome do arquivo importado
@param cTipoReg = Tipo do registro (10 Crédito / 200 Antecipação)

@author Alberto Teixeira
@since 13/10/2022
@version 1.0
/*/
Static Function AtuRegVend( cNomArq As Character, cTipoReg As Character)

	Local cStatus	As Character

	Default cNomArq		:= ""
	Default cTipoReg 	:= ""
	
	cStatus	:= "1"

	If cTipoReg == "200"
		cStatus := "6"
	EndIF

	RecLock("FIF", .F.)
		FIF->FIF_ARQPAG	:= cNomArq
		FIF->FIF_STATUS	:= cStatus
		FIF->FIF_TPREG	:= SubStr(cTipoReg,1,2)
	FIF->(MsUnlock())

Return .T.

/*/{Protheus.doc} Fa910Cont
Verifica se ja existe o registro importado na tabela FIF.

@param cNomarq  = Nome do arquivo importado
@param cTipoReg = Tipo do registro (10 Crédito / 200 Antecipação)

@author Alberto Teixeira
@since 23/12/2022
@version 1.0
/*/
Static Function Fa910Cont(cDtVend As Character, cTef As Character, cNSUSitef As Character, cParc As Character, cCodAut As Character, cCodLoj As Character, cDtCred as Character) As Logical

	Local cQry 		As Character
	Local cDelete	As Character
	Local cFilImp	As Character
	Local lRet 		As Logical
	Local lContinua	As Logical
	Local nParam	As Numeric
	Local nRecnoFIF	As Numeric

	cQry		:= ""
	cDelete		:= Space(1)
	cFilImp		:= cFilAnt
	lRet		:= .F.
	lContinua	:= .F.
	nParam		:= 1
	nRecnoFIF	:= 0

	Default cDtVend := ""
	Default cTef 	:= ""
	Default cNSUSitef := ""
	Default cParc 	:= ""
	Default cCodAut := ""
	Default cCodLoj := ""
	Default cDtCred := ""

	If Alltrim(SubStr(cTef,13)) == ""
		lContinua := FIF->( MsSeek( xFilial("FIF") + cDtVend + cTef + cParc + cCodLoj ) )
	Endif

	If !lContinua .and. Alltrim(SubStr(cNSUSitef,13)) <> ""
		lContinua := FIF->( MsSeek( xFilial("FIF") + cDtVend + cNSUSitef + cParc + cCodLoj ) )
	Endif	

	If !lContinua
		cFilImp	:= Fa914MsFil( cCodLoj, "SOFEX" )
		If cFilImp <> cFilAnt
			lContinua := .T.
		EndIf
	EndIf

	If lContinua
		If cFilImp == cFilAnt
			If	__oTmpFIF1 == Nil
				cQry := "SELECT R_E_C_N_O_ AS RECNO "
				cQry += " FROM " + RetSqlName("FIF") + " FIF "
				cQry += " WHERE FIF_FILIAL = ? "
				cQry += " AND FIF_DTTEF = ? "
				cQry += " AND (FIF_NSUTEF = ? Or FIF_NSUTEF = ?) "
				cQry += " AND FIF_PARCEL = ? "
				cQry += " AND FIF_CODAUT = ? "
				cQry += " AND FIF_CODLOJ = ? "
				cQry += " AND FIF.D_E_L_E_T_ = ? "
				cQry := ChangeQuery(cQry)
				__oTmpFIF1 := FwExecStatement():New(cQry)	
			EndIf

			__oTmpFIF1:SetString(nParam++, xFilial("FIF"))
			__oTmpFIF1:SetString(nParam++, cDtVend)
			__oTmpFIF1:SetString(nParam++, cTef)
			__oTmpFIF1:SetString(nParam++, cNSUSitef)
			__oTmpFIF1:SetString(nParam++, cParc)
			__oTmpFIF1:SetString(nParam++, cCodAut)
			__oTmpFIF1:SetString(nParam++, cCodLoj)
			__oTmpFIF1:SetString(nParam++, cDelete)

			nRecnoFIF :=  __oTmpFIF1:ExecScalar("RECNO")
		Else
			If __oTmpFIF2 == Nil
				cQry := "SELECT R_E_C_N_O_ AS RECNO "
				cQry += " FROM " + RetSqlName("FIF") + " FIF "
				cQry += " WHERE FIF_CODFIL = ? "
				cQry += " AND FIF_DTCRED = ? "
				cQry += " AND (FIF_NSUTEF = ? Or FIF_NSUTEF = ?) "
				cQry += " AND FIF_PARCEL = ? "
				cQry += " AND FIF.D_E_L_E_T_ = ? "
				cQry := ChangeQuery(cQry)
				__oTmpFIF2 := FwExecStatement():New(cQry)
			EndIf

			__oTmpFIF2:SetString(nParam++, cFilImp)
			__oTmpFIF2:SetString(nParam++, cDtCred)
			__oTmpFIF2:SetString(nParam++, cTef)
			__oTmpFIF2:SetString(nParam++, cNSUSitef)
			__oTmpFIF2:SetString(nParam++, cParc)
			__oTmpFIF2:SetString(nParam++, cDelete)

			nRecnoFIF :=  __oTmpFIF2:ExecScalar("RECNO")
		EndIf

		If nRecnoFIF > 0
			dbSelectArea("FIF")
			dbGoTo(nRecnoFIF)
			lRet := .T.
		EndIf
	EndIf

Return lRet
