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
    public class TC_CuentaDeposito
    {
        public int I_CtaDepositoID { get; set; }
        public int I_EntidadFinanID { get; set; }
        public string T_EntidadDesc { get; set; }
        public string C_NumeroCuenta { get; set; }
        public bool B_Habilitado { get; set; }
        public bool B_Eliminado { get; set; }
        public int? I_UsuarioCre { get; set; }
        public DateTime? D_FecCre { get; set; }
        public int? I_UsuarioMod { get; set; }
        public DateTime? D_FecMod { get; set; }


        public List<TC_CuentaDeposito> Find()
        {
            List<TC_CuentaDeposito> result = new List<TC_CuentaDeposito>();

            try
            {
                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    var s_command = @"SELECT CD.I_CtaDepositoID, CD.C_NumeroCuenta, CD.I_EntidadFinanID, CD.B_Habilitado, CD.B_Eliminado, CD.I_UsuarioCre, CD.D_FecCre, CD.I_UsuarioMod, 
                                        CD.D_FecMod, EF.T_EntidadDesc 
                                        FROM TC_CuentaDeposito CD INNER JOIN TC_EntidadFinanciera EF ON CD.I_EntidadFinanID = EF.I_EntidadFinanID ;";

                    result = _dbConnection.Query<TC_CuentaDeposito>(s_command, commandType: CommandType.Text).ToList();
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }

            return result;
        }

        public TC_CuentaDeposito Find(int cuentaDepositoId)
        {
            TC_CuentaDeposito result = new TC_CuentaDeposito();

            try
            {
                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    var s_command = @"SELECT CD.I_CtaDepositoID, CD.C_NumeroCuenta, CD.I_EntidadFinanID, CD.B_Habilitado, CD.B_Eliminado, CD.I_UsuarioCre, CD.D_FecCre, CD.I_UsuarioMod,
                                        CD.D_FecMod, EF.T_EntidadDesc 
                                      FROM TC_CuentaDeposito CD INNER JOIN TC_EntidadFinanciera EF ON CD.I_EntidadFinanID = EF.I_EntidadFinanID
                                      WHERE CD.I_CtaDepositoID = @I_CtaDepositoID ;";

                    result = _dbConnection.QueryFirstOrDefault<TC_CuentaDeposito>(s_command, new { I_CtaDepositoID = cuentaDepositoId }, commandType: CommandType.Text);
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }

            return result;
        }

        public ResponseData ChangeState(int currentUserId)
        {
            ResponseData result = new ResponseData();
            DynamicParameters parameters = new DynamicParameters();

            try
            {
                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    parameters.Add(name: "I_CtaDepositoID", dbType: DbType.Byte, value: this.I_CtaDepositoID);
                    parameters.Add(name: "B_Habilitado", dbType: DbType.Boolean, value: this.B_Habilitado);
                    parameters.Add(name: "D_FecMod", dbType: DbType.DateTime, value: this.D_FecMod);
                    parameters.Add(name: "CurrentUserId", dbType: DbType.Int32, value: currentUserId);

                    parameters.Add(name: "B_Result", dbType: DbType.Boolean, direction: ParameterDirection.Output);
                    parameters.Add(name: "T_Message", dbType: DbType.String, size: 4000, direction: ParameterDirection.Output);

                    _dbConnection.Execute("USP_U_ActualizarEstadoCuentaDeposito", parameters, commandType: CommandType.StoredProcedure);

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

        public ResponseData Insert(int currentUserId)
        {
            ResponseData result = new ResponseData();
            DynamicParameters parameters = new DynamicParameters();

            try
            {
                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    parameters.Add(name: "I_CtaDepositoID", dbType: DbType.Int32, value: this.I_CtaDepositoID);
                    parameters.Add(name: "I_EntidadFinanID", dbType: DbType.Int32, value: this.I_EntidadFinanID);
                    parameters.Add(name: "C_NumeroCuenta", dbType: DbType.String, size: 50, value: this.C_NumeroCuenta);
                    parameters.Add(name: "D_FecCre", dbType: DbType.DateTime, value: this.D_FecCre);
                    parameters.Add(name: "CurrentUserId", dbType: DbType.Int32, value: currentUserId);

                    parameters.Add(name: "B_Result", dbType: DbType.Boolean, direction: ParameterDirection.Output);
                    parameters.Add(name: "T_Message", dbType: DbType.String, size: 4000, direction: ParameterDirection.Output);

                    _dbConnection.Execute("USP_I_GrabarCuentaDeposito", parameters, commandType: CommandType.StoredProcedure);

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

        public ResponseData Update(int currentUserId)
        {
            ResponseData result = new ResponseData();
            DynamicParameters parameters = new DynamicParameters();

            try
            {
                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    parameters.Add(name: "I_CtaDepositoID", dbType: DbType.Int32, value: this.I_CtaDepositoID);
                    parameters.Add(name: "I_EntidadFinanID", dbType: DbType.Int32, value: this.I_EntidadFinanID);
                    parameters.Add(name: "C_NumeroCuenta", dbType: DbType.String, size: 50, value: this.C_NumeroCuenta);
                    parameters.Add(name: "D_FecMod", dbType: DbType.DateTime, value: this.D_FecMod);
                    parameters.Add(name: "CurrentUserId", dbType: DbType.Int32, value: currentUserId);

                    parameters.Add(name: "B_Result", dbType: DbType.Boolean, direction: ParameterDirection.Output);
                    parameters.Add(name: "T_Message", dbType: DbType.String, size: 4000, direction: ParameterDirection.Output);

                    _dbConnection.Execute("USP_U_GrabarCuentaDeposito", parameters, commandType: CommandType.StoredProcedure);

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
