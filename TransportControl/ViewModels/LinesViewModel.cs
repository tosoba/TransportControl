using System.Collections.ObjectModel;
using System.Windows.Input;
using TransportControl.List;
using TransportControl.Models;

namespace TransportControl.ViewModels
{
    public class LinesViewModel
    {
        public ObservableCollection<Line> Lines { get; set; }
        public ObservableCollection<Grouping<string, Line>> LinesGrouped { get; set; }

        public ICommand ButtonLineNumbersClickedCommand { get; }

        public LinesViewModel()
        {
            Lines = LineHelper.Lines;
            LinesGrouped = LineHelper.LinesGrouped;
        }

        public int LineCount => Lines.Count;
    }
}
