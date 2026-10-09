#INCLUDE 'protheus.ch'
#INCLUDE 'parmtype.ch'
#INCLUDE "Fileio.ch"


//-------------------------------------------------------------------
/*/{Protheus.doc} PMobIniEnd

Inicializa processo de endpoints relacionados ao acesso

@author  Geraldo (Mobile Saude) / Renan Sakai
@version P12
@since   06/09/18
/*/
//-------------------------------------------------------------------
Function PMobIniEnd(cType, cDataModel, cClass, oSelf, lAuto, cJsonAuto )
	
	Local bClass := "{ || oController:"+cClass+"() }"
    Local oController := nil
	Local oRequestModel	:= nil 
	Local oConfig := nil
	Local cRespJson := ""

	Default cClass := ""
	Default lAuto := .F.
	Default cJsonAuto := ""

	Do Case
		Case cType == "AUT"
			oController := PMobAutCon():New()

		Case cType == "TOK"
			oController := PMobSecCon():New()

		Case cType == "UTZ"
			oConfig := PMobConfig():New()
			oController := PMobUtzCon():New()

		Case cType == "FIN"
			oConfig := PMobConfig():New()
			oController := PMobFinCon():New()

		Case cType == "GUI"
			oConfig := PMobConfig():New()
			oController := PMobGuiCon():New()
		
		Case cType == "DEC"
			oConfig := PMobConfig():New()
			oController := PMobDecCon():New()
		
		Case cType == "EXREE"
			oConfig := PMobConfig():New()
			oController := PMobExReembCon():New()
		
		Case cType == "ATUCAD"
			oConfig := PMobConfig():New()
			oController := PMobAtuCadCon():New()
		
		Case cType == "PROT"
			oConfig := PMobConfig():New()
			oController := PMobReeCon():New()
	EndCase
			
	oController:cModelEndPoint := cDataModel //Registra a chave do modelo de dados deste EndPoint

	if cType $ "UTZ-FIN-GUI-DEC-EXREE-ATUCAD"
		oController:oConfig := oConfig:GetSettings()
	endIf

	oRequestModel := PMobRequDM():New()
	oRequestModel:oSuperClass := iif(lAuto,nil,oSelf)
	oRequestModel:lCheckSecurityRulles := iif(cType == "TOK",.F.,.T.)
	oRequestModel:oClass := oController
	oRequestModel:cBody := iif(lAuto,cJsonAuto,oSelf:GetContent())
	
	If !oRequestModel:CheckPostModel(lAuto)		
		oSelf:SetResponse( oRequestModel:SetResponse() ) //Retorna se os dados de entrada não são válidos
		Return .T.
	Endif

	oController:SetRequestModel(oRequestModel) //Realiza a regra de negocio do EndPoint
	Eval(&bClass) //Roda funcao especifica do EndPoint

	iif(lAuto,cRespJson := EncodeUTF8(oRequestModel:SetResponse()) , oSelf:SetResponse( EncodeUTF8(oRequestModel:SetResponse()) ) ) //Retorna o modelo de dados do EndPoint

Return iif(lAuto,cRespJson,.T.)


//-------------------------------------------------------------------
/*/{Protheus.doc} PMobSplMat

@author  Geraldo (Mobile Saude) / Sakai
@version P12
@since   03/06/2020
/*/
//------------------------------------------------------------------- 
Function PMobSplMat(cMatric)

	Local aPosInt := {1,4}
	Local aPosEmp := {5,4}
	Local aPosMat := {9,6}
	Local aPosReg := {15,2}
	Local aPosDig := {17,1}
	Local oMatric := jSonObject():New()

	oMatric['codInt'] := Substr(cMatric, aPosInt[1],aPosInt[2])
	oMatric['codEmp'] := Substr(cMatric, aPosEmp[1],aPosEmp[2])
	oMatric['matric'] := Substr(cMatric, aPosMat[1],aPosMat[2])
	oMatric['tipReg'] := Substr(cMatric, aPosReg[1],aPosReg[2])
	oMatric['digito'] := Substr(cMatric, aPosDig[1],aPosDig[2])

Return(oMatric)


//-------------------------------------------------------------------
/*/{Protheus.doc} PMobCpfMat

@author  Geraldo (Mobile Saude) / Sakai
@version P12
@since   03/06/2020
/*/
//------------------------------------------------------------------- 
Function PMobCpfMat(cMatric)

	Local cCpf
	Local cSql := ""
	Local oMatric := PMobSplMat(cMatric)

	cSql := " SELECT BA1_CPFUSR FROM "+RetSqlName("BA1")
	cSql += " WHERE BA1_FILIAL = '"+xFilial("BA1")+"' "
	cSql += " AND BA1_CODINT = '"+oMatric['codInt']+"' "
	cSql += " AND BA1_CODEMP = '"+oMatric['codEmp']+"' "
	cSql += " AND BA1_MATRIC = '"+oMatric['matric']+"' "
	cSql += " AND BA1_TIPREG = '"+oMatric['tipReg']+"' "
	cSql += " AND BA1_DIGITO = '"+oMatric['digito']+"' "
	cSql += " AND D_E_L_E_T_ = ' ' "
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"TRB",.T.,.F.)

	If !TRB->( Eof() )
		cCpf := TRB->BA1_CPFUSR
	Endif

	TRB->( dbCloseArea() )

Return cCPF


//-------------------------------------------------------------------
/*/{Protheus.doc} PMobFile64
Converte um arquivo em BASE64

@author  Geraldo (Mobile Saude) / Sakai
@version P12
@since   03/06/2020
/*/
//------------------------------------------------------------------- 
Function PMobFile64(cFile)

	Local cStr64 := ""
	Local aDir   := {}
	Local nHandle := 0
	Local cString := ""

	//Verifica o tamanho do arquivo, parâmetro exigido na FRead.
	aDir := Directory(cFile)

	If Len(aDir) >= 1

		// Abre o arquivo fisicamente	
		nHandle := fopen(cFile, FO_READWRITE + FO_SHARED )
		
		//Carrega na variável cString, a string ASCII do arquivo.
		FRead( nHandle, @cString, aDir[1][2] ) 
		
		//Converte o arquivo para BASE64
		cStr64 := Encode64(cString) 
		
		// Fecha o arquivo
		fclose(nHandle)

	Endif

Return(cStr64)