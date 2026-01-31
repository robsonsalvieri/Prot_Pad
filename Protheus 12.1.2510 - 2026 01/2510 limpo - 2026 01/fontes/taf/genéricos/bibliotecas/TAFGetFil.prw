#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TAFGETFIL.CH"
//#INCLUDE "TAFTCKDEF.CH"  
//#INCLUDE "TAFCSS.CH" 

//---------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
@type			function
@description	Função para seleção de filiais. Adaptada da função ADMGETFIL.
@author			Karen Honda e Rafael Leme
@since			07/06/2021
@version		1.0
/*/
//---------------------------------------------------------------------

Function TAFGetFil(lTodasFil,lSohFilEmp,cAlias,lSohFilUn,lHlp, lExibTela)

Local cEmpresa 	:= cEmpAnt
Local cTitulo	:= ""
Local MvPar		:= ""
Local MvParDef	:= ""
Local nI 		:= 0
Local aArea 	:= GetArea() 					 // Salva Alias Anterior
Local nReg	    := 0
Local nSit		:= 0
Local aSit		:= {}
Local aSit_Ant	:= {}
Local aFil 		:= {}
Local nTamFil	:= Len(xFilial("C1E"))
Local nInc		:= 0
Local aSM0		:= FWLoadSM0() //AdmAbreSM0()
Local aFilAtu	:= {}

Local aFil_Ant
Local lGestao	:= ( "E" $ FWSM0Layout() .Or. "U" $ FWSM0Layout() )

Local cEmpFil 	:= " "
Local cUnFil	:= " "
Local nTamEmp	:= 0
Local nTamUn	:= 0
Local lOk		:= .T.
Local lUserOk	:= .T.

Default lTodasFil 	:= .F.
Default lSohFilEmp 	:= .F.	//Somente filiais da empresa corrente (Gestao Corporativa)
Default lSohFilUn 	:= .F.	//Somente filiais da unidade de negocio corrente (Gestao Corporativa)
Default lHlp		:= .T.
Default cAlias		:= ""
Default lExibTela	:= .T.

/*
Defines do SM0
SM0_GRPEMP  // Código do grupo de empresas
SM0_CODFIL  // Código da filial contendo todos os níveis (Emp/UN/Fil)
SM0_EMPRESA // Código da empresa
SM0_UNIDNEG // Código da unidade de negócio
SM0_FILIAL  // Código da filial
SM0_NOME    // Nome da filial
SM0_NOMRED  // Nome reduzido da filial
SM0_SIZEFIL // Tamanho do campo filial
SM0_LEIAUTE // Leiaute do grupo de empresas
SM0_EMPOK   // Empresa autorizada
SM0_GRPEMP  // Código do grupo de empresas
SM0_USEROK  // Usuário tem permissão para usar a empresa/filial
SM0_RECNO   // Recno da filial no SIGAMAT
SM0_LEIAEMP // Leiaute da empresa (EE)
SM0_LEIAUN  // Leiaute da unidade de negócio (UU)
SM0_LEIAFIL // Leiaute da filial (FFFF)
SM0_STATUS  // Status da filial (0=Liberada para manutenção,1=Bloqueada para manutenção)
SM0_NOMECOM // Nome Comercial
SM0_CGC     // CGC
SM0_DESCEMP // Descricao da Empresa
SM0_DESCUN  // Descricao da Unidade
SM0_DESCGRP // Descricao do Grupo
*/

//Caso o Alias não seja passado, traz as filiais que o usuario tem acesso (modo padrao)
lSohFilEmp := IF(Empty(cAlias),.F.,lSohFilEmp)
lSohFilUN  := IF(Empty(cAlias),.F.,lSohFilUn) .And. lSohFilEmp

//Caso use gestão corporativa , busca o codigo da empresa dentro do M0_CODFIL
//Em caso contrario, , traz as filiais que o usuario tem acesso (modo padrao)
cEmpFil := IIF(lGestao, FWCompany(cAlias)," ")
cUnFil  := IIF(lGestao, FWUnitBusiness(cAlias)," ")

//Tamanho do codigo da filial
nTamEmp := Len(cEmpFil)
nTamUn  := Len(cUnFil)

	If !(lExibTela .AND. IsBlind())
		PswOrder(1)
		If PswSeek( __cUserID, .T. ) .or. FwIsInCallStack('getFilTSI') //Não validar usuário quando chamada for da API TsiBranches
			aSit		:= {}
			aFilNome	:= {}
			aFilAtu		:= FWArrFilAtu( cEmpresa, cFilAnt )
			If Len( aFilAtu ) > 0
				cTxtAux := IIF(lGestao,STR0001,STR0002)//"Empresa/Unidade/Filial de "##"Filiais de "
				cTitulo := cTxtAux + AllTrim( aFilAtu[6] )
			EndIf

			// Adiciona as filiais que o usuario tem permissão
			For nInc := 1 To Len( aSM0 )
				//DEFINES da SMO encontra-se no arquivo FWCommand.CH
				//Na função FWLoadSM0(), ela retorna na posicao [SM0_USEROK] se esta filial é válida para o user

				//Incluido validação de acesso as filiais, caso o usuário não tenha acesso a todas as filiais do grupo não seta a variável lTodasFil,
				//isso porque os saldos contábeis estavam saindo errados, pois buscavam todas as filiais, mesmo aquelas que o usuário não tem acesso.
				If (aSM0[nInc][SM0_GRPEMP] == cEmpAnt .And. ((ValType(aSM0[nInc][SM0_EMPOK]) == "L" .And. aSM0[nInc][SM0_EMPOK]) .Or. ValType(aSM0[nInc][SM0_EMPOK]) <> "L") .And. ! aSM0[nInc][SM0_USEROK] )
					lUserOk := .F.
				Endif

				If (aSM0[nInc][SM0_GRPEMP] == cEmpAnt .And. ((ValType(aSM0[nInc][SM0_EMPOK]) == "L" .And. aSM0[nInc][SM0_EMPOK]) .Or. ValType(aSM0[nInc][SM0_EMPOK]) <> "L") .And. aSM0[nInc][SM0_USEROK] )

					//Verificacao se as filiais a serem apresentadas serao
					//Apenas as filiais da empresa conrrente (M0_CODFIL)
					If lGestao .and. lSohFilEmp
						//Se for exclusivo para empresa
						If !Empty(cEmpFil)
							lOk := IIf(cEmpFil == Substr(aSM0[nInc][2],1,nTamEmp),.T.,.F.)
							/*
							Verifica se as filiais devem pertencer a mesma unidade de negocio da filial corrente*/
							If lOk .And. lSohFilUn
								//Se for exclusivo para unidade de negocio
								If !Empty(cUnFil)
									lOk := IIf(cUnFil == Substr(aSM0[nInc][2],nTamEmp + 1,nTamUn),.T.,.F.)
								Endif
							Endif
						Else
							//Se for tudo compartilhado, traz apenas a filial corrente
							lOk := IIf(cFilAnt == aSM0[nInc][SM0_CODFIL],.T.,.F.)
						Endif
					Endif

					If lOk
						AAdd(aSit, {aSM0[nInc][SM0_CODFIL],aSM0[nInc][SM0_NOMRED],Transform(aSM0[nInc][SM0_CGC],PesqPict("SA1","A1_CGC"))})
						MvParDef += aSM0[nInc][SM0_CODFIL]
						nI++
					Endif

				Endif

			Next
			If Len( aSit ) <= 0
				// Se não tem permissão ou ocorreu erro nos dados do usuario, pego a filial corrente.
				Aadd(aSit, aFilAtu[2]+" - "+aFilAtu[7] )
				MvParDef := aFilAtu[2]
				nI++
			EndIf
		EndIf
		If lExibTela
			aFil := {}
			If TafOpcoes(@MvPar,cTitulo,aSit,MvParDef,,,.F.,nTamFil,nI,.T.,,,,,,,,.T.)  // Chama funcao Adm_Opcoes
				nSit := 1
				For nReg := 1 To len(mvpar) Step nTamFil  // Acumula as filiais num vetor
					If SubSTR(mvpar, nReg, nTamFil) <> Replicate("*",nTamFil)
				 		AADD(aFil, SubSTR(mvpar, nReg, nTamFil) )
					endif
					nSit++
				next
				If Empty(aFil) .And. lHlp
		 	  		Help(" ",1," ",,STR0003,1,0)		//"Por favor selecionar pelo menos uma filial"
				EndIF

				If Len(aFil) == Len(aSit) .And. lUserOk
					lTodasFil := .T.
				EndIf
			Endif
		Else
			aFil := aClone(aSit)
		EndIf
	Else
		aFil := {cFilAnt}
	EndIf

RestArea(aArea)

Return(aFil)

//---------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
@type			function
@description	Função para seleção de opções adaptada da função AdmOpcoes.
@author			Karen Honda e Rafael Leme
@since			07/06/2021
@version		1.0
/*/
//---------------------------------------------------------------------

Function TAFOpcoes(	uVarRet			,;	//01-Variavel de Retorno
						cTitulo			,;	//2-Titulo da Coluna com as opcoes
						aOpcoes			,;	//3-Opcoes de Escolha (Array de Opcoes)
						cOpcoes			,;	//4-String de Opcoes para Retorno
						nLin1			,;	//5-Nao Utilizado
						nCol1			,;	//6-Nao Utilizado
						l1Elem			,;	//7-Se a Selecao sera de apenas 1 Elemento por vez
						nTam			,;	//8-Tamanho da Chave
						nElemRet		,;	//9-No maximo de elementos na variavel de retorno
						lMultSelect		,;	//10-Inclui Botoes para Selecao de Multiplos Itens
						lComboBox		,;	//11-Se as opcoes serao montadas a partir de ComboBox de Campo ( X3_CBOX )
						cCampo			,;	//12-Qual o Campo para a Montagem do aOpcoes
						lNotOrdena		,;	//13-Nao Permite a Ordenacao
						lNotPesq		,;	//14-Nao Permite a Pesquisa
						lForceRetArr    ,;	//15-Forca o Retorno Como Array
						cF3				,;	//16-Consulta F3
						lVisual			,;  //17-Apenas visualizacao
						lColunada		 ;  //18-Apresenta dados em colunas (Apenas AdmGetFil)
				  )

Local aListBox			:= {}
Local aSvKeys			:= GetKeys()
Local aAdvSize			:= {}
Local aInfoAdvSize		:= {}
Local aObjCoords		:= {}
Local aObjSize			:= {}
Local aButtons			:= {}
Local aX3Box			:= {}

Local bSvF3				:= SetKey( VK_F3  , NIL )
Local bSetF3			:= { || NIL }
Local bSet15			:= { || NIL }
Local bSet24			:= { || NIL }
Local bSetF4			:= { || NIL }
Local bSetF5			:= { || NIL }
Local bSetF6			:= { || NIL }
Local bCapTrc			:= { || NIL }
Local bDlgInit			:= { || NIL }
Local bOrdena			:= { || NIL }
Local bPesquisa			:= { || NIL }

Local cCodOpc			:= ""
Local cDesOpc			:= ""
Local cCodDes			:= ""
Local cPict				:= "@E 999999"
Local cVarQ				:= ""
Local cReplicate		:= ""
Local cTypeRet			:= ""

Local lExistCod			:= .F.
Local lSepInCod			:= .F.

Local nOpcA				:= 0
Local nFor				:= 0
Local nAuxFor			:= 1
Local nOpcoes			:= 0
Local nListBox			:= 0
Local nElemSel			:= 0
Local nInitDesc			:= 1
Local nTamPlus1			:= 0
Local nSize				:= 0

Local oSize
Local a1stRow			:= {}
Local a2ndRow			:= {}
Local a3rdRow			:= {}

Local oDlg
Local oListbox		:= NIL
Local oElemSel      	:= NIL
Local oElemRet		:= NIL
Local oOpcoes			:= NIL
Local oFontNum		:= NIL
Local oFontTit		:= NIL
Local oBtnMarcTod		:= NIL
Local oBtnDesmTod		:= NIL
Local oBtnInverte		:= NIL
Local oGrpOpc			:= NIL
Local oGrpRet			:= NIL
Local oGrpSel			:= NIL

Local uRet				:= NIL
Local uRetF3			:= NIL

DEFAULT uVarRet			:= &( ReadVar() )
DEFAULT cTitulo			:= OemToAnsi( STR0004 )	//"Escolha Padr”es"
DEFAULT aOpcoes			:= {}
DEFAULT cOpcoes			:= ""
DEFAULT l1Elem			:= .F.
DEFAULT lMultSelect 	:= .T.
DEFAULT lComboBox		:= .F.
DEFAULT cCampo			:= ""
DEFAULT lNotOrdena		:= .F.
DEFAULT lNotPesq		:= .F.
DEFAULT lForceRetArr	:= .F.
DEFAULT lVisual			:= .F.
DEFAULT lColunada		:= .F.

Begin Sequence

	uRet				:= uVarRet
	cTypeVarRet			:= ValType( uVarRet )
	cTypeRet			:= IF( lForceRetArr , "A" , ValType( uRet ) )
	lMultSelect 		:= !( l1Elem )
	nSize				:= If(lColunada,20,0)

	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Coloca o Ponteiro do Cursor em Estado de Espera			   ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	//CursorWait()

		IF !( lComboBox )
			DEFAULT nTam	:= 1
			nTamPlus1		:= ( nTam + 1 )
			IF ( ( nOpcoes := Len( aOpcoes ) ) > 0 )
				For nFor := 1 To nOpcoes
					If !lColunada
					    IF !Empty( cOpcoes )
						    cCodOpc		:= SubStr( cOpcoes , nAuxFor , nTam )
					    	lExistCod	:= .F.
					    	nInitDesc	:= 1
					    	IF !( " <-> "		== SubStr( aOpcoes[ nFor ] , nTamPlus1 , 5 ) ) .and. ;
					    	   !( " <=> "		== SubStr( aOpcoes[ nFor ] , nTamPlus1 , 5 ) ) .and. ;
		  	   			       !( " <-> "		== SubStr( aOpcoes[ nFor ] , nTam      , 5 ) ) .and. ;
					    	   !( " <=> "		== SubStr( aOpcoes[ nFor ] , nTam      , 5 ) )
					    		IF !( "<->"		== SubStr( aOpcoes[ nFor ] , nTamPlus1 , 3 ) ) .and. ;
					    		   !( "<=>"		== SubStr( aOpcoes[ nFor ] , nTamPlus1 , 3 ) ) .and. ;
					    		   !( " - "		== SubStr( aOpcoes[ nFor ] , nTamPlus1 , 3 ) ) .and. ;
					    		   !( " = "		== SubStr( aOpcoes[ nFor ] , nTamPlus1 , 3 ) ) .and. ;
					    		   !( "<->"		== SubStr( aOpcoes[ nFor ] , nTam      , 3 ) ) .and. ;
					    		   !( "<=>"		== SubStr( aOpcoes[ nFor ] , nTam	   , 3 ) ) .and. ;
					    		   !( " - "		== SubStr( aOpcoes[ nFor ] , nTam	   , 3 ) ) .and. ;
					    		   !( " = "		== SubStr( aOpcoes[ nFor ] , nTam	   , 3 ) )
					    			IF !( "-"	== SubStr( aOpcoes[ nFor ] , nTamPlus1 , 1 ) ) .and. ;
					    			   !( "="	== SubStr( aOpcoes[ nFor ] , nTamPlus1 , 1 ) ) .and. ;
					    			   !( "-"	== SubStr( aOpcoes[ nFor ] , nTam	   , 1 ) ) .and. ;
					    			   !( "="	== SubStr( aOpcoes[ nFor ] , nTam      , 1 ) )
					    				nInitDesc	:= 1
					    				lExistCod	:= .F.
					    			Else
				    					nInitDesc	:= nTamPlus1 /* 1 */
					    				lExistCod	:= .T.
					    			EndIF
					    		Else
					    			IF (;
					    					lSepInCod := (;
															( "<->" $ cCodOpc ) .or. ;
					    									( "<=>" $ cCodOpc ) .or. ;
					    									( " - " $ cCodOpc ) .or. ;
					    									( " = " $ cCodOpc )		 ;
					    							   	  );
										)
					    				nInitDesc	:= nTamPlus1
					    			Else
					    				nInitDesc	:= ( nTamPlus1 + 2 ) /* 123 */
					    			EndIF
					    			lExistCod	:= .T.
					    		EndIF
					    	Else
				    			IF (;
				    					lSepInCod := (;
				    									( " <-> " $ cCodOpc ) .or. ;
				    									( " <=> " $ cCodOpc )	   ;
				    							   );
									)
				    				nInitDesc	:= nTamPlus1
				    			Else
					    			nInitDesc	:= ( nTamPlus1 + 4 ) /* 12345 */
					    		EndIF
					    		lExistCod	:= .T.
					    	EndIF
						    cDesOpc		:= SubStr( aOpcoes[ nFor ] , nInitDesc )
						    cCodDes		:= IF( lExistCod , aOpcoes[ nFor ] , cCodOpc + " - " + cDesOpc )
						    aAdd( aListBox , { .F. , cCodDes , cCodOpc , cDesOpc } )
							nAuxFor := ( ( nFor * nTam ) + 1 )
						Else
							aAdd( aListBox , { .F. , aOpcoes[ nFor ] , aOpcoes[ nFor ] , aOpcoes[ nFor ] } )
						EndIF
						IF (;
						   		( cTypeVarRet == "C" );
						   		.and.;
						   		( aListBox[ nFor , 03 ] $ uVarRet );
						   	)
							aListBox[ nFor , 01 ] := .T.
						EndIF
	        		Else
					    aAdd( aListBox , { .F. , aOpcoes[ nFor,1 ] , aOpcoes[ nFor,2 ], aOpcoes[ nFor,3 ] } )

					Endif

				Next nFor
			Else
				/*
				ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				³ Restaura o Ponteiro do Cursor                  			   ³
				ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
				//CursorArrow()
				//"N„o existem dados para consulta"###"Escolha Padr”es"
				MsgInfo( OemToAnsi( STR0005 ) , IF( Empty( cTitulo ) , OemToAnsi( STR0004 ) , cTitulo ) )
				Break
			EndIF
		Else
			DEFAULT nTam	:= ( TamSx3( cCampo )[1] )
			aListBox := TafMtaCbo( cCampo , @cTitulo )
			IF ( ( nOpcoes := Len( aListBox ) ) > 0 )
				For nFor := 1 To nOpcoes
			    	IF (;
			    			( cTypeVarRet == "C" );
			    			.and.;
			    			( aListBox[ nFor , 03 ] $ uVarRet );
			    		)
		    	    	aListBox[ nFor , 01 ] := .T.
		    		EndIF
				Next nFor
			Else
				/*
				ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				³ Restaura o Ponteiro do Cursor                  			   ³
				ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
				//CursorArrow()
				//"N„o existem dados para consulta"
				MsgInfo( OemToAnsi( STR0005 ) , IF( Empty( cTitulo ) , OemToAnsi( STR0004 ) , cTitulo ) )
			EndIF
		EndIF

		/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Define o DEFAULT do Maximo de Elementos que Podem ser Retorna³
		³ dos														   ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		DEFAULT nElemRet := ( Len( &( ReadVar() ) ) / nTam )

		/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Define os numeros de Elementos que serao Mostrados		   ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		nOpcoes		:= Len( aListbox )
		nElemRet    := Min( nElemRet , nOpcoes )
		nElemRet	:= IF( !( lMultSelect ) , 01 , nElemRet )
		/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Verifica os Elementos ja Selecionados          			   ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		aEval( aListBox , { |x| IF( x[1] , ++nElemSel , NIL ) } )


	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Restaura o Ponteiro do Cursor                  			   ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	//CursorArrow()

	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Define Bloco e Botao para a Ordenacao das Opcoes       	   ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	IF !( lNotOrdena )
		bOrdena := { || TafOpcOrd(;
									oListBox	,;
									STR0006		 ; //"Ordenar <F7>..."
								 ),;
					 	SetKey( VK_F7 , bOrdena );
					}
		aAdd(;
				aButtons	,;
								{;
									"SDUORDER"				,;
		   							bOrdena 				,;
		       	   					OemToAnsi( STR0006 )	,;	//"Ordenar <F7>..."
		       	   					OemtoAnsi( STR0007 )	 ;	//"Ordenação"
		           				};
		     )
	EndIF

	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Define Bloco e  Botao para a Pesquisa                   	   ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	IF !( lNotPesq )
		bPesquisa := { || aListBox := TafOpcPsq(;
									oListBox	,;
									STR0008		,; // "Pesquisar <F8>..."
									lNotOrdena  ,;
									cF3			,;
									aX3Box		 ;
								 ),;
					 	SetKey( VK_F8 , bPesquisa );
					}
		aAdd(;
				aButtons	,;
								{;
									STR0009				,;
		   							bPesquisa				,;
		       	   					OemToAnsi( STR0008 )	,;	//"Pesquisar <F8>..."
		       	   					OemToAnsi( STR0010 )	 ;	//"Pesquisar"
		           				};
		     )
	EndIF

	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Define o Bloco para a CaPexTroca()						   ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	bCapTrc := { |cTipo,lMultSelect| ;
										aListBox := TafexTroca(;
																oListBox:nAt,;
																@aListBox,;
																l1Elem,;
																nOpcoes,;
																nElemRet,;
																@nElemSel,;
																lMultSelect,;
																cTipo;
															),;
										oListBox:nColPos := 1,;
										oListBox:Refresh(),;
										oElemSel:Refresh();
				}

	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Seta a consulta F3                						   ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	IF !Empty( cCampo )
		IF !Empty( cF3 )
			bSetF3	:= { || TafPesqF3( cF3 , cCampo , oListBox ) , SetKey( VK_F3 , bSetF3 ) }
		Else
			aX3Box	:= Sx3Box2Arr( cCampo )
		EndIF
	EndIF

	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Disponibiliza Dialog para Selecao 						   ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	DEFINE FONT oFontNum NAME "Arial" SIZE 000,-014 BOLD
	DEFINE FONT oFontTit NAME "Arial" SIZE 000,-011 BOLD

	DEFINE MSDIALOG oDlg FROM 000,000 TO 390,500 TITLE STR0011 OF oMainWnd PIXEL //STR0056 - SELEÇÃO DE FILIAIS

	//Faz o calculo automatico de dimensoes de objetos
	oSize := FwDefSize():New(.T.,,,oDlg)

	oSize:lLateral := .F.
	oSize:lProp	:= .T. // Proporcional

	oSize:AddObject( "1STROW" ,  100, 070, .T., .T. ) // Totalmente dimensionavel
	oSize:AddObject( "2NDROW" ,  100, 010, .T., .T. ) // Totalmente dimensionavel
	oSize:AddObject( "3RDROW" ,  100, 020, .T., .T. ) // Totalmente dimensionavel

	oSize:aMargins := { 3, 3, 3, 3 } // Espaco ao lado dos objetos 0, entre eles 3

	oSize:Process() // Dispara os calculos


	a1stRow :=	{oSize:GetDimension("1STROW","LININI"),;
				oSize:GetDimension("1STROW","COLINI"),;
				oSize:GetDimension("1STROW","XSIZE"),;
				oSize:GetDimension("1STROW","YSIZE")}

	a2ndRow :=	{oSize:GetDimension("2NDROW","LININI"),;
				oSize:GetDimension("2NDROW","COLINI"),;
				oSize:GetDimension("2NDROW","XSIZE"),;
				oSize:GetDimension("2NDROW","YSIZE")}

	a3rdRow :=	{oSize:GetDimension("3RDROW","LININI"),;
				oSize:GetDimension("3RDROW","COLINI"),;
				oSize:GetDimension("3RDROW","LINEND"),;
				oSize:GetDimension("3RDROW","COLEND")}


		If lColunada		//Utilizada pela AdmGetFil com Gestao Corporativa
			@ a1stRow[1],a1stRow[2]	LISTBOX oListBox VAR cVarQ FIELDS HEADER "" , STR0012, STR0013, STR0014 SIZE a1stRow[3],a1stRow[4] ON	DBLCLICK Eval( bCapTrc ) NOSCROLL OF oDlg PIXEL //"Filial", "Nome Filial", "CNPJ"
        Else
			@ a1stRow[1],a1stRow[2]	LISTBOX oListBox VAR cVarQ FIELDS HEADER "" , OemToAnsi(cTitulo)  SIZE a1stRow[3],a1stRow[4] ON	DBLCLICK Eval( bCapTrc ) NOSCROLL OF oDlg PIXEL
		Endif

		oListBox:SetArray( aListBox )
		oListBox:bLine := { || LineLstBox( oListBox , .T. ) }
		oListBox:bWhen := { || !lVisual }

		IF ( lMultSelect ) .AND. !lVisual
			/*
			ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			³ Define Bloco e o Botao para Marcar Todos    				   ³
			ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
			bSetF4		:= { || Eval( bCapTrc , "M" , lMultSelect ) , SetKey( VK_F4 , bSetF4 ) }
			@ a2ndRow[1] + 002 ,a2ndRow[2] + 000  BUTTON oBtnMarcTod	PROMPT OemToAnsi( STR0015 )		SIZE 75,13.50 OF oDlg	PIXEL ACTION Eval( bSetF4 ) //"Marca Todos - <F4>"

			/*
			ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			³ Define Bloco e o Botao para Desmarcar Todos    			   ³
			ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
			bSetF5		:= { || Eval( bCapTrc , "D" , lMultSelect ) , SetKey( VK_F5 , bSetF5 ) }
			@ a2ndRow[1] + 002,a2ndRow[2] + 080 BUTTON oBtnDesmTod	PROMPT OemToAnsi( STR0016 )		SIZE 75,13.50 OF oDlg	PIXEL ACTION Eval( bSetF5 ) //"Desmarca Todos - <F5>"

			/*
			ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			³ Define Bloco e o Botao para Inversao da Selecao			   ³
			ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
			bSetF6		:= { || Eval( bCapTrc , "I" , lMultSelect ) , SetKey( VK_F6 , bSetF6 ) }
			@ a2ndRow[1] + 002,a2ndRow[2] + 160 BUTTON oBtnInverte	PROMPT OemToAnsi( STR0017 ) 	SIZE 75,13.50 OF oDlg	PIXEL ACTION Eval( bSetF6 ) //If( cPaisLoc $ "ANG|PTG", "Inverte Selecçäo - <F6>", "Inverte Seleçäo - <F6>" )
		EndIF

		If !lVisual
			/*
			ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			³ Numero de Elementos para Selecao							   ³
			ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
			@ a3rdRow[1] + 000,a3rdRow[2] + 000 GROUP oGrpOpc TO a3rdRow[3]-5,074.50	OF oDlg LABEL OemtoAnsi( STR0018 ) PIXEL	//If( cPaisLoc $ "ANG|PTG", "Nr.Elemento(s)", "Nro.Elemento(s)" )
			oGrpOpc:oFont := oFontTit
			@ a3rdRow[1] + 010,a3rdRow[2] + 010 SAY oOpcoes VAR Transform( nOpcoes	, cPict )	OF oDlg PIXEL	FONT oFontNum

			/*
			ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			³ Maximo de Elementos que poderm Ser Selecionados			   ³
			ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
			@ a3rdRow[1] + 000,a3rdRow[2] + 080 GROUP oGrpRet TO a3rdRow[3]-5,152.50	OF oDlg LABEL OemtoAnsi( STR0019 ) PIXEL	//If( cPaisLoc $ "ANG|PTG", "Máx. Elem. p/ Selecção", "M x. Elem. p/ Seleção" )
			oGrpRet:oFont := oFontTit
			@ a3rdRow[1] + 010,a3rdRow[2] + 090 SAY oElemRet	VAR Transform( nElemRet	, cPict )	OF oDlg PIXEL	FONT oFontNum

			/*
			ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			³ Numero de Elementos Selecionados                		   	   ³
			ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
			@ a3rdRow[1] + 000,a3rdRow[2] + 160 GROUP oGrpSel	TO a3rdRow[3]-5,230	OF oDlg LABEL OemtoAnsi( STR0020 ) PIXEL	//If( cPaisLoc $ "ANG|PTG", "Elem.Seleccionado(s)", "Elem.Selecionado(s)" )
			oGrpSel:oFont := oFontTit
			@ a3rdRow[1] + 010,a3rdRow[2] + 170 SAY oElemSel	VAR Transform( nElemSel	, cPict )	OF oDlg PIXEL	FONT oFontNum
		EndIf

		/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Define Bloco para a Tecla <CTRL-O>              		   	   ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	  	bSet15 := { || nOpcA := 1 , GetKeys() , SetKey( VK_F3 , NIL ) , oDlg:End() }

		/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Define Bloco para a Tecla <CTRL-X>              		   	   ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		bSet24 := { || nOpcA := 0 , GetKeys() , SetKey( VK_F3 , NIL ) , oDlg:End() }

		/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Define Bloco para o Init do Dialog              		   	   ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		bDlgInit := { || EnchoiceBar( oDlg , bSet15 , bSet24 , NIL , aButtons ),;
						 IF( lMultSelect ,;
						 		(;
						 		 	SetKey( VK_F3 , bSetF3 ),;
						 		 	SetKey( VK_F4 , bSetF4 ),;
						 		 	SetKey( VK_F5 , bSetF5 ),;
						 		 	SetKey( VK_F6 , bSetF6 );
						 		 ),;
						 		NIL;
						 	),;
						 SetKey( VK_F7 , bOrdena ),;
						 SetKey( VK_F8 , bPesquisa );
					}

	ACTIVATE MSDIALOG oDlg CENTERED ON INIT Eval( bDlgInit )

	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Retorna as Opcoes Selecionadas                  		   	   ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	IF ( nOpcA == 1 )
		/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Coloca o Ponteiro do Cursor em Estado de Espera			   ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		//CursorWait()
	    IF ( cTypeRet == "C" )
		    uRet		:= ""
			cReplicate	:= Replicate( "*" , nTam )
		    nListBox := Len( aListBox )
		    For nFor := 1 To nListBox
				IF ( aListBox[ nFor , 01 ] )
					uRet += aListBox[ nFor , IIf(lColunada, 02, 03) ]
		    	ElseIF ( lMultSelect )
		    		uRet += cReplicate
		    	EndIF
		    Next nFor
		ElseIF ( cTypeRet == "A" )
		    uRet	 	:= {}
		    nListBox	:= 0
		    While ( ( nFor := aScan( aListBox , { |x| x[1] } , ++nListBox ) ) > 0 )
		    	nListBox := nFor
				aAdd( uRet , aListBox[ nFor , 03 ] )
		    End While
		EndIF
		/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Restaura o Ponteiro do Cursor                  			   ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		//CursorArrow()
	EndIF

	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Carrega Variavel com retorno por Referencia     		   	   ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	uVarRet := uRet

End Sequence

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Restaura o Estado das Teclas de Atalho          		   	   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
RestKeys( aSvKeys , .T. )
SetKey( VK_F3 , bSvF3 )

Return( ( nOpca == 1 ) )

//---------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
@type			function
@description	Função para montagem de combo.Adaptada da função MontaCombo.
@author			Karen Honda e Rafael Leme
@since			07/06/2021
@version		1.0
/*/
//---------------------------------------------------------------------

Function TafMtaCbo( cCampo , cTitulo )

Local aArea		:= GetArea()
Local aAreaSX3	:= SX3->( GetArea() )
Local aListBox	:= {}
Local aSx3Info	:= PosAlias( "SX3" , cCampo , NIL , { "X3Titulo()" , "X3cBox()" , "X3_TAMANHO" } , 2 , .F. )

Local nLoop
Local nLoops

IF !Empty( aSx3Info )
	cTitulo := aSx3Info[1]
	aX3cBox	:= RetSx3Box( aSx3Info[2] , NIL , NIL , aSx3Info[3] )
	nLoops  := Len( aX3cBox )
	For nLoop := 1 To nLoops
		aAdd( aListBox , { .F. , aX3cBox[ nLoop , 1 ] , aX3cBox[ nLoop , 2 ] , aX3cBox[ nLoop , 3 ] } )
	Next nLoop
EndIF

RestArea( aAreaSX3 )
RestArea( aArea )

Return( aListBox )

//---------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
@type			function
@description	Ordenar as Opcoes em TafOpcoes. Adaptada da função AdmOpcOrd.
@author			Karen Honda e Rafael Leme
@since			07/06/2021
@version		1.0
/*/
//---------------------------------------------------------------------

Static Function TafOpcOrd( oListBox , cTitulo )

Local aSvKeys		:= GetKeys()
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjCoords	:= {}
Local aObjSize		:= {}

Local bSort			:= { || NIL }

Local lbSet15		:= .F.

Local nOpcRad		:= 1

Local oFont			:= NIL
Local oDlg			:= NIL
Local oGroup		:= NIL
Local oRadio		:= NIL

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Monta as Dimensoes dos Objetos         					   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
aAdvSize		:= MsAdvSize( .T. , .T. )
/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Redimensiona                           					   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
aAdvSize[3] -= 25
aAdvSize[4] -= 40
aAdvSize[5] -= 50
aAdvSize[6] -= 20
aAdvSize[7] += 50
aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 0 , 0 }
aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords )

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Define o Bloco para a Teclas <CTRL-O>   ( Button OK da Enchoi³
³ ceBar )													   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
bSet15 := { ||	(;
					lbSet15 := .T. ,;
					GetKeys(),;
					oDlg:End();
				  );
			}

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Define o  Bloco  para a Teclas <CTRL-X> ( Button Cancel da En³
³ choiceBar )												   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
bSet24 := { || GetKeys() , oDlg:End() }

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³Monta Dialogo para a selecao do Periodo 					  ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

Define Font oFont NAME "Arial" SIZE 0,-11 Bold
Define MsDialog oDlg Title OemToAnsi(cTitulo) From aAdvSize[7],000 To aAdvSize[6],aAdvSize[5] Of GetWndDefault() Pixel

@ aObjSize[1,1],(aObjSize[1,2] + 003) Group oGroup To aObjSize[1,3],aObjSize[1,4] Label OemToAnsi( STR0007 ) Of oDlg Pixel // "Ordenação"
oGroup:oFont:= oFont

@ (aObjSize[1,1] + 010),(aObjSize[1,2] + 005) Say OemToAnsi( STR0021 ) Size 300 , 010 Of oDlg Pixel Font oFont // If( cPaisLoc $ "ANG|PTG", "Efectuar a Ordenação por:", "Efetuar a Ordenação por:" )
@ (aObjSize[1,1] + 010),(aObjSize[1,2] + 100) Radio oRadio Var nOpcRad Items OemToAnsi( STR0022 ),;            // "Código da Filial"
																	 		 OemToAnsi( STR0013 ),;            // "Nome da Empresa"
																	 		 OemToAnsi( STR0023 ),;            // "Ítem selecionado + Código da Filial"
																	 		 OemToAnsi( STR0024 ),;            // "Ítem selecionado + Nome da Empresa"
																	 		 OemToAnsi( STR0025 ),;            // "Ítem não selecionado + Código da Filial"
																	 		 OemToAnsi( STR0026 );             // "Ítem não selecionado + Nome da Empresa"
																			 Size 115 , 010 Of oDlg Pixel
oRadio:oFont := oFont

Activate MsDialog oDlg Centered On Init EnchoiceBar(oDlg,bSet15,bSet24)

If (lbSet15)

	Do Case
		Case (nOpcRad == 1)
			bSort := {|x,y| x[2] < y[2]}
		Case (nOpcRad == 2)
			bSort := {|x,y| x[3] < y[3]}
		Case (nOpcRad == 3)
			bSort := {|x,y| (If( x[1],"A","Z") + x[2]) < (If( y[1],"A","Z") + y[2])}
		Case (nOpcRad == 4)
			bSort := {|x,y| (If( x[1],"A","Z") + x[3]) < (If( y[1],"A","Z") + y[3])}
		Case (nOpcRad == 5)
			bSort := {|x,y| (If(!x[1],"A","Z") + x[2]) < (If(!y[1],"A","Z") + y[2])}
		Case (nOpcRad == 6)
			bSort := {|x,y| (If(!x[1],"A","Z") + x[3]) < (If(!y[1],"A","Z") + y[3])}
	End Case

	aSort( oListBox:aArray , NIL , NIL , bSort )
	oListBox:nAt := 1
	oListBox:Refresh()
EndIf

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Restaura as Teclas de Atalho                     	  		  ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
RestKeys( aSvKeys , .T. )

Return( NIL )

//---------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
@type			function
@description	Pesquisar as Opcoes em TafOpcoes  . Adaptada da função AdmOpcoes.
@author			Karen Honda e Rafael Leme
@since			07/06/2021
@version		1.0
/*/
//---------------------------------------------------------------------

Static Function TafOpcPsq( oListBox , cTitulo , lNotOrdena , cF3 , aX3Box )

Local aSvKeys		:= GetKeys()
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjCoords	:= {}
Local aObjSize		:= {}
Local aCloneArr		:= {}

Local bSort			:= { || NIL }
Local bAscan		:= { || NIL }
Local bSvF3			:= SetKey( VK_F3  , NIL )

Local cCodigo		:= Space( 20 )
Local cDescri		:= Space( 60 )
Local cMsg			:= ""

Local lbSet15		:= .F.

Local nOpcRad		:= 1
Local nAt			:= 0

Local oFont			:= NIL
Local oDlg			:= NIL
Local oGroup		:= NIL
Local oRadio		:= NIL
Local oCodigo		:= NIL
Local oDescri		:= NIL

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Monta as Dimensoes dos Objetos         					   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
aAdvSize		:= MsAdvSize( .T. , .T. )
/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Redimensiona                           					   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
aAdvSize[3] -= 25
aAdvSize[4] -= 40
aAdvSize[5] -= 50
aAdvSize[6] -= 50
aAdvSize[7] += 20
aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 0 , 0 }
aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords )

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Define o Bloco para a Teclas <CTRL-O>   ( Button OK da Enchoi³
³ ceBar )													   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
bSet15 := { ||	(;
					lbSet15 := .T. ,;
					GetKeys(),;
					oDlg:End();
				  );
			}

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Define o  Bloco  para a Teclas <CTRL-X> ( Button Cancel da En³
³ choiceBar )												   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
bSet24 := { || GetKeys() , oDlg:End() }

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³Monta Dialogo para a selecao do Periodo 					  ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Define Font oFont Name "Arial" Size 000,-11 Bold
Define MsDialog oDlg Title OemToAnsi(cTitulo) From aAdvSize[7],000 To aAdvSize[6] + 020,aAdvSize[5] Of GetWndDefault() Pixel

@ aObjSize[1,1],(aObjSize[1,2] + 003) Group oGroup To aObjSize[1,3] + 012,aObjSize[1,4] Label OemToAnsi( STR0010 ) Of oDlg Pixel // "Pesquisa"
oGroup:oFont := oFont

@ (aObjSize[1,1] + 010),(aObjSize[1,2] + 005) Say OemToAnsi( STR0027 ) Size 300,010 Of oDlg Pixel Font oFont // If( cPaisLoc $ "ANG|PTG", "Efectuar Pesquisa por:", "Efetuar Pesquisa por:" )
@ (aObjSize[1,1] + 010),(aObjSize[1,2] + 100) Radio oRadio Var nOpcRad Items OemToAnsi( STR0022 ),;          // "Código da Filial"
																	 		 OemToAnsi( STR0013 ) ;          // "Nome da Empresa"
																			 Size 115,010 Of oDlg Pixel;
																			 ON CHANGE ( cCodigo := Space( 20 ),;
																			 			 cDescri := Space( 60 ),;
																						 Iif( nOpcRad == 1, oCodigo:SetFocus(), oDescri:SetFocus()) )
oRadio:cToolTip := OemToAnsi( STR0028 )
oRadio:oFont	:= oFont

@ (aObjSize[1,1] + 050),(aObjSize[1,2] + 005) Say OemToAnsi( STR0022 + ":") Size 100 , 010 Of oDlg Pixel Font oFont // "Código da Filial"

If Empty(aX3Box)
	@ (aObjSize[1,1] + 045),(aObjSize[1,2] + 100) MsGet oCodigo Var cCodigo Size 100 , 010 Of oDlg Pixel Font oFont When (nOpcRad == 1)

	If !Empty(cF3)
		oCodigo:cF3 := cF3
	EndIf

Else
	@ (aObjSize[1,1] + 045),(aObjSize[1,2] + 100) ComboBox oCodigo Var cCodigo Items aX3Box	Size 100 , 010 Of oDlg Pixel Font oFont When (nOpcRad == 1)
EndIf

@ (aObjSize[1,1] + 070),(aObjSize[1,2] + 005) Say OemToAnsi( STR0013 + ":") Size 100 , 010 Of oDlg Pixel Font oFont						//"descri‡„o"
@ (aObjSize[1,1] + 065),(aObjSize[1,2] + 100) MsGet oDescri VAR cDescri	Size 190 , 010 Of oDlg Pixel Font oFont When (nOpcRad == 2)

Activate MsDialog oDlg Centered On Init EnchoiceBar(oDlg,bSet15,bSet24)

If ( lbSet15 )
	Do Case
		Case ( nOpcRad == 1 )
			bSort	:= { |x,y| x[2] < y[2] }
			bAscan	:= { |x| x[2] $ cCodigo }
			cMsg	:= STR0029	//"c¢digo n„o encontrado"
		Case ( nOpcRad == 2 )
			bSort 	:= { |x,y| x[3] < y[3] }
			bAscan	:= { |x,y| Upper( AllTrim( cDescri ) ) $ SubStr( Upper( AllTrim( x[3] ) ) , 1 , Len( AllTrim( cDescri ) ) ) }
			cMsg	:= STR0030	//"descri‡„o n„o encontrada"
	End Case
	aCloneArr := aClone( oListBox:aArray )
	IF !( lNotOrdena )
		aSort( oListBox:aArray , NIL , NIL , bSort )
	EndIF
	IF ( ( ( nAt := aScan( oListBox:aArray , bAscan ) ) ) > 0 )
		oListBox:nAt := nAt
		oListBox:Refresh()
	Else
		MsgInfo( OemToAnsi( cMsg ) , cTitulo )
		oListBox:aArray := aClone( aCloneArr )
		oListBox:Refresh()
	EndIF
EndIF

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Restaura as Teclas de Atalho                     	  		  ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
RestKeys( aSvKeys , .T. )
SetKey( VK_F3 , bSvF3 )

Return oListBox:aArray

//---------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
@type			function
@description	Efetua a Troca da Selecao no ListBox da TafOpcoes(). Adaptada da função AdmexTroca.
@author			Karen Honda e Rafael Leme
@since			07/06/2021
@version		1.0
/*/
//---------------------------------------------------------------------

Static Function TafexTroca(	nAt			,;	//Indice do ListBox de AdmOpcoes()
							aArray		,;	//Array do ListBox de AdmOpcoes()
							l1Elem		,;	//Se Selecao apenas de 1 elemento
							nOpcoes		,;	//Numero de Elementos disponiveis para Selecao
							nElemRet	,;	//Numero de Elementos que podem ser Retornados
							nElemSel	,;	//Numero de Elementos Selecionados
							lMultSelect	,;	//Se Trata Multipla Selecao
							cTipo		 ;	//Tipo da Multipla Selecao "M"arca Todos; "D"esmarca Todos; "I"nverte Selecao
						   )

Local nOpcao		:= 0

DEFAULT nAt			:= 1
DEFAULT aArray		:= {}
DEFAULT l1Elem		:= .F.
DEFAULT nOpcoes		:= 0
DEFAULT nElemRet	:= 0
DEFAULT nElemSel	:= 0
DEFAULT lMultSelect := .F.
DEFAULT cTipo		:= "I"

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Coloca o Ponteiro do Cursor em Estado de Espera			   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
CursorWait()
	IF !Empty( aArray )
		IF !( l1Elem )
			IF !( lMultSelect )
				aArray[nAt,1] := !aArray[nAt,1]
				IF !( aArray[nAt,1] )
					--nElemSel
				Else
					++nElemSel
				EndIF
			ElseIF ( lMultSelect )
				IF ( cTipo == "M" )
					nElemSel := 0
					aEval( aArray , { |x,y| aArray[y,1] := IF( ( y <= nElemRet ) , ( ++nElemSel , .T. ) , .F. ) } )
				ElseIF ( cTipo == "D" )
					aEval( aArray , { |x,y| aArray[y,1] := .F. , --nElemSel } )
				ElseIF ( cTipo == "I" )
					nElemSel := 0
					aEval( aArray , { |x,y| IF( aArray[y,1] , aArray[y,1] := .F. , IF( ( ( ++nElemSel ) <= nElemRet ) , aArray[y,1] := .T. , NIL ) ) } )
					nElemSel := Min( nElemSel , nElemRet )
				EndIF
			EndIF
		Else
			For nOpcao := 1 To nOpcoes
				IF ( nOpcao == nAt )
					aArray[ nOpcao , 1 ]	:= .T.
				Else
					aArray[ nOpcao , 1 ]	:= .F.
				EndIF
			Next nOpcao
			nElemSel := 01
		EndIF
	EndIF
/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Restaura o Ponteiro do Cursor                  			   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
CursorArrow()

IF ( nElemSel > nElemRet )
	aArray[nAt,1] := .F.
	nElemSel := nElemRet
	MsgInfo(;
				OemToAnsi( STR0031 ) ,;	//If( cPaisLoc $ "ANG|PTG", "Excedeu o número de elementos permitidos para selecção", "Excedeu o número de elementos permitidos para seleção" )
				OemToAnsi( STR0032 )  ;	//If( cPaisLoc $ "ANG|PTG", "Atenção", "Atencao" )
		    )
ElseIF ( nElemSel < 0 )
	nElemSel := 0
EndIF

Return( aArray )

//---------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
@type			function
@description	Efetua Pesquisa Via Tecla F3. Adaptada da função AdmPesqF3.
@author			Karen Honda e Rafael Leme
@since			07/06/2021
@version		1.0
/*/
//---------------------------------------------------------------------

Static Function TafPesqF3( cF3 , cCampo , oListBox )

Local cAlias
Local lConpad1
Local nAt
Local uRetF3

IF FindFunction( "AliasCpo" )
	cAlias := AliasCpo( cCampo )
	IF (;
			!Empty( cAlias );
			.and.;
			( Select( cAlias ) > 0 );
		)
		lConpad1 := ConPad1( NIL , NIL , NIL , cF3 , NIL , NIL , .F. )
		IF( lConpad1 )
			uRetF3	:= ( cAlias )->( FieldGet( FieldPos( cCampo ) ) )
			nAt		:= aScan( oListBox:aArray , { |x| x[3] == uRetF3 } )
			IF ( nAt > 0 )
				oListBox:nAt := nAt
				oListBox:Refresh()
			Else
				MsgInfo( OemToAnsi( STR0029 ) ) //"c¢digo n„o encontrado"
			EndIF
		EndIF
	EndIF
EndIF

Return( NIL )
