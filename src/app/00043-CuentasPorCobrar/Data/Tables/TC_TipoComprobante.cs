using Dapper;
using Data.Connection;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Data.Tables
{
    public class TC_TipoComprobante
    {
        public int I_TipoComprobanteID { get; set; }

        public string C_TipoComprobanteCod { get; set; }

        public string T_TipoComprobanteDesc { get; set; }

        public bool B_Habilitado { get; set; }
        
        public static IEnumerable<TC_TipoComprobante> GetAll()
        {
            IEnumerable<TC_TipoComprobante> result;

            try
            {
                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    var s_command = "SELECT * FROM dbo.TC_TipoComprobante;";

                    result = _dbConnection.Query<TC_TipoComprobante>(s_command, commandType: CommandType.Text);
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
