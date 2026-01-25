#Include "Totvs.ch"  
#Include "WMSDTCEstruturaFisica.ch"
//---------------------------------------------
/*/{Protheus.doc} WMSCLS0021
Função para permitir que a classe seja visualizada
no inspetor de objetos 
@author Inovação WMS
@since 16/12/2016
@version 1.0
/*/
//---------------------------------------------
Function WMSCLS0021()
Return Nil
//-----------------------------------------
/*/{Protheus.doc} WMSDTCEstruturaFisica
Classe estrutura física
@author Inovação WMS
@since 16/12/2016
@version 1.0
/*/
//-----------------------------------------
CLASS WMSDTCEstruturaFisica FROM LongNameClass
	// Data
	DATA lHasNrUnit // Utilizado para suavizar o campo DC8_NRUNIT
	DATA cEstFis
	DATA cDesEst
	DATA nLargura
	DATA nAltura
	DATA nCompri
	DATA nCapaci
	DATA nNrUnit
	DATA cStatus
	DATA cTipoEst
	DATA cDesTipEs
	DATA nRecno
	DATA cErro
	// Controle dados anteriores
	DATA cEstFisAnt
	// Method
	METHOD New() CONSTRUCTOR
	METHOD LoadData(nIndex)
	METHOD SetEstFis(cEstFis)
	METHOD SetDesEst(cDesEst)
	METHOD SetLargura(nLargura)
	METHOD SetAltura(nAltura)
	METHOD SetComprim(nCompri)
	METHOD SetCapacid(nCapaci)
	METHOD SetNrUnit(nNrUnit)
	METHOD SetStatus(cStatus)
	METHOD SetTipoEst(cTipoEst)
	METHOD GetEstFis()
	METHOD GetDesEst()
	METHOD GetLargura()
	METHOD GetAltura()
	METHOD GetComprim()
	METHOD GetCapacid()
	METHOD GetNrUnit()
	METHOD GetStatus()
	METHOD GetTipoEst()
	METHOD GetTipoSep()
	METHOD GetDesTpEs() 
	METHOD GetErro()
	METHOD Destroy()
ENDCLASS
//-----------------------------------------
/*/{Protheus.doc} New
Método construtor
@author felipe.m
@since 23/12/2014
@version 1.0
/*/
//-----------------------------------------
METHOD New() CLASS WMSDTCEstruturaFisica
	Self:lHasNrUnit := WmsX312120("DC8","DC8_NRUNIT")
	Self:cEstFis    := PadR("", TamSx3("DC8_CODEST")[1])
	Self:cEstFisAnt := PadR("", Len(Self:cEstFis))
	Self:cDesEst    := PadR("", TamSx3("DC8_DESEST")[1])
	Self:nLargura   := 0
	Self:nAltura    := 0
	Self:nCompri    := 0
	Self:nCapaci    := 0
	Self:nNrUnit    := 0
	Self:cStatus    := "1"
	Self:cTipoEst   := "1"
	Self:cDesTipEs  := ""
	Self:nRecno     := 0
Return

METHOD Destroy() CLASS WMSDTCEstruturaFisica
	//Mantido para compatibilidade
Return Nil
//-----------------------------------------
/*/{Protheus.doc} LoadData
Carregamento dos dados DC8
@author felipe.m
@since 23/12/2014
@version 1.0
@param nIndex, numérico, (Descrição do parâmetro)
/*/
//-----------------------------------------
METHOD LoadData(nIndex) CLASS WMSDTCEstruturaFisica
Local lRet       := .T.
Local lCarrega   := .T.
Local aAreaAnt   := GetArea()
Local aAreaDC8   := DC8->(GetArea())
Local aTamSX3    := {}
Local aBoxDC8    := RetSx3Box(Posicione('SX3',2,'DC8_TPESTR','X3CBox()'),,,1)
Local cQuery     := ""
Local cAliasDC8  := Nil
Local cCmpNrUnit := ""
Local nSeek      := 0
Default nIndex := 1
	Do Case
		Case nIndex == 1 // DC8_FILIAL+DC8_CODEST
			If Empty(Self:cEstFis)
				lRet := .F.
			Else
				If Self:cEstFis == Self:cEstFisAnt
					lCarrega := .F.
				EndIf
			EndIf
		Otherwise
			lRet := .F.
	EndCase	
	If !lRet
		Self:cErro := STR0001 // Dados para busca não foram informados!
	Else
		If lCarrega
			cCmpNrUnit := IIf(Self:lHasNrUnit,"% DC8.DC8_NRUNIT,%","% 0 DC8_NRUNIT,%")
			cAliasDC8  := GetNextAlias()
			Do Case
				Case nIndex == 1
					BeginSql Alias cAliasDC8
						SELECT DC8.DC8_CODEST,
								%Exp:cCmpNrUnit%
								DC8.DC8_DESEST,
								DC8.DC8_LARGUR,
								DC8.DC8_ALTURA,
								DC8.DC8_COMPRI,
								DC8.DC8_CAPACI,
								DC8.DC8_STATUS,
								DC8.DC8_TPESTR,
								DC8.R_E_C_N_O_ RECNODC8
						FROM %Table:DC8% DC8
						WHERE DC8.DC8_FILIAL = %xFilial:DC8%
						AND DC8.DC8_CODEST = %Exp:Self:cEstFis%
						AND DC8.%NotDel%
					EndSql
			EndCase
			aTamSX3 := TamSx3("DC8_LARGUR"); TCSetField(cAliasDC8,'DC8_LARGUR','N',aTamSX3[1],aTamSX3[2])
			aTamSX3 := TamSx3("DC8_ALTURA"); TCSetField(cAliasDC8,'DC8_ALTURA','N',aTamSX3[1],aTamSX3[2])
			aTamSX3 := TamSx3("DC8_COMPRI"); TCSetField(cAliasDC8,'DC8_COMPRI','N',aTamSX3[1],aTamSX3[2])
			aTamSX3 := TamSx3("DC8_CAPACI"); TCSetField(cAliasDC8,'DC8_CAPACI','N',aTamSX3[1],aTamSX3[2])
			aTamSX3 := IIf(Self:lHasNrUnit,TamSx3('DC8_NRUNIT'),{1,0}); TcSetField(cAliasDC8,'DC8_NRUNIT','N',aTamSX3[1],aTamSX3[2])
			If (lRet := (cAliasDC8)->(!Eof()))
				Self:cEstFis   := (cAliasDC8)->DC8_CODEST
				Self:cDesEst   := (cAliasDC8)->DC8_DESEST
				Self:nLargura  := (cAliasDC8)->DC8_LARGUR
				Self:nAltura   := (cAliasDC8)->DC8_ALTURA
				Self:nCompri   := (cAliasDC8)->DC8_COMPRI
				Self:nCapaci   := (cAliasDC8)->DC8_CAPACI
				Self:nNrUnit   := (cAliasDC8)->DC8_NRUNIT
				Self:cStatus   := (cAliasDC8)->DC8_STATUS
				Self:cTipoEst  := (cAliasDC8)->DC8_TPESTR
				Self:cDesTipEs := IIf ((nSeek := Ascan(aBoxDC8, { |x| x[ 2 ] == Self:cTipoEst})) > 0,AllTrim(aBoxDC8[nSeek,3]),"")
				Self:nRecno   := (cAliasDC8)->RECNODC8
				// Controle dados anteriores
				Self:cEstFisAnt := Self:cEstFis
			EndIf
			(cAliasDC8)->(dbCloseArea())
		EndIf
	EndIf
	RestArea(aAreaDC8)
	RestArea(aAreaAnt)
Return lRet
//-----------------------------------
// Setters
//-----------------------------------
METHOD SetEstFis(cEstFis) CLASS WMSDTCEstruturaFisica
	Self:cEstFis := PadR(cEstFis, Len(Self:cEstFis))
Return

METHOD SetDesEst(cDesEst) CLASS WMSDTCEstruturaFisica
	Self:cDesEst := PadR(cDesEst, Len(Self:cDesEst))
Return

METHOD SetLargura(nLargura) CLASS WMSDTCEstruturaFisica
	Self:nLargura := nLargura
Return

METHOD SetAltura(nAltura) CLASS WMSDTCEstruturaFisica
	Self:nAltura := nAltura
Return

METHOD SetComprim(nCompri) CLASS WMSDTCEstruturaFisica
	Self:nCompri := nCompri
Return

METHOD SetCapacid(nCapaci) CLASS WMSDTCEstruturaFisica
	Self:nCapaci := nCapaci
Return

METHOD SetNrUnit(nNrUnit) CLASS WMSDTCEstruturaFisica
	Self:nNrUnit := nNrUnit
Return

METHOD SetStatus(cStatus) CLASS WMSDTCEstruturaFisica
	Self:cStatus := PadR(cStatus, Len(Self:cStatus))
Return

METHOD SetTipoEst(cTipoEst) CLASS WMSDTCEstruturaFisica
	Self:cTipoEst := PadR(cTipoEst, Len(Self:cTipoEst))
Return
//-----------------------------------
// Getters
//-----------------------------------
METHOD GetEstFis() CLASS WMSDTCEstruturaFisica
Return Self:cEstFis

METHOD GetDesEst() CLASS WMSDTCEstruturaFisica
Return Self:cDesEst

METHOD GetLargura() CLASS WMSDTCEstruturaFisica
Return Self:nLargura

METHOD GetAltura()  CLASS WMSDTCEstruturaFisica
Return Self:nAltura

METHOD GetComprim() CLASS WMSDTCEstruturaFisica
Return Self:nCompri

METHOD GetCapacid() CLASS WMSDTCEstruturaFisica
Return Self:nCapaci

METHOD GetNrUnit() CLASS WMSDTCEstruturaFisica
Return Self:nNrUnit

METHOD GetStatus() CLASS WMSDTCEstruturaFisica
Return Self:cStatus

METHOD GetTipoEst() CLASS WMSDTCEstruturaFisica
Return Self:cTipoEst

METHOD GetDesTpEs() CLASS WMSDTCEstruturaFisica
Return Self:cDesTipEs

METHOD GetErro() CLASS WMSDTCEstruturaFisica
Return Self:cErro
