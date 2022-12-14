using TransportControl.Utils;

namespace TransportControl.Models
{
    public class Theme : ObservableObject
    {
        public ThemeManager.ThemeType ThemeId { get; set; }
        public string Title { get; set; }
        public string Description { get; set; }
        bool _isSelected = false;
        public bool IsSelected
        {
            get { return _isSelected; }
            set { SetProperty(ref _isSelected, value); }
        }
    }
}
