#!/bin/bash
set -e

# =============================================================================
# Script Orquestrador para Análise de Alertas e Tendências
#
# Versão consolidada que automatiza todo o fluxo.
# 1. Identifica os arquivos .csv de entrada no diretório.
# 2. Se houver 1 arquivo, executa uma análise simples.
# 3. Se houver 2 ou mais, compara os dois mais recentes e gera um relatório
#    de tendência, otimizando a geração de artefatos.
#
# Uso: ./gerar_relatorio_completo.sh
# =============================================================================

# --- Função de Análise Completa ---
run_full_analysis() {
  local INPUT_FILE=$1
  local OUTPUT_DIR=$2

  echo -e "\n---\n⚙️  Executando análise completa para: ${INPUT_FILE}"

  # Define os caminhos completos para os arquivos de saída
  local OUTPUT_JSON="${OUTPUT_DIR}/resumo_problemas.json"
  local OUTPUT_SUMMARY="${OUTPUT_DIR}/resumo_geral.html"
  local OUTPUT_ACTUATION="${OUTPUT_DIR}/atuar.csv"
  local OUTPUT_OK="${OUTPUT_DIR}/tudo-ok.csv"
  local PLAN_DIR="${OUTPUT_DIR}/planos_por_time"

  # Executa o script de análise em modo completo
  .venv/bin/python3 analisar_alertas.py "${INPUT_FILE}" \
      --output-json "${OUTPUT_JSON}" \
      --output-summary "${OUTPUT_SUMMARY}" \
      --output-actuation "${OUTPUT_ACTUATION}" \
      --output-ok "${OUTPUT_OK}" \
      --plan-dir "${PLAN_DIR}"
  
  echo "   -> Análise completa de '${INPUT_FILE}' concluída."
}

# --- Função de Análise Apenas Resumo ---
run_summary_only_analysis() {
  local INPUT_FILE=$1
  local OUTPUT_DIR=$2

  echo -e "\n---\n⚙️  Executando análise otimizada (apenas resumo) para: ${INPUT_FILE}"

  # Define o caminho para o arquivo de saída JSON
  local OUTPUT_JSON="${OUTPUT_DIR}/resumo_problemas.json"

  # Executa o script de análise em modo resumo
  .venv/bin/python3 analisar_alertas.py "${INPUT_FILE}" \
      --output-json "${OUTPUT_JSON}" \
      --resumo-only
  
  echo "   -> Análise otimizada de '${INPUT_FILE}' concluída."
}


# =============================================================================
# --- Lógica Principal do Orquestrador ---
# =============================================================================

echo "🔎 Procurando por arquivos de alerta (.csv) no diretório atual..."

# Lista todos os .csv, ignorando os de resultado, e ordena por data (mais recente primeiro)
INPUT_FILES=($(ls -t *.csv 2>/dev/null | grep -v -e 'atuar.csv' -e 'tudo-ok.csv' || true))
FILE_COUNT=${#INPUT_FILES[@]}

echo "✅ Encontrado(s) ${FILE_COUNT} arquivo(s) de dados."

if [ "${FILE_COUNT}" -eq 0 ]; then
  echo "❌ Erro: Nenhum arquivo .csv de entrada encontrado. Abortando."
  exit 1
fi

# --- Preparação do Ambiente ---
if [ ! -d ".venv" ]; then
  echo "   -> Criando ambiente virtual .venv pela primeira vez..."
  python3 -m venv .venv
fi

echo "   -> Verificando e instalando dependências..."
.venv/bin/pip install --upgrade pip -q
.venv/bin/pip install pandas -q


# --- Execução da Análise ---

# Caso 1: Apenas um arquivo. Análise simples.
if [ "${FILE_COUNT}" -eq 1 ]; then
  FILE_ATUAL=${INPUT_FILES[0]}
  echo "\n1️⃣ Apenas um arquivo encontrado. Executando análise simples."
  
  FILENAME_BASE=$(basename "${FILE_ATUAL}" .csv)
  OUTPUT_DIR="resultados-${FILENAME_BASE}"
  
  if [ -d "${OUTPUT_DIR}" ]; then
    mv "${OUTPUT_DIR}" "${OUTPUT_DIR}.bkp-$(date +%Y%m%d-%H%M%S)"
  fi
  mkdir -p "${OUTPUT_DIR}"

  run_full_analysis "${FILE_ATUAL}" "${OUTPUT_DIR}"
  
  RESUMO_FILE="${OUTPUT_DIR}/resumo_geral.html"
  echo "\n🔔 Adicionando nota sobre análise de tendência ao resumo..."
  echo -e '\n<hr><p style="font-style: italic; color: #555;">Nota: A análise de tendência será gerada na próxima execução quando um novo arquivo de dados estiver disponível para comparação.</p>' >> "${RESUMO_FILE}"
  
  echo "\n🎉 Processo concluído. O resultado está em: ${OUTPUT_DIR}/"
  exit 0
fi

# Caso 2: Dois ou mais arquivos. Análise comparativa.
if [ "${FILE_COUNT}" -ge 2 ]; then
  CANDIDATE_1=${INPUT_FILES[0]}
  CANDIDATE_2=${INPUT_FILES[1]}

  echo "\n2️⃣ Dois ou mais arquivos encontrados. Verificando o conteúdo para definir a ordem cronológica..."

  DATE_1=$(.venv/bin/python3 get_max_date.py "${CANDIDATE_1}")
  DATE_2=$(.venv/bin/python3 get_max_date.py "${CANDIDATE_2}")

  if [[ "$DATE_1" > "$DATE_2" ]]; then
    FILE_ATUAL=${CANDIDATE_1}
    FILE_ANTERIOR=${CANDIDATE_2}
  else
    FILE_ATUAL=${CANDIDATE_2}
    FILE_ANTERIOR=${CANDIDATE_1}
  fi
  
  echo "   - Período Atual (mais recente):    ${FILE_ATUAL}"
  echo "   - Período Anterior (mais antigo): ${FILE_ANTERIOR}"

  # Define os diretórios de saída
  DIR_ANTERIOR="resultados-$(basename "${FILE_ANTERIOR}" .csv)"
  DIR_ATUAL="resultados-$(basename "${FILE_ATUAL}" .csv)"

  # Limpa e cria os diretórios
  rm -rf "${DIR_ANTERIOR}" "${DIR_ATUAL}"
  mkdir -p "${DIR_ANTERIOR}" "${DIR_ATUAL}"

  # Executa as análises: otimizada para o anterior, completa para o atual
  run_summary_only_analysis "${FILE_ANTERIOR}" "${DIR_ANTERIOR}"
  run_full_analysis "${FILE_ATUAL}" "${DIR_ATUAL}"

  # Coleta os intervalos de datas para os relatórios
  echo -e "\n---\n🗓️  Coletando intervalos de datas dos arquivos CSV..."
  DATE_RANGE_ANTERIOR=$(.venv/bin/python3 get_date_range.py "${FILE_ANTERIOR}")
  DATE_RANGE_ATUAL=$(.venv/bin/python3 get_date_range.py "${FILE_ATUAL}")
  echo "   - Intervalo Anterior: ${DATE_RANGE_ANTERIOR}"
  echo "   - Intervalo Atual:    ${DATE_RANGE_ATUAL}"

  # Executa a análise de tendência usando os arquivos JSON e os novos intervalos de data
  echo -e "\n---\n📊 Gerando relatório de tendência..."
  .venv/bin/python3 analise_tendencia.py \
    "${DIR_ANTERIOR}/resumo_problemas.json" \
    "${DIR_ATUAL}/resumo_problemas.json" \
    "${FILE_ANTERIOR}" \
    "${FILE_ATUAL}" \
    "${DATE_RANGE_ANTERIOR}" \
    "${DATE_RANGE_ATUAL}"

  # --- Consolidação dos Resultados ---
  FINAL_DIR="analise-comparativa-$(date +%Y%m%d-%H%M%S)"
  echo "\n📂 Consolidando todos os artefatos em: ${FINAL_DIR}"
  mkdir -p "${FINAL_DIR}"
  
  # Move os principais artefatos para o diretório final
  mv resumo_tendencia.html "${FINAL_DIR}/"
  # Move o diretório de resultados do período atual para dentro do consolidado
  mv "${DIR_ATUAL}" "${FINAL_DIR}/periodo_atual_detalhes"
  # Move apenas o resumo JSON do período anterior para o consolidado
  mkdir -p "${FINAL_DIR}/periodo_anterior_detalhes"
  mv "${DIR_ANTERIOR}/resumo_problemas.json" "${FINAL_DIR}/periodo_anterior_detalhes/"
  # Remove o diretório temporário do período anterior
  rm -rf "${DIR_ANTERIOR}"

  echo "\n🎉 Análise comparativa concluída!"
  echo "   O relatório de tendência e todos os detalhes foram salvos em: ${FINAL_DIR}/"
  exit 0
fi