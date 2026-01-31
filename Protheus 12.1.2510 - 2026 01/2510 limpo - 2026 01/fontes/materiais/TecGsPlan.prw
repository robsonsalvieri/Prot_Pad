#INCLUDE "TOTVS.CH"
#INCLUDE "TRYEXCEPTION.CH"

#DEFINE ID          1
#DEFINE COLUMN	    2
#DEFINE LINE	    3
#DEFINE NAME        4
#DEFINE NICKNAME    5
#DEFINE FORMULA     6
#DEFINE VALUE       7
#DEFINE PICTURE     8
#DEFINE DEPENDENTS  9
#DEFINE BKP_FORM    10

//----------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GsPlan

@description Classe utilizada em complemento a FWUIWORKSHEET do framework

Motor de cálculo com melhor Performance
Sem Interface, apenas para cálculos como Execução e Atualização de planilhas.

@author	jack.junior
@since	05/09/2025
/*/
//----------------------------------------------------------------------------------------------------------------
class GsPlan

Data aCalculos  as ARRAY
Data aCells     as ARRAY
Data aErrors    as ARRAY
Data aSetForm   as ARRAY
Data aSetVal    as ARRAY
Data cCabecalho as STRING
Data cFirstErro as STRING
Data cLastID    as STRING
Data cRodape    as STRING
Data cXmlObj    as STRING
Data nCellPos   as NUMERIC

Method new()            // Construtor
Method loadXmlModel()   // Seta o XML de planilha no Objeto
Method validPos()       // Valida se está posicionado em um Nome ou NickName
Method cellExists()     // Verifica se a Célula Existe
Method getCellPos()     // Retorna a Posição da Célula no Array Self:aCells
Method getCellValue()   // Retorna o Valor da Célula no Array Self:aCells
Method setCellValue()   // Troca o valor da Célula no Array Self:aCells
Method getCellForm()    // Retorna a fórmula da Célula no Array Self:aCells
Method setCellForm()    // Troca a fórmula da Célula no Array Self:aCells
Method recalcAll()      // Recalcula a planilha
Method getDependents()  // Retorna os dependentes de uma Célula (Todos os NickNames de uma formula)
Method getCalcOrder()   // Retorna a ordem de cálculo para não haver recurssividade nos cálculos
Method defineTop()      // Ajusta array quem deve ser calculado primeiro
Method recalcCell()     // Recalcula uma célula a partir da fórmula
Method getXmlModel()    // Recalcula a planilha e Retorna o XML Atualizado
Method prepareForm()    // Altera os Nicks da formula para valores para Calcular
Method replaceNick()    // Troca um nickname da formula pelo valor correspondente
Method formAdjust()     // Ajusta a fórmula retirando espaços vazios e o igual do inicio
Method numToString()    // Transforma um numérico para String
Method isCharNum()      // Verifica se uma String pode ser um Número
Method undecodeForm()   // Trata a fórmula com tags XML para poder calcular
Method numFormOnly()    // Verifica se a fórmula é composta apenas por numeros (nem Names ou NickNames)
Method itemXml()        // Forma o nó do item (célula) para o XML
Method addCell()        // Adiciona uma nova célula na planilha

endclass
//----------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} new

@description Construtor da classe GsPlan

@author	jack.junior
@since	05/09/2025
/*/
//----------------------------------------------------------------------------------------------------------------
method new() class GsPlan

    Self:aCalculos  := {}
    Self:aCells     := {}
    Self:aErrors    := {}
    Self:aSetForm   := {}
    Self:aSetVal    := {}
    Self:cCabecalho := ""
    Self:cFirstErro := ""
    Self:cLastID    := ""
    Self:cRodape    := ""
    Self:cXmlObj    := ""
    Self:nCellPos   := 0

return

//----------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} loadXmlModel

@description Faz o Parse do XML da planilha para o array aCells que será trabalhado

@author	jack.junior
@since	05/09/2025
/*/
//----------------------------------------------------------------------------------------------------------------
method loadXmlModel(cXML) class GsPlan
    Local aDependOn := {}
    Local cFormAux  := ""
    Local cFormBkp  := ""
    Local cFormula  := ""
    Local cIdItem   := ""
    Local cItemXML  := ""
    Local cName     := ""
    Local cNickName := ""
    Local cPicture  := ""
    Local lFirst    := .T.
    Local lSetValue := .F.
    Local nFimItem  := 0
    Local nHasFim   := 0
    Local nHasIni   := 0
    Local nIniItem  := 0
    Local xValue    := Nil

    Self:aCells  := {}
    Self:cXmlObj := cXML

    If ValType(cXML) == "C" .And. !Empty(cXML)
        While !Empty(cXML)
            aDependOn := {}
            cFormBkp  := ""
            cFormula  := ""
            cIdItem   := ""
            cName     := ""
            cNickName := ""
            cPicture  := ""
            lSetValue := .F.
            xValue    := ""

            nIniItem := AT("<item ", cXML)
            nFimItem := AT("</item>", cXML)
            // Pega o Item do XML
            cItemXML := SubStr(cXML, nIniItem+6, nFimItem-(nIniItem+6))

            If lFirst
                // Popula o Cabeçalho da planilha no primeiro Item:
                Self:cCabecalho := SubStr(cXML, 1, nIniItem-1)
                lFirst := .F.
            EndIf

            // Remove Item do XML:
            cXML := SubStr(cXML, nFimItem+7)

            If nIniItem > 0
                // Acha o ID do Item:
                nHasIni := AT('id="', cItemXML)
                cItemXML := SubStr(cItemXML, nHasIni+4)
                If nHasIni > 0
                    nHasFim := AT('"', cItemXML)
                    cIdItem := AllTrim(SubStr(cItemXML, 1, nHasFim-1))
                EndIf
                // Acha a TAG XML NAME:
                nHasIni := AT("<NAME>", cItemXML)
                nHasFim := AT("</NAME>", cItemXML)
                If nHasIni > 0 .And. nHasFim > 0
                    cName := AllTrim(SubStr(cItemXML, nHasIni+6, nHasFim-(nHasIni+6)))
                EndIf
                // Acha a TAG XML NICKNAME:
                nHasIni := AT("<NICKNAME>", cItemXML)
                nHasFim := AT("</NICKNAME>", cItemXML)
                If nHasIni > 0 .And. nHasFim > 0
                    cNickName := AllTrim(SubStr(cItemXML, nHasIni+10, nHasFim-(nHasIni+10)))
                EndIf
                // Acha a TAG XML FORMULA:
                nHasIni := AT("<FORMULA>", cItemXML)
                nHasFim := AT("</FORMULA>", cItemXML)
                If nHasIni > 0 .And. nHasFim > 0
                    cFormula := AllTrim(SubStr(cItemXML, nHasIni+9, nHasFim-(nHasIni+9)))
                    cFormBkp := cFormula
                EndIf

                cFormAux := Self:formAdjust(cFormula)

                // Se a formula for apenas Numeros Ex: =10-5 já executa e seta o valor:
                If Self:numFormOnly(cFormAux)
                    xValue := &(cFormAux)
                    lSetValue := .T.
                Else
                    // Acha a TAG XML VALUE:
                    nHasIni := AT("<VALUE>", cItemXML)
                    nHasFim := AT("</VALUE>", cItemXML)
                    If nHasIni > 0 .And. nHasFim > 0
                        xValue := SubStr(cItemXML, nHasIni+7, nHasFim-(nHasIni+7))
                    EndIf
                EndIf
                // Acha a TAG XML PICTURE:
                nHasIni := AT("<PICTURE>", cItemXML)
                nHasFim := AT("</PICTURE>", cItemXML)
                If nHasIni > 0 .And. nHasFim > 0
                    cPicture := AllTrim(SubStr(cItemXML, nHasIni+9, nHasFim-(nHasIni+9)))
                EndIf

                If !Empty(cName)
                    If !Empty(cFormula)
                        // Ajusta a formula para que tags especials se ajustem Ex:("&gt;" vira ">")
                        cFormula := Self:undecodeForm(cFormula)
                        // Tudo que depende para executar a formula:
                        aDependOn := Self:getDependents(cFormula)
                    EndIf 

                    // Popula o Array aCells com TODAS as Células da Planilha:
                    AADD(Self:aCells, {cIdItem,;               //1-ID DO ITEM
                                        SubStr(cName,1,1),;    //2-COLUNA (LETRA)
                                        Val(SubStr(cName,2)),; //3-LINHA (NUMERO)
                                        cName,;                //4-NOME
                                        cNickName,;            //5-NICKNAME
                                        cFormula,;             //6-FORMULA
                                        xValue,;               //7-VALUE
                                        cPicture,;             //8-PICTURE    
                                        aDependOn,;            //9-DEPENDENTES 
                                        cFormBkp})             //10-Backup da formula   

                    Self:cLastID := cIdItem                                    

                    If lSetValue
                        If Self:cellExists(cNickName)
                            Self:setCellValue(cNickName, xValue, .F.)
                        EndIf
                    EndIf
                EndIf
            Else
                Exit
            EndIf
        End

        // O resto do XML vai no "Rodapé"
        Self:cRodape := cXML
    EndIf

return

//----------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} getCellPos

@description Localiza a célula no array pelo Nome ou Nickname e atribui "posiciona" no atributo Self:nCellPos
             
@Param cNameOrNick, String, Nome ou Nickname. Ex: NOME: A1 NICKNAME:TOTAL_INSUMOS

@Return nPos, Numeric, Posição da célula no Array Self:aCells

@author	jack.junior
@since	05/09/2025
/*/
//----------------------------------------------------------------------------------------------------------------
Method getCellPos(cNameOrNick) Class GsPlan
    Local nPos := 0

    If !Empty(cNameOrNick)
        // Busca posição pelo NickName (coluna 5 do array)
        nPos := AScan(Self:aCells, {|x| AllTrim(x[NICKNAME]) == AllTrim(cNameOrNick)})

        If nPos == 0
            // Busca posição pelo Name (coluna 4 do array)
            nPos := AScan(Self:aCells, {|x| AllTrim(x[NAME]) == AllTrim(cNameOrNick)})
        EndIf
    EndIf

    Self:nCellPos := nPos

Return nPos

//----------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} cellExists

@description    1) Verifica se a célula existe. 
                2) Se sim retorna true e deixa "posicionada" - Atributo nCellPos recebe a posição
                3) Se não - Atributo nCellPos recebe 0
             
@Param cNameOrNick, String, Nome ou Nickname. Ex: NOME: A1 NICKNAME:TOTAL_INSUMOS

@Return lRet, Logic, Se localizou ou não a célula

@author	jack.junior
@since	05/09/2025
/*/
//----------------------------------------------------------------------------------------------------------------
Method cellExists(cNameOrNick) Class GsPlan
    Local lRet := .F.

    // Busca posição pelo NickName ou Name
    nPos := Self:getCellPos(cNameOrNick)

    If nPos > 0
        lRet := .T.
    EndIf
    
Return lRet

//----------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} validPos

@description    Verifica se o Nome ou NickName é da celula posicionada, senão procura e posiciona. 
             
@Param cNameOrNick, String, Nome ou Nickname. Ex: NOME: A1 NICKNAME:TOTAL_INSUMOS

@author	jack.junior
@since	05/09/2025
/*/
//----------------------------------------------------------------------------------------------------------------
Method validPos(cNameOrNick) Class GsPlan
    cNameOrNick := AllTrim(cNameOrNick)

    // Caso não esteja posicionado posiciona na primeira célula para evitar errorlog:
    If Self:nCellPos == 0
        Self:nCellPos := 1
    EndIf

    // Verifica se a célula posicionada não é a que tento pegar o Valor:
    If cNameOrNick <> Self:aCells[Self:nCellPos,NICKNAME] .And. cNameOrNick <> Self:aCells[Self:nCellPos,NAME]
        // Busca posição pelo NickName ou Name e posiciona na célula-> Self:nCellPos
        Self:cellExists(cNameOrNick)
    EndIf
Return

//----------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} getCellValue

@description    1) Verifica se o Nome ou Nick é da celula posicionada, senão procura e posiciona. 
                2) Retorna o valor dela.
             
@Param cNameOrNick, String, Nome ou Nickname. Ex: NOME: A1 NICKNAME:TOTAL_INSUMOS

@Return xValue, Numeric - Sempre que for possível transformar para número
                String - Conteúdo da String caso não dê para transformar para número 
                Se a célula não existir retorna 0 (numérico)

@author	jack.junior
@since	05/09/2025
/*/
//----------------------------------------------------------------------------------------------------------------
Method getCellValue(cNameOrNick) Class GsPlan
    Local xValue := 0

    // Verifica se ta posicionado, senão posiciona:
    Self:validPos(cNameOrNick)

    If Self:nCellPos > 0
        // Acessa o valor na célula, podendo ser Caractere ou Númerico:
        xValue := Self:aCells[Self:nCellPos,VALUE]

        // Transforma o caracter em numérico caso seja número:
        If Self:isCharNum(xValue)
            xValue := Val(xValue)
        EndIf
    EndIf
Return xValue

//----------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} setCellValue

@description    1) Verifica se o Nome ou Nick é da celula posicionada, senão procura e posiciona. 
                2) Troca o valor dela.
                3) Setar valor em uma célula "zera" sua fórmula.
             
@Param cNameOrNick, String, Nome ou Nickname. Ex: NOME: A1 NICKNAME:TOTAL_INSUMOS
       xValue, String ou Numeric, Valor novo para a célula.

@Return lRet, Logic, Se conseguiu ou não setar o valor.

@author	jack.junior
@since	05/09/2025
/*/
//----------------------------------------------------------------------------------------------------------------
Method setCellValue(cNameOrNick, xValue, lLimpForm) Class GsPlan
    Local lRet      := .F.
    Local xValorAnt := ""
    Default lLimpForm := .T.

    // Verifica se ta posicionado, senão posiciona:
    Self:validPos(cNameOrNick)

    If Self:nCellPos > 0
        lRet := .T.

        xValue := Self:numToString(xValue)
        xValorAnt := Self:numToString(Self:aCells[Self:nCellPos,VALUE])

        // LOG de alterações:
        AADD(Self:aSetVal,{cNameOrNick,;    // Name ou NickName
                            Self:nCellPos,; // Posição da célula
                            xValorAnt,;     //Valor anterior
                            xValue})        //Valor novo
        
        // Atualiza valor (posição 7 do array)
        Self:aCells[Self:nCellPos,VALUE] := xValue

        If lLimpForm
            // Como setou valor Zera a fórmula da célula (posição 6 do array)
            Self:aCells[Self:nCellPos,BKP_FORM] := ""
            Self:aCells[Self:nCellPos,FORMULA]  := ""
        EndIf
    EndIf
Return lRet

//----------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} getCellForm

@description    1) Verifica se o Nome ou Nick é da celula posicionada, senão procura e posiciona. 
                2) Se sim retorna o conteúdo de sua fórmula.
                3) Se não retorna vazio ""
             
@Param cNameOrNick, String, Nome ou Nickname. Ex: NOME: A1 NICKNAME:TOTAL_INSUMOS

@Return cFormula, String, Conteúdo da fórmula.

@author	jack.junior
@since	05/09/2025
/*/
//----------------------------------------------------------------------------------------------------------------
Method getCellForm(cNameOrNick) Class GsPlan
    Local cFormula      := ""
    DEFAULT cNameOrNick := ""

    // Verifica se ta posicionado, senão posiciona:
    Self:validPos(cNameOrNick)

    If Self:nCellPos > 0
        cFormula := Self:aCells[Self:nCellPos,FORMULA]
    EndIf
Return cFormula

//----------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} setCellForm

@description    1) Verifica se o Nome ou Nick é da celula posicionada, senão procura e posiciona. 
                2) Se sim troca o conteúdo de sua fórmula.
             
@Param  cNameOrNick, String, Nome ou Nickname. Ex: NOME: A1 NICKNAME:TOTAL_INSUMOS
        cFormula, String, Fórmula. Ex: =(A1+TOTAL_INSUMOS)/2

@author jack.junior
@since	05/09/2025
/*/
//----------------------------------------------------------------------------------------------------------------
Method setCellForm(cNameOrNick, cFormula) Class GsPlan
    Local aDependOn     := {}
    DEFAULT cFormula    := ""
    DEFAULT cNameOrNick := ""

    // Verifica se ta posicionado, senão posiciona:
    Self:validPos(cNameOrNick)

    If Self:nCellPos > 0
        // LOG
        AADD(Self:aSetForm,{cNameOrNick,Self:nCellPos,Self:aCells[Self:nCellPos,BKP_FORM],cFormula})

        // Pega os dependentes da nova fórmula:
        aDependOn := Self:getDependents(cFormula)

        // Coloca a fórmula nova:
        Self:aCells[Self:nCellPos,FORMULA] := AllTrim(cFormula)
        Self:aCells[Self:nCellPos,BKP_FORM] := AllTrim(cFormula)

        // Coloca a fórmula nova:
        Self:aCells[Self:nCellPos,DEPENDENTS] := aDependOn
        

        cFormula := Self:formAdjust(cFormula)

        // Recalcula a célula:
        Self:recalcCell(Self:nCellPos)
    EndIf
Return

//----------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} recalcAll

@description    Recalcula toda a Planilha:
                1) Compõe o array de afetados com base no array de dependentes;
                2) Monta o aOrder com a ordem de execução das células com recurssividade;
                3) Realiza o cálculo das células na ordem para não ter recurssividade de 
                    cálculo e ganhar PERFORMANCE

@author jack.junior
@since	05/09/2025
/*/
//----------------------------------------------------------------------------------------------------------------
Method recalcAll() Class GsPlan
    Local aOrder := {}
    Local nI     := 0
    Local nPos   := 0

    Self:cFirstErro := ""

    // Verifica a ordem do cálculo por meio de recurssividade:
    aOrder := Self:getCalcOrder()

    // Recalcula as células na ordem correta para não haver recurssividade no cálculo:
    For nI := 1 To Len(aOrder)
        nPos := aOrder[nI]
        If !Empty(Self:aCells[nPos,FORMULA]) // só se tem fórmula
            Self:recalcCell(nPos)
        EndIf
    Next

Return

//----------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} getCalcOrder

@description    Cria o array com ordem de cálculo da planilha toda para não haver recurssividade de 
                    cálculo e ganhar PERFORMANCE.
             
@Return aOrder, Array, Ordem de cálculo.

@author	jack.junior
@since	05/09/2025
/*/
//----------------------------------------------------------------------------------------------------------------
Method getCalcOrder() Class GsPlan
    Local aOrder   := {}
    Local aVisited := Array(Len(Self:aCells))
    Local nI       := 0

    For nI := 1 To Len(aVisited)
        aVisited[nI] := .F.
    Next

    For nI := 1 To Len(Self:aCells)
        If !aVisited[nI]
            Self:defineTop(nI, aVisited, @aOrder)
        EndIf
    Next

Return aOrder

//----------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} defineTop

@description    Define a ordem de execução das fórmulas por meio de recurssividade.
                A recurssividade da planilha está presente apenas aqui para ganho de PERFORMANCE.

@Param  nPos, Numeric, Posição da célula sendo visitada no array aCells.
        aVisited, Array, Array para marcar se já passou na posição
        @aOrder, Array, Ordem de cálculo - RETORNO POR REFERENCIA

@author	jack.junior
@since	05/09/2025
/*/
//----------------------------------------------------------------------------------------------------------------
Method defineTop(nPos, aVisited, aOrder) Class GsPlan
    Local cNickName := ""
    Local nJ        := 0

    // Seta True na célula visitada:
    aVisited[nPos] := .T.

    // Percorre dependências
    For nJ := 1 To Len(Self:aCells[nPos,DEPENDENTS])
        // Pega o Nickname do dependente:
        cNickName := Self:aCells[nPos,DEPENDENTS,nJ]
        // Verifica se a célula existe:
        If Self:cellExists(cNickName)
            If Self:nCellPos > 0 .And. !aVisited[Self:nCellPos]
                // Ordena a célula com recurssividade:
                Self:defineTop(Self:nCellPos, aVisited, aOrder)
            EndIf
        EndIf
    Next

    // Adiciona no array de retorno por referencia @:
    AAdd(aOrder, nPos)
Return

//----------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} recalcCell

@description    Recalcula a célula de acordo com sua fórmula.

@Param  nPos, Numeric, Posição da célula para recalculo.

@author	jack.junior
@since	05/09/2025
/*/
//----------------------------------------------------------------------------------------------------------------
Method recalcCell(nPos) Class GsPlan
    Local bBloco   := {||}
    Local cFormula := Self:aCells[nPos,FORMULA]
    Local oError   := Nil
    Local xResult  := 0

    If !Empty(cFormula)
        // Substitui nicknames pelos valores
        cFormula := Self:prepareForm(cFormula, nPos)

        //Executa formula
		TRY EXCEPTION
			// Monta o Bloco para calculo
            bBloco := &("{|| " + cFormula + " }")

            // Avalia expressão matemática (simples)
            xResult := Eval(bBloco)
		CATCH EXCEPTION USING oError
			//Se ocorreu erro
			xResult := Nil
		ENDTRY

		If xResult == Nil .Or. ValType(xResult) <> "N"
            xResult := "#ERROR"
			AADD(Self:aErrors, {Self:aCells[nPos,NAME],;                // Nome da Célula
                                Self:aCells[nPos,NICKNAME],;            // Nickname da Célula
                                AllTrim(Self:aCells[nPos,BKP_FORM]),;   // Formula Original da Célula
                                cFormula})                              // Formula com valor no lugar nos nicknames

            If Empty(Self:cFirstErro)
                Self:cFirstErro := "A célula " + Self:aCells[nPos,NAME] + " de NickName " + Self:aCells[nPos,NICKNAME] + " foi a primeira a dar erro no cálculo. " + CRLF + CRLF
                Self:cFirstErro += " Fórmula original: " + CRLF + AllTrim(Self:aCells[nPos,BKP_FORM]) + CRLF + CRLF
                Self:cFirstErro += " Tentativa de calculo: " + CRLF + cFormula

                AtShowLog(Self:cFirstErro,"Erro de fórmula:",/*lVScroll*/,/*lHScroll*/,/*lWrdWrap*/,.F.) // "Erro de fórmula:"
            EndIf
        Else
            xResult := xResult
            AADD(Self:aCalculos,{Self:aCells[nPos,NAME],;               // Nome da Célula
                                 Self:aCells[nPos,NICKNAME],;           // Nickname da Célula
                                 Str(nPos),;                            // Posição da Célula
                                 Self:numToString(Self:aCells[nPos,VALUE]),; // Valor que estava na Célula
                                 Self:numToString(xResult)})                 // Valor Novo recalculado
		EndIf

        // Atualiza o VALUE
        Self:aCells[nPos,VALUE] := xResult
    EndIf
Return

//----------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} prepareForm

@description    Prepara a fórmula para cálculo:
                1) Remove o igual (=) se houver
                2) Remove os espaços em Branco
                3) Substitui o Name ou Nickname na fórmula pelo Valor dela.
             
@Param cFormula, String, Nome ou Nickname. Ex: NOME: A1 NICKNAME:TOTAL_INSUMOS

@Return cNewFormula, String, Nova fórmula com valores substituidos.

@author	jack.junior
@since	05/09/2025
/*/
//----------------------------------------------------------------------------------------------------------------
Method prepareForm(cFormula) Class GsPlan
    Local aNickNames  := {}
    Local cNewFormula := ""
    Local cNickname   := ""
    Local nX          := 0

    If !Empty(cFormula)
        cFormula := Self:formAdjust(cFormula)

        // Pega os Nicknames da Fórmula:
        aNickNames := Self:getDependents(cFormula)
        cNewFormula := cFormula

        For nX := 1 To Len(aNickNames)
            cNickname := aNickNames[nX]

            // É nickname ? substitui se existir no hash
            If Self:cellExists(cNickname)
                cNewFormula := Self:replaceNick(cNewFormula, cNickname, "("+Self:numToString(Self:aCells[Self:nCellPos,VALUE])+")")
            Else
                // Se a célula não existir seta zero:
                cNewFormula := StrTran(cNewFormula, cNickname, "0")
            EndIf
        Next nX
    EndIF

Return cNewFormula

//----------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} formAdjust

@description    Remove espaços e igual do inicio da fórmula
             
@Param cFormula, String, fórmula

@Return cFormula, String, fórmula ajustada

@author	jack.junior
@since	05/09/2025
/*/
//----------------------------------------------------------------------------------------------------------------
Method formAdjust(cFormula) Class GsPlan

    // Remove "="
    If At("=",cFormula) == 1
        cFormula := SubStr(cFormula, 2)
    EndIf

    // Remove os Espaços em branco:
    cFormula := StrTran(cFormula," ","")

Return cFormula

//----------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} prepareForm

@description    Prepara a fórmula para cálculo:
                1) Remove o igual (=) se houver
                2) Remove os espaços em Branco
                3) Substitui o Name ou Nickname na fórmula pelo Valor dela.
             
@Param cFormula, String, Nome ou Nickname. Ex: NOME: A1 NICKNAME:TOTAL_INSUMOS

@Return cNewFormula, String, Nova fórmula com valores substituidos.

@author	jack.junior
@since	05/09/2025
/*/
//----------------------------------------------------------------------------------------------------------------
Method getXmlModel() Class GsPlan
    Local cXmlUpdated := ""
    Local nX          := 0

    If Len(Self:aCells) > 0

        // Recalcula planilha para atualização de valores:
        Self:recalcAll()

        cXmlUpdated := Self:cCabecalho

        For nX := 1 To Len(Self:aCells)
            cXmlUpdated += Self:itemXml(nX)
        Next nX

        cXmlUpdated += "</item"+Self:cRodape
    EndIf
Return cXmlUpdated

//----------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} itemXml

@description    Prepara o XML para o Item da célula:

@Param nPos, Numeric, Posição do item do array da planilha

@Return cXmlItem, String, Parte do item para compor o XML da planilha.

@author	jack.junior
@since	05/09/2025
/*/
//----------------------------------------------------------------------------------------------------------------
Method itemXml(nPos) Class GsPlan
    Local cValue   := ""
    Local cXmlItem := ""

    If !Empty(Self:aCells[nPos,ID])
        // 1-ID DO ITEM
        cXmlItem := '<item id="'+Self:aCells[nPos,ID]+'" deleted="0" >'
        // 4-NAME
        cXmlItem += '<NAME>'+Self:aCells[nPos,NAME]+'</NAME>'
        // 5-NICKNAME
        cXmlItem += '<NICKNAME>'+Self:aCells[nPos,NICKNAME]+'</NICKNAME>'
        // 6-FORMULA
        cXmlItem += '<FORMULA>'+Self:aCells[nPos,BKP_FORM]+'</FORMULA>'
        // 7-VALUE - Trata o Valor:
        cValue := Self:numToString(Self:aCells[nPos,VALUE])
        cXmlItem += '<VALUE>'+cValue+'</VALUE>'
        // 8-PICTURE
        cXmlItem += '<PICTURE>'+Self:aCells[nPos,PICTURE]+'</PICTURE>'
        // BLOCKCELL
        cXmlItem += '<BLOCKCELL>F</BLOCKCELL>'
        // BLOCKNAME
        cXmlItem += '<BLOCKNAME>F</BLOCKNAME>'
        // FECHA A TAG
        cXmlItem += '</item>'
    EndIf
Return cXmlItem

//----------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} numToString

@description    Transforma um valor numérico para String mantendo o maior numero de decimais para precisão

@Param xValor, Numeric ou String, Valor a ser alterado

@Return cTexto, String, Corrigido para String.

@author	jack.junior
@since	05/09/2025
/*/
//----------------------------------------------------------------------------------------------------------------
Method numToString(xValor) Class GsPlan
    Local cTexto := xValor

    If ValType(xValor) == "N"

        // Espaço grande para não arredondar:
        cTexto := AllTrim(Str(xValor, 40, 10)) 

        // Remove zeros à direita:
        While Right(cTexto,1) == "0"
            cTexto := Left(cTexto, Len(cTexto)-1)
        EndDo

        // Remove o Ponto da ultima casa se não houver decimais:
        If Right(cTexto,1) == "."
            cTexto := Left(cTexto, Len(cTexto)-1)
        EndIf
    EndIf
Return cTexto

//----------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} isCharNum

@description    Verifica se uma String pode ser um Número para variavel numérica

@Param xValor, Numeric ou String, Valor a ser verificado

@Return lRet, Logic, True se a string for um número
                     Exemplo: "-1758.0288" é negativo, mas é numero !

@author	jack.junior
@since	05/09/2025
/*/
//----------------------------------------------------------------------------------------------------------------
Method isCharNum(xValue) Class GsPlan
    Local cBuffer := ""
    Local cChar   := ""
    Local lRet    := .F.
    Local nI      := 0

    If ValType(xValue) == "C"
        // Remove os Espaços:
        xValue := AllTrim(xValue)

        // Percorre caractere por caractere
        For nI := 1 To Len(xValue)
            cChar := SubStr(xValue, nI, 1)

            If ( (cChar == "-") .Or.(cChar == ",") .Or. (cChar == ".") .Or. (cChar >= "0" .And. cChar <= "9") )
                cBuffer += cChar
                lRet := .T.
            Else
                lRet := .F.
                Exit
            EndIf
        Next
    EndIf
    
Return lRet

//----------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} undecodeForm

@description    Ajusta a fórmula da codificação do XML para realizar cálculos

@Param cFormula, String, fórmula

@Return cFormula, String, fórmula ajustada

@author	jack.junior
@since	05/09/2025
/*/
//----------------------------------------------------------------------------------------------------------------
Method undecodeForm(cFormula) Class GsPlan
    // Substitui entidades XML
    cFormula := StrTran(cFormula, "&gt;", ">" ) //Greater than
    cFormula := StrTran(cFormula, "&lt;", "<" ) //Lesser than
    cFormula := StrTran(cFormula, "&amp;", "&") //
    cFormula := StrTran(cFormula, "&#39;", '"' )//Aspas simples '
    cFormula := StrTran(cFormula, "&quot;", '"')//Aspas duplas
    cFormula := StrTran(cFormula, ",", '.')     //virgula é ponto

    // Ajusta separador de parâmetros ( ; -> , )
    cFormula := StrTran(cFormula, ";", ",")     //; é virgula na função

Return cFormula

//----------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} numFormOnly

@description    Verifica se a fórmula é composta apenas de números Ex: =(-17.448*2/47)

@Param cFormula, String, fórmula

@Return lRet, Logic

@author	jack.junior
@since	05/09/2025
/*/
//----------------------------------------------------------------------------------------------------------------
Method numFormOnly(cFormula) Class GsPlan
    Local cBuffer := ""
    Local cChar   := ""
    Local lRet    := .T.
    Local nI      := 0

    If !Empty(cFormula) .And. cFormula <> "=0"
        // Remove igual e espaços em branco:
        cFormula := Self:formAdjust(cFormula)

        // Percorre caractere por caractere
        For nI := 1 To Len(cFormula)
            cChar := SubStr(cFormula, nI, 1)

            If (cChar == "*") .Or. (cChar == "/") .Or. (cChar == "+") .Or. (cChar == "-") .Or.; // Operadores matemáticos
                (cChar == ",") .Or. (cChar == ".") .Or. ; // Ponto ou vírgula
                (cChar >= "0" .And. cChar <= "9") .Or. ; // Número
                (cChar == "(") .Or. (cChar == ")") // Parenteses
                cBuffer += cChar
            Else
                lRet := .F.
                Exit
            EndIf
        Next
    Else
        lRet := .F.
    EndIf
Return lRet

//----------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} replaceNick

@description    Troca o nickname da fórmula pelo valor para cálculo
                Diferente do STRTRAN, esse método reconhece o nick por completo, por exemplo:

                **EXEMPLO***************************************************************************
                    se a formula for: =(VALOR_HE-VALOR_HE_TOTAL) e eu quiser trocar VALOR_HE por 10:
                        o Método fará: =(10-VALOR_HE_TOTAL)
                        e não: =(10-10_TOTAL)
                ************************************************************************************

@Param  cFormula, String, fórmula
        cNickName, String, NickName
        cReplace, String, Valor a ser trocado

@Return lRet, Logic

@author	jack.junior
@since	05/09/2025
/*/
//----------------------------------------------------------------------------------------------------------------
Method replaceNick(cFormula, cNickName, cReplace) Class GsPlan
    Local aParts      := {}
    Local cChar       := ""
    Local cNewFormula := ""
    Local cWord       := ""
    Local lInString   := .F.
    Local nX          := 0

    // Percorre toda a fórmula, caractere por caractere
    For nX := 1 To Len(cFormula)
        cChar := SubStr(cFormula, nX, 1)

        // Se encontrou aspas, inicia/fecha trecho literal
        If cChar == '"'
            lInString := !lInString

            // Se havia uma palavra em construção, salva antes
            If !Empty(cWord)
                AAdd(aParts, cWord)
                cWord := ""
            EndIf
            AAdd(aParts, cChar)
            Loop
        EndIf

        // Se NÃO está em string e o caractere faz parte de nome/símbolo
        If !lInString .And. cChar $ "ABCDEFGHIJKLMNOPQRSTUVWXYZ_0123456789"
            cWord += cChar
        Else
            // Quebrou a palavra? então finalize ela
            If !Empty(cWord)
                If !lInString .And. Upper(cWord) == Upper(cNickName)
                    AAdd(aParts, cReplace)
                Else
                    AAdd(aParts, cWord)
                EndIf
                cWord := ""
            EndIf
            // Adiciona o caractere isolado
            AAdd(aParts, cChar)
        EndIf
    Next
    
    // Se última palavra terminou no final do texto
    If !Empty(cWord)
        If !lInString .And. Upper(cWord) == Upper(cNickName)
            AAdd(aParts, cReplace)
        Else
            AAdd(aParts, cWord)
        EndIf
    EndIf

    // Junta tudo e compõe a formula:
    For nX := 1 To Len(aParts)
        If ValType(aParts[nX]) == "C"
            cNewFormula += aParts[nX]
        EndIf
    Next

Return cNewFormula

//----------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} getDependents

@description    Retorna em forma de array todos os dependentes da fórmula (apenas o que é nickname ou name)

@Param  cFormula, String, fórmula

@Return aNickNames, Array

@author	jack.junior
@since	05/09/2025
/*/
//----------------------------------------------------------------------------------------------------------------
Method getDependents(cFormula) Class GsPlan
    Local aNickNames := {}
    Local aTokens    := {}
    Local cNickname  := ""
    Local cRest      := ""
    Local nPosLetter := ""
    Local nX         := 0

    cFormula := Self:formAdjust(cFormula)

    // Expressão "regex-like" simplificada para capturar nicknames (A-Z, 0-9, _)
    aTokens := StrTokArr(cFormula, '+-*/()><;,"!=') // separa por operadores comuns

    // TO DO! AQUI PODE SER QUE DÊ PROBLEMAS PARA RECONHECER NICKNAMES TESTAR BEM E VALIDAR::
    For nX := 1 To Len(aTokens)
        cNickname := AllTrim(aTokens[nX])

        If !Empty(cNickname) .And. !Self:isCharNum(cNickname)
            // Pega o trecho restante da fórmula a partir da posição do token
            nPosLetter  := At(cNickname, cFormula)
            cRest := SubStr(cFormula, nPosLetter + Len(cNickname), 1)

            // Quando NÃO Considerar como célula:
            If cRest == "(" .Or. ;                  // Após o Token tiver PARENTESES, pois é uma FUNÇÃO: Ex: SOMA(A+B)
                cRest == '"' .Or. ;                 // Após o Token tiver ASPAS, pois é PARAMETRO de função: Ex 
                ".AND." $ UPPER(cNickname) .Or. ;   // Condicional .AND. dentro do Token
                ".OR." $ UPPER(cNickname)           // Condicional .OR. dentro do Token
                // NÃO CONSIDERA ESSE TOKEN !
            Else
                AADD(aNickNames, cNickname)
            EndIf
        EndIf
    Next nX
Return aNickNames

Method addCell(cColuna, nLinha, cNickName, cFormula, xValue, cPicture) Class GsPlan

    Local aDependOn := {}
    Local cIdItem   := "0"
    Local cName     := ""

    If !Empty(cColuna) .And. nLinha > 0

        cName := cColuna + AllTrim(Str(nLinha))

        If !Self:cellExists(cName)

            cIdItem := Soma1(Self:cLastID)

            Self:cLastID := cIdItem

            If !Empty(cFormula)
                // Ajusta a formula para que tags especials se ajustem Ex:("&gt;" vira ">")
                cFormula := Self:undecodeForm(cFormula)
                // Tudo que depende para executar a formula:
                aDependOn := Self:getDependents(cFormula)
            EndIf 

            // Adiciona novo item à Planilha:
            AADD(Self:aCells, {cIdItem,;    //1-ID DO ITEM
                                cColuna,;   //2-COLUNA (LETRA)
                                nLinha,;    //3-LINHA (NUMERO)
                                cName,;     //4-NOME
                                cNickName,; //5-NICKNAME
                                cFormula,;  //6-FORMULA
                                xValue,;    //7-VALUE
                                cPicture,;  //8-PICTURE    
                                aDependOn,; //9-DEPENDENTES 
                                cFormula})  //10-Backup da formula   

            If !Empty(cFormula)
                If Self:cellExists(cName)
                    // Recalcula a célula criada:
                    Self:recalcCell(Self:nCellPos)
                EndIf
            EndIf 
        EndIf
    EndIf
Return
