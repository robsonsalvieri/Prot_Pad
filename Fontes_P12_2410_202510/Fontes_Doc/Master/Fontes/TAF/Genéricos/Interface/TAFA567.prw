#INCLUDE "PROTHEUS.CH"
#INCLUDE "FW_POSCSS.CH"
#INCLUDE "TAFA567.CH"

Static lFindClass 	:= FindFunction("TAFFindClass") .And. TAFFindClass( "FWCSSTools" )
Static lLaySimplif	:= TafLayESoc("S_01_00_00")

/*/{Protheus.doc} TAFA567
    Função de comparação de dados posicionados com dados comparativos
@type function
@version 
@author edvf8
@since 01/07/2020
@param cCPFPos, character, CPF do trabalhador posicionado
@param cNomePos, character, Nome do trabalhador posicionado
@param cEventoPos, character, Evento do trabalhador posicionado
@param dDtAltPos, date, Data de Alteração do registro do trabalhador posicionado
/*/
Function TAFA567(cCPFPos,cNomePos,cEventoPos,dDtAltPos )
    
//------------------------------------------
//VARIÁVEIS PARA DIMENSIONAMENTO DE 
//ACORDO COM O TAMANHO DA TELA E FORMATAÇÃO
//------------------------------------------
Local aRes		    := GetScreenRes()	// Recupera Resolução atual
Local nWidth	    := aRes[1]		// Largura 
Local nHeight       := aRes[2]		// Altura 
Local nTmGrd        := 0            // Controle para montagem de grid de posicionamento de objetos 
Local nTmGrdCpo     := 0            // Controle dos tamanhos do campo
Local oTFont        := TFont():New('Arial Black',,-14,.T.)
Local lElectron		:= IIf(lFindClass, (FWCSSTools():GetInterfaceCSSType() == 5), .F.)
Local lRemote		:= GetRemoteType() == REMOTE_HTML

//----------------------------------------------------------------------
//VARIÁVEIS PARA CAMPOS LIBERADOS PARA EDIÇÃO E PRÉ-CARREGAMENTO DE TELA
//----------------------------------------------------------------------
Local cFiltCPF      := Space(TamSx3("C9V_NOME")[1]) //STRING DE PROCURA
Local cIndCMB       := Space(1)
Local aFields       := {STR0001,STR0002,STR0003}//COLUNAS DO GRID # 'CAMPO','EVENTO POSICIONADO','EVENTO COMPARADO'
Local aMotivos      := {STR0004,STR0005,STR0006}//OPÇÕES DO COMBO DE FILTRO # '1=Campo','2=Evento Posicionado','3=Evento Comparado'

//========================================
//COMPONENTES DE TELA
//========================================
Local oModal 		:= NIl			//Dialog Modal
Local oPanel    	:= NIl			//Painel que receberá a area útil do Modal
Local oPanelSub 	:= NIL          //Necessário a criação para inclusão do tercerio TGROUP.
Local oBrowse   	:= NIL          //TWBROWSE Carregará os dados ao clicar no processamento

//--------------------------------------------------
//ÁREA DE CAMPOS E TITULOS DO REGISTRO POSICIONADO
//--------------------------------------------------
Local oGDPos    	:= NIL          //Agrupador de campos de registro posicionado
Local oSCPFPos  	:= NIL	        //Label de CPF
Local oGCPFPos  	:= NIL          //Campo de CPF
Local oSTrbPos  	:= NIL	        //Label Nome do trabalhador
Local oGTrbPos  	:= NIL	        //Campo Nome do Trabalhador
Local oSEvtPos  	:= NIL	        //Label Evento
Local oGEvtPos  	:= NIL	        //Campo Evento 
Local oSDtAltPos	:= NIL          //Label Data de Alteração 
Local oGDtAltPos	:= NIL          //Campo Data de Alteração 

//--------------------------------------
//ÁREA DE CAMPOS E TITULOS DO COMPARADOR
//--------------------------------------
Local oGComp    	:= NIL          //Agrupador de campos de registro comparador
Local oSCPFCmp  	:= NIL	        //Label de CPF
Local oCPFCmp   	:= NIL          //Campo de CPF
Local oSTrbCmp  	:= NIL	        //Label Nome do trabalhador
Local oGTrbCmp  	:= NIL	        //Campo Nome do Trabalhador
Local oSEvtCmp  	:= NIL	        //Label Evento
Local oGEvtCmp  	:= NIL	        //Campo Evento 
Local oSDtAlt   	:= NIL          //Label Data de Alteração
Local oGDtAlt   	:= NIL          //Campo Data de Alteração

//--------------------------------------
//ÁREA DE CAMPOS E TITULOS DE FILTRO
//--------------------------------------
Local oTGFilt		:= NIL          //Agrupador de Campos de Filtro 
Local oSCMBCOL		:= NIL          //Label do combobox
Local oSCMBFILT		:= NIL          //ComboBox com opções de filtro
Local oSTermFilt	:= NIL          //Label do campo de busca
Local oGFilt		:= NIL          //Campo de busca

//-------------------------
//BOTÕES DE TELA
//-------------------------
Local oBtnFil		:= NIL
Local oBtnProc		:= NIL
Local oBtnClose		:= NIL

//--------------------------------------------------------
//BLOCOS DE CÓDIGO QUE REPRESENTAM AS AÇÕES EM TELA(BOTÕES)
//--------------------------------------------------------
Local bExecute		:= {|| TAFProcCmp(cCpfPos,cEventoPos,dDtAltPos,@oBrowse) } 
Local bClose    	:= {||oModal:Deactivate()}   
Local bExecFil		:= {||oBrowse:GoPosition( fPosReg(cFiltCPF,Val(cIndCMB),aBrowse) )}
Local bLDblClick	:= {||fViewDLG(aBrowse[oBrowse:nAt],aFields)}

Private cFilialCom  := ""
Private nRecnoCom   := 0
Private cCpfCom   	:= Space(TamSx3("C9V_CPF")[1])
Private cNomeCom  	:= Space(TamSx3("C9V_NOME")[1])
Private cEventoCom	:= Space(TamSx3("C9V_NOMEVE")[1])
Private dDtAltCom 	:= Space(TamSx3("C9V_DINSIS")[1])
Private cFilCs		:= ''
Private cFilialpos	:= ''
Private cIdpos		:= ''
Private cId			:= ''
Private cCpf 		:= ''
Private cNome 		:= ''
Private cEvento 	:= ''
Private dData 		:= SToD(' / / ')
Private nRecnoPos 	:= 0
Private aBrowse		:= {{"","",""}} //Variável onde irá conter os dados do grid

//---------------------------------------------------------------
//PROTEÇÃO DE DADOS PARA NÃO IMPACTAR NO CARREGAMENTO DA TELA 
//---------------------------------------------------------------
Default cCpfPos     := Space(TamSx3("C9V_CPF")[1])
Default cNomePos    := Space(TamSx3("C9V_NOME")[1])
Default cEventoPos  := Space(TamSx3("C9V_NOMEVE")[1])
Default dDtAltPos   := Space(TamSx3("C9V_DINSIS")[1])


If	AliasIndic("V5O") ;
 	.AND. X3Uso( Posicione( "SX3", 2, "V5P_ITEM", "X3_USADO" )); 
 	.AND. X3Uso( Posicione( "SX3", 2, "V5Q_ITEM", "X3_USADO" )) 

	//--------------------------------------------------------
	//CARREGANDO DADOS NOS CAMPOS DO REGISTRO POSICIONADO,
	//SELEÇÃO BASEADA NO ALIAS TEMPORÁRIO DA TELA DE HISTÓRICO
	//--------------------------------------------------------
	If ValType("ID") != Nil .And. !Empty(ID)    .And. Empty(cCpfPos)

	    cCpfPos     := CPF
    	cNomePos    := NOME
    	cEventoPos  := NOMEVE
    	cFilialpos	:= FILIAL
    	cIdpos		:= ID
    	dDtAltPos   := fGetDtAlt(RECNO,cEventoPos)
    	nRecnoPos	:= RECNO

	EndIf

	cCpf 		:= cCpfPos
	cNome		:= cNomePos
	cEvento		:= cEventoPos
	cId			:= cIdpos
	cFilCs		:= cFilialpos
	dData		:= dDtAltPos

	//-----------------
	//MONTAGEM DA TELA
	//-----------------
	oModal  := FWDialogModal():New()
	oModal:SetBackground(.F.)
	oModal:SetTitle(STR0007)//"Interface Comparadora"
	oModal:lFontBoldTitle:= .T.
	oModal:enableFormBar(.F.)
	//-------------------------
	//DIMENSIONAMENTO DA DIALOG
	//--------------------------
	nWidth      := (nWidth/2)  * 0.5
	nHeight     := (nHeight/2) * 0.6
	oModal:SetFreeArea(nWidth,nHeight)
	oModal:createDialog()
	oTFont:Bold := .T.
	//------------------------------------------------------------------
	//MONTAGEM DE GRID PARA DIMENSIONAMENTO E LAYOUT DOS OBJETOS EM TELA
	//------------------------------------------------------------------
	nTmGrd		:= nWidth/4 //POSICIONAMENTO DOS OBJETOS DENTRO DA DIALOG
	nTmGrdCpo	:= nTmGrd-(nTmGrd*0.1) //TAMANHO DO CAMPO

	//------------------------------------------
	//PEGANDO A ÁREA ÚTIL PARA OS COMPONENTES.
	//------------------------------------------
	oPanel 		:= TPanel():New(0,0,'',oModal:getPanelMain(),,.T.,.T.,,,nWidth,nHeight,.T.,.T.)

	//-----------------------------------------------
	//AGRUPAMENTO DE OBJETOS DE REGISTRO POSICIONADO
	//-----------------------------------------------
	oGDPos		:= tGroup():New(1, 1 ,45 ,nWidth-1		,STR0008  		,oPanel,CLR_RED,CLR_WHITE,.T.)	  //"Registro posicionado"
   
    oSCPFPos	:= TSay():New(10,5			    ,{|| STR0009 }			                        ,oGDPos,,,,,,.T.)//"CPF"
    oGCPFPos	:= TGet():New(20,5			    ,{|u| if(PCount()>0,cCpfPos:=u,cCpfPos)}	    ,oGDPos,nTmGrdCpo,10,'@!',,,,,,,.T.,,,,,,,.T.,,,"cCpfPos")
    oSTrbPos	:= TSay():New(10,nTmGrd-1	    ,{|| STR0010 }			                        ,oGDPos,,,,,,.T.) //"Nome" 
    oGTrbPos	:= TGet():New(20,nTmGrd-1	    ,{|u| if(PCount()>0,cNomePos:=u,cNomePos)}	    ,oGDPos,nTmGrdCpo,10,'@!',,,,,,,.T.,,,,,,,.T.,,,"cNomePos")
    oSEvtPos	:= TSay():New(10,(nTmGrd-1)*2   ,{|| STR0011 }	                                ,oGDPos,,,,,,.T.) //"Evento"
    oGEvtPos	:= TGet():New(20,(nTmGrd-1)*2   ,{|u| if(PCount()>0,cEventoPos:=u,cEventoPos)}	,oGDPos,nTmGrdCpo,10,'@!',,,,,,,.T.,,,,,,,.T.,,,"cEventoPos")		
    oSDtAltPos  := TSay():New(10,(nTmGrd-1)*3   ,{|| STR0012 }	                    ,oGDPos,,,,,,.T.) //"Data de Alteração"
    oGDtAltPos  := TGet():New(20,(nTmGrd-1)*3   ,{|u| if(PCount()>0,dDtAltPos:=u,dDtAltPos)}	,oGDPos,nTmGrdCpo,10,'@!',,,,,,,.T.,,,,,,,.T.,,,"dDtAltPos")		
	oGDPos:SetFont(oTFont)
	
	//-----------------------------------------------
	//AGRUPAMENTO DE OBJETOS DE REGISTRO COMPARADO
	//-----------------------------------------------
	oGComp		:= tGroup():New(50,1	,90,nWidth-1		,STR0013  		,oPanel,CLR_BLUE,CLR_WHITE,.T.)//"Registro Comparado"

    oSCPFCmp	:= TSay():New(60,5			    ,{|| STR0009 }			                        ,oGComp,,,,,,.T.)  //"CPF"
    oCPFCmp	    := TGet():New(70,5			    ,{|u| if(PCount()>0,cCpfCom:=u,cCpfCom)}	    ,oGComp,nTmGrdCpo -15,10,'@!',,,,,,,.T.,,,,,,,,,/*"TRBCOM"*/,"cCpfCom",,,,,.F.)
    oBtnLupa    := TBtnBmp2():New( 140,(nTmGrd *2)*0.81,25,25,'BMPVISUAL' ,,,,{|| fEvtComp ()  },oGComp,,,.T. ) 
    oSTrbCmp	:= TSay():New(60,nTmGrd-1	    ,{|| STR0010 }			                        ,oGComp,,,,,,.T.)//"Nome"
    oGTrbCmp	:= TGet():New(70,nTmGrd-1	    ,{|u| if(PCount()>0,cNomeCom:=u,cNomeCom)}	    ,oGComp,nTmGrdCpo,10,'@!',,,,,,,.T.,,,,,,,.T.,,,"cNomeCom")
    oSEvtCmp	:= TSay():New(60,(nTmGrd-1)*2   ,{|| STR0011 }	                                ,oGComp,,,,,,.T.)//"Evento"
    oGEvtCmp	:= TGet():New(70,(nTmGrd-1)*2   ,{|u| if(PCount()>0,cEventoCom:=u,cEventoCom)}	,oGComp,nTmGrdCpo,10,'@!',,,,,,,.T.,,,,,,,.T.,,,"cEventoCom")		
    oSDtAlt	    := TSay():New(60,(nTmGrd-1)*3   ,{|| STR0012 }	                    ,oGComp,,,,,,.T.)//"Data de Alteração"
    oGDtAlt	    := TGet():New(70,(nTmGrd-1)*3   ,{|u| if(PCount()>0,dDtAltCom:=u,dDtAltCom)}	,oGComp,nTmGrdCpo,10,'@!',,,,,,,.T.,,,,,,,.T.,,,"dDtAlt")		
	oGComp:SetFont(oTFont)
	
	//----------------------------------------------------------------------
	//MONTAGEM DE PAINEL PARA ARMAZENAR O AGRUPADOR DE ELEMENTOS DE FILTRO
	//----------------------------------------------------------------------
	oPanelSub 	:= TPanel():New(90,0,'',oPanel,,.T.,.T.,,,(nTmGrd-1)*3,40,.T.,.T.)

	//----------------------------------------------- 
	//AGRUPAMENTO DE OBJETOS DE FILTRO
	//-----------------------------------------------
	oTGFilt		    := TGROUP():New(00,1	,35,((nTmGrd-1)*3)-5	,STR0014,oPanelSub,,,.T.)//"Opções de Filtro"
	oTGFilt:SetFont(oTFont)    
	oSCMBCOL		:= TSay():New(10,05	    ,{|| STR0015 }			                    ,oTGFilt,,,,,,.T.)//"Coluna de Pesq."
	oSCMBFILT   :=TComboBox():New(20,05,{|u|if(PCount()>0,cIndCMB:=u,cIndCMB)}, aMotivos,nTmGrdCpo, 13,oTGFilt,,,,,,.T.,,,,,,,,,'cIndCMB')
	
	oSTermFilt	:= TSay():New(10,nTmGrd-1	 ,{|| STR0016 }			                    ,oTGFilt,,,,,,.T.)//"Termo de Busca:"
	oGFilt	    := TGet():New(20,nTmGrd-1   ,{|u| if(PCount()>0,cFiltCPF:=u,cFiltCPF)}	,oTGFilt,nTmGrdCpo,10,'@!',,,,,,,.T.,,,,,,,,,,"cFiltCPF")
	
	oBtnFil		:= tButton():New(20,(nTmGrd-1)*2,STR0017,oTGFilt,bExecFil,nTmGrdCpo,12,,,,.T.)//"&Posicionar"
	
	oBtnProc	:= tButton():New(95,(nTmGrd-1)*3,STR0018,oPanel,{|| FWMsgRun(,bExecute,"Comparativo.","Aguarde o término do processamento...")},nTmGrdCpo,15,,,,.T.)//"&Processar"
    
	oBtnClose	:= tButton():New(110,(nTmGrd-1)*3,STR0019,oPanel,bClose,nTmGrdCpo,15,,,,.T.)//"&Fechar"
 
 	If !(lElectron .OR. lRemote)
   		oBtnFil:SetCSS( FWPOSCSS (GetClassName(oBtnFil), CSS_BTN_ATIVO ))
   		oBtnProc:SetCSS( FWPOSCSS (GetClassName(oBtnProc),  CSS_BTN_FOCAL )) 
   		oBtnClose:SetCSS( FWPOSCSS (GetClassName(oBtnClose),CSS_BTN_NORMAL )) 
	EndIf
    
 	oBrowse := TWBrowse():New( 130 , 00, nWidth-1,nHeight-130,,aFields,{nTmGrdCpo,nTmGrdCpo,nTmGrdCpo},;                              
    	                        oPanel,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )    

	oBrowse:SetArray(aBrowse) 
	oBrowse:bLine       := {||{aBrowse[oBrowse:nAt,01],aBrowse[oBrowse:nAt,02],aBrowse[oBrowse:nAt,03]} }  
	oBrowse:bLDblClick  := bLDblClick
	oBrowse:DrawSelect()
 
	oModal:Activate()
Else

	MsgAlert(STR0045) //"Dicionário desatualizado para execução desta rotina, aplique a utlima expedição do SIGATAF "

EndIf

Return Nil

/*/{Protheus.doc} fPosReg
Função de busca\posicionamento de Browse
@type function
@version 
@author eduardo.vicente
@since 05/07/2020
@param cBusca, character, Termo de Busca
@param nInd, numeric, Indice\coluna de Pesquisa
@param aBrw, array, dados de browse
@return nLin,numeric, Linha de posicionamento
/*/
Static Function fPosReg(cBusca,nInd,aBrw)

Local nLin  := 1

Default nInd    := 1
Default cBusca  := ""
Default aBrw    := {}

//----------------------------------
//VALIDAÇÃO DE PARÂMETROS DE BUSCA
//----------------------------------
If Empty(cBusca) .Or. Empty(nInd)
    MsgInfo( STR0020 ) //"É necessário escolher a coluna e digitar o termo de busca."
Else

	//-----------------------------------
	//POSICIONAMENTO NO REGISTRO\LINHA
	//-----------------------------------
	nLin:= ASCAN(aBrw, { |x| ALLTRIM(UPPER(cBusca)) $ fConvType(x[nInd]) }) 
   
    If nLin < 1
        MsgInfo( STR0021 )//"Registro não encontrado."
    EndIf
EndIf

Return nLin

/*/{Protheus.doc} fViewDLG
Visualização da linha posicionada
@type function
@version 
@author edvf8
@since 06/07/2020
@param aLinPos, array, Linha posicionada
@param aFields, array, Colunas do grid
@return return_type, return_description
/*/
Static Function fViewDLG(aLinPos,aFields)

Local lRet      := .T.
Local cTextPos  := ""
Local oDlg := Nil
Local oMemoP := Nil
Local oMemoC := Nil
Local oFontTit := Nil
Local oFontMem := Nil
Local oSay  := Nil

Default aLinPos := {}

cTextPos := aLinPos[2]
cTextComp := aLinPos[3]

DEFINE FONT oFontTit NAME "Mono AS" SIZE 005,012 BOLD
DEFINE FONT oFontMem NAME "Mono AS" SIZE 005,012 

DEFINE MSDIALOG oDlg TITLE STR0043 + aLinPos[1] From 003,000 TO 370,417 PIXEL //"Diferença campo: "

@ 005,005 SAY oSay PROMPT aFields[2] SIZE 200,20 COLORS CLR_RED,CLR_WHITE FONT oFontTit OF oDlg PIXEL
@ 010,005 GET oMemoP VAR cTextPos MEMO SIZE 200,070 OF oDlg PIXEL
@ 090,005 SAY oSay PROMPT aFields[3] SIZE 200,20 COLORS CLR_BLUE,CLR_WHITE FONT oFontTit OF oDlg PIXEL
@ 096,005 GET oMemoC VAR cTextComp MEMO SIZE 200,070 OF oDlg PIXEL

oMemoP:bRClicked := {||AllwaysTrue()}
oMemoP:oFont := oFontMem
oMemoC:oFont := oFontMem

DEFINE SBUTTON  FROM 169,175 TYPE 1 ACTION oDlg:End() ENABLE OF oDlg PIXEL

ACTIVATE MSDIALOG oDlg CENTER

Return lRet

/*/{Protheus.doc} fEvtComp
Consulta Especifica 
@author Silas.Gomes
@since 16/07/2020
@version 1.0
/*/       
Function fEvtComp()

	Local oListBox		:= Nil
	Local oArea				:= Nil
	Local oList				:= Nil
	Local oButt1 			:= Nil
	Local oButt2 			:= Nil
	Local oButt3 			:= Nil
	Local aCols  			:= {}
	Local aColSizes 	:= { 60, 50, 20 }
	Local aCoord			:= {}
	Local aWindow			:= {}
	Local aHeader   	:= { STR0032, STR0033 , STR0034 , STR0035 , STR0036 , STR0037 }//"ID" # "CPF" # "Nome" # "Evento" # "Data Alteração" # "Status de Transmissão"
	Local cTitulo   	:= "" 
	Local cQuery 			:= ""
	Local cAliasquery := GetNextAlias()
	Local cFiltro			:= STR0038 + Space(GetSx3Cache('C9V_NOME'    ,   'X3_TAMANHO'))//"CPF, Nome ou Evento..."
	Local Nx 					:= 0
	Local lLGPDperm 	:= IIF(FindFunction("PROTDATA"),ProtData(),.T.)
	Local lSemReg     := .F.

	Private cCpfPesq	:= Alltrim(ReadVar())
	Private cNomePesq	:= ""
	Private cEventPesq:= ""
	Private dDtAltPesq:= ""
	
	cTitulo   := STR0039 // "Consulta Específica de Trabalhador"

	If !Empty(cEvento)

		cQuery	:= fQryTrb(cEvento,cCpf,nRecnoPos)

	EndIf
	
	cQuery := ChangeQuery(cQuery)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasquery,.T.,.T.)

	While (cAliasquery)->(!Eof())
		aAdd(aCols,{(cAliasquery)->(Id), (cAliasquery)->(CPF), (cAliasquery)->(Nome), (cAliasquery)->(EVENTO), SToD((cAliasquery)->(Alteracao)), fRtnSts((cAliasquery)->(STATUS)), (cAliasquery)->(FILIAL), (cAliasquery)->(RECNO) })
		(cAliasquery)->(dbSkip())
	End
	(cAliasquery)->(dbCloseArea())

	If Len(aCols) < 1
		aAdd(aCols,{" "," "," "," "," "," "})
		lSemReg := .T.
	EndIf

	aCoord 	:= {000,000,400,800}
	aWindow := {020,073}

	oArea := FWLayer():New()
	oFather := tDialog():New(aCoord[1],aCoord[2],aCoord[3],aCoord[4],cTitulo,,,,,CLR_BLACK,CLR_WHITE,,,.T.)
	oArea:Init(oFather,.F., .F. )

	oArea:AddLine("L01",100,.T.)

	oArea:AddCollumn("L01C01",99,.F.,"L01")
	oArea:AddWindow("L01C01","TEXT","Ações",aWindow[01],.F.,.F.,/*bAction*/,"L01",/*bGotFocus*/)
	oText	:= oArea:GetWinPanel("L01C01","TEXT","L01")

	TSay():New(005,01,{||STR0040},oText,,,,,,.T.,,,200,20)//'Pesquisa:'
	TGet():New(003,028,{|u| if( PCount() > 0, cFiltro := u, cFiltro ) },oText,130,009,"@!",,,,,,,.T.,,,,.T.,,,.F.,,"","cFiltro",,,,.T.,.T.,,,,,,,,)
	oButt3 := tButton():New(003,160,STR0041,oText,{||fPesqTrb(oListBox,cFiltro)}, 45,11,,,.F.,.T.,.F.,,.F.,,,.F. )//"Pesquisar"

	oArea:AddWindow("L01C01","LIST",STR0042,aWindow[02],.F.,.F.,/*bAction*/,"L01",/*bGotFocus*/)//"Trabalhador"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       
	oList	:= oArea:GetWinPanel("L01C01","LIST","L01")

	oButt1 := tButton():New(003,290,"&Confirmar",oText,{||IIF(!lSemReg,fPosicTrb(oListBox:nAt, aCols),oFather:End()),oFather:End()},45,11,,,.F.,.T.,.F.,,.F.,,,.F. )
	oButt2 := tButton():New(003,340,"&Sair",oText,{|| oFather:End()},45,11,,,.F.,.T.,.F.,,.F.,,,.F. )

	oFather:lEscClose := .T.

	nTamCol := Len(aCols[01])
	bLine 	:= "{|| {"
	For Nx := 1 To nTamCol
		bLine += "aCols[oListBox:nAt]["+StrZero(Nx,3)+"]"
		If Nx < nTamCol
			bLine += ","
		EndIf
	Next
	bLine += "} }"

	oListBox := TCBrowse():New(0,0,386,130,,aHeader,,oList,'Fonte')
	oListBox:SetArray( aCols )
	oListBox:bLine := &bLine

	If !lLGPDperm
		oListBox:aObfuscatedCols :={.F.,.T.,.T.}
	EndIf

	If !Empty( aColSizes )
		oListBox:aColSizes := aColSizes
	EndIf
	oListBox:SetFocus()	

	oFather:Activate(,,,.T.,/*valid*/,,/*On Init*/)


Return(.T.)

/*/{Protheus.doc} fQryTrb
Retorna a Query dos Eventos S-2200, S-2205, S-2206,
S-2300 e S-2306.
@type function
@version 
@author Silas.Gomes
@since 21/07/2020
@param cEvento, character, Evento posicionado
@param cCpf, character, cpf do trabalhador
@param nRecnoPos, numeric, recno do posicionado
@return cQuery, character, query de retorno
/*/
Static Function fQryTrb(cEvento,cCpf,nRecnoPos)

Local cQuery		:= ""
Local cMatric		:= ""
Local cEvtT1u       := ""
Local cEvtT1v       := ""
Local cEvtT0F       := ""
Local lCLT          := .T.

Default cEvento		:= ""
Default cCpf		:= ""
Default nRecnoPos	:= 0

If cEvento $ "S2205/S2206"
	DBSelectArea("C9V")
	C9V->(DBSetOrder(2))
	C9V->(DBSeek(cFilCs + cId + "1"))
	cMatric	:= C9V->C9V_MATRIC
EndIf

If (cEvento = "S2205" .And. !Empty(cMatric)) .Or. cEvento $ 'S2200/S2206'
	cEvtT1u := 'S2205'
	cEvtT1v	:= 'S2206'
			lCLT    := .T.
ElseIf Empty(cMatric) .or. cEvento $ 'S2300/S2205/S2306'
	cEvtT1u := 'S2205'
	cEvtT0F	:= 'S2306'
	lCLT    := .F.
EndIf		

cQuery := " SELECT C9V_FILIAL AS Filial, C9V_ID AS Id, C9V_CPF AS CPF, C9V_Nome AS Nome, C9V_NOMEVE AS EVENTO, C9V_DTALT AS Alteracao, C9V_STATUS AS STATUS, C9V.R_E_C_N_O_ AS RECNO "
cQuery += " FROM "+RetSQLName("C9V")+" C9V "
cQuery += " WHERE C9V.D_E_L_E_T_ = ' ' AND C9V_FILIAL = '" + xFilial("C9V",cFilCs) + "' AND C9V.C9V_CPF = '"+cCpf+"' "

If cEvento $ 'S2200#S2300'
	
	cQuery += " AND C9V.R_E_C_N_O_ != "+ALLTRIM(Str(nRecnoPos))+" "
	cQuery += " AND C9V_NOMEVE = '" + cEvento  +"' "

ElseIf cEvento == "S2205" .Or. cEvento $ 'S2206#S2306'
	If Empty(cMatric)
		cQuery += " AND C9V_NOMEVE = 'S2300' "
	Else
		cQuery += " AND C9V_NOMEVE = 'S2200' "
	EndIf
EndIf

If !(cEvento $ "S2206/S2306")

	cQuery += " UNION ALL "
	cQuery += " SELECT T1U_FILIAL AS Filial, T1U_ID AS Id, T1U_CPF AS CPF, T1U_NOME AS Nome, '"+cEvtT1u+"' AS EVENTO, T1U_DTALT AS ALTERACAO, T1U_STATUS AS STATUS, T1U.R_E_C_N_O_ AS RECNO "
	cQuery += " FROM "+RetSQLName("T1U")+" T1U "
	cQuery += " WHERE T1U.D_E_L_E_T_ = ' ' AND T1U_FILIAL = '" + xFilial("T1U",cFilCs)  + "' AND T1U.T1U_CPF = '"+cCpf+"' AND T1U.R_E_C_N_O_ IN ( "
	cQuery += " SELECT DISTINCT T1U.R_E_C_N_O_ "
	cQuery += " FROM "+RetSQLName("T1U")+" T1U "
	cQuery += " INNER JOIN "+RetSQLName("C9V")+" C9V ON (C9V.C9V_FILIAL = T1U.T1U_FILIAL AND C9V.C9V_ID = T1U.T1U_ID
	If cEvento $ 'S2200#S2300'
		cQuery += " AND C9V_NOMEVE = '" + cEvento  +"'"
	EndIf
	cQuery += " ) "
	cQuery += " WHERE C9V.D_E_L_E_T_ = ' ' "

	If cEvento == 'S2205'
		cQuery += " AND T1U.R_E_C_N_O_ != "+ALLTRIM(Str(nRecnoPos))+" "
	EndIf
	cQuery += " )"
		
EndIf

If lClt .And. cEvento != "S2205"

		cQuery  += " UNION ALL "
		cQuery  += " SELECT T1V_FILIAL AS Filial, T1V_ID AS Id, T1V_CPF AS CPF, T1V_NOME AS Nome, '"+cEvtT1v+"' AS EVENTO, T1V_DTALT AS ALTERACAO, T1V_STATUS AS STATUS, T1V.R_E_C_N_O_ AS RECNO "
		cQuery  += " FROM "+RetSQLName("T1V")+" T1V "
		cQuery  += " WHERE T1V.D_E_L_E_T_ = ' ' AND T1V_FILIAL = '" + xFilial("T1V",cFilCs)  + "' AND T1V.T1V_CPF = '"+cCpf+"' AND T1V.R_E_C_N_O_ IN ( "
		cQuery  += " SELECT DISTINCT T1V.R_E_C_N_O_ "
		cQuery  += " FROM "+RetSQLName("T1V")+" T1V "
		cQuery  += " INNER JOIN "+RetSQLName("C9V")+" C9V ON (C9V.C9V_FILIAL = T1V.T1V_FILIAL AND C9V.C9V_ID = T1V.T1V_ID) "
		cQuery  += " WHERE C9V.D_E_L_E_T_ = ' ' "

		If cEvento $ 'S2206'
				cQuery  += " AND T1V.R_E_C_N_O_ != "+ALLTRIM(Str(nRecnoPos))+" "
		EndIf
		cQuery  += " ) "
EndIf

If !lClt .AND. cEvento != "S2205"
		cQuery  += " UNION ALL "
		cQuery	+= "SELECT T0F_FILIAL AS Filial, T0F_ID AS Id, T0F_CPF AS CPF, T0F_NOME AS Nome, '"+cEvtT0F+"' AS EVENTO, T0F_DTALT AS ALTERACAO, T0F_STATUS AS STATUS, T0F.R_E_C_N_O_ AS RECNO "
		cQuery 	+= "FROM " + RetSqlName('T0F') + " T0F "
		cQuery 	+= "WHERE T0F.T0F_FILIAL = '" + xFilial("T0F",cFilCs)  + "' AND T0F.D_E_L_E_T_ = ' ' AND T0F.T0F_CPF = '"+cCpf+" '
		If cEvento $ 'S2306'
				cQuery  += " AND T0F.R_E_C_N_O_ != "+ALLTRIM(Str(nRecnoPos))+" "
		EndIf

EndIf
	

Return cQuery

/*/{Protheus.doc} fPesqTrb
Função responsavel por realizar a pesquisa por Nome e/ou CPF do trabalhador.
@type function
@version 
@author Silas.Gomes
@since 16/07/2020
@param oListBox, object, objeto listbox
@param cFiltro, character, informação de consulta
@return return_type, return_description
/*/
Static Function fPesqTrb(oListBox,cFiltro)

	Local nPos  	 := 0
	Local lRet  	 := .F.
	Local lPosPesq	 := .F.
	Local lCPF 		 := .F.
	Default oListBox := Nil
	Default cFiltro	 := ""

	cFiltro := AllTrim(cFiltro)

	// Faz um scan no objeto para encontrar a posição e posicionar no browser
	If Valtype(cFiltro) = "C" .And. !Empty(cFiltro)
		nPos := aScan( oListBox:aArray, {|x| cFiltro $ AllTrim(x[2])  } )
		lCPF := .T.
		If nPos == 0
			nPos := aScan( oListBox:aArray, {|x| cFiltro $ AllTrim(x[3]) } )			
		EndIf
		If nPos == 0
			nPos := aScan( oListBox:aArray, {|x| cFiltro $ AllTrim(x[4]) } )			
		EndIf

		If nPos > 0
			oListBox:GoPosition(nPos)
			oListBox:Refresh()
			lRet  := .T.
		EndIf

	EndIf

	If nPos == 0 .And. !lPosPesq
		MsgAlert(STR0022 + cFiltro + STR0023)      // Não foi possível encontrar o trabalhador na pesquisa
	EndIf

Return


/*/{Protheus.doc} fPosicTrb
Função responsavel por realizar o posicionamento no registro selecionado na consulta do trabalhador.
@type function
@author Silas.Gomes
@since 21/07/2020
@param nPos, numeric, posição da linha 
@param aCols, array, coluna do grid
@return return_type, return_description
/*/
Static Function fPosicTrb(nPos,aCols)

	Default nPos		:= ""
	Default aCols  		:= ""

	cCpfCom 	:= aCols [nPos] [2]
	cNomeCom  	:= aCols [nPos] [3]
	cEventoCom	:= aCols [nPos] [4]
	dDtAltCom  	:= aCols [nPos] [5]

	cFilialCom  := aCols [nPos] [7]
	nRecnoCom   := aCols [nPos] [8]
	
Return .T.


/*/{Protheus.doc} fRtnSts
Retorna a descrição do status de trasmissão.
@type function
@version 
@author Silas.Gomes
@since 21/07/2020
@param cSts, character, código do status
@return cStatus, character, Descrição de status
/*/
Static Function fRtnSts(cSts)

Local cStatus   := ""
Default cSts    := ""

    DO CASE

        CASE Empty(cSts)
            cStatus := STR0024          //"AGUARDANDO PROCESSAMENTO" 

        CASE cSts == "0"
            cStatus := STR0025          //"VÁLIDO" 

        CASE cSts == "1"
            cStatus := STR0026          //"INVÁLIDO" 

        CASE cSts == "2"
            cStatus := STR0027          //"TRANSMITIDO (AGUARDANDO RETORNO)"
            
        CASE cSts == "3"
            cStatus := STR0028          //"TRANSMITIDO INVÁLIDO"

        CASE cSts == "4"
            cStatus := STR0029          //"TRANSMITIDO VÁLIDO"
        
        CASE cSts == "6"
            cStatus := STR0030          //"PENDENTE DE EXCLUSÃO"

            OTHERWISE
            cStatus := STR0031          //"EXCLUSÃO EFETIVADA"

    ENDCASE

Return cStatus

/*/{Protheus.doc} fGetDtAlt
Função encapsulada para retornar a data de alteração
@type function
@version 
@author eduardo.vicente
@since 23/07/2020
@param nRecPos, numeric, Recno do evento posicionado
@param cEvtPos, character, Evento posicionado
@return dDtAltAtu, string, Data da alteração
/*/
Static Function fGetDtAlt(nRecPos,cEvtPos)

Local dDtAltAtu	:= STOD(" / / ")
Local aArea		:= GetArea()

Default nRecPos	:= 0
Default cEvtPos := ""

If !Empty(cEvtPos)

	Do Case
		CASE cEvtPos $ "S2200/S2300"

			dbSelectArea("C9V")
			C9V->(dbSetOrder(1))
			C9V->(DBGOTO(nRecPos))
			dDtAltAtu := C9V->C9V_DTALT

		CASE cEvtPos $ "S2205"

			dbSelectArea("T1U")
			T1U->(dbSetOrder(1))
			T1U->(DBGOTO(nRecPos))
			dDtAltAtu := T1U->T1U_DTALT

		CASE cEvtPos  $ "S2206"

			dbSelectArea("T1V")
			T1V->(dbSetOrder(1))
			T1V->(DBGOTO(nRecPos))
			dDtAltAtu := T1V->T1V_DTALT

		CASE cEvtPos  $ "S2306"

			dbSelectArea("T0F")
			T0F->(dbSetOrder(1))
			T0F->(DBGOTO(nRecPos))
			dDtAltAtu := T0F->T0F_DTALT

	EndCase

EndIf

RestArea(aArea)

Return dDtAltAtu

/*/{Protheus.doc} TAFProcCmp
Realiza o processamento de comparação dos registros
@type function
@version 1.0 
@author  Bruno de Oliveira
@since   27/07/2020
@param   cCpfPos   , caracter, CPF do registro posicionado
@param   cEventoPos, caracter, Evento do registro posicionado
@param   dDtAltPos , caracter, Data de alteração do registro posicionado
@param   oBrowse   , objeto  , Browse principal 
@return  lRet      , logico  , retorno da função
/*/
Static Function TAFProcCmp(cCpfPos,cEventoPos,dDtAltPos,oBrowse)

Local lRet        := .T.
Local cEvtTran    := "S2200|S2205|S2206|S2300|S2306"
Local cChave	  := ""
Local aIndice	  := {}
Local nContRegs	  := 0
Local aTabTemp	 	:= {} //NOME DA TABELA, ALIAS TEMPORARIO E CHAVE DE AMARRAÇÃO POSICIONADO  E CHAVE DE AMARRAÇÃO PARA
Local  aCampos   	:= {}
Private cMemos   	:= ""
Private cRecPrinc 	:= ""

If !Empty(cCpfPos) .AND. !Empty(cEventoPos) .AND. !Empty(cCpfCom) .AND. !Empty(cEventoCom)

	If len(aBrowse) > 0
		aSize(aBrowse,1)
		aBrowse[1] := {"","",""}
	EndIf

	TAFBscDPar(cEventoPos,cEventoCom,cEvtTran,@aTabTemp,cCpfPos,cCpfCom,dDtAltPos,dDtAltCom,@cChave,@aIndice,@aCampos)
	
	If  Len(aTabTemp)  > 0

		If cEventoPos <> cEventoCom
			CargBrowse(aCampos, aTabTemp,1,@aBrowse,cEventoCom,cEventoPos)
		Else
			CargBrowse(aCampos, aTabTemp,0,@aBrowse,cEventoCom,cEventoPos)
		EndIf
	Else
		MsgAlert(STR0046) //" O Processamento não retornou nenhum resultado ")
	EndIf

Else
	MsgAlert(STR0044) //"Não será realizado processamento. Necessário informar o registro a ser comparado!")
EndIf

If Len(abrowse) > 1
	aDel(abrowse,1)
	aSize(abrowse,len(abrowse)-1)
EndIf
For nContRegs:= 1 to Len(aTabTemp)
	If ValType(aTabTemp[nContRegs][2]) == "O"
		aTabTemp[nContRegs][2]:Delete()
	EndIf

Next

oBrowse:Refresh()

Return lRet

/*/{Protheus.doc} TAFBscDPar
Busca tabela De\Para
@type function
@version 1.0
@author  Bruno de Oliveira
@since   27/07/2020
@param   cEventoPos, caracter, Evento Posicionado
@param   cEvtTran  , caracter, Eventos relacionados ao trabalhador 
@return  cQuery    , caracter, consulta da tabela De\Para
/*/
Static Function TAFBscDPar(cEventoPos,cEventoCom,cEvtTran,aTabTemp,cCpfPos,cCpfCom,dDtAltPos,dDtAltCom,cChave,aIndice,aCampos)

Local cCodDePar  	:= ""
Local cSelectP   	:= ""
Local cTabLeftD  	:= ""
Local cTabLeftP  	:= ""
Local cItemTab   	:= ""
Local cCamposQry 	:= ""
Local nX         	:= 0
Local nY         	:= 0
Local cAliasDE	 	:= ""
Local cAliasPA	 	:= ""
Local cRecnTabDe 	:= ""
Local cRecnTabPa 	:= ""
Local aEstrut1   	:= {}
Local aEstrut2   	:= {}
Local aStructCmp 	:= {}
Local cChavNeg	 	:= ""
Local cChavPai	 	:= ""
Local aIndDe	 	:= {}
Local aIndPa	 	:= {}
Local cIndiceTb	 	:= ""
Local lCargPrinc 	:= .F.
Local lWhrCargPrinc	:= .F.
Local lEvntIgual	:= cEventoPos == cEventoCom
//-----------------------------------------------------------
//BLOCOS DE CÓDIGO QUE REPRESENTAM AS AÇÕES NO PROCESSAMENTO
//-----------------------------------------------------------
Local cWhereFilD 	:= ""
Local cWhereFilP 	:= ""
Local cWhereCPFD 	:= ""
Local cWhereDtAD 	:= ""
Local cWhereCPFP 	:= ""
Local cWhereDtAP 	:= ""
Local cWhereRecD 	:= ""
Local cWhereRecP 	:= ""
Local cWhereDelD 	:= ""

DbSelectArea("V5P")
DbSelectArea("V5Q")

cCodDePar := Posicione("V5O",3,XFilial("V5O")+SubStr(cEventoPos,2)+SubStr(cEventoCom,2),"V5O_ID")

If !Empty(cCodDePar)

	V5P->(DbSetOrder(1))
	V5P->(DbSeek(xFilial("V5P")+cCodDePar))

	While V5P->(!EOF()) .AND. V5P->(V5P_FILIAL+V5P_ID) == xFilial("V5P")+cCodDePar

		cRecnTabDe:= ""
		cRecnTabPa:= ""
		cSelectP  := V5P->V5P_TABDE
		cTabLeftD := V5P->V5P_TABDE
		cTabLeftP := V5P->V5P_TABPAR
		cAliasDe  := V5P->V5P_TABDE+"TEMPDE"
		cAliasPA  := V5P->V5P_TABPAR+"TEMPPA"

		If Empty(cRecnTabDe)
			cRecnTabDe := ","+cSelectP + 'TAB.R_E_C_N_O_ ' + cSelectP + 'REC,'
			If lEvntIgual
				cRecnTabPa := ","+cSelectP + 'TAB.R_E_C_N_O_ ' + cSelectP + 'REC,'
			EndIf
		Else
			cRecnTabPa := ","+cSelectP + 'TAB.R_E_C_N_O_ ' + cSelectP + 'REC,'
		EndIf
		cRecPrinc := cSelectP + 'REC'

		cWhereFilD := cTabLeftD + "_FILIAL = "
		cWhereFilP := cTabLeftP + "_FILIAL = "
		
		If (cEventoPos $ cEvtTran .OR. cEventoCom $ cEvtTran) .And. !lWhrCargPrinc
			cWhereCPFD := " AND " + cTabLeftD + "_CPF = "
			cWhereDtAD := " AND " + cTabLeftD + "_DTALT = "
			
			cWhereCPFP := " AND " + cTabLeftP + "_CPF = "
			cWhereDtAP := " AND " + cTabLeftP + "_DTALT = "

			lWhrCargPrinc:= .T.
			cWhereRecD := " AND " + cSelectP + "TAB.R_E_C_N_O_ = "
			cWhereRecP += " AND   "+cTabLeftP + "TAB.R_E_C_N_O_ = "
		EndIf

		cWhereDelD := " AND " + cSelectP + "TAB.D_E_L_E_T_ = ' ' " 
		cWhereDelP := " AND " + cTabLeftP + "TAB.D_E_L_E_T_ = ' ' "

		aEstrut1 := {}
		aEstrut2 := {}

		If !Empty(cTabLeftD)
			aEstrut1 := (cTabLeftD)->(DbStruct())
		EndIf

		aEstrut2 := (cTabLeftP)->(DbStruct())

		aAdd(aStructCmp,aEstrut1)
		aAdd(aStructCmp,aEstrut2)

		cItemTab := V5P->V5P_ITEM

		cChavNeg := Alltrim(V5P->V5P_CHVNEG)

		V5Q->(DbSetOrder(1))
		cSlctCmpDe	:= ""
		cSlctCmpPA	:= ""
		If V5Q->(DbSeek(xFilial("V5Q")+cCodDePar+cItemTab))
			aIndDe:= {}
			aIndPA:= {}

			While V5Q->(!EOF()) .AND. V5Q->(V5Q_FILIAL+V5Q_ID+V5Q_ITEMTB) == xFilial("V5Q")+cCodDePar+cItemTab

				cCamposQry	:= Alltrim(SubStr(V5Q->V5Q_CAMPOS,1,at('<',V5Q->V5Q_CAMPOS)-1))
				cIndiceTb	:= Alltrim(SubStr(V5Q->V5Q_CAMPOS,at('<',V5Q->V5Q_CAMPOS)+1,at('/>',V5Q->V5Q_CAMPOS)-at('<',V5Q->V5Q_CAMPOS)-1 ) )
				
				If !Empty(cCamposQry)
					cCamposQry := FieldValid(cCamposQry, cEventoPos, cEventoCom)				

					If (nPosCpo:= aScan(aCampos,{|x| left(cCamposQry,at("_",cCamposQry)-1 ) == x[1] .And.  Empty(x[2]) .And. Empty(x[3]) })) > 0
						aCampos[nPosCpo][2]:= cTabLeftD+"x"+cTabLeftP
						aCampos[nPosCpo][3]:= StrTokArr(cCamposQry,",")
					Else 
						aAdd(aCampos,{left(cCamposQry,at("_",cCamposQry)-1 ),cTabLeftD+"x"+cTabLeftP,StrTokArr(cCamposQry,",")})
					EndIf
				EndIf
				
				If !Empty(cCamposQry) 
					If (Right(cTabLeftD,2)+"_") $ cCamposQry
						cSlctCmpDe += cCamposQry 
						If !Empty(cIndiceTb)
							aIndDe	:= StrTokArr(cIndiceTb,"+")
						EndIf 
					Else
						If !Empty(cIndiceTb)
							aIndPA	:= StrTokArr(cIndiceTb,"+")
						EndIf 
						cSlctCmpPA += cCamposQry 
					EndIf
						
					If lEvntIgual
						If !Empty(cIndiceTb)
							aIndPA	:= StrTokArr(cIndiceTb,"+")
						EndIf 
						cSlctCmpPA += cCamposQry 
						Exit
					EndIf
					cCamposQry := ""
				EndIf

				V5Q->(DbSkip())
			End
		Else 

			aAdd(aCampos,{IIF(Empty(V5P->V5P_TABDE),V5P->V5P_TABPAR,V5P->V5P_TABDE),"",{}})
		
		EndIf
		If !Empty(cSlctCmpDe) .And. !Empty(cSlctCmpPA)
			For nX := 1 to Len(aStructCmp)

				For nY := 1 to Len(aStructCmp[nX])

					If aStructCmp[nX][nY][2] == "M"
						cMemos += aStructCmp[nX][nY][1] + "|"
					EndIf

				Next nY

			Next nX
	
			cQueryDe	:= "SELECT " + cSlctCmpDe
			cQueryDe	+= SubStr(cRecnTabDe,1,Len(cRecnTabDe)-1)
			cQueryDe	+= " FROM " + RetSqlName(cSelectP) + ' ' + cSelectP + 'TAB'

			cQueryPA	:= "SELECT " + cSlctCmpPA
			cQueryPA	+= SubStr(cRecnTabPA,1,Len(cRecnTabPA)-1)
			cQueryPA	+= " FROM " + RetSqlName(cTabLeftP) + ' ' + cTabLeftP + 'TAB'

			cQueryDe += " WHERE "
			cQueryPA += " WHERE "
			If !Empty(cQueryDe) .And. !Empty(cQueryPA)
				cQueryDe += cWhereFilD + "'" + cFilialpos + "'"  
				cQueryPA += cWhereFilP + "'" + cFilialCom + "'" 

				If (!lCargPrinc) .And. (cEventoPos $ cEvtTran .OR. cEventoCom $ cEvtTran) //Apenas para eventos do trabalhador
				
					cQueryDe += 	cWhereCPFD + "'" + cCpfPos + "'" 
					cQueryPA += 	cWhereCPFP + "'" + cCpfCom + "'" 

					If cEventoPos != cEventoCom
						cQueryDe += 	cWhereDtAD + "'" + DTOS(dDtAltPos) + "'" 
						cQueryPA += 	cWhereDtAP + "'" + DTOS(dDtAltCom) + "'"
					Else
						cQueryDe += 	cWhereDtAD + "'" + DTOS(dDtAltPos) + "'" 
						cQueryPA += 	cWhereDtAP + "'" + DTOS(dDtAltCom) + "'"
					EndIf  
					lCargPrinc:= .T.
				EndIf

				If cSelectP $ cWhereRecD .OR. cSelectP $ cWhereRecP
						cQueryDe += cWhereRecD + "'" + Alltrim(STR(nRecnoPos)) + "'" 
				EndIf
				If cTabLeftP $ cWhereRecP .OR. cTabLeftP $ cWhereRecD 
					cQueryPA += cWhereRecP + "'" + Alltrim(STR(nRecnoCom)) + "'" 
				EndIf
				cQueryDe += cWhereDelD 
				cQueryPA += cWhereDelP 
				cQueryDe += fMontaVinc(@aTabTemp,Iif(!Empty(cChavPai),cChavPai,cChavNeg),cTabLeftD,cTabLeftP,"DE",lEvntIgual)

				cQueryDe := ChangeQuery(cQueryDe)
										
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQueryDe),cAliasDE,.T.,.T.)
				fCriaTemporary(@aTabTemp,cAliasDE,cSelectP,cTabLeftP+"DE",aIndDe)				

				cQueryPA += fMontaVinc(@aTabTemp,cChavNeg,cTabLeftP,cTabLeftD,IIF(lEvntIgual,"PA","DE"),lEvntIgual)
				cQueryPA := ChangeQuery(cQueryPA)
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQueryPA),cAliasPA,.T.,.T.)

				fCriaTemporary(@aTabTemp,cAliasPA,cTabLeftP,cSelectP+"PA",aIndPa)
				(cAliasDE)->(dbCloseArea())
				(cAliasPA)->(dbCloseArea())
				cChavPai:= ""
				cChavNeg:= ""

			EndIf

		EndIf

		If !Empty(cChavNeg)
			cChavPai:= cChavNeg
		EndIf

		V5P->(DbSkip())

	End

EndIf

Return

/*/{Protheus.doc} TafConCmps
Realiza validação do tipo de Campo e faz a conversão para mascara de campo.
@type function
@version 1.0
@author  Bruno de Oliveira
@since   05/08/2020
@param   cCampoPos , caracter, Campo do registro posicionado
@param   cCampoCprd, caracter, Campo do registro comparado
@param   cValPosic , caracter, Valor do registro posicionado
@param   cValCompar, caracter, Valor do registro posicionado
@return  Array, {retorno da descrição, conteudo registo posicionado, conteudo registro comparado}
/*/
Static Function TafConCmps(cCampoPos,cCampoCprd,cValPosic,cValCompar)

Local cPosiciond := ""
Local cComparado := ""
Local cDscCombP  := ""
Local cDscCombC  := ""
Local cTituloCmp := ""
Local cTipo      := ""

cTipo := AllTrim( Posicione( "SX3", 2, cCampoPos, "X3_TIPO" ) )

If cTipo == "C"
	If TamSX3(cCampoPos)[1] == 1
		cDscCombP := cValPosic + "-" + X3COMBO(cCampoPos,cValPosic)
		cDscCombC := cValCompar + "-" +X3COMBO(cCampoCprd,cValCompar)
	EndIf
	cPosiciond := IIF(Empty(cDscCombP),cValPosic,cDscCombP)
	cComparado := IIF(Empty(cDscCombC),cValCompar,cDscCombC)
ElseIf cTipo == "D"
	cPosiciond := STOD(cValPosic)
	cComparado := STOD(cValCompar)
ElseIf cTipo == "N"
	cPosiciond := cValPosic
	cComparado := cValCompar
EndIf

cTituloCmp := TafTitCamp(cCampoPos)

Return {cTituloCmp,cPosiciond,cComparado}

/*/{Protheus.doc} TafTratMem
Tratamento da comparação dos campos memos.
@type function
@version 1.0
@author  Bruno de Oliveira
@since   05/08/2020
@param   cCMemoPos , caracter, Campo Memo posicionado
@param   cCMemoCmp , caracter, Campo Memo comparado
@param   cAliasComp, caracter, Alias da query
@return  aRet      , array   , {retorno da descrição, conteudo registo posicionado, conteudo registro comparado}
/*/
Static Function TafTratMem(cCMemoPos,cCMemoCmp,cAliasComp)

Local cDescricao := ""
Local cTabelaPos := ""
Local cRecTabPos := ""
Local cTabelaCmp := ""
Local cRecTabCmp := ""
Local cPosiciond := ""
Local cComparado := ""
Local aRet       := {}

cTabelaPos := SubStr(cCMemoPos,1,3)
cRecTabPos := (cAliasComp)->&(cTabelaPos+'REC')

If !Empty(cCMemoCmp)
	cTabelaCmp := SubStr(cCMemoCmp,1,3)
	cRecTabCmp := (cAliasComp)->&(cTabelaCmp+'REC')
EndIf

If !Empty(cRecTabPos)
	DbSelectArea(cTabelaPos)
	(cTabelaPos)->(DbGoto(cRecTabPos))
	cPosiciond := (cTabelaPos)->&(cCMemoPos)

	cDescricao := TafTitCamp(cCMemoPos)
EndIf

If !Empty(cRecTabCmp)
	DbSelectArea(cTabelaCmp)
	(cTabelaCmp)->(DbGoto(cRecTabCmp))
	cComparado := (cTabelaCmp)->&(cCMemoCmp)
EndIf

If cPosiciond <> cComparado
	aRet := {cDescricao,cPosiciond,cComparado}
EndIf

Return aRet

/*/{Protheus.doc} TafTitCamp
Tratamento da comparação dos campos memos.
@type function
@version 1.0 
@author  Bruno de Oliveira
@since   06/08/2020
@param   cCampoPos, caracter, Campo posicionado
@return  cRet     , caracter, titulo do campo
/*/
Static Function TafTitCamp(cCampoPos)

Local cRet := ""

cRet := AllTrim( Posicione( "SX3", 2, cCampoPos, "X3_TITULO" ) )

Return cRet


/*/{Protheus.doc} TafTitCamp
Conversão do Tipo de dado
@type function
@version 1.0 
@author  Eduardo Vicente
@since   17/02/2021
@param   xValue, indefinido, Valor posicionado
/*/
Static Function fConvType(xValue)

Local 	cValue	:= ""

	If ValType(xValue) == "N"
		
		cValue := STR(xValue)

	ElseIf ValType(xValue) == "D"

		cValue := DTOC(xValue)
	
	Else

		cValue := xValue
	EndIf
Return UPPER(cValue)

/*/{Protheus.doc} CargBrowse
Rotina responsável pela carga de dados no abrowse da interface comparadora
@type function
@version 1.0 
@author  Eduardo Vicente
@since   17/02/2021
@param   aCampos, array, Array de campos para comparação
@param   cAliasDe, alias temporaria, Tabela Dê(posicionado)
@param   cAliasPara, alias temporaria, Tabela Dê(comparado)
@param   nStep, numerico, Salto no laço para checagem de posições quando os eventos são diferentes
@param   aBrowse, array, Array do abrowse para carregar na interface
@param   lPosNotFnd, lógico, Verificação se o registro posicionado foi localizado no comparado
@param   lCompNotFnd, lógico, Verificação se o registro comparado foi localizado no posicionado
@param   dDtAltPos, data, Data do registro posicionado
@param   dDtAltCom, data, Data do registro comparado
/*/
Static Function CargBrowse(aCampos, aTabTemp,nStep,aBrowse,cEventoCom,cEventoPos)

Local nContDe		:= 0
Local nContPa		:= 0
Local lMemo			:= .F.
Local nPosDe		:= 0
Local nPosPA		:= 0
Local cRestri		:= "FILIAL/VERSAO/ID/IDDEP/NOMEVE"
Local lPosNotFnd	:= .F.	
Local lCompNotFnd 	:= .F.

Default nStep		:= 0

For nContDe := 1 to Len(aCampos)

	nPosDe		:= aScan(aTabTemp,{|x| aCampos[nContDe][1]+aCampos[nContDe+nStep][1]+"DE" == x[6] })
	nPosPA		:= aScan(aTabTemp,{|x| aCampos[nContDe+nStep][1]+aCampos[nContDe][1]+"PA" == x[6] })
	
	cAliasDe		:= aTabTemp[nPosDe][2]:GetAlias()
	cAliasPara	:= aTabTemp[nPosPA][2]:GetAlias()

 	(cAliasDe)->(dbGotop())
	
	fIgualArrays(@aCampos[nContDe][3],@aCampos[nContDe+nStep][3],cRestri)
	fIgualArrays(@aCampos[nContDe+nStep][3],@aCampos[nContDe][3],cRestri)
	
	If !Empty(aTabTemp[nPosDe][7])
		(cAliasDe)->(dbSetOrder(1))
	EndIf
	
	If !Empty(aTabTemp[nPosPa][7])
		(cAliasPara)->(dbSetOrder(1))
	EndIf

	While !(cAliasDe)->(eof())
		lPosNotFnd	:= .F.
		lCompNotFnd := .F.
		If (cAliasPara)->( dbSeek( (cAliasDe)->&(aTabTemp[nPosDe][3]) ) )

			While !(cAliasPara)->(eof()) .And. (cAliasPara)->&(aTabTemp[nPosPa][3]) == (cAliasDe)->&(aTabTemp[nPosDe][3])
				For nContPa := 1 to Len(aCampos[nContDe][3])
					lMemo := ((aCampos[nContDe][3][nContPa]) $ cMemos)
						addBrowse(lMemo,aCampos[nContDe][3][nContPa],aCampos[nContDe+nStep][3][nContPa],@aBrowse,cAliasDe,cAliasPara,nStep,lPosNotFnd,lCompNotFnd)
				Next nContPa				
				Reclock(cAliasPara,.F.)
				(cAliasPara)->(dbDelete())					
				(cAliasPara)->(msunlock())
				(cAliasPara)->(dbSkip())
			EndDo
		Else

			/*
				tratamento realizado para garantir que o registro esteja posicionado
				para que retire os dados que existem em ambas as tabelas e só considere os diferentes
				caso contrário será adicionado todos os registros 'diferentes'
			*/
			(cAliasPara)->(dbGotop())
			lPosNotFnd	:= .F.
			lCompNotFnd := .T.
			For nContPa := 1 to Len(aCampos[nContDe][3])
				lMemo := ((aCampos[nContDe][3][nContPa]) $ cMemos)
				If !( Right(aCampos[nContDe][3][nContPa],Len(aCampos[nContDe][3][nContPa])-Rat("_",aCampos[nContDe][3][nContPa])) $ cRestri) 
					addBrowse(lMemo,aCampos[nContDe][3][nContPa],aCampos[nContDe+nStep][3][nContPa],@aBrowse,cAliasDe,cAliasPara,nStep,lPosNotFnd,lCompNotFnd)
				EndIf
			Next nContPa	
		Endif
		
		(cAliasDe)->(dbSkip())
	EndDo


	(cAliasDe)->(dbGotop())
	If (cAliasPara)->(reccount()) > 0
		(cAliasPara)->(dbGotop())
		While !(cAliasPara)->(EOF())
			
			lPosNotFnd	:= .T.
			lCompNotFnd := .F.
			For nContPa := 1 to Len(aCampos[nContDe][3])
				lMemo := ((aCampos[nContDe][3][nContPa]) $ cMemos)
				If !( Right(aCampos[nContDe][3][nContPa],Len(aCampos[nContDe][3][nContPa])-Rat("_",aCampos[nContDe][3][nContPa])) $ cRestri) 
					addBrowse(lMemo,aCampos[nContDe][3][nContPa],aCampos[nContDe+nStep][3][nContPa],@aBrowse,cAliasDe,cAliasPara,nStep,lPosNotFnd,lCompNotFnd)
				EndIf
			Next nContPa	
			(cAliasPara)->(dbSkip())
		EndDo
	EndIf
	If cEventoCom <> cEventoPos
		nContDe += 1
	EndIf
Next nContDe

Return

/*/{Protheus.doc} addBrowse
Função que adiciona os dados no array.
@type function
@version 1.0 
@author  Eduardo Vicente
@since   17/02/2021
@param   lMemo, array, Array de campos para comparação
@param   cCampPos, string, Campo posicionado
@param   cCampComp, string, Campo comparado
@param   aBrowse, array, Array do abrowse para carregar na interface
@param   cAliasDe, alias temporaria, Tabela Dê(posicionado)
@param   cAliasPara, alias temporaria, Tabela Dê(comparado)
@param	 nStep, numerico, Salto no laço caso os eventos sejam diferentes
@param   lPosNotFnd, lógico, Verificação se o registro posicionado foi localizado no comparado
@param   lCompNotFnd, lógico, Verificação se o registro comparado foi localizado no posicionado
/*/
Static Function addBrowse(lMemo,cCampPos,cCampComp,aBrowse,cAliasDe,cAliasPara,nStep,lPosNotFnd,lCompNotFnd)

Local cTipo			:= ""
Local cDescricao 	:= ""
Local cRetPosicd	:= ""
Local cRetCompad	:= ""
Local cDdPosi		:= ""
Local cDdComp		:= ""
Local aResult		:= {}

Default aBrowse		:= {}

If !lMemo
	
	cTipo := AllTrim( Posicione( "SX3", 2, cCampPos, "X3_TIPO" ) )

	If cTipo == "N"
		cDdPosi := (cAliasDe)->&(cCampPos)
		cDdComp := (cAliasPara)->&(cCampComp)
	Else
		cDdPosi := AllTrim((cAliasDe)->&(cCampPos))
		cDdComp := Alltrim((cAliasPara)->&(cCampComp))
	EndIf
	
EndIf

If !(cDDPosi == cDDComp)
		
	If lMemo 
		aResult := TafTratMem(cCampPos,cCampComp,cAliasDe)
	Else
		aResult := TafConCmps(cCampPos,cCampComp,cDdPosi,cDdComp)
	EndIf
	cDescricao := aResult[1]
	cRetPosicd := aResult[2]
	cRetCompad := aResult[3]

EndIf

If !Empty(cDescricao)

	If !lCompNotFnd .And. !lPosNotFnd
		
		aAdd(aBrowse,{cDescricao,cRetPosicd,cRetCompad  })	
	
	Else
	
		If lCompNotFnd
			aAdd(aBrowse,{cDescricao,cRetPosicd,"" })
		EndIf
		If lPosNotFnd
			aAdd(aBrowse,{cDescricao,"",cRetCompad })
		EndIf
	
	EndIf

EndIf

Return aBrowse

/*/{Protheus.doc} fMontaVinc
Rotina específica de criação de vinculo entre as tabelas temporárias
@type function
@version 1.0 
@author  Eduardo Vicente
@since   17/02/2021
@param   aTabTemp, array, Array que controla as tabelas temporárias e seus respectivos indices
@param   cChavNeg, string, Chave de where da V5P
@param   cAliasDe, alias temporaria, Tabela Dê(posicionado)
@param   cAliasPa, alias temporaria, Tabela Dê(comparado)
@param   cIdentFlx, lógico, Identificador de tabelas De\Para
@param   lEvntIgual, lógico, informa se são eventos iguais
/*/
Static Function fMontaVinc(aTabTemp,cChavNeg,cAliasDe,cAliasPa,cIdentFlx,lEvntIgual)

Local cChave		:= ""
Local aChave		:= ""
Local nContChv		:= 1
Local cChvDe		:= ""
Local cChvPa		:= ""
Local nPosDe		:= 0
Local cAliasTMP		:= 0
Local nPosPa		:= 0
Local lVazioTemp	:= Empty(aTabTemp) 


If !Empty(cChavNeg)
	aChave:= StrTokArr(cChavNeg," ")
	While nContChv <= Len(aChave) 
		If nContChv <= Len(aChave) .And.  Len(aChave[nContChv]) <= 3 .Or. ("D_E_L_E_T_"  $ aChave[nContChv])
			aDel(aChave,nContChv)
			aSize(aChave,Len(aChave)-1)
			nContChv := nContChv- 1
		Else	
			nContChv++
		EndIf
	EndDo
EndIf

For nContChv:= 1 to Len(aChave) 
	If Len(aChave[nContChv]) > 3 .and. !("D_E_L_E_T_"  $ aChave[nContChv])
		If cAliasDe $ aChave[nContChv]
			cChvDe += aChave[nContChv] + "+"
		EndIf
		If cAliasPa $ aChave[nContChv] 
			cChvPA += aChave[nContChv] + "+"
		EndIf
	EndIf
	
	If !lVazioTemp

		If Empty(cChave)
			cChave	:= cChavNeg
		EndIf
	
		If (nPosPa := aScan(aTabTemp,{|x| cAliasDe != (LEFT(aChave[nContChv],Rat("_",aChave[nContChv])-1)) .And. ;
										LEFT(aChave[nContChv],Rat("_",aChave[nContChv])-1) $ x[1] .And.;
									 (LEFT(aChave[nContChv],Rat("_",aChave[nContChv])-1)) $ x[6] .And.;
		 									IIF(lEvntIgual ,right(x[6],2) == cIdentFlx, x[6]==x[6]) })) > 0

			cAliasTMP := aTabTemp[nPosPa][2]:GetAlias()
			
			cChave:= StrTran(cChave,;
							aTabTemp[nPosPa][1]+"_"+  Right(aChave[nContChv],Len(aChave[nContChv])-Rat("_",aChave[nContChv])),;
							" '"+(cAliasTMP)->&( aTabTemp[nPosPa][1]+"_"+  Right(aChave[nContChv],Len(aChave[nContChv])-Rat("_",aChave[nContChv])))+"' ")
		EndIf
	EndIf

	If nContChv == Len(aChave)
		cChvDe := Substr(cChvDe,1,Len(cChvDe)-1)
		cChvPa := Substr(cChvPa,1,Len(cChvPa)-1)
	EndIf

Next nContChv

If (nPosDe := aScan(aTabTemp,{|x| x[1] == cAliasDe .And. x[6]==""})) > 0
	aTabTemp[nPosDe][1] := cAliasDe
	aTabTemp[nPosDe][3] := cChvDe
	aTabTemp[nPosDe][4] := cChvPa
Else 	
	//NOME DA TABELA,TABELA TEMPORARIA,CHAVE DE VINCULO ENTRE TABELA FILHA E TABELA PAI,CONTADOR,APELIDO DA TABELA, ARRAY DE INDICE
	aAdd(aTabTemp, {cAliasDe,"",cChvDe,cChvPa,0,"",{} }) 
EndIf

If lVazioTemp
	cChave	:= ""
ElseIF !Empty(cChave)
	cChave	:= " AND " + cChave
Endif
Return cChave

/*/{Protheus.doc} fCriaTemporary
Rotina de criação de temporários dinâmicos
@type function
@version 1.0 
@author  Eduardo Vicente
@since   17/02/2021
@param   aTabTemp, array, Array que controla as tabelas temporárias e seus respectivos indices
@param   cAlias	, alias , temporário gerado dinamicamente
@param   cTabName, String, Nome da tabela que será criado
@param   cTabNameP, String, Identifiador de tabela De/Para
@param   aIndice, array, Array de indices 
/*/
Static Function fCriaTemporary(aTabTemp,cAlias,cTabName,cTabNameP,aIndice)
Local lRet			:= .T.
Local nPosTab		:= 0
Local nContStrct:= 0
Local aCpoTemp	:= {}
Local nContRegs := 0
Local nContInd	:= 0
Local cIndice   := ""
Local aStruct		:= (cAlias)->(dbStruct())

nPosTab:= aScan(aTabTemp,{|x| x[1] == cTabName .And. x[6] == "" })
aTabTemp[nPosTab][2] := FWTEMPORARYTABLE():NEW(cTabName+cTabNameP)


For nContStrct:= 1 to Len(aStruct)

	aAdd(aCpoTemp,{aStruct[nContStrct][1],aStruct[nContStrct][2],aStruct[nContStrct][3],aStruct[nContStrct][4]})

Next nContStrct

aTabTemp[nPosTab][2]:SetFields(aCpoTemp) 

If !Empty(aIndice)
	aTabTemp[nPosTab][2]:AddIndex("IDX",aIndice)
EndIf

aTabTemp[nPosTab][2]:Create()
cAlsTmp		:= aTabTemp[nPosTab][2]:GetAlias()

While !(cAlias)->(EOF())

	RecLock(cAlsTmp,.T.)

	For nContStrct:= 1 to Len(aStruct)

		(cAlsTmp)->&(aStruct[nContStrct][1])	:= (cAlias)->&(aStruct[nContStrct][1])

	Next nContStrct

	(cAlsTmp)->(msUnlock())

	(cAlias)->(dbSkip())

	nContRegs++

EndDo

(cAlias)->(dbGotop())

For nContInd:= 1 to Len(aIndice)
	
	If nContInd == Len(aIndice)
	
		cIndice	+= aIndice[nContInd]
	
	Else
	
		cIndice	+= aIndice[nContInd] + "+"
	
	Endif

Next nContInd

aTabTemp[nPosTab][3] := cIndice							//INDICE DE BUSCA
aTabTemp[nPosTab][5] := nContRegs						//CONTADOR DE REGISTROS
aTabTemp[nPosTab][6] := cTabName+cTabNameP //APELIDO UNICO DA AMARRAÇÃO
aTabTemp[nPostab][7] := aIndice			   		//INDICE PARA VALIDAÇÃO POSTERIOR NO COMPARATIVO

Return lRet

/*/{Protheus.doc} fIgualArrays
Rotina que igual as chaves comparadoras 
@type function
@version 1.0 
@author  Eduardo Vicente
@since   17/02/2021
@param   aCposDe, array, Array com os campos Dê
@param   aCposPA, array , Array com os campos Para
@param   cRestri, String, Campos que devem ser retirados, pois não serão comparados.
/*/
Static Function fIgualArrays(aCposDe,aCposPA,cRestri)
Local nPos			:= 0
Local nContCpos		:= 1

While nContCpos < len(aCposDe) 

If (nPos:= aScan(aCposPA,{|x| Right(aCposDe[nContCpos],Len(aCposDe[nContCpos])-Rat("_",aCposDe[nContCpos])) $ x}))== 0 .Or.;
															(Right(aCposDe[nContCpos],Len(aCposDe[nContCpos])-Rat("_",aCposDe[nContCpos])) $ cRestri)	  
	aDel(aCposDe,nContCpos)
	aSize(aCposDe,len(aCposDe)-1)
Else
	nContCpos ++
EndIf

EndDo

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} FieldValid
Validação dos campos que serão apresentados na comparação

@param cCamposQry - String contendo os campos

@author Melkz Siqueira
@since 02/06/2021
@version 1.0		

@return cRet - Retorna uma string com os campos validados
/*/ 
//-------------------------------------------------------------------
Static Function FieldValid(cCamposQry, cEventoPos, cEventoCom)

	Local aCamposQry	:= {}
	Local cRet			:= ""
	Local nX			:= 0
	Local lOK			:= .F.

	Default cCamposQry 	:= ""
	Default cEventoPos	:= ""
	Default cEventoCom	:= ""

	If !Empty(cCamposQry)
		aCamposQry := StrTokArr2(cCamposQry, ",")

		For nX := 1 To Len(aCamposQry)
			If !SubStr(aCamposQry[nX], At("_", aCamposQry[nX]), Len(aCamposQry[nX])) $ "_XMLID|_LOGOPE|_OWNER|_TAFKEY|"
				If !lLaySimplif
					lOK := .T.
				Else
					If cEventoPos $ "S2205" .OR. cEventoCom $ "S2205"
						If !SubStr(aCamposQry[nX], At("_", aCamposQry[nX]), Len(aCamposQry[nX])) $ "_DTNASC|_CODPAI"
							lOK := .T.
						EndIf
					Else
						lOK := .T.
					EndIf	
				EndIf

				If lOK
					lOK	:= .F.
					
					If Empty(cRet)
						cRet += aCamposQry[nX]
					Else
						cRet += "," + aCamposQry[nX]
					EndIf
				EndIf
			EndIf
		Next
	EndIf

Return cRet
