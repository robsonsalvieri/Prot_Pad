#INCLUDE 'rwmake.ch'
#INCLUDE 'PROTHEUS.CH'

/*/{Protheus.doc} WFAUTOTRAN
    Función principal que se debe informar en el Schedule
    /*/
Function WFAUTOTRAN()
    If IsBlind() 
        BatchProcess("","",,{ || TSTExec() })
    EndIf
Return Nil

/*/{Protheus.doc} TSTExec
    Función informanda en la función BatchProcess, la cual se ejecutará
    conforme a la periodicidad informada en el Schedule.
    /*/
Function TSTExec()
    Local cPerg := "MATA486K"
    Local lPE  := ExistBlock("MAUTOTRAN")

    If lPE
        ExecBlock("MAUTOTRAN",.F.,.F.)
    Else
        MakeSqlExpr(cPerg)
        DSVFAT1(MV_PAR01,MV_PAR02)
    Endif

Return       

/*/{Protheus.doc} SchedDef
    Función requerida para definir el grupo de preguntas 
    en los parámetros del Schedule.
    /*/
Static Function SchedDef()
    Local aParam  := {}

    aParam := { "P",;			//Tipo R para relatorio P para processo
                "MATA486K",;		//Pergunte do relatorio, caso nao use passar ParamDef
                ,;				//Alias
                ,;				//Array de ordens
                ""}				//Titulo - "Calculo de Depreciacao e Correcao Monetaria"

Return aParam
