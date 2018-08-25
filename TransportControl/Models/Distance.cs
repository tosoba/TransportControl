namespace TransportControl.Models
{
    public class Distance
    {
        public string ValueLabel { get; set; }
        public int Value { get; set; }

        public Distance(int valueMeters)
        {
            Value = valueMeters;
            if (Value < 1000) ValueLabel = $"{Value} m";
            else ValueLabel = $"{Value / 1000} km";
        }

        public Distance(Distance other)
        {
            Value = other.Value;
            ValueLabel = other.ValueLabel;
        }
    }
}
