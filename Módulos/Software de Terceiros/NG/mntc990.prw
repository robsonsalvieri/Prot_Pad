#INCLUDE "MNTC990.ch"
#INCLUDE "PROTHEUS.CH"

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTC990
Consulta de O.S./Manutencoes atrasadas
@author Felipe N. Welter
@since 10/08/09
@version undefined
@type function
/*/
//---------------------------------------------------------------------
Function MNTC990()

	Local aNGBEGINPRM := NGBEGINPRM( , , , , .T. )

	//Browse detalhes: oListOS
	Local aTitOS := {STR0009, STR0010, STR0011, STR0012, STR0013,; //"T. Atraso"###"O.S."###"Prioridade"###"Bem"###"Descrição Bem"
	STR0014, STR0015, STR0016, STR0017},; //"Família"###"Serviço"###"Descrição Serviço"###"Sequência"
	aSizOS := {28,25,28,45,60,35,35,60,32},;
	cLinOS := "{|| {  (cAliDET)->TMPATR, (cAliDET)->ORDEM, (cAliDET)->PRIORI, (cAliDET)->CODBEM, (cAliDET)->NOMBEM,"+;
	"(cAliDET)->CODFAM, (cAliDET)->SERVIC, (cAliDET)->NOMSER, (cAliDET)->SEQUEN,"
	//Browse detalhes: oListMan
	Local	aTitMan := {STR0009, STR0011, STR0012, STR0013,STR0014,; //"T. Atraso"###"Prioridade"###"Bem"###"Descrição Bem"###"Família"
	STR0015, STR0016, STR0017},; //"Serviço"###"Descrição Serviço"###"Sequência"
	aSizMan := {28,28,45,60,35,35,60,76},;
	bLinMan := {|| { (cAliDET)->TMPATR, (cAliDET)->PRIORI, (cAliDET)->CODBEM, (cAliDET)->NOMBEM, (cAliDET)->CODFAM,;
	(cAliDET)->SERVIC, (cAliDET)->NOMSER, (cAliDET)->SEQUEN } }

	//Menus para click da direita
	Local	oMenu
	Local oMenuOS,;
	asMenuOS := {{STR0022,"Eval({|| STJ->(dbGoTo((cAliDET)->RECNBR)),NGCAD01('STJ',(cAliDET)->RECNBR,2)})"},; //"Visualizar O.S."
	{STR0023,"MNC600CON((cAliDET)->CODBEM)"},; //"Manutenções do Bem"
	{STR0024,"MNTA990()"}} //"Programação de O.S."
	Local oMenuMan,;
	asMenuMan := {{STR0025,"Eval({|| STF->(dbGoTo((cAliDET)->RECNBR)),MNC600FOLD('STF',(cAliDET)->RECNBR,2)})"}} //"Visualizar Manutenção"

	Local oFont14  := TFont():New("Arial",,14,,.F.,,,,.F.,.F.)
	Local oFont14N := TFont():New("Arial",,14,,.T.,,,,.F.,.F.)
	Local oDlg

	Local nAlt := (GetScreenRes()[2]-150)
	Local nLrg := (GetScreenRes()[1]-100)

	//Tabelas  Temporarias (p/ Markbrowse)
	Local oTmpTbl1

	//Consulta por:
	Private oTpCons, cTpCons := "1", aTpCons := {STR0001,STR0002} //"1=Ordem"###"2=Manutenção"

	//Visualizar por:
	Private oTpVis, cTpVis := "1",;
	aTpVisOS := {STR0003,STR0004,STR0005,STR0006,STR0007,STR0008},; //"1=Todos"###"2=Família"###"3=Tipo"###"4=Área"###"5=Serviço"###"6=Prioridade"
	aTpVisMan := {STR0003,STR0004,STR0005,STR0006,STR0007,STR0008} //"1=Todos"###"2=Família"###"3=Tipo"###"4=Área"###"5=Serviço"###"6=Prioridade"

	//Classificar por:
	Private oTpCla, cTpCla := "1", aTpCla := {STR0018,STR0019,STR0020,STR0021} //"1=Tempo Atraso"###"2=Prioridade"###"3=Bem"###"4=Servico"

	//Considera Localizacao/Bem
	Private oChkLc,oChkBm,;
	lChkLc := lChkBm := .T.

	Private nSizeForN := 12 //define o tamanho padrão para os campos numéricos
	Private cPicForN  := "@E 999,999,999,999" //define picture padrão para os campos numéricos

	Private cCadastro := STR0026 //"Consulta de O.S./Manutenções Atrasadas"
	Private cMarca := GetMark()

	Private lFolup := NGCADICBASE("TJ_STFOLUP","D","STJ",.F.)
	Private lTPLUB := NGCADICBASE("TF_TIPLUB ","D","STF",.F.)

	// Variaveis de controle das tabelas temporarias
	Private cAliMKB  := GetNextAlias()
	Private cAliDET  := GetNextAlias()
	Private aDET     := {}
	Private oDetails

	If lFolup
		aAdd(aTpVisOS,STR0027) //"7=Status"
		aAdd(aTitOS,STR0028)   //"Status"
		aAdd(aSizOS,35)
		aAdd(aTitOS,STR0029)   //"Descrição Status"
		aAdd(aSizOS,65)

		cLinOS += "(cAliDET)->STATUS, (cAliDET)->DESTAT, "
	EndIf

	aAdd(aTitOS,STR0030) //"Plano"
	aAdd(aSizOS,30)

	cLinOS += "(cAliDET)->PLANO } }"
	bLinOS := &(cLinOS)

	aMKB    :=  {{"OK"    ,"C",02,0},;
			    {"CODIGO","C",06,0},;
			    {"DESCRI","C",30,0},;
			    {"QNTATR","N", nSizeForN, 0 },; //Quantidade de O.S./Manutencoes atrasadas
			    {"MEDATR","N", nSizeForN, 0 },; //Atraso Médio
			    {"MEDATO","N", nSizeForN, 0 },; //Atraso Total
			    {"MAXATR","N", nSizeForN, 0 },; //Maior Atraso
			    {"MINATR","N", nSizeForN, 0 }}  //Menor Atraso

	aCpMKB  := {{"OK"    ,NIL,"",""},;
				{"DESCRI",NIL,STR0031,"@!"},;        //"Descrição"
				{"QNTATR",NIL,STR0032, cPicForN },; //"Qtde."
				{"MEDATR",NIL,STR0033, cPicForN },; //"Atraso Médio"
				{"MEDATO",NIL,STR0059, cPicForN },; //"Atraso Total"
				{"MAXATR",NIL,STR0034, cPicForN },; //"Maior"
				{"MINATR",NIL,STR0035, cPicForN }}  //"Menor"

	//Intancia classe FWTemporaryTable
	oTmpTbl1	:= FWTemporaryTable():New( cAliMKB, aMKB )
	//Cria indices
	oTmpTbl1:AddIndex( "Ind01" , {"DESCRI"}  )
	//Cria a tabela temporaria
	oTmpTbl1:Create()

	//+-------------------------------------------------+
	//| Criacao da tabela temporaria p/ browse Detalhes |
	//+-------------------------------------------------+
	aDET := {{"TMPATR","N", nSizeForN,0},;
			 {"DTPREV","D",08,0},;
			 {"ORDEM" ,"C",06,0},;
			 {"PRIORI","C",03,0},;
			 {"CODBEM","C",16,0},;
			 {"NOMBEM","C",40,0},;
			 {"SERVIC","C",06,0},;
			 {"SEQUEN","C",03,0},;
			 {"NOMSER","C",40,0},;
			 {"CODFAM","C",06,0},;
			 {"STATUS","C",06,0},;
			 {"DESTAT","C",40,0},;
			 {"PLANO" ,"C",06,0},;
			 {"TIPO"  ,"C",03,0},;
			 {"AREA"  ,"C",06,0},;
			 {"RECNBR","N",09,0}}

	oDetails := FWTemporaryTable():New( cAliDET, aDET )

	oDetails:AddIndex( 'Ind01', { 'DTPREV' } )
	oDetails:AddIndex( 'Ind02', { 'PRIORI' } )
	oDetails:AddIndex( 'Ind03', { 'CODBEM' } )
	oDetails:AddIndex( 'Ind04', { 'SERVIC' } )
	oDetails:AddIndex( 'Ind05', { 'CODFAM' } )
	oDetails:AddIndex( 'Ind06', { 'TIPO' }	 )
	oDetails:AddIndex( 'Ind07', { 'AREA' }	 )
	oDetails:AddIndex( 'Ind08', { 'STATUS' } )

	oDetails:Create()

	CursorWait()

	//Montagem da tela
	Define MsDialog oDlg Title cCadastro From 120,0 To nAlt,nLrg Of oMainWnd Color CLR_BLACK,RGB(225,225,225) Pixel

	oDlg:lEscClose := .F.

	//Define a criacao do painel esquerdo
	oPnlA := tPanel():New(00,00,,oDlg,,,,,,nLrg*.1855,00,.F.,.F.)
	oPnlA:Align := CONTROL_ALIGN_LEFT

	oPnlA1 := tPanel():New(00,00,,oPnlA,,,,,,00,62,.F.,.F.)
	oPnlA1:Align := CONTROL_ALIGN_TOP

	//Define a criacao de um box superior (parte esquerda)
	@ 06,05 To 56,nLrg*.1809 Of oPnlA1 Pixel

	@ 10,10 Say STR0037 Of oPnlA1 Font oFont14N COLOR RGB(0,100,30) Pixel //"Consulta por:"
	@ 18,10 MsComboBox oTpCons Var cTpCons Items aTpCons Size 60,12 Of oPnlA1 Pixel;
	On Change oTpVis:SetItems(If(cTpCons=="1",aTpVisOS,aTpVisMan))

	@ 32,10 Say STR0038 Of oPnlA1 Font oFont14N COLOR RGB(0,100,30) Pixel //"Visualizar por:"
	@ 40,10 MsComboBox oTpVis Var cTpVis Items aTpVisOS Size 60,12 Of oPnlA1 Pixel;
	On Change (CursorWait(),MNC990MKB(cTpCons,cTpVis),CursorArrow())

	oPnlA11 := tPanel():New(00,00,,oPnlA1,,,,,,60,00,.F.,.F.)
	oPnlA11:Align := CONTROL_ALIGN_RIGHT

	//Define a criacao de um box superior (parte direita)
	@ 06,-5 To 56,55 Of oPnlA11 Pixel

	oChkBm := TCheckBox():New(14,5,STR0057,;  //'Bem'
	{|u|If(PCount()==0,lChkBm,lChkBm:=u)},oPnlA11,75,10,,,oFont14;
	,{||CursorWait(),MNC990MKB(cTpCons,cTpVis),CursorArrow()},,,,.T.,;
	STR0039,,{||oTpCons:nAt == 1}) //"Considera O.S. do tipo 'Bem'"
	oChkBm:SetColor(RGB(0,100,30))

	oChkLc := TCheckBox():New(23,5,STR0056,;  //'Localização'
	{|u|If(PCount()==0,lChkLc,lChkLc:=u)},oPnlA11,75,10,,,oFont14;
	,{||CursorWait(),MNC990MKB(cTpCons,cTpVis),CursorArrow()},,,,.T.,;
	STR0040,,{||oTpCons:nAt == 1}) //"Considera O.S. do tipo 'Localização'"
	oChkLc:SetColor(RGB(0,100,30))

	oBtnGC := tButton():New(39,2,STR0041,oPnlA11,{||CursorWait(),MNC990MKB(cTpCons,cTpVis),CursorArrow()},50,12,,,,.T.) //"Gerar &Consulta"

	oPnlA2 := tPanel():New(00,00,,oPnlA,,,,,,00,00,.F.,.F.)
	oPnlA2:Align := CONTROL_ALIGN_ALLCLIENT

	oPnlA21 := tPanel():New(00,00,,oPnlA2,,,,,,05,00,.F.,.F.)
	oPnlA21:Align := CONTROL_ALIGN_LEFT //borda esquerda

	oPnlA22 := tPanel():New(00,00,,oPnlA2,,,,,,00,00,.F.,.F.)
	oPnlA22:Align := CONTROL_ALIGN_ALLCLIENT

	dbSelectArea(cAliMKB)
	dbSetOrder(01)
	dbGoTop()
	oMark := MsSelect():New(cAliMKB,"OK",,aCpMKB,,@cMarca,{0,0,0,0},,,oPnlA22)
	oMark:oBrowse:bLDblClick := { || M990MarkOne() }
	oMark:oBrowse:bAllMark := {||M990MarkAll() }
	oMark:oBrowse:cToolTip := STR0042 //"Visualização de Ordens de Serviço/Manutenções atrasadas por grupo"
	oMark:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

	oPnlA23 := tPanel():New(00,00,,oPnlA2,,,,,,05,00,.F.,.F.)
	oPnlA23:Align := CONTROL_ALIGN_RIGHT  //borda direita

	oPnlA3 := tPanel():New(00,00,,oPnlA,,,,,,00,22,.F.,.F.)
	oPnlA3:Align := CONTROL_ALIGN_BOTTOM

	//Define a criacao de um box inferior (parte esquerda)
	@ 03,05 To 20,nLrg*.1809 Of oPnlA3 Pixel

	oPnlA31 := tPanel():New(00,00,,oPnlA3,,,,,,120,00,.F.,.F.)
	oPnlA31:Align := CONTROL_ALIGN_RIGHT

	//Define a criacao de um box inferior (parte direita)
	@ 03,-5 To 20,115 Of oPnlA31 Pixel

	oBtnDT := tButton():New(6,10,STR0043,oPnlA31,{|| Processa({||MNC990DET(cTpCons,cTpVis)},STR0044)},50,12,,,,.T.) //"&Detalhar"###"Aguarde..."
	oBtEnd := tButton():New(6,62,STR0060,oPnlA31,{|| Processa({|| oDlg:End() })},50,12,,,,.T.)//"Sair"

	//Define a criacao do painel direito
	oPnlB := tPanel():New(06,220,,oDlg,,,,,,00,00,.F.,.F.)
	oPnlB:Align := CONTROL_ALIGN_ALLCLIENT

	//Painel para sobreposicao
	oPnlBX := tPanel():New(00,000,,oDlg,,,,,,00,00,.T.,.F.)
	oPnlBX:Align := CONTROL_ALIGN_ALLCLIENT
	oSayDet := TSay():New(05,05,{||STR0045+CHR(13)+STR0046},oPnlBX,,oFont14N,,,,.T.,,,) //"Detalhes: "###"Visualização não disponível."
	oSayDet:SetColor(RGB(0,100,30))

	oPnlB1 := tPanel():New(00,00,,oPnlB,,,,,,00,62,.F.,.F.)
	oPnlB1:Align := CONTROL_ALIGN_TOP

	@ 10,05 Say STR0047 Of oPnlB1 Font oFont14N COLOR RGB(0,100,30) Pixel //"Classificar por:"
	@ 18,05 MsComboBox oTpCla Var cTpCla Items aTpCla Size 70,12 Of oPnlB1 Pixel;
	On Change (NGDBAREAORDE((cAliDET),Val(cTpCla)), oListOS:Refresh(),oListMan:Refresh())

	oPnlB2 := tPanel():New(00,00,,oPnlB,,,,,,00,00,.F.,.F.)
	oPnlB2:Align := CONTROL_ALIGN_ALLCLIENT

	oPnlB21 := tPanel():New(00,00,,oPnlB2,,,,,,05,00,.F.,.F.)
	oPnlB21:Align := CONTROL_ALIGN_LEFT //borda esquerda

	oPnlB22 := tPanel():New(00,00,,oPnlB2,,,,,,00,00,.F.,.F.)
	oPnlB22:Align := CONTROL_ALIGN_ALLCLIENT

	dbSelectArea(cAliDET)
	dbSetOrder(01)
	dbGoTop()

	oListOS := TWBrowse():New(00,00,00,00,,aTitOS,aSizOS,oPnlB22,,,,,,,,,,,,,(cAliDET),.T.,,,,,,)
	oListOS:Align := CONTROL_ALIGN_ALLCLIENT
	oListOS:bLine := bLinOS
	oListOS:cToolTip := STR0048 //"Ordens de Serviço atrasadas"
	oListOS:blDblClick := {|| STJ->(dbGoTo((cAliDET)->RECNBR)),NGCAD01("STJ",(cAliDET)->RECNBR,2)}
	oListOS:Hide()

	NGPOPUP(asMenuOS,@oMenuOS)
	oListOS:brClicked := { |o,x,y| oMenuOS:Activate(x,y,oListOS)}

	oListMan := TWBrowse():New(00,00,00,00,,aTitMan,aSizMan,oPnlB22,,,,,,,,,,,,,(cAliDET),.T.,,,,,,)
	oListMan:Align := CONTROL_ALIGN_ALLCLIENT
	oListMan:bLine := bLinMan
	oListMan:cToolTip := STR0049 //"Manutenções atrasadas"
	oListMan:blDblClick := {|| STF->(dbGoTo((cAliDET)->RECNBR)),MNC600FOLD("STF",(cAliDET)->RECNBR,2)}
	oListMan:Hide()

	NGPOPUP(asMenuMan,@oMenuMan)
	oListMan:brClicked := { |o,x,y| oMenuMan:Activate(x,y,oListMan)}

	oPnlB23 := tPanel():New(00,00,,oPnlB2,,,,,,05,00,.F.,.F.)
	oPnlB23:Align := CONTROL_ALIGN_RIGHT  //borda direita

	oPnlB3 := tPanel():New(00,00,,oPnlB,,,,,,00,22,.F.,.F.)
	oPnlB3:Align := CONTROL_ALIGN_BOTTOM

	oBtImp := tButton():New(6,318,STR0061,oPnlB3,{|| Processa({|| MNT990IMP() })},50,12,,,,.T.) //Imprimir

	Processa({|lEnd| MNC990MKB(cTpCons,cTpVis)},STR0050,STR0051) //"Processando informações"###"Aguarde"

	CursorArrow()

	NGPOPUP(asMenu,@oMenu)
	oDlg:brClicked := { |o,x,y| oMenu:Activate(x,y,oDlg)}

	Activate MsDialog oDlg Centered

	oTmpTbl1:Delete()
	oDetails:Delete()

	//Retorna conteudo de variaveis padroes
	NGRETURNPRM(aNGBEGINPRM)

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} M990MarkOne
Funcao chamada no duplo clique em um elemento no markbrowse
@author Felipe N. Welter
@since 12/08/09
@version undefined
@type function
/*/
//---------------------------------------------------------------------
Static Function M990MarkOne()

	dbSelectArea(cAliMKB)
	dbSetOrder(01)
	If !Eof() .And. !Bof()
		RecLock(cAliMKB,.F.)
		(cAliMKB)->OK := If(IsMark('OK',cMarca),"  ",cMarca)
		MsUnLock(cAliMKB)
		oMark:oBrowse:Refresh()
	EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} M990MarkAll
Grava marca em todos os registros no markbrowse (inverte)
@author Felipe N. Welter
@since 12/08/09
@version undefined
@type function
/*/
//---------------------------------------------------------------------
Static Function M990MarkAll()

	dbSelectArea(cAliMKB)
	dbSetOrder(01)
	dbGoTop()
	While !Eof()
		RecLock(cAliMKB,.F.)
		(cAliMKB)->OK := If(IsMark('OK',cMarca),"  ",cMarca)
		MsUnLock(cAliMKB)
		dbSkip()
	End
	dbGoTop()
	MsUnLock(cAliMKB)
	oMark:oBrowse:Refresh()

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MNC990MKB
Processamento da consulta/visualizacao do markbrowse
@author Felipe N. Welter
@since 10/08/09
@version undefined
@param cTpConV, characters, descricao
@param cTpVisV, characters, descricao
@type function
/*/
//---------------------------------------------------------------------
Static Function MNC990MKB(cTpConV,cTpVisV)

	Local aOldMKB 	:= {}
	Local cQuery 	:= ''
	Local cAliasQry := GetNextAlias()
	Local cBanco    := Upper(TCGetDB())

	//+----------------------------------------------------------------------------------+
	//| Parametros   1.cTpConV - Tipo de Consulta                           Obrigat.     |
	//|              		 1 - Ordem de Servico                                        |
	//|              		 2 - Manutencao                                              |
	//|              2.cTpVisV - Tipo de Visualizacao da Consulta            Obrigat.    |
	//|              -Se for Ordem de Servico (1):                                       |
	//|                     		1 - Todas as Ordens de Servico                       |
	//|                    			2 - por Status (follow-up)                           |
	//|                   			3 - por Familia de Bens                              |
	//|                				4 - por Tipo de Manutencao                           |
	//|                				5 - por Area de Manutencao                           |
	//|                				6 - por Servico de Manutencaoe do Banco de Dados     |
	//|                				7 - por Prioridade da O.S.                           |
	//+----------------------------------------------------------------------------------+

	//Salva marcados e limpa os registros da tabela
	dbSelectArea(cAliMKB)
	dbGoTop()
	While !Eof()
		aAdd(aOldMKB,{(cAliMKB)->CODIGO,(cAliMKB)->OK})
		dbSkip()
	EndDo
	ZAP

	//+----------------------------------------------+
	//| Montagem do Markbrowse para Ordem de Servico |
	//+----------------------------------------------+
	If cTpConV == "1" //ORDEM DE SERVICO

		cQuery := MNC990STJ( cTpVisV, 'TOT' )

		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

		While (cAliasQry)->(!Eof())

			If !Empty( (cAliasQry)->DESCR )
				dbSelectArea( cAliMKB )
				RecLock( (cAliMKB), .T. )
				(cAliMKB)->CODIGO := (cAliasQry)->CODIGO
				(cAliMKB)->DESCRI := (cAliasQry)->DESCR
				(cAliMKB)->QNTATR := ABS((cAliasQry)->QUANT)
				(cAliMKB)->MEDATO := ABS((cAliasQry)->TOTAL)
				(cAliMKB)->MEDATR := ABS((cAliasQry)->MEDIA)
				
				If cBanco == 'POSTGRES'
					(cAliMKB)->MAXATR := ABS(Val((cAliasQry)->MAIOR))
					(cAliMKB)->MINATR := ABS(Val((cAliasQry)->MENOR))
				Else
					(cAliMKB)->MAXATR := ABS((cAliasQry)->MAIOR)
					(cAliMKB)->MINATR := ABS((cAliasQry)->MENOR)
				EndIf
				
				If (nD := aScan(aOldMKB, {|x| x[1] == (cAliMKB)->CODIGO})) > 0
					(cAliMKB)->OK := aOldMKB[nD,2]
				EndIf
				MsUnLock((cAliMKB))
			EndIf
			(cAliasQry)->(DbSkip())

		EndDo

		dbSelectArea(cAliMKB)
		dbGoTop()
		If (cAliMKB)->(RecCount()) == 1 .And. !IsMark('OK',cMarca)
			M990MarkOne()
		EndIf
		oMark:oBrowse:Refresh()

		//Esconde browse de Detalhes (sobrepoem panel)
		oPnlBX:Show()

		//+----------------------------------------------+
		//| Montagem do Markbrowse para Manutencao       |
		//+----------------------------------------------+
	ElseIf cTpConV == "2" //MANUTENCAO
		
		cQuery := MNC990STF( cTpVisV, 'TOT' )

		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

		While (cAliasQry)->(!Eof())

			dbSelectArea(cAliMKB)
			RecLock((cAliMKB),.T.)
			(cAliMKB)->CODIGO := (cAliasQry)->CODIGO
			(cAliMKB)->DESCRI := (cAliasQry)->DESCR
			(cAliMKB)->QNTATR := ABS((cAliasQry)->QUANT)
			(cAliMKB)->MEDATO := ABS((cAliasQry)->TOTAL)
			(cAliMKB)->MEDATR := ABS((cAliasQry)->MEDIA)
			(cAliMKB)->MAXATR := ABS((cAliasQry)->MAIOR)
			(cAliMKB)->MINATR := ABS((cAliasQry)->MENOR)
			(cAliMKB)->MAXATR := ABS((cAliasQry)->MAIOR)
			(cAliMKB)->MINATR := ABS((cAliasQry)->MENOR)
			
			If (nD := aScan(aOldMKB, {|x| x[1] == (cAliMKB)->CODIGO})) > 0
				(cAliMKB)->OK := aOldMKB[nD,2]
			EndIf
			MsUnLock((cAliMKB))

			(cAliasQry)->(DbSkip())
			
		EndDo

		dbSelectArea(cAliMKB)
		dbGoTop()
		If (cAliMKB)->(RecCount()) == 1 .And. !IsMark('OK',cMarca)
			M990MarkOne()
		EndIf
		oMark:oBrowse:Refresh()

		//Esconde browse de Detalhes (sobrepoem panel)
		oPnlBX:Show()

	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MNC990DET
Processamento da consulta/visualizacao dos detalhes
@author  Felipe N. Welter
@since 10/08/09
@version undefined
@param cTpConV, characters, descricao
@param cTpVisV, characters, descricao
@type function
/*/
//---------------------------------------------------------------------
Static Function MNC990DET(cTpConV,cTpVisV)

	Local aMarkd := {}
	Local cQuery 	:= ''

	//Limpa os registros da tabela
	dbSelectArea(cAliDET)
	ZAP

	dbSelectArea(cAliMKB)
	dbGoTop()
	While !Eof()

		If IsMark('OK',cMarca)
			If cTpVisV $ "2/4/5" //FAMILIA//AREA//SERVICO
				aAdd(aMarkd,SubStr((cAliMKB)->CODIGO,1,6))
			ElseIf cTpVisV $ "3/6" //TIPO//PRIORIDADE
				aAdd(aMarkd,SubStr((cAliMKB)->CODIGO,1,3))
			ElseIf cTpVisV $ "7" .And. lFolup //STATUS
				aAdd(aMarkd,SubStr((cAliMKB)->CODIGO,1,6))
			Else
				aAdd(aMarkd,AllTrim((cAliMKB)->CODIGO))
			EndIf
		EndIf

		dbSelectArea(cAliMKB)
		dbSkip()
	EndDo

	dbGoTop()
	If Len(aMarkd) == 0
		ShowHelpDlg(STR0058,{STR0052,""},2,; //"INVALIDO"###"Não foram marcados itens para visualização das Manutenções."
		{STR0053,""},2) //"É necessário marcar no browse os itens que se deseja visualizar."
		oPnlBX:Show()
		Return .F.
	EndIf

	//+----------------------------------------------+
	//| Montagem dos detalhes para Ordem de Servico  |
	//+----------------------------------------------+
	If cTpConV == "1" //ORDEM

		cQuery := MNC990STJ( cTpVisV, 'DET', aMarkd )

		SqlToTrb( cQuery, aDET, cAliDET )

		dbSelectArea(cAliDET)
		dbGoTop()
		oListOS:Show()
		oListMan:Hide()
		oListOS:Refresh()

		//+----------------------------------------------+
		//| Montagem dos detalhes para Manutencao        |
		//+----------------------------------------------+
	ElseIf cTpConV == "2" //MANUTENCAO

		cQuery := MNC990STF( cTpVisV, 'DET', aMarkd )

		SqlToTrb( cQuery, aDET, cAliDET )

		dbSelectArea(cAliDET)
		dbGoTop()
		oListMan:Show()
		oListOS:Hide()
		oListMan:Refresh()
	EndIf

	oPnlBX:Hide()

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} MNT990IMP
Funçaõ que imprime o relatório de consulta de ordens de serviço
e manuteções atrasadas.
@author Elynton Fellipe Bazzo
@since 21/02/2014
@return Nil
/*/
//---------------------------------------------------------------------
Function MNT990IMP()

	Local cString	:= "ST9"
	Local cDesc1	:= STR0062 //"O.S e Manutenções Atrasadas"
	Local cDesc2	:= ""
	Local cDesc3	:= ""
	Local wnrel	:= "MNTC990"
	Local aArea	:= GetArea()

	Private aReturn   := {STR0063, 1,STR0064, 2, 2, 1, "",1 } //"Zebrado"#"Administracao"
	Private nLastKey 	:= 0
	Private ntipo		:= 0
	Private Titulo   	:= cDesc1
	Private Tamanho  	:= "G"

	//Envia controle para a funcao SETPRINT
	wnrel := SetPrint(cString,wnrel,,titulo,cDesc1,cDesc2,cDesc3,.F.,"")
	If nLastKey = 27
		Set Filter To
		Return
	EndIf

	SetDefault( aReturn,cString )
	RptStatus({| lEnd | C990Imp(@lEnd,wnRel,titulo,tamanho)},titulo)
	RestArea(aArea)
Return Nil
//---------------------------------------------------------------------
/*/{Protheus.doc} C990Imp
Função que monta o cabeçalho e imprime o conteúdo do relatório.

@author Elynton Fellipe Bazzo
@since 21/02/2014
@return Nil
/*/
//---------------------------------------------------------------------
Function C990Imp(lEnd,wnRel,titulo,tamanho)

	Local cRodaTxt	  := ""
	Local nCntImpr	  := 0
	Local lImp		  := .F. // Variável de controle, para impressão do rodapé.
	Local aArea	      := GetArea()
	Local cAlsQry     := GetNextAlias()
	Local cFieldOrd   := ''
	Local cFldAgrup   := ''
	Local cOrderBy    := ''
	Local cTable      := ''

	Private lPriImp	  := .T., lTodos := .T.
	Private nQtdTotOs := 0, nTemTotAt := 0
	Private li		  := 80
	Private m_pag	  := 1
	Private Cabec1	  := " "
	Private Cabec2	  := " "
	Private nomeprog  := "MNTC990"
	nTipo             := IIF(aReturn[4]==1,15,18)

	// Classifica Por:
	Do Case

		Case cTpCla == '1' // Tempo Atraso

			cDesTpCla := STR0065 // Classifica por: Tempo Atraso
			cFieldOrd := 'TMPATR'

		Case cTpCla == '2' // Prioridade

			cDesTpCla := STR0066 // Classifica por: Prioridade
			cFieldOrd := 'PRIORI'

		Case cTpCla == '3' // Bem

			cDesTpCla := STR0067 // Classifica por: Bem
			cFieldOrd := 'CODBEM'

		Case cTpCla == '4' // Serviço

			cDesTpCla := STR0068 // Classifica por: Serviço
			cFieldOrd := 'SERVIC'

	EndCase

	// O.S. Atrasadas Por:
	Do Case

		Case cTpVis == '1' // Todos

			cDescTpVi := STR0070 // Todos
			cFldAgrup := 'DTPREV'

		Case cTpVis == '2' // Família

			cDescTpVi := STR0071 // Família
			cFldAgrup := 'CODFAM'
			cDescri	  := (cAliDET)->CODFAM

		Case cTpVis == '3' // Tipo

			cDescTpVi := STR0072 // Tipo
			cFldAgrup := 'TIPO'
			cDescri	  := (cAliDET)->TIPO

		Case cTpVis == '4' // Área

			cDescTpVi := STR0073 // Área
			cFldAgrup := 'AREA'
			cDescri	  := (cAliDET)->AREA

		Case cTpVis == '5' // Serviço

			cDescTpVi := STR0074 // Serviço
			cFldAgrup := 'SERVIC'
			cDescri	  := (cAliDET)->SERVIC

		Case cTpVis == '6' // Prioridade

			cDescTpVi := STR0075 // Prioridade
			cFldAgrup := 'PRIORI'
			cDescri	  := (cAliDET)->PRIORI

		Case cTpVis == '7' // Status

			cDescTpVi := STR0028 // Status
			cFldAgrup := 'STATUS'
			cDescri	  := (cAliDET)->STATUS

	EndCase

	// Cabeçalho
	If cTpCons == "1" //Ordem.
		Cabec1 := STR0069 + AllTrim( cDescTpVi ) + Space(50) + AllTrim( cDesTpCla )
	Else //Manutenção.
		Cabec1 := STR0098 + AllTrim( cDescTpVi ) + Space(50) + AllTrim( cDesTpCla )
	EndIf

	cCodFam  := (cAliDET)->CODFAM //Código Família
	cCodSer  := (cAliDET)->SERVIC //Código Serviço
	cCodPri  := (cAliDET)->PRIORI //Código Prioridade
	cTipo	 := (cAliDET)->TIPO	  //Tipo Serviço
	cCodArea := (cAliDET)->AREA	  //Area da Manutenção
	cStatus	 := (cAliDET)->STATUS //Status da O.S.
	cOrderBy := '%TMP.' + cFldAgrup + ', TMP.' + cFieldOrd + '%'
	cTable   := '%' + oDetails:GetRealName() + '%'

	// O.S. e Manutenções Atrasadas.
	BeginSQL Alias cAlsQry

		SELECT
			TMP.*
		FROM
			%exp:cTable% TMP
		ORDER BY
			%exp:cOrderBy%

	EndSQl

	SetRegua( LastRec() )

	Do While (cAlsQry)->( !EoF() )

		IncRegua()

		If lImp
			MNT990ROD() //Função que imprime o rodapé do relatório.
		EndIf

		MNT990CON( cAlsQry ) // Função que imprime o conteúdo do relatório.

		cCodFam  := (cAlsQry)->CODFAM // Código Família
		cCodSer  := (cAlsQry)->SERVIC // Código Serviço
		cCodPri  := (cAlsQry)->PRIORI // Código Prioridade
		cTipo	 := (cAlsQry)->TIPO	  // Tipo Serviço
		cCodArea := (cAlsQry)->AREA	  // Area da Manutenção
		cStatus	 := (cAlsQry)->STATUS //Status da O.S.
		lImp 	 := .F. 			  //Variável de controlde -> impressão.

		 (cAlsQry)->( dbSkip() )

		If cTpVis == "2" //Família
			If cCodFam <> (cAlsQry)->CODFAM
				lImp := .T.
			EndIf
		ElseIf cTpVis == "3" //Tipo
			If cTipo <> (cAlsQry)->TIPO
				lImp := .T.
			EndIf
		ElseIf cTpVis == "4" //Área
			If cCodArea <> (cAlsQry)->AREA
				lImp := .T.
			EndIf
		ElseIf cTpVis == "5" //Serviço
			If cCodSer <> (cAlsQry)->SERVIC
				lImp := .T.
			EndIf
		ElseIf cTpVis == "6" //Prioridade
			If cCodPri <> (cAlsQry)->PRIORI
				lImp := .T.
			EndIf
		ElseIf cTpVis == "7" //Status
			If cStatus <> (cAlsQry)->STATUS
				lImp := .T.
			EndIf
		EndIf

	EndDo

	MNT990ROD() //Função que imprime o rodapé com as informações referentes ao conteúdo.

	If cTpVis <> "1" //Todos
		NGSOMALI(58)
		NGSOMALI(58)
		If cTpCons == "1"
			@Li,005 Psay STR0076 // "Quantidade Total OS's.........:"
		Else
			@Li,005 Psay STR0100 // "Quantidade Total Manutenção....:"
		EndIf
		@Li,036 Psay nQtdTotOs	Picture cPicForN
		NGSOMALI(58)
		@Li,005 Psay STR0077 // "Tempo Total de Atraso.........:"
		@Li,036 Psay nTemTotAt	Picture cPicForN
	EndIf

	Roda(nCntImpr,cRodaTxt,Tamanho)
	Set Filter To
	Set Device To Screen

	If aReturn[5] = 1
		Set Printer To
		dbCommitAll()
		OurSpool(wnrel)
	EndIf

	(cAlsQry)->( dbCloseArea() )

	MS_FLUSH()
	RestArea(aArea)

Return Nil

//-----------------------------------------------------------------------------
/*/{Protheus.doc} MNT990CON
Função que imprime o conteúdo do relatório.
@type function

@author Elynton Fellipe Bazzo
@since 21/02/2014

@param cAlsQry, Caracter, Alias contendo registros para impressão já ordenados.
@return Nil
/*/
//-----------------------------------------------------------------------------
Static Function MNT990CON( cAlsQry )

	Local lImprime := .F.

	If cTpVis == "1" //Todos
		cDescTpVi 	:= STR0070
		cDescri	:= STR0070
		lPriImp	:= .F.
	ElseIf cTpVis == "2" //Família
		cDescTpVi	:= STR0071
		cDescri		:= (cAlsQry)->CODFAM
		If cCodFam <> (cAlsQry)->CODFAM .Or. lPriImp
			lImprime := .T.
			lPriImp	 := .F.
		EndIf
	ElseIf cTpVis == "3" //Tipo
		cDescTpVi	:= STR0072
		cDescri		:= (cAlsQry)->TIPO
		If cTipo <> (cAlsQry)->TIPO .Or. lPriImp
			lImprime := .T.
			lPriImp	 := .F.
		EndIf
	ElseIf cTpVis == "4" //Área
		cDescTpVi	:= STR0073
		cDescri		:= (cAlsQry)->AREA
		If cCodArea <> (cAlsQry)->AREA .Or. lPriImp
			lImprime := .T.
			lPriImp	 := .F.
		EndIf
	ElseIf cTpVis == "5" //Serviço
		cDescTpVi := STR0074
		cDescri	  := (cAlsQry)->SERVIC
		If cCodSer <> (cAlsQry)->SERVIC .Or. lPriImp
			lImprime := .T.
			lPriImp	 := .F.
		EndIf
	ElseIf cTpVis == "6" //Prioridade
		cDescTpVi := STR0075
		cDescri   := (cAlsQry)->PRIORI
		If cCodPri <> (cAlsQry)->PRIORI .Or. lPriImp
			lImprime := .T.
			lPriImp	 := .F.
		EndIf
	ElseIf cTpVis == "7" //Status
		cDescTpVi := STR0028
		cDescri   := (cAlsQry)->STATUS
		If cStatus <> (cAlsQry)->STATUS .Or. lPriImp
			lImprime := .T.
			lPriImp	 := .F.
		EndIf
	EndIf

	If lPriImp .Or. lImprime .Or. lTodos
		NGSOMALI(58)
		If cTpVis <> "1" //Todos
			@Li,000 Psay cDescTpVi+"....: "+cDescri
		Else
			If cTpCons == "1"
				@Li,000 Psay STR0102+"....: "+cDescri
			Else
				@Li,000 Psay STR0101+"....: "+cDescri
			EndIf
		EndIf
		NGSOMALI(58)
		If cTpCons == "1" // Se a consulta for por ordem.
			@Li,005 Psay STR0081 //"T. Atraso"
			@Li,019 Psay STR0082 //"O.S."
			@Li,028 Psay STR0083 //"Prioridade"
			@Li,043 Psay STR0084 //"Bem"
			@Li,062 Psay STR0085 //"Desc. Bem"
			@Li,087 Psay STR0086 //"Família"
			@Li,103 Psay STR0087 //"Serviço"
			@Li,126 Psay STR0088 //"Desc. Serviço"
			@Li,153 Psay STR0089 //"Sequência"
			@Li,180 Psay STR0090 //"Status"
			@Li,190 Psay STR0091 //"Desc. Status"
			@Li,214 Psay STR0092 //"Plano"
		Else
			@Li,005 Psay STR0081 //"T. Atraso"
			@Li,028 Psay STR0083 //"Prioridade"
			@Li,050 Psay STR0084 //"Bem"
			@Li,075 Psay STR0085 //"Desc. Bem"
			@Li,120 Psay STR0086 //"Família"
			@Li,150 Psay STR0087 //"Serviço"
			@Li,180 Psay STR0088 //"Desc. Serviço"
			@Li,211 Psay STR0089 //"Sequência"
		EndIf
	EndIf
	lTodos := .F.

	If cTpCons == "1" // Consulta por ordem.

		NGSOMALI(58) //Pula Linha.
		@Li,000 Psay (cAlsQry)->TMPATR Picture cPicForN // T. Atraso
		@Li,019 Psay (cAlsQry)->ORDEM                   // Ordem
		@Li,028 Psay (cAlsQry)->PRIORI                  // Prioridade
		@Li,043 Psay (cAlsQry)->CODBEM                  // Código do Bem
		@Li,062 Psay SubStr( (cAlsQry)->NOMBEM, 1, 20 ) // Descrição do Bem
		@Li,087 Psay (cAlsQry)->CODFAM                  // Código da Família
		@Li,103 Psay (cAlsQry)->SERVIC                  // Serviço
		@Li,126 Psay SubStr( (cAlsQry)->NOMSER, 1, 20 ) // Descrição do Serviço
		@Li,161 Psay (cAlsQry)->SEQUEN                  // Sequência
		@Li,180 Psay (cAlsQry)->STATUS                  // Status
		@Li,190 Psay (cAlsQry)->DESTAT                  // Descrição do Status
		@Li,215 Psay (cAlsQry)->PLANO                   // Plano

	Else // Consulta por manutenção.

		NGSOMALI(58)
		@Li,000 Psay (cAlsQry)->TMPATR Picture cPicForN // T. Atraso
		@Li,028 Psay (cAlsQry)->PRIORI                  // Prioridade
		@Li,050 Psay (cAlsQry)->CODBEM                  // Código do Bem
		@Li,075 Psay SubStr( (cAlsQry)->NOMBEM, 1, 20 ) // Descrição do Bem
		@Li,120 Psay (cAlsQry)->CODFAM                  // Código da Família
		@Li,150 Psay (cAlsQry)->SERVIC                  // Serviço
		@Li,180 Psay SubStr((cAlsQry)->NOMSER,1,20)     // Descrição do Serviço
		@Li,219 Psay (cAlsQry)->SEQUEN                  // Sequência

	EndIf

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT990ROD
Função que imprime as quantidades totais e de tempo das manutenções
do relatório.
@author Elynton Fellipe Bazzo
@since 21/02/2014
@return Nil
/*/
//---------------------------------------------------------------------
Static Function MNT990ROD()

	Local cBusca := ""

	If cTpVis == "2"     //Família
		cBusca := cCodFam
	ElseIf cTpVis == "3" //Tipo
		cBusca := cTipo
	ElseIf cTpVis == "4" //Área
		cBusca := cCodArea
	ElseIf cTpVis == "5" //Serviço
		cBusca := cCodSer
	ElseIf cTpVis == "6" //Prioridade
		cBusca := cCodPri
	ElseIf cTpVis == "7" //Status
		cBusca := cStatus
	EndIf

	NGSOMALI(58)//Pula linha
	NGSOMALI(58)

	If cTpVis == "1"   // Se a consulta for por ordem  e a visualização por TODOS.
		DBSelectArea( cAliMKB )
		If cTpCons == "1"
			@Li,005 Psay STR0076 // "Quantidade Total OS's.........:"
		Else
			@Li,005 Psay STR0100 // "Quantidade Total Manutenção...:"
		EndIf
	ElseIf cTpVis $ "23456" // Se a consulta for por ordem e a visualização por Família/Tipo/Area/Serviço/Prioridade.
		DBSelectArea( cAliMKB )
		DBSetOrder( 01 )
		DBSeek( cBusca )
		If cTpCons == "1"
			@Li,005 Psay STR0099 // "Quantidade O.S........:"
		Else
			@Li,005 Psay STR0093 // "Quantidade Manutenção.:"
		EndIf
	EndIf

	@Li,036 Psay (cAliMKB)->QNTATR 	Picture cPicForN
	NGSOMALI(58)
	@Li,005 Psay STR0094 // "Tempo Tot. Atraso.....:"
	@Li,036 Psay (cAliMKB)->MEDATO 	Picture cPicForN
	NGSOMALI(58)
	@Li,005 Psay STR0095 // "Tempo Méd. Atraso.....:"
	@Li,036 Psay (cAliMKB)->MEDATR 	Picture cPicForN
	NGSOMALI(58)
	@Li,005 Psay STR0096 // "Maior Tempo Atraso....:"
	@Li,036 Psay (cAliMKB)->MAXATR 	Picture cPicForN
	NGSOMALI(58)
	@Li,005 Psay STR0097 // "Menor Tempo Atraso....:"
	@Li,036 Psay (cAliMKB)->MINATR 	Picture cPicForN
	NGSOMALI(58)

	nQtdTotOs := nQtdTotOs + (cAliMKB)->QNTATR // Quantidade Total de O.S.
	nTemTotAt := nTemTotAt + (cAliMKB)->MEDATO // Tempo Total de Atraso.

Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} MNC990STJ
Função responsável por montar as Querys de Totalizadores e de Detalhes da tabela STJ
para os três bancos
(SQL, PostGres e Oracle)

@type Function

@author João Ricardo Santini Zandoná
@since 03/07/2024
@param cTpVisV, caractere, Tipo de visualização (agrupamento dos totalizadores) 
@param cChamada, caractere, Indica se a chamada da função foi realizada pelos Totalizadores(TOT) ou pelos Detalhes(DET)
@param aMarkd, array, indica quais totalizadores estão marcados no browse

@return cQuery, caractere, Query para verificar os registros na STJ já convertida conforme o banco
/*/ 
//------------------------------------------------------------------------------
Static Function MNC990STJ( cTpVisV, cChamada, aMarkd )

	Local cBanco := Upper(TCGetDB())
	Local cQuery := ''
	Local nI     := 1

	Default aMarkd := {}

	If cBanco == 'ORACLE'

		cQuery := 'SELECT '

		If cChamada == 'TOT'
		
			cQuery += 	'COUNT(STJ.TJ_ORDEM) AS QUANT, '
			cQuery +=	'SUM(CAST( ' + ValTOSQL(DTOS(dDataBase)) + ' AS DATE) - CAST( STJ.TJ_DTMPFIM AS DATE)) AS TOTAL, '
			cQuery +=	'MAX(CAST( ' + ValTOSQL(DTOS(dDataBase)) + ' AS DATE) - CAST( STJ.TJ_DTMPFIM AS DATE)) AS MAIOR, '
			cQuery +=	'MIN(CAST( ' + ValTOSQL(DTOS(dDataBase)) + ' AS DATE) - CAST( STJ.TJ_DTMPFIM AS DATE)) AS MENOR, '
			cQuery +=	'AVG(CAST( ' + ValTOSQL(DTOS(dDataBase)) + ' AS DATE) - CAST( STJ.TJ_DTMPFIM AS DATE)) AS MEDIA, '
			
			Do Case
				Case cTpVisV == '1'
					cQuery += ValToSQL(STR0054) + ' AS CODIGO, '
					cQuery += ValToSQL(STR0054) + ' AS DESCR '
				Case cTpVisV == '2'
					cQuery += 'CASE ' 
					cQuery += "WHEN STJ.TJ_TIPOOS = 'L' "
					cQuery += "THEN 'LOCALI' "
					cQuery += 'ELSE '
					cQuery += 	'ST9.T9_CODFAMI '
					cQuery += 'END AS CODIGO, '
					cQuery += 'CASE ' 
					cQuery += "WHEN STJ.TJ_TIPOOS = 'L' "
					cQuery += 'THEN ' + ValToSQL(STR0055)
					cQuery += 'ELSE '
					cQuery += 	'ST9.T9_CODFAMI '
					cQuery += 'END AS DESCR '
				Case cTpVisV == '3'
					cQuery += 'STE.TE_TIPOMAN AS CODIGO, '
					cQuery += 'STE.TE_TIPOMAN AS DESCR '
				Case cTpVisV == '4'
					cQuery += 'STD.TD_CODAREA AS CODIGO, '
					cQuery += 'STD.TD_CODAREA AS DESCR '
				Case cTpVisV == '5'
					cQuery += 'ST4.T4_SERVICO AS CODIGO, '
					cQuery += 'ST4.T4_SERVICO AS DESCR '
				Case cTpVisV == '6'
					cQuery += 'STJ.TJ_PRIORID AS CODIGO, '
					cQuery += 'STJ.TJ_PRIORID AS DESCR '
				Case cTpVisV == '7'
					cQuery += 'STJ.TJ_STFOLUP AS CODIGO, '
					cQuery += 'TQW.TQW_DESTAT AS DESCR '
			EndCase

		Else

			cQuery +=	'CAST( ' + ValTOSQL(DTOS(dDataBase)) + ' AS DATE) - CAST( STJ.TJ_DTMPFIM AS DATE) AS TMPATR, '
			cQuery +=	'STJ.TJ_ORDEM AS ORDEM, '
			cQuery +=	'STJ.TJ_PRIORID AS PRIORI, '
			cQuery +=	'STJ.TJ_CODBEM AS CODBEM, '

			cQuery += 	'CASE ' 
			cQuery +=	"WHEN STJ.TJ_TIPOOS = 'L' "
			cQuery +=	'THEN TAF.TAF_NOMNIV '
			cQuery +=	'ELSE '
			cQuery += 		'ST9.T9_NOME '
			cQuery += 	'END AS NOMBEM, '

			cQuery += 	'CASE ' 
			cQuery +=	"WHEN STJ.TJ_TIPOOS = 'L' "
			cQuery +=	'THEN ' + ValToSQL(STR0055)
			cQuery +=	'ELSE '
			cQuery += 		'ST9.T9_CODFAMI '
			cQuery += 	'END AS CODFAM, '

			cQuery +=	'STJ.TJ_SERVICO AS SERVIC, '
			cQuery +=	'ST4.T4_NOME AS NOMSER, '
			cQuery +=	'STJ.TJ_SEQRELA AS SEQUEN, '
			
			If cTpVisV == '7'

				cQuery +=	'STJ.TJ_STFOLUP AS STATUS, '
				cQuery +=	'TQW.TQW_DESTAT AS DESTAT, '

			Else

				cQuery +=	"' ' AS STATUS, "
				cQuery +=	"' ' AS DESTAT, "

			EndIf

			cQuery += 'STJ.TJ_PLANO AS PLANO, '
			cQuery += 'STJ.TJ_TIPO AS TIPO, '
			cQuery += 'STJ.TJ_CODAREA AS AREA, '
			cQuery += 'STJ.TJ_DTMPFIM AS DTPREV, '
			cQuery += 'STJ.R_E_C_N_O_ AS RECNBR '
		
		EndIf

		cQuery += 'FROM ' + RetSQLName( 'STJ' ) + ' STJ '
		cQuery += 'INNER JOIN ' + RetSQLName( 'ST9' ) + ' ST9 ON '
		cQuery += 	NGMODCOMP('ST9','STJ','=') + ' '
		cQuery += 	'AND ST9.T9_CODBEM = STJ.TJ_CODBEM '
		cQuery += 	"AND ST9.T9_SITBEM = 'A' "
		cQuery += 	"AND ST9.D_E_L_E_T_ = ' ' "
		
		If cChamada == 'TOT'

			Do Case
				Case cTpVisV == '3'
					cQuery += 'INNER JOIN ' + RetSQLName( 'STE' ) + ' STE ON '
					cQuery += NGMODCOMP('STE','STJ','=') + ' '
					cQuery += 'AND STE.TE_TIPOMAN = STJ.TJ_TIPO '
					cQuery += "AND STE.D_E_L_E_T_ = ' ' "
				Case cTpVisV == '4'
					cQuery += 'INNER JOIN ' + RetSQLName( 'STD' ) + ' STD ON '
					cQuery += NGMODCOMP('STD','STJ','=') + ' '
					cQuery += 'AND STD.TD_CODAREA = STJ.TJ_CODAREA '
					cQuery += "AND STD.D_E_L_E_T_ = ' ' "
				Case cTpVisV == '5'
					cQuery += 'INNER JOIN ' + RetSQLName( 'ST4' ) + ' ST4 ON '
					cQuery += NGMODCOMP('ST4','STJ','=') + ' '
					cQuery += 'AND ST4.T4_SERVICO = STJ.TJ_SERVICO '
					cQuery += "AND ST4.D_E_L_E_T_ = ' ' "
				Case cTpVisV == '7'
					cQuery += 'INNER JOIN ' + RetSQLName( 'TQW' ) + ' TQW ON '
					cQuery += NGMODCOMP('TQW','STJ','=') + ' '
					cQuery += 'AND TQW.TQW_STATUS = STJ.TJ_STFOLUP '
					cQuery += "AND TQW.D_E_L_E_T_ = ' ' "
			EndCase

		Else

			cQuery += 'LEFT JOIN ' + RetSQLName( 'TAF' ) + ' TAF ON '
			cQuery +=	NGMODCOMP('TAF','STJ','=') + ' '
			cQuery += 	"AND TAF.TAF_MODMNT = 'X' "
			cQuery += 	"AND TAF.TAF_INDCON = '2' "
			cQuery += 	'AND TAF.TAF_CODNIV = STJ.TJ_CODBEM '
			cQuery += 	"AND TAF.D_E_L_E_T_ = ' ' "

			cQuery += 'INNER JOIN ' + RetSQLName( 'ST4' ) + ' ST4 ON '
			cQuery += NGMODCOMP('ST4','STJ','=') + ' '
			cQuery += 'AND ST4.T4_SERVICO = STJ.TJ_SERVICO '
			cQuery += "AND ST4.D_E_L_E_T_ = ' ' "	
			
			If cTpVisV == '3'
				cQuery += 'INNER JOIN ' + RetSQLName( 'STE' ) + ' STE ON '
				cQuery += NGMODCOMP('STE','STJ','=') + ' '
				cQuery += 'AND STE.TE_TIPOMAN = STJ.TJ_TIPO '
				cQuery += "AND STE.D_E_L_E_T_ = ' ' "	
			Else
				If cTpVisV == '4'
					cQuery += 'INNER JOIN ' + RetSQLName( 'STD' ) + ' STD ON '
					cQuery += NGMODCOMP('STD','STJ','=') + ' '
					cQuery += 'AND STD.TD_CODAREA = STJ.TJ_CODAREA '
					cQuery += "AND STD.D_E_L_E_T_ = ' ' "
				Else
					If cTpVisV == '7'
						cQuery += 'INNER JOIN ' + RetSQLName( 'TQW' ) + ' TQW ON '
						cQuery += NGMODCOMP('TQW','STJ','=') + ' '
						cQuery += 'AND TQW.TQW_STATUS = STJ.TJ_STFOLUP '
						cQuery += "AND TQW.D_E_L_E_T_ = ' ' "
					EndIf
				EndIf
			EndIf

		EndIf

		cQuery += 'WHERE '
		cQuery += 	'STJ.TJ_FILIAL = ' + ValToSQL( FWxFilial( 'STJ' ) ) + ' '
		cQuery += 	'AND STJ.TJ_DTMPFIM < ' + ValToSQL( DTOS( dDataBase ) ) + ' '
		cQuery += 	"AND STJ.TJ_TERMINO = 'N' "
		cQuery += 	"AND STJ.D_E_L_E_T_ = ' ' "

		If !lChkLc

			cQuery += "AND STJ.TJ_TIPOOS <> 'L' "

		EndIf

		If !lChkBm

			cQuery += "AND STJ.TJ_TIPOOS <> 'B' "

		EndIf

		If cTpVisV != '7'

			cQuery += "AND STJ.TJ_SITUACA = 'L' "
		
		Else

			cQuery += "AND RTRIM(LTRIM(STJ.TJ_STFOLUP)) <> ' ' "

		EndIf

		If cChamada == 'DET'


			If cTpVisV != '1'

				Do Case 
					Case cTpVisV == '2'
						cQuery += 'AND ST9.T9_CODFAMI IN '
					Case cTpVisV == '3'
						cQuery += 'AND STE.TE_TIPOMAN IN '
					Case cTpVisV == '4'
						cQuery += 'AND STD.TD_CODAREA IN '
					Case cTpVisV == '5'
						cQuery += 'AND ST4.T4_SERVICO IN  '
					Case cTpVisV == '6'
						cQuery += 'AND STJ.TJ_PRIORID IN '
					Case cTpVisV == '7'
						cQuery += 'AND STJ.TJ_STFOLUP IN '
				EndCase
				
				cQuery += '('

				While nI <= len(aMarkd)

					cQuery += ValToSQL(aMarkd[nI])

					If nI != len(aMarkd)

						cQuery += ', '

					EndIf

					nI := nI + 1

				Enddo

				cQuery += ') '

			EndIf

		Else

			Do Case	
				Case cTpVisV == '2'
					cQuery += ' GROUP BY ROLLUP(ST9.T9_CODFAMI),STJ.TJ_TIPOOS '
				Case cTpVisV == '3'
					cQuery += 'GROUP BY ROLLUP(STE.TE_TIPOMAN) '
				Case cTpVisV == '4'
					cQuery += 'GROUP BY ROLLUP(STD.TD_CODAREA) '
				Case cTpVisV == '5'
					cQuery += 'GROUP BY ROLLUP(ST4.T4_SERVICO) '
				Case cTpVisV == '6'
					cQuery += 'GROUP BY ROLLUP(STJ.TJ_PRIORID) '
				Case cTpVisV == '7'
					cQuery += 'GROUP BY ROLLUP(TQW.TQW_DESTAT),STJ.TJ_STFOLUP '
			EndCase
			
		EndIf

	ElseIf cBanco == 'POSTGRES'

		cQuery := 'SELECT '

		If cChamada == 'TOT'

			cQuery += 	'COUNT(STJ.TJ_ORDEM) AS QUANT, '
			cQuery +=	'SUM( (CAST( ' + ValTOSQL(DTOS(dDataBase)) + ' AS DATE) - CAST( STJ.TJ_DTMPFIM  AS DATE ))::INT ) AS TOTAL, '
			cQuery +=	'MAX( (CAST( ' + ValTOSQL(DTOS(dDataBase)) + ' AS DATE) - CAST( STJ.TJ_DTMPFIM  AS DATE ))::INT ) AS MAIOR, '
			cQuery +=	'MIN( (CAST( ' + ValTOSQL(DTOS(dDataBase)) + ' AS DATE) - CAST( STJ.TJ_DTMPFIM  AS DATE ))::INT ) AS MENOR, '
			cQuery +=	'AVG( (CAST( ' + ValTOSQL(DTOS(dDataBase)) + ' AS DATE) - CAST( STJ.TJ_DTMPFIM  AS DATE ))::INT ) AS MEDIA, '

			Do Case
				Case cTpVisV == '1'
					cQuery += ValToSQL(STR0054) + ' AS CODIGO, '
					cQuery += ValToSQL(STR0054) + ' AS DESCR '
				Case cTpVisV == '2'
					cQuery += 'CASE ' 
					cQuery += "WHEN STJ.TJ_TIPOOS = 'L' "
					cQuery += "THEN 'LOCALI' "
					cQuery += 'ELSE '
					cQuery += 	'ST9.T9_CODFAMI '
					cQuery += 'END AS CODIGO, '
					cQuery += 'CASE ' 
					cQuery += "WHEN STJ.TJ_TIPOOS = 'L' "
					cQuery += 'THEN ' + ValToSQL(STR0055)
					cQuery += 'ELSE '
					cQuery += 	'ST9.T9_CODFAMI '
					cQuery += 'END AS DESCR '
				Case cTpVisV == '3'
					cQuery += 'STE.TE_TIPOMAN AS CODIGO, '
					cQuery += 'STE.TE_TIPOMAN AS DESCR '
				Case cTpVisV == '4'
					cQuery += 'STD.TD_CODAREA AS CODIGO, '
					cQuery += 'STD.TD_CODAREA AS DESCR '
				Case cTpVisV == '5'
					cQuery += 'ST4.T4_SERVICO AS CODIGO, '
					cQuery += 'ST4.T4_SERVICO AS DESCR '
				Case cTpVisV == '6'
					cQuery += 'STJ.TJ_PRIORID AS CODIGO, '
					cQuery += 'STJ.TJ_PRIORID AS DESCR '
				Case cTpVisV == '7'
					cQuery += 'STJ.TJ_STFOLUP AS CODIGO, '
					cQuery += 'TQW.TQW_DESTAT AS DESCR '
			EndCase

		Else

			cQuery +=	'(CAST( ' + ValTOSQL(DTOS(dDataBase)) + ' AS DATE) - CAST( STJ.TJ_DTMPFIM  AS DATE ))::INT AS TMPATR, '
			cQuery +=	'STJ.TJ_ORDEM AS ORDEM, '
			cQuery +=	'STJ.TJ_PRIORID AS PRIORI, '
			cQuery +=	'STJ.TJ_CODBEM AS CODBEM, '

			cQuery += 	'CASE ' 
			cQuery +=	"WHEN STJ.TJ_TIPOOS = 'L' "
			cQuery +=	'THEN TAF.TAF_NOMNIV '
			cQuery +=	'ELSE '
			cQuery += 		'ST9.T9_NOME '
			cQuery += 	'END AS NOMBEM, '

			cQuery += 	'CASE ' 
			cQuery +=	"WHEN STJ.TJ_TIPOOS = 'L' "
			cQuery +=	'THEN ' + ValToSQL(STR0055)
			cQuery +=	'ELSE '
			cQuery += 		'ST9.T9_CODFAMI '
			cQuery += 	'END AS CODFAM, '

			cQuery +=	'STJ.TJ_SERVICO AS SERVIC, '
			cQuery +=	'ST4.T4_NOME AS NOMSER, '
			cQuery +=	'STJ.TJ_SEQRELA AS SEQUEN, '
			
			If cTpVisV == '7'

				cQuery +=	'STJ.TJ_STFOLUP AS STATUS, '
				cQuery +=	'TQW.TQW_DESTAT AS DESTAT, '

			Else

				cQuery +=	"' ' AS STATUS, "
				cQuery +=	"' ' AS DESTAT, "

			EndIf

			cQuery += 'STJ.TJ_PLANO AS PLANO, '
			cQuery += 'STJ.TJ_TIPO AS TIPO, '
			cQuery += 'STJ.TJ_CODAREA AS AREA, '
			cQuery += 'STJ.TJ_DTMPFIM AS DTPREV, '
			cQuery += 'STJ.R_E_C_N_O_ AS RECNBR '

		EndIf
		
		cQuery += 'FROM ' + RetSQLName( 'STJ' ) + ' STJ '
		cQuery += 'INNER JOIN ' + RetSQLName( 'ST9' ) + ' ST9 ON '
		cQuery += 	NGMODCOMP('ST9','STJ','=') + ' '
		cQuery += 	'AND ST9.T9_CODBEM = STJ.TJ_CODBEM '
		cQuery += 	"AND ST9.T9_SITBEM = 'A' "
		cQuery += 	"AND ST9.D_E_L_E_T_ = ' ' "
		
		If cChamada == 'TOT'

			Do Case
				Case cTpVisV == '3'
					cQuery += 'INNER JOIN ' + RetSQLName( 'STE' ) + ' STE ON '
					cQuery += NGMODCOMP('STE','STJ','=') + ' '
					cQuery += 'AND STE.TE_TIPOMAN = STJ.TJ_TIPO '
					cQuery += "AND STE.D_E_L_E_T_ = ' ' "
				Case cTpVisV == '4'
					cQuery += 'INNER JOIN ' + RetSQLName( 'STD' ) + ' STD ON '
					cQuery += NGMODCOMP('STD','STJ','=') + ' '
					cQuery += 'AND STD.TD_CODAREA = STJ.TJ_CODAREA '
					cQuery += "AND STD.D_E_L_E_T_ = ' ' "
				Case cTpVisV == '5'
					cQuery += 'INNER JOIN ' + RetSQLName( 'ST4' ) + ' ST4 ON '
					cQuery += NGMODCOMP('ST4','STJ','=') + ' '
					cQuery += 'AND ST4.T4_SERVICO = STJ.TJ_SERVICO '
					cQuery += "AND ST4.D_E_L_E_T_ = ' ' "	
				Case cTpVisV == '7'
					cQuery += 'INNER JOIN ' + RetSQLName( 'TQW' ) + ' TQW ON '
					cQuery += NGMODCOMP('TQW','STJ','=') + ' '
					cQuery += 'AND TQW.TQW_STATUS = STJ.TJ_STFOLUP '
					cQuery += "AND TQW.D_E_L_E_T_ = ' ' "
			EndCase

		Else

			cQuery += 'LEFT JOIN ' + RetSQLName( 'TAF' ) + ' TAF ON '
			cQuery +=	NGMODCOMP('TAF','STJ','=') + ' '
			cQuery += 	"AND TAF.TAF_MODMNT = 'X' "
			cQuery += 	"AND TAF.TAF_INDCON = '2' "
			cQuery += 	'AND TAF.TAF_CODNIV = STJ.TJ_CODBEM '
			cQuery += 	"AND TAF.D_E_L_E_T_ = ' ' "

			cQuery += 'INNER JOIN ' + RetSQLName( 'ST4' ) + ' ST4 ON '
			cQuery += NGMODCOMP('ST4','STJ','=') + ' '
			cQuery += 'AND ST4.T4_SERVICO = STJ.TJ_SERVICO '
			cQuery += "AND ST4.D_E_L_E_T_ = ' ' "	
			
			If cTpVisV == '3'
				cQuery += 'INNER JOIN ' + RetSQLName( 'STE' ) + ' STE ON '
				cQuery += NGMODCOMP('STE','STJ','=') + ' '
				cQuery += 'AND STE.TE_TIPOMAN = STJ.TJ_TIPO '
				cQuery += "AND STE.D_E_L_E_T_ = ' ' "	
			Else
				If cTpVisV == '4'
					cQuery += 'INNER JOIN ' + RetSQLName( 'STD' ) + ' STD ON '
					cQuery += NGMODCOMP('STD','STJ','=') + ' '
					cQuery += 'AND STD.TD_CODAREA = STJ.TJ_CODAREA '
					cQuery += "AND STD.D_E_L_E_T_ = ' ' "
				Else
					If cTpVisV == '7'
						cQuery += 'INNER JOIN ' + RetSQLName( 'TQW' ) + ' TQW ON '
						cQuery += NGMODCOMP('TQW','STJ','=') + ' '
						cQuery += 'AND TQW.TQW_STATUS = STJ.TJ_STFOLUP '
						cQuery += "AND TQW.D_E_L_E_T_ = ' ' "
					EndIf
				EndIf
			EndIf

		EndIf

		cQuery += 'WHERE '
		cQuery += 	'STJ.TJ_FILIAL = ' + ValToSQL( FWxFilial( 'STJ' ) ) + ' '
		cQuery += 	'AND STJ.TJ_DTMPFIM < ' + ValToSQL( DTOS( dDataBase ) ) + ' '
		cQuery += 	"AND STJ.TJ_TERMINO = 'N' "
		cQuery += 	"AND STJ.D_E_L_E_T_ = ' ' "

		If !lChkLc

			cQuery += "AND STJ.TJ_TIPOOS <> 'L' "

		EndIf

		If !lChkBm

			cQuery += "AND STJ.TJ_TIPOOS <> 'B' "

		EndIf

		If cTpVisV != '7'

			cQuery += "AND STJ.TJ_SITUACA = 'L' "
		
		Else

			cQuery += "AND RTRIM(LTRIM(STJ.TJ_STFOLUP)) <> ' ' "

		EndIf

		If cChamada == 'DET'
			
			If cTpVisV != '1'

				Do Case
					Case cTpVisV == '2'
						cQuery += 'AND ST9.T9_CODFAMI IN '
					Case cTpVisV == '3'
						cQuery += 'AND STE.TE_TIPOMAN IN '
					Case cTpVisV == '4'
						cQuery += 'AND STD.TD_CODAREA IN '
					Case cTpVisV == '5'
						cQuery += 'AND ST4.T4_SERVICO IN  '
					Case cTpVisV == '6'
						cQuery += 'AND STJ.TJ_PRIORID IN '
					Case cTpVisV == '7'
						cQuery += 'AND STJ.TJ_STFOLUP IN '
				EndCase
				
				cQuery += '('

				While nI <= len(aMarkd)

					cQuery += ValToSQL(aMarkd[nI])

					If nI != len(aMarkd)

						cQuery += ', '

					EndIf

					nI := nI + 1

				Enddo

				cQuery += ') '

			EndIf

		Else
			
			Do Case
				Case cTpVisV == '2'
					cQuery += ' GROUP BY ROLLUP(ST9.T9_CODFAMI),STJ.TJ_TIPOOS '
				Case cTpVisV == '3'
					cQuery += 'GROUP BY ROLLUP(STE.TE_TIPOMAN) '
				Case cTpVisV == '4'
					cQuery += 'GROUP BY ROLLUP(STD.TD_CODAREA) '
				Case cTpVisV == '5'
					cQuery += 'GROUP BY ROLLUP(ST4.T4_SERVICO) '
				Case cTpVisV == '6'
					cQuery += 'GROUP BY ROLLUP(STJ.TJ_PRIORID) '
				Case cTpVisV == '7'
					cQuery += 'GROUP BY ROLLUP(TQW.TQW_DESTAT),STJ.TJ_STFOLUP '
			EndCase

		EndIf

	Else

		cQuery := 'SELECT '

		If cChamada == 'TOT'

			cQuery += 	'COUNT(STJ.TJ_ORDEM) AS QUANT, '
			cQuery +=	'SUM(DATEDIFF(day, CONVERT(DATE, STJ.TJ_DTMPFIM, 103), CONVERT(DATE, ' + ValTOSQL(DTOS(dDataBase)) + ', 103))) AS TOTAL, '
			cQuery +=	'MAX(DATEDIFF(day, CONVERT(DATE, STJ.TJ_DTMPFIM, 103), CONVERT(DATE, ' + ValTOSQL(DTOS(dDataBase)) + ', 103))) AS MAIOR, '
			cQuery +=	'MIN(DATEDIFF(day, CONVERT(DATE, STJ.TJ_DTMPFIM, 103), CONVERT(DATE, ' + ValTOSQL(DTOS(dDataBase)) + ', 103))) AS MENOR, '
			cQuery +=	'AVG(DATEDIFF(day, CONVERT(DATE, STJ.TJ_DTMPFIM, 103), CONVERT(DATE, ' + ValTOSQL(DTOS(dDataBase)) + ', 103))) AS MEDIA, '
			
			Do Case
				Case cTpVisV == '1'
					cQuery += ValToSQL(STR0054) + ' AS CODIGO, '
					cQuery += ValToSQL(STR0054) + ' AS DESCR '
				Case cTpVisV == '2'
					cQuery += 'CASE ' 
					cQuery += "WHEN STJ.TJ_TIPOOS = 'L' "
					cQuery += "THEN 'LOCALI' "
					cQuery += 'ELSE '
					cQuery += 	'ST9.T9_CODFAMI '
					cQuery += 'END AS CODIGO, '
					cQuery += 'CASE ' 
					cQuery += "WHEN STJ.TJ_TIPOOS = 'L' "
					cQuery += 'THEN ' + ValToSQL(STR0055)
					cQuery += 'ELSE '
					cQuery += 	'ST9.T9_CODFAMI '
					cQuery += 'END AS DESCR '
				Case cTpVisV == '3'
					cQuery += 'STE.TE_TIPOMAN AS CODIGO, '
					cQuery += 'STE.TE_TIPOMAN AS DESCR '
				Case cTpVisV == '4'
					cQuery += 'STD.TD_CODAREA AS CODIGO, '
					cQuery += 'STD.TD_CODAREA AS DESCR '
				Case cTpVisV == '5'
					cQuery += 'ST4.T4_SERVICO AS CODIGO, '
					cQuery += 'ST4.T4_SERVICO AS DESCR '
				Case cTpVisV == '6'
					cQuery += 'STJ.TJ_PRIORID AS CODIGO, '
					cQuery += 'STJ.TJ_PRIORID AS DESCR '
				Case cTpVisV == '7'
					cQuery += 'STJ.TJ_STFOLUP AS CODIGO, '
					cQuery += 'TQW.TQW_DESTAT AS DESCR '
			EndCase
		
		Else

			cQuery +=	'DATEDIFF(day, CONVERT(DATE, STJ.TJ_DTMPFIM, 103), CONVERT(DATE, ' + ValTOSQL(DTOS(dDataBase)) + ', 103)) AS TMPATR, '
			cQuery +=	'STJ.TJ_ORDEM AS ORDEM, '
			cQuery +=	'STJ.TJ_PRIORID AS PRIORI, '
			cQuery +=	'STJ.TJ_CODBEM AS CODBEM, '

			cQuery += 	'CASE ' 
			cQuery +=	"WHEN STJ.TJ_TIPOOS = 'L' "
			cQuery +=	'THEN TAF.TAF_NOMNIV '
			cQuery +=	'ELSE '
			cQuery += 		'ST9.T9_NOME '
			cQuery += 	'END AS NOMBEM, '

			cQuery += 	'CASE ' 
			cQuery +=	"WHEN STJ.TJ_TIPOOS = 'L' "
			cQuery +=	'THEN ' + ValToSQL(STR0055)
			cQuery +=	'ELSE '
			cQuery += 		'ST9.T9_CODFAMI '
			cQuery += 	'END AS CODFAM, '

			cQuery +=	'STJ.TJ_SERVICO AS SERVIC, '
			cQuery +=	'ST4.T4_NOME AS NOMSER, '
			cQuery +=	'STJ.TJ_SEQRELA AS SEQUEN, '
			
			If cTpVisV == '7'

				cQuery +=	'STJ.TJ_STFOLUP AS STATUS, '
				cQuery +=	'TQW.TQW_DESTAT AS DESTAT, '

			Else

				cQuery +=	"' ' AS STATUS, "
				cQuery +=	"' ' AS DESTAT, "

			EndIf

			cQuery += 'STJ.TJ_PLANO AS PLANO, '
			cQuery += 'STJ.TJ_TIPO AS TIPO, '
			cQuery += 'STJ.TJ_CODAREA AS AREA, '
			cQuery += 'STJ.TJ_DTMPFIM AS DTPREV, '
			cQuery += 'STJ.R_E_C_N_O_ AS RECNBR '

		EndIf

		cQuery += 'FROM ' + RetSQLName( 'STJ' ) + ' STJ '
		cQuery += 'INNER JOIN ' + RetSQLName( 'ST9' ) + ' ST9 ON '
		cQuery += 	NGMODCOMP('ST9','STJ','=') + ' '
		cQuery += 	'AND ST9.T9_CODBEM = STJ.TJ_CODBEM '
		cQuery += 	"AND ST9.T9_SITBEM = 'A' "
		cQuery += 	"AND ST9.D_E_L_E_T_ = ' ' "
		
		If cChamada == 'TOT'

			Do Case
				Case cTpVisV == '3'
					cQuery += 'INNER JOIN ' + RetSQLName( 'STE' ) + ' STE ON '
					cQuery += NGMODCOMP('STE','STJ','=') + ' '
					cQuery += 'AND STE.TE_TIPOMAN = STJ.TJ_TIPO '
					cQuery += "AND STE.D_E_L_E_T_ = ' ' "	
				Case cTpVisV == '4'
					cQuery += 'INNER JOIN ' + RetSQLName( 'STD' ) + ' STD ON '
					cQuery += NGMODCOMP('STD','STJ','=') + ' '
					cQuery += 'AND STD.TD_CODAREA = STJ.TJ_CODAREA '
					cQuery += "AND STD.D_E_L_E_T_ = ' ' "
				Case cTpVisV == '5'
					cQuery += 'INNER JOIN ' + RetSQLName( 'ST4' ) + ' ST4 ON '
					cQuery += NGMODCOMP('ST4','STJ','=') + ' '
					cQuery += 'AND ST4.T4_SERVICO = STJ.TJ_SERVICO '
					cQuery += "AND ST4.D_E_L_E_T_ = ' ' "
				Case cTpVisV == '7'
					cQuery += 'INNER JOIN ' + RetSQLName( 'TQW' ) + ' TQW ON '
					cQuery += NGMODCOMP('TQW','STJ','=') + ' '
					cQuery += 'AND TQW.TQW_STATUS = STJ.TJ_STFOLUP '
					cQuery += "AND TQW.D_E_L_E_T_ = ' ' "
			EndCase

		Else

			cQuery += 'LEFT JOIN ' + RetSQLName( 'TAF' ) + ' TAF ON '
			cQuery +=	NGMODCOMP('TAF','STJ','=') + ' '
			cQuery += 	"AND TAF.TAF_MODMNT = 'X' "
			cQuery += 	"AND TAF.TAF_INDCON = '2' "
			cQuery += 	'AND TAF.TAF_CODNIV = STJ.TJ_CODBEM '
			cQuery += 	"AND TAF.D_E_L_E_T_ = ' ' "

			cQuery += 'INNER JOIN ' + RetSQLName( 'ST4' ) + ' ST4 ON '
			cQuery += NGMODCOMP('ST4','STJ','=') + ' '
			cQuery += 'AND ST4.T4_SERVICO = STJ.TJ_SERVICO '
			cQuery += "AND ST4.D_E_L_E_T_ = ' ' "	
			
			If cTpVisV == '3'
				cQuery += 'INNER JOIN ' + RetSQLName( 'STE' ) + ' STE ON '
				cQuery += NGMODCOMP('STE','STJ','=') + ' '
				cQuery += 'AND STE.TE_TIPOMAN = STJ.TJ_TIPO '
				cQuery += "AND STE.D_E_L_E_T_ = ' ' "	
			Else
				If cTpVisV == '4'
					cQuery += 'INNER JOIN ' + RetSQLName( 'STD' ) + ' STD ON '
					cQuery += NGMODCOMP('STD','STJ','=') + ' '
					cQuery += 'AND STD.TD_CODAREA = STJ.TJ_CODAREA '
					cQuery += "AND STD.D_E_L_E_T_ = ' ' "
				Else
					If cTpVisV == '7'
						cQuery += 'INNER JOIN ' + RetSQLName( 'TQW' ) + ' TQW ON '
						cQuery += NGMODCOMP('TQW','STJ','=') + ' '
						cQuery += 'AND TQW.TQW_STATUS = STJ.TJ_STFOLUP '
						cQuery += "AND TQW.D_E_L_E_T_ = ' ' "
					EndIf
				EndIf
			EndIf

		EndIf

		cQuery += 'WHERE '
		cQuery += 	'STJ.TJ_FILIAL = ' + ValToSQL( FWxFilial( 'STJ' ) ) + ' '
		cQuery += 	'AND STJ.TJ_DTMPFIM < ' + ValToSQL( DTOS( dDataBase ) ) + ' '
		cQuery += 	"AND STJ.TJ_TERMINO = 'N' "
		cQuery += 	"AND STJ.D_E_L_E_T_ = ' ' "

		If !lChkLc

			cQuery += "AND STJ.TJ_TIPOOS <> 'L' "

		EndIf

		If !lChkBm

			cQuery += "AND STJ.TJ_TIPOOS <> 'B' "

		EndIf

		If cTpVisV != '7'

			cQuery += "AND STJ.TJ_SITUACA = 'L' "
		
		Else

			cQuery += "AND RTRIM(LTRIM(STJ.TJ_STFOLUP)) <> ' ' "

		EndIf

		If cChamada == 'DET'
			
			If cTpVisV != '1'

				Do Case
					Case cTpVisV == '2'
						cQuery += 'AND ST9.T9_CODFAMI IN '
					Case cTpVisV == '3'
						cQuery += 'AND STE.TE_TIPOMAN IN '
					Case cTpVisV == '4'
						cQuery += 'AND STD.TD_CODAREA IN '
					Case cTpVisV == '5'
						cQuery += 'AND ST4.T4_SERVICO IN  '
					Case cTpVisV == '6'
						cQuery += 'AND STJ.TJ_PRIORID IN '
					Case cTpVisV == '7'
						cQuery += 'AND STJ.TJ_STFOLUP IN '
				EndCase
				
				cQuery += '('

				While nI <= len(aMarkd)

					cQuery += ValToSQL(aMarkd[nI])

					If nI != len(aMarkd)

						cQuery += ', '

					EndIf

					nI := nI + 1

				Enddo

				cQuery += ') '

			EndIf

		Else

			Do Case
				Case cTpVisV == '2'
					cQuery += ' GROUP BY ROLLUP(ST9.T9_CODFAMI),STJ.TJ_TIPOOS '
				Case cTpVisV == '3'
					cQuery += 'GROUP BY ROLLUP(STE.TE_TIPOMAN) '
				Case cTpVisV == '4'
					cQuery += 'GROUP BY ROLLUP(STD.TD_CODAREA) '
				Case cTpVisV == '5'
					cQuery += 'GROUP BY ROLLUP(ST4.T4_SERVICO) '
				Case cTpVisV == '6'
					cQuery += 'GROUP BY ROLLUP(STJ.TJ_PRIORID) '
				Case cTpVisV == '7'
					cQuery += 'GROUP BY ROLLUP(TQW.TQW_DESTAT),STJ.TJ_STFOLUP '
			EndCase

		EndIf

	EndIf

	cQuery := ChangeQuery( cQuery )

Return cQuery

//------------------------------------------------------------------------------
/*/{Protheus.doc} MNC990STF
Função responsável por montar as Querys de Totalizadores e de Detalhes da tabela STF
para os três bancos
(SQL, PostGres e Oracle)

@type Function

@author João Ricardo Santini Zandoná
@since 03/07/2024
@param cTpVisV, caractere, Tipo de visualização (agrupamento dos totalizadores) 
@param cChamada, caractere, Indica se a chamada da função foi realizada pelos Totalizadores(TOT) ou pelos Detalhes(DET)
@param aMarkd, array, indica quais totalizadores estão marcados no browse

@return cQuery, caractere, Query para verificar os registros na STF já convertida conforme o banco
/*/ 
//------------------------------------------------------------------------------
Static Function MNC990STF( cTpVisV, cChamada, aMarkd )

	Local cBanco := Upper(TCGetDB())
	Local cQuery := ''
	Local nI     := 1

	Default aMarkD := {}

	If cBanco == 'ORACLE'

		cQuery := 'SELECT '

		If cChamada == 'TOT'

			cQuery +=	'CODIGO, '
			cQuery +=	'DESCR, '
			cQuery += 	'COUNT(TF_FILIAL) AS QUANT, '
			cQuery +=	'AVG( CAST(' + ValTOSQL(DTOS(dDataBase)) + 'AS DATE) - CAST( DT AS DATE )) AS MEDIA, '
			cQuery +=	'SUM( CAST(' + ValTOSQL(DTOS(dDataBase)) + 'AS DATE) - CAST( DT AS DATE )) AS TOTAL, '
			cQuery +=	'MAX( CAST(' + ValTOSQL(DTOS(dDataBase)) + 'AS DATE) - CAST( DT AS DATE )) AS MAIOR, '
			cQuery +=	'MIN( CAST(' + ValTOSQL(DTOS(dDataBase)) + 'AS DATE) - CAST( DT AS DATE )) AS MENOR '

		Else

			cQuery +=	'CAST(' + ValTOSQL(DTOS(dDataBase)) + 'AS DATE) - CAST( DT AS DATE ) AS TMPATR, '
			cQuery +=	'DT AS DTPREV, '
			cQuery +=	'TF_PRIORID AS PRIORI, '
			cQuery +=	'TF_CODBEM AS CODBEM, '
			cQuery +=	'T9_NOME AS NOMBEM, '
			cQuery +=	'TF_SERVICO AS SERVIC, '
			cQuery +=	'TF_SEQRELA AS SEQUEN, '
			cQuery +=	'T4_NOME AS NOMSER, '
			cQuery +=	'T9_CODFAMI AS CODFAM, '
			cQuery +=	'TF_TIPO AS TIPO, '
			cQuery +=	'R_E_C_N_O_ AS RECNBR '

		EndIf

		cQuery += 'FROM ( '
		cQuery += 'SELECT '
		cQuery += 'STF.TF_FILIAL, '
		cQuery += 'STF.TF_TOLERA, '
		cQuery += 'CASE '
		cQuery +=	'WHEN '
		cQuery +=		"STF.TF_TIPACOM = 'T' "
		cQuery +=	'THEN (CASE '
		cQuery +=		   'WHEN '
		cQuery +=			   "STF.TF_UNENMAN = 'D' "
		cQuery +=		   'THEN (STF.TF_TEENMAN + STF.TF_TOLERA) + CAST( STF.TF_DTULTMA AS DATE ) '
		cQuery +=		   'WHEN '
		cQuery +=		   	   "STF.TF_UNENMAN = 'S' "
		cQuery +=		   'THEN ((STF.TF_TEENMAN * 7) + STF.TF_TOLERA) + CAST( STF.TF_DTULTMA AS DATE ) '
		cQuery +=		   'WHEN '
		cQuery +=				"STF.TF_UNENMAN = 'M' "
		cQuery +=		   'THEN ((STF.TF_TEENMAN * 30 ) + STF.TF_TOLERA) + CAST( STF.TF_DTULTMA AS DATE ) '
		cQuery +=		   'ELSE '
		cQuery +=	 			  '((STF.TF_TEENMAN / 24) + STF.TF_TOLERA) + CAST( STF.TF_DTULTMA AS DATE ) '
		cQuery +=		   'END ) '
		// Tipo de acompanhamento Contador, Produção e Contador Fixo
		cQuery +=	'WHEN '
		cQuery +=		"STF.TF_TIPACOM = 'C' "
		cQuery +=		"OR STF.TF_TIPACOM = 'P' "
		cQuery +=		"OR STF.TF_TIPACOM = 'F' "
		cQuery +=	'THEN '
		cQuery +=		'((STF.TF_INENMAN - STF.TF_TOLECON)/ST9.T9_VARDIA) + CAST( STF.TF_DTULTMA AS DATE ) '
		// Tipo de acompanhamento Segundo Contador
		cQuery +=	'WHEN '
		cQuery +=		"STF.TF_TIPACOM = 'S' "
		cQuery +=	'THEN (CASE '
		cQuery +=			'WHEN '
		cQuery +=		'((STF.TF_CONMANU + STF.TF_INENMAN) + STF.TF_TOLECON) < TPE.TPE_POSCON '
		cQuery +=		'THEN '
		cQuery +=			'((STF.TF_INENMAN + STF.TF_TOLECON)/TPE.TPE_VARDIA) + CAST( STF.TF_DTULTMA AS DATE) '    
		cQuery +=		'ELSE '
		cQuery +=			'CAST( STF.TF_DTULTMA AS DATE) '
		cQuery +=		'END ) '
		cQuery +=	'ELSE '
		// Tipo de acompanhamento Tempo / Contador - Precisa calcular os dois
		cQuery +=		'CASE '
		cQuery +=			'WHEN '
		cQuery +=				'(CASE '
		cQuery +=		   		'WHEN '
		cQuery +=			    	"STF.TF_UNENMAN = 'D' "
		cQuery +=				'THEN (STF.TF_TEENMAN + STF.TF_TOLERA) + CAST( STF.TF_DTULTMA AS DATE ) '
		cQuery +=		   		'WHEN '
		cQuery +=		   	    	"STF.TF_UNENMAN = 'S' "
		cQuery +=		   		'THEN ((STF.TF_TEENMAN * 7) + STF.TF_TOLERA) + CAST( STF.TF_DTULTMA AS DATE ) '
		cQuery +=		   		'WHEN '
		cQuery +=					"STF.TF_UNENMAN = 'M' "
		cQuery +=		   		'THEN ((STF.TF_TEENMAN * 30 ) + STF.TF_TOLERA) + CAST( STF.TF_DTULTMA AS DATE ) '
		cQuery +=		   		'ELSE '
		cQuery +=	 				  '((STF.TF_TEENMAN / 24) + STF.TF_TOLERA) + CAST( STF.TF_DTULTMA AS DATE ) '
		cQuery +=		   		'END ) < '
		cQuery +=				'((STF.TF_INENMAN - STF.TF_TOLECON)/ST9.T9_VARDIA) + CAST( STF.TF_DTULTMA AS DATE ) '				     
		cQuery +=			'THEN '
		cQuery +=				'(CASE '
		cQuery +=		   		'WHEN '
		cQuery +=			    	"STF.TF_UNENMAN = 'D' "
		cQuery +=				'THEN (STF.TF_TEENMAN + STF.TF_TOLERA) + CAST( STF.TF_DTULTMA AS DATE ) '
		cQuery +=		   		'WHEN '
		cQuery +=		   	    	"STF.TF_UNENMAN = 'S' "
		cQuery +=		   		'THEN ((STF.TF_TEENMAN * 7) + STF.TF_TOLERA) + CAST( STF.TF_DTULTMA AS DATE ) '
		cQuery +=		   		'WHEN '
		cQuery +=					"STF.TF_UNENMAN = 'M' "
		cQuery +=		   		'THEN ((STF.TF_TEENMAN * 30 ) + STF.TF_TOLERA) + CAST( STF.TF_DTULTMA AS DATE ) '
		cQuery +=		   		'ELSE '
		cQuery +=	 				  '((STF.TF_TEENMAN / 24) + STF.TF_TOLERA) + CAST( STF.TF_DTULTMA AS DATE ) '
		cQuery +=		   		'END ) '
		cQuery +=			'ELSE '
		cQuery +=				'((STF.TF_INENMAN - STF.TF_TOLECON)/ST9.T9_VARDIA) + CAST( STF.TF_DTULTMA AS DATE ) '					
		cQuery +=			'END '
		cQuery +=	'END AS DT, '
		cQuery += 'STF.TF_TIPACOM, '
		
		If cChamada == 'TOT'
			// Campos CODIGO e DESCRICAO
			Do Case
				Case cTpVisV == '1'
					cQuery += ValToSQL(STR0054) + ' AS CODIGO, '
					cQuery += ValToSQL(STR0054) + ' AS DESCR '
				Case cTpVisV == '2'
					cQuery += 'ST9.T9_CODFAMI AS CODIGO, ' 
					cQuery += 'ST9.T9_CODFAMI AS DESCR '
				Case cTpVisV == '3'
					cQuery += 'STF.TF_TIPO AS CODIGO, '
					cQuery += 'STF.TF_TIPO AS DESCR '
				Case cTpVisV == '4'
					cQuery += 'STF.TF_CODAREA AS CODIGO, '
					cQuery += 'STF.TF_CODAREA AS DESCR '
				Case cTpVisV == '5'
					cQuery += 'STF.TF_SERVICO AS CODIGO, '
					cQuery += 'STF.TF_SERVICO AS DESCR '
				Case cTpVisV == '6'
					cQuery += 'STF.TF_PRIORID AS CODIGO, '
					cQuery += 'STF.TF_PRIORID AS DESCR '
			EndCase

		Else

			cQuery += 'STF.TF_PRIORID, '
			cQuery += 'STF.TF_CODBEM, '
			cQuery += 'ST9.T9_NOME, '
			cQuery += 'STF.TF_SERVICO, '
			cQuery += 'STF.TF_SEQRELA, '
			cQuery += 'ST4.T4_NOME, '
			cQuery += 'ST9.T9_CODFAMI, '
			cQuery += 'STF.TF_TIPO, '
			cQuery += 'STF.R_E_C_N_O_ '

		EndIf

		cQuery += 'FROM ' + RetSQLName( 'STF' ) + ' STF '
		cQuery += 'INNER JOIN ' + RetSQLName( 'ST9' ) + ' ST9 ON '
		cQuery += 	NGMODCOMP('ST9','STF','=') + ' '
		cQuery += 	'AND ST9.T9_CODBEM = STF.TF_CODBEM '
		cQuery += 	"AND ST9.T9_SITBEM = 'A' "
		cQuery +=	"AND ST9.T9_SITMAN = 'A'"
		cQuery += 	"AND ST9.D_E_L_E_T_ = ' ' "

		If cChamada == 'DET'

			cQuery += 'INNER JOIN ' + RetSQLName( 'ST4' ) + ' ST4 ON '
			cQuery += NGMODCOMP('ST4','STF','=') + ' '
			cQuery += 'AND ST4.T4_SERVICO = STF.TF_SERVICO '
			cQuery += "AND ST4.D_E_L_E_T_ = ' ' "	

		EndIf

		cQuery += 'LEFT JOIN ' + RetSQLName( 'TPE' ) + ' TPE ON '
		cQuery += 	NGMODCOMP('TPE','STF','=') + ' '
		cQuery +=	'AND TPE.TPE_CODBEM = STF.TF_CODBEM '
		cQuery +=	"AND TPE.D_E_L_E_T_ = ' ' "
		cQuery += 'WHERE '
		cQuery += 	'STF.TF_FILIAL = ' + ValToSQL( FWxFilial( 'STF' ) ) + ' '
		cQuery +=	"AND STF.TF_ATIVO = 'S' "
		cQuery +=	"AND STF.TF_PERIODO <> 'E' "
		cQuery +=	"AND (((STF.TF_TIPACOM = 'C'"
		cQuery +=	"OR STF.TF_TIPACOM = 'P'"
		cQuery +=	"OR STF.TF_TIPACOM = 'F'"
		cQuery +=	"OR STF.TF_TIPACOM = 'A') "
		cQuery +=	"AND ST9.T9_VARDIA <> 0) "
		cQuery +=	"OR (STF.TF_TIPACOM = 'T' "
		cQuery +=	"OR STF.TF_TIPACOM = 'S'))"
		cQuery += 	"AND STF.D_E_L_E_T_ = ' ' "

		If cChamada == 'DET'

			If cTpVisV != '1'
				Do Case
					Case cTpVisV == '2' 
						cQuery += 'AND ST9.T9_CODFAMI IN '
					Case cTpVisV == '3'
						cQuery += 'AND STF.TF_TIPO IN '
					Case cTpVisV == '4'
						cQuery += 'AND STF.TF_CODAREA IN '
					Case cTpVisV == '5'
						cQuery += 'AND STF.TF_SERVICO IN  '
					Case cTpVisV == '6'
						cQuery += 'AND STF.TF_PRIORID IN '
				EndCase
				
				cQuery += '('

				While nI <= len(aMarkd)

					cQuery += ValToSQL(aMarkd[nI])

					If nI != len(aMarkd)

						cQuery += ', '

					EndIf

					nI := nI + 1

				Enddo

				cQuery += ') '

			EndIf
		
		EndIf

		cQuery += ') '
		
		If cChamada == 'TOT'
			cQuery += 'GROUP BY CODIGO,DESCR '
		EndIf

	ElseIf cBanco == 'POSTGRES'

		cQuery := 'SELECT '

		If cChamada == 'TOT'

			cQuery +=	'CODIGO, '
			cQuery +=	'DESCR, '
			cQuery += 	'COUNT(TF_FILIAL) AS QUANT, '
			cQuery +=	'AVG( (CAST( ' + ValTOSQL(DTOS(dDataBase)) + ' AS DATE ) - CAST( DT AS DATE ))::INT) AS MEDIA, '
			cQuery +=	'SUM( (CAST( ' + ValTOSQL(DTOS(dDataBase)) + ' AS DATE ) - CAST( DT AS DATE ))::INT) AS TOTAL, '
			cQuery +=	'MAX( (CAST( ' + ValTOSQL(DTOS(dDataBase)) + ' AS DATE ) - CAST( DT AS DATE ))::INT) AS MAIOR, '
			cQuery +=	'MIN( (CAST( ' + ValTOSQL(DTOS(dDataBase)) + ' AS DATE ) - CAST( DT AS DATE ))::INT) AS MENOR '

		Else

			cQuery +=	'(CAST( ' + ValTOSQL(DTOS(dDataBase)) + ' AS DATE ) - CAST( DT AS DATE ))::INT AS TMPATR, '
			cQuery +=	'DT AS DTPREV, '
			cQuery +=	'TF_PRIORID AS PRIORI, '
			cQuery +=	'TF_CODBEM AS CODBEM, '
			cQuery +=	'T9_NOME AS NOMBEM, '
			cQuery +=	'TF_SERVICO AS SERVIC, '
			cQuery +=	'TF_SEQRELA AS SEQUEN, '
			cQuery +=	'T4_NOME AS NOMSER, '
			cQuery +=	'T9_CODFAMI AS CODFAM, '
			cQuery +=	'TF_TIPO AS TIPO, '
			cQuery +=	'R_E_C_N_O_ AS RECNBR '

		EndIf

		cQuery += 'FROM ( '
		cQuery += 'SELECT '
		cQuery += 'STF.TF_FILIAL, '
		cQuery += 'STF.TF_TOLERA, '
		cQuery += 'CASE '
		cQuery +=	'WHEN '
		cQuery +=		"STF.TF_TIPACOM = 'T' "
		cQuery +=	'THEN (CASE '
		cQuery +=		   'WHEN '
		cQuery +=			   "STF.TF_UNENMAN = 'D' "
		cQuery +=		   "THEN (CAST( STF.TF_DTULTMA AS DATE ) + (STF.TF_TEENMAN + STF.TF_TOLERA) * interval '1 days') "
		cQuery +=		   'WHEN '
		cQuery +=		   	   "STF.TF_UNENMAN = 'S' "
		cQuery +=		   "THEN (CAST( STF.TF_DTULTMA AS DATE ) + ((STF.TF_TEENMAN * 7) + STF.TF_TOLERA) * interval '1 days') "
		cQuery +=		   'WHEN '
		cQuery +=				"STF.TF_UNENMAN = 'M' "
		cQuery +=		   "THEN (CAST( STF.TF_DTULTMA AS DATE ) + ((STF.TF_TEENMAN * 30 ) + STF.TF_TOLERA) * interval '1 days') "
		cQuery +=		   'ELSE '
		cQuery +=	 			 "( CAST( STF.TF_DTULTMA AS DATE ) + ((STF.TF_TEENMAN / 24) + STF.TF_TOLERA) * interval '1 days') "
		cQuery +=		   'END ) '
		// Tipo de acompanhamento Contador, Produção e Contador Fixo
		cQuery +=	'WHEN '
		cQuery +=		"STF.TF_TIPACOM = 'C' "
		cQuery +=		"OR STF.TF_TIPACOM = 'P' "
		cQuery +=		"OR STF.TF_TIPACOM = 'F' "
		cQuery +=	'THEN '
		cQuery +=		"(CAST( STF.TF_DTULTMA AS DATE ) + ((STF.TF_INENMAN - STF.TF_TOLECON)/ST9.T9_VARDIA) * interval '1 days') "
		// Tipo de acompanhamento Segundo Contador
		cQuery +=	'WHEN '
		cQuery +=		"STF.TF_TIPACOM = 'S' "
		cQuery +=	'THEN (CASE '
		cQuery +=			'WHEN '
		cQuery +=		'((STF.TF_CONMANU + STF.TF_INENMAN) + STF.TF_TOLECON) < TPE.TPE_POSCON '
		cQuery +=		'THEN '
		cQuery +=			"(CAST( STF.TF_DTULTMA AS DATE ) + ((STF.TF_INENMAN + STF.TF_TOLECON)/TPE.TPE_VARDIA) * interval '1 days') "    
		cQuery +=		'ELSE '
		cQuery +=			'CAST( STF.TF_DTULTMA AS DATE ) '
		cQuery +=		'END ) '
		cQuery +=	'ELSE '
		// Tipo de acompanhamento Tempo / Contador - Precisa calcular os dois
		cQuery +=		'CASE '
		cQuery +=			'WHEN '
		cQuery +=				'(CASE '
		cQuery +=		   		'WHEN '
		cQuery +=			    	"STF.TF_UNENMAN = 'D' "
		cQuery +=				"THEN (CAST( STF.TF_DTULTMA AS DATE ) + (STF.TF_TEENMAN + STF.TF_TOLERA) * interval '1 days') "
		cQuery +=		   		'WHEN '
		cQuery +=		   	    	"STF.TF_UNENMAN = 'S' "
		cQuery +=		   		"THEN (CAST( STF.TF_DTULTMA AS DATE ) + ((STF.TF_TEENMAN * 7) + STF.TF_TOLERA) * interval '1 days') "
		cQuery +=		   		'WHEN '
		cQuery +=					"STF.TF_UNENMAN = 'M' "
		cQuery +=		   		"THEN (CAST( STF.TF_DTULTMA AS DATE ) + ((STF.TF_TEENMAN * 30 ) + STF.TF_TOLERA) * interval '1 days') "
		cQuery +=		   		'ELSE '
		cQuery +=	 				 "( CAST( STF.TF_DTULTMA AS DATE ) + ((STF.TF_TEENMAN / 24) + STF.TF_TOLERA) * interval '1 days') "
		cQuery +=		   		'END ) < '
		cQuery +=				"(CAST( STF.TF_DTULTMA AS DATE ) + ((STF.TF_INENMAN - STF.TF_TOLECON)/ST9.T9_VARDIA) * interval '1 days') "				     
		cQuery +=			'THEN '
		cQuery +=				'(CASE '
		cQuery +=		   		'WHEN '
		cQuery +=			    	"STF.TF_UNENMAN = 'D' "
		cQuery +=				"THEN (CAST( STF.TF_DTULTMA AS DATE ) + (STF.TF_TEENMAN + STF.TF_TOLERA) * interval '1 days') "
		cQuery +=		   		'WHEN '
		cQuery +=		   	    	"STF.TF_UNENMAN = 'S' "
		cQuery +=		   		"THEN (CAST( STF.TF_DTULTMA AS DATE ) + ((STF.TF_TEENMAN * 7) + STF.TF_TOLERA) * interval '1 days') "
		cQuery +=		   		'WHEN '
		cQuery +=					"STF.TF_UNENMAN = 'M' "
		cQuery +=		   		"THEN (CAST( STF.TF_DTULTMA AS DATE ) + ((STF.TF_TEENMAN * 30 ) + STF.TF_TOLERA) * interval '1 days') "
		cQuery +=		   		'ELSE '
		cQuery +=	 				 "( CAST( STF.TF_DTULTMA AS DATE ) + ((STF.TF_TEENMAN / 24) + STF.TF_TOLERA) * interval '1 days') "
		cQuery +=		   		'END ) '
		cQuery +=			'ELSE '
		cQuery +=				"(CAST( STF.TF_DTULTMA AS DATE ) + ((STF.TF_INENMAN - STF.TF_TOLECON)/ST9.T9_VARDIA) * interval '1 days') "					
		cQuery +=			'END '
		cQuery +=	'END AS DT, '
		cQuery += 'STF.TF_TIPACOM, '

		If cChamada == 'TOT'		
			// Campos CODIGO e DESCRICAO
			Do Case
				Case cTpVisV == '1'
					cQuery += ValToSQL(STR0054) + ' AS CODIGO, '
					cQuery += ValToSQL(STR0054) + ' AS DESCR '
				Case cTpVisV == '2'
					cQuery += 'ST9.T9_CODFAMI AS CODIGO, ' 
					cQuery += 'ST9.T9_CODFAMI AS DESCR '
				Case cTpVisV == '3'
					cQuery += 'STF.TF_TIPO AS CODIGO, '
					cQuery += 'STF.TF_TIPO AS DESCR '
				Case cTpVisV == '4'
					cQuery += 'STF.TF_CODAREA AS CODIGO, '
					cQuery += 'STF.TF_CODAREA AS DESCR '
				Case cTpVisV == '5'
					cQuery += 'STF.TF_SERVICO AS CODIGO, '
					cQuery += 'STF.TF_SERVICO AS DESCR '
				Case cTpVisV == '6'
					cQuery += 'STF.TF_PRIORID AS CODIGO, '
					cQuery += 'STF.TF_PRIORID AS DESCR '
			EndCase
		
		Else

			cQuery += 'STF.TF_PRIORID, '
			cQuery += 'STF.TF_CODBEM, '
			cQuery += 'ST9.T9_NOME, '
			cQuery += 'STF.TF_SERVICO, '
			cQuery += 'STF.TF_SEQRELA, '
			cQuery += 'ST4.T4_NOME, '
			cQuery += 'ST9.T9_CODFAMI, '
			cQuery += 'STF.TF_TIPO, '
			cQuery += 'STF.R_E_C_N_O_ '

		EndIf

		cQuery += 'FROM ' + RetSQLName( 'STF' ) + ' STF '
		cQuery += 'INNER JOIN ' + RetSQLName( 'ST9' ) + ' ST9 ON '
		cQuery += 	NGMODCOMP('ST9','STF','=') + ' '
		cQuery += 	'AND ST9.T9_CODBEM = STF.TF_CODBEM '
		cQuery += 	"AND ST9.T9_SITBEM = 'A' "
		cQuery +=	"AND ST9.T9_SITMAN = 'A'"
		cQuery += 	"AND ST9.D_E_L_E_T_ = ' ' "

		If cChamada == 'DET'

			cQuery += 'INNER JOIN ' + RetSQLName( 'ST4' ) + ' ST4 ON '
			cQuery += NGMODCOMP('ST4','STF','=') + ' '
			cQuery += 'AND ST4.T4_SERVICO = STF.TF_SERVICO '
			cQuery += "AND ST4.D_E_L_E_T_ = ' ' "	

		EndIf

		cQuery += 'LEFT JOIN ' + RetSQLName( 'TPE' ) + ' TPE ON '
		cQuery += 	NGMODCOMP('TPE','STF','=') + ' '
		cQuery +=	'AND TPE.TPE_CODBEM = STF.TF_CODBEM '
		cQuery +=	"AND TPE.D_E_L_E_T_ = ' ' "
		cQuery += 'WHERE '
		cQuery += 	'STF.TF_FILIAL = ' + ValToSQL( FWxFilial( 'STF' ) ) + ' '
		cQuery +=	"AND STF.TF_ATIVO = 'S' "
		cQuery +=	"AND STF.TF_PERIODO <> 'E' "
		cQuery +=	"AND (((STF.TF_TIPACOM = 'C' "
		cQuery +=	"OR STF.TF_TIPACOM = 'P' "
		cQuery +=	"OR STF.TF_TIPACOM = 'F' "
		cQuery +=	"OR STF.TF_TIPACOM = 'A') "
		cQuery +=	"AND ST9.T9_VARDIA <> 0) "
		cQuery +=	"OR (STF.TF_TIPACOM = 'T' "
		cQuery +=	"OR STF.TF_TIPACOM = 'S')) "
		cQuery += 	"AND STF.D_E_L_E_T_ = ' ' "
		
		If cChamada == 'DET'

			If cTpVisV != '1'
				Do Case
					Case cTpVisV == '2'
						cQuery += 'AND ST9.T9_CODFAMI IN '
					Case cTpVisV == '3'
						cQuery += 'AND STF.TF_TIPO IN '
					Case cTpVisV == '4'
						cQuery += 'AND STF.TF_CODAREA IN '
					Case cTpVisV == '5'
						cQuery += 'AND STF.TF_SERVICO IN  '
					Case cTpVisV == '6'
						cQuery += 'AND STF.TF_PRIORID IN '
				EndCase
				
				cQuery += '('

				While nI <= len(aMarkd)

					cQuery += ValToSQL(aMarkd[nI])

					If nI != len(aMarkd)

						cQuery += ', '

					EndIf

					nI := nI + 1

				Enddo

				cQuery += ') '

			EndIf
		
		EndIf

		cQuery += 	') AS REGS '
		
		If cChamada == 'TOT'
			cQuery += 'GROUP BY CODIGO,DESCR '
		EndIf

	Else

		cQuery := 'SELECT '

		If cChamada == 'TOT'
		
			cQuery +=	'CODIGO, '
			cQuery +=	'DESCR, '
			cQuery += 	'COUNT(TF_FILIAL) AS QUANT, '
			cQuery +=	'AVG(DATEDIFF(day, CONVERT(DATE, DT, 103), CONVERT(DATE, ' + ValTOSQL(DTOS(dDataBase)) + ', 103)) ) AS MEDIA, '
			cQuery +=	'SUM(DATEDIFF(day, CONVERT(DATE, DT, 103), CONVERT(DATE, ' + ValTOSQL(DTOS(dDataBase)) + ', 103)) ) AS TOTAL, '
			cQuery +=	'MAX(DATEDIFF(day, CONVERT(DATE, DT, 103), CONVERT(DATE, ' + ValTOSQL(DTOS(dDataBase)) + ', 103)) ) AS MAIOR, '
			cQuery +=	'MIN(DATEDIFF(day, CONVERT(DATE, DT, 103), CONVERT(DATE, ' + ValTOSQL(DTOS(dDataBase)) + ', 103)) ) AS MENOR '

		Else

			cQuery +=	'DATEDIFF(day, CONVERT(DATE, DT, 103), CONVERT(DATE, ' + ValTOSQL(DTOS(dDataBase)) + ', 103)) AS TMPATR, '
			cQuery +=	'DT AS DTPREV, '
			cQuery +=	'TF_PRIORID AS PRIORI, '
			cQuery +=	'TF_CODBEM AS CODBEM, '
			cQuery +=	'T9_NOME AS NOMBEM, '
			cQuery +=	'TF_SERVICO AS SERVIC, '
			cQuery +=	'TF_SEQRELA AS SEQUEN, '
			cQuery +=	'T4_NOME AS NOMSER, '
			cQuery +=	'T9_CODFAMI AS CODFAM, '
			cQuery +=	'TF_TIPO AS TIPO, '
			cQuery +=	'R_E_C_N_O_ AS RECNBR '

		EndIf

		cQuery += 'FROM ( '
		cQuery += 'SELECT '
		cQuery += 'STF.TF_FILIAL, '
		cQuery += 'STF.TF_TOLERA, '
		cQuery += 'CASE '
		cQuery +=	'WHEN '
		cQuery +=		"STF.TF_TIPACOM = 'T' "
		cQuery +=	'THEN (CASE '
		cQuery +=		   'WHEN '
		cQuery +=			   "STF.TF_UNENMAN = 'D' "
		cQuery +=		   'THEN DATEADD(day, (STF.TF_TEENMAN + STF.TF_TOLERA), CONVERT(DATE, STF.TF_DTULTMA, 103)) '
		cQuery +=		   'WHEN '
		cQuery +=		   	   "STF.TF_UNENMAN = 'S' "
		cQuery +=		   'THEN DATEADD(day, ((STF.TF_TEENMAN * 7) + STF.TF_TOLERA), CONVERT(DATE, STF.TF_DTULTMA, 103)) '
		cQuery +=		   'WHEN '
		cQuery +=				"STF.TF_UNENMAN = 'M' "
		cQuery +=		   'THEN DATEADD(day, ((STF.TF_TEENMAN * 30 ) + STF.TF_TOLERA), CONVERT(DATE, STF.TF_DTULTMA, 103)) '
		cQuery +=		   'ELSE '
		cQuery +=	 			 'DATEADD(day, ((STF.TF_TEENMAN / 24) + STF.TF_TOLERA), CONVERT(DATE, STF.TF_DTULTMA, 103)) '
		cQuery +=		   'END ) '
		// Tipo de acompanhamento Contador, Produção e Contador Fixo
		cQuery +=	'WHEN '
		cQuery +=		"STF.TF_TIPACOM = 'C' "
		cQuery +=		"OR STF.TF_TIPACOM = 'P' "
		cQuery +=		"OR STF.TF_TIPACOM = 'F' "
		cQuery +=	'THEN ' 
		cQuery +=		'DATEADD(day, ((STF.TF_INENMAN - STF.TF_TOLECON)/ST9.T9_VARDIA), CONVERT(DATE, STF.TF_DTULTMA, 103)) '				 
		// Tipo de acompanhamento Segundo Contador
		cQuery +=	'WHEN '
		cQuery +=		"STF.TF_TIPACOM = 'S' "
		cQuery +=	'THEN (CASE '
		cQuery +=			'WHEN '
		cQuery +=		'((STF.TF_CONMANU + STF.TF_INENMAN) + STF.TF_TOLECON) < TPE.TPE_POSCON '
		cQuery +=		'THEN '
		cQuery +=			'DATEADD(day, ((STF.TF_INENMAN + STF.TF_TOLECON)/TPE.TPE_VARDIA), CONVERT(DATE, STF.TF_DTULTMA, 103)) '    
		cQuery +=		'ELSE '
		cQuery +=			'CONVERT(DATE, STF.TF_DTULTMA, 103)'
		cQuery +=		'END ) '
		cQuery +=	'ELSE '
		// Tipo de acompanhamento Tempo / Contador - Precisa calcular os dois
		cQuery +=		'CASE '
		cQuery +=			'WHEN '
		cQuery +=				'(CASE '
		cQuery +=		   		'WHEN '
		cQuery +=			    	"STF.TF_UNENMAN = 'D' "
		cQuery +=				'THEN DATEADD(day, (STF.TF_TEENMAN + STF.TF_TOLERA), CONVERT(DATE, STF.TF_DTULTMA, 103)) '
		cQuery +=		   		'WHEN '
		cQuery +=		   	    	"STF.TF_UNENMAN = 'S' "
		cQuery +=		   		'THEN DATEADD(day, ((STF.TF_TEENMAN * 7) + STF.TF_TOLERA), CONVERT(DATE, STF.TF_DTULTMA, 103)) '
		cQuery +=		   		'WHEN '
		cQuery +=					"STF.TF_UNENMAN = 'M' "
		cQuery +=		   		'THEN DATEADD(day, ((STF.TF_TEENMAN * 30 ) + STF.TF_TOLERA), CONVERT(DATE, STF.TF_DTULTMA, 103)) '
		cQuery +=		   		'ELSE '
		cQuery +=	 				 'DATEADD(day, ((STF.TF_TEENMAN / 24) + STF.TF_TOLERA), CONVERT(DATE, STF.TF_DTULTMA, 103)) '
		cQuery +=		   		'END ) < '
		cQuery +=				'DATEADD(day, ((STF.TF_INENMAN - STF.TF_TOLECON)/ST9.T9_VARDIA), CONVERT(DATE, STF.TF_DTULTMA, 103)) '				     
		cQuery +=			'THEN '
		cQuery +=				'(CASE '
		cQuery +=		   		'WHEN '
		cQuery +=			    	"STF.TF_UNENMAN = 'D' "
		cQuery +=				'THEN DATEADD(day, (STF.TF_TEENMAN + STF.TF_TOLERA), CONVERT(DATE, STF.TF_DTULTMA, 103)) '
		cQuery +=		   		'WHEN '
		cQuery +=		   	    	"STF.TF_UNENMAN = 'S' "
		cQuery +=		   		'THEN DATEADD(day, ((STF.TF_TEENMAN * 7) + STF.TF_TOLERA), CONVERT(DATE, STF.TF_DTULTMA, 103)) '
		cQuery +=		   		'WHEN '
		cQuery +=					"STF.TF_UNENMAN = 'M' "
		cQuery +=		   		'THEN DATEADD(day, ((STF.TF_TEENMAN * 30 ) + STF.TF_TOLERA), CONVERT(DATE, STF.TF_DTULTMA, 103)) '
		cQuery +=		   		'ELSE '
		cQuery +=	 				 'DATEADD(day, ((STF.TF_TEENMAN / 24) + STF.TF_TOLERA), CONVERT(DATE, STF.TF_DTULTMA, 103)) '
		cQuery +=		   		'END ) '
		cQuery +=			'ELSE '
		cQuery +=				'DATEADD(day, ((STF.TF_INENMAN - STF.TF_TOLECON)/ST9.T9_VARDIA), CONVERT(DATE, STF.TF_DTULTMA, 103)) '					
		cQuery +=			'END '
		cQuery +=	'END AS DT, '
		cQuery += 'STF.TF_TIPACOM, '
		
		If cChamada == 'TOT'
			// Campos CODIGO e DESCRICAO
			Do Case
				Case cTpVisV == '1'
					cQuery += ValToSQL(STR0054) + ' AS CODIGO, '
					cQuery += ValToSQL(STR0054) + ' AS DESCR '
				Case cTpVisV == '2'
					cQuery += 'ST9.T9_CODFAMI AS CODIGO, ' 
					cQuery += 'ST9.T9_CODFAMI AS DESCR '
				Case cTpVisV == '3'
					cQuery += 'STF.TF_TIPO AS CODIGO, '
					cQuery += 'STF.TF_TIPO AS DESCR '
				Case cTpVisV == '4'
					cQuery += 'STF.TF_CODAREA AS CODIGO, '
					cQuery += 'STF.TF_CODAREA AS DESCR '
				Case cTpVisV == '5'
					cQuery += 'STF.TF_SERVICO AS CODIGO, '
					cQuery += 'STF.TF_SERVICO AS DESCR '
				Case cTpVisV == '6'
					cQuery += 'STF.TF_PRIORID AS CODIGO, '
					cQuery += 'STF.TF_PRIORID AS DESCR '
			EndCase

		Else

			cQuery += 'STF.TF_PRIORID, '
			cQuery += 'STF.TF_CODBEM, '
			cQuery += 'ST9.T9_NOME, '
			cQuery += 'STF.TF_SERVICO, '
			cQuery += 'STF.TF_SEQRELA, '
			cQuery += 'ST4.T4_NOME, '
			cQuery += 'ST9.T9_CODFAMI, '
			cQuery += 'STF.TF_TIPO, '
			cQuery += 'STF.R_E_C_N_O_ '

		EndIf

		cQuery += 'FROM ' + RetSQLName( 'STF' ) + ' STF '
		cQuery += 'INNER JOIN ' + RetSQLName( 'ST9' ) + ' ST9 ON '
		cQuery += 	NGMODCOMP('ST9','STF','=') + ' '
		cQuery += 	'AND ST9.T9_CODBEM = STF.TF_CODBEM '
		cQuery += 	"AND ST9.T9_SITBEM = 'A' "
		cQuery +=	"AND ST9.T9_SITMAN = 'A'"
		cQuery += 	"AND ST9.D_E_L_E_T_ = ' ' "

		If cChamada == 'DET'

			cQuery += 'INNER JOIN ' + RetSQLName( 'ST4' ) + ' ST4 ON '
			cQuery += NGMODCOMP('ST4','STF','=') + ' '
			cQuery += 'AND ST4.T4_SERVICO = STF.TF_SERVICO '
			cQuery += "AND ST4.D_E_L_E_T_ = ' ' "	

		EndIf
		
		cQuery += 'LEFT JOIN ' + RetSQLName( 'TPE' ) + ' TPE ON '
		cQuery += 	NGMODCOMP('TPE','STF','=') + ' '
		cQuery +=	'AND TPE.TPE_CODBEM = STF.TF_CODBEM '
		cQuery +=	"AND TPE.D_E_L_E_T_ = ' ' "
		cQuery += 'WHERE '
		cQuery += 	'STF.TF_FILIAL = ' + ValToSQL( FWxFilial( 'STF' ) ) + ' '
		cQuery +=	"AND STF.TF_ATIVO = 'S' "
		cQuery +=	"AND STF.TF_PERIODO <> 'E' "
		cQuery +=	"AND (((STF.TF_TIPACOM = 'C'"
		cQuery +=	"OR STF.TF_TIPACOM = 'P'"
		cQuery +=	"OR STF.TF_TIPACOM = 'F'"
		cQuery +=	"OR STF.TF_TIPACOM = 'A') "
		cQuery +=	"AND ST9.T9_VARDIA <> 0) "
		cQuery +=	"OR (STF.TF_TIPACOM = 'T' "
		cQuery +=	"OR STF.TF_TIPACOM = 'S'))"
		cQuery += 	"AND STF.D_E_L_E_T_ = ' ' "

		If cChamada == 'DET'

			If cTpVisV != '1'
				Do Case
					Case cTpVisV == '2'
						cQuery += 'AND ST9.T9_CODFAMI IN '
					Case cTpVisV == '3'
						cQuery += 'AND STF.TF_TIPO IN '
					Case cTpVisV == '4'
						cQuery += 'AND STF.TF_CODAREA IN '
					Case cTpVisV == '5'
						cQuery += 'AND STF.TF_SERVICO IN  '
					Case cTpVisV == '6'
						cQuery += 'AND STF.TF_PRIORID IN '
				EndCase
				
				cQuery += '('

				While nI <= len(aMarkd)

					cQuery += ValToSQL(aMarkd[nI])

					If nI != len(aMarkd)

						cQuery += ', '

					EndIf

					nI := nI + 1

				Enddo

				cQuery += ') '

			EndIf
		
		EndIf

		cQuery += ') AS REGS '

		If cChamada == 'TOT'
			cQuery += 'GROUP BY CODIGO,DESCR '
		EndIf

	EndIf

	cQuery := ChangeQuery( cQuery )

Return cQuery
