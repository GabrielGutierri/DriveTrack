# DriveTrack API 

Esse repositório se trata de uma aplicação ASP .NET Core API para auxílio da funcionalidade de histórico do aplicativo. A aplicação foi criada para tirar a necessidade do processamento dos dados históricos pelo aplicativo, de modo a separá-lo em um ambiente
isolado.

Essa aplicação se utiliza do protocolo HTTPS e foi publicada na plataforma Microsoft Azure

## ✅ Funcionalidades

- Consulta de dados ao componente `STH-Comet` do `FIWARE Descomplicado`
- Buscar um resumo de todas as corridas de um usuário, separando o intervalo da corrida
- A partir do intervalo de cada corrida, calcular os valores médios de rpm e velocidade, bem como o seu início e fim