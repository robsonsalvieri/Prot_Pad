#INCLUDE "PROTHEUS.CH"

User Function UPDSITFEC()

Local aButtons  := {}
Local aSays     := {}
Local nOpcA     := 0

Private aLog        := {}
Private aTitle      := {}
Private cProcesso   := "     "
Private cPeriodo    := "      "
Private cFiltFil    := cFilAnt

aAdd(aSays,OemToAnsi( "Esta rotina tem como objetivo ajustar a situação dos funcionários      " ))
aAdd(aSays,OemToAnsi( "demitidos ou afastados que não foram atualizadas durante o fechamento mensal." ))
aAdd(aSays,OemToAnsi( "O sistema buscará funcionários que tiveram afastamento ou rescisão no período" ))
aAdd(aSays,OemToAnsi( "informado e atualizá-ra a situação, caso necesário."))
aAdd(aSays, "")
aAdd(aSays,OemToAnsi( "Efetue o BACKUP da base de dados antes da execução da rotina." ))

aAdd(aButtons, { 1,.T.,{|o| nOpcA := 1,IF(fLoadParams() .and. gpconfOK(), FechaBatch(), nOpcA := 0 ) }} )
aAdd(aButtons, { 2,.T.,{|o| FechaBatch() }} )

//Abre a tela de processamento
FormBatch( "Atualização da situação dos funcionários.", aSays, aButtons )

//Efetua o processamento de geração
If nOpcA == 1
    Aadd( aTitle, OemToAnsi( "Funcionários processados: " ) )
    Aadd( aLog, {} )
    ProcGpe( {|lEnd| fProcessa()},,,.T. )
    If Empty(aLog[1])
        MsgInfo("Nenhum registro processado")
    EndIf
    fMakeLog(aLog,aTitle,,,"UPDSITFEC",OemToAnsi("Log de Ocorrências"),"M","P",,.F.)
EndIf

Return

/*/{Protheus.doc} fLoadParams
Função para preenchimento dos parametros de processamento
/*/
Static Function fLoadParams()
Local oDlg
Local oFont
Local oSize
Local lRet  := .F.

DEFINE FONT oFont NAME "Arial" SIZE 0,-11 BOLD

oSize := FwDefSize():New()
oSize:AddObject( "CABECALHO",  160, 50, .F., .F. ) // Não dimensionavel

oSize:lProp 	:= .F. // Proporcional
oSize:aMargins 	:= { 3, 3, 3, 3 } // Espaco ao lado dos objetos 0, entre eles 3
oSize:Process() 	   // Dispara os calculos

Define MSDialog oDlg Title OemToAnsi("Parâmetros para processamento") FROM 0,0 TO 200,380 OF oMainWnd PIXEL

	@ oSize:GetDimension("CABECALHO","LININI") +5 , oSize:GetDimension("CABECALHO","COLINI")+10;
		TO oSize:GetDimension("CABECALHO","LINEND") +10,oSize:GetDimension("CABECALHO","COLEND")+10 LABEL OemToAnsi("Filtro") OF oDlg PIXEL

    @ oSize:GetDimension("CABECALHO","LININI") +18, oSize:GetDimension("CABECALHO","COLINI")+20 SAY OemToAnsi("Filial: ")	SIZE 146,10 OF oDlg PIXEL FONT oFont
    @ oSize:GetDimension("CABECALHO","LININI") +17, oSize:GetDimension("CABECALHO","COLINI")+50 MSGET oFilial VAR cFiltFil SIZE 050,10 OF oDlg PIXEL PICTURE "@!" F3 'SM0' VALID Vazio() .Or. ExistCpo("SM0",cEmpAnt + cFiltFil)

    @ oSize:GetDimension("CABECALHO","LININI") +33, oSize:GetDimension("CABECALHO","COLINI")+20 SAY OemToAnsi("Processo: ")	SIZE 146,10 OF oDlg PIXEL FONT oFont
    @ oSize:GetDimension("CABECALHO","LININI") +32, oSize:GetDimension("CABECALHO","COLINI")+50 MSGET oProcesso VAR cProcesso SIZE 050,10 OF oDlg PIXEL PICTURE "@!" F3 'RCJ' VALID Vazio() .Or. ExistCpo("RCJ")

    @ oSize:GetDimension("CABECALHO","LININI") +48, oSize:GetDimension("CABECALHO","COLINI")+20 SAY OemToAnsi("Período: ")	SIZE 146,10 OF oDlg PIXEL FONT oFont
    @ oSize:GetDimension("CABECALHO","LININI") +47, oSize:GetDimension("CABECALHO","COLINI")+50 MSGET oPeriodo VAR cPeriodo SIZE 050,10 OF oDlg PIXEL PICTURE "@E 999999" F3 "RCH" VALID NaoVazio()


	bSet15 := {|| lRet := .T., oDlg:End() }
	bSet24 := {|| lRet := .F., oDlg:End() }


ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar( oDlg , bSet15 , bSet24 )

If lRet
    lRet := !Empty(cPeriodo)
    If(!lRet, MsgInfo("O preenchimento do período é obrigatório") , Nil)
    If lRet .and. Empty(cFiltFil)
        lRet := MsgYesNo( "Filial não foi preenchida. Confirma o processamento para todas as Filiais? " )
    EndIf 
    If lRet .and. Empty(cProcesso)
        lRet := MsgYesNo( "Processo não foi preenchido. Confirma o processamento para todos os processos? " )
    EndIf           
EndIf

Return lRet

/*/{Protheus.doc} fProcessa
Função que efetua os ajustes na base
/*/
Static Function fProcessa()
Local aArea     := GetArea()
Local aFuncAtSit:= {}
Local cAliasQry := GetNextAlias()
Local cWhere	:= "%"
Local cWhereSRG	:= "%"
Local dDataIni  := StoD(cPeriodo + "01")
Local dDataFim  := StoD(cPeriodo + StrZero(f_UltDia(dDataIni),2))
Local dDtBsIni  := StoD(AnoMes(dDataBase)+"01")
Local dDtBsFim  := StoD(AnoMes(dDataBase) + StrZero(f_UltDia(dDtBsIni),2))
Local nX        := 0

If !Empty(cFiltFil)
	cWhere += " SR8.R8_FILIAL = '" + cFiltFil + "' AND "
    cWhereSRG += " SRG.RG_FILIAL = '" + cFiltFil + "' AND "
EndIf
If !Empty(cProcesso)
	cWhere += " SR8.R8_PROCES = '" + cProcesso + "' AND "
    cWhereSRG += " SRG.RG_PROCES = '" + cProcesso + "' AND "
EndIf

cWhere += "%"
cWhereSRG += "%"

BeginSql alias cAliasQry
    SELECT SR8.R8_FILIAL, SR8.R8_MAT, "AFA" AS SITUA
    FROM %table:SR8% SR8
    WHERE %Exp:cWhere%
    ( ( SR8.R8_DATAINI <= %Exp:DtoS(dDataFim)% AND SR8.R8_DATAFIM >= %Exp:DtoS(dDataIni)% ) OR
    ( SR8.R8_DATAINI >= %Exp:DtoS(dDataIni)% AND SR8.R8_DATAFIM = '') ) AND 
	SR8.%NotDel%
    UNION ALL 
    SELECT SRG.RG_FILIAL, SRG.RG_MAT, "DEM" AS SITUA
    FROM %table:SRG% SRG
    WHERE %Exp:cWhereSRG%
    SRG.RG_DATADEM >= %Exp:DtoS(dDataIni)% AND 
    SRG.RG_DATADEM <= %Exp:DtoS(dDataFim)% AND 
	SRG.%NotDel%
    ORDER BY SR8.R8_FILIAL, SR8.R8_MAT
EndSql

DbGoTop()

DbSelectArea("SRA")
DbSetOrder(1)

While (cAliasQry)->( !EoF() )

    If SRA->(DbSeek((cAliasQry)->(R8_FILIAL + R8_MAT)))

        If ((cAliasQry)->SITUA == "AFA" .or. Empty(SRA->RA_DEMISSA))

            aAdd(aFuncAtSit, {SRA->RA_FILIAL, SRA->RA_MAT, .T., If((cAliasQry)->SITUA == "AFA",dDtBsFim,dDataFim), If((cAliasQry)->SITUA == "AFA",dDtBsIni,dDataIni), SRA->(Recno())})

        EndIf 

    EndIf 
    (cAliasQry)->( dbSkip() )
Enddo   
        
(cAliasQry)->( dbCloseArea() )

GpProcRegua(Len(aFuncAtSit))

DbSelectArea("SRA")

For nX :=1 to Len(aFuncAtSit)

    SRA->(DbGoto(aFuncAtSit[nX,6]))

    If Empty(aLog[1])
		aAdd(aLog[1],"             " + Space(Len(SRA->RA_FILIAL)) + "                   Dt.Demissa     Sit.Folha     Resc.Rais     Cd.Afas.FGTS" )
		aAdd(aLog[1],"")
    EndIf

    aAdd( aLog[1] , "Funcionário: " + SRA->RA_FILIAL + " - " + SRA->RA_MAT +  " - Antes: " + DtoC(SRA->RA_DEMISSA) + "     " + SRA->RA_SITFOLH + "             " + SRA->RA_RESCRAI + "            " + SRA->RA_AFASFGT)

	RetSituacao(aFuncAtSit[nX,1], aFuncAtSit[nX,2], aFuncAtSitnX[nX,3], aFuncAtSit[nX,4], .F., .F., .F., aFuncAtSit[nX,5])

    aAdd( aLog[1] , "             " + Space(Len(SRA->RA_FILIAL)) + "           Depois: " + DtoC(SRA->RA_DEMISSA) + "     " + SRA->RA_SITFOLH + "             " + SRA->RA_RESCRAI + "            " + SRA->RA_AFASFGT)

    GpIncProc()
Next nX 

RestArea( aArea)

Return
