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

        public static IEnumerable<TI_CtaDepo_Servicio> GetAll()
        {
            IEnumerable<TI_CtaDepo_Servicio> result;

            try
            {
                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    var s_command = @"SELECT * FROM TI_CtaDepo_Servicio WHERE B_Eliminado = 0";

                    result = _dbConnection.Query<TI_CtaDepo_Servicio>(s_command, commandType: CommandType.Text).ToList();
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }

            return result;
        }

        public static int Insert(int idCtaDeposito, int idServicio, int currentUserID)
        {
            int id;
            try
            {
                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    var s_command = String.Format("INSERT TI_CtaDepo_Servicio(I_CtaDepositoID, I_ServicioID, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre) VALUES({0}, {1}, 1, 0, {2}, GETDATE()); SELECT CAST(SCOPE_IDENTITY() as int)",
                        idCtaDeposito, idServicio, currentUserID);

                    id = _dbConnection.QuerySingle<int>(s_command, commandType: CommandType.Text);
                }
            }
            catch (Exception)
            {
                id = 0;
            }

            return id;
        }

        public static int[] ObtenerCtaDepositoIDByTasa(int tasaUnfvID)
        {
            int[] result;

            try
            {
                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    var s_command = @"SELECT DISTINCT s.I_CtaDepositoID FROM dbo.TI_TasaUnfv_CtaDepoServicio c
                        INNER JOIN dbo.TI_CtaDepo_Servicio s ON s.I_CtaDepoServicioID = c.I_CtaDepoServicioID and s.B_Eliminado = 0
                        WHERE I_TasaUnfvID = " + tasaUnfvID.ToString() + " AND c.B_Eliminado = 0 AND c.B_Habilitado = 1";

                    var lista = _dbConnection.Query<TI_CtaDepo_Servicio>(s_command, commandType: CommandType.Text);

                    result = lista.Select(x => x.I_CtaDepositoID).ToArray();
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }

            return result;
        }

        public static int[] ObtenerServicioIDByTasa(int tasaUnfvID)
        {
            int[] result;

            try
            {
                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    var s_command = @"SELECT DISTINCT s.I_ServicioID FROM dbo.TI_TasaUnfv_CtaDepoServicio c
                        INNER JOIN dbo.TI_CtaDepo_Servicio s ON s.I_CtaDepoServicioID = c.I_CtaDepoServicioID and s.B_Eliminado = 0
                        WHERE I_TasaUnfvID = " + tasaUnfvID.ToString() + " AND c.B_Eliminado = 0 AND c.B_Habilitado = 1";

                    var lista = _dbConnection.Query<TI_CtaDepo_Servicio>(s_command, commandType: CommandType.Text);

                    result = lista.Select(x => x.I_ServicioID).ToArray();
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
