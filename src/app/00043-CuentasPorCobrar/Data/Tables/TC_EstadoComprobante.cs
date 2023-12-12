using Data.Connection;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Dapper;

namespace Data.Tables
{
    public class TC_EstadoComprobante
    {
        public int I_EstadoComprobanteID { get; set; }

        public string C_EstadoComprobanteCod { get; set; }

        public string T_EstadoComprobanteDesc { get; set; }

        public bool B_Habilitado { get; set; }

        public static IEnumerable<TC_EstadoComprobante> GetAll()
        {
            IEnumerable<TC_EstadoComprobante> result;

            try
            {
                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    var s_command = "SELECT * FROM dbo.TC_EstadoComprobante;";

                    result = _dbConnection.Query<TC_EstadoComprobante>(s_command, commandType: CommandType.Text);
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
