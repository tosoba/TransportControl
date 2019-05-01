using TransportControl.Utils;
using TransportControl.Models;
using System.Collections.Generic;
using ReactiveUI;
using System.Linq;
using Xamarin.Forms;
using TransportControl.Dependencies;

namespace TransportControl.ViewModels
{
    public class ThemesViewModel : BaseViewModel
    {
        public List<Theme> Themes { get; } = new List<Theme>()
            {
                new Theme() { ThemeId = ThemeManager.ThemeType.Light, Title = "Light Theme", Description = "Gives a light theme experience" },
                new Theme() { ThemeId = ThemeManager.ThemeType.Dark, Title = "Dark Theme", Description = "Gives a dark theme experience" }
            };

        private Theme selectedTheme;
        public Theme SelectedTheme
        {
            get { return selectedTheme; }
            set
            {
                this.RaiseAndSetIfChanged(ref selectedTheme, value);
                if (selectedTheme != null)
                {
                    OnThemeSelected(selectedTheme);
                }
            }
        }

        public ThemesViewModel(IScreen hostScreen = null) : base(hostScreen)
        {
            var selectedTheme = Themes.FirstOrDefault(x => x.ThemeId == ThemeManager.CurrentTheme());
            selectedTheme.IsSelected = true;
        }

        private void OnThemeSelected(Theme selectedTheme)
        {
            foreach (var t in Themes)
            {
                t.IsSelected = t.ThemeId == selectedTheme.ThemeId;
            }
            ThemeManager.ChangeTheme(selectedTheme.ThemeId);

            if (Device.RuntimePlatform == Device.Android)
            {
                DependencyService.Get<IThemeChangedListener>().OnThemeChanged(selectedTheme.ThemeId);
            }
        }
    }
}
