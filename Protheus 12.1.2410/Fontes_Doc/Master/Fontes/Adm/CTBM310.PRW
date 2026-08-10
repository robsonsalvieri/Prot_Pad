#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include 'CTBM310.CH'
//
Function CTBM310()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetAlias("QLE")
oBrowse:SetDescription( STR0001 )  //"Cadastro para Limpeza de Procedures Dinamicas"

oBrowse:Activate()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de Dados

@author Totvs

@since 12/09/2022
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function ModelDef()
Local oModelQLE
Local oStructQLE:= FWFormStruct(1,'QLE')

oModelQLE := MPFormModel():New('CTBM310',/*PreValidacao*/,{ |oModelQLE|CTBM310OK(oModelQLE)}/*PosValidacao*/)
oModelQLE:SetDescription( STR0001 )  //"Cadastro para Limpeza de Procedures Dinamicas"


oModelQLE:addFields('MasterQLE',,oStructQLE)
oModelQLE:SetPrimaryKey({ 'QLE_FILIAL', 'QLE_CODSEQ' })

Return oModelQLE

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição do interface

@author Totvs

@since 12/09/2022
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function ViewDef()
Local oView
Local oModelQLE := ModelDef()
Local oStructQLE:= FWFormStruct(2,'QLE')

oView := FWFormView():New()
oView:SetModel(oModelQLE)

oView:AddField('Master_QLE' , oStructQLE,'MasterQLE' )

oView:EnableTitleView('Master_QLE' , STR0001 )  //"Cadastro de Limpeza de Procedures Dinamicas"

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} MENUDEF()
Função para criar do menu

@author Totvs
@since 12/09/2022
@version 1.0
@return aRotina
/*/
//-------------------------------------------------------------------

Static Function MenuDef()
Local aRotina := {} //Array utilizado para controlar opcao selecionada

ADD OPTION aRotina TITLE STR0002 	ACTION "VIEWDEF.CTBM310"	OPERATION 2		ACCESS 0      //"Visualizar"
ADD OPTION aRotina TITLE STR0003 	ACTION "VIEWDEF.CTBM310"	OPERATION 3  	ACCESS 0      //"Incluir"
ADD OPTION aRotina TITLE STR0004	ACTION "VIEWDEF.CTBM310"	OPERATION 4 	ACCESS 0      //"Alterar"
ADD OPTION aRotina TITLE STR0005    ACTION "VIEWDEF.CTBM310"	OPERATION 5  	ACCESS 3 	   //"Excluir"
ADD OPTION aRotina TITLE STR0006 	ACTION "VIEWDEF.CTBM310" 	OPERATION 8 	ACCESS 0 	   //"Imprimir"
ADD OPTION aRotina TITLE STR0018    ACTION "VIEWDEF.CTBM310"    OPERATION 9     ACCESS 0       //""Copiar""
ADD OPTION aRotina TITLE STR0017 	ACTION "CTM310LIMP()" 	    OPERATION 9 	ACCESS 0 	   //"limp.Proc.Dinam."

Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} CTBM310OK()
Função para validar se o codigo Sequencial já existe

@author TOTVS
@since 13/09/2022
@version 1.0
@return lRet
/*/
//-------------------------------------------------------------------
Static Function CTBM310OK(oModelQLE)
Local lRet := .T.
Local nOpc		:= oModelQLE:GetOperation()
Local aArea	:= Getarea()
Local aAreaQLE	:= QLE->(Getarea())
Local oModelQLEQLE			:= oModelQLE:GetModel('MasterQLE')

Default oModelQLE := Nil

If (nOpc == 3 ) .And. QLE->(dbSeek(xFilial("QLE")+oModelQLEQLE:GetValue('QLE_CODSEQ')))
	lRet := .F.
	Help(" ",1,"CTBM310OK","",STR0007,1,0) //"Código Sequencial já cadastrado"
EndIf

If nOpc == 4
 iF oModelQLEQLE:GetValue('QLE_CODSEQ') != QLE->QLE_CODSEQ .and.  QLE->(dbSeek(xFilial("QLE")+oModelQLEQLE:GetValue('QLE_CODSEQ')))
	lRet := .F.
	Help(" ",1,"CTBM310OK","",STR0007,1,0) //"Código Sequencial já cadastrado"
 EndIf
Endif
RestArea( aAreaQLE )
RestArea( aArea )

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} CTM310LIMP()
Função para executar as funcoes de limpeza de procedures e registros na tabela QLE-Controle limpeza Procedures Dinamicas

@author TOTVS
@since 13/09/2022
@version 1.0
@return lRet
/*/
//-------------------------------------------------------------------

Function CTM310LIMP()

If AliasIndic("QLE")
	Ct310ProcL()
	Ct310LmpReg()
EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} Ct310MInc()
Função para criar registros na tabela QLE-ConIf FindFunction("CTM310LIMP") .And. AliasIndic("QLE")trole limpeza Procedures Dinamicas

@author TOTVS
@since 13/09/2022
@version 1.0
@return lRet
/*/
//-------------------------------------------------------------------

Function Ct310MInc(cNomePrc, cRotina, cDscRot)
Local lRet 	:= .T.
Local aArea := GetArea()
Local oModelQLE:= Nil

Default cNomePrc  := ""
Default cRotina  := ""
Default cDscRot  := ""

dbSelectArea("QLE")
QLE->(dbSetOrder(1)) //QLE_FILIAL + QLE_CODSEQ

If !Empty(cNomePrc)
	oModelQLE := FWLoadModel( 'CTBM310' )
	oModelQLE:SetOperation( 3 ) // Inclusão
	oModelQLE:Activate() // Ativa o modelo com os dados posicionados

	oModelQLE:SetValue("MasterQLE","QLE_NOMEPR", cNomePrc )
	oModelQLE:SetValue("MasterQLE","QLE_ROTINA", cRotina )
	oModelQLE:SetValue("MasterQLE","QLE_DESCRT", cDscRot )
	oModelQLE:SetValue("MasterQLE","QLE_STATUS", '0' )
	oModelQLE:SetValue("MasterQLE","QLE_DTCRIA", Date() )
	oModelQLE:SetValue("MasterQLE","QLE_HRCRIA", Time() )
	oModelQLE:SetValue("MasterQLE","QLE_USRCRI", RetCodUsr() )

	If ( lRet := oModelQLE:VldData() )
		// Se o dados foram validados faz-se a gravação efetiva dos dados (commit)
		oModelQLE:CommitData()
		ConfirmSX8()
	Else
		aErro   := oModelQLE:GetErrorMessage()
		AutoGrLog( STR0008 + ' [' + AllToChar( aErro[1]  ) + ']' )//"Id do formulário de origem:"
		AutoGrLog( STR0009 + ' [' + AllToChar( aErro[2]  ) + ']' )//"Id do campo de origem:     "
		AutoGrLog( STR0010 + ' [' + AllToChar( aErro[3]  ) + ']' )//"Id do formulário de erro:  "
		AutoGrLog( STR0011 + ' [' + AllToChar( aErro[4]  ) + ']' )//"Id do campo de erro:       "
		AutoGrLog( STR0012 + ' [' + AllToChar( aErro[5]  ) + ']' )//"Id do erro:                "
		AutoGrLog( STR0013 + ' [' + AllToChar( aErro[6]  ) + ']' )//"Mensagem do erro:          "
		AutoGrLog( STR0014 + ' [' + AllToChar( aErro[7]  ) + ']' )//"Valor atribuido:           "
		AutoGrLog( STR0015 + ' [' + AllToChar( aErro[8]  ) + ']' )//"Valor atribuido[]:         "
		AutoGrLog( STR0016 + ' [' + AllToChar( aErro[9]  ) + ']' )//"Valor anterior:            "
		If !IsBlind()
			MostraErro()
		EndIf
	EndIf
	// Desativamos o Model
	oModelQLE:DeActivate()
EndIf

RestArea(aArea)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Ct310MAtlz()
Função para atualizar registros na tabela QLE-Controle limpeza Procedures Dinamicas

@author TOTVS
@since 13/09/2022
@version 1.0
@return lRet
/*/
//-------------------------------------------------------------------

Function Ct310MAtlz(cNomePrc)
Local lRet 	:= .T.
Local aArea := GetArea()
Local aAreaQLE := QLE->( GetArea() )
Local oModelQLE:= Nil

Default cNomePrc  := ""

dbSelectArea("QLE")
QLE->(dbSetOrder(2)) //QLE_FILIAL + QLE_NOMEPR + QLE_STATUS

If !Empty(cNomePrc) .And. QLE->(dbSeek( xFilial("QLE")+PadR(cNomePrc, Len(QLE->QLE_NOMEPR))+"0"))
	oModelQLE := FWLoadModel( 'CTBM310' )
	oModelQLE:SetOperation( 4 ) // Alteracao
	oModelQLE:Activate() // Ativa o modelo com os dados posicionados

	oModelQLE:SetValue("MasterQLE","QLE_DTEXCL", Date() )
	oModelQLE:SetValue("MasterQLE","QLE_HREXCL", Time() )
	oModelQLE:SetValue("MasterQLE","QLE_STATUS", '1' )

	If ( lRet := oModelQLE:VldData() )
		// Se o dados foram validados faz-se a gravação efetiva dos dados (commit)
		oModelQLE:CommitData()
	Else
		aErro   := oModelQLE:GetErrorMessage()
		AutoGrLog( STR0008 + ' [' + AllToChar( aErro[1]  ) + ']' )//"Id do formulário de origem:"
		AutoGrLog( STR0009 + ' [' + AllToChar( aErro[2]  ) + ']' )//"Id do campo de origem:     "
		AutoGrLog( STR0010 + ' [' + AllToChar( aErro[3]  ) + ']' )//"Id do formulário de erro:  "
		AutoGrLog( STR0011 + ' [' + AllToChar( aErro[4]  ) + ']' )//"Id do campo de erro:       "
		AutoGrLog( STR0012 + ' [' + AllToChar( aErro[5]  ) + ']' )//"Id do erro:                "
		AutoGrLog( STR0013 + ' [' + AllToChar( aErro[6]  ) + ']' )//"Mensagem do erro:          "
		AutoGrLog( STR0014 + ' [' + AllToChar( aErro[7]  ) + ']' )//"Valor atribuido:           "
		AutoGrLog( STR0015 + ' [' + AllToChar( aErro[8]  ) + ']' )//"Valor atribuido:           "
		AutoGrLog( STR0016 + ' [' + AllToChar( aErro[9]  ) + ']' )//"Valor anterior:            "
	EndIf

	// Desativamos o Model
	oModelQLE:DeActivate()
EndIf

RestArea(aAreaQLE)
RestArea(aArea)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Ct310limpa()
Função para limpar as procedures listadas na tabela QLE-Controle limpeza Procedures Dinamicas

@author TOTVS
@since 13/09/2022
@version 1.0
@return lRet
/*/
//-------------------------------------------------------------------

Function Ct310Limpa(cNomePrc, lTabSeek, nRegQLE)
Local lRet 	:= .T.
Local aArea := GetArea()
Local aAreaQLE := QLE->( GetArea() )
Local oModelQLE:= Nil

Default cNomePrc  := ""
Default lTabSeek := .T.  //Faz dbSeek
Default nRegQLE  := 0

dbSelectArea("QLE")
QLE->(dbSetOrder(2)) //QLE_FILIAL + QLE_NOMEPR + QLE_STATUS

If !Empty(cNomePrc)
	If lTabSeek .Or. nRegQle == 0
		QLE->(dbSeek( xFilial("QLE")+PadR(cNomePrc, Len(QLE->QLE_NOMEPR))))
	Else
		//ja sabe o registro e posiciona no registro sem dar dbSeek
		QLE->( dbGoto( nRegQLE ))
	EndIf
	oModelQLE := FWLoadModel( 'CTBM310' )
	oModelQLE:SetOperation( 4 ) // Alteracao
	oModelQLE:Activate() // Ativa o modelo com os dados posicionados

	oModelQLE:SetValue("MasterQLE","QLE_DTLIMP", Date() )
	oModelQLE:SetValue("MasterQLE","QLE_HRLIMP", Time() )
	oModelQLE:SetValue("MasterQLE","QLE_USLIMP", RetCodUsr() )
	oModelQLE:SetValue("MasterQLE","QLE_STATUS", '2' )

	If ( lRet := oModelQLE:VldData() )
		// Se o dados foram validados faz-se a gravação efetiva dos dados (commit)
		oModelQLE:CommitData()
	Else
		aErro   := oModelQLE:GetErrorMessage()
		AutoGrLog( STR0008 + ' [' + AllToChar( aErro[1]  ) + ']' )//"Id do formulário de origem:"
		AutoGrLog( STR0009 + ' [' + AllToChar( aErro[2]  ) + ']' )//"Id do campo de origem:     "
		AutoGrLog( STR0010 + ' [' + AllToChar( aErro[3]  ) + ']' )//"Id do formulário de erro:  "
		AutoGrLog( STR0011 + ' [' + AllToChar( aErro[4]  ) + ']' )//"Id do campo de erro:       "
		AutoGrLog( STR0012 + ' [' + AllToChar( aErro[5]  ) + ']' )//"Id do erro:                "
		AutoGrLog( STR0013 + ' [' + AllToChar( aErro[6]  ) + ']' )//"Mensagem do erro:          "
		AutoGrLog( STR0014 + ' [' + AllToChar( aErro[7]  ) + ']' )//"Valor atribuido:           "
		AutoGrLog( STR0015 + ' [' + AllToChar( aErro[8]  ) + ']' )//"Valor atribuido:           "
		AutoGrLog( STR0016 + ' [' + AllToChar( aErro[9]  ) + ']' )//"Valor anterior:            "
		MostraErro()
	EndIf
	// Desativamos o Model
	oModelQLE:DeActivate()
EndIf

RestArea(aAreaQLE)
RestArea(aArea)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Ct310ProcL()
Função de processamento para limpar as procedures listadas na tabela QLE-Controle limpeza Procedures Dinamicas

@author TOTVS
@since 13/09/2022
@version 1.0
@return lRet
/*/
//-------------------------------------------------------------------

Function Ct310ProcL()
Local lRet 	:= .T.
Local aArea := GetArea()
Local aAreaQLE := QLE->( GetArea() )
Local cPrazoDias := SuperGetMV("MV_CTM310D", .F., "10/90")
Local nDias := 0

Local cDataIni
Local cDataFim
Local cAliasQLE := GetNextAlias()

Local aBindQLE
Static _oQryQLE

//prazo em dias para limpeza
cPrazoDias := AllTrim(StrTran(cPrazoDias, " ", ""))
nDias := Val(Subs(cPrazoDias,1,2))
nDias := If(nDias <= 0, 10, nDias)

cDataIni := DTOS( Date() - 180 ) //considerar 6 meses anteriores
cDataFim := DTOS( Date()-nDias ) //considerar data atual - dias estabelecidos no Parametro

If _oQryQLE == NIL
	_oQryQLE := "SELECT QLE_FILIAL, QLE_CODSEQ, QLE_NOMEPR, QLE_ROTINA, QLE_DESCRT, QLE_DTCRIA, "
	_oQryQLE += "QLE_HRCRIA, QLE_USRCRI, QLE_DTEXCL, QLE_HREXCL, QLE_STATUS, R_E_C_N_O_ REGQLE FROM "
	_oQryQLE += RetSqlName("QLE")
	_oQryQLE += " WHERE QLE_FILIAL = ?"
	_oQryQLE += " AND QLE_DTCRIA >= ?"
	_oQryQLE += " AND QLE_DTCRIA <= ?"
	_oQryQLE += " AND QLE_STATUS <> '2' "	//somente os que nao alimentaram data de limpeza e status
	_oQryQLE += " AND D_E_L_E_T_  = ?"
	_oQryQLE += " ORDER BY QLE_FILIAL, QLE_CODSEQ"
	_oQryQLE := ChangeQuery(_oQryQLE)
EndIf
aBindQLE := {}
AADD(aBindQLE, xFilial("QLE") )
AADD(aBindQLE, cDataIni )
AADD(aBindQLE, cDataFim )
AADD(aBindQLE, Space(1) )
dbUseArea(.T.,"TOPCONN",TcGenQry2(,,_oQryQLE,aBindQLE),cAliasQLE)
aSize(aBindQLE,0)
aBindQLE := nil
If (cAliasQLE)->(!Eof())

	While (cAliasQLE)->( !Eof() )
			//Verifica se existe ainda a procedure
			If TCSPExist( Alltrim( (cAliasQLE)->QLE_NOMEPR ) ) //existe procedure no banco de dados
				//dropa a procedure no banco de dados
				CtM310Drop( Alltrim( (cAliasQLE)->QLE_NOMEPR ) )
			EndIf

			Ct310Limpa((cAliasQLE)->QLE_NOMEPR, .F./*lTabSeek*/, (cAliasQLE)->REGQLE/*nRegQLE*/)

			(cAliasQLE)->( dbSkip() )
	EndDo
EndIf

(cAliasQLE)->( dbCloseArea() )


RestArea(aAreaQLE)
RestArea(aArea)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CtM310Drop( cNomeProc )
Função para dropar procedure criada dinamicamente armazenada no controle de limpeza

@author TOTVS
@since 13/09/2022
@version 1.0
@return lRet
/*/
//-------------------------------------------------------------------
Static Function CtM310Drop( cNomeProc )
Local cQuery := ""
Local lRet := .F.

cQuery := " DROP PROCEDURE "+cNomeProc

lRet := CtbSqlExec1( cQuery )

Return lRet

/*-------------------------------------------------------------------------
Funcao		  : CtbSqlExec1
Autor         : Renato Campos
Data          : 12/09/2016
Uso           : Executa a instruÃ§Ã£o de banco via TCSQLExec
-------------------------------------------------------------------------*/
Static Function CtbSqlExec1( cStatement )
Local bBlock	:= ErrorBlock( { |e| ChecErro(e) } )
Local lRetorno := .T.

BEGIN SEQUENCE
	IF TcSqlExec(cStatement) <> 0
		UserException( " SQL script execution error " + CRLF + TCSqlError()  + CRLF + ProcName(1) + CRLF + cStatement )
		lRetorno := .F.
	Endif
RECOVER
	lRetorno := .F.
END SEQUENCE
ErrorBlock(bBlock)

Return lRetorno


//-------------------------------------------------------------------
/*/{Protheus.doc} Ct310lmpReg()
Função de processamento para deletar fisicamente os registrso das procedures listadas na tabela QLE-Controle limpeza Procedures Dinamicas que ja sofreram limpeza

@author TOTVS
@since 13/09/2022
@version 1.0
@return lRet
/*/
//-------------------------------------------------------------------

Function Ct310LmpReg()
Local lRet 	:= .T.
Local aArea := GetArea()
Local aAreaQLE := QLE->( GetArea() )
Local cPrazoDias := SuperGetMV("MV_CTM310D", .F., "10/90")
Local nDias := 0
Local nDiasTot := 0

Local cDataIni
Local cDataFim
Local cAliasQLE := GetNextAlias()
Local cQueryDel := ""

Local aBindQLE
Static _oQryRGQLE

//prazo em dias para limpeza
cPrazoDias := AllTrim(StrTran(cPrazoDias, " ", ""))
nDias := Val(Subs(cPrazoDias,1,2))
nDias := If(nDias <= 0, 10, nDias)

nDiasTot := Val(Subs(cPrazoDias,4,2)) + nDias

cDataIni := DTOS( Date() - 240 ) //considerar 8 meses anteriores
cDataFim := DTOS( Date()-nDiasTot ) //considerar data atual - dias estabelecidos no Parametro

If _oQryRGQLE == NIL
	_oQryRGQLE := " SELECT QLE_FILIAL "
	_oQryRGQLE += " FROM "
	_oQryRGQLE += RetSqlName("QLE")
	_oQryRGQLE += " WHERE QLE_FILIAL = ? "
	_oQryRGQLE += " AND QLE_DTCRIA >= ? "
	_oQryRGQLE += " AND QLE_DTCRIA <= ? "
	_oQryRGQLE += " AND QLE_STATUS = ? "
	_oQryRGQLE += " AND D_E_L_E_T_  = ? "

	_oQryRGQLE := ChangeQuery(_oQryRGQLE)
EndIf
aBindQLE := {}
AADD(aBindQLE, xFilial("QLE") )
AADD(aBindQLE, cDataIni )
AADD(aBindQLE, cDataFim )
AADD(aBindQLE, "2" )   //2-Procedure excluida Limpeza
AADD(aBindQLE, Space(1) )
dbUseArea(.T.,"TOPCONN",TcGenQry2(,,_oQryRGQLE,aBindQLE),cAliasQLE)

If (cAliasQLE)->(!Eof())

	cQueryDel := " DELETE FROM "
	cQueryDel += RetSqlName("QLE")
	cQueryDel += " WHERE QLE_FILIAL = '"+aBindQLE[1]+"' "
	cQueryDel += " AND QLE_DTCRIA >=  '"+aBindQLE[2]+"' "
	cQueryDel += " AND QLE_DTCRIA <=  '"+aBindQLE[3]+"' "
	cQueryDel += " AND QLE_STATUS =   '"+aBindQLE[4]+"' "
	cQueryDel += " AND D_E_L_E_T_  =  '"+aBindQLE[5]+"' "

	lRet := CtbSqlExec1( cQueryDel )

EndIf

aSize(aBindQLE,0)
aBindQLE := nil
(cAliasQLE)->( dbCloseArea() )

RestArea(aAreaQLE)
RestArea(aArea)
Return lRet






