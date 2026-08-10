/*
Funcao EICCV101
Objetivo: função executada a partir da consulta padrão YR1 na inclusão de registro
Reabrir a tabela temporária TRB caso ela exista no momento da execão da consulta padrão e se foi gerada outra instãncia da TRB no fonte EICCV100
Parâmetros: nenhum
Retorno: nenhum
Author: Maurício
Data: 04/12/2024
*/
Function EICCV101
Local cArqSI := ''
Local cAliasLocal := ''
Local cNewTRB := ''
Local aStruSI := {}
IF SELECT("TRB") > 0
    cArqSI := if(ismemVar("cNomArq"),cNomArq,'')
    cAliasLocal := getNextAlias()
    cNewTRB := Criatrab(,.f.)
    TRB->(TETempBackup(cNewTRB))
    TETempReopen(cArqSI, "TRB",cAliasLocal)
    ("TRB")->(dbCloseArea())
    EICCV100(3)
    aStruSI:=(cNewTRB)->(dbStruct())
    cNomArq:=e_CriaTrab(,aStruSI,"TRB")
    IndRegua("TRB",cNomArq+TEOrdBagExt(),"W1_COD_I+STR(W1_REG,"+Alltrim(STR(AVSX3("W1_REG",3)))+",0)")
    cNomArq2 := CriaTrab(,.F.)
    IndRegua("TRB",cNomArq2+TEOrdBagExt(),"W1_POSIT")
    TRB->(dbSetIndex(cNomArq+TEOrdBagExt()),dbSetIndex(cNomArq2+TEOrdBagExt()))
    TRB->(dbSetOrder(1))
    TRB->(TERestBackup(cNewTRB))
else
    EICCV100(3)
EndIf
return   
