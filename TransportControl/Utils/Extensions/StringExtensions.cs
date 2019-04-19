using System.IO;
using System.Reflection;

namespace TransportControl.Utils.Extensions
{
    public static class StringExtensions
    {
        public static Stream ResourceStream(this string path) => IntrospectionExtensions.GetTypeInfo(typeof(App))
            .Assembly
            .GetManifestResourceStream(path);
    }
}
