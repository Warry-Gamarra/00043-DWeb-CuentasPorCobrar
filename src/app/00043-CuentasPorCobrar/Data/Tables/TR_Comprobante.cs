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
    public class TR_Comprobante
    {
        public int I_ComprobanteID { get; set; }

        public int I_TipoComprobanteID { get; set; }

        public int I_SerieID { get; set; }

        public int I_NumeroComprobante { get; set; }

        public bool B_EsGravado { get; set; }

        public DateTime D_FechaEmision { get; set; }

        public int I_EstadoComprobanteID { get; set; }

        public static bool ExistBySerie(int I_SerieID)
        {
            bool exist;

            try
            {
                string s_command = "SELECT COUNT(c.I_ComprobanteID) FROM dbo.TR_Comprobante c WHERE c.I_SerieID = @I_SerieID;";

                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    var count = _dbConnection.ExecuteScalar<int>(s_command, new { I_SerieID }, commandType: CommandType.Text);

                    exist = count > 0;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }

            return exist;
        }

        public static bool ExistByTipo(int I_TipoComprobanteID)
        {
            bool exist;

            try
            {
                string s_command = "SELECT COUNT(c.I_ComprobanteID) FROM dbo.TR_Comprobante c WHERE c.I_TipoComprobanteID = @I_TipoComprobanteID;";

                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    var count = _dbConnection.ExecuteScalar<int>(s_command, new { I_TipoComprobanteID }, commandType: CommandType.Text);

                    exist = count > 0;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }

            return exist;
        }
    }
}
