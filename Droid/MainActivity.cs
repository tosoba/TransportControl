using Acr.UserDialogs;
using Android.App;
using Android.Content.PM;
using Android.OS;
using ImageCircle.Forms.Plugin.Droid;
using Plugin.CurrentActivity;
using Plugin.Permissions;
using Rg.Plugins.Popup;
using TransportControl.Utils;
using Xamarin;
using Xamarin.Forms;
using Xamarin.Forms.Platform.Android;

namespace TransportControl.Droid
{
    [Activity(Label = "TransportControl.Droid", Icon = "@drawable/icon", Theme = "@style/lightAppTheme", MainLauncher = true, ConfigurationChanges = ConfigChanges.ScreenSize | ConfigChanges.Orientation)]
    public class MainActivity : FormsAppCompatActivity
    {
        protected override void OnCreate(Bundle bundle)
        {
            TabLayoutResource = Resource.Layout.Tabbar;
            ToolbarResource = Resource.Layout.Toolbar;

            InitTheme();

            base.OnCreate(bundle);

            Popup.Init(this, bundle);
            Forms.Init(this, bundle);

            FormsGoogleMaps.Init(this, bundle);
            UserDialogs.Init(this);
            ImageCircleRenderer.Init();

            CrossCurrentActivity.Current.Init(this, bundle);

            LoadApplication(new App());
        }

        public override void OnRequestPermissionsResult(int requestCode, string[] permissions, Permission[] grantResults)
        {
            base.OnRequestPermissionsResult(requestCode, permissions, grantResults);
            PermissionsImplementation.Current.OnRequestPermissionsResult(requestCode, permissions, grantResults);
        }

        public override void OnBackPressed()
        {
            Popup.SendBackPressed(base.OnBackPressed);
        }

        private void InitTheme()
        {
            switch (ThemeManager.CurrentTheme)
            {
                case ThemeManager.ThemeType.Light:
                    {
                        SetTheme(Resource.Style.lightAppTheme);
                        break;
                    }
                case ThemeManager.ThemeType.Dark:
                    {
                        SetTheme(Resource.Style.darkAppTheme);
                        break;
                    }
                default:
                    SetTheme(Resource.Style.lightAppTheme);
                    break;
            }
        }
    }
}
