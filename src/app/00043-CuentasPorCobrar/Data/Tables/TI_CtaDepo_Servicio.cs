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
    public class TI_CtaDepo_Servicio
    {
        public int I_CtaDepoServicioID { get; set; }

        public int I_CtaDepositoID { get; set; }

        public int I_ServicioID { get; set; }

        public bool B_Habilitado { get; set; }

        public static TI_CtaDepo_Servicio FindByID(int I_CtaDepoServicioID)
        {
            TI_CtaDepo_Servicio result;

            try
            {
                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    var s_command = @"SELECT * FROM dbo.TI_CtaDepo_Servicio c 
                        WHERE c.B_Eliminado = 0 AND c.I_CtaDepoServicioID = @I_CtaDepoServicioID;";

                    var parameter = new { I_CtaDepoServicioID = I_CtaDepoServicioID };

                    result = _dbConnection.QueryFirst<TI_CtaDepo_Servicio>(s_command, parameter, commandType: CommandType.Text);
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
