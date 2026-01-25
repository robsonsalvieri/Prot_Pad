#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA203
Browse Assinatura Eletronica

@author  Lucas Nonato
@since   04/06/2024
@version P12
/*/
Function PLSA203()

oBrw := FWmBrowse():New()
oBrw:SetAlias( 'BQ6' )
oBrw:SetDescription( 'Assinatura Eletronica' )
oBrw:SetMenuDef("PLSA203")
oBrw:Activate()

Return(.T.)

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Monta o menu

@author  Lucas Nonato
@since   04/06/2024
@version P12
/*/
Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina Title 'Visualizar' 	   Action 'ViewDef.PLSA203'		OPERATION 2 ACCESS 0

Return aRotina 

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de Dados
@author Lucas Nonato
@since 04/06/2024
@version P12
/*/
Static Function ModelDef()
Local oModel 
Local oStrBQ6:= FWFormStruct(1,'BQ6')

oModel := MPFormModel():New( 'PLSA203' )		
oModel:addFields('MasterBQ6',,oStrBQ6)
oModel:getModel('MasterBQ6')

oModel:SetPrimaryKey( {"BQ6_FILIAL", "BQ6_NUMGUI"} )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição do interface
@author Lucas Nonato
@since 04/06/2024
@version P12
/*/
Static Function ViewDef()
Local oView
Local oModel := ModelDef()
Local oStrBQ6:= FWFormStruct(2, 'BQ6')

oView := FWFormView():New()										
oView:SetModel(oModel)
oView:AddField('FrmBQ6' , oStrBQ6,'MasterBQ6' )
oView:CreateHorizontalBox( 'BxBQ6', 100)
oView:SetOwnerView('FrmBQ6','BxBQ6')

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA203GRV
Browse Assinatura Eletronica

@author  Lucas Nonato
@since   04/06/2024
@version P12
/*/
Function PLSA203GRV(cNumGui,cTipGui)
local cTpInc    := GetNewPar("MV_PLTPTAE", '')//1-Benef;2-Prestador;3-Ambos
local aTipo     := iif(!empty(cTpInc),iif(cTpInc == '3',{'1','2'},{cTpInc}),{})
local nX        := 1 

BQ6->(dbsetorder(1))
for nX := 1 to len(aTipo)
    if !BQ6->(msseek(xfilial("BQ6")+cNumGui+aTipo[nX]))
        BQ6->(reclock("BQ6",.t.))
        BQ6->BQ6_FILIAL := xfilial("BQ6")
        BQ6->BQ6_NUMGUI := cNumGui
        BQ6->BQ6_TIPGUI := cTipGui
        BQ6->BQ6_TPSIGN := aTipo[nX]
        BQ6->BQ6_DTENV  := date()
        BQ6->BQ6_HORENV := time()
        BQ6->BQ6_STATUS := 'X'
        BQ6->(msunlock())
    endif
next

return

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA203STA
Browse Assinatura Eletronica
//X=Pend Envio;E=Erro;0=Pend Assinatura;1=Assinado parcialmente;2=Finalizado;4=Rejeitado;5=Rascunho;6=Pend PLS;7=Cancelado
@author  Lucas Nonato
@since   04/06/2024
@version P12
/*/
Function PLSA203STA(cNumGui)
local cSql      := ''
local cAlias    := GetnextAlias()
local cRet      := ''
cSql := "SELECT BQ6_STATUS,BQ6_TPSIGN FROM " + RetSqlName("BQ6") + " BQ6 "
cSql += " WHERE BQ6_FILIAL 		= '" + xFilial("BQ6") + "' "	
cSql += " AND BQ6_NUMGUI		= '" + cNumGui + "' "	
cSql += " AND D_E_L_E_T_ = ' ' "
dbUseArea(.T.,"TOPCONN",TCGenQry(,,cSql),cAlias,.F.,.T.)

//0-Sem assinatura
//1-Assinado
//2-Pendente 
while !(cAlias)->(eof())
    cRet := iif((cAlias)->BQ6_STATUS == '2',iif(cRet=='2','2','1'),'2')
    (cAlias)->(dbskip())
enddo

if empty(cRet)
    cRet := '0'
endif

(cAlias)->(dbCloseArea())
return cRet
