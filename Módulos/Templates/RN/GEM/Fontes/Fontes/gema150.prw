#INCLUDE "GEMA150.ch"
#INCLUDE "PROTHEUS.CH" 

#DEFINE CRLF CHR(13)+CHR(10)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ GEMA150  ³ Autor ³ Daniel Tadashi Batori ³ Data ³ 06.02.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Exportacao de dados para o DIMOB                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Template GEM                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
TEMPLATE Function GEMA150()
Local aParam := {}
Local cValid_Par2 := "If((MV_PAR02<2002 .Or. MV_PAR02>2010),(Aviso('"+STR0002+"', '"+STR0003+"' ,{'OK'}),.F.),.T.)"
Private cCadastro := "Protheus"

// Valida se tem licenças para o Template GEM = Gestao de Empreendimentos Imobiliarios							 
ChkTemplate("LOT")

If Parambox( { {6, STR0004,"", , , ,60,.T.,STR0005,,GETF_LOCALHARD + GETF_LOCALFLOPPY },;
					{1, STR0006,Year(Date())-1,"9999",cValid_Par2,"","",40,.T.},;
					{1, STR0007,Space(11),"99999999999","CGC(MV_PAR03)","","",40,.T.},;
					{5, STR0008, .F., 160,,.T.},; 
					{1, STR0009,Space(10),"9999999999","","","",80,.F.},;
					{2, STR0010, 1, {STR0011,STR0012,STR0013,STR0014,STR0015}, 80, "", .T.},; //{"Normal","Extinção","Fusão","Incorporação/Incorporada","Cisão Total"}
					{1, STR0016,Date(),"@!","","","",50,.F.},;
					{1, STR0040,Space(20),"","","","",40,.F.};
							}, STR0001, @aParam)
							
	If( ValType(aParam[6])=="N" , aParam[6]:=STR0011 , )
	Processa( {|| GeraDimob(aParam) }, STR0017, STR0018,.F.)
EndIf

Return(.T.)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³ GeraDimob  ³ Autores ³ Daniel Tadashi Batori  ³ Data ³06/02/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Funcao gera o arquivo magnetico TXT Dimob                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ aParam : array de parametros retornados do ParamBox             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function GeraDimob(aParam)
Local lGrava  := .T.
Local cTexto  := ""
Local cPath   := AllTrim(aParam[1])
Local cPathLog:= ""
Local cAno    := Str(aParam[2],4)
Local nCPF    := aParam[3]
Local cTipos  := Alltrim(aParam[8])
Local cRetificadora := If(aParam[4],"1","0")
Local cRecibo := ""
Local cSitEsp := ""
Local cDataSE := ""
Local cCodSitEsp := ""
Local cEndereco  := ""
Local cFilLIT := xFilial("LIT")
Local cFilSA1 := xFilial("SA1")
Local cFilSE5 := xFilial("SE5")
Local cFilLIQ := xFilial("LIQ")
Local cFilLIU := xFilial("LIU")
Local nLin    := 0
Local nValAnoRec := 0
Local cCodMun := ""
Local cCEP    := ""
Local cUF     := ""
Local nHdl    := 0
Local	lContinua := .T.

SX6->(DbSetOrder(1))
If !(SX6->(DbSeek(xFilial("SX6")+"MV_GMCMUN"))) .Or. Empty(GetMV("MV_GMCMUN"))
	MsgAlert(STR0038,STR0002 ) //"O parametro MV_GMCMUN deve existir e conter o código DIMOB do município do declarante!"###"Atenção"
	Return
EndIf

cPathLog := SubStr(cPath,1,Len(cPath)-3) + "LOG"

If Upper(SubStr(cPath,Len(cPath)-3,4))!=".TXT"
	lGrava := .F.
	Aviso(STR0002, STR0019 ,{"OK"}) //'O nome do arquivo deve possuir a extensão ".TXT"!'
ElseIf File(cPath) .And. Aviso(STR0002, STR0020+" '"+AllTrim(cPath)+"' "+STR0021 ,{"OK",STR0037},2)==2 //"O arquivo" ### "deverá ser sobrescrito?"
	lGrava := .F.
Else
	FErase(cPathLog)
EndIf

If aParam[4] == .T. //retificadora
	If Empty(aParam[5])
		Aviso(STR0002, STR0022 ,{"OK"}) //"Na Declaração Retificadora deve conter o numero do Recibo!"
		lGrava := .F.
	Else
		cRecibo := PadL(AllTrim(aParam[5]),10,"0")
	EndIf
Else
	cRecibo := Replicate("0",10)
EndIf

LIT->(DbSetOrder(3)) // LIT_FILIAL+DTOS(LIT_EMISSA)
If !LIT->(DbSeek(cFilLIT+cAno))
	lGrava := .F.
	GravaLog(cPathLog,STR0023) //"Nao existem registros para a exportação do DIMOB"
EndIf

nHdl := FCreate(cPath)
If nHdl==-1
	lGrava := .F.
	GravaLog(cPathLog,STR0024) //"O arquivo não pode ser criado. Verifique se existe o diretorio e se o arquivo nao esta bloqueado."
EndIf

If lGrava == .T.
	
	/***************************************************
	*****Header*****************************************
	***************************************************/
	cTexto := "DIMOB"+Space(369)+CRLF	    //constante 
	FWrite(nHdl, cTexto)

	/***************************************************
	*****R1 - Ficha Inicial (cadastro do declarante)****
	***************************************************/
	//Situacao Especial
	Do Case 
		Case aParam[6]==STR0011 //"Normal"
			cCodSitEsp := "00"
			cSitEsp    := "0"
			cDataSE    := "00000000"
		Case aParam[6]==STR0012 //"Extinção"
			cCodSitEsp := "01"
			cSitEsp    := "1"
			cDataSE    := PadL(Day(aParam[7]),2,"0")+PadL(Month(aParam[7]),2,"0")+ Str(Year(aParam[7]),4)
		Case aParam[6]==STR0013 //"Fusão"
			cCodSitEsp := "02"
			cSitEsp    := "1"
			cDataSE    := PadL(Day(aParam[7]),2,"0")+PadL(Month(aParam[7]),2,"0")+ Str(Year(aParam[7]),4)
		Case aParam[6]==STR0014 //"Incorporação/Incorporada"
			cCodSitEsp := "03"
			cSitEsp    := "1"
			cDataSE    := PadL(Day(aParam[7]),2,"0")+PadL(Month(aParam[7]),2,"0")+ Str(Year(aParam[7]),4)
		Case aParam[6]==STR0015 //"Cisão Total"
			cCodSitEsp := "04"
			cSitEsp    := "1"
			cDataSE    := PadL(Day(aParam[7]),2,"0")+PadL(Month(aParam[7]),2,"0")+ Str(Year(aParam[7]),4)
	EndCase
	
	//Endereco Completo do contribuinte
	cEndereco := AllTrim(SM0->M0_ENDCOB)
	If !Empty(SM0->M0_BAIRCOB)
		cEndereco += " - "+AllTrim(SM0->M0_BAIRCOB)
	EndIf
	If !Empty(SM0->M0_CIDCOB)
		cEndereco += " - "+AllTrim(SM0->M0_CIDCOB)
	EndIf
	If !Empty(SM0->M0_CEPCOB)
		cEndereco += " - "+"CEP "+SM0->M0_CEPCOB
	EndIf

	cTexto :=	"R01"+;                        //constante
					SM0->M0_CGC+;                  //CNPJ do declarante
					cAno+;                         //ano-calendario
					cRetificadora+;                //Declaracao Retificadora
					cRecibo+;                      //No do recibo(necessario se for Declaracao Retificadora)
					cSitEsp+;                      //Situacao Especial
					cDataSE+;                      //Data do evento Situacao Especial
					cCodSitEsp+;                   //Codigo da Situacao Especial
					PadR(SM0->M0_NOMECOM,60," ")+; //Nome Empresarial
					AllTrim(nCPF)+;                //CPF do responsavel perante a SRF
					PadR(cEndereco,120," ")+;      //Endereco Completo do contribuinte
					SM0->M0_ESTCOB+;               //UF do contribuinte
					PadL(GetMV("MV_GMCMUN"),4,"0")+;//codigo do municipio do contribuinte
               Space(20)+;                    //reservado
               Space(10)+;                    //reservado
               CRLF
	FWrite(nHdl, cTexto)

	/******************************************
	*****R2 - Ficha Locacao ()*****************
	******************************************/
	//nao implementado

	/******************************************
	*****R3 - Construcao e Incorporacao********
	******************************************/
	SA1->(DbSetOrder(1)) // A1_FILIAL+A1_COD+A1_LOJA
	SE5->(DbSetOrder(7)) 
	LIQ->(DbSetOrder(1)) // LIQ_FILIAL+LIQ_COD
	LIU->(DbSetOrder(3)) // LIU_FILIAL+LIU_NCONTR+LIU_COD+LIU_ITEM
	LIT->(DbSetOrder(3)) // LIT_FILIAL+DTOS(LIT_EMISSA)
	LIT->(DbSeek(cFilLIT+cAno))
	

	nLin := 1

	ProcRegua(LIT->(RecCount()))
	IncProc(STR0025) //"Construção e Incorporação"
	
	While !LIT->(EOF()) .And. LIT->(LIT_FILIAL+AllTrim(Str(Year(LIT->LIT_EMISSA))))==cFilLIT+cAno

		IncProc()
		
		nValAnoRec := 0
		If SE5->(DbSeek(cFilSE5+LIT->(LIT_PREFIX+LIT_DUPL)))
			While !SE5->(EOF()) .And. SE5->(E5_FILIAL+E5_PREFIXO+E5_NUMERO)==cFilSE5+LIT->(LIT_PREFIX+LIT_DUPL)
				// Consiste se o motivo gera ou nao movimento bancario.
				If !MovBcoBx( SE5->E5_MOTBX, .F. )
					SE5->(DbSkip())
					Loop
				Endif
				
				If SE5->E5_RECPAG == "R" .And. Year(SE5->E5_DATA)==Val(cAno)
					nValAnoRec += SE5->E5_VALOR
				EndIf
				If SE5->E5_RECPAG == "P" .And. Year(SE5->E5_DATA)==Val(cAno)
					nValAnoRec -= SE5->E5_VALOR
				EndIf
				SE5->(DbSkip())
			EndDo
		EndIf
      
		//se o contrato for cancelado e devolvido todo o valor pago ao cliente entao nao deve ser exportado o contrato
		If nValAnoRec=0 .And. (LIT->LIT_STATUS=="3" .Or. LIT->LIT_STATUS=="5")  //contrato cancelado ou ditrato
			LIT->(DbSkip())
     		Loop
		EndIf

		//se o valor do contrato eh menor que o valor pago no ano o programa Dimob nao importa o registro em questao. Sera feito um log para o usuario inclui-lo manualmente.
		If LIT->LIT_VALBRU < nValAnoRec
			GravaLog(cPathLog,STR0032+LIT->LIT_NCONTR) //"O valor do contrato " xxx " é maior que o valor total pago ao ano. Este contrato deverá ser incluído manualmente no programa Dimob."
		EndIf

		//atualmente o sistema nao esta preparado para faturar mais de uma unidade por contrato.
		LIU->(DbSeek(cFilLIU+LIT->LIT_NCONTR)) // LIU_FILIAL+LIU_NCONTR+LIU_COD+LIU_ITEM
		While !LIU->(EOF()) .And. cFilLIU+LIU->LIU_NCONTR==cFilLIU+LIT->LIT_NCONTR
			If !Empty(LIU->LIU_CODEMP)
				Exit
			EndIf
		EndDo

		//informacoes do imovel : endereco, CEP, codigo do municipio, UF
		If LIQ->(DbSeek(cFilLIQ+LIU->LIU_CODEMP))
			If Empty(cTipos) .Or. (Alltrim(LIQ->LIQ_TIPO) $ cTipos)
				If !Empty(LIQ->LIQ_END)
					cEndereco := AllTrim(LIQ->LIQ_END) 
	
					If !Empty(LIQ->LIQ_BAIRRO)
						cEndereco += " - " + AllTrim(LIQ->LIQ_BAIRRO)
					EndIf
				Else
					cEndereco := Space(60)
					GravaLog(cPathLog,STR0026+LIQ->LIQ_COD) //"Não foi encontrado o endereço na unidade(LIQ) do empreendimento "
				EndIf
			
				If !Empty(LIQ->LIQ_CEP)
					cCEP := PadL(AllTrim(LIQ->LIQ_CEP),8,"0")
				Else
					cCEP := "00000000"
					GravaLog(cPathLog,STR0027+LIQ->LIQ_COD) //"Não foi encontrado o CEP na unidade(LIQ) do empreendimento "
				EndIf
	
				If !Empty(LIQ->LIQ_COD_DI)
					cCodMun := PadL(LIQ->LIQ_COD_DI,4,"0")
				Else
					cCodMun := "0000"
					GravaLog(cPathLog,STR0028+LIQ->LIQ_COD) //"Não foi encontrado o Código de municipio na unidade(LIQ) "
				EndIf
	
				If !Empty(LIQ->LIQ_UF)
					cUF := PadR(LIQ->LIQ_UF,2," ")
				Else
					cUF := "  "
					GravaLog(cPathLog,STR0029+LIQ->LIQ_COD) //"Não foi encontrada a UF na unidade(LIQ) "
				EndIf 
				lContinua := .T.
			else
				lContinua := .F.
			EndIf		
		Else
			cEndereco := Space(60)
			cCEP      := "00000000"
			cCodMun   := "0000"
			cUF := "  "
			GravaLog(cPathLog,STR0030+LIU->LIU_CODEMP) //"Não foi encontrada a unidade(LIQ) do empreendimento "
		EndIf

		
		If lContinua
			If SA1->(DbSeek(cFilSA1+LIT->(LIT_CLIENT+LIT_LOJA)))
				If !CGC(SA1->A1_CGC)
					GravaLog(cPathLog,STR0034+LIT->LIT_CLIENT+STR0035) //"O CPF/CGC do cliente " ### " está inválido!"
				EndIf
			Else
				GravaLog(cPathLog,STR0036+LIT->LIT_NCONTR) //"Não foi encontrado cliente para o contrato " ###
			EndIf
			
			cTexto :=	"R03"+;                        //constante
							SM0->M0_CGC+;                  //CNPJ do declarante
							cAno+;                         //ano-calendario
							PadL(nLin,5,"0")+;             //sequencial de venda
							PadR(SA1->A1_CGC,14," ")+;     //CPF/CNPJ do comprador
							PadR(SA1->A1_NOME,60," ")+;    //Nome Empresarial do Comprador
							PadR(Val(LIT->LIT_NCONTR),6," ")+;//numero do contrato
							PadL(Day(LIT->LIT_EMISSA),2,"0")+PadL(Month(LIT->LIT_EMISSA),2,"0")+ Str(Year(LIT->LIT_EMISSA),4)+;//data do contrato
							PadL(LIT->LIT_VALBRU*100,14,"0")+;//valor da operacao
							PadL(nValAnoRec*100,14,"0")+;     //valor pago no ano
							"U"+;                          //tipo do imovel - coloquei fixo porque nao achei no bancop de dados
							PadR(cEndereco,60," ")+;       //endereco do imovel
							cCEP+;                         //CEP
							cCodMun+;                      //codigo do municipio do imovel
							Space(20)+;                    //reservado
							cUF+;                          //UF
							Space(10)+;                    //reservado
							CRLF
			FWrite(nHdl, cTexto)
			
			nLin++
		ENDIF	
		LIT->(DbSkip())
	EndDo

	/***************************************************
	*****Trailer****************************************
	***************************************************/
	cTexto :=	"T9"+;                       //constante
					Space(100)+;                 //reservado
					CRLF
	FWrite(nHdl, cTexto)

EndIf

If nHdl!=-1
	FClose(nHdl)
EndIf

If File(cPathLog)
	Aviso(STR0002, STR0031+CRLF+cPathLog ,{"OK"}) //"Verifique o arquivo de LOG criado!"
Else
	Aviso(STR0002, STR0020+" '"+AllTrim(cPath)+"' "+STR0039 ,{"OK"}) //"O arquivo" ### "foi gerado corretamente."
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o     ³GravaLog  ³ Autor ³Daniel Tadashi Batori  ³ Data ³12/02/06  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o  ³ Funcao para gravacao do LOG de erro da exportacao          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ cPathLog : caminho+nome do arquivo log a ser criado        ³±±
±±³           ³ cLog : string com a mensagem a ser gravada no log          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso       ³ Gema150                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GravaLog(cPathLog,cLog)
Local nHdl := 0

If !File(cPathLog)
	nHdl := FCreate(cPathLog)
Else
	nHdl := FOpen(cPathLog,1+16) //FO_READWRITE+FO_EXCLUSIVE
	FSeek(nHdl,0,2) //FS_END
EndIf

FWrite(nHdl, cLog+CRLF)
FClose(nHdl)

Return
