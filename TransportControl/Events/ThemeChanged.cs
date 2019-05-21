using System;
using static TransportControl.Utils.ThemeManager;

namespace TransportControl.Events
{
    public interface IThemeChangedHandler
    {
        event EventHandler<ThemeChangedEventArgs> OnThemeChanged;
    }

    public class ThemeChangedEventArgs : EventArgs
    {
        public ThemeType ThemeType;
        public ThemeChangedEventArgs(ThemeType themeType)
        {
            ThemeType = themeType;
        }
    }
}
