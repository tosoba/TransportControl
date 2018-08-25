using System.Linq;
using System.Collections.ObjectModel;
using TransportControl.Models;
using Newtonsoft.Json.Linq;

namespace TransportControl.List
{
    public static class LineHelper
    {
        public static ObservableCollection<Grouping<string, Line>> LinesGrouped { get; set; }

        public static ObservableCollection<Line> Lines { get; set; }

        static LineHelper()
        {
            var lineLoader = new Loader();
            var jLines = lineLoader.LoadLines();
            AddLines(jLines);
            GroupCollections(Lines);
        }

        public static void Filter(string filter)
        {
            var filteredLines = new ObservableCollection<Line>();
            if (string.IsNullOrEmpty(filter))
            {
                GroupCollections(Lines);
            }
            else
            {
                foreach (var line in Lines)
                {
                    if (line.Symbol.ToLower().Contains(filter.ToLower()))
                    {
                        filteredLines.Add(line);
                    }
                }
                GroupCollections(filteredLines);
            }
        }

        public static Line FindBy(string symbol) => Lines.Where(l => l.Symbol == symbol).FirstOrDefault();

        private static void GroupCollections(ObservableCollection<Line> toBeGrouped)
        {
            LinesGrouped?.Clear();

            var sorted = from line in toBeGrouped
                         orderby line.Symbol
                         group line by line.SymbolSort into lineGroup
                         select new Grouping<string, Line>(lineGroup.Key, lineGroup);

            var first = sorted.First()
                .OrderBy(l => int.Parse(l.Symbol))
                .GroupBy(l => l.SymbolSort)
                .Select(g => new Grouping<string, Line>(g.Key, g));
            var rest = sorted.Skip(1); 

            LinesGrouped = new ObservableCollection<Grouping<string, Line>>(first.Concat(rest));
        }

        private static void AddLines(JArray jLines)
        {
            Lines = new ObservableCollection<Line>();

            foreach (var jLine in jLines)
            {
                Lines.Add(new Line
                {
                    Symbol = jLine.Value<string>("Symbol"),
                    Dest1 = jLine.Value<string>("Dest1"),
                    Dest2 = jLine.Value<string>("Dest2")
                });
            }
        }
    }
}
