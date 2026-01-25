// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 026    º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#include "protheus.ch"
#include "OFINJD01.CH"
#include 'tbiconn.ch'
#include 'TOPCONN.ch'

#DEFINE IDX_CAMPO    01
#DEFINE IDX_VALOR    02
#DEFINE IDX_SO_NOVO  03
#DEFINE IDX_CHAVE    04

#DEFINE IDX2_FILIAL    01
#DEFINE IDX2_PECA      02
#DEFINE IDX2_DADOS     03
#DEFINE IDX2_DADOS_ADC 04
#DEFINE IDX2_DADOS_ADZ 05

#DEFINE IDX4_FILIAL 01
#DEFINE IDX4_FESTCO 02
#DEFINE IDX4_CTACTB 03
#DEFINE IDX4_CENCUS 04
#DEFINE IDX4_ALMOXA 05
#DEFINE IDX4_GRUITE 06
#DEFINE IDX4_FORNEC 07
#DEFINE IDX4_LOJFOR 08
#DEFINE IDX4_TESENT 09
#DEFINE IDX4_TESSAI 10
#DEFINE IDX4_FABRIC 11

static cTCGetDB := TCGetDB()

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Funcao    | OFINJD01   | Autor |  Luis Delorme         | Data | 23/07/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    | REFACTORED | Autor | Vinicius Gati         | Data | 01/11/16 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descricao | Importacao da arquivo da JD contendo as ultimas atualizacoes |##
##|          | do cadastro e preco de pecas                                 |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Pecas JD                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OFINJD01(aParam)
// Variaveis da ParamBox
Local lAntigo := .f.
Local aSay    := {}
Local aButton := {}
Local nOpc    := 0
//
Local cTitulo := ""
Local cDesc1  := ""
//
Private lSchedule := FWGetRunSchedule()
//
Private cPerg           := "OFINJD01"   // Pergunte quando chamado pelo Menu
Private cPerg_S         := "OFINJD01_S" // Pergunte quando chamado pelo Schedule
Private cLog
Private oArHlp          := Nil
Private cTblLogCod
Private oSql            := Nil
Private cFilCpl         := {}
Private aFilis          := {}
Private cDadosProd
Private lSBZ        	:= SuperGetMV("MV_ARQPROD",.F.,"SB1") == "SBZ"
Private oLogger         := DMS_Logger():New("OFINJD01_"    +dtos(ddatabase)+".LOG")
Private lVL0PPPJD       := .F.

If FWAliasInDic("VL0", .F.) //Complementos DMS - Cadastro de Produtos
	DbSelectArea("VL0")
	DbSetOrder(1)
	lVL0PPPJD := VL0->(FieldPos('VL0_PPPJD')) > 0 //Verifica existência de campo do PPP
	SB1->(DbSetOrder(1))
EndIf

if lSchedule

	If ( VALTYPE(aParam) <> "U" ) // Chamada antiga ( parametros passados na chamada da funcao no cadastro do schedule )
		//
		MV_PAR01 := aParam[3]
		MV_PAR02 := aParam[4]
		MV_PAR03 := aParam[5]
		MV_PAR04 := aParam[6]
		//
		lAntigo := .t.
		//
		cEmpr    := aParam[1] // OFINJD01('99', '01', '\', 'JD', '')
		cFil     := aParam[2]
		cDiret   := aParam[3]
		cMarca   := aParam[4]
		cImpTes  := aParam[5]
		//
		nModulo := 41
		cModulo := "PEC"
		__cInternet := 'AUTOMATICO'
		If Type("cArqTab")=="U"
			cArqTab:=""
		EndIf
		//
		cFOPENed := ""
		DbCloseAll()
		Prepare Environment Empresa cEmpr Filial cFil Modulo cModulo
	Else
		conout("OFINJD01 - " + STR0024 /*"Iniciando"*/)
		conout("OFINJD01 - " + STR0025 /*"Parametros: "*/)
		conout("OFINJD01 -    "+Alltrim(STR0020)+": "+MV_PAR01)
		conout("OFINJD01 -    "+Alltrim(STR0014)+": "+MV_PAR02)
		conout("OFINJD01 -    "+Alltrim(STR0015)+": "+IIf(MV_PAR03==1,STR0016,STR0017))
		conout("OFINJD01 -    "+Alltrim(STR0021)+": "+IIf(MV_PAR04==1,STR0016,STR0017))
		//
	EndIf

Else

	Pergunte(cPerg,.f.)
	If !Pergunte(cPerg,.t.)
		Return
	EndIf

EndIf

cDadosProd  := GetNewPar("MV_MIL0054","SBZ")
oSql        := DMS_SqlHelper():New()
oArHlp      := DMS_ArrayHelper():New()
cTitulo     := STR0001 // "John Deere - Dealer Data Exchange"
cDesc1      := STR0002 // "Importação das ultimas atualizações de peças no cadastro John Deere"
//
if !lSchedule
	//
	//
	aAdd( aSay, cDesc1 )
	//
	aAdd( aButton, { 5, .T., {|| Pergunte(cPerg,.T. )    }} )
	aAdd( aButton, { 1, .T., {|| nOpc := 1, FechaBatch() }} )
	aAdd( aButton, { 2, .T., {|| FechaBatch()            }} )
	//
	FormBatch( cTitulo, aSay, aButton )
	//
	If nOpc <> 1
		Return
	Endif
	//#############################################################################
	//# Chama a rotina de importacao do cadastro de pecas GM                      #
	//#############################################################################
	RptStatus( {|lEnd| RunProc(@lEnd)}, STR0004,STR0005, .T. )
	//
Else
	RunProc()
Endif

Return

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    | RunProc    | Autor |  Luis Delorme         | Data | 23/07/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Importacao da arquivo da JD contendo as ultimas atualizacoes |##
##|          | do cadastro e preco de pecas                                 |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function RunProc(lEnd)
Local cArquivo := ""
Local nIdx     := 1
Local oPIFile  := DMS_PartsInfoFile():New()
Local oDpm     := DMS_DPM():New()
Local cTesEnt  := ""
Local cTesSai  := ""
Local nCntFor

Local nProcessados := 0
Local nX       := 1
Local aVetArq
Local jFile := JsonObject():New()
Local lHasPrevImp := .F.
Local oTabParts := DMS_PartsInfo():New()
Local cBkpFil    := ""
Private aDadosMarca := {}

//
aFilis := oDpm:GetFiliais()

if len(aFilis) == 0
	conout("OFINJD01 - " + STR0029)
	if ! lSchedule
		alert("OFINJD01 - " + STR0029)
	endif
	return
endif

//#############################################################################
//# Tenta abrir o arquivo texto                                               #
//#############################################################################

cArquivo := ALLTRIM(MV_PAR01)

cTblLogCod := oLogger:LogToTable({;
	{'VQL_AGROUP'     , 'OFINJD01'                                  },;
	{'VQL_TIPO'       , 'LOG_EXECUCAO'                              },;
	{'VQL_DADOS'      , 'MODO:' + IIF(!lSchedule, "Normal", "Scheduler")+" - "+Alltrim(cArquivo) } ;
})

if lSchedule
	aVetArq := directory(cArquivo+"PARTINFO_*.DAT")
	if len(aVetArq) > 0
		cArquivo += aVetArq[1,1]
		Conout("OFINJD01 - " + STR0026 /*Arquivo : */+ cArquivo)
	else
		Conout("OFINJD01 - " + STR0027 /*"Arquivo não encontrado no local indicado: " */ + cArquivo )
		return
	Endif
Endif

oFile := FwFileReader():New(Alltrim(cArquivo))
if ! oFile:Open()
	if !lSchedule
		MsgStop(STR0006+cArquivo+STR0007,STR0008)
	Else
		Conout("OFINJD01 - "+STR0006+cArquivo+STR0007)
	endif
	oLogger:LogToTable({;
		{'VQL_AGROUP'     , 'OFINJD01'                                },;
		{'VQL_TIPO'       , 'LOG_EXECUCAO'                            },;
		{'VQL_DADOS'      , STR0006+" "+Alltrim(cArquivo)+" "+STR0007 },;
		{'VQL_CODVQL'     , cTblLogCod                                } ;
	})
	Return
Endif

nProcessados := 0
nTotal := 0

// Verificar depois se isso vai dar problema na Argentina !!!
oTabParts:InsertParts() //Insere os itens que não existem na tabela temporaria

nMV_PAR04 := MV_PAR04
nMV_PAR05 := MV_PAR05

if ValType( MV_PAR06) != "N" .and. empty(MV_PAR06)
	MV_PAR06 := 0 // Moeda
endif

If cPaisLoc $ "ARG,MEX"
	nMV_PAR06 := IIf(MV_PAR06>0.and.MV_PAR06<=MoedFin(),MV_PAR06,1) // Moeda
EndIf

cBkpFil := cFilAnt //Ao final do Loop abaixo, ficava na filial errada.

for nIdx := 1 to LEN(aFilis)
	if EMPTY(aFilis[nIdx, 1])
		loop
	EndIf
	cFilant := aFilis[nIdx, 1]
	if Empty(cFilCpl)
		cFilCpl := cFilant
	EndIf
	//#############################################################################
	//# Armazena informacoes da marca                                             #
	//#############################################################################
	DBSelectArea("VE4")
	DBSetOrder(1)
	DBSeek(xFilial("VE4") + MV_PAR02 )
	cFEstCo := IF(VE4->VE4_FESTCO=="0","N","S")
	cCtaCtb := VE4->VE4_CTACTB
	cCenCus := VE4->VE4_CENCUS
	cAlmox  := VE4->VE4_ALMPAD
	cGruIte := VE4->VE4_GRUITE
	cCodFor := VE4->VE4_CODFOR
	cLojFor := VE4->VE4_LOJFOR
	//
	DBSelectArea("VE1")
	DBSetOrder(1)
	DBSeek(xFilial("VE1") + MV_PAR02 )
	cFabric := left(VE1->VE1_DESMAR,20)
	cTesEnt := ''
	cTesSai := ''
	if MV_PAR03 == 1
		cTesEnt := VE4->VE4_TESENT
		cTesSai := VE4->VE4_TESSAI
	Endif
	AADD( aDadosMarca, {cFilAnt,cFEstCo,cCtaCtb,cCenCus,cAlmox,cGruIte,cCodFor,cLojFor,cTesEnt,cTesSai,cFabric} )

Next

cFilAnt := cBkpFil //Ficava na última filial do For acima

aLines := {}

// Tratamento PPP
jDadosPPP := JsonObject():New()

if lVL0PPPJD
	cAlias := GetnextAlias()

	cQuery := "SELECT VL0_CODPEC, B1_CONV "
	cQuery += "  FROM " + oSql:nolock("VL0")
	cQuery += "  JOIN " + oSql:nolock("SB1") + " ON B1_FILIAL = VL0_FILIAL AND B1_COD = VL0_CODPEC " 
	cQuery += "   AND SB1.B1_TIPCONV = 'D' AND SB1.D_E_L_E_T_ = ' ' AND SB1.B1_CONV <> 0 "
	cQuery += " WHERE VL0_FILIAL = '" + xFilial("VL0") + "' AND VL0_PPPJD = '1' AND VL0.D_E_L_E_T_ = ' ' "
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAlias , .F., .T. )
	While !(cAlias)->(Eof())
		jDadosPPP[alltrim((cAlias)->VL0_CODPEC)] := (cAlias)->B1_CONV
		(cAlias)->(DbSkip())
	EndDo
	(cAlias)->(dbCloseArea())
endif


if oPIFile:AlgumAnterior()
	jFile := oPIFile:ArquivoAnterior()
endif

cTime02 := time()
oLogger:Log({'TIMESTAMP', "OFINJD01 - CARREGANDO PARTSINFO - " + alltrim(cTCGetDB)})
while oFile:hasLine()
	cStr := oFile:GetLine()

	if len(cStr) < 255 .or. left(cStr, 8) == "PARTINFO"
		loop
	else
		cStr := ReplaceMultibyte(cStr)
		cStr := StrTran(cStr,chr(32)+chr(10),'')
		cStr := StrTran(cStr,chr(13)+chr(10),'')
		aadd(aLines, cStr)
	end
enddo
oFile:Close()
oLogger:Log({'TIMESTAMP', "OFINJD01 - ARQUIVO CARREGADO - " + ElapTime(cTime02, time())})

nQtdReg := len(aLines)

aLotes := {}
aLote := {}
oLogger:Log({'TIMESTAMP', "OFINJD01 - INICIANDO IMPORTACAO DE "+ cValToChar(nQtdReg) + " REGISTROS - " + alltrim(cTCGetDB)})

cTime01 := time()
cTime02 := time()

lContinue := .t.
nX := 1
nTamanhoLote := 25000

while lContinue
	cLinha := aLines[nX]

	if len(aLote) < nTamanhoLote
		aadd(aLote, cLinha)

		if len(aLote) >= nTamanhoLote // se chegou a mil acabou o lote comeco a montar outro
			aadd(aLotes, aClone(aLote))
			aLote := {}
		endif
	endif
	nX ++
	if nX > len(aLines) // se chegou a ultima linha do arquivo
		aadd(aLotes, aClone(aLote)) // adiciona o ultimo lote
		lContinue := .f.
	endif
end do

oLogger:Log({'TIMESTAMP', "OFINJD01 - Resumo dos lotes tamanho: " + cValToChar(nTamanhoLote) + " quantidade: " + cValToChar(len(aLotes))})

nProcessados := 0
nTotalRegs := len(aLines)

if ! lSchedule
	SetRegua(len(aLotes))
endif

lHasPrevImp := FM_SQL("SELECT COUNT(*) FROM " + oTabParts:TableNameParts() + " WHERE DATAIMP = '" + DtoS(dDataBase) + "' ") > 0

For nX := 1 to len(aLotes)
	aLote := aLotes[nX]

	BEGIN TRANSACTION
	
		nQtdPrcR := doImp(aLote, nProcessados, nTotalRegs, jFile, jDadosPPP, oPIFile, lHasPrevImp)
		nProcessados += len(aLote)

		oLogger:Log({'TIMESTAMP', "OFINJD01 - Lote processado em: " + ElapTime(cTime02, time()) + " - " +cValToChar(nProcessados)+ " Estimativa " + estimativa(ElapTime(cTime01, time()), nProcessados, nQtdReg) })
		cTime02 := time()

		if nQtdPrcR > 0
			oPIFile:SalvaParcial(aLote)
		endif

		if ! lSchedule
			IncRegua()
		endif
	END TRANSACTION
next

oLogger:Log({'TIMESTAMP', "OFINJD01 - Processamento do último lote concluído"})
oLogger:Log({'TIMESTAMP', "OFINJD01 - Criando registros na tabela de produtos"})
cTime02 := time()
// Cria / Atualiza Registros da SB1 e SB5
JD01ProcLote()
//
oLogger:Log({'TIMESTAMP', "OFINJD01 - Registros atualizados na tabela de produtos - " + ElapTime(cTime02, time())})
oLogger:Log({'TIMESTAMP', "OFINJD01 - Salvando Backup do arquivo importado"})
cTime02 := time()
oPIFile:SalvaArquivoImportado(aLines)
oLogger:Log({'TIMESTAMP', "OFINJD01 - Backup Finalizado - " + ElapTime(cTime02, time())})
oLogger:Log({'TIMESTAMP', "OFINJD01 - Importacao finalizada - " + ElapTime(cTime01, time())})
//

//#############################################################################
//# Move o arquivo para o diretorio SALVA                                     #
//#############################################################################
lErro := .f.
cPath := ""
cArquivo := ""
cArq := oFile:getFileName()
For nCntFor := Len(cArq) to 1 step -1
	if Subs(cArq,nCntFor,1) == "\" // "
		cPath = Left(cArq,nCntFor)
		cArquivo := SUBS(cArq,nCntFor+1,60)
		exit
	endif
next

cPathS = cPath + "SALVA"
aDir := Directory(cPathS,"D")
If Len(aDir) = 0
	If MakeDir(cPathS) <> 0
		lErro := .t.
	EndIf
endif
if !lErro
	Copy File &(cPath+cArquivo) to &(cPath+"SALVA\"+cArquivo) //"
	Dele File &(Alltrim(cArq))
endif
cFilAnt := cBkpFil //Ficava na última filial do For acima
oLogger:CloseOpened(cTblLogCod)

if !lSchedule
	if !Empty(cLog)
		DEFINE MSDIALOG oDlgLog TITLE OemtoAnsi(STR0009) FROM  08.1,10.6 TO 30.4,80.3 OF oMainWnd
		@ 001,001 GET oMsgLog VAR cLog OF oDlgLog MEMO SIZE 273,140 PIXEL READONLY MEMO
		DEFINE SBUTTON FROM 152,240 TYPE 1 ACTION oDlgLog:End() ENABLE OF oDlgLog
		//
		ACTIVATE MSDIALOG oDlgLog CENTER
		//
	Endif
Endif
DBSelectArea("SB1")
DBSetOrder(1)

if !lSchedule
	MsgInfo(STR0010,STR0008) // Arquivo importado com sucesso.
Else
	Conout("OFINJD01 - "+STR0010) // Arquivo importado com sucesso.
Endif
//
Return

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    | CriaSX1    | Autor |  Luis Delorme         | Data | 30/05/11 |##
##+----------+------------+-------+-----------------------+------+----------+##
###############################################################################
===============================================================================
*/
// Static Function CriaSX1()
// 	Local aSX1    := {}
// 	Local aEstrut := {}
// 	Local i       := 0
// 	Local j       := 0
// 	Local lSX1	  := .F.
// 	Local nOpcGetFil := GETF_LOCALHARD + GETF_NETWORKDRIVE
// 	Local nOpcDiret  := GETF_RETDIRECTORY

// 	aEstrut:= { "X1_GRUPO"  ,"X1_ORDEM","X1_PERGUNT","X1_PERSPA","X1_PERENG" ,"X1_VARIAVL","X1_TIPO" ,"X1_TAMANHO","X1_DECIMAL","X1_PRESEL"	,;
// 	"X1_GSC"    ,"X1_VALID","X1_VAR01"  ,"X1_DEF01" ,"X1_DEFSPA1","X1_DEFENG1","X1_CNT01","X1_VAR02"  ,"X1_DEF02"  ,"X1_DEFSPA2"	,;
// 	"X1_DEFENG2","X1_CNT02","X1_VAR03"  ,"X1_DEF03" ,"X1_DEFSPA3","X1_DEFENG3","X1_CNT03","X1_VAR04"  ,"X1_DEF04"  ,"X1_DEFSPA4"	,;
// 	"X1_DEFENG4","X1_CNT04","X1_VAR05"  ,"X1_DEF05" ,"X1_DEFSPA5","X1_DEFENG5","X1_CNT05","X1_F3"     ,"X1_GRPSXG" ,"X1_PYME"}

// 	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
// 	//³ aAdd a Pergunta                                              ³
// 	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

// 	// Pergunte quando chamado pelo Menu
// 	aAdd(aSX1,{cPerg,"01",STR0013,"","","MV_CH1","C",99,0,0,"G","Mv_Par01:=cGetFile('Arquivos |PARTINFO*.DAT','',,,,"+AllTrim(Str(nOpcGetFil))+")","mv_par01",""     ,"","","","",""     ,"","","","","","","","","","","","","","","","","","",""   ,"","S"})
// 	aAdd(aSX1,{cPerg,"02",STR0014,"","","MV_CH2","C",03,0,0,"G",""                                                                                ,"mv_par02",""     ,"","","","",""     ,"","","","","","","","","","","","","","","","","","","VE1","","S"})
// 	aAdd(aSX1,{cPerg,"03",STR0015,"","","MV_CH3","N",01,0,0,"C",""                                                                                ,"mv_par03",STR0016,"","","","",STR0017,"","","","","","","","","","","","","","","","","","",""   ,"","" })
// 	aAdd(aSX1,{cPerg,"04",STR0021,"","","MV_CH4","N",01,0,0,"C",""                                                                                ,"mv_par04",STR0016,"","","","",STR0017,"","","","","","","","","","","","","","","","","","",""   ,"","" })
// 	aAdd(aSX1,{cPerg,"05",STR0022,"","","MV_CH5","N",01,0,0,"C",""                                                                                ,"mv_par05",STR0016,"","","","",STR0017,"","","","","","","","","","","","","","","","","","",""   ,"","" })

// 	// Pergunte quando chamado pelo Schedule
// 	aAdd(aSX1,{cPerg_S,"01",STR0020,"","","MV_CH1","C",99,0,0,"G","MV_PAR01:=cGetFile('Diretorio','',,,,"+AllTrim(Str(nOpcDiret))+")"             ,"MV_PAR01",""     ,"","","","",""     ,"","","","","","","","","","","","","","","","","","",""   ,"","S"})
// 	aAdd(aSX1,{cPerg_S,"02",STR0014,"","","MV_CH2","C",03,0,0,"G",""                                                                              ,"mv_par02",""     ,"","","","",""     ,"","","","","","","","","","","","","","","","","","","VE1","","S"})
// 	aAdd(aSX1,{cPerg_S,"03",STR0015,"","","MV_CH3","N",01,0,0,"C",""                                                                              ,"mv_par03",STR0016,"","","","",STR0017,"","","","","","","","","","","","","","","","","","",""   ,"","" })
// 	aAdd(aSX1,{cPerg_S,"04",STR0021,"","","MV_CH4","N",01,0,0,"C",""                                                                              ,"mv_par04",STR0016,"","","","",STR0017,"","","","","","","","","","","","","","","","","","",""   ,"","" })
// 	aAdd(aSX1,{cPerg_S,"05",STR0022,"","","MV_CH5","N",01,0,0,"C",""                                                                                ,"mv_par05",STR0016,"","","","",STR0017,"","","","","","","","","","","","","","","","","","",""   ,"","" })

// 	dbSelectArea("SX1")
// 	dbSetOrder(1)
// 	For i:= 1 To Len(aSX1)
// 		If !Empty(aSX1[i][1])
// 			If !dbSeek(Left(Alltrim(aSX1[i,1])+SPACE(100),Len(SX1->X1_GRUPO))+aSX1[i,2])
// 				lSX1 := .T.
// 				RecLock("SX1",.T.)

// 				For j:=1 To Len(aSX1[i])
// 					If !Empty(FieldName(FieldPos(aEstrut[j])))
// 						FieldPut(FieldPos(aEstrut[j]),aSX1[i,j])
// 					EndIf
// 				Next j

// 				dbCommit()
// 				MsUnLock()
// 			EndIf
// 		EndIf
// 	Next i
// return

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Funcao    |JD01ProcLote| Autor |  Vinicius Gati        | Data | 07/11/16 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descricao | Processa as peças que estão na fila(queue)                   |##
##|          |                                                              |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function JD01ProcLote()

	Local nIdx := 0
	Local cTime03
	Local cTime04
	Local nIdx2  := 0
	Local nIdx3 := 0
	Local lPEOJD01AGR := ExistBlock('OJD01AGR')
	Local aPecaSB1Alt := {}
	Local aPecaSB1Inc := {}
	Local aPecaSB5Alt := {}
	Local aPecaSB5Inc := {}

	Private aPecaSB1 := {}
	Private aPecaSB5 := {}
	Private aDadosPeca   := {}
	Private aDadosAdPeca := {}

	//
	for nIdx := 1 to LEN(aFilis)

		cFilAnt := aFilis[nIdx, 1]

		cTime04 := time()
		oLogger:Log({'TIMESTAMP', "OFINJD01 - Processando a filial: " + cFilAnt + "  (" + alltrim(cValToChar(nIdx)) + "/" + alltrim(cValToChar(len(aFilis))) + ")"})

		//Alteração dos itens importados na SB1
		cTime03 := time()

		//Incluisão dos itens novos na SB1
		cTime03 := time()

		If lPEOJD01AGR

			//Alteração da SB1
			cTime03 := time()
			oLogger:Log({'TIMESTAMP', "OFINJD01 PEOJD01AGR -    Atualizando SB1"})
			aPecaSB1Alt := OFNJD010085_ItensSB1(.f.)
			oLogger:Log({'TIMESTAMP', "OFINJD01 PEOJD01AGR -    Atualizando SB1 - Fim - " + ElapTime(cTime03, time())})

			//Inclusão da SB1
			cTime03 := time()
			oLogger:Log({'TIMESTAMP', "OFINJD01 PEOJD01AGR -    Incluindo SB1"})
			aPecaSB1Inc := OFNJD010085_ItensSB1(.t.)
			oLogger:Log({'TIMESTAMP', "OFINJD01 PEOJD01AGR -    Incluindo SB1 - Fim - " + ElapTime(cTime03, time())})

			//Alteração da SB5
			cTime03 := time()
			oLogger:Log({'TIMESTAMP', "OFINJD01 PEOJD01AGR -    Atualizando SB5"})
			aPecaSB5Alt := OFNJD010095_ItensSB5(.f.)
			oLogger:Log({'TIMESTAMP', "OFINJD01 PEOJD01AGR -    Atualizando SB5 - Fim - " + ElapTime(cTime03, time())})

			//Incluisão da SB5
			cTime03 := time()
			oLogger:Log({'TIMESTAMP', "OFINJD01 PEOJD01AGR -    Incluindo SB5"})
			aPecaSB5Inc := OFNJD010095_ItensSB5(.t.)
			oLogger:Log({'TIMESTAMP', "OFINJD01 PEOJD01AGR -    Incluindo SB5 - Fim - " + ElapTime(cTime03, time())})

		Else

			//Alteração da SB1
			cTime03 := time()
			oLogger:Log({'TIMESTAMP', "OFINJD01 -    Atualizando SB1"})
			OFNJD010055_AlteraItensSB1()
			oLogger:Log({'TIMESTAMP', "OFINJD01 -    Atualizando SB1 - Fim - " + ElapTime(cTime03, time())})

			//Inclusão da SB1
			cTime03 := time()
			oLogger:Log({'TIMESTAMP', "OFINJD01 -    Incluindo SB1"})
			OFNJD010025_IncluiItensSB1()
			oLogger:Log({'TIMESTAMP', "OFINJD01 -    Incluindo SB1 - Fim - " + ElapTime(cTime03, time())})

			//Alteração dos itens importados na SB5
			cTime03 := time()
			oLogger:Log({'TIMESTAMP', "OFINJD01 -    Alterando SB5"})
			OFNJD010065_AlteraItensSB5()
			oLogger:Log({'TIMESTAMP', "OFINJD01 -    Alterando SB5 - Fim - " + ElapTime(cTime03, time())})

			//Incluisão dos itens novos na SB5
			cTime03 := time()
			oLogger:Log({'TIMESTAMP', "OFINJD01 -    Incluindo SB5"})
			OFNJD010035_IncluiItensSB5()
			oLogger:Log({'TIMESTAMP', "OFINJD01 -    Incluindo SB5 - Fim - " + ElapTime(cTime03, time())})

		EndIf

		oLogger:Log({'TIMESTAMP', "OFINJD01 - Fim do Processamento da Filial: " + cFilAnt + " - " + ElapTime(cTime04, time())})

		If Len(aPecaSB1Inc) > 0
			For nIdx2 := 1 to LEN(aPecaSB1Inc)
				aItem := aPecaSB1Inc[nIdx2]
				RecLock("SB1", .T. /*Novo*/ )
					for nIdx3 := 1 to LEN(aItem)
						aDadosCampo := aItem[nIdx3]
						if ValType(aDadosCampo[IDX_VALOR]) == "C"
							SB1->&( aDadosCampo[IDX_CAMPO] ) := FwNoAccent(Alltrim(aDadosCampo[IDX_VALOR]))
						Else
							SB1->&( aDadosCampo[IDX_CAMPO] ) := aDadosCampo[IDX_VALOR]
						Endif
					next
				SB1->(MsUnLock())
			Next
		EndIf

		If Len(aPecaSB1Alt) > 0
			For nIdx2 := 1 to LEN(aPecaSB1Alt)
				aItem := aPecaSB1Alt[nIdx2]
				SB1->(dbSetOrder(1))
				SB1->(dbSeek(xFilial('SB1')+aItem[IDX2_PECA,IDX_VALOR]))
				RecLock("SB1", .F. /**/ )
					for nIdx3 := 1 to LEN(aItem)
						aDadosCampo := aItem[nIdx3]
						If aDadosCampo[IDX_SO_NOVO] == .F.
							if ValType(aDadosCampo[IDX_VALOR]) == "C"
								SB1->&( aDadosCampo[IDX_CAMPO] ) := FwNoAccent(Alltrim(aDadosCampo[IDX_VALOR]))
							Else
								SB1->&( aDadosCampo[IDX_CAMPO] ) := aDadosCampo[IDX_VALOR]
							Endif
						EndIf
					next
				SB1->(MsUnLock())
			Next
		EndIf

		//
		// Criao do SB5
		//
		If Len(aPecaSB5Inc) > 0
			For nIdx2 := 1 to LEN(aPecaSB5Inc)
				aItem := aPecaSB5Inc[nIdx2]
				RecLock("SB5", .T.)
					for nIdx3 := 1 to LEN(aItem)
						aDadosCampo := aItem[nIdx3]
						SB5->&( aDadosCampo[IDX_CAMPO] ) := aDadosCampo[IDX_VALOR]
					next
				SB5->(MsUnLock())
			Next
		Endif
		If Len(aPecaSB1Alt) > 0
			For nIdx2 := 1 to LEN(aPecaSB1Alt)
				aItem := aPecaSB1Alt[nIdx2]
				SB5->(dbSetOrder(1))
				SB5->(dbSeek(xFilial('SB5')+aItem[IDX2_PECA,IDX_VALOR]))
				RecLock("SB5", .F. /**/ )
					for nIdx3 := 1 to LEN(aItem)
						aDadosCampo := aItem[nIdx3]
						If aDadosCampo[IDX_SO_NOVO] == .F.
							SB5->&( aDadosCampo[IDX_CAMPO] ) := aDadosCampo[IDX_VALOR]
						EndIf
					next
				SB5->(MsUnLock())
			Next
		EndIF
	Next
	//
Return .T.

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Funcao    | SchedDef   | Autor | Andre Luis Almeida    | Data | 13/04/17 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descricao | Funcao utilizada no cadastro de Schedule                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function SchedDef()
Local aParam := {;
	"P",;
	"OFINJD01_S",;
	"",;
	"",;
	"" ;
	}
Return aParam

/*/{Protheus.doc} OFNJD010025_IncluiItensSB1
	Função que faz a inclusão dos itens novos
	@type function
	@version 1.0
	@author Renato Vinicius
	@since 14/11/2024
/*/

Static Function OFNJD010025_IncluiItensSB1()

	Local oTabParts := DMS_PartsInfo():New()
	Local cQuery    := ""

	aMarca := aDadosMarca[ ASCAN(aDadosMarca, {|aDt| aDt[IDX4_FILIAL] == cFilAnt }) ]

	cQuery := "INSERT INTO " + RetSqlName("SB1") 
	cQuery += " ( "
	cQuery += "B1_GRUPO   , "
	cQuery += "B1_LOCPAD  , "
	cQuery += "B1_FABRIC  , "
	cQuery += "B1_LOJPROC , "
	cQuery += "B1_FORAEST , "
	cQuery += "B1_CONTA   , "
	cQuery += "B1_CC      , "
	cQuery += "B1_PROC    , "
	cQuery += "B1_TS      , "
	cQuery += "B1_TE      , "
	cQuery += "B1_FILIAL,"
	cQuery += "B1_COD   ,"
	cQuery += "B1_DESC  ,"
	cQuery += "B1_PRV1  ,"
	cQuery += "B1_PESO  ,"
	cQuery += "B1_CRICOD,"
	cQuery += "B1_POSIPI,"
	cQuery += "B1_REMANE,"
	If(nMV_PAR05==1)
		cQuery += "B1_GRUDES,"
	EndIf
	cQuery += "B1_UREV  ,"
	cQuery += "B1_DTREFP1 ,"
	cQuery += "B1_CODITE,"
	cQuery += "B1_CODFAB,"
	cQuery += "B1_PERINV,"
	cQuery += "B1_IPI   ,"
	cQuery += "B1_PICMENT ,"
	cQuery += "B1_FLAGSUG ,"
	cQuery += "B1_CLASSVE ,"
	cQuery += "B1_ANUENTE ,"
	cQuery += "B1_MSBLQL,"
	cQuery += "B1_BALANCA ,"
	cQuery += "B1_ENVOBR,"
	cQuery += "B1_LOCALIZ ,"
	cQuery += "B1_CONTSOC ,"
	cQuery += "B1_SITPROD ,"
	cQuery += "B1_MONO  ,"
	cQuery += "B1_FANTASM ,"
	cQuery += "B1_TIPODEC ,"
	cQuery += "B1_CONTRAT ,"
	cQuery += "B1_IRRF  ,"
	cQuery += "B1_GRADE ,"
	cQuery += "B1_IMPZFRC ,"
	cQuery += "B1_TIPOCQ,"
	cQuery += "B1_APROPRI ,"
	cQuery += "B1_TIPO  ,"
	cQuery += "B1_SEGUM ,"
	cQuery += "B1_UM    ,"
	cQuery += "B1_ATIVO ,"
	cQuery += "B1_PIS   ,"
	cQuery += "B1_COFINS,"
	cQuery += "B1_ORIGEM,"
	cQuery += "B1_CLASSE,"
	cQuery += "B1_PEDPRO"
	If cPaisLoc $ "ARG,MEX"
		cQuery += ",B1_MOEDA"
	endif
	cQuery += ", R_E_C_N_O_ ) "

	cQuery += " SELECT "
	cQuery += " '"+Alltrim(aMarca[IDX4_GRUITE])+"'"
	cQuery += ",'"+Alltrim(aMarca[IDX4_ALMOXA])+"'"
	cQuery += ",'"+Alltrim(aMarca[IDX4_FABRIC])+"'"
	cQuery += ",'"+Alltrim(aMarca[IDX4_LOJFOR])+"'"
	cQuery += ",'"+Alltrim(aMarca[IDX4_FESTCO])+"'"
	cQuery += ",'"+Alltrim(aMarca[IDX4_CTACTB])+"'"
	cQuery += ",'"+Alltrim(aMarca[IDX4_CENCUS])+"'"
	cQuery += ",'"+Alltrim(aMarca[IDX4_FORNEC])+"'"
	cQuery += ",'"+Alltrim(aMarca[IDX4_TESSAI])+"'"
	cQuery += ",'"+Alltrim(aMarca[IDX4_TESENT])+"'"
	cQuery += ",'"+xFilial("SB1") + "'"
	cQuery += ",PRODUTO "
	cQuery += ",DESCRICAO "
	cQuery += ",PRECOATU "
	cQuery += ",PESOATU "
	cQuery += ",CRICODATU "
	cQuery += ",POSIPIATU "
	cQuery += ",REMANEATU "
	If(nMV_PAR05==1)
		cQuery += ",GRUDESATU"
	EndIf
	cQuery += ",'"+ DtoS(dDataBase) + "' "
	cQuery += ",'"+ DtoS(dDataBase) + "' "
	cQuery += ",PRODUTO"
	cQuery += ",PRODUTO"
	cQuery += ", 180"
	cQuery += ", 0"
	cQuery += ", 0"
	cQuery += ", '1'"
	cQuery += ", '1' "
	cQuery += ", '2' "
	cQuery += ", '2' "
	cQuery += ", '0' "
	cQuery += ", '0' "
	cQuery += ", 'N' "
	cQuery += ", 'N' "
	cQuery += ", 'N' "
	cQuery += ", 'N' "
	cQuery += ", 'N' "
	cQuery += ", 'N' "
	cQuery += ", 'N' "
	cQuery += ", 'N' "
	cQuery += ", 'N' "
	cQuery += ", 'N' "
	cQuery += ", 'M' "
	cQuery += ", 'D' "
	cQuery += ", 'ME'"
	cQuery += ", 'PC'"
	cQuery += ", 'PC'"
	cQuery += ", 'S' "
	cQuery += ", 'S' "
	cQuery += ", 'S' "
	cQuery += ", ' ' "
	cQuery += ", ' ' "
	cQuery += ", '1' "
	If cPaisLoc $ "ARG,MEX"
		cQuery += "," + AllTrim(Str(nMV_PAR06)) // Moeda
	endif
	cQuery += ", ROW_NUMBER() OVER (ORDER BY PRODUTO) + (SELECT coalesce(MAX(R_E_C_N_O_),0) FROM " +RetSqlName("SB1")+ ")"
	cQuery += " FROM " + oTabParts:TableNameParts()
	cQuery += " WHERE "
	//cQuery += "PRODUTO NOT IN ( SELECT trim(SB1.B1_COD) FROM " + RetSqlName("SB1")+ " SB1 WHERE SB1.B1_FILIAL = '" +xFilial("SB1")+ "' AND SB1.D_E_L_E_T_ = ' ' ) AND "
	cQuery += " NOT EXISTS ( SELECT 1 FROM " +RetSqlName("SB1")+ " SB1 WHERE SB1.B1_FILIAL = '" +xFilial("SB1")+ "' AND SB1.B1_COD = " + oTabParts:TableNameParts() + ".PRODUTO and SB1.D_E_L_E_T_ = ' ' ) AND "
	cQuery += "DATAIMP = '" + DtoS(dDataBase) + "' AND "
	cQuery += "PRECOANT  IS NULL AND "
	cQuery += "PESOANT   IS NULL AND "
	cQuery += "CRICODANT IS NULL AND "
	cQuery += "POSIPIANT IS NULL AND "
	cQuery += "REMANEANT IS NULL "
	If(nMV_PAR05==1)
		cQuery += "AND GRUDESANT IS NULL "
	EndIf

	//oLogger:Log({'TIMESTAMP',"                                            " + cQuery})

	OFNJD010075_GeraLogExecQuery(cQuery)

Return

/*/{Protheus.doc} OFNJD010035_IncluiItensSB5
	Função que faz a inclusão dos itens novos na tabela SB5
	@type function
	@version 1.0
	@author Renato Vinicius
	@since 14/11/2024
/*/

Static Function OFNJD010035_IncluiItensSB5()

	Local oTabParts := DMS_PartsInfo():New()
	Local cQuery    := ""

	cQuery := "INSERT INTO " + RetSqlName("SB5") 
	cQuery += " ( "
	cQuery += "B5_FILIAL,"
	cQuery += "B5_COD   ,"
	cQuery += "B5_PRV2  ,"
	cQuery += "B5_PRV3  ,"
	cQuery += "B5_PRV4  ,"
	cQuery += "B5_PRV5,"
	cQuery += "B5_PRV6,"
	cQuery += "B5_DTREFP2,"
	cQuery += "B5_DTREFP3,"
	cQuery += " R_E_C_N_O_ ) "

	cQuery += " SELECT "
	cQuery += "'"+xFilial("SB5") + "'"
	cQuery += ",PRODUTO "
	cQuery += ",CASE WHEN PRECOATU2 IS NULL THEN 0 ELSE PRECOATU2 END "
	cQuery += ",CASE WHEN PRECOATU3 IS NULL THEN 0 ELSE PRECOATU3 END "
	cQuery += ",CASE WHEN PRECOATU4 IS NULL THEN 0 ELSE PRECOATU4 END "
	cQuery += ",CASE WHEN PRECOATU5 IS NULL THEN 0 ELSE PRECOATU5 END "
	cQuery += ",CASE WHEN PRECOATU6 IS NULL THEN 0 ELSE PRECOATU6 END "
	cQuery += ",'" + DtoS(dDataBase) + "' "
	cQuery += ",'" + DtoS(dDataBase) + "' "
	cQuery += ", CASE WHEN (SELECT coalesce(MAX(R_E_C_N_O_),0) FROM " +RetSqlName("SB5")+ ") IS NULL THEN ROW_NUMBER() OVER (ORDER BY PRODUTO) ELSE ROW_NUMBER() OVER (ORDER BY PRODUTO) + (SELECT coalesce(MAX(R_E_C_N_O_),0) FROM " +RetSqlName("SB5")+ ") END "
	cQuery += " FROM " + oTabParts:TableNameParts()
	cQuery += " WHERE "
	//cQuery += "PRODUTO NOT IN ( SELECT SB5.B5_COD FROM " + RetSqlName("SB5")+ " SB5 WHERE SB5.B5_FILIAL = '" +xFilial("SB5")+ "' AND SB5.D_E_L_E_T_ = ' ' ) AND "
	cQuery += " NOT EXISTS ( SELECT 1 FROM " + RetSqlName("SB5")+ " SB5 WHERE SB5.B5_FILIAL = '" +xFilial("SB5")+ "' AND SB5.B5_COD = " + oTabParts:TableNameParts() + ".PRODUTO and SB5.D_E_L_E_T_ = ' ' ) AND "
	cQuery += "DATAIMP = '" + DtoS(dDataBase) + "' AND "
	cQuery += "PRECOANT2 IS NULL AND "
	cQuery += "PRECOANT3 IS NULL AND "
	cQuery += "PRECOANT4 IS NULL AND "
	cQuery += "PRECOANT5 IS NULL AND "
	cQuery += "PRECOANT6 IS NULL  "
	//cQuery += "AND FILIAL = '"+xFilial("SB5") + "' "

	//oLogger:Log({'TIMESTAMP', "                                            " + cQuery})

	OFNJD010075_GeraLogExecQuery(cQuery)

Return

/*/{Protheus.doc} OFNJD010055_AlteraItensSB1
	
	@type function
	@version 1.0
	@author Renato Vinicius
	@since 14/11/2024
/*/
Static Function OFNJD010055_AlteraItensSB1()

	Local oTabParts := DMS_PartsInfo():New()
	Local cQuery    := ""
	Local cMoedaSel := ""
	Local cUPDATE   := ""
	Local cWHERE    := ""

	If cPaisLoc $ "ARG/MEX"
		cMoedaSel := AllTrim(Str(nMV_PAR06))
	EndIf

	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// Campos para realizar o UPDATE ( todos os bancos são iguais )                                                      //
	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	cUPDATE := "  B1_PRV1   = CASE WHEN SB1.B1_PRV1   <> TEMP.PRECOATU  THEN TEMP.PRECOATU  ELSE SB1.B1_PRV1   END "
	cUPDATE += ", B1_PESO   = CASE WHEN SB1.B1_PESO   <> TEMP.PESOATU   THEN TEMP.PESOATU   ELSE SB1.B1_PESO   END "
	cUPDATE += ", B1_CRICOD = CASE WHEN SB1.B1_CRICOD <> TEMP.CRICODATU THEN TEMP.CRICODATU ELSE SB1.B1_CRICOD END "
	cUPDATE += ", B1_POSIPI = CASE WHEN SB1.B1_POSIPI <> TEMP.POSIPIATU THEN TEMP.POSIPIATU ELSE SB1.B1_POSIPI END "
	cUPDATE += ", B1_REMANE = CASE WHEN SB1.B1_REMANE <> TEMP.REMANEATU THEN TEMP.REMANEATU ELSE SB1.B1_REMANE END "
	cUPDATE += ", B1_DTREFP1 = '" + DtoS(dDataBase) + "' " // Data de referência do preço
	If(nMV_PAR05==1)
		cUPDATE += ", B1_GRUDES = CASE WHEN SB1.B1_GRUDES <> TEMP.GRUDESATU THEN TEMP.GRUDESATU ELSE SB1.B1_GRUDES END "
	EndIf
	If !Empty(cMoedaSel)
		cUPDATE += ", B1_MOEDA = CASE WHEN SB1.B1_MOEDA <> "+cMoedaSel+" THEN "+cMoedaSel+" ELSE SB1.B1_MOEDA END "
	endif
	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// WHERE - campos para validar se foram alterados para realizar o UPDATE ( todos os bancos são iguais )              //
	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	cWHERE := " ("
	cWHERE += "    SB1.B1_PRV1   <> TEMP.PRECOATU  "
	cWHERE += " OR SB1.B1_PESO   <> TEMP.PESOATU   "
	cWHERE += " OR SB1.B1_CRICOD <> TEMP.CRICODATU "
	cWHERE += " OR SB1.B1_REMANE <> TEMP.REMANEATU "
	If(nMV_PAR05==1)
		cWHERE += " OR SB1.B1_GRUDES <> TEMP.GRUDESATU "
	EndIf
	If !Empty(cMoedaSel)
		cWHERE += " OR SB1.B1_MOEDA <> "+cMoedaSel
	endif		
	cWHERE += " )"
	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


	if TCGetDB() == "ORACLE"
		cQuery := "MERGE INTO " + RetSqlName("SB1") + " SB1 "
		cQuery += "USING " + oTabParts:TableNameParts() + " TEMP "
		cQuery += "ON (TEMP.PRODUTO = SB1.B1_COD AND DATAIMP = '" + DtoS(dDataBase) + "') "
		cQuery += "WHEN MATCHED THEN "
		cQuery += "UPDATE SET "
		cQuery += cUPDATE // Campos do UPDATE
		cQuery += " WHERE "
		cQuery += "  SB1.B1_FILIAL = '" + xFilial("SB1") + "' AND "
		cQuery += "  SB1.D_E_L_E_T_ = ' ' AND "
		cQuery += cWHERE // WHERE para UPDATE
	elseif TCGetDB() == "POSTGRES"
		cQuery := "UPDATE " + RetSqlName("SB1") + " AS SB1 "
		cQuery += "SET "
		cQuery += cUPDATE // Campos do UPDATE
		cQuery += " FROM " + oTabParts:TableNameParts() + " AS TEMP "
		cQuery += " WHERE "
 		cQuery += "  TEMP.PRODUTO = SB1.B1_COD AND "
		cQuery += "  TEMP.DATAIMP = '" + DtoS(dDataBase) + "' AND "
		cQuery += "  SB1.B1_FILIAL = '" + xFilial("SB1") + "' AND "
		cQuery += "  SB1.D_E_L_E_T_ = ' ' AND "
		cQuery += cWHERE // WHERE para UPDATE
	else
		cQuery := "UPDATE " + RetSqlName("SB1") + " SET "
		cQuery += cUPDATE // Campos do UPDATE
		cQuery += " FROM " + RetSqlName("SB1") + " SB1 "
		cQuery += " JOIN " + oTabParts:TableNameParts() + " TEMP ON TEMP.PRODUTO = SB1.B1_COD AND DATAIMP = '" + DtoS(dDataBase) + "'"
		cQuery += " WHERE "
		cQuery += "  SB1.B1_FILIAL = '" + xFilial("SB1") + "' AND "
		cQuery += "  SB1.D_E_L_E_T_ = ' ' AND "
		cQuery += cWHERE // WHERE para UPDATE
	endif

	OFNJD010075_GeraLogExecQuery(cQuery)

Return

/*/{Protheus.doc} OFNJD010065_AlteraItensSB5
	Função que faz a alteração dos itens na tabela SB5
	@type function
	@version 1.0
	@author Renato Vinicius
	@since 14/11/2024
/*/
Static Function OFNJD010065_AlteraItensSB5()

	Local oTabParts := DMS_PartsInfo():New()
	Local cQuery    := ""

	if TCGetDB() == "ORACLE"
		cQuery += "MERGE INTO " + RetSqlName("SB5") + " SB5 "
		cQuery += " USING "+oTabParts:TableNameParts()+" TEMP "
		//cQuery += " ON (TEMP.FILIAL = SB5.B5_FILIAL AND TEMP.PRODUTO = SB5.B5_COD) "
		cQuery += " ON (TEMP.PRODUTO = SB5.B5_COD AND TEMP.DATAIMP = '" + DtoS(dDataBase) + "') "
		cQuery += " WHEN MATCHED THEN "
		cQuery += " UPDATE SET  "
		cQuery += "     B5_PRV2 = CASE WHEN SB5.B5_PRV2 <> TEMP.PRECOATU2 THEN TEMP.PRECOATU2 ELSE SB5.B5_PRV2 END, "
		cQuery += "     B5_PRV3 = CASE WHEN SB5.B5_PRV3 <> TEMP.PRECOATU3 THEN TEMP.PRECOATU3 ELSE SB5.B5_PRV3 END, "
		cQuery += "     B5_PRV4 = CASE WHEN SB5.B5_PRV4 <> TEMP.PRECOATU4 THEN TEMP.PRECOATU4 ELSE SB5.B5_PRV4 END, "
		cQuery += "     B5_PRV5 = CASE WHEN SB5.B5_PRV5 <> TEMP.PRECOATU5 THEN TEMP.PRECOATU5 ELSE SB5.B5_PRV5 END, "
		cQuery += "     B5_PRV6 = CASE WHEN SB5.B5_PRV6 <> TEMP.PRECOATU6 THEN TEMP.PRECOATU6 ELSE SB5.B5_PRV6 END "
		cQuery += " WHERE "
		cQuery += "  SB5.B5_FILIAL = '" + xFilial("SB5") + "' AND "
		cQuery += "  SB5.D_E_L_E_T_ = ' ' AND "
		cQuery += "  ("
		cQuery += "     SB5.B5_PRV2 <> TEMP.PRECOATU2 OR "
		cQuery += "     SB5.B5_PRV3 <> TEMP.PRECOATU3 OR "
		cQuery += "     SB5.B5_PRV4 <> TEMP.PRECOATU4 OR "
		cQuery += "     SB5.B5_PRV5 <> TEMP.PRECOATU5 OR "
		cQuery += "     SB5.B5_PRV6 <> TEMP.PRECOATU6 "
		cQuery += "  )"
	elseif TCGetDB() == "POSTGRES"
		cQuery := "UPDATE " + RetSqlName("SB5") + " AS SB5 "
		cQuery += " SET "
		cQuery +=       " B5_PRV2 = CASE WHEN SB5.B5_PRV2 <> TEMP.PRECOATU2 THEN TEMP.PRECOATU2 ELSE SB5.B5_PRV2 END,"
		cQuery +=       " B5_PRV3 = CASE WHEN SB5.B5_PRV3 <> TEMP.PRECOATU3 THEN TEMP.PRECOATU3 ELSE SB5.B5_PRV3 END,"
		cQuery +=       " B5_PRV4 = CASE WHEN SB5.B5_PRV4 <> TEMP.PRECOATU4 THEN TEMP.PRECOATU4 ELSE SB5.B5_PRV4 END,"
		cQuery +=       " B5_PRV5 = CASE WHEN SB5.B5_PRV5 <> TEMP.PRECOATU5 THEN TEMP.PRECOATU5 ELSE SB5.B5_PRV5 END,"
		cQuery +=       " B5_PRV6 = CASE WHEN SB5.B5_PRV6 <> TEMP.PRECOATU6 THEN TEMP.PRECOATU6 ELSE SB5.B5_PRV6 END "
		cQuery += "   FROM " + oTabParts:TableNameParts() + " AS TEMP"
		//cQuery += "   JOIN " + oTabParts:TableNameParts() + " TEMP ON TEMP.FILIAL = SB5.B5_FILIAL AND TEMP.PRODUTO = SB5.B5_COD "
		cQuery += " WHERE "
		cQuery += "  TEMP.PRODUTO = SB5.B5_COD AND "
		cQuery += "  TEMP.DATAIMP = '" + DtoS(dDataBase) + "' AND "
		cQuery += "  SB5.B5_FILIAL = '" + xFilial("SB5") + "' AND "
		cQuery += "  SB5.D_E_L_E_T_ = ' ' AND "
		cQuery += "  ("
		cQuery += "       SB5.B5_PRV2 <> TEMP.PRECOATU2 
		cQuery += "    OR SB5.B5_PRV3 <> TEMP.PRECOATU3 "
		cQuery += "    OR SB5.B5_PRV4 <> TEMP.PRECOATU4 "
		cQuery += "    OR SB5.B5_PRV5 <> TEMP.PRECOATU5 "
		cQuery += "    OR SB5.B5_PRV6 <> TEMP.PRECOATU6 "
		cQuery += " )"

	else
		cQuery += "UPDATE " + RetSqlName("SB5") + " SET "
		cQuery +=       " B5_PRV2 = CASE WHEN SB5.B5_PRV2 <> TEMP.PRECOATU2 THEN TEMP.PRECOATU2 ELSE SB5.B5_PRV2 END,"
		cQuery +=       " B5_PRV3 = CASE WHEN SB5.B5_PRV3 <> TEMP.PRECOATU3 THEN TEMP.PRECOATU3 ELSE SB5.B5_PRV3 END,"
		cQuery +=       " B5_PRV4 = CASE WHEN SB5.B5_PRV4 <> TEMP.PRECOATU4 THEN TEMP.PRECOATU4 ELSE SB5.B5_PRV4 END,"
		cQuery +=       " B5_PRV5 = CASE WHEN SB5.B5_PRV5 <> TEMP.PRECOATU5 THEN TEMP.PRECOATU5 ELSE SB5.B5_PRV5 END,"
		cQuery +=       " B5_PRV6 = CASE WHEN SB5.B5_PRV6 <> TEMP.PRECOATU6 THEN TEMP.PRECOATU6 ELSE SB5.B5_PRV6 END "
		cQuery += "   FROM " + RetSqlName("SB5") + " SB5 "
		//cQuery += "   JOIN " + oTabParts:TableNameParts() + " TEMP ON TEMP.FILIAL = SB5.B5_FILIAL AND TEMP.PRODUTO = SB5.B5_COD "
		cQuery += "   JOIN " + oTabParts:TableNameParts() + " TEMP ON TEMP.PRODUTO = SB5.B5_COD AND TEMP.DATAIMP = '" + DtoS(dDataBase) + "' "
		cQuery += " WHERE "
		cQuery += "  SB5.B5_FILIAL = '" + xFilial("SB5") + "' AND "
		cQuery += "  SB5.D_E_L_E_T_ = ' ' AND "
		cQuery += "  ("
		cQuery += "       SB5.B5_PRV2 <> TEMP.PRECOATU2 
		cQuery += "    OR SB5.B5_PRV3 <> TEMP.PRECOATU3 "
		cQuery += "    OR SB5.B5_PRV4 <> TEMP.PRECOATU4 "
		cQuery += "    OR SB5.B5_PRV5 <> TEMP.PRECOATU5 "
		cQuery += "    OR SB5.B5_PRV6 <> TEMP.PRECOATU6 "
		cQuery += " )"
	endif


	//oLogger:Log({'TIMESTAMP', "                                            " + cQuery})

	OFNJD010075_GeraLogExecQuery(cQuery)

Return

/*/{Protheus.doc} OFNJD010075_GeraLogExecQuery
	Função que faz a alteração dos itens novos na tabela SBZ
	@type function
	@version 1.0
	@author Renato Vinicius
	@since 14/11/2024
/*/
Static Function OFNJD010075_GeraLogExecQuery(cQuery)

	Default cQuery := ""

	if cTCGetDB == "ORACLE"
		cQuery := StrTran(cQuery, "''", "' '")
	endif

	If !Empty(cQuery) .and. TcsqlExec(cQuery) < 0
		if !lSchedule
			ALERT(TCSQLError())
			oLogger:Log({'TIMESTAMP', "OFINJD01 - Erro ao executar a query: " + cQuery})
		EndIf
	EndIf

Return

static function ReplaceMultibyte(cStr)
    LOCAL cResult := ""
    LOCAL nLen := LEN(cStr)
    LOCAL i := 1

    DO WHILE i <= nLen
        // Pega o byte atual
        nByte := ASC(SUBSTR(cStr, i, 1))

        // Verifica se é um caractere multibyte (UTF-8)
        IF nByte >= 128
            // Se for multibyte, substitui por um espaço e pula o byte extra
            cResult += " "
            i++
        ELSE 
            // Se for ASCII, mantém o caractere
            cResult += CHR(nByte)
        ENDIF
        i++
    ENDDO
RETURN cResult

static function estimativa(cTime, nProcessados, nTotalRegs)
	Local nSegundos := 0
	Local nTempoTotalSeg := 0
	Local nHoras := 0
	Local nMinutos := 0
	Local nSegundosRest := 0
	Local cEstimado := ""

	// Converte o tempo atual para segundos
	nSegundos := Val(SubStr(cTime,1,2)) * 3600 + ;
					Val(SubStr(cTime,4,2)) * 60 + ;
					Val(SubStr(cTime,7,2))

	// Calcula o tempo total em segundos
	nTempoTotalSeg := (nSegundos * nTotalRegs) / nProcessados

	// Converte para horas, minutos e segundos
	nHoras := Int(nTempoTotalSeg / 3600)
	nTempoTotalSeg := nTempoTotalSeg - (nHoras * 3600) // remove horas
	nMinutos := Int((nTempoTotalSeg) / 60)
	nTempoTotalSeg := nTempoTotalSeg - (nMinutos * 60) // remove minutos
	nSegundosRest := nTempoTotalSeg // segundos restantes

	// Formata o resultado (sem limitar as horas a 2 dígitos)
	cEstimado := AllTrim(Str(nHoras)) + ":" + ;
					StrZero(nMinutos,2) + ":" + ;
					StrZero(nSegundosRest,2)
Return cEstimado

static function doImp(aLote, nProcessados, nTotalRegs, jArqAnt, jDadosPPP, oPIFile, lHasPrevImp)
	local nX := 1
	local cStr := ""
	local cDescription
	local nPackageQuantity
	local nNetPrice
	local nListPrice
	local nCoreXNetPrice
	local nCoreXListPrice
	local nRetCredNetPrice
	local nRetCredListPrice
	local cRetIndicator
	local cCritCode
	local cTariffCode
	local cPricedPerIndicator
	local nShipWeight
	
	Local lPEOFNJD01 := ExistBlock('OFNJD01')
	local lFaz
	local nQtdPrcR := 0
	
	Local oTabParts := DMS_PartsInfo():New()
	Local cSQL
	Local lVE5_GDESFB := VE5->(FieldPos("VE5_GDESFB")) <> 0
	Local cGruDes := " "
	Local cUltConteudo := ""

	local cTNameParts := oTabParts:TableNameParts()
	local cAuxDataBase := DtoS(dDataBase)

    Private cPartNumber

	// Verificação de Código de Grupo de Desconto da Fábrica

	for nX := 1 to len(aLote)
		cStr := aLote[nX]

		If lVE5_GDESFB
			cSQL := "SELECT VE5_GRUDST "
			cSQL += "FROM " + RetSQLName("VE5") + " "
			cSQL += "WHERE VE5_FILIAL = '" + xFilial("VE5") + "' "
			cSQL += "  AND VE5_CODMAR = '" + MV_PAR02 + "' "
			cSQL += "  AND VE5_GDESFB = '" + Subs(cStr,239,3) + "' "
			cSQL += "  AND D_E_L_E_T_ = ' '"
			cGruDes := FM_SQL(cSQL)
		EndIf

		cPartNumber := ALLTRIM(UPPER(Subs(cStr,1,18)))

		cUltConteudo := jArqAnt[cPartNumber]
		if ! Empty(cUltConteudo) .and. alltrim(cUltConteudo) == alltrim(cStr)
			loop // se o conteudo atual for igual o anterior ignora a linha
		endif

		lFaz := IIf(lPEOFNJD01,ExecBlock("OFNJD01",.f.,.f., {cPartNumber}),.T.)
		if ! lFaz
			loop
		endif

		cDescription         = StrTran(alltrim(UPPER(Subs(cStr,25,27))), "'", "")
		nPackageQuantity     = val(Subs(cStr,52,5))
		nNetPrice            = val(Subs(cStr,57,16))
		nListPrice           = val(Subs(cStr,73,16))
		nCoreXNetPrice       = val(Subs(cStr,89,16))
		nCoreXListPrice      = val(Subs(cStr,105,16))
		nRetCredNetPrice     = val(Subs(cStr,121,16))
		nRetCredListPrice    = val(Subs(cStr,137,16))
		cRetIndicator        = Iif(Subs(cStr,153,1)=="R","1","0")
		cCritCode            = Subs(cStr,154,2)
		cTariffCode          = Subs(cStr,222,10)
		cPricedPerIndicator  = Subs(cStr,163,1)
		nShipWeight          = val(Subs(cStr,164,10))

		// o json jDadosPPP ja tem somente as pecas
		// que precisa converter direto, todos os filtros estão na query
		// então aqui podemos fazer direto a conversão
		if ! empty(jDadosPPP[cPartNumber])
			nListPrice := nListPrice / jDadosPPP[cPartNumber]
		endif

		// CORRECAO DE PRECO
		if cPricedPerIndicator == "C"
			nNetPrice         := nNetPrice         / 100
			nListPrice        := nListPrice        / 100
			nCoreXNetPrice    := nCoreXNetPrice    / 100
			nCoreXListPrice   := nCoreXListPrice   / 100
			nRetCredNetPrice  := nRetCredNetPrice  / 100
			nRetCredListPrice := nRetCredListPrice / 100
		endif

		// o  update a seguir serve para caso já exista uma importacao no mesmo dia
		// ele atualize os dados pois não serão inseridos novos registros assim os valores atualizarão
		// deve ser executado antes do insert, pois do contrario vamos inserir e logo apos alterasr o mesmo registro
		if lHasPrevImp

			cSQL := "UPDATE " + cTNameParts + " SET "
			cSQL +=  " PRECOATU  = " + cValToChar(nListPrice) + ", "
			cSQL +=  " PESOATU   = " + cValToChar(nShipWeight) + ", "
			cSQL +=  " CRICODATU = '" + cCritCode + "', "
			cSQL +=  " POSIPIATU = '" + cTariffCode + "', "
			cSQL +=  " REMANEATU = '" + cRetIndicator + "', "
			cSQL +=  " PRECOATU2 = " + cValToChar(nNetPrice) + ", "
			cSQL +=  " PRECOATU3 = " + cValToChar(nCoreXNetPrice) + ", "
			cSQL +=  " PRECOATU4 = " + cValToChar(nCoreXListPrice) + ", "
			cSQL +=  " PRECOATU5 = " + cValToChar(nRetCredNetPrice) + ", "
			cSQL +=  " PRECOATU6 = " + cValToChar(nRetCredListPrice) + " "
			If(nMV_PAR05==1)
				cSQL +=  ", GRUDESATU = '" + cGruDes + "' "
			EndIf
			cSQL += " WHERE DATAIMP = '" + DtoS(dDataBase) + "' "
			cSQL +=  " AND PRODUTO = '" + cPartNumber + "' "

			OFNJD010075_GeraLogExecQuery(cSQL)

		endif

		cSQL := " INSERT INTO "+cTNameParts+" (FILIAL,DATAIMP,DATAGER,PRODUTO,DESCRICAO,PRECOATU,PESOATU,CRICODATU,POSIPIATU,REMANEATU,PRECOATU2,PRECOATU3,PRECOATU4,PRECOATU5,PRECOATU6"
		If(nMV_PAR05==1)
			cSQL += 	",GRUDESATU"
		EndIf
		cSQL += ") "

		cSQL += " SELECT "
		cSQL += 	" ' ', "
		cSQL += 	" '" + cAuxDataBase + "', "
		cSQL += 	" '" + FGX_Timestamp() + "', "
		cSQL += 	" '" + cPartNumber + "', "
		cSQL += 	" '" + cDescription + "', "
		cSQL += 	" " + cValToChar(nListPrice) + ", "
		cSQL += 	" " + cValToChar(nShipWeight) + ", "
		cSQL += 	" '" + cCritCode + "', "
		cSQL += 	" '" + cTariffCode + "', "
		cSQL += 	" '" + cRetIndicator + "', "
		cSQL += 	" " + cValToChar(nNetPrice) + ", "
		cSQL += 	" " + cValToChar(nCoreXNetPrice) + ", "
		cSQL += 	" " + cValToChar(nCoreXListPrice) + ", "
		cSQL += 	" " + cValToChar(nRetCredNetPrice) + ", "
		cSQL += 	" " + cValToChar(nRetCredListPrice) + " "
		If(nMV_PAR05==1)
			cSQL += " , '" + cGruDes+ "' "
		EndIf

		if cTCGetDB == "ORACLE"
			cSQL += " FROM DUAL "
		endif

		cSQL += " WHERE NOT EXISTS ( "
		cSQL += " SELECT 1 "
		cSQL += " FROM " + cTNameParts
		cSQL += " WHERE DATAIMP = '"+ cAuxDataBase +"' "
		cSQL += " AND PRODUTO = '" + cPartNumber + "' "
		cSQL += " ) "

		OFNJD010075_GeraLogExecQuery(cSQL)
		nQtdPrcR += 1

	Next

return nQtdPrcR

/*/{Protheus.doc} OFNJD010085_ItensSB1
	Função que adiciona no vetor aDadosPeca para criação dos itens novos na tabela SB1
	@type function
	@version 1.0
	@author Renato Vinicius
	@since 29/05/2025
/*/

Static Function OFNJD010085_ItensSB1(lInclui)

	Local oTabParts := DMS_PartsInfo():New()
	Local cQuery    := ""
	Local lRemane := .F.
	Local LPEDPRO := .F.
	Local lPEOJD01AGR := ExistBlock('OJD01AGR')
	Local cMoedaSel   := ""
	Local aPecaSB1 := {}

	Default lInclui     := .f.

	If cPaisLoc $ "ARG/MEX"
		cMoedaSel := AllTrim(Str(nMV_PAR06))
	EndIf

	if SB1->(FieldPos("B1_REMANE")) > 0
		lRemane := .T.
	EndIf
	if SB1->(FieldPos("B1_PEDPRO")) > 0
		lPedpro := .T.
	EndIf


	aMarca := aDadosMarca[ ASCAN(aDadosMarca, {|aDt| aDt[IDX4_FILIAL] == cFilAnt }) ]

	cQuery := " SELECT PRODUTO , DESCRICAO , PRECOATU , PESOATU , CRICODATU , POSIPIATU , REMANEATU , GRUDESATU "

	cQuery += " FROM " + oTabParts:TableNameParts()

	If lInclui

		cQuery += " WHERE "
		cQuery += " NOT EXISTS ( SELECT 1 FROM " +RetSqlName("SB1")+ " SB1 WHERE SB1.B1_FILIAL = '" +xFilial("SB1")+ "' AND SB1.B1_COD = " + oTabParts:TableNameParts() + ".PRODUTO and SB1.D_E_L_E_T_ = ' ' ) AND "
		cQuery += "DATAIMP = '" + DtoS(dDataBase) + "' AND "
		cQuery += "PRECOANT  IS NULL AND "
		cQuery += "PESOANT   IS NULL AND "
		cQuery += "CRICODANT IS NULL AND "
		cQuery += "POSIPIANT IS NULL AND "
		cQuery += "REMANEANT IS NULL "
		If(nMV_PAR05==1)
			cQuery += "AND GRUDESANT IS NULL "
		EndIf

	Else

		cQuery += " TEMP "
		cQuery += " JOIN " + RetSqlName("SB1") + " SB1 ON TEMP.PRODUTO = SB1.B1_COD AND DATAIMP = '" + DtoS(dDataBase) + "'"

		cQuery += " WHERE "
		cQuery += "  SB1.B1_FILIAL = '" + xFilial("SB1") + "' AND "
		cQuery += "  SB1.D_E_L_E_T_ = ' ' AND "
		cQuery += " ("
		cQuery += "    SB1.B1_PRV1   <> TEMP.PRECOATU  "
		cQuery += " OR SB1.B1_PESO   <> TEMP.PESOATU   "
		cQuery += " OR SB1.B1_CRICOD <> TEMP.CRICODATU "
		cQuery += " OR SB1.B1_REMANE <> TEMP.REMANEATU "
		If(nMV_PAR05==1)
			cQuery += " OR SB1.B1_GRUDES <> TEMP.GRUDESATU "
		EndIf
		If !Empty(cMoedaSel)
			cQuery += " OR SB1.B1_MOEDA <> "+cMoedaSel
		endif		
		cQuery += " )"

	EndIf

	TcQuery cQuery New Alias "TMPB1"

	While !TMPB1->(Eof())

		aDadosPeca := {;
			{'B1_FILIAL'  , xFilial("SB1")                   , .T.                       , .T. },;
			{'B1_COD'     , TMPB1->PRODUTO                   , .T.                       , .T. },;
			{'B1_PESO'    , TMPB1->PESOATU                   , .F.                       , .F. },;
			{'B1_CRICOD'  , TMPB1->CRICODATU                 , .F.                       , .F. },;
			{'B1_DESC'    , TMPB1->DESCRICAO                 , IIf(nMV_PAR04==1,.F.,.T.) , .F. },;
			{'B1_PRV1'    , TMPB1->PRECOATU                  , .F.                       , .F. },;
			{'B1_UREV'    , ddatabase                        , .F.                       , .F. },;
			{'B1_DTREFP1' , ddatabase                        , .F.                       , .F. },;
			{'B1_POSIPI'  , TMPB1->POSIPIATU                 , .F.                       , .F. },;
			{'B1_CODITE'  , TMPB1->PRODUTO                   , .T.                       , .F. },;
			{'B1_CODFAB'  , TMPB1->PRODUTO                   , .T.                       , .F. },;
			{'B1_PERINV'  , 180                              , .T.                       , .F. },;
			{'B1_IPI'     , 0                                , .T.                       , .F. },;
			{'B1_PICMENT' , 0                                , .T.                       , .F. },;
			{'B1_FLAGSUG' , "1"                              , .T.                       , .F. },;
			{'B1_CLASSVE' , "1"                              , .T.                       , .F. },;
			{'B1_ANUENTE' , "2"                              , .T.                       , .F. },;
			{'B1_MSBLQL'  , "2"                              , .T.                       , .F. },;
			{'B1_BALANCA' , "0"                              , .T.                       , .F. },;
			{'B1_ENVOBR'  , "0"                              , .T.                       , .F. },;
			{'B1_LOCALIZ' , "N"                              , .T.                       , .F. },;
			{'B1_CONTSOC' , "N"                              , .T.                       , .F. },;
			{'B1_SITPROD' , "N"                              , .T.                       , .F. },;
			{'B1_MONO'    , "N"                              , .T.                       , .F. },;
			{'B1_FANTASM' , "N"                              , .T.                       , .F. },;
			{'B1_TIPODEC' , "N"                              , .T.                       , .F. },;
			{'B1_CONTRAT' , "N"                              , .T.                       , .F. },;
			{'B1_IRRF'    , "N"                              , .T.                       , .F. },;
			{'B1_GRADE'   , "N"                              , .T.                       , .F. },;
			{'B1_IMPZFRC' , "N"                              , .T.                       , .F. },;
			{'B1_TIPOCQ'  , "M"                              , .T.                       , .F. },;
			{'B1_APROPRI' , "D"                              , .T.                       , .F. },;
			{'B1_TIPO'    , "ME"                             , .T.                       , .F. },;
			{'B1_SEGUM'   , "PC"                             , .T.                       , .F. },;
			{'B1_UM'      , "PC"                             , .T.                       , .F. },;
			{'B1_ATIVO'   , "S"                              , .T.                       , .F. },;
			{'B1_PIS'     , "S"                              , .T.                       , .F. },;
			{'B1_COFINS'  , "S"                              , .T.                       , .F. },;
			{'B1_ORIGEM'  , " "                              , .T.                       , .F. },;
			{'B1_GRUDES'  , TMPB1->GRUDESATU                 , IIf(nMV_PAR05==1,.F.,.T.) , .F. },;
			{'B1_CLASSE'  , " "                              , .T.                       , .F. },;
			{'B1_GRUPO'   , aMarca[IDX4_GRUITE]              , .T.                       , .F. },;
			{'B1_LOCPAD'  , aMarca[IDX4_ALMOXA]              , .T.                       , .F. },;
			{'B1_FABRIC'  , aMarca[IDX4_FABRIC]              , .T.                       , .F. },;
			{'B1_LOJPROC' , aMarca[IDX4_LOJFOR]              , .T.                       , .F. },;
			{'B1_FORAEST' , aMarca[IDX4_FESTCO]              , .T.                       , .F. },;
			{'B1_CONTA'   , aMarca[IDX4_CTACTB]              , .T.                       , .F. },;
			{'B1_CC'      , aMarca[IDX4_CENCUS]              , .T.                       , .F. },;
			{'B1_PROC'    , aMarca[IDX4_FORNEC]              , .T.                       , .F. },;
			{'B1_TS'      , aMarca[IDX4_TESSAI]              , .T.                       , .F. },;
			{'B1_TE'      , aMarca[IDX4_TESENT]              , .T.                       , .F. } ;
		}

		if lRemane
			AADD(aDadosPeca, {'B1_REMANE'  , TMPB1->REMANEATU , .F. , .F. })
		endIF
		if lPedpro
			AADD(aDadosPeca, {'B1_PEDPRO'  , "1"           , .T. , .F. })
		endIF

		If cPaisLoc $ "ARG/MEX"
			AADD(aDadosPeca, {'B1_MOEDA'  , Val(AllTrim(Str(nMV_PAR06))) , .F. , .F. })
		endif

		If lPEOJD01AGR
			ExecBlock("OJD01AGR",.f.,.f., {"SB1"})
		EndIf

		aAdd(aPecaSB1,aClone(aDadosPeca))

		TMPB1->(DbSkip())

	End

	TMPB1->(DbCloseArea())

Return aPecaSB1

/*/{Protheus.doc} OFNJD010095_ItensSB5
	Função que faz a alteração dos itens novos na tabela SB5
	@type function
	@version 1.0
	@author Renato Vinicius
	@since 29/05/2025
/*/

Static Function OFNJD010095_ItensSB5(lInclui)

	Local oTabParts := DMS_PartsInfo():New()
	Local cQuery    := ""
	Local lPEOJD01AGR := ExistBlock('OJD01AGR')

	Default lInclui   := .f.

	aPecaSB5 := {}

	cQuery += " SELECT PRODUTO,CASE WHEN PRECOATU2 IS NULL THEN 0 ELSE PRECOATU2 END AS PRECOATU2,CASE WHEN PRECOATU3 IS NULL THEN 0 ELSE PRECOATU3 END AS PRECOATU3,CASE WHEN PRECOATU4 IS NULL THEN 0 ELSE PRECOATU4 END AS PRECOATU4,CASE WHEN PRECOATU5 IS NULL THEN 0 ELSE PRECOATU5 END AS PRECOATU5,CASE WHEN PRECOATU6 IS NULL THEN 0 ELSE PRECOATU6 END AS PRECOATU6
	cQuery += " FROM " + oTabParts:TableNameParts()

	If lInclui

		cQuery += " WHERE "
		cQuery += " NOT EXISTS ( SELECT 1 FROM " + RetSqlName("SB5")+ " SB5 WHERE SB5.B5_FILIAL = '" +xFilial("SB5")+ "' AND SB5.B5_COD = " + oTabParts:TableNameParts() + ".PRODUTO and SB5.D_E_L_E_T_ = ' ' ) AND "
		cQuery += "DATAIMP = '" + DtoS(dDataBase) + "' AND "
		cQuery += "PRECOANT2 IS NULL AND "
		cQuery += "PRECOANT3 IS NULL AND "
		cQuery += "PRECOANT4 IS NULL AND "
		cQuery += "PRECOANT5 IS NULL AND "
		cQuery += "PRECOANT6 IS NULL  "

	Else
		cQuery += " TEMP "
		cQuery += "   JOIN " + RetSQLName("SB5") + " SB5 ON TEMP.PRODUTO = SB5.B5_COD AND TEMP.DATAIMP = '" + DtoS(dDataBase) + "' "
		cQuery += " WHERE "
		cQuery += "  SB5.B5_FILIAL = '" + xFilial("SB5") + "' AND "
		cQuery += "  SB5.D_E_L_E_T_ = ' ' AND "
		cQuery += "  ("
		cQuery += "       SB5.B5_PRV2 <> TEMP.PRECOATU2 
		cQuery += "    OR SB5.B5_PRV3 <> TEMP.PRECOATU3 "
		cQuery += "    OR SB5.B5_PRV4 <> TEMP.PRECOATU4 "
		cQuery += "    OR SB5.B5_PRV5 <> TEMP.PRECOATU5 "
		cQuery += "    OR SB5.B5_PRV6 <> TEMP.PRECOATU6 "
		cQuery += " )"
	EndIf

	TcQuery cQuery New Alias "TMPB5"

	While !TMPB5->(Eof())

		aDadosAdPeca := {;
			{'B5_FILIAL'  , xFilial("SB5")           , .T. , .T. },;
			{'B5_COD'     , TMPB5->PRODUTO           , .T. , .T. },;
			{'B5_PRV2'    , TMPB5->PRECOATU2         , .F. , .F. },;
			{'B5_PRV3'    , TMPB5->PRECOATU3         , .F. , .F. },;
			{'B5_PRV4'    , TMPB5->PRECOATU4         , .F. , .F. },;
			{'B5_PRV5'    , TMPB5->PRECOATU5         , .F. , .F. },;
			{'B5_PRV6'    , TMPB5->PRECOATU6         , .F. , .F. },;
			{'B5_DTREFP2' , dDataBase                , .F. , .F. },;
			{'B5_DTREFP3' , dDataBase                , .F. , .F. } ;
		}

		If lPEOJD01AGR
			ExecBlock("OJD01AGR",.f.,.f., {"SB5"})
		EndIf

		aAdd(aPecaSB5,aClone(aDadosAdPeca))

		TMPB5->(DbSkip())

	End

	TMPB5->(DbCloseArea())

Return aPecaSB5
