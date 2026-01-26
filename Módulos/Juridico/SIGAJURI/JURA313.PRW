#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "JURA313.CH"

//-------------------------------------------------------------------
/*/ { Protheus.doc } JURA313
Informações E-Social - S-2501

@author Alan 
@since 19/07/2023
@version 1.0
/*/
//-------------------------------------------------------------------

Function JURA313()
Local oBrowse	   := NIL
Local lRet         := .T.
Local lFound 	   := FwSX2Util():SeekX2File( "V7C" )

	If lFound 
		oBrowse := FWMBrowse():New()
		oBrowse:SetDescription(STR0001) // Informações do E-Social - S-2501
		oBrowse:SetAlias( "V7C" )
		oBrowse:SetLocate()
		JurSetLeg( oBrowse, "V7C" )
		JurSetBSize( oBrowse )
		oBrowse:AddLegend( "V7C_ATIVO=='1'", "GREEN")
		oBrowse:AddLegend( "V7C_ATIVO=='2'", "RED"  )
		oBrowse:Activate()
	Else 
		JurMsgError(STR0005,,; //'Para correto funcionamento desta configuração, deverá possuir a tabela V7Cno dicionário de dados.'
			+STR0006+Chr(13)+Chr(10);//"Para mais informações, acesse o link da nossa documentação:"
			+ "https://tdn.totvs.com/display/PROT/E-Social+-+JURA313+-+Layout+2501")
	Endif

Return lRet

//-------------------------------------------------------------------
/*/ { Protheus.doc } MenuDef
Menu Funcional

@author Alan 
@since 19/07/2023
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function MenuDef()

Local lTafOutSist  := SuperGetMV('MV_JTAFOUT',, .F.) // O TAF e Juri estão config em ambiente diferente?
Local aRotina := FWMVCMenu( "TAFA609" )

	If lTafOutSist = .F.
		ADD OPTION aRotina TITLE STR0004     ACTION 'J313GerXML()' OPERATION 9 ACCESS 0 // Gerar XML
	Endif

Return (aRotina)

//-------------------------------------------------------------------
/*/ { Protheus.doc } J313GerXML
Função que gera o XML

@author Alan 
@since 19/07/2023
@version 1.0
/*/
//-------------------------------------------------------------------

Function J313GerXML()

Local cXml         := ""
Local cNumpro	   := V7C->V7C_NRPROC
Local cPerapu      := V7C->V7C_PERAPU

	// Gera arquivo XML na pasta local
	DbSelectArea("V7C")
	DbSetOrder(5)  // V7C_FILIAL+V7C_NRPROC+V7C_PERAPU+V7C_ATIVO  

	If Dbseek( xFilial('V7C') + Padr(cNumpro,TamSx3("V7C_NRPROC")[1]) + Padr(cPerapu,TamSx3("V7C_PERAPU")[1])  + '1' )                                                                                                                    
		TAF609Xml(,,,)
	Else
		FWAlertInfo(STR0002, STR0003) // Não foi possível gerar o XML, pois o mesmo encontra-se INATIVO no Evendo S-2501, Atenção
	Endif 

Return cXml

