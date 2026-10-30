#Include "plsm153.ch"
#Include "PLSMGER.CH"
#Include "PROTHEUS.CH"
#Include "COLORS.CH"

Static	aRecSE2 := {}

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSm153 ³ Autor ³Módulo Plano de Saúde ³ Data ³ 23.05.2008 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Exclusao de titulos no financeiro...                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Altera‡„o                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSM153() 

Local   n
Local 	cPrefixo    := &(GetMv("MV_3DUPREF"))
Private aRotina     := MenuDef()                           
Private cCadastro 	:= Fundesc() //"Exclusão de Títulos a Pagar"
Private cMarcaE2
Private lIntegracao := IF(GetMV("MV_EASY")=="S",.T.,.F.) 
Private lF050Auto   := .T.    

#IFDEF TOP
       PRIVATE cFiltro := "@E2_FILIAL = '"+xFilial("SE2")+"' "
               cFiltro += " AND E2_PREFIXO = '"+cPrefixo+"' AND D_E_L_E_T_ = ' '"
#ELSE
       PRIVATE cFiltro := "E2_FILIAL = '"+xFilial("SE2")+"' "
               cFiltro += " .AND. E2_PREFIXO = '"+cPrefixo+"' AND D_E_L_E_T_ = ' '"
#ENDIF 
              
cMarcaE2 := GetMark()

DbSelectArea("SE2")
SET FILTER TO &cFiltro
SE2->( dbGotop() )
SE2->( dbSeek(xFilial("SE2")) )

MarkBrow("SE2","E2_OK","(E2_SALDO <> E2_VALOR .OR. E2_LA == 'S' .OR. E2_NUMBOR <> '"+Space(6)+"')",,,cMarcaE2,,,,,"A153Mark()")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Desmasca os registros caso a rotina seja abortada com titulos marcados...		  |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For n := 1 To Len(aRecSE2)
	If aRecSE2[n] > 0
		SE2->( dbGoto(aRecSE2[n]) )
		If !SE2->( Eof() )
			SE2->( RecLock("SE2", .F.) )
				SE2->E2_OK := Space(Len(SE2->E2_OK))
			SE2->( MsUnlock() )
		EndIf
	EndIf
Next

SE2->(DbClearFilter())

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina Principal...                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return Nil 
                                           

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSM153VIS ³Autor³Módulo Plano de Saúde ³ Data ³ 23.05.2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ VIsualização de Títulos a serem excluídos                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Altera‡„o                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function PLSM153Vis()

Local cOldCad := cCadastro

cCadastro := STR0003  //"Visualização do Titulo a Pagar"

Fa050Visua( "SE2",SE2->(Recno()),K_Visualizar )

cCadastro := cOldCad

Return      


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ A153MARK   ³Autor³Módulo Plano de Saúde ³ Data ³ 23.05.2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validação para Seleção de Título para Exclusão             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Altera‡„o                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function A153Mark()

Local lREt := .F.
Local nPos := 0

If Alltrim(SE2->E2_ORIGEM) # 'PLSMPAG' .AND. Alltrim(SE2->E2_ORIGEM) # 'PLSM152'
	MsgStop(STR0004) //"Este Título não foi gerado pelo modulo SIGAPLS e não poderá ser excluido por esta rotina."
ElseIf SE2->E2_LA == "S"
	MsgStop(STR0005) //"Este Título foi contabilizado e não poderá ser excluído por esta rotina."
ElseIf SE2->E2_SALDO <> SE2->E2_VALOR 
	MsgStop(STR0006) //"Este Título foi Baixado e não poderá ser excluido por esta rotina."
ElseIf SE2->E2_NUMBOR <> Space(6)
	MsgStop(STR0007+" "+SE2->E2_NUMBOR+" "+STR0008)	 //"Este Título faz parte do Borderô "###" e não poderá ser excluido por esta rotina."
Else
	SE2->( RecLock("SE2", .F.) )
		If Empty(SE2->E2_OK)
			SE2->E2_OK := cMarcaE2
			
			// Atualiza matriz para desmarcar os registros caso seja necessario.
			If (nPos := Ascan(aRecSE2, SE2->( Recno() ))) == 0
				Aadd(aRecSE2, SE2->( Recno() ))
			EndIf
		Else
			SE2->E2_OK := Space(Len(SE2->E2_OK))
			
			// Remove registro da matriz
			If (nPos := Ascan(aRecSE2, SE2->( Recno() ))) # 0
				Adel(aRecSE2, nPos)				
				If Len(aRecSE2) > 1
					ASize(aRecSE2, (Len(aRecSE2)-1))
				Else
					aRecSE2 := {}
				EndIf
			EndIf
		EndIf
	SE2->( MsUnlock() )
EndIf

Return(lRet)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PLSM153EXC  ³Autor³Módulo Plano de Saúde ³ Data ³ 23.05.2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Exclusão de Títulos de Comissionamento                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Altera‡„o                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSM153EXC()

MsAguarde({|| PLS153EXC() }, cCadastro, "", .T.) // Exibe dialogo padrao...

Return      


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PLS153EXC  ³Autor³Módulo Plano de Saúde ³ Data ³ 23.05.2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Exclusão de Títulos de Comissionamento                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Altera‡„o                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLS153EXC ()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa variaveis                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aErro    := {}
Local nI       := 0
Local nX       := 0
Local bOrdem   := {|x,y| x>y}
Local cSql     := ""
Local cBXQ     := RetSqlName("BXQ")
Local lExclSE2 := .F.
Local lExc	   := .F.
Local lPedCom  := .F.
Local aRecBXQ  := {}
Local aDelNF  := {}
Local aDelPC  := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Confirma a exclusao dos titulos marcados...                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If  Aviso(STR0009,STR0010,{"Sim","Nao"}) == 2 //"Confirmacao de exclusao"###"Deseja realmente excluir todos os titulos marcados?"
	Return(.F.)
EndIf
                  
aSort(aRecSE2,,,bOrdem)

Begin Transaction
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Processa os regsitros marcados...                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nI:=1 To Len(aRecSE2)                               

	lExc := .F.
	SE2->(dbGoto(aRecSE2[nI]))
	
	If  SE2->( EoF() )
		Loop
	EndIf   
	
	MsProcTxt(STR0012)	 //"Atualizando Cálculo da Comissão"

	cSql := " SELECT R_E_C_N_O_ RECBXQ, BXQ_PEDCOM "
	cSql += " FROM "+cBXQ+" " 
	cSql += " WHERE BXQ_FILIAL = '"+xFilial("BXQ")+"' "
	cSql += "    AND BXQ_E2PREF = '"+SE2->E2_PREFIXO+"' " 
	cSql += "    AND BXQ_E2NUM = '"+SE2->E2_NUM+"' " 
	cSql += "    AND BXQ_E2PARC = '"+SE2->E2_PARCELA+"' " 
	cSql += "    AND BXQ_E2TIPO = '"+SE2->E2_TIPO+"' " 
	cSql += "    AND D_E_L_E_T_ = '' "
	
	cSql := ChangeQuery(cSql)
	DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cSql),"TRBBXQ",.T.,.T.)		

	While !TRBBXQ->(EoF())
		aadd(aRecBXQ,TRBBXQ->RECBXQ)		
        lExc := .T.
		lPedCom := !empty(TRBBXQ->BXQ_PEDCOM)
		TRBBXQ->(Dbskip())
	Enddo		
	
	TRBBXQ->(DbCloseArea()) 
	
	if !lExc
		aadd(aErro,{SE2->E2_PREFIXO + SE2->E2_NUM + SE2->E2_PARCELA + SE2->E2_TIPO,STR0014}) //"Título não esta vinculado e nenhum Pagto de Comissão"		 
	elseif !(lExclSE2 := PLCANCRE()[1])
        aadd(aErro,{SE2->E2_PREFIXO + SE2->E2_NUM + SE2->E2_PARCELA + SE2->E2_TIPO,STR0011}) //"Título nao pode ser Excluído Verifique a condição do mesmo no Módulo Financeiro"	
	elseif lPedCom
		aDelNF := PLDELNF(aRecBXQ)
		if !aDelNF[1]
			aadd(aErro, {aDelNF[2], STR0015}) // "Nota fiscal não pode ser excluída. Verifique a condição da mesma no módulo de Compras."	
		endif

		aDelPC := PLDELPC(aRecBXQ)
		if !aDelPC[1]
			aadd(aErro, {aDelPC[2], STR0016}) // "Pedido de compra não pode ser excluído. Verifique a condição do mesmo no módulo de Compras."	
		endif
	endif

	if len(aErro) == 0
    	for nX := 1 to len(aRecBXQ)
			BXQ->(dbGoTo(aRecBXQ[nX]))
	    	BXQ->(recLock("BXQ", .F.))
			BXQ->BXQ_DTGER  := ctod("")
			BXQ->BXQ_E2PREF := ""
			BXQ->BXQ_E2NUM  := ""
			BXQ->BXQ_E2PARC := ""
			BXQ->BXQ_E2TIPO := ""
			BXQ->BXQ_E2FORN := ""
			BXQ->BXQ_E2LOJA := ""
			BXQ->BXQ_PEDCOM := ""
	        BXQ->(msUnlock())
	    next nX
	endif
Next nI

End Transaction

If  Len(aErro) > 0
    PLSCRIGEN(aErro,{ {"Chave (conteudo)","@C",60 } , {"Mensagem","@C",40 } } , STR0013) //"Ocorrências na exclusão dos Títulos selecionados"
EndIf

aRecSE2 := {}

fwFreeArray(aDelNF)
fwFreeArray(aDelPC)

Return     


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Darcio R. Sporl       ³ Data ³22/12/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±
±±³          ³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³	  1 - Pesquisa e Posiciona em um Banco de Dados           ³±±
±±³          ³    2 - Simplesmente Mostra os Campos                       ³±±
±±³          ³    3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³    4 - Altera o registro corrente                          ³±±
±±³          ³    5 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()

Private aRotina   := { 	{ STRPL01        ,'AxPesqui' , 0 ,K_Pesquisar   ,0 , .F.  },; // Pesquisar
						{ STR0000   	 ,'PLSM153VIS' , 0 ,K_Visualizar,0 , Nil  },; //"Visualizar"
                       	{ STR0001	     ,'PLSM153EXC' , 0 ,K_Excluir   ,0 , Nil  }} //"Excluir"


Return(aRotina)

/*/{Protheus.doc} PLDELNF
Função para realizar a exclusão de notas fiscais de comissionamento, caso o título esteja vinculado a uma nota fiscal.
@author Gabriel Lakatos
@since 12/08/2026
@version 12.1.2610
@return aRet - Array com o resultado da exclusão, sendo:
		aRet[1] - .T. se a exclusão foi bem sucedida, .F. caso contrário
		aRet[2] - Dados da nota fiscal que não pôde ser excluída, caso a exclusão tenha falhado
/*/
static function PLDELNF(aRecBXQ) 
       
    local nOpc := 5
    local aCab := {}
    local aItens := {}
    local aLinha := {}
	local cErro := ""
	local aRet := {.F., ""}
     
    private lMsErroAuto := .F.

	default aRecBXQ := {}

	BXQ->(dbGoTo(aRecBXQ[1]))

	// Defino o valor default do retorno, caso a nota fiscal seja excluída com sucesso, o retorno será .T. e a segunda posição do array será vazia
	aRet[1] := .F.
	aRet[2] := BXQ->(BXQ_E2NUM + BXQ_E2PREF + BXQ_E2FORN + BXQ_E2LOJA)

    SF1->(dbSetOrder(1))
    if SF1->(dbSeek(xFilial("SF1") + BXQ->(BXQ_E2NUM + BXQ_E2PREF + BXQ_E2FORN + BXQ_E2LOJA) ))
 
		aadd(aCab, {"F1_TIPO", SF1->F1_TIPO , nil})
		aadd(aCab, {"F1_FORMUL", SF1->F1_FORMUL , nil})
		aadd(aCab, {"F1_DOC", SF1->F1_DOC, nil})
		aadd(aCab, {"F1_SERIE", SF1->F1_SERIE , nil})
		aadd(aCab, {"F1_EMISSAO", dDatabase, nil})
		aadd(aCab, {"F1_DTDIGIT", SF1->F1_DTDIGIT, nil})
		aadd(aCab, {"F1_FORNECE", SF1->F1_FORNECE , nil})
		aadd(aCab, {"F1_LOJA", SF1->F1_LOJA , nil})
		aadd(aCab, {"F1_ESPECIE", SF1->F1_ESPECIE , nil})
	
		SD1->(dbSetOrder(1))
		if SD1->(dbSeek(xFilial("SD1") + SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)))
			while !eof() .and. SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA) == SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)

				aItens := {}
				aadd(aItens, {'D1_DOC', SD1->D1_DOC, nil})
				aadd(aItens, {'D1_SERIE', SD1->D1_SERIE, nil})
				aadd(aItens, {'D1_FORNECE', SD1->D1_FORNECE, nil})
				aadd(aItens, {'D1_LOJA', SD1->D1_LOJA, nil})
				aadd(aItens, {"D1_ITEM", SD1->D1_ITEM, nil})
				aadd(aItens, {"D1_COD" , SD1->D1_COD, nil})
				aadd(aItens, {"D1_UM"  , SD1->D1_UM, nil})
				aadd(aItens, {"D1_LOCAL", SD1->D1_LOCAL, nil})
				aadd(aItens, {"D1_QUANT", SD1->D1_QUANT, nil})
				aadd(aItens, {"D1_VUNIT", SD1->D1_VUNIT, nil})
				aadd(aItens, {"D1_TOTAL", SD1->D1_TOTAL, nil})
				aadd(aItens, {"D1_TES"  , SD1->D1_TES, nil})
					
				aadd(aLinha, aItens)

				SD1->(dbSkip())
			end
		endif
		
		if len(aCab) > 0 .and. len(aLinha) > 0
			msExecAuto({|a,b,c,d| MATA103(a,b,c,d)}, aCab, aLinha, nOpc, .F.)
			
			if !lMsErroAuto
				aRet[1] := .T.
				aRet[2] := ""
			endif
		endif
	endif

	fwFreeArray(aCab)
	fwFreeArray(aLinha)
	fwFreeArray(aItens)
 
return aRet

/*/{Protheus.doc} PLDELPC
Função para realizar a exclusão do pedido de compra de comissionamento, caso o título esteja vinculado a uma nota fiscal.
@author Gabriel Lakatos
@since 12/08/2026
@version 12.1.2610
@return aRet - Array com o resultado da exclusão, sendo:
		aRet[1] - .T. se a exclusão foi bem sucedida, .F. caso contrário
		aRet[2] - Dados do pedido de compra que não pôde ser excluído, caso a exclusão tenha falhado
/*/
static function PLDELPC(aRecBXQ) 

	local aCabec := {}
	local aItens := {}
	local aLinha := {}
	local nOpc := 5
	local aRet := {.F., ""}

	private lMsErroAuto := .F.

	default aRecBXQ := {}
	
	BXQ->(dbGoTo(aRecBXQ[1]))

	// Defino o valor default do retorno, caso o pedido de compra seja excluído com sucesso, o retorno será .T. e a segunda posição do array será vazia
	aRet[1] := .F.
	aRet[2] := BXQ->BXQ_PEDCOM

    SC7->(dbSetOrder(1))
    if SC7->(dbSeek(xFilial("SC7") + BXQ->BXQ_PEDCOM))

		aadd(aCabec, {"C7_NUM", SC7->C7_NUM})
		aadd(aCabec, {"C7_EMISSAO", dDataBase})
		aadd(aCabec, {"C7_FORNECE", SC7->C7_FORNECE})
		aadd(aCabec, {"C7_LOJA", SC7->C7_LOJA})
		aadd(aCabec, {"C7_COND", SC7->C7_COND})
		aadd(aCabec, {"C7_CONTATO", SC7->C7_CONTATO})
		aadd(aCabec, {"C7_FILENT", SC7->C7_FILENT})

		while !SC7->(eof()) .and. SC7->C7_FILIAL == xFilial("SC7") .and. SC7->C7_NUM == BXQ->BXQ_PEDCOM
			
			aLinha := {}
			aadd(aLinha, {"C7_ITEM", SC7->C7_ITEM, nil})
			aadd(aLinha, {"C7_PRODUTO", SC7->C7_PRODUTO, nil})
			aadd(aLinha, {"C7_QUANT", SC7->C7_QUANT, nil})
			aadd(aLinha, {"C7_PRECO", SC7->C7_PRECO, nil})
			aadd(aLinha, {"C7_TOTAL", SC7->C7_TOTAL, nil})
			
			aadd(aItens, aLinha)

			SC7->(dbSkip())
		end

		if len(aCabec) > 0 .and. len(aItens) > 0
			msExecAuto({|a,b,c,d,e| MATA120(a,b,c,d,e)}, 1, aCabec, aItens, nOpc, .F.)

			if !lMsErroAuto
				aRet[1] := .T.
				aRet[2] := ""
			endif
		endif
	endif

	fwFreeArray(aCabec)
	fwFreeArray(aItens)
	fwFreeArray(aLinha)

return aRet
