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
    public class USP_U_ActualizarCtaDeposito_Proceso
    {
        public int I_CtaDepoProID { get; set; }
        public int I_CtaDepositoID { get; set; }
        public int I_ProcesoID { get; set; }
        public bool B_Habilitado { get; set; }
        public int I_UsuarioMod { get; set; }

        public ResponseData Execute()
        {
            ResponseData result = new ResponseData();
            DynamicParameters parameters = new DynamicParameters();

            try
            {
                string s_command = @"USP_U_ActualizarCtaDeposito_Proceso";

                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    parameters.Add(name: "I_CtaDepoProID", dbType: DbType.Int32, value: this.I_CtaDepoProID);
                    parameters.Add(name: "I_CtaDepositoID", dbType: DbType.Int32, value: this.I_CtaDepositoID);
                    parameters.Add(name: "I_ProcesoID", dbType: DbType.Int32, value: this.I_ProcesoID);
                    parameters.Add(name: "B_Habilitado", dbType: DbType.Boolean, value: this.B_Habilitado);
                    parameters.Add(name: "I_UsuarioMod", dbType: DbType.Int32, value: this.I_UsuarioMod);

                    parameters.Add(name: "B_Result", dbType: DbType.Boolean, direction: ParameterDirection.Output);
                    parameters.Add(name: "T_Message", dbType: DbType.String, size: 4000, direction: ParameterDirection.Output);

                    _dbConnection.Execute(s_command, parameters, commandType: CommandType.StoredProcedure);

                    result.CurrentID = this.I_CtaDepoProID.ToString();
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
