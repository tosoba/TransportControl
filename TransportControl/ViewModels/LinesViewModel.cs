using System.Collections.ObjectModel;
using TransportControl.List;
using TransportControl.Models;

namespace TransportControl.ViewModels
{
    public class LinesViewModel
    {
        public ObservableCollection<Line> Lines { get; set; }
        public ObservableCollection<Grouping<string, Line>> LinesGrouped { get; set; }

        public LinesViewModel()
        {
            Lines = LineHelper.Lines;
            LinesGrouped = LineHelper.LinesGrouped;
        }

        public int LineCount => Lines.Count;
    }
}
