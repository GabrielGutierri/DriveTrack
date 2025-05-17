# DriveTrack

O presente repositório apresenta o DriveTrack, um sistema de monitoramento e classificação de condutores. O objetivo dele é classificar trechos de circuitos em duas classes: agressivo e normal. Os dados para essa classificação são enviados a uma instância do FIWARE e a classificação foi realizada a partir de algoritmos de Machine Learning.


## 📁 Estrutura do Repositório

Este repositório é organizado em três módulos principais:

- **`drivetrack-app/`**  
  Contém o código-fonte do aplicativo mobile responsável pela coleta e visualização dos dados.

- **`drivetrack-ML/`**  
  Abriga os notebooks e scripts de pré-processamento, tratamento de dados e treinamento dos modelos de machine learning.

- **`drivetrack-API/`**  
  API desenvolvida para fornecer os dados históricos de classificação para o app.

Cada pasta possui seu próprio `README.md` com informações detalhadas sobre configuração e execução.

## ⚙️ Pré-requisitos

Para executar o projeto corretamente, certifique-se de ter os seguintes componentes configurados:

- Uma máquina virtual (ou ambiente compatível) com o **FIWARE Descomplicado**. Para o trabalho foi usado o Ubuntu Server 24.04 LTS, com 1GB RAM, e instanciado na Azure.
- Configuração de entidades no **Orion Context Broker** para representar os condutores. Para que a entidade seja compatível com o aplicativo, o seu tipo deve ser **iot** e a sua identificação deve conter o seguinte formato: `urn:ngsi-ld:{nome do carro}:{placa do carro}`
- Criação de notificações no **STH-Comet** para armazenar os dados históricos dos trajetos. Uma notificação deve ser associada a sua respectiva entidade criada no Orion.

## 👨‍💻 Desenvolvedores
- Gabriel Gutierri da Costa
- Gabriel Foramilio Araujo
- José Honório Junior
- Vinícius Afonso dos Santos
