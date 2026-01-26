#INCLUDE "JURA170.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH" 
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA170
Fila de Sincronização.

@author André Spirigoni Pinto
@since 06/03/14
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA170()
Local oBrowse := Nil
Local lRet    := (SuperGetMV("MV_JFSINC",.F.,'2') == '2')

//Valida se a integração com o Legal Desk está ativada antes de abrir a tela
If lRet
	JurMsgErro(STR0008) //"O parâmetro MV_JFSINC deve ser configurado para abrir a fila de integração."
Else
	oBrowse := FWMBrowse():New()
	oBrowse:SetDescription( STR0007 )
	oBrowse:SetAlias( "NYS" )
	oBrowse:SetLocate()
	JurSetLeg( oBrowse, "NYS" )
	JurSetBSize( oBrowse )
	
	oBrowse:SetFilterDefault("NYS_STATUS == '1'")
	
	oBrowse:Activate()
EndIf

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Funcional

@return aRotina - Estrutura
[n,1] Nome a aparecer no cabecalho
[n,2] Nome da Rotina associada
[n,3] Reservado
[n,4] Tipo de Transação a ser efetuada:
1 - Pesquisa e Posiciona em um Banco de Dados
2 - Simplesmente Mostra os Campos
3 - Inclui registros no Bancos de Dados
4 - Altera o registro corrente
5 - Remove o registro corrente do Banco de Dados
6 - Alteração sem inclusão de registros
7 - Cópia
8 - Imprimir
[n,5] Nivel de acesso
[n,6] Habilita Menu Funcional

@author André Spirigoni Pinto
@since 06/03/14
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0001, "PesqBrw"        , 0, 1, 0, .T. } ) // "Pesquisar"
aAdd( aRotina, { STR0006, "VIEWDEF.JURA170", 0, 8, 0, NIL } ) // "Imprimir"
aAdd( aRotina, { STR0009, "J170CARGA()"    , 0, 3, 0, .T. } ) // "Carga Inicial"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados da Fila de Sincronização.

@author André Spirigoni Pinto
@since 06/03/14
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oModel     := FWLoadModel( "JURA170" )
Local oStructNYS := Nil
Local oView      := Nil

oStructNYS := FWFormStruct( 2, "NYS" )

JurSetAgrp( 'NYS',, oStructNYS )

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( "NYSMASTER", oStructNYS, "NYSMASTER"  )

oView:CreateHorizontalBox( "PRINCIPAL" , 100 )

oView:SetOwnerView( "NYSMASTER" , "PRINCIPAL" )

oView:SetUseCursor( .T. )
oView:EnableControlBar( .T. )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados da fila de sincronização.

@author André Spirigoni Pinto
@since 06/03/14
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oStructNYS := NIL
Local oModel     := NIL

oStructNYS := FWFormStruct(1,"NYS")

oModel:= MPFormModel():New( "JURA170", /*Pre-Validacao*/, /*Pos-Validacao*/, /*Commit*/,/*Cancel*/)
oModel:AddFields( "NYSMASTER", /*cOwner*/, oStructNYS,/*Pre-Validacao*/,/*Pos-Validacao*/, ) 
oModel:GetModel( "NYSMASTER" ):SetDescription( STR0007 ) //"Fila de sincronização"

JurSetRules( oModel, "NYSMASTER",, 'NYS' )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} J170GRAVA
Faz a gravação na fila de sincronização.

@Params	xModel   Recebe o modelo de dados em casos em que a manipulação 
										está sendo feita via modelo ou o nome da tabela quando   
										via Reclock
@Params  cChave   Chave do registro que foi manipulado
@Params  cOper    Operação que está sendo realizada, quando via Reclock
@Params  lForce   Força a gravação na fila de sincronização (usado na situação de 
					retorno da revisão para gravar os lançamentos)

@author André Spirigoni Pinto
@since 10/03/14
@version 1.0
/*/
//-------------------------------------------------------------------
Function J170GRAVA(xModel, cChave, cOper, lForce)
Local aArea       := GetArea()
Local aAreaNYS    := {}
Local lRet        := .T.
Local cModelo     := ""
Local cModNSinc   := SuperGetMV("MV_JMDLSIN", , "") //Relação dos modelos que não serão sincronizados e não devem gerar registros na fila
Local cSeq        := ""
Local cStatus     := "1"
Local lLDSincOn   := .F.

Default cOper     := ""
Default lForce    := .F.

	If SuperGetMV("MV_JFSINC",.F.,'2') == '1' .And. (!JurIsRest() .Or. lForce) //Varíavel do JurRESTModel que define se a operação é pelo REST ou não
		If ValType(xModel) == "C" //Manipulação manual ou inclusão prioritária de pré-fatura (Em revisão)
			Do Case
			Case xModel == "NUE"
				cModelo := "JURA144"
			Case xModel == "JURA144"
				cModelo := "JURA144"
			Case xModel == "NVY"
				cModelo := "JURA049"
			Case xModel == "NV4"
				cModelo := "JURA027"
			Case xModel == "SA1"
				cModelo := "JURA148"
			Case xModel == "NVE"
				cModelo := "JURA070"
			Case xModel == "NXA"
				cModelo := "JURA204"
			Case xModel == "NVQ"
				cModelo := "JURA030"
			Case xModel == "NT0"
				cModelo := "JURA096"
			Case xModel == "CTO"
				cModelo := "CTBA140"
			Case xModel == "CTT"
				cModelo := "CTBA030"
			Case xModel == "SM2"
				cModelo := "MATA090"
			Case xModel == "ACY"
				cModelo := "FATA110"
			Case xModel == "SE4"
				cModelo := "MATA360"
			Case xModel == "NX0"
				cModelo := "JURA202"
			Case xModel == "JURA202E"
				cModelo := xModel
			Case xModel == "SU5"
				cModelo := "TMKA070"
			Case xModel == "NVV"
				cModelo := "JURA033"
			Case xModel == "NZQ"
				cModelo := "JURA235"
			Case xModel == "JURA235A"
				cModelo := xModel
			Case xModel == "NUF"
				cModelo := "JURA146"
			Case xModel == "SED"
				cModelo := "FINA010"
			Case xModel == "OH6"
				cModelo := "JURA238"
			Case xModel == "OHB"
				cModelo := "JURA241"
			Case xModel == "SE7"
				cModelo := "JURA252"
			Case xModel == "CQD"
				cModelo := "JURA253"
			Case xModel == "OHH"
				cModelo := "JURA255"
			Case xModel == "NWF"
				cModelo := "JURA069"
			Case xModel == "JURA256"
				cModelo := xModel
			Case xModel == "SA6"
				cModelo := "MATA070"
			Case xModel == "OHL"
				cModelo := "JURA264"
			Case xModel == "SA2"
				cModelo := "MATA020"
			Case xModel == "OHD"
				cModelo := "JURA244"
			Case xModel == "NUM"
				cModelo := "JURA290"
			Case xModel == "NVP"
				cModelo := "JURA028"
			Case xModel == "SYA"
				cModelo := "JURA194"
			Case xModel == "OI8"
				cModelo := "JURA311"
			OtherWise
				lRet := .F.
			EndCase
		Else // Manipulação via Model
			cModelo := xModel:GetId()
			cOper   := AllTrim(Str(xModel:GetOperation()))
		EndIf

		If xModel <> "JURA144" .AND. cModelo == "JURA144" .AND. !Empty(JurGetDados("NUE", 1, cChave, "NUE_CPREFT"))
			cModelo := "JURA144PF"
		ENDIF

		If lRet .And. (cOper $ "3/4/5") .And. !(cModelo $ cModNSinc)
			
			If Empty(cChave)
				J170Log(cModelo, xModel, cOper) // Gera Log com dados do registro com problema
				cChave  := "SEMCHAVE" // Chave será identificada pelo checklist do SYNC, para indicar que foi gerado um LOG.
				cStatus := "2" // Coloca status 2-Concluído para que o SYNC não fique procurando pelo registro
			EndIf

			aAreaNYS := NYS->(GetArea())

			cSeq :=  GetSXENum("NYS", "NYS_CODIGO")

			lLDSincOn := FindFunction("JLDSincOn") .And. JLDSincOn(cModelo)

			If lLDSincOn // Sincronização com o LegalDesk foi realizada de forma online
				cStatus := "2" // Com isso, vamos incluir uma fila já processada
			EndIf

			If __lSX8
				ConfirmSX8()
			EndIf
			RecLock("NYS", .T.)
			NYS->NYS_FILIAL := xFilial('NYS')
			NYS->NYS_CODIGO := cSeq
			NYS->NYS_MODELO := cModelo
			NYS->NYS_CHAVE  := cChave
			NYS->NYS_OPERAT := cOper
			NYS->NYS_TSTAMP := JurTime(.T., .F.)
			NYS->NYS_STATUS := cStatus
			NYS->(MsUnlock())
			NYS->(DbCommit())

			If lLDSincOn // Sincronização com o LegalDesk foi realizada de forma online
				// Além de incluir a fila como processada, vamos excluir o registro
				// Isso é necessário para manter uma forma de rastreio
				RecLock("NYS", .F.)
				NYS->(dbDelete())
				NYS->(MsUnlock())
			EndIf

			RestArea( aAreaNYS )
		EndIf

	EndIf

	If lLDSincOn
		JLDSincOff() // Restaura o valor padrão da sincronização online, necessário quando é feito a exclusão e em seguida uma inclusão sem fechar a tela da rotina.
	EndIf

	RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J170CARGA
Exibe o Pergunte (SX1 - JURA170) para escolha dos modelos que devem sofrer
a carga inicial na fila de sincronização.

@author Cristina Cintra
@since 19/05/15
@version 1.0
/*/
//-------------------------------------------------------------------
Function J170CARGA()
Local aArea     := GetArea()
Local oGrid     := Nil
Local lUsaInteg := SuperGetMV("MV_JFSINC",.F.,'2') == '1'

	If lUsaInteg
		oGrid:=FWGridProcess():New("JURA170",STR0009,STR0010,{|oGrid, lEnd|J170Exec(oGrid)},"JURA170"/*Pergunte*/) //"Carga Inicial""Escolha os modelos para carga inicial da fila de sincronização."
		oGrid:SetMeters(2)
		oGrid:Activate()
	Else
		MsgInfo(STR0011) //"Opção disponível apenas quando utilizada a Integração com LegalDesk! - MV_JFSINC = '1'"
	Endif

RestArea(aArea)

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} J170Exec
Executa a carga inicial de todos os registros dos modelos escolhidos
na fila de sincronização.

@author Cristina Cintra
@since 19/05/15
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J170Exec(oGrid)
Local aArea    := GetArea()
Local aFila    := {}
Local lTodos   := (MV_PAR01 == 1) //Opção de todos os modelos

/*Não alterar a ordem abaixo para respeitar a predecessão dos cadastros*/

	oGrid:SetMaxMeter(2, 1, STR0013) //"Gravação da carga inicial da fila de sincronização"

	If lTodos .Or. MV_PAR30 == 1 //Moedas
		aFila := J170Array(aFila, "CTBA140", "CTO", {"CTO_MOEDA"})
	EndIf		
	
	If lTodos .Or. MV_PAR31 == 1 //Grupo Jurídico / Centro de Custo
		aFila := J170Array(aFila, "CTBA030", "CTT", {"CTT_CUSTO"})
	EndIf		
	
	If lTodos .Or. MV_PAR32 == 1 //Municípios
		aFila := J170Array(aFila, "FISA010", "CC2", {"CC2_EST", "CC2_CODMUN"})
	EndIf
	
	If lTodos .Or. MV_PAR32 == 1 //Países
		aFila := J170Array(aFila, "JURA194", "SYA", {"YA_CODGI"})
	EndIf	
		
	If lTodos .Or. MV_PAR03 == 1 //Idioma de faturamento
		aFila := J170Array(aFila, "JURA029", "NR1", {"NR1_COD"})
	EndIf	
		
	If lTodos .Or. MV_PAR04 == 1 //Fechamento Período
		aFila := J170Array(aFila, "JURA030", "NVQ", {"NVQ_COD"})
	EndIf

	If lTodos .Or. MV_PAR05 == 1 //Tipo de Honorário
		aFila := J170Array(aFila, "JURA037", "NRA", {"NRA_COD"})
	EndIf

	If lTodos .Or. MV_PAR06 == 1 //Área Jurídica
		aFila := J170Array(aFila, "JURA038", "NRB", {"NRB_COD"})
	EndIf

	If lTodos .Or. MV_PAR07 == 1 //Tipo de atividade
		aFila := J170Array(aFila, "JURA039", "NRC", {"NRC_COD"})
	EndIf

	If lTodos .Or. MV_PAR12 == 1 //Tipo Tabela de serviços
		aFila := J170Array(aFila, "JURA047", "NRK", {"NRK_COD"})
	EndIf	

	If lTodos .Or. MV_PAR08 == 1 //Serviços Tabelados
		aFila := J170Array(aFila, "JURA040", "NRD", {"NRD_COD"})
	EndIf

	If lTodos .Or. MV_PAR09 == 1 //Tabela de Serviços 
		aFila := J170Array(aFila, "JURA041", "NRE", {"NRE_COD"})
	EndIf	

	If lTodos .Or. MV_PAR10 == 1 //Tipos de despesas 
		aFila := J170Array(aFila, "JURA044", "NRH", {"NRH_COD"})
	EndIf	

	If lTodos .Or. MV_PAR13 == 1 //Subárea Jurídica
		aFila := J170Array(aFila, "JURA048", "NRL", {"NRL_COD"})
	EndIf	
	
	If lTodos .Or. MV_PAR15 == 1 //Categ Participantes
		aFila := J170Array(aFila, "JURA050", "NRN", {"NRN_COD"})
	EndIf		
	
	If lTodos .Or. MV_PAR16 == 1 //Docs E-bill
		aFila := J170Array(aFila, "JURA057", "NRW", {"NRW_COD"})
	EndIf			

	If lTodos .Or. MV_PAR17 == 1 //Empr E-bill
		aFila := J170Array(aFila, "JURA058", "NRX", {"NRX_COD"})
	EndIf	

	If lTodos .Or. MV_PAR18 == 1 //Escritórios
		aFila := J170Array(aFila, "JURA068", "NS7", {"NS7_COD"})
	EndIf	

	If lTodos .Or. MV_PAR20 == 1 //Feriados
		aFila := J170Array(aFila, "JURA078", "NW9", {"NW9_COD"})
	EndIf		

	If lTodos .Or. MV_PAR22 == 1 //Cotações Mensais
		aFila := J170Array(aFila, "JURA111", "NXQ", {"NXQ_ANOMES", "NXQ_CMOEDA"})
	EndIf							

	If lTodos .Or. MV_PAR23 == 1 //Localidades
		aFila := J170Array(aFila, "JURA123", "NTP", {"NTP_COD"})
	EndIf

	If lTodos .Or. MV_PAR27 == 1 //Tp Prestação Contas
		aFila := J170Array(aFila, "JURA164", "NUO", {"NUO_COD"})
	EndIf				

	If lTodos .Or. MV_PAR26 == 1 //Participantes
		aFila := J170Array(aFila, "JURA159", "RD0", {"RD0_CODIGO"})
	EndIf	

	If lTodos .Or. MV_PAR11 == 1 //Tipos de Originação
		aFila := J170Array(aFila, "JURA045", "NRI", {"NRI_COD"})
	EndIf	
	
	If lTodos .Or. MV_PAR25 == 1 //Clientes
		aFila := J170Array(aFila, "JURA148", "SA1", {"A1_COD", "A1_LOJA"})
	EndIf	

	If lTodos .Or. MV_PAR19 == 1 //Casos
		aFila := J170Array(aFila, "JURA070", "NVE", {"NVE_CCLIEN", "NVE_LCLIEN", "NVE_NUMCAS"})
	EndIf		

	If lTodos .Or. MV_PAR21 == 1 //Contratos
		aFila := J170Array(aFila, "JURA096", "NT0", {"NT0_COD"})
	EndIf		

	If lTodos .Or. MV_PAR34 == 1 //Tipo de Retorno / Situação de Cobrança
		aFila := J170Array(aFila, "JURA073", "NSC", {"NSC_COD"})
	EndIf

	If lTodos .Or. MV_PAR35 == 1 //Grupo de Clientes
		aFila := J170Array(aFila, "FATA110", "ACY", {"ACY_GRPVEN"})
	EndIf

	If lTodos .Or. MV_PAR36 == 1 //Condição de Pagamento
		aFila := J170Array(aFila, "MATA360", "SE4", {"E4_CODIGO"})
	EndIf

	If lTodos .Or. MV_PAR37 == 1 //Motivos de WO
		aFila := J170Array(aFila, "JURA140", "NXV", {"NXV_COD"})
	EndIf

	If lTodos .Or. MV_PAR38 == 1 //Tabela de Honorários
		aFila := J170Array(aFila, "JURA042", "NRF", {"NRF_COD"})
	EndIf

	If lTodos .Or. MV_PAR39 == 1 //Contatos
		aFila := J170Array(aFila, "TMKA070", "SU5", {"U5_CODCONT"})
	EndIf

	If  FWAliasInDic("NZQ") .And. (lTodos .Or. MV_PAR41 == 1) //Solicitação Aprovação de Despesas //PROTEÇÃO
		aFila := J170Array(aFila, "JURA235", "NZQ", {"NZQ_COD"})
	EndIf

	If lTodos .Or. MV_PAR42 == 1 //Consulta WO
		aFila := J170Array(aFila, "JURA146", "NUF", {"NUF_COD"})
	EndIf

	If lTodos .Or. MV_PAR43 == 1 //Natureza Financeira
		aFila := J170Array(aFila, "FINA010", "SED", {"ED_CODIGO"})
	EndIf
	
	If lTodos .Or. MV_PAR44 == 1 //Tabela de Rateio
		aFila := J170Array(aFila, "JURA238", "OH6", {"OH6_CODIGO"})
	EndIf	

	If lTodos .Or. MV_PAR45 == 1 //Lançamentos
		aFila := J170Array(aFila, "JURA241", "OHB", {"OHB_CODIGO"})
	EndIf
	
	If lTodos .Or. MV_PAR46 == 1 //Orçamentos
		aFila := J170Array(aFila, "JURA252", "SE7", {"E7_NATUREZ", "E7_ANO", "E7_CMOEDA", "E7_CESCR", "E7_CCUSTO", "E7_CPART", "E7_CRATEIO"})
	EndIf

	If lTodos .Or. MV_PAR47 == 1 //Calendário Contábil
		aFila := J170Array(aFila, "JURA253", "CQD", {"CQD_CALEND", "CQD_EXERC", "CQD_PERIOD", "CQD_PROC"})
	EndIf

	If lTodos .Or. MV_PAR48 == 1 // Pos. Ctas Receber
		aFila := J170Array(aFila, "JURA255", "OHH", {"OHH_PREFIX", "OHH_NUM", "OHH_PARCEL", "OHH_TIPO", "OHH_ANOMES", "OHH_CESCR", "OHH_CFATUR"})
	EndIf

	If lTodos .Or. MV_PAR49 == 1 //Controle Adiantam 
		aFila := J170Array(aFila, "JURA069", "NWF", {"NWF_COD"})
	EndIf

	If lTodos .Or. MV_PAR56 == 1 // Movimentações em Adiantamentos
		aFila := J170Array(aFila, "JURA311", "OI8", {"OI8_COD"})
	EndIf
	
	If lTodos .Or. MV_PAR50 == 1 //Rastreio de receb. por casos no Titulo da Fatura
		aFila := J170Array(aFila, "JURA256", "SE1", {"E1_PREFIXO", "E1_NUM", "E1_PARCELA", "E1_TIPO"})
	EndIf

	If lTodos .Or. MV_PAR51 == 1 //Bancos 
		aFila := J170Array(aFila, "MATA070", "SA6", {"A6_COD", "A6_AGENCIA", "A6_NUMCON"})
	EndIf

	If lTodos .Or. MV_PAR52 == 1 //Projetos e Finalidades
		aFila := J170Array(aFila, "JURA264", "OHL", {"OHL_COD"})
	EndIf	

	If lTodos .Or. MV_PAR53 == 1 //Fornecedores 
		aFila := J170Array(aFila, "MATA020", "SA2", {"A2_COD", "A2_LOJA"})
	EndIf

	If lTodos .Or. MV_PAR54 == 1 //Cobrança 
		aFila := J170Array(aFila, "JURA244", "OHD", {"OHD_COD"})
	EndIf

	If lTodos .Or. MV_PAR55 == 1 //Anexos 
		aFila := J170Array(aFila, "JURA290", "NUM", {"NUM_COD"})
	EndIf

	/* Gravação da Parte 1*/
	//Efetiva a gravação dos registros do array na fila de sincronização via banco
	If Len(aFila) > 0
		J170GRBCO(oGrid, aFila)
		aFila := {}
	EndIf
	/* Gravação da Parte 1*/

	oGrid:SetIncMeter(1)
	
	If lTodos .Or. MV_PAR02 == 1 //Lançamento Tabelado
		aFila := J170Array(aFila, "JURA027", "NV4", {"NV4_COD"})
	EndIf		

	If lTodos .Or. MV_PAR14 == 1 //Despesa
		aFila := J170Array(aFila, "JURA049", "NVY", {"NVY_COD"})
	EndIf	

	If lTodos .Or. MV_PAR24 == 1 //Time Sheet
		aFila := J170Array(aFila, "JURA144", "NUE", {"NUE_COD"})
	EndIf	

	If lTodos .Or. MV_PAR28 == 1 //Pré-faturas
		aFila := J170Array(aFila, "JURA202", "NX0", {"NX0_COD"})
	EndIf				
	
	If lTodos .Or. MV_PAR29 == 1 //Faturas
		aFila := J170Array(aFila, "JURA204", "NXA", {"NXA_CESCR", "NXA_COD"})
	EndIf		

	If lTodos .Or. MV_PAR40 == 1 //Fatura Adicional
		aFila := J170Array(aFila, "JURA033", "NVV", {"NVV_COD"})
	EndIf

	/* Gravação da Parte 2*/
	If Len(aFila) > 0
		J170GRBCO(oGrid, aFila)		
	EndIf
	/* Gravação da Parte 2*/

	oGrid:SetIncMeter(1)

	RestArea(aArea)

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} J170Array
Executa a varredura dos modelos e alimenta o array.

@param aFila    Array com os registros que devem ser incluídos na fila 
                de sincronização.
@param cModelo  Identificador do modelo (Ex. JURA204)
@param cTabela  Tabela para carga (Ex. NXA)
@param aCampos  Array com campos chave da tabela

@return aFila   Array com os registros incluídos na fila.

@author Cristina Cintra
@since 19/05/15
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J170Array(aFila, cModelo, cTabela, aCampos)
Local aArea     := GetArea()
Local cCampoFil := Iif(Substr(cTabela, 1, 1) == "S", Substr(cTabela, 2, 2) + "_FILIAL" , cTabela + "_FILIAL")
Local cFilTab   := ""
Local cChave    := "" 
Local nCpo      := 0

Default aFila   := {}
Default aCampos := {}

	DbSelectArea(cTabela)
	(cTabela)->( dbGoTop() )

	While !(cTabela)->(EOF())
		cFilTab := (cTabela)->(FieldGet(FieldPos(cCampoFil)))
		cChave := cFilTab

		For nCpo := 1 To Len(aCampos)
			cChave += (cTabela)->(FieldGet(FieldPos(aCampos[nCpo])))
		Next nCpo

		If J170Filter(cModelo, cTabela, cChave, aCampos)
			Aadd(aFila, {cModelo, cChave, ""})
		EndIf
		(cTabela)->(dbSkip())
	End
	
	RestArea(aArea)

Return aFila

//-------------------------------------------------------------------
/*/{Protheus.doc} J170GRBCO
Efetiva a gravação dos registros do array na fila de sincronização via banco.

@Param aFila   Array com os registros que devem ser incluídos na fila 
				de sincronização, contendo o modelo e a chave.

@author Cristina Cintra
@since 19/05/15
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J170GRBCO(oGrid, aFila)
Local aArea    := GetArea()
Local cOper    := "3" //Para a carga inicial será sempre inclusão
Local nQtdFila := 0 
Local nI       := 0

Default aFila := {}

	nQtdFila := Len(aFila)
	
	oGrid:SetMaxMeter(nQtdFila, 2, "%") 
	For nI := 1 to nQtdFila
		 aFila[nI][3] :=  GETSXENUM('NYS', 'NYS_CODIGO')
		If __lSX8
			ConfirmSX8()
		EndIf
	Next nI 
	

	For nI := 1 to nQtdFila
		RecLock("NYS", .T.)
		NYS->NYS_FILIAL := xFilial("NYS")
		NYS->NYS_CODIGO := aFila[nI][3]
		NYS->NYS_MODELO := aFila[nI][1]
		NYS->NYS_CHAVE  := aFila[nI][2]
		NYS->NYS_OPERAT := cOper
		NYS->NYS_TSTAMP := JurTime(.T., .F.)
		NYS->NYS_STATUS := "1"
		NYS->(MsUnlock())
		NYS->(DbCommit())
		
		oGrid:SetIncMeter(2)
	Next nI

	RestArea(aArea)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} J170Filter
Função genérica para execução de filtros na carga inicial

@param  cModelo  , caracter, ID do modelo de dados
@param  cTabela  , caracter, Alias do registro
@param  cChave   , caracter, Chave do registro
@param  aCampos  , array   , Campos da chave do registro
@return lFitler  , logico  , Verdadeiro/Falso

@author  Jonatas Martins
@since   14/02/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J170Filter(cModelo, cTabela, cChave, aCampos)
Local lFilter := .T.

Default cModelo := ""
Default cTabela := ""
Default cChave  := ""
Default aCampos := {}
	
	If cModelo == "JURA256"
		lFilter := J256FCarga(cChave)
	EndIf

	If cModelo == "JURA253"
		lFilter := 'FIN001' $ cChave .Or. ;
		           'FIN002' $ cChave .Or. ;
		           'PFS001' $ cChave
	EndIf

	If cModelo == "JURA290" .And. FindFunction("JGrAnxFila")
		lFilter := JGrAnxFila((cTabela)->NUM_ENTIDA)
	EndIf

Return ( lFilter )

//-------------------------------------------------------------------
/*/{Protheus.doc} J170Log
Gera o log com dados do modelo e da pilha de chamadas para o registro
que ficou com a chave em branco

@param  cModelo, ID do modelo de dados
@param  xModel , Modelo de dados em casos em que a manipulação 
                 está sendo feita via modelo ou o nome da tabela quando   
                 via Reclock
@param  cOper  , Operação do modelos de dados

@author  Jorge Martins
@since   01/02/2023
/*/
//-------------------------------------------------------------------
Static Function J170Log(cModelo, xModel, cOper)
Local cLog := ""

	cLog := STR0016 + cModelo + CRLF         // "Modelo: "
	cLog += J170RecLog(xModel, cOper) + CRLF // Recno do registro
	cLog += STR0017 + cOper + CRLF + CRLF    // "Operação: "
	cLog += STR0018 + CRLF + CRLF            // "Pilha de chamadas: "
	cLog += J170StackLog()

	// Faz a gravação do arquivo no protheus_data
	J170Savelog(cLog, cModelo)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J170RecLog
Gera a linha do log com o RECNO do registro

@param  xModel , Modelo de dados em casos em que a manipulação 
                 está sendo feita via modelo ou o nome da tabela quando   
                 via Reclock
@param  cOper  , Operação do modelos de dados

@return cLog   , Linha do Log com Recno do registro

@author  Jorge Martins
@since   01/02/2023
/*/
//-------------------------------------------------------------------
Static Function J170RecLog(xModel, cOper)
Local cLog       := ""
Local cId        := ""
Local nModel     := 0
Local nRecno     := 0
Local aSubModels := {}

	If cOper <> "5" // Na exclusão não será identificado o RECNO
		If ValType(xModel) == "C" .And. Len(xModel) == 3 // Quando o xModel vem com o nome da tabela
			cLog := STR0019 + xModel + ": " +  AllTrim(Str(&(xModel)->(Recno()))) // "Recno "
		
		ElseIf ValType(xModel) == "O" // Quando o xModel vem com o modelo
			
			// Procura o primeiro RECNO válido que é o do MASTER
			// E sai do laço assim que encontra
			
			aSubModels := aClone(xModel:GetAllSubModels())

			If ValType(aSubModels) == "A" .And. Len(aSubModels) > 0
				For nModel := 1 To Len(aSubModels)
					cId    := aSubModels[nModel]:GetID()
					nRecno := aSubModels[nModel]:GetDataID()

					If ValType(nRecno) == "N"
						cLog := STR0019 + cId + ": " + AllTrim(Str(nRecno)) // "Recno "
						Exit
					EndIf
				Next
			EndIf
		EndIf
	EndIf

Return cLog

//-------------------------------------------------------------------
/*/{Protheus.doc} J170StackLog
Gera a linha do log com a pilha de chamadas

@return cLog, Linha do Log com a pilha de chamadas

@author  Jorge Martins
@since   01/02/2023
/*/
//-------------------------------------------------------------------
Static Function J170StackLog()
Local cLog         := ""
Local cSource      := ""
Local cFunction    := ""
Local cDateTime    := ""
Local nLevel       := 0
Local nLine        := 0
Local aRet         := {}

	// Monta a pilha de execução
	Do While !Empty(ProcName(nLevel))
		cSource   := ProcSource(nLevel)  // Fonte
		cFunction := ProcName(nLevel)    // Função
		nLine     := ProcLine(nLevel)    // Linha
		aRet      := GetApoInfo(cSource) // Array com dados do fonte (Data e Hora)
		
		// Valida se é uma função. Necessário pois blocos de código entram na pilha mas não retornam dados na GetApoInfo
		If ValType(aRet) == "A" .And. Len(aRet) >= 5 .And. !Empty(aRet[4]) .And. !Empty(aRet[5])
			cDateTime := DtoC(aRet[4]) + " - " + aRet[5]
		Else
			cDateTime := ""
		EndIf

		// Formato: J170LOG(JURA170.PRW) 01/02/2023 - 18:23:46 - Linha: 728
		cLog += cFunction + "(" + cSource + ") " + cDateTime + " - " + STR0022 + AllTrim(Str(nLine)) + CRLF // "Linha: "

		nLevel ++
	EndDo

Return cLog

//-------------------------------------------------------------------
/*/{Protheus.doc} J170Savelog
Cria o arquivo de log na pasta JURLOGNYS dentro da protheus_data

@param  cLog   , Texto de log
@param  cModelo, ID do modelo de dados

@author  Jorge Martins
@since   01/02/2023
/*/
//-------------------------------------------------------------------
Static Function J170Savelog(cLog, cModelo)
Local cPath       := "\JURLOGNYS\"
Local cDate       := DtoS(Date())
Local cTime       := StrTran(Time(), ":", "")
Local cFileName   := ""
Local nHandle     := -1
Local lChangeCase := .F.
Local lCreated    := .T.
	
	If !ExistDir(cPath, Nil, lChangeCase)
		// Cria pasta JURLOGNYS caso não exista
		lCreated := MakeDir(cPath, Nil, lChangeCase) == 0
	EndIf

	If lCreated
		// Formato do nome do arquivo: JURA144_20230201_172123
		cFileName := cModelo + "_" + cDate + "_" + cTime + ".txt"
		nHandle   := FCreate(cPath + cFileName, Nil, Nil, lChangeCase)
		
		If nHandle == -1 // Erro ao criar arquivo
			JurLogMsg(i18N(STR0020, {cDate, cTime})) // "#1 - #2 - Falha ao criar o arquivo de log!"
		Else
			FWrite(nHandle, cLog)
			FClose(nHandle)
		EndIf
	Else
		JurLogMsg(i18N(STR0021, {cDate, cTime})) // "#1 - #2 - Falha ao criar o dirétorio de log!"
	EndIf

Return Nil

