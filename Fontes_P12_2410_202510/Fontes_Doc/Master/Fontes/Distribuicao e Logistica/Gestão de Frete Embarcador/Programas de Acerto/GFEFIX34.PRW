#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"

//===============================================================================================\\
/*/{Protheus.doc} GFEFIX34
  ================================================================================================
	@description   	Gravação do campo GWM_DTEMDC para os rateios de documento de frete e alimentado o campo de origem e destino
	@author         João Leonardo Schmidt
	@version    	1.0
	@since          04/08/2022
/*/
//================================================================================================\\
Function GFEFIX34()
    Local oDlg      := Nil
	Local oCancel   := Nil
	Local oConfirm  := Nil
	Local dDtEmiIni := Ctod(Space(8))
	Local dDtEmiFim := Ctod(Space(8))
	
	DEFINE MSDIALOG oDlg FROM 0, 0 TO 150, 500 TITLE 'Correção da gravação do rateio do documento de frete' PIXEL
	
	@ 10, 20  SAY 'Data Emissão Documento de Carga Inicial:' OF oDlg PIXEL		
	@ 08, 140  MSGET dDtEmiIni When .T. Picture "@!" PIXEL OF oDlg PICTURE '@!' PIXEL
	@ 30, 20  SAY 'Data Emissão Documento de Carga Final:' OF oDlg PIXEL
	@ 30, 140  MSGET dDtEmiFim When .T. Picture "@!" PIXEL OF oDlg PICTURE '@!' PIXEL
	
	@ 60, 20 BUTTON oConfirm PROMPT "Processar" SIZE 040,012 OF oDlg PIXEL ACTION (Processa(dDtEmiIni,dDtEmiFim),oDlg:End())
	@ 60, 65 BUTTON oCancel  PROMPT "Cancelar"  SIZE 040,012 OF oDlg PIXEL ACTION oDlg:End()

	ACTIVATE MSDIALOG oDlg CENTERED
Return

Static Function Processa(dDtEmiIni, dDtEmiFim)
    Local cAliasGWM  := GetNextAlias()
    Local cAliasGW3  := GetNextAlias()
    Local cAliasGWH  := GetNextAlias()
    Local cMV_VLCNPJ := SuperGetMV('MV_VLCNPJ',,'1')
    Local cWhere     := ""

    Private oProcessC   := Nil
    Private lSaveLogC   := .F.

    BeginSQL Alias cAliasGWM
        SELECT GWM.R_E_C_N_O_ RECNOGWM,
               GW1.GW1_DTEMIS DTEMIS
        FROM %Table:GW1% GW1
        INNER JOIN %Table:GWM% GWM
        ON GWM.GWM_FILIAL = GW1.GW1_FILIAL
        AND GWM.GWM_CDTPDC = GW1.GW1_CDTPDC
        AND GWM.GWM_EMISDC = GW1.GW1_EMISDC
        AND GWM.GWM_SERDC = GW1.GW1_SERDC
        AND GWM.GWM_NRDC = GW1.GW1_NRDC    
        AND GWM.GWM_TPDOC = '2'
        AND GWM.GWM_DTEMDC = ''
        AND GWM.%NotDel%
        WHERE GW1.GW1_DTEMIS >= %Exp:dDtEmiIni%
        AND GW1.GW1_DTEMIS <= %Exp:dDtEmiFim%
        AND GW1.%NotDel%
    EndSQL

    While ((cAliasGWM)->(!Eof()))
        GWM->(dbGoTo((cAliasGWM)->RECNOGWM))

        RecLock("GWM", .F.)
            GWM->GWM_DTEMDC := SToD((cAliasGWM)->DTEMIS)            
        MsUnlock()

        (cAliasGWM)->(dbSkip())
    EndDo

    If cMV_VLCNPJ == "2"
        cWhere := "SUBSTRING(GU3TR.GU3_IDFED,1,8) = SUBSTRING(GU3DF.GU3_IDFED,1,8)"
    Else
        cWhere := "GU3TR.GU3_CDEMIT = GU3DF.GU3_CDEMIT"
    EndIf

    cWhere := "%" + cWhere + "%"

    (cAliasGWM)->(dbCloseArea())

    BeginSQL Alias cAliasGW3
        SELECT GW3.R_E_C_N_O_ RECNOGW3,
               GWU.GWU_NRCIDO NRCIDO,
               GWU.GWU_NRCIDD NRCIDD
        FROM %Table:GW1% GW1
        INNER JOIN %Table:GW4% GW4
        ON GW4.GW4_FILIAL = GW1.GW1_FILIAL
        AND GW4.GW4_EMISDC = GW1.GW1_EMISDC
        AND GW4.GW4_SERDC = GW1.GW1_SERDC
        AND GW4.GW4_NRDC = GW1.GW1_NRDC
        AND GW4.GW4_TPDC = GW1.GW1_CDTPDC
        AND GW4.%NotDel%
        INNER JOIN %Table:GW3% GW3
        ON GW3.GW3_FILIAL = GW4.GW4_FILIAL
        AND GW3.GW3_CDESP = GW4.GW4_CDESP
        AND GW3.GW3_EMISDF = GW4.GW4_EMISDF
        AND GW3.GW3_SERDF = GW4.GW4_SERDF
        AND GW3.GW3_NRDF = GW4.GW4_NRDF
        AND GW3.GW3_DTEMIS = GW4.GW4_DTEMIS
        AND GW3.%NotDel%
        INNER JOIN %Table:GWU% GWU
        ON GWU.GWU_FILIAL = GW1.GW1_FILIAL
        AND GWU.GWU_CDTPDC = GW1.GW1_CDTPDC
        AND GWU.GWU_EMISDC = GW1.GW1_EMISDC
        AND GWU.GWU_SERDC = GW1.GW1_SERDC
        AND GWU.GWU_NRDC = GW1.GW1_NRDC
        INNER JOIN %Table:GU3% GU3TR
        ON GU3TR.GU3_FILIAL = %xFilial:GU3%
        AND GU3TR.GU3_CDEMIT = GWU.GWU_CDTRP
        INNER JOIN %Table:GU3% GU3DF
        ON GU3DF.GU3_FILIAL = %xFilial:GU3%
        AND GU3DF.GU3_CDEMIT = GW3.GW3_EMISDF
        WHERE GW1.GW1_DTEMIS >= %Exp:dDtEmiIni%
        AND GW1.GW1_DTEMIS <= %Exp:dDtEmiFim%
        AND %Exp:cWhere%
        AND GW1.%NotDel%
    EndSQL

    While ((cAliasGW3)->(!Eof()))
        GW3->(dbGoTo((cAliasGW3)->RECNOGW3))

        If Empty(GW3->GW3_MUNINI) .And. Empty(GW3->GW3_MUNFIM)
            If GW3->GW3_TPDF == "5"
                // Para os documentos de frete que são de devolução, as informações são gravadas invertidas do registrado no documento de carga
                RecLock("GW3", .F.)
                    GW3->GW3_MUNINI := Alltrim((cAliasGW3)->NRCIDD) 											// Município Início Transporte
                    GW3->GW3_UFINI  := Posicione("GU7", 1, xFilial("GU7") + (cAliasGW3)->NRCIDD, "GU7_CDUF") 	// UF Início do Transporte
                    GW3->GW3_MUNFIM := Alltrim((cAliasGW3)->NRCIDO) 											// Município Término do Transporte
                    GW3->GW3_UFFIM  := Posicione("GU7", 1, xFilial("GU7") + (cAliasGW3)->NRCIDO, "GU7_CDUF") 	// UF Término do Transporte
                GW3->(MsUnlock())
            Else
                RecLock("GW3", .F.)
                    GW3->GW3_MUNINI := Alltrim((cAliasGW3)->NRCIDO) 											// Município Início Transporte
                    GW3->GW3_UFINI  := Posicione("GU7", 1, xFilial("GU7") + (cAliasGW3)->NRCIDO, "GU7_CDUF") 	// UF Início do Transporte
                    GW3->GW3_MUNFIM := Alltrim((cAliasGW3)->NRCIDD) 											// Município Término do Transporte
                    GW3->GW3_UFFIM  := Posicione("GU7", 1, xFilial("GU7") + (cAliasGW3)->NRCIDD, "GU7_CDUF") 	// UF Término do Transporte
                GW3->(MsUnlock())
            EndIf
        EndIf

        (cAliasGW3)->(dbSkip())
    EndDo

    If cMV_VLCNPJ == "2"
        cWhere := "SUBSTRING(GU3TR.GU3_IDFED,1,8) = SUBSTRING(GU3CALC.GU3_IDFED,1,8)"
    Else
        cWhere := "GU3TR.GU3_CDEMIT = GU3CALC.GU3_CDEMIT"
    EndIf

    cWhere := "%" + cWhere + "%"

    (cAliasGW3)->(dbCloseArea())

    BeginSQL Alias cAliasGWH
        SELECT GWH.R_E_C_N_O_ RECNOGWH,
               GWU.GWU_SEQ SEQ               
        FROM %Table:GW1% GW1
        INNER JOIN %Table:GWH% GWH
        ON GWH.GWH_FILIAL = GW1.GW1_FILIAL
        AND GWH.GWH_EMISDC = GW1.GW1_EMISDC
        AND GWH.GWH_SERDC = GW1.GW1_SERDC
        AND GWH.GWH_NRDC = GW1.GW1_NRDC
        AND GWH.GWH_CDTPDC = GW1.GW1_CDTPDC
        AND GWH.%NotDel%
        INNER JOIN %Table:GWF%  GWF
        ON GWF.GWF_FILIAL = GWH.GWH_FILIAL
        AND GWF.GWF_NRCALC = GWH.GWH_NRCALC
        AND GWF.%NotDel%
        INNER JOIN %Table:GWU% GWU
        ON GWU.GWU_FILIAL = GW1.GW1_FILIAL
        AND GWU.GWU_CDTPDC = GW1.GW1_CDTPDC
        AND GWU.GWU_EMISDC = GW1.GW1_EMISDC
        AND GWU.GWU_SERDC = GW1.GW1_SERDC
        AND GWU.GWU_NRDC = GW1.GW1_NRDC
        INNER JOIN %Table:GU3% GU3TR
        ON GU3TR.GU3_FILIAL = %xFilial:GU3%
        AND GU3TR.GU3_CDEMIT = GWU.GWU_CDTRP
        INNER JOIN %Table:GU3% GU3CALC
        ON GU3CALC.GU3_FILIAL = %xFilial:GU3%
        AND GU3CALC.GU3_CDEMIT = GWF.GWF_TRANSP
        WHERE GW1.GW1_DTEMIS >= %Exp:dDtEmiIni%
        AND GW1.GW1_DTEMIS <= %Exp:dDtEmiFim%
        AND %Exp:cWhere%
        AND GW1.%NotDel%
    EndSQL

    While ((cAliasGWH)->(!Eof()))
        GWH->(dbGoTo((cAliasGWH)->RECNOGWH))

        If Empty(GWH->GWH_TRECHO)
            RecLock("GWH", .F.)
                GWH->GWH_TRECHO := (cAliasGWH)->SEQ
            GWH->(MsUnlock())
        EndIf

        (cAliasGWH)->(dbSkip())
    EndDo

    (cAliasGWH)->(dbCloseArea())

    MsgInfo("","Acerto Finalizado!")
Return
