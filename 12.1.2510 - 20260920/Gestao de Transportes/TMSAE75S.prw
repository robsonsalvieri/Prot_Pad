#INCLUDE "Protheus.ch"

Static aThreads := {}

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ TMSAE75S    ³ Autor ³ Daniel Leme        ³ Data ³16/05/2022³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Schedule de EDI Automáticoe								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSAE75S(aVetCGC,nLinha)
Local cCGCDe    := ""
Local cCGCAte   := ""
Local cSemaforo := ""
Local nQtde     := 0

Default aVetCGC := {}
Default nLinha  := 0

If !Empty(aVetCGC) .And. nLinha > 0 .And. nLinha <= Len(aVetCGC)
	RPCSetType(3)	//-- Nao faz consumo de licença
	RPCSetEnv(aVetCGC[nLinha,1],aVetCGC[nLinha,2],Nil,Nil,"TMS")
	
	cSemaforo := "JOBIMPEDI_" + StrZero(nLinha,4)
	While nQtde < 10
		nQtde ++
		If IpcWaitEx(cSemaforo,10000,@cCGCDe,@cCGCAte)
			nQtde := 0
			If cCGCDe == "EXIT"
				Exit
			Else
				mv_par01 := cCGCDe
				mv_par02 := cCGCAte
				mv_par04 := "99999999999999"
				mv_par05 := 2	//-- Não seleciona as NF's
				TMSAE75Prc(,.T.)

				IPCGo("PRINCIPAL",nLinha)
			EndIf
		EndIf
	EndDo
EndIf

Return 

/*
{Protheus.doc} TMSAE75INI
Rotina que inicializa o ambiente por empresa
@type Function
@author Valdemar Roberto Mognon
@since 14/05/2026
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Function TMSAE75INI()

TMSAE75REG()

Return

/*
{Protheus.doc} TMSAE75REG
Rotina que busca os registros e inicia os JOBs
@type Function
@author Valdemar Roberto Mognon
@since 14/05/2026
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Function TMSAE75REG()
Local aCGCPrc    := {}
Local aStatusAut := {}
Local cQuery	 := ""
Local cAliasDE5	 := GetNextAlias()
Local cSemaforo  := ""
Local nQtdRegJOB := SuperGetMV("MV_TMSREDI",,1)
Local nQtdMaxTHR := SuperGetMV("MV_TMSTEDI",,1)
Local nQtdJOB    := 0
Local nCntFor1   := 0
Local nLinLivre  := 0
Local oObjDE5

//-- Mapa do vetor aCGCPrc
//-- 01 - Empresa
//-- 02 - Filial
//-- 03 - Remetente De
//-- 04 - Remetente Até
//-- 05 - Quantidade de Notas de EDI da faixa de CGCs

Aadd(aStatusAut,' ')
Aadd(aStatusAut,'0')

cQuery := "SELECT DE5_CGCREM,COUNT(DE5_CGCREM) QTDREG "
cQuery +=   "FROM " + RetSqlName("DE5") + " DE5 "
cQuery +=  "WHERE DE5.DE5_FILIAL = ? "
cQuery +=    "AND DE5.DE5_STATUS <> ? "
cQuery +=    "AND DE5.DE5_STAUTO IN(?) "
cQuery +=    "AND DE5.DE5_FILORI = ? "
cQuery +=    "AND DE5.D_E_L_E_T_ = ? "
cQuery +=  "GROUP BY DE5_CGCREM "
cQuery +=  "ORDER BY DE5_CGCREM "
                          
cQuery  := ChangeQuery(cQuery)
oObjDE5 := FwExecStatement():New(cQuery)

oObjDE5:SetString(1,xFilial("DE5"))
oObjDE5:SetString(2,'2')
oObjDE5:SetIn(3,aStatusAut)
oObjDE5:SetString(4,cFilAnt)
oObjDE5:SetString(5,' ')

cAliasDE5 := oObjDE5:OpenAlias()

While (cAliasDE5)->(!Eof())
	If Empty(aCGCPrc) .Or. (aCGCPrc[Len(aCGCPrc),5] + (cAliasDE5)->QTDREG) >= nQtdRegJOB
		Aadd(aCGCPrc,{cEmpAnt,cFilAnt,(cAliasDE5)->DE5_CGCREM,(cAliasDE5)->DE5_CGCREM,(cAliasDE5)->QTDREG})
		nQtdJOB ++
	Else
		aCGCPrc[Len(aCGCPrc),5] := aCGCPrc[Len(aCGCPrc),5] + (cAliasDE5)->QTDREG
	EndIf
	(cAliasDE5)->(DbSkip())
EndDo

(cAliasDE5)->(DbCloseArea())

nQtdJOB := Iif(nQtdJOB > nQtdMaxTHR,nQtdMaxTHR,nQtdJOB)

For nCntFor1 := 1 To nQtdJOB
	cSemaforo := "JOBIMPEDI_" + StrZero(nCntFor1,4)
	Aadd(aThreads,{cSemaforo,.F.})

	StartJob("TMSAE75S",GetEnvServer(),.F.,Aclone(aCGCPrc),nCntFor1)
Next nCntFor1

Sleep(30000)

For nCntFor1 := 1 To Len(aCGCPrc)
	nLinLivre := TMSAE75LIV()

	While nLinLivre == 0
		If IpcWaitEx("PRINCIPAL",10000,@nLinLivre)
			aThreads[nLinLivre,2] := .F.
		EndIf
	EndDo

	If nLinLivre > 0
		cSemaforo := "JOBIMPEDI_" + StrZero(nLinLivre,4)
		aThreads[nLinLivre,2] := .T.
		IPCGo(cSemaforo,aCGCPrc[nCntFor1,3],aCGCPrc[nCntFor1,4])
	EndIf
Next nCntFor1

For nCntFor1 := 1 To nQtdJOB
	cSemaforo := "JOBIMPEDI_" + StrZero(nCntFor1,4)
	IPCGo(cSemaforo,"EXIT")
Next nCntFor1

Return

/*
{Protheus.doc} TMSAE75LIV
Verifica qual thread está livre
@type Function
@author Valdemar Roberto Mognon
@since 17/05/2026
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Function TMSAE75LIV()
Local nRet     := 0
Local nCntFor1 := 0

For nCntFor1 := 1 To Len(aThreads)
	If !aThreads[nCntFor1,2]
		nRet := nCntFor1
		Exit
	EndIf
Next nCntFor1

Return nRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Scheddef    ³ Autor ³ Daniel Leme        ³ Data ³15/05/2022³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Função Schedule  										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function SchedDef()
Local aParam := {}
Local cPerg  := ""

aParam := {"P",;  	//Tipo R para relatorio P para processo   
		   cPerg,;		// Pergunte do relatorio, caso nao use passar ParamDef            
		   "DE5",;  // Alias            
		   ,;   	//Array de ordens   
		   'Schedule - EDI Automático'} //--> Schedule

Return aParam
