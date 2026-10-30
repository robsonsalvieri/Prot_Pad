#INCLUDE "PROTHEUS.CH"
#INCLUDE 'FWMVCDEF.CH'

/*/{Protheus.ch} Function PLPTUCOMP
    Interface MVC para manutenção da tabela BQ9
/*/
Function PLPTUCOMP()
    Local oBrowse := FWMBrowse():New()    
    oBrowse:SetAlias("BQ9")
    oBrowse:SetDescription("Beneficiários Compartilhados")
    oBrowse:Activate()
Return NIL

Static Function MenuDef()
    Local aRotina := {}
    ADD OPTION aRotina TITLE 'Importar'   ACTION 'ImporBQ9()'          OPERATION 3 ACCESS 0 
    ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.PLPTUCOMP' OPERATION 2 ACCESS 0
Return aRotina

Static Function ModelDef()
    Local oModel := Nil
    Local oStruct := FWFormStruct(1, "BQ9") 
    oModel := MPFormModel():New("BQ9MODEL")
    oModel:AddFields("BQ9MASTER", Nil, oStruct)
    oModel:SetDescription("Beneficiários Compartilhados")    
    oModel:GetModel("BQ9MASTER"):SetPrimaryKey({"BQ9_FILIAL","BQ9_BENEFI","BQ9_BENCOM"})
Return oModel

Static Function ViewDef()
    Local oView := Nil
    Local oModel := FWLoadModel("PLPTUCOMP")
    Local oStruct := FWFormStruct(2, "BQ9") 
    oStruct:RemoveField("BQ9_FILIAL") 
    oView := FWFormView():New()
    oView:SetModel(oModel)
    oView:AddField("VIEW_BQ9", oStruct, "BQ9MASTER")    
    oView:CreateHorizontalBox("TELA_TODA", 100)
    oView:SetOwnerView("VIEW_BQ9", "TELA_TODA")
Return oView

/*/{Protheus.doc} ImporBQ9
Chama o processo de importação com régua
/*/
Function ImporBQ9()
    Local cFileSel := cGetFile("Arquivos CSV|*.csv", "Selecione o arquivo para importação", , , .F.)
    local lEnd     := .f.
	Local oProcess 	:= nil

    If Empty(cFileSel)
        MsgStop("Operação cancelada pelo usuário.")
        Return
    EndIf

    // Cria o processo com a régua de processamento
    oProcess :=MsNewProcess():New({|lEnd| ExecImpor(lEnd, cFileSel,oProcess)}, "Importando CSV", "Lendo arquivo, aguarde...", .T.)
 	oProcess:Activate()

Return

/*/{Protheus.doc} ExecImpor
Função interna que executa a leitura e gravação com atualização da régua
/*/
Function ExecImpor(lEnd, cFileSel,oProcess)
    Local oReader
    Local aLine    := {}
    Local aAux     := Array(2)
    Local nCont    := 0
    Local nImport  := 0
    Local cLine    := ""

    oReader := FWFileReader():New(cFileSel)
    
    If oReader:Open()   
        While oReader:HasLine()
            cLine := oReader:GetLine()
            nCont++
            
 			oProcess:IncRegua1("Processando registros ["+cValToChar(nCont)+"] ")
           
            // Pula o cabeçalho e limpa a tabela
            If nCont == 1
                TCSqlExec("DELETE FROM " + RetSqlName('BQ9') + " WHERE BQ9_FILIAL= '"+xFilial('BQ9')+"' AND D_E_L_E_T_ = ' '")
                Loop
            EndIf

            aLine := StrTokArr(cLine, ";")

            IIF(len(aline)>2,MSGINFO("Favor ajustar o arquivo importado de acordo com a documentação!!"),"")

            If len(aLine)==1
                aAux[1]:=StrTran(aLine[1],";","")
                aAux[2]:=PADR("",tamSX3("BQ9_BENEFI")[1])
                aLine:=aAux
            endif

            If Len(aLine) >= 1 .And. !BQ9->(dbSeek(xFilial("BQ9")+aLine[1]+aLine[2]))
                RecLock("BQ9", .T.)
                BQ9->BQ9_FILIAL  := xFilial("BQ9")
                BQ9->BQ9_BENEFI  := iif(len(aLine)>1,aLine[1],"")
                BQ9->BQ9_BENCOM  := iif(len(aLine)>1,aLine[2],"")
                BQ9->(MsUnlock())
                nImport++
            EndIf
        EndDo

        oReader:Close()
        MsgInfo("Importação concluída!" + CRLF + "Total de registros: " + cValToChar(nCont-1)+""+CRLF+"Total de Reg.Importados: "+cvaltochar(nImport)+".")
    Else
        MsgStop("Não foi possível abrir o arquivo.")
    EndIf

Return
