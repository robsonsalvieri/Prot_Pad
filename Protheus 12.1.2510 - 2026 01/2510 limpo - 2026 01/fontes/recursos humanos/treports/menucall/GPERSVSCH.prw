#INCLUDE "GPERSVSCH.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} GPERSVSCH

Geração de relatórios do SV via Schedule.

@author  caio.kretzer
@since   28/11/2024
@version 1.0
/*/

Function GPERSVSCH()

    Local cRelatorio    							As Character
    Local cDescRel      							As Character
	Local jPrintInfo	:= JsonObject():New()		as Json
	Local cFilePath									as Character
	Local lSuccess 									as Logical
	Local lEmailUsuario 							as Logical
	Local lEmailFuncionario 						as Logical
	Local cMailUser									as Character
	Local cMailFunc									as Character
	Local cMailAssunto								as Character
	Local cMailHtml									as Character
	Local cQuery									as Character
	Local oStatement								as Object
	Local oSmartView								as Object
	Local cMatricula								as Character
	Local cFilMat									as Character
	Local cAlias									as Character
	Local aFiles									as Array
	Local nParamOrder								as Numeric

    cRelatorio  		:= MV_PAR01
    lSuccess    		:= .F.
	lEmailUsuario		:= .F.
	lEmailFuncionario	:= .F.
    cDescRel   			:= ""
	cMatricula  		:= ""
	cFilMat  			:= ""
    
    jPrintInfo['name'] := cRelatorio+"SmartView_"+FWTimeStamp()
    jPrintInfo['path'] := "\spool\"
    jPrintInfo['extension'] := "pdf"

	ProcRegua(1)

    If cRelatorio == "GPER011"

        cDescRel 			:= STR0001
		cMatricula 			:= MV_PAR06
		cFilMat 			:= MV_PAR07
		lEmailUsuario		:= MV_PAR08 == "true"
		lEmailFuncionario	:= MV_PAR09 == "true"
		jPrintInfo['name'] 	+= "_"+cMatricula 

        // Instancia a classe callSmartView()
        oSmartView := totvs.framework.smartview.callSmartView():new("rh.sv.gpe.gper011.default.rep", "report")
        oSmartView:setNoInterface(.T.)
    	oSmartView:setPrintType(1)
        oSmartView:setPrintInfo(jPrintInfo)
		
		If MV_PAR02 != ""
			oSmartView:setParam("PAR_PROCESSO"		, MV_PAR02)
		Endif
		If MV_PAR03 != ""
			oSmartView:setParam("PAR_PERIODO"		, MV_PAR03)
		Endif
		If MV_PAR04 != ""
			oSmartView:setParam("PAR_NROPAG"		, MV_PAR04)
		Endif
		If MV_PAR05 != ""
			oSmartView:setParam("PAR_FILIAL"		, MV_PAR05)
		Endif
		If MV_PAR06 != ""
			oSmartView:setParam("PAR_MAT"	        , MV_PAR06)
		Endif

    ElseIf cRelatorio == "GPER014"

        cDescRel 			:= STR0002
		cMatricula 			:= MV_PAR03
		cFilMat 			:= MV_PAR07
		lEmailUsuario		:= MV_PAR08 == "true"
		lEmailFuncionario	:= MV_PAR09 == "true"
		jPrintInfo['name'] 	+= "_"+cMatricula 

        // Instancia a classe callSmartView()
        oSmartView := totvs.framework.smartview.callSmartView():new("rh.sv.gpe.gper014.default.rep", "report")
        oSmartView:setNoInterface(.T.)
    	oSmartView:setPrintType(1)
        oSmartView:setPrintInfo(jPrintInfo)

		If MV_PAR02 != ""
			oSmartView:setParam("filial"			, MV_PAR02)
		Endif
		If MV_PAR03 != ""
			oSmartView:setParam("matricula"			, MV_PAR03)
		Endif
		If MV_PAR04 != ""
			oSmartView:setParam("mesAnoDe"			, MV_PAR04)
		Endif
		If MV_PAR05 != ""
			oSmartView:setParam("mesAnoAte"			, MV_PAR05)
		Endif
		If MV_PAR06 != ""
			oSmartView:setParam("PAR_RELATORIO"		, MV_PAR06)
		Endif

    ElseIf cRelatorio == "GPER030"

        cDescRel 			:= STR0003
		cMatricula 			:= MV_PAR09
		cFilMat 			:= MV_PAR11
		lEmailUsuario		:= MV_PAR12 == "true"
		lEmailFuncionario	:= MV_PAR13 == "true"
		jPrintInfo['name'] 	+= "_"+cMatricula 

        oSmartView := totvs.framework.smartview.callSmartView():new("rh.sv.gpe.gper030.default.rep", "report")
        oSmartView:setNoInterface(.T.)
    	oSmartView:setPrintType(1)
        oSmartView:setPrintInfo(jPrintInfo)

		If MV_PAR02 != ""
			oSmartView:setParam("PAR_PROCESSO", MV_PAR02)
		Endif
		If MV_PAR03 != ""
			oSmartView:setParam("PAR_ROTEIRO", MV_PAR03)
		Endif
		If MV_PAR04 != ""
			oSmartView:setParam("PAR_PERDE", MV_PAR04)
		Endif
		If MV_PAR05 != ""
			oSmartView:setParam("PAR_SEMDE", MV_PAR05)
		Endif
		If MV_PAR06 != ""
			oSmartView:setParam("PAR_PERATE", MV_PAR06)
		Endif
		If MV_PAR07 != ""
			oSmartView:setParam("PAR_SEMATE", MV_PAR07)
		Endif
		If MV_PAR08 != ""
			oSmartView:setParam("PAR_FIL", MV_PAR08)
		Endif
		If MV_PAR09 != ""
			oSmartView:setParam("PAR_MATDE", MV_PAR09)
		Endif
		If MV_PAR10 != ""
			oSmartView:setParam("PAR_MATATE", MV_PAR10)
		Endif

    ElseIf cRelatorio == "GPER084"

        cDescRel 			:= STR0004
		cMatricula 			:= MV_PAR09
		cFilMat 			:= MV_PAR11
		lEmailUsuario		:= MV_PAR12 == "true"
		lEmailFuncionario	:= MV_PAR13 == "true"
		jPrintInfo['name'] 	+= "_"+cMatricula 

        oSmartView := totvs.framework.smartview.callSmartView():new("rh.sv.gpe.gper084.default.rep", "report")
        oSmartView:setNoInterface(.T.)
    	oSmartView:setPrintType(1)
        oSmartView:setPrintInfo(jPrintInfo)

		If MV_PAR02 != ""
			oSmartView:setParam("PAR_PROCESSO", MV_PAR02)
		Endif
		If MV_PAR03 != ""
			oSmartView:setParam("PAR_ROTEIRO", MV_PAR03)
		Endif
		If MV_PAR04 != ""
			oSmartView:setParam("PAR_PERDE", MV_PAR04)
		Endif
		If MV_PAR05 != ""
			oSmartView:setParam("PAR_SEMDE", MV_PAR05)
		Endif
		If MV_PAR06 != ""
			oSmartView:setParam("PAR_PERATE", MV_PAR06)
		Endif
		If MV_PAR07 != ""
			oSmartView:setParam("PAR_SEMATE", MV_PAR07)
		Endif
		If MV_PAR08 != ""
			oSmartView:setParam("PAR_FIL", MV_PAR08)
		Endif
		If MV_PAR09 != ""
			oSmartView:setParam("PAR_MATDE", MV_PAR09)
		Endif
		If MV_PAR10 != ""
			oSmartView:setParam("PAR_MATATE", MV_PAR10)
		Endif

    ElseIf cRelatorio == "PONR010"

        cDescRel 			:= STR0005
		cMatricula 			:= MV_PAR07
		cFilMat 			:= MV_PAR08
		lEmailUsuario		:= MV_PAR09 == "true"
		lEmailFuncionario	:= MV_PAR10 == "true"
		jPrintInfo['name'] 	+= "_"+cMatricula 

        oSmartView := totvs.framework.smartview.callSmartView():new("rh.sv.pon.ponr010.default.rep", "report")
        oSmartView:setNoInterface(.T.)
    	oSmartView:setPrintType(1)
        oSmartView:setPrintInfo(jPrintInfo)

		If MV_PAR02 != ""
			oSmartView:setParam("DateFrom", MV_PAR02)
		Endif
		If MV_PAR03 != ""
			oSmartView:setParam("DateTo", MV_PAR03)
		Endif
		If MV_PAR04 != ""
			oSmartView:setParam("BranchCodeFrom", MV_PAR04)
		Endif
		If MV_PAR05 != ""
			oSmartView:setParam("BranchCodeTo", MV_PAR05)
		Endif
		If MV_PAR06 != ""
			oSmartView:setParam("EmployeeCodeFrom", MV_PAR06)
		Endif
		If MV_PAR07 != ""
			oSmartView:setParam("EmployeeCodeTo", MV_PAR07)
		Endif

    ElseIf cRelatorio == "GPER130"

        cDescRel 			:= STR0011
		cMatricula 			:= MV_PAR04
		cFilMat 			:= MV_PAR08
		lEmailUsuario		:= MV_PAR09 == "true"
		lEmailFuncionario	:= MV_PAR10 == "true"
		jPrintInfo['name'] 	+= "_"+cMatricula 

        oSmartView := totvs.framework.smartview.callSmartView():new("rh.sv.gpe.gper130.aviso.rep", "report")
        oSmartView:setNoInterface(.T.)
    	oSmartView:setPrintType(1)
        oSmartView:setPrintInfo(jPrintInfo)

		If MV_PAR02 != ""
			oSmartView:setParam("FILDE", MV_PAR02)
		Endif
		If MV_PAR03 != ""
			oSmartView:setParam("FILATE", MV_PAR03)
		Endif
		If MV_PAR04 != ""
			oSmartView:setParam("MATDE", MV_PAR04)
		Endif
		If MV_PAR05 != ""
			oSmartView:setParam("MATATE", MV_PAR05)
		Endif
		If MV_PAR06 != ""
			oSmartView:setParam("CPERDE", MV_PAR06)
		Endif
		If MV_PAR07 != ""
			oSmartView:setParam("CPERATE", MV_PAR07)
		Endif

    ElseIf cRelatorio == "GPER420"

        cDescRel 			:= STR0015
		cMatricula 			:= MV_PAR04
		cFilMat 			:= MV_PAR06
		lEmailUsuario		:= MV_PAR07 == "true"
		lEmailFuncionario	:= MV_PAR08 == "true"
		jPrintInfo['name'] 	+= "_"+cMatricula 

        oSmartView := totvs.framework.smartview.callSmartView():new("rh.sv.gpe.gper420.default.rep", "report")
        oSmartView:setNoInterface(.T.)
    	oSmartView:setPrintType(1)
        oSmartView:setPrintInfo(jPrintInfo)

		If MV_PAR02 != ""
			oSmartView:setParam("PAR_FILIALDE", MV_PAR02)
		Endif
		If MV_PAR03 != ""
			oSmartView:setParam("PAR_FILIALATE", MV_PAR03)
		Endif
		If MV_PAR04 != ""
			oSmartView:setParam("PAR_MATDE", MV_PAR04)
		Endif
		If MV_PAR05 != ""
			oSmartView:setParam("PAR_MATATE", MV_PAR05)
		Endif

    ElseIf cRelatorio == "GPER430"

        cDescRel 			:= STR0006
		cMatricula 			:= MV_PAR06
		cFilMat 			:= MV_PAR07
		lEmailUsuario		:= MV_PAR08 == "true"
		lEmailFuncionario	:= MV_PAR09 == "true"
		jPrintInfo['name'] 	+= "_"+cMatricula 

        oSmartView := totvs.framework.smartview.callSmartView():new("rh.sv.gpe.gper430.default.rep", "report")
        oSmartView:setNoInterface(.T.)
    	oSmartView:setPrintType(1)
        oSmartView:setPrintInfo(jPrintInfo)

		If MV_PAR02 != ""
			oSmartView:setParam("ReferenceDate", MV_PAR02)
		Endif
		If MV_PAR03 != ""
			oSmartView:setParam("BranchCodeFrom", MV_PAR03)
		Endif
		If MV_PAR04 != ""
			oSmartView:setParam("BranchCodeTo", MV_PAR04)
		Endif
		If MV_PAR05 != ""
			oSmartView:setParam("EmployeeCodeFrom", MV_PAR05)
		Endif
		If MV_PAR06 != ""
			oSmartView:setParam("EmployeeCodeTo", MV_PAR06)
		Endif

    ElseIf cRelatorio == "GPER440"

        cDescRel 			:= STR0014
		cMatricula 			:= MV_PAR04
		cFilMat 			:= MV_PAR06
		lEmailUsuario		:= MV_PAR07 == "true"
		lEmailFuncionario	:= MV_PAR08 == "true"
		jPrintInfo['name'] 	+= "_"+cMatricula 

        oSmartView := totvs.framework.smartview.callSmartView():new("rh.sv.gpe.gper440.default.rep", "report")
        oSmartView:setNoInterface(.T.)
    	oSmartView:setPrintType(1)
        oSmartView:setPrintInfo(jPrintInfo)

		If MV_PAR02 != ""
			oSmartView:setParam("PAR_FILIALDE", MV_PAR02)
		Endif
		If MV_PAR03 != ""
			oSmartView:setParam("PAR_FILIALATE", MV_PAR03)
		Endif
		If MV_PAR04 != ""
			oSmartView:setParam("PAR_MATDE", MV_PAR04)
		Endif
		If MV_PAR05 != ""
			oSmartView:setParam("PAR_MATATE", MV_PAR05)
		Endif

    ElseIf cRelatorio == "GPER460"

        cDescRel 			:= STR0007
		cMatricula 			:= MV_PAR06
		cFilMat 			:= MV_PAR08
		lEmailUsuario		:= MV_PAR09 == "true"
		lEmailFuncionario	:= MV_PAR10 == "true"
		jPrintInfo['name'] 	+= "_"+cMatricula

        oSmartView := totvs.framework.smartview.callSmartView():new("rh.sv.gpe.gper460.default.rep", "report")
        oSmartView:setNoInterface(.T.)
    	oSmartView:setPrintType(1)
        oSmartView:setPrintInfo(jPrintInfo)

		If MV_PAR02 != ""
			oSmartView:setParam("PAR_DATAINI", MV_PAR02)
		Endif
		If MV_PAR03 != ""
			oSmartView:setParam("PAR_DATAFIM", MV_PAR03)
		Endif
		If MV_PAR04 != ""
			oSmartView:setParam("PAR_FILIALDE", MV_PAR04)
		Endif
		If MV_PAR05 != ""
			oSmartView:setParam("PAR_FILIALATE", MV_PAR05)
		Endif
		If MV_PAR06 != ""
			oSmartView:setParam("PAR_MATDE", MV_PAR06)
		Endif
		If MV_PAR07 != ""
			oSmartView:setParam("PAR_MATATE", MV_PAR07)
		Endif

	ElseIf cRelatorio == "GPEM580"

        cDescRel 			:= STR0012
        lEmailUsuario		:= MV_PAR13 == "true"
        lEmailFuncionario	:= MV_PAR14 == "true"
        cFilMat 			:= MV_PAR12
		cMatricula 			:= MV_PAR06
		jPrintInfo['name'] 	+= "_"+cMatricula  

        oSmartView := totvs.framework.smartview.callSmartView():new("rh.sv.gpe.gpem580.default.rep", "report")
        oSmartView:setNoInterface(.T.)
        oSmartView:setPrintType(1)
        oSmartView:setPrintInfo(jPrintInfo)

        If MV_PAR02 != ""
            oSmartView:setParam("FilialDe", MV_PAR02)
        Endif
        If MV_PAR03 != ""
            oSmartView:setParam("FilialAte", MV_PAR03)
        Endif
        If MV_PAR06 != ""
            oSmartView:setParam("MatriculaDe", MV_PAR06)
        Endif
        If MV_PAR07 != ""
            oSmartView:setParam("MatriculaAte", MV_PAR07)
        Endif
        If MV_PAR08 != ""
            oSmartView:setParam("AnoBase", MV_PAR08)
        Endif
        oSmartView:setParam("TipoImpressao", Iif(Empty(MV_PAR16), "1", MV_PAR16))
        oSmartView:setParam("TipoPessoa",    Iif(Empty(MV_PAR17), "1", MV_PAR17))

	ElseIf cRelatorio == "GPER270"

        cDescRel           := STR0013
        cMatricula         := MV_PAR05 
        cFilMat            := MV_PAR10 
        lEmailUsuario      := MV_PAR11 == "true"
        lEmailFuncionario  := MV_PAR12 == "true"
        jPrintInfo['name'] += "_"+cMatricula

        oSmartView := totvs.framework.smartview.callSmartView():new("rh.sv.gpe.gper270.default.rep", "report")
        oSmartView:setNoInterface(.T.)
        oSmartView:setPrintType(1)
        oSmartView:setPrintInfo(jPrintInfo)

        If MV_PAR02 != ""
            oSmartView:setParam("PAR_FILIAL", MV_PAR02)
        Endif
        If MV_PAR05 != ""
            oSmartView:setParam("PAR_MATDE", MV_PAR05)
        Endif
        If MV_PAR06 != ""
            oSmartView:setParam("PAR_MATATE", MV_PAR06)
        Endif
        If MV_PAR08 != ""
            oSmartView:setParam("PAR_ANOBASE", MV_PAR08)
        Endif
        If MV_PAR09 != ""
            oSmartView:setParam("PAR_ROTEIRO", MV_PAR09)
        Endif

	ElseIf cRelatorio == "GPER065"

        cDescRel           := "Outros Benefícios"
        cMatricula         := MV_PAR05
        cFilMat            := MV_PAR06
        lEmailUsuario      := MV_PAR07 == "true"
        lEmailFuncionario  := MV_PAR08 == "true"
        jPrintInfo['name'] += "_"+cMatricula

        oSmartView := totvs.framework.smartview.callSmartView():new("rh.sv.gpe.gper065.default.rep", "report")
        oSmartView:setNoInterface(.T.)
        oSmartView:setPrintType(1)
        oSmartView:setPrintInfo(jPrintInfo)

        If MV_PAR02 != ""
            oSmartView:setParam("filial", MV_PAR02)
        Endif
        If MV_PAR03 != ""
            oSmartView:setParam("processo", MV_PAR03)
        Endif
        If MV_PAR04 != ""
            oSmartView:setParam("periodo", MV_PAR04)
        Endif
        If MV_PAR05 != ""
            oSmartView:setParam("matricula", MV_PAR05)
        Endif
		
    Endif

    oSmartView:setForceParams(.T.)
    lSuccess := oSmartView:executeSmartView()

    RecLock("RU9", .T.)
    RU9->RU9_FILIAL     := xFilial("RU9")
	RU9->RU9_CODIGO     := FWuuId(FWTimeStamp(4)+StrTran(AllTrim(Str(Seconds())),".",""))
    RU9->RU9_USER       := __cUserID
    RU9->RU9_FILMAT     := cFilMat
    RU9->RU9_MAT       	:= cMatricula
    RU9->RU9_DATA       := Date()
    RU9->RU9_HORA       := Time()
    RU9->RU9_RELAT      := cRelatorio
    RU9->RU9_DESC       := cDescRel
    RU9->RU9_NOTIF      := "0"
    RU9->RU9_DOWNL      := "0"
    If lSuccess
        cFilePath := jPrintInfo['path']+jPrintInfo['name']+"."+jPrintInfo['extension']
        RU9->RU9_STATUS     := "0"
        RU9->RU9_ARQUIV    := cFilePath
    Else
        RU9->RU9_STATUS     := "1"
        RU9->RU9_ARQUIV     := ""
    Endif
    MsUnlock()
	ConfirmSx8()

	If lSuccess .AND. (lEmailUsuario .OR. lEmailFuncionario)

		nParamOrder := 1

		cQuery := " SELECT SRA.RA_NOME, SRA.RA_EMAIL "
		cQuery += " FROM "+RetSqlName("SRA")+" SRA "
		cQuery += " WHERE SRA.RA_FILIAL 	= ? "
		cQuery += "   AND SRA.RA_MAT 		= ? "
		cQuery += "   AND SRA.D_E_L_E_T_	= ? "
		cQuery := ChangeQuery(cQuery)

		// Instancia a classe
		oStatement := FwExecStatement():New(cQuery)

		oStatement:SetString(nParamOrder++, cFilMat)
		oStatement:SetString(nParamOrder++, cMatricula)
		oStatement:SetString(nParamOrder++, " ")

		// Executa a query e retorna o alias criado
		cAlias 	:= oStatement:OpenAlias()
		
		If !(cAlias)->(EOF())
			
			aFiles := {cFilePath}
			cMailAssunto := STR0008+" "+cDescRel+' - '+cMatricula+' - '+RTrim((cAlias)->RA_NOME)

			cMailHtml := "<html>"
			cMailHtml += "<p>"
			cMailHtml += STR0009+", "
			cMailHtml += "</p>"
			cMailHtml += "<p>"
			cMailHtml += STR0010+" "+cMailAssunto+"."
			cMailHtml += "</p>"
			cMailHtml += "</html>"
			
			If lEmailUsuario
				cMailUser := UsrRetMail(__cUserID)
				GPEMail(cMailAssunto, cMailHtml, cMailUser, aFiles)
			Endif

			If lEmailFuncionario
				cMailFunc := (cAlias)->RA_EMAIL
				If !Empty(cMailFunc)
					GPEMail(cMailAssunto, cMailHtml, cMailFunc, aFiles)
				Endif
			Endif

		End

		IncProc()

		(cAlias)->(dbCloseArea())
	Endif

Return


/*/{Protheus.doc} SchedDef
    Definições de agendamento do Schedule.
    @type Function
    @version 12.1.2410
    @author caio.kretzer
    @since 17/04/2025
    @return Array, Definições do agendamento
/*/
Static Function SchedDef() As Array
    // Declaração das variáveis locais
    Local aParam As Array

    // Inicialização das variáveis
    aParam := {}

    // Montagem da estrutura do vetor de retorno
    AAdd(aParam, "P")           // Tipo do agendamento: "P" = Processo | "R" = Relatório
    AAdd(aParam, "GPERSVSCH")   // Pergunte (SX1) (usar "PARAMDEF" caso não tenha conjunto de perguntas)
    AAdd(aParam, "")            // Alias principal (exclusivo para relatórios)
    AAdd(aParam, {})            // Vetor de ordenação (exclusivo para relatórios)
    AAdd(aParam, "")            // Título (exclusivo para relatórios)
Return aParam
