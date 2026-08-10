#Include "TOTVS.ch"
#Include "FwMVCDEF.ch"
#Include "TECA998.ch"

Static oFWSheet
Static oModel740

//------------------------------------------------------------------------------
/*/{Protheus.doc} TECA998
Planilha de cálculo no orçamento de serviços
@sample 	TECA998() 
@param		oModel -> Objeto do modelo
@since		22/10/2013       
@version	P11.9
/*/
//------------------------------------------------------------------------------
Function TECA998(oModel,oView)

Local aModPla   := {.F.,""}
Local aOpc      := {}//{STR0030,STR0003,STR0004,STR0035}// 1-"Visualizar (F7)"# 2-'Executar'# 3-'Novo Modelo'# 4-'Atualizar'
Local aTot      := {}
Local cFuncPosto:= ""
Local cDescFunc	:= ""
Local cManip    := ""
Local cModelo   := ""
Local cRet      := ""
Local lFacilit  := IsInCallStack("At984aPlPc")
Local lLocEq    := .F. 
Local lOk       := .T.
Local lOrcSrv   := At998Orc()
Local lPermLim  := At680Perm( Nil, __cUserID, "073" )
Local lRet      := .F.
Local nOpcao    := 1
Local nOpcOk    := 0
Local oBtn      := Nil
Local oDlg      := Nil
Local oMdlLE    := Nil
Local oMdlRh    := Nil  
Local oOpcao    := Nil
Default oView := Nil

If oModel:GetOperation() == MODEL_OPERATION_VIEW
	aOpc := {STR0030}
Else
	aOpc := {STR0030,STR0003,STR0004,STR0035}
EndIf  

If lFacilit
	oMdlRh	:= oModel:GetModel("TXSDETAIL")
Else
	oMdlRh := oModel:GetModel("TFF_RH")
	oMdlLE := oModel:GetModel("TFI_LE")
	If isInCallStack("At870GerOrc")
		If oMdlRh:GetValue("TFF_COBCTR") != "2"
			//Manipular Planilha de item cobrado dentro da rotina de Item Extra
			lOk := .F.
			Help(,, "AT998COBCTR1",,STR0016,1,0,,,,,,{STR0017}) //"Não é possível modificar itens que são cobrados no contrato através da rotina Item Extra" ## "Para alterar este item, realize uma Revisão do Contrato"
		EndIf
	Else
		If oMdlRh:GetValue("TFF_COBCTR") == "2"
			//Manipular Planilha de item não-cobrado fora da rotina de Item Extra
			lOk := .F.
			Help(,, "AT998COBCTR2",,STR0018,1,0,,,,,,{STR0019}) //"Não é possível modificar itens que não são cobrados no contrato nesta rotina" ## "Para alterar este item, acesse a opção Item Extra dentro da Gestão dos Contratos (TECA870)" 
		EndIf
	EndIf
Endif

If oMdlRh:IsDeleted()
	//Linha deletada não tem ação:
	lOk := .F.
	Help(,, "AT998DELET",,STR0038,1,0,,,,,,{STR0039}) //"Não é possível utilizar essa função com a linha deletada." ## "Para utilização, tire a deleção da linha." 
EndIf

If lOk

	If oView <> Nil .And. !lFacilit
		lLocEq := Upper(oView:GetFolderActive('ABAS', 2)[2]) == STR0014 // 'LOCAÇÃO DE EQUIPAMENTOS'
	EndIf
	
	If !lLocEq
		If lFacilit
			cManip := oMdlRh:GetValue("TXS_CALCMD")
			cRet := oMdlRh:GetValue("TXS_PLACOD") + oMdlRh:GetValue("TXS_PLAREV")
			cFuncPosto := oMdlRh:GetValue("TXS_FUNCAO")
		Else
			cManip := oMdlRh:GetValue("TFF_CALCMD")
			cRet := oMdlRh:GetValue("TFF_PLACOD") + oMdlRh:GetValue("TFF_PLAREV")
			cFuncPosto := oMdlRh:GetValue("TFF_FUNCAO")
		Endif
		cDescFunc := Posicione("SRJ",1,xFilial("SRJ")+cFuncPosto,"RJ_DESC") //RJ_FILIAL+RJ_FUNCAO
	Else	
		cManip		:= oMdlLE:GetValue("TFI_CALCMD")
		cRet 		:= oMdlLE:GetValue("TFI_PLACOD") + oMdlLE:GetValue("TFI_PLAREV")
	EndIf
	
	oModel740 := oModel

	If lPermLim .AND. oModel:GetOperation() <> MODEL_OPERATION_VIEW
		aadd( aOpc, STR0002) //5-'Manipular'
	EndIf
	

	DEFINE DIALOG oDlg TITLE STR0001 FROM 00,00 TO 160,135 PIXEL //"Planilha"
		oDlg:LEscClose	:= .F.
		oOpcao				:= TRadMenu():New(05,05,aOpc,,oDlg,,,,,,,,55,40,,,,.T.) // "Visualizar (F7)" # 'Manipular'#'Executar'#'Novo Modelo'
		oOpcao:bSetGet	:= {|x|IIf(PCount()==0,nOpcao,nOpcao:=x)}
		oBtn				:= TButton():New(60,05,STR0005,oDlg,{|| nOpcOk := 1, nOpcao, oDlg:End()},60,15,,,.F.,.T.,.F.,,.F.,,,.F. ) //'Confirmar'
	ACTIVATE DIALOG oDlg CENTERED
	
	If nOpcOk == 1
		If Empty(cManip) .OR. nOpcao == 3 .OR. nOpcao == 2 //Vazio/3=Novo Modelo/2-Executar
			If nOpcao == 1 .Or. nOpcao == 4 //1-Visualizar/4-Atualizar
				lOk := .F.
				If nOpcao == 1 //1-Visualizar
					Help(,, "TECA998A",,STR0031,1,0,,,,,,{STR0032}) //"Não é possível utilizar a visualização da planilha."#"Para poder visualizar uma planilha é necessário que o Posto tenha uma planilha de preços aplicada."
				Else //4-Atualizar
					Help(,, "TECA998A",,STR0036,1,0,,,,,,{STR0037}) //"Não é possível utilizar a atualização da planilha."#"Para poder atualizar uma planilha é necessário que o Posto tenha uma planilha de preços aplicada."
				EndIf
			Else
				If (lFacilit .And. nOpcao == 3) .Or. (nOpcao == 3 .And. lOrcSrv)//3=Novo Modelo
					aModPla	:= At998InPl()
				Else
					aModPla	:= At998ConsP(cRet)
				Endif
				lRet := aModPla[1]
				cRet := aModPla[2]
				If lRet
					DbSelectArea("ABW")
					DbSetOrder(1) // ABW_FILIAL+ABW_CODIGO+ABW_REVISA
					If ABW->(DbSeek(xFilial("ABW")+cRet))
						cModelo := ABW->ABW_INSTRU
						If nOpcao == 5 .OR. nOpcao == 3//3=Novo Modelo/5-Manipular
							FwMsgRun(Nil,{|| At998MdPla(cModelo,oModel,lLocEq, cRet)}, Nil, STR0020)//"Carregando..."
						Else
							//Executa a planilha se a planilha não tiver função ou a função da planilha for igual a função do posto:
							If Empty(ABW->ABW_FUNCAO) .Or. (ABW->ABW_FUNCAO == cFuncPosto) .Or. lLocEq
								FwMsgRun(Nil,{|| At998ExPla(cModelo,oModel,lLocEq, cRet)}, Nil, STR0020)//"Carregando..."
							Else
								lOk := .F.
								Help(,, "TECA998",,STR0033,1,0,,,,,,{STR0034+CRLF+cFuncPosto+" - "+cDescFunc})//"Não é possível a utilização dessa planilha. A função do Posto diverge da função da Planilha de Preços."#"Selecione uma planilha que não tenha uma função vinculada, ou que a função seja igual a função do posto posicionado: "
							EndIf
						EndIf	
					EndIf
				EndIf
			EndIf
		Else
			If nOpcao == 1 //Visualizar
				FwMsgRun(Nil,{|| TECA998A(oModel,oView)}, Nil, STR0020)//"Carregando..."
			ElseIf nOpcao == 4 //Atualizar
				ABW->( DbSetOrder(1) ) // ABW_FILIAL+ABW_CODIGO+ABW_REVISA
				ABW->( MsSeek( FwxFilial( "ABW" ) + cRet ) )
				FwMsgRun(Nil,{|| At998ExPla(cManip,oModel,lLocEq, cRet)}, Nil, STR0020)//"Carregando..."
			ElseIf nOpcao == 5 //Manipular
				FwMsgRun(Nil,{|| At998MdPla(cManip,oModel,lLocEq, cRet)}, Nil, STR0020)//"Carregando..."
			EndIf
		EndIf

		If lOk
			If oModel:GetModel( "TFJ_TOT" ) <> Nil .And. oModel:GetModel( "TFJ_TOT" ):HasField( "TFJ_TOTGER" ) .And. oModel:GetModel( "TFJ_TOT" ):HasField( "TFJ_TOTCUS" )
				aTot := A740TFJCus( oModel )
				oModel:GetModel( "TFJ_TOT" ):LoadValue( "TFJ_TOTGER", aTot[1] )
				oModel:GetModel( "TFJ_TOT" ):LoadValue( "TFJ_TOTCUS", aTot[2] )
			EndIf
		EndIf
	EndIf
EndIf

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} At998MdPla

Monta a Planilha de cálculo para manipulação. 

@sample 	At998MdPla() 

@param		cXml, Caracter, Conteúdo do XML
			oModel, Object, Classe do modelo de dados MpFormModel   
	
@since		22/10/2013       
@version	P11.9   
/*/
//------------------------------------------------------------------------------
Function At998MdPla(cXml,oModel,lLocEq,cCodRev)

Local oFWLayer 
Local oDlg
Local aSize	 		:= FWGetDialogSize( oMainWnd ) 	
Local oWinPlanilha
Local aCelulasBlock := At998Atrib()
Local cTpModelo		:= ABW->ABW_TPMODP
Local aNickBloq		:= {"TOTAL_RH","TOTAL_MAT_CONS","TOTAL_MAT_IMP","LUCRO", "TOTAL_ABATE_INS"}
Local oMdlRh		:= Nil 
Local oMdlVA        := Nil
Local nTotMI		:= 0 
Local nTotMC		:= 0
Local nTotUnif		:= 0
Local nTotArma		:= 0
Local bExpor		:= {|| TECA997(oFWSheet) }
Local lFacilit 		:= IsInCallStack("At984aPlPc")
Local lOrcSrv 		:= At998Orc()
Local nTotVer       := 0
Local nPercISS		:= 0
Local cDescPrd		:= Space(30)
Local cDescEsc 		:= Space(30)
Local cDescFunc 	:= Space(30)
Local oDscPrdRh		
Local oDscEscal
Local oDscFunc
Local oWinCampos	
Local cInsalub		:= "1"
Local cDscInsa		:= x3Combo("TFF_INSALU",cInsalub)
Local cGrauInsalub  := "1"
Local cDscGrau		:= x3Combo("TFF_GRAUIN",cGrauInsalub)
Local cPericulo		:= "1"
Local cDscPeric		:= x3Combo("TFF_PERICU",cPericulo)
Default cCodRev 	:= ""

If lFacilit
	oMdlRh	:= oModel:GetModel("TXSDETAIL")
	oMdlVA  := oModel:GetModel("TXXDETAIL")
	nTotMI	:= oMdlRh:GetValue("TXS_TOTMI")
	nTotMC	:= oMdlRh:GetValue("TXS_TOTMC")	
	nTotUnif:= oMdlRh:GetValue("TXS_TOTUNI")
	nTotArma:= oMdlRh:GetValue("TXS_TOTARM")
	nTotVer := At998Verba(oMdlVA) 
	cDescPrd := SubStr(oMdlRh:GetValue("TXS_DESCRI"),1,30)
	cDescEsc := SubStr(oMdlRh:GetValue("TXS_DSCESC"),1,30)
	cDescFunc := SubStr(oMdlRh:GetValue("TXS_DESFUN"),1,30)
	If TXS->( ColumnPos('TXS_INSALU') ) > 0
		cInsalub := oMdlRh:GetValue("TXS_INSALU")
		cDscInsa := x3Combo("TXS_INSALU",cInsalub)
	Endif
	If TXS->( ColumnPos('TXS_GRAUIN') ) > 0
		cGrauInsalub := oMdlRh:GetValue("TXS_GRAUIN")
		cDscGrau :=  x3Combo("TXS_GRAUIN",cGrauInsalub)
	Endif
	If TXS->( ColumnPos('TXS_PERICU') ) > 0
		cPericulo := oMdlRh:GetValue("TXS_PERICU")
		cDscPeric := x3Combo("TXS_PERICU",cPericulo)
	Endif
Else
	oMdlRh	:= oModel:GetModel("TFF_RH")
	nTotMI	:= oMdlRh:GetValue("TFF_TOTMI")
	nTotMC	:= oMdlRh:GetValue("TFF_TOTMC")
	oMdlBen := oModel:GetModel("ABP_BENEF")
	nTotVer := At998Verb(oMdlBen) 
	If lOrcSrv
		nTotUnif:= oMdlRh:GetValue("TFF_TOTUNI")
		nTotArma:= oMdlRh:GetValue("TFF_TOTARM")		
		nPercISS := At998GtISS(oModel:GetValue("TFL_LOC","TFL_LOCAL"),oModel:GetValue("TFF_RH","TFF_PRODUT"))
	Endif
	cDescPrd := SubStr(oMdlRh:GetValue("TFF_DESCRI"),1,30)
	cDescEsc := SubStr(oMdlRh:GetValue("TFF_NOMESC"),1,30)
	cDescFunc := SubStr(oMdlRh:GetValue("TFF_DFUNC"),1,30)
	If TFF->( ColumnPos('TFF_INSALU') ) > 0
		cInsalub := oMdlRh:GetValue("TFF_INSALU")
		cDscInsa := x3Combo("TFF_INSALU",cInsalub)
	Endif
	If TFF->( ColumnPos('TFF_GRAUIN') ) > 0
		cGrauInsalub := oMdlRh:GetValue("TFF_GRAUIN")
		cDscGrau :=  x3Combo("TFF_GRAUIN",cGrauInsalub)
	Endif
	If TFF->( ColumnPos('TFF_PERICU') ) > 0
		cPericulo := oMdlRh:GetValue("TFF_PERICU")
		cDscPeric := x3Combo("TFF_PERICU",cPericulo)
	Endif
Endif

DEFINE DIALOG oDlg TITLE STR0006 FROM aSize[1],aSize[2] TO aSize[3],aSize[4] PIXEL //"Planilha Preço"

	oFWLayer := FWLayer():New()
	oFWLayer:init( oDlg, .T. )
	oFWLayer:addLine( "Lin01", 15, .T. )	
	oFWLayer:addCollumn("Col01", 100, .T., "Lin01" )
	oFWLayer:addWindow("Col01", "Win01", STR0026, 100, .f., .f., {||  },"Lin01" ) //"Informações do Posto"

	oWinCampos := oFWLayer:getWinPanel("Col01", "Win01","Lin01" )

	@  4,0.01 SAY STR0027 Of oWinCampos PIXEL SIZE 45, 08 //"Descr. Prod RH:"
	@  1,40.01 GET oDscPrdRh VAR cDescPrd Picture PesqPict('TFF','TFF_DESCRI') WHEN .F. OF oWinCampos PIXEL

	@  4,225.01 SAY STR0028 Of oWinCampos PIXEL SIZE 45, 08 //"DesEscalacr. :"
	@  1,262.01 GET oDscEscal VAR cDescEsc Picture PesqPict('TFF','TFF_NOMESC') WHEN .F. OF oWinCampos PIXEL

	@  4,446.01 SAY STR0029 Of oWinCampos PIXEL SIZE 45, 08 //"Descr. Função:"
	@  1,479.01 GET oDscFunc VAR cDescFunc Picture PesqPict('TFF','TFF_DFUNC') WHEN .F. OF oWinCampos PIXEL

	oFWLayer:addLine( "Lin02", 85, .T. )
	oFWLayer:setLinSplit( "Lin02", CONTROL_ALIGN_BOTTOM, {|| } )
	oFWLayer:addCollumn("Col01", 100, .T., "Lin02" )
	oFWLayer:addWindow("Col01", "Win02", STR0001, 100,.F., .f., {|| Nil },"Lin02" ) //'Planilha'

	oWinPlanilha := oFWLayer:getWinPanel("Col01"	, "Win02" ,"Lin02")

//---------------------------------------
// PLANILHA
//---------------------------------------
oFWSheet := FWUIWorkSheet():New(oWinPlanilha)

IF At680Perm(NIL, __cUserId, "067", .T.)
	oFWSheet:AddItemMenu(STR0007,bExpor) //'Exportar para Excel'
Endif
oFwSheet:SetMenuVisible(.T.,STR0008,50) //"Ações"

If MethIsMemberOf(oFWSheet,"ShowAllErr")
	oFWSheet:ShowAllErr(.F.)
EndIf

If !Empty(cXml) 
	oFWSheet:LoadXmlModel(cXml)
EndIf
If lFacilit .Or. lOrcSrv
	If oFWSheet:CellExists("TOTAL_MI")
		oFWSheet:SetCellValue("TOTAL_MI", nTotMI)
	EndIf	
	If oFWSheet:CellExists("TOTAL_MC")
		oFWSheet:SetCellValue("TOTAL_MC", nTotMC)
	EndIf
	If oFWSheet:CellExists("TOTAL_UNIF")
		oFWSheet:SetCellValue("TOTAL_UNIF", nTotUnif)
	EndIf
	If oFWSheet:CellExists("TOTAL_ARMA")
		oFWSheet:SetCellValue("TOTAL_ARMA", nTotArma)
	EndIf
	If oFWSheet:CellExists("TOTAL_VERBAS")
		oFWSheet:SetCellValue("TOTAL_VERBAS", nTotVer)
	EndIf
	If nPercISS > 0 .And. oFWSheet:CellExists("IMPOSTO_ISS")
		oFWSheet:SetCellValue("IMPOSTO_ISS", nPercISS)
	Endif
	If oFWSheet:CellExists("PARAM_INSALUB")
		oFWSheet:SetCellValue("PARAM_INSALUB",cInsalub )
	Endif
	If oFWSheet:CellExists("DESC_INSALUB")
		oFWSheet:SetCellValue("DESC_INSALUB",cDscInsa )
	Endif
	If oFWSheet:CellExists("PARAM_GRAUINSALUB")
		oFWSheet:SetCellValue("PARAM_GRAUINSALUB", cGrauInsalub )
	Endif
	If oFWSheet:CellExists("DESC_GRAU")
		oFWSheet:SetCellValue("DESC_GRAU", cDscGrau )
	Endif
	If oFWSheet:CellExists("PARAM_PERICULOSO")
		oFWSheet:SetCellValue("PARAM_PERICULOSO",cPericulo )
	Endif
	If oFWSheet:CellExists("DESC_PERICU")
		oFWSheet:SetCellValue("DESC_PERICU",cDscPeric )
	Endif
Else
	If oFWSheet:CellExists("TOTAL_MAT_IMP")
		oFWSheet:SetCellValue("TOTAL_MAT_IMP", nTotMI)
	EndIf	
	If oFWSheet:CellExists("TOTAL_MAT_CONS")
		oFWSheet:SetCellValue("TOTAL_MAT_CONS", nTotMC)
	EndIf	
Endif

//.T. serão bloqueadas as celulas que NÃO estão no array passado aCells 
//.F. serão bloqueadas as celulas que estão no array passado aCells 
If cTpModelo == "1"
	oFWSheet:SetCellsBlock(aCelulasBlock, .T.) //'Lista Liberada'
Else
	oFWSheet:SetCellsBlock(aCelulasBlock, .F.) //'Lista bloqueada' 
EndIf

oFwSheet:SetNamesBlock(aNickBloq)

oFWSheet:Refresh(.T.)

ACTIVATE DIALOG oDlg ON INIT EnchoiceBar(oDlg,{||lOk:=At998Grv(oModel,lLocEq,cCodRev),oDlg:End()},{||oDlg:End()}) CENTERED

If !lFacilit
	TC740Mnt(oModel)
EndIf

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} At998Atrib

Atribui as células gravadas na lista do modelo da planilha 

@sample 	At998Atrib() 

@return	aCel-> Array, Contém células gravadas na lista. 

@since		22/10/2013       
@version	P11.9   
/*/
//------------------------------------------------------------------------------
Function At998Atrib()

Local aArea := GetArea()
Local aCell := {}

DbSelectArea("ABW")
DbSetOrder(1)

If ABW->(DbSeek(xFilial("ABW")+ABW->(ABW_CODIGO+ABW_REVISA)))
	aCell := StrTokArr(ABW->ABW_LISTA,";")
EndIf

RestArea(aArea)

Return aCell

//------------------------------------------------------------------------------
/*/{Protheus.doc} At998Grv

Gravação do xml e do cálculo na planilha do item selecionado.

@sample 	At998Grv() 

@param		oModel, Object, Classe do modelo de dados MpFormModel  
	
@since		22/10/2013       
@version	P11.9   
/*/
//------------------------------------------------------------------------------
Function At998Grv(oModel,lLocEq, cCodRev)

Local oMdlRh		:= Nil 
Local oMdlLE		:= Nil 
Local oMdlLEa		:= Nil 
Local cManip		:= ""
Local nTamCpoCod 	:= TamSX3("TFF_PLACOD")[1]
Local nTamCpoRev 	:= TamSX3("TFF_PLAREV")[1]
Local cTotAbINS		:= 0
Local lAbtInss		:= TFF->( ColumnPos('TFF_ABTINS') ) > 0 .AND. SuperGetMv("MV_GSDSGCN",,"2") == "1"
Local lPLucro		:= TFF->( ColumnPos('TFF_PLUCRO') ) > 0
Local lCpoCustom	:= ExistBlock('A998CPOUSR')
Local lFacilit  	:= IsInCallStack("At984aPlPc")
Local lGsVerb 		:= TableInDic("ABZ") //Verbas de Folha
Local nTotRh 		:= 0
Local nTotPlan		:= 0
Local nPLucro		:= 0
Local lOrcSrv		:= At998Orc()
Default lLocEq		:= .F.
Default cCodRev 	:= ""

Default lLocEq 		:= .F.

cManip := oFwSheet:GetXmlModel(,,,,.F.,.T.,.F.)

If lFacilit
	oMdlRh := oModel:GetModel("TXSDETAIL")
	If oFWSheet:CellExists("TOTAL_CUSTO")
		nTotRh := oFwSheet:GetCellValue("TOTAL_CUSTO")
	Endif
	If oFWSheet:CellExists("TOTAL_BRUTO")
		nTotPlan := oFwSheet:GetCellValue("TOTAL_BRUTO")
	Endif
Else
	oMdlRh := oModel:GetModel("TFF_RH")
	oMdlLE := oModel:GetModel("TFI_LE")
	oMdlLEa := oModel:GetModel("TEV_ADICIO")
	If lOrcSrv 
		If oFWSheet:CellExists("TOTAL_CUSTO")
			nTotRh := oFwSheet:GetCellValue("TOTAL_CUSTO")
		Endif
		If oFWSheet:CellExists("TOTAL_BRUTO")
			nTotPlan := oFwSheet:GetCellValue("TOTAL_BRUTO")
		Endif
	Else
		If oFWSheet:CellExists("TOTAL_RH")
			nTotRh := oFwSheet:GetCellValue("TOTAL_RH")	
		Endif
	Endif
	If lAbtInss .AND. oFWSheet:CellExists("TOTAL_ABATE_INS")
		cTotAbINS := oFwSheet:GetCellValue("TOTAL_ABATE_INS")
	EndIf
	If lPLucro .AND. oFWSheet:CellExists("TX_LR")
		nPLucro := oFwSheet:GetCellValue("TX_LR")
	EndIf
Endif

//Tratamento de Typemismatch Planilha / SetValue em campos numéricos
nTotRh   := at998Val(nTotRh)
nTotPlan := at998Val(nTotPlan)
nPLucro  := at998Val(nPLucro)

If !Empty(cManip) .AND. oMdlRh:GetOperation() <> MODEL_OPERATION_VIEW .And. !lLocEq
	If lFacilit
		oMdlRh:SetValue("TXS_CALCMD",cManip)
		oMdlRh:SetValue("TXS_VLUNIT",Round(nTotRh, TamSX3("TXS_VLUNIT")[2]))
		oMdlRh:SetValue("TXS_PLACOD", SubString(cCodRev,1,nTamCpoCod))
		oMdlRh:SetValue("TXS_PLAREV", SubString(cCodRev,nTamCpoCod+1,nTamCpoRev))	
		oMdlRh:SetValue("TXS_TOTPLA",Round(nTotPlan, TamSX3("TXS_TOTPLA")[2]))
	Else
		oMdlRh:SetValue("TFF_CALCMD",cManip)
		oMdlRh:SetValue("TFF_PRCVEN",ROUND(nTotRh, TamSX3("TFF_PRCVEN")[2]))
		oMdlRh:SetValue("TFF_PLACOD", SubString(cCodRev,1,nTamCpoCod))
		oMdlRh:SetValue("TFF_PLAREV", SubString(cCodRev,nTamCpoCod+1,nTamCpoRev))
		oMdlRh:SetValue("TFF_TOTPLA",Round(nTotPlan, TamSX3("TFF_TOTPLA")[2]))
		If lPLucro
			oMdlRh:LoadValue("TFF_PLUCRO",Round(nPLucro, TamSX3("TFF_PLUCRO")[2]))
		EndIf
	Endif
EndIf

If !lFacilit
	If !Empty(cManip) .AND. lAbtInss .And. cTotAbINS > 0
		oMdlRh:SetValue("TFF_ABTINS", cTotAbINS)
	EndIf

	If !Empty(cManip) .AND. oMdlLE:GetOperation() <> MODEL_OPERATION_VIEW .And. lLocEq .And. !Empty(oMdlLE:GetValue("TFI_PRODUT"))
		oMdlLE:SetValue("TFI_CALCMD",cManip)
		oMdlLE:SetValue("TFI_PLACOD", SubString(cCodRev,1,nTamCpoCod))
		oMdlLE:SetValue("TFI_PLAREV", SubString(cCodRev,nTamCpoCod+1,nTamCpoRev))
		If oFWSheet:CellExists("TOTAL_LE_COB")
			oMdlLEa:SetValue("TEV_MODCOB",if(valtype(oFwSheet:GetCellValue("TOTAL_LE_COB")) == 'N',AllTrim(str(oFwSheet:GetCellValue("TOTAL_LE_COB"))),oFwSheet:GetCellValue("TOTAL_LE_COB")))
		EndIf
		
		If oFWSheet:CellExists("TOTAL_LE_QUANT")
			oMdlLEa:SetValue("TEV_QTDE", if(valtype(oFwSheet:GetCellValue("TOTAL_LE_QUANT")) <> 'N', 0 ,oFwSheet:GetCellValue("TOTAL_LE_QUANT")))
		EndIf
		
		If oFWSheet:CellExists("TOTAL_LE_VUNIT")
			oMdlLEa:SetValue("TEV_VLRUNI", if(valtype(oFwSheet:GetCellValue("TOTAL_LE_VUNIT")) <> 'N', 0 ,oFwSheet:GetCellValue("TOTAL_LE_VUNIT")))
		EndIf
	EndIf
Endif

If lCpoCustom
	ExecBlock('A998CPOUSR', .F., .F., {oMdlRh,oFwSheet} )
EndIf

If lGsVerb .And. !lFacilit
	If !Empty(cManip)
		at740VbRun(.T., "", "", oMdlRh:GetValue("TFF_PLACOD"), oMdlRh:GetValue("TFF_PLAREV"), oFwSheet)
	EndIf
EndIf

Return .T.

//------------------------------------------------------------------------------
/*/{Protheus.doc} At998ExPla

Executa o cálculo do modelo da planilha sem visualizar a mesma. 

@sample 	At998ExPla() 

@param		cXml, Caracter, Conteúdo do XML
			oModel, Object, Classe do modelo de dados MpFormModel  
	
@since		22/10/2013       
@version	P11.9   
/*/
//------------------------------------------------------------------------------
Function At998ExPla(cXml, oModel, lLocEq, cCodRev, lReplica)
Local oMdlLA		:= Nil
Local oMdlRh		:= Nil
Local oMdlVA		:= Nil
Local oMdlLE		:= Nil
Local oMdlLEa		:= Nil
Local oMdlTWO		:= Nil
Local oMdlBen		:= Nil
Local nTotMI		:= 0 
Local nTotMC		:= 0
Local nTotUnif		:= 0
Local nTotArma		:= 0
Local nTotal		:= 0
Local nX			:= 0
Local nY			:= 0
Local nTamCpoCod	:= TamSX3("TFF_PLACOD")[1]
Local nTamCpoRev	:= TamSX3("TFF_PLAREV")[1]
Local cTotAbINS 	:= 0
Local lAbtInss		:= TFF->( ColumnPos('TFF_ABTINS') ) > 0 .AND. SuperGetMv("MV_GSDSGCN",,"2") == "1"
Local lPLucro		:= TFF->( ColumnPos('TFF_PLUCRO') ) > 0
Local lCpoCustom	:= ExistBlock('A998CPOUSR')
Local lFacilit   	:= IsInCallStack("At984aPlPc")
Local lFeriad		:= .F.
Local nTotPlan		:= 0
Local lOrcSrv		:= At998Orc()
Local nTotVer       := 0
Local nPercISS		:= 0
Local nAjustEsc		:= ((((365*4)+1)/4)/12)/30
Local nHrsTot		:= 0
Local nTotFer		:= 0
Local nHrDia		:= 0
Local nHrsNot		:= 0
Local nQtdAlo		:= 0
Local nQtdIntra		:= 0
Local nPLucro		:= 0
Local nHoraSem		:= 0
Local nQuantDias	:= 0
Local cQuantHrs		:= ""
Local cInsalub		:= "1"
Local cDscInsa		:= x3Combo("TFF_INSALU",cInsalub)
Local cGrauInsalub  := "1"
Local cDscGrau		:= x3Combo("TFF_GRAUIN",cGrauInsalub)
Local cPericulo		:= "1"
Local cFuncao		:= ""
Local cDescPeriod	:= ""
Local cDscPeric		:= x3Combo("TFF_PERICU",cPericulo)
Local lGsVerb 		:= TableInDic("ABZ") //Verbas de Folha
Local nPlrCCT		:= 0
Local nSalario		:= 0
Local cCodCCT		:= ""
Local nQtdVen 		:= 0

Default lLocEq		:= .F.
Default cCodRev 	:= ""
Default lReplica 	:= .F.

oFWSheet := FWUIWorkSheet():New(,.F. ) //instancia a planilha sem exibição

If MethIsMemberOf(oFWSheet,"ShowAllErr")
	oFWSheet:ShowAllErr(.F.)
EndIf

oFwSheet:LoadXmlModel(cXml)

If lFacilit 
	oMdlRh := oModel:GetModel("TXSDETAIL")
	oMdlVA := oModel:GetModel("TXXDETAIL")
	nTotMI := oMdlRh:GetValue("TXS_TOTMI")
	nTotMC := oMdlRh:GetValue("TXS_TOTMC")
	nTotUnif:= oMdlRh:GetValue("TXS_TOTUNI")
	nTotArma:= oMdlRh:GetValue("TXS_TOTARM")
	nTotVer := At998Verba(oMdlVA) 
	nQtdVen := oMdlRh:GetValue("TXS_QUANTS")

	If TXS->( ColumnPos('TXS_INSALU') ) > 0
		cInsalub := oMdlRh:GetValue("TXS_INSALU")
		cDscInsa := x3Combo("TXS_INSALU",cInsalub)
	Endif
	If TXS->( ColumnPos('TXS_GRAUIN') ) > 0
		cGrauInsalub := oMdlRh:GetValue("TXS_GRAUIN")
		cDscGrau :=  x3Combo("TXS_GRAUIN",cGrauInsalub)
	Endif
	If TXS->( ColumnPos('TXS_PERICU') ) > 0
		cPericulo := oMdlRh:GetValue("TXS_PERICU")
		cDscPeric := x3Combo("TXS_PERICU",cPericulo)
	Endif
	If oFWSheet:CellExists("TOTAL_MI")
		oFWSheet:SetCellValue("TOTAL_MI", nTotMI)
	EndIf	
	If oFWSheet:CellExists("TOTAL_MC")
		oFWSheet:SetCellValue("TOTAL_MC", nTotMC)
	EndIf
	If oFWSheet:CellExists("TOTAL_UNIF")
		oFWSheet:SetCellValue("TOTAL_UNIF", nTotUnif)
	EndIf
	If oFWSheet:CellExists("TOTAL_ARMA")
		oFWSheet:SetCellValue("TOTAL_ARMA", nTotArma)
	EndIf
	If oFWSheet:CellExists("TOTAL_VERBAS")
		oFWSheet:SetCellValue("TOTAL_VERBAS", nTotVer)
	EndIf
	If oFWSheet:CellExists("AJUSTE_ESCALA") .And. Alltrim(oFWSheet:oFWFormula:GetCell("AJUSTE_ESCALA"):Formula) == "=0"
		oFWSheet:SetCellValue("AJUSTE_ESCALA", nAjustEsc )
	EndIf
	nDiasTrb := At998DTrb(oMdlRh:GetValue("TXS_ESCALA"),oMdlRh:GetValue("TXS_TURNO"),@nHrsTot,@nHrDia,@nHoraSem)
	If oFWSheet:CellExists("MES_COMERCIAL") .And. oFWSheet:CellExists("AJUSTE_ESCALA") .And. Alltrim(oFWSheet:oFWFormula:GetCell("MES_COMERCIAL"):Formula) == "=0"
		oFWSheet:SetCellValue("MES_COMERCIAL","="+cValTochar(nDiasTrb)+"*G6" )
	EndIf
	If oFWSheet:CellExists("JORNADA_CALCULO") .And. Alltrim(oFWSheet:oFWFormula:GetCell("JORNADA_CALCULO"):Formula) == "=0"
		oFWSheet:SetCellValue("JORNADA_CALCULO","="+"G7"+"-G5")
	Endif

	If oFWSheet:CellExists("HORAS_SEMANA") .And. Alltrim(oFWSheet:oFWFormula:GetCell("HORAS_SEMANA"):Formula) == "=0"
		oFWSheet:SetCellValue("HORAS_SEMANA",nHoraSem)
	Endif
	
	nHrsInt := At998TotInt(oMdlRh:GetValue("TXS_ESCALA"),oMdlRh:GetValue("TXS_TURNO"))
	If oFWSheet:CellExists("INTERVALO") .And. Alltrim(oFWSheet:oFWFormula:GetCell("INTERVALO"):Formula) == "=0"
		oFWSheet:SetCellValue("INTERVALO",nHrsInt)
	Endif
	If oFWSheet:CellExists("JORNADA_COMERCIAL") .And. Alltrim(oFWSheet:oFWFormula:GetCell("JORNADA_COMERCIAL"):Formula) == "=0"
		oFWSheet:SetCellValue("JORNADA_COMERCIAL",nHrDia)
	Endif
	If oFWSheet:CellExists("TOTAL_HORAS") .And. Alltrim(oFWSheet:oFWFormula:GetCell("TOTAL_HORAS"):Formula) == "=0"
		oFWSheet:SetCellValue("TOTAL_HORAS",nHrsTot)
	EndIf
	If oFWSheet:CellExists("HORA_EXTRA") .And. Alltrim(oFWSheet:oFWFormula:GetCell("HORA_EXTRA"):Formula) == "=0"
		oFWSheet:SetCellValue("HORA_EXTRA","="+"(G7*G2)-G8" )
	EndIf
	If oFWSheet:CellExists("VALOR_HORA") .And. Alltrim(oFWSheet:oFWFormula:GetCell("VALOR_HORA"):Formula) == "=0"
		oFWSheet:SetCellValue("VALOR_HORA","="+"D2/G8" )
	EndIf
	If oFWSheet:CellExists("VALOR_EXTRA") .And. Alltrim(oFWSheet:oFWFormula:GetCell("VALOR_EXTRA"):Formula) == "=0"
		oFWSheet:SetCellValue("VALOR_EXTRA","="+"G10*(CALC_HORA_EXTRA/100)")
	EndIf
	If oFWSheet:CellExists("VALOR_EXTRA_FERIADO") .And. Alltrim(oFWSheet:oFWFormula:GetCell("VALOR_EXTRA_FERIADO"):Formula) == "=0"
		oFWSheet:SetCellValue("VALOR_EXTRA_FERIADO","="+"G10*(CALC_HORA_EXTRAFER/100)")
	EndIf
	nHrsNot := At998HrNt(oMdlRh:GetValue("TXS_ESCALA"),oMdlRh:GetValue("TXS_TURNO"), @cDescPeriod, @lFeriad)
	If oFWSheet:CellExists("PER_ESCALA") .AND. !Empty(cDescPeriod) .AND. Alltrim(oFWSheet:oFWFormula:GetCell("PER_ESCALA"):Formula) == "=0"
		oFWSheet:SetCellValue("PER_ESCALA",IIF(cDescPeriod == "D", 1 , 2) )
	Endif
	If oFWSheet:CellExists("ESC_FER") .AND. Alltrim(oFWSheet:oFWFormula:GetCell("ESC_FER"):Formula) == "=0"
		oFWSheet:SetCellValue("ESC_FER",IIF(lFeriad, 1 , 2) )
	Endif
	If oFWSheet:CellExists("HORAS_NOTURNAS") .And. Alltrim(oFWSheet:oFWFormula:GetCell("HORAS_NOTURNAS"):Formula) == "=0"
		oFWSheet:SetCellValue("HORAS_NOTURNAS",nHrsNot)
	Endif
	If oFWSheet:CellExists("PARAM_INSALUB")
		oFWSheet:SetCellValue("PARAM_INSALUB",cInsalub )
	Endif
	If oFWSheet:CellExists("DESC_INSALUB")
		oFWSheet:SetCellValue("DESC_INSALUB",cDscInsa )
	Endif
	If oFWSheet:CellExists("PARAM_GRAUINSALUB")
		oFWSheet:SetCellValue("PARAM_GRAUINSALUB", cGrauInsalub )
	Endif
	If oFWSheet:CellExists("DESC_GRAU")
		oFWSheet:SetCellValue("DESC_GRAU", cDscGrau )
	Endif
	If oFWSheet:CellExists("PARAM_PERICULOSO")
		oFWSheet:SetCellValue("PARAM_PERICULOSO",cPericulo )
	Endif
	If oFWSheet:CellExists("DESC_PERICU")
		oFWSheet:SetCellValue("DESC_PERICU",cDscPeric )
	Endif
	If oFWSheet:CellExists("NUMERO_PESSOAS") .And. Alltrim(oFWSheet:oFWFormula:GetCell("NUMERO_PESSOAS"):Formula) == "=0"
		If FindFunction("At740QtdAloc")
			nQtdAlo := At740QtdAloc(oMdlRh:GetValue("TXS_ESCALA"))
			oFWSheet:SetCellValue("NUMERO_PESSOAS",nQtdAlo)
		EndIf
	EndIf
	If oFWSheet:CellExists("PLR_CCT")
		nPlrCCT := At998PsqCCT(cCodRev)
		If nPlrCCT > 0
			oFWSheet:SetCellValue("PLR_CCT",nPlrCCT)
		EndIf
	EndIf
	If oFWSheet:CellExists("QTD_INTRA") .And. Alltrim(oFWSheet:oFWFormula:GetCell("QTD_INTRA"):Formula) == "=0"
		nQtdIntra := At998QtdIntra(oMdlRh:GetValue("TXS_ESCALA"))
		oFWSheet:SetCellValue("QTD_INTRA",nQtdIntra)
	EndIf
	//Atualização do total de INSUMOS (MI,MC,UNI,ARM) e FÓRMULA de acordo com a quantidade vendida na TFF:
	If oFWSheet:CellExists("TOTAL_INSUMOS") .And. (nQtdVen > 0)
		If oFWSheet:GetCellValue("TOTAL_INSUMOS") > 0
			updInsumos(nQtdVen)
		EndIf
	Endif
Else
	oMdlLA := oModel:GetModel("TFL_LOC")
	oMdlRh := oModel:GetModel("TFF_RH")
	oMdlLE := oModel:GetModel("TFI_LE")
	oMdlLEa := oModel:GetModel("TEV_ADICIO")
	oMdlTWO := oModel:GetModel("TWODETAIL")
	oMdlBen := oModel:GetModel("ABP_BENEF")
	nTotVer := At998Verb(oMdlBen) 
	nTotMI := oMdlRh:GetValue("TFF_TOTMI")
	nTotMC := oMdlRh:GetValue("TFF_TOTMC")
	nQtdVen := oMdlRh:GetValue("TFF_QTDVEN")
	nPercISS := At998GtISS(oModel:GetValue("TFL_LOC","TFL_LOCAL"),oModel:GetValue("TFF_RH","TFF_PRODUT"))
	
	If TFF->( ColumnPos('TFF_INSALU') ) > 0
		cInsalub := oMdlRh:GetValue("TFF_INSALU")
		cDscInsa := x3Combo("TFF_INSALU",cInsalub)
	Endif
	If TFF->( ColumnPos('TFF_GRAUIN') ) > 0
		cGrauInsalub := oMdlRh:GetValue("TFF_GRAUIN")
		cDscGrau :=  x3Combo("TFF_GRAUIN",cGrauInsalub)
	Endif
	If TFF->( ColumnPos('TFF_PERICU') ) > 0
		cPericulo := oMdlRh:GetValue("TFF_PERICU")
		cDscPeric := x3Combo("TFF_PERICU",cPericulo)
	Endif
	If lOrcSrv
		If oFWSheet:CellExists("TOTAL_MI")
			oFWSheet:SetCellValue("TOTAL_MI", nTotMI)
		EndIf	
		If oFWSheet:CellExists("TOTAL_MC")
			oFWSheet:SetCellValue("TOTAL_MC", nTotMC)
		EndIf
		If oFWSheet:CellExists("TOTAL_UNIF")
			oFWSheet:SetCellValue("TOTAL_UNIF", oMdlRh:GetValue("TFF_TOTUNI"))
		EndIf
		If oFWSheet:CellExists("TOTAL_ARMA")
			oFWSheet:SetCellValue("TOTAL_ARMA", oMdlRh:GetValue("TFF_TOTARM"))
		EndIf
		If oFWSheet:CellExists("TOTAL_VERBAS")
			oFWSheet:SetCellValue("TOTAL_VERBAS", nTotVer)
		EndIf
		If nPercISS > 0 .And. oFWSheet:CellExists("IMPOSTO_ISS")
			oFWSheet:SetCellValue("IMPOSTO_ISS", nPercISS)
		Endif
		If oFWSheet:CellExists("AJUSTE_ESCALA") .And. Alltrim(oFWSheet:oFWFormula:GetCell("AJUSTE_ESCALA"):Formula) == "=0"
			oFWSheet:SetCellValue("AJUSTE_ESCALA", nAjustEsc)
		EndIf
		nDiasTrb := At998DTrb(oMdlRh:GetValue("TFF_ESCALA"),oMdlRh:GetValue("TFF_TURNO"),@nHrsTot,@nHrDia,@nHoraSem)
		If oFWSheet:CellExists("MES_COMERCIAL") .And. Alltrim(oFWSheet:oFWFormula:GetCell("MES_COMERCIAL"):Formula) == "=0"
			oFWSheet:SetCellValue("MES_COMERCIAL","="+cValTochar(nDiasTrb)+"*G6")
		EndIf
		If oFWSheet:CellExists("JORNADA_CALCULO") .And. Alltrim(oFWSheet:oFWFormula:GetCell("JORNADA_CALCULO"):Formula) == "=0"
			oFWSheet:SetCellValue("JORNADA_CALCULO","="+"G7"+"-G5")
		Endif

		If oFWSheet:CellExists("HORAS_SEMANA") .And. Alltrim(oFWSheet:oFWFormula:GetCell("HORAS_SEMANA"):Formula) == "=0"
			oFWSheet:SetCellValue("HORAS_SEMANA",nHoraSem)
		Endif
		
		nTotFer := At998TotFer(oMdlRh:GetValue("TFF_CALEND"))
		If oFWSheet:CellExists("FERIADO") .And. Alltrim(oFWSheet:oFWFormula:GetCell("FERIADO"):Formula) == "=0"
			oFWSheet:SetCellValue("FERIADO","="+Iif(nTotFer <> 1 ,cValToChar(nTotFer)+"/12",cValToChar(nTotFer)))
		Endif
		nHrsInt := At998TotInt(oMdlRh:GetValue("TFF_ESCALA"),oMdlRh:GetValue("TFF_TURNO"))
		If oFWSheet:CellExists("INTERVALO") .And. Alltrim(oFWSheet:oFWFormula:GetCell("INTERVALO"):Formula) == "=0"
			oFWSheet:SetCellValue("INTERVALO",nHrsInt)
		Endif
		If oFWSheet:CellExists("JORNADA_COMERCIAL") .And. Alltrim(oFWSheet:oFWFormula:GetCell("JORNADA_COMERCIAL"):Formula) == "=0"
			oFWSheet:SetCellValue("JORNADA_COMERCIAL",nHrDia)
		Endif
		If oFWSheet:CellExists("TOTAL_HORAS") .And. Alltrim(oFWSheet:oFWFormula:GetCell("TOTAL_HORAS"):Formula) == "=0"
			oFWSheet:SetCellValue("TOTAL_HORAS",nHrsTot)
		EndIf
		If oFWSheet:CellExists("HORA_EXTRA") .And. Alltrim(oFWSheet:oFWFormula:GetCell("HORA_EXTRA"):Formula) == "=0"
			oFWSheet:SetCellValue("HORA_EXTRA","="+"(G7*G2)-G8")
		EndIf
		If oFWSheet:CellExists("VALOR_HORA") .And. Alltrim(oFWSheet:oFWFormula:GetCell("VALOR_HORA"):Formula) == "=0"
			oFWSheet:SetCellValue("VALOR_HORA","="+"D2/G8")
		EndIf
		If oFWSheet:CellExists("VALOR_EXTRA") .And. Alltrim(oFWSheet:oFWFormula:GetCell("VALOR_EXTRA"):Formula) == "=0"
			oFWSheet:SetCellValue("VALOR_EXTRA","="+"G10*(CALC_HORA_EXTRA/100)")
		EndIf
		If oFWSheet:CellExists("VALOR_EXTRA_FERIADO") .And. Alltrim(oFWSheet:oFWFormula:GetCell("VALOR_EXTRA_FERIADO"):Formula) == "=0"
			oFWSheet:SetCellValue("VALOR_EXTRA_FERIADO","="+"G10*(CALC_HORA_EXTRAFER/100)")
		EndIf

		nHrsNot := At998HrNt(oMdlRh:GetValue("TFF_ESCALA"),oMdlRh:GetValue("TFF_TURNO"), @cDescPeriod,@lFeriad)
		If oFWSheet:CellExists("PER_ESCALA") .AND. !Empty(cDescPeriod) .AND. Alltrim(oFWSheet:oFWFormula:GetCell("PER_ESCALA"):Formula) == "=0"
			oFWSheet:SetCellValue("PER_ESCALA",IIF(cDescPeriod == "D", 1 , 2) )
		Endif
		If oFWSheet:CellExists("ESC_FER") .AND. Alltrim(oFWSheet:oFWFormula:GetCell("ESC_FER"):Formula) == "=0"
			oFWSheet:SetCellValue("ESC_FER",IIF(lFeriad, 1 , 2) )
		Endif
		If oFWSheet:CellExists("HORAS_NOTURNAS") .And. Alltrim(oFWSheet:oFWFormula:GetCell("HORAS_NOTURNAS"):Formula) == "=0"
			oFWSheet:SetCellValue("HORAS_NOTURNAS",nHrsNot)
		Endif
		If oFWSheet:CellExists("PARAM_INSALUB")
			oFWSheet:SetCellValue("PARAM_INSALUB",cInsalub)
		Endif
		If oFWSheet:CellExists("DESC_INSALUB")
			oFWSheet:SetCellValue("DESC_INSALUB",cDscInsa)
		Endif
		If oFWSheet:CellExists("PARAM_GRAUINSALUB")
			oFWSheet:SetCellValue("PARAM_GRAUINSALUB", cGrauInsalub)
		Endif
		If oFWSheet:CellExists("DESC_GRAU")
			oFWSheet:SetCellValue("DESC_GRAU", cDscGrau)
		Endif
		If oFWSheet:CellExists("PARAM_PERICULOSO")
			oFWSheet:SetCellValue("PARAM_PERICULOSO",cPericulo)
		Endif
		If oFWSheet:CellExists("DESC_PERICU")
			oFWSheet:SetCellValue("DESC_PERICU",cDscPeric)
		Endif
		If oFWSheet:CellExists("NUM_TOT_PESSOA")
			oFWSheet:SetCellValue("NUM_TOT_PESSOA",oMdlRh:GetValue("TFF_QTPREV"))
		Endif
		If oFWSheet:CellExists("METRAGEM_LOCAL")
			oFWSheet:SetCellValue("METRAGEM_LOCAL",oMdlLA:GetValue("TFL_METRO"))
		Endif
		If oFWSheet:CellExists("PRODUTIVIDADE_RH")
			oFWSheet:SetCellValue("PRODUTIVIDADE_RH",oMdlRh:GetValue("TFF_AREAPR"))
		Endif
		If oFWSheet:CellExists("METRAGEM_ATENDI")
			oFWSheet:SetCellValue("METRAGEM_ATENDI",oMdlRh:GetValue("TFF_METRAT"))
		Endif
		If oFWSheet:CellExists("NUMERO_PESSOAS") .And. Alltrim(oFWSheet:oFWFormula:GetCell("NUMERO_PESSOAS"):Formula) == "=0"
			If FindFunction("At740QtdAloc")
				nQtdAlo := At740QtdAloc(oMdlRh:GetValue("TFF_ESCALA"))
				oFWSheet:SetCellValue("NUMERO_PESSOAS",nQtdAlo)
			EndIf
		EndIf
		If oFWSheet:CellExists("PLR_CCT")
			nPlrCCT := At998PsqCCT(cCodRev)
			If nPlrCCT > 0
				oFWSheet:SetCellValue("PLR_CCT",nPlrCCT)
			EndIf
		EndIf
		If oFWSheet:CellExists("QTD_INTRA") .And. Alltrim(oFWSheet:oFWFormula:GetCell("QTD_INTRA"):Formula) == "=0"
			nQtdIntra := At998QtdIntra(oMdlRh:GetValue("TFF_ESCALA"))
			oFWSheet:SetCellValue("QTD_INTRA",nQtdIntra)
		EndIf
		If oFWSheet:CellExists("QTD_HORAS")
			cQuantHrs := oMdlRh:GetValue("TFF_QTDHRS") 
			If !Empty(cQuantHrs)
				oFWSheet:SetCellValue("QTD_HORAS", cQuantHrs)
			EndIf
		Endif

		If oFWSheet:CellExists("DIAS_PER")
			nQuantDias := (oMdlRh:GetValue("TFF_PERFIM") - oMdlRh:GetValue("TFF_PERINI")) + 1
			If nQuantDias > 0
				oFWSheet:SetCellValue("DIAS_PER", nQuantDias)
			EndIf
		Endif

		//Atualização do total de INSUMOS (MI,MC,UNI,ARM) e FÓRMULA de acordo com a quantidade vendida na TFF:
		If oFWSheet:CellExists("TOTAL_INSUMOS") .And. (nQtdVen > 0)
			If oFWSheet:GetCellValue("TOTAL_INSUMOS") > 0
				updInsumos(nQtdVen)
			EndIf
		Endif

	Else
		If oFWSheet:CellExists("TOTAL_MAT_IMP")
			oFWSheet:SetCellValue("TOTAL_MAT_IMP", nTotMI)
		EndIf
		If oFWSheet:CellExists("TOTAL_MAT_CONS")
			oFWSheet:SetCellValue("TOTAL_MAT_CONS", nTotMC)
		EndIf
		If oFWSheet:CellExists("TOTAL_VERBAS")
			oFWSheet:SetCellValue("TOTAL_VERBAS", nTotVer)
		EndIf
		If lAbtInss .AND. oFWSheet:CellExists("TOTAL_ABATE_INS")
			cTotAbINS := oFwSheet:GetCellValue("TOTAL_ABATE_INS")
		EndIf
	Endif
	If lPLucro .AND. oFWSheet:CellExists("TX_LR")
		nPLucro := oFwSheet:GetCellValue("TX_LR")
	EndIf
Endif

If Empty(Alltrim(ABW->ABW_FUNCAO))
	DbSelectArea("SRJ")
	SRJ->(DbSetOrder(1))
	If lFacilit
		cFuncao := oMdlRh:GetValue("TXS_FUNCAO")
	Else
		cFuncao := oMdlRh:GetValue("TFF_FUNCAO")
	EndIf

	If RI4->( ColumnPos('RI4_SALARI') ) > 0 .And. !Empty(cFuncao)
		//Verifica se tem Função e Salario na CCT cadastrado:
		cConfCal := ABW->ABW_CODTCW
		cCodCCT := Posicione("TCW",1,xFilial("TCW")+cConfCal,"TCW_CODCCT") //Indice 1 = TCW_FILIAL+TCW_CODIGO
		If !Empty(cCodCCT)
			nSalario := at998SalCCT(cCodCCT, cFuncao)
		EndIf
	EndIf

	//Caso haja salario na função da CCT maior que 0:
	If nSalario > 0
		If oFWSheet:CellExists("VLR_SB")
			oFWSheet:SetCellValue("VLR_SB", nSalario)
		EndIF
	//Senão pega do cadastro de Funções SRJ:
	ElseIf SRJ->(DbSeek(xFilial("SRJ")+cFuncao))
		If oFWSheet:CellExists("VLR_SB")
			oFWSheet:SetCellValue("VLR_SB", SRJ->RJ_SALARIO)
		EndIF
	EndIf
EndIF

If lFacilit .Or. lOrcSrv
	//Força o Refresh com LoadXMLModel
	cXml := oFwSheet:GetXmlModel(,,,,.F.,.T.,.F.)
	If isInCallStack("At740PlLot") .Or. IsBlind()
		oFWSheet:LoadXmlModel(cXml)
	Else
		FwMsgRun(Nil,{|| oFWSheet:LoadXmlModel(cXml)}, Nil, "Atualizando valores...")//"Carregando..."
	EndIf

	If oFWSheet:CellExists("TOTAL_CUSTO")
		nTotal := oFwSheet:GetCellValue("TOTAL_CUSTO")
	Endif
	If oFWSheet:CellExists("TOTAL_BRUTO")
		nTotPlan := oFwSheet:GetCellValue("TOTAL_BRUTO")
	Endif
Else
	If oFWSheet:CellExists("TOTAL_RH")
		nTotal := oFwSheet:GetCellValue("TOTAL_RH")
	Endif
Endif

If oMdlRh:GetOperation() <> MODEL_OPERATION_VIEW
	cXml := oFwSheet:GetXmlModel(,,,,.F.,.T.,.F.)
	//Executar Planilha para item de RH
	If !( lLocEq )
		//Verifica se tem um facilitador vinculado
		If !lFacilit .And. !lReplica .AND. !( Empty(oMdlRh:GetValue('TFF_CHVTWO')) ) .And. oMdlLA:Length(.T.) > 1 .And. MsgYesNo(STR0015) // "Replicar a execução da Planilha para todos locais de atendimento que utilizam este mesmo facilitador? "
			For nX := 1 To oMdlLA:Length()
				oMdlLA:GoLine(nX)
				For nY := 1 To oMdlRh:Length()
					oMdlRh:GoLine(nY)
					If !( Empty(oMdlRh:GetValue('TFF_CHVTWO')) ) .And. SubStr(oMdlRh:GetValue('TFF_CHVTWO'),1,15) == oMdlTWO:GetValue('TWO_CODFAC')
						oMdlRh:SetValue("TFF_PRCVEN",ROUND(nTotal, TamSX3("TFF_PRCVEN")[2]))
						oMdlRh:SetValue("TFF_CALCMD",cXml)
						oMdlRh:SetValue("TFF_PLACOD", SubString(cCodRev,1,nTamCpoCod))
						oMdlRh:SetValue("TFF_PLAREV", SubString(cCodRev,nTamCpoCod+1,nTamCpoRev))
						If lAbtInss .And. cTotAbINS > 0
							oMdlRh:SetValue("TFF_ABTINS",cTotAbINS)
						EndIf
						If lPLucro
							oMdlRh:LoadValue("TFF_PLUCRO",Round(nPLucro, TamSX3("TFF_PLUCRO")[2]))
						EndIf
					EndIf
				Next nY
			Next nX
		Else			
			If lFacilit
				oMdlRh:SetValue("TXS_VLUNIT", ROUND(nTotal, TamSX3("TXS_VLUNIT")[2]))
				oMdlRh:SetValue("TXS_CALCMD", cXml)
				oMdlRh:SetValue("TXS_PLACOD", SubString(cCodRev,1,nTamCpoCod))
				oMdlRh:SetValue("TXS_PLAREV", SubString(cCodRev,nTamCpoCod+1,nTamCpoRev))
				oMdlRh:SetValue("TXS_TOTPLA", ROUND(nTotPlan, TamSX3("TXS_TOTPLA")[2]))
			Else
				oMdlRh:SetValue("TFF_PRCVEN", ROUND(nTotal, TamSX3("TFF_PRCVEN")[2]))
				oMdlRh:SetValue("TFF_CALCMD", cXml)
				/* Necessário pois no gatilho do campo existe a Função FwFldGet  - INÍCIO */
				oMdlRh:LoadValue("TFF_PLACOD", SubString(cCodRev,1,nTamCpoCod))
				oMdlRh:LoadValue("TFF_PLAREV", SubString(cCodRev,nTamCpoCod+1,nTamCpoRev))
				/* Necessário pois no gatilho do campo existe a Função FwFldGet  - FIM */
				oMdlRh:SetValue("TFF_PLACOD", SubString(cCodRev,1,nTamCpoCod))
				oMdlRh:SetValue("TFF_PLAREV", SubString(cCodRev,nTamCpoCod+1,nTamCpoRev))
				If TFF->( ColumnPos('TFF_TOTPLA') ) > 0
					oMdlRh:SetValue("TFF_TOTPLA", ROUND(nTotPlan, TamSX3("TFF_TOTPLA")[2]))
				Endif
				If lAbtInss .And. cTotAbINS > 0
					oMdlRh:SetValue("TFF_ABTINS",cTotAbINS)
				EndIf
				If lPLucro
					oMdlRh:LoadValue("TFF_PLUCRO",Round(at998Val(nPLucro), TamSX3("TFF_PLUCRO")[2]))
				EndIf
			Endif
			If lCpoCustom
				ExecBlock('A998CPOUSR', .F., .F., {oMdlRh,oFwSheet} )
			EndIf
		EndIf
	//Executar Planilha para item de Locação de Equipamento
	ElseIf !( Empty(oMdlLE:GetValue("TFI_PRODUT")) )
		//Verifica se tem um facilitador vinculado
		If !( Empty(oMdlLE:GetValue('TFI_CHVTWO')) ) .AND. oMdlLA:Length(.T.) > 1 .AND. MsgYesNo(STR0015) // "Replicar a execução da Planilha para todos locais de atendimento que utilizam este mesmo facilitador? "
			For nX := 1 To oMdlLA:Length()
				oMdlLA:GoLine(nX)
				For nY := 1 To oMdlLE:Length()
					oMdlLE:GoLine(nY)
					If  !( Empty(oMdlLE:GetValue('TFI_CHVTWO')) ) .And. SubStr(oMdlLE:GetValue('TFI_CHVTWO'),1,15) == oMdlTWO:GetValue('TWO_CODFAC')
						oMdlLE:SetValue("TFI_CALCMD", cXml)
						oMdlLE:SetValue("TFI_PLACOD", SubString(cCodRev,1,nTamCpoCod))
						oMdlLE:SetValue("TFI_PLAREV", SubString(cCodRev,nTamCpoCod+1,nTamCpoRev))
						If oFWSheet:CellExists("TOTAL_LE_COB")
							oMdlLEa:SetValue("TEV_MODCOB",If(valtype(oFwSheet:GetCellValue("TOTAL_LE_COB")) == 'N',AllTrim(str(oFwSheet:GetCellValue("TOTAL_LE_COB"))),oFwSheet:GetCellValue("TOTAL_LE_COB")))
						EndIf
						If oFWSheet:CellExists("TOTAL_LE_QUANT")
							oMdlLEa:SetValue("TEV_QTDE", If(valtype(oFwSheet:GetCellValue("TOTAL_LE_QUANT")) <> 'N', 0 ,oFwSheet:GetCellValue("TOTAL_LE_QUANT")))
						EndIf
						If oFWSheet:CellExists("TOTAL_LE_VUNIT")
							oMdlLEa:SetValue("TEV_VLRUNI", If(valtype(oFwSheet:GetCellValue("TOTAL_LE_VUNIT")) <> 'N', 0 ,oFwSheet:GetCellValue("TOTAL_LE_VUNIT")))
						EndIf
					EndIf
				Next nY
			Next nX
		Else
			oMdlLE:SetValue("TFI_CALCMD", cXml)
			oMdlLE:SetValue("TFI_PLACOD", SubString(cCodRev,1,nTamCpoCod))
			oMdlLE:SetValue("TFI_PLAREV", SubString(cCodRev,nTamCpoCod+1,nTamCpoRev))
			If oFWSheet:CellExists("TOTAL_LE_COB")
				oMdlLEa:SetValue("TEV_MODCOB",If(valtype(oFwSheet:GetCellValue("TOTAL_LE_COB")) == 'N',AllTrim(str(oFwSheet:GetCellValue("TOTAL_LE_COB"))),oFwSheet:GetCellValue("TOTAL_LE_COB")))
			EndIf
			If oFWSheet:CellExists("TOTAL_LE_QUANT")
				oMdlLEa:SetValue("TEV_QTDE", If(valtype(oFwSheet:GetCellValue("TOTAL_LE_QUANT")) <> 'N', 0 ,oFwSheet:GetCellValue("TOTAL_LE_QUANT")))
			EndIf
			If oFWSheet:CellExists("TOTAL_LE_VUNIT")
				oMdlLEa:SetValue("TEV_VLRUNI", If(valtype(oFwSheet:GetCellValue("TOTAL_LE_VUNIT")) <> 'N', 0 ,oFwSheet:GetCellValue("TOTAL_LE_VUNIT")))
			EndIf
		EndIf
	EndIf
EndIf

If lGsVerb .And. !lFacilit
	If !Empty(cXml)
		at740VbRun(.T., "", "", oMdlRh:GetValue("TFF_PLACOD"), oMdlRh:GetValue("TFF_PLAREV"), oFWSheet)
	EndIf
EndIf

If !lFacilit
	TC740Mnt(oModel)
EndIf

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} At998ConsP

Construção da consulta padrão da tabela ABW - MODELO PLANILHA PREC. SERVICOS

@sample 	At998ConsP() 

@return	lRet, Retorna qual botão foi selecionado .T. Confirmar, .F. Sair 
			cRet, Retorna o codigo+revisão do modelo selecionado

@since		23/10/2013       
@version	P11.9   
/*/
//------------------------------------------------------------------------------
Static Function At998ConsP(cCodPlan)

Local oDlg
Local aBrowse	:= {}   
Local lRet		:= .F.
Local cRet		:= ""
Local cFilABW 	:= xFilial("ABW")
Local nPos 		:= 0
Local lFacilit	:= IsInCallStack("At984aPlPc")
Local lCCT 		:= FindFunction("At999CpCCT") .And. At999CpCCT()
Local lMsBlql 	:= ABW->(FieldPos("ABW_MSBLQL")) <= 0
Local cFuncao 	:= ""
Local cDescFunc := ""
Default cCodPlan := ""

DbSelectArea("ABW")
DbSetOrder(1) //ABW_FILIAL+ABW_CODIGO+ABW_REVISA
ABW->( DbSeek( cFilABW ) ) // posiciona no primeiro registro da filial

While ABW->(!EOF()) .And. ABW->ABW_FILIAL == cFilABW
	cFuncao	  := ""
	cDescFunc := ""
	If lMsBlql .OR. ABW->ABW_MSBLQL != "1"
		If ABW->ABW_ULTIMA == "1"
			cFuncao := ABW->ABW_FUNCAO
			If !Empty(cFuncao)
				cDescFunc := cFuncao+" - "+Posicione("SRJ",1,xFilial("SRJ")+ABW->ABW_FUNCAO,"RJ_DESC") //RJ_FILIAL+RJ_FUNCAO
			EndIf
			If lFacilit .Or. (At998Orc())
				If lCCT
					aAdd(aBrowse,{ABW->ABW_CODIGO,ABW->ABW_DESC,ABW->ABW_REVISA,cDescFunc})
					If !Empty(cCodPlan) .AND. cCodPlan  == ABW->ABW_CODIGO+ABW->ABW_REVISA
						nPos := Len(aBrowse)
					EndIf
				Endif
			Else
				aAdd(aBrowse,{ABW->ABW_CODIGO,ABW->ABW_DESC,ABW->ABW_REVISA,cDescFunc})
				If !Empty(cCodPlan) .AND. cCodPlan  == ABW->ABW_CODIGO+ABW->ABW_REVISA
					nPos := Len(aBrowse)
				EndIf
			Endif
		Endif
	EndIf
	ABW->(DbSkip())
End

If ExistBlock('A998BROP')
	aAux := ExecBlock('A998BROP', .F., .F., {aBrowse} )

	If VALTYPE(aAux) == 'A'
		aBrowse := ACLONE(aAux)
		nPos := Len(aBrowse)
	EndIf
EndIf

If Len(aBrowse) > 0
	DEFINE MSDIALOG oDlg FROM 000,000 TO 370,700 PIXEL TITLE STR0009 //'Consulta Padrão'

	oBrowse := TWBrowse():New( 07, 07, 340, 150,,{STR0010,STR0011,STR0012,"Função"},{25,120,25,120}, oDlg, ,,,,{||},,,,,,,.F.,,.T.,,.F.,,, ) //"Código"#"Descrição"#"Revisão"#"Função"
	oBrowse:SetArray(aBrowse)
	If nPos > 0
		//Posiciona na planilha selecionada
		oBrowse:GoPosition(nPos)
	EndIf
	oBrowse:bLine := {||{aBrowse[oBrowse:nAt,01],aBrowse[oBrowse:nAt,02],aBrowse[oBrowse:nAt,03],aBrowse[oBrowse:nAt,04]} }
	oBrowse:bLDblClick := {|| lRet := .T., cRet := aBrowse[oBrowse:nAt,01]+aBrowse[oBrowse:nAt,03] ,oDlg:End()}

	TButton():New(163,125,STR0005,oDlg,{|| lRet := .T., cRet := aBrowse[oBrowse:nAt,01]+aBrowse[oBrowse:nAt,03] ,oDlg:End() },50,13,,,,.T.) //'Confirmar'
	TButton():New(163,184,STR0013,oDlg,{|| lRet := .F. ,oDlg:End() },50,13,,,,.T.) //'Sair'

	ACTIVATE MSDIALOG oDlg CENTERED 
Else
	Help(,, "AT998COBCTR3",,STR0024,1,0,,,,,,{STR0025}) //"Não encontrou registros para essa consulta." ## "Incluir uma planilha de preços."
EndIf

Return {lRet,cRet}
//------------------------------------------------------------------------------
/*/{Protheus.doc} TECGetValue

Função para retornar qualquer valor do Orçamento de serviços, com o modelo instanciado


@return	xValue

@since		10/10/2016       
@version	P12   
/*/
//------------------------------------------------------------------------------
Function TECGetValue(cAba,cCampo,nLinha,cErro)
Local aSaveLines	:= FWSaveRows()
Local xRet			:= Nil
Default nLinha := 0
Default cErro := ""

If Valtype(oModel740) == 'O'
	cAba := Upper(Alltrim(cAba)) 
	
	Do Case
		Case cAba == 'OR' //-- Cabeçalho Orçamento
			xRet := oModel740:GetValue('TFJ_REFER',cCampo) 
				
			
		Case cAba == 'LA' //-- Local de atendimento
			nlinha := If(nLinha == 0,oModel740:GetModel('TFL_LOC'):GetLine(),nLinha)
			If nLinha > oModel740:GetModel('TFL_LOC'):Length()
				cErro := 'Aba: LA ' + CRLF +  'Linha ' + Str(nLinha) + ' inválida'
			Else
				xRet 	:= oModel740:GetValue('TFL_LOC',cCampo,nLinha)
			EndIf			
			
		
		Case cAba == 'RH' //-- Recursos humanos
			nlinha := If(nLinha == 0,oModel740:GetModel('TFF_RH'):GetLine(),nLinha)
			If nLinha > oModel740:GetModel('TFF_RH'):Length()
				cErro := 'Aba: RH ' + CRLF +  'Linha ' + Str(nLinha) + ' inválida' 
			Else
				xRet 	:= oModel740:GetValue('TFF_RH',cCampo,nLinha)
			EndIf			
		
		Case cAba == 'MI' //-- Material de implantação
			nLinha := If(nLinha == 0,oModel740:GetModel('TFG_MI'):GetLine(),nLinha)
			If nLinha > oModel740:GetModel('TFG_MI'):Length()
				cErro := 'Aba: MI ' + CRLF +  'Linha ' + Str(nLinha) + ' inválida' 
			Else
				xRet 	:= oModel740:GetValue('TFG_MI',cCampo,nLinha)
			EndIf			
		
		Case cAba == 'MC' //-- Material de consumo
			nlinha := If(nLinha == 0,oModel740:GetModel('TFH_MC'):GetLine(),nLinha)
			If nLinha > oModel740:GetModel('TFH_MC'):Length()
				cErro := 'Aba: MC ' + CRLF +  'Linha ' + Str(nLinha) + ' inválida' 
			Else
				xRet 	:= oModel740:GetValue('TFH_MC',cCampo,nLinha)
			EndIf			
		
		Case cAba == 'LE' //-- Locação de equipamento
			nlinha := If(nLinha == 0,oModel740:GetModel('TFI_LE'):GetLine(),nLinha)
			If nLinha > oModel740:GetModel('TFI_LE'):Length()
				cErro := 'Aba: LE ' + CRLF +  'Linha ' + Str(nLinha) + ' inválida' 
			Else
				xRet 	:= oModel740:GetValue('TFI_LE',cCampo,nLinha)
			EndIf			
		
	EndCase
EndIf
FwRestRows( aSaveLines )
Return xRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At998InPl
 Realiza a inclusão de uma Planilha de preço
@author	Kaique Schiller
@since	11/08/2022       
/*/
//------------------------------------------------------------------------------
Static Function At998InPl()
Local lRet := .F.
Local aButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},;
					{.T.,STR0021},{.T.,STR0022},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil}} //"Salvar"#"Cancelar"
Local nRet := FWExecView(STR0023, "TECA999", MODEL_OPERATION_INSERT,, {||.T.},,, aButtons ) //"Planilha de Preço"
Local cCodPlan := ""

If nRet == 0
	lRet := .T.
	cCodPlan := ABW->(ABW_CODIGO+ABW_REVISA)
Endif

Return {lRet,cCodPlan}

//------------------------------------------------------------------------------
/*/{Protheus.doc} At998Orc
 Verificar se foi feita a chamada pelo orçamento e orçamento simplificado
@author	Kaique Schiller
@since	11/08/2022       
/*/
//------------------------------------------------------------------------------
Static Function At998Orc()
Return SuperGetMv("MV_GSITORC",,"2") == "1" .And. (Isincallstack("TECA740") .Or. Isincallstack("TECA745") .Or. IsInCallStack("At600SeAtu") .Or. IsInCallStack("at870revis") .OR. Isincallstack("At870GerOrc") .OR. Isincallstack("TECA870F") )

//------------------------------------------------------------------------------
/*/{Protheus.doc} At998Verb
Quantidades de batidas no dia
@since		28/09/2022
@author Vitor kwon
@return 	Nil
/*/
//------------------------------------------------------------------------------
Function At998Verb(oModel)
Local nValor := 0
Local nX     := 0

If ABP->(ColumnPos('ABP_CONFCA'))
	For nX := 1 to oModel:Length()
		oModel:GoLine(nX)
		If !oModel:IsDeleted() .And. !Empty(oModel:GetValue("ABP_BENEFI"))
			If oModel:GetValue("ABP_CONFCA") != "1"
				nValor += oModel:GetValue("ABP_VALOR")
			EndIf
		Endif
	Next nX
Else
	For nX := 1 to oModel:Length()
		oModel:GoLine(nX)
		If !oModel:IsDeleted() .And.  !Empty(oModel:GetValue("ABP_BENEFI"))
			nValor += oModel:GetValue("ABP_VALOR")
		Endif
	Next nX
EndIf

Return nValor

//------------------------------------------------------------------------------
/*/{Protheus.doc} At998Verba
Retorna o valor da TXX na planilha - verbas adicionais
@since		24/10/2022
@author Vitor kwon
@return 	Nil
/*/
//------------------------------------------------------------------------------
Static Function At998Verba(oModel)

Local cValor    := 0
Local nX := 0

For nX := 1 to oModel:Length()
	oModel:GoLine(nX)
	If !oModel:IsDeleted() .And. !Empty(oModel:GetValue("TXX_CODIGO"))
		cValor += oModel:GetValue("TXX_VALOR")
	Endif
Next nX

Return cValor

//------------------------------------------------------------------------------
/*/{Protheus.doc} At998GtISS
Seleciona o valor do ISS
@since		28/09/2022
@author 	Kaique Schiller
@return 	nRetVlr
/*/
//------------------------------------------------------------------------------
Function At998GtISS(cCodLoc,cCodPrd)
Local nRetVlr := 0
Local cCodISS	:= ""
Local cQry		:= ""
Local cCodEst := ""
Local cCodMun := ""

Default cCodLoc := ""

nRetVlr := Posicione("SB1",1,xFilial("SB1")+cCodPrd,"B1_ALIQISS") //B1_FILIAL+B1_COD

If nRetVlr == 0
	DbSelectArea("ABS")
	ABS->(DbSetOrder(1))
	If !Empty(cCodLoc) .And. ABS->(MsSeek(xFilial("ABS")+cCodLoc))
		cCodEst := ABS->ABS_ESTADO
		cCodMun := ABS->ABS_CODMUN
	Endif

	DbSelectArea("SB1")
	SB1->(DbSetOrder(1))

	If !Empty(cCodPrd) .And. SB1->(MsSeek(xFilial("SB1")+ cCodPrd))
		cCodISS := SB1->B1_CODISS
	EndIf
	
	cQry := ""
	cQry += " SELECT CE1.CE1_ALQISS "
	cQry += " FROM " + RetSqlName("CE1") + " CE1 "
	cQry += " WHERE CE1.CE1_FILIAL = ? "
	cQry += " AND CE1.CE1_ESTISS = ? "
	cQry += " AND CE1.CE1_CMUISS = ? "
	cQry += " AND CE1.CE1_PROISS = ? "
	cQry += " AND CE1.D_E_L_E_T_ = ' ' "

	oStatement := FWPreparedStatement():New( cQry )
	oStatement:SetString( 1, FwXFilial( "CE1" ) )
	oStatement:SetString( 2, cCodEst )
	oStatement:SetString( 3, cCodMun )
	oStatement:SetString( 4, cCodPrd )
	

	cQry := oStatement:GetFixQuery()
	cAliasCE1 := GetNextAlias()

	MPSysOpenQuery( cQry, cAliasCE1 )

	If (cAliasCE1)->(!Eof())
		nRetVlr := (cAliasCE1)->(CE1_ALQISS)
	EndIf
	(cAliasCE1)->(DbCloseArea())
	If nRetVlr == 0
		If !Empty(cCodEst) .And. !Empty(cCodMun)
			cQry := ""
			cQry += " SELECT CE1.CE1_ALQISS "
			cQry += " FROM " + RetSqlName("CE1") + " CE1 "
			cQry += " WHERE CE1.CE1_FILIAL = ? "
			cQry += " AND CE1.CE1_ESTISS = ? "
			cQry += " AND CE1.CE1_CMUISS = ? "
			cQry += " AND CE1.CE1_PROISS = '' "
			cQry += " AND CE1.CE1_CODISS = ? "
			cQry += " AND CE1.D_E_L_E_T_ = ' ' "

			oStatement := FWPreparedStatement():New( cQry )
			oStatement:SetString( 1, FwXFilial( "CE1" ) )
			oStatement:SetString( 2, cCodEst )
			oStatement:SetString( 3, cCodMun )
			oStatement:SetString( 4, cCodISS )
			

			cQry := oStatement:GetFixQuery()
			cAliasCE1 := GetNextAlias()

			MPSysOpenQuery( cQry, cAliasCE1 )

			If (cAliasCE1)->(!Eof())
				nRetVlr := (cAliasCE1)->(CE1_ALQISS)
			EndIf
			(cAliasCE1)->(DbCloseArea())
		Endif
	EndIf

EndIf

Return nRetVlr

//------------------------------------------------------------------------------
/*/{Protheus.doc} At998DTrb
Calculo conforme a projeção de dias trabalhados.
@since		28/09/2022
@author 	Kaique Schiller
@return 	nRetVlr
/*/
//------------------------------------------------------------------------------
Function At998DTrb(cEscala,cTurno,nHrsTot,nHrDia,nHoraSem)
Local aTabPadrao := {}
Local aCalend := {}
Local nX := 0
Local nDiaTrab := 0
Local dDtIni := cTod("01/11/2021")
Local dDtFim := cTod("30/11/2021")
Local cTabTemp := ""
Local nHrIni := 0
Local nHrFim := 0
Local cQry		:= ""
Local cAliasSPJ	:= ""

Default cEscala := ""
Default cTurno := ""
Default nHrsTot := 0
Default nHrDia := 0

If !Empty(cEscala)
	cTabTemp := GetNextAlias()
	BeginSql Alias cTabTemp
		SELECT TDX.TDX_TURNO
		FROM %Table:TDX% TDX
		WHERE TDX.TDX_FILIAL = %xFilial:TDX%
			AND TDX.TDX_CODTDW = %Exp:cEscala% 
			AND TDX.%NotDel%
	EndSql
	If !(cTabTemp)->(EOF())
		cTurno := (cTabTemp)->TDX_TURNO
	Endif
	(cTabTemp)->(DbCloseArea())
Endif

If !Empty(cTurno)
	If ( CriaCalend(dDtIni,dDtFim,cTurno,"01",@aTabPadrao,@aCalend,xFilial("SRA")) )
		For nX := 1 To Len(aCalend)
			If aCalend[nX][6] == "S"
				If aCalend[nX][4] == "1E"
					If nDiaTrab <> 0
						nHrDia := TecConvHr(ElapTime(TecConvHr(nHrIni) + ":00", TecConvHr(nHrFim) + ":00"))
						nHrsTot += nHrDia		
					Endif
					nHrIni := aCalend[nX][3]
					nDiaTrab++
				Endif
				nHrFim := aCalend[nX][3]
				If Len(aCalend) == nX
					nHrDia := TecConvHr(ElapTime(TecConvHr(nHrIni) + ":00", TecConvHr(nHrFim) + ":00"))
					nHrsTot += nHrDia		
					nHrIni := 0
					nHrFim := 0
				Endif
			Endif
		Next nX

		cQry := ""
		cQry += " SELECT SPJ.PJ_HRSTRAB, SPJ.PJ_HRSTRA2, SPJ.PJ_HRSTRA3, SPJ.PJ_HRSTRA4 "
		cQry += " FROM " + RetSqlName("SPJ") + " SPJ "
		cQry += " WHERE SPJ.PJ_TURNO = ? "
		cQry += " AND SPJ.PJ_FILIAL = ? "
		cQry += " AND SPJ.PJ_SEMANA = '01' "
		cQry += " AND SPJ.PJ_TPDIA = 'S' "
		cQry += " AND SPJ.D_E_L_E_T_ = ' ' "

		oStatement := FWPreparedStatement():New( cQry )
		oStatement:SetString( 1, cTurno )
		oStatement:SetString( 2, FwXFilial( "SPJ" ) )
		

		cQry := oStatement:GetFixQuery()
		cAliasSPJ := GetNextAlias()

		MPSysOpenQuery( cQry, cAliasSPJ )
		While (cAliasSPJ)->(!EOF())
			nHoraSem += (HRS2MIN((cAliasSPJ)->PJ_HRSTRAB)/60) + (HRS2MIN((cAliasSPJ)->PJ_HRSTRA2)/60) + (HRS2MIN((cAliasSPJ)->PJ_HRSTRA3)/60) + (HRS2MIN((cAliasSPJ)->PJ_HRSTRA4)/60)
			(cAliasSPJ)->(DbSkip())
		EndDo
		(cAliasSPJ)->(DbCloseArea())
	Endif
Endif

Return nDiaTrab

//------------------------------------------------------------------------------
/*/{Protheus.doc} At998TotFer
Total de feriados no ano
@since		28/09/2022
@author 	Kaique Schiller
@return 	nRetVlr
/*/
//------------------------------------------------------------------------------
Function At998TotFer(cCalend)
Local nTotFer := 1
Local cTabTemp := GetNextAlias()
Local dDtIni := cTod("01/01/"+cValtoChar(Year(dDatabase)))
Local dDtFim := cTod("31/12/"+cValtoChar(Year(dDatabase)))

If !Empty(cCalend)
	BeginSql Alias cTabTemp
		COLUMN RR0_DATA AS DATE
		SELECT COUNT(*) TOTALFER
		FROM %Table:RR0% RR0
		WHERE RR0.RR0_FILIAL = %xFilial:RR0%
			AND RR0.RR0_CODCAL = %Exp:cCalend%
			AND ( ( RR0.RR0_DATA BETWEEN %Exp:dDtIni% AND %Exp:dDtFim% ) OR RR0_FIXO = 'S' )
			AND RR0.%NotDel%
	EndSql
	If !(cTabTemp)->(EOF())
		nTotFer := (cTabTemp)->TOTALFER
	Endif
	(cTabTemp)->(DbCloseArea())
Endif

Return nTotFer


//------------------------------------------------------------------------------
/*/{Protheus.doc} At998TotInt
Horas de intervalos
@since		28/09/2022
@author 	Kaique Schiller
@return 	nRetVlr
/*/
//------------------------------------------------------------------------------
Function At998TotInt(cEscala,cTurno)
Local nHrsInt := 0 
Default cEscala := ""
Default cTurno := ""

If !Empty(cEscala)
	cTabTemp := GetNextAlias()
	BeginSql Alias cTabTemp
		SELECT TDX.TDX_TURNO
		FROM %Table:TDX% TDX
		WHERE TDX.TDX_FILIAL = %xFilial:TDX%
			AND TDX.TDX_CODTDW = %Exp:cEscala% 
			AND TDX.%NotDel%
	EndSql
	If !(cTabTemp)->(EOF())
		cTurno := (cTabTemp)->TDX_TURNO
	Endif
	(cTabTemp)->(DbCloseArea())
Endif

If !Empty(cTurno)
	cTabTemp := GetNextAlias()
	BeginSql Alias cTabTemp
		SELECT PJ_HRSINT1,PJ_HRSINT2,PJ_HRSINT3
		FROM %Table:SPJ% SPJ
		WHERE SPJ.PJ_FILIAL = %xFilial:SPJ%
			AND SPJ.PJ_TURNO = %Exp:cTurno% 
			AND SPJ.PJ_TPDIA = 'S'
			AND (SPJ.PJ_HRSINT1 <> 0 OR SPJ.PJ_HRSINT2  <> 0 OR SPJ.PJ_HRSINT3 <> 0)
			AND SPJ.%NotDel%
	EndSql
	If !(cTabTemp)->(EOF())
	 	nHrsInt := (cTabTemp)->PJ_HRSINT1+(cTabTemp)->PJ_HRSINT2+(cTabTemp)->PJ_HRSINT3
	Endif
	(cTabTemp)->(DbCloseArea())
Endif

Return nHrsInt

//------------------------------------------------------------------------------
/*/{Protheus.doc} At998HrNt
Horas Noturnas
@since		28/09/2022
@author 	Kaique Schiller
@return 	nHrsNot
/*/
//------------------------------------------------------------------------------
Function At998HrNt(cEscala,cTurno, cDescPeriod,lFeriad)
Local nHrsNot := 0 
Local cTabTemp := ""
Local lCalcAdcNot := .T.
Local cQuery := ""
Local oStatement := Nil
Default cEscala := ""
Default cTurno := ""

If !Empty(cEscala)
	If TDW->( FieldPos( "TDW_ADCNOT" ) ) > 0
		cTabTemp := GetNextAlias()
		cQuery := "SELECT TDW.TDW_ADCNOT, TDW.TDW_PERIOD "
		cQuery += "FROM ? TDW "
		cQuery += "WHERE TDW.TDW_FILIAL = ? "
		cQuery += "	AND TDW.TDW_COD = ? "
		cQuery += "	AND TDW.D_E_L_E_T_ = ' ' "
		oStatement := FWPreparedStatement():New( cQuery )
		oStatement:SetNumeric( 1, RetSqlName( "TDW" ) )
		oStatement:SetString( 2, FwxFilial( "TDW" ) )
		oStatement:SetString( 3, cEscala )
		cQuery := oStatement:GetFixQuery()
		MPSysOpenQuery( cQuery, cTabTemp )
		If !(cTabTemp)->(EOF())
			lCalcAdcNot := (cTabTemp)->TDW_ADCNOT == "1"
			cDescPeriod := (cTabTemp)->TDW_PERIOD
		Endif
		(cTabTemp)->(DbCloseArea())
		oStatement:Destroy()
		FwFreeObj( oStatement )
	EndIf
	cTabTemp := GetNextAlias()
	cQuery := "SELECT TDX.TDX_TURNO, TDX.TDX_COD "
	cQuery += "FROM ? TDX "
	cQuery += "WHERE TDX.TDX_FILIAL = ? "
	cQuery += "	AND TDX.TDX_CODTDW = ? "
	cQuery += "	AND TDX.D_E_L_E_T_ = ' ' "
	oStatement := FWPreparedStatement():New( cQuery )
	oStatement:SetNumeric( 1, RetSqlName( "TDX" ) )
	oStatement:SetString( 2, FwxFilial( "TDX" ) )
	oStatement:SetString( 3, cEscala )
	cQuery := oStatement:GetFixQuery()
	MPSysOpenQuery( cQuery, cTabTemp )
	If !(cTabTemp)->(EOF())
		cTurno := (cTabTemp)->TDX_TURNO
		If !Empty(Posicione("TDY",2,xFilial("TDY")+(cTabTemp)->TDX_COD,"TDY_COD"))
			lFeriad := .T.
		EndIf
	Endif
	(cTabTemp)->(DbCloseArea())
	oStatement:Destroy()
	FwFreeObj( oStatement )
Endif

If !Empty(cTurno) .And. lCalcAdcNot
	cTabTemp := GetNextAlias()
	cQuery := "SELECT R6_INIHNOT,R6_FIMHNOT "
	cQuery += "FROM ? SR6 "
	cQuery += "WHERE SR6.R6_FILIAL = ? "
	cQuery += "	AND SR6.R6_TURNO = ? "
	cQuery += "	AND SR6.D_E_L_E_T_ = ' ' "
	oStatement := FWPreparedStatement():New( cQuery )
	oStatement:SetNumeric( 1, RetSqlName( "SR6" ) )
	oStatement:SetString( 2, FwxFilial( "SR6" ) )
	oStatement:SetString( 3, cTurno )
	cQuery := oStatement:GetFixQuery()
	MPSysOpenQuery( cQuery, cTabTemp )

	aHoraTrab := GetHoraTrb( cEscala, cTurno )

	If !(cTabTemp)->(EOF())
		nHrsNot := CalcHorNot( aHoraTrab[1], aHoraTrab[2], (cTabTemp)->R6_INIHNOT, (cTabTemp)->R6_FIMHNOT )
	Endif
	(cTabTemp)->(DbCloseArea())
	oStatement:Destroy()
	FwFreeObj( oStatement )
Endif

Return nHrsNot

//------------------------------------------------------------------------------
/*/{Protheus.doc} At998PsqCCT
Retorna valor ou % PLR
@since		11/07/2023
@author 	flavio.vicco
@return 	nPlrCCT
/*/
//------------------------------------------------------------------------------
Function At998PsqCCT(cCodigo)
Local cTabTemp := ""
Local cCodPla  := ""
Local cCodRev  := ""
Local nPlrCCT  := 0

Local nTamCpoCod := TamSX3("TFF_PLACOD")[1]
Local nTamCpoRev := TamSX3("TFF_PLAREV")[1]

	cCodPla := SubString(cCodigo,1,nTamCpoCod)
	cCodRev := SubString(cCodigo,nTamCpoCod+1,nTamCpoRev)

	cTabTemp := GetNextAlias()
	BeginSql Alias cTabTemp
		SELECT WY_PLRTPC, WY_PLRVLR, WY_PLRPER
		FROM %Table:SWY% SWY
		INNER JOIN %Table:ABW% ABW ON ABW.ABW_FILIAL=%xFilial:ABW% AND ABW_CODIGO=%Exp:cCodPla% AND ABW_REVISA=%Exp:cCodRev% AND ABW.%NotDel%
		INNER JOIN %Table:TCW% TCW ON TCW.TCW_FILIAL=%xFilial:TCW% AND TCW_CODIGO=ABW_CODTCW AND WY_CODIGO=TCW_CODCCT AND TCW.%NotDel%
		WHERE SWY.WY_FILIAL = %xFilial:SWY% AND SWY.%NotDel%
	EndSql
	If !(cTabTemp)->(EOF())
		If (cTabTemp)->WY_PLRTPC == "1"
			nPlrCCT := (cTabTemp)->WY_PLRPER
		Else
			nPlrCCT := (cTabTemp)->WY_PLRVLR
		EndIf
	EndIf
	(cTabTemp)->(DbCloseArea())

Return nPlrCCT

//------------------------------------------------------------------------------
/*/{Protheus.doc} at998Val
Retorna valor em Numérico caso venha como Caractere.
@since		27/07/2023
@author 	jack.junior
@return 	xValor - Numérico
/*/
//------------------------------------------------------------------------------
Function at998Val(xValor)

If ValType(xValor) <> "N"
	xValor := Val(xValor)
EndIf

Return xValor

//------------------------------------------------------------------------------
/*/{Protheus.doc} at998SalCCT
Retorna o Salário de acordo com a Função e Código da CCT
@since		05/07/2024
@author 	jack.junior
@return 	nSalario - Numérico
/*/
//------------------------------------------------------------------------------
Function at998SalCCT(cCodCCT, cFuncao)
Local cQuery	:= ""
Local oQuery	:= NIL
Local cAliasRI4 := GetNextAlias()
Local nSalario	:= 0

//Busca Salário cadastrado na CCT de acordo com a função:
cQuery	:= " SELECT RI4.RI4_SALARI"
cQuery	+= " FROM ? RI4 "
cQuery	+= " WHERE RI4.RI4_FILIAL = ? AND "
cQuery	+= " RI4.RI4_FILCCT = ? AND "
cQuery	+= " RI4.RI4_CODCCT = ? AND "
cQuery	+= " RI4.RI4_FILSRJ = ? AND "
cQuery	+= " RI4.RI4_CODSRJ = ? AND "
cQuery	+= " RI4.D_E_L_E_T_ = ' ' "

//Prepara a query:
oQuery := FwPreparedStatement():New(cQuery)
//Substituição das variáveis "?"
oQuery:SetNumeric( 1, RetSQLName("RI4") ) //TABELA RI4
oQuery:SetString( 2, xFilial('RI4') )	  //Filial RI4
oQuery:SetString( 3, xFilial('SWY') )	  //Filial SWY
oQuery:SetString( 4, cCodCCT )			  //Código da CCT
oQuery:SetString( 5, xFilial('SRJ') )	  //Filial SRJ
oQuery:SetString( 6, cFuncao )			  //Código da Função

cQuery := oQuery:GetFixQuery()
MPSysOpenQuery(cQuery, cAliasRI4)

If (cAliasRI4)->(!Eof())
	DbSelectArea("TFJ")
	RI4->(dbSetOrder(1))
	nSalario := (cAliasRI4)->(RI4_SALARI)
EndIf

(cAliasRI4)->(dBCloseArea())
oQuery:Destroy()
FwFreeObj(oQuery)

Return nSalario

//------------------------------------------------------------------------------
/*/{Protheus.doc} AT998GetSh
Retorna a variavel static
@since		29/07/2024
@author 	serviços
@return 	oFWSheet
/*/
//------------------------------------------------------------------------------
Function AT998GetSh()
Return oFWSheet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At998QtdIntra
@description  Retorna a Quantidade de HE de intrajornada (entre intervalo) da Escala
@param cEscala, String - Escala
@return nRet, Numeric - Quantidade de Hora Extra em intrajornada. O cálculo leva em consideração a quantidade de
						dias trabalhados com hora extra no intervalo da agenda em todas as sequencias da escala.
@author jack.junior
@since 19/08/2024
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At998QtdIntra(cEscala)
Local aTGW      := {}
Local cAliasEsc := GetNextAlias()
Local cAliasTGW := ""
Local cQryTGW   := ""
Local cQuery    := ""
Local lTemAntes := .T. //TEM POSIÇÃO 
Local lTemDepois:= .T.
Local lIntraJorn:= .F.
Local nDiasTrab := 0 //TOTAL DE DIAS TRABALHADOS DA ESCALA (TODAS AS SEQUENCIAS)
Local nHorasEsc := 0 //TOTAL DE HORAS EXTRA DE INTRAJORNADA DA ESCALA (TODAS AS SEQUENCIAS)
Local nPosTGW   := 0
Local nRet      := 0
Local nAntes	:= 0
Local nDepois	:= 0
Local nIntervalo:= 0
Local oQryTGW   := Nil
Local oQuery    := Nil

If !Empty(cEscala)
	//Pega TODAS as manutenções planejadas de HE da escala (todas as sequencias):
	cQuery	:= " SELECT TGW.TGW_COD, TGW.TGW_EFETDX, TGW.TGW_DIASEM, TXH.TXH_HORAIN, TXH.TXH_HORAFI "
	cQuery	+= " FROM ? TGW "
		cQuery	+= " INNER JOIN ? TDX ON "
			cQuery	+= " TDX.TDX_FILIAL = ? "
			cQuery	+= " AND TDX.TDX_COD = TGW.TGW_EFETDX "
			cQuery	+= " AND TDX.D_E_L_E_T_ = ' ' "
		cQuery	+= " INNER JOIN ? TDW ON "
			cQuery	+= " TDW.TDW_FILIAL = ? "
			cQuery	+= " AND TDW.TDW_COD = TDX.TDX_CODTDW "
			cQuery	+= " AND TDW.D_E_L_E_T_ = ' ' "
		cQuery	+= " INNER JOIN ? TXH ON "
			cQuery	+= " TXH.TXH_FILIAL = ? "
			cQuery	+= " AND TXH.TXH_CODPAI = TGW.TGW_COD "
			cQuery	+= " AND TXH.D_E_L_E_T_ = ' ' "
	cQuery	+= " WHERE TGW.TGW_FILIAL = ? AND "
	cQuery	+= " TDW.TDW_COD = ? AND "
	cQuery	+= " TGW.D_E_L_E_T_ = ' ' "

	//Prepara a query:
	oQuery := FwPreparedStatement():New(cQuery)

	//SELECT
	oQuery:SetNumeric( 1, RetSQLName("TGW") )	//TABELA TGW
	//INNER JOIN
	oQuery:SetNumeric( 2, RetSQLName("TDX") ) 	//TABELA TDX
	oQuery:SetString( 3, xFilial('TDX') )		//Filial TDX
	//INNER JOIN
	oQuery:SetNumeric( 4, RetSQLName("TDW") )	//TABELA TDW
	oQuery:SetString( 5, xFilial('TDW') )		//Filial TDW
	//INNER JOIN
	oQuery:SetNumeric( 6, RetSQLName("TXH") ) 	//TABELA TXH
	oQuery:SetString( 7, xFilial('TXH') )		//Filial TXH
	//WHERE
	oQuery:SetString( 8, xFilial('TGW') )		//Filial TGW
	oQuery:SetString( 9, cEscala )				//Escala

	cQuery := oQuery:GetFixQuery()
	MPSysOpenQuery(cQuery, cAliasEsc)

	While (cAliasEsc)->(!Eof())
		cAliasTGW := GetNextAlias()
		aTGW	  := {}
		
		//Pega Todos os períodos de uma TGW de mesmo dia da semana do dia que foi feita manutenção planejada de HE:
		cQryTGW	:= " SELECT TGW.TGW_COD, TGW.TGW_HORINI, TGW.TGW_HORFIM, TGW.TGW_STATUS, TDX.TDX_TURNO, TDX.TDX_SEQTUR, TGW.TGW_DIASEM "
		cQryTGW	+= " FROM ? TGW "
		cQryTGW	+= " INNER JOIN ? TDX ON "
		cQryTGW	+= " TDX.TDX_FILIAL = ? "
		cQryTGW	+= " AND TDX.TDX_COD = TGW.TGW_EFETDX "
		cQryTGW	+= " AND TDX.D_E_L_E_T_ = ' ' "
		cQryTGW	+= " WHERE TGW.TGW_FILIAL = ? AND "
		cQryTGW	+= " TGW.TGW_EFETDX = ? AND "
		cQryTGW	+= " TGW.TGW_DIASEM = ? AND "
		cQryTGW	+= " TGW.D_E_L_E_T_ = ' ' "
		cQryTGW	+= " ORDER BY TGW.TGW_COD "

		//Prepara a query:
		oQryTGW := FwPreparedStatement():New(cQryTGW)

		//SELECT
		oQryTGW:SetNumeric( 1, RetSQLName("TGW") ) 		//TABELA TGW
		//INNER JOIN
		oQryTGW:SetNumeric( 2, RetSQLName("TDX") ) 	//TABELA TDX
		oQryTGW:SetString( 3, xFilial('TDX') )		//Filial TDX
		//WHERE
		oQryTGW:SetString( 4, xFilial('TGW') ) 			//Filial TGW
		oQryTGW:SetString( 5, (cAliasEsc)->TGW_EFETDX )	//CodTDX
		oQryTGW:SetString( 6, (cAliasEsc)->TGW_DIASEM )	//Dia da semana

		cQryTGW := oQryTGW:GetFixQuery()
		MPSysOpenQuery(cQryTGW, cAliasTGW)

		//Reset de variáveis
		nIntervalo := 0
		aTGW := {}

		While (cAliasTGW)->(!Eof())
			//TGW_STATUS = 3 é intervalo
			If (cAliasTGW)->TGW_STATUS = '3'
				nIntervalo++
				lIntraJorn := .T.
			EndIf

			If lIntraJorn
				//Verifica se o Intervalo é Intrajornada na tabela de horário padrão SPJ:
				lIntraJorn := At998Interv((cAliasTGW)->TDX_TURNO, (cAliasTGW)->TDX_SEQTUR, (cAliasTGW)->TGW_DIASEM, nIntervalo)
			EndIf

			AADD(aTGW, {(cAliasTGW)->TGW_COD,;
						TecConvHr((cAliasTGW)->TGW_HORINI),; //Conversão para String '00:00'
						TecConvHr((cAliasTGW)->TGW_HORFIM),; //Conversão para String '00:00'
						lIntraJorn})
			(cAliasTGW)->(dbSkip())

			lIntraJorn := .F.
		EndDo		
		
		(cAliasTGW)->(dBCloseArea())
		oQryTGW:Destroy()
		FwFreeObj(oQryTGW)

		//Verifica se agenda tem intervalo (len > 2)
		//Soma as horas extras de INTRAJORNADA:
		If Len(aTGW) > 2
			nPosTGW := Ascan(aTGW, {|x| x[1] == (cAliasEsc)->TGW_COD })
			If nPosTGW > 0
				nAntes := nPosTGW - 1
				nDepois := nPosTGW + 1

				//Proteje caso seja o primeiro e/ou o ultimo registro do array:
				If nPosTGW == 1
					lTemAntes := .F.
				EndIf
				If nPosTGW == Len(aTGW)
					lTemDepois := .F.
				EndIf

				//TXH = Hora da manutenção de HE:
				nHrIniTXH := HoraToInt((cAliasEsc)->TXH_HORAIN)
				nHrFimTXH := HoraToInt((cAliasEsc)->TXH_HORAFI)
				//TGW = Hora original da agenda:
				nHrIniTGW := HoraToInt(aTGW[nPosTGW,2])
				nHrFimTGW := HoraToInt(aTGW[nPosTGW,3])

				//Se o intervalo é antes e depois (mais de um intervalo na agenda) - VERIFICA QTD DE HE NA HORA INI E HORA FIM
				If (lTemAntes .And. aTGW[nAntes,4]) .And. (lTemDepois .And. aTGW[nDepois,4])
					If nHrIniTXH < nHrIniTGW
						nHorasEsc += (nHrIniTGW - nHrIniTXH)
					EndIf
					If nHrFimTXH > nHrFimTGW
						nHorasEsc += (nHrFimTXH - nHrFimTGW)
					EndIf
				Else
					//Se o intervalo antes do período em questão - VERIFICA QTD DE HE NA HORA INI
					If lTemAntes .And. aTGW[nAntes,4]
						If nHrIniTXH < nHrIniTGW
							nHorasEsc += (nHrIniTGW - nHrIniTXH)
						EndIf
					//Se o intervalo depois do período em questão - VERIFICA QTD DE HE NA HORA FIM
					ElseIf lTemDepois .And. aTGW[nDepois,4]
						If nHrFimTXH > nHrFimTGW
							nHorasEsc += (nHrFimTXH - nHrFimTGW)
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf

		lTemAntes := .T.
		lTemDepois := .T.

		(cAliasEsc)->(dbSkip())
	EndDo

	(cAliasEsc)->(dBCloseArea())
	oQuery:Destroy()
	FwFreeObj(oQuery)

	//Total de Dias trabalhados da escala (Todas as sequencias)
	nDiasTrab := At998DiasT(cEscala)

	//TOTAL DE HORAS DE INTRA DA ESCALA / NUMERO DE DIAS TRABALHADOS DA ESCALA
	If nDiasTrab > 0 .And. nHorasEsc > 0
		nRet := nHorasEsc / nDiasTrab
	EndIf
EndIf

Return Round(nRet,2)


//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At998Interv
@description Verifica se a Tabela de horário padrão considera o Intervalo do DIA como
			 INTRAjornada (PJ_INTERV* = 'S') 
		  ou INTERjornada (PJ_INTERV* = 'S')
		  Podendo ser PJ_INTERV1, PJ_INTERV2 ou PJ_INTERV3 a depender de qual intervalo do dia que estamos verificando.


@param cTurno, String - Turno (PJ_TURNO)
		cSeq, String - Sequencia do Turno (PJ_SEMANA)
		cDia, String - Dia (PJ_DIA)
		nIntervalo, Numérico - Número do intervalo (de 1 a 3)

@return lIntraj - Indica se é intrajornada ou não.

@author jack.junior
@since 21/08/2024
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At998Interv(cTurno, cSeq, cDia, nIntervalo)
Local lIntraj := .F.

//Só podem existir 3 intervalos na SPJ: PJ_INTERV1, PJ_INTERV2, PJ_INTERV3
If nIntervalo >= 1 .And. nIntervalo <= 3
	//INDICE 1 -> PJ_FILIAL+PJ_TURNO+PJ_SEMANA+PJ_DIA   
	lIntraj := Posicione("SPJ", 1, xFilial("SPJ")+cTurno+cSeq+cDia, "PJ_INTERV"+CValToChar(nIntervalo)) == 'S'
EndIf

Return lIntraj

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At998DiasT
@description  Retorna a Quantidade de dias trabalhados na Escala considerando todas as sequencias
@param cEscala, String - Escala
@return nDiasTrab, Numeric

@author jack.junior
@since 21/08/2024
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At998DiasT(cEscala)
Local cAliasEsc := GetNextAlias()
Local cQuery 	:= ""
Local nDiasTrab := 0
Local oQuery 	:= Nil

If !Empty(cEscala)
	cQuery	:= " SELECT DISTINCT TGW_DIASEM, TDX_COD "
		cQuery	+= " FROM ? TGW "
			cQuery	+= " INNER JOIN ? TDX ON "
				cQuery	+= " TDX.TDX_FILIAL = ? "
				cQuery	+= " AND TDX.TDX_COD = TGW.TGW_EFETDX "
				cQuery	+= " AND TDX.D_E_L_E_T_ = ' ' "
			cQuery	+= " INNER JOIN ? TDW ON "
				cQuery	+= " TDW.TDW_FILIAL = ? "
				cQuery	+= " AND TDW.TDW_COD = TDX.TDX_CODTDW "
				cQuery	+= " AND TDW.D_E_L_E_T_ = ' ' "
	cQuery	+= " WHERE TGW.TGW_FILIAL = ? AND "
		cQuery	+= " TDW.TDW_COD = ? AND "
		cQuery	+= " TGW.TGW_STATUS = ? AND "
		cQuery	+= " TGW.D_E_L_E_T_ = ' ' "

	//Prepara a query:
	oQuery := FwPreparedStatement():New(cQuery)

	//SELECT
	oQuery:SetNumeric( 1, RetSQLName("TGW") )	//TABELA TGW
	//INNER JOIN
	oQuery:SetNumeric( 2, RetSQLName("TDX") ) 	//TABELA TDX
	oQuery:SetString( 3, xFilial('TDX') )		//Filial TDX
	//INNER JOIN
	oQuery:SetNumeric( 4, RetSQLName("TDW") )	//TABELA TDW
	oQuery:SetString( 5, xFilial('TDW') )		//Filial TDW
	//WHERE
	oQuery:SetString( 6, xFilial('TGW') )		//Filial TGW
	oQuery:SetString( 7, cEscala )				//Escala
	oQuery:SetString( 8, '1' )					//STATUS = '1' - DIAS TRABALHADOS

	cQuery := oQuery:GetFixQuery()
	MPSysOpenQuery(cQuery, cAliasEsc)

	While (cAliasEsc)->(!Eof())
		nDiasTrab ++
		(cAliasEsc)->(dbSkip())
	EndDo
EndIf

(cAliasEsc)->(dBCloseArea())
oQuery:Destroy()
FwFreeObj(oQuery)

Return nDiasTrab

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} updInsumos
@description Update 18/02/2025: 
	Divide o valor dos materiais MI,MC,Uniforme e Armamento na planilha de preços
	pela quantidade vendida no Posto
@param nQtdVen, Numérico - Quantidade de postos vendidos da TFF

@author jack.junior
@since 17/09/2024
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function updInsumos(nQtdVen)
Local aMateriais:= {"TOTAL_MI","TOTAL_MC","TOTAL_UNIF","TOTAL_ARMA"}
Local nOldValue	:= 0
Local nNewValue	:= 0
Local nX		:= 1

If ValType(oFWSheet) == "O" .And. nQtdVen > 0

	//Atualiza a Formula dos Materiais de acordo com quantidade vendida no Posto:
	For nX := 1 To Len(aMateriais)
		If oFWSheet:CellExists(aMateriais[nX]) .And. IIF(Alltrim(oFWSheet:GetCellValue(aMateriais[nX])) == "0", .F., oFWSheet:GetCellValue(aMateriais[nX]) > 0 ) 
			nOldValue := oFWSheet:GetCellValue(aMateriais[nX])
			nNewValue := nOldValue/nQtdVen
			oFWSheet:SetCellValue(aMateriais[nX],nNewValue)
		EndIf
	Next nX
EndIf

Return

/*/{Protheus.doc} GetHoraTrb
	Retorna a hora de início e fim da Escala/Turno/TFF
	@type Static Function
	@author Anderson F. Gomes
	@since 05/02/2025
	@param cEscala, Character, Código da Escala
	@param cTurno, Character, Código do Turno
	@return aRet, Array, aRet[1] = Hora Inical, aRet[2] = Hora Final
/*/
Static Function GetHoraTrb( cEscala As Character, cTurno As Character ) As Array
	Local aRet As Array
	Local oModel As Object
	Local oMdlRh As Object
	Local oStatement As Object
	Local cQuery As Character
	Local cAlias As Character
	Local cDiaSemana As Character
	Local nHoraIn As Numeric
	Local nHoraFi As Numeric

	aRet := {}
	oModel := FwModelActive()
	oMdlRh := oModel:GetModel("TFF_RH")

	If Empty( cEscala )
		aRet := { HoraToInt( oMdlRh:GetValue( "TFF_HORAIN" ) ), HoraToInt( oMdlRh:GetValue( "TFF_HORAFI" ) ) }
	Else
		cQuery := "SELECT TGW.TGW_DIASEM, TGW.TGW_HORINI, TGW.TGW_HORFIM "
		cQuery += "FROM ? TDW "
		cQuery += "INNER JOIN ? TDX ON ? AND TDW.TDW_COD = TDX.TDX_CODTDW AND TDX.D_E_L_E_T_ = ' ' "
		cQuery += "INNER JOIN ? TGW ON ? AND TGW.TGW_EFETDX = TDX.TDX_COD AND TGW.D_E_L_E_T_ = ' ' "
		cQuery += "WHERE TDW.TDW_FILIAL = ? "
		cQuery += "AND TDW.TDW_COD = ? "
		cQuery += "AND TGW.TGW_STATUS = '1' "
		cQuery += "AND TDW.D_E_L_E_T_ = ' ' "
		cQuery += "ORDER BY TGW.TGW_DIASEM, TGW.TGW_COD "
		oStatement := FWPreparedStatement():New( cQuery )
		oStatement:SetNumeric( 1, RetSqlName( "TDW" ) )
		oStatement:SetNumeric( 2, RetSqlName( "TDX" ) )
		oStatement:SetNumeric( 3, FWJoinFilial( "TDW", "TDX" ) )
		oStatement:SetNumeric( 4, RetSqlName( "TGW" ) )
		oStatement:SetNumeric( 5, FWJoinFilial( "TDX", "TGW" ) )
		oStatement:SetString( 6, FwxFilial( "TDW" ) )
		oStatement:SetString( 7, cEscala )
		cQuery := oStatement:GetFixQuery()
		cAlias := GetNextAlias()
		MPSysOpenQuery( cQuery, cAlias )

		If (cAlias)->( !EoF() )
			cDiaSemana := (cAlias)->TGW_DIASEM
			nHoraIn := (cAlias)->TGW_HORINI
			While (cAlias)->( !EoF() ) .And. (cAlias)->TGW_DIASEM == cDiaSemana
				nHoraFi := (cAlias)->TGW_HORFIM
				(cAlias)->( DbSkip() )
			EndDo
			aRet := { nHoraIn, nHoraFi }
		Endif
		(cAlias)->(DbCloseArea())
		oStatement:Destroy()
		FwFreeObj( oStatement )
	EndIf
Return aRet

/*/{Protheus.doc} CalcHorNot
	Calcula o total de horas noturnas dentro da Escala/Turno
	@type Static Function
	@author Anderson F. Gomes
	@since 05/02/2025
	@param nHorTrbIni, Numeric, Hora de Trabalho Inicial
	@param nHorTrbFim, Numeric, Hora de Trabalho Final
	@param nHorNotIni, Numeric, Hora noturna Inicial
	@param nHorNotFim, Numeric, Hora noturna Final
	@return nHorNotTot, Numeric, Total de Horas Noturna dentro da Escala/Turno
/*/
Static Function CalcHorNot( nHorTrbIni As Numeric, nHorTrbFim As Numeric, nHorNotIni As Numeric, nHorNotFim As Numeric ) As Numeric
	Local nHorNotTot As Numeric
	Local nAuxIni As Numeric
	Local nAuxFim As Numeric
	Local nX As Numeric
	Local nY As Numeric
	Local aPerioTrab As Array
	Local aPerioNotu As Array

	aPerioTrab = DividPeriod( nHorTrbIni, nHorTrbFim )
	aPerioNotu = DividPeriod( nHorNotIni, nHorNotFim )

	nHorNotTot = 0

	For nX := 1 To Len( aPerioTrab )
		For nY := 1 To Len( aPerioNotu )
			nAuxIni := Max( aPerioTrab[nX][1], aPerioNotu[nY][1] )
			nAuxFim := Min( aPerioTrab[nX][2], aPerioNotu[nY][2] )
			If nAuxIni < nAuxFim
				nHorNotTot += nAuxFim - nAuxIni
			EndIf
		Next nY
	Next nX

Return nHorNotTot

/*/{Protheus.doc} DividPeriod
	Separa os períodos em intervalos no mesmo dia
	@type Static Function
	@author Anderson F. Gomes
	@since 05/02/2025
	@param nHoraIni, Numeric, Hora inicial
	@param nHoraFim, Numeric, Hora Final
	@return aRet, Array, Dentro do aRet são retornados os períodos { HORA_INICIAL, HORA_FINAL }
/*/
Static Function DividPeriod( nHoraIni, nHoraFim ) As Array
	Local aRet As Array
	If nHoraIni <= nHoraFim
		aRet := { { nHoraIni, nHoraFim } }
	Else
		// Se o período passar de um dia para o outro quebra em dois
		aRet := { { nHoraIni, 24 }, { 0, nHoraFim } }
	EndIf
Return aRet


//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At998ExJob
	Encerramento dos Jobs e Atualizacao dos dados dos Postos
@author flavio.vicco
@since 19/03/2025
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At998ExJob(cEmp, cFil, cXml, cCodRev, cJobThr, aData, lOrcSrv)
Local nTotal	:= 0
Local nTotPlan	:= 0
Local nAjustEsc	:= ((((365*4)+1)/4)/12)/30
Local nPLucro	:= 0
Local cTotAbINS	:= 0
Local aResult	:= {}
Local lAbtInss	:= .F.
Local lRet		:= .T.
Local oSheet	:= Nil

//-- Inicio do processamento da THREAD
PutGlbValue(cJobThr, "INIT")
GlbUnLock()

//-- Abre o ambiente
If cEmp <> Nil
	RpcSetType(3)
	lRet := RPCSetEnv(cEmp,cFil,,,"TEC",,,,,,)
EndIf

If lRet
	lAbtInss := TFF->( ColumnPos('TFF_ABTINS') ) > 0 .AND. SuperGetMv("MV_GSDSGCN",,"2") == "1"

	//-- Inicio do processamento da THREAD
	PutGlbValue(cJobThr, "CALC")
	GlbUnLock()

	//-- Instancia a planilha sem exibição
	oSheet := FWUIWorkSheet():New(,.F.) 

	If MethIsMemberOf(oSheet,"ShowAllErr")
		oSheet:ShowAllErr(.F.)
	EndIf

	oSheet:LoadXmlModel(cXml)

	If lOrcSrv
		If oSheet:CellExists("TOTAL_MI")
			oSheet:SetCellValue("TOTAL_MI", aData[25])
		EndIf	
		If oSheet:CellExists("TOTAL_MC")
			oSheet:SetCellValue("TOTAL_MC", aData[24])
		EndIf
		If oSheet:CellExists("TOTAL_UNIF")
			oSheet:SetCellValue("TOTAL_UNIF", aData[26])
		EndIf
		If oSheet:CellExists("TOTAL_ARMA")
			oSheet:SetCellValue("TOTAL_ARMA", aData[22])
		EndIf
		If oSheet:CellExists("TOTAL_VERBAS")
			oSheet:SetCellValue("TOTAL_VERBAS", aData[27])
		EndIf
		If oSheet:CellExists("IMPOSTO_ISS")
			oSheet:SetCellValue("IMPOSTO_ISS", aData[16])
		Endif
		If oSheet:CellExists("AJUSTE_ESCALA") .And. Alltrim(oSheet:oFWFormula:GetCell("AJUSTE_ESCALA"):Formula) == "=0"
			oSheet:SetCellValue("AJUSTE_ESCALA", nAjustEsc)
		EndIf
		If oSheet:CellExists("MES_COMERCIAL") .And. Alltrim(oSheet:oFWFormula:GetCell("MES_COMERCIAL"):Formula) == "=0"
			oSheet:SetCellValue("MES_COMERCIAL","="+cValTochar(aData[8])+"*G6")
		EndIf
		If oSheet:CellExists("JORNADA_CALCULO") .And. Alltrim(oSheet:oFWFormula:GetCell("JORNADA_CALCULO"):Formula) == "=0"
			oSheet:SetCellValue("JORNADA_CALCULO","="+"G7"+"-G5")
		Endif
		If oSheet:CellExists("HORAS_SEMANA") .And. Alltrim(oSheet:oFWFormula:GetCell("HORAS_SEMANA"):Formula) == "=0"
			oSheet:SetCellValue("HORAS_SEMANA",aData[11])
		Endif
		If oSheet:CellExists("FERIADO") .And. Alltrim(oSheet:oFWFormula:GetCell("FERIADO"):Formula) == "=0"
			oSheet:SetCellValue("FERIADO","="+Iif(aData[23] <> 1 ,cValToChar(aData[23])+"/12",cValToChar(aData[23])))
		Endif
		If oSheet:CellExists("INTERVALO") .And. Alltrim(oSheet:oFWFormula:GetCell("INTERVALO"):Formula) == "=0"
			oSheet:SetCellValue("INTERVALO",aData[12])
		Endif
		If oSheet:CellExists("JORNADA_COMERCIAL") .And. Alltrim(oSheet:oFWFormula:GetCell("JORNADA_COMERCIAL"):Formula) == "=0"
			oSheet:SetCellValue("JORNADA_COMERCIAL",aData[10])
		Endif
		If oSheet:CellExists("TOTAL_HORAS") .And. Alltrim(oSheet:oFWFormula:GetCell("TOTAL_HORAS"):Formula) == "=0"
			oSheet:SetCellValue("TOTAL_HORAS",aData[9])
		EndIf
		If oSheet:CellExists("HORA_EXTRA") .And. Alltrim(oSheet:oFWFormula:GetCell("HORA_EXTRA"):Formula) == "=0"
			oSheet:SetCellValue("HORA_EXTRA","="+"(G7*G2)-G8")
		EndIf
		If oSheet:CellExists("VALOR_HORA") .And. Alltrim(oSheet:oFWFormula:GetCell("VALOR_HORA"):Formula) == "=0"
			oSheet:SetCellValue("VALOR_HORA","="+"D2/G8")
		EndIf
		If oSheet:CellExists("VALOR_EXTRA") .And. Alltrim(oSheet:oFWFormula:GetCell("VALOR_EXTRA"):Formula) == "=0"
			oSheet:SetCellValue("VALOR_EXTRA","="+"G10*(CALC_HORA_EXTRA/100)")
		EndIf
		If oSheet:CellExists("VALOR_EXTRA_FERIADO") .And. Alltrim(oSheet:oFWFormula:GetCell("VALOR_EXTRA_FERIADO"):Formula) == "=0"
			oSheet:SetCellValue("VALOR_EXTRA_FERIADO","="+"G10*(CALC_HORA_EXTRAFER/100)")
		EndIf
		If oSheet:CellExists("PER_ESCALA") .AND. !Empty(aData[14]) .AND. Alltrim(oSheet:oFWFormula:GetCell("PER_ESCALA"):Formula) == "=0"
			oSheet:SetCellValue("PER_ESCALA",IIF(aData[14] == "D", 1 , 2) )
		Endif
		If oSheet:CellExists("ESC_FER") .AND. Alltrim(oSheet:oFWFormula:GetCell("ESC_FER"):Formula) == "=0"
			oSheet:SetCellValue("ESC_FER",IIF(aData[15], 1 , 2) )
		Endif
		If oSheet:CellExists("HORAS_NOTURNAS") .And. Alltrim(oSheet:oFWFormula:GetCell("HORAS_NOTURNAS"):Formula) == "=0"
			oSheet:SetCellValue("HORAS_NOTURNAS",aData[13])
		Endif
		If oSheet:CellExists("PARAM_INSALUB")
			oSheet:SetCellValue("PARAM_INSALUB",aData[3])
		Endif
		If oSheet:CellExists("DESC_INSALUB")
			oSheet:SetCellValue("DESC_INSALUB",aData[4])
		Endif
		If oSheet:CellExists("PARAM_GRAUINSALUB")
			oSheet:SetCellValue("PARAM_GRAUINSALUB", aData[1])
		Endif
		If oSheet:CellExists("DESC_GRAU")
			oSheet:SetCellValue("DESC_GRAU", aData[2])
		Endif
		If oSheet:CellExists("PARAM_PERICULOSO")
			oSheet:SetCellValue("PARAM_PERICULOSO", aData[5])
		Endif
		If oSheet:CellExists("DESC_PERICU")
			oSheet:SetCellValue("DESC_PERICU", aData[6])
		Endif
		If oSheet:CellExists("NUM_TOT_PESSOA")
			oSheet:SetCellValue("NUM_TOT_PESSOA", aData[31])
		Endif
		If oSheet:CellExists("METRAGEM_LOCAL")
			oSheet:SetCellValue("METRAGEM_LOCAL", aData[28])
		Endif
		If oSheet:CellExists("PRODUTIVIDADE_RH")
			oSheet:SetCellValue("PRODUTIVIDADE_RH", aData[29])
		Endif
		If oSheet:CellExists("METRAGEM_ATENDI")
			oSheet:SetCellValue("METRAGEM_ATENDI", aData[30])
		Endif
		If oSheet:CellExists("NUMERO_PESSOAS") .And. Alltrim(oSheet:oFWFormula:GetCell("NUMERO_PESSOAS"):Formula) == "=0"
			oSheet:SetCellValue("NUMERO_PESSOAS", aData[18])
		EndIf
		If oSheet:CellExists("PLR_CCT")
			If aData[17] > 0
				oSheet:SetCellValue("PLR_CCT", aData[17])
			EndIf
		EndIf
		If oSheet:CellExists("QTD_INTRA") .And. Alltrim(oSheet:oFWFormula:GetCell("QTD_INTRA"):Formula) == "=0"
			oSheet:SetCellValue("QTD_INTRA", aData[19])
		EndIf
		If oSheet:CellExists("QTD_HORAS")
			If !Empty(aData[7])
				oSheet:SetCellValue("QTD_HORAS", aData[7])
			EndIf
		Endif
		If oSheet:CellExists("DIAS_PER")
			oSheet:SetCellValue("DIAS_PER", aData[21])
		Endif

		//Atualização do total de INSUMOS (MI,MC,UNI,ARM) e FÓRMULA de acordo com a quantidade vendida na TFF:
		If oSheet:CellExists("TOTAL_INSUMOS") .And. (aData[20] > 0)
			If oSheet:GetCellValue("TOTAL_INSUMOS") > 0
				updInsumos(aData[20])
			EndIf
		Endif
	Else
		If oSheet:CellExists("TOTAL_MAT_IMP")
			oSheet:SetCellValue("TOTAL_MAT_IMP", aData[25])
		EndIf
		If oSheet:CellExists("TOTAL_MAT_CONS")
			oSheet:SetCellValue("TOTAL_MAT_CONS", aData[24])
		EndIf
		If oSheet:CellExists("TOTAL_VERBAS")
			oSheet:SetCellValue("TOTAL_VERBAS", aData[27])
		EndIf
	Endif
	If oSheet:CellExists("VLR_SB")
		oSheet:SetCellValue("VLR_SB", aData[32])
	EndIF

	// If lCpoCustom
	// 	ExecBlock('A998CPOUSR', .F., .F., {oMdlRh,oSheet} )
	// EndIf

	cXml := oSheet:GetXmlModel(,,,,.F.,.T.,.F.)
	
	//-- Força o Refresh com LoadXMLModel
	oSheet:LoadXmlModel(cXml)

	If oSheet:CellExists("TX_LR")
		nPLucro := oSheet:GetCellValue("TX_LR")
	EndIf

	If lOrcSrv
		If oSheet:CellExists("TOTAL_CUSTO")
			nTotal := oSheet:GetCellValue("TOTAL_CUSTO")
		Endif
		If oSheet:CellExists("TOTAL_BRUTO")
			nTotPlan := oSheet:GetCellValue("TOTAL_BRUTO")
		Endif
	Else
		If lAbtInss .AND. oSheet:CellExists("TOTAL_ABATE_INS")
			cTotAbINS := oSheet:GetCellValue("TOTAL_ABATE_INS")
		EndIf
		If oSheet:CellExists("TOTAL_RH")
			nTotal := oSheet:GetCellValue("TOTAL_RH")
		Endif
	Endif

	aResult := {cXml, nTotal, nTotPlan, nPLucro, cTotAbINS}
	PutGlbVars(cJobThr+"_ARRAY",aResult)

	RPCClearEnv()
EndIf

//-- Final do processamento da THREAD
PutGlbValue(cJobThr, "EXIT")
GlbUnLock()

Return
