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
    public class TI_TasaUnfv_CtaDepoServicio
    {
        public int I_TasaCtaDepoServicioID { get; set; }
        public int I_CtaDepoServicioID { get; set; }
        public int I_TasaUnfvID { get; set; }
        public bool B_Habilitado { get; set; }

        public static IEnumerable<TI_TasaUnfv_CtaDepoServicio> GetAll()
        {
            IEnumerable<TI_TasaUnfv_CtaDepoServicio> result;

            try
            {
                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    var s_command = @"SELECT * FROM TI_TasaUnfv_CtaDepoServicio WHERE B_Eliminado = 0;";

                    result = _dbConnection.Query<TI_TasaUnfv_CtaDepoServicio>(s_command, commandType: CommandType.Text);
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }

            return result;
        }

        public static void Insert(int ctaDepositoServicioID, int tasaUnfvID, int currentUserID)
        {
            try
            {
                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    var s_command = @"INSERT TI_TasaUnfv_CtaDepoServicio(I_CtaDepoServicioID, I_TasaUnfvID, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre) 
                        VALUES(@I_CtaDepoServicioID, @I_TasaUnfvID, 1, 0, @I_UsuarioCre, GETDATE());";

                    var parameters = new
                    {
                        I_CtaDepoServicioID = ctaDepositoServicioID,
                        I_TasaUnfvID = tasaUnfvID,
                        I_UsuarioCre = currentUserID
                    };

                    _dbConnection.Execute(s_command, parameters, commandType: CommandType.Text);
                }
            }
            catch (Exception)
            {
            }
        }

        public static void DeshabilitarPorTasa(int tasaUnfvID, int currentUserID)
        {
            try
            {
                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    var s_command = @"UPDATE TI_TasaUnfv_CtaDepoServicio SET B_Habilitado = 0, I_UsuarioMod = @I_UsuarioMod, D_FecMod = GETDATE() 
                        WHERE I_TasaUnfvID = @I_TasaUnfvID;";

                    var parameters = new
                    {
                        I_UsuarioMod = currentUserID,
                        I_TasaUnfvID = tasaUnfvID
                    };

                    _dbConnection.Execute(s_command, parameters, commandType: CommandType.Text);
                }
            }
            catch (Exception)
            {
            }
        }

        public static void CambiarEstado(int tasaCtaDepoServicioID, bool estado, int currentUserID)
        {
            try
            {
                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    var s_command = @"UPDATE TI_TasaUnfv_CtaDepoServicio SET B_Habilitado = @B_Habilitado, I_UsuarioMod = @I_UsuarioMod, D_FecMod = GETDATE() 
                        WHERE I_TasaCtaDepoServicioID = @I_TasaCtaDepoServicioID;";

                    var parameters = new
                    {
                        B_Habilitado = estado,
                        I_UsuarioMod = currentUserID,
                        I_TasaCtaDepoServicioID = tasaCtaDepoServicioID
                    };

                    _dbConnection.Execute(s_command, parameters, commandType: CommandType.Text);
                }
            }
            catch (Exception)
            {
            }
        }

        public static int[] ObtenerCtaDepositoServicioIDByTasa(int tasaUnfvID)
        {
            int[] result;

            try
            {
                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    var s_command = @"SELECT I_CtaDepoServicioID FROM TI_TasaUnfv_CtaDepoServicio 
                        WHERE B_Habilitado = 1 AND B_Eliminado = 0 AND I_TasaUnfvID = @I_TasaUnfvID;";

                    var parameters = new { I_TasaUnfvID = tasaUnfvID };

                    var lista = _dbConnection.Query<TI_TasaUnfv_CtaDepoServicio>(s_command, parameters, commandType: CommandType.Text);

                    result = lista.Select(x => x.I_CtaDepoServicioID).ToArray();
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
