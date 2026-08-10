#INCLUDE "PROTHEUS.CH"
#INCLUDE "SHELL.CH"
#INCLUDE "STPESQLIKE.CH"
#INCLUDE "FWLIBVERSION.CH"

Static cProdSelected := ""
Static __aPrepared   := {}

//-------------------------------------------------------------------
/*{Protheus.doc} STPesqLike
Faz a chamada da janela de pequisa 

@param   
@author  Varejo
@version P11.8
@since   08/04/2014
@return  lRet -	Se encontrou produtos ou nao
*/
//-------------------------------------------------------------------
Function STPesqLike()

Local aArea := GetArea() // Guarda area corrente

Local i         := 0              // Contador
Local j         := 0              // Contador  
Local nOpcaSB1X := 0              // Opcao
Local nOpFab    := 2              // Opcao Fabricante
Local nOpGru    := 2              // Opcao Grupo
Local nOpTip    := 2              // Opcao Tipo
Local nOpDes    := 2              // Opcao Descricao
Local nOpCod    := 2              // Opcao Codigo
Local oOpFab    := Nil            // Objeto Fabricante
Local oOpGru    := Nil            // Objeto Grupo
Local oOpTip    := Nil            // Objeto Tipo
Local oOpDes    := Nil            // Objeto Descricao
Local oOpCod    := Nil            // Objeto Codigo
Local oDlg	    := Nil            // Objeto da Dialog

Local cFabric   := Space( 40 )    // Conteudo do campo Fabricante
Local cGrupo    := Space( 4 )     // Conteudo do campo Grupo
Local cTipo     := Space( 2 )     // Conteudo do campo Tipo
Local cProdut   := Space( 15 )    // Conteudo do campo Produto
Local cDescPr   := Space( 40 )    // Conteudo do campo Descricao

Local nGuarda := 1                // Opcao
	
Local aLbx:= {}                   // Array do listbox
Local cline:= ""                  // Linha

Local aCabec    := {STR0001,STR0002,STR0004,STR0003,STR0005} // Array do cabecalho  "Cod. Produto" ### "Descrição" ### "Fabricante" ### "Tipo" ###  "Grupo"

cProdSelected := ""
	  	
// Monta os dados do listbox
DbSelectArea("SB1")
MontaArray(.T.,@aLbx,@cline,"SB1")
Define MsDialog oDlg Title STR0006 From 000,000 To 421,610 Pixel // "Pesquisa de Produto"

DEFINE FONT oBold NAME "Arial" SIZE 0, -13 BOLD
                                                    
@ 12, 10 SAY STR0002 SIZE 40, 10    PIXEL  // "Descrição"
@ 10, 40 MSGET oGetPesq2 VAR cDescPr SIZE 150, 10 VALID .T. PIXEL  PICTURE "@!"

@ 26, 10 SAY STR0004 SIZE 40, 10    PIXEL  // "Fabricante"
@ 24, 40 MSGET oGetPesq3 VAR cFabric SIZE 150, 10 VALID .T. PIXEL

@ 40, 10 SAY STR0007 SIZE 40, 10    PIXEL  // "Codigo"
@ 38, 40 MSGET oGetPesq3 VAR cProdut SIZE 150, 10 VALID .T. PIXEL F3 "SB1" HasButton PICTURE "@!"
                                                      
@ 60, 10 Button STR0008 of oDlg Size 40,12 Pixel Action FiltraDados(cFabric,cGrupo,cTipo,nOpFab,;
															nOpGru,nOpTip,nOpCod,nOpDes,cProdut,cDescPr,@aLbx,@cline) //"&Filtrar"
@ 60, 55 Button STR0009  of oDlg Size 40,12 Pixel Action LimpaCampos( @cFabric, @cGrupo, @cTipo, @cProdut, @cDescPr ) //"&Limpar"

oLbx:= TWBrowse():New(6,0,303,110,,aCabec,, oDlg,,,,,,,,,,,, .F.,, .F.,, .F.,,, )

Aadd(aLbx,{"","","","",""})
oLbx:SetArray(aLbx)
oLbx:bLine := &(cline)

oLbx:bLDblClick := {|| (nOpcaSB1X := 1,nGuarda:=oLbx:nAt,oDlg:End()) }

oTButton1 := TButton():Create( oDlg,197,010,STR0010,{||nOpcaSB1X := 1,nGuarda := oLbx:nAt, oDlg:End()},40,12,,,,.T.,,,,,,) //"&Confirmar"
oTButton2 := TButton():Create( oDlg,197,055,STR0011,{||nOpcaSB1X := 0, oDlg:End()},40,12,,,,.T.,,,,,,) //"&Sair"

ACTIVATE MSDIALOG oDlg CENTERED 

lRet := .T.

If nGuarda > 0 .and. Len(aLbx) > 0 .and. Len(aLbx) >= nGuarda
	If Empty(aLbx[nGuarda][1]) .AND. Empty(aLbx[nGuarda][2])
		nOpcaSB1X := 0
	Endif	
	dbSelectArea("SB1")
	SET FILTER TO	
	If nOpcaSB1X == 1
		cProdSelected := cValToChar(aLbx[nGuarda][1])
	else
		lRet := .F.
	EndIf	
Else		
	lRet := .F.	
Endif

RestArea(aArea)
	
Return lRet

//-------------------------------------------------------------------
/*{Protheus.doc} FiltraDados
Aplica o filtro especificado pelo usuario

@param   
@author  Varejo
@version P11.8
@since   08/04/2014
@return  lRet -	Se encontrou produtos ou nao
@obs     
@sample
*/
//-------------------------------------------------------------------
Static Function FiltraDados(cFabric,cGrupo,cTipo,nOpFab,nOpGru,nOpTip,nOpCod,nOpDes,cProdut,cDescPr,aLbx,cline)

Local cSb1Alias    := GetNextAlias()
Local cQuery	   := ""
Local nX           := 0
Local aInsert 	   := {}
Local nIniLoopPS   := 1
Local nLen 		   := 0 
Local nPosPrepared := 0 
Local cMD5 		   := "" 
Local lVerLib	   := LojxVerLib()
Local aStruSB1	   := SB1->(DbStruct())

DEFAULT cFabric  := ""
DEFAULT cGrupo   := ""
DEFAULT cTipo    := ""
DEFAULT nOpFab   := 0
DEFAULT nOpGru   := 0
DEFAULT nOpTip   := 0
DEFAULT nOpCod   := 0
DEFAULT nOpDes   := 0
DEFAULT cProdut  := ""
DEFAULT cDescPr  := ""
DEFAULT aLbx     := {}
DEFAULT cline    := ""

DbSelectArea("SB1")

Aadd(aInsert,RetSqlName("SB1"))
nIniLoopPS++
Aadd(aInsert,xFilial("SB1")   )
For nX := 1 To Len(aStruSB1)
	cQuery += ",SB1."+aStruSB1[nX][1]
Next nX
cQuery := "SELECT "+SubStr(cQuery,2)+" "
cQuery += " FROM ? SB1 "
cQuery += " WHERE SB1.B1_FILIAL = ?" 

//Filtro por Fabricante
If Len(AllTrim(cFabric)) > 0
	cFabric := StrTran(Alltrim(cFabric),"'","''")
	cQuery  += " AND "
	cQuery  += " SB1.B1_FABRIC LIKE '"+'%'+AllTrim(cFabric)+'%'+"'"
EndIf

//Filtro por Codigo
If Len(AllTrim(cProdut)) > 0
	cProdut := StrTran(Alltrim(cProdut),"'","''")
	cQuery  += " AND "
	cQuery  += " SB1.B1_COD LIKE '"+'%'+AllTrim(cProdut)+'%'+"'"
EndIf

//Filtro por Descricao	
If Len(AllTrim(cDescPr)) > 0
	If "*" $ cDescPr
		cDescPr := StrTran(Alltrim(cDescPr),"'","''")
        cTemppp := cDescPr
        While "*" $ cTemppp
            nAtt    := At("*",cTemppp)
            cQuery  += " AND "
            cQuery  += " SB1.B1_DESC LIKE '" + '%' +AllTrim(Substr(cTemppp,1,nAtt-1))+'%' + "'"
            cTemppp := Substr(cTemppp,nAtt+1)
        End
        If !Empty(cTemppp)
            cQuery  += " AND "
            cQuery  += " SB1.B1_DESC LIKE '" + '%' +AllTrim(cTemppp)+'%' + "'"
        EndIf
	Else
		cDescPr := StrTran(Alltrim(cDescPr),"'","''")
		cQuery  += " AND "
		cQuery  += " SB1.B1_DESC LIKE '" + '%'+ AllTrim(cDescPr)+ '%' + "'"	
	EndIf
EndIf
Aadd(aInsert,'1')
cQuery  += " AND SB1.B1_MSBLQL != ?"
Aadd(aInsert," ")
cQuery  += " AND SB1.D_E_L_E_T_ = ?"
cQuery  += " ORDER BY "+SqlOrder(SB1->(IndexKey()))

nLen := Len(aInsert)
cMD5 := MD5(cQuery) 
If (nPosPrepared := Ascan(__aPrepared,{|x| x[2] == cMD5})) == 0 
	cQuery := ChangeQuery(cQuery)
	Aadd(__aPrepared,{IIf(lVerLib,FwExecStatement():New(cQuery),FWPreparedStatement():New(cQuery)),cMD5})
	nPosPrepared := Len(__aPrepared)
Endif 
__aPrepared[nPosPrepared][1]:SetUnsafe(1,aInsert[1])

For nX := nIniLoopPS To nLen
	__aPrepared[nPosPrepared][1]:SetString(nX,aInsert[nX])
Next 

If lVerLib
	__aPrepared[nPosPrepared][1]:OpenAlias(cSb1Alias)
	Dbselectarea(cSb1Alias)
EndIf
aInsert := aSize(aInsert,0)
			
For nX := 1 To Len(aStruSB1)
	If aStruSB1[nX][2]<>"C"
		TcSetField(cSb1Alias,aStruSB1[nX][1],aStruSB1[nX][2],aStruSB1[nX][3],aStruSB1[nX][4])
	EndIf
Next nX

MsgRun(STR0012,STR0013,{||MontaArray(.F.,@aLbx,@cline,cSb1Alias)}) //"Carregando" ### "Aguarde"

If Select(cSb1Alias) <> 0 
	(cSb1Alias)->(DbCloseArea())
EndIf

DbSelectArea("SB1")

oLbx:SetArray(aLbx)
oLbx:bLine := &(cline)

Return .T.

//-------------------------------------------------------------------
/*{Protheus.doc} MontaArray

@param   
@author  Varejo
@version P11.8
@since   08/04/2014
@return  lRet -	Se encontrou produtos ou nao
@obs     
@sample
*/
//-------------------------------------------------------------------
Static Function MontaArray(lVazioB1,aLbx,cline,cSb1Alias)

Local j := 0                                // Contador
Local i := 0                                // Contador
Local aDbfB1 := {{"B1_COD"  ,"C",15,0},; 	
			    {"B1_DESC"  ,"C",30,0},; 	
			    {"B1_FABRIC","C",20,0}} 	// Array de campos
			    
DEFAULT lVazioB1 := .F.
DEFAULT aLbx     := {}
DEFAULT cline    := ""
	
aFields := (cSb1Alias)->(DbStruct())

aLbx:={}
cLine := "{ || { "
i     := 0
aAux  := {}
If lVazioB1
	Aadd(aLbx,{"","","","",""})
Else
	(cSb1Alias)->(DbGotop())
	While (cSb1Alias)->(!Eof())
		aAux := Array(Len(aDbfB1))
		For j := 1 to Len(aDbfB1)
			aAux[j] := &(aDbfB1[j][1])
		Next j
		Aadd(aLbx,aAux)
		(cSb1Alias)->(DbSkip())
	End
EndIf

nTAMB := Len(aLbx)

// Define o numero de colunas do listbox
For i:=1 To Len(aDbfB1)
	If aDbfB1[i][2] == "D"
		cLine+= "DtoC(aLbx[oLbx:nAt,"+Alltrim(str(i,2))+"])"
	ElseIf aDbfB1[i][2] == "N"
		cLine+= "Str(aLbx[oLbx:nAt,"+Alltrim(str(i,2))+"])"
	Else
		cLine+= "aLbx[oLbx:nAt,"+Alltrim(str(i,2))+"]"
	EndIf
	If i#Len(aDbfB1)
		cLine+=","
	Else
		cLine+="}"
	EndIf
Next i

cLine+= "}"

Return .T.

//-------------------------------------------------------------------
/*{Protheus.doc} LimpaCampos
Limpa os campos de filtro

@param   
@author  Varejo
@version P11.8
@since   08/04/2014
@return  lRet -	Se encontrou produtos ou nao
@obs     
@sample
*/
//-------------------------------------------------------------------
Static Function LimpaCampos( cFabric, cGrupo, cTipo, cProdut, cDescPr )

	cFabric := Space( 40 ) 
	cGrupo  := Space( 4 )
	cTipo   := Space( 2 )
 	cProdut := Space( 15 )
	cDescPr := Space( 40 )
	
Return .T.

//-------------------------------------------------------------------
/*{Protheus.doc} LUZRET
Retorno da consulta

@param   
@author  Varejo
@version P11.8
@since   08/04/2014
@return  lRet -	Se encontrou produtos ou nao
@obs     
@sample
*/
//-------------------------------------------------------------------
Function STPesqRetVA()
Local cRet := cProdSelected
 
Return cRet

/*/{Protheus.doc} LojxVerLib
Função utilizada para validar a data da LIB para utilização da classe FWExecStatement

@type       Function
@author     Varejo (Leonardo Miranda)
@since      Jun/2024
@version    12.1.2310
@return     __lLojxlib retorna lógico quando a data da lib for superior a 16/11/2021
/*/
Static Function LojxVerLib()

Static __lLojxlib := Nil

If __lLojxlib == Nil 
	__lLojxlib := FWLibVersion() >= "20211116"
EndIf

Return __lLojxlib
