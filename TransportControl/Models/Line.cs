using SQLite;
using System.Linq;

namespace TransportControl.Models
{
    public class Line
    {
        [PrimaryKey, AutoIncrement]
        public int Id { get; set; }

        [Indexed]
        public string Symbol { get; set; }

        public string Dest1 { get; set; }

        public string Dest2 { get; set; }

        public string GroupSymbol
        {
            get
            {
                if (char.IsLetter(Symbol.First())) return Symbol.First().ToString();
                else if (Symbol.Length > 2) return (int.Parse(Symbol) / 100 * 100).ToString();
                else return "1";
            }
        }

        public int Type
        {
            get
            {
                if (char.IsLetter(Symbol.First()) || int.Parse(Symbol) >= 100) return 1;
                else return 2;
            }
        }
    }
}
