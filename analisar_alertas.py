import pandas as pd
import argparse
import sys
import os
import re
import json
from typing import Set, List, Dict
from html import escape

# ====== CONSTANTES =====
# Nomes de colunas
COL_CREATED_ON = "sys_created_on"
COL_NODE = "node"
COL_CMDB_CI = "cmdb_ci"
COL_SELF_HEALING_STATUS = "self_healing_status"
COL_ASSIGNMENT_GROUP = "assignment_group"
COL_SHORT_DESCRIPTION = "short_description"
COL_NUMBER = "number"
COL_SOURCE = "source"
COL_METRIC_NAME = "metric_name"
COL_CMDB_CI_SYS_CLASS_NAME = "cmdb_ci.sys_class_name"

# Colunas que definem um grupo único de alertas
GROUP_COLS: List[str] = [
    COL_ASSIGNMENT_GROUP,
    COL_SHORT_DESCRIPTION,
    COL_NODE,
    COL_CMDB_CI,
    COL_SOURCE,
    COL_METRIC_NAME,
    COL_CMDB_CI_SYS_CLASS_NAME,
]

# Colunas essenciais para o funcionamento do script
ESSENTIAL_COLS: List[str] = GROUP_COLS + [
    COL_CREATED_ON, COL_SELF_HEALING_STATUS, COL_NUMBER
]

# Valores de Status
STATUS_OK = "REM_OK"
STATUS_NOT_OK = "REM_NOT_OK"
UNKNOWN = "DESCONHECIDO"
NO_STATUS = "NO_STATUS"

# Ações Sugeridas (sem emojis)
ACAO_ESTABILIZADA = "Remediação estabilizada (anteriormente falhou)"
ACAO_INTERMITENTE = "Analisar falha na remediação/intermitência"
ACAO_FALHA_PERSISTENTE = "Desenvolver/Corrigir remediação (nenhum sucesso registrado)"
ACAO_STATUS_AUSENTE = "Verificar coleta de dados da remediação (status ausente)"
ACAO_SEMPRE_OK = "Remediação automática funcional"
ACAO_INCONSISTENTE = "Analisar causa raiz das falhas (remediação inconsistente)"

# Ícone de download em SVG
DOWNLOAD_ICON_SVG = '''
<svg class="download-icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
  <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"></path>
  <polyline points="7 10 12 15 17 10"></polyline>
  <line x1="12" y1="15" x2="12" y2="3"></line>
</svg>
'''

# ====== TEMPLATE HTML =====
HTML_TEMPLATE = '''
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{title}</title>
    <style>
        :root {{
            --bg-color: #1a1c2f;
            --card-color: #2c2f48;
            --text-color: #f0f0f0;
            --text-color-dark: #3a3b45;
            --text-secondary-color: #a0a0b0;
            --border-color: #404466;
            --accent-color: #4e73df;
            --success-color: #1cc88a;
            --warning-color: #f6c23e;
            --danger-color: #e74a3b;
        }}
        body {{
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
            line-height: 1.6;
            color: var(--text-color);
            background-color: var(--bg-color);
            margin: 0;
            padding: 20px;
        }}
        .container {{
            max-width: 1200px;
            margin: auto;
        }}
        h1, h2, h3 {{
            color: var(--text-color);
            border-bottom: 1px solid var(--border-color);
            padding-bottom: 10px;
            font-weight: 500;
        }}
        h1 {{ font-size: 2em; margin-bottom: 20px; }}
        h2 {{ font-size: 1.5em; margin-top: 40px; }}
        h3 {{ font-size: 1.2em; margin-top: 25px; border-bottom: none; }}
        a {{
            color: var(--text-color);
            text-decoration: none;
            font-weight: 500;
        }}
        .grid-container {{
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
        }}
        .card {{
            background: var(--card-color);
            border: 1px solid var(--border-color);
            border-radius: 8px;
            padding: 25px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.2);
            position: relative;
            overflow: hidden;
            /* height: 100%; A linha abaixo foi removida para evitar que o card se estique verticalmente em grids com alinhamento 'start' */
            box-sizing: border-box;
        }}
        .kpi-card {{ text-align: center; }}
        .kpi-value {{ font-size: 3em; font-weight: bold; color: var(--accent-color); margin: 0; }}
        .kpi-label {{ font-size: 1em; color: var(--text-secondary-color); margin-top: 5px; }}
        table {{
            width: 100%;
            border-collapse: collapse;
        }}
        th, td {{
            padding: 12px 15px;
            text-align: left;
            border-bottom: 1px solid var(--border-color);
        }}
        th {{
            background-color: #33365a;
            font-weight: bold;
        }}
        code {{
            background-color: var(--bg-color);
            padding: 3px 6px;
            border-radius: 4px;
            font-family: "SFMono-Regular", Consolas, "Liberation Mono", Menlo, Courier, monospace;
            border: 1px solid var(--border-color);
        }}
        .collapsible {{
            background-color: #33365a;
            color: var(--text-color);
            cursor: pointer;
            padding: 18px;
            width: 100%;
            border: none;
            text-align: left;
            outline: none;
            font-size: 1.1em;
            font-weight: 500;
            margin-top: 20px;
            border-radius: 5px;
            transition: background-color 0.2s;
        }}
        .collapsible:hover, .collapsible.active {{ background-color: #3c4062; }}
        .collapsible .instance-count {{ background-color: var(--accent-color); color: white; padding: 3px 10px; border-radius: 12px; font-size: 0.85em; margin-left: 12px; }}
        .content {{
            padding: 0;
            display: none;
            overflow: hidden;
            background-color: var(--card-color);
            border-radius: 0 0 5px 5px;
            border: 1px solid #33365a;
            border-top: none;
        }}
        .emoji {{ display: inline-block; margin-right: 12px; font-size: 1.2em; vertical-align: middle; }}
        
        .expandable-row {{
            cursor: pointer;
            transition: background-color 0.2s;
        }}
        .expandable-row:hover, .expandable-row.active {{
            background-color: #3c4062;
        }}
        .details-row {{
            display: none;
        }}
        .details-row-content {{
            background-color: rgba(0,0,0,0.15);
            padding: 20px;
        }}
        .details-row-content p {{
            margin: 0 0 10px 0;
            color: var(--text-secondary-color);
        }}
        .details-row-content p strong {{
            color: var(--text-color);
        }}
        .details-row-content code {{
            white-space: normal;
            word-break: break-all;
        }}
        .download-icon {{
            width: 22px;
            height: 22px;
            color: var(--text-secondary-color);
            opacity: 0.6;
            transition: opacity 0.2s ease-in-out, transform 0.2s ease-in-out;
        }}
        a.download-link:hover .download-icon {{
            opacity: 1;
            transform: translateY(-2px);
            cursor: pointer;
        }}
        a.download-link {{
            position: absolute;
            right: 15px;
            bottom: 15px;
            line-height: 0;
        }}
        .gauge {{ width: 100%; max-width: 250px; margin: 0 auto; }}
        .gauge__body {{ width: 100%; height: 0; padding-bottom: 50%; background: #404466; position: relative; border-top-left-radius: 100% 200%; border-top-right-radius: 100% 200%; overflow: hidden; }}
        .gauge__fill {{ position: absolute; top: 100%; left: 0; width: inherit; height: 100%; background: var(--accent-color); transform-origin: center top; transform: rotate(var(--gauge-fill)); transition: transform 0.5s ease-out; }}
        .gauge__cover {{ width: 75%; height: 150%; background: var(--card-color); border-radius: 50%; position: absolute; top: 25%; left: 50%; transform: translateX(-50%); }}
        .gauge__text-overlay {{ position: absolute; top: 64%; left: 50%; transform: translate(-50%, -50%); text-align: center; width: 100%; }}
        .gauge__value {{ font-size: 2.2em; font-weight: bold; }}
        .gauge__label {{ font-size: 0.9em; color: var(--text-secondary-color); line-height: 1.2; margin-top: 0; }}
        .card-gauge {{ display: flex; align-items: center; justify-content: center; }}
        
        /* --- INÍCIO DA ALTERAÇÃO NO CSS DO GRÁFICO DE BARRAS --- */
        .bar-chart-container {{ padding: 10px; }}
        .bar-item {{ 
            margin-bottom: 16px; 
        }}
        .bar-label {{ 
            color: var(--text-secondary-color); 
            margin-bottom: 6px;
            white-space: normal; /* Permite que o texto quebre a linha */
            word-break: break-word; /* Garante a quebra de palavras longas */
        }}
        .bar-label a {{
             color: var(--text-secondary-color);
        }}
        .bar-label a:hover {{ 
            text-decoration: underline; 
            color: var(--accent-color); 
        }}
        .bar-wrapper {{ 
            background-color: var(--border-color); 
            border-radius: 4px; 
            height: 25px; 
        }}
        .bar {{ 
            height: 100%; 
            border-radius: 4px; 
            text-align: right; 
            padding-right: 8px; 
            font-weight: bold; 
            box-sizing: border-box; 
            min-width: 35px; 
            transition: width 0.5s ease-out, background-color 0.5s ease-out; 
            color: white;
            line-height: 25px;
        }}
        /* --- FIM DA ALTERAÇÃO --- */
    </style>
</head>
<body>
    <div class="container">
        <h1>{title}</h1>
        {body}
    </div>
    <script>
        // Script para collapsible de problemas
        var coll = document.getElementsByClassName("collapsible");
        for (var i = 0; i < coll.length; i++) {{
            coll[i].addEventListener("click", function() {{
                this.classList.toggle("active");
                var content = this.nextElementSibling;
                if (content.style.display === "block") {{
                    content.style.display = "none";
                }} else {{
                    content.style.display = "block";
                }}
            }});
        }}

        // Script para linhas expansíveis da tabela
        var expandableRows = document.querySelectorAll(".expandable-row");
        expandableRows.forEach(function(row) {{
            row.addEventListener("click", function() {{
                this.classList.toggle("active");
                var targetId = this.dataset.target;
                var detailRow = document.querySelector(targetId);
                if (detailRow) {{
                    if (detailRow.style.display === "table-row") {{
                        detailRow.style.display = "none";
                    }} else {{
                        detailRow.style.display = "table-row";
                    }}
                }}
            }});
        }});
    </script>
</body>
</html>
'''

def carregar_dados(filepath: str) -> pd.DataFrame:
    """Carrega, valida e prepara os dados do arquivo CSV."""
    try:
        df = pd.read_csv(filepath, encoding="utf-8-sig", sep=None, engine='python')
        print(f"✅ Arquivo '{filepath}' carregado com sucesso (UTF-8, separador detectado automaticamente).")
    except FileNotFoundError:
        print(f"❌ Erro: O arquivo '{filepath}' não foi encontrado.", file=sys.stderr)
        sys.exit(1)
    except Exception as e:
        print(f"❌ Erro inesperado ao ler o arquivo '{filepath}': {e}", file=sys.stderr)
        sys.exit(1)

    actual_columns = set(df.columns)
    missing_cols = [col for col in ESSENTIAL_COLS if col not in actual_columns]
    if missing_cols:
        print(f"❌ Erro Fatal: O arquivo de entrada não contém as seguintes colunas essenciais: {missing_cols}", file=sys.stderr)
        sys.exit(1)

    for col in GROUP_COLS:
        if col in df.columns:
            df[col] = df[col].fillna(UNKNOWN).replace("", UNKNOWN)

    print("⚙️ Padronizando colunas de data para o formato datetime (modo flexível)...")
    date_cols = [COL_CREATED_ON, 'u_action_time', 'u_closed_date']
    for col in date_cols:
        if col in df.columns:
            df[col] = pd.to_datetime(df[col], errors='coerce', format='mixed')
    
    df[COL_SELF_HEALING_STATUS] = df[COL_SELF_HEALING_STATUS].fillna(NO_STATUS)

    return df

def analisar_grupos(df: pd.DataFrame) -> pd.DataFrame:
    """Agrupa e analisa os alertas para criar um sumário."""
    
    def get_analysis(group: pd.DataFrame) -> pd.Series:
        group = group.sort_values(by=COL_CREATED_ON)
        status_chronology = group[COL_SELF_HEALING_STATUS].tolist()
        alert_numbers: Set[str] = set(group[COL_NUMBER].unique())
        
        return pd.Series({
            "status_chronology": status_chronology,
            "statuses": ", ".join(sorted(set(status_chronology))),
            "first_date": group[COL_CREATED_ON].min(), 
            "last_date": group[COL_CREATED_ON].max(),
            "alert_count": len(alert_numbers),
            "alert_numbers": ", ".join(sorted(alert_numbers)),
        })

    print("\n⏳ Analisando e agrupando alertas...")
    summary = df.groupby(GROUP_COLS, observed=True, dropna=False).apply(get_analysis, include_groups=False).reset_index()
    print(f"📊 Total de grupos únicos analisados: {summary.shape[0]}")
    return summary

def adicionar_acao_sugerida(df: pd.DataFrame) -> pd.DataFrame:
    """Adiciona uma coluna com ações sugeridas com base na cronologia dos status."""
    def sugerir_acao(row: pd.Series) -> str:
        chronology = row["status_chronology"]
        
        if not chronology or all(s == NO_STATUS for s in chronology):
            return ACAO_STATUS_AUSENTE

        last_status = chronology[-1]
        unique_statuses = set(chronology)

        if last_status == STATUS_OK:
            if len(unique_statuses) > 1:
                return ACAO_ESTABILIZADA
            else:
                return ACAO_SEMPRE_OK
        else: 
            if STATUS_OK in unique_statuses:
                return ACAO_INTERMITENTE
            else:
                return ACAO_FALHA_PERSISTENTE

    df["acao_sugerida"] = df.apply(sugerir_acao, axis=1)
    return df

def gerar_relatorios_csv(summary: pd.DataFrame, output_actuation: str, output_ok: str) -> pd.DataFrame:
    """Filtra os resultados, salva em arquivos CSV e retorna o dataframe de atuação."""
    print("\n📑 Gerando relatórios CSV...")
    
    summary_with_actions = adicionar_acao_sugerida(summary.copy())
    
    action_needed_flags = [ACAO_INTERMITENTE, ACAO_FALHA_PERSISTENTE, ACAO_STATUS_AUSENTE, ACAO_INCONSISTENTE]
    alerts_atuacao = summary_with_actions[summary_with_actions["acao_sugerida"].isin(action_needed_flags)].copy()
    
    ok_flags = [ACAO_SEMPRE_OK, ACAO_ESTABILIZADA]
    alerts_ok = summary_with_actions[summary_with_actions["acao_sugerida"].isin(ok_flags)].copy()

    full_emoji_map = {
        ACAO_INTERMITENTE: "⚠️",
        ACAO_FALHA_PERSISTENTE: "❌",
        ACAO_STATUS_AUSENTE: "❓",
        ACAO_INCONSISTENTE: "🔍",
        ACAO_SEMPRE_OK: "✅",
        ACAO_ESTABILIZADA: "✅"
    }

    alerts_atuacao_csv = alerts_atuacao.copy()
    if not alerts_atuacao_csv.empty:
        alerts_atuacao_csv['acao_sugerida'] = alerts_atuacao_csv['acao_sugerida'].apply(lambda x: f"{full_emoji_map.get(x, '')} {x}".strip())
        alerts_atuacao_csv['status_tratamento'] = 'Pendente'
        alerts_atuacao_csv['responsavel'] = ''
        alerts_atuacao_csv['data_previsao_solucao'] = ''

    alerts_ok_csv = alerts_ok.copy()
    if not alerts_ok_csv.empty:
        alerts_ok_csv['acao_sugerida'] = alerts_ok_csv['acao_sugerida'].apply(lambda x: f"{full_emoji_map.get(x, '')} {x}".strip())

    if not alerts_atuacao_csv.empty:
        alerts_atuacao_csv = alerts_atuacao_csv.sort_values(by="first_date", ascending=True)
    if not alerts_ok_csv.empty:
        alerts_ok_csv = alerts_ok_csv.sort_values(by="first_date", ascending=True)

    alerts_atuacao_csv.to_csv(output_actuation, index=False, encoding="utf-8-sig")
    print(f"✅ Arquivo de atuação geral gerado: {output_actuation}")

    alerts_ok_csv.to_csv(output_ok, index=False, encoding="utf-8-sig")
    print(f"✅ Arquivo 'OK / Estabilizado' gerado: {output_ok}")
    
    return alerts_atuacao

def gerar_planos_por_time(df_atuacao: pd.DataFrame, output_dir: str):
    """Gera arquivos de plano de ação em HTML com KPIs, gráfico de Top Problemas e detalhes expansíveis."""
    print("\n📋 Gerando planos de ação por time (versão com gráfico de top problemas)...")
    if df_atuacao.empty:
        print("⚠️ Nenhum alerta precisa de atuação. Nenhum plano de ação gerado.")
        return

    os.makedirs(output_dir, exist_ok=True)

    emoji_map = {
        ACAO_INTERMITENTE: "⚠️",
        ACAO_FALHA_PERSISTENTE: "❌",
        ACAO_STATUS_AUSENTE: "❓",
        ACAO_INCONSISTENTE: "🔍"
    }

    # Processa cada time individualmente
    for team_name, team_df in df_atuacao.groupby(COL_ASSIGNMENT_GROUP):
        sanitized_name = re.sub(r'[^a-zA-Z0-9_\-]', '', team_name.replace(" ", "_"))
        output_path = os.path.join(output_dir, f"plano-de-acao-{sanitized_name}.html")
        
        title = f"Plano de Ação: {escape(team_name)}"
        
        total_alertas = team_df['alert_count'].sum()
        body_content = '<h2>Visão Geral do Time</h2>'
        body_content += '<div class="grid-container">'
        body_content += f'''
        <div class="card kpi-card">
            <p class="kpi-value" style="color: var(--warning-color);">{len(team_df)}</p>
            <p class="kpi-label">Total de Instâncias de Problemas</p>
        </div>'''
        body_content += f'''
        <div class="card kpi-card">
            <p class="kpi-value">{total_alertas}</p>
            <p class="kpi-label">Total de Alertas Envolvidos</p>
        </div>'''
        body_content += '</div>'

        top_problemas_do_time = team_df.groupby(COL_SHORT_DESCRIPTION)['alert_count'].sum().nlargest(10)

        body_content += '<div class="card" style="margin-top: 20px;">'
        body_content += f"<h3>Top Problemas do Time (por Volume de Alertas)</h3>"
        
        if not top_problemas_do_time.empty:
            body_content += '<div class="bar-chart-container">'
            min_prob_val, max_prob_val = top_problemas_do_time.min(), top_problemas_do_time.max()
            
            for problem, count in top_problemas_do_time.items():
                bar_width = (count / max_prob_val) * 100 if max_prob_val > 0 else 0
                background_color, text_color = gerar_cores_para_barra(count, min_prob_val, max_prob_val)
                body_content += f'''
                <div class="bar-item">
                    <div class="bar-label" title="{escape(problem)}">{escape(problem)}</div>
                    <div class="bar-wrapper">
                        <div class="bar" style="width: {bar_width}%; background-color: {background_color}; color: {text_color};">{count}</div>
                    </div>
                </div>'''
            body_content += '</div>'
        else:
            body_content += "<p>Nenhum problema recorrente para este time. ✅</p>"
        
        body_content += '</div>'
        
        body_content += f"<h2>Detalhes de Todas as Instâncias</h2>"

        team_df['acao_sugerida'] = pd.Categorical(team_df['acao_sugerida'], categories=emoji_map.keys(), ordered=True)
        team_df = team_df.sort_values(by=['acao_sugerida', 'last_date'], ascending=[True, False])

        row_index = 0
        for problem_desc, problem_group_df in team_df.groupby(COL_SHORT_DESCRIPTION, sort=False):
            acao_principal = problem_group_df['acao_sugerida'].iloc[0]
            emoji = emoji_map.get(acao_principal, '⚙️')
            num_instances = len(problem_group_df)

            body_content += f'''
            <button type="button" class="collapsible">
                <span class="emoji">{emoji}</span>
                {escape(problem_desc)}
                <span class="instance-count">{num_instances} {"instâncias" if num_instances > 1 else "instância"}</span>
            </button>
            <div class="content" style="display: block; padding:0;">
                <table>
                    <thead>
                        <tr>
                            <th>Recurso (CI) / Nó</th>
                            <th>Ação Sugerida</th>
                            <th>Período do Problema</th>
                            <th>Alertas</th>
                        </tr>
                    </thead>
                    <tbody>
            '''

            for _, row in problem_group_df.iterrows():
                row_index += 1
                target_id = f"details-row-{row_index}"

                recurso_info = f"<strong>{escape(row[COL_CMDB_CI])}</strong>"
                if row[COL_NODE] != row[COL_CMDB_CI]:
                    recurso_info += f"<br><small style='color:var(--text-secondary-color)'>{escape(row[COL_NODE])}</small>"
                
                acao_info = f"<span class='emoji'>{emoji_map.get(row['acao_sugerida'], '⚙️')}</span> {escape(row['acao_sugerida'])}"

                periodo_info = f"{row['first_date'].strftime('%d/%m %H:%M')} a<br>{row['last_date'].strftime('%d/%m %H:%M')}"
                
                body_content += f'''
                        <tr class="expandable-row" data-target="#{target_id}">
                            <td>{recurso_info}</td>
                            <td>{acao_info}</td>
                            <td>{periodo_info}</td>
                            <td>{row['alert_count']}</td>
                        </tr>
                '''
                
                alertas_info = f"<code>{escape(row['alert_numbers'])}</code>"
                cronologia_info = f"<code>{' → '.join(map(escape, row['status_chronology']))}</code>"

                body_content += f'''
                        <tr id="{target_id}" class="details-row">
                            <td colspan="4">
                                <div class="details-row-content">
                                    <p><strong>Alertas Envolvidos ({row['alert_count']}):</strong> {alertas_info}</p>
                                    <p><strong>Cronologia:</strong> {cronologia_info}</p>
                                </div>
                            </td>
                        </tr>
                '''

            body_content += '</tbody></table></div>'

        html_content = HTML_TEMPLATE.format(title=title, body=body_content)
        with open(output_path, 'w', encoding='utf-8') as f:
            f.write(html_content)
        
        print(f"✅ Plano de ação para o time '{team_name}' gerado em: {output_path}")

def gerar_cores_para_barra(valor: int, valor_min: int, valor_max: int) -> tuple[str, str]:
    """
    Gera uma tupla com (cor de fundo, cor de texto) para a barra do gráfico.
    """
    if valor_max == valor_min:
        return "hsl(0, 90%, 55%)", "white"
    
    fracao = (valor - valor_min) / (valor_max - valor_min)
    hue = 60 - (fracao * 60)
    
    background_color = f"hsl({hue:.0f}, 90%, 55%)"
    text_color = "var(--text-color-dark)" if hue > 35 else "white"
        
    return background_color, text_color

def gerar_resumo_executivo(df_total: pd.DataFrame, df_atuacao: pd.DataFrame, output_path: str, plan_dir: str, actuation_csv_path: str, ok_csv_path: str, json_path: str):
    """Gera um arquivo HTML com o resumo executivo da análise."""
    print("\n📄 Gerando Resumo Executivo estilo Dashboard...")

    total_grupos = len(df_total)
    grupos_atuacao = len(df_atuacao)
    taxa_sucesso = (1 - (grupos_atuacao / total_grupos)) * 100 if total_grupos > 0 else 100
    gauge_rotation = taxa_sucesso / 100 * 180

    all_times = df_atuacao[COL_ASSIGNMENT_GROUP].value_counts()
    top_times = all_times.nlargest(10)
    
    top_problemas = df_atuacao.groupby(COL_SHORT_DESCRIPTION)['alert_count'].sum().nlargest(10)
    
    actuation_csv_name = os.path.basename(actuation_csv_path)
    ok_csv_name = os.path.basename(ok_csv_path)
    json_name = os.path.basename(json_path)

    title = "Dashboard da Análise de Alertas"
    
    body_content = '<h2>Visão Geral</h2>'
    body_content += '<div class="grid-container">'

    gauge_color_class = "var(--success-color)"
    if taxa_sucesso < 70: gauge_color_class = "var(--warning-color)"
    if taxa_sucesso < 50: gauge_color_class = "var(--danger-color)"
    
    body_content += f'''
    <div class="card kpi-card" title="Número total de problemas únicos identificados. Alertas para o mesmo problema no mesmo recurso são agrupados.">
        <p class="kpi-value">{total_grupos}</p>
        <p class="kpi-label">Total de Problemas Únicos</p>
        <a href="{json_name}" download="{json_name}" class="download-link" title="Baixar JSON com todos os problemas">
            {DOWNLOAD_ICON_SVG}
        </a>
    </div>
    '''

    body_content += f'''
    <div class="card card-gauge" title="Percentual de grupos de problemas que foram resolvidos com sucesso pela automação, sem necessidade de intervenção.">
        <div class="gauge">
            <div class="gauge__body">
                <div class="gauge__fill" style="transform: rotate({gauge_rotation}deg); background: {gauge_color_class};"></div>
                <div class="gauge__cover"></div>
            </div>
        </div>
        <div class="gauge__text-overlay">
            <div class="gauge__value" style="color: {gauge_color_class};">{taxa_sucesso:.1f}%</div>
            <p class="kpi-label">Sucesso da Automação</p>
        </div>
        <a href="{ok_csv_name}" download="{ok_csv_name}" class="download-link" title="Baixar CSV com problemas resolvidos">
            {DOWNLOAD_ICON_SVG}
        </a>
    </div>
    '''
    
    body_content += f'''
    <div class="card kpi-card" title="Grupos de problemas onde a automação falhou ou não atuou, exigindo análise manual.">
        <p class="kpi-value" style="color: var(--warning-color);">{grupos_atuacao}</p>
        <p class="kpi-label">Problemas Precisando de Ação</p>
        <a href="{actuation_csv_name}" download="{actuation_csv_name}" class="download-link" title="Baixar CSV com problemas a atuar">
            {DOWNLOAD_ICON_SVG}
        </a>
    </div>
    '''
    body_content += '</div>'

    body_content += "<h2>Pontos de Atenção</h2>"
    body_content += '<div class="grid-container" style="grid-template-columns: 1fr 1fr; align-items: start;">'
    
    body_content += '<div>'
    
    body_content += '<div class="card">'
    body_content += "<h3>Top 10 Times com Mais Problemas</h3>"
    if not top_times.empty:
        body_content += '<div class="bar-chart-container">'
        min_team_val, max_team_val = top_times.min(), top_times.max()
        plan_base_dir = os.path.basename(plan_dir)
        for team, count in top_times.items():
            bar_width = (count / max_team_val) * 100 if max_team_val > 0 else 0
            background_color, text_color = gerar_cores_para_barra(count, min_team_val, max_team_val)
            sanitized_name = re.sub(r'[^a-zA-Z0-9_\-]', '', team.replace(" ", "_"))
            plan_path = os.path.join(plan_base_dir, f"plano-de-acao-{sanitized_name}.html")
            body_content += f'''
            <div class="bar-item">
                <div class="bar-label"><a href="{plan_path}" title="{escape(team)}">{escape(team)}</a></div>
                <div class="bar-wrapper">
                    <div class="bar" style="width: {bar_width}%; background-color: {background_color}; color: {text_color};">{count}</div>
                </div>
            </div>'''
        body_content += '</div>'
    else:
        body_content += "<p>Nenhum time com problemas recorrentes. ✅</p>"
    body_content += '</div>'

    other_times = all_times.drop(top_times.index, errors='ignore')
    if not other_times.empty:
        body_content += f'''
        <button type="button" class="collapsible">Mais Times ({len(other_times)})</button>
        <div class="content">
            <div class="bar-chart-container" style="padding: 10px 0;">'''
        min_other_val, max_other_val = other_times.min(), other_times.max()
        for team, count in other_times.items():
            bar_width = (count / max_other_val) * 100 if max_other_val > 0 else 0
            background_color, text_color = gerar_cores_para_barra(count, min_other_val, max_other_val)
            sanitized_name = re.sub(r'[^a-zA-Z0-9_\-]', '', team.replace(" ", "_"))
            plan_path = os.path.join(plan_base_dir, f"plano-de-acao-{sanitized_name}.html")
            body_content += f'''
            <div class="bar-item">
                <div class="bar-label"><a href="{plan_path}" title="{escape(team)}">{escape(team)}</a></div>
                <div class="bar-wrapper">
                    <div class="bar" style="width: {bar_width}%; background-color: {background_color}; color: {text_color};">{count}</div>
                </div>
            </div>'''
        body_content += '</div></div>'
    
    body_content += '</div>' 

    body_content += '<div class="card">'
    body_content += "<h3>Top 10 Problemas Mais Recorrentes</h3>"
    if not top_problemas.empty:
        body_content += '<div class="bar-chart-container">'
        min_prob_val, max_prob_val = top_problemas.min(), top_problemas.max()
        for problem, count in top_problemas.items():
            bar_width = (count / max_prob_val) * 100 if max_prob_val > 0 else 0
            background_color, text_color = gerar_cores_para_barra(count, min_prob_val, max_prob_val)
            body_content += f'''
            <div class="bar-item">
                <div class="bar-label" title="{escape(problem)}">{escape(problem)}</div>
                <div class="bar-wrapper">
                    <div class="bar" style="width: {bar_width}%; background-color: {background_color}; color: {text_color};">{count}</div>
                </div>
            </div>'''
        body_content += '</div>'
    else:
        body_content += "<p>Nenhum problema recorrente. ✅</p>"
    body_content += '</div>'

    body_content += '</div>'
    
    html_content = HTML_TEMPLATE.format(title=title, body=body_content)
    with open(output_path, 'w', encoding='utf-8') as f:
        f.write(html_content)
    print(f"✅ Resumo executivo gerado: {output_path}")

def export_summary_to_json(summary: pd.DataFrame, output_path: str):
    """Salva o dataframe de resumo em formato JSON."""
    print(f"\n💾 Exportando resumo para JSON...")
    
    summary_json = summary.copy()
    if 'first_date' in summary_json.columns:
        summary_json['first_date'] = summary_json['first_date'].astype(str)
    if 'last_date' in summary_json.columns:
        summary_json['last_date'] = summary_json['last_date'].astype(str)
    
    summary_with_actions = adicionar_acao_sugerida(summary_json)

    summary_with_actions.to_json(output_path, orient='records', indent=4, date_format='iso')
    print(f"✅ Resumo salvo em: {output_path}")

def main():
    parser = argparse.ArgumentParser(description="Analisa um arquivo CSV de alertas para identificar e validar grupos que necessitam de atuação.")
    
    # CORREÇÃO: Trocado "add-argument" por "add_argument" em todas as linhas abaixo
    parser.add_argument("input_file", help="Caminho para o arquivo CSV de entrada.")
    parser.add_argument("--output-summary", help="Caminho de saída para o resumo executivo em HTML.")
    parser.add_argument("--output-actuation", help="Caminho de saída para o CSV de atuação geral.")
    parser.add_argument("--output-ok", help="Caminho de saída para o CSV de alertas que foram sempre OK ou estabilizados.")
    parser.add_argument("--plan-dir", help="Diretório de saída para os planos de ação em HTML por time.")
    parser.add_argument("--output-json", required=True, help="Caminho de saída para o resumo de problemas em JSON.")
    parser.add_argument("--resumo-only", action='store_true', help="Se especificado, gera apenas o arquivo de resumo JSON.")
    
    args = parser.parse_args()

    if not args.resumo_only:
        required_for_full_run = [args.output_summary, args.output_actuation, args.output_ok, args.plan_dir]
        if not all(required_for_full_run):
            print("❌ Erro: Para o modo de análise completa, os argumentos --output-summary, --output-actuation, --output-ok, e --plan-dir são obrigatórios.", file=sys.stderr)
            sys.exit(1)

    df = carregar_dados(args.input_file)
    summary = analisar_grupos(df)
    
    export_summary_to_json(summary, args.output_json)

    if not args.resumo_only:
        df_atuacao = gerar_relatorios_csv(summary, args.output_actuation, args.output_ok)
        gerar_resumo_executivo(summary, df_atuacao, args.output_summary, args.plan_dir, args.output_actuation, args.output_ok, args.output_json)
        gerar_planos_por_time(df_atuacao, args.plan_dir)

if __name__ == "__main__":
    main()