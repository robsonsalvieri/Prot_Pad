#INCLUDE "tfina01.ch"
#INCLUDE "RWMAKE.CH"     
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTFINA01   บAutor  ณEwerton C Tomaz     บ Data ณ  08/04/2002 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Programa de Liberacao de Credito Especifico                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Projeto Ewerton                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Template Function TFINA01()  

Local cFilSC9 := ""
Local nIndex

CHKTEMPLATE("DCM")  

SetPrvt("CFILSC9,CCONDICAO,CINDEX,AINDSC9,NINDSC9,NMV_PAR01")
SetPrvt("AAC,APOS,LFILTRA,AARRAYAE,LIMPMSG,AROTINA")
SetPrvt("CCADASTRO,NINDEX,LMTA450T,CQUERY,CINDSC9")
SetPrvt("CALIASSC9,LQUERY,CBLQCRED,CCODCLI,CLOJA,LCREDITO")
SetPrvt("LESTOQUE,NCNTFOR,LMVAVALEST,AAREA,NPEDIDO,NREGSC9")
SetPrvt("LCONTINUA,ATRAVAS,NOPCA,AAREASC9,CSAVSCR")
SetPrvt("CSALVFIL,NVALATRASO,CALIAS,CFILANT,NORDEM,NSCAN")
SetPrvt("NREG,LPESQUI,L450LIB,L450DUP,NQTDVEN,NQTDEST")
SetPrvt("AAREAC9,DLIMLIB,CSAVESCR,NSALDOLC,NVALITEM,NVALPED")
SetPrvt("NLIMCRED,NMOEDA,CDESCBLOQ,NSALPEDL,NSALPED,NSALDUP")
SetPrvt("BWHILE,CCONDSC9,NMCUSTO,NMOEDAAP,NDECS,LLIBERADO")
SetPrvt("LLIBER,LTRANSF,ACARL,WNREL,NSALVEMP,CDESCRI")
SetPrvt("ASALDOS,CCOLORANT,CSAVEMENUH,ABACKROT,NORDSC9,NREGSC5")
SetPrvt("NORDSC5,NREGSC6,NORDSC6,NREGSM2,NORDSM2,NREGSF4")
SetPrvt("NORDSF4,NREGSB2,NORDSB2,NREGSA1,NORDSA1,NPULA")
SetPrvt("NTOTAL1,NTOTAL2,NTOTAL3A,NTOTAL3B,NTOTAL3C,NVLGERALNF")
SetPrvt("CARQREC1,CARQREC2,CARQPED,CARQFAT,ATOTREC1,ATOTREC2")
SetPrvt("ATOTPED,ATOTFAT,CSAVESCR1,AAREASB1,AAREASB2,LMTA450CON")
SetPrvt("CPRODUTO,CLOCAL,NSTOK,CSAVSCR1,")
Private cCondicao :="",cIndex:=""
Private aIndSC9      := {}
Private nIndSC9      := 0
Private lEstoque,nmv_par01:=0
Private aAC       := { STR0001,STR0002 } //"Abandona"###"Confirma"
Private aPos      := {  8,  4, 11, 74 }
Private lFiltra   := .F.
If cPaisLoc == "ARG"
	Private aArrayAE:={}
	Private lImpMsg:=.T.
EndIf

Private aRotina := MenuDef()


Private cCadastro:= STR0005 //"Liberao de Crdito"

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ So Ped. Bloqueados   mv_par01          Sim Nao               ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Pergunte(Padr("MTA451",Len(SX1->X1_GRUPO)) ,.F.)
If !Pergunte(Padr("MTA451",Len(SX1->X1_GRUPO)) ,.T.)
	Return
EndIf

IF (ExistTemplate("M450FIL"))
	cFilSC9 := ExecTemplate("M450FIL",.f.,.f.)
Endif

If mv_par01 == 1 .Or. !Empty(cFilSC9)
	nmv_par01 := 1
	cIndex := CriaTrab(nil,.f.)
	DbSelectArea("SC9")
	cKey   := IndexKey()
	If mv_par01 == 1
		cCondicao:='C9_BLCRED<>"  ".And. C9_BLCRED<>"10" .And. C9_FILIAL=="'+xFilial("SC9")+'"'+IIF(!Empty(cFilSC9),'.and.'+cFilSC9,"")
	Else
		cCondicao:=cFilSC9
	EndIf
	IndRegua("SC9",cIndex,cKey,,cCondicao,STR0006) //"Selecionando Registros..."
	nIndex  := RetIndex("SC9")
	nIndSC9 := nIndex
	aadd(aIndSC9,{ cIndex , 1 , nIndSC9+1})
	DbSelectArea("SC9")
	#IFNDEF TOP
		DbSetIndex(cIndex+OrdBagExt())
	#ENDIF
	DbSetOrder(nIndex+1)
Endif

DbSelectArea("SC9")
If ( Bof() .And. Eof() )
	HELP(" ",1,"RECNO")
Else
	mBrowse( 7, 4,20,74,"SC9",,"C9_BLCRED")
Endif 

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDeleta os Indices Temporarios                                           ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
DbSelectArea("SC9")
If ( nMV_PAR01 == 1 )         // Variavel Utilizada no caso de Lib. Automatica
	RetIndex("SC9")
	DbClearFilter()
	For nIndex := 1 To Len(aIndSC9)
		Ferase(aIndSC9[nIndex,1]+OrdBagExt())
	Next nIndex
	DbSetOrder(1)
EndIf
Return

/*/
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun็ใo    ณ MenuDef  ณ Autor ณ Conrado Q. Gomes      ณ Data ณ 11.12.06 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Defini็ใo do aRotina (Menu funcional)                      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ MenuDef()                                                  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ TFINA01                                                    ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function MenuDef()
	Local aRotina := {	{STR0003	,"T_fa450Pesq"	,0	,1	,0	,.F.	}	,;  //"Pesquisar"
						{STR0004	,"T_fa450LibMan",0	,0	,0	,.T.	}	}   //"Manual"
Return(aRotina)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTFINA01   บAutor  ณMicrosiga           บ Data ณ  10/21/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/  

Template FUNCTION fa450LibMan(cAlias)

Local aArea		 := GetArea()
Local nPedido   := 0
Local nRegSC9   := SC9->(RecNo())
Local lContinua := .T.
Local 	nIndex  := RetIndex("SC9")
Local aTravas   := {}                     
#IFDEF TOP
	Local cFiltro 	:= ""
	Local cKey := ""
#ENDIF
CHKTEMPLATE("DCM")  

IF (ExistTemplate("MT450MAN"))
	lContinua := ExecTemplate("MT450MAN",.f.,.f.)
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerifica se o registro posicionado eh valido                            ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If ( SC9->C9_BLCRED == "10" .Or. SC9->C9_BLEST == "10" )
	HELP(" ",1,"A450NFISCA")
	Return
EndIf
If ( SC9->C9_BLCRED == "  " .And. SC9->C9_BLEST == "  " )
	Help(" ",1,"A450JALIB")
	Return
EndIf
If ( Empty(SC9->C9_BLCRED) .And. !Empty(SC9->C9_BLEST) )
	Help(" ",1,"A450ESTOQ")
	Return
EndIf
nOpcA := fa450Tela( @lContinua , @aTravas , .T. , .F.)
If ( lContinua )
	#IFDEF TOP
	  IF TcSrvType() == "AS/400"
	     DbSelectArea("SC9")
	     cFiltro := dbFilter()
	     cKey := IndexKey()
		 DbClearFilter()
	     DbSetOrder(1)
	  EndIf
	#ENDIF
	If ( nOpcA == 1 )
		T_fa450Grava(1,.T.,.F.,.F.)
		IF (existTemplate("MTA450I"))
			ExecTemplate("MTA450I",.f.,.f.)
		EndIf
	ElseIf nOpcA == 3
		T_fa450Grava(2,.T.,.F.,.F.)

	IF (ExistTemplate("MTA450R"))
		ExecTemplate("MTA450R",.f.,.f.)
	EndIf

	ElseIf nOpcA == 4
		nPedido := SC9->C9_PEDIDO
		DbSelectArea("SC9")  
		DbSetOrder(1)
		DbSeek(cFilial+nPedido)
		While ( !Eof() .And. SC9->C9_FILIAL == xFilial("SC9") .And.;
				 SC9->C9_PEDIDO == nPedido )
			If ( Empty(SC9->C9_BLCRED) .Or. SC9->C9_BLCRED == "10" )
				DbSkip()
				Loop
			EndIf
			T_fa450Grava(1,.T.,.F.,.F.)
			DbSelectArea("SC9")
			If (existTemplate("MTA450I"))
				ExecTemplate("MTA450I",.f.,.f.)
			EndIf
			DbSkip()
		End
	EndIf                       
	#IFDEF TOP
	  IF TcSrvType() == "AS/400"
	     DbSelectArea("SC9")
	     IndRegua("SC9","",cKey,,cFiltro,)
	  EndIf
	#ENDIF
EndIf
MsUnlockAll()
If ( nmv_par01 == 1 )
	DbSelectArea("SC9")
	DbSetOrder(nIndex+1)
EndIf
DbSelectArea("SC9")
MsGoto(nRegSC9)
If ( Deleted() )
	DbSkip()
EndIf
RestArea(aArea)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFSomaAtrasoบAutor  ณVendas Clientes     บ Data ณ  10/21/05   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ           	                                               บฑฑ
ฑฑบ          ณ                                                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                          บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function FSomaAtraso(cFilNew)
Local cSalvFil 	 := cFilAnt
Local nValAtraso := 0
Local cAlias 	 := Alias()

cFilAnt := cFilNew

DbSelectArea("SE1")
DbSetOrder(8)
DbSeek(cFilial+SA1->A1_COD+SA1->A1_LOJA+"A")
While ( !Eof() .And. SE1->E1_FILIAL == xFilial("SE1") .And. ;
			SE1->E1_CLIENTE+SE1->E1_LOJA == SA1->A1_COD+SA1->A1_LOJA .And.;
			SE1->E1_STATUS == "A" )
	If ( dDataBase > SE1->E1_VENCREA )
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Caso o tกtulo seja de qualquer natureza credora (-) o saldo  ณ
		//ณ deve ser abatido. Os tกtulos tipo RA (Receb.Antecipado),     ณ
		//ณ NCC (Nota de Crdito) e PR (Provisขrio) no precisam de      ณ
		//ณ tratamento especial. Bops 00323-A                            ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If Subst(SE1->E1_TIPO,3,1) == "-"
			nValAtraso += xMoeda( SE1->E1_SALDO , SE1->E1_MOEDA , 1 )
		ElseIF .NOT. SE1->E1_TIPO $ "RA /PR /"+MV_CRNEG
			nValAtraso -= xMoeda( SE1->E1_SALDO , SE1->E1_MOEDA , 1 )
		Endif
	EndIf
	DbSkip()
End
DbSetOrder(1)
cFilAnt := cSalvFil
DbSelectArea(cAlias)
Return (nValAtraso)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFa450Pesq  บAutor  ณVendas Clientes     บ Data ณ  10/21/05   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ           	                                               บฑฑ
ฑฑบ          ณ                                                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                          บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Template Function Fa450Pesq(lPesqui)

CHKTEMPLATE("DCM")  

lPesqui := If(ValType(lPesqui)<>"L",.T.,lPesqui)

If ( lPesqui )
	AxPesqui()
Else
	DbSetOrder(1)
		IndRegua("SC9",cIndex,IndexKey(),,cCondicao,STR0006)       //"Selecionando Registros..."
EndIf

Return(.T.)   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFa450Pesq  บAutor  ณVendas Clientes     บ Data ณ  10/21/05   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ           	                                               บฑฑ
ฑฑบ          ณ                                                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                          บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Template Function fa450Grava(nOpc,lAtuCred,lAtuEst,lBloqEst)

Local l450Lib  := IF(SuperGetMv("MV_LIBNODP")=="S",.T.,.F.)
Local l450Dup  := .F.
Local nQtdVen  := 0
Local nQtdEst	:= 0
Local aArea    := GetArea()
Local aAreaC9  := SC9->(GetArea())
Local lEstoque := .F.
Local lCredito := Empty(SC9->C9_BLCRED)
Local lMvAvalEst:= GetNewPar("MV_AVALEST",1)==2

CHKTEMPLATE("DCM")  

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณPosiciona Registros                                                     ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
DbSelectArea("SC5")
DbSetOrder(1)
DbSeek(xFilial("SC5")+SC9->C9_PEDIDO)

DbSelectArea("SC6")
DbSetOrder(1)
DbSeek(xFilial("SC6")+SC9->C9_PEDIDO+SC9->C9_ITEM+SC9->C9_PRODUTO)

DbSelectArea("SA1")
DbSetOrder(1)
DbSeek(xFilial("SA1")+SC9->C9_CLIENTE+SC9->C9_LOJA)

DbSelectArea("SF4")
DbSetOrder(1)
DbSeek(xFilial("SF4")+SC6->C6_TES)

DbSelectArea("SB2")
DbSetOrder(1)
DbSeek(cFilial+SC6->C6_PRODUTO+SC6->C6_LOCAL)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณLiberacao do SC9                                                        ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If ( nOpc == 1 )
	Begin Transaction
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณTravamento dos Registros                                                ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If !(SC5->C5_TIPO $ "DB")
		RecLock("SA1",.F.)
	EndIf
	RecLock("SC5",.F.)
	RecLock("SC6",.F.)
	RecLock("SC9",.F.)
	If ( SB2->(Found()) )
		RecLock("SB2",.F.)
	EndIf
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณCalcula a quantidade disponivel em estoque                              ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	nQtdEst := SC9->C9_QTDLIB
	If Empty(SC9->C9_RESERVA) .AND. !Empty(SC9->C9_LOCAL) // Especifico
	   If SC9->C9_BLEST <> '02'
  	      lEstoque := A440VerSB2(@nQtdEst,lMvAvalEst) 
  	   Else   
          nQtdEst := 0
  	   Endif   
	Else
       lEstoque := .T.
	EndIf
	If ( nQtdEst == 0 )
		nQtdEst  := SC9->C9_QTDLIB
		lEstoque := .F.
	EndIf
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณAvaliacao de Credito                                                    ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If ( lAtuCred .And. !Empty(SC9->C9_BLCRED) )
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณRetira o Bloqueio de Credito                                            ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		lCredito := .T.
		SC9->C9_BLCRED := "  "
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Atualiza saldo de pedidos no arquivo de clientes             ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If At(SC5->C5_TIPO,"DB") == 0
			If (  SC6->C6_CLI 	== SA1->A1_COD .And.;
				SC6->C6_LOJA	== SA1->A1_LOJA )
				If ( (!l450lib .And. SF4->F4_DUPLIC == "S") .Or. (l450Lib) )
					l450dup := .T.
				EndIf
				IF ( l450Dup )
					SA1->A1_SALPEDB -= xMoeda( SC9->C9_QTDLIB*SC9->C9_PRCVEN,SC5->C5_MOEDA,Val(SuperGetMv("MV_MCUSTO")),SC9->C9_DATALIB)
					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณRegrava a quantidade empenha quando solicitado                          ณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
					If ( lMvAvalEst )
						SC6->C6_QTDEMP -= SC9->C9_QTDLIB
						SC9->C9_QTDLIB := nQtdEst
						SC6->C6_QTDEMP += SC9->C9_QTDLIB
					EndIf
					SA1->A1_SALPEDL += xMoeda( SC9->C9_QTDLIB*SC9->C9_PRCVEN,SC5->C5_MOEDA,Val(SuperGetMv("MV_MCUSTO")),SC9->C9_DATALIB)
				EndIf
			EndIf
		EndIf
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณApos a liberacao de credito deve-se bloquear o estoque para posterior   ณ
		//ณavaliacao.                                                              ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
       IF FunName() <> "#TFINA01"  // Especifico        
          SC9->C9_BLEST := "02"
       Endif   
       
	EndIf
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณAvaliacao do Estoque                                                    ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
    
    IF FunName() = "#TFINA01" // Especifico                                   
       lAtuEst  := .F.
       lEstoque := .F.
    Endif

    IF Empty(SC9->C9_LOCAL) // Especifico                                   
       lAtuEst       := .F.
       lEstoque      := .F.           
       SC9->C9_BLEST := "  "  
	   SC6->C6_BLQ   := " "       
    Endif

    IF FunName() = "#TESTA06" .AND. !lBloqEst // Especifico                                   
       lEstoque := .T.
    Endif    

    IF FunName() = "MATA100" 
       //T_fGravaLOG("MT100AGR INICIO - ENTRADA NF",SC9->C9_PEDIDO,SC9->C9_PRODUTO,SC9->C9_LOCAL,nQtdEst) // Log
    Endif   
    
	If !( Rastro(SC9->C9_PRODUTO) .Or. Localiza(SC9->C9_PRODUTO) .Or. !Empty(SC9->C9_RESERVA) )
	   If  lAtuEst .Or. lEstoque // Especifico 			
       
           IF FunName() = "MATA100" 
              //T_fGravaLOG("MT100AGR MEIO - ENTRADA NF",SC9->C9_PEDIDO,SC9->C9_PRODUTO,SC9->C9_LOCAL,nQtdEst) // Log
           Endif   

			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณRetira o Bloqueio de Estoque                                            ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			SC9->C9_BLEST := "  "
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณRetira  o Bloqueio do SC6                                               ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			SC6->C6_BLQ := " "
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ Atualiza o campo B2_QPEDVEN do arquivo de saldos     ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			DbSelectArea("SB2")
			DbSetOrder(1)
			If DbSeek(cFilial+SC6->C6_PRODUTO+SC6->C6_LOCAL)
			   If SF4->F4_ESTOQUE == "S"
				  SB2->B2_RESERVA += ( SC9->C9_QTDLIB-SC9->C9_QTDRESE )
 				  If SuperGetMv("MV_LIBACIM")
				     If SC6->C6_OP $ "01#03#05"
 					    SB2->B2_QEMPN -= ( SC9->C9_QTDLIB )
				     EndIf
				     SB2->B2_QPEDVEN -= ( SC9->C9_QTDLIB-SC9->C9_QTDRESE )
				  Else
				     nQtdVen := IIf( SC9->C9_QTDLIB > ( SC6->C6_QTDVEN - ;
				                    ( SC6->C6_QTDEMP - SC9->C9_QTDLIB )    - ;
				                    SC6->C6_QTDENT ) , SC6->C6_QTDVEN      - ;
				                    ( SC6->C6_QTDEMP - SC9->C9_QTDLIB )    - ;
				                    SC6->C6_QTDENT , SC9->C9_QTDLIB )
				     If SC6->C6_OP $ "01#03#05"
					    SB2->B2_QEMPN -= ( nQtdVen )
				     Endif
				     SB2->B2_QPEDVEN -= ( nQtdVen-SC9->C9_QTDRESE )
				  EndIf
 	             
 	             IF FunName() = "MATA100" 
                    //T_fGravaLOG("MT100AGR ESTOQUE - ENTRADA NF",SC9->C9_PEDIDO,SC9->C9_PRODUTO,SC9->C9_LOCAL,nQtdEst) // Log
                 Endif   
                 
			   Endif  			   
			EndIf
		EndIf
	Else
		If ( lEstoque )
			SC9->(a460Estorna())
			MaLibDoFat(SC6->(RecNo()),SC9->C9_QTDLIB,@lCredito,@lEstoque,!Empty(SC9->C9_BLCRED),!Empty(SC9->C9_BLEST),.F.,.F.)
		EndIf
		If ( (lAtuEst .And. !Empty(SC9->C9_BLEST)) )
			Help(" ",1,"", "A455LIBMAN", STR0007, 1, 1 ) //"Liberacao manual de estoque nao permitida."
		EndIf
	EndIf
	SC6->C6_OP := If(SC6->C6_OP=="  ","02",If(SC6->C6_OP=="01",If(SC6->C6_QTDVEN-SC6->C6_QTDEMP-SC6->C6_QTDENT>0,SC6->C6_OP,"03"),If(SC6->C6_OP=="05",If(SC6->C6_QTDVEN-SC6->C6_QTDEMP-SC6->C6_QTDENT>0,SC6->C6_OP,"06"),SC6->C6_OP)))
	End Transaction
Else
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณRejeicao do SC9                                                         ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Begin Transaction
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณTravamento dos Registros                                                ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	RecLock("SA1",.F.)
	RecLock("SC5",.F.)
	RecLock("SC6",.F.)
	RecLock("SC9",.F.)
	If ( Empty(SC9->C9_BLCRED) )
		If At(SC5->C5_TIPO,"DB") == 0
			If ( SC6->C6_CLI	== SA1->A1_COD .And.;
				SC6->C6_LOJA== SA1->A1_LOJA )
				If ( (!l450lib .And. SF4->F4_DUPLIC == "S") .Or. (l450Lib) )
					l450dup := .T.
				EndIf
				If ( l450Dup )
					SA1->A1_SALPEDB += xMoeda( SC9->C9_QTDLIB*SC9->C9_PRCVEN,SC5->C5_MOEDA,Val(SuperGetMv("MV_MCUSTO")),SC9->C9_DATALIB)
					SA1->A1_SALPEDL -= xMoeda( SC9->C9_QTDLIB*SC9->C9_PRCVEN,SC5->C5_MOEDA,Val(SuperGetMv("MV_MCUSTO")),SC9->C9_DATALIB)
				EndIf
			EndIf
		EndIf
	EndIf
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณEfetua o Bloqueio de Credito por Rejeicao                               ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	SC9->C9_BLCRED := "09"
	End Transaction
EndIf
RestArea(aAreaC9)
RestArea(aArea)
Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFa450Tela  บAutor  ณVendas Clientes     บ Data ณ  10/21/05   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ           	                                               บฑฑ
ฑฑบ          ณ                                                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                          บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function Fa450Tela(lContinua , aTravas , lAvCred , lAvEst)

Local dLimLib  := dDataBase, cSaveMenuh
Local nSaldoLC := 0
Local nValItem := 0
Local nValPed  := 0
Local nLimCred := 0
Local nMoeda   := 0
Local nQtdVen  := 0
Local cDescBloq:= ""
Local nSalPedL := 0
Local nSalPed  := 0
Local nValAtraso:= 0
Local oBtn
Local oDlg
Local nOpca 	:= 0
Local nSalvEmp
Local nSalDup	:= 0
Local cDescri
Local nCntFor   := 0
Local bWhile    := Nil
Local cCondSC9  := ""
Local nMCusto   := Val(SuperGetMv("MV_MCUSTO"))
Local nMoedaAp  := GetNewPar("MV_APRESLC",1)
Local	nDecs		 := MsDecimais(nMoedaAp)
Local aSaldos
Local lLiberado := .F.
Local aArea     := { Alias() , IndexOrd() , Recno() }
Local aAreaSC9  := { SC9->(IndexOrd()) , SC9->(RecNo()) }
Private lLiber  := .F., lTransf := .F.
Private aCARL   := { STR0002,STR0001,STR0008,STR0009 } //"Confirma"###"Abandona"###"Rejeita"###"Libera todo o Pedido"
Private aPos    := {  8,  4, 11, 74 }

Private cCadastro := STR0010 //"Consulta Posio Clientes"

Private wnrel := "FINC010"
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณPosiciona no SC5                                                        ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If ( lContinua )
	DbSelectArea("SC5")
	DbSetOrder(1)
	If dBSeek(xFilial("SC5")+SC9->C9_PEDIDO)
		If !SoftLock("SC5")
			lContinua := .F.
		Else
			aadd(aTravas,{ Alias() , RecNo() })
		EndIf
	EndIf
EndIf
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerifica o Tipo de Analize                                              ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If ( SC5->C5_TIPLIB=="2" )
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณQuando for por PV deve-se somar todos os SC9 gerados para o item        ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	DbSelectArea("SC9")
	DbSetOrder(1)
	DbSeek(xFilial("SC9")+SC9->C9_PEDIDO)
	cCondSC9 := SC9->C9_PEDIDO
	bWhile := {|| xFilial("SC9") == SC9->C9_FILIAL .And. cCondSC9 == SC9->C9_PEDIDO }
Else
	cCondSC9 := SC9->C9_PEDIDO+SC9->C9_ITEM+SC9->C9_SEQUEN
	bWhile   := {|| xFilial("SC9") == SC9->C9_FILIAL .And. cCondSC9 == SC9->C9_PEDIDO+SC9->C9_ITEM+SC9->C9_SEQUEN }
EndIf
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerifica o tipo de analise a ser efetuado ( Filial ou Matriz )    ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If ( SuperGetMv("MV_CREDCLI") == "L" )
	DbSelectArea("SA1")           // Posiciona cliente
	DbSetOrder(1)
	DbSeek(cFilial+SC5->C5_CLIENTE+SC5->C5_LOJACLI)
	nLimCred := xMoeda(SA1->A1_LC,nMCusto,1,dDatabase)
	nSalPed  := xMoeda(SA1->A1_SALPED,nMCusto,1,dDataBase) + xMoeda(SA1->A1_SALPEDB,nMCusto,1,dDataBase)
	nSalPedL := xMoeda(SA1->A1_SALPEDL,nMCusto,1,dDataBase)
	nSalDup  := SA1->A1_SALDUP
Else
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณSoma-se Todos os Limites de Credito do Cliente          ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	DbSelectArea("SA1")
	DbSetOrder(1)
	DbSeek(xFilial("SA1")+SC5->C5_CLIENTE)
	While ( !Eof() .And. xFilial("SA1") == SA1->A1_FILIAL .And.;
			SC5->C5_CLIENTE ==  SA1->A1_COD )
		nLimCred += xMoeda(SA1->A1_LC,nMCusto,1,dDatabase)
		nSalPed  += xMoeda(SA1->A1_SALPED,nMCusto,1,dDataBase)+xMoeda(SA1->A1_SALPEDB,nMCusto,1,dDataBase)
		nSalPedL += xMoeda(SA1->A1_SALPEDL,nMCusto,1,dDataBase)
		nSalDup  += SA1->A1_SALDUP
		DbSelectArea("SA1")
		DbSkip()
	End
EndIf
nSaldoLC := ( nLimCred - nSalDup - nSalPedL )
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณAnalisar o atraso de Todas as Filiais do Sistema                        ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
nSalvEmp := SM0->(Recno())
DbSelectArea("SM0")
DbSeek(cEmpAnt)
While !Eof() .and. M0_CODIGO == cEmpAnt
	If ( SuperGetMv("MV_CREDCLI")=="L" )
		nValAtraso += FSomaAtraso(SM0->M0_CODFIL)
	Else
		DbSelectArea("SA1")
		DbSetOrder(1)
		DBSeek(xFilial("SA1")+SC5->C5_CLIENTE)
		While ( !Eof() .And. xFilial("SA1")  == SA1->A1_FILIAL .And.;
				SC5->C5_CLIENTE == SA1->A1_COD )
			nValAtraso += FSomaAtraso(SM0->M0_CODFIL)
			DbSelectArea("SA1")
			DbSkip()
		End
	EndIf
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Forca a saida quando o SE1 estiver compartilhado               ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If ( xFilial("SE1") == Space(2) )
		Exit
	EndIf
	DbSelectArea("SM0")
	DbSkip()
End
DbSelectArea("SM0")
DbGoto(nSalvEmp)
DbSelectArea("SA1")           // Posiciona cliente
DbSetOrder(1)
DBSeek(cFilial+SC5->C5_CLIENTE+SC5->C5_LOJACLI)
DbSelectArea("SC9")
While ( !Eof() .And. Eval(bWhile) .And. lContinua)
	If (  SC9->C9_BLCRED <> "10" .And. SC9->C9_BLEST <> "10" .And.;
			(If(lAvCred,!Empty(SC9->C9_BLCRED),.F.) .Or.;
			If(lAvEst,!Empty(SC9->C9_BLEST),.F.)) )
		lLiberado := .T.
		If !SoftLock("SC9")
			lContinua := .F.
		Else
			aadd(aTravas,{ Alias() , RecNo() })
		EndIf
		If ( lContinua )
			DbSelectArea("SC9")
			If ( SC5->C5_TIPO $ "DB" )
				Help(" ",1,"A450NCRED")
				lContinua := .F.
			EndIf
		EndIf
		If ( lContinua )
			DbSelectArea("SC6")           // Posiciona item do pedido
			DbSetOrder(1)
			DbSeek(cFilial+SC9->C9_PEDIDO+SC9->C9_ITEM+SC9->C9_PRODUTO)

			DbSelectArea("SM2")           // Posiciona moeda da data base
			DbSetOrder(1)
			DbSeek(dDataBase,.T.)

			DbSelectArea("SC9")
			nMoeda   := Iif(SC5->C5_MOEDA < 2,1,SC5->C5_MOEDA)
			nValItem := xMoeda((SC6->C6_PRCVEN * SC9->C9_QTDLIB),nMoeda,1,dDataBase)
			nValPed  += nValItem
			nSalPed  -= nValItem
			nSalPed  := IIf( nSalped < 0 , 0 , nSalPed )
		EndIf
	EndIf
	DbSelectArea("SC9")
	DbSkip()
End
DbSelectArea("SC9")
DbGoto(aAreaSC9[2])
If ( !lLiberado )
	Help(" ",1,"A450JALIB")
EndIf
If ( lContinua .And. lLiberado )
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Reposiciona o SA1                                                      ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	DbSelectArea("SA1")
	DbSetOrder(1)
	DbSeek(cFilial+SC5->C5_CLIENTE+SC5->C5_LOJACLI)
	If ( SC9->C9_BLCRED == "01" )
		cDescBloq := STR0011   //"Crdito"
	ElseIf SC9->C9_BLCRED == "04"
		cDescBloq := STR0012   //"Limite de Crdito Vencido"
	ElseIf SC9->C9_BLCRED == "09"
		cDescBloq := STR0013   //"Rejeitado"
	ElseIF !Empty(SC9->C9_BLEST)
		cDescBloq := STR0014   //"Estoque"
	EndIf
	cDescri := Substr(SA1->A1_NOME,1,35)
	//Converte os valores para a moeda escolhida pelo parametro MV_APRESLC
	aSaldos		:=	Array(10)
	aSaldos[1]	:=	xMoeda(nLimCred,1,nMoedaAp)
	aSaldos[2]	:=	xMoeda(SA1->A1_SALDUP,1,nMoedaAp)
	aSaldos[3]	:=	xMoeda(nSalPedl,1,nMoedaAp)
	aSaldos[4]	:=	xMoeda(SA1->A1_MCOMPRA,nMCusto,nMoedaAp)
	aSaldos[5]	:=	xMoeda(nSaldoLc,1,nMoedaAp)
	aSaldos[6]	:=  xMoeda(SA1->A1_MAIDUPL,nMCusto,nMoedaAp)
	aSaldos[7]	:=	xMoeda(nValItem,1,nMoedaAp)
	aSaldos[8]	:=	xMoeda(nValPed,1,nMoedaAp)
	aSaldos[9]	:=	xMoeda(nSalPed,1,nMoedaAp)
	aSaldos[10]	:=	xMoeda(nValAtraso,1,nMoedaAp)

	DEFINE MSDIALOG oDlg FROM  125,3 TO 420,608 TITLE STR0005 PIXEL   //"Liberao de Crdito"

	@ 038, 004  TO 115, 135 //LABEL ""
	@ 038, 139  TO 115, 295 //LABEL ""
	@ 003, 004  TO 033, 295 //LABEL ""
	@ 120, 004  TO 140, 155 //LABEL ""
	@ 120, 160  TO 140, 240 //LABEL ""

	DEFINE SBUTTON FROM 124, 242 TYPE 1 ACTION (nOpca := 1,oDlg:End()) ENABLE OF oDlg
	DEFINE SBUTTON FROM 124, 272 TYPE 2 ACTION oDlg:End() ENABLE OF oDlg

	@ 125, 010 BUTTON  (STR0015) SIZE 34,11 ACTION (fa450F4con(),cCadastro:= (STR0016) )            //"Consulta"###"Liberao de Credito"
	@ 125, 045 BUTTON  (STR0017) SIZE 34,11 ACTION (cCadastro:= (STR0017),AxVisual("SA1",SA1->(RecNo()),1),cCadastro:=  (STR0016) )  //"Cliente"###"Cliente"###"Liberao de Credito"
	@ 125, 080 BUTTON  (STR0018) SIZE 34,11 ACTION (cCadastro:= (STR0018),a410Visual("SC5",SC5->(RecNo()),1),cCadastro:=  (STR0016) )  //"Pedido"###"Pedido"###"Liberao de Credito"
	@ 125, 115 BUTTON  (STR0014) SIZE 34,11 ACTION (fa450ConEst() )   //"Estoque"
	@ 125, 165 BUTTON  (STR0019) SIZE 34,11 ACTION (nOpca := 4,oDlg:End() )  //"Lib.Todos"
	@ 125, 200 BUTTON  (STR0008) SIZE 34,11 ACTION (nOpca := 3,oDlg:End() )  //"Rejeita"
	@ 010, 011 SAY (STR0020)					SIZE 23, 7    //"Pedido :"
	@ 010, 040 SAY SC9->C9_PEDIDO			SIZE 26, 7
	@ 010, 090 SAY (STR0021)					SIZE 35, 7  //"Cond.Pagto. :"
	@ 010, 128 SAY SC5->C5_CONDPAG			SIZE 09, 7
	@ 010, 170 SAY (STR0022)					SIZE 27, 7  //"Bloqueio :"
	@ 010, 201 SAY cDescBloq					SIZE 83, 7
	@ 021, 011 SAY (STR0023)					SIZE 23, 7    //"Cliente :"
	@ 021, 040 SAY cDescri					SIZE 96, 7
	@ 021, 170 SAY (STR0024)					SIZE 21, 7    //"Risco :"
	@ 021, 201 SAY SA1->A1_RISCO			SIZE 11, 7
	@ 021, 240 SAY (STR0025+&("MV_SIMB"+Alltrim(STR(nMoedaAp))))	SIZE 40, 7    //"Valores em "
	@ 044, 012 SAY (STR0026)					SIZE 53, 7      //"Limite de Credito :"
	@ 044, 071 SAY aSaldos[1]				SIZE 59, 7		PICTURE PesqPict("SA1","A1_LC",18,nMoedaAp)
	@ 044, 145 SAY (STR0027)					SIZE 61, 7      //"Titulos Protestados :"
	@ 044, 212 SAY SA1->A1_TITPROT			SIZE 18, 7		PICTURE PesqPict("SA1","A1_TITPROT",18,nMoedaAp)
	@ 044, 240 SAY ("Em")					SIZE 11, 7
	@ 044, 256 SAY DTOC(SA1->A1_DTULTIT)	SIZE 33, 7
	@ 053, 012 SAY (STR0028)					SIZE 53, 7      //"Saldo Duplicatas :"
	@ 053, 071 SAY aSaldos[2]				SIZE 59, 7		PICTURE PesqPict("SA1","A1_SALDUP",18,nMoedaAp)
	@ 053, 145 SAY (STR0029)					SIZE 62, 7      //"Cheques Devolvidos :"
	@ 053, 212 SAY SA1->A1_CHQDEVO			SIZE 18, 7		PICTURE PesqPict("SA1","A1_CHQDEVO",18)
	@ 053, 240 SAY (STR0030)					SIZE 10, 7      //"Em"
	@ 053, 256 SAY DTOC(SA1->A1_DTULCHQ)	SIZE 33, 7
	@ 062, 012 SAY (STR0031)					SIZE 53, 7      //"Pedidos Liberados :"
	@ 062, 071 SAY aSaldos[3]				SIZE 59, 7		PICTURE Tm(aSaldos[4],18,nDecs)
	@ 062, 145 SAY (STR0032)					SIZE 53, 7      //"Maior Compra :"
	@ 062, 212 SAY aSaldos[4]				SIZE 59, 7		PICTURE PesqPict("SA1","A1_MCOMPRA",18,nMoedaAp)
	@ 071, 012 SAY (STR0033)					SIZE 53, 7      //"Saldo Lim.Credito :"
	@ 071, 071 SAY aSaldos[5]				SIZE 59, 7		PICTURE PesqPict("SA1","A1_LC",18,nMoedaAp)
	@ 071, 145 SAY (STR0034)					SIZE 53, 7      //"Maior Duplicata :"
	@ 071, 212 SAY aSaldos[6]				SIZE 59, 7		PICTURE PesqPict("SA1","A1_MAIDUPL",18,nMoedaAp)
	@ 079, 012 SAY (STR0035)					SIZE 53, 7      //"Item Pedido Atual :"
	@ 079, 071 SAY aSaldos[7]				SIZE 59, 7		PICTURE Tm(aSaldos[7],18,nDecs)
	@ 079, 212 SAY SA1->A1_METR				SIZE 18, 7		PICTURE PesqPict("SA1","A1_METR",6)
	@ 079, 242 SAY ("dias")					SIZE 25, 7
	@ 079, 145 SAY (STR0036)					SIZE 53, 7      //"Mdia Atrasos :"
	@ 087, 012 SAY (STR0037)					SIZE 53, 7      //"Pedido Atual :"
	@ 087, 071 SAY aSaldos[8]				SIZE 59, 7		PICTURE Tm(aSaldos[8],18,nDecs)
	@ 087, 145 SAY (STR0038)					SIZE 60, 7      //"Vencto.Lim.Credito :"
	@ 087, 212 SAY DTOC(SA1->A1_VENCLC)	SIZE 33, 7
	@ 096, 012 SAY (STR0039)					SIZE 53, 7      //"Saldo de Pedidos :"
	@ 096, 071 SAY aSaldos[9]				SIZE 59, 7		PICTURE PesqPict("SA1","A1_SALPED",18,nMoedaAp)
	@ 096, 145 SAY (STR0040)					SIZE 64, 7      //"Data Limite Liberaao :"
	@ 096, 212 GET dLimLib					SIZE 52, 7
	@ 105, 012 SAY (STR0041)					SIZE 53, 7      //"Atraso Atual :"
	@ 105, 071 SAY aSaldos[10]				SIZE 59, 7		PICTURE Tm(aSaldos[10],18,nDecs)
	ACTIVATE MSDIALOG oDlg
EndIf

DbSelectArea("SC9")
DbSetOrder(aAreaSC9[1])
DbGoto(aAreaSC9[2])

DbSelectArea(aArea[1])
DbSetOrder(aArea[2])
DbGoto(aArea[3])
Return(nOpcA)


Static Function fa450F4Con()
//Local cAlias := Alias()
Local aBackRot := aClone(aRotina)
Local nRegSC9 := SC9->(Recno())
Local nOrdSC9 := SC9->(IndexOrd())
Local nRegSC5 := SC5->(Recno())
Local nOrdSC5 := SC5->(IndexOrd())
Local nRegSC6 := SC6->(Recno())
Local nOrdSC6 := SC6->(IndexOrd())
Local nRegSM2 := SM2->(Recno())
Local nOrdSM2 := SM2->(IndexOrd())
Local nRegSF4 := SF4->(Recno())
Local nOrdSF4 := SF4->(IndexOrd())
Local nRegSB2 := SB2->(Recno())
Local nOrdSB2 := SB2->(IndexOrd())
Local nRegSA1 := SA1->(Recno())
Local nOrdSA1 := SA1->(IndexOrd())

Private nPula := 180        //Variaveis usada no FINC010
Private nTotal1 := 0, nTotal2 :=0, nTotal3a := 0,;
		  nTotal3b:= 0, nTotal3c:= 0, nVlGeralNf:= 0
Private cArqRec1  := ""
Private cArqRec2  := ""
Private cArqPed   := ""
Private cArqFat   := ""
Private aTotRec1  := {0,0}
Private aTotRec2  := {0,0}
Private aTotPed   := {0,0,0,0}
Private aTotFat   := {0,0}

DbSelectArea("SA1")

If !( Pergunte(Padr("FIC010",Len(SX1->X1_GRUPO)) ,.T.) )
	Return(.F.)
EndIf

Fc010Con()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Restaura a integridade dos dados                     ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

DbSelectArea("SA1")
DbSetOrder(nOrdSA1)
MsGoto( nRegSA1 )

DbSelectArea("SC5")
DbSetOrder(nOrdSC5)
MsGoto( nRegSC5 )

DbSelectArea("SC6")
DbSetOrder(nOrdSC6)
MsGoto( nRegSC6 )

DbSelectArea("SM2")
DbSetOrder(nOrdSM2)
MsGoto( nRegSM2 )

DbSelectArea("SF4")
DbSetOrder(nOrdSF4)
MsGoto( nRegSF4 )

DbSelectArea("SB2")
DbSetOrder(nOrdSB2)
MsGoto( nRegSB2 )

DbSelectArea("SC9")
DbSetOrder(nOrdSC9)
MsGoto( nRegSC9 )

aRotina := aClone(aBackRot)

Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFa450ConEstบAutor  ณVendas Clientes     บ Data ณ  10/21/05   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ           	                                               บฑฑ
ฑฑบ          ณ                                                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                          บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function Fa450ConEst()
Local aArea		:= GetArea()
Local aAreaSB1  := SB1->(GetArea())
Local aAreaSB2  := SB2->(GetArea())
Local lMta450Con:= (ExistTemplate("MTA450CO"))
Local cProduto	:= SC6->C6_PRODUTO
Local cLocal	:= SC6->C6_LOCAL
Local nStok     := 0

If lMta450Con
	ExecTemplate("MTA450CO",.f.,.f.)
Else
	DbSelectArea("SB1")
	DbSetOrder(1)
	If ( DbSeek(xFilial("SB1")+cProduto,.F.) )
		DbSelectArea("SB2")
		DbSetOrder(1)
		If DbSeek(xFilial("SB2")+cProduto+cLocal,.F.)
			nStok:= SaldoSb2()
		EndIf
			DEFINE MSDIALOG oDlg FROM  62,1 TO 293,365 TITLE STR0042 PIXEL				 //"POSI€AO DO ESTOQUE"
			@ 0, 2 TO 28, 181 //LABEL ""  
			@ 31, 2 TO 91, 181 //LABEL ""  
			@ 8, 4 SAY STR0043 SIZE 31, 7  			 //"Produto :"
			@ 7, 39 SAY cProduto + " /" + Subs(SB1->B1_DESC,1,20) SIZE 140, 7  
			@ 16, 5 SAY STR0044 SIZE 31, 7  		 //"Local    :"
			@ 16, 39 SAY cLocal SIZE 13, 7  
			@ 37, 9 SAY STR0045 SIZE 92, 7  			 //"Pedido de Vendas em Aberto"
			@ 37, 118 SAY B2_QPEDVEN  SIZE 53, 7  
			@ 45, 9 SAY STR0046 SIZE 88, 7  			 //"Quantidade Empenhada"
			@ 45, 118 SAY B2_QEMP SIZE 53, 7  
			@ 53, 9 SAY STR0047 SIZE 88, 7  			 //"Qtd.Prevista p/Entrar"
			@ 53, 118 SAY B2_SALPEDI SIZE 53, 7  
			@ 61, 9 SAY STR0048 SIZE 88, 7  	 //"Quantidade Reservada (A)"
			@ 61, 118 SAY B2_RESERVA SIZE 53, 7  
			@ 69, 9 SAY STR0049 SIZE 53, 7  			 //"Saldo Atual (B)"
			@ 69, 118 SAY B2_QATU SIZE 53, 7  
			@ 78, 9 SAY STR0050 SIZE 53, 7  			 //"Disponกvel (B - A)"
			@ 78, 118 SAY nStoK SIZE 53, 7  
			DEFINE SBUTTON FROM 98, 149 TYPE 1 ACTION (oDlg:End()) ENABLE OF oDlg
			ACTIVATE MSDIALOG oDlg CENTERED
	Else
		HELP(" ",1,"C6_PRODUTO")
	EndIf
EndIf
RestArea(aAreaSB1)
RestArea(aAreaSB2)
RestArea(aArea)
Return
