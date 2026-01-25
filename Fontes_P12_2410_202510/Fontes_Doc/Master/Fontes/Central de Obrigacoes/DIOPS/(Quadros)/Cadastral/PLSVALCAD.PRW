#include 'totvs.ch'
#include 'FWMVCDEF.CH'
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} EnvQuaCad

Funcao criada para marcar o quadro Cadastral para ser enviado / gerado o XML

@author timoteo.bega
@since 06/12/2017
/*/
//--------------------------------------------------------------------------------------------------
Function EnvQuaCad(cCodOpe,cAnoCmp,cRefere)
	Local cQuadro		:= "2"//Cadastral
	Default cCodOpe	:= ""
	Default cAnoCmp	:= ""
	Default cRefere	:= ""

	lRet := quadroFimEnvDiops(cQuadro,cCodOpe,cAnoCmp,cRefere)

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetTabUF

Funcao criada para retornar a lista de estados

@author timoteo.bega
@since 08/01/2018
/*/
//--------------------------------------------------------------------------------------------------
Function GetTabUF()
	Local aUF := {}
	
	aAdd(aUF,{"AC","Acre"})
	aAdd(aUF,{"AL","Alagoas"})
	aAdd(aUF,{"AM","Amazonas"})
	aAdd(aUF,{"AP","Amapa"})
	aAdd(aUF,{"BA","Bahia"})
	aAdd(aUF,{"CE","Ceara"})
	aAdd(aUF,{"DF","Distrito Federal"})
	aAdd(aUF,{"ES","Espirito Santo"})
	aAdd(aUF,{"EX","Exterior"})
	aAdd(aUF,{"GO","Goias"})
	aAdd(aUF,{"MA","Maranhao"})
	aAdd(aUF,{"MG","Minas Gerais"})
	aAdd(aUF,{"MS","Mato Grosso do Sul"})
	aAdd(aUF,{"MT","Mato Grosso"})
	aAdd(aUF,{"PA","Para"})
	aAdd(aUF,{"PB","Paraiba"})
	aAdd(aUF,{"PE","Pernambuco"})
	aAdd(aUF,{"PI","Piaui"})
	aAdd(aUF,{"PR","Parana"})
	aAdd(aUF,{"RJ","Rio de Janeiro"})
	aAdd(aUF,{"RN","Rio Grande do Norte"})
	aAdd(aUF,{"RO","Rondonia"})
	aAdd(aUF,{"RR","Roraima"})
	aAdd(aUF,{"RS","Rio Grande do Sul"})
	aAdd(aUF,{"SC","Santa Catarina"})
	aAdd(aUF,{"SE","Sergipe"})
	aAdd(aUF,{"SP","Sao Paulo"})
	aAdd(aUF,{"TO","Tocantis"})

Return aUF

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetUFCen

Funcao criada para retornar a descrição da sigla do Estado

@author timoteo.bega
@since 08/01/2018
/*/
//--------------------------------------------------------------------------------------------------
Function GetUFCen(cAlias, cUF)
	Local cCampo	:= ""
	Local aUF		:= GetTabUF()
	Local nUF		:= 0
	Private CENUF	:= ""
	Default cAlias	:= ''
	Default cUF		:= ''

	If Empty(cUF)
		
		If Empty(cAlias)
			If Select("B8N") > 0
				cAlias := "B8N"
			EndIf
			
			If Select("B8Z") > 0
				cAlias := "B8Z"
			EndIf
		EndIf
		
		If Inclui .Or. Altera
			cCampo := "M->" + cAlias + "_SIGLUF"
		Else
			cCampo := cAlias + "->" + cAlias + "_SIGLUF"
		EndIf
		
		cUF := &cCampo
	
	EndIf
		
	nUF := aScan(aUF,{ |x| x[1] == cUF })
	
	If nUF > 0
		cUF := aUF[nUF,2]
	Else
		cUF	:= 'UF não encontrado'
	EndIf
	
Return cUF

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} F3UFCEN

Funcao criada para montar o F3 de estados

@author timoteo.bega
@since 08/01/2018
/*/
//--------------------------------------------------------------------------------------------------
Function F3UFCEN()
	Local cTitulo	:= "Estados"
	Local nInd		:= 0
	Local nPos		:= 0
	Local nQtd		:= 0
	Local bChk		:= {|| nQtd := PlsCntLst(aLista) }
	Local aLista	:= {}
	Local aGrupos	:= {}
	Local nOpca		:= 0
	Local bOK		:= { || nOpca := 1, oDlg:End() }
	Local bCancel	:= { || oDlg:End() }
	Local oDlg		:= Nil
	Local oGrupo	:= Nil
	Local lRet		:= .F.

//coloca virgula no comeco (caso tenha inicializador padrao)
	cDado := AllTrim(cDado)
	If Subs(cDado,Len(cDado),1) != "," .And. cDado != ""
		cDado += ","
	EndIf

	aGrupos := GetTabUF()

	For nInd := 1 To Len(aGrupos)
		aAdd( aLista , { aGrupos[nInd,1],aGrupos[nInd,2],Iif(aGrupos[nInd,1] $ cDado,.T.,.F.) } )
	Next

	DEFINE MSDIALOG oDlg TITLE cTitulo FROM 00,00 To 25,88 OF GetWndDefault()
	@ 020,012 SAY oSay PROMPT "Selecione um estado" SIZE 300,010 OF oDlg PIXEL COLOR CLR_HBLUE //"Selecione uma atividade

	oGrupo := TcBrowse():New( 035, 012, 330, 150,,,, oDlg,,,,,,,,,,,, .F.,, .T.,, .F., )
	oGrupo:AddColumn(TcColumn():New(" "		,{ || IF(aLista[oGrupo:nAt,3],LoadBitmap( GetResources(), "LBOK" ),LoadBitmap( GetResources(), "LBNO" )) },"@c",nil,nil,nil,015,.T.,.T.,nil,nil,nil,.T.,nil))
	oGrupo:AddColumn(TcColumn():New('Sigla'	,{ || OemToAnsi(aLista[oGrupo:nAt,1]) },"@!",nil,nil,nil,020,.F.,.F.,nil,nil,nil,.F.,nil))
	oGrupo:AddColumn(TcColumn():New('Estado'	,{ || OemToAnsi(aLista[oGrupo:nAt,2]) },"@C",nil,nil,nil,200,.F.,.F.,nil,nil,nil,.F.,nil))
	oGrupo:SetArray(aLista)
	oGrupo:bLDblClick := { || Eval(bChk) , Iif( nQtd<=35 .Or. aLista[oGrupo:nAt,3] , aLista[oGrupo:nAt,3] := IF(aLista[oGrupo:nAt,3],.F.,.T.) , .F. ) }

	ACTIVATE MSDIALOG oDlg ON INIT EnChoiceBar( oDlg,bOK,bCancel,.F.,{} )

	lRet := !empty(cDado)

	If nOpca == 1
		cDado := ""
		For nInd := 1 To Len(aLista)
			If aLista[nInd,3]
				cDado += aLista[nInd,1]+","
			EndIf
		Next
	EndIf

	If Subs(cDado,3,1) == ","
		cDado := Subs(cDado,1,3)
	EndIf
	If (Inclui .Or. Altera) .And. !Empty(cDado)
		CENUF := Alltrim(cDado)
		lRet := .T.
	EndIf

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetTabPAIS

Funcao criada para retornar a lista de paises

@author timoteo.bega
@since 08/01/2018
/*/
//--------------------------------------------------------------------------------------------------
Function GetTabPAIS()
	Local aPaises	:= {}
	
	aAdd(aPaises,{"001","Açores"})
	aAdd(aPaises,{"002","Afeganistão"})
	aAdd(aPaises,{"003","África do Sul"})
	aAdd(aPaises,{"004","Alasca (EUA)"})
	aAdd(aPaises,{"005","Albânia"})
	aAdd(aPaises,{"006","Alemanha"})
	aAdd(aPaises,{"007","Andorra"})
	aAdd(aPaises,{"008","Angola"})
	aAdd(aPaises,{"009","Antártica"})
	aAdd(aPaises,{"010","Antígua"})
	aAdd(aPaises,{"011","Antilhas Holandesas"})
	aAdd(aPaises,{"012","Arábia Saudita"})
	aAdd(aPaises,{"013","Argélia"})
	aAdd(aPaises,{"014","Argentina"})
	aAdd(aPaises,{"015","Armênia"})
	aAdd(aPaises,{"016","Austrália"})
	aAdd(aPaises,{"017","Áustria"})
	aAdd(aPaises,{"018","Azerbaijão"})
	aAdd(aPaises,{"019","Bahamas"})
	aAdd(aPaises,{"020","Bahrein (Bareine)"})
	aAdd(aPaises,{"021","Bangladesh"})
	aAdd(aPaises,{"022","Barbados"})
	aAdd(aPaises,{"023","Bashkortostan"})
	aAdd(aPaises,{"024","Belarus"})
	aAdd(aPaises,{"025","Bélgica"})
	aAdd(aPaises,{"026","Belize"})
	aAdd(aPaises,{"027","Benin"})
	aAdd(aPaises,{"028","Bermudas"})
	aAdd(aPaises,{"029","Bolívia"})
	aAdd(aPaises,{"030","Bósnia-Herzegovina"})
	aAdd(aPaises,{"031","Botswana"})
	aAdd(aPaises,{"032","Brasil"})
	aAdd(aPaises,{"033","Brunei"})
	aAdd(aPaises,{"034","Bulgária"})
	aAdd(aPaises,{"035","Burkina Fasso"})
	aAdd(aPaises,{"036","Burundi"})
	aAdd(aPaises,{"037","Butão"})
	aAdd(aPaises,{"038","Cabo Verde (República do)"})
	aAdd(aPaises,{"039","Camarões"})
	aAdd(aPaises,{"040","Camboja"})
	aAdd(aPaises,{"041","Canadá"})
	aAdd(aPaises,{"042","Catar"})
	aAdd(aPaises,{"043","Cazaquistão"})
	aAdd(aPaises,{"044","Chade"})
	aAdd(aPaises,{"045","Chile"})
	aAdd(aPaises,{"046","China"})
	aAdd(aPaises,{"047","Chipre (República de)"})
	aAdd(aPaises,{"048","Chuvash (República de)"})
	aAdd(aPaises,{"049","Cingapura"})
	aAdd(aPaises,{"050","Colômbia"})
	aAdd(aPaises,{"051","Comoros (República Federal Islâmica de)"})
	aAdd(aPaises,{"052","Congo (Zaire)"})
	aAdd(aPaises,{"053","Coréia do Norte"})
	aAdd(aPaises,{"054","Coréia do Sul"})
	aAdd(aPaises,{"055","Costa do Marfim"})
	aAdd(aPaises,{"056","Costa Rica"})
	aAdd(aPaises,{"057","Croácia"})
	aAdd(aPaises,{"058","Cuba"})
	aAdd(aPaises,{"059","Dinamarca"})
	aAdd(aPaises,{"060","Djibouti"})
	aAdd(aPaises,{"061","Domínica"})
	aAdd(aPaises,{"062","Egito"})
	aAdd(aPaises,{"063","El Salvador"})
	aAdd(aPaises,{"064","Emirados Árabes Unidos"})
	aAdd(aPaises,{"065","Equador"})
	aAdd(aPaises,{"066","Eriteia (Eritreia)"})
	aAdd(aPaises,{"067","Escócia (GBR)"})
	aAdd(aPaises,{"068","Eslováquia"})
	aAdd(aPaises,{"069","Eslovênia"})
	aAdd(aPaises,{"070","Espanha"})
	aAdd(aPaises,{"071","Estados Unidos da América"})
	aAdd(aPaises,{"072","Estônia"})
	aAdd(aPaises,{"073","Etiópia"})
	aAdd(aPaises,{"074","Fiji (Ilhas)"})
	aAdd(aPaises,{"075","Filipinas"})
	aAdd(aPaises,{"076","Finlândia"})
	aAdd(aPaises,{"077","Formosa Taiwan (China)"})
	aAdd(aPaises,{"078","França"})
	aAdd(aPaises,{"079","Gabão"})
	aAdd(aPaises,{"080","Gâmbia"})
	aAdd(aPaises,{"081","Gana"})
	aAdd(aPaises,{"082","Geórgia (República de)"})
	aAdd(aPaises,{"083","Gibraltar (GBR)"})
	aAdd(aPaises,{"084","Grã-Bretanha"})
	aAdd(aPaises,{"085","Granada"})
	aAdd(aPaises,{"086","Grécia"})
	aAdd(aPaises,{"087","Groenlândia (Dinamarca)"})
	aAdd(aPaises,{"088","Guadalupe (França)"})
	aAdd(aPaises,{"089","Guam (EUA)"})
	aAdd(aPaises,{"090","Guatemala"})
	aAdd(aPaises,{"091","Guernsey (GRB)"})
	aAdd(aPaises,{"092","Guiana"})
	aAdd(aPaises,{"093","Guiana Francesa"})
	aAdd(aPaises,{"094","Guiné"})
	aAdd(aPaises,{"095","Guiné Equatorial"})
	aAdd(aPaises,{"096","Guiné-Bissau"})
	aAdd(aPaises,{"097","Guiné-Conacri"})
	aAdd(aPaises,{"098","Haiti"})
	aAdd(aPaises,{"099","Honduras"})
	aAdd(aPaises,{"100","Hong Kong"})
	aAdd(aPaises,{"101","Hungria"})
	aAdd(aPaises,{"102","Iêmen (República do)"})
	aAdd(aPaises,{"103","Ilha Norfolk"})
	aAdd(aPaises,{"104","Ilhas Caimã"})
	aAdd(aPaises,{"105","Ilhas Canárias"})
	aAdd(aPaises,{"106","Ilhas Cocos (Keeling)"})
	aAdd(aPaises,{"107","Ilhas Cook"})
	aAdd(aPaises,{"108","Ilhas Marshall"})
	aAdd(aPaises,{"109","Índia"})
	aAdd(aPaises,{"110","Indonésia"})
	aAdd(aPaises,{"111","Irã"})
	aAdd(aPaises,{"112","Iraque"})
	aAdd(aPaises,{"113","Irlanda"})
	aAdd(aPaises,{"114","Islândia"})
	aAdd(aPaises,{"115","Israel"})
	aAdd(aPaises,{"116","Itália"})
	aAdd(aPaises,{"117","Iugoslávia"})
	aAdd(aPaises,{"118","Jamaica"})
	aAdd(aPaises,{"119","Japão"})
	aAdd(aPaises,{"120","Jordânia"})
	aAdd(aPaises,{"121","Kuwait"})
	aAdd(aPaises,{"122","Laos"})
	aAdd(aPaises,{"123","Lesoto"})
	aAdd(aPaises,{"124","Letônia (República da)"})
	aAdd(aPaises,{"125","Líbano"})
	aAdd(aPaises,{"126","Libéria"})
	aAdd(aPaises,{"127","Líbia"})
	aAdd(aPaises,{"128","Liechtenstein"})
	aAdd(aPaises,{"129","Lituânia"})
	aAdd(aPaises,{"130","Luxemburgo"})
	aAdd(aPaises,{"131","Macau"})
	aAdd(aPaises,{"132","Macedônia"})
	aAdd(aPaises,{"133","Madagascar"})
	aAdd(aPaises,{"134","Malásia"})
	aAdd(aPaises,{"135","Maldívas (Ilhas)"})
	aAdd(aPaises,{"136","Mali"})
	aAdd(aPaises,{"137","Malta"})
	aAdd(aPaises,{"138","Marrocos"})
	aAdd(aPaises,{"139","Martinica (França)"})
	aAdd(aPaises,{"140","Mauritânia"})
	aAdd(aPaises,{"141","Mauritius (Maurício)"})
	aAdd(aPaises,{"142","Mayotte (França)"})
	aAdd(aPaises,{"143","México"})
	aAdd(aPaises,{"144","Micronésia"})
	aAdd(aPaises,{"145","Moçambique"})
	aAdd(aPaises,{"146","Moldavia (República de)"})
	aAdd(aPaises,{"147","Mônaco (Principado de)"})
	aAdd(aPaises,{"148","Mongólia"})
	aAdd(aPaises,{"149","Montserrat (GBR)"})
	aAdd(aPaises,{"150","Namíbia"})
	aAdd(aPaises,{"151","Nauru"})
	aAdd(aPaises,{"152","Nepal"})
	aAdd(aPaises,{"153","Nevis"})
	aAdd(aPaises,{"154","Nicarágua"})
	aAdd(aPaises,{"155","Níger"})
	aAdd(aPaises,{"156","Nigéria"})
	aAdd(aPaises,{"157","Noruega"})
	aAdd(aPaises,{"158","Nova Caledônia"})
	aAdd(aPaises,{"159","Nova Zelândia"})
	aAdd(aPaises,{"160","Omã (Muscat)"})
	aAdd(aPaises,{"161","Países Baixos (Holanda)"})
	aAdd(aPaises,{"162","Palau (República de)"})
	aAdd(aPaises,{"163","Panamá"})
	aAdd(aPaises,{"164","Papua Nova Guiné"})
	aAdd(aPaises,{"165","Paquistão"})
	aAdd(aPaises,{"166","Paraguai"})
	aAdd(aPaises,{"167","Peru"})
	aAdd(aPaises,{"168","Polinésia Francesa"})
	aAdd(aPaises,{"169","Polônia"})
	aAdd(aPaises,{"170","Porto Rico (EUA)"})
	aAdd(aPaises,{"171","Portugal"})
	aAdd(aPaises,{"172","Qatar (Doha)"})
	aAdd(aPaises,{"173","Quênia"})
	aAdd(aPaises,{"174","República Centro Africana"})
	aAdd(aPaises,{"175","República Dominicana"})
	aAdd(aPaises,{"176","República Tcheca"})
	aAdd(aPaises,{"177","Romênia"})
	aAdd(aPaises,{"178","Ruanda"})
	aAdd(aPaises,{"179","Rússia"})
	aAdd(aPaises,{"180","Saara Ocidental"})
	aAdd(aPaises,{"181","Samoa Americana (EUA.)"})
	aAdd(aPaises,{"182","Samoa Ocidental"})
	aAdd(aPaises,{"183","San Marino"})
	aAdd(aPaises,{"184","Santa Lúcia"})
	aAdd(aPaises,{"185","Santa Sé (Cidade do Vaticano)"})
	aAdd(aPaises,{"186","São Pedro e Miquelon (França)"})
	aAdd(aPaises,{"187","São Tomé e Príncipe"})
	aAdd(aPaises,{"188","São Vicente e Granadinas"})
	aAdd(aPaises,{"189","Senegal"})
	aAdd(aPaises,{"190","Serra Leoa"})
	aAdd(aPaises,{"191","Sérvia"})
	aAdd(aPaises,{"192","Síria"})
	aAdd(aPaises,{"193","Somália"})
	aAdd(aPaises,{"194","Sri Lanka (Ceilão)"})
	aAdd(aPaises,{"195","São Kitts (e Nevis) Independente"})
	aAdd(aPaises,{"196","Santa Helena (GBR)"})
	aAdd(aPaises,{"197","Suazilândia"})
	aAdd(aPaises,{"198","Sudão"})
	aAdd(aPaises,{"199","Suécia"})
	aAdd(aPaises,{"200","Suíça"})
	aAdd(aPaises,{"201","Suriname"})
	aAdd(aPaises,{"202","Tadjiquistão (República)"})
	aAdd(aPaises,{"203","Tailândia"})
	aAdd(aPaises,{"204","Taiti (Polinésia Francesa)"})
	aAdd(aPaises,{"205","Tanzânia"})
	aAdd(aPaises,{"206","Togo"})
	aAdd(aPaises,{"207","Tokelau (Ilhas)"})
	aAdd(aPaises,{"208","Tonga"})
	aAdd(aPaises,{"209","Trinidad e Tobago"})
	aAdd(aPaises,{"210","Tunísia"})
	aAdd(aPaises,{"211","Turcomenistão (Turcomênia)"})
	aAdd(aPaises,{"212","Turquia"})
	aAdd(aPaises,{"213","Tuvalu"})
	aAdd(aPaises,{"214","Ucrânia"})
	aAdd(aPaises,{"215","Uganda"})
	aAdd(aPaises,{"216","Uruguai"})
	aAdd(aPaises,{"217","Uzbequistão"})
	aAdd(aPaises,{"218","Vanuatu"})
	aAdd(aPaises,{"219","Venezuela"})
	aAdd(aPaises,{"220","Vietnã"})
	aAdd(aPaises,{"221","Zaire"})
	aAdd(aPaises,{"222","Zâmbia"})
	aAdd(aPaises,{"223","Zanzibar e Pemba (Tanganica)"})
	aAdd(aPaises,{"224","Zimbábue (Zimbabwe)"})
	
Return aPaises

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetPaisCen

Funcao criada para retornar o nome do pais

@author timoteo.bega
@since 08/01/2018
/*/
//--------------------------------------------------------------------------------------------------
Function GetPaisCen(cAlias,cCodPais)
	Local cPais			:= ""
	Local cCampo		:= ""
	Local aPaises		:= GetTabPAIS()
	Local nPais			:= 0
	Default cAlias		:= ''
	Default cCodPais	:= ''
	
	Private CENPAIS		:= ""
	
	If Empty(cCodPais)
	
		If Empty(cAlias) .and. Select("B8N") > 0 
			cAlias := "B8N"
		EndIf
		
		If Inclui .Or. Altera
			cCampo := "M->" + cAlias + "_PAIS"
		Else
			cCampo := cAlias + "->" + cAlias + "_PAIS"
		EndIf
		
		cCodPais := &cCampo
	
	EndIf
		
	nPais := aScan(aPaises,{ |x| x[1] == cCodPais })
	
	If nPais > 0
		cPais := aPaises[nPais,2]
	EndIf
	
Return cPais

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} F3PAISCEN

Funcao criada para montar o F3 de paises

@author timoteo.bega
@since 08/01/2018
/*/
//--------------------------------------------------------------------------------------------------
Function F3PAISCEN()
	Local cTitulo	:= "Paises"
	Local nInd		:= 0
	Local nPos		:= 0
	Local nQtd		:= 0
	Local bChk		:= {|| nQtd := PlsCntLst(aLista) }
	Local aLista	:= {}
	Local aGrupos	:= {}
	Local nOpca		:= 0
	Local bOK		:= { || nOpca := 1, oDlg:End() }
	Local bCancel	:= { || oDlg:End() }
	Local oDlg		:= Nil
	Local oGrupo	:= Nil
	Local lRet		:= .F.

//coloca virgula no comeco (caso tenha inicializador padrao)
	cDado := AllTrim(cDado)
	If Subs(cDado,Len(cDado),1) != "," .And. cDado != ""
		cDado += ","
	EndIf

	aGrupos := GetTabPAIS()

	For nInd := 1 To Len(aGrupos)
		aAdd( aLista , { aGrupos[nInd,1],aGrupos[nInd,2],Iif(aGrupos[nInd,1] $ cDado,.T.,.F.) } )
	Next

	DEFINE MSDIALOG oDlg TITLE cTitulo FROM 00,00 To 25,88 OF GetWndDefault()
	@ 020,012 SAY oSay PROMPT "Selecione um pais" SIZE 300,010 OF oDlg PIXEL COLOR CLR_HBLUE //"Selecione uma atividade

	oGrupo := TcBrowse():New( 035, 012, 330, 150,,,, oDlg,,,,,,,,,,,, .F.,, .T.,, .F., )
	oGrupo:AddColumn(TcColumn():New(" "		,{ || IF(aLista[oGrupo:nAt,3],LoadBitmap( GetResources(), "LBOK" ),LoadBitmap( GetResources(), "LBNO" )) },"@c",nil,nil,nil,015,.T.,.T.,nil,nil,nil,.T.,nil))
	oGrupo:AddColumn(TcColumn():New('Codigo'	,{ || OemToAnsi(aLista[oGrupo:nAt,1]) },"@!",nil,nil,nil,020,.F.,.F.,nil,nil,nil,.F.,nil))
	oGrupo:AddColumn(TcColumn():New('Pais'	,{ || OemToAnsi(aLista[oGrupo:nAt,2]) },"@C",nil,nil,nil,200,.F.,.F.,nil,nil,nil,.F.,nil))
	oGrupo:SetArray(aLista)
	oGrupo:bLDblClick := { || Eval(bChk) , Iif( nQtd<=35 .Or. aLista[oGrupo:nAt,3] , aLista[oGrupo:nAt,3] := IF(aLista[oGrupo:nAt,3],.F.,.T.) , .F. ) }

	ACTIVATE MSDIALOG oDlg ON INIT EnChoiceBar( oDlg,bOK,bCancel,.F.,{} )

	lRet := !empty(cDado)

	If nOpca == 1
		cDado := ""
		For nInd := 1 To Len(aLista)
			If aLista[nInd,3]
				cDado += aLista[nInd,1]+","
			EndIf
		Next
	EndIf

	If Subs(cDado,4,1) == ","
		cDado := Subs(cDado,1,3)
	EndIf
	If (Inclui .Or. Altera) .And. !Empty(cDado)
		CENPAIS := Alltrim(cDado)
		lRet := .T.
	EndIf

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetTabCARGO

Funcao criada para retornar a lista de cargos

@author timoteo.bega
@since 08/01/2018
/*/
//--------------------------------------------------------------------------------------------------
Function GetTabCARGO()
	Local aCargos	:= {}

	aAdd(aCargos,{"001","PRESIDENTE"})
	aAdd(aCargos,{"002","VICE-PRESIDENTE"})
	aAdd(aCargos,{"003","TESOUREIRO"})
	aAdd(aCargos,{"004","ACIONISTA"})
	aAdd(aCargos,{"005","ADMINISTRADOR"})
	aAdd(aCargos,{"006","ADVOGADO"})
	aAdd(aCargos,{"007","ANALISTA CONSULTOR"})
	aAdd(aCargos,{"008","ANALISTA DE RECURSOS HUMANOS"})
	aAdd(aCargos,{"009","ANALISTA DE SISTEMAS"})
	aAdd(aCargos,{"010","ASSESSOR"})
	aAdd(aCargos,{"011","ASSESSOR TÉCNICO"})
	aAdd(aCargos,{"012","ASSISTENTE DE RECURSOS HUMANOS"})
	aAdd(aCargos,{"013","ASSISTENTE DE SAÚDE OCUPACIONAL"})
	aAdd(aCargos,{"014","ASSISTENTE SOCIAL"})
	aAdd(aCargos,{"015","AUXILIAR DE ADMINISTRAÇÃO"})
	aAdd(aCargos,{"016","CHEFE DE RECURSOS HUMANOS"})
	aAdd(aCargos,{"017","CHEFE DEPARTAMENTO MÉDICO"})
	aAdd(aCargos,{"018","CHEFE DEPARTAMENTO PESSOAL"})
	aAdd(aCargos,{"019","CIRURGIÃO-DENTISTA"})
	aAdd(aCargos,{"020","CONSELHEIRO"})
	aAdd(aCargos,{"021","CONSELHEIRO FISCAL"})
	aAdd(aCargos,{"022","CONTADOR"})
	aAdd(aCargos,{"023","COORDENADOR"})
	aAdd(aCargos,{"024","COORDENADOR ADMINISTRATIVO"})
	aAdd(aCargos,{"025","COORDENADOR DE BENEFÍCIOS"})
	aAdd(aCargos,{"026","COORDENADOR DE RECURSOS HUMANOS"})
	aAdd(aCargos,{"027","COORDENADOR GERAL"})
	aAdd(aCargos,{"028","COORDENADOR MÉDICO"})
	aAdd(aCargos,{"029","COORDENADOR TÉCNICO"})
	aAdd(aCargos,{"030","DELEGADO"})
	aAdd(aCargos,{"031","DENTISTA"})
	aAdd(aCargos,{"032","DIRETOR ADMINISTRATIVO"})
	aAdd(aCargos,{"033","DIRETOR ADMINISTRATIVO-COMERCIAL"})
	aAdd(aCargos,{"034","DIRETOR ADMINISTRATIVO-FINANCEIRO"})
	aAdd(aCargos,{"035","DIRETOR CLÍNICO"})
	aAdd(aCargos,{"036","DIRETOR COMERCIAL"})
	aAdd(aCargos,{"037","DIRETOR DE ASSISTÊNCIA"})
	aAdd(aCargos,{"038","DIRETOR DE ASSISTÊNCIA E SAÚDE"})
	aAdd(aCargos,{"039","DIRETOR DE CONTROLADORIA"})
	aAdd(aCargos,{"040","DIRETOR DE MERCADO"})
	aAdd(aCargos,{"041","DIRETOR DE PATRIMÔNIO"})
	aAdd(aCargos,{"042","DIRETOR DE RECURSOS HUMANOS"})
	aAdd(aCargos,{"043","DIRETOR DE SAÚDE E ATENDIMENTO"})
	aAdd(aCargos,{"044","DIRETOR DE SEGURIDADE SOCIAL"})
	aAdd(aCargos,{"045","DIRETOR DE SERVIÇOS MÉDICOS"})
	aAdd(aCargos,{"046","DIRETOR DE SERVIÇOS MÉDICOS/ODONT."})
	aAdd(aCargos,{"047","DIRETOR DE SERVIÇOS ODONTOLÓGICOS"})
	aAdd(aCargos,{"048","DIRETOR EXECUTIVO"})
	aAdd(aCargos,{"049","DIRETOR EXECUTIVO DE BENEFÍCIOS"})
	aAdd(aCargos,{"050","DIRETOR FINANCEIRO"})
	aAdd(aCargos,{"051","DIRETOR GERAL"})
	aAdd(aCargos,{"052","DIRETOR HOSPITALAR"})
	aAdd(aCargos,{"053","DIRETOR INDUSTRIAL"})
	aAdd(aCargos,{"054","DIRETOR LIQUIDANTE"})
	aAdd(aCargos,{"055","DIRETOR MÉDICO"})
	aAdd(aCargos,{"056","DIRETOR OPERACIONAL"})
	aAdd(aCargos,{"057","DIRETOR PRESIDENTE"})
	aAdd(aCargos,{"058","DIRETOR SÓCIO"})
	aAdd(aCargos,{"059","DIRETOR SUPERINTENDENTE"})
	aAdd(aCargos,{"060","GERENTE"})
	aAdd(aCargos,{"061","GERENTE ADMINISTRATIVO"})
	aAdd(aCargos,{"062","GERENTE ADMINISTRATIVO-FINANCEIRO"})
	aAdd(aCargos,{"063","GERENTE COMERCIAL"})
	aAdd(aCargos,{"064","GERENTE DA DIVISÃO DE RECURSOS"})
	aAdd(aCargos,{"065","GERENTE DE ADMINISTRAÇÃO DE BENEFÍCIO"})
	aAdd(aCargos,{"066","GERENTE DE ASSISTÊNCIA"})
	aAdd(aCargos,{"067","GERENTE DE ASSISTÊNCIA E SAÚDE"})
	aAdd(aCargos,{"068","GERENTE DE BENEFÍCIOS ASSISTENCIAIS"})
	aAdd(aCargos,{"069","GERENTE DE CONTROLADORIA"})
	aAdd(aCargos,{"070","GERENTE DE CONVÊNIOS"})
	aAdd(aCargos,{"071","GERENTE DE DIVISÃO"})
	aAdd(aCargos,{"072","GERENTE DE MEDICINA OCUPACIONAL"})
	aAdd(aCargos,{"073","GERENTE DE OPERAÇOES"})
	aAdd(aCargos,{"074","GERENTE DE PADROES"})
	aAdd(aCargos,{"075","GERENTE DE PESSOAL"})
	aAdd(aCargos,{"076","GERENTE DE PRODUÇAO"})
	aAdd(aCargos,{"077","GERENTE DE RECURSOS HUMANOS"})
	aAdd(aCargos,{"078","GERENTE DE SAÚDE E SEGURANÇA"})
	aAdd(aCargos,{"079","GERENTE DE UNIDADE"})
	aAdd(aCargos,{"080","GERENTE DELEGADO"})
	aAdd(aCargos,{"081","GERENTE EXECUTIVO"})
	aAdd(aCargos,{"082","GERENTE FINANCEIRO"})
	aAdd(aCargos,{"083","GERENTE GERAL"})
	aAdd(aCargos,{"084","GERENTE JURÍDICO"})
	aAdd(aCargos,{"085","GERENTE OPERACIONAL"})
	aAdd(aCargos,{"086","GERENTE OPERACIONAL DE PLANOS"})
	aAdd(aCargos,{"087","GERENTE PROCURADOR"})
	aAdd(aCargos,{"088","GERENTE RELAÇÕES INDUSTRIAIS"})
	aAdd(aCargos,{"089","GERENTE RESPONSÁVEL TÉCNICO"})
	aAdd(aCargos,{"090","GERENTE TÉCNICO"})
	aAdd(aCargos,{"091","GERENTE TÉCNICO-ADMINISTRATIVO"})
	aAdd(aCargos,{"092","GESTOR"})
	aAdd(aCargos,{"093","INTERVENTOR"})
	aAdd(aCargos,{"094","INTERVENTOR MUNICIPAL"})
	aAdd(aCargos,{"095","LIQUIDANTE"})
	aAdd(aCargos,{"096","MÉDICO"})
	aAdd(aCargos,{"097","MÉDICO AUDITOR"})
	aAdd(aCargos,{"098","MÉDICO RESPONSÁVEL"})
	aAdd(aCargos,{"099","MÉDICO RESPONSÁVEL CONTRATADO"})
	aAdd(aCargos,{"100","MEMBRO CONSELHO CURADOR"})
	aAdd(aCargos,{"101","MEMBRO DE CONSELHO"})
	aAdd(aCargos,{"102","MEMBRO DO CONSELHO FISCAL"})
	aAdd(aCargos,{"103","ODONTÓLOGO"})
	aAdd(aCargos,{"104","PRESIDENTE CONSELHO ADMINISTRATIVO"})
	aAdd(aCargos,{"105","PRESIDENTE CONSELHO CURADOR"})
	aAdd(aCargos,{"106","PRESIDENTE CONSELHO DELIBERATIVO"})
	aAdd(aCargos,{"107","PRESIDENTE CONSELHO GERAL"})
	aAdd(aCargos,{"108","PRESIDENTE EXECUTIVO"})
	aAdd(aCargos,{"109","PRESIDENTE GRUPO GESTOR"})
	aAdd(aCargos,{"110","PRESIDENTE NACIONAL"})
	aAdd(aCargos,{"111","PROCURADOR"})
	aAdd(aCargos,{"112","PROPRIETARIO"})
	aAdd(aCargos,{"113","PROVEDOR"})
	aAdd(aCargos,{"114","REPRESENTANTE"})
	aAdd(aCargos,{"115","REPRESENTANTE JUNTO A ANS"})
	aAdd(aCargos,{"116","REPRESENTANTE LEGAL"})
	aAdd(aCargos,{"117","REPRESENTANTE TÉCNICO"})
	aAdd(aCargos,{"118","REPRESENTANTE TÉCNICO CONTRATADO"})
	aAdd(aCargos,{"119","RESPONSÁVEL"})
	aAdd(aCargos,{"120","RESPONSÁVEL JUNTO A ANS"})
	aAdd(aCargos,{"121","RESPONSÁVEL LEGAL"})
	aAdd(aCargos,{"122","SECRETÁRIO"})
	aAdd(aCargos,{"123","SECRETÁRIO DE FINANÇAS"})
	aAdd(aCargos,{"124","SÓCIO"})
	aAdd(aCargos,{"125","SÓCIO ADMINISTRADOR"})
	aAdd(aCargos,{"126","SÓCIO GERENTE"})
	aAdd(aCargos,{"127","SUPERINTENDENTE"})
	aAdd(aCargos,{"128","SUPERINTENDENTE ADMINISTRATIVO"})
	aAdd(aCargos,{"129","SUPERINTENDENTE DE MEDICINA"})
	aAdd(aCargos,{"130","SUPERINTENDENTE DE PLANOS"})
	aAdd(aCargos,{"131","SUPERINTENDENTE DE RECURSOS HUMANOS"})
	aAdd(aCargos,{"132","SUPERINTENDENTE EXECUTIVO"})
	aAdd(aCargos,{"133","SUPERINTENDENTE GERAL"})
	aAdd(aCargos,{"134","SUPERVISOR"})
	aAdd(aCargos,{"135","SUPERVISOR DE RECURSOS HUMANOS"})
	aAdd(aCargos,{"136","TÉCNICO DE SEGURANÇA DO TRABALHO"})
	aAdd(aCargos,{"137","TÉCNICO EM CONTABILIDADE"})
	aAdd(aCargos,{"138","TÉCNICO REPONSÁVEL"})
	aAdd(aCargos,{"139","VICE-PRESIDENTE DE SAÚDE"})
	aAdd(aCargos,{"140","VICE-PRESIDENTE EXECUTIVO"})
	aAdd(aCargos,{"141","Primeiro Vice Provedor"})
	aAdd(aCargos,{"142","Primeiro Tesoureiro"})
	aAdd(aCargos,{"143","Diretor Tesoureiro"})
	aAdd(aCargos,{"144","Diretor Secretário"})
	aAdd(aCargos,{"145","Diretor Técnico"})
	aAdd(aCargos,{"146","Segundo Vice Provedor"})
	aAdd(aCargos,{"147","Diretor Ouvidor"})

Return aCargos

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetCarCen

Funcao criada para retornar a descricao do cargo

@author timoteo.bega
@since 08/01/2018
/*/
//--------------------------------------------------------------------------------------------------
Function GetCarCen(cAlias,cCargo)
	Local cDesCargo		:= ""
	Local cCampo		:= ""
	Local aCargos		:= GetTabCargo()
	Local nCargo		:= 0
	Default cAlias		:= ''
	Default cCargo		:= ''
	Private CENCAR	:= ""

	If Empty(cCargo)  
	
		If Select("B8N") > 0
			cAlias := "B8N"
		EndIf
		
		If Inclui .Or. Altera
			cCampo := "M->" + cAlias + "_CARGO"
		Else
			cCampo := cAlias + "->" + cAlias + "_CARGO"
		EndIf
	
	EndIf
	
	If Empty(cCargo)
		cCargo := &cCampo
	EndIf
	
	nCargo := aScan(aCargos,{ |x| x[1] == cCargo })
	
	If nCargo > 0
		cDesCargo := aCargos[nCargo,2]
	EndIf
	
Return cDesCargo

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} F3CARCEN

Funcao criada para montar o F3 de cargos

@author timoteo.bega
@since 08/01/2018
/*/
//--------------------------------------------------------------------------------------------------
Function F3CARCEN()
	Local cTitulo	:= "Cargos"
	Local nInd		:= 0
	Local nPos		:= 0
	Local nQtd		:= 0
	Local bChk		:= {|| nQtd := PlsCntLst(aLista) }
	Local aLista	:= {}
	Local aGrupos	:= {}
	Local nOpca		:= 0
	Local bOK		:= { || nOpca := 1, oDlg:End() }
	Local bCancel	:= { || oDlg:End() }
	Local oDlg		:= Nil
	Local oGrupo	:= Nil
	Local lRet		:= .F.

//coloca virgula no comeco (caso tenha inicializador padrao)
	cDado := AllTrim(cDado)
	If Subs(cDado,Len(cDado),1) != "," .And. cDado != ""
		cDado += ","
	EndIf

	aGrupos := GetTabCargo()

	For nInd := 1 To Len(aGrupos)
		aAdd( aLista , { aGrupos[nInd,1],aGrupos[nInd,2],Iif(aGrupos[nInd,1] $ cDado,.T.,.F.) } )
	Next

	DEFINE MSDIALOG oDlg TITLE cTitulo FROM 00,00 To 25,88 OF GetWndDefault()
	@ 020,012 SAY oSay PROMPT "Selecione um cargo" SIZE 300,010 OF oDlg PIXEL COLOR CLR_HBLUE //"Selecione uma atividade

	oGrupo := TcBrowse():New( 035, 012, 330, 150,,,, oDlg,,,,,,,,,,,, .F.,, .T.,, .F., )
	oGrupo:AddColumn(TcColumn():New(" "		,{ || IF(aLista[oGrupo:nAt,3],LoadBitmap( GetResources(), "LBOK" ),LoadBitmap( GetResources(), "LBNO" )) },"@c",nil,nil,nil,015,.T.,.T.,nil,nil,nil,.T.,nil))
	oGrupo:AddColumn(TcColumn():New('Codigo'	,{ || OemToAnsi(aLista[oGrupo:nAt,1]) },"@!",nil,nil,nil,020,.F.,.F.,nil,nil,nil,.F.,nil))
	oGrupo:AddColumn(TcColumn():New('Cargo'	,{ || OemToAnsi(aLista[oGrupo:nAt,2]) },"@C",nil,nil,nil,200,.F.,.F.,nil,nil,nil,.F.,nil))
	oGrupo:SetArray(aLista)
	oGrupo:bLDblClick := { || Eval(bChk) , Iif( nQtd<=35 .Or. aLista[oGrupo:nAt,3] , aLista[oGrupo:nAt,3] := IF(aLista[oGrupo:nAt,3],.F.,.T.) , .F. ) }

	ACTIVATE MSDIALOG oDlg ON INIT EnChoiceBar( oDlg,bOK,bCancel,.F.,{} )

	lRet := !empty(cDado)

	If nOpca == 1
		cDado := ""
		For nInd := 1 To Len(aLista)
			If aLista[nInd,3]
				cDado += aLista[nInd,1]+","
			EndIf
		Next
	EndIf

	If Subs(cDado,4,1) == ","
		cDado := Subs(cDado,1,3)
	EndIf
	If (Inclui .Or. Altera) .And. !Empty(cDado)
		M->B8N_CARGO := Alltrim(cDado)
		M->B8N_DCARGO := B8NCargo()
		CENCAR := Alltrim(cDado)
		lRet := .T.
	EndIf

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} DIOPSEnvCad

Funcao criada para marcar o quadro 2-Cadatral para envio 

@author timoteo.bega
@since 23/01/2018
/*/
//--------------------------------------------------------------------------------------------------
Function DIOPSEnvCad()
	Local lRet	:= .T.
	Local cAno	:= StrZero(Year(dDataBase),4)
	Local cMes	:= StrZero(Month(dDataBase),2)
	Local cCdComp	:= ''
	
	//Trimestre do compromisso
	If cMes >= '01' .and. cMes <= '03'
		cRefere	:= '1'
	ElseIf cMes >= '04' .and. cMes <= '06'
		cRefere	:= '2'
	ElseIf cMes >= '07' .and. cMes <= '09'
		cRefere	:= '3'
	Else
		cRefere	:= '4'
	EndIf
	
	// Posiciona Obrigação - Tipo? 3 - DIOPS / Ativo? 1 - Sim
	B3A->(dbSetOrder(2))
	B3A->(MsSeek(xFilial('B3A')+B8M->B8M_CODOPE+'3'+'1' ))
	
	cCdComp := PLSEXICOM( B8M->B8M_CODOPE, B3A->B3A_CODIGO, cRefere, cAno )
	
	// Prepara indice para buscar Obrigação
	B3D->(dbSetOrder(1))
	B3D->(MsSeek(xFilial('B3D')+B8M->B8M_CODOPE+B3A->B3A_CODIGO+cAno+cCdComp,.F.))
	
	// Será posicionado sempre na obrigação vigente		
	
	// ==>  se foi enviada procura a próxima em aberto? <==  
	B8X->(dbSetOrder(1))	//B8X_FILIAL+B8X_CODOPE+B8X_CODOBR+B8X_ANOCMP+B8X_CDCOMP+B8X_QUADRO
	If B8X->(dbSeek(xFilial("B8X")+B3D->B3D_CODOPE+B3D->B3D_CDOBRI+B3D->B3D_ANO+B3D->B3D_CODIGO+"2"))
		If RecLock("B8X",.F.)
			B8X->B8X_RECEBI := "1"
			msUnLock()
		Else
			lRet := .F.
			Help( ,, 'HELP',,"Não foi possível marcar o quadro cadastral para envio!" + B3A->B3A_CODOPE, 1, 0)
		EndIf
	EndIf
	
Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} VB8SCPFCNP

Funcao criada para validar se o documento informado esta coerente com o tipo de acionista selecionado

@author timoteo.bega
@since 31/01/2018
/*/
//--------------------------------------------------------------------------------------------------
Function VB8SCPFCNP(cVal,cTpAcio)
	Local lRet		:= .T.
	Local nTam		:= 0
	Default cVal	:= ""
	Default cTpAcio	:= "1"//1-PF,2-PJ

	nTam := Len(AllTrim(cVal))

	If nTam > 0 .And. (Inclui .Or. Altera)
		If nTam == 14 .And. cTpAcio == "1"
			lRet := .F.
		EndIf
		If nTam <= 11 .And. cTpAcio == "2"
			lRet := .F.
		EndIf
	EndIf

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PICB8S

Funcao criada para retornar a picture do cammpo de acordo com o tipo de acionista

@author timoteo.bega
@since 31/01/2018
/*/
//--------------------------------------------------------------------------------------------------
Function PICB8S()
	Local cPic	:= ""
	Local cTp	:= ""
	Local cAlias:= Alias()

	If cAlias == "B8S"

		If Inclui .Or. Altera
			cTp := M->B8S_TPACIO
		Else
			cTp := B8S->B8S_TPACIO
		EndIf
	
	ElseIf cAlias == "B8Y"

		If Inclui .Or. Altera
			cTp := M->B8Y_TPPESS
		Else
			cTp := B8Y->B8Y_TPPESS
		EndIf

	EndIf

	If cTp == "1"
		cPic := "F"
	Else
		cPic := "J"
	EndIf

Return PICPES(cPic)