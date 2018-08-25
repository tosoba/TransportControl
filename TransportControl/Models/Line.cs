using System.Linq;

namespace TransportControl.Models
{
    public class Line
    {
        public string Symbol { get; set; }
        public string Dest1 { get; set; }
        public string Dest2 { get; set; }

        public string SymbolSort
        {
            get
            {
                if (char.IsLetter(Symbol.First())) return Symbol.First().ToString();
                else if (Symbol.First() == 'Z') return "Z";
                else if (Symbol.Length > 2) return (int.Parse(Symbol) / 100 * 100).ToString();
                else return "1";
            }
        }
    }
}
