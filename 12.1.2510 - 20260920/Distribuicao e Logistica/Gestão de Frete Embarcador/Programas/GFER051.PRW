#INCLUDE "PROTHEUS.CH"


/*---------------------------------------------------------
{Protheus.doc} GFER051
	    
@author siegklenes.beulke
@since 02/08/2013
@version 1.0

@description
Relatório de Documento de Carga em Trânsito,
Apresenta os Documento de Carga em Trânsito, mostrando situação de entrega

-------------------------------------------------------------*/
Function GFER051()
	Local oReport
	Local aArea := GetArea()
	
	Private cAliasDoc // tabela temporaria de documentos

	If TRepInUse()
		//+------------------------------------------------------------------------+
		//| "Interface de impressao                                                  |
		//+------------------------------------------------------------------------+
		oReport := ReportDef()
		oReport:PrintDialog()
	EndIf
	
	RestArea(aArea)	
	GFEDelTab(cAliasDoc)
Return Nil

//--------------------------------------------------------------------------------------------------------
/*/ {Protheus.doc}  ReportDef
A funcao estatica ReportDef devera ser criada para todos os relatorios que poderao ser agendados pelo usuario. 

@author siegklenes.beulke
@version 1.0
@since 02/08/2013
@return oReport Objeto do Relatorio.

/*/
//--------------------------------------------------------------------------------------------------------

Static Function ReportDef()
	Local oReport, oSection
	
	//+------------------------------------------------------------------------+
	//| "Criacao do componente de impressao                                      | "
	//| "                                                                        | "
	//| "TReport():New                                                           | "
	//| "ExpC1 : Nome do relatorio                                               | "
	//| "ExpC2 : Titulo                                                          | "
	//| "ExpC3 : Pergunte                                                        | "
	//| "ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  | "
	//| "ExpC5 : Descricao                                                       | "
	//| "                                                                        | "
	//+------------------------------------------------------------------------+
																	
	oReport := TReport():New("GFER051","Relatório de Documentos de Carga em Trânsito","GFER051", {|oReport| ReportPrint(oReport)},"Emite relatório de Documento de Carga em Trânsito conforme os parâmetros informados."/*Descricao do relatório*/)
	oReport:SetLandscape(.T.)   //Define a oriadmientação de página do relatório como paisagem  ou retrato. .F.=Retrato; .T.=Paisagem
	oReport:SetTotalInLine(.T.) //Define se os totalizadores serão impressos em linha ou coluna 
	oReport:HideParamPage() //Oculta página de parametros
	If !Empty(oReport:uParam)
	    Pergunte(oReport:uParam,.F.)  
	EndIf
	oSection := TRSection():New(oReport,"Doc Carga em Trânsito",{"(cAliasDoc)","GU3","GU7"	},{"Doc Carga em Trânsito"}/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/)
	//Exemplo utilizando a tabela de clientes.
	//oSection := TRSection():New(oReport,"Clientes",{"SA1"})
	oSection:SetTotalInLine(.T.)  //Define se os totalizadores serão impressos em linha ou coluna. .F.=Coluna; .T.=Linha
	
	//+------------------------------------------------------------------------+
	//|Criacao da celulas da secao do relatorio                                |
	//|                                                                        |
	//|TRCell():New                                                            |
	//|ExpO1 : Objeto TSection que a secao pertence                            |
	//|ExpC2 : Nome da celula do relatório. O SX3 será consultado              |
	//|ExpC3 : Nome da tabela de referencia da celula                          |
	//|ExpC4 : Titulo da celula                                                |
	//|        Default : X3Titulo()                                            |
	//|ExpC5 : Picture                                                         |
	//|        Default : X3_PICTURE                                            |
	//|ExpC6 : Tamanho                                                         |
	//|        Default : X3_TAMANHO                                            |
	//|ExpL7 : Informe se o tamanho esta em pixel                              |
	//|        Default : False                                                 |
	//|ExpB8 : Bloco de código para impressao.                                 |
	//|        Default : ExpC2                                                 |
	//|                                                                        |
	//+------------------------------------------------------------------------+
	//	GetSx3Inf @return aRetorno Array {cTitulo,cCbox,cPicture}
	//TRCell():New(oSection,/*X3_CAMPO*/,/*Tabela*/,/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	
	TRCell():New(oSection,"(cAliasDoc)->GW1_FILIAL","(cAliasDoc)","Filial",GetSx3Inf("GW1_FILIAL")[3],/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection,"(cAliasDoc)->GW1_EMISDC","(cAliasDoc)","Cod Emissor",GetSx3Inf("GW1_EMISDC")[3],/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection,"NMEMISDC","(cAliasDoc)","Nome Emissor","@!",/*Tamanho*/,/*lPixel*/,{||Posicione("GU3",1,xFilial("GU3") + (cAliasDoc)->GW1_EMISDC,"GU3_NMEMIT")}/*{|| code-block de impressao }*/)
	TRCell():New(oSection,"(cAliasDoc)->GW1_SERDC",	"(cAliasDoc)","Série",				 	"!!!",/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection,"(cAliasDoc)->GW1_NRDC","(cAliasDoc)","Nr Docto",GetSx3Inf("GW1_NRDC")[3],/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection,"(cAliasDoc)->GW1_REPRES","(cAliasDoc)","Representante",GetSx3Inf("GW1_REPRES")[3],/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection,"(cAliasDoc)->GU7_NMCID","(cAliasDoc)","Nome Cidade Destino",GetSx3Inf("GU7_NMCID")[3],/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection,"(cAliasDoc)->GU7_CDUF","(cAliasDoc)","UF Destino",GetSx3Inf("GU7_CDUF")[3],/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection,"(cAliasDoc)->GW1_CDDEST","(cAliasDoc)","Cod Destinatário",GetSx3Inf("GW1_CDDEST")[3],/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection,"NMDEST","(cAliasDoc)","Nome Destinatário","@!",/*Tamanho*/,/*lPixel*/,{||Posicione("GU3",1,xFilial("GU3") + (cAliasDoc)->GW1_CDDEST,"GU3_NMEMIT")}/*{|| code-block de impressao }*/)
	TRCell():New(oSection,"(cAliasDoc)->GW1_NRROM","(cAliasDoc)","Romaneio",GetSx3Inf("GW1_NRROM")[3],/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection,"(cAliasDoc)->GWU_CDTRP","(cAliasDoc)","Cod Transp Atual",GetSx3Inf("GWU_CDTRP")[3],/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection,"NMTRP","(cAliasDoc)","Nome Transp Atual","@!",/*Tamanho*/,/*lPixel*/,{||Posicione("GU3",1,xFilial("GU3") + (cAliasDoc)->GWU_CDTRP,"GU3_NMEMIT")}/*{|| code-block de impressao }*/)
	TRCell():New(oSection,"(cAliasDoc)->GW8_PESOR", "(cAliasDoc)", "Peso Bruto",GetSx3Inf("GW8_PESOR")[3],,,)
	TRCell():New(oSection,"(cAliasDoc)->GW8_VALOR", "(cAliasDoc)", "Valor Carga",GetSx3Inf("GW8_VALOR")[3],,,)
	TRCell():New(oSection,"(cAliasDoc)->GW8_VOLUME", "(cAliasDoc)", "Volume Carga",GetSx3Inf("GW8_VOLUME")[3],,,)	
	TRCell():New(oSection,"(cAliasDoc)->GW1_QTVOL", "(cAliasDoc)", "Qtde Volumes",GetSx3Inf("GW1_QTVOL")[3],,,)
	TRCell():New(oSection,"(cAliasDoc)->GW1_DIASTR", "(cAliasDoc)", "Dias em Trânsito",GetSx3Inf("GW1_QTVOL")[3],,,)
	
	TRCell():New(oSection,"ENTCLI","(cAliasDoc)","Prazo Entrega Cliente","@!",/*Tamanho*/,/*lPixel*/,{||AvalPrazo((cAliasDoc)->GW1_DTPENT)}/*{|| code-block de impressao }*/)
	TRCell():New(oSection,"ENTTRP","(cAliasDoc)","Prazo Entrega Transp","@!",/*Tamanho*/,/*lPixel*/,{||AvalPrazo((cAliasDoc)->DTPENT)}/*{|| code-block de impressao }*/)

Return oReport

//--------------------------------------------------------------------------------------------------------
/*/ {Protheus.doc}  ReportPrint
A funcao estatica ReportDef devera ser criada para todos os relatorios que poderao ser agendados pelo usuario.  

@param oReport Objeto do relatório  
@author Siegklenes.beulke
@version 1.0
@since 01/08/2013
@return Nil
/*/
//--------------------------------------------------------------------------------------------------------
Static Function ReportPrint(oReport)
	Local oSection  := oReport:Section(1)

	Private cAliasDoc // tabela temporaria de documentos
	
	CarregaDados()
	oSection:Init()
	While !(cAliasDoc)->(Eof())
		oSection:PrintLine()
		(cAliasDoc)->(dbSkip())
	EndDo
	oSection:Finish()
Return Nil


//--------------------------------------------------------------------------------------------------------
/*/ {Protheus.doc}  CriaTabTemp
A funcao estatica CriaTabTemp Cria a struct dos dados do relatório e cria as tabelas temporárias, privadas em GFER051() 

@author siegklenes.beulke
@version 1.0
@since 01/08/2013
@return {aStruDoc} Array com Struct dos campos

/*/
//--------------------------------------------------------------------------------------------------------

Static Function CriaTabTemp()
	Local  aStruDoc
	
	aStruDoc 	:= {; 	
						{"GW1_FILIAL"	,"C",TamSX3("GW1_FILIAL" )[1],0},;
						{"GW1_EMISDC"	,"C",TamSX3("GW1_EMISDC" )[1],0},;
						{"GW1_SERDC"	,"C",TamSX3("GW1_SERDC" )[1],0},; 
						{"GW1_NRDC"	,"C",TamSX3("GW1_NRDC" )[1],0},;
						{"GW1_REPRES"	,"C",TamSX3("GW1_REPRES" )[1],0},;
						{"GU7_NMCID"	,"C",TamSX3("GU7_NMCID" )[1],0},;
						{"GU7_CDUF"	,"C",TamSX3("GU7_CDUF" )[1],0},;
						{"GW1_CDDEST"	,"C",TamSX3("GW1_CDDEST" )[1],0},;
						{"GW1_NRROM"	,"C",TamSX3("GW1_NRROM" )[1],0},;
						{"GWU_CDTRP"	,"C",TamSX3("GWU_CDTRP" )[1],0},;
						{"GW8_PESOR"	,"N",TamSX3("GW8_PESOR" )[1],TamSX3("GW8_PESOR" )[2]},;
						{"GW8_VALOR"	,"N",TamSX3("GW8_VALOR" )[1],TamSX3("GW8_VALOR" )[2]},;
						{"GW8_VOLUME"	,"N",TamSX3("GW8_VOLUME" )[1],TamSX3("GW8_VOLUME" )[2]},;
						{"GW1_QTVOL"	,"N",TamSX3("GW8_VALOR" )[1],TamSX3("GW8_VALOR" )[2]},;
						{"GW1_DIASTR"	,"N",9,0},;
						{"GW1_DTPENT"	,"D",TamSX3("GW1_DTPENT")[1],0},;
						{"DTPENT"		,"D",TamSX3("GWU_DTPENT")[1],0}; // PREVISÃO ENTREGA ULTIMO TRECHO
					}
	
	cAliasDoc :=  GFECriaTab({aStruDoc,{"GW1_FILIAL+GW1_EMISDC+GW1_SERDC+GW1_NRDC"}})
	(cAliasDoc)->(dbSetOrder(1))
Return {aStruDoc}


/*/{Protheus.doc} CarregaDados()
	
@author siegklenes.beulke
@since 02/08/2013
@version 1.0
	
@description
	A função estática CarregaDados alimenta as tabelas temporárias(cAliasDoc)  para uso no relatório
@example
	CarregaDados()

/*/

Static Function CarregaDados()
	Local cChaveGW1 := ""
	Local cCidDest  := ""
	/* 	Pergunte
		01 Filial de
		02 Filial até
		03 Data da emissao documento de
		04 Data da emissao documento ate
		05 Data saida de
		06 Data saida até
		07 Representante de
		08 Representante ate
		09 Cidade Dest de
		10 Cidade Dest Ate
		11 destinatario de
		12 destinatario ate
	*/
	
	CriaTabTemp()
	
	dbSelectArea("GW1")
	GW1->(dbSetOrder(1))
	GW1->(dbGoTop())
	
	dbSelectArea("GWU")
	GWU->(dbSetOrder(1))
		
	dbSelectArea("GW8")
	GW8->(dbSetOrder(2))
	
	
	While !GW1->(Eof()) 
		If !Empty(GW1->GW1_DTSAI) .And. GW1->GW1_SIT == '4';
			.And. GW1->GW1_FILIAL >= MV_PAR01 .And. GW1->GW1_FILIAL <= MV_PAR02;
			.And. GW1->GW1_DTEMIS >= MV_PAR03 .And. GW1->GW1_DTEMIS <= MV_PAR04;
			.And. GW1->GW1_DTSAI >= MV_PAR05 .And. GW1->GW1_DTSAI <= MV_PAR06;
			.And. GW1->GW1_REPRES >= MV_PAR07 .And. GW1->GW1_REPRES <= MV_PAR08;
			.And. (cCidDest := If(Vazio(GW1->GW1_ENTNRC),Posicione("GU3",1,xFilial("GU3") + GW1->GW1_CDDEST, "GU3_NRCID") , GW1->GW1_ENTNRC)) >= MV_PAR09; // cidade destino, se em branco no endereço de entrega documento, usa do destinatário
			.And. cCidDest <= MV_PAR10;
			.And. GW1->GW1_CDDEST >= MV_PAR11 .And. GW1->GW1_CDDEST <= MV_PAR12
			
			
			cChaveGW1 := GW1->GW1_FILIAL+GW1->GW1_CDTPDC+GW1->GW1_EMISDC+GW1->GW1_SERDC+GW1->GW1_NRDC
			
			RecLock((cAliasDoc),.T.)
			
			(cAliasDoc)->GW1_FILIAL := GW1->GW1_FILIAL
			(cAliasDoc)->GW1_EMISDC	:= GW1->GW1_EMISDC
			(cAliasDoc)->GW1_SERDC 	:= GW1->GW1_SERDC
			(cAliasDoc)->GW1_NRDC 	:= GW1->GW1_NRDC
			(cAliasDoc)->GW1_REPRES	:= GW1->GW1_REPRES
			(cAliasDoc)->GU7_NMCID 	:= Posicione("GU7",1,xFilial("GU7")+cCidDest,"GU7_NMCID")
			(cAliasDoc)->GU7_CDUF 	:= Posicione("GU7",1,xFilial("GU7")+cCidDest,"GU7_CDUF")
			(cAliasDoc)->GW1_CDDEST := GW1->GW1_CDDEST
			(cAliasDoc)->GW1_NRROM 	:= GW1->GW1_NRROM
			(cAliasDoc)->GW1_DIASTR := Date() - GW1->GW1_DTSAI
			(cAliasDoc)->GW1_QTVOL 	:= GW1->GW1_QTVOL 
			(cAliasDoc)->GW1_DTPENT := GW1->GW1_DTPENT
			
			GW8->(dbSeek(cChaveGW1))
			While !GW8->(Eof()) .And. cChaveGW1 == GW8->GW8_FILIAL+GW8->GW8_CDTPDC+GW8->GW8_EMISDC+GW8->GW8_SERDC+GW8->GW8_NRDC
				(cAliasDoc)->GW8_PESOR += GW8->GW8_PESOR
				(cAliasDoc)->GW8_VALOR += GW8->GW8_VALOR
				(cAliasDoc)->GW8_VOLUME += GW8->GW8_VOLUME
				GW8->(dbSkip())
			EndDo
			
			GWU->(dbSeek(cChaveGW1))
			While !GWU->(Eof()) ;
				.And.  cChaveGW1 == GWU->GWU_FILIAL+GWU->GWU_CDTPDC+GWU->GWU_EMISDC+GWU->GWU_SERDC+GWU->GWU_NRDC
				If GWU->GWU_PAGAR == '1' .And. Empty(GWU->GWU_DTENT) .And. Empty((cAliasDoc)->GWU_CDTRP)
					(cAliasDoc)->GWU_CDTRP 	:= GWU->GWU_CDTRP
				EndIf
				GWU->(DbSkip())
			EndDo
			
			GWU->(DbSkip(-1))
			While !GWU->(Eof()) ;
				.And.  cChaveGW1 == GWU->GWU_FILIAL+GWU->GWU_CDTPDC+GWU->GWU_EMISDC+GWU->GWU_SERDC+GWU->GWU_NRDC
				If GWU->GWU_PAGAR == '1' .And. Empty(GWU->GWU_DTENT)
					(cAliasDoc)->DTPENT := GWU->GWU_DTPENT
					cChaveGW1 := ""
				EndIf
				GWU->(DbSkip(-1))
			EndDo
		
			MsUnlock((cAliasDoc))
		EndIf
		GW1->(dbSkip())
	EndDo
	(cAliasDoc)->(dbGoTop())
	
Return Nil

/*/{Protheus.doc} GetSx3Inf
	
@author siegklenes.beulke
@since 16/07/2013
@version 1.0

@param cCampo, character, Campo  do Banco de dados 
@param aRetorno, array, Opcional, Informações de Retorno caso não encontre o Campo

@description

Função que busca no sx3 as informações de titulo,cbox,picture e descrição do campo
e retorna um array nessa ordem, ou caso não encontre o campo, retorna o segundo parametro

@example

GetSx3Inf("GW1_FILIAL") Retorno {"Filial","","@!","Filial"}
GetSx3Inf("GW1_FILI",{"Fila","1=Sim;2=Nao","","Fila de espera"})Retorno {"Fila","1=Sim;2=Nao","","Fila de espera"} 

@return aArray:={X3Titulo, X3Cbox,X3Picture,X3DESCRIC}
/*/

Static Function GetSx3Inf(cCampo,aRetorno)
Local nCont := 1
Local aArea := GetArea("SX3")
Default aRetorno := {"","","",""}
	For nCont := 1 to 4-Len(aRetorno)
		aAdd(aRetorno,"")
	Next
	dbSelectArea("SX3")
	dbSetOrder(2)
	If dbSeek( cCampo )   
		aRetorno[1] := X3Titulo()
		aRetorno[2] := X3Cbox()
		aRetorno[3] := X3Picture()
		aRetorno[4] := X3DESCRIC()
	EndIf
	RestArea(aArea)
Return aRetorno

Static Function AvalPrazo(cPrev)
	Local cRet := ""
	
	If Empty(cPrev)
		cRet:= "Previsão Não Informada"
	ElseIf cPrev < Date()
		cRet:= "Atrasado"
	Else
		cRet:= "Dentro do Prazo"
	EndIf 
Return cRet