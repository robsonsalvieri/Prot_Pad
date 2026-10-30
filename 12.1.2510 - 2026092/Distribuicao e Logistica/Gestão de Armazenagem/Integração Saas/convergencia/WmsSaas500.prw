#include 'PROTHEUS.CH'
#include 'FWMVCDEF.CH'
#include 'WMSSAAS500.CH'

#define GERADA    WMSSaasManufaturaControleRequisicao():getStatusGerada()
#define CONCLUIDA WMSSaasManufaturaControleRequisicao():getStatusConcluida()

Static oBrowse
Static lMarkAll := .F. // Indicador de marca/desmarca todos
Static cWmsMark := ""

Function WmsSaas500()

DBSelectArea('DBX')
DBX->(DBSetOrder(1))

oBrowse:= FWMarkBrowse():New()
oBrowse:SetAlias('DBX')
oBrowse:SetDescription(STR0001) //--"Monitor de Requisições Empenhadas WMS Saas"
oBrowse:SetFieldMark("DBX_OK") 
oBrowse:SetMenuDef("WmsSaas500")
oBrowse:SetAllMark({||WMSSAllMrk()})
oBrowse:SetValid({||WMSSVldMrk()})

// -- Legendas (Já adiciona filtros)
oBrowse:AddLegend("DBX_STATUS== '1'","WHITE",STR0002) //--"Gerada"
oBrowse:AddLegend("DBX_STATUS== '2'","GREEN",STR0003) //--"Concluida"

// -- Filtro de Status que podem ser atualizados
oBrowse:SetParam({|| WMSSSelDBX(oBrowse) })
If Pergunte("WMSSAAS500",.T.)
    oBrowse:SetFilterDefault("@"+WMSSFilDBX())
    oBrowse:SetdbFFilter(.T.)
	oBrowse:SetUseFilter(.T.)
    oBrowse:Activate()
EndIf

Return NIL

/*/{Protheus.doc} ModelDef
    Modelo de dados do MVC
    @type  Static Function
    @author user
    @since 23/05/2024
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/

Static Function ModelDef()
Local oModel
Local oEstDBX:= FWFormStruct(1,'DBX')

    oModel := MPFormModel():New('WmsSaas500')
    oModel:addFields('MASTER_DBX',,oEstDBX)
    oModel:SetDescription(STR0001)//"Monitor de Requisições Empenhadas WMS Saas"
    oModel:SetPrimaryKey({})

Return oModel

/*/{Protheus.doc} ViewDef
    Definicao da View
    @type  Static Function
    @author user
    @since 23/05/2024
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function ViewDef()
Local oView
Local oModel := FWLoadModel( 'WmsSaas500' )
Local oEstDBX:= FWFormStruct(2,'DBX')

    oView := FWFormView():New() 

    oView:SetModel(oModel)
    oView:AddField('DETAILS_DBX' , oEstDBX,'MASTER_DBX')
    
    oView:CreateHorizontalBox( 'BOXFORM1', 100)
    
    oView:SetOwnerView('DETAILS_DBX','BOXFORM1')
    
    oView:EnableTitleView('DETAILS_DBX' , STR0005 )// -- Requisição
 
    oView:setOnlyView("DETAILS_DBX")
 
Return oView

/*/{Protheus.doc} MenuDef
    Definicao do menu
    @type  Static Function
    @author user
    @since 23/05/2024
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function MenuDef()
Local aRotina := {}
    ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.WMSSAAS500' OPERATION 2 ACCESS 0 //'Visualizar'
    ADD OPTION aRotina TITLE STR0006 ACTION 'WmsSaas501()' OPERATION 3 ACCESS 0 //'Requisitar'
    ADD OPTION aRotina TITLE STR0007 ACTION 'WmsSS500Ex()' OPERATION 5 ACCESS 0 //'Excluir Marcados'
Return aRotina

/*/{Protheus.doc} WMSSSelDBX
    Recarrega browse
    @type  Static Function
    @author user
    @since 05/06/2024
    @version version
    @param param_name, param_type, param_descr
    @example
    (examples)
/*/
Static Function WMSSSelDBX(oBrowse)
    If Pergunte("WMSSAAS500",.T.)
        oBrowse:SetFilterDefault("@"+WMSSFilDBX())
        oBrowse:SetdbFFilter(.T.)
	    oBrowse:SetUseFilter(.T.)
        oBrowse:Refresh(.T.)
    EndIf
Return

/*/{Protheus.doc} WMSSAllMrk
    Marca somente itens filtrados
    @type  Static Function
    @author user
    @since 26/06/2024
    @version version
    @see 
/*/
Static Function WMSSAllMrk()
Local aAreaDBX := DBX->(GetArea())
Local cAliasDBX := Nil
Local cAliasAux := Nil
Local lRet := .T.
    
   cAliasAux := GetNextAlias()
   BeginSql Alias cAliasAux
       SELECT 1
         FROM %Table:DBX% DBX
        WHERE DBX.DBX_OK = %Exp:WMSSMark()%
          AND DBX.%NotDel%
   EndSql
   lMarkAll := (cAliasAux)->(Eof())
   (cAliasAux)->(dbCloseArea())

    cAliasDBX := oBrowse:Alias()
    (cAliasDBX)->(DbGoTop())
    While (cAliasDBX)->(!Eof())
        lRet := .T.
        If WMSSVldMrk()
            If (lMarkAll .And. WMSSMark() = DBX->DBX_OK) .Or. ; //Funcao marcar e ja esta marcado, nao faz nada
            (!lMarkAll .And. Empty(DBX->DBX_OK)) //Funcao desmarcar e nao esta marcado, nao faz nada
                lRet := .F.
            EndIf
            If lRet .And. Reclock('DBX',.F.)
                DBX->DBX_OK := Iif(lMarkAll,WMSSMark(),Space(TamSx3("DBX_OK")[1]))
                DBX->(MsUnlock())
            EndIf
        EndIf
        (cAliasDBX)->(DbSkip())
    EndDo

    RestArea(aAreaDBX)
    oBrowse:Refresh()

Return Nil

Static Function WMSSVldMrk()
Local cAliasDBX := oBrowse:Alias()
Local oConv     := Nil
Local cFilBkp   := cFilAnt
Local lRet      := .F. 
    
    cFilAnt := (cAliasDBX)->DBX_FILIAL    
    oConv   := WMSSaasManufaturaControleRequisicao():LoadByRecno((cAliasDBX)->(Recno()))
    lRet    := oConv:convergencia:canBeUpdated()
    cFilAnt := cFilBkp
Return lRet

/*/{Protheus.doc} WMSSMark
    (Recupera a marca do browse)
    @type  Function
    @author user
    @since 09/12/2024
    @see 
    /*/
Static Function WMSSMark()
	cWmsMark := oBrowse:cMark
Return cWmsMark

/*--------------------------------------------------------------------------------
---MontFiltro
---Filtra registros de requisição WMS SAAS tabela DBX
---03/12/2024
----------------------------------------------------------------------------------*/
Static Function WMSSFilDBX()
Local cQuery   := ""

	cQuery := " DBX_FILIAL = '"+xFilial("DBX")+"'"
    If ((!Empty(MV_PAR01) .OR.  !(Upper(mv_par02) == Replicate('Z', Len(mv_par02)))) .And. (mv_par01 <> mv_par02))
		cQuery += " AND DBX_LOCAL >= '"+mv_par01+"'"
		cQuery += " AND DBX_LOCAL <= '"+mv_par02+"'"
    ElseIf (!Empty(MV_PAR01) .AND. (MV_PAR01 == mv_par02))
        cQuery  += "  AND DBX_LOCAL = '"+mv_par01+"'"
    EndIf
	        
    cQuery += " AND DBX_DATREQ >= '"+DToS(mv_par03)+"'"
	cQuery += " AND DBX_DATREQ <= '"+DToS(mv_par04)+"'"

    If ((!Empty(mv_par05) .OR.  !(Upper(mv_par06) == Replicate('Z', Len(mv_par06)))) .And. (mv_par05 <> mv_par06))
		cQuery += " AND DBX_OP >= '"+mv_par05+"'"
		cQuery += " AND DBX_OP <= '"+mv_par06+"'"
    ElseIf  (!Empty(mv_par05) .AND. (mv_par05 == mv_par06))
        cQuery  += "  AND DBX_OP = '"+mv_par05+"'"
    EndIf
	
	If ((!Empty(mv_par07) .OR.  !(Upper(mv_par08) == Replicate('Z', Len(mv_par08)))) .And. (mv_par07 <> mv_par08))
		cQuery += " AND DBX_COD >= '"+mv_par07+"'"
		cQuery += " AND DBX_COD <= '"+mv_par08+"'"
    ElseIf  (!Empty(mv_par07) .AND. (mv_par07 == mv_par08))
        cQuery  += "  AND DBX_COD = '"+mv_par07+"'"
    EndIf

	Do Case
	    Case MV_PAR09 == 1 .Or. MV_PAR09 == 2//Geradas ou Concluidas
            cQuery += " AND DBX_STATUS = " + cValtoChar(MV_PAR09)
        Case MV_PAR09 == 3//Todas
            cQuery += " AND (DBX_STATUS = '"+GERADA+"' OR DBX_STATUS = '"+CONCLUIDA+"')"
    EndCase
   
	cQuery += " AND D_E_L_E_T_ = ' '"
	
Return cQuery


/*/{Protheus.doc} WmsSS500Ex
    (Recupera a marca do browse)
    @type  Function
    @author equipe WMS
    @since 09/12/2024
    @see 
    /*/
Function WmsSS500Ex()
Local aAreaDBX  := DBX->(GetArea())
Local cAliasDBX := GetNextAlias()
Local oView     := FWFormView():New() 
  
    BeginSql Alias cAliasDBX
        SELECT DBX.R_E_C_N_O_ AS RECDBX
          FROM %Table:DBX% DBX
         WHERE DBX.DBX_OK = %Exp:WMSSMark()%
           AND DBX.%NotDel%
    EndSql
    If (cAliasDBX)->(!Eof())
        If FWAlertNoYes(STR0008,STR0009) // "Confirma a exclusao dos registros marcados?" // "Exclusao de requisicao WMS SaaS"
            While (cAliasDBX)->(!Eof())
                WMSSExItRq((cAliasDBX)->RECDBX)
                (cAliasDBX)->( DbSkip() )
            EndDo 
            oView:Refresh()
        EndIf
    EndIf
    (cAliasDBX)->(dbCloseArea())
    RestArea(aAreaDBX)
Return
