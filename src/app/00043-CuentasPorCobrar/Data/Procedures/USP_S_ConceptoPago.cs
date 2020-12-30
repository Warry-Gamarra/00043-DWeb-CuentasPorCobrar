using Dapper;
using Data.Connection;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Data.Procedures
{
    public class USP_S_ConceptoPago
    {
        public int I_ConcPagID { get; set; }
        public string T_ConceptoDesc { get; set; }
        public int I_Anio { get; set; }
        public int I_Periodo { get; set; }
        public decimal M_Monto { get; set; }
        
        public static List<USP_S_ConceptoPago> Execute()
        {
            List<USP_S_ConceptoPago> result;

            try
            {
                string s_command = @"USP_S_ConceptoPago";

                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    result = _dbConnection.Query<USP_S_ConceptoPago>(s_command, commandType: CommandType.StoredProcedure).ToList();
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
