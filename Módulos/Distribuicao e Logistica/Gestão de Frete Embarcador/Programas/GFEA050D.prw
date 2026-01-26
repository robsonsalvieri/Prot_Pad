#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PROTHEUS.CH"

Static oFwFilter
Static cAliasGW1D 	:= ""
Static cMsgErro  	:= ""

/*-------------------------------------------------------------------------------------------------- 
{Protheus.doc} GFEA050D
Tela de alteração de redespachantes

@sample
GFEA050D()

@author Amanda Vieira
@since 25/02/2016
@version 1.0
--------------------------------------------------------------------------------------------------*/
Function GFEA050D()
Return

/*--------------------------------------------------------------------------------------------------
{Protheus.doc} ModelDef

@sample
ModelDef()

@author Amanda Vieira
@since 25/02/2016
@version 1.0
--------------------------------------------------------------------------------------------------*/
Static Function ModelDef()
	Local oModel	:= Nil
	Local oStrGWU	:= FWFormStruct(1,'GWU')
	Local oStructTab:= FWFormModelStruct():New()
	Local oStructX3	:= GFESeekSX():New()

	oModel := MPFormModel():New('GFEA050D',,{|oModel| ValidModel(oModel) },{|oModel| CommitMdl(oModel) })
	oModel:AddFields('GWUMASTER',,oStrGWU)
	oModel:SetDescription("Redespachantes")
	oModel:GetModel('GWUMASTER'):SetDescription("Trechos") 
	
	// Monta Struct
	oStructTab:AddTable(cAliasGW1D, {'CDTPDC','EMISDC','SERDC','NRDC','SEQ'},'Tb Trechos')
	oStructTab:AddIndex(1,'1','CDTPDC+EMISDC+SERDC+NRDC+SEQ',"Idx Trechos",'','',.T.) 
	
	oStructX3:SeekX3("GWU_CDTPDC")
	oStructTab:AddField(oStructX3:getX3Titulo(),oStructX3:getX3Titulo(),'CDTPDC' ,'C',oStructX3:getX3Tamanho(), oStructX3:getX3Decimal(),Nil,{||.F.},Nil,.F.,,.F.,.F.,.F.)  
	oStructX3:SeekX3("GWU_EMISDC")
	oStructTab:AddField(oStructX3:getX3Titulo(),oStructX3:getX3Titulo(),'EMISDC'  ,'C',oStructX3:getX3Tamanho(), oStructX3:getX3Decimal(),Nil,{||.F.},Nil,.F.,,.F.,.T.,.F.) 
	oStructX3:SeekX3("GWU_SEQ")
	oStructTab:AddField("Trecho",oStructX3:getX3Titulo(),'SEQ','C',oStructX3:getX3Tamanho(), oStructX3:getX3Decimal(),Nil,{||.F.},Nil,.F.,,.F.,.T.,.F.) 
	oStructX3:SeekX3("GWU_SERDC")
	oStructTab:AddField(oStructX3:getX3Titulo(),oStructX3:getX3Titulo(),'SERDC' ,'C',oStructX3:getX3Tamanho(), oStructX3:getX3Decimal(),Nil,{||.F.},Nil,.F.,,.F.,.T.,.F.) 
	oStructX3:SeekX3("GWU_NRDC")
	oStructTab:AddField(oStructX3:getX3Titulo(),oStructX3:getX3Titulo(),'NRDC' ,'C',oStructX3:getX3Tamanho(), oStructX3:getX3Decimal(),Nil,{||.F.},Nil,.F.,,.F.,.T.,.F.) 	
	oStructX3:SeekX3("GWU_CDTRP")
	oStructTab:AddField(oStructX3:getX3Titulo(),oStructX3:getX3Titulo(),'CDTRP'  ,'C',oStructX3:getX3Tamanho(), oStructX3:getX3Decimal(),{|oModel| IIF(VldTransp(oModel:GetValue('CDTRP'),.F.,oModel),oModel:LoadValue("NMEMIT" ,POSICIONE("GU3",1,XFILIAL("GU3")+oModel:GetValue('CDTRP'),"GU3_NMEMIT")),.F.)},;
	                                                                                  {|oModel| VldTrecho(oModel:GetValue('SEQ'),oModel:GetValue('NRDC'),oModel:GetValue('CDTPDC'),oModel:GetValue('EMISDC'),oModel:GetValue('SERDC'),oModel:GetValue('NRCIDD'),oModel:GetValue('CDTRP'),oModel:GetValue('CDTPVC'),1)},Nil,.F.,,.F.,.T.,.F.)
	oStructX3:SeekX3("GU3_NMEMIT")                                                                                   
	oStructTab:AddField(oStructX3:getX3Titulo(),oStructX3:getX3Titulo(),'NMEMIT'  ,'C',oStructX3:getX3Tamanho(), oStructX3:getX3Decimal(),Nil,{||.T.},Nil,.F.,,.F.,.T.,.F.)

	oStructX3:SeekX3("GWU_NRCIDO")                                                                                 
	oStructTab:AddField(oStructX3:getX3Titulo(),oStructX3:getX3Titulo(),'NRCIDO','C',oStructX3:getX3Tamanho(), oStructX3:getX3Decimal(),{|oModel| IIF(VldNrCidd(oModel:GetValue('NRCIDO'),.F.),oModel:LoadValue("NMCIDO", POSICIONE("GU7",1,XFILIAL("GU7")+oModel:GetValue('NRCIDO'),"GU7_NMCID")),.F.)},;
	                                                                                 {|oModel| VldTrecho(oModel:GetValue('SEQ'),oModel:GetValue('NRDC'),oModel:GetValue('CDTPDC'),oModel:GetValue('EMISDC'),oModel:GetValue('SERDC'),oModel:GetValue('NRCIDD'),oModel:GetValue('CDTRP'),oModel:GetValue('CDTPVC'),4)},Nil,.F.,,.F.,.T.,.F.) 
	oStructX3:SeekX3("GWU_NMCIDO")                                                                                 
	oStructTab:AddField(oStructX3:getX3Titulo(),oStructX3:getX3Titulo(),'NMCIDO','C',oStructX3:getX3Tamanho(), oStructX3:getX3Decimal(),Nil,{||.T.},Nil,.F.,,.F.,.T.,.F.)                                                                                                                    
	oStructX3:SeekX3("GWU_UFO")                                                                                  
	oStructTab:AddField(oStructX3:getX3Titulo(),oStructX3:getX3Titulo(),'UFO' ,'C',oStructX3:getX3Tamanho(), oStructX3:getX3Decimal(),Nil,{||.T.},Nil,.F.,,.F.,.T.,.F.)

	oStructX3:SeekX3("GWU_NRCIDD")                                                                                 
	oStructTab:AddField(oStructX3:getX3Titulo(),oStructX3:getX3Titulo(),'NRCIDD','C',oStructX3:getX3Tamanho(), oStructX3:getX3Decimal(),{|oModel| IIF(VldNrCidd(oModel:GetValue('NRCIDD'),.F.),oModel:LoadValue("NMCID", POSICIONE("GU7",1,XFILIAL("GU7")+oModel:GetValue('NRCIDD'),"GU7_NMCID")),.F.)},;
	                                                                                 {|oModel| VldTrecho(oModel:GetValue('SEQ'),oModel:GetValue('NRDC'),oModel:GetValue('CDTPDC'),oModel:GetValue('EMISDC'),oModel:GetValue('SERDC'),oModel:GetValue('NRCIDD'),oModel:GetValue('CDTRP'),oModel:GetValue('CDTPVC'),2)},Nil,.F.,,.F.,.T.,.F.) 
	oStructX3:SeekX3("GU7_NMCID")                                                                                 
	oStructTab:AddField(oStructX3:getX3Titulo(),oStructX3:getX3Titulo(),'NMCID','C',oStructX3:getX3Tamanho(), oStructX3:getX3Decimal(),Nil,{||.T.},Nil,.F.,,.F.,.T.,.F.)                                                                                                                    
	oStructX3:SeekX3("GU7_CDUF")                                                                                  
	oStructTab:AddField(oStructX3:getX3Titulo(),oStructX3:getX3Titulo(),'UFD' ,'C',oStructX3:getX3Tamanho(), oStructX3:getX3Decimal(),Nil,{||.T.},Nil,.F.,,.F.,.T.,.F.) 
	oStructX3:SeekX3("GWU_CDTPVC")                                                                                  
	oStructTab:AddField(oStructX3:getX3Titulo(),oStructX3:getX3Titulo(),'CDTPVC' ,'C',oStructX3:getX3Tamanho(), oStructX3:getX3Decimal(),{|oModel|Empty(oModel:GetValue('CDTPVC')) .Or. VldTpVeic(oModel:GetValue('CDTPVC'),.F.)},;
	                                                                                  {|oModel| VldTrecho(oModel:GetValue('SEQ'),oModel:GetValue('NRDC'),oModel:GetValue('CDTPDC'),oModel:GetValue('EMISDC'),oModel:GetValue('SERDC'),oModel:GetValue('NRCIDD'),oModel:GetValue('CDTRP'),oModel:GetValue('CDTPVC'))},Nil,.F.,,.F.,.T.,.F.) 
	oStructX3:SeekX3("GWU_PAGAR")                                                                                  
	oStructTab:AddField(oStructX3:getX3Titulo(),oStructX3:getX3Titulo(),'PAGAR' ,'C',oStructX3:getX3Tamanho(), oStructX3:getX3Decimal(),{|oModel|VldSentido(oModel)},{||.T.},Nil,.F.,,.F.,.T.,.F.) 
	
	oStructTab:SetProperty( "*", MODEL_FIELD_OBRIGAT, .F. )
	oStrGWU:SetProperty( "*", MODEL_FIELD_OBRIGAT, .F. )
	
	oModel:AddGrid('TRECHOS','GWUMASTER',oStructTab)
	oModel:GetModel('TRECHOS'):SetOnlyQuery(.T.)
	oModel:GetModel('TRECHOS'):SetOptional(.T.)
	oModel:GetModel('TRECHOS'):SetNoInsertLine(.T.)

	// Aumenta numero maximo de linha das GRID's
	oModel:GetModel( "TRECHOS" ):SetMaxLine( 9999 )
	oModel:GetModel( "TRECHOS" ):SetMaxLine( 9999 )
	
	oStructX3:Destroy()
	
Return oModel
/*--------------------------------------------------------------------------------------------------
{Protheus.doc} ViewDef

@sample
ViewDef()

@author Amanda Vieira
@since 25/02/2016
@version 1.0
--------------------------------------------------------------------------------------------------*/
Static Function ViewDef()
	Local oModel     :=  ModelDef()
	Local oStructTab := FWFormViewStruct():New()
	Local oView      := Nil
	Local oStructX3	:= GFESeekSX():New()
	
	oView := FWFormView():New()
	oView:SetModel(oModel)
	
	//Cria campos virtuais para a tabela temporária GWU
	oStructX3:SeekX3("GWU_CDTPDC")
	oStructTab:AddField('CDTPDC' ,'01',oStructX3:getX3Titulo(),oStructX3:getX3Titulo(),Nil,'GET',oStructX3:getX3Picture(),Nil,Nil  ,.F.,Nil,Nil,Nil,Nil,Nil,.F.) // cIdField,cOrdem,cTitulo,cDescric,aHelp,cType,cPicture,bPictVar,cLookUp,lCanChange,cFolder,cGroup,aComboValues,nMaxLenCombo,cIniBrow,lVirtual,cPictVar,lInsertLine,nWidth,lIsDeleted // Código do Produto
	
	oStructX3:SeekX3("GWU_EMISDC")
	oStructTab:AddField('EMISDC'  ,'02',oStructX3:getX3Titulo(),oStructX3:getX3Titulo(),Nil,'GET',oStructX3:getX3Picture(),Nil,Nil  ,.F.,Nil,Nil,Nil,Nil,Nil,.F.) // Quantidade
	
	oStructX3:SeekX3("GWU_SEQ")                                                                                      
	oStructTab:AddField('SEQ','03',"Trecho",oStructX3:getX3Titulo(),Nil,'GET',oStructX3:getX3Picture(),Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,.F.) // Serviço de Transferência
	
	oStructX3:SeekX3("GWU_SERDC")                                                                                      
	oStructTab:AddField("SERDC" ,'04',oStructX3:getX3Titulo(),oStructX3:getX3Titulo(),Nil,'GET',oStructX3:getX3Picture(),Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,.F.) // cIdField,cOrdem,cTitulo,cDescric,aHelp,cType,cPicture,bPictVar,cLookUp,lCanChange,cFolder,cGroup,aComboValues,nMaxLenCombo,cIniBrow,lVirtual,cPictVar,lInsertLine,nWidth,lIsDeleted // Armazém Destino
	
	oStructX3:SeekX3("GWU_NRDC")                                                                                                                                                                                                                                                                          // 
	oStructTab:AddField('NRDC' ,'05',oStructX3:getX3Titulo(),oStructX3:getX3Titulo(),Nil,'GET',oStructX3:getX3Picture(),Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,.F.) // cIdField,cOrdem,cTitulo,cDescric,aHelp,cType,cPicture,bPictVar,cLookUp,lCanChange,cFolder,cGroup,aComboValues,nMaxLenCombo,cIniBrow,lVirtual,cPictVar,lInsertLine,nWidth,lIsDeleted // Endereço Destino                                                                                                                                                                                                                                                                                                           // 
	
	oStructX3:SeekX3("GWU_CDTRP")                                                                                                                                                                                                                                                                           // 
	oStructTab:AddField('CDTRP'  ,'06',oStructX3:getX3Titulo(),oStructX3:getX3Titulo(),Nil,'GET',oStructX3:getX3Picture(),Nil,"GU3RED"  ,.T.,Nil,Nil,Nil,Nil,Nil,.F.) // cIdField,cOrdem,cTitulo,cDescric,aHelp,cType,cPicture,bPictVar,cLookUp,lCanChange,cFolder,cGroup,aComboValues,nMaxLenCombo,cIniBrow,lVirtual,cPictVar,lInsertLine,nWidth,lIsDeleted // Armazém Origem
	
	oStructX3:SeekX3("GU3_NMEMIT")                                                                                                                                                                                                                                                                           // 
	oStructTab:AddField('NMEMIT'  ,'07',oStructX3:getX3Titulo(),oStructX3:getX3Titulo(),Nil,'GET',oStructX3:getX3Picture(),Nil,Nil  ,.F.,Nil,Nil,Nil,Nil,Nil,.F.) // cIdField,cOrdem,cTitulo,cDescric,aHelp,cType,cPicture,bPictVar,cLookUp,lCanChange,cFolder,cGroup,aComboValues,nMaxLenCombo,cIniBrow,lVirtual,cPictVar,lInsertLine,nWidth,lIsDeleted // Endereço Origem
	
	oStructX3:SeekX3("GWU_NRCIDO")                                                                                                                                                                                                                                                                         // 
	oStructTab:AddField('NRCIDO','08',oStructX3:getX3Titulo(),oStructX3:getX3Titulo(),Nil,'GET',oStructX3:getX3Picture(),Nil,"GU7"  ,.T.,Nil,Nil,Nil,Nil,Nil,.F.) // cIdField,cOrdem,cTitulo,cDescric,aHelp,cType,cPicture,bPictVar,cLookUp,lCanChange,cFolder,cGroup,aComboValues,nMaxLenCombo,cIniBrow,lVirtual,cPictVar,lInsertLine,nWidth,lIsDeleted // Lote
	
	oStructX3:SeekX3("GWU_NMCIDO")                                                                                                                                                                                                                                                                         // 
	oStructTab:AddField('NMCIDO','09',oStructX3:getX3Titulo(),oStructX3:getX3Titulo(),Nil,'GET',oStructX3:getX3Picture(),Nil,Nil  ,.F.,Nil,Nil,Nil,Nil,Nil,.F.) // cIdField,cOrdem,cTitulo,cDescric,aHelp,cType,cPicture,bPictVar,cLookUp,lCanChange,cFolder,cGroup,aComboValues,nMaxLenCombo,cIniBrow,lVirtual,cPictVar,lInsertLine,nWidth,lIsDeleted // Sub-Lote
	
	oStructX3:SeekX3("GWU_UFO")
	oStructTab:AddField('UFO' ,'10',oStructX3:getX3Titulo(),oStructX3:getX3Titulo(),Nil,'GET',oStructX3:getX3Picture(),Nil,Nil  ,.F.,Nil,Nil,Nil,Nil,Nil,.F.) // cIdField,cOrdem,cTitulo,cDescric,aHelp,cType,cPicture,bPictVar,cLookUp,lCanChange,cFolder,cGroup,aComboValues,nMaxLenCombo,cIniBrow,lVirtual,cPictVar,lInsertLine,nWidth,lIsDeleted // Produto Origem
	
	oStructX3:SeekX3("GWU_NRCIDD")                                                                                                                                                                                                                                                                         // 
	oStructTab:AddField('NRCIDD','11',oStructX3:getX3Titulo(),oStructX3:getX3Titulo(),Nil,'GET',oStructX3:getX3Picture(),Nil,"GU7"  ,.T.,Nil,Nil,Nil,Nil,Nil,.F.) // cIdField,cOrdem,cTitulo,cDescric,aHelp,cType,cPicture,bPictVar,cLookUp,lCanChange,cFolder,cGroup,aComboValues,nMaxLenCombo,cIniBrow,lVirtual,cPictVar,lInsertLine,nWidth,lIsDeleted // Lote
	
	oStructX3:SeekX3("GU7_NMCID")                                                                                                                                                                                                                                                                         // 
	oStructTab:AddField('NMCID','12',oStructX3:getX3Titulo(),oStructX3:getX3Titulo(),Nil,'GET',oStructX3:getX3Picture(),Nil,Nil  ,.F.,Nil,Nil,Nil,Nil,Nil,.F.) // cIdField,cOrdem,cTitulo,cDescric,aHelp,cType,cPicture,bPictVar,cLookUp,lCanChange,cFolder,cGroup,aComboValues,nMaxLenCombo,cIniBrow,lVirtual,cPictVar,lInsertLine,nWidth,lIsDeleted // Sub-Lote
	
	oStructX3:SeekX3("GWU_UFD")
	oStructTab:AddField('UFD' ,'13',oStructX3:getX3Titulo(),oStructX3:getX3Titulo(),Nil,'GET',oStructX3:getX3Picture(),Nil,Nil  ,.F.,Nil,Nil,Nil,Nil,Nil,.F.) // cIdField,cOrdem,cTitulo,cDescric,aHelp,cType,cPicture,bPictVar,cLookUp,lCanChange,cFolder,cGroup,aComboValues,nMaxLenCombo,cIniBrow,lVirtual,cPictVar,lInsertLine,nWidth,lIsDeleted // Produto Origem
	
	oStructX3:SeekX3("GWU_CDTPVC")
	oStructTab:AddField('CDTPVC' ,'14',oStructX3:getX3Titulo(),oStructX3:getX3Titulo(),Nil,'GET',oStructX3:getX3Picture(),Nil,"GV3"  ,.T.,Nil,Nil,Nil,Nil,Nil,.F.) // cIdField,cOrdem,cTitulo,cDescric,aHelp,cType,cPicture,bPictVar,cLookUp,lCanChange,cFolder,cGroup,aComboValues,nMaxLenCombo,cIniBrow,lVirtual,cPictVar,lInsertLine,nWidth,lIsDeleted ##"Número de Serie"
	
	oStructX3:SeekX3("GWU_PAGAR")
	oStructTab:AddField('PAGAR' ,'15',oStructX3:getX3Titulo(),oStructX3:getX3Titulo(),Nil,'GET',oStructX3:getX3Picture(),Nil,Nil  ,.T.,Nil,Nil,{"1=Sim", "2=Não"},Nil,Nil,.F.) // cIdField,cOrdem,cTitulo,cDescric,aHelp,cType,cPicture,bPictVar,cLookUp,lCanChange,cFolder,cGroup,aComboValues,nMaxLenCombo,cIniBrow,lVirtual,cPictVar,lInsertLine,nWidth,lIsDeleted ##"Número de Serie"

	oView:AddOtherObject('GW1MARK',{|oPainel| MarkCarga(oPainel,oModel,oView) })
	oView:AddGrid('GWUGRID',oStructTab,'TRECHOS')
	oView:EnableTitleView('GWUGRID', "Alterar Trechos")
		
	oView:CreateHorizontalBox('DOCCARGA',40)
	oView:CreateHorizontalBox('TRECHOS',60)
		
	oView:SetOwnerView('GW1MARK','DOCCARGA')
	oView:SetOwnerView('GWUGRID','TRECHOS')

	oStructX3:Destroy()

Return oView
/*--------------------------------------------------------------------------------------------------
{Protheus.doc} CommitMdl

Realiza commit das informações da grid de trechos

@sample
GFEA050D()

@author Amanda Vieira
@since 25/02/2016
@version 1.0
--------------------------------------------------------------------------------------------------*/
Static Function CommitMdl(oModel)
	Local nI		 	:= 1
	Local lRet       	:= .T.
	Local lAltera    	:= .F.
	Local oModelGWU  	:= oModel:GetModel('TRECHOS')
	Local cQuery     	:= ""
	Local cAliasQry		:= ""
	Local cAliasGWH		:= ""

	For nI := 1 To oModelGWU:Length()
		GWU->(dbSetOrder(1)) //GWU_FILIAL+GWU_CDTPDC+GWU_EMISDC+GWU_SERDC+GWU_NRDC+GWU_SEQ
		GWU->(dbSeek(xFilial("GWU")+oModelGWU:GetValue('CDTPDC',nI)+oModelGWU:GetValue('EMISDC',nI)+oModelGWU:GetValue('SERDC',nI)+oModelGWU:GetValue('NRDC',nI)+oModelGWU:GetValue('SEQ',nI)))
		
		If !oModelGWU:isDeleted(nI) //Verifica se a linha está deletada
			RecLock("GWU",.F.)
				If GWU->GWU_CDTRP  <> oModelGWU:GetValue('CDTRP',nI) //Verifica se a informação foi alterada
					GWU->GWU_CDTRP  := oModelGWU:GetValue('CDTRP',nI)
					lAltera := .T.
				EndIf
				If GWU->GWU_NRCIDD <> oModelGWU:GetValue('NRCIDD',nI)
					GWU->GWU_NRCIDD := oModelGWU:GetValue('NRCIDD',nI)
					lAltera := .T.
				EndIf
				If GWU->GWU_NRCIDO <> oModelGWU:GetValue('NRCIDO',nI)
					GWU->GWU_NRCIDO := oModelGWU:GetValue('NRCIDO',nI)
					lAltera := .T.
				EndIf
				If GWU->GWU_CDTPVC <> oModelGWU:GetValue('CDTPVC',nI)
					GWU->GWU_CDTPVC := oModelGWU:GetValue('CDTPVC',nI)
					lAltera := .T.
				EndIf
				If GWU->GWU_PAGAR <> oModelGWU:GetValue('PAGAR',nI)
					GWU->GWU_PAGAR := oModelGWU:GetValue('PAGAR',nI)
					lAltera := .T.
				EndIf
			GWU->(MsUnLock())
		Else
			cAliasGWH := GetNextAlias()

			BeginSQL Alias cAliasGWH
				SELECT GWH.GWH_NRCALC NRCALC
				FROM %Table:GWH% GWH
				WHERE GWH.GWH_FILIAL = %Exp:GWU->GWU_FILIAL%
				AND GWH.GWH_CDTPDC = %Exp:GWU->GWU_CDTPDC%
				AND GWH.GWH_EMISDC = %Exp:GWU->GWU_EMISDC%
				AND GWH.GWH_SERDC = %Exp:GWU->GWU_SERDC%
				AND GWH.GWH_NRDC = %Exp:GWU->GWU_NRDC%
				AND GWH.GWH_TRECHO = %Exp:GWU->GWU_SEQ%
				AND GWH.%NotDel%
			EndSQL

			If !(cAliasGWH)->(Eof())
				GFEDelCalc((cAliasGWH)->NRCALC)
			EndIf

			(cAliasGWH)->(dbCloseArea())

			//-- Deleta Trecho
			RecLock("GWU",.F.)
		    	dbDelete()
		    GWU->(MsUnlock())

		    lAltera := .T.
		    
		    cQuery := " SELECT MAX(GWU_SEQ) GWU_SEQ"
			cQuery += "   FROM "+RetSqlName('GWU')
			cQuery += "  WHERE GWU_FILIAL = '"+xFilial('GWU')+"'"
			cQuery += "    AND GWU_CDTPDC = '"+oModelGWU:GetValue('CDTPDC',nI)+"'"
			cQuery += "    AND GWU_EMISDC = '"+oModelGWU:GetValue('EMISDC',nI)+"'"
			cQuery += "    AND GWU_SERDC  = '"+oModelGWU:GetValue('SERDC',nI)+"'"
			cQuery += "    AND GWU_NRDC   = '"+oModelGWU:GetValue('NRDC',nI)+"'"
			cQuery += "    AND D_E_L_E_T_ = ''"
			cQuery := ChangeQuery(cQuery)
			cAliasQry := GetNextAlias()
			DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
			
			//Em consequência de ter último trecho excluído, é necessário que o 'novo' último trecho tenha como cidade de destino o código de destinatário do documento de carga
			If (cAliasQry)->(!EoF())
				GW1->(dbSetOrder(1)) //GWU_FILIAL+GWU_CDTPDC+GWU_EMISDC+GWU_SERDC+GWU_NRDC+GWU_SEQ
				GW1->(dbSeek(xFilial("GW1")+oModelGWU:GetValue('CDTPDC',nI)+oModelGWU:GetValue('EMISDC',nI)+oModelGWU:GetValue('SERDC',nI)+oModelGWU:GetValue('NRDC',nI)))

				GWU->(dbSetOrder(1)) //GWU_FILIAL+GWU_CDTPDC+GWU_EMISDC+GWU_SERDC+GWU_NRDC+GWU_SEQ
				GWU->(dbSeek(GW1->GW1_FILIAL+GW1->GW1_CDTPDC+GW1->GW1_EMISDC+GW1->GW1_SERDC+GW1->GW1_NRDC+(cAliasQry)->GWU_SEQ))

				RecLock("GWU",.F.)
					GWU->GWU_NRCIDD := POSICIONE("GU3",1,XFILIAL("GU3")+GW1->GW1_CDDEST,"GU3_NRCID")
				GWU->(MsUnLock())

				If (cAliasQry)->GWU_SEQ == "01"
					RecLock("GW1", .F.)
						GW1->GW1_TPFRET := Tira1(GW1->GW1_TPFRET)
					GW1->(MsUnLock())

					If !Empty(GWU->GWU_DTENT) .And. !Empty(GWU->GWU_HRENT)
						RecLock("GW1", .F.)
							GW1->GW1_SIT := "5"
						GW1->(MsUnLock())

						GFEA050LIB (.F.,"Liberado pela rotina de redespacho",dData,cHora)		
						
						RecLock("GWN", .F.)
							GWN->GWN_SIT := "4"
						GWN->(MsUnlock())

						dData := ""
						cHora := ""
					EndIf
				EndIf				
			EndIf
			(cAliasQry)->(dbCloseArea())
		EndIf	
	Next nI
	
	//Verifica se ocorreram alterações no model
	If !lAltera 
		oModel:GetModel():SetErrorMessage( , ,  , '', "GFEA050D", "Formulário não alterado, não precisa ser salvo.")
		lRet := .F.
	Else
		If !Empty(dData) .And. !Empty(cHora) .And. MsgYesNo("Deseja liberar novamente o romaneio?" )
			GFEA050LIB (.F.,"Liberado pela rotina de redespacho",dData,cHora)		
		EndIf		 
	EndIf

	dData := ""
	cHora := ""
Return lRet
/*--------------------------------------------------------------------------------------------------
{Protheus.doc} MarkCarga
Monta browse de marcação para os documentos de carga (GW1)

@sample
MarkCarga()

@author Amanda Vieira
@since 25/02/2016
@version 1.0
--------------------------------------------------------------------------------------------------*/
Static Function MarkCarga(oPainel,oModel,oView)
	Local aAreaAnt   := GetArea()
	Local aCamposGW1 := {} 
	Local aFieldGW1  := {}
	Local aFilterGW1 := {}
	Local aSeek      := {}
	Local lMarcar    := .F.
	Local oMarkGW1   := Nil
	Local oStructX3		:= GFESeekSX():New()

	//Cria array com campos que serão mostrados em tela
	oStructX3:SeekX3("GW1_FILIAL")
	Aadd(aFieldGW1,  {oStructX3:getX3Titulo(),"FILIAL_GW1",  "C", oStructX3:getX3Tamanho(), oStructX3:getX3Decimal(), oStructX3:getX3Picture()})
	AAdd(aFilterGW1, {"FILIAL_GW1", oStructX3:getX3Titulo(), "C", oStructX3:getX3Tamanho(), oStructX3:getX3Decimal(), oStructX3:getX3Picture()})
	
	oStructX3:SeekX3("GW1_CDTPDC")
	Aadd(aFieldGW1,{oStructX3:getX3Titulo(),"CDTPDC_GW1","C", oStructX3:getX3Tamanho(), oStructX3:getX3Decimal(),oStructX3:getX3Picture()})
	AAdd(aFilterGW1, {"CDTPDC_GW1", oStructX3:getX3Titulo(), "C", oStructX3:getX3Tamanho(), oStructX3:getX3Decimal(),oStructX3:getX3Picture()})
	
	oStructX3:SeekX3("GW1_EMISDC")
	Aadd(aFieldGW1,{oStructX3:getX3Titulo(),"EMISDC_GW1","C", oStructX3:getX3Tamanho(), oStructX3:getX3Decimal(),oStructX3:getX3Picture()})
	AAdd(aFilterGW1, {"EMISDC_GW1", oStructX3:getX3Titulo(), "C", oStructX3:getX3Tamanho(), oStructX3:getX3Decimal(),oStructX3:getX3Picture()})
	
	oStructX3:SeekX3("GU3_NMEMIT")
	Aadd(aFieldGW1,{oStructX3:getX3Titulo(),"NMEMIT_GU3","C", oStructX3:getX3Tamanho(), oStructX3:getX3Decimal(),oStructX3:getX3Picture()})
	AAdd(aFilterGW1, {"NMEMIT_GU3", oStructX3:getX3Titulo(), "C", oStructX3:getX3Tamanho(), oStructX3:getX3Decimal(),oStructX3:getX3Picture()})
	
	oStructX3:SeekX3("GW1_DTEMIS")
	Aadd(aFieldGW1,{oStructX3:getX3Titulo(),"DTEMIS_GW1","C", oStructX3:getX3Tamanho(), oStructX3:getX3Decimal(),oStructX3:getX3Picture()})
	AAdd(aFilterGW1, {"DTEMIS_GW1", oStructX3:getX3Titulo(), "C", oStructX3:getX3Tamanho(), oStructX3:getX3Decimal(),oStructX3:getX3Picture()})
	
	oStructX3:SeekX3("GW1_SERDC")
	Aadd(aFieldGW1,{oStructX3:getX3Titulo(),"SERDC_GW1" ,"C", oStructX3:getX3Tamanho(), oStructX3:getX3Decimal(),oStructX3:getX3Picture()})
	AAdd(aFilterGW1, {"SERDC_GW1", oStructX3:getX3Titulo(), "C", oStructX3:getX3Tamanho(), oStructX3:getX3Decimal(),oStructX3:getX3Picture()})
	
	oStructX3:SeekX3("GW1_NRDC")
	Aadd(aFieldGW1,{oStructX3:getX3Titulo(),"NRDC_GW1"  ,"C", oStructX3:getX3Tamanho(), oStructX3:getX3Decimal(),oStructX3:getX3Picture()})
	AAdd(aFilterGW1, {"NRDC_GW1", oStructX3:getX3Titulo(), "C", oStructX3:getX3Tamanho(), oStructX3:getX3Decimal(),oStructX3:getX3Picture()})
	
	oStructX3:SeekX3("GW1_CDREM")
	Aadd(aFieldGW1,{oStructX3:getX3Titulo(),"CDREM_GW1" ,"C", oStructX3:getX3Tamanho(), oStructX3:getX3Decimal(),oStructX3:getX3Picture()})
	AAdd(aFilterGW1, {"CDREM_GW1", oStructX3:getX3Titulo(), "C", oStructX3:getX3Tamanho(), oStructX3:getX3Decimal(),oStructX3:getX3Picture()})
	
	oStructX3:SeekX3("GU3_NMEMIT")
	Aadd(aFieldGW1,{oStructX3:getX3Titulo(),"NMRED_GU3" ,"C", oStructX3:getX3Tamanho(), oStructX3:getX3Decimal(),oStructX3:getX3Picture()})
	AAdd(aFilterGW1, {"NMRED_GU3", oStructX3:getX3Titulo(), "C", oStructX3:getX3Tamanho(), oStructX3:getX3Decimal(),oStructX3:getX3Picture()})
	
	//Pesquisar - Chave primária  //GW1_FILIAL+GW1_CDTPDC+GW1_EMISDC+GW1_SERDC+GW1_NRDC
	Aadd( aSeek, { "Filial + Tp Doc + Emissor + Serie + Numero",;
	{ {"",aFieldGW1[1][3],aFieldGW1[1][4],aFieldGW1[1][5],aFieldGW1[1][1],aFieldGW1[1][6]},;
	  {"",aFieldGW1[2][3],aFieldGW1[2][4],aFieldGW1[2][5],aFieldGW1[2][1],aFieldGW1[2][6]},;	
	  {"",aFieldGW1[3][3],aFieldGW1[3][4],aFieldGW1[3][5],aFieldGW1[3][1],aFieldGW1[3][6]},;
	  {"",aFieldGW1[6][3],aFieldGW1[6][4],aFieldGW1[6][5],aFieldGW1[6][1],aFieldGW1[6][6]},;
	  {"",aFieldGW1[7][3],aFieldGW1[7][4],aFieldGW1[7][5],aFieldGW1[7][1],aFieldGW1[7][6]}},1})
	 
	 //Pesquisar GW1_FILIAL+DTOS(GW1_DTEMIS)+GW1_EMISDC Data Emissao + Emissor
	 Aadd( aSeek, { "Filial + Data Emissao + Emissor",;
	{ {"",aFieldGW1[1][3],aFieldGW1[1][4],aFieldGW1[1][5],aFieldGW1[1][1],aFieldGW1[1][6]},;	
	  {"",aFieldGW1[3][3],aFieldGW1[3][4],aFieldGW1[3][5],aFieldGW1[3][1],aFieldGW1[3][6]}},2})
	
	//Pesquisar GW1_FILIAL+GW1_NRDC Numero
	 Aadd( aSeek, { "Filial + Numero",;
	{ {"",aFieldGW1[1][3],aFieldGW1[1][4],aFieldGW1[1][5],aFieldGW1[1][1],aFieldGW1[1][6]},;	
	  {"",aFieldGW1[7][3],aFieldGW1[7][4],aFieldGW1[7][5],aFieldGW1[7][1],aFieldGW1[7][6]}},3})
	
	//Cria tabela temporária	
	CriaTabGW1(@aCamposGW1)		
	//Carrega dados da tabela temporária
	CarregaGW1(aCamposGW1)
	
	oMarkGW1 := FWMarkBrowse():New()
	oMarkGW1:SetDescription("Documento de Carga") 
	oMarkGW1:SetAlias(cAliasGW1D)
	oMarkGW1:SetOwner(oPainel)
	oMarkGW1:SetFieldMark('OK_GW1')
	oMarkGW1:SetTemporary(.T.)
	oMarkGW1:SetSeek(.T.,aSeek)
	oMarkGW1:SetFields( aFieldGW1 )
	oMarkGW1:bAllMark := { || SetMarkAll(oMarkGW1:Mark(),lMarcar := !lMarcar, 'GW1', oModel ), oMarkGW1:Refresh(.T.),SetTrechos(oModel), oView:Refresh()}
	oMarkGW1:SetAfterMark({|| SetTrechos(oModel), oView:Refresh() })
	oMarkGW1:oBrowse:AddButton("Alterar Lote",{ || GFEA050DINC(oModel),oMarkGW1:Refresh(.T.),SetTrechos(oModel), oView:Refresh() },,3)
	oMarkGW1:oBrowse:AddButton("Filtrar",{ || GFEA050DFR(oMarkGW1,aFilterGW1),SetTrechos(oModel), oView:Refresh() },,2)  
	oMarkGW1:SetMenuDef('')
	oMarkGW1:SetWalkThru(.F.)
	oMarkGW1:Activate()
	
	RestArea(aAreaAnt)
	oStructX3:Destroy()
Return 
/*--------------------------------------------------------------------------------------------------
{Protheus.doc} SetMarkAll
Marca/Desmarca todos os documentos de carga 

@sample
SetMarkAll()

@author Amanda Vieira
@since 25/02/2016  
@version 1.0
--------------------------------------------------------------------------------------------------*/
Static Function SetMarkAll(cMarca,lMarcar,cTable,oModel )
	Local aAreaTable  := (cTable)->( GetArea() )

	//----------------------------------------
	// Seleciona todos GW1 para marcação/desmarcação
	//----------------------------------------
	(cAliasGW1D)->(dbSetOrder(1))
	(cAliasGW1D)->(dbGoTop() )
	While !(cAliasGW1D)->(Eof())

		RecLock( cAliasGW1D, .F. )
			(cAliasGW1D)->OK_GW1 := IIf( lMarcar, cMarca, '  ' )
		MsUnLock()

		(cAliasGW1D)->(dbSkip())
	EndDo

	RestArea( aAreaTable )
Return .T.
/*--------------------------------------------------------------------------------------------------
{Protheus.doc} CarregaGW1
Carrega dados da tabela temporária dos documentos de carga

@Parametros
CarregaGW1()

@author Amanda Vieira
@since 25/02/2016  
@version 1.0
--------------------------------------------------------------------------------------------------*/
Static Function CarregaGW1(arrayCampos)
	Local cAliasQry
	Local cQuery
	Local nCont 	:= 0
	Local nCont1	:= 0
	Local aTab  	:= {}

    //-------------------------------------------------------------------
    // Limpa tabela temporária
    //-------------------------------------------------------------------
    dbSelectArea(cAliasGW1D)
	(cAliasGW1D)->( dbSetOrder(1) )
    ZAP
	
    //-------------------------------------------------------------------
    // Carga de dados
    //-------------------------------------------------------------------	
	cQuery := " SELECT DISTINCT GW1_FILIAL,"
	cQuery += "        GW1.GW1_NRDC,"
	cQuery += "        GW1.GW1_TPFRET,"
	cQuery += "        GW1.GW1_CDTPDC,"
	cQuery += "        GW1.GW1_EMISDC,"
	cQuery += "        GW1.GW1_SERDC,"
	cQuery += "        GW1.GW1_DTEMIS,"
	cQuery += "        GW1.GW1_CDREM"
	cQuery += " FROM "+RetSqlName('GW1')+" GW1"
	cQuery += " LEFT JOIN "+RetSqlName('GWH')+" GWH ON GWH.GWH_FILIAL = GW1.GW1_FILIAL"
	cQuery += " AND GWH.GWH_CDTPDC = GW1.GW1_CDTPDC"
	cQuery += " AND GWH.GWH_EMISDC = GW1.GW1_EMISDC"
	cQuery += " AND GWH.GWH_SERDC  = GW1.GW1_SERDC"
	cQuery += " AND GWH.GWH_NRDC   = GW1.GW1_NRDC"
	cQuery += " AND GWH.D_E_L_E_T_ = ' '"
	cQuery += " LEFT JOIN "+RetSqlName('GWF')+" GWF ON GWF.GWF_FILIAL = GWH.GWH_FILIAL" 
	cQuery += " AND GWF.GWF_NRCALC = GWH_NRCALC"
	cQuery += " AND GWF.D_E_L_E_T_ = ' '"
	cQuery += " LEFT JOIN "+RetSqlName('GXD')+" GXD ON GXD.GXD_FILIAL = GWH.GWH_FILIAL"
	cQuery += " AND GXD.GXD_NRCALC = GWH.GWH_NRCALC"
	cQuery += " AND GXD.D_E_L_E_T_ = ' '"
	cQuery += " LEFT JOIN "+RetSqlName('GXE')+" GXE ON GXE.GXE_FILIAL = GXD.GXD_FILIAL"
	cQuery += " AND GXE.GXE_CODLOT = GXD.GXD_CODLOT"
	cQuery += " AND GXE.D_E_L_E_T_ = ' '"
	If GFXCP1212210('GW1_FILROM')
		cQuery += " WHERE GW1.GW1_FILROM = '"+GWN->GWN_FILIAL+"'"
	Else
		cQuery += " WHERE GW1.GW1_FILIAL = '"+GWN->GWN_FILIAL+"'"
	EndIf	
	cQuery += "   AND GW1.GW1_NRROM = '"+GWN->GWN_NRROM+"'"
	cQuery += "   AND GW1.GW1_TPFRET IN ('2','4','6')"
	cQuery += "   AND (GXE.GXE_SIT NOT IN ('2|3|4|5')"
	cQuery += "        OR GXE.GXE_SIT IS NULL)"
	cQuery += "   AND (GWF.GWF_ORIGEM = '1'"
	cQuery += "       OR GWF.GWF_ORIGEM = '2'"
	cQuery += "       OR GWF.GWF_ORIGEM = '4'"
	cQuery += "       OR GWF.GWF_ORIGEM IS NULL)  
	cQuery += "   AND GW1.D_E_L_E_T_ = ''"
	cQuery := ChangeQuery(cQuery)
	cAliasQry := GetNextAlias()
	dbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)
	TcSetField(cAliasQry,'GW1_DTEMIS','D',8,0)
	
	While (cAliasQry)->(!Eof())
		Aadd(aTab,{ " ",;
			(cAliasQry)->GW1_FILIAL,;
			(cAliasQry)->GW1_CDTPDC,;
			(cAliasQry)->GW1_EMISDC,;
			POSICIONE("GU3",1,XFILIAL("GU3")+(cAliasQry)->GW1_EMISDC,"GU3_NMEMIT"),;
			DtoC((cAliasQry)->GW1_DTEMIS),;
			(cAliasQry)->GW1_SERDC,;
			(cAliasQry)->GW1_NRDC,;
			(cAliasQry)->GW1_CDREM,;
			POSICIONE("GU3",1,XFILIAL("GU3")+(cAliasQry)->GW1_CDREM,"GU3_NMEMIT")})
		(cAliasQry)->(dbSkip())
	EndDo
	
    For nCont := 1 To Len(aTab)
        RecLock(cAliasGW1D,.T.)
			//Inicia a contagem como 2, ignorando o campo "marca/desmarca" que não existe na tabela física
			For nCont1 := 2 To Len(arrayCampos)
				(cAliasGW1D)->&(arrayCampo[nCont1,1]) := aTab[nCont,nCont1]
			Next
        MsUnLock(cAliasGW1D)
    Next
    dbGoTop()
 	(cAliasQry)->(dbCloseArea())
Return cAliasGW1D
/*--------------------------------------------------------------------------------------------------
{Protheus.doc} SetTrechos
Carrega dados da tabela temporária dos trechos

@sample
SetTrechos()

@author Amanda Vieira
@since 25/02/2016  
@version 1.0
--------------------------------------------------------------------------------------------------*/
Static Function SetTrechos(oModel)
	Local cAliasQry := ""
	Local cQuery    := ""
	Local nI        := 1
	Local aAreaTemp := (cAliasGW1D)->(GetArea())
	
	oModel:GetModel('TRECHOS'):SetNoInsertLine(.F.)
	oModel:GetModel("TRECHOS"):ClearData()
	oModel:GetModel("TRECHOS"):InitLine()
	oModel:GetModel("TRECHOS"):GoLine(1)

	//Busca documentos de carga marcados para formar grid com seus trechos
	(cAliasGW1D)->(dbGoTop())
	While (cAliasGW1D)->(!Eof()) 
		If !Empty((cAliasGW1D)->OK_GW1)
	    	// Carga de dados
			cQuery := " SELECT GWU_CDTPDC,GWU_EMISDC,GWU_SEQ,GWU_SERDC,GWU_NRDC,GWU_CDTRP,GWU_NRCIDO,GWU_NRCIDD,GWU_CDTPVC,GWU_PAGAR "
			cQuery += " FROM "+RetSqlName('GWU')+" "
			cQuery += " WHERE GWU_FILIAL = '"+xFilial('GWU')+"'" 
			cQuery += "	AND GWU_CDTPDC = '"+(cAliasGW1D)->CDTPDC_GW1+"'"
			cQuery += "   AND GWU_EMISDC = '"+(cAliasGW1D)->EMISDC_GW1+"'"
			cQuery += "   AND GWU_SERDC  = '"+(cAliasGW1D)->SERDC_GW1+ "'"
			cQuery += "   AND GWU_NRDC   = '"+(cAliasGW1D)->NRDC_GW1+  "'"
			cQuery += "   AND D_E_L_E_T_ = ' '"
			cQuery := ChangeQuery(cQuery)
			cAliasQry := GetNextAlias()
			dbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)
			
			While (cAliasQry)->(!Eof())
				If !Empty(oModel:GetModel('TRECHOS'):GetValue('CDTPDC'))
					oModel:GetModel('TRECHOS'):AddLine()
					oModel:GetModel('TRECHOS'):GoLine(++nI)
				EndIf	
				
				oModel:GetModel("TRECHOS"):LoadValue("CDTPDC",(cAliasQry)->GWU_CDTPDC)	
				oModel:GetModel("TRECHOS"):LoadValue("EMISDC",(cAliasQry)->GWU_EMISDC)
				oModel:GetModel("TRECHOS"):LoadValue("SEQ"   ,(cAliasQry)->GWU_SEQ)
				oModel:GetModel("TRECHOS"):LoadValue("SERDC" ,(cAliasQry)->GWU_SERDC)
				oModel:GetModel("TRECHOS"):LoadValue("NRDC"  ,(cAliasQry)->GWU_NRDC)
				oModel:GetModel("TRECHOS"):LoadValue("CDTRP" ,(cAliasQry)->GWU_CDTRP)
				oModel:GetModel("TRECHOS"):LoadValue("NMEMIT",POSICIONE("GU3",1,XFILIAL("GU3")+(cAliasQry)->GWU_CDTRP,"GU3_NMEMIT"))
				oModel:GetModel("TRECHOS"):LoadValue("NRCIDO",(cAliasQry)->GWU_NRCIDO)
				oModel:GetModel("TRECHOS"):LoadValue("NMCIDO" ,POSICIONE("GU7",1,XFILIAL("GU7")+(cAliasQry)->GWU_NRCIDO,"GU7_NMCID"))
				oModel:GetModel("TRECHOS"):LoadValue("UFO"   ,POSICIONE("GU7",1,XFILIAL("GU7")+(cAliasQry)->GWU_NRCIDO,"GU7_CDUF"))
				oModel:GetModel("TRECHOS"):LoadValue("NRCIDD",(cAliasQry)->GWU_NRCIDD)
				oModel:GetModel("TRECHOS"):LoadValue("NMCID" ,POSICIONE("GU7",1,XFILIAL("GU7")+(cAliasQry)->GWU_NRCIDD,"GU7_NMCID"))
				oModel:GetModel("TRECHOS"):LoadValue("UFD"   ,POSICIONE("GU7",1,XFILIAL("GU7")+(cAliasQry)->GWU_NRCIDD,"GU7_CDUF"))
				oModel:GetModel("TRECHOS"):LoadValue("CDTPVC",(cAliasQry)->GWU_CDTPVC)
				oModel:GetModel("TRECHOS"):LoadValue("PAGAR" ,(cAliasQry)->GWU_PAGAR)	
				(cAliasQry)->(dbSkip())
			EndDo
			(cAliasQry)->(dbCloseArea())
		EndIf
		(cAliasGW1D)->(dbSkip())
	EndDo
	
	oModel:GetModel('TRECHOS'):GoLine(1)
	oModel:GetModel('TRECHOS'):SetNoInsertLine(.T.)

	RestArea(aAreaTemp)
Return Nil
/*--------------------------------------------------------------------------------------------------
{Protheus.doc} CriaTabGW1
Cria tabela temporária dos documentos de carga (GW1)

@sample
CriaTabGW1()

@author Amanda Vieira
@since 25/02/2016  
@version 1.0
--------------------------------------------------------------------------------------------------*/
Static Function CriaTabGW1(aCamposGW1)
	Local oStructX3		:= GFESeekSX():New()
	
	Aadd(aCamposGW1,{"OK_GW1","C",1,0})

	oStructX3:SeekX3("GW1_FILIAL")
	Aadd(aCamposGW1,{"FILIAL_GW1","C",oStructX3:getX3Tamanho(),oStructX3:getX3Decimal()})

	oStructX3:SeekX3("GW1_CDTPDC")
	Aadd(aCamposGW1,{"CDTPDC_GW1","C",oStructX3:getX3Tamanho(),oStructX3:getX3Decimal()})

	oStructX3:SeekX3("GW1_EMISDC")
	Aadd(aCamposGW1,{"EMISDC_GW1","C",oStructX3:getX3Tamanho(),oStructX3:getX3Decimal()})

	oStructX3:SeekX3("GU3_NMEMIT")
	Aadd(aCamposGW1,{"NMEMIT_GU3","C",oStructX3:getX3Tamanho(),oStructX3:getX3Decimal()})

	oStructX3:SeekX3("GW1_DTEMIS")
	Aadd(aCamposGW1,{"DTEMIS_GW1","C",10,oStructX3:getX3Decimal()})

	oStructX3:SeekX3("GW1_SERDC")
	Aadd(aCamposGW1,{"SERDC_GW1","C",oStructX3:getX3Tamanho(),oStructX3:getX3Decimal()})

	oStructX3:SeekX3("GW1_NRDC")
	Aadd(aCamposGW1,{"NRDC_GW1","C",oStructX3:getX3Tamanho(),oStructX3:getX3Decimal()})

	oStructX3:SeekX3("GW1_CDREM")
	Aadd(aCamposGW1,{"CDREM_GW1","C",oStructX3:getX3Tamanho(),oStructX3:getX3Decimal()})

	oStructX3:SeekX3("GU3_NMEMIT")
	Aadd(aCamposGW1,{"NMRED_GU3","C",oStructX3:getX3Tamanho(),oStructX3:getX3Decimal()})
	
	If Empty(cAliasGW1D) // Criação da temporária de seleção GW1
		cAliasGW1D := GFECriaTab({aCamposGW1,{"FILIAL_GW1+CDTPDC_GW1+EMISDC_GW1+SERDC_GW1+NRDC_GW1","FILIAL_GW1+DTEMIS_GW1+EMISDC_GW1","FILIAL_GW1+NRDC_GW1"}})
	EndIf
	oStructX3:Destroy()
Return Nil
/*--------------------------------------------------------------------------------------------------
{Protheus.doc} GFEA050DINC
Tela de alteração de redespachantes por lote

@sample
GFEA050DINC()

@author Amanda Vieira
@since 25/02/2016
@version 1.0
--------------------------------------------------------------------------------------------------*/
Static Function GFEA050DINC(oModel)
	Local aItems      := {'Sim','Não',''}
	Local nOpc        := 0
	Local oDlg        := NIL
	Local oSize       := Nil
	Local oPanel      := Nil
	Local oCombo      := Nil
	Local bOk         := {|| nOpc := 1, oDlg:End() }
	Local bCancel     := {|| nOpc := 0, oDlg:End() }
	Local cSequen     := Space(TamSX3("GWU_SEQ")[1])
	Local cCdTpVc     := Space(TamSX3("GWU_CDTPVC")[1])
	Local cCdTrp	  := Space(TamSX3("GWU_CDTRP")[1])
	Local cNrCidd	  := Space(TamSX3("GWU_NRCIDD")[1])
	Local cNrCidO	  := Space(TamSX3("GWU_NRCIDO")[1])
	Local cPago       := ""
	Local lRet        := .T.
	Local lHasGW1     := .F.
	
	//Valida se há GW1 selecionada
	(cAliasGW1D)->(dbGoTop())	
	While !(cAliasGW1D)->(Eof()) .And. !lHasGW1
		If !Empty((cAliasGW1D)->OK_GW1)
			lHasGW1 := .T.
		EndIf
		(cAliasGW1D)->(dbSkip())
	EndDo

	If !lHasGW1
		MsgInfo("Não há documentos de carga selecionados para a alteração em lote.")
		Return lRet
	EndIf
	
	oSize := FWDefSize():New(.T.)
	oSize:AddObject( "ENCHOICE", 100, 20, .T., .T. ) // Adiciona enchoice
	oSize:SetWindowSize({000, 000, 260, 600})
	oSize:lLateral := .F.  // Calculo vertical
	oSize:Process() //executa os calculos

	DEFINE MSDIALOG oDlg TITLE "Alterar trechos em lote";
							FROM oSize:aWindSize[1],oSize:aWindSize[2] ;
							TO oSize:aWindSize[3],oSize:aWindSize[4] ;
							PIXEL OF oMainWnd
							
	oDlg:lEscClose := .F.				
			
	oPanel := tPanel():New(oSize:GetDimension("ENCHOICE","LININI"),;
	                       oSize:GetDimension("ENCHOICE","COLINI"),;
	                       "",oDlg,,,,,,;
	                       oSize:GetDimension("ENCHOICE","XSIZE"),;
	                       oSize:GetDimension("ENCHOICE","YSIZE"))
	
	// Combo box 
    cPago := aItems[1] //Vertical Horizontal       
	oCombo := TComboBox():New(80,55,{|u|if(PCount()>0,cPago:=u,cPago)},;
	aItems,50,14,oPanel,,;
	,,,,.T.,,,,,,,,,'cPago')
						
	@ 07,10  Say "Seq. do trecho: " Of oPanel COLOR CLR_BLACK Pixel
	@ 05,55  MSGET cSequen Picture "@!"  Of oPanel Valid !Empty(cSequen) When .T. SIZE 10,10 Pixel 
		
	@ 22,10  Say "Transportadora: " Of oPanel COLOR CLR_BLACK Pixel
	@ 20,55  MSGET cCdTrp Picture "@!"  F3 "GU3RED"  Of oPanel Valid Empty(cCdTrp) .Or. VldTransp(cCdTrp) When .T. SIZE 70,10  Pixel
	@ 20,130 MSGET POSICIONE("GU3",1,XFILIAL("GU3")+cCdTrp,"GU3_NMEMIT") Picture "@!" Of oPanel  When .F. SIZE 160,10  Pixel
		
	@ 37,10  Say "Cidade Origem.: " Of oPanel COLOR CLR_BLACK Pixel 
	@ 35,55  MSGET cNrCidO Picture "@!" F3 "GU7" Of oPanel   Valid  Empty(cNrCidO) .Or. VldNrCidd(cNrCidO) When .T. SIZE 35,10   Pixel  			
	@ 35,95  MSGET POSICIONE("GU7",1,XFILIAL("GU7")+cNrCidO,"GU7_NMCID") Picture "@!" Of oPanel   When .F. SIZE 175,10   Pixel 			 		
	@ 35,275 MSGET POSICIONE("GU7",1,XFILIAL("GU7")+cNrCidO,"GU7_CDUF")  Picture "@!" Of oPanel   When .F. SIZE 10,10   Pixel	
		                    
	@ 52,10  Say "Cidade Dest.: " Of oPanel COLOR CLR_BLACK Pixel 
	@ 50,55  MSGET cNrCidd Picture "@!" F3 "GU7" Of oPanel   Valid  Empty(cNrCidd) .Or. VldNrCidd(cNrCidd) When .T. SIZE 35,10   Pixel  			
	@ 50,95  MSGET POSICIONE("GU7",1,XFILIAL("GU7")+cNrCidd,"GU7_NMCID") Picture "@!" Of oPanel   When .F. SIZE 175,10   Pixel 			 		
	@ 50,275 MSGET POSICIONE("GU7",1,XFILIAL("GU7")+cNrCidd,"GU7_CDUF")  Picture "@!" Of oPanel   When .F. SIZE 10,10   Pixel
	                        
	@ 67,10 Say "Tipo de Veiculo: "  Of oPanel COLOR CLR_BLACK Pixel 
	@ 65,55 MSGET cCdTpvc Picture "@!" F3 "GV3" Of oPanel   Valid  Empty(cCdTpvc) .Or. VldTpVeic(cCdTpvc) When .T.  SIZE 50,10  Pixel 			 		
	
	@ 82,10  Say "Frete Pago?" SIZE 40,10  Of oPanel COLOR CLR_BLACK Pixel //"Frete Pago?"
	
	ACTIVATE MSDIALOG oDlg On Init EnchoiceBar(oDlg,bOk,bCancel) CENTERED
	
	If nOpc == 1 //Ato de confirmar
		//Armazena resposta do usuário, se o trecho será pago ou não.
		If cPago == "Sim"
			cPago := "1"
		ElseIf cPago == "Não"
			cPago := "2"
		EndIf
		
		Processa({|lEnd| lRet := GFEProcAlt(cSequen,cCdTrp,cNrCidO,cNrCidd,cCdTpvc,cPago)})//Processa alteração dos trechos	
		If lRet
			MsgInfo("Informações alteradas com sucesso.")
		EndIf
	EndIf 
	
Return lRet 
/*--------------------------------------------------------------------------------------------------
{Protheus.doc} GFEProcAlt
Processa a alteração do trecho dos documentos marcados pelo usuário.

@sample
GFEProcAlt()

-cSequen = Sequência do trecho que será alterado
-cCdTrp  = Código do transportador informado pelo usuário
-cNrCido = Número da cidade de origem  informado pelo usuário
-cNrCidd = Número da cidade de destino informado pelo usuário
-cCdTpvc = Código do tipo do veículo informado pelo usuário

@author Amanda Vieira
@since 15/06/2016
@version 1.0
--------------------------------------------------------------------------------------------------*/
Static Function GFEProcAlt(cSequen,cCdTrp,cNrCidO,cNrCidd,cCdTpvc,cPago)
	Local GFEResult := GFEViewProc():New()
	Local nAlterados:= 0
	Local lRet      := .T.
	Local nGerados  := 0
	Local lErro     := .F.

	aAreaGW1  := GW1->(GetArea())
		
	dbSelectArea("GWU")
	GWU->(dbSetOrder(1)) //GWU_FILIAL+GWU_CDTPDC+GWU_EMISDC+GWU_SERDC+GWU_NRDC+GWU_SEQ
	(cAliasGW1D)->(dbGoTop())
	
	ProcRegua(0)	
		
	Begin Transaction
	While !(cAliasGW1D)->(Eof()) 
		lRet     := .T.
		cMsgErro := ""	
		If !Empty((cAliasGW1D)->OK_GW1)
			IncProc("Alterando trecho... Documento:"+(cAliasGW1D)->NRDC_GW1) //"Alterando trecho... Documento:" 
			If GWU->(dbSeek(xFilial("GWU") + (cAliasGW1D)->CDTPDC_GW1 + (cAliasGW1D)->EMISDC_GW1 + (cAliasGW1D)->SERDC_GW1 + (cAliasGW1D)->NRDC_GW1 + cSequen))
				While GWU->(!EoF()) .And. GWU->(GWU_FILIAL+GWU_CDTPDC+GWU_EMISDC+GWU_SERDC+GWU_NRDC+GWU_SEQ) == xFilial("GWU") + (cAliasGW1D)->(CDTPDC_GW1+EMISDC_GW1+SERDC_GW1+NRDC_GW1) + cSequen .And. lRet
					
					//Faz validaçãoes de primeiro e último trecho  
					lRet := VldTrecho(GWU->GWU_SEQ,GWU->GWU_NRDC,GWU->GWU_CDTPDC,GWU->GWU_EMISDC,GWU->GWU_SERDC,cNrCidd,cCdTrp,cCdTpvc,3,@cMsgErro,.F.) 
					
					//Valida sentido do documento conferindo o campo 'pagar'
					If lRet .And. !Empty(cPago)
						GFE050VLSE(GWU->GWU_CDTPDC,GWU->GWU_EMISDC,GWU->GWU_SERDC,GWU->GWU_NRDC,cPago,@cMsgErro)
					EndIf
				
					If lRet
						RecLock("GWU", .F.) 
						If !Empty(cCdTrp)
							GWU->GWU_CDTRP  := cCdTrp
						EndIf
						If !Empty(cNrCidO) 
							GWU->GWU_NRCIDO := cNrCidO
						EndIf
						If !Empty(cNrCidd) 
							GWU->GWU_NRCIDD := cNrCidd
						EndIf						
						If !Empty(cCdTpvc) 
							GWU->GWU_CDTPVC := cCdTpvc
						EndIf
						If !Empty(cPago) 
							GWU->GWU_PAGAR := cPago
						EndIf 
						MsUnLock()
						//Incrementa contador de documentos com trechos alterados
						nAlterados++
						
						if cSequen > "01" .And. lRet .And. !Empty(cNrCidO)  //Altera a cidade de destino do trecho anterior para dicar igual à de origem do alterado.
							GFEDAnt(GWU->GWU_CDTPDC,GWU->GWU_EMISDC,GWU->GWU_SERDC,GWU->GWU_NRDC,cSequen,cNrCidO)
						EndIf
					EndIf
					
					GWU->(dbSkip())
				EndDo
			Else 
				cMsgErro := "O Documento não possuí a sequência informada." 
				lRet := .F.
			EndIf
			
			If !Empty(cMsgErro)
				lErro := .T.
			   	GFEResult:AddDetail("# Filial: "+AllTrim((cAliasGW1D)->FILIAL_GW1)+" Tipo Doc: "+Alltrim((cAliasGW1D)->CDTPDC_GW1)+" Emissor: "+Alltrim((cAliasGW1D)->EMISDC_GW1)+" Série: "+Alltrim((cAliasGW1D)->SERDC_GW1)+" Documento: "+Alltrim((cAliasGW1D)->NRDC_GW1))
			   	GFEResult:AddDetail("** " + cMsgErro, 1)
			Else 
			   	nGerados++
			   	GFEResult:Add("# "+cValToChar(nAlterados)+" - Filial: "+Alltrim((cAliasGW1D)->FILIAL_GW1)+" Tipo Doc: "+Alltrim((cAliasGW1D)->CDTPDC_GW1)+" Emissor: "+Alltrim((cAliasGW1D)->EMISDC_GW1)+" Série: "+Alltrim((cAliasGW1D)->SERDC_GW1)+" Documento: "+Alltrim((cAliasGW1D)->NRDC_GW1))
			EndIf
	
		EndIf
		(cAliasGW1D)->(dbSkip())
	EndDo
	If !lRet
		DisarmTransaction()
	EndIf	
	
	End Transaction
	
	GFEResult:Add()
	// Verifica se algum trecho foi gerado
	If nGerados == 0
		GFEResult:Add("Nenhum trecho de redespacho alterado.")
	Else 
		//Se houve alguma inclusão de trecho e o romaneio já encontrava-se calculado, altera para "necessita recáculo"
		//A alteração ocorre neste ponto e não no commit do model, para evitar que o usuário feche a tela sem ter completar a alteração da situação do cálculo
		If GWN->GWN_CALC == "1" //Verifica se o romaneio encontrava-se calculado
			//Muda situação do cálculo		
			RecLock("GWN", .F.)
				GWN->GWN_CALC := "4" // Romaneio necessita recálculo
				GWN->GWN_MTCALC := "Alterado informações de trecho em documento de carga"
				GWN->GWN_DTCALC := CToD("  /  /    ")
				GWN->GWN_HRCALC := ""
			MsUnLock("GWN")
			//Caso o usuário não deseje recalcular o romaneio, o mesmo ficará com situação 'Necessita Recálculo' 
			If MsgYesNo("Deseja recalcular este romaneio?" )	// "Deseja recalcular este romaneio?" 
				GFE050CALC() // Recalcula o romaneio
			EndIf
		EndIf
	EndIf
	
	If lErro			   		
		GFEResult:Add()
	EndIf
	
	GFEResult:Show("Alteração de trecho de redespacho", "Documentos com trecho de redespacho alterado", "Erros")
	
	RestArea(aAreaGW1)
Return lRet
/*--------------------------------------------------------------------------------------------------
{Protheus.doc} GFEA050D
Valida informações da grid de trechos

@sample
GFEA050D()

@author Amanda Vieira
@since 25/02/2016
@version 1.0
--------------------------------------------------------------------------------------------------*/
Static Function ValidModel(oModel)
	Local oModelGWU  := oModel:GetModel('TRECHOS')
	Local oModelMGWU := oModel:GetModel('GWUMASTER')
	Local nI         := 0
	
	// O modelo principal precisa sofrer alguma alteração
	oModelMGWU:LoadValue("GWU_CDTPDC"," ")
	
	//Validações realizadas ao setar trecho para excluído
	For nI := 1 To oModelGWU:Length() 
		If oModelGWU:isDeleted(nI) // verifica se a linha foi deletada
			
			If oModelGWU:GetValue('SEQ',nI) == "01"
				Help( ,, 'HELP',, "Não é permitido excluir o primeiro trecho do documento de carga. ", 1, 0,)
				Return .F.
			EndIf
			
			cQuery := " SELECT MAX(GWU_SEQ) GWU_SEQ"
			cQuery += "   FROM "+RetSqlName('GWU')
			cQuery += "  WHERE GWU_FILIAL = '"+xFilial('GWU')+"'"
			cQuery += "    AND GWU_CDTPDC = '"+oModelGWU:GetValue('CDTPDC',nI)+"'"
			cQuery += "    AND GWU_EMISDC = '"+oModelGWU:GetValue('EMISDC',nI)+"'"
			cQuery += "    AND GWU_SERDC  = '"+oModelGWU:GetValue('SERDC',nI)+"'"
			cQuery += "    AND GWU_NRDC   = '"+oModelGWU:GetValue('NRDC',nI)+"'"
			cQuery += "    AND D_E_L_E_T_ = ''"
			cQuery := ChangeQuery(cQuery)
			cAliasQry := GetNextAlias()
			DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
			
			If (cAliasQry)->(!EoF())
				If oModelGWU:GetValue('SEQ',nI) <> (cAliasQry)->GWU_SEQ
					//Só é permitido excluir o último trecho do documento de carga.
					Help( ,, 'HELP',, "É permitido excluir apenas o último trecho do documento de carga.", 1, 0,)
					Return .F.
				EndIf
			EndIf
			(cAliasQry)->(dbCloseArea())
		EndIf	
	Next nI 
	
Return .T.

/*--------------------------------------------------------------------------------------------------
{Protheus.doc} GFEA050D
Valida informações da grid de trechos, no momento da digitação.
Caso for a primeira sequência, permite alteração apenas da cidade de destino,
caso tratar-se da última sequência, permite alteração apenas da transportadora, 
nos outros casos permite-se a alterção de transportadora, cidade destino e tipo do veículo.

@Parametros
cSequen -> Sequência do trecho
cNrDoc,cNrCidd,cCdTransp,cTpVeic -> Dados informados pelo usuário
nAcao -> 1=Edição do campo Cód. da Transportadora
		  2=Edição do campo Nr. Cidade Destino	
		  3=Valida Ambos
		  4=Edição do campo Nr. Cidade Origem

@author Amanda Vieira
@since 19/02/2016
@version 1.0
--------------------------------------------------------------------------------------------------*/
Static Function VldTrecho(cSequen,cNrDoc,cTpDc,cEmisDc,cSerDc,cNrCidd,cCdTransp,cTpVeic,nAcao,cMsgErro,lMensagem)
	Local aAreaAnt  := GWU->(GetArea())
	Local cQuery    := ""
	Local cAliasQry := ""

	Default nAcao    := 1
	Default cNrCidd  := ""
	Default cCdTransp:= ""
	Default cMsgErro := ""
	Default lMensagem:= .T.

	cTpDc  := Padr( cTpDc  ,TamSX3("GWU_CDTPDC")[1])
	cEmisDc:= Padr( cEmisDc,TamSX3("GWU_EMISDC")[1])
	cSerDc := Padr( cSerDc ,TamSX3("GWU_SERDC")[1])
	cNrDoc := Padr( cNrDoc ,TamSX3("GWU_NRDC")[1])
	cSequen:= Padr( cSequen,TamSX3("GWU_SEQ")[1])

	dbSelectArea('GWU')
	GWU->(dbSetOrder(1)) //GWU_FILIAL+GWU_CDTPDC+GWU_EMISDC+GWU_SERDC+GWU_NRDC+GWU_SEQ
	
	//Verifica se é  primeiro ou último trecho
	If cSequen == "01" .And. nAcao <> 2 .And. (!Empty(cCdTransp) .Or. !Empty(cTpVeic))
		cMsgErro :=  "Para o primeiro trecho do documento é permitida apenas a alteração da cidade de destino e informação de trecho pago. "  
		If lMensagem
			Help( ,, 'HELP',, cMsgErro, 1, 0,)
		EndIf
		Return .F.
	ElseIF nAcao > 1 .And. nAcao < 4
		cQuery := " SELECT MAX(GWU_SEQ) GWU_SEQ"
		cQuery += " FROM "+RetSqlName('GWU')+""
		cQuery += " WHERE GWU_FILIAL = '"+xFilial('GWU')+"'"
		cQuery += "   AND GWU_CDTPDC = '"+cTpDc+"'"
		cQuery += "   AND GWU_EMISDC = '"+cEmisDc+"'"
		cQuery += "   AND GWU_SERDC  = '"+cSerDc+"'"
		cQuery += "   AND GWU_NRDC   = '"+cNrDoc+"'"
		cQuery += "   AND D_E_L_E_T_ = ' '"
		cQuery := ChangeQuery(cQuery)
		cAliasQry := GetNextAlias()
		DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
		
		If (cAliasQry)->(!Eof()) .And. (cAliasQry)->GWU_SEQ == cSequen .And. !Empty(cNrCidd) 
			cMsgErro := "Para o último trecho do documento é permitida apenas a alteração da transportadora, da cidade de origem, do tipo do veículo e informação de trecho pago."
			If lMensagem
				Help( ,, 'HELP',, cMsgErro, 1, 0,)
			EndIf
			Return .F.
		EndIf
		(cAliasQry)->(dbCloseArea())
	EndIf 	
	RestArea(aAreaAnt)
Return .T.
/*--------------------------------------------------------------------------------------------------
{Protheus.doc} GFEA050D
Valida transportadora

@sample
GFEA050D()

@author Amanda Vieira
@since 25/02/2016
@version 1.0
--------------------------------------------------------------------------------------------------*/
Static Function VldTransp(cCdTrp,lMsg,oModel)
	Default lMsg   := .T.
	Default oModel := Nil
	
	//Verifica se a transportadora existe e é válida.
	GU3->(dbSetOrder(1))//GU3_FILIAL+GU3_CDEMIT
	If GU3->(dbSeek(xFilial('GU3')+cCdTrp))
		If GU3->GU3_TRANSP != "1"
			If lMsg
				Help( ,, 'HELP',, "Transportadora Inválida. ", 1, 0,)
			EndIf
			Return .F.
		EndIf
		If GU3->GU3_REDESP != "1" .And. SuperGetMV("MV_TREDESP",, "1") == "3"
			If lMsg
				Help( ,, 'HELP',, "Informe uma transportadora redespachante. ", 1,0)
			Else
				oModel:GetModel():SetErrorMessage( , '', '' ,'', 'HELP', 'Informe uma transportadora redespachante.' , '', '')
			EndIf
			Return .F.
		EndIf
	Else
		If lMsg
			Help( ,, 'HELP',, "Transportadora Inválida. ", 1, 0,)
		EndIf
		Return .F.
	EndIf
	
Return .T.
/*--------------------------------------------------------------------------------------------------
{Protheus.doc} GFEA050D
Valida cidade destino

@sample
GFEA050D()

@author Amanda Vieira
@since 25/02/2016
@version 1.0
--------------------------------------------------------------------------------------------------*/
Static Function VldNrCidd(cNrCidd,lMsg)
	Default lMsg := .T.

	dbSelectArea("GU7")
	GU7->(dbSetOrder(1)) //GU7_FILIAL+GU7_NRCID
	
	If GU7->(!dbSeek(xFilial("GU7")+cNrCidd))
		If lMsg
			Help( ,, 'HELP',, "Cidade Inválida. ", 1, 0,)
		EndIf
		Return .F.
	EndIf
Return .T.
/*--------------------------------------------------------------------------------------------------
{Protheus.doc} GFEA050D
Valida tipo do veículo

@sample
GFEA050D()

@author Amanda Vieira
@since 25/02/2016
@version 1.0
--------------------------------------------------------------------------------------------------*/
Static Function VldTpVeic(cTpVeic,lMsg)
	Default lMsg := .T.
	
	dbSelectArea("GV3")
	GV3->(dbSetOrder(1)) //GV3_FILIAL+GV3_CDTPVC
	
	If GV3->(!dbSeek(xFilial("GV3")+cTpVeic))
		If lMsg
			Help( ,, 'HELP',, "Tipo Veículo Inválido. ", 1, 0,)
		EndIf
		Return .F.
	EndIf
Return .T.

Static Function VldSentido(oModel)
	Local aAreaGW1  := GW1->(GetArea())
	Local cTpDcSent := ""
	Local lPagar    := .F.
	Local lRet      := .T.
	Local lCIFSaida := .F.	//Valida a existencia de um trecho pago em um Doc Carga Saida CIF     
	Local lFOBSaida := .T.	//Valida a existencia de um trecho pago em um Doc Carga Saida FOB     
	Local lCIFEnt   := .T.	//Valida a existencia de um trecho pago em um Doc Carga Entrada CIF   
	Local lFOBEnt   := .F.	//Valida a existencia de um trecho pago em um Doc Carga Entrada FOB  
	Local nI        := 0
	
	dbSelectArea('GW1')
	GW1->(dbSetOrder(1))
	GW1->(dbSeek(xFilial('GW1')+oModel:GetValue('CDTPDC')+oModel:GetValue('EMISDC')+oModel:GetValue('SERDC')+oModel:GetValue('NRDC')))
	
	cTpDcSent := Posicione("GV5",1,xFilial("GV5")+GW1->GW1_CDTPDC,"GV5_SENTID")
	
	//Validações realizadas ao setar trecho para excluído
	 For nI := 1 To oModel:Length()
		If !oModel:isdeleted(nI) .And. oModel:GetValue('NRDC',nI) == oModel:GetValue('NRDC') //Verifica se a linha foi deletada	
			//Validação existente no programa GFEA044	
			lPagar := oModel:GetValue('PAGAR',nI) == '1'   //Idica se o trecho é pago ou se será incluído um trecho pago
			If cTpDcSent == '2' // Doc Carga com sentido Saida
				//Doc Carga Sentido Saida e CIF deve conter ao menos 1 trecho pago
				If GW1->GW1_TPFRET $ '12' .And. lPagar
					lCIFSaida := .T.
				//Doc Carga Sentido Saida e FOB não deve ter trechos pagos
			    ElseIf GW1->GW1_TPFRET $ '34' .And. lPagar
			    	lFOBSaida := .F.
			    EndIf
			ElseIf cTpDcSent == '1' // Doc Carga com sentido Entrada
				// Doc Carga com sentido Entrada e CIF não deve ter trechos pagos
			    If GW1->GW1_TPFRET $ '12' .And. lPagar
				 	lCIFEnt := .F.
				 	// Doc Carga com sentido Entrada e FOB deve conter ao menos 1 trecho pago
			   	ElseIf GW1->GW1_TPFRET $ '34' .And. lPagar
			    	lFOBEnt := .T.
				EndIf
			EndIf	
		EndIf	
	Next nI 
	
	//Mensagens de erro referentes a validação do tipo de Doc Carga e os trechos
	If !lCIFSaida .And. GW1->GW1_TPFRET $ '12' .And. cTpDcSent == '2'
		cMsgErro := 'Deve haver, pelo menos um, trecho com Pagar "Sim" quando o Tipo do Frete for "CIF" ou "CIF Redesp" e o sentido do documento for "Saida".' 
		lRet  := .F.
	ElseIf !lFOBSaida .And. GW1->GW1_TPFRET $ '34' .And. cTpDcSent == '2'
		cMsgErro := 'Não pode haver trechos com Pagar "Sim" quando o Tipo do Frete for "FOB" ou "FOB Redesp" e o sentido do documento for "Saida".' 
		lRet  := .F.
	ElseIf !lCIFEnt .And. GW1->GW1_TPFRET $ '12'  .And. cTpDcSent == '1'
		cMsgErro := 'Não pode haver trechos com Pagar "Sim" quando o Tipo do Frete for "CIF" ou "CIF Redesp" e o sentido do documento for "Entrada".' 
		lRet  := .F.
	ElseIf !lFOBEnt  .And. GW1->GW1_TPFRET $ '34'  .And. cTpDcSent == '1'
		cMsgErro := 'Deve haver, pelo menos um, trecho com Pagar "Sim" quando o Tipo do Frete for "FOB" ou "FOB Redesp" e o sentido do documento for "Entrada".' 
		lRet  := .F.
	EndIf
	
	RestArea(aAreaGW1)
Return lRet


/*--------------------------------------------------------------------------------------------------
{Protheus.doc} GFEDAnt
Altera a cidade de destino do trecho anterior ao da sequencia informada com a nova cidade de origem

@sample
GFEA050D()

@since 29/11/2018
@version 1.0
--------------------------------------------------------------------------------------------------*/
Static Function GFEDAnt(cCDTPDC,cEMISDC,cSERDC,cNRDC,cSequen,cNrCidO)
	Local iSequen := (VAL(cSequen)-1)
	
	GWU->(dbSetOrder(1)) //GWU_FILIAL+GWU_CDTPDC+GWU_EMISDC+GWU_SERDC+GWU_NRDC+GWU_SEQ
	If GWU->(dbSeek(xFilial("GWU") + cCDTPDC +cEMISDC + cSERDC + cNRDC + STRZERO(iSequen,2)))
	   RecLock("GWU", .F.) 
		
		If !Empty(cNrCidO) 
			GWU->GWU_NRCIDD := cNrCidO
		EndIf
		
    	MsUnLock()	   
	EndIf			
	GWU->(dbSkip())
	
Return .T.

Function GFEA050DFR(oBrw,aField)
	oBrwse := oBrw
	
	If Empty(oFwFilter)
		oFwFilter := FWFilter():New(oBrw:GetOwner())
		oFwFilter:SetAlias(cAliasGW1D)
		oFwFilter:SetProfileID("50D1")
		oFwFilter:SetField(aField)
		oFwFilter:DisableValid(.F.)
		oFwFilter:CleanFilter(.F.)	
		oFwFilter:LoadFilter()
		oFwFilter:SetExecute({|| GFEA050DFW(oFwFilter,oBrwse)})
	EndIf
	oFwFilter:Activate()	
Return

Function GFEA050DFW(oFwFilter,oBrw)
	Local cFiltroAdv := oFwFilter:GetExprAdvPL() 
    
	oBrw:SetFilterDefault("") 
    oBrw:SetFilterDefault(cFiltroAdv)
    If Empty(cFiltroAdv)
        (cAliasGW1D)->(DBClearfilter())
    EndIf
    oBrw:oBrowse:UpdateBrowse()
    oBrw:oBrowse:Refresh(.T.)
Return
