
import pandas as pd
import sys

def get_max_date(filepath: str):
    """
    Lê um arquivo CSV, encontra a data mais recente na coluna 'sys_created_on'
    e a imprime no formato ISO.
    """
    try:
        df = pd.read_csv(filepath, usecols=['sys_created_on'], encoding="utf-8-sig", sep=None, engine='python')
        # Converte para datetime, coagindo erros para NaT (Not a Time)
        datetimes = pd.to_datetime(df['sys_created_on'], errors='coerce', format='mixed')
        # Remove valores NaT e encontra o máximo
        max_date = datetimes.dropna().max()
        if pd.notna(max_date):
            print(max_date.isoformat())
        else:
            # Se não houver datas válidas, imprime uma data mínima para garantir que seja considerado o mais antigo
            print("1970-01-01T00:00:00")
    except (FileNotFoundError, ValueError, KeyError) as e:
        # Em caso de erro (arquivo não encontrado, coluna ausente, etc.), imprime data mínima
        print("1970-01-01T00:00:00", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Uso: python get_max_date.py <caminho_para_o_csv>", file=sys.stderr)
        sys.exit(1)
    get_max_date(sys.argv[1])
