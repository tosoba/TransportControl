using System;
using Plugin.Settings;
using TransportControl.Events;
using TransportControl.Themes;
using Xamarin.Forms;

namespace TransportControl.Utils
{
    public static class ThemeManager
    {
        public enum ThemeType
        {
            Light,
            Dark
        }

        public static event EventHandler<ThemeChangedEventArgs> OnThemeChanged;

        public static void ChangeTheme(ThemeType theme)
        {
            var mergedDictionaries = Application.Current.Resources.MergedDictionaries;
            if (mergedDictionaries != null)
            {
                mergedDictionaries.Clear();

                CrossSettings.Current.AddOrUpdateValue("SelectedTheme", (int)theme);

                switch (theme)
                {
                    case ThemeType.Light:
                        {
                            mergedDictionaries.Add(new LightTheme());
                            break;
                        }
                    case ThemeType.Dark:
                        {
                            mergedDictionaries.Add(new DarkTheme());
                            break;
                        }
                    default:
                        mergedDictionaries.Add(new LightTheme());
                        break;
                }

                OnThemeChanged?.Invoke(new object(), new ThemeChangedEventArgs(theme));
            }
        }

        public static void ToggleTheme()
        {
            ChangeTheme(CurrentTheme == ThemeType.Light ? ThemeType.Dark : ThemeType.Light);
        }

        public static void LoadTheme()
        {
            ChangeTheme(CurrentTheme);
        }

        public static ThemeType CurrentTheme => (ThemeType)CrossSettings.Current.GetValueOrDefault("SelectedTheme", (int)ThemeType.Light);
    }
}
