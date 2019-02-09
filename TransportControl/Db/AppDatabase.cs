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

        private async Task CreateIfNeeded()
        {
            if (!tableCreated)
            {
                await Connection.CreateTableAsync<Line>();
                tableCreated = true;
            }
        }

        public async Task<bool> Insert(Line line)
        {
            await CreateIfNeeded();
            var query = Connection.Table<Line>().Where(l => l.Symbol == line.Symbol);
            var result = await query.ToListAsync();

            if (!result.Any())
            {
                await Connection.InsertAsync(line);
                return true;
            }
            return false;
        }

        public async Task<IEnumerable<Line>> GetAll()
        {
            await CreateIfNeeded();
            return await Connection.Table<Line>().ToListAsync();
        }

        public async Task Delete(Line line)
        {
            await CreateIfNeeded();
            await Connection.DeleteAsync(line);
        }
    }
}
