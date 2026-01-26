#Include "loca107.ch"
#Include "Protheus.ch"
#Include "FWMVCDef.ch"

/*/{Protheus.doc} LOCA107
Programa para gerar arquivo XNU de menu SIGALOC conforme perfis selecionados
@type Function
@author DENNIS CALABREZ
@since 03/10/2025
/*/
Function LOCA107(cCombo1)
Local oDlg
Local oPanel1, oPanel2, oPanel3
Local oFont14   := TFont():New("Arial",,-14,.T.,.T.)
Local oFont12   := TFont():New("Arial",,-12,.T.,.F.)
Local aTamanhos := {STR0001, STR0003, STR0002} //"Pequeno" //"Grande" //"Médio"
Local cTamanho  := ""
Local oComboTam
Local aRotinas  := {}
Local oBtnGerar, oBtnCancelar
Local oListBox
Local aHeader   := {STR0008,STR0007, STR0006, STR0005, STR0004} //"G" //"M" //"P" //"Menu" //"Rotina"
    
    // Define as rotinas e seus perfis
    AAdd(aRotinas, {STR0009, STR0011,STR0010, .T., .T., .T.}) //"Orçamento" //"Comercial" //"LOCA001"
    AAdd(aRotinas, {STR0013, STR0012,STR0010, .F., .T., .T.}) //"Comercial" //"LOCA057" //"Aprovação"
    AAdd(aRotinas, {STR0014, STR0015,STR0010, .T., .T., .T.}) //"Fatura" //"LOCA021" //"Comercial"
    AAdd(aRotinas, {STR0017, STR0016,STR0010, .T., .T., .T.}) //"Comercial" //"LOCA054" //"RAT"
    AAdd(aRotinas, {STR0019, STR0018,STR0010, .T., .T., .T.}) //"LOCA086" //"Reajuste de Contrato." //"Comercial"
	AAdd(aRotinas, {STR0020, STR0018,STR0010, .T., .T., .T.}) //"Comercial" //"LOCA086" //"Pedido de Venda"
	
    AAdd(aRotinas, {STR0023, STR0022,STR0021, .T., .T., .T.}) //"Operacional" //"LOCA059" //"Apontador de AS"
    AAdd(aRotinas, {STR0024, STR0025, STR0021,.F., .F., .T.}) //"Operacional" //"Controle de Minuta" //"LOCA005"
    AAdd(aRotinas, {STR0026, STR0027,STR0021, .T., .T., .T.}) //"Custo Extra" //"LOCA007" //"Operacional"
    AAdd(aRotinas, {STR0028, STR0029,STR0021, .T., .T., .T.}) //"Gerenciamento de Bens" //"LOCA224" //"Operacional"
    AAdd(aRotinas, {STR0031, STR0030,STR0021, .F., .F., .T.}) //"LOCA075" //"Integração e Processos" //"Operacional"
    AAdd(aRotinas, {STR0033, STR0032,STR0021, .T., .T., .T.}) //"Operacional" //"LOCA048" //"Medição"
    AAdd(aRotinas, {STR0035, STR0034,STR0021, .F., .T., .T.}) //"Operacional" //"LOCA029" //"Romaneio"
    AAdd(aRotinas, {STR0036, "LOCA050",STR0021, .T., .T., .T.}) //"Libera Equipamento" //"Operacional"

    DEFINE MSDIALOG oDlg TITLE STR0037 FROM 000,000 TO 650,800 PIXEL //"Gerador de Menu XNU - SIGALOC"
    
    // Painel superior - Steps
    oPanel1 := TPanel():New(05,05,,oDlg,,,,,,390,40)
    TSay():New(15,150,{||STR0038},oPanel1,,oFont14,,,,.T.,CLR_BLUE) //"DEFINIÇÃO DE MENU CONFORME ESCOPO"
    
    // Painel esquerdo - Tamanhos
    oPanel2 := TPanel():New(50,10,,oDlg,,,,,,150,240)
    
    TSay():New(10,10,{||STR0039},oPanel2,,oFont12,,,,.T.) //"Definir escopo do Menu:"
    If cCombo1 = "P"
		cTamanho  := aTamanhos[1]
	EndIf
	If cCombo1 = "M"
		cTamanho  := aTamanhos[2]
	EndIf
    If cCombo1 = "G"
		cTamanho  := aTamanhos[3]
	EndIf	
    oComboTam := TComboBox():New(25,10,{|u|if(PCount()>0,cTamanho:=u,cTamanho)},;
        aTamanhos,130,20,oPanel2,,,,,,.T.,,,,,,,,,"cTamanho")
    
    // Painel direito - Grade de rotinas
    oPanel3 := TPanel():New(50,165,,oDlg,,,,,,220,240)
    
    @ 18,05 LISTBOX oListBox VAR cVar FIELDS HEADER "",aHeader[1],aHeader[2],aHeader[3],aHeader[4],aHeader[5] ;
        SIZE 210,215 OF oPanel3 PIXEL ;
        ON DBLCLICK(LOCA01071(aRotinas, oListBox:nAt, oListBox:nColPos, oListBox))
    
	oListBox:SetArray(aRotinas)
    oListBox:bLine := {|| {" ",;
        aRotinas[oListBox:nAt,1],;
		aRotinas[oListBox:nAt,3],;
        IIF(aRotinas[oListBox:nAt,4],"X"," "),;
        IIF(aRotinas[oListBox:nAt,5],"X"," "),;
        IIF(aRotinas[oListBox:nAt,6],"X"," ")}}
    
    // Botões
    oBtnGerar := TButton():New(270,240,;
        STR0040,oDlg,{|| LOCA01072(cTamanho, aRotinas, oDlg)},; //"Gerar XNU"
        60,12,,,,.T.)
    
    oBtnCancelar := TButton():New(270,310,;
        STR0041,oDlg,{|| oDlg:End()},; //"Cancelar"
        60,12,,,,.T.)
    
    ACTIVATE MSDIALOG oDlg CENTERED
    
Return

/*/{Protheus.doc} LOCA01071
Altera marcação do perfil na grid
@type Static Function
/*/
Static Function LOCA01071(aRotinas, nLinha, nColPos, oListBox)
    // Colunas: 1=espaço, 2=rotina, 3=P, 4=M, 5=G
    If nColPos >= 4 .And. nColPos <= 6
        aRotinas[nLinha, nColPos] := !aRotinas[nLinha, nColPos]
        oListBox:Refresh()
    EndIf
Return

/*/{Protheus.doc} LOCA01072
Gera o arquivo XNU baseado nas seleções
@type Static Function
/*/
Static Function LOCA01072(cTamanho, aRotinas, oDlg)
Local cArquivo := ""
Local cPath    := ""
Local nHandle  := 0
Local cXML     := ""
Local nTamanho := aScan({"Pequeno","Médio","Grande"}, {|x| x == cTamanho})
Local i
Local lCom     := .T.//Impressão do menu Comercial
Local lOpe     := .T.//Impressão do Menu Operacional
Local cComand  := ""
    
    
    cPath := cGetFile(STR0042,STR0043,1,"",.T.,GETF_LOCALHARD+GETF_NETWORKDRIVE+GETF_RETDIRECTORY) //"Arquivo XNU |*.xnu" //"Salvar Menu Como"
    
    cArquivo := AllTrim(cPath) + STR0044 + Upper(cTamanho) + STR0045 //"SIGALOC_" //".XNU"
    
    // Monta XML
    cXML += '<ApMenu>' + CRLF
    cXML += '	<DocumentProperties>' + CRLF
    cXML += '		<Module>SIGALOC</Module>' + CRLF
    cXML += '		<Version>10.1</Version>' + CRLF
    cXML += '	</DocumentProperties>' + CRLF
    cXML += '	<Menu Status="Enable">' + CRLF
    cXML += '           <Title lang="pt">&Atualizações</Title>' + CRLF
    cXML += '           <Title lang="es">&Actualizaciones</Title>' + CRLF
    cXML += '           <Title lang="en">&Updates</Title>' + CRLF
    cXML += '           <ItemID>A940000001</ItemID>' + CRLF

    cXML += '           <Menu Status="Enable">' + CRLF
	cXML += '           <Title lang="pt">Cadastros</Title>' + CRLF
	cXML += '           <Title lang="es">Archivos</Title>' + CRLF
	cXML += '           <Title lang="en">Records</Title>' + CRLF
	cXML += '           <ItemID>0000019063</ItemID>' + CRLF
	cXML += '           <Menu Status="Enable">' + CRLF

    cXML += '           <Title lang="pt">Cadastros Básicos</Title>' + CRLF
	cXML += '           <Title lang="es">Registros Básicos</Title>' + CRLF
	cXML += '           <Title lang="en">Basic Registrations</Title>' + CRLF
	cXML += '           <ItemID>0000019026</ItemID>' + CRLF

    cXML += '           <MenuItem Status="Enable">' + CRLF
	cXML += '                   <Title lang="pt">Clientes</Title>' + CRLF
	cXML += '			        <Title lang="es">Clientes</Title>' + CRLF
	cXML += '			        <Title lang="en">Customers</Title>' + CRLF
	cXML += '			        <Function>CRMA980</Function>' + CRLF
	cXML += '			        <Type>1</Type>' + CRLF
	cXML += '			        <Access>xxxxxxxxxx</Access>' + CRLF
	cXML += '			        <Module>94</Module>' + CRLF
	cXML += '			        <Owner>0</Owner>' + CRLF
	cXML += '			        <ItemID>0000019027</ItemID>' + CRLF
	cXML += '			        <KeyWord>' + CRLF
	cXML += '				            <KeyWord lang="pt">Clientes</KeyWord>' + CRLF
	cXML += '				            <KeyWord lang="es">Clientes</KeyWord>' + CRLF
	cXML += '				            <KeyWord lang="en">Customers</KeyWord>' + CRLF
	cXML += '			        </KeyWord>' + CRLF
	cXML += '		        </MenuItem>' + CRLF

    cXML += '			<MenuItem Status="Enable">' + CRLF
	cXML += '			        <Title lang="pt">Tabela de Preço</Title>' + CRLF
	cXML += '			        <Title lang="es">Lista de Precio</Title>' + CRLF
	cXML += '			        <Title lang="en">Price List</Title>' + CRLF
	cXML += '			        <Function>OMSA010</Function>' + CRLF
	cXML += '			        <Type>1</Type>' + CRLF
	cXML += '			        <Access>xxxxxxxxxx</Access>' + CRLF
	cXML += '			        <Module>94</Module>' + CRLF
	cXML += '			        <Owner>0</Owner>' + CRLF
	cXML += '			        <ItemID>0000019031</ItemID>' + CRLF
	cXML += '			        <KeyWord>' + CRLF
	cXML += '				            <KeyWord lang="pt">Tabela,preço</KeyWord>' + CRLF
	cXML += '				            <KeyWord lang="es">Lista,precio</KeyWord>' + CRLF
	cXML += '				            <KeyWord lang="en">Table,price</KeyWord>' + CRLF
	cXML += '			        </KeyWord>' + CRLF
	cXML += '		    </MenuItem>' + CRLF

    cXML += '			<MenuItem Status="Enable">' + CRLF
	cXML += '			        <Title lang="pt">Prospect</Title>' + CRLF
	cXML += '			        <Title lang="es">Prospect</Title>' + CRLF
	cXML += '			        <Title lang="en">Prospect</Title>' + CRLF
	cXML += '			        <Function>TMKA260</Function>' + CRLF
	cXML += '			        <Type>1</Type>' + CRLF
	cXML += '			        <Access>xxxxxxxxxx</Access>' + CRLF
	cXML += '			        <Module>94</Module>' + CRLF
	cXML += '			        <Owner>94</Owner>' + CRLF
	cXML += '			        <ItemID>0000019032</ItemID>' + CRLF
	cXML += '			        <KeyWord>' + CRLF
	cXML += '				            <KeyWord lang="pt">Prospect</KeyWord>' + CRLF
	cXML += '				            <KeyWord lang="es">Prospect</KeyWord>' + CRLF
	cXML += '				            <KeyWord lang="en">Prospect</KeyWord>' + CRLF
	cXML += '			        </KeyWord>' + CRLF
	cXML += '		    </MenuItem>' + CRLF

    cXML += '			<MenuItem Status="Enable">' + CRLF
	cXML += '			        <Title lang="pt">Fornecedores</Title>' + CRLF
	cXML += '			        <Title lang="es">Proveedores</Title>' + CRLF
	cXML += '			        <Title lang="en">Suppliers</Title>' + CRLF
	cXML += '			        <Function>MATA020</Function>' + CRLF
	cXML += '			        <Type>1</Type>' + CRLF
	cXML += '			        <Access>xxxxxxxxxx</Access>' + CRLF
	cXML += '			        <Module>94</Module>' + CRLF
	cXML += '			        <Owner>0</Owner>' + CRLF
	cXML += '			        <ItemID>0000019033</ItemID>' + CRLF
	cXML += '			        <KeyWord>' + CRLF
	cXML += '				            <KeyWord lang="pt">Fornecedores</KeyWord>' + CRLF
	cXML += '				            <KeyWord lang="es">Proveedores</KeyWord>' + CRLF
	cXML += '				            <KeyWord lang="en">Suppliers</KeyWord>' + CRLF
	cXML += '			        </KeyWord>' + CRLF
	cXML += '		    </MenuItem>' + CRLF

    cXML += '			<MenuItem Status="Enable">' + CRLF
	cXML += '			        <Title lang="pt">Produtos</Title>' + CRLF
	cXML += '			        <Title lang="es">Productos</Title>' + CRLF
	cXML += '			        <Title lang="en">Products</Title>' + CRLF
	cXML += '			        <Function>MATA010</Function>' + CRLF
	cXML += '			        <Type>1</Type>' + CRLF
	cXML += '			        <Access>xxxxxxxxxx</Access>' + CRLF
	cXML += '			        <Module>94</Module>' + CRLF
	cXML += '			        <Owner>0</Owner>' + CRLF
	cXML += '			        <ItemID>0000019034</ItemID>' + CRLF
	cXML += '			        <KeyWord>' + CRLF
	cXML += '				            <KeyWord lang="pt">Produtos</KeyWord>' + CRLF
	cXML += '				            <KeyWord lang="es">Productos</KeyWord>' + CRLF
	cXML += '				            <KeyWord lang="en">Products</KeyWord>' + CRLF
	cXML += '			        </KeyWord>' + CRLF
	cXML += '		    </MenuItem>' + CRLF

    cXML += '			<MenuItem Status="Enable">' + CRLF
	cXML += '			        <Title lang="pt">Usuário X Rotina X C/c</Title>' + CRLF
	cXML += '			        <Title lang="es">Usuario Vs. Rutina Vs. C/c</Title>' + CRLF
	cXML += '			        <Title lang="en">User X Routine X C/a</Title>' + CRLF
	cXML += '			        <Function>LOCA004</Function>' + CRLF
	cXML += '			        <Type>1</Type>' + CRLF
	cXML += '			        <Access>xxxxxxxxxx</Access>' + CRLF
	cXML += '			        <Module>94</Module>' + CRLF
	cXML += '			        <Owner>94</Owner>' + CRLF
	cXML += '			        <ItemID>0000019039</ItemID>' + CRLF
	cXML += '			        <KeyWord>' + CRLF
	cXML += '				            <KeyWord lang="pt">Usuario,rotina,cc</KeyWord>' + CRLF
	cXML += '				            <KeyWord lang="es">Usuario,rutina,cc</KeyWord>' + CRLF
	cXML += '				            <KeyWord lang="en">User,routine,cc</KeyWord>' + CRLF
	cXML += '			        </KeyWord>' + CRLF
	cXML += '		    </MenuItem>' + CRLF

    cXML += '			<MenuItem Status="Enable">' + CRLF
	cXML += '			        <Title lang="pt">Cadastro Aprovadores</Title>' + CRLF
	cXML += '			        <Title lang="es">Archivo Aprobador</Title>' + CRLF
	cXML += '			        <Title lang="en">Approvals Registration</Title>' + CRLF
	cXML += '			        <Function>LOCA056</Function>' + CRLF
	cXML += '			        <Type>1</Type>' + CRLF
	cXML += '			        <Access>xxxxxxxxxx</Access>' + CRLF
	cXML += '			        <Module>94</Module>' + CRLF
	cXML += '			        <Owner>94</Owner>' + CRLF
	cXML += '			        <ItemID>0000019043</ItemID>' + CRLF
	cXML += '			        <KeyWord>' + CRLF
	cXML += '				            <KeyWord lang="pt">Cadastro,aprovadores</KeyWord>' + CRLF
	cXML += '				            <KeyWord lang="es">Archivo,aprobadores</KeyWord>' + CRLF
	cXML += '				            <KeyWord lang="en">Registration,approvers</KeyWord>' + CRLF
	cXML += '			        </KeyWord>' + CRLF
	cXML += '		    </MenuItem>' + CRLF

    cXML += '			<MenuItem Status="Enable">' + CRLF
	cXML += '			        <Title lang="pt">Vendedores</Title>' + CRLF
	cXML += '			        <Title lang="es">Vendedores</Title>' + CRLF
	cXML += '			        <Title lang="en">Sales Reps</Title>' + CRLF
	cXML += '			        <Function>MATA040</Function>' + CRLF
	cXML += '			        <Type>1</Type>' + CRLF
	cXML += '			        <Access>xxxxxxxxxx</Access>' + CRLF
	cXML += '			        <Module>94</Module>' + CRLF
	cXML += '			        <Owner>0</Owner>' + CRLF
	cXML += '			        <ItemID>0000019044</ItemID>' + CRLF
	cXML += '			        <KeyWord>' + CRLF
	cXML += '				            <KeyWord lang="pt">Vendedores</KeyWord>' + CRLF
	cXML += '				            <KeyWord lang="es">Vendedores</KeyWord>' + CRLF
	cXML += '				            <KeyWord lang="en">Sales Representatives</KeyWord>' + CRLF
	cXML += '			        </KeyWord>' + CRLF
	cXML += '		    </MenuItem>' + CRLF

    cXML += '			<MenuItem Status="Enable">' + CRLF
	cXML += '			        <Title lang="pt">Cond. de Pagamento</Title>' + CRLF
	cXML += '			        <Title lang="es">Cond. de Pago</Title>' + CRLF
	cXML += '			        <Title lang="en">Payment Terms</Title>' + CRLF
	cXML += '			        <Function>MATA360</Function>' + CRLF
	cXML += '			        <Type>1</Type>' + CRLF
	cXML += '			        <Access>xxxxxxxxxx</Access>' + CRLF
	cXML += '			        <Module>94</Module>' + CRLF
	cXML += '			        <Owner>0</Owner>' + CRLF
	cXML += '			        <ItemID>0000019045</ItemID>' + CRLF
	cXML += '			        <KeyWord>' + CRLF
	cXML += '				            <KeyWord lang="pt">Condicao,pagamento</KeyWord>' + CRLF
	cXML += '				            <KeyWord lang="es">Condición,pago</KeyWord>' + CRLF
	cXML += '				            <KeyWord lang="en">Term,payment</KeyWord>' + CRLF
	cXML += '			        </KeyWord>' + CRLF
	cXML += '		    </MenuItem>' + CRLF

    cXML += '			<MenuItem Status="Enable">' + CRLF
	cXML += '			        <Title lang="pt">Naturezas</Title>' + CRLF
	cXML += '			        <Title lang="es">Modalidades</Title>' + CRLF
	cXML += '			        <Title lang="en">Classes</Title>' + CRLF
	cXML += '			        <Function>FINA010</Function>' + CRLF
	cXML += '			        <Type>1</Type>' + CRLF
	cXML += '			        <Access>xxxxxxxxxx</Access>' + CRLF
	cXML += '			        <Module>94</Module>' + CRLF
	cXML += '			        <Owner>0</Owner>' + CRLF
	cXML += '			        <ItemID>0000019046</ItemID>' + CRLF
	cXML += '			        <KeyWord>' + CRLF
	cXML += '				            <KeyWord lang="pt">Naturezas</KeyWord>' + CRLF
	cXML += '				            <KeyWord lang="es">Modalidades</KeyWord>' + CRLF
	cXML += '				            <KeyWord lang="en">Natures</KeyWord>' + CRLF
	cXML += '			        </KeyWord>' + CRLF
	cXML += '		    </MenuItem>' + CRLF

    cXML += '			<MenuItem Status="Enable">' + CRLF
	cXML += '			        <Title lang="pt">Tipos de Ent/saida</Title>' + CRLF
	cXML += '			        <Title lang="es">Tipos de Ent/sal</Title>' + CRLF
	cXML += '			        <Title lang="en">Inp/outp Types</Title>' + CRLF
	cXML += '			        <Function>MATA080</Function>' + CRLF
	cXML += '			        <Type>1</Type>' + CRLF
	cXML += '			        <Access>xxxxxxxxxx</Access>' + CRLF
	cXML += '			        <Module>94</Module>' + CRLF
	cXML += '			        <Owner>0</Owner>' + CRLF
	cXML += '			        <ItemID>0000019050</ItemID>' + CRLF
	cXML += '			        <KeyWord>' + CRLF
	cXML += '				            <KeyWord lang="pt">Tipos,entrada,saida</KeyWord>' + CRLF
	cXML += '				            <KeyWord lang="es">Tipos,entrada,salida</KeyWord>' + CRLF
	cXML += '				            <KeyWord lang="en">Types,inflow,outflow</KeyWord>' + CRLF
	cXML += '			        </KeyWord>' + CRLF
	cXML += '		    </MenuItem>' + CRLF

    cXML += '			<MenuItem Status="Enable">' + CRLF
	cXML += '			        <Title lang="pt">Calendário Medição</Title>' + CRLF
	cXML += '			        <Title lang="es">Calendario Medición</Title>' + CRLF
	cXML += '			        <Title lang="en">Measurement Calendar</Title>' + CRLF
	cXML += '			        <Function>LOCA020</Function>' + CRLF
	cXML += '			        <Type>1</Type>' + CRLF
	cXML += '			        <Access>xxxxxxxxxx</Access>' + CRLF
	cXML += '			        <Module>94</Module>' + CRLF
	cXML += '			        <Owner>0</Owner>' + CRLF
	cXML += '			        <ItemID>0000019051</ItemID>' + CRLF
	cXML += '			        <KeyWord>' + CRLF
	cXML += '				            <KeyWord lang="pt">Calendario,medicao</KeyWord>' + CRLF
	cXML += '				            <KeyWord lang="es">Calendario,medición</KeyWord>' + CRLF
	cXML += '				            <KeyWord lang="en">Calendar,measure</KeyWord>' + CRLF
	cXML += '			        </KeyWord>' + CRLF
	cXML += '		    </MenuItem>' + CRLF

    cXML += '			<MenuItem Status="Enable">' + CRLF
	cXML += '			        <Title lang="pt">Cargos de Contatos</Title>' + CRLF
	cXML += '			        <Title lang="es">Cargos de Contactos</Title>' + CRLF
	cXML += '			        <Title lang="en">Contacts Positions</Title>' + CRLF
	cXML += '			        <Function>TMKA210</Function>' + CRLF
	cXML += '			        <Type>1</Type>' + CRLF
	cXML += '			        <Access>xxxxxxxxxx</Access>' + CRLF
	cXML += '			        <Module>94</Module>' + CRLF
	cXML += '			        <Owner>0</Owner>' + CRLF
	cXML += '			        <ItemID>0000019052</ItemID>' + CRLF
	cXML += '			        <KeyWord>' + CRLF
	cXML += '				            <KeyWord lang="pt">Cargos,contatos</KeyWord>' + CRLF
	cXML += '				            <KeyWord lang="es">Cargos,contactos</KeyWord>' + CRLF
	cXML += '				            <KeyWord lang="en">Positions,contacts</KeyWord>' + CRLF
	cXML += '			        </KeyWord>' + CRLF
	cXML += '		    </MenuItem>' + CRLF

    cXML += '			<MenuItem Status="Enable">' + CRLF
	cXML += '			        <Title lang="pt">Contatos</Title>' + CRLF
	cXML += '			        <Title lang="es">Contactos</Title>' + CRLF
	cXML += '			        <Title lang="en">Contacts</Title>' + CRLF
	cXML += '			        <Function>TMKA070</Function>' + CRLF
	cXML += '			        <Type>1</Type>' + CRLF
	cXML += '			        <Access>xxxxxxxxxx</Access>' + CRLF
	cXML += '			        <Module>94</Module>' + CRLF
	cXML += '			        <Owner>0</Owner>' + CRLF
	cXML += '			        <ItemID>0000019053</ItemID>' + CRLF
	cXML += '			        <KeyWord>' + CRLF
	cXML += '				            <KeyWord lang="pt">Contatos</KeyWord>' + CRLF
	cXML += '				            <KeyWord lang="es">Contactos</KeyWord>' + CRLF
	cXML += '				            <KeyWord lang="en">Contacts</KeyWord>' + CRLF
	cXML += '			        </KeyWord>' + CRLF
	cXML += '		    </MenuItem>' + CRLF

    cXML += '			<MenuItem Status="Enable">' + CRLF
	cXML += '			        <Title lang="pt">Concorrentes</Title>' + CRLF
	cXML += '			        <Title lang="es">Competidores</Title>' + CRLF
	cXML += '			        <Title lang="en">Competitors</Title>' + CRLF
	cXML += '			        <Function>FATA020</Function>' + CRLF
	cXML += '			        <Type>1</Type>' + CRLF
	cXML += '			        <Access>xxxxxxxxxx</Access>' + CRLF
	cXML += '			        <Module>94</Module>' + CRLF
	cXML += '			        <Owner>0</Owner>' + CRLF
	cXML += '			        <ItemID>0000019058</ItemID>' + CRLF
	cXML += '			        <KeyWord>' + CRLF
	cXML += '				            <KeyWord lang="pt"> </KeyWord>' + CRLF
	cXML += '				            <KeyWord lang="es"> </KeyWord>' + CRLF
	cXML += '				            <KeyWord lang="en"> </KeyWord>' + CRLF
	cXML += '			        </KeyWord>' + CRLF
	cXML += '		    </MenuItem>' + CRLF

    cXML += '			<MenuItem Status="Enable">' + CRLF
	cXML += '			        <Title lang="pt">Índice de Correção</Title>' + CRLF
	cXML += '			        <Title lang="es">Índice de Corrección</Title>' + CRLF
	cXML += '			        <Title lang="en">Correction Index</Title>' + CRLF
	cXML += '			        <Function>CNTA070</Function>' + CRLF
	cXML += '			        <Type>1</Type>' + CRLF
	cXML += '			        <Access>xxxxxxxxxx</Access>' + CRLF
	cXML += '			        <Module>94</Module>' + CRLF
	cXML += '			        <Owner>0</Owner>' + CRLF
	cXML += '			        <ItemID>0000019299</ItemID>' + CRLF
	cXML += '			        <KeyWord>' + CRLF
	cXML += '				            <KeyWord lang="pt"> </KeyWord>' + CRLF
	cXML += '				            <KeyWord lang="es"> </KeyWord>' + CRLF
	cXML += '				            <KeyWord lang="en"> </KeyWord>' + CRLF
	cXML += '			        </KeyWord>' + CRLF
	cXML += '		    </MenuItem>' + CRLF

    cXML += '			<MenuItem Status="Enable">' + CRLF
	cXML += '			        <Title lang="pt">Cadastro de Processos</Title>' + CRLF
	cXML += '			        <Title lang="es">Registro de Procesos</Title>' + CRLF
	cXML += '			        <Title lang="en">Processes Registration</Title>' + CRLF
	cXML += '			        <Function>LOCA083</Function>' + CRLF
	cXML += '			        <Type>1</Type>' + CRLF
	cXML += '			        <Access>xxxxxxxxxx</Access>' + CRLF
	cXML += '			        <Module>94</Module>' + CRLF
	cXML += '			        <Owner>0</Owner>' + CRLF
	cXML += '			        <ItemID>0000017328</ItemID>' + CRLF
	cXML += '			        <KeyWord>' + CRLF
	cXML += '				            <KeyWord lang="pt"> </KeyWord>' + CRLF
	cXML += '				            <KeyWord lang="es"> </KeyWord>' + CRLF
	cXML += '				            <KeyWord lang="en"> </KeyWord>' + CRLF
	cXML += '			        </KeyWord>' + CRLF
	cXML += '		    </MenuItem>' + CRLF

    cXML += '			<MenuItem Status="Enable">' + CRLF
	cXML += '			        <Title lang="pt">Cadastro de Status</Title>' + CRLF
	cXML += '			        <Title lang="es">Registro de Estatus</Title>' + CRLF
	cXML += '			        <Title lang="en">Status File</Title>' + CRLF
	cXML += '			        <Function>LOCA081</Function>' + CRLF
	cXML += '			        <Type>1</Type>' + CRLF
	cXML += '			        <Access>xxxxxxxxxx</Access>' + CRLF
	cXML += '			        <Module>94</Module>' + CRLF
	cXML += '			        <Owner>0</Owner>' + CRLF
	cXML += '			        <ItemID>0000017709</ItemID>' + CRLF
	cXML += '			        <KeyWord>' + CRLF
	cXML += '				            <KeyWord lang="pt"> </KeyWord>' + CRLF
	cXML += '				            <KeyWord lang="es"> </KeyWord>' + CRLF
	cXML += '				            <KeyWord lang="en"> </KeyWord>' + CRLF
	cXML += '			        </KeyWord>' + CRLF
	cXML += '		    </MenuItem>' + CRLF

    cXML += '			<MenuItem Status="Enable">' + CRLF
	cXML += '			        <Title lang="pt">Cadastro de Sub-status</Title>' + CRLF
	cXML += '			        <Title lang="es">Reg. de Subestatus</Title>' + CRLF
	cXML += '			        <Title lang="en">Substatus Register</Title>' + CRLF
	cXML += '			        <Function>LOCA085</Function>' + CRLF
	cXML += '			        <Type>1</Type>' + CRLF
	cXML += '			        <Tables>FQG</Tables>' + CRLF
	cXML += '			        <Tables>FQH</Tables>' + CRLF
	cXML += '			        <Access>xxxxxxxxxx</Access>' + CRLF
	cXML += '			        <Module>94</Module>' + CRLF
	cXML += '			        <Owner>0</Owner>' + CRLF
	cXML += '			        <ItemID>0000021761</ItemID>' + CRLF
	cXML += '			        <KeyWord>' + CRLF
	cXML += '				            <KeyWord lang="pt"> </KeyWord>' + CRLF
	cXML += '				            <KeyWord lang="es"> </KeyWord>' + CRLF
	cXML += '				            <KeyWord lang="en"> </KeyWord>' + CRLF
	cXML += '			        </KeyWord>' + CRLF
	cXML += '		    </MenuItem>' + CRLF

    cXML += '				<MenuItem Status="Enable">' + CRLF
	cXML += '				        <Title lang="pt">Hístorico de Índices</Title>' + CRLF
	cXML += '				        <Title lang="es">Historial de Índices</Title>' + CRLF
	cXML += '				        <Title lang="en">Index History</Title>' + CRLF
	cXML += '				        <Function>CNTA080</Function>' + CRLF
	cXML += '				        <Type>1</Type>' + CRLF
	cXML += '				        <Access>xxxxxxxxxx</Access>' + CRLF
	cXML += '				        <Module>94</Module>' + CRLF
	cXML += '				        <Owner>0</Owner>' + CRLF
	cXML += '				        <ItemID>0000017708</ItemID>' + CRLF
	cXML += '				        <KeyWord>' + CRLF
	cXML += '					            <KeyWord lang="pt"> </KeyWord>' + CRLF
	cXML += '					            <KeyWord lang="es"> </KeyWord>' + CRLF
	cXML += '					            <KeyWord lang="en"> </KeyWord>' + CRLF
	cXML += '				        </KeyWord>' + CRLF
	cXML += '			    </MenuItem>' + CRLF
    cXML += '		</Menu>' + CRLF
	cXML += '	    </Menu>' + CRLF
    
    // Adiciona rotinas conforme perfil
    For i := 1 To Len(aRotinas)
		//Pequeno
        If (nTamanho == 1 .And. aRotinas[i,4])
		   
		   If aRotinas[i,3] == "Comercial" .AND. lCom
		   		cXML += '	<Menu Status="Enable">' + CRLF
				cXML += '			<Title lang="pt">Comercial</Title>' + CRLF
				cXML += '			<Title lang="es">Comercial</Title>' + CRLF
				cXML += '			<Title lang="en">Sales</Title>' + CRLF
				cXML += '			<ItemID>0000019064</ItemID>' + CRLF
				lCom := .F.
			EndIf 				

		   If aRotinas[i,3] == "Operacional" .AND. lOpe
		   		cXML += '	<Menu Status="Enable">' + CRLF
				cXML += '			<Title lang="pt">Operacional</Title>' + CRLF
				cXML += '			<Title lang="es">Operativo</Title>' + CRLF
				cXML += '			<Title lang="en">Operational</Title>' + CRLF
				cXML += '			<ItemID>0000019089</ItemID>' + CRLF
				lOpe := .F.
			EndIf 							
            
            cXML += '		<MenuItem Status="Enable">' + CRLF
            cXML += '			<Title lang="pt">' + AllTrim(aRotinas[i,1]) + '</Title>' + CRLF
            cXML += '			<Title lang="es">' + AllTrim(aRotinas[i,1]) + '</Title>' + CRLF
            cXML += '			<Title lang="en">' + AllTrim(aRotinas[i,1]) + '</Title>' + CRLF
            cXML += '			<Function>' + AllTrim(aRotinas[i,2]) + '</Function>' + CRLF
            cXML += '			<Type>1</Type>' + CRLF
            cXML += '			<Access>xxxxxxxxxx</Access>' + CRLF
            cXML += '			<Module>94</Module>' + CRLF
            cXML += '			<Owner>94</Owner>' + CRLF
            cXML += '		</MenuItem>' + CRLF

			If i == 6//como o menu Comercial tem 6 itens, ao chegar no 6 fecho a tag Comercial
				cXML += '	</Menu>' + CRLF
			EndIf									
        EndIf

		//Médio
        If (nTamanho == 2 .And. aRotinas[i,5])
		   
		   If aRotinas[i,3] == "Comercial" .AND. lCom
		   		cXML += '	<Menu Status="Enable">' + CRLF
				cXML += '			<Title lang="pt">Comercial</Title>' + CRLF
				cXML += '			<Title lang="es">Comercial</Title>' + CRLF
				cXML += '			<Title lang="en">Sales</Title>' + CRLF
				cXML += '			<ItemID>0000019064</ItemID>' + CRLF
				lCom := .F.
			EndIf 				

		   If aRotinas[i,3] == "Operacional" .AND. lOpe
		   		cXML += '	<Menu Status="Enable">' + CRLF
				cXML += '			<Title lang="pt">Operacional</Title>' + CRLF
				cXML += '			<Title lang="es">Operativo</Title>' + CRLF
				cXML += '			<Title lang="en">Operational</Title>' + CRLF
				cXML += '			<ItemID>0000019089</ItemID>' + CRLF
				lOpe := .F.
			EndIf 							
            
            cXML += '		<MenuItem Status="Enable">' + CRLF
            cXML += '			<Title lang="pt">' + AllTrim(aRotinas[i,1]) + '</Title>' + CRLF
            cXML += '			<Title lang="es">' + AllTrim(aRotinas[i,1]) + '</Title>' + CRLF
            cXML += '			<Title lang="en">' + AllTrim(aRotinas[i,1]) + '</Title>' + CRLF
            cXML += '			<Function>' + AllTrim(aRotinas[i,2]) + '</Function>' + CRLF
            cXML += '			<Type>1</Type>' + CRLF
            cXML += '			<Access>xxxxxxxxxx</Access>' + CRLF
            cXML += '			<Module>94</Module>' + CRLF
            cXML += '			<Owner>94</Owner>' + CRLF
            cXML += '		</MenuItem>' + CRLF

			If i == 6//como o menu Comercial tem 6 itens, ao chegar no 6 fecho a tag Comercial
				cXML += '	</Menu>' + CRLF
			EndIf									
        EndIf

		//Grande
        If (nTamanho == 3 .And. aRotinas[i,6])
		   
		   If aRotinas[i,3] == "Comercial" .AND. lCom
		   		cXML += '	<Menu Status="Enable">' + CRLF
				cXML += '			<Title lang="pt">Comercial</Title>' + CRLF
				cXML += '			<Title lang="es">Comercial</Title>' + CRLF
				cXML += '			<Title lang="en">Sales</Title>' + CRLF
				cXML += '			<ItemID>0000019064</ItemID>' + CRLF
				lCom := .F.
			EndIf 				

		   If aRotinas[i,3] == "Operacional" .AND. lOpe
		   		cXML += '	<Menu Status="Enable">' + CRLF
				cXML += '			<Title lang="pt">Operacional</Title>' + CRLF
				cXML += '			<Title lang="es">Operativo</Title>' + CRLF
				cXML += '			<Title lang="en">Operational</Title>' + CRLF
				cXML += '			<ItemID>0000019089</ItemID>' + CRLF
				lOpe := .F.
			EndIf 							
            
            cXML += '		<MenuItem Status="Enable">' + CRLF
            cXML += '			<Title lang="pt">' + AllTrim(aRotinas[i,1]) + '</Title>' + CRLF
            cXML += '			<Title lang="es">' + AllTrim(aRotinas[i,1]) + '</Title>' + CRLF
            cXML += '			<Title lang="en">' + AllTrim(aRotinas[i,1]) + '</Title>' + CRLF
            cXML += '			<Function>' + AllTrim(aRotinas[i,2]) + '</Function>' + CRLF
            cXML += '			<Type>1</Type>' + CRLF
            cXML += '			<Access>xxxxxxxxxx</Access>' + CRLF
            cXML += '			<Module>94</Module>' + CRLF
            cXML += '			<Owner>94</Owner>' + CRLF
            cXML += '		</MenuItem>' + CRLF

			If i == 6//como o menu Comercial tem 6 itens, ao chegar no 6 fecho a tag Comercial
				cXML += '	</Menu>' + CRLF
			EndIf												
        EndIf				
    Next i
		cXML += '	</Menu>' + CRLF
 		cXML += '	<Menu Status="Enable">' + CRLF
		cXML += '		<Title lang="pt">App Rental</Title>' + CRLF
		cXML += '		<Title lang="es">App Rental</Title>' + CRLF
		cXML += '		<Title lang="en">Rental App</Title>' + CRLF
		cXML += '		<ItemID>0000022317</ItemID>' + CRLF
		cXML += '	<Menu Status="Enable">' + CRLF
		cXML += '		<Title lang="pt">Entrada e Saída de Equipamentos</Title>' + CRLF
		cXML += '		<Title lang="es">Entrada Y Salida Equip</Title>' + CRLF
		cXML += '		<Title lang="en">Equipment Inflow And Outflow</Title>' + CRLF
		cXML += '		<ItemID>0000022318</ItemID>' + CRLF
		cXML += '		<MenuItem Status="Enable">' + CRLF
		cXML += '			<Title lang="pt">Definição de Entrada e Saída</Title>' + CRLF
		cXML += '			<Title lang="es">Defin. Entrada Y Salida</Title>' + CRLF
		cXML += '			<Title lang="en">Inflow And Outflow Definitn</Title>' + CRLF
		cXML += '			<Function>LOCA088</Function>' + CRLF
		cXML += '			<Type>1</Type>' + CRLF
		cXML += '			<Access>xxxxxxxxxx</Access>' + CRLF
		cXML += '			<Module>94</Module>' + CRLF
		cXML += '			<Owner>0</Owner>' + CRLF
		cXML += '			<ItemID>0000022319</ItemID>' + CRLF
		cXML += '			<KeyWord>' + CRLF
		cXML += '				<KeyWord lang="pt">Definição de Entrada e Saída</KeyWord>' + CRLF
		cXML += '				<KeyWord lang="es">Definición de Entrada Y Salida</KeyWord>' + CRLF
		cXML += '				<KeyWord lang="en">Inflow And Outflow Definitn</KeyWord>' + CRLF
		cXML += '			</KeyWord>' + CRLF
		cXML += '		</MenuItem>' + CRLF
		cXML += '		<MenuItem Status="Enable">' + CRLF
		cXML += '			<Title lang="pt">Pontos de Verificação</Title>' + CRLF
		cXML += '			<Title lang="es">Ptos Verificación</Title>' + CRLF
		cXML += '			<Title lang="en">Checking Points</Title>' + CRLF
		cXML += '			<Function>LOCA089</Function>' + CRLF
		cXML += '			<Type>1</Type>' + CRLF
		cXML += '			<Access>xxxxxxxxxx</Access>' + CRLF
		cXML += '			<Module>94</Module>' + CRLF
		cXML += '			<Owner>0</Owner>' + CRLF
		cXML += '			<ItemID>0000022320</ItemID>' + CRLF
		cXML += '			<KeyWord>' + CRLF
		cXML += '				<KeyWord lang="pt">Pontos de Entrada e Saída</KeyWord>' + CRLF
		cXML += '				<KeyWord lang="es">Puntos de Entrada Y Salida</KeyWord>' + CRLF
		cXML += '				<KeyWord lang="en">Inflow And Outflow Points</KeyWord>' + CRLF
		cXML += '			</KeyWord>' + CRLF
		cXML += '		</MenuItem>' + CRLF
		cXML += '		<MenuItem Status="Enable">' + CRLF
		cXML += '			<Title lang="pt">Modelos de Entrada e Saída</Title>' + CRLF
		cXML += '			<Title lang="es">Mod Entrada Y Salida</Title>' + CRLF
		cXML += '			<Title lang="en">Inflow And Outflow Models</Title>' + CRLF
		cXML += '			<Function>LOCA090</Function>' + CRLF
		cXML += '			<Type>1</Type>' + CRLF
		cXML += '			<Access>xxxxxxxxxx</Access>' + CRLF
		cXML += '			<Module>94</Module>' + CRLF
		cXML += '			<Owner>0</Owner>' + CRLF
		cXML += '			<ItemID>0000022321</ItemID>' + CRLF
		cXML += '			<KeyWord>' + CRLF
		cXML += '				<KeyWord lang="pt">Modelos de Entrada e Saída</KeyWord>' + CRLF
		cXML += '						<KeyWord lang="es">Modelos de Entrada Y Salida</KeyWord>' + CRLF
		cXML += '						<KeyWord lang="en">Inflow And Outflow Models</KeyWord>' + CRLF
		cXML += '					</KeyWord>' + CRLF
		cXML += '				</MenuItem>' + CRLF
		cXML += '				<MenuItem Status="Enable">' + CRLF
		cXML += '					<Title lang="pt">Feedback de Entrada e Saída</Title>' + CRLF
		cXML += '					<Title lang="es">Feedback  Entrada Y Salida</Title>' + CRLF
		cXML += '					<Title lang="en">Inflow And Outflow Feedback</Title>' + CRLF
		cXML += '					<Function>LOCA091</Function>' + CRLF
		cXML += '					<Type>1</Type>' + CRLF
		cXML += '					<Access>xxxxxxxxxx</Access>' + CRLF
		cXML += '					<Module>94</Module>' + CRLF
		cXML += '					<Owner>0</Owner>' + CRLF
		cXML += '					<ItemID>0000022322</ItemID>' + CRLF
		cXML += '					<KeyWord>' + CRLF
		cXML += '						<KeyWord lang="pt">Feedback de Entrada e Saída</KeyWord>' + CRLF
		cXML += '						<KeyWord lang="es">Feedback de Entrada Y Salida</KeyWord>' + CRLF
		cXML += '						<KeyWord lang="en">Inflow And Outflow Feedback</KeyWord>' + CRLF
		cXML += '					</KeyWord>' + CRLF
		cXML += '				</MenuItem>' + CRLF
		cXML += '			</Menu>' + CRLF
		//cXML += '			</Menu>' + CRLF
	cXML += '			</Menu>  ' + CRLF    
    cXML += '	</Menu>' + CRLF
	
	cXML += '			<Menu Status="Enable">' + CRLF
	cXML += '				<Title lang="pt">&Consultas</Title>' + CRLF
	cXML += '				<Title lang="es">&Consultas</Title>' + CRLF
	cXML += '				<Title lang="en">&Queries</Title>' + CRLF
	cXML += '				<ItemID>A940000002</ItemID>' + CRLF
	cXML += '					<MenuItem Status="Enable">' + CRLF
	cXML += '						<Title lang="pt">Genéricos</Title>' + CRLF
	cXML += '						<Title lang="es">Genéricos</Title>' + CRLF
	cXML += '						<Title lang="en">Generic</Title>' + CRLF
	cXML += '						<Function>EDAPP</Function>' + CRLF
	cXML += '						<Type>1</Type>' + CRLF
	cXML += '						<Access>xxxxxxxxxx</Access>' + CRLF
	cXML += '						<Module>94</Module>' + CRLF
	cXML += '						<Owner>0</Owner>' + CRLF
	cXML += '						<ItemID>0000019100</ItemID>' + CRLF
	cXML += '						<KeyWord>' + CRLF
	cXML += '							<KeyWord lang="pt">Genericos</KeyWord>' + CRLF
	cXML += '							<KeyWord lang="es">Genéricos</KeyWord>' + CRLF
	cXML += '							<KeyWord lang="en">Generic</KeyWord>' + CRLF
	cXML += '						</KeyWord>' + CRLF
	cXML += '					</MenuItem>' + CRLF
	cXML += '					<MenuItem Status="Enable">' + CRLF
	cXML += '						<Title lang="pt">Gen. Relacional</Title>' + CRLF
	cXML += '						<Title lang="es">Gen. Relacional</Title>' + CRLF
	cXML += '						<Title lang="en">Relational Gen.</Title>' + CRLF
	cXML += '						<Function>MPVIEW</Function>' + CRLF
	cXML += '						<Type>1</Type>' + CRLF
	cXML += '						<Access>xxxxxxxxxx</Access>' + CRLF
	cXML += '						<Module>94</Module>' + CRLF
	cXML += '						<Owner>0</Owner>' + CRLF
	cXML += '						<ItemID>0000019097</ItemID>' + CRLF
	cXML += '									<KeyWord>' + CRLF
	cXML += '										<KeyWord lang="pt">Generico,relacional</KeyWord>' + CRLF
	cXML += '										<KeyWord lang="es">Genérico,relacional</KeyWord>' + CRLF
	cXML += '										<KeyWord lang="en">Generic,relational</KeyWord>' + CRLF
	cXML += '									</KeyWord>' + CRLF
	cXML += '								</MenuItem>' + CRLF
	cXML += '							<Menu Status="Enable">' + CRLF
	cXML += '								<Title lang="pt">Smartview</Title>' + CRLF
	cXML += '								<Title lang="es">Smartview</Title>' + CRLF
	cXML += '								<Title lang="en">Smartview</Title>' + CRLF
	cXML += '								<ItemID>0000023034</ItemID>' + CRLF
	cXML += '							<Menu Status="Enable">' + CRLF
	cXML += '								<Title lang="pt">Manutenção</Title>' + CRLF
	cXML += '								<Title lang="es">Mantenimiento</Title>' + CRLF
	cXML += '								<Title lang="en">Maintenance</Title>' + CRLF
	cXML += '								<ItemID>0000023035</ItemID>' + CRLF
	cXML += '								<MenuItem Status="Enable">' + CRLF
	cXML += '									<Title lang="pt">Custo de Equipamento Por Cliente</Title>' + CRLF
	cXML += '									<Title lang="es">Costo Del Equipamiento Por Cliente</Title>' + CRLF
	cXML += '									<Title lang="en">Equipment Cost Per Customer</Title>' + CRLF
	cXML += '									<Function>LOCSV005</Function>' + CRLF
	cXML += '									<Type>1</Type>' + CRLF
	cXML += '									<Access>xxxxxxxxxx</Access>' + CRLF
	cXML += '									<Module>94</Module>' + CRLF
	cXML += '									<Owner>0</Owner>' + CRLF
	cXML += '									<ItemID>0000023036</ItemID>' + CRLF
	cXML += '									<KeyWord>' + CRLF
	cXML += '										<KeyWord lang="pt">Custo de Equipamento Por Clien</KeyWord>' + CRLF
	cXML += '										<KeyWord lang="es">Costo Del Equipamiento Por Clien</KeyWord>' + CRLF
	cXML += '										<KeyWord lang="en">Equipment Cost Per Customer</KeyWord>' + CRLF
	cXML += '									</KeyWord>' + CRLF
	cXML += '								</MenuItem>' + CRLF
	cXML += '								<MenuItem Status="Enable">' + CRLF
	cXML += '									<Title lang="pt">Taxa de Confiabilidade</Title>' + CRLF
	cXML += '									<Title lang="es">Tasa de Confiab.</Title>' + CRLF
	cXML += '									<Title lang="en">Reliability Rate</Title>' + CRLF
	cXML += '									<Function>LOCSV003</Function>' + CRLF
	cXML += '									<Type>1</Type>' + CRLF
	cXML += '									<Access>xxxxxxxxxx</Access>' + CRLF
	cXML += '									<Module>94</Module>' + CRLF
	cXML += '									<Owner>0</Owner>' + CRLF
	cXML += '									<ItemID>0000023040</ItemID>' + CRLF
	cXML += '									<KeyWord>' + CRLF
	cXML += '										<KeyWord lang="pt">Visão de Dados da Taxa de Conf</KeyWord>' + CRLF
	cXML += '										<KeyWord lang="es">Visión de Datos de La Tasa de Conf</KeyWord>' + CRLF
	cXML += '										<KeyWord lang="en">Rental Reliability Data View</KeyWord>' + CRLF
	cXML += '									</KeyWord>' + CRLF
	cXML += '								</MenuItem>' + CRLF
	cXML += '								<MenuItem Status="Enable">' + CRLF
	cXML += '									<Title lang="pt">Custo Extra</Title>' + CRLF
	cXML += '									<Title lang="es">Costo Extra</Title>' + CRLF
	cXML += '									<Title lang="en">Extra Cost</Title>' + CRLF
	cXML += '									<Function>LOCSV004</Function>' + CRLF
	cXML += '									<Type>1</Type>' + CRLF
	cXML += '									<Access>xxxxxxxxxx</Access>' + CRLF
	cXML += '									<Module>94</Module>' + CRLF
	cXML += '									<Owner>0</Owner>' + CRLF
	cXML += '									<ItemID>0000023041</ItemID>' + CRLF
	cXML += '									<KeyWord>' + CRLF
	cXML += '										<KeyWord lang="pt">Visão de Dados do Custo Extra</KeyWord>' + CRLF
	cXML += '										<KeyWord lang="es">Visión de Datos Del Costo Extra</KeyWord>' + CRLF
	cXML += '										<KeyWord lang="en">Extra Cost Data View</KeyWord>' + CRLF
	cXML += '									</KeyWord>' + CRLF
	cXML += '								</MenuItem>' + CRLF
	cXML += '							</Menu>' + CRLF
	cXML += '							<Menu Status="Enable">' + CRLF
	cXML += '								<Title lang="pt">Saúde Financeira dos Contratos</Title>' + CRLF
	cXML += '								<Title lang="es">Salud Financiera de Contratos</Title>' + CRLF
	cXML += '								<Title lang="en">Financial Health Of Contracts</Title>' + CRLF
	cXML += '								<ItemID>0000023304</ItemID>' + CRLF
	cXML += '								<MenuItem Status="Enable">' + CRLF
	cXML += '									<Title lang="pt">Tabela Dinâmica de Contratos</Title>' + CRLF
	cXML += '									<Title lang="es">Tabla Dinámica de Contratos</Title>' + CRLF
	cXML += '									<Title lang="en">Dynamic Table Of Contracts</Title>' + CRLF
	cXML += '									<Function>LOCSV006</Function>' + CRLF
	cXML += '									<Type>1</Type>' + CRLF
	cXML += '									<Access>xxxxxxxxxx</Access>' + CRLF
	cXML += '									<Module>94</Module>' + CRLF
	cXML += '									<Owner>0</Owner>' + CRLF
	cXML += '									<ItemID>0000023305</ItemID>' + CRLF
	cXML += '									<KeyWord>' + CRLF
	cXML += '										<KeyWord lang="pt">Tabela Dinâmica de Contratos</KeyWord>' + CRLF
	cXML += '										<KeyWord lang="es">Tabla Dinámica de Contratos</KeyWord>' + CRLF
	cXML += '										<KeyWord lang="en">Dynamic Table Of Contracts</KeyWord>' + CRLF
	cXML += '									</KeyWord>' + CRLF
	cXML += '								</MenuItem>' + CRLF
	cXML += '								<MenuItem Status="Enable">' + CRLF
	cXML += '									<Title lang="pt">Saldo de Contratos</Title>' + CRLF
	cXML += '									<Title lang="es">Saldo de Contratos</Title>' + CRLF
	cXML += '									<Title lang="en">Balance Of Contracts</Title>' + CRLF
	cXML += '									<Function>LOCSV007</Function>' + CRLF
	cXML += '									<Type>1</Type>' + CRLF
	cXML += '									<Access>xxxxxxxxxx</Access>' + CRLF
	cXML += '									<Module>94</Module>' + CRLF
	cXML += '									<Owner>0</Owner>' + CRLF
	cXML += '									<ItemID>0000023361</ItemID>' + CRLF
	cXML += '									<KeyWord>' + CRLF
	cXML += '										<KeyWord lang="pt">Equipamentos a Vencer</KeyWord>' + CRLF
	cXML += '										<KeyWord lang="es">Equipamientos Por Vencer</KeyWord>' + CRLF
	cXML += '										<KeyWord lang="en">Equipment Due</KeyWord>' + CRLF
	cXML += '									</KeyWord>' + CRLF
	cXML += '								</MenuItem>' + CRLF
	cXML += '								<MenuItem Status="Enable">' + CRLF
	cXML += '									<Title lang="pt">Medições Lançadas</Title>' + CRLF
	cXML += '									<Title lang="es">Mediciones Registradas</Title>' + CRLF
	cXML += '									<Title lang="en">Measurements Entered</Title>' + CRLF
	cXML += '									<Function>LOCSV008</Function>' + CRLF
	cXML += '									<Type>1</Type>' + CRLF
	cXML += '									<Access>xxxxxxxxxx</Access>' + CRLF
	cXML += '									<Module>94</Module>' + CRLF
	cXML += '									<Owner>0</Owner>' + CRLF
	cXML += '									<ItemID>0000023362</ItemID>' + CRLF
	cXML += '									<KeyWord>' + CRLF
	cXML += '										<KeyWord lang="pt">Medições Lançadas</KeyWord>' + CRLF
	cXML += '										<KeyWord lang="es">Medicones Registradas</KeyWord>' + CRLF
	cXML += '										<KeyWord lang="en">Measurements Entered</KeyWord>' + CRLF
	cXML += '									</KeyWord>' + CRLF
	cXML += '								</MenuItem>' + CRLF
	cXML += '								<MenuItem Status="Enable">' + CRLF
	cXML += '									<Title lang="pt">Faturas de Locação</Title>' + CRLF
	cXML += '									<Title lang="es">Facturas de Asign.</Title>' + CRLF
	cXML += '									<Title lang="en">Leasing Invoices</Title>' + CRLF
	cXML += '									<Function>LOCSV009</Function>' + CRLF
	cXML += '									<Type>1</Type>' + CRLF
	cXML += '									<Access>xxxxxxxxxx</Access>' + CRLF
	cXML += '									<Module>94</Module>' + CRLF
	cXML += '									<Owner>0</Owner>' + CRLF
	cXML += '									<ItemID>0000023849</ItemID>' + CRLF
	cXML += '									<KeyWord>' + CRLF
	cXML += '										<KeyWord lang="pt">Faturas de Locação</KeyWord>' + CRLF
	cXML += '										<KeyWord lang="es">Facturas de Asignación</KeyWord>' + CRLF
	cXML += '										<KeyWord lang="en">Leasing Invoices</KeyWord>' + CRLF
	cXML += '									</KeyWord>' + CRLF
	cXML += '								</MenuItem>' + CRLF
	cXML += '								<MenuItem Status="Enable">' + CRLF
	cXML += '									<Title lang="pt">Contratos Com Reajuste Pend.</Title>' + CRLF
	cXML += '									<Title lang="es">Contratos Con Reajuste Pend.</Title>' + CRLF
	cXML += '									<Title lang="en">Contracts W/ Pending Adjustmts</Title>' + CRLF
	cXML += '									<Function>LOCSV012</Function>' + CRLF
	cXML += '									<Type>1</Type>' + CRLF
	cXML += '									<Access>xxxxxxxxxx</Access>' + CRLF
	cXML += '									<Module>94</Module>' + CRLF
	cXML += '									<Owner>0</Owner>' + CRLF
	cXML += '									<ItemID>0000023850</ItemID>' + CRLF
	cXML += '									<KeyWord>' + CRLF
	cXML += '										<KeyWord lang="pt">Contratos Com Reajuste Pendent</KeyWord>' + CRLF
	cXML += '										<KeyWord lang="es">Contratos Con Reajuste Pend.</KeyWord>' + CRLF
	cXML += '										<KeyWord lang="en">Contracts With Pending Adjustments</KeyWord>' + CRLF
	cXML += '									</KeyWord>' + CRLF
	cXML += '								</MenuItem>' + CRLF
	cXML += '							</Menu>' + CRLF
	cXML += '							<Menu Status="Enable">' + CRLF
	cXML += '								<Title lang="pt">Movimentações</Title>' + CRLF
	cXML += '								<Title lang="es">Movimiento</Title>' + CRLF
	cXML += '								<Title lang="en">Transactions</Title>' + CRLF
	cXML += '								<ItemID>0000023844</ItemID>' + CRLF
	cXML += '								<MenuItem Status="Enable">' + CRLF
	cXML += '									<Title lang="pt">Remessas de Locação</Title>' + CRLF
	cXML += '									<Title lang="es">Envíos de Asign.</Title>' + CRLF
	cXML += '									<Title lang="en">Leasing Remittances</Title>' + CRLF
	cXML += '									<Function>LOCSV010</Function>' + CRLF
	cXML += '									<Type>1</Type>' + CRLF
	cXML += '									<Access>xxxxxxxxxx</Access>' + CRLF
	cXML += '									<Module>94</Module>' + CRLF
	cXML += '									<Owner>0</Owner>' + CRLF
	cXML += '									<ItemID>0000023845</ItemID>' + CRLF
	cXML += '									<KeyWord>' + CRLF
	cXML += '										<KeyWord lang="pt">Remessas de Locaçã</KeyWord>' + CRLF
	cXML += '										<KeyWord lang="es">Envíos de Asignación</KeyWord>' + CRLF
	cXML += '										<KeyWord lang="en">Leasing Remittances</KeyWord>' + CRLF
	cXML += '									</KeyWord>' + CRLF
	cXML += '								</MenuItem>' + CRLF
	cXML += '								<MenuItem Status="Enable">' + CRLF
	cXML += '									<Title lang="pt">Retornos de Locação</Title>' + CRLF
	cXML += '									<Title lang="es">Devol. Asignac.</Title>' + CRLF
	cXML += '									<Title lang="en">Leasing Returns</Title>' + CRLF
	cXML += '									<Function>LOCSV011</Function>' + CRLF
	cXML += '									<Type>1</Type>' + CRLF
	cXML += '									<Access>xxxxxxxxxx</Access>' + CRLF
	cXML += '									<Module>94</Module>' + CRLF
	cXML += '									<Owner>0</Owner>' + CRLF
	cXML += '									<ItemID>0000023847</ItemID>' + CRLF
	cXML += '									<KeyWord>' + CRLF
	cXML += '										<KeyWord lang="pt"> </KeyWord>' + CRLF
	cXML += '										<KeyWord lang="es"> </KeyWord>' + CRLF
	cXML += '										<KeyWord lang="en"> </KeyWord>' + CRLF
	cXML += '									</KeyWord>' + CRLF
	cXML += '								</MenuItem>' + CRLF
	cXML += '							</Menu>' + CRLF
	cXML += '							</Menu>' + CRLF
	cXML += '						</Menu>' + CRLF

	cXML += '							<Menu Status="Enable">' + CRLF
	cXML += '							<Title lang="pt">&Relatorios</Title>' + CRLF
	cXML += '							<Title lang="es">&Informes</Title>' + CRLF
	cXML += '							<Title lang="en">&Reports</Title>' + CRLF
	cXML += '							<ItemID>A940000003</ItemID>' + CRLF
	cXML += '							<Menu Status="Enable">' + CRLF
	cXML += '								<Title lang="pt">Comercial</Title>' + CRLF
	cXML += '								<Title lang="es">Comercial</Title>' + CRLF
	cXML += '								<Title lang="en">Sales</Title>' + CRLF
	cXML += '								<ItemID>0000017351</ItemID>' + CRLF
	cXML += '								<MenuItem Status="Enable">' + CRLF
	cXML += '									<Title lang="pt">Analise de as</Title>' + CRLF
	cXML += '									<Title lang="es">Análisis de as</Title>' + CRLF
	cXML += '									<Title lang="en">as Analysis</Title>' + CRLF
	cXML += '									<Function>LOCR035</Function>' + CRLF
	cXML += '									<Type>1</Type>' + CRLF
	cXML += '									<Access>xxxxxxxxxx</Access>' + CRLF
	cXML += '									<Module>94</Module>' + CRLF
	cXML += '									<Owner>94</Owner>' + CRLF
	cXML += '									<ItemID>0000017772</ItemID>' + CRLF
	cXML += '									<KeyWord>' + CRLF
	cXML += '										<KeyWord lang="pt">Analise de as</KeyWord>' + CRLF
	cXML += '										<KeyWord lang="es">Análisis de as</KeyWord>' + CRLF
	cXML += '										<KeyWord lang="en">as Analysis</KeyWord>' + CRLF
	cXML += '									</KeyWord>' + CRLF
	cXML += '								</MenuItem>' + CRLF
	cXML += '								<MenuItem Status="Enable">' + CRLF
	cXML += '									<Title lang="pt">Analise Tecnica</Title>' + CRLF
	cXML += '									<Title lang="es">Análisis Técnica</Title>' + CRLF
	cXML += '									<Title lang="en">Technical Analysis</Title>' + CRLF
	cXML += '									<Function>LOCR026</Function>' + CRLF
	cXML += '									<Type>1</Type>' + CRLF
	cXML += '									<Access>xxxxxxxxxx</Access>' + CRLF
	cXML += '									<Module>94</Module>' + CRLF
	cXML += '									<Owner>94</Owner>' + CRLF
	cXML += '									<ItemID>0000017774</ItemID>' + CRLF
	cXML += '									<KeyWord>' + CRLF
	cXML += '										<KeyWord lang="pt">Analise Tecnica</KeyWord>' + CRLF
	cXML += '										<KeyWord lang="es">Análisis Técnica</KeyWord>' + CRLF
	cXML += '										<KeyWord lang="en">Technical Analysis</KeyWord>' + CRLF
	cXML += '									</KeyWord>' + CRLF
	cXML += '								</MenuItem>' + CRLF
	cXML += '								<MenuItem Status="Enable">' + CRLF
	cXML += '									<Title lang="pt">Autorização de Serviço</Title>' + CRLF
	cXML += '									<Title lang="es">Autorización de Servicio</Title>' + CRLF
	cXML += '									<Title lang="en">Service Authorization</Title>' + CRLF
	cXML += '									<Function>LOCR018</Function>' + CRLF
	cXML += '									<Type>1</Type>' + CRLF
	cXML += '									<Access>xxxxxxxxxx</Access>' + CRLF
	cXML += '									<Module>94</Module>' + CRLF
	cXML += '									<Owner>94</Owner>' + CRLF
	cXML += '									<ItemID>0000017777</ItemID>' + CRLF
	cXML += '									<KeyWord>' + CRLF
	cXML += '										<KeyWord lang="pt">Autorizacao de Servico</KeyWord>' + CRLF
	cXML += '										<KeyWord lang="es">Autorización de Servicio</KeyWord>' + CRLF
	cXML += '										<KeyWord lang="en">Service Authorization</KeyWord>' + CRLF
	cXML += '									</KeyWord>' + CRLF
	cXML += '								</MenuItem>' + CRLF
	cXML += '								<MenuItem Status="Enable">' + CRLF
	cXML += '									<Title lang="pt">Carteira de Clientes</Title>' + CRLF
	cXML += '									<Title lang="es">Cartera de Clientes</Title>' + CRLF
	cXML += '									<Title lang="en">Customer Portfolio</Title>' + CRLF
	cXML += '									<Function>LOCR033</Function>' + CRLF
	cXML += '									<Type>1</Type>' + CRLF
	cXML += '									<Access>xxxxxxxxxx</Access>' + CRLF
	cXML += '									<Module>94</Module>' + CRLF
	cXML += '									<Owner>94</Owner>' + CRLF
	cXML += '									<ItemID>0000017781</ItemID>' + CRLF
	cXML += '									<KeyWord>' + CRLF
	cXML += '										<KeyWord lang="pt">Carteira de Clientes</KeyWord>' + CRLF
	cXML += '										<KeyWord lang="es">Cartera de Clientes</KeyWord>' + CRLF
	cXML += '										<KeyWord lang="en">Customers Portfolio</KeyWord>' + CRLF
	cXML += '									</KeyWord>' + CRLF
	cXML += '								</MenuItem>' + CRLF
	cXML += '								<MenuItem Status="Enable">' + CRLF
	cXML += '									<Title lang="pt">Previsão de Faturamento</Title>' + CRLF
	cXML += '									<Title lang="es">Prev. Facturación</Title>' + CRLF
	cXML += '									<Title lang="en">Invoicing Estimation</Title>' + CRLF
	cXML += '									<Function>LOCR039</Function>' + CRLF
	cXML += '									<Type>1</Type>' + CRLF
	cXML += '									<Access>xxxxxxxxxx</Access>' + CRLF
	cXML += '									<Module>94</Module>' + CRLF
	cXML += '									<Owner>0</Owner>' + CRLF
	cXML += '									<ItemID>0000022570</ItemID>' + CRLF
	cXML += '									<KeyWord>' + CRLF
	cXML += '										<KeyWord lang="pt">Previsao de Faturamento</KeyWord>' + CRLF
	cXML += '										<KeyWord lang="es">Previsión de Facturación</KeyWord>' + CRLF
	cXML += '										<KeyWord lang="en">Invoicing Estimation</KeyWord>' + CRLF
	cXML += '									</KeyWord>' + CRLF
	cXML += '								</MenuItem>' + CRLF
	cXML += '								<MenuItem Status="Enable">' + CRLF
	cXML += '									<Title lang="pt">Faturamento Sintetico</Title>' + CRLF
	cXML += '									<Title lang="es">Facturación Sintética</Title>' + CRLF
	cXML += '									<Title lang="en">Summary Invoicing</Title>' + CRLF
	cXML += '									<Function>LOCR040</Function>' + CRLF
	cXML += '									<Type>1</Type>' + CRLF
	cXML += '									<Access>xxxxxxxxxx</Access>' + CRLF
	cXML += '									<Module>94</Module>' + CRLF
	cXML += '									<Owner>94</Owner>' + CRLF
	cXML += '									<ItemID>0000022145</ItemID>' + CRLF
	cXML += '									<KeyWord>' + CRLF
	cXML += '										<KeyWord lang="pt">Sintetico</KeyWord>' + CRLF
	cXML += '										<KeyWord lang="es">Sintético</KeyWord>' + CRLF
	cXML += '										<KeyWord lang="en">Summary</KeyWord>' + CRLF
	cXML += '									</KeyWord>' + CRLF
	cXML += '								</MenuItem>' + CRLF
	cXML += '								<MenuItem Status="Enable">' + CRLF
	cXML += '									<Title lang="pt">Faturamento Analitico</Title>' + CRLF
	cXML += '									<Title lang="es">Facturación Analítica</Title>' + CRLF
	cXML += '									<Title lang="en">Detailed Invoicing</Title>' + CRLF
	cXML += '									<Function>LOCR041</Function>' + CRLF
	cXML += '									<Type>1</Type>' + CRLF
	cXML += '									<Access>xxxxxxxxxx</Access>' + CRLF
	cXML += '									<Module>94</Module>' + CRLF
	cXML += '									<Owner>0</Owner>' + CRLF
	cXML += '									<ItemID>0000022152</ItemID>' + CRLF
	cXML += '									<KeyWord>' + CRLF
	cXML += '										<KeyWord lang="pt"> </KeyWord>' + CRLF
	cXML += '										<KeyWord lang="es"> </KeyWord>' + CRLF
	cXML += '										<KeyWord lang="en"> </KeyWord>' + CRLF
	cXML += '									</KeyWord>' + CRLF
	cXML += '								</MenuItem>' + CRLF
	cXML += '								<MenuItem Status="Enable">' + CRLF
	cXML += '									<Title lang="pt">Historico do Contrato</Title>' + CRLF
	cXML += '									<Title lang="es">Historial Del Contrato</Title>' + CRLF
	cXML += '									<Title lang="en">Contract History</Title>' + CRLF
	cXML += '									<Function>LOCR042</Function>' + CRLF
	cXML += '									<Type>1</Type>' + CRLF
	cXML += '									<Access>xxxxxxxxxx</Access>' + CRLF
	cXML += '									<Module>94</Module>' + CRLF
	cXML += '									<Owner>0</Owner>' + CRLF
	cXML += '									<ItemID>0000022154</ItemID>' + CRLF
	cXML += '									<KeyWord>' + CRLF
	cXML += '										<KeyWord lang="pt"> </KeyWord>' + CRLF
	cXML += '										<KeyWord lang="es"> </KeyWord>' + CRLF
	cXML += '										<KeyWord lang="en"> </KeyWord>' + CRLF
	cXML += '									</KeyWord>' + CRLF
	cXML += '								</MenuItem>' + CRLF
	cXML += '								<MenuItem Status="Enable">' + CRLF
	cXML += '									<Title lang="pt">Projetos</Title>' + CRLF
	cXML += '									<Title lang="es">Proyectos</Title>' + CRLF
	cXML += '									<Title lang="en">Projects</Title>' + CRLF
	cXML += '									<Function>LOCR022</Function>' + CRLF
	cXML += '									<Type>1</Type>' + CRLF
	cXML += '									<Access>xxxxxxxxxx</Access>' + CRLF
	cXML += '									<Module>94</Module>' + CRLF
	cXML += '									<Owner>94</Owner>' + CRLF
	cXML += '									<ItemID>0000017783</ItemID>' + CRLF
	cXML += '									<KeyWord>' + CRLF
	cXML += '										<KeyWord lang="pt">Projetos</KeyWord>' + CRLF
	cXML += '										<KeyWord lang="es">Proyectos</KeyWord>' + CRLF
	cXML += '										<KeyWord lang="en">Projects</KeyWord>' + CRLF
	cXML += '									</KeyWord>' + CRLF
	cXML += '								</MenuItem>' + CRLF
	cXML += '								<MenuItem Status="Enable">' + CRLF
	cXML += '									<Title lang="pt">Vendas</Title>' + CRLF
	cXML += '									<Title lang="es">Ventas</Title>' + CRLF
	cXML += '									<Title lang="en">Sales</Title>' + CRLF
	cXML += '									<Function>LOCR025</Function>' + CRLF
	cXML += '									<Type>1</Type>' + CRLF
	cXML += '									<Access>xxxxxxxxxx</Access>' + CRLF
	cXML += '									<Module>94</Module>' + CRLF
	cXML += '									<Owner>94</Owner>' + CRLF
	cXML += '									<ItemID>0000017784</ItemID>' + CRLF
	cXML += '									<KeyWord>' + CRLF
	cXML += '										<KeyWord lang="pt">Vendas</KeyWord>' + CRLF
	cXML += '										<KeyWord lang="es">Ventas</KeyWord>' + CRLF
	cXML += '										<KeyWord lang="en">Sales</KeyWord>' + CRLF
	cXML += '									</KeyWord>' + CRLF
	cXML += '								</MenuItem>' + CRLF
	cXML += '								<MenuItem Status="Enable">' + CRLF
	cXML += '									<Title lang="pt">Imprime Fatura</Title>' + CRLF
	cXML += '									<Title lang="es">Imprime Factura</Title>' + CRLF
	cXML += '									<Title lang="en">Print Invoice</Title>' + CRLF
	cXML += '									<Function>LOCR003</Function>' + CRLF
	cXML += '									<Type>1</Type>' + CRLF
	cXML += '									<Access>xxxxxxxxxx</Access>' + CRLF
	cXML += '									<Module>94</Module>' + CRLF
	cXML += '									<Owner>0</Owner>' + CRLF
	cXML += '									<ItemID>0000017353</ItemID>' + CRLF
	cXML += '									<KeyWord>' + CRLF
	cXML += '										<KeyWord lang="pt"> </KeyWord>' + CRLF
	cXML += '										<KeyWord lang="es"> </KeyWord>' + CRLF
	cXML += '										<KeyWord lang="en"> </KeyWord>' + CRLF
	cXML += '									</KeyWord>' + CRLF
	cXML += '								</MenuItem>' + CRLF
	cXML += '								<MenuItem Status="Enable">' + CRLF
	cXML += '									<Title lang="pt">Pré Faturamento</Title>' + CRLF
	cXML += '									<Title lang="es">Facturación Previa</Title>' + CRLF
	cXML += '									<Title lang="en">Pre-billing</Title>' + CRLF
	cXML += '									<Function>LOCR038</Function>' + CRLF
	cXML += '									<Type>1</Type>' + CRLF
	cXML += '									<Access>xxxxxxxxxx</Access>' + CRLF
	cXML += '									<Module>94</Module>' + CRLF
	cXML += '									<Owner>0</Owner>' + CRLF
	cXML += '									<ItemID>0000018305</ItemID>' + CRLF
	cXML += '									<KeyWord>' + CRLF
	cXML += '										<KeyWord lang="pt"> </KeyWord>' + CRLF
	cXML += '										<KeyWord lang="es"> </KeyWord>' + CRLF
	cXML += '										<KeyWord lang="en"> </KeyWord>' + CRLF
	cXML += '									</KeyWord>' + CRLF
	cXML += '								</MenuItem>' + CRLF
	cXML += '								<MenuItem Status="Enable">' + CRLF
	cXML += '									<Title lang="pt">Medição Analítico</Title>' + CRLF
	cXML += '									<Title lang="es">Medición Analítico</Title>' + CRLF
	cXML += '									<Title lang="en">Detailed Measurem.</Title>' + CRLF
	cXML += '									<Function>LOCR072</Function>' + CRLF
	cXML += '									<Type>1</Type>' + CRLF
	cXML += '									<Access>xxxxxxxxxx</Access>' + CRLF
	cXML += '									<Module>94</Module>' + CRLF
	cXML += '									<Owner>94</Owner>' + CRLF
	cXML += '									<ItemID>0000017262</ItemID>' + CRLF
	cXML += '									<KeyWord>' + CRLF
	cXML += '										<KeyWord lang="pt">Medicao</KeyWord>' + CRLF
	cXML += '										<KeyWord lang="es">Medición</KeyWord>' + CRLF
	cXML += '										<KeyWord lang="en">Measurement</KeyWord>' + CRLF
	cXML += '									</KeyWord>' + CRLF
	cXML += '								</MenuItem>' + CRLF
	cXML += '							</Menu>' + CRLF
	If (nTamanho == 3)
		cXML += '							<Menu Status="Enable">' + CRLF
		cXML += '								<Title lang="pt">Mao de Obraa</Title>' + CRLF
		cXML += '								<Title lang="es">Mano de Obra</Title>' + CRLF
		cXML += '								<Title lang="en">Workforce</Title>' + CRLF
		cXML += '								<ItemID>0000017259</ItemID>' + CRLF
		cXML += '								<MenuItem Status="Enable">' + CRLF
		cXML += '									<Title lang="pt">Disp. Mo</Title>' + CRLF
		cXML += '									<Title lang="es">Disp. Mo</Title>' + CRLF
		cXML += '									<Title lang="en">Labor Av.</Title>' + CRLF
		cXML += '									<Function>LOCR006</Function>' + CRLF
		cXML += '									<Type>1</Type>' + CRLF
		cXML += '									<Access>xxxxxxxxxx</Access>' + CRLF
		cXML += '									<Module>94</Module>' + CRLF
		cXML += '									<Owner>94</Owner>' + CRLF
		cXML += '									<ItemID>0000017271</ItemID>' + CRLF
		cXML += '									<KeyWord>' + CRLF
		cXML += '										<KeyWord lang="pt">Disponibilidade de Mo</KeyWord>' + CRLF
		cXML += '										<KeyWord lang="es">Disponibilidad de Mo</KeyWord>' + CRLF
		cXML += '										<KeyWord lang="en">Mo Availability</KeyWord>' + CRLF
		cXML += '									</KeyWord>' + CRLF
		cXML += '								</MenuItem>' + CRLF
		cXML += '								<MenuItem Status="Enable">' + CRLF
		cXML += '									<Title lang="pt">Divergências Time Sheet</Title>' + CRLF
		cXML += '									<Title lang="es">Divergencias Time Sheet</Title>' + CRLF
		cXML += '									<Title lang="en">Time Sheet Differences</Title>' + CRLF
		cXML += '									<Function>LOCR023</Function>' + CRLF
		cXML += '									<Type>1</Type>' + CRLF
		cXML += '									<Access>xxxxxxxxxx</Access>' + CRLF
		cXML += '									<Module>94</Module>' + CRLF
		cXML += '									<Owner>94</Owner>' + CRLF
		cXML += '									<ItemID>0000017273</ItemID>' + CRLF
		cXML += '									<KeyWord>' + CRLF
		cXML += '										<KeyWord lang="pt">Divergencia de Time Sheet</KeyWord>' + CRLF
		cXML += '										<KeyWord lang="es">Divergencia de Time Sheet</KeyWord>' + CRLF
		cXML += '										<KeyWord lang="en">Timesheet Divergence</KeyWord>' + CRLF
		cXML += '									</KeyWord>' + CRLF
		cXML += '								</MenuItem>' + CRLF
		cXML += '								<MenuItem Status="Enable">' + CRLF
		cXML += '									<Title lang="pt">Integração Por Obra</Title>' + CRLF
		cXML += '									<Title lang="es">Integración Por Obra</Title>' + CRLF
		cXML += '									<Title lang="en">Integration By Work</Title>' + CRLF
		cXML += '									<Function>LOCR001</Function>' + CRLF
		cXML += '									<Type>1</Type>' + CRLF
		cXML += '									<Access>xxxxxxxxxx</Access>' + CRLF
		cXML += '									<Module>94</Module>' + CRLF
		cXML += '									<Owner>94</Owner>' + CRLF
		cXML += '									<ItemID>0000017274</ItemID>' + CRLF
		cXML += '									<KeyWord>' + CRLF
		cXML += '										<KeyWord lang="pt"> </KeyWord>' + CRLF
		cXML += '										<KeyWord lang="es"> </KeyWord>' + CRLF
		cXML += '										<KeyWord lang="en"> </KeyWord>' + CRLF
		cXML += '									</KeyWord>' + CRLF
		cXML += '								</MenuItem>' + CRLF
		cXML += '								<MenuItem Status="Enable">' + CRLF
		cXML += '									<Title lang="pt">Planilha de Alocacao</Title>' + CRLF
		cXML += '									<Title lang="es">Planilla de Asignación</Title>' + CRLF
		cXML += '									<Title lang="en">Allocation Spreadsheet</Title>' + CRLF
		cXML += '									<Function>LOCR024</Function>' + CRLF
		cXML += '									<Type>1</Type>' + CRLF
		cXML += '									<Access>xxxxxxxxxx</Access>' + CRLF
		cXML += '									<Module>94</Module>' + CRLF
		cXML += '									<Owner>94</Owner>' + CRLF
		cXML += '									<ItemID>0000017279</ItemID>' + CRLF
		cXML += '									<KeyWord>' + CRLF
		cXML += '										<KeyWord lang="pt"> </KeyWord>' + CRLF
		cXML += '										<KeyWord lang="es"> </KeyWord>' + CRLF
		cXML += '										<KeyWord lang="en"> </KeyWord>' + CRLF
		cXML += '									</KeyWord>' + CRLF
		cXML += '								</MenuItem>' + CRLF
		cXML += '								<MenuItem Status="Enable">' + CRLF
		cXML += '									<Title lang="pt">Relatório Time Sheet</Title>' + CRLF
		cXML += '									<Title lang="es">Inf. Time Sheet</Title>' + CRLF
		cXML += '									<Title lang="en">Time Sheet Report</Title>' + CRLF
		cXML += '									<Function>LOCR021</Function>' + CRLF
		cXML += '									<Type>1</Type>' + CRLF
		cXML += '									<Access>xxxxxxxxxx</Access>' + CRLF
		cXML += '									<Module>94</Module>' + CRLF
		cXML += '									<Owner>94</Owner>' + CRLF
		cXML += '									<ItemID>0000017285</ItemID>' + CRLF
		cXML += '									<KeyWord>' + CRLF
		cXML += '										<KeyWord lang="pt"> </KeyWord>' + CRLF
		cXML += '										<KeyWord lang="es"> </KeyWord>' + CRLF
		cXML += '										<KeyWord lang="en"> </KeyWord>' + CRLF
		cXML += '									</KeyWord>' + CRLF
		cXML += '								</MenuItem>' + CRLF
		cXML += '							</Menu>' + CRLF
	EndIf
	cXML += '							<Menu Status="Enable">' + CRLF
	cXML += '								<Title lang="pt">Equipamentos</Title>' + CRLF
	cXML += '								<Title lang="es">Equipamientos</Title>' + CRLF
	cXML += '								<Title lang="en">Equipment</Title>' + CRLF
	cXML += '								<ItemID>0000017287</ItemID>' + CRLF
	cXML += '								<MenuItem Status="Enable">' + CRLF
	cXML += '									<Title lang="pt">Disp. Frota Mod2</Title>' + CRLF
	cXML += '									<Title lang="es">Disp. Flota Mod2</Title>' + CRLF
	cXML += '									<Title lang="en">Fleet Av. Templ2</Title>' + CRLF
	cXML += '									<Function>LOCR005</Function>' + CRLF
	cXML += '									<Type>1</Type>' + CRLF
	cXML += '									<Access>xxxxxxxxxx</Access>' + CRLF
	cXML += '									<Module>94</Module>' + CRLF
	cXML += '									<Owner>94</Owner>' + CRLF
	cXML += '									<ItemID>0000017289</ItemID>' + CRLF
	cXML += '									<KeyWord>' + CRLF
	cXML += '										<KeyWord lang="pt"> </KeyWord>' + CRLF
	cXML += '										<KeyWord lang="es"> </KeyWord>' + CRLF
	cXML += '										<KeyWord lang="en"> </KeyWord>' + CRLF
	cXML += '									</KeyWord>' + CRLF
	cXML += '								</MenuItem>' + CRLF
	cXML += '								<MenuItem Status="Enable">' + CRLF
	cXML += '									<Title lang="pt">Relatório de Avarias</Title>' + CRLF
	cXML += '									<Title lang="es">Informe de Averías</Title>' + CRLF
	cXML += '									<Title lang="en">Damages Report</Title>' + CRLF
	cXML += '									<Function>LOCR037</Function>' + CRLF
	cXML += '									<Type>1</Type>' + CRLF
	cXML += '									<Access>xxxxxxxxxx</Access>' + CRLF
	cXML += '									<Module>94</Module>' + CRLF
	cXML += '									<Owner>0</Owner>' + CRLF
	cXML += '									<ItemID>0000018307</ItemID>' + CRLF
	cXML += '									<KeyWord>' + CRLF
	cXML += '										<KeyWord lang="pt"> </KeyWord>' + CRLF
	cXML += '										<KeyWord lang="es"> </KeyWord>' + CRLF
	cXML += '										<KeyWord lang="en"> </KeyWord>' + CRLF
	cXML += '									</KeyWord>' + CRLF
	cXML += '								</MenuItem>' + CRLF
	cXML += '							</Menu>' + CRLF
	cXML += '						</Menu>' + CRLF

	cXML += '							<Menu Status="Enable">' + CRLF
	cXML += '								<Title lang="pt">&Miscelanea</Title>' + CRLF
	cXML += '								<Title lang="es">&Miscelanea</Title>' + CRLF
	cXML += '								<Title lang="en">&Miscellaneous</Title>' + CRLF
	cXML += '								<ItemID>A940000004</ItemID>' + CRLF
	cXML += '									<MenuItem Status="Enable">' + CRLF
	cXML += '										<Title lang="pt">Contestação de Multas (portal)</Title>' + CRLF
	cXML += '										<Title lang="es">Contest. Multas (portal)</Title>' + CRLF
	cXML += '										<Title lang="en">Disputation Of Fines (portal)</Title>' + CRLF
	cXML += '										<Function>LOCA097</Function>' + CRLF
	cXML += '										<Type>1</Type>' + CRLF
	cXML += '										<Tables>TRX</Tables>' + CRLF
	cXML += '										<Access>xxxxxxxxxx</Access>' + CRLF
	cXML += '										<Module>94</Module>' + CRLF
	cXML += '										<Owner>94</Owner>' + CRLF
	cXML += '										<ItemID>0000022829</ItemID>' + CRLF
	cXML += '										<KeyWord>' + CRLF
	cXML += '											<KeyWord lang="pt">Contestação de Multas</KeyWord>' + CRLF
	cXML += '											<KeyWord lang="es">Contestación de Multas</KeyWord>' + CRLF
	cXML += '											<KeyWord lang="en">Disputation Of Fines</KeyWord>' + CRLF
	cXML += '										</KeyWord>' + CRLF
	cXML += '									</MenuItem>' + CRLF
	cXML += '							</Menu>' + CRLF
	cXML += '							<Menu>' + CRLF
	cXML += '								<Menu Status="Disable">' + CRLF
	cXML += '									<Title lang="pt">Palavras Reservadas</Title>' + CRLF
	cXML += '									<Title lang="es">Palabras Reservadas</Title>' + CRLF
	cXML += '									<Title lang="en">Reserved Words</Title>' + CRLF
	cXML += '									<ItemID>B940000001</ItemID>' + CRLF
	cXML += '									<MenuItem Status="Disable">' + CRLF
	cXML += '										<Title lang="pt">Palavras Reservadas</Title>' + CRLF
	cXML += '										<Title lang="es">Palabras Reservadas</Title>' + CRLF
	cXML += '										<Title lang="en">Reserved Words</Title>' + CRLF
	cXML += '										<Function></Function>' + CRLF
	cXML += '										<Type>1</Type>' + CRLF
	cXML += '										<Tables></Tables>' + CRLF
	cXML += '										<Access>xxxxxxxxxx</Access>' + CRLF
	cXML += '										<Module>01</Module>' + CRLF
	cXML += '										<Owner>0</Owner>' + CRLF
	cXML += '										<ItemID>B940000002</ItemID>' + CRLF
	cXML += '										<ReservedWords>' + CRLF
	cXML += '											<Words "SPA E"></Words>' + CRLF
	cXML += '											<Words "ENG I"></Words>' + CRLF
	cXML += '											<Words "POR T"></Words>' + CRLF
	cXML += '											<Words "POR P"></Words>' + CRLF
	cXML += '											<Words "RUS R"></Words>' + CRLF
	cXML += '										</ReservedWords>' + CRLF
	cXML += '									</MenuItem>' + CRLF
	cXML += '								</Menu>' + CRLF
	cXML += '							</Menu>' + CRLF

    cXML += '</ApMenu>' + CRLF
    
    // Grava arquivo
    cComand  :=  "nHandle := FCreate(cArquivo)"
	&(cComand)
      
    FWrite(nHandle, cXML)
    FClose(nHandle)
    
    MsgInfo(STR0047 + CRLF + cArquivo, STR0046) //"Sucesso" //"Arquivo gerado com sucesso em: "
    oDlg:End()
    
Return
