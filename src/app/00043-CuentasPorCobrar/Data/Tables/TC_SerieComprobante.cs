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
    public class TC_SerieComprobante
    {
        public int I_SerieID { get; set; }

        public int I_NumeroSerie { get; set; }

        public int I_FinNumeroComprobante { get; set; }

        public int I_DiasAnterioresPermitido { get; set; }

        public bool B_Habilitado { get; set; }

        public static IEnumerable<TC_SerieComprobante> GetAll()
        {
            IEnumerable<TC_SerieComprobante> result;

            try
            {
                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    var s_command = "SELECT * FROM dbo.TC_SerieComprobante;";

                    result = _dbConnection.Query<TC_SerieComprobante>(s_command, commandType: CommandType.Text);
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
