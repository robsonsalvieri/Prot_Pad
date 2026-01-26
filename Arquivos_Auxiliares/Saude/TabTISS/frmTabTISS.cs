using System.ComponentModel;
using System.Data;
using System.Data.OleDb;
using System.Reflection;
using System.Text;
using System.Windows.Forms;
using static System.Runtime.InteropServices.JavaScript.JSType;
using static System.Windows.Forms.VisualStyles.VisualStyleElement;

namespace TabTISS
{
    public partial class frmTabTISS : Form
    {
        bool falha = false;        
        string[] prefixosRestritos = { "18", "19", "20", "22", "64" };

        public frmTabTISS()
        {
            InitializeComponent();
        }

        private void checkedListBox1_SelectedIndexChanged(object sender, EventArgs e)
        {


        }

        private void cmsTerminologias_Opening(object sender, System.ComponentModel.CancelEventArgs e)
        {

        }

        private void selecionarTodosToolStripMenuItem_Click(object sender, EventArgs e)
        {
            selecionarTodos(true);
        }

        private void selecionarTodos(bool selecao)
        {          
            // Iterar por todos os itens da CheckedListBox
            for (int i = 0; i < clbTerminologias.Items.Count; i++)
            {
                string itemTexto = clbTerminologias.Items[i].ToString();

                // Verificar se o item começa com algum dos prefixos restritos                
                bool ignorar = prefixosRestritos.Any(prefixo => itemTexto.StartsWith(prefixo));

                // Marcar ou desmarcar o item
                if (selecao)
                    clbTerminologias.SetItemChecked(i, !ignorar);
                else
                    clbTerminologias.SetItemChecked(i, false);
            }
        }

        private void desmarcarTodosToolStripMenuItem_Click(object sender, EventArgs e)
        {
            selecionarTodos(false);
        }

        private void btnIncluiExcel_Click(object sender, EventArgs e)
        {
            // Abrir diálogo para selecionar arquivo
            using (OpenFileDialog openFileDialog = new OpenFileDialog())
            {
                openFileDialog.Filter = "Arquivos Excel (*.xlsx;*.xls)|*.xlsx;*.xls";
                openFileDialog.Title = "Selecione um arquivo Excel";

                if (openFileDialog.ShowDialog() == DialogResult.OK)
                {
                    // Obter o caminho do arquivo
                    string filePath = openFileDialog.FileName;

                    // Adicionar o caminho ao ListBox
                    ltbExcel.Items.Add(filePath);
                }
            }
        }

        private void btnExcluiExcel_Click(object sender, EventArgs e)
        {
            // Verificar se há um item selecionado
            if (ltbExcel.SelectedItem != null)
            {
                // Remover o item selecionado
                ltbExcel.Items.Remove(ltbExcel.SelectedItem);
            }
            else
            {
                // Mostrar mensagem se nenhum item estiver selecionado
                MessageBox.Show("Por favor, selecione um item para remover.", "Atenção", MessageBoxButtons.OK, MessageBoxIcon.Warning);
            }
        }

        private void clbTerminologias_ItemCheck(object sender, ItemCheckEventArgs e)
        {
            // Verificar se algum item que começa com "64" já está marcado
            bool isChecked = false;
            int indexRestrito = -1;

            for (int i = 0; i < clbTerminologias.Items.Count; i++)
            {
                if (prefixosRestritos.Any(prefixo => clbTerminologias.Items[i].ToString().StartsWith(prefixo)))
                {
                    if (i == e.Index) // O item sendo modificado
                    {
                        isChecked = (e.NewValue == CheckState.Checked);
                        indexRestrito = i;
                    }
                    else if (clbTerminologias.GetItemChecked(i)) // Outros itens marcados
                    {
                        isChecked = true;
                        indexRestrito = i;
                    }
                    if (isChecked)
                        break;
                }
            }

            // Verificar se há outros itens marcados
            bool otherItemsChecked = indexRestrito != e.Index;
            if (!otherItemsChecked)
            {
                for (int i = 0; i < clbTerminologias.Items.Count; i++)
                {
                    if (i != indexRestrito && (i != e.Index || e.NewValue == CheckState.Checked) && clbTerminologias.GetItemChecked(i))
                    {
                        otherItemsChecked = true;
                        break;
                    }
                }
            }

            // Se o item restrito está marcado junto com outros itens, exibir mensagem
            if (isChecked && otherItemsChecked)
            {
                string msg = "";
                if (e.Index == indexRestrito)
                    msg = "A tabela " + clbTerminologias.Items[e.Index].ToString().Substring(0, 2) + " deve ser processada separadamente das demais tabelas. " +
                          "Deseja selecionar somente esta tabela?";
                else
                    msg = "A tabela " + clbTerminologias.Items[e.Index].ToString().Substring(0, 2) + " não pode ser processada junto com a tabela " +
                          clbTerminologias.Items[indexRestrito].ToString().Substring(0, 2) + ". Deseja desmarcar a tabela " +
                          clbTerminologias.Items[indexRestrito].ToString().Substring(0, 2) + "?";

                var result = MessageBox.Show(
                    msg,
                    "Confirmação",
                    MessageBoxButtons.YesNo,
                    MessageBoxIcon.Question
                );

                if (result == DialogResult.Yes)
                {
                    desmarcarTodosToolStripMenuItem_Click(sender, e);
                    // Desmarcar todos os outros itens e marcar apenas o item "64"
                    for (int i = 0; i < clbTerminologias.Items.Count; i++)
                    {
                        clbTerminologias.SetItemChecked(i, i == e.Index);
                    }
                }
                else
                {
                    e.NewValue = CheckState.Unchecked;
                }
            }
        }

        private string[] ObterItensMarcados()
        {
            // Criar uma lista para armazenar os itens marcados
            List<string> itensMarcados = new List<string>();

            // Iterar pelos itens marcados da CheckedListBox
            foreach (object item in clbTerminologias.CheckedItems)
            {
                itensMarcados.Add(item.ToString().Substring(0, 2));
            }

            // Retornar os itens marcados como um array de strings
            return itensMarcados.ToArray();
        }


        private void ImportaTabela(string pasta)
        {            
            foreach (string vTab in ObterItensMarcados())
            {
                logaEventos("Importação da tabela de domínio TISS " + vTab);
                DataTable dTab = tabela_de_dominio_detalhe();

                foreach (string vArquivo in ltbExcel.Items)
                {
                    // Cria o DataTable principal
                    DataTable tabela = new DataTable();

                    logaEventos("Arquivo selecionado para importação: " + vArquivo);

                    string conexao = $"Provider=Microsoft.ACE.OLEDB.12.0;Data Source={vArquivo};Extended Properties=\"Excel 12.0 Xml;HDR=YES;IMEX=1;\"";
                    string vPesq = "";
                    string Sht = "";

                    if (vTab.Equals("19"))
                        vPesq = "MATERIAIS E OPME";
                    else if (vTab.Equals("20"))
                        vPesq = "TAB MEDICAMENTOS";
                    else
                        vPesq = "TAB " + vTab;

                    try
                    {
                        logaEventos("Carregando dados da tabela " + vTab + " da planilha Excel");
                        estiloProgressBar(System.Windows.Forms.ProgressBarStyle.Marquee);
                        using (OleDbConnection connection = new OleDbConnection(conexao))
                        {
                            connection.Open();

                            // Obtém o esquema do arquivo Excel para obter todas as planilhas
                            DataTable excelSchema = connection.GetOleDbSchemaTable(OleDbSchemaGuid.Tables, null);

                            // Filtra as planilhas cujos nomes começam com a sequência desejada, sem diferenciação de maiúsculas e minúsculas
                            DataRow[] matchingSheets = excelSchema.Select();

                            // Lista para armazenar os nomes das planilhas correspondentes
                            var matchingSheetNames = new System.Collections.Generic.List<string>();

                            foreach (DataRow row in matchingSheets)
                            {
                                string sheetName = row["TABLE_NAME"].ToString();

                                // Compara o nome da planilha
                                if (sheetName.ToUpper().Contains(vPesq))
                                {
                                    matchingSheetNames.Add(sheetName);
                                }
                            }

                            if (matchingSheetNames.Count == 0)
                            {
                                logaEventos("Nenhuma planilha encontrada com o início do nome " + vPesq + " especificado.");
                                return;
                            }

                            // Obtém o nome da primeira planilha correspondente
                            string firstMatchingSheetName = matchingSheetNames[0].ToString();

                            // Consulta SQL para selecionar os dados da planilha
                            string query = $"SELECT * FROM [{firstMatchingSheetName}]";

                            // Cria o comando SQL
                            using (OleDbCommand command = new OleDbCommand(query, connection))
                            {
                                // Cria o adaptador de dados
                                using (OleDbDataAdapter adapter = new OleDbDataAdapter(command))
                                {
                                    adapter.Fill(tabela);
                                }
                            }
                        }
                    }
                    catch (OleDbException)
                    {
                        logaEventos("A planilha especificada não foi encontrada no arquivo Excel.", true);
                    }
                    catch (Exception ex)
                    {
                        logaEventos("Ocorreu um erro durante a extração de dados: " + ex.Message, true);
                    }


                    if (!falha)
                    {
                        if (tabela.Rows.Count > 0)
                        {
                            int vData = 3;

                            switch (Convert.ToInt32(vTab))
                            {
                                case 18:
                                case 22:
                                case 81:
                                case 79:
                                case 60:
                                    vData = 3;
                                    break;
                                case 19:
                                case 20:
                                    vData = 4;
                                    break;
                                case 64:
                                    vData = 5;
                                    break;
                                default:
                                    vData = 2;
                                    break;
                            }

                            inicializaProgressBar(tabela.Rows.Count);
                            logaEventos("Convertendo tabela " + vTab);
                            estiloProgressBar(System.Windows.Forms.ProgressBarStyle.Blocks);

                            string[] tabs = { "18", "19", "20", "22" };

                            foreach (DataRow reader in tabela.Rows)
                            {
                                if (!reader[0].ToString().Equals("") &&
                                    !reader[1].ToString().Equals("") &&
                                    !reader[0].ToString().Equals("Terminologia") &&
                                    !reader[1].ToString().Equals("Termo") &&
                                    !reader[1].ToString().Equals("Descrição"))
                                {
                                    string vTpEnvio = "";
                                    string vGrupo = "";
                                    string vDescricao = "";
                                    string vCdTermo = "";
                                    string vDtInicio = "";
                                    string vDtFim = "";
                                    string vDtImplantacao = "";
                                    string vCdFabricante = "";
                                    string vNoFabricante = "";
                                    string vNrAnvisa = "";
                                    string vTerminologia = "";
                                    string vClasseRisco = "";
                                    string vNomeTecnico = "";


                                    if (vTab.Equals("64"))
                                    {
                                        if (!tabs.Contains(reader[0].ToString()))
                                        {
                                            logaEventos("Panilha não se refere a tabela 64! Por favor verifique", true);
                                            return;
                                        }

                                        vTerminologia = reader[0].ToString();
                                        vCdTermo = reader[1].ToString();

                                        if (reader[2].ToString().Equals("Consolidado"))
                                        {
                                            vTpEnvio = "Consolidado";
                                            vGrupo = reader[3].ToString();
                                            vDescricao = reader[4].ToString();
                                        }
                                        else
                                        {
                                            vDescricao = "";
                                            vTpEnvio = "Individualizado";
                                        }
                                    }
                                    else
                                    {
                                        vCdTermo = reader[0].ToString();
                                        if (!vTab.Equals("60"))
                                            vDescricao = Trimmer(reader[1].ToString(), 255);
                                        else
                                            vDescricao = Trimmer(reader[1].ToString() + " - " + reader[2].ToString(), 255);
                                    }


                                    vDtInicio = Trimmer(reader[vData].ToString(), 10);
                                    vDtFim = Trimmer(reader[vData + 1].ToString(), 10);
                                    vDtImplantacao = Trimmer(reader[vData + 2].ToString(), 10);

                                    if (vTab.Equals("18"))
                                    {
                                        vNomeTecnico = Trimmer(reader[2].ToString(), 200);
                                    }

                                    if (vTab.Equals("19"))
                                    {
                                        vCdFabricante = Trimmer(reader[2].ToString(), 100);
                                        vNoFabricante = Trimmer(reader[3].ToString(), 200);
                                        vNrAnvisa = reader[7].ToString();
                                        vClasseRisco = reader[8].ToString();
                                        vNomeTecnico = Trimmer(reader[9].ToString(), 200);
                                    }

                                    if (vTab.Equals("20"))
                                    {
                                        vNomeTecnico = Trimmer(reader[2].ToString(),200);
                                        vNoFabricante = Trimmer(reader[3].ToString(),200);
                                        vNrAnvisa = reader[7].ToString();
                                    }

                                    if (vTab.Equals("22"))
                                    {
                                        vNomeTecnico = Trimmer(reader[2].ToString(), 200);
                                    }

                                    dTab.Rows.Add(vTab,
                                                  vCdTermo,
                                                  vDescricao,
                                                  vCdFabricante,
                                                  vNoFabricante,
                                                  vNrAnvisa,
                                                  vDtInicio,
                                                  vDtFim,
                                                  vDtImplantacao,
                                                  vTpEnvio,
                                                  vGrupo,
                                                  vTerminologia,
                                                  vClasseRisco,
                                                  vNomeTecnico);
                                }
                                incProgressBar();
                            }
                        }
                    }
                    if (falha)
                        return;
                }
                if (falha)
                    return;
                
                string nomeArquivo = "btq-tab" + vTab + ".csv"; // Pode personalizar ou gerar dinamicamente
                string caminhoCompleto = Path.Combine(pasta, nomeArquivo);
                SalvarDataTableComoCsv(dTab, caminhoCompleto, vTab);
            }
            return;
        }

        delegate void estiloProgressBarDelegate(ProgressBarStyle barStyle);
        public void estiloProgressBar(ProgressBarStyle barStyle)
        {
            if (InvokeRequired)
            {
                Invoke((estiloProgressBarDelegate)estiloProgressBar, new object[] { barStyle });
                return;
            }
            pbarDetalhe.Style = barStyle;
        }

        delegate void incProgressBarDelegate();
        private void incProgressBar()
        {
            if (InvokeRequired)
            {
                Invoke((incProgressBarDelegate)incProgressBar, new object[] {});
                return;
            }

            if (pbarDetalhe.Value < pbarDetalhe.Maximum)
                pbarDetalhe.Value += 1;
        }

        public static string Trimmer(string vCampo, int vTamanho)
        {
            if (vCampo != null)
            {
                string campo = vCampo.Replace(";", ",")
                                     .Replace("\n", " ")
                                     .Replace("\r", " ");

                if (campo.Length > vTamanho)
                    return campo.Remove(vTamanho);
                else
                    return campo.Trim();
            }
            else
                return "";
        }

        private DataTable tabela_de_dominio_detalhe()
        {
            DataTable bInsert = new DataTable();
            bInsert.Columns.Add("CDTABELA");
            bInsert.Columns.Add("CDTERMO");
            bInsert.Columns.Add("NOTERMO");
            bInsert.Columns.Add("CDFABRICANTE");
            bInsert.Columns.Add("NOFABRICANTE");
            bInsert.Columns.Add("NRANVISA");
            bInsert.Columns.Add("DTINICIO_VIGENCIA");
            bInsert.Columns.Add("DTFIM_VIGENCIA");
            bInsert.Columns.Add("DT_IMPLANTACAO");
            bInsert.Columns.Add("TPENVIO_ANS");
            bInsert.Columns.Add("CDGRUPO_ANS");
            bInsert.Columns.Add("TERMINOLOGIA");
            bInsert.Columns.Add("CLASSE_RISCO");
            bInsert.Columns.Add("NOME_TECNICO");

            return bInsert;
        }

        delegate void inicializaProgressBarDelegate(int valor_max);
        private void inicializaProgressBar(int valor_max)
        {
            if (InvokeRequired)
            {
                this.Invoke((inicializaProgressBarDelegate)inicializaProgressBar, new object[] { valor_max });
                return;
            }
            pbarDetalhe.Maximum = valor_max;
            pbarDetalhe.Minimum = 0;
            pbarDetalhe.Value = 0;
            pbarDetalhe.Step = 1;

        }

        delegate void logaEventosDelegate(string textolog, bool pFalha = false);
        private void logaEventos(string msg, bool erro = false)
        {
            if (InvokeRequired)
            {
                this.Invoke((logaEventosDelegate)logaEventos, new object[] { msg, erro });
                return;
            }
            lblLog.Text = msg;
            if (erro)
            {
                falha = true;
            }
        }

        private void btnProcessar_Click(object sender, EventArgs e)
        {
            // Verificar se há itens marcados na CheckedListBox
            if (clbTerminologias.CheckedItems.Count == 0)
            {
                MessageBox.Show("Por favor, marque pelo menos um item na lista de tabelas.", "Erro", MessageBoxButtons.OK, MessageBoxIcon.Error);
                return;
            }

            // Verificar se há itens adicionados no ListBox
            if (ltbExcel.Items.Count == 0)
            {
                MessageBox.Show("Por favor, adicione ao menos um arquivo na lista de arquivos.", "Erro", MessageBoxButtons.OK, MessageBoxIcon.Error);
                return;
            }

            // Se as verificações forem aprovadas, executar a função ImportaTabela
            try
            {
                string pasta = BuscaPasta();
                if (pasta != "")
                {
                    btnExcluiExcel.Enabled = false;
                    btnIncluiExcel.Enabled = false;
                    btnProcessar.Enabled = false;

                    BackgroundWorker worker = new BackgroundWorker
                    {
                        WorkerReportsProgress = true
                    };

                    worker.DoWork += (s, args) =>
                    {
                        ImportaTabela(pasta);
                    };

                    worker.RunWorkerCompleted += (s, args) =>
                    {
                        btnExcluiExcel.Enabled = true;
                        btnIncluiExcel.Enabled = true;
                        btnProcessar.Enabled = true;
                        estiloProgressBar(System.Windows.Forms.ProgressBarStyle.Blocks);

                        lblLog.Text = "";

                        if (!falha)
                            MessageBox.Show("Processamento concluído com sucesso!", "Sucesso", MessageBoxButtons.OK, MessageBoxIcon.Information);
                        else
                            MessageBox.Show("Processamento concluído com falhas, por favor, verifique!", "Falha", MessageBoxButtons.OK, MessageBoxIcon.Error);
                    };

                    worker.RunWorkerAsync();
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Ocorreu um erro durante o processamento: {ex.Message}", "Erro", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }

        private string BuscaPasta()
        {
            using (FolderBrowserDialog dialog = new FolderBrowserDialog())
            {
                dialog.Description = "Selecione a pasta onde os arquivos CSVs serão salvos.";
                dialog.ShowNewFolderButton = true;

                // Exibir o diálogo ao usuário
                if (dialog.ShowDialog() == DialogResult.OK)
                {
                    // Obter o caminho selecionado
                    return dialog.SelectedPath;                                        
                }
                else
                {
                    MessageBox.Show("A exportação foi cancelada pelo usuário.", "Cancelado", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                    return "";
                }
            }
        }


        public void SalvarDataTableComoCsv(DataTable dataTable, string caminhoArquivo, string vTab)
        {
            // Verificar se o DataTable contém as colunas necessárias
            List<string> colunasRequeridas;
            List<string> header;



            if (vTab == "18")
            {
                colunasRequeridas = new List<string> { "CDTERMO", "NOTERMO", "NOME_TECNICO", "DTINICIO_VIGENCIA", "DTFIM_VIGENCIA", "DT_IMPLANTACAO" };
                header = new List<string> { "Código do Termo", "Termo", "Descrição Detalhada do Termo", "Data de início de vigência", "Data de fim de vigência", "Data de fim de implantação" };
            }
            else if(vTab == "19")
            {                
                colunasRequeridas = new List<string> { "CDTERMO", "NOTERMO", "NOFABRICANTE", "DTINICIO_VIGENCIA", "DTFIM_VIGENCIA", "DT_IMPLANTACAO", "NRANVISA", "CLASSE_RISCO", "NOME_TECNICO" };
                header = new List<string> { "Código do Termo", "Termo", "Fabricante", "Data de início de vigência", "Data de fim de vigência", "Data de fim de implantação", "Registro Anvisa", "Classe de Risco", "NOME TÉCNICO" };
            }
            else if (vTab == "20")
            {
                colunasRequeridas = new List<string> { "CDTERMO", "NOTERMO", "NOME_TECNICO", "NOFABRICANTE", "DTINICIO_VIGENCIA", "DTFIM_VIGENCIA", "DT_IMPLANTACAO", "NRANVISA" };
                header = new List<string> { "Código do Termo", "Termo", "Apresentação", "Laboratório", "Data de início de vigência", "Data de fim de vigência", "Data de fim de implantação", "REGISTRO ANVISA" };
            }
            else if (vTab == "22")
            {
                colunasRequeridas = new List<string> { "CDTERMO", "NOTERMO", "NOME_TECNICO", "DTINICIO_VIGENCIA", "DTFIM_VIGENCIA", "DT_IMPLANTACAO" };
                header = new List<string> { "Código do Termo", "Termo", "Descrição Detalhada", "Data de início de vigência", "Data de fim de vigência", "Data de fim de implantação" };
            }
            else if (vTab != "64")
            {
                colunasRequeridas = new List<string> { "CDTERMO", "NOTERMO", "DTINICIO_VIGENCIA", "DTFIM_VIGENCIA", "DT_IMPLANTACAO" };
                header = new List<string> { "Código do Termo", "Termo", "Data de início de vigência", "Data de fim de vigência", "Data de fim de implantação" };
            }
            else
            {
                colunasRequeridas = new List<string> { "TERMINOLOGIA", "CDTERMO", "TPENVIO_ANS", "CDGRUPO_ANS", "NOTERMO", "DTINICIO_VIGENCIA", "DTFIM_VIGENCIA", "DT_IMPLANTACAO" };
                header = new List<string> { "Terminologia", "Código TUSS", "Forma de envio", "Código do grupo", "Descrição do grupo", "Data de início de vigência", "Data de fim de vigência", "Data de fim de implantação" };
            }


            using (StreamWriter writer = new StreamWriter(caminhoArquivo, false, Encoding.GetEncoding(1252)))
            {
                // Escrever cabeçalho no arquivo
                writer.WriteLine(string.Join(";", header));

                // Escrever as linhas do DataTable
                foreach (DataRow row in dataTable.Rows)
                {
                    string[] valores = colunasRequeridas
                        .Select(coluna =>
                        {
                            // Tratar valores nulos e substituir ";" por "," para evitar conflitos com o delimitador
                            var valor = row[coluna]?.ToString() ?? string.Empty;
                            return valor.Replace(";", ",");
                        })
                        .ToArray();

                    writer.WriteLine(string.Join(";", valores));
                }
            }

        }
    }
}
