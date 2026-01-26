#include 'ubaw18.ch'
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"

Static aErros   := {}

WSRESTFUL UBAW18 DESCRIPTION "Classifica‡Æo visual/HVI"

WSMETHOD POST classification DESCRIPTION "Realiza a classifica‡Æo do algodÆo"  PATH "/v1/classification" PRODUCES APPLICATION_JSON

END WSRESTFUL

WSMETHOD POST classification WSREST UBAW18

    Local oRequest    := JsonObject():New()
    Local aErros      := {}
    Local cErro       := ""
    Local lPost       := .F.
    Local cTipoClass  := ""

    Local cMala       := "" // Mala
    Local cSafra      := "" // safra
    Local cEtiq       := "" // codigoEtiqueta
    Local cCodLab     := "" // codigoLaboratorio
    Local cNomLab     := "" // descricaoLaboratorio
    Local cNumFard    := "" // numeroFardo
    Local cClaVis     := "" // classificacaoVisual
    Local cGrAmar     := "" // grauAmarelamento
    Local cTotImp     := "" // totalImpurezas
    Local cGrCor      := "" // grauCor
    Local cQtImp      := "" // quantidadeParticulasImpurezas
    Local cIdFiab     := "" // indiceFiabilidade
    Local cAlPorc     := "" // alongamentoPorcentagem
    Local cQtFolh     := "" // quantidadeFolhasAmostra
    Local cCmpFib     := "" // comprimentoFibra
    Local cMatur      := "" // maturidade
    Local cMicron     := "" // micronaire
    Local cReflet     := "" // refletancia
    Local cPotFia     := "" // potencialFiacao
    Local cIdxFib     := "" // indiceFibrasCurtas
    Local cResRup     := "" // resistenciaRuptura
    Local cCmpPol     := "" // comprimentoPolegadas
    Local cIdxUni     := "" // indiceUniformidade
    Local cDtAtu      := "" // dataAtualizacao
    Local cUsuar      := "" // usuario
    Local cPrensa     := "" // numeroPrensa
    Local cHrReceb    := "" // hora
    Local cDtReceb    := "" // dataClassificacao

    // define o tipo de retorno do m‚todo
    ::SetContentType("application/json")

    oRequest:fromJson(::GetContent())

    cMala      := oRequest["mala"]
    cSafra     := oRequest["safra"]
    cEtiq      := oRequest["codigoEtiqueta"]
    cCodLab    := oRequest["codigoLaboratorio"]
    cNomLab    := oRequest["descricaoLaboratorio"]
    cNumFard   := oRequest["numeroFardo"]
    cClaVis    := oRequest["classificacaoVisual"]
    cGrAmar    := oRequest["grauAmarelamento"]
    cTotImp    := oRequest["totalImpurezas"]
    cGrCor     := oRequest["grauCor"]
    cQtImp     := oRequest["quantidadeParticulasImpurezas"]
    cIdFiab    := oRequest["indiceFiabilidade"]
    cAlPorc    := oRequest["alongamentoPorcentagem"]
    cQtFolh    := oRequest["quantidadeFolhasAmostra"]
    cCmpFib    := oRequest["comprimentoFibra"]
    cMatur     := oRequest["maturidade"]
    cMicron    := oRequest["micronaire"]
    cReflet    := oRequest["refletancia"]
    cPotFia    := oRequest["potencialFiacao"]
    cIdxFib    := oRequest["indiceFibrasCurtas"]
    cResRup    := oRequest["resistenciaRuptura"]
    cCmpPol    := oRequest["comprimentoPolegadas"]
    cIdxUni    := oRequest["indiceUniformidade"]
    cDtAtu     := oRequest["dataAtualizacao"]
    cUsuar     := oRequest["usuario"]
    cPrensa    := oRequest["numeroPrensa"]
    cHrReceb   := oRequest["hora"]
    cDtReceb   := oRequest["dataClassificacao"]

    cTipoClass := Iif(Empty(cNomLab),"1","2")  //1-Visual, 2-HVI

    If Empty(cMala)
        aAdd(aErros, STR0002 + cEtiq) //Mala nÆo informada para etiqueta
    Endif

    BEGIN TRANSACTION

        If Len(aErros) = 0
            // InclusÆo Classifica‡ao Visual/HVI
            aErros := UB018IncVis(cSafra, cEtiq, cMala, cClaVis, cTipoClass, cUsuar)
        Endif

        If Len(aErros) > 0
            DisarmTransaction()
        Else
            If !Empty(cNomLab)
                // InclusÆo Classifica‡ao HVI
                aErros := UB018IncHvi(cSafra, cEtiq, cCodLab, cNomLab, cNumFard, cClaVis, cGrAmar, cTotImp, cGrCor, cQtImp, cIdFiab, cAlPorc, cQtFolh, cCmpFib, cMatur, cMicron, cReflet, cPotFia, cIdxFib, cResRup, cCmpPol, cIdxUni, cDtAtu, cUsuar, cPrensa, cHrReceb, cDtReceb)

            EndIf
        EndIf

    END TRANSACTION

    If Len(aErros) > 0 .OR. !Empty(cErro)
        lPost    := .F.
        cErro    := aErros[1]

        SetRestFault(400, EncodeUTF8(cErro))
    Else
        lPost    := .T.
    EndIf

Return lPost

/**---------------------------------------------------------------------
{Protheus.doc} UB018IncVis
Classifica‡Æo Visual do algodÆo
@param: cSafra,     character, Safra
@param: cEtiq,      character, Etiqueta
@param: cMala,      character, Mala/Romaneio
@param: cClaVis,    character, Classifica‡Æo Visual
@param: cTipoClass, character, Tipo Classifica‡Æo
@param: cUsuar,     character, Usu rio
@author: Gilson Venturi
@since: 26/03/2024
---------------------------------------------------------------------**/
Function UB018IncVis(cSafra, cEtiq, cMala, cClaVis, cTipoClass, cUsuar)
    Local aArea     := GetArea()
    Local aError    := {}
    Local lOpera    := .F.
    
    cMala      := Padr(cMala,      TamSX3("DXJ_CODIGO")[1])
    cTipoClass := Padr(cTipoClass, TamSX3("DXJ_TIPO")[1])
    cSafra     := Padr(cSafra,     TamSX3("DXK_SAFRA")[1])
    cEtiq      := Padr(cEtiq,      TamSX3("DXK_ETIQ")[1])
    cNumFard   := Padr(cNumFard,   TamSX3("DXK_FARDO")[1])

    //Criar Mala caso nÆo encontre
    dbSelectArea("DXJ")
    DXJ->(dbSetOrder( 1 )) //DXJ_FILIAL+DXJ_CODIGO+DXJ_TIPO
    If !DXJ->(dbSeek(FWxFilial("DXJ") + cMala + cTipoClass ))
        If RecLock("DXJ", .T.)
            DXJ->DXJ_FILIAL  := xFilial("DXJ")
            DXJ->DXJ_SAFRA   := cSafra
            DXJ->DXJ_CODIGO  := cMala
            DXJ->DXJ_TIPO    := cTipoClass
            DXJ->DXJ_STATUS  := Iif((cTipoClass="1"),"3","6") //3-Visual Classificado, 6-HVI Importado 
            DXJ->DXJ_CODUSU  := cUsuar
            DXJ->DXJ_DATA    := dDatabase
            DXJ->DXJ_DATATU  := dDatabase
            DXJ->DXJ_HORATU  := Time()
            DXJ->(MsUnlock())
        EndIf
    Endif
    DXJ->(dbCloseArea())

    dbSelectArea("DXK")    //Itens Classifica‡Æo
    DXK->(dbSetOrder( 1 )) //DXK_FILIAL+DXK_CODROM+DXK_TIPO+DXK_SAFRA+DXK_ETIQ
    If DXK->(dbSeek(FWxFilial("DXK") + cMala + cTipoClass + cSafra + cEtiq ))
        lOpera := .F. // Altera
    Else
        lOpera := .T. // Inclui
    EndIf

    If RecLock("DXK", lOpera)
        If lOpera
            DXK->DXK_FILIAL := xFilial("DXK")
            DXK->DXK_CODROM := cMala
            DXK->DXK_TIPO   := cTipoClass
            DXK->DXK_SAFRA  := cSafra
            DXK->DXK_ETIQ   := cEtiq
            DXK->DXK_FARDO  := cNumFard
        EndIf
        
        DXK->DXK_CLAVIS := cClaVis
        DXK->DXK_CLACON := cClaVis

        DXK->(MsUnlock())
    EndIf
    DXK->(dbCloseArea())

    dbSelectArea("DXI") //Fardos
    DXI->(dbSetOrder( 1 )) //DXI_FILIAL+DXI_SAFRA+DXI_ETIQ
    If DXI->(dbSeek(FWxFilial("DXI") + cSafra + cEtiq))
        If RecLock("DXI", .F.)
           DXI->DXI_CLAVIS := cClaVis
           DXI->DXI_CLACOM := cClaVis
           DXI->DXI_DATATU := dDatabase
           DXI->DXI_HORATU := Time()
           DXI->DXI_STATUS := "20" //CLASSIFICADO
        EndIf
    Else
        aAdd(aError, STR0001 + cEtiq) //Etiqueta nÆo encontrada
    EndIf
    DXI->(dbCloseArea())

    RestArea(aArea)

Return(aError)


/*{Protheus.doc} UB018IncHvi
Classifica‡Æo HVI do algodÆo

@param cSafra,   character, safra
@param cEtiq,    character, codigoEtiqueta
@param cCodLab,  character, codigoLaboratorio
@param cNomLab,  character, descricaoLaboratorio
@param cNumFard, character, numeroFardo
@param cClaVis,  character, classificacaoVisual
@param cGrAmar,  character, grauAmarelamento
@param cTotImp,  character, totalImpurezas
@param cGrCor,   character, grauCor
@param cQtImp,   character, quantidadeParticulasImpurezas
@param cIdFiab,  character, indiceFiabilidade
@param cAlPorc,  character, alongamentoPorcentagem
@param cQtFolh,  character, quantidadeFolhasAmostra
@param cCmpFib,  character, comprimentoFibra
@param cMatur,   character, maturidade
@param cMicron,  character, micronaire
@param cReflet,  character, refletancia
@param cPotFia,  character, potencialFiacao
@param cIdxFib,  character, indiceFibrasCurtas
@param cResRup,  character, resistenciaRuptura
@param cCmpPol,  character, comprimentoPolegadas
@param cIdxUni,  character, indiceUniformidade
@param cDtAtu,   character, dataAtualizacao
@param cUsuar,   character, usuario
@param cPrensa,  character, numeroPrensa
@param cHrReceb, character, hora
@param cDtReceb, character, dataClassificacao
@author Gilson.Venturi
@since 26/03/2024
*/

Static Function UB018IncHvi(cSafra, cEtiq, cCodLab, cNomLab, cNumFard, cClaVis, cGrAmar, cTotImp, cGrCor, cQtImp, cIdFiab, cAlPorc, cQtFolh, cCmpFib, cMatur, cMicron, cReflet, cPotFia, cIdxFib, cResRup, cCmpPol, cIdxUni, cDtAtu, cUsuar, cPrensa, cHrReceb, cDtReceb)
    Local aArea  := GetArea()
    Local aError := {}
    Local lOpera := .F.

    cSafra  := Padr(cSafra,  TamSX3("DX7_SAFRA")[1])
    cEtiq   := Padr(cEtiq,   TamSX3("DX7_ETIQ")[1])
    cCodLab := Padr(cCodLab, TamSX3("DX1_CODIGO")[1])


    dbSelectArea("DX7")    //Resultados Laboratoriais
    DX7->(dbSetOrder( 2 )) //Filial + Safra + Etiqueta + Ativo
	If DX7->(dbSeek(fwxFilial("DX7") + cSafra + cEtiq + "1" ))
        lOpera := .F. // Altera
    Else
        lOpera := .T. // Inclui
    EndIf

    If RecLock("DX7", lOpera)
        If lOpera == .T.
            DX7->DX7_FILIAL := xFilial("DX7")
            DX7->DX7_SAFRA  := cSafra
            DX7->DX7_ETIQ   := cEtiq
            DX7->DX7_LAB    := cCodLab
            DX7->DX7_ATIVO  := "1"

            //Posiciona no registro do Laboratorio
            dbSelectArea('DX1')
			DX1->(dbSetOrder(1))        //DX1_FILIAL+DX1_CODIGO
            If DX1->(dbSeek(fwxFilial("DX1") + cCodLab))
			    DX7->DX7_UNI := DX1->DX1_UNI
			Endif
            DX1->(dbCloseArea())
        EndIf

        DX7->DX7_FARDO  := cNumFard
        DX7->DX7_MAISB  := val(cGrAmar)
        DX7->DX7_AREA   := Iif(!Empty(cTotImp),val(cTotImp),DX7->DX7_AREA)
        DX7->DX7_CG     := cGrCor
        DX7->DX7_COUNT  := Iif(!Empty(cQtImp), val(cQtImp), DX7->DX7_COUNT)
        DX7->DX7_CSP    := Iif(!Empty(cIdFiab),val(cIdFiab),DX7->DX7_CSP)
        DX7->DX7_ELONG  := Iif(!Empty(cAlPorc),val(cAlPorc),DX7->DX7_ELONG)
        DX7->DX7_LEAF   := Iif(!Empty(cQtFolh),val(cQtFolh),DX7->DX7_LEAF)
        DX7->DX7_UHM    := Iif(!Empty(cCmpFib),val(cCmpFib),DX7->DX7_UHM)
        DX7->DX7_MATU   := Iif(!Empty(cMatur), val(cMatur), DX7->DX7_MATU)
        DX7->DX7_MIC    := Iif(!Empty(cMicron),val(cMicron),DX7->DX7_MIC)
        DX7->DX7_RD     := Iif(!Empty(cReflet),val(cReflet),DX7->DX7_RD)
        DX7->DX7_SCI    := Iif(!Empty(cPotFia),val(cPotFia),DX7->DX7_SCI)
        DX7->DX7_SFI    := Iif(!Empty(cIdxFib),val(cIdxFib),DX7->DX7_SFI)
        DX7->DX7_RES    := Iif(!Empty(cResRup),val(cResRup),DX7->DX7_RES)
        DX7->DX7_FIBRA  := Iif(!Empty(cCmpPol),val(cCmpPol),DX7->DX7_FIBRA)
        DX7->DX7_UI     := Iif(!Empty(cIdxUni),val(cIdxUni),DX7->DX7_UI)
        DX7->DX7_PRENSA := cPrensa
        DX7->DX7_USUATU := cUsuar
        DX7->DX7_DATU   := dDataBase
        DX7->DX7_DATREC := dDataBase
        DX7->DX7_HORREC := Substr( Time(), 1, 5 )

    EndIf

    DX7->(dbCloseArea())

    RestArea(aArea)

Return(aError)
