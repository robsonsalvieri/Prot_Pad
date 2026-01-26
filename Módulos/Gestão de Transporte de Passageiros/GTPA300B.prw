#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GTPA300B.CH"

Static c303BCodigo  := ""
Static cGY0_REVISA  := ""
Static cGID_COD     := ""

/*/{Protheus.doc} GTPA300B
(long_description)
@type  Static Function
@author flavio.martins
@since 30/09/2020
@version 1.0
@param , param_type, param_descr
@return nil, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Function GTPA300B(oModel)

If oModel:GetModel('HEADER'):GetValue('OPCAO') == 1 // Gera Viagens

    FWExecView(STR0001,"VIEWDEF.GTPA300B",MODEL_OPERATION_UPDATE, /*oDlg*/, {||.T.} /*bCloseOk*/, {||.T.}/*bOk*/,70/*nPercRed*/,/*aButtons*/, {||.T.}/*bCancel*/,,,oModel ) // "Gerar Viagens"

ElseIf oModel:GetModel('HEADER'):GetValue('OPCAO') == 2 // Consulta Viagens

    oModel:GetModel('HEADER'):LoadValue('TPVIAGEM', '3')
   // oModel:GetModel('HEADER'):LoadValue('OPCAO', nOpc)

    FWExecView(STR0002,"VIEWDEF.GTPA300B",MODEL_OPERATION_UPDATE, /*oDlg*/, {||.T.} /*bCloseOk*/, {||.T.}/*bOk*/,70/*nPercRed*/,/*aButtons*/, {||.T.}/*bCancel*/,,,oModel ) // "Consulta Viagens"

Endif

Return

/*/{Protheus.doc} ModelDef
(long_description)
@type  Static Function
@author flavio.martins
@since 30/09/2020
@version 1.0
@param , param_type, param_descr
@return nil, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function ModelDef()
Local oModel	:= Nil
Local oStruCab	:= FwFormModelStruct():New() 
Local bLoad		:= {|oModel| GA300BLoad(oModel)}
Local bCommit   := {|oModel| GA300BCommit(oModel)}

oModel := MPFormModel():New("GTPA300B",/*bPreValidacao*/, /*bPosValid*/, bCommit, /*bCancel*/ )

SetMdlStru(oStruCab)

oModel:AddFields("HEADER", /*cOwner*/, oStruCab,,,bLoad)

oModel:SetDescription(STR0002) // "Consulta de Viagens"
oModel:GetModel("HEADER"):SetDescription(STR0002)   // "Consulta de Viagens"

oModel:SetPrimaryKey({})

Return(oModel)

/*/{Protheus.doc} ViewDef
(long_description)
@type  Static Function
@author flavio.martins
@since 30/09/2020
@version 1.0
@param , param_type, param_descr
@return nil, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function ViewDef()
Local oView		:= nil
Local oModel	:= FwLoadModel("GTPA300B")
Local oStruCab	:= FwFormViewStruct():New()

// Cria o objeto de View
oView := FWFormView():New()

SetViewStru(oStruCab)

// Define qual o Modelo de dados serÃ¡ utilizado
oView:SetModel(oModel)

oView:SetDescription(STR0002) // "Consulta de Viagens"

oView:AddField('VIEW_HEADER' ,oStruCab,'HEADER')

oView:SetViewAction("ASKONCANCELSHOW",{||.F.})

oView:ShowUpdatetMsg(.F.)

Return(oView)

/*/{Protheus.doc} SetMdlStru
(long_description)
@type  Static Function
@author flavio.martins
@since 30/09/2020
@version 1.0
@param oStruct, param_type, param_descr
@return nil, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function SetMdlStru(oStruCab)
Local bFldVld := {|oMdl,cField,uNewValue,uOldValue|FieldValid(oMdl,cField,uNewValue,uOldValue) }
Local bTrig   := {|oMdl,cField,uNewValue,uOldValue|FieldTrig(oMdl,cField,uNewValue,uOldValue)}

	If ValType(oStruCab) == "O"
        oStruCab:AddTrigger("CLIEINI" , "CLIEINI" , {||.T.}, bTrig)
        oStruCab:AddTrigger("CLIEFIM" , "CLIEFIM" , {||.T.}, bTrig)
        oStruCab:AddTrigger("CONTRINI", "CONTRINI", {||.T.}, bTrig)
        oStruCab:AddTrigger("CONTRFIM", "CONTRFIM", {||.T.}, bTrig)
	
		oStruCab:AddField(STR0003,STR0003,"OPCAO"    ,"N" ,1                     ,0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.)                           //"Opção"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 
		oStruCab:AddField(STR0003,STR0003,"TPVIAGEM" ,"C" ,1                     ,0,{|| .T.},{|| .T.},{STR0014,STR0015,STR0016},.T.,NIL,.F.,.F.,.T.) //"Tipo de Viagem"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 
		oStruCab:AddField(STR0017,STR0017,"EXTRA"    ,"C" ,1                     ,0,{|| .T.},{|| .T.},{STR0018,STR0019,STR0020},.F.,NIL,.F.,.F.,.T.)      //"Viagem Extra"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 
		oStruCab:AddField(STR0004,STR0004,"DATAINI"  ,"D" ,8                     ,0,{|| .T.},{|| .T.},{},.T.,NIL,.F.,.F.,.T.)                         //"Data De"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 
		oStruCab:AddField(STR0005,STR0005,"DATAFIM"  ,"D" ,8                     ,0,bFldVld ,{|| .T.},{},.T.,NIL,.F.,.F.,.T.)                           //"Data Até"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 
		oStruCab:AddField(STR0010,STR0010,"CLIEINI"  ,"C",TamSx3('GY0_CLIENT')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.)     //"Cliente De" 
        oStruCab:AddField(STR0011,STR0011,"LOJAINI"  ,"C",TamSx3('GY0_LOJACL')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.)     //"Loja De"    
        oStruCab:AddField(STR0012,STR0012,"CLIEFIM"  ,"C",TamSx3('GY0_CLIENT')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.)     //"Cliente Até"
        oStruCab:AddField(STR0013,STR0013,"LOJAFIM"  ,"C",TamSx3('GY0_LOJACL')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.)     //"Loja De"    
        oStruCab:AddField(STR0008,STR0008,"CONTRINI" ,"C",TamSx3('GY0_NUMERO')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.)    //"Contrato De"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 
		oStruCab:AddField(STR0009,STR0009,"CONTRFIM" ,"C",TamSx3('GY0_NUMERO')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.)    //"Contrato Até"
        oStruCab:AddField(STR0006,STR0006,"LINHAINI" ,"C",TamSx3('GYN_LINCOD')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.)    //"Linha De"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 
		oStruCab:AddField(STR0007,STR0007,"LINHAFIM" ,"C",TamSx3('GYN_LINCOD')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.)    //"Linha Até"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  

	Endif	
	
Return

/*/{Protheus.doc} SetViewStru
(long_description)
@type  Static Function
@author flavio.martins
@since 30/09/2020
@version 1.0
@param oStruct , param_type, param_descr
@return nil, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function SetViewStru(oStruCab)

If ValType(oStruCab) == "O"
    oStruCab:AddField("TPVIAGEM","01",STR0003,STR0003,{""},"GET","@!",NIL,"GI6ENC",.T.,NIL,NIL,{STR0014,STR0015,STR0016},NIL,NIL,.F.)   // "Tipo de viagem"
    oStruCab:AddField("EXTRA"   ,"02",STR0017,STR0017,{""},"GET","@!",NIL,""      ,.T.,NIL,NIL,{STR0018,STR0019,STR0020},NIL,NIL,.F.)		    //"Viagem Extra"
    oStruCab:AddField("DATAINI" ,"03",STR0004,STR0004,{""},"GET",""  ,NIL,""      ,.T.,NIL,NIL,{},NIL,NIL ,.F.)		                            //"Data De"
    oStruCab:AddField("DATAFIM" ,"04",STR0005,STR0005,{""},"GET",""  ,NIL,""      ,.T.,NIL,NIL,{},NIL,NIL ,.F.)
    oStruCab:AddField("CLIEINI" ,"05",STR0010,STR0010,{""},"GET","@!",NIL,"SA1"   ,.T.,NIL,NIL,{},NIL,NIL ,.F.)	                            //"Cliente De"
    oStruCab:AddField("LOJAINI" ,"09",STR0011,STR0011,{""},"GET","@!",NIL,""      ,.T.,NIL,NIL,{},NIL,NIL ,.F.)		                        //"Loja De"
    oStruCab:AddField("CLIEFIM" ,"10",STR0012,STR0012,{""},"GET","@!",NIL,"SA1"   ,.T.,NIL,NIL,{},NIL,NIL ,.F.)	                            //"Cliente Até"
    oStruCab:AddField("LOJAFIM" ,"11",STR0013,STR0013,{""},"GET","@!",NIL,""      ,.T.,NIL,NIL,{},NIL,NIL ,.F.)		                        //"Loja De"
    oStruCab:AddField("CONTRINI","12",STR0008,STR0008,{""},"GET","@!",NIL,"CLIGY0"   ,.T.,NIL,NIL,{},NIL,NIL ,.F.)	                            //"Contrato De"
    oStruCab:AddField("CONTRFIM","13",STR0009,STR0009,{""},"GET","@!",NIL,"CLIGY0"   ,.T.,NIL,NIL,{},NIL,NIL ,.F.)	                            //"Data Até"
    oStruCab:AddField("LINHAINI","14",STR0006,STR0006,{""},"GET","@!",NIL,"LINGYD"   ,.T.,NIL,NIL,{},NIL,NIL ,.F.)	                            //"Linha De"
    oStruCab:AddField("LINHAFIM","15",STR0007,STR0007,{""},"GET","@!",NIL,"LINGYD"   ,.T.,NIL,NIL,{},NIL,NIL ,.F.)	                            //"Linha Até"	                            //"Contrato Até"  
Endif
    
Return

/*/{Protheus.doc} GA200BLoad
(long_description)
@type  Static Function
@author flavio.martins
@since 30/09/2020
@version 1.0
@param oModel, param_type, param_descr
@return nil, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function GA300BLoad(oModel)
Local oMdlCab := oModel:GetModel('HEADER')

Return

/*/{Protheus.doc} GeraViagens
(long_description)
@type  Static Function
@author flavio.martins
@since 30/09/2020
@version 1.0
@param oModel , param_type, param_descr
@return nil, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function GeraViagens(oModel)
Local aArea		:= GetArea()
Local cAliasQry	:= GetNextAlias()
Local dDtIni	:= CTOD("  /  /    ")
Local dDtFim	:= CTOD("  /  /    ")
Local cLinIni	:= ""
Local cLinFim	:= ""
Local cCliIni	:= ""
Local cCliFim   := ""
Local cLojaIni	:= ""
Local cLojaFim  := ""
Local cContrIni := ""
Local cContrFim := ""
Local cKmProvavel := ""
Local lRet		:= .T.
Local n1		:= 0
Local nCont		:= 0 
Local dDtRef	:= CTOD("  /  /    ")
Local cWhere	:= ""
Local cJoin     := "%%"
Local cSqlNumCar:= "%%"
Local nQtdCarros:= 1 
Local aMsgError := {}
Local cMsgError := ''

Default lBlind	:= .F.

IIF(GYD->(FieldPos("GYD_NUMCAR")) > 0,cSqlNumCar:= "%GYD_NUMCAR,%",cSqlNumCar:= "%%")


dDtIni		:= oModel:GetModel('HEADER'):GetValue('DATAINI')
dDtFim		:= oModel:GetModel('HEADER'):GetValue('DATAFIM')
cLinIni		:= oModel:GetModel('HEADER'):GetValue('LINHAINI')
cLinFim 	:= oModel:GetModel('HEADER'):GetValue('LINHAFIM')
cContrIni   := oModel:GetModel('HEADER'):GetValue('CONTRINI')
cContrFim   := oModel:GetModel('HEADER'):GetValue('CONTRFIM')
cCliIni     := oModel:GetModel('HEADER'):GetValue('CLIEINI')
cLojaIni    := oModel:GetModel('HEADER'):GetValue('LOJAINI')
cCliFim     := oModel:GetModel('HEADER'):GetValue('CLIEFIM')
cLojaFim    := oModel:GetModel('HEADER'):GetValue('LOJAFIM')

If oModel:GetModel('HEADER'):GetValue('TPVIAGEM') == '3'

    cJoin := "% INNER JOIN " + RetSqlName('GY0') + " GY0 ON GY0.GY0_FILIAL = '" + xFilial('GY0') + "'"
    cJoin += " AND GY0.GY0_NUMERO BETWEEN '" + cContrIni + "' AND '" + cContrFim + "'"
    cJoin += " AND GY0.GY0_ATIVO = '1' "
    cJoin += " AND GY0.GY0_CLIENT BETWEEN '" + cCliIni + "' AND '" + cCliFim + "'"
    cJoin += " AND GY0.GY0_LOJACL BETWEEN '" + cLojaIni + "' AND '" + cLojaFim + "'"
    cJoin += " AND GY0.D_E_L_E_T_ = ' ' "       
    cJoin += " INNER JOIN " + RetSqlName('GYD') + " GYD ON GYD.GYD_FILIAL = '" + xFilial('GYD') + "'"
    cJoin += " AND GYD.GYD_CODGI2 = GI2.GI2_COD "
    cJoin += " AND GYD.GYD_NUMERO = GY0.GY0_NUMERO "
    cJoin += " AND GYD.GYD_REVISA = GY0.GY0_REVISA "
    cJoin += " AND GYD.D_E_L_E_T_ = ' ' %"

Endif

If !(Vazio(dDtIni) .And. Vazio(dDtFim))
    
    nCont := (dDtFim-dDtIni)+1
    
    ProcRegua(nCont)
    dDtRef := dDtIni
    
    Begin Transaction

    For n1 := 1 To nCont	
        IncProc()
        cAliasQry   := GetNextAlias()
        cWhere      := "% GID.GID_"+UPPER(substr(DIASEMANA(dDtRef),1,3))+ " = 'T'  AND "
        cWhere      += "  '"+DtoS(dDtRef)+"' BETWEEN GID.GID_INIVIG AND GID.GID_FINVIG  %"

        
    
        // ----------------------------------------------------------------------+
        // QUERY BUSCA OS HORARIOS/SERVICOS COM BASE NAS INFORMACOES DO PERGUNTE |
        // ----------------------------------------------------------------------+		
        BeginSql Alias cAliasQry

            SELECT 	GID.GID_COD, 
                    GID.GID_LINHA, 
                    GID.GID_SENTID,
                    GID.GID_FINVIG,
                    GY0.GY0_NUMERO,
                    GY0.GY0_REVISA,
                    GYD.GYD_KMIDA,%Exp:cSqlNumCar%
                    GYD.GYD_KMVOLT
            FROM %TABLE:GID% GID
            INNER JOIN %Table:GI2% GI2 ON GI2.GI2_FILIAL = GID.GID_FILIAL
            AND GI2.GI2_COD = GID.GID_LINHA
            AND GI2.GI2_HIST = '2'
            AND GI2.%NotDel%
            %Exp:cJoin% 
            WHERE  GID.GID_FILIAL =  %xFilial:GID%
                AND GID.GID_HIST = '2'
                AND GID.GID_LINHA BETWEEN  %Exp:cLinIni% AND %Exp:cLinFim%
                AND GID.GID_REVCON = GY0.GY0_REVISA
                AND GID.%NotDel%
                AND %Exp:cWhere% 
                AND GID.GID_COD NOT IN 
                    ( 
                        SELECT GYN_CODGID 
                        FROM %TABLE:GYN% GYN
                        WHERE 
                            GYN.GYN_FILIAL = %xFilial:GYN% 
                            AND GYN.GYN_DTINI = %Exp:DtoS(dDtRef)% 
                            AND GYN.GYN_LINCOD BETWEEN  %Exp:cLinIni% AND %Exp:cLinFim% 
                            AND GYN.%NotDel%
                    )	
                
        EndSql
        // --------------------------------------------------------+
        // INCLUI UMA VIAGEM PARA CADA HORARIO ENCONTRADO NA QUERY |
        // --------------------------------------------------------+
        (cAliasQry)->(DbGoTop())				
        If (cAliasQry)->( !Eof() ) 	

            cGY0_REVISA := (cAliasQry)->GY0_REVISA
            cGID_COD    := (cAliasQry)->GID_COD

            //-- Varre os trechos do cad. de horarios.
            While (cAliasQry)->( !Eof()  ) 	
                cKmProvavel := cValToChar((cAliasQry)->GYD_KMIDA + (cAliasQry)->GYD_KMVOLT)	
                //8170
                IIF(GYD->(FieldPos("GYD_NUMCAR")) > 0,nQtdCarros:= (cAliasQry)->GYD_NUMCAR ,nQtdCarros:= 1)
               
                lRet := GTPXGerViag((cAliasQry)->GID_LINHA,(cAliasQry)->GID_SENTID,(cAliasQry)->GID_COD,DtoS(dDtRef),DtoS(dDtRef),,,"3",(cAliasQry)->GY0_NUMERO,cKmProvavel,nQtdCarros,@aMsgError)

                If !lRet
                    Exit
                EndIf  

            //-- Pula para o proximo trecho					
            (cAliasQry)->(DbSkip())
            EndDo

            If !lRet
                DisarmTransaction()
                //FWAlertHelp("Erro na geração das viagens")
            Endif

        EndIf
        
        If !lRet
            Exit
        Endif

        dDtRef:= dDtRef+1
        (cAliasQry)->(dBCloseArea())

    Next

    End Transaction

    If !lRet
        cMsgError := CRLF + aMsgError[4] + CRLF
        cMsgError +=        aMsgError[5] + CRLF
        cMsgError +=        aMsgError[6] + CRLF
        oModel:GetModel():SetErrorMessage(oModel:GetId(),aMsgError[4],oModel:GetId(),aMsgError[4],"GeraViagens",cMsgError,"") 
    EndIf 
Else
    FwAlertHelp('Não foram informados os dados de data inicial e final')	
Endif

RestArea(aArea)
		
Return lRet

/*/{Protheus.doc} GA300BCommit
(long_description)
@type  Static Function
@author flavio.martins
@since 30/09/2020
@version 1.0
@param oModel, param_type, param_descr
@return nil, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function GA300BCommit(oModel)
Local lRet := .T.

If oModel:GetModel('HEADER'):GetValue('OPCAO') == 1
    FwMsgRun( ,{|| lRet := GeraViagens(oModel)},, "Gerando Viagens")
Endif

If lRet 
    GTPA300A(oModel,cGY0_REVISA,cGID_COD)
Endif

Return lRet

/*/{Protheus.doc} FieldValid
(long_description)
@type  Static Function
@author flavio.martins
@since 01/10/2020
@version 1.0
@param oMdl, param_type, param_descr
@return nil, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function FieldValid(oMdl,cField,uNewValue,uOldValue) 
Local lRet		:= .T.
Local oModel	:= oMdl:GetModel()
Local cMdlId	:= oMdl:GetId()
Local cMsgErro	:= ""
Local cMsgSol	:= ""

Do Case
	Case Empty(uNewValue)
		lRet := .T.
    
    Case cField == "DATAFIM"
        If uNewValue < oModel:GetModel('HEADER'):GetValue('DATAINI')
            lRet     := .F.
            cMsgErro := "Data final não pode ser menor que a data inicial"
            cMsgSol  := "Altere a data final"
        Endif
EndCase

If !lRet .and. !Empty(cMsgErro)
	oModel:SetErrorMessage(cMdlId,cField,cMdlId,cField,"FieldValid",cMsgErro,cMsgSol,uNewValue,uOldValue)
Endif

Return lRet



/*/{Protheus.doc} FieldTrig(oMdl,cField,uNewValue,uOldValue)
(long_description)
@type  Static Function
@author user
@since 18/05/2021
@version version
@param param_name, param_type, param_descr
@return return_var, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function FieldTrig(oMdl,cField,uNewValue,uOldValue)
Local lRet     := .T.

Do Case
	Case cField $'CLIEINI|CLIEFIM'
        oMdl:SetValue('CONTRINI', '')
        oMdl:SetValue('CONTRFIM', '')
        oMdl:SetValue('LINHAINI', '')
        oMdl:SetValue('LINHAFIM', '')
	Case cField $ 'CONTRINI|CONTRFIM'
        oMdl:SetValue('LINHAINI', '')
        oMdl:SetValue('LINHAFIM', '')
EndCase

Return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} G303BFil
Montagem da consulta padrão especifica na GYD
@sample		G303BFil
@return		lRet, Lógico, .T. ou .F.
@author		Mick William da Silva
@since		08/04/2024
@version	P12
/*/
//------------------------------------------------------------------------------------------
Function G303BFil()
    
    Local oModel	    := FwModelActive()
	Local cMdlId	    := ""
    Local aRetorno 		:= {}
    Local cQryGYD       := ""      
    Local lRet     		:= .F.
    Local oLookUp  		:= Nil
    Local cConteudo     := ""
    Local cCont2        := ""
    Local   cDBUse      := AllTrim( TCGetDB() )

	If Valtype( oModel ) <> "U"
		cMdlId	:= oModel:GetId()
	EndIF
    
    If cMdlId == 'GTPA300B'
        If !Empty(oModel:GetModel('HEADER'):GetValue('CONTRINI'))
			cConteudo 	:= oModel:GetModel('HEADER'):GetValue('CONTRINI')
			cCont2		:= oModel:GetModel('HEADER'):GetValue('CONTRFIM')

            cQryGYD:= " SELECT DISTINCT GYD.GYD_NUMERO, "

			Do Case
				Case cDBUse == 'ORACLE' //Oracle disponibiliza duas fun  es  teis o NVL() e NVL2()
                    cQryGYD+= " (SELECT GYD_REVISA FROM " +RetSqlName("GYD")+ " GYD2 WHERE GYD2.GYD_FILIAL = GYD.GYD_FILIAL AND "
				OtherWise
                    cQryGYD+= " (SELECT TOP 1 GYD_REVISA FROM " +RetSqlName("GYD")+ " GYD2 WHERE GYD2.GYD_FILIAL = GYD.GYD_FILIAL AND "
            EndCase

            cQryGYD+= " GYD2.GYD_NUMERO=GYD.GYD_NUMERO AND GYD2.GYD_INIVIG = GYD.GYD_INIVIG AND  "
            cQryGYD+= " GYD2.GYD_CLIENT = GYD.GYD_CLIENT AND GYD2.GYD_LOJACL = GYD.GYD_LOJACL AND GYD2.D_E_L_E_T_=' ' "

			Do Case
				Case cDBUse == 'ORACLE' //Oracle disponibiliza duas fun  es  teis o NVL() e NVL2()
                    cQryGYD+= " ORDER BY GYD2.GYD_REVISA DESC  fetch first 1 rows only) GYD_REVISA, GYD.GYD_CODGI2, "
                    cQryGYD+= " COALESCE(TRIM(GI1INI.GI1_DESCRI) || '/' || TRIM(GI1FIM.GI1_DESCRI), ' ') AS GI1_DESCRI "
				OtherWise
                    cQryGYD+= " ORDER BY GYD2.GYD_REVISA DESC) AS GYD_REVISA, GYD.GYD_CODGI2, "
                    cQryGYD+= " ISNULL(RTRIM(GI1INI.GI1_DESCRI) + '/' + RTRIM(GI1FIM.GI1_DESCRI),'') AS GI1_DESCRI "
			EndCase

            cQryGYD+= " FROM " + RetSqlName("GYD") + " GYD  "
            cQryGYD+= " LEFT JOIN " + RetSqlName("GI2") + " GI2 ON GI2.GI2_FILIAL = GYD.GYD_FILIAL AND GI2.GI2_COD = GYD.GYD_CODGI2 AND GI2.D_E_L_E_T_= ' ' "
            cQryGYD+= " LEFT JOIN " + RetSqlName("GI1") + " GI1INI ON GI1INI.GI1_FILIAL = '"+xFilial('GI1')+"' AND GI1INI.GI1_COD = GI2_LOCINI AND GI1INI.D_E_L_E_T_= ' ' "
            cQryGYD+= " LEFT JOIN " + RetSqlName("GI1") + " GI1FIM ON GI1FIM.GI1_FILIAL = '"+xFilial('GI1')+"' AND GI1FIM.GI1_COD = GI2_LOCFIM AND GI1FIM.D_E_L_E_T_= ' ' "
            cQryGYD+= " WHERE GYD.GYD_FILIAL = '"+xFilial('GYD')+"' " 
            cQryGYD+= " AND GYD.GYD_NUMERO>='"+cConteudo+"' AND "

            If !Empty(Alltrim(cCont2))
                cQryGYD+= " GYD.GYD_NUMERO<='"+cCont2+"' AND "
            EndIf

            cQryGYD+= " GYD.D_E_L_E_T_=' ' "

            cQryGYD := ChangeQuery(cQryGYD)

            oLookUp := GTPXLookUp():New(StrTran(cQryGYD, '#', '"'), {"GYD_NUMERO","GYD_REVISA", "GYD_CODGI2","GI1_DESCRI"})

            oLookUp:AddIndice("Nr.Orç.Contr", "GYD_NUMERO")
            oLookUp:AddIndice("Revisao"		, "GYD_REVISA")
            oLookUp:AddIndice("Cód.Linha"   , "GYD_CODGI2")
            oLookUp:AddIndice("Nome Linha"  , "GI1_DESCRI")

            If oLookUp:Execute()
                lRet       := .T.
                aRetorno   := oLookUp:GetReturn()
                c303BCodigo:= aRetorno[3]
            EndIf   
            FreeObj(oLookUp)
        EndIf
    EndIf
Return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} G303BRFil()
Função de retorno da consulta padrão especifica na GYD
@sample		G303BRFil()
@return 	cRet, caracter, Retorna o contrato selecionado.
@author		Mick William da Silva
@since		08/04/2024
@version	P12
/*/
//------------------------------------------------------------------------------------------
Function G303BRFil()

    Local cRet :='' 
    
    cRet:=	c303BCodigo

Return cRet
