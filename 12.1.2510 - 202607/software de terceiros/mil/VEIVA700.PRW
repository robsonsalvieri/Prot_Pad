// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 05     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#INCLUDE "PROTHEUS.CH"
#INCLUDE "VEIVA700.CH"

Static lMultMoeda := FGX_MULTMOEDA() // Trabalha com MultMoeda ?

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VEIVA700 ³ Autor ³ Rafael Goncalves      ³ Data ³ 24/05/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Valor Minimo comercial                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEIVA700()

//variaveis controle de janela
Local aObjects  := {} , aInfo := {}//
Local aSizeAut  := MsAdvSize(.t.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local nOrdCpo   := 0
Private lSMar   := .f.
Private lSGmod  := .f.
Private lSMod   := .f.
Private lVeicTot:= .f.
Private lPerMin := .T.
Private lVlrMin := .T.
Private oVerd   := LoadBitmap( GetResources() , "BR_VERDE" )	// Selecionado
Private oVerm   := LoadBitmap( GetResources() , "BR_VERMELHO" )	// Nao Selecionado
Private aMar    := {} // Marca
Private aGru    := {} // Grupo do Modelo
Private aMod    := {} // Modelo
Private aVeicTot:= {} // Veiculos Total
Private cAnoFab := SPACE(9)
Private cEstVei := ""
Private aEstVei := X3CBOXAVET("VV1_ESTVEI","1")
Private cCorVei := ""
Private aCorVei := X3CBOXAVET("VVC_TIPCOR","1")
Private nVlrMin := 0
Private nPerMin := 0
Private cOpcVei := space(100)
Private nDiaIni := 0
Private nDiaFim := 0
Private oOk     := LoadBitmap( GetResources(), "LBTIK" )
Private oNo     := LoadBitmap( GetResources(), "LBNO" )

// Configura os tamanhos dos objetos
aObjects := {}
AAdd( aObjects, { 0, 103 , .T. , .F. } )  	//list box
AAdd( aObjects, { 0, 028 , .T. , .F. } ) 	//Filtros
AAdd( aObjects, { 0,   0 , .T. , .T. } )  	//Rodape

aInfo := {aSizeAut[1] , aSizeAut[2] , aSizeAut[3] , aSizeAut[4] , 2 , 2 }
aPos  := MsObjSize (aInfo, aObjects,.F.)

FS_LEVANTA("MAR",.f.)	// Levanta Marcas
FS_LEVANTA("GRU",.f.)	// Levanta Grupos de Modelo
FS_LEVANTA("MOD",.f.)	// Levanta Modelos

If Len(aVeicTot) <= 0
	aAdd(aVeicTot,{.f.,0,0,0," "," "," "," "," "," "," "," ",0," ",""})
Endif

DEFINE MSDIALOG oValMin FROM aSizeAut[7],0 TO aSizeAut[6],aSizeAut[5] TITLE STR0001 OF oMainWnd PIXEL STYLE DS_MODALFRAME STATUS //Valor Minimo do veiculo
oValMin:lEscClose := .F.

nTam := ( aPos[1,4] / 7 )
// MARCA //
@ aPos[1,1],aPos[1,2]+(nTam*0) TO aPos[1,3]-003,(nTam*2) LABEL STR0011 OF oValMin PIXEL // Marca
@ aPos[1,1]+007,aPos[1,2]+(nTam*0)+2 LISTBOX oLbMar FIELDS HEADER "",STR0011,STR0013 COLSIZES 10,20,40 SIZE (nTam*2)-6,aPos[1,3]-aPos[1,1]-12 OF oValMin PIXEL ON DBLCLICK (FS_TIK("MAR",oLbMar:nAt),FS_CONSVEIC())//Marca / Descricao
oLbMar:SetArray(aMar)
oLbMar:bLine := { || { 	IIf(aMar[oLbMar:nAt,1],oVerd,oVerm) , aMar[oLbMar:nAt,2] , aMar[oLbMar:nAt,3] }}

// GRUPO DO MODELO //
@ aPos[1,1],aPos[1,2]+(nTam*2) TO aPos[1,3]-003,(nTam*4) LABEL STR0017 OF oValMin PIXEL // Grupo do Modelo
@ aPos[1,1]+007,aPos[1,2]+(nTam*2)+2 LISTBOX oLbGru FIELDS HEADER "",STR0011,STR0013 COLSIZES 10,20,40 SIZE (nTam*2)-6,aPos[1,3]-aPos[1,1]-12 OF oValMin PIXEL ON DBLCLICK (FS_TIK("GRU",oLbGru:nAt),FS_CONSVEIC())//Marca / Descricao
oLbGru:SetArray(aGru)
oLbGru:bLine := { || { 	IIf(aGru[oLbGru:nAt,1],oVerd,oVerm) , aGru[oLbGru:nAt,2] , aGru[oLbGru:nAt,4] }}

// MODELO //
@ aPos[1,1],aPos[1,2]+(nTam*4) TO aPos[1,3]-003,(nTam*7) LABEL STR0012 OF oValMin PIXEL // Modelo
@ aPos[1,1]+007,aPos[1,2]+(nTam*4)+2 LISTBOX oLbMod FIELDS HEADER "",STR0011,STR0012 COLSIZES 10,20,120 SIZE ((nTam*3)-6),aPos[1,3]-aPos[1,1]-12 OF oValMin PIXEL ON DBLCLICK (FS_TIK("MOD",oLbMod:nAt),FS_CONSVEIC())//Marca / Modelo
oLbMod:SetArray(aMod)
oLbMod:bLine := { || { 	IIf(aMod[oLbMod:nAt,1],oVerd,oVerm) , aMod[oLbMod:nAt,2] , aMod[oLbMod:nAt,5] }}


//divide a janela em tres colunas.
nTam := ( aPos[2,4] / 3 )

@ aPos[2,1]-001,aPos[2,2]+(nTam*0) TO aPos[1,1],(nTam*3)-2 LABEL "" OF oValMin PIXEL
nOrdCpo := 006
// Dias INICIAL //
@ aPos[2,1]+004,aPos[2,2]+nOrdCpo SAY STR0004 SIZE 47,8 OF oValMin PIXEL COLOR CLR_BLUE //Dias Estq.Inicial
@ aPos[2,1]+012,aPos[2,2]+nOrdCpo MSGET oDiaIni VAR nDiaIni PICTURE "@E 99,999" SIZE 45,08 OF oValMin PIXEL COLOR CLR_BLUE  HASBUTTON
nOrdCpo += 047
// DIAS FINAL //
@ aPos[2,1]+004,aPos[2,2]+nOrdCpo SAY STR0005 SIZE 47,8 OF oValMin PIXEL COLOR CLR_BLUE //Dias Estq.Final
@ aPos[2,1]+012,aPos[2,2]+nOrdCpo MSGET oDiaFim VAR nDiaFim PICTURE "@E 99,999" SIZE 45,08 OF oValMin PIXEL COLOR CLR_BLUE  HASBUTTON
nOrdCpo += 047
// COR DO VEICULO //
@ aPos[2,1]+004,aPos[2,2]+nOrdCpo SAY STR0006 SIZE 50,8 OF oValMin PIXEL COLOR CLR_BLACK //Tipo Cor
@ aPos[2,1]+012,aPos[2,2]+nOrdCpo MSCOMBOBOX oCorVei VAR cCorVei SIZE 50,08 COLOR CLR_BLACK ITEMS aCorVei OF oValMin PIXEL COLOR CLR_BLUE
nOrdCpo += 052
// ESTADO DO VEICULO //
@ aPos[2,1]+004,aPos[2,2]+nOrdCpo SAY STR0007 SIZE 50,8 OF oValMin PIXEL COLOR CLR_BLACK // Estado
@ aPos[2,1]+012,aPos[2,2]+nOrdCpo MSCOMBOBOX oEstVei VAR cEstVei SIZE 50,08 COLOR CLR_BLACK ITEMS aEstVei OF oValMin PIXEL COLOR CLR_BLUE
nOrdCpo += 052
// ANO FINAL //
@ aPos[2,1]+004,aPos[2,2]+nOrdCpo SAY STR0008 SIZE 50,8 OF oValMin PIXEL COLOR CLR_BLACK // Ano Fab.
@ aPos[2,1]+012,aPos[2,2]+nOrdCpo MSGET oAnoFab VAR cAnoFab PICTURE "@R 9999/9999" SIZE 40,08 OF oValMin PIXEL COLOR CLR_BLUE
nOrdCpo += 042
// OPCIONAIS //
@ aPos[2,1]+004,aPos[2,2]+nOrdCpo SAY STR0009 SIZE 85,8 OF oValMin PIXEL COLOR CLR_BLACK // Opcionais
@ aPos[2,1]+012,aPos[2,2]+nOrdCpo MSGET oOpcVei VAR cOpcVei PICTURE VZT->(X3PICTURE("VZT_OPCION")) SIZE 70,08 OF oValMin PIXEL COLOR CLR_BLUE
nOrdCpo += 072

@ aPos[2,1]+012,aPos[2,2]+nOrdCpo BUTTON oBotOk PROMPT STR0030 OF oValMin SIZE 15,10 PIXEL ACTION FS_CONSVEIC() // OK
nOrdCpo += 025

@ aPos[2,1],aPos[2,2]+001 TO aPos[3,1]-001,nOrdCpo-5 LABEL "" OF oValMin PIXEL

// VALOR FINAL //
@ aPos[2,1]+004,aPos[2,2]+nOrdCpo SAY STR0002 SIZE 55,8 OF oValMin PIXEL COLOR CLR_BLUE // Valor Minimo
@ aPos[2,1]+012,aPos[2,2]+nOrdCpo MSGET oVlrMin VAR nVlrMin PICTURE "@E 999,999,999.99" SIZE 55,08 VALID (Positivo() .and. FS_VARPER()) OF oValMin PIXEL COLOR  CLR_BLUE when lVlrMin HASBUTTON
nOrdCpo += 056
// PERCENTUAL CUSTO //
@ aPos[2,1]+004,aPos[2,2]+nOrdCpo SAY STR0010 SIZE 40,8 OF oValMin PIXEL COLOR CLR_BLUE // % Minimo
@ aPos[2,1]+012,aPos[2,2]+nOrdCpo MSGET oPerMin VAR nPerMin PICTURE "@E 999.99%" SIZE 40,08 VALID FS_VARPER() OF oValMin PIXEL COLOR CLR_BLUE when lPerMin HASBUTTON
nOrdCpo += 045

@ aPos[2,1]+003,aPos[2,2]+nOrdCpo BUTTON oAltSel PROMPT (STR0015) OF oValMin SIZE 65,10 PIXEL ACTION (FS_VARPER("1")) // Alterar selecionados
@ aPos[2,1]+016,aPos[2,2]+nOrdCpo BUTTON oAltTod PROMPT (STR0016) OF oValMin SIZE 65,10 PIXEL ACTION (FS_VARPER("2")) // Alterar Todos

@ aPos[2,1],nOrdCpo-103 TO aPos[3,1]-001,nOrdCpo+73 LABEL "" OF oValMin PIXEL

// VEICULOS //
oLbVeic := TWBrowse():New(aPos[3,1],aPos[3,2],(aPos[3,4]-2),(aPos[3,3]-aPos[3,1]),,,,oValMin,,,,,{ || FS_TIK2(oLbVeic:Nat,lVeicTot) },,,,,,,.F.,,.T.,,.F.,,,)
oLbVeic:addColumn( TCColumn():New( "", { || IIf(aVeicTot[oLbVeic:nAt,01],oOk,oNo) } ,,,,"LEFT" ,05,.T.,.F.,,,,.F.,) ) // Tik
If lMultMoeda
	oLbVeic:AddColumn( TCColumn():New( STR0026 , { || aVeicTot[oLbVeic:nAt,15] }    ,,,,"LEFT"  ,35,.F.,.F.,,,,.F.,) ) // Moeda
EndIf
oLbVeic:AddColumn( TCColumn():New( STR0018 , { || Transform(aVeicTot[oLbVeic:nAt,02],"@E 999,999,999.99") } ,,,,"RIGHT"  ,45,.F.,.F.,,,,.F.,) )
oLbVeic:AddColumn( TCColumn():New( STR0002 , { || Transform(aVeicTot[oLbVeic:nAt,03],"@E 999,999,999.99") } ,,,,"RIGHT"  ,45,.F.,.F.,,,,.F.,) )
oLbVeic:AddColumn( TCColumn():New( STR0010 , { || Transform(aVeicTot[oLbVeic:nAt,04],"@E 999.99")+"%" }     ,,,,"RIGHT"  ,35,.F.,.F.,,,,.F.,) )
oLbVeic:AddColumn( TCColumn():New( STR0014 , { || aVeicTot[oLbVeic:nAt,05] } ,,,, "LEFT" , 60,.F.,.F.,,,,.F., ))
oLbVeic:AddColumn( TCColumn():New( STR0011 , { || aVeicTot[oLbVeic:nAt,06] } ,,,, "LEFT" , 30,.F.,.F.,,,,.F., ))
oLbVeic:AddColumn( TCColumn():New( STR0012 , { || aVeicTot[oLbVeic:nAt,07] } ,,,, "LEFT" , 75,.F.,.F.,,,,.F., ))
oLbVeic:AddColumn( TCColumn():New( STR0019 , { || Transform(aVeicTot[oLbVeic:nAt,08],"@R 9999/9999") } ,,,, "LEFT" , 45,.F.,.F.,,,,.F., ))
oLbVeic:AddColumn( TCColumn():New( STR0020 , { || X3CBOXDESC("VV1_COMVEI",aVeicTot[oLbVeic:nAt,09]) } ,,,, "LEFT" , 70,.F.,.F.,,,,.F., ))
oLbVeic:AddColumn( TCColumn():New( STR0021 , { || Transform(aVeicTot[oLbVeic:nAt,10],VV1->(x3Picture("VV1_OPCFAB"))) } ,,,, "LEFT" ,130,.F.,.F.,,,,.F., ))
oLbVeic:AddColumn( TCColumn():New( STR0022 , { || aVeicTot[oLbVeic:nAt,11] } ,,,, "LEFT" , 95,.F.,.F.,,,,.F., ))
oLbVeic:AddColumn( TCColumn():New( STR0023 , { || Transform(aVeicTot[oLbVeic:nAt,12],VV1->(x3Picture("VV1_PLAVEI"))) } ,,,, "LEFT" , 45,.F.,.F.,,,,.F., ))
oLbVeic:AddColumn( TCColumn():New( STR0024 , { || FG_AlinVlrs(Transform(aVeicTot[oLbVeic:nAt,13],"@E 999,999,999")) } ,,,, "LEFT" , 55,.F.,.F.,,,,.F., ))
oLbVeic:AddColumn( TCColumn():New( STR0025 , { || X3CBOXDESC("VV1_TIPVEI",aVeicTot[oLbVeic:nAt,14]) } ,,,, "LEFT" , 55,.F.,.F.,,,,.F., ))
oLbVeic:SetArray(aVeicTot)

oLbMar:bHeaderClick  := {|oObj,nCol| IIf( nCol==1, (lSMar:=!lSMar      ,FS_TIK3("MAR",lSMar))  ,Nil) , oLbMar:Refresh()  }
oLbGru:bHeaderClick  := {|oObj,nCol| IIf( nCol==1, (lSGmod:=!lSGmod    ,FS_TIK3("GRU",lSGmod)) ,Nil) , oLbGru:Refresh()  }
oLbMod:bHeaderClick  := {|oObj,nCol| IIf( nCol==1, (lSMod:=!lSMod      ,FS_TIK3("MOD",lSMod))  ,Nil) , oLbMod:Refresh()  }
oLbVeic:bHeaderClick := {|oObj,nCol| IIf( nCol==1, (lVeicTot:=!lVeicTot,FS_TIK2(0,lVeicTot))   ,Nil) , oLbVeic:Refresh() }

ACTIVATE MSDIALOG oValMin ON INIT EnchoiceBar(oValMin,{|| IIf(FS_GRAVAR(),oValMin:End(),.T.) , .f. },{|| oValMin:End() } )
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_GRAVAR³ Autor ³ Rafael Goncalves      ³ Data ³ 24/05/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Grava valor minimo de venda do Veiculo                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_GRAVAR()
Local ni := 0
Local lRet := .f.
For ni := 1 to len(aVeicTot)
	DbSelectArea("VV1")
	DbSetOrder(2)
	If DbSeek(xFilial("VV1")+aVeicTot[ni,11])//FILIAL - CHASSI
		RecLock("VV1", !Found() )
		VV1->VV1_MNVLVD := aVeicTot[ni,4]//PERCENTUAL
		MsUnLock()
		lRet := .t.
	EndIf
Next
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_CONSVEIC³ Autor ³ Rafael Goncalves     ³ Data ³ 24/05/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Levanta Veiculos                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_CONSVEIC(cTipo)
Local cQuery  	:= ""
Local cQAlSQL 	:= "ALIASSQL"
Local ni      	:= 0
Local _ni      	:= 0
Local nPos    	:= 0
Local _cVV1   	:= ""
Local aAux    	:= {}
Local cOpcSel	:= "" //opcional select
Local cQryTemp 	:= ""
Local lAddveic 	:= .t.
Local aVetEmp	:= {}
Local aFilAtu   := FWArrFilAtu()
Local aSM0      := FWAllFilial( aFilAtu[3] , aFilAtu[4] , aFilAtu[1] , .f. )
Local nCont     := 0
Local cBkpFilAnt:= cFilAnt
Local aMoeda    := {""}
Local cMoeda    := ""
Local _nk:=0
Local nSugVga :=  0 //valor sugerido de venda
Local dDatEnt :=  ctod(" ")
Default cTipo := "0"

If lMultMoeda
	aMoeda := {}
	aAdd(aMoeda,GetMv("MV_MOEDA1")) // TEXTO da Moeda 1
	aAdd(aMoeda,GetMv("MV_MOEDA2")) // TEXTO da Moeda 2
EndIf

aVeicTot := {}
aGrvVei := {}

lTemMarca := .f.
lTemGrupo := .f.

For ni := 1 to len(aMod)
	//marca -grumor - modelo
	If aMod[ni,1] .and. !Empty(aMod[ni,2]) .and. !Empty(aMod[ni,3]) .and. !Empty(aMod[ni,6])
		aAdd(aGrvVei,{aMod[ni,2],aMod[ni,3],aMod[ni,6]})
		lTemMarca := .t.
		lTemGrupo := .t.
	EndIf
Next

For ni := 1 to len(aGru)
	//marca -grumor - modelo
	If aGru[ni,1] .and. !Empty(aGru[ni,2]) .and. !Empty(aGru[ni,3] )
		nPos := aScan(aGrvVei, {|x| x[1]+x[2] == aGru[ni,2]+aGru[ni,3] }) // Verifica se a Marca esta selecionada
		If nPos <= 0
			aAdd(aGrvVei,{aGru[ni,2],aGru[ni,3],""})
			lTemMarca := .t.
			lTemGrupo := .t.
		EndIf
	EndIf
Next

For ni := 1 to len(aMar)
	//marca -grumor - modelo
	If aMar[ni,1] .and. !Empty(aMar[ni,2])
		nPos := aScan(aGrvVei, {|x| x[1] == aMar[ni,2] }) // Verifica se a Marca esta selecionada
		If nPos <= 0
			aAdd(aGrvVei,{aMar[ni,2],"",""})
		EndIf
	EndIf
Next

//Levanta as Filiais
For nCont := 1 to Len(aSM0)
	cFilAnt := aSM0[nCont]
	aAdd( aVetEmp, { cFilAnt , FWFilialName() })
Next

For nCont := 1 to len(aVetEmp)

	cFilAnt := aVetEmp[nCont,1]
	If Len(aGrvVei ) > 0

		cQuery := "SELECT VV1.VV1_FILIAL , VV1.VV1_MNVLVD , VV1.VV1_CHAINT , VV1.VV1_CHASSI , VV1.VV1_CODMAR , VV1.VV1_MODVEI , VV1.VV1_SITVEI , VV1.VV1_ESTVEI , VV1.VV1_TIPVEI , VV1.VV1_FILENT , VV1.VV1_FABMOD , VV1.VV1_KILVEI , VV1.VV1_RESERV , VV1.VV1_BITMAP , VV1.VV1_DTHVAL , VV1.VV1_SUGVDA , VV1.VV1_SEGMOD , VV1.VV1_CORVEI , VV1.VV1_PLAVEI , VV1.VV1_COMVEI , VV1.VV1_OPCFAB , VV1.VV1_TRACPA , VV2.VV2_GRUMOD , VV2.VV2_DESMOD "
		If lMultMoeda
			cQuery += ", VV1.VV1_MOEDA "
		EndIf
		cQuery += "FROM "+RetSqlName("VV1")+" VV1 "
		cQuery += "INNER JOIN "+RetSqlName("VV2")+" VV2 ON ( VV2.VV2_FILIAL='"+xFilial("VV2")+"' AND VV1.VV1_CODMAR=VV2.VV2_CODMAR AND VV1.VV1_MODVEI=VV2.VV2_MODVEI  AND VV2.D_E_L_E_T_=' ' ) "
		cQuery += "INNER JOIN "+RetSqlName("VVC")+" VVC ON ( VVC.VVC_FILIAL='"+xFilial("VVC")+"' AND VVC.VVC_CODMAR=VV1.VV1_CODMAR AND VVC.VVC_CORVEI=VV1.VV1_CORVEI AND VVC.D_E_L_E_T_=' ' ) "
		cQuery += "WHERE VV1.VV1_FILIAL='"+xFilial("VV1")+"' AND "
		For ni := 1 to Len(aGrvVei)
			cQryTemp := "("
			if aGrvVei[ni,1]!=""
				cQryTemp +=" VV1.VV1_CODMAR='"+alltrim(aGrvVei[ni,1])+"'"
			endif
			if aGrvVei[ni,2]!=""
				cQryTemp +=" AND VV2.VV2_GRUMOD='"+alltrim(aGrvVei[ni,2])+"'"
			endif
			if aGrvVei[ni,3]!=""
				cQryTemp +=" AND VV1.VV1_MODVEI='"+alltrim(aGrvVei[ni,3])+"'"
			endif
			cQryTemp += ") AND "
			
			If !Empty(cEstVei)// Estado do Veiculo (Novos/Usados)
				cQryTemp += "VV1.VV1_ESTVEI='"+cEstVei+"' AND "
			EndIf
			
			If !Empty(cCorVei)// Cor do Veiculo (Solida, perolizada ou metaliza)
				cQryTemp += "VVC.VVC_TIPCOR='"+cCorVei+"' AND "
			EndIf
			
			If !Empty(cAnoFab)// Ano Fabricacao/Modelo
				cQryTemp += "VV1.VV1_FABMOD='"+cAnoFab+"' AND "
			EndIf
			cQryTemp += "VV1.VV1_SITVEI IN ('0') AND "
			cQryTemp += "VV1.D_E_L_E_T_=' ' ORDER BY VV1.VV1_CHASSI "
			
			cQryTemp:= cQuery+cQryTemp
			
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQryTemp ), cQAlSQL , .F., .T. )
			While !( cQAlSQL )->( Eof() )

				If _cVV1 <> ( cQAlSQL )->( VV1_CHASSI ) .and. ( aScan(aVeicTot,{|x| x[11] == ( cQAlSQL )->( VV1_CHASSI ) }) == 0 )

					nDiasEst := 0
					aAux     := {}
					
					_cVV1    := ( cQAlSQL )->( VV1_CHASSI )
					lAddveic := .t.
					//verifica opcionais de fabrica.
					If !Empty(cOpcVei)
						If Empty(( cQAlSQL )->( VV1_OPCFAB ))//se o veiculo nao possuir opcional desconsiderar.
							//( cQAlSQL )->( DbSkip() )//desconsidera o veiculo
							lAddveic:= .f.
						EndIf
						If lAddveic
							For _ni:=1 to 5
								cOpcSel := ""
								If !Empty(Substr(( cQAlSQL )->( VV1_OPCFAB ),(_ni*4)-3,3))
									cOpcSel := Substr(( cQAlSQL )->( VV1_OPCFAB ),(_ni*4)-3,3)
									If !(cOpcSel $ cOpcVei)
										lAddveic:= .f.
										exit
									EndIf
								EndIf
							Next
						EndIf
					EndIf
					
					//verificar dias em estoque.
					aAux := FGX_VEIMOVS( ( cQAlSQL )->( VV1_CHASSI ) , "E",  "0" ) // Retorna a ultima Entrada por Compra do Veiculo
					If len(aAux) > 0
						dDatEnt := ctod(Subs(aAux[1,4],5,2)+"/"+Subs(aAux[1,4],3,2)+"/"+Subs(aAux[1,4],1,2))
					EndIf
					nDiasEst := dDataBase-dDatEnt//dias estoque
					If !Empty(nDiaIni)
						If nDiasEst<nDiaIni
							lAddveic := .f.
						EndIf
					EndIf
					If !Empty(nDiaFim)
						If nDiasEst>nDiaFim
							lAddveic := .f.
						EndIf
					EndIf
					
					If lAddveic
						
						_nk := aScan(aVetEmp,{|x| x[1] == IIf(!Empty(( cQAlSQL )->( VV1_FILIAL )),( cQAlSQL )->( VV1_FILIAL ),( cQAlSQL )->( VV1_FILENT )) })//pega a posicao da filial no array
						
						cMoeda  := ""
						If lMultMoeda
							cMoeda := aMoeda[ IIf(( cQAlSQL )->( VV1_MOEDA )>0.and.( cQAlSQL )->( VV1_MOEDA )<3,( cQAlSQL )->( VV1_MOEDA ),1) ]
						EndIf

						nSugVga :=  0
						nSugVga := FGX_VLRSUGV( ( cQAlSQL )->( VV1_CHAINT ) ,  ,  ,  , , .f. ) //RETORNA VALOR SUGERIDO DE VENDA
						
						aAdd(aVeicTot, { .F. ,;//Tick
										nSugVga , ;
										((nSugVga*( cQAlSQL )->( VV1_MNVLVD ))/100) ,;
										( cQAlSQL )->( VV1_MNVLVD ),;
										IIf(!Empty(( cQAlSQL )->( VV1_FILIAL )),( cQAlSQL )->( VV1_FILIAL )+" - " + Iif(_nk>0,aVetEmp[_nk,2],""),( cQAlSQL )->( VV1_FILENT )+" - " + Iif(_nk>0,aVetEmp[_nk,2],"")) , ;
										( cQAlSQL )->( VV1_CODMAR ) , ;
										( cQAlSQL )->( VV2_DESMOD ) , ;
										( cQAlSQL )->( VV1_FABMOD ) , ;
										( cQAlSQL )->( VV1_COMVEI ) , ;
										left(( cQAlSQL )->( VV1_OPCFAB ),80) , ;
										( cQAlSQL )->( VV1_CHASSI ) , ;
										( cQAlSQL )->( VV1_PLAVEI ) , ;
										( cQAlSQL )->( VV1_KILVEI ) , ;
										( cQAlSQL )->( VV1_TIPVEI ) , ;
										cMoeda } )
					EndIf
				EndIf
				
				( cQAlSQL )->( DbSkip() )
			EndDo
			( cQAlSQL )->( dbCloseArea() )
		Next
	EndIf
Next
cFilAnt := cBkpFilAnt

If Len(aVeicTot) <= 0
	aAdd(aVeicTot,{.f.,0,0,0," "," "," "," "," "," "," "," ",0," ",""})
Endif
For ni := 1 to len(aVeicTot)
	If aVeicTot[ni,4] > 0
		aVeicTot[ni,3] := (aVeicTot[ni,2]*aVeicTot[ni,4])/100
	EndIf
Next
IF cTipo <> "1"
	oLbVeic:nAT := 1
	oLbVeic:SetArray(aVeicTot)
	oLbVeic:SetFocus()
	oLbVeic:Refresh()
EndIf
dbSelectArea("VV1")
dbSetOrder(1)
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_LEVANTA³ Autor ³ Rafael Goncalves      ³ Data ³ 24/05/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Levanta MARCA / GRUPO MODELO / MODELO /                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_LEVANTA(cTipo,lRefresh)
Local nPos    := 0
Local cQuery  := ""
Local cQAlSQL := "ALIASSQL"
Local ni := 0
Do Case
	Case cTipo == "MAR" // Levanta Marcas
		aMar := {}
		cQuery := "SELECT VE1.VE1_CODMAR , VE1.VE1_DESMAR FROM "+RetSqlName("VE1")+" VE1 "
		cquery += "WHERE VE1.VE1_FILIAL='"+xFilial("VE1")+"' AND VE1.D_E_L_E_T_=' ' ORDER BY VE1.VE1_CODMAR "
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSQL , .F., .T. )
		While !( cQAlSQL )->( Eof() )
			aAdd(aMar,{.f.,( cQAlSQL )->( VE1_CODMAR ),( cQAlSQL )->( VE1_DESMAR )})
			( cQAlSQL )->( DbSkip() )
		EndDo
		( cQAlSQL )->( DbCloseArea() )
		If len(aMar) == 1
			aMar[1,1] := .t.
		EndIf
		If len(aMar) == 0
			aAdd(aMar,{.f.,"",""})
		EndIf
		If lRefresh
			oLbMar:nAt := 1
			oLbMar:SetArray(aMar)
			oLbMar:bLine := { || { 	IIf(aMar[oLbMar:nAt,1],oVerd,oVerm) , aMar[oLbMar:nAt,2] , aMar[oLbMar:nAt,3] }}
			oLbMar:Refresh()
		EndIf
	Case cTipo == "GRU" // Levanta Grupos de Modelo
		aGruAux := {}
		for ni := 1 to len(aGru)
			If aGru[ni,1]
				aAdd(aGruAux,aGru[ni])
			EndIf
		Next
		aGru := {}
		cQuery := "SELECT VVR.VVR_CODMAR , VVR.VVR_GRUMOD , VVR.VVR_DESCRI FROM "+RetSqlName("VVR")+" VVR "
		cQuery += "WHERE VVR.VVR_FILIAL='"+xFilial("VVR")+"' AND VVR.D_E_L_E_T_=' ' ORDER BY VVR.VVR_CODMAR , VVR.VVR_DESCRI "
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSQL , .F., .T. )
		While !( cQAlSQL )->( Eof() )
			nPos := aScan(aMar, {|x| x[2] == ( cQAlSQL )->( VVR_CODMAR ) }) // Verifica se a Marca esta selecionada
			If nPos > 0 .and. aMar[nPos,1]
				lAchou := aScan(aGruAux,{|x| x[2] + x[3] == ( cQAlSQL )->( VVR_CODMAR ) + ( cQAlSQL )->( VVR_GRUMOD ) } ) > 0
				aAdd(aGru,{lAchou,( cQAlSQL )->( VVR_CODMAR ),( cQAlSQL )->( VVR_GRUMOD ),( cQAlSQL )->( VVR_DESCRI )})
			EndIf
			( cQAlSQL )->( DbSkip() )
		EndDo
		( cQAlSQL )->( DbCloseArea() )
		If len(aGru) <= 0
			aAdd(aGru,{.f.,"","",""})
		EndIf
		If lRefresh
			oLbGru:nAt := 1
			oLbGru:SetArray(aGru)
			oLbGru:bLine := { || { 	IIf(aGru[oLbGru:nAt,1],oVerd,oVerm) , aGru[oLbGru:nAt,2] , aGru[oLbGru:nAt,4] }}
			oLbGru:Refresh()
		EndIf
	Case cTipo == "MOD" // Levanta Modelos
		aModAux := {}
		for ni := 1 to len(aMod)
			If aMod[ni,1]
				aAdd(aModAux,aMod[ni])
			EndIf
		Next
		aMod := {}
		cQuery := "SELECT DISTINCT VV2.VV2_MODVEI , VV2.VV2_CODMAR , VV2.VV2_GRUMOD , VV2.VV2_DESMOD FROM "+RetSqlName("VV2")+" VV2 "
		cQuery += "WHERE VV2.VV2_FILIAL='"+xFilial("VV2")+"' AND VV2.D_E_L_E_T_=' ' ORDER BY VV2.VV2_CODMAR , VV2.VV2_DESMOD "
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSQL , .F., .T. )
		While !( cQAlSQL )->( Eof() )
			nPos := aScan(aGru, {|x| x[2]+x[3] == ( cQAlSQL )->( VV2_CODMAR ) + ( cQAlSQL )->( VV2_GRUMOD ) }) // Verifica se a Marca e o Grupo do Modelo estao selecionados
			If nPos > 0 .and. aGru[nPos,1]                                          '
				lAchou := aScan(aModAux,{|x| x[2] + x[3] + x[6]== ( cQAlSQL )->( VV2_CODMAR ) + ( cQAlSQL )->( VV2_GRUMOD ) + ( cQAlSQL )->( VV2_MODVEI ) } ) > 0
				aAdd(aMod,{lAchou,( cQAlSQL )->( VV2_CODMAR ),( cQAlSQL )->( VV2_GRUMOD ),"'"+Alltrim(( cQAlSQL )->( VV2_MODVEI ))+"'",;
				Alltrim(( cQAlSQL )->( VV2_MODVEI ))+" - "+( cQAlSQL )->( VV2_DESMOD ),( cQAlSQL )->( VV2_MODVEI ) })
			EndIf
			( cQAlSQL )->( DbSkip() )
		EndDo
		( cQAlSQL )->( DbCloseArea() )
		If len(aMod) <= 0
			aAdd(aMod,{.f.,"","","","",""})
		EndIf
		If lRefresh
			oLbMod:nAt := 1
			oLbMod:SetArray(aMod)
			oLbMod:bLine := { || { 	IIf(aMod[oLbMod:nAt,1],oVerd,oVerm) , aMod[oLbMod:nAt,2] , aMod[oLbMod:nAt,5]  }}
			oLbMod:Refresh()
		EndIf
EndCase
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_TIK   ³ Autor ³ Rafael Goncalves      ³ Data ³ 24/05/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ TIK dos ListBox de Filtro                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_TIK(cTipo,nLinha)
Local lSelLin := .f.
Do Case
	Case cTipo == "MAR"
		If len(aMar) > 1 .or. !Empty(aMar[1,2])
			lSelLin := aMar[nLinha,1]
			aMar[nLinha,1] := !lSelLin
			oLbMar:Refresh()
		EndIf
		FS_LEVANTA("GRU",.t.)
		FS_LEVANTA("MOD",.t.)
	Case cTipo == "GRU"
		If len(aGru) > 1 .or. !Empty(aGru[1,2])
			lSelLin := aGru[nLinha,1]
			aGru[nLinha,1] := !lSelLin
			oLbGru:Refresh()
		EndIf
		FS_LEVANTA("MOD",.t.)
	Case cTipo == "MOD"
		If len(aMod) > 1 .or. !Empty(aMod[1,2])
			lSelLin := aMod[nLinha,1]
			aMod[nLinha,1] := !lSelLin
			oLbMod:Refresh()
		EndIf
EndCase
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_TIK2  ³ Autor ³ Rafael Goncalves      ³ Data ³ 24/05/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ TIK2 da Selecao da linha do veiculo ( 0 = todos )          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_TIK2(nLinha,lVeicTot)
Local _ni:= 1
If nLinha > 0
	aVeicTot[nLinha,01] := 	!aVeicTot[nLinha,01]
Else
	For _ni := 1 to Len(aVeicTot)
		aVeicTot[_ni,01] := lVeicTot
	Next
EndIf
oLbVeic:Refresh()
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_TIK3  ³ Autor ³ Rafael Goncalves      ³ Data ³ 24/05/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ TIK3 da Selecao de todos listbox filtro                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_TIK3(cChama,lTipo)
Local _ni:= 1
If cChama == "MAR"
	lSGmod := .F.
	lSMod := .F.
	For _ni := 1 to Len(aMar)
		aMar[_ni,01] := lTipo
	Next	
	FS_LEVANTA("GRU",.t.)
	FS_LEVANTA("MOD",.t.)
ElseIf cChama == "GRU"
	lSMod := .F.
	For _ni := 1 to Len(aGru)
		aGru[_ni,01] := lTipo
	Next
	FS_LEVANTA("MOD",.t.)
ElseIf cChama == "MOD"
	For _ni := 1 to Len(aMod)
		aMod[_ni,01] := lTipo
	Next
EndIf
oLbMar:Refresh()
oLbGru:Refresh()
oLbMod:Refresh()
FS_CONSVEIC()
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_VARPER³ Autor ³ Rafael Goncalves      ³ Data ³ 24/05/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ when campo valor ou percentual                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_VARPER(cTipSel)
Local ni        := 1
Local nOpcMoeda := 0
Local cOpcMoeda := ""
Local aBotMoeda := {}
Local cMoeda1   := IIf(lMultMoeda,GetMv("MV_MOEDA1"),"")
Local cMoeda2   := IIf(lMultMoeda,GetMv("MV_MOEDA2"),"")
Default cTipSel := ""
If cTipSel == "1" // Selecionados
	If aScan(aVeicTot, { |x| x[1] } ) == 0
		MsgStop(STR0029,STR0001) // Necessário selecionar ao menos um Veículo/Máquina / Valor Minimo do veiculo
		Return
	EndIf
	If lMultMoeda
		// Verifica se esta selecionado somente registros da MOEDA 1
		If aScan(aVeicTot, { |x| x[1] .and. x[15] == cMoeda1 } ) > 0 .and. aScan(aVeicTot, { |x| x[1] .and. x[15] == cMoeda2 } ) == 0
			cOpcMoeda := cMoeda1
		EndIf
		// Verifica se esta selecionado somente registros da MOEDA 2
		If aScan(aVeicTot, { |x| x[1] .and. x[15] == cMoeda2 } ) > 0 .and. aScan(aVeicTot, { |x| x[1] .and. x[15] == cMoeda1 } ) == 0
			cOpcMoeda := cMoeda2
		EndIf
	EndIf
ElseIf cTipSel == "2" // Todos
	If lMultMoeda
		// Verifica se existem apenas registros da MOEDA 1
		If aScan(aVeicTot, { |x| x[15] == cMoeda1 } ) > 0 .and. aScan(aVeicTot, { |x| x[15] == cMoeda2 } ) == 0
			cOpcMoeda := cMoeda1
		EndIf
		// Verifica se existem apenas registros da MOEDA 2
		If aScan(aVeicTot, { |x| x[15] == cMoeda2 } ) > 0 .and. aScan(aVeicTot, { |x| x[15] == cMoeda1 } ) == 0
			cOpcMoeda := cMoeda2
		EndIf
	EndIf
EndIf
If lMultMoeda .and. ( nVlrMin > 0 ) .and. !Empty(cTipSel)
	If Empty(cOpcMoeda) // Deixar o usuário selecionar pois existem registros da MOEDA 1 e registros da MOEDA 2
		aBotMoeda := {}
		aAdd(aBotMoeda,cMoeda1) // TEXTO da Moeda 1
		aAdd(aBotMoeda,cMoeda2) // TEXTO da Moeda 2
		aAdd(aBotMoeda,STR0027) // Cancelar
		nOpcMoeda := Aviso(STR0001,STR0028,aBotMoeda,3) // Valor Minimo do veiculo / Ajustar Valores para os Veículos/Máquinas com qual Moeda?
		If nOpcMoeda == 3
			Return
		EndIf
		cOpcMoeda := aBotMoeda[nOpcMoeda]
	EndIf	
EndIf
lPerMin := .T.
lVlrMin := .T.
If !Empty(nVlrMin)
	lPerMin:= .f.
	oAltSel:SetFocus()
EndIf
If !Empty(nPerMin)
	lVlrMin:= .f.
EndIf
If !Empty(cTipSel)
	//altera valor minimo  do veiculo
	For ni := 1 to len(aVeicTot)
		If !Empty(aVeicTot[ni,2])
			If cTipSel=="1" //somente selecionados
				If !aVeicTot[ni,1]//nao estiver selecionado
					Loop
				EndIf
			EndIf
			If !Empty(nVlrMin) .and. ( cOpcMoeda == aVeicTot[ni,15] ) //valor estiver preenchido e for a mesma moeda (default é branco)
				aVeicTot[ni,3] := nVlrMin
				aVeicTot[ni,4] := GETDTOVAL(Transform((nVlrMin/aVeicTot[ni,2])*100,"@E 999.99")) // VAL com decimal
			EndIf
			If !Empty(nPerMin) //percentual estiver preenchido
				aVeicTot[ni,3] := (aVeicTot[ni,2]*nPerMin)/100
				aVeicTot[ni,4] := nPerMin
			EndIf
		EndIf
	Next
	For ni := 1 to len(aVeicTot)
		If aVeicTot[ni,4] > 0
			aVeicTot[ni,3] := (aVeicTot[ni,2]*aVeicTot[ni,4])/100
		EndIf
	Next
	oLbVeic:Refresh()
EndIf
oPerMin:Refresh()
oVlrMIn:Refresh()
Return
