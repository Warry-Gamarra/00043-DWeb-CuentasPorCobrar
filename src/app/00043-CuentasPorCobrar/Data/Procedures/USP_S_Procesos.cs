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
    public class USP_S_Procesos
    {
        public int I_ProcesoID { get; set; }
        public string T_CatPagoDesc { get; set; }
        public short? I_Anio { get; set; }
        public DateTime? D_FecVencto { get; set; }
        public short? I_Prioridad { get; set; }

        public static List<USP_S_Procesos> Execute()
        {
            List<USP_S_Procesos> result;

            try
            {
                string s_command = @"USP_S_Procesos";

                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    result = _dbConnection.Query<USP_S_Procesos>(s_command, commandType: CommandType.StoredProcedure).ToList(); 
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
