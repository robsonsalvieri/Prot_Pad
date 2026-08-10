#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "RHNP09.CH"

/*/{Protheus.doc} fGetQrons
Função para realizar o Get na integração com o Quirons.
@author:	Henrique Ferreira
@since:		30/09/2025
@param:		nType 		- Tipo do atestado ( pending, notpending).
			cCodFil 	- Filial que será utilizada na api
			cCodMat		- Matrícula que será utilizada na api.
			cEmpSRA		- Empresa que será utilizada na api
            cDataIni    - Data de inicio do atestado.
            aData       - Array com os dados retornados ( por referência )
@return:	.T.
/*/	
Function fGetQrons(nType, cCodFil, cCodMat, cEmpSRA, cDataIni, aData)

    //Booleans
    Local lOk        := .F.
    Local lNext      := .F.
    Local lRejected  := .F.
    Local lPending   := .F.
    Local lHistPts   := SUPERGETMV("MV_MRHHQRS", .F., .F.)

    //Strings
    Local cBegin    := ""
    Local cEnd      := ""
    Local cSource   := "/ttalk/v1/premedicalcertificate/employee/"
    Local cStatus   := IIf(nType == 1, "pending", "")

    //Objects
    Local oRet      := JsonObject():New()
    Local oQrons    := NIL
    Local oFile     := Nil

    //Numbers
    Local nX        := NIL
    Local nLen      := NIL

    DEFAULT cEmpSRA := cEmpAnt
    DEFAULT aData   := {}

    cSource	+= cEmpSRA + "|" + cCodFil + "|" + cCodMat
    cSource += "?"
    cSource += MrhConcatQP("companyId", cEmpSRA )
    cSource += MrhConcatQP("branchId" , cCodFil)
    cSource += MrhConcatQP("date", SubStr(formatGMT(cDataIni, .T.),1,10))
    cSource += MrhConcatQP("status", cStatus )
    cSource := StrTran(cSource, " ", "%20")
    cSource := StrTran(cSource, "|", "%7C")

    oRet := MrhQrons("get", cSource, NIL, @lOk)

    If lOK .And. oRet:hasProperty("items")
        lNext := oRet["hasNext"]
        nLen := Len(oRet["items"])
        For nX := 1 To nLen

            lRejected := ( oRet["items"][nX]["status"] == "rejected" )
            lPending  := ( oRet["items"][nX]["status"] == "pending" )
            cBegin    := oRet["items"][nX]["startDate"]
            cEnd      := oRet["items"][nX]["endDate"]

            If ( nType <> 1 .And. lPending )
                Loop
            EndIf

            oQrons := JsonObject():New()
            oFile := JsonObject():New()

            oQrons["id"]        := oRet["items"][nX]["id"]
            oQrons["status"]	:= oRet["items"][nX]["status"]
            oQrons["justify"]	:= oRet["items"][nX]["observation"]
            oQrons["begin"]	    := oRet["items"][nX]["startDate"]
            oQrons["end"]		:= oRet["items"][nX]["endDate"]
            oQrons["sent"]      := oRet["items"][nX]["startDate"]
            oQrons["canDelete"] := lPending

            If lRejected
                oQrons["canEdit"]	       := .T.
                oQrons["rejectionJustify"] := fMotQrons(oRet["items"][nX])
            Else
                oQrons["canEdit"]	:= .F.
            EndIf
            
            // Trata o anexo.
            oFile["content"]    := oRet["items"][nX]["attachment"]["file"]
            oFile["type"]       := oRet["items"][nX]["attachment"]["type"]
            oFile["name"]       := oRet["items"][nX]["attachment"]["name"]

            oQrons["file"]      := oFile
            aAdd(aData, { oQrons, cTod(Format8601(.T., cBegin, .F., .F. )) })

            FreeObj(oQrons)
            FreeObj(oFile)
        Next nX

        // Verifica atestados históricos no Protheus.
        If lHistPts .And. !(nType == 1)
            fGetAtest(cCodFil, cCodMat, nType, NIL, cDataIni, @aData)
        EndIf
    EndIf
    FreeObj(oRet)
Return .T.

/*/{Protheus.doc} fPostQrons
Função para realizar o Post na integração com o Quirons.
@author:	Henrique Ferreira
@since:		30/09/2025
@param:		cCodFil 	- Filial que será utilizada na api
			cCodMat		- Matrícula que será utilizada na api.
			cEmpSRA		- Empresa que será utilizada na api
            cBody       - Body da requisição.
@return:	cErro       - Retorna algum erro caso ocorra.
/*/
Function fPostQrons(cCodFil, cCodMat, cCodEmp, cBody)

    //Booleans
    Local lOk       := .F.

    //Strings
    Local cErro     := ""
    Local cSource   := "/ttalk/v1/premedicalcertificate"
    Local cId       := cCodFil + "|" + cCodMat + "|" + cCodEmp + "|" + DTOS(dDataBase) + "|" + cValToChar(Seconds()*1000)

    //Objects
    Local oRet      := JsonObject():New()
    Local oQrons    := NIL
    Local oBody     := NIL
    Local oFile     := NIL

    Default cCodEmp := cEmpAnt

    cSource += "?"
    cSource += "companyId="
    cSource += cCodEmp
    cSource += "&"
    cSource += "branchId="
    cSource += cCodFil
    cSource := StrTran(cSource, " ", "%20")
    cSource := StrTran(cSource, "|", "%7C")

    If !Empty(cBody)
        oBody  := JsonObject():New()
        oQrons := JsonObject():New()
        oFile  := JsonObject():New()
        
        oBody:FromJson(cBody)

        oFile["type"] := Iif(oBody:hasProperty("file"),oBody["file"]["type"]," ")
        oFile["type"] := IIf(oFile["type"] == "pdf", "application/pdf", "image/jpeg")
        oFile["file"] := Iif(oBody:hasProperty("file"),oBody["file"]["content"]," ")
        oFile["name"] := Iif(oBody:hasProperty("file"),oBody["file"]["name"]," ")
        oFile["length"] := Iif(oBody:hasProperty("file"),Len(oBody["file"]["content"]),0)

        oQrons["id"]          := RC4CRYPT(cId, "MeuRH#AtestadoMedico")
        oQrons["companyId"]   := cCodEmp
        oQrons["banchId"]     := cCodFil
        oQrons["employeeId"]  := cCodEmp + "|" + cCodFil + "|" + cCodMat
        oQrons["startDate"]   := Iif(oBody:hasProperty("begin"),oBody["begin"], CTOD("//"))
        oQrons["endDate"]     := Iif(oBody:hasProperty("end"),oBody["end"], CTOD("//"))
        oQrons["observation"] := Iif(oBody:hasProperty("justify"),Alltrim(FwCutOff(oBody["justify"]))," ")
        oQrons["attachment"]  := oFile

        oRet := MrhQrons("post", cSource, oQrons, @lOk)

        If !lOk
            cErro := IIf( oRet:hasProperty("detailedMessage"), oRet["detailedMessage"], EncodeUTF8(STR0065) ) // Erro não tratado retornado pelo Quirons.
        EndIf
    EndIf
Return cErro

/*/{Protheus.doc} fDelQrons
Função para realizar o Delete na integração com o Quirons.
@author:	Henrique Ferreira
@since:		30/09/2025
@param:		cCodFil 	- Filial que será utilizada na api
			cCodMat		- Matrícula que será utilizada na api.
			cId		    - Id da requisição, retornado na função fGetQrons.
            cErro       - Erro caso aconteça.
@return:	lOk         - Retorna .T. ou .F. caso ocorra erro na requisição.
/*/
Function fDelQrons(cCodFil, cCodEmp, cId, cErro)

    //Objetos
    Local oRet := NIL

    //Booleans
    Local lOk        := .F. 

    //Strings
    Local cSource   := "/ttalk/v1/premedicalcertificate/"

    DEFAULT cCodFil := ""
    DEFAULT cCodEmp := ""
    DEFAULT cId     := ""
    DEFAULT cErro   := ""

    If !Empty(cCodFil) .And. !Empty(cCodEmp) .And. !Empty(cId)

        cSource += cId
        cSource += "?"
        cSource += "companyId="
        cSource += cCodEmp
        cSource += "&"
        cSource += "branchId="
        cSource += cCodFil

        cSource := StrTran(cSource, " ", "%20")
        cSource := StrTran(cSource, "|", "%7C")

        oRet := MrhQrons("delete", cSource, NIL , @lOk)

        cErro := IIf( !lOk .And. oRet:hasProperty("detailedMessage"), EncodeUTF8(oRet["detailedMessage"]), "" )
    EndIf
Return lOK

/*/{Protheus.doc} fGetIdQrons
Busca um atestado no Quirons pelo ID.
@author:	Henrique Ferreira
@since:		30/09/2025
@param:		cId 	    - Id do atestado.
			cCodEmp		- Empresa que será utilizada na api.
			cCodFil		- Filial que será utilizada na api
            cCodMat     - Matricula que será utilizada na api
            cErro       - Erro caso aconteça.
@return:	oRet        - Retorna o objeto completo do atestado
/*/
Function fGetIdQrons(cId, cCodEmp, cCodFil, cCodMat, cErro)

    // Objects.
    Local oRet      := JsonObject():New()
    // Strings
    Local cSource   := "/ttalk/v1/premedicalcertificate/"
    // Booleans
    Local lOk       := .T.

    DEFAULT cCodFil := ""
    DEFAULT cCodEmp := ""
    DEFAULT cCodMat := ""
    DEFAULT cId     := ""
    DEFAULT cErro   := ""

    If !Empty(cCodFil) .And. !Empty(cCodEmp) .And. !Empty(cId)

        cSource += cId
        cSource += "?"
        cSource += "companyId="
        cSource += cCodEmp
        cSource += "&"
        cSource += "branchId="
        cSource += cCodFil

        cSource := StrTran(cSource, " ", "%20")
        cSource := StrTran(cSource, "|", "%7C")

        oRet := MrhQrons("get", cSource, NIL, @lOk)

        cErro := IIf( !lOk .And. oRet:hasProperty("detailedMessage"), EncodeUTF8(oRet["detailedMessage"]), "" )
    EndIf

Return oRet

/*/{Protheus.doc} fAnxQrons
Retorna o anexo da api do Quirons.
@author:	Henrique Ferreira
@since:		30/09/2025
@param:		nType 	    - Tipo da requisição.
			oAnex		- Objeto do anexo.
			cRet		- Arquivo físico.
            cType       - Extensão do arquivo.
            cNameArq    - Nome do arquivo.
@return:	.T.
/*/
Function fAnxQrons(nType, oAnex, cRet, cType, cNameArq)

    Local nPos := 0

    cRet        := Iif(nType == 1, oAnex["attachment"]["file"], Decode64(oAnex["attachment"]["file"]) )
    cNameArq    := oAnex["attachment"]["name"]

    If (nPos := At( "/", oAnex["attachment"]["type"]) ) > 0
        cType := SubStr( oAnex["attachment"]["type"], nPos+1, Len(oAnex["attachment"]["type"]) )
        cType := Iif( cType == "jpeg", "jpg", cType)
    EndIf

Return .T.

/*/{Protheus.doc} fMotQrons
Retorna o motivo de rejeição do atestado do Quirons.
@author:	Henrique Ferreira
@since:		30/09/2025
@param:		oQrons 	    - objeto do atestado.
@return:	cMotivo     - Motivo
/*/
Static Function fMotQrons(oQrons)

    Local cMotivo   := EncodeUTF8("Rejeitado pelo Quirons.")
    Local lContinua := .F.

    If ( lContinua := oQrons:hasProperty("rejectionDetails") .And. ;
                      !Empty(oQrons["rejectionDetails"]) )
        cMotivo := EncodeUTF8(oQrons["rejectionDetails"])
    EndIf

Return cMotivo

/*/{Protheus.doc} fGetAtest
Retorna o motivo de rejeição do atestado do Quirons.
@author:	Henrique Ferreira
@since:		30/09/2025
@param:		cBranchVld 	    - filial do funcionario.
            cMatSRA         - matricula do funcionario.
            nType           - tipo ( pending - notpending)
            cCodReq         - código da requisição.
            cDataIni        - data de inicio ou lançamento do atestado.
            aFields         - array com os campos - por referência.
@return:	.T.
/*/
Function fGetAtest(cBranchVld, cMatSRA, nType, cCodReq, cDataIni, aFields)
    Local cStatus       := ""
    Local cFilRH3       := ""
    Local cCodEmp       := ""
    Local cCodRH3       := ""
    Local cBegin		:= ""
	Local cEnd			:= ""
	Local cCid			:= ""
    Local cJustify		:= ""
    Local cMotivo		:= ""
    Local cDescMot      := ""
    Local cNomMed		:= ""
	Local cCRMMed		:= ""
	Local cIdeOC		:= ""
    Local cRejec		:= ""
	Local cNameArq		:= ""
	Local cFileType		:= ""
    Local cQryRH3       := GetNextAlias()
    Local cWhere        := "%"
    Local cCpoRH3       := If( RH3->(ColumnPos("RH3_BITMAP")) > 0, "%, RH3_BITMAP %", "%%" )
    Local cMsg			:= ""
	Local cRet			:= ""

    Local dDtAfaIni		:= CTOD("//")

    local oFields := NIL
    Local oFile   := NIL
    Local oType   := NIL
    Local oItem   := JsonObject():New()

    Local aCposRH4 := {}

    Local nX            := 0

    Local lIntNg   		:= SUPERGETMV('MV_RHNG', .F., .F.)
	Local lHistPts 		:= SUPERGETMV("MV_MRHHQRS", .F., .F.)

    DEFAULT cBranchVld := ""
    DEFAULT cMatSRA    := ""
    DEFAULT cCodReq    := ""
    DEFAULT aFields    := {}

    If !Empty(cBranchVld) .And. !Empty(cMatSRA)

        If nType == 1
			cWhere += " RH3.RH3_STATUS = '4' AND "
		ElseIf nType == 2
			cWhere += " RH3.RH3_STATUS NOT IN ('4') AND "
		ElseIf nType == 4
			cWhere += " RH3.RH3_CODIGO = '" + cCodReq + "' AND "
		EndIf
		cWhere += "%"

        BEGINSQL ALIAS cQryRH3
        SELECT RH3_FILIAL, RH3_CODIGO, RH3_MAT, RH3_STATUS, RH3_DTSOLI, RH3_DTATEN, RA_PROCES, RH3_EMP %Exp:cCpoRH3% 
        FROM %Table:RH3% RH3
            INNER JOIN %Table:SRA% SRA ON
                RH3_FILIAL = RA_FILIAL AND
                RH3_MAT = RA_MAT		
        WHERE
            RH3.RH3_TIPO='R' AND
            RH3.RH3_FILIAL=%Exp:cBranchVld% AND RH3.RH3_MAT=%Exp:cMatSRA% AND
            RH3.RH3_DTSOLI >= %Exp:cDataIni% AND
            %Exp:cWhere% 
            RH3.%NotDel% AND
            SRA.%NotDel%
		ENDSQL

        If !(cQryRH3)->(Eof())
			While !(cQryRH3)->(Eof())
                cFilRH3		:= (cQryRH3)->RH3_FILIAL
				cCodRH3 	:= (cQryRH3)->RH3_CODIGO
                cCodEmp     := (cQryRH3)->RH3_EMP
                cStatus		:= If( (cQryRH3)->RH3_STATUS=='2', "approved", If((cQryRH3)->RH3_STATUS=='3', 'rejected', 'pending') )
                aCposRH4 := fGetRH4Cpos(cFilRH3, cCodRH3)
                If Len(aCposRH4) > 0
                    For nX := 1 To Len(aCposRH4)
                        DO CASE
                        CASE aCposRH4[nX,1] == "R8_DATAINI"
                            cBegin		:= formatGMT(Alltrim(aCposRH4[nX,2]))
                        CASE aCposRH4[nX,1] == "R8_DATAFIM"
                            cEnd := Iif( Alltrim(aCposRH4[nX,2]) == "/  /", Nil, formatGMT(Alltrim(aCposRH4[nX,2])) )
                        CASE aCposRH4[nX,1] == "R8_CID"
                            cCid		:= Alltrim(aCposRH4[nX,2])
                        CASE aCposRH4[nX,1] == "R8_TIPOAFA"
                            cMotivo		:= Alltrim(aCposRH4[nX,2])
                        CASE aCposRH4[nX,1] == "TMP_MOTIVO"
                            cDescMot	:= Alltrim(aCposRH4[nX,2])
                        CASE aCposRH4[nX,1] == "TMP_OBS"
                            cJustify	:= If((cQryRH3)->RH3_STATUS == '3', '', Alltrim(aCposRH4[nX,2]))
                        CASE aCposRH4[nX,1] == "R8_NMMED"
                            cNomMed		:= Alltrim(aCposRH4[nX,2])
                        CASE aCposRH4[nX,1] == "R8_CRMMED"
                            cCRMMed		:= Alltrim(aCposRH4[nX,2])
                        CASE aCposRH4[nX,1] == "R8_IDEOC"
                            cIdeOC		:= Alltrim(aCposRH4[nX,2])
                        ENDCASE
                    Next nX
                    If nType == 4
                        //-------------------------
                        //Dados do anexo a partir do banco de conhecimento
                        cRet := fInfBcoFile( 1, cFilRH3, cCodRH3, cBranchVld, cMatSRA, @cNameArq, @cFileType, @cMsg )

                        //Dados do anexo a partir do repositorio de imagens (quando nao localiza no BC p/ nao afetar o historico)
                        If Empty(cRet)
                            cRet := fMedImg( 1, cFilRH3, cCodRH3, cBranchVld, cMatSRA, @cNameArq, @cFileType, @cMsg )
                        EndIf

                        oFile      						:= JsonObject():New()
                        oFile["content"] 				:= cRet
                        oFile["type"]    				:= cFileType
                        oFile["name"]    				:= cNameArq

                        oItem 							:= JsonObject():New()
                        oItem["id"]						:= RC4CRYPT( cFilRH3 +"|"+ cCodRH3 +"|"+ cCodEmp, "MeuRH#AtestadoMedico")
                        oItem["type"]					:= Iif( Empty(cIdeOC), "1", cIdeOC ) // Se não existir, carrega Médico no padrão.
                        oItem["begin"]					:= cBegin
                        oItem["end"]					:= cEnd
                        oItem["cid"]					:= cCid
                        oItem["justify"]				:= EncodeUTF8(cJustify)
                        oItem["reason"]					:= EncodeUTF8(cMotivo)
                        oItem["doctorName"]				:= EncodeUTF8(cNomMed)
                        oItem["medicalRegionalCouncil"]	:= EncodeUTF8(cCRMMed)
                        oItem["file"]					:= oFile

                        aAdd( aFields, oItem )

                        FreeObj(oFile)
                    Else
                        //Se a solicitacao já tiver sido atendida ela precisa ter afastamento, caso contrario será desconsiderada
                        If nType == 2 .And. (cQryRH3)->RH3_STATUS == "2" 
                            dDtAfaIni := STOD( StrTran(SubStr(cBegin, 1, 10), "-", "") )
                            If AfasDtValid(cBranchVld,cMatSRA,dDtAfaIni)
                                (cQryRH3)->(dbSkip())
                                Loop
                            EndIf					
                        EndIf
                        If !lIntNg .And. !lHistPts
                            oType				:= JsonObject():New()
                            oType["id"] 		:= Iif( Empty(cIdeOC), "1", cIdeOC ) // Se não existir, carrega Médico no padrão.
                            oType["name"] 		:= IIf( oType["id"] == "1", EncodeUTF8( STR0050 ), EncodeUTF8( STR0051 ) ) // Médico ou Odontológico.
                        EndIf

                        oFields 			:= JsonObject():New()
                        oFields["id"]		:= RC4CRYPT( cFilRH3 +"|"+ cCodRH3 +"|"+ cCodEmp, "MeuRH#AtestadoMedico")
                        oFields["status"]	:= cStatus
                        oFields["type"]		:= IIf( !lIntNg .And. !lHistPts, oType, NIL )
                        oFields["reason"]	:= Iif( !lIntNg .And. !lHistPts, EncodeUTF8( cDescMot ), NIL )
                        oFields["begin"]	:= cBegin
                        oFields["end"]		:= cEnd
                        oFields["sent"]		:= formatGMT( cValToChar( StoD((cQryRH3)->RH3_DTSOLI) ) )
                        oFields["cid"]		:= Iif( !lIntNg .And. !lHistPts, cCid, NIL )
                        If (cQryRH3)->RH3_STATUS == '3'
                            cRejec	:= getRGKJustify(cFilRH3, cCodRH3, Nil, .T.)
                            oFields["rejectionJustify"]	:= AllTrim(cRejec)
                        EndIf
                        oFields["canEdit"]	:= (cQryRH3)->RH3_STATUS $ '3/4'
                        oFields["canDelete"]:= (cQryRH3)->RH3_STATUS == '4'

                        Aadd(aFields,{ oFields, cTod(Format8601(.T., cBegin, .F., .F. )) })

                        FreeObj(oFields)
                        FreeObj(oType)
                    EndIf
				EndIf
                (cQryRH3)->(dbSkip())
            EndDo
        EndIf
        (cQryRH3)->( DBCloseArea() )
    Endif
Return .T.
