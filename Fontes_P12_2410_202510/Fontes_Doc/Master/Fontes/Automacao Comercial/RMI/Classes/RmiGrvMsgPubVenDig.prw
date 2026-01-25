#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} Classe RmiGrvMsgPubVenDig
Classe responsável em gravar o Json de publicação no campo MHQ_MENSAG
    
/*/
//-------------------------------------------------------------------
Class RmiGrvMsgPubVenDig From RmiGrvMsgPubObj

Method New(cAssinante)	                        //Metodo construtor da Classe
Method Especificos(cPonto)              //Efetua tratamento especificos para a publicação da MHQ_MENSAG.
Method Parcelas()                       //Efetua quebra dos pagamentos (SL4) caso haja parcelas na mensagem de venda

EndClass


//-------------------------------------------------------------------
/*/{Protheus.doc} New
Método construtor da Classe

@author  Bruno Almeida
@version 1.0
/*/
//-------------------------------------------------------------------
Method New(cAssinante) Class RmiGrvMsgPubVenDig

_Super:New(cAssinante)
Self:oBuscaObj := RmiBusVenDigObj():New(cAssinante)

Return Nil

//--------------------------------------------------------
/*/{Protheus.doc} Especificos
Efetua tratamento especificos para a publicação da MHQ_MENSAG.

@type    Method
@param   cPonto, Caractere, Define o ponto onde esta sendo chamado o metodo.
@author  Rafael Tenorio da Costa
@version 1.0
@since   01/12/21   
/*/
//--------------------------------------------------------
Method Especificos(cPonto) Class RmiGrvMsgPubVenDig

    Local cProcesso := AllTrim(self:oBuscaObj:cProcesso)


    If cPonto == "FIM"

        If cProcesso == "PEDIDO"
            self:Parcelas()
        EndIf

    EndIf

    _Super:Especificos(cPonto)

Return Nil

//--------------------------------------------------------
/*/{Protheus.doc} Parcelas
Efetua quebra dos pagamentos (SL4) caso haja parcelas TEF na mensagem de venda

@author  Evandro Luiz Barbosa Pattaro
@version 1.0
@since   29/06/22 
/*/
//--------------------------------------------------------
Method Parcelas() Class RmiGrvMsgPubVenDig

    Local nPagto        := 0 
    Local nTotpg        := 0
    Local nParcelas     := 0
    Local nI            := 0
    Local nAux          := 0
    Local dDataPagto    := dDataBase
    Local nVlrPag       := 0
    Local aLj7CalcPgt   := {}
    Local cFormaPg      := ""
    Local cAdminis      := ""
    Local aNsuProc      := {}
    Local cNsu          := ""
    Local cDocTef       := ""
    Local cProcesso := AllTrim(self:oBuscaObj:cProcesso)

    If cProcesso $ "VENDA|PEDIDO" .AND. self:oBuscaObj:cEvento != "3"

        nTotpg := Len(self:oPublica["SL4"])
        
        For nPagto := 1 To nTotpg

            cFormaPg  := self:oPublica["SL4"][nPagto]["L4_FORMA"]
            nParcelas := IIF( self:oPublica["SL4"][nPagto]:HasProperty("L4_PARCTEF"), Val(self:oPublica["SL4"][nPagto]["L4_PARCTEF"]), 0 )
            cNsu      := IIF( self:oPublica["SL4"][nPagto]:HasProperty("L4_NSUTEF") , self:oPublica["SL4"][nPagto]["L4_NSUTEF"]      , "")
        
            If AllTrim(cFormaPg) $ "CC" .And. nParcelas > 1 .And. aScan( aNsuProc, {|x| x == cNsu} ) == 0

                
                dDataPagto := self:oPublica["SL4"][nPagto]["L4_DATA"]
                nVlrPag := self:oPublica["SL4"][nPagto]["L4_VALOR"]
                cAdminis := self:oPublica["SL4"][nPagto]["L4_ADMINIS"]                        
                cDocTef := self:oPublica["SL4"][nPagto]["L4_DOCTEF"]

                aLj7CalcPgt := Lj7CalcPgt( nVlrPag , "CN" , {"1- Simples",SToD(dDataPagto),0,0,nParcelas,30/*Num Dias*/,.F.,.F.},,;
                                                                    ,,,,,,,,cFormaPg,,,,,,, .T. )


                aAdd(aNsuProc,cNsu)

                For nI := 1 To nParcelas
                    
                    If nI == 1
                        nAux := nPagto
                    Else    
                        Aadd(self:oPublica["SL4"], JsonObject():New())
                        nAux := Len(self:oPublica["SL4"])
                    EndIf    
                    self:oPublica["SL4"][nAux]["L4_FILIAL"] :=  self:oPublica["L1_FILIAL"]
                    self:oPublica["SL4"][nAux]["L4_DATA"]   :=  DTOS(aLj7CalcPgt[nI][1])
                    self:oPublica["SL4"][nAux]["L4_VALOR"]  :=  aLj7CalcPgt[nI][2]
                    self:oPublica["SL4"][nAux]["L4_FORMA"]  :=  cFormaPg
                    self:oPublica["SL4"][nAux]["L4_ADMINIS"]:=  cAdminis
                    self:oPublica["SL4"][nAux]["L4_AUTORIZ"]:=  cNsu
                    self:oPublica["SL4"][nAux]["L4_NSUTEF"] :=  cNsu
                    self:oPublica["SL4"][nAux]["L4_PARCTEF"]:=  IIF(Len(aLj7CalcPgt) > 0,"1"+StrZero(nParcelas,2),"") //Tipo de Parcelamento ("0" - Estabelecimento / "1" - Administradora) + Quantidade de Parcelas
                    self:oPublica["SL4"][nAux]["L4_DOCTEF"] :=  cDocTef                      
                Next nI

            EndIf 

        Next nPagto

        aSort( self:oPublica["SL4"],,, {|a,b| a["L4_FORMA"] == b["L4_FORMA"] .And. a["L4_NSUTEF"] == b["L4_NSUTEF"] .And. a["L4_DATA"] < +b["L4_DATA"] })

    EndIf
Return Nil
