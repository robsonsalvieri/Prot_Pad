// ษออออออออหออออออออป
// บ Versao บ 13     บ
// ศออออออออสออออออออผ

#Include "PROTHEUS.CH"
#Include "VEIXX008.CH"
#Include "TOPCONN.CH"

/*/{Protheus.doc} mil_ver()
    Versao do fonte modelo novo

    @author Andre Luis Almeida
    @since  25/10/2017
/*/
Static Function mil_ver()
	If .F.
		mil_ver()
	EndIf
Return "007322_1"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ VEIXX008 บ Autor ณ Andre Luis Almeida บ Data ณ  13/04/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Veiculo Usado na Troca (VAZ-Avaliacoes de Veiculos)        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ nOpc (2-Visualizar/4-Alterar/3-Incluir)                    บฑฑ
ฑฑบ          ณ aParUsa (Nro do Atendimento)                               บฑฑ
ฑฑบ			 ณ	 aParUsa[1] = Nro do Atendimento                          บฑฑ
ฑฑบ			 ณ	 aParUsa[2] = Moeda do Atendimento                        บฑฑ
ฑฑบ          ณ aVS9 (Pagamentos)                                          บฑฑ
ฑฑบ			 ณ	 aVS9[1] = aHeader VS9                                    บฑฑ
ฑฑบ			 ณ	 aVS9[2] = aCols VS9                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Veiculos -> Novo Atendimento                               บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function VEIXX008(nOpc,aParUsa,aVS9)
Local aObjects  := {} , aPos := {} , aInfo := {}
Local aSizeHalf := MsAdvSize(.t.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local lRet      := .f.
Local cNroAte   := aParUsa[1]
Local cAux      := ""
Local cSEQUEN   := ""
Local nPos      := 0
Local ni        := 0
Local nCntFor   := 1
Local cQuery    := ""
Local cQAlVAZ   := "SQLVAZ"
Local cQAlVVA   := "SQLVVA"
Local aVVAs     := {}
Local nOpcao    := 0
Local aRedVeic	:= {} //array contendo informacoes para o redutor
Local lCkAprova := .t.
Local lCkNaoApr := .t.
Local lCkJaUtil := ( nOpc <> 3 ) // Diferente de Incluir
Local lDblClick := .f.
Local cTpVTroca := FM_SQL("SELECT VSA.VSA_TIPPAG FROM "+RetSQLName("VSA")+" VSA WHERE VSA.VSA_FILIAL='"+xFilial("VSA")+"' AND VSA.VSA_TIPO='4' AND VSA.D_E_L_E_T_=' '") // VSA_TIPO='4' ( Veiculos Usados )
Local dDtTit    := ( dDataBase + FM_SQL("SELECT VSA.VSA_DIADEF FROM "+RetSQLName("VSA")+" VSA WHERE VSA.VSA_FILIAL='"+xFilial("VSA")+"' AND VSA.VSA_TIPPAG='"+cTpVTroca+"' AND VSA.D_E_L_E_T_=' '") )
Local cCor      := ""
Local lManut    := FM_PILHA("VEIXX019") // Esta na TELA de Manutencao do Atendimento
//
Local cBkpFilAnt := cFilAnt
Local lVAZComp  := .t.
Local cFilVS9   := ""
Local aFilAtu   := FWArrFilAtu()
Local aSM0      := FWAllFilial( aFilAtu[3] , aFilAtu[4] , aFilAtu[1] , .f. )
//
Local lCkCtrSld := .f.
Local nValorUti := 0
Local nValorCom := 0
Local lVAZCTRSLD := ( cPaisLoc == "BRA" .and. VAZ->(FieldPos("VAZ_CTRSLD")) > 0 ) // Controle de SALDO somente no BRASIL
Local lMultMoeda := FGX_MULTMOEDA() // Trabalha com MultMoeda ?
Local cSimbMoeda := ""
//
Private oOk     := LoadBitmap( GetResources(), "LBTIK" )
Private oNo     := LoadBitmap( GetResources(), "LBNO" )
Private overde  := LoadBitmap( GetResources(), "BR_verde")
Private ocinza  := LoadBitmap( GetResources(), "BR_cinza")
Private overme  := LoadBitmap( GetResources(), "BR_vermelho")
Private aVEITroc:= {}
Private aVEITTot:= {}
Private cObserv := ""
Private cPPlaca := space(len(VV1->VV1_PLAVEI))
Private cPChassi:= space(len(VV1->VV1_CHASSI))
Private cPCodCli:= space(9)
Private cPNomCli:= space(25)
Private aComboP := {STR0002,STR0003,STR0004,STR0005} // Placa / Chassi / Cod.Cliente / Nome Cliente
Private cComboP := STR0002 // Placa
Private aHeaderVS9 := aClone(aVS9[1])
If !Empty(aParUsa[1])
	DbSelectArea("VV9")
	DbSetOrder(1)
	DbSeek(xFilial("VV9")+aParUsa[1])
	DbSelectArea("VV0")
	DbSetOrder(1)
	DbSeek(xFilial("VV0")+aParUsa[1])
	cQuery := "SELECT VVA_CHASSI "
	cQuery += "  FROM "+RetSqlName("VVA")
	cQuery += " WHERE VVA_FILIAL = '"+VV9->VV9_FILIAL+"'"
	cQuery += "   AND VVA_NUMTRA = '"+VV9->VV9_NUMATE+"'"
	cQuery += "   AND VVA_CHASSI <> ' '"
	cQuery += "   AND D_E_L_E_T_ = ' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVVA , .F., .T. )
	While !( cQAlVVA )->( Eof() )
		AAdd( aVVAs , Alltrim(( cQAlVVA )->( VVA_CHASSI )) )
		( cQAlVVA )->( DbSkip() )
	EndDo
	( cQAlVVA )->( dbCloseArea() )
	DbSelectArea("VVA")
EndIf
If nOpc == 3 .or. nOpc == 4 // Incluir / Alterar
	lDblClick := .t.
	If Empty(cTpVTroca)
		MsgStop(STR0007,STR0006) // Impossivel continuar! Nao existe Tipo de Pagamento relacionado a Avaliacoes de Veiculos Usados. / Atencao
		Return lRet
	EndIf
EndIf
If lMultMoeda
	cSimbMoeda := GETMV("MV_SIMB"+Alltrim(str(IIf(aParUsa[2]>0,aParUsa[2],1))))
EndIf
// Fator de reducao 80%
For nCntFor := 1 to Len(aSizeHalf)
	aSizeHalf[nCntFor] := INT(aSizeHalf[nCntFor] * 0.8)
Next
aInfo := { aSizeHalf[ 1 ], aSizeHalf[ 2 ],aSizeHalf[ 3 ] ,aSizeHalf[ 4 ], 3, 3 } // Tamanho total da tela
// Configura os tamanhos dos objetos
aObjects := {}
AAdd( aObjects, { 0, 25, .T. , .F. } ) // Pesquisar
AAdd( aObjects, { 0,  0, .T. , .T. } ) // ListBox
AAdd( aObjects, { 0, 30, .T. , .F. } ) // Observacao
aPos := MsObjSize( aInfo, aObjects )
//
cAux := xFilial("VAZ")
cFilVS9 := ""
For nCntFor := 1 to Len(aSM0)
	cFilAnt := aSM0[nCntFor]
	If cAux <> xFilial("VAZ") // Verifica se o VAZ nao eh compartilhado
		lVAZComp := .f.
	EndIf
	cFilVS9 += "'"+xFilial("VS9")+"',"
Next
cFilVS9 := left(cFilVS9,len(cFilVS9)-1)
cFilAnt := cBkpFilAnt
//
cQuery := "SELECT TEMP.*, VAZ2.*, "
If lVAZCTRSLD
	cQuery += " VAZ2.VAZ_CTRSLD AS VAZ_CTRSLD "
Else
	cQuery += " ' ' AS VAZ_CTRSLD "
EndIf
cQuery += 	"FROM ( SELECT VAZ_CHASSI, MAX(VAZ_REVISA) VAZ_REVISA FROM "+RetSqlName("VAZ")+" VAZ "
cQuery += 			"WHERE VAZ.VAZ_FILIAL='"+xFilial("VAZ")+"' AND VAZ.D_E_L_E_T_=' ' "
cQuery += 			"GROUP BY VAZ_CHASSI ) TEMP "
cQuery += 	"JOIN "+RetSqlName("VAZ")+" VAZ2 ON VAZ2.VAZ_FILIAL='"+xFilial("VAZ")+"' AND VAZ2.VAZ_CHASSI=TEMP.VAZ_CHASSI AND VAZ2.VAZ_REVISA=TEMP.VAZ_REVISA AND VAZ2.D_E_L_E_T_=' '"

dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVAZ, .F., .T. )
Do While !( cQAlVAZ )->( Eof() )
	cAux := VX0080055_AtendimentodaAvaliacao( ( cQAlVAZ )->( VAZ_CTRSLD ), ( cQAlVAZ )->( VAZ_CODIGO ) , ( cQAlVAZ )->( VAZ_NUMATE ), ( cQAlVAZ )->( VAZ_OCOMEM ) )
	If ( ( cQAlVAZ )->( VAZ_APROVA ) <> '2' .or. Alltrim(cNroAte) $ cAux ) .and. Ascan(aVVAs,Alltrim(( cQAlVAZ )->( VAZ_CHASSI ))) == 0
		SA1->(DbSetOrder(1))
		SA1->(DbSeek( xFilial("SA1") + ( cQAlVAZ )->( VAZ_CODCLI ) + ( cQAlVAZ )->( VAZ_LOJCLI ) ))
		VV2->(DbSetOrder(1))
		VV2->(DbSeek( xFilial("VV2") + ( cQAlVAZ )->( VAZ_CODMAR ) + ( cQAlVAZ )->( VAZ_MODVEI ) ))
		cCor := IIf(Empty(( cQAlVAZ )->( VAZ_NUMATE )) .or. ( ( cQAlVAZ )->( VAZ_CTRSLD ) == "1" .and. ( cQAlVAZ )->( VAZ_SLDDIS ) > 0 ) ,IIf(( cQAlVAZ )->( VAZ_APROVA )=="1","verde","verme"),"cinza")
		nValorUti := VX0080045_ValorUtilizado(( cQAlVAZ )->( VAZ_CODIGO ),( cQAlVAZ )->( VAZ_CTRSLD ) , cFilAnt, cNroAte , IIf(lMultMoeda,aParUsa[2],1) )
		If lMultMoeda .and. aParUsa[2] == 2 // Moeda 2
			nValorCom := ( cQAlVAZ )->( VAZ_VALCO2 )
		Else
			nValorCom := ( cQAlVAZ )->( VAZ_VALCOM )
		EndIf
		Aadd(aVEITroc,{ .f. , cCor , ( cQAlVAZ )->( VAZ_CHASSI ) , ( cQAlVAZ )->( VAZ_CODCLI )+( cQAlVAZ )->( VAZ_LOJCLI ) , ( cQAlVAZ )->( VAZ_CODMAR )+" "+VV2->VV2_DESMOD , nValorCom , Transform(stod(( cQAlVAZ )->( VAZ_DATAVA )),"@D")+" "+UsrRetName(( cQAlVAZ )->( VAZ_CUSAVA )) , cAux , ( cQAlVAZ )->( VAZ_CODIGO ) , left(SA1->A1_NOME,25) , ( cQAlVAZ )->( VAZ_PLAVEI ) , 0 , cCor , ( cQAlVAZ )->( VAZ_FABMOD ),( cQAlVAZ )->( R_E_C_N_O_ ) , ( cQAlVAZ )->( VAZ_FILATE ), ( cQAlVAZ )->( VAZ_CTRSLD ), If(( cQAlVAZ )->( VAZ_CTRSLD ) == "1", ( cQAlVAZ )->( VAZ_SLDDIS ), nValorCom - nValorUti ), nValorUti })
		If Alltrim(cNroAte) $ cAux
			If lManut .and. ( cQAlVAZ )->( VAZ_APROVA ) == '2' .or. aVEITroc[len(aVEITroc),2] <> "verde"
				aVEITroc[len(aVEITroc),2] := "verde"
			EndIf
		EndIf
	EndIf
	( cQAlVAZ )->( DbSkip() )
EndDo
( cQAlVAZ )->( dbCloseArea() )
If len(aVEITroc) <= 0
	Aadd(aVEITroc,{ .f. , "verme" , "" , "" , "" , 0 , "  /  /  " , "" , "" , "" , "" , 0 , "verme" , "" , 0 , "", "", 0 , 0 })
EndIf
For ni := 1 to len(aVS9[2]) // Selecionar Avaliacoes de Usados ja utilizadas neste Atendimento
	If !aVS9[2,ni,len(aVS9[2,ni])]
		If aVS9[2,ni,FG_POSVAR("VS9_TIPPAG","aHeaderVS9")] == cTpVTroca
			nPos := aScan(aVEITroc,{|x| Alltrim(aVS9[2,ni,FG_POSVAR("VS9_REFPAG","aHeaderVS9")]) == Alltrim(x[9]) }) // VS9.VS9_REFPAG == VAZ.VAZ_CODIGO
			If nPos > 0
				aVEITroc[nPos,01] := .t. // selecionar registro
				aVEITroc[nPos,12] := ni  // posicao do aCols do VS9
			EndIf
		EndIf
	EndIf
Next
aSort(aVEITroc,1,,{|x,y| x[12] > y[12] }) // Ordena Vetor para deixar os selecionados no Atendimento em Primeiro no ListBox
aVEITTot := aClone(aVEITroc)
If nOpc == 3 // Incluir -> Nao Mostrar Avaliacoes ja Utilizadas em outros Atendimentos
	FS_FILTR008(lCkAprova,lCkNaoApr,lCkJaUtil,.f.,lCkCtrSld)
EndIf
FS_OBSERV(1)
DbSelectArea("VS9")
DEFINE MSDIALOG oVEITroca TITLE STR0001 FROM aSizeHalf[7],0 TO aSizeHalf[6],aSizeHalf[5] OF oMainWnd PIXEL // Avaliacao de Veiculos Usados
oVEITroca:lEscClose := .F.
@ aPos[1,1]+04,aPos[1,2]+000 TO aPos[2,1]-2,050 LABEL STR0008 OF oVEITroca PIXEL // Aprovada
@ aPos[1,1]+13,aPos[1,2]+013 CHECKBOX oCkAprova VAR lCkAprova PROMPT "" OF oVEITroca ON CLICK FS_FILTR008(lCkAprova,lCkNaoApr,lCkJaUtil,.t.,lCkCtrSld) SIZE 08,08 PIXEL WHEN lDblClick
@ aPos[1,1]+14,aPos[1,2]+025 BITMAP OXverde RESOURCE "BR_verde" OF oVEITroca NOBORDER SIZE 10,10 PIXEL
@ aPos[1,1]+04,aPos[1,2]+052 TO aPos[2,1]-2,102 LABEL STR0009 OF oVEITroca PIXEL // Nao Aprovada
@ aPos[1,1]+13,aPos[1,2]+065 CHECKBOX oCkNaoApr VAR lCkNaoApr PROMPT "" OF oVEITroca ON CLICK FS_FILTR008(lCkAprova,lCkNaoApr,lCkJaUtil,.t.,lCkCtrSld) SIZE 08,08 PIXEL WHEN lDblClick
@ aPos[1,1]+14,aPos[1,2]+077 BITMAP OXverme RESOURCE "BR_vermelho" OF oVEITroca NOBORDER SIZE 10,10 PIXEL
@ aPos[1,1]+04,aPos[1,2]+104 TO aPos[2,1]-2,154 LABEL STR0010 OF oVEITroca PIXEL // Ja utilizada
@ aPos[1,1]+13,aPos[1,2]+117 CHECKBOX oCkJaUtil VAR lCkJaUtil PROMPT "" OF oVEITroca ON CLICK FS_FILTR008(lCkAprova,lCkNaoApr,lCkJaUtil,.t.,lCkCtrSld) SIZE 08,08 PIXEL WHEN lDblClick
@ aPos[1,1]+14,aPos[1,2]+129 BITMAP OXcinza RESOURCE "BR_cinza" OF oVEITroca NOBORDER SIZE 10,10 PIXEL
oLbVEITroc := TWBrowse():New(aPos[2,1],aPos[2,2],aPos[2,4]-aPos[2,2],aPos[2,3]-aPos[2,1],,,,oVEITroca,,,,{ || FS_OBSERV(2) },{ || IIf(lDblClick,FS_CLICK008(oLbVEITroc:nAt,cNroAte,aVS9),.t.) },,,,,,,.F.,,.T.,,.F.,,,)
oLbVEITroc:addColumn( TCColumn():New( ""  , { || IIf(aVEITroc[oLbVEITroc:nAt,1],oOk,oNo) } ,,,,"LEFT" , 08,.T.,.F.,,,,.F.,) ) // Tik
oLbVEITroc:addColumn( TCColumn():New( ""  , { || IIf(aVEITroc[oLbVEITroc:nAt,2]<>"cinza",IIf(aVEITroc[oLbVEITroc:nAt,2]=="verde",overde,overme),ocinza) }         ,,,,"LEFT" , 08,.T.,.F.,,,,.F.,) ) // Cor
oLbVEITroc:addColumn( TCColumn():new( STR0002 , { || Transform(aVEITroc[oLbVEITroc:nAt,11],VV1->(x3Picture("VV1_PLAVEI"))) }                                ,,,,"LEFT" , 45,.F.,.F.,,,,.F.,) ) // Placa
oLbVEITroc:addColumn( TCColumn():new( STR0003 , { || aVEITroc[oLbVEITroc:nAt,3] }                                ,,,,"LEFT" , 70,.F.,.F.,,,,.F.,) ) // Chassi
oLbVEITroc:addColumn( TCColumn():new( STR0011 , { || left(aVEITroc[oLbVEITroc:nAt,4],6)+"-"+right(aVEITroc[oLbVEITroc:nAt,4],2)+" "+aVEITroc[oLbVEITroc:nAt,10] }          ,,,,"LEFT" , 90,.F.,.F.,,,,.F.,) ) // Cliente
oLbVEITroc:addColumn( TCColumn():new( STR0012 , { || aVEITroc[oLbVEITroc:nAt,5] }          ,,,,"LEFT" , 100,.F.,.F.,,,,.F.,) ) // Marca/Modelo
oLbVEITroc:addColumn( TCColumn():new( STR0013 , { || Transform(aVEITroc[oLbVEITroc:nAt,14],VV1->(x3Picture("VV1_FABMOD"))) }          ,,,,"LEFT" , 40,.F.,.F.,,,,.F.,) ) // Fab/Mod
oLbVEITroc:addColumn( TCColumn():new( STR0014 , { || cSimbMoeda+Transform(aVEITroc[oLbVEITroc:nAt,6],"@E 9999,999,999.99") }         ,,,,"RIGHT", 55,.F.,.F.,,,,.F.,) ) // Valor Compra
If cPaisLoc == "BRA"
	oLbVEITroc:addColumn( TCColumn():new( STR0025 , { || Transform(aVEITroc[oLbVEITroc:nAt,18],"@E 9999,999,999.99") }         ,,,,"RIGHT", 55,.F.,.F.,,,,.F.,) ) // Saldo Disponivel
	oLbVEITroc:addColumn( TCColumn():new( STR0026 , { || Transform(aVEITroc[oLbVEITroc:nAt,19],"@E 9999,999,999.99") }         ,,,,"RIGHT", 55,.F.,.F.,,,,.F.,) ) // Valor a Utilizar
EndIf
oLbVEITroc:addColumn( TCColumn():new( STR0015 , { || aVEITroc[oLbVEITroc:nAt,7] }                                ,,,,"LEFT" ,70,.F.,.F.,,,,.F.,) ) // Avalia็ใo
oLbVEITroc:nAT := 1
oLbVEITroc:SetArray(aVEITroc)
@ aPos[3,1],aPos[3,2] GET oObserv VAR cObserv OF oVEITroca MEMO SIZE aPos[3,4]-2,030 PIXEL READONLY MEMO
@ aPos[1,1]+11,163 SAY STR0016 SIZE 80,10 OF oVEITroca  PIXEL COLOR CLR_BLUE // Pesquisa:
@ aPos[1,1]+10,192 MSCOMBOBOX oComboP VAR cComboP ITEMS aComboP VALID (FS_PESQUISA(1),FS_PESQUISA(2)) SIZE 48,07 OF oVEITroca PIXEL COLOR CLR_BLUE WHEN lDblClick
@ aPos[1,1]+10,242 MSGET oPPlaca  VAR cPPlaca  PICTURE VV1->(x3Picture("VV1_PLAVEI")) SIZE 100,08 OF oVEITroca PIXEL COLOR CLR_BLUE WHEN lDblClick
@ aPos[1,1]+10,242 MSGET oPChassi VAR cPChassi PICTURE "@!" F3 "VV1" SIZE 100,08 OF oVEITroca PIXEL COLOR CLR_BLUE WHEN lDblClick
@ aPos[1,1]+10,242 MSGET oPCodCli VAR cPCodCli PICTURE "@R 999999-99" F3 "SA1" SIZE 100,08 OF oVEITroca PIXEL COLOR CLR_BLUE WHEN lDblClick
@ aPos[1,1]+10,242 MSGET oPNomCli VAR cPNomCli PICTURE "@!" SIZE 100,08 OF oVEITroca PIXEL COLOR CLR_BLUE WHEN lDblClick
oPChassi:lVisible := .f.
oPCodCli:lVisible := .f.
oPNomCli:lVisible := .f.
@ aPos[1,1]+11,347 BUTTON oPesquisar PROMPT STR0017 OF oVEITroca SIZE 30,09 PIXEL ACTION (FS_PESQUISA(3),FS_OBSERV(2)) WHEN lDblClick // Pesquisar
If cPaisLoc == "BRA"
	@ aPos[1,1]+12,387 CHECKBOX oCkCtrSld VAR lCkCtrSld PROMPT STR0027 OF oVEITroca ON CLICK FS_FILTR008(lCkAprova,lCkNaoApr,lCkJaUtil,.t.,lCkCtrSld) SIZE 100,08 PIXEL WHEN lDblClick
EndIf
ACTIVATE MSDIALOG oVEITroca CENTER ON INIT EnchoiceBar(oVEITroca,{|| nOpcao:=1 , oVEITroca:End()},{ || oVEITroca:End()},,)
If nOpcao == 1 // OK Tela
	If nOpc == 3 .or. nOpc == 4 // Incluir ou Alterar
		lRet := .t.
		aRedVeic := {}
		For ni := 1 to len(aVEITroc) // Atualiza aCols do VS9
			If !aVEITroc[ni,1] .and. aVEITroc[ni,12] > 0 // Excluir VS9
				nPos := aVEITroc[ni,12]
				aVS9[2,nPos,len(aVS9[2,nPos])] := .t.
				cSEQUEN += aVS9[2,nPos,FG_POSVAR("VS9_SEQUEN","aHeaderVS9")]+"/"
			ElseIf aVEITroc[ni,1] .and. aVEITroc[ni,12] > 0 // Alterar VS9
				nPos := aVEITroc[ni,12]
				cSEQUEN += aVS9[2,nPos,FG_POSVAR("VS9_SEQUEN","aHeaderVS9")]+"/"
			ElseIf aVEITroc[ni,1] .and. aVEITroc[ni,12] == 0 // Incluir VS9
				aAdd(aVS9[2],Array(len(aVS9[1])+1))
				nPos := len(aVS9[2])
				aVS9[2,nPos,len(aVS9[2,nPos])] := .f.
			EndIf
			If aVEITroc[ni,1] // Array contendo informacoes para o redutor.
				Aadd(aRedVeic,{ aVEITroc[ni,15] })//Grava o RECNO para redutor.
			EndIf
			If nPos > 0 // Carregar campos da aCols do VS9
				aVS9[2,nPos,FG_POSVAR("VS9_NUMIDE","aHeaderVS9")] := PadR(cNroAte,aVS9[1,FG_POSVAR("VS9_NUMIDE","aHeaderVS9"),4]," ") // Nro do Atendimento
				aVS9[2,nPos,FG_POSVAR("VS9_TIPOPE","aHeaderVS9")] := "V" // Veiculos
				aVS9[2,nPos,FG_POSVAR("VS9_TIPPAG","aHeaderVS9")] := cTpVTroca
				aVS9[2,nPos,FG_POSVAR("VS9_DATPAG","aHeaderVS9")] := dDtTit
				If cPaisLoc == "BRA"
					aVS9[2,nPos,FG_POSVAR("VS9_VALPAG","aHeaderVS9")] := aVEITroc[ni,19] // Saldo
				Else
					aVS9[2,nPos,FG_POSVAR("VS9_VALPAG","aHeaderVS9")] := aVEITroc[ni,06] // Valor de Compra
				EndIf
				aVS9[2,nPos,FG_POSVAR("VS9_REFPAG","aHeaderVS9")] := aVEITroc[ni,9]
				aVS9[2,nPos,len(aVS9[2,nPos])] := !aVEITroc[ni,1]
				nPos := 0
			EndIf
		Next
		nPos := 0
		For ni := 1 to len(aVS9[2]) // Atualizar na aCols do VS9 o VS9_SEQUEN dos Veiculos (Avaliacoes de Veiculos)
			If !aVS9[2,ni,len(aVS9[2,ni])]
				If aVS9[2,ni,FG_POSVAR("VS9_TIPPAG","aHeaderVS9")] == cTpVTroca .and. Empty(aVS9[2,ni,FG_POSVAR("VS9_SEQUEN","aHeaderVS9")])
					While .t.
						nPos++
						If !( strzero(nPos,2) $ cSEQUEN )
							Exit
						EndIf
					EndDo
					aVS9[2,ni,FG_POSVAR("VS9_SEQUEN","aHeaderVS9")] := strzero(nPos,2)
				EndIf
			EndIf
		Next
		If cPaisLoc == "BRA"
			//funcao para calcular valor do redutor.
			VX008REDUT(aRedVeic,cNroAte)
		EndIf
	EndIf
EndIf
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออัอออออออออออออหอออออออัอออออออออออออออออออออหออออออัออออออออออปฑฑ
ฑฑบPrograma ณ FS_FILTR008 บ Autor ณ Andre Luis Almeida  บ Data ณ 09/06/10 บฑฑ
ฑฑฬอออออออออุอออออออออออออสอออออออฯอออออออออออออออออออออสออออออฯออออออออออนฑฑ
ฑฑบDescricaoณ Filtra Avaliacoes de Veiculos Usados                        บฑฑ
ฑฑบ         ณ ( Aprovadas / Nao Aprovadas / Ja utilizadas )               บฑฑ
ฑฑฬอออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametroณ lCkAprova - Mostra Aprovadas                                บฑฑ
ฑฑบ         ณ lCkNaoApr - Mostra Nao-Aprovadas                            บฑฑ
ฑฑบ         ณ lCkJaUtil - Mostra ja utilizadas                            บฑฑ
ฑฑบ         ณ lRefresh  - Faz refresh do ListBox                          บฑฑ
ฑฑศอออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_FILTR008(lCkAprova,lCkNaoApr,lCkJaUtil,lRefresh,lCkCtrSld)
Local ni  := 0
Local lOk := .f.
aVEITroc := {}
For ni := 1 to len(aVEITTot)
	lOk := .f.
	If lCkAprova .and. aVEITTot[ni,2] == "verde" // Aprovadas
		lOk := .t.
	ElseIf lCkNaoApr .and. aVEITTot[ni,2] == "verme" // Nao Aprovadas
		lOk := .t.
	ElseIf lCkJaUtil .and. aVEITTot[ni,2] == "cinza" // Ja utilizadas
		lOk := .t.
	EndIf
	If lCkCtrSld .and. aVEITTot[ni,17] == "0" //Se estiver marcado para apresentar com Controle de Saldo deve desconsiderar os registros que nใo controlam
		lOk := .f.
	EndIf
	If lOk
		aAdd(aVEITroc,aClone(aVEITTot[ni]))
	EndIf
Next
If len(aVEITroc) <= 0
	Aadd(aVEITroc,{ .f. , "verme" , "" , "" , "" , 0 , "  /  /  " , "" , "" , "" , "" , 0 , "verme" , "" , 0 , "", "", 0 , 0 })
EndIf
If lRefresh
	oLbVEITroc:nAt := 1
	oLbVEITroc:SetArray(aVEITroc)
	oLbVEITroc:Refresh()
EndIf
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออัอออออออออออออหอออออออัอออออออออออออออออออออหออออออัออออออออออปฑฑ
ฑฑบPrograma ณ FS_PESQUISA บ Autor ณ Andre Luis Almeida  บ Data ณ 09/06/10 บฑฑ
ฑฑฬอออออออออุอออออออออออออสอออออออฯอออออออออออออออออออออสออออออฯออออออออออนฑฑ
ฑฑบDescricaoณ Pesquisa Avaliacoes de Veiculos Usados                      บฑฑ
ฑฑบ         ณ ( Placa / Chassi / Cod.Cliente / Nome do Cliente )          บฑฑ
ฑฑศอออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_PESQUISA(nTip)
Local nPos := 0
If nTip == 1
	oPPlaca:lVisible  := .f.
	oPChassi:lVisible := .f.
	oPCodCli:lVisible := .f.
	oPNomCli:lVisible := .f.
	If cComboP == STR0002 // Placa
		oPPlaca:lVisible := .t.
	ElseIf cComboP == STR0003 // Chassi
		oPChassi:lVisible := .t.
	ElseIf cComboP == STR0004 // Cod.Cliente
		oPCodCli:lVisible := .t.
	Else // cComboP == STR0005 // Nome Cliente
		oPNomCli:lVisible := .t.
	EndIf
	oPPlaca:Refresh()
	oPChassi:Refresh()
	oPCodCli:Refresh()
	oPNomCli:Refresh()
ElseIf nTip == 2
	If cComboP == STR0002 // Placa
		oPPlaca:SetFocus()
	ElseIf cComboP == STR0003 // Chassi
		oPChassi:SetFocus()
	ElseIf cComboP == STR0004 // Cod.Cliente
		oPCodCli:SetFocus()
	Else // cComboP == STR0005 // Nome Cliente
		oPNomCli:SetFocus()
	EndIf
Else // nTip == 3
	If cComboP == STR0002 // Placa
		aSort(aVEITroc,1,,{|x,y| x[11] < y[11] })
		nPos := aScan(aVEITroc,{|x| UPPER(Alltrim(cPPlaca)) $ UPPER(x[11]) })
	ElseIf cComboP == STR0003 // Chassi
		aSort(aVEITroc,1,,{|x,y| x[3] < y[3] })
		nPos := aScan(aVEITroc,{|x| UPPER(Alltrim(cPChassi)) $ UPPER(x[3]) })
	ElseIf cComboP == STR0004 // Cod.Cliente
		aSort(aVEITroc,1,,{|x,y| x[4] < y[4] })
		nPos := aScan(aVEITroc,{|x| Alltrim(cPCodCli) $ x[4] })
	Else // cComboP == STR0005 // Nome Cliente
		aSort(aVEITroc,1,,{|x,y| x[10] < y[10] })
		nPos := aScan(aVEITroc,{|x| Alltrim(cPNomCli) $ x[10]  })
	EndIf
	If nPos <= 0
		MsgStop(STR0018,STR0006) // Veiculo nao encontrado! / Atencao
		nPos := 1
	EndIf
	oLbVEITroc:nAt := nPos
	oLbVEITroc:SetArray(aVEITroc)
	oLbVEITroc:Refresh()
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออัอออออออออออออหอออออออัอออออออออออออออออออออหออออออัออออออออออปฑฑ
ฑฑบPrograma ณ FS_OBSERV   บ Autor ณ Andre Luis Almeida  บ Data ณ 09/06/10 บฑฑ
ฑฑฬอออออออออุอออออออออออออสอออออออฯอออออออออออออออออออออสออออออฯออออออออออนฑฑ
ฑฑบDescricaoณ Mostra Observacao                                           บฑฑ
ฑฑศอออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_OBSERV(nTip)
cObserv := ""
DbSelectArea("VAZ")
If nTip == 1
	If aVEITroc[1,13] <> "cinza"
		cObserv := IIF(!Empty(aVEITroc[1,8]), MSMM(aVEITroc[1,8],47),"")
	Else
		cObserv := STR0010+" - "+STR0019+" "+aVEITroc[1,8]+" "+STR0023+" "+aVEITroc[1,16]  // Ja utilizada / Atendimento: / Filial:
	EndIf
Else // nTip == 2
	If !Empty(aVEITroc[oLbVEITroc:nAt,8])
		If aVEITroc[oLbVEITroc:nAt,13] <> "cinza"
			cObserv := IIF(!Empty(aVEITroc[oLbVEITroc:nAt,8]),MSMM(aVEITroc[oLbVEITroc:nAt,8],47),"")
		Else
			cObserv := STR0010+" - "+STR0019+" "+aVEITroc[oLbVEITroc:nAt,8]+" "+STR0023+" "+aVEITroc[oLbVEITroc:nAt,16] // Ja utilizada / Atendimento: / Filial:
		EndIf
	EndIf
	oObserv:Refresh()
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออัอออออออออออออหอออออออัอออออออออออออออออออออหออออออัออออออออออปฑฑ
ฑฑบPrograma ณ FS_CLICK008 บ Autor ณ Andre Luis Almeida  บ Data ณ 09/06/10 บฑฑ
ฑฑฬอออออออออุอออออออออออออสอออออออฯอออออออออออออออออออออสออออออฯออออออออออนฑฑ
ฑฑบDescricaoณ Selecao no ListBox das Avaliacoes de Veiculos Usados        บฑฑ
ฑฑฬอออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametroณ nLinha  - Linha do ListBox                                  บฑฑ
ฑฑบ         ณ cNroAte - Numero do Atendimento                             บฑฑ
ฑฑบ         ณ aVS9    - Vetor do VS9                                      บฑฑ
ฑฑศอออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_CLICK008(nLinha,cNroAte,aVS9)
Local nj := 0
If !Empty(aVEITroc[nLinha,9])
	If aVEITroc[nLinha,12] > 0 // Linha do aVS9
		nj := aVEITroc[nLinha,12]
		If VX0080061_VerTituloSE1(aVS9[2,nj,FG_POSVAR("VS9_TIPPAG","aHeaderVS9")],aVS9[2,nj,FG_POSVAR("VS9_PARCEL","aHeaderVS9")])
			Return()
		EndIf
	EndIf
	If aVEITroc[nLinha,2] == "verde"
		aVEITroc[nLinha,1] := !aVEITroc[nLinha,1]
		If !VX0080015_UtilizaSaldo(aVEITroc[nLinha])
			Return()
		EndIf
	ElseIf aVEITroc[nLinha,2] == "cinza"
		MsgStop(STR0010+" - "+STR0019+" "+aVEITroc[nLinha,8]+" "+STR0023+" "+aVEITroc[nLinha,16],STR0006) // Ja utilizada / Atendimento: / Filial: / Atencao
	Else
		MsgStop(STR0021,STR0006) //Avaliacao Nao Aprovada / Atencao
	EndIf
EndIf
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณVX008ATUALบ Autor ณ Andre Luis Almeida บ Data ณ  11/05/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Atualiza VAZ ( Avaliacoes de Veiculos Usados )             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ nTip    - 1-Utiliza VAZ / 0-Cancela VAZ                    บฑฑ
ฑฑบ          ณ cNumAte - Nro do Atendimento                               บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function VX008ATUAL(cTip,cNumAte,cFilAte,cTipPag,cSequen,lGrvSld,nVlrGrv)
Local cQuery    := ""
Local cSQLAlias := "SQLAlias"
Local cTpVTroca := FM_SQL("SELECT VSA.VSA_TIPPAG FROM "+RetSQLName("VSA")+" VSA WHERE VSA.VSA_FILIAL='"+xFilial("VSA")+"' AND VSA.VSA_TIPO='4' AND VSA.D_E_L_E_T_=' '") // VSA_TIPO='4' ( Veiculos Usados )
Local lCanTotal := .f.
Local lVAZCTRSLD := ( cPaisLoc == "BRA" .and. VAZ->(FieldPos("VAZ_CTRSLD")) > 0 )
Local lMultMoeda := FGX_MULTMOEDA() // Trabalha com MultMoeda ?
Local nMoedaVV0  := 1

Default cNumAte := VV9->VV9_NUMATE
Default cFilAte := VV9->VV9_FILIAL
Default cTipPag := ""
Default cSequen := ""
Default lGrvSld := .t.
Default nVlrGrv := 0

cFilAte := PadR(cFilAte, GetSX3Cache("VV0_FILIAL","X3_TAMANHO"))
cNumAte := PadR(cNumAte, GetSX3Cache("VV0_NUMTRA","X3_TAMANHO"))

If lMultMoeda // Posicionar no VV0 para pegar a Moeda do Atendimento
	DbSelectArea("VV0")
	DbSetOrder(1)
	If DbSeek( cFilAte + cNumAte )
		nMoedaVV0 := VV0->VV0_MOEDA
	EndIf
EndIf

If cTip == "1"
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	// Atualizar VAZ (Avaliacao de Veiculo Usado) na Finalizacao do Atendimento //
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	cQuery := "SELECT VS9.VS9_VALPAG , VAZ.R_E_C_N_O_ VAZRECNO FROM "+RetSQLName("VS9")+" VS9 "
	cQuery += "INNER JOIN "+RetSQLName("VSA")+" VSA ON ( VSA.VSA_FILIAL='"+xFilial("VSA")+"' AND VSA.VSA_TIPPAG=VS9.VS9_TIPPAG AND VSA.VSA_TIPO='4' AND VSA.D_E_L_E_T_=' ' ) "
	cQuery += "INNER JOIN "+RetSQLName("VAZ")+" VAZ ON ( VAZ.VAZ_FILIAL='"+xFilial("VAZ")+"' AND VAZ.VAZ_CODIGO=VS9.VS9_REFPAG AND VAZ.VAZ_APROVA='1' AND VAZ.D_E_L_E_T_=' ' ) "
	cQuery += "WHERE VS9.VS9_FILIAL='"+xFilial("VS9")+"' AND VS9.VS9_NUMIDE='"+cNumAte+"' AND VS9.VS9_TIPOPE='V' "

	If !Empty(cTipPag)
		cQuery += " AND VS9.VS9_TIPPAG = '" + cTipPag + "' "
	EndIf

	If !Empty(cSequen)
		cQuery += " AND VS9.VS9_SEQUEN = '" + cSequen + "' "
	EndIf

	cQuery += 	"AND VS9.D_E_L_E_T_=' ' ORDER BY VAZ.VAZ_REVISA DESC"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLAlias , .F. , .T. )
	While !(cSQLAlias)->( Eof() )
		DbSelectArea("VAZ")
		DbGoTo(( cSQLAlias )->( VAZRECNO ))

		RecLock("VAZ",.F.)
			If lVAZCTRSLD .and. VAZ->VAZ_CTRSLD == "1"
				If lGrvSld
					VAZ->VAZ_SLDDIS -= nVlrGrv
					If VAZ->VAZ_SLDDIS == 0
						VAZ->VAZ_APROVA := "2" // Avaliacao com Veiculo Negociado
					EndIf
				EndIf
			Else
				VAZ->VAZ_APROVA := "2" // Avaliacao com Veiculo Negociado
				VAZ->VAZ_FILATE := cFilAte
				VAZ->VAZ_NUMATE := cNumAte
				VAZ->VAZ_VALCOM := ( cSQLAlias )->( VS9_VALPAG )
				If lMultMoeda
					If nMoedaVV0 == 2 // Moeda 2
						VAZ->VAZ_VALCO2 := ( cSQLAlias )->( VS9_VALPAG )
						VAZ->VAZ_VALCOM := FG_MOEDA(( cSQLAlias )->( VS9_VALPAG ),; // Valor Base para Calculo
													2,; // Moeda Origem
													1,; // Moeda Destino
													0,; // Valor Taxa Moeda
													TamSx3("VAZ_VALCOM")[2] ,; // Decimais (tamanho) do Valor a ser retornado
													dDataBase  ) // dDataBase
					Else
						VAZ->VAZ_VALCOM := ( cSQLAlias )->( VS9_VALPAG )
						VAZ->VAZ_VALCO2 := FG_MOEDA(( cSQLAlias )->( VS9_VALPAG ),; // Valor Base para Calculo
													1,; // Moeda Origem
													2,; // Moeda Destino
													0,; // Valor Taxa Moeda
													TamSx3("VAZ_VALCO2")[2] ,; // Decimais (tamanho) do Valor a ser retornado
													dDataBase  ) // dDataBase
					EndIf
				EndIf
			EndIf
		MsUnlock()
		If lVAZCTRSLD .and. VAZ->VAZ_CTRSLD == "1"
			VX0080025_GravaAtendimentos(( cSQLAlias )->( VAZRECNO ),cFilAte,cNumAte,( cSQLAlias )->( VS9_VALPAG ))
		EndIf
		(cSQLAlias)->( DbSkip() )
	EndDo
	( cSQLAlias )->( dbCloseArea() )
ElseIf left(cTip,1) == "0"
	If cTip == "0T" // Cancelamento Total
		lCanTotal := .t.
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Limpar VS9 de Amarracao com Avaliacao ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		cQuery := "SELECT VS9.R_E_C_N_O_ NRECNO FROM " + RetSQLName("VS9") + " VS9 WHERE "
		cQuery += "VS9.VS9_FILIAL='"+xFilial("VS9")+"' AND VS9.VS9_NUMIDE='"+cNumAte+"' AND VS9.VS9_TIPOPE='V' AND VS9.VS9_TIPPAG='"+cTpVTroca+"' AND VS9.D_E_L_E_T_=' '"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLAlias , .F. , .T. )
		While !(cSQLAlias)->( Eof() )
			dbSelectArea("VS9")
			VS9->(dbGoTo( (cSQLAlias)->NRECNO ) )
			If cPaisLoc == "BRA"
				VX0080035_ExcluiAvaliacaoxAtend(cFilAte,cNumAte,VS9->VS9_REFPAG)
			EndIf
			RecLock("VS9",.F.)
			VS9->VS9_REFPAG := Space(Len(VS9->VS9_REFPAG))
			MsUnLock()
			(cSQLAlias)->(dbSkip())
		End
		(cSQLAlias)->(dbCloseArea())
		dbSelectArea("VS9")
	EndIf
	//////////////////////////////////////////////////////////////////////////////
	// Cancelar VAZ (Avaliacao de Veiculo Usado) no Cancelamento do Atendimento //
	//////////////////////////////////////////////////////////////////////////////
	DbSelectArea("VAZ")
	DbSetOrder(4)
	If DbSeek( xFilial("VAZ") + cNumAte + cFilAte )
		If cTip == "0T" .and. MsgYesNo(STR0022,STR0006) // Deseja excluir as Avaliacoes de Veiculos Usados referentes a esse Atendimento? / Atencao
			Do While !Eof() .and. xFilial("VAZ") == VAZ->VAZ_FILIAL .and. cNumAte == VAZ->VAZ_NUMATE .and. cFilAte == VAZ->VAZ_FILATE
				RecLock("VAZ",.f.,.t.)
				DbDelete()
				MsUnlock()
				DbSkip()
			EndDo
		Else
			// Gravar VAZ (Avaliacao de Veiculo Usado) - Limpa link das avaliacoes com o Atendimento
			DbSelectArea("VAZ")
			DbSetOrder(4)
			While .t.
				If DbSeek( xFilial("VAZ") + cNumAte + cFilAte )
					RecLock("VAZ",.F.)
					If VAZ->VAZ_APROVA == "2" // Avaliacao com Veiculo Negociado
						VAZ->VAZ_APROVA := "1" // Avalicao Aprovada
					EndIf
					VAZ->VAZ_FILATE := "" // Limpa link com o Atendimento
					VAZ->VAZ_NUMATE := "" // Limpa link com o Atendimento
					MsUnlock()
				Else
					Exit
				EndIf
			EndDo
		EndIf
	EndIf
	
	If cPaisLoc == "BRA" .and. !lCanTotal // Cancelamento Total
		VX0080035_ExcluiAvaliacaoxAtend(cFilAte,cNumAte,VS9->VS9_REFPAG)
	EndIf

EndIf
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออัอออออออออออออหอออออออัอออออออออออออออออออออหออออออัออออออออออปฑฑ
ฑฑบPrograma ณ VX008REDUT  บ Autor ณ Rafael Goncalves    บ Data ณ 09/06/10 บฑฑ
ฑฑฬอออออออออุอออออออออออออสอออออออฯอออออออออออออออออออออสออออออฯออออออออออนฑฑ
ฑฑบDescricaoณ Atualiza valor do redutor                                   บฑฑ
ฑฑฬอออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametroณ aRedVeic - RECNO                                            บฑฑ
ฑฑบ         ณ cNroAte  - Numero do atendimento                            บฑฑ
ฑฑศอออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function VX008REDUT(aRedVeic,cNroAte) //recno + atendimento
Local _ni := 0
Local nValRedu := 0
Local lAlt := .f.
Local cTpVTroca  := Left(FM_SQL("SELECT VSA.VSA_TIPPAG FROM "+RetSQLName("VSA")+" VSA WHERE VSA.VSA_FILIAL='"+xFilial("VSA")+"' AND VSA.VSA_TIPO='4' AND VSA.D_E_L_E_T_=' '")+Repl("_",6),6) // VSA_TIPO='4' ( Veiculos Usados )
Default aRedVeic := {}

cNroAte := PadR(cNroAte, GetSX3Cache("VZ7_NUMTRA","X3_TAMANHO"))

For _ni:=1 to Len(aRedVeic)
	DbSelectArea("VAZ")
	DbGoTo(aRedVeic[_ni,01])
	IF VAZ->VAZ_VALCOM > VAZ->VAZ_VALAVA
		nValRedu += VAZ->VAZ_VALCOM - VAZ->VAZ_VALAVA
	EndIf
Next
nRecVZ7 := FM_SQL("SELECT VZ7.R_E_C_N_O_ AS RECVZ7 FROM "+RetSQLName("VZ7")+" VZ7 WHERE VZ7_FILIAL='"+xFilial("VZ7")+"' AND VZ7_NUMTRA='"+cNroAte+ "' AND VZ7_AGRVLR='2' AND VZ7_ITECAM='"+cTpVTroca+"' AND VZ7.D_E_L_E_T_ = ' '")
If nValRedu > 0 // Inclui ou Altera
	DbSelectArea("VZ7")
	If nRecVZ7 > 0
		//altera
		lAlt := .f.
		DbGoTo(nRecVZ7)
	Else
		//inclui
		lAlt := .t.
	EndIf
	RecLock("VZ7",lAlt)
	VZ7->VZ7_FILIAL := xFilial("VZ7")
	VZ7->VZ7_NUMTRA := cNroAte
	VZ7->VZ7_ITECAM := cTpVTroca
	VZ7->VZ7_VALITE := nValRedu
	VZ7->VZ7_AGRVLR := "2"
	VZ7->VZ7_ALTVLR := "0"
	VZ7->VZ7_OBRIGA := "0"
	VZ7->VZ7_TIPORC := "0"
	VZ7->VZ7_CODACV := ""
	VZ7->VZ7_GERORC := "0"
	MsUnLock()
Else //Exclui
	If nRecVZ7 > 0
		DbSelectArea("VZ7")
		DbGoTo(nRecVZ7)
		RecLock("VZ7",.F.,.T.)
		dbdelete()
		MsUnlock()
		WriteSx2("VZ7")
	EndIf
EndIf
Return

/*/{Protheus.doc} VX0080061_VerTituloSE1
Verifica se existe o titulo criado e tambem a baixa

@author Andre Luis Almeida
@since 19/04/2010
@version undefined
@type function
/*/
Static Function VX0080061_VerTituloSE1(cTipTit,cParcel)
Local lRet      := .f.
Local cPrefOri  := GetNewPar("MV_PREFVEI","VEI")
Local cNumTit   := "V"+Right(VV9->VV9_NUMATE,TamSx3("E1_NUM")[1]-1)
Local cNumNFI   := VV0->VV0_NUMNFI
Local cQuery    := ""
Local cPreTit   := &(GetNewPar("MV_PTITVEI","''")) // Prefixo dos Titulos de Veiculos
If left(GetNewPar("MV_TITATEN","0"),1) == "0" // Geracao dos Titulos no momento da geracao da NF
	If !Empty(cNumNFI) // Titulos gerados com o Nro da Nota Fiscal
		SF2->(DbSetOrder(1)) // F2_FILIAL + F2_DOC + F2_SERIE
		If SF2->(DbSeek(xFilial("SF2")+VV0->VV0_NUMNFI+VV0->VV0_SERNFI))
			cPreTit := SF2->F2_PREFIXO
		EndIf
	EndIf
EndIf
cQuery := "SELECT SE1.R_E_C_N_O_ AS RECSE1 FROM "+RetSQLName("SE1")+" SE1 WHERE SE1.E1_FILIAL='"+xFilial("SE1")+"' AND "
cQuery += "SE1.E1_PREFIXO='"+cPreTit+"' AND "
cQuery += "( SE1.E1_NUM='"+cNumTit+"' "
If !Empty(cNumNFI) // Titulos gerados com o Nro da Nota Fiscal
	cQuery += "OR SE1.E1_NUM='"+cNumNFI+"'"
EndIf
cQuery += " ) AND SE1.E1_TIPO='"+cTipTit+"' AND SE1.E1_PREFORI='"+cPrefOri+"' AND "
If cParcel <> NIL
	cQuery += "SE1.E1_PARCELA='"+cParcel+"' AND "
Else
	cQuery += "SE1.E1_PARCELA=' ' AND "
EndIf
cQuery += " SE1.E1_FILORIG='"+xFilial("VV9")+"' AND SE1.D_E_L_E_T_=' '"
If FM_SQL(cQuery+" AND ( SE1.E1_BAIXA <> ' ' OR SE1.E1_SALDO <> SE1.E1_VALOR )") > 0 // Titulo Baixado
	lRet := .t.
	MsgStop(STR0020,STR0006) // Titulo referente a este Veiculo Usado ja esta baixado! / Atencao
ElseIf FM_SQL(cQuery) > 0 // Titulo jแ foi criado
	lRet := .t.
	MsgStop(STR0028,STR0006) // Titulo referente a este Veiculo Usado jแ foi criado! / Atencao
EndIf
Return(lRet)

/*/{Protheus.doc} VX0080015_UtilizaSaldo

	@type function
	@author Renato Vinicius
	@since 28/11/2023
/*/

Static Function VX0080015_UtilizaSaldo(aAvaliacao)

	Local aParamBox := {}
	Local aRet      := {}

	If aAvaliacao[1]
		If aAvaliacao[17] == "1" .and. aAvaliacao[18] > 0 // Controla Saldo
			aAdd(aParamBox,{1,STR0024,aAvaliacao[18],GetSX3Cache("VAZ_SLDDIS","X3_PICTURE"),"MV_PAR01 <= "+cValToChar(aAvaliacao[18]),"","",60,.t.}) 
			If !(ParamBox(aParamBox,"",@aRet,,,,,,,,.f.,.f.))
				aAvaliacao[1] := .f.
				Return .f.
			EndIf
			aAvaliacao[19] := aRet[1] // Valor utilizado
		Else
			aAvaliacao[19] := aAvaliacao[18] // Grava o Valor utilizado com o Total da Compra quando nใo controla saldo
		EndIf
		aAvaliacao[18] -= aAvaliacao[19]
	Else
		aAvaliacao[18] += aAvaliacao[19]
		aAvaliacao[19] := 0 // Valor utilizado
	EndIf

Return .t.

/*/{Protheus.doc} VX0080025_GravaAtendimentos

	@type function
	@author Renato Vinicius
	@since 28/11/2023
/*/

Function VX0080025_GravaAtendimentos(nRecVAZ,cFilAte,cNumAte,nValUti)

	Default nRecVAZ := 0
	Default cFilAte := ""
	Default cNumAte := ""
	Default nValUti := 0

	If nRecVAZ > 0

		VAZ->(DbGoTo(nRecVAZ))

		DbSelectArea("VBR")
		DbSetOrder(2)
		DbSeek( xFilial("VBR") + VAZ->VAZ_CODIGO + cFilAte + cNumAte )

		RecLock("VBR",!Found())
			VBR->VBR_FILIAL := xFilial("VBR")
			VBR->VBR_CODIGO := GetSXENum("VBR","VBR_CODIGO")
			VBR->VBR_CODVAZ := VAZ->VAZ_CODIGO
			VBR->VBR_FILATE := cFilAte
			VBR->VBR_NUMATE := cNumAte
			VBR->VBR_VLRUTI := nValUti
			ConfirmSX8()
		MsUnLock()
	EndIf


Return

/*/{Protheus.doc} VX0080035_ExcluiAvaliacaoxAtend

	@type function
	@author Renato Vinicius
	@since 28/11/2023
/*/

Function VX0080035_ExcluiAvaliacaoxAtend(cFilAte,cNumAte,cVS9REF)

	Local cQuery := ""

	If FWAliasInDic("VBR")

		cQuery := "SELECT VAZ.R_E_C_N_O_ AS VAZRECNO, VBR.R_E_C_N_O_ AS VBRRECNO"
		cQuery += " FROM " + RetSQLName("VBR") + " VBR "
		cQuery += " JOIN " + RetSQLName("VAZ") + " VAZ "
		cQuery += 	"  ON VAZ.VAZ_FILIAL = '" + xFilial("VAZ") + "' "
		cQuery += 	" AND VAZ.VAZ_CODIGO = VBR.VBR_CODVAZ "
		cQuery += 	" AND VAZ.D_E_L_E_T_ = ' ' "
		cQuery += " WHERE VBR.VBR_FILIAL = '" + xFilial("VBR") + "' "
		cQuery += 	" AND VBR.VBR_FILATE = '" + cFilAte + "' "
		cQuery += 	" AND VBR.VBR_NUMATE = '" + cNumAte + "' "
		cQuery += 	" AND VBR.VBR_CODVAZ = '" + cVS9REF + "' "
		cQuery += 	" AND VBR.D_E_L_E_T_ = ' '"

		TcQuery cQuery New Alias "TMPVBR"

		While !TMPVBR->(Eof())

			VAZ->(DbGoTo(TMPVBR->(VAZRECNO)))
			VBR->(DbGoTo(TMPVBR->(VBRRECNO)))

			VAZ->(RecLock("VAZ",.F.))
			If VAZ->VAZ_APROVA == "2" // Avaliacao com Veiculo Negociado
				VAZ->VAZ_APROVA := "1" // Avalicao Aprovada
			EndIf
			VAZ->VAZ_SLDDIS += VBR->VBR_VLRUTI
			VAZ->(MsUnLock())

			VBR->(RecLock("VBR",.f.,.t.))
			VBR->(DbDelete())
			VBR->(MsUnlock())

			TMPVBR->(DbSkip())
		EndDo

		TMPVBR->(DbCloseArea())

	EndIf

Return

/*/{Protheus.doc} VX0080045_ValorUtilizado

	@type function
	@author Renato Vinicius
	@since 29/11/2023
/*/

Function VX0080045_ValorUtilizado( cCodAva, cCtrSld , cFilAte, cAtend , nMoedaVV0 )

	Local nValUti := 0

	If cCtrSld == "1"

		cQuery := "SELECT VBR.VBR_CODVAZ, SUM(VBR.VBR_VLRUTI) AS VLRUTI "
		cQuery += " FROM " + RetSQLName("VBR") + " VBR "
		cQuery += " WHERE VBR.VBR_FILIAL = '" + xFilial("VBR") + "' "
		cQuery += 	" AND VBR.VBR_CODVAZ = '" + cCodAva + "' "
		cQuery += 	" AND VBR.VBR_FILATE = '" + cFilAte + "' "
		cQuery += 	" AND VBR.VBR_NUMATE = '" + cAtend + "' "
		cQuery += 	" AND VBR.D_E_L_E_T_ = ' '"
		cQuery += " GROUP BY VBR.VBR_CODVAZ"

	Else

		cQuery := "SELECT VAZ.VAZ_CODIGO, "
		If nMoedaVV0 == 2 // Moeda 2
			cQuery += "VAZ.VAZ_VALCO2 AS VLRUTI "
		Else // Moeda 1 default
			cQuery += "VAZ.VAZ_VALCOM AS VLRUTI "
		EndIf
		cQuery += " FROM " + RetSQLName("VAZ") + " VAZ "
		cQuery += " WHERE VAZ.VAZ_FILIAL = '" + xFilial("VAZ") + "' "
		cQuery += 	" AND VAZ.VAZ_CODIGO = '" + cCodAva + "' "
		cQuery += 	" AND VAZ.VAZ_NUMATE <> ' ' "
		cQuery += 	" AND VAZ.D_E_L_E_T_ = ' '"

	EndIf

	TcQuery cQuery New Alias "TMPAVA"

	If !TMPAVA->(Eof())
		nValUti := TMPAVA->VLRUTI
	EndIf
	TMPAVA->(DbCloseArea())

Return nValUti

/*/{Protheus.doc} VX0080055_AtendimentodaAvaliacao

	@type function
	@author Renato Vinicius
	@since 01/12/2023
/*/

Function VX0080055_AtendimentodaAvaliacao( cVAZCTRSLD , cVAZCODIGO , cVAZNUMATE , cVAZOCOMEM )

	Local cRetorno := ""

	Default cVAZCTRSLD := ""

	If cVAZCTRSLD == "1"
		cQuery := "SELECT VBR.VBR_NUMATE "
		cQuery += "FROM " + RetSQLName("VBR") + " VBR "
		cQuery += " WHERE VBR.VBR_FILIAL = '" +xFilial("VBR")+ "' "
		cQuery += 	" AND VBR.VBR_CODVAZ = '" + cVAZCODIGO + "' "
		cQuery += 	" AND VBR.D_E_L_E_T_ = ' '"

		TcQuery cQuery New Alias "TMPVBR"

		While !TMPVBR->(Eof())
			cRetorno += TMPVBR->VBR_NUMATE + "/"
			TMPVBR->(DbSkip())
		EndDo
		TMPVBR->(DbCloseArea())
	Else
		cRetorno := Alltrim(IIf(Empty(cVAZNUMATE),cVAZOCOMEM,cVAZNUMATE ))
	EndIf

Return cRetorno