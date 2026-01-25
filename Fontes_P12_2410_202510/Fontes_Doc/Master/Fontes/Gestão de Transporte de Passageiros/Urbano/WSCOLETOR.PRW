#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "WSCOLETOR.CH"

//------------------------------------------------------------------------------
/*/{Protheus.doc} COLETOR URBANO PO-UI

Classe WSRESTFUL - API Web Service RESTFUL - Coletor Urbano

@Metodos WSMETHOD

@author  Karyna Martins
@since   06/06/2024
/*/
//------------------------------------------------------------------------------
WSRESTFUL COLETORURBANO DESCRIPTION "Coletor Urbano"        
	WSDATA page      as INTEGER
	WSDATA pageSize  as INTEGER
  
    WSMETHOD POST coletor;
        DESCRIPTION "Método para consultar conteudo do combo de Local" PATH "coletor" PRODUCES APPLICATION_JSON;
        WSSYNTAX "COLETORURBANO/coletor/";
        PATH "COLETORURBANO/coletor/";
        PRODUCES APPLICATION_JSON
    

END WSRESTFUL

//-------------------------------------------------------------------
/*/{Protheus.doc} POST coletor
Efetua o POST do coletor na prestação de contas

@author  Karyna Martins
@since   06/06/2024
@param 

@example 

/*/
//-------------------------------------------------------------------
WSMETHOD POST coletor WSREST COLETORURBANO

    Local oModel        := Nil    
    Local oRequest      := JSonObject():New()
    Local oResponse	    := JsonObject():New()
    Local aAreaGYG	    := {}
    Local aAreaH70	    := {}
    Local aAreaH6V	    := {}
    Local lRet          := .T.
    Local cBody         := Self:GetContent()
    Local cMsgError	    := ''
    Local cCodigoH7I    := '' 
    Local cPrefixo      := ''
    Local cLinha        := ''
    Local cVeiculo      := ''
    Local cMatMot       := ''
    Local cMatCob       := ''
    Local cFilBkp       := cFilAnt 
    Local cFilAux       := ''
    Local nServico      := 1
    Local nPagamento    := 1

    DbSelectArea("GYG")
    DbSelectArea("H70")
    DbSelectArea("H6V")

    aAreaGYG	    := GYG->(GetArea())
    aAreaH70	    := H70->(GetArea())
    aAreaH6V	    := H6V->(GetArea())

    oRequest:fromJson(cBody)

    oModel := FwLoadModel('GTPU013')

    oModel:SetOperation(MODEL_OPERATION_INSERT)
    oModel:Activate()
    
    cMatMot    := Padr(oRequest['cabecalho']['matMotorista'],TamSx3('GYG_FUNCIO')[1])
    cMatCob    := Padr(oRequest['cabecalho']['matCobrador'],TamSx3('GYG_FUNCIO')[1])
    cFilAux    := GetEmpUrb(oRequest['cabecalho']['empresa'] )

    If Empty(cFilAux)
        lRet 	  := .F.	
        cMsgError := STR0001 //"Filial não encontrada no cadastro De/Para"
    ElseIf Empty(cMatMot) .And. Empty(cMatCob)
        lRet 	  := .F.	
        cMsgError := STR0002 //"Motorista e cobrador não informados. É necessário informar um motorista ou um cobrador"
    Else
        cFilAnt := cFilAux
    EndIf

    If lRet
        
        GYG->(DbSetOrder(2))

        If !Empty(cMatMot)
            If  GYG->(DbSeek(xFilial("GYG") + cMatMot)) .And. GYG->GYG_RECCOD == '01'
                cMatMot := GYG->GYG_CODIGO
            Else
                lRet 	  := .F.	
                cMsgError := STR0003 //"Matrícula do motorista não encontrada"
            EndIf

        EndIf

        If !Empty(cMatCob)
            If  GYG->(DbSeek(xFilial("GYG") + cMatCob)) .And. GYG->GYG_RECCOD == '02'
                cMatCob := GYG->GYG_CODIGO
            Else
                lRet 	  := .F.	
                cMsgError := STR0004 //"Matrícula do cobrador não encontrada"
            EndIf
            
        EndIf
    
        If lRet

            // Cabeçalho
            oModel:SetValue('H7IMASTER', 'H7I_FILIAL', cFilAux)
            oModel:LoadValue('H7IMASTER', 'H7I_MOTORI', cMatMot)
            oModel:SetValue('H7IMASTER', 'H7I_CARMOT', oRequest['cabecalho']['cartaoMotorista'])
            oModel:LoadValue('H7IMASTER', 'H7I_COBRAD', cMatCob)  
            oModel:SetValue('H7IMASTER', 'H7I_CARCOB', Iif(!Empty(cMatCob), oRequest['cabecalho']['cartaoCobrador'], "")) 
            oModel:SetValue('H7IMASTER', 'H7I_DATREF', StoD(oRequest['cabecalho']['dataMovimento']))
            oModel:SetValue('H7IMASTER', 'H7I_COLETA', oRequest['cabecalho']['filipeta'])            

            // Serviços
            For nServico := 1 To Len(oRequest['servicos'])

                If (nServico > 1) 
                    oModel:GetModel('H7JDETAIL'):AddLine()
                Endif

                cVeiculo      := Padr(oRequest['servicos'][nServico]['codVeiculo'],TamSx3('H70_PRFVEI')[1])
                cPrefixo      := Padr(oRequest['servicos'][nServico]['prefixoLinha'],TamSx3('H6V_PREFIXO')[1])
                cLinha        := Padr(oRequest['servicos'][nServico]['codigoLinha'],TamSx3('H6V_CODLIN')[1])

                cVeiculo:= Posicione("H70",2, xFilial("H70") + cVeiculo, "H70_CODVEI")
                cLinha  := Posicione("H6V",2, xFilial("H6V") + cPrefixo + cLinha,"H6V_CODIGO")

                If Empty(cVeiculo)
                    lRet 	  := .F.	
                    cMsgError := STR0005 //"Cadastro do veículo não encontrado"
                ElseIf Empty(cLinha)
                    lRet 	  := .F.	
                    cMsgError := STR0006 //"Cadastro de linha não encontrada"
                Else             

                    oModel:SetValue('H7JDETAIL', 'H7J_SERVIC', oRequest['servicos'][nServico]['codServico'])   
                    oModel:LoadValue('H7JDETAIL', 'H7J_VEICUL', cVeiculo )   
                    oModel:LoadValue('H7JDETAIL', 'H7J_CODH6V', cLinha)     
                    oModel:SetValue('H7JDETAIL', 'H7J_TURNO',  oRequest['servicos'][nServico]['turno'])
                    oModel:SetValue('H7JDETAIL', 'H7J_DATAIS', StoD(oRequest['servicos'][nServico]['dataInicioViagem']))
                    oModel:SetValue('H7JDETAIL', 'H7J_DATATS', StoD(oRequest['servicos'][nServico]['dataTerminoViagem']))
                    oModel:SetValue('H7JDETAIL', 'H7J_HRINIS', oRequest['servicos'][nServico]['hrInicio'])
                    oModel:SetValue('H7JDETAIL', 'H7J_HRTERS', oRequest['servicos'][nServico]['hrFim'])  
                    oModel:SetValue('H7JDETAIL', 'H7J_VERCOL', oRequest['layoutColetor']['versaoColetor'])     
                                    
                    // Pagamentos
                    For nPagamento := 1 To Len(oRequest['servicos'][nServico]['dadosValidador']['pagamentos'])

                        If (nPagamento > 1) 
                            oModel:GetModel('H7LDETAIL'):AddLine()
                        Endif

                        H6R->(DbSetOrder(1))
                        If !H6R->(DbSeek(xFilial("H6R") + Padr(oRequest['servicos'][nServico]['dadosValidador']['pagamentos'][nPagamento]['tipoPagamento'],TamSX3('H6R_CODIGO')[1])))
                            lRet 	  := .F.	
                            cMsgError := STR0007 //"Cadastro da forma de pagamento não encontrado"
                        Else
                            oModel:SetValue('H7LDETAIL', 'H7L_TPAGAM', oRequest['servicos'][nServico]['dadosValidador']['pagamentos'][nPagamento]['tipoPagamento']) 
                            oModel:SetValue('H7LDETAIL', 'H7L_NUMPAS', oRequest['servicos'][nServico]['dadosValidador']['pagamentos'][nPagamento]['quantidadePassageiros'])
                            oModel:SetValue('H7LDETAIL', 'H7L_VLRUNI', oRequest['servicos'][nServico]['dadosValidador']['pagamentos'][nPagamento]['valorUnitario'])
                        EndIf

                    Next

                EndIf           
                
            Next
            
            oModel:SetValue('H7IMASTER', 'H7I_INTEGR', 'S')

        EndIf  

    EndIf  

    If lRet .And. oModel:VldData()           
        cCodigoH7I := oModel:GetValue('H7IMASTER', 'H7I_CODIGO')

        oModel:CommitData()

        oResponse['status'] := 'success'
        oResponse['prestacaoContas'] := cCodigoH7I 
        oResponse['message'] := EncodeUtf8(STR0008) //'Prestação de contas incluída com sucesso'
                     
        Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))
    Else
        If Empty(cMsgError)
            cMsgError := oModel:GetErrorMessage()[6]
        EndIf

        SetRestFault(400, EncodeUtf8(cMsgError))

    Endif

    oModel:DeActivate()
    oResponse := Nil
    oRequest :=  Nil
    cFilAnt := cFilBkp

    H70->(RestArea(aAreaH70))
    H6V->(RestArea(aAreaH6V))
    GYG->(RestArea(aAreaGYG))

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GetEmpUrb
Realiza o De/Para das filiais

@author Karyna Martins
@since  06/06/2024
@version 1.0

/*/
//-------------------------------------------------------------------
Static function GetEmpUrb(cEmpresa)

    Local aRetEmp	  := {}    
    Local cRetEmp	  := ""
    Local cReferencia := Padr('COLETOR', 15)
    
    Default cEmpresa  := cEmpAnt  
   
    cEmpresa := Padr(cEmpresa, 2)     

    aRetEmp := FwEaiEmpFil(cEmpresa,,cReferencia)

    If Len(aRetEmp) > 0
        cRetEmp := aRetEmp[2]        
    Endif

Return cRetEmp
