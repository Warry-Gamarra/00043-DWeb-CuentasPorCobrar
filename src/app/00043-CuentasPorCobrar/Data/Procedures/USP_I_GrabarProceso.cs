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
    public class USP_I_GrabarProceso
    {
        public int I_CatPagoID { get; set; }
        public int? I_Anio { get; set; }
        public int MyProperty { get; set; }
        public DateTime? D_FecVencto { get; set; }
        public DateTime? D_FecVenctoExt { get; set; }
        public int? I_Prioridad { get; set; }
        public int? I_Periodo { get; set; }
        public string N_CodBanco { get; set; }
        public string T_ProcesoDesc { get; set; }
        public int I_UsuarioCre { get; set; }

        public int? I_CuotaPagoID { get; set; }

        public ResponseData Execute()
        {
            ResponseData result = new ResponseData();
            DynamicParameters parameters = new DynamicParameters();

            try
            {
                string s_command = @"USP_I_GrabarProceso";

                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    parameters.Add(name: "I_CatPagoID", dbType: DbType.Int32, value: this.I_CatPagoID);
                    parameters.Add(name: "I_Anio", dbType: DbType.Int16, value: this.I_Anio);
                    parameters.Add(name: "I_Periodo", dbType: DbType.Int16, value: this.I_Periodo);
                    parameters.Add(name: "D_FecVencto", dbType: DbType.DateTime, value: this.D_FecVencto);
                    parameters.Add(name: "D_FecVenctoExt", dbType: DbType.DateTime, value: this.D_FecVenctoExt);
                    parameters.Add(name: "I_Prioridad", dbType: DbType.Byte, value: this.I_Prioridad);
                    parameters.Add(name: "N_CodBanco", dbType: DbType.String, size: 10, value: this.N_CodBanco);
                    parameters.Add(name: "T_ProcesoDesc", dbType: DbType.String, size: 250, value: this.T_ProcesoDesc);
                    parameters.Add(name: "I_UsuarioCre", dbType: DbType.Int32, value: this.I_UsuarioCre);
                    parameters.Add(name: "I_CuotaPagoID", dbType: DbType.Int32, value: this.I_CuotaPagoID);

                    parameters.Add(name: "I_ProcesoID", dbType: DbType.Int32, direction: ParameterDirection.Output);
                    parameters.Add(name: "B_Result", dbType: DbType.Boolean, direction: ParameterDirection.Output);
                    parameters.Add(name: "T_Message", dbType: DbType.String, size: 4000, direction: ParameterDirection.Output);

                    _dbConnection.Execute(s_command, parameters, commandType: CommandType.StoredProcedure);

                    int id = parameters.Get<int>("I_ProcesoID");
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
