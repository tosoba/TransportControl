using Foundation;
using ImageCircle.Forms.Plugin.iOS;
using UIKit;

namespace TransportControl.iOS
{
    [Register("AppDelegate")]
    public partial class AppDelegate : Xamarin.Forms.Platform.iOS.FormsApplicationDelegate
    {
        public override bool FinishedLaunching(UIApplication app, NSDictionary options)
        {
            Xamarin.Forms.Forms.Init();
            Xamarin.FormsGoogleMaps.Init(Keys.GOOGLE_MAPS_IOS_API_KEY);
            ImageCircleRenderer.Init();

            LoadApplication(new App());

            return base.FinishedLaunching(app, options);
        }
    }
}

