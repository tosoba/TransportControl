using System;

namespace TransportControl.Utils
{
    public static class Interpolator
    {
        public static float GetInterpolation(float input) => (float)(Math.Cos((input + 1) * Math.PI) / 2.0f) + 0.5f;
    }
}
