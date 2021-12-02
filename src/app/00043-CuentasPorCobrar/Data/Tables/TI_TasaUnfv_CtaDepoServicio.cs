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
                    var s_command = @"SELECT * FROM TI_TasaUnfv_CtaDepoServicio WHERE B_Eliminado = 0";

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
                    var s_command = String.Format("INSERT TI_TasaUnfv_CtaDepoServicio(I_CtaDepoServicioID, I_TasaUnfvID, B_Habilitado, B_Eliminado, I_UsuarioCre, D_FecCre) VALUES({0}, {1}, 1, 0, {2}, GETDATE())", 
                        ctaDepositoServicioID, tasaUnfvID, currentUserID);

                    _dbConnection.Execute(s_command, commandType: CommandType.Text);
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
                    var s_command = String.Format("UPDATE TI_TasaUnfv_CtaDepoServicio SET B_Habilitado = 0, I_UsuarioMod = {0}, D_FecMod = GETDATE() WHERE I_TasaUnfvID = {1}", currentUserID, tasaUnfvID);

                    _dbConnection.Execute(s_command, commandType: CommandType.Text);
                }
            }
            catch (Exception)
            {
            }
        }

        public static void CambiarEstado(int tasaCtaDepoServicioID, int estado, int currentUserID)
        {
            try
            {
                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    var s_command = String.Format("UPDATE TI_TasaUnfv_CtaDepoServicio SET B_Habilitado = {0}, I_UsuarioMod = {1}, D_FecMod = GETDATE() WHERE I_TasaCtaDepoServicioID = {2}",
                        estado, currentUserID, tasaCtaDepoServicioID);

                    _dbConnection.Execute(s_command, commandType: CommandType.Text);
                }
            }
            catch (Exception)
            {
            }
        }
    }
}
