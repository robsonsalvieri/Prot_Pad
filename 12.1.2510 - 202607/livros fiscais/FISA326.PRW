#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FISA326.CH"

#DEFINE GRUPOCODIGO	1
#DEFINE DESCRICAO  	2
#DEFINE VLDEDU		3
#DEFINE PREPAGO   	4
#DEFINE FATCENTRAL	5
#DEFINE COFAT		6

//-------------------------------------------------------------------
/*/{Protheus.doc} FISA326
Tabela de Código de Itens da NFCom (cClass) - Alias: CI0

Criada para armazenar os códigos de itens da NFCom (cClass) Modelo 62, 
possibilitando manutenção e atualização via importação.

Link para baixar a planilha p/ importação (importante converter p/ csv antes)
https://dfe-portal.svrs.rs.gov.br/NFCOM/tabelacclass

@author Denis Souza
@since 03/12/2025
@version 1.0

/*/
//-------------------------------------------------------------------
Function FISA326()

	Local oBrw := FWmBrowse():New() as object

	If AliasIndic("CI0")
		oBrw:SetDescription(STR0001) //"Tabela de Código de Itens da NFCom (cClass)"
		oBrw:SetAlias('CI0')
		oBrw:SetMenuDef('FISA326')
		oBrw:Activate()
	Else
		Help("",1,"Help","Help",STR0002,1,0) //"Tabela CI0 não cadastrada no sistema!"
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@return aRotina

@author Denis Souza
@since 03/12/2025
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina := {} as array

	ADD OPTION aRotina TITLE STR0003 ACTION 'ImportCI0()' 	  OPERATION 3 ACCESS 0 //"Importar"
	ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.FISA326' OPERATION 2 ACCESS 0 //"Visualizar"
	ADD OPTION aRotina TITLE STR0008 ACTION 'VIEWDEF.FISA326' OPERATION 4 ACCESS 0 //"Alterar"
	ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.FISA326' OPERATION 5 ACCESS 0 //"Excluir"
	ADD OPTION aRotina TITLE STR0007 ACTION 'VIEWDEF.FISA326' OPERATION 8 ACCESS 0 //"Imprimir"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Denis Souza
@since 03/12/2025
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

	Local oStru	:= FWFormStruct(1, 'CI0') as object
	Local oModel :=	MPFormModel():New('FISA326') as object

	oModel:AddFields('MODELO', /*cOwner*/, oStru)

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Denis Souza
@since 03/12/2025
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

	Local oModel := FWLoadModel('FISA326') as object
	Local oStru	 := FWFormStruct( 2, 'CI0' ) as object
	Local oView  := FWFormView():New() as object

	oView:SetModel(oModel)
	oView:AddField('VIEW', oStru, 'MODELO')

	oView:EnableTitleView('VIEW', STR0001) //"Tabela de Código de Itens da NFCom (cClass)"
	oView:CreateHorizontalBox('FIELDS', 100)
	oView:SetOwnerView('VIEW', 'FIELDS')

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ImportCI0
Importação da Tabela Código Item NFCom cClas

@return Nil
@author Denis Souza
@since 03/12/2025
@version 1.0
/*/
//-------------------------------------------------------------------
Function ImportCI0()

	Local cFile	:= "" as character
	Local cTipo := OemToAnsi("CSV|") + '*.CSV' as character

	cFile := cGetFile(cTipo, OemToAnsi(STR0001), 1,,.T., 1+16+32, .T.) //"Tabela de Código de Itens da NFCom (cClass)"
	
	MsgRun(STR0005,"",{||ProcessCI0(cFile)}) //"Processando..."

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcessCI0
Processa o arquivo

@return lRet
@author Denis Souza
@since 03/12/2025
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ProcessCI0( cArqTxt as character, lAutoEr as boolean )

Local cLinha	 := "" as character
Local cFil       := "" as character
Local cGrpCod    := "" as character
Local aContent   := {} as array
Local aFormat    := {} as array
Local aStru      := {'Grupo/Código','Descrição','Valor Deduzido','Pré Pago','Fat Central','COFAT'} as array
Local nx		 := 0 as numeric
Local nSizeDef   := 0 as numeric
Local nTmCont    := 0 as numeric
Local nHandle    := 0 as numeric
Local nTmGrpCod  := GetSx3Cache("CI0_GRPCOD", "X3_TAMANHO") as numeric
Local nTmDesc    := GetSx3Cache("CI0_DESCRI", "X3_TAMANHO") as numeric
Local lRet       := .T. as boolean
Local lFind      := .F. as boolean
Local lLock      := .F. as boolean

Default cArqTxt  := ''
Default lAutoEr  := .F.

nHandle := FT_FUse(cArqTxt) //Abre o arquivo

if !("CSV" $ upper(cArqTxt)) .Or. (nHandle == -1) // Se houver erro de abertura abandona processamento
	MsgStop( STR0011, STR0001 ) //"Falha na abertura do arquivo, rotina cancelada."##"Tabela de Código de Itens da NFCom (cClass)"
	lRet := .F.
endif

If lRet
	nSizeDef := len(aStru)
	cFil := xFilial("CI0")
	FT_FSkip() //pular primeira linha referente ao header
	While (!FT_FEof()) //Persiste layout
		cLinha := FT_FREADLN()
		aFormat := separa( cLinha , ";" )
		nX := len( aFormat )
		If nX < nSizeDef
			MsgStop( STR0012, STR0001 ) //""Falha na persistência do arquivo, layout inválido.""##"Tabela de Código de Itens da NFCom (cClass)"
			lRet := .F.
			Exit
		else
			aadd( aContent, aFormat )
		Endif
		FT_FSkip()
	Enddo
	FT_FUse() //Fecha o Arquivo

	nTmCont := len( aContent )
	If lRet	.And. nTmCont > 0
		CI0->(DbSetOrder( 1 ) ) //CI0_FILIAL, CI0_GRPCOD
		Begin Transaction
			For nX := 1 to nTmCont
				cGrpCod := Padr( Alltrim(aContent[nX][GRUPOCODIGO]) , nTmGrpCod )
				lFind := CI0->(DbSeek( cFil + cGrpCod ) )
				lLock := CI0->(RecLock("CI0", !lFind))
				If !lLock .Or. lAutoEr
					lRet := .F.
					DisarmTransaction()
					Break
				EndIf
				If !lFind
					CI0->CI0_FILIAL := cFil
					CI0->CI0_GRPCOD := cGrpCod
				EndIf
				CI0->CI0_DESCRI := Alltrim(SubStr(aContent[nX][DESCRICAO],1,nTmDesc))
				CI0->CI0_VALDED := Iif(Upper(AllTrim(aContent[nX][VLDEDU]))     == "SIM","1","0")
				CI0->CI0_PREPAG := Iif(Upper(AllTrim(aContent[nX][PREPAGO]))    == "SIM","1","0")
				CI0->CI0_FATCEN := Iif(Upper(AllTrim(aContent[nX][FATCENTRAL])) == "SIM","1","0")
				CI0->CI0_COFAT  := Iif(Upper(AllTrim(aContent[nX][COFAT]))      == "SIM","1","0")
				CI0->(MsUnlock())
			Next nX
		End Transaction
		if lRet
			CI0->(DbGotop())
			MsgInfo(STR0009, STR0001) //"Importação da Tabela concluída!"##"Tabela de Código de Itens da NFCom (cClass)"
		else
			MsgStop(STR0013, STR0001) //"Falha ao reservar e gravar o registro na tabela CI0."#"Tabela de Código de Itens da NFCom (cClass)"
		endif
	endif
EndIf

Return lRet
