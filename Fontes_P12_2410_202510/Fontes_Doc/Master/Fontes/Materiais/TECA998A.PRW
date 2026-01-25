#Include 'Totvs.ch'
#Include 'FWMVCDef.ch'

Static aCelulas := {}
Static cTitle   := "Fake Cab"
Static cXML     := ""
Static nTamCamp := 0
Static nQtdCol  := 0
Static nQtdLin  := 0
Static cAliasTmp := ""

//------------------------------------------------------------------------------
/*/{Protheus.doc} TECA998A
Visualizador em MVC do XML da planilha gerada pelo FWUIWORKSHEET.
@sample 	TECA998() 
@param		oModel740 -> Objeto Model do TECA740
            oView740 -> Objeto View do TECA740

@author     Jack Junior
@since		21/02/2024      
/*/
//------------------------------------------------------------------------------
Function TECA998A(oModel740, oView740)
Local aArea         := {}
Local aButtons      := {}
Local cNameCol      := "A"
Local lFacilit      := .T.
Local lGSLE         := .T.
Local lLocEq        := .F.
Local lTecItExtOp 	:= IsInCallStack("At190dGrOrc")
Local nX            := 0
Local oTempTable    := Nil

//Desabilita os atalhos enquanto visualização esta aberta:
SetKey(VK_F4, NIL)
SetKey(VK_F7, NIL)
SetKey(VK_F8, NIL)
SetKey(VK_F9, NIL)
SetKey(VK_F10, NIL)

lFacilit  := IsInCallStack("At984aPlPc")
lGSLE     := GSGetIns("LE")
aButtons  := {{.F.,Nil},;       //Copiar
              {.F.,Nil},;       //Recortar
              {.F.,Nil},;       //Colar
              {.F.,Nil},;       //Calculadora
              {.F.,Nil},;       //Spool
              {.F.,Nil},;       //Imprimir
              {.F.,Nil},;       //Confirmar
              {.T.,"Fechar"},;  //Cancelar
              {.F.,Nil},;       //WalkTrhough
              {.F.,Nil},;       //Ambiente
              {.F.,Nil},;       //Mashup
              {.F.,Nil},;       //Help
              {.F.,Nil},;       //Formulário HTML
              {.F.,Nil}}        //ECM

If lGSLE .And. oView740 <> Nil .And. !lFacilit
    lLocEq := Upper(oView740:GetFolderActive('ABAS', 2)[2]) == 'LOCAÇÃO DE EQUIPAMENTOS' // 'LOCAÇÃO DE EQUIPAMENTOS'
EndIf

If !lLocEq
    If lFacilit
        cXMLPlan := oModel740:GetModel("TXSDETAIL"):GetValue("TXS_CALCMD")
    Else
        cXMLPlan := oModel740:GetModel("TFF_RH"):GetValue("TFF_CALCMD")
    Endif
Else	
    cXMLPlan := oModel740:GetModel("TFI_LE"):GetValue("TFI_CALCMD")
EndIf

cXML := cXMLPlan

If !Empty(cXML)
    aArea    := GetArea()
    aCelulas := XMLArray()
    nTamCamp := GetTamCamp(aCelulas)
    nQtdCol  := GetQtdCol(aCelulas)
    nQtdLin  := GetQtdLin(aCelulas)
    
    //Cria a temporária
    cAliasTmp  := GetNextAlias()
    oTempTable := FWTemporaryTable():New(cAliasTmp)
    
    //Adiciona no array das colunas as que serão incluidas (Nome do Campo, Tipo do Campo, Tamanho, Decimais)
    aFields := {}
    If nQtdCol > 0
        aAdd(aFields, {"NUM", "N", 3, 0})
        For nX := 1 To nQtdCol
            aAdd(aFields, {cNameCol, "C", nTamCamp, 0})
            cNameCol := GetNextLetter(cNameCol)
        Next nX
    EndIf
    
    //Define as colunas usadas e cria a temporaria no banco
    oTempTable:SetFields( aFields )
    oTempTable:Create()

    //Executa a inclusao na tela
    FWExecView('Visualizar Planilha de Preço', "VIEWDEF.TECA998A", MODEL_OPERATION_INSERT, , { || .T. }, , 30, aButtons)

    //Deleta a temporaria
    oTempTable:Delete()
    
    RestArea(aArea)
Else
    Help(,, "TECA998A",,"Não é possível utilizar a visualização da planilha.",1,0,,,,,,{"Para poder visualizar uma planilha é necessário que o Posto tenha uma planilha de preços aplicada."}) //"Não é possível modificar itens que são cobrados no contrato através da rotina Item Extra" ## "Para alterar este item, realize uma Revisão do Contrato"
EndIf

//Volta a habilitar os atalhos no fim da visualização:
SetKey( VK_F4, { || AT740F4() } )
SetKey(VK_F7,{|| FwMsgRun(Nil,{|| TECA998A(oModel740,oView740)}, Nil, "Carregando")})
If !lTecItExtOp
	If FindFunction("TECA740J") .And. TCX->( ColumnPos('TCX_OBRGT') ) > 0
	    SetKey(VK_F8,{|| TECA740J(oModel740)})
	EndIf
	If FindFunction("TECA740K") .And. TableInDic("TXO") .And. TXO->( ColumnPos('TXO_COD') ) > 0
	    SetKey(VK_F9,{|| TECA740K(oModel740)})
	EndIf
	If FindFunction("TECA740L") .And. TCX->( ColumnPos('TCX_OBRGT') ) > 0
	    SetKey(VK_F10,{|| TECA740L(oModel740)})
	EndIf
Endif

Return
  
//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
ModelDef
@sample 	TECA998() 

@author     Jack Junior
@since		21/02/2024      
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()
Local oModel    As Object
Local oStrField As Object
Local oStrGrid  As Object
Local cNameCol  := "A"
Local nX        := 0

//Estrutura falsa que sera uma tabela que ficara escondida no cabecalho
oStrField := FWFormModelStruct():New()
oStrField:AddTable('' , { 'XXTABKEY' } , cTitle, {|| ''})
oStrField:AddField('String 01' , 'Campo de texto' , 'XXTABKEY' , 'C' , 15)

//Estrutura da grid
oStrGrid := FWFormModelStruct():New() 
oStrGrid:AddTable(cAliasTmp,, "Temporaria")

//Adiciona os campos da estrutura
If nQtdCol > 0
    oStrGrid:AddField(;
        " ",;           // [01]  C   Titulo do campo
        "NUM",;         // [02]  C   ToolTip do campo
        "NUM",;         // [03]  C   Id do Field
        "N",;           // [04]  C   Tipo do campo
        3,;             // [05]  N   Tamanho do campo
        0,;             // [06]  N   Decimal do campo
        Nil,;           // [07]  B   Code-block de validação do campo
        Nil,;           // [08]  B   Code-block de validação When do campo
        {},;            // [09]  A   Lista de valores permitido do campo
        .F.,;           // [10]  L   Indica se o campo tem preenchimento obrigatório
        ,;              // [11]  B   Code-block de inicializacao do campo
        .F.,;           // [12]  L   Indica se trata-se de um campo chave
        .F.,;           // [13]  L   Indica se o campo pode receber valor em uma operação de update.
        .F.)            // [14]  L   Indica se o campo é virtual
    For nX := 1 To nQtdCol
        oStrGrid:AddField(;
            cNameCol,;  // [01]  C   Titulo do campo
            cNameCol,;  // [02]  C   ToolTip do campo
            cNameCol,;  // [03]  C   Id do Field
            "C",;       // [04]  C   Tipo do campo
            nTamCamp,;  // [05]  N   Tamanho do campo
            0,;         // [06]  N   Decimal do campo
            Nil,;       // [07]  B   Code-block de validação do campo
            Nil,;       // [08]  B   Code-block de validação When do campo
            {},;        // [09]  A   Lista de valores permitido do campo
            .F.,;       // [10]  L   Indica se o campo tem preenchimento obrigatório
            ,;          // [11]  B   Code-block de inicializacao do campo
            .F.,;       // [12]  L   Indica se trata-se de um campo chave
            .F.,;       // [13]  L   Indica se o campo pode receber valor em uma operação de update.
            .F.)        // [14]  L   Indica se o campo é virtual
        cNameCol := GetNextLetter(cNameCol)
    Next nX
EndIf

//Modelo de dados da tela
oModel := MPFormModel():New('TECA998A')
oModel:AddFields('CABID', , oStrField, , , /*bLoad*/)
oModel:AddGrid('GRIDID', 'CABID', oStrGrid, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPos*/, /*bLoad*/)
oModel:SetRelation('GRIDID', { { 'XXTABKEY', 'XXTABKEY' } })
oModel:SetDescription(cTitle)
oModel:SetPrimaryKey({ 'XXTABKEY' })

//Ativação e população do modelo
oModel:SetActivate( {|oModel| IniciaDado(oModel) } )
oModel:GetModel("GRIDID"):SetNoUpdateLine(.T.)
oModel:GetModel("GRIDID"):SetNoInsertLine(.T.)

Return oModel
  
//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
ViewDef
@sample 	TECA998() 

@author     Jack Junior
@since		21/02/2024      
/*/
//------------------------------------------------------------------------------
Static Function ViewDef()
Local oView    As Object
Local oModel   As Object
Local oStrCab  As Object
Local oStrGrid As Object
Local cNameCol  := "A"
Local cOrdem    := "02"
Local nX        := 0

//Estrtutura falsa do cabeçalho na visualização dos dados
oStrCab := FWFormViewStruct():New()
oStrCab:AddField('XXTABKEY' , '01' , 'String 01' , 'Campo de texto', , 'C')

//Estrutura da Grid
oStrGrid := FWFormViewStruct():New()

//Adicionando campos da estrutura
If nQtdCol > 0
    oStrGrid:AddField(;
        "NUM",;         // [01]  C   Nome do Campo
        "01",;          // [02]  C   Ordem
        " ",;           // [03]  C   Titulo do campo
        "NUM",;         // [04]  C   Descricao do campo
        Nil,;           // [05]  A   Array com Help
        "N",;           // [06]  C   Tipo do campo
        "999",;         // [07]  C   Picture
        Nil,;           // [08]  B   Bloco de PictTre Var
        Nil,;           // [09]  C   Consulta F3
        .F.,;           // [10]  L   Indica se o campo é alteravel
        Nil,;           // [11]  C   Pasta do campo
        Nil,;           // [12]  C   Agrupamento do campo
        Nil,;           // [13]  A   Lista de valores permitido do campo (Combo)
        Nil,;           // [14]  N   Tamanho maximo da maior opção do combo
        Nil,;           // [15]  C   Inicializador de Browse
        Nil,;           // [16]  L   Indica se o campo é virtual
        Nil,;           // [17]  C   Picture Variavel
        Nil)            // [18]  L   Indica pulo de linha após o campo        
    For nX := 1 To nQtdCol
        oStrGrid:AddField(;
            cNameCol,;  // [01]  C   Nome do Campo
            cOrdem,;    // [02]  C   Ordem
            cNameCol,;  // [03]  C   Titulo do campo
            cNameCol,;  // [04]  C   Descricao do campo
            Nil,;       // [05]  A   Array com Help
            "C",;       // [06]  C   Tipo do campo
            "@!",;      // [07]  C   Picture
            Nil,;       // [08]  B   Bloco de PictTre Var
            Nil,;       // [09]  C   Consulta F3
            .T.,;       // [10]  L   Indica se o campo é alteravel
            Nil,;       // [11]  C   Pasta do campo
            Nil,;       // [12]  C   Agrupamento do campo
            Nil,;       // [13]  A   Lista de valores permitido do campo (Combo)
            Nil,;       // [14]  N   Tamanho maximo da maior opção do combo
            Nil,;       // [15]  C   Inicializador de Browse
            Nil,;       // [16]  L   Indica se o campo é virtual
            Nil,;       // [17]  C   Picture Variavel
            Nil)        // [18]  L   Indica pulo de linha após o campo
        cOrdem := Soma1(cOrdem)
        cNameCol := GetNextLetter(cNameCol)
    Next nX
EndIf

//Carrega o ModelDef
oModel  := FWLoadModel('TECA998A')

//Agora na visualização, carrega o modelo, define o cabeçalho e a grid, e no cabeçalho coloca 0% de visualização, e na grid coloca 100%
oView := FwFormView():New()
oView:SetModel(oModel)
oView:AddField('CAB', oStrCab, 'CABID')
oView:AddGrid('GRID', oStrGrid, 'GRIDID')
oView:CreateHorizontalBox('TOHID', 0)
oView:CreateHorizontalBox('TOSHOW', 100)
oView:SetOwnerView('CAB' , 'TOHID')
oView:SetOwnerView('GRID', 'TOSHOW')
oView:SetDescription(cTitle)
//Definindo para que não seja exibido aquela pergunta de confirmar realmente ao clicar no Fechar
oView:SetViewAction('ASKONCANCELSHOW', {|oView| .F.})
Return oView

//------------------------------------------------------------------------------
/*/{Protheus.doc} IniciaDado
Popula o Grid pra visualização da planilha de acordo com o XML
@sample 	IniciaDado() 
@param		oModel -> oModel

@author     Jack Junior
@since		21/02/2024      
/*/
//------------------------------------------------------------------------------
Static Function IniciaDado( oModel )
Local nX := 0
Local oMdlGrid := oModel:GetModel("GRIDID")

oMdlGrid:SetNoUpdateLine(.F.)
oMdlGrid:SetNoInsertLine(.F.)

For nX := 1 To nQtdLin
    If nX > 1
        oMdlGrid:AddLine()
    EndIf
    oMdlGrid:LoadValue("NUM", nX)
Next nX

For nX := 1 To Len(aCelulas)
    oMdlGrid:GoLine(aCelulas[nX,2])
    oMdlGrid:LoadValue(aCelulas[nX,1], aCelulas[nX,3])
Next nX

oMdlGrid:SetNoUpdateLine(.T.)
oMdlGrid:SetNoInsertLine(.T.)

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} XMLArray
Leitura do XML da planilha (cXML - estática), convertendo os dados em array
com estrutura {{COLUNA,LINHA,VALOR},{COLUNA,LINHA,VALOR}}

EXEMPLO: {{"B",1,"1500"},{"C",2,VERBAS ADICIONAIS}}

@sample 	XMLArray() 

@author     Jack Junior
@since		21/02/2024      
/*/
//------------------------------------------------------------------------------
Static Function XMLArray()
Local aArray    := {}
Local cName     := ""
Local cPicture  := ""
Local cValue    := ""

While !Empty(cXML)
	cName := ""
	cValue := ""
	cPicture := ""

	nPosIni := AT("<item ", cXML)

	If nPosIni > 0
		cXML := SubStr(cXML, nPosIni)
		//Acha a TAG XML NAME
		nPosIni := AT("<NAME>", cXML)
		nPosFim := AT("</NAME>", cXML)
		If nPosIni > 0 .And. nPosFim > 0
			cName := SubStr(cXML, nPosIni+6, nPosFim-(nPosIni+6))
			cXML := SubStr(cXML, nPosFim+7)
		EndIf
		//Acha a TAG XML VALUE
		nPosIni := AT("<VALUE>", cXML)
		nPosFim := AT("</VALUE>", cXML)
		If nPosIni > 0 .And. nPosFim > 0
			cValue := SubStr(cXML, nPosIni+7, nPosFim-(nPosIni+7))
			cXML := SubStr(cXML, nPosFim+8)
		EndIf
		//Acha a TAG XML PICTURE
		nPosIni := AT("<PICTURE>", cXML)
		nPosFim := AT("</PICTURE>", cXML)
		If nPosIni > 0 .And. nPosFim > 0
			cPicture := SubStr(cXML, nPosIni+9, nPosFim-(nPosIni+9))
			cXML := SubStr(cXML, nPosFim+10)
		EndIf

		nPosFim := AT("</item>", cXML)
		If nPosFim > 0
			cXML := SubStr(cXML, nPosFim+7)
		EndIf

		If !Empty(cName)
            If  "99.99" $ cPicture
                cValue := Transform(val(cValue), "@E 999,999.99")
            Else
                cValue := DecodeUTF8(cValue)
            EndIf
            AADD(aArray, {AllTrim(SubStr(cName,1,1)),;      //COLUNA (LETRA)
                          Val(AllTrim(SubStr(cName,2))),;   //LINHA (NUMERO)
                          AllTrim(cValue)})                 //VALOR (STRING)
		EndIf
	Else
		Exit
	EndIf
End

Return aArray

//------------------------------------------------------------------------------
/*/{Protheus.doc} GetLetterPos
Retorna a posição da Letra no array com o alfabeto

@sample 	GetLetterPos() 
@param		cLetter -> Letra a ser analisada
@Return     nPos -> Posição da letra no alfabeto

@author     Jack Junior
@since		21/02/2024      
/*/
//------------------------------------------------------------------------------
Static Function GetLetterPos(cLetter)
Local aArrayLetter  := {"A","B","C","D","E","F","G","H","I","J","K","L","M",;
                        "N","O","P","Q","R","S","T","U","V","W","X","Y","Z"}
Local nPos          := 0
DEFAULT cLetter     := ""

If !Empty(cLetter)
    nPos := aScan(aArrayLetter, {|x| x == AllTrim(cLetter)})
EndIf

Return nPos

//------------------------------------------------------------------------------
/*/{Protheus.doc} GetNextLetter
Retorna a próxima letra do alfabeto

@sample 	GetNextLetter() 
@param		cLetter -> Letra a ser analisada

@author     Jack Junior
@since		21/02/2024      
/*/
//------------------------------------------------------------------------------
Static Function GetNextLetter(cLetter)
Local cNextLetter   := ""
Local nPos          := 0
Local aArrayLetter  := {"A","B","C","D","E","F","G","H","I","J","K","L","M",;
                        "N","O","P","Q","R","S","T","U","V","W","X","Y","Z"}
DEFAULT cLetter     := ""

If !Empty(cLetter)
    nPos := aScan(aArrayLetter, {|x| x == AllTrim(cLetter)}) + 1
    cNextLetter := aArrayLetter[nPos]
EndIf

Return cNextLetter

//------------------------------------------------------------------------------
/*/{Protheus.doc} GetTamCamp
Retorna o maior tamanho de conteúdo da String de valor nos dados que vão pra planilha
@sample 	GetTamCamp(aCel) 
@param		aCel -> Array com conteúdo da planilha
@Return     nTamMax -> tamanho do maior valor

@author     Jack Junior
@since		21/02/2024      
/*/
//------------------------------------------------------------------------------
Static Function GetTamCamp(aCel)
Local nTamMax := 0
Local nTamCpo := 0
Local nX      := 0

If Len(aCel) > 0
    For nX := 1 To Len(aCel)
        nTamCpo := Len(aCel[nX, 3])
        If nTamCpo > nTamMax
            nTamMax := nTamCpo
        EndIf
    Next nX
EndIf

Return nTamMax

//------------------------------------------------------------------------------
/*/{Protheus.doc} GetQtdCol
Retorna a quantidade de colunas para construção do MVC visualização da planilha
@sample 	GetQtdCol(aCel) 
@param		aCel -> Array com conteúdo da planilha
@Return     nQuantCol -> Quantidade de colunas

@author     Jack Junior
@since		21/02/2024      
/*/
//------------------------------------------------------------------------------
Static Function GetQtdCol(aCel)
Local nQuantCol := 0
Local nNumCol   := 0
Local nX        := 0

If Len(aCel) > 0
    For nX := 1 To Len(aCel)
        nNumCol := GetLetterPos(aCel[nX, 1])
        If nNumCol > nQuantCol
            nQuantCol := nNumCol
        EndIf
    Next nX
EndIf

Return nQuantCol

//------------------------------------------------------------------------------
/*/{Protheus.doc} GetQtdLin
Retorna a quantidade de linhas para construção do MVC visualização da planilha
@sample 	GetQtdLin(aCel) 
@param		aCel -> Array com conteúdo da planilha
@Return     nQuantLin -> Quantidade de linhas

@author     Jack Junior
@since		21/02/2024     
/*/
//------------------------------------------------------------------------------
Static Function GetQtdLin(aCel)
Local nQuantLin := 0
Local nNumLin   := 0
Local nX        := 0

If Len(aCel) > 0
    For nX := 1 To Len(aCel)
        nNumLin := aCel[nX, 2]
        If nNumLin > nQuantLin
            nQuantLin := nNumLin
        EndIf
    Next nX
EndIf

Return nQuantLin
