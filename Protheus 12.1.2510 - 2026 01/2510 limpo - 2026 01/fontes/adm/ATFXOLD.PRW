#Include "Protheus.Ch"
#Include "AtfxOld.Ch"

Static __lVerKernel := .F.
STATIC cTipoFiscal	:= "01/02/03/04/05/06/07/11/"
STATIC cTipoIncent	:= "08/09"
STATIC cTipoGerenc	:= ""
Static __nQtdMoed
Static __lStruPrj
Static __lStruRat
Static __lAtfCusPrv := NIL
Static aATFMvPar	:= {}
Static __MVCALCDEP  := NIL 

STATIC lIsRussia	:= If(cPaisLoc$"RUS",.T.,.F.) // CAZARINI - Flag to indicate if is Russia location
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณATFXKERNELบAutor  ณTOTVS SA            บ Data ณ  10/08/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina que verifica se o Ativo fixo estแ atualizado corre   บฑฑ
ฑฑบ          ณtamente.                                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function ATFXKERNEL()
Local aAtfFunc := {}
Local lRet		:= .T.

If !__lVerKernel

	aAdd(aAtfFunc,"AF010ATXT")
	aAdd(aAtfFunc,"AF010AAQUI")
	aAdd(aAtfFunc,"AF010ACHV")
	aAdd(aAtfFunc,"AF010ATAXA")
	aAdd(aAtfFunc,"AF010ATIPO")
	aAdd(aAtfFunc,"AF010ADLAT")
	aAdd(aAtfFunc,"AF010AVLDL")
	aAdd(aAtfFunc,"AF010AGRP")
	aAdd(aAtfFunc,"AF010AAT32")
	aAdd(aAtfFunc,"AF010ACHAP")
	aAdd(aAtfFunc,"ATFXVISUAL")
	aAdd(aAtfFunc,"ATFXJACALC")
	aAdd(aAtfFunc,"ATFXPAcols")
	aAdd(aAtfFunc,"AF050DET")
	aAdd(aAtfFunc,"AF050NXMTH")
	aAdd(aAtfFunc,"ATFXSLDCTB")
	aAdd(aAtfFunc,"ATFXBXCIAP")
	aAdd(aAtfFunc,"ATFXGRCIAP")
	aAdd(aAtfFunc,"ATFXMVCIAP")
	aAdd(aAtfFunc,"ATFXRSCIAP")
	aAdd(aAtfFunc,"AF050DET")
	aAdd(aAtfFunc,"AF050NXMTH")
	aAdd(aAtfFunc,"ATFXSLDCTB")
	aAdd(aAtfFunc,"ATFXBXCIAP")
	aAdd(aAtfFunc,"ATFXGRCIAP")
	aAdd(aAtfFunc,"ATFXMVCIAP")
	aAdd(aAtfFunc,"ATFXRSCIAP")
	aAdd(aAtfFunc,"ATFCalcSD")
	aAdd(aAtfFunc,"ATFCalcRS")
	aAdd(aAtfFunc,"ATFCalcVR")
	aAdd(aAtfFunc,"ATFCalcSA")
	aAdd(aAtfFunc,"ATFCalcQC")

	__lVerKernel := lRet
EndIf

lRet := __lVerKernel

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณVerKernel  บAutor  ณTOTVS SA            บ Data ณ  15/10/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida se as fun็ใo do Kernel do M๓dulo estใo Presentes    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function VerKernel()
Local lRet := .F.

lRet := ATFXKERNEL()

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAFXVerRat บAutor  ณMicrosiga           บ Data ณ  02/13/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVerifica se o ambiente estแ preparado para receber          บฑฑ
ฑฑบ          ณa funcionalidade do rateio de movimenta็๕es do Ativo        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AFXVerRat()
Local lRet := .T.

If __lStruRat == Nil
	__lStruRat := .T.
EndIf

lRet := __lStruRat

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAFXAtCsPrv บAutor  ณMauricio Pequim Jr  บ Data ณ  07/05/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVerifica se o ambiente estแ preparado para receber          บฑฑ
ฑฑบ          ณa funcionalidade do filtro de ativos de custo/provisao      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AFXAtCsPrv(lHelp,nValPar)
Local lRet := .F.
Local lContinua := .F.

Default lHelp := .F.
Default nValPar := 2

If __lAtfCusPrv == Nil
	__lAtfCusPrv := Alltrim(SuperGetMV("MV_ATFSPRO",.F.,"1")) == "2"
EndIf

/* Criada trativa para o relat๓rio ATFR050, pois ao selecionar o ๚ltimo pergunte do 
relat๓rio o sistema apresentava o help independente do conte๚do do parโmetro MV_ATFSPRO */

If IsInCallStack("ATFR050")
	lContinua := Alltrim(SuperGetMV("MV_ATFSPRO",.F.,"1")) == "1"
	If lContinua
		lRet := .T.
	EndIf 	
Else
	lRet := __lAtfCusPrv
EndIf

If !lRet .and. lHelp
	If nValPar != 1
		Help(' ',1,"HELP","ATFCUSPRV",STR0001,1,0)	//"Esta pergunta somente terแ efeito caso o parโmetro MV_ATFSPRO estiver igual a <2 (Nใo)>."
	Endif
	lRet := .T.
Endif

Return lRet


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณaf010Textoณ Autor ณ Wagner Xavier         ณ Data ณ 30.03.93 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณRecupera um texto do arquivo de descri”es extendidas       ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณaf010Texto( )                                               ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ Genrico                                                   ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function af010Texto(cChave)
// Movida para o fonte ATFA010a.Prw
If !__lVerKernel
	__lVerKernel := VerKernel()
EndIf
Return AF010ATXT(cChave)

/*/
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณAF010Aquisณ Autor ณ Wagner Xavier         ณ Data ณ 10.01.94 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณVerifica se lei 8.200 e Reavalio  valida.                ณฑฑ
ฑฑณ          ณSomente sero v lidas, se existir aquisio ou adiantamento.ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ ATFA010                                                    ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AF010Aquis( )
// Movida para o fonte ATFA010a.Prw
If !__lVerKernel
	__lVerKernel := VerKernel()
EndIf
Return AF010AAQUI()

/*/
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณAF010Chav ณ Autor ณ Claudinei M. Benzi    ณ Data ณ 28.11.93 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณVerifica se ha' chave duplicada                             ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ ATFA010                                                    ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AF010Chav()
// Movida para o fonte ATFA010a.Prw
If !__lVerKernel
	__lVerKernel := VerKernel()
EndIf
Return AF010ACHV()

/*/
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณ AF010Taxa  ณ Autor ณ Wagner Xavier         ณ Data ณ 20.01.93 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Preenche Taxa depreciao para todas das moedas.             ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ ATFA010                                                      ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Af010Taxa(lGrupo)
// Movida para o fonte ATFA010a.Prw
If !__lVerKernel
	__lVerKernel := VerKernel()
EndIf
Return AF010ATAXA(lGrupo)


/*/
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณ AF010Tipo  ณ Autor ณ Claudinei M. Benzi    ณ Data ณ 22.01.92 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Consiste tipo do bem                                         ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ ATFA010                                                      ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AF010Tipo( cTipo, nLinha, lLinOk )
// Movida para o fonte ATFA010a.Prw
If !__lVerKernel
	__lVerKernel := VerKernel()
EndIf
Return AF010ATIPO( cTipo, nLinha, lLinOk )


/*/
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณ AF010DelAtuณ Autor ณ Alice Y Yamamoto      ณ Data ณ22.01.99  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Atualiza os arquivos apos a exclusao                         ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe e ณ Void AF010AtuArq( )                                          ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ Af010Delet                                                   ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Af010DelAtu(cAlias1, lCprova,lMostra,lContab,aCIAP,aRateio)
// Movida para o fonte ATFA010a.Prw
If !__lVerKernel
	__lVerKernel := VerKernel()
EndIf
Return AF010ADLAT(cAlias1, lCprova,lMostra,lContab,aCIAP, aRateio)

/*/
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณ AF010VldDelณ Autor ณ Alice Y Yamamoto      ณ Data ณ26.01.99  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Verifica se o Ativo pode ser excluido                        ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe e ณ Void AF010Delet() / Mata100 -> Intergracao com compras       ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ Af010Delet ()                                                ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Af010VldDel(cAlias1, lCompra,lHelp)
Default lHelp := .T.
// Movida para o fonte ATFA010a.Prw
If !__lVerKernel
	__lVerKernel := VerKernel()
EndIf
Return AF010AVLDL(cAlias1, lCompra,lHelp)

/*/
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณ AF010Grupo ณ Autor ณ Wagner Mobile Costa   ณ Data ณ 25.03.02 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Preenche entidades contabeis no bem de acordo com grupo [SNG]ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ ATFA010                                                      ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Af010Grupo(cEntidade)
// Movida para o fonte ATFA012.Prw
If !__lVerKernel
	__lVerKernel := VerKernel()
EndIf
Return AF012AGRP(cEntidade)

/*/
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณ Af010Art32 ณ Autor ณ Adilson Soeiro        ณ Data ณ 20.02.10 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Preenche Taxa depreciao para todas das moedas.             ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ Af010Art32                                                   ณฑฑ
ฑฑณ          ณ                                                              ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Af010Art32()
// Movida para o fonte ATFA010a.Prw
If !__lVerKernel
	__lVerKernel := VerKernel()
EndIf
Return AF010AAT32()


/*/
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณaf010Chapaณ Autor ณ Alice Yaeko Yamamoto  ณ Data ณ 30.03.93 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Verifica se a chapa informada ja existe e se pode repetila ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ af010Chapa(cChapa, lRepChapa)                              ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ Criacao Automatica de bens.                                ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
FUNCTION AF010CHAPA(cChapa,lRepChapa)
// Movida para o fonte ATFA010a.Prw
If !__lVerKernel
	__lVerKernel := ATFXKERNEL()
EndIf
RETURN AF010ACHAP(cChapa,lRepChapa)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAjCalcPis บAutor  ณMicrosiga           บ Data ณ  05/06/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAjuste no campo Calc Pis na tabela de movimentos SN4        บฑฑ
ฑฑบ          ณconforme campo Calc Pis (N1_CALCPIS) do Bem                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function Aj_Calc_Pis()
Local cQuery 	:= ""
Local lCCBem 	:= SuperGetMv("MV_ATFCCMV",.F., .T.)  //.T. = Considera Centro Custo Cpo N3_CCUSTO (Padrao) .F. =Considera CC das Movimentacoes (SN4) N4_CCUSTO
Local lPopSN4 	:= SuperGetMv("MV_ATFCSN4",.F., .F.)  //.T. = ja populou tabela SN4 CAMPO N4_CALCPIS .F. =Nao Populado SN4
Local cFilOld := cFilAnt
Local nInc
Local aSM0		:= AdmAbreSM0()

//somente processa se for cc do movim. ativo-sn4 e existe o campo e nao populou o campo ainda (soh deve popular uma unica vez) 
Local lProcessa	:= ! lCCBem .And. ;   //se for cc de movimento SN4
					! lPopSN4 //se nao populou SN4 CAMPO N4_CALCPIS

If lProcessa
	//processa com base no sigamat.emp todas as filiais desta empresa
	For nInc := 1 To Len( aSM0 )
	
		If aSM0[nInc,1] == cEmpAnt
		
			cFilAnt := aSM0[nInc][2]  //seta a filial corrente
			
				cQuery := " UPDATE " + RetSqlName("SN4") + " SET N4_CALCPIS = N1_CALCPIS "
				cQuery += " FROM " + RetSqlName("SN1") 
				//CLAUSULA WHERE SN4
				cQuery += " WHERE N4_FILIAL = '" + xFilial("SN4") + "' "
				cQuery += " AND "+ RetSqlName("SN4") +".D_E_L_E_T_  = ' ' "
				cQuery += " AND N4_CALCPIS  = ' ' "  //somente para os que estao vazio na tabela SN4
				//LINKAR COM SN1
				cQuery += " AND N4_CBASE = N1_CBASE "
				cQuery += " AND N4_ITEM  = N1_ITEM  "
		        //CONDICOES SN1
				cQuery += " AND N1_FILIAL = '" + xFilial("SN1") + "' "
				cQuery += " AND "+ RetSqlName("SN1") +".D_E_L_E_T_  = ' ' "
				cQuery += " AND N1_CALCPIS  != ' ' "    //Somente os que estao preenchidos na tabela SN1
				
				If TcSqlExec(cQuery) != 0
					UserException( TCSqlError() )
				EndIf

				PutMvPar( "MV_ATFCSN4" , .T.)
							
			//se for compartilhado faz uma unica vez
			If Empty(xFilial("SN4"))
				Exit
			EndIf
        EndIf
   Next
EndIf

//restaura a filial corrente
cFilAnt := cFilOld

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ MesAnoAtfณ Autor ณ Cesar C S Prado       ณ Data ณ 09/02/94 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Devolve um campo caracter com o ano e mes de uma data AAMM ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ Generico                                                   ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function MesAnoAtf( dData)
Return StrZero(Year(dData),4)+StrZero(Month(dData),2)

/*/
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ X3Decimal  ณ Autor ณ Cesar C S Prado       ณ Data ณ 29/07/94 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Devolve o numero de decimais de um campo numerico            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ Generico                                                     ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function X3Decimal(cCampo)
Local cAlias   := Alias()
Local nRetorno := 0
dbSelectArea( "SX3" )
dbSetOrder( 2 )
dbSeek( cCampo )
dbSetOrder( 1 )
IF Found( )
	nRetorno := X3_DECIMAL
End
dbSelectArea(cAlias)
Return ( nRetorno )
/*/
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ AtfMeses   ณ Autor ณ Vinicius S Barreira   ณ Data ณ 21/09/94 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Calcula quantos meses existem entre duas datas               ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUtilizacaoณ nMeses := AtfMeses(dInic,dFim,nTipo)                         ณฑฑ
ฑฑณParametrosณ dInic ->  Data Inicial                                       ณฑฑ
ฑฑณ          ณ dFim  ->  Data Final                                         ณฑฑ
ฑฑณ          ณ nTipo ->  1 - Mes Cheio , 2 - Mes Simples                    ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ Generico                                                     ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AtfMeses(dInic,dFim,nTipo)
local nmeses := 0 , dVaraux := ctod("") , Retorno := 0

if ValType(dInic) # "D" .or. ;
    ValType(dFim)  # "D" .or. ;
    ValType(nTipo) # "N"
    return( 0 )
endif

If dInic > dFim  // erro do programador
    return( 0 )
Endif

If nTipo < 1 .or. nTipo > 2
    nTipo := 2  // Valor default para mes simples
Endif

// Este algoritmo pode ser um pouco lento, mas funciona bem.

dVaraux := dFim
While dVaraux >= dInic
    If nMeses # Month(dVaraux)
        nMeses := Month(dVaraux)
        Retorno ++
    endif
    dVaraux --
End

If nTipo == 2  // Mes simples
    If Retorno > 1  // Subtrai uma unidade para compensar os dias
        Retorno --  // excedentes do mes
    Endif
Endif

return( Retorno )


/*/
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ Atfx3      ณ Autor ณ Vinicius S Barreira   ณ Data ณ 21/09/94 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Le a estrutura do arquivo SX3                                ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUtilizacaoณ atfx3(cAlias1,@aHeader)                                      ณฑฑ
ฑฑณParametrosณ alias   - > arquivo que sera' lido do sx3                    ณฑฑ
ฑฑณ          ณ aHeader - > matriz com estrutura do arquivo                  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ Generico                                                     ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
Observacao: variavel nUsado e' private.
*/
Function atfx3( cAlias1 , aHeader, lAuto )

Local nOrdSx3 := SX3->(IndexOrd())
Local cUsado

Default lAuto := .F. // Condi็ใo para criar novos campos no header que sใo tratados somente pela execauto.

dbSelectArea("SX3")
dbSetOrder(1)
SX3->(dbSeek( cAlias1 ))
While ! SX3->(Eof()) .And. (SX3->X3_ARQUIVO == cAlias1)
    IF X3USO(SX3->X3_USADO) .and. cNivel >= SX3->X3_NIVEL
        nUsado++
        AADD(aHeader,{ TRIM(X3Titulo()) ,;
        AllTrim(SX3->X3_CAMPO),;
        SX3->X3_PICTURE ,;
        SX3->X3_TAMANHO ,;
        SX3->X3_DECIMAL ,;
        SX3->X3_VALID ,;
        SX3->X3_USADO ,;
        SX3->X3_TIPO ,;
        SX3->X3_ARQUIVO ,;
        SX3->X3_CONTEXT,;
        SX3->X3_RELACAO } )
    End
    Sx3->(dbSkip())
End

SX3->(PrefixoCpo(cAlias1)+"_FILIAL")

cUsado := SX3->X3_USADO

If lAuto
	nUsado++
	AADD( aHeader, { "N3AVPPLAN","N3AVPPLAN", "", TamSX3("N3_VORIG1")[1], TamSX3("N3_VORIG1")[2],, cUsado, "N", cAlias1, "V", ""} )
	nUsado++
	AADD( aHeader, { "N3AVPREAL","N3AVPREAL", "", TamSX3("N3_VORIG1")[1], TamSX3("N3_VORIG1")[2],, cUsado, "N", cAlias1, "V", ""} )
EndIf

AADD( aHeader, { "Alias WT",PrefixoCpo(cAlias1)+"_ALI_WT", "", 03, 0,, cUsado, "C", cAlias1, "V", ""} )
AADD( aHeader, { "Recno WT",PrefixoCpo(cAlias1)+"_REC_WT", "", 10, 0,, cUsado, "N", cAlias1, "V", ""} )

SX3->(dbSetOrder(nOrdSx3))

return .t.

/*/
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ CposUsuarioณ Autor ณ Claudio D. de Souza   ณ Data ณ 18/01/02 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณLe a estrutura do arquivo SX3 para verificar os campos criadosณฑฑ
ฑฑณ          ณpelo usuario e adicionar na matriz de campos que poder ser    ณฑฑ
ฑฑณ          ณalterados                                                     ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUtilizacaoณ Cposusuario(aAlter,cAlias)                                   ณฑฑ
ฑฑณParametrosณ aAlter  - > Campos que podem ser alterados                   ณฑฑ
ฑฑณ          ณ cAlias  - > Arquivo a ser lido                               ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ Generico                                                     ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function CposUsuario(aAlter,cAlias)
Local aArea := GetArea()
DEFAULT aAlter := {}
dbSelectArea("SX3")
DbSetOrder(1)
SX3->(dbSeek(cAlias))
While ! SX3->(Eof()) .And. (SX3->X3_arquivo == cAlias)
	If X3USO(SX3->X3_usado)    .And.;
		cNivel >= SX3->X3_NIVEL .And.;
		X3_PROPRI == "U"        .And.;
		X3_VISUAL != "V"
		If Ascan(aAlter, {|e| Alltrim(Upper(e))==AllTrim(Upper(X3_CAMPO))})==0
			Aadd(aAlter,SX3->X3_campo)
		Endif
	End
	Sx3->(dbSkip())
End
RestArea(aArea)

Return Nil

/*/
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ AtfLegenda ณ Autor ณ Wagner Mobile Costa ณ Data ณ 18.04.02 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Funcao utilizada para criacao de Legenda SigaAtf           ณฑฑ
ฑฑณ          ณ Retorna a legenda para o Browse/Cria caixa da legenda      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ SigaAtf                                                    ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function AtfLegenda(cAlias, nReg)

Local aLegenda 	:= {}
Local uRetorno 	:= .T.
Local aCoresNew := {}
Local aLegNew	:= {}

If ExistBlock("ATFLEG")
	uRetorno := ExecBlock("ATFLEG",.F.,.F.,{nReg,cAlias})
Else
	If nReg = Nil	// Chamada direta da funcao onde nao passa, via menu Recno eh passado
		uRetorno := {}
		If cAlias = "SN1"
			if cPaisLoc == "RUS"
				Aadd(uRetorno, { 	'ALLTRIM(N1_STATUS) == "0"'	,"f10_pink" 	} )	//"Schedule"			
				Aadd(uRetorno, { 	'ALLTRIM(N1_STATUS) == "1"'	, "BR_VERDE" 	} )	//"Active"
				Aadd(uRetorno, { 	'ALLTRIM(N1_STATUS) == "5"'	, "BR_AZUL"		} )	//"Conservation"
				Aadd(uRetorno, { 	'! Empty(N1_BAIXA)'			, "BR_VERMELHO"	} )	//"Write-off"
			ELse
				Aadd(uRetorno, { 	'ALLTRIM(N1_STATUS) == "4"'	,"BR_PINK" 		} )	//"Transferencia Interna de Filial"		  	
				Aadd(uRetorno, { 	'! Empty(N1_BAIXA)'			, "BR_VERMELHO"	} )	//"Custo de Empr้stimo"
				Aadd(uRetorno, { 	'N1_PATRIM == "S"'			, "BR_AMARELO" 	} )	//"Patrimonio Liquido"
				Aadd(uRetorno, { 	'N1_PATRIM == "A"'			, "BR_CINZA" 	} )	//"Amortizacao"
				Aadd(uRetorno, { 	'N1_PATRIM == "C"'			, "BR_AZUL"		} )	//"Capital Social"
				Aadd(uRetorno, { 	'N1_PATRIM == "P"'			, "BR_MARROM" 	} )	//"Patrimonio (Prejuizo)"
				Aadd(uRetorno, { 	'N1_PATRIM == "D"'			, "f10_azul" 	} )	//"Ativo Diferido"
				Aadd(uRetorno, { 	'N1_PATRIM == "I"'			, "f10_null" 	} )	//"Ativo Intangํvel"
				Aadd(uRetorno, { 	'N1_PATRIM == "O"'			, "f10_amar" 	} )	//"Or็amento de Provisใo de Despesa"
				Aadd(uRetorno, { 	'N1_PATRIM == "V"'			, "f10_verd" 	} )	//"Provisใo de Despesa"
				Aadd(uRetorno, { 	'N1_PATRIM == "T"'			, "f10_cinz" 	} )	//"Custos de Transa็ใo"
				Aadd(uRetorno, { 	'N1_PATRIM == "E"'			, "f10_lara" 	} )	//"Bem Baixado"
				Aadd(uRetorno, { 	'ALLTRIM(N1_STATUS) == "0"'	,"f10_pink" 	} )	//"Pendente Classifica็ใo"			
				Aadd(uRetorno, { 	'N1_PENHORA == "1"'			, "BR_LARANJA" 	} )	//"Bem em Garantia"
				Aadd(uRetorno, { 	'N1_PENHORA == "2"'			, "BR_BRANCO" 	} )	//"Bem em Penhora"
				Aadd(uRetorno, { 	'N1_PENHORA == "3"'			, "BR_PRETO" 	} )	//"Bem Penhorado"
				Aadd(uRetorno, { 	'N1_PATRIM $ " N"'			, "BR_VERDE" 	} )	//"Ativo Fixo"
			Endif
		ElseIf cAlias = "SN3"
		  	Aadd(uRetorno, { 	'AfxLegTran()'				,"BR_PINK" 		} )	//"Transferencia Interna de Filial"
			Aadd(uRetorno, { 	'N3_BAIXA > "0" .And. ! Empty(N3_DTBAIXA)', "BR_VERMELHO" } )	//"Custo de Empr้stimo"
			Aadd(uRetorno, { 	'.T.'							, "BR_VERDE" 		} ) //"Ativo Fixo"
		Endif				           			

		If ValType( uRetorno ) == 'A' .And. Len( uRetorno ) > 0 .And. Type("aRotina") == "A"
			If aScan(aRotina,{|x| Upper(AllTrim(x[2])) == Upper("AtfLegenda")}) == 0
				Aadd(aRotina, { OemToAnsi(STR0002) ,"AtfLegenda", 0 , 5} )	// "Legenda"
			EndIf
		Endif
	Else
		If cAlias = "SN1"
			if cPaisLoc == "RUS"
				aLegenda := { 	{ "f10_pink"	, STR0043 },;	//"Schedule"
								{ "BR_VERDE"	, STR0044 },; 	//"Active"
								{ "BR_AZUL"		, STR0045 },; 	//"Conservation"
								{ "BR_VERMELHO" , STR0012 }}	//"Write-off"
			else
				aLegenda := { 	{ "BR_VERDE"	, STR0003 },; 	//"Ativo Fixo"
								{ "BR_AMARELO"	, STR0004 },; 	//"Patrimonio Liquido"
								{ "BR_CINZA"	, STR0005 },; 	//"Amortizacao"
								{ "BR_AZUL"		, STR0006 },; 	//"Capital Social"
								{ "BR_MARROM"	, STR0007 },; 	//"Patrimonio (Prejuizo)"
								{ "f10_azul"	, STR0008 },; 	//"Ativo Diferido"
								{ "f10_null"	, STR0009 },; 	//"Ativo Intangํvel"
								{ "f10_amar"	, STR0010 },; 	//"Or็amento de Provisใo de Despesa"
								{ "f10_verd"	, STR0011 },; 	//"Provisใo de Despesa"
								{ "f10_cinz"	, STR0042 },; 	//"Custos de Transa็ใo"
								{ "f10_lara"	, STR0013 },;	//"Custo de Empr้stimo"
								{ "BR_VERMELHO" , STR0012 },;	//"Bem Baixado"
								{ "BR_LARANJA"	, STR0014 },;	//"Bem em Garantia"
								{ "BR_BRANCO"	, STR0015 },;	//"Bem em Penhora"
								{ "BR_PRETO"	, STR0016 },;	//"Bem Penhorado"
								{ "BR_PINK"		, STR0017 },;	//"Transferencia Interna de Filial"
								{ "f10_pink"	, STR0018 }}	//"Pendente Classifica็ใo"
			endif				         					         	
		ElseIf cAlias = "SN3"
			aLegenda := { { "BR_VERDE"		, STR0003 },; //"Ativo Fixo"
							{ "BR_VERMELHO"	, STR0012 },; //"Bem Baixado"
							{ "BR_PINK"		, STR0017 }}	//"Transferencia Interna de Filial"
		Endif	

		//P.E Caixa de Legenda
		If ExistBlock("ATFLEGCX")
				aLegNew := ExecBlock("ATFLEGCX",.F.,.F.,{nReg,cAlias,aLegenda})
				If Len(aLegNew) > 0
					aLegenda  := aClone(aLegNew)
				EndIf
		Endif

		BrwLegenda(cCadastro, STR0002, aLegenda) 			//"Legenda"
	Endif
Endif

//P.E Legendas no browse
If ExistBlock("ATFLEGPOS")
	If nReg == Nil
		aCoresNew := ExecBlock("ATFLEGPOS",.F.,.F.,{nReg,cAlias,uRetorno})
		If Len(aCoresNew) > 0
			uRetorno  := aClone(aCoresNew)
		EndIf	
	EndIf	
EndIf	

Return uRetorno



/*/
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ RetDinDepr ณ Autor ณ Eduardo Fernandes     ณ Data ณ 26/07/06 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณRetorna a data do primeiro dia do mes subsequente, para ser   ณฑฑ
ฑฑณ          ณutilizado quando o parametro MV_TIPDEPR estiver com conteudo  ณฑฑ
ฑฑณ          ณigual a 2(Tipo Depreciacao/Mes Subsequente)    				ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ Dicionario(X3_RELACAO)/ATFA250 - AF250Rateio                 ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function RetDinDepr(dData)
Local dRetDt 		:= dData
Local cTipDepr 		:= SuperGetMv("MV_TIPDEPR",.F.,"0")
Local dAquisic		:= IIF(Type("M->N1_AQUISIC") == "D", M->N1_AQUISIC, dData)
Local lSetCentury 	:= __SetCentury()
Local nDiasPDI		:= SuperGetMv("MV_ATFDPDI",.F.,0) // Dias para considerar proporcional ou integral
DEFAULT __MVCALCDEP := SuperGetMv("MV_CALCDEP",.F.,"0") // 0-MENSAL / 1-ANUAL

If !lSetCentury
	SET CENTURY ON
EndIf

IF cTipDepr == "2" .or. lIsRussia // Tratamento para tipo de depreca็ใo igual a 2 Ou Tratamento para todos os tipos na localiza็ใo Russia | Treatment for type of deprecation equal to 2 Or Treatment for all types in the location Russia
	dRetDt := FirstDay(MsSomaMes(dData, 1, .F.))
ElseIf cTipDepr == "5"
	dRetDt := STOD(StrZero(Year(GetMv("MV_ULTDEPR"))+1,4)+"0101")
Endif

IF cPaisLoc == "COL" .AND. __MVCALCDEP == "0"
	dRetDt := IIF(dAquisic == FirstDay(dDatabase), dAquisic, FirstDay(MsSomaMes(dData, 1, .F.)))
ELSEIF cPaisLoc == "EQU" .AND. __MVCALCDEP == "0" .AND. cTipDepr == "0"
	dRetDt	:= IIF(dData-FirstDay(dData) <= nDiasPDI, FirstDay(dData), dData)
ElseIf (cPaisLoc == "BRA" .And. (FwIsInCallStack("AF240CLASS") .And. cTipDepr == "0" ))
	
	AtfSaveMvVar()
	
	Pergunte("AFA240",.F.)

	If (Valtype(mv_par04) == "N"  .And. mv_par04 == 2 )
		dRetDt := dAquisic	
	Else
		dRetDt := Iif ( dRetDt >= dAquisic, dRetDt, dAquisic )
	EndIf

	AtfRestMvPar()

ENDIF

If !lSetCentury
	SET CENTURY OFF
EndIf

Return (dRetDt)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณATFDINDPREบAutor  ณAlvaro Camillo Neto บ Data ณ  11/28/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGatilho do campo N1_AQUISIC                                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function ATFDINDPRE()	
	Local dDIndDPre    := RetDinDepr(M->N1_AQUISIC)
	Local nX           := 1
	Local dUltDepr     := GetMV("MV_ULTDEPR")
	Local dRetDt
	Local lTemAviso    := .F.
	Local lClicouSim   := .F.
	Local cTipDepr     := SuperGetMv("MV_TIPDEPR",.F.,"0")	
	Local oModel       := Nil
	Local oView        := Nil
	Local oSN3         := Nil
	Local nSN3         := 0
	Local oSN1			:= Nil 


If !FwIsInCallStack("AF012ATDOK") //Nใo atualizar gatilho no commit
	If cTipDepr == "2"
		dRetDt := dUltDepr+1
		If M->N1_AQUISIC <= dUltDepr .And. ;
			dDIndDPre < dRetDt
			If Aviso(STR0019, STR0020;  //"Atencao"##"Data calculada para inicio maior que ultima data de depreciacao."
							+CRLF+STR0021+DtoC(dDIndDPre);  //"Data calculada : "
							+CRLF+STR0022+DtoC(dUltDepr);  //"Data ultima depreciacao : "
							+CRLF+STR0023+DtoC(dRetDt)+STR0024,{STR0025, STR0026},3) == 1  //"Considera data [ "##" ] para inicio da depreciacao?"##"Sim"##"Nใo"
				dDIndDPre := dRetDt
				lClicouSim := .T.		
			EndIf
			lTemAviso := .T.
		EndIf
	EndIf

	// pego o modelo ativo se ele existir
	oModel := FWModelActive()

	// pego o submodelo caso tenha um modelo ativo
	If !Empty(oModel)
		oSN3 := oModel:GetModel('SN3DETAIL')
		oSN1 := oModel:GetModel('SN1MASTER')
	EndIf

	// verifico se o submodelo foi encontrado
	If !Empty(oSN3)
		nSN3 := oSN3:GetLine()

		For nX := 1 To oSN3:Length()
			oSN3:GoLine(nX)
			AF012VLAEC(nX)
			
			If cTipDepr == "0"
				If oSN3:GetValue("N3_DINDEPR") <> oSN1:GetValue("N1_AQUISIC")
					If IsBlind()
						oSN3:SetValue("N3_DINDEPR", dDIndDPre)
					Else
						If Aviso(STR0019, STR0047, {STR0025,STR0026},3) == 1
							oSN3:SetValue("N3_DINDEPR", dDIndDPre)
						EndIf	
					EndIf
				EndIf	
			EndIf	

			If cTipDepr == "1"
				If oSN3:GetValue("N3_DINDEPR") == oSN1:GetValue("N1_AQUISIC")
					oSN3:SetValue("N3_DINDEPR", dDIndDPre)
				ElseIf oSN1:GetValue("N1_AQUISIC") <> dDatabase .And. oSN3:GetValue("N3_DINDEPR") == dDatabase
					oSN3:SetValue("N3_DINDEPR", dDIndDPre)		
				EndIf	
			Endif

			If cTipDepr == "2" 
				If !lTemAviso .Or. lClicouSim
					oSN3:SetValue("N3_DINDEPR", dDIndDPre)									
				EndIf	
			Endif
	
		Next nX
		
		oSN3:GoLine(nSN3)

		oView := FWViewActive()
		If oView <> Nil .And. oView:IsActive()
			oView:Refresh()
		EndIf		
	EndIf
EndIf

Return .T.
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ DateComp ณ Autor ณ Pedro Pereira Lima    ณ Data ณ 19.06.2008 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Calcula dias, meses ou anos de diferenca entre as duas datas ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ DateComp(dInicio,dFim,cDataPart)                             ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ dInicio = Data de Inicio                                     ณฑฑ
ฑฑณ          ณ dFim    = Data de Fim                                        ณฑฑ
ฑฑณ          ณ cDataPart = Retorno do valor em ano, mes ou dia. (YY,MM,DD)  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณ nRetorno = Valor da diferenca no formado definido em         ณฑฑ
ฑฑณ          ณ cDataPart.                                                   ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ ATFA050                                                      ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function DateComp( dInicio ,dFim ,cDataPart )
Local nRetorno   := 0
Local dData      := stod("")
Local lInvertido := .F.

DEFAULT cDataPart := "D"

	If dInicio > dFim
		dData   := dInicio
		dInicio := dFim
		dFim    := dData
		dData   := stod("")
		lInvertido := .T.
	EndIf

	cDataPart := upper( cDataPart )

	Do Case
		// se quiser saber a diferenca em anos
		Case cDataPart = "YY" .OR. cDataPart = "YYYY"

			dData := dInicio
			While dData >= dInicio .AND. dData < dFim
				nRetorno++
				dData := stod(strzero(year(dData),4)+strzero(Month(dData)+1,2)+"01")
			EndDo

		// se quiser saber a diferenca em meses
		Case cDataPart = "M" .OR. cDataPart = "MM"

			dData := MsSomaMes( stod(left(dtos(dInicio),6)+"01"), 1)
			dFim  := stod(left(dtos(dFim),6)+"01")
			While dtos(dData) > dtos(dInicio) .AND. dtos(dData) <= dtos(dFim)
				nRetorno++
				dData := MsSomaMes( dData, 1)
			EndDo

		// se quiser saber a diferenca em dias
		Case cDataPart = "D" .OR. cDataPart = "DD"
			nRetorno := dFim - dInicio

	EndCase

	If lInvertido
		nRetorno := nRetorno*-1
	EndIf

Return( nRetorno )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณAtfGetMtvoณ Autor ณ Totvs                 ณ Data ณ 03.09.08 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Retorna a descricao do motivo da baixa                     ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ SIGAATF                                                    ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AtfGetMtvo( aMotBaixa, cMotivo )
	Local cReturn 	:= ""
	Local nPos		:= aScan( aMotBaixa, { |x| Left( x, 02 ) == cMotivo } )

	If nPos > 0
		cReturn := aMotBaixa[ nPos ]
	EndIf
Return cReturn




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณATFCustod บAutor  ณPedro Pereira Lima  บ Data ณ  03/06/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna o tipo de custodia por "extenso": 1 = CETIP;       บฑฑ
ฑฑบ          ณ 2 = SELIC; 3 = CBLC; 4 = OUTROS                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ DIOPS                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function ATFCustod(cCodCustodia)
Local cRet := ""
Default cCodCustodia := ""

Do Case
	Case cCodCustodia == "1"
		cRet := "CETIP"
	Case cCodCustodia == "2"
		cRet := "SELIC"
	Case cCodCustodia == "3"
		cRet := "CBLC"
	Case cCodCustodia == "4"
		cRet := "OUTROS"
	Otherwise
		cRet := ""
EndCase

Return cRet




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAtfMultMoeบAutor  ณ Acacio Egas        บ Data ณ  10/06/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina de tratamento de multiplas moedas.                  บฑฑ
ฑฑบ          ณ Retorna um vetor com o valor de todas as moedas utilizadas บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAATF                                                    บฑฑ
ฑฑบ          ณ  Funcao "AtfSaldo" parametro 4.                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AtfMultMoe(cAlias,cCampo,Block,nMaxMoed,lUpdDepPer)

Local aRetMoedas := {}
Local nRet
Local __nX
// ********************************
// Controle de multiplas moedas  *
// ********************************
Local __nQuantas := AtfMoedas()

Local nNewPerDep	:= 0
Local cCalcDep		:= SuperGetMv("MV_CALCDEP",.F.,"") // 0 = Monthly or 1 = Annually

Default nMaxMoed    := __nQuantas
Default lUpdDepPer	:= .F.

cCampo := Alltrim(cCampo) // O Campo nใo pode ter numero

If Valtype(Block)<>"B"
	If SubStr(cCampo,Len(cCampo)) $ "0123456789" .or. Len(cCampo)>9

		Aviso(STR0019,STR0027, {"Ok"})  //"Aten็ใo"##"Inconsistencia no tratamento de multiplas Moedas"
		Return nil

	EndIf
EndIf
// ********************************
// Controle de multiplas moedas  *
// ********************************


If lIsRussia .and. cCampo=="N3_TXDEPR" .and. Valtype(Block)=="B" .and. lUpdDepPer // Calculate the depreciation period according to the new depreciation tax
	// Calculate the depreciation period according to the new depreciation tax
	nRet := Eval(Block,1) // Trata bloco de codigo

	If nRet > 0
		nNewPerDep := (100 * 12)  / nRet
		If cCalcDep == "1" // 1 = Annually
			If nNewPerDep / 12 == Int(nNewPerDep / 12)
				nNewPerDep := nNewPerDep / 12
			Else
				nNewPerDep := Int(nNewPerDep / 12) + 1					
			Endif	
		Endif
		SN3->N3_PERDEPR := NoRound( nNewPerDep, TAMSX3('N3_PERDEPR')[2])
	Endif
Endif
For __nX := 1 to __nQuantas
	If Valtype(Block)=="B"

		// ************************
		// Trata bloco de codigo *
		// ************************
		nRet := Eval(Block,__nX)
		aAdd(aRetMoedas, nRet )

		// ***********************************
		// Grava bloco de codigo no campo   *
		// ***********************************
		If !Empty(cCampo) .and. !Empty(cAlias) //.and. aScan(__TTSPush,)

			If Len(cCampo)==9 .and. __nX>9
				(cAlias)->(FieldPut(FieldPos(SubStr(cCampo,1,8) + Alltrim(Str(__nX)) 	), nRet ))
			Else
				(cAlias)->(FieldPut(FieldPos(cCampo + Alltrim(Str(__nX)) 				), nRet ))
			EndIf

		EndIf

	Else

		If Len(cCampo)==9 .and. __nX>9
			aAdd(aRetMoedas, (cAlias)->(FieldGet(FieldPos(SubStr(cCampo,1,8) + Alltrim(Str(__nX)) ))) )
		Else
			aAdd(aRetMoedas, (cAlias)->(FieldGet(FieldPos(cCampo + Alltrim(Str(__nX)) ))) )
		EndIf

	EndIf

	If nMaxMoed==__nX

		Exit

	EndIf
Next

Return aRetMoedas

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAtfMultPosบAutor  ณ Acacio Egas        บ Data ณ  10/06/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Monta vetor com posi็ใo dos campos moeda.                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAATF                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AtfMultPos(aHeader,cCampo, nY)

Local nX
Local aPosMoedas := {}
//********************************
// Controle de multiplas moedas  *
//********************************
Local __nQuantas := AtfMoedas()
Default nY := 2
cCampo := Alltrim(cCampo) // O Campo nใo pode ter numero

If SubStr(cCampo,Len(cCampo)) $ "0123456789" .or. Len(cCampo)>9

	Aviso(STR0019,STR0027, {"Ok"})  //"Aten็ใo"##"Inconsistencia no tratamento de multiplas Moedas"
	Return nil

EndIf

For nX := 1 to __nQuantas
	If Len(cCampo)=9 .and. nX>9
		aAdd(aPosMoedas , Ascan( aHeader	, {|e| Alltrim(e[nY]) = SubStr(cCampo,1,8) + Alltrim(Str(nX))} ) )
	Else
		aAdd(aPosMoedas , Ascan( aHeader	, {|e| Alltrim(e[nY]) = cCampo + Alltrim(Str(nX))} ) )
	EndIf
Next

Return aPosMoedas

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAtfMoedas บAutor  ณ Acacio Egas        บ Data ณ  10/06/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna o numero de moedas do Ativo Fixo.                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAATF                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AtfMoedas()

Local nX

If __nQtdMoed == NIL
	__nQtdMoed	:= 0

	For nX := 1 to 99
		If SN3->(FieldPos("N3_VORIG"+ cValtoChar(nX))) > 0
			__nQtdMoed++
		Else
			Exit
		EndIf
	Next nX

	__nQtdMoed := IIF(__nQtdMoed >= 5 , __nQtdMoed , 5)	// Valor Default

EndIf

Return __nQtdMoed

/*/
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณ ATFXPAcols  ณ Autor ณ Claudio D. de Souza   ณ Data ณ 04.09.03 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Pesquisa em aCols o conteudo de um determinado campo         ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ ATFXPAcols(cCampo,xDefault) -> xDefault=Conteudo default caso ณฑฑ
ฑฑณ          ณ o campo nao seja encontrado.                                 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ SigaAtf                                                      ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function ATFXPAcols(cCampo,xDefault)
Local nAscan := Ascan(aHeader	, {|e| Alltrim(e[2]) == cCampo })
Return If(nAscan>0, aCols[n][nAscan], xDefault)










/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณATFXTpBem บAutor  ณAlvaro Camillo Neto บ Data ณ  25/01/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna os tipo de bens das categorias Fiscal Gerencial     นฑฑ
ฑฑบDesc.     ณou incentivada                                              นฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ 01-nTipo      = Tipo                                       ณฑฑ
ฑฑณ          ณ                 1 - Fiscal                                 ณฑฑ
ฑฑณ          ณ                 2 - Gerencial                              ณฑฑ
ฑฑณ          ณ                 3 - Incentivada                            ณฑฑ
ฑฑณ          ณ                                                            ณฑฑ
ฑฑณ          ณ 02-lArray      = Se retorna eh um array                    ณฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function ATFXTpBem(nTipo,lArray)
Local xTipo :=""
Local cTypes10		:= IIF(lIsRussia,"/" + AtfNValMod({1}, "/"),"") // CAZARINI - 27/03/2017 - If is Russia, add new valuations models - main models
Local cTypes12		:= IIF(lIsRussia,"/" + AtfNValMod({2}, "/"),"") // CAZARINI - 10/04/2017 - If is Russia, add new valuations models - recoverable models
Local cTypes17		:= IIF(lIsRussia,"/" + AtfNValMod({3}, "/"),"") // CAZARINI - 27/03/2017 - If is Russia, add new valuations models - 17 and 16 models
Local cTypes16		:= IIF(lIsRussia,"/" + AtfNValMod({4}, "/"),"") // CAZARINI - 27/03/2017 - If is Russia, add new valuations models - 17 and 16 models
Local lIntegPims    := cPaisLoc == "BRA" .And. FwIsInCallStack("ATFA012") .And. ValType(__ReadVar) == "C" .And. AllTrim(__ReadVar) == "M->N3_INTP"
Default nTipo := 1
Default lArray:= .F.

If Empty(cTipoGerenc)
	cTipoGerenc := RetTipGer()
EndIf

If nTipo == 1 //Fiscal
	xTipo := cTipoFiscal
ElseIf nTipo == 2 //Gerencial
	xTipo := cTipoGerenc
ElseIf nTipo == 3 //Incentivada
	xTipo := cTipoIncent
ElseIf nTipo == 4 //Todos
	xTipo := cTipoFiscal+"/"+cTipoGerenc+"/"+cTipoIncent
EndIf

IF "10" $ xTipo
	xTipo += cTypes10
Endif

IF "12" $ xTipo
	xTipo += cTypes12
Endif

IF "17" $ xTipo
	xTipo += cTypes17
Endif

IF "16" $ xTipo
	xTipo += cTypes16
Endif
If lArray
	xTipo := StrToKarr(xTipo,"/")
EndIf

If ValType(xTipo) == "C"
	xTipo += If(lIntegPims, "/"+cTipoGerenc, "")
EndIf

Return xTipo

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRetTipGer  บAutor  ณMicrosiga           บ Data ณ  01/20/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna o tipo gerencial que sใo todos os tipos que nใo     บฑฑ
ฑฑบ          ณsใo fiscais nem gerenciais                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function RetTipGer()
Local cTipo := ""
Local aArea:= GetArea()

SX5->(dbSetOrder(1))//X5_FILIAL + X5_TABELA + X5_CHAVE
If SX5->(MsSeek( xFilial("SX5") + "G1" ))
	While SX5->(!EOF()) .And. SX5->(X5_FILIAL+X5_TABELA) == xFilial("SX5") + "G1"
		If ! ( Alltrim(SX5->X5_CHAVE) $ cTipoFiscal + "/" + cTipoIncent )
			cTipo += Alltrim(SX5->X5_CHAVE) + "/"
		EndIf
		SX5->(dbSkip())
	EndDo
EndIf

cTipo := Left(cTipo,Len(cTipo)-1)

RestArea(aArea)
Return cTipo


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณATFXVUTIL บAutor  ณJair Ribeiro        บ Data ณ  24/02/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna o tipo gerencial que sใo todos os tipos que nใo     บฑฑ
ฑฑบ          ณsใo fiscais nem gerenciais                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function ATFXVUTIL(cTipoDpr,nTxMoeda,nPerDpr,nProdT,nProdM)
Local nVUtil := 0
Local cCalcDpr := 0

Default cTipoDpr:= ""
Default nTxMoeda:= 0
Default nPerDpr := 0
Default nProdT := 0
Default nProdM := 0

If !Empty(cTipoDpr)
	Do Case
		Case cTipoDpr == "1" .or. cTipoDpr == "7" .and. nTxMoeda > 0
			nVUtil:= (100/nTxMoeda)
		Case cTipoDpr == "2" .or. cTipoDpr == "6"
			cCalcDpr:= Alltrim(SUPERGETMV("MV_CALCDEP",,1)) //Calculo de Depreciacao
			If cCalcDpr == "0"
				nVUtil:= (nPerDpr/12)
			Else
				nVUtil:= nPerDpr
			EndIf
		Case cTipoDpr == "4" .or. cTipoDpr == "5" .and. nProdT > 0 .and. nProdM > 0
			nVUtil:=  nProdT/nProdM
	EndCase
EndIf
Return nVUtil


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณATFXBAIXA บAutor  ณJair RIbeiro        บ Data ณ  02/24/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao retorna situacao do ativo (ativo, baixado, parcial) บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametro:ณ cChave: Chave para busca - FILIAL+CBASE+ITEM+TIPO    	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno:  ณ cRet: Caracter                                             บฑฑ
ฑฑบ          ณ Ativo                                                      บฑฑ
ฑฑบ          ณ Baixado                                                    บฑฑ
ฑฑบ          ณ Parcial                                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Generico                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function ATFXBAIXA(cChave,dDataRef,cSeqReav)
Local aArea	:= SN3->(GetArea())
Local cRet  := 0
Local nAtivo:= 0
Local nBaixa:= 0
Local nReg  := 0

Default cChave 		:= ""
Default dDataRef	:= dDataBase
Default cSeqReav	:= ""

If !Empty(cChave)
	SN3->(DbSetOrder(1))
	SN3->(DbSeek(cChave))
	While SN3->(!EOF()) .and. SN3->(N3_FILIAL + N3_CBASE + N3_ITEM + N3_TIPO ) == cChave

		If !Empty(cSeqReav) .And. Alltrim(SN3->N3_SEQREAV) != Alltrim(cSeqReav)
			SN3->(DbSkip())
			Loop
		EndIf

		If SN3->N3_DTBAIXA > dDataRef .or. Empty(SN3->N3_DTBAIXA)
			nAtivo++
		Else
			nBaixa++
		EndIf
		nReg++
		SN3->(DbSkip())
	EndDo
	If nReg > 0
		Do Case
			Case nAtivo == nReg
				cRet := STR0028 //"Ativo"
			Case nBaixa == nReg
				cRet := STR0029//"Baixado"
			OtherWise
				cRet := STR0030//"Parcial"
		EndCase
	EndIf
EndIf
RestArea(aArea)
Return cRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณATFxTpDescBem บAutor  ณFernando Radu Muscaluบ Data ณ  02/24/11   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao retorna a descricao do tipo em que o bem se enquadra 	   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametro:ณ cTipo: Parametro com o conteudo relacionado ao N3_TIPO  	       บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno:  ณ cRetorno: Descricao do tipo                                     บฑฑ
ฑฑบ          ณ - Fiscal                                                        บฑฑ
ฑฑบ          ณ - Gerencial                                                     บฑฑ
ฑฑบ          ณ - Incentivado                                               	   บฑฑ
ฑฑบ          ณ - Nao especificado                                          	   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Generico                                                   	   บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function ATFXDTPBEM(cTipo)

Local cTpFiscais		:= AtfxTpBem(1)
Local cTpGerenciais		:= AtfxTpBem(2)
Local cTpIncentivados	:= AtfxTpBem(3)
Local cRetorno			:= ""

Do Case
	Case alltrim(cTipo) $ cTpFiscais
		cRetorno := STR0031 //"Fiscal"
	Case alltrim(cTipo) $ cTpGerenciais
		cRetorno := STR0032//"Gerencial"
	Case alltrim(cTipo) $ cTpIncentivados
		cRetorno := STR0033 //"Incentivado"
	Otherwise
		cRetorno := STR0034//"Nใo especificado"
End Case

Return(cRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  |ATFxMDP	บAutor  ณJair Ribeiro        บ Data ณ  03/01/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna o valor maximo de depreciacao do bem               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณcChave:Chave de busca FILIAL+CBASE+ITEM+TIPO+FLAGBAIXA+SEQ  บฑฑ
ฑฑบ			 |nValOrig: Valor original do bem					          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno	 ณnValor: Valor maximo de depreciacao				          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAATF                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function ATFXMDP(cChave,nValOrig)

Local nVMaxDpr	:= 0
Local cMoedaDpr:= SuperGetMV("MV_ATFMDMX",,"1")
Local aArea  	:= SN3->(GetArea())

If Empty(cMoedaDpr)
	cMoedaDpr := "1"
EndIf

SN3->(DbSetOrder(1))
If SN3->(DbSeek(cChave))
	nVMaxDpr:=(SN3->N3_VMXDEPR)/SN3->&("N3_VORIG"+cMoedaDpr)
EndIf

nVMaxDpr := (nValOrig*nVMaxDpr)

RestArea(aArea)

Return nVMaxDpr


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณRetTipDeprณ Autor ณ Jair RIbeiro          ณ Data ณ 27/04/11 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDesc.     ณ Sugere criterio de depreciacao	                          ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ SIGAATF                                                    ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Sintaxe  ณ RetTipDepr(cTipDepr) 					                  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ cTipDepr: criterio a ser sugerido						  ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function RetTipDepr(cTipDepr)
Local cParTipDepr := Alltrim(SuperGetMv("MV_TIPDEPR",.F.,""))
Default cTipDepr := "01"

If cParTipDepr != "9"
	Do Case
		Case cParTipDepr == "0"
			cTipDepr :=	"00"
		Case cParTipDepr == "1"
			cTipDepr :=	"01"
		Case cParTipDepr == "2"
			cTipDepr :=	"02"
		Case cParTipDepr == "3"
			cTipDepr :=	"10"
		Case cParTipDepr == "4"
			cTipDepr :=	"11"
		Case cParTipDepr == "5"
			cTipDepr :=	"12"
		OtherWise
			cTipDepr :=	"01"
	EndCase
EndIf
Return cTipDepr



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณATFCBGenerณ Autor ณ Marcelo Akama         ณ Data ณ 12/02/10 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Retorna uma string com os itens da tabela generica         ณฑฑ
ฑฑณ          ณ informada para uso no combo box                            ณฑฑ
ฑฑณ          ณ X3_CBOX := "#AdmCBGener(cFil,cAlias,cTabela,cIdioma)"      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ Generico                                                   ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Sintaxe  ณ AdmCBGener(cFil,cAlias,cTabela,cIdioma)                    ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ cAlias  - Alias ("SX5", "CW0" ou "SN0")                    ณฑฑ
ฑฑณ          ณ cTabela - Codigo da tabela                                 ณฑฑ
ฑฑณ          ณ cIdioma - Idioma                                           ณฑฑ
ฑฑณ          ณ               "01" - Portugues                             ณฑฑ
ฑฑณ          ณ               "02" - Espanhol                              ณฑฑ
ฑฑณ          ณ               "03" - Ingles                                ณฑฑ
ฑฑณ          ณ aChave  - Array para filtro de acordo com o campo _CHAVE   ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function ATFCBGener(cFil,cAlias,cTabela,cIdioma,aChave)
Local cRet		:= ''
Local aArea		:= GetArea()
Local aArea2
Local cPrefix
Local cFldDsc
// Variaveis especificas para projeto R๚ssia | Specific variables for project Russia
Local lTemMod10	:= .F.
Local lTemMod12	:= .F.
Local aValMod	:= {}
Local cValMod	:= ""
Local nValMod	:= 0
Local aAreaSX5	:= {}
Local lChk1012 	:= .F.
//
Default cIdioma := ""
Default cAlias  := "SX5"
Default cTabela := "01"
Default cFil    := xFilial(cAlias)
Default aChave	:= {}

If Valtype(aChave) != "A"
	aChave	:= {}
EndIf

If cAlias $ "SX5.CW0.SN0"

	If cAlias == "SX5"

        cPrefix := "X5"

		if ( FwRetIdiom()=="es" )
			cFldDsc := "_DESCSPA"
		else
			if ( FwRetIdiom()=="en" )
				cFldDsc := "_DESCENG"
			  else
				cFldDsc := "_DESCRI"
			  endif
		   endif 

	ElseIf cAlias=="SN0"
		cPrefix := "N0"
		cFldDsc := "_DESC01"
	Else
		cPrefix := cAlias
		cFldDsc := "_DESC01"
	EndIf

	DbSelectArea(cAlias)
	aArea2:=(cAlias)->(GetArea())

	(cAlias)->(DbSetOrder(1))
	(cAlias)->(MsSeek(cFil+cTabela))

	Do While cFil + cTabela == (cAlias)->( &(cPrefix + "_FILIAL") + &(cPrefix + "_TABELA") )
		lChk1012 := .F.
		If Empty(aChave)
			cRet := cRet + IIf(empty(cRet),'',';') + Alltrim(&(cPrefix + "_CHAVE")) + '=' + Alltrim(&(cPrefix + cFldDsc))
		    lChk1012 	:= lIsRussia // A variavel ้ atribuida como verdadeira apenas se a localiza็ใo for Russia |The variable is assigned as true only if the location is Russia
		Else
			If AsCan(aChave,{|aX| AllTrim(aX) == AllTrim((cAlias)->(&(cPrefix + "_CHAVE")))}) > 0
				cRet := cRet + IIf(empty(cRet),'',';') + Alltrim(&(cPrefix + "_CHAVE")) + '=' + Alltrim(&(cPrefix + cFldDsc))
				lChk1012 	:= lIsRussia // A variavel ้ atribuida como verdadeira apenas se a localiza็ใo for Russia |The variable is assigned as true only if the location is Russia
			EndIf
		EndIf
		If lChk1012 // CAZARINI - 10/03/2017 - If is Russia, add new valuations models - main models
			If cAlias == "SX5" .and. cTabela == "G1"	
				If Alltrim(SX5->X5_CHAVE) == "10"
					lTemMod10 := .T.
				Endif
				If Alltrim(SX5->X5_CHAVE) == "12"
					lTemMod12 := .T.
				Endif
			Endif		
		Endif		
		(cAlias)->(DbSkip())
	EndDo
	RestArea(aArea2)
EndIf
If lTemMod10 // CAZARINI - 10/03/2017 - If is Russia, add new valuations models - main models
	cValMod	:= ATFNValMod( {1}, '/' )
	aValMod	:= Separa(cValMod, '/', .f.) 

	aAreaSX5 := SX5->(GetArea())

	DbSelectArea("SX5")
	DbSetOrder(1) // X5_FILIAL+X5_TABELA+X5_CHAVE                                                                                                                                    
	For nValMod := 1 to len(aValMod)
		If MsSeek(cFil+cTabela+aValMod[nValMod])
			cRet := cRet + IIf(empty(cRet),'',';') + Alltrim(SX5->X5_CHAVE) + '=' + Alltrim(&(cPrefix + cFldDsc))
		Endif
	Next nValMod

	RestArea(aAreaSX5)
Endif

If lTemMod12 // CAZARINI - 10/04/2017 - If is Russia, add new valuations models - main models
	cValMod	:= ATFNValMod( {2}, '/' )
	aValMod	:= Separa(cValMod, '/', .f.) 

	aAreaSX5 := SX5->(GetArea())

	DbSelectArea("SX5")
	DbSetOrder(1) // X5_FILIAL+X5_TABELA+X5_CHAVE                                                                                                                                    
	For nValMod := 1 to len(aValMod)
		If MsSeek(cFil+cTabela+aValMod[nValMod])
			cRet := cRet + IIf(empty(cRet),'',';') + Alltrim(SX5->X5_CHAVE) + '=' + Alltrim(&(cPrefix + cFldDsc))
		Endif
	Next nValMod

	RestArea(aAreaSX5)
Endif


RestArea(aArea)
Return(cRet)



Function AtfXPerCal(dData,cCriterio,cCalend)

Local nI		:= 0
Local nAno		:= 0
Local nMes		:= 0
Local nAnoUso	:= 0
Local nQtdTri	:= 0

Local cPeriodo	:= ""
Local cDataIni	:= ""
Local cDataFim	:= ""

Local aAuxPer	:= {}
Local aPeriodo	:= {}
Local aMesCalTri:= {}

Local dDataIni	:= stod("")
Local dDataFim	:= stod("")

Local xRet		:= .t.

If Alltrim(cCriterio) $ "03|04"

	If !Empty(cCalend)

		cPeriodo := SN0->(GetAdvFVal("SN0","N0_DESC01",xFilial("SN0") + '06' + cCalend,1,""))

		If !Empty(cPeriodo)
			aAuxPer := Separa(cPeriodo,"|")

			For nI := 1 to len(aAuxPer)
				aAdd(aPeriodo,Separa(aAuxPer[nI],"/"))
				aPeriodo[len(aPeriodo),1] := Val(aPeriodo[len(aPeriodo),1])
				aPeriodo[len(aPeriodo),2] := Val(aPeriodo[len(aPeriodo),2])
			Next nI

			nAno := Year(dData)
			nMes := Month(dData)

			If nMes < aPeriodo[1,2]
				nAnoUso 	:= nAno - 1
			Else
				nAnoUso		:= nAno
			Endif

			cDataIni	:= Alltrim(str(nAnoUso)) + StrZero(aPeriodo[1,2],2) + StrZero(aPeriodo[1,1],2)

			If aPeriodo[2,2] < aPeriodo[1,2]
				nAnoUso++
			Endif

			cDataFim := Alltrim(str(nAnoUso)) + StrZero(aPeriodo[2,2],2) + StrZero(aPeriodo[2,1],2)

			dDataIni := stod(cDataIni)
			dDataFim := stod(cDataFim)

			If Alltrim(cCriterio) == "04"

				nMes := DateDiffMonth(dDataFim,dDataIni) + 1 //considerar o mes inicial

				If Mod(nMes,3) <> 0
					Help(" ",1,"AtfXPerCal_02",,"Crit้rio de deprecia็ใo, Pr๓ximo Trimestre, exige que o calendแrio utilizado seja compatํvel, ou seja m๚ltiplo de tr๊s. ",1,0)
					xRet := .f.
				Endif

				nQtdTri := 1
				aAuxPer	:= {}

				While dDataIni <= dDataFim
					aAdd(aAuxPer, Month(dDataIni))

					nQtdTri++

					dDataIni := LastDay(LastDay(dDataIni)+1)

					If nQtdTri > 3
						aAdd(aMesCalTri,aAuxPer)
						aAuxPer := {}
						nQtdTri := 1
					Endif
				EndDo

				nAnoUso := nAno

				For nI := 1 to len(aMesCalTri)

					nPos := aScan(aMesCalTri[nI],{|x| x == Month(dData)})

					If nPos > 0
						nPos := nI
						Exit
					Endif

				Next nI

				nPos++

				If nPos > len(aMesCalTri)
					nAnoUso++
					nMes := aMesCalTri[1,1]
				Else

					If nPos == 1 .and. Month(dData) > aMesCalTri[len(aMesCalTri),3]
						nAnoUso++
					Endif

					nMes := aMesCalTri[nPos,1]
				Endif

				cDataIni := Alltrim(Str(nAnoUso))+StrZero(nMes,2)+StrZero(aPeriodo[1,1],2)
				dDataIni := sTod(cDataIni)

				cDataFim := Alltrim(Str(nAnoUso)) + StrZero(aMesCalTri[len(aMesCalTri),3],2) + StrZero(aPeriodo[2,1],2)
				dDataFim := StoD(cDataFim)
			Endif

			xRet := {dDataIni,dDataFim}
		Else
			Help(" ",1,"AtfXPerCal_03",,"Calendแrio de deprecia็ใo, " + alltrim(cCalend) + ", informado nใo existe.",1,0)
			xRet := .f.
		Endif

	Endif
Else
	Help(" ",1,"AtfXPerCal_01",,"Crit้rio de deprecia็ใo escolhido deve ser 03 - Exercํcio Completo ou 04 -  Pr๓ximo Trimestre.",1,0)
	xRet := .f.
Endif

Return(xRet)



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAtfGetSN0 บAutor  ณMicrosiga           บ Data ณ  09/09/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณExtrai conteudo do campo na tabela / chave especificada     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function AtfGetSN0(cTabela,cChave, xCampo, xRetInv)
Local xRet

Default xCampo 		:= "N0_DESC01"
Default xRetInv 	:= ""
If !Empty(cTabela) .And. !Empty(cChave)
	xRet := SN0->(GetAdvFVal("SN0",xCampo,xFilial("SN0") + cTabela + cChave,1,xRetInv))
Else
	xRet := xRetInv
EndIf

Return(xRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAtfGetSN0 บAutor  ณMicrosiga           บ Data ณ  09/09/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAtualiza tabela / chave / campo especificada c/ Conteudo    บฑฑ
ฑฑบ          ณinformado                                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function AtfPutSN0(cTabela,cChave, cCampo, cConteudo)
Local lRet  := .F.
Local lGrava := .F.
Local nCpoAux

Default cCampo 		:= "N0_DESC01"

If !Empty(cTabela) .And. !Empty(cChave) .And. !Empty(cCampo)
	dbSelectArea("SN0")
	dbSetOrder(1)
	lGrava := SN0->(!dbSeek( xFilial("SN0")+ cTabela + cChave ))
	RecLock("SN0",lGrava)
	If lGrava
		SN0->N0_FILIAL	:= xFilial("SN0")
		SN0->N0_TABELA	:= cTabela
		SN0->N0_CHAVE	:= cChave
	EndIf
	If ( nCpoAux := FieldPos(Alltrim(Upper(cCampo))) ) > 0
		SN0->( FieldPut(nCpoAux, cConteudo) )
	EndIf
	MsUnLock()
EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAfxLegTran   บAutor  ณMicrosiga           บ Data ณ  09/12/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna a legenda do ativo transferido para mbrows com      บฑฑ
ฑฑบ          ณSN3                                                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AfxLegTran()
Local aArea		:= GetArea()
Local lTransf	:= .F.
Local cAliasQry	:= GetNextAlias()

//---------------------------------------------------
// Query necessaria para identificar transfer๊ncias  
// parciais, onde a SN1 nใo fica com o N1_STATUS = 4
//---------------------------------------------------
BeginSQL Alias cAliasQry
SELECT FN7_CODBX
FROM %Table:FN7% FN7
WHERE	FN7.FN7_FILORI	= %Exp:SN3->N3_FILORIG%	AND
		FN7.FN7_CBASE	= %Exp:SN3->N3_CBASE%	AND
		FN7.FN7_CITEM	= %Exp:SN3->N3_ITEM%	AND
		FN7.FN7_TIPO	= %Exp:SN3->N3_TIPO%	AND
		FN7.FN7_SEQ		= %Exp:SN3->N3_SEQ%		AND
		FN7.FN7_TPSALD	= %Exp:SN3->N3_TPSALDO%	AND
		FN7.FN7_MOTIVO	= '18'					AND
		FN7.FN7_STATUS	= '1'					AND
		FN7.%NotDel%
EndSQL

If (cAliasQry)->(!Eof())
	lTransf := .T.
EndIf

//----------------------------------------------------------------
// Tratamento incluso devido registros migrados da versใo 11 onde 
// nใo havia as tabelas FN6 e FN7, porem as baixas eram integrais
//----------------------------------------------------------------
If !lTransf
	SN1->(DBSetOrder(1))
	If SN1->(MsSeek(xFilial("SN1",SN3->N3_FILIAL) + SN3->( N3_CBASE + N3_ITEM )))
		lTransf := SN1->N1_STATUS == '4'
	EndIf
EndIf

(cAliasQry)->(DBCloseArea())

RestArea(aArea)
Return lTransf

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณATFXProxItบAutor  ณAlvaro Camillo Neto บ Data ณ  10/27/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna Item (N1_ITEM) disponivel de acordo com codigo     บฑฑ
ฑฑบ          ณ base                                                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function ATFXProxIt(cFil,cBase,cItem)

Local aArea		 := SN1->(GetArea())
Local nLenN1Item := TamSx3("N1_ITEM")[1]
Local cNewItem	 := STRZERO(0,nLenN1Item)
Local l1z_Or_2z  := .F.

Default cFil 	 := cFilAnt
Default cBase	 := ""
Default cItem	 := ""

If !Empty(cFil) .and. !Empty(cBase)
	cQry := " SELECT"+chr(13)+chr(10)
	cQry += " COALESCE( MAX(N1_ITEM),'"+PadR(Space(1),nLenN1Item)+"') ITEM"+chr(13)+chr(10)
	cQry += " FROM "+RetSQlName("SN1")+ " N1 "+chr(13)+chr(10)
	cQry += " WHERE N1_FILIAL = '"+xFilial("SN1",cFil)+"'"+chr(13)+chr(10)
	cQry += " AND N1_CBASE = '"+cBase+"'"+chr(13)+chr(10)
	cQry += " AND N1.D_E_L_E_T_ = ' ' "

	cQry := ChangeQuery(cQry)

	If Select("SN1ITEM") > 0
		SN1ITEM->(DbCloseArea())
	Endif
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry), "SN1ITEM", .T., .F.)
	If Empty(SN1ITEM->ITEM)
		cNewItem := IiF(Empty(cItem),Soma1(Alltrim(cNewItem)),cItem)
	Else
		//Somente 1 digito Z OU Somente 2 digitos Z
		l1z_Or_2z := If( Upper(Alltrim(SN1ITEM->ITEM)) == "Z" .OR. Upper(Alltrim(SN1ITEM->ITEM)) == "ZZ", .T., .F.)
		cNewItem := If(!l1z_Or_2z , Soma1(Alltrim(SN1ITEM->ITEM)), Soma1(SN1ITEM->ITEM) )
	EndIf
	SN1ITEM->(DbCloseArea())

	//Tratamento pois a fun็ใo Soma1 nใo preserva o tamanho do campo
	cNewItem := PADR( cNewItem, nLenN1Item )
EndIf

SN1->(RestArea(aArea))

Return cNewItem

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ AFXIndRev		บAutor  ณAlvaro Camillo Neto   ณ  10/10/12บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Busca a revisao de indice (FNI) valida para data passada pelo parametro      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AFXIndRev(cIndice,dDataRev)
Local aArea := GetArea()
Local cRev  := ""
Local cQuery   := ""
Local cTab     := GetNextAlias()

Default dDataRev := CTOD("")

// Atualiza apenas as curvas vแlidas
cQuery   += " SELECT MAX(FNI_REVIS) ULTREV"
cQuery   += " FROM " + RetSQLTab("FNI")
cQuery   += " WHERE "
cQuery   += " FNI_FILIAL = '"+xFilial("FNI")+"' "
cQuery   += " AND FNI_CODIND = '"+cIndice+"' "
If !Empty(dDataRev)
	cQuery   += " AND FNI_DTREV <= '"+DTOS(LastDay(dDataRev))+"' "
EndIf
cQuery   += " AND D_E_L_E_T_ = ' ' "
cQuery   := ChangeQuery(cQuery)
If Select(cTab) > 0
	(cTab)->(dbCloseArea())
EndIf

dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cTab, .T., .T.)

If (cTab)->(!EOF())
	cRev := (cTab)->ULTREV
EndIf

(cTab)->(dbCloseArea())
RestArea(aArea)
Return cRev




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAFXDesPatrบAutor  ณAlvaro Camillo Neto บ Data ณ  16/11/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna a descri็ใo da classificacao do ativo fixo          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AFXDesPatr(cPatrim)
Local cDesc := ""
Local aArea := GetArea()

dbSelectArea("SN0")
SN0->(dbSetOrder(1)) //N0_FILIAL+N0_TABELA+N0_CHAVE
If SN0->(MsSeek( xFilial("SN0") + "07" + cPatrim ))
	cDesc := Alltrim(SN0->N0_DESC01)
EndIf

RestArea(aArea)
Return cDesc
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณATFxUltSeq   บAutor  ณRenan Guedes     บ Data ณ  11/22/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPesquisa e retorna a ๚ltima sequ๊ncia dos itens do bem (SN3)บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function ATFxUltSeq(cBase,cItem)
Local cSeq			:= ""
Local aArea			:= {}
Local cAliasTrb		:= ""
Local cQuery		:= ""

Default cBase		:= ""
Default cItem		:= ""

aArea := GetArea()

If (ValType(cBase) == "C") .And. (ValType(cItem) == "C")
	
		cQuery	+= "	SELECT	"
		cQuery	+= "		MAX(SN3.N3_SEQ)	N3_SEQ	"
		cQuery	+= "	FROM " + RetSqlTab("SN3")
		cQuery	+= "	WHERE	"
		cQuery	+= "			SN3.D_E_L_E_T_ != '*'	"
		cQuery	+= "		AND SN3.N3_FILIAL 	= '" + xFilial("SN3") + "'"
		cQuery	+= "		AND SN3.N3_CBASE	= '" + cBase + "'"
		cQuery	+= "		AND SN3.N3_ITEM		= '" + cItem + "'"

		//Executa a query
		cAliasTrb := GetNextAlias()
		cQuery := ChangeQuery(cQuery )
		dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQuery) , cAliasTrb , .T. , .F.)
		(cAliasTrb)->(dbGoTop())

		//Verifica se retornou algum registro e armazena na variแvel
		If (cAliasTrb)->(!EOF())
			cSeq := (cAliasTrb)->N3_SEQ
		EndIf
		(cAliasTrb)->(dbCloseArea())
EndIf

RestArea(aArea)

Return(cSeq)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณATFxCtrlAprov  บAutor  ณRenan Guedes   บ Data ณ  12/13/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVerifica se o controle de aprova็ใo estแ implementado e	  บฑฑ
ฑฑบ          ณativo para determinada rotina/opera็ใo                      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function ATFxCtrlAprov(cRotina,cOper)

Local lRet			:= .F.
Local aArea			:= GetArea()
Local aAreaFNH		:= {}
Local aAreaFNK		:= {}
Local aAreaFNL		:= {}
Local nTamRot, nTamOper
Local cRevis		:= ""

Default cRotina		:= ""
Default cOper		:= ""

If (ValType(cRotina) == "C") .And. (ValType(cOper) == "C")
	nTamRot		:= TamSX3("FNH_ROTINA")[1]
	nTamOper	:= TamSX3("FNH_OPER")[1]

	//Padroniza os strings da rotina e opera็ใo
	cRotina		:= PADR(AllTrim(cRotina), nTamRot)
	cOper		:= PADR(AllTrim(cOper), nTamOper)

	dbSelectArea("FNH")
	aAreaFNH := FNH->(GetArea())
	FNH->(dbSetOrder(1))		//FNH_FILIAL+FNH_ROTINA+FNH_OPER

	//Procura pela rotina e opera็ใo
	If FNH->(MsSeek(xFilial("FNH")+cRotina+cOper))
		//Verifica se a rotina/opera็ใo estแ com o controle de aprova็ใo habilitado
		If FNH->FNH_STATUS == "1"		//Habilitado

			//Procura pela al็ada de aprova็ใo
			cRevis := AFXAprRev(cRotina)

			dbSelectArea("FNK")
			aAreaFNK := FNK->(GetArea())
			FNK->(dbSetOrder(1))		//FNK_FILIAL+FNK_ROTINA+FNK_REVIS
			If FNK->(MsSeek(xFilial("FNK")+cRotina+cRevis))
				If FNK->FNK_STATUS == "1"		//Habilitado

					//Procura por aprovadores habilitados
					dbSelectArea("FNL")
					aAreaFNL := FNL->(GetArea())
					FNL->(dbSetOrder(1))		//FNL_FILIAL+FNL_ROTINA+FNL_REVIS+FNL_OPER+FNL_CODAPR
					If FNL->(MsSeek(xFilial("FNL")+cRotina+cRevis+cOper))
						lRet := .T.
					EndIf
					RestArea(aAreaFNL)
				EndIf
			EndIf
			RestArea(aAreaFNK)
		EndIf
	EndIf
	RestArea(aAreaFNH)

EndIf

RestArea(aArea)

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAFXAprRev   บAutor  ณAFXAprRev          บ Data ณ  12/23/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna a ultima revisใo da operacao da rotina             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AFXAprRev(cRotina)
Local cRev  := ""
Local aArea := GetArea()

FNK->(dbSetOrder(1))		//FNK_FILIAL+FNK_ROTINA+FNK_REVIS
If FNK->(MsSeek(xFilial("FNK")+cRotina))
	While FNK->(!EOF()) .And. FNK->(FNK_FILIAL+FNK_ROTINA) == xFilial("FNK")+cRotina
		cRev := FNK->FNK_REVIS
		FNK->(dbSkip())
	EndDo
EndIf

RestArea(aArea)
Return cRev




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAFXPeriodo บAutor  ณAlvaro Camillo Neto บ Data ณ  04/04/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina que retorna um array com a data inicial e final      บฑฑ
ฑฑบ          ณde todos meses de um perํodo                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AFXPeriodo(dDataIni,dDataFim)
Local aPeriodo := {}
Local dDataAux := FirstDay(dDataIni)

While dDataAux <= LastDay(dDataFim)
	aAdd(aPeriodo,{FirstDay(dDataAux),LastDay(dDataAux)})
	dDataAux := LastDay(dDataAux)+1
EndDo


Return aPeriodo


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAFXVLGer  บAutor  ณAlvaro Camillo Neto บ Data ณ  05/31/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVerifica se no ativo existe apenas o tipo 10 - gerencial    บฑฑ
ฑฑบ          ณ ou 13 adiantamento gerencial                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AFXVLGer(cXFil,cBase,cItem,cTipo,cTpSald)
Local lRet     := .T.
Local aArea    := GetArea()
Local aAreaSN3 := SN3->(GetArea())

Default cXFil := xFilial("SN3")

SN3->(dbSetOrder(1)) //N3_FILIAL+N3_CBASE+N3_ITEM+N3_TIPO+N3_BAIXA+N3_SEQ

If SN3->(MsSeek(cXFil + cBase + cItem + "01" )) .Or. SN3->(MsSeek(cXFil + cBase + cItem + "03" ))
	lRet := .F.
EndIf

If lRet .And. cTpSald != '1'
	lRet := .F.
EndIf

RestArea(aAreaSN3)
RestArea(aArea)
Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณADMGETCLASบAutor  ณRodrigo Gimenes     บ Data ณ  03/07/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Adm_Opcoes de pesquisa por classifica็๕es patrimoniais     บฑฑ
ฑฑบ          ณ existentes na tabela auxiliar do Ativo SN0 - Tabela 7      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณRetorno   ณ aSelClass(Contem todas as classeifica็๕es selecionada)     ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑบUso       ณ SIGACTB, SIGAATF, SIGAFIN                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function ADMGETCLAS(lTodas,lFnb)

Local cTitulo	:= ""
Local MvPar		:= ""
Local MvParDef	:= ""
Local nI 		:= 0
Local aArea 	:= GetArea()
Local nReg	    := 0
Local nSit		:= 0
Local aSit		:= {}
Local aSelClass	:= {}
Local nTamClass	:= 0
Local lOk		:= .T.


Default lTodas := .F.
Default lFnb   := .F.

	If !IsBlind()
		nI := 1
		aSit	:= {}
		MvParDef := ""
		cTitulo :=  STR0035//" Selecione as Classificacoes Patrimoniais "
		nTamClass := TAMSX3("N0_CHAVE")[1]
		DbSelectArea("SN0")
		SN0->(dbSetOrder(1))
		If SN0->(dbSeek( xFilial("SN0")+ "07" ))
			While !SN0->(Eof()) .And. AllTrim(SN0->N0_TABELA) == "07"
				lOk := IIf(lFnb,AllTrim(SN0->N0_CHAVE) $ "N|D|I",.T.)
				If lOk
					cDesc := ""
					cDesc := SN0->N0_DESC01
					Aadd(aSit, cDesc )
				 	MvParDef += SN0->N0_CHAVE
					 nI++
				EndIf
				SN0->(dbSkip())
			End
		EndIf

		IF AdmOpcoes(@MvPar,cTitulo,aSit,MvParDef,,,.F.,nTamClass,nI,.T.)  // Chama funcao Adm_Opcoes
			nSit := 1
			For nReg := 1 To len(mvpar) Step nTamClass  // Acumula as classifica็๕es
				If SubSTR(mvpar, nReg, nTamClass) <> Replicate("*",nTamClass)
			 		AADD(aSelClass, SubSTR(mvpar, nReg, nTamClass) )
				Endif
				nSit++
			next
			If Empty(aSelClass)
	 	  		Help(" ",1,"ADMGETCLAS",,STR0036,1,0)		//"Por favor selecionar pelo menos uma classifica็ใo"
			EndIF
			lTodas := Len(aSelClass) == Len(aSit)
		Endif
	Else
		aSelClass := {"N"}
	EndIf

RestArea(aArea)

Return(aSelClass)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFORMATCLASบAutor  ณRodrigo Gimenes     บ Data ณ  06/07/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Formata o array de classifica็๕es selecionadas para        บฑฑ
ฑฑบ          ณ utiliza็ใo em filtros dos relat๓rios ou nas queries        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณRetorno   ณ cClassif Todas as classeifica็๕es selecionadas e formatadasนฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑบUso       ณ SIGACTB, SIGAATF, SIGAFIN                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FORMATCLAS(aClassif,lQuery)

Local aArea 	:= GetArea()
Local nReg	    := 0
Local cClassif  := ""


Default lQuery := .F.

For nReg := 1 To Len(aClassif)
	cClassif += aClassif[nReg] + IIf(nReg < Len(aClassif),  "/" ,"")
Next


If lQuery
	cClassif := FormatIn(cClassif,"/")
EndIf

RestArea(aArea)

Return(cClassif)



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCLASSN1FNBบAutor  ณRodrigo Gimenes     บ Data ณ  18/07/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Formata a classifica็ใo patrimonial de acordo com a tabela บฑฑ
ฑฑบ          ณ FNB.                                                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณRetorno   ณ aRet : Variแvel contedo o valor correspondente na tabela FNBนฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑบUso       ณ SIGACTB, SIGAATF, SIGAFIN                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function CLASSN1FNB(aClassif)


Local nReg := 0
Local aSubTipo := {}
Local cSubTipo := ""
Local cClassif := ""

For nReg := 1 To Len(aClassif)
	//As correspnd๊ncias dessa fun็ใo sใo baseadas nas i8nforma็๕es da fun็ใo AF430GerAT() do fonte ATFA430.
	cClassif := AllTrim(aClassif[nReg])
	Do Case
		Case cClassif == "N" // Ativo Fixo
			cSubTipo := "1"
		Case cClassif == "I" // Intangํvel
			cSubTipo := "2"
		Case cClassif == "D" //Diferido
			cSubTipo := "3"
	EndCase
	AADD(aSubTipo,cSubTipo)
Next

Return aSubTipo


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณATFEXSTPTRบAutor  ณRodrigo Gimenes     บ Data ณ  20/07/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica se existe a tabela adicional de classif.          บฑฑ
ฑฑบ          ณ patrimonial                                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณRetorno   ณ lRet: Se a tebal existe ou nใo                             นฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑบUso       ณ SIGACTB, SIGAATF, SIGAFIN                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function ATFEXSTPTR()

Local aAreaSN0 	:= {}
Local lRet		:= .F.

DbSelectArea("SN0")
aAreaSN0 := SN0->(GetArea())
lRet := SN0->(DbSeek(xFilial("SN0") + "07"))
RestArea(aAreaSN0)

Return lRet











/*/
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณ FaVRelPrv  ณAutor  ณMauricio Pequim Jr     ณ Data ณ 04/10/12 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Verifica o relacionamento do imobilizado a um controle de    ณฑฑ
ฑฑณ          ณ execucao de provisao                                         ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ Generico                                                     ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
*/
//PRV
Function FaVRelPrv(nIndice,cChave)

Local lRet := .F.
Local aAreaFNX := FNX->(GetArea())

DEFAULT nIndice := 1
DEFAULT cChave := ""

FNX->(dbSetOrder(nIndice))
If FNX->(MsSeek(cChave))
	lRet := .T.
Endif

RestArea(aAreaFNX)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ATFGeTpDp
Fun็ใo que monta a tela de sele็ใo de m้todos de deprecia็ใo para filtro gen้ricos nas rotinas do ambiente Protheus
Utilizando no relat๓rio ATFR350 -> Relat๓rio de Simula็ใo de Deprecia็ใo

@param		lTodas			Sinaliza se todos os m้todos de deprecia็ใo estใo selecionados na tela
@return	aSelTpDep		Objeto criado com o formato do relat๓rio
@author	marylly.araujo
@since		18/09/2012
@version	MP11
/*/
//-------------------------------------------------------------------
Function ATFGeTpDp(lTodas)

Local cTitulo		:= ""
Local MvPar		:= ""
Local MvParDef	:= ""
Local nI			:= 1
Local aArea		:= GetArea()
Local aAreaSN0	:= {}
Local nReg			:= 0
Local nSit			:= 1
Local aSit			:= {}
Local aSelTpDep	:= {}
Local nTamTpDep	:= 0
Local cFilSN0		:= xFilial("SN0")

Default lTodas := .F. // Sinaliza se todos os m้todos de deprecia็ใo estใo selecionados na tela

DbSelectArea("SN0") // Tabela Gen้ricas do M๓dulo Ativo Fixo
aAreaSN0 := SN0->(GetArea())

	If !IsBlind()
		aSit		:= {}
		MvParDef	:= ""
		cTitulo	:= STR0038 // "Selecione os m้todos de deprecia็ใo"
		nTamTpDep	:= TAMSX3("N0_CHAVE")[1]
		SN0->(dbSetOrder(1)) // Filial + Chave Tabela
		If SN0->( dbSeek( cFilSN0 + "04" ) )
			While !SN0->(Eof()) .And. AllTrim(SN0->N0_TABELA) == "04"
				cDesc := ""
				cDesc := AllTrim(SN0->N0_DESC01)
				Aadd(aSit, cDesc )
			 	MvParDef += SN0->N0_CHAVE
				nI++
				SN0->(dbSkip())
			EndDo
		EndIf

		IF AdmOpcoes(@MvPar,cTitulo,aSit,MvParDef,,,.F.,nTamTpDep,nI,.T.) // Fun็ใo que abre a tela com os checkbox para sele็ใo das op็๕es
			For nReg := 1 To len(mvpar) Step nTamTpDep  // Acumula as op็๕es dos m้todos de deprecia็ใo
				If SubSTR(mvpar, nReg, nTamTpDep) <> Replicate("*",nTamTpDep)
			 		AADD(aSelTpDep, SubSTR(mvpar, nReg, nTamTpDep) )
				Endif
				nSit++
			Next nReg

			If Empty(aSelTpDep)
	 	  		Help(" ",1,"ATFGETTPDP",,STR0039,1,0) //"Por favor, selecionar pelo menos um m้todo de deprecia็ใo."
			EndIf
			lTodas := Len(aSelTpDep) == Len(aSit)
		EndIf
	Else
		aSelTpDep := {"1"}
	EndIf

RestArea(aAreaSN0)
RestArea(aArea)

Return(aSelTpDep)

//-------------------------------------------------------------------
/*/{Protheus.doc} AFULTSEQ
Fun็ใo que retornar a sequ๊ncia de saldos de bens de uma ficha de ativo.
Esta fun็ใo pode funcionar por:
- Filial/C๓digo Base/Item;
- Filial/C๓digo Base/Item/Tipo do Bem;
- Filial/C๓digo Base/Item/Tipo do Bem/Tipo de Saldo;
- Filial/C๓digo Base/Item/Tipo de Saldo;

@param cSN3Fil	Filial do Bem
@param cSN3BASE	C๓digo Base do Bem
@param cSN3ITEM	C๓digo do Item do Bem
@param cSN3TIPO	Tipo do Bem
@param cSN3TPSLD	Tipo de Saldo do Bem
@param lIncrem	Se a sequencia encontrada do Bem deve ser incrementada
@param nBaixa		0=Considera os registros nใo baixados, 1=Considera os registros baixados, 2 = Olha todos os registros (Baixados e Nใo Baixados)

@return cSequencia C๓digo da sequencia de saldo de bens da ficha do ativo
@author marylly.araujo
@since 04/03/2013
@version MP11.8
/*/
//-------------------------------------------------------------------
Function AFULTSEQ(cSN3Fil,cSN3BASE,cSN3ITEM,cSN3TIPO,cSN3TPSLD,lIncrem,nBaixa)
Local aArea		:= GetArea()
Local aSN3Area	:= {}
Local cSN3Qry		:= ""
Local cSN3Als		:= ""
Local cSequencia	:= REPLICATE("0",TamSX3("N3_SEQ")[1])

DEFAULT cSN3TIPO	:= ''
DEFAULT cSN3TPSLD	:= ''
DEFAULT lIncrem	:= .F.
DEFAULT nBaixa	:= 0

DbSelectArea("SN3")
aSN3Area := SN3->(GetArea())

cSN3Qry := " SELECT "
cSN3Qry += " MAX(SN3.N3_SEQ) SEQUENCIA "
cSN3Qry += " FROM " + RetSqlName("SN3") + " SN3 "
cSN3Qry += " WHERE SN3.N3_FILIAL = '" + cSN3Fil + "' "
cSN3Qry += " AND SN3.N3_CBASE = '" + cSN3BASE + "' "
cSN3Qry += " AND SN3.N3_ITEM = '" + cSN3ITEM + "' "
If AllTrim(cSN3TIPO) <> ''
	cSN3Qry += " AND SN3.N3_TIPO = '" + cSN3TIPO + "' "
EndIf
If AllTrim(cSN3TPSLD) <> ''
	cSN3Qry += " AND SN3.N3_TPSALDO = '" + cSN3TPSLD + "' "
EndIf

If nBaixa == 1
	cSN3Qry += " AND SN3.N3_BAIXA > '0' " // Bens com baixa
ElseIf nBaixa == 0
	cSN3Qry += " AND SN3.N3_BAIXA = '0' " // Bens sem baixa
EndIf

cSN3Qry += " AND SN3.D_E_L_E_T_ = '' "

cSN3Qry := ChangeQuery(cSN3Qry)

cSN3Als := GetNextAlias()

dbUseArea(.T., "TOPCONN", TcGenQry(,, cSN3Qry ), cSN3Als, .T.,.F. )

While (cSN3Als)->(!Eof())
    cSequencia := (cSN3Als)->SEQUENCIA
    Exit
	(cSN3Als)->(DbSkip())
EndDo     
(cSN3Als)->(dbCloseArea())


/*
 * Se o parโmetro para incrementar estiver habilitado, soma um para a sequ๊ncia encontrada.
 */
If lIncrem .OR. Val(cSequencia) == 0
	/*
	 * Incrementa a seqü๊ncia para inclusใo de novo item na tabela SN3.
	 */
	cSequencia := Soma1(cSequencia)
EndIf

RestArea(aArea)
RestArea(aSN3Area)
Return(cSequencia)

/*/
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ AFSelTpPrv ณ Autor ณMauricio Pequim Jr.  ณ Data ณ 09/11/12 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ tela de selecao de ocorrencias dos movimentos da provisใo  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ ATFR490                                                    ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function AFSelTpPrv(lSelecao)

Local cTitulo	:= ""
Local cMvPar	:= ""
Local cMvParDef	:= ""
Local nI 		:= 0
Local aArea 	:= GetArea()
Local nReg	    := 0
Local nSit		:= 0
Local aSit		:= {}
Local cOcorSel	:= ""
Local cCodOcor	:= ""
Local nTamOcor	:= TAMSX3("N0_CHAVE")[1]
Local nTamOco2	:= TAMSX3("FNW_OCOR")[1]

Default lSelecao	:= .F.

nI := 1
aSit	:= {}
MvParDef := ""
cTitulo :=  STR0041  //"Selecione as Ocorr๊ncias de Movimentos de Provisใo"

DbSelectArea("SN0")
SN0->(dbSetOrder(1))
If SN0->(dbSeek( xFilial("SN0")+ "15" ))
	While !SN0->(Eof()) .And. AllTrim(SN0->N0_TABELA) == "15"
		Aadd(aSit, SN0->N0_DESC01 )
	 	cMvParDef += SN0->N0_CHAVE
		cCodOcor += SN0->N0_CHAVE +"/"
		nI++
		SN0->(dbSkip())
	EndDo
EndIf

lSelecao := AdmOpcoes(@cMvPar,cTitulo,aSit,cMvParDef,,,.F.,nTamOcor,nI,.T.)  // Chama funcao Adm_Opcoes

If lSelecao
	nSit := 1
	For nReg := 1 To len(cMvpar) Step nTamOcor  // Acumula as Ocorifica็๕es
		If SubSTR(cMvpar, nReg, nTamOcor) <> Replicate("*",nTamOcor)
	 		cOcorSel += SubSTR(cMvpar, nReg, nTamOco2) + "/"
		Endif
		nSit++
	next
Endif

If !Empty(cOcorSel)
	cOcorSel := Left(cOcorSel,Len(cOcorSel)-1)
EndIf

RestArea(aArea)

Return(cOcorSel)

/*
	{Protheus.doc}AtfSaveMvVar
	Guarda os parโmetros (mv_parXX)
	@author Fernando Radu Muscalu
	@since  19/07/2018
	@version 12
*/
Function AtfSaveMvVar()

aATFMvPar := RetMvPar()

Return()

/*
	{Protheus.doc}AtfRestMvPar
	Restaura os parโmetros que foram guradados pela fun็ใo AtfSaveMvVar
	@author Fernando Radu Muscalu
	@since  19/07/2018
	@version 12
*/

Function AtfRestMvPar()

Local nI	:= 0

If ( Len(aATFMvPar) > 0 )
	
	For nI := 1 to Len(aATFMvPar)

		&("mv_par"+cValToChar(nI)) := aATFMvPar[nI]

	Next nI

EndIf

Return()

/*
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
???Programa  ?AF010CvCol?Autor  ?Alvaro Camillo Neto ? Data ?  05/12/09   ???
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
???Desc.     ? Realiza as operacoes de conversao de tipos para localiza  ???
???          ? cao da colombia                                            ???
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
???Uso       ? ATFA010                                                 ???
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
????????????????????????????????????????????????????????????????????????
?????????????????????????????????????????s?????????????????????????????????????????
*/
Function AF010CvCol(cAlias,nReg,nOpc)


If !__lVerKernel
	__lVerKernel := VerKernel()
EndIf

Return AF010ACVCL(cAlias,nReg,nOpc)
