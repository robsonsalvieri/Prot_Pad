#INCLUDE "PCOA130.ch"
#Include "Protheus.ch"
#INCLUDE "FWMBROWSE.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³FUNCAO    ³ PCOA130  ³ AUTOR ³ Paulo Carnelossi      ³ DATA ³ 25/10/2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³DESCRICAO ³ Programa de Cadastro de Acessos aos Centros de Custos        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ USO      ³ SIGAPCO                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³_DOCUMEN_ ³ PCOA130                                                      ³±±
±±³_DESCRI_  ³ Programa de Cadastro de Acessos aos Centros de Custos (PCO)  ³±±
±±³_FUNC_    ³ Esta funcao podera ser utilizada com a sua chamada normal    ³±±
±±³          ³ partir do Menu ou a partir de uma funcao pulando assim o     ³±±
±±³          ³ browse principal e executando a chamada direta da rotina     ³±±
±±³          ³ selecionada.                                                 ³±±
±±³          ³ Exemplo: PCOA130(2) - Executa a chamada da funcao de visua-  ³±±
±±³          ³                       zacao da rotina.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³_PARAMETR_³ ExpN1 : Chamada direta sem passar pela mBrowse               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PCOA130(nCallOpcx,aRotAuto)

Private cCadastro	:= STR0001 //"Cadastro de Centros Oramentrios"
Private aRotina := MenuDef()

Default aRotAuto := {}

If AMIIn(57) // AMIIn do modulo SIGAPCO ( 57 )
	If nCallOpcx <> Nil .And. ( nCallOpcx == 3 .OR. nCallOpcx == 4 )
	    If nCallOpcx == 3
	       Inclui := .T.
	    Else
	       Inclui := .F.
	    EndIf   
		PCOA130DLG("AKX",AKX->(RecNo()),nCallOpcx,aRotAuto)
	Else
		if hasSmartX() //Função para validar se o ambiente esta preparado para SmartX
			setSmartX() //Seta o SmartX no mBrowse
		endif
		mBrowse(6,1,22,75,"AKX")
	EndIf
EndIf

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PCOA130DLGºAutor  ³Paulo Carnelossi    º Data ³  25/10/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³funcao para inclusao ou alteracao de acesso aos centros de  º±±
±±º          ³de custos (feito desta forma em razao validacao botao OK)   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PCOA130DLG(cAlias,nReg,nOpcx,aAuto)

Default aAuto := {}

If nOpcx == 3
	If Len(aAuto) > 0
		AxInclui(cAlias,nReg,nOpcx,/*aAcho*/,/*cFunc*/,/*aCpos*/,"PCOA130CC()"/*cTudoOk*/,/*lF3*/,/*cTransact*/,/*aButtons*/,/*aParam*/,aAuto,/*lVirtual*/,/*lMaximized*/)
	Else
		AxInclui(cAlias,nReg,nOpcx,/*aAcho*/,/*cFunc*/,/*aCpos*/,"PCOA130CC()"/*cTudoOk*/,/*lF3*/,/*cTransact*/,/*aButtons*/,/*aParam*/,/*aAuto*/,/*lVirtual*/,/*lMaximized*/)
	EndIf
EndIf
If nOpcx == 4
	If Len(aAuto) > 0
		AxAltera(cAlias,nReg,nOpcx,/*aAcho*/,/*aCpos*/,/*nColMens*/,/*cMensagem*/,"PCOA130CC()"/*cTudoOk*/,/*cTransact*/,/*cFunc*/,/*aButtons*/,/*aParam*/,aAuto,/*lVirtual*/,/*lMaximized*/)
	Else
		AxAltera(cAlias,nReg,nOpcx,/*aAcho*/,/*aCpos*/,/*nColMens*/,/*cMensagem*/,"PCOA130CC()"/*cTudoOk*/,/*cTransact*/,/*cFunc*/,/*aButtons*/,/*aParam*/,/*aAuto*/,/*lVirtual*/,/*lMaximized*/)
	EndIf
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PCOA130CC ºAutor  ³Paulo Carnelossi    º Data ³  25/10/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³funcao para inclusao ou alteracao de acesso aos centros de  º±±
±±º          ³de custos (feito desta forma em razao validacao botao OK)   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PCOA130CC(lAval, cUser, cCustoIni, cCustoFin, lInclui, nRecAKX)
Local aAreaAKX := AKX->(GetArea())
Local cAlias   := Alias()
Local lRet := .T.
Local aFaixaCC
Local nCtd := 0
Local nPriReg := 0
Local nTamCC := Len(AKX->AKX_CC_INI)
Local cQryCC := ""

Local cQryFinal := ""
Local cQryTmp  := GetNextAlias()
Local cTmpCC
Local lVazioTmp := .T.

DEFAULT lAval := .T.
DEFAULT cUser := M->AKX_USER
DEFAULT cCustoIni := M->AKX_CC_INI
DEFAULT cCustoFin := M->AKX_CC_FIN
DEFAULT lInclui   := Inclui
DEFAULT nRecAKX   := If(Inclui, 0, AKX->(Recno()))

If lAval .And. cCustoIni > cCustoFin
   HELP("  ",1,"PCOA1301") //Centro de custo inicial maior que final
   lRet := .F.
EndIf

If lRet
	//temporario criado no banco
	cTmpCC := CriaTrab( , .F.)
	MsErase(cTmpCC)
	MsCreate(cTmpCC,{{ "CTT_CUSTO", "C", Len(CTT->CTT_CUSTO), 0 }}, "TOPCONN")
	Sleep(1000)
	dbUseArea(.T., "TOPCONN",cTmpCC,cTmpCC/*cAlias*/,.T.,.F.)

	// Cria o indice temporario
	IndRegua(cTmpCC/*cAlias*/,cTmpCC,"CTT_CUSTO",,)

	dbSelectArea("AKX")
	dbSetOrder(1)
	aFaixaCC := {}
	If dbSeek(xFilial("AKX")+cUser)
		While ! Eof() .And. AKX_FILIAL == xFilial("AKX") .And. AKX_USER == cUser
		    If lInclui .OR. (!Inclui .And. Recno() <> nRecAKX)
				aAdd(aFaixaCC, {AKX_CC_INI, AKX_CC_FIN})
		    EndIf
			dbSkip()
		End
	EndIf
		
	If Len(aFaixaCC) > 0
		//1o. avalia se todos os elementos são do tipo caracter
		For nCtd := 1 TO Len(aFaixaCC)
		    aFaixaCC[nCtd][1] := PadR(Alltrim(aFaixaCC[nCtd][1]),nTamCC)  //inicio 
	    	aFaixaCC[nCtd][2] := PadR(Alltrim(aFaixaCC[nCtd][2]),nTamCC)  //final
	
			//avalia se todos os elementos sao numericos
			If 	Valtype(aFaixaCC[nCtd][1]) != "C" .OR. ;     //inicio
				Valtype(aFaixaCC[nCtd][2]) != "C"             //final
		    	HELP("  ",1,"PCOA1302") //Erro: Array enviado contem elemento nao caracter!
		   	    lRet := .F.
		    	EXIT
			EndIf
		Next
		
		If lRet
			//Cenario Atual ja incluido no cadastro
			//Usuario Faixa Inicial CC     Faixa Final CC
			//X       01                   03
			//X       10                   20
			//Tentando Incluir os centros de custo na faixa de 04 a 09
			//X       04                  09
			//primeiro contamos quantos CC tem na faixa de 04-09 (C1)
			//depois contamos quantos CC tem na faixa de 04-09 que nao estao cadastrados (C2)
			//entao fazemos comparacao se quantidade de centro de Custo e para permitir cadastros (C1) === (C2)
			//se for diferente entao é porque ja existe alguma faixa com cadastro destes centros de custos
		
			//monta a query para retornar todos os centros de custos constantes no array aFaixaCC
			For nCtd := 1 TO Len(aFaixaCC)
				cQryCC := " SELECT CTT_CUSTO FROM " + RetSqlName("CTT")
				cQryCC += " WHERE CTT_FILIAL = '"+xFilial("CTT")+"' "
				cQryCC += " AND CTT_CUSTO BETWEEN '" + aFaixaCC[nCtd][1] + "' AND '" + aFaixaCC[nCtd][2] + "' "
				cQryCC += " AND D_E_L_E_T_ = ' ' "				
				cQryCC := ChangeQuery(cQryCC)
				dbUseArea(.T., "TOPCONN", TCGenQry(,,cQryCC), cQryTmp, .F., .T.)
				dbSelectArea(cQryTmp)
    	        dbGoTop()
    			//alimenta o temporario criado no banco pois quando usuario tinha muito acesso estourava o tamanho da query	        
    	        While ! Eof()
    	        
    	        	dbSelectArea(cTmpCC)  //temporario criado no banco
    	        	Reclock(cTmpCC, .T.)
                    (cTmpCC)->CTT_CUSTO := (cQryTmp)->CTT_CUSTO
    	        	MsUnlock()
    	        	lVazioTmp := .F.
    	        
    	        	dbSelectArea(cQryTmp)
    	        	dbSkip()
    	        EndDo
				dbSelectArea(cQryTmp)
    	        dbCloseArea()
	
			Next
			
        	dbSelectArea(cTmpCC)  //temporario criado no banco
			dbCloseArea()

			//Monta a query final
		
            //monta a query para retornar se encontrou cc inicial/final informado se existe no array aFaixaCC
			cQryFinal := " SELECT COUNT(CTT_CUSTO) NCOUNTCTT FROM " + RetSqlName("CTT")
			cQryFinal += "        WHERE CTT_FILIAL = '"+xFilial("CTT")+"' "
			cQryFinal += "          AND CTT_CUSTO BETWEEN '" + cCustoIni + "' AND '" + cCustoFin + "' "
			cQryFinal += "          AND D_E_L_E_T_ = ' ' "
			If ! lVazioTmp
				//faz union com arquivo de centro de custo e temporario contendo as faixas de centro de custo ja inclusas
				cQryFinal += " UNION ALL "
	            //somente retorna os centros de custo se nao existe no array aFaixaCC
	            cQryFinal += " SELECT COUNT(CTT_CUSTO) NCOUNTCTT FROM " + RetSqlName("CTT")
				cQryFinal += "         WHERE CTT_FILIAL = '"+xFilial("CTT")+"' "
				cQryFinal += "           AND CTT_CUSTO BETWEEN '" + cCustoIni + "' AND '" + cCustoFin + "' "
				cQryFinal += "           AND D_E_L_E_T_ = ' ' "
				cQryFinal += "           AND CTT_CUSTO NOT IN ( SELECT CTT_CUSTO FROM " + cTmpCC + " ) "
			EndIf
			cQryFinal := ChangeQuery(cQryFinal)
			dbUseArea(.T., "TOPCONN", TCGenQry(,,cQryFinal), cQryTmp, .F., .T.)
			dbSelectArea(cQryTmp)
            dbGoTop()
			
			//avalia retorno da query no primeiro registro
            lRet := ( (nPriReg := (cQryTmp)->NCOUNTCTT) > 0 )
			//avalia segundo registro se primeiro retornou algum contador de centro de custo            
			If lRet .And. ! lVazioTmp
				dbSelectArea(cQryTmp)
            	dbSkip() //vai para segundo registro
				lRet := ( (cQryTmp)->NCOUNTCTT == nPriReg )
			Else
				HELP("  ",1,"PCOA1303") //Faixa de centro de Custo ja existente nao esta integra.Verificar!
			EndIf						
			            
			dbSelectArea(cQryTmp)
            dbCloseArea()
            //apaga arquivo temporario criado
            MsErase(cTmpCC)
            
            If ! lRet
				HELP("  ",1,"PCOA1304") //Faixa de centro de Custo ja existente, portanto nao pode ser incluida!
            EndIf
            
	    EndIf
	    
	EndIf
		
EndIf
	
RestArea(aAreaAKX)
dbSelectArea(cAlias)

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Ana Paula N. Silva     ³ Data ³10/12/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³		1 - Pesquisa e Posiciona em um Banco de Dados     ³±±
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
Local aRotina 	:= {	{ STR0002,		"AxPesqui" , 0 , 1, ,.F.},;    //"Pesquisar"
							{ STR0003, 	"AxVisual" , 0 , 2},;    //"Visualizar"
							{ STR0004, 		"pcoa130Dlg" , 0 , 3},;	  //"Incluir"
							{ STR0005, 		"pcoa130Dlg" , 0 , 4},; //"Alterar"
							{ STR0006, 		"AxDeleta" , 0 , 5}} //"Excluir"
						
If AMIIn(57) // AMIIn do modulo SIGAPCO ( 57 )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Adiciona botoes do usuario no Browse                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock( "PCOA1301" )
		//P_EÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//P_E³ Ponto de entrada utilizado para inclusao de funcoes de usuarios no     ³
		//P_E³ browse da tela de Centros Orcamentarios                                            ³
		//P_E³ Parametros : Nenhum                                                    ³
		//P_E³ Retorno    : Array contendo as rotinas a serem adicionados na enchoice ³
		//P_E³               Ex. :  User Function PCOA1301                            ³
		//P_E³                      Return {{"Titulo", {|| U_Teste() } }}             ³
		//P_EÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ValType( aUsRotina := ExecBlock( "PCOA1301", .F., .F. ) ) == "A"
			AEval( aUsRotina, { |x| AAdd( aRotina, x ) } )
		EndIf
	EndIf          
EndIf
Return(aRotina)	
