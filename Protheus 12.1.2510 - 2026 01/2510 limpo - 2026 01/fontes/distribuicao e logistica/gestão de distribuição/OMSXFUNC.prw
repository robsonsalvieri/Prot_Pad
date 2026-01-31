#include "protheus.ch"
#include "FWMVCDEF.CH"
#include "OMSXFUNC.CH"

#DEFINE NDOCEND_END    01
#DEFINE NDOCEND_BAIRRO 02
#DEFINE NDOCEND_CEP    03
#DEFINE NDOCEND_MUN    04
#DEFINE NDOCEND_EST    05
#DEFINE NDOCEND_CODIGO 06
#DEFINE NDOCEND_LOJA   07
#DEFINE NDOCEND_NREDUZ 08
#DEFINE NDOCEND_NOME   09
#DEFINE NDOCEND_CGC    10
#DEFINE NDOCEND_PESSOA 11
#DEFINE NDOCEND_PAIS   12
#DEFINE NDOCEND_TEL    13
#DEFINE NDOCEND_ALIAS  14
#DEFINE NDOCEND_LENVET 14

Static lIntRot := SC6->(ColumnPos("C6_INTROT")) > 0
Static lExistDK5 := TableInDic('DK5')
Static cImagem := MaEntImage( "DAI", 1 )
Static cSeekPed := ""

/*
    Fonte que agrupa funções referente ao tracker de pedidos
*/

/*/{Protheus.doc} OMSTracker
Apresenta no tracker de pedidos as ações realizadas pelo OMS, tais como:
- Pedido integrado com o Cockpit Logístico
- Viagem gerada pelo Cockpit Logístico
- Carga gerada
- Carga monitorada
@type  Function
@author amanda.vieira
@since 01/06/2020
@param oTree, object, objeto do tipo DbTree
@param cNumPed, string, informação do número do pedido e item do pedido
@param cTreeID, string, id do nó da árvore de apresentação
@param nLevel, number, nível atual da árvore de apresentação
@param nMaxLevel, number, nível máximo suportado pela árvore de apresentação
@return sem retorno
/*/
Function OMSTracker(oTree,cNumPed,cTreeID,nLevel,nMaxLevel)
Default nMaxLevel := 1000000
Default cTreeID   := "000001"

    //Garante o posicionamento da SC6
    If !((SC6->C6_NUM+SC6->C6_ITEM) == cNumPed)
        SC6->(DbSetOrder(1))
        SC6->(DbSeek(xFilial("SC6")+cNumPed))
    EndIf

    //Seek da linha do pedido
    cSeekPed := Pad( "SC6-" + cNumPed, 50 )+cTreeID

    //Apresenta no tracker se pedido foi integrado com o cockpit logístico
    OmsTrckInt(oTree,cTreeID,@nLevel,nMaxLevel)
    //Apresenta no tracker se pedido possuí viagem gerada pelo cockpit logístico
    OmsTrckDK0(oTree,cTreeID,@nLevel,nMaxLevel)
    //Apresenta no tracker se pedido possuí carga gerada
    OmsTrckDAI(oTree,cTreeID,@nLevel,nMaxLevel)
    //Apresenta no tracker se pedido possuí carga monitorada pelo cockpit logístico
    OmsTrckMon(oTree,cTreeID,@nLevel,nMaxLevel)

Return
/*/{Protheus.doc} OmsTrckInt
Apresenta no tracker a informação que o pedido encontra-se integrado com o Cockpit Logístico.
@type  Function
@author amanda.vieira
@since 01/06/2020
@param oTree, object, objeto do tipo DbTree
@param cTreeID, string, id do nó da árvore de apresentação
@param nLevel, number, nível atual da árvore de apresentação
@param nMaxLevel, number, nível máximo suportado pela árvore de apresentação
@return sem retorno
/*/
Static Function OmsTrckInt(oTree,cTreeID,nLevel,nMaxLevel)
Local cTexto := ""
Local cChave := ""
    If lIntRot .And. !Empty(SC6->C6_INTROT) .And. !(SC6->C6_INTROT == "1")
        cTexto := STR0001 //Pedido / Item integrado com Cockpit Logístico
        cChave := "OMS-CPL-" + SC6->C6_NUM + SC6->C6_FILIAL + SC6->C6_ITEM + cTreeID
        AddItemTree(oTree,cTexto,cChave,@nLevel,nMaxLevel)
    EndIf
Return
/*/{Protheus.doc} OmsTrckDK0
Apresenta no tracker a informação qual viagem foi gerada pelo Cockpit Logístico.
@type  Function
@author amanda.vieira
@since 01/06/2020
@param oTree, object, objeto do tipo DbTree
@param cTreeID, string, id do nó da árvore de apresentação
@param nLevel, number, nível atual da árvore de apresentação
@param nMaxLevel, number, nível máximo suportado pela árvore de apresentação
@return sem retorno
/*/
Static Function OmsTrckDK0(oTree,cTreeID,nLevel,nMaxLevel)
Local cAliasDK1 := GetNextAlias()
Local cTexto    := ""
Local cChave    := ""
    BeginSql Alias cAliasDK1
        SELECT DISTINCT DK1.DK1_REGID,
                        DK1.DK1_VIAGID
          FROM %Table:DK1% DK1
         INNER JOIN %Table:DK0% DK0
            ON DK0.DK0_FILIAL = %xFilial:DK0%
           AND DK0.DK0_REGID = DK1.DK1_REGID
           AND DK0.DK0_VIAGID = DK1.DK1_VIAGID
           AND DK0.DK0_SITINT IN ('0','1','2')
           AND DK0.%NotDel%
         WHERE DK1.DK1_FILIAL = %xFilial:DK1%
           AND DK1.DK1_FILPED = %Exp:SC6->C6_FILIAL%
           AND DK1.DK1_PEDIDO = %Exp:SC6->C6_NUM%
           AND DK1.DK1_ITEMPE = %Exp:SC6->C6_ITEM%
           AND DK1.%Notdel%
    EndSql
    While (cAliasDK1)->(!EoF())
        cTexto := STR0002+(cAliasDK1)->DK1_VIAGID //Viagem Cockpit Logístico
        cChave := "OMS-DK1-" + (cAliasDK1)->DK1_REGID + (cAliasDK1)->DK1_VIAGID + SC6->C6_NUM + SC6->C6_FILIAL + SC6->C6_ITEM + cTreeID
        AddItemTree(oTree,cTexto,cChave,@nLevel,nMaxLevel)
        (cAliasDK1)->(DbSkip())
    EndDo
    (cAliasDK1)->(DbCloseArea())
Return
/*/{Protheus.doc} OmsTrckDAI
Apresenta no tracker a informação qual carga foi gerada pelo OMS.
@type  Function
@author amanda.vieira
@since 01/06/2020
@param oTree, object, objeto do tipo DbTree
@param cTreeID, string, id do nó da árvore de apresentação
@param nLevel, number, nível atual da árvore de apresentação
@param nMaxLevel, number, nível máximo suportado pela árvore de apresentação
@return sem retorno
/*/
Static Function OmsTrckDAI(oTree,cTreeID,nLevel,nMaxLevel,aTree)
Local cAliasSC9 := GetNextAlias()
Local cTexto    := ""
Local cChave    := ""
Local cItCarga  := ""
	BeginSql Alias cAliasSC9
		SELECT DISTINCT SC9.C9_CARGA, 
			            SC9.C9_SEQCAR
		  FROM %Table:SC9% SC9
		 WHERE SC9.C9_FILIAL = %xFilial:SC9%
		   AND SC9.C9_PEDIDO = %Exp:SC6->C6_NUM%
		   AND SC9.C9_ITEM = %Exp:SC6->C6_ITEM%
		   AND SC9.C9_PRODUTO = %Exp:SC6->C6_PRODUTO%
		   AND SC9.C9_CARGA <> ' '
		   AND SC9.C9_SEQCAR <> ' '
		   AND SC9.%NotDel%
	EndSql
	While (cAliasSC9)->(!Eof())
        cItCarga  := (cAliasSC9)->C9_CARGA + (cAliasSC9)->C9_SEQCAR + SC6->C6_NUM + SC6->C6_FILIAL            
        cTexto    := Pad( STR0003 + Transform( (cAliasSC9)->C9_CARGA+(cAliasSC9)->C9_SEQCAR, "@R 999999/99" ),100) // Carga / Seq.Carga
        cChave    := Pad( "OMS-DAI-" + cItCarga, 50 )+ cTreeID
        AddItemTree(oTree,cTexto,cChave,@nLevel,nMaxLevel)
		(cAliasSC9)->( dbSkip() )
	EndDo
	(cAliasSC9)->(DbCloseArea())
Return
/*/{Protheus.doc} OmsTrckMon
Apresenta no tracker a informação que a carga encontra-se monitorada pelo Cockpit Logístico.
@type  Function
@author amanda.vieira
@since 01/06/2020
@param oTree, object, objeto do tipo DbTree
@param cTreeID, string, id do nó da árvore de apresentação
@param nLevel, number, nível atual da árvore de apresentação
@param nMaxLevel, number, nível máximo suportado pela árvore de apresentação
@return sem retorno
/*/
Static Function OmsTrckMon(oTree,cTreeID,nLevel,nMaxLevel)
Local cAliasQry := ""
    If lExistDK5
        cAliasQry := GetNextAlias()
        BeginSql Alias cAliasQry
            SELECT SC9.C9_CARGA,
                   SC9.C9_SEQCAR
              FROM %Table:SC9% SC9
             INNER JOIN %Table:DK5% DK5
                ON DK5.DK5_FILIAL = %xFilial:DK5%
               AND DK5.DK5_CARGA = SC9.C9_CARGA
               AND DK5.DK5_SEQCAR = SC9.C9_SEQCAR
               AND DK5.DK5_STATUS = '1'
               AND DK5.%NotDel%
             WHERE SC9.C9_FILIAL = %xFilial:SC9%
		       AND SC9.C9_PEDIDO = %Exp:SC6->C6_NUM%
		       AND SC9.C9_ITEM = %Exp:SC6->C6_ITEM%
		       AND SC9.C9_PRODUTO = %Exp:SC6->C6_PRODUTO%
		       AND SC9.C9_CARGA <> ' '
		       AND SC9.C9_SEQCAR <> ' '
		       AND SC9.%NotDel% 
        EndSql
        If (cAliasQry)->(!EoF())
            cTexto := STR0004 // Carga monitorada pelo Cockpit Logístico
            cChave := "OMS-DK5-" + (cAliasQry)->C9_CARGA +  (cAliasQry)->C9_SEQCAR + SC6->C6_NUM + SC6->C6_FILIAL + SC6->C6_ITEM + cTreeID
            AddItemTree(oTree,cTexto,cChave,@nLevel,nMaxLevel)
        EndIf
        (cAliasQry)->(DbCloseArea())
    EndIf
Return
/*/{Protheus.doc} AddItemTree
Adiciona item à árvore.
@type  Function
@author amanda.vieira
@since 01/06/2020
@param oTree, object, objeto do tipo DbTree
@param cTreeID, string, id do nó da árvore de apresentação
@param nLevel, number, nível atual da árvore de apresentação
@param nMaxLevel, number, nível máximo suportado pela árvore de apresentação
@return sem retorno
/*/
Static Function AddItemTree(oTree,cTexto,cChave,nLevel,nMaxLevel)
    nLevel++
    If nLevel <= nMaxLevel
        oTree:TreeSeek( cSeekPed )
	    oTree:AddItem( cTexto, cChave, cImagem, cImagem ,,,nLevel)
	    oTree:TreeSeek( cChave )
    EndIf
    nLevel--
Return
/*/{Protheus.doc} OmsPreView
Realiza visualização do item da árvore
@type  Function
@author amanda.vieira
@since 01/06/2020
@param cChave, string, chave de pesquisa da árvore
@return sem retorno
/*/
Function OmsPreView(cChave)
Local cTabela := Substr( cChave, 5, 3 )
    If (cTabela == "DAI" .Or. cTabela == "DK5")
        ViewCarga(cChave)
    ElseIf (cTabela == "DK1")
        ViewViagem(cChave)
    ElseIf (cTabela == "CPL")
        ViewPedido(cChave)
    EndIf
Return
/*/{Protheus.doc} ViewCarga
Realiza abertura da rotina para visualização da carga
@type  Function
@author amanda.vieira
@since 01/06/2020
@param cChave, string, chave de pesquisa da árvore
@return sem retorno
/*/
Static Function ViewCarga(cChave)
    Local aArea   := GetArea()
    Local nTamCod := TamSX3("DAK_COD")[1]
    Local nTamSeq := TamSX3("DAK_SEQCAR")[1]
    Local nTamNum := TamSX3("C6_NUM")[1]
    Local nTamFil := TamSX3("C6_FILIAL")[1]
    Local cCarga  := Substr(cChave, 9, nTamCod)
    Local cSeqCar := Substr(cChave, 9 + nTamCod, nTamSeq)
    Local cNumPed := Substr(cChave, 9 + nTamCod + nTamSeq, nTamNum)
    Local cFilPed := Substr(cChave, 9 + nTamCod + nTamSeq + nTamNum, nTamFil)
    Local cFilOpe := SuperGetMV("MV_APDLFOP",,"")
    Local cFilDAK := FWxFilial("DAK",cFilOpe)
    Local cFilBkp := cFilAnt
    Local cAliasDAK := GetNextAlias()

    BeginSql Alias cAliasDAK
        SELECT DAK.R_E_C_N_O_ RECNODAK 
          FROM %Table:DAK% DAK
         INNER JOIN %Table:DAI% DAI
            ON DAI.DAI_FILIAL  = DAK.DAK_FILIAL
            AND DAI.DAI_COD    = DAK.DAK_COD
            AND DAI.DAI_SEQCAR = DAK.DAK_SEQCAR
            AND DAI.DAI_FILPV  = %Exp:cFilPed%
            AND DAI.DAI_PEDIDO = %Exp:cNumPed%
            AND DAI.%NotDel%
        WHERE DAK.DAK_FILIAL  IN (%xFilial:DAK%,%Exp:cFilDAK%)
            AND DAK.DAK_COD    = %Exp:cCarga%
            AND DAK.DAK_SEQCAR = %Exp:cSeqCar%
            AND DAK.%NotDel%
    EndSql

    If (cAliasDAK)->(!EoF())
        If Type( "cCadastro" ) == "C"
            cCadastro := STR0006 //Montagem de Carga - Visualizar
        EndIf
        DAK->(DbGoto((cAliasDAK)->RECNODAK))
        If cFilAnt != DAK->DAK_FILIAL
            cFilAnt := cFilOpe
        EndIf
        Os200Visual("DAK",DAK->(Recno()),2)
    EndIf
    (cAliasDAK)->(DbCloseArea())
    cFilAnt := cFilBkp
    RestArea(aArea)

Return
/*/{Protheus.doc} ViewViagem
Realiza abertura da rotina para visualização da viagem
@type  Function
@author amanda.vieira
@since 01/06/2020
@param cChave, string, chave de pesquisa da árvore
@return sem retorno
/*/
Static Function ViewViagem(cChave)
Local nTamRegId := TamSX3("DK0_REGID")[1]
Local nTamViag  := TamSX3("DK0_VIAGID")[1]
Local cRegId    := Substr(cChave, 9, nTamRegId)
Local cViagId   := Substr(cChave, 9+nTamRegId, nTamViag)
Local cAliasDK0 := GetNextAlias()
    BeginSql Alias cAliasDK0
        SELECT R_E_C_N_O_ RECNODK0
          FROM %Table:DK0% DK0
         WHERE DK0.DK0_FILIAL = %xFilial:DK0%
           AND DK0.DK0_REGID = %Exp:cRegId%
           AND DK0.DK0_VIAGID = %Exp:cViagId%
           AND DK0.%NotDel%
    EndSql
    If (cAliasDK0)->(!EoF())
        DK0->(DbGoTo((cAliasDK0)->RECNODK0))
		FWExecView(STR0005,"OMSXCPL7", MODEL_OPERATION_VIEW ,, { || .T. } ,, ) // Visualização Viagem
    EndIf
    (cAliasDK0)->(DbCloseArea())
Return
/*/{Protheus.doc} ViewPedido
Realiza abertura da rotina para visualização do pedido
@type  Function
@author amanda.vieira
@since 01/06/2020
@param cChave, string, chave de pesquisa da árvore
@return sem retorno
/*/
Static Function ViewPedido(cChave)
Local nTamPed   := TamSX3("C5_NUM")[1]
Local cNumPed   := Substr(cChave, 9, nTamPed)
Local cAliasSC5 := GetNextAlias()
    BeginSql Alias cAliasSC5
        SELECT R_E_C_N_O_ RECNOSC5
          FROM %Table:SC5% SC5
         WHERE SC5.C5_FILIAL = %xFilial:SC5%
           AND SC5.C5_NUM = %Exp:cNumPed%
           AND SC5.%NotDel%
    EndSql
    If (cAliasSC5)->(!EoF())
        SC5->(DbGoTo((cAliasSC5)->RECNOSC5))
        MaMakeView("SC5")
    EndIf
    (cAliasSC5)->(DbCloseArea())
Return

/*{Protheus.doc} OMSDocEnd
Busca endereço de documento de carga
Seguindo a regra do documento.
@author Valdemar Roberto Mognon
@since 29/08/2022
*/

Function OMSDocEnd(cFilPv, cNumNFc, cSerNFc)
Local aAreas   := {SF2->(GetArea()),SA1->(GetArea()),GetArea()}
Local aRet     := {Array(NDOCEND_LENVET),Array(NDOCEND_LENVET)}
Local aSM0Data := {}
Local cRotCep  := SuperGetMv("MV_ROTCEP",.F.,"1")

Default cFilPv  := FwxFilial("DAI")
Default cNumNFC := ""
Default cSerNFc := ""


SF2->(DbSetOrder(1))//F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
If SF2->(MsSeek(cFilPv + cNumNFc + cSerNFc))
	
	//-- Origem
	aSM0Data := FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{"M0_CGC","M0_NOMECOM","M0_NOME","M0_ENDENT","M0_COMPENT","M0_BAIRENT","M0_CIDENT","M0_ESTENT","M0_CEPENT","M0_TEL"})
    aRet[1,NDOCEND_CODIGO] := Space(Len(SA1->A1_COD))
    aRet[1,NDOCEND_LOJA]   := Space(Len(SA1->A1_LOJA))
    aRet[1,NDOCEND_NREDUZ] := aSM0Data[3,2]
    aRet[1,NDOCEND_NOME]   := aSM0Data[2,2]
    aRet[1,NDOCEND_CGC]    := aSM0Data[1,2]
    aRet[1,NDOCEND_PESSOA] := "J"
    aRet[1,NDOCEND_PAIS]   := {"BR","BRASIL"}
    aRet[1,NDOCEND_END]    := aSM0Data[4,2]
    aRet[1,NDOCEND_BAIRRO] := aSM0Data[6,2]
    aRet[1,NDOCEND_CEP]    := Left(aSM0Data[9][2],5) + "-" + Right(aSM0Data[9][2],3)
    aRet[1,NDOCEND_MUN]    := aSM0Data[7,2]
    aRet[1,NDOCEND_EST]    := aSM0Data[8,2]
    aRet[1,NDOCEND_TEL]    := aSM0Data[10,2]
	aRet[1,NDOCEND_ALIAS ] := "SM0"

    FWFreeArray(aSM0Data)

	//-- Destino
	If SA1->(DbSeek(xFilial("SA1") + SF2->(F2_CLIENTE + F2_LOJA)))
		aRet[2,NDOCEND_CODIGO] := SA1->A1_COD
		aRet[2,NDOCEND_LOJA]   := SA1->A1_LOJA
		aRet[2,NDOCEND_NREDUZ] := AllTrim(SA1->A1_NREDUZ)
		aRet[2,NDOCEND_NOME]   := AllTrim(SA1->A1_NOME)
		aRet[2,NDOCEND_CGC]    := AllTrim(SA1->A1_CGC)
		aRet[2,NDOCEND_PESSOA] := SA1->A1_PESSOA
		aRet[2,NDOCEND_PAIS]   := { AllTrim(Posicione("SYA",1,xFilial("SYA")+SA1->A1_PAIS,"YA_SIGLA")), AllTrim(SYA->YA_DESCR) }
        Do Case
            Case cRotCep == "1" // Endereço Principal do Cadastro de Cliente
                aRet[2,NDOCEND_END]    := AllTrim(SA1->A1_END)
                aRet[2,NDOCEND_BAIRRO] := AllTrim(SA1->A1_BAIRRO)
                aRet[2,NDOCEND_CEP]    := AllTrim(SA1->A1_CEP)
                aRet[2,NDOCEND_MUN]    := AllTrim(SA1->A1_MUN)
                aRet[2,NDOCEND_EST]    := AllTrim(SA1->A1_EST)
            Case cRotCep == "2" // CEP de Entrega se preenchido senão CEP principal. 
                aRet[2,NDOCEND_END]    := Iif(!Empty(SA1->A1_ENDENT), AllTrim(SA1->A1_ENDENT), AllTrim(SA1->A1_END))
                aRet[2,NDOCEND_BAIRRO] := Iif(!Empty(SA1->A1_BAIRROE), AllTrim(SA1->A1_BAIRROE), AllTrim(SA1->A1_BAIRRO))
                aRet[2,NDOCEND_CEP]    := Iif(!Empty(SA1->A1_CEPE), AllTrim(SA1->A1_CEPE), AllTrim(SA1->A1_CEP))
                aRet[2,NDOCEND_MUN]    := Iif(!Empty(SA1->A1_MUNE), AllTrim(SA1->A1_MUNE), AllTrim(SA1->A1_MUN))
                aRet[2,NDOCEND_EST]    := Iif(!Empty(SA1->A1_ESTE), AllTrim(SA1->A1_ESTE), AllTrim(SA1->A1_EST))
            Case cRotCep == "3" // Somente CEP de entrega. 
                aRet[2,NDOCEND_END]    := AllTrim(SA1->A1_ENDENT)
                aRet[2,NDOCEND_BAIRRO] := AllTrim(SA1->A1_BAIRROE)
                aRet[2,NDOCEND_CEP]    := AllTrim(SA1->A1_CEPE)
                aRet[2,NDOCEND_MUN]    := AllTrim(SA1->A1_MUNE)
                aRet[2,NDOCEND_EST]    := AllTrim(SA1->A1_ESTE)
        EndCase
        aRet[2,NDOCEND_TEL]    := AllTrim(Iif(!Empty(SA1->A1_DDD),"("+AllTrim(SA1->A1_DDD)+")","")+SA1->A1_TEL)
		aRet[2,NDOCEND_ALIAS ] := "SA1"

	EndIf
EndIf

aEval(aAreas,{|xArea| RestArea(xArea)})

Return aRet

//---------------------------------------------------------------------
/*/{Protheus.doc} OMSMsgRelD
@type			function
@description	Painel referente a exibição de mensagem de descontinuidade de relatórios.
@author			Felipe Barbiere
@since			21/05/2025
@param			lForceShow	-	Indica se o Painel obrigatoriamente deve ser exibido
/*/
//---------------------------------------------------------------------
Function OMSMsgRelD()

Local oProfile		:=	Nil
Local oDialog		:=	Nil
Local oCheck		:=	Nil
Local cRetProf		:=	""
Local nHeightBox	:=	0
Local nWidthBox		:=	0
Local nHeight		:=	300
Local nWidth		:=	500
Local nPosIni		:=	0
Local lCheck		:=	.F.
Local lRet			:=	.F.
Local bClose		:=	{ || }
Local bBlocMsg := {|| ShellExecute( "Open", "https://tdn.totvs.com/pages/viewpage.action?pageId=933155698", "", "C:\", 1 )}

bClose := { || ( SetProfile( oProfile, lCheck ), oDialog:End() ) }

oProfile := FWProfile():New()
oProfile:SetUser( __cUserID )
oProfile:SetProgram( "OMSR020" )
oProfile:SetTask( "SIGAOMS" )
oProfile:Load()

cRetProf := oProfile:GetStringProfile()

If Empty( cRetProf ) .or. DateDiffDay( Date(), SToD( cRetProf ) ) >= 15
	lRet := .T.
EndIf

If lRet
	oDialog := MsDialog():New( 0, 0, nHeight, nWidth, STR0007,,,,,,,,, .T. ) //"Novos relatórios Smart View"

	nHeightBox := ( nHeight - 60 ) / 2
	nWidthBox := ( nWidth - 20 ) / 2

	@ 25,03 SAY oSay1 PROMPT STR0008  + CHR(13) + ; //"Conforme documentação anexa, os relatórios relacionados serão substituídos a partir do release " 
							STR0009 + CHR(13) + ; //" 12.1.2510, sendo definitivamente descontinuados no release 12.1.2610. Recomendamos que seja "
						    STR0010 SIZE 290, 200 OF oDialog PIXEL //" realizada a migração para a nova tecnologia de relatórios em Smart View o quanto antes."
							

	@ 65,05 SAY oSay2 PROMPT "https://tdn.totvs.com/pages/viewpage.action?pageId=933155698" SIZE 200, 200 COLORS CLR_BLUE OF oDialog PIXEL 
	oSay2:bLClicked := bBlocMsg

    oCheck := TCheckBox():New( nHeightBox + 10, 10, STR0011, {|u| If(PCount()>0,lCheck:=u,lCheck)}, oDialog, 500, 010,,,,,,,, .T. ) //"Não exibir pelos próximos 15 dias."

    nPosIni := ( ( nWidth - 20 ) / 2 ) - 52
	TButton():New( nHeightBox + 10, nPosIni, STR0012, oDialog, bClose, 50, 15,,,, .T. ) // "Fechar"

	oDialog:Activate( ,,,.T. )
EndIf

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} SetProfile
@type			function
@description	Atualiza o arquivo de profile da SIGAOMS.
@author			Felipe M. Barbiere
@since			21/05/2025
@param			oProfile	-	Objeto referente ao arquivo de profile
@param			lCheck		-	Indica se a opção para não exibir nos próximos 7 dias foi marcada
/*/
//---------------------------------------------------------------------
Static Function SetProfile( oProfile, lCheck )

Local cSetting	:=	""

If lCheck
    cSetting := DToS( Date() )
EndIf

oProfile:SetStringProfile( cSetting )
oProfile:Save()

Return()
