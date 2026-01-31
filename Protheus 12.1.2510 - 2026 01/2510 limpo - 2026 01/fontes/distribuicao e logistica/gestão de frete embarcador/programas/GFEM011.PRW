#INCLUDE "PROTHEUS.CH"
#INCLUDE "OMSM010.CH"
#INCLUDE "FWMVCDEF.CH"

#DEFINE CRMARCA  1
#DEFINE CRCORBRW 2
#DEFINE CRALIAS  3
#DEFINE CRNOME   4
#DEFINE CRROTINA 5
#DEFINE CRMODEL  6
#DEFINE CRFILTRO 7


// Códigos de mensagens padronizadas
#DEFINE GFEM011001 'GFEM011001'
#DEFINE GFEM011002 'GFEM011002'
#DEFINE GFEM011003 'GFEM011003'
#DEFINE GFEM011004 'GFEM011004'
#DEFINE GFEM011005 'GFEM011005'
#DEFINE GFEM011006 'GFEM011006'
#DEFINE GFEM011007 'GFEM011007'
#DEFINE GFEM011008 'GFEM011008'
#DEFINE GFEM011009 'GFEM011009'
#DEFINE GFEM011010 'GFEM011010'

Static lUsaNewKey

//-----------------------------------------------------
/*/ Idem OMSM010 restrio ao SIGAGFE - Novo programa para substituir o OMSM011
@author Felipe Machado de Oliveira
@version P11
@since 16/06/2021
/*/
//------------------------------------------------------
Function GFEM011()
	Local aSize     := {}
	Local aObjects  := {}
	Local aListBox  := {}
	Local aInfo     := {}
	Local aPosObj   := {}
	Local oOk       := LoadBitMap(GetResources(),"LBOK")
	Local oNo       := LoadBitMap(GetResources(),"LBNO")
	Local oBtn01
	Local oBtn02
	Local lIntAtiva := .T.
	Local lIntGFE := SuperGetMv("MV_INTGFE",.F.,.F.)
	Local cIntGFE2 := SuperGetMv("MV_INTGFE2",.F.,"2")
	Local cIntNFS := SuperGetMv("MV_GFEI11",.F.,"2")
	Local nPosi := 20

	Private oVerde    := LoadBitmap( GetResources()	,	'BR_VERDE'		)
	Private oAmarelo	:=	LoadBitmap( GetResources()	,	'BR_AMARELO'	)
	Private oListBox	:= Nil
	Private oDlg		:= Nil
	Private oQtdDoc	:= Nil
	Private oQtdMrk	:= Nil
	Private nQtdDoc	:= 0
	Private nQtdMrk	:= 0
	Private lExecAuto	:= .F.
	Private cMsgErro 	:= ""

//-- Checkbox
	Private lAllMark:= .F.   // Usado para o controle da marca de todos os documentos
//-- Rotinas Marcadas
	Private aRotMark:= {}

	If lIntGFE <> .T.
		GFEMessage(5,GFEM011001,STR0036,STR0075)  //"ERP não possui integração com SIGAGFE (MV_INTGFE)."
		lIntAtiva := .F.
	Else
		If !cIntGFE2 $ "1"
			GFEMessage(5,GFEM011002,STR0037,STR0076) //"A integração direta, sem o uso de EAI e TOTVSESB, não está ativa (MV_INTGFE2). Utilize o programa de Carga Inicial (OMSM010)."
			lIntAtiva := .F.
		EndIf
	EndIf

	If lIntAtiva

		CursorWait()

		//-- Array com as rotinas a serem integradas GFE x Protheus
		Aadd(aListBox,{'2', oVerde, 'SA1',STR0001 ,'MATA030','MATA030_SA1', NIL }) //Cadastro de Clientes
		Aadd(aListBox,{'2', oVerde, 'SA2',STR0002 ,'MATA020','MATA020_SA2', NIL }) //Cadastro de Fornecedores
		Aadd(aListBox,{'2', oVerde, 'DA3',STR0003 ,'OMSA060','OMSA060_DA3', NIL }) //Cadastro de Veiculo
		Aadd(aListBox,{'2', oVerde, 'DA4',STR0004 ,'OMSA040','OMSA040_DA4', NIL }) //Cadastro de Motoristas
		Aadd(aListBox,{'2', oVerde, 'SA4',STR0005 ,'MATA050','MATA050_SA4', NIL }) //Cadastro de Transportadoras
		Aadd(aListBox,{'2', oVerde, 'CC2',STR0006 ,'FISA010','FISA010_CC2', NIL }) //Cadastro de Municipios
		Aadd(aListBox,{'2', oVerde, 'DUT',STR0007 ,'TMSA530','TMSA530_DUT', NIL }) //Cadastro de Tipos de Veículo
		Aadd(aListBox,{'2', oVerde, 'CTT',STR0025 ,'CTBA030','CTBA030_CTT', NIL }) //Cadastro de Centro de Custo
		Aadd(aListBox,{'2', oVerde, 'CT1',STR0026 ,'CTBA020','CTBA020_CT1', NIL }) //Cadastro de Plano de Contas
		Aadd(aListBox,{'2', oVerde, 'SF2',STR0033 ,'MATA461','MATA461_SF2', NIL }) //Nota Fiscal de Saída
		Aadd(aListBox,{'2', oVerde, 'SF1',STR0038 ,'MATA103','MATA103_SF1', NIL }) //Documentos de Entrada
		Aadd(aListBox,{'2', oVerde, 'DAK',STR0039 ,'OMSA200','OMSA200_DAK', NIL }) //Montagem de Cargas
		Aadd(aListBox,{'2', oVerde, 'DFT',STR0050 ,'TMSAR05','TMSAR05_DFT', NIL }) //Redespacho

		CursorArrow()

		aSize    := MsAdvSize(.F. )
		aObjects := {}

		AAdd( aObjects, { 100, 020, .T., .F., .T.  } )
		AAdd( aObjects, { 100, 100, .T., .T. } )
		AAdd( aObjects, { 100, 020, .F., .F. } )

		aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3, .T.  }
		aPosObj := MsObjSize( aInfo, aObjects, .T. )

		DEFINE MSDIALOG oDlg TITLE STR0040 From aSize[7],0 to aSize[6],aSize[5] OF oMainWnd PIXEL //"Carga Inicial GFE"

		oPanel := TPanel():New(aPosObj[1,1],aPosObj[1,2],"",oDlg,,,,,CLR_WHITE,(aPosObj[1,3]), (aPosObj[1,4]), .T.,.T.)

		@ 005,005 CHECKBOX oAllMark VAR lAllMark PROMPT STR0009 SIZE 168, 08; //-- Marca/Desmarca Todos
		ON CLICK(GFEM011All(aListBox)) OF oPanel PIXEL

		//-- Cabecalho dos campos do Monitor.
		@ aPosObj[2,1],aPosObj[2,2] LISTBOX oListBox Fields HEADER;
			"","",STR0010,STR0011, STR0012 SIZE aPosObj[2,4]-aPosObj[2,2],aPosObj[2,3]-aPosObj[2,1] PIXEL

		oListBox:SetArray( aListBox )
		oListBox:bLDblClick := { || GFEM011Mrk(aListBox) }
		oListBox:bLine      := { || {	Iif(aListBox[ oListBox:nAT,CRMARCA ] == '1',oOk,oNo),;
			aListBox[ oListBox:nAT,CRCORBRW],;
			aListBox[ oListBox:nAT,CRALIAS ],;
			aListBox[ oListBox:nAT,CRROTINA],;
			aListBox[ oListBox:nAT,CRNOME  ]}}

		//-- Botoes da tela do monitor.
		@ aPosObj[3,1],aPosObj[3,4] - 100 BUTTON oBtn01 PROMPT STR0013 ACTION GFEM011Leg() OF oDlg PIXEL SIZE 035,011 //-- "Legenda"
		@ aPosObj[3,1],aPosObj[3,4] - 060 BUTTON oBtn02 PROMPT STR0014 ACTION Iif(MsgYesNo(STR0015,STR0008),;        //--"Confirma o Processamento",Carga Inicial
		Processa( { || GFEM011Proc(aListBox) }, , STR0041, .T. ),'') OF oDlg PIXEL SIZE 035,011 //"Transmitindo para o SIGAGFE"
		@ aPosObj[3,1],aPosObj[3,4] - 020 BUTTON oBtn03 PROMPT STR0019 ACTION GFEM011Fil(@aListBox) OF oDlg PIXEL SIZE 035,011 //-- "Filtro"

		If cIntNFS == "1"
			@ aPosObj[3,1],aPosObj[3,4] + 020 BUTTON oBtn04 PROMPT "NFS Pend" ACTION OMSM012() OF oDlg PIXEL SIZE 035,011 //-- "NFS Pend"
			nPosi := 60
		EndIf

		@ aPosObj[3,1],aPosObj[3,4] + nPosi BUTTON oBtn05 PROMPT STR0020 ACTION oDlg:End() OF oDlg PIXEL SIZE 035,011 //-- "Sair"

		ACTIVATE MSDIALOG oDlg CENTERED

	EndIf

Return ( Nil )
/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Programa  ³GFEM011Leg ³ Autor ³Leandro Paulino			³Data ³05.05.2011 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descri‡…o ³Rotina da Legenda do Filtro da Rotina                       ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Retorno   ³Nenhum                                                      ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Parametros³                                                            ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function GFEM011Leg()

	BrwLegenda( STR0023		, STR0019,;				//--	"Status do Doc." # "Status"
	{{'BR_AMARELO' , STR0021 },;  		//-- Não Transmitido
	{'BR_VERDE'    , STR0022 }})  		//-- Documento Aguardando

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ GFEM011Mrk³  Autor ³ Leandro Paulino      ³ Data ³05.05.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Marca as rotinas no listbox                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GFEM011Mrk()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GFEM011                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function GFEM011Mrk(aListBox,nItem,lRefresh,lUmItem,lRetMark)
Local nPosMrk := 0
Local cIntNFE := SuperGetMv("MV_GFEI10",.F.,"2")
Local cIntNFS := SuperGetMv("MV_GFEI11",.F.,"2")
Local lNumProp:= GFEEMITMP()

Default nItem   := oListBox:nAt
Default lRefresh:= .T.
Default lUmItem := .T.
Default lRetMark:= .F.

If lUmItem
	aListBox[nItem,CRMARCA] := Iif(aListBox[nItem,CRMARCA] == '1','2','1')
	If(aListBox[nItem,CRMARCA]) == '1'
		nQtdMrk += 1
		If aListBox[nItem,CRALIAS] == "SF2" .And. cIntNFS == "2"
			GFEMessage(0,GFEM011003,STR0064,STR0077) //"Integração com Documento de Saída não está ativa. (MV_GFEI10)"
		EndIf

		If aListBox[nItem,CRALIAS] == "SF1" .And. cIntNFE == "2"
			GFEMessage(0,GFEM011004,STR0065,STR0078) //"Integração com Documento de Entrada não está ativa. (MV_GFEI11)"
		EndIf

		If lNumProp .And. aListBox[nItem,CRALIAS] == "SA4"
			GFEMessage(0,GFEM011005,STR0066,STR0079) //"Com a opção 'Numeração própria' do parâmetro 'Código Emitente' (MV_EMITMP) o cadastro de Transportadores no GFE ficará unificado com o de Fornecedores. Se necessário, sincronize os Fornecedores selecionando a tabela SA2."
			aListBox[nItem,CRMARCA] := '2'
		EndIf

	ElseIf(aListBox[nItem,CRMARCA]) == '2'
		nQtdMrk -= 1
	EndIf
Else
	If lAllMark
		aListBox[nItem,CRMARCA] := '1'
		nQtdMrk += 1
	Else
		aListBox[nItem,CRMARCA] := '2'
		nQtdMrk := 0
	EndIf
EndIf
nPosMrk := Ascan(aRotMark,{ | e | e[1]+e[2] == aListBox[nItem,CRALIAS]+aListBox[nItem,CRROTINA] })
If nPosMrk == 0
	Aadd(aRotMark,{ aListBox[nItem,CRROTINA], aListBox[nItem,CRALIAS], '' })
	nPosMrk := Len(aRotMark)
EndIf
aRotMark[nPosMrk,3] := aListBox[nItem,CRMARCA]
If lRefresh
	oListBox:Refresh()
EndIf

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ GFEM011All³  Autor ³ Leandro Paulino     ³ Data ³05.05.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Marca/Desmarca todas as rotinas                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GFEM011All()    		                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GFEM011                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function GFEM011All(aListBox)
Local nI      := 0
Local lRefresh:= .T.
Local lUmItem := .F.

CursorWait()
nQtdMrk := 0

For nI := 1 To Len(aListBox)
	GFEM011Mrk(aListBox,nI,lRefresh,lUmItem)
Next nI

CursorArrow()

oListBox:Refresh()

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³GFEM011Proc  ³ Autor ³Leandro Paulino      ³ Data ³15.04.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina responsavel por enviar as tabelas para MaEnvEAI      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Param[1] - Array contendo as rotinas da tela                ³±±
±±³         ³                                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function GFEM011Proc(aListBox)
	Local nI			:= 0
	Local aCargaIni	:= {}
	Local aGetArea	:= GetArea()
	Local ArqvLog := GFELog():New(STR0042, STR0040+" - "+STR0043, SuperGetMV('MV_GFEEDIL',.F.,'1')) //"Carga_Inicial_GFE"##"Carga Inicial GFE - Relatório de Erros de Integração"
	Local lNumProp := GFEEMITMP()
	Local cFilialTab := ''

	Default aListBox  := {}

	aCargaIni := GFEM011Rot(aListBox)

	ArqvLog:Add("------------------------------------------------------------------------------------------------------------------------")
	ArqvLog:Add("| "+STR0044+" |              "+STR0045+"              | "+STR0046+" |                          STATUS                         ")//"ROTINA"##"CAMPOS CHAVE"##"CAMPO GFE"##"PROBLEMA"
	ArqvLog:Add("------------------------------------------------------------------------------------------------------------------------")

	For nI := 1 To Len(aCargaIni)
		If lNumProp .And. aCargaIni[nI,CRALIAS] == "SA4"
			Loop
		EndIf

		dbSelectArea(aCargaIni[nI,CRALIAS])
		dbGoTop()

		cIndAlias := CriaTrab( Nil, .F. )

		IndRegua((aCargaIni[nI,CRALIAS]), cIndAlias, IndexKey(), , aCargaIni[nI,CRFILTRO],STR0024) //--"Selecionando Registros..."

		nIndAlias := RetIndex(aCargaIni[nI,CRALIAS])

		DbSetOrder( nIndAlias + 1 )
		ProcRegua( (aCargaIni[nI,CRALIAS])->( RecCount() ) )
		While (!(aCargaIni[nI,CRALIAS])->(Eof()))
			cFilialTab := (aCargaIni[nI,CRALIAS])+"->"+IIF(SubStr((aCargaIni[nI,CRALIAS]),1,1) == 'S',SubStr((aCargaIni[nI,CRALIAS]),2,3),(aCargaIni[nI,CRALIAS]))+"_FILIAL"

			If aCargaIni[nI,CRALIAS] == "DFT"
				If IIF(!Empty(&cFilialTab), &cFilialTab == XFILIAL("DFT"), .T.)
					IncProc()

					GFEM011IPG(aCargaIni[nI,CRALIAS],ArqvLog)
				EndIf
			ElseIf IIF(!Empty(&cFilialTab), &cFilialTab == xFilial(aCargaIni[nI,CRALIAS]), .T.)

				If aCargaIni[nI,CRALIAS] == "SF2"
					If Empty(SF2->F2_FILIAL) .OR. SF2->F2_FILIAL == XFILIAL("SF2")
						lFilial := .T.
					Else
						lFilial := .F.

					EndIf
				Else
					lFilial := .T.
				EndIf

				If lFilial
					IncProc()

					GFEM011IPG(aCargaIni[nI,CRALIAS],ArqvLog)
				EndIf

			EndIf

			(aCargaIni[nI,CRALIAS])->(dbSkip())

		EndDo

		If	File( cIndAlias + OrdBagExt() )
			DbSelectArea((aCargaIni[nI,CRALIAS]))
			DbClearFilter()
			Ferase( cIndAlias + OrdBagExt() )
		EndIf

		RetIndex((aCargaIni[nI,CRALIAS]))

	Next nI


	ArqvLog:EndLog()

	If SuperGetMV('MV_GFEEDIL',.F.,"'1") <> "1"
		GFEMessage(0,GFEM011006,STR0067,STR0080 + CHR(13) + CHR(10) + CHR(13) + CHR(10) + ArqvLog:cFullFile) //"Para detalhes do processamento, consultar o arquivo de log:"
	EndIf

	RestArea(aGetArea)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³GFEM011Rot ³ Autor ³ Leandro Paulino       ³ Data ³05.05.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Preparar rotinas para processamento                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Retorna as rotinas selecionadas.                           ³±±
±±³          ³ Array dos documentos                                       ³±±
±±³          ³ [1] - Marca/Desmarca                                       ³±±
±±³          ³ [2] - Cor Legenda    		                                ³±±
±±³          ³ [3] - Alias                                                ³±±
±±³          ³ [4] - Nome do Alias                                        ³±±
±±³          ³ [5] - Rotina                                               ³±±
±±³          ³ [6] - Model        			                                ³±±
±±³          ³ [7] - Filtro       			                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function GFEM011Rot(aListBox)
	Local   nI         := 0
	Local   aRotProc 	 := {}

	For nI := 1 To Len(aListBox)
		If aListBox[nI,CRMARCA] == '1'
			Aadd(aRotProc, {aListBox[nI,CRMARCA],aListBox[nI,CRCORBRW],aListBox[nI][CRALIAS],aListBox[nI][CRNOME], aListBox[nI][CRROTINA], aListBox[nI][CRMODEL], aListBox[nI][CRFILTRO]} )
		EndIf
	Next nI

Return ( aRotProc )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³GFEM011Fil ³ Autor ³ Leandro Paulino       ³ Data ³18.04.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Preparar rotinas para processamento                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Array dos documentos                                       ³±±
±±³          ³ [1] - Marca/Desmarca                                       ³±±
±±³          ³ [2] - Cor Legenda                                          ³±±
±±³          ³ [3] - Alias                                                ³±±
±±³          ³ [4] - Nome do Alias                                        ³±±
±±³          ³ [5] - Rotina                                               ³±±
±±³          ³ [6] - Model                                                ³±±
±±³          ³ [7] - Filtro                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Function GFEM011Fil(aListBox)
Default aListBox := {}

aListBox[oListBox:nAT,CRFILTRO] := BuildExpr( aListBox[ oListBox:nAT,CRALIAS ], ,aListBox[oListBox:nAT,CRFILTRO])

If !Empty(aListBox[oListBox:nAT,CRFILTRO] )
	aListBox[ oListBox:nAT,CRCORBRW] := oAmarelo
	oListBox:Refresh()
Else
	aListBox[ oListBox:nAT,CRCORBRW] := oVerde
	oListBox:Refresh()
EndIf

Return ( Nil )

//-----------------------------------------------------
/*/	Integra as tabelas selecionadas do protheus no SIGAGFE
@author Felipe Machado de Oliveira
@version P11
@since 18/04/2013
/*/
//------------------------------------------------------
Function GFEM011IPG(cProTable,ArqvLog)
	Local lEAICodUnq := Iif(FindFunction("TMSCODUNQ"),TMSCODUNQ(),.F.)      //Codigo Unico
	Local lGU3_ANTT  := (GFXCP12117('GU3_ANTT') .And. GFXCP12117('SA4_ANTT'))
	Local lGU8_CIV   := (GFXCP12117('GU8_CIV') .And. GFXCP12117('DA3_CIV'))
	Local lA4_MSBLQL := GFXCP12117('A4_MSBLQL')
	Local lNumProp   := GFEEMITMP()
	Local aAreaAnt   := GetArea()
	Local oModelGFE  := Nil
	Local cAliasSA4  := Nil
	Local cAliasGU8  := Nil
	Local cAliasGUU  := Nil
	Local cAliasGU7  := Nil
	Local cAliasGV3  := Nil
	Local cAliasGUH  := Nil
	Local cAliasGUE  := Nil
	
	Local cCodMun    := ''
	Local cCodEmit   := ''
	Local nRecnoGU3  := 0
	Local nOperacao  := MODEL_OPERATION_INSERT
	Local oPrVldCAD

	Default ArqvLog := ""

	//Define o Model do SIGAGFE utilizado e
	//seta os valores dos campos em bloco de código
	Do Case
		Case cProTable == "SA1"
			// Verifica se cliente já cadastrado como emitente para efetuar a alteração ou inclusão
			// Quando for uma alteração irá posicionar no registro de emitente.
			If GetOperGU3(cProTable,@nRecnoGU3)
				nOperacao := MODEL_OPERATION_UPDATE
				GU3->(dbGoTo(nRecnoGU3))
			EndIf
			//Carrega o model da rotina
			oModelGFE := FWLoadModel('GFEA015')

			//-- Suportabilidade (09/Nov/2022): Pré-Validações antes do MVC
			oPrVldCAD := JsonObject():New()
			oPrVldCAD["GU3_NRCID"]  := TMS120CDUF(SA1->A1_EST, '1') + SA1->A1_COD_MUN
			lRet := !FindFunction("GFEPreVld") .Or. GFEPreVld("GU3",@oPrVldCAD)
			//-- Fim - Suportabilidade: Pré-validações

			//Chama a opção de insert ou update do model
			If lRet
				oModelGFE:SetOperation(nOperacao) //Retorna operação de update caso ja esteja integrado
				oModelGFE:Activate()
				If nOperacao == MODEL_OPERATION_INSERT
					If lNumProp
						If lEAICodUnq
							oModelGFE:SetValue( 'GFEA015_GU3', 'GU3_CDEMIT', AllTrim(SA1->A1_COD) )
						Else
							oModelGFE:LoadValue( 'GFEA015_GU3', 'GU3_CDEMIT', 'ZZZZZZZZZ' )
						EndIf
					Else
						oModelGFE:SetValue( 'GFEA015_GU3', 'GU3_CDEMIT', IIF(SA1->A1_TIPO <> 'X',SA1->A1_CGC,AllTrim(SA1->A1_COD)+AllTrim(SA1->A1_LOJA)) )
					EndIf
				EndIf
				oModelGFE:SetValue( 'GFEA015_GU3', 'GU3_NMEMIT', SA1->A1_NOME )
				oModelGFE:SetValue( 'GFEA015_GU3', 'GU3_NMFAN' , SA1->A1_NREDUZ )
				oModelGFE:SetValue( 'GFEA015_GU3', 'GU3_NATUR' , IIF(SA1->A1_TIPO <> 'X',SA1->A1_PESSOA,'X') )
				oModelGFE:SetValue( 'GFEA015_GU3', 'GU3_DTNASC', SA1->A1_DTNASC )
				If !Empty(SA1->A1_CGC)
					oModelGFE:LoadValue( 'GFEA015_GU3', 'GU3_EMFIL' , A030CLIFIL(SA1->A1_CGC) )
				EndIf
				oModelGFE:LoadValue( 'GFEA015_GU3', 'GU3_CLIEN' , '1' )
				oModelGFE:SetValue( 'GFEA015_GU3', 'GU3_ENDER' , SA1->A1_END )
				oModelGFE:SetValue( 'GFEA015_GU3', 'GU3_COMPL' , SA1->A1_COMPLEM )
				oModelGFE:SetValue( 'GFEA015_GU3', 'GU3_BAIRRO', SA1->A1_BAIRRO )
				oModelGFE:SetValue( 'GFEA015_GU3', 'GU3_CEP'   , SA1->A1_CEP )
				oModelGFE:SetValue( 'GFEA015_GU3', 'GU3_NRCID' , oPrVldCAD["GU3_NRCID"] )
				oModelGFE:SetValue( 'GFEA015_GU3', 'GU3_IDFED' , IIF(SA1->A1_TIPO <> 'X',SA1->A1_CGC, '') )
				oModelGFE:SetValue( 'GFEA015_GU3', 'GU3_IE'    , SA1->A1_INSCR )
				oModelGFE:SetValue( 'GFEA015_GU3', 'GU3_IM'    , SA1->A1_INSCRM )
				oModelGFE:SetValue( 'GFEA015_GU3', 'GU3_CXPOS' , SubStr(SA1->A1_CXPOSTA,1,10) )
				oModelGFE:SetValue( 'GFEA015_GU3', 'GU3_EMAIL' , SA1->A1_EMAIL )
				oModelGFE:SetValue( 'GFEA015_GU3', 'GU3_FONE1' , SA1->A1_TEL )
				oModelGFE:SetValue( 'GFEA015_GU3', 'GU3_FAX'   , SA1->A1_FAX )
				oModelGFE:SetValue( 'GFEA015_GU3', 'GU3_WSITE' , SA1->A1_HPAGE )
				oModelGFE:LoadValue( 'GFEA015_GU3', 'GU3_ORIGEM', '2' )
				oModelGFE:LoadValue( 'GFEA015_GU3', 'GU3_SIT'   , IIF(SA1->A1_MSBLQL == '1','2','1') )

				If lNumProp
					oModelGFE:LoadValue( 'GFEA015_GU3', 'GU3_CDERP' , SA1->A1_COD )
					oModelGFE:LoadValue( 'GFEA015_GU3', 'GU3_CDCERP', SA1->A1_LOJA )
					oModelGFE:LoadValue( 'GFEA015_GU3', 'GU3_CDTERP', '' )
					oModelGFE:LoadValue( 'GFEA015_GU3', 'GU3_TRANSP', '2' )
					oModelGFE:LoadValue( 'GFEA015_GU3', 'GU3_AUTON', '2' )
				EndIf
			EndIf

			//Valida os dados informados
			If lRet .And. oModelGFE:VldData()
				//Confirma
				oModelGFE:CommitData()
			Else
				If !Empty(oPrVldCAD["MSGERR"])
					oModelGFE:SetErrorMessage(,,,"GU3_NRCID",,"Pré-Validação GFE" + " - " + oPrVldCAD["MSGERR"],)
				EndIf
				If !Empty( SuperGetMv("MV_DRTLOG",.F.,"") ) .And. !Empty(ArqvLog)
					//Criação do arquivo de erro
					CreatLog(@ArqvLog,oModelGFE,cProTable,'MATA030')
				EndIf
			EndIf
				//Fecha para poder incluir um novo registro
			oModelGFE:Deactivate()
			oModelGFE:Destroy()
			FreeObj(oModelGFE)
			FreeObj(oPrVldCAD)

		Case cProTable == "SA2"
			// Verifica se fornecedor já cadastrado como emitente para efetuar a alteração ou inclusão
			// Quando for uma alteração irá posicionar no registro de emitente.
			If GetOperGU3(cProTable,@nRecnoGU3)
				nOperacao := MODEL_OPERATION_UPDATE
				GU3->(dbGoTo(nRecnoGU3))
			EndIf
			//Carrega o model da rotina
			oModelGFE := FWLoadModel('GFEA015')

			//-- Suportabilidade (09/Nov/2022): Pré-Validações antes do MVC
			oPrVldCAD := JsonObject():New()
			oPrVldCAD["GU3_NRCID"]  := TMS120CDUF(SA2->A2_EST, '1')+SA2->A2_COD_MUN
			lRet := !FindFunction("GFEPreVld") .Or. GFEPreVld("GU3",@oPrVldCAD)
			//-- Fim - Suportabilidade: Pré-validações

			//Chama a opção de insert ou update do model
			If lRet
				oModelGFE:SetOperation(nOperacao) //Retorna operação de update caso ja esteja integrado
				oModelGFE:Activate()
				If nOperacao == MODEL_OPERATION_INSERT
					If lNumProp
						If lEAICodUnq
							oModelGFE:SetValue( 'GFEA015_GU3', 'GU3_CDEMIT', AllTrim(SA2->A2_COD) )
						Else
							oModelGFE:LoadValue( 'GFEA015_GU3', 'GU3_CDEMIT', 'ZZZZZZZZZ' )
						EndIf
					Else
						oModelGFE:SetValue( 'GFEA015_GU3', 'GU3_CDEMIT', IIf(SA2->A2_TIPO <> 'X',SA2->A2_CGC,AllTrim(SA2->A2_COD)+AllTrim(SA2->A2_LOJA)) )
					EndIf
				EndIf
				oModelGFE:SetValue( 'GFEA015_GU3', 'GU3_NMEMIT', SA2->A2_NOME )
				oModelGFE:SetValue( 'GFEA015_GU3', 'GU3_NMFAN' , SA2->A2_NREDUZ )
				oModelGFE:SetValue( 'GFEA015_GU3', 'GU3_NATUR' , SA2->A2_TIPO )
				oModelGFE:LoadValue( 'GFEA015_GU3', 'GU3_FORN'  , '1' )
				oModelGFE:LoadValue( 'GFEA015_GU3', 'GU3_EMFIL' , A030CLIFIL(SA2->A2_CGC) )
				oModelGFE:SetValue( 'GFEA015_GU3', 'GU3_ENDER' , SA2->A2_END )
				oModelGFE:SetValue( 'GFEA015_GU3', 'GU3_COMPL' , SA2->A2_COMPLEM )
				oModelGFE:SetValue( 'GFEA015_GU3', 'GU3_BAIRRO', SA2->A2_BAIRRO )
				oModelGFE:SetValue( 'GFEA015_GU3', 'GU3_CEP'   , SA2->A2_CEP )
				oModelGFE:SetValue( 'GFEA015_GU3', 'GU3_NRCID' , oPrVldCAD["GU3_NRCID"] )
				oModelGFE:SetValue( 'GFEA015_GU3', 'GU3_IDFED' , IIf(SA2->A2_TIPO <> 'X',SA2->A2_CGC, '') )
				oModelGFE:SetValue( 'GFEA015_GU3', 'GU3_IE'    , SA2->A2_INSCR )
				oModelGFE:SetValue( 'GFEA015_GU3', 'GU3_IM'    , SA2->A2_INSCRM )
				oModelGFE:SetValue( 'GFEA015_GU3', 'GU3_CXPOS' , SubStr(SA2->A2_CX_POST,1,10) )
				oModelGFE:SetValue( 'GFEA015_GU3', 'GU3_EMAIL' , SA2->A2_EMAIL )
				oModelGFE:SetValue( 'GFEA015_GU3', 'GU3_FONE1' , SubStr(SA2->A2_TEL,1,15) )
				oModelGFE:SetValue( 'GFEA015_GU3', 'GU3_FAX'   , SA2->A2_FAX )
				oModelGFE:SetValue( 'GFEA015_GU3', 'GU3_WSITE' , SA2->A2_HPAGE )
				oModelGFE:LoadValue( 'GFEA015_GU3', 'GU3_ORIGEM', '2' )
				oModelGFE:LoadValue( 'GFEA015_GU3', 'GU3_SIT'   , IIf(SA2->A2_MSBLQL == '1','2','1') )
				oModelGFE:SetValue( 'GFEA015_GU3', 'GU3_CONICM' , SA2->A2_CONTRIB )
				oModelGFE:SetValue( 'GFEA015_GU3', 'GU3_TPTRIB' , IIf(SA2->A2_SIMPNAC=='1','2','1') )

				If lNumProp
					oModelGFE:LoadValue( 'GFEA015_GU3', 'GU3_CDERP' , SA2->A2_COD )
					oModelGFE:LoadValue( 'GFEA015_GU3', 'GU3_CDCERP', SA2->A2_LOJA )
					oModelGFE:LoadValue( 'GFEA015_GU3', 'GU3_CDTERP', GFEM011TRP(SA2->A2_CGC, SA2->A2_INSCR) )
					oModelGFE:LoadValue( 'GFEA015_GU3', 'GU3_TRANSP', IsPJouPF('1','SA2') )
					oModelGFE:LoadValue( 'GFEA015_GU3', 'GU3_AUTON' , IsPJouPF('2','SA2') )

					If lGU3_ANTT
						cAliasSA4 := GetNextAlias()
						BeginSql Alias cAliasSA4
							SELECT SA4.A4_ANTT
							FROM %Table:SA4% SA4
							WHERE SA4.A4_FILIAL = %xFilial:SA4%
							AND SA4.A4_CGC = %Exp:GFEM011TRP(SA2->A2_CGC, SA2->A2_INSCR)%
							AND SA4.%NotDel%
						EndSql
						If (cAliasSA4)->(!Eof())
							oModelGFE:LoadValue( 'GFEA015_GU3', 'GU3_ANTT' ,(cAliasSA4)->A4_ANTT )
						Endif
						(cAliasSA4)->(dbCloseArea())
					EndIf
				EndIf
			EndIf

			//Valida os dados informados
			If lRet .And. oModelGFE:VldData()
				//Confirma
				oModelGFE:CommitData()
			Else
				If !Empty(oPrVldCAD["MSGERR"])
					oModelGFE:SetErrorMessage(,,,"GU3_NRCID",,"Pré-Validação GFE" + " - " + oPrVldCAD["MSGERR"],)
				EndIf
				If !Empty( SuperGetMv("MV_DRTLOG",.F.,"") ) .And. !Empty(ArqvLog)
					//Criação do arquivo de erro
					CreatLog(@ArqvLog,oModelGFE,cProTable,'MATA020')
				EndIf
			EndIf
			//Fecha para poder incluir um novo registro
			oModelGFE:Deactivate()
			oModelGFE:Destroy()
			FreeObj(oModelGFE)
			FreeObj(oPrVldCAD)

		Case cProTable == "DA3"
			// Verifica se veículo já cadastrado no cadatro de veículo para efetuar a alteração ou inclusão
			// Quando for uma alteração irá posicionar no registro de veículo.
			cAliasGU8 := GetNextAlias()
			BeginSql Alias cAliasGU8
				SELECT GU8.R_E_C_N_O_ RECNOGU8
				FROM %Table:GU8% GU8
				WHERE GU8.GU8_FILIAL = %xFilial:GU8%
				AND GU8.GU8_CDVEIC = %Exp:DA3->DA3_COD%
				AND GU8.GU8_SIT = '1'
				AND GU8.%NotDel%
			EndSql
			If (cAliasGU8)->(!Eof())
				nOperacao := MODEL_OPERATION_UPDATE
				GU8->(dbGoTo((cAliasGU8)->RECNOGU8))
			EndIf
			(cAliasGU8)->(dbCloseArea())

			//Carrega o model da rotina
			oModelGFE := FWLoadModel('GFEA046')
			//Chama a opção de insert ou update do model
			oModelGFE:SetOperation(nOperacao) //Retorna operação de update caso ja esteja integrado
			oModelGFE:Activate()

			oModelGFE:SetValue( 'GFEA046_GU8', 'GU8_FILIAL', xFilial("GU8") )
			oModelGFE:SetValue( 'GFEA046_GU8', 'GU8_CDVEIC', DA3->DA3_COD )
			oModelGFE:SetValue( 'GFEA046_GU8', 'GU8_CDTPVC', DA3->DA3_TIPVEI )
			oModelGFE:SetValue( 'GFEA046_GU8', 'GU8_PLACA' , DA3->DA3_PLACA )
			oModelGFE:SetValue( 'GFEA046_GU8', 'GU8_UFPLAC', DA3->DA3_ESTPLA )
			oModelGFE:SetValue( 'GFEA046_GU8', 'GU8_TPPROP', IIf(DA3->DA3_FROVEI == '1','2','1') )
			oModelGFE:SetValue( 'GFEA046_GU8', 'GU8_ALTUR' , DA3->DA3_ALTEXT )
			oModelGFE:SetValue( 'GFEA046_GU8', 'GU8_LARGUR', DA3->DA3_LAREXT )
			oModelGFE:SetValue( 'GFEA046_GU8', 'GU8_COMPRI', DA3->DA3_COMEXT )
			oModelGFE:SetValue( 'GFEA046_GU8', 'GU8_VOLUT' , DA3->DA3_VOLMAX )
			oModelGFE:SetValue( 'GFEA046_GU8', 'GU8_CARGUT', DA3->DA3_CAPACM )
			oModelGFE:SetValue( 'GFEA046_GU8', 'GU8_PBT'   , DA3->DA3_CAPACN )
			oModelGFE:SetValue( 'GFEA046_GU8', 'GU8_TARA'  , DA3->DA3_TARA )
			oModelGFE:SetValue( 'GFEA046_GU8', 'GU8_MMOD'  , DA3->DA3_DESC )
			oModelGFE:SetValue( 'GFEA046_GU8', 'GU8_ANOFAB', DA3->DA3_ANOFAB )
			oModelGFE:SetValue( 'GFEA046_GU8', 'GU8_RENAVA', PadR(DA3->DA3_RENAVA,Len(GU8->GU8_RENAVA)))
			If lGU8_CIV
				oModelGFE:SetValue( 'GFEA046_GU8', 'GU8_CIV'   , DA3->DA3_CIV )
				oModelGFE:SetValue( 'GFEA046_GU8', 'GU8_CIPP'  , DA3->DA3_CIPP )
			EndIf
			oModelGFE:LoadValue( 'GFEA046_GU8', 'GU8_SIT'  , DA3->DA3_ATIVO )
			oModelGFE:LoadValue( 'GFEA046_GU8', 'GU8_DSSIT', IIf(DA3->DA3_ATIVO == '1',STR0062,STR0063) ) // Veículo Ativo // Veículo Inativo
			oModelGFE:SetValue( 'GFEA046_GU8', 'GU8_CDPROP', GFEXINPROP(DA3->DA3_CODFOR,DA3->DA3_LOJFOR) )
			
			//Valida os dados informados
			If oModelGFE:VldData()
				//Confirma
				oModelGFE:CommitData()
			Else
				If !Empty( SuperGetMv("MV_DRTLOG",.F.,"") ) .And. !Empty(ArqvLog)
					//Criação do arquivo de erro
					CreatLog(@ArqvLog,oModelGFE,cProTable,'OMSA060')
				EndIf
			EndIf
				//Fecha para poder incluir um novo registro
			oModelGFE:Deactivate()
			oModelGFE:Destroy()
			
		Case cProTable == "DA4"
			// Verifica se motorista já cadastrado no cadatro de motoristas e ajudamtes para efetuar a alteração ou inclusão
			// Quando for uma alteração irá posicionar no registro de motoristas e ajudantes.
			cAliasGUU := GetNextAlias()
			BeginSql Alias cAliasGUU
				SELECT GUU.R_E_C_N_O_ RECNOGUU
				FROM %Table:GUU% GUU
				WHERE GUU.GUU_FILIAL = %Exp:DA4->DA4_FILIAL%
				AND GUU.GUU_CDMTR = %Exp:DA4->DA4_COD%
				AND GUU.GUU_SIT = '1'
				AND GUU.%NotDel%
			EndSql
			If (cAliasGUU)->(!Eof())
				nOperacao := MODEL_OPERATION_UPDATE
				GUU->(dbGoTo((cAliasGUU)->RECNOGUU))
			EndIf
			(cAliasGUU)->(dbCloseArea())
			
			//Carrega o model da rotina
			oModelGFE := FWLoadModel('GFEA012')
			//Chama a opção de insert ou update do model
			oModelGFE:SetOperation(nOperacao) //Retorna operação de update caso ja esteja integrado
			oModelGFE:Activate()

			oModelGFE:SetValue( 'GFEA012_GUU', 'GUU_FILIAL', DA4->DA4_FILIAL )
			oModelGFE:SetValue( 'GFEA012_GUU', 'GUU_CDMTR' , DA4->DA4_COD )
			oModelGFE:SetValue( 'GFEA012_GUU', 'GUU_NMMTR' , DA4->DA4_NOME )
			oModelGFE:SetValue( 'GFEA012_GUU', 'GUU_PSEUD' , DA4->DA4_NREDUZ )
			oModelGFE:SetValue( 'GFEA012_GUU', 'GUU_IDFED' , DA4->DA4_CGC )
			oModelGFE:SetValue( 'GFEA012_GUU', 'GUU_RG'    , DA4->DA4_RG )
			oModelGFE:SetValue( 'GFEA012_GUU', 'GUU_ORGEXP', DA4->DA4_RGORG )
			oModelGFE:SetValue( 'GFEA012_GUU', 'GUU_NUMCNH', DA4->DA4_NUMCNH )
			oModelGFE:SetValue( 'GFEA012_GUU', 'GUU_REGCNH', DA4->DA4_REGCNH )
			oModelGFE:SetValue( 'GFEA012_GUU', 'GUU_DTECNH', DA4->DA4_DTECNH )
			oModelGFE:SetValue( 'GFEA012_GUU', 'GUU_DTVCNH', DA4->DA4_DTVCNH )
			oModelGFE:SetValue( 'GFEA012_GUU', 'GUU_MUNCNH', DA4->DA4_MUNCNH )
			oModelGFE:SetValue( 'GFEA012_GUU', 'GUU_ESTCNH', DA4->DA4_ESTCNH )
			oModelGFE:SetValue( 'GFEA012_GUU', 'GUU_CATCNH', DA4->DA4_CATCNH )
			oModelGFE:SetValue( 'GFEA012_GUU', 'GUU_MOPP'  , DA4->DA4_CARPER )
			oModelGFE:SetValue( 'GFEA012_GUU', 'GUU_BITMAP', DA4->DA4_BITMAP )
			oModelGFE:LoadValue( 'GFEA012_GUU', 'GUU_SIT'  , IIF(DA4->DA4_BLQMOT == '1','2','1') )
			
			//Valida os dados informados
			If oModelGFE:VldData()
				//Confirma
				oModelGFE:CommitData()
			Else
				If !Empty( SuperGetMv("MV_DRTLOG",.F.,"") ) .And. !Empty(ArqvLog)
					//Criação do arquivo de erro
					CreatLog(@ArqvLog,oModelGFE,cProTable,'OMSA040')
				EndIf
			EndIf
				//Fecha para poder incluir um novo registro
			oModelGFE:Deactivate()
			oModelGFE:Destroy()

		Case cProTable == "SA4"
			// Verifica se fornecedor já cadastrado como emitente para efetuar a alteração ou inclusão
			// Quando for uma alteração irá posicionar no registro de emitente.
			If GetOperGU3(cProTable,@nRecnoGU3)
				nOperacao := MODEL_OPERATION_UPDATE
				GU3->(dbGoTo(nRecnoGU3))
			EndIf
			//Carrega o model da rotina
			oModelGFE := FWLoadModel('GFEA015')
			//Chama a opção de insert ou update do model
			oModelGFE:SetOperation(nOperacao) //Retorna operação de update caso ja esteja integrado
			oModelGFE:Activate()

			If nOperacao == MODEL_OPERATION_INSERT
				If FindFunction("GFECodEmit")
					cCodEmit := GFECodEmit(SA4->A4_COD, SA4->A4_EST, SA4->A4_CGC)
					oModelGFE:SetValue( 'GFEA015_GU3', 'GU3_CDEMIT', cCodEmit )
				Else
					oModelGFE:SetValue( 'GFEA015_GU3', 'GU3_CDEMIT', SA4->A4_CGC )
				EndIf
			EndIf
			oModelGFE:SetValue( 'GFEA015_GU3', 'GU3_NMEMIT', SA4->A4_NOME )
			oModelGFE:SetValue( 'GFEA015_GU3', 'GU3_NMFAN' , SA4->A4_NREDUZ )
			oModelGFE:SetValue( 'GFEA015_GU3', 'GU3_NATUR' , IIf(SA4->A4_TPTRANS == '3','F','J') )
			oModelGFE:LoadValue( 'GFEA015_GU3', 'GU3_TRANSP', IIf(SA4->A4_TPTRANS == '3','2','1') )
			oModelGFE:LoadValue( 'GFEA015_GU3', 'GU3_AUTON' , IIf(SA4->A4_TPTRANS == '3','1','2') )
			oModelGFE:SetValue( 'GFEA015_GU3', 'GU3_ENDER' , SA4->A4_END )
			oModelGFE:SetValue( 'GFEA015_GU3', 'GU3_COMPL' , SA4->A4_COMPLEM )
			oModelGFE:SetValue( 'GFEA015_GU3', 'GU3_BAIRRO', SA4->A4_BAIRRO )
			oModelGFE:SetValue( 'GFEA015_GU3', 'GU3_CEP'   , SA4->A4_CEP )
			oModelGFE:SetValue( 'GFEA015_GU3', 'GU3_NRCID' , TMS120CDUF(SA4->A4_EST,'1')+SA4->A4_COD_MUN )
			oModelGFE:SetValue( 'GFEA015_GU3', 'GU3_NMCID' , SA4->A4_MUN )
			oModelGFE:SetValue( 'GFEA015_GU3', 'GU3_UF'    , SA4->A4_EST )
			oModelGFE:SetValue( 'GFEA015_GU3', 'GU3_IDFED' , SA4->A4_CGC )
			oModelGFE:SetValue( 'GFEA015_GU3', 'GU3_IE'    , SA4->A4_INSEST )
			oModelGFE:SetValue( 'GFEA015_GU3', 'GU3_EMAIL' , SA4->A4_EMAIL )
			oModelGFE:SetValue( 'GFEA015_GU3', 'GU3_FONE1' , SA4->A4_TEL )
			oModelGFE:SetValue( 'GFEA015_GU3', 'GU3_WSITE' , SA4->A4_HPAGE )
			oModelGFE:LoadValue( 'GFEA015_GU3', 'GU3_ORIGEM', '2' )
			If lA4_MSBLQL
				oModelGFE:LoadValue( 'GFEA015_GU3', 'GU3_SIT'   , IIf(SA4->A4_MSBLQL == '1','2','1') )
			EndIf
			If lGU3_ANTT
				oModelGFE:SetValue( 'GFEA015_GU3', 'GU3_ANTT' ,SA4->A4_ANTT )
			EndIf
			
			//Valida os dados informados
			If oModelGFE:VldData()
				//Confirma
				oModelGFE:CommitData()
			Else
				If !Empty( SuperGetMv("MV_DRTLOG",.F.,"") ) .And. !Empty(ArqvLog)
					//Criação do arquivo de erro
					CreatLog(@ArqvLog,oModelGFE,cProTable,'MATA050')
				EndIf
			EndIf
				//Fecha para poder incluir um novo registro
			oModelGFE:Deactivate()
			oModelGFE:Destroy()
			
		Case cProTable == "CC2"
			// Monta código da cidade
			cCodMun := TMS120CDUF(CC2->CC2_EST,'1')+ CC2->CC2_CODMUN
			// Verifica se município já cadastrado no cadatro de cidades para efetuar a alteração ou inclusão
			// Quando for uma alteração irá posicionar no registro de cidades.
			cAliasGU7 := GetNextAlias()
			BeginSql Alias cAliasGU7
				SELECT GU7.R_E_C_N_O_ RECNOGU7
				FROM %Table:GU7% GU7
				WHERE GU7.GU7_FILIAL = %Exp:CC2->CC2_FILIAL%
				AND GU7.GU7_NRCID = %Exp:cCodMun%
				AND GU7.GU7_SIT = '1'
				AND GU7.%NotDel%
			EndSql
			If (cAliasGU7)->(!Eof())
				nOperacao := MODEL_OPERATION_UPDATE
				GU7->(dbGoTo((cAliasGU7)->RECNOGU7))
			EndIf
			(cAliasGU7)->(dbCloseArea())
			
			//Carrega o model da rotina
			oModelGFE := FWLoadModel('GFEA020')
			//Chama a opção de insert ou update do model
			oModelGFE:SetOperation(nOperacao) //Retorna operação de update caso ja esteja integrado
			oModelGFE:Activate()

			oModelGFE:SetValue( 'GFEA020_GU7', 'GU7_FILIAL', CC2->CC2_FILIAL )
			oModelGFE:SetValue( 'GFEA020_GU7', 'GU7_NRCID' , cCodMun )
			oModelGFE:SetValue( 'GFEA020_GU7', 'GU7_NMCID' , SubStr(CC2->CC2_MUN,1,50) )
			oModelGFE:SetValue( 'GFEA020_GU7', 'GU7_CDUF'  , CC2->CC2_EST )
			oModelGFE:SetValue( 'GFEA020_GU7', 'GU7_CDPAIS', '105' )
			
			//Valida os dados informados
			If oModelGFE:VldData()
				//Confirma
				oModelGFE:CommitData()
			Else
				If !Empty( SuperGetMv("MV_DRTLOG",.F.,"") ) .And. !Empty(ArqvLog)
					//Criação do arquivo de erro
					CreatLog(@ArqvLog,oModelGFE,cProTable,'FISA010')
				EndIf
			EndIf
				//Fecha para poder incluir um novo registro
			oModelGFE:Deactivate()
			oModelGFE:Destroy()
			
		Case cProTable == "DUT"
			// Verifica se tipo de veículo já cadastrado no cadatro de tipos de veículos para efetuar a alteração ou inclusão
			// Quando for uma alteração irá posicionar no registro de tipos de veículos.
			cAliasGV3 := GetNextAlias()
			BeginSql Alias cAliasGV3
				SELECT GV3.R_E_C_N_O_ RECNOGV3
				FROM %Table:GV3% GV3
				WHERE GV3.GV3_FILIAL = %Exp:DUT->DUT_FILIAL%
				AND GV3.GV3_CDTPVC = %Exp:DUT->DUT_TIPVEI%
				AND GV3.GV3_SIT = '1'
				AND GV3.%NotDel%
			EndSql
			If (cAliasGV3)->(!Eof())
				nOperacao := MODEL_OPERATION_UPDATE
				GV3->(dbGoTo((cAliasGV3)->RECNOGV3))
			EndIf
			(cAliasGV3)->(dbCloseArea())
			
			//Carrega o model da rotina
			oModelGFE := FWLoadModel('GFEA045')
			//Chama a opção de insert ou update do model
			oModelGFE:SetOperation(nOperacao) //Retorna operação de update caso ja esteja integrado
			oModelGFE:Activate()

			oModelGFE:SetValue( 'GFEA045_GV3', 'GV3_FILIAL', DUT->DUT_FILIAL )
			oModelGFE:SetValue( 'GFEA045_GV3', 'GV3_CDTPVC', DUT->DUT_TIPVEI )
			oModelGFE:SetValue( 'GFEA045_GV3', 'GV3_DSTPVC', DUT->DUT_DESCRI )
			If DUT->DUT_CATVEI $ '36'
				oModelGFE:SetValue( 'GFEA045_GV3', 'GV3_POSCOM','2' )
			Else
				oModelGFE:SetValue( 'GFEA045_GV3', 'GV3_POSCOM','1' )
			EndIf

			//Valida os dados informados
			If oModelGFE:VldData()
				//Confirma
				oModelGFE:CommitData()
			Else
				If !Empty( SuperGetMv("MV_DRTLOG",.F.,"") ) .And. !Empty(ArqvLog)
					//Criação do arquivo de erro
					CreatLog(@ArqvLog,oModelGFE,cProTable,'TMSA530')
				EndIf
			EndIf
				//Fecha para poder incluir um novo registro
			oModelGFE:Deactivate()
			oModelGFE:Destroy()

		Case cProTable == "CTT"
			// Verifica se centro de custo já cadastrado no cadatro de centros de custos para efetuar a alteração ou inclusão
			// Quando for uma alteração irá posicionar no registro de centros de custos.
			cAliasGUH := GetNextAlias()
			BeginSql Alias cAliasGUH
				SELECT GUH.R_E_C_N_O_ RECNOGUH
				FROM %Table:GUH% GUH
				WHERE GUH.GUH_FILIAL = %Exp:CTT->CTT_FILIAL%
				AND GUH.GUH_CCUSTO = %Exp:CTT->CTT_CUSTO%
				AND GUH.GUH_SIT = '1'
				AND GUH.%NotDel%
			EndSql
			If (cAliasGUH)->(!Eof())
				nOperacao := MODEL_OPERATION_UPDATE
				GUH->(dbGoTo((cAliasGUH)->RECNOGUH))
			EndIf
			(cAliasGUH)->(dbCloseArea())

			//Carrega o model da rotina
			oModelGFE := FWLoadModel('GFEA089')
			//Chama a opção de insert ou update do model
			oModelGFE:SetOperation(nOperacao) //Retorna operação de update caso ja esteja integrado
			oModelGFE:Activate()

			oModelGFE:SetValue( 'GFEA089_GUH', 'GUH_FILIAL', CTT->CTT_FILIAL )
			oModelGFE:SetValue( 'GFEA089_GUH', 'GUH_CCUSTO', CTT->CTT_CUSTO )
			oModelGFE:SetValue( 'GFEA089_GUH', 'GUH_DESC'  , CTT->CTT_DESC01 )
			
			//Valida os dados informados
			If oModelGFE:VldData()
				//Confirma
				oModelGFE:CommitData()
			Else
				If !Empty( SuperGetMv("MV_DRTLOG",.F.,"") ) .And. !Empty(ArqvLog)
					//Criação do arquivo de erro
					CreatLog(@ArqvLog,oModelGFE,cProTable,'CTBA030')
				EndIf
			EndIf
				//Fecha para poder incluir um novo registro
			oModelGFE:Deactivate()
			oModelGFE:Destroy()

		Case cProTable == "CT1"
			// Verifica se plano de contas já cadastrado no cadatro de conta contabil para efetuar a alteração ou inclusão
			// Quando for uma alteração irá posicionar no registro de conta contabil.
			cAliasGUE := GetNextAlias()
			BeginSql Alias cAliasGUE
				SELECT GUE.R_E_C_N_O_ RECNOGUE
				FROM %Table:GUE% GUE
				WHERE GUE.GUE_FILIAL = %Exp:CT1->CT1_FILIAL%
				AND GUE.GUE_CTACTB = %Exp:CT1->CT1_CONTA%
				AND GUE.GUE_SIT = '1'
				AND GUE.%NotDel%
			EndSql
			If (cAliasGUE)->(!Eof())
				nOperacao := MODEL_OPERATION_UPDATE
				GUE->(dbGoTo((cAliasGUE)->RECNOGUE))
			EndIf
			(cAliasGUE)->(dbCloseArea())
			
			//Carrega o model da rotina
			oModelGFE := FWLoadModel('GFEA090')
			//Chama a opção de insert ou update do model
			oModelGFE:SetOperation(nOperacao) //Retorna operação de update caso ja esteja integrado
			oModelGFE:Activate()

			oModelGFE:SetValue( 'GFEA090_GUE', 'GUE_FILIAL', CT1->CT1_FILIAL )
			oModelGFE:SetValue( 'GFEA090_GUE', 'GUE_CTACTB', CT1->CT1_CONTA )
			oModelGFE:SetValue( 'GFEA090_GUE', 'GUE_TITULO', CT1->CT1_DESC01 )
			
			//Valida os dados informados
			If oModelGFE:VldData()
				//Confirma
				oModelGFE:CommitData()
			Else
				If !Empty( SuperGetMv("MV_DRTLOG",.F.,"") ) .And. !Empty(ArqvLog)
					//Criação do arquivo de erro
					CreatLog(@ArqvLog,oModelGFE,cProTable,'CTBA020')
				EndIf
			EndIf
				//Fecha para poder incluir um novo registro
			oModelGFE:Deactivate()
			oModelGFE:Destroy()

		Case cProTable == "DAK"
			GFEM011DAK("TODOS",,,cProTable,'OMSA200',ArqvLog)

		Case cProTable == "SF2"
			GFEM011NFS("TODOS",,,cProTable,'MATA461',ArqvLog)

		Case cProTable == "SF1"
			GFEM011NFE("TODOS",,,cProTable,'MATA103',ArqvLog,.T.)

		Case cProTable == "DFT"
			GFEM011TMS("TODOS",,,,cProTable,'TMSAR05',ArqvLog)
	EndCase

	RestArea(aAreaAnt)
Return Nil

//---------------------------------------------------
/*/Verifica se Cliente/Transportador/Fornecedor altera a tabela GU3
@author Felipe Machado de Oliveira
@version P11
@since 11/06/2013
/*/
//---------------------------------------------------
Function GFEM011DAK(cTipoInter,aDados,aDadosItens,cProTable,cRotiProt,ArqvLog,lCommit)
	Local lNumProp   := GFEEMITMP()
	Local oModelGFE  := Nil
	Local cAliasDAI  := Nil
	Local cAliasGU3  := Nil
	Local cAliasSA4  := Nil
	Local cAliasDA3  := Nil
	Local cTransp    := DAK->DAK_TRANSP
	Local cCdTpVc    := ""
	Local cCgcTransp := ""
	Local cPlaca     := ""
	Local cPlacaM    := ""
	Local cPlacaT    := ""
	Local nOperacao  := MODEL_OPERATION_INSERT

	// Carrega a transportadora da carga
	If Empty(cTransp)
		// Busca transportadora do pedido
		cAliasDAI := GetNextAlias()
		BeginSql Alias cAliasDAI
			SELECT DAI.DAI_PEDIDO, SC5.C5_TRANSP
			FROM %Table:DAI% DAI
			INNER JOIN %Table:SC5% SC5
			ON SC5.C5_FILIAL = %xFilial:SC5%
			AND SC5.C5_NUM = DAI.DAI_PEDIDO
			AND SC5.%NotDel%
			WHERE DAI.DAI_FILIAL = %xFilial:DAI%
			AND DAI.DAI_COD = %Exp:DAK->DAK_COD%
			AND DAI.DAI_SEQCAR = %Exp:DAK->DAK_SEQCAR%
			AND DAI.%NotDel%
			GROUP BY DAI.DAI_PEDIDO, SC5.C5_TRANSP
		EndSql
		If (cAliasDAI)->(!Eof())
			cTransp := (cAliasDAI)->C5_TRANSP
		EndIf
		(cAliasDAI)->(dbCloseArea())
	EndIf

	If !Empty(cTransp)
		If lNumProp
			cAliasGU3 := GetNextAlias()
			BeginSql Alias cAliasGU3
				SELECT GU3.GU3_CDEMIT
				FROM %Table:GU3% GU3
				WHERE GU3.GU3_FILIAL = %xFilial:GU3% 
				AND GU3.GU3_CDTERP = %Exp:cTransp%
				AND GU3.GU3_SIT = '1'
				AND GU3.%NotDel%
			EndSql
			If (cAliasGU3)->(!Eof())
				cCgcTransp := (cAliasGU3)->GU3_CDEMIT
			Else
				cAliasSA4 := GetNextAlias()
				BeginSql Alias cAliasSA4
					SELECT SA4.A4_CGC, SA4.A4_INSEST, GU3.GU3_CDEMIT
					FROM %Table:SA4% SA4
					INNER JOIN %Table:GU3% GU3
					ON GU3.GU3_FILIAL = %xFilial:GU3% 
					AND GU3.GU3_IDFED = SA4.A4_CGC
					AND GU3.GU3_IE = SA4.A4_INSEST
					AND GU3.GU3_SIT = '1'
					AND GU3.GU3_TRANSP = '1'
					AND GU3.%NotDel%
					WHERE SA4.A4_FILIAL = %xFilial:SA4%
					AND SA4.A4_COD = %Exp:cTransp%
					AND SA4.%NotDel%
				EndSql
				If (cAliasSA4)->(!Eof())
					cCgcTransp := (cAliasSA4)->GU3_CDEMIT
				EndIf
				(cAliasSA4)->(dbCloseArea())
			EndIf
			(cAliasGU3)->(dbCloseArea())
		Else
			cAliasSA4 := GetNextAlias()
			BeginSql Alias cAliasSA4
				SELECT GU3.GU3_CDEMIT
				FROM %Table:SA4% SA4
				INNER JOIN %Table:GU3% GU3
				ON GU3.GU3_FILIAL = %xFilial:GU3% 
				AND GU3.GU3_CDEMIT = SA4.A4_CGC
				AND GU3.GU3_SIT = '1'
				AND GU3.%NotDel%
				WHERE SA4.A4_FILIAL = %xFilial:SA4%
				AND SA4.A4_COD = %Exp:cTransp%
				AND SA4.%NotDel%
			EndSql
			If (cAliasSA4)->(!Eof())
				cCgcTransp := (cAliasSA4)->GU3_CDEMIT
			EndIf
			(cAliasSA4)->(dbCloseArea())
		EndIf
	EndIf
	// Busca dados da placa
	If !Empty(DAK->DAK_CAMINH)
		cAliasDA3 := GetNextAlias()
		BeginSql Alias cAliasDA3
			SELECT DA3.DA3_TIPVEI,
					DA3.DA3_PLACA
			FROM %Table:DA3% DA3
			WHERE DA3.DA3_FILIAL = %xFilial:DA3%
			AND DA3.DA3_COD = %Exp:DAK->DAK_CAMINH%
			AND DA3.%NotDel%
		EndSql
		If (cAliasDA3)->(!Eof())
			cCdTpVc := (cAliasDA3)->DA3_TIPVEI
			cPlaca  := (cAliasDA3)->DA3_PLACA
		EndIf
		(cAliasDA3)->(dbCloseArea())
	EndIf
	// Busca dados da 2ª Placa
	If !Empty(DAK->DAK_VEIC2)
		cAliasDA3 := GetNextAlias()
		BeginSql Alias cAliasDA3
			SELECT DA3.DA3_TIPVEI,
					DA3.DA3_PLACA
			FROM %Table:DA3% DA3
			WHERE DA3.DA3_FILIAL = %xFilial:DA3%
			AND DA3.DA3_COD = %Exp:DAK->DAK_VEIC2%
			AND DA3.%NotDel%
		EndSql
		If (cAliasDA3)->(!Eof())
			cPlacaM := (cAliasDA3)->DA3_PLACA
		EndIf
		(cAliasDA3)->(dbCloseArea())
	EndIf
	// Busca dados da 3ª Placa
	If !Empty(DAK->DAK_VEIC3)
		cAliasDA3 := GetNextAlias()
		BeginSql Alias cAliasDA3
			SELECT DA3.DA3_TIPVEI,
					DA3.DA3_PLACA
			FROM %Table:DA3% DA3
			WHERE DA3.DA3_FILIAL = %xFilial:DA3%
			AND DA3.DA3_COD = %Exp:DAK->DAK_VEIC3%
			AND DA3.%NotDel%
		EndSql
		If (cAliasDA3)->(!Eof())
			cPlacaT := (cAliasDA3)->DA3_PLACA
		EndIf
		(cAliasDA3)->(dbCloseArea())
	EndIf

	//Carrega o model da rotina
	oModelGFE := FWLoadModel('GFEA050')
	//Chama a opção de insert ou update do model
	oModelGFE:SetOperation(nOperacao) //Retorna operação de update caso ja esteja integrado
	oModelGFE:Activate()

	oModelGFE:SetValue( 'GFEA050_GWN', 'GWN_FILIAL' , DAK->DAK_FILIAL )
	oModelGFE:SetValue( 'GFEA050_GWN', 'GWN_NRROM ' , DAK->DAK_COD+DAK->DAK_SEQCAR )
	oModelGFE:LoadValue( 'GFEA050_GWN', 'GWN_ORI'   , '2' )
	oModelGFE:SetValue( 'GFEA050_GWN', 'GWN_CDMTR'  , DAK->DAK_MOTORI )
	oModelGFE:SetValue( 'GFEA050_GWN', 'GWN_CDTPVC' , cCdTpVc )
	oModelGFE:SetValue( 'GFEA050_GWN', 'GWN_PLACAD' , cPlaca )
	oModelGFE:SetValue( 'GFEA050_GWN', 'GWN_PLACAM' , cPlacaM )
	oModelGFE:SetValue( 'GFEA050_GWN', 'GWN_PLACAT' , cPlacaT )
	oModelGFE:SetValue( 'GFEA050_GWN', 'GWN_CDTPOP' , DAK->DAK_CDTPOP )
	oModelGFE:SetValue( 'GFEA050_GWN', 'GWN_CDCLFR' , DAK->DAK_CDCLFR )
	oModelGFE:SetValue( 'GFEA050_GWN', 'GWN_CDTRP'  , cCGCTransp )
	oModelGFE:SetValue( 'GFEA050_GWN', 'GWN_DTIMPL' , DAK->DAK_DATA )
	oModelGFE:SetValue( 'GFEA050_GWN', 'GWN_HRIMPL' , SubStr(DAK->DAK_HORA,1,5) )
	
	//Valida os dados informados
	If oModelGFE:VldData()
		//Confirma
		oModelGFE:CommitData()

		OMSA200IRM(DAK->DAK_COD,DAK->DAK_SEQCAR,cCGCTransp)	// Refaz associação de numero do romaneio com o documento de carga
	Else
		If !Empty( SuperGetMv("MV_DRTLOG",.F.,"") ) .And. !Empty(ArqvLog)
			//Criação do arquivo de erro
			CreatLog(@ArqvLog,oModelGFE,cProTable,'OMSA200')
		EndIf
	EndIf
	//Fecha para poder incluir um novo registro
	oModelGFE:Deactivate()
	oModelGFE:Destroy(oModelGFE)
Return

//---------------------------------------------------
/*/Verifica se Cliente/Transportador/Fornecedor altera a tabela GU3
@author Felipe Machado de Oliveira
@version P11
@since 11/06/2013
/*/
//---------------------------------------------------
Static Function GetOperGU3(cProTable,nRecnoGU3)
	Local lRet      := .F.
	Local lNumProp  := GFEEMITMP()
	Local cCdEmit   := ""
	Local cAliasGU3 := Nil
	Local cWhere    := ""
	Local cWhereGU3 := ""
	
	nRecnoGU3 := 0
	Do Case
		Case cProTable == "SA1"
			If !lNumProp
				cCdEmit := IIF(SA1->A1_TIPO <> 'X',SA1->A1_CGC,AllTrim(SA1->A1_COD)+AllTrim(SA1->A1_LOJA) )
			Else
				cCdEmit := GFEM011COD(SA1->A1_COD,SA1->A1_LOJA,1,,)
				// Para validar se é cliente
				cWhere += "	GU3.GU3_FORN = '2'"
				cWhere += "	AND GU3.GU3_CLIEN = '1'"
			EndIf

		Case cProTable == "SA2"
			If !lNumProp
				cCdEmit := IIF(SA2->A2_TIPO <> 'X',SA2->A2_CGC,AllTrim(SA2->A2_COD)+AllTrim(SA2->A2_LOJA) )
			Else
				cCdEmit := GFEM011COD(SA2->A2_COD,SA2->A2_LOJA,2,,)
				// Para validar se é fornecedor
				cWhere += "	GU3.GU3_CLIEN = '2'"
				cWhere += "	AND GU3.GU3_FORN = '1'"
			EndIf

		Case cProTable == "SA4"
			If SA4->A4_EST == "EX" .And. Empty(SA4->A4_CGC)
				cCdEmit := SA4->A4_COD
			Else
				cCdEmit := SA4->A4_CGC
			EndIf
			// Para validar se é fornecedor
			cWhere := "	GU3.GU3_SIT = '1'"
			cWhere += "	AND GU3.GU3_CLIEN = '2'"
			cWhere += "	AND GU3.GU3_FORN = '1'"
	EndCase

	cWhereGU3 := "%"+cWhere+"%"
	cAliasGU3 := GetNextAlias()

	If (!lNumProp .And. (cProTable == "SA1" .Or. cProTable == "SA2"))

		BeginSql Alias cAliasGU3
			SELECT GU3.R_E_C_N_O_ RECNOGU3
			FROM %Table:GU3% GU3
			WHERE GU3.GU3_FILIAL = %xFilial:GU3%
			AND GU3.GU3_CDEMIT = %Exp:cCdEmit%
			AND GU3.%NotDel%
		EndSql

	Else

		BeginSql Alias cAliasGU3
			SELECT GU3.R_E_C_N_O_ RECNOGU3
			FROM %Table:GU3% GU3
			WHERE GU3.GU3_FILIAL = %xFilial:GU3%
			AND GU3.GU3_CDEMIT = %Exp:cCdEmit%
			AND %Exp:cWhereGU3%
			AND GU3.%NotDel%
		EndSql	

	EndIf

	If (cAliasGU3)->(!Eof())
		nRecnoGU3 := (cAliasGU3)->RECNOGU3
		lRet := .T.
	EndIf
	(cAliasGU3)->(dbCloseArea())
Return lRet
//---------------------------------------------------
/*/Criação do arquivo de erros da integração
@author Felipe Machado de Oliveira
@version P11
@since 11/06/2013
/*/
//---------------------------------------------------
Static Function CreatLog(ArqvLog,oModelGFE,cProTable,cRotiProt, aDadosSF1)
Local aPriKeys := {}

Default aDadosSF1 := {}

Do Case
	Case cProTable == "SA1"
		Aadd(aPriKeys, {SA1->A1_COD,"A1_COD     = "})
		Aadd(aPriKeys, {SA1->A1_LOJA,"A1_LOJA    = "})

	Case cProTable == "SA2"
		Aadd(aPriKeys, {SA2->A2_COD,"A2_COD     = "})
		Aadd(aPriKeys, {SA2->A2_LOJA,"A2_LOJA    = "})

	Case cProTable == "DA3"
		Aadd(aPriKeys, {DA3->DA3_COD,"DA3_COD    = "})
		Aadd(aPriKeys, {"   ","             "})

	Case cProTable == "DA4"
		Aadd(aPriKeys, {DA4->DA4_COD,"DA4_COD    = "})
		Aadd(aPriKeys, {"   ","             "})

	Case cProTable == "SA4"
		Aadd(aPriKeys, {SA4->A4_COD,"A4_COD     = "})
		Aadd(aPriKeys, {"   ","             "})

	Case cProTable == "CC2"
		Aadd(aPriKeys, {CC2->CC2_EST,"CC2_EST    = "})
		Aadd(aPriKeys, {CC2->CC2_CODMUN,"CC2_CODMUN = "})

	Case cProTable == "DUT"
		Aadd(aPriKeys, {DUT->DUT_TIPVEI,"DUT_TIPVEI = "})
		Aadd(aPriKeys, {DUT->DUT_DESCRI,"DUT_DESCRI = "})

	Case cProTable == "CTT"
		Aadd(aPriKeys, {CTT->CTT_CUSTO,"CTT_CUSTO  = "})
		Aadd(aPriKeys, {"   ","             "})

	Case cProTable == "CT1"
		Aadd(aPriKeys, {CT1->CT1_CONTA,"CT1_CONTA  = "})
		Aadd(aPriKeys, {"   ","             "})

	Case cProTable == "DAK"
		Aadd(aPriKeys, {DAK->DAK_COD,"DAK_COD    = "})
		Aadd(aPriKeys, {DAK->DAK_SEQCAR,"DAK_SEQCAR = "})

	Case cProTable == "SF2"
		Aadd(aPriKeys, {SF2->F2_DOC,"F2_DOC     = "})
		Aadd(aPriKeys, {SF2->F2_SERIE,"F2_SERIE   = "})
		Aadd(aPriKeys, {SF2->F2_CLIENTE,"F2_CLIENTE = "})
		Aadd(aPriKeys, {SF2->F2_LOJA,"F2_LOJA    = "})

	Case cProTable == "SF1"
		Aadd(aPriKeys, {aDadosSF1[3],"F1_DOC     = "})
		Aadd(aPriKeys, {aDadosSF1[4],"F1_SERIE   = "})
		Aadd(aPriKeys, {aDadosSF1[6],"F1_FORNECE = "})
		Aadd(aPriKeys, {aDadosSF1[7],"F1_LOJA    = "})

	Case cProTable == "DFT"
		Aadd(aPriKeys, {DFT->DFT_NUMRED,"DFT_NUMRED    = "})
		Aadd(aPriKeys, {DFT->DFT_CODFOR,"DFT_CODFOR    = "})
		Aadd(aPriKeys, {DFT->DFT_LOJFOR,"DFT_LOJFOR    = "})
EndCase

ArqvLog:Add("|"+AllTrim(cRotiProt)+" |"+aPriKeys[1][2]+SubStr(AllTrim(aPriKeys[1][1])+Space(27 -(Len( AllTrim(aPriKeys[1][1]) )) ),1,40)+"|"+AllTrim(oModelGFE:GetErrorMessage()[4]) + Space(10 - (Len( AllTrim(oModelGFE:GetErrorMessage()[4]) )))+" |"+SubStr(oModelGFE:GetErrorMessage()[6],1,57))

If !Empty(aPriKeys[2][2]) .Or. !Empty(SubStr(oModelGFE:GetErrorMessage()[6],58,117))
	ArqvLog:Add("|        |"+aPriKeys[2][2]+SubStr(AllTrim(aPriKeys[2][1])+Space(27 -(Len( AllTrim(aPriKeys[2][1]) )) ),1,40)+"|           |"+SubStr(oModelGFE:GetErrorMessage()[6],58,117))
EndIf

If cProTable == "SF1" .Or. cProTable == "SF2"
	ArqvLog:Add("|        |"+aPriKeys[3][2]+SubStr(AllTrim(aPriKeys[3][1])+Space(27 -(Len( AllTrim(aPriKeys[3][1]) )) ),1,40)+"|           |"+SubStr(oModelGFE:GetErrorMessage()[6],118,177))
	ArqvLog:Add("|        |"+aPriKeys[4][2]+SubStr(AllTrim(aPriKeys[4][1])+Space(27 -(Len( AllTrim(aPriKeys[4][1]) )) ),1,40)+"|           |"+SubStr(oModelGFE:GetErrorMessage()[6],178,317))
EndIf

ArqvLog:Add(cMsgErro)
ArqvLog:Add("------------------------------------------------------------------------------------------------------------------------")
ArqvLog:Save()

Return Nil

//---------------------------------------------------
/*/Intregração de Notas Fiscais
@author Felipe Machado de Oliveira
@version P11
@since 30/04/2013
/*/
//---------------------------------------------------
Function GFEM011NFS(cTipoInter,cNumNFS,cSerieNFS,cProTable,cRotiProt,ArqvLog)
Local aAreaGW1   := GW1->( GetArea() )
Local aAreaGW8   := GW8->( GetArea() )
Local aAreaGWU   := GWU->( GetArea() )
Local aAreaSA2   := SA2->( GetArea() )
Local aAreaSA1 	 := SA1->( GetArea() )
Local lRet 	 	 := .T.
Local oModelNFS  := FWLoadModel("GFEA044")
Local nI 	 	 := 1
Local oModelItens:= oModelNFS:GetModel('GFEA044_GW8')
Local oModelTrechos := oModelNFS:GetModel('GFEA044_GWU')
Local oModelUnit := oModelNFS:GetModel('GFEA044_GWB')
Local cA1_CGC 	 := ""
Local cA1_EST 	 := ""
Local cA1_COD_MUN:= ""
Local cA2_CGC 	 := ""
Local cA2_TIPO 	 := ""
Local cA2_COD_MUN:= ""
Local cA2_EST 	 := ""
Local cF2_CDTPDC := ""
Local lPula 	 := .F.
Local cEmisDc 	 := ""
Local cRemeDc 	 := ""
Local nAltura 	 := 0
Local nVolume 	 := 0
Local nVolTot 	 := 0
Local nVolSld 	 := 0
Local nRatTot 	 := 0
Local cDsitem 	 := ""
Local nPesor  	 := 0
Local cGW1_AUTSEF:= ""
Local cA1_ESTE 	 := ""
Local cA1_CODMUNE:= ""
Local cCfop 	 := ""
Local lNumProp 	 := GFEEMITMP()
Local cA1_COD 	 := ""
Local cA1_LOJA 	 := ""
Local cA2_COD 	 := ""
Local cA2_LOJA 	 := ""
Local cF2_TPFRETE:= ""
Local aStru 	 := {}
Local nStruVolQtd:= 0
Local nX		 := 1
Local nLine 	 := 1
Local cCdClFrete := SuperGetMv("MV_CDCLFR",.F.,"")
Local lOm11clf   := ExistBlock("OM11CLF")
Local lClEnt     := .F.
Local cBairroEnt := ''
Local cCepEnt    := ''
Local cNrcEnt    := ''
Local cEndEnt    := ''
Local cCodMun    := ''
Local lOMSM0111  := ExistBlock("OMSM0111")
Local lOMSM0113  := ExistBlock("OMSM0113")
Local lOMSM0114  := ExistBlock("OMSM0114")
Local lOMSM0115  := ExistBlock("OMSM0115")
Local cGFEVlIt   := SuperGetMv('MV_GFEVLIT',.F.,"1")
Local cGFEVolU   := SuperGetMv('MV_GFEVOLU',.F.,"2")
Local cCriRat    := SuperGetMv("MV_CRIRAT",.F.,"1")
Local cGUKITEM   := ''
Local cCliRem    := ''
Local cLojaRem   := ''
Local cEspNFS    := ''
Local oPrVldNFS
Local nSumPesoRnd:= 0
Local nDifSum    := 0
Local cGFERPB    := SuperGetMv("MV_GFERPB",.F.,"0")  //Tipo de Rateio do Peso Bruto

Private lGfeCTrib := SuperGetMv("MV_GFECTRI",,.F.)

Default cTipoInter := "TODOS"
Default cNumNFS    := ""
Default cSerieNFS  := ""

If cTipoInter <> "TODOS"
	lPula := .T.

	If SF2->F2_FILIAL == xFilial("SF2") .And. ;
	   AllTrim(SF2->F2_DOC) == AllTrim(cNumNFS) .And. ;
	   AllTrim(SF2->F2_SERIE) == AllTrim(cSerieNFS)
		//Não faz a integração caso seja nota de complemento de Preço/ICMS/IPI
		If (SF2->F2_TIPO $ "CIP")
			lPula := .T.
		Else
			lPula := .F.
		EndIf
	EndIf

EndIf

aStru := SF2->(DbStruct())

For nX := 1 To Len(aStru)

	If "F2_VOLUME" $ aStru[nX,1]
		nStruVolQtd++
	EndIf

Next

If !lPula
	cF2_CDTPDC := Posicione("SX5",1,xFilial("SX5")+"MQ"+AllTrim(SF2->F2_TIPO)+"S","X5_DESCRI")

	If Empty(cF2_CDTPDC)
		cF2_CDTPDC := Posicione("SX5",1,xFilial("SX5")+"MQ"+AllTrim(SF2->F2_TIPO),"X5_DESCRI")
	EndIf

	cF2_CDTPDC := SubStr(cF2_CDTPDC,1,TamSx3("GW1_CDTPDC")[1])

	cEmisDc := GFEM011COD(,,,.T.,xFilial("SF2"))

	cRemeDc := cEmisDc
	//Se cliente retirada estiver preenchido, o utilizará como remetente
	If SF2->(ColumnPos("F2_CLIRET")) > 0 .And. SF2->(ColumnPos("F2_LOJARET")) > 0 .And. !Empty(SF2->F2_CLIRET) .And. !Empty(SF2->F2_LOJARET)
		If lNumProp
			cRemeDc := GFEM011COD(SF2->F2_CLIRET,SF2->F2_LOJARET,1)
		Else
			//buscar pelo CGC na A1
			cAliasQry := GetNextAlias()
			BeginSql Alias cAliasQry
			SELECT SA1.A1_CGC
			FROM %Table:SA1% SA1
			WHERE SA1.A1_FILIAL = %xFilial:SA1%
			AND SA1.A1_COD = %Exp:SF2->F2_CLIRET%
			AND SA1.A1_LOJA = %Exp:SF2->F2_LOJARET%
			AND SA1.%NotDel%
			EndSql

			If (cAliasQry)->(!Eof())
				cRemeDc := (cAliasQry)->A1_CGC
			EndIf
			(cAliasQry)->(dbCloseArea())
		EndIf
	EndIf

	If GFXCP12127('F2_CLIREM') .And. !Empty(SF2->F2_CLIREM) .And. !Empty(SF2->F2_LOJAREM)
		cCliRem  := SF2->F2_CLIREM
		cLojaRem := SF2->F2_LOJAREM
		lClEnt := .T.
	Else
		If !Empty(SF2->F2_CLIENT) .AND. !Empty(SF2->F2_LOJENT) ;
			.AND. (AllTrim(SF2->F2_CLIENT) <> AllTrim(SF2->F2_CLIENTE) ;
			.OR. AllTrim(SF2->F2_LOJA) <> AllTrim(SF2->F2_LOJENT))
			cCliRem  := SF2->F2_CLIENT
			cLojaRem := SF2->F2_LOJENT
			lClEnt := .T.
		EndIf
	EndIf
	If SF2->F2_TIPO $ "DB"
		cAliasQry := GetNextAlias()
		BeginSql Alias cAliasQry
			SELECT SA2.A2_COD,
					SA2.A2_LOJA,
					SA2.A2_CGC,
					SA2.A2_TIPO,
					SA2.A2_EST,
					SA2.A2_COD_MUN
			FROM %Table:SA2% SA2
			WHERE SA2.A2_FILIAL = %xFilial:SA2%
			AND SA2.A2_COD = %Exp:SF2->F2_CLIENTE%
			AND SA2.A2_LOJA = %Exp:SF2->F2_LOJA%
			AND SA2.%NotDel%
		EndSql
		
		If (cAliasQry)->(!Eof())
			If (cAliasQry)->A2_TIPO == "X"
				cA2_CGC := AllTrim((cAliasQry)->A2_COD)+AllTrim((cAliasQry)->A2_LOJA)
				cA2_CGC := PadR( cA2_CGC, Len((cAliasQry)->A2_CGC))
			Else
				cA2_CGC := (cAliasQry)->A2_CGC
			EndIf

			cA2_COD     := (cAliasQry)->A2_COD
			cA2_LOJA    := (cAliasQry)->A2_LOJA
			cA2_TIPO    := (cAliasQry)->A2_TIPO
			cA2_EST     := (cAliasQry)->A2_EST
			cA2_COD_MUN := (cAliasQry)->A2_COD_MUN

			If lClEnt
				cAliasQr1 := GetNextAlias()
				BeginSql Alias cAliasQr1
					SELECT SA2.A2_COD_MUN,
							SA2.A2_BAIRRO,
							SA2.A2_CEP,
							SA2.A2_END,
							SA2.A2_EST
					FROM %Table:SA2% SA2
					WHERE SA2.A2_FILIAL = %xFilial:SA2%
					AND SA2.A2_COD = %Exp:cCliRem%
					AND SA2.A2_LOJA = %Exp:cLojaRem%
					AND SA2.%NotDel%
				EndSql

				If (cAliasQr1)->(!Eof())
					cCodMun     := (cAliasQr1)->A2_COD_MUN
					cBairroEnt  := (cAliasQr1)->A2_BAIRRO
					cCepEnt     := (cAliasQr1)->A2_CEP
					cNrcEnt     := TMS120CDUF((cAliasQr1)->A2_EST, "1") + (cAliasQr1)->A2_COD_MUN
					cEndEnt     := (cAliasQr1)->A2_END
					cA1_ESTE    := (cAliasQr1)->A2_EST
					cA1_CODMUNE := (cAliasQr1)->A2_COD_MUN
				EndIf
				(cAliasQr1)->(dbCloseArea())
			EndIf
		EndIf
		(cAliasQry)->(dbCloseArea())
	Else
		cAliasQry := GetNextAlias()
		BeginSql Alias cAliasQry
			SELECT SA1.A1_COD,
					SA1.A1_LOJA,
					SA1.A1_EST,
					SA1.A1_COD_MUN,
					SA1.A1_CGC,
					SA1.A1_TIPO,
					SA1.A1_ENDENT,
					SA1.A1_CODMUNE,
					SA1.A1_BAIRROE,
					SA1.A1_CEPE,
					SA1.A1_ESTE
			FROM %Table:SA1% SA1
			WHERE SA1.A1_FILIAL = %xFilial:SA1%
			AND SA1.A1_COD = %Exp:SF2->F2_CLIENTE%
			AND SA1.A1_LOJA = %Exp:SF2->F2_LOJA%
			AND SA1.%NotDel%
		EndSql
	
		If (cAliasQry)->(!Eof())
			If (cAliasQry)->A1_TIPO == "X"
				cA1_CGC := AllTrim((cAliasQry)->A1_COD)+AllTrim((cAliasQry)->A1_LOJA)
				cA1_CGC := PadR( cA1_CGC, Len((cAliasQry)->A1_CGC))
			Else
				cA1_CGC := (cAliasQry)->A1_CGC
			EndIf

			cA1_COD     := (cAliasQry)->A1_COD
			cA1_LOJA    := (cAliasQry)->A1_LOJA
			cA1_EST     := (cAliasQry)->A1_EST
			cA1_COD_MUN := (cAliasQry)->A1_COD_MUN

			If !lClEnt
				If !Empty((cAliasQry)->A1_ENDENT) .AND. !Empty((cAliasQry)->A1_CODMUNE)
					cBairroEnt  := (cAliasQry)->A1_BAIRROE
					cCepEnt     := (cAliasQry)->A1_CEPE
					cNrcEnt     := TMS120CDUF((cAliasQry)->A1_ESTE, "1") + (cAliasQry)->A1_CODMUNE
					cEndEnt     := (cAliasQry)->A1_ENDENT
					cCodMun     := (cAliasQry)->A1_CODMUNE
					cA1_ESTE    := (cAliasQry)->A1_ESTE
					cA1_CODMUNE := (cAliasQry)->A1_CODMUNE
				EndIf
			Else
				cAliasQr1 := GetNextAlias()
				BeginSql Alias cAliasQr1
					SELECT SA1.A1_COD_MUN,
							SA1.A1_BAIRRO,
							SA1.A1_CEP,
							SA1.A1_EST,
							SA1.A1_END
					FROM %Table:SA1% SA1
					WHERE SA1.A1_FILIAL = %xFilial:SA1%
					AND SA1.A1_COD = %Exp:cCliRem%
					AND SA1.A1_LOJA = %Exp:cLojaRem%
					AND SA1.%NotDel%
				EndSql
				
				If (cAliasQr1)->(!Eof())
					cCodMun 	:= (cAliasQr1)->A1_COD_MUN
					cBairroEnt  := (cAliasQr1)->A1_BAIRRO
					cCepEnt     := (cAliasQr1)->A1_CEP
					cNrcEnt     := TMS120CDUF((cAliasQr1)->A1_EST, "1") + (cAliasQr1)->A1_COD_MUN
					cEndEnt     := (cAliasQr1)->A1_END
					cA1_ESTE    := (cAliasQr1)->A1_EST
					cA1_CODMUNE := (cAliasQr1)->A1_COD_MUN
				EndIf
				(cAliasQr1)->(dbCloseArea())
			EndIf
		EndIf
		(cAliasQry)->(dbCloseArea())
	EndIf

	//-- Suportabilidade (09/Nov/2022): Pré-Validações antes do MVC
	oPrVldNFS := JsonObject():New()
	oPrVldNFS["GW1_CDREM" ]  := cRemeDc
	oPrVldNFS["GW1_EMISDC"]  := cEmisDc

	If SF2->F2_TIPO $ "DB"
		If lNumProp
			oPrVldNFS["GW1_CDDEST"] := GFEM011COD(cA2_COD,cA2_LOJA,2,,) 
		Else
			oPrVldNFS["GW1_CDDEST"] := cA2_CGC 
		EndIf
	Else
		If lNumProp
			oPrVldNFS["GW1_CDDEST"] := GFEM011COD(cA1_COD,cA1_LOJA,1,,) 
		Else
			oPrVldNFS["GW1_CDDEST"] := cA1_CGC 
		EndIf
	EndIf

	cCGCDest := cA2_CGC

	If !Empty(cCodMun)
		oPrVldNFS["GW1_ENTNRC"]  := cNrcEnt
	EndIf

	aCGCRem := FWSM0Util():GetSM0Data(, , {"M0_CGC"})

	oPrVldCGC := JsonObject():New()
	oPrVldCGC["GW1_CDREM"] 	:= aCGCRem[1][2]
	oPrVldCGC["GW1_EMISDC"]	:= aCGCRem[1][2]
	oPrVldCGC["GW1_CDDEST"] := cCGCDest

	lRet := !FindFunction("GFEPreVld") .Or. GFEPreVld("NFS",@oPrVldNFS,@oPrVldCGC)

	//-- Fim - Suportabilidade: Pré-validações

	If lRet
		oModelNFS:SetOperation( MODEL_OPERATION_INSERT )
		oModelNFS:Activate()

		//Cabeçalho do Documento de Carga
		oModelNFS:SetValue( 'GFEA044_GW1', 'GW1_FILIAL', SF2->F2_FILIAL )

		oModelNFS:SetValue( 'GFEA044_GW1', 'GW1_CDTPDC', cF2_CDTPDC )
		oModelNFS:SetValue( 'GFEA044_GW1', 'GW1_SERDC' , SF2->F2_SERIE )
		oModelNFS:LoadValue( 'GFEA044_GW1', 'GW1_NRDC'  , SF2->F2_DOC )
		oModelNFS:SetValue( 'GFEA044_GW1', 'GW1_DTEMIS', SF2->F2_EMISSAO )
		oModelNFS:LoadValue( 'GFEA044_GW1', 'GW1_ORIGEM', "2" )

		oModelNFS:SetValue( 'GFEA044_GW1', 'GW1_CDREM' , oPrVldNFS["GW1_CDREM" ] )
		oModelNFS:SetValue( 'GFEA044_GW1', 'GW1_EMISDC', oPrVldNFS["GW1_EMISDC"] )

		oModelNFS:SetValue( 'GFEA044_GW1', 'GW1_CDDEST', oPrVldNFS["GW1_CDDEST"] )

		If !Empty(SF2->F2_CARGA+SF2->F2_SEQCAR)
			dbSelectArea("GWN")
			GWN->( dbSetOrder(1) )
			GWN->( dbSeek(xFilial("GWN")+SF2->F2_CARGA+SF2->F2_SEQCAR ) )
			If !GWN->( Eof() ) .And. GWN->GWN_FILIAL == xFilial("GWN");
							   .And. GWN->GWN_NRROM == SF2->F2_CARGA+SF2->F2_SEQCAR

				oModelNFS:LoadValue( 'GFEA044_GW1', 'GW1_SIT'   , "4" )
				If GFXCP1212210('GW1_FILROM') 
					oModelNFS:SetValue( 'GFEA044_GW1', 'GW1_FILROM', GWN->GWN_FILIAL)
				EndIf
				oModelNFS:SetValue( 'GFEA044_GW1', 'GW1_NRROM' , SF2->F2_CARGA+SF2->F2_SEQCAR)
			Else
				oModelNFS:LoadValue( 'GFEA044_GW1', 'GW1_SIT'   , "3" )
			EndIf
		Else
			oModelNFS:LoadValue( 'GFEA044_GW1', 'GW1_SIT'   , "3" )
		EndIf

		oModelNFS:SetValue( 'GFEA044_GW1', 'GW1_DSESP'  , SF2->F2_ESPECI1 )	//Campo referente a espécie da carga e não da espécie da NF.
		oModelNFS:SetValue( 'GFEA044_GW1', 'GW1_DTLIB'  , DATE() )
		oModelNFS:SetValue( 'GFEA044_GW1', 'GW1_HRLIB'  , SubStr(TIME(),1,5) )

		Do Case
			Case SF2->F2_FIMP == "T" //transmitida
				cGW1_AUTSEF := "0" //Nao informado

			Case SF2->F2_FIMP == "S" //NF Autorizada
				cGW1_AUTSEF := "1" //Autorizado

			Case SF2->F2_FIMP == "D" //NF Uso Denegado
				cGW1_AUTSEF := "2" //Nao-autorizado

			Case SF2->F2_FIMP == "N" //NF Não-autorizada
				cGW1_AUTSEF := "2" //Nao-autorizado

			otherwise
				cGW1_AUTSEF := "0" //Nao informado

		EndCase

		oModelNFS:SetValue( 'GFEA044_GW1', 'GW1_AUTSEF' , cGW1_AUTSEF )
		oModelNFS:SetValue( 'GFEA044_GW1', 'GW1_DANFE'  , SF2->F2_CHVNFE )

		cF2_TPFRETE := SF2->F2_TPFRETE


		/* ****************************************************************************************************
		* Ponto de entrada para utilizar outros Tipos de Frete e customizar o valor que será tratado (CIF ou FOB)
		**************************************************************************************************** */
		If lOMSM0111
			cF2_TPFRETE := ExecBlock("OMSM0111",.f.,.f.,{SF2->F2_TPFRETE,"1",0,""})
		EndIf

		DO CASE
			CASE cF2_TPFRETE == "C" .Or. cF2_TPFRETE == "R"
				If Empty(SF2->F2_REDESP)
					oModelNFS:SetValue( 'GFEA044_GW1', 'GW1_TPFRET', "1" )
				Else
					oModelNFS:SetValue( 'GFEA044_GW1', 'GW1_TPFRET', "2" )
				EndIf
			CASE cF2_TPFRETE == "F"  .Or. cF2_TPFRETE == "S" .Or. cF2_TPFRETE == "D"
				If Empty(SF2->F2_REDESP)
					oModelNFS:SetValue( 'GFEA044_GW1', 'GW1_TPFRET', "3" )
				Else
					oModelNFS:SetValue( 'GFEA044_GW1', 'GW1_TPFRET', "4" )
				EndIf
			CASE cF2_TPFRETE == "T"
				If Empty(SF2->F2_REDESP)
					oModelNFS:SetValue( 'GFEA044_GW1', 'GW1_TPFRET', "5" )
				Else
					oModelNFS:SetValue( 'GFEA044_GW1', 'GW1_TPFRET', "6" )
				EndIf
			OTHERWISE
				oModelNFS:SetValue( 'GFEA044_GW1', 'GW1_TPFRET', "1" )
		ENDCASE

		If SF2->F2_TIPO $ "DB"
			oModelNFS:SetValue( 'GFEA044_GW1', 'GW1_ORINR' , SF2->F2_NFORI )
			oModelNFS:SetValue( 'GFEA044_GW1', 'GW1_ORISER', SF2->F2_SERIORI )
		EndIf

		oModelNFS:SetValue( 'GFEA044_GW1', 'GW1_ICMSDC', IIF(SF2->F2_VALICM == 0 , "2" , "1") )
		oModelNFS:SetValue( 'GFEA044_GW1', 'GW1_QTVOL' , SF2->F2_VOLUME1 )

		//Endereço de entrega
		If !Empty(cCodMun)
			oModelNFS:SetValue( 'GFEA044_GW1', 'GW1_ENTEND', cEndEnt )
			oModelNFS:SetValue( 'GFEA044_GW1', 'GW1_ENTCEP', cCepEnt )
			oModelNFS:SetValue( 'GFEA044_GW1', 'GW1_ENTBAI', cBairroEnt )
			oModelNFS:SetValue( 'GFEA044_GW1', 'GW1_ENTNRC', oPrVldNFS["GW1_ENTNRC"] )
		EndIf
		nRatTot := 0
		dbSelectArea("SD2")
		SD2->( dbSetOrder(3) )
		SD2->( dbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA) )
		While !SD2->( Eof() ) .And. SD2->D2_FILIAL == xFilial("SD2");
								.And. AllTrim(SD2->D2_DOC) == AllTrim(SF2->F2_DOC);
								.And. AllTrim(SD2->D2_SERIE) == AllTrim(SF2->F2_SERIE);
								.And. AllTrim(SD2->D2_CLIENTE) == AllTrim(SF2->F2_CLIENTE);
								.And. AllTrim(SD2->D2_LOJA) == AllTrim(SF2->F2_LOJA)

			If nI != 1
				oModelItens:AddLine()
				oModelItens:GoLine( nI )
			EndIf

			//Itens do Documento de Carga
			oModelNFS:SetValue( 'GFEA044_GW8', 'GW8_CDTPDC', cF2_CDTPDC )
			oModelNFS:SetValue( 'GFEA044_GW8', 'GW8_EMISDC', cEmisDc )
			oModelNFS:SetValue( 'GFEA044_GW8', 'GW8_SERDC' , SF2->F2_SERIE )
			oModelNFS:SetValue( 'GFEA044_GW8', 'GW8_NRDC'  , SF2->F2_DOC )
			oModelNFS:SetValue( 'GFEA044_GW8', 'GW8_SEQ'   , SD2->D2_ITEM )	
	
			cGUKITEM := PadR(AllTrim(SD2->D2_COD),TamSx3("GUK_ITEM")[1])
			oModelNFS:SetValue( 'GFEA044_GW8', 'GW8_ITEM'  , cGUKITEM )

			GUK->(dbSetOrder(1))
			If GUK->(dbSeek(xFilial("GUK") + cGUKITEM))

				If !Empty(GUK->GUK_CDCLFR)
					oModelNFS:SetValue( 'GFEA044_GW8', 'GW8_CDCLFR', GUK->GUK_CDCLFR )
				EndIf
				If !Empty(GUK->GUK_TPITEM)
					oModelNFS:SetValue( 'GFEA044_GW8', 'GW8_TPITEM', GUK->GUK_TPITEM )
				EndIf

			Else

				If Empty(cCdClFrete) .AND. lOm11clf
					cCdClFrete := ExecBlock("OM11CLF",.F.,.F.)
				EndIf

				oModelNFS:SetValue( 'GFEA044_GW8', 'GW8_CDCLFR', cCdClFrete )

			EndIf

			nAltura := Posicione("SB5",1,xFilial("SB5")+ (SD2->D2_COD),"B5_ALTURA")
			nVolume := (nAltura * SB5->B5_LARG * SB5->B5_COMPR)* (SD2->D2_QUANT)
			cDsitem := SubStr(Posicione("SB1",1,xFilial("SB1")+SD2->D2_COD,"B1_DESC"),1,50)
			nPesor  := IIF(FindFunction("OmRtPesoIt"),OmRtPesoIt(SD2->D2_COD,SD2->D2_QUANT),(Posicione("SB1",1,xFilial("SB1")+SD2->D2_COD,"B1_PESBRU")) * SD2->D2_QUANT )
			nSumPesoRnd += VerifRoundABNT(nPesor, 8)
			nDifSum := nSumPesoRnd - SF2->F2_PBRUTO

			oModelNFS:SetValue( 'GFEA044_GW8', 'GW8_DSITEM', cDsitem )
			oModelNFS:SetValue( 'GFEA044_GW8', 'GW8_QTDE'  , SD2->D2_QUANT )

			If cGFEVlIt == "2"
				oModelNFS:SetValue( 'GFEA044_GW8', 'GW8_VALOR' , SD2->D2_TOTAL )
			Else
				oModelNFS:SetValue( 'GFEA044_GW8', 'GW8_VALOR' , SD2->D2_VALBRUT )
			EndIf
			oModelNFS:SetValue( 'GFEA044_GW8', 'GW8_VALLIQ', SD2->D2_TOTAL )
			oModelNFS:SetValue( 'GFEA044_GW8', 'GW8_VOLUME', nVolume )
			oModelNFS:SetValue( 'GFEA044_GW8', 'GW8_PESOR' , VerifRoundABNT(nPesor, 8) )
			oModelNFS:SetValue( 'GFEA044_GW8', 'GW8_QTDALT', SD2->D2_PESO * SD2->D2_QUANT )

			cCfop := StrTran(SD2->D2_CF,".")
			cCfop := StrTran(SD2->D2_CF,",")

			oModelNFS:SetValue( 'GFEA044_GW8', 'GW8_CFOP'  , SubStr(cCfop,1,TamSx3("GW8_CFOP")[1]) )

			oModelNFS:SetValue('GFEA044_GW8', 'GW8_INFO1', SD2->D2_TP)
			oModelNFS:SetValue('GFEA044_GW8', 'GW8_INFO2', SD2->D2_GRUPO)
			oModelNFS:SetValue('GFEA044_GW8', 'GW8_INFO3', SD2->D2_TES)
			
			cTribpc := GFETribPC("2;4", SD2->D2_TES, @oModelNFS)

			oModelNFS:SetValue('GFEA044_GW8', 'GW8_TRIBP', cTribpc)	
		
			If lOMSM0113
				ExecBlock("OMSM0113",.f.,.f.,{oModelItens})
			EndIf

			If cGFEVolU == "1" //-- Volume por unitizador
				If cCriRat == "1" // "1=Peso Mercadoria"
					nRatTot += oModelNFS:GetValue( 'GFEA044_GW8', 'GW8_PESOR')
				ElseIf cCriRat == "2" // "2=Valor Mercadoria"
					nRatTot += oModelNFS:GetValue( 'GFEA044_GW8', 'GW8_VALOR')
				ElseIf cCriRat == "3" // "3=Volume"
					nRatTot += oModelNFS:GetValue( 'GFEA044_GW8', 'GW8_VOLUME')
				ElseIf cCriRat == "4" // "4=Quantidade"
					nRatTot += oModelNFS:GetValue( 'GFEA044_GW8', 'GW8_QTDE')
				Else //-- não definido - utilizado o total de itens na NF 
					nRatTot++		
				EndIf
			EndIf
			nI++
			SD2->( dbSkip() )
		EndDo

		If nDifSum != 0 .And. !lOMSM0113 .And. cGFERPB == "1"
			//Retorna ao último item da NF
			SD2->(dbSkip(-1))
			//Corrige a diferença entre o Peso Bruto da NF e a soma do peso dos itens da NF
			If !SD2->(Eof()) 
				If nSumPesoRnd > SF2->F2_PBRUTO
					oModelNFS:SetValue( 'GFEA044_GW8', 'GW8_PESOR' , VerifRoundABNT(nPesor - nDifSum, 8))
				Else
					oModelNFS:SetValue( 'GFEA044_GW8', 'GW8_PESOR' , VerifRoundABNT(nPesor + (nDifSum * -1), 8))
				EndIf
			EndIf
			SD2->( dbSkip() )
		EndIf		
		
		nVolTot := 0
		for nX := 1 to nStruVolQtd

			cEspNFS := &('SF2->F2_ESPECI'+Alltrim(Str(nX)))
			GUG->(dbSetOrder(1))
			If !Empty(cEspNFS) .And. !Empty(&('SF2->F2_VOLUME'+Alltrim(Str(nX)))) .And. GUG->(dbSeek(xFilial("GUG") + cEspNFS))

				//-- Volume por unitizador
				nVolTot += Round(&('SF2->F2_VOLUME'+Alltrim(Str(nX))) * GUG->GUG_VOLUME,TamSx3("GW8_VOLUME")[2])

				If nLine != 1
					oModelUnit:AddLine()
					oModelUnit:GoLine( nLine )
				EndIf

					oModelNFS:SetValue( 'GFEA044_GWB', 'GWB_CDUNIT', cEspNFS)
					oModelNFS:SetValue( 'GFEA044_GWB', 'GWB_QTDE', &('SF2->F2_VOLUME'+Alltrim(Str(nX))))

				If lOMSM0114
					ExecBlock("OMSM0114",.f.,.f.,{oModelUnit})
				EndIf

				nLine++

			EndIf

		Next

		If cGFEVolU == "1" .And. !Empty(nVolTot)//-- Volume por unitizador
			nVolSld := nVolTot
			For nX := 1 To oModelItens:GetQtdLine()
				oModelItens:GoLine( nX )

				nFator := 0
				If cCriRat == "1" // "1=Peso Mercadoria"
					nFator := oModelNFS:GetValue( 'GFEA044_GW8', 'GW8_PESOR') / nRatTot
				ElseIf cCriRat == "2" // "2=Valor Mercadoria"
					nFator := oModelNFS:GetValue( 'GFEA044_GW8', 'GW8_VALOR') / nRatTot
				ElseIf cCriRat == "3" // "3=Volume"
					nFator := oModelNFS:GetValue( 'GFEA044_GW8', 'GW8_VOLUME') / nRatTot
				ElseIf cCriRat == "4" // "4=Quantidade"
					nFator := oModelNFS:GetValue( 'GFEA044_GW8', 'GW8_QTDE') / nRatTot
				Else //-- "0=(Não definido)"
					nFator := 1 / nRatTot  		
				EndIf

				nVolume := Round(nVolTot * nFator,TamSx3("GW8_VOLUME")[2])
				nVolSld -= nVolume
				//-- Diferença de arredondamento no último item
				If nX == oModelItens:GetQtdLine() .And. !Empty(nVolSLd)
					nVolume += nVolSld
				EndIf
				oModelNFS:SetValue( 'GFEA044_GW8', 'GW8_VOLUME', nVolume )
			Next nX
		EndIf
		//Trechos do Documento de Carga
		SetTrechos(oModelNFS,oModelTrechos,cF2_CDTPDC,cEmisDc,cA2_EST,cA2_COD_MUN,cA1_EST,cA1_COD_MUN,cA1_ESTE,cA1_CODMUNE)
	EndIf
	If lRet .And. oModelNFS:VldData()
		oModelNFS:CommitData()

		If lOMSM0115
			ExecBlock("OMSM0115",.f.,.f.,{oModelNFS})
		EndIf

		If IsInCallStack("GFEM011") .And. SuperGetMv("MV_FATGFE",.F.,"2") == "2"
			//Exclui a nota da GW0
			GFEM011GW0()
		EndIf
	Else
		If !Empty(oPrVldNFS["MSGERR"])
			oModelNFS:SetErrorMessage(,,,"F2_DOC",,"Pré-Validação GFE" + " - " + oPrVldNFS["MSGERR"],)
		EndIf
		If IsInCallStack("GFEM011")
			CreatLog(ArqvLog, oModelNFS, cProTable,  cRotiProt)
			If SuperGetMv("MV_FATGFE",.F.,"2") == "2"

				If ValErro(oModelNFS)// Nao grava GW0 quando for rejeitada pelo filtro
					//Grava erro na GW0 para manter arquivado
					GravaGW0(oModelNFS) //F2_FILIAL + F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA
				Else
					//Exclui a nota da GW0
					GFEM011GW0()
				EndIf
			EndIf
		Else
			If SuperGetMv("MV_FATGFE",.F.,"2") == "1"
				If ValErro(oModelNFS)
					GFEMessage(0,GFEM011007,STR0055 +CRLF+CRLF+oModelNFS:GetErrorMessage()[6]+" "+oModelNFS:GetErrorMessage()[4],STR0081 ) // "Inconsistência com o Frete Embarcador (SIGAGFE): "
					lRet := .F.
				EndIf
			Else
				If ValErro(oModelNFS)
					//Grava erro na GW0 para manter arquivado
					GravaGW0(oModelNFS) //F2_FILIAL + F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA
				Else
					//Exclui a nota da GW0
					GFEM011GW0()
				EndIf
			EndIf
		EndIf
	EndIf

	oModelNFS:Deactivate()
	oModelNFS:Destroy()
	oModelNFS := Nil
	FreeObj(oModelNFS)
	FreeObj(oPrVldNFS)
EndIf

RestArea( aAreaSA1 )
RestArea( aAreaSA2 )
RestArea( aAreaGWU )
RestArea( aAreaGW8 )
RestArea( aAreaGW1 )

Return lRet

//---------------------------------------------------
/*/
Intregração de Documentos de Entrada
@author Felipe Machado de Oliveira
@version P11
@since 21/05/2013
/*/
//---------------------------------------------------
Function GFEM011NFE(cTipoInter,aDados,aDadosItens,cProTable,cRotiProt,ArqvLog,lCommit)
	Local lRet        := .T.
	Local lNumProp    := GFEEMITMP()
	Local aAreaSD1    := SD1->(GetArea())
	Local aAreaGW1    := GW1->(GetArea())
	Local aAreaGW8    := GW8->(GetArea())
	Local aAreaGWU    := GWU->(GetArea())
	Local aAreaSA2    := SA2->(GetArea())
	Local aAreaSA1    := SA1->(GetArea())
	Local oModelNFE   := FWLoadModel("GFEA044")
	Local oModelItens := oModelNFE:GetModel('GFEA044_GW8')
	Local cAliasSA1   := Nil
	Local cAliasSA2   := Nil
	Local cAliasSA4   := Nil
	Local cAliasSD1   := Nil
	Local cAliasSF4   := Nil
	Local cAliasGU3   := Nil
	Local cA1_CGC     := ""
	Local cA1_EST     := ""
	Local cA1_COD_MUN := ""
	Local cA2_CGC     := ""
	Local cA2_TIPO    := ""
	Local cF1_CDTPDC  := ""
	Local cA1_ENDENT  := ""
	Local cA1_BAIRROE := ""
	Local cA1_ESTE    := ""
	Local cA1_CODMUNE := ""
	Local cA1_COD     := ""
	Local cA1_LOJA    := ""
	Local cA2_COD     := ""
	Local cA2_LOJA    := ""
	Local cCdTrp      := ""
	Local cEmisDc     := ""
	Local cNrCid      := ""
	Local cNrPed	  := ""
	Local cUso		  := ""
	Local cTipo       := ""
	Local cTpFrete    := ""
	Local nI          := 1
	Local nTamForn    := TamSx3("A2_COD")[1]
	Local nTamLojF    := TamSx3("A2_LOJA")[1]
	Local nTamCli     := TamSx3("A1_COD")[1]
	Local nTamLojC    := TamSx3("A1_LOJA")[1]
	Local aSX5		  := {}
	Local oPrVldNFE	  := Nil
	Local oPrVldCGC	  := Nil
	Local cRemDC	  := ""
	Local cRemCGC	  := ""
	Local cDestDC	  := ""
	Local cDestCGC	  := ""
	Local cCGCEmis	  := ""
	Local cQuery
	Local oQry
	Local cForRet  := Nil
	Local cLojaRet := Nil
	Local cForEnt  := Nil
	Local cLojaEnt := Nil
	
	Private lGfeCTrib := SuperGetMv("MV_GFECTRI",,.F.)

	Default cTipoInter  := "TODOS"
	Default aDados      := {}
	Default aDadosItens := {}
	Default lCommit     := .T.

	If cTipoInter == "UNICO"
	//aNFEDanfe - Array com informações do Documento da Integração com MATA103
		cForRet  := aNFEDanfe[16] // F1_FORRET
		cLojaRet := aNFEDanfe[17] // F1_LOJARET
		cForEnt  := aNFEDanfe[19] // F1_FORENT
		cLojaEnt := aNFEDanfe[20] // F1_LOJAENT
	EndIf

	// Adicionado condicional para não permitir integração de documentos de entrada com Origem no SIGAGFE impedindo assim integrações desnecessarias.
	If !Empty(SF1->F1_ORIGEM) .And. Alltrim(SF1->F1_ORIGEM) == "GFEA065"
		Return .T.
	EndIf

	If lUsaNewKey == Nil
		lUsaNewKey := ( TamSX3("F1_SERIE")[1] == 14 )
	EndIf
	If cTipoInter == "TODOS"
		aDados := { SF1->F1_TIPO ,;
					SF1->F1_FORMUL ,;
					SF1->F1_DOC ,;
					SF1->F1_SERIE ,;
					SF1->F1_EMISSAO ,;
					SF1->F1_FORNECE ,;
					SF1->F1_LOJA ,;
					SF1->F1_ESPECIE ,;
					SF1->F1_NFORIG ,;
					SF1->F1_TRANSP ,;
					SF1->F1_VOLUME1 ,;
					SF1->F1_TPFRETE ,;
					SF1->F1_VALICM ,;
					SF1->F1_FILIAL ,;
					SF1->F1_SERORIG,;
					SF1->F1_CHVNFE,;
					SF1->F1_FORRET,;
					SF1->F1_LOJARET,;
					SF1->F1_FORENT,;
					SF1->F1_LOJAENT  }
	Else 
		Aadd(aDados, cForRet)
		Aadd(aDados, cLojaRet) 
		Aadd(aDados, cForEnt) 
		Aadd(aDados, cLojaEnt) 
	EndIf

	If Empty(Alltrim(SF1->F1_STATUS)) .And. !IsInCallStack("MATA103")
		oModelNFE:SetErrorMessage(,,,"F1_STATUS",,"Nota fiscal não classificada não será enviada ao GFE.", "Para realizar integrações com o GFE é necessario as notas fiscais estarem classificadas.")
		If IsInCallStack("GFEM011")
			CreatLog(ArqvLog, oModelNFE, cProTable,  cRotiProt, aDados)
		EndIf

		Return .T.
	EndIf

	cTipo := AllTrim(aDados[1])

	If !Empty(aDados[12])
		cTpFrete := aDados[12]
	Else
		cTpFrete := 'S'
	EndIf	
	
	aSX5 := FWGetSX5("MQ", cTipo + "E")
	
	If Len(aSX5) > 0
		cF1_CDTPDC := aSX5[1][4]
	EndIf

	If Empty(cF1_CDTPDC)
		aSX5 := FWGetSX5("MQ", cTipo)
	
		If Len(aSX5) > 0
			cF1_CDTPDC := aSX5[1][4]
		EndIf
	EndIf
	
	cF1_CDTPDC := SubStr(cF1_CDTPDC,1,TamSx3("GW1_CDTPDC")[1])

	If !(cTipo $ 'I|P') .And. cTpFrete <> 'S'
		If cTipo $ "D|B"
			//Padronização dos Codigos de Cliente e Loja
			aDados[6] := Padr(aDados[6],nTamCli)
			aDados[7] := Padr(aDados[7],nTamLojC)

			cAliasSA1 := GetNextAlias()
			BeginSql Alias cAliasSA1
				SELECT SA1.A1_COD,
						SA1.A1_LOJA,
						SA1.A1_CGC,
						SA1.A1_EST,
						SA1.A1_COD_MUN,
						SA1.A1_TIPO
				FROM %Table:SA1% SA1
				WHERE SA1.A1_FILIAL = %xFilial:SA1%
				AND SA1.A1_COD = %Exp:aDados[6]%
				AND SA1.A1_LOJA = %Exp:aDados[7]%
				AND SA1.%NotDel%
			EndSql
			If (cAliasSA1)->(!Eof())
				If (cAliasSA1)->A1_TIPO == "X"
					cA1_CGC  := AllTrim((cAliasSA1)->A1_COD)+AllTrim((cAliasSA1)->A1_LOJA)
				Else
					cA1_CGC  := (cAliasSA1)->A1_CGC
				EndIf
				cA1_EST      := (cAliasSA1)->A1_EST
				cA1_COD_MUN  := (cAliasSA1)->A1_COD_MUN
		
				//Endereço de entrega deve ser o da filial que esta recebendo o documento.
				cA1_ENDENT   := SM0->M0_ENDENT
				cA1_BAIRROE  := SM0->M0_BAIRENT
				cA1_ESTE     := SM0->M0_ESTENT
				cA1_CODMUNE  := SM0->M0_CODMUN
		
				If !lNumProp
					cEmisDc  := cA1_CGC
				Else
					cA1_COD  := (cAliasSA1)->A1_COD
					cA1_LOJA := (cAliasSA1)->A1_LOJA
				EndIf
			EndIf
			(cAliasSA1)->(dbCloseArea())
		Else
			//Padronização dos Codigos de Fornecedor e Loja
			aDados[6] := Padr(aDados[6],nTamForn)
			aDados[7] := Padr(aDados[7],nTamLojF)

			cAliasSA2 := GetNextAlias()
			BeginSql Alias cAliasSA2
				SELECT SA2.A2_COD,
						SA2.A2_LOJA,
						SA2.A2_CGC,
						SA2.A2_TIPO
				FROM %Table:SA2% SA2
				WHERE SA2.A2_FILIAL = %xFilial:SA2%
				AND SA2.A2_COD = %Exp:aDados[6]%
				AND SA2.A2_LOJA = %Exp:aDados[7]%
				AND SA2.%NotDel%
			EndSql
			If (cAliasSA2)->(!Eof())
				If (cAliasSA2)->A2_TIPO == "X"
					cA2_CGC  := AllTrim((cAliasSA2)->A2_COD)+AllTrim((cAliasSA2)->A2_LOJA)
				Else
					cA2_CGC  := (cAliasSA2)->A2_CGC
				EndIf
				cA2_TIPO     := (cAliasSA2)->A2_TIPO
				If !lNumProp
					cEmisDc  := cA2_CGC
				Else
					cA2_COD  := (cAliasSA2)->A2_COD
					cA2_LOJA := (cAliasSA2)->A2_LOJA
				EndIf
			EndIf
			(cAliasSA2)->(dbCloseArea())
		EndIf
		
		If lNumProp
			If cTipo $ "D|B"
				cEmisDc  := GFEM011COD(cA1_COD,cA1_LOJA,1,,)
				cCGCEmis := cA1_CGC
			Else
				cEmisDc  := GFEM011COD(cA2_COD,cA2_LOJA,2,,)
				cCGCEmis := cA2_CGC
			EndIf
		Else
			cCGCEmis := cEmisDc
		EndIf

		If !Empty(aDados[17]) .And. !Empty(aDados[18])
			If cTipo $ "D|B"
				//Padronização dos Codigos de Cliente e Loja
				aDados[17] := Padr(aDados[17],nTamCli)
				aDados[18] := Padr(aDados[18],nTamLojC)

				cAliasSA1 := GetNextAlias()
				BeginSql Alias cAliasSA1
					SELECT SA1.A1_COD,
						   SA1.A1_LOJA
					FROM %Table:SA1% SA1
					WHERE SA1.A1_FILIAL = %xFilial:SA1%
					AND SA1.A1_COD = %Exp:aDados[17]%
					AND SA1.A1_LOJA = %Exp:aDados[18]%
					AND SA1.%NotDel%
				EndSql
				If (cAliasSA1)->(!Eof())
					cRemDC  := GFEM011COD((cAliasSA1)->A1_COD,(cAliasSA1)->A1_LOJA,1,,)
				EndIf
				(cAliasSA1)->(dbCloseArea())
			Else
				//Padronização dos Codigos de Fornecedor e Loja
				aDados[17] := Padr(aDados[17],nTamForn)
				aDados[18] := Padr(aDados[18],nTamLojF)

				cAliasSA2 := GetNextAlias()
				BeginSql Alias cAliasSA2
					SELECT SA2.A2_COD,
						   SA2.A2_LOJA
					FROM %Table:SA2% SA2
					WHERE SA2.A2_FILIAL = %xFilial:SA2%
					AND SA2.A2_COD = %Exp:aDados[17]%
					AND SA2.A2_LOJA = %Exp:aDados[18]%
					AND SA2.%NotDel%
				EndSql
				If (cAliasSA2)->(!Eof())
					cRemDC  := GFEM011COD((cAliasSA2)->A2_COD,(cAliasSA2)->A2_LOJA,2,,) 
				EndIf
				(cAliasSA2)->(dbCloseArea())
			EndIf

			cRemCGC := Posicione("GU3",1,xFilial("GU3") + cRemDC, "GU3_IDFED")	
		EndIf

		If !Empty(aDados[19]) .And. !Empty(aDados[20])
			If cTipo $ "D|B"
				//Padronização dos Codigos de Cliente e Loja
				aDados[19] := Padr(aDados[19],nTamCli)
				aDados[20] := Padr(aDados[20],nTamLojC)

				cAliasSA1 := GetNextAlias()

				cQuery := "SELECT SA1.A1_COD, SA1.A1_LOJA"
				cQuery += " FROM " + RetSqlName("SA1") + " SA1"
				cQuery += " WHERE SA1.A1_FILIAL = '"+  xFilial("SA1") +"'"
				cQuery += "	AND SA1.A1_COD =  ?"
				cQuery += "	AND SA1.A1_LOJA = ?"
				cQuery += "	AND D_E_L_E_T_ = ''"

				cQuery := ChangeQuery(cQuery)
				oQry := FWExecStatement():New(cQuery)

				oQry:SetString(1, aDados[19])
				oQry:SetString(2, aDados[20])

				cAliasSA1 := oQry:OpenAlias()
				
				If (cAliasSA1)->(!Eof())
					cDestDC  := GFEM011COD((cAliasSA1)->A1_COD,(cAliasSA1)->A1_LOJA,1,,)
				EndIf
				
				(cAliasSA1)->(dbCloseArea())
			Else
				//Padronização dos Codigos de Fornecedor e Loja
				aDados[19] := Padr(aDados[19],nTamForn)
				aDados[20] := Padr(aDados[20],nTamLojF)

				cAliasSA2 := GetNextAlias()

				cQuery := "SELECT SA2.A2_COD, SA2.A2_LOJA"
				cQuery += " FROM " + RetSqlName("SA2") + " SA2"
				cQuery += "	WHERE SA2.A2_FILIAL =  '"+  xFilial("SA2") +"'"
				cQuery += "	AND SA2.A2_COD = ?"
				cQuery += "	AND SA2.A2_LOJA = ?"
				cQuery += "	AND D_E_L_E_T_ = ''"

				cQuery := ChangeQuery(cQuery)
				oQry := FWExecStatement():New(cQuery)

				oQry:SetString(1, aDados[19])
				oQry:SetString(2, aDados[20])

				cAliasSA2 := oQry:OpenAlias()
				
				If (cAliasSA2)->(!Eof())
					cDestDC  := GFEM011COD((cAliasSA2)->A2_COD,(cAliasSA2)->A2_LOJA,2,,) 
				EndIf
				
				(cAliasSA2)->(dbCloseArea())
			EndIf

			cDestCGC := Posicione("GU3",1,xFilial("GU3") + cDestDC, "GU3_IDFED")	
		EndIf

		If Empty(cRemDC)
			//-- Suportabilidade (09/Nov/2022): Pré-Validações antes do MVC
			oPrVldNFE := JsonObject():New()
			oPrVldNFE["GW1_CDREM" ] := cEmisDc
			oPrVldNFE["GW1_EMISDC"] := cEmisDc
			oPrVldNFE["GW1_ENTNRC"] := cA1_CODMUNE

			oPrVldCGC := JsonObject():New()
			oPrVldCGC["GW1_CDREM"] 	:= cCGCEmis
			oPrVldCGC["GW1_EMISDC"]	:= cCGCEmis
		Else
			//-- Suportabilidade (09/Nov/2022): Pré-Validações antes do MVC
			oPrVldNFE := JsonObject():New()
			oPrVldNFE["GW1_CDREM" ] := cRemDc
			oPrVldNFE["GW1_EMISDC"] := cEmisDc
			oPrVldNFE["GW1_ENTNRC"] := cA1_CODMUNE

			oPrVldCGC := JsonObject():New()
			oPrVldCGC["GW1_CDREM"] 	:= cRemCGC
			oPrVldCGC["GW1_EMISDC"]	:= cCGCEmis
		EndIf

		If Empty(cDestCGC)
			oPrVldNFE["GW1_CDDEST"] := GFEM011COD(,,,.T.,xFilial("SF1")) 

			oPrVldCGC["GW1_CDDEST"] := FWSM0Util():GetSM0Data(, , {"M0_CGC"})[1][2]
		Else
			oPrVldNFE["GW1_CDDEST"] := cDestDC 

			oPrVldCGC["GW1_CDDEST"] := cDestCGC
		Endif

		lRet := !FindFunction("GFEPreVld") .Or. GFEPreVld("NFE",@oPrVldNFE,@oPrVldCGC)

		//-- Fim - Suportabilidade: Pré-validações
		If lRet
			oModelNFE:SetOperation( MODEL_OPERATION_INSERT )
			oModelNFE:Activate()
			
			//Cabeçalho do Documento de Carga
			oModelNFE:SetValue( 'GFEA044_GW1', 'GW1_FILIAL', aDados[14] )
			oModelNFE:SetValue( 'GFEA044_GW1', 'GW1_CDTPDC', cF1_CDTPDC )
			
			If lUsaNewKey
				aDados[4] := SerieNfId("SF1",4,"F1_SERIE",aDados[5],aDados[8],SubStr(aDados[4],1,3))
			EndIf
			oModelNFE:SetValue( 'GFEA044_GW1', 'GW1_SERDC' , aDados[4] )
			
			oModelNFE:LoadValue( 'GFEA044_GW1', 'GW1_NRDC'  , aDados[3] )
			oModelNFE:SetValue( 'GFEA044_GW1', 'GW1_DTEMIS', aDados[5] )
			oModelNFE:LoadValue( 'GFEA044_GW1', 'GW1_ORIGEM', "2" )
			
			oModelNFE:SetValue( 'GFEA044_GW1', 'GW1_CDDEST', oPrVldNFE["GW1_CDDEST"] )
			
			If !Empty(oModelNFE:GetErrorMessage()[6])
				cMsgErro := oModelNFE:GetErrorMessage()[4] + " - " + oModelNFE:GetErrorMessage()[6]
			EndIf
			
			oModelNFE:SetValue( 'GFEA044_GW1', 'GW1_CDREM' , oPrVldNFE["GW1_CDREM" ] )
			oModelNFE:SetValue( 'GFEA044_GW1', 'GW1_EMISDC', oPrVldNFE["GW1_EMISDC"] )
			
			oModelNFE:LoadValue( 'GFEA044_GW1', 'GW1_SIT'   , "3" )
			oModelNFE:SetValue( 'GFEA044_GW1', 'GW1_DSESP' , aDados[8] )
			oModelNFE:SetValue( 'GFEA044_GW1', 'GW1_DTLIB' , DATE() )
			oModelNFE:SetValue( 'GFEA044_GW1', 'GW1_HRLIB' , SubStr(TIME(),1,5) )
			
			If aDados[12] == "F" .or. aDados[12] == "D"
				oModelNFE:SetValue( 'GFEA044_GW1', 'GW1_TPFRET', "3" )
			Else
				//Atribui também Frete CIF quando Tipo de Frete estiver vazio
				oModelNFE:SetValue( 'GFEA044_GW1', 'GW1_TPFRET', "1" )
			EndIf
			
			If cTipo $ 'D|B'
				oModelNFE:SetValue( 'GFEA044_GW1', 'GW1_ORINR' , aDados[9] )
				oModelNFE:SetValue( 'GFEA044_GW1', 'GW1_ORISER', aDados[15] )
			EndIf
			
			oModelNFE:SetValue( 'GFEA044_GW1', 'GW1_ICMSDC', IIF(aDados[13] == 0 , "2" , "1") )
			oModelNFE:SetValue( 'GFEA044_GW1', 'GW1_QTVOL' , aDados[11] )
			
			//Endereço de entrega
			If !Empty(cA1_CODMUNE)
				oModelNFE:SetValue( 'GFEA044_GW1', 'GW1_ENTEND', cA1_ENDENT )
				oModelNFE:SetValue( 'GFEA044_GW1', 'GW1_ENTBAI', cA1_BAIRROE )
				oModelNFE:SetValue( 'GFEA044_GW1', 'GW1_ENTNRC', oPrVldNFE["GW1_ENTNRC"] )
			EndIf
			
			// Numero da DANFE
			If Len(aDados)>15 
				oModelNFE:SetValue( 'GFEA044_GW1', 'GW1_DANFE', aDados[16] )
			EndIf
			
			//Itens do Documento de Carga
			If cTipoInter == "TODOS"
				cAliasSD1 := GetNextAlias()
				BeginSql Alias cAliasSD1
					SELECT SD1.R_E_C_N_O_ RECNOSD1
					FROM %Table:SD1% SD1
					WHERE SD1.D1_FILIAL = %xFilial:SD1%
					AND SD1.D1_DOC = %Exp:aDados[3]%
					AND SD1.D1_SERIE = %Exp:aDados[4]%
					AND SD1.D1_FORNECE = %Exp:aDados[6]%
					AND SD1.D1_LOJA = %Exp:aDados[7]%
					AND SD1.%NotDel%
				EndSql
				Do While (cAliasSD1)->(!Eof())
					SD1->(dbGoTo((cAliasSD1)->RECNOSD1))
					
					If Empty(cNrPed)
						cNrPed	:= AllTrim(SD1->D1_PEDIDO)
					EndIf
					
					If Empty(cUso)
						cAliasSF4 := GetNextAlias()
						BeginSql Alias cAliasSF4
							SELECT SF4.F4_ATUATF,
									SF4.F4_CONSUMO
							FROM %Table:SF4% SF4
							WHERE SF4.F4_FILIAL = %xFilial:SF4%
							AND SF4.F4_CODIGO = %Exp:SD1->D1_TES%
							AND SF4.%NotDel% 
						EndSql
						If (cAliasSF4)->(!Eof())
							If (cAliasSF4)->F4_ATUATF == "S"
								cUso := "3"
							ElseIf (cAliasSF4)->F4_CONSUMO == "S"
								cUso := "2"
							Else
								cUso := "1"
							EndIf
						EndIf
						(cAliasSF4)->(dbCloseArea())
					EndIf
					SetIteDocCar(oModelNFE,oModelItens,cF1_CDTPDC,cEmisDc,aDados[4],aDados[3],nI,cTipoInter)
			
					nI++
			
					(cAliasSD1)->( dbSkip() )
				EndDo
				(cAliasSD1)->(dbCloseArea())
			Else
				For nI := 1 to Len(aDadosItens)
					If Empty(cNrPed)
						aAreaSD1   := SD1->(GetArea())
						
						cAliasSD1 := GetNextAlias()
						BeginSql Alias cAliasSD1
							SELECT SD1.R_E_C_N_O_ RECNOSD1
							FROM %Table:SD1% SD1
							WHERE SD1.D1_FILIAL = %xFilial:SD1%
							AND SD1.D1_DOC = %Exp:aDados[3]%
							AND SD1.D1_SERIE = %Exp:aDados[4]%
							AND SD1.D1_FORNECE = %Exp:aDados[6]%
							AND SD1.D1_LOJA = %Exp:aDados[7]%
							AND SD1.%NotDel%
						EndSql
						If (cAliasSD1)->(!Eof())
							SD1->(dbGoTo((cAliasSD1)->RECNOSD1))
		
							If Empty(cNrPed)
								cNrPed	:= AllTrim(SD1->D1_PEDIDO)
							EndIf
							
							If Empty(cUso)
								cAliasSF4 := GetNextAlias()
								BeginSql Alias cAliasSF4
									SELECT SF4.F4_ATUATF,
											SF4.F4_CONSUMO
									FROM %Table:SF4% SF4
									WHERE SF4.F4_FILIAL = %xFilial:SF4%
									AND SF4.F4_CODIGO = %Exp:SD1->D1_TES%
									AND SF4.%NotDel% 
								EndSql
								If (cAliasSF4)->(!Eof())
									If (cAliasSF4)->F4_ATUATF == "S"
										cUso := "3"
									ElseIf (cAliasSF4)->F4_CONSUMO == "S"
										cUso := "2"
									Else
										cUso := "1"
									EndIf
								EndIf
								(cAliasSF4)->(dbCloseArea())
							EndIf
						EndIf
						(cAliasSD1)->(dbCloseArea())
					EndIf
					SetIteDocCar(oModelNFE,oModelItens,cF1_CDTPDC,cEmisDc,aDados[4],aDados[3],nI,cTipoInter,aDadosItens)
				Next
			EndIf
			
			oModelNFE:SetValue( 'GFEA044_GW1', 'GW1_PEDCLI', cNrPed )
			
			If !Empty(cUso)
				oModelNFE:SetValue( 'GFEA044_GW1', 'GW1_USO', cUso )
			EndIf
			
			nI := 0
			
			//Trecho do Documento de Carga
			oModelNFE:SetValue( 'GFEA044_GWU', 'GWU_CDTPDC', cF1_CDTPDC )
			oModelNFE:SetValue( 'GFEA044_GWU', 'GWU_EMISDC', cEmisDc )
			oModelNFE:SetValue( 'GFEA044_GWU', 'GWU_SERDC' , aDados[4] )
			oModelNFE:SetValue( 'GFEA044_GWU', 'GWU_NRDC'  , aDados[3] )
			oModelNFE:SetValue( 'GFEA044_GWU', 'GWU_SEQ'   , "01" )
			
			If lNumProp
				If Empty(aDados[10])
					cCdTrp := ""
				Else
					cAliasGU3 := GetNextAlias()
					BeginSql Alias cAliasGU3
						SELECT GU3.GU3_CDEMIT
						FROM %Table:GU3% GU3
						WHERE GU3.GU3_FILIAL = %xFilial:GU3%
						AND GU3.GU3_CDTERP = %Exp:aDados[10]%
						AND GU3.GU3_SIT = '1'
						AND GU3.%NotDel%
					EndSql
					If (cAliasGU3)->(!Eof())
						cCdTrp :=(cAliasGU3)->GU3_CDEMIT
					Else
						cAliasSA4 := GetNextAlias()
						BeginSql Alias cAliasSA4
							SELECT GU3.GU3_CDEMIT
							FROM %Table:SA4% SA4
							INNER JOIN %Table:GU3% GU3
							ON GU3.GU3_FILIAL = %xFilial:GU3% 
							AND GU3.GU3_IDFED = SA4.A4_CGC
							AND GU3.GU3_IE = SA4.A4_INSEST
							AND GU3.GU3_SIT = '1'
							AND GU3.GU3_TRANSP = '1'
							AND GU3.%NotDel%
							WHERE SA4.A4_FILIAL = %xFilial:SA4%
							AND SA4.A4_COD = %Exp:aDados[10]%
							AND SA4.%NotDel%
						EndSql
						If (cAliasSA4)->(!Eof())
							cCdTrp := (cAliasSA4)->GU3_CDEMIT
						EndIf
						(cAliasSA4)->(dbCloseArea())
					EndIf
					(cAliasGU3)->(dbCloseArea())
					If Empty(cCdTrp)
						oModelNFE:SetErrorMessage(STR0068,STR0069,STR0070,STR0071,STR0072,STR0073 + aDados[10] + STR0074) //GFEA044,GWU_CDTRP,GFEA044_GWU,GWU_CDTRP, Transp não existe, não existe cadastro correspondente para o transportador ou está inativo, no GFE.
					EndIf
				EndIf
				oModelNFE:SetValue( 'GFEA044_GWU', 'GWU_CDTRP' ,  cCdTrp )
			Else
				cAliasSA4 := GetNextAlias()
				BeginSql Alias cAliasSA4
					SELECT GU3.GU3_CDEMIT
					FROM %Table:SA4% SA4
					INNER JOIN %Table:GU3% GU3
					ON GU3.GU3_FILIAL = %xFilial:GU3%
					AND GU3.GU3_CDEMIT = SA4.A4_CGC
					AND GU3.GU3_SIT = '1'
					AND GU3.%NotDel%
					WHERE SA4.A4_FILIAL = %xFilial:SA4%
					AND SA4.A4_COD = %Exp:aDados[10]%
					AND SA4.%NotDel%
				EndSql
				If (cAliasSA4)->(!Eof())
					cCdTrp := (cAliasSA4)->GU3_CDEMIT
				EndIf
				(cAliasSA4)->(dbCloseArea())
				If Empty(cCdTrp)
					oModelNFE:SetErrorMessage(STR0068,STR0069,STR0070,STR0071,STR0072,STR0073 + aDados[10] + STR0074)
				EndIf
				oModelNFE:SetValue( 'GFEA044_GWU', 'GWU_CDTRP' , cCdTrp )
			EndIf
			
			If Empty(cA1_ENDENT)
				If lNumProp
					cAliasGU3 := GetNextAlias()
					BeginSql Alias cAliasGU3
						SELECT GU3_NRCID
						FROM %Table:GU3% GU3
						WHERE GU3.GU3_FILIAL = %xFilial:GU3%
						AND GU3.GU3_CDEMIT = %Exp:oPrVldNFE["GW1_CDDEST"]%
						AND GU3.%NotDel%
					EndSql
					If (cAliasGU3)->(!Eof())
						cNrCid := (cAliasGU3)->GU3_NRCID
					EndIf
					(cAliasGU3)->(dbCloseArea())
				Else
					cAliasGU3 := GetNextAlias()
					BeginSql Alias cAliasGU3
						SELECT GU3_NRCID
						FROM %Table:GU3% GU3
						WHERE GU3.GU3_FILIAL = %xFilial:GU3%
						AND GU3.GU3_IDFED = %Exp:oPrVldNFE["GW1_CDDEST"]%
						AND GU3.%NotDel%
					EndSql
					If (cAliasGU3)->(!Eof())
						cNrCid := (cAliasGU3)->GU3_NRCID
					EndIf
					(cAliasGU3)->(dbCloseArea())
				EndIf
				oModelNFE:SetValue( 'GFEA044_GWU', 'GWU_NRCIDD', cNrCid )
			Else
				oModelNFE:SetValue( 'GFEA044_GWU', 'GWU_NRCIDD', cA1_CODMUNE )
			EndIf
			
			oModelNFE:SetValue( 'GFEA044_GWU', 'GWU_PAGAR' , IIF((aDados[12] <> "F" .and. aDados[12] <> "D"),"2","1") )
		EndIf		
		If lRet .And. oModelNFE:VldData()
			If lCommit
				oModelNFE:CommitData()
			EndIf
		Else
			If !Empty(oPrVldNFE["MSGERR"])
				oModelNFE:SetErrorMessage(,,,"F1_DOC",,"Pré-Validação GFE" + " - " + oPrVldNFE["MSGERR"],)
			EndIf
			If IsInCallStack("GFEM011")
				CreatLog(ArqvLog, oModelNFE, cProTable,  cRotiProt, aDados)
			Else
				If ValErro(oModelNFE)
					GFEMessage(0,GFEM011009,STR0055 +CRLF+CRLF+oModelNFE:GetErrorMessage()[6]+" "+oModelNFE:GetErrorMessage()[4],STR0081 ) //Atenção - Inconsistência com o Frete Embarcador (SIGAGFE)
					lRet := .F.
				EndIf
			EndIf
		
		EndIf
		
		oModelNFE:Deactivate()
		oModelNFE:Destroy()
		oModelNFE := Nil
		FreeObj(oModelNFE)
		FreeObj(oPrVldNFE)
	ElseIf (!(cTipo $ 'I|P') .And. cTpFrete == 'S')
		oModelNFE:SetErrorMessage(,,,"F1_TPFRETE",,"Tipo de Frete não informado no Documento de Entrada.", "Necessário informar o campo TIPO FRETE na aba 'Informações Danfe' para continuar com a integração da nota fiscal.")
		If IsInCallStack("GFEM011")
			CreatLog(ArqvLog, oModelNFE, cProTable,  cRotiProt, aDados)
		EndIf
	EndIf

	RestArea(aAreaSA1)
	RestArea(aAreaSA2)
	RestArea(aAreaGWU)
	RestArea(aAreaGW8)
	RestArea(aAreaGW1)
	RestArea(aAreaSD1)

Return lRet
//---------------------------------------------------
/*/
Seta os Itens do Documento de Carga
@author Felipe Machado de Oliveira
@version P11
@since 23/05/2013
/*/
//---------------------------------------------------
Static Function SetIteDocCar(oModelNFE,oModelItens,cF1_CDTPDC,cEmisDc,cSerDc,cNrDc,nI,cTipoInter,aDadosItens)
	Local cCod       := IIF(cTipoInter == "TODOS",SD1->D1_COD,aDadosItens[nI][2])
	Local nQuant     := IIF(cTipoInter == "TODOS",SD1->D1_QUANT,aDadosItens[nI][3])
	Local cB5_altura := Posicione("SB5",1,xFilial("SB5")+(cCod),"B5_ALTURA")
	Local nVolume    := (cB5_altura * SB5->B5_LARG * SB5->B5_COMPR)* (nQuant)
	Local cDsitem    := SubStr(Posicione("SB1",1,xFilial("SB1")+cCod,"B1_DESC"),1,50)
	Local nB1_pesbru := Posicione("SB1",1,xFilial("SB1")+cCod,"B1_PESBRU")
	Local cTes       := IIF(cTipoInter == "TODOS",SD1->D1_TES,aDadosItens[nI][5])
	Local nQtdalt    := IIF(cTipoInter == "TODOS",SD1->D1_PESO,aDadosItens[nI][6])
	Local cCfop      := IIF(cTipoInter == "TODOS",SD1->D1_CF,aDadosItens[nI][7])
	Local cAtuatf    := Posicione("SF4",1,xFilial("SF4")+cTes,"F4_ATUATF")
	Local nVlrIt     := 0
	Local nValor     := 0
	Local nPesor     := 0
	Local nValDesc	 := 0
	Local nValLiq    := 0
	
	Default aDadosItens := {}
	
	
	nVlrIt  := IIf(cTipoInter == "TODOS", IIf(chkICMSol(), SD1->D1_TOTAL + SD1->D1_ICMSRET + SD1->D1_VALIPI, SD1->D1_TOTAL + SD1->D1_VALIPI), 0)
	nValor  := IIF(cTipoInter == "TODOS", nVlrIt, aDadosItens[nI][4])
	nPesor  := IIF(FindFunction("OmRtPesoIt"), OmRtPesoIt(cCod,nQuant, "E",nValor), (nB1_PESBRU * nQuant) )
	nValDesc := IIF(cTipoInter == "TODOS",SD1->D1_DESC,aDadosItens[nI][8]) 
	nValLiq := (nValor - (nValor * nValDesc) / 100 )
	If nI != 1
		oModelItens:AddLine()
		oModelItens:GoLine( nI )
	EndIf
	
	//Itens do Documento de Carga
	oModelNFE:SetValue( 'GFEA044_GW8', 'GW8_CDTPDC', cF1_CDTPDC )
	oModelNFE:SetValue( 'GFEA044_GW8', 'GW8_EMISDC', cEmisDc )
	oModelNFE:SetValue( 'GFEA044_GW8', 'GW8_SERDC' , cSerDc )
	oModelNFE:SetValue( 'GFEA044_GW8', 'GW8_NRDC'  , cNrDc )
	oModelNFE:SetValue( 'GFEA044_GW8', 'GW8_SEQ'   , IIF(cTipoInter == "TODOS",SD1->D1_ITEM,aDadosItens[nI][1]) )
	oModelNFE:SetValue( 'GFEA044_GW8', 'GW8_INFO3', SD1->D1_TES)

	cCod := PadR(AllTrim(cCod),TamSx3("GUK_ITEM")[1])
	oModelNFE:SetValue( 'GFEA044_GW8', 'GW8_ITEM'  , cCod )
	
	GUK->(dbSetOrder(1) )
	IF GUK->(dbSeek(xFilial("GUK") + cCod ))
	
		If !Empty(GUK->GUK_CDCLFR)
			oModelNFE:SetValue( 'GFEA044_GW8', 'GW8_CDCLFR', GUK->GUK_CDCLFR )
		EndIf
		If !Empty(GUK->GUK_TPITEM)
			oModelNFE:SetValue( 'GFEA044_GW8', 'GW8_TPITEM', GUK->GUK_TPITEM )
		EndIf
	
	Else
		oModelNFE:SetValue( 'GFEA044_GW8', 'GW8_CDCLFR', SuperGetMv("MV_CDCLFR",.F.,"") )
	EndIf
	
	oModelNFE:SetValue( 'GFEA044_GW8', 'GW8_DSITEM', cDsitem )
	oModelNFE:SetValue( 'GFEA044_GW8', 'GW8_QTDE'  , nQuant )
	oModelNFE:SetValue( 'GFEA044_GW8', 'GW8_VALOR' , nValor )
	oModelNFE:SetValue( 'GFEA044_GW8', 'GW8_VOLUME', nVolume )
	oModelNFE:SetValue( 'GFEA044_GW8', 'GW8_PESOR' , nPesor )
	oModelNFE:SetValue( 'GFEA044_GW8', 'GW8_QTDALT', nQtdalt )
	oModelNFE:SetValue( 'GFEA044_GW8', 'GW8_ATUATF', cAtuatf )
	oModelNFE:SetValue( 'GFEA044_GW8', 'GW8_CFOP'  , SubStr(cCfop,1,TamSx3("GW8_CFOP")[1]) )
	oModelNFE:SetValue( 'GFEA044_GW8', 'GW8_VALLIQ', nValLiq)

	cTribpc := GFETribPC("1;4", SD1->D1_TES, @oModelNFE)

	oModelNFE:SetValue('GFEA044_GW8', 'GW8_TRIBP', cTribpc)	

Return Nil
//---------------------------------------------------
/*/
Seta os Trechos do Documento de Carga de sentido saída
@author Felipe Machado de Oliveira
@version P11
@since 01/07/2013
/*/
//---------------------------------------------------
Static Function SetTrechos(oModelNFS,oModelTrechos,cF2_CDTPDC,cEmisDc,cA2_EST,cA2_COD_MUN,cA1_EST,cA1_COD_MUN,cA1_ESTE,cA1_CODMUNE)
Local nI		:= 1
Local aTrechos	:= {}
Local lRedspBloc	:= ExistBlock("M461LSF2")
Local lNumProp	:= GFEEMITMP()
Local cF2_TPFRETE := ""
Local cCdTrp      := ""
Local cValor	  := ""
Local lRetorno    := .T.
Local lOMSM0111   := ExistBlock("OMSM0111")

aAdd(aTrechos, { SF2->F2_TRANSP , AllTrim(SF2->F2_TPFRETE), "", "" })

For nI := 1 To 5
	If !lRedspBloc .And. nI > 1 
		Exit
	EndIf
	If SF2->(ColumnPos('F2_REDESP' +Iif(nI == 1,"",Str(nI,1)))) > 0
		aAdd(aTrechos, { SF2->&('F2_REDESP' +Iif(nI == 1,"",Str(nI,1))) , AllTrim(SF2->F2_TPFRETE) , "" , "" } )
		If lRedspBloc
			If SF2->(ColumnPos('F2_TFRDP' +Str(nI,1))) > 0 .And. !Empty(cValor := SF2->&('F2_TFRDP' +Str(nI,1)))
				aTail(aTrechos)[2] := cValor
			EndIf
			If SF2->(ColumnPos('F2_ESTRDP' +Str(nI,1))) > 0 .And. !Empty(cValor := SF2->&('F2_ESTRDP' +Str(nI,1)))
				aTail(aTrechos)[3] := cValor
			EndIf
			If SF2->(ColumnPos('F2_CMURDP' +Str(nI,1))) > 0 .And. !Empty(cValor := SF2->&('F2_CMURDP' +Str(nI,1)))
				aTail(aTrechos)[4] := cValor
			EndIf
		EndIf
	EndIf
Next nI

aAdd(aTrechos, {Nil,Nil} )

For nI := 1 To Len(aTrechos)
		
	If nI != 1
		oModelTrechos:AddLine()
		oModelTrechos:GoLine( nI )
	EndIf

	oModelNFS:SetValue( 'GFEA044_GWU', 'GWU_CDTPDC', cF2_CDTPDC )
	oModelNFS:SetValue( 'GFEA044_GWU', 'GWU_EMISDC', cEmisDc )
	oModelNFS:SetValue( 'GFEA044_GWU', 'GWU_SERDC' , SF2->F2_SERIE )
	oModelNFS:SetValue( 'GFEA044_GWU', 'GWU_NRDC'  , SF2->F2_DOC )
	oModelNFS:SetValue( 'GFEA044_GWU', 'GWU_SEQ'   , MsStrZero(nI,2) )

	If lNumProp
		If Empty(aTrechos[nI][1])
			cCdTrp := ""
		Else
			// Pode existir mais de um emitente referenciando o mesmo transportador no ERP
			GU3->( dbSetOrder(13) )
			If GU3->( dbSeek( xFilial("GU3")+aTrechos[nI][1] ) )
				cCdTrp := GU3->GU3_CDEMIT
				While !GU3->(Eof()) .And. GU3->GU3_FILIAL+GU3->GU3_CDTERP == xFilial("GU3")+aTrechos[nI][1]
					If GU3->GU3_SIT == "1"
						cCdTrp := GU3->GU3_CDEMIT
						Exit
					EndIf
					GU3->(DbSkip())
				EndDo
			EndIf

			If Empty(cCdTrp)
				oModelNFS:SetErrorMessage(STR0068,STR0069,STR0070,STR0071,STR0072,STR0073 + aTrechos[nI][1] + STR0074) //GFEA044,GWU_CDTRP,GFEA044_GWU,GWU_CDTRP, Transp não existe, não existe cadastro correspondente para o transportador ou esta inativo, no GFE.
			EndIf
		EndIf

		oModelNFS:SetValue( 'GFEA044_GWU', 'GWU_CDTRP' , cCdTrp )
	Else
		If FindFunction("GFECodEmit")
			SA4->( dbSetOrder(1) )
			SA4->( dbSeek(xFilial("SA4")+aTrechos[nI][1] ) )
			cCodEmit := GFECodEmit(SA4->A4_COD, SA4->A4_EST, SA4->A4_CGC)

			oModelNFS:SetValue( 'GFEA044_GWU', 'GWU_CDTRP' , cCodEmit )
		Else
			oModelNFS:SetValue( 'GFEA044_GWU', 'GWU_CDTRP' , Posicione("SA4",1,xFilial("SA4")+aTrechos[nI][1],"A4_CGC") )
		EndIf
	EndIf

	cF2_TPFRETE := Iif(Empty(aTrechos[nI][2]),SF2->F2_TPFRETE,aTrechos[nI][2])

	/* ****************************************************************************************************
	 * Ponto de entrada para utilizar outros Tipos de Frete e customizar o valor que será tratado (CIF ou FOB)
	 **************************************************************************************************** */
	If lOMSM0111
		cF2_TPFRETE := ExecBlock("OMSM0111",.f.,.f.,{SF2->F2_TPFRETE,"2",nI,aTrechos[nI,1]})
	EndIf

	oModelNFS:SetValue('GFEA044_GWU', 'GWU_PAGAR' , Iif(cF2_TPFRETE == "C" .Or. cF2_TPFRETE == "R","1","2"))

	If !Empty(aTrechos[nI + 1][1])
		dbSelectArea("SA4")
		SA4->( dbSetOrder(1) )
		SA4->( dbSeek(xFilial("SA4")+aTrechos[nI + 1][1] ) )
		If !SA4->( Eof() ) .And. SA4->A4_FILIAL == xFilial("SA4") ;
							 .And. AllTrim(SA4->A4_COD) == AllTrim(aTrechos[nI + 1][1])

			If lRedspBloc .And. !Empty(aTrechos[nI + 1][3]) .And. !Empty(aTrechos[nI + 1][4])
				oModelNFS:SetValue( 'GFEA044_GWU', 'GWU_NRCIDD', rTrim(TMS120CDUF(aTrechos[nI + 1][3], "1") + aTrechos[nI + 1][4] ))
			Else
				oModelNFS:SetValue( 'GFEA044_GWU', 'GWU_NRCIDD', rTrim(TMS120CDUF(SA4->A4_EST, "1") + SA4->A4_COD_MUN ))				
			EndIf

		EndIf
	Else
		If SF2->F2_TIPO $ 'DB'
			oModelNFS:SetValue( 'GFEA044_GWU', 'GWU_NRCIDD', rTrim(TMS120CdUf(cA2_EST, "1") + cA2_COD_MUN ))
		Else
			If Empty(cA1_CODMUNE)
				oModelNFS:SetValue( 'GFEA044_GWU', 'GWU_NRCIDD', rTrim(TMS120CdUf(cA1_EST, "1") + cA1_COD_MUN ))
			Else
				oModelNFS:SetValue( 'GFEA044_GWU', 'GWU_NRCIDD', rTrim(TMS120CdUf(cA1_ESTE, "1") + cA1_CODMUNE ))
			EndIf
		EndIf

		nI := Len(aTrechos)

	EndIf

	If !oModelTrechos:VldLineData()
		lRetorno := .F.
		exit
	EndIf

Next nI

Return lRetorno

//---------------------------------------------------
/*/ Grava as Notas Fiscais que não foram integradas (MV_FATGFE)
@author Felipe Machado de Oliveira
@version P11
@since 15/07/2013
/*/
//---------------------------------------------------
Static Function GravaGW0(oModelNFS,cNota)
Local aAreaGW0 := GW0->( GetArea() )
Local lExist := .F.

dbSelectArea("GW0")
GW0->( dbSetOrder(1) )
GW0->( dbSeek(xFilial("SF2")+PadR( "F2PEND", TamSX3("GW0_TABELA")[1] )+AllTrim(SF2->F2_DOC)+AllTrim(SF2->F2_SERIE)+AllTrim(SF2->F2_CLIENTE)+AllTrim(SF2->F2_LOJA) ) )

If !GW0->( EOF() ) .And. GW0->GW0_FILIAL == xFilial("GW0") ;
					 .And. AllTrim(GW0->GW0_TABELA) == "F2PEND" ;
					 .And. AllTrim(GW0->GW0_CHAVE) == AllTrim(SF2->F2_DOC)+AllTrim(SF2->F2_SERIE)+AllTrim(SF2->F2_CLIENTE)+AllTrim(SF2->F2_LOJA)
	lExist := .T.
Else
	lExist := .F.
EndIf

RecLock("GW0",!lExist)

If lExist
	GW0->GW0_NUM01 := GW0->GW0_NUM01 + 1
Else
	GW0->GW0_FILIAL := xFilial("SF2")
	GW0->GW0_TABELA := "F2PEND"
	GW0->GW0_CHAVE  := AllTrim(SF2->F2_DOC)+AllTrim(SF2->F2_SERIE)+AllTrim(SF2->F2_CLIENTE)+AllTrim(SF2->F2_LOJA)
	GW0->GW0_CHAR01 := SF2->F2_DOC
	GW0->GW0_CHAR02 := SF2->F2_SERIE
	GW0->GW0_CHAR03 := SF2->F2_CLIENTE
	GW0->GW0_CHAR04 := SF2->F2_LOJA
	GW0->GW0_NUM01  := 1
EndIf

GW0->GW0_MEMO01 := oModelNFS:GetErrorMessage()[6]+" "+oModelNFS:GetErrorMessage()[4]
GW0->GW0_DATA01 := dDataBase

GW0->( MsUnlock() )

RestArea( aAreaGW0 )

Return
//---------------------------------------------------
/*/ Exclui as Notas Fiscais, na tabela GW0, que não foram integradas (MV_FATGFE)
@author Felipe Machado de Oliveira
@version P11
@since 15/07/2013
/*/
//---------------------------------------------------
Function GFEM011GW0()
Local aAreaGW0 := GW0->( GetArea() )

dbSelectArea("GW0")
GW0->( dbSetOrder(1) )
GW0->( dbSeek(xFilial("SF2")+PadR( "F2PEND", TamSX3("GW0_TABELA")[1] )+AllTrim(SF2->F2_DOC)+AllTrim(SF2->F2_SERIE)+AllTrim(SF2->F2_CLIENTE)+AllTrim(SF2->F2_LOJA) ) )

If !GW0->( EOF() ) .And. GW0->GW0_FILIAL == xFilial("GW0") ;
					 .And. AllTrim(GW0->GW0_TABELA) == "F2PEND" ;
					 .And. AllTrim(GW0->GW0_CHAVE) == AllTrim(SF2->F2_DOC)+AllTrim(SF2->F2_SERIE)+AllTrim(SF2->F2_CLIENTE)+AllTrim(SF2->F2_LOJA)
	Reclock("GW0")
	dbDelete()
	GW0->( MsUnLock() )
EndIf

RestArea( aAreaGW0 )

Return
//---------------------------------------------------
/* Valida a mensagem de retorno se realmente deve gerar GW0
@author Felipe Machado de Oliveira
@version P11
@since 17/07/2013
/*/
//---------------------------------------------------
Static Function ValErro(oModel)
Local lRet := .T.

If AllTrim(oModel:GetErrorMessage()[5]) == "REGREJEITA" .Or. AllTrim(oModel:GetErrorMessage()[5]) == "EXISTGFE"
	lRet := .F.
EndIf

Return lRet

Static Function GFETribPC(cPisCred, cTes, oNfModel)
	Local cTribp  := "2"
	Local nVlrPis := 0
	Local nVlrCof := 0
	Local aRet    := Nil

	If lGfeCTrib .And. FindClass("GFEConfigTributosWritten")

		oGfeCTWritten := GFEConfigTributosWritten():New()

		If FWIsInCallStack("GFEM011NFE")
			nVlrPis := SF1->F1_VALPIS
			nVlrCof := SF1->F1_VALCOFI
			oGfeCTWritten:getNFEIdTrib(SF1->F1_FILIAL, SF1->F1_DOC, SF1->F1_SERIE, SF1->F1_FORNECE, SF1->F1_LOJA, SF1->F1_EMISSAO)
		Else
			nVlrPis := SF2->F2_VALPIS
			nVlrCof := SF2->F2_VALCOFI
			oGfeCTWritten:getNFSIdTrib(SF2->F2_FILIAL, SF2->F2_DOC, SF2->F2_SERIE, SF2->F2_CLIENTE, SF2->F2_LOJA, SF2->F2_EMISSAO)
		EndIf

		oGfeCTWritten:setIdTrib()

		aRet := oGfeCTWritten:processResponsePisCofCredList()
		If !Empty(Atail(aRet)[5])
			Conout("[GFETRIBPC] Config Tributos/GFE: " + aTail(aRet)[5])
		Else
			If nVlrPis > 0 .Or. nVlrCof > 0
				If Atail(aRet)[4]
					cTribp := "1"
				EndIf
			EndIf
		EndIf

		oGfeCTWritten:destroy()

	Else  	// Se TES Ativo - Mantem o que era feito antes

		cAliasSF4 := GetNextAlias()
		BeginSql Alias cAliasSF4
			SELECT SF4.F4_PISCRED, SF4.F4_PISCOF
			FROM %Table:SF4% SF4
			WHERE SF4.F4_FILIAL = %xFilial:SF4%
			AND SF4.F4_CODIGO = %Exp:cTes%
			AND SF4.%NotDel% 
		EndSql
		If (cAliasSF4)->(!Eof())
			If (cAliasSF4)->F4_PISCRED $ cPisCred .AND. (cAliasSF4)->F4_PISCOF != '4' // não considera
				cTribp := "1" // Sim
			EndIf
		EndIf
		(cAliasSF4)->(dbCloseArea())
	EndIf

Return cTribp
//---------------------------------------------------
/* Retorna o Código correspondente no GFE
@author Felipe Machado de Oliveira
@version P11
@since 09/09/2013
@param cCod = Codigo ERP (cliente ou fornecedor)
		cLoja = Loja ERP (cliente ou fornecedor)
		nForCli = 1=Cliente 2=Fornecedor
		lFilial = Se .T. retorna o codigo da Filial
		cFil = Filial que deseja retornar o código (se lFilial == .T.)
/*/
//---------------------------------------------------
Function GFEM011COD(cCod,cLoja,nForCli,lFilial,cFil)
// COMO A REGRA É DO GFE, FOI TRANSFERIDA A FUNÇÃO PARA UM FONTE DO GFE (GFEXINTA)
Return GFEXINTCOD(cCod,cLoja,nForCli,lFilial,cFil)
//---------------------------------------------------
/* Verifica se o Fornecedor é Transportador
@author Felipe Machado de Oliveira
@version P11
@since 12/09/2013
/*/
//---------------------------------------------------
Function GFEM011TRP(cA2_CGC, cA2_INSCR)
	Local cA4_COD    := ""
	Local aAreaSA4   := SA4->( GetArea() )
	Local lA4_MSBLQL := GFXCP12117('A4_MSBLQL')

	If Empty(cA2_CGC)
		Return ""
	EndIf

	If Empty(AllTrim(StrTran(cA2_CGC, "0", "")))
		Return ""
	EndIf

	dbSelectArea("SA4")
	SA4->( dbSetOrder(3) )
	SA4->( dbSeek( xFilial("SA4")+cA2_CGC ) )
	While SA4->( !EOF() ) .And. SA4->A4_FILIAL == xFilial("SA4");
							  .And. AllTrim(SA4->A4_CGC) == AllTrim(cA2_CGC)
		cA4_COD := Alltrim(SA4->A4_COD)
		If lA4_MSBLQL .And. SA4->A4_MSBLQL == '1'
			cA4_COD := ""
		EndIf
		SA4->( dbSkip() )
	EndDo

	If Empty(cA4_COD)
		SA4->( dbSeek( xFilial("SA4")+cA2_CGC ) )
		cA4_COD := Alltrim(SA4->A4_COD)
		If lA4_MSBLQL .And. SA4->A4_MSBLQL == '1'
			cA4_COD := ""
		EndIf
	EndIf
	RestArea( aAreaSA4 )
Return cA4_COD

//---------------------------------------------------
/* Verifica se é transp ou autono
@author Felipe Machado de Oliveira
@version P11
@since 19/10/2013
/*/
//---------------------------------------------------
Function IsPJouPF(nIsTrouAut,cTab)
	Local cRet     := "2"
	Local cTpTrans := ""
	Local cTransp  := GFEM011TRP(M->A2_CGC, M->A2_INSCR)
	Local lTMSGFE  := TmsIntGFE()

	If cTab == 'SA1'
		cTransp := GFEM011TRP(SA1->A1_CGC, SA1->A1_INSCR)
	ElseIf cTab == 'SA2'
		If FWIsInCallStack("GFEM011")
			cTransp := GFEM011TRP(SA2->A2_CGC, SA2->A2_INSCR)
		Else
			cTransp := GFEM011TRP(M->A2_CGC, M->A2_INSCR)
		EndIf
	EndIf

	If !Empty(cTransp)
		cTpTrans := Posicione('SA4',1,xFilial('SA4')+cTransp,'A4_TPTRANS')

		If nIsTrouAut == '1' //Quer saber se é transp
			If cTpTrans != '3'
				cRet := '1'
			EndIf
		ElseIf nIsTrouAut == '2' //Quer saber se é autonomo
			If cTpTrans == '3'
				cRet := '1'
			EndIf
		EndIf

	ElseIf lTMSGFE .And. SA2->A2_PAGGFE == '1'
		If nIsTrouAut == '1' //Quer saber se é trans
			If SA2->A2_TIPO == 'J'
				cRet := '1'
			Endif
		ElseIF nIsTrouAut == '2' //Quer saber se é autonomo
			If SA2->A2_TIPO == 'F'
				cRet := '1'
			EndIf
		EndIf
	EndIf
Return cRet

//---------------------------------------------------
/* Processa Redespachos para integracao TMS x GFE
@author Katia
@version P11
@since 10/10/2013
OBS: Função externalizada para o TMSXFUNG em 24/08/2018			
/*/
//---------------------------------------------------
Function GFEM011RED(cTipoInter,cNumRed,cCodFor,cLojFor,cProTable,cRotiProt,ArqvLog,nOpc,cFilOri,cViagem,cFilRed)
Return TMSFUNGRED(cTipoInter,cNumRed,cCodFor,cLojFor,cProTable,cRotiProt,ArqvLog,nOpc,cFilOri,cViagem,cFilRed)

//-----------------------------------------------------
/*/	Integra a tabela DFT(Protheus) com GWN(SIGAGFE)
@author Katia
@version P11
@since 10/10/2013
OBS: Função externalizada para o TMSXFUNG em 24/08/2018			
/*/
//------------------------------------------------------
Function GFEM011DFT(nOperation,cChvGFE,cCdtpop,cCdclfr,cUfOri,cCdMunO,cUfDes,cCdMunD,nReqDTQ,cCepOri,cCepDes,aCalcRom, lCalcAut)
Return TMSFUNGDFT(nOperation,@cChvGFE,cCdtpop,cCdclfr,cUfOri,cCdMunO,cUfDes,cCdMunD,nReqDTQ,cCepOri,cCepDes,@aCalcRom, lCalcAut)

//---------------------------------------------------
/*/Intregração TMS - Redespachantes x Documentos
@author Katia
@version P11
@since 04/10/2013
OBS: Função externalizada para o TMSXFUNG em 24/08/2018			
/*/
//---------------------------------------------------
Function GFEM011DFV(nRecnoDFV, ArqvLog, lViagem, nRecnoDUD)
Return TMSFUNGDFV(nRecnoDFV, ArqvLog, lViagem, nRecnoDUD)

//---------------------------------------------------
/*/
Trechos do Documento de Carga
@author Katia
@version P11
@since 14/10/2013
OBS: Função externalizada para o TMSXFUNG em 24/08/2018			
/*/
//---------------------------------------------------
Function GFEM011TRE(nOpc,oModelNFS,oModelTrechos,cCdTpDc,cEmisDc,cUfDes,cCdMunDes,cNumNFC,cSerNFC,cTransp,nTrecho,cA1_EstDes,cA1_CdMuDes,cTipVei,lViagem,cA1_CEPDes,cCodFor,cLojFor)
Return TMSFUNGTRE(nOpc,oModelNFS,oModelTrechos,cCdTpDc,cEmisDc,cUfDes,cCdMunDes,cNumNFC,cSerNFC,cTransp,@nTrecho,cA1_EstDes,cA1_CdMuDes,cTipVei,lViagem,cA1_CEPDes,cCodFor,cLojFor)

//---------------------------------------------------
/*/Intregração TMS - Redespachantes x Documentos
@author Katia
@version P11
@since 04/10/2013
OBS: Função externalizada para o TMSXFUNG em 24/08/2018			
/*/
//---------------------------------------------------
Function GFEM011TMS(cTipoInter,cNumRed,cCodFor,cLojFor,cProTable,cRotiProt,ArqvLog,nOpc)
Return TMSFUNGTMS(cTipoInter,cNumRed,cCodFor,cLojFor,cProTable,cRotiProt,ArqvLog,nOpc)
//---------------------------------------------------
/* Processa Viagens para integracao TMS x GFE
@author Katia
@version P12
@since 16/11/2016
OBS: Função externalizada para o TMSXFUNG em 24/08/2018			
/*/
//---------------------------------------------------
Function GFEM011VGE(cFilOri, cViagem, nOpc, ArqvLog)
Return TMSFUNGVGE(cFilOri, cViagem, nOpc, ArqvLog)

//------------------------------------------------------------------
/*/{Protheus.doc} GFEM11TRRDA
Função que grava os Trechos dos Redespachos Adicionais
da Viagem (DTQ/DUD) e do Redespacho (DFT/DFV)
@author	Katia
@version	1.0
@since		13/12/2016
@sample    Esta função tem por objetivo gravar os trechos
			do Itinerario com base nos Redespachos da Viagem (DJN)
			e Redespachos Adicionais do Redespacho (DJO)
OBS: Função externalizada para o TMSXFUNG em 24/08/2018						
/*/
//-------------------------------------------------------------------
Function GFEM11TRRDA(nOpc,oModelNFS,oModelTrechos,nTrecho,cSeq,lNumProp,cA1_CEPDes,cCdTpDc,lViagem)
Return TMSFGTRRDA(nOpc,oModelNFS,oModelTrechos,nTrecho,@cSeq,lNumProp,cA1_CEPDes,cCdTpDc,lViagem)

//---------------------------------------------------
/*/{Protheus.doc} GFEM011GWE
Função que atualiza Relacionamento Documento de Carga GFE
e Documento de Transporte TMS
@author	Katia
@version	1.0
@since		14/12/2016
@sample    Esta função tem por objetivo gravar a tabela
			GWE
OBS: Função externalizada para o TMSXFUNG em 24/08/2018						
/*/
//----------------------------------------------------

Function GFEM011GWE(cFilDoc,cDoc,cSerie,cFilOri,cViagem,cNumRed)
Return TMSFUNGGWE(cFilDoc,cDoc,cSerie,cFilOri,cViagem,cNumRed)
//-------------------------------------------------------------------------
/*/{Protheus.doc} GFEM011SOL
Função que carrega as Notas de Cliente vinculada a SC
@author	Katia
@version	1.0
@since		06/03/2017
@sample    Esta função tem por objetivo pesquisar as
			Notas vinculadas a SC para atualizar a tabela no SIGAGFE - GXP
OBS: Função externalizada para o TMSXFUNG em 24/08/2018						
/*/
//-------------------------------------------------------------------------
Function GFEM011SOL(cFilOri,cNumSol,oMdGridGXP)
Return TMSFUNGSOL(cFilOri,cNumSol,oMdGridGXP)

//---------------------------------------------------
/*/{Protheus.doc} GFEM011GXP
Função que atualiza o Documento de Origem no SIGAGFE
@author	Katia
@version	1.0
@since		06/03/2017
@sample    Esta função tem por objetivo gravar a tabela
			GXP
OBS: Função externalizada para o TMSXFUNG em 24/08/2018			
/*/
//----------------------------------------------------
Function GFEM011GXP(oMdGridGXP,cNfeId,cFilOri,cEmisDTC,cSerNfc,cNumNfc,oMdGridGXP ) 
Return TMSFUNGGXP(oMdGridGXP,cNfeId,cFilOri,cEmisDTC,cSerNfc,cNumNfc,oMdGridGXP ) 

//---------------------------------------------------
/*/{Protheus.doc} GFEEMITMP
Função que verifica o controle do codigo de emitente  (GU3)
@author	Katia
@version	1.0
@since		12/07/2017
@sample    Esta função tem por objetivo verificar a
regra utilizada para o controle da Numeração do Codigo
do Emitente entre TMS x GFE (MV_EMITMP)
/*/
//----------------------------------------------------
Function GFEEMITMP()
Return GFEXIEMITM()

Static Function chkICMSol()
	Local lRet := .F.
	Local aRet := Nil
	Local oGfeCTWritten := Nil

	If lGfeCTrib .And. FindClass("GFEConfigTributosWritten") // Se paramento está habilitado considera os dados somente pelo configurador de tributos

		oGfeCTWritten := GFEConfigTributosWritten():New()

		oGfeCTWritten:getNFEIdTrib(SF1->F1_FILIAL, SF1->F1_DOC, SF1->F1_SERIE, SF1->F1_FORNECE, SF1->F1_LOJA, SF1->F1_EMISSAO)

		oGfeCTWritten:setIdTrib()

 		aRet := oGfeCTWritten:processResponseAgregICMSRetNFList()

		lRet := aTail(aRet)[4]
		If !Empty(aTail(aRet)[5])
			Conout("[CHKICMSOL] Config Tributos/GFE: " + aTail(aRet)[5])
		EndIf

		oGfeCTWritten:destroy()

	Else  	// Se TES Ativo - Mantem o que era feito antes
		lRet := Posicione("SF4",1,xFilial("SF4") + SD1->D1_TES,"F4_INCSOL") == "S"
	EndIf

Return lRet


//-----------------------------------------------------
/*/	Integra o Documento de Entrada com o SIGAGFE
@author 
@version P11
@since 22/05/2013
@Description: Repasse de antiga função A103VlIGfe do mata103 para o GFE
/*/
//------------------------------------------------------
Function GfeIntA103(lIsIncl,lIsClass, lCommit,cNumNfGFE)
	Local aDados     := {}
	Local aDadosIten := {}
	Local aRet       := Nil
	Local cTpFrete   := ""
	Local lRet 		 := .T.
	Local nI 		 := 0
	Local nVlrIt	 := 0
	Local oGfeCTWrt  := Nil
	Local lIntGFE    := SuperGetMV("MV_INTGFE",.F.,.F.)
	Local cIntGFE2   := SuperGetMV("MV_INTGFE2",.F.,"2")
	Local cGFEI10    := SuperGetMv("MV_GFEI10",.F.,"2")
	Local lGfeCTrib  := SuperGetMv("MV_GFECTRI",,.F.)

	Default cNumNfGFE := ""

	If Type("aNfeDanfe") == "A"
		If !Empty(aNfeDanfe[14])
			cTpFrete := SubStr(aNFEDanfe[14],1,1)
		Else
			//Se o 'aNfeDanfe[14]' estiver vazio significa que o tipo de frete não foi informado (sem frete) então forcei o "S" para que não haja integração com o GFE
			cTpFrete := "S"
		EndIf
	EndIf

	// Tratamento para quando o parametro MV_TPNRNFS = 3 para controlar a numeracao da nota pela SD9
	// a variavel cNFiscal estara em branco e o numero da nota estara armazenado em cNumNfGFE
	If Empty(cNumNfGFE)
		cNumNfGFE := cNFiscal 
	EndIf

	If (cTpFrete <> "S") .And. lIntGFE .And. cIntGFE2 $ "1" .And. cGFEI10 == "1" .And. (lIsIncl .Or. lIsClass) .And. !(AllTrim(cTipo) $ 'I|P')
		aAdd(aDados, AllTrim(cTipo)    + Space( (TamSX3("F1_TIPO")[1]) - (Len( AllTrim(cTipo) )) ) )     	//F1_TIPO
		aAdd(aDados, AllTrim(cFormul)  + Space( (TamSX3("F1_FORMUL")[1]) - (Len( AllTrim(cFormul) )) ) )   	//F1_FORMUL
		aAdd(aDados, AllTrim(cNumNfGFE) + Space( (TamSX3("F1_DOC")[1]) - (Len( AllTrim(cNumNfGFE) )) ) )  	//F1_DOC
		aAdd(aDados, AllTrim(cSerie)   + Space( (TamSX3("F1_SERIE")[1]) - (Len( AllTrim(cSerie) )) ) )    	//F1_SERIE
		aAdd(aDados, dDEmissao )                                                                           	//F1_EMISSAO
		aAdd(aDados, AllTrim(cA100For) )  																	//F1_FORNECE
		aAdd(aDados, AllTrim(cLoja) )    																	//F1_LOJA
		aAdd(aDados, AllTrim(cEspecie) + Space( (TamSX3("F1_ESPECIE")[1]) - (Len( AllTrim(cEspecie) )) ) ) 	//F1_ESPECIE
		aAdd(aDados, "" )                                                                                  	//F1_NFORIG
		aAdd(aDados, aNFEDanfe[1] )                        													//F1_TRANSP
		aAdd(aDados, aNFEDanfe[5] )                        													//F1_VOLUME1
		aAdd(aDados, SubStr(aNFEDanfe[14],1,1) )         													//F1_TPFRETE
		aAdd(aDados, IIF(Empty(SF1->F1_VALICM),0,SF1->F1_VALICM) ) 											//F1_VALICM
		aAdd(aDados, xFilial("SF1") )
		aAdd(aDados, "" )                                  	 												//F1_SERORIG
		aAdd(aDados, aNFEDanfe[13] )                       	 												//F1_CHVNFE

		For nI := 1 to Len(aCols)
			If !aCols[nI][Len(aCols[nI])]

				If lGfeCTrib .And. FindClass("GFEConfigTributosWritten") // Se paramento está habilitado considera os dados somente pelo configurador de tributos

					oGfeCTWrt := GFEConfigTributosWritten():New()

					oGfeCTWrt:getNFEIdTrib(xFilial("SF1"), cNumNfGFE, cSerie, cA100For, cLoja, dDEmissao)

					oGfeCTWrt:setIdTrib()

					aRet := oGfeCTWrt:processResponseAgregICMSRetNFList()
					If !Empty(aRet) .And. aTail(aRet)[4]
						nVlrIt := GDFieldGet("D1_TOTAL", nI) + GDFieldGet("D1_ICMSRET", nI) + GDFieldGet("D1_VALIPI", nI)
					Else
						nVlrIt := GDFieldGet("D1_TOTAL", nI) + GDFieldGet("D1_VALIPI", nI)
					EndIf

					oGfeCTWrt:destroy()

				Else  	// Se TES Ativo - Mantem o que era feito antes
					If Posicione("SF4", 1, xFilial("SF4") + GDFieldGet("D1_TES", nI), "F4_INCSOL") == "S"
						nVlrIt := GDFieldGet("D1_TOTAL", nI) + GDFieldGet("D1_ICMSRET", nI) + GDFieldGet("D1_VALIPI", nI)
					Else
						nVlrIt := GDFieldGet("D1_TOTAL", nI) + GDFieldGet("D1_VALIPI", nI)
					EndIf
				EndIf

				aAdd(aDadosIten, { GDFieldGet("D1_ITEM", nI),;
								   GDFieldGet("D1_COD", nI),;
								   GDFieldGet("D1_QUANT", nI),;
								   nVlrIt,;
								   GDFieldGet("D1_TES", nI),;
								   GDFieldGet("D1_PESO", nI),;
								   GDFieldGet("D1_CF", nI),;
								   GDFieldGet("D1_DESC", nI),;
								   GDFieldGet("D1_SEGURO", nI),;
								   GDFieldGet("D1_DESPESA", nI),;
								   GDFieldGet("D1_TOTAL", nI),;
								   GDFieldGet("D1_VALIPI", nI),;
								   GDFieldGet("D1_VALICM", nI),;
								   GDFieldGet("D1_IPI", nI),;
								   GDFieldGet("D1_PICM", nI)})
			EndIf
		Next nI
		
		lRet := GFEM011NFE("UNICO", aDados, aDadosIten, , , , lCommit)
	EndIf

Return lRet
