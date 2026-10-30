#include 'protheus.ch'
#INCLUDE "FWMVCDEF.CH"

class PrestPlan
    data cTotLines AS CHARACTER
    data cTotColuns AS CHARACTER
    data cRetXmlPlan AS CHARACTER
    data nIdPlan AS NUMBER

    method new() constructor
    method defTotLines()
    method defTotColuns()
    method IniPlan()
    method getXmlPlan()
    method IniItems()
    method FimItems()
    method FimPlan()
    method AddValor()
    method destroy()
endclass

//Define a construção
method new() class PrestPlan

::cTotLines := "0"
::cTotColuns := "0"
::cRetXmlPlan := ""
::nIdPlan := 1

return

//Define o total de linhas
method defTotLines(cSetValue) class PrestPlan
    If VALTYPE(cSetValue) == 'C'
        ::cTotLines := cSetValue
    Endif
Return ::cTotLines

//Define o total de colunas
method defTotColuns(cSetValue) class PrestPlan
    If VALTYPE(cSetValue) == 'C'
        ::cTotColuns := cSetValue
    Endif
Return ::cTotColuns

//Inicializa a Planilha
method IniPlan() class PrestPlan

::cRetXmlPlan += Alltrim('<?xml version="1.0" encoding="UTF-8"?>')
::cRetXmlPlan += Alltrim('<FWMODELSHEET Operation="4" version="1.01">')
::cRetXmlPlan += Alltrim('    <MODEL_SHEET modeltype="FIELDS">')

::cRetXmlPlan += Alltrim('        <TOTLINES order="1">')
::cRetXmlPlan += Alltrim('            <value>'+::cTotLines+'</value>')
::cRetXmlPlan += Alltrim('        </TOTLINES>')

::cRetXmlPlan += Alltrim('        <TOTCOLUMNS order="2">')
::cRetXmlPlan += Alltrim('            <value>'+::cTotColuns+'</value>')
::cRetXmlPlan += Alltrim('        </TOTCOLUMNS>')

::cRetXmlPlan += Alltrim('        <MODEL_CELLS modeltype="GRID" optional="1">')
::cRetXmlPlan += Alltrim('            <struct>')
::cRetXmlPlan += Alltrim('                <NAME order="1"></NAME>')
::cRetXmlPlan += Alltrim('                <NICKNAME order="2"></NICKNAME>')
::cRetXmlPlan += Alltrim('                <FORMULA order="3"></FORMULA>')
::cRetXmlPlan += Alltrim('                <VALUE order="4"></VALUE>')
::cRetXmlPlan += Alltrim('                <PICTURE order="5"></PICTURE>')
::cRetXmlPlan += Alltrim('                <BLOCKCELL order="6"></BLOCKCELL>')
::cRetXmlPlan += Alltrim('                <BLOCKNAME order="7"></BLOCKNAME>')
::cRetXmlPlan += Alltrim('            </struct>')

Return .T.

//Get do xml da planilha
method getXmlPlan() class PrestPlan

Return ::cRetXmlPlan

//Inicia os itens da planilha
method IniItems() class PrestPlan

::cRetXmlPlan += Alltrim('            <items>')

Return .T.

//Inicia os itens da planilha
method FimItems() class PrestPlan

::cRetXmlPlan += Alltrim('            </items>')

Return .T.

//Fecha a Planilha
method FimPlan() class PrestPlan

::cRetXmlPlan += Alltrim('        </MODEL_CELLS>')
::cRetXmlPlan += Alltrim('    </MODEL_SHEET>')
::cRetXmlPlan += Alltrim('</FWMODELSHEET>')

Return .T.

//Adiciona valor nas celulas
method AddValor(cName,cNickName,cFormula,cValue,cPicture,cBlockCell,cBlockName) class PrestPlan
Local cStringAux := ""

::cRetXmlPlan += Alltrim('                <item id="'+cValTocHar(::nIdPlan++)+'" deleted="0" >')

If VALTYPE(cName) == 'C' .And. !Empty(cName)
    ::cRetXmlPlan += Alltrim('                  <NAME>'+cName+'</NAME>')
Endif

If VALTYPE(cNickName) == 'C' .And. !Empty(cNickName)
    ::cRetXmlPlan += Alltrim('                  <NICKNAME>'+cNickName+'</NICKNAME>')
Endif

If VALTYPE(cFormula) == 'C' .And. !Empty(cFormula)
    cStringAux := StrTran(cFormula,".",",")
    //AJUSTA CONDIÇÃO AND:
    cStringAux := StrTran(cStringAux,",AND,",".AND.")
    //AJUSTA CONDIÇÃO OR:
    cStringAux := StrTran(cStringAux,",OR,",".OR.") 

    ::cRetXmlPlan += Alltrim('                  <FORMULA>'+cStringAux+'</FORMULA>')    
Endif

If VALTYPE(cValue) == 'C' .And. !Empty(cValue)
    ::cRetXmlPlan += Alltrim('                  <VALUE>'+cValue+'</VALUE>')
Endif

If VALTYPE(cPicture) == 'C' .And. !Empty(cPicture)
    ::cRetXmlPlan += Alltrim('                  <PICTURE>'+cPicture+'</PICTURE>')
Endif

If VALTYPE(cBlockCell) == 'C' .And. !Empty(cBlockCell)
    ::cRetXmlPlan += Alltrim('                  <BLOCKCELL>'+cBlockCell+'</BLOCKCELL>')
Endif

If VALTYPE(cBlockName) == 'C' .And. !Empty(cBlockName)
    ::cRetXmlPlan += Alltrim('                  <BLOCKNAME>'+cBlockName+'</BLOCKNAME>')
Endif

::cRetXmlPlan += Alltrim('                </item>')

Return .T.

//destroy
method destroy() class PrestPlan
    ::cTotLines := "0"
    ::cTotColuns := "0"
    ::cRetXmlPlan := ""
    ::nIdPlan := 0
return
