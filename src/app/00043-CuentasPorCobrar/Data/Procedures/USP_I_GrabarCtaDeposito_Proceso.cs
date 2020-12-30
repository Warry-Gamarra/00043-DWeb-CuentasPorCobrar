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
    public class USP_I_GrabarCtaDeposito_Proceso
    {
        public int I_CtaDepositoID { get; set; }
        public int I_ProcesoID { get; set; }
        public int I_UsuarioCre { get; set; }

        public ResponseData Execute()
        {
            ResponseData result = new ResponseData();
            DynamicParameters parameters = new DynamicParameters();

            try
            {
                string s_command = @"USP_I_GrabarCtaDeposito_Proceso";

                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    parameters.Add(name: "I_CtaDepositoID", dbType: DbType.Int32, value: this.I_CtaDepositoID);
                    parameters.Add(name: "I_ProcesoID", dbType: DbType.Int32, value: this.I_ProcesoID);
                    parameters.Add(name: "I_UsuarioCre", dbType: DbType.Int32, value: this.I_UsuarioCre);

                    parameters.Add(name: "I_CtaDepoProID", dbType: DbType.Int32, direction: ParameterDirection.Output);
                    parameters.Add(name: "B_Result", dbType: DbType.Boolean, direction: ParameterDirection.Output);
                    parameters.Add(name: "T_Message", dbType: DbType.String, size: 4000, direction: ParameterDirection.Output);

                    _dbConnection.Execute(s_command, parameters, commandType: CommandType.StoredProcedure);

                    int id = parameters.Get<int>("I_CtaDepoProID");
                    result.CurrentID = id.ToString();
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
