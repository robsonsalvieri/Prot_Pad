#INCLUDE "TOTVS.CH"
#INCLUDE "QDOA110.CH"
#INCLUDE "MSOLE.CH"

// Define as posições dos campos no array aQDH
#DEFINE POS_AQDH_STATUS   1  // Posição do Status
#DEFINE POS_AQDH_DOCTP    2  // Posição do Tipo de Documento
#DEFINE POS_AQDH_DOCTO    3  // Posição do Código do Documento
#DEFINE POS_AQDH_RV       4  // Posição da Revisão
#DEFINE POS_AQDH_TITULO   5  // Posição do Título
#DEFINE POS_AQDH_FILIAL   6  // Posição da Filial

#DEFINE INI_AQDH_DOCTP    CriaVar("QDH_CODTP")   // Inicializa variável para o tipo de documento
#DEFINE INI_AQDH_DOCTO    CriaVar("QDH_DOCTO")   // Inicializa variável para o código do documento
#DEFINE INI_AQDH_RV       CriaVar("QDH_RV")      // Inicializa variável para a revisão do documento
#DEFINE INI_AQDH_TITULO   CriaVar("QDH_TITULO")  // Inicializa variável para o título do documento

// Define as posições dos campos no array aQDGREGS
#DEFINE POS_AQDGREGS_FLAG     1  // Posição do flag (ativo/inativo)
#DEFINE POS_AQDGREGS_DESCDP   2  // Posição da Descrição do Departamento
#DEFINE POS_AQDGREGS_MATRI    3  // Posição da Matrícula
#DEFINE POS_AQDGREGS_PASTA    4  // Posição da Pasta
#DEFINE POS_AQDGREGS_NOME     5  // Posição do Nome
#DEFINE POS_AQDGREGS_DESCPT   6  // Posição da Descrição da Pasta
#DEFINE POS_AQDGREGS_TPREC    7  // Posição do Tipo de Recebimento
#DEFINE POS_AQDGREGS_NRCOP    8  // Posição do Número de Cópias
#DEFINE POS_AQDGREGS_TIPO     9  // Posição do Tipo (D/P)
#DEFINE POS_AQDGREGS_FILMAT  10  // Posição da Filial do Mat
#DEFINE POS_AQDGREGS_DEPTO   11  // Posição do Departamento
#DEFINE POS_AQDGREGS_RECEB   12  // Posição do campo Recebe
#DEFINE POS_AQDGREGS_TPRCBT  13  // Posição do campo Tipo de Recebimento (código)
#DEFINE POS_AQDGREGS_FILIAL  14  // Posição da Filial
#DEFINE POS_AQDGREGS_DOCTO   15  // Posição do Documento
#DEFINE POS_AQDGREGS_RV      16  // Posição da Revisão
#DEFINE POS_AQDGREGS_STATUS  17  // Posição do Status da Pasta

#DEFINE INI_AQDGREGS_DEPTO  Space(FWSX3Util():GetFieldStruct("QDG_DEPTO")[3])   // Valor inicial para Departamento
#DEFINE INI_AQDGREGS_DESCDP Space(FWSX3Util():GetFieldStruct("QAD_DESC")[3])    // Valor inicial para Descrição do Departamento
#DEFINE INI_AQDGREGS_MATRI  Space(FWSX3Util():GetFieldStruct("QDG_MAT")[3])     // Valor inicial para Matrícula
#DEFINE INI_AQDGREGS_NOME   Space(FWSX3Util():GetFieldStruct("QAA_NOME")[3])    // Valor inicial para Nome
#DEFINE INI_AQDGREGS_NRCOP  Space(FWSX3Util():GetFieldStruct("QDG_NCOP")[3])    // Valor inicial para Número de Cópias
#DEFINE INI_AQDGREGS_PASTA  Space(FWSX3Util():GetFieldStruct("QDG_CODMAN")[3])  // Valor inicial para Pasta
#DEFINE INI_AQDGREGS_TPREC  Space(FWSX3Util():GetFieldStruct("QDG_TPRCBT")[3])  // Valor inicial para Tipo de Recebimento
#DEFINE INI_AQDGREGS_DESCPT Space(FWSX3Util():GetFieldStruct("QDC_DESC")[3])   // Valor inicial para Descrição da Pasta


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³QDOA110   ³ Autor ³ Newton R. Ghiraldelli   ³ Data ³ 23/09/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Distribuicao de Documentos                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³QDOA110( nReg )                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³nReg - Numero do Registro                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³SIGAQDO - Generico                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³  Data  ³ BOPS ³ Programador ³Alteracao                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³27/02/02³ META ³ Eduardo S.  ³ Alterado para gerar aviso de Cancelamento ³±±
±±³        ³      ³             ³ de Documento.                             ³±±
±±³28/02/02³------³ Eduardo S.  ³ Acertado para salvar o Docto HTML no dire-³±±
±±³        ³      ³             ³ torio especificado no param. "MV_QPATHWH".³±±
±±³24/04/02³ META ³ Eduardo S.  ³ Alterado para gerar pendencia de Devolucao³±±
±±³        ³      ³             ³ de Revisao Anterior para Dist. Copia Papel³±±
±±³08/07/02³ META ³ Eduardo S.  ³ Alterado para apresentar a tela de impres-³±±
±±³        ³      ³             ³ sao do protocolo somente quando existirem ³±±
±±³        ³      ³             ³ dados para impressao.                     ³±±
±±³18/07/02³------³ Eduardo S.  ³ Alterado para baixar o aviso "inclusao do ³±±
±±³        ³      ³             ³ questionario" da revisao anterior na dis- ³±±
±±³        ³      ³             ³ tribuicao da nova revisao.                ³±±
±±³22/07/02³------³ Eduardo S.  ³ Alterado para gravar documento html confor³±±
±±³        ³      ³             ³ me definido no parametro "MV_QDHTML".     ³±±
±±³19/09/02³ ---- ³ Eduardo S.  ³ Acerto para nao permitir a distribuicao   ³±±
±±³        ³      ³             ³ com a qtde de dias negativo.              ³±±
±±³03/10/02³060400³ Eduardo S.  ³ Acerto para prever departamento com ate 20³±±
±±³        ³      ³             ³ caracteres na inclusao do destinatario.   ³±±
±±³23/10/02³060642³ Eduardo S.  ³ Alterado para posicionar corretamente na  ³±±
±±³        ³      ³             ³ ultima revisao do docto.                  ³±±
±±³06/01/03³ ---- ³ Eduardo S.  ³ Acerto ao carregar dest. apos ultima pend.³±±
±±³08/01/03³ ---- ³ Eduardo S.  ³ Alterado para permitir pesquisar usuarios ³±±
±±³        ³      ³             ³ de outras filiais na inclusao de destinat.³±±
±±ÀÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QDOA110(nReg)
                                                       	
	Local aData     := {}
	Local aQPath    := QDOPATH()
	Local aUsrMat   := QA_USUARIO()
	Local cMsgIna   := ""
	Local cQPathTrm := aQPath[3]
	Local cTextoD   := aQPath[4]
	Local lApelido  := aUsrMat[1]
	Local nT        := 0
	Local oCa       := LoaDbitmap( GetResources(), "BR_PRETO" )
	Local oDi       := LoaDbitmap( GetResources(), "BR_AZUL" )

	Private aInativo   := {}
	Private aQDG       := {}
	Private aQDGRegs   := {}
	Private aQDH       := {}
	Private bQDGLine   := Nil
	Private bQDHLine   := Nil
	Private cCadastro  := ""
	Private cCodApDes  := Space(TamSx3("QAA_MAT")[1])
	Private cCodApSol  := Space(TamSx3("QAA_MAT")[1])
	Private cDtEmiss   := dDatabase
	Private cFilApDes  := Space(FWSizeFilial()) //Space( 02 )
	Private cFilApSol  := Space(FWSizeFilial()) //Space( 02 )
	Private cFilDep    := xFilial("QAD")
	Private cFilMat    := cFilAnt
	Private cMatCod    := aUsrMat[3]
	Private cMatDep    := aUsrMat[4]
	Private cMatFil    := aUsrMat[2]
	Private cNomFilial := Space( 40 )
	Private cNomRece   := " "
	Private cTpCopia   := OemToAnsi( STR0001 ) // "Copia Controlada"
	Private hNo        := LoadBitmap( GetResources(), "LBNO" )
	Private hOK        := LoadBitmap( GetResources(), "LBTIK" )
	Private Inclui     := .F.
	Private lAltDoc    := .T.
	Private lContinua  := .F.
	Private lGeraRev   := .F.
	Private lTrat      := GetMv("MV_QDOQDG",.T.,.F.)
	Private nItem      := 2
	Private nOpca      := 0
	Private nQaConPad  := 4
	Private oGet       := Nil
	Private oQDG       := Nil
	Private oQDH       := Nil
	Private oWord      := Nil

	//Verifica se o usuario atual estacadastrado com apelido no cadastro de responsaveis para poder acessar a funcao
	If !lApelido
		Help( " ", 1, "QD_LOGIN") // "O usuario atual nao possui um Login" ### "cadastrado igual ao apelido do configurador."
		Return .F.
	EndIf

	//Verifica se o usuario atual tem alguma pendencia tipo distribuicao para confirmar se o usuario esta cadastrado como distribuidor de documentos
	lContinua := .F.
	QD1->(DbSetOrder(3))
	If QD1->(DbSeek(cMatFil+cMatCod+"P"))
		While QD1->(!Eof()) .And. QD1->QD1_FILMAT+QD1->QD1_MAT+QD1->QD1_PENDEN == cMatFil+cMatCod+"P"
			If QD1->QD1_TPPEND == "I  "
				lContinua:= .T.
				Exit
			EndIf
			QD1->(DbSkip())
		EndDo
	EndIf

	If !lContinua
		Help(" ",1,"QD_USRNDST")
		Return .T.
	EndIf

	//Faz a selecao dos documentos a serem distribuidos
	MsgRun(OemToAnsi(STR0002),OemToAnsi(STR0003),{|| QD110LeQDH()}) // "Selecionando Distribuidores" ### "Aguarde..."

	bQDHLine := { || {	If(Posicione("QDH",1,aQDH[oQDH:nAt,POS_AQDH_FILIAL]+aQDH[oQDH:nAt,POS_AQDH_DOCTO]+aQDH[oQDH:nAt,POS_AQDH_RV],"QDH_CANCEL") == "S",oCa,oDi),;														
						If( Len( aQDH ) > 0, aQDH[ oQDH:nAt, POS_AQDH_DOCTP ] , INI_AQDH_DOCTP ),;
						If( Len( aQDH ) > 0, aQDH[ oQDH:nAt, POS_AQDH_DOCTO ] , INI_AQDH_DOCTO ),;
						If( Len( aQDH ) > 0, aQDH[ oQDH:nAt, POS_AQDH_RV    ] , INI_AQDH_RV    ),;
						If( Len( aQDH ) > 0, aQDH[ oQDH:nAt, POS_AQDH_TITULO] , INI_AQDH_TITULO) } }

	If Len(aQDH) > 0
		QD110MsDlg(nReg)
	Else
		IF Len(aInativo) > 0
			cMsgIna := ""
			For nT := 1 to Len(aInativo)
				cMsgIna += STR0060 + aInativo[nT,1] + STR0061 + aInativo[nT,2] + "-" + QA_NUSR(aInativo[nT,1], aInativo[nT,2]) + CHR(13) // "Filial: "###" Matricula: "
			Next
			MsgStop(STR0062 + CHR(13) + cMsgIna) //"Existem Usuarios Inativos, Utilize a Transferencia no cadastro de Usuarios "
		Endif
		Help(" ", 1, "QDNEDISTR")
		Return .T.
	EndIf

	aData := DIRECTORY(cQPathTrm + "*.CEL")
	For nT := 1 to Len(aData)
		If File(cQPathTrm + AllTrim(aData[nT,1]))
			FErase(cQPathTrm + AllTrim(aData[nT,1]))
		EndIf
	Next nT

	aData := DIRECTORY(cQPathTrm + "*.DOT")
	For nT := 1 to Len(aData)
		If File(cQPathTrm + AllTrim(aData[nT,1]))
			FErase(cQPathTrm + AllTrim(aData[nT,1]))
		EndIf
	Next nT

	If File(cQPathTrm + cTextoD)
		FErase(cQPathTrm + cTextoD)
	EndIf

	QD1->( dbClearFilter() )

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³QD110MsDlg³ Autor ³ Newton R. Ghiraldelli   ³ Data ³ 23/09/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Mostra Dialogo de Distribuicao de Documentos                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QD110MSDlg(ExpN1)                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ ExpN1 - Posicao do Registro                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³QDOA110                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD110MsDlg(nReg)

	Local cQDG     := ""
	Local cQDH     := ""
	Local nWebApp  := 0
	Local oBtn1    := Nil
	Local oBtn7    := Nil
	Local oDlgM    := Nil
	Local oFwLayer := Nil
	Local oPanel1  := Nil
	Local oPanel2  := Nil
	Local oPanel3  := Nil
	Local oPanel4  := Nil
	Local oSize    := Nil

	Default nReg := 0

	If GetRemoteType() == 5
		nWebApp := 27
	EndIF

	// Define tamanho da tela
	oSize := FwDefSize():New(.T.,,,oDlgM)
	oSize:AddObject( "TELA" ,  100, 100, .T., .T. ) // Totalmente dimensionavel
	oSize:lProp := .T. // Proporcional             
	oSize:aMargins := { 3, 3, 3, 3 } // Espaco ao lado dos objetos 0, entre eles 3 

	DEFINE MSDIALOG oDlgM TITLE OemToAnsi(STR0004) FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] PIXEL
	oDlgM:lMaximized := .T.

	//Criando a camada
	oFwLayer := FwLayer():New()
	oFwLayer:init(oDlgM,.F.)

	//Adicionando linhas 
	oFWLayer:addLine("DOCUMENTO"   , 044, .F.)
	oFWLayer:addLine("BTNDOC"      , 006, .F.)
	oFWLayer:addLine("DESTINATARIO", 045, .F.)
	oFWLayer:addLine("BTNDEST"     , 005, .F.)

	//Adicionando as colunas das linhas
	oFWLayer:addCollumn("DOCOLUN"  , 100, .F., "DOCUMENTO"   )
	oFWLayer:addCollumn("BTNCOLDOC", 050, .F., "BTNDOC"      )
	oFWLayer:addCollumn("DESTCOLUN", 100, .F., "DESTINATARIO")
	oFWLayer:addCollumn("BTNCOLDES", 050, .F., "BTNDEST"     )

	oFWLayer:AddWindow("DOCOLUN"  ,"oPanel1", STR0005 ,100,.F.,.T.,,"DOCUMENTO"   ,{ || })
	oFWLayer:AddWindow("DESTCOLUN","oPanel3", STR0007 ,100,.F.,.T.,,"DESTINATARIO",{ || })

	//Criando os paineis
	oPanel1 := oFWLayer:GetWinPanel("DOCOLUN"  ,"oPanel1", "DOCUMENTO"   )
	oPanel2 := oFWLayer:GetColPanel("BTNCOLDOC", "BTNDOC"                )
	oPanel3 := oFWLayer:GetWinPanel("DESTCOLUN","oPanel3", "DESTINATARIO")
	oPanel4 := oFWLayer:GetColPanel("BTNCOLDES", "BTNDEST"               )

	@ 2,2 LISTBOX oQDH VAR	cQDH ;
				FIELDS;
				HEADER " ",	TitSX3("QDH_CODTP")[1],;
							TitSX3("QDH_DOCTO")[1],;
							TitSX3("QDH_RV")[1],;
							TitSX3("QDH_TITULO")[1] ;
				COLSIZES 50,28,50,50,100 ;							
				SIZE 100,(1917/3) OF oPanel1 PIXEL ; 
				WHEN Len( aQDH ) > 0 ;
				ON   CHANGE(aQDG := If(Len(aQDH) > 0 .And. Len(aQDGRegs) > 0,aQDGRegs[oQDH:nAt],{}),oQDG:SetArray(aQDG),oQDG:nAt:= 1,oQDG:bLine:= bQDGLine,oQDG:Refresh())
					
	oQDH:SetArray( aQDH )
	oQDH:bLine := bQDHLine
	If nReg > 0
		QDH->(dbGoTo(nReg))
		If (nPosQDH := aScan(aQDH,{|X| X[POS_AQDH_FILIAL] + X[POS_AQDH_DOCTO] + X[POS_AQDH_RV] == QDH->QDH_FILIAL + QDH->QDH_DOCTO + QDH->QDH_RV })) > 0
			oQDH:nAt:=nPosQDH
		EndIf
	EndIf
	oQDH:Align:= CONTROL_ALIGN_ALLCLIENT

	@ 002,003 BUTTON oBtn1 PROMPT OemToAnsi(STR0055) SIZE 042,011 OF oPanel2 PIXEL; //"Distribuir"
					ACTION If( QD110VeQDH(),( If( QD110CfDst(), .t.,), If( Len( aQDH ) == 0, oDlgM:End(), .t. ) ) , .f. )

	@ 002,048 BUTTON oBtn7 PROMPT OemToAnsi(STR0063) SIZE 042,011 OF oPanel2 PIXEL; //"Legenda"
					ACTION QD110Legen() 

	@ 2,2 LISTBOX oQDG VAR cQDG;
				FIELDS;
				HEADER	TiTSX3("QDG_DEPTO")[1],;
						TiTSX3("QAD_DESC")[1],;						
						TiTSX3("QDG_MAT")[1],;
						TiTSX3("QAA_NOME")[1],;
						TiTSX3("QDG_CODMAN")[1],;
						TiTSX3("QDC_DESC")[1],;
						TiTSX3("QDG_TPRCBT")[1],;
						TiTSX3("QDG_NCOP")[1] ;
				SIZE 500,500 OF oPanel3	PIXEL	WHEN Len( aQDGRegs ) > 0

	oQDG:SetArray( aQDG )
	oQDG:bLine := bQDGLine
	oQDG:Align := CONTROL_ALIGN_ALLCLIENT

	@ 002,003 BUTTON oBtn6 PROMPT OemToAnsi(STR0048) SIZE 042,011 OF oPanel4 PIXEL; // "Pesquisa Depto"
					ACTION QD110PesqDep(oQDG,aQDGRegs[oQDH:nAt],2)

	@ 002,047 BUTTON oBtn5 PROMPT OemToAnsi(STR0057) SIZE 042,011 OF oPanel4 PIXEL; // "Altera Dest."
					ACTION If(QD110VeQDH(),QD110AlQDG(),.f.)

	@ 002,091 BUTTON oBtn2 PROMPT OemToAnsi(STR0058) SIZE 042,011 OF oPanel4 PIXEL; // "Inclui Dest"
					ACTION If( QD110VeQDH(),QD110InQDG(), .f. )

	@ 002,135 BUTTON oBtn3 PROMPT OemToAnsi(STR0059) SIZE 042,011 OF oPanel4 PIXEL; // "Exclui Dest"
					ACTION If( QD110VeQDH(), QD110ExQDG(), .f. )

	@ 002,179 BUTTON oBtn4 PROMPT OemToAnsi(STR0010) SIZE 042,011 OF oPanel4 PIXEL; // "Cancelar"
					ACTION oDlgM:End() 

	ACTIVATE MSDIALOG oDlgM CENTERED

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±± Funcao	  QD110LeQDH,	Autor: Newton R. Ghiraldelli, Data: 23/09/99
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±± Descricao  Monta o array de documentos em status de distribuicao
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±± Sintaxe	  QD110LeQDH()
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±± Uso		  QDOA110
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD110LeQDH()

	Local aARea    := {}
	Local aReg     := {}
	Local aRegs    := {}
	Local aStruQDH := {}
	Local cArea    := Alias()
	Local cQuery   := ""
	Local nPosCpo  := 0

	aQDG     := {}
	aQDGRegs := {}
	aQDH     := {}

	QDH->(DbSetOrder(3))
	QD1->(DbSetOrder(7))              

	aARea	  := GetArea()
	aStruQDH  := QDH->(dbStruct())

	cQuery    := "SELECT * "
	cQuery    +=  " FROM " +RetSqlName("QDH")+ " QDH "
	cQuery    += " WHERE QDH.QDH_OBSOL <> 'S' "
	cQuery    += "   AND (QDH.QDH_STATUS = 'I  ' OR QDH.QDH_STATUS = 'L  ') "
	cQuery    += "   AND QDH.D_E_L_E_T_ = ' ' "		

	cQuery    += "   AND (EXISTS(SELECT R_E_C_N_O_ FROM " + RetSqlName("QD1") + " QD1  	"	
	cQuery    += " WHERE QD1.QD1_FILIAL = QDH.QDH_FILIAL "
	cQuery    += "   AND QD1.QD1_DOCTO  = QDH.QDH_DOCTO  "
	cQuery    += "   AND QD1.QD1_RV     = QDH.QDH_RV	 "
	cQuery    += "   AND QD1.QD1_FILMAT = '"+cMatFil+"'  "
	cQuery    += "   AND QD1.QD1_MAT    = '"+cMatCod+"'  "				
	cQuery    += "   AND QD1.QD1_DEPTO  = '"+cMatDep+"'  "
	cQuery    += "   AND QD1.QD1_TPPEND = 'I  ' " 
	cQuery    += "   AND QD1.QD1_PENDEN = 'P'   "                                      
	cQuery    += "   AND QD1.D_E_L_E_T_ = ' ')) "

	cQuery    += " ORDER BY "+SqlOrder(QDH->(IndexKey()))

	cQuery := ChangeQuery(cQuery)		

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRBQDH",.F.,.T.)

	For nPosCpo := 1 To Len(aStruQDH)
		If aStruQDH[nPosCpo,2]#"C"
			TcSetField("TRBQDH",aStruQDH[nPosCpo,POS_AQDH_STATUS],aStruQDH[nPosCpo,POS_AQDH_DOCTP],;
								aStruQDH[nPosCpo,POS_AQDH_DOCTO],aStruQDH[nPosCpo,POS_AQDH_RV])
		EndIf
	Next nPosCpo

	TRBQDH->(dbGoTop())

	While TRBQDH->(!Eof())
		aRegs:= QD110LeQDG("TRBQDH")
		If Len(aRegs) > 0
			aReg:= Array(6)
			aReg[POS_AQDH_STATUS] := .T.
			aReg[POS_AQDH_DOCTP]  := TRBQDH->QDH_CODTP					
			aReg[POS_AQDH_DOCTO]  := TRBQDH->QDH_DOCTO
			aReg[POS_AQDH_RV]     := TRBQDH->QDH_RV
			aReg[POS_AQDH_TITULO] := OemToAnsi(TRBQDH->QDH_TITULO)
			aReg[POS_AQDH_FILIAL] := TRBQDH->QDH_FILIAL
			AAdd( aQDH, AClone( aReg ) )
			AAdd( aQDGRegs, Aclone( aRegs ))
		EndIF
		TRBQDH->(DbSkip())
	EndDo
	TRBQDH->(dbCloseArea())
	RestArea(aArea)

	IF ExistBlock( "QDOAP28" )  //TAM
		aQDHG:=aClone( ExecBlock( "QDOAP28", .f., .f. ,{ aClone(aQDH), aClone(aQDGRegs) })	)
		IF Len(aQDHG) > 0
			aQDH	 := aQDHG[1]
			aQDGRegs := aQDHG[2]
		Endif
	Endif

	aQDG := If( Len( aQDGRegs ) > 0, aQDGRegs[1], aQDG )

	/*
	bQDGLine: Bloco para definição das linhas da ListBox de destinatários (QDG)
	Cada elemento do array representa uma coluna da ListBox, preenchida com o valor correspondente do array aQDG.
	Caso o array esteja vazio ou o índice seja inválido, utiliza o valor padrão definido pelas constantes INI_AQDGREGS_.
	Colunas:
	[1] Departamento
	[2] Descrição do Departamento
	[3] Matrícula
	[4] Nome
	[5] Pasta
	[6] Descrição Pasta
	[7] Tipo de Recebimento
	[8] Número de Cópias
	*/
	bQDGLine := { || ;
		{ ;
			If( Len(aQDG) > 0 .And. Len(aQDG) >= oQDG:nAt, aQDG[oQDG:nAt, POS_AQDGREGS_DEPTO] , INI_AQDGREGS_DEPTO ),;  // Departamento
			If( Len(aQDG) > 0 .And. Len(aQDG) >= oQDG:nAt, aQDG[oQDG:nAt, POS_AQDGREGS_DESCDP], INI_AQDGREGS_DESCDP),;  // Descrição do Depto
			If( Len(aQDG) > 0 .And. Len(aQDG) >= oQDG:nAt, aQDG[oQDG:nAt, POS_AQDGREGS_MATRI] , INI_AQDGREGS_MATRI ),;  // Matrícula
			If( Len(aQDG) > 0 .And. Len(aQDG) >= oQDG:nAt, aQDG[oQDG:nAt, POS_AQDGREGS_NOME ] , INI_AQDGREGS_NOME  ),;  // Nome
			If( Len(aQDG) > 0 .And. Len(aQDG) >= oQDG:nAt, aQDG[oQDG:nAt, POS_AQDGREGS_PASTA] , INI_AQDGREGS_PASTA ),;  // Pasta
			If( Len(aQDG) > 0 .And. Len(aQDG) >= oQDG:nAt, aQDG[oQDG:nAt, POS_AQDGREGS_DESCPT], INI_AQDGREGS_DESCPT ),; // Descrição Pasta		
			If( Len(aQDG) > 0 .And. Len(aQDG) >= oQDG:nAt, aQDG[oQDG:nAt, POS_AQDGREGS_TPREC] , INI_AQDGREGS_TPREC ),;  // Tipo de Recebimento
			If( Len(aQDG) > 0 .And. Len(aQDG) >= oQDG:nAt, aQDG[oQDG:nAt, POS_AQDGREGS_NRCOP] , INI_AQDGREGS_NRCOP ),;  // Nº de Cópias
		};
	}

	QDH->(DbSetOrder(1))  
	DbSelectArea(cArea)

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	  ³QD110ExQDH  ³ Autor ³ Newton R. Ghiraldelli      ³ Data ³ 23/09/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³ Faz a exclusao e acerto dos array apos a baixa de um documento    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³ QD110ExQDH()                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		  ³ QDOA110                                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD110ExQDH()

	If Len(aQDH) == 0
		Return .F.
	EndIf

	ADel(aQDGRegs, oQDH:nAt)
	ASize(aQDGRegs,Len(aQDGRegs)-1)
	ADel(aQDH, oQDH:nAt)
	ASize(aQDH,Len(aQDH)-1)
	oQDH:SetArray(aQDH)
	oQDH:bLine := bQDHLine
	oQDH:nAT:=1
	oQDH:Refresh()

	If Len(aQDGRegs) > 0
		aQDG:= AClone(aQDGRegs[oQDH:nAt])
	Else
		aQDG := {{.T.,Space(09),Space(06),Space(15),Space(30),Space(30),Space(12),Space(05),Space(01),Space(02),Space(09),Space(01),Space(01),Space(02),Space(16),Space(03)}}
	EndIf

	oQDG:SetArray( aQDG )
	oQDG:bLine := bQDGLine
	oQDG:nAT:=1
	oQDG:Refresh()

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	  ³QD110VeQDH  ³ Autor ³ Newton R. Ghiraldelli      ³ Data ³ 23/09/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³ Faz verificacao e acerto do array de documentos antes de baixar a ³±±
±±³           ³ distribuicao.                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³ QD110VeQDH()                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		  ³ QDOA110                                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD110VeQDH()

Local aQDHCopia:= aClone(aQDH)
Local nC       := 0
Local nDel     := 0

	While .T.
	nDel:= 0
		For nC:= 1 To Len(aQDHCopia)
			If !aQDHCopia[nC,1]
			ADel(aQDHCopia,nC)
			ASize(aQDHCopia,Len(aQDHCopia)-1)
			nDel++
			Exit
			EndIf
		Next nC
		If nC >= Len(aQDHCopia)+nDel .And. Len(aQDHCopia) <> 0
		Return .T.
		EndIf
		If Len(aQDHCopia) == 0
		Return .F.
		EndIf
	EndDo

Return 

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±± Fun‡ao	  QD110LeQDG, Autor: Newton R. Ghiraldelli, Data: 23/09/99
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±± Descricao  Monta o array de destinatarios referentes ao documento
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±± Sintaxe	  QD110LeQDG()
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±± Uso		  QDOA110
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD110LeQDG(cAliasQDH)
	Local aArea      := {}
	Local aReg       := {}
	Local aRegs      := {}
	Local cQuery     := ""
	Local lAltQAD    := .F.
	Local nIndQDG    := QDG->(IndexOrd())
	Local nRegAux    := 0
	Local nRegQDG    := QDG->(Recno())
	Local oQLTQueryM := QLTQueryManager():New()

	aArea := GetArea()
        
	cQuery    := "SELECT QDG.QDG_FILIAL,QDG.QDG_DOCTO, QDG.QDG_RV, "
	cQuery    += "       QDG.QDG_TIPO,  QDG.QDG_FILMAT,QDG.QDG_MAT,   QDG.QDG_CODMAN, "
	cQuery    += "       QDG.QDG_TPRCBT,QDG.QDG_NCOP,  QDG.QDG_RECEB, QDG.QDG_DEPTO, "				
	cQuery    += "       QAA.QAA_FIM,   QAA.QAA_STATUS,QAA.QAA_INICIO,QAA.QAA_NOME, QAA.QAA_TPRCBT, "			
	cQuery    += "       QAD.QAD_DESC,  QAD.QAD_FILMAT,QAD.QAD_MAT,   QAD.QAD_FILIAL,"						

	cQuery    += "       ( SELECT QDC.QDC_DESC FROM "+RetSqlName("QDC")+" QDC "
	cQuery    += "          WHERE QDG.QDG_TIPO = 'P' AND "

	cQuery    += oQLTQueryM:MontaQueryComparacaoFiliais("QDC", "QDG", "QDC", "QDG") + " AND "			

	cQuery    += " QDC.QDC_CODMAN = QDG.QDG_CODMAN AND QDC.D_E_L_E_T_ = ' ' ) "
	cQuery    += " QDC_DESC "		

	cQuery    += ",      ( SELECT QDC.QDC_STATUS FROM "+RetSqlName("QDC")+" QDC "
	cQuery    += "          WHERE QDG.QDG_TIPO = 'P' AND "

	cQuery    += oQLTQueryM:MontaQueryComparacaoFiliais("QDC", "QDG", "QDC", "QDG") + " AND "			

	cQuery    += " QDC.QDC_CODMAN = QDG.QDG_CODMAN AND QDC.D_E_L_E_T_ = ' ' ) "
	cQuery    += " QDC_STATUS "		

	cQuery    += "  FROM "+RetSqlName("QDG")+" QDG,"+ RetSqlName("QAA")+" QAA, "+RetSqlName("QAD")+" QAD"
	cQuery    += " WHERE "
	cQuery    += "       QDG.QDG_FILIAL = '"+TRBQDH->QDH_FILIAL+"' AND "
	cQuery    += "       QDG.QDG_DOCTO  = '"+TRBQDH->QDH_DOCTO+"' AND "
	cQuery    += "       QDG.QDG_RV	  = '"+ TRBQDH->QDH_RV +"' AND "      
	cQuery    += "       QDG.QDG_SIT <> 'I' AND "
	cQuery    += "       QDG.QDG_RECEB = 'S' AND "		
	cQuery    += "       QDG.D_E_L_E_T_ = ' ' AND "							

	cQuery    += "       QAA.QAA_FILIAL = QDG.QDG_FILMAT AND "
	cQuery    += "       QAA.QAA_MAT    = QDG.QDG_MAT AND "		
	cQuery    += "       QAA.D_E_L_E_T_ = ' ' AND "			 

	cQuery    += oQLTQueryM:MontaQueryComparacaoFiliaisComCamposEspecificos("QAD", "QAD.QAD_FILIAL", "QAA", "QDG.QDG_FILMAT") + " AND "

	cQuery     += " QAD.QAD_CUSTO    = QDG.QDG_DEPTO AND "

	cQuery    += oQLTQueryM:MontaQueryComparacaoFiliais("QAD", "QDG", "QAD", "QDG") + " AND "			
			
	cQuery    += " QAD.D_E_L_E_T_ = ' ' "			 								
	cQuery    += " ORDER BY "+SqlOrder("QDG_FILMAT+QDG_DEPTO+QAD_DESC+QDG_CODMAN+QAA_NOME")

	cQuery := ChangeQuery(cQuery)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRBQDG",.F.,.T.)

	TcSetField("TRBQDG","QAA_INICIO","D")                                    
	TcSetField("TRBQDG","QAA_FIM","D")
              
	TRBQDG->(DbGotop())	                
			
	While !TRBQDG->(Eof())

		If TRBQDG->QDG_TIPO == "P" .AND. (TRBQDG->(QAD_FILMAT+QAD_MAT) != TRBQDG->(QDG_FILMAT+QDG_MAT))
			QAA->(DbSetOrder(1))
			If QAA->(DbSeek(TRBQDG->(QAD_FILMAT+QAD_MAT)))
				If lTrat
					If ! QA_SitFolh() .or. TRBQDG->QAA_TPRCBT == "4"
						AADD(aInativo,{QAA->QAA_FILIAL,QAA->QAA_MAT})
						TRBQDG->(DbSkip())
						Loop
					Else
						lAltQAD	:=.T.									
					Endif
				Else
					If ! QA_SitFolh()
						AADD(aInativo,{QAA->QAA_FILIAL,QAA->QAA_MAT})
						TRBQDG->(DbSkip())
						Loop
					Else
						lAltQAD	:=.T.									
					Endif
				Endif
			Endif
		Else
			lAltQAD	:=.F.		
			If lTrat
				If !(((Empty(TRBQDG->QAA_FIM) .And. TRBQDG->QAA_STATUS <> "2") .Or.;
					(! Empty(TRBQDG->QAA_FIM) .And. TRBQDG->QAA_FIM >= dDataBase)) .And.;
					(Empty(TRBQDG->QAA_INICIO) .Or. dDataBase >= TRBQDG->QAA_INICIO).And. TRBQDG->QAA_TPRCBT <> "4")			
					
					AADD(aInativo,{TRBQDG->QDG_FILMAT,TRBQDG->QDG_MAT})
					TRBQDG->(DbSkip())
					Loop
				EndIf
			Else
				If !(((Empty(TRBQDG->QAA_FIM) .And. TRBQDG->QAA_STATUS <> "2") .Or.;
					(! Empty(TRBQDG->QAA_FIM) .And. TRBQDG->QAA_FIM >= dDataBase)) .And.;
					(Empty(TRBQDG->QAA_INICIO) .Or. dDataBase >= TRBQDG->QAA_INICIO))			
				
					AADD(aInativo,{TRBQDG->QDG_FILMAT,TRBQDG->QDG_MAT})
					TRBQDG->(DbSkip())
					Loop
				EndIf
			Endif
		EndIf
				
		aReg := Array(17)			
			
		aReg[ POS_AQDGREGS_FLAG    ] := .T.
		aReg[ POS_AQDGREGS_DESCDP  ] := TRBQDG->QAD_DESC
		aReg[ POS_AQDGREGS_MATRI   ] := TRBQDG->QDG_MAT
		aReg[ POS_AQDGREGS_PASTA   ] := TRBQDG->QDG_CODMAN
		aReg[ POS_AQDGREGS_NOME    ] := TRBQDG->QAA_NOME
		aReg[ POS_AQDGREGS_DESCPT  ] := TRBQDG->QDC_DESC
		aReg[ POS_AQDGREGS_TPREC   ] := QDXFNDsDtr(TRBQDG->QDG_TPRCBT)
		aReg[ POS_AQDGREGS_NRCOP   ] := TRANSFORM(TRBQDG->QDG_NCOP, "@E 9,999")
		aReg[ POS_AQDGREGS_TIPO    ] := TRBQDG->QDG_TIPO
		aReg[ POS_AQDGREGS_FILMAT  ] := TRBQDG->QDG_FILMAT
		aReg[ POS_AQDGREGS_DEPTO   ] := TRBQDG->QDG_DEPTO
		aReg[ POS_AQDGREGS_RECEB   ] := TRBQDG->QDG_RECEB
		aReg[ POS_AQDGREGS_TPRCBT  ] := TRBQDG->QDG_TPRCBT
		aReg[ POS_AQDGREGS_FILIAL  ] := TRBQDG->QDG_FILIAL
		aReg[ POS_AQDGREGS_DOCTO   ] := TRBQDG->QDG_DOCTO
		aReg[ POS_AQDGREGS_RV      ] := TRBQDG->QDG_RV
		aReg[ POS_AQDGREGS_STATUS  ] := TRBQDG->QDC_STATUS
				
		IF lAltQAD
			aReg[POS_AQDGREGS_FILMAT] := QAA->QAA_FILIAL
			aReg[POS_AQDGREGS_MATRI]  := QAA->QAA_MAT
			aReg[POS_AQDGREGS_NOME]   := QAA->QAA_NOME

			QDG->(DbSetOrder(1))
			If QDG->(dbSeek(TRBQDG->(QDG_FILIAL+QDG_DOCTO+QDG_RV+QDG_TIPO+QDG_FILMAT+QDG_DEPTO+QDG_MAT+QDG_CODMAN)))
				nRegAux := QDG->(Recno())
				If !QDG->(dbSeek(TRBQDG->(QDG_FILIAL+QDG_DOCTO+QDG_RV+QDG_TIPO+QAA->QAA_FILIAL+QDG_DEPTO+QAA->QAA_MAT+QDG_CODMAN)))
					QDG->(dbGoTo(nRegAux))
					Begin Transaction
						RecLock("QDG",.F.)
							QDG->QDG_FILMAT := QAA->QAA_FILIAL
							QDG->QDG_MAT    := QAA->QAA_MAT
						QDG->(MsUnLock())
					End Transaction
				Else
					QDG->(dbGoTo(nRegAux))
					Begin Transaction
						RecLock("QDG",.F.)
							QDG->(dbDelete())
						QDG->(MsUnLock())
					End Transaction
					TRBQDG->(DbSkip())
					Loop
				Endif
			Endif
		Endif

		Aadd(aRegs,aReg)
		TRBQDG->(DbSkip())
	EndDo
	TRBQDG->(dbCloseArea())
	RestARea(aArea)

	QDG->(DbGoTo(nRegQDG))
	QDG->(dbSetOrder(nIndQDG))

Return aRegs

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	  ³QD110InQDG  ³ Autor ³ Newton R. Ghiraldelli      ³ Data ³ 23/09/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³Faz a inclusao de um novo destinatario durante a distribuicao      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³QD110InQDG()                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		  ³ QDOA110                                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD110InQDG()

Local nItdp  := 1
Local aDeptos:= {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Seleciona o Tipo de Destino   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !QD110MsSel(@nItdp)
	Return .F.
	EndIf
	
aRegs:= AClone(aQDGRegs[oQDH:nAt])

	If nItdp == 1
	QD110IncUsr(aRegs)
	ElseIf nItdp == 2
	QD110CarDep(@aDeptos)
	QD110IncPst(aRegs,aDeptos)
	EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	  ³QD110MsSel  ³ Autor ³ Newton R. Ghiraldelli      ³ Data ³ 23/09/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³ Monta a tela de selecao Usuarios / Pastas / Nenhum                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³ QD110MsSel(ExpN1)                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ ExpN1 - Tipo Destino (Usuario/Pasta)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		  ³ QDOA110                                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD110MsSel(nItdp)

Local oDlg
Local lRet:= .F.

DEFINE MSDIALOG oDlg FROM 000,000 TO 100,200 TITLE OemToAnsi(STR0011) PIXEL // "Destinat rios - Inclus„o"

@ 003,003 TO 035,098 LABEL OemToAnsi(STR0044) OF oDlg PIXEL // "Tipo Destino"
@ 010,010 RADIO oItdp VAR nItdp;
				ITEMS	OemToAnsi(STR0038),; // "Usuarios"
						OemToAnsi(STR0019); // "Pastas"  
				3D SIZE 035,010 OF oDlg PIXEL

DEFINE SBUTTON FROM 037,040 TYPE 1 ENABLE OF oDlg ACTION	(lRet:= .T.,oDlg:End())
DEFINE SBUTTON FROM 037,070 TYPE 2 ENABLE OF oDlg ACTION	(oDlg:End())

ACTIVATE	MSDIALOG oDlg CENTERED

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	  ³QD110ExQDG  ³ Autor ³ Newton R. Ghiraldelli      ³ Data ³ 23/09/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³Realiza exclusao de um destinatario durante a fase de distribuicao ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³QD110ExQDG()                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		  ³ QDOA110                                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD110ExQDG()

	Local aRegs   := {}
	Local nOrdQDG := QDG->(IndexOrd())

	If Len(aQDGRegs) == 0 .Or. Len(aQDG) == 1
		MessageDlg(STR0072,STR0073,1) // "A distribuição precisa ter no mínimo um destinatário!" //"Exclusão não Permitida"
		Return .F.
	EndIf

	aRegs:= AClone(aQDGRegs[oQDH:nAt])
	If Len(aRegs) > 1
		QDG->(DbSetorder(1))
		If QDG->(DbSeek(aQDG[oQDG:nAt,POS_AQDGREGS_FILIAL]+aQDG[oQDG:nAt,POS_AQDGREGS_DOCTO]+aQDG[oQDG:nAt,POS_AQDGREGS_RV]+aQDG[oQDG:nAt,POS_AQDGREGS_TIPO]+;
						aQDG[oQDG:nAt,POS_AQDGREGS_FILMAT]+aQDG[oQDG:nAt,POS_AQDGREGS_DEPTO]+aQDG[oQDG:nAt,POS_AQDGREGS_MATRI]+aQDG[oQDG:nAt,POS_AQDGREGS_PASTA]))
			Reclock("QDG",.F.)
			QDG->(DbDelete())
			QDG->(MSUnlock())
			FKCOMMIT()			
			MessageDlg(STR0074 + AllTrim(aQDG[oQDG:nAt,POS_AQDGREGS_NOME]) + CRLF + STR0075,STR0076,2) // "Destinatário - " // "Excluído com Sucesso" // "Exclusão Destinatário"
		EndIf
		QDG->(DbSetOrder(nOrdQDG))
		ADel(aRegs,oQDG:nAt)
		ASize(aRegs,Len(aRegs)-1)
		aQDGRegs[oQDH:nAt]:= AClone(aRegs)
		aQDG:= AClone(aRegs)
		oQDG:SetArray(aQDG)
		oQDG:bLine:= bQDGLine
		oQDG:Refresh()
		aQDH[oQDH:nAt,1]:= AScan(aQDG,{|x| x[1] == .T.}) > 0
		oQDH:SetArray(aQDH)
		oQDH:bLine:= bQDHLine
		oQDH:Refresh() 
	Else
		//Remontar o array de distribuicao - documentos
		QD110ExQDH()
	EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	  ³QD110CfDst  ³ Autor ³ Newton R. Ghiraldelli      ³ Data ³ 23/09/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³Realiza a distribuicao do documento                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³QD110CfDst()                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		  ³ QDOA110                                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD110CfDst()

	Local aData               := {}
	Local aDiretorio          := {}
	Local aQPath              := QDOPATH()
	Local aRegsPst            := {}
	Local cArqTmp             := ""
	Local cFilQAD             := xFilial("QAD")
	Local cMvAviso            := GetMV("MV_QAVIREC")
	Local cMvAvisoR           := GetMV("MV_QAVISOR",.F.,"N") // "Aviso de Recolhimento"
	Local cMvProt             := GetMV("MV_QPROT")
	Local cMvProtRe           := GetMV("MV_QPROTRE",.F.,"N") // "Protocolo de Recolhimento"
	Local cMvQAQuest          := GetMv("MV_QAQUEST",.F.,"N")
	Local cQPath              := aQPath[1] // Diretorio que contem os .CEL
	Local cQPathHtm           := aQPath[5]
	Local cQPathTrm           := aQPath[3]
	Local cSvFilAnt           := cFilAnt
	Local cTexto              := ""
	Local cTextoAux           := STRZERO( VAL( QA_SEQU( "QDH", 6, "N" ) ), 6 ) + SubStr( StrZero( year( dDataBase ), 4 ),3 ,2 ) + ".CEL"
	Local cTextoD             := aQPath[4]
	Local lCpyS2T             := .F.
	Local lImpri              := .T.
	Local lNReceb             := .T.
	Local lPastaIna           := .F.
	Local lQd1Par             := .F.
	Local lQDO110IM           := ExistBlock( "QDO110IM" )
	Local lQDOAP19            := ExistBlock( "QDOAP19" )
	Local lQDOAP26            := Existblock( "QDOAP26" )
	Local lQDOATUVA           := ExistBlock( "QDOATUVA" )
	Local lQdocpUM            := GetMv("MV_QDOCPUM",.F.,"2")=="1" //Define se imprime apenas uma copia do Documento na Distribuicao 1=Sim 2=Nao
	Local lQDODISTOK          := ExistBlock( "QDODISTREOK" )
	Local lQDORP27            := Existblock( "QDORP27" )
	Local lQDORP28            := Existblock( "QDORP28" )
	Local lStatus             := .F.
	Local nC                  := 0
	Local nCopDoc             := 0
	Local nCopias             := 1
	Local nDias               := 0
	Local nDiasT              := GetMV("MV_QDIATR")
	Local nDirHtml            := 0
	Local nPosDir             := 0
	Local nQDGRecno           := 0
	Local nRecPro             := 0
	Local nT                  := 0
	Local oQDODocumentControl := QDODocumentControl():New()

	Private aListID  := {}
	Private aListWD  := {}
	Private cDepRece := ""
	Private cNomRece := ""
	Private lChCopia := .T.
	Private lEditor  := .T.
	Private lFim     := .T.

	If oQDODocumentControl:validaExecucaoViaWebApp()
		//STR0077 - "Execução via WebApp sem WebAgent."
		//STR0078 - "Instale e habilite o WebAgent no computador e tente novamente."
		Help(NIL, NIL, "QDO-NO-WEBAPP", NIL, STR0077, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0078})
		Return
	EndIf

	// Verifica se existe no arquivo QDH o documento selecionado e se este esta em fase de distribuicao 
	// Posiciona o registro do arquivo QDH                                                             
	QDH->(DbSeek(aQDH[oQDH:nAt,POS_AQDH_FILIAL]+aQDH[oQDH:nAt,POS_AQDH_DOCTO]+aQDH[oQDH:nAt,POS_AQDH_RV]))
	QD1->(DbSetOrder(7))
	lQd1Par := 	QDH->QDH_STATUS = "L  " .And.;
			QD1->(DbSeek(QDH->QDH_FILIAL+QDH->QDH_DOCTO+QDH->QDH_RV+cMatDep+cMatFil+cMatCod+"I  "))
	If 	! QDH->(Found()) .Or. (lQd1Par .And. QD1->QD1_PENDEN = "B")
		QD1->(DbSetOrder(1))
		Return .F.
	EndIf

	If  cFilAnt <> QDH->QDH_FILIAL .AND. FWModeAccess("QDH") == "E" //!Empty(AllTrim(xFilial("QDH")))
		cFilAnt		 := QDH->QDH_FILIAL // Mudo a Variavel publica de Memória como na SuperGetMV	
		aQPath       := QDOPATH()
		cQPath       := aQPath[1]	    // Diretorio que contem os .CEL
		cQPathTrm    := aQPath[3]
		cQPathHtm    := aQPath[5]
		cTextoD      := aQPath[4] 		
		cFilAnt      := cSvFilAnt       // Restauro a Variavel publica de Memória como na SuperGetMV
	EndIf

	nCopDoc	:= If(! GetMv("MV_QDOCPCN", .T., .T.) .And. QDH->QDH_CANCEL = "S", 0, 1)  

	// Verifica a existencia do registro de distribuicao no arquivo QD1 e posiciona o registro
	QD1->(DbSetOrder(2))
	If !QD1->(DbSeek(QDH->QDH_FILIAL+QDH->QDH_DOCTO+QDH->QDH_RV+QDH->QDH_STATUS))
		Return .F.
	EndIf

	// Verifica a existencia de Questionario e sua Obrigatoridade para impedir a distribuicao  
	QAG->(DbSetOrder(2))
	IF QDH->QDH_CANCEL == "N" .AND. QDH->QDH_QUEST == "1" .AND. cMvQAQuest == "S"
		If !QAG->(DbSeek(xFILIAL("QAG")+QDH->QDH_DOCTO+QDH->QDH_RV))
			MsgAlert(OemToAnsi(STR0054) , OemToAnsi(STR0027))		
			Return .F.
		EndIf
	ENDIF
                                                          
	DbSelectArea("QDH")
	For nC:= 1 To QDH->(FCount())
		cCampo:= Upper(AllTrim(QDH->(FieldName(nC))))
		M->&cCampo.:= QDH->(FieldGet(nC))
	Next nC

	cTexto:=Alltrim(M->QDH_NOMDOC)

	// Ponto de entrada somente permite distribuir se houver Treinamento, se existe no QAD e se foi concluido
	IF lQDODISTOK .AND. QDH->QDH_TREINA == '1'
		if !ExecBlock( "QDODISTREOK", .f., .f. ,{ QDH->QDH_FILIAL, QDH->QDH_DOCTO, QDH->QDH_RV })
      		Return .F.
		EndIf
	Endif

	// Verifica, emite a mensagem e exclui as Pastas Inativas 
	lPastaIna := .F.
	aEval(aQDGRegs[oQDH:nAt],{|x| IF(x[POS_AQDGREGS_STATUS]=="2",lPastaIna:=.T.,"")})

	IF lPastaIna
		IF MsgYesNo(OemToAnsi(STR0068),OemToAnsi(STR0027)) //"Atenção" //"Existe Pasta Inativa deseja exclui-la do documento ?"
			While lPastaIna
			aRegsPst:= AClone(aQDGRegs[oQDH:nAt])
				For nC:=1 To Len(aRegsPst)
					IF aRegsPst[nC,17]=="2"
						oQDG:nAt:=nC
						QD110ExQDG()
						Exit
					Endif
				Next
				lPastaIna:=.F.
				aEval(aQDGRegs[oQDH:nAt],{|x| IF(x[POS_AQDGREGS_STATUS]=="2",lPastaIna:=.T.,"")})
				IF Len(aQDGRegs) == 0 .Or. Len(aQDG) == 1
					Exit
				EndIf
			Enddo
			IF lPastaIna
				Return .F.
			Endif
		Else
			Return .F.
		Endif
	Endif

	aEval(aQDGRegs[oQDH:nAt],{|x| IF(x[POS_AQDGREGS_TPRCBT] <> "4", lNReceb := .F., "")})
	IF lNReceb
		MsgAlert(OemToAnsi(STR0069),OemToAnsi(STR0027)) // ###"Atenção"  //"Nao Existe(m) destinatarios(s) validos cadastrado(s) para o documento "
		Return .F.
	Endif

	// Monta a tela de datas de vigencia, implantacao e validade
	If !QD110DtVig()
		Return .F.
	EndIf

	nDias := M->QDH_DTVIG - dDatabase
	If nDias > nDiasT .And. nDiasT > 0
		nDiasT:= nDias
	EndIf

	IF M->QDH_DTOIE <> "E" .AND. lQdocpUM
		MsgAlert(OemToAnsi(STR0067),OemToAnsi(STR0027)) // "Será impresso apenas uma (1) copia do documento, conforme o parâmetro MV_QDOCPUM." ###"Atenção" 
	Endif

	If !MsgYesNo(OemToAnsi(STR0028),OemToAnsi(STR0027)) // " Confirma Distribuição do Documento ?" ### "Atenção"
		Return .F.
	EndIf

	M->QDH_STATUS:= "L  "

	// Procura a existencia de destinatarios no arquivo QDH e posiciona o primeiro registro
	QDG->(DbSetOrder(6))
	If !QDG->(DbSeek(QDH->QDH_FILIAL+QDH->QDH_DOCTO+QDH->QDH_RV))
		Return .F.
	EndIf

	// Verifica se dois usuarios nao estao tentando executar a baixa do documento ao mesmo tempo e bloqueia um deles 
	QDH->(DbSeek(aQDH[oQDH:nAt,POS_AQDH_FILIAL]+aQDH[oQDH:nAt,POS_AQDH_DOCTO]+aQDH[oQDH:nAt,POS_AQDH_RV]))
	If (QDH->QDH_STATUS == "L  " .And. ! lQd1Par ) .AND. !SoftLock("QDH")
		MsgAlert(OemToAnsi(STR0041),OemToAnsi(STR0027)) // "Outro usuário já  está  realizando esta operação" ### "Atenção" 
		Return .F.
	EndIf

	Begin Transaction

		IF lQDOATUVA
			ExecBlock( "QDOATUVA", .f., .f. ,{ M->QDH_DOCTO, M->QDH_RV })
		Endif

		// Faz a gravacao dos dados nas bases de dados 
		MsgRun(OemToAnsi(STR0042),OemToAnsi(STR0003),{|| QD110GrDst(nDiasT, lQd1Par)}) // "Atualizando Distribuições" ### "Aguarde..."

		If M->QDH_DTOIE <> "E"
			//Atualiza os ultimos campos do Doc, Salva e Finaliza secao Word 
				ProcessaDoc( { || QdoDocRUsr( lEditor, .T. , ,.T.,, nCopDoc,@lCpyS2T,.F.) } )

			If File(cQPathTrm+cTexto)
				If lCpyS2T
					oQDODocumentControl:copiaProtegidaArquivo(cQPathTrm+cTexto,cQPath+cTexto)
					// Copia o Documento em Html para o Servidor  
					cArqTmp := Left(AllTrim(M->QDH_NOMDOC),Len(AllTrim(M->QDH_NOMDOC))-3)+"HTM"
					If File(cQPathTrm+cArqTmp)
						oQDODocumentControl:copiaProtegidaArquivo(cQPathTrm+cArqTmp,cQPathHtm+cArqTmp)
						aDiretorio:= QDocDirc(cQpathTrm,"D") // DIRECTORY
						If Len(aDiretorio) > 0
							nPosDir:= ASCAN(aDiretorio,{|X| Substr(AllTrim(M->QDH_NOMDOC),1,8)+"_" $ X[1] })
							If nPosDir > 0
								If (nDirHtml:= MakeDir(cQPathHtm+aDiretorio[nPosDir,1])) == 0
									aData  := QDocDirc(cQPathTrm+aDiretorio[nPosDir,1]) // DIRECTORY							
									For nT:= 1 to Len(aData)
										If File(cQPathTrm+aDiretorio[nPosDir,1]+"\"+AllTrim(aData[nT,1]))
											oQDODocumentControl:copiaProtegidaArquivo(cQPathTrm+aDiretorio[nPosDir,1]+"\"+AllTrim(aData[nT,1]), cQPathHtm+aDiretorio[nPosDir,1]+"\"+AllTrim(aData[nT,1]))
										Endif
									Next nT
								EndIf
							EndIf
						EndIf
						If File(cQPathTrm+cArqTmp)
							QDRemDirHtm(cArqTmp) // Remove Arquivos Html
						EndIf
					EndIf
				EndIf
				FErase(cQPathTrm+cTexto)
			EndIf

			lImpri := .T.
			// Ponto de Entrada antes da impressao do Documento 
			If lQDO110IM
				If ValType( lImpri := ExecBlock( "QDO110IM", .F., .F., { lImpri } ) ) <> "L"
					lImpri := .T. // Por default Imprime
				EndIf
			EndIf
			
		//Faz a impressao das copias distribuidas em papel
		QDG->(DbSetOrder(1))	
		QDG->(DbSeek(M->QDH_FILIAL+M->QDH_DOCTO+M->QDH_RV))
			While QDG->(!Eof()) .And. QDG->QDG_FILIAL+QDG->QDG_DOCTO+QDG->QDG_RV == M->QDH_FILIAL+M->QDH_DOCTO+M->QDH_RV
				If QDG->QDG_SIT == "I"
				QDG->(DbSkip())
				Loop
				EndIf
				If QDG->QDG_RECEB == "S" .And. QDG->QDG_TPRCBT $ "2,3"
					nQDGRecno:= QDG->(RecNo())
					cFilQDG  := QDG->QDG_FILMAT
					cMatQDG  := QDG->QDG_MAT
					cDepQDG  := QDG->QDG_DEPTO
					If nCopDoc = 0
						nCopias := 0
					Else
						IF lQdocpUM   //Imprime Apenas uma Copia do Doc
							nCopias := 1 
						Else
							nCopias := If(QDG->QDG_NCOP > 0,QDG->QDG_NCOP,1)
						Endif
					Endif
					If !lImpri
						nCopias := 0
					EndIf
					If FWModeAccess("QAD") == "E" //!Empty(xFilial("QAD"))
						cFilQAD:= QDG->QDG_FILMAT
					EndIf
					If QDG->QDG_TIPO == "P"
						If QAD->(DbSeek(cFilQAD+QDG->QDG_DEPTO))
							cFilQDG:= QAD->QAD_FILMAT
							cMatQDG:= QAD->QAD_MAT
						EndIf
					EndIf
					QAA->(DbSetOrder(1))
					If QAA->(DbSeek(cFilQDG+cMatQDG) )
						If QA_SitFolh()
							cNomRece:= QAA->QAA_NOME
							cDepRece:= QAA->QAA_CC
							QAD->(DbSeek(cFilQAD+QDG->QDG_DEPTO))
							If QDG->QDG_TIPO == "P"
								cNomRece:= Alltrim(QDG->QDG_CODMAN)+" - "+QDXFNANMAN(QDG->QDG_CODMAN,.T.)+chr(13)+STR0064+QAA->QAA_NOME //"Responsavel: "
							EndIf
								ProcessaDoc({|| QdoDocRUsr(lEditor,.T.,cNomRece,,,nCopias,@lCpyS2T,.F.)})
							lEditor:= .F.   
							IF lQdocpUM
								Exit
							Endif
						EndIf
					EndIf
				QDG->(DbGoTo(nQDGRecno))
				EndIf
			QDG->(DbSkip())	
			EndDo
		Else
			MsgInfo(OemToAnsi(STR0043),OemToAnsi(STR0004)) // "Por este Documento ser de autoria Externa, nao serao impressas as copias do tipo papel" ### "Distribuicao"
		EndIf

		If !lEditor
			ProcessaDoc({|| QdoDocRUsr(.F.,lFim,,,, nCopDoc,@lCpyS2T,.F.)})
		EndIf

		// Numero da Revisao Anterior 
		cRvAnt:= STRZERO(VAL(LEFT(M->QDH_RV,3))-1,3)

		// Grava Pendencia de Devolucao da Revisao Anterior(Copia Papel)
		QDG->(DbSetOrder(1))	
		If QDG->(DbSeek(M->QDH_FILIAL+M->QDH_DOCTO+cRvAnt))
			While QDG->(!Eof()) .And. QDG->QDG_FILIAL+QDG->QDG_DOCTO+QDG->QDG_RV == M->QDH_FILIAL+M->QDH_DOCTO+cRvAnt
				If QDG->QDG_SIT == "I"
				QDG->(DbSkip())
				Loop
				EndIf
				If QDG->QDG_RECEB == "S" .And. QDG->QDG_TPRCBT $ "2,3"
				QD110GrDev(QDG->QDG_FILMAT,QDG->QDG_MAT,QDG->QDG_DEPTO,M->QDH_DOCTO,cRvAnt,QDG->QDG_NCOP)
				EndIf

				// Ponto de Entrada que Grava Pendencia de Devolucao da Revisao Anterior Outras (Copias)                                         
				IF lQDOAP26
					If QDG->QDG_RECEB == "S" .And. QDG->QDG_TPRCBT $ EXECBLOCK("QDOAP26",.F.,.F.,{QDG->QDG_FILMAT,QDG->QDG_MAT})
					QD110GrDev(QDG->QDG_FILMAT,QDG->QDG_MAT,QDG->QDG_DEPTO,M->QDH_DOCTO,M->QDH_RV,QDG->QDG_NCOP)		
					ENDIF
				Endif
			QDG->(DbSkip())
			EndDo
		EndIf

		//Imprime os protocolos referentes a distribuicao
		If M->QDH_DTOIE == "I"
			If cMvProt == "S"
				If QD110ImpP(M->QDH_FILIAL,M->QDH_DOCTO,M->QDH_RV) // Verifica se ha dados a serem impressos.
					IF lQDORP27
					EXECBLOCK('QDORP27',.F.,.F.)	    	
					ELSE
					QDOR060(.T.) // Protocolo de Recebimento				
					ENDIF
				EndIf
			EndIf
			If cMvProtRe == "S"
				If QDH->(DbSeek(M->QDH_FILIAL+M->QDH_DOCTO+cRvAnt))
					If QD110ImpP(M->QDH_FILIAL,M->QDH_DOCTO,cRvAnt) // Verifica se ha dados a serem impressos.
						IF lQDORP28
						EXECBLOCK('QDORP28',.F.,.F.,{M->QDH_DOCTO,M->QDH_RV})	    	
						ELSE
						QDOR063(.t.,M->QDH_DOCTO,M->QDH_RV) // Protocolo de Recolhimento
						ENDIF
						
					EndIf
				EndIf
			EndIf
		Elseif M->QDH_DTOIE == "E"
			If cMvAviso == "S"
				If QD110ImpP(M->QDH_FILIAL,M->QDH_DOCTO,M->QDH_RV) // Verifica se ha dados a serem impressos.
				QDOR061(.t.) // Aviso de Recebimento
				EndIf
			EndIf
			If cMvAvisoR == "S"
				If QDH->(DbSeek(M->QDH_FILIAL+M->QDH_DOCTO+cRvAnt))
					If QD110ImpP(M->QDH_FILIAL,M->QDH_DOCTO,cRvAnt) // Verifica se ha dados a serem impressos.
					QDOR064(.t.,M->QDH_DOCTO,M->QDH_RV) // Aviso de Recolhimento
					EndIf
				EndIf
			EndIf
		EndIf

		If File(cQPathTrm+cTextoD)
		FErase(cQPathTrm+cTextoD)
		EndIf

		If lQDOAP19
		ExecBlock("QDOAP19",.F.,.F.,{M->QDH_DOCTO,M->QDH_RV})
		EndIf

		// Na Integracao com o QMT verificar se  o procedimento foi preenchido.
		DBSelectArea("QA5")
		DBSetOrder(1)
		DBGoTop() // Foi optado por nao usar um indice na QA5 por Documento
		// Procuro pelo Documento nos Procedimentos de Utilizacao e Medicao 
		While QA5->(!EOF())
			// Se o Procedimento tiver  como anexo o  documento que  esta  sendo  alterado,       
			// devo analisar o  procedimento  verificando se este  esta  apto, ou seja, e a ulti- 
			// ma revisao  vigente  do procedimento e existe  calibração para um  instrumento     
			// com este procedimento.                                                             
			If QA5->QA5_DOCTO == M->QDH_DOCTO  .AND. QMT050RevAp(QA5->QA5_NORMA, QA5->QA5_REVPRO, QA5->QA5_CODTAB,M->QDH_DOCTO,M->QDH_RV)
			nRecPro := Recno()
			QMT050NRD() 
			DbGoTo(nRecPro)
			EndIf
		QA5->(DBSkip())
		End


		dbSelectArea("QD1")
		Set Filter To

		If !lStatus
			If M->QDH_STATUS $ "L  |I  "
				If File(cQPathTrm+cTextoAux)
				fErase(cQPathTrm+cTextoAux)		
				EndIf
			Endif
		EndIf
	End Transaction

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	  ³QD110GrDst  ³ Autor ³ Newton R. Ghiraldelli      ³ Data ³ 23/09/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³ Realiza a gravacao da distribuicao do documento                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³ QD110GrDst(ExpN1)                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ ExpN1 - Dias de Validade do Documento                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		  ³ QDOA110                                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD110GrDst(nDiasT, lQd1Par)
Local aData               := {}
Local aDiretorio          := {}
Local aQPath              := QDOPATH()
Local aSavQD1             := {}
Local aSavQDH             := {}
Local aTPPEND             := {}
Local aUsrMat             := QA_USUARIO()
Local bCampo              :={|nCPO| Field( nCPO ) }
Local cArqTmp             := ""
Local cChaveQDH           := ""
Local cDepQDG             := TamSx3("QDG_DEPTO")[1]
Local cDescr              := ""
Local cFilQa              := If(FWModeAccess("QAD")=="C",xFilial("QAD"), QDH->QDH_FILDEP)
Local cFilQAD             := xFilial("QAD")
Local cFilQDG             := Space(FWSizeFilial()) //Space(02)
Local cHora               := ""
Local cMatCod             := aUsrMat[3]
Local cMatDep             := aUsrMat[4]
Local cMatFil             := aUsrMat[2]
Local cMatQDG             := TamSx3("QDG_MAT")[1]
Local cQPath              := aQPath[1] // Diretorio que contem os .CEL
Local cQPathHtm           := aQPath[5]
Local cQPathTrm           := aQPath[3]
Local cRv                 := ""
Local cUltRv              := ""
Local lCPYS2T             := .F.
Local lEmailCC            := GetMv("MV_QDOEMCC",.F.,"2")=="1" //Define se na distribuicao envia um e-mail de pendencia de leitura com copia para todos os Destinatarios 1=SIM; 2=NAO
Local lFutura             := .F.
Local lGrava              := .T.
Local lQD110PEN           := Existblock( 'QD110PEN' )
Local nC                  := 1
Local nDiasF              := GetMV("MV_QDIATR")
Local nH                  := 0
Local nOpc                := 4
Local nOrdQAA             := QAA->(IndexOrd())
Local nPosDir             := 0
Local nQDGRecno           := 0
Local nQDHRecno           := 0
Local nT                  := 0
Local oQDODocumentControl := QDODocumentControl():New()

Private aUsrMail := {}

//Realiza a baixa do documento gravando as atualizações nos arquivo QDH, QD1 e QDG
Begin Transaction
	//Atualizado o QD1 quando for distribuicao conforme QDZ e QAA
	QD50DSTATU(cFilQA,nOpc,nOrdQAA)

	nQdhRecno := QDH->(Recno())
	RecLock("QDH",.F.)
		QDH->QDH_STATUS:= M->QDH_STATUS
		QDH->QDH_DTVIG := M->QDH_DTVIG
		QDH->QDH_DTLIM := M->QDH_DTLIM
		QDH->QDH_DTIMPL:= M->QDH_DTIMPL
	QDH->(MsUnlock())
	FKCOMMIT()
	QDG->(DbSetOrder(1))
	QDG->(DbSeek(QDH->QDH_FILIAL+QDH->QDH_DOCTO+QDH->QDH_RV))
		While !lQd1Par .And. QDG->(!Eof()) .And.;
			QDG->QDG_FILIAL+QDG->QDG_DOCTO+QDG->QDG_RV == QDH->QDH_FILIAL+QDH->QDH_DOCTO+QDH->QDH_RV
			If QDG->QDG_SIT == "I"
				QDG->(DbSkip())
				Loop
			EndIf
			If QDG->QDG_RECEB == "S" .And. QDG->QDG_TPRCBT <> "4"
				nQDGRecno:= QDG->(RecNo())
				cFilQDG  := QDG->QDG_FILMAT
				cMatQDG  := QDG->QDG_MAT
				cDepQDG  := QDG->QDG_DEPTO
				nCopias  := If(QDG->QDG_NCOP > 0,QDG->QDG_NCOP,1)
				lGrava	 := .T.
				If QDG->QDG_TIPO == "P"
					If FWModeAccess("QAD") == "E" ////!Empty(xFilial("QAD"))
						cFilQAD := QDG->QDG_FILMAT
					EndIf
					If QAD->(DbSeek(cFilQAD+QDG->QDG_DEPTO))
						cFilQDG	:= QAD->QAD_FILMAT
						cMatQDG	:= QAD->QAD_MAT
					EndIf
				EndIf
				QAA->(DbSetOrder(1))
				If QAA->(DbSeek(cFilQDG+cMatQDG)) .And. QA_SitFolh()
					//Condicao criada para NAO gerar erro de gravacao no QD1 chave unica utilizando o campo HRGERA (HORA)				
					cHora := SubStr(Time(),1,5)
					QD1->(DbSetOrder(1))			    
					IF QD1->(DbSeek(QDG->QDG_FILIAL+QDG->QDG_DOCTO+QDG->QDG_RV+cDepQDG+cFilQDG+cMatQDG+DTOS(dDataBase)+"L  "))
						While !QD1->(Eof()) .AND. QDG->QDG_FILIAL+QDG->QDG_DOCTO+QDG->QDG_RV+cDepQDG+cFilQDG+cMatQDG+DTOS(dDataBase)+"L  "==;
	    					   QD1->QD1_FILIAL+QD1->QD1_DOCTO+QD1->QD1_RV+QD1->QD1_DEPTO+QD1->QD1_FILMAT+QD1->QD1_MAT+DTOS(QD1->QD1_DTGERA)+QD1->QD1_TPPEND
							If QDG->QDG_TIPO == "D" .And. QD1->QD1_PENDEN == "P" // Destinatario
								lGrava := .F. // Se exister QD1 pendente não permite a duplicação
							ElseIf QD1->QD1_HRGERA > cHora
								cHora:= QD1->QD1_HRGERA
							EndIf
							QD1->(DbSkip())
						EndDo
						If cHora >= SubStr(Time(),1,5) .And. lGrava
							cHora:=QSomaH(cHora) //Soma um minuto					
						EndIf
					EndIf
			
					If lGrava
						RecLock("QD1",.T.)
							QD1->QD1_FILIAL := M->QDH_FILIAL
							QD1->QD1_DOCTO  := M->QDH_DOCTO 
							QD1->QD1_RV     := M->QDH_RV
							QD1->QD1_TPPEND := M->QDH_STATUS
							QD1->QD1_FMATBX := cMatFil
							QD1->QD1_MATBX  := cMatCod
							QD1->QD1_DEPBX  := cMatDep
							QD1->QD1_FILMAT := cFilQDG
							QD1->QD1_MAT    := cMatQDG
							QD1->QD1_DEPTO  := cDepQDG
							QD1->QD1_DISTNE := "N"
							If QDH->QDH_CANCEL == "S"
								cDescr:= "C" // "Cancelamento"
								QD1->QD1_PENDEN := "B"     
								QD1->QD1_LEUDOC := "S"
								QD1->QD1_DTBAIX := dDataBase     
							Else
								If QDG->QDG_TIPO == "D"
									If QDG->QDG_TPRCBT == "2"
										QD1->QD1_PENDEN := "B"     
										QD1->QD1_LEUDOC := "S"
										QD1->QD1_DTBAIX := dDataBase     						
									Else
										QD1->QD1_PENDEN := "P"     
										QD1->QD1_LEUDOC := "N"
										QD1->QD1_DTBAIX := CTOD("  /  /  ","DDMMYY")
									Endif
								Else
									QD1->QD1_PENDEN := "B"     
									QD1->QD1_LEUDOC := "S"
									QD1->QD1_DTBAIX := dDataBase     						
								EndIf
							EndIf
							QD1->QD1_HRGERA := cHora
							QD1->QD1_DTGERA := dDataBase        			 
							QD1->QD1_CHAVE  := M->QDH_CHAVE
							QD1->QD1_CARGO  := QAA->QAA_CODFUN
							QD1->QD1_TPDIST := QDG->QDG_TPRCBT 
						QD1->(MsUnlock())
						FKCOMMIT()
						//Grava Aviso de Cancelamento de Documento
						If cDescr == "C" // Distribuicao de Docto Cancelamento
							QDS->(DbSetOrder(1))
							If !QDS->(DbSeek(QAA->QAA_FILIAL+QAA->QAA_MAT+"P"+"CAN"+QD1->QD1_DOCTO+QD1->QD1_RV))
								QDXGvAviso("CAN",QAA->QAA_FILIAL,QAA->QAA_MAT,QAA->QAA_CC,QD1->QD1_DOCTO,QD1->QD1_RV,,QD1->QD1_FILIAL)
							Endif
						EndIf
					
						If lQD110PEN
							Execblock('QD110PEN',.F.,.F.) // Ponto de Entrada para efetuar tratamento na tabela de pendencias antes do envio do e-mail 	    	
						Endif
	
						//Executa a emissão dos emails					
						If (!Empty(QAA->QAA_EMAIL) .and. QAA->QAA_RECMAI == "1") .and. (QD1->QD1_PENDEN == "P" .Or. cDescr == "C") .and. (QD1->QD1_TPPEND == "L  ")
							IF lEmailCC
								//Executa a emissão um email com todos os destinatários
								IF Len(aUsrMail) == 0
									fQdoTpMail(@aUsrMail,QD1->QD1_DOCTO,QD1->QD1_RV,M->QDH_TITULO,QAA->QAA_EMAIL,M->QDH_STATUS,M->QDH_FILMAT,QAA->QAA_APELID,"","",cDescr,,M->QDH_CODTP,M->QDH_DTVIG)
								Else
									aUsrMail[1,2]+=","+Alltrim(QAA->QAA_EMAIL)
								Endif
							Else
							//Executa a emissão dos emails com um destinatário						   						
							fQdoTpMail(@aUsrMail,QD1->QD1_DOCTO,QD1->QD1_RV,M->QDH_TITULO,QAA->QAA_EMAIL,M->QDH_STATUS,M->QDH_FILMAT,QAA->QAA_APELID,"","",cDescr,,M->QDH_CODTP,M->QDH_DTVIG)										
							Endif
						EndIf
					
						If QDG->QDG_TIPO == "D"
							QD110GrLog( .t., STR0029, "U", QDG->QDG_NCOP, cMatFil, cMatCod, QDG->QDG_FILMAT, QDG->QDG_MAT, QDG->QDG_TPRCBT ) // "Distribui‡„o por Usuario"
						Else
							QD110GrLog( .t., STR0030, "P", 1, cMatFil, cMatCod, QAA->QAA_FILIAL, QAA->QAA_MAT, QDG->QDG_TPRCBT ) // "Distribui‡„o por Pastas"
						EndIf
					EndIf
				Else
				Reclock("QDG",.F.)
					QDG->(DbDelete())
					QDG->(MSUnlock())
				FKCOMMIT()
				EndIf
				QDG->(DbGoTo(nQDGRecno))
			EndIf
			QDG->(DbSkip())	
		EndDo
		QDJ->(DbSetOrder(1))
		If QDJ->(DbSeek(QDH->QDH_FILIAL+QDH->QDH_DOCTO+QDH->QDH_RV))
			While QDJ->(!Eof()) .And. QDJ->QDJ_FILIAL+QDJ->QDJ_DOCTO+QDJ->QDJ_RV == QDH->QDH_FILIAL+QDH->QDH_DOCTO+QDH->QDH_RV
				If !QDG->(DbSeek(QDJ->QDJ_FILIAL+QDJ->QDJ_DOCTO+QDJ->QDJ_RV+QDJ->QDJ_TIPO+QDJ->QDJ_FILMAT+QDJ->QDJ_DEPTO))
					Reclock("QDJ",.F.)
						QDJ->(DbDelete())
						QDJ->(MSUnlock())   
					FKCOMMIT()
				EndIf
				QDJ->(DbSkip())			
			EndDo
		EndIf
		QDH->(DbSetOrder(1))
		Aadd(aTPPEND,{QDH->QDH_FILIAL+QDH->QDH_DOCTO+QDH->QDH_RV,"I  "})
		cRv   := QDH->QDH_RV
		cUltRv:= ""
		//Guarda as variaveis do Documento atual
		DbSelectArea("QDH")
		For nH := 1 To FCount()
			aAdd(aSavQDH,{Eval(bCampo,nH),M->&(Eval(bCampo,nH))})
		Next nH
		//Grava - quando a distribuicao for de nova revisao de documento - a nova data de validade da revisao anterior
		cChaveQDH	:= QDH->QDH_FILIAL+QDH->QDH_DOCTO
		lFutura  	:= .F.
		If QDH->(DbSeek(QDH->QDH_FILIAL+QDH->QDH_DOCTO))
			While !Eof() .And. QDH->QDH_FILIAL + QDH->QDH_DOCTO == cChaveQDH
				If QDH->QDH_RV <> cRv
					If QDH->QDH_OBSOL <> "S"
						If !lQd1Par
							RecLock("QDH",.F.)
								If M->QDH_DTVIG > dDataBase .And. M->QDH_CANCEL <> "S"
									QDH->QDH_OBSOL := "S"							
								Else
									QDH->QDH_OBSOL := "S"
								Endif
								If lFutura
									QDH->QDH_DTLIM := If(nDiasF == 0, M->QDH_DTVIG-1, M->QDH_DTVIG + nDiasF)
								Else
									QDH->QDH_DTLIM := If(nDiasT == 0, M->QDH_DTVIG-1, M->QDH_DTVIG + nDiasT)
								EndIf
							QDH->(MsUnlock())	
							FKCOMMIT()
						Endif
						//Restaura as variaveis de memoria do documento atual
						For nH := 1 To Len(aSavQDH)
							M->&(aSavQDH[nH,1]) := aSavQDH[nH,2]
						Next
						//Atualiza os ultimos campos do Doc, Salva e Finaliza secao Word
						If M->QDH_DTOIE <> "E"
							ProcessaDoc( { || QdoDocRUsr( .T. , .T. , ,.T.,.T.,,@lCpyS2T,.F.) } )
							If File(cQPathTrm+AllTrim(M->QDH_NOMDOC))
								If lCpyS2T
									oQDODocumentControl:copiaProtegidaArquivo(cQPathTrm+AllTrim(M->QDH_NOMDOC), cQPath+AllTrim(M->QDH_NOMDOC))
									//Copia o Documento Html para o Servidor	
									cArqTmp := Left(AllTrim(M->QDH_NOMDOC),Len(AllTrim(M->QDH_NOMDOC))-3)+"HTM"
									If File(cQPathTrm+cArqTmp)
									    oQDODocumentControl:copiaProtegidaArquivo(cQPathTrm+cArqTmp, cQPathHtm+cArqTmp)
		      							aDiretorio:= QDocDirc(cQpathTrm,"D") //DIRECTORY
										If Len(aDiretorio) > 0
											nPosDir:= ASCAN(aDiretorio,{|X| Substr(AllTrim(M->QDH_NOMDOC),1,8)+"_" $ X[1] })
											If nPosDir > 0
												MakeDir(cQPathHtm+aDiretorio[nPosDir,1])
												aData  := QDocDirc(cQPathTrm+aDiretorio[nPosDir,1]) //DIRECTORY											
												For nT:= 1 to Len(aData)
													If File(cQPathTrm+aDiretorio[nPosDir,1]+"\"+AllTrim(aData[nT,1]))
														oQDODocumentControl:copiaProtegidaArquivo(cQPathTrm+aDiretorio[nPosDir,1]+"\"+AllTrim(aData[nT,1]), cQPathHtm+aDiretorio[nPosDir,1]+"\"+AllTrim(aData[nT,1]))
													Endif
												Next
											EndIf
										EndIf
										If File(cQPathTrm+cArqTmp)
											QDRemDirHtm(cArqTmp) // Remove Arquivos Html
										EndIf
									EndIf
								EndIf
								FErase(cQPathTrm+AllTrim(M->QDH_NOMDOC))
								lCpyS2T := .F.
							Endif
						EndIf
					EndIf
					Aadd(aTPPEND,{QDH->QDH_FILIAL+QDH->QDH_DOCTO+QDH->QDH_RV,"L  "})
				EndIf
			
				DbSelectArea("QDH")
				QDH->(DbSkip())
			EndDo
		EndIf
	
	aSavQD1 := QD1->(GetArea())
	
	//Baixa todas as pendencias de Leitura e alguns Avisos existentes das revisoes anteriores
	QD1->(DbSetOrder(2))
	For nC := 1 To Len(aTPPEND)
		QD1->(DbSeek(aTPPEND[nC,1]+aTPPEND[nC,2]))
		While !QD1->(Eof()) .And. QD1->QD1_FILIAL+QD1->QD1_DOCTO+QD1->QD1_RV+QD1->QD1_TPPEND == aTPPEND[nC,1]+aTPPEND[nC,2]
			If 	QD1->QD1_TPPEND == aTPPEND[nC,2] .And. QD1->QD1_PENDEN == "P"
				RecLock("QD1",.F.)
					QD1->QD1_PENDEN := "B"
					QD1->QD1_DTBAIX := dDataBase
					QD1->QD1_HRBAIX := SubStr( Time(), 1, 5 )
					QD1->QD1_FMATBX := cMatFil
					QD1->QD1_MATBX  := cMatCod
					QD1->QD1_DEPBX  := cMatDep
					QD1->QD1_DISTNE := "N"
				QD1->(MsUnlock())
				FKCOMMIT()
			EndIf
			QD1->(DbSkip())
		EndDo
	
		IF Right(aTPPEND[nC,1],3) <> cRv //Dif da REVISAO ATUAL
			
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Baixa o Avisos de Documento Vencido VEN    					   ³
		//³		de Inclusao de Treinamento da Revisao Anterior TRE		   ³
		//³		de Agendado Treinamento para este Documento TI  		   ³
		//³		de Inclusao de Questionario da Revisao Anterior QUE		   ³
		//³		de Existe solicitacao de Alteracao para este Documento SAD ³
		//³Baixa o Aviso de Referencia Anterior       					   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		QDS->(DbSetOrder(2))
			If QDS->(DbSeek(aTPPEND[nC,1]))
				While QDS->(!Eof()) .And. QDS->QDS_FILIAL+QDS->QDS_DOCTO+QDS->QDS_RV == aTPPEND[nC,1]
										
					IF ALLTRIM(QDS->QDS_TPPEND)$"VEN.TRE.QUE.SAD.TI" .OR. (M->QDH_CANCEL == "S" .AND. ALLTRIM(QDS->QDS_TPPEND)=="REF")
						If QDS->QDS_PENDEN == "P"
						RecLock("QDS",.F.)
							QDS->QDS_PENDEN := "B"
							QDS->QDS_DTBAIX:= dDataBase
							QDS->QDS_HRBAIX:= SubStr(Time(),1,5)
							QDS->QDS_FMATBX := cMatFil
							QDS->QDS_MATBX  := cMatCod
							QDS->QDS_DEPBX  := cMatDep
						QDS->(MsUnlock())
						FKCOMMIT()
						EndIf
					Endif
					QDS->(DbSkip())
				EndDo
			EndIf
		Endif
	Next nC
	//Restaura as variaveis de memoria do documento atual
	For nH := 1 To Len(aSavQDH)
		M->&(aSavQDH[nH,1]) := aSavQDH[nH,2]
	Next
	//Remontar o array de distribuicao - documentos
	QD110ExQDH()   
	//Se a revisao for de cancelamento, grava o status de cancelado em todas as revisoes anteriores
	QDH->(DbSetOrder(1))
	If M->QDH_CANCEL == "S"
		If QDH->(Dbseek(M->QDH_FILIAL+M->QDH_DOCTO))
			While QDH->(!Eof()) .And. QDH->QDH_FILIAL+QDH->QDH_DOCTO == M->QDH_FILIAL+M->QDH_DOCTO
				RecLock("QDH",.F.)
					QDH->QDH_CANCEL:= "S"
				QDH->(MsUnlock())
				FKCOMMIT()
				QDH->(DbSkip())
			EndDo
		EndIf
		QD1->(DbSetOrder(7))
		If QD1->(DbSeek(M->QDH_FILIAL+M->QDH_DOCTO+M->QDH_RV+cMatDep+cMatFil+cMatCod+"I"))
			RecLock("QD1",.F.)
				QD1->QD1_LEUDOC := "S"
			QD1->(MsUnlock())
			FKCOMMIT()
		EndIf
	EndIf

	If lFutura .And. M->QDH_DTVIG > dDataBase
		QDH->(DbGoto(nQdhRecno))
			QDH->(RecLock("QDH", .F.))
			QDH->QDH_FUTURA := "G"
		QDH->(MsUnLock())
		FKCOMMIT()
	Endif
	
	QD1->(RestArea(aSavQD1))
	
End Transaction

If Len(aUsrMail) <> 0
	QaEnvMail(aUsrMail,,,,aUsrMat[5],"2")
EndIf

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	  ³QD110GrLog  ³ Autor ³ Newton R. Ghiraldelli      ³ Data ³ 23/09/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³ Grava em arquivo um Log de distribuicao de documentos             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³QD110GrLog(EcpL1,ExpC1,ExpC2,ExpN1,ExpC3,ExpC4,ExpC5,ExpC5,ExpC7)  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ ExpL1 - Distribuicao S/N                                          ³±±
±±³           ³ ExpC1 - Motivo                                                    ³±±
±±³           ³ ExpC2 - Tipo de distribuicao                                      ³±±
±±³           ³ ExpN1 - Numero de Copias                                          ³±±
±±³           ³ ExpC3 - Filial do distribuidor/solicitante                        ³±±
±±³           ³ ExpC4 - Matricula do distribuidor/solicitante                     ³±±
±±³           ³ ExpC5 - Filial do destinatario                                    ³±±
±±³           ³ ExpC6 - Matricula do destinatario                                 ³±±
±±³           ³ ExpC7 - Tipo de recebimento                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		  ³ QDOA110                                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD110GrLog(lDistr,cMotLog,cTpDist,nCopias,cFilSol,cMatSol,cFilDes,cMatDes,cTpRcbt)

Local cCodSeq:= StrZero(Val(QA_SEQU(QDH->QDH_DOCTO+QDH->QDH_RV+"LOG",6,"N")),6) 

QDE->(DbSetOrder(1))
	If !QDE->(DbSeek(QDH->QDH_FILIAL+QDH->QDH_DOCTO+QDH->QDH_RV+cCodSeq))
	RecLock("QDE",.T.)
	QDE->QDE_FILIAL := QDH->QDH_FILIAL
	QDE->QDE_DOCTO  := QDH->QDH_DOCTO
	QDE->QDE_RV     := QDH->QDH_RV
	QDE->QDE_SEQ    := cCodSeq
	QDE->QDE_CONTR  := If( lDistr, "S", "N" )
	QDE->QDE_DATA   := dDataBase
	QDE->QDE_MOTIVO := cMotLog
	QDE->QDE_NCOP   := nCopias
	QDE->QDE_OBSOL  := QDH->QDH_OBSOL
	QDE->QDE_TPDIST := cTpDist
	QDE->QDE_FILSOL := cFilSol
	QDE->QDE_MATSOL := cMatSol
	QDE->QDE_FILDES := cFilDes
	QDE->QDE_MATDES := cMatDes
	QDE->QDE_TPRCBT := cTpRcbt
	QDE->(MsUnlock())
	FKCOMMIT()
	EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	  ³QD110DtVig  ³ Autor ³ Newton R. Ghiraldelli      ³ Data ³ 23/09/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³ Monta a tela de data de distribuicao, vigencia e validade         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³ QD110DtVig()                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		  ³ QDOA110                                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD110DtVig()

Local aParam      := {}
Local aPermiss    := {}
Local cConsDtImpl := GetMv("MV_QDHDTIM",.f.,"2") // Habilita Calculo a partir da data de Implantacao 1=Sim / 2=Nao  
Local dDtImpl     := If(QDH->QDH_STATUS <> "L ", dDatabase, QDH->QDH_DTIMPL)
Local dDtLimi     := If(QDH->QDH_STATUS <> "L ", CToD( " / / ","DDMMYY" ), QDH->QDH_DTLIM)
Local dDtVig      := If(QDH->QDH_STATUS <> "L ", dDatabase, QDH->QDH_DTVIG)
Local nOpc1       := 0
Local nQtdDias    := 1
Local oDlg        := Nil
Local oDtImpl     := Nil
Local oDtLim      := Nil
Local oDtVig      := Nil
Local oPanel      := Nil
Local oQtdDias    := Nil
 	    
QD2->(DbSeek(xFilial("QD2")+QDH->QDH_CODTP))
If (nQtdDias:= QD2->QD2_QDIASV) > 0
	dDtLimi := (dDtImpl+QD2->QD2_QDIASV)
EndIf

DEFINE MSDIALOG oDlg FROM 000,000 TO 300,405 TITLE OemToAnsi(STR0031) PIXEL // "Distribuição"

oPanel:= tPanel():New(23,37,,oDlg,,.T.,,,,140,110)

@ 010,015 TO 140,190 OF oDlg PIXEL 

@ 010,025 SAY OemToAnsi(STR0032) SIZE 70,10 OF oPanel PIXEL // "Dt Vigência"
@ 025,025 SAY OemToAnsi(STR0033) SIZE 70,10 OF oPanel PIXEL // "Dt Implantação"
@ 040,025 SAY OemToAnsi(STR0034) SIZE 70,10 OF oPanel PIXEL // "Dias Validade"
@ 055,025 SAY OemToAnsi(STR0035) SIZE 70,10 OF oPanel PIXEL // "Dt Validade"

@ 010,070 	MSGET oDtVig VAR dDtVig PICTURE "@D" SIZE 043,008 OF oPanel PIXEL;
			WHEN QDH->QDH_STATUS <> "L  "

@ 025,070 	MSGET oDtImpl VAR dDtImpl	PICTURE "@D" SIZE 043,008 OF oPanel PIXEL;
			VALID dDtImpl <= dDtVig WHEN QDH->QDH_STATUS <> "L  "

@ 040,070 	MSGET oQtdDias VAR nQtdDias PICTURE "9999" SIZE 027,008 OF oPanel PIXEL;
           	VALID If(nQtdDias >= 0,;
           	(dDtLimi:= If(nQtdDias > 0, ;
	if(Alltrim(cConsDtImpl)=="2",dDtVig+nQtdDias,dDtImpl+nQtdDias),;
           	CToD("  /  /  ","DDMMYY")),oDtLim:Refresh()),.F.);
			WHEN QDH->QDH_STATUS <> "L  "

@ 055,070 	MSGET oDtLim VAR dDtLimi PICTURE "@D" SIZE 043,008 OF oPanel PIXEL;
			WHEN QDH->QDH_STATUS <> "L  "
			
// PE para permitir digitar a data da validade sobrepondo o numero de dias.
If ExistBlock("QDODVLDOC")
	aParam:={dDtVig  ,;
				dDtImpl ,;
				nQtdDias,;
				dDtLimi}
	aPermiss:= ExecBlock("QDODVLDOC", .F., .F., aParam)
	If ValType(aPermiss) == "A" .And. !Empty(aPermiss) .And. Len(aPermiss) >= 4
		oDtVig:lReadOnly   := !aPermiss[1]
		oDtImpl:lReadOnly  := !aPermiss[2]
		oQtdDias:lReadOnly := !aPermiss[3]
		oDtLim:lReadOnly   := !aPermiss[4]
	Else
		oDtLim:lReadOnly := .F.
	EndIf
Else
	oDtLim:lReadOnly := .T.
EndIf

DEFINE SBUTTON FROM 75,40 TYPE 1 ENABLE OF oPanel ACTION (nOpc1:=1,oDlg:End())
DEFINE SBUTTON FROM 75,70 TYPE 2 ENABLE OF oPanel ACTION oDlg:End()

ACTIVATE MSDIALOG oDlg CENTERED

If nOpc1 == 1
	M->QDH_DTCAD := dDatabase
	M->QDH_DTVIG := dDtVig
	M->QDH_DTIMPL:= dDtImpl
	M->QDH_DTLIM := dDtLimi
EndIf

Return If(nOpc1 == 1,.T.,.F.)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	  ³QD110CkDep  ³ Autor ³ Newton R. Ghiraldelli      ³ Data ³ 23/09/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³Valida departamento                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³QD110CkDep(ExpC1,ExpC2,ExpC3)                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ ExpC1 - Codigo do departamento                                    ³±±
±±³			  ³ ExpC2 - Filial do Departamento                                    ³±±
±±³ 			  ³ ExpC3 - Nome do Departamento                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		  ³ QDOA110                                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD110CkDep(cDepto,cFilDes,cNDepto)

Local cFilCC:= xFilial("QAD")

	If Empty(cDepto)
	Return .T.
	EndIf

	If FWModeAccess("QAD") == "E" //!Empty(xFilial("QAD"))
	cFilCC:= cFilDes
	EndIf

	If !QAD->(DbSeek(cFilCC+cDepto))
  	Help(" ",1,"QD050CCNE")	// Depto nao Existe
	Return .F.
	EndIf

cNDepto:= QA_NDEPT(cDepto,.T.,cFilCC)

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	  ³QD110CkUsr  ³ Autor ³ Newton R. Ghiraldelli      ³ Data ³ 23/09/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³ Funcao de Validacao da existencia de Usuario/Pastas               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³ QD110CkUsr(ExpC1,ExpC2,ExpC3,ExpC4,ExpN1,ExpC5,ExpL1)             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ ExpC1 - Filial do Usuario                                         ³±±
±±³           ³ ExpC2 - Codigo do Usuario                                         ³±±
±±³           ³ ExpC3 - Nome do usuario                                           ³±±
±±³           ³ ExpC4 - Departamento do Usuario                                   ³±±
±±³           ³ ExpN1 - Tipo de distribuicao                                      ³±±
±±³           ³ ExpC5 - Nome do departamento do usuario                           ³±±
±±³           ³ ExpL1 - Valida o departamento		                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		  ³ QDOA110                                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD110CkUsr(cFilUsr,cCodMat,cUsu,cDepto,nTipo,cNDepto,lCkDepto)

Local cFilCC:= xFilial("QAD")
Local cFilPst:= xFilial("QDC")
Local bValid := {}

Default lCkDepto := .T.

	If lCkDepto // Considera o departamento na validação
	bValid := {|x| x[ 10 ] + x[ 3 ] + x[ 11 ] + x[ 9 ] == cFilUsr+cCodMat+cDepto+"D"}
	Else
	bValid := {|x| x[ 10 ] + x[ 3 ] + x[ 9 ] == cFilUsr+cCodMat+"D"}
	EndIf

	If nTipo == 1	// Departamento
		If FWModeAccess("QAD") == "E" ////!Empty(xFilial("QAD"))
		cFilCC:= cFilUsr
		EndIF
	
		If !QA_CHKMAT(cFilUsr,cCodMat)
		Return .F.
		EndIf
	cUsu   := QAA->QAA_NOME
	cDepto := QAA->QAA_CC
	cNDepto:= QA_NDEPT(cDepto,.T.,cFilCC)

		If Ascan(aQDG, bValid) > 0
		Help(" ",1,"QD050FJE") // Usuario ja cadastrado
		Return .F.
		EndIf
	Else	// Pasta
		If FWModeAccess("QDC") == "E" ////!Empty(xFilial("QDC"))
		cFilPst:= cFilUsr
		EndIf
		If !QDC->(DbSeek(cFilPst+cCodMat))
	 	Help(" ",1,"QD050PNE")	// Pasta nao Existe
		Return .F.
		EndIf
	EndIf

Return .T.                               

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	  ³FCAR_DIS    ³ Autor ³ Newton R. Ghiraldelli      ³ Data ³ 23/09/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³ Atualiza array de Pendencias                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³ FCAR_DIS()                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		  ³ QDOA110                                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function FCAR_DIS()

Local cTitulo:= ""
Local aUsrMat:= QA_USUARIO()
Local cMatFil:= aUsrMat[2]
Local cMatCod:= aUsrMat[3]

aPenden := {}
QD1->(DbSetOrder(3))
	If QD1->(DbSeek(cMatFil+cMatCod))
		While QD1->(!Eof()) .And. QD1->QD1_FILMAT+QD1->QD1_MAT == cMatFil+cMatCod
			If QD1->QD1_TPPEND == "I  " .And. QD1->QD1_PENDEN == "P"
			cTitulo:= Space(50)
			QDH->(DbSetOrder(1))
				If QDH->(DbSeek(QD1->QD1_FILIAL+QD1->QD1_DOCTO+QD1->QD1_RV))
				cTitulo:= QDH->QDH_TITULO
				EndIf
			AADD(aPenden,{"N",QD1->QD1_DOCTO,QD1->QD1_RV,cTitulo,QD1->(Recno())})	
			EndIf
		QD1->(DbSkip())
		EndDo
	aPenden:= aSort(aPenden,,,{|x,y| x[1]+x[2] < y[1]+y[2]})
	EndIf

QD1->(DbSetOrder(1))

Return                   

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	  ³QD110AlQDG  ³ Autor ³ Newton R. Ghiraldelli      ³ Data ³ 23/09/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³ Monta a tela de alteracao de destinatarios                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³ QD110AlQDG()                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		  ³ QDOA110                                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD110AlQDG()

	Local aCobItens  := {}
	Local aNovItens  := {}
	Local cCodMat    := Space(Len(QAA->QAA_MAT))
	Local cDepto     := Space(Len(QDG->QDG_DEPTO))
	Local cFilCC     := xFilial("QAD")
	Local cFilUsr    := xFilial("QAA")
	Local cItCp      := ""
	Local cNDepto    := Space(30)
	Local cPasta     := Space(Len(QDG->QDG_CODMAN))
	Local cUsu       := Space(40)
	Local I          := 1
	Local nCopias    := 1
	Local nItCp      := 1
	Local nItdp      := 1
	Local nItem      := 1
	Local nOpc1      := 0
	Local nOrdQDG    := QDG->(IndexOrd())
	Local oCodMat    := Nil
	Local oCopias    := Nil
	Local oDepto     := Nil
	Local oDlg       := Nil
	Local oFilUsr    := Nil
	Local oFwLayer   := Nil
	Local oItCp      := Nil
	Local oItdp      := Nil
	Local oItem      := Nil
	Local oNDepto    := Nil
	Local oPanelBody := Nil
	Local oPasta     := Nil
	Local oUsu       := Nil

	aRegs:= AClone(aQDGRegs[oQDH:nAt])

	DEFINE MSDIALOG oDlg FROM 000,000 TO 400,650 TITLE OemToAnsi(STR0037) PIXEL // "Destinatários - Alteração"

	//Criando a camada
	oFwLayer := FwLayer():New()
	oFwLayer:init(oDlg,.F.)

	//Adicionando linhas 
	oFWLayer:addLine("SUPERIOR"    , 015, .F.)
	oFWLayer:addLine("CORPO"   	   , 070, .F.)
	oFWLayer:addLine("INFERIOR"    , 015, .F.)

	//Adicionando as colunas das linhas
	oFWLayer:addCollumn("COLSUP" , 100, .T., "SUPERIOR" )
	oFWLayer:addCollumn("LATESQ" , 009, .T., "CORPO"    )
	oFWLayer:addCollumn("CONESQ" , 091, .T., "CORPO"    )
	oFWLayer:addCollumn("COLINF" , 100, .T., "INFERIOR" )

	//Criando os paineis
	oPanelBody := oFWLayer:GetColPanel("CONESQ" , "CORPO"    )

	nItem  := If(aRegs[oQDG:nAt,POS_AQDGREGS_RECEB] == "S",1,2)
	nItdp  := If(aRegs[oQDG:nAt,POS_AQDGREGS_TIPO] == "D",1,2)
	nItCp  := Val(aRegs[oQDG:nAt,POS_AQDGREGS_TPRCBT])
	cFilUsr:= aRegs[oQDG:nAt,POS_AQDGREGS_FILMAT]
	cCodMat:= aRegs[oQDG:nAt,POS_AQDGREGS_MATRI]
	cDepto := aRegs[oQDG:nAt,POS_AQDGREGS_DEPTO]
	nCopias:= Val(aRegs[oQDG:nAt,POS_AQDGREGS_NRCOP])
	cPasta := aRegs[oQDG:nAt,POS_AQDGREGS_PASTA]

	If FWModeAccess("QAD") == "E" //!Empty(xFilial("QAD"))
		cFilCC:= cFilUsr
	EndIf

	cNDepto:= QA_NDEPT(cDepto,.T.,cFilCC)

	If nItdp == 1
		cUsu:= QA_NUSR(cFilUsr,cCodMat,.T.)
	ElseIf nItdp == 2
		cUsu:= QDXFNANMAN(cPasta,.T.)
	EndIf

	@ 001,001 TO 135,268 OF oPanelBody PIXEL

	@ 009,007 SAY OemToAnsi(STR0012) SIZE 035,007 OF oPanelBody PIXEL  //"Filial"
	@ 009,045 MSGET oFilUsr VAR cFilUsr SIZE 050,008 OF oPanelBody PIXEL
	oFilUsr:lReadOnly:= .T.

	If nItdp == 1
		@ 009,100 MSGET oCodMat VAR cCodMat SIZE 055,008 OF oPanelBody PIXEL
		oCodMat:lReadOnly:= .T.
	ElseIf nItdp == 2
		@ 009,100 MSGET oPasta VAR cPasta SIZE 055,008 OF oPanelBody PIXEL
		oPasta:lReadOnly:= .T.
	EndIf

	@ 009,160 RADIO oItdp VAR nItdp;
					ITEMS OemToAnsi( STR0038 ),; // "Usuários"
						OemToAnsi( STR0019 );  // "Pastas"
			SIZE 035,008 OF oPanelBody PIXEL
	oItdp:lReadOnly:= .T.

	@ 034,006 SAY OemToAnsi(STR0013) SIZE 035,007 OF oPanelBody PIXEL  //"Usuário/Pasta"	
	@ 033,045 MSGET oUsu VAR cUsu SIZE 144,008 OF oPanelBody PIXEL
	oUsu:lReadOnly:= .T.

	@ 048,006 SAY OemToAnsi(STR0014) SIZE 035,007 OF oPanelBody PIXEL //"Depto"
	@ 047,045 MSGET oDepto VAR cDepto SIZE 070,008 OF oPanelBody PIXEL
	oDepto:lReadOnly:= .T.

	@ 047,118 MSGET oNDepto VAR cNDepto SIZE 144,008 OF oPanelBody PIXEL
	oNDepto:lReadOnly:= .T.

	@ 063,006 SAY OemToAnsi(STR0015) SIZE 035,007 OF oPanelBody PIXEL //"Nr. Cópias"	
	@ 062,045 MSGET oCopias VAR nCopias PICTURE '9999' SIZE 024,008 OF oPanelBody PIXEL;
					VALID nCopias > 0 WHEN IF(aRegs[oQDG:nAt,POS_AQDGREGS_TIPO] == "D",nItCp<>1,.T.)

	If Len (aQDG) > 0
		@ 077,006 SAY OemToAnsi(STR0016) SIZE 035,007 OF oPanelBody PIXEL  //"Recebe Docto"
		@ 076,045 RADIO oItem VAR nItem;
							ITEMS	OemToAnsi( STR0020 ),; // "Sim"
									OemToAnsi( STR0021 );  // "Não"
						3D SIZE 025,007 OF oPanelBody PIXEL
	EndIf

	IF ExistBlock("QDOAP21")
		If nItdp == 1
			aNovItens:=ExecBlock("QDOAP21",.F.,.F.,{{1,OemToAnsi(STR0022)},{2,OemToAnsi(STR0023)},{3,OemToAnsi(STR0024)},{4,OemToAnsi(STR0025)}})	
		ElseIf nItdp == 2
			aNovItens:=ExecBlock("QDOAP21",.F.,.F.,{{2,OemToAnsi(STR0023)},{4,OemToAnsi(STR0025)}})	
			nItCp:= IF(nItCp<=2,nItCp / 2,nItCp-2)		
		Endif
		aCobItens:={}
		For I:=1 To Len(aNovItens)
			Aadd(aCobItens,aNovItens[I,2])
		Next
		cItCp:= aNovItens[nItCp,2]

		@ 063,130 SAY OemToAnsi(STR0017) SIZE 035,007 OF oPanelBody PIXEL // "Tipo Cópias"
		@ 062,160 	COMBOBOX oItCp VAR cItCp ;
						ITEMS aCobItens ;
					SIZE 45,10 ON CHANGE nItCp:=oItCp:nat  OF oPanelBody PIXEL    
	Else
		If nItdp == 1
			@ 063,130 SAY OemToAnsi(STR0017) SIZE 035,007 OF oPanelBody PIXEL //"Tipo Cópia"	
			@ 062,160 RADIO oItCp VAR nItCp;
						ITEMS	OemToAnsi(STR0022),; // "Eletrônica"
								OemToAnsi(STR0023),; // "Papel"
								OemToAnsi(STR0024),; // "Ambos"
								OemToAnsi(STR0025);  // "Não Recebe"
						3D SIZE 050,007 OF oPanelBody PIXEL
		ElseIf nItdp == 2
			nItCp:= nItCp / 2
			@ 063,130 SAY OemToAnsi(STR0017) SIZE 035,007 OF oPanelBody PIXEL //"Tipo Cópia"
			@ 062,160 RADIO oItCp VAR nItCp;
							ITEMS	OemToAnsi(STR0023),; // "Papel"
									OemToAnsi(STR0025);  // "Não Recebe"
							3D SIZE 050,007 OF oPanelBody PIXEL
		Endif

		oItCp:BCHANGE:={|| IF(aRegs[oQDG:nAt,POS_AQDGREGS_TIPO ]=="D",(nCopias:=IF(nItCp==1,nCopias:=1,nCopias), oCopias:Refresh(),oCopias:SetFocus()),"") }
	EndIf

	DEFINE SBUTTON FROM 118,105 TYPE 1 ENABLE OF oPanelBody ACTION	(nOpc1:=1,oDlg:End())
	DEFINE SBUTTON FROM 118,135 TYPE 2 ENABLE OF oPanelBody ACTION	oDlg:End()

	ACTIVATE MSDIALOG oDlg CENTERED

	If nOpc1 = 1
		aRegs[oQDG:nAt, POS_AQDGREGS_NRCOP]:= Transform( nCopias, "@E 9,999" )
		aRegs[oQDG:nAt, POS_AQDGREGS_RECEB]:= If( nItem == 1, "S", "N" )
		If nItdp == 2
			If ExistBlock("QDOAP21")
				nItCp+= IF( nItCp==1 ,1 ,2 )      
			Else
				nItCp := nItCp * 2
			Endif
		EndIf
		aRegs[oQDG:nAt, POS_AQDGREGS_TPRCBT]:= Str( nItCp, 1 )
		aRegs[oQDG:nAt, POS_AQDGREGS_TPREC] := QDXFNDsDtr( Str( nItCp, 1 ) )
		aQDGRegs[oQDH:nAt]:= AClone( aRegs )
		aQDG:= aClone(aRegs)
		oQDG:SetArray(aQDG)
		oQDG:bLine:= bQDGLine
		oQDG:Refresh()
		aQDH[oQDH:nAt,POS_AQDGREGS_FLAG]:= AScan( aQDG, { |x| x[ 1 ] == .T. } ) > 0
		oQDH:SetArray(aQDH)
		oQDH:bLine:= bQDHLine
		oQDH:Refresh()
		QDG->(DbSetOrder(3))
		If QDG->(DbSeek(aRegs[oQDG:nAt,POS_AQDGREGS_FILIAL ]+aRegs[oQDG:nAt,POS_AQDGREGS_DOCTO]+aRegs[oQDG:nAt,POS_AQDGREGS_RV]+cFilUsr+cDepto+cCodMat+cPasta))
			Reclock("QDG",.F.)
			QDG->QDG_NCOP  := Val(aRegs[oQDG:nAt, POS_AQDGREGS_NRCOP])
			QDG->QDG_TPRCBT:= aRegs[oQDG:nAt,POS_AQDGREGS_TPRCBT]
			QDG->QDG_RECEB := aRegs[oQDG:nAt,POS_AQDGREGS_RECEB]
			QDG->(MsUnlock())
			FKCOMMIT()
		EndIf
		QDG->(DbSetOrder(nOrdQDG))   
	EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	  ³QD110IncUsr ³ Autor ³ Eduardo de Souza           ³ Data ³ 18/04/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³ Faz a inclusao de Usuario Destino                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³ QD110IncUsr(ExpA1)                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ ExpA1 - Array contendo os Destinatarios                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		  ³ QDOA110                                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD110IncUsr(aRegs)

	Local aReg       := {}
	Local cDepto     := Space(Len(QDG->QDG_DEPTO))
	Local cFilCC     := xFilial("QAD")
	Local cFilUsr    := xFilial("QAA")
	Local cMatUsr    := Space(TamSx3("QAA_MAT")[1])
	Local cNDepto    := Space(30)
	Local cUsu       := Space(40)
	Local I          := 0
	Local nCopias    := 1
	Local nItCp      := 1
	Local nItdp      := 1
	Local nItem      := 1
	Local nOpc1      := 0
	Local nOrdQDG    := QDG->(IndexOrd())
	Local nPos       := 0
	Local oCopias    := Nil
	Local oDepto     := Nil
	Local oDlg       := Nil
	Local oFwLayer   := Nil
	Local oItCp      := Nil
	Local oItem      := Nil
	Local oMatUsr    := Nil
	Local oPanelBody := Nil
	Local oUsuario   := Nil

	cFilMat:= cFilAnt

	DEFINE MSDIALOG oDlg FROM 000,000 TO 360,650 TITLE OemToAnsi(STR0011) PIXEL // "Usuários - Inclusão"

	//Criando a camada
	oFwLayer := FwLayer():New()
	oFwLayer:init(oDlg,.F.)

	//Adicionando linhas 
	oFWLayer:addLine("SUPERIOR"    , 015, .F.)
	oFWLayer:addLine("CORPO"   	   , 070, .F.)
	oFWLayer:addLine("INFERIOR"    , 015, .F.)

	//Adicionando as colunas das linhas
	oFWLayer:addCollumn("COLSUP" , 100, .T., "SUPERIOR" )
	oFWLayer:addCollumn("LATESQ" , 009, .T., "CORPO"    )
	oFWLayer:addCollumn("CONESQ" , 091, .T., "CORPO"    )
	oFWLayer:addCollumn("COLINF" , 100, .T., "INFERIOR" )

	//Criando os paineis
	oPanelBody := oFWLayer:GetColPanel("CONESQ" , "CORPO"    )

	@ 001,001 TO 120,268 OF oPanelBody PIXEL

	@ 010,007 SAY OemToAnsi(STR0012) SIZE 055,007 OF oPanelBody PIXEL //"Filial-Código"
	@ 009,045 MSGET cFilUsr	PICTURE '@!' F3 "SM0" SIZE 055,008 OF oPanelBody PIXEL;
					VALID QA_CHKFIL(cFilUsr,@cFilMat)

	@ 009,100 MSGET oMatUsr VAR cMatUsr PICTURE '@!' F3 "QDE" SIZE 055,008 OF oPanelBody PIXEL;
					VALID If(QD110CkUsr(cFilUsr,cMatUsr,@cUsu,@cDepto,nItdp,@cNDepto,.F.),(oNDepto:Refresh(),oUsuario:Refresh(),oDepto:Refresh()),.F.)

	@ 024,006 SAY OemToAnsi(STR0039) SIZE 035,007 OF oPanelBody PIXEL //"Usuário"
	@ 023,045 MSGET oUsuario VAR cUsu PICTURE '@!' SIZE 144,008 OF oPanelBody PIXEL
	oUsuario:lReadOnly:= .T.

	@ 038,006 SAY OemToAnsi(STR0014) SIZE 035,007 OF oPanelBody PIXEL //"Depto"
	@ 037,045 MSGET oDepto VAR cDepto PICTURE '@!' SIZE 070,008 OF oPanelBody PIXEL
	oDepto:lReadOnly:= .T.

	@ 037,118 MSGET oNDepto VAR cNDepto PICTURE '@!' SIZE 144,008 OF oPanelBody PIXEL
	oNDepto:lReadOnly:= .T.

	@ 053,006 SAY OemToAnsi(STR0015) SIZE 35,07 OF oPanelBody PIXEL //"Nr Cópias"
	@ 052,045 MSGET oCopias VAR nCopias PICTURE '9999' SIZE 024,008 OF oPanelBody PIXEL ;
					VALID nCopias > 0 WHEN IF(aRegs[oQDG:nAt, POS_AQDGREGS_TIPO ] == "D",nItCp<>1,.T.)

	@ 067,006 SAY OemToAnsi(STR0016) SIZE 035,007 OF oPanelBody PIXEL //"Recebe Docto"
	@ 066,045 RADIO oItem VAR nItem ;
					ITEMS OemToAnsi(STR0020),; // "Sim"
						OemToAnsi(STR0021);  // "Não"
				3D SIZE	025,007 OF oPanelBody PIXEL;

	If ExistBlock("QDOAP21")
		aNovItens:=ExecBlock("QDOAP21",.F.,.F.,{{1,OemToAnsi(STR0022)},{2,OemToAnsi(STR0023)},{3,OemToAnsi(STR0024)},{4,OemToAnsi(STR0025)}})	
		aCobItens:={}
		For I:=1 To LEN(aNovItens)
			Aadd(aCobItens,aNovItens[I,2])
		Next
		cItCp:= aNovItens[nItCp,2]

		@ 053,130 SAY OemToAnsi(STR0017) SIZE 035,007 OF oPanelBody PIXEL // "Tipo Cópias"
		@ 053,160 COMBOBOX oItCp VAR cItCp ;
		ITEMS aCobItens ;
		SIZE 45,10 ON CHANGE nItCp:=oItCp:nat  OF oPanelBody PIXEL
	Else
		@ 053,130 SAY OemToAnsi(STR0017) SIZE 035,007 OF oPanelBody PIXEL //"Tipo Cópias"
		@ 053,160 RADIO oItCp VAR nItCp ;
					ITEMS OemToAnsi(STR0022),;   // "&Eletrônica"
							OemToAnsi(STR0023),; // "&Papel"
							OemToAnsi(STR0024),; // "&Ambos"
							OemToAnsi(STR0025);  // "Não &Recebe"
					3D SIZE 050,007 OF oPanelBody PIXEL
		oItCp:BCHANGE:={|| IF(aRegs[oQDG:nAt,POS_AQDGREGS_TIPO ]=="D",(nCopias:=IF(nItCp==1,nCopias:=1,nCopias), oCopias:Refresh(),oCopias:SetFocus()),"") }                          
	Endif

	DEFINE SBUTTON FROM 100,105 TYPE 1 ENABLE OF oPanelBody;
				ACTION (If(QD110VldDest(aQDH,oQDH,cFilUsr,cDepto,cMatUsr),(nOpc1:= 1,oDlg:End()),.F.))
				
	DEFINE SBUTTON FROM 100,135 TYPE 2 ENABLE OF oPanelBody ACTION oDlg:End()

	ACTIVATE MSDIALOG oDlg CENTERED

	If nOpc1 = 1 .And. !Empty(cMatUsr)
		If FWModeAccess("QAD") == "E" //!Empty(xFilial("QAD"))
			cFilCC:= cFilUsr
		EndIf
		nPos := Ascan(aQDG,{|x| x[POS_AQDGREGS_FILIAL] + x[POS_AQDGREGS_DOCTO] + x[POS_AQDGREGS_RV] + x[POS_AQDGREGS_FILMAT] + x[POS_AQDGREGS_MATRI] + x[POS_AQDGREGS_DEPTO] + x[POS_AQDGREGS_TIPO] ==;
				      aQDH[oQDH:nAt,POS_AQDH_FILIAL]+aQDH[oQDH:nAt,POS_AQDH_DOCTO]+aQDH[oQDH:nAt,POS_AQDH_RV]+cFilUsr+cMatUsr+cDepto+"D"})

		aReg:= Array(17)			

		aReg[ POS_AQDGREGS_FLAG    ] := .T.
		aReg[ POS_AQDGREGS_DESCDP  ] := QA_NDEPT(cDepto,.T.,cFilCC)
		aReg[ POS_AQDGREGS_MATRI   ] := cMatUsr
		aReg[ POS_AQDGREGS_PASTA   ] := INI_AQDGREGS_PASTA
		aReg[ POS_AQDGREGS_NOME    ] := QA_NUSR(cFilUsr,cMatUsr,.T.)
		aReg[ POS_AQDGREGS_TPREC   ] := QDXFNDsDtr(Str(nItCp,1))
		aReg[ POS_AQDGREGS_NRCOP   ] := Transform(nCopias, "@E 9,999")
		aReg[ POS_AQDGREGS_TIPO    ] := If(nItdp == 1,"D","P")
		aReg[ POS_AQDGREGS_FILMAT  ] := cFilUsr
		aReg[ POS_AQDGREGS_DEPTO   ] := cDepto
		aReg[ POS_AQDGREGS_RECEB   ] := "S"
		aReg[ POS_AQDGREGS_TPRCBT  ] := Str(nItCp, 1)
		aReg[ POS_AQDGREGS_FILIAL  ] := aQDH[oQDH:nAt, POS_AQDH_FILIAL ]
		aReg[ POS_AQDGREGS_DOCTO   ] := aQDH[oQDH:nAt, POS_AQDH_DOCTO  ]
		aReg[ POS_AQDGREGS_RV      ] := aQDH[oQDH:nAt, POS_AQDH_RV     ]

		If nPos > 0
			aQDG[nPos] := AClone(aReg)
		Else
			Aadd(aQDG,aReg)
		Endif

		aQDG := ASort(aQDG,,, { |x, y| ;
					  x[POS_AQDGREGS_FILMAT] + x[POS_AQDGREGS_DEPTO] + x[POS_AQDGREGS_DESCDP] + x[POS_AQDGREGS_MATRI] + x[POS_AQDGREGS_NOME] < ;
					  y[POS_AQDGREGS_FILMAT] + y[POS_AQDGREGS_DEPTO] + y[POS_AQDGREGS_DESCDP] + y[POS_AQDGREGS_MATRI] + y[POS_AQDGREGS_NOME] ;
					})
		aQDGRegs[oQDH:nAt]:= AClone(aQDG)
		oQDG:SetArray(aQDG)
		oQDG:bLine:= bQDGLine
		oQDG:Refresh()
		aQDH[oQDH:nAt,1]:= ( AScan( aQDG, { |x| x[ 1 ] == .T. } ) > 0 )
		oQDH:SetArray(aQDH)
		oQDH:bLine := bQDHLine
		oQDH:Refresh()

		Begin Transaction
			QDG->(DbSetOrder(1))
			If QDG->(DbSeek(aQDH[oQDH:nAt,POS_AQDH_FILIAL]+aQDH[oQDH:nAt,POS_AQDH_DOCTO]+aQDH[oQDH:nAt,POS_AQDH_RV]+aReg[POS_AQDGREGS_TIPO]+cFilUsr+cDepto+cMatUsr))
				Reclock("QDG", .F. )
			Else
				Reclock("QDG", .T. )		
			Endif

			QDG->QDG_FILIAL := aReg[POS_AQDGREGS_FILIAL]
			QDG->QDG_DOCTO  := aReg[POS_AQDGREGS_DOCTO]
			QDG->QDG_RV     := aReg[POS_AQDGREGS_RV]
			QDG->QDG_FILMAT := aReg[POS_AQDGREGS_FILMAT]
			QDG->QDG_DEPTO  := aReg[POS_AQDGREGS_DEPTO]
			QDG->QDG_MAT    := aReg[POS_AQDGREGS_MATRI]
			QDG->QDG_NCOP   := Val(aReg[POS_AQDGREGS_NRCOP])
			QDG->QDG_TPRCBT := aReg[POS_AQDGREGS_TPRCBT]
			QDG->QDG_RECEB  := aReg[POS_AQDGREGS_RECEB]
			QDG->QDG_TIPO   := aReg[POS_AQDGREGS_TIPO]
			QDG->QDG_SIT    := " "
			QDG->(MsUnlock())
			FKCOMMIT()

			If !QDJ->(DbSeek(aReg[POS_AQDGREGS_FILIAL]+aReg[POS_AQDGREGS_DOCTO]+aReg[POS_AQDGREGS_RV]+aReg[POS_AQDGREGS_TIPO]+aReg[POS_AQDGREGS_FILMAT]+aReg[POS_AQDGREGS_DEPTO]))
				Reclock("QDJ", .T. )
				QDJ->QDJ_FILIAL:= aReg[POS_AQDGREGS_FILIAL]
				QDJ->QDJ_DOCTO := aReg[POS_AQDGREGS_DOCTO]
				QDJ->QDJ_RV    := aReg[POS_AQDGREGS_RV]
				QDJ->QDJ_FILMAT:= aReg[POS_AQDGREGS_FILMAT]
				QDJ->QDJ_DEPTO := aReg[POS_AQDGREGS_DEPTO]
				QDJ->QDJ_TIPO  := aReg[POS_AQDGREGS_TIPO]
				QDJ->(MsUnlock())
				FKCOMMIT()
			EndIf
		End Transaction
	EndIf
		
	QDG->(DbSetOrder(nOrdQDG))	

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	  ³QD110VldDest³ Autor ³ Eduardo de Souza           ³ Data ³ 19/04/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³ Verifica se destinatario esta cadastrado                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³ QD110VldDest()                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ ExpA1 - Array contendo dados do documento                         ³±±
±±³           ³ ExpO1 - Objeto ListBox Documentos                                 ³±±
±±³           ³ ExpC1 - Filial do Destinatario                                    ³±±
±±³           ³ ExpC2 - Departamento do Destinatario                              ³±±
±±³           ³ ExpC3 - Matricula do Destinatario                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		  ³ QDOA110                                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD110VldDest(aQDH,oQDH,cFilUsr,cDepto,cMatUsr)

	Local lRet    := .T.
	Local nOrdQDG := QDG->(IndexOrd())

	QDG->(DbSetOrder(3))

	If 	QDG->(DbSeek(aQDH[oQDH:nAt,POS_AQDH_FILIAL]+aQDH[oQDH:nAt,POS_AQDH_DOCTO]+aQDH[oQDH:nAt,POS_AQDH_RV]+cFilUsr+cDepto+cMatUsr)) .And.;
		Ascan(aQDG,{|x| x[POS_AQDGREGS_FILIAL] + x[POS_AQDGREGS_DOCTO] + x[POS_AQDGREGS_RV] + x[POS_AQDGREGS_FILMAT] + x[POS_AQDGREGS_MATRI] + x[POS_AQDGREGS_DEPTO] + x[POS_AQDGREGS_TIPO] ==;
		      aQDH[oQDH:nAt,POS_AQDH_FILIAL]+aQDH[oQDH:nAt,POS_AQDH_DOCTO]+aQDH[oQDH:nAt,POS_AQDH_RV]+cFilUsr+cMatUsr+cDepto+"D"}) > 0
		MsgAlert(OemToAnsi(STR0040),OemtoAnsi(STR0027)) //"Este destino já foi cadastrado" ### "Atenção"
		lRet:= .F.
	EndIf

	QDG->(DbSetOrder(nOrdQDG))

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o     ³ QD110CarDep³ Autor ³ Eduardo de Souza           ³ Data ³ 11/04/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o  ³ Carrega Departamentos para Selecao no Cadastro de Usuarios/Pastas ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe    ³ QD110CarDep(ExpA1)                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro  ³ ExpA1 - Array Contendo Departamentos                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso       ³ QDOA110                                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD110CarDep(aDeptos)

QAD->(DbSetOrder(1))
QAD->(Dbgotop())
QAD->(DbSeek(iif(FWModeAccess("QAD")=="C",xFilial("QAD"),'')))
	While QAD->(!Eof())
	Aadd(aDeptos,{"N",QAD->QAD_FILIAL,QAD->QAD_CUSTO,QAD->QAD_DESC,"N"})
	QAD->(DbSkip())
	EndDo

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	  ³ QD110IncPst³ Autor ³ Eduardo de Souza           ³ Data ³ 19/04/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³ Faz a inclusao de Destinatario tipo pasta                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³ QD110IncPst()                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ ExpA1 - Array contendo os Destinatarios                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		  ³ QDOA110                                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD110IncPst(aRegs,aDeptos)

Local aCobItens  := {}
Local aNovItens  := {}
Local bQADLine1  := Nil
Local bQADLine2  := Nil
Local cCodPst    := Space(TamSX3("QDC_CODMAN")[1])
Local cDescr     := Space(TamSX3("QDC_DESC")[1])
Local cItCp      := ""
Local I          := 1
Local lRet       := .T.
Local nCopias    := 1
Local nItCp      := 1
Local nItem      := 1
Local oBtn1      := Nil
Local oBtn2      := Nil
Local oCodPst    := Nil
Local oCopias    := Nil
Local oDeptos    := Nil
Local oDescr     := Nil
Local oDlg       := Nil
Local oFilPst    := Nil
Local oFWLayer   := Nil
Local oItCp      := Nil
Local oItem      := Nil
Local oNo        := LoadBitmap( GetResources(), "LBNO" )
Local oOk        := LoadBitmap( GetResources(), "ENABLE" )
Local oPanelBody := Nil

Private cFilPst  := xFilial("QDC")

DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0011) FROM 000,000 TO 570,650 OF oMainWnd PIXEL //"Destinatários - Inclusão"

//Criando a camada
oFwLayer := FwLayer():New()
oFwLayer:init(oDlg,.F.)

//Adicionando linhas 
oFWLayer:addLine("CORPO"   	   , 090, .F.)
oFWLayer:addLine("INFERIOR"    , 010, .F.)

//Adicionando as colunas das linhas
oFWLayer:addCollumn("LATESQ" , 009, .T., "CORPO"    )
oFWLayer:addCollumn("CONESQ" , 091, .T., "CORPO"    )
oFWLayer:addCollumn("COLINF" , 100, .T., "INFERIOR" )

//Criando os paineis
oPanelBody := oFWLayer:GetColPanel("CONESQ" , "CORPO"    )

@ 001,003 TO 69,270 OF oPanelBody PIXEL

If FWModeAccess("QDC") == "E" //!Empty(cFilPst)
	@ 010,006 SAY OemToAnsi(STR0012) SIZE 035,007 OF oPanelBody PIXEL //"Filial-Código"
	@ 009,045 MSGET oFilPst VAR cFilPst PICTURE '@!' F3 "SM0" SIZE 035,008 OF oPanelBody PIXEL;
					VALID QA_CHKFIL(cFilPst)

	@ 009,091 MSGET oCodPst VAR cCodPst PICTURE '@!' F3 "QDC1" SIZE 055,008 OF oPanelBody PIXEL;
					VALID If(QA_CHKMAN(cFilPst,cCodPst),(cDescr:= QDC->QDC_DESC,;
							QD110PtxDep(@aDeptos,cFilPst,cCodPst),oDescr:Refresh(),oDeptos:SetArray(aDeptos),oDeptos:bLine:= If(Len(aDeptos)>0,bQADLine1,bQADLine2),oDeptos:Refresh()),;
							(oDescr:Refresh(),.F.))
							
	@ 010,120 SAY OemToAnsi(STR0015) SIZE 035,007 OF oPanelBody PIXEL //"Nr. Cópias"	
	@ 009,154 MSGET oCopias VAR nCopias PICTURE '9999' SIZE 024,008 OF oPanelBody PIXEL;
					VALID nCopias > 0
Else
	@ 010,006 SAY OemToAnsi(STR0019) SIZE 035,007 OF oPanelBody PIXEL //"Pastas"
	@ 009,045 MSGET oCodPst VAR cCodPst PICTURE '@!' F3 "QDC" SIZE 055,008 OF oPanelBody PIXEL;
					VALID If(QA_CHKMAN(cFilPst,cCodPst),(cDescr:= QDC->QDC_DESC,;
							QD110PtxDep(@aDeptos,cFilPst,cCodPst),oDescr:Refresh(),oDeptos:SetArray(aDeptos),oDeptos:bLine:= If(Len(aDeptos)>0,bQADLine1,bQADLine2),oDeptos:Refresh()),;
							(oDescr:Refresh(),.F.))
							
	@ 010,130 SAY OemToAnsi(STR0015) SIZE 035,007 OF oPanelBody PIXEL //"Nr. Cópias"	
	@ 009,165 MSGET oCopias VAR nCopias PICTURE '9999' SIZE 024,008 OF oPanelBody PIXEL;
					VALID nCopias > 0				
EndIf

@ 026,006 SAY OemToAnsi(STR0047) SIZE 035,007 OF oPanelBody PIXEL //"Descricao"
@ 025,045 MSGET oDescr VAR cDescr PICTURE '@!' SIZE 144,008 OF oPanelBody PIXEL
oDescr:lReadOnly:= .T.

@ 041,006 SAY OemToAnsi(STR0016) SIZE 035,007 OF oPanelBody PIXEL //"Recebe Docto"
@ 040,045 RADIO oItem VAR nItem ;
				ITEMS OemToAnsi(STR0020),; // "Sim"
					  OemToAnsi(STR0021);  // "Não"
			 3D SIZE 025,007 OF oPanelBody PIXEL;

IF ExistBlock("QDOAP21")
	aNovItens:=ExecBlock("QDOAP21",.F.,.F.,{{2,OemToAnsi(STR0023)},{4,OemToAnsi(STR0025)}})
	aCobItens:={}
	For I:=1 To Len(aNovItens)
		Aadd(aCobItens,aNovItens[I,2])
	Next
	cItCp:= aNovItens[nItCp,2]

	@ 041,120 SAY OemToAnsi(STR0017) SIZE 035,007 OF oPanelBody PIXEL // "Tipo Cópias"
	@ 040,150 COMBOBOX oItCp VAR cItCp ;
				ITEMS aCobItens ;
				SIZE 45,10 ON CHANGE nItCp:=oItCp:nat OF oPanelBody PIXEL    
Else
	@ 041,118 SAY OemToAnsi(STR0017) SIZE 035,007 OF oPanelBody PIXEL //"Tipo Cópias"
	@ 040,148 RADIO oItCp VAR nItCp;
					ITEMS OemToAnsi(STR0023),; // "Papel"
						  OemToAnsi(STR0025);  // "Não Recebe"
					3D SIZE 50,07 OF oPanelBody PIXEL
Endif

@ 070,003 TO 230,270 LABEL OemToAnsi(STR0045) OF oPanelBody PIXEL //"Departamentos"
@ 080,007 LISTBOX oDeptos FIELDS;
             HEADER  " ", ;
                     OemToAnsi(STR0046),; // "Fil/Cod" 
                     OemToAnsi(STR0047) ; // "Descrição"
             SIZE 260,125 OF oPanelBody PIXEL;
             ON DBLCLICK QDO110Cl(oDeptos,@aDeptos)

bQADLine1 := {|| {If(aDeptos[oDeptos:nAt,1] == "S",oOk, oNo),aDeptos[oDeptos:nAt,2]+" - "+aDeptos[oDeptos:nAt,3],aDeptos[oDeptos:nAt,4]}}
bQADLine2 := {|| {oNo,Space(18),Space(25) }}
oDeptos:SetArray(aDeptos)
oDeptos:bLine:= If(Len(aDeptos)>0,bQADLine1,bQADLine2)
oDeptos:SetFocus(.t.)
oDeptos:Refresh()

@ 210,060 BUTTON oBtn1 PROMPT OemToAnsi(STR0049) SIZE 067,012 OF oPanelBody PIXEL; //"Marcar/Desmarcar todos"
				ACTION (QD110MRDep(@aDeptos),oDeptos:SetArray(aDeptos),oDeptos:bLine:= If(Len(aDeptos)>0,bQADLine1,bQADLine2),oDeptos:Refresh())
				
@ 210,130 BUTTON oBtn2 PROMPT OemToAnsi(STR0048) SIZE 067,012 OF oPanelBody PIXEL; //"Pesquisa Depto"
				ACTION QD110PesqDep(@oDeptos,aDeptos,1)

ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{||lRet:=QD110VPt(cCodPst),If (lRet,(QD110GrPst(aDeptos,nItCp,cFilPst,cCodPst,nCopias),oDlg:End()),)},{|| oDlg:End()}) // "Atualizando Destinatários..." ### "Aguarde..."

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	  ³ QD110GrPst ³ Autor ³ Eduardo de Souza           ³ Data ³ 19/04/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³ Faz a gravacao do Destinatario tipo pasta                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³ QD110GrPst(ExpA1,ExpN1,ExpC1,ExpC2)                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ ExpA1 - Array contendo os Destinatarios                           ³±±
±±³           ³ ExpN1 - Numero de Copias                                          ³±±
±±³           ³ ExpC1 - Filial da Pasta                                           ³±±
±±³           ³ ExpC2 - Codigo da Pasta                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		  ³ QDOA110                                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD110GrPst(aDeptos,nItCp,cFilPst,cCodPst,nCopias)

Local nCnt:= 0
Local cFilRes:= ""

Private cCodMat:= Space(TamSx3("QAA_MAT")[1])

CursorWait()
aDeptos:= aSort(aDeptos,,,{ |x,y| x[1] > y[1] } ) 
	IF ExistBlock("QDOAP21")
   	nItCp+= IF( nItCp==1 ,1 ,2 )      
	ELSE
	nItCp := nItCp * 2
	Endif
	For nCnt:= 1 To Len(aDeptos)
		If aDeptos[nCnt,1] == "S"
			If QAD->(DbSeek(aDeptos[nCnt,2]+aDeptos[nCnt,3]))
			cFilRes:= QAD->QAD_FILMAT
			cCodMat:= QAD->QAD_MAT
			CursorArrow()
				While Empty(cCodMat)
				cCodMat:= Qd053InQDG(cCodPst,aDeptos[nCnt,2],aDeptos[nCnt,3],cFilRes)
					If cCodMat == NIL
					cCodMat:= Space(10)
					EndIf
				EndDo
			CursorWait()
			EndIf
			QDG->(DbSetOrder(3))
			If !QDG->(DbSeek(aQDH[oQDH:nAt,POS_AQDH_FILIAL]+aQDH[oQDH:nAt,POS_AQDH_DOCTO]+aQDH[oQDH:nAt,POS_AQDH_RV]+cFilRes+aDeptos[nCnt,3]+cCodMat+cCodPst))

				aReg:= Array(17)			
				
				aReg[ POS_AQDGREGS_FLAG    ] := .T.
				aReg[ POS_AQDGREGS_DESCDP  ] := aDeptos[nCnt,4]
				aReg[ POS_AQDGREGS_MATRI   ] := cCodMat
				aReg[ POS_AQDGREGS_PASTA   ] := cCodPst
				aReg[ POS_AQDGREGS_NOME    ] := QA_NUSR(cFilRes,cCodMat,.T.)
				aReg[ POS_AQDGREGS_DESCPT  ] := QDXFNANMAN(cCodPst,.T.,cFilPst)
				aReg[ POS_AQDGREGS_TPREC   ] := QDXFNDsDtr(Str(nItCp,1))
				aReg[ POS_AQDGREGS_NRCOP   ] := Transform(nCopias, "@E 9,999")
				aReg[ POS_AQDGREGS_TIPO    ] := "P"
				aReg[ POS_AQDGREGS_FILMAT  ] := cFilRes //aDeptos[nCnt,2]
				aReg[ POS_AQDGREGS_DEPTO   ] := aDeptos[nCnt,3]
				aReg[ POS_AQDGREGS_RECEB   ] := "S"
				aReg[ POS_AQDGREGS_TPRCBT  ] := Str(nItCp,1)
				aReg[ POS_AQDGREGS_FILIAL  ] := aQDH[oQDH:nAt,POS_AQDH_FILIAL]
				aReg[ POS_AQDGREGS_DOCTO   ] := aQDH[oQDH:nAt,POS_AQDH_DOCTO]
				aReg[ POS_AQDGREGS_RV      ] := aQDH[oQDH:nAt,POS_AQDH_RV]

				If FWModeAccess("QDC") == "E" //!Empty(xFilial("QDC"))
					cFilPst:= QDG->QDG_FILIAL
				EndIf
				
				aReg[POS_AQDGREGS_STATUS] := Posicione("QDC",1,cFilPst+QDG->QDG_CODMAN,"QDC_STATUS")
							
				Aadd(aQDG,aReg)
				aQDG := ASort(aQDG,,, { |x, y| ;
							  x[POS_AQDGREGS_FILMAT] + x[POS_AQDGREGS_DEPTO] + x[POS_AQDGREGS_DESCDP] + x[POS_AQDGREGS_MATRI] + x[POS_AQDGREGS_NOME] < ;
							  y[POS_AQDGREGS_FILMAT] + y[POS_AQDGREGS_DEPTO] + y[POS_AQDGREGS_DESCDP] + y[POS_AQDGREGS_MATRI] + y[POS_AQDGREGS_NOME] ;
							})
				aQDGRegs[oQDH:nAt]:= AClone(aQDG)
					
				Begin Transaction
					Reclock("QDG",.T.)
					QDG->QDG_FILIAL := aReg[POS_AQDGREGS_FILIAL]
					QDG->QDG_DOCTO  := aReg[POS_AQDGREGS_DOCTO]
					QDG->QDG_RV     := aReg[POS_AQDGREGS_RV]
					QDG->QDG_FILMAT := aReg[POS_AQDGREGS_FILMAT]
					QDG->QDG_DEPTO  := aReg[POS_AQDGREGS_DEPTO]
					QDG->QDG_MAT    := aReg[POS_AQDGREGS_MATRI]
					QDG->QDG_NCOP   := Val(aReg[POS_AQDGREGS_NRCOP])
					QDG->QDG_TPRCBT := aReg[POS_AQDGREGS_TPRCBT]
					QDG->QDG_RECEB  := aReg[POS_AQDGREGS_RECEB]
					QDG->QDG_TIPO   := aReg[POS_AQDGREGS_TIPO]
					QDG->QDG_CODMAN := aReg[POS_AQDGREGS_PASTA]
					QDG->(MsUnlock())
					FKCOMMIT()			
					If !QDJ->(DbSeek(aReg[14]+aReg[15]+aReg[16]+aReg[9]+aReg[10]+aReg[11]))
						Reclock("QDJ", .T.)
						QDJ->QDJ_FILIAL:= aReg[POS_AQDGREGS_FILIAL]
						QDJ->QDJ_DOCTO := aReg[POS_AQDGREGS_DOCTO]
						QDJ->QDJ_RV    := aReg[POS_AQDGREGS_RV]
						QDJ->QDJ_FILMAT:= aReg[POS_AQDGREGS_FILMAT]
						QDJ->QDJ_DEPTO := aReg[POS_AQDGREGS_DEPTO]
						QDJ->QDJ_TIPO  := aReg[POS_AQDGREGS_TIPO]
						QDJ->(MsUnlock())
						FKCOMMIT()
					EndIf
				End Transaction
			EndIf
		Else
			Exit
		EndIf
	Next nCnt

	oQDG:SetArray(aQDG)
	oQDG:bLine := bQDGLine
	oQDG:Refresh()
	aQDH[oQDH:nAt,1]:= (AScan(aQDG,{|x| x[1] == .T.}) > 0)
	oQDH:SetArray(aQDH)
	oQDH:bLine:= bQDHLine
	oQDH:Refresh()
	aDeptos:= aSort(aDeptos,,,{ |x,y| x[2]+x[3] < y[2]+y[3] } ) 

	CursorArrow()

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	  ³QD110PesqDep³ Autor ³ Eduardo de Souza           ³ Data ³ 19/04/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³ Pesquisa Departamento                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³ QD110PesqDep(ExpO1,ExpA1)                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ ExpO1 - Objeto Departamentos                                      ³±±
±±³           ³ ExpA1 - Array contendo os departamentos                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		  ³ QDOA110                                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD110PesqDep(oDeptos,aDeptos,nTpPesq)

Local cCodDep   := Space(TamSx3("QAD_CUSTO")[1])
Local cDesDep   := Space(25)
Local cFilCC    := xFilial("QAD")
Local nOpcao1   := 0
Local nPos      := 0
Local nPosDep   := If(nTpPesq == 1,3,11)
Local nPosFil   := If(nTpPesq == 1,2,10)
Local oCodDep   := Nil
Local oDlg2     := Nil
Local oFilCC    := Nil
Local oPanelDpt := Nil

DEFINE MSDIALOG oDlg2 TITLE OemToAnsi(STR0071) FROM 000,000 TO 220,620 OF oMainWnd PIXEL // "Pesquisa Departamento"

oPanelDpt:= tPanel():New(23,80,,oDlg2,,.T.,,,,163,065)

@ 010,015 TO 100,298 LABEL OemToAnsi(STR0045) OF oDlg2 PIXEL // "Departamento"

@ 011,023 MSGET oFilCC VAR cFilCC PICTURE "@!" F3 "SM0" SIZE 055,008 OF oPanelDpt PIXEL;
          VALID QA_CHKFIL(cFilCC,@cFilDep) WHEN FWModeAccess("QAD")=="E" // !Empty(cFilCC)

@ 011,083 MSGET oCodDep VAR cCodDep PICTURE '@!' F3 "QDD" SIZE 050,008 OF oPanelDpt PIXEL;
				VALID If(Empty(cDesDep:= QA_NDEPT(cCodDep,.T.,cFilCC)),;
						(Help(" ",1,"QD050CCNE"),oDesDep:Refresh(),.F.),; // "Depto não existe"
						(oDesDep:Refresh(),.T.))

@ 025,023 MSGET oDesDep VAR cDesDep SIZE 110,008 OF oPanelDpt PIXEL
oDesDep:lReadOnly:= .T.

DEFINE SBUTTON FROM 041,050 TYPE 1 ENABLE OF oPanelDpt;
			ACTION (nOpcao1:= 1,oDlg2:End())

DEFINE SBUTTON FROM 041,085 TYPE 2 ENABLE OF oPanelDpt;
			ACTION oDlg2:End()

ACTIVATE MSDIALOG oDlg2 CENTERED	

If nOpcao1 == 1
	If If 	(FWModeAccess("QAD") == "C",;
	nPos:= aScan(aDeptos,{|x| x[nPosDep] == cCodDep} ),;
	nPos:= aScan(aDeptos,{|x| x[nPosFil]+x[nPosDep] == cFilCC+cCodDep} )) > 0
	oDeptos:nAt:= nPos
	oDeptos:Refresh()
		EndIf
	If nPos == 0 .And. nTpPesq == 2
	Help(" ",1,"QD053DEPNE") // "Departamento Destino nao cadastrado neste Documento"
	EndIf
EndIf
 
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o     ³ QDO110Cl   ³ Autor ³ Eduardo de Souza           ³ Data ³ 19/04/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o  ³ Tratar o click da pergunte                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe    ³ QDO110Cl(ExpO1,ExpA1)                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ ExpO1 - Objeto Depto                                              ³±±
±±³           ³ ExpA1 - Array contendo Departamentos                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso       ³ QDOA110                                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QDO110Cl(oDeptos,aDeptos)

	If aDeptos[oDeptos:nAt,1] == "S"
		If aDeptos[oDeptos:nAt,5] <> "S"
		aDeptos[oDeptos:nAt,1]:= "N"
		Else
		Help(" ",1,"QD110NEXC") // "Destino ja Cadastrado, para exclui-lo utilize o botao - Exclui Destinatarios"
		EndIf
	Else
	aDeptos[oDeptos:nAt,1]:= "S"
	EndIf
oDeptos:Refresh()

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	  ³ QD110MRDep ³ Autor ³ Eduardo de Souza           ³ Data ³ 19/04/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³ Marca/Desmarca os Departamentos                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³ QD110MRDep(ExpA1)                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ ExpA1 - Array contendo os departamentos                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		  ³ QDOA110                                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD110MRDep(aDeptos)

Local nCnt      := 0
Local nC        := 0

	If Len(aDeptos) > 0
	nC:= Ascan(aDeptos,{ |X| x[1]+x[5] == "S"+"N" } )
		For nCnt:= 1 to Len(aDeptos)
			If nC <> 0
				If aDeptos[nCnt,5] <> "S"
				aDeptos[nCnt,1]:= "N"
				EndIf
			Else
			aDeptos[nCnt,1]:= "S"
			EndIf
		Next nCnt
	EndIf

Return aDeptos

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	  ³ QD110PtxDep³ Autor ³ Eduardo de Souza           ³ Data ³ 19/04/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³ Marca Departamentos de acordo com amarracao do cadastro de Pastas ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³ QD110PtxDep(ExpA1)                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ ExpA1 - Array contendo os departamentos                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		  ³ QDOA110                                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD110PtxDep(aDeptos,cFilPst,cCodPst)

	Local nCnt    := 0
	Local nOrdQDG := QDG->(IndexOrd())

	For nCnt:= 1 To Len(aDeptos)
		aDeptos[nCnt,1]:= "N"
	Next nCnt

	QDG->(DbSetOrder(5))	
	If QDG->(DbSeek(aQDH[oQDH:nAt,POS_AQDH_FILIAL]+cCodPst+aQDH[oQDH:nAt,POS_AQDH_DOCTO]+aQDH[oQDH:nAt,POS_AQDH_RV]))
		While QDG->(!Eof()) .And. QDG->QDG_FILIAL+QDG->QDG_CODMAN+QDG->QDG_DOCTO+QDG->QDG_RV == aQDH[oQDH:nAt,POS_AQDH_FILIAL]+cCodPst+aQDH[oQDH:nAt,POS_AQDH_DOCTO]+aQDH[oQDH:nAt,POS_AQDH_RV]
			If QDG->QDG_RECEB == "S"
				If (nPos:= aScan(aDeptos,{|x| x[2]+x[3] == QDG->QDG_FILMAT+QDG->QDG_DEPTO})) > 0
					aDeptos[nPos,1]:= "S"
					aDeptos[nPos,5]:= "S"
				Endif
			Endif
			QDG->(DbSkip())
		EndDo
	Else
		QDT->(DbSetOrder(2))
		If QDT->(DbSeek(cFilPst+cCodPst))
			While QDT->(!Eof()) .And. QDT->QDT_FILCOD+QDT->QDT_CODMAN == cFilPst+cCodPst
				If (nPos:= aScan(aDeptos,{|x| x[2]+x[3] == QDT->QDT_FILDEP+QDT->QDT_DEPTO})) > 0
					aDeptos[nPos,1]:= "S"
				EndIf
			QDT->(DbSkip())
			EndDo
		EndIf
		QDT->(DbSetOrder(1))	
	EndIf

	QDG->(DbSetOrder(nOrdQDG))

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡ao      ³ QD110GrDev ³ Autor ³ Eduardo de Souza ³ Data ³ 23/04/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡ao   ³ Gera Pendencia de Devolucao de Revisao Anterior         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe     ³ QD110GrDev(ExpC1,ExpC2,ExpX3,ExpX4,ExpC5,ExpN1)         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Parametros  ³ ExpC1 - Filial do Usuario                               ³±±
±±³             ³ ExpC2 - Matricula do Usuario                            ³±±
±±³             ³ ExpC3 - Departamento do Usuario                         ³±±
±±³             ³ ExpC4 - Documento                                       ³±±
±±³             ³ ExpC5 - Revisao do Documento                            ³±±
±±³             ³ ExpN1 - Numero de Copias                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso         ³ QDOA110                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD110GrDev(cFilUsr,cMatUsr,cDepUsr,cDocto,cRv,nCopias)

QDU->(DbSetOrder(1))
	If QDU->(DbSeek(xFilial("QDU")+cDocto+cRv+cFilUsr+cMatUsr))
	nCopias:= QDU->QDU_NCOP + nCopias
	RecLock("QDU",.F.)
	QDU->QDU_NCOP  := nCopias
	QDU->QDU_COPPEN:= nCopias
	QDU->(MsUnlock())
	FKCOMMIT()
	Else
	RecLock("QDU",.T.)
	QDU->QDU_FILIAL:= xFilial("QDU")
	QDU->QDU_DTGERA:= dDataBase
	QDU->QDU_HRGERA:= SubStr(Time(),1,5)
	QDU->QDU_PENDEN:= "P"
	QDU->QDU_FILMAT:= cFilUsr
	QDU->QDU_MAT   := cMatUsr
	QDU->QDU_DEPTO := cDepUsr
	QDU->QDU_DOCTO := cDocto
	QDU->QDU_RV    := cRv
	QDU->QDU_NCOP  := nCopias
	QDU->QDU_COPPEN:= nCopias
	QDU->(MsUnlock())
	FKCOMMIT()
	EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡ao      ³ QD110ImpP  ³ Autor ³ Eduardo de Souza ³ Data ³ 08/07/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡ao   ³ Verifica se ha dados para impressao do protocolo.       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe     ³ QD110ImpP()                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso         ³ QDOA110                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD110ImpP(cDocFil,cDocCod,cDocRv)

Local cFiltro	:= ""
Local cTipPro  := GETMV("MV_QDOTPPR") // Parametro para impressao de somente copias em papel ou nao

cFiltro:= 'QD1->QD1_FILIAL == "'+cDocFil+ '".And. '
cFiltro+= 'QD1->QD1_DOCTO == "' +cDocCod+ '".And. '
cFiltro+= 'QD1->QD1_RV == "'    +cDocRv + '".And. '
cFiltro+= 'QD1->QD1_TPPEND == "L  "'

	If cTipPro == "S"
	cFiltro+= '.And. QD1->QD1_TPDIST $ "2,3"'
	Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ponto de Entrada Para tratamento do filtro com outras tipos de Copias³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                                    
		IF EXISTBLOCK("QDOAP25")
		cFiltro+= '.And. QD1->QD1_TPDIST $ "'+EXECBLOCK("QDOAP25",.F.,.F.)+'"'	    
		ENDIF
	Endif

DbSelectArea("QD1")
DbSetOrder(1)
Set Filter To &(cFiltro)
DbGotop()

	If QDH->(DbSeek(cDocFil+cDocCod+cDocRv))
		If QD1->(DbSeek(QDH->QDH_FILIAL+QDH->QDH_DOCTO+QDH->QDH_RV))
			While QD1->(!Eof()) .And. QD1->QD1_FILIAL+QD1->QD1_DOCTO+QD1->QD1_RV == cDocFil+cDocCod+cDocRv
			Return .T.
			EndDo
		EndIf
	EndIf

Set Filter To

Return .F.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³QD110Legen ³ Autor ³ Telso Carneiro       ³ Data ³15/06/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Cria uma janela contendo a legenda da ListBox              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QD110Legen                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QDOA110                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function QD110Legen()

Local aLegenda := { 	{'BR_AZUL'   , OemtoAnsi(STR0065) },; //"Elaboracao com Distribuicao Pendente"
						{'BR_PRETO'  , OemtoAnsi(STR0066)} }   //"Documento cancelado"

BrwLegenda(cCadastro,STR0063,aLegenda) 	  //"Legenda"

Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ QD110VPt ºAutor  ³Denis Martins	     º Data ³  08/04/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao para verificar o preenchimento da pasta quando o des º±±
±±º          ³tino for Pasta.											  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QDOA110                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QD110VPt(cCoPat)

	Local lRetorno := .T.

	If Empty(cCoPat)
		MessageDlg(STR0070) //Escolha uma pasta para relacionar ao departamento.
		lRetorno := .F.
	Endif

Return lRetorno


