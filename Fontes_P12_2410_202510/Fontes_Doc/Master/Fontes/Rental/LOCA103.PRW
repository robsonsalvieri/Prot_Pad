#Include "TOTVS.ch"
#Include "TopConn.ch"
#Include "LOCA103.CH"
#include 'parmtype.ch'
#Include 'MsOle.CH'
#Include "TbiConn.ch"
  
Static nPosProjet := 1 //Coluna A no Excel
Static nPosProdut := 2 //Coluna B no Excel
Static nPosContad := 3 //Coluna C no Excel
Static nPosCodFam := 4 //Coluna E no Excel
Static nPosTipMod := 5 //Coluna E no Excel
Static nPosTipCob := 6 //Coluna F no Excel
  
/*/{Protheus.doc} LOCA103
Função para importar MTBF via csv
@author DENNIS CALABREZ
@since 22/07/2025
@version 1.0
@type function
/*/
  
Function LOCA103()
Local cTitulo	:= "Importador do MTBF"
Local cMsg1     := "Esta rotina foi desenvolvida para facilitar a geração e leitura de arquivos do tipo CSV. O que deseja realizar?"
Local cBtn1		:= "Gerar CSV"
Local cBtn2		:= "Atualizar Itens"
Local nRetFunc	:= 0

    nRetFunc := AVISO(cTitulo, cMsg1, { cBtn1,cBtn2,"Fechar"}, 2)

    If nRetFunc == 1
        LOCA103AY()
    ElseIf nRetFunc == 2
        LOCA103AX()
    EndIf

Return

Function LOCA103AY
Local cStr0010	:= STR0022 //'Informe o Local para gravar o arquivo'
Local cMvLocx306:= SuperGetMV("MV_LOCX306",.F.,"")
Local xGet1 	:= GETF_LOCALHARD //manter, pois é macro executado em cDirDest
Local xGet2 	:= GETF_LOCALFLOPPY //manter, pois é macro executado em cDirDest
Local xGet3 	:= GETF_RETDIRECTORY //manter, pois é macro executado em cDirDest
Local cDirDest	:= &("cGetFile( '.' , cStr0010, 1, cMvLocx306, .F., nOR( xGet1, xGet2, xGet3 ),.T., .T. )")
Local nHandle
Local cReturn

    cStr0010 := ""
    cMvLocx306 := ""
    xGet1 := ""
    xGet2 := ""
    xGet3 := ""

    If !Empty(cDirDest)
        nHandle := &('FCREATE(cDirDest + "\" + "mtbf-modelo.csv")')
        If nHandle > 0
            cReturn := "202500467;000000000000000000000000001LOC;1;FAM01;1234;1"  + CRLF
            cReturn += STR0023 + CRLF //"Explicacao das colunas"
            cReturn += "202500467 = "+STR0024 + CRLF //"codigo do projeto"
            cReturn += "000000000000000000000000001LOC = "+ STR0025 + CRLF //"codigo do produto (nao pode repetir)"
            cReturn += "1 = "+STR0026 + CRLF //"posicao do contador"
            cReturn += "FAM01 = "+STR0027 + CRLF //"codigo da familia"
            cReturn += "1234 = "+STR0028 + CRLF //"codigo do tipo de modelo"
            cReturn += "1 = "+STR0029 + CRLF //"Tipo da cobranca sendo 1 para Proporcional e 2 para Integral"
            FWrite(nHandle, cReturn)
            FClose(nHandle)

            FWAlertSuccess(STR0030,STR0031) //"Arquivo modelo gerado com sucesso."###"Migrador do MTBF."

        EndIf
    EndIf

Return

Function LOCA103AX
Local aArea     := GetArea()
Private cArqOri := ""
  
    //Mostra o Prompt para selecionar arquivos
    cArqOri := tFileDialog( "CSV files (*.csv) ", STR0001, , , .F., ) //'Seleção de Arquivos'
      
    //Se tiver o arquivo de origem
    If ! Empty(cArqOri)
          
        //Somente se existir o arquivo e for com a extensão CSV
        If File(cArqOri) .And. Upper(SubStr(cArqOri, RAt('.', cArqOri) + 1, 3)) == 'CSV'
            Processa({|| LOCA103A() }, STR0002) //"Importando..."
        EndIf
    EndIf
      
    RestArea(aArea)
Return
  
/*-------------------------------------------------------------------------------*
 | Func:  LOCA103A                                                               |
 | Desc:  Função que importa os dados                                            |
 *-------------------------------------------------------------------------------*/
  
Static Function LOCA103A()
Local aArea      := GetArea()
Local cArqLog    := "LOCA103A_" + dToS(Date()) + "_" + StrTran(Time(), ':', '-') + ".log"
Local nTotLinhas := 0
Local cLinAtu    := ""
Local nLinhaAtu  := 0
Local aLinha     := {}
Local oArquivo
Local aLinhas
Local cProjet    := ""
Local cCodProd   := ""
Local cPosCon    := ""
Local cCodFam    := ""
Local cTipMod    := ""
Local cTipCob    := ""
Private cDirLog    := "C:\IMPOR_MTBF\"//GetTempPath() + "x_importacao\"
Private cLog       := ""
      
    //Se a pasta de log não existir, cria ela
    If ! ExistDir(cDirLog)
        MakeDir(cDirLog)
    EndIf
  
    //Definindo o arquivo a ser lido
    oArquivo := FWFileReader():New(cArqOri)
      
    //Se o arquivo pode ser aberto
    If (oArquivo:Open())
  
        //Se não for fim do arquivo
        If ! (oArquivo:EoF())
  
            //Definindo o tamanho da régua
            aLinhas := oArquivo:GetAllLines()
            nTotLinhas := Len(aLinhas)
            ProcRegua(nTotLinhas)
              
            //Método GoTop não funciona (dependendo da versão da LIB), deve fechar e abrir novamente o arquivo
            oArquivo:Close()
            oArquivo := FWFileReader():New(cArqOri)
            oArquivo:Open()
  
            //Enquanto tiver linhas
            While (oArquivo:HasLine())
  
                //Incrementa na tela a mensagem
                nLinhaAtu++
                IncProc(STR0003 + cValToChar(nLinhaAtu) + STR0004 + cValToChar(nTotLinhas) + "...") //"Analisando linha "###" de "
                  
                //Pegando a linha atual e transformando em array
                cLinAtu := oArquivo:GetLine()
                aLinha  := StrTokArr(cLinAtu, ";")
  
                //Zera as variaveis
                cProjet  := aLinha[nPosProjet]
                cCodProd := aLinha[nPosProdut]
                cPosCon  := aLinha[nPosContad]
                cCodFam  := aLinha[nPosCodFam]
                cTipMod  := aLinha[nPosTipMod]
                cTipCob  := aLinha[nPosTipCob]

                DbSelectArea('FH0')
                FH0->(DbSetOrder(1))
  
                DbSelectArea('SB1')
                SB1->(DbSetOrder(1))
                If SB1->(DbSeek(FWxFilial('SB1') + cCodProd))//verifica se existe o produto informado no csv
                    DbSelectArea("FP0")
                    FP0->(DbSetOrder(1))
                    If FP0->(DbSeek(FWxFilial('FP0') + cProjet))//verifica se existe o projeto informado no csv
                        DbSelectArea("ST6")
                        ST6->(DbSetOrder(1))
                        If ST6->(DbSeek(FWxFilial('ST6') + cCodFam))//verifica se existe a familia informado no csv
                            DbSelectArea("TQR")
                            TQR->(DbSetOrder(1))
                            If TQR->(DbSeek(FWxFilial('TQR') + cTipMod))//verifica se existe o tipo modelo informado no csv
                                cLog += STR0005 + cValToChar(nLinhaAtu) + STR0006 + cProjet + " - " + cCodProd  + "] " +; //"+ Lin"###", projeto/produto ["
                                STR0007 + cPosCon + STR0008 + Alltrim(cTipCob) + "];" + CRLF //"contador: ["###"], tipo cobraça: ["                               
                                RecLock('FH0', .T.)
                                FH0->FH0_FILIAL := xFilial("FH0")
                                FH0->FH0_PROJET := cProjet
                                FH0->FH0_CODPRO := cCodProd
                                FH0->FH0_DESPRO := Posicione("SB1",1,xFilial("SB1")+cCodProd,"B1_DESC")
                                FH0->FH0_POSCON := val(cPosCon)
                                FH0->FH0_CODFAM := cCodFam
                                FH0->FH0_NOMFAM := Posicione("ST6",1,xFilial("ST6")+cCodFam,"T6_NOME")
                                FH0->FH0_TIPMOD := cTipMod
                                FH0->FH0_DESMOD := Posicione("TQR",1,xFilial("TQR")+cTipMod,"TQR_DESMOD")
                                FH0->FH0_TIPCOB := cTipCob
                                FH0->(MsUnlock())
                            Else
                                cLog += STR0009 + cValToChar(nLinhaAtu) + STR0010 + cTipMod + STR0011 + CRLF //"- Lin"###", Tipo Modelo ["###"] não encontrada no Protheus;"
                            EndIf 
                        Else
                            cLog += STR0009 + cValToChar(nLinhaAtu) + STR0012 + cCodFam + STR0011 + CRLF //"- Lin"###", Familia ["###"] não encontrada no Protheus;"
                        EndIf        
                    Else
                        cLog += STR0009 + cValToChar(nLinhaAtu) + STR0014 + cProjet + STR0011 + CRLF //"- Lin"###", Projeto ["###"] não encontrado no Protheus;"
                    EndIf    

                Else
                    cLog += STR0009 + cValToChar(nLinhaAtu) + STR0016 + cCodProd + STR0011 + CRLF //"- Lin"###", Produto ["###"] não encontrado no Protheus;"
                EndIf 
            EndDo
  
            //Se tiver log, mostra ele
            If ! Empty(cLog)
                cLog := STR0017+ CRLF + cLog //"Processamento concluído. Para conferir os itens importados, feche a tela de MTBF e acesse novamente. Consulte abaixo o log de importação: " + CRLF + cLog
                &('MemoWrite(cDirLog + cArqLog, cLog)')
                ShellExecute("OPEN", cArqLog, "", cDirLog, 1)
            EndIf
  
        EndIf
  
        //Fecha o arquivo
        oArquivo:Close()

    EndIf
  
    RestArea(aArea)
Return
