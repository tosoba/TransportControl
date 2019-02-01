using System;
using Xamarin.Forms.GoogleMaps;

namespace TransportControl.Events
{
    public interface IBoundsCalculatedHandler
    {
        event EventHandler<BoundsCalculatedEventArgs> OnBoundsCalculated;
    }

    public class BoundsCalculatedEventArgs : EventArgs
    {
        public Bounds Bounds { get; }

        public BoundsCalculatedEventArgs(Bounds bounds)
        {
            Bounds = bounds;
        }
    }
}
