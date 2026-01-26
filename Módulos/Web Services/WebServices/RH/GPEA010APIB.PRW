#INCLUDE "TOTVS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "GPEA010APIB.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "FWAdapterEAI.ch"
#Include "topconn.ch"

#DEFINE URL_DEF			"https://tdn.totvs.com/pages/viewpage.action?pageId=770940595"
#DEFINE ERRORCODE_DEF	400
#DEFINE ERRORSRV_DEF	500
#DEFINE PAGESIZE_DEF	2000
#DEFINE CRLF  			CHR ( 13 ) + CHR ( 10 )

Static aBkpDeptos		:= {}

WSRESTFUL employeesManagerDataContent DESCRIPTION OEMToAnsi(STR0001) SECURITY 'GPEA010' FORMAT "application/json"//"Serviço genérico para retorno das informações do líder direto dos empregados do Protheus."

WSDATA page			            As Integer Optional
WSDATA pageSize		            As Integer Optional
WSDATA companyId	            As String
WSDATA branchId	                As String
WSDATA employeeCode             As String Optional
WSDATA employeeCostCenterCode   As String Optional
WSDATA visionCode               As String Optional
WSDATA managerChangeDate        As String Optional

WSMETHOD GET DESCRIPTION OEMToAnsi(STR0002) PRODUCES APPLICATION_JSON WSSYNTAX "rh/v1/employeesManagerDataContent/" PATH "rh/v1/employeesManagerDataContent/" TTALK "v1"//"Exemplo de retorno"

END WSRESTFUL

WSMETHOD GET QUERYPARAM page, pageSize, companyId, branchId, employeeCode, employeeCostCenterCode, visionCode, managerChangeDate WSSERVICE employeesManagerDataContent 

Local cBranchId  	        := ""
Local cCompId 	 	        := ""
Local cFuncCCCod 	        := ""
Local cFuncCod 	 	        := ""
Local cVisionCode 	        := ""
Local cDtChange             := ""
Local lRet 			        := .T.
Local nPage 	 	        := 0
Local nPageSize  	        := 0
Local oJsonRet	            := JsonObject():New()
Local dDtChange             := CtoD("//")
Local cEmpAntBck := cEmpAnt
Local cFilAntBck := cFilAnt

Private bError              := { |e| oError := e, Break(e) }
Private bErrorBlock         := ErrorBlock( bError )
Private oError

DEFAULT Self:page 			            := 1
DEFAULT Self:pageSize 		            := PAGESIZE_DEF
DEFAULT Self:companyId 		            := ""
DEFAULT Self:branchId 		            := ""
DEFAULT Self:employeeCode 	            := ""
DEFAULT Self:employeeCostCenterCode 	:= ""
DEFAULT Self:visionCode 	            := ""
DEFAULT Self:managerChangeDate 	        := ""

BEGIN SEQUENCE
    nPage 	                := Self:page
    nPageSize               := Self:pageSize
    cCompId                 := Self:companyId
    cBranchId               := Self:branchId
    cFuncCod                := Self:employeeCode
    cFuncCCCod              := Self:employeeCostCenterCode
    cVisionCode             := Self:visionCode
    cDtChange               := Self:managerChangeDate

    If !fPreValid( @oJsonRet, cCompId, cBranchId )
        lRet := .F.
    EndIf

    If !Empty(cDtChange) .And. !fVldData(@oJsonRet, cDtChange, @dDtChange)
        lRet := .F.
    EndIf

    If lRet
        fSetErrorHandler( EncodeUTF8( STR0003 ) )//"Erro ao preparar o ambiente com a Empresa e Filial informados!"

        If nPageSize < 1 .Or. nPageSize > PAGESIZE_DEF
            nPageSize := PAGESIZE_DEF
        EndIf

        If nPage < 1
            nPage := 1
        EndIf

        If lRet
            If cEmpAntBck <> cCompId .Or. cFilAntBck <> cBranchId
                fTrGrpGPE(cCompId, cBranchId, "SRA,SQB,CTT", "GPE")
            EndIf

            lRet := fGetData( @oJsonRet, nPage, nPageSize, cBranchId, cFuncCod, cFuncCCCod, cVisionCode, dDtChange )
        EndIf

    EndIf

    ::SetResponse( EncodeUTF8( oJsonRet:toJSON() ) )
RECOVER
    lRet := .F.
    ErrorBlock(bErrorBlock)
    SetRestFault(ERRORSRV_DEF, EncodeUTF8(STR0004) + CRLF + oError:Description, Nil, Nil, Nil, URL_DEF, Nil )//"Ocorreu uma falha no retorno da informação."
END SEQUENCE

If cEmpAntBck <> cCompId .Or. cFilAntBck <> cBranchId
    fTrGrpGPE(cEmpAntBck, cFilAntBck)
EndIf

Return lRet	

/*/{Protheus.doc} Static Function fPreValid
Valida parâmetros obrigatórios
/*/
Static Function fPreValid( oObj, cCompId, cBranchId )

Local lRet 	   := .T.
Local cMessage := ""

If Empty(cCompId)
    cMessage := STR0005//"O parâmetro companyId é obrigatório."
    lRet 	 := .F.
ElseIf Empty(cBranchId)
    cMessage := STR0006//"O parâmetro branchId é obrigatório."
    lRet 	 := .F.
EndIf

If !lRet
    SetRestFault( ERRORCODE_DEF, EncodeUTF8(cMessage), Nil, Nil, Nil, URL_DEF, Nil )
EndIf

Return lRet

/*/{Protheus.doc} Static Function fGetData
Retorna os dados da tabela SRA
/*/
Static Function fGetData( oJsonRet, nPage, nPageSize, cBranchId, cFuncCod, cFuncCCCod, cVisionCode, dDtChange )

Local aAreaSQB      := SQB->( GetArea() )
Local aAreaSRA      := SRA->( GetArea() )
Local aItens        := {}
Local cAliasSRA     := GetNextAlias()
Local cLidCC        := ""
Local cLidCCDesc    := ""
Local cLidDep       := ""
Local cLidDepDesc   := ""
Local cLidEmail     := ""
Local cLidFil       := ""
Local cLidMat       := ""
Local cLidNome      := ""
Local cLidNomeC     := ""
Local cQuery  	    := ""
Local cTipoOrg		:= ""
Local lRet 		    := .T.
Local lSQBAlt       := .F.
Local oItem         := Nil 
Local oJsonData	    := Nil

//Seta o primeiro item e o último da página atual
nStart := ((nPage - 1) * nPageSize) + 1
nEnd   := nPage * nPageSize

cQuery := "SELECT * FROM ("
cQuery += "SELECT ROW_NUMBER() OVER(ORDER BY RA_FILIAL, RA_MAT ASC) ITEMNUMBER, COUNT (1) OVER() TOTALNUMBER,RA_FILIAL,RA_MAT,RA_NOME,RA_NOMECMP,RA_DEPTO "
cQuery += "FROM " + RetSqlName("SRA") + " SRA "
cQuery += "WHERE SRA.RA_FILIAL = '" + cBranchId + "' "
If !Empty(cFuncCod)
    cQuery += "AND SRA.RA_MAT = '" + cFuncCod + "' "
EndIf
If !Empty(cFuncCCCod)
    cQuery += "AND SRA.RA_CC = '" + cFuncCCCod + "' "
EndIf
cQuery += "AND SRA.D_E_L_E_T_ = ' ') TAB "
cQuery += "WHERE TAB.ITEMNUMBER BETWEEN '" + cValToChar(nStart) + "' AND '" + cValToChar(nEnd) + "'"

dbUseArea( .T., "TOPCONN", TcGenQry( , ,cQuery), cAliasSRA, .T., .T. )

If !fPosValid( (cAliasSRA)->ITEMNUMBER, (cAliasSRA)->TOTALNUMBER )
    lRet := .F.
EndIf

SQB->( dbSetOrder(1) )//QB_FILIAL+QB_DEPTO+QB_DESCRIC
SRA->( dbSetOrder(1) )//RA_FILIAL+RA_MAT+RA_NOME

lSQBAlt := SQB->(ColumnPos("QB_DTALTRE")) > 0

If lRet
    oJsonData	            := JsonObject():New()
    oJsonData["hasNext"]    := .T.
    oJsonData["total"] 		:= (cAliasSRA)->TOTALNUMBER

    TipoOrg(@cTipoOrg, cVisionCode)

    While (cAliasSRA)->( !Eof() )

        If (cAliasSRA)->TOTALNUMBER == (cAliasSRA)->ITEMNUMBER .Or. nPageSize >= (cAliasSRA)->TOTALNUMBER
            oJsonData["hasNext"] := .F.
        EndIf

        fGetSup( cAliasSRA, cTipoOrg, cVisionCode, @cLidFil, @cLidMat, @cLidNome, @cLidNomeC, @cLidEmail, @cLidDep, @cLidDepDesc, @cLidCC, @cLidCCDesc, lSQBAlt, dDtChange )
        
        If lSQBAlt .And. !Empty(dDtChange) .And. Empty(cLidMat)
            (cAliasSRA)->(dbSkip())
            oJsonData["total"] -= 1
            Loop
        EndIf 

        oItem := JsonObject():New()
        oItem["managerBranch"]    				:= cLidFil					        // "Filial do Líder"
        oItem["managerCode"]            		:= cLidMat						    // "Matricula do Líder"
        oItem["managerName"]            		:= RTrim( cLidNome )			    // "Nome do Líder"
        oItem["managerFullName"]        		:= RTrim( cLidNomeC )			    // "Nome Completo do Líder"
        oItem["managerEmail"]     				:= RTrim( cLidEmail	)			    // "E-mail do Líder"
        oItem["managerDepartmentCode"] 		    := cLidDep					        // "Codigo do departamento do Líder"
        oItem["managerDepartmentDescription"] 	:= RTrim( cLidDepDesc )		        // "Descrição do Departamento do Líder"
        oItem["managerCostCenterCode"]          := cLidCC						    // "Código do Centro de Custo do Líder"
        oItem["managerCostCenterDescription"] 	:= RTrim( cLidCCDesc )              // "Descrição do Centro de Custo do Líder"
        oItem["employeeBranch"]    				:= (cAliasSRA)->RA_FILIAL			// "Filial do Empregado"
        oItem["employeeCode"]            		:= (cAliasSRA)->RA_MAT				// "Matricula do Empregado"
        oItem["employeeName"]            		:= RTrim( (cAliasSRA)->RA_NOME )	// "Nome do Empregado"
        oItem["employeeFullName"]            	:= RTrim( (cAliasSRA)->RA_NOMECMP )	// "Nome Completo do Empregado"
                    
        aAdd(aItens, oItem)
        
        (cAliasSRA)->( dbSkip() )
    EndDo

    If oJsonData["total"] == 0 
        lRet := .F.
        SetRestFault(ERRORCODE_DEF, EncodeUTF8(STR0007), Nil, Nil, Nil, URL_DEF, Nil) //"Nenhum registro localizado."
    Else
        oJsonData["items"] := aItens
        oJsonRet 		   := oJsonData
    EndIf
EndIf

(cAliasSRA)->( dbCloseArea() )

RestArea( aAreaSQB )
RestArea( aAreaSRA )

Return lRet

/*/{Protheus.doc} Static Function fGetSup
Busca o superior do funcionário
/*/
Static Function fGetSup( cAliasSRA, cTipoOrg, cVisionCode, cLidFil, cLidMat, cLidNome, cLidNomeC, cLidEmail, cLidDep, cLidDepDesc, cLidCC, cLidCCDesc, lSQBAlt, dDtChange )

Local aDeptos 	:= {}
Local aSuperior	:= {}
Local aTransf   := {}
Local aArea     := GetArea()
Local nPosDepto := 0
Local nX        := 0
Local lTranfSQB := .F.

cLidFil     := ""
cLidMat     := ""
cLidNome    := ""
cLidNomeC   := ""
cLidEmail   := ""
cLidDep     := ""
cLidDepDesc := ""
cLidCC      := ""
cLidCCDesc  := ""

If ( nPosDepto := aScan( aBkpDeptos, { |x| x[1] == (cAliasSRA)->RA_FILIAL } ) ) > 0
	aDeptos := aClone( aBkpDeptos[nPosDepto, 2] )
Else
	aDeptos := fEstrutDepto( (cAliasSRA)->RA_FILIAL )
	aAdd( aBkpDeptos, { (cAliasSRA)->RA_FILIAL, aClone(aDeptos) } )
EndIf

If SQB->( dbSeek( xFilial("SQB", (cAliasSRA)->RA_FILIAL)+(cAliasSRA)->RA_DEPTO ) )
    If lSQBAlt .And. !Empty(dDtChange) .And. SQB->QB_DTALTRE < dDtChange
        If SRA->(dbSeek((cAliasSRA)->RA_FILIAL+(cAliasSRA)->RA_MAT)) .And. fTransfDep(@aTransf)
            For nX := 1 to Len(aTransf)
                If aTransf[nX, 07] >= dDtChange
                    lTranfSQB := .T.
                    Exit
                EndIf
            Next nX
        EndIf
        If !lTranfSQB
            RestArea(aArea)
            Return
        EndIf    
    EndIf
    aSuperior := fBuscaSuperior( (cAliasSRA)->RA_FILIAL, (cAliasSRA)->RA_MAT, (cAliasSRA)->RA_DEPTO, aDeptos, cTipoOrg, cVisionCode )
    If !Empty(aSuperior) .And. !Empty( aSuperior[1, 1]+aSuperior[1, 2] )
        If SRA->( dbSeek( aSuperior[1, 1]+aSuperior[1, 2] ) )
            cLidFil     := SRA->RA_FILIAL
            cLidMat     := SRA->RA_MAT
            cLidNome    := SRA->RA_NOME
            cLidNomeC   := SRA->RA_NOMECMP
            cLidEmail   := SRA->RA_EMAIL
            cLidDep     := SRA->RA_DEPTO
            cLidDepDesc := FDesc( "SQB", SRA->RA_DEPTO, "QB_DESCRIC", NIL, cLidFil, 1 )
            cLidCC      := SRA->RA_CC
            cLidCCDesc  := FDesc( "CTT", SRA->RA_CC, "CTT_DESC01", NIL, cLidFil, 1 )
        EndIf
    EndIf
EndIf 

RestArea(aArea)

Return

/*/{Protheus.doc} Static Function fPosValid
Valida query efetuada na SRA
/*/
Static Function fPosValid( nReg, nTotalReg )

Local lRet		:= .T.
Local cMessage	:= ""

If nReg == 0 .OR. nTotalReg == 0
    cMessage	:= STR0007//"Nenhum registro localizado."
    lRet		:= .F.
EndIf

If !lRet
    SetRestFault( ERRORCODE_DEF, EncodeUTF8(cMessage), Nil, Nil, Nil, URL_DEF, Nil )
EndIf

Return lRet

/*/{Protheus.doc} Static Function fSetErrorHandler
Seta código e mensagem de erro
/*/
Static Function fSetErrorHandler( cTitle )

bError      := { |e| oError := e , oError:Description := cTitle + CRLF + oError:Description, Break(e) }
bErrorBlock := ErrorBlock( bError )

Return .T.

/*/{Protheus.doc} Static Function fResetErrorHandler
Seta código e mensagem de erro 
/*/
Static Function fResetErrorHandler( cTitle )

bError      := { |e| oError := e , Break(e) }
bErrorBlock := ErrorBlock( bError )

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} function fVldData
Valida data enviada no managerChangeDate
@author  Bruno Costa
@since   13/12/2024
@version 12
/*/
//-------------------------------------------------------------------
Static Function fVldData(oObj, cDataVld, dDtChange)        
Local lValida :=  .T.     
Local nAno    := 0
Local nMes    := 0
Local nDia    := 0

If Len(cDataVld) != 10 .Or. SubStr(cDataVld, 5, 1) != "-" .Or. SubStr(cDataVld, 8, 1) != "-"
    lValida := .F.
EndIf

If lValida
    nAno := Val(SubStr(cDataVld, 1, 4))
    nMes := Val(SubStr(cDataVld, 6, 2))
    nDia := Val(SubStr(cDataVld, 9, 2))

    If nAno >= 1900 .And. nMes >= 1 .And. nMes <= 12 .And. nDia >= 1 .And. nDia <= 31
        dDtChange := CtoD(StrZero(nDia, 2) + "/" + StrZero(nMes, 2) + "/" + Str(nAno, 4))
    Else
        lValida := .F.
    EndIf
EndIf

If !lValida
    SetRestFault(ERRORCODE_DEF, EncodeUTF8(STR0008), Nil, Nil, Nil, URL_DEF, Nil) //"O parâmetro managerChangeDate deve estar no formato ano-mês-dia: '2024-12-01'.'
EndIf

Return lValida
