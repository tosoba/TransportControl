using System.Collections.Generic;
using System.Collections.ObjectModel;

namespace TransportControl.List
{
    public class GroupedObservableCollection<K, T> : ObservableCollection<T>
    {
        public K Key { get; private set; }

        public GroupedObservableCollection(K key, IEnumerable<T> items)
        {
            Key = key;
            foreach (var item in items)
                Items.Add(item);
        }
    }
}
