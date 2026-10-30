#INCLUDE "TOTVS.CH"
#INCLUDE "QNCA060.CH"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ QNCA060  ³ Autor ³ Aldo Marini Junior    ³ Data ³ 04.02.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Follow-Up de Acoes e Nao-conformidades                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Aldo        ³09/05/01³------³ Nao deixar adicionar campo no filtro se  ³±±
±±³            ³        ³      ³ nao for selecionado "E" ou "OU".         ³±±
±±³Aldo        ³14/05/01³------³ Alteracao do sinal "=" para "==" na opcao³±±
±±³            ³        ³      ³ de Filtro de campos                      ³±±
±±³Aldo        ³18/09/01³------³ Acerto no posicionamento no nAt do "oQI2"³±±
±±³Aldo        ³26/09/01³------³ Acerto na passagem dos parametros nas    ³±±
±±³            ³        ³      ³ funcoes FQNC060QI2() e FQNC060QI3()      ³±±
±±³Eduardo S.  ³03/01/02³012443³ Acertado para posicionar o arquivo QI2 na³±±
±±³            ³        ³      ³ ordem 1.                                 ³±±
±±³Aldo        ³08/03/02³14091 ³ Retirado os campos virtuais da lista.    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QNCA060()
Local aButtons := {}
Local aSize    := MsAdvSize()
Local aQI2     := {}
Local aQI3     := {}
Local aQI5     := {}
Local aStatus  := {" 0%"," 25%"," 50%"," 75%"," 100%","REPROV"}
Local cQI2     := ""
Local cQI5     := ""
Local oDlg     := Nil
Local oPanel1  := Nil
Local oPanel2  := Nil
Local oPanel3  := Nil

Private aFiltro1 := {.F., " "    , " "}
Private aFiltro2 := {.F., " "    , " "}
Private aFiltro3 := {.F., " "    , " "}
Private aOrdem1  := {1  , {1,2}}
Private aOrdem2  := {1  , {1,2}}
Private aOrdem3  := {1  , {2,1,4}}
Private cAnoAte  := Str(Year(dDatabase),4)
Private cAnoDe   := Str(Year(dDatabase),4)
Private lFilCpo  := .F.
Private lFilQI2  := .F.
Private lFilQI3  := .F.
Private lFilQI5  := .F.
Private nCadast  := 1
Private nCadastO := 1
Private nCadPsq  := 1
Private nFirst   := 1
Private nRelac   := 1
Private oQI2     := Nil
Private oQI3     := Nil
Private oQI5     := Nil

If Type("aColAnx") == "U"
	Private aColAnx := {}
EndIf

INCLUI := .F.

// Carrega todas as tabelas relacionadas com a consulta
QNC060CARR(@aQI2,@aQI3,@aQI5,.T.,.T.,.T.,"X")

DEFINE MSDIALOG oDlg FROM aSize[7],000 TO aSize[6],aSize[5] TITLE OemToAnsi(STR0001) PIXEL OF oMainWnd // "Follow-Up Plano de Ação X Ocorrências/Ficha Não-conformidades"

//Criando a camada
oFwLayer := FwLayer():New()
oFwLayer:init(oDlg,.F.)

//Adicionando linhas 
oFWLayer:addLine("NAOCONFORM" , 027, .F.)
oFWLayer:addLine("PLANOACAO"  , 027, .F.)
oFWLayer:addLine("ETAPAS"     , 036, .F.)

//Adicionando as colunas das linhas
oFWLayer:addCollumn("COLUNAOC"  , 100, .F., "NAOCONFORM")
oFWLayer:addCollumn("COLUNPLA"  , 100, .F., "PLANOACAO" )
oFWLayer:addCollumn("COLUNETA"  , 100, .F., "ETAPAS"    )

oFWLayer:AddWindow("COLUNAOC" ,"oPanel1", STR0002 ,100,.F.,.T.,,"NAOCONFORM",{ || }) // "Ficha Não-conformidades"
oFWLayer:AddWindow("COLUNPLA" ,"oPanel2", STR0004 ,100,.F.,.T.,,"PLANOACAO" ,{ || }) // "Plano de Ação"
oFWLayer:AddWindow("COLUNETA" ,"oPanel3", STR0005 ,100,.F.,.T.,,"ETAPAS"    ,{ || }) // "Etapas - Plano de Ação"

//Criando os paineis
oPanel1 := oFWLayer:GetWinPanel("COLUNAOC"  ,"oPanel1" ,"NAOCONFORM")
oPanel2 := oFWLayer:GetWinPanel("COLUNPLA"  ,"oPanel2" ,"PLANOACAO" )
oPanel3 := oFWLayer:GetWinPanel("COLUNETA"  ,"oPanel3" ,"ETAPAS"    )

@ 009,006 LISTBOX oQI2 VAR cQI2 FIELDS HEADER Alltrim(TitSx3("QI2_FNC")[1]) ,;
											   Alltrim(TitSx3("QI2_REV")[1]),;
								               TitSx3("QI2_DESCR")[1],;
								               Alltrim(TitSx3("QI2_STATUS")[1]) ;
             SIZE  50,50 OF oPanel1 PIXEL ;  //275,aSize[3]-aSize[4]-150
             ON DBLCLICK QNC060VsFNC(aQI2[oQI2:nAt,5]) ;
             ON CHANGE IF(nRelac == 1 .And. nFirst==0,; 
			              (FQNC060QI3(aQI2,@aQI3,.F.,.F.,iif(nFirst==1,nFirst:=0,nRelac),oQI2:nAt,aFiltro2),;
		                   FQNC060IND(@aQI3,aOrdem2,1),;
			               QNC060CARR(@aQI2,@aQI3,@aQI5,.F.,.F.,.T.,,aFiltro1,aFiltro2,aFiltro3),;
						   oQI3:aArray:=aQI3,oQI3:bLogicLen:={||Len(aQI3)},oQI3:Refresh(.T.),oQI3:GoTop(),;
						   oQI5:aArray:=aQI5,oQI5:bLogicLen:={||Len(aQI5)},oQI5:Refresh(.T.)),nFirst:=0)

oQI2:SetArray(aQI2)
oQI2:bLine    := {||{Transform(aQI2[oQI2:nAt,1],PesqPict("QI2","QI2_FNC")),aQI2[oQI2:nAt,2],aQI2[oQI2:nAt,3],aQI2[oQI2:nAt,4]}}
oQI2:cToolTip := OemToAnsi( STR0003 ) //"Duplo Click para Visualizar..."
oQI2:Align := CONTROL_ALIGN_ALLCLIENT

@ 072,006 LISTBOX oQI3 VAR cQI3 FIELDS HEADER Alltrim(TitSx3("QI3_CODIGO")[1]),;
											   Alltrim(TitSx3("QI3_REV"   )[1]),;
								               Alltrim(TitSx3("QI3_ABERTU")[1]),;
								               Alltrim(TitSx3("QI3_ENCPRE")[1]),;
								               Alltrim(TitSx3("QI3_ENCREA")[1]) ;
             SIZE 50,50 OF oPanel2 PIXEL ;   //306,aSize[3]-aSize[4]-150
             ON DBLCLICK QNC060VsAca(aQI3[oQI3:nAt,6]);
             ON CHANGE	(IF(nRelac==2,;
                      (FQNC060QI2(@aQI2,aQI3,.F.,.F.,nRelac,oQI3:nAt,aFiltro1),;
                      FQNC060IND(@aQI2,aOrdem1,1),;
                      oQI2:aArray:=aQI2,oQI2:bLogicLen:={||Len(aQI2)},oQI2:Refresh(.T.),oQI2:GoTop(),oQI2:nAt:=1),""),;
                      QNC060CARR(@aQI2,@aQI3,@aQI5,.F.,.F.,.T.,oQI3:nAt,aFiltro1,aFiltro2,aFiltro3),;
                      oQI5:aArray:=aQI5,oQI5:bLogicLen:={||Len(aQI5)},oQI5:Refresh(.T.))
             
oQI3:SetArray(aQI3)
oQI3:bLine    := {||{Transform(aQI3[oQI3:nAt,1],PesqPict("QI3","QI3_CODIGO")),aQI3[oQI3:nAt,2],DtoC(aQI3[oQI3:nAt,3]),DtoC(aQI3[oQI3:nAt,4]),DtoC(aQI3[oQI3:nAt,5])}}
oQI3:cToolTip := OemToAnsi( STR0003 ) //"Duplo Click para Visualizar..."
oQI3:Align := CONTROL_ALIGN_ALLCLIENT

@ 136,006 LISTBOX oQI5 VAR cQI5 FIELDS HEADER Alltrim(TitSx3("QI5_STATUS")[1]),;
											   Alltrim(TitSx3("QI5_PRAZO" )[1]),;
											   Alltrim(TitSx3("QI5_REALIZ")[1]),;
							                   TitSx3("QI5_NUSR"  )[1],;
							                   TitSx3("QI5_TPACAO")[1],;
											   Alltrim(TitSx3("QI5_CODIGO")[1]),;
								               Alltrim(TitSx3("QI5_REV"	   )[1]) ;
            SIZE 306,070 OF oPanel3 PIXEL ;
            ON DBLCLICK QNC060VsEta(aQI5[oQI5:nAt,8])

oQI5:SetArray(aQI5)
oQI5:cToolTip := OemToAnsi(STR0006) //"Duplo click para Visualizar Etapas/Plano de Acao..."	
oQI5:bLine    := {||{aStatus[Val(aQI5[oQI5:nAt,1])+1],DTOC(aQI5[oQI5:nAt,2]),DTOC(aQI5[oQI5:nAt,3]),aQI5[oQI5:nAt,4],aQI5[oQI5:nAt,5],Transform(aQI5[oQI5:nAt,6],PesqPict("QI5","QI5_CODIGO")),aQI5[oQI5:nAt,7]}}
oQI5:Align := CONTROL_ALIGN_ALLCLIENT

aAdd(aButtons,{"BMPORD1", {|| IF(QNC060Ord(@aQI2,@aQI3,@aQI5),;
						(IF(nRelac == 1,(oQI3:aArray:=aQI3,oQI3:bLogicLen:={||Len(aQI3)}),;
						IF(nRelac == 2,(oQI2:aArray:=aQI2,oQI2:bLogicLen:={||Len(aQI2)},oQI2:nAt:=1),"")),;
						oQI5:aArray:=aQI5,oQI5:bLogicLen:={||Len(aQI5)},;
	   				    oQI2:Refresh(.T.),oQI3:Refresh(.T.),oQI5:Refresh(.T.),;
	   				    oQI2:GoTop(),oQI3:GoTop(),oQI5:GoTop()),"")} , OemToAnsi( STR0065 ),OemToAnsi(STR0065)  } )  // "bmpord1" "Ordem"
	   				    
aAdd(aButtons,{"FILTRO",{|| IF(QNC060Fil(@aQI2,@aQI3,@aQI5),;
						(oQI2:nAt:=1,oQI2:aArray:=aQI2,oQI2:bLogicLen:={||Len(aQI2)},oQI2:Refresh(.T.),oQI2:GoTop(),;
						oQI3:aArray:=aQI3,oQI3:bLogicLen:={||Len(aQI3)},oQI3:Refresh(.T.),oQI3:GoTop(),;
						oQI5:aArray:=aQI5,oQI5:bLogicLen:={||Len(aQI5)},oQI5:Refresh(.T.),oQI5:GoTop()),"")},OemToAnsi(LEFT(STR0035,6)),OemToAnsi(LEFT(STR0035,6)) } )   //"Filtro: 

aAdd(aButtons,{"NOTE", {|| QNC060Psq(@aQI2,@aQI3,@aQI5,@oQI2,@oQI3,oQI2:nAt,oQI3:nAt)},OemToAnsi( STR0063 ),OemToAnsi( STR0069 ) } ) //"Pesquisa Rapida..."### "Pesq Rap"


ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| oDlg:End()},{|| oDlg:End()},,aButtons)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QNC060CARR ³ Autor ³ Aldo Marini Junior   ³ Data ³ 04/02/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa para Mostrar tela de processamento                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QNC060CARR(aQI2,aQI3,aQI5,lQI2,lQI3,lQI5,nPos)             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 = Array com os dados das Nao-conformidades           ³±±
±±³          ³ ExpA2 = Array com os dados dos Plano de Acao               ³±±
±±³          ³ ExpA3 = Array com as dados das Etapas/Plano de Acao        ³±±
±±³          ³ ExpL1 = Variavel logica contendo .T. para atualiza Array   ³±±
±±³          ³ ExpL2 = Variavel logica contendo .T. para atualiza Array   ³±±
±±³          ³ ExpL3 = Variavel logica contendo .T. para atualiza Array   ³±±
±±³          ³ ExpN1 = Numero com o posicao do Array                      ³±±
±±³          ³ ExpA4 = Array contendo as opcoes e filtros do QI2          ³±±
±±³          ³ ExpA5 = Array contendo as opcoes e filtros do QI3          ³±±
±±³          ³ ExpA6 = Array contendo as opcoes e filtros do QI5          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QNCA060                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QNC060CARR(aQI2,aQI3,aQI5,lQI2,lQI3,lQI5,nPos,aFiltro1,aFiltro2,aFiltro3)
lQI2 := IF(lQI2==NIl,.F.,lQI2)
lQI3 := IF(lQI3==NIl,.F.,lQI3)
lQI5 := IF(lQI5==NIl,.F.,lQI5)
nPos := IF(nPos==NIL,1,nPos)

// Verifica se vai carregar todos para exibir tela de processamento
If ValType(nPos) == "C" .And. nPos == "X"
	ProcQNC({|| QNC060PCAR(@aQI2,@aQI3,@aQI5,lQI2,lQI3,lQI5,nPos,aFiltro1,aFiltro2,aFiltro3) })
Else
	QNC060PCAR(@aQI2,@aQI3,@aQI5,lQI2,lQI3,lQI5,nPos,aFiltro1,aFiltro2,aFiltro3)
Endif

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QNC060PCAR ³ Autor ³ Aldo Marini Junior   ³ Data ³ 16/02/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa para Carregar tabelas em array dentro da ProcQnc  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QNC060PCAR(aQI2,aQI3,aQI5,lQI2,lQI3,lQI5,nPos)        	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 = Array com os dados das Nao-conformidades           ³±±
±±³          ³ ExpA2 = Array com os dados dos Plano de Acao               ³±±
±±³          ³ ExpA3 = Array com as dados das Etapas/Plano de Acao        ³±±
±±³          ³ ExpL1 = Variavel logica contendo .T. para atualiza Array   ³±±
±±³          ³ ExpL2 = Variavel logica contendo .T. para atualiza Array   ³±±
±±³          ³ ExpL3 = Variavel logica contendo .T. para atualiza Array   ³±±
±±³          ³ ExpN1 = Numero com o posicao do Array					  ³±±
±±³          ³ ExpA4 = Array contendo as opcoes e filtros do QI2		  ³±±
±±³          ³ ExpA5 = Array contendo as opcoes e filtros do QI3		  ³±±
±±³          ³ ExpA6 = Array contendo as opcoes e filtros do QI5		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QNCA060                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QNC060PCAR(aQI2,aQI3,aQI5,lQI2,lQI3,lQI5,nPos,aFiltro1,aFiltro2,aFiltro3)
Local lTelaProc	:=If((lQI2 .Or. lQI3 .Or. lQI5) .And. !(Valtype(nPos)=="C" .And. nPos=="X"),.T.,.F.)
Local cFilQI5	:= xFilial("QI5")
Local lTelaP1	:=(Valtype(nPos)=="C" .And. nPos=="X")
Local nAno		:= 0
Local nRegistro	:= 0
nPos :=IF(Valtype(nPos)=="C" .And. nPos=="X",1,nPos)

If lTelaP1 
	nRegistro := 0
	IF nRelac == 1 .Or. nRelac == 3
		If QA4->(dbSeek(xFilial("QA4")+"QNC_QI2"+cAnoDe))
			If cAnoDe == cAnoAte
				RegProcQNC(Val(Left(QA4->QA4_CHAVE,6)))
			Else
				For nAno:=Val(cAnoDe) to Val(cAnoAte)
					If QA4->(dbSeek(xFilial("QA4")+"QNC_QI2"+StrZero(nAno,4)))
						nRegistro+=Val(Left(QA4->QA4_CHAVE,6))
					Endif
				Next
				RegProcQNC(nRegistro)
			Endif
		Else
			nRegistro += QI2->(RecCount())
		Endif
    Endif

	IF nRelac == 2 .Or. nRelac == 3    
		If QA4->(dbSeek(xFilial("QA4")+"QNC_QI3"+cAnoDe))
			If cAnoDe == cAnoAte
				RegProcQNC(Val(Left(QA4->QA4_CHAVE,6)))
			Else
				For nAno:=Val(cAnoDe) to Val(cAnoAte)
					If QA4->(dbSeek(xFilial("QA4")+"QNC_QI3"+StrZero(nAno,4)))
						nRegistro+=Val(Left(QA4->QA4_CHAVE,6))
					Endif
				Next
				RegProcQNC(nRegistro)
			Endif
		Else
			nRegistro += QI3->(RecCount())
		Endif

		RegProcQNC(nRegistro)
    Endif
    
Endif

If nRelac == 1 .Or. nRelac == 3
	If lQI2
		If lTelaProc
			ProcQNC({|| FQNC060QI2(@aQI2,aQI3,lTelaProc,lTelaP1,nRelac,nPos,aFiltro1) },,,lTelaProc)
		Else
			FQNC060QI2(@aQI2,aQI3,lTelaProc,lTelaP1,nRelac,nPos,aFiltro1)
		Endif
		FQNC060IND(@aQI2,aOrdem1,1)
	Endif

	If lQI3
    	If lTelaProc
			ProcQNC({|| FQNC060QI3(aQI2,@aQI3,lTelaProc,lTelaP1,nRelac,nPos,aFiltro2) },,,lTelaProc)
		Else
			FQNC060QI3(aQI2,@aQI3,lTelaProc,lTelaP1,nRelac,nPos,aFiltro2)
		Endif
		FQNC060IND(@aQI3,aOrdem2,1)
	Endif
ElseIf nRelac == 2
	If lQI3
		If lTelaProc
			ProcQNC({|| FQNC060QI3(aQI2,@aQI3,lTelaProc,lTelaP1,nRelac,nPos,aFiltro2) },,,lTelaProc)
		Else
			FQNC060QI3(aQI2,@aQI3,lTelaProc,lTelaP1,nRelac,nPos,aFiltro2)
		Endif
		FQNC060IND(@aQI3,aOrdem2,1)
	Endif

	If lQI2
		If lTelaProc
			ProcQNC({|| FQNC060QI2(@aQI2,aQI3,lTelaProc,lTelaP1,nRelac,nPos,aFiltro1) },,,lTelaProc)
		Else
			FQNC060QI2(@aQI2,aQI3,lTelaProc,lTelaP1,nRelac,nPos,aFiltro1)
		Endif
		FQNC060IND(@aQI2,aOrdem1,1)
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega as pendencias no Array (campos) - Etapas/Acoes       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lQI5 
	aQI5 := {}
	If !Empty(aQI3[nPos,1]+aQI3[nPos,2])
		dbSelectArea("QI5")
		dbSetOrder(1)
		dbSeek(cFilQI5+aQI3[nPos,1]+aQI3[nPos,2])
		While !Eof() .And. cFilQI5+aQI3[nPos,1]+aQI3[nPos,2] == QI5->QI5_FILIAL+QI5->QI5_CODIGO+QI5->QI5_REV
			If lTelaP1
				IncProcQNC(OemToAnsi(STR0058))	// "Carregando Lactos Etapas de Plano de Acao"
			Endif	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Filtra os registros dos Plano de Acao conforme aFiltro2      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If aFiltro3 <> NIL .And. aFiltro3[1] == .T. .And. !Empty(aFiltro3[3])
				IF &('!('+aFiltro3[3]+')')
					dbSkip()
					Loop
				Endif
			Endif

			AADD( aQI5,{QI5->QI5_STATUS,;                 // Status da Acao 
				 QI5->QI5_PRAZO,;                		// Prazo/Vecto da Acao 
				 QI5->QI5_REALIZ,;                     // Data Realizacao/Baixa
				 QI5->QI5_FILMAT+"-"+;					// Filial+Matricula+Apelido Responsavel
				 QI5->QI5_MAT+" "+;
				 QA_NUSR(QI5->QI5_FILMAT,QI5->QI5_MAT,.F.),;	
				 FQNCDTPACAO(QI5->QI5_TPACAO),;       // Tipo da Acao 
				 QI5->QI5_CODIGO,;						// Codigo do Plano de Acao
				 QI5->QI5_REV,;                        // Revisao da Acao
				 QI5->(Recno())})                     // Registro para controle
			DbSkip()
		Enddo
	Endif

	If Len(aQI5) == 0
		AADD( aQI5,{" ",CTOD("  /  /  "),CTOD("  /  /  "),Space(20),Space(20),Space(10),Space(2),0})
	Endif

	FQNC060IND(@aQI5,aOrdem3,6)
		
Endif

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FQNC060QI2³ Autor ³ Aldo Marini Junior   ³ Data ³ 17/02/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa para Carregar Lactos do arquivo QI2               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FQNC060QI2(aQI2,aQI3,lTelaProc,nRelac,nPos,aFiltro)        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 = Array dos Lactos de Ficha Nao-conformidade         ³±±
±±³          ³ ExpA2 = Array dos Lactos de Plano de Acao                  ³±±
±±³          ³ ExpL1 = Valor Logico que define se apresenta processamento ³±±
±±³          ³ ExpL2 = Valor Logico que define se apresenta processamento ³±±
±±³          ³ ExpN1 = Numero da opcao do relacionamento                  ³±±
±±³          ³ ExpN2 = Numero da posicao atual do registro                ³±±
±±³          ³ ExpA3 = Array com os campos a serem filtrados              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QNCA060                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FQNC060QI2(aQI2,aQI3,lTelaProc,lTelaP1,nRelac,nPos,aFiltro)
Local aQI2Sit := { OemToAnsi(STR0054),;	// "Registrada"
                   OemToAnsi(STR0053),;	// "Em Analise"
                   OemToAnsi(STR0050),;	// "Procede"					
                   OemToAnsi(STR0051),;	// "Nao Procede"
                   OemToAnsi(STR0052)} 	// "Cancelado"
Local cFilQI2	:= xFilial("QI2")
Local cFilQI9	:= xFilial("QI9")

If lTelaProc .And. !lTelaP1
	If QA4->(dbSeek(xFilial("QA4")+"QNC_QI2"+Str(Year(dDataBase),4)))
		RegProcQNC(Val(Left(QA4->QA4_CHAVE,6)))
	Else
		RegProcQNC(QI2->(RecCount()))
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega as pendencias no Array (campos) - Nao-conformidades  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aQI2 := {}
If nRelac == 1 .Or. nRelac == 3
	dbSelectArea("QI2")
	dbSetOrder(1)
	dbSeek(cFilQI2+cAnoDe,.T.)
	While !Eof() .And. cFilQI2 == QI2->QI2_FILIAL .And. ;
		cAnoDe <= QI2->QI2_ANO .And. cAnoAte >= QI2->QI2_ANO
		If lTelaProc .Or. lTelaP1
			IncProcQNC(OemToAnsi(STR0056))	// "Carregando Lactos Nao-conformidades"
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Filtra os registros das Plano de Acao conforme aFiltro       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If aFiltro <> NIL .And. aFiltro[1] == .T. .And. !Empty(aFiltro[3])
			IF &('!('+aFiltro[3]+')')
				dbSkip()
				Loop
			Endif
		Endif

		aAdd(aQI2,{QI2->QI2_FNC,;						// Codigo nao-conformidade
				QI2->QI2_REV,;                     // Revisao
				QI2->QI2_DESCR,;                   // Descricao
				aQI2SIT[Val(QI2->QI2_STATUS)],;   // Situacao
				QI2->(Recno()) })     			// Registro de Controle
		dbSkip()
	Enddo

ElseIf nRelac == 2
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se existe Relacionamento entre QI2 e QI3 == QI9     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	dbSelectArea("QI9")
	dbSetOrder(1)
  	dbSeek(cFilQI9+aQI3[nPos,1]+aQI3[nPos,2])
	While !Eof() .And. cFilQI9+aQI3[nPos,1]+aQI3[nPos,2] == QI9->QI9_FILIAL+QI9->QI9_CODIGO+QI9->QI9_REV
		If QI2->(dbSeek(cFilQI9+Right(QI9->QI9_FNC,4)+QI9->QI9_FNC+QI9->QI9_REVFNC))

			If lTelaProc .Or. lTelaP1
				IncProcQNC(OemToAnsi(STR0056))	// "Carregando Lactos Nao-conformidades"
			Endif

			dbSelectArea("QI2")
			dbSetOrder(1)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Filtra os registros dos Plano de Acao conforme aFiltro2      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If aFiltro <> NIL .And. aFiltro[1] == .T. .And. !Empty(aFiltro[3])
				IF &('!('+aFiltro[3]+')')
               dbSelectArea("QI9")
					dbSkip()
					Loop
				Endif
			Endif

			aAdd(aQI2,{QI2->QI2_FNC,;						// Codigo nao-conformidade
				QI2->QI2_REV,;                     // Revisao
				QI2->QI2_DESCR,;                   // Descricao
				aQI2SIT[Val(QI2->QI2_STATUS)],;   // Situacao
				QI2->(Recno()) })     			// Registro de Controle
			dbSelectArea("QI9")		
      Endif
		dbSkip()
	Enddo
Endif

If Len(aQI2)==0
	aAdd(aQI2,{Space(10),Space(2),Space(50),aQI2SIT[1],0})
Endif

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FQNC060QI3³ Autor ³ Aldo Marini Junior   ³ Data ³ 17/02/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa para Visualizacao dos Plano de Acao               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FQNC060QI3(aQI2,aQI3,lTelaProc,nRelac,nPos,aFiltro)        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 = Array dos Lactos de Ficha Nao-conformidade         ³±±
±±³          ³ ExpA2 = Array dos Lactos de Plano de Acao                  ³±±
±±³          ³ ExpL1 = Valor Logico que define se apresenta processamento ³±±
±±³          ³ ExpL2 = Valor Logico que define se apresenta processamento ³±±
±±³          ³ ExpN1 = Numero da opcao do relacionamento                  ³±±
±±³          ³ ExpN2 = Numero da posicao atual do registro                ³±±
±±³          ³ ExpA3 = Array com os campos a serem filtrados              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QNCA060                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FQNC060QI3(aQI2,aQI3,lTelaProc,lTelaP1,nRelac,nPos,aFiltro)
Local cFilQI3 := xFilial("QI3")
Local cFilQI9 := xFilial("QI9")

If lTelaProc .And. !lTelaP1
	If QA4->(dbSeek(xFilial("QA4")+"QNC_QI3"+Str(Year(dDataBase),4)))
		RegProcQNC(Val(Left(QA4->QA4_CHAVE,6)))
	Else
		RegProcQNC(QI3->(RecCount()))
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega as pendencias no Array (campos) - Plano de Acao      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aQI3 := {}
If nRelac == 2 .Or. nRelac == 3
	dbSelectArea("QI3")
	dbSeek(cFilQI3+cAnoDe,.T.)
	While !Eof() .And. cFilQI3 == QI3->QI3_FILIAL .And.;
		cAnoDe <= QI3->QI3_ANO .And. cAnoAte >= QI3->QI3_ANO
		If lTelaProc .Or. lTelaP1
			IncProcQNC(OemToAnsi(STR0057))	// "Carregando Lactos de Plano de Acao"
	   	Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Filtra os registros dos Plano de Acao conforme aFiltro2      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If aFiltro <> NIL .And. aFiltro[1] == .T. .And. !Empty(aFiltro[3])
			IF &('!('+aFiltro[3]+')')
				dbSkip()
				Loop
			Endif
		Endif

		aAdd(aQI3,{QI3->QI3_CODIGO,;		 // Codigo do Plano de Acao
                 QI3->QI3_REV,;         // Revisao
                 QI3->QI3_ABERTU,;      // Data Abertura
                 QI3->QI3_ENCPRE,;      // Data Encerramento Prevista
                 QI3->QI3_ENCREA,;      // Data Encerramento Real
                 QI3->(Recno()) })      // Registro de Controle
		dbSkip()
	Enddo
ElseIf nRelac == 1

	dbSelectArea("QI9")
	dbSetOrder(2)
  	dbSeek(cFilQI9+aQI2[nPos,1]+aQI2[nPos,2])
	While !Eof() .And. cFilQI9+aQI2[nPos,1]+aQI2[nPos,2] == QI9->QI9_FILIAL+QI9->QI9_FNC+QI9->QI9_REVFNC
		If QI3->(dbSeek(cFilQI9+Right(QI9->QI9_CODIGO,4)+QI9->QI9_CODIGO+QI9->QI9_REV))

			If lTelaProc .Or. lTelaP1
				IncProcQNC(OemToAnsi(STR0057))	// "Carregando Lactos de Plano de Acao"
			Endif

			dbSelectArea("QI3")
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Filtra os registros dos Plano de Acao conforme aFiltro2      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If aFiltro <> NIL .And. aFiltro[1] == .T. .And. !Empty(aFiltro[3])
				IF &('!('+aFiltro[3]+')')
					dbSelectArea("QI9")
					dbSkip()
					Loop
				Endif
			Endif

			aAdd(aQI3,{QI3->QI3_CODIGO,;    // Codigo do Plano de Acao
                    QI3->QI3_REV,;        // Revisao
                    QI3->QI3_ABERTU,;     // Data Abertura
                    QI3->QI3_ENCPRE,;     // Data Encerramento Prevista
                    QI3->QI3_ENCREA,;    	// Data Encerramento Real
                    QI3->(Recno()) })    // Registro de Controle
			dbSelectArea("QI9")
      Endif
		dbSkip()
	Enddo

	dbSelectArea("QI9")
	dbSetOrder(1)
Endif

If Len(aQI3)==0
	aAdd(aQI3,{Space(10),Space(2),CtoD("  /  /  "),CtoD("  /  /  "),CtoD("  /  /  "),0})	
Endif

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QNC060VsAca³ Autor ³ Aldo Marini Junior   ³ Data ³ 03/02/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa para Visualizacao do Plano de Acao                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QNC060VsAca(nReg) 	                     				     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Numero do Registro do Plano de Acao                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QNCA060                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QNC060VsAca(nReg)
Local cAliasOld := Alias()
Local nIndexOrd := IndexOrd()
Private aRotina := { {"","",0,0}, {STR0008,"QNC030Alt",0,0}, {"","",0,0}, {"","",0,0}, {"","",0,0}, {"","",0,0} } //"Visualizar"
INCLUI := .F.

If nReg > 0
	dbSelectArea("QI3")
	dbGoTo(nReg)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Funcao de Visualizacao do Plano de Acao do Programa QNCA030  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	QNC030Alt("QI3",QI3->(Recno()),2)

	dbSelectArea(cAliasOld)
	dbSetOrder(nIndexOrd)
Endif


Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QNC060VsFNC³ Autor ³ Aldo Marini Junior   ³ Data ³ 03/02/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa para Visualizacao da Nao-conformidade             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QNC060VsFNC(nReg) 	                     				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Numero do Registro da Nao-conformidade             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QNCA060                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QNC060VsFNC(nReg)
Local cAliasOld := Alias()
Local nIndexOrd := IndexOrd()
Private aRotina := { {"","",0,0}, {STR0008,"QNC040Alt",0,0}, {"","",0,0}, {"","",0,0}, {"","",0,0}, {"","",0,0} } //"Visualizar"
INCLUI := .F.

If nReg > 0
	dbSelectArea("QI2")
	dbSetOrder(1)
	dbGoTo(nReg)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Funcao de Visualizacao da Nao-conformidade do Programa QNCA040 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	QNC040Alt("QI2",nReg,2)

	dbSelectArea(cAliasOld)
	dbSetOrder(nIndexOrd)
Endif

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QNC060VsEta³ Autor ³ Aldo Marini Junior   ³ Data ³ 05/02/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa para Visualizacao da Etapa do Plano de Acao       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QNC060VsEta(nReg)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Numero do Registro da Etapa do Plano de Acao       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QNCA060                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QNC060VsEta(nReg)  
Local cAliasOld := Alias()
Local nIndexOrd := IndexOrd()
Local oDlgEta
Local iT		:= 0 
Local aUsrMat	:= QNCUSUARIO()
Local oGetEta   

Local lSigilo		:= .T.
Local aNomes		:= {}
Local cMensagem		:= ""
Local nConta		:= 0
Local nPosQI3		:= QI3->(Recno())
Local nIndQI3		:= QI3->(IndexOrd())

Private aRotina := {{"","",0,0},{STR0008,"QNC060VsEta",0,0},{"","",0,0},{"","",0,0},{"","",0,0},{"","",0,0}}	// "Visualizar"
Private aTELA[0][0],aGETS[0],aHeader[0]  
Private bCampo  := { |nCPO| Field( nCPO ) }
Private lDlgEtapa:= .F.  
Private nQaConPad:= 0

Private lAltEta     := .F.
Private lAutorizado := .T.

INCLUI := .F.

If nReg > 0  

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se Plano eh Sigiloso. Somente Responsavel e Reponsaveis pelas Etapas podem Manipular  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	lSigilo := .F.
	dbSelectArea("QI5")
	dbGoTo(nReg)
        
	QI3->(DbSetOrder(2))      	// Filial + Numero + Revisao
	QI3->(DbSeek(xFilial("QI3") + QI5->QI5_CODIGO + QI5->QI5_REV))

	If QI3->QI3_SIGILO == "1"	

		lSigilo := .T.
		
		If aUsrMat[2]+aUsrMat[3] <> QI3->QI3_FILMAT+QI3->QI3_MAT

			aNomes 		:= {AllTrim(Posicione("QAA",1, QI3->QI3_FILMAT+QI3->QI3_MAT,"QAA_NOME")) }   
			cMensagem 	:= ""
			
			QI5->(dbSetOrder(1))
			If QI5->(dbSeek(QI3->QI3_FILIAL+QI3->QI3_CODIGO+QI3->QI3_REV))
				While QI5->(!Eof()) .And. QI5->QI5_FILIAL+QI5->QI5_CODIGO+QI5->QI5_REV == QI3->QI3_FILIAL+QI3->QI3_CODIGO+QI3->QI3_REV
					If QI5->QI5_FILMAT + QI5->QI5_MAT <> aUsrMat[2]+aUsrMat[3]
						cNome := AllTrim(Posicione("QAA",1, QI5->QI5_FILMAT+QI5->QI5_MAT,"QAA_NOME"))
						If Ascan(aNomes,{ |x| x == cNome }) == 0
							Aadd(aNomes,cNome)
						Endif
					Else
						lSigilo := .f.
					Endif
					QI5->(dbSkip())
				Enddo
			Endif							

			For nConta := 1 To Len(aNomes)
				cMensagem += ", " + aNomes[nConta] 
			Next nConta
		Else          
			lSigilo := .F.
		Endif

	Endif

	QI3->(DbGoTo(nPosQI3))
	QI3->(DbSetOrder(nIndQI3))
					
	If lSigilo 
		If Len(aNomes) == 1
			MsgAlert(OemToAnsi(STR0070)+Chr(13)+;					// "Plano de Ação Sigiloso"
			OemToAnsi(STR0071 + Substr(cMensagem,3) + STR0073 ))  	// "Somente o usuario " ### " tem acesso aos dados."
		Else
			MsgAlert(OemToAnsi(STR0070)+Chr(13)+;					// "Plano de Ação Sigiloso"
			OemToAnsi(STR0072 + Substr(cMensagem,3) + STR0074 ))	// "Somente os usuarios " ### " terão acesso aos dados."
		Endif

	Else

		dbSelectArea("QI5")
		dbGoTo(nReg)
		
		FOR iT := 1 TO FCount()
			M->&(EVAL(bCampo,iT)) := FieldGet(iT)
		NEXT i
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Visualiza Etapa do Plano de Acao em Enchoice                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		DEFINE MSDIALOG oDlgEta TITLE OemToAnsi(STR0009) FROM 09,00 TO 30,80 // "Etapas Plano de Acao - Visualizar"
		oGetEta:=MsMGet():New("QI5",nReg,2,,,,,{003,000,125,300},,,,,,oDlgEta)
		oGetEta:oBox:Align := CONTROL_ALIGN_ALLCLIENT
		ACTIVATE MSDIALOG oDlgEta CENTERED ON INIT EnchoiceBar(oDlgEta,{||oDlgEta:End()},{||oDlgEta:End()})
	
	Endif
	
	dbSelectArea(cAliasOld)
	dbSetOrder(nIndexOrd)
Endif


Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QNC060Fil  ³ Autor ³ Aldo Marini Junior   ³ Data ³ 07/02/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa para Filtrar lancamentos                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QNC060Fil(aQI2,aQI3,aQI5)                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 = Array com os dados da Ficha Nao-cOnformidade       ³±±
±±³          ³ ExpA2 = Array com os dados dos Plano de Acao               ³±±
±±³          ³ ExpA3 = Array com os dados da Etapas das Acoes             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QNCA060                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QNC060Fil(aQI2,aQI3,aQI5)
Local aAuxFil1   := aClone(aFiltro1)
Local aAuxFil2   := aClone(aFiltro2)
Local aAuxFil3   := aClone(aFiltro3)
Local aCampo     := {}
Local aCpo       := {}
Local aStrOp     := {}
Local cAnoAteOld := cAnoAte
Local cAnoDeOld  := cAnoDe
Local cCampo     := ""
Local cExpFil    := &("aFiltro"+Str(nCadast,1)+"[3]")
Local cExpr      := ""
Local cOper      := ""
Local cTxtFil    := &("aFiltro"+Str(nCadast,1)+"[2]")
Local lFil1      := .F.
Local lFil2      := .F.
Local lFil3      := .F.
Local lRet       := .T.
Local nCadastOld := nCadast
Local nMatch     := 0
Local nOpcao     := 0
Local nRelacOld  := nRelac
Local oBtn       := Nil
Local oBtna      := Nil
Local oBtne      := Nil
Local oBtnExp    := Nil
Local oBtnOp     := Nil
Local oBtnou     := Nil
Local oCadast    := Nil
Local oCampo     := Nil
Local oDlg       := Nil
Local oExpr      := Nil
Local oFilCpo    := Nil
Local oMatch     := Nil
Local oOper      := Nil
Local oPanelFil  := Nil
Local oRelac     := Nil
Local oTxtFil    := Nil

Private aSX3QI2 := {}
Private aSX3QI3 := {}
Private aSX3QI5 := {}

aStrOp := {OemToAnsi(STR0011),; //"Igual a"
		   OemToAnsi(STR0012),; //"DIferente de"
		   OemToAnsi(STR0013),; //"Menor que"
		   OemToAnsi(STR0014),; //"Menor ou igual a"
		   OemToAnsi(STR0015),; //"Maior que"
		   OemToAnsi(STR0016),; //"Maior ou igual a"
		   OemToAnsi(STR0017),; //"Contém a expressão"
		   OemToANsi(STR0018),; //"Não contém"
		   OemToANsi(STR0019),; //"Está contido em"
		   OemToAnsi(STR0020)}  //"Não está contido em"

// Carrega todos os campos no array com os seus respectivos nomes
FQNC060SX3()					

// Carrega no array os campos do 1o. Cadastro
FQNC060CX3(@aCpo,@aCampo,.T.,1)

DEFINE MSDIALOG oDlg FROM 00,00 TO 27,65 TITLE OemToAnsi(STR0021) // "Follow-Up - Filtros"

@ 005,011 MSPANEL oPanelFil SIZE 500,500 OF oDlg 

@ 030,003 TO 065,115 LABEL OemToAnsi(STR0022) OF oPanelFil PIXEL //"Relacionamentos"
@ 036,006 RADIO oRelac VAR nRelac 3D SIZE 105,008 OF oPanelFil PIXEL ;
		  ITEMS OemToAnsi(STR0023),;   // "Ficha N.Conform. X Plano de Ação"
		  		OemToAnsi(STR0024),;   // "Plano de Ação X Ficha N. Conform."
		  		OemToAnsi(STR0025)	   // "Nenhum"

@ 030,120 TO 065,185 LABEL OemToAnsi(STR0027) OF oPanelFil PIXEL //"Cadastros"
@ 036,123 RADIO oCadast VAR nCadast 3D  SIZE 57,08 OF oPanelFil PIXEL ;
			ITEMS OemToAnsi(STR0028),; // "Ficha N.Conform." 
			      OemToAnsi(STR0029),; // "Plano de Ação"
			      OemToAnsi(STR0030) ; // "Etapas das Ações"         
			ON CHANGE ( If(nCadastOld==1,aAuxFil1,IF(nCadastOld==2,aAuxFil2,aAuxFil3)) := {lFilCpo,cTxtFil,cExpFil},;
						nCadastOld := nCadast ,;
						If(nCadast==1,(lFilCpo:=aAuxFil1[1],cTxtFil:=aAuxFil1[2],cExpFil:=aAuxFil1[3]),;
						If(nCadast==2,(lFilCpo:=aAuxFil2[1],cTxtFil:=aAuxFil2[2],cExpFil:=aAuxFil2[3]),;
										(lFilCpo:=aAuxFil3[1],cTxtFil:=aAuxFil3[2],cExpFil:=aAuxFil3[3]))),;
                        oFilCpo:Refresh(.T.),;
                        oTxtFil:Refresh(.T.),;
                        oRelac:Refresh(.T.),;
                        IF(lFilCpo,(FQNC060CX3(@aCpo,@aCampo,lFilCpo,nCadast),;
	                         oBtnOu:Disable(),oBtne:Disable(),oBtna:Enable(),oBtn:Enable(),;
							 oBtnExp:Enable(),oBtnOp:Enable(),oMatch:Disable(),oCampo:Enable(),;
							 oOper:Enable(),oTxtFil:Enable()),;
							(aCpo:={},aCampo:={},;
							 oBtnOu:Disable(),oBtne:Disable(),oBtna:Disable(),oBtn:Disable(),;
							 oBtnExp:Disable(),oBtnOp:Disable(),oMatch:Disable(),oCampo:Disable(),;
							 oOper:Disable(),oTxtFil:Disable())),;
						oCampo:aItems:=aCpo,oCampo:Refresh(.T.))

@ 031,190 TO 066,235 LABEL OemToAnsi(STR0059) OF oPanelFil PIXEL //"Ano"
@ 039,192 SAY OemToAnsi(STR0060) SIZE 9,8 PIXEL OF oPanelFil // "De"
@ 051,192 SAY OemToAnsi(STR0061) SIZE 9,8 PIXEL OF oPanelFil // "Até"
@ 037,203 MSGET oAnoDe VAR cAnoDe SIZE 01,01 PICTURE "9999" OF oPanelFil PIXEL valid !Empty(cAnoDe)
@ 050,203 MSGET oAnoAte VAR cAnoAte SIZE 01,01 PICTURE "9999" OF oPanelFil PIXEL VALID cAnoAte >= cAnoDe

@ 069,009 CHECKBOX oFilCpo VAR lFilCpo PROMPT OemToAnsi(STR0026) SIZE 65,09 OF oPanelFil PIXEL; //"Filtrar por Campos" 
			ON CHANGE (IF(lFilCpo,;
						 (FQNC060CX3(@aCpo,@aCampo,lFilCpo,nCadast),;
 						  oBtnOu:Disable(),oBtne:Disable(),oBtna:Enable(),oBtn:Enable(),;
						  oBtnExp:Enable(),oBtnOp:Enable(),oMatch:Disable(),oCampo:Enable(),;
						  oOper:Enable(),oTxtFil:Enable()),;
						 (aCpo:={},aCampo:={},;
						  oBtnOu:Disable(),oBtne:Disable(),oBtna:Disable(),oBtn:Disable(),;
						  oBtnExp:Disable(),oBtnOp:Disable(),oMatch:Disable(),oCampo:Disable(),;
						  oOper:Disable(),oTxtFil:Disable())),;
					  	oCampo:aItems:=aCpo,oCampo:Refresh(.T.))
					  	
@ 078,003 TO 185,235 LABEL OemToAnsi(STR0031) OF oPanelFil PIXEL //"Seleção de Campos"
@ 086,009 SAY OemToAnsi(STR0032) SIZE 20,8 PIXEL OF oPanelFil // "Campo:"
@ 086,071 SAY OemToAnsi(STR0033) SIZE 30,8 PIXEL OF oPanelFil // "Operador:"
@ 086,133 SAY OemToAnsi(STR0034) SIZE 30,8 PIXEL OF oPanelFil // "Expressão:"
@ 129,010 SAY OemToAnsi(STR0035) SIZE 20,8 PIXEL OF oPanelFil // "Filtro:"

@ 114,009 BUTTON oBtna PROMPT OemToAnsi(STR0036) SIZE 35,10 OF oPanelFil PIXEL ; // "&Adiciona"
		ACTION (cTxtFil := FQNC060Txt(cTxtFil,Trim(cCampo),cOper,cExpr,@cExpFil,aCampo,oCampo:nAt,oOper:nAt),;
				cExpr := FQNC060Cfd(oCampo:nAt,aCampo),;
				FQNC060Get(oExpr,@cExpr,aCampo,oCampo,oDlg),;
				oTxtFil:Refresh(),oBtne:Enable(),oBtnOp:Disable(),oBtnOu:Enable(),;
				oBtnExp:Disable(),oBtna:Disable(),oBtne:Refresh(),oBtnou:Refresh(),;
				oBtna:Refresh()) 

@ 114,49 BUTTON oBtn PROMPT OemToAnsi(STR0037) SIZE 35,10 OF oPanelFil PIXEL ; // "&Limpa Filtro"
		ACTION (cTxtFil := "",cExpFil := "",nMatch := 0,oTxtFil:Refresh(),;
				oBtnExp:Enable(),oBtnA:Enable(),oBtnE:Disable(),oBtnOu:Disable(),;
				oMatch:Disable(),oBtnOp:Enable()) 

@ 114,89 BUTTON oBtnExp PROMPT OemToAnsi(STR0038) SIZE 40,10 OF oPanelFil PIXEL ; // "&Expressão"
		ACTION (lRet:=FQNC060Exp(@cTxtFil,@cExpFil),oTxtFil:Refresh(),;
				If(lRet,oBtnOp:Disable(),oBtnOp:Enable()),;
				If(lRet,oBtnExp:Disable(),oBtnExp:Enable()),;
				If(lRet,oBtna:Disable(),oBtna:Enable()),;
				If(lRet,oBtnE:Enable(),oBtnE:Disable()),;
				If(lRet,oBtnOu:Enable(),oBtnOu:Disable())) 

@ 109,176 BUTTON oBtnOp PROMPT OemToAnsi("(") SIZE 25,10 OF oPanelFil PIXEL ;
		ACTION (If(nMatch==0,oMatch:Enable(),nil),nMatch++,;
					cTxtFil+= " ( ",cExpFil+="(",oTxtFil:Refresh()) 

@ 109,202 BUTTON oMatch PROMPT OemToAnsi(")") SIZE 25,10 OF oPanelFil PIXEL ;
		ACTION (nMatch--,cTxtFil+= " ) ",cExpFil+=")",;
				If(nMatch==0,oMatch:Disable(),nil),oTxtFil:Refresh()) 

@ 124,176 BUTTON oBtne PROMPT OemToAnsi(STR0039) SIZE 25,10 OF oPanelFil PIXEL ;	// "E"
		ACTION (cTxtFil+=" "+OemToAnsi(STR0039)+" ",cExpFil += ".and.",oTxtFil:Refresh(),; 	// "E"
				oBtne:Disable(),oBtnou:Disable(),oBtnExp:Enable(),oBtna:Enable(),;
				oBtne:Refresh(),oBtnou:Refresh(),oBtna:Refresh(),oBtnOp:Enable()) 

@ 124,202 BUTTON oBtnOu PROMPT OemToAnsi(STR0040) SIZE 25,10 OF oPanelFil PIXEL ; // "OU"
		ACTION (cTxtFil+=" "+OemToAnsi(STR0040)+" ",cExpFil += ".or.",oTxtFil:Refresh(),oBtne:Disable(),; // "OU"
				oBtnou:Disable(),oBtnExp:Enable(),oBtna:Enable(),oBtne:Refresh(),;
				oBtnou:Refresh(),oBtna:Refresh(),oBtnOp:Enable())

oMatch:Disable()
cCampo := aCpo[1]
@ 092,009 COMBOBOX oCampo VAR cCampo ITEMS aCpo SIZE 50,75 OF oPanelFil PIXEL;
		ON CHANGE (FQNC060Get(oExpr,@cExpr,aCampo,oCampo,oDlg,,oOper:nAt),;
					IF(aCampo[oCampo:nAt,7]=="M",(oOper:nAt:=7,cOper:=aStrOp[7],oOper:Refresh(.T.)),""))

cExpr := FQNC060Cfd(oCampo:nAt,aCampo)
cOper := aStrOp[1]

@ 092,71 COMBOBOX oOper VAR cOper ITEMS aStrOp SIZE 50,75 OF oPanelFil PIXEL;
		ON CHANGE FQNC060Get(oExpr,@cExpr,aCampo,oCampo,oDlg,,oOper:nAt)

@ 092,133 MSGET oExpr VAR cExpr SIZE 95,10 PIXEL OF oPanelFil PICTURE AllTrim(aCampo[oCampo:nAt,6])

@ 137,010 GET oTxtFil VAR cTxtFil MEMO NO VSCROLL SIZE 217,40 PIXEL OF oPanelFil READONLY

oTxtFil:bRClicked := {||AlwaysTrue()}
If lFilCpo
	oBtnOu:Disable();oBtne:Disable() ;oBtna:Enable() ;oBtn:Enable()
	oBtnExp:Enable();oBtnOp:Enable() ;oMatch:Disable();oCampo:Enable();oOper:Enable()
	oTxtFil:Enable()
Else
	oTxtFil:Disable();oBtn:Disable()   ;oBtna:Disable()  ;oBtne:Disable() ;oBtnOu:Disable()
	oBtnOp:Disable() ;oBtnExp:Disable();oCampo:Disable();oOper:Disable()
Endif

If !Empty(cTxtFil)
	oBtne:Enable()
	oBtnOu:Enable()
	oBtnOp:Disable()
	oBtnExp:Disable()
	oBtna:Disable()
Endif

ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{||nOpcao:=1,oDlg:End()},{||nOpcao:=2,oDlg:End()})

If nOpcao == 1 // OK

	FQNC060FCA(@lFil1,aFiltro1,aAuxFil1)
	FQNC060FCA(@lFil2,aFiltro2,aAuxFil2)
	If (nRelac == 1 .Or. nRelac == 2) .And. nRelacOld <> nRelac
		If nRelac == 2 .Or. (nRelac == 1 .And. nRelacOld <> 3)
			lFil1 := .T.
		Endif
		If nRelac == 1 .Or. (nRelac == 2 .And. nRelacOld <> 3)
			lFil2 := .T.
		Endif
	Endif

	If nRelac == 3 .And. nRelacOld <> nRelac
		If nRelacOld == 1
			lFil2 := .T.
		ElseIf nRelacOld == 2
			lFil1 := .T.
		Endif
	Endif
    If cAnoDeOld <> cAnoDe .Or. cAnoAteOld <> cAnoAte
		lFil1 := .T.
		lFil2 := .T.
    Endif
	FQNC060FCA(@lFil3,aFiltro3,aAuxFil3)
	IF !lFil3 .And. lFil2
		lFil3 := .T.
	Endif

	aFiltro1 := aClone(aAuxFil1)
	aFiltro2 := aClone(aAuxFil2)
	aFiltro3 := aClone(aAuxFil3)

	If nCadast==1
		aFiltro1 := {lFilCpo,cTxtFil,cExpFil}
		FQNC060FCA(@lFil1,aFiltro1,aAuxFil1)
		If nRelac == 2 .And. nRelacOld <> nRelac
			lFil1 := .T.
		Endif
	ElseIf nCadast == 2
		aFiltro2 := {lFilCpo,cTxtFil,cExpFil}
		FQNC060FCA(@lFil2,aFiltro2,aAuxFil2)
		If (nRelac == 1 .Or. nRelac == 3) .And. nRelacOld <> nRelac
			lFil2 := .T.
		Endif
	ElseIf nCadast == 3
		aFiltro3 := {lFilCpo,cTxtFil,cExpFil}
		FQNC060FCA(@lFil3,aFiltro3,aAuxFil3)
		IF !lFil3 .And. lFil2
			lFil3 := .T.
		Endif
	Endif

	// Carrega todas as tabelas relacionadas com a consulta
	QNC060CARR(@aQI2,@aQI3,@aQI5,lFil1,lFil2,lFil3,"X",aFiltro1,aFiltro2,aFiltro3)

Else // Cancel - Retorna os valores das variaveis
	lRet	:= .F.
	nCadast	:= 	nCadastOld
	nRelac	:= 	nRelacOld	
	cAnoDe	:= 	cAnoDeOld
	cAnoAte	:= 	cAnoAteOld
Endif

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FQNC060FCA ³ Autor ³ Aldo Marini Junior  ³ Data ³ 07/02/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa para Verificar atualizacao de filtros             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FQNC060FCA(lAtualiza,aArray1,aArray2)                 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpL1 = Valor logico indicando se havera atualizacao       ³±±
±±³          ³ ExpA1 = Array contendo configuracao filtro informado anter.³±±
±±³          ³ ExpA2 = Array contendo configuracao filtro a atualizar     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QNCA060                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FQNC060FCA(lAtualiza,aArray1,aArray2)
Local nT	:= 0
For nT := 1 to Len(aArray1)
	If aArray1[nT] <> aArray2[nT]
		lAtualiza := .T.
		Exit
	Endif
Next

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FQNC060CX3 ³ Autor ³ Aldo Marini Junior  ³ Data ³ 07/02/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa para Carregar os arrays no Combo                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FQNC060CX3(@aCombo,lFilCpo,lFilQI2,lFilQI3,lFilQI5) 		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 = Array onde sera guardado os campos dos arquivos    ³±±
±±³          ³ ExpL1 = Var.Logica indicando se havera filtro por campo    ³±±
±±³          ³ ExpL2 = Var.logica indicando se havera por Nao-conformidade³±±
±±³          ³ ExpL3 = Var.Logica indicando se havera por Plano de Acao   ³±±
±±³          ³ ExpL4 = Var.Logica indicando se havera por Etapas das Acoes³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QNCA060                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FQNC060CX3(aCpo,aCampo,lFilCpo,nCadast)
aCpo:={}
aCampo:={}
If lFilCpo
	If nCadast == 1		// Nao-conformidades
		aEval(aSX3QI2,{|x| aAdd(aCpo,x[1])})
		aEval(aSX3QI2,{|x| aAdd(aCampo,x[2])})
	Endif
	If nCadast == 2		// Plano de Acao 
		aEval(aSX3QI3,{|x| aAdd(aCpo,x[1])})
		aEval(aSX3QI3,{|x| aAdd(aCampo,x[2])})
	Endif
	If nCadast == 3		// Etapas das Acoes
		aEval(aSX3QI5,{|x| aAdd(aCpo,x[1])})
		aEval(aSX3QI5,{|x| aAdd(aCampo,x[2])})
	Endif
Endif

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FQNC060SX3 ³ Autor ³ Aldo Marini Junior  ³ Data ³ 07/02/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa para Carregar os campos do SX3 para array         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FQNC060SX3()             						  		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QNCA060                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FQNC060SX3

Local aStruQI2 := FWFormStruct(3, "QI2")[3]
Local aStruQI3 := FWFormStruct(3, "QI3")[3]
Local aStruQI5 := FWFormStruct(3, "QI5")[3]
Local nX

aSX3QI2:={}
aSX3QI3:={}
aSX3QI5:={}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega os nomes dos campos nos arrays para o combobox       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX := 1 To Len(aStruQI2)
	If cNivel >= GetSx3Cache(aStruQI2[nX,1], "X3_NIVEL") .AND.;
		Trim(aStruQI2[nX,1])<>"QI2_FILIAL" .And. GetSx3Cache(aStruQI2[nX,1], "X3_CONTEXT") <> "V"
		AADD(aSX3QI2, Q060GetSX3(aStruQI2[nX,1]) )
	EndIf
Next nX

For nX := 1 To Len(aStruQI3)
	If cNivel >= GetSx3Cache(aStruQI3[nX,1], "X3_NIVEL") .AND.;
		Trim(aStruQI3[nX,1])<>"QI2_FILIAL" .And. GetSx3Cache(aStruQI3[nX,1], "X3_CONTEXT") <> "V"
		AADD(aSX3QI3, Q060GetSX3(aStruQI3[nX,1]) )
	EndIf
Next nX

For nX := 1 To Len(aStruQI5)
	If cNivel >= GetSx3Cache(aStruQI5[nX,1], "X3_NIVEL") .AND.;
		Trim(aStruQI5[nX,1])<>"QI2_FILIAL" .And. GetSx3Cache(aStruQI5[nX,1], "X3_CONTEXT") <> "V"
		AADD(aSX3QI5, Q060GetSX3(aStruQI5[nX,1]) )
	EndIf
Next nX

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FQNC060Cfd ³ Autor ³ Aldo Marini Junior  ³ Data ³ 09/02/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retornar valor conforme o tipo do campo     				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FQNC060Cfd(nAt,aCampo)   						  		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Numero da linha do array aCampo                    ³±±
±±³          ³ ExpA1 = Array a ser verificado o tipo do campo             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QNCA060                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FQNC060Cfd(nAt,aCampo)
Local cRet

If aCampo[nAt,7] == "C" .Or. aCampo[nAt,7] == "M"
	cRet := Space(aCampo[nAt,5])
ElseIf aCampo[nAt,7] == "N"
	cRet := 0
ElseIf aCampo[nAt,7] == "D"
	cRet := CTOD("  /  /  ")
EndIf
Return cRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FQNC060Txt ³ Autor ³ Aldo Marini Junior  ³ Data ³ 09/02/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa para Montar String de comparacao de campos        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FQNC060Txt(cTxtFil,cCampo,cOper,xExpr,cExpFil,aCampo,      ³±±
±±³          ³ nCpo,nOper)                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Descricao do filtro a ser visualizado              ³±±
±±³          ³ ExpC2 = Descricao do campo selecionado                     ³±±
±±³          ³ ExpC3 = Descricao do Operador selecionado                  ³±±
±±³          ³ ExpC4 = Descricao da Expressao                             ³±±
±±³          ³ ExpC5 = Array a ser verificado o tipo do campo             ³±±
±±³          ³ ExpA1 = Array contendo os campos                           ³±±
±±³          ³ ExpN1 = Numero que contem opcao selecionada (campos)       ³±±
±±³          ³ ExpN2 = Numero que contem opcao selecionada (operador)     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QNCA060                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FQNC060Txt(cTxtFil,cCampo,cOper,xExpr,cExpFil,aCampo,nCpo,nOper)
Local cChar := OemToAnsi(CHR(39))
Local cType := ValType(xExpr)
Local aOper := { "==","!=","<","<=",">",">=","..","!.","$","!x"}

cType := IF(aCampo[nCpo,7]=="M","M",cType)

cTxtFil += cCampo+" "+cOper+" "+If(cType=="C",cChar,"")+;
								 IF(cType=="M",Alltrim(cValToChar(xExpr)),cValToChar(xExpr))+;
								 If(cType=="C",cChar,"")
If cType == "C"
	If  aOper[nOper] == "!."    //  Nao Contem
		cExpFil += '!('+'"'+AllTrim(cValToChar(xExpr))+'"'+' $ '+aCampo[nCpo,1]+')'   // Inverte Posicoes
	ElseIf aOper[nOper] == "!x"   // Nao esta contido
		cExpFil += '!('+aCampo[nCpo,1]+" $ " + '"'+AllTrim(cValToChar(xExpr))+'")'
	ElseIf aOper[nOper]	== ".."  // Contem a Expressao
		cExpFil += '"'+AllTrim(cValToChar(xExpr))+'"'+" $ "+aCampo[nCpo,1] +" "   // Inverte Posicoes
	Else
		If (aOper[nOper]=="==")
			cExpFil += aCampo[nCpo,1] +aOper[nOper]+" "
			cExpFil += '"'+cValToChar(xExpr)+'"'
		Else
			cExpFil += aCampo[nCpo,1] +aOper[nOper]+" "
			cExpFil += '"'+AllTrim(cValToChar(xExpr))+'"'
		Endif
	EndIf
ElseIf cType == "D"
	cExpFil += "DtoS("+aCampo[nCpo,1]+") "+aOper[nOper]+' "'
	cExpFil += Dtos(CTOD(cValToChar(xExpr)))+'"'
ElseIf cType == "M"
	If  aOper[nOper] == "!."    //  Nao Contem
		cExpFil += '!('+'"'+AllTrim(cValToChar(xExpr))+'"'+' $ '+AllTrim(aCampo[nCpo,9])+')'   // Inverte Posicoes
	ElseIf aOper[nOper] == "!x"   // Nao esta contido
		cExpFil += '!('+AllTrim(aCampo[nCpo,9])+" $ " + '"'+AllTrim(cValToChar(xExpr))+'")'
	ElseIf aOper[nOper]	== ".."  // Contem a Expressao
		cExpFil += '"'+AllTrim(cValToChar(xExpr))+'"'+" $ "+AllTrim(aCampo[nCpo,9])+" "   // Inverte Posicoes
	Else
		cExpFil += AllTrim(aCampo[nCpo,9]) +aOper[nOper]+" "
		cExpFil += '"'+AllTrim(cValToChar(xExpr))+'"'
	EndIf
Else
	cExpFil += aCampo[nCpo,1]+" "+aOper[nOper]+" "
	cExpFil += cValToChar(xExpr)
EndIf

Return cTxtFil



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FQNC060Get ³ Autor ³ Aldo Marini Junior  ³ Data ³ 09/02/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa para Montar String de comparacao de campos        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FQNC060Get(oExpr,cExpr,aCampo,oCampo,oDlg,lFirst,nOpr)     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Objeto da descricao da Expressao                   ³±±
±±³          ³ ExpC1 = Descricao do Expressao                             ³±±
±±³          ³ ExpA1 = Array com os campos do cadastro selecionado        ³±±
±±³          ³ ExpO2 = Objeto do Combobox - Selecao de campos             ³±±
±±³          ³ ExpO3 = Objeto da DIALOG                                   ³±±
±±³          ³ ExpL1 = Atualizar a Picture do GET                         ³±±
±±³          ³ ExpN1 = Numero da opcao selecionada (operador)             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QNCA060                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
FUNCTION FQNC060Get(oExpr,cExpr,aCampo,oCampo,oDlg,lFirst,nOpr)
Local cPicture := AllTrim(aCampo[oCampo:nAt,6])
Local aOper := { "==","!=","<","<=",">",">=","..","!.","$","!x"}

cExpr := FQNC060Cfd(oCampo:nAt,aCampo)
DEFAULT lFirst := .t.

If Empty(cPicture)
	If aCampo[oCampo:nAT,7] == "N"
		cPicture := "@E "+Replicate("9",aCampo[oCampo:nAT,5])
		If aCampo[oCampo:nAT,8] > 0
			cPicture := Subs(cPicture,1,Len(cPicture)-(aCampo[oCampo:nAt,8]+1))
			cPicture += "."+Replicate("9",aCampo[oCampo:nAT,8])
		EndIf
	ElseIf aCampo[oCampo:nAT,7] == "C"
		cPicture := "@K"
	EndIf

EndIf

If aCampo[oCampo:nAt,7] == "D"
	cPicture := "@D"
EndIf

If nOpr != Nil
	If aOper[nOpr] $ "$|!x"
		cExpr := Space(60)
		cPicture := "@S23"
	EndIf
EndIf
oExpr:oGet:Picture := cPicture
oExpr:oGet:Pos := 0

SetFocus(oExpr:hWnd)
oExpr:oGet:Assign()
oExpr:Refresh()
// Executando a segunda vez para for‡ar a Picture do GET.
If lFirst
	FQNC060Get(oExpr,cExpr,aCampo,oCampo,oDlg,.f.,nOpr)
EndIf
Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FQNC060Exp ³ Autor ³ Aldo Marini Junior  ³ Data ³ 09/02/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa Editar a Expressao a ser adicionada               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FQNC060Exp(cTxtFil,cExpFil                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Descricao do Filtro a ser mostrado                 ³±±
±±³          ³ ExpC2 = Descricao do Filtro a ser usado nos campos         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QNCA060                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FQNC060Exp(cTxtFil,cExpFil)

Local oDlg, oBtn, cExpr := Space(255), oPai
Local lProcess := .f.

oPai:= GetWndDefault()

DEFINE MSDIALOG oDlg TITLE OemToAnsi( STR0041 ) FROM 0,0 TO 100,500 OF oPai PIXEL	// "Expressao de Filtro"

@ 10,10 MSGET oExpr VAR cExpr SIZE 230,10 OF oDlg PIXEL
@ 30,10 TO 30,240 OF oDlg PIXEL
@ 35,10 BUTTON oBtn PROMPT OemToAnsi(STR0036) SIZE 40,10 PIXEL ACTION (lProcess := .t.,oDlg:End()) // "&Adiciona"
@ 35,55 BUTTON oBtn PROMPT OemToAnsi(STR0043) SIZE 40,10 PIXEL ACTION oDlg:End() // "&Cancela"

ACTIVATE MSDIALOG oDlg CENTERED

If lProcess

	cTxtFil += Trim(cExpr)
	cExpFil += Trim(cExpr)

	// Retorno correto para o Enable/Disable dos botoes.
	If Empty(cExpr)
		lProcess:= .F.
	EndIf

EndIf
Return lProcess

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QNC060Ord  ³ Autor ³ Aldo Marini Junior   ³ Data ³ 14/02/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa para Ordenar lancamentos                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QNC060Ord(aQI2,aQI3,aQI5)                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 = Array com os dados da Ficha Nao-cOnformidade       ³±±
±±³          ³ ExpA2 = Array com os dados dos Plano de Acao               ³±±
±±³          ³ ExpA3 = Array com os dados da Etapas das Acoess            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QNCA060                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QNC060Ord(aQI2,aQI3,aQI5)
Local aAuxOrd1   := {}
Local aAuxOrd2   := {}
Local aAuxOrd3   := {}
Local aCpo       := {}
Local aOrd       := {}
Local aOrdLst    := {}
Local aOrdQI2    := {}
Local aOrdQI3    := {}
Local aOrdQI5    := {}
Local lRet       := .T.
Local nCadastOld := nCadastO
Local nItem1     := 1
Local nItem2     := 1
Local nOpcao     := 0
Local nOrdena    := 1
Local oBtn       := Nil
Local oBtnVai    := Nil
Local oBtnVolta  := Nil
Local oCadast    := Nil
Local oCampo1    := Nil
Local oCampo2    := Nil
Local oDlg       := Nil
Local oOrdena    := Nil
Local oPanelOrd  := Nil

aOrdQI2 := {{Trim(TitSX3("QI2_FNC")[1]),;     // Campos do QI2- Nao-conformidades
			 Trim(TitSX3("QI2_REV")[1]),;
			 Trim(TitSX3("QI2_DESCR")[1]),;
			 Trim(TitSX3("QI2_STATUS")[1])},;
			 {1,2}} 

aOrdQI3 := {{Trim(TitSX3("QI3_CODIGO")[1]),;  // Campos do QI3 - Plano de Acao
		     Trim(TitSX3("QI3_REV")[1]),;
			 Trim(TitSX3("QI3_ABERTU")[1]),;
			 Trim(TitSX3("QI3_ENCPRE")[1]),;
			 Trim(TitSX3("QI3_ENCREA")[1])},;
			 {1,2}}
             
aOrdQI5 := {{Trim(TitSX3("QI5_STATUS")[1]),;	// Campos do QI5 - Etapas dos Plano de Acao
			 Trim(TitSX3("QI5_PRAZO")[1]),;
			 Trim(TitSX3("QI5_REALIZ")[1]),;
			 Trim(TitSX3("QI5_NUSR")[1]),;
			 Trim(TitSX3("QI5_TPACAO")[1]),;
			 Trim(TitSX3("QI5_CODIGO")[1]),;
			 Trim(TitSX3("QI5_REV")[1])},;
			 {2,1,4}}

// Atribui os campos dos arquivos e os campos selecionados anteriormente
If nCadastO == 1
	aCpo 	:= aClone(aOrdQI2[1])	
	aEval(aOrdem1[2], {|x| aAdd(aOrd,aOrdQI2[1,x]) })
	aOrdLst := aClone(aOrdem1[2])
	nOrdena := aOrdem1[1]
ElseIf nCadastO == 2
	aCpo 	:= aClone(aOrdQI3[1])
	aEval(aOrdem2[2], {|x| aAdd(aOrd,aOrdQI3[1,x]) })
	aOrdLst := aClone(aOrdem2[2])
	nOrdena := aOrdem2[1]
ElseIf nCadastO == 3
	aCpo 	:= aClone(aOrdQI5[1])
	aEval(aOrdem3[2], {|x| aAdd(aOrd,aOrdQI5[1,x]) })
	aOrdLst := aClone(aOrdem3[2])
	nOrdena := aOrdem3[1]
Endif

aAuxOrd1 := aClone(aOrdem1)
aAuxOrd2 := aClone(aOrdem2)
aAuxOrd3 := aClone(aOrdem3)

DEFINE MSDIALOG oDlg FROM 00,00 TO 28,50 TITLE OemToAnsi(STR0042) // "Ordenar os Lancamentos"

@ 017,015 MSPANEL oPanelOrd SIZE 200,500 OF oDlg 

@ 029,013 TO 065,084 LABEL OemToAnsi(STR0027) OF oPanelOrd PIXEL //"Cadastros"
@ 035,018 RADIO oCadast VAR nCadastO 3D  SIZE 64,08 OF oPanelOrd PIXEL ;
			ITEMS OemToAnsi(STR0062),; //"Ficha N.Conformidade" 
			      OemToAnsi(STR0029),; //"Plano de Ação"
			      OemToAnsi(STR0030) ; //"Etapas das Ações"
			ON CHANGE ( If(nCadastOld==1,aAuxOrd1,IF(nCadastOld==2,aAuxOrd2,aAuxOrd3)) := {nOrdena,aClone(aOrdLst)} ,;
						nCadastOld := nCadastO,aOrd:={},;
						If(nCadastO==1,(aOrdLst:=aClone(aAuxOrd1[2]),aCpo:=aClone(aOrdQI2[1]),;
										 aEval(aAuxOrd1[2],{|x| aAdd(aOrd,aOrdQI2[1,x]) }),;
										 oOrdena:nOption:=aAuxOrd1[1]),;
						If(nCadastO==2,(aOrdLst:=aClone(aAuxOrd2[2]),aCpo:=aClone(aOrdQI3[1]),;
										 aEval(aAuxOrd2[2],{|x| aAdd(aOrd,aOrdQI3[1,x]) }),;
										 oOrdena:nOption:=aAuxOrd2[1]),;
									    (aOrdLst:=aClone(aAuxOrd3[2]),aCpo:=aClone(aOrdQI5[1]),;
									     aEval(aAuxOrd3[2],{|x| aAdd(aOrd,aOrdQI5[1,x]) }),;
									     oOrdena:nOption:=aAuxOrd3[1]))),;
						oCampo1:SetItems(aCpo),oCampo1:Refresh(.T.),oCampo1:GoTop(),;
                        oCampo2:SetItems(aOrd),oCampo2:Refresh(.T.),oCampo2:GoTop())
 
@ 029,087 TO 065,162 LABEL OemToAnsi(STR0047) OF oPanelOrd PIXEL //"Ordenação"
@ 035,092 RADIO oOrdena VAR nOrdena  3D  SIZE 60,08 OF oPanelOrd PIXEL;
			ITEMS OemToAnsi(STR0048),; //"Crescente"
			      OemToAnsi(STR0049) 	//"Decrescente"
			
@ 070,013 TO 173,160 LABEL OemToAnsi(STR0031) OF oPanelOrd PIXEL //"Seleção de Campos"

@ 105,074 BUTTON oBtn PROMPT OemToAnsi(STR0044) SIZE 25,10 OF oPanelOrd PIXEL ; // "&Padrão"
		ACTION (IF(nCadastO == 1,(aCpo:=aClone(aOrdQI2[1]),aOrd:={aOrdQI2[1,1],aOrdQI2[1,2]},;
									aOrdLst := aClone(aOrdQI2[2]),aAuxOrd1:={1,aClone(aOrdQI2[2])}),;
				IF(nCadastO == 2,(aCpo:=aClone(aOrdQI3[1]),aOrd:={aOrdQI3[1,1],aOrdQI3[1,2]},;
									aOrdLst := aClone(aOrdQI3[2]),aAuxOrd2:={1,aClone(aOrdQI3[2])}),;
								  (aCpo:=aClone(aOrdQI5[1]),aOrd:={aOrdQI5[1,2],aOrdQI5[1,1],;
							  	aOrdQI5[1,4]},aOrdLst:=aClone(aOrdQI5[2]),aAuxOrd3:={1,aClone(aOrdQI5[2])}))),;
				nOrdena:=1, ;
				oCampo1:SetItems(aCpo),oCampo1:Refresh(.T.),oCampo1:GoTop(),;
				oCampo2:SetItems(aOrd),oCampo2:Refresh(.T.),oCampo2:GoTop())

@ 117,074 BUTTON oBtnVai PROMPT OemToAnsi(">>") SIZE 25,10 OF oPanelOrd PIXEL ;
		ACTION If(aScan(aOrd,aCpo[nItem1]) == 0 ,;
					(IF(Len(aOrd)==1 .And. aOrd[1]=" ",(aOrd:={},aOrdLst:={}),""),;
					aAdd(aOrdLst,nItem1),;
					aAdd(aOrd,aCpo[nItem1]),;
					oCampo2:SetItems(aOrd),;
					oCampo2:Refresh(.T.) ),"")

@ 129,074 BUTTON oBtnVolta PROMPT OemToAnsi("<<") SIZE 25,10 OF oPanelOrd PIXEL;
		 ACTION	(aDel(aOrd,nItem2),;
				aSize(aOrd,Len(aOrd)-1),;
				If(Len(aOrd)==0,aAdd(aOrd," "),""),;
				If(Len(aOrdLst)>0,(aDel(aOrdLst,nItem2),aSize(aOrdLst,Len(aOrdLst)-1)),"") ,;
				oCampo2:SetItems(aOrd),;
				oCampo2:Refresh(.T.))

oBtnVai:cToolTip:=OemToAnsi(STR0045)   // "Adiciona Campo"
oBtnVai:Disable()
oBtnVolta:cToolTip:=OemToAnsi(STR0046) // "Exclui Campo"
oBtnVolta:Disable()

@ 077,019 LISTBOX oCampo1 VAR nItem1 ITEMS aCpo SIZE 50,93 OF oPanelOrd PIXEL ;
		  ON CHANGE IF(oCampo1:GetPos() > 0,oBtnVai:Enable(),oBtnVai:Disable())
@ 077,105 LISTBOX oCampo2 VAR nItem2 ITEMS aOrd SIZE 50,93 OF oPanelOrd PIXEL ;
		  ON CHANGE IF(oCampo2:GetPos() > 0,oBtnVolta:Enable(),oBtnVolta:Disable())

ACTIVATE MSDIALOG oDlg CENTERED ON INIT ;
			EnchoiceBar(oDlg,{||If(Len(aOrdLst)>0,(nOpcao:=1,oDlg:End()),"")},{||nOpcao:=2,oDlg:End()})

If nOpcao == 1 // OK

	aOrdem1 := aClone(aAuxOrd1)
	aOrdem2 := aClone(aAuxOrd2)
	aOrdem3 := aClone(aAuxOrd3)

	If nCadastO == 1						 // Ficha N.Conformidade
		aOrdem1 := {nOrdena,aClone(aOrdLst)}
	ElseIf nCadastO == 2                     // Plano de Ação
		aOrdem2 := {nOrdena,aClone(aOrdLst)}
	ElseIf nCadastO == 3                     // Etapas dos Plano de Ação
		aOrdem3 := {nOrdena,aClone(aOrdLst)}
	Endif

	If nRelac == 1
        //ProcQNC({|| FQNC060IND(@aQI2,aOrdem1,1,.T.) })
		FQNC060IND(@aQI2,aOrdem1,1)
		FQNC060QI3(aQI2,@aQI3,.F.,.F.,nRelac,1,aFiltro2)
		FQNC060IND(@aQI3,aOrdem2,1)
	ElseIf nRelac == 2
        //ProcQNC({|| FQNC060IND(@aQI3,aOrdem2,1,.T.) })
		FQNC060IND(@aQI3,aOrdem2,1)
		FQNC060QI2(@aQI2,aQI3,.F.,.F.,nRelac,1,aFiltro1)
		FQNC060IND(@aQI2,aOrdem1,1)
	Else
        //ProcQNC({|| FQNC060IND(@aQI2,aOrdem1,1,.T.) })
        //ProcQNC({|| FQNC060IND(@aQI3,aOrdem2,1,.T.) })		
		FQNC060IND(@aQI2,aOrdem1,1)
		FQNC060IND(@aQI3,aOrdem2,1)
		QNC060CARR(@aQI2,@aQI3,@aQI5,.F.,.F.,.T.,1,aFiltro1,aFiltro2,aFiltro3)
		FQNC060IND(@aQI5,aOrdem3,6)
	Endif	
Else 	// Cancel - Retorna os valores das variaveis
	lRet	 := .F.
	nCadastO := nCadastOld
Endif

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FQNC060IND ³ Autor ³ Aldo Marini Junior  ³ Data ³ 18/02/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa para Ordenar Lactos conforme campos selecionados  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FQNC060IND(aArray,aOrdem,nCampo)                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 = Array do cadastro a ser atualizado                 ³±±
±±³          ³ ExpA2 = Array com os parametros de ordenacao               ³±±
±±³          ³ ExpN1 = Numero da posicao do array para os Codigos FNC/Acao³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QNCA060                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FQNC060IND(aArray,aOrdem,nCampo,lTelaP1)
Local cChave	:= ""
Local nA	    := 0
Local bOrdem	:= {||}
lTelaP1 := If(lTelaP1==NIL,.F.,lTelaP1)

For nA := 1 to Len(aOrdem[2])
	If ValType(aArray[1,aOrdem[2][nA]]) == "D"
		cChave+="DtoS(X["+Str(aOrdem[2][nA],1)+"])"+IF(Len(aOrdem[2])>nA,"+","")
	Else
		If nA == nCampo
			cChave+="Right(X["+Str(aOrdem[2][nA],1)+"],4)+Left(X["+Str(aOrdem[2][nA],1)+"], Len(X["+Str(aOrdem[2][nA],1)+"]) - 4)"
			cChave+=IF(Len(aOrdem[2])>nA,"+","")
		Else
			cChave+="X["+Str(aOrdem[2][nA],1)+"]"+IF(Len(aOrdem[2])>nA,"+","")
		Endif
	Endif
Next

cChave := cChave +IF(aOrdem[1]==1," < "," > ")+StrTran(cChave,"X","Y")
//If lTelaP1 .And. Len(aArray) > 0
//	bOrdem := &("{|X,Y| ("+cChave+") .And. ftete() }")		// "Indexando registros..."
//Else
	bOrdem := &("{|X,Y| "+cChave+"}")
//Endif
aArray := aSort(aArray,,,bOrdem)

Return	
		
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QNC060Psq  ³ Autor ³ Aldo Marini Junior   ³ Data ³ 16/03/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa para Ordenar lancamentos                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QNC060Psq(oQI2,oQI3,nPosQI2,nPosQI3)	       				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 = Array com os dados da Ficha Nao-cOnformidade       ³±±
±±³          ³ ExpA2 = Array com os dados dos Plano de Acao               ³±±
±±³          ³ ExpA3 = Array com so dados das Etapas das Acoes            ³±±
±±³          ³ ExpO1 = Objeto do ListBox da Ficha Nao-cOnformidade        ³±±
±±³          ³ ExpO2 = Objeto do LixtBox dos Planos de Acao               ³±±
±±³          ³ ExpN1 = Posicao do array para FNC                          ³±±
±±³          ³ ExpN2 = Posicao do array para Plano de Acao                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QNCA060                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QNC060Psq(aQI2,aQI3,aQI5,oQI2,oQI3,nPosQI2,nPosQI3)
Local aOrdem     := {}
Local aOrdQI2    := {}
Local aOrdQI3    := {}
Local bCodeP     := {||}
Local cChave     := Space(80)
Local cOrdAux    := ""
Local cOrdem     := ""
Local cPesq      := ""
Local nA         := 0
Local nOpcao     := 0
Local nPosQI2Old := nPosQI2
Local nPosQI3Old := nPosQI3
Local oBtn1      := Nil
Local oBtn2      := Nil
Local oCadast    := Nil
Local oChave     := Nil
Local oDlg       := Nil
Local oOrdem     := Nil

aOrdQI2 := {Trim(TitSX3("QI2_FNC")[1]),;    // Campos do QI2- Nao-conformidades
		    Trim(TitSX3("QI2_REV")[1]),;
		    Trim(TitSX3("QI2_DESCR")[1]),;
		    Trim(TitSX3("QI2_STATUS")[1])}

aOrdQI3 := {Trim(TitSX3("QI3_CODIGO")[1]),; // Campos do QI3 - Plano de Acao 
			Trim(TitSX3("QI3_REV")[1]),;
			Trim(TitSX3("QI3_ABERTU")[1]),;
			Trim(TitSX3("QI3_ENCPRE")[1]),;
			Trim(TitSX3("QI3_ENCREA")[1])}

// Monta as descricoes das ordens dos arquivos
aEval(aOrdem1[2], {|X| cOrdAux+= aOrdQI2[X] + " + "})
aAdd(aOrdem,SubStr(cOrdAux,1,Len(cOrdAux)-3))

cOrdAux := ""
aEval(aOrdem2[2], {|x| cOrdAux+= aOrdQI3[x] + " + "})
aAdd(aOrdem,SubStr(cOrdAux,1,Len(cOrdAux)-3))

DEFINE MSDIALOG oDlg FROM 00,00 TO 13.5,46 TITLE OemToAnsi(STR0064) // "Pesquisa Rápida"

@ 005,010 TO 031,176 LABEL OemToAnsi(STR0027) OF oDlg PIXEL //"Cadastros"
@ 012,014 RADIO oCadast VAR nCadPsq  3D  SIZE 66,08 OF oDlg PIXEL ;
			ITEMS OemToAnsi(STR0062),; //"Ficha N.Conformidade" 
			      OemToAnsi(STR0029) ; //"Plano de Ação"
			ON CHANGE (cChave:=Space(80),oChave:SetText(cChave),oChave:Refresh(),;
						cOrdem:=aOrdem[nCadPsq],oOrdem:SetText(cOrdem),oOrdem:Refresh())

@ 033,010 TO 55,176 LABEL OemToAnsi(STR0065) OF oDlg PIXEL // "Ordem"
@ 041,012 MSGET oOrdem VAR cOrdem SIZE 163,10 PIXEL

@ 057,010 TO 79,176 LABEL OemToAnsi(STR0066) OF oDlg PIXEL // "Chave Pesquisa"
@ 065,012 MSGET oChave VAR cChave SIZE 163,10 PIXEL

cOrdem:=aOrdem[nCadPsq]
oOrdem:SetText(cOrdem)
OOrdem:lReadOnly:= .T.
oOrdem:Refresh()

DEFINE SBUTTON oBtn1 FROM 084,120 TYPE  1 ENABLE OF oDlg ACTION (nOpcao:=1,oDlg:End()) // Ok
DEFINE SBUTTON oBtn2 FROM 084,150 TYPE  2 ENABLE OF oDlg ACTION oDlg:End()			   // Cancelar

ACTIVATE MSDIALOG oDlg CENTERED 

If nOpcao == 1 // OK

	cChave := AllTrim(cChave)

	If nCadPsq == 1		// Ficha N.Conformidade

		cPesq := ""
		For nA := 1 to Len(aOrdem1[2])
			If ValType(aQI2[1,aOrdem1[2][nA]]) == "D"
				cPesq+="DtoS(X["+Str(aOrdem1[2][nA],1)+"])"+IF(Len(aOrdem1[2])>nA,"+","")
			Else
				cPesq+="X["+Str(aOrdem1[2][nA],1)+"]"+IF(Len(aOrdem1[2])>nA,"+","")
			Endif
		Next

		bCodeP := &("{|X| SubStr("+cPesq+",1,Len(cChave)) == '"+cChave+"' }")
		If (nPosQI2 := aScan(oQI2:aArray,bCodeP)) == 0
			nPosQI2 := nPosQI2Old
		Endif	

		oQI2:nAt:=nPosQI2
		
	Else // Plano de Ação
		cPesq := ""
		For nA := 1 to Len(aOrdem2[2])
			If ValType(aQI3[1,aOrdem2[2][nA]]) == "D"
				cPesq+="DtoS(X["+Str(aOrdem2[2][nA],1)+"])"+IF(Len(aOrdem2[2])>nA,"+","")
			Else
				cPesq+="X["+Str(aOrdem2[2][nA],1)+"]"+IF(Len(aOrdem2[2])>nA,"+","")
			Endif
		Next

		bCodeP := &("{|X| SubStr("+cPesq+",1,Len(cChave)) == '"+cChave+"' }")
		If (nPosQI3 := aScan(oQI3:aArray,bCodeP)) == 0
			nPosQI3 := nPosQI3Old
		Endif	

		oQI3:nAt:=nPosQI3
		
	Endif	

	If     nRelac == 1 .And. nCadPsq == 1
			FQNC060QI3(aQI2,@aQI3,.F.,.F.,nRelac,nPosQI2,aFiltro2)
			FQNC060IND(@aQI3,aOrdem2,1)
			oQI3:aArray:=aQI3
			oQI3:bLogicLen:={||Len(aQI3)}
		    nPosQI3 := 1
	ElseIf nRelac == 2 .And. nCadPsq == 2
			FQNC060QI2(@aQI2,aQI3,.F.,.F.,nRelac,nPosQI3,aFiltro1)
			FQNC060IND(@aQI2,aOrdem1,1)
			oQI2:aArray:=aQI2
			oQI2:bLogicLen:={||Len(aQI2)}
			oQI2:nAt:=1
	Endif

	QNC060CARR(@aQI2,@aQI3,@aQI5,.F.,.F.,.T.,nPosQI3,aFiltro1,aFiltro2,aFiltro3)
	oQI5:aArray:=aQI5
	oQI5:bLogicLen:={||Len(aQI5)}

	oQI2:Refresh(.T.)
	oQI3:Refresh(.T.)
	oQI5:Refresh(.T.)

Endif

Return

//----------------------------------------------------------------------
/*/{Protheus.doc} Q060GetSX3 
Busca dados da SX3 
@author Brunno de Medeiros da Costa
@since 17/04/2018
@version 1.0
@return aHeaderTmp
/*/
//---------------------------------------------------------------------- 
Static Function Q060GetSX3(cCampo)
Local aHeaderTmp := {}              
aHeaderTmp := {OemtoAnsi(IF(GetSx3Cache(cCampo,'X3_TIPO') == "M","*","")+TRIM(QAGetX3Tit(cCampo))),;
		      {cCampo,;
		      	QAGetX3Tit(cCampo),;
		      	.T.,;
		      	GetSx3Cache(cCampo,'X3_ORDEM'),;
		      	GetSx3Cache(cCampo,'X3_TAMANHO'),;
		        If(Empty(GetSx3Cache(cCampo,'X3_PICTURE')),Space(45),GetSx3Cache(cCampo,'X3_PICTURE')),;
		        GetSx3Cache(cCampo,'X3_TIPO'),;
		        GetSx3Cache(cCampo,'X3_DECIMAL'),;
		        GetSx3Cache(cCampo,'X3_RELACAO') }}
Return aHeaderTmp
