namespace TabTISS
{
    partial class frmTabTISS
    {
        /// <summary>
        ///  Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        ///  Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        ///  Required method for Designer support - do not modify
        ///  the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            components = new System.ComponentModel.Container();
            clbTerminologias = new CheckedListBox();
            cmsTerminologias = new ContextMenuStrip(components);
            selecionarTodosToolStripMenuItem = new ToolStripMenuItem();
            desmarcarTodosToolStripMenuItem = new ToolStripMenuItem();
            label1 = new Label();
            label2 = new Label();
            ltbExcel = new ListBox();
            btnProcessar = new Button();
            btnIncluiExcel = new Button();
            btnExcluiExcel = new Button();
            pbarDetalhe = new ProgressBar();
            lblLog = new Label();
            cmsTerminologias.SuspendLayout();
            SuspendLayout();
            // 
            // clbTerminologias
            // 
            clbTerminologias.ContextMenuStrip = cmsTerminologias;
            clbTerminologias.FormattingEnabled = true;
            clbTerminologias.Items.AddRange(new object[] { "18 - TUSS Diárias e Taxas", "19 - TUSS Materiais e OPME", "20 - TUSS Medicamentos", "22 - TUSS Procedimentos e Eventos em Saúde", "23 - Caráter do atendimento", "24 - Classificação Brasileira de Ocupações (CBO)", "25 - Código da despesa", "26 - Conselho profissional", "27 - Débitos e créditos", "28 - Dentes", "29 - Diagnóstico por imagem", "30 - Escala de capacidade funcional (ECOG - Escala de Zubrod)", "31 - Estadiamento do tumor", "32 - Faces do dente", "33 - Finalidade do tratamento", "34 - Forma de pagamento", "35 - Grau de participação", "36 - Indicador de acidente", "37 - Indicador de débito ou crédito", "38 - Mensagens (glosas, negativas e outras)", "39 - Motivo de encerramento", "40 - Origem da Guia", "41 - Regime de internação", "42 - Regiões da boca", "43 - Sexo", "44 - Situação inicial do dente", "45 - Status da solicitação", "46 - Status do", "47 - Status do protocolo", "48 - Técnica utilizada", "49 - Tipo de acomodação", "50 - Tipo de atendimento", "51 - Tipo de atendimento em odontologia", "52 - Tipo de consulta", "53 - Tipo de demonstrativo", "54 - Tipo de guia", "55 - Tipo de faturamento", "56 - Natureza da guia", "57 - Tipo de internação", "58 - Tipo de quimioterapia", "59 - Unidade da federação", "60 - Unidade de medida", "61 - Via de acesso", "62 - Via de administração", "63 - Grupos de procedimentos e itens assistenciais para envio para ANS", "64 - Envio de Dados para ANS", "65 - metástases", "66 - nódulo", "67 - tumor", "68 - categoria de despesa", "69 - versão do componente de comunicação do padrão", "70 - forma de envio do padrão", "71 - Tipo de atendimento por operadora intermediária", "72 - tipo de identificação do beneficiário", "73 - etapas de autorização", "74 - motivos de ausência do código de validação", "75 - Cobertura especial", "76 - Regime de", "77 - Saúde ocupacional", "78 - Tipo de Pagamento", "79 - Modelos de Remuneração entre Operadoras e Prestadores", "80 - formato do documento", "81 - Tipo do documento", "87 - Relação das terminologias unificadas na saúde" });
            clbTerminologias.Location = new Point(22, 31);
            clbTerminologias.Name = "clbTerminologias";
            clbTerminologias.Size = new Size(766, 202);
            clbTerminologias.TabIndex = 1;
            clbTerminologias.ItemCheck += clbTerminologias_ItemCheck;
            clbTerminologias.SelectedIndexChanged += checkedListBox1_SelectedIndexChanged;
            // 
            // cmsTerminologias
            // 
            cmsTerminologias.ImageScalingSize = new Size(20, 20);
            cmsTerminologias.Items.AddRange(new ToolStripItem[] { selecionarTodosToolStripMenuItem, desmarcarTodosToolStripMenuItem });
            cmsTerminologias.Name = "cmsTerminologias";
            cmsTerminologias.Size = new Size(194, 52);
            cmsTerminologias.Opening += cmsTerminologias_Opening;
            // 
            // selecionarTodosToolStripMenuItem
            // 
            selecionarTodosToolStripMenuItem.Name = "selecionarTodosToolStripMenuItem";
            selecionarTodosToolStripMenuItem.Size = new Size(193, 24);
            selecionarTodosToolStripMenuItem.Text = "Selecionar Todos";
            selecionarTodosToolStripMenuItem.Click += selecionarTodosToolStripMenuItem_Click;
            // 
            // desmarcarTodosToolStripMenuItem
            // 
            desmarcarTodosToolStripMenuItem.Name = "desmarcarTodosToolStripMenuItem";
            desmarcarTodosToolStripMenuItem.Size = new Size(193, 24);
            desmarcarTodosToolStripMenuItem.Text = "Desmarcar Todos";
            desmarcarTodosToolStripMenuItem.Click += desmarcarTodosToolStripMenuItem_Click;
            // 
            // label1
            // 
            label1.AutoSize = true;
            label1.Location = new Point(22, 9);
            label1.Name = "label1";
            label1.Size = new Size(103, 20);
            label1.TabIndex = 2;
            label1.Text = "Terminologias";
            // 
            // label2
            // 
            label2.AutoSize = true;
            label2.Location = new Point(22, 236);
            label2.Name = "label2";
            label2.Size = new Size(99, 20);
            label2.TabIndex = 3;
            label2.Text = "Arquivo Excel";
            // 
            // ltbExcel
            // 
            ltbExcel.FormattingEnabled = true;
            ltbExcel.Location = new Point(22, 259);
            ltbExcel.Name = "ltbExcel";
            ltbExcel.Size = new Size(766, 104);
            ltbExcel.TabIndex = 4;
            // 
            // btnProcessar
            // 
            btnProcessar.Location = new Point(350, 379);
            btnProcessar.Name = "btnProcessar";
            btnProcessar.Size = new Size(94, 29);
            btnProcessar.TabIndex = 5;
            btnProcessar.Text = "Processar";
            btnProcessar.UseVisualStyleBackColor = true;
            btnProcessar.Click += btnProcessar_Click;
            // 
            // btnIncluiExcel
            // 
            btnIncluiExcel.Location = new Point(794, 259);
            btnIncluiExcel.Name = "btnIncluiExcel";
            btnIncluiExcel.Size = new Size(31, 29);
            btnIncluiExcel.TabIndex = 6;
            btnIncluiExcel.Text = "+";
            btnIncluiExcel.UseVisualStyleBackColor = true;
            btnIncluiExcel.Click += btnIncluiExcel_Click;
            // 
            // btnExcluiExcel
            // 
            btnExcluiExcel.Location = new Point(794, 294);
            btnExcluiExcel.Name = "btnExcluiExcel";
            btnExcluiExcel.Size = new Size(31, 29);
            btnExcluiExcel.TabIndex = 7;
            btnExcluiExcel.Text = "-";
            btnExcluiExcel.UseVisualStyleBackColor = true;
            btnExcluiExcel.Click += btnExcluiExcel_Click;
            // 
            // pbarDetalhe
            // 
            pbarDetalhe.Dock = DockStyle.Bottom;
            pbarDetalhe.Location = new Point(0, 442);
            pbarDetalhe.Name = "pbarDetalhe";
            pbarDetalhe.Size = new Size(833, 29);
            pbarDetalhe.TabIndex = 8;
            // 
            // lblLog
            // 
            lblLog.Anchor = AnchorStyles.Bottom | AnchorStyles.Left;
            lblLog.AutoSize = true;
            lblLog.Location = new Point(12, 419);
            lblLog.Name = "lblLog";
            lblLog.Size = new Size(0, 20);
            lblLog.TabIndex = 9;
            // 
            // frmTabTISS
            // 
            AutoScaleDimensions = new SizeF(8F, 20F);
            AutoScaleMode = AutoScaleMode.Font;
            ClientSize = new Size(833, 471);
            Controls.Add(lblLog);
            Controls.Add(pbarDetalhe);
            Controls.Add(btnExcluiExcel);
            Controls.Add(btnIncluiExcel);
            Controls.Add(btnProcessar);
            Controls.Add(ltbExcel);
            Controls.Add(label2);
            Controls.Add(label1);
            Controls.Add(clbTerminologias);
            Name = "frmTabTISS";
            Text = "Tabelas de Domínio TISS - geração csv";
            cmsTerminologias.ResumeLayout(false);
            ResumeLayout(false);
            PerformLayout();
        }

        #endregion

        private CheckedListBox clbTerminologias;
        private Label label1;
        private Label label2;
        private ListBox ltbExcel;
        private Button btnProcessar;
        private Button btnIncluiExcel;
        private Button btnExcluiExcel;
        private ContextMenuStrip cmsTerminologias;
        private ToolStripMenuItem selecionarTodosToolStripMenuItem;
        private ToolStripMenuItem desmarcarTodosToolStripMenuItem;
        private ProgressBar pbarDetalhe;
        private Label lblLog;
    }
}
