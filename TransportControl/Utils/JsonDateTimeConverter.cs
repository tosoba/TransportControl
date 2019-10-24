using Newtonsoft.Json.Converters;

namespace TransportControl.Utils
{
    public class JsonDateTimeConverter : IsoDateTimeConverter
    {
        public JsonDateTimeConverter(string format)
        {
            DateTimeFormat = format;
        }
    }
}
