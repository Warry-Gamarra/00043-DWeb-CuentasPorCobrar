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
    public class USP_I_GrabarPeriodo
    {
        public int I_CuotaPagoID { get; set; }
        public short N_Anio { get; set; }
        public DateTime D_FecIni { get; set; }
        public DateTime D_FecFin { get; set; }

        public ResponseData Execute()
        {
            ResponseData result = new ResponseData();
            DynamicParameters parameters = new DynamicParameters();

            try
            {
                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    parameters.Add(name: "I_CuotaPagoID", dbType: DbType.Int32, value: this.I_CuotaPagoID);
                    parameters.Add(name: "N_Anio", dbType: DbType.Int32, value: this.N_Anio);
                    parameters.Add(name: "D_FecIni", dbType: DbType.DateTime, value: this.D_FecIni);
                    parameters.Add(name: "D_FecFin", dbType: DbType.DateTime, value: this.D_FecFin);

                    parameters.Add(name: "I_PeriodoID", dbType: DbType.Int32, direction: ParameterDirection.Output);
                    parameters.Add(name: "B_Result", dbType: DbType.Boolean, direction: ParameterDirection.Output);
                    parameters.Add(name: "T_Message", dbType: DbType.String, size: 4000, direction: ParameterDirection.Output);

                    _dbConnection.Execute("USP_I_GrabarPeriodo", parameters, commandType: CommandType.StoredProcedure);
                    int id = parameters.Get<int>("I_PeriodoID");
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
