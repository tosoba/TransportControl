using SQLite;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Threading.Tasks;
using TransportControl.Models;

namespace TransportControl.Db
{
    public class AppDatabase : IAppDatabase
    {
        private readonly string databasePath = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.MyDocuments), "TransportControl.db");

        private bool tableCreated = false;

        public SQLiteAsyncConnection Connection => new SQLiteAsyncConnection(databasePath);

        public async Task Create()
        {
            if (!tableCreated)
            {
                await Connection.CreateTableAsync<Line>();
                tableCreated = true;
            }
        }

        public async Task Insert(Line line)
        {
            var query = Connection.Table<Line>().Where(l => l.Symbol == line.Symbol);
            var result = await query.ToListAsync();

            if (!result.Any())
                await Connection.InsertAsync(line);
        }

        public async Task<IEnumerable<Line>> GetAll() => await Connection.Table<Line>().ToListAsync();
    }
}
