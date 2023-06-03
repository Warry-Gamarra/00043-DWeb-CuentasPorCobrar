using Data.Connection;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Dapper;

namespace Data.Tables
{
    public class TR_ConstanciaPago
    {
        public int I_ConstanciaPagoID { get; set; }

        public int I_PagoBancoID { get; set; }

        public int I_ConstanciaPagoNum { get; set; }

        public int I_UsuarioCre { get; set; }

        public DateTime D_FecCre { get; set; }

        public static int GenerarNroConstancia()
        {
            int nroConstancia;

            try
            {
                string s_command = @"SELECT ISNULL(MAX(I_ConstanciaPagoNum), 0) + 1 AS I_ConstanciaPagoNum FROM dbo.TR_ConstanciaPago;";

                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    var query = _dbConnection.QuerySingle<TR_ConstanciaPago>(s_command, null, commandType: CommandType.Text);

                    nroConstancia = query.I_ConstanciaPagoNum;
                }
            }
            catch (Exception)
            {
                nroConstancia = 0;
            }

            return nroConstancia;
        }

        public static int? GetNroConstancia(int I_PagoBancoID)
        {
            int? nroConstancia;

            try
            {
                string s_command = @"SELECT * FROM dbo.TR_ConstanciaPago WHERE I_PagoBancoID = @I_PagoBancoID;";

                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    var query = _dbConnection.QuerySingle<TR_ConstanciaPago>(s_command, new { I_PagoBancoID = I_PagoBancoID }, commandType: CommandType.Text);

                    nroConstancia = query.I_ConstanciaPagoNum;
                }
            }
            catch (Exception)
            {
                nroConstancia = null;
            }

            return nroConstancia;
        }

        public ResponseData Save()
        {
            ResponseData result = new ResponseData();
            DynamicParameters parameters = new DynamicParameters();

            try
            {
                string s_command = @"USP_I_GrabarConstanciaPago";

                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    parameters.Add(name: "I_PagoBancoID", dbType: DbType.Int32, value: I_PagoBancoID);
                    parameters.Add(name: "I_ConstanciaPagoNum", dbType: DbType.Int32, value: I_ConstanciaPagoNum);
                    parameters.Add(name: "UserID", dbType: DbType.Int32, value: I_UsuarioCre);
                    
                    _dbConnection.Execute(s_command, parameters, commandType: CommandType.StoredProcedure);

                    result.Value = true;
                    result.Message = "Grabación correcta.";
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
