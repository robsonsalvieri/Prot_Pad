#INCLUDE "TOTVS.CH"
#INCLUDE "hatActions.ch"


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PEHatBC4
    Classe abstrata para execução de comandos
    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Class PEHatBC4 From PEHatGener

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
Method New() Class PEHatBC4

    Default cPedido := ''
    
    _Super:New()
    self:cNodePrinc := 'providers'
    self:aNodeKey   := {'healthProviderCode'}

Return self


//-------------------------------------------------------------------
/*/{Protheus.doc} retDadBC4
Retorna array com dados do bloqueio/desbloqueio de prestadores

@author  Renan Sakai
@version P12
@since    05.10.18
/*/
//-------------------------------------------------------------------
Method retDadJson() Class PEHatBC4

	Local lRet := .F.
	Local aRet := {}
	Local aMap := PLHATMap("BC4")
	Local nX   := 0

	BC4->(DbSetOrder(2))//BC4_FILIAL+BC4_CODCRE+BC4_TIPO+BC4_DATA+BC4_HORA
	BAU->(DbSetOrder(1))//BAU_FILIAL+BAU_CODIGO
	if BC4->(MsSeek(xFilial('BC4')+self:cChaveBNV)) .And. BAU->(MsSeek(xFilial("BAU")+BC4->BC4_CODCRE))

		for nX := 1 to len(aMap)
			Aadd(aRet,{aMap[nX,1],;
				aMap[nX,2],;
				&(Substr(aMap[nX,2],1,3)+"->("+aMap[nX,2]+")"),;
				aMap[nX,3]})

			//De/para de informacao escrita para bloqueio/desbloqueio
			if aRet[nX][1] == "eventType"
				if aRet[nX][3] == "0"
					aRet[nX][3] := "bloqueio"
				else
					aRet[nX][3] := "desbloqueio"
				endif
			endif
		next

		lRet := .T.
	endIf
	aRet := self:ajustType(aRet)

Return {lRet,aRet}