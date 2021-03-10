using Dapper;
using Data.Connection;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Data.Views
{
    public class VW_Facultades
    {
        public string C_CodFac { get; set; }
        public string T_FacDesc { get; set; }

        public static IEnumerable<VW_Facultades> GetAll()
        {
            IEnumerable<VW_Facultades> result;

            try
            {
                string s_command = @"SELECT * FROM dbo.VW_Facultades";

                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    result = _dbConnection.Query<VW_Facultades>(s_command, commandType: CommandType.Text);
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }

            return result;
        }
    }
}
