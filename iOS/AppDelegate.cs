using System;
using System.Collections.Generic;
using System.Linq;

using Foundation;
using UIKit;

namespace TransportControl.iOS
{
    [Register("AppDelegate")]
    public partial class AppDelegate : global::Xamarin.Forms.Platform.iOS.FormsApplicationDelegate
    {
        public override bool FinishedLaunching(UIApplication app, NSDictionary options)
        {
            global::Xamarin.Forms.Forms.Init();
            Xamarin.FormsGoogleMaps.Init("AIzaSyD74rhwpjwqhu2X6rzZLtNmtE - NKVBKzW4"); 
            LoadApplication(new App());

            return base.FinishedLaunching(app, options);
        }
    }
}

