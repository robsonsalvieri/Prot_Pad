#INCLUDE "PROTHEUS.CH"
#INCLUDE "DBTREE.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "APWIZARD.CH"
#INCLUDE "CTBA810.CH"

// ESTRUTURA DE DADOS DA ARRAY __ADADOSENT
#DEFINE AE_ENTIDADE		1
#DEFINE AE_DESCRICAO	2
#DEFINE AE_ALIAS		3
#DEFINE AE_CAMPO		4
#DEFINE AE_DESCITEM		5
#DEFINE AE_F3			6

#DEFINE TMPORI

#DEFINE BMPALTERAR 		"NOTE.PNG"

// Array principal para montagem e manipulaÁ„o da tela.
Static __aDadosEnt	:= {}
Static __CtbUseAmar := Nil

// Array contendo os dados de filtros.
Static __aFiltros	:= {}
Static __aFiliais	:= {cFilAnt}
Static __aTmpFil	:= {}
Static __aTmpAux	:= {}

Static nQtdEntid	:= Nil
Static __nTmpOri	:= Nil

Static __lConOutR	:= Nil

Static __lCTB810MNU	:= ExistBlock("CTB810MNU")
Static lCtb810Grv	:= ExistBlock("CTB810Grv")

Static nCont		:= 0
Static nAplySelect  := 0

Static jEntidades := Nil
Static oQryExec	  := Nil
Static _lPostgres := Upper(TcGetDb()) $ "POSTGRES"
Static _lOracle   := Upper(TcGetDb()) $ "ORACLE"

//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//± Funcao		 : CTBA810
//± Autor        : Renato Campos
//± Data         : 28/03/2013
//± Uso          : Rotina de AmarraÁ„o de entidades contabeis.
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

Function CTBA810( cAlias,nRecno,nOpc )
Local nIx	:= 0

Private aIndexFil	:= {}
Private aIndexes

Private cCadastro 	:= OemToAnsi(STR0001)  //"Cadastro AmarraÁ„o de entidades"

Private aHeaderOri	:= {}
Private aHeaderDes  := {}

Private cAliasOri	:= ""
Private cAliasEnt01	:= ""
Private cAliasEnt02	:= ""
Private cAliasDes	:= ""
Private cIndex 		:= ""

Private aResult 	
Private aAliasOri	:= {}

Private nEntAnt		:= 0 	//Entidade Anterior

//-----------------------------------
// ValidaÁıes para utilizaÁ„o da tela
//-----------------------------------
// Acesso somente pelo SIGACTB
If ( !AMIIn(34) )
	Return
EndIf

// Se o parametro estiver nulo, atribuo conforme a regra do parametro MV_CTBAMAR
If __CtbUseAmar == Nil
	__CtbUseAmar := CtbUseAmar() $ '2#3' 
Endif

If __lConOutR == Nil
	__lConOutR := FindFunction("CONOUTR")
EndIf

If !__CtbUseAmar .OR. ( FunName() <> "CTBA250" )
	// Se n„o tiver controle de amarraÁ„o, desvio para a CTBA250 
    CTBA250()   
	Return
EndIf

// Rotina disponivel somente para ambientes TOPCONN
If !IfDefTopCTB()
	MsgAlert( STR0032 )  //"AtenÁ„o, rotina disponivel somente para ambientes TOPConnect ou TOTVSDbAcess"
	Return
Endif

// Quantidade de entidades.
If nQtdEntid == NIL
	nQtdEntid := CtbQtdEntd()//sao 4 entidades padroes -> conta /centro custo /item contabil/ classe de valor
EndIf

// Define a posiÁ„o do temporario de origem
__nTmpOri := nQtdEntid + 1

// define o tamanho da array de temporarios
aAliasOri := Array(__nTmpOri)

For nIx := 1 To Len( aAliasOri )
	If nIx <= nQtdEntid
		aAliasOri[nIx]	:= CriaTmpOri( @aHeaderOri, nIx )
	Else
		aAliasOri[nIx]	:= CriaTmpOri( @aHeaderOri, 10 )   //coloca sempre 10 
	EndIf 
Next

If oQryExec != Nil	
	oQryExec:destroy()
	freeObj(oQryExec)
EndIf

cAliasDes	:= CriaTmpDes( @aHeaderDes ) 

CTBA810Dlg(cAlias,nRecno,nOpc)

If !Empty(aAliasOri)
	For nIx := 1 To Len(aAliasOri)
		DeleteTmp(aAliasOri[nIx])
	Next nIx
Endif

If !Empty( cAliasDes )
	DeleteTmp( cAliasDes )
Endif

CTDelTmpFil()
For nIx := 1 TO Len( __aTmpFil )
	CtbTmpErase( __aTmpFil[nIx] )
Next

__aTmpAux := {}   

Return

//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//± Funcao		 : CTBA810Dlg
//± Autor        : Renato Campos
//± Data         : 28/03/2013
//± Uso          : Efetua a montagem da tela (FwLayer, FwBrowse, xTree)
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

Function CTBA810Dlg(cAlias,nRecno,nOpc)
Local oDlg
Local oFWLayer, oWin01, oWin02, oWin03
Local oBarTree, oButtonBar 

Local aArea			:= GetArea()
Local aSize 		:= MsAdvSize(,.F.,400)
Local bSair			:= {|| oDlg:End() }

Local bActHide		:= {|| oWin03:Hide(), oWin02:Hide() , oWin03:Hide() }
Local bAction		:= {|| IIf( !VISUAL, CtbEditTree(.F.),.F.),oWin03:Show(),oWin04:Show() }
Local bGrava		:= {|| IIf( Ct810VFilt() , MsgRun(STR0033,"",{||CTBA810Grava(nOpc), oDlg:End() } ), .F.) }  //"Salvando os dados, aguarde..."
Local bFiltro		:= {|| MsgRun(STR0034,"",{||CtbEditTree(.T.),oWin03:Show(),oWin04:Show()} ) } //"Filtrando Dados, aguarde..."
Local bMarkAll		:= {|| If(!VerCartesi(1),NIL,(MarkOnOff(.T.),FiltraDestino(),oBrwWin01:Refresh()))}
Local bMarkAllDs	:= {|| If(!VerCartesi(3),NIL,(MarkDOnOff(.T.),FiltraDestino(),oBrwWin02:Refresh()))}
Local bAplyFilter   := {|| If(!VerCartesi(2),NIL,(nAplySelect:=If(Aviso( STR0035, STR0036,{ STR0037,STR0038})==1,1,0),;  //"Aplicar SeleÁ„o"##"Confirma a aplicaÁ„o dos novos itens selecionados ?"##"Sim"##"Nao"
 							If(nAplySelect==1,FiltraDestino(),NIL)))}
Local nWinOri 		:= 37
Local nWinDes 		:= 41

Private oBrwWin01, oBrwWin02

Private VISUAL		:= nOpc==2
Private INCLUI		:= nOpc==3
Private ALTERA		:= nOpc==4 
Private EXCLUI		:= nOpc==5

// retorna a array __aDadosEnt para a montagem dos componentes da tela
If !CtbGetEnt()
	MsgAlert( STR0039 )  //"Erro! N„o foi encontrado nenhuma entidade configurada."
	Return .F.
Endif

CTA->(DbSelectArea( "CTA" ))
CTA->(dbGoTo( nRecno ))

RegToMemory("CTA",.F.)

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ MONTAGEM DA TELA ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
DEFINE DIALOG oDlg TITLE ""  FROM aSize[7],0 to aSize[6],aSize[5]  PIXEL STYLE nOr(WS_VISIBLE,WS_POPUP)

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Cria instancia do fwlayer≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ 
oFWLayer := FWLayer():New()

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥Inicializa componente passa a Dialog criada,o segundo parametro È para ≥
//≥criaÁ„o de um botao de fechar utilizado para Dlg sem cabeÁalho 		  ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ 
oFWLayer:Init( oDlg, .T. )

// Efetua a montagem das colunas das telas
oFWLayer:AddCollumn( "Col01", 20, .T. )
oFWLayer:AddCollumn( "Col02", 80, .F. )

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Cria a window passando, nome da coluna onde sera criada, nome da window			 	≥
//≥ titulo da window, a porcentagem da altura da janela, se esta habilitada para click,	≥
//≥ se È redimensionada em caso de minimizar outras janelas e a aÁ„o no click do split 	≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ 
oFWLayer:AddWindow( "Col01", "Win01", STR0013	, 98 		, .F., .T.,	 			,,) //'Entidade'
oFWLayer:AddWindow( "Col02", "Win02", STR0040	, 20  		, .F., .T., {|| .T. }	,,) //'Dados da AmarraÁ„o'
oFWLayer:AddWindow( "Col02", "Win03", STR0041	, nWinOri  	, .F., .T., {|| .T. }	,,) //'Entidade de Origem'
oFWLayer:AddWindow( "Col02", "Win04", STR0042	, nWinDes  	, .F., .T., {|| .T. }	,,) //'Entidade de Destino'

oFWLayer:SetColSplit( "Col01", CONTROL_ALIGN_RIGHT,, {|| .T. } )

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Painel 1					  ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
oWin01	:= oFWLayer:GetWinPanel('Col01','Win01')

//--------------------------------
//Adiciona a arvore no painel 1
//--------------------------------
oTree	:= Xtree():New(00,00,oWin01:NCLIENTHEIGHT*.48,oWin01:NCLIENTWIDTH*.50, oWin01)
CriaArvore( oTree, bAction, bActHide )

//--------------------------------
//Adiciona as barras dos botıes
//--------------------------------
DEFINE BUTTONBAR oBarTree SIZE 10,10 3D BOTTOM OF oWin01
oButtTree		:= thButton():New(01,01, STR0008  , oBarTree,  bSair	,30,20,) //'Sair'

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Painel 2					  ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
oWin02 := oFWLayer:getWinPanel('Col02','Win02')
CtbGetAmar(oWin02,nOpc) 

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Painel 3					  ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
oWin03 := oFWLayer:getWinPanel('Col02','Win03')

//--------------------------------
//Adiciona o browse no painel 3
//--------------------------------
DEFINE FWBROWSE oBrwWin01 DATA TABLE ALIAS (aAliasOri[__nTmpOri]) OF oWin03 
ADD MARKCOLUMN   oColumn DATA { || Iif(( aAliasOri[__nTmpOri] )->MARCA=='T' ,'LBOK', 'LBNO' ) } DOUBLECLICK { |oBrwWin01| MarkOnOff(),FiltraDestino() } HEADERCLICK bMarkAll OF oBrwWin01		
LoadBrowse(aAliasOri[__nTmpOri], aHeaderOri, oBrwWin01)

If !VISUAL
	//--------------------------------
	//Adiciona as barras dos botıes
	//--------------------------------
	DEFINE BUTTONBAR oButtonBar SIZE 10,10 3D BOTTOM OF oWin03
	oButtTree := thButton():New(01,01, STR0043	, oButtonBar,  bMarkAll  	,50,20,) //"Marcar(Des) Todos"
	oButtTree := thButton():New(01,01, STR0044	, oButtonBar,  bFiltro   	,50,20,) //"Parametros"
	If Altera
		oButtTree := thButton():New(01,01, STR0045	, oButtonBar,  bAplyFilter 	,50,20,) //"Aplicar SeleÁ„o"
	EndIf
Endif
	
//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Painel 4					  ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
oWin04 := oFWLayer:getWinPanel('Col02','Win04')

//--------------------------------
//Adiciona o browse no painel 4
//--------------------------------
DEFINE FWBROWSE oBrwWin02 DATA TABLE ALIAS (cAliasDes) OF oWin04
ADD MARKCOLUMN   oColumn DATA { || Iif(( cAliasDes )->MARCA=='T' ,'LBOK', 'LBNO' ) } DOUBLECLICK { |oBrwWin02| MarkDOnOff() } HEADERCLICK bMarkAllDs OF oBrwWin02		
LoadBrowse(cAliasDes, aHeaderDes, oBrwWin02)
oBrwWin02:SetDelete(.T., {||.T.})

If !VISUAL
	DEFINE BUTTONBAR oBarTree SIZE 10,10 3D BOTTOM OF oWin04
	oButtTree := thButton():New(01,01, STR0043	, oBarTree,  bMarkAllDs ,50,20,) //"Marcar(Des) Todos"
	oButtTree := thButton():New(01,01, STR0046	, oBarTree,  bGrava	,30,20,) //'Gravar'
Endif
	
//Esconde os dados dos paineis 2 e 3 ao iniciar
oWin03:Hide(.T.)
oWin04:Hide(.T.)

If !INCLUI
	LoadDadosCTA()
	oWin04:Show(.T.)
	oBrwWin02:Refresh(.T.)
Endif

ACTIVATE DIALOG oDlg CENTERED

RestArea( aArea )

If jEntidades != Nil
	FreeObj(jEntidades)
	jEntidades := Nil
EndIf

Return  

//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//± Funcao		 : CriaArvore
//± Autor        : Renato Campos
//± Data         : 28/03/2013
//± Uso          : Cria a arvore (Pai e Filho) do painel 1 no xTree
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

Static Function CriaArvore( oTree, bAction, bActHide )
Local nIX
Local cCargo		:= "ENT"
Local cCargoEnt		:= ""

oTree:BeginUpdate()
oTree:Reset()

oTree:AddTree( STR0047,"IndicatorCheckBox","IndicatorCheckBoxOver",cCargo,bActHide) //'Entidade Cont·bil'

If Len(__aDadosEnt) > 0
	For nIx := 1 To Len(__aDadosEnt)
		
		cCargoEnt	:= cCargo+ __aDadosEnt[nIx][AE_ENTIDADE] 
			
		oTree:TreeSeek(cCargo)
		oTree:AddTree(	__aDadosEnt[nIx][AE_ENTIDADE] + " - " + __aDadosEnt[nIx][AE_DESCRICAO],; //descricao do node
						"IndicatorCheckBox", ; //bitmap fechado
						"IndicatorCheckBoxOver",; //bitmap aberto
						cCargoEnt , ;  //cargo (id)
						bAction ; //bAction - bloco de codigo para exibir
					 )
		
		oTree:EndTree()
	Next
Endif
    
oTree:EndUpdate()
oTree:Refresh()

Return oTree

//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//± Funcao		 : CtbGetAmar
//± Autor        : Renato Campos
//± Data         : 28/03/2013
//± Uso          : Monta a Get dos dados basicos da amarraÁ„o.
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

Static Function CtbGetAmar(oWin,nOpc) 
Local aAreaAtu	:= GetArea() 

Local aCpoEnch		:= {'NOUSER','CTA_REGRA','CTA_DESC'}
Local aIncluEnch	:= {'CTA_REGRA','CTA_DESC'}

Local cAliasE		:= 'CTA'
Local nModelo		:= 2

Private aTELA[0][0]
Private aGETS[0]

If IsInCallStack('CTBA250')
	oGet := MsMGet():New(cAliasE,(cAliasE)->(RecNo()),4,,,,aCpoEnch,{0,0,60,300},aIncluEnch,nModelo,,,,oWin)  //forca alteracao pois axinclui - ctba250
Else
	oGet := MsMGet():New(cAliasE,(cAliasE)->(RecNo()),nOpc,,,,aCpoEnch,{0,0,60,300},aIncluEnch,nModelo,,,,oWin)
EndIf
oGet:oBox:Align := CONTROL_ALIGN_ALLCLIENT


RestArea(aAreaAtu)

Return

//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//± Funcao		  : LoadBrowse
//± Autor         : Renato Campos
//± Data          : 28/03/2013
//± Uso           : Carrega a estrutura de dados no FWBrowse
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Static Function LoadBrowse(cAlias, aHeader, oBrowse, bDbClik)
Local nI
Private cIdProf810	:= "CT810" // Variavel para identificaÁ„o de ID quando existem multiplos browsers.

Default			:= {|| .T. }

oBrowse:SetUseFilter()
oBrowse:SetProfileID(cIdProf810) //Definindo ID para identificaÁ„o dos browser's.
//-------------------------------------------------------------------
// Adiciona as colunas do Browse
//-------------------------------------------------------------------
nI := 0
For nI := 1 To Len( aHeader )
	ADD COLUMN oColumn DATA &( '{ || ' + aHeader[nI][2] + ' }' ) Title aHeader[nI][1] PICTURE aHeader[nI][6] DOUBLECLICK bDbClik Of oBrowse
Next                                           

oBrowse:Activate()

Return( oBrowse )


//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//± Funcao		  : MarkOnOff
//± Autor         : Renato Campos
//± Data          : 28/03/2013
//± Uso           : 
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Static Function MarkOnOff( lAll )
Local nEntid		:= Val(oTree:aNodes[Val(oTree:CurrentNodeId)][2])-1
Local cQuery		:= ""
Local lMarca
Local nRecno		:= (aAliasOri[__nTmpOri])->(Recno())
Local nRecAux       
Default lAll		:= .F.
lMarca		:= ( (aAliasOri[__nTmpOri])->MARCA=='T' )

(aAliasOri[nEntid])->( dbGoTop() )

If (aAliasOri[nEntid])->( ! Eof() )
	cQuery := "UPDATE " + aAliasOri[__nTmpOri]
	If !lAll
		cQuery += "   SET MARCA = CASE WHEN MARCA = 'F' THEN 'T' ELSE 'F' END" 
		cQuery += " WHERE R_E_C_N_O_ = " +  StrZero( nRecno , 10 )
	Else
		cQuery += "   SET MARCA = '" + Iif( lMarca , 'F' , 'T' ) + "'" 
		
	Endif
	
	If CtbSqlExec( cQuery )
		TcRefresh( aAliasOri[__nTmpOri] )
		
		cQuery := "UPDATE " + aAliasOri[nEntid] + " SET MARCA = ( SELECT MARCA FROM " + aAliasOri[__nTmpOri] + " WHERE " + aAliasOri[__nTmpOri] + ".R_E_C_N_O_ = " + aAliasOri[nEntid] + ".R_E_C_N_O_ )" 
		If !lAll
			cQuery += " WHERE R_E_C_N_O_ = " +  StrZero( nRecno , 10 )
		Endif
			
		If CtbSqlExec( cQuery )
			TcRefresh( aAliasOri[nEntid] ) 
			TcRefresh( cAliasDes ) 
		Endif
		//este trecho eh somente para dar refresh na tabela---NAO RETIRAR
		nRecAux := 	( aAliasOri[nEntid] )->( Recno() )
		DbSelectArea( aAliasOri[nEntid] )
		dbGoBottom()
		dbGoTop()
		DbGoTo( nRecAux )
		//-----------------------------------------------------------------
		DbSelectArea( aAliasOri[__nTmpOri] )
		DbGoTo( nRecno )
	Endif                        
Endif                        

oBrwWin01:Refresh()
oBrwWin02:Refresh()
	
Return

//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//± Funcao		  : MarkDOnOff
//± Autor         : Renato Campos
//± Data          : 28/03/2013
//± Uso           : 
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Static Function MarkDOnOff(lAll)

Local cQuery		:= ""
Local nRecno		:= (cAliasDes)->(Recno())
Local lMarca        := .F.
Local aFiltSql      := {}
Local nX            := 0
local lSQL			:= .T.
Default lAll := .F.

//Se n„o confirmar a marcaÁ„o, retorna a funÁ„o.
If ! YesNoCheck()
	Return 
EndIf

lMarca		:= ( (cAliasDes)->MARCA=='T' )

cQuery := "UPDATE " + cAliasDes
If !lAll
	cQuery += "   SET MARCA = CASE WHEN MARCA = 'F' THEN 'T' ELSE 'F' END" 
	cQuery += " WHERE R_E_C_N_O_ = " +  StrZero( nRecno , 10 )
Else
	cQuery += "   SET MARCA = '" + Iif( lMarca , 'F' , 'T' ) + "'" 
	If ! Ct810VFilt(.F., aFiltSql,@lSQL) .and. lSQL  //Se existe filtro ativo coloca na clausula where
		If Len(aFiltSql) > 0
			cQuery += " WHERE "
			For nX := 1 to Len(aFiltSql)
				cQuery += IIf(nX==1, "", " AND ") + aFiltSql[Nx] + " "
			Next
		EndIf
	EndIf
EndIf
If lSQL
	If CtbSqlExec( cQuery )
		TcRefresh( cAliasDes )
		
		DbSelectArea( cAliasDes )
		DbGoTo( nRecno )
	Endif 
Else
	CtbAdvplExec(cAliasDes,aFiltSql)
EndIf

oBrwWin02:Refresh()
	
Return


//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
//
//                      FILTRAGEM E GRAVACAO DE DADOS
//
//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹


//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//± Funcao		  : CtbGetEnt 
//± Autor         : Renato Campos
//± Data          : 28/03/2013
//± Uso           : Busca os dados das entidades
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Static Function CtbGetEnt()
Local aArea		:= GetArea()

Local nTotEnt	:= 0
Local nX		:= 0

Local oEntCT0	:= Nil

__aDadosEnt := {}

// Conta
Aadd( __aDadosEnt , {"01", STR0048,"CT1","CT1_CONTA", "CT1_DESC01" , "CT1"	} )  //"Plano de Contas"
// Centro de Custo
Aadd( __aDadosEnt , {"02", STR0049,"CTT","CTT_CUSTO","CTT_DESC01" , "CTT"	} )  //"Centro de Custo"
// Item contabil
Aadd( __aDadosEnt , {"03", STR0050,"CTD","CTD_ITEM","CTD_DESC01" , "CTD"	} )  //"Item Cont·bil"  
// Classe de valor
Aadd( __aDadosEnt , {"04", STR0051,"CTH","CTH_CLVL","CTH_DESC01" , "CTH"	} )  //"Classe de Valor"

// Demais entidades
If nQtdEntid > 4
	oEntCT0:= Adm_List_Records():New()
	oEntCT0:SetAlias("CT0")  //alias
	oEntCT0:SetOrder(1)		//ordem do indice	
	oEntCT0:Fill_Records() //preenche os registros 

	For nX := 1 TO oEntCT0:CountRecords()
		oEntCT0:SetPosition(nX)
		oEntCT0:SetRecord()
	    
		If nX > 4
			Aadd( __aDadosEnt , {StrZero(nX,2), CT0->CT0_DSCRES, CT0->CT0_ALIAS, CT0->CT0_CPOCHV, CT0->CT0_CPODSC, CT0->CT0_F3ENTI} )
		Endif
	Next
	
	nTotEnt	:= oEntCT0:CountRecords() 
	oEntCT0 := Nil
Endif

RestArea( aArea )

Return ( Len(__aDadosEnt) > 0)


//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//± Funcao		  : FiltraOrigem
//± Autor         : Renato Campos
//± Data          : 28/03/2013
//± Uso           : Efetua a filtragem dos dados da Origem, escolhida na tree
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Static Function FiltraOrigem(nEntid, aResult )
Local cCodEnt		:= AllTrim(__aDadosEnt[nEntid][1])	//Codigo da Entidade
Local cAlias		:= Alltrim(__aDadosEnt[nEntid][3])  // Alias do filtro
Local lCpoClasse	:= ( cAlias $ 'CT1*CTT*CTD*CTH*CV0' ) // Filtra Classe
Local cQuery		:= ''
Local cFuncTrim     := "RTRIM("

If ! ( Alltrim( Upper(TcGetDb())) $ 'MSSQL7|MSSQL|ORACLE|DB2' )
	cFuncTrim     := "TRIM("
EndIf
 
//Limpa tabela temporaria
CtbSqlExec( "DELETE FROM "+ aAliasOri[__nTmpOri] )

// Monta a query de filtro dos dados
cQuery := "SELECT 'F' MARCA"

cQuery += "     , "+ cFuncTrim + Alltrim(__aDadosEnt[nEntid][4]) + " ) CODIGO"
cQuery += "     , "+ cFuncTrim + AllTrim(__aDadosEnt[nEntid][5]) + " ) DESCRICAO"
cQuery += "     , D_E_L_E_T_, R_E_C_N_O_ "
cQuery += "  FROM " + RetSqlName(cAlias) + " " + cAlias + " " 
cQuery += " WHERE " + PrefixoCpo(cAlias) + "_FILIAL = '" + xFilial(cAlias) + "'"
cQuery += "   AND " + Alltrim(__aDadosEnt[nEntid][4]) + " BETWEEN '" + aResult[nEntid,1] + "' AND '" + aResult[nEntid,2] + "' "

If lCpoClasse
	cQuery += "AND  "+PrefixoCpo(cAlias)+"_CLASSE = '2' "	
EndIf 

If cAlias == 'CV0
	cQuery += " AND CV0_PLANO = '"+ cCodEnt +"' "
EndIf		
			
If !Empty(aResult[nEntid, 3])
	_cFiltro := PcoParseFil( aResult[nEntid, 3], cAlias )
	
	If !Empty(_cFiltro)		
		cQuery += " AND "+_cFiltro
	Else
		If !MsgYesNo( STR0052 )   //"Somente ser„o aceitas expressıes exatas. As expressıes [ContÈm a express„o], [N„o ContÈm], [Esta Contido em] e [N„o esta Contido em]  n„o ser„o executadas.Prosseguir?")
			Return()  
		EndIf						
	EndIf
EndIf

cQuery += "   AND D_E_L_E_T_ = ' '"

If ! ( Alltrim( Upper(TcGetDb())) $ 'INFORMIX' )
	cQuery += " ORDER BY CODIGO "
EndIf

cQuery := ChangeQuery( cQuery )             
cQuery:= StrTran ( cQuery, "FOR READ ONLY", "")

cInsert := "INSERT INTO " + aAliasOri[__nTmpOri] + "(MARCA, CODIGO, DESCRICAO, D_E_L_E_T_, R_E_C_N_O_) " + cQuery

IF CtbSqlExec(cInsert)
	TcRefresh( aAliasOri[__nTmpOri] )

	// Efetua a copia dos registros para o temporario
	CopyEnt(aAliasOri[__nTmpOri],aAliasOri[nEntid])
Endif

oBrwWin01:Refresh()

Return

//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//± Funcao		  : FiltraDestino
//± Autor         : Renato Campos
//± Data          : 25/04/2013
//± Uso           : Executa o filtro do destino
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Static Function FiltraDestino() as logical
Local aArea as array
Local lContinua as logical

aArea := GetArea()

If Inclui 
	lContinua := CtbSqlExec( "DELETE FROM "+ cAliasDes )  //Limpa tabela temporaria
	TcRefresh( cAliasDes )
ElseIf Altera
	lContinua := nAplySelect > 0  //verifica se confirmou filtro selecionado atravez do Aviso
EndIf

If lContinua
	MsgRun( STR0053, STR0054 , {|| Ctb810Amar()} ) //"Aguarde"##"Carregando dados..."
	
	If Altera
		nAplySelect := 0
	EndIf
	
	TcRefresh( cAliasDes )

	oBrwWin01:Refresh()
	oBrwWin02:Refresh( .T. )
	
	oBrwWin02:SetFilterDefault( cAliasDes+"->(CTA_CONTA<>'ZZZZZZZZZZZZZZZZ' ) " )
	oBrwWin02:ExecuteFilter()
EndIf

RestArea( aArea )

Return .T.

//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//± Funcao		  : CopyEnt
//± Autor         : Renato Campos
//± Data          : 25/04/2013
//± Uso           : Executa a copia dos dados de origem para o destino
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Static Function CopyEnt(cAliasFrom, cAliasTO)
Local cQuery	:= ""    
Local cFuncTrim     := "RTRIM("

If ! ( Alltrim( Upper(TcGetDb())) $ 'MSSQL7|MSSQL|ORACLE|DB2' )
	cFuncTrim     := "TRIM("
EndIf

//Limpa tabela temporaria
cQuery := "DELETE FROM " + cAliasTO

If CtbSqlExec(cQuery)
	TcRefresh( cAliasTO )

	If Alltrim( Upper(TcGetDb())) $ 'INFORMIX'
		cQuery := "INSERT INTO " + cAliasTO +  " (MARCA, CODIGO, DESCRICAO, D_E_L_E_T_, R_E_C_N_O_) SELECT MARCA, "+cFuncTrim+" CODIGO ),"+cFuncTrim+" DESCRICAO ), D_E_L_E_T_, R_E_C_N_O_ FROM " + cAliasFrom 
	Else
		cQuery := "INSERT INTO " + cAliasTO +  " (MARCA, CODIGO, DESCRICAO, D_E_L_E_T_, R_E_C_N_O_) (SELECT MARCA, "+cFuncTrim+" CODIGO ), DESCRICAO, D_E_L_E_T_, R_E_C_N_O_ FROM " + cAliasFrom + ")"
	EndIf
	CtbSqlExec(cQuery)
Endif
	
TcRefresh(cAliasTO)

oBrwWin01:Refresh()

Return

//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//± Funcao		  : LoadDadosCTA
//± Autor         : Felipe Cunha
//± Data          : 26/04/2013
//± Uso           : Informa parametros para seleÁ„o de dados 
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Static Function LoadDadosCTA()
Local cQuery	:= ""
Local cCampos	:= ""
Local nX		:= 0

//Informa quais colunas ser„o exibidas
cCampos := "CTA_CONTA,CTA_CUSTO,CTA_ITEM,CTA_CLVL"

For nX := 5 To nQtdEntid 
	cCampos += "," + AllTrim("CTA_ENTI") + STRZERO(nX,2)
Next nX

If Alltrim( Upper(TcGetDb())) $ 'INFORMIX'
	cQuery += "INSERT INTO " + cAliasDes + " ( MARCA, " + cCampos + ", D_E_L_E_T_, R_E_C_N_O_)  "
Else
	cQuery += "INSERT INTO " + cAliasDes + " ( MARCA, " + cCampos + ", D_E_L_E_T_, R_E_C_N_O_)  ( "	
EndIf

cQuery += "SELECT 'T', " + cCampos + ", D_E_L_E_T_, R_E_C_N_O_
cQuery += "  FROM " + RetSqlName( "CTA" ) + " CTA "
cQuery += " WHERE CTA_FILIAL = '" + xFilial( "CTA" ) + "'"
cQuery += "   AND CTA_REGRA = '" + M->CTA_REGRA + "'"
cQuery += "   AND D_E_L_E_T_  = ' '"
If ! ( Alltrim( Upper(TcGetDb())) $ 'INFORMIX' )
	cQuery += ")"
EndIF 

If CtbSqlExec(cQuery)
	TcRefresh( cAliasDes )
Endif

//Ao inicializar a grid carregada, posicionar no topo 
(cAliasDes)->(dbGoTop())

Return


//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//± Funcao		  : CtbEditTree
//± Autor         : Felipe Cunha
//± Data          : 26/04/2013
//± Uso           : Informa parametros para selecÁ„o de dados 
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Static Function CtbEditTree(lForce)
Local cAlias
LocaL cCodEnt		:= ""
Local cCampo 		:= ""
Local cFiltro 		:= ""
Local cF3 			:= ""
Local cRange_De 	:= ""
Local cRange_Ate    := ""
Local cDesc			:= ""
Local cDesc2		:= ""
Local cTitulo 		:= SubStr(oTree:GetPrompt(),At('-',oTree:GetPrompt())+2,Len(oTree:GetPrompt()))
Local aParametros	:= {}
Local aConfig 		:= {}  
Local aTamCpo       
Local lRet 			:= .T.
Local nEntid		:=Val(oTree:aNodes[Val(oTree:CurrentNodeId)][2])-1
Local lFiltra		:= .F.

Default lForce		:= .F.

If ValType(aResult) == "U"
	aResult := 	ARRAY( Len(__aDadosEnt) )
EndIf

cCodEnt		:= AllTrim(__aDadosEnt[nEntid][1])	//Codigo da Entidade
cDesc		:= AllTrim(__aDadosEnt[nEntid][2])	//Nome da Entidade
cF3 		:= Alltrim(__aDadosEnt[nEntid][3])  //Consulta Padr„o
cCampo 		:= Alltrim(__aDadosEnt[nEntid][4])	//Campo Chave	               
cDesc2		:= AllTrim(__aDadosEnt[nEntid][5])	//Campo DescriÁ„o
cAlias		:= Alltrim(__aDadosEnt[nEntid][3])
aTamCpo 	:= TamSX3(cCampo)[1]				//Tamanho do Campo

//-------------------------------------------
//Se for a primeira vez, chama tela de
//filtro para informar parametros.
//Senao aplica o ultimo filtro ja gravado
//-------------------------------------------
If aResult[nEntid] == NIL   
	cRange_De 	:= Space(aTamCpo)
	cRange_Ate 	:= Replicate("Z",aTamCpo)
	cFiltro 	:= ""     
Else
	cRange_De 	:= aResult[nEntid, 1]
	cRange_Ate 	:= aResult[nEntid, 2]
	cFiltro		:= aResult[nEntid, 3]
EndIf

//Cria campos da tela de filtro.
aAdd(aParametros,{1, Alltrim(cDesc)+" de "	, cRange_De		, "" 	,"",cF3	,""	, aTamCpo*5 , .F. } ) 	//" de "
aAdd(aParametros,{1, Alltrim(cDesc)+" atÈ "	, cRange_Ate	, "" 	,"",cF3	,""	, aTamCpo*5 , .F. } ) 	//" Ate "
aAdd(aParametros,{7, "Filtro "				, cF3			,cFiltro,""} ) 							  	//"Filtro "

If aResult[nEntid] == NIL .Or. lForce
	lFiltra := ParamBox(  aParametros ,cTitulo,aConfig,,,.F.,,,,,.F.)

	If lFiltra
		aResult[nEntid] := aClone(aConfig)
		oTree:ChangeBmp(BMPALTERAR,BMPALTERAR,oTree:GetCargo()) 
	Else
		aResult[nEntid] := aClone( {cRange_De, cRange_Ate, ""} ) 
	Endif
EndIf

IF nEntAnt <> 0
	CopyEnt(aAliasOri[__nTmpOri],aAliasOri[nEntAnt])
Endif

If lFiltra
	// Efetua a filtro dos dados.
	FiltraOrigem(nEntid, aResult)
Else
	// Efetua a copia dos dados j· filtrados
	CopyEnt(aAliasOri[nEntid],aAliasOri[__nTmpOri])
Endif

nEntAnt := nEntid

oBrwWin01:Refresh( .T. )

Return lRet

//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
//
//                    MONTAGEM DE ESTRUTURA DE DADOS
//
//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹


//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//± Funcao		  : CriaTmpOri
//± Autor         : Renato Campos
//± Data          : 28/03/2013
//± Uso           : Cria a tabela temporaria a ser usada no FwBrowse de Origem
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Static Function CriaTmpOri( aHeader, nEntidAux )
Local aChvOri   := {}
Local aCampos	:= {}
Local nCont
Local nTam	:= TAMSX3("CT1_DESC01")[1]
Local nTmaior	:= 0
Local cAliasOri	:= ""
Local aCpos	:={"CTH_DESC01","CT1_DESC01","CTT_DESC01","CTD_DESC01","CV0_DESC"}

Default nEntidAux := 0

For nCont:=1 to Len(aCpos)
		nTam := TAMSX3(aCpos[ncont])[1]
	If nTmaior < nTam
		ntmaior := nTam
	EndIf
	
Next nCont



Default aHeader	:= {}

If Len( aHeader ) <= 0
	//aAdd( aHeader, { "Marca"		, "MARCA"	, "L", 1,0,".F." } )
	aAdd( aHeader, { STR0055, "CODIGO"	, "C", TamSx3("CT1_CONTA")[1],0,"@!" } )  //"Entidade"
	aAdd( aHeader, { STR0056, "DESCRICAO","C",nTmaior,0,"@!" } )  //"DescriÁ„o"
Endif
	
Aadd( aCampos, { "MARCA"		, "C", 1,0} )

If 			nEntidAux == 1
	Aadd( aCampos, { "CODIGO"		, "C", TamSx3("CTA_CONTA")[1],0} )
ElseIf 		nEntidAux == 2
	Aadd( aCampos, { "CODIGO"		, "C", TamSx3("CTA_CUSTO")[1],0} )
ElseIf 		nEntidAux == 3
	Aadd( aCampos, { "CODIGO"		, "C", TamSx3("CTA_ITEM")[1],0} )
ElseIf	 	nEntidAux == 4
	Aadd( aCampos, { "CODIGO"		, "C", TamSx3("CTA_CLVL")[1],0} )
ElseIf	 	nEntidAux == 5
	Aadd( aCampos, { "CODIGO"		, "C", TamSx3("CTA_ENTI05")[1],0} )
ElseIf 		nEntidAux == 6
	Aadd( aCampos, { "CODIGO"		, "C", TamSx3("CTA_ENTI06")[1],0} )
ElseIf 		nEntidAux == 7
	Aadd( aCampos, { "CODIGO"		, "C", TamSx3("CTA_ENTI07")[1],0} )
ElseIf 		nEntidAux == 8
	Aadd( aCampos, { "CODIGO"		, "C", TamSx3("CTA_ENTI08")[1],0} )
ElseIf 		nEntidAux == 9
	Aadd( aCampos, { "CODIGO"		, "C", TamSx3("CTA_ENTI09")[1],0} )
Else
	Aadd( aCampos, { "CODIGO"		, "C", TamSx3("CT1_CONTA")[1],0} )
EndIf
//MAIOR DESCRICAO
Aadd( aCampos, { "DESCRICAO"	, "C",nTmaior,0} )

// Montagem da Matriz aChvDes ( Chaves de Busca )
Aadd( aChvOri, "CODIGO" )

If ExistBlock( "CTC810CORI" )
	ExecBlock( "CTC810CORI" , .F. , .F. , {aCampos, aChvOri})			
Endif
	
// Cria o temporario a ser utilizado na tela.
cAliasOri := CriaTmp( aCampos, aChvOri )

RETURN cAliasOri

//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//± Funcao	   	  : CriaTmpDes
//± Autor         : Renato Campos
//± Data          : 28/03/2013
//± Uso           : Cria a tabela temporaria a ser usada no FwBrowse de Destino
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Static Function CriaTmpDes(aHeader)
Local aChvDes   := {}
Local aCampos	:= {}
Local aObrigat	:= {}

Local cAliasDes := ""  
lOCAL Nx 		:= 0

Default aHeader	:= {}

//Informa quais colunas ser„o exibidas
Aadd( aObrigat, "CTA_CONTA" )
Aadd( aObrigat, "CTA_CUSTO" )
Aadd( aObrigat, "CTA_ITEM" 	)
Aadd( aObrigat, "CTA_CLVL" 	)

For nX :=5 To nQtdEntid 
	Aadd( aObrigat, AllTrim("CTA_ENTI") + STRZERO(nX,2))
Next nX

Aadd( aCampos, { "MARCA"		, "C", 1,0} )

// Carrega os campos da CTA a partir do dicionario
CtbLoadSx3( 'CTA', aObrigat, @aHeader, @aCampos )

// Montagem da Matriz aChvDes ( Chaves de Busca )
//Aadd( aChvDes, "CTA_CONTA,CTA_CUSTO,CTA_ITEM,CTA_CLVL" )

If ExistBlock( "CTC810CDES" )
	ExecBlock( "CTC810CDES" , .F. , .F. , {aCampos, aChvDes})			
Endif

// Cria o temporario a ser utilizado na tela.
cAliasDes := CriaTmp( aCampos, aChvDes )
cIndex := "I" + cAliasDes
(cAliasDes)->(dbCreateIndex(cIndex, "CTA_CONTA", {|| "CTA_CONTA"}))

RETURN cAliasDes


//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//± Funcao	   	  : CriaTmp
//± Autor         : Renato Campos
//± Data          : 28/03/2013
//± Uso           : Cria a tabela temporaria a ser usada no FwBrowse no Banco
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Static Function CriaTmp( aCampos, aChaves )
Local aArea		:= GetArea()

Local cArq		:= ""
Local cChave	:= ""

Local nIx		:= 0

Default aChaves := {}

cArq	:= CriaTrab(,.F.)
If aScan(__aTmpAux, cArq)>0
	While aScan(__aTmpAux, cArq)>0
		aAdd(__aTmpAux, cArq)
		cArq	:= CriaTrab(,.F.)
	EndDo
Else	
	aAdd(__aTmpAux, cArq)
EndIf

MsCreate(cArq, aCampos, "TOPCONN")
Sleep(100)

dbUseArea( .T., "TOPCONN", cArq, cArq, .F., .F. )

If Len( aChaves ) > 0
	// Efetua a criaÁ„o da tabela no banco
	For nIx := 1 TO Len( aChaves )
		cChave := aChaves[nIx]
		
		cOrdName := "X"+ StrZero( nIx ,2)+cArq 
		If ( !TcCanOpen(cArq,cOrdName) )
			INDEX ON &(ClearKey( cChave )) TO &(cOrdName)
   		EndIf

		DbSetIndex(cOrdName)
		DbSetNickName(OrdName(nIx),cOrdName)
	Next nIx
	
	DbSelectArea( cArq )
	DbSetOrder(1)
	Sleep(100)
Endif

RestArea(aArea)

Return cArq

//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//± Funcao		  : DeleteTmp
//± Autor         : Renato Campos
//± Data          : 28/03/2013
//± Uso           : Delela o temporario criado
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

Static Function DeleteTmp( cAliasTmp )
Local aArea := GetArea()

If cAliasTmp <> NIL .And. Valtype(cAliasTmp) == "C" .And. !Empty(cAliasTmp)
	If Select(cAliasTmp) > 0
		DbSelectArea(cAliasTmp)
		dbCloseArea()
	EndIf

	MsErase(cAliasTmp)
EndIf

RestArea(aArea)

Return

//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//± Funcao		  : CtbLoadSx3
//± Autor         : Renato Campos
//± Data          : 28/03/2013
//± Uso           : Carrega os campos da SX3 para a criaÁ„o do temporario
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

Static Function CtbLoadSx3( cAlias, aObrigat, aHeader, aCampos )

local aSX3Aux	:= {}	as array
local cNivAux	:= ""	as character
local cFldAux	:= ""	as character
local nX		:= 0	as numeric

Default aObrigat	:= {}
Default aHeader		:= {}
Default aCampos		:= {}

	// Montagem da matriz aCampos
	aSX3Aux := FwSX3Util():getAllFields(cAlias)

	for nX := 1 to len(aSX3Aux)
	
		cFldAux	:= aSX3Aux[nX]
		cNivAux := getSx3cache( cFldAux, "X3_NIVEL" )

		if cNivel >= cNivAux

			if ( len( aObrigat ) > 0 .And. aScan( aObrigat , Alltrim(cFldAux) ) <= 0 )
				SX3->( DbSkip() )
				loop
			endif

			aAdd( aHeader, {getSX3Cache(cFldAux, "X3_TITULO")	,; 
							cFldAux								,;
							getSX3Cache(cFldAux, "X3_TIPO")		,; 
							getSX3Cache(cFldAux, "X3_TAMANHO")	,;
							getSX3Cache(cFldAux, "X3_DECIMAL")	,;
							getSX3Cache(cFldAux, "X3_PICTURE")	,;
							getSX3Cache(cFldAux, "X3_USADO") })
			
			aAdd( aCampos, {cFldAux	,;
							getSX3Cache(cFldAux, "X3_TIPO")		,;
							getSX3Cache(cFldAux, "X3_TAMANHO")	,;
							getSX3Cache(cFldAux, "X3_DECIMAL") })

		endif

	next nX

	FwFreeArray(aSX3Aux)

Return


//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//± Funcao		  : CtbSqlExec
//± Autor         : Renato Campos
//± Data          : 25/04/2013
//± Uso           : Executa a instruÁ„o de banco via TCSQLExec
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

Static Function CtbSqlExec( cStatement )
Local bBlock	:= ErrorBlock( { |e| ChecErro(e) } )
Local lRetorno := .T.

BEGIN SEQUENCE
	IF TcSqlExec(cStatement) <> 0
		UserException( STR0057 + CRLF + TCSqlError()  + CRLF + ProcName(1) + CRLF + cStatement )  //"Erro na instruÁ„o de execuÁ„o SQL"
		lRetorno := .F.
	Endif
RECOVER
	lRetorno := .F.
END SEQUENCE
ErrorBlock(bBlock)

Return lRetorno

//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//± Funcao		  : MontaQuery
//± Autor         : Renato Campos
//± Data          : 28/03/2013
//± Uso           : Monta a query
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Static Function MontaQuery(oQryOri)

Local nIx as numeric
Local nOrigem as numeric
Local nCont as numeric
Local cQuery as character
Local cFrom	as character
Local cWhere as character
Local cFuncTrim as character

nIx		  := 0
nOrigem   := 0
nCont     := 1
cQuery    := "SELECT "
cFrom     := "FROM "
cWhere    := ""
cFuncTrim := "RTRIM("

If ! ( Alltrim( Upper(TcGetDb())) $ 'MSSQL7|MSSQL|ORACLE|DB2' )
	cFuncTrim     := "TRIM("
EndIf

For nIx := 1 TO Len( aAliasOri ) - 1 	
	If aResult[nIx] <> NIL  .And. Ctb810Qlp(aAliasOri[nIx])
		cQuery += cFuncTrim+" "+aAliasOri[nIx] + ".CODIGO )"

		If nIx <= 4
			cQuery += " CTA_" + Substr( __aDadosEnt[nIx][AE_CAMPO] , 5 )
		Else
			cQuery += " CTA_ENTI" + StrZero( nIx , 2 )
		Endif
		cFrom  += aAliasOri[nIx]
	
		cWhere := AddSqlExpr( cWhere , aAliasOri[nIx] + ".MARCA = ?"      )
		cWhere := AddSqlExpr( cWhere , aAliasOri[nIx] + ".D_E_L_E_T_ = ?" )
		nOrigem++

		cQuery += ", "
		cFrom  += ", "		
	Endif
Next

cQuery := Substr( cQuery , 1 , Len(cQuery) - 2)
cFrom  := Substr( cFrom  , 1 , Len(cFrom) - 2 )
cQuery := If(nOrigem > 0, ChangeQuery( cQuery + cFrom + cWhere ), "")

If !Empty(cQuery)
	oQryOri := FWExecStatement():New(cQuery)
	For nIx := 1 To nOrigem		
		oQryOri:SetString(nCont++, "T")
		oQryOri:SetString(nCont++, Space(1))
	Next nIx
EndIf

Return

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥CTBA810Grava Autor≥TOTVS               ∫ Data ≥  07/04/10   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ Gravacao                                                   ∫±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ AP                                                         ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ/ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function CTBA810Grava(nOpc)
Local nIx			:= 0
Local cCodRegra	:= M->CTA_REGRA									//Codigo da Regra
Local cQuery     := ""
Local cProc      := "INSERT INTO CTA"

Local cCpoFixCTA := "CTA_FILIAL, CTA_REGRA, CTA_DESC, CTA_NIVEL, CTA_ITREGR,"

Local cCposCTA   := ""
Local cVarsCTA   := ""

Local lEntid05   := .F.
Local lEntid06   := .F.
Local lEntid07   := .F.
Local lEntid08   := .F.
Local lEntid09   := .F.
Local cSqlCta	 := ""
Local cNameRecno := " @iRecno" 
Local cConcat 	 := " + "
Local cFuncChar  := "CHAR"

Default lCtb810Grv	:= ExistBlock("CTB810Grv")	

//Se n„o confirmar a gravaÁ„o, retorna a funÁ„o
If ! YesNoCheck()
	MsgAlert(STR0067) //"OperaÁ„o cancelada."
	Return
Endif

For nIx := 1 TO Len( aHeaderDes )
	If ( cAliasDes )->(FieldPos(aHeaderDes[nIx][2])) > 0 .And. CTA->(FieldPos( aHeaderDes[nIx][2] )) > 0
		cCposCTA += Alltrim(aHeaderDes[nIx][2])+", "
		cVarsCTA += Alltrim(aHeaderDes[nIx][2])+", "
				
		If   		Alltrim(aHeaderDes[nIx][2])  == "CTA_ENTI05"
					lEntid05   := .T.
		
		ElseIf   	Alltrim(aHeaderDes[nIx][2])  == "CTA_ENTI06"
					lEntid06   := .T.

		ElseIf   	Alltrim(aHeaderDes[nIx][2])  == "CTA_ENTI07"
					lEntid07   := .T.

		ElseIf   	Alltrim(aHeaderDes[nIx][2])  == "CTA_ENTI08"
					lEntid08   := .T.

		ElseIf   	Alltrim(aHeaderDes[nIx][2])  == "CTA_ENTI09"
					lEntid09   := .T.

		Endif


	Endif
Next nCont
		
cCposCTA += " R_E_C_N_O_ "

BEGIN TRANSACTION

//Este comando SQL vai excluir todos os registros com o mesmo codigo de amarracao
If nOpc == 4 // alteracao

	cQuery := " DELETE FROM "
	cQuery += RetSqlName("CTA") + " "
	cQuery += " WHERE " 
	cQuery += "       CTA_FILIAL = '"+xFilial("CTA")+"' "
	cQuery += "   AND CTA_REGRA = '"+M->CTA_REGRA+"' "
	cQuery += "   AND D_E_L_E_T_  = ' ' "
	
	If TcSqlExec( cQuery  ) <> 0
		UserException( "CTBA810 - Error in delete - Table" + RetSqlName(cAlias) ;
					+ CRLF + "Error: " + CRLF + TCSqlError() )
	EndIf   

EndIf

DbSelectArea( "CTA" )
DbSetOrder(0)
					
MsgRun(STR0069,STR0054)//"Gravando Registros" --"Aguarde"

If _lPostgres
	cConcat := " || " 
	cFuncChar  := "CHR"
	cNameRecno := " iRecno"
	cSqlCta +="DO $$" + CRLF
	cSqlCta +="DECLARE "+ cNameRecno +" INTEGER; " + CRLF
	cSqlCta +="BEGIN" +CRLF
	cSqlCta +="SELECT COALESCE(MAX(R_E_C_N_O_), 0) INTO iRecno FROM "+ RetSqlName("CTA") +" ; " +CRLF
ElseIf _lOracle
	cNameRecno := " iRecno"
	cFuncChar  := "CHR"
	cConcat := " || " 
	cSqlCta +="DECLARE "+ cNameRecno +" INTEGER; " + CRLF
	cSqlCta +="BEGIN" +CRLF
	cSqlCta +="SELECT NVL(MAX(R_E_C_N_O_), 0) INTO iRecno FROM "+ RetSqlName("CTA") +" ; " +CRLF
Else
	cSqlCta +="DECLARE "+ cNameRecno +" INTEGER; " + CRLF
	cSqlCta +="SELECT @iRecno = COALESCE(MAX(R_E_C_N_O_), 0) FROM "+ RetSqlName("CTA") +" ; " +CRLF
Endif

cSqlCta+= " INSERT INTO "+ RetSqlName("CTA") +" ("+cCpoFixCTA+cCposCTA+") " + CRLF

cSqlCta += ' SELECT ' + CRLF
	
cSqlCta += "'"+xFilial('CTA')+"'" + CRLF
cSqlCta += ",'"+cCodRegra+"' " + CRLF
cSqlCta += ",'"+M->CTA_DESC+"'" + CRLF
cSqlCta += ",'1'" + CRLF

//TRATAMENTO CTA_ITREGR EM PROCEDURE USAVA O SOMA1
cSqlCta += ", CASE " + CRLF
cSqlCta += "   WHEN rn < 10000 THEN " + CRLF
If _lOracle
	cSqlCta += "        LPAD(TO_CHAR(rn), 4, '0') " + CRLF
Else
	cSqlCta += "        RIGHT('0000' "+cConcat+" CAST(rn AS VARCHAR), 4) " + CRLF
EndIf
cSqlCta += "    WHEN rn < 36000 THEN " + CRLF
cSqlCta += cFuncChar+ "(CAST(65 + ((rn - 10000) / 1000)AS INTEGER) ) "+cConcat+" " + CRLF
If _lOracle
	cSqlCta += "        LPAD(TO_CHAR(MOD((rn - 10000), 1000)), 3, '0') " + CRLF
Else
	cSqlCta += "        RIGHT('000' "+cConcat+" CAST((rn - 10000) % 1000 AS VARCHAR), 3) " + CRLF
EndIf
cSqlCta += "    WHEN rn < 38600 THEN " + CRLF
cSqlCta += "        'Z' "+cConcat+" " + CRLF
cSqlCta += cFuncChar+ "(CAST(65 + ((rn - 36000) / 100)AS INTEGER)) "+cConcat+" " + CRLF
If _lOracle
	cSqlCta += "        LPAD(TO_CHAR(MOD((rn - 36000), 100)), 2, '0') " + CRLF
Else
	cSqlCta += "        RIGHT('00' "+cConcat+" CAST((rn - 36000) % 100 AS VARCHAR), 2) " + CRLF
EndIf
cSqlCta += "    WHEN rn < 38860 THEN " + CRLF
cSqlCta += "        'ZZ' "+cConcat+" " + CRLF
cSqlCta += cFuncChar+"(CAST(65 + ((rn - 38600) / 10)AS INTEGER)) "+cConcat+" " + CRLF
If _lOracle
	cSqlCta += "        TO_CHAR(MOD((rn - 38600), 10)) " + CRLF
Else
	cSqlCta += "        CAST((rn - 38600) % 10 AS VARCHAR) " + CRLF
EndIf
cSqlCta += "    WHEN rn < 38886 THEN " + CRLF
cSqlCta += "        'ZZZ' "+cConcat+" "+cFuncChar+"(CAST(65 + (rn - 38860)AS INTEGER)) " + CRLF
cSqlCta += "    ELSE " + CRLF
cSqlCta += "        'ZZZZ' " + CRLF
cSqlCta += " END AS CTA_ITREGR," + CRLF

cSqlCta += cVarsCTA
cSqlCta += cNameRecno + " + rn AS R_E_C_N_O_ " + CRLF

cSqlCta += " FROM ( SELECT "+cVarsCTA+" ROW_NUMBER() OVER (ORDER BY CTA_CONTA) AS rn FROM " + cAliasDes  + " WHERE MARCA = 'T' AND D_E_L_E_T_ = ' ' ) SUBQUERY"
If _lPostgres
	cSqlCta += ";"+CRLF+"END $$;"
EndIf
If _lOracle
	cSqlCta += ";"+CRLF+"END ;"
EndIf

If TcSqlExec(cSqlCta) <> 0
	MsgAlert( "CTBA810 - Error in exec procedure - Table: " + RetSqlName("CTA") + " Procedure: " + cProc ) 
	DisarmTransaction()	 
EndIf

If nOpc == 3
	ConfirmSx8()
EndIf

END TRANSACTION

//PE executado apÛs a gravaÁ„o das amarraÁıes de entidade
If lCtb810Grv
	ExecBlock("CTB810Grv", .F., .F.,{nOpc})
EndIf		                                            

Return()


//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//± Funcao		  : Ctb810Qlp
//± Autor         : Felipe Cunha
//± Data          : 23/07/2013
//± Uso           : 
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Static Function Ctb810Qlp(cAliasTmp)

local cAlsAux	:= ""	as character
local cQuery	:= ""	as character
local nX		:= 1	as numeric
local lRet		:= .F.	as logical
local oAlsQry	:= Nil	as object

	//Verifica se a tabela de origem esta populada
	cQuery := "SELECT COUNT(CODIGO) AS NREG FROM ? WHERE MARCA = ? AND D_E_L_E_T_ = ? "

	oAlsQry := FWExecStatement():New( ChangeQuery( cQuery ) )
	oAlsQry:SetUnsafe(nX++, cAliasTmp)
	oAlsQry:SetString(nX++, "T")
	oAlsQry:SetString(nX++, Space(1))
	
	cQuery := oAlsQry:GetFixQuery()

	oAlsQry:destroy()
	freeObj(oAlsQry)

	cAlsAux := MPSysOpenQuery(cQuery)
	
	if (cAlsAux)->NREG > 0
		lRet := .T.
	endif
	
	(cAlsAux)->(dbCloseArea())

Return lRet

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥CtbRegCt0 ∫ Autor ≥TOTVS               ∫ Data ≥  04/07/10   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ Retorna array com os registros da CT0                      ∫±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ AP                                                         ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function CtbRegCt0()
Local aArea	:= GetArea()
Local aRegs	:= {}
DbSelectArea('CT0')
DbSetOrder(1)
If DbSeek(xFilial('CT0')) 
	While !Eof() .And. xFilial('CT0') == CT0->CT0_FILIAL
			AADD( aRegs , {CT0->CT0_ALIAS , CT0->CT0_ENTIDA, CT0->CT0_ID, CT0->CT0_CPOCHV,CT0->CT0_CPODSC,CT0->CT0_F3ENTI } )  
		DbSkip()			
	EndDo			
EndIf                        
RestArea( aArea )
Return aRegs

//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//± Funcao		  : VerCartesi()
//± Autor         : Paulo Carnelossi
//± Data          : 04/08/2015
//± Uso           : Verifica se cartesiano ao Marcar Todos excede 100.000 reg.
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Static Function VerCartesi(nOption)
Local lRet 		:= .T.
Local nEntidOri	:= Val(oTree:aNodes[Val(oTree:CurrentNodeId)][2])-1
Local aRetCount := {}
Local nResult  	:= 1
Local lMarcado
Local nX

Default nOption := 1

If nOption == 1   //marcar / desmarcar

	lMarcado 	:= ( (aAliasOri[nEntidOri])->MARCA=='T' )
	
	If !lMarcado  //se nao estiver marcado vai marcar todos ai valida senao nao eh necessario
		//montar query entre marcados x Entidade posicionada e pressionado Marcar Todos e retornar array  
		aRetCount := MontQryMrk(nEntidOri, .F.)
		//faz multiplicacao de todos os elementos do array
		For nX := 1 TO Len(aRetCount)	
			nResult *= aRetCount[nX]
		Next
	EndIf

ElseIf nOption == 2  // aplicar filtro na alteracao
	
	//montar query entre marcados x Entidade posicionada e pressionado Marcar Todos e retornar array  
	aRetCount := MontQryMrk(nEntidOri, .T.)
	//faz multiplicacao de todos os elementos do array
	For nX := 1 TO Len(aRetCount)	
		nResult *= aRetCount[nX]
	Next
	
	//soma a nResult a quantidade ja incluida no destino antes de aplicar filtro
	nResult += QryDestino()

ElseIf nOption == 3  //marcar / desmarcar entidade destino

	lMarcado 	:= ( (cAliasDes)->MARCA=='T' )
	
	If !lMarcado  //se nao estiver marcado vai marcar todos ai valida senao nao eh necessario
		//montar query entre marcados x Entidade posicionada e pressionado Marcar Todos e retornar array  
		aRetCount := MontQryMrk(nEntidOri, .T.)
		//faz multiplicacao de todos os elementos do array
		For nX := 1 TO Len(aRetCount)	
			nResult *= aRetCount[nX]
		Next
	EndIf

	nResult += QryDestino()

EndIf

//se atingiu os 50.000 registro informa ao usuario e nao deixa marcar todos
If nResult > 50000 //(maior que cem mil registros avisa e nao deixa prosseguir com marcar todos)
	Aviso(STR0058, STR0059+If(nOption==1, STR0060, STR0061)+CRLF+; //"Atencao"##"O numero de combinacoes pretendidas ao marcar todos excede a 50.000 registros, portanto n„o ser· "##"marcado."##"aplicado."
					STR0062+;   //"Usuario deve restringir o numero de registros a marcar e se necessario deve se efetuar uma nova "
					STR0063, {STR0064})  //"amarracao com outro codigo, pois na avaliacao da regra n„o e considerado o codigo da amarracao."##"Fechar"
	lRet := .F.
EndIf

Return(lRet)

//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//± Funcao		  : MontQryMrk
//± Autor         : Renato Campos/Paulo Carnelossi
//± Data          : 28/03/2013
//± Uso           : Monta query p cartesiano entre os marcados x Marcar Todos
//±               : retorna um array contendo as contagem por entidade
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Static Function MontQryMrk(nEntOrig, lMark)

Local nIx			:= 0
Local nY			:= 0
Local cQuery		:= " "
Local aRetorno      := {}
Local cNewAlias   	:= CriaTrab(,.F.)
Local aArea 		:= GetArea()
Local oQryMrk		:= Nil

Default lMark := .F.

For nIx := 1 TO Len( aAliasOri ) - 1 
	
	If Ctb810Qlp(aAliasOri[nIx])

		nY := 1
		
		cQuery := " SELECT COUNT(R_E_C_N_O_) NREG FROM ? WHERE"
	
		if nIx != nEntOrig .OR. lMark
			cQuery += " MARCA = ? AND"
		endif	
		
		cQuery += " D_E_L_E_T_ = ?"

		oQryMrk := FWExecStatement():New(cQuery)
		oQryMrk:SetUnsafe(nY++, aAliasOri[nIx])
		
		if nIx != nEntOrig .OR. lMark
			oQryMrk:SetString(nY++, 'T')
		endif
		
		oQryMrk:SetString(nY++, Space(1))

		cNewAlias := oQryMrk:OpenAlias(GetNextAlias())

		If ( cNewAlias )->NREG > 0
			aAdd(aRetorno, ( cNewAlias )->NREG)
		Else
			aAdd(aRetorno, 1)
		EndIf

		( cNewAlias )->(dbCloseArea())
		
		oQryMrk:destroy()
		freeObj(oQryMrk)

	Else
		aAdd(aRetorno, 1)
	Endif
Next

RestArea(aArea)

Return(aRetorno)


//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//± Funcao		  : QryDestino
//± Autor         : Renato Campos/Paulo Carnelossi
//± Data          : 28/03/2013
//± Uso           : Monta query p/ contar na tabela destino todos os ja marcados
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

Static Function QryDestino()

Local aArea 		:= GetArea()
Local cNewAlias   	:= ""
Local cQuery		:= ""
Local nRetorno      := 0
Local oQryDes		:= Nil

	cQuery := " SELECT COUNT(R_E_C_N_O_) NREG FROM ? "
	cQuery += " WHERE MARCA = ? AND D_E_L_E_T_ = ? "
	cQuery := ChangeQuery( cQuery )

	oQryDes := FWExecStatement():New(cQuery)
	oQryDes:SetUnsafe(1, cAliasDes)
	oQryDes:SetString(2, 'T')
	oQryDes:SetString(3, Space(1))

	cNewAlias := oQryDes:OpenAlias(GetNextAlias())

	If ( cNewAlias )->NREG > 0
		nRetorno := ( cNewAlias )->NREG
	EndIf

	( cNewAlias )->( dbCloseArea() )

	oQryDes:destroy()
	freeObj(oQryDes)

	RestArea(aArea)

Return nRetorno

//-----------------------------------------------------------------------------------------
/*
{Protheus.doc}Ct810VFilt
FunÁ„o que verifica se na grade de destino esta com filtro ativado

@author Totvs
@since  23/12/2022
@version 12
*/
//-----------------------------------------------------------------------------------------
Static Function Ct810VFilt(lShowMsg as Logical , aFiltSql as Array, lSql as Logical) as Logical
Local lRet := .T.	   as Logical
Local nX   			   as Numeric
Local lFilterOn := .F. as Logical

Default lShowMsg := .T.
Default lSql 	 := .T.

//VERIFICA SE NAO FILTRO NO FWBROWSE DO DESTINO E CASO EXISTA AVISA USUARIO PARA REMOVER O FILTRO
//oBrwWin02 È variavel private portanto visivel neste ponto
If Len(oBrwWin02:oFwFilter:aFilter) > 0 
	//verifica se tem algum filtro ativo - caso positivo ja retorna .F.
	For nX := 1 to Len(oBrwWin02:oFwFilter:aFilter)
		If oBrwWin02:oFwFilter:aFilter[nX][6] .And. oBrwWin02:GetFilterDefault() != oBrwWin02:oFwFilter:aFilter[nX][2]
			lRet := .F.
			lFilterOn := .T.
			Exit
		EndIf
	Next
	If lFilterOn .and. aFiltSql != NIL .And. Valtype(aFiltSql)=="A"
		cfilter := ExecFilter(oBrwWin02:oFwFilter:GetFilter(.F.),@lSql)
		If !lSql
			cfilAux := PcoParseFil( cFilter,"CTA" )
			If !Empty(cfilAux) 
				lSql := .T.
				cfilter := cfilAux
			EndIf
		EndIf
		If !Empty(cFilter) .and. !Empty(StrTran(StrTran(cFilter,'(',''),')',''))
			aAdd(aFiltSql, cfilter)
		EndIf
	EndIf
	
	If !lRet .And. lShowMsg
		MsgInfo(STR0065,STR0029)  // "Esta Grade no momento da gravaÁ„o dos dados n„o pode estar com filtro ativo. Favor remover filtro, verificar se as amarraÁıes est„o corretas e novamente pressionar bot„o Gravar." ##"AtenÁ„o"
	EndIf
	
EndIf

Return(lRet)

//-----------------------------------------------------------------------------------------
/*
{Protheus.doc}YesNoCheck
FunÁ„o que verifica o resultado do MsgYesNo()

@author Totvs
@since  10/03/2023
@version 12
*/
//-----------------------------------------------------------------------------------------

Static Function YesNoCheck() as Logical

Local lRet as Logical 
lRet := .F.

If ProcName(1) == "CTBA810GRAVA"
	lRet := MsgYesno(STR0066) //"Deseja Confirmar a GravaÁ„o ?"
ElseIf ProcName(1) == "MARKDONOFF"
	lRet := MsgYesno(STR0068) //"Deseja Marcar/ Desmarcar Todos ?"
Endif

Return lRet

//-----------------------------------------------------------------------------------------
/*
{Protheus.doc}Ctb810Amar
FunÁ„o que incoui/atualiza as amarracoes na na tabela de destino

@author Totvs
@since  24/10/2024
@version 12
*/
//-----------------------------------------------------------------------------------------
Static Function Ctb810Amar()

Local cQuery as character
Local cAliasOri as character
Local cAliasAuxDes as character
Local cCampo as character
Local cCampos as character
Local cKeyEnt as character
Local aCampos as array
Local aValues as array
Local nX as numeric
Local oQryOri as Object
Local oQryAuxDes as Object
Local oQryFindDes as Object
Local oBulk as object

//Monta query das entidades (origem)
MontaQuery(@oQryOri)

If oQryOri != Nil	
	Ctb810Clear()
	cAliasOri := oQryOri:OpenAlias(GetNextAlias())	
	cCampos := "CTA_CONTA, CTA_CUSTO, CTA_ITEM, CTA_CLVL"
	aCampos := {{"MARCA"}, {"CTA_CONTA"}, {"CTA_CUSTO"}, {"CTA_ITEM"}, {"CTA_CLVL"}}
	
	For nX := 1 To Len(__aDadosEnt)
		If nX > 4			
			cCampos += ","+"CTA_ENTI"+__aDadosEnt[nX][AE_ENTIDADE]
			aAdd(aCampos, {"CTA_ENTI"+__aDadosEnt[nX][AE_ENTIDADE]})
		EndIf			
	Next nX

	If nEntant <= 4
		cCampo := AllTrim("CTA_"+Substr(__aDadosEnt[nEntant][AE_CAMPO], 5))
	Else
		cCampo := "CTA_ENTI"+StrZero(nEntant, 2)
	EndIf

	//Monta query do temporario de destino
	If ALTERA						
		//Busca informacoes na tabela de amarracoes
		cQuery := " SELECT ?"
		cQuery += " FROM ?"
		cQuery += " WHERE D_E_L_E_T_ = ?"
		cQuery := ChangeQuery(cQuery)

		oQryAuxDes := FWExecStatement():New(cQuery)
		oQryAuxDes:SetUnsafe(1, cCampos) 
		oQryAuxDes:SetUnsafe(2, cAliasDes) 
		oQryAuxDes:SetString(3, Space(1)) 
		cAliasAuxDes := oQryAuxDes:OpenAlias(GetNextAlias())
	EndIf
	
	oBulk := FwBulk():New(cAliasDes)
	oBulk:setFields(aCampos)

	If jEntidades == Nil
		jEntidades := JsonObject():New()
	EndIf
					
	While (cAliasOri)->(!Eof())		
		If INCLUI
			aValues := {}
			cKeyEnt := ""
								
			For nX := 1 To Len(aCampos)													
				If aCampos[nX][1] == "MARCA"
					aAdd(aValues, "T")						
				Else //Copia entidades ja existentes para o novo registro							
					cKeyEnt += AllTrim((cAliasOri)->&(aCampos[nX][1]))
					aAdd(aValues, (cAliasOri)->&(aCampos[nX][1]))
				EndIf					
			Next nX					

			If jEntidades[cKeyEnt] == Nil
				jEntidades[cKeyEnt] := .T.
				oBulk:AddData(aValues)						
			EndIf																					
		Else //Alteracoes
			//Verifica se entidade ja existe no temporario de amarracoes		
			If !Ctb810Ent(@oQryFindDes, cAliasDes, cCampo, (cAliasOri)->&(cCampo))
				(cAliasDes)->(dbGoTop())
				
				If Empty((cAliasDes)->&(cCampo)) //Update amarracoes
					While (cAliasDes)->(!Eof())						
						RecLock((cAliasDes),.F.)
						(cAliasDes)->&(cCampo) := (cAliasOri)->&(cCampo)
						(cAliasDes)->(MsUnLock())
						
						(cAliasDes)->(dbSkip())
					EndDo

					(cAliasOri)->(dbSkip())
					Loop
				Else												
					(cAliasAuxDes)->(dbGoTop())

					While (cAliasAuxDes)->(!Eof())
						aValues := {}
						cKeyEnt := ""
											
						For nX := 1 To Len(aCampos)													
							If aCampos[nX][1] == "MARCA"
								aAdd(aValues, "T")
							ElseIf AllTrim(cCampo) == AllTrim(aCampos[nX][1]) //Adiciona nova entidade							
								cKeyEnt += AllTrim((cAliasOri)->&(cCampo))
								aAdd(aValues, (cAliasOri)->&(cCampo))
							Else //Copia entidades ja existentes para o novo registro							
								cKeyEnt += AllTrim((cAliasAuxDes)->&(aCampos[nX][1]))
								aAdd(aValues, (cAliasAuxDes)->&(aCampos[nX][1]))
							EndIf					
						Next nX					

						If jEntidades[cKeyEnt] == Nil
							jEntidades[cKeyEnt] := .T.
							oBulk:AddData(aValues)						
						EndIf
																
						(cAliasAuxDes)->(dbSkip())
					EndDo								
				EndIf
			EndIf
		EndIf
			
		(cAliasOri)->(dbSkip())			
	EndDo

	(cAliasDes)->(dbSetIndex(cIndex))

	If INCLUI
		If jEntidades != Nil
			FreeObj(jEntidades)
			jEntidades := Nil
		EndIf
	EndIf

	oBulk:Close()
    oBulk:Destroy()
    FreeObj(oBulk)

	(cAliasOri)->(dbCloseArea())
	oQryOri:Destroy()
	FreeObj(oQryOri)
	
	If oQryFindDes != Nil
		oQryFindDes:Destroy()
		FreeObj(oQryFindDes)
	EndIf
	
	If oQryAuxDes != Nil
		(cAliasAuxDes)->(dbCloseArea())
		oQryAuxDes:Destroy()
		FreeObj(oQryAuxDes)
	EndIf
EndIf
FwFreeArray(aCampos)
FwFreeArray(aValues)

Return Nil

//-----------------------------------------------------------------------------------------
/*
{Protheus.doc}Ctb810Ent
FunÁ„o que verifica se a entidade existe na tabela de destino (amarracoes)

@author Totvs
@since  24/10/2024
@version 12
*/
//-----------------------------------------------------------------------------------------
Static Function Ctb810Ent(oQryFindDes as Object, cAliasTmp as character, cCampo as character, cValEnt as character) as logical

Local cQuery as character
Local lRet as logical

If oQryFindDes == Nil
	cQuery := "SELECT COUNT(1) ENTIDADE FROM ?"	
	cQuery += " WHERE ? = ?"
	cQuery += " AND D_E_L_E_T_ = ?"
	cQuery := ChangeQuery(cQuery)

	oQryFindDes := FWExecStatement():New(cQuery)
EndIf

oQryFindDes:SetUnsafe(1, cAliasTmp)
oQryFindDes:SetString(2, cCampo)
oQryFindDes:SetString(3, cValEnt)
oQryFindDes:SetString(4, Space(1))

lRet := oQryFindDes:ExecScalar("ENTIDADE") > 0

Return lRet

//-----------------------------------------------------------------------------------------
/*
{Protheus.doc}Ctb810Clear
FunÁ„o que limpa linha inconsistente das amarracoes

@author Totvs
@since  24/10/2024
@version 12
*/
//-----------------------------------------------------------------------------------------
Static Function Ctb810Clear()

Local cQuery as character
Local cAliasAuxDes as character
Local nX as numeric
Local nCont as numeric
Local nRegs as numeric
Local aCampos as array
Local oQryDest as Object

nRegs := 0

If !INCLUI
	(cAliasDes)->(dbGoTop())
	While (cAliasDes)->(!Eof()) .And. nRegs <= 1
		nRegs++
		(cAliasDes)->(dbSkip())
	EndDo
	
	If nRegs > 1
		aCampos := {"CTA_CONTA", "CTA_CUSTO", "CTA_ITEM", "CTA_CLVL"}
		
		For nX := 1 To Len(__aDadosEnt)
			If nX > 4						
				aAdd(aCampos, "CTA_ENTI"+__aDadosEnt[nX][AE_ENTIDADE])
			EndIf			
		Next nX
	
		cQuery := "SELECT R_E_C_N_O_ AS RECNO FROM ?"
		cQuery += " WHERE "
		For nX := 1 To Len(aCampos)
			cQuery += " ? = ?"
			cQuery += " AND "
		Next nX
		cQuery += " D_E_L_E_T_ = ?"
		cQuery := ChangeQuery(cQuery)

		oQryDest := FWExecStatement():New(cQuery)

		nCont := 1
		oQryDest:setUnsafe(nCont++, cAliasDes)
		For nX := 1 To Len(aCampos)
			oQryDest:setUnsafe(nCont++, aCampos[nX])
			oQryDest:SetString(nCont++, Space( getSX3Cache(aCampos[nX],'X3_TAMANHO') ))		
		Next nX
		oQryDest:SetString(nCont++, Space(1))
	
		cAliasAuxDes := oQryDest:OpenAlias(GetNextAlias())

		If (cAliasAuxDes)->(!Eof())
			(cAliasDes)->(dbGoTo((cAliasAuxDes)->RECNO))
			Reclock((cAliasDes), .F.)
			(cAliasDes)->(dbDelete())
			(cAliasDes)->(MsUnLock())
		EndIf
	
		(cAliasAuxDes)->(dbCloseArea())
		oQryDest:Destroy()
		FreeObj(oQryDest)
	EndIf	
EndIf

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} MontaFiltr
Retorna a string do filtro

@param aFilter - Array contendo os dados do filtro [FWFilter:GetFilter]
@param nPos - PosiÁ„o que ser· utilizado para pegar as informaÁıes do filtro
@param cAnd - Operador lÛgico AND conforme ADVPL ou SQL

@return cFilter - String contendo o filtro SQL ou ADVPL

@author Controladoria
@since 04/06/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Static function MontaFiltr(aFilter as Array, nPos as Numeric, cAnd as Character) as Character

Local nFor 		:= 0 	as Numeric 
Local cFilter 	:= ""	as Character

For nFor := 1 to Len(aFilter)
	If "Programa" $ aFilter[nFor][1] 
		Loop
	EndIf
    if !Empty(aFilter[nFor][nPos])
        cFilter += " ("+aFilter[nFor][nPos] + ") "+ cAnd
    EndIf
Next

Return cFilter


//-------------------------------------------------------------------
/*/{Protheus.doc} ExecFilter
FunÁ„o auxiliar para a criaÁ„o da express„o do filtro

@param aFilter - Array contendo os dados do filtro [FWFilter:GetFilter]
@param lSQL - Indica se ser· possÌvel utilizar um filtro SQL [ReferÍncia]

@return cFilter - String contendo o filtro, podendo ser um filtro SQL ou ADVPL

@author Controladoria
@since 04/06/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Static function ExecFilter(aFilter as Array,lSql as Logical) as Character

Local nPos		:= 0 	as Numeric 
Local cAnd 		:= ""   as Character
Local cFilter 	:= ""	as Character
Local nSizeAnd 	:= 0	as Numeric 

lSQL := VldSQLFilt(aFilter)

If lSQL
    cAnd := " AND "
    nPos := 3
    nSizeAnd := 5
Else
    cAnd := " .And. "
    nPos := 2
    nSizeAnd := 7
Endif

cFilter := MontaFiltr(aFilter, nPos, cAnd)
cFilter := Left(cFilter, Len(cFilter) - nSizeAnd)

aSize(aFilter, 0)
aFilter := nil

Return cFilter


//-------------------------------------------------------------------
/*/{Protheus.doc} VldSQLFilt
Retorna se o filtro È SQL ou ADVPL

@param aFilter - Array contendo os dados do filtro [FWFilter:GetFilter]

@return lSQL - Indica se ser· possÌvel utilizar um filtro SQL

@author Controladoria
@since 04/06/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Static function VldSQLFilt(aFilter as Array) as Logical

Local lSQL	:= .T. as Logical
Local nFor 	:= 0   as Numeric	
Local nLoop := 0   as Numeric

For nFor := 1 to Len(aFilter)
    //Filtro SQL vazio
	If "Programa" $ aFilter[nFor][1] 
		Loop
	EndIf
    If Empty(aFilter[nFor][3])
        lSQL := .F.
        exit
    Else
        //Filtro do tipo funÁ„o ou express„o
        For nLoop := 1 to Len(aFilter[nFor][4])
            If aFilter[nFor][4][nLoop][2] $ "USEREXP|FUNCTION"
                lSQL := .F.
                Exit
            EndIf
        Next
        If !lSQL
            Exit
        EndIf
    EndIf
Next

Return lSQL


//-----------------------------------------------------------------------------------------
/*
{Protheus.doc}CtbAdvplExec
FunÁ„o que Marca ou Desmarca as amarracoes na na tabela de destino quando o Filtro n„o da suporte para expressao em SQL
Vide Filtros especificos de Informar na ExecuÁ„o utilizando "Contem" por exemplo.
@author Ewerton Franklin	
@since  10/06/2025
@version 12
*/
//-----------------------------------------------------------------------------------------
Static Function CtbAdvplExec(cDestAlias as Character,aFilAdvpl as Array)

Local cQuery 	as character
Local cAuxAlias as character
Local nX 	 	as numeric
Local cCampos 	as character
Local lAltera 	as Logical

cCampos := "MARCA, CTA_CONTA, CTA_CUSTO, CTA_ITEM, CTA_CLVL"

For nX := 1 To Len(__aDadosEnt)
	If nX > 4			
		cCampos += ","+"CTA_ENTI"+__aDadosEnt[nX][AE_ENTIDADE]
	EndIf			
Next nX
If oQryExec == Nil	//Reutiliza Query
	//Busca informacoes na tabela de amarracoes
	cQuery := " SELECT " + cCampos + ", R_E_C_N_O_ RECNO "
	cQuery += " FROM "+ cDestAlias
	cQuery += " WHERE D_E_L_E_T_ = ? "
	cQuery := ChangeQuery(cQuery)

	oQryExec := FWExecStatement():New(cQuery)
	oQryExec :SetString(1, Space(1)) 
EndIf


cAuxAlias := oQryExec:OpenAlias(GetNextAlias())
While (cAuxAlias)->(!Eof())	
	lAltera :=.F.
	For nX:= 1 to len(aFilAdvpl)
		If (cAuxAlias)->&(aFilAdvpl[nX])
			lAltera:= .T.
		EndIf
	Next
	If lAltera
		lMarca	:= ( (cAuxAlias)->MARCA=='T' )
		(cAliasDes)->(dbGoTo((cAuxAlias)->RECNO))
		Reclock((cAliasDes), .F.)
			(cAliasDes)->MARCA := Iif( lMarca , 'F' , 'T')
		(cAliasDes)->(MsUnLock())
	EndIf
	(cAuxAlias)->(DbSkip())
Enddo

(cAuxAlias)->(DBCloseArea())
Return Nil
