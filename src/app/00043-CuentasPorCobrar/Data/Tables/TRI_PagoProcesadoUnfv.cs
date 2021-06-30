using Dapper;
using Data.Connection;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Data.Tables
{
    public class TRI_PagoProcesadoUnfv
    {
        public int I_PagoProcesID { get; set; }
        public int I_PagoBancoID { get; set; }
        public int I_CtaDepositoID { get; set; }
        public int I_TasaUnfvID { get; set; }
        public int I_ObligacionAluID { get; set; }
        public decimal I_MontoPagado { get; set; }
        public decimal I_SaldoAPagar { get; set; }
        public decimal I_PagoDemas { get; set; }
        public bool B_PagoDemas { get; set; }
        public int N_NroSIAF { get; set; }
        public bool B_Anulado { get; set; }
        public DateTime D_FecCre { get; set; }
        public int I_UsuarioCre { get; set; }
        public DateTime D_FecMod { get; set; }
        public int I_UsuarioMod { get; set; }



        public ResponseData SaveNroSIAF()
        {
            ResponseData result = new ResponseData();

            DynamicParameters parameters = new DynamicParameters();

            try
            {
                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    parameters.Add(name: "I_PagoProcesID", dbType: DbType.Int32, value: this.I_PagoProcesID);
                    parameters.Add(name: "N_NroSIAF", dbType: DbType.Int32, value: this.N_NroSIAF);
                    parameters.Add(name: "D_FecMod", dbType: DbType.DateTime, value: this.D_FecMod);
                    parameters.Add(name: "CurrentUserId", dbType: DbType.Int32, value: I_UsuarioMod);

                    parameters.Add(name: "B_Result", dbType: DbType.Boolean, direction: ParameterDirection.Output);
                    parameters.Add(name: "T_Message", dbType: DbType.String, size: 4000, direction: ParameterDirection.Output);

                    _dbConnection.Execute("USP_U_GrabarNroSIAFRegistroPago", parameters, commandType: CommandType.StoredProcedure);

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

        public ResponseData AnularRegistroPago()
        {
            ResponseData result = new ResponseData();

            DynamicParameters parameters = new DynamicParameters();

            try
            {
                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    parameters.Add(name: "I_PagoProcesID", dbType: DbType.Int32, value: this.I_PagoProcesID);
                    parameters.Add(name: "D_FecMod", dbType: DbType.DateTime, value: this.D_FecMod);
                    parameters.Add(name: "CurrentUserId", dbType: DbType.Int32, value: I_UsuarioMod);

                    parameters.Add(name: "B_Result", dbType: DbType.Boolean, direction: ParameterDirection.Output);
                    parameters.Add(name: "T_Message", dbType: DbType.String, size: 4000, direction: ParameterDirection.Output);

                    _dbConnection.Execute("USP_U_AnularPagoRegistrado", parameters, commandType: CommandType.StoredProcedure);

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
