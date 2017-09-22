namespace TransportControl.Models
{
    public class Line
    {
        public string Symbol { get; set; }
        public string Dest1 { get; set; }
        public string Dest2 { get; set; }

        public string SymbolSort => Symbol[0].ToString();
    }
}
