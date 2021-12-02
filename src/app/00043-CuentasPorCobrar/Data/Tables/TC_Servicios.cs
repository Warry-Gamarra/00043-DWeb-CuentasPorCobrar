using Dapper;
using Data.Connection;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Data.Tables
{
    public class TC_Servicios
    {
        public int I_ServicioID { get; set; }
        public string C_CodServicio { get; set; }
        public string T_DescServ { get; set; }
        public bool B_Habilitado { get; set; }

        public static IEnumerable<TC_Servicios> GetAll()
        {
            IEnumerable<TC_Servicios> result;

            try
            {
                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    var s_command = @"SELECT * FROM TC_Servicios WHERE B_Eliminado = 0";

                    result = _dbConnection.Query<TC_Servicios>(s_command, commandType: CommandType.Text);
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
