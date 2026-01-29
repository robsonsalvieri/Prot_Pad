#INCLUDE "TOTVS.CH"
#INCLUDE "QAXA010.CH"
#INCLUDE "REPORT.CH"
 
Static lExQLTMan := NIL

#DEFINE POS_RESP_DIGITACAO    1
#DEFINE POS_RESP_ELABORACAO   2
#DEFINE POS_RESP_REVISAO      3
#DEFINE POS_RESP_APROVACAO    4
#DEFINE POS_RESP_HOMOLOGACAO  5
#DEFINE POS_RESP_DISTRIBUICAO 6
#DEFINE POS_RESP_LEITURA      7
#DEFINE POS_RESP_RESP_DEPTO   8
#DEFINE POS_RESP_DESTINATARIO 9
#DEFINE POS_RESP_AVISO        10

#DEFINE POS_TR_DataDE       1
#DEFINE POS_TR_DataATE      2
#DEFINE POS_TR_DocumentoDE  3
#DEFINE POS_TR_DocumentoATE 4
#DEFINE POS_TR_RevisaoDE    5
#DEFINE POS_TR_RevisaoATE   6

#DEFINE POS_aTpPen_MARCACAO         1
#DEFINE POS_aTpPen_TEM_DOCUMENTO    2
#DEFINE POS_aTpPen_RESPONSABILIDADE 3
#DEFINE POS_aTpPen_TPPEND           4
#DEFINE POS_aTpPen_DESTINATARIO     5

#DEFINE POS_PendDoc_TPPEND          1
#DEFINE POS_PendDoc_DOCTO           2
#DEFINE POS_PendDoc_RV              3
#DEFINE POS_PendDoc_FILIAL_DPTO     2
#DEFINE POS_PendDoc_DEPTO           3
#DEFINE POS_PendDoc_MARK            4
#DEFINE POS_PendDoc_PENDEN1         5
#DEFINE POS_PendDoc_POR_DOC_FIL_MAT 6
#DEFINE POS_PendDoc_RECNO           7
#DEFINE POS_PendDoc_FILIAL          8
//#DEFINE POS_PendDoc_XXXX          9
#DEFINE POS_PendDoc_PENDEN2        10
#DEFINE POS_PendDoc_ALIAS          11
#DEFINE POS_PendDoc_FILMAT         12
#DEFINE POS_PendDoc_MAT            13
#DEFINE POS_PendDoc_DEPMAT         14

#DEFINE POS_Falhas_Legenda 1
#DEFINE POS_Falhas_Docto   2
#DEFINE POS_Falhas_Revisao 3
#DEFINE POS_Falhas_TpPend  4
#DEFINE POS_Falhas_TpDoc   5
#DEFINE POS_Falhas_FilMat  6
#DEFINE POS_Falhas_Mat     7
#DEFINE POS_Falhas_QAANome 8

//Defines para inicialização dos campos do array aDoctos
#DEFINE INI_CAMPO_ADOCTOS_ONO      SPACE(1)
#DEFINE INI_CAMPO_ADOCTOS_OOK      SPACE(1)
#DEFINE INI_CAMPO_ADOCTOS_TIPO_DOC Space(FWSX3Util():GetFieldStruct("QD2_CODTP")[3])
#DEFINE INI_CAMPO_ADOCTOS_DOCUMENT Space(FWSX3Util():GetFieldStruct("QDH_DOCTO")[3])
#DEFINE INI_CAMPO_ADOCTOS_REV_DOCT Space(FWSX3Util():GetFieldStruct("QDH_RV")[3])
#DEFINE INI_CAMPO_ADOCTOS_TIT_DOCT Space(FWSX3Util():GetFieldStruct("QDH_TITULO")[3])
#DEFINE INI_CAMPO_ADOCTOS_MAT_NOME Space(FWSX3Util():GetFieldStruct("QAA_MAT")[3]+FWSX3Util():GetFieldStruct("QAA_NOME")[3])
#DEFINE INI_CAMPO_ADOCTOS_FIL_MAT  Space(FWSX3Util():GetFieldStruct("QAA_FILIAL")[3]+FWSX3Util():GetFieldStruct("QAA_MAT")[3])
#DEFINE INI_CAMPO_ADOCTOS_FIL_PEND Space(FWSX3Util():GetFieldStruct("QD1_FILIAL")[3])
#DEFINE INI_CAMPO_ADOCTOS_TP_PENDE Space(FWSX3Util():GetFieldStruct("QD1_TPPEND")[3])
#DEFINE INI_CAMPO_ADOCTOS_RECNO    Space(8)
#DEFINE INI_CAMPO_ADOCTOS_STATUS   Space(FWSX3Util():GetFieldStruct("QD1_PENDEN")[3])

//Defines de posições dos dados no array aDoctos
#DEFINE POS_ADOCTOS_MARK      1
#DEFINE POS_ADOCTOS_LEGENDA   2
#DEFINE POS_ADOCTOS_TP_DOC    3
#DEFINE POS_ADOCTOS_COD_DOC   4
#DEFINE POS_ADOCTOS_COD_DOC_P 5
#DEFINE POS_ADOCTOS_REV_DOC   5
#DEFINE POS_ADOCTOS_REV_DOC_P 4
#DEFINE POS_ADOCTOS_TIT_DOC   6
#DEFINE POS_ADOCTOS_MAT_NOM   7
#DEFINE POS_ADOCTOS_FIL_MAT   8
#DEFINE POS_ADOCTOS_FIL_PEN   9
#DEFINE POS_ADOCTOS_TIP_PEN   10
#DEFINE POS_ADOCTOS_RECNO     11
#DEFINE POS_ADOCTOS_STATUS    12


/*/{Protheus.doc} QAXA010AuxClass
Classe agrupadora de métodos auxiliares do QAXA010
@author rafael.kleestadt
@since 07/03/2023
@version 1.0
/*/
CLASS QAXA010AuxClass FROM LongNameClass

    METHOD new() Constructor

	//Transferir Responsabilidade
	METHOD montaPainelDocumentosPastasAvisos()
	METHOD montaPainelLegendasTiposDePendencias()
	Method montaPainelOpcoes(oPanOpcao, lEdicao)
	METHOD montaPainelTiposDePendencias()
	METHOD montaPainelUsuariosDestino()
	METHOD montaTelaTransferenciaResponsabilidade()

	//Transferir Departamento
	METHOD montaTelaTransferenciaDepartamento()

	//Demais Auxiliares
	METHOD acaoMudancaRadioResponsabilidades()
	METHOD acaoTrocaDeLinhaDocumentos()
	METHOD acaoTrocaDeLinhaTipoPendencia()
	METHOD atualizaPonteiroUsuario(oUsuarios, cChave)
	METHOD carregaAvisosEmTela(lPosAv, oDoctos, aDoctos, oAvisos, aAvisos, aAviAux, nItem4)
	METHOD carregaDocumentosEmTela(oDoctos, aDoctos, aPenDoc, aTpPen, nPosTp, nItem4, lCarrega, lTpPen, aAvisos, oAvisos, aAviAux)
	METHOD carregaPendenciasBaixadasOuNao(aTpPen, aPenDoc, aDoctos, nItem4, oDoctos, aAvisos, oAvisos, aAviAux, lPergunta)
	METHOD carregaTransferenciasEMatriculaAtual(lRet, lPorDepart)
	METHOD checaPermissaoTransferenciaUsuario()
	METHOD duploCliqueDocumento()
	METHOD duploCliqueTipoPendencia()
	METHOD marcaResponsabilidade(nItem, lMarkAtu, lAtuDocs, lAtuPends)
	METHOD marcaTodasResponsabilidades()
	METHOD marcaTodosDocumentosDaResponsabilidade(nItem, lMarkAtu, lAtuDocs, lAtuPends)
	METHOD pendenciaPreenchidaPorDocumento()
	METHOD posicionarUsuarioDestino(cTexto, cOrdem, nOpc)
	METHOD processaFechamentoTransferencia(nOpcao)
    METHOD responsabilidadeQD0ExisteNasPendenciasQD1()
	METHOD retornaAvisos(lAvisoPosicionado, oDocumentos, aDocumentos, aAvisos, aRetAvisos, cChave)
	METHOD retornaBLineTipoPendencia()
	METHOD retornaUsuarioENomeDestinatario(cDestPorResp, cDestPorDoc)
	METHOD validaSeOUsuarioEDistribuidorDeAlgumDocumento()
	METHOD validaSeOUsuarioEOUnicoDistribuidorDeAlgumDocumento(cAliasQDZ)
    METHOD verificaSeUsuariosPossuemPendenciasDeDevolucaoDeRevisaoAnterior(aDoctos, cFilAtu, cMatAtu, cFilDest, cMatDest)
	METHOD vinculaDocumento()
	METHOD vinculaResponsabilidade()
	METHOD vinculaTodasResponsabilidades(nItem2,oItem2,aTpPen,oTpPen,cFilAtu,cMatAtu,aDoctos,aAvisos)
	METHOD vinculaUsuario(lPorDocto, aDoctos, oDoctos, aPenDoc, oTpPen, aTpPen, cFilAtu, cMatAtu, aAvisos)
	METHOD vinculaUsuarioUnico()

ENDCLASS

/*/{Protheus.doc} new
Construtor da Classe
@author rafael.kleestadt
@since 09/03/2023
@version 1.0
@param param_name, param_type, param_descr
@return return_var, return_type, return_description
/*/
METHOD new() CLASS QAXA010AuxClass
Return Self

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³QAXA010   ³ Autor ³Aldo Marini Junior     ³ Data ³ 13/05/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Cadastro de Responsaveis                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³QAXA010()                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³Siga Quality ( Generico )                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Eduardo S.  ³25/03/02³ META ³ Otimizacao, Melhoria e Alteracao na utili³±±
±±³            ³        ³      ³ zacao dos arquivos de Usuarios/Centro C./³±±
±±³            ³        ³      ³ Transf. conforme novo Conceito Quality.  ³±±
±±³Eduardo S.  ³22/05/02³      ³ Acertado para transf. corretamente os des³±±
±±³            ³        ³      ³ tinatarios do Docto.                     ³±±
±±³Eduardo S.  ³01/07/02³      ³ Acerto para transferir tambem doctos bai-³±±
±±³            ³        ³      ³ xados e vigentes.                        ³±±
±±³Eduardo S.  ³16/07/02³      ³ Incluido o campo QAA_TPUSR defindo o tipo³±±
±±³            ³        ³      ³ do Usuario, permitindo somente a inclusao³±±
±±³            ³        ³      ³ do Tipo Outros qdo integrado com SIGAGPE.³±±
±±³Aldo Marini ³01/08/02³      ³ Transf. das funcoes QX10VldEmp() e       ³±±
±±³            ³        ³      ³ QA010VRCFG()para o fonte QAXFUN.PRW      ³±±
±±³Eduardo S.  ³05/09/02³ ---- ³ Acerto para validar exclusao de usuarios ³±±
±±³            ³        ³      ³ do tipo funcionario qdo integrado SIGAGPE³±±
±±³Eduardo S.  ³07/01/03³ ---- ³ Acerto para transferir corretamente os   ³±±
±±³            ³        ³      ³ destinatarios dos doctos em elaboracao.  ³±±
±±³Eduardo S.  ³11/02/03³062340³ Acerto para permitir somente a transf. de³±±
±±³            ³        ³      ³ Doctos em etapa Leitura Qdo selecionado  ³±±
±±³            ³        ³      ³ Transf. e Baixar / Baixar s/ Transf.     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function MenuDef()

	Local aRotina   := {}

	Private lIntLox   := GetMv("MV_QALOGIX") == "1"

	aAdd(aRotina, {OemToAnsi(STR0001),"AxPesqui"  , 0 , 1,,.F.}) // "Pesquisar"
	aAdd(aRotina, {OemToAnsi(STR0002),"QA010Telas", 0 , 2}     ) // "Visualizar"

	If !lIntLox
		aAdd(aRotina, {OemToAnsi(STR0003),"QA010Telas", 0 , 3} ) // "Incluir" 
	EndIf

	aAdd(aRotina, {OemToAnsi(STR0004),"QA010Telas", 0 , 4}     ) // "Alterar"

	If !lIntLox
		aAdd(aRotina, {OemToAnsi(STR0006),"QA010Telas", 0 , 5} ) // "Excluir"
	EndIf

	aAdd(aRotina, {OemToAnsi(STR0047),"QAXA010Vrf", 0 , 6,,.F.}) // "Mostrar Inativo"
	aAdd(aRotina, {OemToAnsi(STR0181),"QAXA010TRR", 0 , 6}     ) // "Transferir Responsabilidade"
	aAdd(aRotina, {OemToAnsi(STR0182),"QAXA010TRD", 0 , 6}     ) // "Transferir Departamento"
	aAdd(aRotina, {OemToAnsi(STR0100),"QAXA010Leg", 0 , 6,,.F.}) // "Legenda"
	aAdd(aRotina, {OemToAnsi(STR0153),"MsDocument", 0 , 4}     ) // "Conhecimento"

Return aRotina

Function QAXA010()

	Private aFltDoc   := {}
	Private aRotina   := MenuDef()
	Private cCadastro := OemtoAnsi(STR0007) // "Responsáveis/Usuários"
	Private cFilQAD   := If(Alltrim(FWModeAccess("QAD"))=="C",FWFILIAL("QAD"),QAA->QAA_FILIAL) // mudado para private pois combinado com cursorarrow
	Private lIntGPE   := If(GetMv("MV_QGINT") == "S",.T.,.F.)
	Private lUsrInat  := .F.
	Private lVldPer   := .F. // Valida se a tela de filtro foi preenchida ou não(Tras todos os registros de Doctos)		 
	Private nCallInat := 0
	Private oCinza    := LoadBitmap( GetResources(), "BR_CINZA"   ) // Sem pendência
	Private oLaranja  := LoadBitmap( GetResources(), "BR_LARANJA" ) // Sem usuário selecionado
	Private oVerde    := LoadBitmap( GetResources(), "BR_VERDE"   ) // Usuário selecionado

	// Causa lentidão.
	DbSelectArea("QAA")
	DbSetOrder(1)

	oBrowse := FWmBrowse():New()
	oBrowse:SetAlias( 'QAA' )
	oBrowse:SetDescription( cCadastro )  
	oBrowse:AddLegend( "Qaxa010Vld(1) == 1", 'ENABLE'    , "Verde - Normal,sem nenhum lacto de pendencia")		 //Verde - Normal,sem nenhum lacto de pendencia
	oBrowse:AddLegend( "Qaxa010Vld(2) == 2", 'DISABLE'   , "Vermelho - Demitido, sem nenhum lacto de pendencia") // Vermelho - Demitido, sem nenhum lacto de pendencia
	oBrowse:AddLegend( "Qaxa010Vld(3) == 3", 'BR_AMARELO', "Amarelo - Normal,com lacto de pendencia")  			 // Amarelo - Normal,com lacto de pendencia
	oBrowse:AddLegend( "Qaxa010Vld(4) == 4", 'BR_AZUL'   , "Azul - Transferido,com lacto de pendencia")  	     // Azul - Transferido,com lacto de pendencia
	oBrowse:AddLegend( "Qaxa010Vld(5) == 5", 'BR_PRETO'  , "Preta - Demitido, com lacto de pendencia")  	     // Preta - Demitido, com lacto de pendencia
	oBrowse:SetFilterDefault( "QAA->QAA_STATUS == '1' .AND. QAA->QAA_FIM == ' '" )                               // Filtra Usuarios Inativos

	DbselectArea("QAA")
	QAA->(DbSetOrder(1))
	DbSeek(xFilial("QAA"))                                                                     
	oBrowse:Activate()

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QA010Telas³ Autor ³ Eduardo de Souza      ³ Data ³ 22/03/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Tela Cadastro de Usuarios                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QA010Telas(ExpC1,ExpN1,ExpN2)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Alias do arquivo                                   ³±±
±±³          ³ ExpN1 - Numero do registro                                 ³±±
±±³          ³ ExpN2 - Numero da opcao selecionada                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QAXA010 - Siga Quality (Generico)                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QA010Telas(cAlias,nReg,nOpc)

	Local aMsSize   := MsAdvSize()
    Local cChaveMat := AllTrim(SubStr(QAA->QAA_MAT, Len(cEmpAnt)+1, TAMSX3("QAA_MAT")[1])) // Da posição do tamanho da empresa + 1 até o tamanho do código do usuário
	Local cEmpReg   := SubStr(QAA->QAA_MAT, 1, Len(cEmpAnt)) // Da primeira posição até o tamanho da empresa
    Local cFilReg   := SubStr(QAA->QAA_MAT, Len(cEmpAnt)+1, FWSizeFilial()) // Da posição do tamanho da empresa + 1 até o tamanho da filial
	Local lAchouSRA := .F.
	Local lIntLox   := GetMv("MV_QALOGIX") == "1"
	Local nOpcao    := 0
	Local nRetorno  := 0
	Local nSaveSx8  := GetSX8Len()
	Local oDlg      := Nil
	Local oEnchoice := Nil

	Private aGETS[0]
	Private aTELA[0][0]
	Private bCampo  := {|nCPO| Field( nCPO ) }
	Private lAltUsr := .F.

	If lIntLox
		nOpc := 4
	Endif

	DbSelectArea("QAA")
	DbSetOrder(1)

	RegToMemory("QAA", nOpc = 3)

	If nOpc == 3
		M->QAA_FILIAL:= xFilial("QAA")    	
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Variavel utilizada para bloquear os campos que nao podem ser alterados. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lIntGPE .And. (INCLUI .Or. M->QAA_TPUSR == "1")
		lAltUsr:= .T.
	EndIf

	DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0007) FROM 000,000 To aMsSize[6]-40,aMsSize[5]-350  OF oMainWnd PIXEL

	oDlg:lMaximized := .T.

	oEnchoice := Msmget():New("QAA",nReg,nOpc,,,,,{001,001,oDlg:nClientHeight,oDlg:nClientWidth * 0.60})

	oEnchoice:oBox:Align := CONTROL_ALIGN_ALLCLIENT

	If nOpc == 2 .Or. nOpc == 5
		ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpcao:= 1,oDlg:End() },{|| oDlg:End()}) CENTERED	
	ElseIf nOpc == 3 .Or. nOpc == 4
		ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| If(QAX010TOK(nOpc),(nOpcao:= 1,oDlg:End()),)},{|| oDlg:End()}) CENTERED	
	EndIf


	If nOpc <> 2
		If nOpcao == 1				// Ok
			If nOpc == 3 .Or. nOpc == 4
				QAX010GUsr(nOpc)	//Grava Usuario
				While (GetSX8Len() > nSaveSx8)
					ConfirmSX8()		
				Enddo

			ElseIf nOpc == 5

				If !lIntGpe .Or. M->QAA_TPUSR <> "1"
					QAX010Dele() //Exclui Usuario

				ElseIf lIntGpe .And. M->QAA_TPUSR == "1"

					// Verifica se o usuário(QAA) existe na SRA(Gestão de Pessoal)
					If cEmpReg+cFilReg <> cEmpAnt+cFilAnt
						nRetorno := StartJob("LOCALIZSRA", GetEnvServer(), .T.,cEmpReg, cFilReg, cChaveMat, cModulo)
						
						If nRetorno == 0 // Se a tabela SRA NÃO foi localizada ou ocorreu falha na abertura do ambiente 
							// STR0126 - "Não foi possível encontrar o arquivo: " + "SRA"
							Help(NIL, NIL, cEmpReg+cFilReg, NIL, STR0126+"SRA", 1, 0, NIL, NIL, NIL, NIL, NIL, {""})
							Return .F.

						ElseIf nRetorno == 1 // Se o usuário existir na SRA, não exclui o usuário do QAA
							lAchouSRA := .T.
						Endif
					Else
						dbSelectArea("SRA")
						dbSetOrder(1) // Filial + Matrícula
						If SRA->(dbSeek(cChaveMat))
							lAchouSRA := .T.
						Endif
					Endif
					
					If !lAchouSRA
						QAX010Dele() 			//Exclui Usuario
					Else
						Help(" ",1,"QX10EXGPE")	// "O Usuario somente podera ser excluido pelo modulo Gestao de Pessoal."
					Endif
				Else
					Help(" ",1,"QX10EXGPE") 	// "O Usuario somente podera ser excluido pelo modulo Gestao de Pessoal."
				EndIf
			EndIf
		Else
			While (GetSX8Len() > nSaveSx8)
				RollBackSX8()
			Enddo
		EndIf
	Endif

	If nOpc == 3
		Qaxa010Fil()
	EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QAX010GUsr³ Autor ³ Eduardo de Souza      ³ Data ³ 22/03/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Grava Usuarios                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QAX010GUsr(ExpN1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 - Opcao do Browse                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QAXA010 - Siga Quality (Generico)                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QAX010GUsr(nOpc)

	Local lRecLock:= .F.
	Local nI      := 0

	If nOpc == 3
		lRecLock:= .T.
	EndIf

	Begin Transaction

		DbSelectArea("QAA")
		If nOpc == 4 .And. QAA->QAA_MAT <> M->QAA_MAT
			QAA->(dbSetOrder(1))
			QAA->(dbSeek(xFilial('QAA')+M->QAA_MAT))
		EndIf

	If valAltFunc()==.T.
	EndIf

	M->QAA_LOGIN:= UPPER(M->QAA_LOGIN)
	RecLock("QAA",lRecLock)
		For nI := 1 TO FCount()
			FieldPut(nI,M->&(Eval(bCampo,nI)))
		Next nI
	MsUnLock()      
	FKCOMMIT()

	End Transaction

	If ExistBlock("QAX010OK")
		ExecBlock("QAX010OK",.F.,.F.,{nOpc})
	EndIf
	

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³ QAX010Dele ³ Autor ³ Eduardo de Souza    ³ Data ³ 22/03/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Exclusao de registros do Cadastro de Usuarios              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QAX010Dele()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QAXA010 - Siga Quality (Generico)                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QAX010Dele()

	Local lRet := .F.

	MsgRun(OemToAnsi(STR0114),OemToAnsi(STR0009),{|| lRet:= QAAValExc() }) // "Validando Exclusao de Usuarios..." ### "Aguarde..."	
	If lRet
		Begin Transaction
			If RecLock("QAA",.F.)
				QAA->(DbDelete())
				QAA->(MsUnlock())
				QAA->(FKCOMMIT())
				QAA->(DbSkip())
			Endif
		End Transaction
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Exclui a amarracao com os conhecimentos                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		MsDocument( Alias(), RecNo(), 2, , 3 ) 
	EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³ Qaxa010Fil³ Autor ³Aldo Marini Junior    ³ Data ³ 06/07/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Filtra os Usuarios/Responsaveis Inativos                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Qaxa010Fil()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QAXA010 - Siga Quality (Generico)                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/                      
Function Qaxa010Fil()

	Local cFiltro    := Qa_FilSitF() // "Filtra Ativo"

	DEFAULT lUsrInat := .F.

	DbSelectArea("QAA")
	Set Filter to &(cFiltro)
	If FwIsInCallStack("QAXA010") .And. lUsrInat
		DbClearFilter()
		oBrowse:SetFilterDefault( ".T." )
	Else
		oBrowse:SetFilterDefault( "QAA->QAA_STATUS == '1' .AND. QAA->QAA_FIM == ' '" )
		oBrowse:Refresh()
	EndIf

	DbSeek(xFilial("QAA"))

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³Qaxa010Vld ³ Autor ³Aldo Marini Junior    ³ Data ³ 13/05/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Retorna o numero da opcao correspondente a cor da situacao ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Qaxa010Vld(ExpN1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 - Situacao do Registro                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QAXA010 - Siga Quality (Generico)                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/                      
Function Qaxa010Vld(nOpcQAB)

	Local nRet   	:= nOpcQAB
	Local cFilQAD	:= If(Alltrim(FWModeAccess("QAD"))=="C",FWFILIAL("QAD"),QAA->QAA_FILIAL) //Empty(xFilial("QAD")
	Local lAtivo    := QA_SitFolh()
	Local aBuscaTra := {}
	Local aRecTra	:= {}
	Local cFilTra	:= Space(FWSizeFilial())
	Local cMatTra   := ''
	Local cDepTra   := ''
	Local nTra		:= 1

	//1 Verde   - Normal,sem nenhum lacto de pendencia
	//2 Vermelho- Demitido, sem nenhum lacto de pendencia
	//3 Amarelo - Normal,com lacto de pendencia
	//4 Azul 	- Transferido,com lacto de pendencia
	//5 Preta 	- Demitido, com lacto de pendencia

	If nOpcQAB = 1 .And. ! lAtivo
	Return 0
	ElseIf nOpcQAB = 2 .And. lAtivo
	Return 0
	ElseIf nOpcQAB = 3 .And. ! lAtivo
	Return 0
	ElseIf nOpcQAB = 4 .And. ! lAtivo
	Return 0
	ElseIf nOpcQAB = 5 .And. lAtivo
	Return 0
	Endif

	QD1->(DbSetOrder(3))
	QAB->(DbSetOrder(2))
	QAD->(DbSetOrder(2))

	DO CASE
	CASE nOpcQAB == 1 .Or. nOpcQAB == 3		//1 Verde - Normal,sem nenhum lacto de pendencia
											//3 Amarelo - Normal,com lacto de pendencia
		
		If QD1->(DbSeek(QAA->QAA_FILIAL+QAA->QAA_MAT+"P"))
			If QAA->QAA_CC == QD1->QD1_DEPTO
				If nOpcQAB == 1
					nRet:= 0
				Endif
			Endif
		Else
			If nOpcQAB == 3
				nRet:= 0
			Endif
		Endif
	CASE nOpcQAB == 2 .Or. nOpcQAB == 5 	//2 Vermelho- Demitido, sem nenhum lacto de pendencia
											//5 Preta 	- Demitido, com lacto de pendencia
		If QD1->(DbSeek(QAA->QAA_FILIAL+QAA->QAA_MAT+"P"))
			If nOpcQAB == 2
				nRet:= 0
			Endif
		Else
			If nOpcQAB == 5
				nRet:= 0
				If QAD->(DbSeek(cFilQAD+QAA->QAA_MAT))
					nRet := 5
				Endif
			Endif
		Endif
		
	CASE nOpcQAB == 4  //4 Azul 	- Transferido,com lacto de pendencia
		
		cFilTra :=	QAA->QAA_FILIAL
		cMatTra :=	QAA->QAA_MAT
		cDepTra :=	QAA->QAA_CC
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Carrega os Lactos de Transferencia e Matricula atual         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If QAB->(DbSeek(cFilTra+cMatTra))
			While QAB->(!Eof()) .And. QAB->QAB_FILP+QAB->QAB_MATP == cFilTra+cMatTra
				If Ascan(aRecTra,QAB->(Recno())) > 0
					QAB->(DbSkip())
					Loop
				Else
					Aadd(aRecTra,QAB->(Recno()))
				Endif
				If QAB->QAB_FILP+QAB->QAB_MATP == cFilTra+cMatTra
					If QAB->QAB_FILP+QAB->QAB_MATP+QAB->QAB_CCP <> QAB->QAB_FILD+QAB->QAB_MATD+QAB->QAB_CCD
						If Ascan(aBuscaTra,{|X| X[1]+X[2]+X[3] == QAB->QAB_FILD+QAB->QAB_MATD+QAB->QAB_CCD}) == 0
							IF QAB->QAB_FILD+QAB->QAB_MATD+QAB->QAB_CCD <> QAA->QAA_FILIAL+QAA->QAA_MAT+QAA->QAA_CC
								Aadd(aBuscaTra,{QAB->QAB_FILD,QAB->QAB_MATD,QAB->QAB_CCD})
							Endif
						Endif
					EndIf
				Else
					QAB->(DbSkip())
				EndIf
			EndDo
		EndIf
		
		nRet:= 0
		For nTra:=1 To Len(aBuscaTra)
			If QD1->(DbSeek(aBuscaTra[nTra,1]+aBuscaTra[nTra,2]+"P"))
				While QD1->(!Eof()) .And. aBuscaTra[nTra,1]+aBuscaTra[nTra,2]+"P" == QD1->QD1_FILMAT+QD1->QD1_MAT+QD1->QD1_PENDEN
					If QD1->QD1_SIT == "I" .OR. (aBuscaTra[nTra,3] <> QD1->QD1_DEPTO)
						QD1->(DbSkip())
						Loop
					Else
						nRet:= 4
					Endif
					QD1->(DbSkip())
				Enddo
			Endif
		Next
	EndCASE

	QD1->(DbSetOrder(1))
	QAB->(DbSetOrder(1))
	QAD->(DbSetOrder(1))

Return nRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³Qaxa010Vrf³ Autor ³Aldo Marini Junior     ³ Data ³ 13/05/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Filtra aleatoriamente funcionarios Inativos e/ou Normais   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Qaxa010Vrf()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QAXA010 - Siga Quality (Generico)                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/                      
Function Qaxa010Vrf()

	Default lUsrInat := .F.

	nCallInat ++

	If !lUsrInat .And. nCallInat % 2 != 0
		lUsrInat := .T.
	Else
		lUsrInat := .F.
	Endif

	MsgRun(OemToAnsi(STR0008),OemToAnsi(STR0009),{ || Qaxa010Fil() } ) //"Selecionando Usuários" ### "Aguarde..."

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FQAXA010Grv ³ Autor ³ Aldo Marini Junior  ³ Data ³ 21.05.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Carrega os Lactos de Transferencia                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FQAXA010     (aTpPen,aPenDoc,aDoctos,nItem4)               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aPenDoc  = Array contendo os Lactos das Pendencias         ³±±
±±³          ³ aTpPen   = Array contendo os Tp.Pendencias selecionadas    ³±±
±±³          ³ cCcFilial= Caracter contendo filial destino                ³±±
±±³          ³ cCcMatr  = Caracter contendo Matricula destino             ³±±
±±³          ³ cCcPara  = Caracter contendo C.Custo destino               ³±±
±±³          ³ lChk03   = DESUSO                                          ³±±
±±³          ³ lChk04   = Logico indicando se Gera Revisao qdo Responsav. ³±±
±±³          ³ nItem2   = Numero indicando opcao (Todas Pend./Selec.Pend.)³±±
±±³          ³ nItem3   = Numero indicando opcao (Fil.C.Custo/Pendencias) ³±±
±±³          ³ nItem4   = Numero indicando opcao (Ambas/Baixadas/Pendente)³±±
±±³          ³ nItem5   = Numero indicando opcao de Transferencias        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function FQAXA010Grv(aPenDoc,aTpPen,cCcFilial,cCcMatr,cCcPara,lChk03,lChk04,nItem2,nItem3,nItem4,nItem5)

	Local aAreaQD0BKP := {}
	Local aAvPos      := 0
	Local aQD0Tran    := {}
	Local aQD0TranQD1 := {}
	Local aQDGTran    := {}
	Local cCampo      := ""
	Local cCcAtu      := Space(TAMSX3("QAA_CC")[1])
	Local cCcCargo    := Space(TAMSX3("QAA_CODFUN")[1])
	Local cCcFilAtu   := Space(FWSizeFilial()) //Space(2)
	Local cCcMatAtu   := Space(TAMSX3("QAA_MAT")[1])
	Local cChkFil     := Space(FWSizeFilial()) //Space(2)
	Local cChkMat     := Space(TAMSX3("QAA_MAT")[1])
	Local cChkTpPnd   := Space(3)
	Local cDepBsc     := Space(TAMSX3("QAA_CC")[1])
	Local cDepOrig    := Nil
	Local cFilBsc     := Space(FWSizeFilial()) //Space(2)
	Local cFilOrig    := Nil
	Local cMatBsc     := Space(TAMSX3("QAA_MAT")[1])
	Local cMatOrig    := Nil
	Local cQuery      := ""
	Local cTpQDJ      := "D"
	Local lMvQdoRevd  := GetMv("MV_QDOREVD",.F.,"2") == "1" //1=SIM ; 2=NAO Denife se o Digitador pode Gerar Revisao.							
	Local lQDGDup     := .F.
	Local lTransfere  := .F.
	Local n0          := 1
	Local n0_1        := 0
	Local nA          := 1
	Local nCnt        := 0
	Local nOrdQDG     := 0
	Local nPosA       := 1
	Local nPosM1      := 0
	Local nPosM2      := 0
	Local nU          := 1
	Local oQAXA010Aux := QAXA010AuxClass():New()

	Private aUsrMail := {}
	Private bCampo   := {|nCPO| Field( nCPO ) }

	QD0->(dbSetOrder(2))
	QDG->(dbSetOrder(3))
	QAD->(dbSetOrder(1))
	QAA->(dbSetOrder(1))
	QD1->(dbSetOrder(2))
	QDR->(DbSetOrder(1))
	QDZ->(DbSetOrder(1))
	QDU->(DbSetOrder(1))

	Begin Transaction

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Transfere o Funcionario de Centro de Custo                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nItem3 == 1

			DbSelectArea("QAA")
			DbSetOrder(1)
			If DbSeek( cFilAtu + cMatAtu )
				RecLock("QAA",.F.)
				QAA->QAA_FILIAL:= cCcFilial
				QAA->QAA_MAT   := cCcMatr
				QAA->QAA_CC    := cCcPara
				MsUnlock()
				FKCOMMIT()
			Endif

			cQuery := "UPDATE"
			cQuery += " "+RetSqlName("QDP")+""
			cQuery += " SET QDP_FILMAT = '"+cCCFilial+"',"
			cQuery += " QDP_DEPTO = '"+cCcPara+"'
			cQuery += " WHERE QDP_FILIAL = '"+xFilial("QDP")+"'"
			cQuery += " AND QDP_MAT = '"+cCcMatr+"'"
			cQuery += " AND D_E_L_E_T_ = ' '"
						
			TcSqlExec( cQuery )
			TcRefresh( RetSqlName("QDP") )
						
			cQuery := "UPDATE"
			cQuery += " "+RetSqlName("QDP")+""
			cQuery += " SET QDP_FMATBX = '"+cCCFilial+"',"
			cQuery += " QDP_DEPBX = '"+cCcPara+"'
			cQuery += " WHERE QDP_FILIAL = '"+xFilial("QDP")+"'"
			cQuery += " AND QDP_MATBX <> ' '"
			cQuery += " AND QDP_MATBX = '"+cCcMatr+"'"
			cQuery += " AND D_E_L_E_T_ = ' '" 

			TcSqlExec( cQuery )
			TcRefresh( RetSqlName("QDP") )

			If cFilAtu+cMatAtu+cDepAtu <> cCcFilial+cCcMatr+cCcPara
				DbSelectArea("QAB")
				RecLock("QAB",.T.)
				QAB->QAB_FILD := cFilAtu
				QAB->QAB_MATD := cMatAtu
				QAB->QAB_CCD  := cDepAtu
				QAB->QAB_FILP := cCcFilial
				QAB->QAB_MATP := cCcMatr
				QAB->QAB_CCP  := cCcPara
				QAB->QAB_DATA := dDataBase
				MsUnlock()
				FKCOMMIT()
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Cria e-mail de Transferencia			  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			IF nItem5 <> 3 .AND. nItem5 <> 4
				QAX10Email(QDH->QDH_DOCTO,QDH->QDH_RV,cCcFilial,cCcMatr)
			Endif
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Transfere as Pendencias 			                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Len(aPenDoc) > 0
			For nA := 1 to Len(aTpPen)
		
				If (nItem3 == 2) .And. ( aTpPen[nA,1] == .F. .Or. aTpPen[nA,2] == .F. )
					Loop
				Endif
		
				nPosA := aScan(aPenDoc, { |x| Left(x[1],1) == aTpPen[nA,4] } )
				nPosA := If(nPosA == 0,Len(aPenDoc),nPosA)
		
				For nU := nPosA to Len(aPenDoc)
					If Left(aPenDoc[nU,1],1) <> aTpPen[nA,4]
						Exit
					Endif
			
					If nItem3 == 2
				
						If (aPenDoc[nU,4]) == .F. .Or. ;
							( Empty(aTpPen[nA,5]) .And. Empty(aPenDoc[nU,6]) .And. nItem5 <> 4)
							Loop
						Endif
				
					Endif
			
					cCcFilAtu := cCcFilial
					cCcMatAtu := cCcMatr
					cCcAtu    := cCcPara
			
					If !Empty(aTpPen[nA,5])
						cCcFilAtu := SubStr(aTpPen[nA,5],1,FWSizeFilial())
						cCcMatAtu := SubStr(aTpPen[nA,5],FWSizeFilial()+1)
						If QAA->(dbSeek(aTpPen[nA,5]))
							cCcAtu := QAA->QAA_CC
						Endif
					Endif
			
					If !Empty(aPenDoc[nU,6])
						cCcFilAtu := SubStr(aPenDoc[nU,6],1,FWSizeFilial())
						cCcMatAtu := SubStr(aPenDoc[nU,6],FWSizeFilial()+1)
						If QAA->(dbSeek(aPenDoc[nU,6]))
							cCcAtu := QAA->QAA_CC
						Endif
					Endif
			
					If aTpPen[nA,4] == "P"	// Pasta-Centro de Custo
						dbSelectArea("QAD")
						dbGoTo(aPenDoc[nU,7])
						If QAD->QAD_FILMAT+QAD->QAD_MAT <> cCcFilAtu+cCcMatAtu .And. nItem5 <> 4
							RecLock("QAD",.F.)
							QAD->QAD_FILMAT := cCcFilAtu
							QAD->QAD_MAT  	:= cCcMatAtu
							MsUnlock()
							FKCOMMIT()
						Endif
						Loop
					Endif

					cCcCargo  := Posicione("QAA",1,cCcFilAtu+cCcMatAtu,"QAA_CODFUN")

					// Posiciona no Docto para verificacao posterior
					dbSelectArea("QDH")
					dbSetOrder(1)
					dbSeek(aPenDoc[nU,8]+aPenDoc[nU,2]+aPenDoc[nU,3])
			
					// Transferencia de Destinatarios antes da Distribuicao
					If aTpPen[nA,4] == "G" .And. aPenDoc[nU,1] == "G  "
						dbSelectArea("QDG")
						dbGoTo(aPenDoc[nU,7])
				
						If QDG->QDG_FILMAT+QDG->QDG_DEPTO+QDG->QDG_MAT <> cCcFilAtu+cCcMatAtu+cCcAtu
					
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Grava Log de Transferencia			  ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							FQAXA010Log(QDG->QDG_FILIAL,QDG->QDG_DOCTO,QDG->QDG_RV,"QDG",QDG->QDG_FILMAT,QDG->QDG_MAT,QDG->QDG_DEPTO,cCcFilAtu,cCcMatAtu,cCcAtu)
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Cria e-mail de Transferencia			  ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							IF nItem5 <> 3 .AND. nItem5 <> 4
								QAX10Email(QDG->QDG_DOCTO,QDG->QDG_RV,cCcFilAtu,cCcMatAtu)
							Endif
					
							RecLock("QDG",.F.)
							QDG->QDG_RECEB  :="N"
							QDG->QDG_SIT    := "I"
							MsUnLock()
							FKCOMMIT()
					
							IF DBSEEK(aPenDoc[nU,8]+aPenDoc[nU,2]+aPenDoc[nU,3]+cCcFilAtu+cCcAtu+cCcMatAtu)
								RecLock("QDG",.F.)
								QDG->QDG_RECEB  :="S"
								QDG->QDG_SIT    := "T"
								MsUnLock()
								FKCOMMIT()
							Else
								dbGoTo(aPenDoc[nU,7])
								RecLock("QDG",.F.)
								QDG->QDG_FILMAT := cCcFilAtu
								QDG->QDG_MAT    := cCcMatAtu
								QDG->QDG_DEPTO  := cCcAtu
								QDG->QDG_RECEB  :="S"
								QDG->QDG_SIT    := "T"
								MsUnLock()
								FKCOMMIT()
							Endif
					
							If !QDJ->(dbSeek(QDG->QDG_FILIAL+QDG->QDG_DOCTO+QDG->QDG_RV+QDG->QDG_TIPO+cCcFilAtu+cCcAtu))
								RecLock("QDJ",.T.)
								QDJ->QDJ_FILIAL	:= QDG->QDG_FILIAL
								QDJ->QDJ_DOCTO 	:= QDG->QDG_DOCTO
								QDJ->QDJ_RV    	:= QDG->QDG_RV
								QDJ->QDJ_FILMAT	:= cCcFilAtu
								QDJ->QDJ_DEPTO	:= cCcAtu
								QDJ->QDJ_TIPO	:= QDG->QDG_TIPO
								MsUnlock()
								FKCOMMIT()
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³Grava Log de Transferencia			  ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								FQAXA010Log(QDJ->QDJ_FILIAL,QDJ->QDJ_DOCTO,QDJ->QDJ_RV,"QDJ",QDG->QDG_FILMAT,QDG->QDG_MAT,QDG->QDG_DEPTO,cCcFilAtu,cCcMatAtu,cCcAtu)
							Endif
						Endif
				
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Loop para realizar apenas o tipo "G" - Destinatarios ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						Loop
				
					Endif
			
					//Transf de Avisos     
					IF aTpPen[nA,4] == "S"
						IF nItem5 <> 3 .AND. nItem5 <> 4
							aAvPos:=Ascan(aAvisos,{|x| x[1]+x[2]+x[3] == aPenDoc[nU,8]+aPenDoc[nU,2]+aPenDoc[nU,3]})
							IF aAvPos > 0
								dbSelectArea("QDS")
								QDS->(DbSetOrder(1))
								IF nItem5 <> 2
									//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									//³Baixa o Aviso ³
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
									dbGoTo(aPenDoc[nU,7])
									RecLock( "QDS",.F.)
									QDS->QDS_PENDEN 	:= "B"
									QDS->QDS_DTBAIX	:= dDataBase
									QDS->QDS_HRBAIX	:= SubStr(Time(),1,5)
									QDS->QDS_FMATBX 	:= cMatFil
									QDS->QDS_MATBX  	:= cMatCod
									QDS->QDS_DEPBX  	:= cMatDep
									MsUnlock()
									FKCOMMIT()
								Else
									//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									//³ se não é baixa é transf. (nItem5 = 2) então  coloca origem como Inativo
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
									dbGoTo(aPenDoc[nU,7])
									RecLock( "QDS",.F.)
									QDS->QDS_SIT		:= "I"
									MsUnlock()
									FKCOMMIT()
								Endif
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³Grava o novo Aviso ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								IF !QDS->(DBSeek(cCcFilAtu+cCcMatAtu+"P"+aAvisos[aAvPos,6]+aPenDoc[nU,2]+aPenDoc[nU,3]+aAvisos[aAvPos,7]))
									QDXGvAviso(aAvisos[aAvPos,6],cCcFilAtu,cCcMatAtu,cCcAtu,aPenDoc[nU,2],aPenDoc[nU,3],aAvisos[aAvPos,7],aPenDoc[nU,8],aAvisos[aAvPos,8],aAvisos[aAvPos,9])
								Endif

								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³Loop para realizar apenas o tipo "S" - Avisos 		³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								Loop
						
							Endif
						Endif
					Endif
											
					// Criticas por Docto
					If aPenDoc[nU,9] == 1
						dbSelectArea("QD4")
						If dbSeek(aPenDoc[nU,8]+aPenDoc[nU,2]+aPenDoc[nU,3])
							While !Eof() .And. QD4->QD4_FILIAL+QD4->QD4_DOCTO+QD4->QD4_RV == aPenDoc[nU,8]+aPenDoc[nU,2]+aPenDoc[nU,3]
								If aTpPen[nA,4] == Left(QD4->QD4_TPPEND,1) .And. ;
									( QD4->QD4_FILMAT+QD4->QD4_MAT == cFilAtu+cMatAtu .Or. ;
									QD4->QD4_FMATBX+QD4->QD4_MATBX == cFilAtu+cMatAtu .Or. ;
									(nPosM1 := aScan(aBuscaQD1,{|x| x[1]+x[2] == QD4->QD4_FILMAT+QD4->QD4_MAT } )) > 0 .Or. ;
									(nPosM2 := aScan(aBuscaQD1,{|x| x[1]+x[2]+X[3] == QD4->QD4_FMATBX+QD4->QD4_MATBX+QD4->QD4_DEPBX } )) > 0 )
							
									If nItem4 == 1 .Or. ( nItem4 == 2 .And. QD4->QD4_PENDEN == "B" ) .Or. ;
										( nItem4 == 3 .And. QD4->QD4_PENDEN == "P" )
										Reclock("QD4",.F.)
										If nItem5 == 1 .Or. nItem5 == 2 .Or. nItem5 == 3	// Transf. e Ativar ou Transf. s/Baixar ou Transf. e Baixa
											If QD4->QD4_FILMAT+QD4->QD4_MAT == cFilAtu+cMatAtu .Or. ;
												(nPosM1 > 0 .And. QD4->QD4_FILMAT+QD4->QD4_MAT == aBuscaQD1[nPosM1,1]+aBuscaQD1[nPosM1,2])
												QD4->QD4_FILMAT := cCcFilAtu
												QD4->QD4_MAT	:= cCcMatAtu
											Endif
											If QD4->QD4_FMATBX+QD4->QD4_MATBX+QD4->QD4_DEPBX == cFilAtu+cMatAtu+cDepAtu .Or. ;
												(nPosM2 > 0 .And. QD4->QD4_FMATBX+QD4->QD4_MATBX+QD4->QD4_DEPBX == aBuscaQD1[nPosM2,1]+aBuscaQD1[nPosM2,2]+aBuscaQD1[nPosM2,3])
												QD4->QD4_FMATBX := cCcFilAtu
												QD4->QD4_MATBX	:= cCcMatAtu
												QD4->QD4_DEPBX	:= cCcAtu
											Endif
										Endif
										If nItem5 == 3 .Or. nItem5 == 4	// Transf. e Baixa ou Baixa s/Transf.
											QD4->QD4_PENDEN := "B"
											QD4->QD4_DTBAIX := dDataBase
											QD4->QD4_HRBAIX := SubStr(Time(),1,5)
											If nItem5 == 4
												QD4->QD4_FMATBX := cMatFil
												QD4->QD4_MATBX	:= cMatCod
												QD4->QD4_DEPBX	:= cMatDep
											Endif
										Endif
										MsUnlock()
										FKCOMMIT()
										//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
										//³Grava Log de Transferencia					³
										//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
										FQAXA010Log(QD4->QD4_FILIAL,QD4->QD4_DOCTO,QD4->QD4_RV,"QD4",cFilAtu,cMatAtu,cDepAtu,cCcFilAtu,cCcMatAtu,cCcAtu)
										//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
										//³Cria e-mail de Transferencia			  ³
										//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
										IF nItem5 <> 3 .AND. nItem5 <> 4
											QAX10Email(QD4->QD4_DOCTO,QD4->QD4_RV,cCcFilAtu,cCcMatAtu)
										Endif
								
									Endif
								Endif
								QD4->(dbSkip())
							Enddo
						Endif
					EndIf

					//QDU - Devolução de Revisão Anterior
					dbSelectArea("QDU")
					If QDU->(dbSeek(aPenDoc[nU,8]+aPenDoc[nU,2]))
						While QDU->(!Eof()) .And. QDU->QDU_FILIAL+QDU->QDU_DOCTO == aPenDoc[nU,8]+aPenDoc[nU,2]
							If QDU->QDU_FILMAT+QDU->QDU_MAT   == cFilAtu+cMatAtu .Or. ;
								QDU->QDU_FMATBX+QDU->QDU_MATBX == cFilAtu+cMatAtu
						
								If nItem4 == 1 .Or. ( nItem4 == 2 .And. QDU->QDU_PENDEN == "B" ) .Or. ;
													( nItem4 == 3 .And. QDU->QDU_PENDEN == "P" )
									Reclock("QDU",.F.)
									If nItem5 == 1 .Or. nItem5 == 2 .Or. nItem5 == 3	// Transf. e Ativar ou Transf. s/Baixar ou Transf. e Baixa
										If QDU->QDU_FILMAT+QDU->QDU_MAT == cFilAtu+cMatAtu
											QDU->QDU_FILMAT := cCcFilAtu
											QDU->QDU_DEPTO	:= cCcAtu
											QDU->QDU_MAT	:= cCcMatAtu
										Endif
										If QDU->QDU_FMATBX+QDU->QDU_MATBX+QDU->QDU_DEPBX == cFilAtu+cMatAtu+cDepAtu
											QDU->QDU_FMATBX := cCcFilAtu
											QDU->QDU_MATBX	:= cCcMatAtu
											QDU->QDU_DEPBX	:= cCcAtu
										Endif
									Endif
									If nItem5 == 3 .Or. nItem5 == 4	// Transf. e Baixa ou Baixa s/Transf.
										QDU->QDU_PENDEN := "B"
										QDU->QDU_DTBAIX := dDataBase
										QDU->QDU_HRBAIX := SubStr(Time(),1,5)
										If nItem5 == 4 //Baixa ou Baixa s/Transf.
											QDU->QDU_FMATBX := cMatFil
											QDU->QDU_MATBX	:= cMatCod
											QDU->QDU_DEPBX	:= cMatDep
										Endif
									Endif
									QDU->(MsUnlock())
									QDU->(FKCOMMIT())
									//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									//³Grava Log de Transferencia					³
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
									FQAXA010Log(QDU->QDU_FILIAL,QDU->QDU_DOCTO,QDU->QDU_RV,"QDU",cFilAtu,cMatAtu,cDepAtu,cCcFilAtu,cCcMatAtu,cCcAtu)
									//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									//³Cria e-mail de Transferencia			  ³
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
									IF nItem5 <> 3 .AND. nItem5 <> 4
										QAX10Email(QDU->QDU_DOCTO,QDU->QDU_RV,cCcFilAtu,cCcMatAtu)
									Endif
							
								Endif
							Endif
							QDU->(dbSkip())
						Enddo
					Endif
			
					// Solicitacoes de Alteracao
					If aPenDoc[nU,9] == 1
						dbSelectArea("QDP")
						dbSetOrder(1)  //QDP_FILIAL+QDP_DTOORI+QDP_RV+QDP_NUMSEQ
						If dbSeek(aPenDoc[nU,8]+aPenDoc[nU,2]+aPenDoc[nU,3])
							While !Eof() .And. QDP->QDP_FILIAL+QDP->QDP_DTOORI+QDP->QDP_RV == aPenDoc[nU,8]+aPenDoc[nU,2]+aPenDoc[nU,3]
								If (aTpPen[nA,4] == "E" .OR. (aTpPen[nA,4] == "D" .And. lMvQdoRevd)) .And. ;
									( QDP->QDP_FILMAT+QDP->QDP_DEPTO+QDP->QDP_MAT == cFilAtu+cDepAtu+cMatAtu .Or. ;
									QDP->QDP_FMATBX+QDP->QDP_DEPBX+QDP->QDP_MATBX == cFilAtu+cDepAtu+cMatAtu .Or. ;
									(nPosM1 := aScan(aBuscaQD1, {|x| x[1]+x[2]+x[3] == QDP->QDP_FILMAT+QDP->QDP_MAT  +QDP->QDP_DEPTO } )) > 0 .Or. ;
									(nPosM2 := aScan(aBuscaQD1, {|x| x[1]+x[2]+x[3] == QDP->QDP_FMATBX+QDP->QDP_MATBX+QDP->QDP_DEPBX } )) > 0 )
							
									If nItem4 == 1 .Or. ( nItem4 == 2 .And. QDP->QDP_PENDEN == "B" ) .Or. ;
										( nItem4 == 3 .And. QDP->QDP_PENDEN == "P" )
								
										Reclock("QDP",.F.)
										If nItem5 == 1 .Or. nItem5 == 2 .Or. nItem5 == 3	// Transf. s/Baixar ou Transf. e Baixa
											If QDP->QDP_FILMAT+QDP->QDP_DEPTO+QDP->QDP_MAT == cFilAtu+cDepAtu+cMatAtu .Or. ;
												(nPosM1 > 0 .And. QDP->QDP_FILMAT+QDP->QDP_MAT+QDP->QDP_DEPTO == aBuscaQD1[nPosM1,1]+aBuscaQD1[nPosM1,2]+aBuscaQD1[nPosM1,3])
												QDP->QDP_FILMAT := cCcFilAtu
												QDP->QDP_DEPTO	 := cCcAtu
												QDP->QDP_MAT	 := cCcMatAtu
											Endif
											If QDP->QDP_FMATBX+QDP->QDP_DEPBX+QDP->QDP_MATBX == cFilAtu+cDepAtu+cMatAtu .Or. ;
												(nPosM2 > 0 .And. QDP->QDP_FMATBX+QDP->QDP_MATBX+QDP->QDP_DEPBX == aBuscaQD1[nPosM2,1]+aBuscaQD1[nPosM2,2]+aBuscaQD1[nPosM2,3])
													QDP->QDP_FMATBX := cCcFilAtu
													QDP->QDP_DEPBX	 := cCcAtu
													QDP->QDP_MATBX	 := cCcMatAtu
												Endif
										Endif
										If nItem5 == 3 .Or. nItem5 == 4	// Transf. e Baixa ou Baixa s/Transf.
											QDP->QDP_PENDEN := "B"
											QDP->QDP_DTBAIX := dDataBase
											QDP->QDP_HRBAIX := SubStr(Time(),1,5)
											QDP->QDP_FMATBX := cMatFil
											QDP->QDP_MATBX	 := cMatCod
											QDP->QDP_DEPBX	 := cMatDep
										Endif
										MsUnLock()
										FKCOMMIT()
										//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
										//³Grava Log de Transferencia					³
										//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
										FQAXA010Log(QDP->QDP_FILIAL,QDP->QDP_DTOORI,QDP->QDP_RV,"QDP",cFilAtu,cMatAtu,cDepAtu,cCcFilAtu,cCcMatAtu,cCcAtu)
										//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
										//³Cria e-mail de Transferencia			  ³
										//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
										IF nItem5 <> 3 .AND. nItem5 <> 4
											QAX10Email(QDP->QDP_DTOORI,QDP->QDP_RV,cCcFilAtu,cCcMatAtu)
										Endif
									Endif
								Endif
								QDP->(dbSkip())
							Enddo
						Endif
					EndIf
			
					If nItem4 == 1 .Or. ( nItem4 == 2 .And. aPenDoc[nU,5] == "B" ) .Or. ;
						( nItem4 == 3 .And. aPenDoc[nU,5] == "P" )
				
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Atualiza o status de pendencias D/E que tenham criticas pendentes ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If !Empty(aPenCri)
							aEval(aPenCri,{|x| aPenDoc[x,5] := "B" })
						EndIf
								
						If aTpPen[nA,4] == "D"
							If nItem5 == 1 .Or. nItem5 == 2 .Or. nItem5 == 3	// Transf. e Ativar ou Transf. s/Baixar ou Transf. e Baixa
								dbSelectArea("QDH")
								dbSetOrder(1)
								If dbSeek(aPenDoc[nU,8]+aPenDoc[nU,2]+aPenDoc[nU,3])
									RecLock("QDH",.F.)
									QDH->QDH_FILMAT	:= cCcFilAtu
									QDH->QDH_MAT	:= cCcMatAtu
									QDH->QDH_DEPTOE	:= cCcAtu
									MsUnlock()
									FKCOMMIT()
									//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									//³Grava Log de Transferencia			  ³
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
									FQAXA010Log(QDH->QDH_FILIAL,QDH->QDH_DOCTO,QDH->QDH_RV,"QDH",cFilAtu,cMatAtu,cDepAtu,cCcFilAtu,cCcMatAtu,cCcAtu)
									//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									//³Cria e-mail de Transferencia			  ³
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
									IF nItem5 <> 3 .AND. nItem5 <> 4
										QAX10Email(QDH->QDH_DOCTO,QDH->QDH_RV,cCcFilAtu,cCcMatAtu)
									Endif
							
								Endif
							Endif
						Endif
				
						If aTpPen[nA,4] $ "E,R,A,H"
							If nItem5 == 1 .Or. nItem5 == 2 .Or. nItem5 == 3	// Transf. e Ativar ou Transf. s/Baixar ou Transf. e Baixa
								dbSelectArea("QD0")
								QD0->(dbSetOrder(2))
								For nCnt:= 1 To Len(aBuscaQD1)
									cFilBsc := aBuscaQD1[nCnt,1]
									cMatBsc := aBuscaQD1[nCnt,2]
									cDepBsc := aBuscaQD1[nCnt,3]   													                                                                 							
									IF (cFilBsc+cMatBsc+cDepBsc)==(cCcFilAtu+cCcMatAtu+cCcAtu)
										//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
										//³ignora a Transf de usuario para ele mesmo³
										//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
										Loop
									Endif
							
									If QD0->(DbSeek(aPenDoc[nU,8]+aPenDoc[nU,2]+aPenDoc[nU,3]+aTpPen[nA,4]+cFilBsc+cDepBsc+cMatBsc))
															
										aQD0Tran 	:= {}
										aQD0TranQD1 := {}
										aAreaQD0BKP := {}
										
										While QD0->(!Eof()) .And. QD0->(QD0_FILIAL+QD0_DOCTO+QD0_RV+QD0_AUT+QD0_FILMAT+QD0_DEPTO+QD0_MAT) == aPenDoc[nU,8]+aPenDoc[nU,2]+aPenDoc[nU,3]+aTpPen[nA,4]+cFilBsc+cDepBsc+cMatBsc
											aAdd(aQD0Tran,{ QD0->(QD0_FILIAL+QD0_DOCTO+QD0_RV+QD0_AUT), QD0->(QD0_FILMAT+QD0_DEPTO+QD0_MAT), QD0->(QD0_ORDEM)} )
											aAdd(aQD0TranQD1,{ QD0->(QD0_FILIAL+QD0_DOCTO+QD0_RV+QD0_DEPTO+QD0_FILMAT+QD0_MAT+QD0_AUT)} )
											QD0->(dbSkip())
										Enddo
								
										For n0 := 1 to Len(aQD0Tran)
											If QD0->(dbSeek(aQD0Tran[n0,1]+aQD0Tran[n0,2]))
												nRegQD0 := QD0->(Recno())
												For n0_1 := 1 to FCount()
													cCampo  := "M->O_"+Upper( AllTrim( QD0->( FieldName( n0_1 ) ) ) )
													&cCampo := QD0->( FieldGet( n0_1 ) )
												Next

												lTransfere := oQAXA010Aux:responsabilidadeQD0ExisteNasPendenciasQD1(aQD0TranQD1[n0])

												aPenDoc[nU,9] := 1

												RecLock("QD0",.F.)
													QD0->QD0_FLAG := "I"	
												QD0->(MsUnlock())
												QD0->(FKCOMMIT())

												QD0->(dbSetOrder(2))
												If !QD0->(dbSeek(aQD0Tran[n0,1]+cCcFilAtu+cCcAtu+cCcMatAtu))
													
													If lTransfere
														RecLock("QD0",.T.)
															For n0_1 := 1 to FCount()
																FieldPut( n0_1, &("M->O_"+Eval( bCampo, n0_1 ) ) )
															Next
															QD0->QD0_FILMAT := cCcFilAtu
															QD0->QD0_MAT    := cCcMatAtu
															QD0->QD0_DEPTO  := cCcAtu
															QD0->QD0_FLAG   := "T"
														QD0->(MsUnLock())
														QD0->(FKCOMMIT())
													Else
														QD0->(DBGOTO(nRegQD0))
														RecLock("QD0",.F.)
															QD0->QD0_FILMAT := cCcFilAtu
															QD0->QD0_MAT    := cCcMatAtu
															QD0->QD0_DEPTO 	:= cCcAtu
															QD0->QD0_FLAG  	:= ""
														QD0->(MsUnlock())
														QD0->(FKCOMMIT())
													EndIf

													//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
													//³Grava Log de Transferencia			  ³
													//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
													If aPenDoc[nU,9] == 1
														FQAXA010Log(QD0->QD0_FILIAL,QD0->QD0_DOCTO,QD0->QD0_RV,QD0->QD0_AUT,cFilBsc,cMatBsc,cDepBsc,cCcFilAtu,cCcMatAtu,cCcAtu)
														//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
														//³Cria e-mail de Transferencia			  ³
														//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
														IF nItem5 <> 3 .AND. nItem5 <> 4
															QAX10Email(QD0->QD0_DOCTO,QD0->QD0_RV,cCcFilAtu,cCcMatAtu)
														Endif
													EndIf
												Else
													RecLock("QD0",.F.)
														QD0->QD0_FLAG := "T"
													QD0->(MsUnLock())
													QD0->(FKCOMMIT())
												Endif

											Endif
											lTransfere  := .F.
											aAreaQD0BKP := {}
										Next n0
									Endif
								Next nCnt
							Endif
						Endif
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Gravacao do QDZ para Transf de Distribuicao³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						IF aTpPen[nA,4] == "I"
							cFilOrig := aPenDoc[nU,POS_PendDoc_FILMAT]
							cMatOrig := aPenDoc[nU,POS_PendDoc_MAT]
							cDepOrig := aPenDoc[nU,POS_PendDoc_DEPMAT]

							If !Empty(cFilOrig+cMatOrig+cDepOrig) .And. ;
								(cFilOrig+cMatOrig+cDepOrig) <> (cCcFilAtu+cCcMatAtu+cCcAtu)
								If QDZ->(DbSeek(aPenDoc[nU,POS_PendDoc_FILIAL]+aPenDoc[nU,POS_PendDoc_DOCTO]+aPenDoc[nU,POS_PendDoc_RV]+cDepOrig+cMatOrig+cFilOrig))

									//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									//³Grava Log de Transferencia			  ³
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
									FQAXA010Log(QDZ->QDZ_FILIAL,QDZ->QDZ_DOCTO,QDZ->QDZ_RV,"I",cFilAtu,cMatAtu,cDepAtu,cCcFilAtu,cCcMatAtu,cCcAtu)

									RecLock("QDZ",.F.)
									QDZ->(DbDelete())
									QDZ->(MsUnLock())
									FKCOMMIT()

								EndIf
							EndIf

							If !QDZ->(DbSeek(aPenDoc[nU,8]+aPenDoc[nU,2]+aPenDoc[nU,3]+cCcAtu+cCcMatAtu+cCcFilAtu))
								RecLock( "QDZ",.T.)
								QDZ->QDZ_FILIAL := aPenDoc[nU,8]
								QDZ->QDZ_DOCTO  := aPenDoc[nU,2]
								QDZ->QDZ_RV     := aPenDoc[nU,3]
								QDZ->QDZ_FILMAT := cCcFilAtu
								QDZ->QDZ_DEPTO  := cCcAtu
								QDZ->QDZ_MAT	:= cCcMatAtu
								QDZ->QDZ_DIGITA	:= "1"
								MsUnLock()
								FKCOMMIT()
								DbSelectArea("QD1")
							Endif
						Endif

						If aPenDoc[nU,9] == 1 .AND. aPenDoc[nU,11] == "QD1"
							dbSelectArea("QD1")
							dbGoTo(aPenDoc[nU,7])

							IF (QD1->QD1_TPPEND == "L  " .Or. (QD1->QD1_TPPEND <> "L  " .And. QDH->QDH_STATUS == "L  ")) .And. ;
								aPenDoc[nU,8]+aPenDoc[nU,2]+aPenDoc[nU,3] == QD1->(QD1_FILIAL+QD1_DOCTO+QD1_RV) .And. ;
								cCcAtu+cCcFilAtu+cCcMatAtu <> QD1->QD1_DEPTO+QD1->QD1_FILMAT+QD1->QD1_MAT .And. ;
								( nItem5 == 1 .Or. nItem5 == 2 )
						
								lQDGDup := .T.
								For n0_1 := 1 to FCount()
									cCampo := "M->O_"+Upper( AllTrim( QD1->( FieldName( n0_1 ) ) ) )
									&cCampo := QD1->( FieldGet( n0_1 ) )
								Next
								
								dbSetOrder(7) //QD1_FILIAL+QD1_DOCTO+QD1_RV+QD1_DEPTO+QD1_FILMAT+QD1_MAT+QD1_TPPEND+QD1_PENDEN
								If !QD1->(dbSeek(aPenDoc[nU,8]+aPenDoc[nU,2]+aPenDoc[nU,3]+cCcAtu+cCcFilAtu+cCcMatAtu+M->O_QD1_TPPEND))
									RecLock("QD1",.T.)
									For n0_1 := 1 to FCount()
										FieldPut( n0_1, &("M->O_"+Eval( bCampo, n0_1 ) ) )
									Next
							
									QD1->QD1_FILMAT:= cCcFilAtu
									QD1->QD1_MAT   := cCcMatAtu
									QD1->QD1_DEPTO := cCcAtu
									QD1->QD1_CARGO := cCcCargo
									QD1->QD1_SIT   := "T"	// Lacto de Transferencia
							
									If  QD1->QD1_PENDEN == "B" .AND. QD1->QD1_TPPEND == "L  " .AND. QD1->QD1_TPDIST<>"2"
										If nItem5 == 1
											QD1->QD1_PENDEN := "P"
											QD1->QD1_DTBAIX := CTOD("  /  /  ")
											QD1->QD1_HRBAIX := Space(5)
											QD1->QD1_LEUDOC := "N"
											QD1->QD1_FMATBX := Space(FWSizeFilial()) //Space(2)
											QD1->QD1_MATBX  := Space(TAMSX3("QAA_MAT")[1])
											QD1->QD1_DEPBX  := Space(TAMSX3("QAA_CC")[1])
										Endif
									Endif
									MsUnLock()
									FKCOMMIT()
								Else
									RecLock("QD1",.F.)
									QD1->QD1_SIT := "T" // Lacto de Transferencia
							
									If QD1->QD1_TPPEND == "L  " .AND. QD1->QD1_TPDIST<>"2"
										If nItem5 == 1
											QD1->QD1_PENDEN := "P"
											QD1->QD1_DTBAIX := CTOD("  /  /  ")
											QD1->QD1_HRBAIX := Space(5)
											QD1->QD1_LEUDOC := "N"
											QD1->QD1_FMATBX := Space(FWSizeFilial())//Space(2)
											QD1->QD1_MATBX  := Space(TAMSX3("QAA_MAT")[1])
											QD1->QD1_DEPBX  := Space(TAMSX3("QAA_CC")[1])
										Endif
									Endif
									MsUnLock()
									FKCOMMIT()
								Endif

								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³Grava Log de Transferencia					³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								FQAXA010Log(QD1->QD1_FILIAL,QD1->QD1_DOCTO,QD1->QD1_RV,QD1->QD1_TPPEND,cFilAtu,cMatAtu,cDepAtu,cCcFilAtu,cCcMatAtu,cCcAtu)
								
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³Cria e-mail de Transferencia			  ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								IF nItem5 <> 3 .AND. nItem5 <> 4
									QAX10Email(QD1->QD1_DOCTO,QD1->QD1_RV,cCcFilAtu,cCcMatAtu)
								Endif
						
								dbSelectArea("QD1")
								dbSetOrder(2)
								dbGoTo(aPenDoc[nU,7])
								RecLock("QD1",.F.)
								QD1->QD1_SIT := "I"	// Inativo
								MsUnlock()
								FKCOMMIT()
							Else
								lQDGDup := .F.
								dbGoTo(aPenDoc[nU,7])
								If aTpPen[nA,4] == "L" .AND. QD1->QD1_TPDIST<>"2"
									If nItem5 == 1 .And. !(nItem3 == 1 .And. cCcFilAtu+cCcMatAtu == cFilAtu+cMatAtu )
										RecLock("QD1",.F.)
										QD1->QD1_PENDEN := "P"
										QD1->QD1_DTBAIX := CTOD("  /  /  ","DDMMYY")
										QD1->QD1_HRBAIX := Space(5)
										QD1->QD1_LEUDOC := "N"
										QD1->QD1_FMATBX := Space(FWSizeFilial())//Space(2)
										QD1->QD1_MATBX  := Space(TAMSX3("QAA_MAT")[1])
										QD1->QD1_DEPBX  := Space(TAMSX3("QAA_CC")[1])
										MsUnlock()
										FKCOMMIT()        
									Endif
								Endif
								If (nItem5 <> 4) .And. ;  // Baixa s/Transf.
									cCcAtu+cCcFilAtu+cCcMatAtu <> QD1->QD1_DEPTO+QD1->QD1_FILMAT+QD1->QD1_MAT
									dbSetOrder(7)
									If !dbSeek(aPenDoc[nU,8]+aPenDoc[nU,2]+aPenDoc[nU,3]+cCcAtu+cCcFilAtu+cCcMatAtu+aPenDoc[nU,1])
										dbGoTo(aPenDoc[nU,7])
								
										cChkFil   := QD1->QD1_FILMAT
										cChkMat	  := QD1->QD1_MAT
										cChkTpPnd := AllTrim(QD1->QD1_TPPEND)
								
										RecLock("QD1",.F.)
										QD1->QD1_FILMAT	:= cCcFilAtu
										QD1->QD1_MAT	:= cCcMatAtu
										QD1->QD1_DEPTO	:= cCcAtu
										QD1->QD1_CARGO  := cCcCargo
										QD1->QD1_SIT	:= " "
										MsUnlock()
										FKCOMMIT()
										
										//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
										//³Transfere as pendencias com critica (EC/DC) ³
										//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
										QA010TCR(cChkFil,cChkMat,cChkTpPnd,cCcFilAtu,cCcMatAtu,cCcAtu,aPenDoc[nU])
									Else
										dbGoTo(aPenDoc[nU,7])
										IF aTpPen[nA,4] == "L" .AND. QD1->QD1_TPDIST<>"2"
											RecLock("QD1",.F.)
												QD1->QD1_SIT 	:= "I"
												QD1->QD1_PENDEN	:= "B"			
											MsUnLock()
											FKCOMMIT()
										Else
											cChkFil   := QD1->QD1_FILMAT
											cChkMat	  := QD1->QD1_MAT
											cChkTpPnd := AllTrim(QD1->QD1_TPPEND)

											RecLock("QD1",.F.)
											QD1->QD1_FILMAT	:= cCcFilAtu
											QD1->QD1_MAT	:= cCcMatAtu
											QD1->QD1_DEPTO	:= cCcAtu
											QD1->QD1_CARGO  := cCcCargo
											QD1->QD1_SIT 	:= " "
											MsUnLock()
											FKCOMMIT()
											
											//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
											//³Transfere as pendencias com critica (EC/DC) ³
											//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
											QA010TCR(cChkFil,cChkMat,cChkTpPnd,cCcFilAtu,cCcMatAtu,cCcAtu,aPenDoc[nU])
										Endif
									Endif
									//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									//³Grava Log de Transferencia			  ³
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
									FQAXA010Log(QD1->QD1_FILIAL,QD1->QD1_DOCTO,QD1->QD1_RV,QD1->QD1_TPPEND,cFilAtu,cMatAtu,cDepAtu,cCcFilAtu,cCcMatAtu,cCcAtu)
									
									//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									//³Cria e-mail de Transferencia			  ³
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
									QAX10Email(QD1->QD1_DOCTO,QD1->QD1_RV,cCcFilAtu,cCcMatAtu)							
							
								Endif
								If nItem5 == 4 .Or. nItem5 == 3  	// Transf. e Baixa ou Baixa s/Transf.
									RecLock("QD1",.F.)
									QD1->QD1_PENDEN := "B"
									QD1->QD1_DTBAIX := dDataBase
									QD1->QD1_HRBAIX := Substr( Time(), 1, 5 )
									QD1->QD1_LEUDOC := "S"
									QD1->QD1_FMATBX := cMatFil
									QD1->QD1_MATBX  := cMatCod
									QD1->QD1_DEPBX  := cMatDep
									MsUnlock()
									FKCOMMIT()
									//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									//³Grava Log de Transferencia			  ³
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
									FQAXA010Log(QD1->QD1_FILIAL,QD1->QD1_DOCTO,QD1->QD1_RV,QD1->QD1_TPPEND,cFilAtu,cMatAtu,cDepAtu,cCcFilAtu,cCcMatAtu,cCcAtu)
									//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									//³Cria e-mail de Transferencia			  ³
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
									IF nItem5 <> 4
										QAX10Email(QD1->QD1_DOCTO,QD1->QD1_RV,cCcFilAtu,cCcMatAtu)
									Endif
								Endif
							Endif
						Endif

				
						//-- Atualiza os arquivos de Destinos e Destinatarios
						If aPenDoc[nU,9] == 1
							If aTpPen[nA,4] == "L" .And. (nItem5 == 1 .Or. nItem5 == 2 .Or. nItem5 == 3)	// Transf. s/Baixar ou Transf. e Baixa
						
								dbSelectArea("QDG")
								For nCnt:= 1 To Len(aBuscaQD1)
									cFilBsc := aBuscaQD1[nCnt,1]
									cMatBsc := aBuscaQD1[nCnt,2]
									cDepBsc := aBuscaQD1[nCnt,3]
							
									If dbSeek(aPenDoc[nU,8]+aPenDoc[nU,2]+aPenDoc[nU,3]+cFilBsc+cDepBsc+cMatBsc)
										aQDGTran := {}
										While !Eof() .And. QDG->QDG_FILIAL+QDG->QDG_DOCTO+QDG->QDG_RV+QDG->QDG_FILMAT+QDG->QDG_DEPTO+QDG->QDG_MAT == aPenDoc[nU,8]+aPenDoc[nU,2]+aPenDoc[nU,3]+cFilBsc+cDepBsc+cMatBsc
											aAdd(aQDGTran,{QDG->QDG_FILIAL+QDG->QDG_DOCTO+QDG->QDG_RV,QDG->QDG_FILMAT+QDG->QDG_DEPTO+QDG->QDG_MAT} )
											QDG->(dbSkip())
										Enddo
										If Len(aQDGTran) > 0
											cTpQDJ := "D"
									
											For n0:=1 to Len(aQDGTran)
												If QDG->(dbSeek(aQDGTran[n0,1]+aQDGTran[n0,2]))
													If QDG->QDG_SIT <> "I"
														nRegQDG := QDG->(Recno())
														If lQDGDup
															For n0_1 := 1 to FCount()
																cCampo := "M->O_"+Upper( AllTrim( QDG->( FieldName( n0_1 ) ) ) )
																&cCampo := QDG->( FieldGet( n0_1 ) )
															Next
													
															RecLock("QDG",.F.)
															QDG->QDG_SIT := "I"
															MsUnlock()
															FKCOMMIT()
													
															If !QDG->(dbSeek(aQDGTran[n0,1]+cCcFilAtu+cCcAtu+cCcMatAtu))
																RecLock("QDG",.T.)
																For n0_1 := 1 to FCount()
																	FieldPut( n0_1, &("M->O_"+Eval( bCampo, n0_1 ) ) )
																Next
																QDG->QDG_FILMAT	:= cCcFilAtu
																QDG->QDG_MAT		:= cCcMatAtu
																QDG->QDG_DEPTO		:= cCcAtu
																QDG->QDG_SIT      := " "
																MsUnLock()
																FKCOMMIT()
																//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
																//³Grava Log de Transferencia			  ³
																//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
																FQAXA010Log(QDG->QDG_FILIAL,QDG->QDG_DOCTO,QDG->QDG_RV,"QDG",cFilBsc,cMatBsc,cDepBsc,cCcFilAtu,cCcMatAtu,cCcAtu)
																//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
																//³Cria e-mail de Transferencia			  ³
																//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
																IF nItem5 <> 3 .AND. nItem5 <> 4
																	QAX10Email(QDG->QDG_DOCTO,QDG->QDG_RV,cCcFilAtu,cCcMatAtu)
																Endif
														
															Else
																RecLock("QDG",.F.)
																QDG->QDG_SIT := " "
																MsUnLock()
																FKCOMMIT()
															Endif
														Else
															If QDG->(dbSeek(aQDGTran[n0,1]+cCcFilAtu+cCcAtu+cCcMatAtu))
																RecLock("QDG",.F.)
																QDG->QDG_SIT := " "
																MsUnlock()
																FKCOMMIT()
																QDG->(dbGoTo(nRegQDG))
																If QDG->QDG_FILMAT+QDG->QDG_MAT+QDG->QDG_DEPTO <> cCcFilAtu+cCcMatAtu+cCcAtu
																	RecLock("QDG",.F.)
																	QDG->QDG_SIT := "I"
																	MsUnlock()
																	FKCOMMIT()
																EndIf
															Else
																QDG->(dbGoTo(nRegQDG))
																RecLock("QDG",.F.)
																QDG->QDG_FILMAT	:= cCcFilAtu
																QDG->QDG_MAT		:= cCcMatAtu
																QDG->QDG_DEPTO		:= cCcAtu
																MsUnlock()
																FKCOMMIT()
																//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
																//³Grava Log de Transferencia			  ³
																//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
																FQAXA010Log(QDG->QDG_FILIAL,QDG->QDG_DOCTO,QDG->QDG_RV,"QDG",cFilBsc,cMatBsc,cDepBsc,cCcFilAtu,cCcMatAtu,cCcAtu)
																//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
																//³Cria e-mail de Transferencia			  ³
																//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
																IF nItem5 <> 3 .AND. nItem5 <> 4
																	QAX10Email(QDG->QDG_DOCTO,QDG->QDG_RV,cCcFilAtu,cCcMatAtu)
																Endif
														
															Endif
														Endif
														cTpQDJ := QDG->QDG_TIPO
													Endif
												EndIf
											Next
											If !QDG->(dbSeek(aPenDoc[nU,8]+aPenDoc[nU,2]+aPenDoc[nU,3]+cFilBsc+cDepBsc))
												If !QDJ->(dbSeek(aPenDoc[nU,8]+aPenDoc[nU,2]+aPenDoc[nU,3]+cTpQDJ+cCcFilAtu+cCcAtu))
													If QDJ->(dbSeek(aPenDoc[nU,8]+aPenDoc[nU,2]+aPenDoc[nU,3]+cTpQDJ+cFilBsc+cDepBsc))
														RecLock("QDJ",.F.)
														QDJ->QDJ_FILMAT	:= cCcFilAtu
														QDJ->QDJ_DEPTO	:= cCcAtu
														MsUnlock()
														FKCOMMIT()
														//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
														//³Grava Log de Transferencia			  ³
														//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
														FQAXA010Log(QDJ->QDJ_FILIAL,QDJ->QDJ_DOCTO,QDJ->QDJ_RV,"QDJ",cFilBsc,cMatBsc,cDepBsc,cCcFilAtu,cCcMatAtu,cCcAtu)
														//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
														//³Cria e-mail de Transferencia			  ³
														//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
														IF nItem5 <> 3 .AND. nItem5 <> 4
															QAX10Email(QDJ->QDJ_DOCTO,QDJ->QDJ_RV,cCcFilAtu,cCcMatAtu)
														Endif
												
													Endif
												Endif
											Endif
											If !QDJ->(dbSeek(aPenDoc[nU,8]+aPenDoc[nU,2]+aPenDoc[nU,3]+cTpQDJ+cCcFilAtu+cCcAtu))
												RecLock("QDJ",.T.)
												QDJ->QDJ_FILIAL	:= aPenDoc[nU,8]
												QDJ->QDJ_DOCTO 	:= aPenDoc[nU,2]
												QDJ->QDJ_RV    	:= aPenDoc[nU,3]
												QDJ->QDJ_FILMAT	:= cCcFilAtu
												QDJ->QDJ_DEPTO		:= cCcAtu
												QDJ->QDJ_TIPO		:= cTpQDJ
												MsUnlock()
												FKCOMMIT()
												//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
												//³Grava Log de Transferencia			  ³
												//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
												FQAXA010Log(QDJ->QDJ_FILIAL,QDJ->QDJ_DOCTO,QDJ->QDJ_RV,"QDJ",cFilBsc,cMatBsc,cDepBsc,cCcFilAtu,cCcMatAtu,cCcAtu)
												//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
												//³Cria e-mail de Transferencia			  ³
												//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
												IF nItem5 <> 3 .AND. nItem5 <> 4
													QAX10Email(QDJ->QDJ_DOCTO,QDJ->QDJ_RV,cCcFilAtu,cCcMatAtu)
												Endif
										
											Endif
										Endif
									Endif
								Next nCnt
							Endif
						Endif
					EndIf
				Next
			Next
		Endif

	End Transaction

	IF Len(aUsrMail) > 0
		QaEnvMail(aUsrMail,,,,aUsrMat[5],"2")
	Endif

	QD1->(dbSetOrder(3))

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QAXA010CkPen³ Autor ³ Aldo Marini Junior  ³ Data ³ 15.05.00 ³±±
±±³          carregaPendenciasBaixadasOuNao                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Carrega os Lactos de Pendencias                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ carregaPendenciasBaixadasOuNao(...)                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 - Array contendo os Tp.Pendencias selecionadas       ³±±
±±³          ³ ExpA2 - Array contendo os Lactos das Pendencias            ³±±
±±³          ³ ExpA3 - Array contendo os Doctos envolvidos com o usr      ³±±
±±³          ³ ExpN1 - Numerico Indicando Tp Pendencia Ambas/Baix/Pend    ³±±
±±³          ³ ExpO1 - Objeto do Listbox de Documentos                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/


Method carregaPendenciasBaixadasOuNao(aTpPen, aPenDoc, aDoctos, nItem4, oDoctos, aAvisos, oAvisos, aAviAux, lPergunta) CLASS QAXA010AuxClass

	Local cDepBsc    := Space(TamSx3("QAA_CC")[1])
	Local cFilBsc    := Space(FWSizeFilial())
	Local cMatBsc    := Space(TamSx3("QAA_MAT")[1])
	Local cTrCancel  := GetNewPar("MV_QTRCANC","1")
	Local nA         := 1
	Local nI         := 0
	Local nIndice    := 0
	Local nPos       := 0
	Local nTotPenDoc := 0

	Default lPergunta := SuperGetMv("MV_QDOFTRA",.F.,.T.)

	aArryPg     := {dDataBase - 36525                     ,;
					dDataBase + 36525                     ,;
					Space(TamSx3("QDH_DOCTO")[1])         ,;
					Replicate("z",TamSx3("QDH_DOCTO")[1]) ,;
					Space(TamSx3("QDH_RV")[1])            ,;
					Replicate("z",TamSx3("QDH_RV")[1])    }

	If lPergunta .AND. !fMontPerg()
		Return .F.
	EndIf

	//Atualiza Filtros de Documento e Revisão aFltDoc - PERFORMANCE/LEGADO
	fAtuFltDoc()

	QDH->(DbSetOrder(1))
	QD1->(DbSetOrder(3)) 

	For nA:= 1 to Len(aBuscaQD1)
		cFilBsc := aBuscaQD1[nA,1]
		cMatBsc := aBuscaQD1[nA,2]
		cDepBsc := aBuscaQD1[nA,3]

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Carrega as responsabilidade ja delegadas em etapa do processo de elaboracao ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cQuery := " SELECT QD1.QD1_FILIAL, QD1.QD1_DOCTO, QD1.QD1_RV, QD1.QD1_TPPEND, QD1.QD1_PENDEN, QD1.R_E_C_N_O_ " 
		cQuery += "   FROM " + RetSqlName("QD1")+" QD1 "
		cQuery += "  WHERE QD1.QD1_FILMAT = '"+cFilBsc+"' AND QD1.QD1_MAT = '"+cMatBsc+"' AND QD1.QD1_DEPTO = '"+cDepBsc+"' AND QD1.QD1_SIT <> 'I'"
		cQuery +=    " AND QD1.QD1_TPPEND <> 'EC' AND QD1.QD1_TPPEND <> 'DC' "
		cQuery +=    " AND QD1.QD1_DOCTO  >= '" + aArryPg[POS_TR_DocumentoDE]   + "' "
		cQuery +=    " AND QD1.QD1_DOCTO  <= '" + aArryPg[POS_TR_DocumentoATE]  + "' "
		cQuery +=    " AND QD1.QD1_RV     >= '" + aArryPg[POS_TR_RevisaoDE]     + "' "
		cQuery +=    " AND QD1.QD1_RV     <= '" + aArryPg[POS_TR_RevisaoATE]    + "' "
		cQuery +=    " AND QD1.QD1_DTGERA >= '" + DtoS(aArryPg[POS_TR_DataDE])  + "' "
		cQuery +=    " AND QD1.QD1_DTGERA <= '" + DtoS(aArryPg[POS_TR_DataATE]) + "' "
		cQuery +=    " AND QD1.D_E_L_E_T_ = ' ' "
		
		cQuery += " AND NOT EXISTS(SELECT R_E_C_N_O_ FROM "+ RetSqlName("QDH")+" QDH WHERE QD1.QD1_FILIAL = QDH.QDH_FILIAL "
		cQuery += " AND QD1.QD1_DOCTO = QDH.QDH_DOCTO AND QD1.QD1_RV = QDH.QDH_RV"
		If cTrCancel =="2"
			cQuery += " AND QDH.QDH_OBSOL = 'S' AND QDH.QDH_STATUS = 'L'" 
		Else
			cQuery += " AND (QDH.QDH_OBSOL = 'S' Or (QDH.QDH_CANCEL = 'S' And QDH.QDH_STATUS = 'L'))"
		Endif
		cQuery += " AND QDH.D_E_L_E_T_ = ' ')"
		cQuery += " ORDER BY QD1.QD1_FILIAL,QD1.QD1_TPPEND,QD1.QD1_DOCTO,QD1.QD1_RV "			
		cQuery := ChangeQuery(cQuery) 
						
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QD1TRB",.T.,.T.)

		WHILE QD1TRB->(!EOF())
			If (nPos:= aScan(aTpPen,{|x| x[POS_aTpPen_TPPEND] == ALLTRIM(QD1TRB->QD1_TPPEND)})) > 0

				aTpPen[nPos, POS_aTpPen_TEM_DOCUMENTO] := .T.

				//Atualiza o array com as pendencias de todas as etapas
				If (nPos:= aScan(aPenDoc,{|x| x[POS_PendDoc_TPPEND] == QD1TRB->QD1_TPPEND .And.;
											  x[POS_PendDoc_FILIAL] == QD1TRB->QD1_FILIAL .And.;
											  x[POS_PendDoc_DOCTO ] == QD1TRB->QD1_DOCTO  .And.;
											  x[POS_PendDoc_RV    ] == QD1TRB->QD1_RV })) == 0 .Or. ;
				   (nPos > 0 .And. aPenDoc[nPos,POS_PendDoc_RECNO]  <> QD1TRB->R_E_C_N_O_)

					aAdd(aPenDoc,{QD1TRB->QD1_TPPEND,QD1TRB->QD1_DOCTO,QD1TRB->QD1_RV,.T.,QD1TRB->QD1_PENDEN,INI_CAMPO_ADOCTOS_FIL_MAT,QD1TRB->R_E_C_N_O_,QD1TRB->QD1_FILIAL,1,QD1TRB->QD1_PENDEN, "QD1", cFilBsc, cMatBsc, cDepBsc})

				Endif
			EndIf
			QD1TRB->(DbSkip())				
		ENDDO
		QD1TRB->(DbCloseArea())



		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Carrega os distribuidores que ainda nao receberam distribuicao vinculada ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cQuery := " SELECT QDZ.QDZ_FILIAL, QDZ.QDZ_DOCTO, QDZ.QDZ_RV, QDZ.R_E_C_N_O_ " 
		cQuery += "   FROM " + RetSqlName("QDZ")+" QDZ "
		cQuery += "  WHERE QDZ.QDZ_FILMAT = '"+cFilBsc+"' AND QDZ.QDZ_MAT = '"+cMatBsc+"' AND QDZ.QDZ_DEPTO = '"+cDepBsc+"' "
		cQuery +=    " AND QDZ.QDZ_DOCTO  >= '"+aArryPg[POS_TR_DocumentoDE]+"' "
		cQuery +=    " AND QDZ.QDZ_DOCTO  <= '"+aArryPg[POS_TR_DocumentoATE]+"' "
		cQuery +=    " AND QDZ.QDZ_RV     >= '"+aArryPg[POS_TR_RevisaoDE]+"' "
		cQuery +=    " AND QDZ.QDZ_RV     <= '"+aArryPg[POS_TR_RevisaoATE]+"' "
		cQuery +=    " AND QDZ.D_E_L_E_T_ = ' ' "
		
		cQuery += " AND NOT EXISTS(SELECT R_E_C_N_O_ FROM "+ RetSqlName("QDH")+" QDH WHERE QDZ.QDZ_FILIAL = QDH.QDH_FILIAL "
		cQuery += " AND QDZ.QDZ_DOCTO = QDH.QDH_DOCTO AND QDZ.QDZ_RV = QDH.QDH_RV"
		If cTrCancel =="2"
			cQuery += " AND QDH.QDH_OBSOL = 'S' AND QDH.QDH_STATUS = 'L'" 
		Else
			cQuery += " AND (QDH.QDH_OBSOL = 'S' Or (QDH.QDH_CANCEL = 'S' And QDH.QDH_STATUS = 'L'))"
		Endif
		cQuery += " AND QDH.D_E_L_E_T_ = ' ')"
		cQuery += " ORDER BY QDZ.QDZ_FILIAL,QDZ.QDZ_DOCTO,QDZ.QDZ_RV "			
		cQuery := ChangeQuery(cQuery) 
						
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QDZTRB",.T.,.T.)

		WHILE QDZTRB->(!EOF())
			If (nPos:= aScan(aTpPen,{|x| x[POS_aTpPen_TPPEND] == "I"})) > 0

				aTpPen[nPos, POS_aTpPen_TEM_DOCUMENTO] := .T.

				//Atualiza o array com as pendencias de distribuicao ainda nao geradas
				If (nPos := aScan(aPenDoc,{|x| x[POS_PendDoc_TPPEND] == "I  "                   .And.;
											   x[POS_PendDoc_FILIAL] == QDZTRB->QDZ_FILIAL      .And.;
											   x[POS_PendDoc_DOCTO ] == QDZTRB->QDZ_DOCTO       .And.;
											   x[POS_PendDoc_RV    ] == QDZTRB->QDZ_RV })) == 0

					aAdd(aPenDoc,{"I  ",QDZTRB->QDZ_DOCTO,QDZTRB->QDZ_RV,.T.,"B",INI_CAMPO_ADOCTOS_FIL_MAT,QDZTRB->R_E_C_N_O_,QDZTRB->QDZ_FILIAL,1,"P", "QDZ", cFilBsc, cMatBsc, cDepBsc})

				Endif
			EndIf
			QDZTRB->(DbSkip())
		ENDDO
		QDZTRB->(DbCloseArea())


		DBSelectArea("QAD")
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza o sinalizador no Tipo de Pendencias                                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cQuery :="    SELECT QAD.QAD_FILIAL, QAD.QAD_CUSTO, QAD.R_E_C_N_O_ " 
		cQuery += "     FROM " + RetSqlName("QAD")+" QAD "
		cQuery += "    WHERE QAD.QAD_FILMAT = '"+cFilBsc+"' AND QAD.QAD_MAT = '"+cMatBsc+"' "
		cQuery += "      AND QAD.D_E_L_E_T_ = ' ' "                                      
		cQuery += " ORDER BY QAD.QAD_FILIAL,QAD.QAD_CUSTO "
		cQuery := ChangeQuery(cQuery) 
									
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QADTRB",.T.,.T.)
		
		//Atualiza o sinalizador no Tipo de Pendencias
		WHILE QADTRB->(!EOF())
			If (nPos:= aScan(aTpPen,{|x| x[POS_aTpPen_TPPEND] == "P"})) > 0 //P - Responsável Departamento
				
				aTpPen[nPos, POS_aTpPen_TEM_DOCUMENTO] := .T.

				If (nPos:= aScan(aPenDoc,{|x| Left(x[POS_PendDoc_TPPEND      ],1) == "P" .And.;
												   x[POS_PendDoc_FILIAL_DPTO ]    == QADTRB->QAD_FILIAL .And.;
												   x[POS_PendDoc_DEPTO       ]    == QADTRB->QAD_CUSTO})) == 0

					aAdd(aPenDoc,{"P  ",QADTRB->QAD_FILIAL,QADTRB->QAD_CUSTO,.T.,"X",INI_CAMPO_ADOCTOS_FIL_MAT,QADTRB->R_E_C_N_O_,QADTRB->QAD_FILIAL,1,'P',"QAD", cFilBsc, cMatBsc, cDepBsc})

				Endif
			Endif
			QADTRB->(DbSkip())
		ENDDO
		DBCLOSEAREA()
		DBSelectArea("QD0")

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Carrega Responsaveis                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
		cQuery := "   SELECT QD0.QD0_FILIAL, QD0.QD0_DOCTO, QD0.QD0_RV, QD0.QD0_AUT, QD0.R_E_C_N_O_ "
		cQuery += "     FROM "+ RetSqlName("QD0")+" QD0 "
		cQuery += "    WHERE QD0.QD0_FILMAT = '"+cFilBsc+"' " 
		cQuery += "      AND QD0.QD0_MAT    = '"+cMatBsc+"' "
		cQuery += "	     AND QD0.QD0_FLAG   <> 'I' "			
		cQuery += "      AND QD0.D_E_L_E_T_ = ' ' "
		cQuery += "  AND NOT EXISTS(SELECT R_E_C_N_O_ "
		cQuery += "                   FROM " + RetSqlName("QDH")+" QDH "
		cQuery += "                  WHERE QD0.QD0_FILIAL = QDH.QDH_FILIAL "
		cQuery += "                    AND QD0.QD0_DOCTO  = QDH.QDH_DOCTO "
		cQuery += "                    AND QD0.QD0_RV     = QDH.QDH_RV "
		If cTrCancel == "2"
			cQuery += "                AND QDH.QDH_OBSOL  = 'S' "
			cQuery += "                AND QDH.QDH_STATUS = 'L' "
		Else
			cQuery += "                AND (QDH.QDH_OBSOL = 'S' OR (QDH.QDH_CANCEL = 'S' AND QDH.QDH_STATUS = 'L')) " 
		Endif
		cQuery += "                    AND QDH.D_E_L_E_T_ = ' ') " 
		cQuery += "      AND QD0.QD0_DOCTO >= '"+aArryPg[POS_TR_DocumentoDE]+"' "
		cQuery += "      AND QD0.QD0_DOCTO <= '"+aArryPg[POS_TR_DocumentoATE]+"' "
		cQuery += "      AND QD0.QD0_RV    >= '"+aArryPg[POS_TR_RevisaoDE]+"' "
		cQuery += "      AND QD0.QD0_RV    <= '"+aArryPg[POS_TR_RevisaoATE]+"' "
		cQuery += " ORDER BY QD0.QD0_FILIAL,QD0.QD0_AUT,QD0.QD0_DOCTO,QD0.QD0_RV "
		cQuery := ChangeQuery(cQuery) 
									
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QD0TRB",.T.,.T.)

		WHILE QD0TRB->(!EOF())
			If ( nPos := aScan(aTpPen,{|x| x[POS_aTpPen_TPPEND] == QD0TRB->QD0_AUT } ) ) > 0

				aTpPen[nPos, POS_aTpPen_TEM_DOCUMENTO] := .T.

				If Ascan(aPenDoc, {|X| X[POS_PendDoc_FILIAL] + X[POS_PendDoc_DOCTO] + X[POS_PendDoc_RV] + SubStr(X[POS_PendDoc_TPPEND],1,1);
									==   QD0TRB->QD0_FILIAL  + QD0TRB->QD0_DOCTO    + QD0TRB->QD0_RV    + QD0TRB->QD0_AUT }) == 0

					aAdd(aPenDoc, { Left(QD0TRB->QD0_AUT+Space( 3 ),3), QD0TRB->QD0_DOCTO, QD0TRB->QD0_RV, .T. ,"B", INI_CAMPO_ADOCTOS_FIL_MAT, QD0TRB->R_E_C_N_O_, QD0TRB->QD0_FILIAL, 1,'',"QD0", cFilBsc, cMatBsc, cDepBsc})
					
				EndIf
			EndIf
			QD0TRB->(DbSkip())
		EndDo
		DBCLOSEAREA()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Carrega os destinatarios que ainda estao com Documentos em Elaboracao ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cQuery :=" SELECT QDG.QDG_FILIAL,QDG.QDG_DOCTO,QDG.QDG_RV,QDG.QDG_FILMAT,QDG.QDG_MAT,QDG.R_E_C_N_O_" 
		cQuery += " FROM " + RetSqlName("QDG")+" QDG ,"+ RetSqlName("QDH")+" QDH " 
		cQuery += " WHERE QDG.QDG_FILMAT = '"+cFilBsc+"' AND QDG.QDG_MAT = '"+cMatBsc+"' AND QDG.QDG_SIT <> 'I' AND"
		cQuery += " QDG.QDG_FILIAL = QDH.QDH_FILIAL AND QDG.QDG_DOCTO = QDH.QDH_DOCTO AND QDG.QDG_RV = QDH.QDH_RV AND"
		If cTrCancel =="2"
			cQuery += " QDH.QDH_OBSOL <> 'S' AND QDH.QDH_STATUS <> 'L  ' AND" 
		Else
			cQuery += " QDH.QDH_OBSOL <> 'S' AND QDH.QDH_CANCEL <> 'S' AND QDH.QDH_STATUS <> 'L  ' AND" 
		Endif
		cQuery += " QDG.D_E_L_E_T_ = ' ' AND QDH.D_E_L_E_T_ = ' ' "
		cQuery += "      AND QDG.QDG_DOCTO >= '"+aArryPg[POS_TR_DocumentoDE]+"' "
		cQuery += "      AND QDG.QDG_DOCTO <= '"+aArryPg[POS_TR_DocumentoATE]+"' "
		cQuery += "      AND QDG.QDG_RV    >= '"+aArryPg[POS_TR_RevisaoDE]+"' "
		cQuery += "      AND QDG.QDG_RV    <= '"+aArryPg[POS_TR_RevisaoATE]+"' "
		cQuery += " ORDER BY QDG.QDG_FILMAT,QDG.QDG_MAT,QDG.QDG_FILIAL,QDG.QDG_DOCTO,QDG.QDG_RV"
		cQuery := ChangeQuery(cQuery) 
								
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QDGTRB",.T.,.T.)
		nTotPenDoc := Len(aPendoc)

		While QDGTRB->(!Eof())
			If Ascan( aPenDoc , {|X| X[POS_PendDoc_FILIAL] + X[POS_PendDoc_DOCTO] + X[POS_PendDoc_RV] + SubStr(X[POS_PendDoc_TPPEND],1,1);
									== QDGTRB->QDG_FILIAL  + QDGTRB->QDG_DOCTO    + QDGTRB->QDG_RV    + "G" }) == 0
				aAdd(aPenDoc , { "G  ", QDGTRB->QDG_DOCTO, QDGTRB->QDG_RV, .T. ,"B",INI_CAMPO_ADOCTOS_FIL_MAT, QDGTRB->R_E_C_N_O_, QDGTRB->QDG_FILIAL, 1,'G', "QDG", cFilBsc, cMatBsc, cDepBsc})
			EndIf
			QDGTRB->(DbSkip())
		EndDo
		aTpPen[POS_RESP_DESTINATARIO, POS_aTpPen_TEM_DOCUMENTO] := IIf(Len(aPenDoc) > nTotPenDoc, .T., .F.)
		
		DBCLOSEAREA()			
		DbSelectArea( "QDG" )			   	

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Carrega os avisos que ainda estao pendentes com Documentos     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cQuery := " SELECT QDS.QDS_FILIAL,QDS.QDS_DOCTO,QDS.QDS_RV,QDS.QDS_FILMAT,QDS.QDS_MAT,QDS_PENDEN,QDS_TPPEND,QDS_DTGERA,QDS_HRGERA,QDS_CHAVE,QDS.R_E_C_N_O_" 
		cQuery += ",QDS_DOCREF ,QDS_RVREF "
		cQuery += " FROM " + RetSqlName("QDS")+" QDS "
		cQuery += " WHERE "					
		cQuery += " QDS.QDS_FILMAT = '"+cFilBsc+"' AND QDS.QDS_MAT = '"+cMatBsc+"' AND QDS.QDS_DEPTO ='"+cDepBsc+"' AND "
		cQuery += " QDS.QDS_SIT <> 'I' AND QDS.QDS_PENDEN ='P' AND QDS.D_E_L_E_T_ = ' ' "
		cQuery += " AND QDS.QDS_DOCTO  >= '"+aArryPg[POS_TR_DocumentoDE]+"' "
		cQuery += " AND QDS.QDS_DOCTO  <= '"+aArryPg[POS_TR_DocumentoATE]+"' "
		cQuery += " AND QDS.QDS_RV     >= '"+aArryPg[POS_TR_RevisaoDE]+"' "
		cQuery += " AND QDS.QDS_RV     <= '"+aArryPg[POS_TR_RevisaoATE]+"' "
		cQuery += " AND QDS.QDS_DTGERA >= '"+DtoS(aArryPg[POS_TR_DataDE])+"' "
		cQuery += " AND QDS.QDS_DTGERA <= '"+DtoS(aArryPg[POS_TR_DataATE])+"' "
		cQuery += " ORDER BY "+SqlOrder("QDS_FILIAL+QDS_DOCTO+QDS_RV+QDS_PENDEN+QDS_TPPEND+QDS_CHAVE")

		cQuery := ChangeQuery(cQuery) 
					
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QDSTRB",.T.,.T.)

		TcSetField("QDSTRB","QDS_DTGERA","D")					
		nTotPenDoc := Len(aPendoc)

		While !Eof()
			If (nPos:= aScan(aPenDoc,{|x| x[POS_PendDoc_TPPEND] == "S  " .And.;
										  x[POS_PendDoc_FILIAL] == QDSTRB->QDS_FILIAL .And.;
										  x[POS_PendDoc_DOCTO ] == QDSTRB->QDS_DOCTO  .And.;
										  x[POS_PendDoc_RV    ] == QDSTRB->QDS_RV })) == 0
				aAdd(aPenDoc , { "S  ",QDSTRB->QDS_DOCTO,QDSTRB->QDS_RV,.T.,QDSTRB->QDS_PENDEN,INI_CAMPO_ADOCTOS_FIL_MAT,QDSTRB->R_E_C_N_O_,QDSTRB->QDS_FILIAL,1,'S', "QDS", cFilBsc, cMatBsc, cDepBsc})
			EndIf
				
			aAdd( aAvisos, { QDSTRB->QDS_FILIAL, QDSTRB->QDS_DOCTO, QDSTRB->QDS_RV,QDSTRB->QDS_PENDEN,DTOS(QDSTRB->QDS_DTGERA)+" "+QDSTRB->QDS_HRGERA,QDSTRB->QDS_TPPEND , QDSTRB->QDS_CHAVE,QDSTRB->QDS_DOCREF,QDSTRB->QDS_RVREF })									

			QDSTRB->(DbSkip())
		EndDo

		aTpPen[POS_RESP_AVISO, POS_aTpPen_TEM_DOCUMENTO] := IIf(Len(aPenDoc) > nTotPenDoc, .T., .F.)
		
		DBCLOSEAREA()			
		DbSelectArea( "QDS" )			   	

	Next

	QD1->(DbSetOrder(1))
	QAD->(DbSetOrder(1))
			
	If Len(aPenDoc) > 0
		aPenDoc := aSort(aPenDoc,,,{ |x,y| x[POS_PendDoc_TPPEND] + x[POS_PendDoc_FILIAL] + x[POS_PendDoc_DOCTO] + x[POS_PendDoc_RV] ;
										 < y[POS_PendDoc_TPPEND] + y[POS_PendDoc_FILIAL] + y[POS_PendDoc_DOCTO] + y[POS_PendDoc_RV] } )
	Endif

	// Atualiza o Array dos Documento relacionados por Tipo de Documento                 ³
	For nIndice := 1 To Len(aTpPen)
		Self:carregaDocumentosEmTela(@oDoctos,@aDoctos,@aPenDoc,aTpPen,nIndice,nItem4,.T.,,aAvisos,@oAvisos,@aAviAux)
	Next nIndice

	//Atualiza o status de pendencias D/E que tenham criticas pendentes
	If Len(aPenDoc) > 0
		aPenCri := {} // Reinicializa o vetor para apagar dados das transf. anteriores

		For nI := 1 To Len(aPenDoc)
			If QA010CRP(aPenDoc[nI,POS_PendDoc_FILIAL],;
						aPenDoc[nI,POS_PendDoc_DOCTO] ,;
						aPenDoc[nI,POS_PendDoc_RV]    ,;
						aPenDoc[nI,POS_PendDoc_TPPEND],;
						aPenDoc[nI,POS_PendDoc_FILMAT],;
						aPenDoc[nI,POS_PendDoc_MAT]   ,;
						aPenDoc[nI,POS_PendDoc_DEPMAT] )
				aPenDoc[nI,5] := "P"	// Altera o status da pendencia para pendente
				aAdd(aPenCri,nI)		// Salva a posicao do item alterado
			EndIf
		Next
	EndIf

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FQAXA010Doc³ Autor ³ Aldo Marini Junior  ³ Data ³ 15.05.00 ³±±
±±³            carregaDocumentosEmTela                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Carrega Documentos em Tela                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   carregaDocumentosEmTela(...)                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 - Objeto do ListBox de Doctos                        ³±±
±±³          ³ ExpA1 - Array contendo os Lancamentos dos Documentos       ³±±
±±³          ³ ExpA2 - Array contendo os Lancamentos dos Tp de Pendenc    ³±±
±±³          ³ ExpA3 - Array contendo os Tipos de Pendencias              ³±±
±±³          ³ ExpN1 - Numerico contendo posicao atual do Tp Pendencia    ³±±
±±³          ³ ExpN2 - Numerico contendo o Tp Pendencia-Ambas/Baix/Pend   ³±±
±±³          ³ ExpL1 - Logico indicando se ira carregar no inicio prg     ³±±
±±³          ³ ExpL2 - Logico indicando Filtro por Status Pen/Baix/Amb    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Method carregaDocumentosEmTela(oDoctos, aDoctos, aPenDoc, aTpPen, nPosTp, nItem4, lCarrega, lTpPen, aAvisos, oAvisos, aAviAux) CLASS QAXA010AuxClass

	Local aArDoc      := {}
	Local aAvisAx     := {}
	Local aPendAx     := {}
	Local cChave      := If(nItem4 == 1, "", If(nItem4==2, "B", "P"))
	Local cTitulo     := INI_CAMPO_ADOCTOS_TIT_DOCT
	Local nPos        := 1
	Local nPosA       := 1
	Local nX          := 0
	Local nY          := 1

	Default lCarrega:= .F.
	Default lTpPen  := .F.

	aDoctos := {}
	aPendAx := {}
	aAvisAx := {}

	If lVldPer

		// Filtrando os registros de Documentos escolhidos pelo usuário na tela de abertura De Até
		For nX := 1 To Len(aPenDoc)
			If !(AScan(aFltDoc, {|X| X[1]+X[2] == aPenDoc[nX][2]+aPenDoc[nX][3] }) == 0)
				Aadd(aPendAx,aPenDoc[nX])
			Endif
		Next

		// Filtrando os registros de Avisos com base nos Documentos escolhidos pelo usuário na tela de abertura De Até
		For nX := 1 To Len(aAvisos)
			If !(AScan(aFltDoc, {|X| X[1]+X[2] == aAvisos[nX][2]+aAvisos[nX][3] }) == 0)
				Aadd(aAvisAx,aAvisos[nX])
			Endif
		Next
	Else
		aPendAx := aClone(aPenDoc)
		aAvisAx := aClone(aAvisos)
	Endif

	If Len(aPendAx) > 0
		If lTpPen
			For nY := 1 to Len(aTpPen)
				aTpPen[nY, POS_aTpPen_TEM_DOCUMENTO] := .F.
			Next
		Else
			nPosA := aScan(aPendAx, { |x| Left(x[POS_PendDoc_TPPEND],1) == aTpPen[nPosTp, POS_aTpPen_TPPEND] } )
			nPosA := If(nPosA == 0,Len(aPendAx),nPosA)
		Endif

		For nY := nPosA to Len(aPendAx)
			cTipoDoc := Posicione('QDH', 1, aPendAx[nY, POS_PendDoc_FILIAL]+aPendAx[nY, POS_PendDoc_DOCTO]+aPendAx[nY, POS_PendDoc_RV], 'QDH_CODTP')
			If Left(aPendAx[nY, POS_PendDoc_TPPEND],1) == "P"
				If Left(aPendAx[nY, POS_PendDoc_TPPEND],1) == aTpPen[nPosTp, POS_aTpPen_TPPEND]
					
					cTitulo := INI_CAMPO_ADOCTOS_TIT_DOCT

					QAD->(DbSetOrder(1))
					If QAD->(DbSeek(If(FWModeAccess("QAD")=="E",aPendAx[nY, POS_PendDoc_DOCTO],Space(FWSizeFilial()))+aPendAx[nY, POS_PendDoc_RV]))
						cTitulo := QAD->QAD_DESC
					Endif

					aAdd(aDoctos, {aPendAx[nY, POS_PendDoc_MARK           ]                                      ,;
					               .F.                                                                           ,;
								   cTipoDoc                                                                      ,;
								   aPendAx[nY, POS_PendDoc_DEPTO          ]                                      ,;
								   aPendAx[nY, POS_PendDoc_FILIAL_DPTO    ]                                      ,;
								   cTitulo                                                                       ,;
								   Self:retornaUsuarioENomeDestinatario(aTpPen[nPosTp, POS_aTpPen_DESTINATARIO]  ,;
								                                        aPendAx[nY, POS_PendDoc_POR_DOC_FIL_MAT]),;
								   aPendAx[nY, POS_PendDoc_POR_DOC_FIL_MAT]                                      ,;
								   aPendAx[nY, POS_PendDoc_FILIAL         ]                                      ,;
								   aPendAx[nY, POS_PendDoc_TPPEND         ]                                      ,;
								   aPendAx[nY, POS_PendDoc_RECNO          ]                                      ,;
								   aPendAx[nY, POS_PendDoc_PENDEN2        ] })

					aTail(aDoctos)[POS_ADOCTOS_LEGENDA]      := !Empty(aTail(aDoctos)[POS_ADOCTOS_MAT_NOM])
					aTpPen[nPosTp, POS_aTpPen_TEM_DOCUMENTO] := .T.
				Endif
			Else
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica se ja esta fora do Tipo de Pendencia e finaliza para agilizar ListBox    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !lTpPen .And. Left(aPendAx[nY, POS_PendDoc_TPPEND],1) <> aTpPen[nPosTp, POS_aTpPen_TPPEND]
					Exit
				Endif
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Atualiza o sinalizador no Tipo de Pendencias                                      ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lTpPen
					If ( nPos := aScan(aTpPen,{|x| x[POS_aTpPen_TPPEND] == Left(aPendAx[nY, POS_PendDoc_TPPEND],1) } ) ) > 0 .And. ;
						( Empty(cChave)                           .Or.;
						  aPendAx[nY, POS_PendDoc_PENDEN1] == "X" .Or.;
						(!Empty(cChave) .And. aPendAx[nY, POS_PendDoc_PENDEN1] == cChave ))
						aTpPen[nPos, POS_aTpPen_TEM_DOCUMENTO] := .T.
					Endif
					If Left(aPendAx[nY, POS_PendDoc_TPPEND],1) <> aTpPen[nPosTp, POS_aTpPen_TPPEND]
						Loop
					Endif
				Endif

				If !Empty(cChave) .And. aPendAx[nY, POS_PendDoc_PENDEN1] <> cChave .And. aPendAx[nY, POS_PendDoc_PENDEN1] <> "X"
					Loop
				Endif

				If !Empty(cChave) .And. aPendAx[nY,9] == 0
					Loop
				EndIf

				If aPendAx[nY,9] == 0
					Loop
				EndIf

				cTitulo := INI_CAMPO_ADOCTOS_TIT_DOCT

				If QDH->(dbSeek(aPendAx[nY,8]+aPendAx[nY,2]+aPendAx[nY,3]))
					cTitulo := QDH->QDH_TITULO
				Endif

				If aScan(aDoctos,{|x| X[POS_ADOCTOS_COD_DOC]+X[POS_ADOCTOS_REV_DOC]+X[POS_ADOCTOS_TIT_DOC]+X[6]+X[POS_ADOCTOS_FIL_PEN]+X[POS_ADOCTOS_TIP_PEN]+X[POS_ADOCTOS_STATUS] == aPendAx[nY,2]+aPendAx[nY,3]+cTitulo+aPendAx[nY,6]+aPendAx[nY,8]+aPendAx[nY,1]+aPendAx[nY,10]}) == 0

					aAdd(aDoctos,{ aPendAx[nY, POS_PendDoc_MARK           ]                                     ,;
					               .F.                                                                          ,;
								   cTipoDoc                                                                     ,;
								   aPendAx[nY, POS_PendDoc_DOCTO          ]                                     ,;
								   aPendAx[nY, POS_PendDoc_RV             ]                                     ,;
								   cTitulo                                                                      ,;
								   Self:retornaUsuarioENomeDestinatario(aTpPen[nPosTp,POS_aTpPen_DESTINATARIO ] ,;
								                                        aPendAx[nY,POS_PendDoc_POR_DOC_FIL_MAT]),;
								   aPendAx[nY, POS_PendDoc_POR_DOC_FIL_MAT]                                     ,;
								   aPendAx[nY, POS_PendDoc_FILIAL         ]                                     ,;
								   aPendAx[nY, POS_PendDoc_TPPEND         ]                                     ,;
								   aPendAx[nY, POS_PendDoc_RECNO          ]                                     ,;
								   aPendAx[nY, POS_PendDoc_PENDEN2        ] })

					aTail(aDoctos)[POS_ADOCTOS_LEGENDA]      := !Empty(aTail(aDoctos)[POS_ADOCTOS_MAT_NOM])
					aTpPen[nPosTp, POS_aTpPen_TEM_DOCUMENTO] := .T.
				EndIf
			Endif
		Next
	Endif

	If Len(aDoctos) == 0
		aAdd(aDoctos,{.F.,;
					  .F.,;
					  INI_CAMPO_ADOCTOS_TIPO_DOC,;
					  INI_CAMPO_ADOCTOS_DOCUMENT,;
					  INI_CAMPO_ADOCTOS_REV_DOCT,;
					  OemToAnsi(STR0089) + Space(Len(INI_CAMPO_ADOCTOS_TIT_DOCT)-Len(OemToAnsi(STR0089))),;
					  INI_CAMPO_ADOCTOS_MAT_NOME,;
					  INI_CAMPO_ADOCTOS_FIL_MAT,;
					  INI_CAMPO_ADOCTOS_FIL_PEND,;
					  INI_CAMPO_ADOCTOS_TP_PENDE,;
					  0,;
					  "P" })
		aTpPen[nPosTp,2] := .F.
	Endif

	aDoctos:= aSort(aDoctos,,,{ |x,y| x[POS_ADOCTOS_COD_DOC] + x[POS_ADOCTOS_REV_DOC] < y[POS_ADOCTOS_COD_DOC] + y[POS_ADOCTOS_REV_DOC] } )

	// Filtrando os documentos
	For nX := 1 To Len(aDoctos)
		If nX == 1 
			Aadd(aArDoc,aDoctos[nX])
		Else
			If !(AScan(aFltDoc, {|X| X[1]+X[2] == aDoctos[nX][POS_ADOCTOS_COD_DOC]+aDoctos[nX][POS_ADOCTOS_REV_DOC] }) == 0)
				Aadd(aArDoc,aDoctos[nX])
			Endif
		Endif
	Next

	If !lCarrega
		oDoctos:aHeaders:=IF(nPosTp == 8,aHeadRes,aHeadDoc)
		oDoctos:nAt:= 1
		oDoctos:SetArray(aArDoc)
		oDoctos:bLine := { || { If( aArDoc[oDoctos:nAt, POS_ADOCTOS_MARK], hOk, hNo )              ,;
		                       If(aTpPen[oTpPen:nAt, POS_aTpPen_TEM_DOCUMENTO]                     ,;
						         If( aDoctos[ oDoctos:nAt, POS_ADOCTOS_LEGENDA], oVerde, oLaranja ),;
							     oCinza  )                                                         ,;
							   aArDoc[oDoctos:nAt, POS_ADOCTOS_TP_DOC ]                            ,;
							   aArDoc[oDoctos:nAt, POS_ADOCTOS_COD_DOC]                            ,;
							   aArDoc[oDoctos:nAt, POS_ADOCTOS_REV_DOC]                            ,;
							   aArDoc[oDoctos:nAt, POS_ADOCTOS_TIT_DOC]                            ,;
							   aArDoc[oDoctos:nAt, POS_ADOCTOS_MAT_NOM]                             } }

		oDoctos:Refresh()
		// STR0080 - Documentos/Pastas
		// STR0202 - Qtd
		// STR0201 - Vincule o Usuário DESTINO para a Transferência
		oFWLayer:setWinTitle("DOCUMENTOS_COL", "oPanDoc", STR0080 + " - " + STR0202 + ": ("+(Alltrim(Str(IF(aTpPen[nPosTp,2],Len(aArDoc),0))))+")" , "FULL")
		oFWLayer:setWinTitle("DOCUMENTOS_COL", "oPanUsr", STR0201 , "FULL")
		oFWLayer:Refresh() 
	Endif
			
	Self:carregaAvisosEmTela(aTpPen[nPosTp,4]=="S", oDoctos, {aArDoc[1]}, @oAvisos, aAvisAx, @aAviAux, nItem4)

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FQAXA010Fun ³ Autor ³ Aldo Marini Junior  ³ Data ³ 15.05.00 ³±±
±±            atualizaPonteiroUsuario                                      ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Atualiza ponteiro de usuarios                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   atualizaPonteiroUsuario(oUsuarios, cChave)                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ oUsuarios= Objeto contendo os Usuarios                     ³±±
±±³          ³ cChave   = Caracter contendo a chave de pesquisa de usuario³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

METHOD atualizaPonteiroUsuario(oUsuarios, cChave) CLASS QAXA010AuxClass
	
	Local nOrdem:= QAA->(Indexord())

	QAA->(dbSetOrder(1))
	If !QAA->(dbSeek(cChave))
		oUsuarios:GoTop()
	Endif

	oUsuarios:UpStable()
	oUsuarios:Refresh()

	QAA->(dbSetOrder(nOrdem))

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³FQAXA010QAD³ Autor ³Aldo Marini Junior    ³ Data ³ 21/05/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Verifica se existe o Centro de Custo digitado/selecionado   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³FQAXA010QAD(cFilCC,cCodCC,cNDepto)                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³cFilCC - Caracter indicando a Filial destino                ³±±
±±³          ³cCodCC - Caracter indicando o Codigo do C.Custo destino     ³±±
±±³          ³cNDepto- Caracter indicando a descricao do C.Custo destino  ³±±
±±³          ³cCcMatr- Caracter indicando o Codigo do Usuario             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³QAXA010()                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/                      
Static Function FQAXA010QAD(cFilCC,cCodCC,cNDepto,cCcMatr,nItem5)
	Local cFilQAD := xFilial("QAD", cFilCC)
	Local lRet	  := .T.
  
	If cDepAtu == cCodCC .And. cFilAtu == cCcFilial .And. cMatAtu == cCcMatr .And. nItem5 <> 4
		lRet := .F.
	Else
		QAD->(dbSetOrder(1))
		If QAD->(DbSeek( cFilQAD + cCodCC ))
			lRet := .T.
			cNDepto := Padr(QAD->QAD_DESC,30)
		Else
			QAD->(DbGoTop())
			MsgStop( OemToAnsi( STR0029 ), OemToAnsi( STR0011 ) ) // "N„o foi encontrado um registro v lido. Informe outro !" ### "Aten‡„o"
			lRet := .F.
		Endif
	Endif

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QAXA010Leg ³ Autor ³ Aldo Marini Junior   ³ Data ³ 30.03.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cria uma janela contendo a legenda da mBrowse              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QAXA010Leg()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QAXA010 - Siga Quality (Generico)                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QAXA010Leg()

Local aLegenda := { {'ENABLE'    , OemtoAnsi(STR0095) },; // "Usuario normal sem Lactos Pendentes"
                    {'DISABLE'   , OemtoAnsi(STR0096)},;  // "Usuario demitido sem Lactos Pendentes"
                    {'BR_AMARELO', OemtoAnsi(STR0097)},;  // "Usuario normal com Lactos Pendentes"
                    {'BR_AZUL'   , OemtoAnsi(STR0098)},;  // "Usuario Transferido com Lactos Pendentes"
                    {'BR_PRETO'  , OemtoAnsi(STR0099)} }  // "Usuario Demitido com Lactos Pendentes"

BrwLegenda(cCadastro,STR0100 ,aLegenda) 	// "Legenda"

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³FQAXA010Ttf³ Autor ³Aldo Marini Junior    ³ Data ³ 11/07/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Valida a transferencia de lactos em fase de Elaboracao      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³FQAXA010Ttf(nItem3,nItem5,aPenDoc,aTpPen)              	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ExpN1 - Numero identificando a opcao 1-Demissao/2-Transfer. ³±±
±±³          ³ExpN2 - Numero identificando a opcao 1-Fil.C.C./Pendencias  ³±±
±±³          ³ExpN3 - Numero identificando a opcao de Transfer. Pendencias³±±
±±³          ³ExpA1 - Array identificando os Doctos                       ³±±
±±³          ³ExpA2 - Array identificando os Tipos de Doctos              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³QAXA010()                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function FQAXA010Ttf(nItem3,nItem5,aPenDoc,aTpPen,cCCFilial)

	Local lRet    := .T.
	Local nPosQAA := QAA->(RecNo())
	Local cFiltro := QAA->(DbFilter())
	Local nU
	Local nA

	If nItem3 == 1

		If cCCFilial <> xFilial("QAA")

		DbSelectArea("QAA")
		DbClearFilter()

			If QAA->(DbSeek(cCcFilial+cMatAtu))
			Help("",1,"QX10FILDES") // "Usuario ja existe na Filial Destino."
			lRet:= .F.
			EndIf

		Set Filter To &(cFiltro)
		QAA->(DbGoto(nPosQAA))

		EndIf
									

	EndIf

	If lRet .And. Len(aPenDoc) > 0 .And. (nItem5 == 3 .Or. nItem5 == 4)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Buscar lactos Pendentes das etapas:                          ³
		//³ 1-Digitacao ; 2-Elaboracao; 3-Revisao ; 4-Aprovacao ;        ³
		//³ 5-Homologacao ; 6-Distribuicao                               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		For nA := 1 to 6

			If !(aTpPen[nA,1] == .T. .And. aTpPen[nA,2] == .T.)
				Loop
			Endif

			nPosA := aScan(aPenDoc, { |x| Left(x[1],1) == aTpPen[nA,4] } )
			nPosA := If(nPosA == 0,Len(aPenDoc),nPosA)

			For nU := nPosA to Len(aPenDoc)
				If Left(aPenDoc[nU,1],1) <> aTpPen[nA,4]
					Exit
				Endif
			
				If (aPenDoc[nU,4])
					Help("",1,"HELP",,STR0160,1,0,,,,,,{STR0104, ' ', STR0105}) // Somente poderão ser Baixados lançamentos do tipo LEITURA 
					lRet := .F.
					Exit
				Endif
			Next

			If !lRet
				Exit
			Endif

		Next

		// Pendencias tipo aviso
		If aTpPen[POS_RESP_AVISO, POS_aTpPen_MARCACAO] .And. aTpPen[POS_RESP_AVISO, POS_aTpPen_TEM_DOCUMENTO] .And. lRet
			Help(,,"HELP",,STR0160,1,0) // Selecione as Etapas e seus respectivos Documentos com um Usuario destino e tente novamente
			lRet := .F. 		
		Endif
	Endif

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³FQAXA010Log³ Autor ³Eduardo de Souza      ³ Data ³ 31/10/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Grava Log da Transferencia                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³FQAXA010Log(ExpC1,ExpC2,ExpC3,ExpC4,ExpC5,ExpC6,ExpC7,ExpC8,³±±
±±³          ³            ExpC9,ExpC10)                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ExpC1  - Filial do Documento                                ³±±
±±³          ³ExpC2  - Codigo do Documento                                ³±±
±±³          ³ExpC3  - Revisao do Documento                               ³±±
±±³          ³ExpC4  - Tipo de Pendencia                                  ³±±
±±³          ³ExpC5  - Filial do Usuario Transferido                      ³±±
±±³          ³ExpC6  - Matricula do Usuario Transferido                   ³±±
±±³          ³ExpC7  - Departamento do Usuario Transferido                ³±±
±±³          ³ExpC8  - Filial Usuario Destino                             ³±±
±±³          ³ExpC9  - Matricula Usuario Destino                          ³±±
±±³          ³ExpC10 - Departamento Usuario Destino                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³QAXA010()                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function FQAXA010Log(cFilDoc,cDocto,cRv,cTpPend,cFilDe,cMatDe,cDeptoDe,cFilPara,cMatPara,cDeptoPara)

	Local cAlias := Alias()
	Local lGrava := .T.
	Local nOrd   := IndexOrd()

	Default cFilDoc   := Space(FWSizeFilial()) //""
	Default cDocto    := ""
	Default cRv       := ""
	Default cTpPend   := ""
	Default cFilDe    := Space(FWSizeFilial()) //""
	Default cMatDe    := ""
	Default cDeptoDe  := ""
	Default cFilPara  := Space(FWSizeFilial()) //""
	Default cMatPara  := ""
	Default cDeptoPara:= ""

	DbSelectArea("QDR")
	DbSetOrder(1)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Pesquisa Chave unica                                                                                                  ³
	//³QDR_FILIAL+QDR_DOCTO+QDR_RV+QDR_TPPEND+QDR_FILDE+QDR_MATDE+QDR_DEPDE+QDR_FILPAR+QDR_MATPAR+QDR_DEPPAR+DTOS(QDR_DTTRAN)³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IF QDR->(DBSeek(cFilDoc+cDocto+cRv+DTOS(dDataBase))) //QDR_FILIAL+QDR_DOCTO+QDR_RV+DTOS(QDR_DTTRAN)
		While QDR->(!EOF()) .AND. QDR->QDR_FILIAL+QDR->QDR_DOCTO+QDR->QDR_RV+DTOS(QDR->QDR_DTTRAN)==cFilDoc+cDocto+cRv+DTOS(dDataBase)
			IF  QDR->QDR_FILIAL+QDR->QDR_DOCTO+QDR->QDR_RV+Alltrim(QDR->QDR_TPPEND)+;
				QDR->QDR_FILDE+QDR->QDR_MATDE+QDR->QDR_DEPDE+QDR->QDR_FILPAR+QDR->QDR_MATPAR+QDR->QDR_DEPPAR+DTOS(QDR->QDR_DTTRAN)== ;
				cFilDoc+cDocto+cRv+AllTrim(cTpPend)+cFilDe+cMatDe+cDeptoDe+cFilPara+cMatPara+cDeptoPara+DTOS(dDatabase)
			
				lGrava:=.F.
				Exit
				
			Endif
			QDR->(DbSkip())
		Enddo
	Endif

	IF lGrava
		RecLock("QDR",.T.)
		QDR->QDR_FILIAL:= cFilDoc
		QDR->QDR_DOCTO := cDocto
		QDR->QDR_RV    := cRv
		QDR->QDR_DTTRAN:= dDataBase
		QDR->QDR_TPPEND:= cTpPend
		QDR->QDR_MOTIVO:= cMotTransf
		QDR->QDR_FILRES:= cMatFil
		QDR->QDR_MATRES:= cMatCod
		QDR->QDR_DEPRES:= cMatDep
		QDR->QDR_FILDE := cFilDe
		QDR->QDR_MATDE := cMatDe
		QDR->QDR_DEPDE := cDeptoDe
		QDR->QDR_FILPAR:= cFilPara
		QDR->QDR_MATPAR:= cMatPara
		QDR->QDR_DEPPAR:= cDeptoPara
		MsUnlock()		
		FKCOMMIT()														
	Endif
		
	DbSelectArea(cAlias)
	DbSetOrder(nOrd)

Return 

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³QA010DlgJus³ Autor ³Eduardo de Souza      ³ Data ³ 01/11/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Tela de Justificativa                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³QA010DlgJus()   				                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³QAXA010()                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QA010DlgJus(oDlg)

Local oMotTransf
Local lGrava:= .F.

DEFINE MSDIALOG oDlgTransf TITLE OemToAnsi(STR0106) FROM 150,000 TO 230,280 OF oDlg PIXEL

@ 005,005 MSGET oMotTransf VAR cMotTransf SIZE 130,010 OF oDlgTransf PIXEL

DEFINE SBUTTON FROM 021,075 TYPE 1 ENABLE OF oDlgTransf;
   ACTION  (If(NaoVazio(cMotTransf),(lGrava := .T.,oDlgTransf:End()),));

DEFINE SBUTTON FROM 021,105 TYPE 2 ENABLE OF oDlgTransf;
   ACTION  (lGrava := .F.,oDlgTransf:end());

ACTIVATE MSDIALOG oDlgTransf CENTERED 

Return lGrava

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³ QAX010VdEx ³ Autor ³ Eduardo de Souza    ³ Data ³ 25/03/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Valida Exclusao de Usuarios                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QAX010VdEx()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QAXA010 - Siga Quality (Generico)                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QAX010VdEx()

	Local nOrd01  := 0
	Local cIndex  := ""
	Local cKey    := ""
	Local cFiltro := ""
	Local lApaga  := .T. 
	Local QTD	  := 0

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ RESPONSAVEIS                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lApaga
		cQuery := "Select Count (*)  QTD" 
		cQuery += " From " + RetSqlName("QD0") + " QD0 "
		cQuery += " Where QD0.QD0_FILMAT = '" + QAA->QAA_FILIAL + "' and "
		cQuery += "       QD0.QD0_MAT = '" + QAA->QAA_MAT + "' and "
		cQuery += "       QD0.D_E_L_E_T_ = ' '"

		cQuery := ChangeQuery(cQuery)

		If Qtd > 0
			lApaga := .F.
		Endif
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ PENDENCIAS                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lApaga
		cQuery := "Select Count (*)  QTD" 
		cQuery += " From " + RetSqlName("QD1") + " QM6 "
		cQuery += " Where QD1.QD1_FILMAT = '" + QAA->QAA_FILIAL + "' and "
		cQuery += "       QD1.QD1_MAT = '" + QAA->QAA_MAT + "' and "
		cQuery += "       QD1.D_E_L_E_T_ = ' '"
		
		cQuery := ChangeQuery(cQuery)
		
		If Qtd > 0
			lApaga := .F.
		Endif
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ JUSTIFICATIVAS POR DOCUMENTO                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lApaga
		nOrd01:= QD7->(IndexOrd())	
		DbSelectarea("QD7")
		cIndex  := CriaTrab(Nil,.F.)
		cKey    := "QD7_FILMAT+QD7_MAT"
		cFiltro := "QD7->QD7_FILMAT+QD7->QD7_MAT == '"+QAA->QAA_FILIAL+QAA->QAA_MAT+"'"
		IndRegua("QD7",cIndex,cKey,,cFiltro,OemToAnsi(STR0114)) //"Validando Exclusao..."
		If QD7->(!Eof())
			lApaga:= .F.
		EndIf
		RetIndex("QD7")
		DbClearFilter()
		cIndex += OrDbagExt()
		Delete File &(cIndex)
		QD7->(DbSetOrder(nOrd01))
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ TREINAMENTOS CARGOxDEPTOxUSUAR                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lApaga
		nOrd01:= QD8->(IndexOrd())	
		DbSelectarea("QD8")
		cIndex  := CriaTrab(Nil,.F.)
		cKey    := "QD8_FILMAT+QD8_MAT"
		cFiltro := "QD8->QD8_FILMAT+QD8->QD8_MAT == '"+QAA->QAA_FILIAL+QAA->QAA_MAT+"'"
		IndRegua("QD8",cIndex,cKey,,cFiltro,OemToAnsi(STR0114)) //"Validando Exclusao..."
		If QD8->(!Eof())
			lApaga:= .F.
		EndIf
		RetIndex("QD8")
		DbClearFilter()
		cIndex += OrDbagExt()
		Delete File &(cIndex)
		QD8->(DbSetOrder(nOrd01))
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SUGESTOES						                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lApaga
		nOrd01:= QD9->(IndexOrd())	
		DbSelectarea("QD9")
		cIndex  := CriaTrab(Nil,.F.)
		cKey    := "QD9_FILMAT+QD9_MAT"
		cFiltro := "QD9->QD9_FILMAT+QD9->QD9_MAT == '"+QAA->QAA_FILIAL+QAA->QAA_MAT+"'"
		IndRegua("QD9",cIndex,cKey,,cFiltro,OemToAnsi(STR0114)) //"Validando Exclusao..."
		If QD9->(!Eof())
			lApaga:= .F.
		EndIf
		RetIndex("QD9")
		DbClearFilter()
		cIndex += OrDbagExt()
		Delete File &(cIndex)
		QD9->(DbSetOrder(nOrd01))
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ TREINAMENTO      				                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lApaga
		nOrd01:= QDA->(IndexOrd())	
		DbSelectarea("QDA")
		cIndex  := CriaTrab(Nil,.F.)
		cKey    := "QDA_FILF1+QDA_MAT1"
		cFiltro := "(QDA->QDA_FILF1+QDA->QDA_MAT1 == '"+QAA->QAA_FILIAL+QAA->QAA_MAT+"' .Or. "
		cFiltro += "QDA->QDA_FILF2+QDA->QDA_MAT2 == '"+QAA->QAA_FILIAL+QAA->QAA_MAT+"' .Or. "
		cFiltro += "QDA->QDA_FILF3+QDA->QDA_MAT3 == '"+QAA->QAA_FILIAL+QAA->QAA_MAT+"')"
		IndRegua("QDA",cIndex,cKey,,cFiltro,OemToAnsi(STR0114)) //"Validando Exclusao..."
		If QDA->(!Eof())
			lApaga:= .F.
		EndIf
		RetIndex("QDA")
		DbClearFilter()
		cIndex += OrDbagExt()
		Delete File &(cIndex)
		QDA->(DbSetOrder(nOrd01))
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ DESTINATARIOS    				                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lApaga
		nOrd01:= QDG->(IndexOrd())	
		QDG->(DbSetOrder(8))
		If QDG->(DbSeek(QAA->QAA_FILIAL+QAA->QAA_MAT))
			lApaga:= .F.
		EndIf
		QDG->(DbSetOrder(nOrd01))
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ DOCUMENTOS       				                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lApaga
		cQuery := "Select Count (*)  QTD" 
		cQuery += " From " + RetSqlName("QDH") + " QM6 "
		cQuery += " Where QDH.QDH_FILMAT = '" + QAA->QAA_FILIAL + "' and "
		cQuery += "       QDH.QDH_MAT = '" + QAA->QAA_MAT + "' and "
		cQuery += "       QDH.D_E_L_E_T_ = ' '"

		cQuery := ChangeQuery(cQuery)

		If Qtd > 0
			lApaga := .F.
		Endif
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ REGISTRO ASSINATURA DE USRS.	                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lApaga
		nOrd01:= QDN->(IndexOrd())	
		DbSelectarea("QDN")
		cIndex  := CriaTrab(Nil,.F.)
		cKey    := "QDN_FILIAL+QDN_MAT"
		cFiltro := "QDN->QDN_FILIAL+QDN->QDN_MAT == '"+QAA->QAA_FILIAL+QAA->QAA_MAT+"'"
		IndRegua("QDN",cIndex,cKey,,cFiltro,OemToAnsi(STR0114)) //"Validando Exclusao..."
		If QDN->(!Eof())
			lApaga := .F.
		EndIf
		RetIndex("QDN")
		DbClearFilter()
		cIndex += OrDbagExt()
		Delete File &(cIndex)
		QDN->(DbSetOrder(nOrd01))
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SOLICITACOES                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lApaga
		nOrd01:= QDP->(IndexOrd())	
		DbSelectarea("QDP")
		cIndex  := CriaTrab(Nil,.F.)
		cKey    := "QDP_FILIAL+QDP_MAT"
		cFiltro := "(QDP->QDP_FILIAL+QDP->QDP_MAT == '"+QAA->QAA_FILIAL+QAA->QAA_MAT+"' .Or. "
		cFiltro += "QDP->QDP_FMATBX+QDP->QDP_MATBX == '"+QAA->QAA_FILIAL+QAA->QAA_MAT+"')"
		IndRegua("QDP",cIndex,cKey,,cFiltro,OemToAnsi(STR0114)) //"Validando Exclusao..."
		If QDP->(!Eof())
			lApaga:= .F.
		EndIf
		RetIndex("QDP")
		DbClearFilter()
		cIndex += OrDbagExt()
		Delete File &(cIndex)
		QDP->(DbSetOrder(nOrd01))
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ AVISOS          				                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lApaga
		nOrd01:= QDS->(IndexOrd())	
		QDS->(DbSetOrder(1))
		If QDS->(DbSeek(QAA->QAA_FILIAL+QAA->QAA_MAT))
			Return .F.
		EndIf
		QDS->(DbSetOrder(nOrd01))
	EndIf
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ DEPARTAMENTOS (Responsavel)                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lApaga
		nOrd01:= QAD->(IndexOrd())	
		QAD->(DbSetOrder(2))
		If QAD->(DBSeek(QAA->QAA_FILIAL+QAA->QAA_MAT))
			Return .F.
		EndIf
		QAD->(DbSetOrder(nOrd01))
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ VALIDA RELACIONAMENTOS DAS TABELAS DA NG INFORMATICA³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lApaga
		If !NGVALSX9("QAA")
			dbSelectArea("QAD")
			dbSetOrder(1)
			Return .F.
		Else
			dbSelectArea("QAD")
			dbSetOrder(1)
		Endif
	Endif
Return lApaga

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³FQAXA010USU³ Autor ³Aldo Marini Junior      ³ Data ³ 21/05/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Verifica se existe o Centro de Custo digitado/selecionado     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³FQAXA010USU(CcFilial,cCcMatr)                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³cCcFilial - Caracter indicando a Filial destino               ³±±
±±³          ³cCcMatr   - Caracter indicando a Matricula usuario destino    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³QAXA010()                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/                      
Static Function FQAXA010USU(cCcFilial,cCcMatr)

	Local lRet    := .T.
	Local nPosQAA := QAA->(RecNo())
	Local cFiltro := QAA->(DbFilter())

	If (cFilAtu <> cCcFilial)

		DbSelectArea("QAA")
		DbClearFilter()
		
		If QAA->(DbSeek(cCcFilial+cCcMatr))
			Help("",1,"QX10FILDES") // "Usuario ja existe na Filial Destino."
			lRet:= .F.
		EndIf
	
		Set Filter To &(cFiltro)
		QAA->(DbGoto(nPosQAA))

	EndIf

Return( lRet )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QAX10MarU ºAutor  ³Telso Carneiro      º Data ³  14/05/2004 º±±
±±º           vinculaUsuario                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³   VINCULA / DESVINCULA USUARIOS		                      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BUTTON  oMarcar                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Method vinculaUsuario(lPorDocto, aDoctos, oDoctos, aPenDoc, oTpPen, aTpPen, cFilAtu, cMatAtu, aAvisos) CLASS QAXA010AuxClass

	Local lRet        := .T.
	Local nPosT       := 0

	If Self:verificaSeUsuariosPossuemPendenciasDeDevolucaoDeRevisaoAnterior(aDoctos, cFilAtu, cMatAtu, QAA->QAA_FILIAL, QAA->QAA_MAT)

		//STR0178 - "Devolução de Revisão Anterior"
		//STR0179 - "Usuários origem e destino possuem pendências de devolução do mesmo documento físico."
		//STR0180 - "Realize a devolução do documento por meio da rotina QDOA060 ou transfira a(s) pendência(s) para outro usuário."
		Help(NIL, NIL, STR0178, NIL, STR0179, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0180})
		lRet := .F.

	EndIf

	//Verifica a Existencia de Ausencia Temporia para o Usuario Destino
	IF lRet .AND. oTpPen:nAt <= 6 //Todos os Tipos de Pendencia ate Distribuicao

		//Verifica a Existencia de Ausencia Temporia para o Usuario Destino
		IF QA_SitAuDP(QAA->QAA_FILIAL,QAA->QAA_MAT,aTpPen[oTpPen:nAt,4])
			Help(" ",1,"QX040JEAP",,aTpPen[oTpPen:nAt,3]+" (" + Alltrim(QAA->QAA_MAT) + "-" + AllTrim(QA_NUSR(QAA->QAA_FILIAL,QAA->QAA_MAT)) + ")",05,00) // "Ja existe Ausencia Temporaria cadastrada no Periodo para este Usuario."
			lRet  := .F.
		Endif
		IF lRet

			//Verifica a Existencia de Ausencia Temporia para o Usuario Origem
			IF QA_SitAuDP(cFilAtu,cMatAtu,aTpPen[oTpPen:nAt,4])
				Help(" ",1,"QX040JEAP",,aTpPen[oTpPen:nAt,3]+" (" + Alltrim(cMatAtu) + "-" + AllTrim(QA_NUSR(cFilAtu,cMatAtu)) + ")",05,00) // "Ja existe Ausencia Temporaria cadastrada no Periodo para este Usuario."
				lRet  := .F.
			Endif
			IF lRet

				//Verifica o Usurio que vai receber a pendencia de Distribuicao e DISTSN (SIM)
				IF aTpPen[oTpPen:nAt,4]=="I" .AND. QAA->QAA_DISTSN =="2"
					MsgAlert(OemToAnsi(STR0128),OemToAnsi(STR0127)) //"O usuário informado para pendencia de Distribuição NÃO está indicado como um distribuidor no cadastro !"###"Atencao"
					lRet  := .F.
				Endif

				//Verifica se a Distribuição pode ser executada para o Usuario Destino
				If oTpPen:nAt == 6 .and. !lPorDocto .And. lRet
					lRet := QAX10SDoc(QAA->QAA_FILIAL,QAA->QAA_MAT,QAA->QAA_CC,cFilAtu,cMatAtu,cDepAtu,aDoctos)
					If !lRet
						aTpPen[6,1] := .F.
					EndIf
				EndIf
			Endif
		Endif
	Endif

	IF lRet
		If lPorDocto
			If Empty(aDoctos[oDoctos:nAt,POS_ADOCTOS_FIL_MAT]) .OR.;
				(!Empty(aTpPen[oTpPen:nAt,POS_aTpPen_DESTINATARIO]) .And. aDoctos[oDoctos:nAt,POS_ADOCTOS_MAT_NOM] != Self:retornaUsuarioENomeDestinatario(aTpPen[oTpPen:nAt,POS_aTpPen_DESTINATARIO], ""))
				
				lRet := QAX10SDoc(QAA->QAA_FILIAL,QAA->QAA_MAT,QAA->QAA_CC,cFilAtu,cMatAtu,cDepAtu,aDoctos,oDoctos,lPorDocto)
				aTpPen[POS_RESP_DISTRIBUICAO, POS_aTpPen_MARCACAO] := If (oTpPen:nAt == POS_RESP_DISTRIBUICAO, lRet, aTpPen[POS_RESP_DISTRIBUICAO, POS_aTpPen_MARCACAO])

				aDoctos[oDoctos:nAt,POS_ADOCTOS_FIL_MAT] := (QAA->QAA_FILIAL+QAA->QAA_MAT)
				aDoctos[oDoctos:nAt,POS_ADOCTOS_MAT_NOM] := AllTrim(QAA->QAA_MAT)+"/"+Alltrim(QAA->QAA_NOME)
				
			Else

				aDoctos[oDoctos:nAt,POS_ADOCTOS_FIL_MAT] := SPACE(TAMSX3("QAA_FILIAL")[1]+TAMSX3("QAA_MAT")[1])
				If Empty(aTpPen[oTpPen:nAt,POS_aTpPen_DESTINATARIO])
					aDoctos[oDoctos:nAt,POS_ADOCTOS_MAT_NOM] := INI_CAMPO_ADOCTOS_MAT_NOME
				Else
					aDoctos[oDoctos:nAt,POS_ADOCTOS_MAT_NOM] := Self:retornaUsuarioENomeDestinatario(aTpPen[oTpPen:nAt,POS_aTpPen_DESTINATARIO], "")
				EndIf
			Endif

			aDoctos[oDoctos:nAt,POS_ADOCTOS_LEGENDA] := !Empty(aDoctos[oDoctos:nAt,POS_ADOCTOS_MAT_NOM])

			nPosT := 0
			nPosT := aScan(aPenDoc,{|x| x[1] == aDoctos[oDoctos:nAt,POS_ADOCTOS_TIP_PEN] .And. x[7] == aDoctos[oDoctos:nAt,POS_ADOCTOS_RECNO] }) // Verifica Tipo de Pend. e Recno devido a fonte diversificada do recno
			aPenDoc[nPosT,POS_PendDoc_POR_DOC_FIL_MAT] := If(nPosT > 0 .And. (!Empty(aDoctos[oDoctos:nAt,POS_ADOCTOS_FIL_MAT]) .Or. QAA->QAA_FILIAL+QAA->QAA_MAT <> cFilAtu+cMatAtu), QAA->QAA_FILIAL+QAA->QAA_MAT, INI_CAMPO_ADOCTOS_FIL_MAT)
		Else
			IF Empty(aTpPen[oTpPen:nAt,POS_aTpPen_DESTINATARIO]) .OR.;
				aTpPen[oTpPen:nAt,POS_aTpPen_DESTINATARIO] != (QAA->QAA_FILIAL+QAA->QAA_MAT)
				
				aTpPen[oTpPen:nAt,POS_aTpPen_DESTINATARIO] := (QAA->QAA_FILIAL+QAA->QAA_MAT)
				aEval(aDoctos,{|x| Iif(Empty(x[POS_ADOCTOS_FIL_MAT]),;
										(x[POS_ADOCTOS_MAT_NOM]  := AllTrim(QAA->QAA_MAT)+"/"+Alltrim(QAA->QAA_NOME),;
											x[POS_ADOCTOS_LEGENDA]  := .T. );
										,"")})

			Else
				aTpPen[oTpPen:nAt,POS_aTpPen_DESTINATARIO] := SPACE(TAMSX3("QAA_FILIAL")[1]+TAMSX3("QAA_MAT")[1])
				aEval(aDoctos,{|x| Iif(Empty(x[POS_ADOCTOS_FIL_MAT]),;
										(x[POS_ADOCTOS_MAT_NOM]  := INI_CAMPO_ADOCTOS_MAT_NOME,;
											x[POS_ADOCTOS_LEGENDA]  := .F. );
										,"")})

			Endif

			oTpPen:SetArray(aTpPen)
			oTpPen:bLine := Self:retornaBLineTipoPendencia()
			oTpPen:Refresh()
		Endif
		oDoctos:Refresh()
	Endif

Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QAX10MarT ºAutor  ³Telso Carneiro      º Data ³  14/05/2004 º±±
±±º          vinculaTodasResponsabilidades                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ VINCULA / DESVINCULA RESPONSABILIDADES                     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ oItem2:bChange                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Method vinculaTodasResponsabilidades(nItem2,oItem2,aTpPen,oTpPen,cFilAtu,cMatAtu,aDoctos,aAvisos) CLASS QAXA010AuxClass

	Local lRet        := .T.
	Local nI          := 0
	Local SpaceQAA    := Space(TAMSX3("QAA_FILIAL")[1]+TAMSX3("QAA_MAT")[1])
	Local lLimpaMarca := aScan(aTpPen, {|x| (Empty(x[POS_aTpPen_DESTINATARIO]) .OR. QAA->QAA_FILIAL+QAA->QAA_MAT != x[POS_aTpPen_DESTINATARIO]) .and. x[POS_aTpPen_TEM_DOCUMENTO] }) == 0

	Default aDoctos := {}

	CursorWait()
	If lLimpaMarca
		aTpPen[POS_RESP_DIGITACAO   , POS_aTpPen_DESTINATARIO] := SpaceQAA
		aTpPen[POS_RESP_ELABORACAO  , POS_aTpPen_DESTINATARIO] := SpaceQAA
		aTpPen[POS_RESP_REVISAO     , POS_aTpPen_DESTINATARIO] := SpaceQAA
		aTpPen[POS_RESP_APROVACAO   , POS_aTpPen_DESTINATARIO] := SpaceQAA
		aTpPen[POS_RESP_HOMOLOGACAO , POS_aTpPen_DESTINATARIO] := SpaceQAA
		aTpPen[POS_RESP_DISTRIBUICAO, POS_aTpPen_DESTINATARIO] := SpaceQAA
		aTpPen[POS_RESP_LEITURA     , POS_aTpPen_DESTINATARIO] := SpaceQAA
		aTpPen[POS_RESP_RESP_DEPTO  , POS_aTpPen_DESTINATARIO] := SpaceQAA
		aTpPen[POS_RESP_DESTINATARIO, POS_aTpPen_DESTINATARIO] := SpaceQAA
		aTpPen[POS_RESP_AVISO       , POS_aTpPen_DESTINATARIO] := SpaceQAA

	Else
		If lRet
			For nI := 1 To 6 //Todos os Tipos de Pendencia ate Distribuicao
				IF aTpPen[nI, POS_aTpPen_TEM_DOCUMENTO]
					
					//Verifica a Existencia de Ausencia Temporia para o Usuario Destino
					IF QA_SitAuDP(QAA->QAA_FILIAL,QAA->QAA_MAT,aTpPen[nI,4])
						Help(" ",1,"QX040JEAP",,aTpPen[nI,3]+" (" + Alltrim(QAA->QAA_MAT) + "-" + AllTrim(QA_NUSR(QAA->QAA_FILIAL,QAA->QAA_MAT)) + ")",05,00) // "Ja existe Ausencia Temporaria cadastrada no Periodo para este Usuario."
						lRet  := .F.
					Endif

					//Verifica se a Distribuição pode ser executada para o Usuario Destino
					If lRet .And. nI == POS_RESP_DISTRIBUICAO
						lRet := QAX10SDoc(QAA->QAA_FILIAL,QAA->QAA_MAT,QAA->QAA_CC,cFilAtu,cMatAtu,cDepAtu,aDoctos)
						If !lRet
							aTpPen[6,1] := .F.
						EndIf
					EndIf

					IF lRet
						
						//Verifica a Existencia de Ausencia Temporia para o Usuario Origem
						IF QA_SitAuDP(cFilAtu,cMatAtu,aTpPen[nI,4])
							Help(" ",1,"QX040JEAP",,aTpPen[nI,3]+" (" + Alltrim(cMatAtu) + "-" + AllTrim(QA_NUSR(cFilAtu,cMatAtu)) + ")",05,00) // "Ja existe Ausencia Temporaria cadastrada no Periodo para este Usuario."
							lRet  := .F.
						Endif
						
						//Verifica o Usurio que vai receber a pendencia de Distribuicao e DISTSN (SIM)
						IF lRet .AND. aTpPen[nI,4]=="I" .AND. QAA->QAA_DISTSN =="2"
							MsgAlert(OemToAnsi(STR0128),OemToAnsi(STR0127)) //"O usuário informado para pendencia de Distribuição NÃO está indicado como um distribuidor no cadastro !"###"Atencao"
							lRet  := .F.
						Endif

					Endif

					IF !lRet
						Exit
					Endif
					
				Endif
			Next
		EndIf

		IF lRet
			aTpPen[POS_RESP_DIGITACAO   , POS_aTpPen_DESTINATARIO] := If(aTpPen[POS_RESP_DIGITACAO   , POS_aTpPen_TEM_DOCUMENTO], QAA->QAA_FILIAL+QAA->QAA_MAT, SpaceQAA)
			aTpPen[POS_RESP_ELABORACAO  , POS_aTpPen_DESTINATARIO] := If(aTpPen[POS_RESP_ELABORACAO  , POS_aTpPen_TEM_DOCUMENTO], QAA->QAA_FILIAL+QAA->QAA_MAT, SpaceQAA)
			aTpPen[POS_RESP_REVISAO     , POS_aTpPen_DESTINATARIO] := If(aTpPen[POS_RESP_REVISAO     , POS_aTpPen_TEM_DOCUMENTO], QAA->QAA_FILIAL+QAA->QAA_MAT, SpaceQAA)
			aTpPen[POS_RESP_APROVACAO   , POS_aTpPen_DESTINATARIO] := If(aTpPen[POS_RESP_APROVACAO   , POS_aTpPen_TEM_DOCUMENTO], QAA->QAA_FILIAL+QAA->QAA_MAT, SpaceQAA)
			aTpPen[POS_RESP_HOMOLOGACAO , POS_aTpPen_DESTINATARIO] := If(aTpPen[POS_RESP_HOMOLOGACAO , POS_aTpPen_TEM_DOCUMENTO], QAA->QAA_FILIAL+QAA->QAA_MAT, SpaceQAA)
			aTpPen[POS_RESP_DISTRIBUICAO, POS_aTpPen_DESTINATARIO] := If(aTpPen[POS_RESP_DISTRIBUICAO, POS_aTpPen_TEM_DOCUMENTO], QAA->QAA_FILIAL+QAA->QAA_MAT, SpaceQAA)
			aTpPen[POS_RESP_LEITURA     , POS_aTpPen_DESTINATARIO] := If(aTpPen[POS_RESP_LEITURA     , POS_aTpPen_TEM_DOCUMENTO], QAA->QAA_FILIAL+QAA->QAA_MAT, SpaceQAA)
			aTpPen[POS_RESP_RESP_DEPTO  , POS_aTpPen_DESTINATARIO] := If(aTpPen[POS_RESP_RESP_DEPTO  , POS_aTpPen_TEM_DOCUMENTO], QAA->QAA_FILIAL+QAA->QAA_MAT, SpaceQAA)
			aTpPen[POS_RESP_DESTINATARIO, POS_aTpPen_DESTINATARIO] := If(aTpPen[POS_RESP_DESTINATARIO, POS_aTpPen_TEM_DOCUMENTO], QAA->QAA_FILIAL+QAA->QAA_MAT, SpaceQAA)
			aTpPen[POS_RESP_AVISO       , POS_aTpPen_DESTINATARIO] := If(aTpPen[POS_RESP_AVISO       , POS_aTpPen_TEM_DOCUMENTO], QAA->QAA_FILIAL+QAA->QAA_MAT, SpaceQAA)
		Endif

	Endif

	oTpPen:bLine := Self:retornaBLineTipoPendencia()
	oTpPen:Refresh()
	CursorArrow()

Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QAX10VldAuºAutor  ³Telso Carneiro      º Data ³  14/05/2004 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica a Existencia de Ausencia Temporia para o Usuario  º±±
±±º			 ³  Destino nos Tipos Pendencias ate a Distribuicao           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ oItem2:bChange  / Valid da Troca de Depto                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function QAX10VldAu(cFilUsu,cCodUsu,aTpPen)

	Local lRet :=.T.
	Local nI

	CursorWait()
	For nI:=1 To 6 //Todos os Tipos de Pendencia ate Distribuicao
		IF aTpPen[nI,2]
			IF QA_SitAuDP(cFilUsu,cCodUsu,aTpPen[nI,4])
				Help(" ",1,"QX040JEAP",,aTpPen[nI,3]+" (" + Alltrim(cCodUsu) + "-" + AllTrim(QA_NUSR(cFilUsu,cCodUsu)) + ")",05,00) // "Ja existe Ausencia Temporaria cadastrada no Periodo para este Usuario."
				lRet  := .F.
				Exit
			Endif
		Endif
	Next

	CursorArrow()

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QAX10EmailºAutor  ³Telso Carneiro      º Data ³ 03/06/2004  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Cria e-mail de Transferencia			                      º±±
±±º          ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function QAX10Email(cDocto,cRv,cFilPara,cMatPara)

	Local aDiv      := {}
	Local aAlQAA	:= QAA->(GETAREA())

	QAA->(DBSETORDER(1))
	IF QAA->(DBSEEK(cFilPara+cMatPara))
		If !Empty(QAA->QAA_EMAIL) .And. QAA->QAA_RECMAI == "1"
			IF ASCAN(aUsrMail,{|x| Alltrim(x[1])==Alltrim(QAA->QAA_APELID)}) == 0
				FQDOTPMAIL(@aUsrMail,cDocto,cRv,,QAA->QAA_EMAIL,"TRF",cMatFil,QAA->QAA_APELID,QAA->QAA_MAT,,,aDiv,,)
			Endif
		EndIf
	ENDIF

	RestArea(aAlQAA)

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QAX010Lib ºAutor  ³Telso Carneiro      º Data ³  08/06/2004 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica a Existencia da matriz de Responsabilidade em     º±±
±±º          ³ Duplicidade para a Transferencia                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe	 ³QAX010Lib(aTpPen,aPenDoc,cFilAtu,cMatAtu,cDepAtu,			  º±±
±±º	    	 ³			nItem3,nItem5)                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametro ³aTpPen - Array com o Tipos de Pendencia e Usuario que Recebeº±±
±±º          ³aPenDoc- Array com o Documentos sinconizadro com aTpPen     º±±
±±º          ³cFilAtu- Filial do Usuario Transferido                      º±±
±±º          ³cMatAtu- Matricula do Usuario Transferido      			  º±± 
±±º          ³cDepAtu- Departamento do Usuario Transferido                º±±
±±º          ³nItem3 - Intem de Transferencia de Filial/Depto  			  º±±
±±º          ³nItem5 - Tipo de Transferencia                   			  º±±
±±º          ³nItem2 - nItem2 == 1 //"Todas Pendencias"        			  º±±
±±º          ³aFalhas - Array com relação de inconsistência	              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function QAX010Lib(aTpPen,aPenDoc,cFilAtu,cMatAtu,cDepAtu,nItem3,nItem5,nItem2,aFalhas)

	Local aArea  := GetArea()
	Local aAreaQD0:= QD0->(GetArea())
	Local cQuery := ""
	Local nA	 := 0
	Local nU	 := 0
	Local nPosA	 := 0
	Local cDepto := ""
	Local cUsrFil:= ""
	Local cUsrMat:= ""

	For nA := 1 to 6 //Todos os Tipos de Pendencia ate Distribuicao aTpPen
		If  aTpPen[nA,1] == .F. .Or. aTpPen[nA,2] == .F.
			Loop
		Endif

		nPosA := aScan(aPenDoc, { |x| Left(x[1],1) == aTpPen[nA,4] } )
		nPosA := If(nPosA == 0,Len(aPenDoc),nPosA)

		For nU := nPosA to Len(aPenDoc)
			If Left(aPenDoc[nU,1],1) <> aTpPen[nA,4]
				Exit
			Endif

			If nItem3 == 2

				If (aPenDoc[nU,4]) == .F. .Or. ;
						( Empty(aTpPen[nA,5]) .And. Empty(aPenDoc[nU,6]) .And. nItem5 <> 4)
					Loop
				Endif

			Endif

			IF !Empty(aTpPen[nA,5]) // Pendencias
				cUsrFil:= SUBS(aTpPen[nA,5],1,FWSizeFilial())
				cUsrMat:= SUBS(aTpPen[nA,5],FWSizeFilial()+1)
			Endif

			IF !Empty(aPenDoc[nU,6]) // Por Documento
				cUsrFil:= SUBS(aPenDoc[nU,6],1,FWSizeFilial())
				cUsrMat:= SUBS(aPenDoc[nU,6],FWSizeFilial()+1)
			Endif

			//Transferencias do Usuario para ele MESMO para atender a
			//Usuario transferido  pelo SIGAGPE - Legenda Azul
			IF cFilAtu==cUsrFil .And. cMatAtu==cUsrMat
				Loop
			Endif

			cDepto:=Posicione("QAA",1,cUsrFil+cUsrMat,"QAA_CC")

			cQuery := " SELECT R_E_C_N_O_ FROM "+ RetSqlName("QD0")+" QD0 WHERE QD0.QD0_FILIAL = '"+aPenDoc[nU,8]+"'"
			cQuery += " AND QD0.QD0_DOCTO = '"+aPendoc[nU,2]+"' AND QD0.QD0_RV = '"+aPendoc[nU,3]+"' AND QD0.QD0_FLAG <> 'I'"
			cQuery += " AND QD0.QD0_AUT = '"+Left(aPenDoc[nU,1],1) +"'"
			cQuery += " AND QD0.QD0_FILMAT = '"+cFilAtu+"' AND QD0.QD0_MAT = '"+cMatAtu+"'"
			cQuery += " AND QD0.D_E_L_E_T_ = ' '"

			cQuery += " AND EXISTS(SELECT R_E_C_N_O_ FROM "+ RetSqlName("QD0")+" QD0 WHERE QD0.QD0_FILIAL = '"+aPenDoc[nU,8]+"'"
			cQuery += " AND QD0.QD0_DOCTO = '"+aPendoc[nU,2]+"' AND QD0.QD0_RV = '"+aPendoc[nU,3]+"' AND QD0.QD0_FLAG <> 'I'"
			cQuery += " AND QD0.QD0_AUT = '"+Left(aPenDoc[nU,1],1) +"'"
			cQuery += " AND QD0.QD0_FILMAT = '"+cUsrFil+"' AND QD0.QD0_MAT = '"+cUsrMat+"'"
			cQuery += " AND QD0.D_E_L_E_T_ = ' ')"

			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QD0TRB",.T.,.T.)

			QD0TRB->(DBGotop())
			WHILE QD0TRB->(!Eof())

				IF ASCAN(aFalhas,{|X| X[POS_Falhas_Legenda] == 1                              .AND.;
					                  X[POS_Falhas_Docto]   == aPendoc[nU,POS_PendDoc_DOCTO]  .AND.;
					                  X[POS_Falhas_Revisao] == aPendoc[nU,POS_PendDoc_RV]     .AND.;
									  X[POS_Falhas_TpPend]  == aPendoc[nU,POS_PendDoc_TPPEND] .AND.;
									  X[POS_Falhas_FilMat]  == cUsrFil .AND.;
									  X[POS_Falhas_Mat]     == cUsrMat }) == 0

						AADD(aFalhas,{1                             ,;
						              aPendoc[nU,POS_PendDoc_DOCTO] ,;
						              aPendoc[nU,POS_PendDoc_RV]    ,;
									  AllTrim(aPendoc[nU,POS_PendDoc_TPPEND] + " - " + QA_NSIT(aPendoc[nU,POS_PendDoc_TPPEND])),;
									  Posicione("QDH",1,xFilial("QDH", cUsrFil) + aPendoc[nU,POS_PendDoc_DOCTO] + aPendoc[nU,POS_PendDoc_RV],"QDH_CODTP"),;
									  cUsrFil                       ,;
									  cUsrMat                       ,;
									  QA_NUSR(cUsrFil,cUsrMat)       ;
									 })

					Endif

				QD0TRB->(DbSKIP())
			Enddo

			DBCLOSEAREA()
			DbSelectArea("QD0")
		Next
	Next

	QD0->(RestArea(aAreaQD0))
	ResTArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QAX10AuDlgºAutor  ³Telso Carneiro      º Data ³  13/05/2004 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Tela de Apresentaca das Inconsistencias da Ausencia Temp.  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe	 ³QAX10AuDlg(aFalhas,cFilAtu,cMatAtu)						  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametro ³aFalhas- Array com o Doctos Inconsistentes                  º±±
±±º          ³cFilAtu- Filial do Usuario Transferido                      º±±
±±º          ³cMatAtu- Matricula do Usuario Transferido      			  º±± 
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QAX010Lib (Validacao da Tela)                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function QAX10AuDlg(aFalhas,cFilAtu,cMatAtu)

	Local cDesAtu     := QA_NUSR(cFilAtu,cMatAtu)
	Local nPercent    := 0.85
	Local oBitAmarelo := Nil
	Local oBitCinza   := Nil
	Local oDesAtu     := Nil
	Local oDlg        := Nil
	Local oFilAtu     := Nil
	Local oFwLayer    := FwLayer()  :New()
	Local oFailList   := Nil
	Local oMatAtu     := Nil
	Local oSize       := Nil
	Local oSizeDlg    := FwDefSize():New(.F.)

	//STR0117 - "Corrija as Inconsistências antes de prosseguir:"
	DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0117) FROM ;
	oSizeDlg:aWindSize[1]*nPercent,oSizeDlg:aWindSize[2]*nPercent TO ;
    oSizeDlg:aWindSize[3]*nPercent,oSizeDlg:aWindSize[4]*nPercent OF oMainWnd PIXEL
	
	oFwLayer:Init( oDlg, .F., .T. )

	//Resoluções Pequenas - Browser e monitores antigos ou com zoom		
	If oSizeDlg:aWorkArea[4] < 345
		oFWLayer:AddLine( 'TOPO', 20, .F. )
		oFWLayer:AddLine( 'FULL', 80, .F. )

	Else
		oFWLayer:AddLine( 'TOPO', 13, .F. )
		oFWLayer:AddLine( 'FULL', 87, .F. )

	EndIF
	
	// STR0212 - "Usuário Origem"
	oFWLayer:AddCollumn('TOPO_COL', 100, .F., 'TOPO' )
	oFWLayer:AddWindow("TOPO_COL","oPanelTOP",STR0212,100,.F.,.F.,,"TOPO",{ || })

	// STR0117 - "Corrija as Inconsistências antes de prosseguir:"
	// STR0202 - Qtd
	oFWLayer:AddCollumn('LISTA_COL' , 100, .F., 'FULL' )
	oFWLayer:AddWindow("LISTA_COL","oPanelDOWN" ,STR0117 + " - " + STR0202 +  ": (" + AllTrim(Str(Len(aFalhas))) + ")",100,.F.,.F.,,"FULL",{ || })

	oPanelTOP  := oFWLayer:GetWinPanel("TOPO_COL","oPanelTOP" ,"TOPO")

	//Usuário de Origem da Transferência
	@ 007, 006 MSGET oFilAtu VAR cFilAtu SIZE 038,008 OF oPanelTOP PIXEL WHEN .F.
	@ 007, 050 MSGET oMatAtu VAR cMatAtu SIZE 044,008 OF oPanelTOP PIXEL WHEN .F.
	@ 007, 120 MSGET oDesAtu VAR cDesAtu SIZE 085,008 OF oPanelTOP PIXEL WHEN .f.

	
	//LISTAGEM DE INCONSISTÊNCIAS
	oPanelDOWN := oFWLayer:GetWinPanel("LISTA_COL" ,"oPanelDOWN","FULL")

	oSize := FwDefSize():New(.F.,,,oPanelDOWN)
	oSize:lProp    := .T.                            // Proporcional
	oSize:aMargins := { 3, 3, 3, 3 }
	oSize:AddObject( "GRID"    , 090, 080, .T., .T. )
	oSize:AddObject( "LEGENDAS", 090, 040, .T., .F. )
	oSize:Process() // Dispara os calculos

	//Definição de GRID de Inconsistências
	@ oSize:GetDimension('GRID', 'LININI'), oSize:GetDimension('GRID', 'COLINI');
	  LISTBOX oFailList;
	  FIELDS HEADER "", Alltrim(TitSx3("QD0_DOCTO")[1]) ,;
						Alltrim(TitSx3("QD0_RV")[1])    ,;
						Alltrim(TitSx3("QD1_TPPEND")[1]),;
						Alltrim(TitSx3("QDH_CODTP")[1]) ,;
						Alltrim(TitSx3("QD0_FILMAT")[1]),;
						Alltrim(TitSx3("QD0_MAT")[1])   ,;
						Alltrim(TitSx3("QD0_NOME")[1])  ;
	  SIZE oSize:GetDimension('GRID', 'COLEND') - 005, oSize:GetDimension('GRID', 'LINEND') - 030 PIXEL OF oPanelDOWN

	oFailList:SetArray(aFalhas)
	oFailList:bLine := { || { LegInconsit(aFalhas[oFailList:nAt,POS_Falhas_Legenda]),;
										  aFalhas[oFailList:nAt,POS_Falhas_Docto  ] ,;
										  aFalhas[oFailList:nAt,POS_Falhas_Revisao] ,;
										  aFalhas[oFailList:nAt,POS_Falhas_TpPend ] ,;
										  aFalhas[oFailList:nAt,POS_Falhas_TpDoc  ] ,;
										  aFalhas[oFailList:nAt,POS_Falhas_FilMat ] ,;
										  aFalhas[oFailList:nAt,POS_Falhas_Mat    ] ,;
										  aFalhas[oFailList:nAt,POS_Falhas_QAANome] }}
	oFailList:GoTop()
	oFailList:Refresh()

	//Ícones de Legendas
	@ oSize:GetDimension('LEGENDAS', 'LINEND') - 40, 010 BitMap oBitAmarelo Resource "BR_LARANJA" Size 17,17 of oPanelDOWN Pixel Noborder Design
	@ oSize:GetDimension('LEGENDAS', 'LINEND') - 20, 010 BitMap oBitCinza   Resource "BR_CINZA"   Size 17,17 of oPanelDOWN Pixel Noborder Design

	//STR0196 - "Usuários Origem e Destino com mesma responsabilidade."
	//STR0197 - "Solução: Selecione outro Destino para pendência."
	//STR0198 - "Departamento e/ou Cargo do usuário Destino não conferem com Responsáveis do Tipo de Documento."
	//STR0199 - "Solução: Selecione um Destino que atenda aos requisitos de Responsáveis do Tipo de Documento."
	@ oSize:GetDimension('LEGENDAS', 'LINEND') - 40, 020  Say Oemtoansi(STR0196) Of oPanelDOWN Pixel
	@ oSize:GetDimension('LEGENDAS', 'LINEND') - 30, 020  Say Oemtoansi(STR0197) Of oPanelDOWN Pixel
	@ oSize:GetDimension('LEGENDAS', 'LINEND') - 20, 020  Say Oemtoansi(STR0198) Of oPanelDOWN Pixel
	@ oSize:GetDimension('LEGENDAS', 'LINEND') - 10, 020  Say Oemtoansi(STR0199) Of oPanelDOWN Pixel


	//STR0213 - "Imprimir"
	@ oSize:GetDimension('LEGENDAS', 'LINEND') - 20, oSize:GetDimension('LEGENDAS', 'COLEND') - 080;
	  BUTTON oCancel PROMPT OemToAnsi(STR0213)                                                     ;
	  ACTION QAXR10(aFalhas,cFilAtu,cMatAtu,cDepAtu) SIZE 030, 015 OF oPanelDOWN PIXEL

	//STR0214 - "Voltar"
	@ oSize:GetDimension('LEGENDAS', 'LINEND') - 20, oSize:GetDimension('LEGENDAS', 'COLEND') - 045;
	  BUTTON oVoltar PROMPT OemToAnsi(STR0214)                                                     ;
	  ACTION oDlg:End() SIZE 030, 015 OF oPanelDOWN PIXEL

	ACTIVATE MSDIALOG oDlg CENTERED

Return

/*/{Protheus.doc} LegInconsit
@type Static Function
@author brunno.costa
@since 12/09/2024
@param nLegenda, numérico, retorna o objeto de cor da legenda de inconsistencia
@return oLegenda, objeto, objeto de legenda
/*/
Static Function LegInconsit(nLegenda)
	Local oLegenda := Nil

	If nLegenda == 1     //Duplicidade Pendência
		oLegenda := oLaranja
	ElseIf nLegenda == 2 //Falta Exigibilidade Responsaveis do Tipo de Documento
		oLegenda := oCinza
	EndIf

Return oLegenda


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ QADR045  ³ Autor ³ Leandro S. Sabino     ³ Data ³ 17/05/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Relacao de Emails Associados   			                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Obs:      ³ (Versao Relatorio Personalizavel) 		                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QADR045	                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Function QAXR10(aDocDup,cFilAtu,cMatAtu,cDepAtu)
	Local oReport

	If TRepInUse()
		oReport := ReportDef(aDocDup,cFilAtu,cMatAtu,cDepAtu)
		oReport:PrintDialog()
	Else
		Return QAXR10R3(aDocDup,cFilAtu,cMatAtu,cDepAtu) //Executa versão anterior do fonte
	EndIf

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ReportDef()   ³ Autor ³ Leandro Sabino   ³ Data ³ 17.05.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Montar a secao				                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ReportDef()				                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QADR045                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportDef(aDocDup,cFilAtu,cMatAtu,cDepAtu)
Local oReport 
Local oSection1 
Local oSection2 

oReport   := TReport():New("QAXR080" ,OemToAnsi(STR0122),,{|oReport| RF010Imp(oReport,aDocDup,cFilAtu,cMatAtu,cDepAtu)},OemToAnsi(STR0119)+OemToAnsi(STR0120))
//"Docs.Inconsistencia Transferencia"##"Documentos com Inconsistencia na Transferencia "##"entre Usuarios de mesma Responsabilidade. "

oSection1 := TRSection():New(oReport,OemToAnsi(STR0146),{}) // "Usuario"
oSection1:SetTotalInLine(.F.)
TRCell():New(oSection1,OemToAnsi(STR0145),"   ","Filial" ,,20,/*lPixel*/,/*{||}*/)//"Filial"
TRCell():New(oSection1,OemToAnsi(STR0146),"   ","Usuario",,40,/*lPixel*/,/*{||}*/)//"Usuario"

oSection2 := TRSection():New(oSection1,OemToAnsi(STR0122),{}) //"Docs.Inconsistencia Transferencia"

TRCell():New(oSection2,OemToAnsi(Alltrim(TitSx3("QD0_DOCTO")[1])) ,"   ",OemToAnsi(Alltrim(TitSx3("QD0_DOCTO")[1]))	,,16,/*lPixel*/,/*{||}*/)
TRCell():New(oSection2,OemToAnsi(Alltrim(TitSx3("QD0_RV")[1]))    ,"   ",OemToAnsi(Alltrim(TitSx3("QD0_RV")[1]))	,,3 ,/*lPixel*/,/*{||}*/)
TRCell():New(oSection2,OemToAnsi(Alltrim(TitSx3("QD1_TPPEND")[1])),"   ",OemToAnsi(Alltrim(TitSx3("QD1_TPPEND")[1])),,20,/*lPixel*/,/*{||}*/)
TRCell():New(oSection2,OemToAnsi(Alltrim(TitSx3("QDH_CODTP")[1])) ,"   ",OemToAnsi(Alltrim(TitSx3("QDH_CODTP")[1]))	,,20,/*lPixel*/,/*{||}*/)
TRCell():New(oSection2,OemToAnsi(Alltrim(TitSx3("QD0_FILMAT")[1])),"   ",OemToAnsi(Alltrim(TitSx3("QD0_FILMAT")[1])),,3 ,/*lPixel*/,/*{||}*/)
TRCell():New(oSection2,OemToAnsi(Alltrim(TitSx3("QD0_MAT")[1]))   ,"   ",OemToAnsi(Alltrim(TitSx3("QD0_MAT")[1]))	,,6 ,/*lPixel*/,/*{||}*/)
TRCell():New(oSection2,OemToAnsi(Alltrim(TitSx3("QD0_NOME")[1]))  ,"   ",OemToAnsi(Alltrim(TitSx3("QD0_NOME")[1]))	,,40,/*lPixel*/,/*{||}*/)
TRCell():New(oSection2,OemToAnsi(Alltrim(STR0200))                ,"   ",OemToAnsi(STR0200)                         ,,40,/*lPixel*/,/*{||}*/)//"Inconsistência"

Return oReport


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ RF010Imp      ³ Autor ³ Leandro Sabino   ³ Data ³ 17.05.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Imprimir os campos do relatorio                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ RF010Imp(ExpO1)   	     	                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ oReport- Objeto oPrint                                     ³±±
±±³          | aDocDup- Array com o Doctos Inconsistentes                 |±±
±±º          ³ cFilAtu- Filial do Usuario Transferido                     |±±
±±º          ³ cMatAtu- Matricula do Usuario Transferido      			  |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QADR045                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RF010Imp(oReport,aFalhas,cFilAtu,cMatAtu,cDepAtu)

	Local cInconsistencia := ""
	Local nI              := 0
	Local oSection1       := oReport:Section(1)
	Local oSection2       := oReport:Section(1):Section(1)

	oSection1:Init()

	oSection1:Cell(OemToAnsi(STR0145)):SetValue(cFilAtu)//"Filial"
	oSection1:Cell(OemToAnsi(STR0146)):SetValue(cMatAtu+" "+QA_NUSR(cFilAtu,cMatAtu))//"Usuario"
	oSection1:PrintLine()

	oSection2:Init()
         
	For nI:= 1 To Len(aFalhas)
		cInconsistencia := ""
		
		//STR0196 - "Usuários Origem e Destino com mesma responsabilidade."
		//STR0197 - "Solução: Selecione outro Destino para pendência."
		//STR0198 - "Departamento e/ou Cargo do usuário Destino não conferem com Responsáveis do Tipo de Documento."
		//STR0199 - "Solução: Selecione um Destino que atenda aos requisitos de Responsáveis do Tipo de Documento."

		cInconsistencia := Iif(aFalhas[nI,POS_Falhas_Legenda] == 1, STR0196 + STR0197, cInconsistencia)
		cInconsistencia := Iif(aFalhas[nI,POS_Falhas_Legenda] == 2, STR0198 + STR0199, cInconsistencia)

		oSection2:Cell(OemToAnsi(Alltrim(TitSx3("QD0_DOCTO")[1] ))):SetValue(aFalhas[nI,POS_Falhas_Docto])
		oSection2:Cell(OemToAnsi(Alltrim(TitSx3("QD0_RV")[1]    ))):SetValue(aFalhas[nI,POS_Falhas_Revisao])
		oSection2:Cell(OemToAnsi(Alltrim(TitSx3("QD1_TPPEND")[1]))):SetValue(aFalhas[nI,POS_Falhas_TpPend])
		oSection2:Cell(OemToAnsi(Alltrim(TitSx3("QDH_CODTP")[1] ))):SetValue(aFalhas[nI,POS_Falhas_TpDoc])
		oSection2:Cell(OemToAnsi(Alltrim(TitSx3("QD0_FILMAT")[1]))):SetValue(aFalhas[nI,POS_Falhas_FilMat])
		oSection2:Cell(OemToAnsi(Alltrim(TitSx3("QD0_MAT")[1]   ))):SetValue(aFalhas[nI,POS_Falhas_Mat])
		oSection2:Cell(OemToAnsi(Alltrim(TitSx3("QD0_NOME")[1]  ))):SetValue(aFalhas[nI,POS_Falhas_QAANome])
		oSection2:Cell(OemToAnsi(STR0200                         )):SetValue(cInconsistencia) //Inconsistência
		oSection2:Cell(STR0200):SetLineBreak()
		oSection2:PrintLine()
	Next

	oSection1:Finish()
	oSection2:Finish()

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QAXR10R3 ºAutor  ³Telso Carneiro      º Data ³  08/06/2004 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Relatorio de Doctos Inconsistencia na Transferencia         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe	 ³QAXR10R3(aDocDup,cFilAtu,cMatAtu,cDepAtu)				  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametro ³aDocDup- Array com o Doctos Inconsistentes                  º±±
±±º          ³cFilAtu- Filial do Usuario Transferido                      º±±
±±º          ³cMatAtu- Matricula do Usuario Transferido      			  º±± 
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QAX10AuDlg (Tela de Apresentacao da Inconsistencia)        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function QAXR10R3(aDocDup,cFilAtu,cMatAtu,cDepAtu)

	Local cDesc1       := STR0121 //"Este programa tem como objetivo imprimir relatorio "
	Local cDesc2       := STR0119 //"Documentos com Inconsistencia na Transferencia "
	Local cDesc3       := STR0120 //"entre Usuarios de mesma Responsabilidade. "
	Local titulo       := STR0122 //"Docs.Inconsistencia Transferencia"
	Local nLin         := 80

	Local Cabec1       := OemToAnsi(STR0118) //"Filial/Usuario"
	Local Cabec2       := cFilAtu +" "+cMatAtu+" "+QA_NUSR(cFilAtu,cMatAtu)
	Local aOrd 		   := {}

	Private limite     := 80
	Private tamanho    := "P"
	Private nomeprog   := "QAXR080"
	Private nTipo      := 18
	Private aReturn    := { STR0123, 1, STR0124, 2, 2, 1, "", 1}  //"Zebrado"###"Administracao"
	Private nLastKey   := 0
	Private m_pag      := 01
	Private wnrel      := "QAXR080"
	Private cString    := "QAA"

	wnrel := SetPrint(cString,NomeProg,"",@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.T.,Tamanho,,.F.)

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,cString)

	If nLastKey == 27
		Return
	Endif

	nTipo := If(aReturn[4]==1,15,18)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Processamento. RPTSTATUS monta janela com a regua de processamento. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	RptStatus({|| QAX10AuRel(Cabec1,Cabec2,Titulo,nLin,aDocDup) },Titulo)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³QAX10AuRelº Autor ³ Telso Carneiro     º Data ³  13/05/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS º±±
±±º          ³ monta a janela com a regua de processamento.               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QAXR010                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function QAX10AuRel(Cabec1,Cabec2,Titulo,nLin,aDocDup)

	Local nI
	Local cCabec3 := (TitSx3("QDH_DOCTO")[1])+" "+ALLTRIM(TitSx3("QDH_RV")[1])+" "+(TitSx3("QD1_TPPEND")[1])+" "+(TitSx3("QD0_NOME")[1])
	Local cbtxt    := SPACE(10)
	Local cbcont   := 0

	SetRegua(len(aDocDup))

	For nI:=1 TO Len(aDocDup)
		
		//Verifica o cancelamento pelo usuario...
		If lAbortPrint
			@nLin,00 PSAY STR0125 //"*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif
		IncRegua()

		//Impressao do cabecalho do relatorio. . .
		If nLin > 60
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)                   
			nLin := 9
			@nLin,00 PSAY cCabec3                  
			nLin++                                 
			@nLin,000 Psay __PrtThinLine() 
			nLin++                                 
		Endif
		@nLin,00 PSAY aDocDup[nI,1]+" "+aDocDup[nI,2]+" "+aDocDup[nI,3]+;
			 SPACE(6)+aDocDup[nI,4]+" "+aDocDup[nI,5]+"-"+aDocDup[nI,6]
		nLin++                                           

	Next

	If nLin != 80
		Roda(cbcont,cbtxt,tamanho)
	EndIf


	SET DEVICE TO SCREEN

	If aReturn[5]==1
		dbCommitAll()
		SET PRINTER TO
		OurSpool(wnrel)
	Endif

	MS_FLUSH()

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QAX010PUS ºAutor  ³Telso Carneiro      º Data ³ 22/09/2004  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Tela de Pesquisa do Usuario para definir a Filial/Codigo    º±±
±±º          ³												              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³QAX010Atu()                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function QAX010PUS()

	Local lRet:= .T.
	Local oDlgU
	Local oFilUsr
	Local cFilUsr := cCcFilial
	Local oCodUsr
	Local oDesUsr
	Local cCodUsr:= Space(TamSx3("QAA_MAT" )[1])
	Local cDesUsr:= Space(TamSx3("QAA_NOME")[1])


	DEFINE MSDIALOG oDlgU FROM 000,000 TO 160,490 TITLE OemToAnsi(STR0001) PIXEL //"Pesquisar"

	@ 020,003 TO 065,240 LABEL OemToAnsi(STR0021) OF oDlgU PIXEL  //"Usuario"

	@ 030,006 SAY OemToAnsi(STR0033) SIZE 010,008 OF oDlgU PIXEL  //"Fil"
	@ 040,006 MSGET oFilUsr VAR cCcFilial PICTURE PesqPict("QDE","QDE_FILIAL") F3 "SM0" SIZE 050,008 OF oDlgU PIXEL ;
		VALID QA_CHKFIL(cCcFilial,@cFilMat)

	@ 030,070 SAY OemToAnsi(STR0082) SIZE 044,008 OF oDlgU PIXEL  //"C¢digo"
	@ 040,070 MSGET oCodUsr VAR cCodUsr PICTURE '@!' F3 "QDE" SIZE 044,008 OF oDlgU PIXEL ;
		VALID (cDesUsr:= QA_NUSR(cCcFilial,cCodUsr,.T.),	oDesUsr:Refresh(),QA_CHKMAT(cCcFilial,cCodUsr))

	@ 030,134 SAY OemToAnsi(STR0083) SIZE 85,008 OF oDlgU PIXEL  //"Nome"
	@ 040,134 MSGET oDesUsr VAR cDesUsr SIZE 85,008 OF oDlgU PIXEL WHEN .f.

	ACTIVATE MSDIALOG oDlgU CENTERED ON INIT EnchoiceBar(oDlgU,{|| lRet:=.T., oDlgU:End()},{|| lRet:=.F., oDlgU:End()} )

	cCcFilial := cFilUsr

Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QA_SitAuDPºAutor  ³Telso Carneiro      º Data ³  11/05/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica a Existencia de Ausencia Temporaria para o Usuarioº±±
±±º          ³ DE e PARA                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function QA_SitAuDP(cMatFil,cMatCod,cTpend)

	Local lRet	 := .F.
	Local aArea	 := GetArea()
	Local cQuery := ""

	//Verifica se existe lancamento de Ausencia Temporaria
	cQuery := " SELECT QAF.QAF_TPPEND "
	cQuery += " FROM " + RetSqlName("QAE")+" QAE ,"+ RetSqlName("QAF")+" QAF "
	cQuery += " WHERE QAE.QAE_FILIAL = '"+xFilial("QAE")+"'
	cQuery += " AND QAE.QAE_STATUS = '1' AND QAE.QAE_MODULO = "+AllTrim(Str(nModulo))
	cQuery += " AND QAE.QAE_FILIAL = QAF.QAF_FILIAL AND QAF.QAF_FLAG <> 'I'"
	cQuery += " AND QAE.QAE_ANO = QAF.QAF_ANO AND QAE.QAE_NUMERO = QAF.QAF_NUMERO "
	cQuery += " AND (QAE.QAE_FILMAT = '" + cMatFil +"' AND QAE.QAE_MAT = '" + cMatCod +"')"
	cQuery += " AND QAE.D_E_L_E_T_ = ' ' AND QAF.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QAETRB",.T.,.T.)

	QAETRB->(DBGotop())
	WHILE QAETRB->(!Eof())
		IF SUBS(QAETRB->QAF_TPPEND,1,1)==cTpend
			lRet:= .T.
			Exit
		Endif
		QAETRB->(DbSkip())
	EndDO

	DBCLOSEAREA()

	RestARea(aArea)

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QAX010FIM ºAutor  ³Telso Carneiro      º Data ³  14/12/2004 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica e Libera a Transferência                          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QAXA010()                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function QAX010FIM(nItem2,nItem3,nItem4,nItem5,aPenDoc,aTpPen,cCcFilial,cCcPara,cNDepto,cCcMatr,cFilAtu,cMatAtu,cDepAtu,oDlgFolder,lChk03,aAvisos)
	
	Local aCof        := {}
	Local aFalhas     := {}
	Local aSize       := Nil
	Local cCof        := ""
	Local cFilPara    := Space(FWSizeFilial())
	Local cMatPara    := ""
	Local cTipo       := ""
	Local lRet        := .F.
	LocaL Na          := 1
	Local nItem2Bkp   := 2
	Local nItem3Bkp   := 2
	Local nItem4Bkp   := 1
	Local nItem5Bkp   := 1
	Local nPosA       := 0
	Local Nu          := 1
	Local oCof        := Nil
	Local oDlgC       := Nil
	Local oFwLayer    := FwLayer():New()
	Local oPanelDOWN  := Nil
	Local oPanelTOP   := Nil
	Local oQAXA010Aux := QAXA010AuxClass():New()
	Local oSize       := Nil

	CursorWait()

	//Valida a transferencia de lactos em fase de Elaboracao
	lRet:= FQAXA010Ttf(nItem3,nItem5,aPenDoc,aTpPen,cCcFilial)

	IF !lRet
		CursorArrow()
		Return( { IF(lRet,1,2), nItem2, nItem3, nItem4, nItem5 } )
	Endif

	//Valida a transferencia de usuario entre filiais
	lRet:= FQAXA010ICE(cCcFilial)

	IF !lRet
		CursorArrow()
		Return( { IF(lRet,1,2), nItem2, nItem3, nItem4, nItem5 } )
	Endif

	//Verifica se existe o Centro de Custo digitado/selecionado
	IF nItem3 == 1
		lRet:= FQAXA010QAD(cCcFilial,cCcPara,@cNDepto,cCcMatr,nItem5)
		IF !lRet
			CursorArrow()
			Return( { IF(lRet,1,2), nItem2, nItem3, nItem4, nItem5 } )
		Endif

		//Verifica a Existencia de Ausencia Temporia para o Usuario
		//Destino nos Tipos Pendencias ate a Distribuicao          
		lRet:= QAX10VldAu(cCcFilial,cCcMatr,aTpPen)
		IF !lRet
			CursorArrow()
			Return(IF(lRet,1,2))
		Endif
	Endif


	//Verifica a Existencia da matriz de Responsabilidade em
	//Duplicidade para a Transferencia                      
	QAX010Lib(aTpPen,aPenDoc,cFilAtu,cMatAtu,cDepAtu,nItem3,nItem5,nItem2,@aFalhas)

	//Verifica a Existencia da matriz de Responsabilidade em
	//Discordancia entre depto e Cargo                      
	QAX010QDD(aTpPen,aPenDoc,cFilAtu,cMatAtu,cDepAtu,nItem3,nItem5,nItem2,cCcPara,@aFalhas)

	IF Len(aFalhas) > 0
		lRet := .F.
		QAX10AuDlg(aFalhas,cFilAtu,cMatAtu)
		CursorArrow()
		Return( { IF(lRet,1,2), nItem2, nItem3, nItem4, nItem5 } )
	Endif


	//Verifica os Avisos para evitar inconsistencia na Transferencia
	lRet:=QAX010Vav(aAvisos,nItem2,nItem3,nItem5,aPenDoc,aTpPen)
	IF !lRet
		CursorArrow()
		Return( { IF(lRet,1,2), nItem2, nItem3, nItem4, nItem5 } )
	Endif

	For nA := 1 to LeN(aTpPen) //Todos os Tipos de Pendencias
		If  aTpPen[nA,1] == .F. .Or. aTpPen[nA,2] == .F.
			Loop
		Endif

		nPosA := aScan(aPenDoc, { |x| Left(x[1],1) == aTpPen[nA,4] } )
		nPosA := If(nPosA == 0,Len(aPenDoc),nPosA)

		For nU := nPosA to Len(aPenDoc)
			If Left(aPenDoc[nU,1],1) <> aTpPen[nA,4]
				Exit
			Endif

			If nItem3 == 2 //Responsabilidade
				If (aPenDoc[nU,4]) == .F. .Or. ;
				   (Empty(aTpPen[nA,POS_aTpPen_DESTINATARIO]) .And. Empty(aPenDoc[nU,6]) .And. nItem5 <> 4)
					Loop
				Endif
			Endif

			If (aPenDoc[nU,9]) == 0
				Loop
			EndiF

			cTipo		:= aTpPen[nA,3]
			cFilPara	:= Space(FWSizeFilial())
			cMatPara	:= ""
			cDepto		:= ""

			IF !Empty(aTpPen[nA,5]) // Pendencias
				cFilPara:= SUBS(aTpPen[nA,5],1,FWSizeFilial())
				cMatPara:= SUBS(aTpPen[nA,5],FWSizeFilial()+1)
				cDepto	:= Posicione("QAA",1,cFilPara+cMatPara,"QAA_CC")
			Endif

			IF !Empty(aPenDoc[nU,6]) // Por Documento
				cFilPara:= SUBS(aPenDoc[nU,6],1,FWSizeFilial())
				cMatPara:= SUBS(aPenDoc[nU,6],FWSizeFilial()+1)
				cDepto	:= Posicione("QAA",1,cFilPara+cMatPara,"QAA_CC")
			Endif

			If nItem3 == 1
				cFilPara:=cCcFilial
				cMatPara:=cCcMatr
				cDepto	:=cCcPara
			Endif

			If nItem4 == 1 .Or.;
			 ( nItem4 == 2 .And. aPenDoc[nU,5] == "B" ) .Or. ; //"1=Ambas 2=Baixadas 3=Pendentes"
			 ( nItem4 == 3 .And. aPenDoc[nU,5] == "P" )

				If aScan(aCof,{|x| X[1]+X[2]+X[3]+X[4] == cTipo+aPenDoc[nU,8]+aPenDoc[nU,2]+aPenDoc[nU,3]}) == 0
					AADD(aCof,{cTipo ,; //Tipo de Pendencia
							   aPenDoc[nU,8],; //Filial
							   aPenDoc[nU,2],; // Codigo Docto
							   aPenDoc[nU,3],; // Revisao
					           cFilPara +"-" +cMatPara+" "+QA_NUSR(cFilPara,cMatPara)+OemToAnsi(STR0085)+": "+cDepto}) //PARA Depto
				EndIf

			Endif

		Next
	Next

	If Len(aCof)  > 0

		// Define tamanho da tela
		oSize := FwDefSize():New(.T.,,,oDlgC)
		oSize:AddObject( "TELA" ,  100, 100, .T., .T. ) // Totalmente dimensionavel
		oSize:lProp := .T. // Proporcional             
		oSize:aMargins := { 3, 3, 3, 3 } // Espaco ao lado dos objetos 0, entre eles 3 

		oSize:Process() // Dispara os calculos  

		aSize	:= MsAdvSize()
		
		//"Confirmação da "###"Transferencia de Usuarios"###"Usuario"###"Depto"
		DEFINE MSDIALOG oDlgC TITLE OemToAnsi(STR0132)+OemToAnsi(STR0020)+" - "+OemToAnsi(STR0021)+": "+AllTrim(cMatAtu)+" - "+AllTrim(cNomAtu)+" "+OemToAnsi(STR0085)+": "+cDepATu;
		       FROM 000,000 To aSize[6]-60,aSize[5]-150 OF GetWndDefault() PIXEL

		oFwLayer:Init( oDlgC, .F., .T. )

		//Resoluções Pequenas - Browser e monitores antigos ou com zoom		
		If oSize:aWorkArea[4] < 345
			oFWLayer:AddLine( 'OPCOES', 20, .F. )
			oFWLayer:AddLine( 'FULL'  , 75, .F. )

		Else
			oFWLayer:AddLine( 'OPCOES', 13, .F. )
			oFWLayer:AddLine( 'FULL'  , 82, .F. )

		EndIF
		
		// STR0060 - Opções
		oFWLayer:AddCollumn('OPCOES_COL', 100, .F., 'OPCOES' )
		oFWLayer:AddWindow("OPCOES_COL","oPanelTOP",STR0060,100,.F.,.F.,,"OPCOES",{ || })

		oFWLayer:AddCollumn( 'LISTA_COL' , 100, .F., 'FULL' )

		// STR0203 - Lista de Transferências
		// STR0202 - Qtd
		oFWLayer:AddWindow("LISTA_COL","oPanelDOWN", STR0203 + " - " + STR0202 + ": (" + AllTrim(Str(Len(aCof))) + ")",100,.F.,.F.,,"FULL",{ || })

		oPanelTOP  := oFWLayer:GetWinPanel("OPCOES_COL","oPanelTOP" ,"OPCOES")
		oPanelDOWN := oFWLayer:GetWinPanel("LISTA_COL" ,"oPanelDOWN","FULL")

		oQAXA010Aux:montaPainelOpcoes(oPanelTOP, .F.)


		//LISTAGEM DE TRANSFERÊNCIAS
		@015, 002 LISTBOX oCof VAR cCof;
		FIELDS HEADER OemToAnsi(STR0078), ; //"Tipo de Responsabilidade"
		              OemToAnsi(STR0033), ; //"Fil"
		              OemToAnsi(STR0086), ; //"No.Docto"
		              OemToAnsi(STR0087), ; //"Rv"
		              OemToAnsi(STR0023) ;  //" Transferir para "
		SIZE 330,210 OF oPanelDOWN PIXEL
		oCof:Align := CONTROL_ALIGN_ALLCLIENT
		oCof:SetArray(aCof)
     	oCof:bLine := {|| aCof[oCof:nAt] }

		//Contorno ao bug que deixa o nItem5 private em branco
		nItem2Bkp := nItem2
		nItem3Bkp := nItem3
		nItem4Bkp := nItem4
		nItem5Bkp := nItem5

		CursorArrow()
		ACTIVATE MSDIALOG oDlgC CENTERED ON INIT EnchoiceBar(oDlgC,{||  nItem2 := nItem2Bkp, ;
		                                                      			nItem3 := nItem3Bkp, ; 
															  			nItem4 := nItem4Bkp, ;
															  			nItem5 := nItem5Bkp, ;
																		lRet:=.T. ,oDlgC:End()},{|| lRet:= .F.,oDlgC:End()} )

		lRet := lRet .AND. QA010DlgJus(oDlgFolder)
	Else
		If nItem3 == 1 // Caso a Transferencia seja  por Centro de Custo
			CursorArrow()
			MsgInfo(OemToAnsi(STR0143),OemToAnsi(STR0127))  //"Nao ha Lancamentos a transferir! Usuario sera transferido de Departamento, favor verificar as pendencias deste usuario nos outros ambientes da Qualidade (Ex: Metrologia, Inspecao de Processos, etc ...)"###"Atencao"
			lRet:=.T.
		Else
			CursorArrow()
			MsgAlert(OemToAnsi(STR0089),OemToAnsi(STR0127))  //"Näo há Lançamentos"###"Atencao"
			lRet:=.F.
		EndIf
	Endif

Return {IF(lRet,1,2), nItem2, nItem3, nItem4, nItem5}

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QAX10SDoc ºAutor  ³Cicero Cruz         º Data ³  18/06/2005 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica se a Distribuição pode ser executada para o       º±±
±±º          ³ Usuario Destino com Pendencias de Distribuicao             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QAXA010()                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function QAX10SDoc(cFilDest,cMatDest,cDepDest,cFilDe,cMatDe,cDepde,aDoctos,oDoctos,lPorDocto)

	Local aArea		   := GetArea()
	Local lRet 		   := .T.
	Local nI 		   := 0
	Local MsgConsist   := ""
	Local aAreaQD1     := QD1->(GetArea())

	Default lPorDocto := .F.
	Default oDoctos   := nil

	QD1->(dbSetOrder(7))

	If !lPorDocto
		For nI:=1 to Len(aDoctos)
			If aDoctos[nI,1] == .T.
				If QD1->(DBSeek(aDoctos[nI,POS_ADOCTOS_FIL_PEN]+aDoctos[nI,POS_ADOCTOS_COD_DOC]+aDoctos[nI,POS_ADOCTOS_REV_DOC]+cDepDest+cFilDest+cMatDest+"I  "+"P"))    //Filial+Documento+Revisao+Departamento+Filial+Matricula+Tipo Pendencia+pendente
					lRet := .F.
					MsgConsist := OemToAnsi(STR0129) + aDoctos[nI,POS_ADOCTOS_COD_DOC] +"/"+ aDoctos[nI,POS_ADOCTOS_REV_DOC] //"A pendencia de Distribuicao do Documento "
					MsgConsist += OemToAnsi(STR0131) //" nao pode ser transferida, pois o usuario destino ja possui em esta pendencia de distribuicao!"
					Exit
				EndIf
			EndIf
		Next
	Else
		If aDoctos[oDoctos:nAt,POS_ADOCTOS_MARK] == .T.
			If QD1->(DBSeek(aDoctos[oDoctos:nAt,POS_ADOCTOS_FIL_PEN]+aDoctos[oDoctos:nAt,POS_ADOCTOS_COD_DOC]+aDoctos[oDoctos:nAt,POS_ADOCTOS_REV_DOC]+cDepDest+cFilDest+cMatDest+"I  "+"P"))    //Filial+Documento+Revisao+Departamento+Filial+Matricula+Tipo Pendencia+pendente
				lRet := .F.
				MsgConsist := OemToAnsi(STR0129) + aDoctos[oDoctos:nAt,POS_ADOCTOS_COD_DOC] +"/"+ aDoctos[oDoctos:nAt,POS_ADOCTOS_REV_DOC]  //"A pendencia de Distribuicao do Documento " ###"/"
				MsgConsist += OemToAnsi(STR0131)    //" nao pode ser transferida, pois o usuario destino ja possui esta pendencia de distribuicao!"
			EndIf
		EndIf
	EndIf

	IF !lRet
		MsgAlert(MsgConsist)
	Endif

	QD1->(RestArea(aAreaQD1))
	RestArea(aArea)

Return lRet



/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FQAXA010Avs³ Autor ³ Telso Carneiro      ³ Data ³18/08/2005³±±
±±³            carregaAvisosEmTela                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Carrega os Avisos                           				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe    carregaAvisosEmTela(...)                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 - Objeto do ListBox de Doctos                        ³±±
±±³          ³ ExpA1 - Array contendo os Lancamentos dos Documentos       ³±±
±±³          ³ ExpA2 - Array contendo os Lancamentos Avisos    			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

METHOD carregaAvisosEmTela(lPosAv, oDoctos, aDoctos, oAvisos, aAvisos, aAviAux, nItem4) CLASS QAXA010AuxClass

	Local aRetAvisos  := {}
	Local cChave      := If(nItem4==1, "", If(nItem4==2, "B", "P"))

	Self:retornaAvisos(lPosAv, oDoctos, aDoctos, aAvisos, @aRetAvisos, cChave)
   
	aAviAux := iif(Empty(aRetAvisos), aAviAux, aRetAvisos)

	If oAvisos <> Nil
		oAvisos:nAt   := 1
		oAvisos:SetArray(aAviAux)
		oAvisos:bLine := bQDSLine
		IF !lPosAv
			oAvisos:Hide()		       
		Else
			oAvisos:Show()     
		Endif
		oAvisos:Refresh()    	
	Endif
Return


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ QAX010MsgA³ Autor ³ Telso Carneiro               ³ Data ³ 19/08/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Carrega Mensagem do Aviso                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QAX010MsgA(ExpC1)                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Tipo de Aviso                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QAXA010                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function QAX010MsgA(cTipoAviso)
Return QAXDescSX5("QH",cTipoAviso,cTipoAviso)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QAX010Vav ºAutor  ³Telso Carneiro      º Data ³  29/08/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida a Transferencia dos Avisos   						  º±±
±±º          ³para evitar inconsistencia na Transferencia                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

STatic Function QAX010Vav(aAvisos,nItem2,nItem3,nItem5,aPenDoc,aTpPen)
	Local aTiAus     := {}
	Local cCodFun    := ""
	Local cCODTp     := ""
	Local cDepto     := ""
	Local cDist      := ""
	Local cMvQLIBLEI := GetMV( "MV_QLIBLEI" )
	Local cUsrFil    := ""
	Local cUsrMat    := ""
	Local lRet       := .T.
	Local nA         := 10 //Posicao dos Aviso no Array
	Local nOrdQDA    := QDA->(IndexOrd())
	Local nOrdQDG    := QDG->(IndexOrd())
	Local nPosA      := 0
	Local nPosP      := 0
	Local nPosT      := 0
	Local nU         := 0
	Local nY         := 0

	If  aTpPen[nA,1] == .F. .Or. aTpPen[nA,2] == .F.
		Return(lRet)
	Endif

	nPosA := aScan(aPenDoc, { |x| Left(x[1],1) == aTpPen[nA,4] } )
	nPosA := If(nPosA == 0,Len(aPenDoc),nPosA)

	For nU := nPosA to Len(aPenDoc)
		If Left(aPenDoc[nU,1],1) <> aTpPen[nA,4]
			Exit
		Endif

		If nItem3 == 2

			If (aPenDoc[nU,4]) == .F. .Or. ;
					( Empty(aTpPen[nA,5]) .And. Empty(aPenDoc[nU,6]) .And. nItem5 <> 4)
				Loop
			Endif

		Endif

		IF !Empty(aTpPen[nA,5]) // Pendencias
			cUsrFil:= SUBS(aTpPen[nA,5],1,FWSizeFilial())
			cUsrMat:= SUBS(aTpPen[nA,5],FWSizeFilial()+1)
		Endif

		IF !Empty(aPenDoc[nU,6]) // Por Documento
			cUsrFil:= SUBS(aPenDoc[nU,6],1,FWSizeFilial())
			cUsrMat:= SUBS(aPenDoc[nU,6],FWSizeFilial()+1)
		Elseif Empty(cUsrFil) .and. Empty(cUsrMat)
			cUsrFil:=cFilMat
			cUsrMat:=cMatAtu
		Endif

		IF nItem2 == 1 //"Todas Pendencias"
			//Transferencias do Usuario para ele MESMO para atender a
			//Usuario transferido  pelo SIGAGPE - Legenda Azul -   
			IF cFilAtu==cUsrFil .And. cMatAtu==cUsrMat
				Loop
			Endif
		Endif

		QAA->(DbSetOrder(1))
		QAA->(DBSeek(cUsrFil+cUsrMat))
		cDepto 	:= QAA->QAA_CC
		cCodFun	:= QAA->QAA_CODFUN
		cDist	:= QAA->QAA_DISTSN

		nI:=Ascan(aAvisos,{|x| x[1]+x[2]+x[3] == aPenDoc[nU,8]+aPenDoc[nU,2]+aPenDoc[nU,3]})
		IF nI > 0
			IF aAvisos[nI,6] $ "QUE.REF.SAD.VEN"
				cCODTp:=POSICIONE("QDH",1,aAvisos[nI,1]+aAvisos[nI,2]+aAvisos[nI,3],"QDH_CODTP")
				QD5->(DbSetOrder(1))
				If QD5->(DBSeek(aAvisos[nI,1] + cCODTp ))
					While QD5->(!EOF()) .AND. QD5->QD5_FILIAL==aAvisos[nI,1] .AND. QD5->QD5_CODTP == cCODTp
						IF aAvisos[nI,6] $ "REF.SAD.VEN"
							IF QD5->QD5_GREV == "N"
								// STR0127 - Atenção
								// STR0134 - O usuário informado para receber o aviso de 
								// STR0135 - no documento
								// STR0136 - NÃO está indicado como permissão um Gerar Revisao no cadastro !
								// STR0175 - Deverá ser concedida permissão no Cadastro de Tipo de Documento.
								Help(NIL, NIL, STR0127, NIL, OemToAnsi(STR0134)+" ("+Alltrim(QAX010MsgA(aAvisos[nI,6]))+") "+OemToAnsi(STR0135)+Alltrim(aAvisos[nI,2])+" "+aAvisos[nI,3]+","+OemToAnsi(STR0136) ,1, 0, NIL, NIL, NIL, NIL, NIL, {STR0175})
								lRet := .F.
								Exit
							Else
								
								//Verifica o Usurio que vai receber o Aviso de Referencia, Solicitacao de Alt, Vencido com GREV='S'
								QD0->(DbSetOrder(2))
								IF QD0->(DBSeek(aAvisos[nI,1]+aAvisos[nI,2]+aAvisos[nI,3]+QD5->QD5_AUT+cUsrFil+cDepto+cUsrMat))
									AADD(aTiAus,QD0->QD0_AUT)
									Exit
								Else
									// STR0127 - Atenção
									// STR0173 - Usuário não tem permissão para receber aviso.
									// STR0174 - Efetue a transferencia de alguma pendência(Elaboração, Revisão, Aprovação ou Homologação) do documento e repita a transferencia de aviso.
									Help(NIL, NIL, STR0127, NIL, STR0173,1, 0, NIL, NIL, NIL, NIL, NIL, {STR0174})
									lRet := .F.
									Exit
								EndiF
							EndiF
						ElseIF aAvisos[nI,6] == "QUE"
							IF QD5->QD5_ALT == "N"
								// STR0127 - Atenção
								// STR0134 - O usuário informado para receber o aviso de 
								// STR0135 - no documento
								// STR0137 - NÃO está indicado com permissão de Alterar no cadastro !
								// STR0175 - Deverá ser concedida permissão no Cadastro de Tipo de Documento.
								Help(NIL, NIL, STR0127, NIL, OemToAnsi(STR0134)+" ("+Alltrim(QAX010MsgA(aAvisos[nI,6]))+") "+OemToAnsi(STR0135)+Alltrim(aAvisos[nI,2])+" "+aAvisos[nI,3]+","+OemToAnsi(STR0137) ,1, 0, NIL, NIL, NIL, NIL, NIL, {STR0175})
								lRet := .F.
								Exit
							Else
								//Verifica o Usurio que vai receber o Aviso de Questionario TEM e QD5_ALT =S
								QD0->(DbSetOrder(2))
								IF QD0->(DBSeek(aAvisos[nI,1]+aAvisos[nI,2]+aAvisos[nI,3]+QD5->QD5_AUT+cUsrFil+cDepto+cUsrMat))
									AADD(aTiAus,QD0->QD0_AUT)
									Exit
								Else
									// STR0127 - Atenção
									// STR0173 - Usuário não tem permissão para receber aviso.
									// STR0174 - Efetue a transferencia de alguma pendência(Elaboração, Revisão, Aprovação ou Homologação) do documento e repita a transferencia de aviso.
									Help(NIL, NIL, STR0127, NIL, STR0173,;
										1, 0, NIL, NIL, NIL, NIL, NIL, {STR0174})
									lRet := .F.
									Exit
								EndiF
							EndiF
						Endif
						IF !lRet
							Exit
						Endif
						QD5->(DbSkip())
					Enddo
				Endif
			ElseIF aAvisos[nI,6]== "TRE"

				//Verifica o Usurio que vai receber o Aviso de Treinamento TEM e DISTSN (SIM)
				IF cDist =="2"
					MsgAlert(OemToAnsi(STR0134)+" ("+Alltrim(QAX010MsgA(aAvisos[nI,6]))+"), "+OemToAnsi(STR0138),OemToAnsi(STR0127)) //"O usuário informado para receber o aviso de"###" NÃO está indicado como um distribuidor no cadastro !"###"Atencao"
					lRet  := .F.
				Else
					IF QDZ->(DBSeek(aAvisos[nI,1]+aAvisos[nI,2]+aAvisos[nI,3]+cDepto+cUsrMat+cUsrFil))
						AADD(aTiAus,"I")
					Else
						nPosT := aScan(aPenDoc,{ |x| Alltrim(x[1])+x[8]+x[2]+x[3] == "I"+aAvisos[nI,1]+aAvisos[nI,2]+aAvisos[nI,3] }) //Por Documento
						nPosP := aScan(aTpPen ,{ |x| Alltrim(x[4]) == "I" })	 //Verifica a Transferencia"
						If (IIF(nPosT > 0, aPenDoc[nPosT,6] != (cUsrFil+cUsrMat),.T.))  .AND. ;
								(aTpPen[nPosP,1] .AND. aTpPen[nPosP,2] .AND. aTpPen[nPosP,5] != (cUsrFil+cUsrMat)) 	//Verifica a Transferencia de  "Distribuidor"
							lRet  := .F.
						Endif
					Endif
					IF !lRet
						MsgAlert(OemToAnsi(STR0134)+" ("+Alltrim(QAX010MsgA(aAvisos[nI,6]))+") "+OemToAnsi(STR0135)+Alltrim(aAvisos[nI,2])+" "+aAvisos[nI,3]+","+OemToAnsi(STR0139),OemToAnsi(STR0127)) //"O usuário informado para receber o aviso de"###"no documento ###"" NÃO está indicado como distribuidor!"###"Atencao"
					Endif
				Endif
			ElseIF aAvisos[nI,6]== "CAN" .AND. cMvQLIBLEI == "N"
				
				//Verifica o Usurio que vai receber o Aviso de Cancelado e um usuario leitor
				QDG->(DbSetOrder(3))
				IF !QDG->(DBSeek(aAvisos[nI,1]+aAvisos[nI,2]+aAvisos[nI,3]+cUsrFil+cDepto+cUsrMat))
					nPosT := aScan(aPenDoc,{ |x| Alltrim(x[1]) == "L" .AND. (x[8]+x[2]+x[3] +aAvisos[nI,1]+aAvisos[nI,2]+aAvisos[nI,3]) }) //Por Documento
					If (IIF(nPosT > 0, aPenDoc[nPosT,6] != (cUsrFil+cUsrMat),.F.))
						lRet  := .F.
					Endif
					IF !lRet
						MsgAlert(OemToAnsi(STR0134)+" ("+Alltrim(QAX010MsgA(aAvisos[nI,6]))+") "+OemToAnsi(STR0135)+Alltrim(aAvisos[nI,2])+" "+aAvisos[nI,3]+","+OemToAnsi(STR0140),OemToAnsi(STR0127)) //"O usuário informado para receber o aviso de"###"no documento "###" NÃO está indicado como um Leitor!"###"Atencao"
					Endif
				Endif
				QDG->(DbSetorder(nOrdQDG))
			ElseIF aAvisos[nI,6]== "TI "

				//Verifica o Usurio que vai receber o Aviso de Treinamento e um usuario a ser treinado
				QDA->(DbSetOrder(2))
				IF QDA->(DBSeek(aAvisos[nI,1]+aAvisos[nI,2]+aAvisos[nI,3]))
					While QDA->(!EOF()) .AND. (QDA->QDA_FILIAL+QDA->QDA_DOCTO+QDA->QDA_RV)==(aAvisos[nI,1]+aAvisos[nI,2]+aAvisos[nI,3])
						QD8->(DbSetOrder(1))
						IF !QD8->(DBSeek(QDA->QDA_FILIAL+QDA->QDA_ANO+QDA->QDA_NUMERO+cUsrFil+cDepto+cCodFun+cUsrMat)) .AND. QD8->QD8_BAIXA !="S"
							MsgAlert(OemToAnsi(STR0134)+" ("+Alltrim(QAX010MsgA(aAvisos[nI,6]))+") "+OemToAnsi(STR0135)+Alltrim(aAvisos[nI,2])+" "+aAvisos[nI,3]+","+OemToAnsi(STR0141),OemToAnsi(STR0127)) //"O usuário informado para receber o aviso de"###"no documento "###" NÃO está indicado como um treinando!""###"Atencao"
							lRet  := .F.
							Exit
						Endif
						QDA->(DbSkip())
					Enddo
				Endif
				QDA->(DbSetorder(nOrdQDA))
			Endif
		Endif
		IF lRet
			For nY:= 1 to Len(aTiAus)

				//Verifica a Existencia de Ausencia Temporia para o Usuario Destino
				IF QA_SitAuDP(cUsrFil,cUsrMat,aTiAus[nY])
					Help(" ",1,"QX040JEAP",,aTpPen[Ascan(aTpPen,{|x| x[POS_aTpPen_TPPEND]==aTiAus[nY]}),3]+" (" + Alltrim(cUsrMat) + "-" + AllTrim(QA_NUSR(cUsrFil,cUsrMat)) + ")",05,00) // "Ja existe Ausencia Temporaria cadastrada no Periodo para este Usuario."
					lRet  := .F.
				Endif
				IF lRet

					//Verifica a Existencia de Ausencia Temporia para o Usuario Origem
					IF QA_SitAuDP(cFilAtu,cMatAtu,aTiAus[nY])
						Help(" ",1,"QX040JEAP",,aTpPen[Ascan(aTpPen,{|x| x[POS_aTpPen_TPPEND]==aTiAus[nY]}),3]+" (" + Alltrim(cMatAtu) + "-" + AllTrim(QA_NUSR(cFilAtu,cMatAtu)) + ")",05,00) // "Ja existe Ausencia Temporaria cadastrada no Periodo para este Usuario."
						lRet  := .F.
					Endif
				Endif
				IF !lRet
					Exit
				Endif
			Next
		Endif
		IF !lRet
			Exit
		Endif
	Next

Return(lRet)



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QAX010QDD ºAutor  ³Telso Carneiro      º Data ³  01/02/2006 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica a Existencia da matriz de Responsabilidade na     º±±
±±º          ³ para a Transferencia e valida o usuario transferido        º±±
±±º          ³ pertence a matriz de Responsabilidade        			  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe	 ³QAX010Lib(aTpPen,aPenDoc,cFilAtu,cMatAtu,cDepAtu,			  º±±
±±º	    	 ³			nItem3,nItem5)                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametro ³aTpPen - Array com o Tipos de Pendencia e Usuario que Recebeº±±
±±º          ³aPenDoc- Array com o Documentos sinconizadro com aTpPen     º±±
±±º          ³cFilAtu- Filial do Usuario Transferido                      º±±
±±º          ³cMatAtu- Matricula do Usuario Transferido      			  º±± 
±±º          ³cDepAtu- Departamento do Usuario Transferido                º±±
±±º          ³nItem3 - Intem de Transferencia de Filial/Depto  			  º±±
±±º          ³nItem5 - Tipo de Transferencia                   			  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function QAX010QDD(aTpPen,aPenDoc,cFilAtu,cMatAtu,cDepAtu,nItem3,nItem5,nItem2,cCcPara,aFalhas)

	Local aArea    := GetArea()
	Local aAreaQAA := QAA->(GetArea())
	Local aAreaQDD := QDD->(GetArea())
	Local cDepto   := ""
	Local cUsrFil  := ""
	Local cUsrMat  := ""
	Local lResp    := .T.
	Local nA       := 0
	Local nPosA    := 0
	Local nU       := 0

	QAA->(DbSetOrder(1))

	For nA := 2 to 5 //Tipos de Pendencia da Matriz QDD
		If  aTpPen[nA,1] == .F. .Or. aTpPen[nA,2] == .F.
			Loop
		Endif

		nPosA := aScan(aPenDoc, { |x| Left(x[1],1) == aTpPen[nA,4] } )
		nPosA := If(nPosA == 0,Len(aPenDoc),nPosA)

		For nU := nPosA to Len(aPenDoc)
			If Left(aPenDoc[nU,1],1) <> aTpPen[nA,4]
				Exit
			Endif

			If nItem3 == 2

				If (aPenDoc[nU,4]) == .F. .Or. ;
						( Empty(aTpPen[nA,5]) .And. Empty(aPenDoc[nU,6]) .And. nItem5 <> 4)
					Loop
				Endif

			Endif

			IF !Empty(aTpPen[nA,POS_aTpPen_DESTINATARIO])      // Pendencias
				cUsrFil:= SUBS(aTpPen[nA,POS_aTpPen_DESTINATARIO],1,FWSizeFilial())
				cUsrMat:= SUBS(aTpPen[nA,POS_aTpPen_DESTINATARIO],FWSizeFilial()+1)
			Endif

			IF !Empty(aPenDoc[nU,POS_PendDoc_POR_DOC_FIL_MAT]) // Por Documento
				cUsrFil:= SUBS(aPenDoc[nU,POS_PendDoc_POR_DOC_FIL_MAT],1,FWSizeFilial())
				cUsrMat:= SUBS(aPenDoc[nU,POS_PendDoc_POR_DOC_FIL_MAT],FWSizeFilial()+1)
			Elseif Empty(cUsrFil).and. Empty(cUsrMat)
				cUsrFil:=cFilMat
				cUsrMat:=cMatAtu
			Endif

			QAA->(DBSeek(cUsrFil+cUsrMat))
			If !Empty(cCcPara) .and. nItem3 == 1
				cDepto:=cCcPara
			Else
				cDepto:=QAA->QAA_CC
			Endif
			cCargo:=QAA->QAA_CODFUN

			// Posiciona no Docto
			QDH->(dbSetOrder(1))
			QDH->(dbSeek(aPenDoc[nU,POS_PendDoc_FILIAL]+;
			             aPenDoc[nU,POS_PendDoc_DOCTO ]+;
						 aPenDoc[nU,POS_PendDoc_RV    ]))

			QDD->(DbSetOrder(1))
			If QDD->(DbSeek(aPenDoc[nU,POS_PendDoc_FILIAL]+;
			                QDH->QDH_CODTP                +;
							aTpPen[nA,POS_aTpPen_TPPEND   ]))

				lResp := .F.

				While QDD->(!Eof()) .And. QDD->QDD_FILIAL+QDD->QDD_CODTP+QDD->QDD_AUT == QDH->QDH_FILIAL+QDH->QDH_CODTP+aTpPen[nA,POS_aTpPen_TPPEND]
					IF QDD->QDD_FILA   == cUsrFil .AND.;
					   QDD->QDD_DEPTOA == cDepto  .And.;
					   QDD->QDD_CARGOA == cCargo
						lResp:=.T.
					Endif
					QDD->(DbSkip())
				Enddo

				IF !lResp
					IF ASCAN(aFalhas,{|X| X[POS_Falhas_Legenda] == 2                              .AND.;
					                      X[POS_Falhas_Docto]   == aPendoc[nU,POS_PendDoc_DOCTO]  .AND.;
					                      X[POS_Falhas_Revisao] == aPendoc[nU,POS_PendDoc_RV]     .AND.;
										  X[POS_Falhas_TpPend]  == aPendoc[nU,POS_PendDoc_TPPEND] .AND.;
										  X[POS_Falhas_FilMat]  == cUsrFil                        .AND.;
										  X[POS_Falhas_Mat]     == cUsrMat }) == 0

						AADD(aFalhas,{2                             ,;
						              aPendoc[nU,POS_PendDoc_DOCTO] ,;
						              aPendoc[nU,POS_PendDoc_RV]    ,;
									  AllTrim(aPendoc[nU,POS_PendDoc_TPPEND] + " - " + QA_NSIT(aPendoc[nU,POS_PendDoc_TPPEND])),;
									  Posicione("QDH",1,xFilial("QDH", cUsrFil) + aPendoc[nU,POS_PendDoc_DOCTO] + aPendoc[nU,POS_PendDoc_RV],"QDH_CODTP"),;
									  cUsrFil                       ,;
									  cUsrMat                       ,;
									  QA_NUSR(cUsrFil,cUsrMat)       ;
									 })

					Endif
				Endif
			EndIf
		Next
	Next

	QDD->(RestArea(aAreaQDD))
	QAA->(RestArea(aAreaQAA))
	ResTArea(aArea)

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³FQAXA010ICE³ Autor ³Leandro S. Sabino     ³ Data ³ 22/08/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Valida a transferencia de usuario entre filiais 			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³FQAXA010ICE(cCCFilial)					              	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ExpN1 - Numero identificando a filial 					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³QAXA010()                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function FQAXA010ICE(cCCFilial)

	Local lRet    := .T.

	If cCCFilial <> xFilial("QAA")
		DbSelectArea("IC2")
		DbSetOrder(2)

		If IC2->(DbSeek(xFilial("IC2")+cMatAtu))
			MSGALERT(STR0154)//"Usuario não podera ser transferido de filial, pois  pertence a um comite Gestor de Risco."
			lRet:= .F.
		EndIf

	EndIf

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QAXA010   ºAutor  ³Renata Cavalcante   º Data ³  05/23/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Validação na Confirmação da tela                           º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Validação de Responsável, ou se é único Destinatário do Docº±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function QAX010VLTP(nOpc)

	Local aArea:= GetArea()
	Local lRet:= .T.
	Local cMat:= M->QAA_MAT
	Local cDoc:= ""
	Local nCont:=0
	Local cRecno

	If nOpc == 4 .and. M->QAA_TPRCBT == "4"     // verifica se é alteração e se o tipo de recebimento foi alterado para Não Recebe
		DbSelectArea("QAD")
		DbSetOrder(2)
		If DbSeek(XFilial("QAD")+cMat)
			messagedlg(STR0155)//"O usuário consta como responsável por departamento(s) não é permitido a alteração do tipo de recebimento para não recebe"
			lRet:= .F.

		Endif

		DbSelectArea("QDG")
		DbSetorder(8)
		If DbSeek(cfilAnt+cMat)
			While !EOF() .And. QDG->QDG_MAT == cMat
				If QDG->QDG_DOCTO <> cDoc
					cDoc:= QDG->QDG_DOCTO
					cRev:= QDG->QDG_RV
				Else
					QDG->(DbSkip())
				Endif
				cRecno:= QDG->(Recno())
				DBSELECTAREA("QDG")
				DbSetorder(1)
				DBGOTOP()
				If DbSeek(XFilial("QDG")+cDoc+cRev) // Verifica se está como o único destinatário do documento
					While !EOF() .And. QDG->QDG_DOCTO == cDoc .and. QDG->QDG_RV == cRev
						nCont++
						QDG->(DbSkip())
					enddo
					If nCont == 1
						DbSelectArea("QDH")
						DbSetOrder(1)
						If Dbseek(Xfilial("QDH")+cDoc+cRev)
							IF QDH_STATUS <> "L"
								lRet:= .F.
								messagedlg(STR0156)//"O usuário consta como único destinatário de documento(s) portanto o tipo de recebimento não poderá estar como não recebe"
								exit
							Endif
						Endif
					Endif
				Endif
				nCont:=0
				DbSelectarea("QDG")
				DbSetorder(8)
				dbgoto(cRecno)
				QDG->(DbSkip())

			Enddo
		Endif
	Endif
	RestArea(aArea)

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ QA010TCR º Autor ³Paulo Fco. Cruz Nt. º Data ³  29/12/2009 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Efetua a transferência de pendências com crítica	(EC/DC)	  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe	 ³ QA010TCR(cChkFil,cChkMat,cChkTpPnd,cCcFilAtu,cCcMatAtu,	  º±±
±±º          ³ cCcAtu,aPenDoc)						  					  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametro ³ cChkFil	 - Filial do Usuario Origem						  º±±
±±º          ³ cChkMat	 - Matricula do Usuario Origem					  º±±
±±º          ³ cChkTpPnd - Tipo de pendência na transferência			  º±±
±±º          ³ cCcFilAtu - Filial do Usuario Destino					  º±± 
±±º          ³ cCcMatAtu - Matricula do Usuario Destino					  º±±
±±º          ³ cCcAtu 	 - Departamento do Usuario Destino				  º±±
±±º          ³ aPenDoc 	 - Vetor com a pendencia transferida			  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function QA010TCR(cChkFil,cChkMat,cChkTpPnd,cCcFilAtu,cCcMatAtu,cCcAtu,aPenDoc)
	Local aArea		  := GetArea()
	Local nTamTpPnd	  := TamSx3("QD1_TPPEND")[1]
	Local aAreaQD1    := {}
	Local aRegAlt	  := {}
	Local nI		  := 0
	Local lGrava	  := .T.

	Default cChkFil	  := Space(FWSizeFilial())//Space(2)
	Default cChkMat	  := Space(TAMSX3("QAA_MAT")[1])
	Default cChkTpPnd := Space(3)
	Default cCcFilAtu := Space(FWSizeFilial())//Space(2)
	Default cCcMatAtu := Space(TAMSX3("QAA_MAT")[1])
	Default cCcAtu	  := Space(TAMSX3("QAA_CC")[1])
	Default aPenDoc	  := {}

	If cChkTpPnd $ "D|E"
		DBSelectArea("QD1")
		DbSetOrder(2)
		QD1->(DbSeek(aPenDoc[8]+aPenDoc[2]+aPenDoc[3]))
		While QD1->(!Eof()) .AND. (QD1->QD1_FILIAL+QD1->QD1_DOCTO+QD1->QD1_RV==aPenDoc[8]+aPenDoc[2]+aPenDoc[3])
			aAreaQD1 := QD1->(GetArea())
			If QD1->QD1_TPPEND == PadR(cChkTpPnd+"C",nTamTpPnd) .And. cChkFil+cChkMat == QD1->QD1_FILMAT+QD1->QD1_MAT
				QD1->(dbSetOrder(8))
				QD1->(dbGoTop())
				If !QD1->(dbSeek(aPenDoc[8]+aPenDoc[2]+aPenDoc[3]+cCcAtu+cCcFilAtu+cCcMatAtu+PadR(cChkTpPnd+"C",nTamTpPnd)+" "))
					If Len(aRegAlt) > 0
						For nI:=1 To Len(aRegAlt)
							If aPenDoc[8]+aPenDoc[2]+aPenDoc[3]+cCcAtu+cCcFilAtu+cCcMatAtu+PadR(cChkTpPnd+"C",nTamTpPnd)+" "+cvaltochar(aPenDoc[7]) == aRegAlt[nI]
								lGrava := .F.
							Endif
						Next nI
					Endif
					If lGrava
						RestArea(aAreaQD1)
						Aadd(aRegAlt,aPenDoc[8]+aPenDoc[2]+aPenDoc[3]+cCcAtu+cCcFilAtu+cCcMatAtu+PadR(cChkTpPnd+"C",nTamTpPnd)+" "+cvaltochar(QD1->(RecNo())))
						RecLock("QD1",.F.)
						QD1->QD1_FILMAT	:= cCcFilAtu
						QD1->QD1_MAT	:= cCcMatAtu
						QD1->QD1_DEPTO	:= cCcAtu
						QD1->QD1_SIT	:= " "
						QD1->(MsUnlock())
						QD1->(FKCOMMIT())
					Else
						RestArea(aAreaQD1)
						RecLock("QD1",.F.)
						QD1->(DbDelete())
						QD1->(MsUnlock())
						QD1->(FKCOMMIT())
					Endif
				Else
					RestArea(aAreaQD1)
					RecLock("QD1",.F.)
					QD1->(DbDelete())
					QD1->(MsUnlock())
					QD1->(FKCOMMIT())
				Endif
			EndIf
			QD1->(DbSkip())
			lGrava := .T.
		EndDo
	EndIf

	RestArea(aArea)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ QA010CRP º Autor ³Paulo Fco. Cruz Nt. º Data ³  29/12/2009 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica se existem pendencias com critica pendentes		  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe	 ³ QA010CRP(cFil,cDoc,cRv,cTpPend,cFilMat,cMat,cCC)			  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametro ³ cFil 	- Filial do pendencia							  º±±
±±º          ³ cDoc 	- Codigo do documento							  º±±
±±º          ³ cRv		- Revisao do documento							  º±±
±±º          ³ cTpPend	- Tipo da pendencia								  º±± 
±±º          ³ cFilMat	- Filial do usuario da pendencia				  º±±
±±º          ³ cMat		- Matricula do usuario da pendencia				  º±±
±±º          ³ cCC		- Departamento do usuario da pendencia			  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function QA010CRP(cFil,cDoc,cRv,cTpPend,cFilMat,cMat,cCC)
	Local aArea		:= GetArea()
	Local aQD1		:= QD1->(GetArea())
	Local aQDH		:= QDH->(GetArea())
	Local nA		:= 1
	Local nTamTpPnd	:= TamSx3("QD1_TPPEND")[1]
	Local cQuery	:= ""
	Local cFilBsc	:= Space(FWSizeFilial())//Space(2)
	Local cMatBsc	:= Space(TamSx3("QAA_MAT")[1])
	Local cDepBsc	:= Space(TamSx3("QAA_CC")[1])
	Local cTrCancel := GetNewPar("MV_QTRCANC","1")
	Local lExiste	:= .F.

	Static aPenCrit
	Static cLastUsr

	Default cFil 	:= Space(FWSizeFilial())
	Default cDoc	:= ""
	Default cRv		:= ""
	Default cTpPend	:= ""
	Default cFilMat	:= ""
	Default cMat	:= ""
	Default cCC		:= ""

	If (ValType(aPenCrit) != "A" .Or. ValType(cLastUsr) != "C") .Or. cLastUsr != cFilMat+cMat

		aPenCrit := {}
		cLastUsr := cFilMat+cMat

		For nA := 1 to Len(aBuscaQD1)
			cFilBsc := aBuscaQD1[nA,1]
			cMatBsc := aBuscaQD1[nA,2]
			cDepBsc := aBuscaQD1[nA,3]

			//Carrega as pendencias com critica (DC/EC)
			cQuery := " SELECT QD1.QD1_FILIAL,QD1.QD1_DOCTO,QD1.QD1_RV,QD1.QD1_TPPEND,QD1.QD1_PENDEN,QD1.QD1_FILMAT,QD1.QD1_MAT,QD1.QD1_DEPTO"//,QD1.R_E_C_N_O_"
			cQuery += " FROM " + RetSqlName("QD1")+" QD1 "
			cQuery += " WHERE QD1.QD1_FILMAT = '"+cFilBsc+"' AND QD1.QD1_MAT = '"+cMatBsc+"' AND QD1.QD1_SIT <> 'I'"
			cQuery += " AND QD1.QD1_TPPEND IN ('EC','DC')"
			cQuery += " AND QD1.QD1_PENDEN = 'P'"
			cQuery += " AND QD1.D_E_L_E_T_ = ' ' "

			cQuery += " AND NOT EXISTS(SELECT R_E_C_N_O_ FROM "+ RetSqlName("QDH")+" QDH WHERE QD1.QD1_FILIAL = QDH.QDH_FILIAL "
			cQuery += " AND QD1.QD1_DOCTO = QDH.QDH_DOCTO AND QD1.QD1_RV = QDH.QDH_RV"
			If cTrCancel =="2"
				cQuery += " AND QDH.QDH_OBSOL = 'S' AND QDH.QDH_STATUS = 'L'"
			Else
				cQuery += " AND (QDH.QDH_OBSOL = 'S' Or (QDH.QDH_CANCEL = 'S' And QDH.QDH_STATUS = 'L'))"
			EndIf
			cQuery += " AND QDH.D_E_L_E_T_ = ' ')"
			cQuery += " ORDER BY QD1.QD1_FILIAL,QD1.QD1_TPPEND,QD1.QD1_DOCTO,QD1.QD1_RV "
			cQuery := ChangeQuery(cQuery)

			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QD1TRB",.T.,.T.)

			While QD1TRB->(!Eof())

				//Atualiza o array com as pendencias DC/EC
				If aScan(aPenCrit,{|x| x[1] == QD1TRB->QD1_FILIAL .And. x[2] == QD1TRB->QD1_DOCTO .And. x[3] == QD1TRB->QD1_RV .And. x[4] == QD1TRB->QD1_TPPEND }) == 0
					aAdd(aPenCrit,{QD1TRB->QD1_FILIAL,QD1TRB->QD1_DOCTO,QD1TRB->QD1_RV,QD1TRB->QD1_TPPEND,QD1TRB->QD1_PENDEND,QD1TRB->QD1_FILMAT,QD1TRB->QD1_MAT,QD1TRB->QD1_DEPTO})
				EndIf

				QD1TRB->(DbSkip())
			EndDo

			QD1TRB->(DbCloseArea())
		Next
	EndIf

	cTpPend := PadR(AllTrim(cTpPend)+"C",nTamTpPnd)

	If !Empty(aPenCrit) .And. cTpPend $ "DC |EC " .And. ;
			aScan(aPenCrit,{|x| x[1]+x[2]+x[3]+x[4]+x[6]+x[7] == cFil+cDoc+cRv+cTpPend+cFilMat+cMat}) > 0

		lExiste := .T.
	EndIf

	RestArea(aArea)
	QD1->(RestArea(aQD1))
	QDH->(RestArea(aQDH))

Return lExiste

/*/{Protheus.doc} fMontPerg
Função que monta um pergunte manual
@type  Function
@author thiago.rover
@since 18/06/2021
/*/
Function fMontPerg() 

	Local cDoctoAt := aArryPg[POS_TR_DocumentoATE]
	Local cDoctoDe := aArryPg[POS_TR_DocumentoDE]
	Local cPict    := ""
	Local cRevAt   := aArryPg[POS_TR_RevisaoATE]
	Local cRevDe   := aArryPg[POS_TR_RevisaoDE]
	Local dDataAt  := aArryPg[POS_TR_DataATE]
	Local dDataDe  := aArryPg[POS_TR_DataDE]
	Local nOpcao   := 0
	Local oDataAt  := Nil
	Local oDataDe  := Nil
	Local oDlg     := Nil
	Local oDoctoAt := Nil
	Local oDoctoDe := Nil
	Local oGet1    := Nil
	Local oGet2    := Nil
	Local oRevAt   := Nil
	Local oRevDe   := Nil

	DEFINE MSDIALOG oDlg FROM 000,000 TO 20, 50 TITLE OemToAnsi(STR0161) // "Filtros"

	//Filtros de Data
	@10, 15 Say STR0183 Size 70, 07 Of oDlg  Pixel  // "Data De:"
	@10, 65 MSGET oDataDe VAR dDataDe PICTURE cPict SIZE 50, 09 WHEN .T.  OF oDlg PIXEL
	oDataDe:bHelp := {|| ShowHelpCpo("dDataDe",{STR0186},2,,2)}
	//STR0186 - "Data de geração inicial para filtro das responsabilidades."

	@30, 15 Say STR0184 Size 70, 07 Of oDlg  Pixel // "Data Até:"
	@30, 65 MSGET oDataAt VAR dDataAt PICTURE cPict SIZE 50, 09 WHEN .T. OF oDlg PIXEL
	oDataAt:bHelp := {|| ShowHelpCpo("oDataAt",{STR0187},2,,2)}
	//STR0187 - "Data de geração final para filtro das responsabilidades."

	//Filtros de Documento
	@50, 15 Say STR0162 Size 70, 07 Of oDlg  Pixel // "Documento De: "
	@50, 65 MSGET oDoctoDe VAR cDoctoDe SIZE 70, 09 OF oGet1 PIXEL PICTURE cPict F3 "QDH" 
	oDoctoDe:bHelp := {|| ShowHelpCpo("oDoctoDe",{STR0188},2,,2)}
	//STR0188 - "Código de documento inicial para filtro das responsabilidades."

	@70, 15 Say STR0164 Size 70, 07 Of oDlg  Pixel // "Documento Até: "
	@70, 65 MSGET oDoctoAt VAR cDoctoAt SIZE 70, 09 OF oGet2 PIXEL PICTURE cPict F3 "QDH"
	oDoctoAt:bHelp := {|| ShowHelpCpo("oDoctoAt",{STR0189},2,,2)}
	//STR0189 - "Código de documento final para filtro das responsabilidades."

	//Filtros de Revisão
	@90, 15 Say STR0163 Size 70, 07 Of oDlg  Pixel  // "Revisão De: "
	@90, 65 MSGET oRevDe VAR cRevDe PICTURE cPict SIZE 50, 09 WHEN .T.  OF oDlg PIXEL
	oRevDe:bHelp := {|| ShowHelpCpo("oRevDe",{STR0190},2,,2)}
	//STR0190 - "Código da revisão inicial para filtro das responsabilidades."

	@110, 15 Say STR0165 Size 70, 07 Of oDlg  Pixel // "Revisão Até: "
	@110, 65 MSGET oRevAt VAR cRevAt PICTURE cPict SIZE 50, 09 WHEN .T. OF oDlg PIXEL
	oRevAt:bHelp := {|| ShowHelpCpo("oRevAt",{STR0191},2,,2)}
	//STR0191 - "Código da revisão final para filtro das responsabilidades."
	
	//botões
	DEFINE SBUTTON FROM 130, 080 TYPE 1 ACTION (nOpcao:= 1,oDlg:End()) ENABLE OF oDlg
	DEFINE SBUTTON FROM 130, 110 TYPE 2 ACTION (nOpcao:= 2,oDlg:End()) ENABLE OF oDlg

	ACTIVATE MSDIALOG oDlg CENTERED

	If nOpcao == 1

		If Empty(cDoctoAt) .Or. Empty(cRevAt)
			fMontPerg()
		EndIf

		aArryPg     := {dDataDe ,;
						dDataAt ,;
						cDoctoDe,;
						cDoctoAt,;
						cRevDe  ,;
						cRevAt   }
		
	EndIf

Return nOpcao == 1

/*/{Protheus.doc} fAtuFltDoc
Função para atribuição dos filtros de documentos aFltDoc - PERFORMANCE/LEGADO
@type  Function
@author brunno.costa / thiago.rover (fMontPerg)
@since 02/04/2024 / 18/06/2021
/*/
Function fAtuFltDoc()

	Local cQuery := ""

	cQuery := " SELECT DISTINCT QDH_DOCTO, QDH_RV From "+ RetSqlName("QDH")+" QDH"
	cQuery += " WHERE "
	If !Empty(aArryPg[POS_TR_DocumentoDE]) .Or. !Empty(aArryPg[POS_TR_RevisaoDE])
		lVldPer := .T.
		cQuery += " QDH_DOCTO BETWEEN '"+aArryPg[POS_TR_DocumentoDE]+"' AND '"+aArryPg[POS_TR_DocumentoATE]+"'"
		cQuery += " AND QDH_RV BETWEEN '"+aArryPg[POS_TR_RevisaoDE]+"' AND '"+aArryPg[POS_TR_RevisaoATE]+"' AND "
	Endif
	cQuery += " D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery(cQuery) 
								
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QDHTRB",.T.,.T.)

	// Inicialização da variável
	aFltDoc := {} 

	WHILE QDHTRB->(!EOF())
		aAdd(aFltDoc , { QDHTRB->QDH_DOCTO, QDHTRB->QDH_RV,})
		QDHTRB->(DbSkip())
	EndDo

	QDHTRB->(DbCloseArea())
Return

/*/{Protheus.doc} valAltFunc
	Função que valida se o usuário está alterando o cargo/função - DMANQUALI-2724
	@type  Function
	@author cintia.paul	
	@since 07/07/2021
	@example
	(examples)
	@see (links_or_references)
/*/
Function valAltFunc()

	Local cCodFun := QAA->QAA_CODFUN

	If Altera .And. !(cCodFun == M->QAA_CODFUN) 

			//Aviso
			//Ao alterar a função do usuário, o mesmo pode ficar sem permissão para baixar pendências. 
			//Revise se usuário possui pendências e transfira as mesmas para um novo responsável ou realize a baixa das pendências antes desta alteração.
			//O Relatório de Pendências - QDOR050 poderá ser utilizado realizar esta verificação.
			Help("",1,"ALTFUNCAO",,STR0168,1,0,,,,,,{STR0169, ' ', STR0170}) 

	Endif	
	
Return .T.

/*/{Protheus.doc} QAX010TOK
@type Static Function
@author rafael.hesse
@since 29/04/2022
@param nOpc, numérico, indica a operação da rotina
@return lRet, Lógico, indica se o cadastro está válido para inclusão/alteração
/*/
Static Function QAX010TOK(nOpc)
	Local cAliasQDZ   := ""
	Local lImplantado := .F.
	Local lRet        := .F.
	Local oDocControl := Nil
	Local oQAXA010Aux := QAXA010AuxClass():New()

	If Obrigatorio(aGets,aTela) .And. QX10VldEmp(lIntGPE) .And. QA010VrCfg(.T.) .And. QAX010VLTP(nOpc)	
		lRet := .T.  
	EndIf

	If lRet .and. M->QAA_TPWORD == '4'
		If FindClass(Upper("QDODocumentControl"))
			oDocControl 	:= QDODocumentControl():New()
			lRet := !oDocControl:validaInconsistenciaImplantacao(@lImplantado, .T.) 
			If lRet .and. !lImplantado
				//STR0171 "Implantação não executada."
				//STR0172 "Opção disponível apenas após a execução do implantador 'QDOWIZPDF'  "
				Help( " ", 1, "QX10IMPDOC",,STR0171 ,1, 1,,,,,, {STR0172})
				lRet := .F.
			Endif
		Endif

	ElseIf lRet .and. M->QAA_TPWORD == '2'
		//Exibe help, quando for o caso
		//"A leitura de documentos com Word Viewer é incompatível em bases com a implantação da leitura interna."
		//"Utilize outra opção de leitura diferente de '2 = Word Viewer'."
		lRet := QDOVlWorVi(2)
	EndIf

	If lRet .And. Altera .And. M->QAA_STATUS == '2'
		lRet := QAAValIna()
	EndIf

	If lRet .And. M->QAA_DISTSN = "2" .And. M->QAA_DISTSN <> QAA->QAA_DISTSN

		If oQAXA010Aux:validaSeOUsuarioEOUnicoDistribuidorDeAlgumDocumento(@cAliasQDZ)
			
			// STR0223 - O documento
			// STR0224 - não possuirá distribuidores válidos após a alteração.
			// STR0218 - Transfira primeiro as responsabilidades de distribuição do usuário:  XX
			// STR0219 - para novo usuário e depois modifique o campo de distribuidor do documento.
			Help("",1, "QDONODISTVALID", , STR0223 + " " + AllTRIM((cAliasQDZ)->QDZ_DOCTO) + "-" + AllTrim((cAliasQDZ)->QDZ_RV) + " " + STR0224, 1, 0, , , ,, , ;
		                                  {STR0218 + " " + ALLTRIM(QAA->QAA_NOME) + " " + STR0219}) 
			lRet := .F.

			(cAliasQDZ)->(DbCloseArea())

		ElseIf oQAXA010Aux:validaSeOUsuarioEDistribuidorDeAlgumDocumento(@cAliasQDZ)
			
			// STR0215 - Atenção
			// STR0220 - O usuário XX
			// STR0221 - será removido da lista de distribuidores dos documentos que estão até a fase de homologação, 
			//           essa ação não poderá ser revertida. Deseja Continuar ?
			If MsgYesNo(STR0220+""+ALLTRIM(QAA->QAA_NOME)+""+ STR0221,STR0215) 
				
				DBSelectArea("QDZ")
				QDZ->(DbSetOrder(1))
				If QDZ->(DbSeek((cAliasQDZ)->(QDZ_FILIAL + QDZ_DOCTO + QDZ_RV + QDZ_DEPTO + QDZ_MAT + QDZ_FILMAT)))
					While QDZ->(!Eof()) .And.  ;
					        QDZ->(QDZ_FILIAL + QDZ_DOCTO + QDZ_RV + QDZ_DEPTO + QDZ_MAT + QDZ_FILMAT) == ;
					        (cAliasQDZ)->(QDZ_FILIAL + QDZ_DOCTO + QDZ_RV + QDZ_DEPTO + QDZ_MAT + QDZ_FILMAT)
						
						RecLock("QDZ",.F.)
							QDZ->(DbDelete())
							QDZ->(MsUnLock())
						FKCOMMIT()
						QDZ->(DbSkip())
					Enddo
				Endif
			Else
				lRet := .F.
			Endif
			QDZ->(dbCloseArea())
		Endif
	Endif

Return lRet

/*/{Protheus.doc} QAAValExc
Função que valida se o usuário está apto a ser excluido
@type  Function
@author rafael.hesse
@since 13/07/2022
@return lRet, Lógico, indica se o cadastro está válido para Exclusão.
/*/
Function QAAValExc()

	Local lRet    := .T.

	If !(QNC070VExc() .And. QEA050VdDel() .And. QAX010VdEx())
		// "Existe Lancamentos para este Usuario nao e permitido a exclusao"
		// "Consulte o Follow Up/Etapas e verifique as etapas pendentes para este Usuario."
		Help(" ",1,"QDFUNEXC") 
		lRet := .F.
	EndIf

Return lRet

/*/{Protheus.doc} QAAValIna
Função que valida se o usuário está apto a ser inativado
@type  Function
@author rafael.hesse
@since 16/08/2022
@return lRet, Lógico, indica se o cadastro está válido para Inativação.
/*/
Function QAAValIna()

	Local cAliasQD1 := GetNextAlias()
	Local cQuery    := ""
	Local lRet      := .T.
	Local oExec     := Nil

	Default lFwExecSta := FindClass( Upper("FwExecStatement") ) //Default para facilitar na cobertura

	cQuery := " SELECT "
	cQuery += 		" QD1_PENDEN "
	cQuery += " FROM "
	cQuery += 		RetSqlName("QD1") + " QD1 "
	cQuery += " WHERE "
	cQuery += 		" QD1.D_E_L_E_T_ = ' ' "
	cQuery += 		" AND QD1.QD1_MAT = '" + M->QAA_MAT + "' "
	cQuery += 		" AND QD1.QD1_FILMAT = '" + M->QAA_FILIAL + "' "
	cQuery += 		" AND QD1.QD1_PENDEN = 'P' "

	If lFwExecSta
		oExec := FwExecStatement():New(cQuery)
		cAliasQD1 := oExec:OpenAlias()
		oExec:Destroy()
		oExec := nil 
	else
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQD1)
	EndIf
	
	If (cAliasQD1)->(!EOF())
		//STR0176 "Não é possível inativar o usuário ###-#####"
		//STR0177 "Existem Lancamentos para este Usuário que o impedem de ser inativado"
		Help( " ", 1, "QDFUNINA",,STR0176 + M->QAA_MAT + " - " + M->QAA_NOME,1, 1,,,,,, {STR0177})
		lRet := .F.
	EndIf

	(cAliasQD1)->(DbCloseArea())
	
Return lRet

/*/{Protheus.doc} retornaUsuarioENomeDestinatario
Retorna Usuário/Nome do destinatário para exibição na Grid de Documentos
@author brunno.costa
@since 02/10/2024
@version 1.0
@param 01 - cDestPorResp, caracter, destinatário vinculado no array de responsabildiade aTpPen
@param 02 - cDestPorDoc , caracter, destinatário vinculado no array de documentos aPenDoc / aPendAx
@return cNome, caracter, Usuário/Nome para exibição na Grid
/*/
METHOD retornaUsuarioENomeDestinatario(cDestPorResp, cDestPorDoc) CLASS QAXA010AuxClass
	
	Local aAreaQAA := Nil
	Local cNome    := ""
	
	If Empty(cDestPorDoc)
		If Empty(cDestPorResp)
			cNome := INI_CAMPO_ADOCTOS_MAT_NOME
		Else
			aAreaQAA := QAA->(GetArea())
			QAA->(DbSetOrder(1))
			QAA->(DBSeek(cDestPorResp))
			cNome    := AllTrim(QAA->QAA_MAT)+"/"+Alltrim(QAA->QAA_NOME)
			RestArea(aAreaQAA)
		EndIf
	Else
		aAreaQAA := QAA->(GetArea())
		QAA->(DbSetOrder(1))
		QAA->(DBSeek(cDestPorDoc))
		cNome    := AllTrim(QAA->QAA_MAT)+"/"+Alltrim(QAA->QAA_NOME)
		RestArea(aAreaQAA)
	EndIf

Return cNome

/*/{Protheus.doc} retornaBLineTipoPendencia
Retorna bloco de código bLine para componente Topo de Pendência / Responsabilidades
@author brunno.costa
@since 02/10/2024
@version 1.0
@return oBloco, bloco de código, bloco de código bLine para componente Topo de Pendência / Responsabilidades
/*/
METHOD retornaBLineTipoPendencia() CLASS QAXA010AuxClass
	
	Local oBloco := { || { If(aTpPen[oTpPen:nAt, POS_aTpPen_MARCACAO], hOk, hNo ),;
	                       If(aTpPen[oTpPen:nAt, POS_aTpPen_TEM_DOCUMENTO]       ,;
						     If(!Empty(aTpPen[ oTpPen:nAt, POS_aTpPen_DESTINATARIO ]) .or. self:pendenciaPreenchidaPorDocumento(aTpPen[oTpPen:nAt, POS_aTpPen_TPPEND]),;
							    oVerde,;
								oLaranja),;
							 oCinza  ),;
						  aTpPen[ oTpPen:nAt, POS_aTpPen_RESPONSABILIDADE ] } }
	
Return oBloco

/*/{Protheus.doc} posicionarUsuarioDestino
Posiciona no registro do usuário destino da transferência com base em texto na QAA
@author brunno.costa
@since 02/10/2024
@version 1.0
@param 01 - cTexto, caracter, texto de pesquisa digitado pelo usuário
@param 02 - cOrdem, caracter, ordenação selecionada pelo usuário
@param 03 - nOpc  , número  ,
@return oBloco, bloco de código, bloco de código bLine para componente Topo de Pendência / Responsabilidades
/*/
METHOD posicionarUsuarioDestino(cTexto, cOrdem, nOpc) CLASS QAXA010AuxClass
	
	Local cAlias     := ""
	Local cCampo     := ""
	Local cFiltQry1  := ""
	Local cFiltQry2  := ""
	Local cFiltQry3  := ""
	Local cFimQry    := ""
	Local cIniQry    := ""
	Local cOrder     := ""
	Local cOrderType := "ASC"
	Local cQuery     := ""
	Local nPosAtu    := QAA->(Recno())
	Local nPrimeiro  := -1
	Local oQLTQueryM := Nil

	CursorWait()

	If !Empty(cTexto)
		If     oCombOrd:nAt == 1 // "Matricula"
			QAA->(dbSetOrder(1))
			cCampo := "QAA_MAT"

		ElseIf oCombOrd:nAt == 2 //"Nome"
			QAA->(dbSetOrder(3))
			cCampo := "QAA_NOME"

		ElseIf oCombOrd:nAt == 3 //"Nome Reduzido"
			QAA->(dbSetOrder(6))
			cCampo := "QAA_APELID"

		ElseIf oCombOrd:nAt == 4 //"Depto"
			QAA->(dbSetOrder(5))
			cCampo := "QAA_CC"

		ElseIf oCombOrd:nAt == 5 //"Descr.Depto"
			QAA->(dbSetOrder(5))
			cCampo := "QAD_DESC"

		EndIf

		If     nOpc == 1
			cOrderType := "ASC"
		ElseIf nOpc == 2
			cOrderType := "DESC"
			cOrder     := StrTran(cOrder, ",", " " + cOrderType + ", ")
		ElseIf nOpc == 3
			cOrderType := "ASC"
		EndIf
		
		cIniQry := " SELECT QAA.R_E_C_N_O_ RECNO "
		cIniQry += " FROM " + RetSqlName("QAA") + " QAA "
		If cCampo == "QAD_DESC"
			cIniQry += " INNER JOIN " + RetSqlName("QAD") + " QAD "
        	cIniQry +=   " ON QAA.QAA_CC = QAD.QAD_CUSTO "
			cIniQry +=   " AND " + QLTQCmpFil("QAA", "QAD", "QAA", "QAD")
		EndIf
		cIniQry += " WHERE "

		cFiltQry1 :=      " UPPER(" + cCampo + ") = '" + Upper(AllTrim(cTexto)) + "' "
		cFiltQry2 :=      " UPPER(" + cCampo + ") LIKE '" + Upper(AllTrim(cTexto)) + "%' "
		cFiltQry3 :=      " UPPER(" + cCampo + ") LIKE '%" + Upper(AllTrim(cTexto)) + "%' "
		
		cFimQry :=      " AND QAA.D_E_L_E_T_= ' ' "
		cFimQry += " ORDER BY " + cCampo + " " + cOrderType

		oQLTQueryM := QLTQueryManager():New()

		cQuery := oQLTQueryM:changeQuery(cIniQry + cFiltQry1 + cFimQry)
		cAlias := oQLTQueryM:executeQuery(cQuery)

		If (cAlias)->(Eof())

			cQuery := oQLTQueryM:changeQuery(cIniQry + cFiltQry2 + cFimQry)
			cAlias := oQLTQueryM:executeQuery(cQuery)

			If (cAlias)->(Eof())

				cQuery := oQLTQueryM:changeQuery(cIniQry + cFiltQry3 + cFimQry)
				cAlias := oQLTQueryM:executeQuery(cQuery)

			EndIf
		EndIf
	
		If !(cAlias)->(Eof())

			nPrimeiro := (cAlias)->RECNO
			
			//Primeiro
			If nOpc == 1
				QAA->(DbGoTo(nPrimeiro))
			
			//Anterior ou Próximo
			ElseIf nOpc == 2 .OR. nOpc == 3
				While !(cAlias)->(Eof()) .AND. nPosAtu <> (cAlias)->RECNO
					(cAlias)->(DbSkip())
				EndDo
				(cAlias)->(DbSkip())
				If (cAlias)->(Eof())
					QAA->(DbGoTo(nPrimeiro))
				Else
					QAA->(DbGoTo((cAlias)->RECNO))
				EndIf
			EndIf
		EndIf
		(cAlias)->(DbCloseArea())

		oUsuarios:UpsTable()
	EndIf

	CursorArrow()
	
Return .T.

/*/{Protheus.doc} pendenciaPreenchidaPorDocumento
Indica se a pendência está preenchida por documento
@author brunno.costa
@since 02/10/2024
@version 1.0
@param 01 - cResponsabilidade, caracter, tipo de pendencia para checagem
@return lComDestino, lógico, indica se a pendência está preenchida por documento
/*/
METHOD pendenciaPreenchidaPorDocumento(cResponsabilidade) CLASS QAXA010AuxClass
	
	Local lComDestino := aScan(aPenDoc, {|x| AllTrim(x[POS_PendDoc_TPPEND]) == cResponsabilidade .And. !Empty(x[POS_PendDoc_POR_DOC_FIL_MAT]) }) > 0
	
Return lComDestino

/*/{Protheus.doc} responsabilidadeQD0ExisteNasPendenciasQD1
Verifica se a responsabilidade cadastrada no documento já esta criada nas pendencias do documento.
@author rafael.kleestadt
@since 07/03/2023
@version 1.0
@param aChaveQD0, array, array contendo a chave para busca na QD1 com base no indice 7
@return lTransfere, lógico, verdadeiro se a responsabilidade já existe na QD1.
/*/
Method responsabilidadeQD0ExisteNasPendenciasQD1(aChaveQD0) CLASS QAXA010AuxClass
	Local aAreaQD1   := QD1->(GetArea())
	Local lTransfere := .F.

	DbSelectArea("QD1")
	QD1->(DbSetOrder(7)) //QD1_FILIAL+QD1_DOCTO+QD1_RV+QD1_DEPTO+QD1_FILMAT+QD1_MAT+QD1_TPPEND+QD1_PENDEN
	If QD1->(DbSeek(aChaveQD0[1]))
		lTransfere := .T.
	EndIf
	QD1->(DbCloseArea())

	RestArea(aAreaQD1)
Return lTransfere

/*/{Protheus.doc} verificaSeUsuariosPossuemPendenciasDeDevolucaoDeRevisaoAnterior
Método que verifica se os usuarios de origem e destino(marcado) possuem pendencia de devolução de revisão anterior.
@author rafael.kleestadt
@since 07/12/2023
@version 1.0
@param aDoctos, array, array contendo os documentos com pendescias marcadas para transferencia;
@param cFilAtu, caractere, filial(QAA) do usuario de origem da transferencia;
@param cMatAtu, caractere, matricula(QAA) do usuario de origem da transferencia;
@param cFilDest, caractere, filial(QAA) do usuario de destino da transferencia;
@param cMatDest, caractere, matricula(QAA) do usuario de destino da transferencia;
@return lTemDevPen, lógico, verdadeiro se os usuarios de origem e destino(marcado) possuem pendencia de devolução de revisão anterior.
/*/
Method verificaSeUsuariosPossuemPendenciasDeDevolucaoDeRevisaoAnterior(aDoctos, cFilAtu, cMatAtu, cFilDest, cMatDest) CLASS QAXA010AuxClass
	Local cAliasQDU  := ""
	Local cFilialQDU := xFilial("QDU")
	Local cQDUBanco  := RetSqlName("QDU")
	Local cQuery     := ""
	Local lTemDevPen := .F.
	Local nContDocs  := 0
	Local oQLTQueryM := Nil

	lExQLTMan := IIF(lExQLTMan  == Nil, FindClass("QLTQueryManager"), lExQLTMan )

	For nContDocs := 1 To Len(aDoctos)
		
		If aDoctos[ncontDocs, POS_ADOCTOS_MARK] // Somente os documentos marcados

			cQuery :=        " SELECT R_E_C_N_O_ "
			cQuery +=          " FROM "+ cQDUBanco +" t1 "
			cQuery +=         " WHERE QDU_FILIAL = '"+ cFilialQDU + "' "
			cQuery +=           " AND QDU_DOCTO = '" + aDoctos[nContDocs,POS_ADOCTOS_COD_DOC] + "' "
			cQuery +=           " AND QDU_PENDEN = 'P' "
			cQuery +=           " AND D_E_L_E_T_ = ' ' "
			cQuery +=    " AND EXISTS ( SELECT 1 "
			cQuery +=                  "  FROM "+ cQDUBanco +" t2 "
			cQuery +=                  " WHERE t1.QDU_FILIAL = t2.QDU_FILIAL "
			cQuery +=                    " AND t1.QDU_DOCTO = t2.QDU_DOCTO "
			cQuery +=                    " AND t1.QDU_RV = t2.QDU_RV "
			cQuery +=                    " AND t2.QDU_FILMAT = '"+cFilAtu+"' "
			cQuery +=                    " AND t2.QDU_MAT = '"+cMatAtu+"' "
			cQuery +=                    " AND t2.QDU_PENDEN = 'P' "
			cQuery +=                    " AND t2.D_E_L_E_T_ = ' ' ) "
			cQuery +=    " AND EXISTS ( SELECT 1 "
			cQuery +=                   " FROM "+ cQDUBanco +" t3 "
			cQuery +=                  " WHERE t1.QDU_FILIAL = t3.QDU_FILIAL "
			cQuery +=                    " AND t1.QDU_DOCTO = t3.QDU_DOCTO "
			cQuery +=                    " AND t1.QDU_RV = t3.QDU_RV "
			cQuery +=                    " AND t3.QDU_FILMAT = '"+cFilDest+"' "
			cQuery +=                    " AND t3.QDU_MAT = '"+cMatDest+"' "
			cQuery +=                    " AND t3.QDU_PENDEN = 'P' "
			cQuery +=                    " AND t3.D_E_L_E_T_ = ' ' ) "
			
			If lExQLTMan
				oQLTQueryM := QLTQueryManager():New()
				
				cQuery 	  := oQLTQueryM:changeQuery(cQuery)
				cAliasQDU := oQLTQueryM:executeQuery(cQuery)
					
				lTemDevPen := (cAliasQDU)->(!Eof())
				(cAliasQDU)->(DbCloseArea())
				If lTemDevPen
					EXIT
				EndIf
			EndIf

		EndIf
			
	Next nContDocs

Return lTemDevPen


/*/{Protheus.doc} QAXA010TRR
Função responsável por montagem da tela de transferência de responsabilidades
@author brunno.costa
@since 20/03/2024
@version 1.0
/*/
Function QAXA010TRR()
	Local oQAXA010Aux := QAXA010AuxClass():New()
	oQAXA010Aux:montaTelaTransferenciaResponsabilidade()
Return

/*/{Protheus.doc} QAXA010TDP
Função responsável por montagem da tela de transferência de departamento
@author brunno.costa
@since 20/03/2024
@version 1.0
/*/
Function QAXA010TRD()
	Local oQAXA010Aux := QAXA010AuxClass():New()
	oQAXA010Aux:montaTelaTransferenciaDepartamento()
Return

/*/{Protheus.doc} montaTelaTransferenciaResponsabilidade
Monta Tela Transferência de Responsabilidade
@author brunno.costa
@since 20/03/2024
@version 1.0
/*/
Method montaTelaTransferenciaResponsabilidade() CLASS QAXA010AuxClass
	
	Local aAreaQAAOk := Nil
	Local aRetorno   := {}
	Local cNDepto    := " "
	Local lRet       := .T.
	Local nOpcao     := 2

	Private aSize      := MsAdvSize()
	Private aUsrMat    := QA_USUARIO()
	Private aArryPg    := {}
	Private aAviAux    := {{ Space(TamSx3("QDS_FILIAL")[1]),Space(TamSx3("QDS_DOCTO")[1]),Space(TamSx3("QDS_RV")[1]),Space(TamSx3("QDS_PENDEN")[1]),Space(TamSx3("QDS_DTGERA")[1])+" "+Space(TamSx3("QDS_HRGERA")[1]), OemToAnsi(STR0089)}}
	Private aAvisos    := {}
	Private aBuscaQD1  := {}
	Private aDoctos    := {{.F., .F., INI_CAMPO_ADOCTOS_TIPO_DOC, INI_CAMPO_ADOCTOS_DOCUMENT, INI_CAMPO_ADOCTOS_REV_DOCT, OemToAnsi(STR0089), INI_CAMPO_ADOCTOS_MAT_NOME, INI_CAMPO_ADOCTOS_FIL_MAT, INI_CAMPO_ADOCTOS_FIL_PEND, INI_CAMPO_ADOCTOS_TP_PENDE, 0, "P" }} //"Não há Lançamentos"
	Private aHeadDoc   := {" " , " ", AllTrim(FWX3Titulo("QD2_CODTP")), OemToAnsi(STR0086)+"/"+OemToAnsi(STR0039), OemToAnsi(STR0087)+"/"+OemToAnsi(STR0033), OemToAnsi(STR0088)+"/"+OemToAnsi(STR0079), STR0204 + AllTrim(FWX3Titulo("QAA_MAT"))+"/"+AllTrim(FWX3Titulo("QAA_NOME"))} // "No.Docto" ### "Rv" ### "Titulo" + "Destino: "
	Private aHeadRes   := {" " , " ", AllTrim(FWX3Titulo("QD2_CODTP")),                        OemToAnsi(STR0039),                        OemToAnsi(STR0033),                        OemToAnsi(STR0079), STR0204 + AllTrim(FWX3Titulo("QAA_MAT"))+"/"+AllTrim(FWX3Titulo("QAA_NOME"))} // "Depto" ### "Fil" ### "Descrição" + "Destino: "
	Private aPenCri    := {} // Vetor com o indice das pendencias com criticas de status "pendente"
	Private aPenDoc    := {}
	Private aPosObj    := MsObjSize({aSize[1], aSize[2], aSize[3], aSize[4], 3, 3}, {{1,1,.T.,.T.}}, .T.)
	Private aSaveArea  := GetArea()
	Private aTpPen     := {}
	Private bQDSLine   := {|| }
	Private cCcFilial  := Space(FWSizeFilial())
	Private cCcMatr    := Space(TAMSX3("QAA_MAT")[1])
	Private cCcPara    := Space(TAMSX3("QAA_CC")[1])
	Private cDepAtu    := ""
	Private cDepNov    := ""
	Private cFilAtu    := Space(FWSizeFilial())
	Private cFilDep    := xFilial("QAD")
	Private cFilMat    := cFilAnt
	Private cFilNov    := Space(FWSizeFilial())
	Private cMatAtu    := ""
	Private cMatCod    := aUsrMat[3]
	Private cMatDep    := aUsrMat[4]
	Private cMatFil    := aUsrMat[2]
	Private cMotTransf := Space(30)
	Private cNomAtu    := ""
	Private hNo        := LoadBitmap( GetResources(), "LBNO" )
	Private hOK        := LoadBitmap( GetResources(), "LBTIK" )
	Private lChk04     := .F.
	Private lChkAllDoc := .T.
	Private lChkAllPen := .T.
	Private lDep       := .f.
	Private lFil       := .f.
	Private nItem2     := 2
	Private nItem3     := 2
	Private nItem4     := 1
	Private nItem5     := 1
	Private nPosQAA    := QAA->(Recno())
	Private nQaConpad  := 2
	Private oAvisos    := Nil
	Private oChk03     := Nil
	Private oChkAllDoc := Nil
	Private oChkAllPen := Nil
	Private oCombOrd   := Nil
	Private oDlgMain   := Nil
	Private oDoctos    := Nil
	Private oFwLayer   := Nil
	Private oItem2     := Nil
	Private oItem4     := Nil
	Private oItem5     := Nil
	Private oMarcarP   := Nil
	Private oMarcarR   := Nil
	Private oMarcarU   := Nil
	Private oNo        := LoadBitmap( GetResources(), "DISABLE" )
	Private oOK        := LoadBitmap( GetResources(), "ENABLE" )
	Private oPanDoc    := Nil
	Private oPanLeg    := Nil
	Private oPanLegend := Nil
	Private oPanOpcao  := Nil
	Private oPanPende  := Nil
	Private oPanUsr    := Nil
	Private oPesq      := Nil
	Private oPesquisa  := Nil
	Private oSayT1     := Nil
	Private oSayUsu    := Nil
	Private oSize      := Nil
	Private oTpPen     := Nil
	Private oUsuarios  := Nil

	If !Self:checaPermissaoTransferenciaUsuario()
		Return .F.
	EndIf

	DbSelectArea("QDZ")
	DbSetOrder(1)

	DbSelectArea("QAB")
	DbSetOrder(2)

	DbSelectArea("QAA")
	DbSetOrder(1)

	// Inicializa aRetorno com valores padrão
	aRetorno := { 2, nItem2, nItem3, nItem4, nItem5 }

	cFilMat	  := QAA->QAA_FILIAL
	cFilAtu	  := QAA->QAA_FILIAL
	cMatAtu	  := QAA->QAA_MAT
	cNomAtu	  := QAA->QAA_NOME           
	cDepAtu	  := QAA->QAA_CC
	cCcFilial := cFilAtu
	cCcMatr	  := cMatAtu
	cCcPara	  := cDepAtu 
	aBuscaQD1 := { {cFilAtu , cMatAtu , cDepAtu } }

	Self:carregaTransferenciasEMatriculaAtual(@lRet, .F.)

	If !lRet
		Return Nil
	EndIf

	// Define tamanho da tela
	oSize := FwDefSize():New(.T.,,,oDlgMain)
	oSize:AddObject( "TELA" ,  100, 100, .T., .T. ) // Totalmente dimensionavel
	oSize:lProp := .T. // Proporcional             
	oSize:aMargins := { 3, 3, 3, 3 } // Espaco ao lado dos objetos 0, entre eles 3 

	oSize:Process() // Dispara os calculos  

	//STR0020 - "Transferencia de Usuarios"
	//STR0021 - "Usuario"
	//STR0085 - "Depto"
	DEFINE MSDIALOG oDlgMain TITLE OemToAnsi(STR0020) + " - " +;
	                               OemToAnsi(STR0021) + ": " + AllTrim(cMatAtu) + " - " + AllTrim(cNomAtu) + " " +;
								   OemToAnsi(STR0085) + ": " + cDepAtu ;
								   FROM oSize:aWindSize[1],oSize:aWindSize[2] ;
								     TO oSize:aWindSize[3],oSize:aWindSize[4] OF oMainWnd PIXEL

	oFwLayer := FwLayer():New()
    oFwLayer:Init( oDlgMain, .F., .T. )
	
	//Resoluções Pequenas - Browser e monitores antigos ou com zoom
	If oSize:aWorkArea[4] < 345
		oFWLayer:AddLine( 'OPCOES', 20, .F. )
		oFWLayer:AddLine( 'FULL'  , 75, .F. )

	Else
		oFWLayer:AddLine( 'OPCOES', 13, .F. )
		oFWLayer:AddLine( 'FULL'  , 82, .F. )

	EndIF
	
	// STR0060 - Opções
	oFWLayer:AddCollumn('OPCOES_COL', 100, .F., 'OPCOES' )
	oFWLayer:AddWindow("OPCOES_COL","oPanOpcao",STR0060,100,.F.,.F.,,"OPCOES",{ || })

	oFWLayer:AddCollumn( 'RESPONSABILIDADES_COL' , 15, .F., 'FULL' )
	oFWLayer:AddCollumn( 'DOCUMENTOS_COL'        , 85, .F., 'FULL' )

	// STR0078 - Tipo de Responsabilidade
	// STR0192 - Legendas 
	oFWLayer:AddWindow("RESPONSABILIDADES_COL","oPanPende" ,STR0078,70,.F.,.F.,,"FULL",{ || })
	oFWLayer:AddWindow("RESPONSABILIDADES_COL","oPanLegend",STR0192,30,.F.,.F.,,"FULL",{ || })
	
	
	//Resoluções Pequenas - Browser e monitores antigos ou com zoom
	If oSize:aWorkArea[4] < 345
		// STR0080 - Documentos/Pastas
		oFWLayer:AddWindow("DOCUMENTOS_COL","oPanDoc",,40,.F.,.T.,,"FULL",{ || })
		oFWLayer:AddWindow("DOCUMENTOS_COL","oPanUsr",,60,.F.,.T.,,"FULL",{ || })

	Else
		oFWLayer:AddWindow("DOCUMENTOS_COL","oPanDoc",,50,.F.,.T.,,"FULL",{ || })
		oFWLayer:AddWindow("DOCUMENTOS_COL","oPanUsr",,50,.F.,.T.,,"FULL",{ || })

	EndIF

	oPanPende := oFWLayer:GetWinPanel("RESPONSABILIDADES_COL","oPanPende" ,"FULL")
	oPanLegend:= oFWLayer:GetWinPanel("RESPONSABILIDADES_COL","oPanLegend","FULL")

	oPanDoc   := oFWLayer:GetWinPanel("DOCUMENTOS_COL","oPanDoc"   ,"FULL")
	oPanUsr   := oFWLayer:GetWinPanel("DOCUMENTOS_COL","oPanUsr"   ,"FULL")

	oPanOpcao := oFWLayer:GetWinPanel("OPCOES_COL"    ,"oPanOpcao" ,"OPCOES")

	Self:montaPainelTiposDePendencias()
	Self:montaPainelLegendasTiposDePendencias()
	Self:montaPainelDocumentosPastasAvisos()
	Self:montaPainelUsuariosDestino()
	Self:montaPainelOpcoes(oPanOpcao, .T.)

	//Folder Centros de Custo
	cNDepto  := QA_NDEPT(cCcPara,.F.,cCcFilial)

	QAA->(dbSetOrder(3))
	QAA->(DbGoTop())

	ACTIVATE MSDIALOG oDlgMain ;
			ON INIT EnchoiceBar( oDlgMain, { || aAreaQAAOk := QAA->(GetArea()),;
							aRetorno := QAX010FIM(nItem2,nItem3,nItem4,nItem5,aPenDoc,aTpPen,cCcFilial,cCcPara,cNDepto,cCcMatr,cFilAtu,cMatAtu,cDepAtu,oDlgMain,Nil,aAvisos),;
						 IF(aRetorno[1] == 1, oDlgMain:End(), ""), RestArea(aAreaQAAOk)},;
					   { || aRetorno := {2, nItem2, nItem3, nItem4, nItem5}, oDlgMain:End() } )


	//Contorno ao bug que deixa o nItem5 private em branco 
	nOpcao := aRetorno[1] //Opção selecionada no botão EnchoiceBar
	nItem2 := aRetorno[2] //Conteúdo do nItem2
	nItem3 := aRetorno[3] //Conteúdo do nItem3
	nItem4 := aRetorno[4] //Conteúdo do nItem4
	nItem5 := aRetorno[5] //Conteúdo do nItem5

	Self:processaFechamentoTransferencia(nOpcao)

Return

/*/{Protheus.doc} montaPainelTiposDePendencias
Monta painel Tipo de Pendências
@author brunno.costa
@since 20/03/2024
@version 1.0
/*/
Method montaPainelTiposDePendencias() CLASS QAXA010AuxClass

	Local cTpPen := " "

	//Cria GRID com os Tipos de Pendencias
	@ 009,006 LISTBOX oTpPen VAR cTpPen ;
				FIELDS ;
				HEADER " "," "," ",OemToAnsi(STR0079);	// "Descrição"
				SIZE 080, aPosObj[1,4]-aPosObj[1,2] OF oPanPende PIXEL ; 
				ON DBLCLICK Processa({|lEnd| Self:duploCliqueTipoPendencia() })
	oTpPen:Align := CONTROL_ALIGN_TOP
	oTpPen:SetArray(aTpPen)
	oTpPen:bLine := Self:retornaBLineTipoPendencia()

	//STR0009 - "Aguarde..."
	//STR0031 - "Verificando pendencias"
	oTpPen:bChange      := { || MsgRun(OemToAnsi(STR0031),OemToAnsi(STR0009), { || Self:acaoTrocaDeLinhaTipoPendencia() }) }
	oTpPen:bHeaderClick := {|oObj,nCol| IIf( nCol==1 , Processa({|lEnd| Self:marcaTodasResponsabilidades() }) , Nil ) }

	
	oChkAllPen := TCheckBox():New(002,003,"",,oPanPende,015,,,,,,,,,,"")
	oChkAllPen:bSetGet := {|u| If(PCount() == 0, lChkAllPen, lChkAllPen := u) }
	oChkAllPen:bChange := {|| Processa({|lEnd| Self:marcaTodasResponsabilidades() }) }

Return

/*/{Protheus.doc} marcaTodasResponsabilidades
Marca / Desmarca todos os checkbox das Responsabilidades
@author brunno.costa
@since 15/10/2024
@version 1.0
/*/
Method marcaTodasResponsabilidades() CLASS QAXA010AuxClass

	Local lAtuDocs  := .F.
	Local lAtuPends := .F.
	Local nItem     := 0
	Local nTotal    := Len(aTpPen)

	For nItem := 1 to nTotal

		lAtuDocs  := .T.
		lAtuPends := nItem == nTotal

		Self:marcaResponsabilidade(nItem, !lChkAllPen, lAtuDocs, lAtuPends)

	Next

Return .T.

/*/{Protheus.doc} marcaResponsabilidade
Marca / Desmarca uma Responsabilidade
@author brunno.costa
@since 15/10/2024
@version 1.0
@param 01 - nItem    , numérico, indica a posição do registro de responsabilidade na GRID
@param 02 - lMarkAtu , lógico  , indica o status atual de referência para atualização
@param 03 - lAtuDocs , lógico  , indica se atualizará a marcação e aplicará refresh nos documentos relacionados à responsabilidade
@param 04 - lAtuPends, lógico  , indica se atualizará a marcação e aplicará refresh na grid de responsabilidades
/*/
Method marcaResponsabilidade(nItem, lMarkAtu, lAtuDocs, lAtuPends) CLASS QAXA010AuxClass

	If lMarkAtu
		aTpPen[nItem][POS_aTpPen_MARCACAO] := .F.
	Else
		aTpPen[nItem][POS_aTpPen_MARCACAO] := .T.
	EndIf

	//Marca Todos os Documentos relacionados à Responsabilidade
	Self:marcaTodosDocumentosDaResponsabilidade(nItem, lMarkAtu, lAtuDocs, lAtuPends)

Return .T.

/*/{Protheus.doc} marcaTodosDocumentosDaResponsabilidade
Marca / Desmarca todos os checkbox dos documentos da Responsabilidade
@author brunno.costa
@since 15/10/2024
@version 1.0
@param 01 - nItem    , numérico, indica a posição do registro de responsabilidade na GRID
@param 02 - lMarkAtu , lógico  , indica o status atual de referência para atualização
@param 03 - lAtuDocs , lógico  , indica se atualizará a marcação e aplicará refresh nos documentos relacionados à responsabilidade
@param 04 - lAtuPends, lógico  , indica se atualizará a marcação e aplicará refresh na grid de responsabilidades
/*/
Method marcaTodosDocumentosDaResponsabilidade(nItem, lMarkAtu, lAtuDocs, lAtuPends) CLASS QAXA010AuxClass

	Local cTpPend := aTpPen[nItem, POS_aTpPen_TPPEND]
	Local nPosDoc := 0

	//Atualiza GRID de Pendências
	If lAtuPends
		Self:marcaResponsabilidade(nItem, lMarkAtu, lAtuDocs, .F.)

		oTpPen:SetArray(aTpPen)
		oTpPen:bLine := Self:retornaBLineTipoPendencia()
		oTpPen:Refresh()
	EndIf

	//Atualiza GRID de Documentos da GRID Selecionada
	If lAtuDocs

		//Marca Todos as Pendências / Documentos / Avisos relacionados à Pendência
		nPosDoc := aScan(aPenDoc, { |x| Left(x[POS_PendDoc_TPPEND],1) == cTpPend }, nPosDoc + 1 )
		While nPosDoc > 0

			If lMarkAtu
				aPenDoc[nPosDoc, POS_PendDoc_MARK] := .F.
			Else
				aPenDoc[nPosDoc, POS_PendDoc_MARK] := .T.
			EndIf

			nPosDoc := aScan(aPenDoc, { |x| Left(x[POS_PendDoc_TPPEND],1) == cTpPend }, nPosDoc + 1 )

		EndDo
			
		Self:acaoTrocaDeLinhaTipoPendencia()
	EndIf

Return .T.

/*/{Protheus.doc} acaoTrocaDeLinhaTipoPendencia
Ação de troca de linha de grid de Tipo de Pendências
@author brunno.costa
@since 03/10/2024
@version 1.0
/*/
Method acaoTrocaDeLinhaTipoPendencia() CLASS QAXA010AuxClass

	Self:carregaDocumentosEmTela(@oDoctos,@aDoctos,aPenDoc,aTpPen,oTpPen:nAt,nItem4,,,aAvisos,@oAvisos,@aAviAux)
	
	If aTpPen[oTpPen:nAt, POS_aTpPen_TEM_DOCUMENTO]
		oMarcarP:Enable()
		oMarcarR:Enable()
	Else
		oMarcarP:Disable()
		oMarcarR:Disable()
	EndIf

	If !Empty(aDoctos[oDoctos:nAt, POS_ADOCTOS_FIL_MAT])
		Self:atualizaPonteiroUsuario(@oUsuarios,aDoctos[oDoctos:nAt,POS_ADOCTOS_FIL_MAT])
	EndIf

	lChkAllDoc := aTpPen[oTpPen:nAt, POS_aTpPen_MARCACAO]
	//oChkAllDoc:VarPut( lChkAllDoc )
	oChkAllDoc:CtrlRefresh()

Return

/*/{Protheus.doc} duploCliqueTipoPendencia
Ação de troca de linha de grid de Tipo de Pendências
@author brunno.costa
@since 03/10/2024
@version 1.0
/*/
Method duploCliqueTipoPendencia() CLASS QAXA010AuxClass

	Local lAtuDocs  := .T.
	Local lAtuPends := .T.
	Local lMarkAtu  := aTpPen[oTpPen:nAt, POS_aTpPen_MARCACAO]

	Self:marcaTodosDocumentosDaResponsabilidade(oTpPen:nAt, lMarkAtu, lAtuDocs, lAtuPends)

Return

/*/{Protheus.doc} duploCliqueDocumento
Ação duplo clique para Marcação e Desmarcação de Documentos
@author brunno.costa
@since 03/10/2024
@version 1.0
/*/
Method duploCliqueDocumento() CLASS QAXA010AuxClass

	Local lAtuDocs  := .F.
	Local lAtuPends := .T.
	Local lMarkAtu  := .F.
	Local nPosT     := 0

	aDoctos[oDoctos:nAt,POS_ADOCTOS_MARK] := !aDoctos[oDoctos:nAt,POS_ADOCTOS_MARK]
	oDoctos:Refresh() 

	nPosT := 0                //Fil+DOC+REV+TPPEND+PENDEN+RECNO
	nPosT := aScan(aPenDoc,{ |x| x[POS_PendDoc_FILIAL]  == aDoctos[oDoctos:nAt,POS_ADOCTOS_FIL_PEN] .AND. ;
	                             x[POS_PendDoc_DOCTO]   == aDoctos[oDoctos:nAt, If(x[1]=="P",POS_ADOCTOS_COD_DOC_P,POS_ADOCTOS_COD_DOC)] .AND. ;
								 x[POS_PendDoc_RV]      == aDoctos[oDoctos:nAt, If(x[1]=="P",POS_ADOCTOS_REV_DOC_P,POS_ADOCTOS_REV_DOC)] .AND. ;
								 x[POS_PendDoc_TPPEND]  == aDoctos[oDoctos:nAt,POS_ADOCTOS_TIP_PEN] .AND. ;
								 x[POS_PendDoc_PENDEN2] == aDoctos[oDoctos:nAt,POS_ADOCTOS_STATUS] .AND. ;
								 cValToChar(x[POS_PendDoc_RECNO]) == cValToChar(aDoctos[oDoctos:nAt,POS_ADOCTOS_RECNO]) ;
						   })

	//Marca Pendência no Controle de Pendências
	If nPosT > 0
		aPenDoc[nPosT, POS_PendDoc_MARK] := aDoctos[oDoctos:nAt,POS_ADOCTOS_MARK]
	EndIf

	lMarkAtu := aScan(aDoctos, { |x| x[POS_ADOCTOS_MARK]  }) == 0
	Self:marcaResponsabilidade(oTpPen:nAt, lMarkAtu, lAtuDocs, lAtuPends)

Return

/*/{Protheus.doc} acaoTrocaDeLinhaDocumentos
Ação de troca de linha de grid de Documentos
@author brunno.costa
@since 03/10/2024
@version 1.0
/*/
Method acaoTrocaDeLinhaDocumentos() CLASS QAXA010AuxClass

	IF !Empty(aDoctos[oDoctos:nAt,POS_ADOCTOS_FIL_MAT])
		Self:atualizaPonteiroUsuario(@oUsuarios, aDoctos[oDoctos:nAt,POS_ADOCTOS_FIL_MAT]  )

	ElseIF !Empty(aTpPen[oTpPen:nAt, POS_aTpPen_DESTINATARIO])
		Self:atualizaPonteiroUsuario(@oUsuarios, aTpPen[oTpPen:nAt,POS_aTpPen_DESTINATARIO])

	EndIf

	Self:carregaAvisosEmTela(aTpPen[oTpPen:nAt,4]=="S",oDoctos,aDoctos,@oAvisos,aAvisos,@aAviAux,nItem4)

Return

/*/{Protheus.doc} acaoMudancaRadioResponsabilidades
Ação mudança Radio Button de Responsabilidades
@author brunno.costa
@since 03/10/2024
@version 1.0
/*/
Method acaoMudancaRadioResponsabilidades() CLASS QAXA010AuxClass

	Self:carregaDocumentosEmTela(@oDoctos,@aDoctos,aPenDoc,@aTpPen,oTpPen:nAt,nItem4,,.T.,aAvisos,@oAvisos,@aAviAux)

	oTpPen:SetArray(aTpPen)
	oTpPen:bLine := Self:retornaBLineTipoPendencia()
	oTpPen:Refresh()

Return

/*/{Protheus.doc} montaPainelLegendasTiposDePendencias
Monta painel Legendas da ações nas pendências
(Verde - Usuário selecionado, Amarelo - Sem usuário selecionado, Cinza - Sem registro)
@author thiago.rover
@since 05/08/2024
@version 1.0
/*/
Method montaPainelLegendasTiposDePendencias() CLASS QAXA010AuxClass

	Local oBitVerde   := Nil
	Local oBitAmarelo := Nil
	Local oBitCinza   := Nil

	@ 005,010 BitMap oBitVerde   Resource "BR_VERDE"   Size 17,17 of oPanLegend Pixel Noborder Design
	@ 015,010 BitMap oBitAmarelo Resource "BR_LARANJA" Size 17,17 of oPanLegend Pixel Noborder Design
	@ 025,010 BitMap oBitCinza   Resource "BR_CINZA"   Size 17,17 of oPanLegend Pixel Noborder Design

	// STR0193 - Usuário Selecionado
	// STR0194 - Sem usuário selecionado
	// STR0195 - Sem registro
	@ 005,020  Say Oemtoansi(STR0193) Of oPanLegend Pixel
	@ 015,020  Say Oemtoansi(STR0194) Of oPanLegend Pixel
	@ 025,020  Say Oemtoansi(STR0195) Of oPanLegend Pixel

Return 


/*/{Protheus.doc} montaPainelDocumentosPastasAvisos
Monta Painel de Documentos / Pastas e Avisos
@author brunno.costa
@since 20/03/2024
@version 1.0
/*/
Method montaPainelDocumentosPastasAvisos() CLASS QAXA010AuxClass

	Local cAvi      := ""
	Local cDoc      := " "

	//Cria GRID de Documentos
	@ 009,083 LISTBOX oDoctos VAR cDoc ;
			  FIELDS ;
			  HEADER " "," "," "," "," "," "," " ;	
			  ON DBLCLICK Processa({|lEnd| Self:duploCliqueDocumento() });
			  SIZE aPosObj[1,4]-aPosObj[1,2] , aPosObj[1,4]-aPosObj[1,2] OF oPanDoc PIXEL 
	oDoctos:SetArray(aDoctos)
	oDoctos:bLine:= { || { If( aDoctos[ oDoctos:nAt, POS_ADOCTOS_MARK], hOk, hNo )             ,;
						   If(aTpPen[oTpPen:nAt, POS_aTpPen_TEM_DOCUMENTO]                     ,;
						     If( aDoctos[ oDoctos:nAt, POS_ADOCTOS_LEGENDA], oVerde, oLaranja ),;
							 oCinza  )                                                         ,;
						   aDoctos[oDoctos:nAt, POS_ADOCTOS_COD_DOC]                           ,;
						   aDoctos[oDoctos:nAt, POS_ADOCTOS_REV_DOC]                           ,;
						   aDoctos[oDoctos:nAt, POS_ADOCTOS_TIT_DOC]                            } }
	oDoctos:Align:= CONTROL_ALIGN_ALLCLIENT
	oDoctos:bChange      := { || Self:acaoTrocaDeLinhaDocumentos() }
	oDoctos:bHeaderClick := {|oObj,nCol| IIf( nCol==1 , Processa({|lEnd| Self:marcaTodosDocumentosDaResponsabilidade(oTpPen:nAt, aDoctos[ 1, POS_ADOCTOS_MARK], .T., .T.) }) , Nil )}

	oChkAllDoc := TCheckBox():New(002,003,"",,oPanDoc,015,,,,,,,,,,"")
	oChkAllDoc:bSetGet := {|u| If(PCount() == 0, lChkAllDoc, lChkAllDoc := u) }
	oChkAllDoc:bChange := {|| Processa({|lEnd| Self:marcaTodosDocumentosDaResponsabilidade(oTpPen:nAt, aDoctos[ 1, POS_ADOCTOS_MARK], .T., .T.) }) }

	//STR0133 - "Avisos"
	@ 009,090 LISTBOX oAvisos VAR cAvi ;
				FIELDS ;
				HEADER TitSx3("QDS_DTGERA")[1],;
						OemToAnsi(STR0133);
				COLSIZES 40 ;
				SIZE 150,(aPosObj[1,4]-aPosObj[1,2]) OF oPanDoc PIXEL
	bQDSLine:={ || { DTOC(STOD(SUBS(aAviAux[oAvisos:nAt,5],1,8))) + SUBS(aAviAux[oAvisos:nAt,5],9), QAX010MsgA(aAviAux[oAvisos:nAt,6]) } }
	oAvisos:SetArray(aAviAux)
	oAvisos:bLine:= bQDSLine
	oAvisos:Align:= CONTROL_ALIGN_RIGHT
	oAvisos:Hide()

Return

/*/{Protheus.doc} montaPainelUsuariosDestino
Monta Painel de Usuários Destino da Transferencia
@author brunno.costa
@since 20/03/2024
@version 1.0
/*/
Method montaPainelUsuariosDestino() CLASS QAXA010AuxClass

	Local aCombOrd  := {}
	Local cCombOrd  := OemToAnsi(STR0092) // "Nome"
	Local cFilFIM   := Space(FWSizeFilial())
	Local cFilINI   := Space(FWSizeFilial())
	Local cFiltro   := ""
	Local cPesquisa := Space(100)
	Local cUsr      := " "
	Local nOldOrdU  := 3

	aCombOrd := {OemToAnsi(STR0091),;	                        // "Matricula"
				 OemToAnsi(STR0092),;	                        // "Nome"
				 OemToAnsi(STR0084),;	                        // "Nome Reduzido"
				 OemToAnsi(STR0085),; 	                        // "Depto"
				 OemToAnsi(AllTrim(FWX3Titulo('QAA_DESCCC'))) } // "Descr.Depto"

	//Define se na Transferencia Filtra os Funcionarios apenas a Filial Atual 1=SIM 2=NAO
	IF GETMV("MV_QDOFFIL",.F.,"2")=="1"
		cFilINI :=xFilial("QAA")
		cFilFIM :=xFilial("QAA")
	Else
		cFilINI := Space(FWSizeFilial())
		cFilFIM := Repl("z",FWSizeFilial())
	Endif

	cFiltro:= Qa_FilSitF() // "Filtra Usuarios Ativo"
	DbSelectArea("QAA")
	Set Filter to &(cFiltro)
	DbSeek(xFilial("QAA"))

	//Cria Lista de Usuários Destino
	@ 131,006 LISTBOX oUsuarios VAR cUsr;
				FIELDS QAA->QAA_FILIAL,QAA->QAA_MAT,QAA->QAA_NOME,QAA->QAA_APELID,QAA->QAA_CC, fDesc("QAD",QAA->QAA_CC,"QAD_DESC") ;
				HEADER 	OemToAnsi(STR0033),; // "Fil"
						OemToAnsi(STR0091),; // "Matricula"
						OemToAnsi(STR0083),; // "Nome""
						OemToAnsi(STR0084),; // "Nome Reduzido"
						OemToAnsi(STR0085),; // "Depto"
						OemToAnsi(AllTrim(FWX3Titulo('QAA_DESCCC'))) ; // "Descr.Depto"
				SELECT QAA->QAA_FILIAL FOR cFilINI TO cFilFIM ;				  
				ALIAS "QAA" ;
				SIZE (aPosObj[1,4]-aPosObj[1,2]),(oPanUsr:nHeight * 0.4) OF oPanUsr PIXEL  
							
	QAA->(DBSeek(cFilAtu+cMatAtu))
	oUsuarios:Align := CONTROL_ALIGN_BOTTOM
	oUsuarios:UpStable()
	oUsuarios:Refresh()

	//Combo Ordenação / Pesquisa
	@ 000,005 COMBOBOX oCombOrd VAR cCombOrd ITEMS aCombOrd SIZE 060, 070 OF oPanUsr PIXEL ;
				ON CHANGE If( nOldOrdU <> oCombOrd:nAt,;
								(nOldOrdU := oCombOrd:nAt,;
											If( oCombOrd:nAt == 1, QAA->(dbSetOrder(1)) ,;
												If( oCombOrd:nAt == 2, QAA->(dbSetOrder(3)) ,;
													If( oCombOrd:nAt == 3, QAA->(dbSetOrder(6)) ,;
													QAA->(dbSetOrder(5)) ))) ,;
							oUsuarios:UpsTable(),oUsuarios:Refresh() ) ,"") 

	//Entrada de Texto para Pesquisa
	oGetPesqu := TGet():New(000, 070,{|u| if(PCount()==0,cPesquisa,cPesquisa:=u)}, oPanUsr, 120, 013,"@!",{|| Processa({|lEnd| Self:posicionarUsuarioDestino(cPesquisa, cCombOrd, 1) }) },0,,,.F.,,.T.,,.F.,{||.T.},.F.,.F.,,.F.,,,cPesquisa,,,, )

	oPesquisa := TBtnBmp2():New(000,385,025,028,"Pesquisa","Pesquisa",,,{|| Processa({|lEnd| Self:posicionarUsuarioDestino(cPesquisa, cCombOrd, 1) }) },oPanUsr, STR0205) //"Pesquisar"
	oAnterior := TBtnBmp2():New(000,425,025,028,"UP","UP"            ,,,{|| Processa({|lEnd| Self:posicionarUsuarioDestino(cPesquisa, cCombOrd, 2) }) },oPanUsr, STR0206) //"Anterior [F6]"
	oProximo  := TBtnBmp2():New(000,465,025,028,"DOWN","DOWN"        ,,,{|| Processa({|lEnd| Self:posicionarUsuarioDestino(cPesquisa, cCombOrd, 3) }) },oPanUsr, STR0207) //"Próximo [F7]"

	SetKey( VK_F6, {|| Processa({|lEnd| Self:posicionarUsuarioDestino(cPesquisa, cCombOrd, 2) }) } )
	SetKey( VK_F7, {|| Processa({|lEnd| Self:posicionarUsuarioDestino(cPesquisa, cCombOrd, 3) }) } )

	//STR0090 - MARCAR / DESMARCAR DESTINATÁRIO
	@ 000,260 BUTTON oMarcarU PROMPT OemToAnsi(STR0208) ;                   //"Único Usuário"
				ACTION Processa({|lEnd| Self:vinculaUsuarioUnico() }) ;
				SIZE 050, 015 OF oPanUsr PIXEL

	//STR0090 - MARCAR / DESMARCAR DESTINATÁRIO
	@ 000,315 BUTTON oMarcarR PROMPT OemToAnsi(STR0209) ;                   //"Usuário Por Responsabilidade"
				ACTION Processa({|lEnd| Self:vinculaResponsabilidade() }) ;
				SIZE 095, 015 OF oPanUsr PIXEL

	//STR0090 - MARCAR / DESMARCAR DESTINATÁRIO
	@ 000,415 BUTTON oMarcarP PROMPT OemToAnsi(STR0210) ;                   //"Usuário Por Documento"
				ACTION Processa({|lEnd| Self:vinculaDocumento() }) ;
				SIZE 075, 015 OF oPanUsr PIXEL

Return

/*/{Protheus.doc} vinculaDocumento
Vincula responsabilidade do documento selecionado ao usuário selecionado
@author brunno.costa
@since 02/10/2024
@version 1.0
@return .T.
/*/
METHOD vinculaDocumento() CLASS QAXA010AuxClass
	
	Local aAreaQAA := QAA->(GetAreA())
	
	Self:vinculaUsuario(.T.,@aDoctos,@oDoctos,@aPenDoc,@oTpPen,@aTpPen,cFilAtu,cMatAtu)
	
	RestArea(aAreaQAA)
	
Return .T.

/*/{Protheus.doc} vinculaResponsabilidade
Vincula todos os documento da responsabilidade atual ao usuário selecionado
@author brunno.costa
@since 02/10/2024
@version 1.0
@return .T.
/*/
METHOD vinculaResponsabilidade() CLASS QAXA010AuxClass
	
	Local aAreaQAA := QAA->(GetAreA())
	
	Self:vinculaUsuario(.F.,@aDoctos,@oDoctos,@aPenDoc,@oTpPen,@aTpPen,cFilAtu,cMatAtu)
	
	RestArea(aAreaQAA)
Return .T.

/*/{Protheus.doc} vinculaUsuarioUnico
Vincula o usuário selecionado para todas as responsabilidades (prevalece a seleção por documento manual)
@author brunno.costa
@since 02/10/2024
@version 1.0
@return .T.
/*/
METHOD vinculaUsuarioUnico() CLASS QAXA010AuxClass
	
	Local aAreaQAA := QAA->(GetAreA())

	Self:vinculaTodasResponsabilidades(1,@oItem2,@aTpPen,@oTpPen,cFilAtu,cMatAtu,@aDoctos)
	Self:carregaDocumentosEmTela(@oDoctos,@aDoctos,aPenDoc,aTpPen,oTpPen:nAt,nItem4,,,aAvisos,@oAvisos,@aAviAux)

	RestArea(aAreaQAA)
	
Return .T.

/*/{Protheus.doc} montaPainelOpcoes
Monta Painel de Opções da Transferência
@author brunno.costa
@since 20/03/2024
@version 1.0
@return {nItem4, nItem5}, array, retorna os valores selecionados nos Radio Buttons
/*/
Method montaPainelOpcoes(oPanOpcao, lEdicao) CLASS QAXA010AuxClass

	Local nItem4Bkp := nItem4
	Local nItem5Bkp := nItem5	

	//STR0066 - "Responsabilidades:"
	@ 003,003 SAY OemToAnsi(STR0066) SIZE 050,010 OF oPanOpcao PIXEL
	@ 013,005 RADIO oItem4 VAR nItem4 ;
			ITEMS OemToAnsi( STR0067 ),; //"Ambas"
				  OemToAnsi( STR0222 ),; //"Vinculadas"
				  OemToAnsi( STR0069 ) ; //"Pendentes"
			3D SIZE 145,007 OF oPanOpcao PIXEL ;
			WHEN If(FwIsInCallStack("montaTelaTransferenciaDepartamento"), .F., lEdicao)
	
	oItem4:lHoriz := .T.
	
	//STR0009 - "Aguarde..."
	//STR0031 - "Verificando pendencias"
	oItem4:bChange := { || MsgRun(OemToAnsi(STR0031),OemToAnsi(STR0009), {|| Self:acaoMudancaRadioResponsabilidades() }) }

	//STR0211 - "Modo de Transferência:"
	@ 003,215 SAY OemToAnsi(STR0211) SIZE 150,010 OF oPanOpcao PIXEL
	@ 013,218 RADIO oItem5 VAR nItem5 ;
			ITEMS OemToAnsi( STR0048 ),;  //STR0048 - "Transferir e Ativar"
				  OemToAnsi( STR0043 ),;  //STR0043 - "Transferir sem Baixar"
				  OemToAnsi( STR0044 ),;  //STR0044 - "Transferir e Baixar"
				  OemToAnsi( STR0045 ) ;  //STR0045 - "Baixar sem Transferir"
			3D SIZE 300,007 OF oPanOpcao PIXEL ;
			WHEN If(FwIsInCallStack("montaTelaTransferenciaDepartamento") .And. ;  
			        !FwIsInCallStack("QAX010FIM"), .T., lEdicao);

	oItem5:lHoriz := .T.

	nItem4 := nItem4Bkp  
	nItem5 := nItem5Bkp  	

Return 


/*/{Protheus.doc} montaTelaTransferenciaDepartamento
Monta Tela Transferência de Departamento
@author brunno.costa
@since 20/03/2024
@version 1.0
/*/
Method montaTelaTransferenciaDepartamento() CLASS QAXA010AuxClass

	Local aCombOrd  := {}
	Local aRetorno  := {}
	Local aSize     := MsAdvSize()
	Local aPosObj   := MsObjSize({aSize[1], aSize[2], aSize[3], aSize[4], 3, 3}, {{1,1,.T.,.T.}}, .T.)
	Local cNDepto   := " "
	Local cSitAtu   := " "
	Local cUsr      := " "
	Local nOpcao    := 2
	Local oCcFilial := Nil
	Local oCcMatr   := Nil
	Local oCcPara   := Nil
	Local oFwLayer  := Nil
	Local oHistCC   := Nil
	Local oNome     := Nil
	Local oPanDepto := Nil
	Local oPanHistD := Nil
	Local oPanOpcao := Nil
	Local oSayHtr   := Nil
	Local oSize     := Nil
	
	Private aAviAux   := {{ Space(TamSx3("QDS_FILIAL")[1]),Space(TamSx3("QDS_DOCTO")[1]),Space(TamSx3("QDS_RV")[1]),Space(TamSx3("QDS_PENDEN")[1]),Space(TamSx3("QDS_DTGERA")[1])+" "+Space(TamSx3("QDS_HRGERA")[1]), OemToAnsi(STR0089)}}
	Private aBuscaQD1 := {}
	Private aDoctos   := {{.F., .F., INI_CAMPO_ADOCTOS_TIPO_DOC, INI_CAMPO_ADOCTOS_DOCUMENT, INI_CAMPO_ADOCTOS_REV_DOCT, OemToAnsi(STR0089), INI_CAMPO_ADOCTOS_MAT_NOME, INI_CAMPO_ADOCTOS_FIL_MAT, INI_CAMPO_ADOCTOS_FIL_PEND, INI_CAMPO_ADOCTOS_TP_PENDE, 0, "P" }} //"Näo há Lançamentos"
	Private aPenDoc   := {}
	Private aRecTrf   := {}
	Private aSaveArea := GetArea()
	Private aTpPen    := {}
	Private cCcMatr   := Space(TAMSX3("QAA_MAT")[1])
	Private cCcPara   := Space(TAMSX3("QAA_CC")[1])
	Private lChk04    := .F.
	Private nItem2    := 2
	Private nItem3    := 1
	Private nItem4    := 1
	Private nItem5    := 1
	Private nPosQAA   := QAA->(Recno())
	Private oAvisos   := Nil
	Private oDlgMain  := Nil
	Private oDoctos   := Nil

	Private aArryPg     := {}
	Private aAvisos		:= {}                
	Private aHeadDoc	:= { " "," ",OemToAnsi(STR0086)+"/"+OemToAnsi(STR0039),OemToAnsi(STR0087)+"/"+OemToAnsi(STR0033),OemToAnsi(STR0088)+"/"+OemToAnsi(STR0079)}	// "No.Docto" ### "Rv" ### "Titulo"
	Private aHeadRes	:= { " "," ",OemToAnsi(STR0039),OemToAnsi(STR0033),OemToAnsi(STR0079)}	// "Depto" ### "Fil" ### "Descri‡„o"
	Private aPenCri		:= {} // Vetor com o indice das pendencias com criticas de status "pendente"
	Private aUsrMat 	:= QA_USUARIO()
	Private bQDSLine    := {|| }
	Private cCcFilial 	:= Space(FWSizeFilial()) //Space(2)
	Private cDepAtu   	:= ""
	Private cDepNov   	:= ""
	Private cFilAtu   	:= Space(FWSizeFilial())
	Private cFilDep   	:= xFilial("QAD")
	Private cFilMat 	:= cFilAnt
	Private cFilNov   	:= Space(FWSizeFilial())
	Private cMatAtu   	:= ""
	Private cMatCod 	:= aUsrMat[3]
	Private cMatDep 	:= aUsrMat[4]
	Private cMatFil 	:= aUsrMat[2]
	Private cMotTransf	:= Space(30)
	Private cNomAtu   	:= ""
	Private hNo       	:= LoadBitmap( GetResources(), "LBNO" )
	Private hOK       	:= LoadBitmap( GetResources(), "LBTIK" )
	Private lDep      	:= .f.
	Private lFil      	:= .f.
	Private nQaConpad 	:= 2

	aCombOrd := {OemToAnsi(STR0091),;	// "Matricula"
				OemToAnsi(STR0092),;	// "Nome"
				OemToAnsi(STR0084),;	// "Nome Reduzido"
				OemToAnsi(STR0085) } 	// "Depto"

	aTpPen := { { .T.,.F., OemToAnsi(STR0070),"D",Space(TAMSX3("QAA_FILIAL")[1]+TAMSX3("QAA_MAT")[1]) },;	// "Digitação"
				{ .T.,.F., OemToAnsi(STR0071),"E",Space(TAMSX3("QAA_FILIAL")[1]+TAMSX3("QAA_MAT")[1]) },;	// "Elaboração"
				{ .T.,.F., OemToAnsi(STR0072),"R",Space(TAMSX3("QAA_FILIAL")[1]+TAMSX3("QAA_MAT")[1]) },;	// "Revisão"
				{ .T.,.F., OemToAnsi(STR0073),"A",Space(TAMSX3("QAA_FILIAL")[1]+TAMSX3("QAA_MAT")[1]) },;	// "Aprovação"
				{ .T.,.F., OemToAnsi(STR0074),"H",Space(TAMSX3("QAA_FILIAL")[1]+TAMSX3("QAA_MAT")[1]) },;	// "Homologação"
				{ .T.,.F., OemToAnsi(STR0075),"I",Space(TAMSX3("QAA_FILIAL")[1]+TAMSX3("QAA_MAT")[1]) },;	// "Distribuição"
				{ .T.,.F., OemToAnsi(STR0076),"L",Space(TAMSX3("QAA_FILIAL")[1]+TAMSX3("QAA_MAT")[1]) },;	// "Leitura"
				{ .T.,.F., OemToAnsi(STR0038),"P",Space(TAMSX3("QAA_FILIAL")[1]+TAMSX3("QAA_MAT")[1]) },;	// "Resp.Depto"   
				{ .T.,.F., OemToAnsi(STR0116),"G",Space(TAMSX3("QAA_FILIAL")[1]+TAMSX3("QAA_MAT")[1]) },; 	// "Destinatário"
				{ .T.,.F., OemToAnsi("Aviso"),"S",Space(TAMSX3("QAA_FILIAL")[1]+TAMSX3("QAA_MAT")[1]) }} 

	If !Self:checaPermissaoTransferenciaUsuario()
		Return .F.
	EndIf

	DbSelectArea("QDZ")
	DbSetOrder(1)

	DbSelectArea("QAB")
	DbSetOrder(2)

	DbSelectArea("QAA")
	DbSetOrder(1)

	// Inicializa aRetorno com valores padrão
	aRetorno := { 2, nItem2, nItem3, nItem4, nItem5 }

	cFilMat	  := QAA->QAA_FILIAL
	cFilAtu	  := QAA->QAA_FILIAL
	cMatAtu	  := QAA->QAA_MAT
	cNomAtu	  := QAA->QAA_NOME           
	cDepAtu	  := QAA->QAA_CC
	cSitAtu	  := QAA->QAA_STATUS
	cCcFilial := cFilAtu
	cCcMatr	  := cMatAtu
	cCcPara	  := cDepAtu 
	aBuscaQD1 := { {cFilAtu , cMatAtu , cDepAtu } }

	Self:carregaTransferenciasEMatriculaAtual(.T., .T.)

	// Define tamanho da tela
	oSize := FwDefSize():New(.T.,,,oDlgMain)
	oSize:AddObject( "TELA" ,  100, 100, .T., .T. ) // Totalmente dimensionavel
	oSize:lProp := .T. // Proporcional             
	oSize:aMargins := { 3, 3, 3, 3 } // Espaco ao lado dos objetos 0, entre eles 3 

	oSize:Process() // Dispara os calculos

	// STR0020 - "Transferencia de Usuarios"
	DEFINE MSDIALOG oDlgMain TITLE OemToAnsi(STR0020) FROM oSize:aWindSize[1],oSize:aWindSize[2] ;
								     TO oSize:aWindSize[3],oSize:aWindSize[4] OF oMainWnd PIXEL

	oFwLayer := FwLayer():New()
    oFwLayer:Init( oDlgMain, .F., .T. )
	
	//Resoluções
	oFWLayer:AddLine( 'OPCOES', 17, .F. )
	oFWLayer:AddLine( 'DEPTO' , 33, .F. )
	oFWLayer:AddLine( 'HIST'  , 50, .F. )

	// Coluna única que ocupa 100% da largura para cada linha
	oFWLayer:AddCollumn( 'OPCOES_COL', 100, .F., 'OPCOES' )
	oFWLayer:AddCollumn( 'DEPTO_COL' , 100, .F., 'DEPTO'  )
	oFWLayer:AddCollumn( 'HIST_COL'  , 100, .F., 'HIST'   )

	// STR0060 - Opções
	oFWLayer:AddWindow("OPCOES_COL","oPanOpcao" ,STR0060,100,.F.,.F.,,"OPCOES",{ || })
	oFWLayer:AddWindow("DEPTO_COL" ,"oPanDepto" ,       ,100 ,.F.,.F.,,"DEPTO" ,{ || })
	oFWLayer:AddWindow("HIST_COL"  ,"oPanHistD" ,       ,90  ,.F.,.F.,,"HIST"  ,{ || })

	oPanOpcao := oFWLayer:GetWinPanel("OPCOES_COL", "oPanOpcao", "OPCOES")
	oPanDepto := oFWLayer:GetWinPanel("DEPTO_COL" , "oPanDepto", "DEPTO")
	oPanHistD := oFWLayer:GetWinPanel("HIST_COL"  , "oPanHistD", "HIST")

	Self:montaPainelOpcoes(oPanOpcao, .F.)

	//Folder Centros de Custo
	cNDepto  := QA_NDEPT(cCcPara,.F.,cCcFilial)

	//STR0107 - "Transferencia de departamento"
	@000,000 MSPANEL oPanTras PROMPT " "+OemToAnsi(STR0107) SIZE 080,060 OF oPanDepto
	oPanTras:Align := CONTROL_ALIGN_TOP

	//STR0026 - "Filial"
	@ 015,006 SAY OemToAnsi(STR0026) SIZE 025,007 OF oPanDepto PIXEL
	@ 014,040 MSGET oCcFilial VAR cCcFilial F3 "SM0" SIZE  60, 08 OF oPanDepto PIXEL ;
				VALID (QA_CHKFIL(cCcFilial,@cFilDep) .And. FQAXA010USU(cCcFilial,cCcMatr))

	//STR0021 - "Usuario"
	@ 028,006 SAY OemToAnsi(STR0021) SIZE 025,007 OF oPanDepto PIXEL
	@ 027,040 MSGET oCcMatr VAR cCcMatr SIZE 060,008 OF oPanDepto PIXEL
	oCcMatr:lReadOnly:= .T.
	@ 027,100 MSGET oNome   VAR cNomAtu SIZE 096,008 OF oPanDepto PIXEL

	//STR0059 - "Depto"
	@ 040,006 SAY OemToAnsi(STR0059) SIZE 035,007 OF oPanDepto PIXEL
	@ 039,040 MSGET oCcPara VAR cCcPara F3 "QDD" SIZE 060,008 OF oPanDepto PIXEL ;
				VALID (FQAXA010QAD(cCcFilial,cCcPara,@cNDepto,cCcMatr,nItem5),oNDepto:Refresh()) ;
				ON CHANGE (oNDepto:cText:=cNDepto,oNDepto:Refresh())
	@ 039,100 MSGET oNDepto VAR cNDepto SIZE 096,008 OF oPanDepto PIXEL
	oNDepto:lReadOnly:= .T.

	//STR0108 - Historico de Transferencias de Departamento
	@ 000,010 Say oSayHtr VAR ""  SIZE 010,010 OF oPanHistD PIXEL 
	oSayHtr:SetText(" "+OemToAnsi(STR0108))
	oSayHtr:Align := CONTROL_ALIGN_TOP	

	//Cria GRID de Histórico de Transferências do Departamento
	// Usa tamanho dinâmico baseado em aPosObj para preencher corretamente o painel e evitar overflow
	@ 015,006 LISTBOX oHistCC VAR cUsr;
				FIELDS QAB->QAB_FILD,QAB->QAB_CCD,QAB->QAB_FILP,QAB->QAB_CCP,QAB->QAB_DATA;
				HEADER ;
					OemToAnsi(STR0109),; // "De Filial"
					OemToAnsi(STR0110),; // "De Departamento"
					OemToAnsi(STR0111),; // "Para Filial"
					OemToAnsi(STR0112),; // "Para Departamento"
					OemToAnsi(STR0113);  // "Data"
				ALIAS "QAB" ;
				SIZE 080, aPosObj[1,4]-aPosObj[1,2] OF oPanHistD PIXEL
	oHistCC:Align := CONTROL_ALIGN_ALLCLIENT
	// Garante que o controle seja dimensionado corretamente em diferentes resoluções
	oHistCC:SetFilter("QAB->QAB_FILD+QAB->QAB_MATD",cFilAtu+cMatAtu,cFilAtu+cMatAtu)
	oHistCC:UpStable()
	oHistCC:GoTop()
	oHistCC:Refresh()

	ACTIVATE MSDIALOG oDlgMain CENTERED ;
			ON INIT EnchoiceBar( oDlgMain, { || aRetorno := QAX010FIM(nItem2,nItem3,nItem4,nItem5,aPenDoc,aTpPen,cCcFilial,cCcPara,cNDepto,cCcMatr,cFilAtu,cMatAtu,cDepAtu,oDlgMain,Nil,aAvisos),;
						 IF(aRetorno[1] == 1, oDlgMain:End(), "")},;
					   { || aRetorno := {2, nItem2, nItem3, nItem4, nItem5}, oDlgMain:End() } )
	
	//Contorno ao bug que deixa o nItem5 private em branco 
	nOpcao := aRetorno[1] //Opção selecionada no botão EnchoiceBar
	nItem2 := aRetorno[2] //Conteúdo do nItem2
	nItem3 := aRetorno[3] //Conteúdo do nItem3
	nItem4 := aRetorno[4] //Conteúdo do nItem4
	nItem5 := aRetorno[5] //Conteúdo do nItem5
	
	Self:processaFechamentoTransferencia(nOpcao)

Return

/*/{Protheus.doc} carregaTransferenciasEMatriculaAtual
Carrega Lançamentos de Transferências e Matrícula Atual
@author brunno.costa
@since 20/03/2024
@version 1.0
@param 01 - lRet      , lógico, retorna por referência se existem pendências válidas
@param 02 - lPorDepart, lógico, indica carga por departamento
/*/
Method carregaTransferenciasEMatriculaAtual(lRet, lPorDepart) CLASS QAXA010AuxClass

	Local lPergunta := Iif(lPorDepart, .F., SuperGetMv("MV_QDOFTRA",.F.,.T.))

	Default lPorDepart := .F.

	//Carrega os Lactos de Transferencia e Matricula atual
	If QAB->(DbSeek(cFilAtu+cMatAtu))
		While QAB->(!Eof()) .And. QAB->QAB_FILP+QAB->QAB_MATP == cFilAtu+cMatAtu
			If QAB->QAB_FILP+QAB->QAB_MATP == cFilAtu+cMatAtu
				If QAB->QAB_FILP+QAB->QAB_MATP+QAB->QAB_CCP <> QAB->QAB_FILD+QAB->QAB_MATD+QAB->QAB_CCD
					If Ascan(aBuscaQD1,{|X| X[1]+X[2]+X[3] == QAB->QAB_FILD+QAB->QAB_MATD+QAB->QAB_CCD}) == 0
						Aadd(aBuscaQD1,{QAB->QAB_FILD,QAB->QAB_MATD,QAB->QAB_CCD})
					Endif
				EndIf
			EndIf
			QAB->(DbSkip())
		EndDo
		cFilAtu	:= QAA->QAA_FILIAL
		cMatAtu	:= QAA->QAA_MAT
	EndIf

	aTpPen := { { .T.,.F., OemToAnsi(STR0070),"D",Space(TAMSX3("QAA_FILIAL")[1]+TAMSX3("QAA_MAT")[1]) },;   //	"Digitação"
				{ .T.,.F., OemToAnsi(STR0071),"E",Space(TAMSX3("QAA_FILIAL")[1]+TAMSX3("QAA_MAT")[1]) },;	// "Elaboração"
				{ .T.,.F., OemToAnsi(STR0072),"R",Space(TAMSX3("QAA_FILIAL")[1]+TAMSX3("QAA_MAT")[1]) },;	// "Revisão"
				{ .T.,.F., OemToAnsi(STR0073),"A",Space(TAMSX3("QAA_FILIAL")[1]+TAMSX3("QAA_MAT")[1]) },;	// "Aprovação"
				{ .T.,.F., OemToAnsi(STR0074),"H",Space(TAMSX3("QAA_FILIAL")[1]+TAMSX3("QAA_MAT")[1]) },;	// "Homologação"
				{ .T.,.F., OemToAnsi(STR0075),"I",Space(TAMSX3("QAA_FILIAL")[1]+TAMSX3("QAA_MAT")[1]) },;	// "Distribuição"
				{ .T.,.F., OemToAnsi(STR0076),"L",Space(TAMSX3("QAA_FILIAL")[1]+TAMSX3("QAA_MAT")[1]) },;	// "Leitura"
				{ .T.,.F., OemToAnsi(STR0038),"P",Space(TAMSX3("QAA_FILIAL")[1]+TAMSX3("QAA_MAT")[1]) },;	// "Resp.Depto"   
				{ .T.,.F., OemToAnsi(STR0116),"G",Space(TAMSX3("QAA_FILIAL")[1]+TAMSX3("QAA_MAT")[1]) },; 	// "Destinatário"
				{ .T.,.F., OemToAnsi("Aviso"),"S",Space(TAMSX3("QAA_FILIAL")[1]+TAMSX3("QAA_MAT")[1]) }} 

	//STR0009 - "Aguarde..."
	//STR0031 - "Verificando pendencias"
	MsgRun(OemToAnsi(STR0031),OemToAnsi(STR0009),{|| lRet := Self:carregaPendenciasBaixadasOuNao(@aTpPen,@aPenDoc,@aDoctos,1,oDoctos,@aAvisos,oAvisos,@aAviAux,lPergunta) })

Return

/*/{Protheus.doc} checaPermissaoTransferenciaUsuario
Indica se Usuário tem Acesso Permitido para Transferir
@author brunno.costa
@since 20/03/2024
@version 1.0
@return lPermitido, lógico, indica se o acesso é permitido ao usuário
/*/
Method checaPermissaoTransferenciaUsuario() CLASS QAXA010AuxClass

	Local lPermitido := .T.
	
	//Funcionario nao tem permissao p/ responsavel
	If !VerSenha(102)
		Help(" ",1,"QDFUNCNP")
		lPermitido := .F.
	Endif

	//Verifica se o usuario logado esta transferindo suas pendencias
	If lPermitido .And. (cMatFil + cMatcod == QAA->QAA_FILIAL + QAA->QAA_MAT)
		Help(" ",1,"QD_USRNTRF")
		lPermitido := .F.
	Endif

Return lPermitido

/*/{Protheus.doc} processaFechamentoTransferencia
Processa o Fechamento da Transferência
@author brunno.costa
@since 20/03/2024
@version 1.0
@param 01 - nOpcao, número, opção de confirmação da tela: 1 = confirmou;  2 = cancelou
/*/
Method processaFechamentoTransferencia(nOpcao) CLASS QAXA010AuxClass

	If nOpcao == 1
	    //STR0009 - Aguarde..."
		//STR0036 - "Transferindo Pendencias..."
		MsgRun( OemToAnsi( STR0036 ), OemToAnsi( STR0009 ), { || FQAXA010Grv(aPenDoc,aTpPen,cCcFilial,cCcMatr,cCcPara,Nil,lChk04,nItem2,nItem3,nItem4,nItem5) } )

		//Ponto de Entrada para executar acoes apos a transferencia
		IF ExistBlock( "QDOAX010" )
			ExecBlock( "QDOAX010", .f., .f., {aPenDoc} )
		Endif
	Endif

	//STR0009 - Aguarde..."
	//STR0008 - "Selecionando Usuários"
	MsgRun( OemToAnsi( STR0008 ), OemToAnsi( STR0009 ), { || QAXA010FIL() } ) 

	DbClearFilter()
	RestArea(aSaveArea)

	If cCcFilial == cFilAtu
		DbGoTo(nPosQAA)
	Else
		QAA->(DbSeek(xFilial()))
	Endif	 

Return


/*/{Protheus.doc} retornaAvisos
Retorna avisos com base no documento posicionado
@author thiago.rover
@since 31/07/2024
@version 1.0
@param 01 - lAvisoPosicionado , lógico  , Indica se a pendência posicionada é um aviso
@param 02 - oDocumentos       , objeto  , Objeto do documento poscionado
@param 03 - aDocumentos       , array   , Lista de documentos que estão com pendência do tipo aviso
@param 04 - aAvisos           , array   , Lista de Avisos 
@param 05 - aRetAvisos        , array   , Array auxiliar que receberá os aviso 
@param 06 - cChave            , caracter, Indica se Tipo da Pendência " " - Ambas/ "B"- Baixada/ "P"- Pendente
/*/
Method retornaAvisos(lAvisoPosicionado, oDocumentos, aDocumentos, aAvisos, aRetAvisos, cChave) CLASS QAXA010AuxClass
 
	Local nIndiceAviso      := 1
	Local nIndiceDocumentos := iif(ValType(oDoctos) == 'U' , 1, oDoctos:nAt)
	
	If lAvisoPosicionado .AND. Len(aDocumentos) > 0
		For nIndiceAviso := 1 to Len(aAvisos)
			If aAvisos[nIndiceAviso,1] == aDocumentos[nIndiceDocumentos,7] .AND.;
			   aAvisos[nIndiceAviso,2] == aDocumentos[nIndiceDocumentos,3] .AND.;
			   aAvisos[nIndiceAviso,3] == aDocumentos[nIndiceDocumentos,4] .AND.;
			   Iif(EMPTY(cChave),.T.,cChave == aAvisos[nIndiceAviso,4])
					aAdd(aRetAvisos,aAvisos[nIndiceAviso])
			Endif
		Next
	Endif
Return 

/*/{Protheus.doc} validaSeOUsuarioEDistribuidorDeAlgumDocumento
Valida se o usuário faz parte da lista de distribuidore em algum documento

@author thiago.rover
@since 08/10/2024
@version 1.0
@param1 cAliasQDZ, caracter, variável que representa o alias da query

@return True  - Indica que o usuário faz parte da lista de distruidores em algum documento
        False - Indica que o usuário não faz parte da lista de distruidores em nenhum documento
/*/
Method validaSeOUsuarioEDistribuidorDeAlgumDocumento(cAliasQDZ) CLASS QAXA010AuxClass
 
	Local aBindParam   := {}
	Local cQuery       := ""
	Local lChangeQuery := .F.

	cQuery := " SELECT QDZ_FILIAL, " 
	cQuery +=        " QDZ_DOCTO, "
	cQuery +=        " QDZ_RV, "
	cQuery +=        " QDZ_DEPTO, " 
	cQuery +=        " QDZ_FILMAT, "
	cQuery +=        " QDZ_MAT "
	cQuery += " FROM "+RetSqlName("QDH")+" QDH "
	cQuery += " INNER JOIN "+RetSqlName("QDZ")+" QDZ "
	cQuery += " ON QDH.QDH_FILIAL = QDZ.QDZ_FILIAL "
	cQuery +=    " AND QDH.QDH_DOCTO = QDZ.QDZ_DOCTO "
	cQuery +=    " AND QDH.QDH_RV = QDZ.QDZ_RV "
	cQuery += " WHERE "

	aAdd(aBindParam, {xFilial("QAA"), "S"})
	aAdd(aBindParam, {QAA->QAA_MAT, "S"})
	aAdd(aBindParam, {{'D', 'E', 'R', 'A', 'H'}, "A"})
	aAdd(aBindParam, {' ', "S"})
	aAdd(aBindParam, {' ', "S"})
	cQuery +=   " QDZ.QDZ_FILMAT = ? " 
	cQuery +=   " AND QDZ.QDZ_MAT = ? " 
	cQuery +=   " AND QDH.QDH_STATUS in (?) "
	cQuery +=   " AND QDH.D_E_L_E_T_ = ? "
	cQuery +=   " AND QDZ.D_E_L_E_T_ = ? "

	cAliasQDZ := QLTQueryManager():executeQueryWithBind(cQuery, aBindParam, lChangeQuery)

Return Iif((cAliasQDZ)->(EOF()), .F., .T.)


/*/{Protheus.doc} validaSeOUsuarioEOUnicoDistribuidorDeAlgumDocumento
Valida se o usuário é o único distribuidor em algum documento

@author thiago.rover
@since 09/10/2024
@version 1.0

@param 01 - cAliasQDZ, caracter, retorna por referência o alias da consulta QDZ

@return True  - Indica que o usuário é o único distruidor em algum documento
        False - Indica que o usuário não é o único distruidor em nenhum documento
/*/
Method validaSeOUsuarioEOUnicoDistribuidorDeAlgumDocumento(cAliasQDZ) CLASS QAXA010AuxClass
 
	Local aBindParam   := {}
	Local cAliasQDZ    := ""
	Local cQuery       := ""
	Local lChangeQuery := .F.
	Local oManager     := QLTQueryManager():New()

    cQuery +=    " SELECT "
	cQuery +=        " QDZQAA.QDZ_FILIAL, "
    cQuery +=        " QDZQAA.QDZ_DOCTO, " 
    cQuery +=        " QDZQAA.QDZ_RV, "
    cQuery +=        " QDZQAA.QDZ_DEPTO, " 
    cQuery +=        " QDZQAA.QDZ_FILMAT "
    cQuery +=    " FROM "        + RetSqlName("QDH")+" QDH "
    cQuery +=    " INNER JOIN "  + RetSqlName("QDZ")+" QDZQAA "
    cQuery +=            "  ON " 
	
	aAdd(aBindParam, {QAA->QAA_FILIAL, "S"})
	aAdd(aBindParam, {QAA->QAA_MAT   , "S"})
	aAdd(aBindParam, {' '            , "S"})
	cQuery +=                " QDZQAA.QDZ_FILMAT = ? "
	cQuery +=            " AND QDZQAA.QDZ_MAT    = ? "
	cQuery +=            " AND QDZQAA.D_E_L_E_T_ = ? "

	aAdd(aBindParam, {{'D', 'E', 'R', 'A', 'H', 'I'}, "A"})
	aAdd(aBindParam, {' '                           , "S"})
	cQuery +=            " AND " + oManager:MontaQueryComparacaoFiliais("QDZ", "QDH", "QDZQAA", "QDH")
    cQuery +=            " AND QDZQAA.QDZ_DOCTO  = QDH.QDH_DOCTO"
    cQuery +=            " AND QDZQAA.QDZ_RV     = QDH.QDH_RV   "
	cQuery +=            " AND SUBSTRING(QDH.QDH_STATUS, 1, 1) in (?) "
    cQuery +=            " AND QDH.D_E_L_E_T_   = ? "


    cQuery +=    " LEFT JOIN "+RetSqlName("QDZ")+" QDZ_OUTROS "
	aAdd(aBindParam, {' '                           , "S"})
    cQuery +=            "  ON " + oManager:MontaQueryComparacaoFiliais("QDZ", "QDH", "QDZ_OUTROS", "QDH")
    cQuery +=            " AND QDZ_OUTROS.QDZ_DOCTO  = QDH.QDH_DOCTO "
    cQuery +=            " AND QDZ_OUTROS.QDZ_RV     = QDH.QDH_RV"
	cQuery +=            " AND CONCAT(QDZ_OUTROS.QDZ_FILMAT, QDZ_OUTROS.QDZ_MAT) <> CONCAT(QDZQAA.QDZ_FILMAT, QDZQAA.QDZ_MAT) "
	cQuery +=            " AND QDZ_OUTROS.D_E_L_E_T_ = ? "

    cQuery +=    " WHERE "
	cQuery +=        " QDZ_OUTROS.QDZ_DOCTO IS NULL " //Não existe outro distribuidor no documento

	cQuery := oManager:changeQuery(cQuery)

	cAliasQDZ := oManager:executeQueryWithBind(cQuery, aBindParam, lChangeQuery)

Return Iif((cAliasQDZ)->(EOF()), .F., .T.)
