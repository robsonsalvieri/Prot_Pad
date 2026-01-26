#INCLUDE "TOTVS.CH"
#INCLUDE "hatActions.ch"


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PEHatBCA
    Classe abstrata para execução de comandos
    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Class PEHatBCA From PEHatGener

	Method New()
    Method retDadJson()
	
EndClass


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} New
    Metodo construtor da classe proGuiaAPI
    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method New() Class PEHatBCA

    Default cPedido := ''
    
    _Super:New()
    self:cNodePrinc := 'items'
    self:aNodeKey   := {'subscriberId'}

Return self

//-------------------------------------------------------------------
/*/{Protheus.doc} retDadJson
Retorna array com dados do bloqueio/desbloqueio de beneficiarios

@author  Renan Sakai
@version P12
@since    17.10.23
/*/
//-------------------------------------------------------------------
Method retDadJson() Class PEHatBCA

    Local lRet := .F.
    Local aMap := PLHATMap("BCA")
    Local aRet := {}
    Local nX := 0

    BCA->(DbSetOrder(1))//BCA_FILIAL+BCA_MATRIC+BCA_TIPREG+BCA_DATA+BCA_TIPO
    if BCA->(DbSeek(xFilial('BCA')+self:cChaveBNV))

        for nX := 1 to len(aMap)

            Aadd(aRet,{aMap[nX,1],;
                aMap[nX,2],;
                &(Substr(aMap[nX,2],1,3)+"->("+aMap[nX,2]+")"),;
                aMap[nX,3]})

            //De/para de informacao escrita para bloqueio/desbloqueio
            if aRet[nX][1] == "eventType"
                aRet[nX][3] := iif(aRet[nX][3] == "0","bloqueio","desbloqueio")
            endif
        next

        lRet := .T.
    endIf
    aRet := self:ajustType(aRet)

Return {lRet,aRet}