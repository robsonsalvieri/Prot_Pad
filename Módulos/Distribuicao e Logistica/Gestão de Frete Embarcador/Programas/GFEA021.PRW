#INCLUDE "GFEA021.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
 
Static cCodAnt

// SonarQube - CA1003: Uso não permitido de chamada de API em LOOP
Static s_TIPREG := SuperGetMV('MV_TIPREG',,'2')


//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA021()
Cadastro de Regioes


@author Luiz Fernando Soares
@since 21/10/09
@version 1.0
/*/
//-------------------------------------------------------------------

Function GFEA021()

Local oBrowse 

oBrowse := FWMBrowse():New()
oBrowse:SetAlias("GU9")      // Alias da tabela utilizada
oBrowse:SetMenuDef("GFEA021") // Nome do fonte onde esta a função MenuDef
oBrowse:SetDescription("Cadastro de Regiões")   // Descrição do browse //"Regiões"

oBrowse:Activate()                

Return(Nil)

//------------------------------------------------------------------------------------//
//----------------------------FUNCAO MENUDef()----------------------------------------//
//------------------------------------------------------------------------------------//
Static Function MenuDef()

Local aRotina := {}                                           
//-------------------------------------------------------

// Adiciona botões do browse

//-------------------------------------------------------

ADD OPTION aRotina TITLE STR0002    ACTION STR0003           OPERATION 1 ACCESS 0 //"Pesquisar"###"AxPesqui"
ADD OPTION aRotina TITLE STR0004    ACTION "VIEWDEF.GFEA021C" OPERATION 2 ACCESS 0 //"Visualizar"
ADD OPTION aRotina TITLE STR0005    ACTION "VIEWDEF.GFEA021" OPERATION 3 ACCESS 0 //"Incluir"
ADD OPTION aRotina TITLE STR0006    ACTION "VIEWDEF.GFEA021" OPERATION 4 ACCESS 0 //"Alterar"
ADD OPTION aRotina TITLE STR0007    ACTION "VIEWDEF.GFEA021" OPERATION 5 ACCESS 0 //"Excluir"
ADD OPTION aRotina TITLE STR0008    ACTION "VIEWDEF.GFEA021" OPERATION 9 ACCESS 0 //"Copiar"
ADD OPTION aRotina TITLE STR0009    ACTION "VIEWDEF.GFEA021" OPERATION 8 ACCESS 0 //"Imprimir"

Return aRotina 

/*/{Protheus.doc} GFEA021TRG
	Configura a trigger de atualização de nome
@author siegklenes.beulke
@since 24/11/2016
@param oStruct, object , objeto instanciado da FWFormModelStruct
@param nCampos, Numeric, 0 = todos os campos, 1 = somente região, 2 = somente região agrupadora
/*/
Function GFEA021TRG(oStruct,nCampos)
	Local aAux := {}
	
	If nCampos == 0 .Or. nCampos == 1
		aAux := FwStruTrigger("GVR_NRREG","GVR_NMREG","If (Empty(M->GVR_NRREG),' ',Posicione('GU9',1,xFilial('GU9')+M->GVR_NRREG,'GU9_NMREG') )",/*lSeek*/,/*cAlias*/,/*nOrdem*/,/*cChave*/,/*cCondicao*/,'001')
		oStruct:AddTrigger(aAux[1],aAux[2],aAux[3],aAux[4] )
	EndIf
	
	If nCampos == 0 .Or. nCampos == 2
		aAux := FwStruTrigger("GVR_NRREGR","GVR_NMREGR","If (Empty(M->GVR_NRREGR),' ',Posicione('GU9',1,xFilial('GU9')+M->GVR_NRREGR,'GU9_NMREG') )",/*lSeek*/,/*cAlias*/,/*nOrdem*/,/*cChave*/,/*cCondicao*/,If(nCampos == 0,'002','001'))
		oStruct:AddTrigger(aAux[1],aAux[2],aAux[3],aAux[4] )
	EndIf
	
	aSize(aAux,0)
Return

//------------------------------------------------------------------------------------//
//----------------------------FUNCAO ModelDef()---------------------------------------//
//------------------------------------------------------------------------------------//
Static Function ModelDef() 

Local oModel
Local oStructGVR := FWFormStruct(1,"GVR")

// cID     Identificador do modelo
// bPre    Code-Block de pre-edição do formulário de edição. Indica se a edição esta liberada
// bPost   Code-Block de validação do formulário de edição
// bCommit Code-Block de persistência do formulário de edição
// bCancel Code-Block de cancelamento do formulário de edição
oModel := MPFormModel():New("GFEA021", /*bPre*/,{ |oX| GFEA021INC( oX ) },/*bPost*/,/*bCommit*/, /*bCancel*/)
// cId          Identificador do modelo
// cOwner       Identificador superior do modelo
// oModelStruct Objeto com  a estrutura de dados
// bPre         Code-Block de pré-edição do formulário de edição. Indica se a edição esta liberada
// bPost        Code-Block de validação do formulário de edição
// bLoad        Code-Block de carga dos dados do formulário de edição
oModel:AddFields("GFEA021_GU9", Nil, FWFormStruct(1,"GU9"),/*bPre*/,/*bPost*/,/*bLoad*/)    

oModel:AddGrid("GFEA021_GUA","GFEA021_GU9",FWFormStruct(1,"GUA"),/*bLinePre*/, { |oMdlG| GFEA021BRW( oMdlG ) }/*bLinePost*/,/*bPre*/,/*bPost*/,/*bLoad*/)
oModel:GetModel("GFEA021_GUA"):SetUniqueLine({"GUA_NRCID"})
oModel:SetRelation("GFEA021_GUA",{{"GUA_FILIAL",'xFilial("GU9")'},{"GUA_NRREG","GU9_NRREG"}},"GUA_FILIAL+GUA_NRREG")
oModel:SetPrimaryKey({"GU9_FILIAL", "GU9_NRREG"})
oModel:GetModel("GFEA021_GUA"):SetDelAllLine(.T.)
oModel:GetModel("GFEA021_GUA"):SetMaxLine(9999) 
oModel:SetOptional("GFEA021_GUA", .T. )

oModel:AddGrid("GFEA021_GUL","GFEA021_GU9",FWFormStruct(1,"GUL"),/*bLinePre*/,{|oMdlG| GFEA021GUL( oMdlG ) }/*bLinePost*/,/*bPre*/,/*bPost*/,/*bLoad*/)
oModel:GetModel("GFEA021_GUL"):SetUniqueLine({"GUL_CEPINI"})
oModel:SetRelation("GFEA021_GUL",{{"GUL_FILIAL",'xFilial("GU9")'},{"GUL_NRREG","GU9_NRREG"}},"GUL_FILIAL+GUL_NRREG")
oModel:GetModel("GFEA021_GUL"):SetDelAllLine(.T.)  
oModel:SetVldActivate ( { |oX| GFEA021VLD(oX)} )  
oModel:GetModel("GFEA021_GUL"):SetMaxLine(9999) 
oModel:SetOptional("GFEA021_GUL", .T. )

GFEA021TRG(oStructGVR,2)
oStructGVR:SetProperty('GVR_NRREG',MODEL_FIELD_OBRIGAT,.F.)
oModel:AddGrid("GFEA021_GVR","GFEA021_GU9",oStructGVR,/*bLinePre*/,/*bLinePost*/,/*bPre*/,/*bPost*/,/*bLoad*/)
oModel:GetModel("GFEA021_GVR"):SetUniqueLine({"GVR_NRREGR"})
oModel:SetRelation("GFEA021_GVR",{{"GVR_FILIAL",'xFilial("GU9")'},{"GVR_NRREG","GU9_NRREG"}},GVR->(IndexKey(1)))
oModel:GetModel("GFEA021_GVR"):SetDelAllLine(.T.)
oModel:GetModel("GFEA021_GVR"):SetMaxLine(9999)   
oModel:SetOptional("GFEA021_GVR", .T. )

Return(oModel)

//------------------------------------------------------------------------------------//
//----------------------------FUNCAO ViewDef()----------------------------------------//
//------------------------------------------------------------------------------------//

Static Function ViewDef()
Local oModel := FWLoadModel("GFEA021")
Local oView 
Local oStructGUA := FWFormStruct(2,"GUA")
Local oStructGUL := FWFormStruct(2,"GUL")
Local oStructGVR := FWFormStruct(2,"GVR")
Local nOpc := oModel:GetOperation()
 
oView := FWFormView():New()
oView:SetModel(oModel)
oView:AddField( "GFEA021_GU9" , FWFormStruct(2,"GU9") )

oStructGUA:RemoveField("GUA_NRREG")
oStructGUL:RemoveField("GUL_NRREG")
oStructGVR:RemoveField("GVR_NRREG")
oStructGVR:RemoveField("GVR_NMREG")

oView:AddGrid( "GFEA021_GUA" , oStructGUA )
oView:AddGrid( "GFEA021_GUL" , oStructGUL )
oView:AddGrid( "GFEA021_GVR" , oStructGVR )

oView:CreateHorizontalBox( "MASTER" , 20 )
oView:CreateHorizontalBox( "DETAIL" , 80 )

oView:CreateFolder("IDFOLDER","DETAIL")
oView:AddSheet("IDFOLDER","IDSHEET01",STR0010)
oView:AddSheet("IDFOLDER","IDSHEET02",STR0011)
oView:AddSheet("IDFOLDER","IDSHEET03","Regiões")

oView:CreateHorizontalBox( "DETAILCID"  , 100,,,"IDFOLDER","IDSHEET01" )
oView:CreateHorizontalBox( "DETAILCEP"  , 100,,,"IDFOLDER","IDSHEET02" )
oView:CreateHorizontalBox( "DETAILREG"  , 100,,,"IDFOLDER","IDSHEET03" )

oView:SetOwnerView( "GFEA021_GU9" , "MASTER" )
oView:SetOwnerView( "GFEA021_GUA" , "DETAILCID" )
oView:SetOwnerView( "GFEA021_GUL" , "DETAILCEP" )
oView:SetOwnerView( "GFEA021_GVR" , "DETAILREG" )

oView:AddUserButton( 'Relacionar Cidades', 'MAGIC_BMP', {|oModel| GFEA021A(oModel)  } )
oView:AddUserButton( 'Relacionar Regiões', 'MAGIC_BMP', {|oModel| GFEA021B(oModel)  } )
oView:AddUserButton( 'Consultar Cidade'  , 'MAGIC_BMP', {|oModel| GFEA021CID(oModel,"GFEA021_GUA")} )
oView:AddUserButton( 'Consultar Região'  , 'MAGIC_BMP', {|oModel| GFEA021REG(oModel,"GFEA021_GVR","GVR_NRREGR")} )

 
Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA021GUL
Rotina de validação do grid da tabela GUL (Faixa de CEP)
Uso Geral.

@param   oMOdelGrid        Model do grid da tabela

@author Luiz Fernando Soares
@since 21/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
function GFEA021GUL(oModelGrid)
Local lRet       := .T.
Local oModel     := oModelGrid:GetModel( 'GFEA021_GUL' )
local nOpc       := (oModel:GetOperation())

if nOpc == 3 .Or. nOpc == 4
	if FWFldGet( 'GUL_CEPINI' ) > FWFldGet( 'GUL_CEPFIM' ) .and. FWFldGet( 'GUL_CEPFIM' ) <> " "
		PutHelp("PFRM022I",{STR0012},{STR0012},{STR0012}) //"CEP Inicial maior que CEP Final"###"CEP Inicial maior que CEP Final"###"CEP Inicial maior que CEP Final"
		HELP(" ",1,"FRM022I")
		lRet := .F.
	endif
endif

return (lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA021BRW
Rotina de validação do grid da tabela GUA (Regiao X Cidade)
Uso Geral.

@param   oModelGrid        Model do grid da tabela

@author Luiz Fernando Soares
@since 21/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
function GFEA021BRW (oModelGrid)                                    
Local lRet       := .T.
Local oModel     := oModelGrid:GetModel( 'GFEA021_GUA' )
local nOpc       := (oModel:GetOperation()) 



if nOpc == 3 .Or. nOpc == 4    

    dbSelectArea("GU7")
    dbSetOrder(1)
         
    If GU7->( dbSeek( xFilial( 'GU7' ) + FwFldGet( 'GUA_NRCID' ) ) ) 
    	if GU7->GU7_SIT == "2"        
	    	Help( ,, 'Help',, STR0029, 1, 0 ) //"Cidade com a situação Inativa"
	    	lRet := .F.
	    endif
    endif  
    
endif     


return (lRet) 

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA021INC 
Rotina para Validar os dados no momento da inclusão ou alteração
Uso Geral.

@param   oModel        Objeto do model principal
@author Luiz Fernando Soares
@since 21/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
function GFEA021INC (oModel)
Local lRet      := .T.
local nOpc      := (oModel:GetOperation())                                                
Local nI        := 0                                
Local nLineaUX  := 0
local cCidade   := ''
Local cQuery    := ''
Local cTmp      := ''
Local aArea     := GetArea()
Local lGUA      := .F. // Flag responsavel por verificar se há algum registro na tabela GUA
Local lGUL      := .F. // Flag responsavel por verificar se há algum registro na tabela GUL
Local lGVR      := .F. // Flag responsavel por verificar se há algum registro na tabela GVR
Local oModelGUA
Local oModelGUL
Local oModelGVR
Local oModelGU9 := oModel:GetModel("GFEA021_GU9")
Local nInfo

if nOpc == 3 .Or. nOpc == 4
    

	DbSelectArea('GU9')
	Chkfile( 'GU9',,'GU9BF')
    
	If FwFldGet('GU9_DEMCID') == '1'   
    	
    	//Não incluir mais de uma região com o campo Demais Cidades como Sim para a mesma UF.
    	dbSelectArea('GU9BF')
    	dbSetOrder(03)
    	If dbSeek(xFilial('GU9')+FwFldGet('GU9_CDUF'))   
    	    While !Eof() .And. xFilial('GU9')+FwFldGet('GU9_CDUF') == GU9BF->GU9_FILIAL+GU9BF->GU9_CDUF .And. FwFldGet('GU9_NRREG') != GU9BF->GU9_NRREG
	        	If GU9BF->GU9_DEMCID == '1'
	        		Help( ,, 'Help',, STR0025+M->GU9_CDUF, 1, 0 )  //"Já existe um registro com a opção Demais cidades? como 'Sim' para a UF: "
			   		lRet := .F.
	        	EndIf   
        	GU9BF->(dbSkip())
        	EndDo
        EndIf
   
    EndIf
    
    
	oModelGUA := oModel:GetModel( "GFEA021_GUA" )
	nLineaUX := oModelGUA:nLine
	For nI := 1 To oModelGUA:GetQtdLine()
		oModelGUA:GoLine( nI )
	
		If !oModelGUA:IsDeleted() .and. FWFldGet( 'GUA_NRCID' ) <> " "  
			lGUA := .T. // Se há algum registro na tabela GUA 
			dbSelectArea("GU7")
			dbSetOrder(1)
			If !GU7->( dbSeek( xFilial( 'GU7' ) + FwFldGet( 'GUA_NRCID' ) ) )
				Help( ,, 'Help',, STR0030, 1, 0 ) //"Cidade inexistente"
				lRet := .F.
			EndIf
			
			If(s_TIPREG == '2')
				cCidade     := FwFldGet('GUA_NRCID')
				cQuery := ""
				cQuery += "SELECT COUNT(*) QTD FROM " + RetSQLName( 'GUA' ) + " GUA "
				cQuery += "WHERE GUA_FILIAL = '   ' "
				cQuery += "AND GUA_NRCID = '" + cCidade + "' "
				cQuery += "AND GUA_NRREG <> '" + FwFldGet('GU9_NRREG') + "' "
				cQuery += "AND D_E_L_E_T_ = ' ' "
				cTmp := GetNextAlias()
				dbUseArea( .T., 'TOPCONN', TcGenQry(,,cQuery), cTmp, .T., .F. )
				If (cTmp)->QTD > 0
					Help( ,, 'Help',, STR0026, 1, 0 )  //"Cidade ja cadastrada para outra regiao"
					lRet := .F.
				EndIf
				(cTmp)->(dbCloseArea())
					    
			EndIf  
		endif
			
	Next
	oModelGUA:GoLine( nLineaUX )
	
	dbSelectArea("GU9")
	dbSetOrder(1)

	If FWFldGet( 'GU9_DEMCID' ) == "1" .or. FWFldGet( 'GU9_SIT' ) == "2"
		oModelGUA := oModel:GetModel( "GFEA021_GUA" )
		nLineaUX := oModelGUA:nLine
		For nI := 1 To oModelGUA:GetQtdLine()
			oModelGUA:GoLine( nI )
			If nI == 1
				If oModelGUA:IsUpDated() //.OR. !Empty( FWFldGet( 'GUA_NRREG' ) )
					PutHelp("PFRM022F",{STR0013},{STR0013},{STR0013}) //"Região Demais Cidades ou Inativa"###"Região Demais Cidades ou Inativa"###"Região Demais Cidades ou Inativa"
					PutHelp("SFRM022F",{STR0014},{STR0014},{STR0015}) //"Não é possivel incluir Cidade ou CEP"###"Não é possivel incluir Cidade ou CEP"###"Não é possivel incluir Cidade ou Faixa de CEP"
					HELP(" ",1,"FRM022F","FRM022F" )
					lRet := .F.
				EndIf
			Else
				If !oModelGUA:IsDeleted() .And. M->GU9_SIT == "1"
					PutHelp("PFRM022F",{STR0013},{STR0013},{STR0013}) //"Região Demais Cidades ou Inativa"###"Região Demais Cidades ou Inativa"###"Região Demais Cidades ou Inativa"
					PutHelp("SFRM022F",{STR0014},{STR0014},{STR0015}) //"Não é possivel incluir Cidade ou CEP"###"Não é possivel incluir Cidade ou CEP"###"Não é possivel incluir Cidade ou Faixa de CEP"
					HELP(" ",1,"FRM022F","FRM022F" )
					lRet := .F.
				endif
				
			endif
		Next
		oModelGUA:GoLine( nLineaUX )
		
		If lRet
			oModelGUL := oModel:GetModel( "GFEA021_GUL" )
			nLineaUX := oModelGUL:nLine

			For nI := 1 To oModelGUL:GetQtdLine()
				oModelGUL:GoLine( nI )
				If !oModelGUL:IsDeleted() .And. !Empty(FWFldGet('GUL_CEPINI')) 
					lGUL := .T. // Flag para ver se há algum registro na   
				EndIf	

				If nI == 1
					If (oModelGUL:IsUpDated().OR. !Empty( FWFldGet( 'GUL_NRREG' ) )) .and. FWFldGet( 'GU9_DEMCID' ) == '1'
						PutHelp("PFRM022F",{STR0016},{STR0016},{STR0016}) //"Região setada como Demais Cidades"###"Região setada como Demais Cidades"###"Região setada como Demais Cidades"
						PutHelp("SFRM022F",{STR0014},{STR0014},{STR0015}) //"Não é possivel incluir Cidade ou CEP"###"Não é possivel incluir Cidade ou CEP"###"Não é possivel incluir Cidade ou Faixa de CEP"
						HELP(" ",1,"FRM022F","FRM022F" )
						lRet := .F.
					EndIf
				Else
					If !oModelGUL:IsDeleted() .AND. FWFldGet( 'GU9_DEMCID' ) == '1'
						PutHelp("PFRM022F",{STR0016},{STR0016},{STR0016}) //"Região setada como Demais Cidades"###"Região setada como Demais Cidades"###"Região setada como Demais Cidades"
						PutHelp("SFRM022F",{STR0014},{STR0014},{STR0015}) //"Não é possivel incluir Cidade ou CEP"###"Não é possivel incluir Cidade ou CEP"###"Não é possivel incluir Cidade ou Faixa de CEP"
						HELP(" ",1,"FRM022F","FRM022F" )
						lRet := .F.
					endif
				endif
			Next
			oModelGUL:GoLine( nLineaUX )
		EndIf
	endif	
	
	if FWFldGet( 'GUA_NRCID' ) <> " " .and. FWFldGet( 'GUL_CEPINI' ) <> " " 
		oModelGUA := oModel:GetModel( "GFEA021_GUA" )
		oModelGUL := oModel:GetModel( "GFEA021_GUL" )
		If !oModelGUA:IsDeleted() .and. !oModelGUL:IsDeleted()
			PutHelp("PFRM022D",{STR0017},{STR0017},{STR0017}) //"Região Inválida "###"Região Inválida "###"Região Inválida "
			PutHelp("SFRM022D",{STR0018},{STR0018},{STR0018}) //"Região possui vínculo com cidade e CEP"###"Região possui vínculo com cidade e CEP"###"Região possui vínculo com cidade e CEP"
			HELP(" ",1,"FRM022D","FRM022D" )
			lRet := .F.
		                 
		endif
	endif
	
	//Percorre o grid de Ceps para ver se há registro 
	oModelGUL := oModel:GetModel( "GFEA021_GUL" )
	nLineaUX := oModelGUL:nLine
	For nI := 1 To oModelGUL:GetQtdLine()
		oModelGUL:GoLine( nI )
		If !oModelGUL:IsDeleted() .And. !Empty(FWFldGet('GUL_CEPINI')) .And. !Empty(FWFldGet('GUL_CEPFIM'))
			lGUL := .T. // Flag para ver se há algum registro
			Exit
		EndIf	
	Next
	oModelGUL:GoLine( nLineaUX )
	
	//Percorre o grid de Regiões para ver se há registro 
	oModelGVR := oModel:GetModel( "GFEA021_GVR" )
	For nI := 1 To oModelGVR:Length()
		If !oModelGVR:IsDeleted(nI) .And. !Empty(oModelGVR:GetValue('GVR_NRREGR',nI))
			lGVR := .T. // Flag para ver se há algum registro
			If oModelGU9:GetValue("GU9_NRREG") == oModelGVR:GetValue('GVR_NRREGR',nI)
				Help(,,'HELP',,'Não é permitido auto-relacionamento de regiões',1,0)
				lRet := .F.
				Exit
			EndIf
		EndIf	
	Next
	
	nInfo := IIf(lGUA,1,0) + IIf(lGUL,2,0) + IIf(lGVR,4,0)	

	//não permite alterar uma região com relacionamentos de cidades para Demais Cidades como Sim.
	//If nInfo > 0 .And. M->GU9_DEMCID == '1'

	If nInfo > 0 .And. FWFldGet( 'GU9_DEMCID' ) == '1'
		Help( ,, 'Help',, STR0028, 1, 0 ) //"Não é possível uma região com cidades,CEP´s ou Regiões relacionadas e a opção Demais Cidades igual a 'Sim'."
		lRet := .F.
	EndIf 
	
	//Não permite a região ter combinação entre cidades, ceps e regiões cadastrados
	If nInfo != 0 .And. nInfo != 1 .And. nInfo != 2 .And. nInfo != 4
		Help( ,, 'Help',, STR0031, 1, 0 ) //"Não é possível uma região com mais de um tipo de relacionamento(Cidades,CEP´s e Regiões)."
		lRet := .F.    
	EndIf 

	If nInfo == 0 .And.  FWFldGet( 'GU9_DEMCID' ) == '2'
		Help( ,, 'Help',, 'Deve haver pelo menos um registro nas abas Cidades, Faixas de CEP ou Regiões.', 1, 0 )
		lRet := .F. 
	EndIf
	
	
GU9BF->( dbCloseArea() )	
	 
endif
Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} ValidaCEP
Rotina chamada no Dicionario para fazer as validacoes referentes 
as faixas de CEP
Uso Geral.

@sample ValidaCEP()

@author Luiz Fernando Soares
@since 21/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFEValCEP()      
Local oModel    := FwModelActive() 
Local oModelGUL := oModel:GetModel( "GFEA021_GUL" )
Local lRet      := .T.
Local nI        := 0   
Local nLin      := oModelGUL:nLine
Local cCEP      := ''
Local cQuery    := ''
Local cTmp      := ''
Local aArea     := GetArea()


If     'GUL_CEPINI' $ ReadVar()
	cCEP     := FwFldGet('GUL_CEPINI')
ElseIf 'GUL_CEPFIM' $ ReadVar()
	cCEP     := FwFldGet('GUL_CEPFIM')
EndIf  
                                                   
For nI := 1 To oModelGUL:GetQtdLine()
	oModelGUL:GoLine( nI )
	If !oModelGUL:IsDeleted()
		If nI <> nLin   // Se a linha nao eh a do proprio campo
			If  oModelGUL:GetValue( 'GUL_CEPINI' )  <= cCEP .AND. cCEP <= oModelGUL:GetValue( 'GUL_CEPFIM' ) 
				PutHelp("PFRM022H",{STR0021},{STR0021},{STR0021}) //"CEP esta contido em faixa ja cadastrada"###"CEP esta contido em faixa ja cadastrada"###"CEP esta contido em faixa ja cadastrada"
				HELP(" ",1,"FRM022H")
				lRet := .F.
			EndIf
		EndIf
	EndIf
Next     

If s_TIPREG == '2'
	cQuery := ""
	cQuery += "SELECT COUNT(*) QTD FROM " + RetSQLName( 'GUL' ) + " GUL "
	cQuery += "WHERE GUL_FILIAL = '   ' "
	cQuery += "AND GUL_CEPINI <= '" + cCEP + "' "
	cQuery += "AND GUL_CEPFIM >= '" + cCEP + "' "
	cQuery += "AND GUL_NRREG <> '" + FwFldGet('GU9_NRREG') + "' "
	cQuery += "AND D_E_L_E_T_ = ' ' "
	cTmp := GetNextAlias()
	dbUseArea( .T., 'TOPCONN', TcGenQry(,,cQuery), cTmp, .T., .F. )
	If (cTmp)->QTD > 0
		Help( ,, 'Help',, STR0027 + s_TIPREG, 1, 0 )  //"Este CEP esta contido em faixa ja cadastrada para outra regiao   "
		lRet := .F.
		
	EndIf
	(cTmp)->(dbCloseArea())
EndIf


oModelGUL:GoLine( nLin )  
RestArea( aArea )
Return lRet

/*/{Protheus.doc} GFEA021VRR
//TODO Realiza a validação da região(GVR) que será relacionada na região(GU9) 
@author siegklenes.beulke
@since 25/11/2016
@version undefined
@param cNrReg, characters, Código da Região
@example
(examples)
@see (links_or_references)
/*/
Function GFEA021VRR(cNrReg)
	Local aArea    := GetArea()
	Local aAreaGU9 := GU9->(GetArea())
	Local oModel := FwModelActive()
	Local oModelGU9 := oModel:GetModel("GFEA021_GU9")
	Local lRet := .T.
	If !Empty(cNrReg)
		If oModelGU9:GetValue("GU9_NRREG") == cNrReg .Or. (oModel:GetOperation() == 4 .And. cNrReg == cCodAnt) // Valor anterior 
			Help(,,'HELP',,'Não é permitido auto-relacionamento de regiões',1,0)
			lRet := .F.
		Else
			GU9->(dbSetOrder(1))
			If !GU9->(dbSeek(xFilial("GU9") + cNrReg))
				Help(,,'HELP',,'Região ' + cNrReg + ' não localizada!',1,0)
				lRet := .F.
			ElseIf GU9->GU9_SIT == '2'
				Help(,,'HELP',,'Região ' + cNrReg + ' não está ativa!',1,0)
				lRet := .F.
			ElseIf GU9->GU9_DEMCID == '1'
				Help(,,'HELP',,"Não é permitido relacionar uma região agrupadora à uma região configurada como Demais Cidades",1,0)
				lRet := .F.
			Else
				GVR->(dbSetOrder(1))
				If GVR->(dbSeek(xFilial("GU9") + cNrReg))
					Help(,,'HELP',,"Não é permitido relacionar duas regiões agrupadoras",1,0)
					lRet := .F.
				EndIf
			EndIf
		EndIf
		
	EndIf
	
	RestArea(aAreaGU9)
	RestArea(aArea   )
	
	aSize(aAreaGU9,0)
	aSize(aArea   ,0)
Return lRet

Function GFEA021CID(oModel,cSubMod)
	Local oModelGUA := oModel:GetModel(cSubMod)
	Local cCidade   := oModelGUA:GetValue("GUA_NRCID")
	Local aArea := GetArea()
	If Empty(cCidade)
		Help(,,'HELP',,'Não há cidades relacionadas ou código da cidade está em branco',1,0)
	Else
		GU7->(dbSetOrder(1))
		If GU7->(dbSeek(xFilial("GU7") + cCidade))
			GFEC020(.F.)
		Else
			Help(,,'HELP',,'A cidade com o código ' + cCidade + ' não foi localizada.',1,0)
		EndIf
	EndIf
	RestArea(aArea)
Return

Function GFEA021REG(oModel,cSubMod,cCampo)
	Local oModelGVR := oModel:GetModel(cSubMod)
	Local cRegiao   := oModelGVR:GetValue(cCampo)
	Local aArea := GetArea()
	If Empty(cRegiao)
		Help(,,'HELP',,'Não há regiões relacionadas ou código da região está em branco',1,0)
	Else
		GU9->(dbSetOrder(1))
		If GU9->(dbSeek(xFilial("GU9") + cRegiao))
			FWExecView(,"GFEA021C",,,{|| .T.})
		Else
			Help(,,'HELP',,'A região com o código ' + cRegiao + ' não foi localizada.',1,0)
		EndIf
	EndIf
	RestArea(aArea)
Return

Function GFEA021VLD(oX)
	Local nOp := oX:GetOperation()
	Local aAreaGVR := GVR->(GetArea())
	Local lRet := .T.
	cCodAnt := GU9->GU9_NRREG
	
	If nOp == MODEL_OPERATION_DELETE
		GVR->(dbSetOrder(2))
		If GVR->(dbSeek(xFilial("GVR") + GU9->GU9_NRREG))
			Help( ,, 'Help',, "Esta região está relacionado a um grupo de regiões. Utilize a opção visualizar e verifique as regiões superiores.", 1, 0 )
			lRet := .F.
		EndIf
	EndIf 
	RestArea(aAreaGVR)
Return lRet
