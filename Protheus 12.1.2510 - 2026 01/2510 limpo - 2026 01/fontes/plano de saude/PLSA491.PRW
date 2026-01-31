#include "PROTHEUS.CH"
#include "PLSMGER.CH"
#include "FWMVCDEF.CH"
#DEFINE CRLF chr( 13 ) + chr( 10 )

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA491

@author Lucas Nonato
@since  18/07/2025
@version 1.0
/*/
function PLSA491()
local aPergs		:= {}
local cAno			:= space(4)
local cMes			:= space(2)
local cRDAFil		:= space(6)
local cFilter  		:= ""
local oBrw      	:= nil
private aFilter 	:= {}

aadd(/*01*/ aPergs,{ 1,"Ano Competência",cAno,"@R 9999",'.T.',,/*'.T.'*/,40,.T. } )
aadd(/*02*/ aPergs,{ 1,"Mês Competência",cMes,"@R 99",'.T.',,/*'.T.'*/,40,.T. } )
aadd(/*03*/ aPergs,{ 1,"RDA ",cRDAFil,"@!",'.T.','BAUPLS',/*'.T.'*/,40,.F. } )

if( !paramBox( aPergs,"Filtro de Tela",aFilter,/*bOK*/,/*aButtons*/,/*lCentered*/,/*nPosX*/,/*nPosy*/,/*oDlgWizard*/,/*cLoad*/'PLSA491',/*lCanSave*/.T.,/*lUserSave*/.T. ) )
	return
endIf

cFilter := getFilter()

oBrw := FWmBrowse():New()
oBrw:SetAlias( 'BEA' )
oBrw:SetDescription( 'Recriar vinculo Proc Contas' ) 
oBrw:SetFilterDefault('@'+cFilter)
oBrw:SetMenuDef("PLSA491")
oBrw:DisableDetails()
oBrw:SetWalkThru(.F.)
oBrw:Activate()       

return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

@author Lucas Nonato
@since  18/07/2025
@version 1.0
/*/
static function MenuDef()
local aRotina := {}
	
	ADD OPTION aRotina Title 'Processar '	Action 'Processa({||PLSA491PRO()},"Recriar Guias Proc Contas","Processando...",.T.)'	OPERATION MODEL_OPERATION_INSERT ACCESS 0
		
return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} getFilter

@author Lucas Nonato
@since  18/07/2025
@version 1.0
/*/
static function getFilter()
local cFilter := ''
	
cFilter += " BEA_FILIAL = '" + xFilial("BEA") + "' "
cFilter += " AND BEA_OPEMOV = '" + plsintpad() + "' "
cFilter += " AND BEA_ANOAUT = '" + aFilter[1] + "' "
cFilter += " AND BEA_MESAUT = '" + aFilter[2] + "' "
if !empty(aFilter[3])
	cFilter += " AND BEA_CODRDA = '" + aFilter[3] + "' "
endif
cFilter += " AND BEA_CODPEG = ' ' "
cFilter += " AND BEA_CANCEL <> '1' "
cFilter += " AND BEA_STATUS IN ('1','2') "
cFilter += " AND BEA_LIBERA = '0' "
cFilter += " AND BEA_TIPGUI IN ('01','02','13') "
cFilter += " AND D_E_L_E_T_ = ' ' "
cFilter := PLSConSQL(cFilter)		

return cFilter
 
//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA491PRO

@author Lucas Nonato
@since  18/07/2025
@version 1.0
/*/
function PLSA491PRO(lAuto)
local aCols 		:= {}
local aVetTrab 		:= {}
local aHeader 		:= {}
local nOpc 			:= 3
local cMatUsa 		:= "1"
local lIntern 		:= .F.
local cNumGuia 		:= ""//preenchido só pra internação
local lAutoriz 		:= .t.
local cSituac 		:= "1"
local cCodLDP 		:= PLSRETLDP(9)
local lReanaliza 	:= .t.// só manda .f. pra GHI e GRI
local lVeioComu 	:= .F.
local lExcluiAte 	:= .t.
local lNMudFase 	:= .F.
local lReembolso 	:= .F.
local cAliasCab 	:= "BEA"
local oBrwB47 		:= nil
local lIncNeg 		:= getNewPar("MV_PLSINEG", .t.)
local cObsoleto 	:= ""
local lSolicit 		:= .F.
local lMudarFase 	:= .t.
local cAliasPri 	:= ""
local aMatCom 		:= {}
local cLotGui 		:= "" //Lote de faturamento
local lResInt 		:= .F.
local lGuiHoRe 		:= .F.
local aPartic 		:= {}
local lOdontoWeb 	:= .F.
local cArqImp 		:= ""
local lRecGlo 		:= .F.
local lWeb 			:= .T.
local notUsed 		:= nil
local lSUS 			:= .F.
local aArraySUS 	:= {}
local aDadRda 		:= {}
local lMfJob 		:= .F.
local cRdaExe 		:= ''
local lJaCobLib 	:= .F.
local lExeHatBB0 	:= .f.
local cSql 			:= ''
local cMsg 			:= ''
local cAlias 		:= Getnextalias()
local nQtd 			:= 0
local cIni 			:= ""
local cMsgFull		:= ""
default lAuto 		:= .f.

if !lAuto .and. !msgYesNo("Confirma a reanálise dos dados de faturamento?")
	return
endif
cIni := time()
PlsPtuLog("-----------------------------------------------", "recriar_proc_contas.log")
PlsPtuLog("[" + Time() + "] Inicio", "recriar_proc_contas.log")
ProcRegua(-1)
// Monta o Cabecalho
Store Header "BE2" TO aHeader for .t.

cSql := " SELECT R_E_C_N_O_ Recno FROM " + RetSqlName("BEA") + " BEA "
cSql += " WHERE " + getFilter()
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),cAlias,.F.,.T.)

while !(cAlias)->(eof())
	BEA->(dbGoTo((cAlias)->(Recno)))
	IncProc("Processando: " + BEA->BEA_OPEMOV + BEA->BEA_ANOAUT + BEA->BEA_MESAUT + BEA->BEA_NUMAUT)
	aCols 		:= {}
	aVetTrab 	:= {}
	lExeHatBB0 	:= iif(BEA->BEA_TIPGUI == '13' .and. BEA->BEA_ORIMOV == '6',.T.,.F.) 
	cRdaExe 	:= BEA->BEA_CODRDA
	aRetFun 	:= PLSDADRDA(BEA->BEA_OPEMOV,BEA->BEA_CODRDA,"1",dDataBase,,,,,,,,,,,.T.)
	aDadRda 	:= PLSGETRDA()

	PLSA090MDA(BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT),"",aHeader,aVetTrab,aCols)

	aRetMF := PLSA090MF(	BEA->BEA_OPEMOV,;
							BEA->BEA_ANOAUT,;
							BEA->BEA_MESAUT,;
							aCols,;
							aHeader,;
							nOpc,;
							cMatUsa,;
							BEA->BEA_ANOAUT,;
							BEA->BEA_MESAUT,;
							BEA->BEA_TIPGUI,;
							lIntern,;
							cNumGuia,;
							lAutoriz,;
							cSituac,;
							cCodLDP,;
							lReanaliza,;
							lVeioComu,;
							lExcluiAte,;
							lNMudFase,;
							lReembolso,;
							cAliasCab,;
							oBrwB47,;
							lIncNeg,;
							cObsoleto,;
							lSolicit,;
							lMudarFase,;
							cAliasPri,;
							aMatCom,;
							BEA->BEA_TPGRV,;
							cLotGui,;
							lResInt,;
							lGuiHoRe,;
							aPartic,;
							lOdontoWeb,;
							cArqImp,;
							lRecGlo,;
							lWeb,;
							notUsed,;
							lSUS,;
							aArraySUS,;
							aDadRda,;
							lMfJob,;
							cRdaExe,;
							lJaCobLib,;
							lExeHatBB0)
							
	cMsg := "Guia: " + BEA->BEA_OPEMOV + BEA->BEA_ANOAUT + BEA->BEA_MESAUT + BEA->BEA_NUMAUT + CRLF
	cMsg += "Protocolo: " + BEA->BEA_CODPEG + " Guia: " + BEA->BEA_NUMGUI + CRLF
	cMsg += CRLF
	cMsgFull+= cMsg
	PlsPtuLog("[" + Time() + "] "+cMsg, "recriar_proc_contas.log")
	nQtd++
	(cAlias)->(dbskip())
enddo	
(cAlias)->(dbCloseArea())
PlsPtuLog("[" + Time() + "] Fim", "recriar_proc_contas.log")
if !lAuto
	telaLog(cIni,cMsgFull,nQtd)
endif
return

//-------------------------------------------------------------------
/*/{Protheus.doc} telaLog

@author Lucas Nonato
@since  18/07/2025
@version 1.0
/*/
static function telaLog(cIni,cMsg,nQtd)
local cAux 	:= ""
local cFile	:= ""
local oMemo	:= Nil
local oDlg	:= Nil

cAux += Replicate( " ", 128 ) + CRLF
cAux += "Hora Inicio.:" + cvaltochar( cIni )  + CRLF
cAux += "Hora Fim....:" + cvaltochar( time() )  + CRLF
cAux += "Quantidade de guias recriadas: " + cvaltochar( nQtd ) + CRLF
cAux += CRLF
cAux += cMsg

Define Font oFont Name "Mono AS" Size 6, 12

Define MsDialog oDlg Title "Resumo" From 3, 0 to 340, 417 Pixel

@ 5, 5 Get oMemo Var cAux Memo Size 200, 145 Of oDlg Pixel
oMemo:bRClicked := { || AllwaysTrue() }
oMemo:oFont     := oFont

Define SButton From 153, 175 Type  1 Action oDlg:End() Enable Of oDlg Pixel
Define SButton From 153, 145 Type 13 Action ( cFile := cGetFile( "*.txt", "" ), if( cFile == "", .T., ;
MemoWrite( cFile, cAux ) ) ) Enable Of oDlg Pixel

Activate MsDialog oDlg Center

Return
