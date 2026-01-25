#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PROTHEUS.CH"


/*/{Protheus.doc} DareXml
    (
        Dummy Function para reserva do nome no arquivo .PRW
        Fonte criado para separar o menu especifico do FISA095
        para geração do arquivo xml de guias DARE-SP.
    )
    @type  Function
    @author Delleon Fernandes
    @since 23/01/2023
    @version 12.1.2210
    /*/
Function DareXml()
Return


/*/{Protheus.doc} MenuDef
    (
        Este menu foi criado para ser utilizado no SetMenuDef do FISA095 quando for no Estado de SP
        Como não é possível criar condicionais na definição de menudef 
        conforme equipe de framework link https://tdn.totvs.com.br/display/public/framework/MenuDef
        criamos outro neste fonte DAREXML.PRW para atender os requisitos exigidos do fremework.
    )
    @type  Static Function
    @author Delleon Fernandes
    @since 23/01/2023
    @version 12.1.2210
/*/
Static Function MenuDef()

	local aRotina := {}
	ADD OPTION aRotina TITLE 'Visualizar'	        ACTION 'VIEWDEF.MATA960'	OPERATION 2  ACCESS 0
	ADD OPTION aRotina TITLE 'Exportar XML GNRE'    ACTION 'DareXmlGer'		    OPERATION 8  ACCESS 0

Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} DareXmlGer
Gerar arquivo XML com GNREs de SP

@author Delleon Fernandes Silva
@since 20.12.2022
@version 12.1.2210

/*/
//-------------------------------------------------------------------   
Function DareXmlGer()
	Local aArea     := GetArea()
	Local lEnd	    := .F.
	Local lGerou    := .F.
	Local lF6PROCESS:= .F.
	Local cFileDest := ""
	local cNomWiz   := SM0->(M0_CODIGO+M0_CODFIL)+"DAREXMLGER"

	If WizardXML(cNomWiz)

		Processa({|lEnd| GnreXMLArq(@lEnd, cNomWiz, , @lGerou, @cFileDest, @lF6PROCESS)})

		If lF6PROCESS
			Help(NIL, NIL, "Atenção!", NIL, "Foi identificado que existem guias já processadas e não serão apresentadas neste arquivo", 1, 0, NIL, NIL, NIL, NIL, NIL,;
				{"Caso seja necessário apresentar, acessar a rotina MATA960 'Guia Nacional de Recolhimento' e alterar o campo 'Processa' F6_PROCESS para 2-Nao"})
		ElseIf lGerou
			MsgInfo("Arquivo "  + cFileDest + " gerado com sucesso!")
		Else
			MsgAlert("Não foi possível gerar o arquivo!")
		EndIf

	EndIf

	RestArea(aArea)
Return



/*/{Protheus.doc} WizardXML
	(Wizard para gerar arquivo XML)
	
	@type  Function
	@author Delleon Fernandes Silva
	@since 21/12/2022
	@version 12.1.2210
	
	@param param_name, param_type, param_descr

	@return .T. se finalizado com sucesso
	@return .F. se foi cancelado

/*/
Static Function WizardXML(cNomWiz)
	Local	aTxtApre	:= {}
	Local	aPaineis	:= {}
	Local	cTitObj1	:= ""
	Local	cTitObj2	:= ""
	Local	lRet		:= .T.
	Local   nLenF6NUMERO:= len(SF6->F6_NUMERO)
	Local   cParNumGnre := Replicate("X", nLenF6NUMERO)

//ÚÄÄÄÄÄÄÄÄ¿
//³Painel 0³
//ÀÄÄÄÄÄÄÄÄÙ
	aAdd (aTxtApre, "Parâmetros necessários.")
	aAdd (aTxtApre, "")
	aAdd (aTxtApre, "Preencha corretamente as informações solicitadas.")
	aAdd (aTxtApre, "Esta funcionalidade permite exportação de arquivo XML em layout de GNRE para importação no portal e geração de DAREs SP.")


//ÚÄÄÄÄÄÄÄÄ¿
//³Painel 1³
//ÀÄÄÄÄÄÄÄÄÙ
	aAdd (aPaineis, {})
	nPos	:=	Len (aPaineis)
	aAdd (aPaineis[nPos], "Preencha corretamente as informações solicitadas.")
	aAdd (aPaineis[nPos], "Parâmetros para Geração")
	aAdd (aPaineis[nPos], {})

//
	cTitObj1	:=	"Número GNRE Inicial:"; 					cTitObj2	:=	"Número GNRE Final:"
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});				aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})

	cTitObj1	:=	cParNumGnre;	                            cTitObj2	:=	cParNumGnre
	aAdd (aPaineis[nPos][3], {2,,cTitObj1,1,,,,nLenF6NUMERO});	aAdd (aPaineis[nPos][3], {2,,cTitObj2,1,,,,nLenF6NUMERO})

	aAdd (aPaineis[nPos][3], {0,"",,,,,,});						aAdd (aPaineis[nPos][3], {0,"",,,,,,})
//
	cTitObj1	:=	"Data de";								   	cTitObj2	:=	"Data até"
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});				aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})

	aAdd (aPaineis[nPos][3], {2,,,3,,,,});						aAdd (aPaineis[nPos][3], {2,,,3,,,,})

	aAdd (aPaineis[nPos][3], {0,"",,,,,,});						aAdd (aPaineis[nPos][3], {0,"",,,,,,})
//
	cTitObj1	:=	"Diretório do Arquivo Destino";				cTitObj2	:=	"Nome do Arquivo Destino"
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});				aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})

	cTitObj1	:=	Replicate ("X", 50);						cTitObj2	:=	Replicate ("X", 20)
	aAdd (aPaineis[nPos][3], {2,,cTitObj1,1,,,,50});			aAdd (aPaineis[nPos][3], {2,,cTitObj2,1,,,,20})

	aAdd (aPaineis[nPos][3], {0,"",,,,,,});						aAdd (aPaineis[nPos][3], {0,"",,,,,,})

	lRet :=	xMagWizard(aTxtApre, aPaineis, cNomWiz)
Return (lRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} GnreXMLArq
Obtem parametros para geração do arquivo Xml GNRE SP.

@author Delleon Fernandes Silva
@since 21.12.2022

@param   lEnd       Booleano Controle do Processa()
@param   cNomWiz    Caracter Nome CFP do Wizard
@param   cUFFav     Caracter UF de processamento das Guias
@param   lGerou     Booleano controla se gerou ou não o arquivo
@param   cFileDest  Caracter Arquivo de destino do XML
@param   lF6PROCESS Booleano Indica se existe Guias já Processadas

/*/
//-------------------------------------------------------------------
static function GnreXMLArq(lEnd, cNomWiz, cUFFav, lGerou, cFileDest, lF6PROCESS)

	local aXML		:= {}
	local cAliasSF6	:= "SF6"
	local nY		:= 0
	local nB		:= 0
	Local aWizard   := {}

	Local cGNREIni  := ""
	Local cGNREFim  := ""
	Local cDataDe   := ""
	Local cDataAte  := ""
	Local cDir      := ""
	Local cNomeArq  := ""
	Local lNoWS     := .T.
	Local nLenAXML  := 0
	Local cXml      := ""
	Local cArqXml   := ""
	Local cIdGN     := ""
	Local cUFGnre   := ""
	Local cNumGN    := ""
	Local oFWriter	:= nil

	Default cUFFav    := "SP"
	Default lGerou    := .F.
	Default lF6PROCESS:= .F.
	Default cFileDest := ""

	// Atribuo o conteudo do CFP gerado pelo wizard no array aWizard
	If xMagLeWiz(cNomWiz, @aWizard, .T.)
		cGNREIni := Alltrim(aWizard[1][1])
		cGNREFim := Alltrim(aWizard[1][2])
		cDataDe	 :=	aWizard[1][3]
		cDataAte :=	aWizard[1][4]
		cDir     := Alltrim(aWizard[1][5])
		cNomeArq := Alltrim(aWizard[1][6])
	EndIf

	If (SubStr(cDir, Len(cDir), 1)<>"\")
		cDir +=	"\"
	EndIf

	FISA095Qry(@cAliasSF6, cGNREIni, cGNREFim, cUFFav, lNoWS, cDataDe, cDataAte)

	while !(cAliasSF6)->(Eof()) .And. (xFilial("SF6") == (cAliasSF6)->F6_FILIAL)
		lGerou   := .T.

		If (cAliasSF6)->F6_PROCESS == '1' // Controle de DAREs não processados
			lF6PROCESS := .T.
			(cAliasSF6)->(dbSkip())
			Loop
		EndIf

		aadd(aXML,{})
		nY       := Len(aXML)
		aXML[nY] := ExecBlock("GnreXMLEnv",.F.,.F.,{cAliasSF6})

		(cAliasSF6)->(dbSkip())
	enddo

	nLenAXML := len(aXML)
	if nLenAXML > 0
		cArqXml := '<TLote_GNRE xmlns="http://www.gnre.pe.gov.br" versao="2.00">'
		cArqXml += '<guias>'

		dbselectarea('SF6')
		SF6->(dbSetOrder(1))

		//Gravo o Id na tabela SF6
		for nB:= 1 to nLenAXML

			cIdGN   := alltrim( aXML[nB,1] )
			cUFGnre := left(cIdGN, 2)
			cNumGN  := right(cIdGN, len(cIdGN)-2)
			cXml    := aXML[nB,2]
			cArqXml += cXml

			if dbSeek(xFilial("SF6")+cUFGnre+cNumGN)
				RecLock("SF6",.F.)
				SF6->F6_PROCESS:= "1"
				SF6->F6_GNREWS := "S"
				SF6->F6_IDTSS  := cIdGN
				SF6->F6_XMLENV := cXml
				MsUnlock()
			endif
		next

		cArqXml += '</guias>'
		cArqXml += '</TLote_GNRE>'
	endif

	#IFDEF TOP
		dbSelectArea(cAliasSF6)
		dbCloseArea()
	#ELSE
		dbSelectArea(cAliasSF6)
		RetIndex(cAliasSF6)
		ferase(nIndex+OrdBagExt())
	#ENDIF

	If lGerou
		cFileDest := cDir+cNomeArq
		oFWriter  := FWFileWriter():new(cFileDest, .F.)
		// Se o arquivo já existe, apaga
		If oFWriter:Exists()
			oFWriter:Erase()
		EndIf
		// Cria o arquivo
		If oFWriter:Create()
			// Se criou com sucesso, escreve
			oFWriter:Write(cArqXml)
		EndIf		
		// Fecha o arquivo
		oFWriter:Close()
		lGerou := oFWriter:Exists()

		FreeObj(oFWriter)

	Endif

Return

