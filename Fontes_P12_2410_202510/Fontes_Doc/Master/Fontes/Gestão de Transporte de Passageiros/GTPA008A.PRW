#include 'GTPA008A.CH'
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"


/*/{Protheus.doc} GTPA008A
Rotina utilizada para integração RM
@type  Function
@author Luiz Gabriel Gomes de Jesus
@since 10/04/2023
@version 1.0
@return oBrowse, Object, Objeto do Browse
/*/

Function GTPA008A()
Local oMBrowse
Local cMarca 		:= IIF(SuperGetMV("MV_GSXINT",,"2") == "3", "RM", "")
Local aFieldsTXB 	:= {}
Local cMsgErro 		:= ''

aFieldsTXB := {'TXB_FILIAL','TXB_COD','TXB_CODTEC','TXB_TEMPO','TXB_DTINI','TXB_DTFIM',;
				'TXB_RESTRI','TXB_MOTIVO','TXB_OBS','TXB_CODGYG'}

If cMarca == "RM" .AND. GTPxVldDic("TXB",aFieldsTXB,.T.,.T.,@cMsgErro)
	If !IsBlind() 
		oMBrowse:= FWmBrowse():New() 
		oMBrowse:SetAlias("GYG")
		oMBrowse:SetDescription(STR0006)   // "Cadastro de Restrições"
		oMBrowse:Activate()
	Else
		GtpRestSdl()
	EndIf 
ElseIf !Empty(cMsgErro)
	FwAlertHelp(cMsgErro,'')
ElseIf cMarca <> "RM" 
	Help(,, "GTPA008A",,STR0007,1,0,,,,,,{STR0008}) //"Rotina utilizada somente para integração RM"##"Para utilizar configure o prametro MV_GSXINT com o valor 3"	
EndIf 

DummyOff()
Return

//----------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Model - Relacionamentos - restrição de cadastro operacional 

@Return 	model
@author	Luiz Gabriel
@since 	17/03/2023
/*/
//----------------------------------------------------------
Static Function ModelDef()

Local oModel		:= Nil
Local oStrGYG 	    := FWFormStruct(1,"GYG")
Local oStrTXBRH 	:= FWFormStruct(1,"TXB")
Local aFieldsTXB 	:= {}
Local cMsgErro		:= ''

aFieldsTXB := {'TXB_FILIAL','TXB_COD','TXB_CODTEC','TXB_TEMPO','TXB_DTINI','TXB_DTFIM',;
				'TXB_RESTRI','TXB_MOTIVO','TXB_OBS','TXB_CODGYG'}
    


If GTPxVldDic("TXB",aFieldsTXB,.T.,.T.,@cMsgErro)
	oModel := MPFormModel():New("GTPA008A", /*bPreValidacao*/,/*bPosValidacao*/,/*bCommit*/,/*bCancel*/ )
	oModel:AddFields("GYGMASTER",/*cOwner*/,oStrGYG, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

	oModel:AddGrid( "TXBDETRH", "GYGMASTER", oStrTXBRH,/*bLinePre*/, ,/*bPreVal*/ ,/*bPosVal*/ , /*bLoad */ )
	oModel:SetRelation( "TXBDETRH", { { "TXB_FILIAL", "xFilial('TXB')" }, { "TXB_CODGYG", "GYG_CODIGO" } }, TXB->(IndexKey(2)) )
	oModel:SetDescription(STR0009) //"Recursos Humanos"

	oStrTXBRH:SetProperty('TXB_CODTEC', MODEL_FIELD_OBRIGAT , .F. )
	oStrTXBRH:SetProperty('TXB_CODGYG', MODEL_FIELD_OBRIGAT , .F. )
	oStrTXBRH:SetProperty("TXB_DTINI", MODEL_FIELD_VALID, {|oModel| Gtp08AVlDt("TXBDETRH","TXB_DTFIM","TXB_DTINI","TXB_DTFIM") } )
	oStrTXBRH:SetProperty("TXB_DTFIM", MODEL_FIELD_VALID, {|oModel| Gtp08AVlDt("TXBDETRH","TXB_DTFIM","TXB_DTINI","TXB_DTFIM") } )
	oStrTXBRH:SetProperty('TXB_DTFIM',MODEL_FIELD_WHEN ,{|| oModel:GetModel("TXBDETRH"):GetValue("TXB_TEMPO") == '2' } )	
	oStrTXBRH:SetProperty("TXB_DMOTIV",MODEL_FIELD_INIT,{|| AllTrim(TABELA("0J", TXB->TXB_MOTIVO, .F.))})

	oModel:GetModel('GYGMASTER'):SetOnlyView(.T.)
	oModel:GetModel('GYGMASTER'):SetOnlyQuery(.T.)
	oModel:GetModel('TXBDETRH'):SetOptional(.T.)
EndIf
Return(oModel)

//----------------------------------------------------------
/*/{Protheus.doc} ViewDef()
View - Relacionamentos - Restrição de cadastro operacional 

@Return 	view
@author	Luiz Gabriel
@since 	17/03/2023
/*/
//----------------------------------------------------------
Static Function ViewDef()

Local oView
Local oModel        := FWLoadModel("GTPA008A")  
Local oStrGYG       := FWFormStruct( 2, "GYG" , {|cCpo| AllTrim(cCpo)$'GYG_CODIGO+GYG_NOME' }  )
Local oStrTXBRH		:= FWFormStruct(2,"TXB",{|cCpo| AllTrim(cCpo) <> "TXB_COD" .and.  !AllTrim(cCpo)$ 'TXB_CODTEC|TXB_NOME|TXB_RESTRI|TXB_CODGYG' } )

oStrGYG:SetNoFolder()

oView := FWFormView():New()
oView:SetModel(oModel)
oView:AddField( 'VIEW_GYG' , oStrGYG, 'GYGMASTER' )
oView:AddGrid ( 'VIEW_TXBRH' , oStrTXBRH, 'TXBDETRH' )

oView:CreateHorizontalBox('SUPERIOR', 10 ) //atendente
oView:CreateHorizontalBox('INFERIOR', 90 ) //restrições

oView:SetOwnerView( 'VIEW_GYG' , 'SUPERIOR' ) 
oView:SetOwnerView( 'VIEW_TXBRH' , 'INFERIOR' )	//"Recursos Humanos"

oView:EnableTitleView('VIEW_TXBRH', STR0010) //"Restrições de RH"
	

Return oView
//----------------------------------------------------------
/*/{Protheus.doc} MenuDef()
MenuDef - Cadastro de Restrições 

@Return 	MenuDef
@author	Luiz Gabriel
@since 	17/03/2023
/*/
//----------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0011 ACTION 'VIEWDEF.GTPA008A'     OPERATION 4 ACCESS 0 //"Manutenção"
ADD OPTION aRotina TITLE STR0012 ACTION 'VIEWDEF.GTPA008A'   OPERATION 2 ACCESS 0 //"Visualização"
ADD OPTION aRotina TITLE STR0013 ACTION 'Gtp08AImpR()' OPERATION 2 ACCESS 0 //"Importação de Restrições"

Return(aRotina)

//------------------------------------------------------------------------------
/*/{Protheus.doc} Gtp08AVlDt
Função para validação dos períodos iniciais e finais das restrições.

@sample 	Gtp08AVlDt(cModelo,cCpoSelec,cCpoDtIn,cCpoDtFm)

@since		15/03/2023     
@version	P12

@return 	lRet, Lógico, retorna .T. se data for válida.

@param  	oModel, Objeto, Model utilizado para a consistencia das informações.
@param  	cModelo, Caracter, nome do modelo de dados principal.
@param  	cCpoSelec, Caracter, nome do campo da data selecionada para validação.
@param  	cCpoDtIn, Caracter, nome do campo da data inicial.
@param  	cCpoDtFm, Caracter, nome do campo da data final.
/*/
//------------------------------------------------------------------------------
Function Gtp08AVlDt(cModelo,cCpoSelec,cCpoDtIni,cCpoDtFim)

Local oModel  := FwModelActive()
Local oMdl		:= oModel:GetModel(cModelo)
Local lRet		:= .T.
Local cCpoAlias := IIF( Left(cModelo,3) <> "TW2", "TXB", "TW2" )

If Empty(oMdl:GetValue(cCpoAlias+'_DTINI'))
	lRet := .F.
	Help(,,"GTPA008A",,STR0014,1,0) // "Data inicial deve ser informada"
Else

	If  oMdl:GetValue(cCpoAlias+'_TEMPO') == '2' //contrato determinado
		If !Empty(oMdl:GetValue(cCpoAlias+'_DTFIM')) .AND. !Empty(oMdl:GetValue(cCpoAlias+'_DTINI'))
			If DtoS(oMdl:GetValue(cCpoDtIni)) > DtoS(oMdl:GetValue(cCpoDtFim))  		
				lRet := .F.
				Help(,,"GTPA008A",,STR0015,1,0) // "Data final deve ser maior ou igual a data inicial da restrição para contratos determinados!"
			EndIf
		Endif
	Elseif oMdl:GetValue(cCpoAlias+'_TEMPO') == '1' //contrato determinado
		If !Empty(oMdl:GetValue(cCpoAlias+'_DTFIM'))
			Help(,,"GTPA008A",,STR0016,1,0) //"Para contratos indeterminados, deixar a data final em branco"
			lRet := .F.
		Endif	
	EndIf
EndIf

Return(lRet)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Gtp08AImpR()
Função para selecionar o tipo e ou atendentes para importação de suas restrições

@return	lOk
@author	Luiz Gabriel
@since 	17/03/2023
/*/
//--------------------------------------------------------------------------------------------------------------------
Function Gtp08AImpR()
Local aStruct		:= {}
Local aIdx			:= {}
Local aSeek			:= {}
Local aInsertTmp	:= {}
Local aColumns		:= {}
Local aFuncionar	:= {}
local aFunc			:= {}
Local lOk			:= .T.
Local nStepCmmIns	:= 900
Local nOpc
Local nX	
Local nY
Local oMrkBrowse	:= FWMarkBrowse():New()
Local oGTPTmpTb		:= Nil

nOpc := Aviso( STR0017, STR0018,{ STR0019, STR0020, STR0021 }, 2 ) //"Importação de Restrições" ## "Como deseja realizar a importação ?" ## "Selecionar Atendentes" ## "Importa Todos" ## "Cancelar" 

If nOpc <> 3
	aFuncionar := Gtp08AColRM()
	If len(aFuncionar) > 0
		If nOpc == 1
			//Cria estrutura e tabela tmp com os campos necessarios
			Aadd(aStruct, {"OK"        	, "C", 1 						, 0						 })
			Aadd(aStruct, {"GYG_FILIAL"	, "C", TamSX3("GYG_FILIAL")[1]	, TamSX3("GYG_FILIAL")[2]})
			Aadd(aStruct, {"GYG_FUNCIO"	, "C", TamSX3("GYG_FUNCIO")[1]	, TamSX3("GYG_FUNCIO")[2]})
			Aadd(aStruct, {"GYG_NOME"	, "C", TamSX3("GYG_NOME")[1]	, TamSX3("GYG_NOME")[2]})
			Aadd(aStruct, {"GYG_CODIGO"	, "C", TamSX3("GYG_CODIGO")[1]	, TamSX3("GYG_CODIGO")[2]})
			
			//Cria indices para a tabela temporária 
			Aadd(aIdx, {"I1",{ 'GYG_FUNCIO' }})
			Aadd(aIdx, {"I2",{ 'GYG_CODIGO'}})
			Aadd(aIdx, {"I5",{ 'GYG_NOME'}})
			
			//Cria array da busca de acordo com os indices da tabela temporária
			aAdd(aSeek, {TxDadosCpo('GYG_FUNCIO')[1]	,{{'','C',TamSX3('GYG_FUNCIO')[1],TamSX3('GYG_FUNCIO')[2],TxDadosCpo('GYG_FUNCIO')[1],PesqPict('GYG','GYG_FUNCIO'),NIL}},1})
			aAdd(aSeek, {TxDadosCpo('GYG_CODIGO')[1]	,{{'','C',TamSX3('GYG_CODIGO')[1],TamSX3('GYG_CODIGO')[2],TxDadosCpo('GYG_CODIGO')[1],PesqPict('GYG','GYG_CODIGO'),NIL}},2})
			aAdd(aSeek, {TxDadosCpo('GYG_NOME')[1]		,{{'','C',TamSX3('GYG_NOME')[1],TamSX3('GYG_NOME')[2],TxDadosCpo('GYG_NOME')[1],PesqPict('GYG','GYG_NOME'),NIL}},5})
			
			//Instancia o método NEW para criação da tabela temporária
			oGTPTmpTb := GSTmpTable():New('RESGYG',aStruct, aIdx, {}, nStepCmmIns )
			cRetTab  := 'RESGYG'
			
			//Validação para a criação da tabela temporária
			If oGTPTmpTb:CreateTMPTable()
				//Preenche Tabela temporária com as informações filtradas
				For nX := 1 To Len(aFuncionar)
					aInsertTmp :={}
					Aadd(aInsertTmp, {'GYG_FILIAL'		,aFuncionar[nX][1]})
					Aadd(aInsertTmp, {'GYG_CODIGO'		,aFuncionar[nX][2]})
					Aadd(aInsertTmp, {'GYG_NOME'		,aFuncionar[nX][3]})
					Aadd(aInsertTmp, {'GYG_FUNCIO'		,aFuncionar[nX][4]})
						
					If oGTPTmpTb:Insert(aInsertTmp)
						lOk := oGTPTmpTb:Commit()
					EndIf

				Next nX
			Else
				oGTPTmpTb:ShowErro()
			EndIf
			
			//MarkBrowse
			For nY := 1 To Len(aStruct)
				If aStruct[nY][1] <> "OK"
					AAdd(aColumns,FWBrwColumn():New())
					aColumns[Len(aColumns)]:SetData( &("{||"+aStruct[nY][1]+"}") )
					aColumns[Len(aColumns)]:SetTitle(RetTitle(aStruct[nY][1]))
					aColumns[Len(aColumns)]:SetSize(aStruct[nY][3])
					aColumns[Len(aColumns)]:SetDecimal(aStruct[nY][4])
					aColumns[Len(aColumns)]:SetPicture(PesqPict(cRetTab,aStruct[nY][1]))
				EndIf
			Next nY
		
			DEFINE MSDIALOG oDlg TITLE STR0022 From 300,0 To 700,1000 PIXEL //"Colaboradores disponiveis para importação de restrições"
			oMrkBrowse:SetOwner(oDlg)
			oMrkBrowse:DisableFilter()
			
			oMrkBrowse:SetDescription(STR0023) //"Importa Restrições do colaborador"
			oMrkBrowse:SetTemporary(.T.)     	
			oMrkBrowse:AddButton(STR0024,{|| GTP08ACol(aFunc),oDlg:End(), oMrkBrowse:Refresh(.T.) },,3,)		//"Importa"
			oMrkBrowse:AddButton(STR0025, {|| GTP08ACol(aFuncionar ),oDlg:End(), oMrkBrowse:Refresh(.T.)},,3,) // "Importa Todos"
			oMrkBrowse:SetFieldMark("OK")
			oMrkBrowse:SetAlias(cRetTab) //Seta o arquivo temporario para exibir a seleção dos dados
			oMrkBrowse:SetSeek(.T., aSeek) 
			oMrkBrowse:SetAllMark( { || oMrkBrowse:AllMark() } )
			oMrkBrowse:bMark := {||GTP08AMark(oMrkBrowse,cRetTab, @aFunc)}	        
			oMrkBrowse:SetColumns(aColumns)
			oMrkBrowse:DisableReport()
			oMrkBrowse:SetMenuDef("")
			oMrkBrowse:DisableDetails()
			oMrkBrowse:Activate(oDlg)
			ACTIVATE MSDIALOG oDlg CENTERED	
			
			oGTPTmpTb:Close()
			TecDestroy(oGTPTmpTb)			 
		ElseIf nOpc == 2
			GTP08ACol(aFuncionar)   
		EndIf
	Else
		Help( ,, 'At012ImpRes',, STR0026, 1, 0) // "Nenhum Atentende Retornado!"
	EndIf
Else
	MSGInfo(STR0027, STR0028 ) //"A operação foi cancelada!" ## "Operação Cancelada" 
EndIf
Return lOk

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Gtp08AColRM()
Função para retorno dos funcionarios disponiveis na base

@return	aFunc funcionarios disponiveis
@author	Luiz Gabriel
@since 	17/03/2023
/*/
//--------------------------------------------------------------------------------------------------------------------
Function Gtp08AColRM()
Local aArea		:= GetArea()
Local aFunc		:= {}
Local cAliasGYG	:= GetNextAlias()

BeginSql Alias cAliasGYG
	Select 
		GYG.GYG_FILIAL,GYG.GYG_CODIGO, GYG.GYG_NOME, GYG.GYG_FUNCIO
	from 
		%Table:GYG% GYG
	WHERE 
		GYG.%notdel%
		AND GYG.GYG_FILIAL = %xfilial:GYG%
		AND GYG.GYG_FUNCIO <> ''
EndSql

While (cAliasGYG)->(! Eof())
	aAdd(aFunc,{ (cAliasGYG)->GYG_FILIAL,;
	             (cAliasGYG)->GYG_CODIGO,;
	             (cAliasGYG)->GYG_NOME,;
	             (cAliasGYG)->GYG_FUNCIO})
	(cAliasGYG)->(DbSkip())
EndDo
(cAliasGYG)->(DbCloseArea())

RestArea(aArea)
Return (aFunc)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTP08AMark(oMrkBrowse,cRetTab,aFunc)
Função para selecionar os funcionarios

@return	
@author	Luiz Gabriel
@since 	17/03/2023
/*/
//--------------------------------------------------------------------------------------------------------------------
Function GTP08AMark(oMrkBrowse,cRetTab,aFunc)
Local aArea		:= GetArea()
Local aAux		:= {}
Local cMarca	:= ""
Local cCodigo	:= (cRetTab)->GYG_CODIGO
Local nX

DbSelectArea(cRetTab)
  
cMarca := oMrkBrowse:Mark() 
	RecLock(cRetTab, .F.)
		
If (cRetTab)->OK <> cMarca
	(cRetTab)->OK := ' '
	For nX := 1 To Len(aFunc)
		Iif (aFunc[nX][2] <> cCodigo, AADD(aAux, aFunc[nX]),nil)
	Next nX
	aFunc	:= ACLONE(aAux)
Else
	(cRetTab)->OK := cMarca
	AADD(aFunc, {(cRetTab)->GYG_FILIAL, (cRetTab)->GYG_CODIGO, (cRetTab)->GYG_NOME, (cRetTab)->GYG_FUNCIO}  )
EndIf
MsUnlock()
(cRetTab)->(DbSkip())

RestArea(aArea)

Return

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTP08ACol(aFunc)
Função cria regua para mostrar o andamento do processo

@return	
@author	Luiz Gabriel
@since 	17/03/2023
/*/
//--------------------------------------------------------------------------------------------------------------------
Function GTP08ACol(aFunc)
Local nTotal	:= 0
Local nMeter
Local oDlg
Local oMeter
Local oSayMtr

Default aFunc := {}

nTotal := Len(aFunc)
DEFINE MSDIALOG oDlg FROM 0,0 TO 5,60 TITLE STR0029 //"Importação de Restrições"
	nMeter := 0
	oSayMtr := tSay():New(10,10,{||STR0030},oDlg,,,,,,.T.,,,220,20) //"Processando, aguarde..."
	oMeter  := tMeter():New(20,10,{|u|if(Pcount()>0,nMeter:=u,nMeter)},Len(aFunc),oDlg,220,10,,.T.) // cria a régua
	
ACTIVATE MSDIALOG oDlg CENTERED ON INIT (GTP08AResWS(aFunc, oDlg, oMeter, oSayMtr, .F. ))

Return

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTP08AResWS(aFunc, oDlg, oMeter, oSayMsg, oSayMtr)
Função de chama do webservice e da gravação na TXB

@return	
@author	Luiz Gabriel
@since 	17/03/2023
/*/
//--------------------------------------------------------------------------------------------------------------------
Function GTP08AResWS(aFunc, oDlg, oMeter, oSayMtr, lJob)
Local aErrors 	:= {}
Local aGeral	:= {}
Local aRet 		:= {}
Local cMsg		:= ""
Local cMsgErro	:= ""
Local cMotivo	:= ""
Local cCodCol	:= ""
Local cCdFunc	:= ""
Local cNomCol	:= ""
Local lOk		:= .T.
Local lFalha	:= .F.
Local nFunc		:= Len(aFunc)
Local nFalhaA 	:= 0
Local nFalhaR	:= 0
Local nReg		:= 0
Local nInclu	:= 0
Local nLoop		:= 0
Local nTotLoop	:= 0
Local nTotalF	:= 0
Local nTotalI	:= 0
Local nX
Local nY
Local oModel	:= Nil 

If nFunc > 0
	cCodCol	:= aFunc[1][2]
	cCdFunc	:= aFunc[1][4]
	cNomCol	:= aFunc[1][3]
	
	oModel	:= FwLoadModel("GTPA008A")

	For nX := 1 To nFunc
		aRet := GTP08AInRes("FopFuFeriasPerData", "PFUFeriasPer.CHAPA=" + aFunc[nX][4], "RM", @cMsgErro, aFunc[nX][4] )
		If Len(aRet) > 0
			aAdd(aGeral, aClone(aRet))
		EndIf
		aRet :=  GTP08AInRes("FopHstAftData", "PFHstAft.CHAPA=" + aFUNC[nX][4], "RM", @cMsgErro, aFunc[nX][4] )
		If Len(aRet) > 0
			aAdd(aGeral, aClone(aRet))
		EndIf
		aRet := GTP08AInRes("FopRescisaoData", "PFunc.DataDemissao>'' and pfunc.chapa=" + aFUNC[nX][4], "RM", @cMsgErro, aFunc[nX][4] )
		If Len(aRet) > 0
			aAdd(aGeral, aClone(aRet))
		EndIf
	Next nX
	Begin Transaction
		For nX := 1 To Len(aGeral)
			If 	aGeral[nX][1][1] <> cCdFunc
				For nY := 1	To nFunc
					If (aGeral[nX][1][1] == aFunc[nY][4]) .Or. DummyOn()
						If lFalha
							nFalhaA++
							lFalha := .F.
						EndIf
						cCodCol := aFunc[nY][2]
						cCdFunc	:= aFunc[ny][4]
						cNomCol	:= aFunc[nY][3]
						Exit
					EndIf
				Next nY
			EndIf	
			lOk	:= GTP08AResAll(aGeral[nX], cCodCol, @nInclu, @nFalhaR, @nLoop, oModel, @cMotivo)
			
			If ( !lJob .And. (!lOk .OR. !Empty(cMotivo)) .Or. DummyOn())
				AAdd(aErrors, { STR0031	+ cNomCol					 	,;	// "Nome: "
								STR0032	+ aGeral[nX][1][1]			 	,;	// "Codigo do Colaborador: "
								STR0033	+ aGeral[nX][1][6]			 	,;	// "Ao tentar cadastrar: "
								STR0034	+ cValtoChar(Len(aGeral[nX]))	,;	// "Total de Restrições: "
								STR0035	+ cValToChar(nInclu)		 	,;	// "Restrições inseridas: "
								STR0036	+ cValToChar(nFalhaR)		 	,;	// "Restrições com falhas: "
								cMotivo })
				lFalha := .T.
				cMotivo := ""
			EndIf
			
			If nReg <> nFunc
				nReg++
			EndIf
			
			If !lJob
				oMeter:Set(nReg)
				oSayMtr:SetText(STR0037 + cValToChar(nReg) + STR0038 + cValToChar(oMeter:nTotal) + STR0039) //"Importando... "  ## " de " ## " funcionarios com restrições"
				oMeter:Refresh()
				oSayMtr:CtrlRefresh()
				SysRefresh()
			EndIf 

			nTotalF	+= nFalhaR
			nTotalI += nInclu
			nTotLoop += nLoop
			nInclu 	:= 0
			nFalhaR := 0
			nLoop	:= 0
		Next nX
	End Transaction
	
	IF lFalha
		nFalhaA++
	EndIf
	cMsg += STR0040  + cValToChar(( nFunc )) + CRLF // "Total de Colaborador(s) com suas Restrições: " 
	If nTotLoop + nTotalF + nTotalI > 0
	cMsg += STR0041  + cValToChar(nFunc - nFalhaA) + CRLF // "Restrições de Colaborador(s) adicionados: " 
	cMsg += STR0042 + cValToChar(nFalhaA) + CRLF + CRLF // ""Colaborador(s) com falha(s) na inclusão de restrições: "
	Else
		cMsg += CRLF + CRLF
	EndIf
	If LEN(aErrors) > 0
		cMsg += STR0043 + CRLF + CRLF // "Os colaboradores abaixo tiveram algum erros na inclusão das restrições: "
		cMsg += REPLICATE("-",50) + CRLF
		
		For nX := 1 To LEN(aErrors)
			For nY := 1 To LEN(aErrors[nX])
				cMsg += aErrors[nX][nY] + CRLF
			Next nY
			cMsg += CRLF + REPLICATE("-",50) + CRLF
		Next nX
		cMsg += CRLF
	EndIf
	cMsg += STR0044 + cValtoChar(nTotLoop + nTotalF + nTotalI) // "Quantidade de Registro processados: "
	cMsg += CRLF + STR0045 + cValToChar(nTotalI ) // "Registro(s) incluido(s): "
	cMsg += CRLF + STR0046 + cValToChar(nTotalF) // "Registro(s) com falha(s): "
	cMsg += CRLF + STR0047 + cValToChar(nTotLoop) + CRLF // "Registro(s) duplicado(s) não inserido(s): "
	cMsg += CRLF + cMsgErro
	If !lJob
		AtShowLog(cMsg,STR0048,/*lVScroll*/,/*lHScroll*/,/*lWrdWrap*/,.F.) // "Importa Restrições"
	EndIf
	oModel:DeActivate()	
Else
	If !lJob
		Help(,,"GTP08AResWS",,STR0049 ,1,0) // "Nenhum colaborador selecionado"
	EndIf 	 
EndIf


If !lJob
	oDlg:End()
EndIf 

Return

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTP08AInRes(cName, cFiltro, cMarca, cMsgErro)
Função de gravação do webservice para ser usada na TXB

@return	aRet - retorno dos dados do webservice
@author	Luiz Gabriel
@since 	17/03/2023
/*/
//--------------------------------------------------------------------------------------------------------------------
Function GTP08AInRes(cName, cFiltro, cMarca, cMsgErro, cChapa)
Local aRet		:= {}
Local aRestri	:= {}
Local aAux		:= {}
Local cRet		:= ""
Local cWarning 	:= ""
Local cError 	:= ""
Local cCodFilRM	:= ""
Local cMotivo	:= ""
Local cTipo		:= "1"
Local dDataF	:= ""
Local lRet		:= .T.
Local nX
Local oRet		:= Nil
Local oWS 		:= NIL

oWS := GTPItRMWS(cMarca, .F., @cMsgErro, @cCodFilRM)

If oWS <> NIL
	oWS:cFiltro := cFiltro
	oWS:cDataServerName := cName
	oWS:ReadView()
	
	cRet	:= oWS:cReadViewResult  // pega o retorno se deu certo		
	
	If !Empty(cRet) .AND. cRet <> "<NewDataSet />"
		oRet := XMLParser( cRet, "_", @cError, @cWarning)
		cError := IIf(XMLDummyOn(),"Dummy Ligado",cError)
		If Empty(cError)
			If cName == "FopFuFeriasPerData"
				aAux := XmlChildEx ( oRet:_NEWDATASET, "_PFUFERIASPER")
				If ValType(aAux) <> Nil
					IIf(Valtype(aAux) == "O",	aAdd(aRestri, aAux),;
						IIf(Valtype(aAux) == "A",aRestri := aClone(aAux),nil))
					If lRet
						For nX := 1 To Len(aRestri)
							If XmlChildEx ( aRestri[nX], "_NRODIASABONO" ) <>  Nil
								cMotivo	:= STR0051 + ALLTRIM(aRestri[nx]:_NRODIASABONO:TEXT) //"Numero de dias abonados: "
							EndIf
							AADD(aRet, {PADR(aRestri[nx]:_CHAPA:TEXT, TamSX3("AA1_CDFUNC")[1]),;
										"2",;
										StoD(Strtran(Left(aRestri[nx]:_DATAINICIO:TEXT, 10), "-")),;														
										"02",;																												
										"2",;																												
										STR0052,; 																											// "Ferias"
										StoD(Strtran(Left(aRestri[nx]:_DATAFIM:TEXT, 10), "-")),;															
										STR0053 + ALLTRIM(aRestri[nx]:_SITUACAOFERIAS:TEXT) + CRLF + STR0054 + ALLTRIM(aRestri[nx]:_NRODIASFERIAS:TEXT) +;	// "Situação: " ## "Numero de dia de ferias: "
										CRLF + STR0053 + ALLTRIM(aRestri[nx]:_IMAGEMSITUACAO:TEXT) + CRLF +;												// "Situação: "
										STR0055	 + cValToChar(Stod(Strtran(Left(aRestri[nx]:_DATAPAGTO:TEXT, 10), "-"))) + CRLF + cMotivo }) 				//"Data do pagamento: "						
						Next nX
					EndIf
				EndIf
			ElseIf cName == "FopHstAftData"
				aAux := XmlChildEx ( oRet:_NEWDATASET, "_PFHSTAFT")
				If ValType(aAux) <> Nil
					IIf(Valtype(aAux) == "O",	aAdd(aRestri, aAux),;
						IIf(Valtype(aAux) == "A",aRestri := aClone(aAux),nil))
					If lRet
						For nX := 1 To Len(aRestri)
							If XmlChildEx ( aRestri[nX], "_OBSERVACAO" ) <>  Nil
								cMotivo	:= STR0057  + ALLTRIM(aRestri[nx]:_OBSERVACAO:TEXT) + CRLF // "Observação: " 
							EndIf
							If XmlChildEx ( aRestri[nX], "_DTFINAL" ) <>  Nil
								dDataF	:= aRestri[nx]:_DTFINAL:TEXT
								cTipo	:= "2"
							EndIf
							
							AADD(aRet, {PADR(aRestri[nx]:_CHAPA:TEXT, TamSX3("AA1_CDFUNC")[1]),;
										cTipo,;
										StoD(Strtran(Left(aRestri[nx]:_DTINICIO:TEXT, 10), "-")),;
										"04",;
										"2",;
										STR0058,; 
										StoD(Strtran(Left(dDataF, 10), "-")),;
										cMotivo + STR0059 + ALLTRIM(aRestri[nx]:_DESCAFAST:TEXT) + CRLF +;
										STR0060 + ALLTRIM(aRestri[nx]:_DESCMOTIVO:TEXT)}) /*"Afastamento"*/ // "Descrição do Afastamento: " ## "Descrição do motivo: "						
							dDataF := ""
							cTipo 	:= "1"
						Next nX
					EndIf
				EndIf
			ElseIF cName == "FopRescisaoData"
				aAux := XmlChildEx ( oRet:_NEWDATASET, "_PFUNC")
				If ValType(aAux) <> Nil
					IIf(Valtype(aAux) == "O",	aAdd(aRestri, aAux),;
						IIf(Valtype(aAux) == "A",aRestri := aClone(aAux),nil))
					If lRet
						For nX := 1 To Len(aRestri)
							dDataF := ""
							AADD(aRet, {	PADR(aRestri[nx]:_CHAPA:TEXT, TamSX3("AA1_CDFUNC")[1]),;
											"1",;
											StoD(Strtran(Left(aRestri[nx]:_DATADEMISSAO:TEXT, 10), "-")),;
											"03",;
											"2",;
											STR0061,;
											StoD(Strtran(Left(dDataF, 10), "-")),; 
											STR0062 + cValToChar(Stod(Strtran(Left(aRestri[nx]:_DATADEMISSAO:TEXT, 10), "-")))+ CRLF + "Motivo da demissão: " + ALLTRIM(aRestri[nx]:_MOTIVODEMISSAO:TEXT) + CRLF +;
											STR0063  + cValToChar(Stod(Strtran(Left(aRestri[nx]:_DTDESLIGAMENTO:TEXT, 10), "-")))}) /*"Demissão"*/ // "Tipo de demissão: " ## "Motivo da demissão: " ## "Data do desligamento: " 
						Next nX
					EndIf
				EndIf
			EndIf
		Else
			cMsgErro	+= cError
		EndIF
	EndIf
	FreeObj(oWS)
	oWS := NIL
EndIf

Return aRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTP08AResAll(aGeral, cCodCol, nInclu, nFalhaR, nLoop)
Função de gravação na TXB

@return	lOk - (.T.) gravou, (.F.) falha
@author	Luiz Gabriel
@since 	17/03/2023
/*/
//--------------------------------------------------------------------------------------------------------------------
Function GTP08AResAll(aGeral, cCodCol, nInclu, nFalhaR, nLoop, oModel, cMotivo)
Local aRotAuto	:= {}
Local aBusca 	:= {}
Local lOk		:= .T.
Local lLoop		:= .F.
Local nLinha	:= 0
Local nRegistro	:= Len(aGeral)
Local nX
Local nY
Local oModelTXB	:= Nil

GYG->(DbSetOrder(1))

If GYG->(DbSeek(xFilial("GYG")+cCodCol))
	
	oModel:SetOperation( MODEL_OPERATION_UPDATE )	
	oModel:Activate()
	oModelTXB := oModel:GetModel("TXBDETRH")
	For nY := 1 To Len(aGeral)
		aAdd(aBusca,{"TXB_CODGYG",cCodCol})
		aAdd(aBusca,{"TXB_DTINI", aGeral[nY][3]})
		aAdd(aBusca,{"TXB_MOTIVO", aGeral[nY][4]})
		If oModelTXB:SeekLine(aBusca,,.T. )
			If oModelTXB:GetValue("TXB_TEMPO") == "2" .And. !Empty(aGeral[nY][7])
				If oModelTXB:GetValue("TXB_DTFIM") <> aGeral[nY][7] 
					oModelTXB:SetValue("TXB_TEMPO", "2")
					oModelTXB:SetValue("TXB_DTFIM", aGeral[nY][7])
					nInclu++
					Loop
				EndIf
			EndIf
			lLoop := .T.
		Endif
		If lLoop
			lLoop := .F.
			nLoop++
			aBusca := {}
			Loop
		Else
			aBusca := {}
			nLinha := oModelTXB:AddLine()
			oModelTXB:GoLine(nLinha)
			nInclu++
		EndIf

		aAdd(aRotAuto,{"TXB_TEMPO"	,	aGeral[nY][2]})
		aAdd(aRotAuto,{"TXB_DTINI"	,	aGeral[nY][3]})
		aAdd(aRotAuto,{"TXB_MOTIVO"	,	aGeral[nY][4]})
		aAdd(aRotAuto,{"TXB_RESTRI"	,	aGeral[nY][5]})
		If aGeral[nY][2] == "2"
			aAdd(aRotAuto,{"TXB_DTFIM",	aGeral[nY][7]})
			If (aGeral[nY][3] > aGeral[nY][7]) .Or. DummyOn()
				nFalhaR++
				nInclu--
				cMotivo := STR0064  + aGeral[nY][6] + ": " + CRLF // "Erro ao cadastrar " 
				cMotivo += STR0065 + DToC(aGeral[nY][7]) + STR0066 + DToC(aGeral[nY][3]) + STR0067 // "Data final ( " ## " ) deve ser maior que a data inicial ( "
				nLoop++
				Loop  
			EndIf
		EndIf
		AaDd(aRotAuto, {"TXB_OBS",	aGeral[nY][8]})
		If lOk	
			For nX := 1 to LEN(aRotAuto)
 				If !(oModelTXB:SetValue(aRotAuto[nX][1],aRotAuto[nX][2])) .Or. DummyOn()
					nFalhaR++
					nInclu--
				EndIf
			Next nX
		EndIf		
		aRotAuto := {}
	Next nY
	If nRegistro == nLoop 
		lOk := .T.
	Else 
		lOk := oModel:VldData() .AND. oModel:CommitData()			
	EndIf
EndIf
oModel:deActivate()
Return lOk

/*/{Protheus.doc} GtpRestSdl
Função a ser chamada pelo Schedule
@author Luiz.jesus
@since 06/04/2023
/*/
Function GtpRestSdl()
Local aFuncionar	:= Gtp08AColRM()

GTP08AResWS(aFuncionar, Nil, Nil, Nil, .T. )

Return


/*/{Protheus.doc} SchedDef
Retorna informacoes de definicao dos parametros do schedule.
@author Luiz.jesus
@since 06/04/2023
@version 1.0
@Return  Array com as informacoes de definicao dos parametros do schedule
		 Array[x,1] -> Caracter, Tipo: "P" - para Processo, "R" - para Relatorios
		 Array[x,2] -> Caracter, Nome do Pergunte
		 Array[x,3] -> Caracter, Alias(para Relatorio)
		 Array[x,4] -> Array, Ordem(para Relatorio)
		 Array[x,5] -> Caracter, Titulo(para Relatorio)
/*/
Static Function SchedDef()
Local aParam := { "P", "PARAMDEF", Nil, Nil, Nil }

Return aParam

Static Function DummyOn()

	Local bExec := {;
		|lOn| lOn := ValType(GTPDummyVal()) == "N",;
		IIf(!lOn,GTPDummyOn(0),nil),;
		GTPDummyRunning();
	}

	lRet := IIf(FindFunction("GTPDUMMYON"),Eval(bExec),.F.)

Return(lRet)

Static Function DummyOff()
		
Return(Iif(FindFunction("GTPDUMMYOFF"),GTPDummyOff(),Nil))

Static Function XMLDummyOn()
//XMLDUMMYON -> LIGADO, FORÇA ERRO DO XML, CADASTRAR PARÂMETRO
Return(GTPGetRules("XMLDUMMYON",,,.f.))


