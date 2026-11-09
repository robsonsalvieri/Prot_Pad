#INCLUDE "STFStationConfig.ch"
#INCLUDE "Protheus.ch"
#INCLUDE "AP5MAIL.CH"
#INCLUDE "STFSTCFG.CH"

Static cFil3   := NIL
Static cFil2   := NIL
Static cFil1   := NIL
Static cLG_CODIGO := NIL
Static cIdAmb	  := NIL
Static cNodeAnt	  := NIL
Static cEsta	  := NIL
Static oCfgTef	  := NIL  

//-------------------------------------------------------------------
/*/{Protheus.doc} STFStatCon
Configurador de Estação
@author  Varejo
@version P11.8
@since   26/04/2013
@return  NIL
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STFStatCon()
	STFStationConfig()
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} STFStationConfig
Configurador de Estação
@author  Varejo
@version P11.8
@since   26/04/2013
@return  NIL
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STFStationConfig()
Local aSize :=  MsAdvSize( .F. ) //Tamanho da Janela
Local aSections := {} 			//Seções da Janela
Local aPosObj	:= {} 				//Posicões do Objeto
Local nTamX :=  aSize[5]    //LARGURA
Local nTamY	:=  aSize[6] - aSize[7]  //ALTURA
Local oDlg	:= NIL          //Janela
Local aArea	:= {}           //Area Anterior
Local aPosObjD2	:= {}       //Objeto2
Local nTamSx3 := MF7->(TamSx3("MF7_NODE")[1]) 			//To do  - Carregar o código do nó princial
Local aDados := {}			 //No pai, idnode, descricao, ordem, ambiente, gravado, validado, editado, IdInterno
Local cIdAmbiente := IIF(nModulo == 12, "1", "3")   //Ambiente dos nós
Local oPanel := NIL         //Painel
Local nTamNode	:= MF7->(TamSX3("MF7_DESCR")[1])       //to do - descrição do nó
Local cSearchNode := space(nTamNode)  //
Local nTamCol := 0          //Tamanho da coluna
Local aList := { STR0001, STR0002, STR0003, STR0004}  //ambientes //"1=Retaguarda"###"2=Frente de Lojas"###"3=POS"###"4=Central de PDV"
Local cLog := ""            //Log
Local oBtn1 := NIL          //Botões
Local oBtnLog := NIL        //botão 2
Local oBtn3 := NIL          //Botão 3
Local nColFin	:= 0        //Coluna Finaç
Local aCoord	:= {}		//Coordenadas da Tree
Local oTree := NIL			//Objeto da árvore


	IniStaticVar()

	InsertData()

	cNodeAnt	  := ""

	LoadData(@aDados, cIdAmbiente)

	DEFINE MSDIALOG oDlg TITLE STR0005 FROM aSize[7],0 TO aSize[6],aSize[5] PIXEL //"Configurador Loja"


	aAdd(aSections, {100, 5, .T., .T. }) // Painel 1 - 05%
	aAdd(aSections, {100, 87, .T., .T. }) //Painel 2 - 85%
	aAdd(aSections, {100, 8, .T., .T. }) //Painel 2 - 8%


	aArea := { aSize[1], aSize[2], aSize[3], aSize[4], 3, 3, 3, 3}

	aPosObj :=  MsObjSize( aArea, aSections, .T., .F.)

	//Cria os painéis verticais   - PAINEL 1
		nTamCol := CalcFieldSize("C",nTamNode,0,"@!")

		@aPosObj[01,01],aPosObj[01,02] TO aPosObj[01,03], aPosObj[01,04 ] OF oDlg PIXEL

		@aPosObj[01,01]+3,aPosObj[01,02]+5 MsGet cSearchNode Size  nTamCol,10  OF oDlg  PIXEL
		nColFin := aPosObj[01,02]+5+nTamCol+1

		SButton():Create( oDlg, aPosObj[01,01]+3, nColFin , 15, {|| SearchNode(cSearchNode, oTree, @aDados,  cIdAmbiente,  @oPanel, @oDlg, @cLog)} , .F., STR0006, { || !Empty(cSearchNode)  } )// --> oObjeto //"Localizar o Nó"
		//Falta criar o tlist programar o bchange para re-montar a tree
		nColFin += 40
		nTamCol := CalcFieldSize("C",Len(STR0007)) //"Estação"

		@aPosObj[01,01]+5,nColFin SAY STR0008 SIZE nTamCol, 10 PIXEL OF oDlg //"Estacao"
		nTamCol := CalcFieldSize("C",SLG->(TamSx3("LG_CODIGO"))[1],0,"@!")

		@aPosObj[01,01]+3,nColFin MsGet cLG_CODIGO Size  nTamCol,10 PIXEL OF oDlg F3 "SLG"  PIXEL Picture "@!" VALID BuildList(@oTree, @aDados, cIdAmbiente, nTamSX3, oDlg, @oPanel, @cLog, cLG_CODIGO, aCoord, nTamSX3)
		nColFin += nTamCol+1
		nTamCol := CalcFieldSize("C",20,0,"@!")

		TComboBox():New(aPosObj[01,01]+3, aPosObj[01,04 ] - (nTamCol+10), {|u| if( Pcount( )>0, cIdAmbiente := u,cIdAmbiente )  } ,aList, nTamCol,10, oDlg, ,, { || BuildList(@oTree, @aDados, cIdAmbiente, nTamSX3, oDlg, @oPanel, @cLog, cLG_CODIGO, aCoord, nTamSX3)  } ,,,.T.,,,.F.,,.T.,,,,"cIdAmbiente")

	//PAINEL 2
		@aPosObj[02,01],aPosObj[02,02] TO aPosObj[02,03], aPosObj[02,04 ] OF oDlg PIXEL

		//Cria a divisão do objeto Tree -  2 Painels horizontais
		aSections := {}
		aAdd(aSections, {100, 30, .T., .T., .F.}) 		//30% Tree
		aAdd(aSections, {100, 70, .T., .T., .T.})  //70% Painel - Retorna X, y ao invés de linha/coluna finaç

		aArea := { aPosObj[02,01], aPosObj[02,02],  aPosObj[02,03], aPosObj[02,04], 0, 0}
		aPosObjD2	:=  MsObjSize( aArea, aSections, .T., .T.)
		aPosObjD2[02,01] := aPosObj[02,01]                                                                                                                                              //l                           //h
		aPosObjD2[02,02] := aPosObjD2[01,04]+3
		oPanel := TPanel():New ( aPosObjD2[02,01], aPosObjD2[02,02], "" , oDlg, /*[ oFont]*/, /*[ lCentered]*/, /*[ uParam7]*/, /*[ nClrText]*/, /*[ nClrBack]*/, aPosObj[02,04]-aPosObjD2[02,02], aPosObj[02,03]-aPosObjD2[02,01], /*[ lLowered]*/, /*lRaised*/ )
		aCoord := aClone(aPosObj[02])
		aCoord[4] := aPosObjD2[01,04]

		BuildTree(@oTree, @aDados, cIdAmbiente, @oPanel, oDlg, @cLog, aCoord, nTamSX3)



	//PAINEL 3
		@aPosObj[03,01],aPosObj[02,02] TO aPosObj[03,03], aPosObj[03,04 ] OF oDlg PIXEL

		oBtn1 := TButton():New( aPosObj[03,01]+5, aPosObj[02,02]+05, STR0009,oDlg,{|| cLog := ValidAllNodes(cIdAmbiente, oTree:GetCargo(), oTree, aDados)},55,15,,,.F.,.T.,.F.,,.F.,{ || .T. },,.F. ) //"Validar Tudo"

		oBtnLog := TButton():New( aPosObj[03,01]+5, aPosObj[02,02]+05+60, STR0010,oDlg,{|| ShowMainLog(oTree:GetCargo(), oTree, oPanel, cIdAmbiente, @cLog, aDados) },55,15,,,.F.,.T.,.F.,,.F.,{ || !Empty(cLog) },,.F. ) //"Visualizar Log"
		If Empty(cLog)
			oBtnLog:Disable()
		EndIf

		oBtn3 := TButton():New( aPosObj[03,01]+5, aPosObj[02,02]+05+120, STR0011,oDlg,{||oBtnLog:Free(), oBtnLog := NIL, oDlg:End()  },55,15,,,.F.,.T.,.F.,,.F.,{ || .T. },,.F. ) //"Fechar"


	ACTIVATE DIALOG oDlg CENTERED

	ReleaseStaticVar()

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} ActionClick
Evento do clique do nó da arvore
@param cCargo  Nó
@param oTree   Arvore
@param aDados  Array dos nós
@param cIdAmb  Código do Ambiente
@param oPanel  Painel
@param oDlg    Janela
@param cLog	   Log
@author  Varejo
@version P11.8
@since   26/04/2013
@return  NIL
@obs
@sample
/*/
//-------------------------------------------------------------------
Static Function ActionClick( cCargo, oTree,  aDados,  cIdAmb, oPanel, oDlg, cLog)
Local nPos 			:= 0        //Posicao do Array aDados
Local lContinua 	:= .T.  //Continua o processamento
Local cFatherNode 	:= ""  //Nó pai   

	DEFAULT cCargo 	:= ""
	DEFAULT oTree 	:= NIL
	DEFAULT aDados 	:= {}
	DEFAULT cIdAmb 	:= ""
	DEFAULT oPanel 	:= NIL
	DEFAULT oDlg 	:= NIL
	DEFAULT cLog	:= ""

	If !Empty(cNodeAnt) .AND.;
		 ( nPos := aScan(aDados, { |x| x[_CODE_NODE] == cNodeAnt}) ) > 0

		cFatherNode := aDados[nPos,_FATHER_NODE]
		If aDados[nPos, _EDITED_NODE]
			lContinua := 	MsgYesNo(STR0012 + AllTrim(aDados[nPos,_DESCRIPTION_NODE]) + " ? ") //"Sair sem salvar as alterações do processo "
	    Else

			aEval(aDados[nPos,_COMPS_NODE], { |c| IIF(Valtype(c[_COMP_OBJECT]) == "O",  c[_COMP_OBJECT]:= FreeObj(c[_COMP_OBJECT]), )})

			If !( cFatherNode <>  cNodeAnt .OR. ;
				((nPos := aScan(aDados, { |x| x[_CODE_NODE] == cCargo}) ) > 0 .AND. ;
				  (cFatherNode  == aDados[nPos,_FATHER_NODE] .OR. ;
				   cNodeAnt  == aDados[nPos,_FATHER_NODE] .OR.  ;
				   cFatherNode == cCargo ) ) )

					ReleaseChildren(cIdAmb, cNodeAnt, @aDados, @oTree)

			EndIf
	  	EndIf


	    If lContinua
	       	If cNodeAnt <> aDados[nPos,_CODE_NODE]
        		nPos := aScan(aDados, { |x| x[_CODE_NODE] == cNodeAnt})
        	EndIf
        	aEval(aDados[nPos,_COMPS_NODE], { |c| IIf(ValType(c[_COMP_OBJECT]) == "O" , c[_COMP_OBJECT]:Free(),)})

			//Mudou o foco, então libera os objetos criados pelos componentes
			If cFatherNode ==  cNodeAnt .OR. ;
				((nPos := aScan(aDados, { |x| x[_CODE_NODE] == cCargo}) ) > 0 .AND. ;
				  (cFatherNode  == aDados[nPos,_FATHER_NODE] .OR. ;
				   cNodeAnt  == aDados[nPos,_FATHER_NODE] .OR. ;
				   cFatherNode == cCargo ) )
				//Seta como editado o nó pai
				If aDados[nPos,_CODE_NODE] == cFatherNode .OR. ;
					(nPos := aScan(aDados, { |x| x[_CODE_NODE] == cFatherNode} ) ) > 0

					STFSetNodeEdited( lContinua, @aDados[nPos])
				EndIf
			Else
				If !Empty(cNodeAnt)
					ReleaseChildren(cIdAmb, cNodeAnt, @aDados, @oTree)
				EndIf
			EndIf

		Else
			oTree:TreeSeek(cNodeAnt)
		EndIf


	EndIf
	If lContinua .AND. ;
			( (nPos > 0 .AND. aDados[nPos,_CODE_NODE] == cCargo) .OR. (nPos := aScan(aDados, { |x| x[_CODE_NODE] == cCargo}) ) > 0  )

			//Carrega os componentes do nó
			If cNodeAnt <> cCargo
				cLog := ""
			EndIf
			cNodeAnt := cCargo
			If Len(aDados[nPos,_COMPS_NODE]) == 0
				aDados[nPos,_COMPS_NODE] := LoadComp(cCargo, cIdAmb)
			EndIf

		    oPanel:Hide()
		    MsFreeObj(@oPanel, .T.)

		    MontaPanel(cCargo, oTree, @aDados[nPos], oPanel, cIdAmb,, aDados, @cLog)
		    cNodeAnt := cCargo
		    oPanel:Show()

		    If Len(	aDados[nPos, _COMPS_NODE]) > 0 .AND. ValType(	aDados[nPos, _COMPS_NODE][1, _COMP_OBJECT] ) == "O"
		    	aDados[nPos, _COMPS_NODE][1, _COMP_OBJECT]:SetFocus()
		    EndIf
		    

	ElseIf nPos = 0

		    oPanel:Hide()
		    MsFreeObj(@oPanel, .T.)

		    MontaPanel(cCargo, oTree, {}, oPanel, cIdAmb, ,aDados, @cLog)
		    cNodeAnt := cCargo
		    oPanel:Show()  
		    
	EndIf



Return

//-------------------------------------------------------------------
/*/{Protheus.doc} LoadTree
Carrega o nó da árvore
@param oDlg      Janela
@param oTree     Arvore
@param cIdAmb    Código do Ambiente
@param cMainNode Nó principal
@param aDados  Array dos nós
@author  Varejo
@version P11.8
@since   26/04/2013
@return  NIL
@obs
@sample
/*/
//-------------------------------------------------------------------
Static Function LoadTree(oDlg, oTree, cIdAmb, cMainNode, aDados)

//Carregar/Nontar nós principais
Local nPos := 0    //Posição do nó
Local lPai	:= .F.  //No Pai
Local nTam	:= MF7->(TamSX3("MF7_DESCR")[1])   //To do: amanho da descrição do nó

DEFAULT oDlg := NIL
DEFAULT oTree := NIL
DEFAULT cIdAmb := ""
DEFAULT cMainNode := ""
DEFAULT aDados := {}


	If (nPos := aScan(aDados, { |x| x[_FATHER_NODE] ==  cMainNode }) )  > 0  //substituir por um setfilter
		Do While nPos <= Len(aDados) .AND. aDados[nPos, _FATHER_NODE] ==  cMainNode
			If Empty(aDados[nPos,_ENVIRONMENT_NODE]) .OR. cIdAmb $ aDados[nPos,_ENVIRONMENT_NODE]   //Está no ambiente, então monta o nó
				//Verifica se existe filhos para criar um ícone de folder ou de item
				lPai := ExistNodes(cIdAmb, aDados[nPos,_CODE_NODE], aDados)
				If !lPai
					oTree:AddTreeItem(aDados[nPos,_DESCRIPTION_NODE],"SUMARIO",, aDados[nPos,_CODE_NODE])
				Else
					oTree:AddTree (aDados[nPos,_DESCRIPTION_NODE] , ,"FOLDER5" ,"FOLDER6"  , ,  , aDados[nPos,_CODE_NODE] )
					LoadTree(oDlg, oTree, cIdAmb, aDados[nPos,_CODE_NODE], aDados)
					oTree:EndTree()
				EndIf
				aDados[nPos, _IS_FATHER] :=  lPai
			EndIf
			nPos ++
		EndDo
	EndIf


Return

//-------------------------------------------------------------------
/*/{Protheus.doc} LoadComp
Carrega os componentes do Node
@param   cCargo    Nó
@param   cIdAmb    Código do Ambiente
@author  Varejo
@version P11.8
@since   26/04/2013
@return  aRetorno - Componentes do Nó
@obs
@sample
/*/
//-------------------------------------------------------------------
Static Function LoadComp(cCargo, cIdAmb )  //Carrega os componentes do Node
Local aComps := {} //Lista dos componentes
Local nPos	 := 0
Local aRetorno := {}
Local aArea := GetArea()
Local aAreaMF8 := MF8->(GetArea())

DEFAULT cCargo := ""
DEFAULT cIdAmb := ""

MF8->(DbSetFilter({ || MF8_FILIAL == xFilial() .AND. MF8_NODE == cCargo .AND.  (Empty(MF8_ENVIRO) .OR. cIdAmb $ MF8_ENVIRO) .AND.  (Empty(MF8_PAISES) .OR. cPaisLoc $ MF8_PAISES )}, ;
		"MF8_FILIAL == xFilial() .AND. MF8_NODE == cCargo .AND.  (Empty(MF8_ENVIRO) .OR. cIdAmb $ MF8_ENVIRO ) .AND. (Empty(MF8_PAISES) .OR. cPaisLoc $ MF8_PAISES )"))

MF8->(DbGoTop())

Do While MF8->(!Eof())
	MF8->(aAdd(aRetorno, { MF8_NODE,;//_COMP_NODE	01 //codigo do nó
					MF8_ID,; //_COMP_ID 02     //id do componentes
					MF8_ENVIRO,; // _COMP_ENVIRONMENT 03 //ambiente do componente
					MF8_TYPE,; // _COMP_TYPE  04       //tipo do componente
					RTrim(MF8_NAME),; //_COMP_NAME 05        //Nome do componente
					MF8_TITLE,; //_COMP_TITLE 06       //titulo do componente
					RTrim(MF8_F3),; //_COMP_F3 07          //f3 do componente
					IIF(!Empty(MF8_DEFAUL),&(AllTrim(MF8_DEFAUL)),NIL),; //_COMP_DEFAULT 08     //valor default do componente
					RTrim(MF8_TABLE),; //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
					MF8_INDEX,; //_COMP_INDEX 10        //indice da tabela
					MF8_KEY,;//_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração
					MF8_INTYPE,;//_COMP_INITYPE 12 */    //tipo de arquivo.ini
				   IIF(!Empty(MF8_VALID),&(AllTrim(MF8_VALID)),NIL),;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO*/
					MF8_LEN,; //_COMP_LEN   14
					RTrim(MF8_LIST),;// _COMP_LIST 15 // lISTA DE vALORES   //
					MF8_FTYPE,;// _COMP_FIELD_TYPE 16
					,;// _COMP_CTRL_TYPE 17
					,;//_COMP_OLDVALUE 18
					MF8_POSICA,;
					}	) )

	nPos++
	LoadValue(@aRetorno[nPos])
	MF8->(DbSkip())
EndDo

MF8->(DbClearFilter())

RestArea(aAreaMF8)
RestArea(aArea)
Return aRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} ExistNodes
Verifica se o nó existe
@param   cIdAmb    Código do Ambiente
@param   cMainNode Nó principal
@param   aDados    Array dos nós
@author  Varejo
@version P11.8
@since   26/04/2013
@return  lAchou    Se componente existe, retorna True.
@obs
@sample
/*/
//-------------------------------------------------------------------
Static Function ExistNodes(cIdAmb, cMainNode, aDados)
Local lAchou := .F.  //Achou o nó
Local nPos := 0      //Posicao

DEFAULT cIdAmb := ""
DEFAULT cMainNode := ""
DEFAULT aDados := {}

	If (nPos := aScan(aDados, { |x| x[_FATHER_NODE] ==  cMainNode }) )  > 0  //substituir por um setfilter
		Do While !lAchou .AND. nPos <= Len(aDados) .AND. aDados[nPos, _FATHER_NODE] ==  cMainNode
			If Empty(aDados[nPos,_ENVIRONMENT_NODE]) .OR. cIdAmb $ aDados[nPos,_ENVIRONMENT_NODE]   //Está no ambiente, então monta o nó
			   lAchou := .T.
			EndIf
			nPos++
		EndDo
	EndIf


Return lAchou

//-------------------------------------------------------------------
/*/{Protheus.doc} MontaPanel
Função para Montar o Painel
@param cCargo    Nó
@param oTree     Arvore
@param aDadosL   Nó de Posicionamento
@param oPanel    Painel
@param cIdAmb    Código do Ambiente
@param aControls Controles da Janela
@param aDados    Array dos nós
@param cLog	     Log
@author  Varejo
@version P11.8
@since   26/04/2013
@return  NIL
@obs
@sample
/*/
//-------------------------------------------------------------------
Static Function MontaPanel(cCargo, oTree, aDadosL, oPanel, cIdAmb, aControls, aDados, cLog)
Local nRow		:= 0 							//Linha do Painel
Local nCol		:= 0   							//Coluna do Painel
Local aObjects := {}                           //Objetos do painel
Local aPosObj2 := {}                           //Coordenadas do painel
Local cTitulo := ""						       //titulo do Painel
Local nRow1 := 0	                        //Linhas da seção 2
Local lPai	   := .F.                         //Eh no pai?
Local nC := 0                                 //contador de controles
Local nComps := 0                            //Contador de componentes
Local nInitCBox := 0                         //Inicializador da Lista
Local nTam  := 0                             //Tamanho do título
Local aList := {}                            //Lista de Valores
Local nPos	:= 0                             //Posicao dos dados
Local oPanel2 := NIL                         //painel 2
Local oBtn1 := NIL                           //Botão1
Local oBtn2 := NIL                           //Botão2
Local oBtn3 := NIL                           //botão3
Local cVariable := NIL                       //Variável do bloco
Local cGet := NIL                            //Comando do Get   
Local cNomeRot								 //Nome da rotina

	DEFAULT cCargo 		:= ""
	DEFAULT oTree		:= NIL
	DEFAULT aDadosL		:= {}
	DEFAULT oPanel		:= NIL
	DEFAULT cIdAmb		:= ""
	DEFAULT aControls 	:= {}
	DEFAULT aDados		:= {}
	DEFAULT cLog		:= ""
 
	If ValType(oPanel) == "O"
		nRow		:= Int((oPanel:nHeight ) / 2)  //Linha do Painel
		nCol		:= Int((oPanel:nWidth ) / 2)   //Coluna do Painel
		nRow1 := nRow-29                        //Linhas da seção 2
	EndIf
	
	If Len(aDadosL) >= _DESCRIPTION_NODE
		cTitulo := AllTrim(aDadosL[_DESCRIPTION_NODE])         //titulo do Painel
    EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Parte 01 da tela³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len(aDadosL) > 0
		lPai	   := aDadosL[_IS_FATHER]
		nPos := Len(aDadosL[_COMPS_NODE])
	EndIf

	For nC := 1 to nPos           
		        	
	     If !aDadosL[_COMPS_NODE][nC,_COMP_CTRL_TYPE] $ "C/R/X"
	 	 	aAdd(aObjects,  { CalcFieldSize("C",aDadosL[_COMPS_NODE][nC,_COMP_LEN],0,"@!",aDadosL[_COMPS_NODE][nC,_COMP_TITLE]), 6, .F., .F.}) //Impar Say
		 	aAdd(aControls, { aDadosL[_COMPS_NODE][nC,_COMP_TITLE], , , "S", } )
	        nComps++
	        //Verifica a criação da variável

	        If aDadosL[_COMPS_NODE][nC,_COMP_CTRL_TYPE] == "G"
	        
	        	aAdd(aObjects, {CalcFieldSize("C",aDadosL[_COMPS_NODE][nC,_COMP_LEN],0,"@!",aDadosL[_COMPS_NODE][nC,_COMP_TITLE]), 10, .F., .F.} ) //Impar Say           
	        	

               If aDadosL[_COMPS_NODE][nC,_COMP_FIELD_TYPE]=="N" .AND. !Empty(aDadosL[_COMPS_NODE][nC,_COMP_LEN])  
	        	aAdd(aControls, {aDadosL[_COMPS_NODE][nC,_COMP_DEFAULT] , ;
	        							IIF( Empty(aDadosL[_COMPS_NODE][nC,_COMP_INITYPE]),;
	        								Replicate("9",aDadosL[_COMPS_NODE][nC,_COMP_LEN]),;
	        								Replicate("9",aDadosL[_COMPS_NODE][nC,_COMP_LEN]  - Val(aDadosL[_COMPS_NODE][nC,_COMP_INITYPE])+1)  + "." + Replicate("9",Val(aDadosL[_COMPS_NODE][nC,_COMP_INITYPE])) ),;
	        							 aDadosL[_COMPS_NODE][nC,_COMP_F3],;
	        							 aDadosL[_COMPS_NODE][nC,_COMP_CTRL_TYPE], nC} )
               
               Else
               		aAdd(aControls, {aDadosL[_COMPS_NODE][nC,_COMP_DEFAULT] , ;
	        							 "",;
	        							 aDadosL[_COMPS_NODE][nC,_COMP_F3],;
	        							 aDadosL[_COMPS_NODE][nC,_COMP_CTRL_TYPE], nC} )
               EndIf

	        	nComps++
	        ElseIf aDadosL[_COMPS_NODE][nC,_COMP_CTRL_TYPE] == "L"
	        	If ! "{" $ aDadosL[_COMPS_NODE][nC,_COMP_LIST] .AND. ! "}" $ aDadosL[_COMPS_NODE][nC,_COMP_LIST]
	        	  aList := RetSx3Box(aDadosL[_COMPS_NODE][nC,_COMP_LIST],@nInitCBox,@nTam,aDadosL[_COMPS_NODE][nC,_COMP_LEN],AllTrim(aDadosL[_COMPS_NODE][nC,_COMP_DEFAULT]))
	        	  aList := StrTokArr(aDadosL[_COMPS_NODE][nC,_COMP_LIST], ";")

	        	Else
	        		aList := Eval(&(aDadosL[_COMPS_NODE][nC,_COMP_LIST]) )
	        	EndIf

	        	aAdd(aObjects,{CalcFieldSize("C",nTam,0,"@!",aDadosL[_COMPS_NODE][nC,_COMP_TITLE]), 10, .F., .F.} ) //Impar Say
	        	aAdd(aControls,{NIL , NIL, aClone(aList), aDadosL[_COMPS_NODE][nC,_COMP_CTRL_TYPE], nC})

	        	nComps++

	        ElseIf aDadosL[_COMPS_NODE][nC,_COMP_CTRL_TYPE] == "M"
	        	aAdd(aObjects,{CalcFieldSize("C",110,0,"@!",aDadosL[_COMPS_NODE][nC,_COMP_TITLE]),(Int(aDadosL[_COMPS_NODE][nC,_COMP_LEN]/110)+1)*10 , .F., .F.} )//Impar Say
	        	aAdd(aControls, {aDadosL[_COMPS_NODE][nC,_COMP_DEFAULT] , NIL, ,aDadosL[_COMPS_NODE][nC,_COMP_CTRL_TYPE], nC} )
	        	nComps++
	        EndIf
	     ElseIf aDadosL[_COMPS_NODE][nC,_COMP_CTRL_TYPE] == "C"
	     	aAdd(aObjects, {CalcFieldSize("C",Len(aDadosL[_COMPS_NODE][nC,_COMP_TITLE])+5,0,"",aDadosL[_COMPS_NODE][nC,_COMP_TITLE]),10 , .F., .F.}) //Impar Say
	     	aAdd(aControls, {AllTrim(aDadosL[_COMPS_NODE][nC,_COMP_DEFAULT]) ,NIL , aDadosL[_COMPS_NODE][nC,_COMP_TITLE], aDadosL[_COMPS_NODE][nC,_COMP_CTRL_TYPE], nC} )
	     	nComps++
         ElseIf aDadosL[_COMPS_NODE][nC,_COMP_CTRL_TYPE] == "R"
        	aAdd(aObjects,{1,1 , .F., .F.} )//Impar Say
        	aAdd(aControls, {aDadosL[_COMPS_NODE][nC,_COMP_DEFAULT] , NIL, ,aDadosL[_COMPS_NODE][nC,_COMP_CTRL_TYPE], nC} )
        	nComps++

	     EndIf
	Next


	If nComps > 0

		@ 0, 0 TO nRow1, nCol OF oPanel PIXEL
		oPanel2 := TScrollBox():New( oPanel, 0,0,nRow1,nCol)


	   	aPosObj2 := MsObjSize( { 0 , 15 , nRow1 ,nCol, 2, 3,3,3}, aObjects, .T., .F.)
	   	nTam := CalcFieldSize("C",Len(cTitulo), 0, "@!")

		@05, ( nCol/2 - (nTam/2) ) SAY Upper(cTitulo) PIXEL SIZE nTam, 10*2  OF  oPanel2



		@nRow1+3, 0 TO nRow, nCol OF oPanel PIXEL
		oBtn1 := TButton():New( nRow1+8, 05, STR0013,oPanel,{|| WriteControls(@aDadosL,@cLog, cTitulo, oTree, aDados )},55,15,,,.F.,.T.,.F.,,.F.,{ || aDadosL[_EDITED_NODE] },,.F. ) //"Gravar"
		If !aDadosL[_EDITED_NODE]
			oBtn1:Disable()
		EndIf
		oBtn2 := TButton():New( nRow1+8, 05+60, STR0014,oPanel,{||ValidNode(@aDadosL, @cLog, cTitulo, oTree, aDados)},55,15,,,.F.,.T.,.F.,,.F.,{ || aDadosL[_EDITED_NODE] },,.F. ) //"Validar"
		If !aDadosL[_EDITED_NODE]
			oBtn2:Disable()
		EndIf
		oBtn3 := TButton():New( nRow1+8, 05+120, STR0015,oPanel,{|| ExibeLog(cCargo, oTree, aDadosL, oPanel, cIdAmb, aControls, @cLog, aDados) },55,15,,,.F.,.T.,.F.,,.F.,{ || !aDadosL[_VALID_NODE] },,.F. ) //"Log"
		If aDadosL[_VALID_NODE]
			oBtn3:Disable()
		EndIf


		//Detalhes dos campos
		For nC := 1 to nComps
	 		cVariable := "aDadosL["+Str(_COMPS_NODE)+"][aControls[" + Str(nC) + ", 05] , "+Str(_COMP_DEFAULT)+ " ]"

			cGet := "{ |U| Iif(PCOUNT() > 0, (STFSetNodeEdited(.T., @aDadosL),"+cVariable+" := U), "+cVariable+")} "


			Do Case

		 		Case aControls[nC, 04] == "S"

			          tSay():New( aPosObj2[nC, 1],  aPosObj2[nC, 2]  , &("{ || '" + StrTran(aControls[nC, 01], "'", "") + "' } "),oPanel2,,,,,,.T.,,,  ,  )

				Case aControls[nC, 04] == "G"
						cVariable := "'" + cVariable + "'"
						aDadosL[_COMPS_NODE][aControls[nC, 05], _COMP_OBJECT]  := TGet():New( aPosObj2[nC, 1],aPosObj2[nC, 2],&cGEt,oPanel2,aObjects[nC, 01],,aControls[nC, 02],       /*&(cBlkVld)*/,,,, .T.,, .T.,, .T.,            , .F., .F.,, .F., .F. ,aControls[nC, 03],&cVariable,,,,.T.,Empty(aControls[nC, 03]) )

				Case aControls[nC, 04] == "L"

		 			cVariable := "'" + cVariable + "'"
		 			aDadosL[_COMPS_NODE][aControls[nC, 05], _COMP_OBJECT]  := TComboBox():New( aPosObj2[nC, 1],aPosObj2[nC, 2], &cGet,aControls[nC, 03], aObjects[nC, 01], aObjects[nC, 02], oPanel2, ,,       ,,,.T.,,,.F.,,.T.,,,,&cVariable)

		 		Case aControls[nC, 04] == "C"
						cGet := "{ |U| Iif(PCOUNT() > 0, "+cVariable+" := U, "+cVariable+")} "
						cVariable := "'" + cVariable + "'"
						aDadosL[_COMPS_NODE][aControls[nC, 05], _COMP_OBJECT]  := TCheckBox():New(aPosObj2[nC, 1],aPosObj2[nC, 2],aControls[nC, 03],&cGet,oPanel2, aObjects[nC, 01],aObjects[nC, 02],,{|| STFSetNodeEdited(.T., @aDadosL)},,,,,,.T.,,,)


				Case aControls[nC, 04] == "M"
					aDadosL[_COMPS_NODE][aControls[nC, 05], _COMP_OBJECT]  := 	TMultiGet():New(aPosObj2[nC, 1],aPosObj2[nC, 2],&cGet,oPanel2,;
										aObjects[nC, 01],aObjects[nC, 02],/*oFont*/,.F.,;
										/*nClrFore*/,/*nClrBack*/,/*oCursor*/,.T.,;
										/*cMg*/,.T.,,/*lCenter*/,;
										/*lRight*/,.F.,,/*bChange*/,;
										,.F., .T.)

				Case aControls[nC, 04] == "R"
					
					cNomeRot := Substr(aDadosL[_COMPS_NODE][aControls[nC, 05], _COMP_NAME], 1, At("(", aDadosL[_COMPS_NODE][aControls[nC, 05], _COMP_NAME]) -1)
					
					If FindFunction(AllTrim(cNomeRot := cNomeRot)) 
						STFSetNodeEdited(.T., @aDadosL)
						//cVariable := "aDadosL["+Str(_COMPS_NODE)+"][aControls[" + Str(nC) + ", 05] , "+Str(_COMP_NAME)+ " ]"

						Eval(&("{ || "+aDadosL[_COMPS_NODE][aControls[nC, 05], _COMP_NAME]+ " }"))
						oBtn2:Refresh()
      				Else
      					MsgStop(STR0016 + cNomeRot) //"Função nao encontrada no repositório "
                    EndIf
				EndCase
			Next

	eLSE
		@ 0, 0 TO  nRow, nCol OF oPanel PIXEL
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} LoadValue
Função para carregar o valor do componente
@param aComp	     Definição do Componente
@author  Varejo
@version P11.8
@since   26/04/2013
@return  aComp       Componente com o valor carregado
@obs
@sample
/*/
//-------------------------------------------------------------------
Static Function LoadValue(aComp)
Local aAreaX := NIL       //WorkArea da Tabela
Local cChave := ""        //Chave da Tabela
Local cCompl := ""		  //tipo do Componente + Nome

	DEFAULT aComp	:= {}    
	
	If Len(aComp) > 0
		cCompl := RetCompType(aComp[_COMP_TYPE]) + space(1) + aComp[_COMP_NAME]  //tipo do Componente + Nome      
		
		aComp[_COMP_CTRL_TYPE] := "G" //Get
		Do Case
		Case aComp[_COMP_TYPE] == _PARAMETRO
	
				cChave := PadR( AllTrim(aComp[_COMP_NAME]), Len(SX6->X6_VAR))
				aAreaX := SX6->(GetArea())
	
	
				If !SX6->(DbSeek(cFilAnt + cChave))  //4
					If !SX6->(DbSeek(cFil3 + cChave))  //3
						If !SX6->(DbSeek(cFil2 + cChave))  //2
							SX6->(DbSeek(cFil1 + cChave)) //1
						EndIf
					EndIf
	
				EndIf
	
	
				If SX6->(Found())
					If Empty(aComp[_COMP_TITLE])
				   		aComp[_COMP_TITLE] := SX6->(AllTrim(AllTrim(X6Descric()) + " " + X6Desc1() + X6Desc2()))
		            EndIf
					If Empty(aComp[_COMP_FIELD_TYPE])
						aComp[_COMP_FIELD_TYPE] := SX6->X6_TIPO
					EndIf
					aComp[_COMP_DEFAULT] := GetMv(aComp[_COMP_NAME])
				Else
					aComp[_COMP_DEFAULT] := SuperGetMv(aComp[_COMP_NAME], .t., aComp[_COMP_DEFAULT])
				EndIf
	
				RestArea(aAreaX)
	
	
			If Empty(aComp[_COMP_LEN])
				aComp[_COMP_LEN] := Len(SX6->X6_VAR)
			EndIf
	
		Case aComp[_COMP_TYPE] == _ARQUIVO_INI
				aComp[_COMP_KEY] := Alltrim(aComp[_COMP_KEY])
				aComp[_COMP_NAME] := AllTrim(aComp[_COMP_NAME])
				aComp[_COMP_DEFAULT] := GetPvProfString(aComp[_COMP_KEY], aComp[_COMP_NAME], aComp[_COMP_DEFAULT], IIF( aComp[_COMP_INITYPE]  == "1" , GetAdv97(), GetClientDir()+ aComp[_COMP_TABLE_FILE]))
	
		   	    If Empty(aComp[_COMP_LEN])
		   			aComp[_COMP_LEN] := Max(60, Len(aComp[_COMP_DEFAULT]))
		   		EndIf
		   		aComp[_COMP_DEFAULT] := PadR(  aComp[_COMP_DEFAULT], aComp[_COMP_LEN])
	
		   		If Empty(aComp[_COMP_FIELD_TYPE])
					aComp[_COMP_FIELD_TYPE] := "C"
				EndIf
	
		Case aComp[_COMP_TYPE] == _CAMPO
			 If Empty(aComp[_COMP_LEN]) .OR. ;
			 	Empty(aComp[_COMP_DEFAULT]) .OR. ;
			 	Empty(aComp[_COMP_TITLE]) .OR. ;
			 	Empty(aComp[_COMP_F3])  .OR. ;
			 	Empty(aComp[_COMP_FIELD_TYPE]) .OR.;
			 	Empty(aComp[_COMP_VALID])
	
			 	aAreaX := SX3->(GetArea())
			 	SX3->(DbSetOrder(02))
			 	cChave := PadR(aComp[_COMP_NAME], Len(SX3->X3_CAMPO))
			 	If SX3->(DbSeek(cChave))
			 	    If Empty(aComp[_COMP_TITLE])
			 	    	aComp[_COMP_TITLE] := SX3->(X3Titulo())
			 	    EndIf
			 	    If Empty(aComp[_COMP_DEFAULT])
			 	    	aComp[_COMP_DEFAULT] := &(SX3->X3_RELACAO)
			 	    EndIf
			 	    If Empty(aComp[_COMP_LEN])
			 	    	aComp[_COMP_LEN] := SX3->X3_TAMANHO
			 	    EndIf
			 	    If Empty(aComp[_COMP_F3])
			 	    	aComp[_COMP_F3] := SX3->X3_F3
			 	    EndIf
			 	    If Empty(aComp[_COMP_LIST])
			 	    	aComp[_COMP_LIST] := SX3->(X3CBox())
			 	    EndIf
			 	    If Empty(aComp[_COMP_FIELD_TYPE])
			 	    	aComp[_COMP_FIELD_TYPE] := SX3->X3_TIPO
			 	    EndIf  
			 	    
			 	    If AllTrim(SX3->X3_TIPO) == "N" .AND. SX3->X3_DECIMAL > 0
			 	    	aComp[_COMP_INITYPE] := AllTrim(Str(SX3->X3_DECIMAL))
			 	    EndIf
	
			 	EndIf
			 EndIf
			 	RestArea(aAreaX)
	
		 	//Carrega o Valor do Campo
		 	If !Empty(aComp[_COMP_TABLE_FILE]) .AND. ;
		 		!Empty(aComp[_COMP_INDEX] ) .AND. ;
		 		!Empty(aComp[_COMP_KEY]) .AND. ;
		 		(aComp[_COMP_TABLE_FILE])->(FieldPos(aComp[_COMP_NAME])) > 0
	
		 		aAreaX := (aComp[_COMP_TABLE_FILE])->(GetArea())
	
		 			(aComp[_COMP_TABLE_FILE])->(DbSetOrder(aComp[_COMP_INDEX]))
	
		 			If (aComp[_COMP_TABLE_FILE])->(DbSeek(&(aComp[_COMP_KEY])))
		 				If Empty(aComp[_COMP_POSICA])
		 					aComp[_COMP_DEFAULT] := (aComp[_COMP_TABLE_FILE])->(FieldGet(FieldPos(aComp[_COMP_NAME])))
		 				ElseIf aComp[_COMP_POSICA] <= Len((aComp[_COMP_TABLE_FILE])->(FieldGet(FieldPos(aComp[_COMP_NAME]))))
		 					aComp[_COMP_DEFAULT] := Substr((aComp[_COMP_TABLE_FILE])->(FieldGet(FieldPos(aComp[_COMP_NAME]))), aComp[_COMP_POSICA], 1)
		 				EndIf
		 			Else
		 				If Empty(aComp[_COMP_DEFAULT])
		 					aComp[_COMP_DEFAULT] := CriaVar(aComp[_COMP_NAME])
		 				EndIf
		 			EndIf
	
		 		Restarea(aAreaX)
		 	EndIf
	
		 	If (aComp[_COMP_TABLE_FILE])->(FieldPos(aComp[_COMP_NAME])) = 0
		 		aComp[_COMP_CTRL_TYPE] := "X"
		 	EndIf
	
		EndCase
	
		If aComp[_COMP_TYPE] <> _ROTINA //rotina sómente macro-executa
	
			If Empty(aComp[_COMP_FIELD_TYPE])
				aComp[_COMP_FIELD_TYPE] := ValType(aComp[_COMP_DEFAULT])
			EndIf
	
			If !Empty(aComp[_COMP_LIST])
	
				aComp[_COMP_CTRL_TYPE] := "L"
	
			ElseIf aComp[_COMP_FIELD_TYPE] = "L"
				aComp[_COMP_CTRL_TYPE] := "C" //CheckBox
			ElseIf aComp[_COMP_LEN] > 60
	
				aComp[_COMP_CTRL_TYPE] := "M"
			EndIf
	
			If !Empty(aComp[_COMP_F3]) .AND. Empty(aComp[_COMP_DEFAULT])
	
				aComp[_COMP_DEFAULT] := space(aComp[_COMP_LEN])
			EndIf
	
		Else
	
			aComp[_COMP_CTRL_TYPE] := "R"
		EndIf
	
		If Empty(aComp[_COMP_TITLE])
	
			aComp[_COMP_TITLE] := "[" + AllTrim(cCompl)+"]"
		Else
	
			aComp[_COMP_TITLE] := AllTrim(aComp[_COMP_TITLE]) + space(1) + "[" + AllTrim(cCompl)+"]"
		EndIf
	
	EndIf

Return aComp


//-------------------------------------------------------------------
/*/{Protheus.doc} STFSetNodeEdited
Muda o estado do nó para editado
@param lEdit	 Nó Editado?
@param aDadosL   Nó de Posicionamento
@author  Varejo
@version P11.8
@since   26/04/2013
@return  lValid   Se Valido, retorna True
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STFSetNodeEdited(lEdit, aDadosL)
	DEFAULT aDadosL := {}
	DEFAULT lEdit := .T.   //No editado?

	If Len(aDadosL) >= _EDITED_NODE
		aDadosL[_EDITED_NODE] := lEdit
	EndIf

Return lEdit


//-------------------------------------------------------------------
/*/{Protheus.doc} ValidNode
Muda o estado do nó para editado
@param aDadosL   Nó de Posicionamento
@param cLog	   	 Resultado da Validação
@param cTitulo	 Título do No
@param oTree	 Objeto da arvore
@param aDados	Array com os nós
@param lRetFatherNode Retorna os nós pais?
@author  Varejo
@version P11.8
@since   26/04/2013
@return  lValid   Se Valido, retorna True
@obs
@sample
/*/
//-------------------------------------------------------------------
Static Function ValidNode(aDadosL, cLog, cTitulo, oTree, aDados, lRetFatherNode)
Local lValid := .T.  //Nó valido
Local nC 	 := 0                     //Variável contadora
Local nCampos := Len(aDadosL[_COMPS_NODE])  //Quantidade de linhas
Local bValid := NIL                         //Bloco de validação
Local cLog2	  := ""                         //Log
Local nNivel := 0               //Nível do nó
Local cEst   := cLG_CODIGO
Local cLgTmp := "" //Variável temporária de Log


	DEFAULT aDadosL := {}
	DEFAULT cLog	:= ""
	DEFAULT cTitulo	:= ""
	DEFAULT oTree	:= NIL
	DEFAULT aDados	:= {}
	DEFAULT lRetFatherNode := .T. //Retorna os nós pais        
	
	If ValType(oTree) == "O"
		nNivel := oTree:Nivel()               //Nível do nó
    EndIf
    
    If nCampos > 0

		If aDadosL[_EDITED_NODE] //No alterado, então valida
		    //cRIA TODAS AS VARIAVEIS
		    aEval( aDadosL[_COMPS_NODE], { |aComp| IIF(aComp[_COMP_TYPE] <> _ROTINA, &("M->"+aComp[_COMP_NAME]) := aComp[_COMP_DEFAULT],) }  )
	
			For nC := 1 to nCampos
				If !Empty(bValid := aDadosL[_COMPS_NODE][nC , _COMP_VALID]) .AND. ;
					ValType(bValid) == "B"
					cLgTmp := ""
					If  !Eval(bValid, aDadosL[_COMPS_NODE][nC , _COMP_DEFAULT])
						cLog += CRLF + space(nNivel*5) + "- "+ aDadosL[_COMPS_NODE][nC, _COMP_TITLE]  +;
									   				STR0017 + cValToChar(aDadosL[_COMPS_NODE][nC , _COMP_DEFAULT]) + "]" + cLgTmp //" Valor incorreto ["
						lValid := .F.
					Else
						cLog += CRLF + space(nNivel*5) + "- "+ aDadosL[_COMPS_NODE][nC, _COMP_TITLE]  +;
									   				STR0018 + cValToChar(aDadosL[_COMPS_NODE][nC , _COMP_DEFAULT]) + "]" + cLgTmp //" Valor correto ["
	
					EndIf
				Else
					cLog += CRLF + space(nNivel*5) + "- "+ aDadosL[_COMPS_NODE][nC, _COMP_TITLE]  +;
									   				STR0019 + cValToChar(aDadosL[_COMPS_NODE][nC , _COMP_DEFAULT]) + "]" //" Não existe validação para este componente. Conteudo["
	
				EndIf
	
			Next
	
		    aEval( aDadosL[_COMPS_NODE], { |aComp| IIF(aComp[_COMP_TYPE] <> _ROTINA, &("M->"+aComp[_COMP_NAME]) := NIL,) }  )
	
			If !Empty(aDadosL[_VALID_FUNCTION])
				bValid := TransLateParameters(aDadosL[_VALID_FUNCTION])
				lValid := Eval( &("{ || " + bValid +"}"))  .AND. lValid
				cLog := cLog + CRLF + cLog2
			EndIf
		Else
			cLog := CRLF + space(nNivel*5) + STR0020 //"- Componentes deste nó não foram editados, portanto não serão validados"
	
		EndIf
	
		If lRetFatherNode
			cLog := RetFatherNodes(aDadosL[_CODE_NODE], aDados, nNivel) + cLog
		Else
			cLog := space(5*(nNivel-1))+ cTitulo + cLog
		EndIf
	
		If aDadosL[_EDITED_NODE]
			If !lValid
				oTree:ChangeBmp(IF(!aDadosL[_IS_FATHER], "CANCEL", "FOLDER7"),IF(!aDadosL[_IS_FATHER], "CANCEL", "FOLDER8"),,, aDadosL[_CODE_NODE] )
			Else
				//Muda o controle para ok
				oTree:ChangeBmp(IF(!aDadosL[_IS_FATHER], "PCOFXOK","FOLDER10") , IF(!aDadosL[_IS_FATHER],"PCOFXOK","FOLDER11"),,, aDadosL[_CODE_NODE])
			EndIf
			aDadosL[_VALID_NODE] := lValid
		EndIf
		//REALIZAR A VALIDAÇÃO DE NÓS PREDECESSORES
	 
	 EndIf

Return lValid


//-------------------------------------------------------------------
/*/{Protheus.doc} RetCompType
Função para retornar a descrição do tipo do componente
@param cType	 Tipo do componente
@author  Varejo
@version P11.8
@since   26/04/2013
@return  cType   Descrição do Componente
@obs
@sample
/*/
//-------------------------------------------------------------------
Static Function RetCompType(cType)
Local nPos := 0    //Posicao do array
Local aTypes := { {_PARAMETRO, STR0021},; //"Parâmetro"
                  {_ARQUIVO_INI, STR0022},; //"Arquivo de Configurações"
		          {_CAMPO, STR0023},; //"Campo"
		          {_ROTINA, STR0024}} //"Rotina"

	DEFAULT cType := ""
	If (nPos := aScan(aTypes, {|c| c[1] == cType})) > 0
		cType := aTypes[nPos, 2]
	EndIf

Return cType

//-------------------------------------------------------------------
/*/{Protheus.doc} TransLateParameters
Função para traduzir os parâmetros
@param cFunction	 Função a ser traduzida
@author  Varejo
@version P11.8
@since   26/04/2013
@return  cFunction	 Função traduzida
@obs
@sample
/*/
//-------------------------------------------------------------------
Static Function TransLateParameters(cFunction)

	DEFAULT cFunction := ""

	cFunction := StrTran(cFunction , "__NODE_CONTROLS","aControls")
	cFunction := StrTran(cFunction , "__NODE_DATA","aDadosL")
	cFunction := StrTran(cFunction , "__NODE_LOG","@cLog2")

Return cFunction


//-------------------------------------------------------------------
/*/{Protheus.doc} ReturnKey
Função para retornar as chaves da tabela
@param uCompKey	 Valor da Chave
@param cKey	     Composição da chave
@author  Varejo
@version P11.8
@since   26/04/2013
@return  aRet    Array bidimensional contendo o nome e conteúdo do campo
@obs
@sample
/*/
//-------------------------------------------------------------------
Static Function ReturnKey(uCompKey, cKey)
       Local aCampos := {}
       Local nC := 0
       Local nPos := 0
       Local aRet := {}
       Local nCampos := 0

	DEFAULT uCompKey := NIL
	DEFAULT cKey	 := ""

	aCampos := StrTokArr(cKey, "+")
	nCampos := Len(aCampos)
	For nC := 1 To nCampos

		If (nPos := At(aCampos[nC], "(")) > 0 //Existe função?
			aCampos[nC] := AllTrim(Left(aCampos[nC, nPos-1]))
			If (nPos := At(aCampos[nC], ",")) > 0  .OR. (nPos := At(aCampos[nC], ")")) > 0
				aCampos[nC] := AllTrim(Left(aCampos[nC, nPos-1]))

			EndIf
		EndIf
		If FieldPos(aCampos[nC]) == 0
			aRet := NIL
			Exit
		EndIf

		//DÁ um sustrs baseado na  chave
		If ValType(uCompKey) <> "C"  .OR. nC == nCampos
			aAdd(aRet, {aCampos[nC], uCompKey})
		Else
			nPos := TamSx3(aCampos[nC])[1]
			aAdd(aRet, {aCampos[nC], Left(uCompKey, nPos)})
			uCompKey := Substr(uCompKey, nPos+1)
		EndIf
	Next

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ReleaseChildren
Função para Liberar os componentes do nó, incluindo seus filhos
@param cIdAmb    Código do Ambiente
@param cCodeNode Nó
@param aDados    Array dos nós
@param oTree     Arvore
@param lSorted   Ordenação
@author  Varejo
@version P11.8
@since   26/04/2013
@return  NIL
@obs
@sample
/*/
//-------------------------------------------------------------------
Static Function ReleaseChildren(cIdAmb, cCodeNode, aDados, oTree, lSorted)
   Local nPos := 0     //Posicao do nó
   Local nTamDados := 0                                  //Tamanho do array

   Local lSortedMain := .F. //ordenado na principal

   DEFAULT cIdAmb := ""
   DEFAULT cCodeNode := ""
   DEFAULT aDados := {}
   DEFAULT oTree := NIL
   DEFAULT lSorted := .F. //Array não ordenado
   

	nPos := aScan(aDados, {|x| x[_CODE_NODE] == cCodeNode})     //Posicao do nó
  	nTamDados := Len(aDados)                                   //Tamanho do array

   If  nPos > 0
   		If !aDados[nPos, _IS_FATHER]
   			STFSetNodeEdited( .F., @aDados[nPos])
   			aDados[nPos, _VALID_NODE] := .T.
   			oTree:ChangeBmp("SUMARIO","SUMARIO",,,cCodeNode )
   		   //	aEval( aDados[nPos,_COMPS_NODE], { |aDadosL| IIF(aDadosL[_COMP_TYPE] <> _ROTINA, &("M->"+AllTrim(aDadosL[_COMP_NAME])) := NIL ,)})
   			aDados[nPos,_COMPS_NODE] := {}

   		Else
   			//Ordena pelo pai
   			If !lSorted
   				aSort( aDados,,, {|x, y| x[_FATHER_NODE] + Str(x[_ORDER_NODE]) + x[_CODE_NODE] < y[_FATHER_NODE] + Str(y[_ORDER_NODE]) + y[_CODE_NODE]})
            	lSorted := .T.
            	lSortedMain := .T.
            EndIf
            nPos :=  aScan(aDados, {|x|  x[_FATHER_NODE] ==  cCodeNode })
            While nPos > 0 .AND. nPos <= nTamDados .AND. aDados[nPos,_FATHER_NODE] == cCodeNode
            	If Empty(aDados[nPos,_ENVIRONMENT_NODE]) .OR. cIdAmb $  aDados[nPos,_ENVIRONMENT_NODE]
            		ReleaseChildren(cIdAmb, aDados[nPos, _CODE_NODE], @aDados, @oTree, lSorted)
            	EndIf
            	nPos++
            EndDo
            //Volta a ordem para os filhos
   			If lSortedMain
   				aSort( aDados,,, {|x, y| x[_CODE_NODE] <  y[_CODE_NODE]}) //Volta a ordem para os filhos
   				nPos := aScan(aDados, {|x| x[_CODE_NODE] == cCodeNode})
   				oTree:ChangeBmp("FOLDER5","FOLDER6",,,cCodeNode )
   				aDados[nPos,_COMPS_NODE] := {}
   			EndIf
   		EndIf
   EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} SearchNode
Função para busca do Nó

@param cSearchNode  Código do Ambiente
@param oTree        Árvore
@param aDados       Array dos nós
@param cIdAmbiente  Codigo do Ambiente
@param oPanel       Objeto Panel
@param oDlg         Janela
@param cLog         Log
@author  Varejo
@version P11.8
@since   26/04/2013
@return  NIL
@obs
@sample
/*/
//-------------------------------------------------------------------
Static Function SearchNode(cSearchNode, oTree, aDados,  cIdAmbiente, oPanel, oDlg, cLog)
Local aArea := GetArea()
Local aAreaMF7 := MF7->(GetArea())

	DEFAULT cSearchNode := ""
	DEFAULT oTree 		:= NIL
	DEFAULT aDados		:= {}
	DEFAULT cIdAmbiente	:= ""
	DEFAULT oPanel 		:= NIL
	DEFAULT oDlg		:= NIL
	DEFAULT cLog		:= ""


	MF7->(DbSetFilter( { || MF7_FILIAL == xFilial() .AND. (Empty(MF7_ENVIRO) .OR. cIdAmbiente $ MF7_ENVIRO) .AND. AllTrim(Upper(cSearchNode)) $ AllTrim(Upper(FwNoAccent(MF7_DESCR)))}, "MF7_FILIAL == xFilial() .AND. (Empty(MF7_ENVIRO) .OR. cIdAmbiente $ MF7_ENVIRO) .AND. AllTrim(Upper(cSearchNode)) $ AllTrim(Upper(FwNoAccent(MF7_DESCR)))"))
	MF7->(DbGoTop())

	If MF7->(!Eof())  .AND. oTree:GetCargo() <> MF7->MF7_NODE

		oTree:TreeSeek("")
		cNode := MF7->MF7_NODE
		If oTree:TreeSeek(MF7->MF7_NODE) //Posiciona no topo e procura
			ActionClick(oTree:GetCargo(), oTree,  @aDados,  cIdAmbiente, @oPanel, @oDlg, @cLog)
		EndIf
	EndIf

	MF7->(DbClearFilter())
	RestArea(aAreaMF7)
	RestArea(aArea)

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} BuildList
Função para Reconstrução do nó
@param cSearchNode  Código do Ambiente
@param oTree		Objeto da árvore
@param aDados		Itens da árvore
@param cIdAmbiente  Codigo do Ambiente editado
@param nTamNode		Tamanho do nó
@param oDlg			Janela
@param oPanel		Painel
@param cLog			Variavel de Log
@param cLG_CODIGO	Codigo da estação alterado
@param aCoord		Array de coordenadas da Tree
@param nTamSX3		Tamanho do Campo descrição do nó
@author  Varejo
@version P11.8
@since   26/04/2013
@return  NIL
@obs
@sample
/*/
//-------------------------------------------------------------------
Static Function BuildList(oTree, aDados, cIdAmbiente, nTamNode, oDlg, oPanel, cLog, cLG_CODIGO, aCoord, nTamSX3)

	DEFAULT oTree := NIL
	DEFAULT cIdAmbiente := ""
	DEFAULT nTamNode := 0
	DEFAULT oDlg := NIL
	DEFAULT oPanel:= NIL
	DEFAULT cLog	:= ""
	DEFAULT cLG_CODIGO := ""
	DEFAULT aCoord := {}
	DEFAULT nTamSX3 := 0



	If cIdAmb <> cIdAmbiente .OR. cEsta <> cLG_CODIGO
		aSort( aDados,,, {|x, y| x[_FATHER_NODE] + Str(x[_ORDER_NODE]) + x[_CODE_NODE] < y[_FATHER_NODE] + Str(y[_ORDER_NODE]) + y[_CODE_NODE]})

		If cIdAmb <> cIdAmbiente
			aDados := {}
			LoadData(@aDados, cIdAmbiente)
		EndIf
		BuildTree(@oTree, @aDados, cIdAmbiente, @oPanel, oDlg, @cLog, aCoord, nTamSX3)

		If Len(aDados) > 1 .AND. oTree:TreeSeek(aDados[01, _CODE_NODE] )

		   	If cEsta == cLG_CODIGO
				cIdAmb := cIdAmbiente  
		  	 	ActionClick(oTree:GetCargo(), oTree,  @aDados, cIdAmbiente,  @oPanel, @oDlg, @cLog)
		   	Else
		  		cEsta := cLG_CODIGO 
		   	   	ActionClick(oTree:GetCargo(), oTree,  @aDados, cIdAmbiente,  @oPanel, @oDlg, @cLog)
		   	EndIf

		 EndIf

	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ExibeLog
Função para Exibição de LOG
@param cCargo Id do No
@param oTree  Objeto da Arvore
@param aDadosL //Nó atual
@param oPanel  Objeto Paneç
@param cIdAmb Codigo do Ambiente
@param aControls Array de Controles
@param cLog		Log
@param aDados  Nos da arvore
@author  Varejo
@version P11.8
@since   26/04/2013
@return  NIL
@obs
@sample
/*/
//-------------------------------------------------------------------
Static Function ExibeLog(cCargo, oTree, aDadosL, oPanel, cIdAmb, aControls, cLog, aDados)
Local nRow		:= 0  							//Linha do Log
Local nCol		:= 0    						//coluna do Log
Local aObjects := {}                            //Objetos
Local aPosObj2 := {}                            //Coordenadas do Objeto
Local nTam := 0                            		//Tamanho
Local cTitulo := ""							  //titulo da Janela
Local nRow1 := 0                        		//Linha do painel 2
Local oPanel2 := NIL                           //Painel 2
Local oBtn1 := NIL                             //botão 1
Local oBtn2 := NIL                             //Botão 2
Local oBtn3 := NIL                             //botão 3
Local cFile := ""                              //Arquivo de Gravação

	DEFAULT cCargo := ""
	DEFAULT oTree  := NIL
	DEFAULT aDadosL := {}
	DEFAULT oPanel  := NIL
	DEFAULT cIdAmb  := ""
	DEFAULT aControls := {}
	DEFAULT cLog	:= ""
	DEFAULT aDados := {}       
	
	If Valtype(oPanel) == "O"
		nRow		:= Int((oPanel:nHeight ) / 2)   //Linha do Log
		nCol		:= Int((oPanel:nWidth ) / 2)    //coluna do Log
		nRow1 := nRow-29                         //Linha do painel 2

	EndIf 
	
	If Len(aDadosL) >= _DESCRIPTION_NODE
		cTitulo := STR0025 +aDadosL[_DESCRIPTION_NODE] //"Log de Validação - "
	EndIf


	@ 0, 0 TO nRow1, nCol OF oPanel PIXEL
	oPanel2 := TScrollBox():New( oPanel, 0,0,nRow1,nCol)
	nTam := CalcFieldSize("C",Len(cTitulo),0, "@!")

	@05, ( nCol/2 - (nTam/2) ) SAY Upper(cTitulo) PIXEL SIZE nTam, 10  OF  oPanel2


	aObjects := { {CalcFieldSize("C",110,0),nRow1-5, .F., .F.} }
	aPosObj2 := MsObjSize( { 0 , 15 , nRow1 ,nCol, 2, 3,3,3}, aObjects, .T., .F.)


	TMultiGet():New(aPosObj2[1, 1],aPosObj2[1, 2],{|| Iif(PCOUNT() > 0, cLog := U,cLog)} ,oPanel2,;
								aObjects[1, 01],aObjects[1, 02],/*oFont*/,.T.,;
								/*nClrFore*/,/*nClrBack*/,/*oCursor*/,.T.,;
								/*cMg*/,.T.,,/*lCenter*/,;
								/*lRight*/,.T.,,/*bChange*/,;
								,.F., .T.)


	@nRow1+3, 0 TO nRow, nCol OF oPanel PIXEL

	oBtn1 := TButton():New( nRow1+8, 05, STR0013,oPanel,{|| (cFile:=cGetFile(STR0026,""),If(cFile="",.t.,MemoWrite(cFile,cLog))) },55,15,,,.F.,.T.,.F.,,.F.,{ || aDadosL[_EDITED_NODE] },,.F. ) //"Gravar"###"Arquivos Texto (*.TXT) |*.txt|"
	If !aDadosL[_EDITED_NODE]
		oBtn1:Disable()
	EndIf
	oBtn2 := TButton():New( nRow1+8, 05+60, STR0027,oPanel,{||SendMail(cTitulo, cLog) },55,15,,,.F.,.T.,.F.,,.F.,{ || aDadosL[_EDITED_NODE] },,.F. ) //"Enviar e-mail"
	oBtn3 := TButton():New( nRow1+8, 05+120, STR0011,oPanel,{|| MontaPanel(cCargo, oTree, aDadosL, oPanel, cIdAmb, {}, aDados, cLog) },55,15,,,.F.,.T.,.F.,,.F.,{ || !aDadosL[_VALID_NODE] },,.F. ) //"Fechar"

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} RetFatherNodes
Função para retornar os nós Pais
@param cCargo Codigo do No
@param aDados Nos da arvore
@param nNivel Nivel da Arvore
@author  Varejo
@version P11.8
@since   26/04/2013
@return  cRetorno Codigo do No Pai
@obs
@sample
/*/
//-------------------------------------------------------------------
Static Function RetFatherNodes(cCargo,aDados, nNivel)
	 Local nPos := 0 //Posicao do nó pai
	 Local cRetorno  := ""
	                                      //Retorno da função
	 DEFAULT cCargo := ""
	 DEFAULT aDados := {}
	 DEFAULT nNivel := 1  
	 
	 nPos := aScan(aDados, {|l| l[_CODE_NODE] == cCargo})

	 If nPos > 0
		 nNivel := nNivel -1

		 cRetorno := space(nNivel*5) + aDados[nPos,_DESCRIPTION_NODE]

	     If !Empty(aDados[nPos,_FATHER_NODE])
	     	cRetorno := RetFatherNodes(aDados[nPos,_FATHER_NODE], aDados, nNivel) + CRLF + cRetorno
	     EndIf
     EndIf

Return  cRetorno


//-------------------------------------------------------------------
/*/{Protheus.doc} ShowMainLog
Função para retornar os Log da Janela Principal
@param cCargo Codigo do No
@param oTree  Objeto Arvore
@param oPanel Objeto Panel
@param cIdAmb Codigo do Ambiente
@param cLog   Codigo do Log
@param aDados Array de Dados
@author  Varejo
@version P11.8
@since   26/04/2013
@return  NIL
@obs
@sample
/*/
//-------------------------------------------------------------------
Static Function ShowMainLog(cCargo, oTree, oPanel, cIdAmb, cLog, aDados)

	 Local nPos := 0  //Posicao do Log

	 DEFAULT cCargo := ""
	 DEFAULT oTree := NIL
	 DEFAULT oPanel := NIL
	 DEFAULT cIdAmb := ""
	 DEFAULT cLog := ""
	 DEFAULT aDados := {}

	 If (nPos := aScan(aDados, {|l| l[_CODE_NODE] == cCargo})) > 0

	 	ExibeLog(cCargo, oTree, aDados[nPos], oPanel, cIdAmb, {}, @cLog, aDados)
     EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} SendMail
Função para enviar e-mail do log de validação
@param cAssunto Assunto e-mail
@param cMsg     Mensagem do e-mail
@author  Varejo
@version P11.8
@since   26/04/2013
@return  lRet  E-mail enviado com sucesso
@obs
@sample
/*/
//-------------------------------------------------------------------
Static Function SendMail(cAssunto, cMsg)
Local oMail  		:= NIL         //Objeto do Service de e-mail
Local oMessage  	:= NIL      //Mensagem
Local nErro 		:= 0           //Erro
Local lRet 			:= .T.          //Retorno de execução
Local cSMTPServer	:= GetMV("MV_RELSERV",,"smtp.servername.com.br")  //SMTP Server
Local cSMTPUser		:= GetMV("MV_RELAUSR",,"minhaconta@servername.com.br") //Usuário de autenticação
Local cSMTPPass		:= GetMV("MV_RELAPSW",,"minhasenha")                   //Senha
Local cMailFrom		:= GetMV("MV_RELFROM",,"minhaconta@servername.com.br")  //Remetente
Local nPort	   		:= GetMV("MV_GCPPORT",,25)                              //Porta
Local lUseAuth		:= GetMV("MV_RELAUTH",,.T.)                             //Autentica?
Local cPara 		:= GetMV("MV_LJEMLAD",,"minhaconta@servername.com.br")  //Destinatário
Local lTLS			:= GetMV("MV_RELTLS ",.F.,.F.)                       //lTS?
Local nTOUT			:= GetMV("MV_RELTIME",.F.,120)					//Time-Out

	DEFAULT cAssunto := ""
	DEFAULT cMsg := ""

	cMsg := StrTran(StrTran(StrTran(StrTran(StrTran(StrTran(cMsg, ";"), "&", "&amp;"), " ", "&nbsp;"), ">", "&gt;"), "<", "&lt;"), CRLF, "<BR>")

	If !lTLS
		//MailSMTPOn
		CONNECT SMTP SERVER cSMTPServer ACCOUNT cSMTPUser PASSWORD cSMTPPass RESULT lRet
		If 	lRet
			SEND MAIL FROM cMailFrom ;
				TO cPara ;
				SUBJECT cAssunto ;
				BODY cMsg;
				ATTACHMENT ;
				RESULT lRet
			If !lRet
				GET MAIL ERROR cMAilError
				ConOut(STR0028 + RTrim(cMAilError)) //"Erro no envio do e-mail "
			EndIf
			DISCONNECT SMTP SERVER
		Else
			GET MAIL ERROR cMAilError
			ConOut(STR0029 +  RTrim(cErro)) //"Erro na conexão:"
		EndIf

	Else

		oMail := TMailManager():New()
		oMail:SetUseTLS(.T.)
		oMail:Init( '', cSMTPServer , cSMTPUser, cSMTPPass, 0, nPort  )
		oMail:SetSmtpTimeOut( nTOUT )
		nErro := oMail:SmtpConnect()

		conout(STR0045+str(nErro,6))   //"Status de Retorno = "

		If lUseAuth
			nErro := oMail:SmtpAuth(cSMTPUser ,cSMTPPass)
			If nErro <> 0
				// Recupera erro ...
				cMAilError := oMail:GetErrorString(nErro)
				DEFAULT cMailError := '***UNKNOW***'
				Conout(STR0030+str(nErro,4)+' ('+cMAilError+')') //"Erro de Autenticacao "
				lRet := .F.
			Endif
		Endif

		if nErro <> 0

			// Recupera erro
			cMAilError := oMail:GetErrorString(nErro)
			DEFAULT cMailError := '***UNKNOW***'
			conout(cMAilError)

			Conout(STR0031+str(nErro,4)) //"Erro de Conexão SMTP "
			oMail:SMTPDisconnect()

			lRet := .F.

		Endif

		If lRet
			oMessage := TMailMessage():New()
			oMessage:Clear()
			oMessage:cFrom	:= cMailFrom
			oMessage:cTo	:= cPara
			oMessage:cSubject	:= cAssunto
			oMessage:cBody		:= cMsg
			nErro := oMessage:Send( oMail )

			if nErro <> 0
				xError := oMail:GetErrorString(nErro)
				Conout(STR0032+str(nErro,4)+" ("+xError+")") //"Erro de Envio SMTP "
				lRet := .F.
			Endif

			oMail:SMTPDisconnect()
			FreeObj(oMessage)
		Endif

		FreeObj(oMail)

	EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} ValidAllNodes
Função para validar todos os nós
@param cIdAmb Codigo do Ambiente
@param cCargo Codigo do No
@param oTree Objeto Arvore
@param aDados Array dos nós
@param lRetFather Retorna a descrição dos nós pais
@param aDadosF    Array dos nós ordenados pelo pai
@param lValid     No valido?
@author  Varejo
@version P11.8
@since   26/04/2013
@return  cRet	 Retorno da descrição do NO
@obs
@sample
/*/
//-------------------------------------------------------------------
Static Function ValidAllNodes(cIdAmb, cCargo, oTree, aDados, lRetFather, aDadosF, lValid)
	Local cTitulo := ""						 //título do no
	Local cRetorno  := ""                   //Retorno da funcao
	Local nPos2 := 0                        //Posicao dos filhos
	Local nTamDados := Len(aDados)          //Tamanho dos Dados
	Local lValChild := .T. 					//Filhos Válidos
	Local nNivel := 0                       //Nivel do No
	Local cRet := ""                        //Retorno
	Local nPos := 0                         //Posico

	DEFAULT cIdAmb := ""
	DEFAULT cCargo := ""
	DEFAULT oTree  := NIL
	DEFAULT aDados := {}
	DEFAULT lRetFather := .T.
	DEFAULT aDadosF	:= {}
	DEFAULT lValid := .T.

    nPos := aScan(aDados, { | x| x[_CODE_NODE] == cCargo })
    cTitulo := aDados[nPos, _DESCRIPTION_NODE]

    If Len(aDados[nPos, _COMPS_NODE])  = 0
    	//Carrega os componentes
    	aDados[nPos,_COMPS_NODE] := LoadComp(cCargo, cIdAmb)
    EndIf

	If aDados[nPos, _IS_FATHER]
	   //Retorna os filhos

		If lRetFather
		   	aDadosF := aClone(aDados)
			aSort( aDadosF,,, {|x, y| x[_FATHER_NODE] + Str(x[_ORDER_NODE]) + x[_CODE_NODE] < y[_FATHER_NODE] + Str(y[_ORDER_NODE]) + y[_CODE_NODE]})
	    EndIf


	   If (nPos2 := aScan(aDadosF,{ |x|  x[_FATHER_NODE] == cCargo})) > 0
	   		Do While nPos2  <= nTamDados .AND. aDadosF[nPos2,_FATHER_NODE] == cCargo
	   			If Empty(aDadosF[nPos2,_ENVIRONMENT_NODE]) .OR. cIdAmb $  aDadosF[nPos2,_ENVIRONMENT_NODE]
	   				cRetorno :=  ValidAllNodes( cIdAmb, aDadosF[nPos2,_CODE_NODE],oTree, @aDados, .F., aDadosF, @lValid) + CRLF + cRetorno

		   			lValChild := lValChild .AND. lValid
	   			EndIf
	   			nPos2++
	   		EndDo

	   EndIf
    	oTree:TreeSeek(cCargo)
    	cTitulo := oTree:GetPrompt(.T.)

    	ValidNode(@aDados[nPos] , @cRet, cTitulo, oTree, aDados, lRetFather)

    	If !lValChild
    		aDados[nPos,_VALID_NODE] := .F.
    	EndIf
    	cRetorno := cRet +  CRLF + cRetorno

	Else

		oTree:TreeSeek(cCargo)
		cTitulo := oTree:GetPrompt(.T.)
		ValidNode(@aDados[nPos], @cRet, cTitulo, oTree, aDados, lRetFather)
		cRetorno := cRet +  cRetorno
    EndIf

 	nNivel := oTree:Nivel()

    lValid := aDados[nPos,_VALID_NODE]
   	cRet := cRetorno

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} IniStaticVar
Função para iniciar as variáveis estáticas
@author  Varejo
@version P11.8
@since   26/04/2013
@return  NIL
@obs
@sample
/*/
//-------------------------------------------------------------------
Static Function IniStaticVar()

	cFil3   := FWxFilial("SX6",cFilAnt, "C", "E", "E") //Nivel 3
	cFil2   := FWxFilial("SX6",cFilAnt, "C", "C", "E")// Nivel 2
	cFil1   := FWxFilial("SX6",cFilant, "C", "C", "C") //Nivel 1
	cLG_CODIGO := SLG->(CriaVar("LG_CODIGO") )
	cLG_CODIGO := cEstacao := SLG->(DbGotop(), LG_CODIGO) //Alterar
	cIdAmb	  := IIF(nModulo == 12, "1", "3")
	
	cNodeAnt	  := ""
	oCfgTef := NIL

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} ReleaseStaticVar
Função para retornar os nós Pais
@author  Varejo
@version P11.8
@since   26/04/2013
@return  NIL
@obs
@sample
/*/
//-------------------------------------------------------------------
Static Function ReleaseStaticVar()
//Libera as variáveis de memória
	cFil3   := NIL
	cFil2   := NIL
	cFil1   := NIL
	cLG_CODIGO := NIL
	nIdAmb	  := NIL
	cNodeAnt  := NIL
	cEsta := NIL
	If oCfgTef <> NIL
		oCfgTef := FreeObj(oCfgTef)
	EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} LoadData
Função para retornar os nós
@param aData	Array dos nos
@param cIdAmbiente Codigo do Ambiente
@author  Varejo
@version P11.8
@since   26/04/2013
@return  NIL
@obs
@sample
/*/
//-------------------------------------------------------------------
Static Function LoadData(aData, cIdAmbiente)
Local aArea		:= GetArea()
Local aAreaMF7   := MF7->(GetArea())
Local nTamSx3 := MF7->(TamSx3("MF7_NODE")[1]) //To do tamando do nó

	DEFAULT aData := {}
	DEFAULT cIdAmbiente := ""
	
	
	MF7->(DbSetFilter({|| MF7_FILIAL == xFilial() .AND. (Empty(MF7_ENVIRO) .OR. cIdAmbiente $ MF7_ENVIRO) },"MF7_FILIAL == xFilial() .AND. (Empty(MF7_ENVIRO) .OR. cIdAmbiente $ MF7_ENVIRO)" ))
	MF7->(DbGoTop())
	MF7->(DbSetOrder(2)) //MF7_FILIAL+MF7_FATHER+STR(MF7_ORDER,4)+ MF7_NODE
	
	
	Do While MF7->(!Eof())
		aAdd(aData, {MF7->MF7_FATHER,; //1
					 MF7->MF7_NODE,; //2
					 MF7->MF7_DESCR,; //3
					 MF7->MF7_ORDER,; //4
					 MF7->MF7_ENVIRO,; //5
					 .T.,; //6
					 .F.,; //7
					 MF7->MF7_VALID,; //8
					 ,; //9
					 ,; //10
					 MF7->MF7_TABREC,; //11
					 MF7->MF7_TABINS,; //12
					 MF7->MF7_POSREC,; //13
					 MF7->MF7_FUNREC,;//14
					 {}} ) 	//15
		MF7->(DbSkip())
	EndDo
	
	MF7->(DbClearFilter())
	
	RestArea(aAreaMF7)
	RestArea(aArea)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} WriteControls
Função para gravar os controls do NO
@param aDadosL Dados do No
@param cLog    Log
@param cTitulo Titulo do No
@param oTree   Objeto da arvore
@param aDados  Array dos nos
@author  Varejo
@version P11.8
@since   26/04/2013
@return  NIL
@obs
@sample
/*/
//-------------------------------------------------------------------
Static Function WriteControls(aDadosL, cLog, cTitulo, oTree, aDados)
    Local lValidNode := .T.     //Nó valido?
    Local nC := 0               //Variável
    Local nTam := 0				//Tamano dos controles
    Local lWrite	:= .T.		//Gravou o controle
    Local aArea		:= GetArea() //Workarea anterior
    Local cIdAmb	:= cIdAmb    //Codigo do Ambiente - Variável estática não e visualizada pelo eval
    Local cLG_CODIGO := cLG_CODIGO //Codigo da Estação - Variável estática não e visualizada pelo eval

    DEFAULT aDadosL := {}
    DEFAULT cLog	:= ""
    DEFAULT cTitulo	:= ""
    DEFAULT oTree   := NIL
    DEFAULT aDados 	:= {}

    If aDadosL[_EDITED_NODE]   
    
     	nTam := Len(aDadosL[_COMPS_NODE] )            
		If lValidNode := ValidNode(aDadosL, @cLog, cTitulo, oTree, aDados)


	        If !Empty(aDadosL[_WRITE_FUNCTION])

	        	lWrite :=  Eval(&("{ || " + aDadosL[_WRITE_FUNCTION]+ "}")) //Delega a função de gravação para o nó
	        												//Caso dê errado é responspavel pelo rollback
	        Else
	        	BeginTran()
			        If aDadosL[_RECORD_TABLE_ONCE] //Grava todos os controles de um nó de uma vez
						lWrite := WriteAllCt(@aDadosL[_COMPS_NODE],oTree,aDadosL[_INSERT_TABLE], _COMP_DEFAULT) //Insere o registro de uma tabela, caso o registro ainda não exista
					Else
						For nC := 1 to nTam
							lWrite := lWrite .AND. WriteCrtl(aDadosL[_COMPS_NODE, nC],aDadosL[_INSERT_TABLE], _COMP_DEFAULT)
							If !lWrite
								Exit
							EndIf
						Next
					EndIf
			EndIf

			If Empty(aDadosL[_WRITE_FUNCTION])
              	If lWrite
              		EndTran()
              	Else
              		DisarmTransaction()
              	EndIf
			EndIf

			If lWrite

				aDadosL[_EDITED_NODE] := .F.
				nTam := nC
				//Grava nos dados antigos os valores editados


				aEval(aDadosL[_COMPS_NODE], {|x| x[_COMP_OLDVALUE] := x[_COMP_DEFAULT]})
				If !Empty(aDadosL[_POS_RECORDED])
				     &(aDadosL[_POS_RECORDED])
				EndIf

				oTree:ChangeBmp(IF(!aDadosL[_IS_FATHER], "SUMARIO", "FOLDER5"),IF(!aDadosL[_IS_FATHER], "SUMARIO", "FOLDER6"),,, aDadosL[_CODE_NODE] )


			Else
				If !aDadosL[_RECORD_TABLE_ONCE]
					For nC := 1 to nTam
						lWrite := lWrite .AND. WriteCrtl(aDadosL[_COMPS_NODE, nC],aDadosL[_INSERT_TABLE], _COMP_OLDVALUE)
						If !lWrite
							Exit
						EndIf
					Next
				Else
					WriteAllCt(@aDadosL[_COMPS_NODE],oTree,aDadosL[_INSERT_TABLE], _COMP_OLDVALUE)
				EndIf
				MsgStop(STR0033) //"Problemas na gravação do controle"
			EndIf
	    Else
	    	MsgStop(STR0034) //"Nó inválido.Gravação não permitida."
	    EndIf
	Else
		MsgStop(STR0035) //"Nó não editado.Gravação não realizada"
	EndIf

	RestArea(aArea)

	Return

//-------------------------------------------------------------------
/*/{Protheus.doc} WriteCrtl
Função para gravar o controle
@param aComp  Dados do Componente
@param lInsert Insere novo registro na tabela?
@param nCol    Coluna ser gravada [default/old - rollback]
@author  Varejo
@version P11.8
@since   26/04/2013
@return  lRecorded - Componente gravado com sucesso
@obs
@sample
/*/
//-------------------------------------------------------------------
Static Function WriteCrtl(aComp, lInsert, nCol)
    Local lRecorded := .T.    //Gravado
    Local aArea := GetArea()  //Area anterior

	DEFAULT aComp := {}
	DEFAULT lInsert := .F.
	DEFAULT nCol	:= _COMP_DEFAULT


	Do Case
		Case aComp[_COMP_TYPE] == _PARAMETRO
			PutMv( AllTrim(aComp[_COMP_NAME]), aComp[nCol])


		Case aComp[_COMP_TYPE] == _ARQUIVO_INI

	   		WritePProString(aComp[_COMP_KEY], aComp[_COMP_NAME], aComp[nCol], IIF( aComp[_COMP_INITYPE]  == "1" , GetAdv97(), GetClientDir()+ aComp[_COMP_TABLE_FILE]) )

	Case aComp[_COMP_TYPE] == _CAMPO

	 	    lRecorded := WriteTable(aComp[_COMP_TABLE_FILE], aComp[_COMP_INDEX], lInsert, aComp[_COMP_KEY], {{aComp[_COMP_NAME], aComp[nCol], aComp[_COMP_POSICA]}} )
	EndCase


	RestArea(aArea)

	If lRecorded
		aComp[_COMP_OLDVALUE] := aComp[nCol]
	EndIf



	Return	lRecorded

//-------------------------------------------------------------------
/*/{Protheus.doc} WriteAllCt
Função para gravar todos os campos de uma mesma tabela, conforme configuração do nó
@param aComps Componentes do No
@param oTree  Objeto Arvore
@param lInsert Insere um registro, caso a chave não exista?
@param nCol    Coluna da informação a ser gravada
@author  Varejo
@version P11.8
@since   26/04/2013
@return  lRecorded
@obs
@sample
/*/
//-------------------------------------------------------------------
Static Function WriteAllCt(aComps,oTree,lInsert,nCol)
	Local nC := ""          //Contador do Laço
	Local cTable := ""      //Tabela
	Local nTam := 0			//Tamanho do Campo
	Local lRecorded := .T. //Gravado
	Local aCamposK := {}   //Campos a serem gravados
	Local nIndex := 0		//Indice
	Local cKey := ""		//Chave
	Local cCampo := ""		//Campo
	Local nPos	:= 0		//Posicao do array

	DEFAULT aComps := {}
	DEFAULT oTree  := NIL
	DEFAULT lInsert := .F.
	DEFAULT nCol	:= _COMP_DEFAULT


	aSort(aComps, ,, { | x, y | x[_COMP_TYPE] + x[_COMP_TABLE_FILE]  +  x[_COMP_ID]  + x[_COMP_NAME] + Str(x[_COMP_POSICA]) < y[_COMP_TYPE] + y[_COMP_TABLE_FILE]   +  y[_COMP_ID] + y[_COMP_NAME] + Str(y[_COMP_POSICA]) })
	nTam := Len(aComps)            

	For nC := 1 to nTam
		If aComps[nC, _COMP_TYPE] == _CAMPO
			//Bufferiza os campos da tabela
			If aComps[nC, _COMP_TABLE_FILE] <> cTable

				If !Empty(cTable)
			   		lRecorded := WriteTable(cTable , nIndex , lInsert, cKey, aCamposK )
				EndIf
				aCamposK := {}
				cTable := aComps[nC, _COMP_TABLE_FILE]
				nIndex :=  aComps[nC, _COMP_INDEX]
				cKey := aComps[nC, _COMP_KEY]
				cCampo := ""

				If cCampo <> aComps[nC, _COMP_NAME] .OR. Empty(aComps[nC, _COMP_POSICA])
					aAdd(aCamposK, { aComps[nC, _COMP_NAME],aComps[nC, nCol], aComps[nC, _COMP_POSICA]  } )
					nPos++
					cCampo := aComps[nC, _COMP_NAME]
				Else
					aCamposK[nPos, 02] += aComps[nC, nCol]
					aCamposK[nPos, 03] := 0
				EndIf
			Else
				If cCampo <> aComps[nC, _COMP_NAME] .OR. Empty(aComps[nC, _COMP_POSICA])
					aAdd(aCamposK, { aComps[nC, _COMP_NAME],aComps[nC, nCol], aComps[nC, _COMP_POSICA]  } )
					nPos++
					cCampo := aComps[nC, _COMP_NAME]
				Else
					aCamposK[nPos, 02] += aComps[nC, nCol]
					aCamposK[nPos, 03] := 0
				EndIf
			EndIf
		Else
			If aComps[nC, nCol] <> NIL
				lRecorded :=  lRecorded .AND. WriteCrtl(aComps[nC], lInsert, nCol)
			EndIf
		EndIf


		If !lRecorded
			Exit
		EndIf

	Next
	//ultima tabela
	If !Empty(cTable) .AND. lRecorded
		lRecorded := WriteTable(cTable , nIndex , lInsert, cKey, aCamposK )
	EndIf


	aSort(aComps,  , , {|x,y| x[_COMP_NODE] + x[_COMP_ID] <= y[_COMP_NODE] + y[_COMP_ID] })

Return lRecorded

//-------------------------------------------------------------------
/*/{Protheus.doc} WriteTable
Função para gravar a tabela
@param cTable  Tabela
@param nIndex  Indice
@param lInsert Insere um registro, caso a chave não exista
@param cKey    cChave de busca
@param aCamposK Campos a serem gravados
@author  Varejo
@version P11.8
@since   26/04/2013
@return  lRecorded Registro gravado
@obs
@sample
/*/
//-------------------------------------------------------------------
Static Function WriteTable(cTable, nIndex, lInsert, cKey, aCamposK )
	Local aCampos := {}		//Campos a serem inseridos
	Local aAreaX := {}		//Workarea anterior da tabela
	Local lRecorded := .T.  //Registro inserido?
	Local nC := 0			//Contador
	Local nTam := 0			//Tamanho dos campos
	Local cCampo := ""		//Conteudo do campo 
	


	DEFAULT cTable := ""
	DEFAULT nIndex := 0
	DEFAULT lInsert := .F.
	DEFAULT cKey := ""
	DEFAULT aCamposK := {}


		aAreaX := (cTable)->(GetArea())

 			(cTable)->(DbSetOrder(nIndex))

 			If (cTable)->(DbSeek(&cKey))
 				lRecorded :=  RecLock(cTable, .F.)
 			Else

 				If lInsert

 					aCampos := (cTable)->(ReturnKey(&cKey, IndexKey() )  )
 					If (nTam := Len(aCampos)) > 0
 						If (lRecorded := RecLock(cTable, .T.))
 						//To do: Verificar se não existem campos obrigatórios ou valid de campos
 						For nC := 1 To nTam
 							(cTable)->(FieldPut(FieldPos(aCampos[nC, 1]), aCampos[nC, 2]))
 						Next
 						If cTable == "SLG" .AND. FieldPos("LG_ISPOS") > 0
 							(cTable)->(FieldPut(FieldPos("LG_ISPOS"), IIF(cIdAmb == "3", "1", "2")))
 						EndIf
 					EndIf
 					Else
 						lRecorded := .F.
 					EndIf
 				Else
 					lRecorded := .F.
 				EndIf
 			EndIf

 			If lRecorded
 				//Registro travado, pronto para gravar
 				nTam := Len(aCamposK)
 				For nC := 1 To nTam

 					If Empty(aCamposK[nC, 3] )
 						(cTable)->(FieldPut(FieldPos(aCamposK[nC, 1]), aCamposK[nC, 2]))
 					Else
 						cCampo := (cTable)->(FieldGet(FieldPos(aCamposK[nC, 1])))
	 					If aCamposK[nC, 3] = 1
	 						cCampo := aCamposK[nC, 2] + Substr(cCampo, aCamposK[nC, 3]+1)
	 					ElseIf aCamposK[nC, 3] == Len(cCampo)
	 				   		cCampo := Left(cCampo,aCamposK[nC, 3]-1) + aCamposK[nC, 2]
	 					Else
	 						cCampo := Substr(cCampo, 1, aCamposK[nC, 3]-1) + aCamposK[nC, 2] + Substr(cCampo, aCamposK[nC, 3]+1)
	 					EndIf

 						(cTable)->(FieldPut(FieldPos(aCamposK[nC, 1]), cCampo))
 					EndIf

 				Next
 				(cTable)->(MsUnLock())

 			EndIf

 		Restarea(aAreaX)


Return lRecorded

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildTree
Função para construir a arvore
@param oTree Objeto da arvore
@param aDados Nos da arvore
@param cIdAmbiente Codigo do ambiente
@param oPanel Objeto Panel
@param oDlg Dialogo
@param cLog Log
@param aCoord Coordenadas do No
@param nTamSX3 Tamanho do No
@author  Varejo
@version P11.8
@since   26/04/2013
@return  NIL
@obs
@sample
/*/
//-------------------------------------------------------------------
Static Function BuildTree(oTree, aDados, cIdAmbiente, oPanel, oDlg, cLog, aCoord, nTamSX3)

	DEFAULT oTree := NIL
	DEFAULT aDados := {}
	DEFAUlT oPanel	:= NIL
	DEFAULT oDlg := NIL
	DEFAULT cLog := ""
	DEFAULT aCoord := {}
	DEFAULT nTamSX3 := 0

	If ValType(oTree) == "O"
		oTree := FreeObj(oTree)
	EndIf

	If cIdAmbiente == "3" //POS

		STFStrategyECF()
	    aRet := STFFireEvent(	ProcName(0) ,;		// Nome do processo
	 					"STCheckDLL",;// Nome do evento
	 					{.T.} )
	EndIf


	oTree := DbTree():New(aCoord[1],aCoord[2],aCoord[3],aCoord[4],oDlg,{|| ActionClick(oTree:GetCargo(), oTree, aDados,  cIdAmbiente, @oPanel, oDlg, @cLog) },,.T.)
	                //Coordenadas do Painel)
	oTree:SetScroll( 1, .t. ) //Horizontaç
	oTree:SetScroll( 2, .T.)   //Vertical

	oTree:BeginUpdate()

		LoadTree(oDlg, oTree, cIdAmbiente, space(nTamSx3), aDados)

	oTree:EndTree()
	oTree:EndUpdate()

	//Ordena pelo código
	aSort( aDados,,, {|x, y| x[_CODE_NODE] <  y[_CODE_NODE]})
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} InsertData
Função para retornar os nós Pais
@author  Varejo
@version P11.8
@since   26/04/2013
@return  lRecorded Registro inserido
@obs
@sample
/*/
//-------------------------------------------------------------------
Static Function InsertData()
	Local aArea := GetArea()         //Workarea Anterior
	Local aAreaMF7 := MF7->(GetArea()) //WorkArea MF7
	Local aAreaMF8 := MF8->(GetArea()) //WorkArea MF8
	Local nConta := 0                  //Contador
	Local aData := {}                  //Array de processos/nós
	Local nC := 0                      //Contador
	Local cLastCmp := ""               //Ultimo nó do usuário
	Local lRecorded := .T.             //Registros atualizados
	Local nTamSX3 := TamSX3("MF7_NODE")[1] //Tamanho do nó
	Local aComps := {} //array de componentes
	Local nTamID := TamSX3("MF8_ID")[1]   //Tamanho do Id
	Local nComps := 0                     //Tamanho de Componentes
	Local nCampos := _TOTAL_CAMPOS        //Total de campos MF8
	Local aCampos := {}                   //Array de Campos MF8
	Local nC2 := 0                        //Contador de Campos
	Local aRecs		:= {}					//Array de Registros
	Local nTotalNodes := 0      //Total dos nos  
	Local lRecorded	:= .T.				//Registro inserido

	BEGIN TRANSACTION

	aData := STFStComponentes(nTamSX3) //Carrega os nós
	nTotalNodes := _TOTAL_NODES      //Total dos nos

	MF7->( DbEval({ || nConta := nConta+1},{ || MF7_PROPR == "S" .AND. MF7_FILIAL == xFilial() }  ) )
	If nConta <> nTotalNodes  //Se a quantidade total de nós for diferente
		lRecorded	:= .T.				//Registro inserido
		
		MF7->(DbSetFilter({ || MF7_PROPR == "S" .AND. MF7_FILIAL == xFilial() }, " MF7_PROPR == 'S' .AND. MF7_FILIAL == xFilial() ")  )
		MF7->(DbGoTop())
		Do While !MF7->(Eof())
			RecLock("MF7", .F.)
			MF7->(DbDelete())
			MF7->(MsUnLock())
			MF7->(Dbskip())
		EndDo
		MF7->(DBClearFilter())

		//Deleta o MF8
		MF8->(DbSetFilter({ || MF8_PROPR == "S" .AND. MF8_FILIAL == xFilial() }, " MF8_PROPR == 'S' .AND. MF8_FILIAL == xFilial() ")  )
		MF8->(DbGoTop())
		Do While !MF8->(Eof())
			RecLock("MF8", .F.)
			MF8->(DbDelete())
			MF8->(MsUnLock())
			MF8->(Dbskip())
		EndDo

		aCampos :=  { "MF8_NODE",;   //1
				   		"MF8_ID",;   //2
						"MF8_ENVIRO",; //3
					   	"MF8_TYPE",;  //4
						"MF8_NAME",;  //5
						"MF8_TITLE",; //6
					 	"MF8_F3",;    //7
						"MF8_DEFAUL",; //8
					   	"MF8_TABLE",; //9
					   	"MF8_INDEX",; //10
					   	"MF8_KEY",;  //11
					   	"MF8_INTYPE",; //12
					    'MF8_VALID',;  //13/Aspas duplas + nome ocorre erro no compilador
					   	"MF8_LEN",;    //14
						"MF8_LIST",;  //15
						"MF8_FTYPE",; //16
						"MF8_PAISES",; //17
						"MF8_POSICA"}   //18

    aComps := STFStItensComponents(nTamSX3, nTamID)

		MF7->(DbSetOrder(1)) //MF7_FILIAL + MF7_NODE
		//Ordena pelo nó pai
		nConta := 0
		MF7->(DbSetFilter({ || MF7_PROPR <> "S" .AND. MF7_FILIAL == xFilial() }, " MF7_PROPR <> 'S' .AND. MF7_FILIAL == xFilial() ")  )
        MF7->(DbGoTop())
		MF7->( DbEval({ || nConta := nConta+1, cLastCmp := MF7_NODE},{ ||!Eof() }  ) )
		MF7->(DbClearFilter())
		aSort( aData,,, {|x, y| x[_CODE_NODE] < y[_CODE_NODE]})


		If nConta > 0 //Existem registros do usuário , então Deleta
			cLastCmp := IIF(cLastCmp <  aData[_TOTAL_NODES, 2],aData[_TOTAL_NODES, 2], cLastCmp)
			For nC := 1 to nTotalNodes
				If MF7->(DbSeek(xFilial() + aData[nC, _CODE_NODE])) //
					cLastCmp := Soma1(cLastCmp)
					RecLock("MF7", .F.)
					MF7->MF7_NODE := cLastCmp
					MF7->(MsUnlock())
				    //atualiza os componentes
				    aRecs := {}
				   	MF8->(DbSetFilter({ || MF8_NODE ==  aData[nC, _CODE_NODE] .AND. MF8_FILIAL == xFilial() } , " MF8_NODE ==  aData[nC, " + Str(_CODE_NODE) + "] .AND. MF8_FILIAL == xFilial() ")  )
                    MF8->(DbGotop())

					MF8->( DbEval({ || aAdd(aRecs, Recno()) },{ || !Eof() }  ) )

					MF8->( aEval(aRecs, { | r| DbGoTo(r), RecLock("MF8", .F.), MF8_NODE := cLastCmp, MsUnlock()}))
					MF8->(DbClearFilter())

					MF7->(DbSetFilter({ || MF7_FATHER ==  aData[nC, _CODE_NODE] .AND. MF7_FILIAL == xFilial() }, " MF7_FATHER ==  aData[nC, " + Str(_CODE_NODE) + "] .AND. MF7_FILIAL == xFilial()") )
				    MF7->(DbGotop())
					MF7->( DbEval({ || RecLock("MF7", .F.), MF7_FATHER := cLastCmp, MsUnLock() }, { || !Eof()}  ))
					MF7->(DbClearFilter())
				EndIf
			Next
		EndIf
		For nC := 1 to nTotalNodes
			If !MF7->(DbSeek(xFilial() + aData[nC, _CODE_NODE] ) )
				RecLock("MF7", .T.)
				MF7->MF7_FILIAL := xFilial("MF7")
				MF7->MF7_FATHER = aData[nC, _FATHER_NODE]
				MF7->MF7_NODE :=  aData[nC, _CODE_NODE]
				MF7->MF7_DESCR := aData[nC, _DESCRIPTION_NODE]
				MF7->MF7_ORDER := aData[nC, _ORDER_NODE]
				MF7->MF7_VALID := aData[nC, _VALID_FUNCTION]
				MF7->MF7_ENVIRO := aData[nC, _ENVIRONMENT_NODE]
				MF7->MF7_TABREC	:= aData[nC, _RECORD_TABLE_ONCE]
				MF7->MF7_TABINS :=  aData[nC, _INSERT_TABLE]
				MF7->MF7_PROPR  := "S"
				MF7->MF7_POSREC :=  aData[nC, _POS_RECORDED]
				MF7->MF7_FUNREC := aData[nC, _WRITE_FUNCTION]
				MF7->(MsUnLock())

			Else
				lRecorded := .F.
				Exit
			EndIf
		Next
		If lRecorded
			//Insere os componentes
			nComps := Len(aComps)
			For nC := 1 to nComps

				If MF8->( RecLock("MF8", .T.) )

					MF8->(FieldPut(FieldPos("MF8_FILIAL"), xFilial()))
					MF8->(FieldPut(FieldPos("MF8_PROPR"), "S"))
					For nC2 := 1 to nCampos
						If !Empty(aComps[nC, nC2])
							MF8->(FieldPut(FieldPos(aCampos[nC2]), aComps[nC, nC2]))
						EndIf
					Next
					MF8->(MsUnLock())

				Else

					lRecorded := .F.
					Exit
				EndIf
			Next
		EndIf

	EndIf
	
	END TRANSACTION

	RestArea(aAreaMF8)
	RestArea(aAreaMF7)
	RestArea(aArea)
    Return lRecorded

//-------------------------------------------------------------------
/*/{Protheus.doc} STFStTEF20
Função para invocar a Janela TEF 20
@param lPOS Ambiente POS?
@param oPanel Objeto Panel
@author  Varejo
@version P11.8
@since   26/04/2013
@return  NIL
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STFStTEF20( oPanel, cCodigo)
 	Local aArea    := GetArea()
 	Local aAreaSLG := SLG->(GetArea())
 	Local nOpc := 3
 	Local cEstAnt := cEstacao
 	Local lDestroy	:= .F.

	DEFAULT oPanel := NIL 
	DEFAULT cCodigo := ""
 	   
 
 	cEstacao := cCodigo
 
 	
 	If type("cCadastro") <> "C"
    	Private cCadastro  := STR0036 //"Cadastro de Estação"
    EndIf
    
    


 	If cCodigo == ""  .AND. Type("cLG_CODIGO") == "C"   
 		cCodigo := cLG_CODIGO
 	EndIf

 	If ValType(oCfgTef) <> "O"
 		oCfgTef 		:= LJCCfgTef():New()
 	EndIf
 	
 	oCfgTef:Carregar(cCodigo)

 	If SLG->(DbSeek(xFilial() + cCodigo))

		nOpc := 4

	EndIf

	oCfgTef:Show(nOpc, oPanel)


	cEstacao := cEstAnt
  
    
    cCadastro := NIL

    RestArea(aAreaSLG)
 	RestArea(aArea)

 Return oCfgTef

//-------------------------------------------------------------------
/*/{Protheus.doc} ValidaTEF20
Função para retornar os nós Pais
@param cRetorno Retorno da função
@author  Varejo
@version P11.8
@since   26/04/2013
@return  lRet TEF Valido?
@obs
@sample
/*/
//-------------------------------------------------------------------
Static Function ValidaTEF20(cRetorno)
	Local lRet := .T.

 If cIdAmb == "3"
 	If !oCfgTef:TefVl(oCfgTef, @lRet)
		cRetorno := oCfgTef:cMenssagem
	EndIf
 EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GravaTEF20
Função para gravar os dados do TEF20
@param cIdAmb
@author  Varejo
@version P11.8
@since   26/04/2013
@return  NIL
@obs
@sample
/*/
//-------------------------------------------------------------------
Static Function GravaTEF20(cIdAmb)      //colocar o loja121 na pasta pos_final

 If cIdAmb == "3"
	oCfgTef:Salvar()
 EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} LjGrvJob
Função para gravar no arquivo de config do server os dados do job
@param cIdAmb   Codigo do ambiente
@param aDadosL  Linha do no
@param cCodigo  Codigo da Estação 
@param cKey     Chave da Seção
@param cRot		Nome da rotina (main)
@author  Varejo
@version P11.8
@since   26/04/2013
@return  NIL
@obs
@sample
/*/
//-------------------------------------------------------------------
Static Function LjGrvJob(cIdAmb, aDadosL, cCodigo, cKey,;
						 cRot)
       Local lWrite := .T.                 //Gravação com sucesso
       Local nTam := Len(aDadosL[_COMPS_NODE])          //Dados
       Local lGrvIni := .F.                //GravaIni ?
       Local cJobs := ""                   //Jobs
       Local nI := 0                       //Contador
       Local lOnStart := .F.               //Grava on start
       Local lAltConfig := .F.             //Alteração configuração
       Local cAmb := ""                    ///Ambiente
       Local cEmp := ""                    //Empresa
       Local cFil := ""                    //Filial
       Local nC	  := 0						//Variável contadora 
       Local lNovo	:= .F.					//Job Novo
       

		DEFAULT cKey := "APFrontLoja"
		DEFAULT cRot := "FRTA020"
       BeginTran()

		For nC := 1 to nTam
			If aDadosL[_COMPS_NODE, nC, _COMP_TYPE] <> _ARQUIVO_INI .OR. cIdAmb == "3"
				lWrite := lWrite .AND. WriteCrtl(aDadosL[_COMPS_NODE, nC],aDadosL[_INSERT_TABLE], _COMP_DEFAULT)
			ElseIf aDadosL[_COMPS_NODE, nC, _COMP_TYPE] ==_ARQUIVO_INI .AND. cIdAmb <> "3"
					If RTRim(aDadosL[_COMPS_NODE, nC, _COMP_NAME]) == "Environment" .AND. RTrim(aDadosL[_COMPS_NODE, nC, _COMP_KEY]) == cKey
						lGrvIni := !Empty(aDadosL[_COMPS_NODE, nC,_COMP_DEFAULT])
						cAmb := aDadosL[_COMPS_NODE, nC, _COMP_DEFAULT]
					ElseIf RTrim(aDadosL[_COMPS_NODE, nC, _COMP_NAME]) == "Parm1" .AND. RTrim(aDadosL[_COMPS_NODE, nC, _COMP_KEY]) == cKey
						cEmp := aDadosL[_COMPS_NODE, nC,_COMP_DEFAULT]
					ElseIf RTrim(aDadosL[_COMPS_NODE, nC, _COMP_NAME]) == "Parm2" .AND. RTrim(aDadosL[_COMPS_NODE, nC, _COMP_KEY]) == cKey
                        cFil := aDadosL[_COMPS_NODE, nC, _COMP_DEFAULT]
					EndIf
			EndIf
			If !lWrite
				Exit
			EndIf
		Next

		If lGrvIni .AND. lWrite
			cJobs := AllTrim(GetPvProfString("OnStart", "Jobs", "", GetAdv97()))
			lOnStart := If(Len(cJobs) == 0, .F., .T.)							// Verifica a existencia desta secao
			lNovo := At(ckey,cJobs) == 0
			If At(ckey,cJobs) > 0									// Elimina a Chamada do Job APFrontLoja
				cJobs := Stuff(cJobs, At(cKey,cJobs), 12, "")
			EndIf 
			
			cJobs := If(Left(cJobs,1) == ",", SubStr(cJobs,2), cJobs)			// Elimina "," (virgulas) excedentes
			cJobs := If(Right(cJobs,1) == ",", SubStr(cJobs,1,Len(cJobs)-1), cJobs)
			For nI := 1 To Len(cJobs)
				If SubStr(cJobs,nI,2) == ",,"
					cJobs := Stuff(cJobs, nI, 2, ",")
					lAltConfig  := .T.
				EndIf
			Next nI


			cJobs := If(Empty(cAmb),"",cKey)+If(Len(cJobs)>0,",","")+cJobs


			If lAltConfig .Or. lNovo
				WritePProString("OnStart", "Jobs", cJobs, GetAdv97())
			EndIf

				WritePProString(cKey, "Main",			cRot ,	GetAdv97())
				WritePProString(cKey, "Environment",	cAmb,	GetAdv97())
				WritePProString(cKey, "nParms",			IIF(!Empty(cCodigo),  "3", "2"),		GetAdv97())
				WritePProString(cKey, "Parm1",			cEmp,	GetAdv97())
				WritePProString(cKey, "Parm2",			cFil,	Getadv97())
				IF !Empty(cCodigo)
					WritePProString(cKey, "Parm3",			cCodigo,	GetAdv97())
				EndIf
		EndIf


		If lWrite
			EndTran()

		Else
			DisarmTransaction()
		EndIf

Return lWrite

//-------------------------------------------------------------------
/*/{Protheus.doc} Lj120Alt
Função para invocar o cadastro de caixa
@author  Varejo
@version P11.8
@since   26/04/2013
@return  NIL
@obs
@sample
/*/
//-------------------------------------------------------------------
Static Function Lj120Alt()

     Local aCampos := {}
     Local aRet	  := {}
     Local aArea := GetArea()
     Local aAreaSLF := SLF->(GetArea())


 	aCampos := {	{	1,STR0046		,__cUserID,"@!",'','','',,.T.	};  //"Caixa"
				}

	If	ParamBox(aCampos, STR0047, @aRet) //"Informe o Código do Caixa"
     	DbSelectArea("SLF")
     	DbSetOrder(1) //LF_FILIAL + LF_COD
		If DbSeek( xFilial() + aRet[1])

     		a120CFG(.F.)
     	EndIf
     	RestArea(aAreaSLF)
    EndIf

    RestArea(aArea)
Return
//-------------------------------------------------------------------
/*/{Protheus.doc} RetLTPPed
Função para retornar o tipo de quebra do pedido
@author  Varejo
@version P11.8
@since   26/04/2013
@return  aRet - Combo do pedido
@obs
@sample
/*/
//-------------------------------------------------------------------
Static Function RetLTPPed()
	Local aRet := { STR0037,; //"1= Loja Reserva + Tipo de Entrega"
					STR0038,; //"2= Loja Reserva + Tipo de Entrega + Código do Contato"
					STR0039,; //"3= Loja Reserva + Tipo de Entrega + Data Entrega"
					STR0040,; //"4= Loja Reserva + Tipo de Entrega + Código do Contato + Data de Entrega"
					STR0041,; //"5= Loja Reserva + Tipo de Entrega + Data da Montagem"
					STR0042,; //"6= Loja Reserva + Tipo de Entrega + Data de Montagem + Código do Contato"
					STR0043,; //"7= Loja Reserva + Tipo de Entrega + Codigo do Contato + Data de entrega + Data de Montagem"
					STR0044} //"8= Loja Reserva + Tipo de Entrega + Data de Entrega + o Codigo do Contato + Turno"

Return aRet