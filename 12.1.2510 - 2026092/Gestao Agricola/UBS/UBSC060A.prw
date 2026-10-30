#INCLUDE "UBSC060A.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "FWPrintSetup.ch"
#include 'parmtype.ch'

/*/{Protheus.doc} UBSC060A
Função principal responsavel pela impressão do termo de conformidade conforme lotes selecionados
@type function
@version P12
@author Daniel Silveira / claudineia.reinert
@since 20/11/2023
/*/
Function UBSC060A(aDados, cCodTerm, cRespTec, cCodSaf , cCodCultr, cCodCtvar, cCateg, cCodLab, cLojaLab, dData)
   
	Local lAdjustToLegacy := .F.
	Local lDisableSetup   := .T.
	Local cLocal          := ALLTRIM(GETTEMPPATH())
	Local cPmsObs         := ''
	Local cNome 		  := alltrim(FWSM0Util():GetSM0Data(, , { "M0_NOMECOM" } )[1][2])
	Local cCNPJ 		  := alltrim(FWSM0Util():GetSM0Data(, , {"M0_CGC"})[1][2])
	Local cRenasem 		  := alltrim(SuperGetMV("MV_AGRRENA",.F.,""))
	Local cEnder 		  := alltrim(FWSM0Util():GetSM0Data(, , {"M0_ENDENT"})[1][2])
	Local cMunic 		  := UPPER(Alltrim(FWSM0Util():GetSM0Data(, , {"M0_CIDENT"})[1][2]) + " / " + alltrim(FWSM0Util():GetSM0Data(, , {"M0_ESTENT"})[1][2]))
	Local cCEP 			  := alltrim(FWSM0Util():GetSM0Data(, , {"M0_CEPENT"})[1][2])

	Local cNomeTec	:= ALLTRIM(Posicione("NP8", 1, xFilial("NP8") + cRespTec, "NP8_NOME"))
	Local cCPFTec 	:= ALLTRIM(Posicione("NP8", 1, xFilial("NP8") + cRespTec, "NP8_CPF"))
	Local cRenasTec := ALLTRIM(Posicione("NP8", 1, xFilial("NP8") + cRespTec, "NP8_RENASE"))
	Local cEndTec 	:= ALLTRIM(Posicione("NP8", 1, xFilial("NP8") + cRespTec, "NP8_ENDER"))
	Local cMunTec 	:= UPPER(ALLTRIM(Posicione("NP8", 1, xFilial("NP8") + cRespTec, "NP8_DESMUN")) + " / " + ALLTRIM(Posicione("NP8", 1, xFilial("NP8") + cRespTec, "NP8_EST")))
	Local cTelTec 	:= ALLTRIM(Posicione("NP8", 1, xFilial("NP8") + cRespTec, "NP8_NUMTEL"))
	Local cMailTec 	:= LOWER(ALLTRIM(Posicione("NP8", 1, xFilial("NP8") + cRespTec, "NP8_EMAIL")))
	Local cCepTec 	:= ALLTRIM(Posicione("NP8", 1, xFilial("NP8") + cRespTec, "NP8_CEP"))
	Local cEspecie 	:= fNP3Espec(cCodCultr)
	Local cCultivar := ALLTRIM(Posicione("NP4", 1, xFilial("NP4") + cCodCtvar,"NP4_DESCRI"))
	Local cCategoria:= cCateg
	Local cSafra 	:= cCodSaf
	Local cMsg 		:= ""
	Local cData 	:= ""
    Local ni		:= 0
	Local oPrinter	:= nil
	Local cPathAsTec   	:= LOWER(Alltrim(SuperGetMV("MV_AGRS006",,"" ))) 
	Local cPathLogo 	:= LOWER(Alltrim(SuperGetMV("MV_AGRS007",,"" ))) 
	Local aColOFat 	:= {}

	Default dData 	:= dDataBase
	
	Private _nCol          := 045
	Private _nRow          := 010
	Private _nSalto        := 012
	Private _cPixel        := "-6"
	Private _nLinGrid      := 25
	Private _nLinFim       := 575
	Private _cNomeLab      := ''
	Private _cEstLab       := ''
	Private _cRenaLa       := ''

	Private _oFntArN14     := TFont():New("Arial", /*uPar2*/, 14, /*uPar4*/, .T., /*uPar6*/, /*uPar7*/, /*uPar8*/, /*uPar9*/, /*lUnderline*/, /*lItalic*/)
	Private _oFntAr11      := TFont():New("Arial", /*uPar2*/, 11, /*uPar4*/, .F., /*uPar6*/, /*uPar7*/, /*uPar8*/, /*uPar9*/, /*lUnderline*/, /*lItalic*/)
	Private _oFntArN10     := TFont():New("Arial", /*uPar2*/, 10, /*uPar4*/, .T., /*uPar6*/, /*uPar7*/, /*uPar8*/, /*uPar9*/, /*lUnderline*/, /*lItalic*/)
    Private _oFntAr10      := TFont():New("Arial", /*uPar2*/, 10, /*uPar4*/, .F., /*uPar6*/, /*uPar7*/, /*uPar8*/, /*uPar9*/, /*lUnderline*/, /*lItalic*/)
	Private _oFntAr08N     := TFont():New("Arial", /*uPar2*/, 08, /*uPar4*/, .F., /*uPar6*/, /*uPar7*/, /*uPar8*/, /*uPar9*/, /*lUnderline*/, /*lItalic*/)
	Private _oFntArN08     := TFont():New("Arial", /*uPar2*/, 08, /*uPar4*/, .T., /*uPar6*/, /*uPar7*/, /*uPar8*/, /*uPar9*/, /*lUnderline*/, /*lItalic*/)

	cData := cvaltochar(Day(dData)) + " de " + AGRMesAno(SUBSTR( DTOC(dData), 4, 10) , 4) + " de " + cvaltochar(Year(dData))

	cPathLogo  := cPathLogo+"lgrl"+cEmpAnt+cFilAnt+".bmp"
	If !File(cPathLogo)
		cPathLogo := cPathLogo+"lgrl"+cEmpAnt+".bmp"
		If !File(cPathLogo)
			cPathLogo := ""
		Endif   
	Endif   

	cPathAsTec  := cPathAsTec+STR0001+cCPFTec+".bmp" //"assinatura_tecnica_"
	If !File(cPathAsTec)
		cPathAsTec := ""
	Endif   
	
	fBusLab(cCodLab, cLojaLab)
	cMsg := STR0002 + STR0003 +alltrim(_cNomeLab)+ STR0004 + alltrim(_cEstLab) + STR0005 +alltrim(_cRenaLa)+ STR0006 //##"Atestamos que os lotes de sementes, abaixo discriminados, foram produzidos de acordo com as normas e padrões estabelecidos pelo ministério da Agricultura, Pecuária e Abastecimento e analisados "+;
	 	    //"pelo Laboratório de Análise de Sementes "+alltrim(_cNomeLab)+", no estado de "+alltrim(_cEstLab)+", Credenciado no RENASEM sob n° "+alltrim(_cRenaLa)+", apresentando as seguintes características:"
	
	oPrinter:=FwMsPrinter():New(STR0007 + Alltrim(cCodTerm) + ".pdf", 6, lAdjustToLegacy,cLocal, lDisableSetup,,,, /*lServer*/, /*lPDFAsPNG*/, /*lRaw*/, /*lViewPDF*/, /*nQtdCopy*/ ) //##"Termo_"
	
	oPrinter:SetResolution(72)
	oPrinter:SetLandscape()
	oPrinter:SetPaperSize(DMPAPER_A4)

	oPrinter:StartPage()     

	oPrinter:cPathPDF := GetTempPath()
	oPrinter:SetPaperSize(9) 

	oPrinter:SetLandscape()

	oPrinter:SetMargin(001,001,001,001)

	oPrinter:SayBitmap(005, 050, cPathLogo, 060, 060) 
    //Identificação do Produtor da Semente
	oPrinter:SayAlign(_nRow+(2*_nSalto),001 ,STR0008 + AllTrim(cCodTerm)	, _oFntArN14 , 830, _nSalto, , 2, 1 )//TEXTO //##"TERMO DE CONFORMIDADE DE SEMENTE NR: "

	oPrinter:SayAlign(_nRow+(3.5*_nSalto),001 ,STR0009	, _oFntArN14 , 830, _nSalto+5, , 2, 1 )//TEXTO //##"Identificação do Produtor da Semente"

	oPrinter:Box(_nRow+(5*_nSalto),015, _nRow+(8*_nSalto), 820, _cPixel) // box Produtor

	oPrinter:SayAlign(_nRow+(5*_nSalto), _nCol, STR0010 + cNome				, _oFntAr11 , 415, _nSalto, , 0, 1 )//TEXTO //##"Nome: "
	oPrinter:SayAlign(_nRow+(6*_nSalto), _nCol, STR0011 + AGRXCPOCGC(cCNPJ)	, _oFntAr11 , 415, _nSalto, , 0, 1 )//TEXTO //##"CNPJ/CPF: "
	oPrinter:SayAlign(_nRow+(7*_nSalto), _nCol, STR0012 + cRenasem			, _oFntAr11 , 415, _nSalto, , 0, 1 )//TEXTO //##"Inscrição no Renasem nº: " 
	oPrinter:SayAlign(_nRow+(5*_nSalto), 445 , STR0013 + cEnder				, _oFntAr11 , 415, _nSalto, , 0, 1 )//TEXTO //##"End: "
	oPrinter:SayAlign(_nRow+(6*_nSalto), 445 , STR0014 + cMunic				, _oFntAr11 , 415, _nSalto, , 0, 1 )//TEXTO //##"Município/UF: "
	oPrinter:SayAlign(_nRow+(7*_nSalto), 445 , STR0015 + TRANSFORM(cCEP,  PesqPict("SA2","A2_CEP")) , _oFntAr11 , 415, _nSalto, , 0, 1 )//TEXTO //##"CEP: "

	// Informações do Responsável Técnico
	oPrinter:SayAlign(_nRow+(8.5*_nSalto),001, STR0016 , _oFntArN14 , 830, _nSalto, , 2, 1 )//TEXTO //##"Identificação do Responsável Técnico"

	oPrinter:Box(_nRow+(10*_nSalto),020, _nRow+(14*_nSalto), 815	, _cPixel) // box Responsável Técnico 

	oPrinter:SayAlign(_nRow+(10*_nSalto), _nCol, STR0010 + cNomeTec				, _oFntAr11 , 415, _nSalto, , 0, 1 ) //##"Nome: "
	oPrinter:SayAlign(_nRow+(11*_nSalto), _nCol, STR0017 + AGRXCPOCGC(cCPFTec)	, _oFntAr11 , 415, _nSalto, , 0, 1 ) //##"CPF: "
	oPrinter:SayAlign(_nRow+(11*_nSalto), 445 , STR0018 + cRenasTec				, _oFntAr11 , 415, _nSalto, , 0, 1 ) //##"Credenciamento no Renasem nº: "
	oPrinter:SayAlign(_nRow+(12*_nSalto), _nCol, STR0013 + cEndTec				, _oFntAr11 , 415, _nSalto, , 0, 1 ) //##"End: "
	oPrinter:SayAlign(_nRow+(13*_nSalto), _nCol, STR0019 + cTelTec				, _oFntAr11 , 415, _nSalto, , 0, 1 ) //##"Tel: "
	oPrinter:SayAlign(_nRow+(13*_nSalto), 150 , STR0020 + cMailTec				, _oFntAr11 , 415, _nSalto, , 0, 1 ) //##"Endereço eletrônico: "
	oPrinter:SayAlign(_nRow+(13*_nSalto), 445 , STR0014 + cMunTec				, _oFntAr11 , 415, _nSalto, , 0, 1 ) //##"Município/UF: "
	oPrinter:SayAlign(_nRow+(13*_nSalto), 650 , STR0015 + TRANSFORM(cCEPTec,  PesqPict("NP8","NP8_CEP")), _oFntAr11 , 415, _nSalto, , 0, 1 ) //##"CEP: "

	// INFORMAÇÕES DOS LOTES DE SEMENTE

	oPrinter:Box(_nRow+(15*_nSalto),020, _nRow+(16*_nSalto), 815, _cPixel) // box INFORMAÇÕES DOS LOTES DE SEMENTE

	oPrinter:SayAlign(_nRow+(15*_nSalto) , _nCol, STR0021   + cEspecie		, _oFntAr11 , 415, _nSalto, , 0, 1 ) //## "Espécie: "
	oPrinter:SayAlign(_nRow+(15*_nSalto) , 300 , STR0022  + cCultivar		, _oFntAr11 , 415, _nSalto, , 0, 1 ) //##"Cultivar: "
	oPrinter:SayAlign(_nRow+(15*_nSalto) , 545 , STR0023 + cCategoria		, _oFntAr11 , 415, _nSalto, , 0, 1 )  //##"Categoria: " 
	oPrinter:SayAlign(_nRow+(15*_nSalto) , 650 , STR0024 	 + cSafra		, _oFntAr11 , 415, _nSalto, , 0, 1 ) //##"Safra: "

    //AVISO
	oPrinter:SayAlign(_nRow+(16*_nSalto +5),020,cMsg, _oFntAr08N , 795, _nSalto*3, , 2, 1 ) 

	oPrinter:Box(_nRow+(20*_nSalto),020, _nRow+(25*_nSalto), 815, _cPixel) // box Pincipal
	
	oPrinter:Box(_nRow+(20*_nSalto),020, _nRow+(25*_nSalto), 100, _cPixel) // box LOTE
    oPrinter:SayAlign(_nRow+(23*_nSalto) ,020,STR0025, _oFntArN10 , 80, _nRow+(25*_nSalto) , , 2, 1 )//##"Lote Nº"

	oPrinter:Box(_nRow+(20*_nSalto),100, _nRow+(25*_nSalto), 200,_cPixel) // box REPRESENTATIVIDADE
    oPrinter:SayAlign(_nRow+(20*_nSalto) ,100,STR0026, _oFntArN10 , 100, _nRow+(25*_nSalto) , , 2, 1 )//##"Representatividade do Lote"

	oPrinter:Box(_nRow+(22*_nSalto+1),100, _nRow+(25*_nSalto),150,_cPixel) // box Nº EMBALAGENS
	oPrinter:SayAlign(_nRow+(22*_nSalto+2) ,100,STR0027, _oFntArN10 , 50, _nRow+(25*_nSalto) , , 2, 1 )//##"Nº de Embalagem"

	oPrinter:Box(_nRow+(22*_nSalto+1),150, _nRow+(25*_nSalto), 200,_cPixel) // box PESO EMBALAGENS
    oPrinter:SayAlign(_nRow+(22*_nSalto+2),150,STR0028, _oFntArN10 , 50, _nRow+(25*_nSalto) , , 2, 1 )//##"Peso por Embalagem KG"

	oPrinter:Box(_nRow+(20*_nSalto),200, _nRow+(25*_nSalto), 300,_cPixel) // box BOLETIM
	oPrinter:SayAlign(_nRow+(20*_nSalto+1) ,200,STR0029, _oFntArN10 , 100, _nRow+(25*_nSalto) , , 2, 1 )//##"Boletim de Análise"

	oPrinter:Box(_nRow+(22*_nSalto+1),200, _nRow+(25*_nSalto), 250,_cPixel) // box Nº 
	oPrinter:SayAlign(_nRow+(22*_nSalto+2) ,200,STR0030, _oFntArN10 , 50, _nRow+(25*_nSalto) , , 2, 1 )//##Nº 

	oPrinter:Box(_nRow+(22*_nSalto+1),250, _nRow+(25*_nSalto), 300,_cPixel) // box DATA
	oPrinter:SayAlign(_nRow+(22*_nSalto+2),250,STR0031, _oFntArN10 , 50, _nRow+(25*_nSalto) , , 2, 1 )//##"Data"

	oPrinter:Box(_nRow+(20*_nSalto),300, _nRow+(25*_nSalto), 350,_cPixel) // box SEMENTES PURAS
	oPrinter:SayAlign(_nRow+(21*_nSalto) ,300,STR0032, _oFntArN10 , 50, _nRow+(25*_nSalto) , , 2, 1 )//##"Sementes Puras %"

	oPrinter:Box(_nRow+(20*_nSalto),350, _nRow+(25*_nSalto), 400,_cPixel) // box GERMINAÇÃO
	oPrinter:SayAlign(_nRow+(21*_nSalto) ,350,STR0033, _oFntArN10 , 50, _nRow+(25*_nSalto) , , 2, 1 )//##"Germinação %"

	oPrinter:Box(_nRow+(20*_nSalto),400, _nRow+(25*_nSalto), 450,_cPixel) // box SEMENTES DURAS
	oPrinter:SayAlign(_nRow+(21*_nSalto) ,400,STR0034, _oFntArN10 , 50, _nRow+(25*_nSalto) , , 2, 1 )//##"Sementes Duras %"

	oPrinter:Box(_nRow+(20*_nSalto),450, _nRow+(25*_nSalto), 700,_cPixel) // OUTROS FATORES
	oPrinter:SayAlign(_nRow+(20*_nSalto) ,450,STR0035, _oFntArN10 , 250, _nRow+(25*_nSalto) , , 2, 1 )//"Outros Fatores *"
	aColOFat 	:= fDefColOFat(aDados,250) //define colunas para outros fatores (700-450)
	fPCabOFat(@oPrinter,21,450,700,_oFntArN10,aColOFat) 
	
	oPrinter:SayAlign(_nRow+(20*_nSalto) ,700,STR0036, _oFntArN10 , 115, _nRow+(25*_nSalto) , , 2, 1 )//##"Validade do Teste de Germinação (mês/ano)"

	//percorre o adados e imprime as informações do lote
    for ni:=1 to LEN(aDados)
	    
		oPrinter:Box(_nRow+(_nLinGrid*_nSalto),020, _nRow+((_nLinGrid+1)*_nSalto) ,100,_cPixel) // box lote
		oPrinter:SayAlign(_nRow+(_nLinGrid*_nSalto+1), 020, alltrim(aDados[ni][_nPosLote]), _oFntAr10 , 80, (_nLinGrid+1)*_nSalto , , 2, 1 )//TEXTO LOTE

		oPrinter:Box(_nRow+(_nLinGrid*_nSalto),100, _nRow+((_nLinGrid+1)*_nSalto) ,150,_cPixel) // box embalagens
		oPrinter:SayAlign(_nRow+(_nLinGrid*_nSalto+1), 100, alltrim(aDados[ni][_nPosQtde]), _oFntAr10 , 50, (_nLinGrid+1)*_nSalto , , 2, 1 )//TEXTO EMBALAGEM
		
		oPrinter:Box(_nRow+(_nLinGrid*_nSalto),150, _nRow+((_nLinGrid+1)*_nSalto) ,200,_cPixel) // box peso
		oPrinter:SayAlign(_nRow+(_nLinGrid*_nSalto+1), 150, alltrim(aDados[ni][_nPosPSMDEN]), _oFntAr10 , 50, (_nLinGrid+1)*_nSalto , , 2, 1 )//TEXTO PESO
		
		oPrinter:Box(_nRow+(_nLinGrid*_nSalto),200, _nRow+((_nLinGrid+1)*_nSalto) ,250,_cPixel) // box num boletim
		oPrinter:SayAlign(_nRow+(_nLinGrid*_nSalto+1), 200, alltrim(aDados[ni][_nPosNume]), _oFntAr10 , 50, (_nLinGrid+1)*_nSalto , , 2, 1 )//TEXTO NUMERO BOLETIM
		
		oPrinter:Box(_nRow+(_nLinGrid*_nSalto),250, _nRow+((_nLinGrid+1)*_nSalto) ,300,_cPixel) // box data
		oPrinter:SayAlign(_nRow+(_nLinGrid*_nSalto+1), 250, alltrim(cValToChar(aDados[ni][_nPosData]) ), _oFntAr10 , 50, (_nLinGrid+1)*_nSalto , , 2, 1 )//TEXTO DATA BOLETIM
		
		oPrinter:Box(_nRow+(_nLinGrid*_nSalto),300, _nRow+((_nLinGrid+1)*_nSalto) ,350,_cPixel) // box pura
		oPrinter:SayAlign(_nRow+(_nLinGrid*_nSalto+1), 300, alltrim(aDados[ni][_nPosPura]), _oFntAr10 , 50, (_nLinGrid+1)*_nSalto , , 2, 1 )//TEXTO PURAS
		
		oPrinter:Box(_nRow+(_nLinGrid*_nSalto),350, _nRow+((_nLinGrid+1)*_nSalto) ,400,_cPixel) // box germina
		oPrinter:SayAlign(_nRow+(_nLinGrid*_nSalto+1), 350, alltrim(aDados[ni][_nPosGerm]), _oFntAr10 , 50, (_nLinGrid+1)*_nSalto , , 2, 1 )//TEXTO GERMINAÇÃO
		
		oPrinter:Box(_nRow+(_nLinGrid*_nSalto),400, _nRow+((_nLinGrid+1)*_nSalto) ,450,_cPixel) // box duras
		oPrinter:SayAlign(_nRow+(_nLinGrid*_nSalto+1), 400, alltrim(aDados[ni][_nPosDura]), _oFntAr10 , 50, (_nLinGrid+1)*_nSalto , , 2, 1 )//TEXTO DURAS
		
		fPLinOFat(@oPrinter,aDados[ni][_nPosOFat],aColOFat,450,_oFntAr10)
		
		oPrinter:Box(_nRow+(_nLinGrid*_nSalto),700, _nRow+((_nLinGrid+1)*_nSalto) ,815,_cPixel) // box validade
		oPrinter:SayAlign(_nRow+(_nLinGrid*_nSalto+1), 700, alltrim(aDados[ni][_nPosVali]), _oFntAr10 , 115,(_nLinGrid+1)*_nSalto , , 2, 1 )//TEXTO VALIDADE
		
		_nLinGrid++ //incrementa a variável de controle da linha 	
		If nI = 1 
			cPmsObs += aDados[ni][_nPosPSMDSC] 
		Else
			cPmsObs +=  " | " + aDados[ni][_nPosPSMDSC] 
		EndIf
		fSaltaPag(@oPrinter)
	next ni
	
	_nLinGrid++

    oPrinter:Box(_nRow+(_nLinGrid*_nSalto+5),020, _nRow+((_nLinGrid+3)*_nSalto) ,815,_cPixel) // box OBSERVAÇÕES

    oPrinter:SayAlign(_nRow+(_nLinGrid*_nSalto+7),022,STR0037 + cPmsObs, _oFntAr10 , 815, (_nLinGrid+3)*_nSalto , , 0, 1 )//##"* Obs.: PMS: "

    _nLinGrid := _nLinGrid + 4

	fSaltaPag(@oPrinter) 

    oPrinter:SayAlign(_nRow+(_nLinGrid*_nSalto),020, cMunic +", " + cData, _oFntAr10 , 815, (_nLinGrid+2)*_nSalto , , 2, 1 )//TEXTO CIDADE

    _nLinGrid := _nLinGrid + 3
	
	//assinatura
	fSaltaPag(@oPrinter)
	If !Empty(cPathAsTec)
		oPrinter:SayBitmap(_nRow+(_nLinGrid*_nSalto)-20, 380, cPathAsTec, 100, 100)
		_nLinGrid := _nLinGrid + 6
	EndIf 

	fSaltaPag(@oPrinter)
	//oPrinter:SayBitmap(_nRow+(_nLinGrid*_nSalto)-20, 380, cAssTecn, 100, 100) 
	//_nLinGrid++
	oPrinter:Line(_nRow+(_nLinGrid*_nSalto),250, _nRow+(_nLinGrid*_nSalto), 570 ) //linha de assinatura
	_nLinGrid++
 	oPrinter:SayAlign(_nRow+(_nLinGrid*_nSalto),020,cNomeTec , _oFntAr10 , 815, (_nLinGrid+2)*_nSalto , , 2, 1 ) //texto Nome
	_nLinGrid++
	oPrinter:SayAlign(_nRow+(_nLinGrid*_nSalto),020,STR0038, _oFntAr10 , 815, (_nLinGrid+2)*_nSalto , , 2, 1 ) //##"Responsável Técnico"
	
	oprinter:Endpage()

	oPrinter:Preview()

	FreeObj(oPrinter)

Return .T.

/*/{Protheus.doc} fSaltaPag
Verifica se é necessario salto de página
@type function
@version  P12
@author Daniel Silveira / claudineia.reinert
@since 20/11/2023
@param oPrinter, object, objeto de impressão
@return variant, , não retorna valores
/*/
Static Function fSaltaPag(oPrinter)
	if _nLinGrid * (_nSalto) >= _nLinFim
		oPrinter:Endpage() 
		oPrinter:StartPage()
		_nLinGrid := 3
	endif
return

/*/{Protheus.doc} fBusLab
Busca nome, estado e codigo renasem do laboratorio
seta valores nas variaveis privates _cNomeLab,_cEstLab,_cRenaLa
@type function
@version P12  
@author Daniel Silveira / claudineia.reinert
@since 20/11/2023
@param cCodLab, character, codigo do laboratorio
@param cLojaLab, character, loja do laboratorio
@return variant, não retorna valores
/*/Static Function fBusLab(cCodLab, cLojaLab)
	Local cAliLab := GetNextAlias()
	Local cQuery := ''

	cQuery += " SELECT A2_NOME, A2_EST, DKE_RENASE" 
	cQuery += " FROM "+RetSqlName("SA2")+" SA2 "
	cQuery += " LEFT OUTER JOIN "+RetSqlName("DKE")+" DKE ON DKE.D_E_L_E_T_ = '' AND DKE.DKE_FILIAL = SA2.A2_FILIAL AND DKE.DKE_COD = SA2.A2_COD AND DKE.DKE_LOJA = SA2.A2_LOJA "
	cQuery += " WHERE SA2.D_E_L_E_T_ = ' ' "
	cQuery += " AND A2_FILIAL = '"+FWxFilial('SA2')+"' "
	cQuery += " AND A2_COD = '"+cCodLab+"' "
	cQuery += " AND A2_LOJA = '"+cLojaLab+"' "
	cQuery := changequery(cQuery)

	dbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAliLab, .F., .T.)

	_cNomeLab := (cAliLab)->A2_NOME
	_cEstLab  := (cAliLab)->A2_EST
	_cRenaLa  := (cAliLab)->DKE_RENASE

	(cAliLab)->(dbclosearea())
Return

/*/{Protheus.doc} fDefColOFat
Função responsavel por definir as colunas e tamanho das colunas para o item outros fatores
@type function
@version P12 
@author claudineia.reinert
@since 20/11/2023
@param aDados, array, Dados 
@param nTamOFat, numeric, Indica a coordenada vertical disponivel para as colunas outros faotres 
@return array, array com os dados {{codigo variavel analise, descrição variavel analise, tamanho para a coluna}}
/*/
Static Function fDefColOFat(aDados,nTamOFat)
	Local aCols := {}
	Local nX	:= 0
	Local nY 	:= 0
	Local aOutFat := {}
	Local nPos	:= 0
	Local nTamCols := 0

	For nX := 1 to Len (aDados)
		aOutFat := aDados[nX][_nPosOFat]
		For nY := 1 to Len (aOutFat)
			nPos := aScan(aCols, {|x| x[1] == AllTrim(aOutFat[nY][1])})
			If nPos = 0
				aadd(aCols,{aOutFat[nY][1],aOutFat[nY][2],0})
			EndIf
		next nY
	next nX 

	If LEN(aCols) = 0 //padrão para quando não há outros fatores
		aadd(aCols,{"","",0}) 
		aadd(aCols,{"","",0}) 
		aadd(aCols,{"","",0}) 
	EndIf

	//define o tamanho para as colunas
	For nX := 1 to Len(aCols)
		nTamCols :=  int(nTamOFat/(Len(aCols)-(nX-1)))
		aCols[nX][3] := nTamCols
		nTamOFat -= nTamCols
	next nX 
	

Return aCols

/*/{Protheus.doc} fPCabOFat
Função responsavel por imprimir o titulo nas colunas referente a outros fatores no termo de conformidade 
@type function
@version  P12
@author claudineia.reinert
@since 20/11/2023
@param oPrinter, object, Objeto da impressão
@param nLin, numeric, valor para calculo da coordenada vertical da linha
@param nIniCol, numeric, Indica a coordenada horizontal inicial da coluna outros fatores
@param nFimCol, numeric, Indica a coordenada horizontal final da coluna outros fatores
@param oFnt, object, objeto Tfont para definir a fonte do conteudo
@param aColOFat, array, dados para as colunas {{codigo variavel analise, descrição variavel analise, tamanho para a coluna}}
@return variant, não retorna valores
/*/
Static Function fPCabOFat(oPrinter,nLin,nIniCol,nFimCol,oFnt,aColOFat) 
	Local nQtdCol 	:= LEN(aColOFat) //qtd de colunas
	Local nX 		:= 0
	Local nColIBox	:= nIniCol //coluna inicial box
	Local nColFBox	:= nIniCol //coluna final box

	For nX:=1 to nQtdCol
		nColIBox := nColFBox 
		nColFBox := nColFBox + aColOFat[nX][3]
		oPrinter:Box(_nRow+(nLin*_nSalto),nColIBox, _nRow+(25*_nSalto), nColFBox,_cPixel) // box coluna
		oPrinter:SayAlign(_nRow+((nLin)*_nSalto) ,nColIBox,ALLTRIM(aColOFat[nX][2]), oFnt , aColOFat[nX][3], _nRow+(25*_nSalto) , , 2, 1 )//TEXTO coluna
	Next nX

Return ()

/*/{Protheus.doc} fPLinOFat
Função responsavel por imprimir os dados nas linhas referentes as colunas outros fatores no termo de conformidade 
@type function
@version P12 
@author claudineia.reinert
@since 20/11/2023
@param oPrinter, object, Objeto da impressão
@param aDadOFat, array, os Dados referentes a outros fatores para impressão
@param aColOFat, array, as colunas referentes a outros fatores com a descrição e posição
@param nIniCol, numeric, Indica a coordenada horizontal inicial da coluna outros fatores
@param oFnt, object, objeto Tfont para definir a fonte do conteudo
@return variant, não retorna valores
/*/
Static Function fPLinOFat(oPrinter,aDadOFat,aColOFat,nIniCol,oFnt)
	Local nX 		:= 0
	Local nColIni	:= nIniCol
	Local nColFim	:= nIniCol
	Local nPos		:= 0
	Local cTexto 	:= ""

	For nX:=1 to LEN(aColOFat)
		nColIni := nColFim
		nColFim := nColIni+aColOFat[nX][3]
		cTexto := ""
		nPos := aScan(aDadOFat, {|x| x[1] == AllTrim(aColOFat[nX][1])})
		If nPos > 0
			cTexto := alltrim(aDadOFat[nPos][3])
		EndIf
		oPrinter:Box(_nRow+(_nLinGrid*_nSalto),nColIni, _nRow+((_nLinGrid+1)*_nSalto) ,nColFim,_cPixel) // box 
		oPrinter:SayAlign(_nRow+(_nLinGrid*_nSalto+1), nColIni, cTexto, oFnt , aColOFat[nX][3],(_nLinGrid+1)*_nSalto , , 2, 1 )//TEXTO 
	Next nX

Return ()

/*/{Protheus.doc} fNP3Espec
Busca a descrição da especie para impressão no termo de conformidade
@type function
@version  P12
@author claudineia.reinert
@since 12/19/2023
@param cCodNP3, character, código da cultura
@return variant, descrição da especie/cultura mais o nome cientifico se tiver informado
/*/
Static Function fNP3Espec(cCodNP3)
	Local cRet := ""

	DBSELECTAREA( "NP3" )
	DBSETORDER( 1 )
	If NP3->(DbSeek(FWxFilial('NP3') + cCodNP3)) 
		cRet := Alltrim(NP3->NP3_DESCRI)
		If !Empty(NP3->NP3_NOMCIE)
			cRet += " ("+Alltrim(NP3->NP3_NOMCIE)+")"
		EndIf
	EndIf
	NP3->(DBCLOSEAREA())
Return cRet
