#Include "FISA174.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"

PUBLISH MODEL REST NAME FISA174 SOURCE FISA174

//-------------------------------------------------------------------
/*/{Protheus.doc} FISA154
Rotina que tem objetivo de exibir as telas da apuração do tributo genérico

@author Erick G. Dias
@since 18/10/2018
@version 12117

/*/
//-------------------------------------------------------------------
Function FISA174(cOp, cTitulo, cIdTrib)
	Local nRet	:= 0
	Default cOp 	:= '2' // Visualização
	Default cTitulo	:= ''	

	PRIVATE COPCAO		:= cOp	
	PRIVATE IDTRIBUTO	:= cIdTrib
	PRIVATE IDRTRIBUTO	:= ""
	PRIVATE CTPAJU	    := ""	

	//Chama a View da rotina diretamente
	nRet	:= FWExecView(cTitulo ,'FISA174', MODEL_OPERATION_UPDATE,, { || .T. } , { || OnClose() })    

Return nRet


//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

@author Erick G. Dias
@since 18/10/2018
@version 12117

/*/
//-------------------------------------------------------------------
Static Function MenuDef() 
Return FWMVCMenu( 'FISA174' )

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

@author Erick G. Dias
@since 18/10/2018
@version 12117

/*/
//-------------------------------------------------------------------
Static Function ModelDef()

	Local oModel
	Local aArray		:= {}
	Local oStruABA		:= FWFormStruct( 1, 'F2H')
	Local oStruABA1		:= TempStruct(1,'ABA1') //Aba de Créditos
	Local oStruABA2		:= TempStruct(1,'ABA2') //Aba de Débitos
	Local oStruABA3	    := TempStruct(1,'ABA3') //Aba do resumo da apuração
	
	Local bLoadABA1  	:= {||LoadGrid('ABA1',@aArray) } //Popula as informações da aba de crédito
	Local bLoadABA2  	:= {||LoadGrid('ABA2',@aArray) } //Popula as informações da aba de débito
	Local bLoadABA3  	:= {||LoadGrid('ABA3',@aArray) } //Popula as informações da aba resumo		
	
	oModel	:=	MPFormModel():New('FISA154',,{|oModel| .T. },{|oModel| .T. })

	oModel:AddFields('MODEL_ABA',, oStruABA)	

	//Montagem do grid da aba crédito
    oModel:AddGrid('MODEL_ABA1', 'MODEL_ABA', oStruABA1,,,,, bLoadABA1)
	oModel:GetModel('MODEL_ABA1'):SetNoInsertLine(.T.)
	oModel:GetModel('MODEL_ABA1'):SetNoDeleteLine(.T.)
	oModel:GetModel('MODEL_ABA1'):SetNoUpdateLine(.T.)

	//Montagem do grid da aba débito
	oModel:AddGrid('MODEL_ABA2', 'MODEL_ABA', oStruABA2,,,,, bLoadABA2)
	oModel:GetModel('MODEL_ABA2' ):SetNoInsertLine(.T.)
	oModel:GetModel('MODEL_ABA2' ):SetNoDeleteLine(.T.)
	oModel:GetModel('MODEL_ABA2' ):SetNoUpdateLine(.T.)

	//Montagem do grid da segunda ABA
	oModel:AddGrid('MODEL_ABA3' ,'MODEL_ABA', oStruABA3,{||isincallstack('FSA174CLICK') .OR. isincallstack('OnClose') },,,, bLoadABA3)
	oModel:GetModel('MODEL_ABA3'):SetNoInsertLine(.T.)
	oModel:GetModel('MODEL_ABA3'):SetNoDeleteLine(.T.)
	//oModel:GetModel('MODEL_ABA3'):SetNoUpdateLine(.T.)
	
	oModel:SetPrimaryKey({'ABA1_CMP1'})
	oModel:SetDescription(STR0001) //'Apuração'

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

@author Erick G. Dias
@since 18/10/2018
@version 12117

/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oModel     	:= FWLoadModel('FISA174')
Local oView        	:= FWFormView():New()
Local oStruABA1   	:= TempStruct(2,'ABA1')
Local oStruABA2   	:= TempStruct(2,'ABA2')
Local oStruABA3   	:= TempStruct(2,'ABA3')

oView:SetModel( oModel )

//Cria View para cada grid crédito, débito e resumo
oView:AddGrid('VIEW_ABA1', oStruABA1 ,'MODEL_ABA1')
oView:AddGrid('VIEW_ABA2', oStruABA2 ,'MODEL_ABA2')
oView:AddGrid('VIEW_ABA3', oStruABA3 ,'MODEL_ABA3')
oView:SetViewProperty( "*", "GRIDNOORDER")

  //Títulos das telas
oView:EnableTitleView('VIEW_ABA1',STR0002) //"Débitos"
oView:EnableTitleView('VIEW_ABA2',STR0003) //"Créditos"
oView:EnableTitleView('VIEW_ABA3',STR0004) //"Resumo"

//Cria a pasta
oView:CreateFolder('PASTAS')

oView:CreateHorizontalBox( 'TELA1', 100,,, 'PASTAS', 'ABA01' )
oView:CreateHorizontalBox( 'TELA2', 100,,, 'PASTAS', 'ABA02' )
oView:CreateHorizontalBox( 'TELA3', 100,,, 'PASTAS', 'ABA03' )


//Cria as abas
oView:AddSheet('PASTAS', 'ABA01', STR0002) //"Débitos"
oView:AddSheet('PASTAS', 'ABA02', STR0003) //"Créditos"
oView:AddSheet('PASTAS', 'ABA03', STR0004) //"Resumo"

//Relaciona cada grid com sua respectiva aba na tela
oView:SetOwnerView( 'VIEW_ABA1'  , 'TELA1')
oView:SetOwnerView( 'VIEW_ABA2'  , 'TELA2')
oView:SetOwnerView( 'VIEW_ABA3'  , 'TELA3')

oView:SetViewProperty("VIEW_ABA3", "GRIDDOUBLECLICK", {{|oFormulario,cFieldName,nLineGrid,nLineModel, cField| FSA174CLICK(oFormulario,cFieldName,nLineGrid,nLineModel,cField)}}) 

oView:AddUserButton(STR0005,"",{||x174Ajuste("1")},) //"Ajustes de Débito"
oView:AddUserButton(STR0006,"",{||x174Ajuste("2")},) //"Ajustes de Crédito"
oView:AddUserButton(STR0007,"",{||x174Saldos("1")},) //"Saldos Credores"

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} TempStruct

Função utilizada para criação das tabelas temporárias para as abas
da apuração, já que as tabelas não estão em dicionário, deverão ser
criadas manualmente.

@param  	nOpcao  - indica se foi chamada na criação do Model ou da View.
			cTabela - Indica o alias da tabela temporária
@return	oStru  - Estrutura criada com os campos da tabela temporária qe será exibida na tela.

@author Erick G. Dias
@since 18/10/2018
@version 12117

/*/
//-------------------------------------------------------------------
Static Function TempStruct(nOpcao,cTabela)

Local aCampos	:= {}
Local nCont	:= 0
Local oStru

//Chama Função para criar os campos conforme tabela processada
aCampos:= CriaCampos(cTabela)

//Quando for chamada para criar Model
If nOpcao == 1

	oStru :=  FWFormModelStruct():New()//	FWFormStruct( 1 , '')//
	oStru:AddTable("TRB",{},"TOTVS")
	For nCont := 1 to len (aCampos)
		oStru:AddField( ; 					// Ord. Tipo Desc.
						aCampos[nCont][1] , ;// [01] C Titulo do campo
						aCampos[nCont][1] , ;// [02] C ToolTip do campo
						aCampos[nCont][2] , ;// [03] C identificador (ID) do Field
						aCampos[nCont][3] , ;// [04] C Tipo do campo
						aCampos[nCont][4] , ;// [05] N Tamanho do campo
						aCampos[nCont][5] , ;	// [06] N Decimal do campo
						NIL				,;	// [07] B Code-block de validação do campo
						NIL 				, ;	// [08] B Code-block de validação When do campo
						aCampos[nCont][10]  , ;	// [09] A Lista de valores permitido do campo
						NIL 				, ;	// [10] L Indica se o campo tem preenchimento obrigatório
						nil					, ;	// [11] B Code-block de inicializacao do campo
						NIL 				, ;	// [12] L Indica se trata de um campo chave
						.F. 				, ;	// [13] L Indica se o campo pode receber valor em uma operação de update.
						.F. ) 					// [14] L Indica se o campo é virtual
	Next nCont

//Quando for chamada para criar a View
ElseIF nOpcao == 2

	oStru := FWFormViewStruct():New()
	For nCont := 1 to len (aCampos)
		oStru:AddField( ;
		aCampos[nCont][2], ; // [01] C Nome do Campo
		aCampos[nCont][6], ;	// [02] C Ordem
		aCampos[nCont][1], ;	// [03] C Titulo do campo
		aCampos[nCont][1], ;	// [04] C Descrição do campo
	    aCampos[nCont][7], ; // [05] A Array com Help
		aCampos[nCont][3], ; 	// [06] C Tipo do campo
		aCampos[nCont][8], ; // [07] C Picture
		NIL 			   , ;	// [08] B Bloco de Picture Var
		''                 , ; 	// [09] C Consulta F3
		aCampos[nCont][9]	, ; 	// [10] L Indica se o campo é evitável
		nil				   , ; 	// [11] C Pasta do campo
		NIL                , ;	// [12] C Agrupamento do campo
		aCampos[nCont][10] , ; 	// [13] A Lista de valores permitido do campo
		NIL                , ;	// [14] N Tamanho Maximo da maior opção do combo
		NIL                , ; 	// [15] C Inicializador de Browse
		.F.                , ; 	// [16] L Indica se o campo é virtual
		NIL )
	Next nCont

EndIF

Return oStru


//-------------------------------------------------------------------
/*/{Protheus.doc} LoadGrid

 Função que irá retornar as informações para pouplar as linhas
 das tabelas temporárias de cada aba da tela de apuração.

@param  	     cTabela  - Tabela a qual serão será populada
@return	aLoad   - Array com as informações e valores para popular as telas

@author Erick G. Dias
@since 08/04/2014
@version 12117

/*/
//-------------------------------------------------------------------
Static Function LoadGrid(cTabela,aArray)

Local aLoad  		:= {}

Do Case

	Case cTabela == 'ABA1'

		//Chama Função para buscar informações da aba de Débitos
		aLoad	:= LoadCrdDeb(IDTRIBUTO, '1')		

	Case cTabela == 'ABA2'

		//Chama Função para buscar informações da aba de Créditos
		aLoad	:= LoadCrdDeb(IDTRIBUTO, '2')		

	Case cTabela == 'ABA3'
	    //Carga das informaçõe dos campos da aba de resumo
		aLoad	:= LoadResumo(IDTRIBUTO)   

EndCase

Return( aLoad )

//-------------------------------------------------------------------
/*/{Protheus.doc} CriaCampos

 Função que monta as propriedades de cada campo da tabela temporária
 de cada aba das telas de apuração

@param  	cTabela  - Tabela a qual serão criados os campos
@return	aCampos  - Array com as propriedades dos campos que serão criados

@author Erick G. Dias
@since 08/04/2014
@version 12117

/*/
//-------------------------------------------------------------------
Static Function CriaCampos(cTabela)

Local aCampos	:= {}

//aAdd(aCampos, {/*Título*/,/*Nome do campo*/,/*Tipo*/,/*Tamanho*/,/*Decimal*/,/*Ordem*/,/*Array com help*/,/*Picture*/,/*Campo editáveç*/})

Do Case

	Case cTabela == 'ABA1'
		//---------------------------------------------
		// Cria as colunas da segunda aba Débitos
		//---------------------------------------------
		aAdd(aCampos, {STR0008,'ABA1_CMP1','C',15,0,'01',{STR0008},'@!'              ,.T.,{}}) //"Regra de Cálculo do Tributo"
		aAdd(aCampos, {STR0009,'ABA1_CMP2','C',50,0,'02',{STR0009},'@!'              ,.T.,{}})  //"Descrição"
		aAdd(aCampos, {STR0010,'ABA1_CMP3','N',14,2,'03',{STR0011},'@E 999,999,999.99',.T.,{}}) //"Valor Tributado" //"Valor"
		aAdd(aCampos, {STR0012,'ABA1_CMP4','N',14,2,'04',{STR0011},'@E 999,999,999.99',.T.,{}}) //"Valor" //"Devoluções (Estorno de Débito)"

	Case cTabela == 'ABA2'

		//----------------------------------------
		// Cria as colunas da segunda aba Créditos
		//----------------------------------------
        aAdd(aCampos, {STR0008,'ABA2_CMP1','C',15,0,'01',{STR0008},'@!'               ,.T.,{}}) //"Regra de Cálculo do Tributo"
		aAdd(aCampos, {STR0009,'ABA2_CMP2','C',50,0,'02',{STR0009},'@!'               ,.T.,{}}) //"Descrição"
		aAdd(aCampos, {STR0010,'ABA2_CMP3','N',14,2,'03',{STR0011},'@E 999,999,999.99',.T.,{}}) //"Valor" //"Valor Tributado"
		aAdd(aCampos, {STR0013,'ABA2_CMP4','N',14,2,'04',{STR0011},'@E 999,999,999.99',.T.,{}}) //"Valor" //"Devoluções (Estorno de Crédito)"

	Case cTabela == 'ABA3'
		//---------------------------------------
		// Cria as colunas da terceita aba resumo
		//---------------------------------------
		aAdd(aCampos, {STR0014, 'ABA3_CMP1','C',6,0, '01',{STR0014},'@!',.T.,{}}) //"Linha"
		aAdd(aCampos, {STR0009, 'ABA3_CMP2','C',50,0,'02',{STR0009},'@!',.T.,{}}) //"Descrição"
		aAdd(aCampos, {STR0011, 'ABA3_CMP3','N',14,2,'03',{STR0011},'@E 999,999,999.99',.T.,{}})  //"Valor"
	
EndCase

Return aCampos

//-------------------------------------------------------------------
/*/{Protheus.doc} OnClose

Função que fará o tratamento ao concluir tela de resumo da apuração.

@author Erick G. Dias
@since 19/10/2018
@version 12117

/*/
//-------------------------------------------------------------------
Static Function OnClose()

Local lRet		:= .T.
Local oModel    :=	FWModelActive()
Local oABA3	    := oModel:GetModel('MODEL_ABA3' )
Local oView 	:= 	FWViewActive()

//Este trecho é necessário, pois preciso alterar o modelo para o botão confirmar fechar a tela.
//Como o modelo possui tabela temporária, preciso alterar o modelo manualmente
cText	:= oABA3:GetValue("ABA3_CMP1",1)
oABA3:SetValue('ABA3_CMP1', "." )
oview:Refresh( 'VIEW_ABA3' )
oABA3:SetValue('ABA3_CMP1', cText )
oview:Refresh( 'VIEW_ABA3' )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} LoadCrdDeb

Função Responsável por buscar as informações da tabela e popular
as abas de crédito e débito.

@author Erick G. Dias
@since 21/10/2018
@version 12117

/*/
//-------------------------------------------------------------------
Static Function LoadCrdDeb(cIdApur, cOp)

Local cAliasxFil	:= x175Query('F2JXFIL',{cIdApur, cOp})
Local cAliasLoad	:= ""
Local aRet			:= {}
Local nX			:= 0
Local nTotTrib		:= 0
Local nTotDev		:= 0
Local aAreaSM0		:= {}


aAreaSM0 := SM0->(GetArea())

//Rodar para uma ou mais filiais selecionadas no momendo que rodou a apuração
While (cAliasxFil)->(!Eof())

	SM0->(DbGoTop())
	SM0->(MsSeek(cEmpAnt+(cAliasxFil)->F2J_FILIAL, .T.))
	cFilAnt := FWGETCODFILIAL

	cAliasLoad	:= x175Query('F2J', {cIdApur, cOp})

	While (cAliasLoad)->(!Eof())
		
		//Adiciona linha para cada valor de regra gravada
		aAdd(aRet, {nX++, {(cAliasLoad)->F2B_REGRA, (cAliasLoad)->F2B_DESC, (cAliasLoad)->VALOR_TRIBUTO, (cAliasLoad)->VALOR_DEVOLUCOES}})	
		
		//Variáveis totalizadoras
		nTotTrib += (cAliasLoad)->VALOR_TRIBUTO
		nTotDev += (cAliasLoad)->VALOR_DEVOLUCOES

		(cAliasLoad)->(dbSkip())
	EndDo

	//Fecha o alias da query
	(cAliasLoad)->(dbCloseArea())

	(cAliasxFil)->(dbSkip())
EndDo

RestArea(aAreaSM0)
cFilAnt := FWGETCODFILIAL

//Fecha o alias da query
(cAliasxFil)->(dbCloseArea())

//Adiciona linha com o totalizador
aAdd(aRet, {nX++, {""      ,"",          ,         }})
aAdd(aRet, {nX++, {STR0015 ,"",  nTotTrib, nTotDev }}) //"TOTAL"

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} LoadResumo

Função responsável por montar a aba de resumo da apuração do tributo.

@author Erick G. Dias
@since 21/10/2018
@version 12117

/*/
//-------------------------------------------------------------------
Static Function LoadResumo(cIdApur)

Local aRet			:= {}
Local nX			:= 0
Local nSpace		:= 10
Local cAliasLoad	:= x175Query('F2K', {cIdApur})

If (cAliasLoad)->(!Eof())

	//------------------------------
	//Seção de campos dos débitos	
	//------------------------------
	aAdd(aRet, {nX++, {"", "", }})
	aAdd(aRet, {nX++, {"", Space(nSpace) + STR0016, }}) //"-- DÉBITOS --"
	aAdd(aRet, {nX++, {"", "", }})                
	aAdd(aRet, {nX++, {"001", STR0017, Lin2F2K("001", cAliasLoad)}}) //"DÉBITOS POR SAÍDA"
	aAdd(aRet, {nX++, {"002", STR0018, Lin2F2K("002", cAliasLoad)}}) //"ESTORNOS DE CRÉDITO"
	aAdd(aRet, {nX++, {"003", STR0019, Lin2F2K("003", cAliasLoad)}}) //"AJUSTES DE DÉBITO"
	aAdd(aRet, {nX++, {"004", STR0020, Lin2F2K("004", cAliasLoad)}}) //"TOTAL DE DÉBITOS (A)"
	//-----------------------------------
	//Seção dos campos do saldo anterior
	//-----------------------------------
	aAdd(aRet, {nX++, {"", "", }})
	aAdd(aRet, {nX++, {"", Space(nSpace) + STR0021, }}) //"-- SALDO CREDOR --"
	aAdd(aRet, {nX++, {"", "", }})        
	aAdd(aRet, {nX++, {"005", STR0022, Lin2F2K("005", cAliasLoad)}}) //"SALDO CREDOR TRANSPORTADO DO PERÍODO ANTERIOR (B)"
	aAdd(aRet, {nX++, {"006", STR0023, Lin2F2K("006", cAliasLoad)}}) //"SALDO CREDOR DO PERÍODO ANTERIOR UTILIZADO (C)"

	//----------------------------
	//Seção de campos dos créditos	
	//----------------------------
	aAdd(aRet, {nX++, {"", "", }})
	aAdd(aRet, {nX++, {"", Space(nSpace) + STR0024, }}) //"-- CRÉDITOS --"
	aAdd(aRet, {nX++, {"", "", }})
	aAdd(aRet, {nX++, {"007", STR0025, Lin2F2K("007", cAliasLoad)}}) //"CRÉDITOS POR ENTRADA"
	aAdd(aRet, {nX++, {"008", STR0026, Lin2F2K("008", cAliasLoad)}}) //"ESTORNOS DE DÉBITO"
	aAdd(aRet, {nX++, {"009", STR0027, Lin2F2K("009", cAliasLoad)}}) //"AJUSTES DE CRÉDITO"
	aAdd(aRet, {nX++, {"010", STR0028, Lin2F2K("010", cAliasLoad)}}) //"TOTAL DE CRÉDITOS (D)"
	
	//---------------------------
	//Seção de campos dos totais
	//---------------------------
	aAdd(aRet, {nX++, {"", "", }})
	aAdd(aRet, {nX++, {"", Space(nSpace) + STR0029, }}) //"-- TOTAIS --"
	aAdd(aRet, {nX++, {"", "", }})
	aAdd(aRet, {nX++, {"011", STR0030, Lin2F2K("011", cAliasLoad)}}) //"SALDO DEVEDOR (A - C - D)"
	aAdd(aRet, {nX++, {"012", STR0031, Lin2F2K("012", cAliasLoad)}}) //"SALDO CREDOR A TRANSPORTAR PARA O PRÓXIMO PERÍODO"
	aAdd(aRet, {nX++, {"", "", }})	

	//Atualiza o ID do resumo da apuração, será utilizado no evento de duplo click
	IDRTRIBUTO	:= (cAliasLoad)->F2K_ID

EndIF

//Fecha o alias da query
(cAliasLoad)->(dbCloseArea())

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA174CLICK

Função que faz o tratamento do duplo click da aba de resumo da apuração,
para abrir a tela de ajustes da apuração.

@author Erick G. Dias
@since 21/10/2018
@version 12117

/*/
//-------------------------------------------------------------------
Function FSA174CLICK(oFormulario,cFieldName,nLineGrid,nLineModel,cField)

Local cLinAjuDeb	:= "003"
Local cLinAjuCrd	:= "009"
Local cLinSldCrd	:= "005|006|012"
Local cLin			:= ""
Local oModelAba3 	:= oFormulario:GetModel("MODEL_ABA3")
Local oBrowse		:= nil
Local lProcAjuste	:= .F.
Local cFiltroBrw    := ""

//Obtenho qual a linha que disparou o duplo clique
cLin	:= oModelAba3:GetValue("ABA3_CMP1")

//Verifico primeiro se linha não está vazia
If !Empty(cLin)	

	//Verifica se a linha pertence a linha de ajuste de crédito
	If cLin $ cLinAjuCrd		
		lProcAjuste	:= .T.
		CTPAJU		:= "2"		
	EndIF	

	//Verifica se a linha pertence a linha de ajuste de débito
	If cLin $ cLinAjuDeb		
		lProcAjuste	:= .T.
		CTPAJU		:= "1"
	EndIF

	//Verifica se a linha pertence a uma das linhas de saldo credor (transportado/utilizado/a transportar)
	If cLin $ cLinSldCrd
		x174Saldos("1")
	EndIf

EndIF

//Se o duplo click foi em uma linha que permita alteração, será aberta a tela de ajuste manual, considerando o ID do resumo da apuração.
If lProcAjuste
	x174Ajuste(CTPAJU, nLineGrid)
EndIF

Return .F.

//-------------------------------------------------------------------
/*/{Protheus.doc} x174Ajuste

Função responsável por centralizar a chamada do browse para manipulação
dos ajustes de crédito ou débito.

@author Erick G. Dias
@since 23/10/2018
@version 12117

/*/
//-------------------------------------------------------------------
Static Function x174Ajuste(cTpAjuste, nLineGrid)

Local cDescr		:= "Ajustes de "
Local cAttIsMemberOf := "AttIsMemberOf"
Local cFiltroBrw	:= 'F2M_FILIAL == "' + xFilial('F2M') + '"'

DEFAULT nLineGrid := 1

CTPAJU := cTpAjuste

Do Case

	Case cTpAjuste == "2"
		cDescr 		+= "Créditos"				
		cFiltroBrw 	+=' .AND. F2M_TPAJUS == "2" '
	Case cTpAjuste == "1"
		cDescr 		+= "Débitos"			
		cFiltroBrw 	+=' .AND. F2M_TPAJUS == "1" '

EndCase

cFiltroBrw +=' .AND. F2M_IDRAPU == "' + IDRTRIBUTO  + '" '		

//Chamará a view
oBrowse := FWmBrowse():New()
oBrowse:SetDescription( cDescr)
oBrowse:SetAlias( 'F2M' )
oBrowse:SetMenuDef( 'FISA174AJU' )
// Desabilita a seleção de filiais na hora de incluir um ajuste. O ajuste sempre será incluido
// na filial "logada" (cfilant) já que a apuração é feita por filial.
If &cAttIsMemberOf.(oBrowse,"lBrwFilOn",.T.)
	oBrowse:lBrwFilOn := .F.
EndIf
oBrowse:SetFilterDefault( cFiltroBrw )
oBrowse:Activate()

IF COPCAO == '2' //Edição
	x175ResApu(IDTRIBUTO,,IDRTRIBUTO)
	//Chama função para atualizar os valores da tela
	AtuResumo(IDTRIBUTO, nLineGrid)
EndIF

//Limpo a variável para não ficar sujeira
CTPAJU	:= ""

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} x174TPAJU
Campo que retorna o tipo de ajuste manual a ser executado,
se ajuste de débito ou ajuste de crédito.

@author Erick G. Dias
@since 21/10/2018
@version 12117

/*/
//-------------------------------------------------------------------
Function x174TPAJU()
Return CTPAJU

//-------------------------------------------------------------------
/*/{Protheus.doc} x174TPAJU
Função que retorna o ID do resumo da apuração, campo que faz relação
entre as tabelas F2K e F2M.

@author Erick G. Dias
@since 21/10/2018
@version 12117

/*/
//-------------------------------------------------------------------
Function x174IDRAPU()
Return IDRTRIBUTO

//-------------------------------------------------------------------
/*/{Protheus.doc} x174OPER

Função que retorna o tipo de operação da apuração
Visualização ou edição

@author Erick G. Dias
@since 21/10/2018
@version 12117

/*/
//-------------------------------------------------------------------
Function x174OPER()
Return COPCAO

//-------------------------------------------------------------------
/*/{Protheus.doc} Lin2F2K

Função responsável por fazer o link da linha da aba de resumo da apuração
com o campo correspondente da tabela F2K, deixando de forma centralizada
a criação e atualização desta aba.

@author Erick G. Dias
@since 22/10/2018
@version 12117

/*/
//-------------------------------------------------------------------
Static Function Lin2F2K(cLinResumo, cAliasF2K)

Local nValRet	:= 0

cLinResumo	:= Alltrim(cLinResumo)

Do Case
	Case cLinResumo == "001" //Total de saídas
		nValRet	:= (cAliasF2K)->F2K_OPTRIB
	Case cLinResumo == "002" //Estorno de Crédito
		nValRet	:= (cAliasF2K)->F2K_ESTCRD	
	Case cLinResumo == "003" //Ajuste de débito
		nValRet	:= (cAliasF2K)->F2K_AJUDEB	
	Case cLinResumo == "004" //Total das saídas
		nValRet	:= (cAliasF2K)->F2K_TOTDEB	
	Case cLinResumo == "005" //Saldo credor de período anterior
		nValRet	:= (cAliasF2K)->F2K_SLDANT	
	Case cLinResumo == "006" //Saldo credor utilizado
		nValRet	:= (cAliasF2K)->F2K_SLDUTI	
	Case cLinResumo == "007" //Crédito por entrada
		nValRet	:= (cAliasF2K)->F2K_OPCRED	
	Case cLinResumo == "008" //Estorno de Débito
		nValRet	:= (cAliasF2K)->F2K_ESTDEB	
	Case cLinResumo == "009" //Ajuste de Crédito
		nValRet	:= (cAliasF2K)->F2K_AJUCRD	
	Case cLinResumo == "010" //Total das entradas	
		nValRet	:= (cAliasF2K)->F2K_TOTCRD	
	Case cLinResumo == "011" //Saldo devedor
		nValRet	:= (cAliasF2K)->F2K_SLDDEV	
	Case cLinResumo == "012" //Saldo a transportar para próximo período
		nValRet	:= (cAliasF2K)->F2K_SLDATU	

EndCase

Return nValRet

//-------------------------------------------------------------------
/*/{Protheus.doc} AtuResumo

Função que fará a atualização dos valores na tela do resumo da apuração.
Esta funçõ precorrerá linha por linha buscar o valor correspondente através
da função Lin2F2K.

@author Erick G. Dias
@since 22/10/2018
@version 12117

/*/
//-------------------------------------------------------------------
Static Function AtuResumo(cIdApur, nLineGrid)

Local oModel		:= FWModelActive()
Local oModelABA3	:= oModel:GetModel('MODEL_ABA3')
lOCAL oView 		:= FWViewActive()
Local cAliasF2K		:= x175Query('F2K', {cIdApur})
Local cLin			:= ""
Local nI 			:= 0

//Rodo as linhas da aba de resumo da apuração, para que os valores sejam atualizados
For nI := 1 To oModelABA3:Length()
	//Posiciona a linha
	oModelABA3:GoLine( nI )	

	//Obtenho o número da linha 
	cLin	:= Alltrim(oModelAba3:GetValue("ABA3_CMP1"))	
	
	//Se a linha estiver preenchida, chamarei a função Lin2F2K para atualizar o valor 
	If !Empty(cLin)
		oModelABA3:SetValue( 'ABA3_CMP3' , Lin2F2K(cLin, cAliasF2K))		
	EndIF
Next nI

//Volto para a primeira linha e faço refresh da view
oModelABA3:GoLine( nLineGrid )
oview:Refresh('VIEW_ABA3')

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} x174Saldos

Função responsável por exibir um browse com os saldos gerados e/ou
consumidos pela apuração.

@author Erick G. Dias
@since 23/10/2018
@version 12117

/*/
//-------------------------------------------------------------------
Static Function x174Saldos(cTpSaldo)

Local cFiltroBrw := ""

dbSelectArea("F2I")
F2I->(dbSetOrder(1))
cFiltroBrw := "F2I_FILIAL == " + ValToSql(xFilial("F2I")) + " .And. "
cFiltroBrw += "F2I_IDAPUR == " + ValToSql(IDTRIBUTO) + " .And. "
cFiltroBrw += "F2I_TPSLD == " + ValToSql(cTpSaldo) + " .And. "
cFiltroBrw += "D_E_L_E_T_ = ' '"

FISA174DET("F2I", STR0007, cFiltroBrw) //"Saldos Credores"

Return

