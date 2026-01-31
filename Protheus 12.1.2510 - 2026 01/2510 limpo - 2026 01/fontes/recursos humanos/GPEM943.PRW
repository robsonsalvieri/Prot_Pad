#INCLUDE "PROTHEUS.CH"
#INCLUDE "GPEM943.CH"

Static oInstace

/*/{Protheus.doc} GPEM943
Efetua a integração dos registros do Protheus com a Ahgora pelo Schedule
@author Bruno Costa
@since 23/09/2024
/*/
Function GPEM943(aParam)
Local lProcessa    := .T.
Local lMVOk        := .F.

Private aLogStatus := {}
Private lDelAfast  := .F.

If Len(aParam) > 0
    RpcSetType(3)
    RPCsetEnv(aParam[1], aParam[2])
EndIf	

If LockByName("GPEM943"+cEmpAnt+cFilAnt, .T., .T., .T.) 
   
    lMVOk := !Empty(SuperGetMv('MV_AHGORA1', Nil, "")) .And. !Empty(SuperGetMv('MV_AHGORA2', Nil, ""))

    If !AliasInDic("RUM") .Or. !lMVOk
        Conout( FwNoAccent(STR0001) ) //"Atenção"
        Conout( FwNoAccent(STR0002) ) //"A rotina de integração somente deve ser utilizada quando a integração com a Ahgora estiver ativa."
        Conout( FwNoAccent(STR0003) ) //"Além disso, é necessário que o ambiente esteja atualizado com a existência da tabela RUM."
        Conout( FwNoAccent(STR0004) ) //"Contate o administrador do sistema para efetuar o ajuste na parametrização no módulo Configurador e/ou atualização do ambiente."
        lProcessa := .F.
    EndIf

    If lProcessa
        Conout("=========================================================================")
        Conout( FwNoAccent(STR0024 + cEmpAnt + " " + STR0026 + cFilAnt) ) //"Integração Ahgora (GPEM943) - Empresa:" ### "Filial:"
        Conout("=========================================================================")

        Conout("=========================================================================")
        Conout( FwNoAccent(STR0005) ) //"Início da integração dos funcionários com Ahgora"
        Conout("=========================================================================")
        fProcFun()
        Conout("=========================================================================")
        Conout( FwNoAccent(STR0006) ) //"Término da integração dos funcionários com Ahgora"
        Conout("=========================================================================")

        Conout("=========================================================================")
        Conout( FwNoAccent(STR0007) ) //"Início da integração dos afastamentos com Ahgora"
        Conout("=========================================================================")
        fProcAfas()
        Conout("=========================================================================")
        Conout( FwNoAccent(STR0008) ) //"Término da integração dos afastamentos com Ahgora"
        Conout("=========================================================================")

        Conout("=========================================================================")
        Conout( FwNoAccent(STR0009) ) //"Início da integração das exclusões dos afastamentos com Ahgora"
        Conout("=========================================================================")
        fProcExc()
        lDelAfast := .F.
        Conout("=========================================================================")
        Conout( FwNoAccent(STR0010) )//"Término da integração das exclusões dos afastamentos com Ahgora"
        Conout("=========================================================================")

        Conout("=========================================================================")
        Conout( FwNoAccent(STR0025 + cEmpAnt + " " + STR0026 + cFilAnt) ) //"Término da integração Ahgora (GPEM943) - Empresa:" ### "Filial:"
        Conout("=========================================================================")
    EndIf
    UnLockByName("GPEM943"+cEmpAnt+cFilAnt, .T., .T., .T.)
EndIf

Return

/*/{Protheus.doc} fProcFun
Processa os funcionários para integração com Ahgora
@author Bruno Costa
@since 23/09/2024
/*/
Static Function fProcFun() 
Local aCodInter    := {} 
Local aInfo        := {}
Local aChefia      := {}
Local aLocalSRA    := {} 
Local aLocalBkp    := {} 
Local aLocais      := {}
Local cAliasRUM    := "INTFUNC"
Local cQuery       := ""
Local cEmailChefia := ""
Local cNomeChefia  := ""
Local cMatChefia   := ""
Local cLastDepto   := ""
Local cLastCFunc   := ""
Local cBatePonto   := ""
Local cLastFil     := ""
Local cDescFun     := ""
Local cCatFunc     := ""
Local cDescDe      := ""
Local cMatAnt      := ""
Local cRCEComp     := ""
Local cSR6Comp     := "" 
Local cCTTComp     := "" 
Local cNomeOf      := ""
Local lRet         := .F.
Local lNomeSoc     := .F.
Local oJsResponse  := JsonObject():new() 
Local dDHisSind 
Local dDtAltFun 
Local dDtTransf 
Local dDHisSR9 
Local dDtTurno 

DEFAULT oInstace   := Nil

DbSelectArea("SRA")
DbSetOrder(1) 

cQuery := "SELECT RUM.RUM_CODINT, RUM.RUM_OPER, RUM.RUM_DATMOV, RUM.RUM_CODINT, SRA.RA_FILIAL, SRA.RA_MAT, SRA.RA_NOME, SRA.RA_NOMECMP, SRA.RA_NSOCIAL, SRA.RA_CIC, SRA.RA_PIS, SRA.RA_CODUNIC, SRA.RA_ADMISSA, "
cQuery += "SRA.RA_DEMISSA, SRA.RA_TNOTRAB, SRA.RA_NUMCP, SRA.RA_TELEFON, SRA.RA_TPCONTR, SRA.RA_CATEFD, "
cQuery += "SRA.RA_DEPTO, SRA.RA_CODFUNC, SRA.RA_SEXO, SRA.RA_EMAIL, SRA.RA_RG, SRA.RA_CC, SRA.RA_CATFUNC, SRA.RA_NASC, SRA.RA_HRSMES, SRA.RA_SALARIO, SRA.RA_SINDICA "
cQuery += "FROM "+RetSqlName("RUM")+" RUM "
cQuery += "INNER JOIN "+RetSqlName("SRA")+" SRA ON " + FWJoinFilial( "RUM", "SRA" ) + " AND RUM.RUM_FIL = SRA.RA_FILIAL AND RUM.RUM_MAT = SRA.RA_MAT AND SRA.D_E_L_E_T_ = ' ' "
cQuery += "WHERE RUM.RUM_STATUS IN ('0', '3') AND RUM.RUM_TIPO = '1' AND RUM.RUM_FIL = '"+xFilial("SRA")+"' AND RUM.D_E_L_E_T_ = ' ' "
cQuery += "ORDER BY 1,2,3"
cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasRUM,.T.,.T.)

oJsResponse["items"] := {}

While (cAliasRUM)->( !EoF() )

    If oInstace == Nil
        oInstace := GPEAhGora():getInstance()
    EndIf

    If cLastFil != (cAliasRUM)->RA_FILIAL
        cLastFil := (cAliasRUM)->RA_FILIAL
        cRCEComp := Rtrim(xFilial("RCE", cLastFil)) 
        cSR6Comp := Rtrim(xFilial("SR6", cLastFil))  
        cCTTComp := Rtrim(xFilial("CTT", cLastFil))  
        fInfo(@aInfo, (cAliasRUM)->RA_FILIAL)
        aLocais   := oInstace:getLocalFun((cAliasRUM)->RA_FILIAL, @aLocalSRA)
		aLocalBkp := aClone(aLocais)
    EndIf

    If Len(aLocalSRA) > 0
        aLocais := aClone(aLocalBkp)
        fLocalSRA(aLocalSRA, (cAliasRUM)->RA_FILIAL, (cAliasRUM)->RA_MAT, @aLocais)
    EndIf

    cDescFun := Alltrim(fDesc('SRJ', (cAliasRUM)->RA_CODFUNC, 'RJ_DESC',, (cAliasRUM)->RA_FILIAL))

    If cLastCFunc != (cAliasRUM)->RA_CATFUNC+(cAliasRUM)->RA_CATEFD+(cAliasRUM)->RA_TPCONTR
        cLastCFunc := (cAliasRUM)->RA_CATFUNC+(cAliasRUM)->RA_CATEFD+(cAliasRUM)->RA_TPCONTR
        cCatFunc   := oInstace:getCatAhgora((cAliasRUM)->RA_CATFUNC, (cAliasRUM)->RA_CATEFD, (cAliasRUM)->RA_TPCONTR)
    EndIf

    If !Empty((cAliasRUM)->RA_DEPTO) .And. cLastDepto != (cAliasRUM)->RA_FILIAL + (cAliasRUM)->RA_DEPTO
        cLastDepto := (cAliasRUM)->RA_FILIAL + (cAliasRUM)->RA_DEPTO
        aChefia    := oInstace:fVldChefia((cAliasRUM)->RA_FILIAL, (cAliasRUM)->RA_MAT, (cAliasRUM)->RA_DEPTO)
        cDescDe    := Alltrim(fDesc('SQB', (cAliasRUM)->RA_DEPTO, 'QB_DESCRIC',, (cAliasRUM)->RA_FILIAL))
        If Len(aChefia) > 0
            cMatChefia   := aChefia[1][1]
            cNomeChefia  := RTrim(aChefia[1][2])
            cEmailChefia := RTrim(aChefia[1][3])
        EndIf
    EndIf	

    dDHisSR9   := dDHisSind := dDtAltFun := dDtTransf := dDtTurno := CtoD("//")
    cBatePonto := oInstace:getAhgoraSR9(Date(), @dDHisSR9, "AHGORA", "1")
    cMatAnt    := ""
    lNomeSoc   := !Empty((cAliasRUM)->RA_NSOCIAL)
    cNomeOf    := IIF(!Empty((cAliasRUM)->RA_NOMECMP), (cAliasRUM)->RA_NOMECMP, (cAliasRUM)->RA_NOME)

    If (cAliasRUM)->RUM_OPER == "A"
        oInstace:getAhgoraSR9(Date(), @dDHisSind, "RA_SINDICA", "2")
        oInstace:getAltFunc((cAliasRUM)->RUM_DATMOV, cEmpAnt+(cAliasRUM)->RA_FILIAL+(cAliasRUM)->RA_MAT, @dDtAltFun, @dDtTransf, @cMatAnt, @dDtTurno)
    EndIf	

    oItem := JsonObject():new()
    oItem["matricula"]			       		:= StrTran((cAliasRUM)->RUM_CODINT, " ", "")
    oItem["nome"]				       		:= RTrim(IIf(lNomeSoc, (cAliasRUM)->RA_NSOCIAL, cNomeOf))
    oItem["checkbox_nome_social"]           := lNomeSoc
    If lNomeSoc
        oItem["nome_registro"]				:= RTrim(cNomeOf)
    EndIf 
    oItem["pis"] 				       		:= RTrim((cAliasRUM)->RA_PIS)
    oItem["matricula_esocial"]         		:= (cAliasRUM)->RA_CODUNIC
    oItem["dataAdmissao"] 		       		:= oInstace:getDateAhgora((cAliasRUM)->RA_ADMISSA)
    oItem["dataDemissao"] 		       		:= oInstace:getDateAhgora((cAliasRUM)->RA_DEMISSA)
    If Len(aLocais) > 0
        oItem["localizacoes"]				:= aLocais
    Else
        oItem["localizacoes"]				:= ""
    EndIf
    oItem["escala_padrao"] 			   		:= cEmpAnt + cSR6Comp + (cAliasRUM)->RA_TNOTRAB
    oItem["lastChangeDefaultSchedule"] 		:= oInstace:getDateAhgora(DtoS(dDtTurno)) //Data alteração do turno
    oItem["ctps"] 					   		:= (cAliasRUM)->RA_NUMCP
    oItem["cargo"] 					   		:= Rtrim((cAliasRUM)->RA_CODFUNC) + " - " + cDescFun 
    oItem["departamento"] 			   		:= If(!Empty((cAliasRUM)->RA_DEPTO), Rtrim((cAliasRUM)->RA_DEPTO) + " - " + cDescDe, "") 
    oItem["sexo"] 					   		:= If((cAliasRUM)->RA_SEXO $ "M*F", (cAliasRUM)->RA_SEXO, "O")  		
    oItem["email"] 					   		:= (cAliasRUM)->RA_EMAIL 
    oItem["cpf"]					   		:= (cAliasRUM)->RA_CIC  
    oItem["rg"]						   		:= (cAliasRUM)->RA_RG
    oItem["cnpj"]					   		:= RTrim(aInfo[08]) 
    oItem["dataCnpj"]				   		:= If(!Empty(cMatAnt), oInstace:getDateAhgora(DtoS(dDtTransf)), "") //Data transferência
    oItem["centroCusto"]	 		   		:= cEmpAnt + cCTTComp + RTrim((cAliasRUM)->RA_CC)
    oItem["regimeTrabalho"]		       		:= cCatFunc
    oItem["dataNascimento"] 		   		:= oInstace:getDateAhgora((cAliasRUM)->RA_NASC)
    oItem["dataCargo"]						:= oInstace:getDateAhgora(DtoS(dDtAltFun)) //Data Alteração de função
    oItem["carga_horaria"]				    := (cAliasRUM)->RA_HRSMES
    oItem["bate_ponto"]	                    := cBatePonto
    oItem["data_troca_elegibilidade_ponto"]	:= oInstace:getDateAhgora(DtoS(dDHisSR9)) //Data Alteração se bate ponto
    oItem["matricula_chefia"]	            := cMatChefia
    oItem["nome_chefia"]					:= cNomeChefia
    oItem["email_chefia"]	                := cEmailChefia
    oItem["codSindicato"]	                := (cAliasRUM)->RA_SINDICA
    oItem["dataCodSindicato"]				:= oInstace:getDateAhgora(DtoS(dDHisSind)) //Data Alteração do sindicato
    oItem["telefone"]	                    := (cAliasRUM)->RA_TELEFON
    oItem["sem_pis"]						:= If(Empty((cAliasRUM)->RA_PIS), "true", "false") 
    oItem["codInterno"]		                := cEmpAnt+"|"+(cAliasRUM)->RA_FILIAL+"|"+(cAliasRUM)->RA_MAT
    oItem["matricula_anterior"]		        := cMatAnt
    oItem["salario"]						:= If((cAliasRUM)->RA_SALARIO > 0, AllTrim(Transform((cAliasRUM)->RA_SALARIO, "@E 999,999,999.99")), "")
    oItem["custo_da_hora"]                  := If((cAliasRUM)->RA_SALARIO > 0, If((cAliasRUM)->RA_CATFUNC $ "H*T*G", oItem["salario"], AllTrim(Transform((cAliasRUM)->RA_SALARIO / (cAliasRUM)->RA_HRSMES, "@E 999,999,999.99"))), "")

    aAdd(oJsResponse["items"], oItem)
    aAdd(aCodInter, {(cAliasRUM)->RA_FILIAL, (cAliasRUM)->RA_MAT, RTrim((cAliasRUM)->RUM_CODINT), Nil , Nil, "I", oItem["codInterno"]})

(cAliasRUM)->( dbSkip() )

EndDo

(cAliasRUM)->(dbCloseArea())
SRA->(dbCloseArea())

If Len(aCodInter) > 0
    lRet := oInstace:integracaoAhgora(oJsResponse, "1", "", "I", aCodInter)
    If lRet
        Conout( FwNoAccent(STR0011) ) //"Os Funcionários foram integrados com Ahgora..."
    EndIf
Else
    Conout( FwNoAccent(STR0012) ) //Não existem funcionários a serem integrados
EndIf

fgetStatus("1") //Consulta o status sempre, pois pode existir registro com status 4 que foi integrado pela tela 

Return 

/*/{Protheus.doc} fProcAfas
Processa os afastamentos para integração com Ahgora
@author Bruno Costa
@since 23/09/2024
/*/
Static Function fProcAfas() 
local oJsResponse := JsonObject():new() 
local aCodInter   := {} 
local cRCMComp    := ""
local cFilLast    := ""
Local cAliasRUM   := "INTAFAST"
local lRet        := .F.

DEFAULT oInstace  := Nil

cQuery := "SELECT SRA.RA_FILIAL, SRA.RA_MAT, SR8.R8_TIPOAFA, SR8.R8_DATAINI, SR8.R8_DATAFIM, SR8.R8_SEQ, RUM.RUM_CODINT "
cQuery += "FROM "+RetSqlName("SRA")+" SRA " 
cQuery += "INNER JOIN " + RetSqlName("SR8") + " SR8 ON " + FWJoinFilial( "SR8", "SRA" ) + " AND SRA.RA_MAT = SR8.R8_MAT AND SR8.D_E_L_E_T_ = ' ' "
cQuery += "INNER JOIN " + RetSqlName("RUM") + " RUM ON " + FWJoinFilial( "RUM", "SRA" ) + " AND SRA.RA_FILIAL = RUM.RUM_FIL AND SRA.RA_MAT = RUM.RUM_MAT AND RUM.RUM_TIPO ='2' AND RUM.RUM_OPER <> 'E' AND RUM.D_E_L_E_T_ = ' ' "
cQuery += "WHERE RUM.RUM_STATUS IN ('0', '3') AND RUM.RUM_FIL = '"+xFilial("SRA")+"' AND SRA.D_E_L_E_T_ = ' ' "
cQuery += "ORDER BY 1,2,3"

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasRUM,.T.,.T.)

oJsResponse["items"] := {}

While (cAliasRUM)->( !EoF() )

    If oInstace == Nil
        oInstace := GPEAhGora():getInstance()
    EndIf

    If cFilLast != (cAliasRUM)->RA_FILIAL
        cFilLast := (cAliasRUM)->RA_FILIAL
        cRCMComp := Rtrim(xFilial("RCM", cFilLast)) 
    EndIf

    oItem := JsonObject():new()
    oItem["matricula"]   := StrTran(cEmpAnt+(cAliasRUM)->RA_FILIAL+(cAliasRUM)->RA_MAT, " ", "")
    oItem["motivo"]      := cEmpAnt + cRCMComp + (cAliasRUM)->R8_TIPOAFA
    oItem["inicio"]   	 := oInstace:getDateAhgora((cAliasRUM)->R8_DATAINI)
    oItem["fim"]  		 := If(Empty((cAliasRUM)->R8_DATAFIM), "2099-12-31", oInstace:getDateAhgora((cAliasRUM)->R8_DATAFIM))
    oItem["cod_interno"] := cEmpAnt+"."+(cAliasRUM)->RA_FILIAL+"."+(cAliasRUM)->RA_MAT+"."+(cAliasRUM)->R8_SEQ 
    oItem["operation"]   := "INS"

    aAdd(oJsResponse["items"], oItem)
    aAdd(aCodInter, {(cAliasRUM)->RA_FILIAL, (cAliasRUM)->RA_MAT, RTrim((cAliasRUM)->RUM_CODINT), (cAliasRUM)->R8_SEQ, StoD((cAliasRUM)->R8_DATAINI), "I", oItem["cod_interno"]})    

    (cAliasRUM)->( dbSkip() )

EndDo

(cAliasRUM)->(dbCloseArea())

If Len(aCodInter) > 0
    lRet := oInstace:integracaoAhgora(oJsResponse, "2", "", "I", aCodInter)
    If lRet
        Conout( FwNoAccent(STR0013) ) //"Os Afstamentos foram integrados com Ahgora..."
    EndIf
Else
    Conout( FwNoAccent(STR0014) ) //"Não existem afastamentos a serem integrados"
EndIf

fgetStatus("2") //Consulta o status sempre, pois pode existir registro com status 4 que foi integrado pela tela 

Return 

/*/{Protheus.doc} fProcExc
Processa as exclusões dos afastamentos para integração com Ahgora
@author Bruno Costa
@since 23/09/2024
/*/
Static Function fProcExc() 
local oJsResponse := JsonObject():new() 
local aCodInter   := {} 
local aKeyFunc    := {}
local cRCMComp    := ""
local cFilLast    := ""
Local cAliasRUM   := "EXCAFAST"
local lRet        := .F.

DEFAULT oInstace  := Nil

cQuery := "SELECT RUM.RUM_FIL, RUM.RUM_MAT, RUM.RUM_KEY, RUM.RUM_DATAIN, RUM.RUM_CODINT "
cQuery += "FROM "+RetSqlName("RUM")+" RUM " 
cQuery += "WHERE RUM.RUM_STATUS IN ('0', '3') AND RUM.RUM_FIL = '"+xFilial("SRA")+"' AND RUM.RUM_TIPO ='2' AND RUM.RUM_OPER = 'E' AND RUM.D_E_L_E_T_ = ' ' "
cQuery += "ORDER BY 1,2,3"

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasRUM,.T.,.T.)

oJsResponse["items"] := {}

While (cAliasRUM)->( !EoF() )

    If oInstace == Nil
        oInstace := GPEAhGora():getInstance()
    EndIf

    If cFilLast != (cAliasRUM)->RUM_FIL
        cFilLast := (cAliasRUM)->RUM_FIL
        cRCMComp := Rtrim(xFilial("RCM", cFilLast)) 
    EndIf

    aKeyFunc := StrTokArr((cAliasRUM)->RUM_KEY, "|")
    oItem := JsonObject():new()
    oItem["matricula"]   := StrTran(cEmpAnt+(cAliasRUM)->RUM_FIL+(cAliasRUM)->RUM_MAT, " ", "")
    oItem["motivo"]      := cEmpAnt + Rtrim(xFilial("RCM", (cAliasRUM)->RUM_FIL)) + aKeyFunc[5]
    oItem["inicio"]   	 := oInstace:getDateAhgora(RTrim(aKeyFunc[6]))
    oItem["fim"]  		 := If(Len(aKeyFunc) > 6, oInstace:getDateAhgora(RTrim(aKeyFunc[7])), "2099-12-31")
    oItem["cod_interno"] := cEmpAnt+"."+(cAliasRUM)->RUM_FIL+"."+(cAliasRUM)->RUM_MAT+"."+aKeyFunc[4]
    oItem["operation"]   := "DEL" 

    aAdd(oJsResponse["items"], oItem)
    aAdd(aCodInter, {(cAliasRUM)->RUM_FIL, (cAliasRUM)->RUM_MAT, (cAliasRUM)->RUM_CODINT, aKeyFunc[4], StoD(aKeyFunc[6]), "E", oItem["cod_interno"]})

    (cAliasRUM)->( dbSkip() )

EndDo

(cAliasRUM)->(dbCloseArea())

If Len(aCodInter) > 0
    lDelAfast := .T.
    lRet := oInstace:integracaoAhgora(oJsResponse, "2", "", "I", aCodInter)
    If lRet
        Conout( FwNoAccent(STR0015) ) //"As exclusões dos Afstamentos foram integrados com Ahgora..."
    EndIf
Else
    Conout( FwNoAccent(STR0016) ) //Não existem exclusões a serem integrados
EndIf

fgetStatus("2", "E") //Consulta o status sempre, pois pode existir registro com status 4 que foi integrado pela tela 

Return 

/*/{Protheus.doc} fgetStatus
Consulta status dos registros na Ahgora
@author Bruno Costa
@since 23/09/2024
/*/
Static Function fgetStatus(cTipo, cOper)
Local cAliasRUM  := ""
Local cQuery     := ""
Local lRet       := .F.
Local nCont      := 0
Local nReq       := 0

DEFAULT oInstace := Nil
DEFAULT cOper    := ""

Static oStatementStatus

If oStatementStatus == Nil
    cQuery := "SELECT RUM.RUM_UNIQUE, RUM.RUM_SUBUNQ, MAX(RUM.RUM_DATINT) AS RUM_DATINT, MAX(RUM.RUM_HORINT) AS RUM_HORINT "
    cQuery += "FROM "+RetSqlName("RUM")+" RUM "
    cQuery += "WHERE RUM.RUM_STATUS = '4' AND RUM.RUM_TIPO = ? "+ If(!Empty(cOper), "AND RUM.RUM_OPER = 'E'", "") + " AND RUM.D_E_L_E_T_ = ' ' "
    cQuery += "GROUP BY RUM.RUM_UNIQUE, RUM.RUM_SUBUNQ, RUM.RUM_STATUS"
    
    cQuery := ChangeQuery(cQuery) 
    oStatementStatus := FwExecStatement():New(cQuery)
EndIf

oStatementStatus:SetString(1, cTipo)
cAliasRUM := oStatementStatus:OpenAlias()
dbSelectArea(cAliasRUM)

While !(cAliasRUM)->(Eof())
    If oInstace == Nil
        oInstace := GPEAhGora():getInstance()
    EndIf
    nReq++
    lRet := oInstace:atualizaStatus(cTipo, (cAliasRUM)->RUM_UNIQUE, (cAliasRUM)->RUM_SUBUNQ, (cAliasRUM)->RUM_DATINT+(cAliasRUM)->RUM_HORINT)
    (cAliasRUM)->(DbSkip())
EndDo

If lRet 
    If !Empty(aLogStatus)
        Conout("=========================================================================")
        Conout( FwNoAccent(STR0017) ) //"Início da consulta do status da integração com Ahgora"
        Conout("=========================================================================")

        For nCont := 1 to Len(aLogStatus) 
            Conout( FwNoAccent(STR0018 + aLogStatus[nCont][1] + "/" + aLogStatus[nCont][2] + If(cTipo == "2", " " + STR0019 + dToS(aLogStatus[nCont][4]), "") + " "+ STR0020 +;
             If(aLogStatus[nCont][3] == "6", If(cOper = "E", STR0021, STR0022), aLogStatus[nCont][5]))) // "Funcionário:" ### "Dt.Início Afastamento::" ### "Status:" ### "Exclusão integrada com sucesso" ### "Integrado com sucesso"
        Next nCont

        Conout("=========================================================================")
        Conout( FwNoAccent(STR0023) ) //"Término da consulta do status da integração com Ahgora""
        Conout("=========================================================================")
    EndIf
    aSize(aLogStatus, 0)
	aLogStatus := {}
    If nReq <= 3
        fgetStatus(cTipo, cOper) //Checa novamente para verificar se ainda existe registro aguardando retorno 
    EndIf    
EndIf

Return 

/*/{Protheus.doc} fLocalSRA
Monta a localização conforme conteúdo dos campos da SRA do funcionário
@author Bruno Costa
@since 02/04/2025
/*/
Static Function fLocalSRA(aLocSRA, cFilSRA, cMatSRA, aLocais)
Local aArea   := GetArea()
Local aCampos := {}
Local cLAux   := ""
Local nSRA    := 0
Local nCampos := 0
Local uVarAux

If SRA->(DbSeek(cFilSRA+cMatSRA)) 
    For nSRA := 1 To Len(aLocSRA)
        aCampos := StrTokArr(aLocSRA[nSRA][3], "|")
        For nCampos := 1 To Len(aCampos)
            uVarAux := SRA->&(aCampos[nCampos])
            IF ValType(uVarAux) == "C"
                cLAux += Rtrim(uVarAux)
            ElseIf ValType(uVarAux) == "D"
                cLAux += Rtrim(dToS(uVarAux))
            ElseIf ValType(uVarAux) == "N"
                cLAux += cValToChar(uVarAux)
            EndIf
        Next nCampos
        If !Empty(cLAux)		
            aAdd(aLocais, {cLAux})
            cLAux := ""
        EndIf
    Next nSRA
EndIf

RestArea(aArea)

Return 
