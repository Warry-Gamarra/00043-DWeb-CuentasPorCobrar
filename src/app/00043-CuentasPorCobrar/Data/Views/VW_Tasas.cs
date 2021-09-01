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
    public class VW_Tasas
    {
        public int I_TasaUnfvID { get; set; }
        public string C_CodTasa { get; set; }
        public string T_ConceptoPagoDesc { get; set; }
        public decimal M_Monto { get; set; }
        public string T_clasificador { get; set; }
        public bool B_Habilitado { get; set; }

        public static IEnumerable<VW_Tasas> GetHabilitados()
        {
            IEnumerable<VW_Tasas> result;

            try
            {
                string s_command = "select t.* from dbo.VW_Tasas t where t.B_Habilitado = 1";

                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    result = _dbConnection.Query<VW_Tasas>(s_command, commandType: CommandType.Text);
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
