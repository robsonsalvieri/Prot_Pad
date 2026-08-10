#INCLUDE "Protheus.ch"

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    | UpdDCM01 ³ Autor ³Vendas e CRM           ³ Data ³ 30.04.12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualizacao de X3 e X1 Template DCM       				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Template DCM 		                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function UpdDCM01()

Local bHist      := {|| MsgYesNo("Deseja efetuar a atualização dos dicionários? Esta rotina deve ser utilizada em modo exclusivo. "+;
                                 "Faça um backup dos dicionários e da base de dados antes de prosseguir com esta atualização.",;
                                 "Atenção")}
Local lHistorico	:= .T.
					    
cArqEmp := "SigaMat.Emp"
__cInterNet := Nil

PRIVATE cMessage
PRIVATE aArqUpd	 := {}
PRIVATE aREOPEN	 := {}
PRIVATE oMainWnd 

Set Dele On

lEmpenho	:= .F.
lAtuMnu	:= .F.

//
oMainWnd := MsDialog():New(0/*[nTop]*/, 0 /*[nLeft]*/, 600 /*[nBottom]*/, 800 /*[nRight]*/,;
                           "Atualização dos dicionários" /*[cCaption]*/,;
                           /*[uParam6]*/, /*[uParam7]*/, /*[uParam8]*/, /*[uParam9]*/, /*[nClrText]*/,;
                           /*[nClrBack]*/, /*[uParam12]*/, /*[oWnd]*/, .T./*[lPixel]*/, /*[uParam15]*/,;
                           /*[uParam16]*/, /*[uParam17]*/, /*[lTransparent]*/)
oMainWnd:bInit := {|| oMainWnd:nHeight := 600,;
                      oMainWnd:nWidth := 800,;
                      oMainWnd:Center(.T.),;
                      if(lHistorico := Eval(bHist), (oProcess:Activate(), Final("Atualização efetuada.")), Final("Atualização cancelada.")),;
                      oMainWnd:End()}
oProcess := MsNewProcess():New({|lEnd| Processa({|lEnd| GraProc(@lEnd)}, "Processando", "Aguarde, processando preparação dos arquivos", .F.),;
                                       Final("Atualização efetuada!")})
oMainWnd:Activate()
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ GRAProc  ³ Autor ³Ricardo Berti          ³ Data ³ 18.02.09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao de processamento da gravacao dos arquivos           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Atualizacao COL_GRA                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function GRAProc(lEnd)
Local cTexto    := ''
Local cFile     := ""
Local cMask     := "Arquivos Texto (*.TXT) |*.txt|"
Local nRecno    := 0
Local nI        := 0
Local nX        := 0
Local aRecnoSM0 := {}     
Local lOpen     := .F. 

ProcRegua(1)
IncProc("Verificando integridade dos dicionários....")
If ( lOpen := MyOpenSm0Ex() )

	dbSelectArea("SM0")
	dbGotop()
	While !Eof() 
  		If Ascan(aRecnoSM0,{ |x| x[2] == M0_CODIGO}) == 0 //--So adiciona no aRecnoSM0 se a empresa for diferente
			Aadd(aRecnoSM0,{Recno(),M0_CODIGO})
		EndIf			
		dbSkip()
	EndDo	
		
	If lOpen
		For nI := 1 To Len(aRecnoSM0)
			SM0->(dbGoto(aRecnoSM0[nI,1]))
			RpcSetType(2) 
			RpcSetEnv(SM0->M0_CODIGO, SM0->M0_CODFIL)
			nModulo := 12 // MODULO COMPRAS    // -> 2 -> 12 -> Modulo Loja

			lMsFinalAuto := .F.
			cTexto += Replicate("-",128)+CHR(13)+CHR(10)
			cTexto += "Empresa : "+SM0->M0_CODIGO+SM0->M0_NOME+CHR(13)+CHR(10)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Atualiza o dicionario de dados (SX3) ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			IncProc("Analisando Dicionario de Dados...")
			cTexto += GRAAtuSX3()

			__SetX31Mode(.F.)
			For nX := 1 To Len(aArqUpd)
				IncProc("Atualizando estruturas. Aguarde... ["+aArqUpd[nx]+"]")
				If Select(aArqUpd[nx])>0
					dbSelecTArea(aArqUpd[nx])
					dbCloseArea()
				EndIf
				X31UpdTable(aArqUpd[nx])
				If __GetX31Error()
					Alert(__GetX31Trace())
					Aviso("Atenção!","Ocorreu um erro desconhecido durante a atualização da tabela : "+ aArqUpd[nx] + ". Verifique a integridade do dicionário e da tabela.",{"Continuar"},2)
					cTexto += "Ocorreu um erro desconhecido durante a atualização da estrutura da tabela : "+aArqUpd[nx] +CHR(13)+CHR(10)
				EndIf
			Next nX		
			RpcClearEnv()
			If !( lOpen := MyOpenSm0Ex() )
				Exit 
			EndIf 

		Next nI 
		   
		If lOpen
			
			cTexto     := "Log da atualização "+CHR(13)+CHR(10)+cTexto
			__cFileLog := MemoWrite(Criatrab(,.f.)+".LOG",cTexto)
			DEFINE FONT oFont NAME "Mono AS" SIZE 5,12   //6,15
			DEFINE MSDIALOG oDlg TITLE "Atualização concluída." From 3,0 to 340,417 PIXEL
			@ 5,5 GET oMemo  VAR cTexto MEMO SIZE 200,145 OF oDlg PIXEL
			oMemo:bRClicked := {||AllwaysTrue()}
			oMemo:oFont     := oFont
			DEFINE SBUTTON  FROM 153,175 TYPE 1 ACTION oDlg:End() ENABLE OF oDlg PIXEL //Apaga
			DEFINE SBUTTON  FROM 153,145 TYPE 13 ACTION (cFile:=cGetFile(cMask,""),If(cFile="",.t.,MemoWrite(cFile,cTexto))) ENABLE OF oDlg PIXEL //Salva e Apaga //"Salvar Como..."
			ACTIVATE MSDIALOG oDlg CENTER

			lEnd	:= .T.
		EndIf 
		
	EndIf
Else
	lEnd	:= .F.
EndIf 	

Return(.T.)


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³GRAAtuSX3 ³ Autor ³Ricardo Berti          ³ Data ³ 18.02.09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao de processamento da gravacao do SX3 - Campos        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Atualizacao COL_GRA                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function GRAAtuSX3()
Local aEstrut        := {}
Local aSX3           := {}
Local cTexto         := ''
Local cAlias         := ''
Local i              := 0
Local j              := 0

aEstrut:= {"X3_ARQUIVO","X3_ORDEM"  ,"X3_CAMPO"  ,"X3_TIPO"   ,"X3_TAMANHO","X3_DECIMAL","X3_TITULO" ,"X3_TITSPA" ,"X3_TITENG" ,;
           "X3_DESCRIC","X3_DESCSPA","X3_DESCENG","X3_PICTURE","X3_VALID"  ,"X3_USADO"  ,"X3_RELACAO","X3_F3"     ,"X3_NIVEL"  ,;
           "X3_RESERV" ,"X3_CHECK"  ,"X3_TRIGGER","X3_PROPRI" ,"X3_BROWSE" ,"X3_VISUAL" ,"X3_CONTEXT","X3_OBRIGAT","X3_VLDUSER",;
           "X3_CBOX"   ,"X3_CBOXSPA","X3_CBOXENG","X3_PICTVAR","X3_WHEN"   ,"X3_INIBRW" ,"X3_GRPSXG" ,"X3_FOLDER", "X3_PYME"}

/*
//--Pesquisa um campo existente para gravar o Reserv e o Usado
	If SX3->(MsSeek("LJX_NFSAID")) //Este campo e obrigatorio e permite alterar
		For nI := 1 To SX3->(FCount())
			If "X3_RESERV" $ SX3->(FieldName(nI))
				cReservObrig := SX3->(FieldGet(FieldPos(FieldName(nI))))
			EndIf
			If "X3_USADO"  $ SX3->(FieldName(nI))
				cUsadoObrig  := SX3->(FieldGet(FieldPos(FieldName(nI))))
			EndIf
		Next 							
	EndIf		
*/

//Atualização de campos do Template ref. ao grupo de campos

dbSelectArea("SXG")
dbSelectArea("SX3")
SX3->(DbSetOrder(2))	

If SXG->(dbSeek("001"))

	//Chama atualizacao do X1 para cliente/fornecedor:
	DCMSX1("001",SXG->XG_SIZE)
	
	If SX3->(dbSeek("LH7_CODF")) .And. (SX3->X3_GRPSXG <> "001" .Or. SX3->X3_TAMANHO <> SXG->XG_SIZE)
		RecLock("SX3")
		Replace X3_GRPSXG WITH "001"
		If SX3->X3_TAMANHO <> SXG->XG_SIZE
			Replace X3_TAMANHO WITH SXG->XG_SIZE                      
		  	If Ascan(aSX3,{ |x| x[1] == "LH7"}) == 0
				Aadd(aSX3,{"LH7"})
	  		EndIf
		EndIf
		dbCommit()
		MSUnlock()        
   	EndIf
	
	
	If SX3->(dbSeek("LH2_CLIENT")) .And. (SX3->X3_GRPSXG <> "001" .Or. SX3->X3_TAMANHO <> SXG->XG_SIZE)
		RecLock("SX3")
		Replace X3_GRPSXG WITH "001"
		If SX3->X3_TAMANHO <> SXG->XG_SIZE
			Replace X3_TAMANHO WITH SXG->XG_SIZE                      
		  	If Ascan(aSX3,{ |x| x[1] == "LH2"}) == 0
				Aadd(aSX3,{"LH2"})
	  		EndIf
		EndIf
		dbCommit()
		MSUnlock()        
   	EndIf
	
	
	If SX3->(dbSeek("LH1_CODCLI")) .And. (SX3->X3_GRPSXG <> "001" .Or. SX3->X3_TAMANHO <> SXG->XG_SIZE)
		RecLock("SX3")
		Replace X3_GRPSXG WITH "001"
		If SX3->X3_TAMANHO <> SXG->XG_SIZE
			Replace X3_TAMANHO WITH SXG->XG_SIZE                      
		  	If Ascan(aSX3,{ |x| x[1] == "LH1"}) == 0
				Aadd(aSX3,{"LH1"})
	  		EndIf
		EndIf
		dbCommit()
		MSUnlock()        
   	EndIf
	
	
	If SX3->(dbSeek("LH4_CLIENT")) .And. (SX3->X3_GRPSXG <> "001" .Or. SX3->X3_TAMANHO <> SXG->XG_SIZE)
		RecLock("SX3")
		Replace X3_GRPSXG WITH "001"
		If SX3->X3_TAMANHO <> SXG->XG_SIZE
			Replace X3_TAMANHO WITH SXG->XG_SIZE                      
		  	If Ascan(aSX3,{ |x| x[1] == "LH4"}) == 0
				Aadd(aSX3,{"LH4"})
	  		EndIf
		EndIf
		dbCommit()
		MSUnlock()        
   	EndIf
	
	
	If SX3->(dbSeek("LHA_CODCLI")) .And. (SX3->X3_GRPSXG <> "001" .Or. SX3->X3_TAMANHO <> SXG->XG_SIZE)
		RecLock("SX3")
		Replace X3_GRPSXG WITH "001"
		If SX3->X3_TAMANHO <> SXG->XG_SIZE
			Replace X3_TAMANHO WITH SXG->XG_SIZE                      
		  	If Ascan(aSX3,{ |x| x[1] == "LHA"}) == 0
				Aadd(aSX3,{"LHA"})
	  		EndIf
		EndIf
		dbCommit()
		MSUnlock()        
   	EndIf
	
	
	If SX3->(dbSeek("LH6_CLIENT")) .And. (SX3->X3_GRPSXG <> "001" .Or. SX3->X3_TAMANHO <> SXG->XG_SIZE)
		RecLock("SX3")
		Replace X3_GRPSXG WITH "001"
		If SX3->X3_TAMANHO <> SXG->XG_SIZE
			Replace X3_TAMANHO WITH SXG->XG_SIZE                      
		  	If Ascan(aSX3,{ |x| x[1] == "LH6"}) == 0
				Aadd(aSX3,{"LH6"})
	  		EndIf
		EndIf
		dbCommit()
		MSUnlock()        
   	EndIf
	
	
	If SX3->(dbSeek("UA_CLIENTE")) .And. (SX3->X3_GRPSXG <> "001" .Or. SX3->X3_TAMANHO <> SXG->XG_SIZE)
		RecLock("SX3")
		Replace X3_GRPSXG WITH "001"
		If SX3->X3_TAMANHO <> SXG->XG_SIZE
			Replace X3_TAMANHO WITH SXG->XG_SIZE                      
		  	If Ascan(aSX3,{ |x| x[1] == "SUA"}) == 0
				Aadd(aSX3,{"SUA"})
	  		EndIf
		EndIf
		dbCommit()
		MSUnlock()        
   	EndIf
	
	
	If SX3->(dbSeek("LH5_CLIENT")) .And. (SX3->X3_GRPSXG <> "001" .Or. SX3->X3_TAMANHO <> SXG->XG_SIZE)
		RecLock("SX3")
		Replace X3_GRPSXG WITH "001"
		If SX3->X3_TAMANHO <> SXG->XG_SIZE
			Replace X3_TAMANHO WITH SXG->XG_SIZE                      
		  	If Ascan(aSX3,{ |x| x[1] == "LH5"}) == 0
				Aadd(aSX3,{"LH5"})
	  		EndIf
		EndIf
		dbCommit()
		MSUnlock()        
   	EndIf
	
	If SX3->(dbSeek("LH6_SOCIO")) .And. (SX3->X3_GRPSXG <> "001" .Or. SX3->X3_TAMANHO <> SXG->XG_SIZE)
		RecLock("SX3")
		Replace X3_GRPSXG WITH "001"
		If SX3->X3_TAMANHO <> SXG->XG_SIZE
			Replace X3_TAMANHO WITH SXG->XG_SIZE                      
		  	If Ascan(aSX3,{ |x| x[1] == "LH6"}) == 0
				Aadd(aSX3,{"LH6"})
	  		EndIf
		EndIf
		dbCommit()
		MSUnlock()        
   	EndIf

	If SX3->(dbSeek("LHA_CLIENT")) .And. (SX3->X3_GRPSXG <> "001" .Or. SX3->X3_TAMANHO <> SXG->XG_SIZE)
		RecLock("SX3")
		Replace X3_GRPSXG WITH "001"
		If SX3->X3_TAMANHO <> SXG->XG_SIZE
			Replace X3_TAMANHO WITH SXG->XG_SIZE                      
		  	If Ascan(aSX3,{ |x| x[1] == "LHA"}) == 0
				Aadd(aSX3,{"LHA"})
	  		EndIf
		EndIf
		dbCommit()
		MSUnlock()        
   	EndIf

	If SX3->(dbSeek("LH0_CLIENT")) .And. (SX3->X3_GRPSXG <> "001" .Or. SX3->X3_TAMANHO <> SXG->XG_SIZE)
		RecLock("SX3")
		Replace X3_GRPSXG WITH "001"
		If SX3->X3_TAMANHO <> SXG->XG_SIZE
			Replace X3_TAMANHO WITH SXG->XG_SIZE                      
		  	If Ascan(aSX3,{ |x| x[1] == "LH0"}) == 0
				Aadd(aSX3,{"LH0"})
	  		EndIf
		EndIf
		dbCommit()
		MSUnlock()        
   	EndIf

		
EndIF

If SXG->(dbSeek("002"))

	//Chama atualizacao do X1 para loja:
	DCMSX1("002",SXG->XG_SIZE)
	
	If SX3->(dbSeek("LH7_LOJA")) .And. (SX3->X3_GRPSXG <> "002" .Or. SX3->X3_TAMANHO <> SXG->XG_SIZE)
		RecLock("SX3")
		Replace X3_GRPSXG WITH "002"
		If SX3->X3_TAMANHO <> SXG->XG_SIZE
			Replace X3_TAMANHO WITH SXG->XG_SIZE
		  	If Ascan(aSX3,{ |x| x[1] == "LH7"}) == 0
				Aadd(aSX3,{"LH7"})
	  		EndIf
		EndIf
		dbCommit()
		MSUnlock()        
	EndIf
	
	If SX3->(dbSeek("LH4_LOJA")) .And. (SX3->X3_GRPSXG <> "002" .Or. SX3->X3_TAMANHO <> SXG->XG_SIZE)
		RecLock("SX3")
		Replace X3_GRPSXG WITH "002"
		If SX3->X3_TAMANHO <> SXG->XG_SIZE
			Replace X3_TAMANHO WITH SXG->XG_SIZE
		  	If Ascan(aSX3,{ |x| x[1] == "LH4"}) == 0
				Aadd(aSX3,{"LH4"})
	  		EndIf
		EndIf
		dbCommit()
		MSUnlock()        
	EndIf
	
	If SX3->(dbSeek("LH2_CLILOJ")) .And. (SX3->X3_GRPSXG <> "002" .Or. SX3->X3_TAMANHO <> SXG->XG_SIZE)
		RecLock("SX3")
		Replace X3_GRPSXG WITH "002"
		If SX3->X3_TAMANHO <> SXG->XG_SIZE
			Replace X3_TAMANHO WITH SXG->XG_SIZE
		  	If Ascan(aSX3,{ |x| x[1] == "LH2"}) == 0
				Aadd(aSX3,{"LH2"})
	  		EndIf
		EndIf
		dbCommit()
		MSUnlock()        
	EndIf
	
	If SX3->(dbSeek("LHA_LOJA")) .And. (SX3->X3_GRPSXG <> "002" .Or. SX3->X3_TAMANHO <> SXG->XG_SIZE)
		RecLock("SX3")
		Replace X3_GRPSXG WITH "002"
		If SX3->X3_TAMANHO <> SXG->XG_SIZE
			Replace X3_TAMANHO WITH SXG->XG_SIZE
		  	If Ascan(aSX3,{ |x| x[1] == "LHA"}) == 0
				Aadd(aSX3,{"LHA"})
	  		EndIf
		EndIf
		dbCommit()
		MSUnlock()        
	EndIf
	
	If SX3->(dbSeek("LH6_LOJA")) .And. (SX3->X3_GRPSXG <> "002" .Or. SX3->X3_TAMANHO <> SXG->XG_SIZE)
		RecLock("SX3")
		Replace X3_GRPSXG WITH "002"
		If SX3->X3_TAMANHO <> SXG->XG_SIZE
			Replace X3_TAMANHO WITH SXG->XG_SIZE
		  	If Ascan(aSX3,{ |x| x[1] == "LH6"}) == 0
				Aadd(aSX3,{"LH6"})
	  		EndIf
		EndIf
		dbCommit()
		MSUnlock()        
	EndIf
	
	If SX3->(dbSeek("UA_LOJA")) .And. (SX3->X3_GRPSXG <> "002" .Or. SX3->X3_TAMANHO <> SXG->XG_SIZE)
		RecLock("SX3")
		Replace X3_GRPSXG WITH "002"
		If SX3->X3_TAMANHO <> SXG->XG_SIZE
			Replace X3_TAMANHO WITH SXG->XG_SIZE
		  	If Ascan(aSX3,{ |x| x[1] == "SUA"}) == 0
				Aadd(aSX3,{"SUA"})
	  		EndIf
		EndIf
		dbCommit()
		MSUnlock()        
	EndIf
	
	If SX3->(dbSeek("LFW_LOJA")) .And. (SX3->X3_GRPSXG <> "002" .Or. SX3->X3_TAMANHO <> SXG->XG_SIZE)
		RecLock("SX3")
		Replace X3_GRPSXG WITH "002"
		If SX3->X3_TAMANHO <> SXG->XG_SIZE
			Replace X3_TAMANHO WITH SXG->XG_SIZE
		  	If Ascan(aSX3,{ |x| x[1] == "LFW"}) == 0
				Aadd(aSX3,{"LFW"})
	  		EndIf
		EndIf
		dbCommit()
		MSUnlock()        
	EndIf
	
	If SX3->(dbSeek("LH0_LOJA")) .And. (SX3->X3_GRPSXG <> "002" .Or. SX3->X3_TAMANHO <> SXG->XG_SIZE)
		RecLock("SX3")
		Replace X3_GRPSXG WITH "002"
		If SX3->X3_TAMANHO <> SXG->XG_SIZE
			Replace X3_TAMANHO WITH SXG->XG_SIZE
		  	If Ascan(aSX3,{ |x| x[1] == "LH0"}) == 0
				Aadd(aSX3,{"LH0"})
	  		EndIf
		EndIf
		dbCommit()
		MSUnlock()        
	EndIf
	
	If SX3->(dbSeek("C9_LOJAFOR")) .And. (SX3->X3_GRPSXG <> "002" .Or. SX3->X3_TAMANHO <> SXG->XG_SIZE)
		RecLock("SX3")
		Replace X3_GRPSXG WITH "002"
		If SX3->X3_TAMANHO <> SXG->XG_SIZE
			Replace X3_TAMANHO WITH SXG->XG_SIZE
		  	If Ascan(aSX3,{ |x| x[1] == "SC9"}) == 0
				Aadd(aSX3,{"SC9"})
	  		EndIf
		EndIf
		dbCommit()
		MSUnlock()        
	EndIf
	
	If SX3->(dbSeek("LH6_LOJASO")) .And. (SX3->X3_GRPSXG <> "002" .Or. SX3->X3_TAMANHO <> SXG->XG_SIZE)
		RecLock("SX3")
		Replace X3_GRPSXG WITH "002"
		If SX3->X3_TAMANHO <> SXG->XG_SIZE
			Replace X3_TAMANHO WITH SXG->XG_SIZE
		  	If Ascan(aSX3,{ |x| x[1] == "LH6"}) == 0
				Aadd(aSX3,{"LH6"})
	  		EndIf
		EndIf
		dbCommit()
		MSUnlock()        
	EndIf
	
		
EndIf
	
If SXG->(dbSeek("030"))
                  
	//Chama atualizacao do X1 para produto:
	DCMSX1("030",SXG->XG_SIZE)
	
	If SX3->(dbSeek("LH5_PRODUT")) .And. (SX3->X3_GRPSXG <> "030" .Or. SX3->X3_TAMANHO <> SXG->XG_SIZE)
		RecLock("SX3")
		Replace X3_GRPSXG WITH "030"
		If SX3->X3_TAMANHO <> SXG->XG_SIZE
			Replace X3_TAMANHO WITH SXG->XG_SIZE
		  	If Ascan(aSX3,{ |x| x[1] == "LH5"}) == 0
				Aadd(aSX3,{"LH5"})
	  		EndIf
		EndIf
		dbCommit()
		MSUnlock()        
	EndIf
	If SX3->(dbSeek("LH7_COD")) .And. (SX3->X3_GRPSXG <> "030" .Or. SX3->X3_TAMANHO <> SXG->XG_SIZE)
		RecLock("SX3")
		Replace X3_GRPSXG WITH "030"
		If SX3->X3_TAMANHO <> SXG->XG_SIZE
			Replace X3_TAMANHO WITH SXG->XG_SIZE
		 	If Ascan(aSX3,{ |x| x[1] == "LH7"}) == 0
				Aadd(aSX3,{"LH7"})
	  		EndIf
		EndIf
		dbCommit()
		MSUnlock()        
	EndIf
	If SX3->(dbSeek("LFW_PRODUT")) .And. (SX3->X3_GRPSXG <> "030" .Or. SX3->X3_TAMANHO <> SXG->XG_SIZE)
		RecLock("SX3")
		Replace X3_GRPSXG WITH "030"
		If SX3->X3_TAMANHO <> SXG->XG_SIZE
			Replace X3_TAMANHO WITH SXG->XG_SIZE
		  	If Ascan(aSX3,{ |x| x[1] == "LFW"}) == 0
				Aadd(aSX3,{"LFW"})
	  		EndIf
		EndIf
		dbCommit()
		MSUnlock()        
	EndIf
	If SX3->(dbSeek("LHA_PRODUT")) .And. (SX3->X3_GRPSXG <> "030" .Or. SX3->X3_TAMANHO <> SXG->XG_SIZE)
		RecLock("SX3")
		Replace X3_GRPSXG WITH "030"
		If SX3->X3_TAMANHO <> SXG->XG_SIZE
			Replace X3_TAMANHO WITH SXG->XG_SIZE
		  	If Ascan(aSX3,{ |x| x[1] == "LHA"}) == 0
				Aadd(aSX3,{"LHA"})
	  		EndIf
		EndIf
		dbCommit()
		MSUnlock()        
	EndIf
	If SX3->(dbSeek("LH1_PRODUT")) .And. (SX3->X3_GRPSXG <> "030" .Or. SX3->X3_TAMANHO <> SXG->XG_SIZE)
		RecLock("SX3")
		Replace X3_GRPSXG WITH "030"
		If SX3->X3_TAMANHO <> SXG->XG_SIZE
			Replace X3_TAMANHO WITH SXG->XG_SIZE
		  	If Ascan(aSX3,{ |x| x[1] == "LH1"}) == 0
				Aadd(aSX3,{"LH1"})
	  		EndIf
		EndIf
		dbCommit()
		MSUnlock()        
	EndIf
	If SX3->(dbSeek("LH5_CODCLI")) .And. (SX3->X3_GRPSXG <> "030" .Or. SX3->X3_TAMANHO <> SXG->XG_SIZE)
		RecLock("SX3")
		Replace X3_GRPSXG WITH "030"
		If SX3->X3_TAMANHO <> SXG->XG_SIZE
			Replace X3_TAMANHO WITH SXG->XG_SIZE
		  	If Ascan(aSX3,{ |x| x[1] == "LH5"}) == 0
				Aadd(aSX3,{"LH5"})
	  		EndIf
		EndIf
		dbCommit()
		MSUnlock()        
	EndIf
	
EndIf
 

If SXG->(dbSeek("033"))
     
	If SX3->(dbSeek("LH8_FILIAL")) .And. (SX3->X3_GRPSXG <> "033" .Or. SX3->X3_TAMANHO <> SXG->XG_SIZE)
		RecLock("SX3")
		Replace X3_GRPSXG WITH "033"
		If SX3->X3_TAMANHO <> SXG->XG_SIZE
			Replace X3_TAMANHO WITH SXG->XG_SIZE
		  	If Ascan(aSX3,{ |x| x[1] == "LH8"}) == 0
				Aadd(aSX3,{"LH8"})
	  		EndIf
		EndIf
		dbCommit()
		MSUnlock()        
	EndIf 
	
	If SX3->(dbSeek("LH9_FILIAL")) .And. (SX3->X3_GRPSXG <> "033" .Or. SX3->X3_TAMANHO <> SXG->XG_SIZE)
		RecLock("SX3")
		Replace X3_GRPSXG WITH "033"
		If SX3->X3_TAMANHO <> SXG->XG_SIZE
			Replace X3_TAMANHO WITH SXG->XG_SIZE
		  	If Ascan(aSX3,{ |x| x[1] == "LH9"}) == 0
				Aadd(aSX3,{"LH9"})
	  		EndIf
		EndIf
		dbCommit()
		MSUnlock()        
	EndIf
	If SX3->(dbSeek("LH4_FILIAL")) .And. (SX3->X3_GRPSXG <> "033" .Or. SX3->X3_TAMANHO <> SXG->XG_SIZE)
		RecLock("SX3")
		Replace X3_GRPSXG WITH "033"
		If SX3->X3_TAMANHO <> SXG->XG_SIZE
			Replace X3_TAMANHO WITH SXG->XG_SIZE
		  	If Ascan(aSX3,{ |x| x[1] == "LH4"}) == 0
				Aadd(aSX3,{"LH4"})
	  		EndIf
		EndIf
		dbCommit()
		MSUnlock()        
	EndIf
	If SX3->(dbSeek("LH6_FILIAL")) .And. (SX3->X3_GRPSXG <> "033" .Or. SX3->X3_TAMANHO <> SXG->XG_SIZE)
		RecLock("SX3")
		Replace X3_GRPSXG WITH "033"
		If SX3->X3_TAMANHO <> SXG->XG_SIZE
			Replace X3_TAMANHO WITH SXG->XG_SIZE
		  	If Ascan(aSX3,{ |x| x[1] == "LH6"}) == 0
				Aadd(aSX3,{"LH6"})
	  		EndIf
		EndIf
		dbCommit()
		MSUnlock()        
	EndIf
	If SX3->(dbSeek("LH7_FILIAL")) .And. (SX3->X3_GRPSXG <> "033" .Or. SX3->X3_TAMANHO <> SXG->XG_SIZE)
		RecLock("SX3")
		Replace X3_GRPSXG WITH "033"
		If SX3->X3_TAMANHO <> SXG->XG_SIZE
			Replace X3_TAMANHO WITH SXG->XG_SIZE
		  	If Ascan(aSX3,{ |x| x[1] == "LH7"}) == 0
				Aadd(aSX3,{"LH7"})
	  		EndIf
		EndIf
		dbCommit()
		MSUnlock()        
	EndIf
	If SX3->(dbSeek("LH3_FILIAL")) .And. (SX3->X3_GRPSXG <> "033" .Or. SX3->X3_TAMANHO <> SXG->XG_SIZE)
		RecLock("SX3")
		Replace X3_GRPSXG WITH "033"
		If SX3->X3_TAMANHO <> SXG->XG_SIZE
			Replace X3_TAMANHO WITH SXG->XG_SIZE
		  	If Ascan(aSX3,{ |x| x[1] == "LH3"}) == 0
				Aadd(aSX3,{"LH3"})
	  		EndIf
		EndIf
		dbCommit()
		MSUnlock()        
	EndIf
	If SX3->(dbSeek("LFW_FILIAL")) .And. (SX3->X3_GRPSXG <> "033" .Or. SX3->X3_TAMANHO <> SXG->XG_SIZE)
		RecLock("SX3")
		Replace X3_GRPSXG WITH "033"
		If SX3->X3_TAMANHO <> SXG->XG_SIZE
			Replace X3_TAMANHO WITH SXG->XG_SIZE
		  	If Ascan(aSX3,{ |x| x[1] == "LFW"}) == 0
				Aadd(aSX3,{"LFW"})
	  		EndIf
		EndIf
		dbCommit()
		MSUnlock()        
	EndIf
	If SX3->(dbSeek("LXB_FILIAL")) .And. (SX3->X3_GRPSXG <> "033" .Or. SX3->X3_TAMANHO <> SXG->XG_SIZE)
		RecLock("SX3")
		Replace X3_GRPSXG WITH "033"
		If SX3->X3_TAMANHO <> SXG->XG_SIZE
			Replace X3_TAMANHO WITH SXG->XG_SIZE
		  	If Ascan(aSX3,{ |x| x[1] == "LXB"}) == 0
				Aadd(aSX3,{"LXB"})
	  		EndIf
		EndIf
		dbCommit()
		MSUnlock()        
	EndIf   
	
	If SX3->(dbSeek("LH0_FILIAL")) .And. (SX3->X3_GRPSXG <> "033" .Or. SX3->X3_TAMANHO <> SXG->XG_SIZE)
		RecLock("SX3")
		Replace X3_GRPSXG WITH "033"
		If SX3->X3_TAMANHO <> SXG->XG_SIZE
			Replace X3_TAMANHO WITH SXG->XG_SIZE
		  	If Ascan(aSX3,{ |x| x[1] == "LH0"}) == 0
				Aadd(aSX3,{"LH0"})
	  		EndIf
		EndIf
		dbCommit()
		MSUnlock()        
	EndIf   
	
	If SX3->(dbSeek("LH1_FILIAL")) .And. (SX3->X3_GRPSXG <> "033" .Or. SX3->X3_TAMANHO <> SXG->XG_SIZE)
		RecLock("SX3")
		Replace X3_GRPSXG WITH "033"
		If SX3->X3_TAMANHO <> SXG->XG_SIZE
			Replace X3_TAMANHO WITH SXG->XG_SIZE
		  	If Ascan(aSX3,{ |x| x[1] == "LH1"}) == 0
				Aadd(aSX3,{"LH1"})
	  		EndIf
		EndIf
		dbCommit()
		MSUnlock()        
	EndIf   
	
	If SX3->(dbSeek("LH2_FILIAL")) .And. (SX3->X3_GRPSXG <> "033" .Or. SX3->X3_TAMANHO <> SXG->XG_SIZE)
		RecLock("SX3")
		Replace X3_GRPSXG WITH "033"
		If SX3->X3_TAMANHO <> SXG->XG_SIZE
			Replace X3_TAMANHO WITH SXG->XG_SIZE
		  	If Ascan(aSX3,{ |x| x[1] == "LH2"}) == 0
				Aadd(aSX3,{"LH2"})
	  		EndIf
		EndIf
		dbCommit()
		MSUnlock()        
	EndIf   
	
	If SX3->(dbSeek("LH5_FILIAL")) .And. (SX3->X3_GRPSXG <> "033" .Or. SX3->X3_TAMANHO <> SXG->XG_SIZE)
		RecLock("SX3")
		Replace X3_GRPSXG WITH "033"
		If SX3->X3_TAMANHO <> SXG->XG_SIZE
			Replace X3_TAMANHO WITH SXG->XG_SIZE
		  	If Ascan(aSX3,{ |x| x[1] == "LH5"}) == 0
				Aadd(aSX3,{"LH5"})
	  		EndIf
		EndIf
		dbCommit()
		MSUnlock()        
	EndIf   
	
	If SX3->(dbSeek("LHA_FILIAL")) .And. (SX3->X3_GRPSXG <> "033" .Or. SX3->X3_TAMANHO <> SXG->XG_SIZE)
		RecLock("SX3")
		Replace X3_GRPSXG WITH "033"
		If SX3->X3_TAMANHO <> SXG->XG_SIZE
			Replace X3_TAMANHO WITH SXG->XG_SIZE
		  	If Ascan(aSX3,{ |x| x[1] == "LHA"}) == 0
				Aadd(aSX3,{"LHA"})
	  		EndIf
		EndIf
		dbCommit()
		MSUnlock()        
	EndIf   
	
	If SX3->(dbSeek("LX5_FILIAL")) .And. (SX3->X3_GRPSXG <> "033" .Or. SX3->X3_TAMANHO <> SXG->XG_SIZE)
		RecLock("SX3")
		Replace X3_GRPSXG WITH "033"
		If SX3->X3_TAMANHO <> SXG->XG_SIZE
			Replace X3_TAMANHO WITH SXG->XG_SIZE
		  	If Ascan(aSX3,{ |x| x[1] == "LX5"}) == 0
				Aadd(aSX3,{"LX5"})
	  		EndIf
		EndIf
		dbCommit()
		MSUnlock()        
	EndIf   

EndIf

If SXG->(dbSeek("033"))
	//Chama atualizacao do X1 para Filial
	DCMSX1("033",SXG->XG_SIZE)
EndIf

If SXG->(dbSeek("018"))
	//Chama atualizacao do X1 para Doc Ent/Sai:
	DCMSX1("018",SXG->XG_SIZE)
EndIf

ProcRegua(Len(aSX3))

SX3->(DbSetOrder(2))	
For i:= 1 To Len(aSX3)
	If !Empty(aSX3[i][1])
		If !(aSX3[i,1]$cAlias)
			cAlias += aSX3[i,1]+"/"
			aAdd(aArqUpd,aSX3[i,1])
		EndIf
	EndIf
Next i

If Len(aSX3) > 0
	cTexto := 'Foram alterados os dicionarios das seguintes tabelas : '+cAlias+CHR(13)+CHR(10)
EndIf

Return cTexto



/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MyOpenSM0Ex³ Autor ³Microsiga             ³ Data ³07/01/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Efetua a abertura do SM0 exclusivo                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Atualizacao FIS                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function MyOpenSM0Ex()

Local lOpen := .F. 
Local nLoop := 0 

For nLoop := 1 To 20
	dbUseArea( .T.,, "SIGAMAT.EMP", "SM0", .F., .F. ) 
	If !Empty( Select( "SM0" ) ) 
		lOpen := .T. 
		dbSetIndex("SIGAMAT.IND") 
		Exit	
	EndIf
	Sleep( 500 ) 
Next nLoop 

If !lOpen
	Aviso( "Atencao !", "Nao foi possivel a abertura da tabela de empresas de forma exclusiva !", { "Ok" }, 2 ) 
EndIf                                 

Return( lOpen ) 
 
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    |DCMSX1 	 | Autor ³Microsiga             ³ Data ³11/11/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Atualiza SX1						                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Atualizacao FIS                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function DCMSX1(cGrpSXG,nTamCampo)

Local nTamSX1 	:= 0
Local aArea 	:= GetArea()

If !Empty(nTamCampo)
	DBSelectArea("SX1")
	DBSetOrder(1)
	nTamSX1 := Len(SX1->X1_GRUPO)

	If cGrpSXG = '033' //grupo de campo -> Filial
		If DBSeek(PADR("TFAT05",nTamSX1)+"07")
			RecLock("SX1",.F.)
			Replace X1_TAMANHO with nTamCampo
			Replace X1_GRPSXG  with "033"
			MsUnLock()
		EndIf
		If DBSeek(PADR("TFAT05",nTamSX1)+"08")
			RecLock("SX1",.F.)
			Replace X1_TAMANHO with nTamCampo
			Replace X1_GRPSXG  with "033"
			MsUnLock()
		EndIf
		If DBSeek(PADR("TFAT06",nTamSX1)+"06")
			RecLock("SX1",.F.)
			Replace X1_TAMANHO with nTamCampo
			Replace X1_GRPSXG  with "033"
			MsUnLock()
		EndIf
	EndIf

	If cGrpSXG = '030' //grupo de campo -> produto
		If DBSeek(PADR("TFATR1",nTamSX1)+"03")
			RecLock("SX1",.F.)
			Replace X1_TAMANHO with nTamCampo
			Replace X1_GRPSXG  with "030"
			MsUnLock()
		EndIf
		If DBSeek(PADR("TFATR1",nTamSX1)+"04")
			RecLock("SX1",.F.)
			Replace X1_TAMANHO with nTamCampo
			Replace X1_GRPSXG  with "030"
			MsUnLock()
		EndIf
		If DBSeek(PADR("COMA01",nTamSX1)+"03")
			RecLock("SX1",.F.)
			Replace X1_TAMANHO with nTamCampo
			Replace X1_GRPSXG  with "030"
			MsUnLock()
		EndIf
		If DBSeek(PADR("COMA01",nTamSX1)+"04")
			RecLock("SX1",.F.)
			Replace X1_TAMANHO with nTamCampo
			Replace X1_GRPSXG  with "030"
			MsUnLock()
		EndIf
		If DBSeek(PADR("COMA01B",nTamSX1)+"04")
			RecLock("SX1",.F.)
			Replace X1_TAMANHO with nTamCampo
			Replace X1_GRPSXG  with "030"
			MsUnLock()
		EndIf
		If DBSeek(PADR("COMA2B",nTamSX1)+"02")
			RecLock("SX1",.F.)
			Replace X1_TAMANHO with nTamCampo
			Replace X1_GRPSXG  with "030"
			MsUnLock()
		EndIf
		If DBSeek(PADR("COMA2B",nTamSX1)+"03")
			RecLock("SX1",.F.)
			Replace X1_TAMANHO with nTamCampo
			Replace X1_GRPSXG  with "030"
			MsUnLock()
		EndIf
		If DBSeek(PADR("RELETQ",nTamSX1)+"03")
			RecLock("SX1",.F.)
			Replace X1_TAMANHO with nTamCampo
			Replace X1_GRPSXG  with "030"
			MsUnLock()
		EndIf
		If DBSeek(PADR("RELETQ",nTamSX1)+"04")
			RecLock("SX1",.F.)
			Replace X1_TAMANHO with nTamCampo
			Replace X1_GRPSXG  with "030"
			MsUnLock()
		EndIf
		If DBSeek(PADR("COMA04",nTamSX1)+"05")
			RecLock("SX1",.F.)
			Replace X1_TAMANHO with nTamCampo
			Replace X1_GRPSXG  with "030"
			MsUnLock()
		EndIf
		If DBSeek(PADR("COMA04",nTamSX1)+"06")
			RecLock("SX1",.F.)
			Replace X1_TAMANHO with nTamCampo
			Replace X1_GRPSXG  with "030"
			MsUnLock()
		EndIf
		If DBSeek(PADR("ESTA07",nTamSX1)+"02")
			RecLock("SX1",.F.)
			Replace X1_TAMANHO with nTamCampo
			Replace X1_GRPSXG  with "030"
			MsUnLock()
		EndIf
		If DBSeek(PADR("TFAT06",nTamSX1)+"08")
			RecLock("SX1",.F.)
			Replace X1_TAMANHO with nTamCampo
			Replace X1_GRPSXG  with "030"
			MsUnLock()
		EndIf
		If DBSeek(PADR("TFAT06",nTamSX1)+"09")
			RecLock("SX1",.F.)
			Replace X1_TAMANHO with nTamCampo
			Replace X1_GRPSXG  with "030"
			MsUnLock()
		EndIf
	EndIf

	If cGrpSXG = '001' //grupo de campo -> codigo cliente/fornecedor
		If DBSeek(PADR("TFATR1",nTamSX1)+"13")
			RecLock("SX1",.F.)
			Replace X1_TAMANHO with nTamCampo
			Replace X1_GRPSXG  with "001"
			MsUnLock()
		EndIf
		If DBSeek(PADR("TFATR1",nTamSX1)+"17")
			RecLock("SX1",.F.)
			Replace X1_TAMANHO with nTamCampo
			Replace X1_GRPSXG  with "001"
			MsUnLock()
		EndIf
		If DBSeek(PADR("COMA01",nTamSX1)+"09")
			RecLock("SX1",.F.)
			Replace X1_TAMANHO with nTamCampo
			Replace X1_GRPSXG  with "001"
			MsUnLock()
		EndIf
		If DBSeek(PADR("COMA2B",nTamSX1)+"01")
			RecLock("SX1",.F.)
			Replace X1_TAMANHO with nTamCampo
			Replace X1_GRPSXG  with "001"
			MsUnLock()
		EndIf
		If DBSeek(PADR("COMA04",nTamSX1)+"03")
			RecLock("SX1",.F.)
			Replace X1_TAMANHO with nTamCampo
			Replace X1_GRPSXG  with "001"
			MsUnLock()
		EndIf
		If DBSeek(PADR("COMA04",nTamSX1)+"04")
			RecLock("SX1",.F.)
			Replace X1_TAMANHO with nTamCampo
			Replace X1_GRPSXG  with "001"
			MsUnLock()
		EndIf
		If DBSeek(PADR("RFTA01",nTamSX1)+"02")
			RecLock("SX1",.F.)
			Replace X1_TAMANHO with nTamCampo
			Replace X1_GRPSXG  with "001"
			MsUnLock()
		EndIf
		If DBSeek(PADR("TCOMR2C",nTamSX1)+"01")
			RecLock("SX1",.F.)
			Replace X1_TAMANHO with nTamCampo
			Replace X1_GRPSXG  with "001"
			MsUnLock()
		EndIf
		If DBSeek(PADR("TTMK04",nTamSX1)+"02")
			RecLock("SX1",.F.)
			Replace X1_TAMANHO with nTamCampo
			Replace X1_GRPSXG  with "001"
			MsUnLock()
		EndIf
		If DBSeek(PADR("TFAT05",nTamSX1)+"03")
			RecLock("SX1",.F.)
			Replace X1_TAMANHO with nTamCampo
			Replace X1_GRPSXG  with "001"
			MsUnLock()
		EndIf
		If DBSeek(PADR("TFAT06",nTamSX1)+"02")
			RecLock("SX1",.F.)
			Replace X1_TAMANHO with nTamCampo
			Replace X1_GRPSXG  with "001"
			MsUnLock()
		EndIf
	EndIf

	If cGrpSXG = '002' //grupo de campo -> Loja
		If DBSeek(PADR("TFATR1",nTamSX1)+"14")
			RecLock("SX1",.F.)
			Replace X1_TAMANHO with nTamCampo
			Replace X1_GRPSXG  with "002"
			MsUnLock()
		EndIf
		If DBSeek(PADR("TFATR1",nTamSX1)+"18")
			RecLock("SX1",.F.)
			Replace X1_TAMANHO with nTamCampo
			Replace X1_GRPSXG  with "002"
			MsUnLock()
		EndIf
	EndIf
	
	If cGrpSXG = '018' //grupo de campo -> Doc ent/sai
		If DBSeek(PADR("TFATR1",nTamSX1)+"15")
			RecLock("SX1",.F.)
			Replace X1_TAMANHO with nTamCampo
			Replace X1_GRPSXG  with "018"
			MsUnLock()
		EndIf
	EndIf

EndIf
         
If Empty(nTamCampo)
	MsgAlert("Ocorreu erro ao atualizar o dicionario de pergunte")
EndIf

RestArea(aArea)
Return