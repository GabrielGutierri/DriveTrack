using DriveTrackAPI.Model;
using Microsoft.AspNetCore.Mvc;
using Newtonsoft.Json;
using System.Collections.Concurrent;
using System.Net.Http;

namespace DriveTrackAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class HistoricoCorridasController : ControllerBase
    {
        private static readonly string IPFiware = "20.62.95.153";
        private readonly HttpClient httpClient;

        public HistoricoCorridasController(HttpClient client)
        {
            httpClient = client;
        }

        [HttpGet("Health")]
        public async Task<IActionResult> Health()
        {
            return Ok("Caminho da controller OK");
        }

        [HttpGet("")]
        public async Task<IActionResult> BuscaCorridasEntidade([FromQuery]string nomeCarro, [FromQuery] string placaCarro)
        {
            string entidade = $"urn:ngsi-ld:{nomeCarro}:{placaCarro}";
            var corridas = await ProcessarCorridasAsync(entidade);
            return Ok(corridas);
        }

        private async Task<List<CorridaResumo>> ProcessarCorridasAsync(string entidadeId)
        {
            var dadosCorrida = await BuscarTodosIdsCorrida(entidadeId);

            var resultados = new List<CorridaResumo>();

            foreach (var corrida in dadosCorrida)
            {
                var dados = await ConsultarValoresNoIntervalo(entidadeId, corrida);
                resultados.Add(dados);
            }
            return resultados.ToList();
        }

        private async Task<List<DadosIdCorrida>> BuscarTodosIdsCorrida(string entidadeId)
        {
            var valores = await ObterTodosOsValores(entidadeId, "idCorrida");
            var agrupado = valores
                .GroupBy(v => v.AttrValue)
                .Select(g => new DadosIdCorrida
                {
                    IDCorrida = g.Key,
                    Inicio = g.Min(v => DateTime.Parse(v.RecvTime, null, System.Globalization.DateTimeStyles.AdjustToUniversal | System.Globalization.DateTimeStyles.AssumeUniversal)),
                    Fim = g.Max(v => DateTime.Parse(v.RecvTime, null, System.Globalization.DateTimeStyles.AdjustToUniversal | System.Globalization.DateTimeStyles.AssumeUniversal))
                })
                .ToList();

            return agrupado;
        }
        
        private async Task<CorridaResumo> ConsultarValoresNoIntervalo(string entidadeId, DadosIdCorrida dadosIdCorrida)
        {
            var valoresVelocidade = await ObterTodosOsValores(entidadeId, "velocidade", dadosIdCorrida.Inicio, dadosIdCorrida.Fim);
            var valoresRPM = await ObterTodosOsValores(entidadeId, "rpm", dadosIdCorrida.Inicio, dadosIdCorrida.Fim);
            var valoresData = await ObterTodosOsValores(entidadeId, "dataColetaDados", dadosIdCorrida.Inicio, dadosIdCorrida.Fim);

            var velocidades = valoresVelocidade.Select(v => double.TryParse(v.AttrValue, System.Globalization.NumberStyles.Any, System.Globalization.CultureInfo.InvariantCulture, out var val) ? val : 0.0)
                .Where(v => v > 0).ToList();

            var rpms = valoresRPM.Select(v => double.TryParse(v.AttrValue, System.Globalization.NumberStyles.Any, System.Globalization.CultureInfo.InvariantCulture, out var val) ? val : 0.0)
                .Where(v => v > 0).ToList();

            var datas = valoresData.Select(v => DateTime.Parse(v.AttrValue)).ToList();
            return new CorridaResumo
            {
                IdCorrida = dadosIdCorrida.IDCorrida,
                VelocidadeMaxima = velocidades.Max(),
                VelocidadeMinima = velocidades.Min(),
                VelocidadeMedia = velocidades.Average(),
                RPMMaximo = rpms.Max(),
                RPMMinimo = rpms.Min(),
                RPMMedio = rpms.Average(),
                DataInicio = datas.Min(),
                DataFim = datas.Max()
            };
        }

        private async Task<List<CometValue>> ObterTodosOsValores(string entidadeId, string atributo, DateTime? de = null, DateTime? ate = null)
        {
            int offset = 0, limit = 100;
            var todos = new List<CometValue>();

            while (true)
            {
                var url = $"http://{IPFiware}:8666/STH/v1/contextEntities/type/iot/id/{entidadeId}/attributes/{atributo}?hLimit={limit}&hOffset={offset}";
                if (de.HasValue && ate.HasValue)
                {
                    url += $"&dateFrom={de.Value:yyyy-MM-ddTHH:mm:ss.fffZ}&dateTo={ate.Value:yyyy-MM-ddTHH:mm:ss.fffZ}";
                }

                var request = new HttpRequestMessage(HttpMethod.Get, url);
                request.Headers.Add("fiware-service", "smart");
                request.Headers.Add("fiware-servicepath", "/");
                var response = await httpClient.SendAsync(request);
                var body = await response.Content.ReadAsStringAsync();
                var dados = JsonConvert.DeserializeObject<CometResponse>(body);

                var valores = dados?.ContextResponses?.FirstOrDefault()
                    ?.ContextElement?.Attributes?.FirstOrDefault(a => a.Name == atributo)?.Values;

                if (valores == null || !valores.Any()) break;

                todos.AddRange(valores);
                if (valores.Count < limit) break;

                offset += limit;
            }

            return todos;
        }

        public class DadosIdCorrida
        {
            public string IDCorrida { get; set; }
            public DateTime Inicio { get; set; }
            public DateTime Fim { get; set; }
        }
    }
}