VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Plan1"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = True
Sub extraiPlanoDeContas()
    'Verificar se as cores não mudaram na planilha da ANS com o comando ActiveCell.DisplayFormat.Interior.Color
    Const Branco As Double = 16777215
    Const Amarelo As Double = 10092543
    Const Vermelho As Double = 9737946
    Const planilhas As String = "ATIVO, PASSIVO, RECEITAS, DESPESAS"
    Const inicioRange As String = "A6"
    ' O fim do range foi determinado olhando o maior numero de linhas entre as 4 planilhas
    Const fimRange As String = "O2300"
        
    Dim i As Integer
    Dim CountRow As Integer
    Dim Conta As String
    Dim Descricao As String
    Dim PlanoContas As String
    Dim rng As Range
    Dim Current As Worksheet
    
    Set fs = CreateObject("Scripting.FileSystemObject")
    Set csv = fs.CreateTextFile("c:\temp\RN 435 - Plano de contas.csv", True)
    PlanoContas = ""
    For Each Current In Worksheets
        If InStr(1, planilhas, Current.Name, vbTextCompare) Then
            Application.ScreenUpdating = False
            'Seleciono a planilha
            Current.Select
            Set rng = Current.Range(inicioRange & ":" & fimRange)
            rng.Select
            CountRow = rng.EntireRow.Count
            'Percorro as linhas
            For i = 1 To CountRow
                Conta = ""
                Descricao = ""
                'Linhas em vermelho eu desconsidero, pois foram excluidas do plano de contas
                If ActiveCell.DisplayFormat.Interior.Color <> Vermelho Then
                    For j = 1 To 13
                        If ActiveCell.Text <> "" Then
                            Conta = Conta & ActiveCell.Text
                        End If
                        ActiveCell.Offset(0, 1).Select
                    Next j
                    Descricao = ActiveCell.Text
                    'Desconsidero linhas em branco também
                    If Conta <> "" Then
                        PlanoContas = PlanoContas & Conta & ";" & Descricao & Chr(13) & Chr(10)
                    End If
                    ActiveCell.Offset(1, -13).Select
                Else
                    ActiveCell.Offset(1, 0).Select
                End If
                
            Next i
        End If
    Next
    csv.WriteLine (PlanoContas)
    csv.Close
    Application.ScreenUpdating = True
End Sub

