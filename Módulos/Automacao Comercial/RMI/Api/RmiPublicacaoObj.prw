#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "RMIPUBLICACAOOBJ.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} Classe RmiPublicacaoObj
    Classe para tratamento da API de Publicação de dados do Varejo
/*/
//-------------------------------------------------------------------
Class RmiPublicacaoObj From LojRestObj

	Method New(oWsRestObj)  Constructor

    Method SetSelect(cTable)
    Method Alter()
    Method ExecAuto()

EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New
Método construtor da Classe

@param oWsRestObj - Objeto WSRESTFUL da API

@author  Rafael Tenorio da Costa
@since   16/07/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Method New(oWsRestObj) Class RmiPublicacaoObj

    _Super:New(oWsRestObj)

    self:SetSelect("MHQ")

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} SetSelect
Carrega a query que será executada

@author  Rafael Tenorio da Costa
@since   23/07/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Method SetSelect(cTable) Class RmiPublicacaoObj

    Local aAux := {}

    self:cTable := cTable

    If self:oWsRestObj:AssinanteProcesso <> Nil .And. !Empty(self:oWsRestObj:AssinanteProcesso)
        aAux := Separa( Upper(self:oWsRestObj:AssinanteProcesso), "|")
    EndIf
        
	If Len(aAux) > 0
        If !( AllTrim(aAux[1]) $ "LIVE|CHEF|PROTHEUS" )

            self:cSelect := " SELECT MHQ_ORIGEM, MHQ_CPROCE, MHQ_DATGER, MHQ_HORGER, MHQ_UUID, CAST( MHQ_MENSAG AS VARCHAR(8000) ) AS MHQ_MENSAG"       //Cast pra limitação de campo memo
            self:cSelect += " FROM " + RetSqlName("MHR") + " MHR INNER JOIN " + RetSqlName("MHQ") +" MHQ"
            self:cSelect +=     " ON  MHR.MHR_FILIAL = MHQ.MHQ_FILIAL AND"
            self:cSelect +=         " MHR.MHR_CPROCE = MHQ.MHQ_CPROCE AND"
            self:cSelect +=         " MHR.MHR_UIDMHQ = MHQ.MHQ_UUID AND"
            self:cSelect +=         " MHQ.D_E_L_E_T_ = ' '"

            self:cWhere  := " WHERE MHR.D_E_L_E_T_ = ' ' AND"
            self:cWhere  +=     " MHR.MHR_STATUS = '1' AND"
            self:cWhere  +=     " MHR.MHR_CASSIN = '" + aAux[1] + "' AND"
            self:cWhere  +=     " MHR.MHR_CPROCE = '" + aAux[2] + "' "
        EndIf     
    EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} 
Método que ira fazer a alteração do status 

@author  Danilo Santos
@since   11/12/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Method Alter(cAssinante, oEaiObj) Class RmiPublicacaoObj

    Local cProcesso := ""
    Local cChave    := ""
    Local nX        := 0
    Local oModel    := Nil
    Local lAtualiza := .F.

    //Carrega Assinante no padrão do cadastro
    cAssinante := AllTrim( Upper( PadR(cAssinante, TamSX3("MHR_CASSIN")[1]) ) )    

    //Produtos da Totvs não podem ser atualizados pela API
    If cAssinante $ "LIVE|CHEF|PROTHEUS"

        self:lSuccess := .F.
        self:cError   := I18n(STR0001, {cAssinante})    //"Não é possivel atualizar o status de Distribuições de Assinantes internos da TOTVS (#1)"
    Else

        //Carrega configurações do modelo MVC
        oModel := FWLoadModel("RMIDISMVC")
        oModel:SetOperation(MODEL_OPERATION_UPDATE)

        DbSelectArea("MHR")
        MHR->( DbSetOrder(4) )  //MHR_FILIAL + MHR_UIDMHQ + MHR_CPROCE + MHR_CASSIN
        
        For nX:= 1 To Len(oEaiObj['ITEMS'])
            
            cProcesso := PadR( oEaiObj['ITEMS'][nX]['PROCESSO'], TamSX3("MHR_CPROCE")[1] )
            cChave    := Lower( PadR(oEaiObj['ITEMS'][nX]['CHAVEUNICA'], TamSX3("MHR_UIDMHQ")[1]) )

            If MHR->( DbSeek(xFilial("MHR") + cChave + cProcesso + cAssinante) )

                //Carrega o registro no modelo
	            oModel:Activate()

                oModel:SetValue("MHRMASTER", "MHR_STATUS", "2"      )   //1=A Processar;2=Processada;3=Erro
                oModel:SetValue("MHRMASTER", "MHR_TENTAT", "1"      )
                oModel:SetValue("MHRMASTER", "MHR_DATPRO", Date()   )
                oModel:SetValue("MHRMASTER", "MHR_HORPRO", Time()   )

                //Atualiza registro
                If ( lAtualiza := oModel:VldData() )
                    lAtualiza := oModel:CommitData()
                EndIf

                If lAtualiza
                    oEaiObj['ITEMS'][nX]['STATUS'] := STR0002   //"Atualizado"
                Else
                    oEaiObj['ITEMS'][nX]['STATUS'] := oModel:GetErrorMessage(.T.)[6]
                EndIf

                oModel:Deactivate()
            Else

                oEaiObj['ITEMS'][nX]['STATUS'] := I18n(STR0003, {"MHR_UIDMHQ = " + cChave})  //"Chave Única não encontrada: (#1)"
            EndIf

        Next nX

        oModel:Destroy()
    EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} ExecAuto
Executa a gravação da publicação

@author  Rafael Tenorio da Costa
@since   28/02/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Method ExecAuto() Class RmiPublicacaoObj

    Local nCampo    := 0
    Local oModel    := Nil
    Local aExecAuto := aClone(self:aExecAuto[1])
    Local xConteudo := Nil

    //Carrega configurações do modelo MVC
    oModel := FWLoadModel("RMIPUBMVC")
    oModel:SetOperation(MODEL_OPERATION_INSERT)
	oModel:Activate()

    Varinfo("",aExecAuto)

    //Carrega campos
    For nCampo:=1 To Len(aExecAuto)
        
        xConteudo := StrTran(aExecAuto[nCampo][2], "'", '"')

        //Tratamento para conseguir transformar o conteudo deste campo em um JsonObject
        If AllTrim(aExecAuto[nCampo][1]) == "MHQ_MENSAG"
            xConteudo := StrTran(aExecAuto[nCampo][2], "'", '"')
        EndIf

        oModel:SetValue("MHQMASTER", aExecAuto[nCampo][1], xConteudo)
    Next nCampo

    oModel:SetValue("MHQMASTER", "MHQ_STATUS", "1"          )   //1=A Processar;2=Processada;3=Erro
    oModel:SetValue("MHQMASTER", "MHQ_DATGER", Date()       )
    oModel:SetValue("MHQMASTER", "MHQ_HORGER", Time()       )    
    oModel:SetValue("MHQMASTER", "MHQ_UUID"  , FwUUID("MHQ"))   //Gera chave unica    
    oModel:SetValue("MHQMASTER", "MHQ_MSGORI", self:cBody   )    

    If ( self:lSuccess := oModel:VldData() )
        self:lSuccess := oModel:CommitData()
    EndIf

    //Carrega o retorno
    If self:lSuccess
        self:cBody  := '{ "MHQ_UUID": "' + oModel:GetValue("MHQMASTER", "MHQ_UUID") + '" }'
    Else
        self:cError := I18n(STR0004, {oModel:GetErrorMessage(.T.)[6]})  //"Não foi possível incluir a Publicação: #1"
    EndIf

    oModel:Deactivate()
    oModel:Destroy()
    
Return Nil