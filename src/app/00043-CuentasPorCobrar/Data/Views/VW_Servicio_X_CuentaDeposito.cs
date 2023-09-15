using Dapper;
using Data.Connection;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Data.Views
{
    public class VW_Servicio_X_CuentaDeposito
    {
        public int I_CtaDepoServicioID { get; set; }
        
        public string T_EntidadDesc { get; set; }
        
        public string C_NumeroCuenta { get; set; }
        
        public string C_CodServicio { get; set; }

        public string T_DescServ { get; set; }

        public bool B_Habilitado { get; set; }

        public static IEnumerable<VW_Servicio_X_CuentaDeposito> GetAll()
        {
            IEnumerable<VW_Servicio_X_CuentaDeposito> result;

            try
            {
                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    var s_command = @"SELECT * FROM VW_Servicio_X_CuentaDeposito;";

                    result = _dbConnection.Query<VW_Servicio_X_CuentaDeposito>(s_command, commandType: CommandType.Text);
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
