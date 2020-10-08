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
    public class USP_I_GrabarPeriodo_CuentaDeposito
    {
        public int I_CtaDepID { get; set; }
        public int I_PeriodoID { get; set; }
        public int C_DepCod { get; set; }

        public ResponseData Execute()
        {
            ResponseData result = new ResponseData();
            DynamicParameters parameters = new DynamicParameters();

            try
            {
                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    parameters.Add(name: "I_CtaDepID", dbType: DbType.Int32, value: this.I_CtaDepID);
                    parameters.Add(name: "I_PeriodoID", dbType: DbType.Int32, value: this.I_PeriodoID);
                    parameters.Add(name: "C_DepCod", dbType: DbType.Int32, value: this.C_DepCod);
                    
                    parameters.Add(name: "B_Result", dbType: DbType.Boolean, direction: ParameterDirection.Output);
                    parameters.Add(name: "T_Message", dbType: DbType.String, size: 4000, direction: ParameterDirection.Output);

                    _dbConnection.Execute("USP_I_GrabarPeriodo_CuentaDeposito", parameters, commandType: CommandType.StoredProcedure);

                    result.Value = parameters.Get<bool>("B_Result");
                    result.Message = parameters.Get<string>("T_Message");
                }
            }
            catch (Exception ex)
            {
                result.Value = false;
                result.Message = ex.Message;
            }

            return result;
        }
    }
}
