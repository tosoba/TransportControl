using TransportControl.Utils;

namespace TransportControl.Dependencies
{
    public interface IThemeChangedListener
    {
        void OnThemeChanged(ThemeManager.ThemeType theme);
    }
}
