#include "totvs.ch"
#include "ofir011.ch"

static cPerg  := "OFIR011" // Grupo de perguntas (SX1) 
static cAlias := "QryR011"

/* {Protheus.doc} OFIR011
Relatório TReport da Recompra Scania [ENVARP]
@type function
@autor Paulo Roberto Alves Pereira
@data 24/08/2026
*/
Function OFIR011()
	local oReport
    local lOk := .F.

    while !lOk .and. pergunte( cPerg, .T. )
        if OR0110048_QtdReg() > 0
            lOK := .T.
        else
            FwAlertWarning(STR0001) // "Não existem informações com os parâmetros informados."
        endif
    enddo
    if ! lOk
        return
    endif    
	oReport := OR0110018_RptDef()
	oReport:PrintDialog()

return

/* {Protheus.doc} OR0110018_RptDef
Define estrutura do relatório
@type static function
@autor Paulo Roberto Alves Pereira
@data 24/08/2026
*/

static function OR0110018_RptDef()
    local oReport    := nil
    local oSecPedido := nil
    local oSecItens  := nil 
    local oCellTotal := nil
     
    oReport := TReport():New( cPerg, STR0002, cPerg, {|oReport| OR0110028_PrintRpt(oReport) } ) // "Recompra SCANIA"
    oReport:oPage:SetPaperSize(9) 
    oReport:SetPortrait()     
    oReport:SetLineHeight(50)
    oReport:nFontBody := 12

    oSecPedido := TRSection():New(oReport, STR0003, {cAlias}, , , , , , .F.  ) // "Pedido"
        
    TRCell():New(oSecPedido, "VWN_PEDIDO", cAlias, STR0004) // "Nº Pedido"
    TRCell():New(oSecPedido, "VWN_MESANO", cAlias, STR0005) // "Referência"
    oSecPedido:SetPageBreak(.T.)
     
    oSecItens := TRSection():New( oReport, STR0006, {cAlias},  , , , , , .F.  ) // "Itens do Pedido"
    oSecItens:SetLinesBefore(2)
    
    TRCell():New(oSecItens, "VWO_SEQUEN", cAlias, STR0007,, 04, , , "LEFT", , "LEFT", , , , , , .F.) // "Seq."
    TRCell():New(oSecItens, "VWO_CODITE", cAlias, STR0008,, 07, , , "LEFT", , "LEFT", , , , , , .F.) // "Código"
    TRCell():New(oSecItens, "VWO_DESCRI", cAlias, STR0009,, 15, , , "LEFT", , "LEFT", , , , , , .F.) // "Descrição"
    TRCell():New(oSecItens, "VWO_PESOLQ", cAlias, STR0010,, 07, , , "LEFT", , "LEFT", , , , , , .F.) // "Peso Lq"
    TRCell():New(oSecItens, "VWO_QUANTI", cAlias, STR0011,, 05, , , "RIGHT", , "RIGHT", , , , , , .F.) // "Quant"
    TRCell():New(oSecItens, "VWO_PRECO",  cAlias, STR0012,, 10, , , "RIGHT", , "RIGHT", , , , , , .F.) // "Preço"
    oCellTotal := TRCell():New(oSecItens, "VLTOTAL", cAlias, STR0013,  "@E 999,999,999.99", 13, , , "RIGHT", , "RIGHT", , , , , , .F.) // "Valor Total"
    TRCell():New(oSecItens, "VWO_PERICM", cAlias, STR0014,    , 10, , , "RIGHT", , "RIGHT", , , , , , .F.) // "% ICMS"
     
    oBreak := TRBreak():New(oSecItens, oSecPedido:Cell("VWN_PEDIDO"), "", .F.,, .T.)

    TRFunction():New(oCellTotal, , "SUM", oBreak, STR0015, "@E 999,999,999.99", , .F., .F., .F. )
     
Return oReport

/* {Protheus.doc} OR0110018_RptDef
Faz a impressão do relatório
@type static function
@autor Paulo Roberto Alves Pereira
@data 24/08/2026
*/

static function OR0110028_PrintRpt(oReport)
    local aArea      := FWGetArea()
	local oStatement := nil
    local oSecPedido := nil
    local oSecItens  := nil
    local cQuery     := OR0110038_MontaQuery(.F.)
    local nTotal     := OR0110048_QtdReg()
    local nAtual     := 0
    local cPedido    := ""

    oSecPedido := oReport:Section(1)
    oSecItens  := oReport:Section(2)
	
    oStatement := FwExecStatement():new( cQuery )
	oStatement:OpenAlias(cAlias)
    DbSelectArea(cAlias)

    oReport:SetMeter(nTotal)

    while ! (cAlias)->(Eof())
        cPedido := (cAlias)->VWN_PEDIDO
        oSecPedido:Init()    
        oSecPedido:PrintLine()
        oSecPedido:Finish()
        oReport:SkipLine()
        oSecItens:Init()
        while ! (cAlias)->(Eof()) .and. cPedido == (cAlias)->VWN_PEDIDO
            nAtual++
            oReport:SetMsgPrint(STR0016 + " " + cValToChar(nAtual) + " " + STR0017 + " " + cValToChar(nTotal) + "...") // "Imprimindo registro" + ... + "de"
            oReport:IncMeter()
            oSecItens:PrintLine()
            (cAlias)->(DbSkip())
        enddo
        oSecItens:Finish()     
    enddo

    (cAlias)->(DbCloseArea())
     
    FWRestArea(aArea)
Return

/* {Protheus.doc} OR0110038_MontaQuery
Retorna a query fixada com os parametros ajustados
@type static function
@autor Paulo Roberto Alves Pereira
@data 26/08/2026
*/

static function OR0110038_MontaQuery( lCount )
    local oStatement := nil
    local cQuery
    local nPosPed

    if lCount
        cQuery := "SELECT count(*) "
    else
        cQuery := "SELECT VWN_DATGER, VWN_MESANO, VWN_PEDIDO, VWO_SEQUEN, VWO_CODITE, VWO_DESCRI, VWO_PESOLQ, VWO_QUANTI, VWO_PRECO, "
        cQuery += "(VWO_QUANTI * VWO_PRECO) VLTOTAL, VWO_PERICM "
    endif
    cQuery += "FROM " + RetSQLName("VWN") + " VWN "
    cQuery += "LEFT JOIN " + RetSQLName("VWO") + " VWO ON VWO_FILIAL = ? AND VWO_MESANO = VWN_MESANO AND VWO_PEDIDO = VWN_PEDIDO "
    cQuery += "WHERE VWN_FILIAL = ? AND VWN.D_E_L_E_T_ = ? AND VWO.D_E_L_E_T_ = ? "

	if !empty(MV_PAR01) .and. !empty(MV_PAR02)
		cQuery += "AND VWN_DATGER BETWEEN ? AND ? "
	else
		if !empty(MV_PAR01) .and. empty(MV_PAR02)
			cQuery += "AND VWN_DATGER >= ? "
		elseif empty(MV_PAR01) .and. !empty(MV_PAR02)
			cQuery += "AND VWN_DATGER <= ? "		
		endif        
	endif	

    if !empty(MV_PAR03)
        cQuery += "AND VWN_PEDIDO = ? "		
    endif        

    if !lCount
        cQuery += "ORDER BY VWN_PEDIDO"
    endif
        	
    oStatement := FwExecStatement():new( cQuery )
	oStatement:setString( 01, xFILIAL("VWN") )
	oStatement:setString( 02, xFILIAL("VWO") )
	oStatement:setString( 03, ' ' )
    oStatement:setString( 04, ' ' )
    nPosPed := 5

	if !empty(MV_PAR01) .and. !empty(MV_PAR02)
		oStatement:setString( 05, DTOS(MV_PAR01) )
		oStatement:setString( 06, DTOS(MV_PAR02) )
        nPosPed := 7
	else
		if !empty(MV_PAR01) .and. empty(MV_PAR02)
		    oStatement:setString( 05, DTOS(MV_PAR01) )
            nPosPed := 6
		elseif empty(MV_PAR01) .and. !empty(MV_PAR02)        
			oStatement:setString( 05, DTOS(MV_PAR02) )	
             nPosPed := 6
		endif
	endif
    if !empty(MV_PAR03)
        oStatement:setString( nPosPed, MV_PAR03 )	
    endif

	cQuery := oStatement:getFixQuery()
    FWFreeObj(oStatement)

return cQuery

/* {Protheus.doc} OR0110048_QtdReg
Retorna a quantidade de registros com os parametros informados
@type static function
@autor Paulo Roberto Alves Pereira
@data 26/08/2026
*/

static function OR0110048_QtdReg()
    local cQuery := OR0110038_MontaQuery(.T.)

return FM_SQL(cQuery)
