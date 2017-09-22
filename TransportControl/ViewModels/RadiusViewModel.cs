using System.Collections.ObjectModel;
using TransportControl.Models;

namespace TransportControl.ViewModels
{
    public class RadiusViewModel
    {
        public ObservableCollection<Distance> Radiuses { get; set; } = new ObservableCollection<Distance>
        {
            new Distance(100),
            new Distance(250),
            new Distance(500),
            new Distance(1000),
            new Distance(2000),
            new Distance(5000),
            new Distance(10000)
        };
    }
}
