#INCLUDE "Totvs.ch"
#INCLUDE 'Fileio.ch'
#DEFINE CLASS_NAME 1
#DEFINE METH_NAME 1
#DEFINE PARAMS 2
#DEFINE PARAM_NAME 2
#DEFINE PROP_NAME 1

User Function DocClass(aClasses, nOpc)
    Local cDoc := ""
    Local nClasse := 0
    // Local aClasses := {"FWCOSCHDAGENT","FWUISCHDAGENTPERSIST","FWDASCHDAGENT","FWVOSCHDAGENT"}
    Local nLen := 0
    Local oObj := Nil
    Private nOpcao
    Default aClasses := {"PRJWZCONFIG","PRJWZPG","PRJWZFILES","PRJWZPGSCD","PRJSCHED","PRJWZPGARQ","PRJWZPGPRM","PRJWZPGMIL","PRJWZPGCSV"}
    Default nOpc := "1"
    nLen := Len(aClasses)
    nOpcao := Val(nOpc)

    For nClasse := 1 to nLen
        oObj := &(aClasses[nClasse]+"():new()")
        cDoc := montaDoc(aClasses[nClasse],ClassMethArr(oObj,.T.),ClassDataArr(oObj,.T.))
        FreeObj(oObj)
        oObj := Nil
        gravaDoc(cDoc, aClasses[nClasse])
    Next nClasse
Return

Static Function montaDoc(cClass,aMeth, aProp) 
    Local cDoc := ""
    Local nMethod := 0 
    Local nProp := 0 
    Local nParam := 0 
    Local nLenMeth := Len(aMeth)
    Local nLenProp := Len(aProp)
    Local nLenParam := 0
    Local cMeth := ""
    Local cParam := ""
    cDoc += "====================================" + CRLF
    cDoc += "Classe: " + cClass + CRLF
    cDoc += "" + CRLF
    cDoc += "    <Descrição da classe>" + CRLF
    cDoc += "" + CRLF
    cDoc += "h2. Propriedades:" + CRLF
    cDoc += "" + CRLF
    For nProp := 1 to nLenProp
        cProp := "    " + cClass + ":" + aProp[nProp][PROP_NAME] + CRLF
        If nOpcao == 1
            cProp += "" + CRLF
            cProp += "        <Descrição da propriedade>" + CRLF
            cProp += "" + CRLF
            cProp += "        ||Tipo||" + Chr(9) + "Valor Padrão||" + Chr(9) + "Somente Leitura||" + CRLF
            cProp += "" + CRLF
            cProp += "        |" + getType(aProp[nProp][PROP_NAME]) + Chr(9) + "|<DEFAULT>|" + Chr(9) + "N|" + CRLF
        EndIf
        cDoc += cProp + CRLF
    Next nProp
    cDoc += "" + CRLF
    cDoc += "h2. Métodos:"    + CRLF
    For nMethod := 1 to nLenMeth
        nLenParam := Len(aMeth[nMethod][PARAMS]) 
        cDoc += "" + CRLF
        cDoc += "    " + cClass + ":" + aMeth[nMethod][METH_NAME] + CRLF 
        If nOpcao == 1
            cDoc += "" + CRLF
            cDoc += "        <Descrição do método>" + CRLF 
            cDoc += "" + CRLF
            cDoc += "    h2. Sintaxe:" + CRLF
            cDoc += "" + CRLF
            cMeth := "        {" + cClass + "():" + aMeth[nMethod][METH_NAME] + "(" 
            For nParam := 1 to nLenParam
                cMeth += " < " + aMeth[nMethod][PARAMS][nParam] + " > " + IIf(nParam < Len(aMeth[nMethod][PARAMS]),",","" ) 
            Next nParam 
            cMeth += ")}"
            cDoc += cMeth + CRLF 
            If nLenParam > 0
                cDoc += "" + CRLF
                cDoc += "    h2. Parâmetros:" + CRLF
                cDoc += "" + CRLF
                cDoc += "        ||Nome||" + Chr(9) + "Tipo||" + Chr(9) + "Descrição||" + Chr(9) + "Obrigatório||" + Chr(9) + "Referência||" + CRLF
                For nParam := 1 to nLenParam
                    cParam := "        |" + aMeth[nMethod][PARAMS][nParam] + "|" + Chr(9) + getType(aMeth[nMethod][PARAMS][nParam]) + "|" + Chr(9) + "<PARAM DESCRIPTION>|" + Chr(9) + "<REQUIRED>|" + Chr(9) + "<BY REFERENCE>|"
                    cDoc += cParam + CRLF
                Next nParam 
            EndIf
        EndIf
    Next nMethod  
    cDoc += "" + CRLF
Return cDoc

Static Function getType(cParam) 
    Local cType := "Indefinido"
    Local cIni := UPPER(SubStr(cParam,1,1))

    Do Case
        Case cIni == "N"
            cType := "Numerico"
        Case cIni == "C"
            cType := "Texto"
        Case cIni == "L"
            cType := "Lógico"
        Case cIni == "D"
            cType := "Data"
        Case cIni == "A"
            cType := "Array"
        Case cIni == "O" .OR. cIni == "J"
            cType := "Objeto"
    End Case

Return cType

Static Function gravaDoc(cDoc, cClassName)
    Local cPath := "\doc\" + cClassName + "_docCompleto.txt"
    Local nFile
    If nOpcao == 2
        cPath := "\doc\" + cClassName + "_docSimples.txt"
    EndIF
    nFile := FCREATE(cPath, FC_NORMAL)
    If nFile < 0
        nFile := FOpen(cPath, FO_READWRITE)
    EndIf
    If nFile >= 0
        fwrite(nFile, cDoc)
        fclose(nFile)
    EndIf
Return
/*
Classe: <CLASS NAME>

Descrição:
    <Descrição da classe>
Propriedades:
    <PROPERTY NAME>: <PROPERTY TYPE>    
Métodos:
    <METHOD NAME>
    Descrição:
        <Descrição do método>
    Sintaxe:
        <CLASS NAME>():<METHOD NAME>(<PARAM 1>,<PARAM 2>,<PARAM 3>,...,<PARAM N>) -> <RETORNO>

    Parametros:
        <PARAM NAME> <PARAM TYPE> <PARAM DESCRIPTION> <DEFAULT> <REQUIRED> <BY REFERENCE>
        <PARAM NAME> <PARAM TYPE> <PARAM DESCRIPTION> <DEFAULT> <REQUIRED> <BY REFERENCE>
        <PARAM NAME> <PARAM TYPE> <PARAM DESCRIPTION> <DEFAULT> <REQUIRED> <BY REFERENCE>
        <PARAM NAME> <PARAM TYPE> <PARAM DESCRIPTION> <DEFAULT> <REQUIRED> <BY REFERENCE>

*/