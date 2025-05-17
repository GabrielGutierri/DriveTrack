namespace DriveTrackAPI.Model
{
    public class CorridaResumo
    {
        public string IdCorrida { get; set; }
        public double VelocidadeMaxima { get; set; }
        public double VelocidadeMinima { get; set; }
        public double VelocidadeMedia { get; set; }
        public double RPMMaximo { get; set; }
        public double RPMMinimo { get; set; }
        public double RPMMedio{ get; set; }

        public DateTime DataInicio { get; set; }
        public DateTime DataFim { get; set; }
    }
}
