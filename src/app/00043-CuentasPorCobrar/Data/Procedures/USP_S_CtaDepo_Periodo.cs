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
    public class USP_S_CtaDepo_Periodo
    {
        public int I_CtaDepoPerID { get; set; }
        public int I_CtaDepositoID { get; set; }
        public int I_PeriodoID { get; set; }
        public bool B_Habilitado { get; set; }
        public string C_NumeroCuenta { get; set; }
        public string T_EntidadDesc { get; set; }

        public static List<USP_S_CtaDepo_Periodo> Execute(int I_PeriodoID)
        {
            List<USP_S_CtaDepo_Periodo> result;
            DynamicParameters parameters = new DynamicParameters();
            try
            {
                string s_command = @"USP_S_CtaDepo_Periodo";

                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    parameters.Add(name: "I_PeriodoID", dbType: DbType.Int32, value: I_PeriodoID);

                    result = _dbConnection.Query<USP_S_CtaDepo_Periodo>(s_command, parameters, commandType: CommandType.StoredProcedure).ToList();
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
