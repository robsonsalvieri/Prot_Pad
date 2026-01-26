#INCLUDE "PROTHEUS.CH" 
#INCLUDE "TBICONN.CH"
#INCLUDE "TAFA631.ch" 

/*{Protheus.doc} TAFA631
@type			function
@description	Função que atua como Job no schedule para executar a Transmissão de eventos da REINF.
@author			Wesley Matos
@since			31/10/2024
@version		1.0
@return			Nil 
*/
Function TAFA631()

    Local cPeriod as Character
    Local cMes    as Character
    Local cAno    as Character

    cPeriod := ''
    cMes    := StrZero(Month(Date()), 2)
    cAno    := cValToChar(Year(Date()))
    cPeriod := cMes + cAno

    AutoTrans(cPeriod)
    AutoGovCon(cPeriod)

return Nil


/*{Protheus.doc} GrvSchT8M
@type			function
@description	Função para criar o schedule com base nos dados gravados na tabela T8M.
@author			Wesley Matos
@since			28/10/2024
@version		1.0
@return			lCreate - .T. se o schedule foi criado com sucesso.
*/
Function GrvSchT8M(cFil as Character)

    Local oScheduleAuto as object
    Local cEnv          as Character
    Local cDiaIni       as Character
    Local cDiaFin       as Character
    Local cRecor        as Character
    Local cCodSch       as Character
    Local dDataPri      as Date
    Local cMes          as Character
    Local cAno          as Character
    Local lCreate       as Logical
    Local cTime         as Character
    Local cTimePri      as Character

    cDiaIni    := ''
    cDiaFin    := ''
    cRecor     := ''
    cCodSch    := ''
    dDataPri   := CToD(' / / ')
    cMes       := cValToChar(Month(Date()))
    cAno       := cValToChar(Year(Date()))
    cEnv       := TafSchdRun()
    lCreate    := .F.
    cTime      := Time()
    cHoraIni   := ''
    cMinutoIni := ''
    cTimePri   := ''

    oScheduleAuto := totvs.framework.schedule.automatic():new()

    DBSelectArea("T8M")
    T8M->(DBSetOrder(1))
    
    If T8M->(DbSeek(cFil))
        cDiaIni    := T8M->T8M_DIAINI
        cDiaFin    := T8M->T8M_DIAFIM
        cRecor     := T8M->T8M_RECORR
        cCodSch    := T8M->T8M_CODSCH
        cHoraIni   := "00"
        cMinutoIni := "10"
        cTimePri   := "00:01:00"
        dDataPri   := CToD(cDiaIni + "/" + cMes + "/" + cAno)
        
        Do Case
            Case cRecor == "1"
                cRecor := "15"
            Case cRecor == "2"
                cRecor := "30"
            Case cRecor == "3"
                cRecor := "45"
            Case cRecor == "4"
                cRecor := "60"
        EndCase

        If dDataPri < Date()
            cMes  := cValToChar(Month(Date())+1)
            If cMes == "13"
                cAno := cValToChar(Year(Date())+1)
                cMes := "01"
            EndIf
            dDataPri := CToD(cDiaIni + "/" + cMes + "/" + cAno)
        EndIf

        If dDataPri == Date()
            cHoraIni   := SubStr(cTime,1,2)
            cMinutoIni := SubStr(cTime,4,2)
            cTimePri   := cTime
        EndIf

        If Empty(cEnv)
            cEnv := GetEnvServer()
        Endif
        
        If Empty(Alltrim(cCodSch))

            //Cria o agendamento
            oScheduleAuto:setRoutine("TAFA631")
            oScheduleAuto:setFirstExecution(dDataPri,cTimePri)
            oScheduleAuto:setPeriod("M", Val(cDiaIni),Val(cHoraIni),Val(cMinutoIni))
            oScheduleAuto:setFrequency("M", Val(cRecor),Val(cDiaFin),23,50)
            oScheduleAuto:setDiscard(.T.)
            oScheduleAuto:setEnvironment(cEnv,{{cEmpAnt,{cFilAnt}}})
            oScheduleAuto:setModule(84)
            oScheduleAuto:setUser(__cUserID)
            oScheduleAuto:setDescription(STR0001)//"Consulta Automatica Reinf"
            oScheduleAuto:setRecurrence(.T.)
            
            If oScheduleAuto:createSchedule()
                lCreate := .T.
                aDados  := ClassDataArr(oScheduleAuto)
                RecLock("T8M",.F.)
                T8M->T8M_CODSCH := aDados[12][2] //Grava código do agendamento na T8M
                T8M->(MsUnLock())
            EndIf
        else
            //Altera o agendamento
            If !Empty(FWSchdEmpFil(cCodSch))
                oScheduleAuto:setSchedule(cCodSch)
                oScheduleAuto:setFirstExecution(dDataPri,cTimePri)
                oScheduleAuto:setPeriod("M", Val(cDiaIni),Val(cHoraIni),Val(cMinutoIni))
                oScheduleAuto:setFrequency("M", Val(cRecor),Val(cDiaFin),23,50)
                oScheduleAuto:setRecurrence(.T.)
                oScheduleAuto:setDiscard(.T.)
                oScheduleAuto:setEnvironment(cEnv,{{cEmpAnt,{cFilAnt}}})
                lCreate := oScheduleAuto:updateSchedule()
            EndIf
        EndIf
    EndIf

    T8M->(DbCloseArea())

return lCreate


/*{Protheus.doc} DelSchT8M
@type			function
@description	Função para deletar o schedule com base nos dados gravados na tabela T8M.
@author			Wesley Matos
@since			28/10/2024
@version		1.0
@return			lDelete - .T. se o schedule foi deletado com sucesso.
*/
Function DelSchT8M(cFil as Character, lAutomato as Logical)

    Local oScheduleAuto as object
    Local cCodSch       as Character
    Local lDelete       as Logical

    Default lAutomato := .F.

    cCodSch := ''
    lDelete := .T.

    oScheduleAuto := totvs.framework.schedule.automatic():new()

    If T8M->(DbSeek(cFil))
        cCodSch := T8M->T8M_CODSCH
        
        If !Empty(FWSchdEmpFil(cCodSch))
            oScheduleAuto:setSchedule(cCodSch)
            lDelete := oScheduleAuto:deleteSchedule()
        EndIf
    EndIf

    If lAutomato
        lDelete := .F.
    EndIf

return lDelete


/*{Protheus.doc} AutoTrans
@type			function
@description	Função para executar a Transmissão de eventos da REINF.
@author			Wesley Matos
@since			31/10/2024
@version		1.0
@return			Nil 
*/
Static Function AutoTrans(cPeriod as Character)

    Local lAll      as Logical
    Local cMsgRet   as Character
    Local aRetErro  as Array
    Local lAut      as Logical
    Local aEvento   as Array
    Local nI        as Number
    Local cAlsFilho as Character
    Local aEvents   as Array
    Local cAliasTmp as Character
    Local aRegRec   as Array

    lAll      := .T.
    cMsgRet   := ''
    aRetErro  := {}
    lAut      := .F.
    aEvento   := EventReinf()
    nI        := 0
    cAlsFilho := ''
    aEvents   := {}
    cAliasTmp := ''
    aRegRec   := {}

    TafConout(STR0002)//Inicio da Transmissão Automatica!

    For nI := 1 To Len(aEvento)

        Do Case
            Case aEvento[ni] == "R-2020"
			    cAlsFilho := "C1H"
            Case aEvento[ni] == "R-2030"
			    cAlsFilho := "V1G"
            Case aEvento[ni] == "R-2040"
			    cAlsFilho := "V1J"
            Case aEvento[ni] == "R-4010"
                cAlsFilho := "V5E"
            Case aEvento[ni] == 'R-4020'
                cAlsFilho  := 'V4S'
            Case aEvento[ni] == 'R-4040'
                cAlsFilho  := 'V4P'
            Case aEvento[ni] == 'R-4080'
                    cAlsFilho  := 'V99'
            OtherWise
                cAlsFilho := ""
        EndCase

        aEvents := TAFRotinas( aEvento[nI], 4, .F., 5 )
        If Len(aEvents) > 0
            cAliasTmp := WS004Event( aEvents, cPeriod, cAlsFilho , , lAll )

            If (cAliasTmp)->(!Eof())
                aRegRec := WSTAFRecno( cAliasTmp )
                TAFProc9TSS( .T.,aEvents,Nil,Nil,Nil,Nil,Nil,@cMsgRet,Nil,Nil,Nil,Nil,Nil,aRegRec,,.F.,@aRetErro )
            Else
                TafConout(STR0003 + aEvento[nI])//Não há registros para a transmissão do evento:
            EndIf
        EndIf
    Next nI

    TafConout(STR0004)//Fim da Transmissão Automatica!

return Nil


/*{Protheus.doc} AutoGovCon
@type			function
@description	Função para executar a Transmissão de eventos da REINF.
@author			Wesley Matos
@since			04/11/2024
@version		1.0
@return			Nil 
*/
Static Function AutoGovCon(cPeriod as Character)

    Local cMsgRet   as Character
    Local aEvento   as Array
    Local nI        as Number
    Local aEvents   as Array
    Local cAliasTmp as Character
    Local aRegRec   as Array
    Local dDataIni  as Date
    Local dDataFim  as Date

    cMsgRet   := ''
    aEvento   := EventReinf()
    nI        := 0
    aEvents   := {}
    cAliasTmp := ''
    aRegRec   := {}

    TafConout(STR0005) //Inicio da Consulta ao Governo Automatica!

    dDataIni := CToD( "01/" + SubStr( cPeriod, 1, 2 ) + "/" + SubStr( cPeriod,3,4 ) )
	dDataFim := LastDay( CToD( "01/" + SubStr( cPeriod, 1, 2 ) + "/" + SubStr( cPeriod, 3, 4 ) ) )

    For nI := 1 To Len(aEvento)

        aEvents := TAFRotinas( aEvento[nI], 4, .F., 5 )

        If Len(aEvents) > 0
            cAliasTmp := WS005Stat( aEvents, cPeriod, "2",, cFilAnt )
            If (cAliasTmp)->(!Eof())
                aRegRec := WSTAFRecno( cAliasTmp )
                ( cAliasTmp )->( DBCloseArea() )
                TAFProc10TSS( .F., aEvents, /*cStatus*/, /*aIDTrab*/, /*cRecnos*/, /*lEnd*/, @cMsgRet, /*aFiliais*/, dDataIni, dDataFim, /*lEvtInicial*/, /*lCommit*/, aRegRec, /*cIDEnt*/ )
            Else
                TafConout(STR0006 + aEvento[nI]) //Não há consulta para o evento:
            EndIf
        EndIf

    Next nI

    TafConout(STR0007) //Fim da Consulta ao Governo Automatica!
return Nil


/*{Protheus.doc} AutoGovCon
@type			function
@description	Função para retornar os eventos da REINF.
@author			Wesley Matos
@since			04/11/2024
@version		1.0
@return			aEvento - Array com os eventos da REINF.
*/
Static Function EventReinf()

    Local aEvento   as Array
    Local lReinf20  as Logical

    aEvento  := {}
    lReinf20 := alltrim(StrTran( SuperGetMv('MV_TAFVLRE',.F.,'') ,'_','')) >= '20102'

    AAdd(aEvento, "R-2010")
    AAdd(aEvento, "R-2020")

    If lReinf20
        AAdd(aEvento, "R-4010")
        AAdd(aEvento, "R-4020")
    EndIf

    AAdd(aEvento, "R-2050")
    AAdd(aEvento, "R-2055")
    AAdd(aEvento, "R-2030")
    AAdd(aEvento, "R-2040")
    AAdd(aEvento, "R-2060")
    
    If lReinf20
        AAdd(aEvento, "R-4080")
        AAdd(aEvento, "R-4040")
    EndIf

return aEvento


//-------------------------------------------------------------------
/*/{Protheus.doc} SchedDef
Informacoes de definicao dos parametros do schedule
@Return  Array com as informacoes de definicao dos parametros do schedule
		 Array[x,1] -> Caracter, Tipo: "P" - para Processo, "R" - para Relatorios
		 Array[x,2] -> Caracter, Nome do Pergunte
		 Array[x,3] -> Caracter, Alias(para Relatorio)
		 Array[x,4] -> Array, Ordem(para Relatorio)
		 Array[x,5] -> Caracter, Titulo(para Relatorio)

@author Wesley Matos
@since  04/11/2024
@version 1.0

/*///----------------------------------------------------------------
Static Function SchedDef()

	Local aParam  := {}

	aParam := { "P";			//Tipo R para relatorio P para processo
	           	,"ParamDef";	//Pergunte do relatorio, caso nao use passar ParamDef
	            ,;				//Alias
	            ,;				//Array de ordens
	            ,STR0008 } 	    //Esta rotina realiza a transmissão e consulta automatica para os eventos periódicos da EFD-REINF

Return ( aParam )
