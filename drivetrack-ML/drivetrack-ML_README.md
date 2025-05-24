# drivetrack-ML

Esta pasta contém notebooks e arquivos relacionados ao processamento de dados, geração de targets e aplicação de técnicas de Machine Learning para o projeto DriveTrack.

## Conteúdo da pasta

- **`analise_dados.ipynb`**  
  Notebook Jupyter destinado à análise exploratória dos dados, visualização e estatísticas descritivas. Apresenta todos os passos para a leitura, tratamento, geração de critérios, treinamento de modelos de machine learning e de geração de gráfico com a classificação final.

- **`classificacao.ipynb`**  
  Versão simplificada do Notebook Jupyter "analise_dados.ipynb". Com o objetivo principal de classificar uma corrida. É necessário utilizar o modelo treinado no script anterior

- **`geracao_target.ipynb`**  
  Notebook Jupyter responsável por tentar identificar um target utilizando um caminho não supervisionado. Foco principal em analise das informações, e se a partir delas existia um target. Precisa utilizar um arquivo excel, que é gerado no script "analise_dados.ipynb".

## Como utilizar

1. **Pré-requisitos**  
   Recomenda-se ter o Python instalado, além do Jupyter Notebook e bibliotecas comuns para ciência de dados como:
   - pandas
   - numpy
   - scikit-learn
   - matplotlib / seaborn

   Instale os pacotes necessários com:
   ```bash
   pip install -r requirements.txt
   ```
   > *Se não houver um `requirements.txt`, verifique nos primeiros blocos dos notebooks quais bibliotecas são importadas.*

2. **Execução dos notebooks**  
   Abra os notebooks usando o Jupyter:
   ```bash
   jupyter notebook
   ```
   Em seguida, navegue até a pasta `drivetrack-ML` e selecione o notebook desejado.

## Observações

- Os notebooks provavelmente utilizam datasets que podem estar em outras partes do repositório ou precisam ser baixados separadamente.
- É necessário configurar um ambiente FIWARE, da onde os dados são provenientes
- É necessário ter uma conta no Google Cloud, e Microsoft Azure para a utilização de APIs. Após gerar a conta é preciso configurar uma chave para cada serviço.

