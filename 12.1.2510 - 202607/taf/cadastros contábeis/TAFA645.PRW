#include "totvs.ch"
#include "FWMVCDEF.CH"
#include "TAFA645.CH"

// Colunas do CSV T7H (posições 1-based)
#DEFINE TAF645_COL_PERIOD  1
#DEFINE TAF645_COL_TIPDED  2
#DEFINE TAF645_COL_TIPO    3
#DEFINE TAF645_COL_TPDEST  4
#DEFINE TAF645_COL_CGC     5
#DEFINE TAF645_COL_VALDED  6
#DEFINE TAF645_COL_OBSERV  7
#DEFINE TAF645_CSV_COLS    7
#DEFINE TAF645_BULK_FLUSH  500
#DEFINE TAF645_NOTICE_DAYS 30

Static oCSS := totvs.framework.css.ProtheusTheme():New()

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA645
Reg.Y730-Identificação dos Donatários/Destinatários de Deduções do IRPJ/CSLL
@type function
@author Carlos Pister
@since 30/03/2026
@version 1.0
@return Nil, sem retorno
*/
//-------------------------------------------------------------------
Function TAFA645()

Local oBrw := FWmBrowse():New()

If TAFAlsInDic( "T7H" )
	oBrw:SetDescription(STR0001) //"Identificação dos Donatários/Destinatários de Deduções do IRPJ/CSLL"
	oBrw:SetAlias( 'T7H')
	oBrw:SetMenuDef( 'TAFA645' )
	T7H->( DBSetOrder( 1 ) )
	oBrw:Activate()
else
	Aviso(STR0002,TafAmbInvMsg(),{STR0003},3) //##"Dicionário Incompatível" ##"Encerrar"
endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu
@type function
@author Carlos Pister
@since 30/03/2026
@version 1.0
@return Array, Array de opções de menu
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aFuncao := {}
Local aRotina := {}

Aadd( aFuncao, { STR0037 , "ImportT7H", , 3 } ) //"Importar Registro"

aRotina := xFunMnuTAF( "TAFA645" , , aFuncao )

Return( aRotina )

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model
@type function
@author Carlos Pister
@since 30/03/2026
@version 1.0
@return Object, Objeto do Modelo MVC
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oStruT7H	:= Nil as object
Local oModel	:= Nil as object

oStruT7H :=	FWFormStruct( 1, "T7H" )

oModel	 :=	MPFormModel():New( "TAFA645",,, { |oModel| SaveModel( oModel ) } )

oModel:AddFields( "MODEL_T7H", /*cOwner*/, oStruT7H )
oModel:GetModel( "MODEL_T7H" ):SetPrimaryKey( { "T7H_FILIAL", "T7H_ID" } )

Return( oModel )

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View
@type function
@author Carlos Pister
@since 30/03/2026
@version 1.0
@return Object, Objeto da View MVC
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oModel   := FWLoadModel( 'TAFA645' )
Local oStruT7H := FWFormStruct( 2, "T7H" )
Local oView	   := FWFormView():New()

oView:SetModel( oModel )

oView:AddField( "VIEW_T7H", oStruT7H, "MODEL_T7H")
oView:EnableTitleView("VIEW_T7H",STR0004) //"Identificação dos Donatários/Destinatários de Deduções do IRPJ/CSLL"

/*-----------------------------------------------------------------------------------
Estrutura do Folder
-------------------------------------------------------------------------------------*/
oView:CreateHorizontalBox("PAINEL_PRINCIPAL", 100 )
oView:CreateFolder("FOLDER_PRINCIPAL","PAINEL_PRINCIPAL")

/*-----------------------------------------------------------------------------------
Amarração para exibição das informações
-------------------------------------------------------------------------------------*/
oView:SetOwnerView( 'VIEW_T7H', 'PAINEL_PRINCIPAL' )

/*-----------------------------------------------------------------------------------
Esconde campos de controle interno
-------------------------------------------------------------------------------------*/
oStruT7H:RemoveField( "T7H_ID" )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao de gravacao dos dados, chamada no final, no momento da confirmacao do modelo
@type function
@author Carlos Pister
@since 30/03/2026
@version 1.0
@param oModel, Object, Modelo de dados
@return Logical, .T. se gravação concluída com sucesso
/*/
//-------------------------------------------------------------------
Static Function SaveModel(oModel)

Local nOperation := oModel:GetOperation() as numeric

Begin Transaction 
	
	If nOperation == MODEL_OPERATION_UPDATE 
		TAFAltStat( "T7H", " " )
	EndIf  

	FwFormCommit( oModel )
			
End Transaction 

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} T7HTipDed
Combo no campo tipo de dedução T7H_TIPDED
@type function
@author Carlos Pister
@since 30/03/2026
@version 1.0
@return Character, String com os valores do combo
/*/
//-------------------------------------------------------------------
Function T7HTipDed()

Local cString := "" as character

cString := "10="  + STR0005 + ";" //"Operações de Caráter Cultural e Artístico"
cString += "20="  + STR0006 + ";" //"Programa de Alimentação do Trabalhador"
cString += "30="  + STR0007 + ";" //"Desenvolvimento Tecnológico Industrial / Agropecuário"
cString += "40="  + STR0008 + ";" //"Atividade Audiovisual"
cString += "50="  + STR0009 + ";" //"Fundos dos Direitos da Criança e do Adolescente"
cString += "60="  + STR0010 + ";" //"Fundos Nacional, Estaduais ou Municipais do Idoso (Lei nº 12.213/2010, art. 3º)"
cString += "70="  + STR0011 + ";" //"Atividades de Caráter Desportivo"
cString += "80="  + STR0012 + ";" //"Programa Nacional de Apoio à Atenção Oncológica - PRONON (Lei nº 12.715/2012, arts. 1º e 4º)"
cString += "90="  + STR0013 + ";" //"Programa Nacional de Apoio à Atenção da Saúde da Pessoa com Deficiência - PRONAS/PCD (Lei nº 12.715/2012, arts. 3º e 4º)"
cString += "100=" + STR0014 + ";" //"Valor da Remuneração da Prorrogação da Licença-Maternidade e da Licença-Paternidade  (Lei nº 11.770/2008, art. 5º)"
cString += "110=" + STR0015 + ";" //"Incentivo a Projetos de Reciclagem (Art. 3º, da Lei nº 14.260/2021)"
cString += "120=" + STR0016       //"Outras Deduções"

Return( cString )

//-------------------------------------------------------------------
/*/{Protheus.doc} T7HTDed
Validação campo T7H_TIPDED
@type function
@author Carlos Pister
@since 30/03/2026
@version 1.0
@param cCombo, Character, Valor selecionado no combo
@return Logical, .T. se valor válido
/*/
//-------------------------------------------------------------------
Function T7HTDed(cCombo as character)
	
Local lRet := .F. as logical

Default cCombo := ""    

If "|" + AllTrim(cCombo) + "|" $ "|10|20|30|40|50|60|70|80|90|100|110|120|"
	lRet := .T.
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} T7HTipDoa
Combo no campo tipo de doação T7H_TIPO
@type function
@author Carlos Pister
@since 30/03/2026
@version 1.0
@return Character, String com os valores do combo
/*/
//-------------------------------------------------------------------
Function T7HTipDoa()

Local cString := "" as character

cString := "10="  + STR0017 + ";" //"Dinheiro"
cString += "20="  + STR0018 + ";" //"Prédio residencial"
cString += "30="  + STR0019 + ";" //"Prédio comercial"
cString += "40="  + STR0020 + ";" //"Galpão"
cString += "50="  + STR0021 + ";" //"Apartamento"
cString += "60="  + STR0022 + ";" //"Casa"
cString += "70="  + STR0023 + ";" //"Terreno"
cString += "80="  + STR0024 + ";" //"Terra nua"
cString += "90="  + STR0025 + ";" //"Sala ou conjunto"
cString += "100=" + STR0026 + ";" //"Construção"
cString += "110=" + STR0027 + ";" //"Benfeitorias"
cString += "120=" + STR0028 + ";" //"Loja"
cString += "130=" + STR0029 + ";" //"Veículo automotor terrestre: caminhão, automóvel, moto etc."
cString += "140=" + STR0030 + ";" //"Aeronave"
cString += "150=" + STR0031 + ";" //"Embarcação"
cString += "160=" + STR0032 + ";" //"Joia, quadro, objeto de arte, antiguidade etc."
cString += "170=" + STR0033 + ";" //"Linha telefônica"
cString += "970=" + STR0034 + ";" //"Outros bens e direitos"
cString += "980=" + STR0035 + ";" //"Outros bens móveis"
cString += "990=" + STR0036       //"Outros bens imóveis"

Return( cString )

//-------------------------------------------------------------------
/*{Protheus.doc} T7HTipo
Validação campo T7H_TIPO
@author Carlos Pister
@since 30/03/2026
@version 1.0
/*/
//-------------------------------------------------------------------
Function T7HTipo(cCombo as character)
	
Local lRet := .F. as logical

Default cCombo := ""

If "|" + AllTrim(cCombo) + "|" $ "|10|20|30|40|50|60|70|80|90|100|110|120|130|140|150|160|170|970|980|990|"
	lRet := .T.
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} T7HCGC
Verifica a máscara do campo T7H_CGC
@type function
@author Carlos Pister
@since 30/03/2026
@version 1.0
@param cTipo, Character, Tipo do CGC (1 para CPF, 2 para CNPJ)
@return Character, Máscara de exibição do campo
/*/
//-------------------------------------------------------------------
Function T7HCGC()
	
Local cPict := "" as character

If M->T7H_TPDEST == "1"
	cPict := "@R 999.999.999-99"		
Else
	cPict := "@R! NN.NNN.NNN/NNNN-99"
EndIf

cPict := cPict +"%C"

Return cPict

//-------------------------------------------------------------------
/*/{Protheus.doc} ImportT7H
Abre diálogo para seleção de arquivo CSV e dispara importação T7H
@type function
@author Carlos Pister
@since 08/04/2026
@version 1.0
@return Nil, sem retorno
/*/
//-------------------------------------------------------------------
Function ImportT7H()

Local cFile := "" as character
Local cMask := OemToAnsi("CSV|") + "*.CSV" as character

NoticeT7H()

cFile := cGetFile(cMask, OemToAnsi(STR0001), 1,,.T., 1+16+32, .T.)

If !Empty(cFile)
    MsgRun(STR0059, "", {|| ProcessT7H(cFile)}) //"Processando..."
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcessT7H
Orquestra a leitura, validação e gravação do CSV na tabela T7H
@type function
@author Carlos Pister
@since 08/04/2026
@version 1.0
@param cArqTxt, Character, Caminho completo do arquivo CSV
@return Logical, .T. se processado com sucesso
/*/
//-------------------------------------------------------------------
Function ProcessT7H(cArqTxt as character)

Local aContent := {}  as array
Local aErrors  := {}  as array
Local lRet     := .T. as logical
Local cDir     := ""  as character
Local cBarra   := ""  as character

Default cArqTxt := ""

cBarra := "/"

If GetRemoteType() <> 2 //0 = QT Win 6e7; 1 = QT Win 8e10; 2 = QT linux 8e10 ; 3 = nao utilizado; 4 = telnet; 5 smartclient html; 6=nao utilizado; 6 smartclient windows C
    cBarra := "\"
EndIf

cDir := Left(cArqTxt, RAt(cBarra, cArqTxt))

lRet := ReadCsvT7H(cArqTxt, @aContent, @aErrors)

If lRet .And. Len(aContent) > 0
    lRet := SaveT7HData(aContent, @aErrors)
EndIf

If Len(aErrors) > 0
    ShowT7HLog(aErrors, cDir)
ElseIf !lRet
    MsgInfo(STR0060) //"Arquivo vazio ou com formato inválido."
Else
    MsgInfo(STR0038) //"Importação concluída com sucesso!"
EndIf

FwFreeArray(aContent)
FwFreeArray(aErrors)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ReadCsvT7H
Lê e valida as linhas do CSV para importação na tabela T7H
@type function
@author Carlos Pister
@since 08/04/2026
@version 1.0
@param cArqTxt, Character, Caminho do arquivo CSV
@param aContent, Array, Array com linhas válidas (passado por referência)
@param aErrors, Array, Array com mensagens de erro (passado por referência)
@return Logical, .T. se arquivo aberto e lido com sucesso
/*/
//-------------------------------------------------------------------
Static Function ReadCsvT7H(cArqTxt as character, aContent as array, aErrors as array)

Local cLinha  := "" as character
Local cErrMsg := "" as character
Local aRow    := {} as array
Local aLines  := {} as array
Local nLine   := 0  as numeric
Local lRet    := .F. as logical
Local oFile   := Nil as object

Default cArqTxt := ""

oFile := FWFileReader():New(cArqTxt)

If oFile:Open()
    lRet := .T.
    aLines := oFile:getAllLines()

    For nLine := 2 To Len(aLines) // Ignora a primeira linha do CSV (cabeçalho)
        cLinha := aLines[nLine]
        aRow   := Separa(cLinha, ";")

        If Len(aRow) < TAF645_CSV_COLS
            AAdd(aErrors, STR0039 + cValToChar(nLine) + STR0040) //"Linha "# ": colunas insuficientes."
        ElseIf VldT7HRow(@aRow, nLine, @cErrMsg)
            AAdd(aContent, aRow)
        Else
            AAdd(aErrors, cErrMsg)
        EndIf
    Next nLine

    oFile:Close()
EndIf

FwFreeArray(aLines)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} VldT7HRow
Valida os campos T7H_TIPDED e T7H_TIPO de uma linha do CSV T7H
@type function
@author Carlos Pister
@since 08/04/2026
@version 1.0
@param aRow, Array, Array com os campos da linha (passado por referência)
@param nLine, Numeric, Número da linha para mensagem de log
@param cErrMsg, Character, Mensagem de erro de retorno (passado por referência)
@return Logical, .T. se linha válida
/*/
//-------------------------------------------------------------------
Static Function VldT7HRow(aRow as array, nLine as numeric, cErrMsg as character)

Local cTipDed := AllTrim(aRow[TAF645_COL_TIPDED]) as character
Local cTipo   := AllTrim(aRow[TAF645_COL_TIPO])   as character
Local lRet    := .T. as logical

cErrMsg := ""

If Empty(aRow[TAF645_COL_PERIOD]) .Or. Empty(aRow[TAF645_COL_TIPDED]) .Or. Empty(aRow[TAF645_COL_TIPO]) .Or. Empty(aRow[TAF645_COL_TPDEST]) .Or. Empty(aRow[TAF645_COL_CGC]) .Or. Empty(aRow[TAF645_COL_VALDED])
    cErrMsg += STR0039 + cValToChar(nLine) + STR0041 + Chr(13)+Chr(10) //"Linha " + ": Campos obrigatórios não preenchidos."
    lRet := .F.
EndIf

If !T7HTDed(cTipDed)
    cErrMsg += STR0039 + cValToChar(nLine) + STR0042 + cTipDed + STR0043 + Chr(13)+Chr(10) //"Linha " + "": Tipo de dedução [" + "] inválido, coluna 2."
    lRet := .F.
EndIf

If !T7HTipo(cTipo)
    cErrMsg += STR0039 + cValToChar(nLine) + STR0044 + cTipo + STR0045 + Chr(13)+Chr(10) //"Linha " + "": Tipo [" + "] inválido, coluna 3."
    lRet := .F.
EndIf

If !ValidCgc(@aRow)
    cErrMsg += STR0039 + cValToChar(nLine) + STR0046 + AllTrim(aRow[TAF645_COL_CGC]) + STR0047 + Chr(13)+Chr(10)  //"Linha " + "": CNPJ/CPF [" inválido, coluna 4."
    lRet := .F.
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveT7HData
Grava na tabela T7H os registros validados do CSV
@type function
@author Carlos Pister
@since 08/04/2026
@version 1.0
@param aContent, Array, Array com dados das linhas válidas
@param aErrors, Array, Array de erros (passado por referência)
@return Logical, .T. se todos os registros gravados com sucesso
/*/
//-------------------------------------------------------------------
Static Function SaveT7HData(aContent as array, aErrors as array)

Local nTmTpDed   := GetSx3Cache("T7H_TIPDED", "X3_TAMANHO") as numeric
Local nTmTipo    := GetSx3Cache("T7H_TIPO",   "X3_TAMANHO") as numeric
Local nTmTpDest  := GetSx3Cache("T7H_TPDEST", "X3_TAMANHO") as numeric
Local nTmCgc     := GetSx3Cache("T7H_CGC",    "X3_TAMANHO") as numeric
Local nTmObsrv   := GetSx3Cache("T7H_OBSERV", "X3_TAMANHO") as numeric
Local nX         := 0 as numeric
Local lRet       := .T. as logical
Local oBulk      := Nil as object
Local aFields    := {"T7H_FILIAL","T7H_ID","T7H_PERIOD","T7H_TIPDED","T7H_TIPO","T7H_TPDEST","T7H_CGC","T7H_VALDED","T7H_OBSERV"} as array 
Local aStructT7H := {} as array

aStructT7H := BulkField(aFields)

oBulk := FwBulk():New(RetSqlName("T7H"))
oBulk:SetFields(aStructT7H)

Begin Transaction

    For nX := 1 To Len(aContent)
        oBulk:AddData({;
            xFilial("T7H"),;
            FWUUID("T7H"),;
            cTod(AllTrim(aContent[nX][TAF645_COL_PERIOD])),;
            Padr(AllTrim(aContent[nX][TAF645_COL_TIPDED]), nTmTpDed),;
            Padr(AllTrim(aContent[nX][TAF645_COL_TIPO]),   nTmTipo),;
            Padr(AllTrim(aContent[nX][TAF645_COL_TPDEST]), nTmTpDest),;
            Padr(AllTrim(aContent[nX][TAF645_COL_CGC]),    nTmCgc),;
            Val(AllTrim(aContent[nX][TAF645_COL_VALDED])),;
            Padr(AllTrim(aContent[nX][TAF645_COL_OBSERV]), nTmObsrv);
        })

        If nX % TAF645_BULK_FLUSH == 0
            If !oBulk:Flush()
                AAdd(aErrors, STR0048 + oBulk:GetError()) //"FWBulk falhou: "
                lRet := .F.
                DisarmTransaction()
                Exit
            EndIf
        EndIf
    Next nX

    If lRet
        If !oBulk:Close()
            AAdd(aErrors, STR0048 + oBulk:GetError()) //"FWBulk falhou: "
            lRet := .F.
            DisarmTransaction()
        EndIf
    EndIf

End Transaction

oBulk:Destroy()
FwFreeArray(aStructT7H)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ShowT7HLog
Grava e exibe o log de erros da importação T7H
@type function
@author Carlos Pister
@since 08/04/2026
@version 1.0
@param aErrors, Array, Array com mensagens de erros da importação
@param cDir, Character, Caminho do diretório para gravação do arquivo de log
@return Nil, sem retorno
/*/
//-------------------------------------------------------------------
Static Function ShowT7HLog(aErrors as array, cDir as character)

Local cLogFile    := "LOG_IMPORTT7H_" + DToS(Date()) + ".txt" as character
Local cLogContent := "" as character
Local nX          := 0 as numeric

If Len(aErrors) > 0

    cLogContent := STR0049 + DToS(Date()) + Chr(13)+Chr(10) //"Log de Importacao Y730 - "
    cLogContent += "=================================================" + Chr(13)+Chr(10)

    For nX := 1 To Len(aErrors)
        cLogContent += aErrors[nX] + Chr(13)+Chr(10)
    Next nX

    MemoWrite(cDir + cLogFile, cLogContent)

    MsgStop(STR0050 + cValToChar(Len(aErrors)) + STR0051 + cDir + cLogFile, STR0001) //"Importacao com " #" erro(s). Log salvo em: " 
EndIf

Return

/*/{Protheus.doc} BulkField
Obtém os campos da SX3 e os transforma em estrutura idêntica ao DBStruct
@type function
@author Carlos Pister
@since 22/01/2026
@version 12.1.2510
@param aFields, Array, Array com os nomes dos campos da SX3
@return Array, Estrutura de campos para uso em FwBulk:SetFields
/*/
Static Function BulkField( aFields as array)

Local aStructTab := {} as array
Local aStructCpo := {} as array
Local nPosCpo    := 0  as numeric

For nPosCpo := 1 To Len(aFields)
    aStructCpo:= FWSX3Util():GetFieldStruct(aFields[nPosCpo]) 
	aAdd(aStructTab, { aStructCpo[1], aStructCpo[2], aStructCpo[3], aStructCpo[4] })
Next

FwFreeArray(aStructCpo)

Return (aStructTab)

//-------------------------------------------------------------------
/*/{Protheus.doc} ValidCgc
Validação do CNPJ/CPF do campo T7H_CGC, considerando o tipo de destinatário (T7H_TPDEST)
@type function
@author Carlos Pister
@since 30/03/2026
@version 1.0
@param aRow, Array, Array com os campos da linha do CSV (passado por referência)
@return Logical, .T. se o CNPJ/CPF é válido
/*/
//-------------------------------------------------------------------
Static Function ValidCgc(aRow as array)

Local lRet := .T. as logical
	
If aRow[TAF645_COL_TPDEST] == "1" 	//CPF
    If Len(AllTrim(aRow[TAF645_COL_CGC])) < 11
        aRow[TAF645_COL_CGC] := PadL( AllTrim(aRow[TAF645_COL_CGC]), 11, "0" )
    EndIf
	If Len(AllTrim(aRow[TAF645_COL_CGC])) <> 11 .Or. !CGC(aRow[TAF645_COL_CGC],,.F.) 
		lRet	:=	.F.
	EndIf
ElseIf aRow[TAF645_COL_TPDEST] == "2" 	//CNPJ
    If Len(AllTrim(aRow[TAF645_COL_CGC])) < 14
        aRow[TAF645_COL_CGC] := PadL( AllTrim(aRow[TAF645_COL_CGC]), 14, "0" )
    EndIf
	If Len(AllTrim(aRow[TAF645_COL_CGC])) <> 14 .Or. !CGC(aRow[TAF645_COL_CGC],,.F.) 
		lRet	:=	.F.
	EndIf
EndIf

Return lRet

/*/{Protheus.doc} NoticeT7H
Função responsável por controlar a exibição de um aviso sobre a obrigatoriedade do registro Y730, 
que deve ser apresentado na importação do CSV, podendo ser desabilitado por um período de n dias.
@type function
@author Carlos Pister
@since 08/04/2026
@version 1.0
@return Nil, sem retorno
/*/
Static Function NoticeT7H()

Local dDate      	:= Date() as date
Local oProfile   	:= Nil as object
Local aLoad      	:= {}  as array
Local cShow      	:= ""  as character
Local lCheck     	:= .F. as logical
Local nPauseDays	:= 0   as numeric

// numero de dias que pode ser desabilitada a mensagem
nPauseDays	:= TAF645_NOTICE_DAYS

oProfile := FwProFile():New()
oProfile:SetTask("T7HExpired") //Nome da sessão
aLoad := oProfile:Load()
If Empty(aLoad)
	cShow := "00000000"
Else
	cShow := aLoad[1]
Endif

// reseta o controle de nPauseDays dias e volta apresentar a tela de advertencia
If cShow <> "00000000" .and. STOD(cShow) + nPauseDays <= dDate
	cShow := "00000000"
	oProfile:SetProfile({cShow})
	oProfile:Save()
ENDIF

If cShow == "00000000"
	lCheck := ModImpCsv(nPauseDays)
	If lCheck
		cShow := dtos(date())
		oProfile:SetProfile({cShow})
		oProfile:Save()
	EndIf
EndIf

oProfile:Destroy()
oProfile := nil
FwFreeArray(aLoad)

Return

/*/{Protheus.doc} ModImpCsv
Função responsável por renderizar o modal com as informações sobre o registro Y730.
@type function
@author Carlos Pister
@since 08/04/2026
@version 1.0
@param nPauseDays, Numeric, Número de dias para inibir a exibição do aviso
@return Logical, .T. se o usuário optou por não exibir a mensagem pelos próximos n dias
/*/
Static Function ModImpCsv(nPauseDays as numeric)

Local cWarning		:= ""  as character
Local cDisclaimer	:= ""  as character
Local cLink     	:= ""  as character
Local oModal 		:= Nil as object
Local oWarning		:= Nil as object
Local oDisclaimer	:= Nil as object
Local oContainer	:= Nil as object
Local oCheck1		:= Nil as object
Local lCheck        := .F. as logical

cLink	:= "https://tdn.totvs.com/pages/viewpage.action?pageId=1059302421"
oModal 	:= FWDialogModal():New()

oModal:SetEscClose(.T.)
oModal:SetTitle(STR0052) // "Importação registro Y730"
oModal:SetSize(150, 250)
oModal:CreateDialog()
oModal:AddCloseButton(Nil, STR0053) // "Fechar"

oContainer := TPanel():New(000, 000,, oModal:GetPanelMain(),, .T.,,,, 249, 091,, .T.)

cWarning := '<p>' + STR0054 + '</p>' // "O registro Y730 na ECF 2026 (ano-calendário 2025) é uma nova obrigatoriedade para empresas no Lucro Real que utilizam deduções de incentivos fiscais no IRPJ/CSLL."
cWarning += '<p>' + STR0055 + '</p>' // "Ele exige a identificação detalhada (CNPJ/CPF) dos donatários/beneficiários, aumentando a rastreabilidade do Fisco sobre doações, patrocínios, PAT e licença maternidade/paternidade.

oWarning := TSay():New(002, 002, {|| cWarning}, oContainer,,,,,, .T.,,, 240, 090,,,,,, .T., 3)

oWarning:SetCss("TSay { font-size: 12px; }")

cDisclaimer := '<p>' + STR0056 + '</p>' // "Para mais informações, acesse a documentação no TDN."

oDisclaimer := TSay():New(050, 002, {|| cDisclaimer}, oContainer,,,,,, .T.,,, 240, 090,,,,,, .T., 2)

oDisclaimer:SetCss("TSay { font-size: 12px; color: " + oCSS:oTheme:brand01Dark + "; }")

THButton():New(065, 060, STR0057, oContainer, {|| ShellExecute("open", cLink, "", "", 1)}, 120, 010,, cLink) // "Clique aqui para acessar a documentação."

oCheck1 := TCheckBox():New(080,002,i18n(STR0058,{strzero(nPauseDays,2)}) ,{|x|If(Pcount()==0,lCheck,lCheck:=x)},oContainer,220,010,,,,,,,,.T.,,,) // "Não apresentar esta mensagem nos proximos #1[30]# dias."

oModal:Activate()	

Return lCheck
