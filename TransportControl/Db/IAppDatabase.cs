using System.Collections.Generic;
using System.Threading.Tasks;
using TransportControl.Models;

namespace TransportControl.Db
{
    public interface IAppDatabase
    {
        Task Create();
        Task Insert(Line line);
        Task<IEnumerable<Line>> GetAll();
    }
}
