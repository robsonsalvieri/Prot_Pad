#INCLUDE "PROTHEUS.CH"
#include 'TOPCONN.ch'
#INCLUDE "ofia537.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} OFIA537
Importacao de Arquivo texto PRI RM

@author		Guilherme Santos
@since		05/09/2025
@version	12.1.2610
/*/
//-------------------------------------------------------------------
Function OFIA537()
	Local cPerg		:= "OFIA537"
	Local lSchedule	:= FWGetRunSchedule()
	Local oLogExec	:= DMS_Logger():New("OFIA537_" + dtos(ddatabase) + "_" + StrTran(Time(), ":", "") + ".LOG") // VQL
	Local oFile     := Nil
	Local lSair     := .F.
	Local lTudoOk   := .F.
	Local aHeader 	:= {}

	Private cIdLog  := ""

	If lSchedule
		
		lTudoOk := OA537008M_VldTudoOk( @oFile , @aHeader, lSchedule  ) 
		
		If lTudoOk
			 
			cIdLog := OA537010M_GrvLog() 

			OA537001L_ProcessaTXT( oLogExec, oFile, aHeader )
		EndIf
	Else
		
		While !lSair .And. !lTudoOk

			lSair := Pergunte(cPerg, .T.) 

			If !lSair .Or. !OA537008M_VldTudoOk( @oFile , @aHeader, lSchedule  ) 

				lSair := If( !lSair, .T., .F. ) 
			Else
				lTudoOk  := .T. 
			EndIf
		End

		If lSair .And. !lTudoOk
			Return
		Else
			cIdLog := OA537010M_GrvLog() 
			FWMsgRun(,{|| OA537001L_ProcessaTXT( oLogExec, oFile, aHeader )}, STR0007, STR0008 + AllTrim(MV_PAR01))  //"Aguarde"		//"Processando arquivo: "
		EndIf

	EndIF

Return NIL
//-------------------------------------------------------------------
/*/{Protheus.doc} OA537001L_ProcessaTXT
Processa a importacao do arquivo texto

@author		Guilherme Santos
@since		11/09/2025
@version	12.1.2610 
/*/
//-------------------------------------------------------------------
Static Function OA537001L_ProcessaTXT( oLogExec, oFile, aHeader ) 
	Local cNomeArq	:= OA537006L_SeparaNomeArq(AllTrim(MV_PAR01))
	Local cLinha 	:= ""
	Local nPosItem	:= 0
	Local nPosDesc	:= 0
	Local nPosQtd	:= 0
	Local nPosPAR03	:= 0
	Local nPosPAR04	:= 0
	Local nPosPAR05	:= 0
	Local nPosPAR06	:= 0 

	Local cItem 	:= ""
	Local cDescri	:= ""
	Local nQtdEmb	:= 0
	Local nVlrCPO03	:= ""
	Local nVlrCPO04	:= ""
	Local nVlrCPO05	:= ""
	Local nVlrCPO06	:= ""
	local aItNoEx 	:= {}
	Local aListGrupo:= OA537004L_ListaGruposSB1() 

	Local cQuery	:= ""

	Local aFilSB5	:= OA537005L_RetornaFiliais("SB5") 
	Local aFilSBZ	:= OA537005L_RetornaFiliais("SBZ")

	Local nFilSB5	:= 0
	Local nFilSBZ	:= 0

	Local cFilBkp	:= cFilAnt

	Local nRetorno	:= 0							 //Retorno da Manipulacao do arquivo texto

	Local lA537GRV	:= ExistBlock("OFA537GR")		//Ponto de Entrada apos a gravacao da Linha
	Local lA537FIM	:= ExistBlock("OFA537FI")		//Ponto de Entrada no final do processamento

	Local nPosCp03	:= SB5->(FieldPos(AllTrim(MV_PAR03)))
	Local nPosCp04	:= SB5->(FieldPos(AllTrim(MV_PAR04)))
	Local nPosCp05	:= SB5->(FieldPos(AllTrim(MV_PAR05)))
	Local nPosCp06	:= SB5->(FieldPos(AllTrim(MV_PAR06)))

	Local lField03	:= nPosCp03 > 0
	Local lField04	:= nPosCp04 > 0
	Local lField05	:= nPosCp05 > 0
	Local lField06	:= nPosCp06 > 0

	Local oStatement := Nil 

	nPosItem	:= aScan(aHeader, {|x| x[01]          == "B5_COD"          .AND. x[02] == "Cod.Item"         })
	nPosDesc	:= aScan(aHeader, {|x| x[01]          == "B5_CEME"         .AND. x[02] == "Descricao_Item"   })
	nPosQtd		:= aScan(aHeader, {|x| x[01]          == "B1_QE"           .AND. x[02] == "Qt.Peca_Emb."     })
	nPosPAR03	:= aScan(aHeader, {|x| AllTrim(x[01]) == AllTrim(MV_PAR03) .AND. x[02] == "P.Dealer_Contrato"})
	nPosPAR04	:= aScan(aHeader, {|x| AllTrim(x[01]) == AllTrim(MV_PAR04) .AND. x[02] == "P.Dealer_Normal"  })
	nPosPAR05	:= aScan(aHeader, {|x| AllTrim(x[01]) == AllTrim(MV_PAR05) .AND. x[02] == "P.Balcao_Contrato"})
	nPosPAR06	:= aScan(aHeader, {|x| AllTrim(x[01]) == AllTrim(MV_PAR06) .AND. x[02] == "P.Balcao_Normal"  })
	
	begin transaction
	
	While ( oFile:hasLine())

		cLinha := oFile:GetLine()

		If Substr(cLinha, 1, 10) == "----------" .OR. Empty(cLinha) 
			Loop
		EndIf

		cItem 		:= DecodeUTF8(Substr( cLinha    , aHeader[nPosItem][03]  , aHeader[nPosItem][04]   )) //SUBS(cLinha, 1, 10)
		cDescri		:= DecodeUTF8(Substr( cLinha    , aHeader[nPosDesc][03]  , aHeader[nPosDesc][04]   )) // SUBS(cLinha, 12, 35) //Descrição do item
		nQtdEmb		:= Val(Substr(cLinha , aHeader[nPosQtd][03]   , aHeader[nPosQtd][04]   )) // SUBC(cLinha, 55, 12)
		nVlrCPO03	:= Val(Substr(cLinha , aHeader[nPosPAR03][03] , aHeader[nPosPAR03][04] )) // val(SUBS(cLinha,217,17))   //PRECO DEALER CONTRATO
		nVlrCPO04	:= Val(Substr(cLinha , aHeader[nPosPAR04][03] , aHeader[nPosPAR04][04] )) // val(SUBS(cLinha,235,17))  //PRECO DEALER NORMAL
		nVlrCPO05	:= Val(Substr(cLinha , aHeader[nPosPAR05][03] , aHeader[nPosPAR05][04] )) // val(SUBS(cLinha,263,17))  //PRECO BALCAO CONTRATO
		nVlrCPO06	:= Val(Substr(cLinha , aHeader[nPosPAR06][03] , aHeader[nPosPAR06][04] )) // val(SUBS(cLinha,235,17))	 //PRECO DEALER NORMAL

		cQuery		:= " SELECT								    " + CRLF
		cQuery		+= " SB1.R_E_C_N_O_ NREGSB1		  			" + CRLF
		cQuery		+= " FROM	" + RetSqlName("SB1") + " SB1 	" + CRLF
		cQuery		+= " WHERE  SB1.B1_FILIAL =   ?				" + CRLF
		cQuery		+= " AND 	SB1.B1_CODITE =   ?			  	" + CRLF
		cQuery		+= " AND	SB1.B1_GRUPO IN ( ? )		    " + CRLF 
		cQuery		+= " AND	SB1.D_E_L_E_T_ =  ?			    " + CRLF

		// Define a consulta e os parâmetros
		oStatement := FWPreparedStatement():New( )
		oStatement:SetQuery(cQuery				 )
		oStatement:SetString( 1 , xFilial("SB1") ) 
		oStatement:SetString( 2 , cItem			 )  
		oStatement:SetIn(     3 , aListGrupo     )
		oStatement:SetString( 4 , ''     		 ) 

		cFinalQuery := oStatement:GetFixQuery()

		TCQUERY cFinalQuery NEW ALIAS "cTabQry" 

		if (cTabQry->NREGSB1) <= 0
			aadd( aItNoEx , {cItem, cDescri} ) 
			cTabQry->(DbCloseArea())
			Loop
		endif

		While !cTabQry->(Eof())

			DbSelectArea("SB1")
			DbSetOrder(1)		//B1_FILIAL, B1_COD  

			SB1->(DbGoTo(cTabQry->NREGSB1))

			For nFilSB5 := 1 to Len(aFilSB5) 

				//Grava somente a SB5 para a Filial atual do SB1 (ou todas se compartilhada)
				If SB1->B1_FILIAL == aFilSB5[nFilSB5][02]

					cFilAnt := aFilSB5[nFilSB5][01]

					DbSelectArea("SB5")
					DbSetOrder(1)		//B5_FILIAL, B5_COD

					If SB5->(DBSeek(xFilial("SB5") + SB1->B1_COD))
						RecLock("SB5", .F.)
					Else
						RecLock("SB5", .T.)
						SB5->B5_FILIAL 	:= xFilial("SB5")
						SB5->B5_COD		:= SB1->B1_COD
						SB5->B5_CEME   	:= cDescri
					EndIf

					If lField03
						SB5->(FieldPut(nPosCp03, nVlrCPO03))
					EndIf

					If lField04
						SB5->(FieldPut(nPosCp04, nVlrCPO04))
					EndIf

					If lField05
						SB5->(FieldPut(nPosCp05, nVlrCPO05))
					EndIf

					If lField06
						SB5->(FieldPut(nPosCp06, nVlrCPO06))
					EndIf

					SB5->(MsUnlock())

					cFilAnt := cFilBkp
				EndIf
			Next nFilSB5

			//Grava Quantidade por Embalagem
			If MV_PAR07 == 1		// 1=Sim ou 2=Nao

				lSB1 := GetNewPar("MV_ARQPROD","") == "SB1"
				lSBZ := GetNewPar("MV_ARQPROD","") == "SBZ"

				If lSB1
				
					RecLock("SB1", .F.)
					SB1->B1_QE := nQtdEmb
					SB1->(MsUnlock())
				
				ElseIf lSBZ 

					For nFilSBZ := 1 to Len(aFilSBZ)
											  
						//Grava somente a SB5 para a Filial atual do SB1 (ou todas se compartilhada)
						If SB1->B1_FILIAL == aFilSBZ[nFilSBZ][02]

							cFilAnt := aFilSBZ[nFilSBZ][01]
										
							DbSelectArea("SBZ")
							DbSetOrder(1)		//BZ_FILIAL, BZ_COD
		  
							If SBZ->(DBSeek(xFilial("SBZ") + SB1->B1_COD))
								RecLock("SBZ", .F.)
							Else
								RecLock("SBZ", .T.)
								SBZ->BZ_FILIAL 	:= xFilial("SBZ")
								SBZ->BZ_COD		:= SB1->B1_COD
								SBZ->BZ_LOCPAD	:= SB1->B1_LOCPAD
							EndIf

							SBZ->BZ_QE := nQtdEmb

							SBZ->(MsUnlock())
		  
							cFilAnt := cFilBkp
						EndIf

					Next nFilSBZ
				EndIf
			EndIf

			cTabQry->(DbSkip()) 
		End

		cTabQry->(DbCloseArea())

		//Chamada do Execblock apos a gravacao da Linha do Arquivo Texto
		If lA537GRV
			ExecBlock("OFA537GR", .F., .F., {cLinha})
		EndIf
	End
	
	end transaction

	oFile:Close()

	if len(aItNoEx) > 0
		OA537010M_GrvLog( {OA537010J_MontaJsonDeItensNaoImportados(aItNoEx)}, cIdLog, 'IMPORT_ERRORS' )
	endif

	Do Case
	Case MV_PAR08 == 2	//Mover Arquivo
		// + "\"
		OA537010M_GrvLog( { STR0012 + AllTrim(MV_PAR09) + "\" + cNomeArq }, cIdLog )  //"Movendo Arquivo processado para a pasta: "

		If File(MV_PAR01)
			If __CopyFile(AllTrim(MV_PAR01), AllTrim(MV_PAR09) + "\" + cNomeArq)
				//Destrava o arquivo em uso
				FT_FUSE()

				//Apaga o arquivo
				nRetorno := FERASE(AllTrim(MV_PAR01))  

				If nRetorno == -1
					
					OA537010M_GrvLog( { STR0014 }, cIdLog )  //"Erro ao apagar o arquivo processado: "
				EndIf
			Else
				
				OA537010M_GrvLog( { STR0015 }, cIdLog )  //"Erro ao copiar o arquivo para a pasta de destino: "  
			EndIf
		EndIf
	Case MV_PAR08 == 3	//Apagar Arquivo
		OA537010M_GrvLog( { STR0013 + AllTrim(MV_PAR01) }, cIdLog )  //"Apagando Arquivo processado: " 

		//Apaga o arquivo
		nRetorno := FERASE(AllTrim(MV_PAR01))

		If nRetorno == -1
			
			OA537010M_GrvLog( { STR0014 + MV_PAR01 }, cIdLog ) 
		EndIf

	EndCase

	OA537010M_GrvLog( {STR0026}, cIdLog )   

	If lA537FIM
		ExecBlock("OFA537FI", .F., .F.)
	EndIf

Return Nil
//-------------------------------------------------------------------
/*/{Protheus.doc} OA537002L_GetPosCab
Retorna um array com os campos e as posicoes no Arquivo texto

@author		Guilherme Santos	
@since		11/09/2025
@version	12.1.2610
/*/
//-------------------------------------------------------------------
Static Function OA537002L_GetPosCab(cLinha)
	Local aHeader	:= {}
	Local nHeader	:= 0
	Local nPosTxt	:= 0
	Local cField	:= ""
	Local nLenFld	:= 0
	local cLinhaBkp := ''

	cLinhaBkp := cLinha

	if ValType(cLinha) == "C" //com o arquivo anexado na issue ele vai virar pra nil essa variável 
		cLinha := noAcento(DecodeUTF8(cLinha))
	endif

	if cLinha == nil .or. empty(cLinha)//se ele chegar como nulo ou como vazio aqui, o decode deu erro, ou seja ele já ta no formato, por isso jogo um bkp e tiro os acentos
		cLinha := cLinhaBkp
		cLinha := noAcento(cLinha)
	endif

	/*
	-------------------------------------------------------------------
		Formato do Array aHeader - Nome da coluna no arquivo
	-------------------------------------------------------------------
		1 - Nome do Campo no Protheus
		2 - Nome do Campo no Arquivo Texto
		3 - Posicao Inicial do Campo no Arquivo Texto
		4 - Tamanho do Campo no Arquivo Texto
	-------------------------------------------------------------------
	*/

	Aadd(aHeader, {"B5_COD", 	"Cod.Item", 			0, 0}) 
	Aadd(aHeader, {"B5_CEME", 	"Descricao_Item", 		0, 0})
	Aadd(aHeader, {"B1_QE", 	"Qt.Peca_Emb.", 		0, 0})
	Aadd(aHeader, {"BZ_QE", 	"Qt.Peca_Emb.", 		0, 0})
	Aadd(aHeader, {MV_PAR03, 	"P.Dealer_Contrato", 	0, 0})
	Aadd(aHeader, {MV_PAR04, 	"P.Dealer_Normal", 		0, 0})
	Aadd(aHeader, {MV_PAR05, 	"P.Balcao_Contrato", 	0, 0})
	Aadd(aHeader, {MV_PAR06, 	"P.Balcao_Normal", 		0, 0})
	
	For nHeader  := 1 to Len(aHeader)
		
		cField	 := aHeader[nHeader][2]
		nPosTxt	 := At(cField, cLinha)

		If nPosTxt <= 0
			If ValType( cLinha ) != "U" .And. ValType( cLinha ) != NIL   
 				
				cAux := cLinha
				
				If ValType( cAux ) == "C"
					nPosTxt := At( cField, cAux )    
				EndIf  	  	   
			EndIf
		EndIf

		if nPosTxt > 0 
			For nLenFld := nPosTxt + Len(cField) to Len(cLinha)   
				If !Empty(Substr(cLinha, nLenFld, 1))
					Exit
				EndIf
			Next nLenFld

			aHeader[nHeader][3] := nPosTxt
			aHeader[nHeader][4] := nLenFld - 1 - nPosTxt
		endif

	Next nHeader

Return aHeader

//-------------------------------------------------------------------
/*/{Protheus.doc} OA537003L_ValidaCab
Valida o Header do Arquivo Texto

@author		Guilherme Santos
@since		11/09/2025
@version	12.1.2610
/*/
//-------------------------------------------------------------------
Static Function OA537003L_ValidaCab(aHeader, cFields)
	Local lRetorno	:= .T.
	Local nHeader	:= 0

	For nHeader := 1 to Len(aHeader)
		If aHeader[nHeader][03] == 0 .OR. aHeader[nHeader][04] == 0
			lRetorno := .F.
			cFields += aHeader[nHeader][02] + "|"
		EndIf
	Next nHeader

Return lRetorno
//-------------------------------------------------------------------
/*/{Protheus.doc} SchedDef
Funcao padrao Scheduler

@author		Guilherme Santos
@since		10/09/2025
@version	12.1.2610
/*/
//-------------------------------------------------------------------
Static Function SchedDef()
	Local aParam	:= {	"P",;
		"OFIA537",;
		"",;
		"",;
		""}
Return aParam
//-------------------------------------------------------------------
/*/{Protheus.doc} OA537004L_ListaGruposSB1
Formação de string utilizada na query

@author		Jessé Augusto
@since		02/10/2025
@version	12.1.2610 
/*/
//-------------------------------------------------------------------
Static Function OA537004L_ListaGruposSB1()

	Local nX  	   := 0
	Local aAux     := {}
	Local aValores := {}

	aValores 		:= StrTokArr( AllTrim(MV_PAR02), "/" ) 

	For nX := 1 To Len( aValores )  
		
		If !Empty( aValores[nX] )  			
			
			aAdd( aAux ,  aValores[nX] ) 
		EndIf 

	Next nX 

Return aAux

//-------------------------------------------------------------------
/*/{Protheus.doc} OA537005L_RetornaFiliais
Retorna as Filiais para gravacao da tabela informada

@author		Guilherme Santos
@since		12/09/2025
@version	12.1.2610
/*/
//-------------------------------------------------------------------
Static Function OA537005L_RetornaFiliais(cTabela)
	Local aRetorno 	:= {}
	Local cFilBkp	:= cFilAnt
	Local nFil		:= 0
	Local oAuxFil	:= DMS_FilialHelper():New()
	Local aFiliais  := oAuxFil:GetAllFilEmpresa(.t.)

	For nFil := 1 to Len(aFiliais)
		cFilAnt := aFiliais[nFil]

		If AScan(aRetorno, {|x| x[02] == xFilial("SB1") .AND. x[03] == xFilial(cTabela)}) == 0
			Aadd(aRetorno, {cFilAnt, xFilial("SB1"), xFilial(cTabela)})
		EndIf
	Next nFil

	cFilAnt := cFilBkp

Return aRetorno
//-------------------------------------------------------------------
/*/{Protheus.doc} OA537VlGrp
Validacao dos Grupos de Produtos informados

@author		Guilherme Santos
@since		17/09/2025
@version	12.1.2610
/*/
//-------------------------------------------------------------------
Function OA537VlGrp()
	Local aGrupos	:= {}
	Local aArea		:= GetArea()
	Local aAreaSBM	:= SBM->(GetArea())
	Local cGrpInv	:= ""
	Local nGrupo	:= 0
	Local lRetorno 	:= .T.

	If !Empty(MV_PAR02)
		aGrupos := StrTokArr(MV_PAR02, "/")

		DbSelectArea("SBM")
		DbSetOrder(1)		//BM_FILIAL, BM_GRUPO

		For nGrupo := 1 to Len(aGrupos)

			If  !Empty(aGrupos[nGrupo]) .And. !SBM->( DBSeek(xFilial("SBM") + aGrupos[nGrupo]) ) 

				cGrpInv += aGrupos[nGrupo] + If(nGrupo < Len(aGrupos), " / ", "")

				lRetorno := .F.
			EndIf

		Next nGrupo

		If !lRetorno

			FMX_HELP( "OA537VlGrp", chr(13)  + chr(10) + STR0006 + cGrpInv, STR0027 ) // "Grupos de Produtos inválidos: " // Informe apenas grupos presente no cadastro
		EndIf
	EndIf

	RestArea(aAreaSBM)
	RestArea(aArea)

Return lRetorno
//-------------------------------------------------------------------
/*/{Protheus.doc} OA537006L_SeparaNomeArq
Separa o Caminho do Nome do Arquivo Texto

@author  Guilherme Santos
@since   17/09/2025
@version 12.1.2610
/*/
//-------------------------------------------------------------------
Static Function OA537006L_SeparaNomeArq(cArquivo)
	Local nI		:= 0
	Local cNomeArq	:= ""

	For nI := Len(cArquivo) to 1 Step -1
		If Substr(cArquivo, nI, 1) == "\" .OR. Substr(cArquivo, nI, 1) == "/"
			Exit
		EndIf
		cNomeArq := Substr(cArquivo, nI, 1) + cNomeArq
	Next nI

Return cNomeArq

//-------------------------------------------------------------------
/*/{Protheus.doc} OA537007M_CheckFileOk
Validação preliminar da estrutura do arquivo
@author		Jessé Augusto
@since		02/10/2025
@version	12.1.2610
/*/
//-------------------------------------------------------------------
Static Function OA537007M_CheckFileOk( oFile, aHeader )

	Local cLinha    := ""
	Local cFields   := ""
	Local cColuna   := "Cod.Item"
	Local nLimite   := 0
	Local lContinue := .F.

	While ( oFile:hasLine() .And. nLimite <= 10 )

		cLinha := oFile:GetLine()

		nPosIt := At( cColuna, cLinha ) ; nLimite++

		If nPosIt <= 0
			Loop
		EndIf

		aHeader   := OA537002L_GetPosCab( cLinha )

		lContinue := OA537003L_ValidaCab( aHeader, @cFields )

		If !lContinue
			
			OA537010M_GrvLog( { STR0005 + cFields } , cIdLog )
		EndIf

		nLimite := 11
	End

Return lContinue

//-------------------------------------------------------------------
/*/{Protheus.doc} OA537008M_VldTudoOk
Validacao geral
@author		Jessé Augusto
@since		02/10/2025
@version	12.1.2610 
/*/
//-------------------------------------------------------------------
Static Function OA537008M_VldTudoOk( oFile, aHeader, lSchedule  )  
	
	Local lSX6   := .F.
	Local cEnter := chr(13)  + chr(10)
																																   
	If Empty( Alltrim(StrTran( MV_PAR02,"/","" )) ) 
		
		If lSchedule
			OA537010M_GrvLog( {STR0018, STR0028},,STR0033 )		 	   // O campo Grupo a Considerar não foi preenchido
		Else 
			OA537010M_GrvLog( {STR0018, STR0028},,STR0033) 	 // O campo Grupo a Considerar não foi preenchido
			FMX_HELP( "OA537008A", cEnter + STR0018, STR0028 ) // O campo Grupo a Considerar não foi preenchido // Informe um ou mais grupo de produto válido
		EndIf 

		Return .F.
	EndIf
	
	lSx6   := FWSX6Util():ExistsParam( "MV_ARQPROD" ) .And. !Empty( GetNewPar( "MV_ARQPROD" ,"") )
						 
	If !lSx6
		
		If lSchedule
			OA537010M_GrvLog( { STR0019, STR0029 },,STR0033 )		  	// O parâmetro MV_ARQPROD não existe ou não está habilitado neste ambiente
		Else 
			OA537010M_GrvLog( { STR0019, STR0029 },,STR0033 )		  	// O parâmetro MV_ARQPROD não existe ou não está habilitado neste ambiente
			FMX_HELP( "OA537008C", cEnter + STR0019, STR0029 )  // O parâmetro MV_ARQPROD não existe ou não está habilitado neste ambiente // Se certifique o parâmetro existe e está preenchido com SB1 ou SBZ
		EndIf 

		Return .F.
	EndIf

	oFile := FWFileReader():New(AllTrim(MV_PAR01)) 

	lOpen := oFile:Open()

	If ( !lOpen .Or. !OA537007M_CheckFileOk( oFile, @aHeader ) )

		If !lOpen
			
			If lSchedule
				OA537010M_GrvLog( { STR0017, STR0030 },,STR0033 )			// Falha na leitura do arquivo
			Else 
				OA537010M_GrvLog( { STR0017, STR0030 },,STR0033 )			// Falha na leitura do arquivo
				FMX_HELP( "OA537008D", cEnter + STR0017, STR0030)   // Falha na leitura do arquivo // Verifique se o arquivo existe e está apto à leitura
			EndIf 
		Else
			If lSchedule
				OA537010M_GrvLog( { STR0005, STR0031 },,STR0033 )		 	// Formato do arquivo inválido. Campos não localizados 
			Else  
				OA537010M_GrvLog( { STR0005, STR0031 },,STR0033 )		 	// Formato do arquivo inválido. Campos não localizados 
				FMX_HELP( "OA537008E", cEnter + STR0005, STR0031 ) 	// Formato do arquivo inválido. Campos não localizados // Use um arquivo que esteja no padrão exigido pela rotina
			EndIf 

			oFile:Close()
		EndIf

		Return .F.
	EndIf

Return .T. 

//-------------------------------------------------------------------
/*/{Protheus.doc} OA537008M_VldTudoOk
Validacao do conteúdo do campo digitado

@author		Jessé Augusto
@since		02/10/2025
@version	12.1.2610
/*/
//-------------------------------------------------------------------
Function OA537009M_VldFldOk(nOpc)

	Local cMascara := ""
	Local xValue   := Upper(Alltrim(&(ReadVar())))
	Local aAux     := {}
	Local nX       :=  0
	Local nErro    :=  0
	Local lTudoOk  := .T.
	Local lMove    := nOpc == 2 

	If ( nOpc == 1 .Or. ( nOpc == 3 ) )

		cMascara := If( !lMove, "*.txt|*.txt", ""  ) 

		If nOpc == 1
			
			If !File( MV_PAR01 ) 

				xValue := MV_PAR01 := cGetFile( cMascara , STR0024, , STR0025, .T., 0, .T., .T. ) 
			EndIf	
			
			lTudoOk := File( MV_PAR01 ) 
		Else
			
			If !ExistDir( MV_PAR09 )
				
				xValue := MV_PAR09 := cGetFile("", STR0024, , STR0025, .T., 128, .T., .T. )  
			EndIf 

			lTudoOk := ExistDir( MV_PAR09 ) 
		EndIf

		Return !Empty(xValue) .And. lTudoOk   
	EndIf

	If nOpc == 2	

		lTudoOk := ExistCPO('SX3', xValue, 2) .And. GetSX3Cache( xValue, "X3_TIPO") != Nil  .And. Left( xValue, 3) == "B5_"

		If !lTudoOk
			Return .F.
		EndIf  		
		
		aAux := { MV_PAR03, MV_PAR04, MV_PAR05, MV_PAR06 }
		
		For nX := 1 To Len( aAux ) 

			nErro += If( Upper(Alltrim( xValue  )) == Upper(Alltrim( aAux[nX] )) , 1, 0 ) 

		Next nX 
 
		If nErro  > 1
			
			FMX_HELP( "OA537009A", chr(13)  + chr(10) + STR0021, STR0032 ) // O campo informado já está em uso // Evite usar um único campo mais de uma vez

			Return .F.
		EndIf
		
	EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} OA537010M_GrvLog
Grava o log dos valores utilizados pelo usuário
@author		Jessé Augusto
@since		02/10/2025
@version	12.1.2610
/*/
//-------------------------------------------------------------------
Static Function OA537010M_GrvLog( aMsg, cId, cTipo ) 

	Local oLogger   := DMS_Logger():New()
	Local jPars     := JSonObject():New()
	Local lSchedule	:= FWGetRunSchedule()
	local cSchedule := ''
	Local aValor    := {}
	Local nX 	    := 0 	

	Default cId   := ""
	Default aMsg  := {}
	default cTipo := ''

	if lSchedule
		cSchedule := "SCHEDULE"
	else
		cSchedule := "MANUAL"
	endif

	jPars["mensagem"] 	   := {} 

	jPars["EMPRESA"]        := cEmpAnt
	jPars["FILIAL"]         := cFilAnt
	jPars["USUARIO"]        := cUserName
	jPars["MODE_EXECUCAO"]  := cSchedule
	jPars["MV_PAR01"]       := Alltrim(MV_PAR01)
	jPars["MV_PAR02"]       := Alltrim(MV_PAR02)
	jPars["MV_PAR03"]       := Alltrim(MV_PAR03)
	jPars["MV_PAR05"]       := Alltrim(MV_PAR05)
	jPars["MV_PAR04"]       := Alltrim(MV_PAR04)
	jPars["MV_PAR06"]       := Alltrim(MV_PAR06)   
	jPars["MV_PAR07"]       := MV_PAR07
	jPars["MV_PAR08"]       := MV_PAR08
	jPars["MV_PAR09"]       := Alltrim(MV_PAR09)
	
	For nX := 1 To Len( aMsg )
		aAdd( jPars["mensagem"], aMsg[nX] ) 
	Next nX 

	aAdd( aValor , {"VQL_AGROUP", "OFIA537"       							  })
	aAdd( aValor , {"VQL_FILORI", xFilial("VQL")  							  })
	aAdd( aValor , {"VQL_DATAI" , dDatabase       							  })
	aAdd( aValor , {"VQL_DATAF" , dDatabase       							  })
	aAdd( aValor , {"VQL_HORAI" , Val( StrTran( Left( Time(), 5), ":", "" ) ) })
	aAdd( aValor , {"VQL_HORAF" , Val( StrTran( Left( Time(), 5), ":", "" ) ) })
	aAdd( aValor , {"VQL_MSGLOG", jPars:ToJSon()  							  })

	If !Empty(cId)

		aAdd( aValor , {"VQL_CODVQL", cId  							  	      })  
	EndIf
	if !Empty(cTipo)
		aadd(aValor, {"VQL_TIPO", cTipo})
	endif

Return oLogger:LogToTable( aValor )

/*/{Protheus.doc} OA537010J_MontaJsonDeItensNaoImportados
	Monta um json com os itens nao importados para o log na VQL
	Já vai retornar a parada como uma string para ser salvo lá (toJson)
	@type  Static Function
	@author Renan Migliaris
	@since 25/11/2025
/*/
Static Function OA537010J_MontaJsonDeItensNaoImportados(aItens)
	local jJson := JSonObject():New()
	local jAuxJson := nil
	local nX := 0

	jJson['notFoundItems'] := {}
 
	for nX := 1 to len(aItens)
		jAuxJson := JSonObject():New()
		jAuxJson["itemCode"] := alltrim(aItens[nx][1])
		jAuxJson["itemDescription"] := alltrim(aItens[nX][2])
		aadd(jJson['notFoundItems'], jAuxJson)
		freeObj(jAuxJson)
	next
Return jJson:ToJSon()
