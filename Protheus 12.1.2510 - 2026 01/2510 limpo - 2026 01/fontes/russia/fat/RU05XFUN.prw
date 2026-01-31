#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "RU05XFUN.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#Include "FILEIO.CH"
#INCLUDE "PARMTYPE.CH"
#include "TOTVS.CH" 

//define for dialogs
#define LAYOUT_LINEAR_L2R 0 // LEFT TO RIGHT
#define LAYOUT_LINEAR_R2L 1 // RIGHT TO LEFT
#define LAYOUT_LINEAR_T2B 2 // TOP TO BOTTOM
#define LAYOUT_LINEAR_B2T 3 // BOTTOM TO TOP
 
#define LAYOUT_ALIGN_LEFT     1
#define LAYOUT_ALIGN_RIGHT    2
#define LAYOUT_ALIGN_HCENTER  4
#define LAYOUT_ALIGN_TOP      32
#define LAYOUT_ALIGN_BOTTOM   64
#define LAYOUT_ALIGN_VCENTER  128

#DEFINE _PEDREM		    1
#DEFINE _GRUPO	   		2
#DEFINE _AGREGADOR		3
#DEFINE _NOQUEBRA	 	5


/*{Protheus.doc} RUXXTS01
@author Marina Dubovaya
@since 29.05.2018
@version 1.0
@return character cRet
@type function
@description Returns counteragent atribute by alias, if it is some subdivision
*/
Function _RUXXTS01(cFieldName as character, cAliasP as character)
Local cRet := ""
If cAliasP == "A1_"
    If (SA1->A1_TIPO == "3")
        cRet := Posicione('AI0',1,xFilial('AI0') + SA1->A1_COD + SA1->A1_LOJA, 'AI0_'+cFieldName)  
    EndIf
Else
    If (SA2->A2_TIPO == "3")
        cRet := SA2-> &("A2_"+cFieldName)
    EndIf
EndIf   
Return(cRet)

/*{Protheus.doc} RUXXTS02
@author Marina Dubovaya
@since 29.05.2018
@version 1.0
@return character cRet
@type function
@description Returns *_NREDUZ(short name) of Head Office if counteragent is a subdivision
*/
Function _RUXXTS02(cAliasP as character,cNametab as character)
Local cRet := ""
    If  &(cNametab + "->" + cAliasP +"TIPO")=="3"
        cRet := Posicione(cNametab,1,xFilial(cNametab) + RUXXTS01('HEAD',cAliasP) + RUXXTS01('HEADUN',cAliasP),cAliasP + "NREDUZ")
    Endif  

Return(cRet)


/*{Protheus.doc} RUXXTO03_FullAdrOffice
@author Marina Dubovaya
@since 29.05.2018
@version 1.0
@return character cRet
@type function
@description Returns AGA->AGA_FULL address or empty string if none 
*/
Static Function RUXXTO03_FullAdrOffice(cAliasP as character, cKeyP as character, cTipo as character)
Local cRet := ""
Local cQuery := ""
Local cAgaFull := ""
Local cTab := ""

if (!empty(cAliasP) .and. !empty(cKeyP) .and. !empty(cTipo))

	cQuery := " SELECT AGA.*, AGA.R_E_C_N_O_ AS AGAREC FROM " + RetSqlName("AGA") + " AGA "
	cQuery += " WHERE AGA_FILIAL = '"+xFilial("AGA")+"'"
	cQuery += " AND AGA_ENTIDA = '" + cAliasP + "'"
	cQuery += " AND AGA_CODENT = '" + cKeyP + "'"
	cQuery += " AND AGA_TIPO = '" + cTipo + "'"	
	cQuery += " AND '" + DtoS(dDatabase) + "' BETWEEN AGA_FROM AND AGA_TO"
	cQuery += " AND D_E_L_E_T_ = ' ' "
	cTab := MPSysOpenQuery(cQuery)

	If (cTab)->(!EOF())
		AGA->(dbGoTo((cTab)->AGAREC))
		cAgaFull	:= AGA->AGA_FULL
	
		If !Empty(cAgaFull)
			cRet := cAgaFull
		EndIf
	EndIf

	(cTab)->( dbCloseArea() )
EndIf

Return(cRet)

/*{Protheus.doc} RUXXTS03
@author Marina Dubovaya
@since 29.05.2018
@version 1.0
@return character cRet
@type function
@use RUXXTO03_FullAdrOffice()
@description Returns  postal address if flag 2, 
                      legal address head office if flag 0 and A*_tipo = 3, 
                      legal address if flag 0 and A*_tipo <> 3                
*/
Function _RUXXTS03(cFlag as character,cAliasP as character,cNametab as character)
Local cRet as Character

    If cFlag == '0'
      If (&(cNametab + "->" + cAliasP +"TIPO")=="3")
	      cRet := RUXXTO03_FullAdrOffice(cNametab, xFilial(cNametab) + RUXXTS01('HEAD', cAliasP) + RUXXTS01('HEADUN',cAliasP),'0') //addr head office
        Else
	      cRet := RUXXTO03_FullAdrOffice(cNametab, xFilial(cNametab) + &(cNametab + "->" + cAliasP + "COD") + &(cNametab + "->" + cAliasP +"LOJA"),'0') //addr office
       Endif 
    Else  
        cRet := RUXXTO03_FullAdrOffice(cNametab, xFilial(cNametab) + &(cNametab + "->" + cAliasP + "COD") + &(cNametab + "->" + cAliasP +"LOJA"),'2') // postal
    EndIf  
          
Return(cRet)

/*{Protheus.doc} RUXXTS04
@author Marina Dubovaya.
@since 29.05.2018
@version 1.0
@return character lRet
@type function
@use x3_when for F1_CNORSUP, F1_CNEEBUY, F2_CNORVEN, F2_CNEECLI, C5_CNORVEN, C5_CNEECLI
@description Returns  .T. if only GOODS are selected     
*/
Function RUXXTS04(DCod)
Local nX := 0
Local nPosCode  as Numeric
local cGrs      as Character
Local lRet      as Logical

lRet := .F.

If (Type ("aHeader") != "U") .AND. (Type ("aCols") != "U") .AND. ((Type ("lLocxAuto") != "U" .AND. !lLocxAuto) .OR. FwIsInCallStack('mata410'))//Checking if function not called by execauto or called from MATA410
    nPosCode := aScan(aHeader,{|x| AllTrim(x[2]) == Dcod   } )
    If nPosCode > 0
        For nX   := 1 to Len(aCols)
            If !aCols[nX][Len(aCols[nX])]
                DbSelectArea("SB1")
                If (SB1->(DbSeek(xFilial("SB1") + aCols[nX][nPosCode])))
                    cGrs := SB1->B1_GRUPO
                    DbSelectArea("SBM")
                    If (SBM->(DbSeek(xFilial("SBM") + cGrs)))
                        If (SBM->BM_GDSSRV) == '1' 
                            lRet := .T.
                        EndIf            
                    Endif
                EndIf
            EndIf     
        Next nX

	EndIf  
elseIf (Type ("lLocxAuto") != "U" .AND. lLocxAuto)//called by execauto MATA465N ULCD
    lRet := .T.
EndIf

Return (lRet)

/*{Protheus.doc} RUXXTS05
@author Marina Dubovaya
@since 06.05.2018
@version 1.0
@return character cRet
@type function
@use x3_when for F1_MOEDA, F1_CONUNI and LocxNF in function LocxDlgNF()
@description Returns  .T. if empty D#_PEDIDO (purchase/sales order), D#_REMITO(purchase/sales delivery), D#_NFORI (credit/debet note)
*/
Function RUXXTS05()
Local nX as Numeric
Local nPosPedido as Numeric
Local nPosRemito as Numeric
Local nPosNfOri  as Numeric
lRet:=.T.

If !IsBlind() .And. (type("aHeader") != "U") .AND. (type("aCols") != "U")
    nPosPedido := aScan(aHeader,{|x| "_PEDIDO"  $ AllTrim(x[2])  } )
    nPosRemito := aScan(aHeader,{|x| "_REMITO"  $ AllTrim(x[2])   } )
    nPosNfOri := aScan(aHeader,{|x|  "_NFORI"   $ AllTrim(x[2])   } )
    If nPosPedido > 0 .Or. nPosRemito > 0 .Or. nPosNfOri > 0
		For nX   := 1 to Len(aCols)
			If !aCols[nX][Len(aCols[nX])]
                lRet := lRet .And. ( Empty(nPosPedido) .Or. Empty(aCols[nX][nPosPedido]) )
                lRet := lRet .And. ( Empty(nPosRemito) .Or. Empty(aCols[nX][nPosRemito]) )
                lRet := lRet .And. ( Empty(nPosNfOri) .Or. Empty(aCols[nX][nPosNfOri]) )
			EndIf   
		Next
	EndIf  
EndIf

Return (lRet)

/*{Protheus.doc} RUXXTS06
@author Anna Fedorova
@since 09.13.2018
@version P12.1.23
@return Logical lRet
@type function
@param 
    cConsigID - C5_CNORVEN or C5_CNEECLI
    cConsigCod - C5_CNORCOD or C5_CNEECOD
    cConsigBranch - C5_CNORBR or C5_CNEEBR
@use x3_valid for C5_CNORVEN, C5_CNEECLI
@description Validation for Consignee and Consignor fields.
*/

Function RUXXTS06(cConsigID as Character, cConsigCod as Character, cConsigBranch as Character)
Local lRet as logical
lRet := .F.

lRet :=  IIF(M->&(cConsigID) == "1",;
            EVAL({||(M->&(cConsigCod):=Space(TamSX3(cConsigCod)[1]),;
                    M->&(cConsigBranch):=Space(TamSX3(cConsigBranch)[1])),.T.}),;
            .T.)

Return (lRet)

//-----------------------------------------------------------------------
/*/{Protheus.doc} RU05X0001_InitMoeDes

Standard init. for C5_MOEDES field

@param		None
@return		CHARACTER cDescr
@author 	victor.rezende
@since 		21/09/2018
@version 	1.5
@project	MA3
/*/
//-----------------------------------------------------------------------
Function RU05X0001_InitMoeDes()
Local cCurMoed  AS CHARACTER
Local cRet      AS CHARACTER
Local oModel    AS OBJECT
Local oModelSC5 AS OBJECT

cRet        := ""
cCurMoed    := ""
oModel      := FwModelActive()

If Empty(oModel)
    cCurMoed    := Posicione("CTO",1,xFilial("CTO")+StrZero(M->C5_MOEDA,TamSX3("CTO_MOEDA")[1]),"CTO_SIMB")
ElseIf ValType(oModel) == "O" .And. ! Empty( oModelSC5 := oModel:GetModel("SC5DETAIL") ) .And. oModel:GetOperation() <> MODEL_OPERATION_INSERT .And. ! Empty( oModelSC5:Length() )
    cCurMoed    := oModelSC5:GetValue("C5_MOEDA")
EndIf

If ! Empty( cCurMoed )
    cRet        := Posicione("CTO",1,xFilial("CTO")+StrZero(M->C5_MOEDA,TamSX3("CTO_MOEDA")[1]),"CTO_SIMB")
EndIf

Return cRet

//-----------------------------------------------------------------------
/*/{Protheus.doc} RU05XDTSAI

Check date of sales remito

@param		cOrder   Character  Order of Delivery;
            cClient  Character  Client;
            cLoja    Character  Unit of Client
@return		CHARACTER dRet
@author 	Alexandra Menyashina
@since 		27/09/2018
@version 	1.0
@project	MA3
/*/
//-----------------------------------------------------------------------
Function RU05XDTSAI(cOrder as Character, cClient as Character, cLoja as Character)
local   nWidth      AS NUMERIC
local   nHeight     AS NUMERIC
Local   dRet        AS DATE

Private oDlg as object

DEFAULT dRET := dDatabase

nWidth:=400
nHeight:=150

oDlg    := TDialog():New(000,000,nHeight,nWidth,STR0001,,,,,,,,,.T.)
oGBC    := tGridLayout():New(oDlg,CONTROL_ALIGN_ALLCLIENT)
oTFont := TFont():New(,,-13)

oOrder  := TSay():New(,, {|| STR0002 + cOrder}, oGBC,,oTFont,,,,.T.,,,,,,,,,,.T.)
oClient := TSay():New(,, {|| STR0003 + cClient }, oGBC,,oTFont,,,,.T.,,,,,,,,,,.T.)
oLoja   := TSay():New(,, {|| STR0004 + cLoja}, oGBC,,oTFont,,,,.T.,,,,,,,,,,.T.)

oGet := TGet():New( ,, { | u | If( PCount() == 0, dRet, dRet := u ) },oGBC, ;
     60, 10, "@d",, 0, 16777215, oTFont,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"dRet",,,,.T./*lHasButton*/  )
oButton1 := TButton():New(,, STR0005, oGBC, {||.T. .AND. oDlg:End()},;
	40,10,,oTFont,.F.,.T.,.F.,,.F.,,,.F.)

oGBC:addInLayout(oOrder,1,1,,,LAYOUT_ALIGN_HCENTER + LAYOUT_ALIGN_VCENTER)
oGBC:addInLayout(oClient,1,2,,,LAYOUT_ALIGN_HCENTER + LAYOUT_ALIGN_VCENTER)
oGBC:addInLayout(oLoja,1,3,,,LAYOUT_ALIGN_HCENTER + LAYOUT_ALIGN_VCENTER)
oGBC:addInLayout(oGet,2,1,,3,LAYOUT_ALIGN_HCENTER + LAYOUT_ALIGN_VCENTER)
oGBC:addInLayout(oButton1,3,1,,3,LAYOUT_ALIGN_HCENTER + LAYOUT_ALIGN_VCENTER)

oDlg:Activate(,,,.T.,,,)

Return dRet

//-----------------------------------------------------------------------
/*/{Protheus.doc} RU05X0002_OriDoc

MarkBrowse of original document for credit/debit notes

@param		cAliasHead   Character Alias of header table which will be created;
            nTipo          Numeric Type of document
            
@return		nil
@author 	Alexandra Velmozhnaya
@since 		06/03/2019
@version 	1.0
@project	MA3
/*/
//-----------------------------------------------------------------------
Function RU05X0002_OriDoc(cAliasHead as Character, nTipo as Numeric)
Local aArea    		:= GetArea()
Local aSF2			:= SF2->(GetArea())
Local aSD2			:= SD2->(GetArea())
Local aCposF4		:= {}
Local aRecs    		:= {}
Local aRet     		:= {}
Local nI 			:= 0
Local nTaxaNf		:= 0
Local nUm			:= 0
Local nSegUm		:= 0
Local nCod			:= 0
Local nFdesc		:= 0
Local nLocal		:= 0
Local nQuant		:= 0
Local nNfOri		:= 0
Local nSeriOri		:= 0
Local nItemOri		:= 0
Local nItem			:= 0
Local nTes			:= 0
Local nCf			:= 0
Local nLoteCtl		:= 0
Local nNumLote		:= 0
Local nDtValid		:= 0
Local nVunit		:= 0
Local nTotal		:= 0
Local nQTSegum		:= 0
Local nConta		:= 0
Local nCCusto		:= 0
Local nDesc			:= 0
Local nValDesc		:= 0
Local nProvEnt 		:= 0
Local nClVl			:= 0
Local nClientD2		:= 0
Local nLojaD2		:= 0
Local nTotalM		:= 0
Local nDescri		:= 0
Local cFilter 	    := ""
Local cItem			:= ""
Local cTipoDoc 		:= ""
Local cCliFor		:= M->F2_CLIENTE
Local cLoja  		:= M->F2_LOJA
Local dInvDoc       := M->F2_EMISSAO
Local cSeek  		:= ""
Local cWhile 		:= ""
Local cAliasCab		:= ""
Local cAliasItem	:= ""
Local cAliasTRB		:= ""
Local cQuery		:= ""
Local cFilSD		:= ""
Local lFiltroDoc	:= ExistBlock( "LxDocOri" )
Local cFilSB1		:= xFilial("SB1")
Local cFilSD2		:= xFilial("SD2")

Private aFiltro		:= {}

If Empty(cCliFor) .OR. Empty(cLoja)
	Aviso(cCadastro,STR0006,{STR0005}) //"Please complete the heading?s data"###"OK"
	Return
EndIf

For nI:=1 to Len(aHeader)
	Do Case
		Case  Alltrim(aHeader[nI][2]) == "D2_UM"
			nUm      := nI
		Case  Alltrim(aHeader[nI][2]) == "D2_SEGUM"
			nSegUm   := nI
		Case  Alltrim(aHeader[nI][2]) == "D2_COD"
			nCod     := nI
		Case  Alltrim(aHeader[nI][2]) == "D2_LOCAL"
			nLocal   := nI
		Case  Alltrim(aHeader[nI][2]) == "D2_QUANT"
			nQuant   := nI
		Case  Alltrim(aHeader[nI][2]) == "D2_NFORI"
			nNfOri  := nI
		Case  Alltrim(aHeader[nI][2]) == "D2_SERIORI"
			nSeriOri := nI
		Case  Alltrim(aHeader[nI][2]) == "D2_ITEMORI"
			nItemOri := nI
		Case  Alltrim(aHeader[nI][2]) == "D2_ITEM"
			nItem    := nI
		Case  Alltrim(aHeader[nI][2]) == "D2_TES"
			nTes     := nI
		Case  Alltrim(aHeader[nI][2]) == "D2_CF"
			nCf      := nI
		Case  Alltrim(aHeader[nI][2]) == "D2_LOTECTL"
			nLoteCtl := nI
		Case  Alltrim(aHeader[nI][2]) == "D2_NUMLOTE"
			nNumLote := nI
		Case  Alltrim(aHeader[nI][2]) == "D2_DTVALID"
			nDtValid := nI
		Case  Alltrim(aHeader[nI][2]) == "D2_PRCVEN"
			nVunit   := nI
		Case  Alltrim(aHeader[nI][2]) == "D2_TOTAL"
			nTotal   := nI
		Case  Alltrim(aHeader[nI][2]) == "D2_QTSEGUM"
			nQTSegum := nI
		Case  Alltrim(aHeader[nI][2]) == "D2_CONTA"
			nConta := nI
		Case  Alltrim(aHeader[nI][2]) == "D2_CC"
			nCCusto := nI
		Case  Alltrim(aHeader[nI][2]) == "D2_VALDESC"
			nValDesc := nI
		Case  Alltrim(aHeader[nI][2]) == "D2_DESC"
			nDesc := nI
		Case  Alltrim(aHeader[nI][2]) == "D2_PROVENT"
			nProvEnt := nI
		Case  Alltrim(aHeader[nI][2]) == "D2_CLVL"
			nClVl := nI
		Case  Alltrim(aHeader[nI][2]) == "D2_CLIENTE"
			nClientD2 := nI
		Case  Alltrim(aHeader[nI][2]) == "D2_LOJA"
			nLojaD2 := nI
		Case Alltrim(aHeader[nI][2]) == "D2_TOTALM"
			nTotalM   := nI
		Case Alltrim(aHeader[nI][2]) == "D2_FDESC"
			nFdesc     := nI
		Case Alltrim(aHeader[nI][2]) == "D2_DESCRI"
			nDescri     := nI
	Endcase
Next nI

cAliasCab	:= "SF2"
cAliasItem	:= "SD2"
SX3->(DbSetOrder(1))
SX3->(DbSeek(cAliasCab))
While !SX3->(EOF()) .AND. SX3->X3_ARQUIVO == cAliasCab
	If SX3->X3_BROWSE == "S" .AND. cNivel >= SX3->X3_NIVEL
		AAdd(aCposF4,SX3->X3_CAMPO)
	Endif
	SX3->(DbSkip())
EndDo

If nTipo == 2

	cTipoDoc	:= "'01'"
	cSeek  		:= "'" + xFilial(cAliasCab)+cCliFor+cLoja + "'"
	cWhile 		:= "SF2->(!EOF()) .AND. SF2->(F2_FILIAL+F2_CLIENTE+F2_LOJA)== " + cSeek
	cFilter     := "Ascan(aFiltro,SF2->(F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_TIPODOC)) > 0"
	cItem		:= aCols[Len(aCols),nItem]

    cAliasTRB := GetNextAlias()
    
    cQuery := "select distinct D2_FILIAL,D2_DOC,D2_SERIE,D2_CLIENTE,D2_LOJA,D2_TIPO,D2_TIPODOC,D2_ITEM"
    cQuery += " from " + RetSqlName("SD2") + " SD2 where "
    cQuery += " D2_FILIAL ='" + xFilial("SD2") + "'"
    cQuery += " and D2_CLIENTE = '" + cCliFor + "'"
    cQuery += " and D2_LOJA = '" + cLoja + "'"
    cQuery += " and D2_EMISSAO <= '" + DTOS(dInvDoc) + "'"
    cQuery += " and D2_TIPODOC in (" + cTipoDoc + ")"
    cQuery += " and D2_QUANT > D2_QTDEDEV"
    cQuery += " and SD2.D_E_L_E_T_ = ' ' "

    If lFiltroDoc
        cQuery := ExecBlock( "LxDocOri", .F., .F., { cQuery } )
    EndIf

    cQuery := ChangeQuery(cQuery)
    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTRB,.F.,.T.)
    DbSelectArea(cAliasTRB)
    While (cAliasTRB)->(!Eof())
        nI := Ascan(aCols,{|x| x[nNFORI] == (cAliasTRB)->D2_DOC .AND. x[nItemOri] == (cAliasTRB)->D2_ITEM .AND. !x[Len(x)]})
        If nI == 0
            Aadd(aFiltro, (cAliasTRB)->D2_FILIAL + (cAliasTRB)->D2_DOC + (cAliasTRB)->D2_SERIE + (cAliasTRB)->D2_CLIENTE + (cAliasTRB)->D2_LOJA + (cAliasTRB)->D2_TIPODOC)
        EndIf
        (cAliasTRB)->(DbSkip())
    EndDo
    (cAliasTRB)->(DbCloseArea())
Else
	Return
EndIf
If !Empty(aFiltro)
	aRet := LocxF4(cAliasCab,2,cWhile,cSeek,aCposF4,,STR0007,cFilter,.T.,,,,,.F.,,,.F.)  // Return
Else
	Help(" ",1,"A103F4")
	Return
EndIf
If ValType(aRet)=="A" .AND. Len(aRet)==3
	aRecs := aRet[3]
EndIf
If ValType(aRecs)!="A" .OR. (ValType(aRecs)=="A" .AND. Len(aRecs)==0)
	Return
EndIf
SD2->(DbSetOrder(3))
cFilSD := cFilSD2
ProcRegua(Len(aRecs))

For nI := 1 To Len(aRecs)
	SF2->(MsGoTo(aRecs[nI]))
	SD2->(DbSeek(cFilSD + SF2->F2_DOC + SF2->F2_SERIE + SF2->F2_CLIENTE + SF2->F2_LOJA))
	IncProc(STR0008 + "(" + SF2->F2_DOC + ")")
	While SD2->D2_FILIAL == cFilSD .AND. SD2->D2_DOC == SF2->F2_DOC .AND. SD2->D2_SERIE == SF2->F2_SERIE .AND.;
            SD2->D2_CLIENTE == SF2->F2_CLIENTE .AND. SD2->D2_LOJA == SF2->F2_LOJA
		
        If Ascan(aCols,{|x| x[nNFORI] == SD2->D2_DOC .AND. x[nItemOri] == SD2->D2_ITEM .AND. !x[Len(x)]}) == 0
            nLenAcols := Len(aCols)
            If !Empty(aCols[nLenAcols,nCod])
                AAdd(aCols,Array(Len(aHeader)+1))
                nLenAcols := Len(aCols)
                cItem := Soma1(cItem)
            Endif
            aCols[nLenAcols][Len(aHeader)+1]:=.F.
            If Empty(cCondicao) .OR. RUXXTS05()
                M->F2_CNTID 	:= SF2->F2_CNTID
                M->F2_F5QDESC   := Iif(!EMPTY(SF2->F2_CNTID),Posicione("F5Q",1,XFILIAL("F5Q")+SF2->F2_CNTID,"F5Q_CODE"),"")
                MaFisAlt("NF_MOEDA",SF2->F2_MOEDA)
                M->F2_MOEDA 	:= SF2->F2_MOEDA
                nMoedaNF		:= SF2->F2_MOEDA
                nMoedaCor		:= SF2->F2_MOEDA
                MaFisAlt("NF_TXMOEDA",SF2->F2_TXMOEDA)
                M->F2_TXMOEDA	:= SF2->F2_TXMOEDA
                M->F2_CONUNI	:= SF2->F2_CONUNI
                M->F2_CNORSUP	:= SF2->F2_CNORVEN	
                M->F2_CNEEBUY	:= SF2->F2_CNEECLI
                M->F2_CNORCOD	:= SF2->F2_CNORCOD
                M->F2_CNORBR	:= SF2->F2_CNORBR
                M->F2_CNEECOD	:= SF2->F2_CNEECOD
                M->F2_CNEEBR	:= SF2->F2_CNEEBR
                M->F2_DTSAIDA   := M->F2_DTSAIDA
                cCondicao   	:= SF2->F2_COND
            EndIf						

            nTaxaNF := MaFisRet(,'NF_TXMOEDA')
            nTaxaNF := Iif(nTaxaNF == 0,Recmoeda(dDEmissao,M->F1_MOEDA),nTaxaNF)
                      
            SB1->(MsSeek(cFilSB1+SD2->D2_COD))
            If (nUm      >  0  ,  aCOLS[nLenAcols][nUm      ] := SD2->D2_UM	,)
            If (nSegUm   >  0  ,  aCOLS[nLenAcols][nSegUm   ] := SB1->B1_SEGUM,)
            If (nCod     >  0  ,  aCOLS[nLenAcols][nCod     ] := SD2->D2_COD,)
            If (nDescri  >  0  ,  aCOLS[nLenAcols][nDescri  ] := SD2->D2_DESCRI,)
            If (nFdesc   >  0  ,  aCOLS[nLenAcols][nFdesc   ] := SD2->D2_FDESC,)
            If (nLocal   >  0  ,  aCOLS[nLenAcols][nLocal   ] := SD2->D2_LOCAL,)
            If (nNfOri   >  0  ,  aCOLS[nLenAcols][nNfOri   ] := SD2->D2_DOC,)
            If (nSeriOri >  0  ,  aCOLS[nLenAcols][nSeriOri ] := SD2->D2_SERIE,)
            If (nItemOri >  0  ,  aCOLS[nLenAcols][nItemOri ] := SD2->D2_ITEM,)
            If (nItem    >  0  ,  aCOLS[nLenAcols][nItem    ] := cItem,)
            If (nConta   >  0  ,  aCOLS[nLenAcols][nConta   ] := SD2->D2_CONTA,)
            If (nCCusto  >  0  ,  aCOLS[nLenAcols][nCCusto  ] := SD2->D2_CCUSTO,)
            If (nClVl    >  0  ,  aCOLS[nLenAcols][nClVl    ] := SD2->D2_CLVL,)
            If (nLoteCtl >  0  ,  aCOLS[nLenAcols][nLoteCtl ] := SD2->D2_LOTECTL,)
            If (nNumLote >  0  ,  aCOLS[nLenAcols][nNumLote ] := SD2->D2_NUMLOTE,)
            If (nDtValid >  0  ,  aCOLS[nLenAcols][nDtValid ] := SD2->D2_DTVALID,)
            If (nQtSegUm >  0  ,  aCOLS[nLenAcols][nQtSegUm ] := SD2->D2_QTSEGUM,)
            If (nClientD2 >  0 ,  aCOLS[nLenAcols][nClientD2] := SD2->D2_CLIENTE,)
            If (nLojaD2  >  0  ,  aCOLS[nLenAcols][nLojaD2  ] :=SD2->D2_LOJA,)
            If (nQuant  >  0   ,  aCOLS[nLenAcols][nQuant   ] := SD2->D2_QUANT,)
            If (nVUnit > 0     ,  aCOLS[nLenAcols][nVUnit   ] := SD2->D2_PRCVEN,)
            If (nTES > 0       ,  aCOLS[nLenAcols][nTES     ] := SD2->D2_TES,)
            If (nCf > 0        ,  aCOLS[nLenAcols][nCf      ] := SD2->D2_CF,)
            If (nTotal > 0     ,  aCOLS[nLenAcols][nTotal   ] := SD2->D2_TOTAL,)
            If (nTotalM > 0    ,   aCOLS[nLenAcols][nTotalM ] := SD2->D2_TOTALM,)

            AEval(aHeader,{|x,y| If(aCols[nLenAcols][y]==NIL,aCols[nLenAcols][y]:=CriaVar(x[2]),) })
            MaColsToFis(aHeader,aCols,nLenAcols,"MT100",.T.)    //TODO:debug for changing price = total. Its wrong
            MaFisAlt("IT_BASEIV1_C1",SD2->D2_BSIMP1M,nLenAcols)
			MaFisAlt("IT_VALIV1_C1",SD2->D2_VLIMP1M,nLenAcols)
            MaFisAlt("IT_RECORI",SD2->(Recno()),nLenAcols)
        EndIf

		SD2->(DbSkip())
	EndDo
Next nI
oGetDados:lNewLine:=.F.
oGetDados:obrowse:refresh()
Eval(bDoRefresh)
ModxAtuObj(.F.)

AtuLoadQt()
RestArea(aSD2)
RestArea(aSF2)
RestArea(aArea)

Return nil

/*{Protheus.doc} ExcRt101N
@author Alexandra Menyashina
@since 11/04/2018
@version P12.1.20
@param lCallRate    Logical     Flag of mandatory recalculation 
@return lRet
@type function
@description called by validation in Currency Rate to update all the item lines and header when the end user changes currency rate (for Inflow Invoice)
*/
Function _ExcRt101N(lCallRate, lAdvance)
Local nPosImp := aScan(aHeader,{|x| AllTrim(x[2]) == ('D1_VALIMP1')} )
Local nPosBas := aScan(aHeader,{|x| AllTrim(x[2]) == ('D1_BASIMP1')} )
Local nPosTot := aScan(aHeader,{|x| AllTrim(x[2]) == ('D1_TOTAL')} )

Local nPosTotM := aScan(aHeader,{|x| AllTrim(x[2]) == ('D1_TOTALM')} )
Local nPosBrutM := aScan(aHeader,{|x| AllTrim(x[2]) == ('D1_VLBRUTM')} )
Local nPosBsIM := aScan(aHeader,{|x| AllTrim(x[2]) == ('D1_BSIMP1M')} )
Local nPosVlIM := aScan(aHeader,{|x| AllTrim(x[2]) == ('D1_VLIMP1M')} )
Local nI as numeric
Local nVlImp1M as numeric
Local nBsImp1M as numeric
Local nTotalM as numeric
Local nBrutM as numeric
Local nRate := M->F1_TXMOEDA
Local lRecalc := .T.

Default lCallRate := .T.
Default lAdvance := .F.

If !lCallRate .And. !IsBlind() .And. !RUXXTS05() .And. RUXXTS04("D1_COD") 
    lRecalc := MsgYesNo(STR0012, STR0011)
EndIf

If lRecalc
    If !lAdvance .And. !lCallRate .Or. ReadVar() == "F1_MOEDA"
        nRate := RecMoeda(M->F1_EMISSAO,M->F1_MOEDA)
    EndIf
    nVlImp1M :=	0
    nBsImp1M :=	0
    nTotalM :=	0
    nBrutM	:=	0

    For nI := 1 To Len(aCols)
        If !aCols[nI][Len(aCols[nI])]
            aCols[nI][nPosTotM] :=	xMoeda(aCols[nI][nPosTot],M->F1_MOEDA,1,dDEmissao,,nRate)
            aCols[nI][nPosBsIM] := 	xMoeda(aCols[nI][nPosBas],M->F1_MOEDA,1,dDEmissao,,nRate)
            aCols[nI][nPosVlIM] := 	xMoeda(aCols[nI][nPosImp],M->F1_MOEDA,1,dDEmissao,,nRate)
            aCols[nI][nPosBrutM] :=	aCols[nI][nPosBsIM] + aCols[nI][nPosVlIM]

            nVlImp1M += aCols[nI][nPosVlIM]
            nBsImp1M += aCols[nI][nPosBsIM]
            nTotalM += aCols[nI][nPosTotM]
            nBrutM += aCols[nI][nPosBrutM]
        EndIf
    Next nI

    M->F1_VLIMP1M := nVlImp1M
    M->F1_BSIMP1M := nBsImp1M
    M->F1_VLBRUTM := nBrutM
    M->F1_VLMERCM := nTotalM
    MaFisRef("NF_BASEIV1_C1","MT100",nBsImp1M)
    MaFisRef("NF_VALIV1_C1","MT100",nVlImp1M)
    MaFisRef("NF_VALMERC_C1","MT100",nTotalM)
    MaFisRef("NF_TOTAL_C1","MT100",nBrutM)
    If !IsBlind()
        aoSbx[1]:Refresh()
    EndIf
EndIf
return lCallRate .Or. lRecalc

/*{Protheus.doc} ExcRt467N
@author Alexandra Menyashina
@since 23/04/2018
@version P12.1.20
@param lCallRate    Logical     Flag of mandatory recalculation
       nCurrLine    Numeric     grid line for which we run recalculation, if it is
                                Nil or 0, we recalculate values for all lines in grid
	   lAdvance     Logical     Flag about Select prepayments
@return lRet
@type function
@description called by validation in Currency Rate to update all the item lines and header when the end user changes currency rate (for Outflow Invoice)
*/
Function _ExcRt467N(lCallRate, nCurrLine, lAdvance)
Local nPosImp := aScan(aHeader,{|x| AllTrim(x[2]) == ('D2_VALIMP1')} )
Local nPosBas := aScan(aHeader,{|x| AllTrim(x[2]) == ('D2_BASIMP1')} )
Local nPosTot := aScan(aHeader,{|x| AllTrim(x[2]) == ('D2_TOTAL')} )

Local nPosTotM := aScan(aHeader,{|x| AllTrim(x[2]) == ('D2_TOTALM')} )
Local nPosBrutM := aScan(aHeader,{|x| AllTrim(x[2]) == ('D2_VLBRUTM')} )
Local nPosBsIM := aScan(aHeader,{|x| AllTrim(x[2]) == ('D2_BSIMP1M')} )
Local nPosVlIM := aScan(aHeader,{|x| AllTrim(x[2]) == ('D2_VLIMP1M')} )
Local nI as numeric
Local nVlImp1M as numeric
Local nBsImp1M as numeric
Local nTotalM as numeric
Local nBrutM as numeric
Local nStart as numeric
Local nStop  as numeric
Local nRate := M->F2_TXMOEDA
Local lRecalc := .T.
Local aMemVars as array

Default lCallRate := .T.
Default nCurrLine  := 0
Default lAdvance := .F.

If !lCallRate .And. !IsBlind() .And. RUXXTS04("D2_COD") .And. (Empty(M->F2_CNTID) .OR. M->F2_MOEDA!=1) 
    lRecalc := MsgYesNo(STR0012, STR0011)
EndIf
If lRecalc
    If !lAdvance .And. (!lCallRate .Or. ReadVar() == "F2_MOEDA")
        nRate := RecMoeda(M->F2_DTSAIDA,M->F2_MOEDA)
    EndIf 
    nVlImp1M :=	0
    nBsImp1M :=	0
    nTotalM :=	0
    nBrutM	:=	0
    If nCurrLine > 0
        nStart := nCurrLine
        nStop  := nStart
    Else
        nStart := 1
        nStop  := Len(aCols)
    EndIf
    For nI := nStart To nStop
        If !aCols[nI][Len(aCols[nI])] //if last element in array row is .F.
            aCols[nI][nPosTotM] :=	xMoeda(aCols[nI][nPosTot],M->F2_MOEDA,1,dDEmissao,,nRate)
            aCols[nI][nPosBsIM] := 	xMoeda(aCols[nI][nPosBas],M->F2_MOEDA,1,dDEmissao,,nRate)
            aCols[nI][nPosVlIM] := 	xMoeda(aCols[nI][nPosImp],M->F2_MOEDA,1,dDEmissao,,nRate)
            aCols[nI][nPosBrutM] :=	aCols[nI][nPosBsIM] + aCols[nI][nPosVlIM]

            nVlImp1M += aCols[nI][nPosVlIM]
            nBsImp1M += aCols[nI][nPosBsIM]
            nTotalM += aCols[nI][nPosTotM]
            nBrutM += aCols[nI][nPosBrutM]
        EndIf
    Next nI
    If nCurrLine > 0
        M->D2_VLIMP1M := nVlImp1M
        M->D2_BSIMP1M := nBsImp1M
        M->D2_VLBRUTM := nBrutM
        M->D2_VLMERCM := nTotalM
        //get totals for F2 fields
        nVlImp1M := 0
        nBsImp1M := 0
        nTotalM  := 0
        nBrutM   := 0
        For nI := 1 To Len(aCols)
            If !aCols[nI][Len(aCols[nI])] 
                nVlImp1M += aCols[nI][nPosVlIM]
                nBsImp1M += aCols[nI][nPosBsIM]
                nTotalM  += aCols[nI][nPosTotM]
                nBrutM   += aCols[nI][nPosBrutM]
            EndIf    
        Next nI
    EndIf
    aMemVars := {"M->F2_VLIMP1M", "M->F2_BSIMP1M", "M->F2_VLBRUTM", "M->F2_VLMERCM"}
    &(aMemVars[1]) := nVlImp1M // M->F2_VLIMP1M
    &(aMemVars[2]) := nBsImp1M // M->F2_BSIMP1M
    &(aMemVars[3]) := nBrutM   // M->F2_VLBRUTM
    &(aMemVars[4]) := nTotalM  // M->F2_VLMERCM
    MaFisRef("NF_BASEIV1_C1","MT100",nBsImp1M)
    MaFisRef("NF_VALIV1_C1","MT100",nVlImp1M)
    MaFisRef("NF_VALMERC_C1","MT100",nTotalM)
    MaFisRef("NF_TOTAL_C1","MT100",nBrutM)
    If !IsBlind()
        If nCurrLine > 0
            //refresh totals in bottom of the grid
            If Type("__AOGETS") == "A"
                For nI := 1 to Len(aMemVars)
                    nStop := ASCAN(__AOGETS, {|x| x:cReadVar == aMemVars[nI]})
                    If nStop > 0
                        __AOGETS[nStop]:Refresh()
                    EndIf
                Next nI
            EndIf
        Else
            aoSbx[1]:Refresh()
        EndIf
    EndIf
EndIf
return lCallRate .Or. lRecalc

/*/{Protheus.doc} RU05X0003_VATOriDoc
Routine responsible to Select a Original Document according Type
1 - Commercial Invoice (SF2)
2 - Correction Invoice (F5Y)
2 - Adjustment Invoice (F5Y)

@type function
@author Alison Kaique
@since Apr|2019

@param nOrigType, numeric  , Type of Original Document
@param cCustomer, character, Customer Code
@param cUnit    , character, Customer Unit
@param cSeries  , character, Document Series
@param cDocument, character, Document Number
@param cDocType , character, Document Type
@return lReturn , logical, Process Control
/*/
Function RU05X0003_VATOriDoc(nOrigType As Numeric, cCustomer As Character, cUnit AS Character, cSeries As Character, cDocument As Character, cDocType As Character)
    Local cHeaderAlias As Character //Header Alias
    Local aFields      As Array //Table Fields
    Local lReturn      As Logical //Process Control

    Local cType        As Character //Document Type
    Local cSeek        As Character //String Seek
    Local cWhile       As Character //String While
    Local cFilter      As Character //String Filter
    Local cItem        As Character //Invoice Item
    Local cAliasTMP    As Character //Alias for Temporary Table
    Local cQuery       As Character //String Query
    Local aReturn      As Array //Return for registers
    Local cDblClick    As Character //Double Click Routine

    Private aFilter    As Array //Filter for Notes

    Default cSeries   := ""
    Default cDocument := ""
    Default cDocType  := ""

    aFilter := {}

    lReturn := .T. //Process Control

    cDblClick := ""

    //Verify Type and define parameters
    Do Case
        Case nOrigType == 01 //Commercial Invoice
            //Verify if informed Series, Document and DocType
            If (!Empty(cSeries) .OR. !Empty(cDocument) .OR. !Empty(cDocType))
                //Seek Document
                SF2->(DbSetOrder(02)) //F2_FILIAL+F2_CLIENTE+F2_LOJA+F2_DOC+F2_SERIE+F2_TIPO+F2_ESPECIE
                If !(SF2->(DbSeek(FWxFilial("SF2") + cCustomer + cUnit + cDocument + cSeries + cDocType)))
                    lReturn := .F.
                EndIf
            Else
                cHeaderAlias := "SF2"
                //Get Fields
                aFields := {"F2_FILIAL", "F2_DOC", "F2_SERIE", "F2_CLIENTE", "F2_LOJA", "F2_EMISSAO", "F2_VLBRUTM", "F2_MOEDA", "F2_CONUNI", "F2_BASIMP1", "F2_VALIMP1", "F2_F5QDESC", "F2_TIPO", "F2_TIPODOC"}

                cType   	:= "'01'"
                cSeek  		:= "'" + FWxFilial(cHeaderAlias) + cCustomer + cUnit + "'"
                cWhile 		:= "SF2->(!EOF()) .AND. SF2->(F2_FILIAL + F2_CLIENTE + F2_LOJA) == " + cSeek
                cFilter     := "Ascan(aFilter, SF2->(F2_FILIAL + F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA + F2_TIPODOC)) > 0"
                cItem		:= StrZero(01, TamSX3("D2_ITEM")[01])

                cAliasTMP   := GetNextAlias()

                cQuery := "SELECT" + CRLF
                cQuery += " DISTINCT D2_FILIAL,D2_DOC,D2_SERIE,D2_CLIENTE,D2_LOJA,D2_TIPO,D2_TIPODOC" + CRLF
                cQuery += "FROM " + RetSqlName("SD2") + " SD2" + CRLF
                cQuery += "WHERE" + CRLF
                cQuery += " D2_FILIAL = '" + FWxFilial("SD2") + "'"
                cQuery += " AND D2_CLIENTE = '" + cCustomer + "'"
                cQuery += " AND D2_LOJA = '" + cUnit + "'"
                cQuery += " AND D2_TIPODOC in (" + cType + ")"
                cQuery += " AND D2_QUANT > D2_QTDEDEV"
                cQuery += " AND (SELECT COUNT(*) FROM " + RetSqlName("SD2") + " B WHERE B.D2_FILIAL = '" + FWxFilial("SD2") + "' AND B.D2_NFORI = SD2.D2_DOC AND B.D2_SERIORI = SD2.D2_SERIE AND B.D_E_L_E_T_ = '') = 0" + CRLF
                cQuery += " AND SD2.D_E_L_E_T_ = ' ' "

                cQuery := ChangeQuery(cQuery)

                PlsQuery(cQuery, cAliasTMP)

                While (cAliasTMP)->(!Eof())
                    Aadd(aFilter, (cAliasTMP)->(D2_FILIAL + D2_DOC + D2_SERIE + D2_CLIENTE + D2_LOJA + D2_TIPODOC))
                    (cAliasTMP)->(DbSkip())
                EndDo
                (cAliasTMP)->(DbCloseArea())

                cDblClick := "RU05X0004_OpenComInv(01, {" + StrTran(StrTran(FormatIn(ArrTokStr(aFields, ","), ","), "(", ""), ")", "") + "}, '" + cCustomer + "', '" + cUnit + "')"
            EndIf
        Case nOrigType == 02 //ULCD
            cHeaderAlias := "F5Y"

            //Get Fields
            aFields := {"F5Y_FILIAL", "F5Y_DOC", "F5Y_SERIE", "F5Y_CLIENT", "F5Y_BRANCH", "F5Y_DATE"}

            cSeek  		:= "'" + FWxFilial(cHeaderAlias) + cCustomer + cUnit + "'"
            cWhile 		:= "F5Y->(!EOF()) .AND. F5Y->(F5Y_FILIAL + F5Y_CLIENT + F5Y_BRANCH) == " + cSeek
            cFilter     := "Ascan(aFilter, F5Y->(F5Y_FILIAL + F5Y_DOC + F5Y_SERIE + F5Y_CLIENT + F5Y_BRANCH)) > 0"
            cItem		:= StrZero(01, TamSX3("D2_ITEM")[01])

            cAliasTMP   := GetNextAlias()

            cQuery := "SELECT" + CRLF
            cQuery += " F5Y_FILIAL, F5Y_DOC, F5Y_SERIE, F5Y_CLIENT, F5Y_BRANCH" + CRLF
            cQuery += "FROM " + RetSqlName("F5Y") + " F5Y" + CRLF
            cQuery += "WHERE" + CRLF
            cQuery += " F5Y_FILIAL = '" + FWxFilial("F5Y") + "'" + CRLF
            cQuery += " AND F5Y_CLIENT = '" + cCustomer + "'" + CRLF
            cQuery += " AND F5Y_BRANCH = '" + cUnit + "'" + CRLF
            cQuery += " AND (SELECT COUNT(*) FROM " + RetSqlName("F5Y") + " B WHERE B.F5Y_FILIAL = '" + FWxFilial("F5Y") + "' AND B.F5Y_DOCORI = F5Y.F5Y_DOC AND B.F5Y_SERORI = F5Y.F5Y_SERIE AND B.D_E_L_E_T_ = '') = 0" + CRLF
            cQuery += " AND F5Y.D_E_L_E_T_ = ' ' " + CRLF

            cQuery := ChangeQuery(cQuery)

            PlsQuery(cQuery, cAliasTMP)

            While (cAliasTMP)->(!Eof())
                Aadd(aFilter, (cAliasTMP)->(F5Y_FILIAL + F5Y_DOC + F5Y_SERIE + F5Y_CLIENT + F5Y_BRANCH))
                (cAliasTMP)->(DbSkip())
            EndDo
            (cAliasTMP)->(DbCloseArea())

            cDblClick := "RU05X0004_OpenComInv(02, {" + StrTran(StrTran(FormatIn(ArrTokStr(aFields, ","), ","), "(", ""), ")", "") + "}, '" + cCustomer + "', '" + cUnit + "')"
    EndCase

    If Len(aFilter) > 0
        aReturn := LocxF4(cHeaderAlias, 02, cWhile, cSeek, aFields, , STR0009, cFilter, .F.,,,, cDblClick, .F.,,,.F.) //"Select Original Document"
    Else
        lReturn := .F.
    EndIf

    If ValType(aReturn) == "A" .AND. Len(aReturn) == 3
        //Go To Recno
        DBSelectArea(cHeaderAlias)
        (cHeaderAlias)->(DBGoTo(aReturn[03]))
    Else
        lReturn := .F.
    EndIf

    If (!lReturn)
        Help(" ", 01, "VATOriDoc", , STR0010, 04, 15) //"No Original Documents found"
    EndIf

Return lReturn


/*{Protheus.doc} RU05X0005_ValidDateIncDoc
@author Alexandra Velmozhnya
@since 27/05/2019
@version 1.0
@param None
@return lRet
@type function
@description 
*/
Function RU05X0005_ValidDateIncDoc(dInvDate, dDocDate)
Local lRet as Logical

Default dInvDate := dDatabase
Default dDocDate := dDatabase

lRet := dInvDate >= dDocDate

If !lRet 
    Help("", 1, "RU05X0005_ValidDateIncDoc1",, STR0013, 1, 0)   //Date of document which was include could not be more than Invoice date
EndIf

Return lRet

/*{Protheus.doc} RU05X0006_RecalcTotal
@author Alexandra Velmozhnya
@since 06/06/2019
@version 1.0
@param None
@return nRet
@type function
@description trigger for recalculation D*_TOTAL
*/
Function RU05X0006_RecalcTotal()
Local nRet := 0
Local nPosQuant := aScan(aHeader,{|x| Upper(Alltrim(x[2]))$"D2_QUANT|D1_QUANT"})
Local nPosPrice := aScan(aHeader,{|x| Upper(Alltrim(x[2]))$"D2_PRCVEN/D1_VUNIT"})
Local nPosTotal := aScan(aHeader,{|x| Upper(Alltrim(x[2]))$"D2_TOTAL/D1_TOTAL"})

If nPosPrice > 0 .And. nPosQuant > 0 .And. nPosTotal > 0
    nRet := Iif( aCols[n][nPosQuant] > 0 .And. aCols[n][nPosPrice] > 0, aCols[n][nPosQuant] * aCols[n][nPosPrice] , aCols[n][nPosTotal] )
EndIf
return nRet

/*{Protheus.doc} RU05XFN007_InitialArrayMatxFis
@author Alexandra Velmozhnya
@since 23/01/2020
@version 1.0
@param  aHeader array   - structure of grid
        aCols   array   - data of grid
        lClear  logical - Flag clear array if operation creation
@return Nil
@type function
@description Initializing MatXFis array
*/
Function RU05XFN007_InitialArrayMatxFis(aHeader,aCols, lClear)
Local nY		As Numeric
Local nX		As Numeric
Local cValid	As Character
Local cRefCols	As Character
Local aRefImpos	As Array

Default lClear := .F.

If lClear
    MaFisClear()
EndIf
aRefImpos := MaFisRelImp("MATA461",{"SC6"})
aSort(aRefImpos,,,{|x,y| x[3]<y[3]})

MaFisIni(SC5->C5_CLIENTE/*cClient*/,SC5->C5_LOJACLI/*cLoja*/,"C","N",Nil,aRefImpos,,.F.)		//Initialize NFCab and NFItem
For nX := 1 to Len(aCols)
    MaFisIniLoad(nX)
    For nY	:= 1 To Len(aHeader)
        cValid	:= AllTrim(UPPER(aHeader[nY][6]))
        cRefCols := MaFisGetRf(cValid)[1]
        If !Empty(cRefCols) .AND. MaFisFound("IT",nX)
            MaFisLoad(cRefCols,aCols[nX][nY],nX)
        EndIf
    Next nY
    MaFisEndLoad(nX,1)
Next nX
return Nil


/*{Protheus.doc} RU05XFN008_Help
@author Artem Kostin
@since 02/08/2019
@version 1.0
@param cFunTrown - function, which trows an error
@return None
@type function
@description generalization of  
*/
Function RU05XFN008_Help(oModel as Object)
If (oModel:HasErrorMessage())
    Help(NIL, NIL, ProcName(1)+":"+Procname(0), NIL;
        , oModel:GetErrorMessage()[1] + CRLF;
        + oModel:GetErrorMessage()[2] + CRLF;
        + oModel:GetErrorMessage()[3] + CRLF;
        + oModel:GetErrorMessage()[4] + CRLF;
        + oModel:GetErrorMessage()[5] + CRLF;
        + oModel:GetErrorMessage()[6];
        , 1, 0, NIL, NIL, NIL, NIL, NIL;
        , {oModel:GetErrorMessage()[7], Iif(oModel:GetErrorMessage()[8] == Nil, "", oModel:GetErrorMessage()[8]), Iif(oModel:GetErrorMessage()[9] == Nil, "", oModel:GetErrorMessage()[9])};
    )
EndIf
Return

/*{Protheus.doc} RU05XFN009_ArrayColumns
@author Alexandra Velmozhnya
@since 27/12/2019
@version 1.0
@param aMarkField - name of Fields for mark Browse
@param aHideFields - name of Fields which should be hidden but in temporary table should be
@return None
@type function
@description generalization of  
*/
Function RU05XFN009_ArrayColumns(aMarkField as array, aHideFields as Array)
Local aRet as Array
Local aArea as Array
Local aAreaSX3 as Array
Local nI as Numeric

aRet := {}
aArea := GetArea()
aAreaSX3 := SX3->(GetArea())
DbSelectArea("SX3")
SX3->(DbSetOrder(2))
For nI := 1 To Len(aMarkField)
    If (SX3->(DbSeek(aMarkField[nI])))
        aAdd(aRet, FwBrwColumn():New())
        aRet[Len(aRet)]:SetData(&("{|| " + aMarkField[nI] + "}"))
        aRet[Len(aRet)]:SetTitle(X3Titulo())
        aRet[Len(aRet)]:SetSize(TamSX3(aMarkField[nI])[1])
        aRet[Len(aRet)]:SetDecimal(TamSX3(aMarkField[nI])[2])
        aRet[Len(aRet)]:SetPicture(PesqPict("S" + SubStr(aMarkField[nI], 1, 2), aMarkField[nI]))
        aRet[Len(aRet)]:SetOptions( Separa(RTrim(X3CBox()),";") )
        If aScan(aHideFields,{|x| x == aMarkField[nI]}) > 0
            aRet[Len(aRet)]:SetDelete(.T.)
        EndIf
    EndIf
Next nI
RestArea(aAreaSX3)
RestArea(aArea)
Return aRet

/*/{Protheus.doc} RU05XFN00A
    This function gets invoice values and generates  arrays of advances with moneatry values
    that wil be used for write-off.
    !!!ATTENTION!!! We must use this function in transaction mode and aRecnoAdvn records must be locked
    @type  Function
    @author astepanov
    @since 23/10/2022
    @version version
    @param nValbrut, Numeric, Total Value of goods in document currency
    @param nVlbrutm, Numeric, Gross Value in Currency 1
    @param nBasimp1, Numeric, Document Tax Base in Currency 1
    @param aRecnoAdvn, Array, Array with information about used advances
    @param dDEmissao, Date, Date which will be used for new SE1 or SE2 record for E1_EMISSAO or E2_EMISSAO accordingly
    @return aRet, Array, {Result of execution,aValmerc,aVlbrutm,aBasimp1}
    @example
    (examples)
    @see (links_or_references)
    /*/
Function RU05XFN00A(nValbrut, nVlbrutm, nBasimp1, aRecnoAdvn, dDEmissao)
    Local nX         As Numeric
    Local nMoeda1    As Numeric
    Local nLenAdv    As Numeric
    Local nSE_Recno  As Numeric
    Local nValor     As Numeric
    Local nTxMoeda   As Numeric
    Local nSaldo     As Numeric
    Local nSaldoM1   As Numeric
    Local nAdvValue  As Numeric
    Local nAdvValuM1 As Numeric
    Local nAdvValuBs As Numeric
    Local nBasimp1Sl As Numeric
    Local nValbrutSl As Numeric
    Local cPr        As Character
    Local lRet       As Logical
    Local aValbrut   As Array
    Local aVlbrutm   As Array
    Local aBasimp1   As Array
    Local aRet       As Array
    Local aArea      As Array
    Local dSaldoDate As Date

    aValbrut   := {}
    aVlbrutm   := {}
    aBasimp1   := {}
    lRet       := .T.
    aArea      := GetArea()
    nMoeda1    := 1
    dSaldoDate := RU05XFN01K_dSaldoDateForAdvance()
    nLenAdv    := Len(aRecnoAdvn)
    nX := 1
    nBasimp1Sl := nBasimp1
    nValbrutSl := nValbrut
    If !(InTransact() .AND. !FWInTTSBreak())
        lRet := .F. // We can use this function only in transaction mode
        Help("", 1, STR0029,, STR0097, 1, 0) //Attention -- Non tarnsaction mode is prohibited
    EndIf
    While lRet .AND. nX  <= nLenAdv .AND. nValbrutSl > 0
        nSE_Recno   := (aRecnoAdvn[nX][6])->(Recno()) //save current cursor position in SE1 or SE2
        (aRecnoAdvn[nX][6])->(DBGoto(aRecnoAdvn[nX][2])) // Go to SE1 or SE2 record, it is an advance AP or AR
        cPr     := SubStr(aRecnoAdvn[nX][6],2,2)+"_"
        If RecLock(aRecnoAdvn[nX][6], .F.)
            nAdvValue   := aRecnoAdvn[nX][3]
            nValor      := &(cPr+"VALOR")
            nTxMoeda    := &(cPr+"TXMOEDA")
            nTxMoeda    := IIF(nTxMoeda==0,1,nTxMoeda)
            nCurrency   := &(cPr+"MOEDA")
            nSaldo      := RU05XFN01E_GetSaldo(aRecnoAdvn[nX][6],aRecnoAdvn[nX][2],dSaldoDate,nCurrency)
            nSaldoM1    := RU05XFN01E_GetSaldo(aRecnoAdvn[nX][6],aRecnoAdvn[nX][2],dSaldoDate,nMoeda1)
            If nAdvValue >= nSaldo
                nAdvValue  := nSaldo
                nAdvValuM1 := nSaldoM1
            Else
                nAdvValuM1 := Round(nAdvValue*nTxMoeda,GetSX3Cache(cPr+"VLCRUZ","X3_TAMANHO"))
            EndIf
            nValbrutSl   := nValbrutSl - nAdvValue
            // total base value should be shared between APs or ARs proportionally to nAdvValue
            If nValbrutSl != 0
                nAdvValuBs := ROUND((nAdvValue * nBasimp1) / nValbrut, GetSX3Cache(cPr+"BASIMP1","X3_DECIMAL"))
                nBasimp1Sl := nBasimp1Sl - nAdvValuBs
            Else
                nAdvValuBs := nBasimp1Sl
            EndIf
            AADD(aValbrut,{dDEmissao,nAdvValue ,nTxMoeda,nAdvValuM1,aRecnoAdvn[nX][2],aRecnoAdvn[nX][6]})
            AADD(aVlbrutm,{dDEmissao,nAdvValuM1,nTxMoeda,nAdvValuM1,aRecnoAdvn[nX][2],aRecnoAdvn[nX][6]})
            AADD(aBasimp1,{dDEmissao,nAdvValuBs,nTxMoeda,nAdvValuM1,aRecnoAdvn[nX][2],aRecnoAdvn[nX][6]})
            (aRecnoAdvn[nX][6])->(MsUnlock())
        Else
            lRet := .F.
        EndIf
        (aRecnoAdvn[nX][6])->(DBGoto(nSE_Recno)) //restore cursor position in SE1 or SE2
        nX := nX + 1
    EndDo
    RestArea(aArea)
    aRet := {lRet,aValbrut,aVlbrutm,aBasimp1}
Return aRet

/*{Protheus.doc} RU05XFN00B_ViewPrepayment
@author Alexandra Velmozhnaia
@since 18/09/2020
@version 1.0
@param	cCliFor		Character	Client/Supplier Cod
		cLoja		Character	Client/Supplier Branch
		cDocNumber	Character	Document Number
		cSerie		Character	Document Serie
@return None
@edit astepanov 17 March 2023
@description
    The function for search linked Prepayment
*/
Function RU05XFN00B(cCliFor, cLoja, cDocNumber, cSerie)
    Local cTab  as Character
    Local aArea as Array
    aArea := GetArea()
    cTab := CrtTmpT00C(cCliFor,cLoja,cDocNumber,cSerie)
    If cTab != Nil
        (cTab)->(DBGoTop())
        If (cTab)->(!EOF())
            RU05XFN00C(cTab, cCliFor, cLoja, cDocNumber, cSerie)
        Else
            Help("", 1, "RU05XFN00B_ViewPrepayment",, STR0073, 1, 0)   // "Prepayments are not found"
        EndIf
        (cTab)->(DBCloseArea())
    EndIf
    RestArea(aArea)
Return nil


/*{Protheus.doc} RU05XFN00C_ViewPrepayment
@author Alexandra Velmozhnaia
@since 18/09/2020
@version 2.0
@param  cTab        Character   Alias to linked Prepayments
        cCliFor     Character   Client or Fornece Cod
        cLoja       Character   Client or Fornece Branch
        cDocNumber  Character   Document Number
        cSerie      Character   Document Serie
@return None
@edit astepanov 17 March 2023
@description
    The function show window with full information about linked advanced
*/
Function RU05XFN00C(cTab, cCliFor, cLoja, cDocNumber, cSerie)
    Local oDlg  as Object

    Local cTitPrep as Character

    Local cTitData as Character
    Local oSayData as Object
    Local oGetData as Object
    Local dGetData as Date

    Local cTitInv as Character
    Local oSayInv as Object
    Local oGetInv as Object

    Local cTitTotV as Character
    Local oSayTotV as Object
    Local oGetTotV as Object
    Local nTotVal as Numeric
    
    Local cTitTotSel as Character
    Local oSayTotSel as Object
    Local oGetTotSel as Object
    Local nTotSel as Numeric

    Local cTitTotRub as Character
    Local oSayTotRub as Object
    Local oGetTotRub as Object

    Local cTitExch as Character
    Local oSayExch as Object
    Local oGetExch as Object
    Local nExchRate as Numeric
 
    Local cTitSTExch as Character
    Local oSaySTExch as Object
    Local oGetSTExch as Object
    Local nSTExch as Numeric

    local nWidth as numeric
    local nHeight as numeric

    local nTotSelRub as Numeric
    Local nTotValRub    as Numeric   

    nWidth:=1640
    nHeight:=875

    cTitPrep := STR0074 //"Prepayment Visualization"
    cTitData := STR0075 //"Data:"
    If FunName() == "MATA101N"
        dGetData := SF1->F1_EMISSAO
    Else
        dGetData := SF2->F2_DTSAIDA
    EndIf
    cGetInv := Alltrim(cSerie) + "-" + cDocNumber

    If FunName() == "MATA101N"
        nTotVal := SF1->F1_VALBRUT
        nExchRate := IIf(SF1->F1_MOEDA > 1,SF1->F1_TXMOEDA, 1)
        nSTExch := Iif(SF1->F1_MOEDA > 1,RecMoeda(SF1->F1_EMISSAO,SF1->F1_MOEDA), 1)
    Else
        nTotVal := SF2->F2_VALBRUT
        nExchRate := IIf(SF2->F2_MOEDA > 1,SF2->F2_TXMOEDA, 1)
        nSTExch := Iif(SF2->F2_MOEDA > 1,RecMoeda(SF2->F2_DTSAIDA,SF2->F2_MOEDA), 1)
    EndIf
    nTotSel    := 0
    nTotSelRub := 0
    nTotValRub :=0 
    nTotValRub :=ROUND(nTotVal * nExchRate, GetSX3Cache("F2_VLBRUTM","X3_DECIMAL")) 
    aBrowse    := RU05XFN00D(cTab,@nTotSel,@nTotSelRub)

    cTitInv := STR0076 //"Invoice" 
    cTitTotV := AllTrim(RetTitle("F2_VALBRUT"))//"Total Value"
    cTitTotSel := STR0077 //"Selected Value"
    cTitTotRub :=  AllTrim(RetTitle("F2_VLBRUTM"))// "Total in Rubles"
    cTitExch := AllTrim(RetTitle("F2_TXMOEDA"))// "Tx Exchande rate"
    cTitSTExch := STR0078//"Standard Exchange rate"
 
    oDlg := TDialog():New(000,000,nHeight,nWidth,cTitPrep,,,,,,,,,.T.)
    oGBC:= tGridLayout():New(oDlg,CONTROL_ALIGN_ALLCLIENT)
    //Date - 1
    oSayData := TSay():New(01,01, {|| cTitData}, oGBC,,,,,,.T.,,,,,,,,,,.T.)
    oGetData := TGet():New(01,01,{ | u | If(PCount() == 0, dGetData, dGetData := u) },oGBC,80,009,"@d",, 0,,,.F.,,.T.,,.F.,,.F.,.F.,{||},.T.,.F. ,,"dGetData",,,,.T.)
    //Invoice - 2
    oSayInv := TSay():New(01,01, {|| cTitInv}, oGBC,,,,,,.T.,,,,,,,,,,.T.)
    oGetInv := TGet():New(01,01,{ | u | If(PCount() == 0, cGetInv, cGetInv := u) },oGBC,80,009,"@!",, 0,,,.F.,,.T.,,.F.,,.F.,.F.,{||},.T.,.F. ,,"cGetInv",,,,.T.)
    // //Total Value - 3
    oSayTotV := TSay():New(01,01, {|| cTitTotV}, oGBC,,,,,,.T.,,,,,,,,,,.T.)
    oGetTotV := TGet():New(01,01,{ | u | If(PCount() == 0, nTotVal, nTotVal := u) },oGBC,80,009,X3Picture("F2_VALBRUT"),, 0,,,.F.,,.T.,,.F.,,.F.,.F.,{||},.T.,.F. ,,"nTotVal",,,,.T.)
    // //Selected Value - 4
    oSayTotSel := TSay():New(01,01, {|| cTitTotSel}, oGBC,,,,,,.T.,,,,,,,,,,.T.)
    oGetTotSel := TGet():New(01,01,{ | u | If(PCount() == 0, nTotSel, nTotSel := u) },oGBC,80,009,X3Picture("F2_VALBRUT"),, 0,,,.F.,,.T.,,.F.,,.F.,.F.,{||},.T.,.F. ,,"nTotSel",,,,.T.)
    // //Total in Rubbles - 2
    oSayTotRub := TSay():New(01,01, {|| cTitTotRub}, oGBC,,,,,,.T.,,,,,,,,,,.T.)
    oGetTotRub := TGet():New(01,01,{ | u | If(PCount() == 0, nTotValRub, nTotValRub := u) },oGBC,80,009,X3Picture("F2_VLBRUTM"),, 0,,,.F.,,.T.,,.F.,,.F.,.F.,{||},.T.,.F. ,,"nTotValRub",,,,.T.)
    // //Tx Excange rate - 3
    oSayExch := TSay():New(01,01, {|| cTitExch}, oGBC,,,,,,.T.,,,,,,,,,,.T.)
    oGetExch := TGet():New(01,01,{ | u | If(PCount() == 0, nExchRate, nExchRate := u) },oGBC,80,009,X3Picture("F2_TXMOEDA"),, 0,,,.F.,,.T.,,.F.,,.F.,.F.,{||},.T.,.F. ,,"nExchRate",,,,.T.)
    // //Standard Excange rate - 4
    oSaySTExch := TSay():New(01,01, {|| cTitSTExch}, oGBC,,,,,,.T.,,,,,,,,,,.T.)
    oGetSTExch := TGet():New(01,01,{ | u | If(PCount() == 0, nSTExch, nSTExch := u) },oGBC,80,009,X3Picture("F2_TXMOEDA"),, 0,,,.F.,,.T.,,.F.,,.F.,.F.,{||},.T.,.F. ,,"nSTExch",,,,.T.)

    
    oBrowse := TCBrowse():New(00,00, 920, 390,, {RetTitle("FR3_PREFIX"),;
                                                RetTitle("FR3_NUM"),;
                                                RetTitle("FR3_PARCEL"),;
                                                RetTitle("FR3_TIPO"),;
                                                RetTitle("F2_MOEDA"),;
                                                RetTitle("CTO_SIMB"),;
                                                RetTitle("A1_COD"),;
                                                RetTitle("A1_NOME"),;
                                                RetTitle("FR3_VALOR"),;
                                                RetTitle("F2_TXMOEDA"),;
                                                RetTitle("F2_VLBRUTM")},;
                                                    {TamSx3("FR3_PREFIX")[1],;
                                                    TamSx3("FR3_NUM")[1],;
                                                    TamSx3("FR3_PARCEL")[1],;
                                                    TamSx3("FR3_TIPO")[1],;
                                                    TamSx3("F2_MOEDA")[1],;
                                                    TamSx3("CTO_SIMB")[1],;
                                                    TamSx3("A1_COD")[1],;
                                                    TamSx3("F2_TXMOEDA")[1],;
                                                    TamSx3("F2_VLBRUTM")[1]},;
                                                    oGBC,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

    oBrowse:SetArray(aBrowse)

    oBrowse:bLine := {||{ aBrowse[oBrowse:nAt,01],;
                          aBrowse[oBrowse:nAt,02],;
                          aBrowse[oBrowse:nAt,03],;
                          aBrowse[oBrowse:nAt,04],;
                          Transform(aBrowse[oBrowse:nAt,05],X3Picture("F2_MOEDA")),;
                          aBrowse[oBrowse:nAt,06],;
                          aBrowse[oBrowse:nAt,07],;
                          aBrowse[oBrowse:nAt,08],;
                          Transform(aBrowse[oBrowse:nAt,09],X3Picture("FR3_VALOR")),;
                          Transform(aBrowse[oBrowse:nAt,10],X3Picture("F2_TXMOEDA")),;
                          Transform(aBrowse[oBrowse:nAT,11],X3Picture("F2_VLBRUTM")) } }
    //Date - 1
    oGBC:addInLayout(oSayData,1,3,,1,LAYOUT_ALIGN_RIGHT + LAYOUT_ALIGN_TOP)
    oGBC:addInLayout(oGetData,1,4,,1,LAYOUT_ALIGN_HCENTER + LAYOUT_ALIGN_TOP)
    oGBC:addSpacer( 1, , ,2)
    //Invoice - 2
    oGBC:addInLayout(oSayInv,2,1,,1,LAYOUT_ALIGN_RIGHT + LAYOUT_ALIGN_TOP)
    oGBC:addInLayout(oGetInv,2,2,,1,LAYOUT_ALIGN_HCENTER + LAYOUT_ALIGN_TOP)
    // //Total Value - 3
    oGBC:addInLayout(oSayTotV,3,1,,1,LAYOUT_ALIGN_RIGHT + LAYOUT_ALIGN_TOP)
    oGBC:addInLayout(oGetTotV,3,2,,1,LAYOUT_ALIGN_HCENTER + LAYOUT_ALIGN_TOP)
    // //Selected Value - 4
    oGBC:addInLayout(oSayTotSel,4,1,1,1,LAYOUT_ALIGN_RIGHT + LAYOUT_ALIGN_TOP)
    oGBC:addInLayout(oGetTotSel,4,2,,1,LAYOUT_ALIGN_HCENTER + LAYOUT_ALIGN_TOP)
    // //Total in Rubbles - 2
    oGBC:addInLayout(oSayTotRub,2,3,,1,LAYOUT_ALIGN_RIGHT + LAYOUT_ALIGN_TOP)
    oGBC:addInLayout(oGetTotRub,2,4,,1,LAYOUT_ALIGN_HCENTER + LAYOUT_ALIGN_TOP)
    // //Tx Excange rate - 3
    oGBC:addInLayout(oSayExch,3,3,,1,LAYOUT_ALIGN_RIGHT + LAYOUT_ALIGN_TOP)
    oGBC:addInLayout(oGetExch,3,4,,1,LAYOUT_ALIGN_HCENTER + LAYOUT_ALIGN_TOP)
    // //Standard Excange rate - 4
    oGBC:addInLayout(oSaySTExch,4,3,,1,LAYOUT_ALIGN_RIGHT + LAYOUT_ALIGN_TOP)
    oGBC:addInLayout(oGetSTExch,4,4,,1,LAYOUT_ALIGN_HCENTER + LAYOUT_ALIGN_TOP)
    
    //oGBC:addSpacer(5, , 1)
    If FunName() $ "MATA101N|MATA467N"
        oTButton1 := TButton():New( 0, 0, STR0087, oGBC,{|| RU05XFN00X(cTab, cCliFor, cLoja, aBrowse[oBrowse:nAt], 1)}, 40,10,,,.F.,.T.,.F.,,.F.,,,.F.)
        oTButton2 := TButton():New( 0, 0, STR0095, oGBC,{|| RU05XFN00X(cTab, cCliFor, cLoja, aBrowse[oBrowse:nAt], 2)}, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
        oTButton3 := TButton():New( 0, 0, STR0096, oGBC,{|| RU05XFN00X(cTab, cCliFor, cLoja, aBrowse[oBrowse:nAt], 3)}, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
    EndIf
    
    oGBC:addInLayout(oTButton1, 6, 5, 1, LAYOUT_ALIGN_LEFT)
    oGBC:addInLayout(oTButton2, 6, 6, 1)
    oGBC:addInLayout(oTButton3, 6, 7, 1, LAYOUT_ALIGN_RIGHT)

    oGBC:addInLayout(oBrowse,7,1,,4,LAYOUT_ALIGN_HCENTER + LAYOUT_ALIGN_TOP)

    oDlg:Activate(,,,.T.,,,)

Return Nil

/*{Protheus.doc} RU05XFN00D_FillFR3Grid
@author Alexandra Velmozhnaia
@since 18/09/2020
@version 1.0
@param  cTab        Character   Alias of linked Prepayments
        nTotSel     Numeric     Selected value in document currency
        nTotInLocC  Numeric     Selected value in Local currency
@return None
@edit astepanov
@description
    The function returns data line of linked advanced
*/
Function RU05XFN00D(cTab,nTotSel,nTotInLocC)
    Local aRet as Array
    Local aArea as array
    Local nValInLocC as Numeric
    Local nRound     as Numeric
    Default nTotSel    := 0
    Default nTotInLocC := 0
    nRound := GetSX3Cache("F2_VLBRUTM","X3_DECIMAL")
    aArea := GetArea()
    aRet := {}
    dbSelectArea(cTab)
    (cTab)->(DbGoTop())
    While !(cTab)->(EOF())
        nTotSel    += (cTab)->FR3_VALOR
        nValInLocC := ROUND((cTab)->FR3_VALOR * (cTab)->TXMOEDA, nRound) // Value in rubles_THIS CALCULATION IS NOT CORRECT BECAUSE VALUE IN LOCAL CURRENCY SHOULD BE STORED IN FR3
        nTotInLocC += nValInLocC
        aAdd(aRet, {(cTab)->FR3_PREFIX,;
                    (cTab)->FR3_NUM,;
                    (cTab)->FR3_PARCEL,;
                    (cTab)->FR3_TIPO,;
                    (cTab)->MOEDA,; //Currency
                    Posicione("CTO", 1, xFilial("CTO")+StrZero((cTab)->MOEDA, TamSX3("CTO_MOEDA")[1]),"CTO_SIMB"),; //Currency Simbol
                    (cTab)->COD,; // Client of Fornece Cod
                    (cTab)->NOME,; // Client Name/Supplier(descr)
                    (cTab)->FR3_VALOR,;
                    (cTab)->TXMOEDA,; // Exchange Rate
                    nValInLocC})
        (cTab)->(DbSkip())
    EndDo
    RestArea(aArea)
Return aRet

/*{Protheus.doc} RU05XFN010_CheckModel
@author Artem Kostin
@since 06/02/2020
@version 1.0
@param oModel   - A model to be checked.
@param cModelIds - The name of the model to be checked.
@return lRet    - Idicates whether the model passed all checks or not.
@type function
@description
    The function checks:
        if parameter oModel has object type,
        if paramenter cModelIds equals the name of the model
        if the model is acivated
    If any of these checks is not passed, help message with the name of caller
    and decription of the issue will be displayed.
*/
Function RU05XFN010_CheckModel(oModel as Object, cModelIds as Character)
    Local lRet as Logical
    Local cProcessName	as Character

    lRet := .T.
    cProcessName := ProcName(1)

    If (ValType(oModel) != "O")
        lRet := .F.
        Help(" ", 01, cProcessName + ":01", , STR0014 + STR0015 + STR0016, 1, 1) // "Model is not an object."
    ElseIf !(oModel:GetId() $ cModelIds)
        lRet := .F.
        Help(" ", 01, cProcessName + ":02", , STR0014 + oModel:GetId() + STR0015 + cModelIds, 1, 1) // "Model is " + oModel:GetId() + ", not " + cModelIds
    ElseIf (!oModel:IsActive())
        lRet := .F.
        Help(" ", 01, cProcessName + ":03", , STR0014 + STR0015 + STR0017, 1, 1) // "Model is not activated."
    EndIf
Return lRet


/*/{Protheus.doc} RU05XFN011_MassInput
    (long_description)
    @type  Function
    @author Alexandra Velmozhnya
    @since date
    @version 1.0
    @param cAlias   Character Working Alias
    @return 
    @example
    (examples)
    @see (links_or_references)
    /*/
//-------------------------------
Function RU05XFN011(cAlias)
	Local nX := 0	
	Local aCmps     as Array
	Local aPar 	    as Array
	Local aFilCol	as Array
    Local aIndex    as Array
    Local aEditCols as Array
    Local aColTmp   as Array
    Local bFill     as Block
    Local lFin as Logical

    Local bSavSetKey	:= SetKey(VK_F4,Nil)
	Local bSavKeyF5		:= SetKey(VK_F5,Nil)
	Local bSavKeyF6		:= SetKey(VK_F6,Nil)
	Local bSavKeyF7		:= SetKey(VK_F7,Nil)
	Local bSavKeyF8		:= SetKey(VK_F8,Nil)
	Local bSavKeyF9		:= SetKey(VK_F9,Nil)
	Local bSavKeyF10	:= SetKey(VK_F10,Nil)
	Local bSavKeyF11	:= SetKey(VK_F11,Nil)

    Private cTmpPQs    as Character
    Private cExpFin    as Character
	Private oTmpPQs  as Object

    aCmps   :=	{}
    aFilCol := {}
    aPar := {}
    aColTmp := aClone(aCols)

	For nX := 2 To Len(aHeader)
        aAdd(aCmps,aHeader[nX][2])

        If aHeader[nX][10] <> "V"  //  X3_CONTEXT
	    	aAdd(aFilCol,aHeader[nX][2])
        EndIf
	Next nX
	If FunName() $ "MATA101N/MATA102N"
        bFill := {|| RU05XFN014(aCols, aHeader, "D1_COD")}
        aIndex := { {"D1_ITEM","D1_COD" }}
        cExpFin := "D1_DOC+' - '+D1_ITEM"
    EndIf

	If !Eval(bFill)
		Help("", 1, "MassInput",, STR0069, 1, 0)  //There are no items to be edited
	Else
		cTmpPQs	:= CriaTrab(,.F.)

		RU05XFN012(cAlias,aIndex)
		
		aAdd(aPar,{cAlias,cExpFin, aCmps,""})
		
		lFin :=  RU05XFN013(aPar[1,1],aPar[1,2],aPar[1,3],,aPar[1,4],oTmpPQs:GetRealName(),aFilCol)
        If lFin
			aEditCols := RU05XFN024(oTmpPQs:getalias())
            RU05XFN029(aEditCols, aCols, aCfgNf)
			oGetDados:Refresh()
		EndIf

		If oTmpPQs <> Nil
			oTmpPQs:Delete()
			oTmpPQs := Nil
		EndIf
	EndIf
	
    SetKey(VK_F4,bSavSetKey)
	SetKey(VK_F5,bSavKeyF5)
	SetKey(VK_F6,bSavKeyF6)
	SetKey(VK_F7,bSavKeyF7)
	SetKey(VK_F8,bSavKeyF8)
	SetKey(VK_F9,bSavKeyF9)
	SetKey(VK_F10,bSavKeyF10)
	SetKey(VK_F11,bSavKeyF11)
Return nil


/*{Protheus.doc} RU05XFN012_PQCreaTRB
@author Alexandra Velmozhnya
@since 03/12/2020
@version 1.0
@param none
@return None
@type function
@description Tmp table for approve/reject in group markbrowse
/*/
Function RU05XFN012(cAlias,aIndex)
	Local aFields   as Array
	Local nX        as Numeric
	Local nY        as Numeric
    Local cPref     as Character
	Local aArea := GetArea()

	/* Object creation*/
	oTmpPQs := FWTemporaryTable():New(cTmpPQs)

    cPref := Iif(SubStr(cAlias,1,1) == "S" ,SubStr(cAlias,2), cAlias)
	aFields := {}
	aAdd(aFields,{cPref+"_FILIAL"	, "C", TamSX3(cPref+"_FILIAL")[1], 00})
	For nX := 1 To Len(aHeader)
                    /*2 = FIELD_NAME, 8 = TYPE,        4 = SIZE,     5 = DECIMAL*/
		aAdd(aFields,{aHeader[nX][2], aHeader[nX][8], aHeader[nX][4],aHeader[nX][5]})
	Next
	
	oTmpPQs:SetFields(aFields)
    For nX := 1 to Len(aIndex)
        oTmpPQs:AddIndex("Indice"+(StrZero(nX+1,2)), aIndex[nX] )
    Next nX
	oTmpPQs:Create()
		For nX := 1 To Len(aCols)
			RecLock(oTmpPQs:GetAlias(),.T.)
                Replace D1_FILIAL  With xFilial(cAlias)				
                For nY := 1 To Len(aHeader)
                    If aCols[nX][nY] == nil
                        Replace (&(aHeader[nY][2]))  With "    "				
                    Else
                        Replace (&(aHeader[nY][2]))  With aCols[nX][nY]				
                    EndIf
                Next
			MsUnLock()
		Next
	RestArea(aArea)

Return .T.

/*{Protheus.doc} RU05XFN013_WizMassInput
@author Alexandra Velmozhnaya
@since 26/11/2020
@version 1.0
@param 
@return lRet
@type function
@description
    
*/
Function RU05XFN013(cAlias, cExpApFim, aFldEdit, aTxtHead,cPosiciona,tmpFile,aFldFilter)
Local lRet as Logical
Local lInverte as Logical
Local lFinish as Logical
Local aArea as Array
Local aFldParam as Array    //  array for customer settings for parameters
Local aMarkField as Array
Local aEditField as Array
Local aGrpField as Array
Local aCpos as Array
Local aTrb as Array
Local aPanels as Array  // array of titles for Wizard pages
Local aResume as Array
Local aTxtDescr	as Array
Local aCampos	as Array
Local aIndKey	as Array
Local aAux1 as Array
Local aAux2 as Array
Local aAux3 as Array
Local aBlock as Array

Local oWizard as Object
Local oTWBrow as Object
Local oMSSelect as Object
Local oWndFilter as Object  // Filter Window
Local oMemo as Object     
Local oTree as Object
Local oGetDad as Object
Local oDlgFinal as Object

Local nPage as Numeric
Local nX as Numeric

Local cTitTable as Character
Local cSearch as Character
Local cSearchGrp as Character
Local cFilter as Character
Local cDescFilter as Character
Local cCdBlock as Character
Local cMarc as Character
Local cMemo as Character
Local cFileLog as Character
Local cTexto as Character

Local aFldGroup := {"D1_ITEM","D1_COD","D1_QUANT","D1_TES","D1_CF","D1_CONTA","D1_ITEMCTA","D1_CC","D1_LOCAL","D1_CLVL","D1_LOCALIZ"}

Local	lGenerate	:=	.F.   
Local   oOk   	    := LoadBitmap( GetResources(), "LBOK")
Local   oNo	        := LoadBitmap( GetResources(), "LBNO")
Local 	cMask     	:= "Text files (*.TXT) |*.txt|"
Local	cFile		:=	""

Private aAlterRot   := {}
Private	aColsWiz	:= {}
Private	aHeadWiz	:= {}
Private	aHeadAux	:= {}
Private	aDescri		:= {}
private aVldUser	:= {}

Private	lPeDescri	:= .F.
Private lAgrupa :=  .F.

lRet := .F.
lInverte	:=	.F.
lFinish := .F.
aArea := GetArea()
aAux1 := {}
aAux2 := {}
aAux3 := {}
aBlock :={}
aFldParam := {}
aMarkField := {}
aEditField := {}
aGrpField := {}
aPanels := {}
aTxtDescr   := {}
aCampos		:=	{}
aIndKey		:=	{}
aDescri     := {}
aResume :=	{"","","",""}
cSearch	:=	Space(50)
cFilter := ""
cDescFilter := ""
cSearchGrp  :=   Space(50)
oWndFilter  := GetWndDefault()
cCdBlock    :=	""
cMarc		:=	GetMark()
cTexto      :=	""

    cTitTable 	:=	AllTrim(FWX2Nome(cAlias))

    DbSelectArea("SX3")
    SX3->(DBSetorder(2))
    For nX := 1 to Len(aFldEdit)
        If SX3->(DBSeek(aFldEdit[nX]))
            aAdd(aEditField, {.F.,aFldEdit[nX],X3Descric()})
        EndIf
    Next nX
    For nX := 1 to Len(aFldGroup)
        If SX3->(DBSeek(aFldGroup[nX]))
            aAdd(aGrpField,{aFldGroup[nX],X3Descric()})
        EndIf
    Next nX

    aSort(aEditField,,,{|x,y|x[2]<y[2]})
	aSort(aGrpField,,,{|x,y|x[1]<y[1]})

    aTrb	:=	RU05XFN016(1,aGrpField)
	aCpos 	:= 	{{"TRB_OK"  , 	"", STR0066,	""},;	//"Selection"
				{"TRB_CMP1",	"", STR0067,  	""},;	//"Field"
				{"TRB_CMP2", 	"", STR0068, 	""}} //"Description"

// Entry points block

    If ExistBlock('MA300003')
        For nX:= 1 To Len(aEditField)
            aAdd(aAux1, aEditField[nX][2])
        Next nX
        For nX:= 1 To Len(aGrpField)
            aAdd(aAux2, aGrpField[nX][1])
        Next nX
        For nX:= 1 To Len(aFldFilter)
            aAdd(aAux3, alltrim(aFldFilter[nX]))
        Next nX
        aAdd(aBlock, aAux1)
        aAdd(aBlock, aAux2)
        aAdd(aBlock, aAux3)		
        aBlock := Execblock('MA300003',.F.,.F.,aBlock)
        aAux1 := {}
        aAux2 := {}
        aAux3 := {}
        
        For nX:= 1 To Len(aBlock[1])
            If aScan(aEditField,{|aX| Alltrim(aX[2]) == Alltrim(aBlock[1][nX])}) > 0 
                aAdd(aAux1,aEditField[aScan(aEditField,{|aX| Alltrim(aX[2]) == Alltrim(aBlock[1][nX])})])
            Endif 
        Next nX
        If len(aAux1)> 0 
            aEditField := aAux1
        Endif 

        For nX:= 1 To Len(aBlock[2])
            If aScan(aGrpField,{|aX| AllTrim(aX[1]) == Alltrim(aBlock[2][nX])}) > 0 
                aAdd(aAux2,aGrpField[ aScan(aGrpField, {|aX| Alltrim(aX[1]) == Alltrim(aBlock[2][nX])})])
            Endif 
        Next nX

        If len(aAux2)> 0 
            aGrpField := aAux2
        Endif 

        For nX:= 1 To Len(aBlock[3])
            If aScan(aFldFilter,{|aX| Alltrim(aX) == Alltrim(aBlock[3][nX])}) > 0 
                aAdd(aAux3,aFldFilter[aScan(aFldFilter,{|aX| Alltrim(aX) == Alltrim(aBlock[3][nX])})])
            Endif 
        Next nX

        If len(aAux3)> 0 
            aFldFilter := aAux3
        Endif 

	EndIf
    If ExistBlock('MA300002')
        aDescri := Execblock('MA300002',.F.,.F.,aCampos)
        If !empty(aDescri)
            lPeDescri:=.T.
        Endif 
    EndIf

    If Empty(aTxtHead) 
        aTxtHead := {STR0063, STR0064, cAlias + cTitTable, STR0065} //### Facilitator ### cMsg ### This technical staff enables simplified maintenance of registration information of certain tables, according to criteria defined in execution of routine wizard.
    EndIf

    cDesc	:=	STR0057	            //  To change the warehouse and storage address, you must select the check boxes for the fields that will change in the receipt document. A prerequisite for changing the storage address is the user must check the box opposite the warehouse field, since the storage address is tied to the warehouse.
    aAdd(aPanels,{STR0018, STR0019, cDesc}) 	//### Fields to be modified... ###	1/6 - In this step you must select the fields to be modified in the respective register		

    cDesc	:=	STR0058             // When choosing a filter for mass change, the user can select the materials he needs or other characteristics that will be selectively changed. A filter is configured by attribute, subsequently the mass change is applied only for the rows that are specified in the filter.
    aAdd(aPanels,{STR0020, STR0021, cDesc})     //### Filter... ### 2/5 - In this step we can enter a filter in order to restrain changes in file.

    cDesc	:=	STR0059             // When selecting the grouping fields, the user limits the total results by mass change. The fields are grouped if the filter from the previous window is used. The values from the filter are grouped by other system fields and displayed in the next window. If there is no filter and grouping needs, click the 'Next' button.
    aAdd(aPanels,{STR0022, STR0023, cDesc})     //### Group... ### 3/5 - In this step we created a group to edit the selected information.

    cDesc	:=	STR0060             // Select the code of the warehouse where the goods are received, then select the storage address (specification) where the materials will be placed.
    aAdd(aPanels,{STR0024, STR0025, cDesc})     //### Editing:  ### In this step, we are changing the fields to new values.

    cDesc	:=	STR0061+AllTrim("SD1")+" - "+cTitTable        // This window displays a summary of all the previous steps, what fields we used, filters and groupings. The window is for informational purposes, if you are sure of your data, click 'Finish', and then the system will start the bulk change.
    aAdd(aPanels,{STR0026, STR0027, cDesc})	    //### Summary: ### At this step, the system shows us all the options for selection and future changes.

    // additional descriptions of pages
    If ExistBlock('MA300005')
        aTxtDescr := Execblock('MA300005',.F.,.F.,{aTxtHead, aPanels})
        If !Empty(aTxtDescr)
            aTxtHead := aClone(aTxtDescr[1])
            aPanels := aClone(aTxtDescr[2])
        EndIf
    EndIf

    oWizard := APWizard():New(	aTxtHead[1]/*<chTitle>*/,;    
								aTxtHead[2]/*<chMsg>*/,;
  								aTxtHead[3]/*<cTitle>*/,;
								aTxtHead[4]/*<cText>*/,;
	  							{|| .T.}/*<bNext>*/, ;
								{|| .T. }/*<bFinish>*/,;
								/*<.lPanel.>*/, , , /*<.lNoFirst.>*/) 

    For nPage := 1 To 5

        oWizard:NewPanel( aPanels[nPage][1]/*<chTitle>*/,; 
                        aPanels[nPage][2]/*<chMsg>*/,;
                        {|| RU05XFN019(oWizard,oTree,@cMemo)}/*<bBack>*/,;	
        				{|| RU05XFN017(oWizard,oTWBrow,cAlias,cFilter,@oGetDad,@aResume,cTitTable,cDescFilter,cMarc,@cCdBlock,@aCampos,oTree,@aIndKey,;
                                        TMPFILE,aEditField,@aGrpField,@aTrb)}/*<bNext>*/, ;
                        {||  lFinish:= RU05XFN030(oWizard, @lRet)}/*<bFinish>*/,;
                        .T./*<.lPanel.>*/,;
                        {|| .T.}/*<bExecute>*/ )

        //(1/5) Select modified Fields
        If nPage == 1
            TSay():New(05, 05, &("{||aPanels["+AllTrim(Str(nPage))+"][3]}"), oWizard:oMPanel[nPage+1],,,.F.,.F.,.F., .T., CLR_BLUE,, 275, 50, .F., .F., .F., .F., .F.)

            TGroup():New( 29/*[ nTop ]*/,  05/*[ nLeft ]*/, 132/*[ nBottom ]*/, 282/*[ nRight ]*/, STR0030/*[ cCaption ]*/, oWizard:oMPanel[nPage + 1]/*[ oWnd ]*/, /*[ nClrText ]*/, /*[ nClrPane ]*/, .T./*[ lPixel ]*/, /*[ uParam10 ]*/ )   //Fields to be edited

            oTWBrow := TWBrowse():New(54,10,266,66 ,,{" ",STR0067,STR0068},{20,30,30},oWizard:oMPanel[nPage + 1],,,,,,,,,,,,.F.,,.T.,,.F.,,,)	//"##Field","##Description"
            oTWBrow:SetArray(aEditField)          
            oTWBrow:bLine := {||{If(aEditField[oTWBrow:nAt,01],oOK,oNO),aEditField[oTWBrow:nAt,02],aEditField[oTWBrow:nAt,03]} }
            // Change the image by double-clicking the mouse
            oTWBrow:bLDblClick := {|| aEditField[oTWBrow:nAt][1] := !aEditField[oTWBrow:nAt][1], oTWBrow:DrawSelect()}
            // panel searching 
            TSay():New (40, 150, {||STR0031}, oWizard:oMPanel[nPage + 1],,,.F.,.F.,.F., .T.,,, 100, 10, .F., .F., .F., .F., .F.)	//"Search"
            TGet():New (38, 176, {|u| Iif(PCount()==0,cSearch,cSearch:=u)}, oWizard:oMPanel[nPage + 1], 100, 9, "",{||RU05XFN015(1,oTWBrow,cSearch,aEditField)},,,,,, .T.)

        //(2/5) Set Filter
        ElseIf nPage == 2
            TSay():New (05, 05, &("{||aPanels["+AllTrim(Str(nPage))+"][3]}"), oWizard:oMPanel[nPage+1],,,.F.,.F.,.F., .T., CLR_BLUE,, 275, 50, .F., .F., .F., .F., .F.)

            TGroup():New( 40/*[ nTop ]*/, 05/*[ nLeft ]*/, 132/*[ nBottom ]*/, 250/*[ nRight ]*/, STR0032/*[ cCaption ]*/, oWizard:oMPanel[nPage + 1]/*[ oWnd ]*/, /*[ nClrText ]*/, /*[ nClrPane ]*/, .T./*[ lPixel ]*/, /*[ uParam10 ]*/ )    //Filter

            @50,10 GET oDescFilter VAR cDescFilter MEMO SIZE 235,74 OF oWizard:oMPanel[nPage+1] PIXEL READONLY

            SButton():New( 44/*[ nTop ]*/, 255/*[ nLeft ]*/, 17/*[ nType ]*/, {|/*cFilter, cDescFilter*/| cFilter  := BuildExpr(cAlias,oWndFilter,cFilter,.T.,,,aFldFilter),;
                                                                                cDescFilter := MontDescr(cAlias,cFilter),;
                                                                                oDescFilter:Refresh()}/*[ bAction ]*/, oWizard:oMPanel[nPage+1]/*[ oWnd ]*/, .T./*[ lEnable ]*/, /*[ cMsg ]*/, {|| .T./*nOpc == INCLUIR .OR. nOpc == ALTERAR */}/*[ bWhen ]*/ )

        //(3/5) Select grouping fields
        ElseIf nPage == 3
            TSay():New (05, 05, &("{||aPanels["+AllTrim(Str(nPage))+"][3]}"), oWizard:oMPanel[nPage+1],,,.F.,.F.,.F., .T., CLR_BLUE,, 275, 50, .F., .F., .F., .F., .F.)

            TGroup():New( 35/*[ nTop ]*/, 05/*[ nLeft ]*/, 132/*[ nBottom ]*/, 282/*[ nRight ]*/, STR0033/*[ cCaption ]*/, oWizard:oMPanel[nPage + 1]/*[ oWnd ]*/, /*[ nClrText ]*/, /*[ nClrPane ]*/, .T./*[ lPixel ]*/, /*[ uParam10 ]*/ )    //Grouping field

            oMSSelect	:=	MsSelect():New ("TRB", "TRB_OK",,aCpos, @lInverte, @cMarc, {60, 10, 126, 276},,,oWizard:oMPanel[nPage+1])
            oMSSelect:oBrowse:lHasMark 	:= 	.f.
            oMSSelect:oBrowse:lCanAllMark	:=	.f.

            TSay():New (46, 150, {||STR0031}, oWizard:oMPanel[nPage+1],,,.F.,.F.,.F., .T.,,, 100, 10, .F., .F., .F., .F., .F.)	//"Search"
            TGet():New (44, 176, {|u| Iif(PCount()==0,cSearchGrp,cSearchGrp:=u)}, oWizard:oMPanel[nPage+1], 100, 9, "",{||RU05XFN015(2,oMSSelect,cSearchGrp,aGrpField)},,,,,, .T.)
        //(4/5) Editor
        ElseIf nPage == 4
            TSay ():New (05, 05, &("{||aPanels["+AllTrim(Str(nPage))+"][3]}"), oWizard:oMPanel[nPage+1],,,.F.,.F.,.F., .T., CLR_BLUE,, 275, 30, .F., .F., .F., .F., .F.)

        //(5/5) Appliing changes
        ElseIf nPage == 5
            TSay ():New (05, 05, &("{||aPanels["+AllTrim(Str(nPage))+"][3]}"), oWizard:oMPanel[nPage+1],,,.F.,.F.,.F., .T., CLR_BLUE,, 275, 30, .F., .F., .F., .F., .F.)
            TGroup():New( 40/*[ nTop ]*/, 05/*[ nLeft ]*/, 132/*[ nBottom ]*/, 282/*[ nRight ]*/, STR0034/*[ cCaption ]*/, oWizard:oMPanel[nPage + 1]/*[ oWnd ]*/, /*[ nClrText ]*/, /*[ nClrPane ]*/, .T./*[ lPixel ]*/, /*[ uParam10 ]*/ )    //Resume

			@ 50,120 GET oMemo VAR cMemo MEMO SIZE 156,77 OF oWizard:oMPanel[nPage+1] PIXEL READONLY

            oTree	:=	DbTree():New(50, 10, 127, 115, oWizard:oMPanel[nPage+1],,,.T.)
            oTree:AddItem(PadR(STR0034,20), "L1"+StrZero(0, 2, 0), 'FOLDER5','FOLDER6',,,1)	//"Resume"

            oTree:TreeSeek("L1"+StrZero(0, 2, 0))
            oTree:AddItem(STR0030, "L2"+StrZero(1, 2, 0), 'PMSEDT3','PMSEDT3',,,2)	//"Fields to be edited"
            oTree:AddItem(STR0032, "L2"+StrZero(2, 2, 0), 'PMSEDT3','PMSEDT3',,,2)	//"Filter"
            oTree:AddItem(STR0035, "L2"+StrZero(3, 2, 0), 'PMSEDT3','PMSEDT3',,,2)	//"Group"
            
            oTree:lShowHint := .T.
            oTree:bLClicked := {|| RU05XFN020(oTree, @cMemo, aResume), oMemo:Refresh()}
        EndIf
    Next nPage

// Activate
    oWizard:Activate( .T./*<.lCenter.>*/,;
								 {||.T.}/*<bValid>*/, ;
								 {||.T.}/*<bInit>*/, ;
								 {||.T.}/*<bWhen>*/ )

    If lRet .And. lFinish
        //Processing registration table update
        cFileLog := Criatrab(,.f.)+".LOG"
        Processa({|lEnd| lGenerate := RU05XFN018(aCampos,oGetDad,cAlias,cFilter,cCdBlock,aIndKey,tmpFile,aDescri)},STR0036,STR0037,.F.) //"Prepare data ..."###"Processing update"

        If lGenerate
            cTexto += CRLF
            cTexto += STR0038;
                    + cFileLog + "." //"CONCLUSION: A copy of content displayed in screen of system directory STARTPATH was created, file  "+cFileLog+"."
        Else
            cTexto += STR0039   // None
            cTexto += CRLF+CRLF
            cTexto += STR0040   //STATUS: Update NOT made because there was NO change in board 4/5 edition.
        EndIf
        RU05XFN027(cFileLog,cTexto)

        DEFINE MSDIALOG oDlgFinal TITLE STR0041 From 3,0 to 340,417 PIXEL //"Problem With Update"
        @ 5,5 GET oMemo VAR cTexto MEMO SIZE 200,145 OF oDlgFinal PIXEL READONLY
        oMemo:bRClicked := {||AllwaysTrue()}
        DEFINE SBUTTON FROM 153,175 TYPE  1 ACTION oDlgFinal:End() ENABLE OF oDlgFinal PIXEL //Apaga
        DEFINE SBUTTON FROM 153,145 TYPE 13 ACTION (cFile:=cGetFile(cMask,""),If(cFile="",.T.,MemoWrite(cFile,cTexto))) ENABLE OF oDlgFinal PIXEL //Salva e Apaga //"Salvar Como..."
        oDlgFinal:Activate(,,, .T.)
    EndIf

    RU05XFN016(2, aGrpField, aTrb)
    If Select("TRB") > 0
        TRB->(DBCloseArea())
    EndIf
	dbSelectArea(cAlias)

RestArea(aArea)
Return lRet

/*/{Protheus.doc} RU05XFN014_EmptyGrid
    (long_description)
    @type  Function
    @author user
    @since 03/12/20
    @version 1.0
    @param  param       param_type  param_descr
            aGrid       Array       Array of Grid records       
            aHeadGrid   Array       Array of Fields Name
            cSearch     Character   Field which indicate not empty grid
    @return lRet        Logical     return .T. if grid is not empty and all parameters correct  
    @example
        RU05X0013(aCols, aHeader, 'D1_COD')
    @see -
    /*/
Function RU05XFN014(aGrid, aHeadGrid, cSearch)
local lRet as Logical
Local nPos as Numeric

Default aGrid := {}
Default aHeadGrid := {}
Default cSearch := ""

If (ValType(aGrid) == "A" .And. Len(aGrid) != 0) .And. (ValType(aHeadGrid) == "A" .And. Len(aHeadGrid) != 0) .And. !Empty(cSearch)
    nPos := aScan(aHeadGrid, {|x| AllTrim(x[2]) == AllTrim(cSearch)  })
    If nPos > 0
        lRet := !Empty(aCols[1][nPos])
    Else
	lRet := .F.
    EndIf
Else
	lRet := .F.
EndIf
Return lRet

/*{Protheus.doc} RU05XFN015
@author Alexandra Velmozhnaya
@since 30/11/2020
@version 1.0
@param nOption -> Function call option. 
            1 = First assistant
            2 = Second assistant.
        oObj -> Search object created
        cSearch -> Search content entered
        aGridSeek -> Array with the items to be searched.
@return
@type function
@description Searching
*/
Function RU05XFN015(nOption, oObj,cSearch,aGridSeek) 
Local nPos as Numeric

//Search by field name
If nOption==1
    nPos	:=	aScan(aGridSeek,{|aX|  (AllTrim(cSearch)==Left(aX[2],Len(AllTrim(cSearch)))) .Or.;
                                (AllTrim(cSearch) $ Alltrim(aX[3])) })

	oObj:nAT := Iif(nPos==0,1,nPos)
	oObj:Refresh()
Else
    nPos	:=	aScan(aGridSeek,{|aX|  (AllTrim(cSearch)==Left(aX[1],Len(AllTrim(cSearch)))) .Or.;
                                (AllTrim(cSearch) $ Alltrim(aX[2])) })
	dbSelectArea("TRB")
	TRB->(dbSeek(AllTrim(cSearch)))
	oObj:oBrowse:Refresh()
EndIf
Return .T.

/*{Protheus.doc} RU05XFN016_MontTrb
@author Alexandra Velmozhnaya
@since 30/11/2020
@version 1.0
@param nOption -> Function call option. 
            1 = Creation
            2 = Delete
        aList2 -> Array with all user fields of the table involved
        aTrb -> Array with the created work space
        aGridSeek -> Array with the items to be searched.
@return
@type function
@description Searching
*/
Function RU05XFN016(nOption, aList2, aTrb)
Local	aStru	:=	{}
Local	cArq	:=	""
Local	nI		:=	0

Default	aTrb	:=	{}

If (nOption==1)
	aAdd(aStru,{"TRB_OK",	"C",	002,					0})
	aAdd(aStru,{"TRB_CMP1",	"C",	Len(SX3->X3_CAMPO),		0})
	aAdd(aStru,{"TRB_CMP2",	"C",	Len(SX3->X3_DESCRIC),	0})
	
	cArq	:=	CriaTrab(aStru)
	dbUseArea(.T., __LocalDriver, cArq, "TRB")
	IndRegua("TRB", cArq, "TRB_CMP1")
	
	aTrb	:=	{"TRB",cArq}
	
	For nI := 1 To Len(aList2)
		RecLock("TRB", .T.)
			TRB->TRB_CMP1	:=	aList2[nI,1]
			TRB->TRB_CMP2	:=	aList2[nI,2]
		MsUnLock()
	Next nI
	dbGoTop()
Else
	DbSelectArea(aTrb[1])
	(aTrb[1])->(DbCloseArea())
	Ferase(aTrb[2]+GetDBExtension())
	Ferase(aTrb[2]+OrdBagExt())
EndIf

Return aTrb

/*{Protheus.doc} RU05XFN017_ValPainel
@author Alexandra Velmozhnaya
@since        02/12/20                                       
@param  oWizard     Object      Object of Wizard
        oTWBrow     Object      Browse object to select the field to be changed
        cAlias      Character   Reference table alias.                 
        cFilter     Character   Filter selected in the routine assistant.        
        oGetDad     Object      Routine update browse getdados object
        aResume     Array       Texts of the final summary presented before starting the update.                                   
        cTitTable   Character   Title of the table being processed.    
        cDescFilter Character   Full description of the selected filter.
        cMarc       Character   Returned GETMARK()                              
        cCdBlock    Character   Product verification codeblock for modification.                                                       
        aFields     Array       Field name that can be updated.          
        oTree       Object      TREE object presented in the processing summary
        aIndKey     Array       Key table fields based on the index if no field is selected in the grouping for editing.
        tmpFile     Character   Name of temporary table with aCols Values        
        aEditField  Array       Array editable fields 
        aGrpField   Array       Array grouping field
        aTrb        Array       Array with the created work space
@Return lRet        Logical    .T. or  .F.  
@Description Validation of wizard panel changes
/*/
Function RU05XFN017(oWizard,oTWBrow,cAlias,cFilter,oGetDad,aResume,cTitTable,cDescFilter,cMarc,cCdBlock,aFields,oTree,aIndKey,;
                tmpFile,aEditField,aGrpField,aTrb)
Local	lRet	:=	.T.
Local	nI		:=	0 
Local   nX		:=	0 
Local   nHead	:=	0
Local 	nPos 	:=	0
Local 	nLen 	:=	0
// Local 	aExcl 	:=	{}

//lAgrupa := (nRadio == 2)

If oWizard:nPanel==4
    aFields := {}
	Processa({|lEnd| lRet := RU05XFN021(oWizard,oTWBrow,cAlias,cFilter,@oGetDad,cMarc,@cCdBlock,@aFields,@aIndKey,tmpFile)},STR0042,STR0037,.F.) //"Update ..."###"Processing update"
	If !lRet
		MsgAlert(STR0043)   //No records found for later updates. Check the configurations provided in the previous frames of the routine wizard.
	Else
		TRB->(dbGoTop())
	EndIf
ElseIf oWizard:NPANEL==2
	For nX:= 1 To Len(aEditField)
		If aEditField[nx][1]
			nPos:= aScan(aGrpField,{|aX| Alltrim(aX[1]) == Alltrim(aEditField[nx][2])})
			If nPos> 0 
				//aAdd(Aexcl,aGrpField[nPos][1])
				adel(aGrpField,nPos)	
				nlen:= 	len(aGrpField)
				aSize(aGrpField,nLen-1)
			Endif 	
		ENDIF
	Next nX
	RU05XFN016(2, aGrpField, aTrb)
	aTrb	:=	RU05XFN016(1,aGrpField)
	TRB->(dbGoTop())
ElseIf oWizard:nPanel==5 .And. oGetDad<>Nil .And. Len(oGetDad:aCols)>0
	aResume		:=	{"","","",""}
    
	aResume[1]	+=	STR0044     //Check the summary by clicking one of the options on the left.
	
	aResume[2]	+=	STR0045     //The following fields have been selected to change: 
	
	For nX:= 1 To Len(aFields)
		nHead:= aScan(aheadwiz,{|aX| Alltrim(aX[2]) == Alltrim(aAlterRot[nX])})
		aResume[2]	+= "[" + oGetDad:aHeader[nHead,1]+"]" 
	Next nX

	If(Empty(cFilter))
		aResume[3]	+=	STR0039     //None
	Else
		aResume[3]	+=	STR0049+AllTrim(cAlias) + " - " + cTitTable;    // A filter was selected in the routine wizard and identified that only the records in table '
        +STR0050 + AllTrim(cDescFilter) + STR0051   //### ' meeting the condition ' ###' must be updated when processing the routine.
	EndIf
    
	If lAgrupa 
        aResume[4]	+=	STR0052 //### The following fields were used for grouping:   ### ' by '
        For nI := 1 To Len(oGetDad:aHeader)
            If ( "TRB_CMP" $ oGetDad:aHeader[nI,2])
                aResume[4]	+= "[" + oGetDad:aHeader[nI,1] + "] "
            EndIf
        Next nI
    Else
        aResume[4]	+=	STR0039     //None
    EndIf
	oTree:TreeSeek("L1"+StrZero(0, 2, 0))
EndIf

Return lRet

/*{Protheus.doc} RU05XFN018_Atualiza
@author Alexandra Velmozhnaya
@since        02/12/20
@param  aCampos     Array       Field name that can be updated. 
        oGetDad     Object      Routine update browse getdados object
        cAlias      Character   Reference table alias.
        cFilter     Character   Filter selected in the routine assistant.
        cCdBlock    Character   Product verification codeblock for modification.    
        aIndKey     Array       Key table fields based on the index if no field is selected in the grouping for editing.
        tmpFile     Character   Name of temporary table with aCols Values
        aDescri     Array       Array of Description
@Return lRet         Logical    .T. or  .F.
@Description Update function of the table involved.
/*/
Function RU05XFN018(aCampos,oGetDad,cAlias,cFilter,cCdBlock,aIndKey,tmpFile,aDescri)
Local aAreaSX3		:= SX3->( GetArea() )
Local lRet			:= .F.
Local aAreaAnt		:= {}
Local aHeadsWiz		:= {}
Local cAliasAnt		:= cAlias
Local nX			:= 0

// lAgrupa 		:= nRadio == 2

aColsWiz	:=	oGetDad:aCols
aHeadsWiz	:=	oGetDad:aHeader

DbSelectArea(cAlias)
(cAlias)->(DbSetOrder (1))
aAreaAnt	:= (cAliasAnt)->(GetArea())

If !lAgrupa
    lRet:= RU05XFN025(tmpFile,aCampos,aColsWiz[1],cFilter,aHeadsWiz,aHeadAux,aDescri)
Else
    For nX:= 1 To Len(aColsWiz)			
        lRet:= RU05XFN026(tmpFile,aColsWiz[nX],cFilter,aHeadsWiz,aHeadAux,aDescri)
        If !lRet
            Exit
        EndIf  
    Next nX
EndIf

If ExistBlock('MA300007')
	Execblock('MA300007',.F.,.F.,{tmpFile, aCampos})
EndIf

dbSelectArea(cAlias)
dbCloseArea()

RestArea(aAreaSX3)
RestArea(aAreaAnt)
Return lRet


/*{Protheus.doc} RU05XFN019_BkPainel
@author Alexandra Velmozhnaya
@since        02/12/20
@param  oWizard     Object      Object of Wizard
        oTree       Object      TREE object presented in the processing summary
        cMemo       Character   Initial firs text of last step
@Return lRet         Logical    .T. or  .F.
@Description Validation function when returning the routine assistant. Used to reset the memo variable when you return to the wizard.
/*/
Function RU05XFN019(oWizard,oTree,cMemo)
Local	lRet	:=	.T.

If oWizard:NPANEL==5
	oTree:TreeSeek("L1"+StrZero(0, 2, 0))
	cMemo	:=	STR0044 //Check the summary by clicking one of the options on the left.
EndIf

Return lRet


/*{Protheus.doc} RU05XFN020_MontClick
@author Alexandra Velmozhnaya
@since  02/12/20
@param  oTree       Object      TREE object presented in the processing summary
        cMemo       Character   Initial firs text of last step
        aResume     Array       Texts of the final summary presented before starting the update.
@Return lRet        Logical    .T. or  .F.
@Description Presentation of the summary when clicking on one tree options.
/*/
Function RU05XFN020(oTree, cMemo, aResume)
Local	lRet	:=	.T.

If ("L1"$oTree:GetCargo())
	cMemo	:=	""
	cMemo	+=	aResume[1]
ElseIf ("L201"$oTree:GetCargo())
	cMemo	:=	""
	cMemo	+=	aResume[2]
ElseIf ("L202"$oTree:GetCargo())
	cMemo	:=	""
	cMemo	+=	aResume[3]
ElseIf ("L203"$oTree:GetCargo())
	cMemo	:=	""
	cMemo	+=	aResume[4]	
EndIf
Return lRet  
/*{Protheus.doc} RU05XFN021_ProcWiz
@author Alexandra Velmozhnaya
@since  02/12/20                                       
@param  oWizard     Object      Object of Wizard
        oTWBrow     Object      Browse object to select the field to be changed
        cAlias      Character   Reference table alias.                 
        cFilter     Character   Filter selected in the routine assistant.        
        oGetDad     Object      Routine update browse getdados object
        cMarc       Character   Returned GETMARK()
        cCdBlock    Character   Product verification codeblock for modification.    
        aFields     Array       Field name that can be updated
        aIndKey     Array       Key table fields based on the index if no field is selected in the grouping for editing
        tmpFile     Character   Name of temporary table with aCols Values
@Return lRet        Logical    .T. or  .F.  
@Description Validation of wizard panel changes.
/*/
Function RU05XFN021(oWizard,oTWBrow,cAlias,cFilter,oGetDad,cMarc,cCdBlock,aFields,aIndKey,tmpFile)
Local lRet		:=	.F.
Local nI			:=	1
Local aGroupFld	:=	{}
Local aAreaAnt	:=  {}
Local cSelect	:=  ''
Local cAliasAnt	:=	cAlias  
Local nX        := 0
Local cQuery as Character
Local cTab as Character
Local cFieldOk as Character

aColsWiz	:=	{}
cCampo		:=	AllTrim(oTWBrow:aArray[oTWBrow:nAT,2])
cCdBlock	:=	"aScan(aColsWiz,{|aX| "
lAgrupa := .F.

cFieldOk := "RU05XFN028(aHeadWiz,aColsWiz,aHeadAux,aDescri,aVldUser)"

If Empty(aFields)
	For nX := 1 to Len(oTWBrow:aArray)   
		If oTWBrow:aArray[nX,1]
			aAdd(aFields,oTWBrow:aArray[nX,2])                                  
		EndIf
	Next nX      
EndIf
	
TRB->(dbGoTop())
While !TRB->(Eof())
	If TRB->TRB_OK==cMarc
		aAdd(aGroupFld,TRB->TRB_CMP1)
		cCdBlock +=	"Alltrim(aX[" + AllTrim(Str(nI++)) + "])=="+AllTrim(TRB->TRB_CMP1) + ".And."	
        lAgrupa := .T.
	EndIf
	TRB->(dbSkip())
End

If Len(aIndKey) == 0
	aIndKey	:=	&("{'"+StrTran(AllTrim((cAlias)->(IndexKey())),"+","','")+"'}")
	aDel(aIndKey,1)
	aSize(aIndKey,Len(aIndKey)-1)
EndIf                            

If !Empty(aGroupFld)
	 RU05XFN022(aFields,@cCdBlock,aGroupFld,nI)
Else
	For nI := 1 To Len(aIndKey)
		cCdBlock	+=	"aX["+AllTrim(Str(nI))+"]=="+AllTrim(aIndKey[nI])+".And."
	Next nI	
	RU05XFN022(aFields,@cCdBlock,aGroupFld,Len(aIndKey)+1)
	aGroupFld	:=	aClone(aIndKey)
EndIf               

// Function that assembles ACOLS and AHEADER
aAlterRot:= RU05XFN023(aGroupFld,aFields,aDescri)   

aAreaAnt	:= (cAliasAnt)->(GetArea())
DbSelectArea(cAlias)
(cAlias)->(DbSetOrder(1))
cSelect := ""

If lAgrupa
    For nI := 1 To Len(aFields)
        cSelect += aFields[nI]+","
    Next nI
    For nI := 1 To Len(aGroupFld)
        cSelect += aGroupFld[nI]+","
    Next nI
    cSelect := SubStr(cSelect,1,Len(cSelect)-1)
    
    cQuery := " SELECT " + cSelect 
    cQuery += " FROM " + tmpFile
    If ! EMPTY(cFilter)
        cQuery += " WHERE " + cFilter
    ENDIF
    cQuery += " GROUP BY " + cSelect

    cQuery := ChangeQuery(cQuery)
    cTab := CriaTrab( , .F.)
    TcQuery cQuery New Alias ((cTab))
    DbSelectArea((cTab))
    (cTab)->(DbGoTop())

    While (cTab)->(!Eof())
        lRet	:=	.T.
        If Len(aColsWiz) == 0 .Or. (nPos := &(cCdBlock)) == 0
            aAdd(aColsWiz,{})
            For nI := 1 To Len(aGroupFld)
                aAdd(aTail(aColsWiz),&(aGroupFld[nI]))
            Next nI

            For nX:= 1 To Len(aFields)
                aAdd(aTail(aColsWiz),&(aFields[nX]))
                aAdd(aTail(aColsWiz),&(aFields[nX]))
                If lPeDescri
                    If aScan(aDescri,{|aX| Alltrim(aX[1]) == alltrim(aFields[nx])}) > 0 
                        nScan:= aScan(aDescri,{|aX| Alltrim(aX[1]) == Alltrim(aFields[nX])})
                        aAdd(aTail(aColsWiz),PadR("",TamSX3(aDescri[nScan][2])[1]))
                    EndIf 
                EndIf
            Next nX
            aAdd(aTail(aColsWiz),.F.)
        EndIf
        (cTab)->(DbSkip())
    EndDo      
Else
    lRet	:=	.T.
    aAdd(aColsWiz,{})
    For nX:= 1 To Len(aFields)
        aAdd(aTail(aColsWiz),PadR("",TamSX3(aFields[nX])[1]))
        If lPeDescri
            If aScan(aDescri,{|aX| Alltrim(aX[1]) == alltrim(aFields[nx])}) > 0 
                nScan:= aScan(aDescri,{|aX| Alltrim(aX[1]) == Alltrim(aFields[nX])})
                aAdd(aTail(aColsWiz),PadR("",TamSX3(aDescri[nScan][2])[1]))
            EndIf 
        EndIf
    Next nX
    aAdd(aTail(aColsWiz),.F.)
    
EndIf

If Empty(aFields) 
	lRet := .F.
EndIf

#IFDEF TOP
	dbSelectArea(cAlias)
	dbCloseArea()
#ENDIF

RestArea(aAreaAnt)
// Create object for edit
If lRet
	aSort(aColsWiz,,,{|x,y|x[1]<y[1]})
	oGetDad := MsNewGetDados():New(25, 05, 132, 282,GD_UPDATE,"AllwaysTrue","AllwaysTrue",,aAlterRot,/*freeze*/,Len(aColsWiz),cFieldOk,/*superdel*/,/*delok*/,oWizard:oMPanel[oWizard:nPanel+1],aHeadWiz,aColsWiz)
EndIf
Return lRet

/*{Protheus.doc} RU05XFN022_MontCode
@author Alexandra Velmozhnaya
@since  02/12/20                                       
@param  aFields     Array       Field name that can be updated
        cCdBlock    Character   Product verification codeblock for modification
        aGroupFld   Array       Field for grouping
        nI          Numeric     Current Posicion
@Return lRet        Logical    .T. or  .F.  
@Description Assemble CodeBlock of the fields to be modified
/*/
Function RU05XFN022(aFields,cCdBlock,aGroupFld,nI)
Local nX as Numeric

For nX:= 1 To Len(aFields)
	If nX ==1
        cCdBlock	+=	"aX["+AllTrim(Str(nI++))+"]=="+aFields[nX]    
    Else
        ++nI
        cCdBlock	+=	"aX["+AllTrim(Str(nI++))+"]=="+aFields[nX]  
    EndIf    
    If nX < Len(aFields)
        cCdBlock	+=	".And."
    Else
        cCdBlock	+=	"})"
    EndIf
Next nX 
Return .T.


/*{Protheus.doc} RU05XFN023_ProcGetD
@author Alexandra Velmozhnaya
@since  02/12/20                                       
@param  aGroupFld   Array       Field for grouping
        aFields     Array       Field name that can be updated
        aDescri     Array       Description Magnifire field
@Return lRet        Logical    .T. or  .F.  
@Description Information processing function of the wizard to set up the update fields check.
/*/
Function RU05XFN023(aGroupFld,aEditFld,aDescri)
Local	nI		  := 0
Local   aAlterFld := {}
Local 	aF3 	  := {}
Local 	lF3 	  :=.F.
Local 	nScan	  :=0	
local 	cF3 	  :=""

aHeadWiz	:=	{}
aHeadAux	:=	{}
dbSelectArea("SX3")
dbSetOrder(2)
If lAgrupa 
    For nI := 1 To Len(aGroupFld)
        MsSeek(aGroupFld[nI])
        AADD(aHeadWiz,{TRIM(x3titulo()),;
            "TRB_CMP"+StrZero(nI,3),;
            SX3->X3_PICTURE,;
            SX3->X3_TAMANHO,;
            SX3->X3_DECIMAL,;
            ".F.",;
            SX3->X3_USADO,;
            SX3->X3_TIPO,;
            SX3->X3_F3,;
            SX3->X3_CONTEXT,;
            SX3->X3_CBOX,;
            SX3->X3_RELACAO,;
            ".T."})
        AADD(aHeadAux,{"TRB_CMP"+StrZero(nI,3),	aGroupFld[nI]})
    Next nI
EndIf

If ExistBlock('MA300001')
	aF3 := Execblock('MA300001',.F.,.F.,aEditFld)
	If !Empty(aF3)
		lF3:=.T.
	Endif 
EndIf
If ExistBlock('MA300004')
	aVldUser := Execblock('MA300004',.F.,.F.,aEditFld)
EndIf

For nI:= 1 To Len(aEditFld)

	If MsSeek(aEditFld[nI])

        cF3 := SX3->X3_F3
        If lF3
            nScan:=0
            nScan := aScan(aF3,{|aX| Alltrim(aX[1]) == alltrim(aEditFld[ni])})
            If nScan > 0 
                cF3:= aF3[nScan][2]	
            Endif		
        Endif 
        If lAgrupa 
            AADD(aHeadWiz,{TRIM(x3titulo()+STR0055),;   // (Old)
                "TRB_ANT" + StrZero(nI,3),;
                SX3->X3_PICTURE,;
                SX3->X3_TAMANHO,;
                SX3->X3_DECIMAL,;
                ".F.",;
                SX3->X3_USADO,;
                SX3->X3_TIPO,;
                "",;
                SX3->X3_CONTEXT,;
                SX3->X3_CBOX,;
                SX3->X3_RELACAO,;
                ".T."})
            AADD(aHeadAux,{"TRB_ANT" + StrZero(nI,3), aEditFld[nI]})
        EndIf
            AADD(aHeadWiz,{TRIM(x3titulo())+STR0054,;   //(New)
                "TRB_NV" + StrZero(nI,3),;
                SX3->X3_PICTURE,;
                SX3->X3_TAMANHO,;
                SX3->X3_DECIMAL,;
                ".T.",;
                SX3->X3_USADO,;
                SX3->X3_TIPO,;
                cF3,;
                SX3->X3_CONTEXT,;
                SX3->X3_CBOX,;
                SX3->X3_RELACAO,;
                ".T."})
	    If lPeDescri
            If aScan(aDescri,{|aX| Alltrim(aX[1]) == alltrim(aEditFld[nI])}) > 0 
                nScan:= aScan(aDescri,{|aX| Alltrim(aX[1]) == alltrim(aEditFld[nI])})
                cTitiOr := TRIM(x3titulo())
                MsSeek(aDescri[nScan][2])
                AADD(aHeadWiz,{TRIM(x3titulo())+" "+ cTitiOr,;
                    "TRB_DESC" + StrZero(nI,3),;
                    SX3->X3_PICTURE,;
                    SX3->X3_TAMANHO,;
                    SX3->X3_DECIMAL,;
                    ".F.",;
                    SX3->X3_USADO,;
                    SX3->X3_TIPO,;
                    SX3->X3_F3,;
                    SX3->X3_CONTEXT,;
                    SX3->X3_CBOX,;
                    SX3->X3_RELACAO,;
                    ".T."})
            Endif
        Endif 

        AADD(aHeadAux,{"TRB_NV" + StrZero(nI,3), aEditFld[nI]})
        AADD(aAlterFld,	"TRB_NV" + StrZero(nI,3))     
    EndIf
Next nI

Return aAlterFld


/*{Protheus.doc} RU05XFN024_UpdateACols
@author Alexandra Velmozhnaya
@since  02/12/20                                       
@param  cAlias   Character  Alias of temporary table
@Return none
@Description Update aCols
/*/
Function  RU05XFN024(cAlias)
Local nX as Numeric
Local nY as Numeric
Local aTmpaCols as Array

DbSelectArea(cAlias)

If Len(aCols)
    (cAlias)->(DbGoTo(1))
Else
    (cAlias)->(DbGoTop())
EndIf

nY := 1
aTmpaCols := aClone(aCols)

While (cAlias)->(!Eof())
    For nX := 1 To Len(aHeader)
        aTmpaCols[nY][nX] := &(aHeader[nX][2])
    Next
    nY++
    (cAlias)->(DbSkip())
EndDo
DbCloseArea()
Return  aTmpaCols


/*{Protheus.doc} RU05XFN025_udpFile
@author Alexandra Velmozhnaya
@since  02/12/20                                       
@param  tmpFile     Character   Name of temporary table with aCols Values
        aFields     Array       Field name that was updated
        aColsWiz    Array       Collumns of edit grid
        cFilter     Character   Filter selected in the routine assistant
        aHeadsWiz   Array       Array of name fields in edit grid
        aHeadAux    Array       Array of fields with values in edit grid
        aDescri     Array       Array of Description
@Return lRet        Logical    .T. or .F.  
@Description Update aCols without grouping
/*/
Function RU05XFN025(tmpFile,aFields,aColsWiz,cFilter,aHeadsWiz,aHeadAux,aDescri)
Local cQuery        as Character
Local cCSet         as Character
Local cDescField    as Character
Local nI		    as Numeric
Local nJ		    as Numeric
Local nK		    as Numeric
Local nX		    as Numeric
Local nY		    as Numeric
Local lRet 		    as logical 

lRet:= .T.
nI:= 0 
cCSet:= ""
For nI := 1 To Len(aFields)
    nJ := aScan(aHeadAux,{|aX| Alltrim(aX[2]) == Alltrim(aFields[nI])})
    nK := aScan(aHeadsWiz,{|aX| aX[2] == Alltrim(aHeadAux[nJ][1])})
    cCSet += aFields[nI]+" = '" + aColsWiz[nK] +"',"
    If lPeDescri
        If aScan(aDescri, {|aX| alltrim(aX[1]) == allTrim(aFields[nI])}) > 0
            nX := aScan(aDescri, {|aX| alltrim(aX[1]) == allTrim(aFields[nI])})
            cDescField := "TRB_DESC" + SubStr(aHeadsWiz[nK][2], Len(aHeadsWiz[nK][2])-2, Len(aHeadsWiz[nK][2]))
            nY := aScan(aHeadsWiz,{|aX| aX[2] == cDescField})
            If !Empty(aDescri[nX][6])
                cCSet += aDescri[nX][6]+" = '" + aColsWiz[nY] +"',"
            EndIf
        EndIf
    EndIf
Next nI
cCSet := SubStr(cCSet,1,Len(cCSet)-1)

cQuery := " UPDATE " + tmpFile
cQuery += " SET "
cQuery += cCSet
If !Empty(cFilter)
    cQuery += " WHERE "
    cQuery +=  cFilter 
EndIf 

nStatus := TCSqlExec(cQuery)

If (nStatus < 0)
    conout("TCSQLError() " + TCSQLError())
    lRet:= .F.
Endif

Return lRet


/*{Protheus.doc} RU05XFN026_udpMultFle
@author Alexandra Velmozhnaya
@since  02/12/20                                       
@param  tmpFile     Character   Name of temporary table with aCols Values
        aColsWiz    Array       Columns of edit grid
        cFilter     Character   Filter selected in the routine assistant.  
        aHeadsWiz   Array       Array of name fields in edit grid
        aHeadAux    Array       Array of fields  vith values in edit grid
        aDescri     Array       Array of Description
@Return lRet        Logical    .T. or .F.  
@Description Update aCols without grouping
@Return lRet        Logical    .T. or .F.  
@Description Update aCols with grouping
/*/
Function RU05XFN026(tmpFile,aColsWiz,cFilter,aHeadsWiz,aHeadAux, aDescri)
	Local cQuery    as Character
	Local cCSet     as Character
	Local cWhere    as Character
	Local nI        as Numeric
    Local nPos      as Numeric
    Local nScan     as Numeric
	Local lRet 		as logical 
	
	lRet := .T.
	nI := 0 
	cCSet := ""
	cWhere := ""

	For nI := 1 To Len(aHeadsWiz)
		If SubStr(aHeadsWiz[nI][2], 1, Len(aHeadsWiz[nI][2])-3 ) == "TRB_CMP" // Extra Group
			cWhere  += aHeadAux[aScan(aHeadAux, {|aX| aHeadsWiz[nI][2]==aX[1]} )][2] + " = '" + aColsWiz[nI] + "' AND "
		ElseIf  SubStr(aHeadsWiz[nI][2],1,Len(aHeadsWiz[nI][2])-3) == "TRB_ANT" // Original Value
			cWhere  += aHeadAux[aScan(aHeadAux,{|aX| aHeadsWiz[nI][2]==aX[1]})][2]+" = '" + aColsWiz[nI] + "' AND "
		ElseIf  SubStr(aHeadsWiz[nI][2], 1, Len(aHeadsWiz[nI][2])-3 ) == "TRB_NV"// Value to be changed
			cCSet += aHeadAux[aScan(aHeadAux,{|aX| aHeadsWiz[nI][2]==aX[1]})][2]+" = '" + aColsWiz[nI] + "',"
            //add descr
        ElseIf lPeDescri .And. SubStr(aHeadsWiz[nI][2], 1, Len(aHeadsWiz[nI][2])-3 ) == "TRB_DESC" 
            // Posicion main description field in array {Field_edit, Original field}
            nPos := aScan(aHeadAux,{|aX| Alltrim(aX[1]) == "TRB_NV" + SubStr(aHeadsWiz[nI][2], Len(aHeadsWiz[nI][2])-2, Len(aHeadsWiz[nI][2])) })
            // search original name of description
            nScan := aScan(aDescri ,{|aX| Alltrim(aX[1]) == Alltrim(aHeadAux[nPos][2]) })
            If Len(aDescri[nScan]) == 6 .And. !Empty(aDescri[nScan][6])
                cCSet += aDescri[nScan][6] + " = '" + aColsWiz[nI] + "',"
            EndIf
		Endif 
	Next nI

	If Empty(cFilter)
		cWhere := SubStr(cWhere,1,Len(cWhere)-4)
	Else
		cWhere  += cFilter
	Endif

	cCSet := SubStr(cCSet,1,Len(cCSet)-1)

	cQuery := " UPDATE " + tmpFile
	cQuery += " SET "
	cQuery += cCSet
    If !Empty(cWhere)
        cQuery += " WHERE "
        cQuery +=  cWhere 
    EndIf
	nStatus := TCSqlExec(cQuery)

	If (nStatus < 0)
		conout("TCSQLError() " + TCSQLError())
		lRet:= .F.
	EndIf

Return lRet


/*/{Protheus.doc} RU05XFN027_SaveLog
@since  02/12/20 
@author Alexandra Velmozhnaya
@param	cFile   Character   Log file name
		cText   Character   Log Content
@return	Nil
@version 1.0
@Description Record LOG Execution Data
/*/
Function RU05XFN027(cFile,cText)
Local nHandle as Numeric
Local cMask   as Character

Default cFile  := cGetFile(cMask,"")
Default cText := ""

nHandle := 0
cMask   := "Text Files (*.TXT) |*.txt|"
If !File(cFile)  // Arquivo não existe
	//Creates the log file
	nHandle := FCreate(cFile,FC_NORMAL)
	FSeek(nHandle, 0)	// Positions at the beginning of the log file
Else	// File exists
	nHandle := FOpen(cFile,FO_READWRITE+FO_SHARED)
	FSeek(nHandle, 0, FS_END)	// Positions at the end of the log file
EndIf
FWrite(nHandle,cText,Len(cText)) // Writes the contents of the variable to the log file
FClose(nHandle) // Closes the log file
Return

Return Nil

/*/{Protheus.doc} RU05XFN028_VldGen
    Function validation after edit field.
    P.S. for updating should use aCols instead of aColsWiz for refreshing
    @type  Function
    @author ALexandra Velmozhnaya
    @since 07/12/2020
    @version 1.0
    @param  aHeadWiz    Array   Wizard Columns Structure
            aColsWiz    Array   Wizard Values   aCols
            aHeadAux    Array   Connection Wizard fields [1] with Original Fields [2]
            aDescri     Array   Array of Field-description
            aVldUser    Array   Array of User Validation
    @return lRet        Logical result of User validation, for description  .T.
    @example

    @see Function use in RU05XFN021_ProcWiz as a parameter of MsNewGetDados object
    /*/
Function RU05XFN028(aHeadWiz,aColsWiz,aHeadAux,aDescri,aVldUser)
	Local lRet  as Logical
    Local cField    as Character
	Local cDescr    as Character
	Local cFildes   as Character
    Local cKeyInd   as Character
	Local nScan     as Numeric
	Local nCol      as Numeric
    Local nX        as Numeric
    Local nPos      as Numeric
    Local aKeyInd   as Array

lRet    := .T.

// Execution of user Validation
	If !Empty(aVldUser) 	
		cField := aHeadAux[aScan(aHeadAux,{|aX| aX[1] == Alltrim(StrTran( readvar(), "M->", "")) })][2]
		nScan:= aScan(aVldUser,{|aX| aX[1] == Alltrim(cField) })
		If nScan > 0	
			lRet:= &(aVldUser[nScan][2])
		Endif 
	Endif

//Execution Posicione
	If lRet .And. lPeDescri
    aKeyInd  := {}
    cKeyInd := ""
    //Search in edit wizard fields original field name 
        nCol := aScan(aHeadAux,{|x| x[1] == StrTran( ReadVar(), "M->", "")})
        // if edit field have description
        If nCol > 0
            nScan := aScan(aDescri, {|x| Alltrim(x[1]) == Alltrim(aHeadAux[nCol][2])})
        EndIf
        //Search data for posicione
		If nScan > 0
            aKeyInd := StrTokArr(aDescri[nScan][5],"+")
            For nX:= 1 to Len(aKeyInd)
                //Search Wizard field name for field(s) in index
                nPos := aScan(aHeadAux,{|x| Alltrim(x[2]) == Alltrim(aKeyInd[nX]);
                                        .And. Alltrim(SubStr(x[1],1, Len(x[1])-3)) $ "TRB_NV|TRB_CMP"})
                // Concatenate Values of wizard Line for Key
                If nPos > 0
                    cKeyInd += IIf ( aHeadAux[nPos][1] == StrTran( ReadVar(), "M->", ""),;
                                    &(ReadVar()),;
                                    aCols[n][ GdFieldPos( aHeadAux[nPos][1],aHeadWiz) ])
                EndIf
            Next nX
			cDescr := Posicione( aDescri[nScan][3],aDescri[nScan][4], xFilial(aDescri[nScan][3]) + cKeyInd,aDescri[nScan][2])
			cFildes := "TRB_DESC"+right(StrTran( readvar(), "M->", ""),3)
			nCol := aScan(aHeadWiz,{|aX| Alltrim(aX[2]) == Alltrim(cFildes) })
			aCols[n][nCol]:=cDescr
		Endif 
	Endif
Return lRet


/*/{Protheus.doc} RU05XFN029_ValidateACols
    Function validation after edit field.
    P.S. for updating should use aCols instead of aColsWiz for refreshing
    @type  Function
    @author ALexandra Velmozhnaya
    @since 07/12/2020
    @version 1.0
    @param  aEditCols   Array   Wizard Columns Structure
            aCols       Array   Wizard Values aCols
            aSetting    Array   Settings LocxNF
    @return lRet        Logical result of User validation, for description  .T.
    @example

    @see Function use in RU05XFN021_ProcWiz as a parameter of MsNewGetDados object
    /*/
Function RU05XFN029(aEditCols, aCols, aSetting)
Local aTmpaCols as array
Local nX as Numeric
Local nY as Numeric
Local cError as Character
Local lUpdError as Logical

cError := STR0062 +  Chr(13)    // Due to validation issues, the following line has not been updated: 
lUpdError := .F.
aTmpaCols := AClone(aCols)


For nX := 1 to Len(aEditCols)
    // TODO: Now validation is not enough. in case with LocXNF should be include recalculation and hide twice window about validation line 
    If NfLinOk(aSetting[05]/*cAliasI*/,;
                HeaderCpos()/*aCposIOri*/,;
                aSetting[02]/*cAliasCF*/,;
                aEditCols/*aItensOri*/,;
                aSetting[10]/*cTipDoc*/,;
                nX/*nLinha*/,;
                aSetting[ 03 ]/*lFormP*/)
        For nY := 1 To Len(aHeader)
            aCols[nX][nY]:= aEditCols[nX][nY]
        Next nY
    Else
        cError += STR0071 + StrZero(nX , TamSX3("D1_ITEM")[1]) + Chr(13)        // "Item "
        lUpdError := .T.
    EndIf
Next nX
    If lUpdError
        Help("", 1, STR0072,, cError, 1, 0)   //### Changes validation
    EndIf
Return Nil

/*/{Protheus.doc} RU05XFN030_WizardFinish
    Function validation after edit field.
    P.S. for updating should use aCols instead of aColsWiz for refreshing
    @type  Function
    @author ALexandra Velmozhnaya
    @since 10/12/2020
    @version 1.0
    @param  oWizard Object  Wizard
            lLast   Logical Flag Last Step
    @return lRet        Logical result of User validation, for description  .T.
    @example

    @see Function use in RU05XFN021_ProcWiz as a parameter of MsNewGetDados object
    /*/
Function RU05XFN030(oWizard, lLast)
Local lRet as Logical

lRet := .T.

If oWizard:nPanel == 6
    lRet := MSGYESNO(STR0028,STR0029)   //### Do you confirm updating the data according to the summary table?  ### Attention
    lLast := .T.
Else
    lLast := .F.
EndIf
Return lRet
/*/{Protheus.doc} RU05XFN031_GatLoja
This function autofills current SA1->A1_LOJA to TGet object
which reads and changes memory variable M->F2_LOJA.
This function inserted to validation block for F2_CLIENTE in aCposNF array element
in LocxNF.PRW
The most correct way is to use trigger for F2_CLIENTE but it is prohibited. So we
emulate a trigger behaviour.
@type  Function
@param   lAutoFill  Logical  // Autofill cText fot TGet object with cReadVar == "M->F2_LOJA"
                             // Default is .T.
@private __AOGETS   Array of TGet fields
@author astepanov
@since 03 Feb 2020
@version 1.0
@see https://jiraproducao.totvs.com.br/browse/RULOC-1259
/*/
Function RU05XFN031_GatLoja(lAutoFill)
    Local lRet      As Logical
    Local cUnit     As Character
    Local cText     As Character
    Local nX        As Numeric
    Local oGetLoja  As Object
    Default lAutoFill := .T.
    lRet := .T.
    If !(Type("lLocxAuto")<>"U" .And. lLocxAuto) .And. lAutoFill
        // So if we are in this function  M->F2_CLIENTE should be equal to SA1->A1_COD.
        // Posicione('SA1',1,xFilial('SA1')+M->F2_CLIENTE,'A1_COD') == M->F2_CLIENTE
        // function executed before in validation routine sets this condition to .T.
        // So, our new loja located in SA1->A1_LOJA
        cUnit := SA1->A1_LOJA
        // Find an object which changes M->F2_LOJA
        If Type("__AOGETS") == "A"
            nX := ASCAN(__AOGETS, {|x| x:cReadVar == "M->F2_LOJA"})
            If nX > 0 
                oGetLoja := __AOGETS[nX]
                If Eval(oGetLoja:bWhen)     // So, we found TGet object try to change it
                    cText := oGetLoja:cText // Get current content
                    oGetLoja:cText := cUnit
                    If Eval(oGetLoja:bSetGet) == cUnit   // Update memory variable
                        If Eval(oGetLoja:bChange) != .F. // run bChange block
                            If Eval(oGetLoja:bValid)     //Run validation
                                //So, after validation we can refresh TGet
                                oGetLoja:CtrlRefresh()
                                oGetLoja:SetFocus()
                            Else
                                //Not validated. So return previous values
                                oGetLoja:cText := cText
                                Eval(oGetLoja:bSetGet)
                                lRet := .F.
                            EndIf
                        Else
                            //error in bChange. Return previuos cText
                            oGetLoja:cText := cText
                            lRet := .F.
                        EndIf
                    Else
                        //Can't set memory varibale. Return previous cText
                        oGetLoja:cText := cText
                        lRet := .F.
                    EndIf
                Else
                    lRet := .F. //Changes prohibited by bWhen
                EndIf
            Else
                lRet := .F. // Can't find TGet object
            //solved in https://gitlab.national-platform.ru/np/ma3/-/merge_requests/1719/diffs
            EndIf
        Else
            lRet := .F. //no __AOGETS private var
        EndIf
    EndIf
Return lRet //end of RU05XFN031


/*{Protheus.doc} RU05XFN00F_TpPed
@description 
    Search by order type (normal or optional)
    ExpL1 (Application Type Result) 
    .T. - > optional (SA2)
    .F. - > Normal (SA1)
@author oleg.ivanov
@since 09/04/2021
@version 1.0
@project MA3 - Russia
*/
Function RU05XFN00F_TpPed( cCliFor, cLj, cPedNum )

Local 	lRet       	:= .F.
Local 	aArea		:= GetArea()
Default cClifor		:= "" // Code client or supplier
Default cLj			:= "" // Loja client or supplier
Default cPedNum 	:= "" // invoice order

If !Empty(cCliFor) .And. !Empty(cLj) .And. !Empty(cPedNum)
	DbSelectArea( "SC5" )
	DbSetOrder(3) // C5_FILIAL+C5_CLIENTE+C5_LOJACLI+C5_NUM
	If DbSeek( xFilial("SC5") + cCliFor + cLj + cPedNum )
		If C5_TIPO = "B"
			lRet := .T.
		Endif
	EndIf
Endif

RestArea( aArea )
Return  ( lRet  )


/*{Protheus.doc} RU05XFN00H_AutoPrepayment
@description
    Automatic write-off of the amount of prepayments in mata468n
@author oleg.ivanov
@since 31/03/2021
@version 1.0
@project MA3 - Russia
*/
Function RU05XFN00H_AutoPrepayment(cAlias,aRecs,cCamposQueb,lCarga,lMT310,c310Ser)
    Local aQuebra  	 := {}	,aQuebraPed:={}	,	aQuebraRem:={},bQuebra
    Local lPegaSerie := FindFunction("U_M468ASER")
    Local cVendedor  := "1", nMaxVend := Fa440CntVen()
    Local aPv1NFs	 :=	{},nPosNota	:=	0
    Local lQuebra	 :=	.F.
    Local aRecsTRB	 :=	{}
    Local bCondW_01,bIf
    Local nOrderTRB	 :=	1
    Local bSeparo
    Local lTrb	     :=	.F.
    Local nCntFor	 :=	1,nRecs,cCondicao := ""
    Local cCondPag   := ""
    Local cTipoNota  := "NF "
    Local nX
    Local lFatDiverg := If( GetNewPar("MV_FATDIV","S")=="S",.T.,.F.)
    Local lRespVlrInf:= .F. // Indicates whether the user answered the question to include Advances
    Local lActVlrInf := .F. // Indicates whether the user will include advances or cancel the generation of invoices for orders without advances
    Local lPedSemAd	 := .F.	//	Logic that indicates if the Order has Advance
    Local aPedSemAd  := {}	//	Stores the Order Number that will not be included in the note due to lack of Advance
    Local lM468Proc	:= ExistBlock("lM468Proc")	
    Local aArea := GetArea()
    Local lCallStAut as Logical

    Default lMT310   := .F.
    Default c310Ser  := ""
    Default lCarga	:=	.F.

    Private lSeqEspecie := GetMV("MV_SEQESPE",,.F.)
    Private nTipoGer := aParams[22]
    Private nMoedSel := aParams[23]
    Private lNotAviso as Logical

	lNotAviso := .F.
    lCallStAut := .T.

 //grouping by pergunta value 
	Do Case
        Case nSepara == _PEDREM
            bSeparo	:=	If(lPedidos,{|| SC9->C9_PEDIDO},{|| SD2->D2_DOC})
        Case nSepara == _AGREGADOR
            bSeparo	:=	If(lPedidos,{|| SC9->C9_AGREG} ,{|| SD2->D2_AGREG})
        Case nSEPARA == _GRUPO
            bSeparo	:=	If(lPedidos,{|| SC9->C9_GRUPO},{|| SD2->D2_GRUPO})
        OtherWise
            bSeparo	:=	{|| ''}
	EndCase

    If cCamposQueb  <> Nil
	    nSepara := 0
	    cCamposQueb	:=	"+"+cCamposQueb
    Else
	    cCamposQueb	:=	""
    Endif

    //select order where have mark on grid
    lTRB 	:=	.T.
    dbSelectArea( "TRB" )
    nOrderTRB	:=	IndexOrd() 
    DbSetOrder(4)
    ProcRegua(LastRec())
    aRecs	:=	{}   

    If lPedidos
        bCondW_01 := {||!Eof() .And. TRB->C9_FILIAL == xFilial("SC9") .And. TRB->C9_OK == cMarca }
        bIf := {|| !Empty(SC9->C9_NFISCAL) }
        MsSeek(xFilial('SC9')+cMarca)
    Else
        bCondW_01 := {||!Eof() .And. TRB->D2_FILIAL == xFilial("SD2") .And. TRB->D2_OK == cMarca}
        bIf := {|| TRB->D2_QUANT == TRB->D2_QTDEFAT }
        MsSeek(xFilial('SD2')+cMarca)
    EndIf

    //verification elements
    While Eval(bCondW_01)
        IncProc(STR0079) 
        If lPedidos
            SC9->(MsGoTo(TRB->RECNO))
        Else
            SD2->(MsGoTo(TRB->RECNO))
        Endif
        If Eval(bIf)
            DbSkip()
            Loop
        Endif
        If !lAutomato
            If IsMark(If(lPedidos,"C9_OK","D2_OK"))
                AAdd(aRecs,If(lPedidos,SC9->(RECNO()),SD2->(RECNO())))
                AAdd(aRecsTRB,TRB->(RECNO()))
            Endif
        Else
            If  SD2->D2_OK <> Nil .or. SC9->C9_OK <> Nil 
                AAdd(aRecs,If(lPedidos,SC9->(RECNO()),SD2->(RECNO())))
                AAdd(aRecsTRB,TRB->(RECNO()))
            Endif
        Endif
        DbSkip()
    Enddo

    DbSetOrder(nOrderTRB)

    aadd(aQuebraPed,{"SC9->C9_CLIENTE",})
    aadd(aQuebraPed,{"SC9->C9_LOJA",})
    aadd(aQuebraPed,{"SC5->C5_TIPO",})
    aadd(aQuebraPed,{"SC5->C5_TIPOREM",})
    If SC5->(FieldPos('C5_CODMUN'))>0
        aadd(aQuebraPed,{"SC5->C5_CODMUN",})
    Endif
 
    If SC5->(FieldPos('C5_PROVENT'))>0
        aadd(aQuebraPed,{"SC5->C5_PROVENT",})
    Endif

    aadd(aQuebraPed,{"SC5->C5_CLIENT",})
    aadd(aQuebraPed,{"SC5->C5_LOJAENT",})
    aadd(aQuebraPed,{"SC5->C5_REAJUST",})
    aadd(aQuebraPed,{"SC5->C5_CONDPAG",})
    aadd(aQuebraPed,{"SC5->C5_TRANSP",})
    aadd(aQuebraPed,{"SC5->C5_F5QUID",})
    aadd(aQuebraPed,{"SC5->C5_F5QCODE",})

    If nTipoGer == 1
        aadd(aQuebraPed,{"STR(SC5->C5_MOEDA)",})
        aadd(aQuebraPed,{"STR(SC5->C5_TXMOEDA)",})
    EndIf
    If lCarga
        aadd(aQuebraPed,{"SC9->C9_CARGA",})
    Endif
    cVendedor := "1"
    For nCntfor := 1 To nMaxVend
        aadd(aQuebraPed,{"SC5->C5_VEND"+cVendedor,})
        cVendedor := Soma1(cVendedor,1)
    Next nCntFor
    If nSepara	== _AGREGADOR
        aadd(aQuebraPed,{"SC9->C9_AGREG",})
    ElseIf nSepara	== _GRUPO
        aadd(aQuebraPed,{"SC9->C9_GRUPO",})
    Endif

    aadd(aQuebraRem,{"SD2->D2_CLIENTE",})
    aadd(aQuebraRem,{"SD2->D2_LOJA",})
    aadd(aQuebraRem,{"SD2->D2_TIPO",})
    aadd(aQuebraRem,{"SD2->D2_TIPOREM",})
    If SF2->(FieldPos('F2_CODMUN'))>0
        aadd(aQuebraRem,{"SF2->F2_CODMUN",})
    Endif
    
    If SF2->(FieldPos('F2_PROVENT'))>0
        aadd(aQuebraRem,{"SF2->F2_PROVENT",})
    Endif

    aadd(aQuebraRem,{"SD2->D2_LOJA",})
    aadd(aQuebraRem,{'"'+space(TamSX3("C5_REAJUST")[1])+'"',})
    aadd(aQuebraRem,{'"'+space(TamSX3("C5_TRANSP")[1])+'"',})
    If nTipoGer == 1
        aadd(aQuebraRem,{"STR(SF2->F2_MOEDA)",})
        aadd(aQuebraRem,{"STR(SF2->F2_TXMOEDA)",})
        If SF2->(Fieldpos("F2_REFMOED")) > 0
            aadd(aQuebraRem,{"STR(SF2->F2_REFMOED)",})
        EndIf
        If SF2->(ColumnPos("F2_REFTAXA")) > 0
            aadd(aQuebraRem,{"STR(SF2->F2_REFTAXA)",})
        EndIf
    EndIf
    If lCarga
        aadd(aQuebraRem,{'"'+space(TamSX3("C9_CARGA")[1])+'"',})
    EndIf
    cVendedor := "1"
    For nCntfor := 1 To nMaxVend
        aadd(aQuebraRem,{"SF2->F2_VEND"+cVendedor,})
        cVendedor := Soma1(cVendedor,1)
    Next nCntFor
    If nSepara  == _AGREGADOR
        aadd(aQuebraRem,{"SD2->D2_AGREG",})
    ElseIf nSepara	== _GRUPO
        aadd(aQuebraRem,{"SD2->D2_GRUPO",})
    Endif

    cCondicao	:=	""

    For nX:= 1 To Len(aQuebraPed)
        cCondicao += aQuebraPed[nX][1]+"+"
    Next
    cCondicao	:=	Substr(cCondicao,1,Len(cCondicao)-1)
    aQuebraPed	:=	{cCondicao, }

    If lM468Proc
        aQuebraNew:=ExecBlock("lM468Proc",.F.,.F., aQuebraRem)
        If (ValType(aQuebraNew) == "A" )
            aQuebraRem := aClone(aQuebraNew)
        EndIf
    EndIf

    cCondicao	:=	""

    For nX:= 1 To Len(aQuebraRem)
        cCondicao += aQuebraRem[nX][1]+"+"
    Next
    cCondicao	:=	Substr(cCondicao,1,Len(cCondicao)-1)
    aQuebraRem	:=	{cCondicao, }

    bQuebra	:= {|lPed| aClone(If(lPed, aQuebraPed,aQuebraRem))}
    //group elements
    ProcRegua(Len(aRecs))

    For nRecs	:=	1	To	Len(aRecs)
        IncProc(STR0080) 
        If lPedidos
            SC9->(MsGoTo(aRecs[nRecs]))
            lTpPedBenf := RU05XFN00F_TpPed(SC9->C9_CLIENTE,SC9->C9_LOJA,SC9->C9_PEDIDO)
        Else
            SD2->(MsGoTo(aRecs[nRecs]))
            lTpPedBenf := (SD2->D2_TIPO=="B")
        Endif

        If lTrb
            TRB->(MsGoTo(aRecsTRB[nRecs]))
        Endif
        
        If lTpPedBenf
            SA2->( dbSetOrder(1) )
        Else
            SA1->( dbSetOrder(1) )
        Endif
        SC6->( dbSetOrder(1) )
        SC9->( dbSetOrder(1) )
        SC5->( dbSetOrder(1) )
        SE4->( dbSetOrder(1) )
        SF2->( dbSetOrder(1) )
        lPedOk	:=	.F.
        If lPedidos
            SC5->( MsSeek(xFilial("SC5")+ SC9->C9_PEDIDO) )
            If lTpPedBenf
                SA2->( MsSeek(xFilial("SA2")+ SC9->C9_CLIENTE+SC9->C9_LOJA) )
            Else
                SA1->( MsSeek(xFilial("SA1")+ SC9->C9_CLIENTE+SC9->C9_LOJA) )
            Endif
            SE4->( MsSeek(xFilial("SE4")+ SC5->C5_CONDPAG) )
            lPedOk	:=	.T.
        Else
            If !Empty(SD2->D2_PEDIDO)
                SC5->( MsSeek(xFilial("SC5")+ SD2->D2_PEDIDO) )
                SC9->( MsSeek(xFilial("SC9")+ SD2->D2_PEDIDO+SD2->D2_ITEMPV+SD2->D2_SEQUEN+SD2->D2_COD) )
                SE4->( MsSeek(xFilial("SE4")+ SC5->C5_CONDPAG) )
                lPedOk	:=	.T.
            Endif
            If lTpPedBenf
                SA2->( MsSeek(xFilial("SA2")+SD2->D2_CLIENTE+SD2->D2_LOJA) )
            Else
                SA1->( MsSeek(xFilial("SA1")+SD2->D2_CLIENTE+SD2->D2_LOJA) )
            Endif
            SF2->( MsSeek(xFilial("SF2")+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA+SD2->D2_FORMUL) )
        Endif
        If lPedOk
            cCondPag  := SE4->E4_CODIGO
        Else
            If lTpPedBenf
                cCondPag := SA2->A2_COND
            Else
                cCondPag := SA1->A1_COND
            Endif
        EndIf

        lPedSemAd := .F.
    //an array of sales orders is collected
        If aScan(aPedSemAd, SC9->C9_PEDIDO) <= 0    
            lPedSemAd := a468NAdian(SC9->C9_PEDIDO, cCondPag, aRecs, @lRespVlrInf, @lActVlrInf, SC9->C9_CLIENTE, SC9->C9_LOJA,,;
                                    {SC5->C5_CONUNI,SC5->C5_F5QUID,SC5->C5_EMISSAO},lCallStAut)
            If !lPedSemAd
                aAdd(aPedSemAd, SC9->C9_PEDIDO)
            EndIf
        EndIf
        //check - does the payment have an advance
        If (!lPedidos .and. lFatDiverg) .Or. (!LogMov('SC9',.F.,.T.,SC9->C9_PRODUTO,SC9->C9_LOCAL,.T.) .And. lPedSemAd)

            aQuebra	:=	Eval(bQuebra,lPedOk)

            If !lPedOk
                If lTpPedBenf
                    aQuebra[1]	+=	"+SA2->A2_COND"
                Else
                    aQuebra[1]	+=	"+SA1->A1_COND"
                Endif
            Endif
        
            If lPedOk .And. ( SE4->E4_TIPO=="9" )
                aQuebra[1]	+=	"+SC5->C5_NUM"
            Endif

            If nSepara == _PEDREM .or. nSepara == _NOQUEBRA
                If lPedidos
                    If ( SE4->E4_TIPO<>"9" )
                        aQuebra[1]	+=	"+SC5->C5_NUM"
                    Endif
                Else
                    aQuebra[1]	+=	"+SD2->D2_DOC"
                Endif
            Endif

            aQuebra[1] +=	cCamposQueb
            aQuebra[2] := Alltrim( &(aQuebra[1]) )

            If lSeqEspecie .And. Empty(cSerie)
                If SX5->(DbSeek(xFilial("SX5")+"AC"+cTipoNota),.T.)
                    cSerie  := Substr(SX5->X5_CHAVE,4,3)
                EndIf
            EndIf

            If lQuebra
    //receiving a series of tax statements		
                If lPegaSerie
                    cSerie := ExecBlock( "M468ASER",.F.,.F., {0,cSerie})
                EndIf
                If Empty(cSerie) .And. ! Empty(c310Ser)
                    cSerie		:= c310Ser
                Endif
            
                AAdd(aPv1NFs,{aQuebra[2],{aRecs[nRecs]},IIf(lMT310,c310Ser,cSerie),,{If(lTRB,TRB->(RECNO()),0)},Eval(bSeparo),cCondPag,'','', ,cTipoNota ,lTpPedBenf } )
                lQuebra	:=	.F.
            Else
                nPosNota	:=	aScan(aPv1NFs, {|x| x[1]==aQuebra[2] .And. Len(x[2]) < x[10]  })
                If nPosNota == 0	
                    If lPegaSerie
                        cSerie := ExecBlock( "M468ASER",.F.,.F., {0,cSerie})
                    EndIf
                    If Empty(cSerie) .And. ! Empty(c310Ser)
                        cSerie		:= c310Ser
                    Endif

                    AAdd(aPv1NFs,{aQuebra[2],{aRecs[nRecs]},IIf(lMT310,c310Ser,cSerie),,{If(lTRB,TRB->(RECNO()),0)},Eval(bSeparo),cCondPag,'','',;
                                    LjGetMaxIt(IIf(lMT310,c310Ser,cSerie)),cTipoNota, lTpPedBenf })
                    lQuebra	:=	.F.
                Else
                    AAdd(aPv1NFs[nPosNota][2],aRecs[nRecs])
                    AAdd(aPv1NFs[nPosNota][5],If(lTRB,TRB->(RECNO()),0))
                Endif
            Endif
        Endif
    Next

    For nX := 1 To Len(aPv1NFs)
        Aadd(aPv1NFs[nX],{})
        Aadd(aPv1NFs[nX],{})
        Aadd(aPv1NFs[nX],{})
        Aadd(aPv1NFs[nX],0)
        Aadd(aPv1NFs[nX],0)
        Aadd(aPv1NFs[nX],0)
        Aadd(aPv1NFs[nX],{0,0,0,0})
    Next
    
    If Len(aPv1NFs) > 0
        nLenNFS := Len(aPv1NFs[1])
    EndIf

    RestArea(aArea)

Return aClone(aPv1NFs)


/*{Protheus.doc} RU05XFN00J
@description
    Calculate new exchange rate and total value in local currency when select PA or RA for mata101n or mata467n
@param  cAlias,Character TRBADT name of temporary table
@param  nSelec, Numeric Total Selected prepayment value
@param  nValLimite, Numeric 
@param  nStandExcR, Numeric
@param  cCarteira, Character "P" or "R"
@return aReturn, Array {nNewExRate,nTotRub}
@author oleg.ivanov
@since 28/04/2021
@edit astepanov
@version 1.0
@project MA3 - Russia
*/
Function RU05XFN00J(cAlias,nSelec,nValLimite,nStandExcR,cCarteira)

    Local aArea      as Array
    Local aAreaTRB   as Array
    Local aReturn    as Array
    Local cPr        as Character
    Local cTab       as Character
    Local nRound     as Numeric
    Local nRoundER   as Numeric
    Local nSelctdRub as Numeric
    Local nTotRub    as Numeric
    Local nNewExRate as Numeric
    Default cCarteira := Nil

    If (cAlias)->(FieldPos("P_R")) > 0
        If (cAlias)->P_R == "R"
            cTab := "SE1"
            cPr  := "E1_"
        ElseIf (cAlias)->P_R == "P"
            cTab := "SE2"
            cPr  := "E2_"
        EndIf
    Else
        If !Empty(cCarteira)
            If cCarteira == "R"
                cTab := "SE1"
                cPr  := "E1_"
            ElseIf cCarteira == "P"
                cTab := "SE2"
                cPr  := "E2_"
            EndIf
        EndIf
    EndIf
    nRound     := IIF(!Empty(cPr),GetSX3Cache(cPr+"VLCRUZ","X3_DECIMAL"),MsDecimais(1))
    nRoundER   := GetSx3Cache(IIF(cTab=="SE2","F1_TXMOEDA","F2_TXMOEDA"), "X3_DECIMAL")
    nSelctdRub := 0
    aArea := GetArea()
    aAreaTRB := (cAlias)->(GetArea())
    If (cAlias)->(FieldPos("RELRUB")) > 0
        (cAlias)->(DBGoTop())
        While (cAlias)->(!Eof())
            nSelctdRub := nSelctdRub + (cAlias)->RELRUB
            (cAlias)->(DBSkip())
        EndDo
    EndIf
    RestArea(aAreaTRB)
    RestArea(aArea)
    nTotRub    := nSelctdRub + Round((nValLimite-nSelec)*nStandExcR,nRound)
    nNewExRate := IIF(nSelec == 0, nStandExcR, CalcAvgExR(nTotRub,nValLimite,nRoundER))
    aReturn    := {nNewExRate,nTotRub}

Return aReturn


/*{Protheus.doc} RU05XFN00K
@description
The function recalculates the value for new fields (FI-AR-16-1 Part 4) in the prepayment selection grid
@param  cAlias,Character TRBADT name of temporary table
@return Nil
@author oleg.ivanov
@since 05/05/2021
@edit   astepanov
@version 1.0
@project MA3 - Russia
*/
Function RU05XFN00K(cAlias,lFixedExRt)

    Local cPr       as Character
    Local nRound    as Numeric

    DEFAULT lFixedExRt  :=.T.

    If (cAlias)->P_R == "R"
        cPr     := "E1_"
    ElseIf (cAlias)->P_R == "P"
        cPr     := "E2_"
    EndIf
    nRound := GetSX3Cache(cPr+"VLCRUZ","X3_DECIMAL")

    If ((cAlias)->(FieldPos("BALRUB")) > 0) .AND. ((cAlias)->(FieldPos("RELVALRUB")) > 0) .AND. ((cAlias)->(FieldPos("RELRUB")) > 0) .AND. ((cAlias)->(FieldPos("SALDO")) > 0)
        If RecLock(cAlias,.F.)
            If lFixedExRt .AND. (((cAlias)->VALAREL) + (cAlias)->VALRELA == (cAlias)->SALDO .AND. (cAlias)->VALAREL > 0)
                (cAlias)->RELRUB := (cAlias)->BALRUB
            Else
                (cAlias)->RELRUB := Round((cAlias)->VALAREL * (cAlias)->EXRATE,nRound)
            EndIf
            (cAlias)->RELVALRUB := Round((cAlias)->VALRELA * (cAlias)->EXRATE,nRound)
            (cAlias)->BALRUB :=    round(xMoeda((cAlias)->PRINCIP,(cAlias)->MOEDA,1,,3,(cAlias)->EXRATE),2)//get saldo in local currency 
            (cAlias)->(MSUnlock())
        EndIf
    EndIf
Return Nil


/*{Protheus.doc} RUPrepPrnt
@description
    standart print FI-AR-16-1 in mata467n/mata101n (Prepayment)
@author oleg.ivanov
@since 12/05/2021
@version 1.0
@project MA3 - Russia
*/
Function RUPrepPrnt(cNameAlias, aCamposBr)
    Local oReport	 As Object
    Local bPrint     As Block
    bPrint     := {|oReport| ReportPrint(oReport)}
    oReport := ReportDef(cNameAlias, aCamposBr, bPrint)
    oReport:PrintDialog()
Return Nil


/*{Protheus.doc} ReportDef
@description
    standart print FI-AR-16-1 in mata467n/mata101n (Prepayment)
@author oleg.ivanov
@since 12/05/2021
@version 1.0
@project MA3 - Russia
*/
Static Function ReportDef(cAlias, aViewCampo, bPrint)
    Local oReport   as Object
    Local oSection  as Object
    Local nX	    as Numeric

    oReport := TReport():New(cAlias, STR0015, cAlias, bPrint, "", .F.,, .T.,, .F., .F.,)
    oReport:lParamPage	:= .F.

    oSection := TRSection():New(oReport, cAlias, {cAlias})
    For nX := 1 To Len(aViewCampo)
        TRCell():New(oSection, aViewCampo[nX][1], cAlias)
    Next nX

Return oReport


/*{Protheus.doc} ReportPrint
@description
    standart print FI-AR-16-1 in mata467n (Prepayment)
@author oleg.ivanov
@since 12/05/2021
@version 1.0
@project MA3 - Russia
*/
Static Function ReportPrint(oReport)
    Local oSection  as Object
    Local cAlias    As Character
    Local nX	    as Numeric
    Local aCells    as Array
    Local aArea     as Array
    aArea      := GetArea()
    cAlias     := oReport:uParam
    oSection   := oReport:Section(cAlias)
    aCells     := oSection:ACELL
    oSection:Init()
    DBSelectarea(cAlias)
    (cAlias)->(DBGOTOP())
    While (cAlias)->(!EOF())
        For nX := 1 To Len(aCells)
            oSection:Cell(aCells[nX]:CNAME):SetValue((cAlias)->&(aCells[nX]:CNAME))
        Next nX
        oSection:Printline()
        (cAlias)->(DbSkip())
    EndDo
    oSection:Finish()
    RestArea(aArea)
Return Nil


/*{Protheus.doc} RU05XFN00L
@description
    1) Button in "Other Actions" at screen for Prepayments from mata467n/mata101n.
    2) Button from mata468n FI-AR-16-1 -- function RU05XFN00M()
    Return lRet, If lRet is .T. Document was found, if .F. document was not found
@author oleg.ivanov
@since 14/05/2021
@version 1.0
@edit astepanov 10 April 2023
@project MA3 - Russia
*/
Function RU05XFN00L(cAlias as Character, cLoja as Character, lClStFN00M as Logical)
    Local lRet      as Logical
    Local cAliasTRB as Character
    Local cQuery as Character
    Local cQueryULCD as Character
    Local cFil       as Character
    Local cQuerKAl   as Character
    Local nLenF5mKey as Numeric
    Local cAliasTMP  as Character
    Local aTmpArea   as Array
    Local aF4CArea   as Array
    Local cPrefix    as Character
    Local cNum       as Character
    Local cParcela   as Character
    Local cTipo      as Character
    Local cClifor    as Character
    Local cPr        as Character

    Default lClStFN00M := .F.

    lRet := .F.
    aArea := GetArea()
    cQuery := ''
    cQueryULCD := ''
    cAliasTRB := cAlias
   
    If FunName() == "MATA101N" .And. AllTrim(TRBADT->TIPO) $ MVPAGANT
        cFil     := xFilial("SE2")
        cQuerKAl := "  AND F5M.F5M_KEYALI = 'SE2'       "
        cPr      := "E2"
    Else
        cFil     := xFilial("SE1")
        cQuerKAl := "  AND F5M.F5M_KEYALI = 'SE1'       "
        cPr      := "E1"
    EndIf
    If !lClStFN00M
        cPrefix := PADR(TRBADT->PREFIXO, GetSX3Cache(cPr+"_PREFIXO","X3_TAMANHO"), " ")
        cNum    := PADR(TRBADT->TITULO,  GetSX3Cache(cPr+"_NUM"    ,"X3_TAMANHO"), " ")
        cParcela:= PADR(TRBADT->PARCELA, GetSX3Cache(cPr+"_PARCELA","X3_TAMANHO"), " ")
        cTipo   := PADR(TRBADT->TIPO   , GetSX3Cache(cPr+"_TIPO"   ,"X3_TAMANHO"), " ")
        cClifor := PADR(TRBADT->CLIFOR , GetSX3Cache(IIF(cPr=="E1",cPr+"_CLIENTE",cPr+"_FORNECE"),"X3_TAMANHO"), " ")
    Else
        cPrefix := PADR((cAliasTRB)->E1_PREFIXO, GetSX3Cache("E1_PREFIXO","X3_TAMANHO"), " ")
        cNum    := PADR((cAliasTRB)->E1_NUM,     GetSX3Cache("E1_NUM"    ,"X3_TAMANHO"), " ")
        cParcela:= PADR((cAliasTRB)->E1_PARCELA, GetSX3Cache("E1_PARCELA","X3_TAMANHO"), " ")
        cTipo   := PADR((cAliasTRB)->E1_TIPO   , GetSX3Cache("E1_TIPO"   ,"X3_TAMANHO"), " ")
        cClifor := PADR((cAliasTRB)->C5_CLIENTE, GetSX3Cache("E1_CLIENTE","X3_TAMANHO"), " ")
    EndIf
    cF5MKey := cFil+"|"+cPrefix+"|"+cNum+"|"+cParcela+"|"+cTipo+"|"+cClifor+"|"+cLoja
    nLenF5mKey := Len(cF5MKey)
    cQuery +=   "SELECT F5M_FILIAL,F5M_KEY,F5M_KEYALI,F5M_ALIAS,F5M_IDDOC "
    cQuery +=   "FROM " + RetSqlName("F5M") + " F5M "
    cQuery +=   "WHERE F5M.F5M_FILIAL = '"+xFilial("F5M")+"' "
    cQuery +=   cQuerKAl
    cQuery +=   "  AND TRIM(SUBSTRING(F5M.F5M_KEY,1,"+cValToChar(nLenF5mKey)+")) = '"+cF5MKey+"'"
    cQuery +=   "  AND F5M.D_E_L_E_T_ = ' ' "
    cQuery := ChangeQuery(cQuery)
    cAliasTMP := MPSysOpenQuery(cQuery)
    DBSelectArea(cAliasTMP)
    (cAliasTMP)->(DBGoTop())

    Do Case
        Case IIf(!lClStFN00M, TRBADT->TIPO != "NCC", (cAliasTRB)->E1_TIPO != "NCC")
            If (cAliasTMP)->(!Eof())
                If (cAliasTMP)->F5M_ALIAS == "F4C"
                    aTmpArea := GetArea()
                    DBSelectArea("F4C")
                    aF4CArea := F4C->(GetArea())
                    F4C->(DBSetOrder(5)) // F4C_FILIAL+F4C_CUUID
                    If F4C->(MSSeek(xFilial("F4C")+(cAliasTMP)->F5M_IDDOC))
                        FWExecView("","RU06D07",MODEL_OPERATION_VIEW,,{|| .T.})
                        lRet := .T.
                    EndIf
                    RestArea(aF4CArea)
                    RestArea(aTmpArea)
                EndIf
            EndIf
        Case IIf(!lClStFN00M, TRBADT->TIPO == "NCC", (cAliasTRB)->E1_TIPO == "NCC") .And. FunName() != "MATA101N"
            cQueryULCD += "SELECT DISTINCT E1.E1_PREFIXO, ulcd.* "
            cQueryULCD += "FROM " + RetSqlName("SE1") + " E1 " 
            cQueryULCD += "LEFT JOIN (SELECT F5Y.F5Y_FILIAL, F1.F1_DOC, F5Y.F5Y_CLIENT, F5Y.F5Y_BRANCH, F1.F1_ESPECIE, F5Y.R_E_C_N_O_ RECNO "
            cQueryULCD += "             FROM " + RetSqlName("SF1") + " F1 " 
            cQueryULCD += "             LEFT JOIN " + RetSqlName("F5Y") + " F5Y " 
            cQueryULCD += "             ON  F5Y.F5Y_DOCCRD = F1.F1_DOC AND "
            cQueryULCD += "                 F5Y.F5Y_SERCRD = F1.F1_SERIE AND "
            cQueryULCD += "                 F5Y.F5Y_CLIENT = F1.F1_FORNECE AND "
            cQueryULCD += "                 F5Y.F5Y_BRANCH = F1.F1_LOJA "
            cQueryULCD += "             WHERE "
            cQueryULCD += "                 F5Y.F5Y_DOCCRD = F1.F1_DOC AND "
            cQueryULCD += "                 F5Y.F5Y_SERCRD = F1.F1_SERIE AND "
            cQueryULCD += "                 F5Y.F5Y_CLIENT = F1.F1_FORNECE AND "
            cQueryULCD += "                 F5Y.F5Y_BRANCH = F1.F1_LOJA "
            cQueryULCD += "            ) ulcd "
            cQueryULCD += "ON  E1.E1_FILIAL = ulcd.F5Y_FILIAL AND "
            cQueryULCD += "    E1.E1_NUM = ulcd.F1_DOC AND "
            cQueryULCD += "    E1.E1_CLIENTE = ulcd.F5Y_CLIENT "
            cQueryULCD += "WHERE "
            cQueryULCD += "    E1.E1_FILIAL = ulcd.F5Y_FILIAL AND "
            cQueryULCD += "    E1.E1_NUM = ulcd.F1_DOC AND "
            cQueryULCD += "    E1.E1_CLIENTE = ulcd.F5Y_CLIENT AND "
            cQueryULCD += "    E1.E1_LOJA = ulcd.F5Y_BRANCH AND "
            cQueryULCD += "    E1.E1_TIPO = ulcd.F1_ESPECIE "
            cQueryULCD += "ORDER BY ulcd.RECNO"

            cQueryULCD := ChangeQuery(cQueryULCD)

            If SELECT("TMPULCD") > 0
                TMPULCD->(DbCloseArea())
            EndIf

            dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQueryULCD), "TMPULCD", .T., .F.)
            dbSelectArea("TMPULCD")
            TMPULCD->(DbGoTop())

            While (TMPULCD->(!Eof()))
                If  AllTrim(TMPULCD->F5Y_FILIAL) == xFilial("SE1") .And. ;
                    IIf(!lClStFN00M, AllTrim(TRBADT->PREFIXO), (cAliasTRB)->E1_PREFIXO) == AllTrim(TMPULCD->E1_PREFIXO) .And.;
                    IIf(!lClStFN00M, AllTrim(TRBADT->TITULO), (cAliasTRB)->(IIf(lTpPedBenf, A2_NOME, A1_NOME))) == AllTrim(TMPULCD->F1_DOC) .And. ;
                    AllTrim(cLoja) == AllTrim(TMPULCD->F5Y_BRANCH)
                        DBSelectArea("F5Y")
                        DBGoTo(TMPULCD->RECNO)
                        FWExecView("","RU05D01",MODEL_OPERATION_VIEW,,{|| .T.})
                        lRet := .T.
                        Exit
                EndIf
                dbSkip()
            EndDo
            TMPULCD->(DbCloseArea())
    EndCase
    
    If !lRet .AND. FunName() == "MATA101N" .And. AllTrim(TRBADT->TIPO) $ MVPAGANT
        lRet := RU05XFN00V(cLoja)
    EndIf

    If !lRet
        If lClStFN00M
            lRet := VwARFIN040(cFil,(cAliasTRB)->C5_NUM,"","","")
        Else
            lRet := VwARFIN040(cFil,cPrefix,cNum,cParcela,cTipo)
        EndIf
    EndIf

    If !lRet
        Help("",1,STR0082,,STR0094,1,0)
    EndIf

    If !Empty(cAliasTMP)
        (cAliasTMP)->(DBCloseArea())
    EndIf
    RestArea(aArea)

Return lRet


/*{Protheus.doc} RU05XFN00M
@description
    Functionality on the menu at routine MATA468N called "Prepayment Maintenance"
    At that routine, we will show one list of all browse items + FIE information 
    with balance for the actual branch, grouped by sales order + prepayment document order by prepayment balance desc.
@author Alexandra Velmozhnaya/Oleg.Ivanov
@since 01/06/2021
@version 1.0
@project MA3 - Russia
*/
Function RU05XFN00M(cAliasTRBP as Character)
    Local aArea as Array        // storing working Area of main proccess
    Local aFields as Array
    Local cQuery as Character   // working Query
    Local cAlias as Character   // working Alias
    Local cSlcFld as Character   // select fields
    Local cInsFld as Character   // Browse fields
    Local cClifor as Character   // Name and Prefix
    Local nStat as Numeric      // result Query request
    Local nX as Numeric
    Local oTmp as Object        // Temporary Table
    Local aColumns as Array     // Columns
    Local aSize as Array        // Dialog size
    Local aFldList as Array
    Local aArquivo as Array
    Local aSeek as Array
    Local aFilter as Array
    Local nOrder as Numeric
    Local aTmpRot as Array
    Local lClStFN00M as Logical

    Private oDlgPrep as Object   // Dialog
    Private cMark as Character

    //saving work area  of main proccess
    lClStFN00M := .T.
    aArea := GetArea()
    cMark := "X"
    aSeek := {}
    aArquivo := {}
    aFields := {}
    aFilter  := {}
    cQuery  := ""
    cSlcFld := ""
    cInsFld := "MARCA, "
    cHlpMsg := ""
    cClifor := Iif(lTpPedBenf,"CLIFOR.A2","CLIFOR.A1")

    aFldList := {"C5_FILIAL",;                              // Branch: from Sales Order.
                "C5_NUM",;                                  // Sales Order: from Sales Order. 
                "C6_VALOR",;                                // Total Amount: Total of items at Sales Order.
                "E1_SALDO",;                                // Release Balance: Total amount on MATA468N browse at temporary table TMP. 
                "C5_MOEDA",;                                // Curr.: Currency from Sales Order, C5_MOEDA.
                "CTO_SIMB",;                                //symbol currency
                "C5_CLIENTE",;                              // Customer: Customer code and branch, from C9_CLIENTE
                "C5_LOJACLI",;                              // Customer: Customer code and branch, from C9_LOJA
                IIf(lTpPedBenf, "A2_NOME", "A1_NOME"),;     // Name: Name of customer (SA1 or SA2) depend of sales order type (look the function a468nTpPed).
                "E1_PREFIXO",;                              // Prepayment: Prepayment identification (E1_PREFIXO).
                "E1_NUM",;                                  // Prepayment: Prepayment identification (E1_NUM).
                "E1_PARCELA",;                              // Prepayment: Prepayment identification (E1_PARCELA).
                "E1_TIPO",;                                 // Prepayment: Prepayment identification (E1_TIPO).
                "FIE_VALOR",;                               // Amount Related: Total amount related to that sales order on FIE table at column FIE_VALOR.
                "FIE_SALDO",;                               // Amount Balance: Total balance related to that sales order on FIE table at column FIE_SALDO.
                "E1_TXMOEDA" }                              // Ex. Rate Prepayment: The value at E1_TXMOEDA on prepayment document.

    AADD(aFields, {"MARCA", "C", 1, 0, '@!', ' '})

    For nX := 1 To Len(aFldList)

        AADD(aFields, { aFldList[nX],;
                        GetSX3Cache(aFldList[nX], "X3_TIPO"   ),;
                        GetSX3Cache(aFldList[nX], "X3_TAMANHO"),;
                        GetSX3Cache(aFldList[nX], "X3_DECIMAL"),;
                        GetSX3Cache(aFldList[nX], "X3_PICTURE"),;
                        RetTitle(aFldList[nX]) } )
        Do Case
            Case aFldList[nX] == "C5_FILIAL"
                cSlcFld += " SC5.C5_FILIAL AS "+aFldList[nX]+", "
            Case aFldList[nX] == "C5_NUM"
                cSlcFld += " SC5.C5_NUM AS "+aFldList[nX]+", "
            Case aFldList[nX] == "C6_VALOR"
                If lPedidos
                    cSlcFld += " (TRB.C9_PRCVEN * TRB.C9_QTDLIB) AS " +aFldList[nX]+", "
                Else
                    cSlcFld += " (TRB.D2_PRCVEN * TRB.D2_QUANT) AS " +aFldList[nX]+", "
                EndIf
            Case aFldList[nX] == "C5_MOEDA"
                cSlcFld += " SC5.C5_MOEDA AS "+aFldList[nX]+", "
            Case aFldList[nX] == "CTO_SIMB"
                cSlcFld += " CTO.CTO_SIMB AS "+aFldList[nX]+", "
            Case aFldList[nX] == "C5_CLIENTE"
                cSlcFld += " SC5.C5_CLIENTE AS "+aFldList[nX]+", "
            Case aFldList[nX] == "C5_LOJACLI"
                cSlcFld += " SC5.C5_LOJACLI AS "+aFldList[nX]+", "
            Case aFldList[nX] == "A1_NOME"
                cSlcFld += cClifor + "_NOME AS "+aFldList[nX]+", "
            Otherwise
                cSlcFld += aFldList[nX]+" AS "+aFldList[nX]+", "
        EndCase
        cInsFld += aFldList[nX] + ", "
    Next nX

    cSlcFld := SubStr(cSlcFld,1,Len(cSlcFld)-2)
    cInsFld := SubStr(cInsFld,1,Len(cInsFld)-2)

    nOrder := 1
    cAlias  := CriaTrab( ,.F.)
    oTmp := FWTemporaryTable():New(cAlias)
    oTmp:SetFields(aFields)

    For nX := 1 To Len(aFields)
        If !(aFields[nX][1] $ "|MARCA|C6_VALOR|E1_SALDO|CTO_SIMB|C5_LOJACLI|E1_PARCELA|FIE_VALOR|FIE_SALDO|E1_TXMOEDA|" )
            oTmp:AddIndex(cAlias+cValToChar(nOrder),{aFields[nX][1]})
            
            aAdd(aSeek,{RetTitle(aFields[nX][1])/*Title*/,{{""/*LookUp*/, TamSX3(aFields[nX][1])[3]/*Type*/, TamSX3(aFields[nX][1])[1]/*Size*/,;
                            TamSX3(aFields[nX][1])[2]/*Decimal*/,aFields[nX][5]}}, nOrder,.T. } )
            aAdd(aFilter, {aFields[nX][1], RetTitle(aFields[nX][1]), TamSX3(aFields[nX][1])[3], TamSX3(aFields[nX][1])[1],; 
                            TamSX3(aFields[nX][1])[2], aFields[nX][5]} )
            nOrder += 1
        EndIf
    Next nX

    oTmp:Create()

    // here should be query for main information

    cQuery += " SELECT ' ' MARCA, " + cSlcFld 
    cQuery += " FROM " + oTmpTable:GetRealName() + " TRB "
    // add Sales Order
    cQuery += " INNER JOIN " 
    cQuery += "     (SELECT C5_FILIAL, C5_NUM, C5_MOEDA, C5_CLIENTE, C5_LOJACLI "
    cQuery += "      FROM " + RetSqlName("SC5") 
    cQuery += "      WHERE C5_FILIAL = '" + xFilial('SC5') + "' "
    cQuery += "      AND D_E_L_E_T_ = ' ') SC5 "
    cQuery += " ON "
    If lPedidos
        cQuery += " SC5.C5_NUM = TRB.C9_PEDIDO "
        cQuery += " AND SC5.C5_CLIENTE = TRB.C9_CLIENTE "
    Else
        cQuery += " SC5.C5_NUM = TRB.D2_PEDIDO "
        cQuery += " AND SC5.C5_CLIENTE = TRB.D2_CLIENTE "
    EndIf
    // add Prepayment x Order
    cQuery += " INNER JOIN " + RetSqlName("FIE") + " FIE "
    cQuery += " ON  FIE.FIE_FILIAL = '" + xFilial('FIE') + "' "    
    cQuery += " AND FIE.FIE_PEDIDO = SC5.C5_NUM "
    cQuery += " AND FIE.FIE_CLIENT = SC5.C5_CLIENTE "
    cQuery += " AND FIE.D_E_L_E_T_ = ' '"
    // add Prepayment
    cQuery += " INNER JOIN " + RetSqlName("SE1") + " SE1 "
    cQuery += " ON  SE1.E1_FILIAL   = '" + xFilial('SE1') + "' "
    cQuery += " AND SE1.E1_PREFIXO  = FIE.FIE_PREFIX "
    cQuery += " AND SE1.E1_NUM      = FIE.FIE_NUM	 "
    cQuery += " AND SE1.E1_PARCELA  = FIE.FIE_PARCEL "
    cQuery += " AND SE1.E1_TIPO     = FIE.FIE_TIPO "
    cQuery += " AND SE1.D_E_L_E_T_  = ' '"
    // add Currency
    cQuery += " INNER JOIN " + RetSqlName("CTO") + " CTO "
    cQuery += " ON CTO.CTO_FILIAL = '" + xFilial('CTO') + "' " 
    cQuery += " AND CAST(CTO.CTO_MOEDA AS INTEGER) = SC5.C5_MOEDA "
    cQuery += " AND CTO.D_E_L_E_T_ = ' '"
    // add Client or supplier table
    cQuery += " INNER JOIN "
    If lTpPedBenf
        cQuery += RetSqlName("SA2") + " CLIFOR "
    Else
        cQuery += RetSqlName("SA1") + " CLIFOR "
    Endif
    cQuery += " ON " + cClifor + "_FILIAL='"+ xFilial(Iif(lTpPedBenf,"SA2", "SA1"))+"'"
    If lPedidos
        cQuery += " AND TRB.C9_CLIENTE = " + cClifor + "_COD "
        cQuery += " AND TRB.C9_LOJA = " + cClifor + "_LOJA "
    Else
        cQuery += " AND TRB.D2_CLIENTE = " + cClifor + "_COD "
        cQuery += " AND TRB.D2_LOJA = " + cClifor + "_LOJA "
    EndIf
    cQuery += " AND CLIFOR.D_E_L_E_T_ = ' '"
    cQuery += " GROUP BY C5_FILIAL, C5_NUM, C6_VALOR, E1_SALDO, C5_MOEDA," 
    cQuery += " CTO_SIMB, C5_CLIENTE, C5_LOJACLI, A1_NOME, E1_PREFIXO," 
	cQuery += " E1_NUM, E1_PARCELA, E1_TIPO, FIE_VALOR, FIE_SALDO, E1_TXMOEDA "
    cQuery += "  "

    cQuery := ChangeQuery(cQuery)
 
    cQuery := "INSERT INTO " + oTmp:GetRealName() +;
                "          ( " + cInsFld            + ") " + cQuery
    nStat  := TCSqlExec(cQuery)

    cTmpAlias := oTmp:GetAlias()
    If nStat >= 0
        DBSelectArea(cTmpAlias)
        DBGoTop()
        If (cTmpAlias)->(!EoF())
            aColumns := {}
            For nX := 2 To Len(aFields)
                AADD(aColumns, FWBrwColumn():New())  
                aColumns[nX-1]:SetData(&("{||"+aFields[nX][1]+"}"))  //there should not be a column with a stamp field!
                aColumns[nX-1]:SetTitle(aFields[nX][6])              // since a column with an empty field will appear in the grid
                aColumns[nX-1]:SetSize(aFields[nX][3])
                aColumns[nX-1]:SetDecimal(aFields[nX][4])
                aColumns[nX-1]:SetPicture(aFields[nX][5]) 
            Next nX
            
            aSize  := MsAdvSize()
            oDlgPrep := MsDialog():New(aSize[7], aSize[2], aSize[6], aSize[5],;
                                        STR0081, , , , ,;             
                                        CLR_BLACK, CLR_WHITE, , ,;
                                        .T., , , , .T.                         )
            oBrwsPrep := FWMarkBrowse():New()  
            oBrwsPrep:oBrowse:SetAlias(cTmpAlias) //Temporary Table Alias
            oBrwsPrep:SetOwner(oDlgPrep)
            
            aTmpRot  := IIF(aRotina == Nil, Nil, ACLONE(aRotina))
            
            oBrwsPrep:oBrowse:SetMenuDef("")
            oBrwsPrep:oBrowse:SetTemporary(.T.) //Using Temporary Table
            oBrwsPrep:oBrowse:SetSeek(.T., aSeek)
            oBrwsPrep:oBrowse:SetUseFilter(.T.) //Using Filter
            oBrwsPrep:oBrowse:SetProfileID("RU05XFUNFL")//ID for filter
            oBrwsPrep:oBrowse:DisableDetails()
            oBrwsPrep:oBrowse:DisableReport()
            oBrwsPrep:oBrowse:SetColumns(aColumns)
            oBrwsPrep:oBrowse:SetIgnoreARotina(.T.)
            oBrwsPrep:oBrowse:SetFieldFilter(aFilter) //Set Filters
        //Add Mark
            oBrwsPrep:oBrowse:AddMarkColumns({|| IIf(Empty((cTmpAlias)->MARCA), "LBNO", "LBOK")},; //Code-Block image
                                            {|| SelectOne(oBrwsPrep:oBrowse, cTmpAlias) },; //Code-Block Double Click
                                            {|| SelectAll(oBrwsPrep:oBrowse, cTmpAlias)}) //Code-Block Header Click

        // Add Buttons
            oBrwsPrep:AddButton(STR0086, {|| oDlgPrep:End()},0, 3)                                                                  //+ Save/Cancel
            oBrwsPrep:AddButton(STR0087, {|| RU05XFN00S(cTmpAlias, aFields, cMark)},0, 1)                                           //+ Print
            oBrwsPrep:AddButton(STR0088, {|| RU05XFN00T(cTmpAlias, (cTmpAlias)->C5_LOJACLI, cMark, lClStFN00M)}, 0, 1)              //+ Open Prepayment 
            oBrwsPrep:AddButton(STR0089, {|| RU05XFN00N(cTmpAlias, cMark)}, 0, 1)                                                   //+ Open Sales Order
            oBrwsPrep:AddButton(STR0090, {|| RU05XFN00P(cAliasTRBP, cTmpAlias, aParams, oBrwsPrep, cMark)},0, 1)                    //+ Auto Relation 
            oBrwsPrep:AddButton(STR0091, {|| RU05XFN00O(oBrwsPrep, cTmpAlias, cMark)},0, 1)                                         //+ Select Prepayment
            oBrwsPrep:AddButton(STR0092, {|| RU05XFN00R(oBrwsPrep, cTmpAlias, cMark)},0, 1)                                         //+ Delete Prepayment

        //Change Order
            oBrwsPrep:oBrowse:SetColumnOrder(Len(oBrwsPrep:oBrowse:aColumns), 01)
            oBrwsPrep:oBrowse:Activate()

            oDlgPrep:Activate(,,,.T.,,,)
            
            aRotina  := aTmpRot
        Else
            cHlpMsg := STR0093 // There is no advances for that sales order
        EndIf
    Else
        cHlpMsg += " TCSQLError() " + TCSQLError()
    EndIf

    If !Empty(cHlpMsg)
        Help("",1,STR0082,,cHlpMsg,1,0) 
    EndIf
    oTmp:Delete()

    //return work area  of main proccess
    RestArea(aArea)

Return Nil


/*{Protheus.doc} SelectOne
@description
    Double click (one mark) for MarkBrowse in function RU05XFN00M
@author oleg.ivanov
@since 04/06/2021
@version 1.0
@project MA3 - Russia
*/
Static Function SelectOne(oBrwsPrep as Object, cTmpAlias as Char, cFieldName as Character)
    Local aArea := GetArea()
 
    Default cFieldName := "MARCA"

    RecLock(cTmpAlias, .F.)
	If !Empty(AllTrim((cTmpAlias)-> ( &(cFieldName)) ) )
		(cTmpAlias)-> ( &(cFieldName) ) := ""
	Else
		(cTmpAlias)->( &(cFieldName) ) := cMark
	EndIf
	(cTmpAlias)->(MsUnlock())
        
    oBrwsPrep:Refresh()

    RestArea(aArea)
    
Return .T.


/*{Protheus.doc} SelectAll
@description
    Double click (all mark) for MarkBrowse in function RU05XFN00M
@author oleg.ivanov
@since 04/06/2021
@version 1.0
@project MA3 - Russia
*/
Static Function SelectAll(oBrwsPrep as Object, cTmpAlias as Char, cFieldName as Character)
    Local nRecOri 	as Numeric
    Local aArea := GetArea()

    Default cFieldName := "MARCA"
    
    nRecOri	:= (cTmpAlias)->(RecNo())

    dbSelectArea(cTmpAlias)
    (cTmpAlias)->( DbGoTop() )
    While !(cTmpAlias)->( Eof() )
        RecLock(cTmpAlias, .F.)
        If !Empty(AllTrim((cTmpAlias)-> ( &(cFieldName)) ) )
            (cTmpAlias)-> ( &(cFieldName) ) := ""
        Else
            (cTmpAlias)->( &(cFieldName) ) := cMark
        EndIf
        MsUnlock()

        (cTmpAlias)->( DbSkip() )
    Enddo

    (cTmpAlias)->(DbGoTo(nRecOri))

    oBrwsPrep:Refresh()

    RestArea(aArea)

Return .T.


/*{Protheus.doc} RU05XFN00N
@description
    Button from mata468n FI-AR-16-1 -- function RU05XFN00M() - Open Sales Order
@author oleg.ivanov
@since 15/06/2021
@version 1.0
@project MA3 - Russia
*/
Function RU05XFN00N(cAlias as Character, cMark as Character)
    Local aArea := GetArea()
    Local nOpc := 2 //Visual

    DBSelectArea("SC5")
	DBSetOrder(1) 
    MsSeek(xFilial("SC5")+(cAlias)->C5_NUM)

    dbSelectArea(cAlias)
    (cAlias)->( DbGoTop() )
        
    While ((cAlias)->(!Eof()))       
        If (cAlias)->MARCA == cMark
            A410Visual("SC5",SC5->(Recno()),nOpc)
        Else
            Help("",1,STR0082,,STR0083,1,0) 
        EndIf
            dbSkip()
    EndDo
    SC5->(DbCloseArea())

    RestArea(aArea)

Return Nil


/*{Protheus.doc} RU05XFN00O
@description
    Button from mata468n FI-AR-16-1 -- function RU05XFN00M() - Select Prepayment
@author oleg.ivanov
@since 16/06/2021
@version 1.0
@project MA3 - Russia
*/
Function RU05XFN00O(oBrwsPrep as Object, cAlias as Character, cMark as Character)
    Local nValParcLc as Numeric
    Local aArea := GetArea()

    DBSelectArea(cAlias)
    (cAlias)->( DbGoTop() )
    
    nValParcLc := (SC6->C6_QTDVEN - SC6->C6_QTDENT) * SC6->C6_PRCVEN

    While ((cAlias)->(!Eof()))       
        If (cAlias)->MARCA == cMark    
            DBSelectArea("SC5")
            DBSetOrder(1) 
            MsSeek(xFilial("SC5")+(cAlias)->C5_NUM)

            DBSelectArea("SC6")
            DBSetOrder(1) 
            MsSeek(xFilial("SC6")+(cAlias)->C5_NUM)

            A410Adiant((cAlias)->C5_NUM, SC5->C5_CONDPAG, nValParcLc, , .F., (cAlias)->C5_CLIENTE, (cAlias)->C5_LOJACLI, .T.,,,,,,,,)
        EndIf
        dbSkip()
    EndDo

    SC5->(DbCloseArea())
    SC6->(DbCloseArea())

    oBrwsPrep:Refresh()

    RestArea(aArea)

Return Nil


/*{Protheus.doc} RU05XFN00P
@description
    Button from mata468n FI-AR-16-1 -- function RU05XFN00M() - Automatic Relation
@author oleg.ivanov
@since 16/06/2021
@version 1.0
@project MA3 - Russia
*/
Function RU05XFN00P(cAliasTRBP as Character, cAlias as Character, aParams as Array, oBrowsePrep as Object, cMark as Character)
    Local aArea := GetArea()

    DBSelectArea(cAlias)
    (cAlias)->( DbGoTop() )

    While ((cAlias)->(!Eof()))       
        If (cAlias)->MARCA == cMark    
            DBSelectArea(cAliasTRBP)
            DBSetOrder(3)
            MsSeek(xFilial("SC5")+(cAlias)->C5_CLIENTE+(cAlias)->C5_LOJACLI, .T.)

            RecLock(cAliasTRBP,.F.)
				a468nMrk()
			MsUnLock()

            a468nFatura(cAlias,aParams,,,,,,,,,.T.)
        EndIf
        dbSkip()
    EndDo

    oBrwsPrep:Refresh()

    RestArea(aArea)

Return Nil


/*{Protheus.doc} RU05XFN00R
@description
    Button from mata468n FI-AR-16-1 -- function RU05XFN00M() - Delete some relations Prepayment
@author oleg.ivanov
@since 16/06/2021
@version 1.0
@project MA3 - Russia
*/
Function RU05XFN00R(oBrwsPrep as Object, cAlias as Character, cMark as Character)
    Local lDeletPrep as Logical
    Local aArea := GetArea()

    lDeletPrep := .F.

    If !IsBlind()
        lDeletPrep := MsgYesNo(STR0084, STR0085)   
    EndIf
    
    DBSelectArea(cAlias)
    (cAlias)->( DbGoTop() )

    If lDeletPrep
        DBSelectArea("FIE")
        DBSetOrder(2)
        MsSeek(xFilial("FIE")+(cAlias)->C5_CLIENTE+(cAlias)->C5_LOJACLI+(cAlias)->E1_PREFIXO+ ;
                (cAlias)->C5_NUM+(cAlias)->E1_PARCELA+(cAlias)->E1_TIPO, .T.)
        
        While ((cAlias)->(!Eof()))       
            If (cAlias)->MARCA == cMark   
                RecLock("FIE",.F.)
                Do Case
                    Case FIE->FIE_SALDO == FIE->FIE_VALOR
                        DbDelete()
                    Case FIE->FIE_SALDO < FIE->FIE_VALOR
                        FIE->FIE_VALOR -= FIE->FIE_SALDO
                        FIE->FIE_SALDO := 0
                EndCase
                        
                MsUnLock()
            EndIf
            dbSkip()
        EndDo
        FIE->(DbCloseArea())
    EndIf

    oBrwsPrep:Refresh()
    
    RestArea(aArea)

Return Nil


/*{Protheus.doc} RU05XFN00S
@description
    Button from mata468n FI-AR-16-1 -- function RU05XFN00M() - Print
@author oleg.ivanov
@since 16/06/2021
@version 1.0
@project MA3 - Russia
*/
Function RU05XFN00S(cAlias as Character, aFields as Array, cMark as Character)
    Local aArea := GetArea()
    
    DBSelectArea(cAlias)
    (cAlias)->( DbGoTop() )

    While ((cAlias)->(!Eof()))       
        If (cAlias)->MARCA == cMark    
            RUPrepPrnt(cAlias, aFields)
        EndIf
        dbSkip()
    EndDo
       
    RestArea(aArea)

Return Nil


/*{Protheus.doc} RU05XFN00T
@description
    Button from mata468n FI-AR-16-1 -- function RU05XFN00M() - Open Prepayment
@author oleg.ivanov
@since 21/06/2021
@version 1.0
@project MA3 - Russia
*/
Function RU05XFN00T(cTmpAlias as Character, cLoja as Character, cMark as Character, lClStFN00M as Logical)
    Local aArea := GetArea()

    Default lClStFN00M := .F.

    DBSelectArea(cTmpAlias)
    (cTmpAlias)->( DbGoTop() )

    While ((cTmpAlias)->(!Eof()))       
        If (cTmpAlias)->MARCA == cMark    
            RU05XFN00L(cTmpAlias, cLoja, lClStFN00M)
        EndIf
        dbSkip()
    EndDo

    RestArea(aArea)

Return Nil


/*{Protheus.doc} RU05XFN00U
@description
    Recalculation of currency rate include prepayments
@author alexandra.velmozhnaya
@since 26/06/2021
@version 1.0
@project MA3 - Russia
*/

Function RU05XFN00U(nCurrency)
    Local aArea     as Array
    Default nCurrency := Nil
    aArea := GetArea()
    MaFisAlt("NF_TXMOEDA",nCurrency)
    If FunName() == "MATA101N"
        M->F1_TXMOEDA := MafisRet(,"NF_TXMOEDA")
        ExcRt101N(.T.,.T.) //update the totals
    Else
        M->F2_TXMOEDA := MafisRet(,"NF_TXMOEDA")
        ExcRt467N(.T.,,.T.) //update the totals
    EndIf
    RestArea(aArea)
Return Nil


/*{Protheus.doc} RU05XFN0U1
@description
    the code block is transferred from the source mata468n, the function a468nGravF2 (), all variables are taken from the function a468nGravF2()
@author oleg.ivanov
@since 20/07/2021
@version 1.0
@project MA3 - Russia
*/
Function RU05XFN0U1(lPedidos as Logical, aNFs as Array, nPosNF as Numeric, cRem as Character, aTamSx3Prc as Array, dDTSaida as Date)
    Local aGetSC9Rus as Array
    Local aGetSD2Rus as Array
    Local aGetSE1Rus as Array
    Local aRecPRE    as Array
    Local aRecnoSE1  as Array
    Local cCart2     as Character
    Local cCliFor2   as Character
    Local cLoja2     as Character
    Local cNatureza2 as Character
    Local cNumero2   as Character
    Local cParcela2  as Character
    Local cPrefixo2  as Character
    Local cTipo2     as Character
    Local nJJ        as Numeric
    Local nMoeda2    as Numeric
    Local nOrig      as Numeric
    Local nOrig2     as Numeric
    Local nTaxamoeda as Numeric
    Local nTotal     as Numeric
    Local nTotal2    as Numeric
    Local nVAlSaldo  as Numeric
    Local nValFim    as Numeric
    Local nValFim2   as Numeric
    Local nI         as Numeric
    Local nValTax    as Numeric
    Local __nSalFIm	 as Numeric
    Local __usedBef  as Numeric
    Local aAllVarU1  as Array
    Local _aOrdAdd   as Array
    Local __cArea    as Character
    Local __nPos     as Numeric
    Local nPrtDel    as Numeric   // used for partial delivery (RUS)

    aGetSE1Rus := SE1->(GetArea())
	aGetSC9Rus := SC9->(GetArea())
	If !lPedidos
		aGetSD2Rus := SD2->(GetArea())
	EndIf

    aAllVarU1   := {}
	__cArea     := GetArea()
	_aOrdAdd    := {}
	nTotal      := 0
	nOrig       := 0
	nValFim     := 0
	nValFim2    := 0
    nValTax     :=0

	//Group all items for sales order
	For nJJ := 1 To Len((aNFs[nPosNF][2]))        
		If lPedidos
			DbSelectArea('SC9')
			DbGoTo(aNFs[nPosNF][2][nJJ])
           
            if Len(aNFs[nPosNF][13]) > 0 .And. (aNFs[nPosNF][13][nJJ][1]) != 0 .AND. aNFs[nPosNF][13][nJJ][1] != (SC9->C9_QTDLIB)
                nPrtDel := RU05XFN0S3(aNFs[nPosNF][13][nJJ][1], (SC9->C9_QTDLIB), SC9->C9_PEDIDO, SC9->C9_CLIENTE, SC9->C9_ITEM, SC9->C9_PRODUTO)
            else
                nPrtDel := 1
            Endif

            nValTax := nPrtDel * RU05XFN01P(SC9->C9_PEDIDO,SC9->C9_ITEM)
            nValFim := nPrtDel * RU05XFN01U(SC9->C9_PEDIDO,SC9->C9_ITEM) + nValTax
            
		Else
			DBSelectArea("SD2")
			SD2->(DbGoTo(aNFs[nPosNF][2][nJJ]))


			DbSelectArea('SC9')
			SC9->(DBSetOrder(1))	//C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO+C9_BLEST+C9_BLCRED
			SC9->(DBSeek(xFilial("SC9") + SD2->(D2_PEDIDO + D2_ITEMPV)))
			nValFim := (cRem)->D2_VALBRUT 
		EndIf
		nValFim2 += nValFim
		__nPos := AScan(_aOrdAdd,{|x| x[1] == SC9->C9_PEDIDO })
		If __nPos > 0
			_aOrdAdd[__nPos,2] += nValFim //add value to control
		Else
			aAdd(_aOrdAdd,{SC9->C9_PEDIDO,nValFim})
		EndIf
	Next nJJ
	aRecPRE := {}
	//With sales order group amount, we will try to found prepayment for each one and calculate the amounts
	For nI := 1 To Len(_aOrdAdd)
		nVAlSaldo := _aOrdAdd[nI][2]
		nOrig2 := 0
		//Prepayments for that sales order
		aRecnoSE1 := FPedAdtPed( "R", {_aOrdAdd[nI][1]}, .F. )
		For nJJ := 1 To Len(aRecnoSE1)
			DbSelectArea('SE1')
			dbGoTo(aRecnoSE1[nJJ][2])
			//Take the amount until you make up the total balance of the order
			// calculate total value   
			//Checks the total of the Order until reaching the total advance, according to the order of the FIE
			If nVAlSaldo >= aRecnoSE1[nJJ, 3]
				nTotal2 :=  Round(aRecnoSE1[nJJ][3] * Round(SE1->E1_VLCRUZ/SE1->E1_VALOR,TamSx3("E1_TXMOEDA")[2]),aTamSx3Prc[2]) // (SE1->E1_VLCRUZ/SE1->E1_VALOR) contra E1_TXMOEDA
				nOrig += aRecnoSE1[nJJ][3]
				nOrig2 := aRecnoSE1[nJJ][3]
				nVAlSaldo -= aRecnoSE1[nJJ][3]
			ElseIf nVAlSaldo > 0
				nTotal2 :=  Round(nVAlSaldo * Round(SE1->E1_VLCRUZ/SE1->E1_VALOR,TamSx3("E1_TXMOEDA")[2]), aTamSx3Prc[2]) // (SE1->E1_VLCRUZ/SE1->E1_VALOR) contra E1_TXMOEDA
				nOrig += nVAlSaldo
				nOrig2 := nVAlSaldo
				nVAlSaldo := 0
			Else
				nVAlSaldo := 0
			EndIf
			//Controle prepayment linked with others sales
			__nSalFIm := nOrig2
			__usedBef := nTotal2
			__nPos := AScan(aRecPRE,{|x| x[1] == SE1->(Recno()) })
			IF __nPos > 0
				aRecPRE[__nPos,2] += nOrig2 //add value to control
				__usedBef := aRecPRE[__nPos,3] //used before that sales order
				aRecPRE[__nPos,3] += nTotal2 //add value to control
				__nSalFIm := aRecPRE[__nPos,2] //total used in original currency
			Else
				aAdd(aRecPRE,{SE1->(Recno()),nOrig2,nTotal2})
			EndIf
			//if the header balance is equal to the write-off value, the header is reset to zero
			If SE1->E1_SALDO == __nSalFIm .and. __nPos >0
				cPrefixo2 := SE1->E1_PREFIXO
				cNumero2 := SE1->E1_NUM
				cParcela2 := SE1->E1_PARCELA
				cTipo2 := SE1->E1_TIPO
				cNatureza2 := SE1->E1_NATUREZ
				cCart2 := 'R'
				cCliFor2 := SE1->E1_CLIENTE
				nMoeda2 := 1 //Rublos
				cLoja2 := SE1->E1_LOJA//TODOLAST takes the balance in rubles and does not calculate the amount
				nTotal += xSaldoTit(cPrefixo2,cNumero2,cParcela2,cTipo2,cNatureza2,cCart2,cCliFor2,nMoeda2,,,cLoja2,,,,,) - __usedBef
				//calculated balance - used proportional in other sales
			Else
				nTotal += nTotal2
			Endif
		Next nJJ
	Next nI
	RestArea(aGetSE1Rus)
	RestArea(aGetSC9Rus)
	If !lPedidos
		RestArea(aGetSD2Rus)
	EndIf
	RestArea(__cArea)
	//Remaining balance without advance
	nTotal += (nValFim2 - nOrig) * RecMoeda(dDTSaida,SC5->C5_MOEDA)
	//calculate the new extract
	If SC5->C5_MOEDA != 1
	    nTaxamoeda := Round(nTotal,aTamSx3Prc[2]) / nValFim2 
    Else
        nTaxamoeda := RecMoeda(dDTSaida,SC5->C5_MOEDA)
    EndIf
	// (Selected amount of prepayment 1 * E1_TXMOEDA of AR 1  +  Selected amount of prepayment 2 * E1_TXMOEDA of AR 2  + … + Left balance of invoice * current exchange rate) / Total amount of invoice
    //retur all variables
    aAdd(aAllVarU1,{nTaxamoeda, aNFs, aTamSx3Prc, dDTSaida})

Return aAllVarU1


/*{Protheus.doc} RU05XFN0U2
@description
    the code block is transferred from the source mata468n, the function a468nGravF2 (), all variables are taken from the function a468nGravF2()
@author oleg.ivanov
@since 20/07/2021
@version 1.0
@project MA3 - Russia
*/
Function RU05XFN0U2(lPedidos as Logical, aNFs as Array, nPosNF as Numeric, cRem as Character, aTamSx3Prc as Array, dDTSaida as Date)
    Local aGetSC9Rus as Array
    Local aGetSD2Rus as Array
    Local aGetSE1Rus as Array
    Local aRecPRE    as Array
    Local aRecnoSE1  as Array
    Local aVencPre   as Array
    Local cCart2     as Character
    Local cCliFor2   as Character
    Local cLoja2     as Character
    Local cNatureza2 as Character
    Local cNumero2   as Character
    Local cParcela2  as Character
    Local cPrefixo2  as Character
    Local cTipo2     as Character
    Local nJJ        as Numeric
    Local nMoeda2    as Numeric
    Local nOrig      as Numeric
    Local nOrig2     as Numeric
    Local nTotal     as Numeric
    Local nTotal2    as Numeric
    Local nVAlSaldo  as Numeric
    Local nValFim    as Numeric
    Local nValTax    as Numeric
    Local nValFim2   as Numeric
    Local nI         as Numeric
    Local __nSalFIm	as Numeric
    Local __usedBef	as Numeric
    Local aAllVarU2 as Array
    Local _aOrdAdd  as Array
    Local __cArea   as Character
    Local __aTempPe as Array
    Local __nPos    as Numeric
    Local nPrtDel   as Numeric   // used for partial delivery (RUS)

    aAllVarU2 := {}
    aVencPre := {} //array with advance prepayment data
	aGetSE1Rus := SE1->(GetArea())
	aGetSC9Rus := SC9->(GetArea())
	If !lPedidos
		aGetSD2Rus := SD2->(GetArea())
	EndIf
	__cArea     := GetArea()
	_aOrdAdd    := {}
	aRecnoSE1   := {}
	__aTempPe   := {}
	nValFim2    := 0
    nValFim     := 0
    nValTax     := 0
    
	//Get the prepayments for all itens
	//We can have a at FIE 1000 balance 1000 and invoice 10 for the one item, and have other itens without balance
	//and in same invoice many other itens withou prepayment, so in that case we will use ony 10, because there is only one item with prepayment
	For nJJ := 1 To Len((aNFs[nPosNF][2]))
		If lPedidos
			DbSelectArea('SC9')
			SC9->(DbGoTo(aNFs[nPosNF][2][nJJ]))

            if Len(aNFs[nPosNF][13]) > 0 .And. (aNFs[nPosNF][13][nJJ][1]) != 0 .AND. aNFs[nPosNF][13][nJJ][1] != (SC9->C9_QTDLIB)
                nPrtDel := RU05XFN0S3(aNFs[nPosNF][13][nJJ][1], (SC9->C9_QTDLIB), SC9->C9_PEDIDO, SC9->C9_CLIENTE, SC9->C9_ITEM, SC9->C9_PRODUTO)
            else
                nPrtDel := 1
            Endif

            nValTax := nPrtDel * RU05XFN01P(SC9->C9_PEDIDO,SC9->C9_ITEM)
            nValFim := nPrtDel * RU05XFN01U(SC9->C9_PEDIDO,SC9->C9_ITEM) + nValTax

		Else
			DBSelectArea("SD2")
			SD2->(DbGoTo(aNFs[nPosNF][2][nJJ]))
			SC9->(DbSelectArea('SC9'))
			SC9->(DBSetOrder(1))	//C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO+C9_BLEST+C9_BLCRED
			SC9->(DBSeek(xFilial("SC9") + SD2->(D2_PEDIDO + D2_ITEMPV)))
			nValFim := (cRem)->D2_VALBRUT 
		EndIf
		
		nValFim2 += nValFim
		__nPos := AScan(_aOrdAdd,{|x| x[1] == SC9->C9_PEDIDO })
		If __nPos > 0
			_aOrdAdd[__nPos,2] += nValFim //add value to control
		Else
			aAdd(_aOrdAdd,{SC9->C9_PEDIDO,nValFim})
		EndIf
	Next nJJ
	aRecPRE := {}
	nOrig2 := 0
	//With sales order group amount, we will try to found prepayment for each one and calculate the amounts FOR INSTALLMENTS
	For nI := 1 To Len(_aOrdAdd)
		nOrig := 0
		nTotal := 0
		nTotal2 := 0
		nVAlSaldo := _aOrdAdd[nI][2]
		//Prepayments for that sales order
		aRecnoSE1 := FPedAdtPed( "R", {_aOrdAdd[nI][1]}, .F. )
		For nJJ := 1 To Len(aRecnoSE1)
			If nVAlSaldo <= 0
				Exit
			EndIf
			nOrig2 := 0
			DbSelectArea('SE1')
			dbGoTo(aRecnoSE1[nJJ][2])
			//Pega o valor ate compor o saldo total do pedido
			//calculo valor total	//Verifica o total do Pedido ate atingir o total de adiantamento, pela orde do rencno do FIE
			If nVAlSaldo >= aRecnoSE1[nJJ, 3]
				nTotal2 :=  Round(aRecnoSE1[nJJ][3] * Round(SE1->E1_VLCRUZ/SE1->E1_VALOR,TamSx3("E1_TXMOEDA")[2]),aTamSx3Prc[2]) // (SE1->E1_VLCRUZ/SE1->E1_VALOR) contra E1_TXMOEDA
				nOrig += aRecnoSE1[nJJ][3]
				nOrig2 := aRecnoSE1[nJJ][3]
				nVAlSaldo -= aRecnoSE1[nJJ][3]
			ElseIf nVAlSaldo < aRecnoSE1[nJJ, 3]
				nTotal2 :=  Round(nVAlSaldo * Round(SE1->E1_VLCRUZ/SE1->E1_VALOR,TamSx3("E1_TXMOEDA")[2]), aTamSx3Prc[2]) // (SE1->E1_VLCRUZ/SE1->E1_VALOR) contra E1_TXMOEDA
				nOrig += nVAlSaldo
				nOrig2 := nVAlSaldo
				nVAlSaldo := 0
			Else
				nVAlSaldo := 0
			EndIf
			//Controle prepayment linked with others sales
			__nSalFIm := nOrig2
			__usedBef := nTotal2
			__nPos := AScan(aRecPRE,{|x| x[1] == SE1->(Recno()) })
			If __nPos > 0
				aRecPRE[__nPos,2] += nOrig2 //add value to control
				__usedBef := aRecPRE[__nPos,3] //used before that sales order
				aRecPRE[__nPos,3] += nTotal2 //add value to control
				__nSalFIm := aRecPRE[__nPos,2] //total used in original currency
			Else
				aAdd(aRecPRE,{SE1->(Recno()),nOrig2,nTotal2})
			EndIf
			//se saldo titulo for igual ao valor da baixa, esta zerando o titulo
			If SE1->E1_SALDO == __nSalFIm .and. __nPos >0
				cPrefixo2 := SE1->E1_PREFIXO
				cNumero2 := SE1->E1_NUM
				cParcela2 := SE1->E1_PARCELA
				cTipo2 := SE1->E1_TIPO
				cNatureza2 := SE1->E1_NATUREZ
				cCart2 := 'R'
				cCliFor2 := SE1->E1_CLIENTE
				nMoeda2 := 1 //Rublos
				cLoja2 := SE1->E1_LOJA//TODOLAST pega o saldo em rublos e n?o calcula o valor
				nTotal2 := xSaldoTit(cPrefixo2,cNumero2,cParcela2,cTipo2,cNatureza2,cCart2,cCliFor2,nMoeda2,,,cLoja2,,,,,) - __usedBef
			Endif
			//Grouped same advanced in one installments
			__nPos := AScan(aVencPre,{|x| x[5] == SE1->(Recno()) })
			If __nPos > 0
				aVencPre[__nPos,2] += nOrig2 //add value in original currency
				aVencPre[__nPos,4] += nTotal2 //add value in rubles value
			Else
				//	      	ISSUE DATE , ORIGINAL AMONT  , EX RATE		   , FINAL AMOUNT, RECNO
				Aadd(aVencPre,{dDTSaida,nOrig2           , SE1->E1_TXMOEDA ,(nTotal2),SE1->(Recno()) })
			EndIf
		Next nJJ
	Next nI
	
	RestArea(aGetSE1Rus)
	RestArea(aGetSC9Rus)
	If !lPedidos
		RestArea(aGetSD2Rus)
	EndIf
	RestArea(__cArea)

    aAdd(aAllVarU2,{nTaxamoeda, aNFs, aTamSx3Prc, dDTSaida, aVencPre})

Return aAllVarU2


/*{Protheus.doc} RU05XFN0U3
@description
    the code block is transferred from the source mata468n, the function a468nImp(), all variables are taken from the function a468nImp()
@author oleg.ivanov
@since 20/07/2021
@version 1.0
@project MA3 - Russia
*/  
Function RU05XFN0U3(lPedidos as Logical, cRem as Character, aNFs as Array, nNFs as Numeric, aTamSx3Prc as Array, dDTSaida as Date, aAvgRus as Array)
    Local aGetSC9Rus as Array
    Local aGetSD2Rus as Array
    Local aGetSE1Rus as Array
    Local aRecPRE    as Array
    Local aRecnoSE1  as Array
    Local cCart2     as Character
    Local cCliFor2   as Character
    Local cLoja2     as Character
    Local cNatureza2 as Character
    Local cNumero2   as Character
    Local cParcela2  as Character
    Local cPrefixo2  as Character
    Local cTipo2     as Character
    Local nJJ        as Numeric
    Local nMoeda2    as Numeric
    Local nOrig      as Numeric
    Local nOrig2     as Numeric
    Local nTaxamoeda as Numeric
    Local nTotal     as Numeric
    Local nTotal2    as Numeric
    Local nVAlSaldo  as Numeric
    Local nValFim    as Numeric
    Local nValFim2   as Numeric
    Local nValTax    as Numeric
    Local nI         as Numeric
    Local __nSalFIm	as Numeric
    Local __usedBef	as Numeric
    Local aAllVarU3 as Array
    Local __nPos    as Numeric
    Local nPrtDel   as Numeric   // used for partial delivery (RUS)

    aAllVarU3 := {}
    aGetSE1Rus := SE1->(GetArea())
	aGetSC9Rus := SC9->(GetArea())
	If !lPedidos
		aGetSD2Rus := (cRem)->(GetArea())
	EndIf

	__cArea     := GetArea()
	aRecnoSE1   := FPedAdtPed( "R", {SC5->C5_NUM}, .F. ) //Get prepayments linked to item
	_aOrdAdd    := {}
	nTotal      := 0
	nOrig       := 0
	nValFim     := 0
	nValFim2    := 0
    nValTax     :=0

	For nJJ := 1 To Len((aNFs[nNFs][2]))
		If lPedidos
			DbSelectArea('SC9')
			DbGoTo(aNFs[nNFs][2][nJJ])

            if Len(aNFs[nNFs][13]) > 0 .And. (aNFs[nNFs][13][nJJ][1]) != 0 .AND. aNFs[nNFs][13][nJJ][1] != (SC9->C9_QTDLIB)
                nPrtDel := RU05XFN0S3(aNFs[nNFs][13][nJJ][1], (SC9->C9_QTDLIB), SC9->C9_PEDIDO, SC9->C9_CLIENTE, SC9->C9_ITEM, SC9->C9_PRODUTO)
            else
                nPrtDel := 1
            Endif

            nValTax := nPrtDel * RU05XFN01P(SC9->C9_PEDIDO,SC9->C9_ITEM)
            nValFim := nPrtDel * RU05XFN01U(SC9->C9_PEDIDO,SC9->C9_ITEM) + nValTax

		Else
			DBSelectArea(cRem)
			(cRem)->(DbGoTo(aNFs[nNFs][2][nJJ]))
			DbSelectArea('SC9')
			SC9->(DBSetOrder(1))	//C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO+C9_BLEST+C9_BLCRED
			SC9->(DBSeek(xFilial("SC9") + (cRem)->(D2_PEDIDO + D2_ITEMPV)))
			nValFim := (cRem)->D2_VALBRUT //Value for the actual item on loop
		EndIf
		
		nValFim2 += nValFim
		__nPos := AScan(_aOrdAdd,{|x| x[1] == SC9->C9_PEDIDO })
		If __nPos > 0
			_aOrdAdd[__nPos,2] += nValFim //add value to control
		Else
			aAdd(_aOrdAdd,{SC9->C9_PEDIDO,nValFim})
		EndIf
	Next nJJ
	
    aRecPRE := {}
	//With sales order group amount, we will try to found prepayment for each one and calculate the amounts
	For nI := 1 To Len(_aOrdAdd)
		nVAlSaldo := _aOrdAdd[nI][2]
		nOrig2 := 0
		//Prepayments for that sales order
		aRecnoSE1 := FPedAdtPed( "R", {_aOrdAdd[nI][1]}, .F. )
		For nJJ := 1 To Len(aRecnoSE1)
			DbSelectArea('SE1')
			dbGoTo(aRecnoSE1[nJJ][2])
			//Take the amount until you make up the total balance of the order
			// calculate total value   
			//Checks the total of the Order until reaching the total advance, according to the order of the FIE
			If nVAlSaldo >= aRecnoSE1[nJJ, 3]
				nTotal2 :=  Round(aRecnoSE1[nJJ][3] * Round(SE1->E1_VLCRUZ/SE1->E1_VALOR,TamSx3("E1_TXMOEDA")[2]),aTamSx3Prc[2]) // (SE1->E1_VLCRUZ/SE1->E1_VALOR) contra E1_TXMOEDA
				nOrig += aRecnoSE1[nJJ][3]
				nOrig2 := aRecnoSE1[nJJ][3]
				nVAlSaldo -= aRecnoSE1[nJJ][3]
			ElseIf nVAlSaldo > 0
				nTotal2 :=  Round(nVAlSaldo * Round(SE1->E1_VLCRUZ/SE1->E1_VALOR,TamSx3("E1_TXMOEDA")[2]), aTamSx3Prc[2]) // (SE1->E1_VLCRUZ/SE1->E1_VALOR) contra E1_TXMOEDA
				nOrig += nVAlSaldo
				nOrig2 := nVAlSaldo
				nVAlSaldo := 0
			Else
				nVAlSaldo := 0
			EndIf

			//Controle prepayment linked with others sales
			__nSalFIm := nOrig2
			__usedBef := nTotal2
			__nPos := AScan(aRecPRE,{|x| x[1] == SE1->(Recno()) })
			IF __nPos > 0
				aRecPRE[__nPos,2] += nOrig2 //add value to control
				__usedBef := aRecPRE[__nPos,3] //used before that sales order
				aRecPRE[__nPos,3] += nTotal2 //add value to control
				__nSalFIm := aRecPRE[__nPos,2] //total used in original currency
			Else
				aAdd(aRecPRE,{SE1->(Recno()),nOrig2,nTotal2})
			EndIf
			//if the header balance is equal to the write-off value, the header is reset to zero
			If SE1->E1_SALDO == __nSalFIm .and. __nPos >0
				cPrefixo2 := SE1->E1_PREFIXO
				cNumero2 := SE1->E1_NUM
				cParcela2 := SE1->E1_PARCELA
				cTipo2 := SE1->E1_TIPO
				cNatureza2 := SE1->E1_NATUREZ
				cCart2 := 'R'
				cCliFor2 := SE1->E1_CLIENTE
				nMoeda2 := 1 //Rublos
				cLoja2 := SE1->E1_LOJA//TODOLAST takes the balance in rubles and does not calculate the amount
				nTotal += xSaldoTit(cPrefixo2,cNumero2,cParcela2,cTipo2,cNatureza2,cCart2,cCliFor2,nMoeda2,,,cLoja2,,,,,) - __usedBef
				//calculated balance - used proportional in other sales
			Else
				nTotal += nTotal2
			Endif
		Next nJJ
	Next nI
	
    RestArea(aGetSE1Rus)
	RestArea(aGetSC9Rus)
	
    If !lPedidos
		RestArea(aGetSD2Rus)
	EndIf
	
    RestArea(__cArea)
	
    nTotal += (nValFim2 - nOrig) * RecMoeda(dDTSaida,SC5->C5_MOEDA)
    If SC5->C5_MOEDA != 1
	    nTaxamoeda := Round(nTotal,aTamSx3Prc[2]) / nValFim2 
    Else
        nTaxamoeda := RecMoeda(dDTSaida,SC5->C5_MOEDA)
    EndIf
	
    aAdd(aAvgRus,{aNFs[nNFS][1],aNFs[nNFS][6],aNFs[nNFS][7],nTaxamoeda}) //Average exchange rate to show at invoice selection

    aAdd(aAllVarU3,{nTaxamoeda, aNFs, nNFs, aTamSx3Prc, dDTSaida, aAvgRus})

Return aAllVarU3


/*{Protheus.doc} RU05XFN0U4
@description
    the code block is transferred from the source mata468n, the function a468nImp(), all variables are taken from the function a468nImp()
@author oleg.ivanov
@since 20/07/2021
@version 1.0
@project MA3 - Russia
*/ 
Function RU05XFN0U4(aNFs as Array, nNFs as Numeric, aTamSx3Prc as Array, dDTSaida as Date, aAvgRus as Array)
    Local aGetSC9Rus as Array
    Local aGetSE1Rus as Array
    Local aRecPRE    as Array
    Local aRecnoSE1  as Array
    Local cCart2     as Character
    Local cCliFor2   as Character
    Local cLoja2     as Character
    Local cNatureza2 as Character
    Local cNumero2   as Character
    Local cParcela2  as Character
    Local cPrefixo2  as Character
    Local cTipo2     as Character
    Local nJJ        as Numeric
    Local nMoeda2    as Numeric
    Local nOrig      as Numeric
    Local nOrig2     as Numeric
    Local nTaxamoeda as Numeric
    Local nTotal     as Numeric
    Local nTotal2    as Numeric
    Local nVAlSaldo  as Numeric
    Local nValTax    as Numeric
    Local nValFim    as Numeric
    Local nValFim2   as Numeric
    Local nI         as Numeric
    Local __nSalFIm		as Numeric
    Local __usedBef		as Numeric
    Local aAllVarU4 as Array
    Local __nPos as Numeric

    aGetSE1Rus  := SE1->(GetArea())
	aGetSC9Rus  := SC9->(GetArea())
	__cArea     := GetArea()
	aRecnoSE1   := FPedAdtPed( "R", {SC5->C5_NUM}, .F. ) //Get prepayments linked to item
	_aOrdAdd    := {}
	nTotal      := 0
	nOrig       := 0
	nValFim     := 0
	nValFim2    := 0
    nValTax     :=0
    aAllVarU4   := {}

	For nJJ := 1 To Len((aNFs[nNFs][2]))
		DbSelectArea('SC9')
		DbGoTo(aNFs[nNFs][2][nJJ])	//Recno SC9

        if Len(aNFs[nNFs][13]) > 0 .And. (aNFs[nNFs][13][nJJ][1]) != 0 .AND. aNFs[nNFs][13][nJJ][1] != (SC9->C9_QTDLIB)
            nPrtDel := RU05XFN0S3(aNFs[nNFs][13][nJJ][1], (SC9->C9_QTDLIB), SC9->C9_PEDIDO, SC9->C9_CLIENTE, SC9->C9_ITEM, SC9->C9_PRODUTO)
        else
            nPrtDel := 1
        Endif

        nValTax := nPrtDel * RU05XFN01P(SC9->C9_PEDIDO,SC9->C9_ITEM)
        nValFim := nPrtDel * RU05XFN01U(SC9->C9_PEDIDO,SC9->C9_ITEM) + nValTax
		nValFim2 += nValFim
        
		__nPos := AScan(_aOrdAdd,{|x| x[1] == SC9->C9_PEDIDO })
		If __nPos > 0
			_aOrdAdd[__nPos,2] += nValFim //add value to control
		Else
			aAdd(_aOrdAdd,{SC9->C9_PEDIDO,nValFim})
		EndIf
	Next nJJ
	
     aRecPRE := {}
	//With sales order group amount, we will try to found prepayment for each one and calculate the amounts
	For nI := 1 To Len(_aOrdAdd)
		nVAlSaldo := _aOrdAdd[nI][2]
		nOrig2 := 0
		//Prepayments for that sales order
		aRecnoSE1 := FPedAdtPed( "R", {_aOrdAdd[nI][1]}, .F. )
		For nJJ := 1 To Len(aRecnoSE1)
			DbSelectArea('SE1')
			dbGoTo(aRecnoSE1[nJJ][2])
			//Take the amount until you make up the total balance of the order
			// calculate total value   
			//Checks the total of the Order until reaching the total advance, according to the order of the FIE
			If nVAlSaldo >= aRecnoSE1[nJJ, 3]
				nTotal2 :=  Round(aRecnoSE1[nJJ][3] * Round(SE1->E1_VLCRUZ/SE1->E1_VALOR,TamSx3("E1_TXMOEDA")[2]),aTamSx3Prc[2]) // (SE1->E1_VLCRUZ/SE1->E1_VALOR) contra E1_TXMOEDA
				nOrig += aRecnoSE1[nJJ][3]
				nOrig2 := aRecnoSE1[nJJ][3]
				nVAlSaldo -= aRecnoSE1[nJJ][3]
			ElseIf nVAlSaldo > 0
				nTotal2 :=  Round(nVAlSaldo * Round(SE1->E1_VLCRUZ/SE1->E1_VALOR,TamSx3("E1_TXMOEDA")[2]), aTamSx3Prc[2]) // (SE1->E1_VLCRUZ/SE1->E1_VALOR) contra E1_TXMOEDA
				nOrig += nVAlSaldo
				nOrig2 := nVAlSaldo
				nVAlSaldo := 0
			Else
				nVAlSaldo := 0
			EndIf

			//Controle prepayment linked with others sales
			__nSalFIm := nOrig2
			__usedBef := nTotal2
			__nPos := AScan(aRecPRE,{|x| x[1] == SE1->(Recno()) })
			IF __nPos > 0
				aRecPRE[__nPos,2] += nOrig2 //add value to control
				__usedBef := aRecPRE[__nPos,3] //used before that sales order
				aRecPRE[__nPos,3] += nTotal2 //add value to control
				__nSalFIm := aRecPRE[__nPos,2] //total used in original currency
			Else
				aAdd(aRecPRE,{SE1->(Recno()),nOrig2,nTotal2})
			EndIf
			//if the header balance is equal to the write-off value, the header is reset to zero
			If SE1->E1_SALDO == __nSalFIm .and. __nPos >0
				cPrefixo2 := SE1->E1_PREFIXO
				cNumero2 := SE1->E1_NUM
				cParcela2 := SE1->E1_PARCELA
				cTipo2 := SE1->E1_TIPO
				cNatureza2 := SE1->E1_NATUREZ
				cCart2 := 'R'
				cCliFor2 := SE1->E1_CLIENTE
				nMoeda2 := 1 //Rublos
				cLoja2 := SE1->E1_LOJA
				nTotal += xSaldoTit(cPrefixo2,cNumero2,cParcela2,cTipo2,cNatureza2,cCart2,cCliFor2,nMoeda2,,,cLoja2,,,,,) - __usedBef
				//calculated balance - used proportional in other sales
			Else
				nTotal += nTotal2
			Endif
		Next nJJ
	Next nI
	
    RestArea(aGetSE1Rus)
	RestArea(aGetSC9Rus)
	RestArea(__cArea)
	
    nTotal += (nValFim2 - nOrig) * RecMoeda(dDTSaida,SC5->C5_MOEDA)
	If SC5->C5_MOEDA != 1
	    nTaxamoeda := Round(nTotal,aTamSx3Prc[2]) / nValFim2 
    Else
        nTaxamoeda := RecMoeda(dDTSaida,SC5->C5_MOEDA)
    EndIf
	
    aAdd(aAvgRus,{aNFs[nNFS][1],aNFs[nNFS][6],aNFs[nNFS][7],nTaxamoeda}) //Average exchange rate to show at invoice selection

    //retur all variables
    aAdd(aAllVarU4,{nTaxamoeda, aNFs, nNFs, aTamSx3Prc, dDTSaida, aAvgRus})

Return aAllVarU4


/*{Protheus.doc} RU05XFN0U5_CondicaoRus
@description
    redesigned Condicao function for Russia
@author A.Velmoznaya/Oleg.Ivanov
@since 12/08/2021
@version 1.0
@project MA3 - Russia
*/
Function RU05XFN0U5_CondicaoRus(nValTot,cCond,nValIpi,dData0,nValSolid,aImpVar,aE4,nAcrescimo,nInicio3,aDias3,aPrep)
    local aRet as Array
    Local aCondTmp as Array
    Local nX as Numeric

    Default nValIpi   := 0
    Default nValSolid := 0
    Default aPrep := {}

    aRet := {}

    //At first add advances
    If Len(aPrep) > 0 
        For nX:= 1 To Len(aPrep)
            nValTot -= aPrep[nX][2]
        Next nX
        aRet := AClone(aPrep)
    Else
        aRet := {}
    EndIf
    
    aCondTmp := Condicao(nValTot,cCond,nValIpi,dData0,nValSolid,aImpVar,aE4,nAcrescimo,nInicio3,aDias3)
    
    For nX := 1 to Len(aCondTmp)
        aAdd(aRet, aCondTmp[nX])
    Next nX

Return aRet


/*{Protheus.doc} RU05XFN00V
@description
    We will open a FINA050 in visualization mode when viewing the document in the prepayment selection window
@author oleg.ivanov
@since 26/07/2021
@version 1.0
@project MA3 - Russia
*/
Function RU05XFN00V(cLoja as Character, lRu05XFNY as Logical, aArrayData as Array)
    Local aArea		:= GetArea()
    Local aAreaSE2	:= Eval({||DbSelectArea("SE2"),SE2->(GetArea())})
    Local lViewValid as Logical

    Default lRu05XFNY := .F.
    Default aArrayData := Nil

    lViewValid := .F.

    SE2->(DbSetOrder(1))
    
    If IIF(!lRu05XFNY, SE2->(MSSeek(xFilial("SE2")+PADR(TRBADT->PREFIXO,GetSX3Cache("E2_PREFIXO","X3_TAMANHO")," ")+PADR(TRBADT->TITULO,GetSX3Cache("E2_NUM","X3_TAMANHO")," ")+PADR(TRBADT->PARCELA,GetSX3Cache("E2_PARCELA","X3_TAMANHO")," ")+PADR(TRBADT->TIPO,GetSX3Cache("E2_TIPO","X3_TAMANHO")," ")+PADR(TRBADT->CLIFOR,GetSX3Cache("E2_FORNECE","X3_TAMANHO")," ")+PADR(cLoja,GetSX3Cache("E2_LOJA","X3_TAMANHO")," "),.T.)), ;
                       SE2->(MsSeek(xFilial("SE2")+aArrayData[1]+aArrayData[2]+aArrayData[3]+aArrayData[4],.T.)))
        DBSelectArea("SA2")
        If DBSeek(xFilial("SA2")+SE2->E2_FORNECE+cLoja)
            AxVisual('SE2',SE2->(RecNo()),2,,4,SA2->A2_NOME,"FA050MCPOS",fa050BAR('SE2->E2_PROJPMS == "1"')   )
            lViewValid := .T.
        EndIf
    EndIf
    RestArea(aAreaSE2)
    RestArea(aArea)
Return lViewValid


/*{Protheus.doc} RU05XFN00W
@description
    option to user track the accounting track for Prepayment window in mata101n
@author oleg.ivanov
@since 27/07/2021
@version 1.0
@project MA3 - Russia
*/
Function RU05XFN00W(aArrayData as Array, lValidFnct as Logical)
    Local aArea		:= GetArea()
    Local aAreaSE2	:= Eval({||DbSelectArea("SE2"),SE2->(GetArea())})

    Default aArrayData := Nil
    Default lValidFnct := .F.

    SE2->(DbSetOrder(1))

    If IIF(!lValidFnct, SE2->(MSSeek(xFilial("SE2")+PADR(TRBADT->PREFIXO,GetSX3Cache("E2_PREFIXO","X3_TAMANHO")," ")+PADR(TRBADT->TITULO,GetSX3Cache("E2_NUM","X3_TAMANHO")," ")+PADR(TRBADT->PARCELA,GetSX3Cache("E2_PARCELA","X3_TAMANHO")," ")+PADR(TRBADT->TIPO,GetSX3Cache("E2_TIPO","X3_TAMANHO")," ")+PADR(TRBADT->CLIFOR,GetSX3Cache("E2_FORNECE","X3_TAMANHO")," ")+PADR(Substr(TRBADT->CLIFOR,GetSX3Cache("E2_FORNECE","X3_TAMANHO")+2),GetSx3Cache("E2_LOJA", "X3_TAMANHO"), " "),.T.)), ;
                        SE2->(MsSeek(xFilial("SE2")+aArrayData[1]+aArrayData[2]+aArrayData[3]+aArrayData[4],.T.)))
        CTBC662("SE2", SE2->(Recno()))
    EndIf

    RestArea(aAreaSE2)
    RestArea(aArea)

Return .T.


/*{Protheus.doc} RU05XFN00X
@description
    The button function in RU05XFN00C. sends data to the corresponding functions, 
    according to the buttons pressed on the form for viewing prepayments for mata101n
@param cTab     Character Alias to temporary table
@param cCliFor  Character Client or Fornece Cod
@param cLoja    Character Client or Fornece Branch
@param aNaTObj  Array     Array of row data selcted in grid of advances
@param nIndex   Numeric   nIndex := 1 "Print", nIndex := 2 "View", nIndex := 3 "Acc. tracker"
@author oleg.ivanov
@edit astepanov
@since 02/08/2021
@version 1.0
@project MA3 - Russia
*/
Function RU05XFN00X(cTab, cCliFor, cLoja, aNaTObj as Array, nIndex as Numeric)
    Local aArea as Array
    Local aStrcTab as Array
    Local aStrFR3 as Array
    Local nX as Numeric

    aArea := GetArea()
    
    Do Case
        Case nIndex == 1
            aStrcTab := {}
            aStrFR3 := (cTab)->(DbStruct())
                For nX := 1 To Len(aStrFR3)
                    If aStrFR3[nX][1] $ "|FR3_PREFIX|FR3_NUM|FR3_PARCEL|FR3_TIPO|F2_MOEDA|CTO_SIMB|A1_COD|A1_NOME|FR3_VALOR|F2_TXMOEDA|F2_VLBRUTM|" 
                        AAdd(aStrcTab, aStrFR3[nX])
                    EndIf
                Next nX
            RUPrepPrnt(cTab, aStrcTab)
        Case nIndex == 2
            RU05XFN00Y(aNaTObj, cCliFor, cLoja)
        Case nIndex == 3
            RU05XFN00W(aNaTObj, .T.)
    EndCase

    RestArea(aArea)

Return Nil


/*{Protheus.doc} RU05XFN00Y
@description
    the option opens the document for viewing for the prepayment window in mata101n/mata467n
@author oleg.ivanov
@param aNaTObj Array Array of Row data in Grid
@param cCliFor Character Client or Fornece Cod
@param cLoja   Character Client or Fornece branch
@since 02/08/2021
@edit astepanov
@version 1.0
@project MA3 - Russia
*/
Function RU05XFN00Y(aNaTObj, cCliFor, cLoja)
    Local aArea as Array
    Local cQuery as Character
    Local cQueryULCD as Character
    Local lValidDoc as Logical
    Local lChecOpnDc as Logical
    Local aArrayData as Array
    Local lRu05XFNY as Logical
    Local nLenF5mKey as Numeric
    Local cAlias as Character
    Local aF4CArea as Array
    Local aSE_Area as Array
    Local aTmpArea as Array
    Local cSE_Alias as Character
    Local cSeekKeyO1 as Character

    aArea := GetArea()
    cQuery := ''
    cQueryULCD := ''
    aArrayData := aNaTObj
    lRu05XFNY := .T.
    lValidDoc := .T.
    lChecOpnDc := .T.   //Checking for opening a document in mata101n/mata467n
    cSE_Alias  := ""
    If AllTrim(aArrayData[4]) $ MVPAGANT
        cSE_Alias  := "SE2"
        cSeekKeyO1 := xFilial(cSE_Alias)+aArrayData[1]+aArrayData[2]+aArrayData[3]+aArrayData[4]+cCliFor+cLoja //unique key for SE2
    ElseIf AllTrim(aArrayData[4]) $ MVRECANT
        cSE_Alias  := "SE1"
        cSeekKeyO1 := xFilial(cSE_Alias)+aArrayData[1]+aArrayData[2]+aArrayData[3]+aArrayData[4] //unique key for SE1
    EndIf
    aSE_Area := (cSE_Alias)->(GetArea())
    (cSE_Alias)->(DBSetOrder(1))
    If !Empty(cSE_Alias) .AND. (cSE_Alias)->(MsSeek(cSeekKeyO1,.T.))
        cF5MKey    := xFilial(cSE_Alias)+"|"+aArrayData[1] + "|" + aArrayData[2] + "|" + aArrayData[3] + "|" + aArrayData[4] + "|" + cCliFor + "|" + cLoja
        nLenF5mKey := Len(cF5MKey)
        cQuery +=   "SELECT F5M_FILIAL,F5M_KEY,F5M_KEYALI,F5M_ALIAS,F5M_IDDOC "
        cQuery +=   "FROM " + RetSqlName("F5M") + " F5M "
        cQuery +=   "WHERE F5M.F5M_FILIAL = '"+xFilial("F5M")+"' "
        cQuery +=   "  AND F5M.F5M_KEYALI = '"+cSE_Alias+"'      "
        cQuery +=   "  AND TRIM(SUBSTRING(F5M.F5M_KEY,1,"+cValToChar(nLenF5mKey)+")) = '"+cF5MKey+"'"
        cQuery +=   "  AND F5M.D_E_L_E_T_ = ' ' "
        cQuery := ChangeQuery(cQuery)
        cAlias := MPSysOpenQuery(cQuery)
        Do Case
            Case aArrayData[4] != "NCC" .And. lChecOpnDc
                (cAlias)->(DbGoTop())
                If (cAlias)->(!Eof())
                    If (cAlias)->F5M_ALIAS == "F4C"
                        aTmpArea := GetArea()
                        DBSelectArea("F4C")
                        aF4CArea := F4C->(GetArea())
                        F4C->(DBSetOrder(5)) // F4C_FILIAL+F4C_CUUID
                        If F4C->(MSSeek(xFilial("F4C")+(cAlias)->F5M_IDDOC))
                            FWExecView("","RU06D07",MODEL_OPERATION_VIEW,,{|| .T.})
                            lChecOpnDc := .F.
                            lValidDoc := .F.
                        EndIf
                        RestArea(aF4CArea)
                        RestArea(aTmpArea)
                    EndIf
                EndIf
            Case aArrayData[4] == "NCC" .And. lChecOpnDc
                cQueryULCD += "SELECT DISTINCT E1.E1_PREFIXO, ulcd.* "
                cQueryULCD += "FROM " + RetSqlName("SE1") + " E1 " 
                cQueryULCD += "LEFT JOIN (SELECT F5Y.F5Y_FILIAL, F1.F1_DOC, F5Y.F5Y_CLIENT, F5Y.F5Y_BRANCH, F1.F1_ESPECIE, F5Y.R_E_C_N_O_ RECNO "
                cQueryULCD += "             FROM " + RetSqlName("SF1") + " F1 " 
                cQueryULCD += "             LEFT JOIN " + RetSqlName("F5Y") + " F5Y " 
                cQueryULCD += "             ON  F5Y.F5Y_DOCCRD = F1.F1_DOC AND "
                cQueryULCD += "                 F5Y.F5Y_SERCRD = F1.F1_SERIE AND "
                cQueryULCD += "                 F5Y.F5Y_CLIENT = F1.F1_FORNECE AND "
                cQueryULCD += "                 F5Y.F5Y_BRANCH = F1.F1_LOJA "
                cQueryULCD += "             WHERE "
                cQueryULCD += "                 F5Y.F5Y_DOCCRD = F1.F1_DOC AND "
                cQueryULCD += "                 F5Y.F5Y_SERCRD = F1.F1_SERIE AND "
                cQueryULCD += "                 F5Y.F5Y_CLIENT = F1.F1_FORNECE AND "
                cQueryULCD += "                 F5Y.F5Y_BRANCH = F1.F1_LOJA AND "
                cQueryULCD += "                 F5Y.D_E_L_E_T_ = ' ' AND "
             	cQueryULCD += "                 F1.D_E_L_E_T_  = ' ' "
                cQueryULCD += "            ) ulcd "
                cQueryULCD += "ON  E1.E1_FILIAL = ulcd.F5Y_FILIAL AND "
                cQueryULCD += "    E1.E1_NUM = ulcd.F1_DOC AND "
                cQueryULCD += "    E1.E1_CLIENTE = ulcd.F5Y_CLIENT "
                cQueryULCD += "WHERE "
                cQueryULCD += "    E1.E1_FILIAL = ulcd.F5Y_FILIAL AND "
                cQueryULCD += "    E1.E1_NUM = ulcd.F1_DOC AND "
                cQueryULCD += "    E1.E1_CLIENTE = ulcd.F5Y_CLIENT AND "
                cQueryULCD += "    E1.E1_LOJA = ulcd.F5Y_BRANCH AND "
                cQueryULCD += "    E1.E1_TIPO = ulcd.F1_ESPECIE AND "
                cQueryULCD += "    E1.D_E_L_E_T_ = ' ' "
                cQueryULCD += "ORDER BY ulcd.RECNO"

                cQueryULCD := ChangeQuery(cQueryULCD)

                If SELECT("TMPULCD") > 0
                    TMPULCD->(DbCloseArea())
                EndIf

                dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQueryULCD), "TMPULCD", .T., .F.)
                dbSelectArea("TMPULCD")
                TMPULCD->(DbGoTop())

                While (TMPULCD->(!Eof()))
                    If  AllTrim(TMPULCD->F5Y_FILIAL) == xFilial("SE1") .And. ;
                        aArrayData[1] == AllTrim(TMPULCD->E1_PREFIXO) .And.;
                        aArrayData[2] == AllTrim(TMPULCD->F1_DOC) .And. ;
                        AllTrim(cLoja) == AllTrim(TMPULCD->F5Y_BRANCH)
                            DBSelectArea("F5Y")
                            DBGoTo(TMPULCD->RECNO)
                            FWExecView("","RU05D01",MODEL_OPERATION_VIEW,,{|| .T.})

                            lChecOpnDc := .F.
                            lValidDoc := .F.

                            Exit
                    EndIf
                    dbSkip()
                EndDo
                TMPULCD->(DbCloseArea())
        EndCase
        
        If lChecOpnDc
            If     cSE_Alias == "SE2"
                lValidDoc := .NOT. RU05XFN00V(cLoja, lRu05XFNY, aArrayData)
            ElseIf cSE_Alias == "SE1"
                lValidDoc := .NOT. VwARFIN040(xFilial(cSE_Alias),aArrayData[1],aArrayData[2],aArrayData[3],aArrayData[4])
            EndIf
            lChecOpnDc := lValidDoc
        EndIf
    EndIf

    If lValidDoc
        Help("",1,STR0082,,STR0094,1,0) 
    EndIf

    If !Empty(cAlias)
        (cAlias)->(DBCloseArea())
    EndIf
    RestArea(aSE_Area)
    RestArea(aArea)

Return .T.

/*/{Protheus.doc} RU05XFN00Z
    Update local variables in FPDxADTREL in FINXAPI.PRX
    @type  Function
    @author astepanov
    @since 09/10/2022
    @version version
    @param aAddRus, Array, Array with Legal contract information
    @param cPrefix, Character, "E1" or "E2" prefix for SE1 or SE2 table
    @param cSETable, Character, "SE1" or "SE2", SE_ table name
    @param cCarteira, Character , "R" or "P" don't cahnge this parameter
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
Function RU05XFN00Z(aAddRus,cPrefix,cSETable,cCarteira,lValrelat)
   	aAddRus := RU99XFUN0A(aAddRus)
    If cCarteira == "R"
        cPrefix  := "E1"
        cSETable := "SE1"
    Else
        cPrefix  := "E2"
        cSETable := "SE2"
    EndIf 
    lValrelat :=.F. // In the future if it is needed check the posssibility to insert a parameter or pergunte if needed to show the colluns values related task https://jiraproducao.totvs.com.br/browse/RULOC-4487\    
Return Nil

/*/{Protheus.doc} RU05XFN01A
    For changing New Exchange rate and total value in local currency
    when we select PA or RA lines for invoice
    @type  Function
    @author astepanov
    @since 12/10/2022
    @version version
    @param nNewExRat, Numeric, New Average Exchange Rate
    @param nTotValRub, Numeric New Total VAlue in Local Currency
    @param cAlias, Character, TRBADT
    @param nSelec, Numeric, Selected value
    @param nValLimite, Numeric, Allowed value
    @param nStandExcR, Numeric, Standard Exchange rate
    @param cCarteira,  Character "P" or "R"
    @param 
    @return Nil
    (examples)
    @see (links_or_references)
    /*/
Function RU05XFN01A(nNewExRat,nTotValRub,cAlias,nSelec,nValLimite,nStandExcR,cCarteira)
    Local aNewValRet As Array
    Default cCarteira := Nil
    aNewValRet := RU05XFN00J(cAlias,nSelec,nValLimite,nStandExcR,cCarteira)
    nNewExRat  := aNewValRet[1]
    nTotValRub := aNewValRet[2]
Return Nil

/*/{Protheus.doc} RU05XFN01B
    nValor must be less or equal ValLimite - nSelec
    This function called from Static Function FPedAdtTrc in FINXAPI
    @type  Function
    @author astepanov
    @since 17/10/2022
    @version version
    @param nValor, Numeric, AP or AR Value which we can use, can be changed
    @param nSaldo, Numeric, maximum AP or AR Value which we can use, can be changed
    @param nValLimite, Numeric, Total limit
    @param nSelec, Numeric, Already used part of total limit
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
Function RU05XFN01B(nValor,nSaldo,nValLimite,nSelec)
    Local lRet  As Logical
    lRet := .T.
    If nValor > (nValLimite - nSelec)
        nValor := nValLimite - nSelec
        nSaldo := nValor
    EndIf
Return lRet

/*/{Protheus.doc} RU05XFN01C_CreateaDuplRus
    This function Creates aDulpRus for RU05XFN01G_GeneraDuplRus
    @type  Function
    @author astepanov
    @since 17/10/2022
    @version version
    @param nValmerc, Numeric, F1_VALMERC or F2_VALMERC of invoice
    @param nVlbrutm, Numeric, F1_VLBRUTM or F2_VLBRUTM of invoice
    @param nBasimp1, Numeric, F1_BASIMP1 or F2_BASIMP1 of invoice
    @param aVencPreRu, Array, Array of advdnces generated by RU05XFN00A
    @param dDEmissao, Date, date of Emissao
    @param cCondicao, Character, Condition used by Condicao
    @return aRet, Array, {aDuplMCur,aDuplTB}
    @example
    (examples)
    @see (links_or_references)
    /*/
Function RU05XFN01C_CreateaDuplRus(nValmerc, nVlbrutm, nBasimp1, aVencPreRu, dDEmissao,cCondicao)
    Local aPreBrutM  As Array
    Local aPreBase   As Array
    Local aRet       As Array

    aPreBrutM := IIF(!Empty(aVencPreRu),aVencPreRu[3],{})
    aDuplMCur := RU05XFN0U5_CondicaoRus(nVlbrutm,cCondicao,,dDEmissao,,,,,,,aPreBrutM)
    aPreBase  := IIF(!Empty(aVencPreRu),aVencPreRu[4],{})
    aDuplTB   := RU05XFN0U5_CondicaoRus(nBasimp1,cCondicao,,dDEmissao,,,,,,,aPreBase)
    aRet      := {aDuplMCur,aDuplTB}
Return aRet

/*/{Protheus.doc} RU05XFN01D_aRecnoSE_to_aVencAdvnc
    This function used by LxA103Dupl for aVenc generating from aRecnoSE1
    @type  Function
    @author user
    @since 31/10/2022
    @version version
    @param aRecnoSE_, Array, Array of SE1 or SE2 recnos
    @param dDEmissao, Date
    @return aVencAdvnc, Array,
    @example
    (examples)
    @see (links_or_references)
    /*/
Function RU05XFN01D_aRecnoSE_to_aVencAdvnc(aRecnoSE_,dDEmissao)
    Local aVencAdvnc As Array
    Local nLen       As Numeric
    Local nX         As Numeric
    aVencAdvnc := {}
    nLen := IIF(!Empty(aRecnoSE_),Len(aRecnoSE_),0)
    For nX := 1 To nLen
        AADD(aVencAdvnc,{dDEmissao,aRecnoSE_[nX][3]})
    Next nX
Return aVencAdvnc

/*/{Protheus.doc} RU05XFN01E_GetSaldo
    (long_description)
    @type  Function
    @author user
    @since 31/10/2022
    @version version
    @param cTab, Caharacter, "SE2" or "SE1"
    @param nRecno, Numeric, record position on SE1 or SE1
    @param dSaldoDate, Date, date of balance
    @param nMoeda, Numeric, In which currency we get saldo?
    @return nSaldo, Numeric, Balance on dSaldoDate in nMoeda currency
    @example
    (examples)
    @see (links_or_references)
    /*/
Function RU05XFN01E_GetSaldo(cTab,nRecno,dSaldoDate,nMoeda)
    Local nSaldo     As Numeric
    Local cPr        As Character
    Local cCart      As Character
    Local cCliFor    As Character
    Local cLoja      As Character
    Local nCurrRec   As Numeric
    Local aArea      As Array
    aArea := GetArea()
    nSaldo := 0
    nCurrRec := (cTab)->(Recno())
    (cTab)->(DBGoto(nRecno))
    If     cTab == "SE1"
        cPr     := "E1_"
        cCart   := "R"
        cCliFor := (cTab)->&("E1_CLIENTE")
        cLoja   := (cTab)->&("E1_LOJA")
    ElseIf cTab == "SE2"
        cPr     := "E2_"
        cCart   := "P"
        cCliFor := (cTab)->&("E2_FORNECE")
        cLoja   := (cTab)->&("E2_LOJA")
    EndIf
    nSaldo := SaldoTit((cTab)->&(cPr+"PREFIXO"),(cTab)->&(cPr+"NUM"),(cTab)->&(cPr+"PARCELA"),(cTab)->&(cPr+"TIPO"),(cTab)->&(cPr+"NATUREZ"),cCart,cCliFor,nMoeda,Nil,dSaldoDate,cLoja,Nil,Nil,Nil,Nil,Nil,Nil,Nil)
    (cTab)->(DBGoto(nCurrRec))
    RestArea(aArea)
Return nSaldo

/*/{Protheus.doc} RU05XFN01F_PostRelatedAdvances
    This code removed from LocxNF
    We use it for posting  SE1 or SE2 records which compensates related advances
    in function GravaFina
    @type  Function
    @author astepanov
    @since 26/10/2022
    @version version
    @param aRelAdv, Array, Array of related advances filled in GravaSE1 or GravaSE2
    @param cAliasFin, Character, "SE1" or "SE2"
    @param aRecnoAdv, Array, Array of recnos used advaces for compensation
    @return lRet, Logical, .T. or .F.
    @example
    (examples)
    @see (links_or_references)
    /*/
Function RU05XFN01F_PostRelatedAdvances(aRelAdv,cAliasFin,aRecnoAdv)
    Local lRet        As Logical
    Local aArea       As Array
    Local aAreaSE_    As Array
    Local aTxMoeda    As Array
    Local lOnlineAcc  As Logical
    Local lShowAcc    As Logical
    Local lDonGrvFR3  As Logical
    Local nLenRecnoA  As Numeric
    Local nX          As Numeric
    Local nLenArelAd  As Numeric
    Local nTaxaCM     As Numeric

    lRet := .T.
    aArea := GetArea()
    aMVParamet  := GetSaveMVP(Nil,14)
    nLenRecnoA := IIF(!Empty(aRecnoAdv),Len(aRecnoAdv),0)
    nLenArelAd := IIF(!Empty(aRelAdv)  ,Len(aRelAdv)  ,0)
    If cAliasFin == "SE1"
        Pergunte("FIN330",.F.)
        lOnlineAcc := MV_PAR09
        lShowAcc   := MV_PAR07
        DBSelectArea("SE1")
        aAreaSE_ := SE1->(GetArea())
        nX := 1
        While lRet .AND. nX <= nLenRecnoA .AND. nX <= nLenArelAd
            SE1->(DbGoTo(aRelAdv[nX][2]))
            aTxMoeda := {{SE1->E1_MOEDA,SE1->E1_TXMOEDA}}
            nTaxaCM  := aTxMoeda[1][2]
            lRet := MaIntBxCR(3,{aRelAdv[nX][1]},,{aRelAdv[nX][2]},,{lOnlineAcc,.F./*lAglutina*/,lShowAcc,.F.,.F.,.F.},,,,,SE1->E1_SALDO,,{aRelAdv[nX][3]},,nTaxaCM,aTxMoeda)
            SE1->(DbGoTo(aRelAdv[nX][2]))
            If lRet
                lDonGrvFR3 := FaGrvFR3("R","",SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,SE1->E1_CLIENTE,SE1->E1_LOJA,aRecnoSE1[nX][3],SF2->F2_DOC,SF2->F2_SERIE)
                lRet := IIF(ValType(lDonGrvFR3) == "L", lDonGrvFR3, lRet)
            EndIf
            nX := nX + 1
        EndDo
        RestArea(aAreaSE_)
    Else //cAliasFin == "SE2"
        Pergunte("AFI340",.F.)
        DBSelectArea("SE2")
        aAreaSE_ := SE2->(GetArea())
        nX := 1
        While lRet .AND. nX <= nLenRecnoA .AND. nX <= nLenArelAd
            LoteCont("FIN")
            SE2->(DbGoTo(aRelAdv[nX][2]))
            lRet := FinCmpAut({aRelAdv[nX,1]}, {aRelAdv[nX,2]},;
                            {(mv_par11==1) /*lContabil */,(mv_par08==1)/*lAgluCtb */, (mv_par09==1)/*lDigita */} /*aParam*/,;
                            /*bBlock*/, /*aEstorno*/, aRelAdv[nX,3] /*nSldComp*/, /*dDatabase*/,;
                            /*nTaxaPA*/ ,/*nTaxaNF*/, /*nHdl*/, /*nOperacao*/, /*aRecSE5*/)
            SE2->(DbGoTo(aRelAdv[nX][2]))
            If lRet
               lDonGrvFR3 := FaGrvFR3("P","",SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,SE2->E2_TIPO,SE2->E2_FORNECE,SE2->E2_LOJA,aRelAdv[nX,3],SF1->F1_DOC,SF1->F1_SERIE)
               lRet := IIF(ValType(lDonGrvFR3) == "L", lDonGrvFR3, lRet)
            EndIf
            nX := nX + 1
        Enddo
        RestArea(aAreaSE_)
    EndIf
    GetSaveMVP(aMVParamet)
    If nLenArelAd > 0
        aRelAdv := {} //clear aRelAdv
    EndIf
    RestArea(aArea)

Return lRet

Static Function GetSaveMVP(aMVParam,nCountPar)
    Local nX         As Numeric
    Default aMVParam := Nil
    Default nCountPar := IIF(!Empty(aMVParam),Len(aMVParam),14)
    If aMVParam == NIL
        //Return array of MV parameters
        aMVParam := {}
        For nX := 1 to nCountPar
            AAdd(aMVParam, &("MV_PAR" + StrZero(nX, 2)))
        Next nX
    Else
        //Restore MV parameters from an array
        For nX := 1 To nCountPar
            &("MV_PAR" + StrZero(nX, 2)) := aMVParam[nX]
        Next nX
    EndIf
Return aMVParam

/*/{Protheus.doc} RU05XFN01G_GeneraDuplRus
    This function generates aDuplRus which used for generating APs or ARs by
    GravaSE1 or GravaSe2 in LocxNF
    @type  Function
    @author astepanov
    @since 26/10/2022
    @version version
    @param aDuplRus, Array, Emty array {} which we must change
    @param aRecnoSE1, Array with information about used advances for compensation generated by FPDxADTREL in FINXAPI
    @param cCondicao, Character, Condition used by Condicao
    @param aCfgNf, Array, Array with information about current NF document
    @param SAliasHead, Numeric, Alias info position in aCfgNf
    @param dDEmissao , Date, Date of emissao
    @return lRet, Logical, .T. or .F.
    @example
    (examples)
    @see (links_or_references)
    /*/
Function RU05XFN01G_GeneraDuplRus(aDuplRus,aRecnoSE1,cCondicao,aCfgNf,SAliasHead,dDEmissao)
    Local lRet       As Logical
    Local aVencPreRu As Array
    Default aDuplRus := {}
    lRet := .T.
    If !Empty(aRecnoSE1) .AND. A410UsaAdi(cCondicao)
        aVencPreRu := RU05XFN00A(&(aCfgNf[SAliasHead]+"->"+Substr(aCfgNf[SAliasHead],2,2)+"_VALBRUT"),&(aCfgNf[SAliasHead]+"->"+Substr(aCfgNf[SAliasHead],2,2)+"_VLBRUTM"),&(aCfgNf[SAliasHead]+"->"+Substr(aCfgNf[SAliasHead],2,2)+"_BASIMP1"),aRecnoSE1,dDEmissao)
		lRet := aVencPreRu[1]
	EndIf
	If lRet
		aDuplRus := RU05XFN01C_CreateaDuplRus(&(aCfgNf[SAliasHead]+"->"+Substr(aCfgNf[SAliasHead],2,2)+"_VALBRUT"),&(aCfgNf[SAliasHead]+"->"+Substr(aCfgNf[SAliasHead],2,2)+"_VLBRUTM"),&(aCfgNf[SAliasHead]+"->"+Substr(aCfgNf[SAliasHead],2,2)+"_BASIMP1"),aVencPreRu,dDEmissao,cCondicao)
	EndIf
Return lRet

/*/{Protheus.doc} CalcAvgExR
    (long_description)
    @type  Static Function
    @author astepanov
    @since 24/10/2022
    @version version
    @param nTotalMoe1, Numeric, Value in currency 1
    @param nTotalOrig, Numeric, Value in other currency
    @param nRound, Numeric, Rounding accuracy
    @return nRet, Numeric, Average echange rate
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function CalcAvgExR(nTotalMoe1,nTotalOrig,nRound)
    Local nRet       As Numeric
    nRet := Round(nTotalMoe1/nTotalOrig,nRound)
Return nRet

/*/{Protheus.doc} RU05XFN01H_LockSelectedAdvances
    Lock selected advances when we select them for invoice,
    We need locking for correct balance calculations
    @type  Function
    @author astepanov
    @since 01/11/2022
    @version version
    @param aLkdAdvRUS, Array, {[1] - Alias, [2] - Recno, [3] - 0 (Locked), -1(Was not locked)}, Can be empty
    @param cAliasSE_, Character, Alias to temporary table
    @param cTab, Character, Alias to real table in database
    @param cRecNoName, Caharcter, R_E_C_N_O_ field name in cAliasSE_
    @param lLocked   , Logical  , Allows to inform previows if the records will be locked Default False
    @return lRet, Logical, .T. or .F.
    @example
    (examples)
    @see (links_or_references)
    /*/
Function RU05XFN01H_LockSelectedAdvances(aLkdAdvRUS,cAliasSE_,cTab,cRecNoName,lLocked)
    Local lRet        As Logical
    Local aArea       As Array
    Local cAliasArea  As Array
    Local nCurrcTabRN As Numeric
    Default lLocked  := .F.
    lRet := .T.
    If ValType(aLkdAdvRUS) == "A"
        aArea    := GetArea()
        DBSelectArea(cAliasSE_)
        cAliasArea := (cAliasSE_)->(GetArea())
        (cAliasSE_)->(DBGoTop())
        While lRet .AND. (cAliasSE_)->(!Eof())
            nCurrcTabRN := (cTab)->(Recno())
            (cTab)->(DBGoTo((cAliasSE_)->&(cRecNoName)))
            nPos := ASCAN(aLkdAdvRUS, {|x| x[2] == (cAliasSE_)->&(cRecNoName) })
            If lRet .AND. RecLock((cTab), .F.) .AND. !lLocked// lock advance record in SE1 or SE2 table
                If nPos == 0 //add record to array of locked records
                    AADD(aLkdAdvRUS,{cTab,(cAliasSE_)->&(cRecNoName),0})
                Else //we already have a locked record in an array
                    If aLkdAdvRUS[nPos][3] == -1
                        aLkdAdvRUS[nPos][3] := 0 // we locked previously not locked record
                    EndIf
                EndIf
            Else //if we can't lock a record we must exclude it from sql query result
                If nPos == 0 
                    AADD(aLkdAdvRUS,{cTab,(cAliasSE_)->&(cRecNoName),-1})
                Else
                    If aLkdAdvRUS[nPos][3] == 0
                        aLkdAdvRUS[nPos][3] := -1 // we can't lock previously locked record
                    EndIf
                EndIf
            EndIf
            (cTab)->(DBGoto(nCurrcTabRN))
            (cAliasSE_)->(DbSkip())
        EndDo
        (cAliasSE_)->(DBGoTop())
        RestArea(cAliasArea)
        RestArea(aArea)
    EndIf
Return lRet

/*/{Protheus.doc} RU05XFN01I_UnLockSelectedAdvances
    Unlock advances locked by RU05XFN01H_LockSelectedAdvances
    @type  Function
    @author astepanov
    @since 01/11/2022
    @version version
    @param aLkdAdvRUS, Array, {[1] - Alias, [2] - Recno, [3] - 0 (Locked), -1(Was not locked)}
    @return lRet, Logical, .T. or .F.
    @example
    (examples)
    @see (links_or_references)
    /*/
Function RU05XFN01I_UnLockSelectedAdvances(aLkdAdvRUS)
    Local lRet       As Logical
    Local cTab       As Character
    Local nLen       As Numeric
    Local nRecno     As Numeric
    Local nCurrRecno As Numeric
    Local nX         As Numeric
    Local aArea      As Array
    lRet  := .T.
    aArea :=  GetArea()
    If ValType(aLkdAdvRUS) == "A"
        nLen := Len(aLkdAdvRUS)
        For nX := 1 to nLen
            cTab   := aLkdAdvRUS[nX][1]
            nRecno := aLkdAdvRUS[nX][2]
            nCurrRecno := (cTab)->(Recno())
            (cTab)->(DBGoTo(nRecno))
            (cTab)->(MSUnlock())
            (cTab)->(DBGoTo(nCurrRecno))
        Next nX
        aLkdAdvRUS := {}
    EndIf
    RestArea(aArea)
Return lRet

/*/{Protheus.doc} RU05XFN01I_UnLockSelectedAdvances
    Unlock non marked advances in TRBADT temporary table which were locked by 
    RU05XFN01H_LockSelectedAdvances
    @type  Function
    @author astepanov
    @since 01/11/2022
    @version version
    @param aLkdAdvRUS, Array, {[1] - Alias, [2] - Recno, [3] - 0 (Locked), -1(Was not locked)}
    @param cTRBADT, Character, Alias to TRBADT temporary table
    @param cTab, Character, Alias to real table name
    @param cMarca, Character, Mark flag in TRBADT
    @return lRet, Logical, .T. or .F.
    @example
    (examples)
    @see (links_or_references)
    /*/
Function RU05XFN01J_UnlockNonMarkedAdvances(aLkdAdvRUS,cTRBADT,cTab,cMarca)
    Local aAreaTRBAD  As Array
    Local aArea       As Array
    Local nPos        As Numeric
    Local nCurrePos   As Numeric
    Local nSize       As Numeric
    Local lRet        As Logical
    lRet := .T.
    If Valtype(aLkdAdvRUS) == "A"
        aArea := GetArea()
        DBSelectArea(cTRBADT)
        aAreaTRBAD := (cTRBADT)->(GetArea())
        (cTRBADT)->(DBGoTop())
        While (cTRBADT)->(!Eof())
            If (cTRBADT)->MARCA != cMarca //select non-marked line only
                nPos := ASCAN(aLkdAdvRUS, {|x| x[1] == cTab .AND. x[2] == (cTRBADT)->NRECORD .AND. x[3] == 0})
                If nPos > 0 //Unlock Locked Advance Record
                    nCurrePos := (cTab)->(Recno())
                    (cTab)->(DBGoto(aLkdAdvRUS[nPos][2]))
                    (cTab)->(MSUnlock())
                    nSize := Len(aLkdAdvRUS)
                    ADEL(aLkdAdvRUS,nPos)
                    ASIZE(aLkdAdvRUS,nSize-1)
                    (cTab)->(DBGoto(nCurrePos))
                EndIf
            EndIf
            (cTRBADT)->(DBSkip())
        EndDo
        RestArea(aAreaTRBAD)
        RestArea(aArea)
    EndIf
Return lRet

/*/{Protheus.doc} RU05XFN01L_GetSE_Saldo
    @type Function
    @author user
    @since 01/11/2022
    @version version
    @param cTab, Character, "SE1" or "SE2"
    @param nRec, Numeric, R_E_C_N_O_
    @return nRet, Numeric, E1_SALDO or E2_SALDO
    @example
    (examples)
    @see (links_or_references)
/*/
Function RU05XFN01L_GetSE_Saldo(cTab,nRec)
    Local nRet      As Numeric
    Local nCurrnRec As Numeric
    nRet := 0
    nCurrnRec := (cTab)->(Recno())
    (cTab)->(DBGoto(nRec))
    nRet := (cTab)->&(SubStr(cTab,2,2)+"_SALDO")
    (cTab)->(DBGoto(nCurrnRec))
Return nRet

/*/{Protheus.doc} RU05XFN01K_dSaldoDateForAdvance
    Date which we used for getting saldo for advances AR or AP
    @type Function
    @author user
    @since 01/11/2022
    @version version
    @return dRet, Date, Date for RU05XFN01E_GetSaldo
    @example
    (examples)
    @see (links_or_references)
/*/
Function RU05XFN01K_dSaldoDateForAdvance()
    Local dRet := dDatabase
Return dRet

/*/{Protheus.doc} RU05XFN01M_Return_TXMOEDA
    We use this function in GravaSE1 and GravaSE2 functions in LocxNF.PRW source
    When we create a new document (Nakladnaya) we must put to E1_TXMOEDA or E2_TXMOEDA
    exchange rate value. According to russian rules there are several cases:
    1) If we create nakladnaya which write-offs advance, we use echange rate of advance payment.
       In our case this echange rate stored in aExchRates on nPos line.
    2) In several cases we must use exchange rate from SM2 table, where we store
    excahnge rate values from Bank Rosii. For this case we use nCurrency - code of our currency and
    dDate on which we recieve excahnge rate.
    3) Also we can get Exchange rate from Invoice. It should be passed through nInvExRat
    According to order of passed parameters we return required exchange rate, if there is no 
    correct parameters 1 will be returned.
    @type  Function
    @author astepanov
    @since 14/12/2022
    @version version
    @param aExchRates, Array, Array of advances with exchange rates
    @param lUseaExchR, Logical, .T. - use aExchRates for exchange rate, .F. - don't use it
    @param nPos, Numeric, element position in aExchRates
    @param nCurrency, Numeric,  currency of Nakladnaya
    @param dDate, Date,  date of exchange rate which we get from SM2 table
    @param nInvExRat, Numeric, Invoice exchange rate
    @return nExchRate, Numeric, Exchange rate value
    @example
    (examples)
    @see (links_or_references)
    /*/
Function RU05XFN01M_Return_TXMOEDA(aExchRates,lUseaExchR,nPos,nCurrency,dDate,nInvExRat)
    Local nExchRate As Numeric
    nExchRate := 1
    If aExchRates != Nil .AND. lUseaExchR != Nil .AND. lUseaExchR == .T. .AND. nPos != Nil .AND. nPos > 0
        nExchRate := aExchRates[nPos][3]
    ElseIf nCurrency != Nil .AND. nCurrency > 0 .AND. dDate != Nil .AND. Valtype(dDate) == "D"
        nExchRate := RecMoeda(dDate,nCurrency)
    ElseIf nInvExRat != Nil .AND. Valtype(nInvExRat) == "N"
        nExchRate := nInvExRat
    EndIf
Return nExchRate

/*/{Protheus.doc} CrtTmpT00C()
    Creates temporary table for RU05XFN00B function. It returns data from FR3 table and other linked tables
    @type  Static Function
    @author astepanov
    @since 16/03/2023
    @version version
    @param cCliFor, Character, Cliente or Fornece code which relates to A1_COD or A2_COD
    @param cLoja, Character, Client or fornece branch, relates to A1_LOJA or A2_LOJA
    @param cDocNumber, Character, Document number relates to FR3_DOC
    @param cSerie, Character, Document serie relates to FR3_SERIE
    @return cTmpTab, Charcater, aLias to temporary table with data form FR3 table and other linked tables
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function CrtTmpT00C(cCliFor,cLoja,cDocNumber,cSerie)
    Local cTmpTab    As Character
    Local cQuery     As Character
    Local cFields    As Character
    Local oTmpTab    As Object
    Local aTMPStruct As Array
    Local aArea      As Array
    Local nX         As Numeric
    Local nStat      As Numeric
    Local cCart      As Character
    Local cSETab     As Character
    Local cPr        As Character
    Local cClForFld  As Character
    Local cClForFlx  As Character
    Local cError     As Character
    Local cCtrTab    As Character
    Local cCliForNm  As Character
    If FunName() == "MATA101N"
        cCart     := "P"
        cSETab    := "SE2"
        cPr       := "E2"
        cClForFld := "FORNECE"
        cClForFlx := "FORNEC"
        cCtrTab   := "SA2"
        cCliForNm := "A2_NOME"
    Else
        cCart     := "R"
        cSETab    := "SE1"
        cPr       := "E1"
        cClForFld := "CLIENTE"
        cClForFlx := "CLIENT"
        cCtrTab   := "SA1"
        cCliForNm := "A1_NOME"
    EndIf
    aArea := GetArea()
    aTMPStruct := FR3->(DBStruct())
    AADD(aTMPStruct, {"TXMOEDA" ,GetSX3Cache(cPr+"_TXMOEDA","X3_TIPO"),GetSX3Cache(cPr+"_TXMOEDA","X3_TAMANHO"),GetSX3Cache(cPr+"_TXMOEDA","X3_DECIMAL")})
    AADD(aTMPStruct, {"MOEDA"   ,GetSX3Cache(cPr+"_MOEDA"  ,"X3_TIPO"),GetSX3Cache(cPr+"_MOEDA"  ,"X3_TAMANHO"),GetSX3Cache(cPr+"_MOEDA"  ,"X3_DECIMAL")})
    AADD(aTMPStruct, {"NOME"    ,GetSX3Cache(cCliForNm     ,"X3_TIPO"),GetSX3Cache(cCliForNm     ,"X3_TAMANHO"),GetSX3Cache(cCliForNm     ,"X3_DECIMAL")})
    AADD(aTMPStruct, {"COD"     ,GetSX3Cache(Substr(cCtrTab,2,2)+"_COD","X3_TIPO"),GetSX3Cache(Substr(cCtrTab,2,2)+"_COD","X3_TAMANHO"),GetSX3Cache(Substr(cCtrTab,2,2)+"_COD","X3_DECIMAL")})
    cTmpTab := CriaTrab(,.F.)
    oTmpTab := FWTemporaryTable():New(cTmpTab)
    oTmpTab:SetFields(aTMPStruct)
    oTmpTab:Create()
    cFields := ""
    For nX :=1 To Len(aTMPStruct)
        cFields += aTMPStruct[nX][1]+", "
    Next nX
    cFields := SubStr(cFields, 1, Len(cFields)-2)
    cQuery := " SELECT "+cFields+" "
    cQuery += " FROM ( "
    cQuery += " SELECT * FROM "+RetSqlName("FR3")+ " FR3 "
    cQuery += " INNER JOIN ( "
    cQuery += "              SELECT "+cSETab+"."+cPr+"_TXMOEDA TXMOEDA, "
    cQuery += "                     "+cSETab+"."+cPr+"_MOEDA   MOEDA,   "
    cQuery += "                     "+cSETab+"."+cPr+"_FILIAL, "+cSETab+"."+cPr+"_PREFIXO, "+cSETab+"."+cPr+"_NUM, "
    cQuery += "                     "+cSETab+"."+cPr+"_PARCELA,"+cSETab+"."+cPr+"_TIPO   , "+cSETab+"."+cPr+"_"+cClForFld+", "
    cQuery += "                     "+cSETab+"."+cPr+"_LOJA "
    cQuery += "              FROM   "+RetSqlName(cSETab)+" "+cSETab+"  "
    cQuery += "              WHERE  "+cSETab+"."+cPr+"_FILIAL        = '"+xFilial(cSETab)+"' "
    cQuery += "                AND  "+cSETab+"."+cPr+"_"+cClForFld+" = '"+cCliFor        +"' "
    cQuery += "                AND  "+cSETab+"."+cPr+"_LOJA"+"       = '"+cLoja          +"' "
    cQuery += "                AND  "+cSETab+"."+"D_E_L_E_T_         = ' '                   "
    cQuery += "            ) "+cSETab+" "
    cQuery += "            ON "+cSETab+"."+cPr+"_FILIAL        = '"+xFilial(cSETab)+"' "
    cQuery += "           AND "+cSETab+"."+cPr+"_PREFIXO       = FR3.FR3_PREFIX "
    cQuery += "           AND "+cSETab+"."+cPr+"_NUM           = FR3.FR3_NUM    "
    cQuery += "           AND "+cSETab+"."+cPr+"_PARCELA       = FR3.FR3_PARCEL "
    cQuery += "           AND "+cSETab+"."+cPr+"_TIPO          = FR3.FR3_TIPO   "
    cQuery += "           AND "+cSETab+"."+cPr+"_"+cClForFld+" = "+"FR3.FR3_"+cClForFlx
    cQuery += "           AND "+cSETab+"."+cPr+"_LOJA          = FR3.FR3_LOJA   "
    cQuery += " LEFT JOIN  ( "
    cQuery += "              SELECT "+cCtrTab+"."+cCliForNm+" NOME,      "
    cQuery += "                     "+cCtrTab+"."+Substr(cCtrTab,2,2)+"_FILIAL, "+cCtrTab+"."+Substr(cCtrTab,2,2)+"_COD COD, "
    cQuery += "                     "+cCtrTab+"."+Substr(cCtrTab,2,2)+"_LOJA "
    cQuery += "              FROM   "+RetSqlName(cCtrTab)+" "+cCtrTab+"  "
    cQuery += "              WHERE  "+cCtrTab+"."+Substr(cCtrTab,2,2)+"_FILIAL = '"+xFilial(cCtrTab)+"' "
    cQuery += "                AND  "+cCtrTab+".D_E_L_E_T_ = ' '  "
    cQuery += "            )  "+cCtrTab+" "
    cQuery += "            ON "+cCtrTab+"."+Substr(cCtrTab,2,2)+"_FILIAL        = '"+xFilial(cCtrTab)+"' "
    cQuery += "           AND "+cCtrTab+".COD                                   = FR3.FR3_"+cClForFlx+"  "
    cQuery += "           AND "+cCtrTab+"."+Substr(cCtrTab,2,2)+"_LOJA          = FR3.FR3_LOJA           "
    cQuery += " WHERE FR3.FR3_FILIAL        = '"+xFilial("FR3")+"' "
    cQuery += "   AND FR3.FR3_CART          = '"+cCart+         "' "
    cQuery += "   AND FR3.FR3_"+cClForFlx+" = '"+cCliFor+       "' "
    cQuery += "   AND FR3.FR3_LOJA          = '"+cLoja+         "' "
    cQuery += "   AND FR3.FR3_DOC           = '"+cDocNumber+    "' "
    cQuery += "   AND FR3.FR3_SERIE         = '"+cSerie+        "' "
    cQuery += "   AND FR3.D_E_L_E_T_        = ' '                  "
    cQuery += "      ) TAB "
    cQuery := ChangeQuery(cQuery)
    cQuery := " INSERT INTO "+oTmpTab:GetRealName()+" ("+cFields+") "+cQuery
    nStat  := TCSqlExec(cQuery)
    If nStat <  0
        cError := " TCSQLError() " + TCSQLError()
        HELP("",1,"",,cError,1,0,,,,,,{})
        oTmpTab:Delete()
        cTmpTab := Nil
    EndIf
    RestArea(aArea)
Return cTmpTab




/*/{Protheus.doc} RU05XFN01O_Put_An_element_OF_AnArray_After_ANother
    This method  finds the index of the array element with the first position value
     and the index of the array element with the second position value. 
     Then shifts all the elements in the array between these two positions one position to the 
     right and inserts a new element with the second position value immediately after the element with the first 
     position value. 
    @type  Function
    @author eduardo.Flima
    @since 29/03/2023
    @version 29/03/2023
    @param aCpoBro  , Array       , Array base to be shifited
    @param cPosAnt  , Character   , Value stored in the first position of the array item we want to use as base
    @param cPosAfter, Character   , Value stored in the first position of the array item we want to shift    
    @param aCpoBro  , Array       , Array shifited
/*/
Function RU05XFN01O_Put_An_element_OF_AnArray_After_ANother(aCpoBro,cPosAnt,cPosAfter)
    Local nPosAnt := ASCAN(aCpoBro, {|x| x[1] == cPosAnt })
    Local nPosAfter := ASCAN(aCpoBro, {|x| x[1] == cPosAfter })
    Local aReserva :={}
    Local aPosAfter :=aclone(aCpoBro[nPosAfter])
    Local nX :=nPosAfter
    for nX := nPosAfter to nPosAnt+1 STEP -1
        aReserva:=aclone(aCpoBro[nX])
        aCpoBro[nX]:=aCpoBro[nx-1]
    next 
    aCpoBro[nPosAnt+1] :=aPosAfter
Return aCpoBro

/*/{Protheus.doc} RU05XFN01P_Get_ValImp_From_SC6
    Recover Tax Value from Sales Orders Items
    @type  Function
    @author eduardo.Flima
    @since   04/04/2023
    @version 04/04/2023
    @param cNumPed      , Character , Order Number
    @param cItem        , Character , Item Number in Order
    @param cProduto     , Character , Product Code
    @param cTable       , Character , Table to be searched (standart value SC6)
    @param nIndex       , Numeric   , Table to SEARCH      (standart value 1)    
    @return nValImp     ,  Numeric  ,  C6_VALIMP1 value
/*/
Function RU05XFN01P_Get_ValImp_From_SC6_OR_SD2(cNumPed,cItem,cProduto,cTable,nIndex)
    Local nValImp   as Numeric
    Local aArea     as Array
    Local aAreaTab  as Array
    Local cIniTab    as Character

    Default cProduto := ""
    DEFAULT cItem    :=""
    DEFAULT cTable   :="SC6"
    DEFAULT nIndex   := 1 

    cIniTab := Iif (left(upper(cTable),1) =="S",right(cTable,(len(cTable)-1)),  cTable) //Remove 'S' from tables started with S
    
    nValImp   :=0
    aArea     :=GetArea()
    aAreaTab  :=(cTable)->(GetArea())
    DbSelectArea(cTable)
    DbSetOrder(nIndex) // C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO .or. D2_FILIAL+D2_PEDIDO+D2_ITEMPV
    If DbSeek(xFilial(cTable) +cNumPed + cItem + cProduto)
        nValImp:= &(cTable + "->" + cIniTab + "_VALIMP1")
    EndIf
	RestArea(aArea)
	RestArea(aAreaTab)
Return nValImp

/*/{Protheus.doc} RU05XFN01U_Get_BasImp_From_SC6
    Recover Base Value from Sales Orders Items (clone from RU05XFN01P)
    @type  Function
    @author konstantin.konovalov
    @since   12/10/2023
    @version 12/10/2023
    @param cNumPed      , Character , Order Number
    @param cItem        , Character , Item Number in Order
    @param cProduto     , Character , Product Code
    @param cTable       , Character , Table to be searched (standart value SC6)
    @param nIndex       , Numeric   , Table to SEARCH      (standart value 1)    
    @return nValImp     , Numeric   , C6_BASIMP1 value
/*/
Function RU05XFN01U_Get_BasImp_From_SC6_OR_SD2(cNumPed,cItem,cProduto,cTable,nIndex)
    Local nValImp   as Numeric
    Local aArea     as Array
    Local aAreaTab  as Array
    Local cIniTab    as Character

    Default cProduto := ""
    DEFAULT cItem    :=""
    DEFAULT cTable   :="SC6"
    DEFAULT nIndex   := 1 

    cIniTab := Iif (left(upper(cTable),1) =="S",right(cTable,(len(cTable)-1)),  cTable) //Remove 'S' from tables started with S
    
    nValImp   :=0
    aArea     :=GetArea()
    aAreaTab  :=(cTable)->(GetArea())
    DbSelectArea(cTable)
    DbSetOrder(nIndex) // C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO .or. D2_FILIAL+D2_PEDIDO+D2_ITEMPV
    If DbSeek(xFilial(cTable) +cNumPed + cItem + cProduto)
        nValImp:= &(cTable + "->" + cIniTab + "_BASIMP1")
    EndIf
	RestArea(aArea)
	RestArea(aAreaTab)
Return nValImp

/*/{Protheus.doc} VwARFIN040
    Call FIAN040 for viewing ARs.
    @type  Static Function
    @author astepanov
    @since 24/05/2023
    @version version
    @param cFili, Character, E1_FILIAL
    @param cPrefixo, Character, E1_PREFIXO
    @param cNum, Character, E1_NUM
    @param cParcela, Character, E1_PARCELA
    @param cTipo, Character, E1_TIPO
    @return lRet, Logical, .T. if viewwing is ok
    @example
    (examples)
    @see Transferred from oleg.ivanov code
    /*/
Static Function VwARFIN040(cFili, cPrefixo, cNum, cParcela, cTipo)
    Local lRet     As Logical
    Local aArea    As Array
    Local aAreaSE1 As Array
    Local cKey     As Character
    Local aParam   As Array
    Default cFili    := xFilial("SE1")
    Default cPrefixo := ""
    Default cNum     := ""
    Default cParcela := ""
    Default cTipo    := ""
    lRet  := .T.
    aArea := GetArea()
    aAreaSE1 := SE1->(GetArea())
    DBSelectArea("SE1")
    DBSetOrder(1) // E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO - unique key for SE1
    cKey := cFili+cPrefixo+cNum+cParcela+cTipo
    If ("SE1")->(MSSeek(cKey,.T.))
        lMsErroAuto := .F.
        lMsHelpAuto := .F.
        aParam := {}
        AADD(aParam,{ {"E1_PREFIXO",   SE1->E1_PREFIXO,    Nil},;
            {"E1_NUM",                 SE1->E1_NUM,        Nil},;
            {"E1_PARCELA",             SE1->E1_PARCELA,    Nil},;
            {"E1_TIPO",                SE1->E1_TIPO,       Nil},;
            {"E1_NATUREZ",             SE1->E1_NATUREZ,    Nil},;
            {"E1_CLIENTE",             SE1->E1_CLIENTE,    Nil},;
            {"E1_LOJA",                SE1->E1_LOJA,       Nil},;
            {"E1_EMISSAO",             SE1->E1_EMISSAO,    Nil},;
            {"E1_VENCTO",              SE1->E1_VENCTO,     Nil},;
            {"E1_VENCREA",             SE1->E1_VENCREA,    Nil},;
            {"E1_PORTADO",             SE1->E1_PORTADO,    Nil},;
            {"E1_AGEDEP",              SE1->E1_AGEDEP,     Nil},;
            {"E1_CONTA",               SE1->E1_CONTA,      Nil},;
            {"E1_VALOR",               SE1->E1_VALOR,      Nil} })
        MSExecAuto({|x,y| FINA040(x,y)},aParam[1],2) //2-view
        If lMsErroAuto
            MostraErro()
        EndIf
    Else
        lRet := .F.
    EndIf
    RestArea(aAreaSE1)
    RestArea(aArea)
Return lRet

/*/{Protheus.doc} RU05XFN01R_ADDVATTOGRIDVALUE
    We use this this function for changinq SQL query in a468nPrcC9 function in mata468n.
    According to consultant reuiremenet in ruloc-4267 to C9_PRCVEN value should be VAT value. So if 
    you you see incorrect calculations please connect to consultant.
    For returning to standard just remove this function entries in nata468n source
    @type  Function
    @author astepanov
    @since 22/05/2023
    @version 22/05/2023
    @param aStruTRB  , Array      , Array with SC9 fields
    @param lChange   , Logical   , If True - change field content, if .F. - return field content to standard
/*/
Function RU05XFN01R(aStruTRB, lChange)
    Local lRet   As Logical
    Local cField As Character
    Default lChange   := .F.
    Static  nPosition :=  0
    lRet := .T.
    cField := "C9_PRCVEN"
    If lChange
        nPosition := ASCAN(aStruTRB, {|x| x[1] = cField})
        If nPosition > 0
            aStruTRB[nPosition][1] := "(SC9.C9_PRCVEN + SC6.C6_VALIMP1) AS "+cField
        EndIf
    Else
        If nPosition > 0
            aStruTRB[nPosition][1] := cField
            nPosition := 0 
        EndIf
    EndIf
Return lRet



/*/{Protheus.doc} RU05XFN0S_Check_If_Remove_Items_from_Advances
    This method  Check if it will be shown the values already related in the browser
    if not is used then it is removed from the browser
    @type  Function
    @author eduardo.Flima
    @since 29/03/2023
    @version 29/03/2023
    @param aCpoBro      , Array       , Array with the structure of the grid sown
    @param lValrelat    , Logical     , If it will be shown the values already related
    @param cFields      , Character   , Fields to be removed from the grid when necessary in the format Field1|Field2
    @return aCpoBro     , Array       , Array with the structure of the grid sown already changed
/*/
Function RU05XFN0S_Check_If_Remove_Items_from_Advances(aCpoBro,lValrelat,cFields)
    Local nX        as Numeric
    Local nY        as Numeric
    Local aFields   as Array

    DEFAULT lValrelat :=.T.
    DEFAULT cFields   := ""
    nX  :=0
    nY  :=0
    If !lValrelat
        aFields :=separa(cFields,"|")
        For nX := 1 to len(aFields)
            nY :=ASCAN(aCpoBro, {|x| x[1] == aFields[nX]}) 
            If nY >0 
                ADEL(aCpoBro, nY)  
                aSize(aCpoBro,Len(aCpoBro)-1)
            Endif             
        Next nX       
    ENDIF
Return aCpoBro



/*/{Protheus.doc} RU05XFN0S1_Automatic_Select
    Function responsible for automatically selecting the advances when they have 
    not already been selected in the sales order.
    @type  Function
    @author eduardo.Flima
    @since 09/06/2023
    @version 09/06/2023
    @param TRBADT       , Character , Temporary table with the advances avaliable
    @param nSelec       , Numeric   , Value Selected 
    @param aInfAdto     , Array     , Array with the advances Info
    @param cMarca       , Character , Value to the registers selected
    @param nValLimite   , Numeric   , Valuye max to be selected 
    @param aPedidos     , Array     , Array with the advances selected in the sales order
    @param cPedido      , Character , Number of the sales order    
    @return nOpcA       , Numeric   , Value to alow the proccess to continue
/*/
Function RU05XFN0S1_Automatic_Select(TRBADT,nSelec,aInfAdto,cMarca,nValLimite,aPedidos,cPedido)
    Local nValRub as Numeric
    Local nOpcA   as Numeric
    nValRub :=0
    nOpcA   :=1
    Aadd( aInfAdto, { cPedido, nValLimite } )
    If EMPTY(aPedidos)        
        While TRBADT->(!Eof()) .and. nSelec < nValLimite
            TRBADT->MARCA := cMarca
            If (nValLimite - nSelec) >= TRBADT->Saldo
                TRBADT->VALAREL :=  TRBADT->Saldo
            else
                TRBADT->VALAREL := nValLimite - nSelec
            EndIf
            nValRub := round(xMoeda(TRBADT->VALAREL,TRBADT->MOEDA,1,,3,TRBADT->EXRATE),2)
            TRBADT->PRINCIP :=  TRBADT->PRINCIP - TRBADT->VALAREL
            TRBADT->BALRUB  :=  TRBADT->BALRUB - nValRub
            TRBADT->RELRUB  :=  TRBADT->RELRUB + nValRub
            nSelec += TRBADT->VALAREL
            TRBADT->(DBSkip())
        EndDo
    ENDIF
    TRBADT->(DBGoTop())
Return nOpcA

/*/{Protheus.doc} RU05XFN01Q_Get_ValBrut_From_SD2
    Recover Total Value Plus taxes
    @type  Function
    @author eduardo.Flima
    @since   04/04/2023
    @version 04/04/2023
    @param cNumPed      , Character , Order Number
    @param cItem        , Character , Item Number in Order
    @param cProduto     , Character , Product Code
    @param cTable       , Character , Table to be searched (standart value SD2)
    @param nIndex       , Numeric   , Table to SEARCH      (standart value 8)    
    @return nValBrut     ,  Numeric  ,  D2_VALBRUT value
/*/
Function RU05XFN01Q_Get_ValBrut_From_SD2(cNumPed,cItem,cProduto,cTable,nIndex)
    Local nValBrut   as Numeric
    Local aArea     as Array
    Local aAreaTab  as Array
    Local cIniTab    as Character

    Default cProduto := ""
    DEFAULT cItem    :=""
    DEFAULT cTable   :="SD2"
    DEFAULT nIndex   := 8 

    cIniTab := Iif (left(upper(cTable),1) =="S",right(cTable,(len(cTable)-1)),  cTable) //Remove 'S' from tables started with S
    
    nValBrut   :=0
    aArea     :=GetArea()
    aAreaTab  :=(cTable)->(GetArea())
    DbSelectArea(cTable)
    DbSetOrder(nIndex) 
    If DbSeek(xFilial(cTable) +cNumPed + cItem + cProduto)
        nValBrut:= &(cTable + "->" + cIniTab + "_VALBRUT")
    EndIf
	RestArea(aArea)
	RestArea(aAreaTab)
Return nValBrut

/*/{Protheus.doc} RU05XFN01S
    This function generates a Total Panel for oDlg1 in FPDxADTREL function in FINAXPI.PRX
    @type  Function
    @author astepanov
    @since 15/09/2023
    @version version
    @param aPnlTotals, Array, This array contains next information
    {{"DOCNUMBER",STR0016,Nil,"cPedido"},;
    {"LIMITVALUE",STR0017,Nil,"nValLimite"},;
    {"SELECTEDVAL",STR0022,"oSelec","nSelec"},;
    {"TOTALVALLC",STR0064,"oTotValRub","nTotValRub"},;
    {"NEWEXCHRATE",STR0065,"oNewExRate","nNewExRat"},;
    {"STDEXCHRATE",STR0066,Nil,"nStandExcR"}}
    which we pass form FINXAPI, we use it for creating caontrols on Panel
    @param oPanel, Object, Panel on oDlg1
    @param oDlg1, Object, Container for controls
    @param cPrefix, Character, "E2" or "E1"
    @param cCarteira, Caharacter, "P" or "R"
    @param cPedido, Character, Document number passed by reference
    @param nValLimite, Numeric, Limit value passed by reference
    @param oSelec, Object, Object passed by reference which serves nSelec variable
    @param nSelec, Numeric, Select value passed by reference
    @param oTotValRub, Object, Object passed by reference which serves nTotValRub variable
    @param nTotValRub, Numeric, Total value in Local Currency passed by reference
    @param oNewExRate,  Object,  Object passed by reference which serves nNewExRat variable
    @param nNewExRat, Numeric, New exchange rate value passed by reference
    @param nStandExcR, Numeric, Standard exchange rate value
    @return lRet, Logical, .T. - all is ok
    @example
    (examples)
    @see (links_or_references)
    /*/
Function RU05XFN01S(aPnlTotals,oPanel,oDlg1,cPrefix,cCarteira,cPedido,nValLimite,oSelec,nSelec,oTotValRub,nTotValRub,oNewExRate,nNewExRat,nStandExcR)
    Local lRet := .T.
    Local cNewExRPic As Character
    Local cStdExRPic As Character
    Local cTotVLCPic As Character
    Local nRow1   := 010 //first row position
    Local nCol1   := 040 //first column position
    Local nCol2   := 300 //second column position
    Local nStepR  := 080 //right step value
    Local nStepD  := 015 //down step value
    Local nWidth  := 120 //TGet element width
    Local nHeight := nStepD - 002 //TGet element height
    Local lPixelCoord := .T. // Use pixels for coordinate values
    Local nAlign  := 1      // align to right border
    Local lReadOnly := .T.  // user can read only tGet element
    Local oPedido    As Object
    Local oValLimite As Object
    Local oStandExcR As Object

    If cCarteira == "P"
        aPnlTotals[1][2] := IIf(FunName()== "MATA101N",RetTitle("D1_DOC"),RetTitle("D2_DOC")) //Title for document number
        cNewExRPic := GetSX3Cache("F1_TXMOEDA","X3_PICTURE")
        cStdExRPic := cNewExRPic
    Else
        cNewExRPic := GetSX3Cache("F2_TXMOEDA","X3_PICTURE")
        cStdExRPic := cNewExRPic
    EndIf
    cTotVLCPic := GetSX3Cache(cPrefix+"_VLCRUZ","X3_PICTURE")

    nRow := nRow1
    @nRow, nCol1 Say aPnlTotals[1][2] FONT oDlg1:oFont PIXEL OF oPanel  //Document
    oPedido := TGet():New(nRow,nCol1+nStepR,{|u| If(PCount()>0,cPedido:=u,cPedido)},oPanel,nWidth,nHeight,"@!",/*bValid*/,/*nClrFore*/,/*nClrBack*/,oDlg1:oFont,/*uParam12*/,/*uParam13*/,lPixelCoord/*lPixel*/,/*uParam15*/,/**uParam16*/,/*bWhen*/,/*uParam18*/,/*uParam19*/,/*bChange*/,lReadOnly,/*lPassword*/,/*uParam23*/,aPnlTotals[1][4]/*cReadVar*/) //cPedido
    oPedido:SetContentAlign(nAlign)
    
    nRow := nRow + nStepD
    @nRow, nCol1 Say aPnlTotals[2][2] FONT oDlg1:oFont PIXEL OF oPanel  //Limit Value
    oValLimite := TGet():New(nRow,nCol1+nStepR,{|u| If(PCount()>0,nValLimite:=u,nValLimite)},oPanel,nWidth,nHeight,"@E 9,999,999,999.99",/*bValid*/,/*nClrFore*/,/*nClrBack*/,oDlg1:oFont,/*uParam12*/,/*uParam13*/,lPixelCoord/*lPixel*/,/*uParam15*/,/**uParam16*/,/*bWhen*/,/*uParam18*/,/*uParam19*/,/*bChange*/,lReadOnly,/*lPassword*/,/*uParam23*/,aPnlTotals[2][4]/*cReadVar*/) //nValLimite
    oValLimite:SetContentAlign(nAlign)

    nRow := nRow + nStepD
    @nRow, nCol1 Say aPnlTotals[3][2] FONT oDlg1:oFont PIXEL OF oPanel  //Selected Value
    oSelec := TGet():New(nRow,nCol1+nStepR,{|u| If(PCount()>0,nSelec:=u,nSelec)},oPanel,nWidth,nHeight,"@E 9,999,999,999.99",/*bValid*/,/*nClrFore*/,/*nClrBack*/,oDlg1:oFont,/*uParam12*/,/*uParam13*/,lPixelCoord/*lPixel*/,/*uParam15*/,/**uParam16*/,/*bWhen*/,/*uParam18*/,/*uParam19*/,/*bChange*/,lReadOnly,/*lPassword*/,/*uParam23*/,aPnlTotals[3][4]/*cReadVar*/) //nSelec
    oSelec:SetContentAlign(nAlign)

    nRow := nRow1
    If IIf(FunName() != "MATA468N" .And. FunName() != "MATA410", M->F2_MOEDA, SC5->C5_MOEDA) <> 1
        If FunName() != "MATA410"
            @nRow, nCol2 Say aPnlTotals[4][2] FONT oDlg1:oFont PIXEL OF oPanel  //Total Value in Local currency in Rubles
            oTotValRub := TGet():New(nRow,nCol2+nStepR,{|u| If(PCount()>0,nTotValRub:=u,nTotValRub)},oPanel,nWidth,nHeight,cTotVLCPic,/*bValid*/,/*nClrFore*/,/*nClrBack*/,oDlg1:oFont,/*uParam12*/,/*uParam13*/,lPixelCoord/*lPixel*/,/*uParam15*/,/**uParam16*/,/*bWhen*/,/*uParam18*/,/*uParam19*/,/*bChange*/,lReadOnly,/*lPassword*/,/*uParam23*/,aPnlTotals[4][4]/*cReadVar*/) //nTotValRub
            oTotValRub:SetContenteAlign(nAlign)
            nRow := nRow + nStepD
            @nRow, nCol2 Say aPnlTotals[5][2] FONT oDlg1:oFont PIXEL OF oPanel  //New exchange rate
            oNewExRate := TGet():New(nRow,nCol2+nStepR,{|u| If(PCount()>0,nNewExRat:=u,nNewExRat)},oPanel,nWidth,nHeight,cNewExRPic,/*bValid*/,/*nClrFore*/,/*nClrBack*/,oDlg1:oFont,/*uParam12*/,/*uParam13*/,lPixelCoord/*lPixel*/,/*uParam15*/,/**uParam16*/,/*bWhen*/,/*uParam18*/,/*uParam19*/,/*bChange*/,lReadOnly,/*lPassword*/,/*uParam23*/,aPnlTotals[5][4]/*cReadVar*/) //nNewExRat
            oNewExRate:SetContenteAlign(nAlign)
            nRow := nRow + nStepD
        EndIf
        @nRow, nCol2 Say aPnlTotals[6][2] FONT oDlg1:oFont PIXEL OF oPanel  //Standard exchange rate
        oStandExcR := TGet():New(nRow,nCol2+nStepR,{|u| If(PCount()>0,nStandExcR:=u,nStandExcR)},oPanel,nWidth,nHeight,cStdExRPic,/*bValid*/,/*nClrFore*/,/*nClrBack*/,oDlg1:oFont,/*uParam12*/,/*uParam13*/,lPixelCoord/*lPixel*/,/*uParam15*/,/**uParam16*/,/*bWhen*/,/*uParam18*/,/*uParam19*/,/*bChange*/,lReadOnly,/*lPassword*/,/*uParam23*/,aPnlTotals[6][4]/*cReadVar*/) //nStandExcR
        oStandExcR:SetContenteAlign(nAlign)
        nRow := nRow + nStepD
    EndIf

Return lRet

/*/{Protheus.doc} RU05XFN0S3_Get_PartialRatio (RU05XFN0S3)
    the partial delivery multiplier caclulation
    @type  Function
    @author Konstantin.Konovalov
    @since   05/10/2023
    @version 05/10/2023
    @param nSoldQty  , Numeric , Sold Quantity
    @param nDelQty   , Numeric , Current quantity for delivery
    @param cPedido   , Character , Document number 
    @param cCliente  , Character , Client code
    @param cItemPV   , Character , Sales Order Item    
    @return cCod     , Charater ,  StockItem Code (MTR)
/*/
Function RU05XFN0S3_Get_PartialRatio(nSoldQty, nDelQty, cPedido, cCliente, cItemPV, cCod)
    Local aArea         as Array
    Local nResult       as Numeric
    Local nSumQty       as Numeric
    Local cAlias        as Character
    Local cAliasQry     as Character
    Local cQuery        as Character
    
    aArea  :=GetArea()
    cAlias :="SD2"
    cAliasQry  := GetNextAlias()

    cQuery := "SELECT COALESCE(SUM(D2_QUANT), 0) CONFSUM "
    cQuery += "FROM " + RetSqlName(cAlias) + " " + cAlias + " "
    cQuery += "WHERE  SD2.D2_FILIAL ='" + xFilial(cAlias) + "' AND "
    cQuery += " SD2.D2_PEDIDO ='" + cPedido + "' AND "
    cQuery += " SD2.D2_CLIENTE ='" +  cCliente  + "' AND " 
    cQuery += " SD2.D2_ITEMPV ='" + cItemPV + "' AND "
    cQuery += " SD2.D2_COD ='" + cCod + "' AND "
    cQuery += " SD2.D_E_L_E_T_ = ' ' "   
    
    cQuery := ChangeQuery(cQuery)
    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)

    nSumQty := (cAliasQry)->CONFSUM   
    (cAliasQry)->( dbCloseArea())
    if((nSumQty + nDelQty) == nSoldQty)
        // Last delivery (eliminate error rounding from previous deliveries):
        nResult := 1 - nSumQty/nSoldQty
    else
        // current delivery is a next delivery (not last):
        nResult := nDelQty/nSoldQty
    endif
    RestArea(aArea)

Return nResult

/*/{Protheus.doc} RU05XFN01T_Confirm_Value
    Filling data for popup for Russia
    @type  Function
    @author ogalyandina
    @since 09/10/2023
    @version version
    @param  lNotAviso as Logical,
            lCallStAut as Logical,
            lActVlrInf as Logical as Reference,
            lRet as Logical as Reference,
            cTxt1,cTxt2,cTxt3,cTxt4,cTxt5,cTxt6,cTxt7,cTxt8,cTxt9,cTxt10
                as Character, STR* for forming message;
            cNumPedido,nValTot,nValAdt as Numeric, for forming message
    @return NIL
    /*/
Function RU05XFN01T_Confirm_Value(lNotAviso,lCallStAut,lActVlrInf,lRet,;
                cTxt1,cTxt2,cTxt3,cTxt4,cTxt5,cTxt6,cTxt7,cTxt8,cTxt9,cTxt10,;
                cNumPedido,nValTot,nValAdt)
    Local cNewLine := CHR(13) + CHR(10)
    Local nRemType := GetRemoteType()
    Local nAviso
    If nRemType == 5
        cNewLine += "<br>"
    Endif
    If !lNotAviso
        If !lCallStAut
            nAviso := AVISO(cTxt1, cTxt2 + ;
            cNewLine + cNewLine + cTxt3 + cNumPedido + cNewLine + ;
            cTxt4 + cValToChar(nValTot) + cNewLine +;
            cTxt5 + cValToChar(nValAdt) + cNewLine + cNewLine + ;
            cTxt6 + cNewLine, ;
            {cTxt7, cTxt8, cTxt9, cTxt10}, 2)

            If nAviso == 1
                lActVlrInf := .F.
            ElseIf  nAviso == 2
                lActVlrInf := .T.
            Else
                If nAviso == 4
                    lNotAviso := .T.
                EndIf
                lActVlrInf := .F.
                lRet := .T.
            Endif
        Else 
            nAviso := 2
            lActVlrInf := .T.
        EndIf
	Else
        lRet := .T.
    EndIf
Return NIL

/*/{Protheus.doc} RU05XFN0U6
    Filling blines for Window after changing number
    @type  Function
    @author ogalyandina
    @since 29/09/2023
    @version 0
    @param  bline6 as Block as Reference, 
            bline7 as Block as Reference, 
            bline8 as Block as Reference, 
            bline9 as Block as Reference, 
            aFacs as Array, 
            oLbx as Object as Reference
    @return NIL
    /*/
Function RU05XFN0U6(bline6, bline7, bline8, bline9, aFacs, oLbx)
    bline6	:=	{ || {aFacs[oLbx:nAt,1],aFacs[oLbx:nAt,2],aFacs[oLbx:nAt,3],aFacs[oLbx:nAt,4],aFacs[oLbx:nAt,5],aFacs[oLbx:nAt,6],aFacs[oLbx:nAt,7],Transform(aFacs[oLbx:nAt,11],PesqPict("SD2","D2_TOTAL")),Transform(aFacs[oLbx:nAt,12],PesqPict("SD2","D2_TOTAL")),Transform(aFacs[oLbx:nAt,13],PesqPict("SD2","D2_TOTAL")),Transform(aFacs[oLbx:nAt,14],PesqPict("SD2","D2_TOTAL")),Transform(aFacs[oLbx:nAt,15],PesqPict("SD2","D2_TOTAL"))}}
    bline7	:=	{ || {aFacs[oLbx:nAt,1],aFacs[oLbx:nAt,2],aFacs[oLbx:nAt,3],aFacs[oLbx:nAt,4],aFacs[oLbx:nAt,5],aFacs[oLbx:nAt,6],aFacs[oLbx:nAt,7],Transform(aFacs[oLbx:nAt,11],PesqPict("SD2","D2_TOTAL")),Transform(aFacs[oLbx:nAt,12],PesqPict("SD2","D2_TOTAL")),Transform(aFacs[oLbx:nAt,13],PesqPict("SD2","D2_TOTAL")),Transform(aFacs[oLbx:nAt,14],PesqPict("SD2","D2_TOTAL")),Transform(aFacs[oLbx:nAt,15],PesqPict("SD2","D2_TOTAL"))}}
    bline8	:=	{ || {aFacs[oLbx:nAt,1],aFacs[oLbx:nAt,2],aFacs[oLbx:nAt,3],aFacs[oLbx:nAt,4],aFacs[oLbx:nAt,5],aFacs[oLbx:nAt,6],;
                        aFacs[oLbx:nAt,7],aFacs[oLbx:nAt,8],aFacs[oLbx:nAt,9],aFacs[oLbx:nAt,10]}}
    bline9	:=	{ || {aFacs[oLbx:nAt,1],aFacs[oLbx:nAt,2],aFacs[oLbx:nAt,3],aFacs[oLbx:nAt,4],;
                        aFacs[oLbx:nAt,5],aFacs[oLbx:nAt,6],aFacs[oLbx:nAt,7],;
                        Transform(aFacs[oLbx:nAt,11],PesqPict("SD2","D2_TOTAL")),;
                        Transform(aFacs[oLbx:nAt,12],PesqPict("SD2","D2_TOTAL")),;
                        Transform(aFacs[oLbx:nAt,13],PesqPict("SD2","D2_TOTAL")),;
                        Transform(aFacs[oLbx:nAt,14],PesqPict("SD2","D2_TOTAL")),;
                        Transform(aFacs[oLbx:nAt,15],PesqPict("SD2","D2_TOTAL")),;
                        Transform(aFacs[oLbx:nAt,16],PesqPict("SF1","F1_TXMOEDA")),aFacs[oLbx:nAt,10]}}
Return NIL

/*/{Protheus.doc} RU05XFN0U7
    filling array aFacs for "RUS"
    @type  Function
    @author ogalyandina
    @since 29/09/2023
    @version 0
    @param  aNFS as Array, 
            nX as Numeric, 
            aDtSaida as Array, 
            aFacs as Array as Reference, 
            nCli as Numeric, 
            nLoja as Numeric
    @return NIL
    /*/
Function RU05XFN0U7(aNFS, nX, aDtSaida, aFacs, nCli, nLoja)
    If aNFS[nX][12]
        AAdd(aFacs,{aNFS[nX][8],aNFS[nX][9],'->',aNFS[nX][3],aNFS[nX][4],Substr(aNFs[nX][1],1,nCli),Substr(aNFs[nX][1],nCli+1,nLoja),;
            Posicione('SA2',1,xFilial('SA2')+Substr(aNFs[nX][1],1,nCli)+Substr(aNFs[nX][1],nCli+1,nLoja),'A2_NREDUZ'),;
            DTOC(aDtSaida[Len(aDtSaida)])})
    Else
        AAdd(aFacs,{aNFS[nX][8],aNFS[nX][9],'->',aNFS[nX][3],aNFS[nX][4],Substr(aNFs[nX][1],1,nCli),Substr(aNFs[nX][1],nCli+1,nLoja),;
            Posicione('SA1',1,xFilial('SA1')+Substr(aNFs[nX][1],1,nCli)+Substr(aNFs[nX][1],nCli+1,nLoja),'A1_NREDUZ'),;
            DTOC(aDtSaida[Len(aDtSaida)])})
    Endif
Return NIL

/*/{Protheus.doc} RU05XFN0U8
    Button - add purchase order  - filling array aCols for "RUS" in LxA103SC7ToaCols 
    @type  Function
    @author avelmozhnaya
    @since 2023/10/13
    @version 2210
    @param  nItem       Numeric     Current grid posicion
            nSalPed     Numeric     Purchase order quantity saldo 
            aHeader     Array       Fields parameters
            aCols       Array       Grid
            lPreNota    Logical     Indicates whether Pre-Note data should be preserved
            nTaxaNF     Numeric     Tax Rate of Invoice
            nTaxaPed    Numeric     Tax rate of purchase order
    @return NIL
    @use LocxNf2 LxA103SC7ToaCols
    /*/
Function RU05XFN0U8(nItem,nSalPed,aHeader,aCols,lPreNota,nTaxaNF,nTaxaPed)
    Local nPerQuant	as Numeric	// Not delivery Purchase order quantity in proporcial for multiply Tax and tax base values
    Local nTotalM   as Numeric
    Local nBaseImp as Numeric
    Local nBaseImpM as Numeric
    Local nValImp as Numeric
    Local nValImpM as Numeric
    Local nAlqImp as Numeric
    Local nCf as Numeric
    Local nDesc as Numeric
    Local nFDesc as Numeric

    nTotalM     := aScan(aHeader, {|x| Trim(x[2]) == "D1_TOTALM" })
    nBaseImp    := aScan(aHeader, {|x| Trim(x[2]) == "D1_BASIMP1" })
    nBaseImpM   := aScan(aHeader, {|x| Trim(x[2]) == "D1_BSIMP1M" })
    nValImp     := aScan(aHeader, {|x| Trim(x[2]) == "D1_VALIMP1" })
    nValImpM    := aScan(aHeader, {|x| Trim(x[2]) == "D1_VLIMP1M" })
    nAlqImp     := aScan(aHeader, {|x| Trim(x[2]) == "D1_ALQIMP1" })
    nCf         := aScan(aHeader, {|x| Trim(x[2]) == "D1_CF" })
    nDesc       := aScan(aHeader, {|x| Trim(x[2]) == "D1_DESCRI" })
    nFDesc      := aScan(aHeader, {|x| Trim(x[2]) == "D1_FDESC" })

    nPerQuant	:= nSalPed/SC7->C7_QUANT
    If nTotalM > 0
        If !lPreNota
            aCols[nItem,nTotalM] := xMoeda( SC7->C7_TOTAL * nPerQuant,SC7->C7_MOEDA,1,dDatabase,TamSX3('D1_TOTALM'  )[2],nTaxaNF)
        EndIf
    EndIf
    If nBaseImp > 0
    	aCols[nItem,nBaseImp] := xMoeda(SC7->C7_BASIMP1 * nPerQuant,SC7->C7_MOEDA,M->F1_MOEDA,dDatabase,TamSX3('D1_BASIMP1'  )[2],nTaxaPed,nTaxaNF)
    EndIf
	If nBaseImpM > 0
        aCols[nItem,nBaseImpM] := xMoeda(SC7->C7_BASIMP1 * nPerQuant,SC7->C7_MOEDA,1,dDatabase,TamSX3('D1_BSIMP1M'  )[2],nTaxaNF)
    EndIf
    If nValImp > 0
		aCols[nItem,nValImp] := xMoeda(SC7->C7_VALIMP1 * nPerQuant,SC7->C7_MOEDA,M->F1_MOEDA,dDatabase,TamSX3('D1_VALIMP1'  )[2],nTaxaPed,nTaxaNF)
    EndIf
	If nValImpM > 0
		aCols[nItem,nValImpM] := xMoeda(SC7->C7_VALIMP1 * nPerQuant,SC7->C7_MOEDA,1,dDatabase,TamSX3('D1_VLIMP1M'  )[2],nTaxaNF)
    EndIf
    
    If nAlqImp > 0
        aCols[nItem,nAlqImp] := SC7->C7_ALQIMP1
    EndIf
    If nCf > 0
		aCols[nItem,nCf] := SC7->C7_CF
    EndIf
    If nDesc > 0
        aCols[nItem,nDesc] :=SC7->C7_DESCRI
    EndIf
    If nFDesc > 0
        aCols[nItem,nFDesc] :=SC7->C7_FDESC
    EndIf
Return NIL


/*/{Protheus.doc} RU05XFN0U9_LxAdianRus
    Call to Item Advances Link Screen based on LxAdianMex 
    @type  Function
    @author eduardo.Flima
    @since 03/09/2024
    @version R14
    @param cNum             , Character  , Invoice Number
    @param cCondPagto       , Character  , Payment Conditions cODE
    @param nTotal           , Numeric    , Total advance amount
    @param aRecnoSE1        , Array      , Array with the Recno of the advances in SE2
    @param lCarregaTotal    , Logical    , If all the value will be charged
    @param cCodCli          , Character  , Customers Code
    @param cCodLoja         , Character  , Customers Branch
    @param cNatureza        , Character  , Class Code
    @param aAddRus          , Array      , Array with Legal contract information
/*/
Function RU05XFN0U9_LxAdianRus(cNum, cCondPagto, nTotal, aRecnoSE1 , lCarregaTotal , cCodCli, cCodLoja, cNatureza, aAddRus, cParRotina)
    Local nX		as Numeric
    Local nSoma	    as Numeric
    Local nNewExRat as Numeric
    Local lAdiant   as Logical 
    Local cRotina   as Charater
    Local cHelp     as Character
    Local nValor    as Numeric

    Default aAddRus := {}	//FI-AR-16-1 Prepayments in AR part 1: Russian convential Unit and legal contract
    Default cParRotina := FunName()

    nSoma	:= 0
    nX		:= 0
    nValor  := 0
    lAdiant :=.F.
    cRotina := alltrim(cParRotina)
    cHelp   :=""


    aAddRus := RU99XFUN0A(aAddRus)
    nNewExRat := MaFisRet(,'NF_TXMOEDA')

    If cRotina ==  "MATA101N"
        lAdiant := MafisRet(,"NF_BASEDUP") > 0 //FI-AP-16-1 part 3
        nValor :=MafisRet(,"NF_TOTAL")
        cHelp :=STR0100 //Total value must be upper than zero to be possible selected prepayment
    ElseIF cRotina $  "MATA467N|MATA410"
        lAdiant := (Type("N")=="N" .AND. N > 0 .AND. MaFisFound("IT",N) .AND. ;
                    !Empty(MafisRet(N,"IT_TES")) .AND. ;
                    ( MafisRet(N,"IT_TOTAL") > 0 .OR. MafisRet(N,"IT_ADIANT") > 0))
        nValor :=nTotal
        cHelp :=STR0101 //To associate advances, first position in one of the Invoice items and fill out the TIO and the Values.
    Endif

    If lAdiant

        If Len(aRecnoSE1) == 0
            Alert(STR0098) //"Warning! Once you associate advances, you cannot edit the Customer/Store or the Currency/Rate."
        EndIf

        A410Adiant(cNum, cCondPagto,  nValor    , @aRecnoSE1, lCarregaTotal, cCodCli, cCodLoja, NIL,NIL,NIL,NIL,cNatureza,MafisRet(N,"IT_TES"),N,,aAddRus,@nNewExRat)

        If MafisRet(,"NF_MOEDA") > 1 .And. cRotina $ "MATA467N/MATA101N" .And. Len(aRecnoSE1) > 0
            RU05XFN00U(nNewExRat) // update exchange rate
            If bDoRefresh != Nil
                Eval(bDoRefresh)
            EndIf
        EndIf

    Else
        Aviso(STR0099,cHelp,{STR0005})	//Attention #Total value must be upper than zero to be possible selected prepayment/ To associate advances, first position in one of the Invoice items and fill out the TIO and the Values. #OK
    EndIf
    
Return 
