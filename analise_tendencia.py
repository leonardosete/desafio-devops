import pandas as pd
import sys
import os
import argparse
from html import escape

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
            --text-secondary-color: #a0a0b0;
            --border-color: #404466;
            --success-color: #1cc88a;
            --warning-color: #f6c23e;
            --danger-color: #e74a3b;
            --info-color: #4e73df;
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
        h2 {{ font-size: 1.5em; margin-top: 40px; border: none; }}
        .card {{
            background: var(--card-color);
            border: 1px solid var(--border-color);
            border-radius: 8px;
            padding: 25px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.2);
            margin-bottom: 25px;
        }}
        .grid-container {{
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            margin-bottom: 25px;
        }}
        .kpi-card {{ text-align: center; }}
        .kpi-value {{ font-size: 3em; font-weight: bold; margin: 0; }}
        .kpi-label {{ font-size: 1em; color: var(--text-secondary-color); margin-top: 5px; }}
        
        table {{ width: 100%; border-collapse: collapse; margin-top: 20px; }}
        th, td {{ padding: 12px 15px; text-align: left; border-bottom: 1px solid var(--border-color); }}
        th {{ background-color: #33365a; font-weight: bold; }}
        tr:hover {{ background-color: #3c4062; }}
        
        code {{ background-color: var(--bg-color); padding: 3px 6px; border-radius: 4px; border: 1px solid var(--border-color); }}
        ul {{ list-style-type: none; padding: 0; }}
        li strong {{ color: var(--text-secondary-color); min-width: 150px; display: inline-block; }}
        
        .status-resolved    {{ color: var(--success-color); font-weight: bold; }}
        .status-worsened    {{ color: var(--danger-color); font-weight: bold; }}
        .status-new         {{ color: var(--warning-color); font-weight: bold; }}
        .status-improved    {{ color: var(--success-color); font-weight: bold; }}
        .status-maintained  {{ color: var(--text-secondary-color); }}

        .change-bar-container {{ display: flex; align-items: center; gap: 10px; }}
        .bar-wrapper {{ flex-grow: 1; background-color: var(--border-color); border-radius: 4px; height: 12px; }}
        .bar {{ height: 100%; border-radius: 4px; }}
        .bar.positive {{ background-color: var(--success-color); }}
        .bar.negative {{ background-color: var(--danger-color); }}
        .change-value {{ font-weight: bold; min-width: 35px; text-align: right; }}

        .gauge {{ width: 100%; max-width: 250px; margin: 0 auto; position: relative; }}
        .gauge__body {{ width: 100%; height: 0; padding-bottom: 50%; background: #404466; position: relative; border-top-left-radius: 100% 200%; border-top-right-radius: 100% 200%; overflow: hidden; }}
        .gauge__fill {{ position: absolute; top: 100%; left: 0; width: inherit; height: 100%; background: var(--info-color); transform-origin: center top; transform: rotate(var(--gauge-fill)); transition: transform 0.5s ease-out; }}
        .gauge__cover {{ width: 75%; height: 150%; background: var(--card-color); border-radius: 50%; position: absolute; top: 25%; left: 50%; transform: translateX(-50%); }}
        .gauge__text-overlay {{ position: absolute; top: 78%; left: 50%; transform: translate(-50%, -50%); text-align: center; width: 100%; }}
        .gauge__value {{ font-size: 2.2em; font-weight: bold; }}
    </style>
</head>
<body>
    <div class="container">
        <h1>{title}</h1>
        {body}
    </div>
</body>
</html>
'''

def load_summary_from_json(filepath: str):
    """Carrega o resumo de problemas a partir de um arquivo JSON."""
    try:
        df = pd.read_json(filepath, orient='records')
        print(f"✅ Resumo de problemas carregado de: {filepath}")
    except (FileNotFoundError, ValueError) as e:
        print(f"❌ Erro ao carregar o arquivo JSON '{filepath}': {e}", file=sys.stderr)
        return None
    return df

def analyze_trends(df_p1, df_p2, group_col):
    """Compara os dois dataframes e retorna um dataframe combinado com as tendências."""
    action_needed_flags = [
        "Analisar falha intermitente da remediação",
        "Desenvolver/Corrigir remediação (nenhum sucesso registrado)",
        "Verificar coleta de dados da remediação (status ausente)",
        "Analisar causa raiz das falhas (remediação inconsistente)"
    ]
    
    df_p1_atuacao = df_p1[df_p1["acao_sugerida"].isin(action_needed_flags)]
    df_p2_atuacao = df_p2[df_p2["acao_sugerida"].isin(action_needed_flags)]

    counts_p1 = df_p1_atuacao[group_col].value_counts().to_frame('count_p1')
    counts_p2 = df_p2_atuacao[group_col].value_counts().to_frame('count_p2')

    combined_df = pd.concat([counts_p1, counts_p2], axis=1).fillna(0)
    combined_df = combined_df.astype(int)
    
    combined_df['change'] = combined_df['count_p2'] - combined_df['count_p1']
    combined_df = combined_df[combined_df['change'] != 0 | (combined_df['count_p1'] > 0)]
    combined_df['abs_change'] = combined_df['change'].abs()
    
    return combined_df.sort_values(by=['abs_change', 'change'], ascending=[False, False])

def calculate_kpis_tendencia(df_trends):
    """Calcula os KPIs de alto nível a partir do dataframe de tendências."""
    if df_trends.empty:
        return {'resolved': 0, 'new': 0, 'net_change': 0, 'improvement_rate': 0}

    resolved = df_trends[(df_trends['count_p1'] > 0) & (df_trends['count_p2'] == 0)].shape[0]
    new = df_trends[(df_trends['count_p1'] == 0) & (df_trends['count_p2'] > 0)].shape[0]
    
    net_change = df_trends['count_p2'].sum() - df_trends['count_p1'].sum()

    improved_or_resolved_count = df_trends[df_trends['change'] < 0].shape[0]
    total_from_p1 = df_trends[df_trends['count_p1'] > 0].shape[0]
    
    improvement_rate = (improved_or_resolved_count / total_from_p1 * 100) if total_from_p1 > 0 else 100
    
    return {
        'resolved': resolved,
        'new': new,
        'net_change': net_change,
        'improvement_rate': improvement_rate
    }

def generate_kpis_html(kpis):
    """Gera o HTML para a seção de KPIs de resumo."""
    net_change_color = 'var(--success-color)' if kpis['net_change'] <= 0 else 'var(--danger-color)'
    gauge_rotation = kpis['improvement_rate'] / 100 * 180
    
    # Define a cor do gauge
    gauge_color_class = "var(--success-color)"
    if kpis['improvement_rate'] < 70: gauge_color_class = "var(--warning-color)"
    if kpis['improvement_rate'] < 50: gauge_color_class = "var(--danger-color)"

    kpi_html = "<h2>Resumo da Tendência</h2><div class='grid-container'>"
    kpi_html += f"""
    <div class="card kpi-card" title="Categorias de problemas que existiam no período 1 e foram eliminadas no período 2.">
        <p class="kpi-value" style="color: var(--success-color);">{kpis['resolved']}</p>
        <p class="kpi-label">Problemas Resolvidos</p>
    </div>
    <div class="card kpi-card" title="Categorias de problemas que não existiam no período 1 e surgiram no período 2.">
        <p class="kpi-value" style="color: var(--warning-color);">{kpis['new']}</p>
        <p class="kpi-label">Novos Problemas</p>
    </div>
    <div class="card kpi-card" title="Balanço total de ocorrências de problemas (Total P2 - Total P1).">
        <p class="kpi-value" style="color: {net_change_color};">{kpis['net_change']:+d}</p>
        <p class="kpi-label">Balanço Geral de Ocorrências</p>
    </div>
    <div class="card" title="Dos problemas existentes no Período 1, quantos % foram melhorados ou resolvidos.">
        <div class="gauge">
            <div class="gauge__body">
                <div class="gauge__fill" style="--gauge-fill: {gauge_rotation}deg; background: {gauge_color_class};"></div>
                <div class="gauge__cover"></div>
            </div>
            <div class="gauge__text-overlay">
                <div class="gauge__value" style="color: {gauge_color_class};">{kpis['improvement_rate']:.1f}%</div>
                <p class="kpi-label" style="margin-top:0;">Taxa de Melhoria</p>
            </div>
        </div>
    </div>
    """
    kpi_html += "</div>"
    return kpi_html

def generate_trend_table_html(sorted_df, category_name, label_p1, label_p2):
    """Gera a tabela HTML detalhada de tendências a partir de um dataframe processado."""
    report = f"<h2>{escape(category_name)}</h2>"
    
    if sorted_df.empty:
        report += "<p>🤷 Nenhum dado para comparar ou nenhuma mudança registrada.</p>"
        return report

    max_abs_change = sorted_df['abs_change'].max() if not sorted_df.empty else 1
    report += f"<table><tr><th>Status</th><th>Item</th><th style='text-align:center;'>{escape(label_p1)}</th><th style='text-align:center;'>{escape(label_p2)}</th><th>Mudança</th></tr>"

    for name, row in sorted_df.iterrows():
        p1_count, p2_count, change = row['count_p1'], row['count_p2'], row['change']
        status_text, status_class = "", ""
        if p2_count == 0: status_text, status_class = "✅ Resolvido", "status-resolved"
        elif change > 0 and p1_count > 0: status_text, status_class = "📉 Piorou", "status-worsened"
        elif change > 0 and p1_count == 0: status_text, status_class = "⚠️ Novo", "status-new"
        elif change < 0: status_text, status_class = "📈 Melhorou", "status-improved"
        else: status_text, status_class = "➡️ Manteve", "status-maintained"
        
        bar_html = ""
        if change != 0:
            bar_width = (abs(change) / max_abs_change) * 100
            bar_class = "negative" if change > 0 else "positive"
            bar_html = f'<div class="change-bar-container"><div class="bar-wrapper"><div class="bar {bar_class}" style="width: {bar_width}%;"></div></div><span class="change-value">{change:+d}</span></div>'
        else:
            bar_html = f'<div class="change-bar-container"><span class="change-value" style="color: var(--text-secondary-color)">{change:+d}</span></div>'

        report += f'<tr><td class="{status_class}">{status_text}</td><td>{escape(name)}</td><td style="text-align:center;">{p1_count}</td><td style="text-align:center;">{p2_count}</td><td>{bar_html}</td></tr>'

    return report + "</table>\n"

def main():
    parser = argparse.ArgumentParser(description="Analisa a tendência entre dois resumos de problemas em JSON.")
    parser.add_argument("json_anterior", help="Caminho para o arquivo de resumo JSON do período anterior.")
    parser.add_argument("json_atual", help="Caminho para o arquivo de resumo JSON do período atual.")
    parser.add_argument("csv_anterior_name", help="Nome do arquivo CSV original do período anterior para usar como rótulo.")
    parser.add_argument("csv_atual_name", help="Nome do arquivo CSV original do período atual para usar como rótulo.")
    parser.add_argument("date_range_anterior", nargs='?', default=None, help="Intervalo de datas do período anterior (opcional).")
    parser.add_argument("date_range_atual", nargs='?', default=None, help="Intervalo de datas do período atual (opcional).")
    args = parser.parse_args()

    df_p1 = load_summary_from_json(args.json_anterior)
    df_p2 = load_summary_from_json(args.json_atual)

    if df_p1 is None or df_p2 is None:
        sys.exit("❌ Não foi possível continuar devido a erros na análise dos arquivos de resumo JSON.")

    # Análise para Times
    teams_trends_df = analyze_trends(df_p1, df_p2, 'assignment_group')
    teams_kpis = calculate_kpis_tendencia(teams_trends_df)

    # Análise para Problemas
    problems_trends_df = analyze_trends(df_p1, df_p2, 'short_description')

    # Montagem do HTML
    title = "📊 Análise de Tendência de Alertas"
    body = "<div class='card'>"
    body += "<h2>Períodos Analisados</h2>"
    periodo_anterior_text = f"<code>{escape(os.path.basename(args.csv_anterior_name))}</code>"
    if args.date_range_anterior and args.date_range_anterior != "N/A":
        periodo_anterior_text += f" <span style='color: var(--text-secondary-color);'>({escape(args.date_range_anterior)})</span>"
    periodo_atual_text = f"<code>{escape(os.path.basename(args.csv_atual_name))}</code>"
    if args.date_range_atual and args.date_range_atual != "N/A":
        periodo_atual_text += f" <span style='color: var(--text-secondary-color);'>({escape(args.date_range_atual)})</span>"
    body += f"<ul><li><strong>Período Anterior:</strong> {periodo_anterior_text}</li><li><strong>Período Atual:</strong> {periodo_atual_text}</li></ul></div>"
    
    body += generate_kpis_html(teams_kpis)

    label_anterior = os.path.basename(args.csv_anterior_name)
    label_atual = os.path.basename(args.csv_atual_name)
    
    body += "<div class='card'>"
    body += generate_trend_table_html(teams_trends_df, "Análise Detalhada por Time", label_anterior, label_atual)
    body += "</div>"
    
    body += "<div class='card'>"
    body += generate_trend_table_html(problems_trends_df, "Análise Detalhada por Problema", label_anterior, label_atual)
    body += "</div>"

    final_report = HTML_TEMPLATE.format(title=title, body=body)
    output_path = "resumo_tendencia.html"
    try:
        with open(output_path, 'w', encoding='utf-8') as f:
            f.write(final_report)
        print(f"✅ Relatório de tendência aprimorado gerado em: {output_path}")
    except IOError as e:
        print(f"❌ Erro ao escrever o arquivo {output_path}: {e}")

if __name__ == "__main__":
    main()