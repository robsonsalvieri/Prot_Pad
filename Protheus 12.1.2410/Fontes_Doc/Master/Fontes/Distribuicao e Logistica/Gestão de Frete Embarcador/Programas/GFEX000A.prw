#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//-----------------------------------------------------
/*/Filial x Emitente
@author Felipe Machado de Oliveira
@version P11
@since 26/08/2013
/*/
//------------------------------------------------------
Function GFEX000A()
	Local aSize := {}
	Local aHeader := {}
	Local aCols := {}
	Local nX := 0
	Local aButtons := {}
	Local cLinOk := "AllwaysTrue"
	Local cTudoOk := "AllwaysTrue"
	Local nFreeze := 000
	Local nMax := 999
	Local cFieldOk := "GFEXLINOK"
	Local cSuperDel := ""
	Local cDelOk := "AllwaysFalse"
	Local oSize
	Private oDlg := Nil
	Private oGetD
	
	aSize := MsAdvSize(.F.)
	
	SelDados(@aHeader,@aCols,.F.)
	oDlg := MSDIALOG():New((aSize[7] * 0.5),0,(aSize[6] * 0.5),(aSize[5] * 0.5), "Filial x Emitentes",,,,,,,,,.T.)
	
	oSize := FWDefSize():New(.T.,,,oDlg)
	oSize:AddObject( "Panel1", 100, 100, .T., .T. ) //Panel 1 em 50% da tela
	oSize:lProp := .T. //permite redimencionar as telas de acordo com a proporção do AddObject		
	oSize:Process() //executa os calculos
	
	oPanel1:= tPanel():New(oSize:GetDimension("Panel1","LININI"),; 
	                       oSize:GetDimension("Panel1","COLINI"),;
	                       "Panel1",oDlg,,,,,,;
	                       oSize:GetDimension("Panel1","XSIZE"),;
	                       oSize:GetDimension("Panel1","YSIZE"))
	                       		
		RegToMemory("GW0", .T.)
		oGetD:= MsNewGetDados():New(000,000,(aSize[6] * 0.22),(aSize[5] * 0.25), GD_UPDATE, cLinOk, cTudoOk, "", {"CODEMIT"}, nFreeze, nMax, cFieldOk, cSuperDel, cDelOk, oPanel1, aHeader, aCols)
	
		oGetD:oBrowse:lUseDefaultColors := .F.
		oGetD:oBrowse:SetBlkBackColor({|| GETDCLR(oGetD:aCols,oGetD:nAt,aHeader)})
	
	oDlg:bInit := {|| EnchoiceBar(oDlg, {|| IIF( GFEX000ACF(oGetD:aCols),oDlg:End(),Nil )  }, {||oDlg:End()},,aButtons)}
	oDlg:lCentered := .T.
	oDlg:Activate()
		
Return ( Nil )
//-----------------------------------------------------
/*/Seleciona as filiais
@author Felipe Machado de Oliveira
@version P11
@since 17/07/2013
/*/
//------------------------------------------------------
Static Function SelDados(aHeader,aCols,lRefresh)
Local aAreaGW0 := GW0->( GetArea() )
Local nX := 1
Local aFil := GFEGETFIL(cEmpAnt)
Local nPos := 1

CursorWait()

dbSelectArea("GW0")
GW0->( dbSetOrder(1) )
For nX := 1 to Len(aFil)
	GW0->( dbSeek( Space(TamSx3("GW0_FILIAL")[1])+PadR( "FILIALEMIT",TamSx3("GW0_TABELA")[1] )+aFil[nX][1] ) )
	If !(GW0->( !EOF() ) .And. GW0->GW0_FILIAL == Space(TamSx3("GW0_FILIAL")[1]);
							.And. AllTrim(GW0->GW0_TABELA) == "FILIALEMIT";
							.And. AllTrim(GW0->GW0_CHAVE) == AllTrim(aFil[nX][1]))
		RecLock("GW0", .T.)
		GW0->GW0_TABELA := "FILIALEMIT"
		GW0->GW0_CHAVE  := aFil[nX][1]
		GW0->GW0_CHAR01 := ""
		GW0->(MsUnlock())
		GW0->(DbCommit())
	EndIf
Next nX

aAdd(aHeader,{ "Cod. Filial"  , "CODFIL" , "",TamSx3("GU3_FILIAL")[1], 0,"AllwaysTrue()",, "C", "GW0", } )
aAdd(aHeader,{ "Nome Filial"  , "NOMFIL ", "",Len(aFil[1][2]), 0,"AllwaysTrue()",, "C", "GW0", } )
aAdd(aHeader,{ "Cod. Emitente", "CODEMIT", "",TamSx3("GU3_CDEMIT")[1], 0,"AllwaysTrue()",, "C", "GU3", } )

nX := 1

dbSelectArea("GW0")
GW0->( dbSeek( Space(TamSx3("GW0_FILIAL")[1])+PadR( "FILIALEMIT",TamSx3("GW0_TABELA")[1] )) )
While !GW0->( EOF() ) .And. GW0->GW0_FILIAL == Space(TamSx3("GW0_FILIAL")[1]);
						  .And. GW0->GW0_TABELA == PadR( "FILIALEMIT",TamSx3("GW0_TABELA")[1] )
	
	nPos := aScan( aFil, {|x| AllTrim(x[1]) == AllTrim(GW0->GW0_CHAVE) } )

	If nPos > 0
		aAdd(aCols, { SubStr(GW0->GW0_CHAVE,1,TamSx3("GW0_FILIAL")[1]),;
		 				aFil[nPos][2],;
		 				SubStr(GW0->GW0_CHAR01,1,TamSx3("GU3_CDEMIT")[1]),;
		 				.F.} )
	Else
		RecLock("GW0",.F.)
		GW0->(dbdelete())
		GW0->(MsUnlock())
		GW0->(DbCommit())
	EndIf
	nX++
	GW0->( dbSkip() )
EndDo

CursorArrow()

RestArea( aAreaGW0 )

Return .T.
//-----------------------------------------------------
/*/ Função para tratamento das regras de cores para a grid da MsNewGetDadosStatic
@author Felipe Machado de Oliveira
@version P11
@since 28/08/2013
/*/
//------------------------------------------------------
Function GETDCLR(aLinha,nLinha,aHeader)
Local nCor2 := 16776960 // Ciano - RGB(0,255,255)
Local nCor3 := 16777215 // Branco - RGB(255,255,255)
Local nPosProd := aScan( aHeader,{|x| Alltrim(x[2]) == "CODFIL"} )
Local nRet := nCor3

If !Empty(aLinha[nLinha][nPosProd]) .And. aLinha[nLinha][4]
	nRet := nCor2
ElseIf !Empty(aLinha[nLinha][nPosProd]) .And. !aLinha[nLinha][4]
	nRet := nCor3
Endif

Return nRet
//-----------------------------------------------------
/*/ Confimação
@author Felipe Machado de Oliveira
@version P11
@since 28/08/2013
/*/
//------------------------------------------------------
Function GFEX000ACF(aCols)
Local aAreaGW0 := GW0->( GetArea() )
Local nX := 1

	For nX := 1 to Len(aCols)

		If !Empty(aCols[nX][3])
			dbSelectArea("GW0")
			GW0->( dbSeek( Space(TamSx3("GW0_FILIAL")[1])+PadR( "FILIALEMIT",TamSx3("GW0_TABELA")[1])+aCols[nX][1] ))
			If !GW0->( EOF() ) .And. GW0->GW0_FILIAL == Space(TamSx3("GW0_FILIAL")[1]);
						  	  	.And. GW0->GW0_TABELA == PadR( "FILIALEMIT",TamSx3("GW0_TABELA")[1] );
					  	  	  	.And. GW0->GW0_CHAVE == PadR( aCols[nX][1],TamSx3("GW0_CHAVE")[1] );

				RecLock("GW0", .F.)
				GW0->GW0_CHAR01 := aCols[nX][3]
				MsUnlock()
				GW0->(DbCommit())

			EndIf
		EndIf

	Next nX


RestArea( aAreaGW0 )

Return .T.
//-----------------------------------------------------
/*/Validação do Emitente
@author Felipe Machado de Oliveira
@version P11
@since 28/08/2013
/*/
//------------------------------------------------------
Function GFEXLINOK(nLinha,cEmitente)
Local aAreaGU3 := GU3->( GetArea() )
Local lFieldOK := .T.
Local cAliasGU3 := GetNextAlias()

Default nLinha := oGetD:nAt
Default cEmitente := GDFieldGet( "CODEMIT",nLinha,.T. ) 

cQuery := "SELECT GU3_EMFIL, GU3_SIT FROM "+RetSqlName("GU3")
cQuery += " WHERE GU3_FILIAL = '"+xFilial("GU3")+"' " 
cQuery += "   AND GU3_CDEMIT = '"+PadR( cEmitente,TamSx3("GU3_CDEMIT")[1] )+"' "
cQuery += "   AND GU3_ORIGEM = '2' "
cQuery += "   AND D_E_L_E_T_ = ' '"

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasGU3,.T.,.T.)

(cAliasGU3)->(dbGoTop())
If (cAliasGU3)->(!Eof())

	If (cAliasGU3)->GU3_EMFIL != "1" .Or. (cAliasGU3)->GU3_SIT != "1" 
		lFieldOK := .F.
		Help( ,, 'HELP',, "Emitente não é Filial ou não está Ativo. ("+AllTrim(cEmitente)+")", 1, 0)
	EndIf
	
Else
	lFieldOK := .F.
	Help( ,, 'HELP',, "Emitente não existe ou não teve o cadastro com origem no ERP. ("+AllTrim(cEmitente)+")", 1, 0)
EndIf
(cAliasGU3)->(dbCloseArea())
RestArea( aAreaGU3 )

Return lFieldOK
//-----------------------------------------------------
/*/ Validação se todos os dados estao OK
@author Felipe Machado de Oliveira
@version P11
@since 28/08/2013
/*/
//------------------------------------------------------
Function GFEXTUDOOK(aCols)
Local lTudoOk := .T.
Local nX := 1

For nX := 1 To Len(aCols)
	If !Empty(aCols[nX][3]) .And. !GFEXLINOK(nX,aCols[nX][3])
		lTudoOk := .F.
		Exit
	EndIf
Next nX

Return lTudoOk
