#include "Ofiom030.ch"
#include "Protheus.ch"

#include "OFIXDEF.CH"

#include "TOPCONN.ch"

Static cMVMIL0006 := GetNewPar("MV_MIL0006","")
STATIC cSGBD := TcGetDb()
STATIC cMVAPOUNI := GetNewPar("MV_APOUNI ","S")
Static lVOITPATEN := FindFunction("FGX_VOITPATEN")
Static lAltInconv := findFunction("OX001066K_AlteraDescricaoInconveniente")
Static lOm030Ast  := ExistBlock("OM030AST")
Static checkIni := .f.
Static lInconveniente := (GetNewPar("MV_INCORC","N") == "S")

#DEFINE APOAUT_SEL        01
#DEFINE APOAUT_STATUS     02
#DEFINE APOAUT_TIPTEM     03
#DEFINE APOAUT_DESCTIPTEM 04
#DEFINE APOAUT_VO4RECNO   05
#DEFINE APOAUT_DATINI     06
#DEFINE APOAUT_HORINI     07
#DEFINE APOAUT_DATFIM     08
#DEFINE APOAUT_HORFIM     09
#DEFINE APOAUT_ARRAY_VO4  10
#DEFINE APOAUT_TIPSER     11
#DEFINE APOAUT_DESTIPSER  12
#DEFINE APOAUT_SEQINC     13
#DEFINE APOAUT_GRUINC     14
#DEFINE APOAUT_CODINC     15
#DEFINE APOAUT_DESINC     16

#DEFINE APOAUT_ARRAY_VO4_CODSER 01
#DEFINE APOAUT_ARRAY_VO4_TEMPAD 02
#DEFINE APOAUT_ARRAY_VO4_RECNO  03
#DEFINE APOAUT_ARRAY_VO4_DATINI 04
#DEFINE APOAUT_ARRAY_VO4_HORINI 05
#DEFINE APOAUT_ARRAY_VO4_DATFIN 06
#DEFINE APOAUT_ARRAY_VO4_HORFIN 07
#DEFINE APOAUT_ARRAY_VO4_GRUSER 08
#DEFINE APOAUT_ARRAY_VO4_CODPRO 09

#DEFINE SRV_TIPTEM    01 // VO4->VO4_TIPTEM
#DEFINE SRV_FATPAR    02 // VO4->VO4_FATPAR
#DEFINE SRV_LOJA      03 // VO4->VO4_LOJA
#DEFINE SRV_GRUSER    04 // VO4->VO4_GRUSER
#DEFINE SRV_CODSER    05 // VO4->VO4_CODSER
#DEFINE SRV_TIPSER    06 // VO4->VO4_TIPSER
#DEFINE SRV_TEMPAD    07 // VO4->VO4_TEMPAD
#DEFINE SRV_VALVEN    08 // VO4->VO4_VALVEN
#DEFINE SRV_CODSEC    09 // VO4->VO4_CODSEC
#DEFINE SRV_DATINI    10 // VO4->VO4_DATINI
#DEFINE SRV_HORINI    11 // VO4->VO4_HORINI
#DEFINE SRV_DATFIM    12 // VO4->VO4_DATFIN
#DEFINE SRV_HORFIM    13 // VO4->VO4_HORFIN
#DEFINE SRV_CODCAM    14 // VO4_CODCAM
#DEFINE SRV_CODFAS    15 // VO4->VO4_CODFAS
#DEFINE SRV_SEQINC    16 // VO4->VO4_SEQINC	// 16 - Sequencia do Inconveniente
#DEFINE SRV_NAOUSADO  17 // ""				// 17 - Campo nao utilizado mais
#DEFINE SRV_PRODUTIVO 18 // cProdutivo		// 18 - Produto que esta trabalhando na OS
#DEFINE SRV_EXCLUIDO  19 // .f. // Indica se o registro esta excluido
#DEFINE SRV_VO4RECNO  20 // VO4->(Recno())
#DEFINE SRV_VALDES    21 // VO4->VO4_VALDES // 21 - Valor do Desconto
#DEFINE SRV_PERDES    22 // VO4->VO4_PERDES // 22 - Percentual de Desconto
#DEFINE SRV_VALSER    23 // VO4->VO4_VALSER // 23 - Valor do Servico


#Define EVT_ORC_APROVADO_AGUARD_SERVICO "35"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณ OFIOM030 ณ Autor ณ  Fabio                ณ Data ณ 19/08/99 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Requisicao de Servico                                      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ Generico  (Modelo3)                                        ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OFIOM030(cOSFiltro,lNoMBrowse,xAutoCab,xAutoItens,nOpcAuto)
Private aRotina := MenuDef()
Private cCadastro := OemToAnsi(STR0004) //"Requisicao de Servicos"
Private aIndVO1   := {}
Private cCondicao := ""
Private aVerPad   := {} //, bFiltraBrw
Private lVZ1Pec := .f.
Private lVZ1Ser := .f.
Private aVetor  := {}
Private cAchou  := ""
Private cOSFilter := ""
Private aDelMotiv := {}
//
Private cTpTpoPEVM := space(4) // Tipo de Tempo Pecas
Private cProdPEVM  := space(6) // Tipo de Tempo Servico
//
Private aAutoCab   := {}
Private aAutoItens := {}
Private lOM030Auto := ( xAutoItens <> NIL )
Private lAutoApont := .f.
Private oCliente   := DMS_Cliente():New()
//
Private lVOIVLSVAC := (VOI->(FieldPos("VOI_VLSVAC")) <> 0)
//
Private lAlterou   := .f.
Private lInicial   := .t.	//Mauro Innovare - 07/06/2023 (Para tratar o aAlter na Tela de abertura)
//
Private lMultMoeda := FGX_MULTMOEDA()
Default cOSFiltro := "" // Rafael - 22/03 - Filtro do Mbrowse
Default lNoMBrowse := .f.
cOSFilter := cOSFiltro // Variavel utilizada na funcao OM030()

if ! checkIni .and. ! IsBlind() .and. ExistFunc("FG_CHKINI")
	FG_CHKINI()
	checkIni := .t.
endif

//AjustaHelp()











If AMIIn(11,14,41)

	If !lOM030Auto

		If lNoMBrowse
			dbSelectArea("VO1")
			If ( nOpc <> 0 ) .And. !Deleted()
				bBlock := &( "{ |a,b,c,d,e| " + aRotina[ nOpc,2 ] + "(a,b,c,d,e) }" )
				Eval( bBlock, Alias(), (Alias())->(Recno()),nOpc)
			EndIf
		Else

			//Filtra Ordem de Servicos Abertas
			dbSelectArea("VO1")
			//RetIndex()
			VO1->(dbSetOrder(1))
			VO1->(dbClearFilter())
			IF !empty(cOSFiltro)
				FilBrowse("VO1",{},"VO1->VO1_FILIAL=='"+xFilial("VO1")+"' .and. VO1->VO1_NUMOSV=='"+cOSFiltro+"'",.t.) 	// Filtra a OS
			Else
				dbSelectArea("VAI")
				VAI->(dbSetOrder(4))
				VAI->(dbSeek(xFilial("VAI")+__cUserID))

				if VAI->VAI_TIPTEC == "4"
					DbSelectArea("VO1")
					VO1->(dbSetOrder(1))

					cCondicao := "VO1->VO1_FUNABE == VAI->VAI_CODTEC"

					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณ Endereca a funcao de BROWSE                                  ณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
					FilBrowse('VO1',{},cCondicao) // Filtra Usuario

				Endif
			Endif
			mBrowse(6, 1, 22, 75, "VO1",,,,,, OM030LEG())
			VO1->(dbClearFilter())

		Endif

	Else

		aAutoCab := xAutoCab
		aAutoItens := xAutoItens
		MBrowseAuto( nOpcAuto , , "VO1" , .f. , .T. )

	EndIf

EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณOM030     บAutor  ณFabio               บ Data ณ  07/07/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMonta tela                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OM030(cAlias,nReg,nOpc)

Local nPosPed := 0
Local _nimil
Local bCampo   := { |nCPO| Field(nCPO) }

Local nPosicaoVO2 := 0 , _ni := 0
Local cCodSer
Local cAliasEnchoice , cAliasGetD , cLinOk , cTudOk , cFieldOk
Local nCntFor   := 0
Local nPosRec   :=0  // Posicao do registro dentro do aCols
Local dDataAutoApont, nHoraAutoApont
Local dDtIniAutoApont, nHrIniAutoApont, dDtFinAutoApont, nHrFinAutoApont
Local lVAI_VALSER := VAI->(FieldPos("VAI_VALSER")) > 0
Local aObjects  := {} , aPosObj := {} , aPosObjApon := {} , aInfo := {} , aSizeAut := MsAdvSize() // Variaveis para posicionamento de Tela
Local cOSFiltro := ""
Local nPosVO2Soft
Local nLin, nCol
Local cMV_SRV3PD := GetNewPar("MV_SRV3PD","N")
Local nCpo
Local aSrvcProc := {}, lApontIniFim
Private cTitulo , oFolder030
Private aTitles  := {OemToAnsi(STR0006),OemToAnsi(STR0007)} //"&Servico"###"&Apontamento Manual"
Private aCols := {} , aHeader := {} , aCpoEnchoice  :={}
Private aColsSrv:={},aHeaderSrv:={},nSrv:=1             // Servico
Private aColsIniFim:={},aHeaderIniFim:={},nIniFim:=1    // Inicio/Fim do Servico
Private aAlter := {}                                    // Verifica se pode alterar o registro
Private aAgrupSer := {} , aPecasReq := {}
Private NomeRel                                         // Impressora selecionada p/ relatorio de Ferramentas
Private aTELA[0][0], aGETS[0], n:=1,nOpca:=0
Private oGetSrv,oGetIniFim
Private cKeyAce := "" , aSrvRetorno := {}
Private nLinhas := 0  , nAba := 0 , nUsadoSrv := 0 , nUsadoIniFim := 0
Private cIndice , aIndice := {} , aSeguros := {} , aControle := {},aSrv3rd := {}
Private aProdutivoOnLine:={}
Private oBBranco    := LoadBitmap( GetResources(), "FOLDER9" )
Private oBVerde     := LoadBitmap( GetResources(), "BR_VERDE" )
Private oBVermelho  := LoadBitmap( GetResources(), "BR_VERMELHO" )
Private oBAmarelo   := LoadBitmap( GetResources(), "BR_AMARELO" )
Private oBAzul      := LoadBitmap( GetResources(), "BR_AZUL" )
Private oBPreto     := LoadBitmap( GetResources(), "BR_PRETO" )
Private oObserv030
Private xFlag   := 0
Private oDlgServico
Private lFechaObj := .f.
Private aMemos    := {{"VO4_OBSMEM","VO4_OBSERV"}}
Private aNewBot   := {}

Private lVO1DATATE := ( VO1->(FieldPos("VO1_DATATE")) <> 0 )

Private aApontTar := {}
Private aApontSrvc := {}

If lOM030Auto
	If aScan(aAutoCab, { |x| x[1] == "AUTAPONT" }) <> 0
		lAutoApont := getDatAutoCab("AUTAPONT")
	EndIf
EndIf

If Type("cOSFilter") # "U"
	cOSFiltro := cOSFilter
EndIf

VO1->(dbClearFilter())

if iif(lOm030Ast,ExecBlock("OM030AST",.F.,.F.,{VO1->VO1_STATUS}),VO1->VO1_STATUS) # "A"

   Help("  ",1,"OSNABERTA")

   DbSelectArea("VO1")
   DbSetOrder(1)

   Return

EndIf

If !OM030033K_PermiteRequisitarAposEntregaVeic()
	Return
Endif

DbSelectArea("VV1")
VV1->(DbSetOrder(1))
VV1->(DbSeek(xFilial("VV1")+VO1->VO1_CHAINT))

If FindFunction("FM_VEIGAR")
	FM_VEIGAR() // Verifica se o Veiculo esta em garantia - 04/05/2009 - Andre Luis Almeida
EndIf

DbSelectArea("VE1")
VE1->(DbSetOrder(1))
VE1->(DbSeek(xFilial("VE1")+VV1->VV1_CODMAR))

dbSelectArea("VO2")
nPosicaoVO2:=Recno()

// Verifica quais pecas foram requisitadas para o servico...
aPecasReq := FS_PECREQ()

VO2->(dbSetOrder(1))
VO2->(dbSeek(xFilial("VO2")+VO1->VO1_NUMOSV+"S"))
nPosicaoVO2:=Recno()

SA1->(dbSetOrder(1))
SA1->(dbSeek(xFilial("SA1")+VO1->VO1_PROVEI+VO1->VO1_LOJPRO))

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Cria variaveis M->????? da Enchoice                          ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
RegToMemory("VO2",.T.)

aCpoEnchoice  :={}
DbSelectArea("SX3")
SX3->(DbSetOrder(1))
SX3->(DbSeek("VO2"))
While !Eof().and.(x3_arquivo=="VO2")

	If X3USO(x3_usado).and.cNivel>=x3_nivel.And.!(Alltrim(x3_campo) $ [VO2_DEVOLU/VO2_TIPREQ])
		AADD(aCpoEnchoice,x3_campo)
		&("M->"+x3_campo):= CriaVar(x3_campo)
	Endif

	SX3->(dbSkip())

End

nPosVO2Soft := 0
If VO2->(Found())

	If !Softlock("VO2")
		return .f.
	EndIf
	nPosVO2Soft := VO2->(Recno())

	DbSelectArea("VO2")
	For nCntFor := 1 TO FCount()
		M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
	Next

Endif

// Monta numero sequencial - VO2_NOSNUM
FS_SXENUM030(M->VO2_NUMOSV)

nOpcE := 3
nOpcG := 3
nOpc  := 3

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Cria variaveis M->????? da GetDados                          ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
RegToMemory("VO4",.T.)

// Monta aHeaders
nUsadoSrv:=nUsadoIniFim:=0
FS_MTAHEADER()

// Inclui coluna de registro atraves de funcao generica
dbSelectArea("VO4")
ADHeadRec("VO4",aHeaderSrv)
// Posicao do registro
nPosRec   := Len(aHeaderSrv)
nUsadoSrv := Len(aHeaderSrv)

Aadd(aAlter,{ } )
Aadd(aAlter,{ } )

VO4->(dbSetOrder(1))
VO4->(dbSeek(xFilial("VO4")+VO2->VO2_NOSNUM))

cCodSer := Space(Len(VO4->VO4_CODSER))

Do While !eof() .and. VO4->VO4_NOSNUM == VO2->VO2_NOSNUM .And. VO4->VO4_FILIAL == xFilial("VO4")

	FG_SEEK("VOK","VO4->VO4_TIPSER",1,.f.)

	// Servico nao foi liberado ...
	If Empty(VO4->VO4_DATDIS)

		// 0-Mao-de-Obra Gratuita /1-Mao-de-Obra/3-Valor Livre c/Base na Tabela/4-Retorno de Servico
		If !( VOK->VOK_INCMOB $ "2/5/6" )

			OM030001_AddaColsIniFim()

		EndIf

		// Adciona Servicos
		If Ascan(aColsSrv,{ |x| x[FG_POSVAR("VO4_CODSER","aHeaderSrv")] == VO4->VO4_CODSER .and. x[FG_POSVAR("VO4_TIPSER","aHeaderSrv")] == VO4->VO4_TIPSER } ) == 0 ;
			.Or. VOK->VOK_INCMOB $ "2/5/6"

			// Adciona controle de Registro
			Aadd( aControle , { "VO4_SEQUEN" , VO4->VO4_SEQUEN , STR0148 } ) // "Controle de Srv Terceiro"
			// Adiciona posicao anterior dos titulos gerados no financeiro para servico de 3rd
			If VOK->VOK_INCMOB=="2" // Terceiros
				FS_ADD3RD()
			Endif
			VOI->( MsSeek( xFilial("VOI") + VO4->VO4_TIPTEM ) )

			If VOI->VOI_SEGURO == "1"
				Aadd( aSeguros , { VOI->VOI_TIPTEM , VOI->VOI_TIPFRA , .t. } )
			EndIf

			AADD(aColsSrv,Array(nUsadoSrv+1))
			Aadd(aAlter[1],{})

			For _ni := 1 to nUsadoSrv

				// a funcao E_MSMM traz somente o conteudo se a variavel inclui estiver .f.
				If aHeaderSrv[_ni,2] == "VO4_OBSERV"
					Inclui := .f.
				EndIf

				// verifica se e a coluna de controle do walk-thru
				If IsHeadRec(aHeaderSrv[_ni,2])
					aColsSrv[Len(aColsSrv),_ni] := VO4->(RecNo())
				ElseIf IsHeadAlias(aHeaderSrv[_ni,2])
					aColsSrv[Len(aColsSrv),_ni] := "VO4"
				Else
					if aHeaderSrv[_ni,10] # "V"
						aColsSrv[Len(aColsSrv),_ni]:= FieldGet(FieldPos(aHeaderSrv[_ni,2]))
					else
						aColsSrv[Len(aColsSrv),_ni]:= &(aHeaderSrv[_ni,11])
						If aHeaderSrv[_ni,2] == "VO4_NOMCLI"
							aColsSrv[Len(aColsSrv),_ni] := Posicione("SA1",1,xFilial("SA1")+VO4->VO4_FATPAR+VO4->VO4_LOJA,"A1_NOME")
						Endif
					endif
				EndIf

				// a funcao E_MSMM traz somente o conteudo se a variavel inclui estiver .f.
				If aHeaderSrv[_ni,2] == "VO4_OBSERV"
					Inclui := .t.
				EndIf

				If !(AllTrim(aHeaderSrv[_ni,2]) $ "VO4_TIPTEM/VO4_VALDES/VO4_PERDES/VO4_VALSER/VO4_TIPSER") .or. ( lVAI_VALSER .and. AllTrim(aHeaderSrv[_ni,2]) == "VO4_VALSER" )
					Aadd(aAlter[1,Len(aAlter[1])], aHeaderSrv[_ni,2] )
				EndIf

			Next

			aColsSrv[Len(aColsSrv),nUsadoSrv+1]:=.F.
			cGruSer := VO4->VO4_GRUSER
			cCodSer := VO4->VO4_CODSER

		EndIf

		nPosPed := FG_POSVAR("VO4_PEDCOM","aHeaderSrv")
		// Se Foi marcado hora para o servico nao podera ser alterado ou se for servico de terceiros.
		If Len(aColsSrv) # 0 .and. ;
			( ( !Empty(VO4->VO4_CODPRO) .or. !Empty(VO4->VO4_DATINI) ) .or. ;
			  ( cMV_SRV3PD == "P" .and. VOK->VOK_INCMOB=="2" )  .or. ;
			  ( nPosPed > 0 .and. !Empty(aColsSrv[Len(aColsSrv),nPosPed]) ) )

			If ( cMV_SRV3PD	== "P" .And. VOK->VOK_INCMOB=="2" ) .or. ( nPosPed > 0 .and. !Empty(aColsSrv[Len(aColsSrv),nPosPed]) ) // Pedido

				aAlter[1,Len(aAlter[1])] := {" "} // Quando Servi็o de Terceiro e for Peidido, nao deixa alterar nada

			Elseif cMV_SRV3PD == "T" // Titulo Provisorio

				For _ni := 1 to Len(aAlter[1,Len(aAlter[1])])

					If !(aAlter[1,Len(aAlter[1]),_ni] $ "VO4_IMPSUB/VO4_SRVFIN/VO4_CODSEC/VO4_TEMPAD/VO4_VALHOR/VO4_OBSERV/VO4_CODCAM")
						aAlter[1,Len(aAlter[1]),_ni] := " "
					EndIf

				Next

			EndIf
		EndIf

	EndIf

	VO4->(dbSkip())

Enddo

// Posiciona novamente, pois o VO4 ficava posicionado na proxima OS, e na execucao do relacao aparecia informacoes da proxima OS
VO4->(MsSeek(xFilial("VO4")+VO2->VO2_NOSNUM))
//

VO2->(DbGoTo(nPosicaoVO2))

aVetVO4Ini := FMX_CALSER(M->VO2_NUMOSV,,,,.t.) // Vetor utilizado para compara็ใo no momento da Grava็ใo
for _nimil := 1 to Len (aColsSrv)
	If (_ni := aScan( aVetVO4Ini , { |x| x[SRVC_TIPTEM] == aColsSrv[_nimil , FG_POSVAR("VO4_TIPTEM","aHeaderSrv")] .and. x[SRVC_CODSER] == aColsSrv[_nimil,FG_POSVAR("VO4_CODSER","aHeaderSrv")] .and. x[SRVC_TIPSER] == aColsSrv[_nimil,FG_POSVAR("VO4_TIPSER","aHeaderSrv")] })) <> 0
		aColsSrv[_nimil,FG_POSVAR("VO4_VALTOT","aHeaderSrv")] := aVetVO4Ini[_ni,SRVC_VALLIQ]
	EndIf
next

DbSelectArea("VO2")

If Len(aColsSrv) == 0

	aColsSrv:={Array(nUsadoSrv+1)}
	aColsSrv[1,nUsadoSrv+1]:=.F.

	For _ni:=1 to nUsadoSrv
		If IsHeadRec(aHeaderSrv[_ni,2])
			aColsSrv[Len(aColsSrv),_ni] := 0
		ElseIf IsHeadAlias(aHeaderSrv[_ni,2])
			aColsSrv[Len(aColsSrv),_ni] := "VO4"
		Else
			aColsSrv[1,_ni]:=CriaVar(aHeaderSrv[_ni,2])
		EndIf
	Next

EndIf

If Len(aColsIniFim) == 0 .and. !lAutoApont

	aColsIniFim:={Array(nUsadoIniFim+1)}
	aColsIniFim[1,nUsadoIniFim+1]:=.F.

	For _ni:=1 to nUsadoIniFim
		aColsIniFim[1,_ni]:=CriaVar(aHeaderIniFim[_ni,2])
	Next

EndIf

Asort(aColsIniFim,1,,{ |x,y| ;
	x[FG_POSVAR("VO4_CODSER","aHeaderIniFim")]+ x[FG_POSVAR("VO4_SEQUEN","aHeaderIniFim")] > ;
	y[FG_POSVAR("VO4_CODSER","aHeaderIniFim")]+ Y[FG_POSVAR("VO4_SEQUEN","aHeaderIniFim")] })

Aadd(aAlter[1],{})
For _ni:=1 to nUsadoSrv
	If !(aHeaderSrv[_ni,2] $ "VO4_VALDES/VO4_PERDES/VO4_VALSER") .or. ( lVAI_VALSER .and. AllTrim(aHeaderSrv[_ni,2]) == "VO4_VALSER" )
		Aadd(aAlter[1,Len(aAlter[1])], aHeaderSrv[_ni,2] )
	EndIf
Next

Aadd(aAlter[2],{})
For _ni:=1 to nUsadoIniFim
	If !(aHeaderIniFim[_ni,2] $ "VO4_GRUSER/VO4_CODSER/VO4_TEMPAD")
		Aadd(aAlter[2,Len(aAlter[2])], aHeaderIniFim[_ni,2] )
	EndIf
Next

If ExistBlock("OM3020TP")
	 ExecBlock("OM3020TP",.f.,.f.)
EndIf

SETKEY(VK_F4,{|| OM030KEYF4() })

If Len(aColsSrv)>0

	If !lOM030Auto
		If ExistBlock("OM030INI")
			lRet := ExecBlock("OM030INI",.f.,.f.,{})
			If !lRet
				Return
			Endif
		Endif

		// Menu botใo "Outras A็๕es"
		AADD(aNewBot, { "PESQUISA", { || FG_OSONLINE() }, STR0090} ) // Ordem De Servi็o On Line
		If cPaisLoc <> "BRA"
			If FGX_USERVL( xFilial("VAI"),__cUserID, "VAI_STALTV", "==" ,"1") // Permite alterar o Valor do Servi็o de Terceiro
				AADD(aNewBot, { "PESQUISA", { || OM0300111_Altera_Valores_Servico_Terceiro() }, STR0212} ) // Altera Valores Servi็o de Terceiro
			EndIf
		EndIf

		If (ExistBlock("OM030ABT")) // Ponto de Entrada para adicionar op็๕es no botใo "Outras A็๕es"
			aNewBot := ExecBlock("OM030ABT", .f., .f., {aNewBot})
		EndIf

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Executa a Modelo 3                                           ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		cTitulo       :=STR0004
		cAliasEnchoice:="VO2"
		cAliasGetD    :="VO4"
		cLinOk        :="FS_030VALID('L')"
		cTudOk        :="FS_030TUDOK()"
		cFieldOk      :="FS_030VALID('F')"
		nLinhas       := 999
		nAba          := 1

		cIndice  := " "
		aIndice  := {STR0008,STR0009,STR0010}    //"Codigo Servico + Sequencia + Data Inicial + Hora"###"Codigo do Mecanico + Data Inicial + Hora"###"Data Inicial + Hora"
		aCols    := {}
		aHeader  := {}

		// Configura os tamanhos dos objetos
		aObjects := {}
		AAdd( aObjects, { 315, 100, .T., .F. } ) // EnchoiceBar
		AAdd( aObjects, { 315, 100, .T., .T. } ) // Folder
		aInfo := {aSizeAut[1] , aSizeAut[2] , aSizeAut[3] , aSizeAut[4] , 2 , 2 }
		aPosObj := MsObjSize (aInfo, aObjects, .t.)

		DEFINE MSDIALOG oDlgServico FROM aSizeAut[7],000 to aSizeAut[6], aSizeAut[5] TITLE cTitulo OF oMainWnd PIXEL

		EnChoice("VO2", nReg, nOpc, , , ,aCpoEnchoice,aPosObj[1])

		oFolder030 := TFolder():New(aPosObj[2,1], aPosObj[2,2], aTitles, aTitles, oDlgServico, , , , .t. , , aPosObj[2,4], aPosObj[2,3]-aPosObj[2,1] )
 		oFolder030:bSetOption := {|| FS_030CHANGE() .and. If(FS_030VALID( "L" ),FS_DISENABLE(),.f.) }

		// Monta Tela de Servico
		aRotina := {{ STR0001 ,"axPesqui", 0 , 1},;    // Pesquisar
					{ STR0002 ,"OM030"    , 0 , 3},;  // Incluir "Requisitar"
					{ STR0003 ,"OM030A"    , 0 , 3}}   // Alterar

		FS_VETOR(3)
		oGetSrv     := MsGetDados():New(001,001,080,313,nOpcG,cLinOk,cTudOk,"",If(nOpcG > 2 .and. nOpcg < 5,.t.,.f.),aAlter[1,n],,,nLinhas,cFieldOk,,,,oFolder030:aDialogs[1])
		oGetSrv:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

		// Monta Tela Apontamento Inicial e Final
		aRotina := {{ STR0001 ,"axPesqui", 0 , 1},;   // Pesquisar
					{ STR0002 ,"OM030"    , 0 , 6},;   // Requisitar
					{ STR0003 ,"OM030A"    , 0 , 6}}    // Alterar

		// Configura os tamanhos dos objetos da Aba de Apontamento
		aObjects := {}
		AAdd( aObjects, {100 , 100, .T., .T. } ) // GetDados de Apontamento
		If GetMv("MV_PONLINE") == "S"
			AAdd( aObjects, { 80, 100, .F., .T. } ) // List com Tecnicos
		Endif
		aInfo := {0 , 13 , aPosObj[2,4], aPosObj[2,3]-aPosObj[2,1], 2 , 2 }
		aPosObjApon := MsObjSize (aInfo, aObjects, .T., .T.)

		@ 001,001 BUTTON oObserv030 PROMPT OemToAnsi(STR0011)  OF oFolder030:aDialogs[2] SIZE 55,11 PIXEL  ACTION FS_DUPL030(cIndice,.t.,.t.) //"Duplica registro do acols"
		@ 001,058 MSCOMBOBOX oIndice VAR cIndice SIZE aPosObjApon[1,4]-57 ,50 ITEMS aIndice VALID FS_DUPL030(cIndice,.f.,.t.) OF oFolder030:aDialogs[2] PIXEL

		FS_VETOR(4)
		oGetIniFim := MsGetDados():New(013,000,aPosObjApon[1,3]-12,aPosObjApon[1,4],nOpcG,cLinOk,cTudOk,"",If(nOpcG > 2 .and.  	nOpcg < 5,.t.,.f.),aAlter[2,n],,,nLinhas,cFieldOk,,,,oFolder030:aDialogs[2])

		FS_VETOR(3)
		If GetMv("MV_PONLINE") == "S"

			DEFINE TIMER oTimeProdutivo INTERVAL 30000 ACTION FS_PRODONLINE() OF oDlgServico

			oTimeProdutivo:lActive := .f.
			@ 001,aPosObjApon[2,2] BUTTON oConPro PROMPT OemToAnsi(STR0022)  OF oFolder030:aDialogs[2] ;
				SIZE aPosObjApon[2,4] - aPosObjApon[2,2],11 PIXEL  ;
				ACTION (BrwLegenda(STR0105,STR0097,{{"FOLDER9" ,STR0106},;		//Requisicao de Servico # Legenda # Sem escala
													{"BR_PRETO",STR0107},;		//Fora do Turno
													{"BR_AZUL" ,STR0108},;		//Ausente
													{"BR_VERDE",STR0109},;		//Disponivel
													{"BR_VERMELHO",STR0110}	} ) )	//Em Andamento

			@ 013,aPosObjApon[2,2] LISTBOX oLbProdutivo FIELDS HEADER  OemToAnsi(""),;
				OemToAnsi(STR0077); //Produtivo
				COLSIZES 10,50 ;
				SIZE aPosObjApon[2,4]-aPosObjApon[2,2],aPosObjApon[2,3]-aPosObjApon[2,1]-10 ;
				OF oFolder030:aDialogs[2] ON DBLCLICK (FG_TEMPTRA(aProdutivoOnLine[oLbProdutivo:nAt,2],dDataBase,0,dDataBase, Val(Substr(time(),1,2)+Substr(time(),4,2)) ,,,,, aCols , aHeader ), oLbProdutivo:Refresh() ) PIXEL

			FS_PRODONLINE(,.f.)

			oLbProdutivo:SetArray(aProdutivoOnLine)
			oLbProdutivo:bLine := { || { If(Empty(aProdutivoOnLine[oLbProdutivo:nAt,1]),oBBranco, If(aProdutivoOnLine[oLbProdutivo:nAt,1]=="D",oBVerde,If(aProdutivoOnLine[oLbProdutivo:nAt,1]$"E/O",oBVermelho,If(aProdutivoOnLine[oLbProdutivo:nAt,1]=="A",oBAzul,oBPreto))) ) ,;
			aProdutivoOnLine[oLbProdutivo:nAt,2] }}

		EndIf

		// Propriedades do Objeto Servico
		oGetSrv:oBrowse:bDelete    := {|| FS_VALDEL(1), oGetSrv:oBrowse:Refresh() }
		oGetSrv:oBrowse:bChange    := {|| FS_ALTREG(1) }
		oGetSrv:oBrowse:bEditCol   := {|| FS_WHENTIPSER() , FG_PULACPO(oGetSrv) }
		oGetSrv:oBrowse:Default()

		// Propriedades do Objeto Apontamento
		oGetIniFim:oBrowse:bDelete    := {|| FS_VALDEL(2,M->VO4_CODSER,M->VO4_SEQUEN), oGetIniFim:oBrowse:Refresh()	}
		oGetIniFim:oBrowse:bChange    := {|| FS_ALTREG(2)  }
		oGetIniFim:oBrowse:bEditCol   := {|| FG_PULACPO(oGetIniFim) , FS_PRODONLINE(M->VO4_CODPRO) }
		oGetIniFim:oBrowse:Default()

		ACTIVATE MSDIALOG oDlgServico ON INIT (EnchoiceBar(oDlgServico,{|| Processa( {|| OM030OKNO(.t.) }), ;
																			If(lFechaObj,oDlgServico:End(),.f.) },;
																		{|| OM030OKNO(.f.),If(lFechaObj,oDlgServico:End(),.f.) },;
																		,;
																		aNewBot),;
																		(Iif(FindFunction("OFA1100016_PesquisaCampanha") .And. VOU->(FieldPos("VOU_SERINT")) > 0, OFA1100016_PesquisaCampanha(VV1->VV1_CHASSI), NIL)))
	Else

		cLinOk        :="FS_030VALID('L')"
		cTudOk        :="FS_030TUDOK() .and. OM030OKNO(.t.)"

		FS_VETOR( IIf( lAutoApont , 4 , 3 ) )

		// Ajusta
		If lAutoApont

			if len(aAutoItens) == 0
				aApontTar := {}
				If aScan(aAutoCab, { |x| x[1] == "APONTTAR" }) <> 0
					aAuxApontTar := getDatAutoCab("APONTTAR")
					for nLin := 1 to Len(aAuxApontTar)
						AADD(aApontTar, aAuxApontTar[nLin,1])
						For nCol := 1 to Len(aAuxApontTar[nLin,2])
							AADD(aApontSrvc, aAuxApontTar[nLin,2][nCol])
						Next nCol
					next nLin
				EndIf

				// Apontamento por tarefa 
				//if len(aApontTar) > 0 .or. Len(aApontSrvc) > 0

					cApontProdutivo := ""
					If aScan(aAutoCab, { |x| x[1] == "VO4_CODPRO" }) <> 0
						cApontProdutivo := getDatAutoCab("VO4_CODPRO")

						dDtIniAutoApont := CtoD(" ")
						dDtFinAutoApont := CtoD(" ")
						dDataAutoApont  := CtoD(" ")

						lApontIniFim := .f.
						If aScan(aAutoCab, { |x| x[1] == "VO4_DATINI" }) <> 0 .OR. aScan(aAutoCab, { |x| x[1] == "VO4_DATFIN" })
							If aScan(aAutoCab, { |x| x[1] == "VO4_DATINI" }) <> 0 
								dDtIniAutoApont := getDatAutoCab("VO4_DATINI")
								nHrIniAutoApont := getDatAutoCab("VO4_HORINI")
							EndIf
							
							if aScan(aAutoCab, { |x| x[1] == "VO4_DATFIN" }) <> 0
								dDtFinAutoApont := getDatAutoCab("VO4_DATFIN")
								nHrFinAutoApont := getDatAutoCab("VO4_HORFIN")
								lApontIniFim := .t.
							endif

						else
							dDataAutoApont := Date()
							If aScan(aAutoCab, { |x| x[1] == "APONTDATA" }) <> 0
								dDataAutoApont := getDatAutoCab("APONTDATA")
							endif

							nHoraAutoApont := Val(Substr(time(),1,2)+Substr(time(),4,2))
							If aScan(aAutoCab, { |x| x[1] == "APONTHORA" }) <> 0
								nHoraAutoApont := getDatAutoCab("APONTHORA")
							endif

							dDtIniAutoApont := dDtFinAutoApont := dDataAutoApont
							nHrIniAutoApont := nHrFinAutoApont := nHoraAutoApont
						endif

						lIniTrab := OM0300155_ApontTarefaInicioTrabalho(;
							VO1->VO1_NUMOSV,;
							cApontProdutivo,;
							aApontTar,;
							aApontSrvc,;
							/* cTipTem */,;
							/* cTipSer */ )

						// Verifica se ้ inicio de trabalho ou final de trabalho 
						if lIniTrab

							if empty(dDtIniAutoApont)
								FMX_HELP("OM030ERR07", STR0217) // "Nใo foi informado data / hora de inicio de trabalho."
								return .f.
							endif

							OM0300175_FiltraServicosTarefa(;
								@aAutoItens,;     // aAuxAutoItens
								dDtIniAutoApont,; // dDtIni
								nHrIniAutoApont,; // nHrIni
								VO1->VO1_NUMOSV,; // cNumOsv
								cApontProdutivo,; // cProdutivo
								aApontTar,;       // aSeqInc
								aApontSrvc,;      // aCodSrvc
								,;                // cTipTem 
								,;                // cTipSer
								aSrvcProc)        // aSrvcProc

						endif

						if ! lIniTrab .or. lApontIniFim

							if empty(nHrFinAutoApont)
								FMX_HELP("OM030ERR08","Nใo foi informado data / hora final de trabalho.")
								return .f.
							endif

							cVO4MAUSA := ""
							If aScan(aAutoCab, { |x| x[1] == "VO4_MPAUSA" }) <> 0
								cVO4MAUSA := getDatAutoCab("VO4_MPAUSA")
							endif

							if ! OM0300195_FechaServicosTarefa(;
									@aAutoItens,;     // aAuxAutoItens
									dDtFinAutoApont,; // dDtFin
									nHrFinAutoApont,; // nHrFin
									VO1->VO1_NUMOSV,; // cNumOsv
									cApontProdutivo,; // cProdutivo
									aApontTar,;       // aSeqInc 
									aApontSrvc,;      // aCodSrvc
									,;                // cTipTem 
									,;                // cTipSer
									aSrvcProc,;        // aSrvcProc
									cVO4MAUSA)
								return .f.
							endif
						endif

					EndIf

				//endif

			endif

			//aCpoObrigat := {"VO4_SEQUEN","VO4_TEMPAD"}

			aCpoObrigat := {"VO4_TEMPAD"}
			VO2->(dbSetOrder(1))
			VO2->(dbSeek( xFilial ("VO2") + VO1->VO1_NUMOSV + "S"))

			VO4->(dbSetOrder(1)) // VO4_FILIAL+VO4_NOSNUM+VO4_TIPTEM+VO4_CODSER
			For nLin := 1 to Len(aAutoItens)
				cTipTem := aAutoItens[ nLin , aScan(aAutoItens[nLin] , { |x| x[1] == "VO4_TIPTEM" }) , 2]
				cCodSer := aAutoItens[ nLin , aScan(aAutoItens[nLin] , { |x| x[1] == "VO4_CODSER" }) , 2]
				For nCpo := 1 to Len(aCpoObrigat)
					OM030AJAUTOITENS( nLin , aCpoObrigat[ nCpo ] , cTipTem , cCodSer )
				Next nCpo
			Next nLin

			OM030AJSEQUEN(aAutoItens)

			//M->VO4_SEQUEN := aColsIniFim[1,FG_POSVAR("VO4_SEQUEN","aHeaderIniFim")]

	//			If Len(aCols) == 1
	//				If Empty( aCols[ 1, FG_POSVAR("VO4_DATINI","aHeader") ] )
	//					aCols := {}
	//				EndIf
	//			EndIf

		EndIf

		SX3->(dbSetOrder(2))
		For nLin := 1 to Len(aAutoItens)
			For nCol := 1 to Len(aAutoItens[nLin])
				nPos := aScan( aHeader , { |x| AllTrim(x[2]) == aAutoItens[nLin,nCol,1] } )
				If nPos > 0
					If SX3->(dbSeek(aAutoItens[nLin,nCol,1]))
						aAutoItens[nLin,nCol,3] := ""
						If !Empty(SX3->X3_VALID) .and. !aAutoItens[nLin,nCol,1] $ "VO4_FATPAR"
							aAutoItens[nLin,nCol,3] := "(" + AllTrim(SX3->X3_VALID) + ")"
						EndIf
						If !Empty(SX3->X3_VLDUSER)
							aAutoItens[nLin,nCol,3] += IIf( !Empty(aAutoItens[nLin,nCol,3]) , " .AND. " , "" ) + "(" + AllTrim(SX3->X3_VLDUSER) + ")"
						EndIf
						If lAutoApont .and. !aAutoItens[nLin,nCol,1] $ "VO4_GRUSER/VO4_CODSER"
							aAutoItens[nLin,nCol,3] += IIf( !Empty(aAutoItens[nLin,nCol,3]) , " .AND. " , "" ) + " (FS_030VALID('F'))"
						EndIf
						// Se for apontamento, vamos adicionar uma validacao para permitir limpar a data inicial
						// Usado no apontamento por tarefa
						If lAutoApont .and. aAutoItens[nLin,nCol,1] $ "VO4_DATINI" .and. ! empty(aAutoItens[nLin,nCol,3])
							aAutoItens[nLin,nCol,3] := "(" + aAutoItens[nLin,nCol,3] + ") .OR. ( Vazio() )"
						EndIf
					EndIf
				EndIf
			Next nCol
		Next nLin

		lAutoErrNoFile := .f.

		aAutoCab := {}
		//aCols := {}
		//aHeader = aClone(aVO3Header)
	//	lRet := MsGetDAuto(aAutoItens,cVO3LinOk,	{|| OX001TUDOK(nOpc).And.OX001FAT(nOpc) },aAutoCab,nOpc)
		Conout(" ")
		varInfo("aAutoItens", aAutoItens)
		Conout(" ")

		lRet := MsGetDAuto(aAutoItens , cLinOk, cTudOk , aAutoCab,nOpc,.f.)
		If !lRet
			lMsErroAuto := .t.
			If nPosVO2Soft <> 0
				VO2->(dbGoTo(nPosVO2Soft))
				VO2->(MSUnlock())
			EndIf
			return .f.
		EndIf

	EndIf
Endif

If nPosVO2Soft <> 0
	VO2->(dbGoTo(nPosVO2Soft))
	VO2->(MSUnlock())
EndIf

If !lOM030Auto
	dbSelectArea("VO1")
	VO1->(dbSetOrder(1))
	// Volta Filtro
	IF !empty(cOSFiltro)
		FilBrowse("VO1",{},"VO1->VO1_FILIAL=='"+xFilial("VO1")+"' .and. VO1->VO1_NUMOSV=='"+cOSFiltro+"'",.t.) 	// Filtra a OS
	else
		dbSelectArea("VAI")
		VAI->(dbSetOrder(4))
		VAI->(MsSeek(xFilial("VAI")+__cUserID))
		if VAI->VAI_TIPTEC == "4"
			cCondicao := "VO1->VO1_FUNABE == VAI->VAI_CODTEC"
			FilBrowse('VO1',{},cCondicao) // Filtra Usuario
		Endif
	Endif
Endif

SET KEY VK_F4 TO

Return


static function getDatAutoCab(cCpoGet)
	local nPos := aScan(aAutoCab, { |x| x[1] == cCpoGet })
	local cConteudo := ""
	if nPos <> 0
		cConteudo := aAutoCab[nPos,2]
		aDel(aAutoCab,nPos)
		aSize(aAutoCab,Len(aAutoCab) - 1)
	endif
return cConteudo

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณOM030OKNO   บAutor  ณFabio               บ Data ณ  08/02/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณBotao Ok e No                                               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณOficina                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OM030OKNO(lOperacao)
Local nQtdMec   := 1
Local aProdTrab := {}
Local ni  := 0
Local nj  := 0
Local lOk := .t.
Local aColsSLV   := aClone(aCols)
Local aHeaderSLV := aClone(aHeader)
Local nSLV       := n

Local cProdProc   := ""

Private aVetPerc := {}

lFechaObj := .f.

//Reposicionamento em funcao de filtros na VO1.
If Empty( VO1->VO1_NUMOSV )
	VO2->( xFilial("VO2") + M->VO2_NUMOSV + "S" )
EndIf

If lOperacao
	// verifica se houve mudan็a nos registros do VO4 enquanto esta rotina estava aberta. Se houver nใo permite a grava็ใo
	If !FS_VerApon()
		lFechaObj := .f.
		Return .f.
	EndIf

	If !lOM030Auto
		If oFolder030:nOption <> 1 // Diferente de Requisicao de Servicos
			aCols   := aClone(aColsSrv)
			aHeader := aClone(aHeaderSrv)
			n       := 1
		EndIf
	EndIf

	For ni := 1 to len(aCols)
		If !lOM030Auto // Quando nao for EXECAUTO, verifica se o usuario preencheu corretamente o Grupo / Codigo do Servico
			DbSelectArea("VO6")

			OFM0300011_PosicionaVO6( aCols[ni,FG_POSVAR("VO4_CODSER")] )

			If VO6->VO6_GRUSER <> aCols[ni,FG_POSVAR("VO4_GRUSER")]
				MsgStop(STR0175 + CHR(13) + CHR(10) + CHR(13) + CHR(10) +;
						STR0176 + " " + aCols[ni, FG_POSVAR("VO4_GRUSER")] + CHR(13) + CHR(10) +;
						STR0177 + " " + VO6->VO6_GRUSER, STR0158)

				lFechaObj := .f.

				Return .f.
			EndIf
		EndIf

		// Verifica se o campo esta no aHeader pois a funcao pode ser chamada das duas Guias (Requisicao e Apontamento)
		// Quando a guia for de apontamento o campo de Cliente nao esta no aHeader
		If FG_POSVAR("VO4_FATPAR") > 0
			If oCliente:Bloqueado(aCols[ni,FG_POSVAR("VO4_FATPAR")], aCols[ni,FG_POSVAR("VO4_LOJA")], .T.)
				lOk := .f.
				nOpca:=0
				lFechaObj := .f.

				Exit
			EndIf

			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณRafael Goncalves - 23/12/09            ณ
			//ณFNC 00000027650/2009-00                ณ
			//ณvalidar quanto tipo servico for socorroณ
			//ณse informado valor da kilometragem.    ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			VOK->(DbSetOrder(1))

			VOK->(DbSeek( xFilial("VOK") + aCols[ni,FG_POSVAR("VO4_TIPSER")] ))
			If VOK->VOK_INCMOB == "5" .and. !aCols[ni,FG_POSVAR("VO4_KILROD")] > 0
				FMX_HELP("OFM030ERR01", STR0112 + aCols[ni,FG_POSVAR("VO4_TIPSER")]) //"Necessario informar a Kilometragem para tipo de servi็o Socorro. Tipo de servi็o: "
				lOk := .f.
				nOpca:=0
				lFechaObj := .f.
			EndIf
		endif
	Next

	aCols   := aClone(aColsSLV)
	aHeader := aClone(aHeaderSLV)
	n       := nSLV
	lAchou  := .f.
	lEntrou := .f.

	If lOk
		//If !lOM030Auto .and. oFolder030:nOption==2 // Apontamento de Servicos
		// Apontamento de Servicos
		If (lOM030Auto .and. lAutoApont) .or. (lOM030Auto == .f. .and. oFolder030:nOption == 2)
			cProdProc := ""

			// Valida a Qtde de Mecanicos por Servico //
			For ni := 1 to len(aCols)
				nQtdMec   := 1
				aProdTrab := {}

				Aadd( aProdTrab , aCols[ni,FG_POSVAR("VO4_CODPRO")] )

				If !aCols[ni,Len(aCols[ni])]
					For nj := 1 to len(aCols)
						If !aCols[nj,Len(aCols[nj])]
							If !Empty(aCols[ni,FG_POSVAR("VO4_CODPRO")])
								dbSelectArea("VAI")
								dbSetOrder(1)

								VAI->(DbSeek( xFilial("VAI")+aCols[ni,FG_POSVAR("VO4_CODPRO")]))
								If !OM030ProFil(aCols[ni,FG_POSVAR("VO4_CODPRO")], aCols[ni,FG_POSVAR("VO4_DATINI")], !(aCols[ni,FG_POSVAR("VO4_CODPRO")] $ cProdProc), @cProdProc )
									Return .f.
								EndIf

							EndIf

							If ni <> nj .and. aCols[ni,FG_POSVAR("VO4_CODSER")] == aCols[nj,FG_POSVAR("VO4_CODSER")]
								If Empty(aCols[nj,FG_POSVAR("VO4_DATFIN")]) .or. ( ;
									aCols[ni,FG_POSVAR("VO4_DATINI")] >= aCols[nj,FG_POSVAR("VO4_DATINI")] .and. ;
									aCols[ni,FG_POSVAR("VO4_HORINI")] >= aCols[nj,FG_POSVAR("VO4_HORINI")] .and. ;
									aCols[ni,FG_POSVAR("VO4_DATINI")] <= aCols[nj,FG_POSVAR("VO4_DATFIN")] .and. ;
									aCols[ni,FG_POSVAR("VO4_HORINI")] <= aCols[nj,FG_POSVAR("VO4_HORFIN")] )

									If Len( aProdTrab ) == 0 .Or. Ascan( aProdTrab , aCols[nj,FG_POSVAR("VO4_CODPRO")] ) == 0
										Aadd( aProdTrab , aCols[nj,FG_POSVAR("VO4_CODPRO")] )
										nQtdMec++
									EndIf
								EndIf
							EndIf
						EndIf
					Next
				EndIf

				DbSelectArea("VO6")

				OFM0300011_PosicionaVO6( aCols[ni,FG_POSVAR("VO4_CODSER")] )

				If nQtdMec > VO6->VO6_QTDMEC
					Help("  ", 1, "QTDMEC",, Alltrim(RetTitle("VO6_CODSER")) + ": ";
						+ Alltrim(VO6->VO6_CODSER) + " ( " + Alltrim(str(nQtdMec, 8) + " " + STR0077) + " )", 4, 1)

					lOk       := .f.
					nOpca     := 0
					lFechaObj := .f.

					Exit
				EndIf
			Next

			aVetPerc := {}

			For ni := 1 to len(aCols)
				If !aCols[ni,Len(aCols[ni])]
					If FG_POSVAR("VO4_PERRAT") > 0
						If !Empty(aCols[ni,FG_POSVAR("VO4_PERRAT")])
							nPos := AScan( aVetPerc, { |x| x[1] + x[3] + x[4] == aCols[ni,FG_POSVAR("VO4_CODPRO")] ;
								+ aCols[ni,FG_POSVAR("VO4_GRUSER")] + aCols[ni,FG_POSVAR("VO4_CODSER")] } )

							If nPos == 0
								aAdd(aVetPerc, {aCols[ni,FG_POSVAR("VO4_CODPRO")], aCols[ni,FG_POSVAR("VO4_PERRAT")],;
									aCols[ni,FG_POSVAR("VO4_GRUSER")], aCols[ni,FG_POSVAR("VO4_CODSER")]})
							Else
								If aCols[ni,FG_POSVAR("VO4_PERRAT")] != aVetPerc[nPos,2]
									Help("  ",1,"M030RATDIV",,,3,0)
									lOk := .f.

									Exit
								EndIf
							EndIf
						EndIf
					EndIf
				EndIf
			Next

			aVetServ100 := {}
			nTotPercMec := 0

			For ni := 1 to len(aVetPerc)
				nPos := AScan( aVetServ100, { |x| x[1] + x[2] == aVetPerc[ni,3] + aVetPerc[ni,4] } )
				If nPos == 0
					aAdd(aVetServ100, {aVetPerc[ni,3], aVetPerc[ni,4], aVetPerc[ni,2]})
				Else
					aVetServ100[nPos,3] += aVetPerc[ni,2]
				EndIf
			Next

			For ni := 1 to Len(aVetServ100)
				If aVetServ100[ni,3] > 100
					Help("  ", 1, "M030DIV100",, Alltrim(aVetServ100[ni,1]) + "/" + Alltrim(aVetServ100[ni,2]), 3, 0)
					lOk := .f.

					Exit
				EndIf
			Next
		EndIf

		If lOk
			nOpca := 1
			//If lOM030Auto .or. oFolder030:nOption==1
			If (lOM030Auto .and. !lAutoApont) .or. (lOM030Auto == .f. .and. oFolder030:nOption == 1)
				If lOM030Auto .or. (oGetSrv:TudoOk() .and. FS_030LINOK())
					If obrigatorio(aGets,aTela) .And. FS_VALFASE()
						nOpc  := 2

						FS_VETOR(1)

						If FS_GRSRVs(.t.)
							lFechaObj := .t.
						Else
							lOk := .f.
						EndIf

						&& Retorna o acols e aheader de servico porque a requisicao de peca automatica altera o mesmos.
						FS_VETOR(3)
					EndIf
				EndIf
			Else
				If lOM030Auto .or. (oGetIniFim:TudoOk() .And. FS_VALFASE())
					FS_VETOR(2)

					If FS_030LIN2()
						If FS_GRSRVs(.t.,.T.) // 2o parametro para gravar as requisicoes automaticas
							lFechaObj := .t.
						Endif
					EndIf

					&& Retorna o acols e aheader de Apontamento porque a requisicao de peca automatica altera o mesmos.
					FS_VETOR(4)
				EndIf
			EndIf
		EndIf
	EndIf
Else
	nOpca := 0

	FS_VETOR(oFolder030:nOption)

	lFechaObj := .t.
EndIf

If ExistBlock("OM030OKN")
	ExecBlock("OM030OKN",.f.,.f.,{lOperacao})
EndIf
Return lOk

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_MTAHEADER  บAutor  ณMicrosiga       บ Data ณ  07/07/00   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCria aHeader e aCols da GetDados                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FS_MTAHEADER()

Local cInc    := ""
Local cCpoSvT := ""
Local lVO4IPDCOM := VO4->(FieldPos("VO4_IPDCOM")) > 0
nUsadoSrv:=nUsadoIniFim:=0

// Inconveniente
If GetNewPar("MV_INCORC","N") == "S"
	cInc := "/VO4_GRUINC/VO4_CODINC/VO4_DESINC/VO4_SEQINC"
EndIf

If lVO4IPDCOM
	cCpoSvT := "/VO4_IPDCOM/VO4_NNFCOM/VO4_SNFCOM"
EndIf

dbSelectArea("SX3")
SX3->(DbSetOrder(1))
SX3->(dbSeek("VO4"))

aHeader:={}
While !Eof().And.(x3_arquivo=="VO4")

	// Servico
	If X3USO(x3_usado).And.cNivel>=x3_nivel.And.( SX3->X3_PROPRI=="U" .or. Alltrim(x3_campo) $ "VO4_TIPTEM/VO4_FATPAR/VO4_LOJA/VO4_NOMCLI/VO4_GRUSER/VO4_CODSER/VO4_DESSER/VO4_TIPSER/VO4_KILROD/VO4_TEMPAD/VO4_VALHOR/VO4_CODSEC/VO4_DESSEC/VO4_CODFOR/VO4_FOLOJA/VO4_NOMFOR/VO4_PEDCOM/VO4_NUMTIT/VO4_TIPTIT/VO4_NATURE/VO4_CODPAG/VO4_VALCUS/VO4_VALVEN/VO4_DATPAG/VO4_DEPINT/VO4_DEPGAR/VO4_IMPSUB/VO4_CODCOR/VO4_PRISMA/VO4_VALTOT/VO4_OBSERV/VO4_OBSMEM/VO4_CODCAM/VO4_PERDES/VO4_VALDES/VO4_SRVFIN/VO4_PREKIL"+cInc+"/VO4_VALSER/"+cCpoSvT)
		nUsadoSrv:=nUsadoSrv+1
		Aadd(aHeaderSrv,{ iif( lAltInconv, OX001066K_AlteraDescricaoInconveniente(x3_campo), retTitle(x3_campo) ), x3_campo, x3_picture,;
			x3_tamanho, x3_decimal,x3_valid,;
			x3_usado, x3_tipo, x3_arquivo, x3_context, x3_Relacao, x3_reserv } )
	EndIf

	// Inicio/Fim do Servico - Apontamento
	If X3USO(x3_usado).And.cNivel>=x3_nivel.And.(Alltrim(x3_campo) $ "VO4_GRUSER/VO4_CODSER/VO4_DESSER/VO4_CODPRO/VO4_NOMPRO/VO4_DATINI/VO4_HORINI/VO4_DATFIN/VO4_HORFIN/VO4_HOREXT/VO4_SEQUEN/VO4_CODFAS/VO4_DESFAS/VO4_TEMFAS/VO4_TEMPAD/VO4_PERRAT/VO4_MPAUSA/VO4_DESMPA")
		nUsadoIniFim:=nUsadoIniFim+1
		Aadd(aHeaderIniFim,{ iif( lAltInconv, OX001066K_AlteraDescricaoInconveniente(x3_campo), retTitle(x3_campo) ), x3_campo, x3_picture,;
			x3_tamanho, x3_decimal,x3_valid,;
			x3_usado, x3_tipo, x3_arquivo, x3_context, x3_Relacao, x3_reserv } )
	Endif

	&("M->"+Alltrim(x3_campo)) := CriaVar(x3_campo)

	SX3->(dbSkip())
End


Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_GRSRVs บAutor  ณFabio               บ Data ณ  07/07/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGrava Servicos Requisitados                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FS_GRSRVs(lTelaRolagem,lRegAut)

Local lRet  := .t. , lMostraErro := .t. , nTotTpPadrao:=0 , nTpConces:=0 , nDias:=0 , nValPer:=0
Local nHorIni:=0 , nHorFin:=0 , nHorAbe:=0 , nHorSeg:=0 , lAddSrv:=.T.

Local niIni := 0 , nPosSrv := 0 , nPos := 0 , cSrvQuebra := "" , nSrvOpcao := 0 , nContPrisma := 0
Local aColsReqPec  := {} , aColsDReqPec := {} , aSalvaaColsSrv := aClone( aColsSrv ) , aSalvaaHeaderSrv := aClone( aHeaderSrv )
Local nPosFor := FG_POSVAR("VO4_CODFOR","AHEADERSRV")
Local nPosLoj := FG_POSVAR("VO4_FOLOJA","AHEADERSRV")
Local nPosTit := FG_POSVAR("VO4_NUMTIT","AHEADERSRV")
Local nPosPed := FG_POSVAR("VO4_PEDCOM","AHEADERSRV")
Local nPosTip := FG_POSVAR("VO4_TIPTIT","AHEADERSRV")
Local nPosNat := FG_POSVAR("VO4_NATURE","AHEADERSRV")
Local nPosPag := FG_POSVAR("VO4_CODPAG","AHEADERSRV")
Local nPosCus := FG_POSVAR("VO4_VALCUS","AHEADERSRV")
Local nPosDat := FG_POSVAR("VO4_DATPAG","AHEADERSRV")
Local nPreKil := FG_POSVAR("VO4_PREKIL","AHEADERSRV")
Local nPosPedTit := 0
Local ni := 0
Local niIniApt := 0
Local nCriVar := 0
Local nReqPec := 0
Local ix2 := 0

Local nVlrPec := 0
Local aAuxTipTem := {}
Local lExistVO2 := .f. // Verifica se existe o VO2 para chamar a funcao FMX_CANUSETT
Local lVO4PEDCOM := VO4->(FieldPos('VO4_PEDCOM')) > 0
Local lVO4IPDCOM := VO4->(FieldPos("VO4_IPDCOM")) > 0
Local cMV_SRV3PD := GetNewPar("MV_SRV3PD","N")
Local cCpoPedTit := ""
Local cSQLVOU    := "SQLVOU"
Local cQuery     := ""
Local lVO4PREKIL := VO4->(FieldPos("VO4_PREKIL")) <> 0

Local oOficina   := DMS_Oficina():New()
Local oControlTower	:= Nil // Variavel para controlar a Torre de Controle
Local cEvtServico	:= ""

Default lRegAut := .F.

Private aHeaderReqPec := {} , aHeaderDReqPec := {} , aPecaOrc:= {} , aPrisma := {}
Private lMsHelpAuto := .t. , lMsFinalAuto := .f.

//**********
// Gravar no VO2_TIPREQ "S" Servico
//**********
Default lTelaRolagem := .f.
lTelaRolagem := !lOM030Auto
If lTelaRolagem .and. !lOM030Auto
	ProcRegua(Len(aColsSrv))
EndIf

// Adapta aCols Srv para controle Interno
If Type("aControle") == "U"
	aControle := {}
EndIf

Aadd(aHeaderSrv,{ "Controle", "VO4_SEQUEN" , "", 8, 0,"", "", "C", "VO4", "" , "", "" } )

For ni:=1 to Len(aColsSrv)

	Aadd( aColsSrv[ni] , aColsSrv[ni,Len(aColsSrv[ni])] )

	If ni <= Len( aControle )
		aColsSrv[ni,Len(aColsSrv[ni])-1] := aControle[ni,2]
	Else
		aColsSrv[ni,Len(aColsSrv[ni])-1] := Space(16)
	EndIf

Next

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMonta Ambiente p/ Requisicao e Devolucao de Pecas Automaticoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If Type("aAgrupSer") # "U" .And. Len(aAgrupSer) # 0

	aCols   := {}
	aHeader := {}

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Cria aHeader e aCols p/ Requisicao de Pecas                  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	cReqDev   := "1"

	RegToMemory("VO3",.T.)

	// Monta aHeaders Pecas
	FS_MTPECAAHEAD()
	aHeaderReqPec := aClone(aHeader)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณAdapta aCols p/ Requisicao Automatica de Peca.                       ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Asort(aAgrupSer,,,{|x,y| x[2]+x[1] < y[2]+y[1] } )

	nReqPec := Iif(n<>nil,n,1)
	cSrvQuebra := ""

	For nPos := 1 To Len(aAgrupSer)

		nRecPec := FG_POSVAR("VO4_CODSER","aheaderIniFim")
		nRecPec2 := FG_POSVAR("VO4_CODSER","aHeaderSrv")
		nLinPec := Ascan(aColsIniFim,{|x| x[nRecPec]==aAgrupSer[nPos,1]})
		nPosSrv := Ascan(aColsSrv,{|x| x[nRecPec2] == aColsIniFim[nLinPec,nRecPec]})
		cReqDev := "1"


		If aAgrupSer[nPos,2] == "2"

			If !aAgrupSer[nPos,7] .And. aAgrupSer[nPos,10]

				nPosPec := Ascan(aColsReqPec,{|x| x[FG_POSVAR("VO3_GRUITE","aHeaderReqPec")]+x[FG_POSVAR("VO3_CODITE","aHeaderReqPec")] == Subs(aAgrupSer[nPos,3],1,4) + Subs(aAgrupSer[nPos,3],7) })

				If nPosPec == 0

					AADD(aColsReqPec,Array(Len(aHeaderReqPec)+1))

					For nCriVar:=1 to Len(aHeaderReqPec)

						aColsReqPec[Len(aColsReqPec),nCriVar] := CriaVar( aHeaderReqPec[nCriVar,2] )

					Next

					nPosPec := Len(aColsReqPec)

				EndIf

				nVlrPec := aAgrupSer[nPos,8]
				DbSelectArea("VSJ")
				DbSetOrder(1)
				If DbSeek( xFilial("VSJ") + VO1->VO1_NUMOSV )
					DbSelectArea("VS3")
					DbSetOrder(2)
					If DbSeek( xFilial("VS3") + VSJ->VSJ_NUMORC + Subs(aAgrupSer[nPos,3],1,4) + subs(aAgrupSer[nPos,3],7) )
						nVlrPec := ( VS3->VS3_VALTOT / VS3->VS3_QTDITE )
					EndIf
				EndIf

				aColsReqPec[nPosPec,FG_POSVAR("VO3_TIPTEM","aHeaderReqPec")] := aAgrupSer[nPos,14] // tipo de tempo
				aColsReqPec[nPosPec,FG_POSVAR("VO3_FATPAR","aHeaderReqPec")] := aColsSrv[nPosSrv,FG_POSVAR("VO4_FATPAR","aHeaderSrv")]
				aColsReqPec[nPosPec,FG_POSVAR("VO3_LOJA"  ,"aHeaderReqPec")] := aColsSrv[nPosSrv,FG_POSVAR("VO4_LOJA"  ,"aHeaderSrv")]
				aColsReqPec[nPosPec,FG_POSVAR("VO3_NOMCLI","aHeaderReqPec")] := aColsSrv[nPosSrv,FG_POSVAR("VO4_NOMCLI","aHeaderSrv")]
				aColsReqPec[nPosPec,FG_POSVAR("VO3_GRUITE","aHeaderReqPec")] := Subs(aAgrupSer[nPos,3],1,4)
				aColsReqPec[nPosPec,FG_POSVAR("VO3_CODITE","aHeaderReqPec")] := Subs(aAgrupSer[nPos,3],7)
				aColsReqPec[nPosPec,FG_POSVAR("VO3_DESITE","aHeaderReqPec")] := aAgrupSer[nPos,4]
				aColsReqPec[nPosPec,FG_POSVAR("VO3_QTDREQ","aHeaderReqPec")] := aAgrupSer[nPos,5] + aColsReqPec[nPosPec,FG_POSVAR("VO3_QTDREQ","aHeaderReqPec")]
				aColsReqPec[nPosPec,FG_POSVAR("VO3_PROREQ","aHeaderReqPec")] := aAgrupSer[nPos,9]
				aColsReqPec[nPosPec,FG_POSVAR("VO3_DEPINT","aHeaderReqPec")] := aColsSrv[nPosSrv,FG_POSVAR("VO4_DEPINT","aHeaderSrv")]
				aColsReqPec[nPosPec,FG_POSVAR("VO3_DEPGAR","aHeaderReqPec")] := aColsSrv[nPosSrv,FG_POSVAR("VO4_DEPGAR","aHeaderSrv")]
				aColsReqPec[nPosPec,FG_POSVAR("VO3_FORMUL","aHeaderReqPec")] := aAgrupSer[nPos,6]
				//          aColsReqPec[nPosPec,FG_POSVAR("VO3_VALPEC","aHeaderReqPec")] := aAgrupSer[nPos,8]
				aColsReqPec[nPosPec,FG_POSVAR("VO3_VALPEC","aHeaderReqPec")] := nVlrPec

				Aadd( aPecaOrc , { .t. , aColsReqPec[nPosPec,FG_POSVAR("VO3_TIPTEM","aHeaderReqPec")] , aColsReqPec[nPosPec,FG_POSVAR("VO3_FATPAR","aHeaderReqPec")] , aColsReqPec[nPosPec,FG_POSVAR("VO3_LOJA","aHeaderReqPec")] ,;
				"" , aColsReqPec[nPosPec,FG_POSVAR("VO3_GRUITE","aHeaderReqPec")] , aColsReqPec[nPosPec,FG_POSVAR("VO3_CODITE","aHeaderReqPec")] , "" , aColsReqPec[nPosPec,FG_POSVAR("VO3_QTDREQ","aHeaderReqPec")] ,;
				aColsReqPec[nPosPec,FG_POSVAR("VO3_FORMUL","aHeaderReqPec")] , aColsReqPec[nPosPec,FG_POSVAR("VO3_VALPEC","aHeaderReqPec")] , aAgrupSer[nPos,12] , aAgrupSer[nPos,13] } )


			EndIf

		Endif
	Next

EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Cria aHeader e aCols Devolucao                               ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If Type("aPecasReq") # "U" .and. Len(aPecasReq) # 0

	cReqDev   := "0"
	aHeader   := {}

	DbSelectArea("VO3")
	For nReqPec := 1 to FCount()

		DbSelectArea("SX3")
		DbSetOrder(2)
		DbSeek( VO3->(FieldName(nReqPec)) )

		Aadd(aHeaderDReqPec,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
			x3_tamanho, x3_decimal,x3_valid,;
			x3_usado, x3_tipo, x3_arquivo, x3_context, x3_Relacao, x3_reserv } )

		DbSelectArea("VO3")

	Next

EndIf

// Verifica se pode continuar a requisicao ...
// Tenta minimizar a duplicacao de VO2 para o mesmo TT
aAuxTipTem := {}
For ni:=1 to Len(aColsSrv)
	If !aColsSRV[ ni , Len(aColsSRV[ni]) ] .and. aScan( aAuxTipTem, aColsSrv[ni,FG_POSVAR("VO4_TIPTEM","aHeaderSrv")] ) == 0
		AADD( aAuxTipTem , aColsSrv[ni,FG_POSVAR("VO4_TIPTEM","aHeaderSrv")] )
	EndIf
Next nI
VO2->(dbSetOrder(1))
lExistVO2 := VO2->(DbSeek( xFilial("VO2") + VO1->VO1_NUMOSV + "S" ))
For nI := 1 to Len(aAuxTipTem)
	If !FMX_CANUSETT( "3" , VO1->VO1_NUMOSV , aAuxTipTem[nI] , !lExistVO2 )
		Return .f.
	EndIf
Next nI
//

If ExistBlock("OM030ANGR")
	lRetPE := ExecBlock("OM030ANGR",.f.,.f.,)
	If !lRetPE
		Return .f.
	Endif
EndIf


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณInicio da gravacaoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Begin Transaction

// Monta numero sequencial
FS_SXENUM030(M->VO2_NUMOSV)

DbSelectArea("VO2")
DbSetOrder(1)
DbSeek( xFilial("VO2") + M->VO2_NUMOSV + "S" + M->VO2_NOSNUM )

If !RecLock("VO2", !Found() )
	Help("  ",1,"REGNLOCK")
	lRet := .f.
	DisarmTransaction()
	Break
EndIf

FG_GRAVAR("VO2")
VO2->VO2_TIPREQ := "S"

If VO2->(FieldPos("VO2_DATALT")) > 0 .and. lAlterou
	VO2->VO2_DATALT := DDATABASE
EndIf

MsUnlock()

// Exclusใo de todas as Campanhas T้cnicas com Relacionamento em VOU e nใo Executadas
// Obs: FieldPos("VOU_SERINT") pois o campo ้ novo, antes o c๓digo nใo realizava essa exclusใo!
If VOU->(FieldPos("VOU_SERINT")) > 0
	cQuery := "SELECT VOU.R_E_C_N_O_ RECVOU "
	cQuery += "FROM " + RetSQLName("VOU") + " VOU "
	cQuery += "JOIN " + RetSQLName("VOP") + " VOP ON VOP_FILIAL = '" + xFilial("VOP") + "' AND VOP_NUMINT = VOU_NUMINT "
	cQuery += "  AND VOP_TIPPEN = '1' AND VOP.D_E_L_E_T_ = ' ' "
	cQuery += "WHERE VOU_FILIAL = '" + xFilial("VOU") + "' "
	cQuery += "  AND VOU_CHASSI = '" + VO1->VO1_CHASSI + "' AND VOU_NUMOSV = '" + VO1->VO1_NUMOSV + "' "
	cQuery += "  AND VOU_DATEXE = ' ' AND VOU.D_E_L_E_T_ = ' ' "
	dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cSQLVOU, .T., .T.)

	While !(cSQLVOU)->(Eof())
		VOU->(dbGoTo((cSQLVOU)->(RECVOU)))

		RecLock("VOU", .F., .T.)
		dbdelete()
		MsUnlock()

		dbSelectArea(cSQLVOU)

		(cSQLVOU)->(dbSkip())
	EndDo

	(cSQLVOU)->(dbCloseArea())

	DbSelectArea("VO2")
EndIf

cCpoPedTit := "VO4_NUMTIT"
nPosPedTit := nPosTit // Posicao do Nro do Titulo na aCols de Servicos
If cMV_SRV3PD == "P" // Pedido
	If lVO4PEDCOM // Nro do Pedido
		cCpoPedTit := "VO4_PEDCOM"
		nPosPedTit := nPosPed // Posicao do Pedido na aCols de Servicos
	EndIf
EndIf

Asort(aColsIniFim,1,,{ |x,y| x[FG_POSVAR("VO4_CODSER","aHeaderIniFim")]+ x[FG_POSVAR("VO4_SEQUEN","aHeaderIniFim")]< y[FG_POSVAR("VO4_CODSER","aHeaderIniFim")]+ Y[FG_POSVAR("VO4_SEQUEN","aHeaderIniFim")]})
Asort(aColsSrv,1,,{ |x,y| x[FG_POSVAR("VO4_CODSER","aHeaderSrv")] < y[FG_POSVAR("VO4_CODSER","aHeaderSrv")] })

For ni:=1 to Len(aColsSrv)

	If lOM030Auto .and. Empty(aColsSrv[ni,FG_POSVAR("VO4_TIPTEM","aHeaderSrv")]) //Hแ uma linha em branco quando ้ executado por execauto
		Loop
	EndIf

	If lTelaRolagem
		IncProc(aColsSrv[ni,FG_POSVAR("VO4_CODSER","aHeaderSrv")] + " - " + aColsSrv[ni,FG_POSVAR("VO4_DESSER","aHeaderSrv")] )
	EndIf

	// Inicializaca niIni para ser utilizada na hora que for percorrer entre todos apontamentos do servico
	niIni := Ascan(aColsIniFim,{ |x| x[FG_POSVAR("VO4_CODSER","aHeaderIniFim")] == aColsSrv[ni,FG_POSVAR("VO4_CODSER","aHeaderSrv")] } )

	If oOficina:TipoTempoBloqueado(aColsSrv[ni,FG_POSVAR("VO4_TIPTEM","aHeaderSrv")],.t.) // Valida se Tipo de Tempo esta BLOQUEADO
		lRet := .f.
		DisarmTransaction()
		Break
	EndIf

	// Se o tipo de tempo for garantia grava Flag.
	If VOI->VOI_SITTPO$"2/4" .Or. (VOI->VOI_SITTPO=="3".And.aColsSrv[ni,FG_POSVAR("VO4_DEPINT","aHeaderSrv")]=="R")                   //aCols[ni,1] $ [G/R/I]

		DbSelectArea("VO1")

		If !RecLock("VO1",.F.)
			Help("  ",1,"REGNLOCK")
			lRet := .f.
			DisarmTransaction()
			Break
		EndIf

		VO1->VO1_TEMGAR := "S"
		MsUnlock()

	EndIf

	DbSelectArea("VOK")
	DbSetOrder(1)
	DbSeek( xFilial("VOK") + aColsSRV[ni,FG_POSVAR("VO4_TIPSER","aHeaderSRV")] )

	// Tipo Cobranca do Tipo de Servico = 2-Servico de Terceiros/5-Socorro/6-Franquia
	If VOK->VOK_INCMOB $ "2/5/6"

		niIni := 0

		DbSelectArea("VO4")
		DbSetOrder(8)

		If Empty( aColsSrv[ni,FG_POSVAR("VO4_SEQUEN","aHeaderSRV")] )

			lSrvFound := .f.

		Else

			lSrvFound := DbSeek( xFilial("VO4") + M->VO2_NOSNUM + aColsSrv[ni,FG_POSVAR("VO4_SEQUEN","aHeaderSRV")] )

		EndIf

		If !aColsSRV[ ni , Len(aColsSRV[ni]) ]

			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ Gera SEQUEN, quando for servico com Apontamento, o SEQUEN ja estaณ
			//ณ gerado na matriz aColsIniFim                                     ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			if !lSrvFound
				aColsSrv[ni,FG_POSVAR("VO4_SEQUEN","aHeaderSRV")] := FS_030SEQUEN(,,.T.)
			endif

			If !RecLock("VO4", !lSrvFound )
				Help("  ",1,"REGNLOCK")
				lRet := .f.
				DisarmTransaction()
				Break
			EndIf

			nSrvOpcao := 4
			// Tipo de Cobranca - 2=Srv de Terceiro
			If VOK->VOK_INCMOB == "2"

				If Empty(&("VO4->"+cCpoPedTit))

					nSrvOpcao := 3

					/*So sera gerado titulo se informado o numero do mesmo*/

					If Empty( aColsSrv[ni,FG_POSVAR(cCpoPedTit,'aHeaderSrv')] ) .And. ( !Empty( aColsSrv[ni,FG_POSVAR('VO4_CODFOR','aHeaderSrv')] ) )

						If cMV_SRV3PD == "P" // Pedido
							aColsSrv[ni,FG_POSVAR(cCpoPedTit,'aHeaderSrv')] := CriaVar("C7_NUM",.T.)

							If lVO4IPDCOM
								aColsSrv[ni,FG_POSVAR("VO4_IPDCOM",'aHeaderSrv')] := strzero(1,TamSX3("C7_ITEM")[1])
							EndIf

						ElseIf cMV_SRV3PD == "T" // Titulo Provisorio
							aColsSrv[ni,FG_POSVAR(cCpoPedTit,'aHeaderSrv')] := GetSXENum("SE2","E2_NUM")
						EndIf
						ConfirmSx8()

					EndIf

				ElseIf VO4->VO4_CODFOR <> aColsSrv[ni,nPosFor] .or.;
					VO4->VO4_FOLOJA <> aColsSrv[ni,nPosLoj] .or.;
					&("VO4->"+cCpoPedTit) <> aColsSrv[ni,nPosPedTit] .or.;
					VO4->VO4_TIPTIT <> aColsSrv[ni,nPosTip] .or.;
					VO4->VO4_NATURE <> aColsSrv[ni,nPosNat] .or.;
					VO4->VO4_CODPAG <> aColsSrv[ni,nPosPag] .or.;
					VO4->VO4_DATPAG <> aColsSrv[ni,nPosDat] .or.;
					VO4->VO4_VALCUS <> aColsSrv[ni,nPosCus]

					// houve alteracao, entao excluir o antigo e gravar o novo
					nSrvOpcao := 5

				EndIf

			// Tipo de Cobranca - 5=KM - Socorro
			ElseIf VOK->VOK_INCMOB == "5"

				VO4->VO4_VALHOR := 0
				If lVO4PREKIL .and. lVOIVLSVAC .and. VOI->VOI_VLSVAC == "1"// Valor de Requisi็ใo
					VO4->VO4_PREKIL := aColsSrv[ni,nPreKil]
				EndIf

			EndIf

			// Movimenta Servico
			FS_MOVSRV(.t.,aColsSrv,aHeaderSrv,ni,.t.,ni)

			// Gera Contas a Pagar - Servico de Terceiros
			If  VOK->VOK_INCMOB == "2" .And. !Empty(&("VO4->"+cCpoPedTit)) .And. nSrvOpcao # 4

				If nSrvOpcao == 5

					If !FS_MOVSRVTERC( .t. , nSrvOpcao ) // Servico de Terceiros Inclusao 5
						lRet := .f.
						DisarmTransaction()
						Break
					EndIf

					nSrvOpcao := 3

				EndIf

				// Servico de Terceiros Inclusao 3
				If !FS_MOVSRVTERC( .t. , nSrvOpcao )
					lRet := .f.
					DisarmTransaction()
					Break
				EndIf

			EndIf

			MsUnlock()

			nTotTpPadrao += VO4->VO4_TEMPAD

			// Movimenta Ocorrencia
			FS_MOVVFB(.t.)

		ElseIf lSrvFound

			// Deleta Movimento
			FS_MOVVFB(.f.)

            If VOK->VOK_INCMOB == "2"

				cCpoPedTit := "VO4_NUMTIT"
				If cMV_SRV3PD == "P" // Pedido
					If lVO4PEDCOM // Nro do Pedido
						cCpoPedTit := "VO4_PEDCOM"
					EndIf
				EndIf

				// Servico de Terceiros Cancelamento 5
				If !Empty(&("VO4->"+cCpoPedTit))
					If !FS_MOVSRVTERC(.t.,5)
						lRet := .f.
						DisarmTransaction()
						Break
					EndIf
				EndIf

			EndIf

			// Deleta Servico
			FS_MOVSRV(.f.)

		EndIf

	EndIf

	// Foi selecionado um servico com Tipo Cobranca do Tipo de Servico = 2-Servico de Terceiros/5-Socorro
	If niIni == 0
		Loop
	EndIf

	Do While niIni <= Len(aColsIniFim) .And. aColsIniFim[niIni,FG_POSVAR("VO4_CODSER","aHeaderIniFim")] == aColsSrv[ni,FG_POSVAR("VO4_CODSER","aHeaderSrv")]

		dbselectArea("VO4")
		DbSetOrder(8)
		DbSeek( xFilial("VO4") + M->VO2_NOSNUM + aColsIniFim[niIni,FG_POSVAR("VO4_SEQUEN","aHeaderIniFim")] )

		If !aColsIniFim[ niIni , Len(aColsIniFim[niIni]) ] //O apontamento nใo estแ deletado

			If !RecLock("VO4", !Found() )
				Help("  ",1,"REGNLOCK")
				lRet := .f.
				DisarmTransaction()
				Break
			EndIf

			lMovContaCor := Empty(VO4->VO4_DATFIN)

			// Movimento o Servico
			FS_MOVSRV(.t.,aColsSrv,aHeaderSrv,ni,,ni)

			// Movimento o Servico
			FS_MOVSRV(.t.,aColsIniFim,aHeaderIniFim,niIni,,ni)

			// Marca Retorno de Servico
			FS_MOVRETSRV()

			MsUnlock()

			nTotTpPadrao += VO4->VO4_TEMPAD

			// Movimenta a Conta Corrente do Produtivo  Adiciona
			If lMovContaCor .And. !Empty(VO4->VO4_CODPRO) .And. !Empty(VO4->VO4_DATFIN)

				//FS_MOVCONTCOR(.t.)

			EndIf

			// Grava Ocorrencia do Veiculo
			FS_MOVVFB(.t.)

			niIni++

		Else //O apontamento estแ deletado

			//            If DbSeek( xFilial("VO4") + aColsIniFim[niIni,FG_POSVAR("VO4_CODSER","aHeaderIniFim")] + M->VO2_NOSNUM + aColsIniFim[niIni,FG_POSVAR("VO4_SEQUEN","aHeaderIniFim")] )
			dbselectArea("VO4")
			DbSetOrder(4)
			If VO4->( Found() )

				// Deleta Ocorrencia do Veiculo
				FS_MOVVFB(.f.)

				// Deleta Disponibilidade
				FG_ESTSVGAR()

				// Movimenta a Conta Corrente do Produtivo  Subtrai
				If !Empty(VO4->VO4_CODPRO) .And. !Empty(VO4->VO4_DATFIN)

					//FS_MOVCONTCOR(.f.)

				EndIf

				// Deleta Servico
				FS_MOVSRV(.f.)

				If VO2->(FieldPos("VO2_DATALT")) > 0 .and. !Empty(VO4->VO4_CODPRO)

					DbSelectArea("VO2")
					RecLock("VO2",.f.)
						VO2->VO2_DATALT := DDATABASE
					MsUnLock()

				EndIf

				DbSelectArea("VO4")

				// Cria Linha para marcar tempo
				If !aColsSrv[ ni , Len(aColsSrv[ni]) ]

					// Verifica se adciona novo registro no VO4
					DbSelectArea("VO4")
					DbSeek(xFilial("VO4"))
					DbSetOrder(4)
					DbSeek(xFilial("VO4") + aColsSrv[ni,FG_POSVAR("VO4_CODSER","aHeaderSrv")] + M->VO2_NOSNUM )
					Do While !Eof() .And. VO4->VO4_FILIAL+VO4->VO4_CODSER+VO4->VO4_NOSNUM == xFilial("VO4") + aColsSrv[ni,FG_POSVAR("VO4_CODSER","aHeaderSrv")] + M->VO2_NOSNUM

						If VO4->VO4_TIPSER == aColsSrv[ni,FG_POSVAR("VO4_TIPSER","aHeaderSrv")]

							lAddSrv := .F.
							Exit

						EndIf

						DbSkip()

					EndDo

					//Otแvio - 16/01/2014
					//ษ preciso verificar se existe mais de um apontamento para este servi็o na mem๓ria que ainda nใo foi gravado na tabela.
					//Se tiver, nใo precisa criar o servi็o.
					If lAddSrv

						niIniApt := 1
						Do While niIniApt <= Len(aColsIniFim) .And. aColsIniFim[niIni,FG_POSVAR("VO4_CODSER","aHeaderIniFim")] == aColsSrv[ni,FG_POSVAR("VO4_CODSER","aHeaderSrv")]
							If !aColsIniFim[ niIniApt , Len(aColsIniFim[niIniApt]) ]
								lAddSrv := .F.
								Exit
							EndIf
							niIniApt++
						EndDo
					EndIf

					If lAddSrv

						// Movimento o Servico
						If !RecLock("VO4",.t.)
							Help("  ",1,"REGNLOCK")
							lRet := .f.
							DisarmTransaction()
							Break
						EndIf

						FS_MOVSRV(.t.,aColsSrv,aHeaderSrv,ni,,ni)

						MsUnLock()

						// Grava Ocorrencia do Veiculo
						FS_MOVVFB(.t.)

					EndIf

				EndIf

			EndIf

			niIni++

		EndIf

	EndDo

	///////////////////////////////////
	// Gravar Motivo de Cancelamento //
	///////////////////////////////////
	If !Empty(VO4->VO4_MPAUSA)
		For ix2 := 1 to len(aDelMotiv)
			If aDelMotiv[ix2,1] == ni // Posicao na aCols
				OFA210VDT("000006",aDelMotiv[ix2,2,1],"2",VO1->VO1_FILIAL,VO1->VO1_NUMOSV,aDelMotiv[ix2,2,4])
			EndIf
		Next
	EndIf

Next

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณAjusta Status do Box para analise.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
FG_MARCABOX(VO1->VO1_NUMBOX,VO1->VO1_CODCOR,VO1->VO1_PRISMA,VO1->VO1_NUMOSV)

For nContPrisma := 1 to Len( aPrisma )

	FG_MARCABOX( , aPrisma[nContPrisma,1] , aPrisma[nContPrisma,2] , VO1->VO1_NUMOSV )

Next

// Requisicao
If Len(aColsReqPec) # 0

	cReqDev := "1"
	aCols   := aClone(aColsReqPec)
	aHeader := aClone(aHeaderReqPec)
	M->VO2_NOSNUM := GetSXENum("VO2","VO2_NOSNUM",,2)

	If !FS_GRAREQ(,,.F.)
		lRet := .f.
		lMostraErro := .f.
		DisarmTransaction()
		Break
	EndIf

EndIf

// Devolucao
If Type("aPecasReq") # "U"

	For nReqPec := 1 to Len(aPecasReq)

		If aPecasReq[nReqPec,7]

			Aadd( aColsDReqPec , aPecasReq[nReqPec,5] )

		EndIf

	Next

EndIf

If Len(aColsDReqPec) # 0

	cReqDev := "0"
	aCols   := aClone(aColsDReqPec)
	aHeader := aClone(aHeaderDReqPec)
	M->VO2_NOSNUM := GetSXENum("VO2","VO2_NOSNUM",,2)

	//      FS_ORDBUSCA()

	If !FS_GRAREQ( aColsDReqPec , aHeaderDReqPec ,.F.)
		lRet := .f.
		lMostraErro := .f.
		DisarmTransaction()
		Break
	EndIf

	// Requisita pecas se for transferencia de pecas entre os produtivos.
	If Len( aPecasReq ) # 0

		aCols := {}

		For nReqPec := 1 to Len( aColsDReqPec )

			nPosSrv := 0

			nPosSrv := Ascan( aPecasReq , { |x| x[1] == aColsDReqPec[nReqPec,FG_POSVAR("VO3_CONSRV","aHeaderDReqPec")] } )

			If nPosSrv # 0 .And. !Empty( aPecasReq[nPosSrv,3] ) .And. aColsDReqPec[nReqPec,FG_POSVAR("VO3_PROREQ","aHeaderDReqPec")] # aPecasReq[nPosSrv,3]

				Aadd( aCols , aColsDReqPec[nReqPec] )
				aCols[ Len(aCols) , FG_POSVAR("VO3_PROREQ","aHeaderDReqPec") ] := aPecasReq[nPosSrv,3]
				aCols[ Len(aCols) , FG_POSVAR("VO3_CONSRV","aHeaderDReqPec") ] := aPecasReq[nPosSrv,4]

			EndIf

		Next

		If Len( aCols ) # 0

			cReqDev := "1"
			aHeader := aClone(aHeaderDReqPec)
			M->VO2_NOSNUM := GetSXENum("VO2","VO2_NOSNUM",,2)

			If !FS_GRAREQ(,,.F.)
				lRet := .f.
				lMostraErro := .f.
				DisarmTransaction()
				Break
			EndIf

		EndIf

	EndIf

EndIf

// Levanta data e hora da Entrega
nValPer		 := 0
nHorIni		 := 0
nHorFin 		 := 0
nHorAbe		 := 0
nHorAbe 		 := Val( Substr( StrZero( VO1->VO1_HORABE , 4 ) , 1 , 2 ) + StrZero( ( Val( Substr( StrZero( VO1->VO1_HORABE , 4 ) , 3 , 2 ) ) / 0.6 ) , 2 ) )
nTotTpPadrao := Val( Substr( StrZero( nTotTpPadrao , 4 ) , 1 , 2 ) + StrZero( ( Val( Substr( StrZero( nTotTpPadrao , 4 ) , 3 , 2 ) ) / 0.6 ) , 2 ) )
nHorSeg		 := Val( Substr( StrZero( GetMv("MV_HORSEG") , 4 ) , 1 , 2 ) + StrZero( ( Val( Substr( StrZero( GetMv("MV_HORSEG") , 4 ) , 3 , 2 ) ) / 0.6 ) , 2 ) )
Do While .t.

	For ni:=1 to Len(Alltrim(GetMv("MV_HORCON")))+1 Step 10

		nHorIni := Val( Substr( StrZero( Val(Substr(Alltrim(GetMv("MV_HORCON")),ni,4)) , 4 ) , 1 , 2 ) + StrZero( ( Val( Substr( StrZero( Val(Substr(Alltrim(GetMv("MV_HORCON")),ni,4)) , 4 ) , 3 , 2 ) ) / 0.6 ) , 2 ) )
		nHorFin := Val( Substr( StrZero( Val(Substr(Alltrim(GetMv("MV_HORCON")),ni+5,4)) , 4 ) , 1 , 2 ) + StrZero( ( Val( Substr( StrZero( Val(Substr(Alltrim(GetMv("MV_HORCON")),ni+5,4)) , 4 ) , 3 , 2 ) ) / 0.6 ) , 2 ) )

		If nHorFin >= nHorAbe .And. Empty(nTpConces)
			nValPer:= ( nHorFin - nHorAbe )
			nHorIni:= nHorAbe
		ElseIf !Empty(nTpConces)
			nValPer:= ( nHorFin - nHorIni )
		EndIf

		If nValPer+nTpConces <= nTotTpPadrao
			nTpConces+=nValPer
		Else
			nTpConces:= ( nHorIni + ( nTotTpPadrao	- nTpConces ) ) + nHorSeg
			nValPer  := 0
			Exit
		EndIf

	Next

	If Empty(nValPer)
		If nTpConces >= 2400
			nDias 	 += Int( nTpConces/2400 )
			nTpConces := ( nTpConces - ( ( Int( nTpConces/2400 ) )*2400) )
		EndIf
		Exit
	EndIf

	nDias+=1

EndDo

nTpConces := Val( Substr( StrZero( nTpConces , 4 ) , 1 , 2 ) + StrZero( ( Val( Substr( StrZero( nTpConces , 4 ) , 3 , 2 ) ) * 0.6 ) , 2 ) )

If GetNewPar("MV_CALDTEN","S") == "S" // Calclula data de entrega? (SIM/NAO)

	DbSelectArea("VO1")
	RecLock("VO1",.f.)
	VO1->VO1_DATENT := VO1->VO1_DATABE + nDias
	VO1->VO1_HORENT := nTpConces
	MsUnLock()

EndIf

DbSelectArea("VO1")

//PE.
If ExistBlock("OM030DPGR")
	ExecBlock("OM030DPGR",.f.,.f.)
Endif

End Transaction

If lMostraErro

	If !lRet

		MostraErro()

		aColsSrv := aClone( aSalvaaColsSrv )
		aHeaderSrv := aClone( aSalvaaHeaderSrv )

	Else

		// ------------------------------------------------------------------
        // Control Tower: Eventos dinamicos de servico (EVT36-39)
        // Disparar apos gravacao de apontamentos (inclusao/alteracao/exclusao)
        // AvaliarEventoServico determina qual evento disparar com base no
        // status consolidado dos apontamentos da OS
        // ------------------------------------------------------------------
        If FindClass("OFSEventoControlTower") .and. GetNewPar("MV_MIL0006","") == "SCA"
            oControlTower := OFSEventoControlTower():New()
            cEvtServico := oControlTower:AvaliarEventoServico(VO1->VO1_NUMOSV)
            If !Empty(cEvtServico)
                oControlTower:ExecutarEvento(cEvtServico, VO1->VO1_CHASSI, VO1->VO1_NUMOSV, "", "")
			Else
				oControlTower:ExecutarEvento(EVT_ORC_APROVADO_AGUARD_SERVICO, VO1->VO1_CHASSI, VO1->VO1_NUMOSV, "", "")
            EndIf
			FreeObj(oControlTower)
        EndIf


		// Imprime Ordem de Busca P/ Requisicao de Pecas Automatico
		If Len(aColsReqPec) # 0

			FS_ORDBUSCA()

		EndIf

		// Imprime sub ordem
		If Len(aColsSrv) # 0
			if ExistBlock("IMPSUBORD") // Impressao da subordem de servico
				ExecBlock("IMPSUBORD",.f.,.f.)
			Else
				FS_SUBORDEM()
 			Endif
		EndIf

	EndIf

EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_MOVSRV บAutor  ณFabio               บ Data ณ  05/23/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMovimenta Servico                                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_MOVSRV(lOperacao,aColsG,aHeaderG,nLinha,lSrvTerceiro,ni)

Local nVlHrTab := 0
Local cSQLVOU  := "SQLVOU"
Local cQuery   := ""
Local cSQL     := ""
Local lGrvCam  := .f.
Local cRecNo   := ""
Local cNumInt  := ""

PRIVATE aMemos  := {{"VO4_OBSMEM","VO4_OBSERV"}}
Private aHeadGRef := aClone(aHeaderG)

Default lSrvTerceiro := .f.

// Requisicao
lAchou := .f.
If lOperacao

	FG_GRAVAR("VO4",aColsG,aHeaderG,nLinha)
	if  FG_POSVAR("VO4_PERRAT","aHeadGRef") > 0
		nPos := AScan( aVetPerc , { |x| x[1] + x[3] + x[4] == aColsG[nLinha,FG_POSVAR("VO4_CODPRO","aHeadGRef")] + aColsG[nLinha,FG_POSVAR("VO4_GRUSER","aHeadGRef")] + aColsG[nLinha,FG_POSVAR("VO4_CODSER","aHeadGRef")] } )
		if nPos > 0
			VO4->VO4_PERRAT := aVetPerc[nPos,2]
		endif
	endif
	//	VO4->VO4_SERINT := Posicione("VO6",2,xFilial("VO6") + FG_MARSRV(Posicione("VV1",1,xFilial("VV1")+VO1->VO1_CHAINT,"VV1_CODMAR"),VO4->VO4_CODSER) + VO4->VO4_CODSER ,"VO6_SERINT")

/*    nPos := Ascan( aVetor , {|x| x[1]+x[2] == aColsG[nLinha,1] + aColsG[nLinha,2] } )
	if nPos == 0
	    if !Empty(aColsG[nLinha,2])
			Aadd( aVetor , { aColsG[nLinha,1] , aColsG[nLinha,2] } )
		Endif
	Else
    	lAchou := .t.
	Endif
    if lAchou
		VO4->VO4_TEMPAD := 0
    Endif */
	VO4->VO4_TEMPAD := aColsSrv[ni,FG_POSVAR('VO4_TEMPAD','aHeaderSrv')]
	VO4->VO4_FILIAL := xFilial("VO4")
	VO4->VO4_NOSNUM := M->VO2_NOSNUM
	VO4->VO4_NUMOSV := M->VO2_NUMOSV
	VO4->VO4_CODTES := POSICIONE("VOI",1,xFilial("VOI")+VO4->VO4_TIPTEM,"VOI_CODTES")

	VO4->VO4_SERINT := Posicione("VO6",2,xFilial("VO6")+FG_MARSRV(Posicione("VV1",1,xFilial("VV1")+VO1->VO1_CHAINT,"VV1_CODMAR"),aColsSrv[ni,FG_POSVAR('VO4_CODSER','aHeaderSrv')])+aColsSrv[ni,FG_POSVAR('VO4_CODSER','aHeaderSrv')] ,"VO6_SERINT")

	MSMM(VO4->VO4_OBSMEM,TamSx3("VO4_OBSERV")[1],,&(aMemos[1][2]),1,,,"VO4","VO4_OBSMEM")

	nVlHrTab := FG_ValHor(VO4->VO4_TIPTEM,OM030TPVLSRV(VO4->VO4_TIPTEM,VO4->VO4_NOSNUM),,,VV1->VV1_CODMAR,VO4->VO4_CODSER,VO4->VO4_TIPSER,VO4->VO4_FATPAR,VO4->VO4_LOJA,VV1->VV1_MODVEI,VV1->VV1_SEGMOD, Iif(lMultMoeda, VO1->VO1_MOEDA, nil), Iif(lMultMoeda, VO1->VO1_TXMOED, nil))
	If Empty(VO4->VO4_VALHOR)
		VO4->VO4_VALHOR := nVlHrTab
	EndIf

	// Se foi alterado o valor da hora grava flag
	If VO4->VO4_VALHOR # nVlHrTab
		VO4->VO4_VHRDIG := "1"
	Else
		VO4->VO4_VHRDIG := "0"
	EndIf

	// Grava Tempo trabalhado se nao for Srv de terceiro
	If !lSrvTerceiro
		VO4->VO4_TEMTRA := FG_TEMPTRA(VO4->VO4_CODPRO,VO4->VO4_DATINI,VO4->VO4_HORINI,VO4->VO4_DATFIN, VO4->VO4_HORFIN ,"N",.f.)
	EndIf

	// Em caso de alteracao Subtrai o valor antigo
	//FG_CONTCOR(VO4->VO4_CODPRO,VO4->VO4_DATINI, , , , VO4->VO4_TEMVEN ,,,,, .F.,VO4->VO4_TEMPAD,VO4->VO4_NOSNUM,VO4->VO4_CODSER,VO4->VO4_TIPTEM)

	// Tempo Para Calculo - 3=Trabalhado
	If VOK->VOK_INCTEM == "3"

		VO4->VO4_TEMVEN := VO4->VO4_TEMTRA

		// Tempo Para Calculo - 1=Fabrica / 2=Concessionaria
	ElseIf VOK->VOK_INCTEM $ "1/2"

		VO4->VO4_TEMVEN := FG_TemPad(VO1->VO1_CHAINT , VO6->VO6_CODSER , VOK->VOK_INCTEM , VOK->VOK_INCMOB )

	EndIf

	// Adciona o novo valor
	//FG_CONTCOR(VO4->VO4_CODPRO,VO4->VO4_DATINI, , , , VO4->VO4_TEMVEN ,,,,, .T.,VO4->VO4_TEMPAD,VO4->VO4_NOSNUM,VO4->VO4_CODSER,VO4->VO4_TIPTEM )

	If Empty(VO4->VO4_SEQUEN)
		VO4->VO4_SEQUEN := FS_030SEQUEN()
	EndIf

	If VO4->(FieldPos("VO4_CODIGO")) > 0 .and. Empty(VO4->VO4_CODIGO)
		VO4->VO4_CODIGO := GetSXENum("VO4","VO4_CODIGO",,12)
		ConfirmSX8()
	EndIf

	if VO4->(fieldpos("VO4_UUID")) > 0 .and. empty(VO4->VO4_UUID)
		VO4->VO4_UUID := criavar("VO4_UUID")
		VO4->VO4_DATINC := criavar("VO4_DATINC")
		VO4->VO4_DATALT := criavar("VO4_DATALT")
	elseif VO4->(fieldpos("VO4_UUID")) > 0 .and. ! empty(VO4->VO4_UUID)
		VO4->VO4_DATALT := criavar("VO4_DATALT")
	endif

	If Len( aPrisma ) == 0 .Or. Ascan( aPrisma , {|x| x[1]+x[2] == VO4->VO4_CODCOR+VO4->VO4_PRISMA } ) == 0

		Aadd( aPrisma , { VO4->VO4_CODCOR , VO4->VO4_PRISMA } )

	EndIf

	// Caso array de Servi็o e nใo de Apontamento (verifica็ใo da coluna "VO4_CODCAM")
	// grava็ใo da Campanha T้cnica informada para Relacionamento em VOU
	// Obs: FieldPos("VOU_SERINT") pois o campo ้ novo, antes o c๓digo nใo realizava essa inclusใo/exclusใo!
	If FG_POSVAR("VO4_CODCAM", "aHeadGRef") > 0 .And. VOU->(FieldPos("VOU_SERINT")) > 0
		If !Empty(aColsG[nLinha, FG_POSVAR("VO4_CODCAM", "aHeadGRef")])
			cQuery := "SELECT VOU.R_E_C_N_O_ RECVOU, VOU.VOU_DATEXE, VOP.VOP_NUMINT "
			cQuery += "FROM " + RetSQLName("VOU") + " VOU "
			cQuery += "JOIN " + RetSQLName("VOP") + " VOP ON VOP_FILIAL = '" + xFilial("VOP") + "' AND VOP_NUMINT = VOU_NUMINT "
			cQuery += "  AND VOP_NUMCAM = '" + aColsG[nLinha, FG_POSVAR("VO4_CODCAM", "aHeadGRef")] + "' AND VOP.D_E_L_E_T_ = ' ' "
			cQuery += "WHERE VOU_FILIAL = '" + xFilial("VOU") + "' "
			cQuery += "  AND VOU_CHASSI = '" + VO1->VO1_CHASSI + "' AND VOU_NUMOSV = '" + VO1->VO1_NUMOSV + "' AND VOU.D_E_L_E_T_ = ' ' "
			dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cSQLVOU, .F., .T.)

			lGrvCam := .t.
			cRecNo  := ""

			If !(cSQLVOU)->(Eof())
				// Nใo pode atualizar caso jแ Liberado (executado)
				If !Empty((cSQLVOU)->(VOU_DATEXE))
					lGrvCam := .f.
				Else
					// RECVOU / VOU_NUMINT
					cRecNo  := (cSQLVOU)->(RECVOU)
					cNumInt := (cSQLVOU)->(VOP_NUMINT)
				EndIf
			Else
				// VOU_NUMINT
				cSQL := "SELECT VOP_NUMINT "
				cSQL += "FROM " + RetSQLName("VOP") + " VOP "
				cSQL += "WHERE VOP_FILIAL = '" + xFilial("VOP") + "' "
				cSQL += "  AND VOP_NUMCAM = '" + aColsG[nLinha, FG_POSVAR("VO4_CODCAM", "aHeadGRef")] + "' "
				cSQL += "  AND VOP.D_E_L_E_T_ = ' '"
				cNumInt := FM_SQL(cSQL)
			EndIf

			dbSelectArea(cSQLVOU)
			(cSQLVOU)->(dbCloseArea())

			DbSelectArea("VO4")

			If lGrvCam
				// VOU
				If !Empty(cRecNo)
					VOU->(dbGoTo(cRecNo))

					RecLock("VOU", .F.)
				Else
					RecLock("VOU", .T.)
				EndIf
				VOU->VOU_FILIAL := xFilial("VOU")
				VOU->VOU_NUMINT := cNumInt
				VOU->VOU_CHASSI := VO1->VO1_CHASSI
				VOU->VOU_NUMOSV := VO1->VO1_NUMOSV
				VOU->VOU_KILVEI := VO1->VO1_KILOME

				If VOU->(FieldPos("VOU_FILCAM")) <> 0
					VOU->VOU_FILCAM := xFilial("SF2")
				EndIf

				If VOU->(FieldPos("VOU_FILOSV")) <> 0
					VOU->VOU_FILOSV := xFilial("VO1")
				EndIf

				If VOU->(FieldPos("VOU_TIPTEM")) <> 0
					VOU->VOU_TIPTEM := VO4->VO4_TIPTEM
				EndIf

				If VOU->(FieldPos("VOU_GRUSER")) <> 0
					VOU->VOU_GRUSER := aColsG[nLinha, FG_POSVAR("VO4_GRUSER", "aHeadGRef")]
				EndIf

				If VOU->(FieldPos("VOU_CODSER")) <> 0
					VOU->VOU_CODSER := aColsG[nLinha, FG_POSVAR("VO4_CODSER", "aHeadGRef")]
				EndIf

				If VOU->(FieldPos("VOU_SERINT")) <> 0
					VOU->VOU_SERINT := VO4->VO4_SERINT
				EndIf
				MsUnlock()
			EndIf
		EndIf
	EndIf

Else

	If Len( aPrisma ) == 0 .Or. Ascan( aPrisma , {|x| x[1]+x[2] == VO4->VO4_CODCOR+VO4->VO4_PRISMA } ) == 0

		Aadd( aPrisma , { VO4->VO4_CODCOR , VO4->VO4_PRISMA } )

	EndIf

	//FG_CONTCOR(VO4->VO4_CODPRO,VO4->VO4_DATINI, , , , VO4->VO4_TEMVEN ,,,,, .F. ,VO4->VO4_TEMPAD,VO4->VO4_NOSNUM,VO4->VO4_CODSER,VO4->VO4_TIPTEM)

	// Deleta Servico
	If !RecLock("VO4",.F.,.T.)
		Help("  ",1,"REGNLOCK")
		lRet := .f.
		DisarmTransaction()
		Break
	EndIf

	dbdelete()
	MsUnlock()
	WriteSx2("VO4")

EndIf


Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_MOTVFB บAutor  ณFabio               บ Data ณ  05/23/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMovimenta arquivos de movimento do veiculo VFB              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_MOVVFB(lOperacao)

If lOperacao

	// Grava Ocorrencia do Veiculo
	DbSelectArea("VFB")
	DbSetOrder(4)
	DbSeek( xFilial("VFB") + VO1->VO1_PROVEI + VO1->VO1_LOJPRO + VO1->VO1_CHAINT + "S" + VO4->VO4_CODSER + Dtos(VO2->VO2_DATREQ) + VO1->VO1_NUMOSV )

	If !RecLock("VFB", !Found() )
		Help("  ",1,"REGNLOCK")
		lRet := .f.
		DisarmTransaction()
		Break
	EndIf

	VFB->VFB_FILIAL := xFilial("VFB")
	VFB->VFB_CODCLI := M->VO2_PROVEI
	VFB->VFB_LOJA   := M->VO2_LJPVEI
	VFB->VFB_CHAINT := VO1->VO1_CHAINT
	VFB->VFB_SERPEC := "S"
	VFB->VFB_NUMOSV := M->VO2_NUMOSV
	VFB->VFB_TIPTEM := VO4->VO4_TIPTEM
	VFB->VFB_DATAPL := M->VO2_DATREQ
	VFB->VFB_NUMREQ := M->VO2_NOSNUM
	VFB->VFB_KILOME := VO1->VO1_KILOME
	VFB->VFB_CODSER := VO4->VO4_CODSER
//	VFB->VFB_ORDCRO := aColsSrv[ni,]
//	VFB->VFB_TIPREV := aColsSrv[ni,]
	MsUnlock()

Else

	DbSelectArea("VFB")
	DbSetOrder(4)

	If DbSeek( xFilial("VFB") + VO1->VO1_PROVEI + VO1->VO1_LOJPRO + VO1->VO1_CHAINT + "S" + VO4->VO4_CODSER + Dtos(VO2->VO2_DATREQ) + VO1->VO1_NUMOSV )

		If !RecLock("VFB",.F.,.T.)
			Help("  ",1,"REGNLOCK")
			lRet := .f.
			DisarmTransaction()
			Break
		EndIf

		dbdelete()
		MsUnlock()
		WriteSx2("VFB")
	EndIf

EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_MOVSRVTบAutor  ณFabio               บ Data ณ  05/23/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMovimenta Servico de Terceiro                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_MOVSRVTERC(lOperacao,nOperacao)

Local aContaPagar := {} , aPgto := {} , cParc := "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
Local lExist := (Ascan(aSrv3rd,{|x| x[1]==VO4->(Recno())}) > 0) .and. (nOperacao == 5)
Local nPos := Ascan(aSrv3rd,{|x| x[1]==VO4->(Recno())})
Local nGerTit := 0

Local aCab := {}, aItem := {}
Local lVO4PEDCOM := VO4->(FieldPos('VO4_PEDCOM')) > 0
Local cNUM       := ""
Local cMV_SRV3PD := GetNewPar("MV_SRV3PD","N")

Local cItePed := strzero(1,TamSX3("C7_ITEM")[1])
Local lVO4IPDCOM := VO4->(FieldPos("VO4_IPDCOM")) > 0

Private lMsErroAuto := .f. , lMsHelpAuto := .t., lMsFinalAuto := .f.

If lOperacao

	// Gera pedido de compra
	If cMV_SRV3PD == "P" // P - Gera pedido

		If lVO4PEDCOM // Nro do Pedido
			cNUM := VO4->VO4_PEDCOM

			If lVO4IPDCOM
				cItePed := VO4->VO4_IPDCOM
			EndIf

		Else
			cNUM := VO4->VO4_NUMTIT
		EndIf

		DbSelectArea("SC7")
		DbSetOrder(1)

		If Empty(cNUM) .or. !DbSeek(xFilial("SC7")+cNUM) // Caso Pedido em Branco ou nao existir ainda na tabela SC7 --> Gerar Pedido

			If nOperacao == 3 .And. !Empty(VO4->VO4_CODFOR) .And. !Empty(VO4->VO4_FOLOJA) .And. !Empty(VO4->VO4_VALCUS)

				If cPaisLoc <> "BRA"
					If !SuperGetMV("MV_T120PC",.F.,.T.) // Verifica o parโmetro MV_T120PC: Controle transa็ใo do PC (T = Por pedido / F = Por item)
						FMX_HELP("OFM030ERR02", STR0181) // "Parโmetro MV_T120PC (Controle transa็ใo do PC) incorreto. Favor informar T = Por pedido."
						Return(.f.)
					EndIf
				EndIf

				SA2->(DbSetOrder(1))
				SA2->(dbSeek(xFilial("SA2")+VO4->VO4_CODFOR+VO4->VO4_FOLOJA))
				aCab:={	{"C7_NUM"		,cNUM  				,Nil},; // Numero do Pedido
						{"C7_EMISSAO"	,dDataBase			,Nil},; // Data de Emissao
						{"C7_FORNECE"	,VO4->VO4_CODFOR	,Nil},; // Fornecedor
						{"C7_LOJA"		,VO4->VO4_FOLOJA	,Nil},; // Loja do Fornecedor
						{"C7_COND"		,VO4->VO4_CODPAG	,Nil},; // Condicao de pagamento
						{"C7_NATUREZ"	,VO4->VO4_NATURE	,Nil},; // Natureza
						{"C7_CONTATO"	,"               "	,Nil},; // Contato
						{"C7_FILENT"	,FWCODFIL()			,Nil}} // Filial Entrega

				If lMultMoeda
					aAdd(aCab,{"C7_MOEDA"	,VO1->VO1_MOEDA	,Nil})
					aAdd(aCab,{"C7_TXMOEDA"	,VO1->VO1_TXMOED,Nil})
				EndIf

				SB1->(DbSetOrder(7))
				SB1->(DbSeek(xFilial("SB1")+VOK->VOK_GRUITE+VOK->VOK_CODITE))
				SB1->(DbSetOrder(1))
				aadd(aItem,{{"C7_ITEM"   , cItePed ,Nil},; //Numero do Item "001"
							{"C7_PRODUTO",SB1->B1_COD      ,Nil},; //Codigo do Produto
							{"C7_UM"     ,SB1->B1_UM       ,Nil},; //Unidade de Medida
							{"C7_QUANT"  ,1                ,Nil},; //Quantidade
							{"C7_PRECO"  ,VO4->VO4_VALCUS  ,Nil},; //Preco
							{"C7_DATPRF" ,dDataBase        ,Nil},; //Data De Entrega
							{"C7_FLUXO"  ,"S"              ,Nil},; //Fluxo de Caixa (S/N)
							{"C7_LOCAL"  ,FM_PRODSBZ(SB1->B1_COD,"SB1->B1_LOCPAD")   ,Nil}}) //Localizacao

				lMsErroAuto := .f.
				MSExecAuto({|v,x,y,z| MATA120(v,x,y,z)},1,aCab,aItem,3)

			EndIf

		EndIf

		// Gera um Titulo Provisorio
	ElseIf cMV_SRV3PD == "T"	// T - Gera Titulo

		If lExist
			aPgto := Condicao(aSrv3rd[nPos,8],aSrv3rd[nPos,7],,aSrv3rd[nPos,9])
		Else
			aPgto := Condicao(VO4->VO4_VALCUS,VO4->VO4_CODPAG,,VO4->VO4_DATPAG)
		Endif

		For nGerTit := 1 to Len(aPgto)

			aContaPagar := {}
			aAdd(aContaPagar, {"E2_PREFIXO"	,"SR3"      							 		,Nil} ) // C6
			aAdd(aContaPagar, {"E2_NUM"     ,IIf(lExist,aSrv3rd[nPos,4],VO4->VO4_NUMTIT)	,Nil} ) // C6
			aAdd(aContaPagar, {"E2_TIPO"    ,Iif(lExist,aSrv3rd[nPos,5],VO4->VO4_TIPTIT)	,Nil} ) // C3
			aAdd(aContaPagar, {"E2_PARCELA"	,Substr(cParc,nGerTit,TamSx3("E2_PARCELA")[1])	,Nil} ) // C3
			aAdd(aContaPagar, {"E2_NATUREZ" ,Iif(lExist,aSrv3rd[nPos,6],VO4->VO4_NATURE)	,Nil} ) // C10
			aAdd(aContaPagar, {"E2_FORNECE" ,Iif(lExist,aSrv3rd[nPos,2],VO4->VO4_CODFOR)	,Nil} ) // C6
			aAdd(aContaPagar, {"E2_LOJA"    ,Iif(lExist,aSrv3rd[nPos,3],VO4->VO4_FOLOJA)	,Nil} ) // C2
			aAdd(aContaPagar, {"E2_EMISSAO" ,dDataBase       								,Nil} ) // D8
			aAdd(aContaPagar, {"E2_VENCTO"  ,aPgto[nGerTit,1]								,Nil} ) // D8
			aAdd(aContaPagar, {"E2_VALOR"   ,aPgto[nGerTit,2]								,Nil} ) // N17 2
			aAdd(aContaPagar, {"E2_VLCRUZ"  ,aPgto[nGerTit,2]								,Nil} ) // N17 2
			aAdd(aContaPagar, {"E2_ORIGEM"  ,"OFIOM030" 	  								,Nil} ) // N17 2
			aAdd(aContaPagar, {"E2_TITORIG" ,VO4->VO4_NOSNUM+VO4->VO4_SEQUEN  				,Nil} ) // N17 2
				//  Parametros do CodBlock
			//  Funcao
			//  Vetor com conta a parar
			//  " "
			//  Tipo de Operacao  3 = Inclusao , 4 = Alteracao, 5 = Exclusao
			pergunte("FIN050",.F.)
			MSExecAuto({|x,Y,Z| FINA050(X,Y,Z)},aContaPagar,,nOperacao)
		Next
	EndIf

	If ExistBlock("OM030TERC")
		ExecBlock("OM030TERC",.f.,.f.)
	EndIf

EndIf

Return(!lMsErroAuto)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_MOVRETSบAutor  ณFabio               บ Data ณ  08/02/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMarca Retorno do Servico                                    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณOficina                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_MOVRETSRV()

Local cSele := Alias(),;
      nPosVO4:= VO4->(Recno()) , nIndVO4 := VO4->(IndexOrd()) ,;
      nPosVOK:= VOK->(Recno()) , nIndVOK := VOk->(IndexOrd())
Local cNosNum , cSrv , cTipTem , cOSRet , cSrvRet , cTpSrvRet
Local nPosR := 0

cNosNum := VO4->VO4_NOSNUM
cTipTem := VO4->VO4_TIPTEM
cSrv    := VO4->VO4_CODSER

If Type("aSrvRetorno") # "U" .and. Len(aSrvRetorno) # 0

	nPosR := Ascan(aSrvRetorno, { |x| x[3] == VO4->VO4_CODSER } )

	Do While nPosR # 0 .And. nPosR <= Len(aSrvRetorno) .And. aSrvRetorno[nPosR,3] == VO4->VO4_CODSER

		If aSrvRetorno[nPosR,1] .Or. aSrvRetorno[nPosR,2]
			VO4->VO4_RENOSV := aSrvRetorno[nPosR,5]   // Numero da OS
			VO4->VO4_RESERV := aSrvRetorno[nPosR,4]   // Codigo do Servico
			VO4->VO4_RETSER := aSrvRetorno[nPosR,17]  // Tipo de Servico
		EndIf

		nPosR++

	EndDo

EndIf

DbSelectArea("VOK")
DbSetOrder(1)
DbSeek( xFilial("VOK") + VO4->VO4_TIPSER )

If VOK->VOK_INCMOB == "4"

	DbSelectArea("VO4")
	DbSetOrder(1)
	DbSeek( xFilial("VO4") + cNosNum + cTipTem + cSrv )

	Do While !Eof() .And. VO4->VO4_FILIAL == xFilial("VO4") .And. VO4->VO4_NOSNUM == cNosNum .And. VO4->VO4_TIPTEM == cTipTem .And. VO4->VO4_CODSER == cSrv

		If !Empty(VO4->VO4_RENOSV) .Or. !Empty(VO4->VO4_RESERV) .Or. !Empty(VO4->VO4_RETSER)
			cOSRet    := VO4->VO4_RENOSV
			cSrvRet   := VO4->VO4_RESERV
			cTpSrvRet := VO4->VO4_RETSER
			Exit
		EndIf

		DbSelectArea("VO4")
		DbSkip()

	EndDo

	DbSelectArea("VO4")
	DbSetOrder(nIndVO4)
	DbGoto(nPosVO4)

	VO4->VO4_RENOSV := cOSRet    // Numero da OS
	VO4->VO4_RESERV := cSrvRet   // Codigo do Servico
	VO4->VO4_RETSER := cTpSrvRet // Tipo de Servico

EndIf

DbSelectArea("VO4")
DbSetOrder(nIndVO4)
DbGoto(nPosVO4)

DbSelectArea("VOK")
DbSetOrder(nIndVOK)
DbGoto(nPosVOK)

DbSelectArea(cSele)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_VETOR  บAutor  ณFabio               บ Data ณ  03/22/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณSalva o conteudo do aCols para Srv ou IniFim                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FS_VETOR(nVetor)

If nVetor == 1
	aColsSrv   := aClone(aCols)
	aHeaderSrv := aClone(aHeader)
EndIf

If nVetor == 2
	aColsIniFim   := aClone(aCols)
	aHeaderIniFim := aClone(aHeader)
EndIf

If nVetor == 3

	aCols   := aClone(aColsSrv)
	aHeader := aClone(aHeaderSrv)

	If lOM030Auto .and. oGetSrv # NIL
		n:=oGetSrv:oBrowse:nAt
		FG_MEMVAR()
	EndIf

EndIf

If nVetor == 4

	aCols   := aClone(aColsIniFim)
	aHeader := aClone(aHeaderIniFim)

	If lOM030Auto .and. oGetIniFim # NIL
		n:=oGetIniFim:oBrowse:nAt
		FG_MEMVAR()
	EndIf

EndIf

// Conout(" ")
// varInfo("aHeader",aHeader)
// Conout(" ")
// varInfo("aCols",aCols)
// Conout(" ")

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_DISENABบAutor  ณFabio               บ Data ณ  03/23/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณDesabilita a getdados corrente                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FS_DISENABLE()

If oFolder030:nOption == 1

	lInicial := .T.		//Incluํdo Mauro - Innovare em 14/06/2023

	FS_VETOR(1)

	oGetSrv:oBrowse:Disable()
	oGetIniFim:oBrowse:Enable()
	oObserv030:Enable()
	oIndice:Enable()

	If GetMv("MV_PONLINE") == "S"
		oConPro:Enable()
		oLbProdutivo:Enable()
		oTimeProdutivo:lActive := .t.
	EndIf

	FS_VETOR(4)

	n:=oGetIniFim:oBrowse:nAt
	oGetIniFim:oBrowse:SetFocus()
	oGetIniFim:oBrowse:Refresh()

Else

	lInicial := .T.		//Incluํdo Mauro - Innovare em 14/06/2023

	oGetIniFim:oBrowse:Disable()
	oObserv030:Disable()
	oIndice:Disable()

	FS_VETOR(2)

	oGetSrv:oBrowse:Enable()

	If GetMv("MV_PONLINE") == "S"
		oConPro:Disable()
		oLbProdutivo:Disable()
		oTimeProdutivo:lActive := .f.
	EndIf

	FS_VETOR(3)

	n:=oGetSrv:oBrowse:nAt
	oGetSrv:oBrowse:SetFocus()
	oGetSrv:oBrowse:Refresh()

EndIf

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_WHENTIPSERบAutor  ณFabio               บ Data ณ  04/25/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณApaga valor do campos que nao atender as condicoes          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FS_WHENTIPSER()

Local cSele := Alias(), nPosSX3 := SX3->(Recno()), nIndSX3 := SX3->(IndexOrd())
Local _ni := 0
Local lVO4IPDCOM := VO4->(FieldPos("VO4_IPDCOM")) > 0
Local cCpoSvT    := ""

DbSelectArea("SX3")
DbSetOrder(2)

If lVO4IPDCOM
	cCpoSvT := "/VO4_IPDCOM/VO4_NNFCOM/VO4_SNFCOM"
EndIf

For _ni := 1 to Len(aHeader)

	DbSeek( aHeader[_ni,2] )

	If !Empty(SX3->X3_WHEN) .And. (aHeader[_ni,2] $ "VO4_KILROD/VO4_CODFOR/VO4_FOLOJA/VO4_NOMFOR/VO4_PEDCOM/VO4_NUMTIT/VO4_TIPTIT/VO4_NATURE/VO4_VALCUS/VO4_VALVEN/VO4_DATPAG/"+cCpoSvT);
		.And. &("!"+Alltrim(SX3->X3_WHEN))

		aCols[n,_ni] := CriaVar(aHeader[_ni,2])

		FG_MEMVAR()

	EndIf

Next

DbSetOrder(nIndSX3)
DbGoTo(nPosSX3)
DbSelectArea(cSele)

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_DUPLAPMบAutor  ณFabio               บ Data ณ  03/22/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCria e Altera linha no IniFim                               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FS_DUPLAPM(cCodSer)
Local nPosaColsIniFim := 0 , _ni := 0

If lOM030Auto .OR. oFolder030:nOption == 1
	VOK->(dbSetOrder(1))

	VOK->(dbSeek(xFilial("VOK") + aCols[n,FG_POSVAR("VO4_TIPSER")] ))

	// Se for sevico de terceiro/Socorro nao cria registro para marcar inicio e fim do servico.
	If VOK->VOK_INCMOB $ "2/5/6" // 2-Servico de Terceiros / 5-Socorro
		Return(.t.)
	EndIf

	Asort(aColsIniFim, 1,, { |x, y| x[FG_POSVAR("VO4_CODSER", "aHeaderIniFim")] < y[FG_POSVAR("VO4_CODSER", "aHeaderIniFim")] })

	nPosaColsIniFim := Ascan(aColsIniFim, { |x| x[FG_POSVAR("VO4_CODSER","aHeaderIniFim")] == aCols[n,FG_POSVAR("VO4_CODSER", "aHeaderSrV")];
		.Or. x[FG_POSVAR("VO4_CODSER", "aHeaderIniFim")] == space(Len(aCols[n,FG_POSVAR("VO4_CODSER", "aHeaderSrV")]))})

	If nPosaColsIniFim == 0
		If cCodSer == NIL // So adiciona linha quando estiver validando o linOk
			AADD(aColsIniFim,Array(Len(aHeaderIniFim) + 1))
		EndIf

		nPosaColsIniFim := Len(aColsIniFim)
	EndIf

	//Do While nPosaColsIniFim <= Len(aColsIniFim) .And.;
	//	aColsIniFim[nPosaColsIniFim, FG_POSVAR("VO4_CODSER","aHeaderIniFim")] == aCols[n, FG_POSVAR("VO4_CODSER")]
	//Do While nPosaColsIniFim <= Len(aColsIniFim) .And.;
	//	If(!Empty(aColsIniFim[nPosaColsIniFim, FG_POSVAR("VO4_CODSER", "aHeaderIniFim")]),;
	//	aColsIniFim[nPosaColsIniFim, FG_POSVAR("VO4_CODSER", "aHeaderIniFim")] == aCols[n, FG_POSVAR("VO4_CODSER", "aHeaderSrv")], .t.)
	Do While nPosaColsIniFim <= Len(aColsIniFim) .And. If(cCodSer # NIL, If(!Empty(aCols[n,FG_POSVAR("VO4_CODSER")]),;
		aColsIniFim[nPosaColsIniFim, FG_POSVAR("VO4_CODSER","aHeaderIniFim")] == aCols[n, FG_POSVAR("VO4_CODSER", "aHeaderSrv")], .f.),;
		Empty(aColsIniFim[nPosaColsIniFim, FG_POSVAR("VO4_CODSER","aHeaderIniFim")]))

		aColsIniFim[Len(aColsIniFim), Len(aHeaderIniFim) + 1] := .F.

		For _ni := 1 to Len(aHeaderIniFim)
			Do Case
				Case _ni == FG_POSVAR("VO4_TEMPAD", "aHeaderIniFim")
					aColsIniFim[nPosaColsIniFim, _ni] := aCols[n, FG_POSVAR("VO4_TEMPAD", "aHeaderSrv")] // Tempo Padrใo
				Case _ni == FG_POSVAR("VO4_GRUSER", "aHeaderIniFim")
					aColsIniFim[nPosaColsIniFim, _ni] := aCols[n,FG_POSVAR("VO4_GRUSER", "aHeaderSrv")]  // Grupo de Servico
				Case _ni == FG_POSVAR("VO4_CODSER", "aHeaderIniFim")
					aColsIniFim[nPosaColsIniFim, _ni]:= M->VO4_CODSER                                    // Codigo do Servico
				Case _ni == FG_POSVAR("VO4_DESSER", "aHeaderIniFim")
					aColsIniFim[nPosaColsIniFim,_ni] := M->VO4_DESSER                                    // Descricao do Servico
				Case _ni == FG_POSVAR("VO4_CODPRO", "aHeaderIniFim")
					If !Empty(cProdPEVM)
						aColsIniFim[nPosaColsIniFim, _ni] := cProdPEVM                                   // Produtivo
					Else
						aColsIniFim[nPosaColsIniFim, _ni] := If(aColsIniFim[nPosaColsIniFim, _ni] # NIL,;
							aColsIniFim[nPosaColsIniFim, _ni], CriaVar(aHeaderIniFim[_ni, 2]))
					EndIf
				Case _ni == FG_POSVAR("VO4_NOMPRO", "aHeaderIniFim")
					if !Empty(cProdPEVM)
						DbSelectArea("VAI")
						DbSetOrder(1)

						DbSeek(xFilial("VAI") + cProdPEVM)

						aColsIniFim[nPosaColsIniFim, _ni] := VAI->VAI_NOMTEC                             // Produtivo
					Else
						aColsIniFim[nPosaColsIniFim, _ni] := If(aColsIniFim[nPosaColsIniFim, _ni] # NIL,;
							aColsIniFim[nPosaColsIniFim, _ni], CriaVar(aHeaderIniFim[_ni, 2]))
					EndIf
				Case _ni == FG_POSVAR("VO4_SEQUEN", "aHeaderIniFim")
					If nPosaColsIniFim <= Len(aControle) .and. VOK->VOK_INCMOB == "2"
						aColsIniFim[nPosaColsIniFim, _ni] := aControle[nPosaColsIniFim, 2]
					Else
						If Empty(aColsIniFim[nPosaColsIniFim, _ni])                                      // Somente criar sequencia quando o campo VO4_SEQUEN nao esta preenchido
							aColsIniFim[nPosaColsIniFim, _ni] := CriaVar(aHeaderIniFim[_ni, 2])          // Sequencia
						EndIf
					EndIf
				Otherwise
					aColsIniFim[nPosaColsIniFim, _ni] := If(aColsIniFim[nPosaColsIniFim, _ni] # NIL,;
						aColsIniFim[nPosaColsIniFim, _ni], CriaVar(aHeaderIniFim[_ni, 2]))               // Demais Campos
			EndCase
//				Case _ni == FG_POSVAR("VO4_SEQUEN", "aHeaderIniFim")
//					aColsIniFim[nPosaColsIniFim, _ni] := If(Empty(aColsIniFim[nPosaColsIniFim, _ni]),;
//						"001", aColsIniFim[nPosaColsIniFim, _ni])                                        // Sequencia
		Next

		nPosaColsIniFim++

		DbSelectArea("VO4")
	EndDo
EndIf
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_SERTEM บAutor  ณFabio               บ Data ณ  07/07/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVerifica se o tipo de servico esta relacionado com o tipo   บฑฑ
ฑฑบ          ณde tempo.                                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FS_SERTEM(cTipSer,cTipTem,lMensagem,lTpo,lTpSrvBlq)

Local nTemPad    := 0
Local lVO4PREKIL := VO4->(FieldPos("VO4_PREKIL")) <> 0
Local lVOKMOEDA  := VOK->(FieldPos("VOK_MOEDA" )) <> 0
Local nPreKil    := 0
Local oTipSer    := DMS_Servico():New()

Default cTipSer   := M->VO4_TIPSER
Default cTipTem   := M->VO4_TIPTEM
Default lMensagem := .t.
Default lTpo      := .t.
Default lTpSrvBlq := .f.

//
If ExistBlock("OM030VTS")
	If !ExecBlock("OM030VTS",.f.,.f.,{1,cTipSer,cTipTem,lMensagem,lTpo})
		Return .f.
	EndIf
EndIf
//

VOX->( DbSetOrder(1) )
lConsidera := .t.
if VOI->(FieldPos("VOI_CONVOX")) > 0
	VOI->(DbSetOrder(1))
	VOI->(DbSeek( xFilial("VOI") + cTipTem ))
	if VOI->VOI_CONVOX == "0"
		lConsidera := .f.
	endif
endif
If !VOX->( DbSeek( xFilial("VOX") + cTipSer + cTipTem ) ) .and. lConsidera
	If lMensagem
		Help(1,"  ","TPSERTEM")
	EndIf

	Return .f.
EndIf

// A variแvel lTpSrvBlq apenas serแ .f. quando a fun็ใo for chamada pelo SXB
If lTpSrvBlq .And. FindFunction("OFXFA0016_VerificaMetodoEmClasse") .And. OFXFA0016_VerificaMetodoEmClasse(oTipSer, "TipServBloqueado")
	// Tipo de Servi็o Bloqueado
	If oTipSer:TipServBloqueado(cTipSer, lMensagem)
		Return .f. // A mensagem jแ ้ exibida dentro da fun็ใo OFM0300026_TipSerBloqueado()
	EndIf
EndIf

If lMensagem .And. lTpo

	nTemPad        := int(FG_TEMPAD(VV1->VV1_CHAINT,M->VO4_CODSER,if(VOK->VOK_INCTEM == "3","1",VOK->VOK_INCTEM),VOK->VOK_INCMOB)) / 100
	M->VO4_TEMPAD := nTemPad * 100

	If VOK->VOK_INCMOB $ "2/5" // Servi็o de Terceiro e Kilometragem
		M->VO4_VALHOR := aCols[n,FG_POSVAR("VO4_VALHOR")] := 0
		If lVO4PREKIL .and. VOK->VOK_INCMOB == "5" // Servi็o de Terceiro e Kilometragem
			nPreKil := VOK->VOK_PREKIL
			If lVOKMOEDA .and. VOK->VOK_MOEDA <> VO1->VO1_MOEDA
				nPreKil := FG_MOEDA(nPreKil, VOK->VOK_MOEDA, VO1->VO1_MOEDA)
			EndIf
			M->VO4_PREKIL := aCols[n,FG_POSVAR("VO4_PREKIL")] := nPreKil
		Endif
	Endif

	If Type("aCols") # "U" .And. FG_POSVAR("VO4_TEMPAD") # 0
		aCols[n,FG_POSVAR("VO4_TEMPAD")] := nTemPad * 100
		aCols[n,FG_POSVAR("VO4_TIPTIT")] := If( GetNewPar("MV_SRV3PD","N") $ "P.T" .and. Posicione("VOK",1,xFilial("VOK")+cTipSer,"VOK_INCMOB") == "2","PR",CriaVar("VO4_TIPTIT"))
	EndIf

EndIf

Return .t.

/*/{Protheus.doc} om030SRVJAREQ

Valida se um servico ja foi requisitado.
So ้ permitir repetir o codigo de servico para servico de terceiros

@author Rubens Takahashi
@since 17/09/2023
@param
@type function
/*/
static function om030SRVJAREQ()
	local ni

	If !Empty(M->VO4_TIPSER)

		VOK->(dbSetOrder(1))
		VOK->(MsSeek(xFilial("VOK") + M->VO4_TIPSER))

		If (ReadVar() == "M->VO4_TIPSER" .And. (Empty(aCols[n,FG_POSVAR("VO4_TIPSER")]) .Or. aCols[n,FG_POSVAR("VO4_TIPSER")] # M->VO4_TIPSER)) .or. FWIsInCallStack("FS_VALDEL")

			cVOKINCMOB := VOK->VOK_INCMOB

			// 2=Srv.Terceiro/6=Franquia
			// Neste caso nao pode haver um registro de requisicao com tipo de servi็o que seja diferente de 2/6
			if cVOKINCMOB $ "2/6"
				VOK->(dbSetOrder(1))
				for ni := 1 to Len(aCols)
					if ni <> n .and. aCols[ni,FG_POSVAR("VO4_CODSER")] == M->VO4_CODSER .and. aCols[ni,FG_POSVAR("VO4_TIPSER")] <> M->VO4_TIPSER .and. !aCols[n, Len(aCols[n])] .and. !aCols[ni, Len(aCols[ni])]
						VOK->(MsSeek(xFilial("VOK") + aCols[ni,FG_POSVAR("VO4_TIPSER")]))
						if ! VOK->VOK_INCMOB $ "2/6"
							Help("  ",1,"SRVJAREQ")
							return .t.
						endif
					endif
				next nI
			// 0=M.Obra Gratuita;1=M.Obra;3=Vlr.Livre c/Base na Tabela;4=Retorno Srv.;5=Km Socorro;7=Vlr.Informado
			// Neste caso nao pode haver um registro de requisicao com o mesmo codigo de servico
			else
				for ni := 1 to Len(aCols)
					if ni <> n .and. aCols[ni,FG_POSVAR("VO4_CODSER")] == M->VO4_CODSER .and. !aCols[n, Len(aCols[n])] .and. !aCols[ni, Len(aCols[ni])]
						Help("  ",1,"SRVJAREQ")
						return .t.
					endif
				next nI
			EndIf

		endif
	EndIf

return .f.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_TPFSRV บAutor  ณFabio               บ Data ณ  07/07/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEspaco no when do SX3 insuficiente, necessario criar funcao บฑฑ
ฑฑบ          ณpara verificar se pode alterar o faturar para.              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FS_TPFSRV(lValida)

FG_SEEK("VOI","M->VO4_TIPTEM",1,.F.)

lValida := If(lValida # NIL,FG_TIPTPFAT(,"M->VO4_FATPAR","M->VO4_LOJA","M->VO4_NOMCLI",Posicione("VV1",1,xFilial("VV1")+VO1->VO1_CHAINT,"VV1_CODMAR"),"S"),FG_TIPTPFAT(aCols[n,FG_POSVAR("VO4_TIPTEM","aHeaderSrv")]))

Return(lValida)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_MEMVAR0บAutor  ณFabio               บ Data ณ  07/07/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณSalva conteudo da linha do aCols na memoria                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณOficina                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FS_MEMVAR030()

Local bCampo := {|x| aHeader[x,2]}
Local z := 0

For z := 1 to Len(aHeader)
	&( "M->"+(EVAL(bCampo,z)) ) := aCols[n,z]
Next

// Posiciona os arquivos P/ determinada linha da getdados
VOI->( DbSeek( xFilial("VOI") + M->VO4_TIPTEM ) )
SA1->( DbSeek( xFilial("SA1") + M->VO4_FATPAR+M->VO4_LOJA ) )
VOS->( DbSeek( xFilial("VOS") + VV1->VV1_CODMAR+M->VO4_GRUSER ) )
VOK->( DbSeek( xFilial("VOK") + M->VO4_TIPSER ) )
VOD->( DbSeek( xFilial("VOD") + M->VO4_CODSEC ) )
VAI->( DbSeek( xFilial("VAI") + M->VO4_CODPRO ) )
SA2->( DbSeek( xFilial("SA2") + M->VO4_CODFOR+M->VO4_FOLOJA ) )
SED->( DbSeek( xFilial("SED") + M->VO4_NATURE ) )

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_ALTREG บAutor  ณFabio               บ Data ณ  03/02/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVerifica se o campo pode ser digitado "When"                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FS_ALTREG(nAba,nLinha)

Default nLinha := n

If lOM030Auto
	Return
EndIF

FS_MEMVAR030()

If nAba == 1

	If Len(aAlter[nAba]) >= nLinha .And. nLinha # 0
		oGetSrv:aAlter := oGetSrv:oBrowse:aAlter := aClone(aAlter[nAba,nLinha])
	Else
		oGetSrv:aAlter := oGetSrv:oBrowse:aAlter := aClone(aAlter[nAba,Len(aAlter[nAba])])
	EndIf

	if Empty(M->VO4_TIPTEM)
		M->VO4_NOMCLI := ""
		aCols[nLinha,FG_POSVAR("VO4_NOMCLI")] := ""
		M->VO4_DATPAG := ctod(" ")
		aCols[nLinha,FG_POSVAR("VO4_DATPAG")] := ctod("")
		M->VO4_DESSER := ""
		aCols[nLinha,FG_POSVAR("VO4_DESSER")] := ""
	Endif

Else
	//Adicionado o IF e a parte .T. do IF (Mauro - Innovare - 07/06/2023)

	IF lInicial
		lInicial := .F.
		oGetIniFim:aAlter := oGetIniFim:oBrowse:aAlter := aClone(aAlter[nAba,1])
	Else
		nLinha := Ascan(aAlter[2],{|x| x[1] == M->VO4_SEQUEN })

		If Len(aAlter[nAba]) >= nLinha .And. nLinha # 0
			oGetIniFim:aAlter := oGetIniFim:oBrowse:aAlter := aClone(aAlter[nAba,nLinha])
		Else
			oGetIniFim:aAlter := oGetIniFim:oBrowse:aAlter := aClone(aAlter[nAba,Len(aAlter[nAba])])
		EndIf
	Endif
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_DUPL030บAutor  ณFabio               บ Data ณ  03/02/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณDuplica o servico no aColsIniFim                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FS_DUPL030(cIndices,lDupl,lRefresh,lIndex,cCodPro,dDataIni,nHoraIni,dDataFin,nHoraFin,cStatus,lAddLine)

Local nLinha := n ,cSeekPos
Local _ni := 0

Default lIndex   := .t.
Default lAddLine := .t.

If Len(aHeader) # Len(aHeaderIniFim) .or. aCols[nlinha,Len(aCols[nlinha])]
	Return(!lDupl)
EndIf

// Valida autorizacao do usuario
If !FS_VALDPRO(__cUserID,aCols[n,FG_POSVAR("VO4_CODPRO")])
	Return(.f.)
EndIf

If !lOM030Auto .and. lRefresh
	cSeekPos := aCols[n,FG_POSVAR("VO4_CODSER")]+aCols[n,FG_POSVAR("VO4_SEQUEN")]
EndIf

ni_ := Ascan(aColsSrv,{|x| x[FG_POSVAR("VO4_CODSER","aHeaderSrv")] == aCols[n,FG_POSVAR("VO4_CODSER")] })
if ni_ > 0
	if aColsSrv[ni_,FG_POSVAR("VO4_SRVFIN","aHeaderSrv")] == "1"
		aColsSrv[ni_,FG_POSVAR("VO4_SRVFIN","aHeaderSrv")] := "0"
	Endif
Endif

If lDupl

	If lAddLine
		AADD(aCols,Array(Len(aHeader)+1))
		nLinha := Len(aCols)
	EndIf

	For _ni := 1 to Len(aHeader)

		If aHeader[_ni,2] $ "VO4_GRUSER/VO4_CODSER/VO4_DESSER/VO4_CODFAS/VO4_DESFAS/VO4_TEMPAD" .Or. (aHeader[_ni,2] $ "VO4_SEQUEN/VO4_TEMFAS" .And. !lAddLine)
			aCols[nLinha,_ni] := aCols[n,_ni]
		Else
			aCols[nLinha,_ni] := CriaVar(aHeader[_ni,2])
		EndIf

		If cCodPro # NIL

			do case
			case  _ni == FG_POSVAR("VO4_CODPRO")
				aCols[nLinha,_ni] := cCodPro
			case  _ni == FG_POSVAR("VO4_NOMPRO")
				aCols[nLinha,_ni] := Posicione("VAI",1,xFilial("VAI")+cCodPro,"VAI_NOMTEC")
			case  _ni == FG_POSVAR("VO4_DATINI")
				aCols[nLinha,_ni] := dDataIni
			case  _ni == FG_POSVAR("VO4_HORINI")
				aCols[nLinha,_ni] := nHoraIni
			case  _ni == FG_POSVAR("VO4_DATFIN")
				aCols[nLinha,_ni] := dDataFin
			case  _ni == FG_POSVAR("VO4_HORFIN")
				aCols[nLinha,_ni] := nHoraFin
			case  _ni == FG_POSVAR("VO4_HOREXT")
				aCols[nLinha,_ni] := If( cStatus == "D" , "O" , "E" )
			EndCase

		EndIf

	Next

	If lOM030Auto .and. lAddLine
		n := nLinha
	EndIf
	aCols[nLinha,Len(aHeader)+1]:=.F.

EndIf

If lIndex

	If cIndices == STR0008 //"Codigo Servico + Sequencia + Data Inicial + Hora"
		Asort(aCols,1,,{ |x,y| x[FG_POSVAR("VO4_CODSER")]+x[FG_POSVAR("VO4_SEQUEN")]+Dtos(x[FG_POSVAR("VO4_DATINI")])+Str(x[FG_POSVAR("VO4_HORINI")],4) < y[FG_POSVAR("VO4_CODSER")]+y[FG_POSVAR("VO4_SEQUEN")]+Dtos(y[FG_POSVAR("VO4_DATINI")])+Str(y[FG_POSVAR("VO4_HORINI")],4) })
	ElseIf cIndices == STR0009 //"Codigo do Mecanico + Data Inicial + Hora"
		Asort(aCols,1,,{ |x,y| x[FG_POSVAR("VO4_CODPRO")]+Dtos(x[FG_POSVAR("VO4_DATINI")])+Str(x[FG_POSVAR("VO4_HORINI")],4) < y[FG_POSVAR("VO4_CODPRO")]+Dtos(y[FG_POSVAR("VO4_DATINI")])+Str(y[FG_POSVAR("VO4_HORINI")],4) })
	Else
		Asort(aCols,1,,{ |x,y| Dtos(x[FG_POSVAR("VO4_DATINI")])+Str(x[FG_POSVAR("VO4_HORINI")],4) < Dtos(y[FG_POSVAR("VO4_DATINI")])+Str(y[FG_POSVAR("VO4_HORINI")],4) })
	EndIf

EndIf

FS_VETOR(2)
FS_ALTREG(2)

If !lOM030Auto .and. lRefresh
	oGetIniFim:oBrowse:SetFocus()
	n := Ascan(aCols,{|x| x[FG_POSVAR("VO4_CODSER")] + x[FG_POSVAR("VO4_SEQUEN")] == cSeekPos })
EndIf

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_VALDEL บAutor  ณFabio               บ Data ณ  04/19/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVerifica se o servico pode ser deletado                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FS_VALDEL(nAba,cCodSer,cSequencia,lMensagem)


Local nx := 0 , nPos := 0
Local lVO4PEDCOM := VO4->(FieldPos('VO4_PEDCOM')) > 0
Local cCpoPedTit := ""
Local nVlrSrvs   := 0
Local nMoedaC    := 0
Default lMensagem := .t.

If ExistBlock("OM030DEL")
	lRet := ExecBlock("OM030DEL",.f.,.f.,{nAba})
	If !lRet
		Return (.f.)
	Endif
Endif

If nAba == 1

	If	( Len( aSeguros ) # 0 .And. Ascan( aSeguros , { |x| x[2] == aCols[n,FG_POSVAR("VO4_TIPTEM")] } ) # 0 .and. VOI->(FieldPos("VOI_TPSEGU")) == 0)

		Return(.f.)

	EndIf

	If !aCols[n,Len(aCols[n])]

		If GetNewPar("MV_SRV3PD"," ")	== "P"

			SC7->( DbSetOrder(1) )
			lRet := .t.
			cCpoPedTit := "VO4_NUMTIT"
			If lVO4PEDCOM // Nro do Pedido
				cCpoPedTit := "VO4_PEDCOM"
			EndIf
			If !Empty(aCols[n,FG_POSVAR(cCpoPedTit)]) .And. SC7->( DbSeek(xFilial("SC7") + aCols[n,FG_POSVAR(cCpoPedTit)] ) )
				lRet := .f.
			EndIf

			If !lRet
				Help("  ",1,"DELSRVPED",,STR0113,4,1)//Existe pedido de compra para esse servico.
				Return(.f.)
			EndIf

		EndIf

		If !FS_DISPOS(oFolder030:nOption)
			Return(.f.)
		EndIf

	EndIf

	// Deleta Apontamento
	For nx := 1 to 2
		Asort(aColsIniFim,1,,{ |x,y| x[FG_POSVAR("VO4_CODSER","aHeaderIniFim")]+x[FG_POSVAR("VO4_SEQUEN","aHeaderIniFim")] < y[FG_POSVAR("VO4_CODSER","aHeaderIniFim")]+y[FG_POSVAR("VO4_SEQUEN","aHeaderIniFim")] })

		nPos := Ascan(aColsIniFim,{ |x| x[FG_POSVAR("VO4_CODSER","aHeaderIniFim")] == aCols[n,FG_POSVAR("VO4_CODSER")] } )

		Do While nPos # 0 .And. nPos <= Len(aColsIniFim) .And. aColsIniFim[nPos,FG_POSVAR("VO4_CODSER","aHeaderIniFim")] == aCols[n,FG_POSVAR("VO4_CODSER")]

			VO4->(DbSetOrder(4))
			VO4->(DbSeek(xFilial("VO4")+aColsIniFim[nPos,FG_POSVAR("VO4_CODSER","aHeaderIniFim")]+M->VO2_NOSNUM+aColsIniFim[nPos,FG_POSVAR("VO4_SEQUEN","aHeaderIniFim")]))

			If nx==1 .And. !aColsIniFim[nPos,Len(aColsIniFim[nPos])] .And. (!Empty(VO4->VO4_CODPRO) .Or. !Empty(VO4->VO4_DATINI) .Or. !Empty(VO4->VO4_DATFIN))

				If lMensagem
					Help("  ",1,"NPERDEL")
				EndIf

				Return(.f.)

			EndIf

			VOK->(DbSetOrder(1))
			VOK->(DbSeek(xFilial("VOK")+aCols[n,FG_POSVAR("VO4_TIPSER")]))

			If !( VOK->VOK_INCMOB $ "2/5/6" )   //Not Servico de Terceiro/Socorro/Franquia

				If nx==2 .And. Empty(VO4->VO4_DATINI) .And. Empty(VO4->VO4_DATFIN)
					aColsIniFim[nPos,Len(aColsIniFim[nPos])] := aCols[n,Len(aCols[n])]
				EndIf

			EndIf

			nPos++

		EndDo

		If nx == 1
			aCols[n,Len(aCols[n])]:= !aCols[n,Len(aCols[n])]
		EndIf

	Next

	If !aCols[n,Len(aCols[n])]
		if !FindFunction('FGX_ChkCredCond') .or. FGX_ChkCredCond(VO1->VO1_FORPAG)
			If "S" $ GetMv("MV_CHKCRE") .And. !(VOI->VOI_SITTPO $ "2/3/4")
				nVlrSrvs := OFM0300025_LevantaValorServicosGrid(n)
				nMoedaC  := IIF(FGX_MULTMOEDA(),IIF(VO1->(FieldPos("VO1_MOEDA"))>0,Max(VO1->VO1_MOEDA,1), nil ), nil )
				If !FGX_AVALCRED(M->VO4_FATPAR,M->VO4_LOJA, nVlrSrvs ,.t., ,VO1->VO1_NUMOSV , nMoedaC )
					Help("  ",1,"LIMITECRED")
					aCols[n,Len(aCols[n])] := !aCols[n,Len(aCols[n])]
					Return(.f.)
				EndIf
			EndIf
		Endif
	EndIf

	// Marca Desmarca Retorno de Servico
	FS_DESMARCA(aCols[n,FG_POSVAR("VO4_CODSER")], !aCols[n,Len(aCols[n])] )

	If Len( aSeguros ) # 0 .and. VOI->(FieldPos("VOI_TPSEGU")) == 0

		nx := Ascan( aSeguros , { |x| x[1] == aCols[n,FG_POSVAR("VO4_TIPTEM")] } )

		If nx # 0 .And. aSeguros[ nx , 3 ]

			nx := Ascan( aCols , { |x| x[FG_POSVAR("VO4_TIPTEM")] == aSeguros[nx,2] } )

			If nx # 0

				aCols[nx,Len(aCols[nx])] := aCols[n,Len(aCols[n])]

			EndIf

		EndIf

	EndIf

	if om030SRVJAREQ()
		aCols[n,Len(aCols[n])] := !aCols[n,Len(aCols[n])]
		Return(.f.)
	endif

	oGetSrv:oBrowse:SetFocus()

Else

	If !aCols[n,Len(aCols[n])] .And. !FS_DISPOS(oFolder030:nOption)
		Return(.f.)
	EndIf

	If !FS_TRANSFPEC(aCols[n,FG_POSVAR("VO4_CODSER")] , aCols[n,FG_POSVAR("VO4_CODPRO")] , M->VO2_NOSNUM+aCols[n,FG_POSVAR("VO4_SEQUEN")] )
		Return(.f.)
	EndIf

	If !FS_VALDPRO(__cUserID,M->VO4_CODPRO)
		Return(.f.)
	EndIf

	// Verifica se o servico esta deletado
	If aCols[n,Len(aCols[n])]
		VOK->(DbSetOrder(1))
		For nx := 1 to Len(aColsSrv)
			If aColsSrv[nx,FG_POSVAR("VO4_CODSER","aHeaderSrv")] == aCols[n,FG_POSVAR("VO4_CODSER")] .And. aColsSrv[nx,Len(aColsSrv[nx])] ;
				.And. VOK->(DbSeek(xFilial("VOK")+aColsSrv[nx,FG_POSVAR("VO4_TIPSER","aHeaderSrv")])) .And. !( VOK->VOK_INCMOB $ "2/5/6" )
				Return(.f.)
			EndIf
		Next

		// Valida produtivo / apontamento ...
		If !Empty(M->VO4_CODPRO)
			__ReadVar := 'M->VO4_CODPRO'
			If !FS_030VALID("F",.t.)
				Return .f.
			EndIf
		EndIf

		If !Empty(M->VO4_DATINI)
			__ReadVar := 'M->VO4_DATINI'
			If !FS_030VALID("F",.t.)
				Return .f.
			EndIf
		EndIf

		If !Empty(M->VO4_HORINI)
			__ReadVar := 'M->VO4_HORINI'
			If !FS_030VALID("F",.t.)
				Return .f.
			EndIf
		EndIf

		If !Empty(M->VO4_DATFIN)
			__ReadVar := 'M->VO4_DATFIN'
			If !FS_030VALID("F",.t.)
				Return .f.
			EndIf
		EndIf

		If !Empty(M->VO4_HORFIN)
			__ReadVar := 'M->VO4_HORFIN'
			If !FS_030VALID("F",.t.)
				Return .f.
			EndIf
		EndIf
		//

	EndIf

	VO4->(DbSetOrder(4))
	VO4->(MsSeek(xFilial("VO4")+cCodSer+M->VO2_NOSNUM+cSequencia))

	aCols[n,Len(aCols[n])] := !aCols[n,Len(aCols[n])]
	oGetIniFim:oBrowse:SetFocus()
	oGetIniFim:oBrowse:Refresh()

	// Atualiza Produtivo OnLine
	FS_PRODONLINE(M->VO4_CODPRO)

EndIf

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_AGRUSERบAutor  ณFabio               บ Data ณ  15/12/99   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณLista as pecas do agrupamento e baixa em estoque            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FS_AGRUSER(cCodMar,cModVei,cCodSer,cTipTem,cCodPro,lTela,lJaReq)

Local cSele := Alias() ,nPosAlias := Recno(), nPosPecas := 0 , nPosVO8 := 0
Local lReturn := .t. , cTipAgr
Local nPos := 0
Local lSair := .f.
Local OXvermelho
Private oFonte   := TFont():New( "Arial", 6, 10 )
Private oOk     := LoadBitmap( GetResources(), "LBTIK" )
Private oNo     := LoadBitmap( GetResources(), "LBNO" )
Private oBranco := LoadBitmap( GetResources(), "FOLDER9" )
Private aAgrSerList := {}
Private overmelho:= LoadBitmap( GetResources() , "BR_VERMELHO" )	// Pecas ja requisitadas
Default lTela  := .t.
Default lJaReq := .f.

DbSelectArea("VO6")
nPosVO6 := Recno()

If !OFM0300011_PosicionaVO6( cCodSer )
	Help("  ",1,"SRVINEX")
	DbSelectArea(cSele)
	DbGoto(nPosAlias)
	Return(.t.)
EndIf

If VO6->VO6_AGRSER == "S"

	aAgrSerList := {}

	lReturn := .t.

	DbSelectArea("VO8")
	nPosVO8 := Recno()
	DbSetOrder(2)

	If !DbSeek(xFilial("VO8")+ FG_MARSRV(cCodMar,cCodSer) +cModVei+cCodSer)
		Aadd(aAgrSerList,{VO8->VO8_TIPAGR , If(VO8->VO8_TIPAGR=="0",STR0012,If(VO8->VO8_TIPAGR=="1",STR0013,STR0014)), ,0 , .f. , .f. , "" , "" , "" , , 0 }) //"Ferramentas"###"Servicos"###"Pecas"
	EndIf

	cTipAgr := VO8->VO8_TIPAGR

	Do While !Eof() .And. VO8->VO8_CODMAR== FG_MARSRV(cCodMar,cCodSer) .And. VO8->VO8_MODVEI==cModVei .And. VO8->VO8_CODSER==cCodSer ;
		.And. VO8->VO8_FILIAL == xFilial("VO8")

		DbSelectArea("SB1")
		DbSetOrder(7)
		DbSeek( xFilial("SB1") + VO8->VO8_GRUITE + VO8->VO8_CODITE )

		DbSelectArea("SB5")
		DbSetOrder(1)
		DbSeek( xFilial("SB5") + SB1->B1_COD )

		If VO8->VO8_TIPAGR # cTipAgr

			Aadd(aAgrSerList,{VO8->VO8_TIPAGR , If(VO8->VO8_TIPAGR=="0",STR0012,If(VO8->VO8_TIPAGR=="1",STR0013,STR0014+" - "+STR0015)), ,0 ,.f. ,.f. , "" , "" , "" , 0 }) //"Ferramentas"###"Servicos"###"Pecas"###"Agrupado"
			cTipAgr := VO8->VO8_TIPAGR

		EndIf

		If VO8->VO8_TIPAGR == "0"     // Ferramentas
			Aadd(aAgrSerList,{VO8->VO8_TIPAGR , VO8->VO8_CODFER , Posicione("VO9",1,xFilial("VO9")+VO8->VO8_CODFER,"VO9_DESFER") , 0  , .t. , .f. , "" , "" , "" , 0 })
		ElseIf VO8->VO8_TIPAGR == "1" // Servico
			Aadd(aAgrSerList,{VO8->VO8_TIPAGR , VO8->VO8_CODSRV , Posicione("VO6",2,xFilial("VO6")+FG_MARSRV(cCodMar,VO8->VO8_CODSRV) + VO8->VO8_CODSRV ,"VO6_DESSER") , 0  , .t. , .f. , "" , "" , "" , 0 })
		Else                          // Pecas
			Aadd(aAgrSerList,{VO8->VO8_TIPAGR , VO8->VO8_GRUITE+"  "+VO8->VO8_CODITE , Posicione("SB1",7,xFilial("SB1")+VO8->VO8_GRUITE+VO8->VO8_CODITE,"B1_DESC") , VO8->VO8_QTDITE , .t. , .t. , SB1->B1_COD , FM_PRODSBZ(SB1->B1_COD,"SB1->B1_LOCPAD") , FM_PRODSBZ(SB1->B1_COD,"SB5->B5_LOCALI2") , 0 })
			nPos := Ascan(aAgrupSer,{|x| x[3] == aAgrSerList[Len(aAgrSerList),2] })
			If nPos > 0
				If !aAgrupSer[nPos,7]
					aAgrupSer[nPos,15] := 1
				EndIf
				aAgrSerList[Len(aAgrSerList),10] := aAgrupSer[nPos,15]
			EndIf
		EndIf

		FS_ADDAGRU( VO8->VO8_GRUITE , VO8->VO8_CODITE , VO8->VO8_TIPAGR , cTipTem , cCodSer , cCodPro , FM_PRODSBZ(SB1->B1_COD,"SB1->B1_LOCPAD") , FM_PRODSBZ(SB1->B1_COD,"SB5->B5_LOCALI2") , lJaReq )

		If Len(aAgrupSer) # 0

			nPosPecas := Ascan(aAgrupSer,{|x| x[1] + x[3] == cCodSer + aAgrSerList[Len(aAgrSerList),2] })

		EndIf

		If nPosPecas == 0
			nPosPecas := Len(aAgrupSer)
		EndIf

		DbSelectArea("VO8")
		DbSkip()

	EndDo

EndIf


// Pecas do Orcamento
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณRubens - 06/11/2009         ณ
//ณRetirado momentaneamente ...ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ(ู
/*
DbSelectArea("VSJ")
DbSetOrder(1)
DbSeek( xFilial("VSJ") + VO1->VO1_NUMOSV )

Do While !Eof() .And. VSJ->VSJ_FILIAL == xFilial("VSJ") .And. VSJ->VSJ_NUMOSV == VO1->VO1_NUMOSV

   If Len(aAgrupSer) # 0

      nPosPecas := Ascan(aAgrupSer,{|x| x[2] + x[1] + x[3] == "2" + cCodSer + VSJ->VSJ_GRUITE+"  "+VSJ->VSJ_CODITE })

   EndIf

   If nPosPecas == 0 .Or. !aAgrupSer[nPosPecas,10]

      If Len(aAgrSerList) == 0 .Or. Ascan(aAgrSerList,{ |x| x[1] == "2" } ) == 0

      	Aadd(aAgrSerList,{"2" , STR0014+" - "+STR0016 , ,0 ,.f. ,.f. ,"","","",0}) //"Pecas"###"Orcamento"

		EndIf

		DbSelectArea("SB1")
		DbSetOrder(7)
		DbSeek( xFilial("SB1") + VSJ->VSJ_GRUITE + VSJ->VSJ_CODITE )

		DbSelectArea("SB5")
		DbSetOrder(1)
		DbSeek( xFilial("SB5") + SB1->B1_COD )

	   Aadd(aAgrSerList,{ "2" , VSJ->VSJ_GRUITE+"  "+VSJ->VSJ_CODITE , Posicione("SB1",7,xFilial("SB1")+VSJ->VSJ_GRUITE+VSJ->VSJ_CODITE,"B1_DESC") , VSJ->VSJ_QTDITE , .t. , .t. , SB1->B1_COD , If( VSJ->VSJ_RESPEC == "0" , FM_PRODSBZ(SB1->B1_COD,"SB1->B1_LOCPAD") , GetMv("MV_RESITE")+Space(TamSx3("BF_LOCAL")[1]-Len(GetMv("MV_RESITE"))) ) ,  If( VSJ->VSJ_RESPEC == "0" , FM_PRODSBZ(SB1->B1_COD,"SB5->B5_LOCALI2") , GetMv("MV_RESLOC")+Space(TamSx3("B5_LOCALI2")[1]-Len(GetMv("MV_RESLOC"))) ) , 0 })

	   nPos := Ascan(aAgrupSer,{|x| x[3] == aAgrSerList[Len(aAgrSerList),2] })
		If nPos > 0
			If !aAgrupSer[nPos,7]
				aAgrupSer[nPos,15] := 1
			EndIf
			aAgrSerList[Len(aAgrSerList),10] := aAgrupSer[nPos,15]
		EndIf
   	FS_ADDAGRU( VSJ->VSJ_GRUITE , VSJ->VSJ_CODITE , "2" , cTipTem , cCodSer , cCodPro , If( VSJ->VSJ_RESPEC == "0" , FM_PRODSBZ(SB1->B1_COD,"SB1->B1_LOCPAD") , GetMv("MV_RESITE")+Space(TamSx3("B2_LOCAL")[1]-Len(GetMv("MV_RESITE"))) ) ,  If( VSJ->VSJ_RESPEC == "0" , FM_PRODSBZ(SB1->B1_COD,"SB5->B5_LOCALI2") , GetMv("MV_RESLOC")+Space(TamSx3("B5_LOCALI2")[1]-Len(GetMv("MV_RESLOC"))) ) , lJaReq )

	   nPosPecas := Len(aAgrupSer)

   EndIf

   DbSelectArea("VSJ")
   DbSkip()

EndDo
*/
// Monta Tela
If lTela .And. Len( aAgrupSer ) # 0 .And. nPosPecas != 0 .and. !aAgrupSer[nPosPecas , 10]

	DEFINE MSDIALOG oDlgAgruSer TITLE STR0017 From 15,20 to 27,93   of oMainWnd //"Agrupamento de Servico"

	@ .1,.1 LISTBOX oLbAgruSer FIELDS HEADER   OemToAnsi(""),;
		OemToAnsi(STR0018),; // "Cod item" //"Codigo"
		OemToAnsi(STR0019),; //"Descricao"
		OemToAnsi(STR0020); //"Quantidade"
		COLSIZES 10,90,130,30;
		SIZE 288,75 OF oDlgAgruSer ON DBLCLICK FS_POEVER(,,"T")

	oLbAgruSer:SetArray(aAgrSerList)
	oLbAgruSer:bLine := { || { If(aAgrSerList[oLbAgruSer:nAt,1] # "2" .Or. !aAgrSerList[oLbAgruSer:nAt,5] , oBranco , If(aAgrSerList[oLbAgruSer:nAt,10]==0,If(aAgrSerList[oLbAgruSer:nAt,6],oNo,oOk),oVermelho) ) ,;
		aAgrSerList[oLbAgruSer:nAt,2] ,;
		aAgrSerList[oLbAgruSer:nAt,3] ,;
		If(!(aAgrSerList[oLbAgruSer:nAt,1] $ "0/1") .And. aAgrSerList[oLbAgruSer:nAt,5] ,Transform(aAgrSerList[oLbAgruSer:nAt,4],"@E 999,999,999")," ") }}

	DEFINE SBUTTON oBotInc FROM 77,225 TYPE 4 ACTION (lSair:=.t.,FS_POEVER(cCodSer,.f.),oDlgAgruSer:End()) ENABLE OF oDlgAgruSer
	oBotInc:cToolTip := OemtoAnsi(STR0021) //"Requisita Peca Automaticamente!"

	DEFINE SBUTTON FROM 77,255 TYPE 2 ACTION (oDlgAgruSer:End()) ENABLE OF oDlgAgruSer //(FS_POEVER(cCodSer,.t.),oDlgAgruSer:End())

	@ 080,003 BITMAP OXvermelho RESOURCE "BR_VERMELHO" OF oDlgAgruSer PIXEL NOBORDER SIZE 10,10 when .f.
	@ 080,012 SAY STR0092 SIZE 160,10 OF oDlgAgruSer PIXEL COLOR CLR_HBLUE

	ACTIVATE MSDIALOG oDlgAgruSer ON INIT oBotInc:SetFocus() CENTER

	If !lSair
		For nPos := 1 to len(aAgrSerList)
			If !aAgrSerList[nPos,6]
				aAgrSerList[nPos,6] := .t.
				aAgrSerList[nPos,10]:= 0
			EndIf
		Next
		FS_POEVER(cCodSer,.t.)
	EndIf

EndIf

If Len(aAgrupSer) # 0
	Asort(aAgrupSer,1,,{|x,y| x[1] == y[1] })
EndIf

VO8->(DBGoTo(nPosVO8))
VO6->(DBGoTo(nPosVO6))

DbSelectArea(cSele)
DbGoto(nPosAlias)

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_ADDAGRUบAutor  ณFabio               บ Data ณ  10/09/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAdiciona pecas no vetor                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_ADDAGRU( cGruIte , cCodIte , cTipAgru , cTipTem , cCodSer , cCodPro , cLocal , cLocaliz , lJaReq )

Private cAgruForm , nAgruVal  := 0

If Len(aAgrupSer) # 0

	nPosPecas := Ascan(aAgrupSer,{|x| x[3] == aAgrSerList[Len(aAgrSerList),2] })

EndIf

If Len(aAgrupSer) == 0 .Or. nPosPecas == 0

	Aadd(aAgrupSer,{ "" ,"" ,"" ,"" ,0 ,"" ,.t. ,0 ,"" ,.t. ,"","","" ,"",0})

	nPosPecas := Len(aAgrupSer)

EndIf

cAgruForm := ""
nAgruVal  := 0

If cTipAgru == "2"
	FG_VALPEC(cTipTem,"cAgruForm",VSJ->VSJ_GRUITE,VSJ->VSJ_CODITE,"nAgruVal",.f.)
EndIf

aAgrupSer[nPosPecas, 1] := cCodSer
aAgrupSer[nPosPecas, 2] := cTipAgru
aAgrupSer[nPosPecas, 3] := aAgrSerList[Len(aAgrSerList),2]
aAgrupSer[nPosPecas, 4] := aAgrSerList[Len(aAgrSerList),3]
aAgrupSer[nPosPecas, 5] := aAgrupSer[nPosPecas, 5]+aAgrSerList[Len(aAgrSerList),4]
aAgrupSer[nPosPecas, 6] := cAgruForm
If !aAgrupSer[nPosPecas,7]
	aAgrupSer[nPosPecas,15] := 1
EndIf
aAgrupSer[nPosPecas, 7] :=  .t.
aAgrupSer[nPosPecas, 8] := nAgruVal
aAgrupSer[nPosPecas, 9] := cCodPro
aAgrupSer[nPosPecas,10] := lJaReq
aAgrupSer[nPosPecas,11] := cCodPro
aAgrupSer[nPosPecas,12] := cLocal
aAgrupSer[nPosPecas,13] := cLocaliz
aAgrupSer[nPosPecas,14] := cTipTem

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_POEVER บAutor  ณFabio               บ Data ณ  07/07/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณColoca Flag p/ requisicao de pecas                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณOficina                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_POEVER(cCodSerV,lMarca,cOperacao)

Local nx := 0
Local nPos := 0
Default cOperacao := "O"

If cOperacao == "T"
	If aAgrSerList[oLbAgruSer:nAt,10] == 1
		MsgStop(STR0092,STR0066) // Pe็a ja seleccionada para Requisi็ใo. / Aten็ใo
		Return
	EndIf
EndIf

If cOperacao == "O"

	nx := Ascan(aAgrupSer,{|x| x[1] == cCodSerV } )
	Do While  nx#0 .And. nx <= Len(aAgrupSer) .And. aAgrupSer[nx,1] == cCodSerV
		nPos := Ascan(aAgrSerList,{|x| x[2] == aAgrupSer[nx,3] })
		If nPos > 0
			aAgrupSer[nx,7] := aAgrSerList[nPos,6]
		EndIf
		aAgrupSer[nx,10] := !lMarca
		nx++
	EndDo

Else

	If !aAgrSerList[oLbAgruSer:nAt,6]

		aAgrSerList[oLbAgruSer:nAt,6] :=  .t.

	Else

		DbSelectArea("SB2")
		If CalcEst(aAgrSerList[oLbAgruSer:nAt,7],aAgrSerList[oLbAgruSer:nAt,8],dDataBase+1)[1] < aAgrSerList[oLbAgruSer:nAt,4]

			Help(" ",1,"QTDREQPEC")

		Else

			aAgrSerList[oLbAgruSer:nAt,6] :=  .f.

		EndIf

	EndIf

EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_SUBORDEMบAutor ณMICROSIGA           บ Data ณ  12/23/99   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณImprime as Ferramentas que serao usadas no servico.         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FS_SUBORDEM()

Local nImp := 0 , nAgrupN := 0 , nix := 1 , i := 0 , nTotal := 0 , nLin   := 0 , nContMec := 0 , nLinTxt := 0
Local aString := {}
Local cSPF , nPos := 0 , nLBarra := 0, nCBarra := 0

Private aReturn  := { OemToAnsi(STR0002), 1,OemToAnsi(STR0003), 2, 2, 2,,1 } //"Requisitar"###"Alterar"
Private titulo,cabec1,cabec2,nLastKey:=0,wnrel,oPrinter,oFont
Private cAlias , cNomRel , cPerg , cTitulo , cDesc1 , cDesc2 , cDesc3 , lHabil := .f.
Private oPr
Private cTamanho  := "P"          // P/M/G
Private Limite    := 80           // 80/132/220
Private nCaracter := 15

cAlias := "VO4"
NomeRel:= "SUBORDEM"
cPerg  := nil
cTitulo:= STR0004 //"Requisicao de Servicos"
cDesc1 := STR0023 //"Sub Ordem"
cDesc2 := cDesc3 := ""
//aOrdem := {"Nosso Numero","Codigo do Item"}
lHabil := .f.

For nImp := 1 to Len(aColsSrv)

	If !aColsSrv[ nImp , Len(aColsSrv[nImp]) ] .And. (aColsSrv[nImp,FG_POSVAR("VO4_IMPSUB","aHeaderSrv")] == "1")
		Exit
	EndIf

	If nImp == Len(aColsSrv)
		Return
	EndIf

Next

NomeRel := SetPrint(cAlias,NomeRel,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,lHabil,,,cTamanho)

//NomeRel := GETMV("MV_SUBORDE")

If nlastkey == 27
	Return(Allwaystrue())
EndIf

SetDefault(aReturn,cAlias)

Set Printer to &NomeRel
Set Printer On
Set device to Printer

/*
cbTxt    := Space(10)
cbCont   := 0
cString  := "VO3"
Li       := 80
m_Pag    := 1

wnRel    := "OFIOM030"

cTitulo:= "Sub Ordem"
cabec1 := "OS.: "+M->VO2_NUMOSV+Space(1)+"Nro Req.:"+M->VO2_NOSNUM+Space(1)+"Func: "+M->VO2_FUNREQ+"-"+Subs(M->VO2_NOMREQ,1,22)+Space(1)+"Box: "+VO1->VO1_NUMBOX
cabec2 := "Cliente: "+M->VO2_PROVEI+"-"+Subs(M->VO2_NOMPRO,1,16)+Space(1)+"Chassi: "+M->VO2_CHASSI+Space(1)+"Frota:"+M->VO2_CODFRO
//cabec2 := "--- -- ---- --------------------------- ---------------------------- ----- ------- --------- -------------- -------------- ------"
nomeprog:="OFIOM030"
tamanho:="P"
nCaracter:=15
*/

nTotal := 0
nLin   := 0

//SetRegua( Len( aAgrupSer ) )

Asort(aAgrupSer,,,{|x,y| x[1]+x[2]+x[3] < y[1]+y[2]+y[3] } )

cCodSrv := aColsSrv[1,FG_POSVAR("VO4_CODSER","aHeaderSrv")]

For nAgrupN := 1 to 2

	For nix := 1 to Len(aColsSrv)

		If aColsSrv[ nix , Len(aColsSrv[nix]) ] .Or. (aColsSrv[nix,FG_POSVAR("VO4_IMPSUB","aHeaderSrv")] # "1")
			Loop
		EndIf

		i := Ascan(aAgrupSer,{|x| x[1] == aColsSrv[nix,FG_POSVAR("VO4_CODSER","aHeaderSrv")] })

		If nAgrupN == 1 .And. i # 0 .Or. nAgrupN == 2 .And. i == 0
			Loop
		EndIf

		If nLin > 66 .Or. i # 0
			nLin := 0
		Else
			If nLin > 33
				nLin := 0
			ElseIf nLin # 0
				nLin := 34
			EndIf
		EndIf

		DbSelectArea("VO4")
		DbSetOrder(1)
		DbSeek(xFilial("VO4")+M->VO2_NOSNUM+aColsSrv[nix,FG_POSVAR("VO4_TIPTEM","aHeaderSrv")]+aColsSrv[nix,FG_POSVAR("VO4_CODSER","aHeaderSrv") ])

		//       nLin := cabec(ctitulo,cabec1,cabec2,nomeprog,tamanho,nCaracter) + 1

		@ nLin++,0 PSAY Repl("_",80)
		@ nLin++,0 PSAY STR0023+": "+ALLTRIM(VO4->VO4_NOSNUM+VO4->VO4_SEQUEN)+Space(27)+STR0025+Dtoc(dDataBase)+" - "+left(Time(),5) //"Sub Ordem"###"Emissao: "
		@ nLin++,0 PSAY STR0026+M->VO2_NUMOSV+Space(1)+STR0027+M->VO2_NOSNUM+Space(1)+STR0028+Dtoc(VO1->VO1_DATABE)+STR0029+Transform(VO1->VO1_HORABE,"@R 99:99")+" "+Subs(M->VO2_NOMREQ,1,11)+" "+STR0030+VO1->VO1_NUMBOX //"OS.: "###"Nro Req.:"###"Aberta em "###" as "###"Box: "
		@ nLin++,0 PSAY Repl("_",80)
		@ nLin++,0 PSAY VV1->VV1_CODMAR+" "+left(Posicione("VV2",1,xFilial("VV2")+VV1->VV1_CODMAR+VV1->VV1_MODVEI,"VV2_DESMOD"),29)+" "+STR0033+Transform(VV1->VV1_PLAVEI,VV1->(X3PICTURE("VV1_PLAVEI")))+" "+Transform(VO1->VO1_KILOME,"@E 99,999,999,999")+STR0034+" "+STR0038+M->VO2_CODFRO //"Marca: "###"Modelo: "###"Placa: "###" Km" ### Frota
		If !Empty(VO1->VO1_CODMOT)
			@ nLin++,0 PSAY STR0035+Posicione("VOG",1,xFilial("VOG")+VO1->VO1_CODMOT ,"VOG_NOMMOT") //"Motorista: "
		EndIf
		@ nLin++,0 PSAY STR0036+M->VO2_PROVEI+"-"+M->VO2_LJPVEI+" "+left(M->VO2_NOMPRO,25)+Space(1)+STR0037+M->VO2_CHASSI //"Cliente: "###"Chassi: "###"Frota:"
		@ nLin++,0 PSAY Repl("_",80)

		If i == 0

			aString := {}

			DbSelectArea("VOC")
			DbSetOrder(2)
			DbSeek(xFilial("VOC")+VV1->VV1_CODMAR+aColsSrv[nix,FG_POSVAR("VO4_CODSER","aHeaderSrv")])

			For nContMec := 1 to 12

				If !Eof() .And. VOC->VOC_CODMAR == VV1->VV1_CODMAR .And. VOC->VOC_CODSER == aColsSrv[nix,FG_POSVAR("VO4_CODSER","aHeaderSrv")]

					Aadd(aString,{VOC->VOC_QTDEXE,VOC->VOC_CODPRO,Subs(Posicione("VAI",1,xFilial("VAI")+VOC->VOC_CODPRO,"VAI_NOMTEC"),1,09)  })

					DbSelectArea("VOC")
					DbSkip()

				Else

					Aadd(aString,{0,Space(6),Space(09) })

				EndIf

			Next

			Asort(aString,,,{|x,y| Str(x[1],6)+x[2] > Str(y[1],6)+y[2] })

			@ nLin++,0 PSAY Repl("-",5)+"[ "+STR0039+" ]"+Repl("-",15)+"[ "+STR0040+" ]"+Repl("-",13) //"Servico a Executar"###"Mecanicos Habilitados"
			@ nLin++,0 PSAY Space(30)+STR0041 //"Nr. Vezes Codigo Nome"
			@ nLin++,0 PSAY STR0042+".: "+aColsSrv[nix,FG_POSVAR("VO4_CODSER","aHeaderSrv")]+If(!Empty(aString[1,2]),Space(7)+Str(aString[1,1],6)+" "+aString[1,2]+" "+aString[1,3],"")+If(!Empty(aString[7,2]),Space(1)+Str(aString[7,1],6)+" "+aString[7,2]+" "+aString[7,3],"") //"Servico "
			@ nLin++,0 PSAY STR0019+": "+Subs(aColsSrv[nix,FG_POSVAR("VO4_DESSER","aHeaderSrv")],1,20)+If(!Empty(aString[2,2]),Space(2)+Str(aString[2,1],6)+" "+aString[2,2]+" "+aString[2,3],"")+If(!Empty(aString[8,2]),Space(1)+Str(aString[8,1],6)+" "+aString[8,2]+" "+aString[8,3],"") //"Descricao"
			@ nLin++,0 PSAY STR0043+".....: "+aColsSrv[nix,FG_POSVAR("VO4_TIPSER","aHeaderSrv")]+"-"+Subs(Posicione("VOK",1,xFilial("VOK")+aColsSrv[nix,FG_POSVAR("VO4_TIPSER","aHeaderSrv")],"VOK_DESSER"),1,17)+If(!Empty(aString[3,2]),Space(1)+Str(aString[3,1],6)+" "+aString[3,2]+" "+aString[3,3],"")+If(!Empty(aString[9,2]),Space(1)+Str(aString[9,1],6)+" "+aString[9,2]+" "+aString[9,3],"") //"Tipo"
			@ nLin++,0 PSAY STR0044+"....: "+substr(aColsSrv[nix,FG_POSVAR("VO4_DESSEC","aHeaderSrv")],1,20)+If(!Empty(aString[4,2]),Space(2)+Str(aString[4,1],6)+" "+aString[4,2]+" "+aString[4,3],"")+If(!Empty(aString[10,2]),Space(1)+Str(aString[10,1],6)+" "+aString[10,2]+" "+aString[10,3],"") //"Secao"
			@ nLin++,0 PSAY STR0045+"....: "+aColsSrv[nix,FG_POSVAR("VO4_GRUSER","aHeaderSrv")]+"-"+Subs(Posicione("VOS",1,xFilial("VOS")+VV1->VV1_CODMAR+aColsSrv[nix,FG_POSVAR("VO4_GRUSER","aHeaderSrv")],"VOS_DESGRU"),1,18)+If(!Empty(aString[5,2]),Space(1)+Str(aString[5,1],6)+" "+aString[5,2]+" "+aString[5,3],"")+If(!Empty(aString[11,2]),Space(1)+Str(aString[11,1],6)+" "+aString[11,2]+" "+aString[11,3],"") //"Grupo"
			@ nLin++,0 PSAY STR0046+": "+Transform(aColsSrv[nix,FG_POSVAR("VO4_TEMPAD","aHeaderSrv")],"@R 99:99")+If(!Empty(aString[6,2]),Space(17)+Str(aString[6,1],6)+" "+aString[6,2]+" "+aString[6,3],"")+If(!Empty(aString[12,2]),Space(1)+Str(aString[12,1],6)+" "+aString[12,2]+" "+aString[12,3],"") //"Tp Padrao"

		Else

			@ nLin++,0 PSAY STR0042+" "+STR0015+": "+aColsSrv[nix,FG_POSVAR("VO4_CODSER","aHeaderSrv")]+" "+STR0019+": "+aColsSrv[nix,FG_POSVAR("VO4_DESSER","aHeaderSrv")] //"Servico "###"Agrupado"###"Descricao"
			@ nLin++,0 PSAY STR0045+": "+aColsSrv[nix,FG_POSVAR("VO4_GRUSER","aHeaderSrv")]+"-"+Subs(Posicione("VOS",1,xFilial("VOS")+VV1->VV1_CODMAR+aColsSrv[nix,FG_POSVAR("VO4_GRUSER","aHeaderSrv")],"VOS_DESGRU"),1,15)+Space(2)+STR0044+": "+aColsSrv[nix,FG_POSVAR("VO4_DESSEC","aHeaderSrv")]+Space(10)+STR0046+": "+Transform(aColsSrv[nix,FG_POSVAR("VO4_TEMPAD","aHeaderSrv")],"@R 99:99") //"Grupo"###"Secao"###"Tp Padrao"

		EndIf

		If i # 0
			cSPF := "4"
		EndIf

		Do While i # 0 .And. i<= Len(aAgrupSer) .And. aAgrupSer[i,1] == aColsSrv[nix,FG_POSVAR("VO4_CODSER","aHeaderSrv")]

			If aAgrupSer[i,2] # cSPF

				If aAgrupSer[i,2] == "0"
					@ nLin++,0 PSAY STR0047+Repl("-",59) //"Ferramentas-Descricao"
				ElseIf aAgrupSer[i,2] == "1"
					@ nLin++,0 PSAY "-"+STR0048+"---"+STR0049+"-"+STR0050+Repl("-",27)+STR0046+Repl("-",09) //"AP"###"RP"###"Servico----------Descricao"###"Tp Padrao"
				Else
					@ nLin++,0 PSAY STR0014+Repl("-",29)+STR0019+Repl("-",27)+STR0020 //"Pecas"###"Descricao"###"Quantidade"
				EndIf

				cSPF := aAgrupSer[i,2]

			EndIf

			@ nLin++,0 PSAY If(cSPF == "1","( )  ( ) ","")+aAgrupSer[i,3]+" "+aAgrupSer[i,4]+If( cSPF == "2","  "+Transform(aAgrupSer[i,5],"@E 99,999,999,999"), If( cSPF == "1", If(Posicione("VOK",1,xFilial("VOK")+aColsSrv[nix,FG_POSVAR("VO4_TIPSER","aHeaderSrv")],"VOK_INCTEM")== "2", Space(9)+Transform(Posicione("VO6",2,xFilial("VO6")+FG_MARSRV(VV1->VV1_CODMAR,aAgrupSer[i,3])+aAgrupSer[i,3],"VO6_TEMCON"),"@R 99:99") , Space(9)+Transform(Posicione("VO6",2,xFilial("VO6")+FG_MARSRV(VV1->VV1_CODMAR,aAgrupSer[i,3])+aAgrupSer[i,3],"VO6_TEMFAB"),"@R 99:99") ) ," ")  )

			i++

			If nLin >= 66
				nLin := 1
			EndIf

		EndDo

		If i # 0

			nLin := nLin+2
			@ nLin++,0 PSAY STR0051+Repl("_",26)+STR0052+Repl("_",26) //"Executado por:"###"Chefe Oficina:"

		Else

			nLinTxt := 0
			nLin++

			@ nLin++,0 PSAY STR0053 //"Detalhamento da Descricao"

			OFM0300011_PosicionaVO6( aColsSrv[nix,FG_POSVAR("VO4_CODSER","aHeaderSrv")] )

			DbSelectArea("SYP")
			DbSeek(xFilial("SYP")+VO6->VO6_DESMEM )

			Do While !Eof() .And. SYP->YP_CHAVE == VO6->VO6_DESMEM .And. SYP->YP_FILIAL == xFilial("SYP")

				@ nLin++,0 PSAY Stuff(SYP->YP_TEXTO, If( (nPos:=At("\13\10",SYP->YP_TEXTO))<=0 ,80,nPos) ,6,Space(6))

				nLinTxt++

				DbSkip()

				If nLinTxt >= 14
					Exit
				EndIf

			EndDo

		EndIf

		If GetNewPar("MV_ICODBAR","S") == "S"

			nLBarra := 13.0
			nCBarra :=  3.5

			If SX6->(DbSeek(xFilial("SX6")+"MV_POSCBAR")) // "L:=13,0C:=03,5"

				nLBarra := Val( Substr(GetMv("MV_POSCBAR"), At("L:=",GetMv("MV_POSCBAR"))+3 ,4) )
				nCBarra := Val( Substr(GetMv("MV_POSCBAR"), At("C:=",GetMv("MV_POSCBAR"))+3 ,4) )
				if nLBarra == 0
					nLBarra := Val( Substr(GetMv("MV_POSCBAR"), At("l:=",GetMv("MV_POSCBAR"))+3 ,4) )
				Endif
				if nLBarra == 0
					nLBarra := 13.0
				Endif
			EndIf

			If nLin > 33
				nLBarra := (nLBarra*2)
			endif

			oPr := ReturnPrtObj()
			cCode := ALLTRIM(VO4->VO4_NOSNUM+VO4->VO4_SEQUEN)
			//		  MSBAR3("CODE128",nLBarra,0.5,Alltrim(cCode),oPr,Nil,Nil,Nil,nil ,1.5 ,Nil,Nil,Nil)

			MSBAR3("CODE128",nLBarra,nCBarra,Alltrim(cCode),oPr,Nil,Nil,Nil,0.045,1.5,Nil,Nil,Nil)
			//	      MSBAR3("CODE128", nLBarra , nCBarra , ALLTRIM(VO4->VO4_NOSNUM+VO4->VO4_SEQUEN) ,oPr,NIL,NIL,NIL,NIL,NIL, NIL,NIL, "A" )

		EndIf

	Next
Next

Set Printer to
Set device to Screen

MS_FLUSH()

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_SERINA บAutor  ณFabio               บ Data ณ  12/28/99   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVerifica se o servico esta ativo ou nao.                    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FS_SERINA(cCodMar_,cCodSer_,cGruser_,cDesSer_,cCpoCodSer, cModVei_)
Local lRet := .f.
Local cAuxCodSer := ""
Private cCodMar:=cCodMar_,cCodSer:=cCodSer_,cGruser:=cGruser_
Private cAliasVO6  := "SQLVO6"
Private cAliasVO6A := "SQLVO6A"


Default cGruSer_ := M->VO4_GRUSER
Default cDesSer_ := "M->VO4_DESSER"
Default cCpoCodSer := "M->VO4_CODSER"
Default cModVei_ := VV1->VV1_MODVEI

cGruser:=cGruser_

If cMVMIL0006 == "JD"
	If !Empty(cGruser)
		cAuxCodSer := OM030CPLCOD(cCodMar,cModVei_,cGruSer,cCodSer)
		If !Empty(cAuxCodSer)
			cCodSer := cAuxCodSer //Efetua o levantamento do servi็o de acordo com a base
			&(cCpoCodSer) := cCodSer
		EndIf
	EndIf
EndIf

cQuery := "SELECT VO6.R_E_C_N_O_ RECVO6 , VO6.VO6_CODMAR"
cQuery += " FROM "+ RetSQLName("VO6") + " VO6"
cQuery += " WHERE VO6.VO6_FILIAL = '" + xFilial("VO6") + "'"
cQuery +=   " AND VO6.VO6_GRUSER = '" + cGruSer + "'"
cQuery +=   " AND VO6.VO6_CODSER = '" + cCodSer + "'"
cQuery +=   " AND VO6.D_E_L_E_T_ = ' '"

dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasVO6, .T., .T. )

if !( cAliasVO6 )->( Eof())
	Do While !( cAliasVO6 )->( Eof() )
		cRecNo := ( cAliasVO6 )->( RECVO6 )
		if cCodMar_ == ( cAliasVO6 )->VO6_CODMAR .or. Empty(( cAliasVO6 )->VO6_CODMAR)
			dbSelectArea("VO6")
			dbGoto(cRecNo)
			lRet := .t.
			Exit
		Endif
		( cAliasVO6 )->(DbSkip())

    Enddo

Else

	cQuery := "SELECT VO6.R_E_C_N_O_ RECVO6 "
	cQuery += " FROM " + RetSQLName("VO6") + " VO6"
	cQuery += " WHERE VO6.VO6_FILIAL = '" + xFilial("VO6") + "'"
	cQuery +=   " AND VO6.VO6_CODSER = '" + cCodSer + "'"
	cQuery +=   " AND VO6.D_E_L_E_T_ = ' '"

	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasVO6A, .T., .T. )
	if !( cAliasVO6 )->( Eof())
		Do While !( cAliasVO6A )->( Eof() )
			cRecNo := ( cAliasVO6A )->( RECVO6 )
			If ( !Empty(cGruSer) )
				lRet := .f.
			Else
				dbSelectArea("VO6")
				dbGoto(cRecNo)
				if cCodMar_ == VO6->VO6_CODMAR .or. Empty(VO6->VO6_CODMAR)
					lRet := .t.
					Exit
				Endif
			EndIf
			dbSelectArea(cAliasVO6A)
			( cAliasVO6A )->(DbSkip())

		Enddo
	Else
		lRet := .f.
	Endif
    ( cAliasVO6A )->( dbCloseArea() )
Endif
( cAliasVO6 )->( dbCloseArea() )

dbSelectArea("VO6")
if lRet
	If VO6->VO6_SERATI == "0"
		Help(" ",1,"SERINATIVO")
		lRet := .f.
	Else

		&(cDesSer_) := VO6->VO6_DESSER

	Endif
Endif

Return(lRet)

/*/
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณ OM030A     ณ Autor ณ Fabio                 ณ Data ณ 29/09/99 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Lista Servico Requisitadas na OS e Altera os Itens           ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ Exclusivo                                                    ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OM030A(cAlias,nReg,nOpc)

Local nCont    := 0
//Local lMostra  := .T.
Local cTitulo  := STR0004 + " - " + STR0003
Local o030Scroll
Local cCpoInc := ""//, aInconv

Local aObjects := {}, aSizeAut := {}, aPosObj := {}//, aPosGet := {}
Local nPosVO2Soft := 0
Local nPos, nPosMov

Local aPesqPeca := {}
Local aPesqSrvc := {}

Local cDescTT, cDescTipSer

Private cDescDepInt, cDescDepGar

Private cDesc1 := ""
Private cDesc2 := ""
Private oOk     := LoadBitmap( GetResources(), "LBOK" )
Private oNo     := LoadBitmap( GetResources(), "LBNO" )
Private aServicos  := {},aPecas := {},aTitulo := {}                     //Nome do Vetor em Uso
Private oLbItens,lBxFilho := .f. , oTipTem
Private oOrdens,cOrdens,aOrdens:={OemToAnsi(STR0055),OemToAnsi(STR0056)} //"Tipo de Tempo + Cliente + Codigo do Servico"###"Cliente + Tipo de Tempo + Codigo do Servico"
Private lMarcar := .f.

if iif(lOm030Ast,ExecBlock("OM030AST",.F.,.F.,{VO1->VO1_STATUS}),VO1->VO1_STATUS) # "A"
	Help("  ",1,"OSNABERTA")
	DbSelectArea("VO1")
	DbSetOrder(1)
	Return
EndIf

// Inconveniente
if lInconveniente
	cCpoInc := "/VO4_GRUINC/VO4_CODINC/VO4_DESINC/VO4_SEQINC"
EndIf

DbSelectArea("VV1")
DbSetOrder(1)
DbSeek(xFilial("VV1")+VO1->VO1_CHAINT)

If FindFunction("FM_VEIGAR")
	FM_VEIGAR() // Verifica se o Veiculo esta em garantia - 04/05/2009 - Andre Luis Almeida
EndIf

DbSelectArea("VE1")
DbSetOrder(1)
DbSeek(xFilial("VE1")+VV1->VV1_CODMAR)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณConfigura Enchoiceณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("VO4")

While !Eof().and.(x3_arquivo=="VO4")

	If X3USO(x3_usado) .and. x3_nivel > 0 .And. ( SX3->X3_PROPRI=="U" .or. Alltrim(x3_campo) $ "VO4_TIPTEM/VO4_FATPAR/VO4_LOJA/VO4_NOMCLI/VO4_TIPSER/VO4_FORMUL/VO4_DEPINT/VO4_DEPGAR/VO4_NUMRRC"+cCpoInc)
		&("M->"+x3_campo) := CriaVar(x3_campo)
	Endif

	DbSkip()

EndDo

DbSelectArea("VO2")
DbSetOrder(1)
If !DbSeek(xFilial("VO2")+VO1->VO1_NUMOSV+"S")
	Help(" ",1,"ITENSOSV")
	Return
EndIf
If !Softlock("VO2")
	return .f.
EndIf
nPosVO2Soft := VO2->(Recno())

DbSeek(xFilial("VO2")+VO1->VO1_NUMOSV)

aPesqPeca := FMX_CALPEC(VO1->VO1_NUMOSV,,,,.t.,.f.,.f.,.t.,.f.,.f.,.t.,,,.f.,,.t.,)
For nPos := 1 to Len(aPesqPeca)
	For nPosMov := 1 to Len(aPesqPeca[nPos,PECA_MOV])
		Aadd(aPecas,{;
			.f.,;
			aPesqPeca[ nPos , PECA_MOV , nPosMov , PECA_MOV_REQDEV ] ,; // VO2->VO2_DEVOLU,;	// 02
			aPesqPeca[ nPos , PECA_TIPTEM ] ,; // VO3->VO3_TIPTEM,;	// 03
			aPesqPeca[ nPos , PECA_CLIENTE ] ,; // VO3->VO3_FATPAR,;	// 04
			aPesqPeca[ nPos , PECA_LOJA ] ,; // VO3->VO3_LOJA,;		// 05
			aPesqPeca[ nPos , PECA_GRUITE ] ,; // VO3->VO3_GRUITE,;	// 06
			aPesqPeca[ nPos , PECA_CODITE ] ,; // VO3->VO3_CODITE,;	// 07
			aPesqPeca[ nPos , PECA_VALBRU ] ,; // (VO3->VO3_QTDREQ*VO3->VO3_VALPEC),;	// 08
			aPesqPeca[ nPos , PECA_MOV, nPosMov , PECA_MOV_NOSNUM ] ,; // VO3->VO3_NOSNUM,;	// 09
			aPesqPeca[ nPos , PECA_INCONV_GRUPO  ] ,; // " ",; 				// 10 - Grupo de Inconveniente
			aPesqPeca[ nPos , PECA_INCONV_CODIGO ] ,; // " ",;				// 11 - Codigo de Inconveniente
			aPesqPeca[ nPos , PECA_INCONV_SEQ    ] ,; // " ",;				// 12 - Seq de Inconveniente
			aPesqPeca[ nPos , PECA_INCONV_DESCR  ] ,; // " ";				// 13 - Descricao do Inconveniente
				})
	Next nPosMov
Next nPos
aPesqSrvc := FMX_CALSER(VO1->VO1_NUMOSV,,,,.t.,.f.,.t.,.f.,.f.,.f.,,)
For nPos := 1 to Len(aPesqSrvc)
	Aadd(aServicos,{;
		.F.,;
		aPesqSrvc[ nPos , SRVC_TIPTEM ] ,; // VO4->VO4_TIPTEM,;	// 02
		aPesqSrvc[ nPos , SRVC_CLIENTE ] ,; // VO4->VO4_FATPAR,;	// 03
		aPesqSrvc[ nPos , SRVC_LOJA ] ,; // VO4->VO4_LOJA,;		// 04
		aPesqSrvc[ nPos , SRVC_CODSER ] ,; // VO4->VO4_CODSER,;	// 05
		aPesqSrvc[ nPos , SRVC_DESCRICAO ] ,; // Posicione("VO6",2,xFilial("VO6")+FG_MARSRV(Posicione("VV1",1,xFilial("VV1")+VO1->VO1_CHAINT,"VV1_CODMAR"),VO4->VO4_CODSER)+VO4->VO4_CODSER,"VO6_DESSER"),;	// 06
		aPesqSrvc[ nPos , SRVC_DEPINT ] ,; // VO4->VO4_DEPINT,;	// 07
		aPesqSrvc[ nPos , SRVC_DEPGAR ] ,; // VO4->VO4_DEPGAR,;	// 08
		aPesqSrvc[ nPos , SRVC_VALBRU ] ,; // ((VO4->VO4_TEMPAD*VO4->VO4_VALHOR)/100),;	// 09
		aPesqSrvc[ nPos , SRVC_APONT , 1 , SRVC_APONT_NOSNUM ] ,; // VO4->VO4_NOSNUM,;	// 10
		aPesqSrvc[ nPos , SRVC_INCONV_GRUPO  ] ,; // " ",;				// 11 - Grupo de inconveniente
		aPesqSrvc[ nPos , SRVC_INCONV_CODIGO ] ,; // " ",;				// 12 - Codigo de Inconveniente
		aPesqSrvc[ nPos , SRVC_TIPSER ] ,; // VO4->VO4_TIPSER,;	// 13
		aPesqSrvc[ nPos , SRVC_INCONV_SEQ   ] ,; // " ",;				// 14 - Seq de inconveniente
		aPesqSrvc[ nPos , SRVC_INCONV_DESCR ] ,; // " ";				// 15 - Descricao de Inconveniente
		aClone( aPesqSrvc[ nPos , SRVC_APONT ] ) ,; // 16 - Apontamentos
		aPesqSrvc[ nPos , SRVC_GRUSER ] ; // " ";				// 17 - Grupo de Servico
				})

Next nPos

If Len(aServicos) == 0
	Help(" ",1,"ITENSOSV")
	Return
EndIf

// VO4_TIPTEM + VO4_FATPAR + VO4_LOJA + VO4_CODSER + VO4_DEPINT + VO4_TIPSER
Asort(aServicos,1,,{|x,y|x[2]+x[3]+x[4]+x[5]+x[7]+x[8]+x[13] < y[2]+y[3]+y[4]+y[5]+y[7]+y[8]+y[13] })

If Len(aPecas)# 0
	// VO3_GRUITE + VO3_CODITE + VO3_NOSNUM + VO3_TIPTEM
	Asort(aPecas   ,1,,{|x,y|x[6]+x[7]+x[9]+x[3] < y[6]+y[7]+y[9]+y[3] })
EndIf

VOI->( DbSetOrder(1) )

M->VO4_TIPTEM := Space(TamSX3("VO4_TIPTEM")[1])
M->VO4_FATPAR := Space(TamSX3("VO4_FATPAR")[1])
M->VO4_LOJA   := Space(TamSX3("VO4_LOJA")[1])
M->VO4_NOMCLI := Space(TamSX3("VO4_NOMCLI")[1])
M->VO4_DEPINT := Space(TamSX3("VO4_DEPINT")[1])
M->VO4_TIPSER := Space(TamSX3("VO4_TIPSER")[1])
M->VOK_DESSER := Space(TamSX3("VOK_DESSER")[1])
cDescTT := Space(TamSX3("VOI_DESTTE")[1])

If !lOM030Auto

	aSizeAut := MsAdvSize(.t.)
	AADD( aObjects, { 0 , 80 , .T. , .F. } )
	AADD( aObjects, { 0 , 100 , .T. , .T. } )
	aInfo := { aSizeAut[1] , aSizeAut[2] , aSizeAut[3] , aSizeAut[4], 0 , 2 }
	aPosObj := MsObjSize( aInfo, aObjects )

	DEFINE MSDIALOG oDlgServico TITLE cTitulo FROM aSizeAut[7],00 TO aSizeAut[6], aSizeAut[5] OF oMainWnd PIXEL

	o030Scroll := TScrollBox():New( oDlgServico, aPosObj[1,1] , aPosObj[1,2] , aPosObj[1,3] - aPosObj[1,1], aPosObj[1,4] - aPosObj[1,2], .t. , , .t. )

	// Tipo Tempo
	@ 05,002 SAY STR0057 OF o030Scroll PIXEL COLOR CLR_HBLUE
	@ 04,040 MSGET oTipTem VAR M->VO4_TIPTEM PICTURE "@!" F3 "VOI" SIZE 10,1 VALID ( OM030VALTT(@cDescTT) .And. Iif(lVOITPATEN, FGX_VOITPATEN(VO1->VO1_TPATEN, M->VO4_TIPTEM, .t.), .t.) ) OF o030Scroll PIXEL HASBUTTON

	// Descricao de Tipo de Tempo
	@ 05,160 SAY RetTitle("VOI_DESTTE") OF o030Scroll PIXEL
	@ 04,200 MSGET oDescTT VAR cDescTT PICTURE "@!S15" SIZE 90,1 OF o030Scroll PIXEL when .f.

	// Codigo do Cliente
	@ 16,002 SAY RetTitle("VO4_FATPAR") OF o030Scroll PIXEL COLOR CLR_HBLUE
	@ 15,040 MSGET M->VO4_FATPAR PICTURE "@!" F3 "VSA" VALID (FG_SEEK("SA1","M->VO4_FATPAR",1,.f.,"VO4_NOMCLI","A1_NOME") .And. &(GetSx3Cache("VO4_FATPAR","X3_VLDUSER"))) SIZE 40,1 OF o030Scroll PIXEL COLOR CLR_BLACK WHEN If(Posicione("VOI",1,xFilial("VOI")+M->VO4_TIPTEM,"VOI_ALTCLI") == "0",.f.,.t.) HASBUTTON

	// Loja
	@ 16,160 SAY RetTitle("VO4_LOJA") OF o030Scroll PIXEL COLOR CLR_HBLUE
	@ 15,200 MSGET M->VO4_LOJA PICTURE "@!" VALID FG_SEEK("SA1","M->VO4_FATPAR+M->VO4_LOJA",1,.f.,"VO4_NOMCLI","A1_NOME") SIZE 10,1 OF o030Scroll PIXEL when If(Posicione("VOI",1,xFilial("VOI")+M->VO4_TIPTEM,"VOI_ALTCLI") == "0",.f.,.t.)

	// Nome do cliente
	@ 27,002 SAY RetTitle("VO4_NOMCLI") OF o030Scroll PIXEL
	@ 26,040 MSGET M->VO4_NOMCLI SIZE 250,1 OF o030Scroll PIXEL When .f.

	// Departamento Interno
	@ 38,002 SAY RetTitle("VO4_DEPINT") OF o030Scroll PIXEL
	@ 37,040 MSGET M->VO4_DEPINT PICTURE "@!" F3 "VD" SIZE 10,1 VALID OM030VALDEP("VD", M->VO4_DEPINT, oDescDepInt, @cDescDepInt) OF o030Scroll PIXEL COLOR CLR_BLACK WHEN VOI->VOI_DEPINT == "1" HASBUTTON

	// Descricao Departamento Interno
	@ 38,160 SAY STR0019 OF o030Scroll PIXEL
	@ 37,200 MSGET oDescDepInt VAR cDescDepInt PICTURE SIZE 90,1 OF o030Scroll PIXEL When .f.

	// Departamento de Garantia
	@ 49,002 SAY RetTitle("VO4_DEPGAR") OF o030Scroll PIXEL
	@ 48,040 MSGET M->VO4_DEPGAR PICTURE "@!" F3 "VF" VALID OM030VALDEP("VF", M->VO4_DEPGAR, oDescDepGar, @cDescDepGar) SIZE 10,1 OF o030Scroll PIXEL When VOI->VOI_DEPGAR == "1" HASBUTTON

	// Descricao do Departamento de Garantia
	@ 49,160 SAY STR0019 OF o030Scroll PIXEL
	@ 48,200 MSGET oDescDepGar VAR cDescDepGar SIZE 90,1 OF o030Scroll PIXEL When .f.

	// Tipo de Servico
	@ 60,002 SAY RetTitle("VO4_TIPSER") OF o030Scroll PIXEL
	@ 59,040 MSGET M->VO4_TIPSER PICTURE "@!" F3 "VOK" SIZE 15,1 VALID OM030VALTIPSER(@cDescTipSer) OF o030Scroll PIXEL HASBUTTON

	// Descricao do Tipo de Servico
	@ 60,160 SAY RetTitle("VOK_DESSER") OF o030Scroll PIXEL
	@ 59,200 MSGET cDescTipSer OF o030Scroll SIZE 90,1 PIXEL When .f.

	TGroup():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],STR0013,oDlgServico,,,.t.)

	oLbItens := TWBrowse():New(aPosObj[2,1] + 10 , aPosObj[2,2] + 4,aPosObj[2,4] - aPosObj[2,2] - 8 , aPosObj[2,3] - aPosObj[2,1] - 15,,,,oDlgServico,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
	oLbItens:addColumn(TCColumn():New( " " , { || IIf(oLbItens:aArray[oLbItens:nAt,01],oOk,oNo) } ,,,,"LEFT" ,05,.T.,.F.,,,,.F.,) )
	If lInconveniente
		oLbItens:addColumn(TCColumn():New( iif( lAltInconv, OX001066K_AlteraDescricaoInconveniente("VO4_GRUINC"), retTitle('VO4_GRUINC') ) , { || oLbItens:aArray [ oLbItens:nAt , 11 ] } ,,,,"LEFT" ,30,.F.,.F.,,,,.F.,) ) // Grupo do Inconveniente
		oLbItens:addColumn(TCColumn():New( iif( lAltInconv, OX001066K_AlteraDescricaoInconveniente("VO4_CODINC"), retTitle('VO4_CODINC') ) , { || oLbItens:aArray [ oLbItens:nAt , 12 ] } ,,,,"LEFT" ,40,.F.,.F.,,,,.F.,) ) // Codigo do Inconveniente
		oLbItens:addColumn(TCColumn():New( iif( lAltInconv, OX001066K_AlteraDescricaoInconveniente("VO4_SEQINC"), retTitle('VO4_SEQINC') ) , { || oLbItens:aArray [ oLbItens:nAt , 14 ] } ,,,,"LEFT" ,20,.F.,.F.,,,,.F.,) ) // Seq do Inconveniente
		oLbItens:addColumn(TCColumn():New( iif( lAltInconv, OX001066K_AlteraDescricaoInconveniente("VO4_DESINC"), retTitle('VO4_DESINC') ) , { || oLbItens:aArray [ oLbItens:nAt , 15 ] } ,,,,"LEFT" ,70,.F.,.F.,,,,.F.,) ) // Descricao do Inconveniente
	EndIf
	oLbItens:addColumn(TCColumn():New( STR0063                , { || oLbItens:aArray [ oLbItens:nAt , 02 ] } ,,,,"LEFT" ,30,.F.,.F.,,,,.F.,) ) // "Tempo"
	oLbItens:addColumn(TCColumn():New( STR0058                , { || oLbItens:aArray [ oLbItens:nAt , 03 ] } ,,,,"LEFT" ,35,.F.,.F.,,,,.F.,) ) // "Cod Cliente"
	oLbItens:addColumn(TCColumn():New( STR0059                , { || oLbItens:aArray [ oLbItens:nAt , 04 ] } ,,,,"LEFT" ,15,.F.,.F.,,,,.F.,) ) // "Loja"
	oLbItens:addColumn(TCColumn():New( STR0042                , { || oLbItens:aArray [ oLbItens:nAt , 05 ] } ,,,,"LEFT" ,40,.F.,.F.,,,,.F.,) ) // "Servico "
	oLbItens:addColumn(TCColumn():New( STR0019                , { || oLbItens:aArray [ oLbItens:nAt , 06 ] } ,,,,"LEFT" ,40,.F.,.F.,,,,.F.,) ) // "Descricao"
	oLbItens:addColumn(TCColumn():New( STR0060                , { || oLbItens:aArray [ oLbItens:nAt , 07 ] } ,,,,"LEFT" ,15,.F.,.F.,,,,.F.,) ) // "Dep Interno"
	oLbItens:addColumn(TCColumn():New( STR0061                , { || oLbItens:aArray [ oLbItens:nAt , 08 ] } ,,,,"LEFT" ,15,.F.,.F.,,,,.F.,) ) // "Dep Garantia"
	oLbItens:addColumn(TCColumn():New( STR0071                , { || oLbItens:aArray [ oLbItens:nAt , 13 ] } ,,,,"LEFT" ,30,.F.,.F.,,,,.F.,) ) // "Tipo Servico"
	oLbItens:nAt := 1
	oLbItens:SetArray(aServicos)
	oLbItens:bHeaderClick := { |oObj,nCol| IIf( nCol==1 , ( lMarcar := !lMarcar , FS_SELECIONA(lMarcar) , oLbItens:Refresh() ) , .t. ) , }
	oLbItens:bLDblClick := { || IIf( aServicos[oLbItens:nAt,1],;
												aServicos[oLbItens:nAt,1] := .F. ,;
												aServicos[oLbItens:nAt,1] := ( FS_VALTTIPSER(M->VO4_TIPSER,aServicos[oLbItens:nAt,13]) .and. FS_TPLIBFEC(VO1->VO1_NUMOSV,aServicos[oLbItens:nAt,2])) ) }
	oLbItens:Refresh()

	ACTIVATE MSDIALOG oDlgServico ON INIT EnchoiceBar(oDlgServico,{|| if( OM030ATUDOK(),(nOpca := 1,FS_ALTSRV()),NIL)},{|| nOpca := 0,(oDlgServico:End())})

Else

	cDesc := ""

	nPos := aScan( aAutoCab , { |x| x[1] == "TIPTEM" } )
	M->VO4_TIPTEM := aAutoCab[ nPos , 2 ]
	If !OM030VALTT(@cDesc,M->VO4_TIPTEM)
		lMsErroAuto := .t.
		Return .f.
	EndIf

	// Tipo de tempo permite alteracao do faturar para ...
	If VOI->VOI_ALTCLI == "1"
		nPos := aScan( aAutoCab , { |x| x[1] == "FATPAR" } )
		If nPos <> 0
			M->VO4_FATPAR := aAutoCab[ nPos , 2 ]

			nPos := aScan( aAutoCab , { |x| x[1] == "LOJA" } )
			M->VO4_LOJA  := aAutoCab[ nPos , 2 ]

			SA1->(dbSetOrder(1))
			If !SA1->(dbSeek( xFilial("SA1") + M->VO4_FATPAR + M->VO4_LOJA ))
				Help(" ",1,"REGNOIS",,RetTitle("VO4_FATPAR") + ": " + M->VO4_FATPAR + "-" + M->VO4_LOJA ,4,1)
				lMsErroAuto := .t.
				Return .f.
			EndIf
		EndIf
	EndIf
	//

	// Departamento Interno
	If VOI->VOI_DEPINT == "1"
		nPos := aScan( aAutoCab , { |x| x[1] == "DEPINT" } )
		If nPos > 0
			M->VO4_DEPINT := aAutoCab[ nPos , 2 ]
			If !OM030VALDEP("VD", M->VO4_DEPINT, , @cDesc)
				Help(" ",1,"REGNOIS",,RetTitle("VO4_DEPINT") + ": "+ M->VO4_DEPINT ,4,1)
				lMsErroAuto := .t.
				Return .f.
			EndIf
		EndIf
	EndIf
	//

	// Departamento de Garantia
	If VOI->VOI_DEPGAR == "1"
		nPos := aScan( aAutoCab , { |x| x[1] == "DEPGAR" } )
		If nPos > 0
			M->VO4_DEPGAR := aAutoCab[ nPos , 2 ]
			If !OM030VALDEP("VF", M->VO4_DEPGAR, oDescDepGar, @cDesc)
				Help(" ",1,"REGNOIS",,RetTitle("VO4_DEPGAR") + ": "+ M->VO4_DEPGAR ,4,1)
				lMsErroAuto := .t.
				Return .f.
			EndIf
		EndIf
	EndIf
	//

	// Tipo de Servico
	nPos := aScan( aAutoCab , { |x| x[1] == "TIPSER" } )
	If nPos > 0
		M->VO4_TIPSER := aAutoCab[ nPos , 2 ]
		If !OM030VALTIPSER(@cDesc)
			lMsErroAuto := .t.
			Return .f.
		EndIf
	EndIf
	//

	// Marca os servicos para alteracao ...
	For nCont := 1 to Len(aAutoItens)

		nPos := aScan( aAutoItens[nCont] , { |x| x[1] == "VO4_TIPTEM" } )
		cAuxTipTem := aAutoItens[nCont,nPos,2]

		nPos := aScan( aAutoItens[nCont] , { |x| x[1] == "VO4_CODSER" } )
		cAuxCodSer := aAutoItens[nCont,nPos,2]

		nPos := aScan( aServicos , { |x| x[2] == cAuxTipTem .and. x[5] == cAuxCodSer } )
		If nPos == 0
			Help(" ",1,"OM030ERR04",,STR0179 + CRLF + CRLF + RetTitle("VO4_TIPTEM") + ": [" + cAuxTipTem +"]" + CRLF + RetTitle("VO4_CODSER") + ": [" + cAuxCodSer + "]",4,1) // "Servi็o nใo encontrado entre os servi็os requisitados."
			lMsErroAuto := .t.
			Return .f.
		Else
			If !FS_VALTTIPSER(M->VO4_TIPSER,aServicos[nPos,13])
				lMsErroAuto := .t.
				Return .f.
			EndIf
			If !FS_TPLIBFEC(VO1->VO1_NUMOSV,aServicos[nPos,2])
				lMsErroAuto := .t.
				Return .f.
			EndIf
			aServicos[nPos,1] := .t.
		EndIf
	Next nCont

	//
	If !OM030ATUDOK()
		lMsErroAuto := .t.
		Return .f.
	EndIf
	//

	// Altera Servico
	FS_ALTSRV()
	//

EndIf

If nPosVO2Soft <> 0
	VO2->(dbGoTo(nPosVO2Soft))
	VO2->(MSUnlock())
EndIf

DbSelectArea("VO1")
dbSetOrder(1)

Return










/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao ณ OM030VALDEP    ณ Autor ณ Rubens Takahashi   ณ Data ณ 09/02/10 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Validacao do Dep. Interno/Garantia da Alteracao da         ณฑฑ
ฑฑณ          ณ Requisicao                                                 ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function OM030VALDEP(cTpReg, cCodigo, oObjDesc, cDesc)
Local lRetorno := .f.

lRetorno := SX5->(DbSeek(xFilial("SX5")+cTpReg+cCodigo))

if lRetorno
	cDesc := &("SX5->"+IIf(FindFunction("FGX_CPOSX5"),FGX_CPOSX5(),"X5_DESCRI"))
else
	cDesc := ""
endif
If !lOM030Auto
	oObjDesc:Refresh()
EndIf

//if !FS_030INTGAR(VO1->VO1_NUMOSV,M->VO4_TIPTEM)
//	Return .f.
//endif

Return lRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao ณ OM030VALTT    ณ Autor ณ Rubens Takahashi    ณ Data ณ 09/02/10 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Validacao do Tipo de Tempo da Alteracao da Requisicao      ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function OM030VALTT(cAuxDescTT,cTipTem)

Local oOficina := DMS_Oficina():New()

Default cTipTem := M->VO4_TIPTEM

M->VO4_DEPINT := CriaVar("VO4_DEPINT")
M->VO4_DEPGAR := CriaVar("VO4_DEPGAR")
cDescDepInt := ""
cDescDepGar := ""

cAuxDescTT := Space(TamSX3("VOI_DESTTE")[1])
If oOficina:TipoTempoBloqueado(M->VO4_TIPTEM,.t.) // Valida se Tipo de Tempo esta BLOQUEADO
	return .f.
EndIf
cAuxDescTT :=VOI->VOI_DESTTE

if !FG_TIPTPFAT(cTipTem,"M->VO4_FATPAR","M->VO4_LOJA","M->VO4_NOMCLI",VO1->VO1_CODMAR,"S",,.f.,,,.f.)
	Return .f.
endif

if !FS_VALTPABE(VO1->VO1_CHASSI,M->VO4_TIPTEM,VO1->VO1_NUMOSV)
	Return .f.
endif

if !FS_ALTTPREQ()
	Return .f.
endif

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao ณOM030VALTIPSER   ณ Autor ณ Rubens Takahashi  ณ Data ณ 09/02/10 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Validacao do Tipo de Servico da Alteracao da Requisicao    ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function OM030VALTIPSER(cDesc)

if Empty(M->VO4_TIPSER)
	cDesc := ""
	Return .t.
endif

if VOK->(DbSeek(xFilial("VOK")+M->VO4_TIPSER))
	cDesc := VOK->VOK_DESSER
else
	cDesc := ""
	return .f.
endif

if !FS_SERTEM(,,,.f.,.t.)
	return .f.
endif

/*if !FS_VALTTIPSER(M->VO4_TIPSER,aServicos[oLbItens:nAt,13])
	return .f.
endif */

Return .t.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao ณ OM030ATUDOK   ณ Autor ณ Rubens Takahashi   ณ Data ณ 09/02/10  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Valida se pode haver a alteracao dos servicos              ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function OM030ATUDOK()
Local nCntFor
Local nApont
Local oOficina := DMS_Oficina():New()

If oOficina:TipoTempoBloqueado(M->VO4_TIPTEM,.t.) // Valida se Tipo de Tempo esta BLOQUEADO
	return .f.
EndIf

// Tipo de Tempo exige informacao de departamento interno
if VOI->VOI_DEPINT == "1" .AND. Empty(M->VO4_DEPINT)
	Help( NIL, NIL, "OM030ERR02", , STR0141 , 1, 0 )
	return .f.
endif

// Tipo de Tempo exige informacao de departamento de garantia
if VOI->VOI_DEPGAR == "1" .AND. Empty(M->VO4_DEPGAR)
	Help( NIL, NIL, "OM030ERR03", , STR0140 , 1, 0 )
	return .f.
endif

// Verifica se a situacao do TT permite requisicao
//If lCANUSETT .and. !FMX_CANUSETT( "4" , VO1->VO1_NUMOSV , M->VO4_TIPTEM )
//	Return .f.
//EndIf
//

If !FMX_TTVLDCLIENTE( VO1->VO1_NUMOSV, M->VO4_TIPTEM , M->VO4_FATPAR , M->VO4_LOJA )
	Return .f.
EndIf

For nCntFor := 1 to Len(aServicos)
	if aServicos[nCntFor,1]
		if !FS_VALTTIPSER(M->VO4_TIPSER,aServicos[nCntFor,13])
			return .f.
		endif

		For nApont := 1 to Len(aServicos[ nCntFor , 16 ])
			// Verifica se a situacao do TT permite requisicao
			If !FMX_CANUSETT( "4" , VO1->VO1_NUMOSV , aServicos[nCntFor,02] ,,,,, aServicos[nCntFor , 16 , nApont , SRVC_APONT_RECVO4] )
				Return .f.
			EndIf
			//
		Next nApont
		If !OM030GRUSRV( aServicos[nCntFor,17] ,;
						 M->VO4_TIPTEM,;
						 VV1->VV1_CODMAR,;
						 .t.)
			Return .f.
		EndIF
	endif
Next nCntFor

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_ALTSRV บAutor  ณFabio               บ Data ณ  07/07/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAltera Servico                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FS_ALTSRV()

Local i := 0 , iP := 0 , nValor := 0 //, nVlHrTab := 0
Local lLimCre := .T. , lRet := .t. //, aItensNew:={}

Local lAltCli := .f.

Local lConsidera := .t.

Local lAltDpI := .f.
Local lAltDpG := .f.

Local oOficina := DMS_Oficina():New()
Local nMoedaC := 0

Local cAuxTES := ""

Private lMsHelpAuto := .t. , lMsErroAuto := .t., lMsFinalAuto := .f.

if oCLiente:Bloqueado(M->VO4_FATPAR , M->VO4_LOJA, .T.)
	Return(.f.)
EndIf

If !FG_FATSP(M->VO4_TIPTEM,M->VO4_FATPAR+M->VO4_LOJA,"M->VO4_NOMCLI","A1_NOME")

	If !MsgYesNo(STR0065+" "+M->VO4_TIPTEM,STR0066)  //"Sera Alterado todos os clientes do tipo de tempo"###"Atencao!!!"
		Return(.f.)
	Else
		lAltCli := .t.
	EndIf

EndIf

If oOficina:TipoTempoBloqueado(M->VO4_TIPTEM,.t.) // Valida se Tipo de Tempo esta BLOQUEADO
	return .f.
EndIf

If VOI->VOI_DEPINT == "1" // Tipo de Tempo Interno
	If !Empty(M->VO4_DEPINT)
		lAltDpI := .t.
	Endif
ElseIf VOI->VOI_DEPGAR == "1" // Tipo de Tempo Garantia
	If !Empty(M->VO4_DEPGAR)
		lAltDpG := .t.
	Endif
EndIf

cAuxTES := VOI->VOI_CODTES

//Validacao por Ponto de Entrada
If ExistBlock("OM030VAS") // Valida Altera็ใo do Servico
	lRet := ExecBlock("OM030VAS",.f.,.f.)
	If !lRet
		Return (.f.)
	Endif
Endif

VOX->( DbSetOrder(1) )
lConsidera := .t.
if VOI->(FieldPos("VOI_CONVOX")) > 0
	VOI->(DbSetOrder(1))
	VOI->(DbSeek( xFilial("VOI") + M->VO4_TIPTEM ))
	if VOI->VOI_CONVOX == "0"
		lConsidera := .f.
	endif
endif
If lConsidera .and. !Empty(M->VO4_TIPSER)
	If !VOX->( DbSeek( xFilial("VOX") + M->VO4_TIPSER + M->VO4_TIPTEM))
		lMsHelpAuto := .F.
		Help(1,"  ","TPSERTEM",,M->VO4_TIPSER+" - "+M->VO4_TIPTEM ,4,1)
		lMsHelpAuto := .T.
		Return(.f.)
	EndIf
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMarca as pecas com mesmo tipo de tempo dos servicos selecionados para alteracaoณ
//ณCalcula valor total que ficara para verificar o credito do FATURAR PARA        ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
For i := 1 to Len(aServicos)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณServico marcado para alteracaoณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If aServicos[i,1]

		lMensagem := .t.

		// Se exigir relacao do tipo de tempo com tipo de servico (VOX) e nao for informado o tipo de servico
		// na alteracao, verifica relacao com o TIPO DE SERVICO atual
		If lConsidera .and. Empty(M->VO4_TIPSER)
			If !VOX->( MsSeek( xFilial("VOX") + aServicos[i,13] + M->VO4_TIPTEM))

				If lMensagem
					lMsHelpAuto := .F.
					Help(1,"  ","TPSERTEM",,aServicos[i,13]+" - "+M->VO4_TIPTEM ,4,1)
					lMsHelpAuto := .T.
				EndIf

				Return(.f.)

			EndIf
		EndIf

		nValor := nValor + aServicos[i,9]

		// Pecas
		If Len(aPecas)#0 .And. aScan(aPecas,{|x| x[3] == aServicos[i,2]}) # 0

			For iP:=1 to Len(aPecas)

				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณPeca com mesmo TT do Servicoณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				If aPecas[iP,3] == aServicos[i,2]

					if lInconveniente .and. !aPecas[iP,3] <> aServicos[i,14]
						loop
					endif

					aPecas[iP,1] := aServicos[i,1]

					If aPecas[iP,2] =="0"
						nValor := nValor - aPecas[iP,8]
					Else
						nValor := nValor + aPecas[iP,8]
					EndIf

				EndIf

			Next

		EndIf

	EndIf

Next

If !lAltCli
	nValor := 0
Endif

lMsHelpAuto := .f.

lVerTpgCC := .t.
If ExistBlock("VERTPGCC") // Verifica tipo de Pagamento para Checagem de Credito
	lVerTpgCC := ExecBlock("VERTPGCC",.f.,.f.,{"OFIOM030"})
Endif

If lVerTpgCC
	if !FindFunction('FGX_ChkCredCond') .or. FGX_ChkCredCond(VO1->VO1_FORPAG)
		If "S" $ GetMv("MV_CHKCRE") .And. !(VOI->VOI_SITTPO $ "2/3/4")
			nMoedaC := IIF(lMultMoeda , Max(VO1->VO1_MOEDA,1), nil )
			If !FGX_AVALCRED(M->VO4_FATPAR,M->VO4_LOJA,nValor,.t., ,VO1->VO1_NUMOSV , nMoedaC)

				Help(" ",1,"LIMITECRED")
				return .f.

			EndIf

		EndIf
	Endif

Endif

lMsHelpAuto := .t.
lMsErroAuto := .f.

// Altera
Begin Transaction

// Altera Peca
For iP:=1 to Len(aPecas)

	DbSelectArea("VO3")
	VO3->(DbSetOrder(2)) // VO3_FILIAL+VO3_GRUITE+VO3_CODITE+VO3_NOSNUM+VO3_TIPTEM

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณSe a req. de Pecas nao for do mesmo TTณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If aPecas[iP,3] # M->VO4_TIPTEM
		Loop
	EndIf

	VO3->(DbSeek( xFilial("VO3") + aPecas[iP,6] + aPecas[iP,7] + aPecas[iP,9] + aPecas[iP,3] ))

	If (lAltDpI .or. lAltDpG) .or. !Empty(VO3->VO3_DATCAN) .or. VO3->VO3_FATPAR+VO3->VO3_LOJA <> M->VO4_FATPAR+M->VO4_LOJA
		If !RecLock("VO3",.F.)
			Help("  ",1,"REGNLOCK")
			lRet := .f.
			DisarmTransaction()
			Break
		EndIf
		If !Empty( M->VO4_DEPINT )
			VO3->VO3_DEPINT := M->VO4_DEPINT
		EndIf
		If !Empty( M->VO4_DEPGAR )
			VO3->VO3_DEPGAR := M->VO4_DEPGAR
		EndIf

		If !Empty(VO3->VO3_DATCAN)
			VO3->VO3_DATCAN := CtoD(" ")
		EndIf

		If VO3->VO3_FATPAR+VO3->VO3_LOJA <> M->VO4_FATPAR+M->VO4_LOJA
			VO3->VO3_TIPTEM := M->VO4_TIPTEM
			VO3->VO3_FATPAR := M->VO4_FATPAR
			VO3->VO3_LOJA   := M->VO4_LOJA

			DbSelectArea("VFB")
			DbSetOrder(3)
			DbSeek(xFilial("VFB")+VO1->VO1_PROVEI+VO1->VO1_LOJPRO+VO1->VO1_CHAINT+VO1->VO1_NUMOSV+"P")

			Do While !Eof() .And. VFB->VFB_FILIAL == xFilial("VFB") ;
				.And. VFB->VFB_CODCLI+VFB->VFB_LOJA+VFB->VFB_CHAINT+VFB->VFB_NUMOSV+VFB->VFB_SERPEC == VO1->VO1_PROVEI+VO1->VO1_LOJPRO+VO1->VO1_CHAINT+VO1->VO1_NUMOSV+"P"

				If VFB->VFB_TIPTEM == aPecas[iP,3]

					If !RecLock("VFB",.F.)
						Help("  ",1,"REGNLOCK")
						lRet := .f.
						DisarmTransaction()
						Break
					EndIf

					VFB->VFB_CODCLI := VO1->VO1_PROVEI
					VFB->VFB_LOJA   := VO1->VO1_LOJPRO
					VFB->VFB_TIPTEM := M->VO4_TIPTEM
					MsUnlock()

				EndIf

				DbSkip()

			EndDo
		Endif
		dbSelectArea("VO3")
		MsUnLock()
	Endif

Next

VO2->(DbSetOrder(2))

//  Altera Servico
For i:=1 to Len(aServicos)

	DbSelectArea("VO4")
	DbSetOrder(8)

	If aServicos[i,2] # M->VO4_TIPTEM

		If !aServicos[i,1]
			Loop
		EndIf

	EndIf

	DbSeek(xFilial("VO4") + aServicos[i,10] )

	Do While !Eof() .And. VO4->VO4_NOSNUM == aServicos[i,10] .And. VO4->VO4_FILIAL == xFilial("VO4")

		If VO4->VO4_TIPTEM == aServicos[i,2] .And. VO4->VO4_CODSER == aServicos[i,5]

			OFM0300011_PosicionaVO6( VO4->VO4_CODSER )

			DbSelectArea("VO4")
			If !RecLock("VO4",.F.)
				Help("  ",1,"REGNLOCK")
				lRet := .f.
				DisarmTransaction()
				Break
			EndIf

			M->VO4_CODTES := VO4->VO4_CODTES
			If !Empty(cAuxTES)
				M->VO4_CODTES := cAuxTES
			EndIf

			VO4->VO4_FILIAL := xFilial("VO4")
			VO4->VO4_TIPTEM := M->VO4_TIPTEM
			VO4->VO4_FATPAR := M->VO4_FATPAR
			VO4->VO4_LOJA   := M->VO4_LOJA
			VO4->VO4_DEPINT := M->VO4_DEPINT
			VO4->VO4_DEPGAR := M->VO4_DEPGAR
			VO4->VO4_CODTES := M->VO4_CODTES

			If !Empty(M->VO4_TIPSER) .And. VO4->VO4_TIPSER == aServicos[i,13] .And. aServicos[i,1]
				VO4->VO4_TIPSER := M->VO4_TIPSER
			EndIf

			If VO4->VO4_VHRDIG # "1"
				VO4->VO4_VALHOR := FG_ValHor(VO4->VO4_TIPTEM,OM030TPVLSRV(VO4->VO4_TIPTEM,VO4->VO4_NOSNUM),VO4->VO4_VHRDIG,VO4->VO4_VALHOR,VV1->VV1_CODMAR,VO4->VO4_CODSER,VO4->VO4_TIPSER,VO4->VO4_FATPAR,VO4->VO4_LOJA,VV1->VV1_MODVEI,VV1->VV1_SEGMOD, Iif(lMultMoeda, VO1->VO1_MOEDA, nil), Iif(lMultMoeda, VO1->VO1_TXMOED, nil))
			EndIf

			VO4->VO4_VALSER := VO6->VO6_VALSER // GRAVAR o Valor do Servi็o

			MsUnLock()

			DbSelectArea("VFB")
			DbSetOrder(3)
			DbSeek(xFilial("VFB")+VO1->VO1_PROVEI+VO1->VO1_LOJPRO+VO1->VO1_CHAINT+VO1->VO1_NUMOSV+"S")

			While !Eof() .And. VFB->VFB_FILIAL+VFB->VFB_CODCLI+VFB->VFB_LOJA+VFB->VFB_CHAINT+VFB->VFB_NUMOSV+VFB->VFB_SERPEC == xFilial("VFB")+VO1->VO1_PROVEI+VO1->VO1_LOJPRO+VO1->VO1_CHAINT+VO1->VO1_NUMOSV+"S"

				If VFB->VFB_CODSER == aServicos[i,5]

					If !RecLock("VFB",.F.)
						Help("  ",1,"REGNLOCK")
						lRet := .f.
						DisarmTransaction()
						Break
					EndIf

					VFB->VFB_CODCLI := VO1->VO1_PROVEI
					VFB->VFB_LOJA   := VO1->VO1_LOJPRO
					VFB->VFB_TIPTEM := M->VO4_TIPTEM
					MsUnlock()

				EndIf

				DbSelectArea("VFB")
				DbSkip()

			EndDo

		EndIf

		DbSelectArea("VO4")
		DbSkip()

	EndDo

	If aServicos[i,1] .and. VO2->(FieldPos("VO2_DATALT")) > 0
		DbSelectArea("VO2")
		RecLock("VO2",.f.)
			VO2->VO2_DATALT := DDATABASE
		MsUnLock()
	EndIf

	// Altera็ใo de Tipo de Tempo
	// Obs: FieldPos("VOU_SERINT") pois o campo ้ novo, antes o c๓digo nใo realizava essa altera็ใo!
	If aServicos[i,1] .And. VOU->(FieldPos("VOU_SERINT")) > 0
		// Verificar se o Servi็o estแ Relacionado e entใo
		// alterar o Tipo de Tempo (o campo "VOU_TIPTEM" deve ser alterado)
		// VO1
		DbSelectArea("VO1")
		DbSetOrder(1) // VO1_FILIAL + VO1_NUMOSV
		If DbSeek(xFilial("VO1") + VO1->VO1_NUMOSV)
			// VOU
			DbSelectArea("VOU")
			DbSetOrder(2) // VOU_FILIAL + VOU_CHASSI
			If DbSeek(xFilial("VOU") + VO1->VO1_CHASSI)
				While !VOU->(Eof()) .And. xFilial("VOU") == VOU->VOU_FILIAL .And. VO1->VO1_CHASSI == VOU->VOU_CHASSI .And. VO1->VO1_NUMOSV == VOU->VOU_NUMOSV
					If aServicos[i,5] == VOU->VOU_CODSER .And. aServicos[i,2] == VOU->VOU_TIPTEM
						RecLock("VOU", .F.)
						VOU->VOU_TIPTEM := M->VO4_TIPTEM
						MsUnlock()
					EndIf

					VOU->(dbSkip())
				EndDo
			EndIf
		EndIf
	EndIf

	// Array
	If aServicos[i,1] .and. !Empty(M->VO4_TIPSER)
		aServicos[i,13] := M->VO4_TIPSER
	EndIf
	aServicos[i,1]  := .F.
	aServicos[i,2]  := M->VO4_TIPTEM
	aServicos[i,3]  := M->VO4_FATPAR
	aServicos[i,4]  := M->VO4_LOJA
	aServicos[i,7]  := M->VO4_DEPINT
	aServicos[i,8]  := M->VO4_DEPGAR

Next

If !(lLimCre)
	Help(" ",1,"CATALOGO")
EndIf

If !lOM030Auto
	oLbItens:SetFocus()
EndIf

// Ponto de Entrada para verifica็๕es customizadas ap๓s Grava็ใo da Altera็ใo realizada com sucesso
If ExistBlock("OM030ADG")
	ExecBlock("OM030ADG",.f.,.f.)
Endif

End Transaction
lMsHelpAuto := .f.

If !lRet
	MostraErro()
EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_030INTGบAutor  ณFabio               บ Data ณ  07/07/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida    o departamento interno ou garantia                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FS_030INTGAR(cNumOsv,cTipTem)

Local cSelect:=Alias()
Local nPosVO2 := VO2->(Recno()), nIndVO2 := VO2->(IndexOrd())
Local nPosVO3 := VO3->(Recno()), nIndVO3 := VO3->(IndexOrd())
Local nPosVO4 := VO4->(Recno()), nIndVO4 := VO4->(IndexOrd())
Local nPosAcols := 0
Local lReturn := .t.
Local cDepInt, cDepGar

Default cNumOsv := VO1->VO1_NUMOSV
Default cTipTem := M->VO4_TIPTEM

VOI->( DbSetOrder(1) )
VOI->( DbSeek( xFilial("VOI") + cTipTem ) )

If VOI->VOI_SITTPO # "2" .and. ReadVar() <> 'M->VO4_DEPGAR'
	M->VO4_DEPGAR := CriaVar("VO4_DEPGAR")
EndIf

If VOI->VOI_SITTPO # "3" .and. ReadVar() <> 'M->VO4_DEPINT'
	M->VO4_DEPINT := CriaVar("VO4_DEPINT")
EndIf

VO2->( DbSetOrder(1) )
VO2->( DbSeek( xFilial("VO2") + cNumOsv ) )

VO3->( DbSetOrder(1) )
VO4->( DbSetOrder(1) )

If VO3->(DbSeek(xFilial("VO3")+VO2->VO2_NOSNUM+cTipTem )) .Or. VO4->(MsSeek(xFilial("VO4")+VO2->VO2_NOSNUM+cTipTem ))

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณRubens - 06/11/2009                                                       ณ
	//ณInicializa variaveis de memoria, somente se nao estiver editando as mesmasณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If ReadVar() <> 'M->VO4_DEPINT' .and. Empty(M->VO4_DEPINT)
		M->VO4_DEPINT := If( VO3->(Found()) , VO3->VO3_DEPINT , VO4->VO4_DEPINT )
		If Type("aCols") # "U"
			aCols[n,FG_POSVAR("VO4_DEPINT")] := M->VO4_DEPINT
		EndIf
	endif
	if ReadVar() <> 'M->VO4_DEPGAR' .and. Empty(M->VO4_DEPGAR)
		M->VO4_DEPGAR := If( VO3->(Found()) , VO3->VO3_DEPGAR , VO4->VO4_DEPGAR )
		If Type("aCols") # "U"
			aCols[n,FG_POSVAR("VO4_DEPGAR")] := M->VO4_DEPGAR
		EndIf
	endif
	cDepInt := If( VO3->(Found()) , VO3->VO3_DEPINT , VO4->VO4_DEPINT )
	cDepGar := If( VO3->(Found()) , VO3->VO3_DEPGAR , VO4->VO4_DEPGAR )
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณRubens - 06/11/2009                             ณ
	//ณAcerto na validacao de Depto Interno e Garantia.ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If ReadVar() == 'M->VO4_DEPINT' .Or. ReadVar() == 'M->VO4_DEPGAR'
		if (M->VO4_DEPINT <> cDepInt .and. !Empty(cDepInt)) .or. ;
			(M->VO4_DEPGAR <> cDepGar .and. !Empty(cDepGar))
			lReturn := .f.
		endif
	EndIf

EndIf

If Type("aCols") # "U"


	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณRubens - 06/11/2009                                            ณ
	//ณAcerto na validacao do Depto, quando estiver digitando na aColsณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	For nPosACols := 1 to Len(aCols)
		If n <> nPosACols .and. aCols[nPosACols,FG_POSVAR("VO4_TIPTEM")] == cTipTem
			cDepInt := aCols[nPosACols,FG_POSVAR("VO4_DEPINT")]
			cDepGar := aCols[nPosACols,FG_POSVAR("VO4_DEPGAR")]
			if (ReadVar() == 'M->VO4_DEPINT' .Or. ReadVar() == 'M->VO4_DEPGAR')
				if (M->VO4_DEPINT <> cDepInt .and. !Empty(cDepInt)) .or. ;
					(M->VO4_DEPGAR <> cDepGar .and. !Empty(cDepGar))
					lReturn := .f.
				endif
			endif
			// Sugere o Dep. Interno ou Dep. Garantia
			If ReadVar() == 'M->VO4_TIPTEM'
				aCols[n,FG_POSVAR("VO4_DEPINT")] := M->VO4_DEPINT := aCols[nPosaCols,FG_POSVAR("VO4_DEPINT")]
				aCols[n,FG_POSVAR("VO4_DEPGAR")] := M->VO4_DEPGAR := aCols[nPosaCols,FG_POSVAR("VO4_DEPGAR")]
			Endif
		Endif
	Next nPosACols

EndIf

If !lReturn
	Help(" ",1,"DEPINTGAR")
EndIf

VO2->(DbSetOrder(nIndVO2))
VO2->(DbGoTo(nPosVO2))
VO3->(DbSetOrder(nIndVO3))
VO3->(DbGoTo(nPosVO3))
VO4->(DbSetOrder(nIndVO4))
VO4->(DbGoTo(nPosVO4))
DbSelectArea(cSelect)

Return(lReturn)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_030SEQUEN บAutor  ณFabio               บ Data ณ  02/14/00   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMonta Sequencia                                                บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                           บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FS_030SEQUEN(laCols,cSequencia,lNovo)

Local cSelect:=Alias(),nPosVO4:=VO4->(Recno()),nIndVO4:=VO4->(IndexOrd())
Local nSeq := 0
Local nSequencia := If(cSequencia#NIL,Val(cSequencia),0)
Local cSQL

Default laCols      := .f.
Default lNovo := .f.

M->VO2_NOSNUM := If(Type("M->VO2_NOSNUM")#"U",M->VO2_NOSNUM,VO2->VO2_NOSNUM)

cSQL := ;
	" SELECT MAX(VO4_SEQUEN) " + ;
	  " FROM " + RetSQLName("VO4") + " VO4 " + ;
	" WHERE VO4.VO4_FILIAL = '" + xFilial("VO4") + "'" + ;
	  " AND VO4.VO4_NOSNUM = '" + M->VO2_NOSNUM + "'"
nSequencia := Val(FM_SQL(cSQL)) + 1

If (Type("aCols")#"U" .And. laCols) .or. lOM030Auto

	If (Type("oFolder030")#"U" .And. oFolder030:nOption == 2) .or. ( lOM030Auto .and. lAutoApont )

		For nSeq := 1 to Len(aCols)

			If nSeq#Len(aCols) .And. Val( aCols[nSeq,FG_POSVAR("VO4_SEQUEN","aHeader")] ) >= nSequencia
				nSequencia := Val(aCols[nSeq,FG_POSVAR("VO4_SEQUEN","aHeader")])+1
			EndIf

		Next

	EndIf

	For nSeq := 1 to Len(aColsIniFim)

		If nSeq#Len(aColsIniFim) .And. Val(aColsIniFim[nSeq,FG_POSVAR("VO4_SEQUEN","aHeaderIniFim")]) >= nSequencia
			nSequencia := Val(aColsIniFim[nSeq,FG_POSVAR("VO4_SEQUEN","aHeaderIniFim")])+1
		EndIf

	Next

EndIf

if lNovo

	For nSeq := 1 to Len(aColsIniFim)

		If Val(aColsIniFim[nSeq,FG_POSVAR("VO4_SEQUEN","aHeaderIniFim")]) >= nSequencia
			nSequencia := Val(aColsIniFim[nSeq,FG_POSVAR("VO4_SEQUEN","aHeaderIniFim")])+1
		EndIf

	Next

EndIf

VO4->(DbSetOrder(nIndVO4))
VO4->(DbGoTo(nPosVO4))
DbSelectArea(cSelect)

Return(StrZero(nSequencia,Len(VO4->VO4_SEQUEN)))

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_DIPOS  บAutor  ณFabio               บ Data ณ  02/18/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVerifica a disponibilidade da OS                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FS_DISPOS(nAba)

Local cSelect:=Alias(), nPosVO4:=VO4->(Recno()), nIndVO4:=VO4->(IndexOrd()),lReturn:=.t.

Default nAba := 1

DbSelectArea("VO4")

iif(cSelect =="",cSelect:=Alias(),cSelect)

If nAba == 1
	DbSetOrder(1)
	DbSeek(xFilial("VO4")+M->VO2_NOSNUM+M->VO4_TIPTEM+M->VO4_CODSER)
Else
	DbSetOrder(8)
	DbSeek(xFilial("VO4")+M->VO2_NOSNUM+M->VO4_SEQUEN)
EndIf

If !Empty(VO4->VO4_DATDIS) .And. !Empty(VO4->VO4_HORDIS)
	Help(" ",1,"SERVDISP")
	lReturn:=.f.
EndIf

DbSetOrder(nIndVO4)
DbGoTo(nPosVO4)
DbSelectArea(cSelect)

Return(lReturn)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_030VALIบAutor  ณFabio               บ Data ณ  02/24/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida as variaveis do fieldOk                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FS_030VALID(cLinhaField, lRestaura, cTipTem)

Local nPosTipSer := 0 ,nSit := 0
Local cTTSrv
Local aSitMec := {}
Local ni := 0
Local nQtdMec := 0
Local aProdTrab := {}
Local aInconv, nPosCODITE

Local cAuxReadVar := ReadVar()

Local oOficina   := DMS_Oficina():New()

Local nVlrSrvs   := 0
Local nMoedaC    := 0

Local lVO4IPDCOM := VO4->(FieldPos("VO4_IPDCOM")) > 0

lReadTipT := .f.


Default lRestaura := .f.
Default cTipTem := M->VO4_TIPTEM

VOI->( DbSetOrder(1) )
VOI->( DbSeek( xFilial("VOI") + cTipTem ) )

// Chamada pelo FieldOK
If cLinhaField == "F"

	conout(" ")
	conout("FS_030VALID")
	conout("Readvar: " + cvaltochar(readvar()))
	varinfo("aCols[" + cvaltochar(n) + "]", aCols[n])
	conout(" ")

	If !lAlterou
		lAlterou := .t.
	EndIf

	FG_MEMVAR()

	//Validacao por Ponto de Entrada
	If ExistBlock("OM030VLD")
		lRet := ExecBlock("OM030VLD",.f.,.f.,{cAuxReadVar})
		If !lRet
			Return (.f.)
		Endif
	Endif
	// Aba de Servicos
	If (lOM030Auto .and. !lAutoApont) .or. (lOM030Auto == .f. .and. oFolder030:nOption == 1)

		if Empty(aCols[n,FG_POSVAR("VO4_TIPTEM")]) .and. !Empty(cTpTpoPEVM)
			aCols[n,FG_POSVAR("VO4_TIPTEM")] :=cTpTpoPEVM
			M->VO4_TIPTEM := cTpTpoPEVM
			lReadTipT := .t.
		endif

		// Verifica se o tipo de tempo esta posicionado corretamente ...
		If oOficina:TipoTempoBloqueado(M->VO4_TIPTEM,.t.) // Valida se Tipo de Tempo esta BLOQUEADO
			return .f.
		EndIf
		//

		If ReadVar() == "M->VO4_TIPSER" .And. (Empty(aCols[n,FG_POSVAR("VO4_TIPSER")]) .Or. aCols[n,FG_POSVAR("VO4_TIPSER")] # M->VO4_TIPSER)
			if om030SRVJAREQ()
				return .f.
			endif
		endif

		If !Empty(M->VO4_TIPSER)
			VOK->(dbSetOrder(1))
			VOK->(MsSeek(xFilial("VOK") + M->VO4_TIPSER))
		EndIf

		If ReadVar() == "M->VO4_GRUSER"
			If !OM030GRUSRV(M->VO4_GRUSER,;
						M->VO4_TIPTEM,;
						VV1->VV1_CODMAR,;
						.t.)
				Return(.f.)
			EndIf

		EndIf

		If ReadVar() == "M->VO4_CODSER"

			FS_DUPLAPM(M->VO4_CODSER)
			//         FS_AGRUSER(VV1->VV1_CODMAR,VV1->VV1_MODVEI,M->VO4_CODSER)

			If !FG_GARANTIA( VO1->VO1_CHAINT , M->VO4_TIPTEM , , , M->VO4_CODSER , dDataBase , VO1->VO1_KILOME )
				Return(.f.)
			EndIf

			M->VO4_VALHOR := aCols[n,FG_POSVAR("VO4_VALHOR")] := FG_ValHor(M->VO4_TIPTEM,OM030TPVLSRV(M->VO4_TIPTEM,M->VO2_NOSNUM),,,VV1->VV1_CODMAR,M->VO4_CODSER,M->VO4_TIPSER,M->VO4_FATPAR,M->VO4_LOJA,VV1->VV1_MODVEI,VV1->VV1_SEGMOD,Iif(lMultMoeda, VO1->VO1_MOEDA, nil),Iif(lMultMoeda, VO1->VO1_TXMOED, nil))

			if lInconveniente
				// Se a OS utilizou ao menos um inconveniente, deve ser selecionado um inconveniente para o item
				if Empty(aCols[n,FG_POSVAR("VO4_SEQINC")])
					// Procura um item com inconveniente selecinado
					nPosCODITE := Ascan(aCols,{|x| !Empty(x[FG_POSVAR("VO4_SEQINC")]) })

					// Se tiver um item com inconveniente ou ja tiver uma peca requisitada com um inconveniente ...
					if nPosCODITE <> 0 .or. OM420UTILINC( "2" , VO1->VO1_NUMOSV )
						aInconv := OM420SELINCON(aCols, { FG_POSVAR("VO4_SEQINC") , ;
										FG_POSVAR("VO4_GRUINC") , ;
										FG_POSVAR("VO4_CODINC") , ;
										FG_POSVAR("VO4_DESINC") } , oMainWnd , "2" , VO1->VO1_NUMOSV ,;
										STR0006+": "+M->VO4_GRUSER+" - "+M->VO4_CODSER ) // Servico

						M->VO4_GRUINC := aCols[n,FG_POSVAR("VO4_GRUINC")] := aInconv[1]
						M->VO4_CODINC := aCols[n,FG_POSVAR("VO4_CODINC")] := aInconv[2]
						M->VO4_DESINC := aCols[n,FG_POSVAR("VO4_DESINC")] := aInconv[3]
						M->VO4_SEQINC := aCols[n,FG_POSVAR("VO4_SEQINC")] := aInconv[4]

					endif

				endif
			endif

			OFM0300011_PosicionaVO6( M->VO4_CODSER )

			M->VO4_DESSER := aCols[n,FG_POSVAR("VO4_DESSER")] := VO6->VO6_DESSER // GRAVAR a descri็ใo do Servi็o
			M->VO4_VALSER := aCols[n,FG_POSVAR("VO4_VALSER")] := VO6->VO6_VALSER // GRAVAR o Valor do Servi็o

		EndIf

		If (ReadVar()$'M->VO4_TIPTEM'.Or.ReadVar()$'M->VO4_DEPINT'.Or.ReadVar()$'M->VO4_DEPGAR') .or. lReadTipT
			if lReadTipT   .and. !(ReadVar()$'M->VO4_TIPTEM')
				__readvar := "M->VO4_TIPTEM"
				FS_TPFSRV(.T.)
			endif
			If !FS_030INTGAR(VO1->VO1_NUMOSV,M->VO4_TIPTEM)
				Return(.f.)
			EndIf

		EndIf

		If (ReadVar()$'M->VO4_TIPTEM'.Or.ReadVar()$'M->VO4_TIPSER'.Or.ReadVar()$'M->VO4_TEMPAD') .or. lReadTipT

			If ReadVar() == "M->VO4_TIPSER"

				nPosTipSer := Ascan(aColsIniFim,{|x| x[FG_POSVAR("VO4_CODSER","aHeaderIniFim")] == aCols[n,FG_POSVAR("VO4_CODSER")]})

				If !Empty(aCols[n,FG_POSVAR("VO4_TIPSER")]) .And. nPosTipSer # 0 .And. !(aColsIniFim[nPosTipSer,Len(aColsIniFim[nPosTipSer])]);
					.And.  VOK->VOK_INCMOB == "2"

					Help("  ",1,"ALTTIPSER")
					Return(.f.)

				EndIf

				// Verifica se o Srv e de Retorno
				If !FS_GARSRV( M->VO2_CHASSI , M->VO4_CODSER , M->VO4_TIPSER )
					Return(.f.)
				EndIf

				If !(VOK->VOK_INCMOB $ "2/5") // S๓ hแ valor de Hora se nใo for Servi็o de Terceiro e Kilometragem
					M->VO4_VALHOR := aCols[n,FG_POSVAR("VO4_VALHOR")] := FG_ValHor(M->VO4_TIPTEM,OM030TPVLSRV(M->VO4_TIPTEM,M->VO2_NOSNUM),,,VV1->VV1_CODMAR,M->VO4_CODSER,M->VO4_TIPSER,M->VO4_FATPAR,M->VO4_LOJA,VV1->VV1_MODVEI,VV1->VV1_SEGMOD,Iif(lMultMoeda, VO1->VO1_MOEDA, nil),Iif(lMultMoeda, VO1->VO1_TXMOED, nil))
				Endif

			EndIf

			//         If FG_LIMCRE(M->VO4_FATPAR,M->VO4_LOJA) < (FG_ValHor(M->VO4_TIPTEM,dDataBase)*  (Val(Left(StrZero(M->VO4_TEMPAD,4),2))*60)+Val(Right(StrZero(M->VO4_TEMPAD,4),2))  )/60
			lVerTpgCC := .t.
			If ExistBlock("VERTPGCC") // Verifica tipo de Pagamento para Checagem de Credito
				lVerTpgCC := ExecBlock("VERTPGCC",.f.,.f.,{"OFIOM030"})
			Endif

			If lVerTpgCC
				if !FindFunction('FGX_ChkCredCond') .or. FGX_ChkCredCond(VO1->VO1_FORPAG)
					If "S" $ GetMv("MV_CHKCRE") .And. !(VOI->VOI_SITTPO $ "2/3/4")

						If FindFunction("OM0200045_ChecaCredGar")
							If !OM0200045_ChecaCredGar()
								Return .t.
							EndIf
						Endif

						nVlrSrvs := OFM0300025_LevantaValorServicosGrid(n)
						nMoedaC    := IIF(FGX_MULTMOEDA(),IIF(VO1->(FieldPos("VO1_MOEDA"))>0,Max(VO1->VO1_MOEDA,1), nil ), nil )
						If !FGX_AVALCRED(M->VO4_FATPAR,M->VO4_LOJA, nVlrSrvs ,.t., ,VO1->VO1_NUMOSV ,nMoedaC)
							Help("  ",1,"LIMITECRED")
							Return(.f.)
						EndIf

					EndIf
				Endif
			EndIf

		EndIf

		If ReadVar() $ 'M->VO4_TIPTEM'  .or. lReadTipT

			If ReadVar() == "M->VO4_TIPTEM"
				If oOficina:TipoTempoBloqueado(M->VO4_TIPTEM,.t.) // Valida se Tipo de Tempo esta BLOQUEADO
					Return .f.
				EndIf
			EndIf

			// Valida tipo de tempo do orcamento
			If !FS_VALTPORC(M->VO4_TIPTEM)
				Return(.f.)
			EndIf

			// Valida se o veiculo tem tipo de tempo aberto em outra OS
			If !FS_VALTPABE(VO1->VO1_CHASSI,M->VO4_TIPTEM,VO1->VO1_NUMOSV)
				Return(.f.)
			EndIf

			// Valida tipo de atendimento por tipo de tempo
			If lVOITPATEN
				If !FGX_VOITPATEN(VO1->VO1_TPATEN, M->VO4_TIPTEM, .t.)
					Return(.f.)
				EndIf
			EndIf

			FS_FRANQUIA( M->VO4_TIPTEM )

			M->VO4_VALHOR := aCols[n,FG_POSVAR("VO4_VALHOR")] := FG_ValHor(M->VO4_TIPTEM,OM030TPVLSRV(M->VO4_TIPTEM,M->VO2_NOSNUM),,,VV1->VV1_CODMAR,M->VO4_CODSER,M->VO4_TIPSER,M->VO4_FATPAR,M->VO4_LOJA,VV1->VV1_MODVEI,VV1->VV1_SEGMOD,Iif(lMultMoeda, VO1->VO1_MOEDA, nil),Iif(lMultMoeda, VO1->VO1_TXMOED, nil))
			M->VO4_VALSER := 0

		EndIf

		If ReadVar() $ 'M->VO4_PRISMA'
			// Ja esta posicionado no valid do x3
			If VOF->VOF_SITBOX # "D" .And. VOF->VOF_NUMOSV # VO1->VO1_NUMOSV

				Return( .f. )

			EndIf

		EndIf

		If ReadVar() $ 'M->VO4_FATPAR/M->VO4_LOJA'
			M->VO4_VALHOR := aCols[n,FG_POSVAR("VO4_VALHOR")] := FG_ValHor(M->VO4_TIPTEM,OM030TPVLSRV(M->VO4_TIPTEM,M->VO2_NOSNUM),,,VV1->VV1_CODMAR,M->VO4_CODSER,M->VO4_TIPSER,M->VO4_FATPAR,M->VO4_LOJA,VV1->VV1_MODVEI,VV1->VV1_SEGMOD,Iif(lMultMoeda, VO1->VO1_MOEDA, nil),Iif(lMultMoeda, VO1->VO1_TXMOED, nil))
		EndIf

		If ReadVar() $ 'M->VO4_VALHOR'

			If !FS_VALVLRHOR()
				Return(.f.)
			EndIf

		EndIf

		// Quando algum campo que interfira no valor do servico for alterado, o campo de valor fixo de servico serแ zerado
//		If ReadVar() $ 'M->VO4_TIPTEM,M->VO4_TIPSER,M->VO4_M->VO4_VALHOR/M->VO4_TEMPAD' .and. FG_POSVAR("VO4_VALSER") <> 0
//			M->VO4_VALSER := aCols[n,FG_POSVAR("VO4_VALSER")] := 0
//		EndIf


		If ReadVar() $ 'M->VO4_VALSER'

			If !OM030VALSER(M->VO4_CODSER,M->VO4_VALSER,-1)
				Return .f.
			EndIf

		EndIf

		If ( ReadVar()$'M->VO4_TIPTEM'.Or.;
			 ReadVar()$'M->VO4_CODSER'.Or.;
			 ReadVar()$'M->VO4_TIPSER'.Or.;
			 ReadVar()$'M->VO4_TEMPAD'.Or.;
			 ReadVar()$'M->VO4_VALHOR'.Or.;
			 ReadVar()$'M->VO4_FATPAR/M->VO4_LOJA'.Or.;
			 ReadVar()$'M->VO4_VALSER'.Or.;
			 (ReadVar()$'M->VO4_KILROD/M->VO4_PREKIL'.And.VOK->VOK_INCMOB=='5')) .or.;
			lReadTipT

			If FG_POSVAR("VO4_VALTOT") # 0
				M->VO4_VALTOT := OM030TOTSRV(aCols[n,FG_POSVAR("VO4_CODSER")])
				aCols[n,FG_POSVAR("VO4_VALTOT")] := M->VO4_VALTOT
			EndIf

		EndIf

		If ReadVar() == "M->VO4_VALCUS"
			If VOK->VOK_INCMOB == "2" // Servi็o de Terceiro
				M->VO4_VALVEN := aCols[n,FG_POSVAR("VO4_VALVEN")] := OFM0300045_ValorServicoTerceiro(M->VO4_VALCUS,aCols[n,FG_POSVAR("VO4_CODSER")])
			EndIf
		EndIf

		If ReadVar() == "M->VO4_PEDCOM" .or.;
			( lVO4IPDCOM .and. ReadVar() == "M->VO4_IPDCOM" )

			If Empty(M->VO4_PEDCOM) .and. aCols[n,nUsadoSrv] == 0 // Deixa passar no valid quando limpa o campo e o registro ainda nใo esta gravado no VO4
				OM0300091_Limpar_relacionamento_Pedido()
				Return .t.
			EndIf

			If VOK->VOK_INCMOB == "2" // Servi็o de Terceiro

				SB1->(DbSetOrder(7))
				SB1->(DbSeek(xFilial("SB1")+VOK->VOK_GRUITE+VOK->VOK_CODITE))
				SB1->(DbSetOrder(1))

				cChvPesq := SB1->B1_COD + M->VO4_CODFOR + M->VO4_FOLOJA + M->VO4_PEDCOM
				If lVO4IPDCOM .and. !Empty(M->VO4_IPDCOM)
					cChvPesq := SB1->B1_COD + M->VO4_CODFOR + M->VO4_FOLOJA + M->VO4_PEDCOM + M->VO4_IPDCOM
				EndIf

				SC7->(DbSetOrder(6)) //Filial Entr. + Produto + Fornecedor + Loja + Numero PC + Item + Item g
				If !SC7->( DbSeek( xFilial("VO4") + cChvPesq ) )
					FMX_HELP("OFM030ERR03", STR0182 , STR0183 ) // "Pedido informado nใo encontrado" / "Informe um c๓digo de pedido existente"
					Return(.f.)
				Else
					If !OM0300065_RelacionarPedido()
						Return(.f.)
					EndIf
				EndIf
			EndIf
		EndIf
	// Aba de Apontamentos
	Else

		If Empty(M->VO4_CODSER)
			Help("  ",1,"OBRIGAT",,aHeader[FG_POSVAR('VO4_CODSER'),1],4,1)
			Return(.f.)
		EndIf

		If Empty(M->VO4_GRUSER)
			Help("  ",1,"OBRIGAT",,aHeader[FG_POSVAR('VO4_GRUSER'),1],4,1)
			Return(.f.)
		EndIf

		If !FG_QTDMEC(M->VO2_NUMOSV,Posicione("VO6",2,xFilial("VO6")+FG_MARSRV(VV1->VV1_CODMAR,M->VO4_CODSER)+M->VO4_CODSER,"VO6_SERINT"),M->VO4_CODPRO,M->VO4_DATINI,M->VO4_HORINI,M->VO4_DATFIN,M->VO4_HORFIN)
			Return(.f.)
		Else
			// Valida a Qtde de Mecanicos por Servico //
			If !Empty(M->VO4_DATINI) .and. !Empty(M->VO4_HORINI)
				For ni := 1 to len(aCols)
					If !aCols[ni,Len(aCols[ni])]
						If aCols[ni,FG_POSVAR("VO4_CODSER")] == M->VO4_CODSER
							If Empty(aCols[ni,FG_POSVAR("VO4_DATFIN")]) .or. ( ;
								M->VO4_DATINI >= aCols[ni,FG_POSVAR("VO4_DATINI")] .and. ;
								M->VO4_HORINI >= aCols[ni,FG_POSVAR("VO4_HORINI")] .and. ;
								M->VO4_DATINI <= aCols[ni,FG_POSVAR("VO4_DATFIN")] .and. ;
								M->VO4_HORINI <= aCols[ni,FG_POSVAR("VO4_HORFIN")] )
								If Len( aProdTrab ) == 0 .Or. Ascan( aProdTrab , aCols[ni,FG_POSVAR("VO4_CODPRO")] ) == 0
									Aadd( aProdTrab , aCols[ni,FG_POSVAR("VO4_CODPRO")] )
									nQtdMec++
								EndIf
							EndIf
						EndIf
					EndIf
				Next
				If nQtdMec > VO6->VO6_QTDMEC
					Help("  ",1,"QTDMEC",,Alltrim(RetTitle("VO6_CODSER"))+": "+Alltrim(VO6->VO6_CODSER)+" ( "+Alltrim(str(nQtdMec,8)+" "+STR0077)+" )",4,1) // Produtivos
					Return(.f.)
				EndIf
			EndIf
		EndIf

		If ReadVar()$'M->VO4_CODPRO'

			If !FG_HABPRO(M->VO4_CODPRO,VV1->VV1_CODMAR,M->VO4_CODSER)
				Return(.f.)
			EndIf

			If !Empty(aCols[n,FG_POSVAR("VO4_DATINI")])

				// Verifica se existe algum servico iniciado na mesma hora ...
				If !OM030VLAP(M->VO4_CODPRO,M->VO4_DATINI,M->VO4_HORINI,M->VO2_NOSNUM,M->VO4_SEQUEN)
					Return(.f.)
				EndIf
				//

				If !FG_TEMPTRA(M->VO4_CODPRO,M->VO4_DATINI,M->VO4_HORINI,M->VO4_DATFIN, M->VO4_HORFIN ,,,, M->VO2_NOSNUM+M->VO4_SEQUEN , aCols , aHeader )
					Return(.f.)
				EndIf

			EndIf

			cTTSrv := aColsSrv[ Ascan(aColsSrv,{|x| x[FG_POSVAR("VO4_CODSER","aHeaderSrv")] == M->VO4_CODSER }) , FG_POSVAR("VO4_TIPTEM","aHeaderSrv")]

			FS_AGRUSER(VV1->VV1_CODMAR,VV1->VV1_MODVEI,M->VO4_CODSER,cTTSrv,M->VO4_CODPRO)

			// Valida se o produtivo esta com hora aberta
			If !FS_APOUNICO()
				Return(.f.)
			EndIf

		EndIf

		If ReadVar()$'M->VO4_DATINI'
			// Valida se o produtivo esta com hora aberta
			If !FS_APOUNICO()
				Return(.f.)
			EndIf

		EndIf

		If ( ReadVar() $ 'M->VO4_HORFIN' )

			If Dtos(M->VO4_DATFIN)+Str(M->VO4_HORFIN,4) > Dtos(dDataBase+GetNewPar("MV_DIAFUT",0))+(Substr(Time(),1,2)+Substr(Time(),4,2))
				Help("  ",1,"DTFUTINVAL")
				Return(.f.)
			EndIf

			If Dtos(M->VO4_DATFIN)+Str(M->VO4_HORFIN,4) < Dtos(M->VO4_DATINI)+Str(M->VO4_HORINI,4) .Or. (((M->VO4_DATFIN-M->VO4_DATINI)*2400)+M->VO4_HORFIN ) - M->VO4_HORINI > 2400
				Help("  ",1,"VQHORAS")
				Return(.f.)
			EndIf

			If !FG_TEMPTRA(M->VO4_CODPRO,M->VO4_DATINI,M->VO4_HORINI,M->VO4_DATFIN,M->VO4_HORFIN ,,,, M->VO2_NOSNUM+M->VO4_SEQUEN , aCols , aHeader )
				Return(.f.)
			EndIf

			aSitMec := FG_TEMPTRA(M->VO4_CODPRO,M->VO4_DATINI,M->VO4_HORINI,M->VO4_DATFIN, M->VO4_HORFIN ,"A",,"F/D", M->VO2_NOSNUM+M->VO4_SEQUEN , aCols , aHeader )

			If !lRestaura
				For nSit := 1 to Len(aSitMec)
					//             FS_DUPL030(cIndice,.t.,.t.,If(nSit==Len(aSitMec),.t.,.f.),M->VO4_CODPRO,aSitMec[nSit,1],aSitMec[nSit,2],aSitMec[nSit,3],aSitMec[nSit,4],aSitMec[nSit,5],If(nSit==1,.f.,.t.))
					If !FS_DUPL030(cIndice,.t.,.t.,.f.,M->VO4_CODPRO,aSitMec[nSit,1],If(nSit==1,M->VO4_HORINI,aSitMec[nSit,2]),aSitMec[nSit,3],aSitMec[nSit,4],aSitMec[nSit,5],If(nSit==1,.f.,.t.))
						Return(.f.)
					EndIf
				Next
			EndIf

			If !lOM030Auto
				n := Ascan(aCols,{|x| x[FG_POSVAR("VO4_CODSER")]+x[FG_POSVAR("VO4_CODPRO")]+Dtos(x[FG_POSVAR("VO4_DATFIN")])+Str(x[FG_POSVAR("VO4_HORFIN")],4) == M->VO4_CODSER+M->VO4_CODPRO+Dtos(M->VO4_DATFIN)+Str(M->VO4_HORFIN,4) })
				oGetIniFim:oBrowse:nAt := n
			EndIf

		EndIf

		If ReadVar() $ 'M->VO4_DATINI' .And. M->VO4_DATINI < IIF( lVO1DATATE .and. !Empty(VO1->VO1_DATATE) , VO1->VO1_DATATE , VO1->VO1_DATABE )
			Help("  ",1,"DATANOSABE",,	DtoC(IIF( lVO1DATATE .and. !Empty(VO1->VO1_DATATE) , VO1->VO1_DATATE , VO1->VO1_DATABE )),4,0)
			Return( .f. )
		EndIf

		If ( ReadVar()$'M->VO4_HORINI' )

			If Dtos(M->VO4_DATINI)+StrZero(M->VO4_HORINI,4) <  IIF( lVO1DATATE .and. !Empty(VO1->VO1_DATATE) , Dtos(VO1->VO1_DATATE)+StrZero(VO1->VO1_HORATE,4) , Dtos(VO1->VO1_DATABE)+StrZero(VO1->VO1_HORABE,4) )
				Help("  ",1,"DATANOSABE",, IIF( lVO1DATATE .and. !Empty(VO1->VO1_DATATE) , DtoC(VO1->VO1_DATATE) + CHR(13) + CHR(10) + Transform(VO1->VO1_HORATE,"@R 99:99") , DtoC(VO1->VO1_DATABE) + CHR(13) + CHR(10) + Transform(VO1->VO1_HORABE,"@R 99:99")),4,0)
				Return( .f. )
			EndIf

			If Dtos(M->VO4_DATINI)+Str(M->VO4_HORINI,4) > Dtos(dDataBase+GetNewPar("MV_DIAFUT",0))+(Substr(Time(),1,2)+Substr(Time(),4,2))

				Help("  ",1,"DTFUTINVAL")
				Return(.f.)

			EndIf

			// Verifica se existe algum servico iniciado na mesma hora ...
			If !OM030VLAP(M->VO4_CODPRO,M->VO4_DATINI,M->VO4_HORINI,M->VO2_NOSNUM,M->VO4_SEQUEN)
				Return(.f.)
			EndIf
			//

			If !FG_TEMPTRA(M->VO4_CODPRO,M->VO4_DATINI,M->VO4_HORINI,M->VO4_DATFIN,M->VO4_HORFIN  ,,,, M->VO2_NOSNUM+M->VO4_SEQUEN , aCols , aHeader )

				Return(.f.)

			EndIf

			aSitMec := FG_TEMPTRA(M->VO4_CODPRO,M->VO4_DATINI,M->VO4_HORINI,M->VO4_DATFIN, M->VO4_HORFIN ,"A",,"F/D", M->VO2_NOSNUM+M->VO4_SEQUEN , aCols , aHeader )

			If !lRestaura
				If !FS_DUPL030(cIndice,.t.,.t.,.f.,M->VO4_CODPRO,M->VO4_DATINI,M->VO4_HORINI,M->VO4_DATFIN,M->VO4_HORFIN,aSitMec[1,5],.f.)
					Return(.f.)
				EndIf
			EndIf

		EndIf

		if ReadVar() $ 'M->VO4_PERRAT'
			if Empty("M->VO4_CODPRO")
				Help("  ",1,"M030OBRPRO")
				return .f.
			endif
			aVetPerc := {}
			For ni := 1 to len(aCols)
				If !aCols[ni,Len(aCols[ni])] .and. ni != n .and.  M->VO4_GRUSER + M->VO4_CODSER == aCols[ni,FG_POSVAR("VO4_GRUSER")] + aCols[ni,FG_POSVAR("VO4_CODSER")]
					If !Empty(aCols[ni,FG_POSVAR("VO4_PERRAT")])    .and. aCols[ni,FG_POSVAR("VO4_PERRAT")] != 0
						nPos := AScan( aVetPerc , { |x| x[1] == aCols[ni,FG_POSVAR("VO4_CODPRO")] } )
						if nPos == 0
							aAdd(aVetPerc, {aCols[ni,FG_POSVAR("VO4_CODPRO")], aCols[ni,FG_POSVAR("VO4_PERRAT")]})
						else
							if aCols[ni,FG_POSVAR("VO4_PERRAT")] != aVetPerc[nPos,2] // so por seguran็a. nao deveria entrar
								Help("  ",1,"M030RATDIV",,,3,0)
								return .f.
							endif
						endif
					endif
				endif
			next
			nPos := AScan( aVetPerc , { |x| x[1] == M->VO4_CODPRO } )
			if nPos ==0
				aAdd(aVetPerc, {M->VO4_CODPRO, M->VO4_PERRAT})
				nPos := Len(aVetPerc)
			else
				aVetPerc[nPos,2]:= M->VO4_PERRAT
			endif
			nTotPercMec := 0
			For ni := 1 to len(aVetPerc)
				nTotPercMec +=aVetPerc[ni,2]
			next
			if nTotPercMec > 100
				Help("  ",1,"030DIV100",,,3,0)
				return .f.
			endif
			For ni := 1 to len(aCols)
				If M->VO4_GRUSER + M->VO4_CODSER + M->VO4_CODPRO == aCols[ni,FG_POSVAR("VO4_GRUSER")] + aCols[ni,FG_POSVAR("VO4_CODSER")] + aCols[ni,FG_POSVAR("VO4_CODPRO")]
					aCols[ni,FG_POSVAR("VO4_PERRAT")] := aVetPerc[nPos,2]
				endif
			next
		endif
		//
		//
		// Pergunta se o servico foi finalizado
		If ReadVar() $ "M->VO4_HORINI/M->VO4_HORFIN"

			FS_SRVFIN()

		EndIf

		// Valida autorizacao do usuario
		If !FS_VALDPRO(__cUserID,M->VO4_CODPRO)
			Return(.f.)
		EndIf

		If ReadVar() $ "M->VO4_CODFAS/M->VO4_TEMFAS"
			If !FS_VLDFASE(__cUserID)
				Return(.f.)
			EndIf
		EndIf

	EndIf

// Chamada pelo LinOK
Else

	If !aCols[n,Len(aCols[n])]

		If (lOM030Auto .and. !lAutoApont) .or. (lOM030Auto == .f. .and. oFolder030:nOption == 1)

			If FG_OBRIGAT() .And. FG_FATSP(M->VO4_TIPTEM,M->VO4_FATPAR+M->VO4_LOJA,'M->VO4_NOMCLI','A1_NOME',,aCols,,"VO4_TIPTEM","VO4_FATPAR","VO4_LOJA",n)

				If !FS_DUPLAPM()
					Return(.f.)
				EndIf

				If !FS_VALSRV3( .t. , aCols[n,nUsadoSrv] , aCols , n )

					Return(.f.)

				EndIf

				VOI->(dbSetOrder(1))
				VOI->(MSSeek(xFilial("VOI") + M->VO4_TIPTEM))
				If VOI->VOI_DEPINT=="1" .And. Empty(M->VO4_DEPINT)
					Help("  ",1,"OBRIGAT",,aHeader[FG_POSVAR('VO4_DEPINT'),1],4,1)
					Return(.f.)
				EndIf
				If VOI->VOI_DEPGAR=="1" .And. Empty(M->VO4_DEPGAR)
					Help("  ",1,"OBRIGAT",,aHeader[FG_POSVAR('VO4_DEPGAR'),1],4,1)
					Return(.f.)
				EndIf

			Else

				Return(.f.)

			EndIf

		Else

			/*			If !Empty( M->VO4_CODPRO ) .And. Empty( M->VO4_DATINI )

			Help("  ",1,"OBRIGAT")
			Return(.f.)

			EndIf
			*/
			If !Empty(M->VO4_DATINI) .AND. !EMPTY(M->VO4_DATFIN)

				If Dtos(M->VO4_DATINI)+Str(M->VO4_HORINI,4) > Dtos(dDataBase+GetNewPar("MV_DIAFUT",0))+(Substr(Time(),1,2)+Substr(Time(),4,2))
					Help("  ",1,"DTFUTINVAL")
					Return(.f.)
				EndIf

				If Dtos(M->VO4_DATFIN)+Str(M->VO4_HORFIN,4) > Dtos(dDataBase+GetNewPar("MV_DIAFUT",0))+(Substr(Time(),1,2)+Substr(Time(),4,2))
					Help("  ",1,"DTFUTINVAL")
					Return(.f.)
				EndIf

				If Dtos(M->VO4_DATFIN)+ Str(M->VO4_HORFIN,4) < Dtos(M->VO4_DATINI)+Str(M->VO4_HORINI,4) .Or. (((M->VO4_DATFIN-M->VO4_DATINI)*2400)+M->VO4_HORFIN ) - M->VO4_HORINI > 2400
					Help("  ",1,"VQHORAS")
					Return(.f.)
				EndIf

			Endif

		EndIf

	EndIf

EndIf

Return(.t.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_VALSRV3บAutor  ณFabio               บ Data ณ  04/25/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida os campo do servico de terceiros                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_VALSRV3( lMensagem , nRecVO4 , aColsAux , nLinaCols  )

Local nSrv3 := 0 , bCamposSrv3
Local cCpoVld := ""
Local cMV_SRV3PD := GetNewPar("MV_SRV3PD","N")
Local nTo     := 0
Local lVO4IPDCOM := ( VO4->(FieldPos("VO4_IPDCOM")) > 0 )
Local cChvPesq   := ""

Default lMensagem := .t.

If VOK->VOK_INCMOB == "2"

	If cMV_SRV3PD == "P" // Pedido
		If cPaisLoc $ "ARG/MEX/PAR"
			cCpoVld := "M->VO4_CODFOR#M->VO4_CODPAG#M->VO4_VALVEN#M->VO4_VALCUS#"
			nTo := 56 // N๚mero de caracteres a serem lidos
		Else
			If ( !Empty(M->VO4_PEDCOM) .Or. !Empty(M->VO4_VALCUS))
				cCpoVld := "M->VO4_CODFOR#M->VO4_CODPAG#M->VO4_VALVEN#M->VO4_DATPAG#M->VO4_VALCUS#"
				nTo := 70 // N๚mero de caracteres a serem lidos
			EndIf
		EndIf
	ElseIf cMV_SRV3PD == "T" // Titulo Provisorio
		cCpoVld := "M->VO4_CODFOR#M->VO4_CODPAG#M->VO4_VALVEN#M->VO4_DATPAG#M->VO4_VALCUS#M->VO4_NATURE#"
		nTo := 84 // N๚mero de caracteres a serem lidos
		If !cPaisLoc $ "ARG/MEX/PAR" .and. ( Empty(M->VO4_NUMTIT) .and. Empty(M->VO4_VALCUS) ) // Recuperado Regra perdida com a altera็ใo do chamado DVARMIL-7429
			cCpoVld := ""
			nTo := 0
		EndIf
	EndIf

	If !Empty(cCpoVld)

		bCamposSrv3 := {|x| Substr( cCpoVld , x ,13 ) }

		For nSrv3 := 1 to nTo Step 14

			If Empty( &( Eval( bCamposSrv3 , nSrv3 ) ) )
				If lMensagem
					Help(" ",1,"OBRIGAT",,RetTitle(Subs(Eval( bCamposSrv3 , nSrv3 ),4,10)),5,1)
				EndIf
				Return(.f.)
			EndIf

		Next

	EndIf

	If !Empty(M->VO4_PEDCOM)
		SB1->(DbSetOrder(7))
		SB1->(DbSeek(xFilial("SB1")+VOK->VOK_GRUITE+VOK->VOK_CODITE))
		SB1->(DbSetOrder(1))
		cChvPesq := SB1->B1_COD + M->VO4_CODFOR + M->VO4_FOLOJA + M->VO4_PEDCOM
		If lVO4IPDCOM .and. !Empty(M->VO4_IPDCOM)
			cChvPesq := SB1->B1_COD + M->VO4_CODFOR + M->VO4_FOLOJA + M->VO4_PEDCOM + M->VO4_IPDCOM
		EndIf
		SC7->(DbSetOrder(6)) //Filial Entr. + Produto + Fornecedor + Loja + Numero PC + Item + Item g
		If SC7->( DbSeek( xFilial("VO4") + cChvPesq ) )
			If !OM0300081_Valida_QTD_SC7_com_VO4( M->VO4_TIPSER , nRecVO4 , aColsAux , nLinaCols )
				Return .f.
			EndIf
		EndIf
	EndIf

EndIf

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_GARSRV   บAutor  ณMicrosiga         บ Data ณ  07/29/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_GARSRV(cCodVei,cSrv,cTipSer)

Local cSele := Alias() , nPosSele := Recno()
Local dDatSrv , nPosReg := 0 , lSrvReq := .f. , lRet := .t.
Private aPecExec := {} , aTodasPec := {} , aSrvExec := {}
Private oOk     := LoadBitmap( GetResources(), "LBTIK" )
Private oNo     := LoadBitmap( GetResources(), "LBNO" )

dDatSrv := (dDataBase-365)

DbSelectArea("VOK")
DbSetOrder(1)
DbSeek(xFilial("VOK") + cTipSer )

If VOK->VOK_INCMOB != "4"
	Return(.t.)
EndIf

DbSelectArea("VV1")
DbSetOrder(2)
DbSeek(xFilial("VV1") + cCodVei )

DbSelectArea("VO6")
DbSetOrder(1)
DbSeek(xFilial("VO6") + cSrv )

DbSelectArea("VFB")
DbSetOrder(6)
DbSeek(xFilial("VFB") + VV1->VV1_PROATU + VV1->VV1_LJPATU + VV1->VV1_CHAINT + "S" + Dtos(dDatSrv) , .t. )

Do While !Eof() .And. VFB->VFB_FILIAL == xFilial("VFB") .And. VFB->VFB_CODCLI == VV1->VV1_PROATU ;
	.And. VFB->VFB_LOJA == VV1->VV1_LJPATU .And. VFB->VFB_SERPEC == "S" ;
	.And. VFB->VFB_DATAPL >= dDatSrv .And.VFB->VFB_DATAPL <= dDataBase

	If VFB->VFB_CODSER == cSrv
		lSrvReq := .t.
	EndIf

	// Servicos
	DbSelectArea("VSC")
	DbSetOrder(1)
	DbSeek(xFilial("VSC") + VFB->VFB_NUMOSV + VFB->VFB_TIPTEM + VFB->VFB_CODSER  )

	Do While !Eof() .And. VSC->VSC_FILIAL == xFilial("VSC") .And. VSC->VSC_NUMOSV == VFB->VFB_NUMOSV ;
		.And. VSC->VSC_TIPTEM == VFB->VFB_TIPTEM .And. VSC->VSC_CODSER == VFB->VFB_CODSER

		DbSelectArea("VOK")
		DbSetOrder(1)
		DbSeek(xFilial("VOK") + VSC->VSC_TIPSER )

		DbSelectArea("VOI")
		DbSetOrder(1)
		DbSeek(xFilial("VOI") + VSC->VSC_TIPTEM )

		//    If VOK->VOK_INCTEM # "5" .And. VOI->VOI_TPOKLM == "0"
		If VOI->VOI_TPOKLM == "0"

			DbSelectArea("VAI")
			DbSetOrder(1)
			DbSeek(xFilial("VAI") + VSC->VSC_CODPRO )

			// Armazena todos o servicos de retorno
			If Len(aSrvRetorno) # 0
				nPosReg := Ascan(aSrvRetorno, {|x| x[3]+x[4]+x[5]+x[6] == cSrv+VFB->VFB_CODSER+VFB->VFB_NUMOSV+VSC->VSC_RECVO4 } )
			EndIf

			If nPosReg == 0
				Aadd(aSrvRetorno, {.f. , .f. , cSrv , VFB->VFB_CODSER , VFB->VFB_NUMOSV , VSC->VSC_RECVO4 , VFB->VFB_DATAPL , VFB->VFB_DATFEC , VFB->VFB_KILOME , VFB->VFB_TIPTEM , VSC->VSC_NUMNFI , VSC->VSC_CODPRO , VAI->VAI_NOMTEC , VSC->VSC_TEMTRA , VSC->VSC_TEMCOB , VSC->VSC_VALSER , VSC->VSC_TIPSER } )
				nPosReg := Len(aSrvRetorno)
			EndIf

			Aadd(aSrvExec   , { aSrvRetorno[nPosReg,1] , cSrv , VFB->VFB_CODSER , VFB->VFB_NUMOSV , VFB->VFB_DATAPL , VFB->VFB_DATFEC , VFB->VFB_KILOME , VFB->VFB_TIPTEM , VSC->VSC_NUMNFI , VSC->VSC_CODPRO , VAI->VAI_NOMTEC , VSC->VSC_TEMTRA , VSC->VSC_TEMCOB , VSC->VSC_VALSER , VSC->VSC_RECVO4 , VSC->VSC_TIPSER } )

			// Pecas
			If Ascan(aTodasPec, { |x| x[3] == VSC->VSC_NUMNFI }) == 0

				DbSelectArea("VEC")
				DbSetOrder(4)
				DbSeek(xFilial("VEC") + VSC->VSC_NUMNFI )

				Do While !Eof() .And. VEC->VEC_FILIAL == xFilial("VEC") .And. VEC->VEC_NUMNFI == VSC->VSC_NUMNFI

					DbSelectArea("SB1")
					DbSetOrder(7)
					DbSeek(xFilial("SB1") + VEC->VEC_GRUITE + VEC->VEC_CODITE )

					Aadd(aTodasPec, {.f. , VSC->VSC_NUMNFI , VEC->VEC_GRUITE , VEC->VEC_CODITE , SB1->B1_DESC , VEC->VEC_QTDITE , VEC->VEC_VALVDA } )

					DbSelectArea("VEC")
					DbSkip()

				EndDo

			EndIf

		EndIf

		DbSelectArea("VSC")
		DbSkip()

	EndDo

	DbSelectArea("VFB")
	DbSkip()

EndDo

If Len(aTodasPec) == 0
	Aadd(aTodasPec, {.f. , "" , "" , "" , "" , 0 , 0 } )
EndIf

If Len(aSrvExec) # 0

	Asort(aSrvExec,1,,{ |x,y| Dtos(x[5])+x[4] > Dtos(y[5])+y[4] })

	If lSrvReq

		If MsgYesNo(STR0067,STR0068) //"Confirma retorno?"###"Retorno de Servico"

			FS_DESMARCA(cSrv,.t.)
			DbSelectArea(cSele)
			DbGoTo(nPosSele)
			Return(.t.)

		Else

			DbSelectArea(cSele)
			DbGoTo(nPosSele)
			Return(.f.)

		EndIf

	EndIf

	// Tela do Retorno do Servico
	DEFINE MSDIALOG oDlgRetorno FROM 001,000 TO 024,070 TITLE STR0068 OF oMainWnd //"Retorno de Servico"

	@ 001,001 TO 080,278 LABEL STR0013 OF oDlgRetorno PIXEL  //"Servicos"

	@ 006,002 LISTBOX oLbRetorno FIELDS HEADER   OemToAnsi(""),; // "Cod item"
		OemToAnsi(STR0069),; //"Nro OS"
		OemToAnsi(STR0070),; //"Servico"
		OemToAnsi(STR0071),; //"Tp Srv"
		OemToAnsi(STR0072),; //"Dt Aplic"
		OemToAnsi(STR0073),; //"Dt Fecha"
		OemToAnsi(STR0074),; //"Kilometragem"
		OemToAnsi(STR0075),; //"Tp"
		OemToAnsi(STR0076),; //"Nro Nf"
		OemToAnsi(STR0077),; //"Produtivo"
		OemToAnsi(STR0078),; //"Nome"
		OemToAnsi(STR0079),; //"Tp Trab"
		OemToAnsi(STR0080),; //"Tp Cobr"
		OemToAnsi(STR0081); //"Vlr Srv"
		COLSIZES 10,30,30,15,25,25,30,10,25,30,50,25,25,40;
		SIZE 275,70 OF oDlgRetorno ON DBLCLICK (FS_CLICK(),oLbRetorno:Refresh()) ;
		ON CHANGE FS_MOSTRAPEC(aSrvExec[oLbRetorno:nAt,9]) PIXEL

	oLbRetorno:SetArray(aSrvExec)
	oLbRetorno:bLine := { || { If(aSrvExec[oLbRetorno:nAt,1], oOk , oNo ) ,;
		aSrvExec[oLbRetorno:nAt,4] ,;
		aSrvExec[oLbRetorno:nAt,3] ,;
		aSrvExec[oLbRetorno:nAt,16] ,;
		Dtoc(aSrvExec[oLbRetorno:nAt,5]) ,;
		Dtoc(aSrvExec[oLbRetorno:nAt,6]) ,;
		Transform(aSrvExec[oLbRetorno:nAt,7], "@E 999,999,999") ,;
		aSrvExec[oLbRetorno:nAt,8] ,;
		aSrvExec[oLbRetorno:nAt,9] ,;
		aSrvExec[oLbRetorno:nAt,10] ,;
		aSrvExec[oLbRetorno:nAt,11] ,;
		Transform(aSrvExec[oLbRetorno:nAt,12], "@R 99:99 ") ,;
		Transform(aSrvExec[oLbRetorno:nAt,13], "@R 99:99 ") ,;
		Transform(aSrvExec[oLbRetorno:nAt,14], "@E 999,999,999.99 ") }}

	oLbRetorno:bGotFocus := {|| oLbPecas:nClrPane := CLR_HGRAY , oLbRetorno:nClrPane := CLR_WHITE }

	@ 080,001 TO 160,278 LABEL STR0014 OF oDlgRetorno PIXEL  //"Pecas"

	@ 085,002 LISTBOX oLbPecas FIELDS HEADER OemToAnsi(""),; // "Cod item"
		OemToAnsi(STR0045),; //"Grupo"
		OemToAnsi(STR0018),; //"Codigo"
		OemToAnsi(STR0019),; //"Descricao"
		OemToAnsi(STR0020),; //"Quantidade"
		OemToAnsi(STR0082); //"Valor"
		COLSIZES 10,30,70,70,40,40;
		SIZE 275,070 OF oDlgRetorno PIXEL

	FS_MOSTRAPEC(aSrvExec[1,8])

	oLbPecas:SetArray(aPecExec)
	oLbPecas:bLine := { || { "" ,;
		aPecExec[oLbPecas:nAt,3] ,;
		aPecExec[oLbPecas:nAt,4] ,;
		aPecExec[oLbPecas:nAt,5] ,;
		Transform(aPecExec[oLbPecas:nAt,6], "@E 999,999,999 ") ,;
		Transform(aPecExec[oLbPecas:nAt,7], "@E 999,999,999.99 ") }}

	oLbPecas:bGotFocus := {|| oLbPecas:nClrPane := CLR_WHITE , oLbRetorno:nClrPane := CLR_HGRAY }
	oLbPecas:nClrPane := CLR_HGRAY

	DEFINE SBUTTON FROM 160,203 TYPE 1 ACTION (FS_DESMARCA(cSrv,.t.),lRet := .t.,oDlgRetorno:End()) ENABLE OF oDlgRetorno
	DEFINE SBUTTON FROM 160,243 TYPE 2 ACTION (FS_DESMARCA(cSrv,.f.),lRet := .f.,oDlgRetorno:End()) ENABLE OF oDlgRetorno

	ACTIVATE MSDIALOG oDlgRetorno CENTER

Else

	Help("  ",1,"VOM030RET" )
	DbSelectArea(cSele)
	DbGoTo(nPosSele)
	Return(.f.)

EndIf


DbSelectArea(cSele)
DbGoTo(nPosSele)

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_MOSTRAPบAutor  ณFabio               บ Data ณ  08/01/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMostra pecas requisitadas na OS / Tipo de tempo             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณOficina                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_MOSTRAPEC(cNfi)

Local nPosReg := 0 , nx := 0

aPecExec := {}

nPosReg := Ascan(aTodasPec, { |x| x[2] == cNfi } )

Do While nPosReg > 0 .And. nPosReg <= Len(aTodasPec) .And. aTodasPec[nPosReg,2] == cNfi

	Aadd(aPecExec , Array( Len(aTodasPec[nPosReg]) ) )
	For nx := 1 to Len(aTodasPec[nPosReg])
		aPecExec[Len(aPecExec),nx] := aTodasPec[nPosReg,nx]
	Next

	nPosReg++

EndDo

If Len(aPecExec) == 0
	Aadd( aPecExec , {.f. , "" , "" , "" , "" , 0 , 0 } )
EndIf

oLbPecas:SetArray(aPecExec)
oLbPecas:bLine := { || { "" ,;
	aPecExec[oLbPecas:nAt,3] ,;
	aPecExec[oLbPecas:nAt,4] ,;
	aPecExec[oLbPecas:nAt,5] ,;
	Transform(aPecExec[oLbPecas:nAt,6], "@E 999,999,999 ") ,;
	Transform(aPecExec[oLbPecas:nAt,7], "@E 999,999,999.99 ") }}

oLbPecas:SetFocus()
oLbRetorno:SetFocus()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_DESMARCบAutor  ณFabio               บ Data ณ  08/01/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณDesmarca retorno de servico                                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณOficina                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_DESMARCA(cSrv,lOperacao)

Local nPosReg := 0

nPosReg := Ascan(aSrvRetorno,{ |x| x[3] == cSrv })

Do While nPosReg # 0 .And. nPosReg <= len(aSrvRetorno) .And. aSrvRetorno[nPosReg,3] == cSrv

	aSrvRetorno[nPosReg,2] := lOperacao

	nPosReg++

EndDo

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_CLICK  บAutor  ณFabio               บ Data ณ  08/02/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMarca vetor ao click no listbox                             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณOficina                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_CLICK()

Local ni := 0

For ni := 1 to Len(aSrvExec)

	If ni == oLbRetorno:nAt
		aSrvExec[ni,1] := !aSrvExec[ni,1]
	Else
		aSrvExec[ni,1] := .f.
	EndIf

	aSrvRetorno[Ascan(aSrvRetorno,{ |x| x[3]+x[4]+x[5]+x[6] == aSrvExec[ni,2]+aSrvExec[ni,3]+aSrvExec[ni,4]+aSrvExec[ni,15] }),1] := aSrvExec[ni,1]

Next

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_TRANSFPบAutor  ณFabio               บ Data ณ  09/18/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณTransfere peca de produtivo A p/ o B                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_TRANSFPEC(cCodSer,cCodPro,cNosNumSeq)

Local ni := 0 //, nPosVO2 := VO2->( RecNo() ) , nPosVO3 := VO3->( RecNo() )
Local lRet := .t.
Private aProdutivos := {}
Private oOk     := LoadBitmap( GetResources(), "LBTIK" )
Private oNo     := LoadBitmap( GetResources(), "LBNO" )

Default cNosNumSeq := ""

If Len(aPecasReq) == 0 .Or. Ascan( aPecasReq , { |x| x[1] == cNosNumSeq } ) == 0
	Return( lRet )
EndIf

// Valida se nao existe nenhum outro registro sem ser excluido.
For ni := 1 to Len( aCols )

	If aCols[ni,FG_POSVAR("VO4_CODSER")] == cCodSer .And. aCols[ni,FG_POSVAR("VO4_CODPRO")] == cCodPro .And. !aCols[ni,Len(aCols[ni])] .And. ni # n

		// Desmarca produtivo da transferencia de pecas.
		aPecasReq := FS_PECREQ( aPecasReq , cNosNumSeq , cCodSer , cCodPro , .f. )

		Return( lRet )

	EndIf

Next

For ni := 1 to Len(aCols)

	If !aCols[n,Len(aCols[n])]     // Adiciona produtivo para serem marcados para transferencia de pecas.
		If aCols[ni,FG_POSVAR("VO4_CODSER")] == cCodSer .And. aCols[ni,FG_POSVAR("VO4_CODPRO")] # cCodPro .And. !aCols[ni,Len(aCols[ni])]
			If Len( aProdutivos ) == 0 .Or. Ascan( aProdutivos , { |x| x[2] == cCodPro } ) == 0
				Aadd(aProdutivos, { If(Len(aProdutivos)==0,.t.,.f.) , aCols[ni,FG_POSVAR("VO4_CODPRO")] , Posicione("VAI", 1 , xFilial("VAI")+aCols[ni,FG_POSVAR("VO4_CODPRO")] ,"VAI_NOMTEC") , M->VO2_NOSNUM+aCols[ni,FG_POSVAR("VO4_SEQUEN")] } )
			EndIf
		EndIf
	EndIf

Next

If Len(aProdutivos) # 0

	// Tela do Retorno do Servico
	DEFINE MSDIALOG oDlgTransf FROM 001,000 TO 014,070 TITLE STR0083 OF oMainWnd //"Transferencia das pecas do servico agrupado"

	@ 004,002 LISTBOX oLbTransf FIELDS HEADER   OemToAnsi(""),; // "Cod item"
		OemToAnsi(STR0084),; //Codigo Produtivo
		OemToAnsi(STR0019);//Descricao
		COLSIZES 10,60,100;
		SIZE 275,80 OF oDlgTransf ON DBLCLICK (FS_MARPEC(),oLbTransf:Refresh()) PIXEL

	oLbTransf:SetArray(aProdutivos)
	oLbTransf:bLine := { || { If(aProdutivos[oLbTransf:nAt,1], oOk , oNo ) ,;
		aProdutivos[oLbTransf:nAt,2] ,;
		aProdutivos[oLbTransf:nAt,3] } }

	DEFINE SBUTTON FROM 85,203 TYPE 1 ACTION (FS_MARPEC(cCodSer,cCodPro),lRet := .t.,oDlgTransf:End()) ENABLE OF oDlgTransf
	DEFINE SBUTTON FROM 85,243 TYPE 2 ACTION (lRet := .f.,oDlgTransf:End()) ENABLE OF oDlgTransf

	ACTIVATE MSDIALOG oDlgTransf CENTER

Else

	// Desmarca produtivo da transferencia de pecas.
	aPecasReq := FS_PECREQ( aPecasReq , cNosNumSeq , cCodSer , cCodPro , .t. )

EndIf

Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_MARPEC บAutor  ณFabio               บ Data ณ  09/18/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_MARPEC( cCodSer , cCodPro )

Local ni := 0

If cCodSer == NIL .Or. cCodPro == NIL

	For ni := 1 to Len(aProdutivos)

		aProdutivos[ni,1] := If( ni # oLbTransf:nAt , .F. , .T. )

	Next

Else

	// Transfere peca do produtivo A p/ o B
	For ni := 1 to Len(aPecasReq)

		If aPecasReq[ ni , 2 ] == cCodSer .And. aPecasReq[ ni , 5 , Ascan( aPecasReq[ ni , 6] , "VO3_PROREQ" ) ] == cCodPro

			aPecasReq[ ni , 3 ] := aProdutivo[ Ascan( aProdutivo , { |x| x[1] == .t. } ) , 2 ]
			aPecasReq[ ni , 4 ] := aProdutivo[ Ascan( aProdutivo , { |x| x[1] == .t. } ) , 4 ]
			aPecasReq[ ni , 7 ] := .t.

		EndIf

	Next

EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_PECREQ บAutor  ณFabio               บ Data ณ  03/20/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMonta vetor com pecas requisitadas                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_PECREQ( aPecas , cNosNumSeq , cServico , cProdutivo , lMarca )

Local aPecReq := {}, nCount := 0

Default cNosNumSeq := ""
Default cServico   := ""
Default cProdutivo := ""
Default lMarca     := .f.

If aPecas == NIL

	aPecas := {}
	DbSelectArea("VO2")
	VO2->(DbSetOrder(1))
	VO2->(DbSeek( xFilial("VO2") + VO1->VO1_NUMOSV + "P" ))
	Do While !Eof() .And. VO2->VO2_NUMOSV == VO1->VO1_NUMOSV .And. VO2->VO2_TIPREQ == "P"

		DbSelectArea("VO3")
		VO3->(DbSetOrder(1))
		VO3->(DbSeek( xFilial("VO3") + VO2->VO2_NOSNUM ))
		Do While !Eof() .And. VO3->VO3_NOSNUM == VO2->VO2_NOSNUM

			nPosSrv := 0
			If Len(aPecReq) # 0
				nPosSrv := Ascan(aPecReq,{ |x| x[1] == VO3->VO3_CONSRV })
			EndIf

			If nPosSrv == 0

				Aadd(aPecReq, { VO3->VO3_CONSRV , "" , "" , "" , {} , {} , .f. } )
				nPosSrv := Len( aPecReq )

				For nCount := 1 to FCount()
					Aadd( aPecReq[ nPosSrv , 5 ] , FieldGet( nCount ) )
					Aadd( aPecReq[ nPosSrv , 6 ] , FieldName( nCount ) )
				Next

				Aadd( aPecReq[ nPosSrv , 5 ] , .f. )

			Else

				If VO2->VO2_DEVOLU == "0"
					aPecReq[ nPosSrv , 5 , Ascan(aPecReq[nPosSrv , 6], "VO3_QTDREQ" ) ] -= VO3->VO3_QTDREQ
				Else
					aPecReq[ nPosSrv , 5 , Ascan(aPecReq[nPosSrv , 6], "VO3_QTDREQ" ) ] += VO3->VO3_QTDREQ
				EndIf

			EndIf

			VO3->(DbSkip())

		EndDo

		VO2->(DbSkip())

	EndDo

	// Se o saldo da peca for zero despresa.
	For nCount := 1 to Len( aPecReq )

		If aPecReq[ nCount , 5 , Ascan( aPecReq[nCount , 6] , "VO3_QTDREQ" ) ] > 0
			Aadd( aPecas , aPecReq[nCount] )
		EndIf

	Next

ElseIf Len( aPecas ) # 0

	nPosSrv := Ascan( aPecas , { |x| x[1] == cNosNumSeq } )

	If nPosSrv # 0

		aPecas[ nPosSrv , 2 ] := cServico
		aPecas[ nPosSrv , 3 ] := cProdutivo
		aPecas[ nPosSrv , 4 ] := cNosNumSeq
		aPecas[ nPosSrv , 7 ] := lMarca

	EndIf

EndIf

Return( aPecas )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_FRANQUIบAutor  ณFabio               บ Data ณ  07/16/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCria linha para franquia                                    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_FRANQUIA( cTipTem )

Local nLinOri := n  , aArea := {}
Local _ni := 0

If VOI->VOI_SEGURO == "1"   // Tempo de Seguro

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Se existir o campo TPSEGU, foi aplicado o update contendo    ณ
	//ณ o novo tratamento para OS de Seguradora, entao nao deve      ณ
	//ณ ser feito a requisicao de franquia, pois ela ja deve ter sidoณ
	//ณ gerada                                                       ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	if VOI->(FieldPos("VOI_TPSEGU")) > 0
		Return .t.
	endif

	If Len(aSeguros) == 0 .Or. Ascan( aSeguros , { |x| x[1] == cTipTem } ) == 0

		If MsgYesNo(OemToAnsi(STR0085),OemToAnsi(STR0066))

			aArea := sGetArea(aArea , Alias())
			aArea := sGetArea(aArea , "VJ8")
			aArea := sGetArea(aArea , "VJ9")
			aArea := sGetArea(aArea , "VO6")
			aArea := sGetArea(aArea , "VO6")
			aArea := sGetArea(aArea , "VO7")
			aArea := sGetArea(aArea , "VOD")
			aArea := sGetArea(aArea , "VOI")
			aArea := sGetArea(aArea , "VOK")
			aArea := sGetArea(aArea , "VOK")
			aArea := sGetArea(aArea , "VOS")
			aArea := sGetArea(aArea , "VOX")
			aArea := sGetArea(aArea , "VV1")

			Aadd( aCols , Array(Len(aHeader)+1) )
			aCols[Len(aCols),Len(aHeader)+1]:=.F.

			For _ni:=1 to Len(aHeader)

				// verifica se e a coluna de controle do walk-thru
				If IsHeadRec(aHeader[_ni,2])
					aCols[Len(aCols),_ni] := 0
				ElseIf IsHeadAlias(aHeader[_ni,2])
					aCols[Len(aCols),_ni] := "VO4"
				Else
					aCols[Len(aCols),_ni] := CriaVar(aHeader[_ni,2])
				EndIf

			Next

			n := Len(aCols)
			FG_MEMVAR()

			aCols[Len(aCols),FG_POSVAR("VO4_TIPTEM")] := M->VO4_TIPTEM := VOI->VOI_TIPFRA
			If !( &( aHeader[FG_POSVAR("VO4_TIPTEM"),6] ) )
				aCols[Len(aCols),Len(aHeader)+1]		  := .T.
				MsgStop( STR0114+" "+VOI->VOI_TIPFRA ,STR0066)  //Tipo de tempo invalido ### Atencao!
			EndIf
			__ReadVar := 'M->VO4_GRUSER'
			aCols[Len(aCols),FG_POSVAR("VO4_GRUSER")] := M->VO4_GRUSER := VOI->VOI_GRUSER
			If !( &( aHeader[FG_POSVAR("VO4_GRUSER"),6] ) )
				aCols[Len(aCols),Len(aHeader)+1]		  := .T.
				MsgStop( STR0115+" "+VOI->VOI_GRUSER ,STR0066)  //Grupo de servico invalido ### Atencao!
			EndIf
			aCols[Len(aCols),FG_POSVAR("VO4_CODSER")] := M->VO4_CODSER := VOI->VOI_CODSER
			If !( &( aHeader[FG_POSVAR("VO4_CODSER"),6] ) )
				aCols[Len(aCols),Len(aHeader)+1]		  := .T.
				MsgStop( STR0116+" "+VOI->VOI_CODSER ,STR0066) //Servico invalido ### Atencao!
			EndIf
			aCols[Len(aCols),FG_POSVAR("VO4_TIPSER")] := M->VO4_TIPSER := VOI->VOI_TIPSER
			If !( &( aHeader[FG_POSVAR("VO4_TIPSER"),6] ) )
				aCols[Len(aCols),Len(aHeader)+1]		  := .T.
				MsgStop( STR0117+" "+VOI->VOI_TIPSER ,STR0066) //Tipo de Servico invalido ### Atencao!
			EndIf
			aCols[Len(aCols),FG_POSVAR("VO4_CODSEC")] := M->VO4_CODSEC := VOI->VOI_CODSEC
			If !( &( aHeader[FG_POSVAR("VO4_CODSEC"),6] ) )
				aCols[Len(aCols),Len(aHeader)+1]		  := .T.
				MsgStop( STR0118+" "+VOI->VOI_CODSEC ,STR0066) //Secao invalida ### Atencao!
			EndIf

			aCols[Len(aCols),FG_POSVAR("VO4_VALVEN")] := M->VO4_VALVEN := VO1->VO1_FRANQU

			Aadd( aSeguros , { cTipTem , VOI->VOI_TIPTEM , !aCols[Len(aCols),Len(aHeader)+1] } )

			Aadd(aAlter[1],{})
			Aadd(aAlter[1,Len(aAlter[1])], "VO4_IMPSUB" )
			For _ni := 1 to Len(aHeader)

				If aHeader[_ni,2] # "VO4_IMPSUB"
					Aadd(aAlter[1,Len(aAlter[1])], "  " )
				EndIf

			Next

			n := nLinOri
			aCols[n,FG_POSVAR("VO4_TIPTEM")] := M->VO4_TIPTEM := cTipTem
			FG_MEMVAR()

			// Volta posicoes originais
			sRestArea(aArea)

		EndIf

	EndIf

EndIf

Return( .t. )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_SRVFIN บAutor  ณFabio               บ Data ณ  09/25/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFlag final do servico                                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_SRVFIN()

Local nFin := 0
Local nY   := 0
Local lPergPausa := .f.

If lOM030Auto
	Return
EndIf

If FG_POSVAR("VO4_SRVFIN","aHeaderSrv") # 0
	For nFin:=1 to Len(aColsSrv)
		If aColsSrv[nFin,FG_POSVAR("VO4_CODSER","aHeaderSrv")] == aColsIniFim[n,FG_POSVAR("VO4_CODSER","aHeaderIniFim")]
			For nY := 1 to Len(aColsIniFim)
				if !aColsIniFim[nY,len(aColsIniFim[nY])]
				    if ny <> n
						If aColsIniFim[n,FG_POSVAR("VO4_CODSER","aHeaderIniFim")]  == aColsIniFim[nY,FG_POSVAR("VO4_CODSER","aHeaderIniFim")]
					    	if Empty(aColsIniFim[ny,9]) .or. aColsIniFim[ny,10] == 0
										lPergPausa := .t.
			    			Endif
			    		Endif
				    Endif
	 			Endif
			Next
			DbSelectArea("VOK")
			DbSetOrder(1)
			DbSeek(xFilial("VOK")+aColsSrv[nFin,FG_POSVAR("VO4_TIPSER","aHeaderSrv")])
			If !(VOK->VOK_INCMOB $ "2/5/6")
				If aColsSrv[nFin,FG_POSVAR("VO4_SRVFIN","aHeaderSrv")] # "0"  ;  // Sim Finalizado
					.And.	ReadVar() $ "M->VO4_HORINI"
					aColsSrv[nFin,FG_POSVAR("VO4_SRVFIN","aHeaderSrv")] := "0"
					If FG_POSVAR("VO4_MPAUSA","aHeaderSrv") # 0
					   M->VO4_MPAUSA := TamSx3("VO4_MPAUSA")[1]
					Endif
				EndIf
				If aColsSrv[nFin,FG_POSVAR("VO4_SRVFIN","aHeaderSrv")] # "1"  ;  // Nao Finalizado
					.And.	ReadVar() $ "M->VO4_HORFIN"
					//M->VO4_HORFIN := val(Substr(Time(),1,2)+Substr(Time(),4,2))
					If !lPergPausa .and. MsgYesNo(STR0089,OemToAnsi(STR0066) ) // Finalizar O Servi็o? / Aten็ใo
						aColsSrv[nFin,FG_POSVAR("VO4_SRVFIN","aHeaderSrv")] := "1"
					Else
						aColsSrv[nFin,FG_POSVAR("VO4_SRVFIN","aHeaderSrv")] := "0"
						VO4->(DbGoTo(aColsSrv[nFin,FG_POSVAR("VO4_REC_WT","aHeaderSrv")]))
						FS_PAUSASERV()
					EndIf
				EndIf
			EndIf
		EndIf
	Next
EndIf

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_030CHANGE      ณRicardo Farinelli   บ Data ณ  12/09/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValid se existem servicos no acols para que os mesmo possam บฑฑ
ฑฑบ          ณser apontados                                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao de concessionarias                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_030CHANGE()
Local lRet := .T.
Local nwnk := 0
Local lValid := .F.
Local lTipSSoc := .t.

If oFolder030:nOption == 1
	For nwnk := 1 To Len(aCols)
		If !aCols[nwnk,Len(aCols[nwnk])]
			lValid := .T.
			Exit
		Endif
	Next
Else
	lValid := .T.
Endif

If !lValid
	Help(" ",1,"OBRIGAT")
	lRet := .F.
	Return lRet
Endif

/*
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณRafael Goncalves - 15/01/2010                       ณ
//ณFNC -27650 - Valida se existir somente              ณ
//ณtipo de servico socorro nao deixa selecionar a pastaณ
//ณde apontamento. - Alexandre                         ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู*/
If oFolder030:nOption == 1 .and. lValid .and. lRet
	lTipSSoc := .f.
	For nwnk := 1 To Len(aCols)
		DbSelectArea("VOK")
		DbSetOrder(1)
		if dbSeek(xFilial("VOK")+aCols[nwnk,FG_POSVAR("VO4_TIPSER")])
			If VOK->VOK_INCMOB <> "5" .and. VOK->VOK_INCMOB <> "2" .and. VOK->VOK_INCMOB <> "6"
				lTipSSoc := .t.
				Exit
			Endif

		EndIf
	Next
EndIf
If lTipSSoc == .f.
	MsgInfo(STR0133,STR0066)//O tipo de servico nao necessita de apontamento ou nao existem servicos requisitados. # atencao
	Return .f.
EndIF

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_ADD3RD บAutor  ณRicardo Farinelli   บ Data ณ  12/09/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAdiciona num array de controle interno o status dos servicosบฑฑ
ฑฑบ          ณdo contas a pagar gerados anteriormente.                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao de Concessionarias                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_ADD3RD()

If !Empty(VO4->VO4_CODFOR) .and. !Empty(VO4->VO4_FOLOJA) .and. !Empty(VO4->VO4_TIPTIT) .and.;
	!Empty(VO4->VO4_NATURE) .and. !Empty(VO4->VO4_CODPAG) .and. !Empty(VO4->VO4_VALCUS) .and.;
	!Empty(VO4->VO4_NUMTIT) .and. !Empty(VO4->VO4_DATPAG)

	Aadd(aSrv3rd,{VO4->(Recno()),;
		VO4->VO4_CODFOR,;
		VO4->VO4_FOLOJA,;
		VO4->VO4_NUMTIT,;
		VO4->VO4_TIPTIT,;
		VO4->VO4_NATURE,;
		VO4->VO4_CODPAG,;
		VO4->VO4_VALCUS,;
		VO4->VO4_DATPAG})
Endif

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_030LINOK       ณRicardo Farinelli   บ Data ณ  12/09/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFaz a validacao da linha digitada pelo o usuario no caso de บฑฑ
ฑฑบ          ณservico de terceiros.                                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao de Concessionarias                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_030LINOK()
Local lret := .T.

FS_VETOR(1)

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_030LIN2        ณRicardo Farinelli   บ Data ณ  13/09/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFaz a validacao da linha digitada pelo o usuario no caso de บฑฑ
ฑฑบ          ณapontamento de servicos.                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao de Concessionarias                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_030LIN2()
Local lret := .T.
Local nPosDati:= FG_POSVAR("VO4_DATINI","AHEADERINIFIM")
Local nPosHori:= FG_POSVAR("VO4_HORINI","AHEADERINIFIM")
Local nPosDatf:= FG_POSVAR("VO4_DATFIN","AHEADERINIFIM")
Local nwnk := 1

For nwnk := 1 To Len(aColsIniFim)
	If aColsIniFim[nwnk,len(aColsIniFim[nwnk])]
		Loop
	Endif
	If (!Empty(aColsIniFim[nwnk,nPosDati]) .and. Empty(aColsIniFim[nwnk,nPosHori])) .or.;
		(Empty(aColsIniFim[nwnk,nPosDati]) .and. !Empty(aColsIniFim[nwnk,nPosHori])) .or.;
		(!Empty(aColsIniFim[nwnk,nPosDatf]) .and. Empty(aColsIniFim[nwnk,nPosDatf])) .or.;
		(Empty(aColsIniFim[nwnk,nPosDatf]) .and. !Empty(aColsIniFim[nwnk,nPosDatf])) .or.;
		(!Empty(aColsIniFim[nwnk,nPosDatf]) .and. !Empty(aColsIniFim[nwnk,nPosDatf])) .and.;
		(Empty(aColsIniFim[nwnk,nPosDati]) .or. Empty(aColsIniFim[nwnk,nPosHori]))

		Help(" ",1,"OBRIGAT",,OemToAnsi(STR0088),4,1)
		lRet := .F.
		Exit

	Endif
Next

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_ALTTP  บAutor  ณFabio               บ Data ณ  10/17/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida alteracao do tipo de tempo When                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FS_ALTTP()

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_PRODONLบAutor  ณfabio               บ Data ณ  01/04/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณConsulta produtivo                                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_PRODONLINE(cCodProOnLine,lAtiva)

Local oOficina := DMS_Oficina():New()
Local nI

Default cCodProOnLine:=""
Default lAtiva := .t.

If GetMv("MV_PONLINE") == "S"

	oTimeProdutivo:lActive := .f.
	aProdutivoOnLine := {}

	oOficina:GetHoras(dDataBase,dDataBase)
	aPrtvos  := oOficina:aProdutivos

	For nI := 1 to Len(aPrtvos)

		oPrdtv := aPrtvos[nI]
		Aadd(aProdutivoOnLine, {oPrdtv:cStatus,oPrdtv:cCodigo} )

	Next

	If Len(aProdutivoOnLine) == 0
		Aadd(aProdutivoOnLine, {"",""} )
	EndIf

	oLbProdutivo:SetArray(aProdutivoOnLine)
	oLbProdutivo:bLine := { || { If(Empty(aProdutivoOnLine[oLbProdutivo:nAt,1]),oBBranco, If(aProdutivoOnLine[oLbProdutivo:nAt,1]=="D",oBVerde,If(aProdutivoOnLine[oLbProdutivo:nAt,1]$"E/O",oBVermelho,If(aProdutivoOnLine[oLbProdutivo:nAt,1]=="A",oBAzul,oBPreto))) ) ,;
	aProdutivoOnLine[oLbProdutivo:nAt,2] }}
	oLbProdutivo:SetFocus()
	If xFlag == 0
		xFlag := 1
	Else
		oLbProdutivo:Refresh()
	Endif
	oGetIniFim:oBrowse:SetFocus()

	oTimeProdutivo:lActive := lAtiva

EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_SXENUM0บAutor  ณMicrosiga           บ Data ณ  10/15/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP6                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FS_SXENUM030(cNumOsv)

Local lFoundOs := .f.

Default cNumOsv := VO1->VO1_NUMOSV

DbSelectArea("VO2")
VO2->(DbSetOrder(1))
lFoundOs := VO2->(MsSeek( xFilial("VO2") + cNumOsv + "S" ))
If lFoundOS
	ALTERA := .t.
Else
	ALTERA := .f.
EndIf

VO2->(DbSetOrder(2))
Do While ( Empty(M->VO2_NOSNUM) .Or. ( VO2->(MsSeek( xFilial("VO2") + M->VO2_NOSNUM )) .And. VO2->VO2_NUMOSV # cNumOsv ) )

	If lFoundOs .And. !Empty(VO2->VO2_NOSNUM) .And. VO2->VO2_NUMOSV == cNumOsv
		M->VO2_NOSNUM := VO2->VO2_NOSNUM
	Else
		M->VO2_NOSNUM := GetSxeNum("VO2","VO2_NOSNUM",,2)
		ConfirmSx8()
	EndIf

EndDo

DbSelectArea("VO2")
VO2->(DbSetOrder(1))
VO2->(MsSeek( xFilial("VO2") + cNumOsv + "S" ))

Return(M->VO2_NOSNUM)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_APOUNICบAutor  ณFabio               บ Data ณ  07/02/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida apontamento se o mecanico nao esta trabalhando em    บฑฑ
ฑฑบ          ณnenhuma outra OS                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_APOUNICO()

Local aArea:={}
Local aDadosOs := {}
Local lRetorno := .t.
Local cAliasVO4 := "APOUNI"
Local cQuery    := ""

aArea := sGetArea(aArea , Alias())

If cMVAPOUNI == "S"

	// Verifica se o produtivo esta trabalhando em outra OS
	cQuery := "SELECT VO2.VO2_NUMOSV, "
	cQuery +=       " VO4.VO4_CODSER, VO4.VO4_CODPRO, VO4.VO4_DATINI, VO4.VO4_HORINI, VO4.VO4_DATFIN, VO4.VO4_HORFIN"
	cQuery += " FROM " + RetSqlName("VO4") + " VO4 "
	cQuery +=       " JOIN " + RetSQLName("VO2") + " VO2 "
	cQuery +=              "  ON VO2.VO2_FILIAL = '" + xFilial("VO2") + "'"
	cQuery +=              " AND VO2.VO2_NOSNUM = VO4.VO4_NOSNUM "
	cQuery +=              " AND VO2.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE VO4.VO4_FILIAL = '" + xFilial("VO4") + "' AND "
	cQuery +=      " VO4.VO4_CODPRO = '" + M->VO4_CODPRO + "' AND "
	cQuery +=      " VO4.VO4_DATDIS = ' ' AND "
	cQuery +=      " VO4.VO4_DATFEC = ' ' AND "
	cQuery +=      " VO4.VO4_DATCAN = ' ' AND "
	cQuery +=      " VO4.VO4_DATINI <>' ' AND VO4.VO4_DATFIN=' ' AND "
	cQuery +=      " VO4.VO4_NOSNUM = ' ' AND "
	cQuery +=      " VO4.VO4_CODSER = ' ' AND "
	cQuery +=      " VO4.D_E_L_E_T_ = ' ' "
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAliasVO4, .F., .T. )
	If !(cAliasVO4)->(Eof())
		Aadd(aDadosOs,(cAliasVO4)->(VO2_NUMOSV))
		Aadd(aDadosOs,(cAliasVO4)->(VO4_CODSER))
		Aadd(aDadosOs,(cAliasVO4)->(VO4_CODPRO))
		Aadd(aDadosOs,Stod((cAliasVO4)->(VO4_DATINI)))
		Aadd(aDadosOs,(cAliasVO4)->(VO4_HORINI))
		Aadd(aDadosOs,Stod((cAliasVO4)->(VO4_DATFIN)))
		Aadd(aDadosOs,(cAliasVO4)->(VO4_HORFIN))
	EndIf
	(cAliasVO4)->(dbCloseArea())
	DbSelectArea("VO4")
	//

	// Verifica se existe outro apontamento aberto na mesma OS
	nVO4CODPRO := FG_POSVAR("VO4_CODPRO")
	nVO4DATINI := FG_POSVAR("VO4_DATINI")
	nVO4DATFIN := FG_POSVAR("VO4_DATFIN")

	nHorAberta := Ascan( aCols , { |x| !x[Len(x)] .and. ;
	                                    X[Len(x)-1] > 0 .and. ; // Recno > 0
	                                    x[nVO4CODPRO] == M->VO4_CODPRO .and. ;
	                                    !Empty( x[nVO4DATINI] ) .and. ;
	                                    Empty( x[nVO4DATFIN] ) } )
	If nHorAberta <> 0 .and. nHorAberta <> n
		Aadd(aDadosOs,VO1->VO1_NUMOSV)
		Aadd(aDadosOs,aCols[nHorAberta,FG_POSVAR("VO4_CODSER")])
		Aadd(aDadosOs,aCols[nHorAberta,FG_POSVAR("VO4_CODPRO")])
		Aadd(aDadosOs,aCols[nHorAberta,FG_POSVAR("VO4_DATINI")])
		Aadd(aDadosOs,aCols[nHorAberta,FG_POSVAR("VO4_HORINI")])
		Aadd(aDadosOs,aCols[nHorAberta,FG_POSVAR("VO4_DATFIN")])
		Aadd(aDadosOs,aCols[nHorAberta,FG_POSVAR("VO4_HORFIN")])
	EndIf
	//

	If Len(aDadosOs) # 0
		Help( NIL, NIL, "M030HORABE", , STR0119 + CRLF +; //Produtivo com hora aberta!
													STR0120 + aDadosOs[1] + CRLF + ; // Nro Os....:
													STR0121 + aDadosOs[2] + CRLF + ;//Servico...
													STR0122 + aDadosOs[3] + CRLF + ;//Produtivo.:
													STR0123 + Transform(aDadosOs[4],"@D") + " " + Transform(aDadosOs[5],"@R 99:99") + CRLF + ;//Dt Inicial:
													STR0125 + Transform(aDadosOs[6],"@D") + " " + Transform(aDadosOs[7],"@R 99:99"), 1, 0 ) //Dt Final..:
		lRetorno := .f.
	EndIf
EndIf

sRestArea(aArea)

Return(lRetorno)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_VALTTIPบAutor  ณFabio               บ Data ณ  02/19/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida a alteracao do tipo de servico.                      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_VALTTIPSER(cTpSrvNov,cTpSrvAnt)

Local aArea := {} , cStatusNov := "" , cStatusAnt := ""

if empty(cTpSrvNov) .or. Empty(cTpSrvAnt)
	Return .t.
endif

If !Empty(Alias())
	aArea := sGetArea(aArea , Alias())
EndIf
aArea := sGetArea(aArea , "VOK")

DbSelectArea("VOK")
DbSetOrder(1)
DbSeek( xFilial("VOK") + cTpSrvAnt )

cStatusAnt := VOK->VOK_INCMOB

DbSelectArea("VOK")
DbSetOrder(1)
DbSeek( xFilial("VOK") + cTpSrvNov )

cStatusNov := VOK->VOK_INCMOB

If ((( cStatusNov == "2"  .And. cStatusAnt # "2"  ) .Or. ( cStatusNov # "2"  .And. cStatusAnt == "2"  ));
	.Or. (( cStatusNov == "5"  .And. cStatusAnt # "5"  ) .Or. ( cStatusNov # "5"  .And. cStatusAnt == "5"  ));
	.Or. (( cStatusNov == "6"  .And. cStatusAnt # "6"  ) .Or. ( cStatusNov # "6"  .And. cStatusAnt == "6"  )))

	Help("  ",1,"VALTTIPSER",,STR0091,4,1)
	sRestArea(aArea)
	Return(.F.)

EndIf

sRestArea(aArea)

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_VALVLRHOR บAutor  ณMicrosiga        บ Data ณ  06/27/05   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida alteracao no valor da hora                           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_VALVLRHOR()

Local nVlrHr := 0, nVlrHrI := 0, nVlrHrF := 0, nVlrHrP := 0
Local aStruct   := FWSX3Util():GetFieldStruct( "VO4_VALHOR" )
Local nDecimais := aStruct[4] // Decimais do Valor Hora
Local cMascara  := aStruct[5] // Mแscara do Valor Hora

If M->VO4_VALHOR <= 0
	Return( .f. )
EndIf

// Valida o percentual de variacao no preco da hora do servico.
nVlrHr    := FG_ValHor(M->VO4_TIPTEM,OM030TPVLSRV(M->VO4_TIPTEM,M->VO2_NOSNUM),,,VV1->VV1_CODMAR,M->VO4_CODSER,M->VO4_TIPSER,M->VO4_FATPAR,M->VO4_LOJA,VV1->VV1_MODVEI,VV1->VV1_SEGMOD,Iif(lMultMoeda, VO1->VO1_MOEDA, nil),Iif(lMultMoeda, VO1->VO1_TXMOED, nil))   // Valor da hora
nVlrHrP   := VOI->VOI_ALTVLR                                       						// Percentual de variacao
nVlrHrI   := 0                                                     						// Valor inicial com o percentual
nVlrHrF   := 0                                                     						// Valor final

If VOI->VOI_ALTVLR < 0
	nVlrHrP   := ( nVlrHrP * (-1) )
EndIf

nVlrHrI   := NoRound( ( nVlrHr - ( ( nVlrHr * nVlrHrP ) / 100 ) ) , nDecimais)
If nVlrHrI < 0
	nVlrHrI := 0
EndIf
nVlrHrF   := NoRound( ( nVlrHr + ( ( nVlrHr * nVlrHrP ) / 100 ) ) , nDecimais)

If ( M->VO4_VALHOR # nVlrHr .And. ( Empty(VOI->VOI_ALTVLR) .Or. ( M->VO4_VALHOR < nVlrHrI .Or. M->VO4_VALHOR > nVlrHrF ) ) )
	Help("  ",1,"M030VALHOR",,;
		STR0128 + ": " + AllTrim(Transform( M->VO4_VALHOR  ,cMascara)) + chr(13) + chr(10) + ; // "Valor informado"
		STR0129 + ": " + AllTrim(Transform( nVlrHr  ,cMascara)) + chr(13) + chr(10) + ; // "Valor da hora"
		STR0130 + ": " + AllTrim(Transform( VOI->VOI_ALTVLR ,"@E 9999")) + "%" + chr(13) + chr(10) + ; // "Percentual permitido"
		STR0131 + ": " + AllTrim(Transform( nVlrHrI ,cMascara))+ " / " + AllTrim(Transform( nVlrHrF ,cMascara)) ; // "Valor Min/Max permitido"
		,3,0)
	Return( .f. )

EndIf

Return(.t.)


/*
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณOM030LEG   ณ Autor ณ Fabio                ณ Data ณ 16/02/06 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Cria uma janela contendo a legenda da mBrowse              ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณofiom030                                                    ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OM030LEG(nReg)

Local uRetorno  := .t.
Local aLegenda  := {{ 'BR_VERDE'   , STR0093 },; // Aberta
					{ 'BR_AZUL'    , STR0094 },; // Liberada
					{ 'BR_VERMELHO', STR0095 },; // Fechado
					{ 'BR_PRETO'   , STR0096 }}  // Cancelado

// Pontos de Entrada para incluir tipos para legenda
If (ExistBlock("OM030CLG"))
    aLegenda := ExecBlock("OM030CLG", .f., .f., {aLegenda})
EndIf

If nReg == NIL // Chamada direta da fun็ใo onde nใo passa, via menu Recno ้ passado
    uRetorno := {}
    AADD(uRetorno, { 'VO1->VO1_STATUS == "A"', aLegenda[1,1], aLegenda[1,2] }) // Aberta
    AADD(uRetorno, { 'VO1->VO1_STATUS == "D"', aLegenda[2,1], aLegenda[2,2] }) // Liberada
    AADD(uRetorno, { 'VO1->VO1_STATUS == "F"', aLegenda[3,1], aLegenda[3,2] }) // Fechado
    AADD(uRetorno, { 'VO1->VO1_STATUS == "C"', aLegenda[4,1], aLegenda[4,2] }) // Cancelado

	If (ExistBlock("OM030COR"))
        uRetorno := ExecBlock("OM030COR", .f., .f., {uRetorno, aLegenda})
    EndIf
Else
    BrwLegenda(cCadastro, STR0097, aLegenda) //Legenda
EndIf

Return uRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_VALDPROบAutor  ณFabio               บ Data ณ  09/20/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida direito de manutencao do usuario                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FS_VALDPRO(cUsrLogado,cUsrSrv)

Local aArea := {}

iif(Empty(Alias()),DbSelectArea("VAI"),aArea := sGetArea(aArea,Alias()))
aArea := sGetArea(aArea,"VAI")

VAI->(DbSelectArea("VAI"))
VAI->(DbSetOrder(4))
If (! VAI->(MsSeek( xFilial("VAI") + cUsrLogado )) .Or. (VAI->VAI_CODTEC # cUsrSrv .And. VAI->VAI_ALTAPO # "1") )

	MsgStop(STR0098,STR0066) //Usuario nao autoriazado # Atencao

	// Volta posicoes originais
	sRestArea(aArea)

	Return(.F.)

EndIf
// Volta posicoes originais
sRestArea(aArea)

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_VLDFASEบAutor  ณFabio               บ Data ณ  09/20/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida direito de manutencao do usuario na fase             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FS_VLDFASE(cUsrLogado)

Local aArea := {}

aArea := sGetArea(aArea,Alias())
aArea := sGetArea(aArea,"VAI")

DbSelectArea("VAI")
DbSetOrder(4)
If (!DbSeek( xFilial("VAI") + cUsrLogado ) .Or. (VAI->VAI_ALTFAS # "1") )

	MsgStop(STR0098,STR0066) //Usuario nao autoriazado! # Atencao!

	// Volta posicoes originais
	sRestArea(aArea)

	Return(.F.)

EndIf


// Volta posicoes originais
sRestArea(aArea)

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ FS_VALFASE บAutor  ณMicrosiga         บ Data ณ  09/26/06   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_VALFASE()

Local nCont    := 0
Local nTotPad  := 0
Local nTotFas  := 0
Local aCSrv    := {}
Local aCIniFin := {}

// Temporario
// Verificar se realmente nao deve validar o tempo trabalhado com relacao ao tempo padrao do servico
If lOM030Auto
	Return .t.
EndIf

aCSrv    := aClone(aCols)
aCIniFin := aClone(aColsIniFim)
If oFolder030:nOption==2
	aCSrv    := aClone(aColsSrv)
	aCIniFin := aClone(aCols)
EndIf

For nCont := 1 to Len(aCSrv)

	If !aCSrv[nCont,Len(aCSrv[nCont])]
		nTotPad += aCSrv[nCont,FG_POSVAR("VO4_TEMPAD","aHeaderSrv")]
	EndIf

Next

For nCont := 1 to Len(aCIniFin)

	If !aCIniFin[nCont,Len(aCIniFin[nCont])]
		nTotFas += aCIniFin[nCont,FG_POSVAR("VO4_TEMFAS","aHeaderIniFin")]
	EndIf

Next

If nTotPad < nTotFas
	MsgStop(STR0099+Transform(nTotFas,"@R 9999:99")+STR0100+Transform(nTotPad,"@R 9999:99")+")!",STR0066) //Tempo total da fase( # ) maior que o tempo total padrao( # Atencao!
	Return(.f.)
EndIf

Return(.t.)

Function FS_WTFAS()

Local nCont    := 0

For nCont := 1 to Len(aCols)

	If Empty(aCols[n,FG_POSVAR("VO4_TEMFAS","aHeaderIniFin")])

		If nCont # n ;
			.And. aCols[nCont,FG_POSVAR("VO4_CODSER","aHeaderIniFin")] == aCols[n,FG_POSVAR("VO4_CODSER","aHeaderIniFin")] ;
			.And. aCols[nCont,FG_POSVAR("VO4_GRUSER","aHeaderIniFin")] == aCols[n,FG_POSVAR("VO4_GRUSER","aHeaderIniFin")] ;
			.And. aCols[nCont,FG_POSVAR("VO4_CODFAS","aHeaderIniFin")] == aCols[n,FG_POSVAR("VO4_CODFAS","aHeaderIniFin")] ;
			.And. !Empty(aCols[nCont,FG_POSVAR("VO4_TEMFAS","aHeaderIniFin")])

			Return(.f.)

		EndIf

	EndIf

Next

Return(.t.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_ALTTPREบAutor  ณFabio               บ Data ณ  09/17/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida alteracao do tipo de tempo                          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_ALTTPREQ()

if ExistBlock("ALTTPREQ")
	Return( ExecBlock("ALTTPREQ",.f.,.f.) )
Endif

Return(.t.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ MenuDef  บAutor  ณFabio               บ Data ณ  09/17/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Definicao do Menu da mBrowse                               บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MenuDef()
Local aRotina := {}
Local aNovBot := {}

AADD(aRotina, { STR0001           , "axPesqui", 0, 1})         // Pesquisar
AADD(aRotina, { STR0002           , "OM030"   , 0, 3})         // Requisitar
AADD(aRotina, { STR0003           , "OM030A"  , 0, 3})         // Alterar
AADD(aRotina, { STR0214			  , "OM0300122_ChamaAPPApontamentoPorTarefa", 0, 3})
//AADD(aRotina, { "Apontamento Automatico"           , "OM030APAUT"   , 0, 4})         // Requisitar
AADD(aRotina, { OemToAnsi(STR0097), "OM030LEG", 0, 4, 2, .f.}) // Legenda

If FindFunction("OFA1100056_RelacionaCampanha")
	AADD(aRotina, {STR0178, "OFA1100056_RelacionaCampanha", 0 , 2}) // Relacionar Campanha
EndIf

If !funname() == "OFIOM030"
	AADD(aRotina, { STR0147, "OM030V", 0, 1}) // Pesq.Avancada
EndIf

If ExistBlock("OM030ROT")
	If ValType( aNovBot := ExecBlock("OM030ROT", .f., .f.) ) == "A"
		aEval( aNovBot , { | x | aAdd( aRotina , x ) } )
	EndIf
Endif

Return aRotina

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ OM030APAUT บAutor  ณFabio             บ Data ณ  09/17/07   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Apontamento Automatico                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OM030APAUT()
	OM030APONT(VO1->VO1_NUMOSV)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณOM030APONTบAutor  ณFabio               บ Data ณ  10/09/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณInicializa e finalisa servico                               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OM030APONT(cNumOsv)

Local aTipTem := {}
Local nOpcOk := 0
Local aSizeAut, aObjects := {}, aInfo := {}, aPosObj
Local oFont := TFont():New( "System", 10, 24 )


Local cProdutivo := Space(TamSX3("VO4_CODPRO")[1])

Private nHora := 0
Private oOk := LoadBitmap( GetResources(), "LBOK" )
Private oNo := LoadBitmap( GetResources(), "LBNO" )
Private oBVerde     := LoadBitmap( GetResources(), "BR_VERDE" )
Private oBVermelho  := LoadBitmap( GetResources(), "BR_VERMELHO" )
Private oBBranco    := LoadBitmap( GetResources(), "BR_BRANCO" )
Private aNewBot := { {"PMSCOLOR", {|| BrwLegenda(STR0138,STR0097,{ {"BR_BRANCO" ,STR0144},{"BR_VERMELHO",STR0145},{"BR_VERDE" ,STR0146} } ) } , STR0097 }} // Apontamento de Servi็o / Legenda / Sem apontamento / Em Andamento / Finalizado / Legenda
Private aIncTipTem := {}

Private cNomProdut := Space(TamSX3("VO4_NOMPRO")[1])

Private AVETPERC := {}

Default cNumOsv := ""

DbSelectArea("VO1")
DbSetOrder(1)
If !DbSeek( xFilial("VO1") + cNumOsv )
	Return(.f.)
EndIf

// Levanta registros
OM030LEVREG(@aTipTem,cNumOsv)

If Len(aTipTem) # 0

	aSizeAut := MsAdvSize(.t.)

	DEFINE MSDIALOG oApontAut TITLE STR0138 From aSizeAut[7],00 to aSizeAut[6],aSizeAut[5] PIXEL of oMainWnd

	// Configura os tamanhos dos objetos
	aObjects := {}
	AAdd( aObjects, { 100, 003, .T., .F. } ) // Espacamento TOP
	AAdd( aObjects, { 100, 050, .T., .T. } ) // Listbox TT
	AAdd( aObjects, { 100, 016, .T., .F. } ) // Espacamento Bottom
	aInfo := {aSizeAut[1] , aSizeAut[2] , aSizeAut[3] , aSizeAut[4] , 1 , 1 }
	aPosObj := MsObjSize (aInfo, aObjects, .t.)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณListbox de Servicos por TT e TSณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	TGroup():New(aPosObj[2,1],aPosObj[2,2]+1,aPosObj[2,3],aPosObj[2,4]-1,STR0013,oApontAut,,,.t.) // Servi็os

	@ aPosObj[2,1]+11,aPosObj[2,2]+04 SAY AllTrim(RetTitle("VO4_CODPRO")) of oApontAut PIXEL
	@ aPosObj[2,1]+10,aPosObj[2,2]+30 MSGET oProdutivo VAR cProdutivo PICTURE PesqPict("VO4","VO4_CODPRO") VALID OM030VALPR(cProdutivo) F3 "A1C" OF oApontAut SIZE 40,1 PIXEL HASBUTTON
	@ aPosObj[2,1]+10,aPosObj[2,2]+80 MSGET oNomProdut VAR cNomProdut WHEN .F. OF oApontAut SIZE 250,1 PIXEL HASBUTTON

	oLbTipTem := TWBrowse():New(aPosObj[2,1]+25,aPosObj[2,2]+04,(aPosObj[2,4]-aPosObj[2,2]-08),(aPosObj[2,3]-aPosObj[2,1]-30),,,,oApontAut,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
	oLbTipTem:nAT := 1
	oLbTipTem:SetArray(aTipTem)
	oLbTipTem:addColumn( TCColumn():New( "" , { || IIf(oLbTipTem:aArray[oLbTipTem:nAt,APOAUT_SEL],oOk,oNo) } 					,,,,"LEFT" ,05,.T.,.F.,,,,.F.,) )
	oLbTipTem:addColumn( TCColumn():New( ""	, { || IIf( "0" $ oLbTipTem:aArray[oLbTipTem:nAt,APOAUT_STATUS],oBBranco,IIf( "1" $ oLbTipTem:aArray[oLbTipTem:nAt,APOAUT_STATUS],oBVermelho,oBVerde)) } ,,,,"LEFT" ,05,.T.,.F.,,,,.F.,) )
	if lInconveniente
		oLbTipTem:addColumn( TCColumn():New( iif( lAltInconv, OX001066K_AlteraDescricaoInconveniente("VO4_SEQINC"), retTitle('VO4_SEQINC') ) , { || oLbTipTem:aArray[oLbTipTem:nAt,APOAUT_SEQINC]} ,,,,"LEFT" ,20,.F.,.F.,,,,.F.,) )
		oLbTipTem:addColumn( TCColumn():New( iif( lAltInconv, OX001066K_AlteraDescricaoInconveniente("VO4_GRUINC"), retTitle('VO4_GRUINC') ) , { || oLbTipTem:aArray[oLbTipTem:nAt,APOAUT_GRUINC]} ,,,,"LEFT" ,30,.F.,.F.,,,,.F.,) )
		oLbTipTem:addColumn( TCColumn():New( iif( lAltInconv, OX001066K_AlteraDescricaoInconveniente("VO4_CODINC"), retTitle('VO4_CODINC') ) , { || oLbTipTem:aArray[oLbTipTem:nAt,APOAUT_CODINC]} ,,,,"LEFT" ,40,.F.,.F.,,,,.F.,) )
		oLbTipTem:addColumn( TCColumn():New( iif( lAltInconv, OX001066K_AlteraDescricaoInconveniente("VO4_DESINC"), retTitle('VO4_DESINC') ) , { || oLbTipTem:aArray[oLbTipTem:nAt,APOAUT_DESINC]} ,,,,"LEFT" ,70,.F.,.F.,,,,.F.,) )
	endif
	oLbTipTem:addColumn( TCColumn():New( AllTrim(RetTitle("VO4_TIPTEM")) , { || oLbTipTem:aArray[oLbTipTem:nAt,APOAUT_TIPTEM]} ,,,,"LEFT" ,40,.F.,.F.,,,,.F.,) )
	oLbTipTem:addColumn( TCColumn():New( AllTrim(RetTitle("VOI_DESTTE")) , { || oLbTipTem:aArray[oLbTipTem:nAt,APOAUT_DESCTIPTEM]} ,,,,"LEFT" ,70,.F.,.F.,,,,.F.,) )
	oLbTipTem:addColumn( TCColumn():New( AllTrim(RetTitle("VO4_TIPSER")) , { || oLbTipTem:aArray[oLbTipTem:nAt,APOAUT_TIPSER]} ,,,,"LEFT" ,40,.F.,.F.,,,,.F.,) )
	oLbTipTem:addColumn( TCColumn():New( AllTrim(RetTitle("VOK_DESSER")) , { || oLbTipTem:aArray[oLbTipTem:nAt,APOAUT_DESTIPSER]} ,,,,"LEFT" ,70,.F.,.F.,,,,.F.,) )
	oLbTipTem:bLDblClick := { || OM030ALTTIK(@aTipTem, @oLbTipTem) }
	oLbTipTem:Refresh()

	oTPanelBOTTOM := TPanel():New(aPosObj[Len(aPosObj),1],aPosObj[Len(aPosObj),2],, oApontAut, , , , , , aPosObj[Len(aPosObj),4]-aPosObj[Len(aPosObj),2], aPosObj[Len(aPosObj),3]-aPosObj[Len(aPosObj),1],,)
	@ 005,005 SAY STR0137 Font oFont OF oTPanelBOTTOM PIXEL COLOR CLR_HBLUE //Hora.:
	@ 005,040 SAY oHora VAR nHora Font oFont PICTURE "@R 99:99" OF oTPanelBOTTOM PIXEL COLOR CLR_HBLUE

	// Timer para Atualizar a Hora
	nHora := Val(Substr(Time(),1,2)+Substr(Time(),4,2))
	DEFINE TIMER oTime INTERVAL 20 ACTION (nHora := Val(Substr(Time(),1,2)+Substr(Time(),4,2)), oHora:Refresh()) OF oApontAut
	oTime:lActive := .t.
	//

	ACTIVATE MSDIALOG oApontAut ON INIT EnchoiceBar(oApontAut,{ || If(OM030GRVAPO(@aTipTem,cNumOsv,cProdutivo),nOpcOk := 1,nOpcOk := 0) }, { || oApontAut:End() },,aNewBot)

Else

	MsgStop(STR0143,STR0066) //Nao existe tipo de tempo com apontamento automatico para ordem de servico! # Atencao!

EndIf

Return( (nOpcOk == 1) )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณOM030VALPR  บAutor  ณRubens Takahashi  บ Data ณ  01/29/10   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Validacao da GET de Produtivo                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function OM030VALPR(cProdutivo)
Local lRetorno := .t.
Local aAreaVAI

cNomProdut := ""

If !Empty(cProdutivo)
	aAreaVAI := VAI->(GetArea())
	VAI->(dbSetOrder(1))
	If !VAI->(dbSeek(xFilial("VAI") + cProdutivo))
		Help(" ",1,"REGNOIS",,RetTitle("VAI_CODTEC") + ": "+ cProdutivo ,4,1)
		lRetorno := .f.
	EndIf
	cNomProdut := VAI->VAI_NOMTEC
	If lRetorno .and. VAI->VAI_FUNPRO <> "1"
		MsgInfo(STR0154) // "T้cnico nใo ้ um produtivo"
		lRetorno := .f.
	EndIf
	//If !OM030ProFil(aCols[ni,FG_POSVAR("VO4_CODPRO")], aCols[ni,FG_POSVAR("VO4_DATINI")], !(aCols[ni,FG_POSVAR("VO4_CODPRO")] $ cProdProc) )
	//	cProdProc += aCols[ni,FG_POSVAR("VO4_CODPRO")]
	//	Return .f.
	//EndIf
	RestArea(aAreaVAI)
EndIf

oNomProdut:Refresh()

Return lRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณOM030ALTTIK บAutor  ณMicrosiga         บ Data ณ  01/29/10   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Seleciona um servico para apontamento automatico           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function OM030ALTTIK(aParArray, oParLBox)

Local nAltTik := 0

For nAltTik := 1 to Len(aParArray)

	If nAltTik # oParLBox:nAt
		aParArray[nAltTik,1] := .f.
	EndIf

Next

aParArray[oParLBox:nAt,1] := !aParArray[oParLBox:nAt,1]

oParLBox:Refresh()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ OM030LEVREG  บAutor  ณ Rubens Takahashi  บ Data ณ 28/01/10 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Seleciona os TT e TS para serem exibidos na tela de apont. บฑฑ
ฑฑบ          ณ automatico                                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function OM030LEVREG(aTipTem,cNumOsv,cTipTem,cTipSrvc,cSeqInc)

Local aArea  := {}
Local nAuxPos
local nParam := 1
Local cAlLevReg
Local cQuery

Default cTipTem  := ""
Default cTipSrvc := ""
Default cSeqInc := ""

aArea := sGetArea(aArea , Alias())
aArea := sGetArea(aArea , "VO2")
aArea := sGetArea(aArea , "VO4")

If Empty(cTipTem)
	aTipTem := {}
Else
	nAuxPos := 1
	// Remove todos as linhas da matriz com o mesmo TT/Tipo de Servico
	While nAuxPos <= Len(aTipTem)
		If aTipTem[nAuxPos,03] == cTipTem .and. (Empty(cTipSrvc) .or. (!Empty(cTipSrvc) .and. aTipTem[nAuxPos,11] == cTipSrvc ))
			aDel(aTipTem,nAuxPos)
			aSize(aTipTem, Len(aTipTem) - 1 )
		EndIf
		nAuxPos++
	End
	//
EndIf

cQuery := " SELECT VO4.R_E_C_N_O_ VO4RECNO, VOK.R_E_C_N_O_ VOKRECNO, VOI.R_E_C_N_O_ VOIRECNO "
cQuery +=  " FROM " + RetSQLName("VO2") + " VO2 "
cQuery +=  " JOIN " + RetSQLName("VO4") + " VO4 ON VO4.VO4_FILIAL = VO2.VO2_FILIAL AND VO2.VO2_NOSNUM = VO4.VO4_NOSNUM AND VO4.D_E_L_E_T_ = ' ' "
cQuery +=  " JOIN " + RetSQLName("VOI") + " VOI ON VOI.VOI_FILIAL = '" + FWxFilial("VOI") + "' AND VOI.VOI_TIPTEM = VO4.VO4_TIPTEM AND VOI.D_E_L_E_T_ = ' ' "
cQuery +=  " JOIN " + RetSQLName("VOK") + " VOK ON VOK.VOK_FILIAL = '" + FWxFilial("VOK") + "' AND VOK.VOK_TIPSER = VO4.VO4_TIPSER AND VOK.D_E_L_E_T_ = ' ' "
cQuery +=  " AND VOK.VOK_INCMOB NOT IN ('2','5','6') "
cQuery +=  " WHERE VO2.VO2_FILIAL = '" + FWxFilial("VO2") + "' "
cQuery +=    " AND VO2.VO2_NUMOSV = ? "
cQuery +=    " AND VO2.VO2_TIPREQ = 'S' "
cQuery +=    " AND VO2.D_E_L_E_T_ = ' ' "

if !Empty(cTipTem)
	cQuery += " AND VO4.VO4_TIPTEM = ? "
Endif

if !Empty(cTipSrvc)
	cQuery += " AND VO4.VO4_TIPSER = ? "
endif

if lInconveniente .and. ! empty(cSeqInc)
	cQuery += " AND VO4.VO4_SEQINC = ?"
endif
cQuery += " ORDER BY VO4.VO4_DATINI , VO4.VO4_HORINI, VO4.VO4_SEQINC, VO4.VO4_CODSER"

oOM030Statement:setQuery(cQuery)
oOM030Statement:setString(nParam++, VO1->VO1_NUMOSV )

if !Empty(cTipTem)
	oOM030Statement:setString(nParam++, cTipTem)
Endif

if !Empty(cTipSrvc)
	oOM030Statement:setString(nParam++, cTipSrvc)
endif

if lInconveniente .and. ! empty(cSeqInc)
	oOM030Statement:setIn(nParam++, cSeqInc)
endif

cAlLevReg  := MPSysOpenQuery(oOM030Statement:getFixQuery())

While !(cAlLevReg)->(Eof())

	VO4->(dbGoTo((cAlLevReg)->VO4RECNO))
	VOK->(dbGoTo((cAlLevReg)->VOKRECNO))
	VOI->(dbGoTo((cAlLevReg)->VOIRECNO))

	// So considera servico em ABERTO e que o Tipo de Cobranca nao seja Srvc de Terceiro/Socorro/Franquia
	If Empty(VO4->VO4_DATDIS) .And. Empty(VO4->VO4_DATFEC) .And. Empty(VO4->VO4_DATCAN)

		nPosTp := Ascan(aTipTem, {|x| x[APOAUT_SEQINC] == VO4->VO4_SEQINC .and. x[APOAUT_TIPTEM] == VO4->VO4_TIPTEM .and. x[APOAUT_TIPSER] == VO4->VO4_TIPSER })
		If nPosTp == 0

			AADD( aTipTem , Array(16) )
			nPosTp := Len(aTipTem)
			aTipTem[ nPosTp , APOAUT_SEL        ] := .f.
			aTipTem[ nPosTp , APOAUT_STATUS     ] := "0" // Sem Apontamento
			aTipTem[ nPosTp , APOAUT_TIPTEM     ] := VO4->VO4_TIPTEM
			aTipTem[ nPosTp , APOAUT_DESCTIPTEM ] := VOI->VOI_DESTTE
			aTipTem[ nPosTp , APOAUT_VO4RECNO   ] := VO4->(RecNo())
			aTipTem[ nPosTp , APOAUT_DATINI     ] := VO4->VO4_DATINI
			aTipTem[ nPosTp , APOAUT_HORINI     ] := VO4->VO4_HORINI
			aTipTem[ nPosTp , APOAUT_DATFIM     ] := VO4->VO4_DATFIN
			aTipTem[ nPosTp , APOAUT_HORFIM     ] := VO4->VO4_HORFIN
			aTipTem[ nPosTp , APOAUT_ARRAY_VO4  ] := {} // Agrupa todos os servicos com mesmo TT e TS
			aTipTem[ nPosTp , APOAUT_TIPSER     ] := VO4->VO4_TIPSER
			aTipTem[ nPosTp , APOAUT_DESTIPSER  ] := VOK->VOK_DESSER
			aTipTem[ nPosTp , APOAUT_SEQINC     ] := VO4->VO4_SEQINC
			aTipTem[ nPosTp , APOAUT_GRUINC     ] := ""
			aTipTem[ nPosTp , APOAUT_CODINC     ] := ""
			aTipTem[ nPosTp , APOAUT_DESINC     ] := ""

			if lInconveniente .and. !Empty(VO4->VO4_SEQINC)
				aAuxInconv := OM420CONSINC( "2" , VO4->VO4_NUMOSV , VO4->VO4_SEQINC )
				aTipTem[ nPosTp , APOAUT_GRUINC ] := aAuxInconv[1] // Inconveniente - Grupo
				aTipTem[ nPosTp , APOAUT_CODINC ] := aAuxInconv[2] // Inconveniente - Codigo
				aTipTem[ nPosTp , APOAUT_SEQINC ] := aAuxInconv[4] // Inconveniente - Sequencia
				aTipTem[ nPosTp , APOAUT_DESINC ] := aAuxInconv[3] // Inconveniente - Descricao
			endif

		endif

		If !( aTipTem[nPosTp,APOAUT_STATUS] $ "1/2") .And. ( !Empty(VO4->VO4_DATINI) .And. !Empty(VO4->VO4_DATFIN) )
			aTipTem[ nPosTp , APOAUT_STATUS   ] := "2"	// Tipo de Tempo ja FINALIZADO
			aTipTem[ nPosTp , APOAUT_VO4RECNO ] := VO4->(RecNo())
			aTipTem[ nPosTp , APOAUT_DATINI   ] := VO4->VO4_DATINI
			aTipTem[ nPosTp , APOAUT_HORINI   ] := VO4->VO4_HORINI
			aTipTem[ nPosTp , APOAUT_DATFIM   ] := VO4->VO4_DATFIN
			aTipTem[ nPosTp , APOAUT_HORFIM   ] := VO4->VO4_HORFIN
		ElseIf ( !Empty(VO4->VO4_DATINI) .And. Empty(VO4->VO4_DATFIN) )
			aTipTem[ nPosTp , APOAUT_STATUS   ] := "1"	// Marca Tipo de Tempo como em ANDAMENTO
			aTipTem[ nPosTp , APOAUT_VO4RECNO ] := VO4->(RecNo())
			aTipTem[ nPosTp , APOAUT_DATINI   ] := VO4->VO4_DATINI
			aTipTem[ nPosTp , APOAUT_HORINI   ] := VO4->VO4_HORINI
			aTipTem[ nPosTp , APOAUT_DATFIM   ] := VO4->VO4_DATFIN
			aTipTem[ nPosTp , APOAUT_HORFIM   ] := VO4->VO4_HORFIN
		EndIf

		// Adiciona na posicao 10 todos os servicos com mesmo TT e TS
		nPosSrv := Ascan(aTipTem[nPosTp,APOAUT_ARRAY_VO4], {|x| x[APOAUT_ARRAY_VO4_CODSER] == VO4->VO4_CODSER .and. x[APOAUT_ARRAY_VO4_GRUSER] == VO4->VO4_GRUSER })
		If nPosSrv == 0

			AADD( aTipTem[nPosTp,APOAUT_ARRAY_VO4], Array(09) )
			nPosSrv := Len(aTipTem[nPosTp,APOAUT_ARRAY_VO4])
			aTipTem[nPosTp , APOAUT_ARRAY_VO4 , nPosSrv , APOAUT_ARRAY_VO4_CODSER ] := VO4->VO4_CODSER
			aTipTem[nPosTp , APOAUT_ARRAY_VO4 , nPosSrv , APOAUT_ARRAY_VO4_TEMPAD ] := VO4->VO4_TEMPAD
			aTipTem[nPosTp , APOAUT_ARRAY_VO4 , nPosSrv , APOAUT_ARRAY_VO4_RECNO  ] := VO4->(RecNo())
			aTipTem[nPosTp , APOAUT_ARRAY_VO4 , nPosSrv , APOAUT_ARRAY_VO4_DATINI ] := Ctod("  /  /  ")	// Data inicial do Apontamento
			aTipTem[nPosTp , APOAUT_ARRAY_VO4 , nPosSrv , APOAUT_ARRAY_VO4_HORINI ] := 0					// Hora incial do Apontamento
			aTipTem[nPosTp , APOAUT_ARRAY_VO4 , nPosSrv , APOAUT_ARRAY_VO4_DATFIN ] := Ctod("  /  /  ")	// Data final do apontamento
			aTipTem[nPosTp , APOAUT_ARRAY_VO4 , nPosSrv , APOAUT_ARRAY_VO4_HORFIN ] := 0					// Hora final do apontamento
			aTipTem[nPosTp , APOAUT_ARRAY_VO4 , nPosSrv , APOAUT_ARRAY_VO4_GRUSER ] := VO4->VO4_GRUSER
			aTipTem[nPosTp , APOAUT_ARRAY_VO4 , nPosSrv , APOAUT_ARRAY_VO4_CODPRO ] := ""

		EndIf

		// Se nao tiver sido finalizado o apontamento
		If ( Empty(VO4->VO4_DATINI) .Or. Empty(VO4->VO4_DATFIN) )
			aTipTem[nPosTp , APOAUT_ARRAY_VO4 , nPosSrv , APOAUT_ARRAY_VO4_RECNO  ] := VO4->(RecNo())
			aTipTem[nPosTp , APOAUT_ARRAY_VO4 , nPosSrv , APOAUT_ARRAY_VO4_DATINI ] := VO4->VO4_DATINI
			aTipTem[nPosTp , APOAUT_ARRAY_VO4 , nPosSrv , APOAUT_ARRAY_VO4_HORINI ] := VO4->VO4_HORINI
			aTipTem[nPosTp , APOAUT_ARRAY_VO4 , nPosSrv , APOAUT_ARRAY_VO4_DATFIN ] := VO4->VO4_DATFIN
			aTipTem[nPosTp , APOAUT_ARRAY_VO4 , nPosSrv , APOAUT_ARRAY_VO4_HORFIN ] := VO4->VO4_HORFIN
			aTipTem[nPosTp , APOAUT_ARRAY_VO4 , nPosSrv , APOAUT_ARRAY_VO4_CODPRO ] := VO4->VO4_CODPRO
		EndIf

	EndIf

	(cAlLevReg)->(DbSkip())

EndDo

(cAlLevReg)->(DbCloseArea())


If Len(aTipTem) > 0
	aSort( aTiptem ,,, { |x,y| x[APOAUT_SEQINC] + x[APOAUT_TIPTEM] + x[APOAUT_TIPSER] < y[APOAUT_SEQINC] + y[APOAUT_TIPTEM] + y[APOAUT_TIPSER] } )
EndIf

sRestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ OM030GRVAPO  บAutor  ณ Rubens Takahashi  บ Data ณ 28/01/10 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Grava o apontamento automatico                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function OM030GRVAPO(aTipTem,cNumOsv,cProdutivo)

Local aSrv := {}
Local nAponta := 0, nEscala := 0, nSrv := 0, nTotTem := 0, nTotPad := 0, nPerTem := 0



Local aAreaVAI := VAI->(GetArea())
Local cAuxTipTem
Local cAuxTipSer
Local cAuxSeqInc
Local cAuxSitTT
Local lErro := .f.
Local cAuxProdut := ""
local cProdProc := ""
Local jMecTempoTrab := jsonObject():new()

// Desabilita atualizacao da hora
oTime:lActive := .f.

// Procura a linha da matriz com o TT selecionado para apontamento
nAponta := aScan(aTipTem,{ |x| x[1] } )
If nAponta == 0
	MsgInfo(STR0150) // "Selecionar um registro para apontamento."
	Return .f.
EndIf

cAuxTipTem := aTipTem[nAponta,APOAUT_TIPTEM]
cAuxTipSer := aTipTem[nAponta,APOAUT_TIPSER]
cAuxSeqInc := aTipTem[nAponta,APOAUT_SEQINC]
cAuxSitTT  := aTipTem[nAponta,APOAUT_STATUS] // Salva a situacao atual do TT para comparacao ao carregar a matriz novamente

// Atualiza a as informacoes do tipo de tempo ...
OM030LEVREG(@aTipTem,cNumOsv,cAuxTipTem,cAuxTipSer,cAuxSeqInc)
//

// Verifica se o TT / Tipo de Servico ainda esta na matriz ...
nAponta := aScan(aTipTem,{ |x| x[APOAUT_TIPTEM] == cAuxTipTem .and. x[APOAUT_TIPSER] == cAuxTipSer} )
If nAponta == 0
	lErro := .t.
	MsgInfo(STR0152 + Chr(13) + Chr(10) + STR0151) // "Tipo de Tempo nใo encontrado na matriz de apontamento." // "Tente novamente."
ElseIf aTipTem[nAponta,APOAUT_STATUS] <> cAuxSitTT
	lErro := .t.
	MsgInfo(STR0153 + Chr(13) + Chr(10) + STR0151) // "A situa็ใo do Tipo de Tempo foi alterada." // "Tente novamente."
EndIf
If lErro
	oLbTipTem:nAt := 1
	oLbTipTem:SetArray(aTipTem)
	oLbTipTem:DrawSelect()
	oLbTipTem:Refresh()
	Return .f.
EndIf
aTipTem[nAponta,1] := .t.
//

oLbTipTem:nAt := nAponta
oLbTipTem:SetArray(aTipTem)
oLbTipTem:DrawSelect()
oLbTipTem:Refresh()

// TT nao incializado ou ja Finalizado
If ( Empty(aTipTem[nAponta,APOAUT_DATINI]) .Or. ( !Empty(aTipTem[nAponta,APOAUT_DATINI]) .And. !Empty(aTipTem[nAponta,APOAUT_DATFIM]) ) )

	VO4->(DbGoTo(aTipTem[nAponta,APOAUT_VO4RECNO]))

	VAI->(dbSetOrder(1))
	If !VAI->(dbSeek(xFilial("VAI") + cProdutivo))
		RestArea(aAreaVAI)
		Return .f.
	EndIf

	If !OM030ProFil(cProdutivo, iif( ! empty(VO4->VO4_DATINI) , VO4->VO4_DATINI , DATE()), !(cProdutivo $ cProdProc) )
		cProdProc += cProdutivo
		RestArea(aAreaVAI)
		Return .f.
	EndIf

	// Monta apontamentos
	If Len(aTipTem[nAponta,APOAUT_ARRAY_VO4]) # 0

		For nSrv := 1 to Len(aTipTem[nAponta,APOAUT_ARRAY_VO4])

			VO4->(DbGoTo(aTipTem[nAponta,APOAUT_ARRAY_VO4, nSrv, APOAUT_ARRAY_VO4_RECNO]))

			AADD( aSrv, Array(23) )
			aSrv[Len(aSrv) , SRV_TIPTEM] := VO4->VO4_TIPTEM  // 01
			aSrv[Len(aSrv) , SRV_FATPAR] := VO4->VO4_FATPAR  // 02
			aSrv[Len(aSrv) , SRV_LOJA]   := VO4->VO4_LOJA    // 03
			aSrv[Len(aSrv) , SRV_GRUSER] := VO4->VO4_GRUSER  // 04
			aSrv[Len(aSrv) , SRV_CODSER] := VO4->VO4_CODSER  // 05
			aSrv[Len(aSrv) , SRV_TIPSER] := VO4->VO4_TIPSER  // 06
			aSrv[Len(aSrv) , SRV_TEMPAD] := VO4->VO4_TEMPAD  // 07
			aSrv[Len(aSrv) , SRV_VALVEN] := VO4->VO4_VALVEN  // 08
			aSrv[Len(aSrv) , SRV_CODSEC] := VO4->VO4_CODSEC  // 09

			// Marca data e hora somente no primeiro registro
			if len(aSrv) == 1
				aSrv[Len(aSrv) , SRV_DATINI] := Date()
				aSrv[Len(aSrv) , SRV_HORINI] := nHora
			else
				aSrv[Len(aSrv) , SRV_DATINI] := CtoD(" ")
				aSrv[Len(aSrv) , SRV_HORINI] := 0
			endif
			aSrv[Len(aSrv) , SRV_DATFIM    ] := Ctod(" ")
			aSrv[Len(aSrv) , SRV_HORFIM    ] := 0
			aSrv[Len(aSrv) , SRV_CODCAM    ] := ""
			aSrv[Len(aSrv) , SRV_CODFAS    ] := ""
			aSrv[Len(aSrv) , SRV_SEQINC    ] := VO4->VO4_SEQINC	// 16 - Sequencia do Inconveniente
			aSrv[Len(aSrv) , SRV_NAOUSADO  ] := ""				// 17 - Campo nao utilizado mais
			aSrv[Len(aSrv) , SRV_PRODUTIVO ] := cProdutivo		// 18 - Produto que esta trabalhando na OS
			aSrv[Len(aSrv) , SRV_EXCLUIDO  ] := .f.
			aSrv[Len(aSrv) , SRV_VO4RECNO  ] := VO4->(Recno())
			aSrv[Len(aSrv) , SRV_VALDES    ] := VO4->VO4_VALDES // 21 - Valor do Desconto
			aSrv[Len(aSrv) , SRV_PERDES    ] := VO4->VO4_PERDES // 22 - Percentual de Desconto
			aSrv[Len(aSrv) , SRV_VALSER    ] := VO4->VO4_VALSER // 23 - Valor do Servico

			// TT e TS Ja Finalizado
			If ( !Empty(aTipTem[nAponta,APOAUT_DATINI]) .And. !Empty(aTipTem[nAponta,APOAUT_DATFIM]) )
				aSrv[Len(aSrv),SRV_VO4RECNO] := 0
			EndIf
			//

		Next nSrv

	EndIf

Else

	// Levanta total do tempo padrao
	nTotPad := 0
	For nSrv := 1 to Len(aTipTem[nAponta,APOAUT_ARRAY_VO4])
		If Len(aTipTem[nAponta,APOAUT_ARRAY_VO4]) <= 1 .And. Empty(aTipTem[nAponta,APOAUT_ARRAY_VO4,nSrv,APOAUT_ARRAY_VO4_TEMPAD])
			aTipTem[nAponta,APOAUT_ARRAY_VO4,nSrv,APOAUT_ARRAY_VO4_TEMPAD] := 1
		EndIf
		nTotPad += aTipTem[nAponta,APOAUT_ARRAY_VO4,nSrv,APOAUT_ARRAY_VO4_TEMPAD]

		// Levanta tempo total trabalhado para o Produtivo em questao
		if ! jMecTempoTrab:HasProperty(aTipTem[nAponta,APOAUT_ARRAY_VO4,nSrv,APOAUT_ARRAY_VO4_CODPRO])
			jMecTempoTrab[aTipTem[nAponta,APOAUT_ARRAY_VO4,nSrv,APOAUT_ARRAY_VO4_CODPRO]] := ;
				FG_TEMPTRA(;
					aTipTem[nAponta,APOAUT_ARRAY_VO4,nSrv,APOAUT_ARRAY_VO4_CODPRO],;  // cCodPro
					aTipTem[nAponta,APOAUT_DATINI],;                                  // dDataIni
					aTipTem[nAponta,APOAUT_HORINI],;                                  // nHoraIni
					Date(),;                                                          // dDataFin
					nHora,;                                                           // nHoraFin
					"N",;                                                             // cSitMecR
					,;                                                                // lMensagem
					"F/D/E/A" )                                                       // cTipLevant
		endif
	Next

	// Levanta o tempo total trabalhado
	//nTotTem := FS_VLSERTP(aTipTem[nAponta,APOAUT_DATINI],aTipTem[nAponta,APOAUT_HORINI],Date(),nHora)
	//aSitMec := FG_TEMPTRA(aSrv[nAponta,SRV_PRODUTIVO],aSrv[nAponta,SRV_DATINI],aSrv[nAponta,SRV_HORINI],aSrv[nAponta,SRV_DATFIM],aSrv[nAponta,SRV_HORFIM] ,"A",,"F/D/E/A" )

	// Monta apontamentos
	If Len(aTipTem[nAponta,APOAUT_ARRAY_VO4]) # 0

		Asort(aTipTem[nAponta,APOAUT_ARRAY_VO4],1,,{ |x,y| x[APOAUT_ARRAY_VO4_DATINI]+x[APOAUT_ARRAY_VO4_HORINI] > y[APOAUT_ARRAY_VO4_DATINI]+ y[APOAUT_ARRAY_VO4_HORINI]})

		For nSrv := 1 to Len(aTipTem[nAponta,APOAUT_ARRAY_VO4])

			nPerTem := ( ( aTipTem[nAponta,APOAUT_ARRAY_VO4,nSrv,APOAUT_ARRAY_VO4_TEMPAD] * 100 ) / nTotPad )

			VO4->(DbGoTo(aTipTem[nAponta,APOAUT_ARRAY_VO4,nSrv,APOAUT_ARRAY_VO4_RECNO]))

			If Empty(cAuxProdut) .AND. !Empty(VO4->VO4_CODPRO)
				cAuxProdut := VO4->VO4_CODPRO
			Endif

			AADD( aSrv, Array(23) )
			nUltimo := Len(aSrv)
			aSrv[ nUltimo , SRV_TIPTEM    ] := VO4->VO4_TIPTEM
			aSrv[ nUltimo , SRV_FATPAR    ] := VO4->VO4_FATPAR
			aSrv[ nUltimo , SRV_LOJA      ] := VO4->VO4_LOJA
			aSrv[ nUltimo , SRV_GRUSER    ] := VO4->VO4_GRUSER
			aSrv[ nUltimo , SRV_CODSER    ] := VO4->VO4_CODSER
			aSrv[ nUltimo , SRV_TIPSER    ] := VO4->VO4_TIPSER
			aSrv[ nUltimo , SRV_TEMPAD    ] := VO4->VO4_TEMPAD
			aSrv[ nUltimo , SRV_VALVEN    ] := VO4->VO4_VALVEN
			aSrv[ nUltimo , SRV_CODSEC    ] := VO4->VO4_CODSEC
			aSrv[ nUltimo , SRV_DATINI    ] := Ctod("  /  /  ")
			aSrv[ nUltimo , SRV_HORINI    ] := 0
			aSrv[ nUltimo , SRV_DATFIM    ] := Ctod("  /  /  ")
			aSrv[ nUltimo , SRV_HORFIM    ] := 0
			aSrv[ nUltimo , SRV_CODCAM    ] := ""
			aSrv[ nUltimo , SRV_CODFAS    ] := ""
			aSrv[ nUltimo , SRV_SEQINC    ] := VO4->VO4_SEQINC	// 16 - Sequencia do Inconveniente
			aSrv[ nUltimo , SRV_NAOUSADO  ] := "" 				// 17 - Campo nao utilizado mais
			aSrv[ nUltimo , SRV_PRODUTIVO ] := VO4->VO4_CODPRO
			aSrv[ nUltimo , SRV_EXCLUIDO  ] := .f.
			aSrv[ nUltimo , SRV_VO4RECNO  ] := VO4->(Recno())
			aSrv[ nUltimo , SRV_VALDES    ] := VO4->VO4_VALDES // 21 - Valor do Desconto
			aSrv[ nUltimo , SRV_PERDES    ] := VO4->VO4_PERDES // 22 - Percentual de Desconto
			aSrv[ nUltimo , SRV_VALSER    ] := VO4->VO4_VALSER // 23 - Valor do Servico

			// Hora inicial
			If ! Empty(aTipTem[nAponta,APOAUT_ARRAY_VO4,nSrv,APOAUT_ARRAY_VO4_HORINI])
				aSrv[ nUltimo , SRV_DATINI ] := aTipTem[nAponta,APOAUT_ARRAY_VO4,nSrv,APOAUT_ARRAY_VO4_DATINI]
				aSrv[ nUltimo , SRV_HORINI ] := aTipTem[nAponta,APOAUT_ARRAY_VO4,nSrv,APOAUT_ARRAY_VO4_HORINI]
			Else
				nPosAnterior := IIf(( nUltimo -1) <= 0 , 1 , nUltimo -1 )
				aSrv[ nUltimo , SRV_DATINI ] := aSrv[ nPosAnterior , SRV_DATFIM]
				aSrv[ nUltimo , SRV_HORINI ] := aSrv[ nPosAnterior , SRV_HORFIM]
			EndIf

			nTotTem := jMecTempoTrab[aSrv[nUltimo,SRV_PRODUTIVO]] // Levanta o tempo total trabalhado para o produtivo em questao

			// Hora inicial
			nHrIni := Val( Substr(StrZero((aSrv[ nUltimo ,SRV_HORINI ]),4),1,2) + StrZero( Int(Val(Substr(StrZero((aSrv[ nUltimo ,SRV_HORINI ]),4),3,2)) / 0.6 ), 2) )

			// Hora final
			nHrFin := nHrIni // Val( Substr(StrZero((aSrv[ nUltimo ,SRV_HORINI ]),4),1,2) + StrZero( Int(Val(Substr(StrZero((aSrv[ nUltimo ,SRV_HORINI ]),4),3,2)) / 0.6 ), 2) )
			nHrFin := Int( ( nHrFin + ( ( nTotTem * nPerTem ) / 100 ) ) + 1.67 ) // Soma 1 min (centesimal)
			// Hora final em Sexagesimal
			nHrFin := Val( Substr(StrZero(nHrFin,4),1,2) + StrZero( Round( ( Val(Substr(StrZero(nHrFin,4),3,2)) * 0.6 ) + 0.5 , 0 ) , 2) )

			aSrv[ nUltimo ,SRV_DATFIM  ] := ( aSrv[ nUltimo ,SRV_DATINI ] + ( Int(nHrFin / 2400) ) )
			aSrv[ nUltimo ,SRV_HORFIM  ] := ( nHrFin - ( Int(nHrFin / 2400)*2400 ) )

			// Se tiver algum apontamento, grava 0 no recno para gerar um novo registro de apontamento
			If ( !Empty(VO4->VO4_DATINI) .And. !Empty(VO4->VO4_DATFIN) )
				aSrv[ nUltimo ,SRV_VO4RECNO] := 0
			EndIf

		Next

		aEval( aSrv , {|x| IIF( Empty(x[SRV_PRODUTIVO]) , x[SRV_PRODUTIVO] := cAuxProdut , ) } ) // Grava produtivo quando estiver em branco ...

	EndIf

EndIf

// ajusta a hora de acordo com a escala de trabalho do produtivo
If Len(aSrv) # 0

	For nAponta := 1 to Len(aSrv)

//		aSitMec := FG_TEMPTRA(aSrv[nAponta,SRV_PRODUTIVO],aSrv[nAponta,SRV_DATINI],aSrv[nAponta,SRV_HORINI],aSrv[nAponta,SRV_DATFIM],aSrv[nAponta,SRV_HORFIM] ,"A",,"F/D" )
		aSitMec := FG_TEMPTRA(aSrv[nAponta,SRV_PRODUTIVO],aSrv[nAponta,SRV_DATINI],aSrv[nAponta,SRV_HORINI],aSrv[nAponta,SRV_DATFIM],aSrv[nAponta,SRV_HORFIM] ,"A",,"F/D/E/A" )

		For nEscala := 1 to Len(aSitMec)

			If !Empty(aSrv[nAponta,SRV_DATINI])

				If ( Len(aSitMec) == 1 .And. Dtos(aSitMec[nEscala,3]) + Str(aSitMec[nEscala,4],4) < Dtos(aSrv[nAponta,10]) + Str(aSrv[nAponta,11],4 ) ;
					.Or. ( nEscala > 1 .And. Dtos(aSitMec[nEscala-1,3]) + Str(aSitMec[nEscala-1,4],4) < Dtos(aSrv[nAponta,10]) + Str(aSrv[nAponta,11],4) .And. Dtos(aSitMec[nEscala,1]) + Str(aSitMec[nEscala,2],4) > Dtos(aSrv[nAponta,10]) + Str(aSrv[nAponta,11],4) ) )

					aSrv[nAponta,SRV_DATINI] := aSitMec[nEscala,1]
					aSrv[nAponta,SRV_HORINI] := aSitMec[nEscala,2]

				ElseIf ( Len(aSitMec) > 1 .And. Dtos(aSrv[nAponta,SRV_DATINI]) + Str(aSrv[nAponta,SRV_HORINI],4) >= Dtos(aSitMec[nEscala,1]) + Str(aSitMec[nEscala,2],4) .And. Dtos(aSrv[nAponta,SRV_DATINI]) + Str(aSrv[nAponta,SRV_HORINI],4) <= Dtos(aSitMec[nEscala,3]) + Str(aSitMec[nEscala,4],4) .And. aSitMec[nEscala,5] == "F" )

					aSrv[nAponta,SRV_DATINI] := aSitMec[nEscala,3]
					aSrv[nAponta,SRV_HORINI] := aSitMec[nEscala,4]

				EndIf

			EndIf

			If !Empty(aSrv[nAponta,12])

				If ( Len(aSitMec) == 1 .And. Dtos(aSitMec[nEscala,3]) + Str(aSitMec[nEscala,4],4) < Dtos(aSrv[nAponta,12]) + Str(aSrv[nAponta,13],4) );
					.Or. ( nEscala > 1 .And. Dtos(aSitMec[nEscala-1,3]) + Str(aSitMec[nEscala-1,4],4) < Dtos(aSrv[nAponta,12]) + Str(aSrv[nAponta,13],4) ;
									   .And. Dtos(aSitMec[nEscala,1])   + Str(aSitMec[nEscala,2],4)   > Dtos(aSrv[nAponta,12]) + Str(aSrv[nAponta,13],4) )

					aSrv[nAponta,SRV_DATFIM] := aSitMec[nEscala,3]
					aSrv[nAponta,SRV_HORFIM] := aSitMec[nEscala,4]

				EndIf

			EndIf

		Next

	Next

EndIf

// verifica se o produtivo ja esta apontado no horario
VO4->(DbSetOrder(2))
For nAponta := 1 to Len(aSrv)

	If VO4->(MsSeek( xFilial("VO4") + aSrv[nAponta,SRV_PRODUTIVO] + Dtos(aSrv[nAponta,SRV_DATINI]) + Str(aSrv[nAponta,SRV_HORINI],4) )) ;
		.And. VO4->(Recno()) # aSrv[nAponta,SRV_VO4RECNO]

		MsgStop(STR0134 + Chr(13)+Chr(10) ;        	 //Mecanico com hora marcada neste horario!
			+ STR0135 + cProdutivo +Chr(13)+Chr(10) ;  //Mecanico:
			+ STR0136 + Transform(aSrv[nAponta,10],"@D")+Chr(13)+Chr(10) ; //Data:
			+ STR0137 + Transform(aSrv[nAponta,11],"@R 99:99")	,STR0066)  //Hora:

		oTime:lActive := .t.

		RestArea(aAreaVAI)
		Return(.f.)

	EndIf

Next
VO4->(DbSetOrder(1))

If Len(aSrv) # 0
	// Grava Servico
	// Grava Servicos Requisitados
	OM030GRVO4( aSrv , 3 , .t.)
EndIf

// Levanta registros
OM030LEVREG(@aTipTem,cNumOsv)

oTime:lActive := .t.

RestArea(aAreaVAI)

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณOM030GRVO4บAutor  ณFabio               บ Data ณ  07/07/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGrava Sevicos da Ordem de Servico VO4                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณOficina                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function OM030GRVO4( aItens , nOpc , lAltReq )

Local ni := 0
Local nx_ := 0, aSitMec := {}, nApont := 0, nPosSrv := 0



Private aHeaderSrv := {} , aHeaderIniFim := {} , aHeader := {}
Default lAltReq := .f.

// Grava Cabecalho de Servico
IncProc( OemtoAnsi( STR0139 ) )  //Gerando Cabecalho Ordem de Servico

DbSelectArea("VO2")
DbSetOrder(1)
DbSeek(xFilial("VO2") + VO1->VO1_NUMOSV + "S" )

DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("VO2")
Do While !Eof() .And. x3_Arquivo == "VO2"

	&("M->"+x3_campo) := CriaVar(x3_campo)

	If Alltrim(x3_campo) $ "VO2_NOSNUM"
		&( "M->"+Alltrim(x3_campo) ) := If(!VO2->(Found()),GetSxeNum("VO2",x3_campo,,2) , VO2->VO2_NOSNUM )
		ConfirmSx8()
	EndIf

	DbSelectArea("SX3")
	DbSkip()

EndDo

// Monta aHeaders
FS_MTAHEADER()

aColsSrv    := {}
aColsIniFim := {}
aCols       := {}
aSitMec     := {}

// Servicos
DbSelectArea("VO4")
DbSetOrder(4)

For ni := 1 to Len(aItens)

	//   If (!DbSeek( xFilial("VO4") + aItens[ni,05] + M->VO2_NOSNUM ) .Or. ( Empty(VO4->VO4_DATINI) .Or. Empty(VO4->VO4_DATFIN) ))
	If ( ( !DbSeek( xFilial("VO4") + aItens[ni,05] + M->VO2_NOSNUM ) .Or. aItens[ni,19] ) .Or. lAltReq )

		Aadd( aColsSrv , Array(Len(aHeaderSrv)+1) )

		// Sequencia do Inconveniente
		If lInconveniente
			&("M->"+aHeaderSrv[FG_POSVAR("VO4_SEQINC","aHeaderSrv"),2]) := aColsSrv[Len(aColsSrv), FG_POSVAR("VO4_SEQINC","aHeaderSrv") ] := aItens[ni,16]
		EndIf

		&("M->"+aHeaderSrv[FG_POSVAR("VO4_TIPTEM","aHeaderSrv"),2]) := aColsSrv[Len(aColsSrv), FG_POSVAR("VO4_TIPTEM","aHeaderSrv") ] := aItens[ni,01]
		&("M->"+aHeaderSrv[FG_POSVAR("VO4_FATPAR","aHeaderSrv"),2]) := aColsSrv[Len(aColsSrv), FG_POSVAR("VO4_FATPAR","aHeaderSrv") ] := aItens[ni,02]
		&("M->"+aHeaderSrv[FG_POSVAR("VO4_LOJA","aHeaderSrv"),2])   := aColsSrv[Len(aColsSrv), FG_POSVAR("VO4_LOJA"  ,"aHeaderSrv") ] := aItens[ni,03]
		&("M->"+aHeaderSrv[FG_POSVAR("VO4_GRUSER","aHeaderSrv"),2]) := aColsSrv[Len(aColsSrv), FG_POSVAR("VO4_GRUSER","aHeaderSrv") ] := aItens[ni,04]
		&("M->"+aHeaderSrv[FG_POSVAR("VO4_CODSER","aHeaderSrv"),2]) := aColsSrv[Len(aColsSrv), FG_POSVAR("VO4_CODSER","aHeaderSrv") ] := aItens[ni,05]
		&("M->"+aHeaderSrv[FG_POSVAR("VO4_TIPSER","aHeaderSrv"),2]) := aColsSrv[Len(aColsSrv), FG_POSVAR("VO4_TIPSER","aHeaderSrv") ] := aItens[ni,06]
		&("M->"+aHeaderSrv[FG_POSVAR("VO4_TEMPAD","aHeaderSrv"),2]) := aColsSrv[Len(aColsSrv), FG_POSVAR("VO4_TEMPAD","aHeaderSrv") ] := aItens[ni,07]
//		&("M->"+aHeaderSrv[FG_POSVAR("VO4_KILROD","aHeaderSrv"),2]) := aColsSrv[Len(aColsSrv), FG_POSVAR("VO4_KILROD","aHeaderSrv") ] := aItens[ni,08]
		// acha o valor da hora
		&("M->"+aHeaderSrv[FG_POSVAR("VO4_VALHOR","aHeaderSrv"),2]) := aColsSrv[Len(aColsSrv), FG_POSVAR("VO4_VALHOR","aHeaderSrv") ] := ( ( aItens[ni,08] / aItens[ni,07] ) * 100 )

		&("M->"+aHeaderSrv[FG_POSVAR("VO4_VALVEN","aHeaderSrv"),2]) := aColsSrv[Len(aColsSrv), FG_POSVAR("VO4_VALVEN","aHeaderSrv") ] := aItens[ni,08]
		&("M->"+aHeaderSrv[FG_POSVAR("VO4_CODSEC","aHeaderSrv"),2]) := aColsSrv[Len(aColsSrv), FG_POSVAR("VO4_CODSEC","aHeaderSrv") ] := aItens[ni,09]
		&("M->"+aHeaderSrv[FG_POSVAR("VO4_CODCAM","aHeaderSrv"),2]) := aColsSrv[Len(aColsSrv), FG_POSVAR("VO4_CODCAM","aHeaderSrv") ] := aItens[ni,14]

		&("M->"+aHeaderSrv[FG_POSVAR("VO4_VALDES","aHeaderSrv"),2]) := aColsSrv[Len(aColsSrv), FG_POSVAR("VO4_VALDES","aHeaderSrv") ] := aItens[ni,21]
		&("M->"+aHeaderSrv[FG_POSVAR("VO4_PERDES","aHeaderSrv"),2]) := aColsSrv[Len(aColsSrv), FG_POSVAR("VO4_PERDES","aHeaderSrv") ] := aItens[ni,22]

		&("M->"+aHeaderSrv[FG_POSVAR("VO4_VALSER","aHeaderSrv"),2]) := aColsSrv[Len(aColsSrv), FG_POSVAR("VO4_VALSER","aHeaderSrv") ] := aItens[ni,23]

		aColsSrv[Len(aColsSrv), Len(aColsSrv[Len(aColsSrv)]) ]      := aItens[ni,19]

		For nx_ := 1 to Len(aHeaderSrv)

			If aColsSrv[Len(aColsSrv),nx_] == NIL
				&("M->"+aHeaderSrv[nx_,2]) := aColsSrv[Len(aColsSrv),nx_] := CriaVar(aHeaderSrv[nx_,2])
			EndIf

		Next

		If !aItens[ni,19]
			aSitMec := FG_TEMPTRA( aItens[ni,18] ,aItens[ni,10],aItens[ni,11],aItens[ni,12], aItens[ni,13] ,"A",,"F/D" )
//			           FG_TEMPTRA(cCodPro        ,dDataIni     ,nHoraIni     ,dDataFin     ,nHoraFin,cSitMecR,lMensagem,cTipLevant,cSrvIdent,aVetCols,aVetHeader)
		EndIf

		DbSelectArea("VO4")
		DbSetOrder(1)
		DbSeek( xFilial("VO4") + M->VO2_NOSNUM + aItens[ni,01] + aItens[ni,05] ) // NosNum + Tipo de Tempo + Codigo do Servico
		Do While !Eof() .And. VO4->VO4_FILIAL+VO4->VO4_NOSNUM+VO4->VO4_TIPTEM+VO4->VO4_CODSER == xFilial("VO4")+M->VO2_NOSNUM+aItens[ni,01]+aItens[ni,05]

			If Len(aItens[ni]) >= 20 .And. aItens[ni,20] == VO4->(Recno())
				nPosSrv := Ascan(aSitMec,{|x| Dtos(x[1])+StrZero(x[2],4) == Dtos(aItens[ni,10])+StrZero(aItens[ni,11],4) })
			Else
				nPosSrv := Ascan(aSitMec,{|x| Dtos(x[1])+StrZero(x[2],4) == Dtos(VO4->VO4_DATINI)+StrZero(VO4->VO4_HORINI,4) })
			EndIf

			If nPosSrv == 0
				If ( Len(aSitMec) == 0 .Or. ( !Empty(aSitMec[Len(aSitMec),1]) .Or. !Empty(aSitMec[Len(aSitMec),3]) ) )
					Aadd(aSitMec, { Ctod("  /  /  "), 0, Ctod("  /  /  "), 0, "" , 0, "", "", "", Repl("0",Len(VO4->VO4_SEQUEN)), aItens[ni,19] } )
				EndIf
				nPosSrv := Len(aSitMec)

				aSitMec[nPosSrv,01] := VO4->VO4_DATINI
				aSitMec[nPosSrv,02] := VO4->VO4_HORINI
				aSitMec[nPosSrv,03] := VO4->VO4_DATFIN
				aSitMec[nPosSrv,04] := VO4->VO4_HORFIN
				aSitMec[nPosSrv,05] := VO4->VO4_HOREXT
				aSitMec[nPosSrv,06] := 0
				aSitMec[nPosSrv,07] := ""
				aSitMec[nPosSrv,08] := ""
				aSitMec[nPosSrv,09] := ""
			EndIf

			// Adiciona VO4_SEQUEN
			Aadd( aSitMec[nPosSrv], VO4->VO4_SEQUEN )

			DbSelectArea("VO4")
			DbSkip()
		EndDo

		For nApont := 1 to Len(aSitMec)

			Aadd( aColsIniFim , Array(Len(aHeaderIniFim)+1) )

			&("M->"+aHeaderIniFim[FG_POSVAR("VO4_GRUSER","aHeaderIniFim"),2]) := aColsIniFim[Len(aColsIniFim), FG_POSVAR("VO4_GRUSER","aHeaderIniFim") ] := aItens[ni,04]
			&("M->"+aHeaderIniFim[FG_POSVAR("VO4_CODSER","aHeaderIniFim"),2]) := aColsIniFim[Len(aColsIniFim), FG_POSVAR("VO4_CODSER","aHeaderIniFim") ] := aItens[ni,05]

			&("M->"+aHeaderIniFim[FG_POSVAR("VO4_CODPRO","aHeaderIniFim"),2]) := aColsIniFim[Len(aColsIniFim), FG_POSVAR("VO4_CODPRO","aHeaderIniFim") ] := aItens[ni,18]
			&("M->"+aHeaderIniFim[FG_POSVAR("VO4_DATINI","aHeaderIniFim"),2]) := aColsIniFim[Len(aColsIniFim), FG_POSVAR("VO4_DATINI","aHeaderIniFim") ] := aSitMec[nApont,1]
			&("M->"+aHeaderIniFim[FG_POSVAR("VO4_HORINI","aHeaderIniFim"),2]) := aColsIniFim[Len(aColsIniFim), FG_POSVAR("VO4_HORINI","aHeaderIniFim") ] := aSitMec[nApont,2]
			&("M->"+aHeaderIniFim[FG_POSVAR("VO4_DATFIN","aHeaderIniFim"),2]) := aColsIniFim[Len(aColsIniFim), FG_POSVAR("VO4_DATFIN","aHeaderIniFim") ] := aSitMec[nApont,3]
			&("M->"+aHeaderIniFim[FG_POSVAR("VO4_HORFIN","aHeaderIniFim"),2]) := aColsIniFim[Len(aColsIniFim), FG_POSVAR("VO4_HORFIN","aHeaderIniFim") ] := aSitMec[nApont,4]
			&("M->"+aHeaderIniFim[FG_POSVAR("VO4_HOREXT","aHeaderIniFim"),2]) := aColsIniFim[Len(aColsIniFim), FG_POSVAR("VO4_HOREXT","aHeaderIniFim") ] := If( aSitMec[nApont,5] $ "D/O" , "O" , "E" )
			&("M->"+aHeaderIniFim[FG_POSVAR("VO4_CODFAS","aHeaderIniFim"),2]) := aColsIniFim[Len(aColsIniFim), FG_POSVAR("VO4_CODFAS","aHeaderIniFim") ] := aItens[ni,15]

			aColsIniFim[Len(aColsIniFim), Len(aColsIniFim[Len(aColsIniFim)]) ]   := aItens[ni,19]

			If !Empty(aSitMec[nApont,Len(aSitMec[nApont])])
				&("M->"+aHeaderIniFim[FG_POSVAR("VO4_SEQUEN","aHeaderIniFim"),2]) := aColsIniFim[Len(aColsIniFim), FG_POSVAR("VO4_SEQUEN","aHeaderIniFim") ] := aSitMec[nApont,Len(aSitMec[nApont])]
			EndIf

			For nx_ := 1 to Len(aHeaderIniFim)

				If aColsIniFim[Len(aColsIniFim),nx_] == NIL
					&("M->"+aHeaderIniFim[nx_,2]) := aColsIniFim[Len(aColsIniFim),nx_] := CriaVar(aHeaderIniFim[nx_,2])
				EndIf

			Next

		Next

	EndIf

	IncProc( OemtoAnsi( STR0139 ) )    //"Importando Servicos"

Next

If Len(aColsSrv) # 0

	// Grava Servicos
	FS_GRSRVs(.t.)

EndIf

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณOM030ATULBOX บAutor  ณMicrosiga        บ Data ณ  02/04/10   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Atualiza listbox com inconvenientes cadastrado para o mesmoบฑฑ
ฑฑบ          ณ grupo de servicos (Tipo de Tempo + Tipo de Servico )       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
STATIC FUNCTION OM030ATULBOX(cNumOsv, cTipTem, cTipSrvc)

Local cQuery, cSQLINC := "TINCSRV"

cQuery := "SELECT DISTINCT VST_GRUINC, VST_CODINC, VST_DESINC, VST_SEQINC"
cQuery +=  " FROM "+RetSQLName("VO2")+" VO2 , "+RetSQLName("VO4")+" VO4 , "+RetSQLName("VST")+" VST"
cQuery += " WHERE VO2.VO2_FILIAL = '"+xFilial("VO2")+"'"
cQuery +=   " AND VO2.VO2_NUMOSV = '"+cNumOsv+"'"
cQuery +=   " AND VO2.VO2_TIPREQ = 'S'" // Somente Requisicao de Servicos
cQuery +=   " AND VO2.D_E_L_E_T_ = ' '"
cQuery +=   " AND VO4.VO4_FILIAL = '"+xFilial("VO4")+"'"
cQuery +=   " AND VO4.VO4_NOSNUM = VO2.VO2_NOSNUM"
cQuery +=   " AND VO4.VO4_TIPTEM = '"+cTipTem+"'"
cQuery +=   " AND VO4.VO4_TIPSER = '"+cTipSrvc+"'"
cQuery +=   " AND VO4.D_E_L_E_T_ = ' '"
cQuery +=   " AND VST.VST_FILIAL = '"+xFilial("VST")+"'"
cQuery +=   " AND VST.VST_TIPO = '2'" // Inconvenientes de OS
cQuery +=   " AND VST.VST_CODIGO = VO2.VO2_NUMOSV"
cQuery +=   " AND VST.VST_SEQINC = VO4.VO4_SEQINC"
cQuery +=   " AND VST.D_E_L_E_T_ = ' '"
cQuery += " ORDER BY VST_GRUINC, VST_CODINC, VST_DESINC"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLINC , .F., .T. )

aIncTipTem := {}
While !(cSQLINC)->(Eof())
	AADD( aIncTipTem , { .f. , (cSQLINC)->VST_GRUINC, (cSQLINC)->VST_CODINC, (cSQLINC)->VST_DESINC, (cSQLINC)->VST_SEQINC } )
	(cSQLINC)->(DbSkip())
End
(cSQLINC)->(dbCloseArea())

if Len(aIncTipTem) == 0
	aIncTipTem := {{ .f. , " "," "," " , " "}}
endif

oLbInconv:SetArray(aIncTipTem)
//oLbInconv:bLine := { || { aIncTipTem[oLbInconv:nAt,1] , aIncTipTem[oLbInconv:nAt,2] , aIncTipTem[oLbInconv:nAt,3] }}
oLbInconv:Refresh()

RETURN

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ FS_030TUDOK บ Autor ณ Rubens          บ Data ณ  03/11/11   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Tudo OK da GetDados de Requisicao de Pecas                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FS_030TUDOK()

Local lRet      := .t.
Local lVerTpgCC := .t.
Local aAvCred   := {}
Local ni        := 0
Local nAvCred   := 0
Local nVlHrTab  := 0
Local nMoedaC   := 0
Private aAuxaCols   := {}
Private aAuxaHeader := {}

//If lOM030Auto .or. oFolder030:nOption == 1
If (lOM030Auto .and. !lAutoApont) .or. (lOM030Auto == .f. .and. oFolder030:nOption == 1)
	aAuxaHeader := aClone(aHeader)
	aAuxaCols   := aClone(aCols)
Else
	aAuxaHeader := aClone(aHeaderSrv)
	aAuxaCols   := aClone(aColsSrv)
EndIf

For ni := 1 to Len(aAuxaCols)
	If !aAuxaCols[ni,Len(aAuxaCols[ni])]

		VOK->(DbSetOrder(1))
		VOK->(DbSeek(xFilial("VOK")+aAuxaCols[ni,FG_POSVAR("VO4_TIPSER","aAuxaHeader")]))
		FG_MEMVAR(aAuxaHeader,aAuxaCols,ni,.f.) // Carregar os M-> pela aCols

		lRet := OM030GRUSRV(aAuxaCols[ni,FG_POSVAR("VO4_GRUSER","aAuxaHeader")],;
							aAuxaCols[ni,FG_POSVAR("VO4_TIPTEM","aAuxaHeader")],;
							VV1->VV1_CODMAR,;
							.t.)

		If lRet
			lRet := FS_VALSRV3( .t. , aAuxaCols[ni,nUsadoSrv] , aAuxaCols , ni )
		EndIf

		If !lRet
			Exit
		EndIf

		// Montar vetor de Credito com as novas Requisi็๕es
		If aAuxaCols[ni,FG_POSVAR("VO4_REC_WT","aHeaderSrv")] == 0
			nAvCred := aScan(aAvCred, { |x| x[1] == aAuxaCols[ni,FG_POSVAR("VO4_FATPAR","aHeaderSrv")] .And. x[2] == aAuxaCols[ni,FG_POSVAR("VO4_LOJA","aHeaderSrv")] })
			If nAvCred == 0
				AADD(aAvCred, Array(03))
				nAvCred := Len(aAvCred)

				aAvCred[nAvCred,01] := aAuxaCols[ni,FG_POSVAR("VO4_FATPAR","aHeaderSrv")]
				aAvCred[nAvCred,02] := aAuxaCols[ni,FG_POSVAR("VO4_LOJA","aHeaderSrv")]
				aAvCred[nAvCred,03] := 0
			EndIf

			nVlHrTab := (FG_ValHor(aAuxaCols[ni,FG_POSVAR("VO4_TIPTEM","aHeaderSrv")],							;
								   OM030TPVLSRV(aAuxaCols[ni,FG_POSVAR("VO4_TIPTEM","aHeaderSrv")],				;
								                M->VO4_NOSNUM),													;
								   "1",																			;
								   aAuxaCols[ni,FG_POSVAR("VO4_VALHOR","aHeaderSrv")],							;
								   VV1->VV1_CODMAR,																;
								   aAuxaCols[ni,FG_POSVAR("VO4_CODSER","aHeaderSrv")],							;
								   aAuxaCols[ni,FG_POSVAR("VO4_TIPSER","aHeaderSrv")],							;
								   aAuxaCols[ni,FG_POSVAR("VO4_FATPAR","aHeaderSrv")],							;
								   aAuxaCols[ni,FG_POSVAR("VO4_LOJA","aHeaderSrv")],							;
								   VV1->VV1_MODVEI,																;
								   VV1->VV1_SEGMOD,																;
								   Iif(lMultMoeda, VO1->VO1_MOEDA, nil),									;
								   Iif(lMultMoeda, VO1->VO1_TXMOED, nil))									;
						 * (Val(Left(StrZero(aAuxaCols[ni,FG_POSVAR("VO4_TEMPAD","aHeaderSrv")], 4), 2)) * 60)	;
						 + Val(Right(StrZero(aAuxaCols[ni,FG_POSVAR("VO4_TEMPAD","aHeaderSrv")], 4), 2)) ) / 60

			aAvCred[nAvCred,03] += nVlHrTab
		EndIf
	EndIf
Next

If lRet .And. Len(aAvCred) > 0
	For ni := 1 To Len(aAvCred)
		// Validacao por Ponto de Entrada
		If ExistBlock("VERTPGCC") // Verifica tipo de Pagamento para Checagem de Credito
			lVerTpgCC := ExecBlock("VERTPGCC",.f.,.f.,{"OFIOM030"})
		Endif

		If lVerTpgCC
			if !FindFunction('FGX_ChkCredCond') .or. FGX_ChkCredCond(VO1->VO1_FORPAG)
				// Verifica Credito do Cliente
				If "S" $ GetMv("MV_CHKCRE") .And. !(VOI->VOI_SITTPO $ "2/3/4")
					If !OM0200045_ChecaCredGar()
						lRet := .t.
						Exit
					Endif
					nMoedaC := IIF(lMultMoeda , Max(VO1->VO1_MOEDA,1), nil )
					If !FGX_AVALCRED(aAvCred[ni,01], aAvCred[ni,02], aAvCred[ni,03], .t., ,VO1->VO1_NUMOSV , nMoedaC)
						lRet := .f.
						Help("  ",1,"LIMITECRED")
						Exit
					EndIf
				EndIf
			Endif
		EndIf
	Next
EndIf

If lRet
	If ( ExistBlock("OM030TOK") )
		lRet := ExecBlock("OM030TOK",.F.,.F.,{aClone(aAuxaHeader),aClone(aAuxaCols)})
	EndIf
EndIf

Return lRet




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ REQFRA030 บ Autor ณ Rubens            บ Data ณ  06/05/10   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Requisicao do valor de franquia de pecas                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function REQFRA030( cNumOsv,cTTSegur )

Local cTTFranquia // Tipo de Tempo de Franquia
Local nValFra // Valor ja lancado como Franquia
Local aArea := {}
Local cQuery := ""
Local nSequen

Local oOficina   := DMS_Oficina():New()

Private cCodCliente, cLojCliente, cNomCliente

// -----------------------------------------
// ARMAZENA AREAS PARA RESTAURACAO POSTERIOR
// -----------------------------------------
aArea := sGetArea(aArea,"VO2")
aArea := sGetArea(aArea,"VOI")
aArea := sGetArea(aArea,"VO3")
aArea := sGetArea(aArea,"VO6")
aArea := sGetArea(aArea,"VO1")
aArea := sGetArea(aArea,"VO4")
If !Empty(Alias())
	aArea := sGetArea(aArea,Alias())
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Posiciona na OS e verifica se existe franquia de SERVICOS ... ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
VO1->(dbSetOrder(1))
IF !VO1->(dbSeek(xFilial("VO1") + cNumOsv))
	sRestArea(aArea)
	Help(" ",1,"REGNOIS",,STR0101 + cNumOsv ,4,1) // OS:
	Return .f.
ENDIF

// Nao foi implementado funcionalidade de franquia especifica de pecas
// OU nao foi informado franquia de SERVICOS ...
IF VO1->VO1_FRANQU <= 0
	sRestArea(aArea)
	Return .t.
ENDIF
//

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ A partir do TT de Seguradora, procura o TT de Franquia ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If oOficina:TipoTempoBloqueado(cTTSegur,.t.) // Valida se Tipo de Tempo esta BLOQUEADO
	sRestArea(aArea)
	return .f.
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Verifica se o TT de Franquia esta cadatrado ... ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cTTFranquia := VOI->VOI_TIPFRA
If oOficina:TipoTempoBloqueado(cTTFranquia,.t.) // Valida se Tipo de Tempo esta BLOQUEADO
	sRestArea(aArea)
	return .f.
EndIf
//

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Verifica se ja foi gerado a requisicao de Franquia ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cQuery := "SELECT SUM(VO4_VALHOR) "
cQuery +=  " FROM " + RetSQLName("VO2") + " VO2 JOIN " + RetSQLName("VO4") + " VO4 ON VO4.VO4_FILIAL = VO2.VO2_FILIAL AND VO4.VO4_NOSNUM = VO2.VO2_NOSNUM AND VO4.D_E_L_E_T_ = ' '"
cQuery += " WHERE VO2.VO2_FILIAL = '" + xFilial("VO2") + "'"
cQuery +=   " AND VO2.VO2_NUMOSV = '" + cNumOsv + "'"
cQuery +=   " AND VO2.VO2_TIPREQ = 'S'"
cQuery +=   " AND VO2.D_E_L_E_T_ = ' '"
cQuery +=   " AND VO4.VO4_TIPTEM = '" + cTTFranquia + "'"
nValFra := FM_SQL(cQuery)
if nValFra > 0
	sRestArea(aArea)
	Return .t.
endif
//

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Procura Cliente de Faturar Para ... ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cCodCliente := ""
cLojCliente := ""
cNomCliente := ""
FG_TIPTPFAT(cTTFranquia,"cCodCliente","cLojCliente","cNomCliente",VO1->VO1_CODMAR,"S",cNumOsv,.f.,.f.,.f.)
//

DbSelectArea("VO2")
DbSetOrder(1)
nSequen := -1
if !(DbSeek( xFilial("VO2") + cNumOsv + "S" ))

	RegToMemory("VO2",.T.)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Gera um Nosso Numero Requisicao ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	DbSelectArea("VO2")
	DbSetOrder(2)
	Do While Empty(M->VO2_NOSNUM) .Or. DbSeek( xFilial("VO2")+M->VO2_NOSNUM )
		M->VO2_NOSNUM := GetSxeNum("VO2","VO2_NOSNUM",,2)
		ConfirmSx8()
	EndDo

	DbSelectArea("VO2")
	DbSetOrder(1)
	If !RecLock("VO2",.T.)
		sRestArea(aArea)
		Help("  ",1,"REGNLOCK")
		Return .f.
	EndIf

	FG_GRAVAR("VO2")
	VO2->VO2_TIPREQ := "S"

	If VO2->(FieldPos("VO2_DATALT")) > 0 .and. lAlterou
		VO2->VO2_DATALT := DDATABASE
	EndIf

	MsUnlock()

else
	DBSelectArea("VO4")
	DBSetOrder(8)
	DBSeek(xFilial("VO4")+VO2->VO2_NOSNUM)
	while !eof() .and. VO4->VO4_FILIAL+VO4->VO4_NOSNUM == xFilial("VO4")+VO2->VO2_NOSNUM
		nSequen :=  val(VO4->VO4_SEQUEN)
		DBSkip()
	enddo
endif

//
DBSelectArea("VOI")
DbSetOrder(1)
DbSeek( xFilial("VOI") + cTTFranquia )

DBSelectArea("VO4")
reclock("VO4",.t.)
VO4->VO4_FILIAL := xFilial("VO4")
VO4->VO4_TIPTEM := cTTFranquia
VO4->VO4_FATPAR := cCodCliente
VO4->VO4_LOJA   := cLojCliente
VO4->VO4_GRUSER := VOI->VOI_GRUSER
VO4->VO4_CODSER := VOI->VOI_CODSER
VO4->VO4_TIPSER := VOI->VOI_TIPSER
VO4->VO4_CODTES := VOI->VOI_CODTES
VO4->VO4_CODSEC := VOI->VOI_CODSEC
VO4->VO4_VALVEN := VO1->VO1_FRANQU
VO4->VO4_SERINT := Posicione("VO6",2,xFilial("VO6") + FG_MARSRV(VO1->VO1_CODMAR,VOI->VOI_CODSER) + VOI->VOI_CODSER, "VO6_SERINT" )
VO4->VO4_VALHOR := VO1->VO1_FRANQU
VO4->VO4_NOSNUM := VO2->VO2_NOSNUM
VO4->VO4_SEQUEN := STRZERO(nSequen+1,8)
VO4->VO4_NUMOSV := VO1->VO1_NUMOSV
VO4->VO4_VHRDIG := "0"
VO4->VO4_CODPRO := VO2->VO2_FUNREQ
MsUnLock()

sRestArea(aArea)

Return .t.

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Funo    | OM030V     | Autor |  Thiago		          | Data | 05/01/12 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrio | Pesquisa Avancada                                            |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OM030V()
nOpc := 1
OFIOC450()
Return(.t.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_VerAponบAutor  ณManoel              บ Data ณ  20/10/2012 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica a posi็ใo VO4 do momento da Abertura da Requisi็ใoบฑฑ
ฑฑบ          ณ versus sua posi็ใo no momento da Grava็ใo. Grava se estiverบฑฑ
ฑฑบ          ณ OK, senใo nใo permite a grava็ใo.                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณOficina - Apontamento de Produtivos                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_VerApon(lOperacao)

Local lRet := .t.
Local ni1   := 0
Local ni2  := 0
Local ni3  := 0
Local ni4  := 0

Local aVetVO4Atu := FMX_CALSER(M->VO2_NUMOSV,,,,.t.)

If Len(aVetVO4Atu) == Len(aVetVO4Ini)

	For ni1 := 1 to Len(aVetVO4Atu)

		For ni2 := 1 to Len(aVetVO4Atu[ni1])

			// Valores de requisicao
			if ni2 <> 14
				if aVetVO4Atu[ni1,ni2] <> aVetVO4Ini[ni1,ni2]
					lRet := .f.
					ni2 := Len(aVetVO4Atu[ni1])
					ni1 := Len(aVetVO4Atu)
				Endif

			// Verifica apontamento de servico
			Else

				// Houve alteracao de apontamento
				If Len(aVetVO4Atu[ni1,ni2]) <> Len(aVetVO4Ini[ni1,ni2])
					lRet := .f.
					ni2 := Len(aVetVO4Atu[ni1])
					ni1 := Len(aVetVO4Atu)
				Else

					// Verifica apontamento por apontamento
					For ni3 := 1 to Len(aVetVO4Atu[ni1,ni2])
						For ni4 := 1 to Len(aVetVO4Atu[ni1,ni2,ni3])
							if aVetVO4Atu[ni1,ni2,ni3,ni4] <> aVetVO4Ini[ni1,ni2,ni3,ni4]
								lRet := .f.
								ni4  := Len(aVetVO4Atu[ni1,ni2,ni3])
								ni3  := Len(aVetVO4Atu[ni1,ni2])
								ni2  := Len(aVetVO4Atu[ni1])
								ni1  := Len(aVetVO4Atu)
							Endif
						Next
					Next
					//

				Endif
				//

			Endif

		Next

	Next

Else

	lRet := .f.

Endif

If !lRet
	MsgInfo(STR0155,STR0066)
Endif

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao ณ FS_030VLAP  ณ Autor ณ Rubens Takahashi      ณ Data ณ 29/10/12 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Valida se o produtivo esta trabalhando em outro servico    ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OM030VLAP( cCodPro , dDatIni , nHorIni , cNosNum , cSequen, lCheckACols )

Local cQuery
Local lRetorno := .t.
Local cMsg
Local cAliasAPO := "TAPOABE"
Local aArea := GetArea()
Local nPosScan

Default cNosNum := ""
Default cSequen := ""
Default lCheckACols := .t. // CUIDADO: Parametro criado para chamada atraves da API. Neste caso, nao existe aCols, por isso que a valida็ใo nao deve considerar o conteudo da aCols

Conout(" ")
Conout("OM030VLAP")
Conout("ProcName: " + alltrim(procname(1)) + " - " + cvaltochar(procline(1)))
Conout("        : " + alltrim(procname(2)) + " - " + cvaltochar(procline(2)))
Conout(" ")
conout("len(aCols)  : " + cvaltochar(Len(aCols)))
conout("n           : " + cvaltochar(n))
conout("readvar     : " + cvaltochar(readvar()))
Conout("cCodPro     : " + alltrim(cvaltochar(cCodPro)))
Conout("dDatIni     : " + alltrim(cvaltochar(dDatIni)))
Conout("nHorIni     : " + alltrim(cvaltochar(nHorIni)))
Conout("cNosNum     : " + alltrim(cvaltochar(cNosNum)))
Conout("cSequen     : " + alltrim(cvaltochar(cSequen)))
Conout("lCheckACols : " + alltrim(cvaltochar(lCheckACols)))
Conout(" ")
varinfo("aCols",aCols[n])
Conout(" ")

cQuery := "SELECT VO4.VO4_NUMOSV, VO4.VO4_GRUSER, VO4.VO4_CODSER, VO4.VO4_DATINI, VO4.VO4_HORINI, VO4.VO4_DATFIN , VO4.VO4_HORFIN "
cQuery +=  " FROM " + RetSQLName("VO4") + " VO4 "
cQuery += " WHERE VO4_FILIAL = '" + xFilial("VO4") + "'"
cQuery +=   " AND VO4.VO4_CODPRO = '" + cCodPro + "'"
cQuery +=   " AND VO4.VO4_DATINI = '" + DtoS(dDatIni) + "'"
cQuery +=   " AND VO4.VO4_HORINI = " + Str(nHorIni,4)
cQuery +=   " AND VO4.VO4_DATCAN = '  ' "
If ! Empty(cNosNum)
	cQuery +=   " AND ( "
	cQuery +=		"( VO4.VO4_NOSNUM <> '" + cNosNum + "' )"
	cQuery +=   	" OR "
	cQuery +=		"( VO4.VO4_NOSNUM = '" + cNosNum + "' AND VO4.VO4_SEQUEN <> '" + cSequen + "' )"
	cQuery +=	" ) "
EndIf
cQuery +=   " AND VO4.D_E_L_E_T_ = ' '"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAliasAPO, .F., .T. )
If !(cAliasAPO)->(Eof())
	lRetorno := .f.

	cMsg := STR0156 + CHR(13) + CHR(13) +; //  "Produtivo trabalhando em outro servi็o"
			AllTrim(RetTitle("VO1_NUMOSV")) + ": " + (cAliasAPO)->VO4_NUMOSV + CHR(13) + ;
			AllTrim(RetTitle("VO4_CODSER")) + ": " + (cAliasAPO)->VO4_GRUSER + " - " + (cAliasAPO)->VO4_CODSER + CHR(13) + ;
				AllTrim(RetTitle("VO4_DATINI")) + ": " + Transform(StoD((cAliasAPO)->VO4_DATINI),"@D") + " - " + Transform((cAliasAPO)->VO4_HORINI,"@R 99:99") + CHR(13) + ;
				AllTrim(RetTitle("VO4_DATFIN")) + ": " + Transform(StoD((cAliasAPO)->VO4_DATFIN),"@D") + " - " + Transform((cAliasAPO)->VO4_HORFIN,"@R 99:99")

EndIf
(cAliasAPO)->(dbCloseArea())
RestArea( aArea )
dbSelectArea("VO4")

// Se nใo encontrar na base, procura na aCols ...
If lRetorno .and. lCheckACols
	nPosScan := aScan(aCols,{ |x| x[FG_POSVAR("VO4_CODPRO","aHeader")] == cCodPro .and. x[FG_POSVAR("VO4_DATINI","aHeader")] == dDatIni .and. x[FG_POSVAR("VO4_HORINI","aHeader")] == nHorIni .and. x[FG_POSVAR("VO4_SEQUEN","aHeader")] <> cSequen .and. !x[Len(x)] } )
	If nPosScan > 0

		conout("nPosScan: " + cvaltochar(nPosScan))

		lRetorno := .f.

		cMsg := STR0156 + CHR(13) + CHR(13) + ; //  "Produtivo trabalhando em outro servi็o"
			AllTrim(RetTitle("VO4_CODSER")) + ": " + aCols[nPosScan,FG_POSVAR("VO4_GRUSER","aHeader")] + " - " + aCols[nPosScan,FG_POSVAR("VO4_CODSER","aHeader")] + CHR(13) + ;
				AllTrim(RetTitle("VO4_DATINI")) + ": " + Transform(aCols[nPosScan,FG_POSVAR("VO4_DATINI","aHeader")] , "@D") + " - " + Transform(aCols[nPosScan,FG_POSVAR("VO4_HORINI","aHeader")] , "@R 99:99") + chr(13) + ;
				AllTrim(RetTitle("VO4_DATFIN")) + ": " + Transform(aCols[nPosScan,FG_POSVAR("VO4_DATFIN","aHeader")] , "@D") + " - " + Transform(aCols[nPosScan,FG_POSVAR("VO4_HORFIN","aHeader")] , "@R 99:99")

	EndIf
EndIf
//

If !lRetorno
	Help( NIL, NIL, "OM030ERR06", , cMsg , 1, 0 ) // "Produtivo trabalhando em outro servi็o"
EndIf

Return lRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao ณ FS_PAUSASERV ณ Autor ณ Thiago			    ณ Data ณ 11/05/13 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Grava็ใo do motivo da pausa.							      ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_PAUSASERV()

Local nPosMot := 0
Private aMotCancel := {}

If FindFunction("FM_GerLog") //funcao que grava log  - OFIXFUNA
	//verifica se nao eh finalizacao por final do period o de trabalho
	//selecionar se eh uma pausa ou finalizacao do servico
	If MsgYesNo(STR0157,OemToAnsi(STR0158) )//ษ uma pausa do servico / Aten็ใo
		nPosMot := aScan(aDelMotiv,{|x| x[1] == oGetSrv:oBrowse:nAt })
		If nPosMot <= 0
			aAdd(aDelMotiv,{oGetSrv:oBrowse:nAt,{}})
			nPosMot := len(aDelMotiv)
		EndIf
		aMotCancel := OFA210MOT("000006","2","","",.f.) // Filtro da consulta do motivo
		If len(aMotCancel) <= 0
			aDelMotiv[nPosMot,2] := {}
		Else
			cMotCan := aMotCancel[1]
			aDelMotiv[nPosMot,2] := aClone(aMotCancel)
			cMotPausa := aMotCancel[1]
			VS0->(dbSeek(xFilial("VS0")+"000006"+cMotPausa))
			cLogTexto:= STR0159+ VO4->VO4_NUMOSV + STR0160+ VO4->VO4_TIPTEM + STR0161 +Left(VO4->VO4_CODSER,11) + STR0162 + cMotPausa+":"+Left(VS0->VS0_DESMOT,19)+" "+ STR0163 +" "+M->VO4_CODPRO+"-"+Left(VAI->VAI_NOMTEC,19) //  pausou OS: / , TT: / , Srv: / , Mot: / prod:
			FM_GerLog("P",,cLogTexto)
			If FG_POSVAR("VO4_MPAUSA","aHeaderIniFim") # 0
			   M->VO4_MPAUSA := cMotPausa
			   dbSelectArea("VS0")
			   dbSetOrder(1)
			   dbSeek(xFilial("VS0")+"000006"+M->VO4_MPAUSA)
			   M->VO4_DESMPA := VS0->VS0_DESMOT
	           aColsIniFim[n,FG_POSVAR("VO4_MPAUSA","aHeaderIniFim")] := M->VO4_MPAUSA
	           aColsIniFim[n,FG_POSVAR("VO4_DESMPA","aHeaderIniFim")] := M->VO4_DESMPA
	           aCols[n,FG_POSVAR("VO4_MPAUSA","aHeader")] := M->VO4_MPAUSA
	           aCols[n,FG_POSVAR("VO4_DESMPA","aHeader")] := M->VO4_DESMPA
	           oGetIniFim:oBrowse:Refresh()
			Endif
		EndIf
	EndIF
EndIF
Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAjustaHelpบAutor  ณRubens              บ Data ณ  01/10/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAjusta Help da Funcao                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
//Static Function AjustaHelp()
//
//Local aHelpEng, aHelpSpa, aHelpPor
//
//aHelpPor := { STR0127 } // Valor informado nใo permitido.
//aHelpEng := aHelpSpa :=	aHelpPor
//PutHelp("PM030VALHOR",aHelpPor,aHelpEng,aHelpSpa,.f.)
//
//aHelpPor := { STR0164 } // O rateio estแ divergente para o produtivo.
//aHelpEng := aHelpSpa :=	aHelpPor
//PutHelp("PM030RATDIV",aHelpPor,aHelpEng,aHelpSpa,.f.)
//
//aHelpPor := { STR0165 } // A soma dos percentuais nใo pode ser maior que 100%
//aHelpEng := aHelpSpa :=	aHelpPor
//PutHelp("PM030DIV100",aHelpPor,aHelpEng,aHelpSpa,.f.)
//
//aHelpPor := { STR0166 } // Preencha o c๓digo do produtivo.
//aHelpEng := aHelpSpa :=	aHelpPor
//PutHelp("PM030OBRPRO",aHelpPor,aHelpEng,aHelpSpa,.f.)
//
//aHelpPor := { STR0167,STR0168 } // Usuแrio sem acesso para informar / valor fixo de servi็o.
//aHelpEng := aHelpSpa :=	aHelpPor
//PutHelp("PM030VALSER",aHelpPor,aHelpEng,aHelpSpa,.f.)
//
//aHelpPor := { STR0169,STR0170 } // Valor fixo de servi็o informado / nใo permitido.
//aHelpEng := aHelpSpa :=	aHelpPor
//PutHelp("PM030VALSER2",aHelpPor,aHelpEng,aHelpSpa,.f.)
//
//aHelpPor := { "Produtivo com hora aberta." }
//aHelpEng := aHelpSpa :=	aHelpPor
//PutHelp("PM030HORABE",aHelpPor,aHelpEng,aHelpSpa,.f.)
//
//Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณOM030FEC  บAutor  ณThiago              บ Data ณ  18/11/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณChamada do fechamemto.             	                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OM030FEC()
Private nOpc := 2
Private cGetVersao := GetVersao(.f.) // "P10" ou "11"

If cGetVersao == "P10"
	OFIOM160(.f.)
Else
	OFIXA100(.T.)
Endif
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณ FS_SELECIONA Autor ณ  THIAGO             ณ Data ณ 27/05/14 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Marca/Desmarca TOTAL Vetor de Alteracao.                   ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_SELECIONA(lMarcar)
Local nLine := 0

if Empty(M->VO4_TIPTEM)
	Return(.f.)
Endif

If ExistBlock("OM030VTS")
	If !ExecBlock("OM030VTS",.f.,.f.,{2,M->VO4_TIPSER,M->VO4_TIPTEM,.f.,.f.})
		Return .f.
	EndIf
EndIf

For nLine:=1 to Len(aServicos)
	aServicos[nLine,1] := lMarcar
Next
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณ OM030VALSER บAutor  ณ Rubens Takahashi บ Data ณ 16/12/14   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida se o usuario pode informar um valor fixo de servico บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OM030VALSER(cCodSrv, nValSerFixo, nVlrValid)

Local nPerValSer
Local nValDif
Local nValTot
Default nVlrValid := -1 // Levantar o Valor PADRAO do Servico

If VAI->(FieldPos("VAI_VALSER")) == 0 .or. ( lOM030Auto .and. cPaisLoc <> "BRA" .and. FWIsInCallStack("OFNJD15OS") )
	Return lOM030Auto // Se for chamada de ExecAuto, podera ser feita alteracao do valor do servico (Utilizado na Garantia John Deere)
EndIf

If nValSerFixo == 0
	Return .t.
EndIf

If VOK->VOK_INCMOB $ "2" // Nao valida para servico de terceiros ...
	Return .t.
EndIf

nPerValSer := FM_SQL("SELECT VAI_VALSER FROM " + RetSQLName("VAI") + " WHERE VAI_FILIAL = '" + xFilial("VAI") + "' AND VAI_CODUSR = '" + __cUserID + "' AND D_E_L_E_T_ = ' '")

If nPerValSer <= 0
	HELP("  ",1,"M030VALSER")
	Return .f.
EndIf

If nVlrValid == -1 // Levantar o Valor PADRAO do Servico
	nValTot := OM030TOTSRV(cCodSrv,.t.)
Else
	nValTot := nVlrValid // Valor do Servi็o passado para Funcao
EndIf
nValDif := nValTot * ( nPerValSer / 100 )
If ABS( nValTot - nValSerFixo ) > nValDif
	Help("  ",1,"M030VALSER2")
	Return .f.
EndIf

Return .t.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณ OM030TOTSRV บAutor  ณ Rubens Takahashi บ Data ณ 16/12/14   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna o total do servico                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function OM030TOTSRV(cCodSrv,lVldValSer)

Local lVO6VALSER := VO6->(FieldPos("VO6_VALSER")) > 0
Local lVO4PREKIL := VO4->(FieldPos("VO4_PREKIL")) <> 0

Local lVOKMOEDA  := VOK->(FieldPos("VOK_MOEDA" )) <> 0
Local nPreKil    := 0

Local nValTot := 0

Default lVldValSer := .f.

// Tipo de Servico de KM
If VOK->VOK_INCMOB $ "5"
	nPreKil := VOK->VOK_PREKIL
	If lVOKMOEDA .and. VOK->VOK_MOEDA <> VO1->VO1_MOEDA
		nPreKil := FG_MOEDA(nPreKil, VOK->VOK_MOEDA, VO1->VO1_MOEDA)
	EndIf
	If lVO4PREKIL .AND. M->VO4_PREKIL <> 0
		nPreKil := M->VO4_PREKIL
	EndIf
	nValTot := M->VO4_KILROD * nPreKil
//
Else

	// Verifica se foi informado um valor fixo de servico na requisicao
	If M->VO4_VALSER <> 0 .and. !lVldValSer
		nValTot := M->VO4_VALSER
	EndIf

	// Verifica se tem valor de fixo de servico
	If lVO6VALSER .and. nValTot == 0

		OFM0300011_PosicionaVO6( cCodSrv )

		If VO6->VO6_VALSER > 0 // Valor Fixo para o Servico
			nValTot := VO6->VO6_VALSER
		EndIf

	EndIf

	If nValTot == 0
		nValTot := (M->VO4_TEMPAD /100) * M->VO4_VALHOR
	EndIf

EndIf

Return nValTot

/*/{Protheus.doc} OM030KEYF4
Execu็ใo da tecla de atalho F4
@author Renato Vinicius
@since 26/07/2017
@version undefined
@type function
/*/

Static Function OM030KEYF4()

if readvar() $ "M->VO4_CODSER"
	OM030CSRV()
ElseIf readvar() $ "M->VO4_PEDCOM"
	OFM0300031_SelecionaPedido()
EndIf

Return

/*/{Protheus.doc} OM030CSRV
Montagem da tela de sele็ใo de servi็os atrav้s da tecla de atalho f4
@author Renato Vinicius
@since 26/07/2017
@version undefined
@type function
/*/
Function OM030CSRV(cOkFunc)

	Local oInterface := DMS_InterfaceHelper():New()
	Local oSizePrinc
	Local cRetFunc

	Default cOkFunc := "OM030DBSEL"

	Private cVeiMod := VV1->VV1_MODVEI
	Private cModDes := VV1->VV1_CODMAR+" "+Alltrim(VV1->VV1_MODVEI)+" - "+VV2->VV2_DESMOD
	Private cGruMod := VV2->VV2_GRUMOD

	Private cPesqCodSer := space(TamSX3("VO6_CODSER")[1])
	Private cPesqDesSer := space(TamSX3("VO6_DESSER")[1])

	Private nPosGruSer := 1

	oInterface:nOpc := 3

	//oInterface:SetOwnerPvt("OFIOM030")
	oInterface:SetOwnerPvt("OM030CSRV")

//Tamanho do Form superior
	oSizePrinc := oInterface:CreateDefSize( .t. , ;
		{ ;
			{ "LINHA1" , 100 , 053 , .T. , .F. } ,; //
			{ "LINHA2" , 100 , 100 , .T. , .T. }  ; //
		} , ,  )
	oSizePrinc:aMargins := { 0 , 2 , 0 , 0 }
	oSizePrinc:Process()

	oInterface:SetDefSize(oSizePrinc)
	oDlgOFM30 := oInterface:CreateDialog("Servi็os")
	oInterface:SetDialog(oDlgOFM30)

// Tamanho da coluna do Form inferior
	oSizeL2 := oInterface:CreateDefSize( .f. , ;
		{ ;
			{ "COLUNA1" , 040 , 100 , .T. , .T. } ,; //
			{ "COLUNA2" , 060 , 100 , .T. , .T. }  ; //
		},;
		oSizePrinc:GetNextCallArea("LINHA2") , )
	oSizeL2:lLateral := .t.
	oSizeL2:Process()

// Campos que serใo apresentados no form superior
	oInterface:SetDialog( oDlgOFM30 )
	oInterface:SetDefSize(oSizePrinc,"LINHA1")
	oPanModel := oInterface:CreateTPanel()
	oInterface:SetDialog( oPanModel )

	oInterface:CreateTGet({;
		{"NOMEOBJ","oGetMod"},;
		{"LINHA",04},;
		{"COLUNA",10},;
		{"NOMEVAR","cModDes"},;
		{"LARGURA",200},;
		{"READONLY",.t.},;
		{"PICTURE","@!"},;
		{"WHEN",".f."},;
		{"HASBUTTON",.f.},;
		{"LABEL",STR0171};
		})

	oInterface:CreateTGet({;
		{"NOMEOBJ","oGetCodSer"},;
		{"LINHA",20},;
		{"COLUNA",10},;
		{"NOMEVAR","cPesqCodSer"},;
		{"LARGURA",90},;
		{"READONLY",.f.},;
		{"PICTURE",X3PICTURE("VO4_CODSER")},;
		{"VALID","OM030VLDF4('"+cOkFunc+"')"},;
		{"HASBUTTON",.f.},;
		{"LABEL",STR0172};
		})

	oInterface:CreateTGet({;
		{"NOMEOBJ","oGetDesSer"},;
		{"LINHA",36},;
		{"COLUNA",10},;
		{"NOMEVAR","cPesqDesSer"},;
		{"LARGURA",190},;
		{"READONLY",.f.},;
		{"PICTURE",X3PICTURE("VO6_DESSER")},;
		{"VALID","OM030VLDF4('"+cOkFunc+"')"},;
		{"HASBUTTON",.f.},;
		{"LABEL",STR0173};
		})

// List box de Grupo de Servico que serแ apresentada no form inferior
	oInterface:SetDialog( oDlgOFM30 )
	oInterface:SetDefSize(oSizeL2,"COLUNA1")
	oPanGruSrvc := oInterface:CreateMGroup( { { "TEXTO" , STR0174 } }) // Grupo de Servi็o

	oInterface:Clean()
	oInterface:SetDialog( oPanGruSrvc )
	oInterface:AddColLBox( { { "X3" , "VOS_CODGRU" } } )
	oInterface:AddColLBox( { { "X3" , "VOS_DESGRU" } } )

	oGetDGruSer := oInterface:CreateLBox("oGetDGruSer",;
							{{"ALINHAMENTO",CONTROL_ALIGN_ALLCLIENT}})
	oGetDGruSer:SetArray(OM030LGRSRV(cOkFunc,VV1->VV1_CODMAR))
	oGetDGruSer:nAt := nPosGruSer

// // List box de Servicos que serแ apresentada no form inferior
	oInterface:Clean()
	oInterface:SetDialog( oDlgOFM30 )
	oInterface:SetDefSize(oSizeL2,"COLUNA2")
	oPanSrvc := oInterface:CreateMGroup( { { "TEXTO" , STR0013 } }) // Servi็os

	oInterface:Clean()
	oInterface:SetDialog( oPanSrvc )
	oInterface:AddColLBox( { { "X3" , "VO6_CODSER" } } )
	oInterface:AddColLBox( { { "X3" , "VO6_DESSER" } } )
	oInterface:AddColLBox( { { "X3" , "VO6_TEMFAB" } } )
	oInterface:AddColLBox( { { "X3" , "VO6_DETENG" } } )

	cRetFunc := AllTrim(cOkFunc) + "( oGetDGruSer:aArray[oGetDGruSer:nAt,1], oGetDSer:aArray[oGetDSer:nAt,1])"

//Complemento das configura็๕es do form inferior
	oGetDSer := oInterface:CreateLBox("oGetDSer",;
							{{"ALINHAMENTO",CONTROL_ALIGN_ALLCLIENT}})
	oGetDSer:SetArray(OM030LVSRV(oGetDGruSer:aArray[oGetDGruSer:nAt,1],VV1->VV1_CODMAR))
	oGetDSer:bLDblClick := { || ;
		IIf ( &(cRetFunc),;
		oDlgOFM30:End() ,;
		.t. ) }

	oGetDGruSer:bChange := { || oGetDSer:SetArray(OM030LVSRV(oGetDGruSer:aArray[oGetDGruSer:nAt,1],VV1->VV1_CODMAR)) , oGetDSer:Refresh()}

// Ativa็ใo para apresenta็ใo da tela
//	ACTIVATE MSDIALOG oDlgOFM30 ;
//		ON INIT EnchoiceBar(oDlgOFM30 ,;
//								{ || IIf( OM030DBSEL(oGetDGruSer:aArray[oGetDGruSer:nAt,1], oGetDSer:aArray[oGetDSer:nAt,1]) ,;
//													oDlgOFM30:End() ,;
//													.F. ) },;
//								{ || oDlgOFM30:End() },,)
	ACTIVATE MSDIALOG oDlgOFM30 ;
		ON INIT EnchoiceBar(oDlgOFM30 ,;
								{ || IIf( &(cRetFunc) ,;
										oDlgOFM30:End() ,;
										.F. ) },;
								{ || oDlgOFM30:End() },,)

Return

/*/{Protheus.doc} OM030LGRSRV
Levantamento de dados da tela de sele็ใo de grupo de servi็os
@author Renato Vinicius
@since 26/07/2017
@version undefined
@type function
/*/
Static Function OM030LGRSRV(cOkFunc,cCodMarca)

Local aRetorno := {}
Local cQuery   := ""

cQuery := "SELECT DISTINCT VOS.VOS_CODGRU, VOS.VOS_DESGRU "
cQuery += " FROM " + RetSqlName("VOS") + " VOS "
cQuery += " JOIN "
cQuery += "( " + OM030SQLVO6( "" , " IN ('" + cCodMarca + "',' ') " , .f. ) + " ) " // Verifica se existe Servicos para o Grupo de Modelo / Marca
cQuery += "FILTRO ON VOS.VOS_CODGRU = FILTRO.VO6_GRUSER    AND VOS.VOS_CODMAR = FILTRO.VO6_CODMAR"
cQuery += " WHERE VOS.VOS_FILIAL = '" + xFilial("VOS") + "'"
cQuery +=   " AND VOS.D_E_L_E_T_ = ' ' "
cQuery +=   " ORDER BY VOS.VOS_CODGRU "
TcQuery cQuery New Alias "GSRVTMP"
While !GSRVTMP->(Eof())
	aAdd(aRetorno,{	GSRVTMP->VOS_CODGRU,; //Codigo do Grupo
					GSRVTMP->VOS_DESGRU}) //Descri็ใo
	If cOkFunc == "OM030DBSEL" // Requisicao de Servicos - OFIOM030
		If !Empty(M->VO4_GRUSER) .and. GSRVTMP->VOS_CODGRU == M->VO4_GRUSER
			nPosGruSer := len(aRetorno) // Posiciona no Grupo de Servico selecionado na Requisicao de Servicos
		EndIf
	ElseIf cOkFunc == "OX001DBSEL" // Orcamento - OFIXX001
		If !Empty(M->VS4_GRUSER) .and. GSRVTMP->VOS_CODGRU == M->VS4_GRUSER
			nPosGruSer := len(aRetorno) // Posiciona no Grupo de Servico selecionado no Orcamento
		EndIf
	EndIf
	GSRVTMP->(DbSkip())
EndDo

If Len(aRetorno) == 0
	aAdd(aRetorno,{	"",; //Codigo do Grupo
					""}) //Descri็ใo
EndIf

GSRVTMP->(dbCloseArea())
DbSelectArea("VOS")

Return aRetorno

/*/{Protheus.doc} OM030LVSRV
Levantamento dos dados da tela de sele็ใo de servi็os
@author Renato Vinicius
@since 26/07/2017
@version undefined
@param cGrpSrv, characters, descricao
@type function
/*/
Static Function OM030LVSRV( cGrpSrv , cCodMarca )

Local aRetorno := {}
Local cQuery   := ""
Default cCodMarca := VO1->VO1_CODMAR

cQuery := OM030SQLVO6( " = '" + cGrpSrv + "'" , " IN ('" + cCodMarca + "',' ') " , .t. ) // Levanta Servicos para o Grupo de Modelo / Marca Especifica ou Marca em branco

TcQuery cQuery New Alias "SRVTMP"

While !SRVTMP->(Eof())
	aAdd(aRetorno,{	SRVTMP->VO6_CODSER,; //Codigo do Servico
					SRVTMP->VO6_DESSER,; //Descri็ใo
					SRVTMP->VO6_TEMFAB,; //Descri็ใo da engenharia
					SRVTMP->VO6_DETENG}) //Tempo Padrใo
	SRVTMP->(DbSkip())
EndDo

SRVTMP->(dbCloseArea())
dbSelectArea("VO6")

If Len(aRetorno) == 0
	aAdd(aRetorno,{	"",; //Codigo do Servico
				 	"",; //Descri็ใo
				 	"",; //Tempo Padrใo
					""}) //Descri็ใo da engenharia
EndIf

Return aRetorno

/*/{Protheus.doc} OM030DBSEL
Selecใo do servi็o
@author Renato Vinicius
@since 26/07/2017
@version undefined
@param cParGrpSer, characters, descricao
@param cParCodSer, characters, descricao
@type function
/*/

Static Function OM030DBSEL(cParGrpSer,cParCodSer)

Local lRetorno := .t.

If .f. // Para nao dar Warning
	OM030DBSEL(cParGrpSer,cParCodSer)
EndIf

__ReadVar := 'M->VO4_GRUSER'
aCols[n,FG_POSVAR("VO4_GRUSER")] := M->VO4_GRUSER := cParGrpSer
lRetorno := FS_030VALID('F')

If lRetorno
	__ReadVar := 'M->VO4_CODSER'
	M->VO4_CODSER := cParCodSer
Else
	aCols[n,FG_POSVAR("VO4_GRUSER")] := M->VO4_GRUSER := Space(TamSx3("VO4_GRUSER")[1])
EndIf

Return lRetorno

/*/{Protheus.doc} OM030CPLCOD
Pesquisa a base do servi็o e completa o c๓digo
@author Renato Vinicius
@since 27/07/2017
@version undefined
@type function
/*/

Static Function OM030CPLCOD(_cCodMarca,_cModVei,_cGruSer,_cCodSer)

	Local cQuery := ""
	Default _cCodMarca := VV1->VV1_CODMAR

	cQuery := "SELECT VO6.VO6_CODSER"
	cQuery += " FROM " + RetSqlName("VO6") + " VO6"
	cQuery += " WHERE VO6.VO6_FILIAL = '" + xFilial("VO6") + "'"
	cQuery +=   " AND VO6.VO6_GRUSER = '" + _cGruSer       + "'"
	cQuery +=   " AND VO6.VO6_MODVEI = '" + _cModVei       + "'"
	cQuery +=   " AND VO6.VO6_CODMAR = '" + _cCodMarca     + "'"
	cQuery +=   " AND VO6.VO6_SERATI <> '0'"
	cQuery +=   " AND VO6.VO6_CODSER LIKE '" + Alltrim(_cCodSer) + "%'"
	cQuery +=   " AND VO6.D_E_L_E_T_ = ' '"

Return FM_SQL(cQuery)

/*/{Protheus.doc} OM030SQLVO6
Monta SQLs para levantar Servicos
@author Andre Luis Almeida
@since 07/11/2017
@version undefined
@type function
/*/
Static Function OM030SQLVO6(cPARGruSer,cPARCodMar,lOrdem)
Local cQuery := ""
Local oSQL

// Para os bancos de dados abaixo relacionados, ้ feita uma query para verificar se considera o servico com
// codigo da marca ou em branco. O servico com codigo igual ao do veiculo sempre sera utilizado com prioridade
If 'MSSQL' $ cSGBD
	cQuery := "SELECT FILTRO.VO6_CODMAR, VO6.VO6_GRUSER , VO6.VO6_CODSER, VO6.VO6_DETENG, VO6.VO6_DESSER, VO6.VO6_TEMFAB"
	cQuery += " FROM ("
	cQuery += "SELECT VO6.VO6_CODSER , VO6.VO6_GRUSER, VO6.VO6_CODMAR, "
	cQuery += " ROW_NUMBER() OVER ( "
	cQuery += " PARTITION BY VO6.VO6_CODSER, VO6.VO6_GRUSER "
	cQuery += " ORDER BY VO6.VO6_CODMAR DESC "
	cQuery += " ) AS RN "
	cQuery +=  " FROM " + RetSQLName("VO6") + " VO6 "
	cQuery += " WHERE VO6.VO6_FILIAL = '" + xFilial("VO6") + "' "
	cQuery +=   " AND VO6.VO6_CODMAR " + cPARCodMar
	If !Empty(cPARGruSer)
		cQuery += " AND VO6.VO6_GRUSER " + cPARGruSer
	EndIf
	If !Empty(cPesqCodSer)
		cQuery +=   " AND VO6.VO6_CODSER LIKE '" + Alltrim(cPesqCodSer)+"%'"
	EndIf
	If !Empty(cPesqDesSer)
		cQuery +=   " AND VO6.VO6_DESSER LIKE '%" + Alltrim(cPesqDesSer)+"%'"
	EndIf
	cQuery +=   " AND VO6.VO6_MODVEI IN (' ','" + cVeiMod + "') "
	cQuery +=   " AND VO6.VO6_SERATI <> '0'"
	cQuery +=   " AND VO6.D_E_L_E_T_ = ' '"
	cQuery +=  OM0300101_SQL_VO7()
	cQuery += " ) FILTRO JOIN " + RetSQLName("VO6") + " VO6 "
	cQuery +=            " ON VO6.VO6_FILIAL = '" + xFilial("VO6") + "' "
	cQuery +=           " AND VO6.VO6_GRUSER = FILTRO.VO6_GRUSER"
	cQuery +=           " AND VO6.VO6_CODSER = FILTRO.VO6_CODSER"
	cQuery +=           " AND VO6.VO6_CODMAR = FILTRO.VO6_CODMAR"
	cQuery +=           " AND VO6.D_E_L_E_T_ = ' ' AND FILTRO.RN = 1"
	If lOrdem
		cQuery += " ORDER BY VO6.VO6_CODSER"
	EndIf

ElseIf 'ORACLE' $ cSGBD .or. 'MYSQL' $ cSGBD .or. 'POSTGRES' $ cSGBD

	oSQL := DMS_SqlHelper():New()

	cQuery := "SELECT FILTRO.VO6_CODMAR, VO6.VO6_GRUSER , VO6.VO6_CODSER, VO6.VO6_DETENG, VO6.VO6_DESSER, VO6.VO6_TEMFAB"
	cQuery += " FROM ("
	cQuery += "SELECT VO6_GRUSER, VO6_CODSER, " + oSQL:CompatFunc("SUBSTR") + "(MARCA,1,3) VO6_CODMAR "
	cQuery +=  " FROM ("
	cQuery +=          " SELECT VO6_GRUSER, VO6_CODSER,"
	Do Case
	Case 'ORACLE' $ cSGBD
		cQuery +=                 " LISTAGG (VO6.VO6_CODMAR,'/') WITHIN GROUP (ORDER BY VO6.VO6_CODMAR DESC ) MARCA"
	Case 'MYSQL' $ cSGBD
		cQuery +=                 " GROUP_CONCAT(VO6.VO6_CODMAR ORDER BY VO6.VO6_CODMAR DESC SEPARATOR '/') MARCA "
	Case 'POSTGRES' $ cSGBD
		cQuery +=                 " STRING_AGG(VO6.VO6_CODMAR ,'/' ORDER BY VO6.VO6_CODMAR DESC) MARCA "
	EndCase
	cQuery +=            " FROM " + RetSQLName("VO6") + " VO6 "
	cQuery +=           " WHERE VO6_FILIAL = '" + xFilial("VO6") + "' "
	cQuery +=             " AND VO6_CODMAR " + cPARCodMar
	If !Empty(cPARGruSer)
		cQuery +=          " AND VO6.VO6_GRUSER " + cPARGruSer
	EndIf
	If !Empty(cPesqCodSer)
		cQuery +=   " AND VO6.VO6_CODSER LIKE '" + Alltrim(cPesqCodSer)+"%'"
	EndIf
	If !Empty(cPesqDesSer)
		cQuery +=   " AND VO6.VO6_DESSER LIKE '%" + Alltrim(cPesqDesSer)+"%'"
	EndIf
	cQuery +=             " AND VO6.VO6_MODVEI IN (' ','" + cVeiMod + "') "
	cQuery +=             " AND VO6_SERATI <> '0'"
	cQuery +=             " AND VO6.D_E_L_E_T_ = ' '"
	cQuery +=  OM0300101_SQL_VO7()
	cQuery +=           " GROUP BY VO6_GRUSER, VO6_CODSER ) TMP "
	cQuery += " ) FILTRO JOIN " + RetSQLName("VO6") + " VO6 "
	cQuery +=            " ON VO6.VO6_FILIAL = '" + xFilial("VO6") + "' "
	cQuery +=           " AND VO6.VO6_GRUSER = FILTRO.VO6_GRUSER"
	cQuery +=           " AND VO6.VO6_CODSER = FILTRO.VO6_CODSER"
	cQuery +=           " AND VO6.VO6_CODMAR = FILTRO.VO6_CODMAR"
	cQuery +=           " AND VO6.D_E_L_E_T_ = ' '"
	If lOrdem
		cQuery += " ORDER BY VO6.VO6_CODSER"
	EndIf
Else
	cQuery := "SELECT VO6.VO6_GRUSER , VO6_CODSER, VO6_DETENG, VO6_DESSER, VO6_TEMFAB "
	cQuery += " FROM " + RetSqlName("VO6") + " VO6"
	cQuery += " WHERE VO6.VO6_FILIAL = '" + xFilial("VO6") + "'"
	cQuery +=   " AND VO6.VO6_CODMAR " + cPARCodMar
	cQuery +=   " AND VO6.VO6_GRUSER " + cPARGruSer
	If !Empty(cPesqCodSer)
		cQuery +=   " AND VO6.VO6_CODSER LIKE '" + Alltrim(cPesqCodSer)+"%'"
	EndIf
	If !Empty(cPesqDesSer)
		cQuery +=   " AND VO6.VO6_DESSER LIKE '%" + Alltrim(cPesqDesSer)+"%'"
	EndIf
	cQuery +=   " AND VO6.VO6_MODVEI IN (' ','" + cVeiMod + "') "
	cQuery +=   " AND VO6.VO6_SERATI <> '0'"
	cQuery +=   " AND VO6.D_E_L_E_T_ = ' '"
EndIf
Return cQuery

/*/{Protheus.doc} OM030VLDF4
Validacao dos campos na Consulta de Servicos F4
@author Andre Luis Almeida
@since 09/11/2017
@version undefined
@type function
/*/
Static Function OM030VLDF4(cOkFunc)
If .f.
	OM030VLDF4(cOkFunc) // Somente para nao dar WARNING de compilacao
EndIf
oGetDGruSer:nAt := 1
oGetDGruSer:SetArray(OM030LGRSRV(cOkFunc,VV1->VV1_CODMAR))
oGetDGruSer:Refresh()
oGetDSer:SetArray(OM030LVSRV(oGetDGruSer:aArray[oGetDGruSer:nAt,1],VV1->VV1_CODMAR))
oGetDSer:Refresh()
Return

/*/{Protheus.doc} OM030AJAUTOITENS
Ajusta matriz de integra็ใo para importa็ใo de apontamento de servico
@author Rubens
@since 16/11/2017
@version 1.0
@return ${return}, ${return_description}
@param nLin, numeric, descricao
@param cCpoAjusta, characters, descricao
@param cTipTem, characters, descricao
@param cCodSer, characters, descricao
@type function
/*/
Static Function OM030AJAUTOITENS( nLin, cCpoAjusta , cTipTem , cCodSer )
	If aScan( aAutoItens[nLin] , { |x| x[1] == cCpoAjusta }) == 0
		VO4->(MSSeek( xFilial("VO4") + VO2->VO2_NOSNUM + cTipTem + cCodSer ))

		AADD( aAutoItens[nLin] , { cCpoAjusta , &("VO4->" + cCpoAjusta ) , NIL })
	EndIf
Return


/*/{Protheus.doc} OM030AJSEQUEN

Ajusta sequencia de registros quando chamado por ExecAuto de Apontamento de Servico

@author Rubens
@since 16/11/2017
@version 1.0
@return ${return}, ${return_description}
@param aAutoItens, array, descricao
@type function
/*/
Static Function OM030AJSEQUEN(aAutoItens)

	Local nLinItens
	Local cJaProc := ""

	Local nPVO4TIPTEM
	Local nPVO4CODSER
	Local nPVO4TIPSER
	Local nPVO4CODPRO

	Local cVO4TIPTEM
	Local cVO4CODSER
	Local cVO4TIPSER
	Local cVO4CODPRO

	Local cSQL
	Local cSequen

	For nLinItens := 1 to Len(aAutoItens)
		nPVO4TIPTEM := aScan(aAutoItens[nLinItens] , { |x| x[1] == "VO4_TIPTEM" } )
		nPVO4CODSER := aScan(aAutoItens[nLinItens] , { |x| x[1] == "VO4_CODSER" } )
		nPVO4TIPSER := aScan(aAutoItens[nLinItens] , { |x| x[1] == "VO4_TIPSER" } )
		nPVO4CODPRO := aScan(aAutoItens[nLinItens] , { |x| x[1] == "VO4_CODPRO" } )

		cVO4TIPTEM := aAutoItens[ nLinItens , nPVO4TIPTEM , 2 ]
		cVO4CODSER := aAutoItens[ nLinItens , nPVO4CODSER , 2 ]
		cVO4TIPSER := aAutoItens[ nLinItens , nPVO4TIPSER , 2 ]
		cVO4CODPRO := aAutoItens[ nLinItens , nPVO4CODPRO , 2 ]

		If cVO4TIPTEM + "/" + cVO4CODSER + "/" + cVO4TIPSER + "/" + cVO4CODPRO + "จ" $ cJaProc
			Loop
		EndIf

		cJaProc += cVO4TIPTEM + "/" + cVO4CODSER + "/" + cVO4TIPSER + "/" + cVO4CODPRO + "จ"

		// Verifica se tem apontamento aberto ...
		// Se possuir apontamento aberto, gravar o SEQUEN para nao gerar outro VO4_SEQUEN
		cSQL := ;
			" SELECT VO4.VO4_SEQUEN " + ;
			  " FROM " + RetSQLName("VO4") + " VO4 " + ;
			" WHERE VO4.VO4_FILIAL = '" + xFilial("VO4") + "'" + ;
			  " AND VO4.VO4_NOSNUM = '" + M->VO2_NOSNUM + "'" + ;
			  " AND VO4.VO4_TIPTEM = '" + cVO4TIPTEM + "'" + ;
			  " AND VO4.VO4_CODSER = '" + cVO4CODSER + "'" + ;
			  " AND VO4.VO4_TIPSER = '" + cVO4TIPSER + "'" + ;
			  " AND VO4.VO4_CODPRO = '" + cVO4CODPRO + "'" + ;
			  " AND VO4.VO4_DATINI <> '        '" + ;
			  " AND VO4.VO4_DATFIN = '        '" + ;
			  " AND VO4.D_E_L_E_T_ = ' '"
		cSequen := FM_SQL(cSQL)

		If !Empty(cSequen)
			//AADD( aAutoItens[nLinItens] , { "VO4_SEQUEN" , cSequen , NIL })
			AADD( aAutoItens[nLinItens] , { "LINPOS"    , "VO4_SEQUEN" , cSequen }) // Posicionamento de aCols
			AADD( aAutoItens[nLinItens] , { "AUTDELETA" , "N" , NIL })
			loop
		EndIf

		// Verifica se tem apontamento aberto ...
		// Se possuir apontamento aberto, gravar o SEQUEN para nao gerar outro VO4_SEQUEN
		cSQL := ;
			" SELECT VO4.VO4_SEQUEN " + ;
			  " FROM " + RetSQLName("VO4") + " VO4 " + ;
			" WHERE VO4.VO4_FILIAL = '" + xFilial("VO4") + "'" + ;
			  " AND VO4.VO4_NOSNUM = '" + M->VO2_NOSNUM + "'" + ;
			  " AND VO4.VO4_TIPTEM = '" + cVO4TIPTEM + "'" + ;
			  " AND VO4.VO4_CODSER = '" + cVO4CODSER + "'" + ;
			  " AND VO4.VO4_TIPSER = '" + cVO4TIPSER + "'" + ;
			  " AND VO4.VO4_DATINI = '        '" + ;
			  " AND VO4.VO4_DATFIN = '        '" + ;
			  " AND VO4.D_E_L_E_T_ = ' '"
		cSequen := FM_SQL(cSQL)

		If !Empty(cSequen)
			//AADD( aAutoItens[nLinItens] , { "VO4_SEQUEN" , cSequen , NIL })
			AADD( aAutoItens[nLinItens] , { "LINPOS"    , "VO4_SEQUEN" , cSequen }) // Posicionamento de aCols
			AADD( aAutoItens[nLinItens] , { "AUTDELETA" , "N" , NIL })
		EndIf

	Next nLinItens

Return


/*/{Protheus.doc} OM030001_AddaColsIniFim
Adiciona uma linha na aCols de apontamento de servico
@author Rubens
@since 16/11/2017
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function OM030001_AddaColsIniFim()

	Local _ni

	// Levanta pecas da OS
	aPecasReq := FS_PECREQ( aPecasReq ,;
		VO4->VO4_NOSNUM+VO4->VO4_SEQUEN ,;
		VO4->VO4_CODSER ,;
		VO4->VO4_CODPRO )
	//

	// Quando ExecAuto de Apontamento, nao adiciona na matriz de apontamento
	// os registros sem data final
	//If lAutoApont .and. Empty(VO4->VO4_DATFIN)
	//	Return
	//EndIf

	AADD(aColsIniFim,Array(nUsadoIniFim+1))
	nLinACols := Len(aColsIniFim)

	Aadd(aAlter[2],{VO4->VO4_SEQUEN})

	For _ni:=1 to nUsadoIniFim

		If aHeaderIniFim[_ni,10] # "V"
			aColsIniFim[ nLinACols ,_ni] := FieldGet( FieldPos(aHeaderIniFim[_ni,2]))
		Else
			aColsIniFim[ nLinACols ,_ni] := CriaVar( aHeaderIniFim[_ni,2] )
		EndIf

		// Controla se o registro pode ser alterado
		If aHeaderIniFim[_ni,10] # "V" ;
			.And. ( Empty(FieldGet(FieldPos(aHeaderIniFim[_ni,2]))) .Or. !(aHeaderIniFim[_ni,2] $ "VO4_CODPRO/VO4_DATINI/VO4_HORINI/VO4_DATFIN/VO4_HORFIN/") ) ;
			.And. ! ( aHeaderIniFim[_ni,2] $ "VO4_GRUSER/VO4_CODSER/" )

			Aadd(aAlter[2,Len(aAlter[2])], aHeaderIniFim[_ni,2] )

		EndIf
		//

	Next

	aColsIniFim[Len(aColsIniFim),nUsadoIniFim+1]:=.F.

Return
/*/{Protheus.doc} OM030GRUSRV
Valida็ใo da associa็ใo de Grupo de Servi็o ao tipo de tempo
@author Renato Vinicius
@since 30/11/2017
@version undefined
@type function
/*/
Function OM030GRUSRV(cCodGru,cTipTem,cCodMar,lMensagem)



Default cCodGru   := M->VO4_GRUSER
Default cTipTem   := M->VO4_TIPTEM
Default cCodMar   := VV1->VV1_CODMAR
Default lMensagem := .t.

VOX->( DbSetOrder(1) )
lConsidera := .t.
if VOI->(FieldPos("VOI_CONGSV")) > 0
	VOI->(DbSetOrder(1))
	VOI->(DbSeek( xFilial("VOI") + cTipTem ))
	if VOI->VOI_CONGSV <> "1"
		lConsidera := .f.
	endif
else
	lConsidera := .f.
endif

If !lConsidera
	Return(.t.)
EndIf

cQuery := "SELECT VOX.R_E_C_N_O_ "
cQuery += "FROM "+ RetSqlName("VOX") + " VOX "
cQuery += "WHERE VOX.VOX_FILIAL = '" + xFilial("VOX") + "' "
cQuery +=   "AND VOX.VOX_TIPTEM = '" + cTipTem +"' "
cQuery +=   "AND ( VOX.VOX_CODMAR = ' ' OR VOX.VOX_CODMAR = '" + cCodMar +"' ) "
cQuery +=   "AND VOX.VOX_CODGRU = '" + cCodGru +"' "
cQuery +=   "AND VOX.VOX_TIPREG = '2' "
cQuery +=   "AND VOX.D_E_L_E_T_ = ' ' "

nRecVOX := FM_SQL(cQuery)

If nRecVOX == 0
	If lMensagem
		Help(1,"  ","GPSERTEM")
	EndIf

	Return(.f.)
EndIf

Return(.t.)

/*/{Protheus.doc} OM030TPVLSRV
Data a ser considerada no levantamento do valor da hora do servi็o
@author Renato Vinicius
@since 14/11/2017
@version undefined
@type function
/*/
Static Function OM030TPVLSRV(cTipT,cNosN)

Local dDtReq  := dDataBase
Local lVOIVLSVAC := (VOI->(FieldPos("VOI_VLSVAC")) <> 0)

Default cTipT := ""
Default cNosN := ""

VOI->(DbSetOrder(1))
VOI->(MsSeek(xFilial("VOI")+cTipT))

If lVOIVLSVAC
	If VOI->VOI_VLSVAC == "1" // Valor da Hora baseado na data da requisicao do servico
		VO2->(DbSetOrder(2))
		If VO2->(MsSeek(xFilial("VO2")+cNosN))
			dDtReq := VO2->VO2_DATREQ
		EndIf
	ElseIf VOI->VOI_VLSVAC == "3" // Valor da Data de Abertura da OS
		dDtReq := IIf( !Empty(VO1->VO1_DATATE), VO1->VO1_DATATE , VO1->VO1_DATABE )
	EndIf
EndIf

Return dDtReq



/////////////////////////////////////////////////////////////////////////////////////////
// Fun็ใo OM030ProFil() // Retorna se o Produtivo pode ou nใo trabalhar em outra Filial
//
// Parโmetros
//   cCodPro -> C๓digo do Produtivo
//   dData   -> Data de Verifica็ใo da aloca็ใo do Produtivo
//   lMsg    -> Mostra ou nใo a mensagem
//
Function OM030ProFil(cCodPro, dData, lMsg, cProdProc )

Default lMsg := .t.
Default cProdProc := ""

cVOEFilialAlocada := OM030AlocPro(cCodPro, dData )

If cVOEFilialAlocada <> FWCodFil()

	cProdProc += VAI->VAI_CODTEC + "/"
	// Produtivo pode trabalhar em outra filial
	If VAI->VAI_PROFIL == "1"
		If lMsg
			// Utiliza ShowHelpDlg para nao dar problemas nas rotinas de execauto
			ShowHelpDlg ( "PRODUTIVOFILIAL", { STR0111+" "+VAI->VAI_CODTEC+" - "+VAI->VAI_NOMTEC+" "+STR0149 }) // Produtivo / Nใo pertence a esta Filial
		EndIf
		Return .t.
	Else
		If lMsg
			Help("  ",1,"PRODUTIVOFILIAL",,STR0111+" "+VAI->VAI_CODTEC+" - "+VAI->VAI_NOMTEC+" "+STR0149,4,1) // Produtivo / Nใo pertence a esta Filial
		EndIf
		Return .f.
	EndIf

EndIf

Return .t.


///////////////////////////////////////////////////////////////////
// Fun็ใo OM030AlocPro() // Retorna a aloca็ใo do Produtivo na Data
//
// Parโmetros
//   cCodPro -> C๓digo do Produtivo
//   dData   -> Data de Verifica็ใo da aloca็ใo do Produtivo
//
Function OM030AlocPro(cCodPro, dData )

Local lVOEFILPRO := (VOE->(FieldPos("VOE_FILPRO")) > 0)
Local cSQL
Local cVOEFilialAlocada := ""
//
VAI->(MsSeek( xFilial("VAI")+cCodPro))
//
If lVOEFILPRO
	//
	cSQL := "SELECT VOE_FILPRO "
	cSQL +=  " FROM " + RetSQLName("VOE") + " VOE "
	cSQL += " WHERE VOE.VOE_FILIAL = '" + xFilial("VOE") + "'"
	cSQL +=   " AND VOE.VOE_CODPRO = '" + cCodPro + "'"
	cSQL +=   " AND VOE.VOE_DATESC <= '" + dTos(dData) + "'"
	cSQL +=   " AND VOE.D_E_L_E_T_ = ' '"
	cSQL += " ORDER BY VOE.VOE_DATESC DESC "
	//
	cVOEFilialAlocada := FM_SQL(cSQL)
	//
Endif
//
If Empty(cVOEFilialAlocada)
	cVOEFilialAlocada := VAI->VAI_FILPRO
EndIf
//
Return cVOEFilialAlocada

//-------------------------------------------------------------------
/*/{Protheus.doc} OM0300076L_VO4Desgr
description
@author  leonardo
@since   29/04/2025
@version version
/*/
//-------------------------------------------------------------------
Function OM0300076L_VO4Desgr()
Local cRet := " "
cRet := Posicione("VOS",1,xFilial("VOS")+VV1->VV1_CODMAR+VO4->VO4_GRUSER,"VOS_DESGRU")
Return cRet

/*/{Protheus.doc} OFM0300011_PosicionaVO6
Posicionamento no VO6
@author Andre Luis Almeida
@since 20/07/2018
@param _cCodSrv, caracter, Codigo do Servico
@type function
/*/
Static Function OFM0300011_PosicionaVO6( _cCodSrv )
Local lRet := .t.
If !Empty(_cCodSrv)
	VO6->( dbSetOrder(2) )
	If !VO6->( MsSeek( xFilial("VO6") + VV1->VV1_CODMAR + _cCodSrv ) )
		VO6->( dbSetOrder(4) )
		If !VO6->( MsSeek( xFilial("VO6") + _cCodSrv ) )
			lRet := .f.
		EndIf
	EndIf
EndIf
Return lRet

/*/{Protheus.doc} OFM0300025_LevantaValorServicosGrid

@author Renato Vinicius
@since 22/12/2023
@param
@type function
/*/
Static Function OFM0300025_LevantaValorServicosGrid( nLinAtual )

	Local ni        := 0
	Local nRetValor := 0
	Local nAuxValHor:= 0
	Local nAuxTemPad:= 0

	Default nLinAtual := 0

	For ni := 1 to len(aCols)
		If !aCols[ni,Len(aCols[ni])]
			If nLinAtual == nI
				nAuxValHor := FG_ValHor(M->VO4_TIPTEM,OM030TPVLSRV(M->VO4_TIPTEM,M->VO2_NOSNUM),"1",M->VO4_VALHOR,VV1->VV1_CODMAR,M->VO4_CODSER,M->VO4_TIPSER,M->VO4_FATPAR,M->VO4_LOJA,VV1->VV1_MODVEI,VV1->VV1_SEGMOD,Iif(lMultMoeda, VO1->VO1_MOEDA, nil),Iif(lMultMoeda, VO1->VO1_TXMOED, nil))
				nAuxTemPad := M->VO4_TEMPAD / 100
			Else
				nAuxValHor := FG_ValHor(aCols[ni,FG_POSVAR("VO4_TIPTEM")],OM030TPVLSRV(aCols[ni,FG_POSVAR("VO4_TIPTEM")],M->VO2_NOSNUM),"1",aCols[ni,FG_POSVAR("VO4_VALHOR")],VV1->VV1_CODMAR,aCols[ni,FG_POSVAR("VO4_CODSER")],aCols[ni,FG_POSVAR("VO4_TIPSER")],aCols[ni,FG_POSVAR("VO4_FATPAR")],aCols[ni,FG_POSVAR("VO4_LOJA")],VV1->VV1_MODVEI,VV1->VV1_SEGMOD,Iif(lMultMoeda, VO1->VO1_MOEDA, nil),Iif(lMultMoeda, VO1->VO1_TXMOED, nil))
				nAuxTemPad := aCols[ni,FG_POSVAR("VO4_TEMPAD")] / 100
			EndIf
			nRetValor += Round(nAuxValHor * nAuxTemPad,2)
		Endif
	Next

Return nRetValor

/*/{Protheus.doc} OFM0300031_SelecionaPedido
Selecionar PEDIDO relacionado ao Servi็o de Terceiro

@author Andre Luis Almeida
@since 25/02/2025

@type function
/*/
Function OFM0300031_SelecionaPedido()

	Local aObjects   := {} , aInfo := {}, aPos := {}
	Local aSizeHalf  := MsAdvSize(.t.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
	Local aCamposC7  := {} // Array para campos da tabela temporแria e campos da View
	Local lVO4IPDCOM := ( VO4->(FieldPos("VO4_IPDCOM")) > 0 )
	Local aBkpRot    := aClone(aRotina)

	aRotina := {}

	VOK->(DbSeek(xFilial("VOK")+M->VO4_TIPSER))
	SB1->(DbSetOrder(7))
	SB1->(DbSeek(xFilial("SB1")+VOK->VOK_GRUITE+VOK->VOK_CODITE))
	SB1->(DbSetOrder(1))

	aadd(aCamposC7, {"WC7_NUMPED",GetSX3Cache("C7_NUM"    ,"X3_TIPO"),GetSX3Cache("C7_NUM"    ,"X3_TAMANHO"),0} ) // Nro.Pedido
	aadd(aCamposC7, {"WC7_ITEPED",GetSX3Cache("C7_ITEM"   ,"X3_TIPO"),GetSX3Cache("C7_ITEM"   ,"X3_TAMANHO"),0} ) // Item Pedido
	aadd(aCamposC7, {"WC7_EMISSA",GetSX3Cache("C7_EMISSAO","X3_TIPO"),GetSX3Cache("C7_EMISSAO","X3_TAMANHO"),0} ) // Data do Pedido
	aadd(aCamposC7, {"WC7_CODFOR",GetSX3Cache("C7_FORNECE","X3_TIPO"),GetSX3Cache("C7_FORNECE","X3_TAMANHO"),0} ) // Fornecedor
	aadd(aCamposC7, {"WC7_LOJFOR",GetSX3Cache("C7_LOJA"   ,"X3_TIPO"),GetSX3Cache("C7_LOJA"   ,"X3_TAMANHO"),0} ) // Loja
	aadd(aCamposC7, {"WC7_NOMFOR",GetSX3Cache("A2_NOME"   ,"X3_TIPO"),GetSX3Cache("A2_NOME"   ,"X3_TAMANHO"),0} ) // Nome
	aadd(aCamposC7, {"WC7_RECSC7","N",20,0}) // RecNo SC7
	aadd(aCamposC7, {"WC7_QTDPED",GetSX3Cache("C7_QUANT"  ,"X3_TIPO"),GetSX3Cache("C7_QUANT"  ,"X3_TAMANHO"),0} ) // Qtd.Pedido
	aadd(aCamposC7, {"WC7_QTDUTI",GetSX3Cache("C7_QUANT"  ,"X3_TIPO"),GetSX3Cache("C7_QUANT"  ,"X3_TAMANHO"),0} ) // Qtd.Utilizada
	aadd(aCamposC7, {"WC7_QTDDIS",GetSX3Cache("C7_QUANT"  ,"X3_TIPO"),GetSX3Cache("C7_QUANT"  ,"X3_TAMANHO"),0} ) // Qtd.Disponivel

	oTmpSC7 := OFDMSTempTable():New()
	oTmpSC7:cAlias := "TMPSC7"
	oTmpSC7:aVetCampos := aCamposC7
	oTmpSC7:AddIndex(, {"WC7_NUMPED"} )
	oTmpSC7:CreateTable()
	oTmpSC7:InsertSQL( OM0300071_Monta_Dados_SC7() ) // Monta tabela temporaria SC7 desse Servi็o

	aCamposC7 := {	{STR0187,"WC7_NUMPED", GetSX3Cache("C7_NUM"    ,"X3_TIPO"),08,0, Alltrim(GetSX3Cache("C7_NUM"    ,"X3_PICTURE")),GetSX3Cache("C7_NUM"    ,"X3_DECIMAL"),.f.},;// Nro.Pedido
					{STR0188,"WC7_EMISSA", GetSX3Cache("C7_EMISSAO","X3_TIPO"),08,0, Alltrim(GetSX3Cache("C7_EMISSAO","X3_PICTURE")),GetSX3Cache("C7_EMISSAO","X3_DECIMAL"),.f.},;// Data
					{STR0189,"WC7_CODFOR", GetSX3Cache("C7_FORNECE","X3_TIPO"),08,0, Alltrim(GetSX3Cache("C7_FORNECE","X3_PICTURE")),GetSX3Cache("C7_FORNECE","X3_DECIMAL"),.f.},;// Fornecedor
					{STR0190,"WC7_LOJFOR", GetSX3Cache("C7_LOJA"   ,"X3_TIPO"),05,0, Alltrim(GetSX3Cache("C7_LOJA"   ,"X3_PICTURE")),GetSX3Cache("C7_LOJA"   ,"X3_DECIMAL"),.f.},;// Loja
					{STR0191,"WC7_NOMFOR", GetSX3Cache("A2_NOME"   ,"X3_TIPO"),40,0, Alltrim(GetSX3Cache("A2_NOME"   ,"X3_PICTURE")),GetSX3Cache("A2_NOME"   ,"X3_DECIMAL"),.f.},;// Nome
					{STR0192,"WC7_QTDPED", GetSX3Cache("C7_QUANT"  ,"X3_TIPO"),10,0, Alltrim(GetSX3Cache("C7_QUANT"  ,"X3_PICTURE")),GetSX3Cache("C7_QUANT"  ,"X3_DECIMAL"),.f.},;// Qtd.Pedido
					{STR0193,"WC7_QTDUTI", GetSX3Cache("C7_QUANT"  ,"X3_TIPO"),10,0, Alltrim(GetSX3Cache("C7_QUANT"  ,"X3_PICTURE")),GetSX3Cache("C7_QUANT"  ,"X3_DECIMAL"),.f.},;// Qtd.Utilizada
					{STR0194,"WC7_QTDDIS", GetSX3Cache("C7_QUANT"  ,"X3_TIPO"),10,0, Alltrim(GetSX3Cache("C7_QUANT"  ,"X3_PICTURE")),GetSX3Cache("C7_QUANT"  ,"X3_DECIMAL"),.f.} }// Qtd.Disponivel

	aInfo := { aSizeHalf[ 1 ], aSizeHalf[ 2 ],aSizeHalf[ 3 ] ,aSizeHalf[ 4 ], 3, 3 } // Tamanho total da tela
	aAdd( aObjects, { 0 , 0 , .T. , .T. } ) // Tela Total
	aPos := MsObjSize( aInfo, aObjects )

	DEFINE MSDIALOG oDlgPedSC7 FROM aSizeHalf[7],0 TO aSizeHalf[6],aSizeHalf[5] TITLE STR0185 OF oMainWnd PIXEL STYLE DS_MODALFRAME STATUS // Pedidos relacionados ao Servi็o de Terceiro

		oBrwSC7 := FWMBrowse():New( )
		oBrwSC7:SetOwner(oDlgPedSC7)
		oBrwSC7:SetDescription(STR0185) // Pedidos relacionados ao Servi็o de Terceiro
		oBrwSC7:SetTemporary(.T.)
		oBrwSC7:DisableDetails()
		oBrwSC7:SetFilterDefault(" !Empty(WC7_NUMPED) ")
		oBrwSC7:AddFilter(STR0195," WC7_QTDPED > WC7_QTDUTI ",.f.,Empty(M->VO4_PEDCOM),) // Pedidos Disponiveis
		oBrwSC7:AddFilter(STR0196+" ( "+right(left(dtos(dDataBase),6),2)+" / "+left(dtos(dDataBase),4)+" )","WC7_EMISSA >= '"+dtos(dDataBase-day(dDataBase)+1)+"'",.f.,.f.,) // Pedidos do M๊s
		oBrwSC7:AddFilter(STR0206,"WC7_EMISSA >= '"+dtos(dDataBase-15)+"'",.f.,.f.,) // Pedidos dos ultimos 15 dias
		oBrwSC7:AddFilter(STR0197,"WC7_EMISSA >= '"+dtos(dDataBase-30)+"'",.f.,.t.,) // Pedidos dos ultimos 30 dias
		oBrwSC7:AddFilter(STR0209,"WC7_EMISSA >= '"+dtos(dDataBase-60)+"'",.f.,.f.,) // Pedidos dos ultimos 60 dias
		oBrwSC7:AddFilter(STR0198,"WC7_EMISSA >= '"+dtos(dDataBase-90)+"'",.f.,.f.,) // Pedidos dos ultimos 90 dias
		oBrwSC7:AddFilter(STR0210,"WC7_EMISSA >= '"+dtos(dDataBase-120)+"'",.f.,.f.,) // Pedidos dos ultimos 120 dias
		oBrwSC7:AddFilter(STR0207,"WC7_EMISSA >= '"+dtos(dDataBase-180)+"'",.f.,.f.,) // Pedidos dos ultimos 180 dias
		oBrwSC7:AddFilter(STR0208,"WC7_EMISSA >= '"+dtos(dDataBase-365)+"'",.f.,.f.,) // Pedidos dos ultimos 365 dias
		If lVO4IPDCOM .and. !Empty(M->VO4_PEDCOM)
			oBrwSC7:AddLegend(" WC7_NUMPED == '" + M->VO4_PEDCOM + "' .AND. WC7_ITEPED == '" + M->VO4_IPDCOM + "'" , "BR_AZUL" , STR0202 ) // Pedido de Servi็o de Terceiro selecionado
		EndIf
		oBrwSC7:AddLegend(" WC7_QTDUTI == 0 " , "BR_VERDE"    , STR0199 ) // Pedido de Servi็o de Terceiro nใo utilizado
		oBrwSC7:AddLegend(" WC7_QTDUTI > 0 .AND. WC7_QTDPED > WC7_QTDUTI " , "BR_AMARELO"  , STR0200 ) // Pedido de Servi็o de Terceiro utilizado parcialmente
		oBrwSC7:AddLegend(" WC7_QTDUTI >= WC7_QTDPED " , "BR_VERMELHO" , STR0201 ) // Pedido de Servi็o de Terceiro jแ utilizado
		oBrwSC7:AddButton( STR0203 , { || oDlgPedSC7:End() } ) // Fechar
		oBrwSC7:AddButton( STR0204 , { || IIf(TMPSC7->WC7_RECSC7>0.and.OM0300065_RelacionarPedido(TMPSC7->WC7_RECSC7),oDlgPedSC7:End(),.t.) } ) // Selecionar Pedido
		If !Empty(M->VO4_PEDCOM) .and. aCols[n,nUsadoSrv] == 0 // Somente deixa tirar relacionamento do Pedido se ainda nao salvou o registro do VO4
			oBrwSC7:AddButton( STR0211 , { || IIf(OM0300091_Limpar_relacionamento_Pedido(),oDlgPedSC7:End(),.t.) } ) // Limpar relacionamento com Pedido
		EndIf
		oBrwSC7:SetDoubleClick({ || IIf(TMPSC7->WC7_RECSC7>0.and.OM0300065_RelacionarPedido(TMPSC7->WC7_RECSC7),oDlgPedSC7:End(),.t.) })
		oBrwSC7:DisableConfig()
		oBrwSC7:DisableReport()
		oBrwSC7:SetFixedBrowse(.T.)
		oBrwSC7:SetAlias("TMPSC7")
		oBrwSC7:SetFields(aCamposC7)
		oBrwSC7:SetMenuDef("")
		oBrwSC7:ForceQuitButton(.t.)
		oBrwSC7:Activate()

	oDlgPedSC7:Activate( , , , .t. , , , ) //ativa a janela

	oTmpSC7:CloseTable()

	aRotina := aClone(aBkpRot)

Return

/*/{Protheus.doc} OFM0300045_ValorServicoTerceiro
Fun็ใo para retornar o valor do servi็o de terceiro baseado no custo

@author Renato Vinicius
@since 05/03/2025

@type function
/*/
Function OFM0300045_ValorServicoTerceiro(cCusSrvTer,cCdSer)

	Local nVlrRet := 0
	Local nVlrApl := 0

	Default cCusSrvTer := 0

	If OFM0300011_PosicionaVO6( cCdSer )

		Do Case
		Case VO6->(FieldPos("VO6_PERVDA")) > 0 .and. VO6->VO6_PERVDA > 0
			nVlrApl := (cCusSrvTer * VO6->VO6_PERVDA) / 100
		Case VOK->(FieldPos("VOK_PERVDA")) > 0 .and. VOK->VOK_PERVDA > 0
			nVlrApl := (cCusSrvTer * VOK->VOK_PERVDA) / 100
		End
	EndIf

	nVlrRet := cCusSrvTer + nVlrApl

Return nVlrRet

/*/{Protheus.doc} OM0300055_BaixaServicoTerceiro

@author Renato Vinicius
@since 05/03/2025
@version 1.0
@param cNumOsv, characters, description
@param cTipTem, characters, description
@type function
/*/
Function OM0300055_BaixaServicoTerceiro(cFilPed, cPedCom, cItemPC, cDocEnt, cSerEnt)

	Local cMV_SRV3PD := GetNewPar("MV_SRV3PD","N")
	Local lVO4NNFCOM := VO4->(FieldPos("VO4_NNFCOM")) > 0
	Local nRecVO4    := 0

	If cMV_SRV3PD == "P" .and. lVO4NNFCOM

		cQuery := "SELECT VO4.R_E_C_N_O_ FROM " + RetSqlName("VO4") + " VO4 "
		cQuery += "WHERE VO4.VO4_FILIAL = '" + cFilPed + "' "
		cQuery +=  " AND VO4.VO4_PEDCOM = '" + cPedCom + "' "
		cQuery +=  " AND VO4.VO4_IPDCOM = '" + cItemPC + "' "
		cQuery +=  " AND VO4.D_E_L_E_T_ = ' ' "

		nRecVO4 := FM_SQL(cQuery)

		If nRecVO4 > 0
			DbSelectArea("VO4")
			DbGoTo(nRecVO4)

			RecLock("VO4",.f.)
				VO4->VO4_NNFCOM := cDocEnt
				VO4->VO4_SNFCOM := cSerEnt
			MsUnLock()

		EndIf

	EndIf

Return

/*/{Protheus.doc} OM0300065_RelacionarPedido

@author Renato Vinicius
@since 07/03/2025
@version 1.0

@type function
/*/
Function OM0300065_RelacionarPedido(nRecSC7)
	Default nRecSC7 := 0

	If nRecSC7 > 0
		SC7->(DbGoTo(nRecSC7))
	EndIf

	If !OM0300081_Valida_QTD_SC7_com_VO4( M->VO4_TIPSER , aCols[n,nUsadoSrv] , aCols , n )
		Return .f.
	EndIf

	nVlCustPed := SC7->C7_PRECO
	If lMultMoeda
		nVlCustPed := FG_MOEDA( nVlCustPed , SC7->C7_MOEDA , If( VO1->(FieldPos('VO1_MOEDA')) > 0 , VO1->VO1_MOEDA, 1) )
	EndIf

	M->VO4_CODFOR := aCols[n,FG_POSVAR("VO4_CODFOR")] := SC7->C7_FORNECE
	M->VO4_FOLOJA := aCols[n,FG_POSVAR("VO4_FOLOJA")] := SC7->C7_LOJA
	M->VO4_PEDCOM := aCols[n,FG_POSVAR("VO4_PEDCOM")] := SC7->C7_NUM
	M->VO4_VALCUS := aCols[n,FG_POSVAR("VO4_VALCUS")] := nVlCustPed
	M->VO4_CODPAG := aCols[n,FG_POSVAR("VO4_CODPAG")] := SC7->C7_COND
	If SC7->(FieldPos("C7_NATUREZ")) > 0
		M->VO4_NATURE := aCols[n,FG_POSVAR("VO4_NATURE")] := SC7->C7_NATUREZ
	EndIf
	M->VO4_VALVEN := aCols[n,FG_POSVAR("VO4_VALVEN")] := OFM0300045_ValorServicoTerceiro(M->VO4_VALCUS,aCols[n,FG_POSVAR("VO4_CODSER")])
	If VO4->(FieldPos("VO4_IPDCOM")) > 0
		M->VO4_IPDCOM := aCols[n,FG_POSVAR("VO4_IPDCOM")] := SC7->C7_ITEM
	EndIf

	oGetSrv:oBrowse:Refresh()

Return .t.

/*/{Protheus.doc} OM0300071_Monta_Dados_SC7
Levanta Dados Pedidos (SC7) do Produto SERVICO posicionado

@author Andre Luis Almeida
@since 14/04/2025
/*/
Static Function OM0300071_Monta_Dados_SC7()
Local cFilVO4 := xFilial("VO4")
Local cQuery  := ""
cQuery := "SELECT SC7.C7_NUM , SC7.C7_ITEM , SC7.C7_EMISSAO , "
cQuery += "       SC7.C7_FORNECE , SC7.C7_LOJA , SA2.A2_NOME , "
cQuery += "       SC7.R_E_C_N_O_ AS RECSC7 , SC7.C7_QUANT , "
cQuery += "       COUNT(VO4.R_E_C_N_O_) AS QTDUTI , "
cQuery += "       ( SC7.C7_QUANT - COUNT(VO4.R_E_C_N_O_) ) AS QTDDIS "
cQuery += "  FROM " + RetSQLName("SC7") + " SC7 "
cQuery += "  JOIN " + RetSQLName("SA2") + " SA2 "
cQuery += "    ON SA2.A2_FILIAL  = '"+xFilial("SA2")+"'"
cQuery += "   AND SA2.A2_COD     = SC7.C7_FORNECE"
cQuery += "   AND SA2.A2_LOJA    = SC7.C7_LOJA"
cQuery += "   AND SA2.D_E_L_E_T_ = ' ' "
cQuery += "  LEFT JOIN " + RetSQLName("VO4") + " VO4 "
cQuery += "    ON VO4.VO4_FILIAL = '"+ cFilVO4 +"'"
cQuery += "   AND VO4.VO4_TIPSER = '"+ M->VO4_TIPSER +"'"
cQuery += "   AND VO4.VO4_PEDCOM = SC7.C7_NUM"
cQuery += "   AND VO4.D_E_L_E_T_ = ' '"
cQuery += " WHERE SC7.C7_FILIAL = '" + xFilial("SC7") + "' "
If !Empty(M->VO4_CODFOR)
	cQuery += " AND SC7.C7_FORNECE = '" + M->VO4_CODFOR + "'"
EndIf
If !Empty(M->VO4_FOLOJA)
	cQuery += " AND SC7.C7_LOJA = '" + M->VO4_FOLOJA + "'"
EndIf
cQuery += " AND SC7.C7_PRODUTO = '" + SB1->B1_COD + "'"
cQuery += " AND SC7.C7_FILENT  = '" + cFilVO4 + "'"
cQuery += " AND SC7.D_E_L_E_T_ = ' ' "
cQuery += " GROUP BY SC7.C7_NUM , SC7.C7_ITEM , SC7.C7_EMISSAO , "
cQuery += "          SC7.C7_FORNECE , SC7.C7_LOJA , SA2.A2_NOME , "
cQuery += "          SC7.R_E_C_N_O_ , SC7.C7_QUANT "
Return cQuery

/*/{Protheus.doc} OM0300081_Valida_QTD_SC7_com_VO4
Valida a Quantidade de Pedidos (SC7) de Servi็o de Terceiro utilizados no VO4

@author Andre Luis Almeida
@since 14/04/2025
/*/
Static Function OM0300081_Valida_QTD_SC7_com_VO4(cTipSer,nRecVO4,aColsAux,nLinaCols)
Local lRet       := .t.
Local cQuery     := ""
Local nCntFor    := 0
Local nQtdJaSel  := 0
Local lVO4IPDCOM := VO4->(FieldPos("VO4_IPDCOM")) > 0
Default aColsAux := {}
Default nLinaCols := 0
For nCntFor := 1 to len(aColsAux)
	If nLinaCols <> nCntFor .and. aColsAux[nCntFor,nUsadoSrv] == 0 .and. !aColsAux[nCntFor,Len(aColsAux[nCntFor])] .and. ;
			SC7->C7_NUM == aColsAux[nCntFor,FG_POSVAR("VO4_PEDCOM")] .and. ;
			( !lVO4IPDCOM .or. SC7->C7_ITEM == aColsAux[nCntFor,FG_POSVAR("VO4_IPDCOM")] )
		nQtdJaSel++ // Soma se for o mesmo Tipo de Servi็o e ainda nใo esta gravado no VO4
	EndIf
Next
cQuery += "SELECT COUNT(*) AS QTD "
cQuery += "  FROM " + RetSqlName("VO4")
cQuery += " WHERE VO4_FILIAL = '"+xFilial("VO4")+"'"
cQuery += "   AND VO4_TIPSER = '"+cTipSer+"'"
cQuery += "   AND VO4_PEDCOM = '"+SC7->C7_NUM+"'"
If lVO4IPDCOM
	cQuery += " AND VO4_IPDCOM = '"+SC7->C7_ITEM+"'"
EndIf
cQuery += "   AND R_E_C_N_O_ <> "+Alltrim(str(nRecVO4))
cQuery += "   AND D_E_L_E_T_ = ' '
If ( FM_SQL(cQuery)+nQtdJaSel ) >= SC7->C7_QUANT
	lRet :=  .f.
	FMX_HELP("OFM030ERR04", STR0205) // Quantidade de Servi็o de Terceiro do Pedido jแ utilizada. Impossํvel continuar.
EndIf
Return lRet

/*/{Protheus.doc} OM0300091_Limpar_relacionamento_Pedido
Limpar relacionamento com Pedido ( SC7 )

@author Andre Luis Almeida
@since 30/04/2025
/*/
Static Function OM0300091_Limpar_relacionamento_Pedido()
	M->VO4_CODFOR := aCols[n,FG_POSVAR("VO4_CODFOR")] := space(GetSx3Cache("VO4_CODFOR","X3_TAMANHO"))
	M->VO4_FOLOJA := aCols[n,FG_POSVAR("VO4_FOLOJA")] := space(GetSx3Cache("VO4_FOLOJA","X3_TAMANHO"))
	M->VO4_PEDCOM := aCols[n,FG_POSVAR("VO4_PEDCOM")] := space(GetSx3Cache("VO4_PEDCOM","X3_TAMANHO"))
	M->VO4_VALCUS := aCols[n,FG_POSVAR("VO4_VALCUS")] := 0
	M->VO4_CODPAG := aCols[n,FG_POSVAR("VO4_CODPAG")] := space(GetSx3Cache("VO4_CODPAG","X3_TAMANHO"))
	M->VO4_NATURE := aCols[n,FG_POSVAR("VO4_NATURE")] := space(GetSx3Cache("VO4_NATURE","X3_TAMANHO"))
	M->VO4_VALVEN := aCols[n,FG_POSVAR("VO4_VALVEN")] := 0
	If VO4->(FieldPos("VO4_IPDCOM")) > 0
		M->VO4_IPDCOM := aCols[n,FG_POSVAR("VO4_IPDCOM")] := space(GetSx3Cache("VO4_IPDCOM","X3_TAMANHO"))
	EndIf
	oGetSrv:oBrowse:Refresh()
Return .t.

/*/{Protheus.doc} OM0300101_SQL_VO7
Monta o SELECT complementar para VO7

@author Andre Luis Almeida
@since 04/08/2025
/*/
Static Function OM0300101_SQL_VO7()
Local lVO7GRUMOD := (VO7->(FieldPos("VO7_GRUMOD")) > 0)
Local cQuery := ""
cQuery += " AND ( "
cQuery += " NOT EXISTS "
cQuery += "   ( SELECT VO70.R_E_C_N_O_ "
cQuery += "       FROM "+RetSQLName("VO7")+" VO70 "
cQuery += "      WHERE VO70.VO7_FILIAL = '"+xFilial("VO7")+"' "
cQuery += "        AND VO70.VO7_CODMAR = VO6.VO6_CODMAR "
cQuery += "        AND VO70.VO7_CODSER = VO6.VO6_CODSER "
cQuery += "        AND VO70.D_E_L_E_T_ = ' ' "
cQuery += "   ) "
cQuery += " OR "
cQuery += " EXISTS "
cQuery += "   ( SELECT VO71.R_E_C_N_O_ "
cQuery += "       FROM "+RetSQLName("VO7")+" VO71 "
cQuery += "      WHERE VO71.VO7_FILIAL = '"+xFilial("VO7")+"' "
cQuery += "        AND VO71.VO7_CODMAR = VO6.VO6_CODMAR "
cQuery += "        AND VO71.VO7_CODSER = VO6.VO6_CODSER "
cQuery += "        AND ( "
cQuery += "               VO71.VO7_MODVEI = '" + cVeiMod + "' "
If lVO7GRUMOD
	cQuery += "         OR "
	cQuery += "           VO71.VO7_GRUMOD = '" + cGruMod + "' "
EndIf
cQuery += "            ) "
cQuery += "        AND VO71.D_E_L_E_T_ = ' ' "
cQuery += "   ) "
cQuery += " ) "
Return cQuery

/*/{Protheus.doc} OM0300111_Altera_Valores_Servico_Terceiro
Altera Valores do Servico de Terceiro

@author Andre Luis Almeida
@since 14/11/2025
/*/
Static Function OM0300111_Altera_Valores_Servico_Terceiro()
Local cMV_SRV3PD := GetNewPar("MV_SRV3PD","N")
Local cCpoValid  := IIf(cMV_SRV3PD=="P","VO4_PEDCOM","VO4_NUMTIT")
Local nCpoValid  := FG_POSVAR(cCpoValid,"aHeaderSrv")
Local nLinCols   := oGetSrv:oBrowse:nAt
Local nTIPSER    := FG_POSVAR("VO4_TIPSER","aHeaderSrv")
Local nVALCUS    := FG_POSVAR("VO4_VALCUS","aHeaderSrv")
Local nVALVEN    := FG_POSVAR("VO4_VALVEN","aHeaderSrv")
Local nVALTOT    := FG_POSVAR("VO4_VALTOT","aHeaderSrv")
Local nVALHOR    := FG_POSVAR("VO4_VALHOR","aHeaderSrv")
Local aParamBox  := {}
Local aRet       := {}
If oFolder030:nOption == 1 .and. len(aCols) >= nLinCols
	VOK->(DbSetOrder(1))
	VOK->(MsSeek(xFilial("VOK")+aCols[nLinCols,nTIPSER]))
	If VOK->VOK_INCMOB == "2" .and. Empty(aCols[nLinCols,nCpoValid]) // Servi็o de Terceiro
		aAdd(aParamBox,{1,RetTitle("VO4_VALCUS"), aCols[nLinCols,nVALCUS] , GetSX3Cache("VO4_VALCUS","X3_PICTURE") ,"positivo()","","",80,.t.}) // Valor Custo
		aAdd(aParamBox,{1,RetTitle("VO4_VALVEN"), aCols[nLinCols,nVALVEN] , GetSX3Cache("VO4_VALVEN","X3_PICTURE") ,"positivo()","","",80,.t.}) // Valor Venda
		If ParamBox(aParamBox,STR0212,@aRet,,,,,,,,.F.,.F.) // Altera Valores Servi็o de Terceiro
			aCols[nLinCols,nVALCUS] := aRet[1]
			aCols[nLinCols,nVALVEN] := aRet[2]
			aCols[nLinCols,nVALTOT] := aRet[2]
			aCols[nLinCols,nVALHOR] := aRet[2]
			oGetSrv:oBrowse:Refresh()
		EndIf
	Else
		FMX_HELP("OFM030ERR06",STR0213) // Op็ใo disponํvel apenas para Servi็o de Terceiro que nใo foi confirmada a Requisi็ใo do Servi็o.
	EndIf
EndIf
Return

/*/{Protheus.doc} OM020033K_PermiteRequisitarAposEntregaVeic
	Fun็ใo que valida a permissใo do usuแrio para requisitar servi็os
	ap๓s entrega do veํculo ao cliente - entende-se que o servi็o foi finalizado
	@type  Static Function
	@author Lucas Oliveira
	@since 25/05/2026
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function OM030033K_PermiteRequisitarAposEntregaVeic()

	Local aArea	:= GetArea()
	Local lRet 	:= .T.

	If VAI->(FieldPos("VAI_REQPOS")) > 0

		If !Empty(VO1->VO1_DTENTR) .and. VO1->VO1_LIBMAN == "0" // Veํculo jแ foi entregue ao cliente

			VAI->(DBSetOrder(4))
			VAI->(DBSeek(xFilial("VAI") + __cUserID))

			If !Empty(VAI->VAI_REQPOS) .and. !VAI->VAI_REQPOS $ "3.4" // Permite Servi็os ou Permite Pe็as/Servi็os
				FMX_Help("OM030033",;
				STR0215 ,; // "Usuแrio sem permissใo para requisitar servi็os ap๓s a entrega do veํculo."
				STR0216 ) //"Verifique a configura็ใo do campo P๓s-Entrega no cadastro de permiss๕es."
				lRet := .F.
			Endif
		EndIf
	EndIf

	RestArea(aArea)

Return lRet

/*/{Protheus.doc} OM0300122_ChamaAPPApontamentoPorTarefa
	Funcao utilizada para chamada da aplicacao de Apontamento de Tarefa
	Passando o numero da OS como parโmetro

	@type  Function
	@author Bruno Forcato
	@since 21/01/2026
	/*/
Function OM0300122_ChamaAPPApontamentoPorTarefa()
	OFIA636(VO1->VO1_NUMOSV)
Return


static function OM0300155_ApontTarefaInicioTrabalho(cNumOsv, cProdutivo, aSeqInc, aCodSrvc, cTipTem, cTipSer)

	Local oQryApontTar := FWPreparedStatement():new()

	local nParam
	local cQuery
	Local cAlTmp
	Local lIniTrab

	Default aSeqInc := {}
	Default aCodSrvc := {}
	Default cTipTem := ""
	Default cTipSer := ""

	cQuery := " SELECT COUNT(*) CONTADOR"
	cQuery += OM0300185_QueryServicosTarefa(cNumOsv, aSeqInc , cTipTem , cTipSer)
	cQuery += " AND VO4.VO4_CODPRO = ?"
	cQuery += " AND VO4.VO4_DATFIN = ' '"

	nParam := 1
	oQryApontTar:setQuery(cQuery)
	oQryApontTar:setString(nParam++, cNumOsv )

	if !Empty(cTipTem)
		oQryApontTar:setString(nParam++, cTipTem)
	Endif

	if !Empty(cTipSer)
		oQryApontTar:setString(nParam++, cTipSer)
	endif

	if lInconveniente .and. ! empty(aSeqInc)
		oQryApontTar:setIn(nParam++, aSeqInc)
	endif
	oQryApontTar:setString(nParam++, cProdutivo )

CONOUT("OM0300155_ApontTarefaInicioTrabalho")
Conout(oQryApontTar:getFixQuery())
Conout(" ")

	cAlTmp := MPSysOpenQuery(oQryApontTar:getFixQuery())
	lIniTrab := ((cAlTmp)->CONTADOR > 0)
	(cAlTmp)->(dbCloseArea())

return ! lIniTrab


static function OM0300175_FiltraServicosTarefa(aAuxAutoItens, dDtIni, nHrIni, cNumOsv, cProdutivo, aSeqInc, aCodSrvc, cTipTem , cTipSer, aSrvcProc)

	Local oQryFiltraSrvc := FWPreparedStatement():New()

	Local aAuxIteVO4
	Local cQuery
	Local nParam
	Local cAlTmp

	Default dDtIni := Date()
	Default nHrIni := Val(Substr(time(),1,2)+Substr(time(),4,2))
	Default aSeqInc := {}
	Default aCodSrvc := {}
	Default cTipTem := ""
	Default cTipSer := ""

	cQuery := " SELECT DISTINCT VO4_TIPTEM, VO4_TIPSER, VO4_SEQINC, VO4_GRUSER , VO4_CODSER, VO4_TEMPAD "
	cQuery += OM0300185_QueryServicosTarefa(cNumOsv, aSeqInc , aCodSrvc, cTipTem , cTipSer)

	nParam := 1
	oQryFiltraSrvc:setQuery(cQuery)
	oQryFiltraSrvc:setString(nParam++, cNumOsv )

	if !Empty(cTipTem)
		oQryFiltraSrvc:setString(nParam++, cTipTem)
	Endif

	if !Empty(cTipSer)
		oQryFiltraSrvc:setString(nParam++, cTipSer)
	endif

	if lInconveniente .and. len(aSeqInc) > 0
		oQryFiltraSrvc:setIn(nParam++, aSeqInc)
	endif

	if len(aCodSrvc) > 0
		oQryFiltraSrvc:setIn(nParam++, aCodSrvc)
	endif

	aAuxIteVO4 := {}

CONOUT("OM0300175_FiltraServicosTarefa")
Conout(oQryFiltraSrvc:getFixQuery())
Conout(" ")


	cAlTmp := MPSysOpenQuery(oQryFiltraSrvc:getFixQuery())
	While !(cAlTmp)->(Eof())

		aAuxIteVO4 := {}
		AADD(aAuxIteVO4, { "VO4_TIPTEM" , (cAlTmp)->VO4_TIPTEM , nil } )
		AADD(aAuxIteVO4, { "VO4_GRUSER" , (cAlTmp)->VO4_GRUSER , nil } )
		AADD(aAuxIteVO4, { "VO4_CODSER" , (cAlTmp)->VO4_CODSER , nil } )
		AADD(aAuxIteVO4, { "VO4_TIPSER" , (cAlTmp)->VO4_TIPSER , nil } )

		// Necessแrio limpar a data inicio para permitir o fechamento correto do apontamento por tarefa
		// E deve ficar nesse ponto
		if Len(aAuxAutoItens) <> 0
			AADD(aAuxIteVO4, { "VO4_DATINI" , CtoD(" ") , nil } )
		endif
		//

		AADD(aAuxIteVO4, { "VO4_CODPRO" , cProdutivo       , nil } )

		if Len(aAuxAutoItens) == 0
			AADD(aAuxIteVO4, { "VO4_DATINI" , dDtIni , nil } )
			AADD(aAuxIteVO4, { "VO4_HORINI" , nHrIni , nil } )
		endif

		AADD( aAuxAutoItens , aClone( aAuxIteVO4 ) )

		// Array Auxiliar quando enviado data inicial e final
		AADD(aSrvcProc, {;
			" ",;                      // 01
			(cAlTmp)->VO4_CODSER ,;    // 02
			(cAlTmp)->VO4_TEMPAD,;     // 03
			0 ,;                       // 04
			0 ,;                       // 05
			0 ,;                       // 06
			CtoD(" ") ,;               // 07
			0 ,;                       // 08
			(cAlTmp)->VO4_TIPTEM ,;    // 09
			(cAlTmp)->VO4_GRUSER ,;    // 10
			(cAlTmp)->VO4_TIPSER } )   // 11
		//
		if Len(aAuxAutoItens) == 1
			aSrvcProc[Len(aSrvcProc),7] := dDtIni
			aSrvcProc[Len(aSrvcProc),8] := nHrIni
		endif

	
		(cAlTmp)->(DbSkip())
	end
	(cAlTmp)->(DbCloseArea())

return

static function OM0300185_QueryServicosTarefa(cNumOsv, aSeqInc , aCodSrvc, cTipTem , cTipSer)

	Local cQuery := ""

	cQuery +=  " FROM " + RetSQLName("VO2") + " VO2 "
	cQuery +=  " JOIN " + RetSQLName("VO4") + " VO4 ON VO4.VO4_FILIAL = VO2.VO2_FILIAL AND VO2.VO2_NOSNUM = VO4.VO4_NOSNUM AND VO4.D_E_L_E_T_ = ' ' "
	cQuery +=  " JOIN " + RetSQLName("VOK") + " VOK ON VOK.VOK_FILIAL = '" + FWxFilial("VOK") + "' AND VOK.VOK_TIPSER = VO4.VO4_TIPSER AND VOK.D_E_L_E_T_ = ' ' "
	cQuery +=  " AND VOK.VOK_INCMOB NOT IN ('2','5','6') "
	cQuery +=  " WHERE VO2.VO2_FILIAL = '" + FWxFilial("VO2") + "' "
	cQuery +=    " AND VO2.VO2_NUMOSV = ? "
	cQuery +=    " AND VO2.VO2_TIPREQ = 'S' "
	cQuery +=    " AND VO2.D_E_L_E_T_ = ' ' "

	if !Empty(cTipTem)
		cQuery += " AND VO4.VO4_TIPTEM = ? "
	Endif

	if !Empty(cTipSer)
		cQuery += " AND VO4.VO4_TIPSER = ? "
	endif

	if lInconveniente .and. len(aSeqInc) > 0
		cQuery += " AND VO4.VO4_SEQINC IN (?)"
	endif

	if len(aCodSrvc) > 0
		cQuery += " AND VO4.VO4_CODSER IN (?)"
	endif

return cQuery


static function OM0300195_FechaServicosTarefa(aAuxAutoItens, dDtFin, nHrFin, cNumOsv, cProdutivo, aSeqInc, aCodSrvc, cTipTem , cTipSer, aSrvcProc, cVO4MAUSA)

	local aPeriodos
	local oQryFechApont := FWPreparedStatement():new()
	Local oUtil := DMS_Util():new()
	Local nPos
	Local nParam
	Local cAlFechSrvc
	Local aAuxIteVO4 := {}
	Local dAuxDtIni := CtoD("31/12/9999")
	Local nAuxHrIni := 2400
	Local nTotTemPad := 0
	Local lApontIniFim := .f.

	Default aSeqInc := {}
	Default aCodSrvc := {}
	Default cTipTem := ""
	Default cTipSrvc := ""
	Default aSrvcProc := {}
	Default cVO4MAUSA := ""

	if len(aSrvcProc) == 0

		cQuery := " SELECT VO4_TEMPAD, VO4.R_E_C_N_O_ VO4RECNO "
		cQuery += OM0300185_QueryServicosTarefa(cNumOsv, aSeqInc , cTipTem , cTipSer)

		cQuery += " AND VO4.VO4_CODPRO = ? "
		cQuery += " AND VO4.VO4_DATFIN = ' ' "

		cQuery += " ORDER BY VO4.VO4_DATINI DESC, VO4.VO4_HORINI , VO4.VO4_SEQINC, VO4.VO4_CODSER"

		nParam := 1
		oQryFechApont:setQuery(cQuery)
		oQryFechApont:setString(nParam++, cNumOsv )

		if !Empty(cTipTem)
			oQryFechApont:setString(nParam++, cTipTem)
		Endif

		if !Empty(cTipSrvc)
			oQryFechApont:setString(nParam++, cTipSrvc)
		endif

		if lInconveniente .and. ! empty(aSeqInc)
			oQryFechApont:setIn(nParam++, aSeqInc)
		endif

		oQryFechApont:setString(nParam++, cProdutivo)

CONOUT("OM0300195_FechaServicosTarefa")
Conout(oQryFechApont:getFixQuery())
Conout(" ")


		cAlFechSrvc := MPSysOpenQuery(oQryFechApont:getFixQuery())

		aSrvcProc := {}
		While !(cAlFechSrvc)->(Eof())

			VO4->(dbGoTo((cAlFechSrvc)->VO4RECNO))

			nTotTemPad += (cAlFechSrvc)->VO4_TEMPAD

			AADD(aSrvcProc, {;
				VO4->VO4_SEQUEN,;          // 01
				VO4->VO4_CODSER ,;         // 02
				VO4->VO4_TEMPAD,;          // 03
				0 ,;                       // 04 - Percentual do servico em relacao ao servicos que serao apontados, sera utilizado o tempo padrao para calculo
				0 ,;                       // 05 - Tempo a ser apontado (Tempo trabalhado * percentual do servico)
				(cAlFechSrvc)->VO4RECNO ,; // 06
				VO4->VO4_DATINI ,;         // 07
				VO4->VO4_HORINI ,;         // 08
				VO4->VO4_TIPTEM ,;         // 09
				VO4->VO4_GRUSER ,;         // 10
				VO4->VO4_TIPSER } )        // 11

			if ! empty(VO4->VO4_DATINI) .and. VO4->VO4_DATINI < dAuxDtIni
				dAuxDtIni := VO4->VO4_DATINI
			endif

			if VO4->VO4_HORINI <> 0 .and. VO4->VO4_HORINI < nAuxHrIni
				nAuxHrIni := VO4->VO4_HORINI
			endif

			(cAlFechSrvc)->(DbSkip())
		end
		(cAlFechSrvc)->(DbCloseArea())

	else

		lApontIniFim := .t.
		for nPos := 1 to len(aSrvcProc)

			nTotTemPad += aSrvcProc[nPos][3]

			if ! empty(aSrvcProc[nPos][7]) .and. aSrvcProc[nPos][7] < dAuxDtIni
				dAuxDtIni := aSrvcProc[nPos][7]
			endif

			if aSrvcProc[nPos][8] <> 0 .and. aSrvcProc[nPos][8] < nAuxHrIni
				nAuxHrIni := aSrvcProc[nPos][8]
			endif

		next nPos
	endif

	if dDtFin < dAuxDtIni .or. (dDtFin == dAuxDtIni .and. nHrFin <= nAuxHrIni)
		FMX_HELP("OM030ERR09", STR0218 + CRLF + CRLF + STR0219 + DtoC(dAuxDtIni) + " - " + Transform(nAuxHrIni,"@R 99:99") + CRLF + STR0220 + DtoC(dDtFin) + " - " + Transform(nHrFin,"@R 99:99")) // "Data/Hora final de trabalho informada ้ menor que a data inicial do trabalho.", "Inํcio: ",  "Final: "
		return .f.
	endif

	// Calcula o tempo trabalhado do produtivo considerando a data de inicio de trabalho e a data final de trabalho
	nTempoTrab := ;
		FG_TEMPTRA(;
			cProdutivo,;      // cCodPro
			dAuxDtIni,;       // dDataIni
			nAuxHrIni,;       // nHoraIni
			dDtFin,;          // dDataFin
			nHrFin,;          // nHoraFin
			"N",;             // cSitMecR - "N" retorna o tempo calculado
			,;                // lMensagem
			/* "F/D/E/A" */ ) // cTipLevant
			// "D" - Disponivel
			// "F" - Fora do turno
			// "A" - Ausente
			// "O" - Ocupado
			// "E" - Hora Extra
	varInfo("nTempoTrab", nTempoTrab)
	conout(" ")

	// Faz distribuicao do tempo trabalhado porporcioalmente ao tempo padrao dos servicos que serใo apontados
	nSumTemDistribuido := 0
	for nPos := 1 to Len(aSrvcProc)
		aSrvcProc[nPos][4] := aSrvcProc[nPos][3] / nTotTemPad
		aSrvcProc[nPos][5] := round(aSrvcProc[nPos][4] * nTempoTrab,0)
		nSumTemDistribuido += aSrvcProc[nPos][5]
	end
	varinfo("aSrvcProc", aSrvcProc)
	conout(" ")

	// Joga a diferenca de apontamento distribuido para o servico com o maior tempo trabalhado
	aSort(aSrvcProc,,,{ |a,b| a[3] > b[3] })
	aSrvcProc[1][5] += nTempoTrab - nSumTemDistribuido
	varinfo("aSrvcProcAjustado", aSrvcProc)
	conout(" ")

	aSort(aSrvcProc,,,{ |a,b| DtoS(a[7]) + strzero(a[8],8) > DtoS(b[7]) + strzero(b[8],8)})
	varinfo("aSrvcProcFinal", aSrvcProc)
	conout(" ")

	// Levanta os periodos para distribuir os apontamentos calculados
	aPeriodos := ;
		FG_TEMPTRA(;
			cProdutivo,;  // cCodPro
			dAuxDtIni,;   // dDataIni
			nAuxHrIni,;   // nHoraIni
			dDtFin,;      // dDataFin
			2359,;        // nHoraFin
			"A",;         // cSitMecR - "A" - Retorna Array com os periodos
			,;            // lMensagem
			/* "F/D/E/A" */ )                                                       // cTipLevant
			// "D" - Disponivel
			// "F" - Fora do turno
			// "A" - Ausente
			// "O" - Ocupado
			// "E" - Hora Extra
	varinfo("aPeriodos", aPeriodos)
	conout(" ")

	aEval(aPeriodos, { |x| x[2] := oUtil:Hora2Centes(x[2]) , x[4] := oUtil:Hora2Centes(x[4]) })
	varinfo("aPeriodosCentes", aPeriodos)
	conout(" ")

	aSrvcApontamento := {}
	nIndex := 1
	for nPos := 1 to Len(aSrvcProc)
		
		while nIndex <= Len(aPeriodos)

			AADD(aSrvcApontamento, { ;
				aSrvcProc[nPos][02],;  // 01 - Codigo do Servico
				aPeriodos[nIndex][1],; // 02 - Data Inicial
				aPeriodos[nIndex][2],; // 03 - Hora Inicial
				aPeriodos[nIndex][3],; // 04 - Data Final
				0,;                    // 05 - Hora Final 
				0,;                    // 06 - Tempo - Centesimal
				aSrvcProc[nPos][06],;  // 07 - Recno (Remover)
				aSrvcProc[nPos][09],;  // 08 - Tipo de Tempo
				aSrvcProc[nPos][10],;  // 09 - Grupo de Servico
				aSrvcProc[nPos][11] }) // 10 - Tipo de Servico

			nPosSrvcApontamento := Len(aSrvcApontamento)
			// O tempo do servico ้ menor ou igual ao tempo do perํodo, entใo o servi็o cabe no perํodo
			if aSrvcProc[nPos][5] <= aPeriodos[nIndex][6]
				aSrvcApontamento[nPosSrvcApontamento][5] := aPeriodos[nIndex][2] + aSrvcProc[nPos][5]
				//aPeriodos[nIndex][2] := oUtil:SomaHora( aPeriodos[nIndex][2] , oUtil:Min2Hora( oUtil:Centes2Min(aSrvcProc[nPos][5]) ) )
				aPeriodos[nIndex][2] += aSrvcProc[nPos][5]
				aPeriodos[nIndex][6] -= aSrvcProc[nPos][5]
				
				// Ultimo servico a ser processado
				// Se tiver diferenca de minutos (centesimal)
				if nPos == Len(aSrvcProc) .and. aSrvcApontamento[nPosSrvcApontamento][5] <> oUtil:Hora2Centes(nHrFin)
					Conout(" ")
					Conout("                                                                _      _                     ")
					Conout("  /\  ._   _  ._ _|_  _. ._ _   _  ._ _|_  _     _  _  ._ _    | \ o _|_ _  ._ _  ._   _  _. ")
					Conout(" /--\ |_) (_) | | |_ (_| | | | (/_ | | |_ (_)   (_ (_) | | |   |_/ |  | (/_ | (/_ | | (_ (_| ")
					Conout("      |                                                                                      ")
					Conout(" ")
					nAuxDiff := oUtil:Hora2Centes(nHrFin) - aSrvcApontamento[nPosSrvcApontamento][5]
					Conout("nAuxDiff: " + cvaltochar(nAuxDiff))
					Conout("aSrvcApontamento[nPosSrvcApontamento][5]: " + cvaltochar(aSrvcApontamento[nPosSrvcApontamento][5]))
					Conout("aPeriodos[nIndex][4]: " + cvaltochar(aPeriodos[nIndex][4]))
					Conout(" ")
					// Verifica se a diferenca esta dentro do limite aceitavel 
					// E verifica se a hora final calculada mais a diferenca ้ menor ou igual a hora final do periodo que estamos processando
					if Abs(nAuxDiff) <= 5 .and. aSrvcApontamento[nPosSrvcApontamento][5] + nAuxDiff <= aPeriodos[nIndex][4]
						aSrvcApontamento[nPosSrvcApontamento][5] += nAuxDiff
					endif
					Conout("aSrvcApontamento[nPosSrvcApontamento][5]: " + cvaltochar(aSrvcApontamento[nPosSrvcApontamento][5]))
					Conout(" ")
				endif
				exit
			else
				aSrvcApontamento[nPosSrvcApontamento][5] := aPeriodos[nIndex][4]
				aSrvcProc[nPos][5] -= aPeriodos[nIndex][6]
				nIndex++
			endif
		end

	next nPos

	// Faz ajuste 

	aEval(aSrvcApontamento, { |x| x[6] := x[5] - x[3] })
	varInfo("aSrvcApontamentoCentesimal", aSrvcApontamento)

	aEval(aSrvcApontamento, { |x| x[3] := oUtil:Centes2Hora(x[3]) , x[5] := oUtil:Centes2Hora(x[5]) })
	varInfo("aSrvcApontamento", aSrvcApontamento)

	// Deve inicializar sempre para os casos em que vai sera apontado inicio e fim em um mesmo execauto 
	aAuxAutoItens := {}

	for nPos := 1 to Len(aSrvcApontamento)

		//VO4->(dbGoTo(aSrvcApontamento[nPos][7]))
		aAuxIteVO4 := {}
		AADD(aAuxIteVO4, { "VO4_NUMOSV" , VO1->VO1_NUMOSV , nil } )
		AADD(aAuxIteVO4, { "VO4_TIPTEM" , aSrvcApontamento[nPos][08] , nil } )
		AADD(aAuxIteVO4, { "VO4_GRUSER" , aSrvcApontamento[nPos][09] , nil } )
		AADD(aAuxIteVO4, { "VO4_CODSER" , aSrvcApontamento[nPos][01] , nil } )
		AADD(aAuxIteVO4, { "VO4_TIPSER" , aSrvcApontamento[nPos][10] , nil } )
		AADD(aAuxIteVO4, { "VO4_CODPRO" , cProdutivo      , nil } )
		if npos <> 1 .or. lApontIniFim
			AADD(aAuxIteVO4, { "VO4_DATINI" , aSrvcApontamento[nPos][02] , nil } )
			AADD(aAuxIteVO4, { "VO4_HORINI" , aSrvcApontamento[nPos][03] , nil } )
		endif
		AADD(aAuxIteVO4, { "VO4_DATFIN" , aSrvcApontamento[nPos][04] , nil } )
		AADD(aAuxIteVO4, { "VO4_HORFIN" , aSrvcApontamento[nPos][05] , nil } )
		if ! empty(cVO4MAUSA)
			AADD(aAuxIteVO4, { "VO4_MPAUSA" , cVO4MAUSA , nil } )
		endif

		//AADD(aAuxIteVO4, { "VO4_NUMOSV" , VO1->VO1_NUMOSV , nil } )
		//AADD(aAuxIteVO4, { "VO4_TIPTEM" , VO4->VO4_TIPTEM , nil } )
		//AADD(aAuxIteVO4, { "VO4_GRUSER" , VO4->VO4_GRUSER , nil } )
		//AADD(aAuxIteVO4, { "VO4_CODSER" , VO4->VO4_CODSER , nil } )
		//AADD(aAuxIteVO4, { "VO4_TIPSER" , VO4->VO4_TIPSER , nil } )
		//AADD(aAuxIteVO4, { "VO4_CODPRO" , cProdutivo      , nil } )
		//if npos <> 1
		//	AADD(aAuxIteVO4, { "VO4_DATINI" , aSrvcApontamento[nPos][2] , nil } )
		//	AADD(aAuxIteVO4, { "VO4_HORINI" , aSrvcApontamento[nPos][3] , nil } )
		//endif
		//AADD(aAuxIteVO4, { "VO4_DATFIN" , aSrvcApontamento[nPos][4] , nil } )
		//AADD(aAuxIteVO4, { "VO4_HORFIN" , aSrvcApontamento[nPos][5] , nil } )

		AADD( aAuxAutoItens , aClone( aAuxIteVO4 ) )
	next nPos

return .t.

/*/{Protheus.doc} OM030013C_ApontamentoProporcional
Rotina que retorna os apontamentos proporcionais ao tempo padrใo
@type  Function
@author Cristiam Rossi
@since 10/04/2026
@param aInicio, array, Array com os dados de inํcio dos apontamentos
@param aTermino, array, Array com os dados de t้rmino dos apontamentos
@param cNumOS, character, N๚mero da OS para filtro dos apontamentos
@param cProdutivo, character, Indicador se o apontamento ้ produtivo ou nใo para filtro dos apontamentos
@param nRateio, numeric, Tipo de rateio: 1=Tarefa;2=Tipo de Tempo;3=Tipo de Servi็o;4=C๓digo de Servi็o
@param aAlvos, array, lista dos elementos a serem considerados
@return aRetorno, array, Array com os dados dos apontamentos proporcionais
/*/
function OM030013C_ApontamentoProporcional( aInicio, aTermino, cNumOS, cProdutivo, nRateio, aAlvos )
local   aArea      := getArea()
local   aCampos    := { "VO4_SEQINC", "VO4_TIPTEM", "VO4_TIPSER", "VO4_CODSER" }
local   aRetorno   := {}
local   nTotPad    := 0
local   nTotPer    := 0
local   cQuery
local   cAlias
local   aParams    := {}
local   aServicos  := {}
local   aRateio    := {}
local   nAux
local   aAux
local   nI
local   nJ
local   nTpAjust

private oProdutivo

default aInicio    := { CtoD("") , 0 }
default aTermino   := { dDatabase, 2400 }
default cNumOS     := ""
default cProdutivo := ""
default nRateio    := 1		// 1=Tarefa;2=Tipo de Tempo;3=Tipo de Servi็o;4=C๓digo de Servi็o
default aAlvos     := {}

	VAI->( dbSetOrder(1) )
	if VAI->( dbSeek( xFilial("VAI") + cProdutivo ) ) .and. VAI->VAI_FUNPRO == "1"
		oProdutivo := DMS_Produtivo():New( cProdutivo )				// instancia classe com o Produtivo
		oProdutivo:LoadEscala( aInicio[1], aTermino[1] )			// carrega a escala de trabalho/turno do Produtivo no perํodo informado

		cQuery := "select VO4_SEQINC, VO4_TIPTEM, VO4_TIPSER, VO4_CODSER, VO4_GRUSER, VO4_TEMPAD, VO4_SEQUEN "
		cQuery += " from "+retSqlName("VO2")+" VO2"
		cQuery += " join "+retSqlName("VO4")+" VO4"
		cQuery += 		" on  VO4_FILIAL = VO2_FILIAL"
		cQuery += 		" and VO4_NOSNUM = VO2_NOSNUM"
		cQuery += 		" and VO4.D_E_L_E_T_ = ?"			; aAdd( aParams, " " )
		cQuery += " where VO2_FILIAL = ?" 					; aAdd( aParams , xFilial("VO2") )
		cQuery += " and VO2_NUMOSV = ?"						; aAdd( aParams , cNumOS )
		cQuery += " and VO2_TIPREQ = ?"						; aAdd( aParams , "S" )
		cQuery += " and VO2.D_E_L_E_T_ = ?"					; aAdd( aParams, " " )

		if len( aAlvos ) > 0					// caso seja informado serแ filtrado o servi็o mediante Rateio e Alvos
			cQuery += " and ? in ('?')"						; aAdd( aParams, aCampos[nRateio] )		; aAdd( aParams, arrTokStr(aAlvos) )
		endif

		cQuery += " order by VO4_SEQUEN"
		oOM030Statement := FwExecStatement():new( cQuery )
		oOM030Statement:setParams( aParams )
		cQuery := oOM030Statement:getFixQuery()
		cAlias := MPSysOpenQuery( cQuery )

		while ! (cAlias)->( eof() )
			nTotPad += (cAlias)->VO4_TEMPAD			// Acumulo Tempo Padrใo total dos Servi็os filtrados
			(cAlias)->( dbSkip() )
		endDo
		aIni := aClone( aInicio )					// necessแrio pois Array como parโmetro sofre altera็ใo (como variแvel private)
		aFim := aClone( aTermino )
		aAux := OM030014C_RetornaIntervalos( aIni, aFim, 9999 )		// obtem intervalos do produtivo
		aEval( aAux, {|it| nTotPer += oProdutivo:oUtil:Hora2Centes( it[4] ) } )		// acumulo do Total no Perํodo
		nPerc := nTotPer * 100 / nTotPad											// % para pondera็ใo Tempo Padrใo x Tempo Informado

		(cAlias)->( dbGotop() )
		while ! (cAlias)->( eof() )
			nTpAjust := round( (cAlias)->VO4_TEMPAD * nPerc / 100, 0 )		// % Pondera็ใo sobre o Tempo Padrใo do servi็o
			aAdd( aServicos,{;
							(cAlias)->VO4_SEQINC,;
							(cAlias)->VO4_TIPTEM,;
							(cAlias)->VO4_TIPSER,;
							(cAlias)->VO4_CODSER,;
							(cAlias)->VO4_GRUSER,;
							(cAlias)->VO4_TEMPAD,;
							OM030014C_RetornaIntervalos( @aInicio, aTermino, nTpAjust ),;		// 7-intervalos
							nRateio;															// 8-% servi็os na OS
			})

			if ( nPos := aScan( aRateio, {|it| it[1] == (cAlias)->( fieldGet(nRateio) ) }) ) == 0
				aAdd( aRateio, { (cAlias)->( fieldGet(nRateio) ), 0, 0 } )		// acumulo dos itens p/ calculo do rateio
				nPos := len( aRateio )
			endif
			aRateio[nPos,2] += (cAlias)->VO4_TEMPAD

			(cAlias)->( dbSkip() )
		endDo
		(cAlias)->( dbCloseArea() )
	endif

	for nI := 1 to len( aServicos )
		nPos := aScan( aRateio, {|it| it[1] == aServicos[ nI, aServicos[nI,8] ] })			// calculo do % de rateio
		aServicos[nI,8] := round( aServicos[ nI, 6 ] / aRateio[nPos,2] * 100, 2 )
		aRateio[nPos,3] += aServicos[nI,8]
		if abs( 100 - aRateio[nPos,3] ) < 1
			aServicos[nI,8] -= ( 100 - aRateio[nPos,3] )
		endif
	next

	for nI := 1 to len( aServicos )				// la็o final p/ preparar o Array de retorno
		nAux     := 0
		aInicio  := { "", 0 }
		aTermino := { "", 0 }
		for nJ := 1 to len( aServicos[nI,7] )			// Separo o 1ช perํodo e o ๚ltimo perํodo (itens 2 e 3 do array de retorno)
			if empty( aInicio[1] )
				aInicio[1] := aServicos[nI,7,nJ,1]
				aInicio[2] := aServicos[nI,7,nJ,2]
			endif
			aTermino[1] := aServicos[nI,7,nJ,1]
			aTermino[2] := aServicos[nI,7,nJ,3]

			nAux += aServicos[nI,7,nJ,4]
		next

		aAdd( aRetorno, {	aServicos[nI,4],;						// 1-Cod Servico
							aClone( aInicio  ),;					// 2-Data/Hora Inicio
							aClone( aTermino ),;					// 3-Data/Hora Fim
							aServicos[nI,6],;						// 4-Tempo Padrใo
							oProdutivo:oUtil:Hora2Centes( nAux ),;	// 5-Tempo Alocado
							aServicos[nI,8],;						// 6-% pelo tipo
							aServicos[nI,7];						// 7-Intervalos
		})
	next

	fwFreeObj(oOM030Statement)
	fwFreeObj(oProdutivo)

	restArea( aArea )
return aRetorno


/*/{Protheus.doc} OM030014C_RetornaIntervalos
Rotina que retorna os intervalos p/ atender o servi็o
@type  Function
@author Cristiam Rossi
@since 15/04/2026
@param aInicio, array, Array com os dados de inํcio dos apontamentos
@param aTermino, array, Array com os dados de t้rmino dos apontamentos
@param nTempoPad, numeric, tempo padrใo do servi็o
@return aRetorno, array, lista dos perํodos
/*/
static function OM030014C_RetornaIntervalos( aInicio, aTermino, nTempoPad )
local aIntervalos := {}
local nTempoSaldo := nTempoPad
local nPos
local nI
local nJ
local nPosEscala  := aScan( oProdutivo:aEscala, {|it| it[1] == DtoS(aInicio[1]) } )		// posi็ใo do dia da escala
local nIni
local nFim
local nDisp

	begin sequence

	aInicio[2]  := oProdutivo:oUtil:Hora2Centes( aInicio[2]  )
	aTermino[2] := oProdutivo:oUtil:Hora2Centes( aTermino[2] )

	for nI := nPosEscala to len( oProdutivo:aEscala )
		if StoD(oProdutivo:aEscala[nI,1]) <= aTermino[1] .and. oProdutivo:aEscala[nI,4] > 0				// horas disponiveis no dia
			if ( nPos := aScan( oProdutivo:aPeriodo, {|it| it[1] == oProdutivo:aEscala[nI,2] } ) ) > 0

				if aInicio[2] >= max( oProdutivo:aPeriodo[nPos,5], oProdutivo:aPeriodo[nPos,9] )		// se o horแrio for maior que o perํodo
					aInicio[1]  := aInicio[1]++															// avan็o p/ pr๓ximo dia
					aInicio[2]  := 0																	// zero a hora inicial
					nI--																				// volto o dia da escala
					loop
				endif

				for nJ := 1 to len( oProdutivo:aPeriodo[nPos,15] )
					if oProdutivo:aPeriodo[nPos,15,nJ,3] == "D"			// perํodo Disponํvel para trabalho
						if ( aInicio[2] >= oProdutivo:aPeriodo[nPos,15,nJ,1] .and. aInicio[2] < oProdutivo:aPeriodo[nPos,15,nJ,2] ) .or. aInicio[2] < oProdutivo:aPeriodo[nPos,15,nJ,1]

							nIni  := oProdutivo:aPeriodo[nPos,15,nJ,1]			// assume o Inicio do turno
							if aInicio[2] > oProdutivo:aPeriodo[nPos,15,nJ,1]	// se come็ou depois assume o horแrio informado
								nIni  := aInicio[2]
							endif

							nFim := oProdutivo:aPeriodo[nPos,15,nJ,2]			// assume o Fim do turno
							if oProdutivo:aEscala[nI,1] == DtoS(aTermino[1]) .and. aTermino[2] < oProdutivo:aPeriodo[nPos,15,nJ,2]	// se ๚ltimo dia e horario informado for menor
								nFim  := aTermino[2]							// assume horแrio informado
							endif

							if nFim < nIni		// se Fim for menor que inํcio interrompe
								break
							endif

							nDisp := nFim - nIni		// Tempo disponํvel

							if nDisp > nTempoSaldo				// Se Disponํvel for maior que o saldo
								nFim := nIni + nTempoSaldo		// refa็o o Fim
								nDisp := nFim - nIni			// atualizo o Disponํvel
							endif

							aAdd( aIntervalos, { StoD(oProdutivo:aEscala[nI,1]),;				// 1-Data
												int( oProdutivo:oUtil:Centes2Hora( nIni ) ),;	// 2-Hora Inicial
												int( oProdutivo:oUtil:Centes2Hora( nFim ) ),;	// 3-Hora Final
												int( oProdutivo:oUtil:Centes2Hora( nDisp) );	// 4-Disponibilidade
							} )
							aInicio[1]  := aTail( aIntervalos )[1]				// atualizo a data de inํcio
							aInicio[2]  := aTail( aIntervalos )[3] + 1			// atualizo a hora de inํcio pelo fim + 1 minuto
							nTempoSaldo -= nDisp								// abato o Disponivel do Saldo
						endif
					endif
					if nTempoSaldo <= 0				// se zerou o Saldo interrompo
						break
					endif
				next
			endif
		endif
	next

	end sequence
return aIntervalos
