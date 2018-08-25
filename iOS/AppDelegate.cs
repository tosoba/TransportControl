using Foundation;
using ImageCircle.Forms.Plugin.iOS;
using UIKit;

namespace TransportControl.iOS
{
    [Register("AppDelegate")]
    public partial class AppDelegate : global::Xamarin.Forms.Platform.iOS.FormsApplicationDelegate
    {
        public override bool FinishedLaunching(UIApplication app, NSDictionary options)
        {
            global::Xamarin.Forms.Forms.Init();
            Xamarin.FormsGoogleMaps.Init(Keys.GOOGLE_MAPS_IOS_API_KEY); 
            LoadApplication(new App());
            ImageCircleRenderer.Init();

            return base.FinishedLaunching(app, options);
        }
    }
}

