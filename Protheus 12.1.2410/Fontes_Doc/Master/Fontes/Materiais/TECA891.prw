#INCLUDE "TOTVS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TECA891.CH"

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Realiza apontamento dos materiais 

@author Serviços
@since 22/06/2015
@version P12
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function ModelDef()
Local oStruTFL	:= FWFormStruct( 1, 'TFL' )
Local oStruTGU	:= FWFormStruct( 1, 'TGU' )
Local bCommit	:= {|oModel|At891Commit(oModel)}
Local oModel	:= MPFormModel():New( 'TECA891',/*bPreValidacao*/,/*bPosVld*/,bCommit,/*bCancel*/)
Local lFldCtb	:= TGU->(ColumnPos("TGU_CONTA"))>0 .And. TGU->(ColumnPos("TGU_ITEM"))>0 .And. TGU->(ColumnPos("TGU_CLVL"))>0
Local aAux		:= {}

If lFldCtb
	aAux := FwStruTrigger("TGU_PROD","TGU_CC"   ,'Posicione("ABS",1,xFilial("ABS")+FwFldGet("TFL_LOCAL"),"ABS_CCUSTO")',.F.,Nil,Nil,Nil)
	oStruTGU:AddTrigger(aAux[1],aAux[2],aAux[3],aAux[4])

	aAux := FwStruTrigger("TGU_PROD","TGU_CONTA",'Posicione("ABS",1,xFilial("ABS")+FwFldGet("TFL_LOCAL"),"ABS_CONTA")' ,.F.,Nil,Nil,Nil)
	oStruTGU:AddTrigger(aAux[1],aAux[2],aAux[3],aAux[4])

	aAux := FwStruTrigger("TGU_PROD","TGU_ITEM" ,'Posicione("ABS",1,xFilial("ABS")+FwFldGet("TFL_LOCAL"),"ABS_ITEM")'  ,.F.,Nil,Nil,Nil)
	oStruTGU:AddTrigger(aAux[1],aAux[2],aAux[3],aAux[4])

	aAux := FwStruTrigger("TGU_PROD","TGU_CLVL" ,'Posicione("ABS",1,xFilial("ABS")+FwFldGet("TFL_LOCAL"),"ABS_CLVL")'  ,.F.,Nil,Nil,Nil)
	oStruTGU:AddTrigger(aAux[1],aAux[2],aAux[3],aAux[4])
EndIf

oStruTFL:AddField( STR0001 ,STR0001 ,'TFL_DESLOC', 'C', 60, 0,/*bValid*/,/*bWhen*/, /*aValues*/, .F., ,/*lKey*/, /*lNoUpd*/, .F./*lVirtual*/,/*cValid*/) //Descrição
oStruTFL:AddField( STR0002 ,STR0002 ,'TFL_SALDO' , 'N', 16, 2,,/*bWhen*/, /*aValues*/, .F., ,/*lKey*/, /*lNoUpd*/, .F./*lVirtual*/,/*cValid*/)			  //Status
oStruTFL:AddField( STR0026 ,STR0026 ,'TFL_CNTREC', 'C', TAMSX3("TFJ_CNTREC")[1],0,/* */,/*bValid*/, /*bWhen*/, .F., {|| Posicione("TFJ", 1, xFilial("TFJ") + TFL->TFL_CODPAI ,"TFJ_CNTREC") } ,/*lKey*/, .F./*lNoUpd*/, .T./*lVirtual*/,/*cValid*/)//"Contrato recorrente"##"Contrato Recorrente"

oModel:AddFields( 'MODEL_TFL' , /*cOwner*/ , oStruTFL )

oModel:AddGrid ( 'MODEL_TGU' , 'MODEL_TFL' , oStruTGU, {|oModel,nLine,cAction| FDelReg(oModel,nLine,cAction)} )
oModel:GetModel( 'MODEL_TGU' ):SetUniqueLine( { 'TGU_COD'} )

oModel:SetRelation( 'MODEL_TGU', { { 'TGU_FILIAL', 'xFilial( "TGU" )' }, { 'TGU_CODTFL', 'TFL_CODIGO' } }, TGU->( IndexKey( 1 ) ) )
oModel:GetModel( 'MODEL_TGU' ):SetOptional(.T.)

//Aplica o filtro no model
oModel:GetModel( 'MODEL_TGU' ):SetLoadFilter( { { 'TGU_APURAC', "' '" } } )

oModel:SetActivate( {|oModel| InitDados( oModel ) } )

Return ( oModel )

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Realiza apontamento dos materiais 

@author Serviços
@since 22/06/2015
@version P12
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function ViewDef()

Local oModel 	:= 	FWLoadModel ( 'TECA891' )
Local oView 	:= 	FWFormView():New()

Local oStruTFL  :=  Nil
Local oStruTGU 	:= 	Nil

cCmpsFil   :=  '|TFL_LOCAL|'
oStruTFL 	:= 	FWFormStruct( 2, 'TFL', {|cCampo| ( AllTrim( cCampo )+"|" $ cCmpsFil ) } )

cCmpsFil	:= '|TGU_CODTWZ|'
oStruTGU   := 	FWFormStruct( 2, 'TGU', {|cCampo| !( AllTrim( cCampo )+"|" $ cCmpsFil ) } )

oStruTFL:SetProperty('TFL_LOCAL', MVC_VIEW_CANCHANGE, .F.)

oView:SetModel( oModel )            
                                        
oStruTFL:AddField( 'TFL_DESLOC', ; // cIdField
       			 '04', ; // cOrdem
                   STR0001, ; // cTitulo - Descrição
                   STR0001, ; // cDescric  - Descrição
                   {}, ; // aHelp
                   'C', ; // cType
                   '', ; // cPicture
       			  Nil, ; // nPictVar
                    Nil, ; // Consulta F3
                    .F., ; // lCanChange
                    '', ; // cFolder
                    Nil, ; // cGroup
                    Nil, ; // aComboValues
                    Nil, ; // nMaxLenCombo
                    '', ; // cIniBrow
                    .T., ; // lVirtual
                    '' ) // cPictVar
                    
oStruTFL:AddField( 'TFL_CONTRT', ; // cIdField
       				'05',; // cOrdem
                    STR0003,; // cTitulo - Contrato
                    STR0003 , ; // cDescric - Contrato
                    {}, ; // aHelp
                   	'C', ; // cType
                   	'', ; // cPicture
       				Nil, ; // nPictVar
                    Nil, ; // Consulta F3
                    .F., ; // lCanChange
                    '', ; // cFolder
                    Nil, ; // cGroup
                    Nil, ; // aComboValues
                    Nil, ; // nMaxLenCombo
                    Nil, ; // cIniBrow
                    .T., ; // lVirtual
                    Nil ) // cPictVar     
                    
oStruTFL:AddField( 'TFL_CONREV', ; // cIdField
       				'06', ; // cOrdem
                    STR0004 , ; // cTitulo - Revisão
                    STR0004 , ; // cDescric - Revisão
                    {}, ; // aHelp
                   	'C', ; // cType
                   	'', ; // cPicture
       				Nil, ; // nPictVar
                    Nil, ; // Consulta F3
                    .F., ; // lCanChange
                    '', ; // cFolder
                    Nil, ; // cGroup
                    Nil, ; // aComboValues
                    Nil, ; // nMaxLenCombo
                    Nil, ; // cIniBrow
                    .T., ; // lVirtual
                    Nil ) // cPictVar    
                    
oStruTFL:AddField( 'TFL_SALDO', ; // cIdField
       				'07', ; // cOrdem
                    STR0002 , ; // cTitulo - Saldo
                    STR0002 , ; // cDescric - Saldo
                    {}, ; // aHelp
                   	'N', ; // cType
                   	'@E 999,999,999.99', ; // cPicture
       				Nil, ; // nPictVar
                    Nil, ; // Consulta F3
                    .F., ; // lCanChange
                    '', ; // cFolder
                    Nil, ; // cGroup
                    Nil, ; // aComboValues
                    Nil, ; // nMaxLenCombo
                    Nil, ; // cIniBrow
                    .T., ; // lVirtual
                    Nil ) // cPictVar     

oStruTFL:AddField( 'TFL_CNTREC', ; // cIdField
       				'08', ; // cOrdem
                     STR0026, ; // "Contrato Recorrente"
                     STR0026, ; // "Contrato Recorrente"
                     {}, ; // aHelp
                   	'C', ; // cType
                   	'@ ', ; // cPicture
       				Nil, ; // nPictVar
                     Nil, ; // Consulta F3
                     .F., ; // lCanChange
                    '', ; // cFolder
                     Nil, ; // cGroup
                     {STR0027,STR0028}, ; // aComboValues "1=Sim"##"2=Não"
                     Nil, ; // nMaxLenCombo
                     Nil, ; // cIniBrow
                     .T., ; // lVirtual
                     Nil ) // cPictVar

//Exibindo os titulos da tela
oView:AddField( 'VIEW_TFL', oStruTFL, 'MODEL_TFL' )
oView:EnableTitleView( 'VIEW_TFL', STR0005 ) //Local de Atendimento"

oView:AddGrid ( 'VIEW_TGU', oStruTGU, 'MODEL_TGU' )
oView:EnableTitleView( 'VIEW_TGU', STR0006 ) //Apontamento por Valor

oView:AddUserButton(STR0009,"",{|oView| FHist891()}) //"Histórico" 
oView:AddUserButton(STR0031,"",{|oView| At890CpAp( oModel )}) //"Copiar apontamentos"

//Definindo os espaços de tela
oView:CreateHorizontalBox( 'FIELDSTFL', 30 )
oView:CreateHorizontalBox( 'GRIDTGU', 70 )

oView:SetOwnerView( 'VIEW_TFL', 'FIELDSTFL' )
oView:SetOwnerView( 'VIEW_TGU', 'GRIDTGU' )


Return ( oView ) 

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} InitDados
Realiza a inicialização dos valores na carga da tela

@Param
oModel - Model Corrente 

@author Serviços
@since 22/06/2015
@version P12
/*/
//--------------------------------------------------------------------------------------------------------------------	
Static Function InitDados( oModel )

Local cDesLoc   := ''
Local cQuery    := ''
Local cAliasQry := ''
Local nSaldo    := 0
Local lCntRec   := oModel:GetValue("MODEL_TFL", "TFL_CNTREC") == "1" .And. (Posicione( "TFJ", 1, xFilial("TFJ") + FWFLDGET("TFL_CODPAI"), "TFJ_GESMAT") <> "5")
Local dDtIni    := FirstDate(dDataBase)
Local dDtFim    := LastDate(dDataBase)
Local lOrcPrc   := SuperGetMv("MV_ORCPRC",,.F.) 
Local oExec     := Nil

//Grava a descrição do Local de Atendimento para exibição no cabeçalho
cDesLoc := Alltrim( Posicione( "ABS", 1, xFilial("ABS") + FWFLDGET("TFL_LOCAL"), "ABS_DESCRI") )
oModel:LoadValue("MODEL_TFL", "TFL_DESLOC", cDesLoc)

//	Soma os Apontamentos por Valor
cQuery    := "SELECT SUM( "
If lCntRec
	cQuery += "  CASE WHEN TGU_DATA BETWEEN ? AND ? "
	cQuery += "       THEN TGU_QUANT * TGU_VALOR "
	cQuery += "       ELSE 0  END "
Else
	cQuery += "       TGU_QUANT * TGU_VALOR "
Endif
cQuery    += "  ) AS SALDO"
cQuery    += "  FROM ? "
cQuery    += " WHERE D_E_L_E_T_ = ' ' "
cQuery    += "   AND TGU_FILIAL = ? "
cQuery    += "   AND TGU_CODTFL = ? "
cQuery := ChangeQuery(cQuery)

cQuery := ChangeQuery(cQuery)
oExec := FwExecStatement():New(cQuery)

oExec:SetDate( 1, dDtIni )
oExec:SetDate( 2, dDtFim )
oExec:SetUnsafe( 3, RetSqlName("TGU") )
oExec:SetString( 4, xFilial("TGU") )
oExec:SetString( 5, TFL->TFL_CODIGO )

cAliasQry := oExec:OpenAlias()
nSaldo := (cAliasQry)->SALDO

(cAliasQry)->(dbCloseArea())
oExec:Destroy()
FwFreeObj(oExec)

//Busca o valor de materiais de todos os itens de recursos humanos utilizados no local de trabalhoTFF
If lOrcPrc
	nSaldo := TFL->TFL_TOTMI
Else
	cQuery := " SELECT SUM( TFF.TFF_VLRMAT + TFF.TFF_VLRCON ) TFF_VLRMAT "
	cQuery += " FROM ? TFF "
	cQuery += " WHERE TFF.TFF_FILIAL = ? "
	cQuery +=   " AND TFF.TFF_LOCAL = ? "
	cQuery +=   " AND TFF.TFF_CODPAI = ? "
	cQuery +=   " AND TFF.D_E_L_E_T_ = ' '"

	cQuery := ChangeQuery(cQuery)
	oExec := FwExecStatement():New(cQuery)

	oExec:SetUnsafe( 1, RetSqlName("TFF") )
	oExec:SetString( 2, xFilial("TFF") )
	oExec:SetString( 3, TFL->TFL_LOCAL )
	oExec:SetString( 4, TFL->TFL_CODIGO )

	cAliasQry := oExec:OpenAlias()

	nSaldo := (cAliasQry)->TFF_VLRMAT - nSaldo

	(cAliasQry)->(dbCloseArea())
	oExec:Destroy()
	FwFreeObj(oExec)
EndIf
//Atualiza o campo de Saldo do cabeçalho
oModel:LoadValue("MODEL_TFL", "TFL_SALDO", nSaldo )

Return


//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} F891VldGrid
Atualiza o valor do Saldo 

@Param
cCmp - Campo que será validado

@author Serviços
@since 22/06/2015
@version P12
/*/
//--------------------------------------------------------------------------------------------------------------------
Function F891VldGrid( cCmp )

Local lRet    := .T.
Local nTotAtu := 0
Local nSaldo  := 0
Local lCntRec := .F.
Local dDtIni  := FirstDate(dDataBase)
Local dDtFim  := LastDate(dDataBase)

oView  := FWViewActive()	//Recuperando a view ativa da interface
oModel := FWModelActive()	//Recuperando a view ativa da interface

nSaldo := oModel:GetValue( 'MODEL_TGU' , 'TGU_TOTAL' ) //Valor Anterior
lCntRec := oModel:GetValue( 'MODEL_TFL' , 'TFL_CNTREC' ) == "1"

if 'TGU_QUANT' $ cCmp
	If lCntRec
		If oModel:GetValue( 'MODEL_TGU' , 'TGU_DATA' ) >= dDtIni .And. oModel:GetValue( 'MODEL_TGU' , 'TGU_DATA' ) <= dDtFim
			nTotAtu := M->TGU_QUANT * ( oModel:GetValue( 'MODEL_TGU' , 'TGU_VALOR' ) )
		Endif
	Else
		nTotAtu := M->TGU_QUANT * ( oModel:GetValue( 'MODEL_TGU' , 'TGU_VALOR' ) )		
	Endif
elseif 'TGU_VALOR' $ cCmp
	If lCntRec
		If oModel:GetValue( 'MODEL_TGU' , 'TGU_DATA' ) >= dDtIni .And. oModel:GetValue( 'MODEL_TGU' , 'TGU_DATA' ) <= dDtFim
			nTotAtu := ( oModel:GetValue( 'MODEL_TGU' , 'TGU_QUANT' ) ) * M->TGU_VALOR
		Endif
	Else
		nTotAtu := ( oModel:GetValue( 'MODEL_TGU' , 'TGU_QUANT' ) ) * M->TGU_VALOR	
	Endif
else
	Return ( .T. )	
endif

if nTotAtu <> nSaldo
	nSaldo :=  nTotAtu - nSaldo	
else
	nSaldo := 0
endif

nSaldo := oModel:GetValue( 'MODEL_TFL' , 'TFL_SALDO' ) - nSaldo 
if nSaldo >= 0
	//Atualiza o campo de Saldo do cabeçalho
	oModel:LoadValue("MODEL_TFL", "TFL_SALDO", nSaldo)
else
	Help( ' ', 1, 'TECA891', , STR0007 , 1, 0 ) //Limite de saldo excedido
	lRet := .F.
endif
 
Return ( lRet )

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FVld891Dt
Verifica se a data informada esta no período de vigência 

@author Serviços
@since 22/06/2015
@version P12
/*/
//--------------------------------------------------------------------------------------------------------------------
Function FVld891Dt()

Local lRet := .T.
Local dDtIni  	:= FirstDate(dDataBase)
Local dDtFim  	:= LastDate(dDataBase)
Local oModel 	:= FWModelActive()	//Recuperando a view ativa da interface
Local lCntRec	:= oModel:GetValue("MODEL_TFL", "TFL_CNTREC") == "1"

if ( M->TGU_DATA > TFL->TFL_DTFIM ) .Or. ( M->TGU_DATA < TFL->TFL_DTINI )
	Help( ' ', 1, 'TECA891', , STR0008, 1, 0 ) //Data fora do período de vigência do local
	lRet := .F.
endif

If lRet .And. lCntRec .And. !(M->TGU_DATA >= dDtIni .And. M->TGU_DATA <= dDtFim)
	Help( ' ', 1, 'TECA891', , STR0029+cValTochar(dDtIni)+STR0030+cValTochar(dDtFim), 1, 0 ) //"Data fora do período de recorrencia "##" a "
	lRet := .F.
Endif

Return ( lRet )                                                                                                                      

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FHist891
Monta tela de Histórico de apontamento de materiais 

@author Serviços
@since 22/06/2015
@version P12
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function FHist891()

Local cAliasPro	:= "AT891QRY"
Local cRotina  := 'TECA891'
Local cTitulo  := STR0009 //Histórico
Local cQuery   := ''

Local aSize	 	:= FWGetDialogSize( oMainWnd ) 	// Array com tamanho da janela.
Local aFields  := {}

Local oPanel   := Nil
Local oFWLayer := Nil
Local oBrowse  := Nil

oBrowse := FWFormBrowse():New()

aColumns := At891Cols()
cQuery   := At891Query()

DEFINE DIALOG oDlg TITLE STR0009 FROM aSize[1] + 100,aSize[2] + 100 TO aSize[3] - 100, aSize[4] - 100 PIXEL //Histórico
	
// Cria um Form Browse
oBrowse := FWFormBrowse():New()

// Atrela o browse ao Dialog form nao abre sozinho
oBrowse:SetOwner(oDlg)

// Indica que vai utilizar query
oBrowse:SetAlias(cAliasPro)
oBrowse:SetDataQuery(.T.)
oBrowse:SetQuery(cQuery)


oBrowse:SetColumns(aColumns)						 
oBrowse:DisableDetails()

oBrowse:AddButton( STR0010 , { || oDlg:End() },,,, .F., 2 ) //Sair	

oBrowse:SetDescription(STR0009)	//Histórico

oBrowse:Activate()

ACTIVATE DIALOG oDlg CENTERED

Return ( .T. )

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At891Cols
Monta as colunas de exibição da GRID 

@author Serviços
@since 22/06/2015
@version P12
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At891Cols()

Local nI		:= 0 
Local aArea		:= GetArea()
Local aColumns	:= {}
Local aRet		:= {}
Local aCampos 	:= { "TGU_DATA", "TGU_PROD", "B1_DESC", "TGU_QUANT", "TGU_VALOR", "TGU_TOTAL", "TGU_APURAC" }

For nI := 1 To Len(aCampos)
	cCampo := aCampos[nI]
	If cCampo == "TGU_TOTAL"
		AAdd(aColumns,FWBrwColumn():New())
		nLinha := Len(aColumns)
	   	aColumns[nLinha]:SetType("N")
	   	aColumns[nLinha]:SetTitle(STR0011) //Total
		aColumns[nLinha]:SetSize(14)
		aColumns[nLinha]:SetDecimal(2)
		aColumns[nLinha]:SetPicture("@E 999,999,999.99" )
		aColumns[nLinha]:SetData(&("{||" + cCampo + "}"))		
	Else
		aRet := FwTamSx3(cCampo)
		AAdd(aColumns,FWBrwColumn():New())
		nLinha := Len(aColumns)
		aColumns[nLinha]:SetType(aRet[3])
		aColumns[nLinha]:SetTitle(AllTrim(FWX3Titulo(cCampo)))
		aColumns[nLinha]:SetSize(aRet[1])
		aColumns[nLinha]:SetDecimal(aRet[2])
		aColumns[nLinha]:SetPicture(AllTrim(X3Picture(cCampo)))
		If aRet[3] == "D"
			aColumns[nLinha]:SetData(&("{|| sTod(" + cCampo + ")}"))		
		Else
			aColumns[nLinha]:SetData(&("{||" + cCampo + "}"))	
		EndIf
	EndIf
Next nI

RestArea(aArea)

Return(aColumns)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At891Query
Monta a Query de Exibição na GRID 

@author Serviços
@since 22/06/2015
@version P12
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At891Query()

cQuery := " SELECT TGU_DATA, TGU_PROD, B1_DESC, TGU_QUANT, TGU_VALOR, ( TGU_QUANT * TGU_VALOR ) TGU_TOTAL, TGU_APURAC "
 
cQuery += " FROM " + RetSqlName("TGU")

cQuery += " INNER JOIN " + RetSqlName("SB1")
cQuery += " ON B1_FILIAL = '" + xFilial("SB1") + "' AND"
cQuery += " TGU_PROD = B1_COD "
  
cQuery += " WHERE TGU_APURAC <> ''"
cQuery += " AND TGU_CODTFL = '" + TFL->TFL_CODIGO + "'"
cQuery += " AND "+RetSqlName("TGU")+".D_E_L_E_T_ = ''"
cQuery += " AND "+RetSqlName("SB1")+".D_E_L_E_T_ = ''"

cQuery += " ORDER BY TGU_DATA"

Return ( cQuery )

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FDelReg
Realiza o Delete / Undelete da GRID 


@author Serviços
@since 22/06/2015
@version P12
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function FDelReg(oMdlApt, nLine, cAction)
Local lRet		:= .T.
Local oModel 	:= FWModelActive()	//Recuperando a view ativa da interface
Local lCntRec 	:= oModel:GetValue("MODEL_TFL", "TFL_CNTREC") == "1"
Local dDtIni  	:= FirstDate(dDataBase)
Local dDtFim  	:= LastDate(dDataBase)

If lCntRec .And. !Empty(oMdlApt:GetValue("TGU_DATA")) .And. !(oMdlApt:GetValue("TGU_DATA") >= dDtIni .And. oMdlApt:GetValue("TGU_DATA") <= dDtFim) 
	lRet := .F.		
	If cAction == 'DELETE'	
		Help( ' ', 1, 'FDelReg', , STR0029+cValTochar(dDtIni)+STR0030+cValTochar(dDtFim), 1, 0 ) //"Data fora do período de recorrencia "##" a "
	Endif
Endif

if lRet .And. cAction == 'DELETE'	
	If (Empty(oMdlApt:GetValue("TGU_DATA")) .AND. Empty(oMdlApt:GetValue("TGU_PROD")) .AND. Empty(oMdlApt:GetValue("TGU_QUANT")) .AND. Empty(oMdlApt:GetValue("TGU_VALOR")))		
		TGU->(RollBackSx8())	
	Else
		nSaldo := oModel:GetValue( 'MODEL_TFL' , 'TFL_SALDO' ) + oModel:GetValue( 'MODEL_TGU' , 'TGU_TOTAL' )
		oModel:LoadValue("MODEL_TFL", "TFL_SALDO", nSaldo )
	EndIf
	
elseif lRet .And. cAction == 'UNDELETE'
	nSaldo := oModel:GetValue( 'MODEL_TFL' , 'TFL_SALDO' ) - oModel:GetValue( 'MODEL_TGU' , 'TGU_TOTAL' )
	If nSaldo >= 0
		oModel:LoadValue("MODEL_TFL", "TFL_SALDO", nSaldo )
	Else
		Help( ' ', 1, 'TECA891', , STR0007 , 1, 0 ) //Limite de saldo excedido
		lRet := .F.
	EndIf
endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} At891Commit()
Commit do Modelo de Dados

@sample		At891Commit(oModel)

@param		ExpO - Modelo de Dados
	
@return		ExpL - Retorna Verdadeiro, caso a Inclusão dos campos foram feitos com sucesso

@author		Serviços
@since		02/02/2017
@version	12  
/*/
//------------------------------------------------------------------
Static Function At891Commit(oModel)
Local lRet 		:= .T.
Local bAfter	:= {|oModel,cID,cAlias| At891After(oModel,cID,cAlias)}

	FWModelActive( oModel )
	lRet := FWFormCommit( oModel,/*bBefore*/,bAfter,NIL)

	If lRet == .T.
		Begin Transaction

			If !(lRet := At891ExcAt(oModel))
				DisarmTransacation()
			EndIf

		End Transaction
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} At891After()
Função para Realizar a Inclusão do Custo

@sample		At891After(oModel,cID,cAlias)

@param		ExpO - Modelo de Dados
			ExpC - ID do Modelo
			ExpC - Alias da Tabela
	
@return		ExpL - Retorna Verdadeiro, caso a Inclusão dos campos foram feitos com sucesso

@author		Serviços
@since		02/02/2017
@version	12  
/*/
//------------------------------------------------------------------
Static Function At891After(oModel,cID,cAlias)
Local lRet 		:= .T.
Local cCodTWZ	:= ""
Local aAlter	:= {}
Local oMdlFull	:= Nil

If ( cId == "MODEL_TGU" .AND. cAlias == "TGU" )
	oMdlFull := FwModelActive()
	Do Case
		Case oModel:IsDeleted()
			If !Empty(oModel:GetValue("TGU_CODTWZ"))
				At995ExcC(oMdlFull:GetModel("MODEL_TFL"):GetValue("TFL_CODPAI"),oModel:GetValue("TGU_CODTWZ"))
			EndIf	
		Case oModel:IsInserted()
			cCodTWZ := At995Custo(oMdlFull:GetModel("MODEL_TFL"):GetValue("TFL_CODPAI"),;
						NIL,oMdlFull:GetModel("MODEL_TFL"):GetValue("TFL_CODIGO"),;
						oModel:GetValue("TGU_PROD"),"5",oModel:GetValue("TGU_TOTAL"),"TECA891")
			If !Empty(cCodTWZ)
				RecLock("TGU", .F.)
					TGU->TGU_CODTWZ := cCodTWZ
				TWZ->(MsUnlock())
			EndIf		
		Case oModel:IsUpdated()
			At995ExcC(oMdlFull:GetModel("MODEL_TFL"):GetValue("TFL_CODPAI"),oModel:GetValue("TGU_CODTWZ"))
			cCodTWZ := At995Custo(oMdlFull:GetModel("MODEL_TFL"):GetValue("TFL_CODPAI"),;
						NIL,oMdlFull:GetModel("MODEL_TFL"):GetValue("TFL_CODIGO"),;
						oModel:GetValue("TGU_PROD"),"5",oModel:GetValue("TGU_TOTAL"),"TECA891")
			If !Empty(cCodTWZ)
				RecLock("TGU", .F.)
					TGU->TGU_CODTWZ := cCodTWZ
				TWZ->(MsUnlock())
			EndIf				
	End Case
EndIf

Return lRet
//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc}  At891ExcAt

Realiza a Gravação dos dados utilizando a ExecAuto MATA240 para inclusão e extorno de apontamentos.
no Modulo Estoque
@sample  At891ExcAt() 
@author  Serviços
@since 	  31/10/13
@version P11 R9
@param ExpO:Modelo de Dados da Tela de Locais de Atendimento

@return ExpL: Retorna .T. quando houve sucesso na ExecAuto
/*/
//--------------------------------------------------------------------------------------------------------------------

Function At891ExcAt(oModel)

	Local lRetorno			:= .T.			//validador de retorno, caso ocorra algum erro, ele retorna false, evitando que seja adicionado dados na tabela ABV
	Local nCntFor			:= 0
	Local aArea				:= GetArea()		//Pega posição GetArea()
	Local aSaveLines		:= FWSaveRows()
	Local oModelTGU			:= oModel:GetModel("MODEL_TGU")
	Local cNumero 			:= ""
	Local lGsApmat   		:= SuperGetMv('MV_GSAPMAT',.F.,.F.)
	Local lDeleted			:= .F.
	Local nOpc				:= 0
	Local cMsg				:= ''

	For nCntFor := 1 To oModelTGU:Length() // Quantidade linhas

		oModelTGU:GoLine(nCntFor)
		lDeleted:=oModelTGU:IsDeleted()//Se verdade o registro foi excluído
		aSaveLines	:= FWSaveRows()

		If Empty(oModelTGU:GetValue("TGU_CODSA")) .and. !lDeleted
			nOpc:=3
			cMsg:= STR0034
		ElseIf !Empty(oModelTGU:GetValue("TGU_CODSA")) .and. !lDeleted
			nOpc:=4
			cMsg:= STR0032
		ElseIf !Empty(oModelTGU:GetValue("TGU_CODSA")) .and. lDeleted
			nOpc:=5
			cMsg:= STR0035
		else
			nOpc:=0
		EndIf

		If Empty(oModelTGU:GetValue("TGU_APURAC")) .AND. lGsApmat	//Verifica se o apontamento ainda não foi apurado/Se integração está Habilitada

			If nOpc > 0

				MsgRun(cMsg, STR0033, {||lretorno:=At891SolArmaz(oModelTGU,nOpc,@cNumero)}) //Processando Solicitação

				If lRetorno .and. Empty(oModelTGU:GetValue("TGU_CODSA"))
					At891CodSa(cNumero)
				ENDIF

			ENDIF

		ENDIF

		FwRestRows( aSaveLines )
	Next nCntFor

	RestArea(aArea)

Return (lRetorno)
//-------------------------------------------------------------------
/*/{Protheus.doc} At890INum

Função de inicializador padrão de auto numeração com confirmação de gravação

@author Vitor Kwon
@since 19/04/22
/*/
//-------------------------------------------------------------------

Static Function At891INum(cAlias, cCampo, nQualndex)

	Local aArea     := GetArea()
	Local aAreaTmp  := (cAlias)->(GetArea())
	Local cProxNum  := ""

	Default nQualndex := 1

	cProxNum  := GetSx8Num(cAlias, cCampo,, nQualndex)

	dbSelectArea(cAlias)
	dbSetOrder(nQualndex)

	While dbSeek( xFilial( cAlias ) + cProxNum )
		If ( __lSx8 )
			ConfirmSX8()
		EndIf
		cProxNum := GetSx8Num(cAlias, cCampo,, nQualndex)
	End

	RestArea(aAreaTmp)
	RestArea(aArea)

Return(cProxNum)

//-------------------------------------------------------------------
/*/{Protheus.doc} At891CodSa

Função de gravação do código da solicitação da SA no registro da TGU

@author André Rupolo
@since 14/11/23
/*/
//-------------------------------------------------------------------
Static Function At891CodSa(cNumero)
	Local lRetorno  := .T.
	Local aArea     := GetArea()

	TGU->(DbSetOrder(1))

	If !Empty(cNumero)
		RECLOCK( 'TGU', .F. )
		TGU->TGU_CODSA := cNumero
		TGU->(MSUNLOCK())
	EndIf

	RestArea(aArea)
Return lRetorno
//-------------------------------------------------------------------
/*/{Protheus.doc} At891CodSa

Carrega os dados para execução do ExecAuto MATA105

@author André Rupolo
@since 14/11/23
/*/
//-------------------------------------------------------------------
Static Function At891SolArm(oModelTGU,nOpc,cNumero)

	Local cPrdTGU	:= ""
	Local cQtdTGU	:= ""
	Local cLocTGU	:= ""
	Local cUM		:= ""
	Local cCustoTGU	:= ""
	Local cCLVLTFT	:= ""
	Local cItConTFT	:= ""
	Local cContaTFT	:= ""
	Local dEmiTGU	:= ""
	Local aCab 		:= {}
	Local aItens	:= {}
	Local lFldCtb	:= TGU->(ColumnPos("TGU_CONTA"))>0 .And. TGU->(ColumnPos("TGU_ITEM"))>0 .And. TGU->(ColumnPos("TGU_CLVL"))>0
	Local nVlrUNit	:= 0

	Private lMsErroAuto := .F. // Informa a ocorrência de erros no ExecAuto

	DEFAULT cNumero :=""

	BEGIN Transaction

		If oModelTGU:GetValue("TGU_QUANT") <> 0

			cPrdTGU     := oModelTGU:GetValue("TGU_PROD")
			cQtdTGU     := oModelTGU:GetValue("TGU_QUANT")
			cLocTGU     := oModelTGU:GetValue("TGU_LOCAL")
			cUM         := Posicione("SB1",1,xFilial("SB1")+cPrdTGU,"B1_UM")
			nVlrUNit    := Posicione("SB1",1,xFilial("SB1")+cPrdTGU,"B1_CUSTD")
			cCustoTGU	:= oModelTGU:GetValue("TGU_CC")
			dEmiTGU     := oModelTGU:GetValue("TGU_DATA")
			If lFldCtb
				cContaTGU	:= oModelTGU:GetValue("TGU_CONTA")
				cItConTGU	:= oModelTGU:GetValue("TGU_ITEM")
				cCLVLTGU	:= oModelTGU:GetValue("TGU_CLVL")
			EndIf

			dbSelectArea('SCP')
			SCP->(dbSetOrder(1))

			If Empty(oModelTGU:GetValue("TGU_CODSA"))
				cNumero := At891INum('SCP', 'CP_NUM', 1)
			else
				cNumero := oModelTGU:GetValue("TGU_CODSA")
			ENDIF

			Aadd(aCab,{ "CP_NUM"     ,cNumero, nil})
			Aadd(aCab,{ "CP_EMISSAO" ,dEmiTGU ,nil})

			Aadd(aItens,{})
			Aadd(aItens[Len(aItens)],{"CP_ITEM"    ,'01'             ,nil})
			Aadd(aItens[Len(aItens)],{"CP_PRODUTO" ,Alltrim(cPrdTGU) ,nil})
			Aadd(aItens[Len(aItens)],{"CP_UM"      ,cUM              ,nil})
			Aadd(aItens[Len(aItens)],{"CP_QUANT"   ,cQtdTGU          ,nil})
			Aadd(aItens[Len(aItens)],{"CP_DATPRF"  ,dEmiTGU          ,nil})
			Aadd(aItens[Len(aItens)],{"CP_LOCAL"   ,cLocTGU          ,nil})
			Aadd(aItens[Len(aItens)],{"CP_CC"      ,cCustoTGU        ,nil})
			Aadd(aItens[Len(aItens)],{"CP_CONTA"   ,cContaTFT        ,nil})
			Aadd(aItens[Len(aItens)],{"CP_ITEMCTA" ,cItConTFT        ,nil})
			Aadd(aItens[Len(aItens)],{"CP_CLVL"    ,cCLVLTFT         ,nil})
			Aadd(aItens[Len(aItens)],{"CP_VUNIT"   ,nVlrUNit         ,nil})
		Endif

		MSExecAuto({|x,y,z| mata105(x,y,z)},aCab, aItens , nOpc )

		if lMsErroAuto
			MostraErro()
			DisarmTransaction()
			lRetorno := .F.
		else
			aItens := {}
			aCab   := {}
			lRetorno := .T.
		EndIf

	End Transaction

Return lRetorno
