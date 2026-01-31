#INCLUDE "TOTVS.CH"
#INCLUDE "XMLXFUN.CH"
#include "protheus.ch"
#include "topconn.ch"
#include "fileio.ch"
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    | IMPXML     | Autor | MIL			          | Data | 18/01/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição |                                                              |##
##+----------+--------------------------------------------------------------+##
##|Uso       |                                                              |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
User Function IMPXMLSC()
//
Local cDesc1       := "Importação de nota fiscal de compra." // TODO - Descrição do FormBatch
Local cDesc2       := "" // TODO - Descrição do FormBatch
Local cDesc3       := "" // TODO - Descrição do FormBatch
Local aSay         := {}
Local aButton      := {}
PRIVATE cCadastro  := ""
PRIVATE oXmlHelper := nil
PRIVATE aRotina
//
Private cTitulo    := "Importação XML Entrada" // TODO - Titulo do Assunto (Vai no relatório e FormBatch)
Private cPerg      := "IMPXMLSC"
Private lErro      := .f.		// Se houve erro, não move arquivo gerado
Private cArquivo				// Nome do Arquivo a ser importado
Private aLinhasRel := {}		// Linhas que serão apresentadas no relatorio
Private aItemErro  := {}
Private aVolumes   := {}
Private cPedido := ""
Private cItemPc := ""
Private nMostraTela := 0 // Obrigatória já que é usada diretamente na função A140NFISCAL()
Private aDirImpor := {}
Private cComplPC := iif( GetNewPar("MV_PEDANO","N")=="S", "/" + Right(Alltrim(Str(Year(DDATABASE),4)),2), "" )

	ajustaSX1()

	aAdd( aSay, cDesc1 ) // Um para cada cDescN
	aAdd( aSay, cDesc2 ) // Um para cada cDescN
	aAdd( aSay, cDesc3 ) // Um para cada cDescN

	nOpc := 0
	aAdd( aButton, { 5, .T., {|| Pergunte(cPerg,.T. )    }} )
	aAdd( aButton, { 1, .T., {|| nOpc := 1, FechaBatch() }} )
	aAdd( aButton, { 2, .T., {|| FechaBatch()            }} )

	FormBatch( cTitulo, aSay, aButton )
	If nOpc <> 1
		Return nil
	Endif

	Pergunte(cPerg,.f.)

	If len( aDirImpor ) == 0
		fwAlertWarning( "Favor preencher uma pasta com XMLs para carga.", cTitulo )
		Return nil
	EndIf

	If Empty(MV_PAR02)
		fwAlertWarning( "Favor preencher a Marca.", cTitulo )
		Return nil
	EndIf

	If Empty(MV_PAR04)
		fwAlertWarning( "Favor preencher o tipo do documento.", cTitulo )
		Return nil
	EndIf

	If MV_PAR06 == 2 .and. empty(MV_PAR07)
		fwAlertWarning( "Favor preencher a pasta destino.", cTitulo )
		Return nil
	EndIf

	FS_SELARQUIVOS()
return nil


//----------------------------------------------------------
Static Function FS_SELARQUIVOS()
Local oDlgSelArquivo
Local cMarca   := MV_PAR02
Local aSize    := FWGetDialogSize( oMainWnd )
Local oNo      := LoadBitmap( GetResources(), "LBNO" )
Local oTik     := LoadBitmap( GetResources(), "LBTIK" )
Local nOpca    := 0
Local nAcao    := MV_PAR05
Local nCntFor  := 0
local cNomeArq
local cDrive
local cDir
local cNome
local cExt
local cConteudo
Private cCadastro := "Selecionar arquivos XML para importação"
Private oProcImpXML
Private lMarcar    := .f.
Private cEspecNF := MV_PAR04
Private oLBoxArquivos
Private aArquivos := {}
	for nCntFor := 1 to Len(aDirImpor)

		cNomeArq  := alltrim( aDirImpor[nCntFor,1] )
		SplitPath( cNomeArq, @cDrive, @cDir, @cNome, @cExt )

		if lower( cExt ) != ".xml"
			loop
		endif

		If MV_Par03 == 1 // Mostra detalhes dos Arquivos
			lError     := .f.
			lContinue  := .t.
			cError     := ""
			cWarning   := ""
			cConteudo  := getConteudo( alltrim(MV_PAR01) + cNomeArq )
			oXml       := XmlParser( cConteudo, "_", @cError, @cWarning )
			If !Empty(cError) .or. VALTYPE( XmlChildEx(oXml, "_NFEPROC") ) == "U" // valida se o xml é válido
				Loop
			EndIf
			oXmlHelper := Mil_XmlHelper():New(oXml)
			cVerXML := oXmlHelper:GetValue("_NFEPROC:_NFE:_INFNFE:_VERSAO:Text")
			If ValType(oXml:_NFEPROC:_NFE:_INFNFE:_DET) == "O"
				nPecas := 1
			Else
				nPecas := Len(oXml:_NFEPROC:_NFE:_INFNFE:_DET)
			EndIf
			if nPecas <= 0
				Loop
			EndIf
			cSerie  := oXmlHelper:GetValue("_NFEPROC:_NFE:_INFNFE:_IDE:_serie:Text")
			cNF     := oXmlHelper:GetValue("_NFEPROC:_NFE:_INFNFE:_IDE:_NNF:Text")
			If Val(Left(cVerXML,1)) <= 2
				cEmissao := oXmlHelper:GetValue("_NFEPROC:_NFE:_INFNFE:_IDE:_DEMI:Text")
			Else
				cEmissao := oXmlHelper:GetValue("_NFEPROC:_NFE:_INFNFE:_IDE:_DHEMI:Text")
			EndIf
			dEmissao := stod(Left(cEmissao,4)+subs(cEmissao,6,2)+subs(cEmissao,9,2))
			cCNPJFor := oXmlHelper:GetValue("_NFEPROC:_NFE:_INFNFE:_EMIT:_CNPJ:Text")
			DBSelectArea("SA2")
			DBSetOrder(3)
			DBSeek(xFilial("SA2") + Alltrim(cCNPJFor))
	 		aAdd(aArquivos,{.f.,cNome + cExt,cNF,cSerie,cEmissao,cCNPJFor,SA2->A2_COD+"-"+SA2->A2_LOJA+" "+SA2->A2_NOME, cNomeArq})
		Else
	 		aAdd(aArquivos,{.f.,cNome + cExt,"","","","","", cNomeArq})
		Endif
	Next

	if len( aArquivos ) > 0
		oDlgSelArquivo := MSDialog():New( aSize[1], aSize[2], aSize[3], aSize[4], cCadastro, , , , nOr( WS_VISIBLE, WS_POPUP ), , , , , .T., , , , .F. )
		oLBoxArquivos := TWBrowse():New(1,1,100,100,,,,oDlgSelArquivo,,,,,{ || FS_TIK( lMarcar, "0") },,,,,,,.F.,,.T.,,.F.,,,)
		oLBoxArquivos:AddColumn( TCColumn():New( "", { || IIf(aArquivos[oLBoxArquivos:nAt,1],oTik,oNo) } ,,,,"LEFT" ,05,.T.,.F.,,,,.F.,) ) // Tik
		oLBoxArquivos:AddColumn( TCColumn():New( "Arquivo XML" , { || aArquivos[oLBoxArquivos:nAt,2] } ,,,,"LEFT" ,100,.F.,.F.,,,,.F.,) )
		oLBoxArquivos:AddColumn( TCColumn():New( "Nota Fiscal" , { || aArquivos[oLBoxArquivos:nAt,3] } ,,,,"LEFT" ,60,.F.,.F.,,,,.F.,) )
		oLBoxArquivos:AddColumn( TCColumn():New( "Série" , { || aArquivos[oLBoxArquivos:nAt,4] } ,,,,"LEFT" ,30,.F.,.F.,,,,.F.,) )
		oLBoxArquivos:AddColumn( TCColumn():New( "Emissão" , { || aArquivos[oLBoxArquivos:nAt,5] } ,,,,"LEFT" ,100,.F.,.F.,,,,.F.,) )
		oLBoxArquivos:AddColumn( TCColumn():New( "CNPJ Fornecedor" , { || Transform(aArquivos[oLBoxArquivos:nAt,6],GetSX3Cache("A2_CGC","X3_PICTURE")) } ,,,,"LEFT" ,100,.F.,.F.,,,,.F.,) )
		oLBoxArquivos:AddColumn( TCColumn():New( "Fornecedor" , { || aArquivos[oLBoxArquivos:nAt,7] } ,,,,"LEFT",200,.F.,.F.,,,,.F.,) )
		oLBoxArquivos:setArray( aArquivos )
		oLBoxArquivos:Align := CONTROL_ALIGN_ALLCLIENT
		oLBoxArquivos:bHeaderClick := {|oObj,nCol| IIf( nCol==1 , ( lMarcar := !lMarcar , FS_TIK(lMarcar,"1") ) , ) , }
		ACTIVATE MSDIALOG oDlgSelArquivo ON INIT EnchoiceBar(oDlgSelArquivo,{|| (nOpca := 1,oDlgSelArquivo:End()) },{|| oDlgSelArquivo:End() },,)
	else
		MsgInfo("Nenhum arquivo foi carregado, verifique!")
	endif
	If nOpca == 1 .and. len( aArquivos ) > 0
		oProcImpXML := MsNewProcess():New({ |lEnd| ImportaXML(nAcao, cMarca) }," Importando XML ...","",.f.)
		oProcImpXML:Activate()
	Endif
Return nil


Static Function ImportaXML(	nAcao, cMarca )
Local cError   := ""
Local cWarning := ""
Local cFile    := ""
Local lAchou   := .f.
Local nCntFor  := 0
Local nCntFor2 := 0
Local aSize    := FWGetDialogSize( oMainWnd )
Local cNF      := ""
Local cSerNF   := ""
Local cCodSA2  := ""
Local cLojSA2  := ""
Local aVetCpos := {}
Local cVerXML := ""
Local cChaveNFE := Space(44)
Local nTotArquivos := 0
Local cTmpTotIni := Time()
Local cTmpArqIni
Local lFuncTempo := ExistFunc("OA3630011_Tempo_Total_Conferencia_Volume_Entrada")
Private	nBasICM    	:= 0
Private	nPerICM    	:= 0
Private	nValICM    	:= 0
Private	nBasICMST  	:= 0
Private	nPerICMST  	:= 0
Private	nValICMST  	:= 0
Private	cModBCST    := ""
Private nAlqSB1		:= 0
Private lError := .f.
Private cProduto := ""
Private cDescP   := ""
Private cCFOP    := ""
Private nQuant   := 0
Private nValUni  := 0
Private nBasIPITri := 0
Private nPerIPITri := 0
Private nValIPITri := 0
Private nBasPIS    := 0
Private nPerPIS    := 0
Private nValPIS    := 0
Private nBasCOF    := 0
Private nPerCOF    := 0
Private nValCOF    := 0
Private nTBaseIPI  := 0
Private cNumIte    := Repl( "0", Len(SD1->D1_ITEM) )
Private aItens 	   := {}
Private oDet
Private oXml
Private cAliasSB     := "SQLSB"
Private lContinue    := .t.
Private aVetPed      := {}
Private nTamMatItens := IIf( nAcao == 1 , 18 , 19 )
Private aPCs         := {}
Private lMSHelpAuto  := .t.
Private lMsErroAuto  := .f.

	// Totaliza Barra 1
	aEval(aArquivos,{ |x| nTotArquivos += IIf( x[1] , 1 , 0 ) })
	oProcImpXML:SetRegua1(nTotArquivos)

	for nCntFor := 1 to Len(aArquivos)

		if !aArquivos[nCntFor,1]
			Loop
		Endif

		cTmpArqIni := Time()

		lError     := .f.
		lContinue  := .t.

		cFile := aTail( aArquivos[nCntFor] )
		Pergunte(cPerg,.f.)

		//Gera o Objeto XML
		cConteudo  := getConteudo( alltrim(MV_PAR01) + cFile )
		oXml       := XmlParser( cConteudo, "_", @cError, @cWarning )
		If !Empty(cError) .or. VALTYPE( XmlChildEx(oXml, "_NFEPROC") ) == "U" // valida se o xml é válido
			MsgStop("Arquivo XML inválido" + chr(13) + chr(10)  + chr(13) + chr(10) + ;
				"Arquivo: " + AllTrim(cFile) + chr(13) + chr(10) + ;
				IIf( !Empty(cError), "Erro: " + AllTrim(cError), "" ),"Erro")
			Loop
		EndIf

		oXmlHelper := Mil_XmlHelper():New(oXml)

		cVerXML := oXmlHelper:GetValue("_NFEPROC:_NFE:_INFNFE:_VERSAO:Text")

		If ValType(oXml:_NFEPROC:_NFE:_INFNFE:_DET) == "O"
			nPecas := 1
		Else
			nPecas := Len(oXml:_NFEPROC:_NFE:_INFNFE:_DET)
		EndIf

		if nPecas <= 0
			Loop
		EndIf

		cTxtObs := oXmlHelper:GetValue("_NFEPROC:_NFE:_INFNFE:_INFADIC:_INFADFISCO:Text")
		cSerie  := oXmlHelper:GetValue("_NFEPROC:_NFE:_INFNFE:_IDE:_serie:Text")
		cNF     := oXmlHelper:GetValue("_NFEPROC:_NFE:_INFNFE:_IDE:_NNF:Text")

		oProcImpXML:IncRegua1("Processando Nota Fiscal: " + cSerie + "-" + cNF)

		If Val(Left(cVerXML,1)) <= 2
			cEmissao := oXmlHelper:GetValue("_NFEPROC:_NFE:_INFNFE:_IDE:_DEMI:Text")
		Else
			cEmissao := oXmlHelper:GetValue("_NFEPROC:_NFE:_INFNFE:_IDE:_DHEMI:Text")
		EndIf
		dEmissao := stod(Left(cEmissao,4)+subs(cEmissao,6,2)+subs(cEmissao,9,2))
		cCNPJFor := oXmlHelper:GetValue("_NFEPROC:_NFE:_INFNFE:_EMIT:_CNPJ:Text")
		//--------------------------------------------------------------------------------------------------------//
		// Estes campos abaixo não estavam sendo utilizados mas serão mantidos por 1 versao para manter historico //
		//--------------------------------------------------------------------------------------------------------//
		// nCNPJCli  := oXmlHelper:GetValue("_NFEPROC:_NFE:_INFNFE:_DEST:_CNPJ:Text")                             //
		// nTBasICM  := oXmlHelper:GetValue("_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VBC:Text", 0)                 //
		// nTValMerc := oXmlHelper:GetValue("_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VPROD:Text", 0)               //
		// nTValDesc := oXmlHelper:GetValue("_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VDESC:Text", 0)               //
		// nTValPIS  := oXmlHelper:GetValue("_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VPIS:Text", 0)                //
		// nTValCOF  := oXmlHelper:GetValue("_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VCOFINS:Text", 0)             //
		// nTotNF    := oXmlHelper:GetValue("_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VNF:Text", 0)                 //
		// cDatVenc  := oXmlHelper:GetValue("_NFEPROC:_NFE:_INFNFE:_COBR:_DUP:_DVENC:Text", 0)                    //
		// nNumDupl  := oXmlHelper:GetValue("_NFEPROC:_NFE:_INFNFE:_COBR:_DUP:_NDUP:Text", 0)                     //
		// nValDupl  := oXmlHelper:GetValue("_NFEPROC:_NFE:_INFNFE:_COBR:_DUP:_VDUP:Text", 0)                     //
		// dDatVenc  := stod(Left(cDatVenc,4)+subs(cDatVenc,6,2)+subs(cDatVenc,9,2))                              //
		//--------------------------------------------------------------------------------------------------------//
		nTValICM  := oXmlHelper:GetValue("_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VICMS:Text"  , '0')
		nTBasST   := oXmlHelper:GetValue("_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VBCST:Text"  , '0')
		nTValST   := oXmlHelper:GetValue("_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VST:Text"    , '0')
		nTValFre  := oXmlHelper:GetValue("_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VFRETE:Text" , '0')
		nTValSeg  := oXmlHelper:GetValue("_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VSEG:Text"   , '0')
		nTValIPI  := oXmlHelper:GetValue("_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VIPI:Text"   , '0')

		cChaveNFE := oXmlHelper:GetValue("_NFEPROC:_PROTNFE:_INFPROT:_CHNFE:Text"   , '0')

		cNF := STRZERO(VAL(cNF),9)

		lError := FS_VALIDIMP(cMarca, cCNPJFor, cNF, cSerie)
		If lError
			Loop
		EndIf

		aCabec   := {}
		aItens   := {}
		aadd(aCabec,{"F1_TIPO"   	,"N"})
		aadd(aCabec,{"F1_FORMUL" 	,"N"})
		aadd(aCabec,{"F1_DOC"    	,cNF})
		aadd(aCabec,{"F1_SERIE"  	,Alltrim(cSerie)})
		aadd(aCabec,{"F1_EMISSAO"	,dEmissao})
		aadd(aCabec,{"F1_FORNECE"	,SA2->A2_COD})
		aadd(aCabec,{"F1_LOJA"   	,SA2->A2_LOJA})
		aadd(aCabec,{"F1_ESPECIE"	,cEspecNF})
		aadd(aCabec,{"F1_COND"		,VE4->VE4_PGTNFP})
		aadd(aCabec,{"F1_EST"		,SA2->A2_EST}) // Alteraçao realizada pois estava gravando incorretamente quando transferencia entre estado - MAQNELSON
		aadd(aCabec,{"F1_SEGURO"  	, Val(nTValSeg) })
		aadd(aCabec,{"F1_FRETE"   	, Val(nTValFre) })
		aadd(aCabec,{"F1_VALICM"	, Val(nTValICM)	})
		aadd(aCabec,{"F1_VALIPI"	, Val(nTValIPI)	})
		aadd(aCabec,{"F1_BRICMS"	, Val(nTBasST)  })
		aadd(aCabec,{"F1_ICMSRET"	, Val(nTValST)  })
		aadd(aCabec,{"F1_RECBMTO"	, dDataBase		})

		cSerNF  := PadR( Alltrim(cSerie) ,TamSX3("D1_SERIE")[1] )
		cCodSA2 := SA2->A2_COD
		cLojSA2 := SA2->A2_LOJA

		cChaveSD1 := xFilial("SD1") + cNF + cSerNF + cCodSA2 + cLojSA2

		aVolumes  := {}
		aItemErro := {}
		If nPecas == 1
			oDet := oXml:_NFEPROC:_NFE:_INFNFE:_DET
			FS_CRIAVIA( nAcao, cMarca )
			FS_ItemErro()
		Else
			for nCntFor2 := 1 to nPecas
				oDet := oXml:_NFEPROC:_NFE:_INFNFE:_DET[nCntFor2]
				FS_CRIAVIA( nAcao, cMarca )
				FS_ItemErro()
			next nCntFor2
		EndIf
		if Len(aItemErro) > 0
			cCadastro := "Itens com problemas"
			oDlgErro := MSDialog():New( aSize[1], aSize[2], aSize[3], aSize[4], cCadastro, , , , nOr( WS_VISIBLE, WS_POPUP ), , , , , .T., , , , .F. )
				oLBErro := TWBrowse():New(1,1,100,100,,,,oDlgErro,,,,,{ || .t. },,,,,,,.F.,,.T.,,.F.,,,)
				oLBErro:AddColumn( TCColumn():New( "Cód.Produto" , { || aItemErro[oLBErro:nAt,1] } ,,,,"LEFT" ,100,.F.,.F.,,,,.F.,) )
				oLBErro:AddColumn( TCColumn():New( "Descrição"   , { || aItemErro[oLBErro:nAt,2] } ,,,,"LEFT" ,200,.F.,.F.,,,,.F.,) )
				oLBErro:AddColumn( TCColumn():New( "Observação"  , { || aItemErro[oLBErro:nAt,3] } ,,,,"LEFT" ,200,.F.,.F.,,,,.F.,) )
				oLBErro:setArray( aItemErro )
				oLBErro:Align := CONTROL_ALIGN_ALLCLIENT
			ACTIVATE MSDIALOG oDlgErro ON INIT EnchoiceBar(oDlgErro,{|| oDlgErro:End() },{|| oDlgErro:End() },,)
			Return .f.
		Endif

		aAdd(aCabec,{"F1_BASEIPI", nTBaseIPI , Nil})  // Carrega o total da base do IPI

		If VVF->(FieldPos("VVF_CHVNFE")) > 0
			aAdd(aCabec,{"F1_CHVNFE" , cChaveNFE   ,Nil})
		endif

		lMsErroAuto := .F.

		MSExecAuto({|x,y,z| MATA140(x,y,z)},aCabec,aItens,3)

		If lMsErroAuto
			MostraErro()
			Return .f.
		else
			// Criação dos Volumes dos Itens
			For nCntFor2 := 1 to len(aVolumes)
				aVetCpos := {}
				aadd(aVetCpos,{ "VCX_DOC"    , cNF })
				aadd(aVetCpos,{ "VCX_SERIE"  , cSerNF })
				aadd(aVetCpos,{ "VCX_FORNEC" , cCodSA2 })
				aadd(aVetCpos,{ "VCX_LOJA"   , cLojSA2 })
				aadd(aVetCpos,{ "VCX_COD"    , aVolumes[nCntFor2,1] })
				aadd(aVetCpos,{ "VCX_ITEM"   , aVolumes[nCntFor2,2] })
				aadd(aVetCpos,{ "VCX_VOLUME" , aVolumes[nCntFor2,3] })
				aadd(aVetCpos,{ "VCX_QTDITE" , aVolumes[nCntFor2,4] })
				OA3200011_Volumes_dos_Itens_da_NF_Entrada( 0 , aVetCpos ) // Incluir Volumes com quantidade dos Itens da NF de Entrada
				If lFuncTempo
					OA3630011_Tempo_Total_Conferencia_Volume_Entrada( 1 , aVolumes[nCntFor2,3] ) // 1=Iniciar o Tempo Total da Conferencia de Volume de Entrada caso não exista o registro
				EndIf
			Next
			If ExistFunc("OA3600011_Tempo_Total_Conferencia_NF_Entrada")
				OA3600011_Tempo_Total_Conferencia_NF_Entrada( 1 , cNF , cSerNF , cCodSA2 , cLojSA2 ) // 1=Iniciar o Tempo Total da Conferencia de NF de Entrada caso não exista o registro
			EndIf
			//
			DBSelectArea("SD1")
			DBSetOrder(1)
			DBSeek(cChaveSD1)
			while xFilial(cChaveSD1) == SD1->D1_FILIAL+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA
				reclock("SD1",.f.)
				SD1->D1_CONBAR := "0"
				msunlock()
				SD1->( dbSkip() )
			enddo
		EndIf

		Conout(" ")
		Conout("======================================================================")
		Conout("IMPXMLSC - Finalizada a importacao: " + cChaveSD1 + " (Filial+NF+Serie+Fornecedor+Loja)")
		Conout("         Tempo de Processamento: " + ElapTime(cTmpArqIni,Time()))
		Conout("======================================================================")

		oProcImpXML:IncRegua2("Executando rotina de Nota Fiscal")

		ALTERA    := .T.
		INCLUI    := .F.
		EXCLUI    := .F.
		VISUALIZA := .F.

		If nAcao == 1 //PRE NOTA
			MSExecAuto({|x,y,z,a,b| MATA140(x,y,z,a,b)},aCabec,aItens,4,,2)
		ElseIf nAcao == 2 //Classifica
			MSExecAuto({|x,y,z,a| MATA103(x,y,z,a)},aCabec,aItens,4,.T.)
		Endif

		lAchou := .T.
		Pergunte(cPerg,.f.)
		if MV_PAR06 == 2 		// mover
			__CopyFile( alltrim(MV_PAR01) + cFile, alltrim(MV_PAR07) + cFile )
			fErase( alltrim(MV_PAR01) + cFile )
		elseif MV_PAR06 == 3	// apagar
			fErase( alltrim(MV_PAR01) + cFile )
		endif
	next

	if lAchou
		MsgInfo("arquivos importados. Tempo de Processamento: " + ElapTime(cTmpTotIni,Time()))
	Else
		MsgInfo("Nenhum arquivo foi importado, verifique!")
	Endif
return .T.


Static Function FS_VALIDIMP(cMarca, cCNPJFor, cNF, cSerie)
	DbSelectArea("VE4")
	DbSetOrder(1)
	If !DbSeek( xFilial("VE4") + cMarca + cCNPJFor) // Busca por marca + CNPJ do fornecedor da nota fiscal
		MsgStop("Não foi possível encontrar o cadastro do fornecedor com CNPJ " + Alltrim(cCNPJFor) +;
			" na rotina Parâmetro Marca (OFIPA980). A operação será abortada. Por favor verifique!","Atenção!")
		Return .t.
	EndIf
	If Empty(VE4->VE4_PGTNFP)
		MsgStop("A condição de pagamento padrão a ser utilizada na importação de pedido de compras está em " +;
			"branco. Por favor, verifique o conteúdo do campo F.Pgto NF Pc (VE4_PGTNFP) da rotina Parâmetro " +;
			"Marca (OFIPA980)!","Atenção!")
		Return .t.
	EndIf

	DBSelectArea("SA2")
	DBSetOrder(3)
	if !DBSeek(xFilial("SA2") + Alltrim(cCNPJFor))
		MsgStop("O Fornecedor com CNPJ " + Alltrim(cCNPJFor) + " não foi encontrado. " +;
			"A Nota Fiscal " + Alltrim(cNF) + " não será importada.")
		Return .t.
	endif
	cQuery := "SELECT SF1.R_E_C_N_O_ RECSF1 " +;
			"  FROM "+RetSQLName("SF1")+" SF1 " +;
			" WHERE SF1.F1_FILIAL = '" + xFilial("SF1") + "'" + ;
			"   AND SF1.F1_DOC = '" + cNF + "'" +;
			"   AND SF1.F1_SERIE = '" + cSerie + "'" +;
			"   AND SF1.F1_FORNECE = '" + SA2->A2_COD + "'" +;
			"   AND SF1.F1_LOJA = '" + SA2->A2_LOJA + "'" +;
			"   AND SF1.D_E_L_E_T_ = ' '"
	If FM_SQL(cQuery) > 0
		MsgStop("Nota Fiscal "+cNF+"-"+cSerie+" já existe e não será importada.")
		Return .t.
	endif
Return .f.


/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    | iXmlSCF    | Autor |  Vinicius Gati        | Data | 29/05/15 |##
##+----------+------------+-------+-----------------------+------+----------+##
##+ Criado para ser usado dentro da pergunte                                +##
##+----------+------------+-------+-----------------------+------+----------+##
###############################################################################
===============================================================================
*/
User Function iXmlSCF( cFinalidade )
local   cTitulo1    := "Selecione uma pasta"
local   cExtens     := "Pasta | *.*"
local   cPasta      := alltrim( iif( empty( cFinalidade ), MV_PAR01, MV_PAR07 ) )
default cFinalidade := ""

	if ! empty( cFinalidade ) .and. MV_PAR06 != 2
		MV_PAR07 := ""
		return .T.
	endif

	if empty( cPasta ) .or. ! existDir( cPasta )
		cPasta := cGetFile(cExtens,cTitulo1,2,,.T.,nOR( GETF_LOCALHARD, GETF_LOCALFLOPPY, GETF_NETWORKDRIVE, GETF_RETDIRECTORY ),.T.)
	endif

	if empty( cFinalidade )
		MV_PAR01  := alltrim( cPasta )
		if ! right( MV_PAR01, 1 ) $ "\/"
			MV_PAR01 += iif( "/" $ MV_PAR01, "/", "\" )
		endif
		aDirImpor := directory( MV_PAR01 + "*.XML" )
	else
		MV_PAR07  := alltrim( cPasta )
		if ! right( MV_PAR07, 1 ) $ "\/"
			MV_PAR07 += iif( "/" $ MV_PAR07, "/", "\" )
		endif
	endif
return .T.


/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    | CriaVIA    | Autor |  ?????????????        | Data | 29/05/15 |##
##+----------+------------+-------+-----------------------+------+----------+##
##+ Criado para ser usado no pergunte                                       +##
##+----------+------------+-------+-----------------------+------+----------+##
###############################################################################
===============================================================================
*/
Static Function FS_CRIAVIA( nAcao, cMarca )
Local cTesE   := ""
Local cPedido := ""
Local cItemPc := ""
Local cInfProd:= ""
Local nPosItens
Local aAuxItens := {}
Local cAliasQry := getNextAlias()

	nBasIPITri := 0
	nPerIPITri := 0
	nValIPITri := 0

	nBasPIS    := 0
	nPerPIS    := 0
	nValPIS    := 0

	nBasCOF    := 0
	nPerCOF    := 0
	nValCOF    := 0

	oXmlDetHlp := Mil_XmlHelper():New(oDet)

	cProduto   := oXmlDetHlp:GetValue('_PROD:_CPROD:Text')
	cDescP     := oXmlDetHlp:GetValue('_PROD:_XPROD:Text')
	cCFOP      := oXmlDetHlp:GetValue('_PROD:_CFOP:Text' )
	cPedFab	   := oXmlDetHlp:GetValue('_PROD:_XPED:Text')
	cPedFab	   += iif( ! empty(cPedFab), cComplPC, "" )
	cItemPed   := oXmlDetHlp:GetValue('_PROD:_NITEMPED:Text')
	nQuant     := Val( oXmlDetHlp:GetValue('_PROD:_QCOM:Text'  , '0') )
	nValUni    := Val( oXmlDetHlp:GetValue('_PROD:_VUNCOM:Text', '0') )
	cSubLin    := ""
	cItem      := ""
	nBasICM    := 0
	nPerICM    := 0
	nValICM    := 0
	nBasICMST  := 0
	nPerICMST  := 0
	nValICMST  := 0
	FS_TrataICM()

//oXmlHelper:GetValue("_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VIPI:Text"   , '0')
	if type("oDET:_Imposto:_IPI") == "O" .and. XmlChildEx(oDET:_Imposto:_IPI, "_IPITRIB" )!= Nil
		nBasIPITri := Val( oXmlDetHlp:GetValue('_IMPOSTO:_IPI:_IPITRIB:_VBC:Text' , '0') )
		nPerIPITri := Val( oXmlDetHlp:GetValue('_IMPOSTO:_IPI:_IPITRIB:_PIPI:Text', '0') )
		nValIPITri := Val( oXmlDetHlp:GetValue('_IMPOSTO:_IPI:_IPITRIB:_VIPI:Text', '0') )
	Endif

	if type("oDET:_Imposto:_PIS") == "O" .and. XmlChildEx(oDET:_Imposto:_PIS, "_PISALIQ" ) != Nil
		nBasPIS    := Val( oXmlDetHlp:GetValue('_IMPOSTO:_PIS:_PISALIQ:_VBC:Text' , '0') )
		nPerPIS    := Val( oXmlDetHlp:GetValue('_IMPOSTO:_PIS:_PISALIQ:_PPIS:Text', '0') )
		nValPIS    := Val( oXmlDetHlp:GetValue('_IMPOSTO:_PIS:_PISALIQ:_VPIS:Text', '0') )
	Endif

	if type("oDET:_Imposto:_COFINS") == "O" .and. XmlChildEx(oDET:_Imposto:_COFINS, "_COFINSALIQ" ) != Nil
		nBasCOF    := Val( oXmlDetHlp:GetValue('_IMPOSTO:_COFINS:_COFINSALIQ:_VBC:Text'    , '0') )
		nPerCOF    := Val( oXmlDetHlp:GetValue('_IMPOSTO:_COFINS:_COFINSALIQ:_PCOFINS:Text', '0') )
		nValCOF    := Val( oXmlDetHlp:GetValue('_IMPOSTO:_COFINS:_COFINSALIQ:_VCOFINS:Text', '0') )
	Endif
	//

	cInfProd := oXmlDetHlp:GetValue('_INFADPROD:Text')

	if ! lError

		cQuery := " SELECT B1_COD, B1_GRUPO, B1_TE , B1_PICMENT, B1_UM, B1_LOCPAD  "
		cQuery += "   FROM "+RetSqlName("SB1") + " SB1 "
		cQuery += "  WHERE B1_FILIAL  = '" + xFilial("SB1")    + "' "
		cQuery += "    AND ( B1_CODFAB = '" + Alltrim(cProduto) + "'"
		cQuery += "		  or B1_CODITE = '" + Alltrim(cProduto) + "'"
		cQuery += "		  or B1_COD    = '" + Alltrim(cProduto) + "' )"
		cQuery += "    AND SB1.D_E_L_E_T_ = ' ' "
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAliasSB , .F., .T. )

		If (cAliasSB)->(Eof())
			AADD(aItemErro,{cProduto,cDescP,"PRODUTO NAO ENCONTRADO"})
		EndIf

		If nAcao == 2
			cTesE := ""
			If !Empty((cAliasSB)->(B1_TE))
				cTesE := (cAliasSB)->(B1_TE)
			ElseIf !Empty(VE4->VE4_TESENT)
				cTesE := VE4->VE4_TESENT
			Else
				cTesE := FM_PRODSBZ((cAliasSB)->(B1_COD),"SB1->B1_TE")
			EndIf
			DbSelectArea("SF4")
			DbSetOrder(1)
			MsSeek( xFilial("SF4") + cTesE )
		EndIf

		cPedido  := ""
		cItemPc  := ""



		cQuery := "select "
		cQuery += " 		C7_NUM, C7_ITEM "
		cQuery += " from "+RetSqlName("SC7")+" SC7 "

		cQuery += " join "+RetSqlName("VEI")+" VEI "
		cQuery += " on    VEI_FILIAL='"+xFilial("VEI")+"'"
		cQuery += " and   VEI_CODMAR='"+cMarca+"'"
		cQuery += " and   VEI_PEDFAB='"+cPedFab+"'"
		cQuery += " and  VEI.D_E_L_E_T_=' '"

		cQuery += " where C7_FILIAL  = '"+xFilial("SC7")+"'"
		cQuery += " and   C7_NUM     = VEI_NUM"
		cQuery += " and   C7_PRODUTO = '"+ (cAliasSB)->(B1_COD) +"'"
		cQuery += " and   C7_QUANT - C7_QUJE - C7_QTDACLA >= " + cValtoChar( nQuant )
		cQuery += " and  SC7.D_E_L_E_T_ = ' '"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAliasQry , .F., .T. )

		if ! (cAliasQry)->( eof() )
			cPedido  := (cAliasQry)->C7_NUM
			cItemPc  := (cAliasQry)->C7_ITEM
		else
			if aScan( aPCs, cPedFab ) == 0
				if ! fwAlertYesNo("O pedido de compra: ["+cPedFab+"] não foi encontrado, continua assim mesmo?")
					AADD(aItemErro,{cProduto,cDescP,"PEDIDO COMPRA "+cPedFab+" NÃO ENCONTRADO"})
				endif
			endif
		endif
		(cAliasQry)->( dbCloseArea() )

		aAdd( aPCs, cPedFab )

		nPosItens := Len(aItens)
		If nPosItens > 0
			cNumIte := aItens[nPosItens,1,2]
		EndIf
		cNumIte := SOMA1(cNumIte)

		aAuxItens := {}
		AADD( aAuxItens , { "D1_ITEM"    , cNumIte                                         , NIL } )
		AADD( aAuxItens , { "D1_COD"     , (cAliasSB)->(B1_COD)                            , NIL } )
		AADD( aAuxItens , { "D1_UM"      , (cAliasSB)->(B1_UM)                             , NIL } )
		If !Empty(cPedido)
			AADD( aAuxItens , { "D1_PEDIDO"  , cPedido                                     , NIL } )
			AADD( aAuxItens , { "D1_ITEMPC"  , cItemPc                                     , NIL } )
		EndIf
		AADD( aAuxItens , { "D1_QUANT"   , nQuant                                          , NIL } )
		AADD( aAuxItens , { "D1_VUNIT"   , nValUni                                         , NIL } )
		AADD( aAuxItens , { "D1_TOTAL"   , nValUni * nQuant                                , NIL } )
		AADD( aAuxItens , { "D1_VALIPI"  , nValIPITri                                      , NIL } )
		AADD( aAuxItens , { "D1_IPI"     , nPerIPITri                                      , NIL } )
		AADD( aAuxItens , { "D1_PICM"    , nPerICM                                         , NIL } )
		AADD( aAuxItens , { "D1_BASEIPI" , Round( ( nValIPITri / ( nPerIPITri/100 ) ) ,2 ) , NIL } )
		AADD( aAuxItens , { "D1_VALICM"  , nValIcm                                         , NIL } )
		If nAcao == 2
			AADD( aAuxItens , { "D1_TES"     , cTesE                                       , NIL } )
		EndIf
		AADD( aAuxItens , { "D1_RATEIO"  , "2"                                             , NIL } )
		AADD( aAuxItens , { "D1_ALIQSOL" , nPerICMST                                       , NIL } )
		AADD( aAuxItens , { "D1_BRICMS"  , nBasICMST                                       , NIL } )
		AADD( aAuxItens , { "D1_ICMSRET" , nValICMST                                       , NIL } )
		AADD( aAuxItens , { "D1_LOCAL"   , (cAliasSB)->B1_LOCPAD                           , NIL } )

		AADD( aItens , aClone(aAuxItens) )

		(cAliasSB)->(DBCloseArea())
	endif
Return .t.


/*
================================================================================
################################################################################
##+----------+-------------+-------+-----------------------+------+----------+##
##|Função    | FS_TrataIcm | Autor | ??????????????        | Data | 29/05/15 |##
##+----------+-------------+-------+-----------------------+------+----------+##
##+ Criado para ser usado no pergunte                                        +##
##+----------+-------------+-------+-----------------------+------+----------+##
################################################################################
================================================================================
*/
Static Function FS_TrataIcm()

	if XmlChildEx(oDET:_Imposto, "_ICMS" )!= Nil

		// Identifica a tag do xml
		SX5->( DbSetOrder(1) )
		SX5->( DbSeek( xFilial("SX5") + "S2" ) )

		Do While !SX5->(Eof()) .And. SX5->X5_FILIAL + SX5->X5_TABELA == xFilial("SX5") + "S2"

			nBasICM    := 0
			nPerICM    := 0
			nValICM    := 0
			nBasICMST  := 0
			nPerICMST  := 0
			nValICMST  := 0

			If XmlChildEx(oDET:_Imposto:_ICMS, "_ICMS"+Alltrim(SX5->X5_CHAVE) )!= Nil

				// ICMS
				If XmlChildEx( &("oDET:_Imposto:_ICMS:_ICMS"+Alltrim(SX5->X5_CHAVE)) , "_VICMS" )!= Nil
					nValICM    := Val( &("oDET:_Imposto:_ICMS:_ICMS"+Alltrim(SX5->X5_CHAVE)+":_VICMS:Text") )
				EndIf
				If XmlChildEx( &("oDET:_Imposto:_ICMS:_ICMS"+Alltrim(SX5->X5_CHAVE)) , "_PICMS" )!= Nil
					nPerICM    :=  Val( &("oDET:_Imposto:_ICMS:_ICMS"+Alltrim(SX5->X5_CHAVE)+":_PICMS:Text") )
				EndIf
				If XmlChildEx( &("oDET:_Imposto:_ICMS:_ICMS"+Alltrim(SX5->X5_CHAVE)) , "_VBC" )!= Nil
					nBasICM    := Val( &("oDET:_Imposto:_ICMS:_ICMS"+Alltrim(SX5->X5_CHAVE)+":_VBC:Text") )
				EndIf

				// ICMS ST
				If Alltrim(SX5->X5_CHAVE) == "10" .OR. Alltrim(SX5->X5_CHAVE) == "30" .OR.  Alltrim(SX5->X5_CHAVE)=="70"  // O conteudo 10/30 considera o ST

					If XmlChildEx( &("oDET:_Imposto:_ICMS:_ICMS"+Alltrim(SX5->X5_CHAVE)) , "_VICMSST" )!= Nil
						nValICMST  :=  Val( &("oDET:_Imposto:_ICMS:_ICMS"+Alltrim(SX5->X5_CHAVE)+":_VICMSST:Text") )
					EndIf

					If XmlChildEx( &("oDET:_Imposto:_ICMS:_ICMS"+Alltrim(SX5->X5_CHAVE)) , "_VBCST" )!= Nil
						nBasICMST  :=  Val( &("oDET:_Imposto:_ICMS:_ICMS"+Alltrim(SX5->X5_CHAVE)+":_VBCST:Text") )
					EndIf

					If XmlChildEx( &("oDET:_Imposto:_ICMS:_ICMS"+Alltrim(SX5->X5_CHAVE)) , "_PMVAST" )!= Nil
						nAlqSB1    := Val( &("oDET:_IMPOSTO:_ICMS:_ICMS"+Alltrim(SX5->X5_CHAVE)+":_PMVAST:Text"))
					EndIf

					If XmlChildEx( &("oDET:_Imposto:_ICMS:_ICMS"+Alltrim(SX5->X5_CHAVE)) , "_MODBCST" )!= Nil
						cModBCST   :=      &("oDET:_IMPOSTO:_ICMS:_ICMS"+Alltrim(SX5->X5_CHAVE)+":_MODBCST:Text")
					EndIf

					If XmlChildEx( &("oDET:_Imposto:_ICMS:_ICMS"+Alltrim(SX5->X5_CHAVE)) , "_PICMSST" )!= Nil
						nPerICMST   := Val(&("oDET:_IMPOSTO:_ICMS:_ICMS"+Alltrim(SX5->X5_CHAVE)+":_PICMSST:Text"))
					EndIf

				EndIf

				Exit

			EndIf

			SX5->(DbSkip())

		EndDo
	Endif
return nil


/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡…o    |FS_TIK      | Autor | Thiago                | Data | 03/09/15 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descricao |Marca listbox.                                                |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function FS_TIK(lMarcar,nOpcao)
	Local ni := 0
	if nOpcao == "1"
		For ni := 1 to Len(aArquivos)
			aArquivos[ni,1] := lMarcar
		Next
	Else
		aArquivos[oLBoxArquivos:nAt,1] := !aArquivos[oLBoxArquivos:nAt,1]
	Endif
	oLBoxArquivos:Refresh()
Return(.t.)


Static Function FS_ItemErro()

	oXmlDetHlp := Mil_XmlHelper():New(oDet)

	cProduto   := oXmlDetHlp:GetValue('_PROD:_CPROD:Text')
	cDescP     := oXmlDetHlp:GetValue('_PROD:_XPROD:Text')

	nPosPedido := aScan(aVetPed,{|x| x[2]+x[8] == Padr(cProduto,len(SC7->C7_PRODUTO))+"usado"})
	if nPosPedido > 0
		cNPedido := aVetPed[nPosPedido,4]
		dbSelectArea("SC7")
		dbSetOrder(4)
		if !dbSeek(xFilial("SC7")+Padr(cProduto,len(SC7->C7_PRODUTO))+cNPedido)
			aAdd( aItemErro, {cProduto,cDescP,"PRODUTO SEM PEDIDO"} )
		Endif
	Endif
Return .t.


/*/{Protheus.doc} ajustaSX1
Por se tratar de RDMake, se não tiver as perguntas eu crio
@author Cristiam Rossi
@since 08/12/2025
@version 1.0
@type function
/*/
static function ajustaSX1()
Local aSX1   	:= {}
Local aEstrut	:= {}
Local nI      	:= 0
Local nJ      	:= 0

aEstrut:= {	"X1_GRUPO"  ,"X1_ORDEM"  ,"X1_PERGUNT","X1_PERSPA","X1_PERENG" ,"X1_VARIAVL","X1_TIPO"   ,"X1_TAMANHO","X1_DECIMAL","X1_PRESEL",;
			"X1_GSC"    ,"X1_VALID"  ,"X1_VAR01"  ,"X1_DEF01" ,"X1_DEFSPA1","X1_DEFENG1","X1_CNT01"  ,"X1_VAR02"  ,"X1_DEF02"  ,"X1_DEFSPA2",;
			"X1_DEFENG2","X1_CNT02"  ,"X1_VAR03" ,"X1_DEF03"  ,"X1_DEFSPA3","X1_DEFENG3","X1_CNT03"  ,"X1_VAR04"  ,"X1_DEF04"  ,"X1_DEFSPA4",;
			"X1_DEFENG4","X1_CNT04"  ,"X1_VAR05" ,"X1_DEF05"  ,"X1_DEFSPA5","X1_DEFENG5","X1_CNT05"  ,"X1_F3"     ,"X1_GRPSXG" ,"X1_PYME","X1_PICTURE"}

    aAdd(aSX1,{ ;
        cPerg , ; // X1_GRUPO
        "01" , ; // X1_ORDEM
        "Arquivos" , ; // X1_PERGUNT
        "Arquivos" , ; // X1_PERSPA
        "Arquivos" , ; // X1_PERENG
        "MV_CH1" , ; // X1_VARIAVL
        "C" , ; // X1_TIPO
        99 , ; // X1_TAMANHO
        0 , ; // X1_DECIMAL
        0 , ; // X1_PRESEL
        "G" , ; // X1_GSC
        "u_iXmlSCF()" , ; // X1_VALID
        "MV_PAR01" , ; // X1_VAR01
        "" , ; // X1_DEF01
        "" , ; // X1_DEFSPA1
        "" , ; // X1_DEFENG1
        "" , ; // X1_CNT01
        "" , ; // X1_VAR02
        "" , ; // X1_DEF02
        "" , ; // X1_DEFSPA2
        "" , ; // X1_DEFENG2
        "" , ; // X1_CNT02
        "" , ; // X1_VAR03
        "" , ; // X1_DEF03
        "" , ; // X1_DEFSPA3
        "" , ; // X1_DEFENG3
        "" , ; // X1_CNT03
        "" , ; // X1_VAR04
        "" , ; // X1_DEF04
        "" , ; // X1_DEFSPA4
        "" , ; // X1_DEFENG4
        "" , ; // X1_CNT04
        "" , ; // X1_VAR05
        "" , ; // X1_DEF05
        "" , ; // X1_DEFSPA5
        "" , ; // X1_DEFENG5
        "" , ; // X1_CNT05
        "" , ; // X1_F3
        "" , ; // X1_GRPSXG
        "" , ; // X1_PYME
        "" ; // X1_PICTURE
    })

    aAdd(aSX1,{ ;
        cPerg , ; // X1_GRUPO
        "02" , ; // X1_ORDEM
        "Marca" , ; // X1_PERGUNT
        "Marca" , ; // X1_PERSPA
        "Marca" , ; // X1_PERENG
        "MV_CH2" , ; // X1_VARIAVL
        "C" , ; // X1_TIPO
        3 , ; // X1_TAMANHO
        0 , ; // X1_DECIMAL
        0 , ; // X1_PRESEL
        "G" , ; // X1_GSC
        "vazio() .or. existCpo('VE1',M->MV_PAR02)" , ; // X1_VALID
        "MV_PAR02" , ; // X1_VAR01
        "" , ; // X1_DEF01
        "" , ; // X1_DEFSPA1
        "" , ; // X1_DEFENG1
        "" , ; // X1_CNT01
        "" , ; // X1_VAR02
        "" , ; // X1_DEF02
        "" , ; // X1_DEFSPA2
        "" , ; // X1_DEFENG2
        "" , ; // X1_CNT02
        "" , ; // X1_VAR03
        "" , ; // X1_DEF03
        "" , ; // X1_DEFSPA3
        "" , ; // X1_DEFENG3
        "" , ; // X1_CNT03
        "" , ; // X1_VAR04
        "" , ; // X1_DEF04
        "" , ; // X1_DEFSPA4
        "" , ; // X1_DEFENG4
        "" , ; // X1_CNT04
        "" , ; // X1_VAR05
        "" , ; // X1_DEF05
        "" , ; // X1_DEFSPA5
        "" , ; // X1_DEFENG5
        "" , ; // X1_CNT05
        "VE1" , ; // X1_F3
        "" , ; // X1_GRPSXG
        "" , ; // X1_PYME
        "" ; // X1_PICTURE
    })

    aAdd(aSX1,{ ;
        cPerg , ; // X1_GRUPO
        "03" , ; // X1_ORDEM
        "Mostra Detalhes" , ; // X1_PERGUNT
        "Mostra Detalhes" , ; // X1_PERSPA
        "Mostra Detalhes" , ; // X1_PERENG
        "MV_CH3" , ; // X1_VARIAVL
        "N" , ; // X1_TIPO
        1 , ; // X1_TAMANHO
        0 , ; // X1_DECIMAL
        0 , ; // X1_PRESEL
        "C" , ; // X1_GSC
        "" , ; // X1_VALID
        "MV_PAR03" , ; // X1_VAR01
        "Sim" , ; // X1_DEF01
        "Sim" , ; // X1_DEFSPA1
        "Sim" , ; // X1_DEFENG1
        "" , ; // X1_CNT01
        "" , ; // X1_VAR02
        "Nao" , ; // X1_DEF02
        "Nao" , ; // X1_DEFSPA2
        "Nao" , ; // X1_DEFENG2
        "" , ; // X1_CNT02
        "" , ; // X1_VAR03
        "" , ; // X1_DEF03
        "" , ; // X1_DEFSPA3
        "" , ; // X1_DEFENG3
        "" , ; // X1_CNT03
        "" , ; // X1_VAR04
        "" , ; // X1_DEF04
        "" , ; // X1_DEFSPA4
        "" , ; // X1_DEFENG4
        "" , ; // X1_CNT04
        "" , ; // X1_VAR05
        "" , ; // X1_DEF05
        "" , ; // X1_DEFSPA5
        "" , ; // X1_DEFENG5
        "" , ; // X1_CNT05
        "" , ; // X1_F3
        "" , ; // X1_GRPSXG
        "" , ; // X1_PYME
        "" ; // X1_PICTURE
    })

    aAdd(aSX1,{ ;
        cPerg , ; // X1_GRUPO
        "04" , ; // X1_ORDEM
        "Especie NF" , ; // X1_PERGUNT
        "Especie NF" , ; // X1_PERSPA
        "Especie NF" , ; // X1_PERENG
        "MV_CH4" , ; // X1_VARIAVL
        "C" , ; // X1_TIPO
        5 , ; // X1_TAMANHO
        0 , ; // X1_DECIMAL
        0 , ; // X1_PRESEL
        "G" , ; // X1_GSC
        "Vazio() .or. ExistCpo('SX5','42'+M->MV_PAR04)" , ; // X1_VALID
        "MV_PAR04" , ; // X1_VAR01
        "" , ; // X1_DEF01
        "" , ; // X1_DEFSPA1
        "" , ; // X1_DEFENG1
        "" , ; // X1_CNT01
        "" , ; // X1_VAR02
        "" , ; // X1_DEF02
        "" , ; // X1_DEFSPA2
        "" , ; // X1_DEFENG2
        "" , ; // X1_CNT02
        "" , ; // X1_VAR03
        "" , ; // X1_DEF03
        "" , ; // X1_DEFSPA3
        "" , ; // X1_DEFENG3
        "" , ; // X1_CNT03
        "" , ; // X1_VAR04
        "" , ; // X1_DEF04
        "" , ; // X1_DEFSPA4
        "" , ; // X1_DEFENG4
        "" , ; // X1_CNT04
        "" , ; // X1_VAR05
        "" , ; // X1_DEF05
        "" , ; // X1_DEFSPA5
        "" , ; // X1_DEFENG5
        "" , ; // X1_CNT05
        "42" , ; // X1_F3
        "" , ; // X1_GRPSXG
        "" , ; // X1_PYME
        "" ; // X1_PICTURE
    })

    aAdd(aSX1,{ ;
        cPerg , ; // X1_GRUPO
        "05" , ; // X1_ORDEM
        "Gerar Doc" , ; // X1_PERGUNT
        "Gerar Doc" , ; // X1_PERSPA
        "Gerar Doc" , ; // X1_PERENG
        "MV_CH5" , ; // X1_VARIAVL
        "N" , ; // X1_TIPO
        1 , ; // X1_TAMANHO
        0 , ; // X1_DECIMAL
        0 , ; // X1_PRESEL
        "C" , ; // X1_GSC
        "" , ; // X1_VALID
        "MV_PAR05" , ; // X1_VAR01
        "Pré-Nota" , ; // X1_DEF01
        "Pré-Nota" , ; // X1_DEFSPA1
        "Pré-Nota" , ; // X1_DEFENG1
        "" , ; // X1_CNT01
        "" , ; // X1_VAR02
        "Classificado" , ; // X1_DEF02
        "Classificado" , ; // X1_DEFSPA2
        "Classificado" , ; // X1_DEFENG2
        "" , ; // X1_CNT02
        "" , ; // X1_VAR03
        "" , ; // X1_DEF03
        "" , ; // X1_DEFSPA3
        "" , ; // X1_DEFENG3
        "" , ; // X1_CNT03
        "" , ; // X1_VAR04
        "" , ; // X1_DEF04
        "" , ; // X1_DEFSPA4
        "" , ; // X1_DEFENG4
        "" , ; // X1_CNT04
        "" , ; // X1_VAR05
        "" , ; // X1_DEF05
        "" , ; // X1_DEFSPA5
        "" , ; // X1_DEFENG5
        "" , ; // X1_CNT05
        "" , ; // X1_F3
        "" , ; // X1_GRPSXG
        "" , ; // X1_PYME
        "" ; // X1_PICTURE
    })

    aAdd(aSX1,{ ;
        cPerg , ; // X1_GRUPO
        "06" , ; // X1_ORDEM
        "Pós processamento" , ; // X1_PERGUNT
        "Pós processamento" , ; // X1_PERSPA
        "Pós processamento" , ; // X1_PERENG
        "MV_CH6" , ; // X1_VARIAVL
        "N" , ; // X1_TIPO
        1 , ; // X1_TAMANHO
        0 , ; // X1_DECIMAL
        0 , ; // X1_PRESEL
        "C" , ; // X1_GSC
        "" , ; // X1_VALID
        "MV_PAR06" , ; // X1_VAR01
        "Nenhuma Ação" , ; // X1_DEF01
        "Nenhuma Ação" , ; // X1_DEFSPA1
        "Nenhuma Ação" , ; // X1_DEFENG1
        "" , ; // X1_CNT01
        "" , ; // X1_VAR02
        "Mover Arquivo" , ; // X1_DEF02
        "Mover Arquivo" , ; // X1_DEFSPA2
        "Mover Arquivo" , ; // X1_DEFENG2
        "" , ; // X1_CNT02
        "" , ; // X1_VAR03
        "Apagar Arquivo" , ; // X1_DEF03
        "Apagar Arquivo" , ; // X1_DEFSPA3
        "Apagar Arquivo" , ; // X1_DEFENG3
        "" , ; // X1_CNT03
        "" , ; // X1_VAR04
        "" , ; // X1_DEF04
        "" , ; // X1_DEFSPA4
        "" , ; // X1_DEFENG4
        "" , ; // X1_CNT04
        "" , ; // X1_VAR05
        "" , ; // X1_DEF05
        "" , ; // X1_DEFSPA5
        "" , ; // X1_DEFENG5
        "" , ; // X1_CNT05
        "" , ; // X1_F3
        "" , ; // X1_GRPSXG
        "" , ; // X1_PYME
        "" ; // X1_PICTURE
    })

    aAdd(aSX1,{ ;
        cPerg , ; // X1_GRUPO
        "07" , ; // X1_ORDEM
        "Pasta Destino" , ; // X1_PERGUNT
        "Pasta Destino" , ; // X1_PERSPA
        "Pasta Destino" , ; // X1_PERENG
        "MV_CH7" , ; // X1_VARIAVL
        "C" , ; // X1_TIPO
        99 , ; // X1_TAMANHO
        0 , ; // X1_DECIMAL
        0 , ; // X1_PRESEL
        "G" , ; // X1_GSC
        "u_iXmlSCF('dest')" , ; // X1_VALID
        "MV_PAR07" , ; // X1_VAR01
        "" , ; // X1_DEF01
        "" , ; // X1_DEFSPA1
        "" , ; // X1_DEFENG1
        "" , ; // X1_CNT01
        "" , ; // X1_VAR02
        "" , ; // X1_DEF02
        "" , ; // X1_DEFSPA2
        "" , ; // X1_DEFENG2
        "" , ; // X1_CNT02
        "" , ; // X1_VAR03
        "" , ; // X1_DEF03
        "" , ; // X1_DEFSPA3
        "" , ; // X1_DEFENG3
        "" , ; // X1_CNT03
        "" , ; // X1_VAR04
        "" , ; // X1_DEF04
        "" , ; // X1_DEFSPA4
        "" , ; // X1_DEFENG4
        "" , ; // X1_CNT04
        "" , ; // X1_VAR05
        "" , ; // X1_DEF05
        "" , ; // X1_DEFSPA5
        "" , ; // X1_DEFENG5
        "" , ; // X1_CNT05
        "" , ; // X1_F3
        "" , ; // X1_GRPSXG
        "" , ; // X1_PYME
        "" ; // X1_PICTURE
    })

	dbSelectArea("SX1")
	dbSetOrder(1)
	For nI := 1 To Len(aSX1)
		If ! Empty(aSX1[nI][1])
			If ! dbSeek(left(aSX1[nI,1]+SPACE(10),LEN(SX1->X1_GRUPO))+aSX1[nI,2])
				RecLock("SX1",.T.)

				For nJ:=1 To Len(aSX1[nI])
					If !Empty(FieldName(FieldPos(aEstrut[nJ]))) .and. aSX1[ni,nj] # NIL
						FieldPut(FieldPos(aEstrut[nJ]),aSX1[nI,nJ])
					EndIf
				Next nJ

				dbCommit()
				MsUnLock()
			EndIf
		EndIf
	next
return nil


/*/{Protheus.doc} getConteudo
Abre o arquivo e retorna seu conteúdo
@author Cristiam Rossi
@since 08/12/2025
@version 1.0
@type function
/*/
static function getConteudo( cFile )
local cConteudo := ""
local oFile     := FWFileReader():New( cFile )
	if oFile:Open()
		cConteudo := oFile:fullRead()
		oFile:Close()
	endif
	freeObj( oFile )
return cConteudo
