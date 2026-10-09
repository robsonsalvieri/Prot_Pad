#INCLUDE 'TOTVS.CH'
#INCLUDE 'FWMVCDEF.CH'

#DEFINE STR0001 "Veiculo encontra-se agendado no dia "
#DEFINE STR0002 " as "
#DEFINE STR0003 " , deseja continuar?"
#DEFINE STR0004 "Cliente bloqueado!"
#DEFINE STR0005 "Atenção!"
#DEFINE STR0006 "Tipo de tempo por tipo de atendimento invalido."
#DEFINE STR0007 "TT Seguradora - Peca"
#DEFINE STR0008 "TT Seguradora - Serv."
#DEFINE STR0009 "TT Seguradora"

#Define EVT_OS_ABERTA_SEM_ORCAMENTO     "32"

Class OFIA003EVDEF From  FWModelEvent
    Data cTTSegPeca
    Data cTTSegSrvc
	Method New() Constructor
	Method FieldPreVld()
	Method ModelPosVld()
    Method BeforeTTS()
	Method InTTS()
	Method AfterTTS()
EndClass

Method New() Class OFIA003EVDEF
Return self

Method FieldPreVld(oSubModel, cModelID, cAction, cId, xValue) CLASS OFIA003EVDEF
    Local lRet := .T.
    If cId == "VO1_CODCOR"
        Private M->VO1_CODCOR := xValue
    EndIf
Return lRet

Method ModelPosVld(oModel, cModelId) CLASS OFIA003EVDEF
    Local lRet := .T.
    Local oVO1 := oModel:GetModel("MODEL_VO1")
    Local cErro := ""
    Local lSeekSA1 := .F.
    
    If !IsBlind()
        VSO->(dbSelectArea("VSO"))
        VSO->(dbSetOrder(3))
        If VSO->(MsSeek(xFilial("VSO")+oVO1:GetValue("VO1_GETKEY")))
            While VSO->(!EOF());
                .AND. VSO->VSO_FILIAL == xFilial("VSO");
                .AND. VSO->VSO_GETKEY == oVO1:GetValue("VO1_GETKEY")
                if VSO->VSO_DATAGE > dDataBase
                    if !MsgYesNo( STR0001 + dtoc(VSO->VSO_DATAGE) + STR0002 + transform(val(VSO->VSO_HORAGE),"@E 99:99")+ STR0003 ) // Veiculo encontra-se agendado no dia
                        lRet := .F.
                    Endif
                    Exit
                Endif
                VSO->(dbSkip())
            EndDo
        EndIf
    EndIf

 
    // Verifica se o cliente esta bloqueado
    SA1->(DbSelectArea("SA1"))
    SA1->(DbSetOrder(1))
    If !Empty(oVO1:GetValue("VO1_FATPAR"))
        lSeekSA1 := SA1->(MsSeek(xFilial("SA1")+oVO1:GetValue("VO1_FATPAR")+oVO1:GetValue("VO1_LOJA")))
    Else
        lSeekSA1 := SA1->(MsSeek(xFilial("SA1")+oVO1:GetValue("VO1_PROVEI")+oVO1:GetValue("VO1_LOJPRO")))
    EndIf

    If lSeekSA1  .AND. SA1->A1_MSBLQL == "1"
        cErro += STR0004+CHR(13)+CHR(10)+CHR(13)+CHR(10)+Alltrim(RetTitle(IIf(!Empty(oVO1:GetValue("VO1_FATPAR")),"VO1_FATPAR","VO1_PROVEI")))+": "+SA1->A1_COD+"-"+SA1->A1_LOJA+" "+SA1->A1_NOME + CRLF  // Cliente bloqueado! / Atenção!
        lRet := .F.
    EndIf

    // Validação Tipo de Atendimento por Tipo de Tempo (Peça e Serviços)
    If !ValidateTimeType(oVO1:GetValue("VO1_TPATEN"), oVO1:GetValue("VO1_NUMOSV"))
        cErro += STR0006 //"Tipo de tempo por tipo de atendimento invalido."
	    lRet := .F.
    EndIf


Return lRet

Method BeforeTTS(oModel, cModelId) CLASS OFIA003EVDEF
    Local oVO1 := oModel:GetModel("MODEL_VO1")
    Local aParamBox := {}
    Local aRet := {}
    Local nOpc := oModel:getOperation()

    If nOpc == MODEL_OPERATION_INSERT
        oVO1:LoadValue("VO1_NUMOSV",NumOS())
	    ConfirmSx8()
    EndIf
    
    if !IsBlind();
        .AND. VO1->(FieldPos("VO1_FRANQP")) > 0 ;
        .AND. (oVO1:GetValue("VO1_FRANQU") > 0 .OR. oVO1:GetValue("VO1_FRANQP") > 0 )
        
        Self:cTTSegPeca :=  Space(TamSX3("VOI_TIPTEM")[1])
        Self:cTTSegSrvc := Space(TamSX3("VOI_TIPTEM")[1])

        aAdd(aParamBox,{1,STR0007 ,Self:cTTSegPeca,"@!","!Empty(MV_Par01)","VOI","",0,.t.}) // "TT Seguradora - Peca"
        aAdd(aParamBox,{1,STR0008 ,Self:cTTSegSrvc,"@!","!Empty(MV_PAR02)","VOI","",0,.t.}) // "TT Seguradora - Serv."
        While .t.
            If ParamBox(aParamBox,STR0009,@aRet,,,,,,,,.T.)//"TT de Seguradora"
                SSelf:cTTSegPeca := aRet[1]
                Self:cTTSegSrvc := aRet[2]
                exit
            Endif
        Enddo

    endif
Return 

Method InTTS(oModel, cModelId) CLASS OFIA003EVDEF
    Local oVO1 := oModel:GetModel("MODEL_VO1")
    Local nOpc := oModel:getOperation()
    local lDiarioOficina := FindFunction("OA5480062_RegistraEventoDiarioOficina")
    local cNumOsv := ''

    Private cMVMIL0006 := GetNewPar("MV_MIL0006","")
    Private lGarMut := (VO1->(FieldPos("VO1_GARMUT")) <> 0 )
    Private nValGarMut := 0
    Private aRetWS := {}

    VA8->(dbSelectArea("VA8"))
    VA8->(dbSetOrder(1))
    if VA8->(msSeek(xFilial("VA8")+space(Len(oVO1:GetValue("VO1_NUMOSV")))+oVO1:GetValue("VO1_PLAVEI")))
        Reclock("VA8",.f.)
            VA8->VA8_NUMOSV := oVO1:GetValue("VO1_NUMOSV")
        VA8->(MsUnlock())
    Endif

    VSR->(dbSelectArea("VSR"))
    VSR->(dbSetOrder(2))
    If VSR->(FieldPos("VSR_PLAVEI")) > 0
        if VSR->(msSeek(xFilial("VSR")+space(Len(oVO1:GetValue("VO1_NUMOSV")))+oVO1:GetValue("VO1_PLAVEI")))
            Reclock("VSR",.f.)
                VSR->VSR_NUMOSV := oVO1:GetValue("VO1_NUMOSV")
            VSR->(MsUnlock())
        Endif
    Endif
        
    //MSMM(VO1->VO1_OBSMEM,TamSx3("VO1_OBSERV")[1],,&(aMemos[1][2]),1,,,"VO1","VO1_OBSMEM")

    //Ajusta Status do Box para analise.
    FG_MARCABOX(oVO1:GetValue("VO1_NUMBOX"),oVO1:GetValue("VO1_CODCOR"),oVO1:GetValue("VO1_PRISMA"),oVO1:GetValue("VO1_NUMOSV"))

    // tratamento de controle de status de veiculos soh se estiver abrindo OS para um veiculo que esta no estoque
    //todo: gerando varios erros difernetes verificar depois
    // VV1->(dbSelectArea("VV1"))
    // VV1->(DbsetOrder(1))
    
    // If VV1->(msSeek(xFilial("VV1")+oVO1:GetValue("VO1_CHAINT"))); 
    //         .AND. FG_STATUS(,"X") .AND. VV1->VV1_SITVEI $ "0 "
    //     FG_STATUS(oVO1:GetValue("VO1_CHAINT"),"O")
    // Endif

   // So deve requisitar se tiver rodado o UPDATE de OS de Seguradora
    if VO1->(FieldPos("VO1_FRANQP")) > 0 
        // Gera Requisicao de Franquia    P E C A S     
        If oVO1:GetValue("VO1_FRANQP") > 0
            REQFRA020(oVO1:GetValue("VO1_NUMOSV"),Self:cTTSegPeca)
        EndIf
       //Gera Requisicao de Franquia    S E R V I C O
        If oVO1:GetValue("VO1_FRANQU") > 0
            REQFRA030(oVO1:GetValue("VO1_NUMOSV"),Self:cTTSegSrvc)
        EndIf
    endif


    // Importa Garantia ...
    ImportWarranty(oVO1:GetValue("VO1_CODMAR"))
    
    // Se for GARANTIA MUTUA e informado o valor estimado, gera a solicitacao de garantia mutua
    If lGarMut .AND. oVO1:GetValue("VO1_GARMUT") == "1" .AND. nValGarMut <> 0
        OA550INC(oVO1:GetValue("VO1_NUMOSV"), "", nValGarMut)
    EndIf
    //

    If cMVMIL0006 == "SCA" .AND. FindFunction("OFINSC01")
        OFSC01(.f.,.t.,oVO1:GetValue("VO1_NUMOSV"),Space(TamSX3("VOI_TIPTEM")[1]),Space(TamSX3("VOO_LIBVOO")[1]))//lEnd, lAuto, cTipTem, cLibVOO
    EndIf

    // Atualiza tabela VFB
    If nOpc == MODEL_OPERATION_UPDATE
        //ajustado por Fernando Radu Muscalu em 08/03/2024 - CI 2136-013001
        OM010ALTVFB(oVO1:GetValue("VO1_PROVEI"),oVO1:GetValue("VO1_LOJPRO"),oVO1:GetValue("VO1_CHAINT"),cNumOsv,oVO1:GetValue("VO1_KILOME"))
    Endif

    if FWAliasInDic("VO0")
        OM010VO0()
    EndIf

    //Após demais gravações, se for o caso, vincula o agendamento com a OS
    if nOpc == MODEL_OPERATION_INSERT .or. nOpc == MODEL_OPERATION_UPDATE
        cNumOsv := oVO1:GetValue("VO1_NUMOSV")
    	if lDiarioOficina .and. !empty(cNumOsv)
    		OA5480062_RegistraEventoDiarioOficina(cNumOsv, '009') // 009 – ABERTURA DA ORDEM DE SERVICO
    	endif
    endif

Return Nil

Method AfterTTS(oModel, cModelId) CLASS OFIA003EVDEF

Local oControlTower := Nil 
Local nOpc := oModel:getOperation()

	// Disparo Control Tower (Nova Rotina)
	//Evento: OS Aberta / Sem Orçamento (32)
	If nOpc == MODEL_OPERATION_INSERT 
		If FindClass("OFSEventoControlTower") .and. GetNewPar("MV_MIL0006","") == "SCA" .And. !Empty(VO1->VO1_NUMOSV) 
			oControlTower := OFSEventoControlTower():New()
			oControlTower:ExecutarEvento(EVT_OS_ABERTA_SEM_ORCAMENTO, VO1->VO1_CHASSI, VO1->VO1_NUMOSV, "", "")
			FreeObj(oControlTower)
		EndIf 
	EndIf 

Return Nil


Static Function ValidateTimeType(cTipAte,cNumOSv)
    Local lRet := .T.
    Local cAlias := GetNextAlias()
    Local cTipTem := ""

    If VOI->(FieldPos("VOI_CONVCP")) > 0
        // Peças e Serviços
        BeginSql Alias cAlias
            SELECT 
                VO3.VO3_TIPTEM TIPTEM
            FROM 
                %Table:VO3% VO3 
            JOIN 
                %Table:VOI% VOI 
            ON 
                VOI.%notDel%
                AND VOI.VOI_FILIAL = %xFilial:VOI% 
                AND VOI.VOI_TIPTEM = VO3.VO3_TIPTEM 
                AND VOI.VOI_CONVCP = '1'  
            WHERE 
                VO3.%notDel%
                AND VO3.VO3_FILIAL = %xFiliaL:VO3% 
                AND VO3.VO3_DATCAN = ' ' 
                AND VO3.VO3_NUMOSV = %Exp:cNumOSv%
            UNION 
            SELECT 
                VO4.VO4_TIPTEM TIPTEM
            FROM 
                %Table:VO4% VO4 
            JOIN 
                %Table:VOI% VOI 
            ON 
                VOI.%notDel%
                AND VOI.VOI_FILIAL = %xFilial:VOI% 
                AND VOI.VOI_TIPTEM = VO4.VO4_TIPTEM 
                AND VOI.VOI_CONVCP = '1'
            WHERE 
                VO4.%NotDel%
                AND VO4.VO4_FILIAL = %xFilial:VO4% 
                AND VO4.VO4_DATCAN = ' ' 
                AND VO4.VO4_NUMOSV = %Exp:cNumOSv%
        EndSql
        
        While (cAlias)->(!EOF())
            cTipTem += IIF(Empty(cTipTem),"",",") + "'" + (cAlias)->TIPTEM + "'"

            (cAlias)->(dbSkip())
        EndDo
        (cAlias)->(dbCloseArea())

        lRet := Empty(cTipTem)

        If !lRet
            cTipTem := "%" + cTipTem + "%"
            cAlias := GetNextAlias()
            BeginSql Alias cAlias
                SELECT 
                    COUNT(VCP.R_E_C_N_O_) COUNTVCP
                FROM 
                    %Table:VCP%  VCP
                WHERE 
                    VCP.%notDel%
                    AND VCP.VCP_FILIAL = %xFilial:VCP%
                    AND VCP.VCP_TPATEN = %Exp:cTipAte%
                    AND VCP.VCP_TIPTEM IN (%Exp:cTipTem%)
            EndSql

            lRet := (cAlias)->COUNTVCP == 0

            (cAlias)->(dbCloseArea())
        EndIf
    EndIf

   

Return lRet

Static Function NumOS()
	Local cRet := GetSXENum("VO1","VO1_NUMOSV")

	While ExistNumOs(cRet)
		ConfirmSx8()
		cRet := GetSXENum("VO1","VO1_NUMOSV")
	EndDo
Return cRet

Static Function ExistNumOs(cNum)
	Local cAlias := GetNextAlias()
	Local lRet := .F.
	BeginSql Alias cAlias
		SELECT
			VO1_NUMOSV
		FROM
			%Table:VO1% VO1
		WHERE
			VO1.%notDel%
			AND VO1_FILIAL = %xFiliaL:VO1%
			AND VO1_NUMOSV = %Exp:cNum%
	EndSql

	If (cAlias)->(!EOF())
		lRet := .T.
	EndIf
	(cAlias)->(dbCloseArea())
Return lRet


Static Function ImportWarranty(cCodMar)

    Local cFunExp := ""
    Local nIx1 := 0
    Local nAuxRecno := GetVE4RECNO(cCodMar)

    If nAuxRecno == 0
        Return .t.
    EndIf
    
    VE4->(dbSelectArea("VE4"))
    VE4->(dbSetOrder(1))

    VE4->(dbGoTo(nAuxRecno))

    If FG_SEEK("VEG","VE4->VE4_FOREXP",1,.f.)
        
        cFunExp := Alltrim(VEG->VEG_FORMUL)
        
        nIx1 := At("(",cFunExp)
        If nIx1 <> 0
            cFunExp := Left(cFunExp,nIx1) + "'A','','','',aRetWS)"
        EndIf

        // Funcao de Importacao para Garantia
        lMsHelpAuto := .f.
        If !FG_VERFORGAR(cFunExp)
            lMsHelpAuto := .t.
            Return .f.
        EndIf
        //
    EndIf

Return .t.

Static Function GetVE4RECNO(cPesqCodMar)

	Local cAlias := GetNextAlias()
	Local nRet := 0

	If cMVMIL0006 == "JD"
        BeginSql Alias cAlias
            SELECT 
                VE4.R_E_C_N_O_ RECNO
			FROM
                ( 
					SELECT 
                        VE1_1.VE1_CODMAR, '0' ORDEM 
					FROM 
                        %Table:VE1%  VE1_1  
					WHERE 
                        VE1_1.%notDel%
                        AND VE1_1.VE1_FILIAL = %xFilial:VE1% 
					    AND VE1_1.VE1_CODMAR = %Exp:cPesqCodMar% 
					    AND VE1_1.VE1_MARFAB IN ('JD ','GRS','PLA','JDC','HCM')
					  
					UNION  
					SELECT 
                        VE1_2.VE1_CODMAR, '1' ORDEM
					FROM 
                        %Table:VE1% VE1_2
					WHERE 
                        VE1_2.%notDel%
                        AND VE1_2.VE1_FILIAL = %xFilial:VE1%
					    AND VE1_2.VE1_MARFAB IN ('JD ','GRS','PLA','JDC','HCM')
				) TMPFILTRO 
            JOIN 
                %Table:VE4% VE4 
            ON 
                VE4.%notDel%
                AND VE4.VE4_FILIAL = %xFilial:VE4%  
                AND VE4.VE4_PREFAB = TMPFILTRO.VE1_CODMAR
                AND VE4.VE4_QDOIMP = '3'
                AND VE4.VE4_FOREXP <> ' '
                
			ORDER BY 
                TMPFILTRO.ORDEM , RECNO

        EndSql
			
	Else
		BeginSql Alias cAlias
			SELECT 
                R_E_C_N_O_ RECNO
			FROM 
                %Table:VE4% VE4
			WHERE 
                VE4.%notDel%
                AND VE4.VE4_FILIAL = %xFilial:VE4%
			    AND VE4.VE4_PREFAB = %Exp:cPesqCodMar%
			    AND VE4.VE4_QDOIMP = '3'
        EndSql
	EndIf

    If (cAlias)->(!EOF())
        nRet := (cAlias)->RECNO
    EndIf

    (cAlias)->(dbCloseArea())
	
Return nRet

