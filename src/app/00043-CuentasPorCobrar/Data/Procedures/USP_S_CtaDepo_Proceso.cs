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
    public class USP_S_CtaDepo_Proceso
    {
        public int I_CtaDepoProID { get; set; }
        public int I_CtaDepositoID { get; set; }
        public int I_ProcesoID { get; set; }
        public int I_EntidadFinanID { get; set; }
        public bool B_Habilitado { get; set; }
        public string C_NumeroCuenta { get; set; }
        public string T_EntidadDesc { get; set; }
        public string T_DescCuenta { get; set; }

        public static List<USP_S_CtaDepo_Proceso> Execute(int I_ProcesoID)
        {
            List<USP_S_CtaDepo_Proceso> result;
            DynamicParameters parameters = new DynamicParameters();
            try
            {
                string s_command = @"USP_S_CtaDepo_Proceso";

                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    parameters.Add(name: "I_ProcesoID", dbType: DbType.Int32, value: I_ProcesoID);

                    result = _dbConnection.Query<USP_S_CtaDepo_Proceso>(s_command, parameters, commandType: CommandType.StoredProcedure).ToList();
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
