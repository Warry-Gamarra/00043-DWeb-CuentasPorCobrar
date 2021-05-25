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
    public class TR_DevolucionPago
    {
        public int I_DevolucionPagoID { get; set; }
        public int I_PagoProcesID { get; set; }
        public decimal I_MontoPagoDev { get; set; }
        public DateTime? D_FecDevAprob { get; set; }
        public DateTime? D_FecDevPago { get; set; }
        public DateTime? D_FecProc { get; set; }
        public bool B_Eliminado { get; set; }
        public int? I_UsuarioCre { get; set; }
        public DateTime? D_FecCre { get; set; }
        public int? I_UsuarioMod { get; set; }
        public DateTime? D_FecMod { get; set; }

        public static List<TR_DevolucionPago> FindAll()
        {
            List<TR_DevolucionPago> result;

            try
            {
                string s_command = @"select t.* from dbo.TC_CategoriaPago t  WHERE B_Eliminado = 0;";

                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    result = _dbConnection.Query<TR_DevolucionPago>(s_command, commandType: CommandType.Text).ToList();
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }

            return result;
        }

        public static TR_DevolucionPago FindByID(int I_CatPagoID)
        {
            TR_DevolucionPago result;

            try
            {
                string s_command = @"select t.* from dbo.TC_CategoriaPago t where t.I_CatPagoID = @I_CatPagoID";

                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    result = _dbConnection.Query<TR_DevolucionPago>(s_command, new { I_CatPagoID = I_CatPagoID }, commandType: CommandType.Text).FirstOrDefault();
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
