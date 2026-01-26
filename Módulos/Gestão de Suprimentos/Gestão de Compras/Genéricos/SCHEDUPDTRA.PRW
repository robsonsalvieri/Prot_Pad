#Include "Protheus.ch"

//-----------------------------------------------------------------
/*/{Protheus.doc} SCHEDUPDTRA
Execucao do processo de leitura dos arquivos recebidos via TOTVS Colaboração 2.0.

@author  Rafael Iaquinto
@since   24/07/2014
@version 11.8
/*/
//-----------------------------------------------------------------
Function SCHEDUPDTRA(aParam) 

Local oComTransmite    := Nil
Local lImpXML       := SuperGetMv("MV_IMPXML",.F.,.F.) .And. CKO->(FieldPos("CKO_ARQXML")) > 0 .And. !Empty(CKO->(IndexKey(5)))
Local cTraCID       := SuperGetMv("MV_XMLCID",.F.,"")
Local cTraCSEC      := SuperGetMv("MV_XMLCSEC",.F.,"") 

If lImpXML .And. !Empty(cTraCID) .And. !Empty(cTraCSEC)
    oComTransmite := ComTransmite():New()

    If oComTransmite:TokenTotvsTransmite() 
        //Atualiza Status
        oComTransmite:UpdStatus()

        If oComTransmite:lIntGfe //Integração com GFE
            //Atualiza Status de Documentos GFE
            oComTransmite:UpdGFEStatus()
        Endif
    Endif
Endif 
		
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} SchedDef
Retorna as perguntas definidas no schedule.

@return aReturn			Array com os parametros

@author  Rafael Iaquinto
@since   24/07/2014
@version 12
/*/
//-------------------------------------------------------------------

Static Function SchedDef()

Local aParam  := {}

aParam := { "P",;	//Tipo R para relatorio P para processo
            "",;	//Pergunte do relatorio, caso nao use passar ParamDef
            ,;		//Alias
            ,;		//Array de ordens
            }		//Titulo

Return aParam
